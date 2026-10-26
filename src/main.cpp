#include "shaders/renderer.h"
#include <optix_function_table_definition.h>
#include "loader.h"
#include <cstring>
#include <cstddef>
#include <utility>
#include <sys/mman.h>
#include <unistd.h>
#include "shaders.h"

// Kinds of what the extension pipes in
enum { SCENE, REQUEST, UPDATE, STEPS };

int main(int, char** argv) { // Usage: renderer file < scenes and requests > an answer per request, sums in the file
    // CUDA + OptiX contexts
    CUcontext cuda;
    OptixDeviceContext context;
    CHECK(cuInit(0));
    CHECK(cuCtxCreate(&cuda, nullptr, 0, 0));
    CHECK(optixInit());
    CHECK(optixDeviceContextCreate(cuda, nullptr, &context));
    // Require RT cores
    unsigned rtcore;
    CHECK(optixDeviceContextGetProperty(context, OPTIX_DEVICE_PROPERTY_RTCORE_VERSION, &rtcore, sizeof(rtcore)));
    CHECK(!rtcore); // RT cores required: built-in triangles then use hardware traversal and intersection.
    if (!argv[1]) return 0; // Probe: whether this machine's device runs it
    const int shared = std::atoi(argv[1]);
    // Scenes keep the reuse textures; the arrays of the last one loaded
    Scene scene{.pairing = {loadPairing(PAIRING_SIZES[0]), loadPairing(PAIRING_SIZES[1]),
        loadPairing(PAIRING_SIZES[2])}};
    Loaded loaded;
    // Temporal denoiser of the means, guided by their motion
    OptixDenoiserOptions denoiserOptions{};
    OptixDenoiser denoiser;
    CHECK(optixDenoiserCreate(context, OPTIX_DENOISER_MODEL_KIND_TEMPORAL_AOV, &denoiserOptions, &denoiser));

    // Embedded PTX compiled for the steps the scene's programs take, bound in params: first for none
    OptixPipelineCompileOptions compile{.numPayloadValues = 6, // The triangle a ray skips, a layer and its gathering
        .pipelineLaunchParamsVariableName = "params"};
    Params params{};
    const OptixModuleCompileBoundValueEntry bound{0, sizeof(params), &params};
    OptixModuleCompileOptions moduleOptions{.boundValues = &bound, .numBoundValues = 1};
    const CUdeviceptr launch = allocate(sizeof(params));
    OptixModule module;
    // Raygen programs of a frame's passes, then the any-hit program skipping a triangle: rays are only traversed, so
    // none runs on a miss or a closest hit
    constexpr unsigned PASSES = std::size(PROGRAMS);
    OptixProgramGroup groups[PASSES + 1];
    OptixProgramGroupOptions groupOptions{};
    // Link pipeline, no recursion
    OptixPipelineLinkOptions link{.maxTraceDepth = 1};
    OptixPipeline pipeline;
    // SBT records carrying scene: first the anchor's, scene in the BVH, triangles and lights its reservoirs were last
    // traced in, which a view's first temporal pass reprojects into, then one per pass
    struct alignas(OPTIX_SBT_RECORD_ALIGNMENT) Record { char header[OPTIX_SBT_RECORD_HEADER_SIZE]; Scene data; };
    static_assert(sizeof(Record) == RECORD_STRIDE, "The shaders step back to the anchor's record by RECORD_STRIDE");
    Record records[PASSES + 1]{};
    const CUdeviceptr table = allocate(sizeof(records));
    struct alignas(OPTIX_SBT_RECORD_ALIGNMENT) HitRecord { char header[OPTIX_SBT_RECORD_HEADER_SIZE]; } hit;
    OptixShaderBindingTable sbt = {.hitgroupRecordBase = allocate(sizeof(hit)),
        .hitgroupRecordStrideInBytes = sizeof(hit), .hitgroupRecordCount = 1};
    const auto specialize = [&] { // Module, programs and pipeline for params
        CHECK(cuMemcpyHtoD(launch, &params, sizeof(params)));
        CHECK(optixModuleCreate(context, &moduleOptions, &compile,
            (const char*)build_shaders_ptx, build_shaders_ptx_len, nullptr, nullptr, &module));
        for (unsigned pass = 0; pass < PASSES; ++pass) {
            OptixProgramGroupDesc desc{.kind = OPTIX_PROGRAM_GROUP_KIND_RAYGEN, .raygen = {module, PROGRAMS[pass]}};
            CHECK(optixProgramGroupCreate(context, &desc, 1, &groupOptions, nullptr, nullptr, &groups[pass]));
            CHECK(optixSbtRecordPackHeader(groups[pass], &records[pass + 1]));
        }
        OptixProgramGroupDesc skip{.kind = OPTIX_PROGRAM_GROUP_KIND_HITGROUP,
            .hitgroup = {.moduleAH = module, .entryFunctionNameAH = "__anyhit__skip"}};
        CHECK(optixProgramGroupCreate(context, &skip, 1, &groupOptions, nullptr, nullptr, &groups[PASSES]));
        CHECK(optixPipelineCreate(context, &compile, &link, groups, PASSES + 1, nullptr, nullptr, &pipeline));
        CHECK(optixSbtRecordPackHeader(groups[PASSES], &hit));
        CHECK(cuMemcpyHtoD(sbt.hitgroupRecordBase, &hit, sizeof(hit)));
    };
    specialize();
    // Each request accumulates up to launches more samples of its view, samples at most, and is answered with the
    // number launched, memory used and peak in MiB, the sums left in the shared file if any were. A new view starts
    // over: it persists the last one if it has its size and settings and its camera did not jump, move farther than
    // distance or turn further than the angle of cosine, keeping its reservoirs and denoised sequence and tracing reuse
    // samples at most; otherwise all of the view's arrays are freed and allocated zeroed. So does the view after a new
    // scene, persisting the last one only if it has as many triangles. A persisted view starts from the reservoirs the
    // last view starting over ended with, against the scene they were traced in, and jumps by that view's camera.
    struct View { unsigned width, height; Settings settings; Camera camera; } view{};
    struct { unsigned samples, reuse; float distance, cosine; unsigned launches; View view; } request;
    bool reused = false;
    size_t pixels = 1;
    float4* sums = (float4*)mmap(nullptr, sizeof(float4), PROT_WRITE, MAP_SHARED, shared, 0);
    loadView(scene, 1); // For the first view to free like any later one's
    scene.vertices = scene.previousVertices = (float3*)allocate(0); // For the first scene to keep or free
    // The reservoirs the last view starting over ended with and their duplication, its camera and the scratch and
    // output of the BVH of the scene it was traced in
    CUdeviceptr anchor = allocate(0), anchorTemp = allocate(0), anchorOutput = allocate(0);
    Camera anchorCamera{};
    scene.anchorVertices = (float3*)allocate(0), scene.anchorNormals = (float3*)allocate(0);
    scene.anchorLights = (LightNode*)allocate(0), scene.anchorTrails = (unsigned long long*)allocate(0);
    // Of a denoised view's state and scratch, besides its denoised means and the internal guides of the frame last
    // denoised and the next; whether those hold one of its sequence
    OptixDenoiserSizes sizes;
    CUdeviceptr state, scratch, denoised, guides[2];
    bool history = false;
    for (unsigned done = 0, launched, kind; std::fread(&kind, sizeof(kind), 1, stdin); std::fflush(stdout)) {
        if (kind != REQUEST) {
            const unsigned count = scene.count;
            kind == SCENE ? loadScene(context, scene, loaded) : kind == UPDATE ? updateScene(context, scene, loaded)
                : updateSteps(scene, loaded);
            Params next{};
            for (const Op& op : loaded.ops) next.ops[op.code >> 6] |= 1ull << (op.code & 63);
            if (std::memcmp(&next, &params, sizeof(params))) { // Compiled anew for other steps, in place of the last
                CHECK(optixPipelineDestroy(pipeline));
                for (OptixProgramGroup group : groups) CHECK(optixProgramGroupDestroy(group));
                CHECK(optixModuleDestroy(module));
                params = next;
                specialize();
            }
            for (unsigned bake : std::exchange(kind == SCENE ? loaded.bakes : loaded.rebakes, {})) { // A scene's, or
                const Op& texture = loaded.ops[bake - 1]; // those new steps run again, once: numbered by its frame,
                CHECK(cuMemsetD32((CUdeviceptr)(scene.texels + texture.texel), 0, 2 * texture.width * texture.height));
                for (unsigned pass = 0, tiles = loaded.ops[bake - 2].width; pass < (tiles ? 2 : 1); ++pass) {
                    records[PASSES - 2].data = scene; // before the lights pass: 16 x 16 texels per tile, inside their
                    records[PASSES - 2].data.frame = bake | pass << 31; // triangles, then off their edges, as halves;
                    records[PASSES - 2].data.ops = (Op*)loaded.bakeOps - loaded.rows; // the bakes' steps, numbered on
                    CHECK(cuMemcpyHtoD(table + (PASSES - 2) * sizeof(Record), &records[PASSES - 2], sizeof(Record)));
                    const OptixShaderBindingTable sbt = {.raygenRecord = table + (PASSES - 2) * sizeof(Record)};
                    CHECK(optixLaunch(pipeline, nullptr, launch, sizeof(params), &sbt, tiles ? 16 * tiles // or,
                        : texture.width, tiles ? 16 : texture.height, 1)); // without tiles, every texel at once
                }
            }
            if (loaded.bakeOps) // Freed once baked, as nothing else reads them: those the next steps need come again
                release(loaded.bakeOps), release((CUdeviceptr)scene.bakeTexels), loaded.bakeOps = 0,
                    scene.bakeTexels = {};
            std::vector<Material> materials = loaded.materials;
            if (scene.count) {
                CHECK(cuMemcpyHtoD((CUdeviceptr)scene.materials, materials.data(), materials.size() * sizeof(Material)));
                records[PASSES - 1].data = scene;
                CHECK(cuMemcpyHtoD(table + (PASSES - 1) * sizeof(Record), &records[PASSES - 1], sizeof(Record)));
                const OptixShaderBindingTable sbt = {.raygenRecord = table + (PASSES - 1) * sizeof(Record)};
                CHECK(optixLaunch(pipeline, nullptr, launch, sizeof(params), &sbt, scene.count, 1, 1));
                CHECK(cuMemcpyDtoH(materials.data(), (CUdeviceptr)scene.materials, materials.size() * sizeof(Material)));
            }
            unsigned long long* trails;
            LightNode* const lights = loadLights(loaded.vertices, materials, trails);
            std::replace(loaded.arrays.begin(), loaded.arrays.end(), (CUdeviceptr)scene.lights, (CUdeviceptr)lights);
            std::replace(loaded.arrays.begin(), loaded.arrays.end(), (CUdeviceptr)scene.trails, (CUdeviceptr)trails);
            release((CUdeviceptr)scene.lights), release((CUdeviceptr)scene.trails);
            scene.lights = lights, scene.trails = trails;
            view.camera = {};
            if (scene.count != count) view.width = 0;
            continue;
        }
        std::fread(&request, sizeof(request), 1, stdin);
        if (std::memcmp(&view, &request.view, sizeof(View))) {
            const Camera &last = anchorCamera, &next = request.view.camera;
            reused = length(next.origin - last.origin) <= request.distance
                && dot(next.z, last.z) >= request.cosine * length(next.z) * length(last.z)
                && !std::memcmp(&next.lens, &last.lens, sizeof(Lens));
            if (!reused || std::memcmp(&view, &request.view, offsetof(View, camera))) {
                reused = false;
                for (void* array : {(void*)scene.accumulation, (void*)scene.previous, (void*)scene.initial,
                    (void*)scene.temporal, (void*)scene.shifts, (void*)anchor})
                    release((CUdeviceptr)array);
                loadView(scene, request.view.width * request.view.height);
                CHECK(munmap(sums, pixels * sizeof(float4)));
                pixels = request.view.width * request.view.height;
                CHECK(ftruncate(shared, pixels * sizeof(float4)));
                sums = (float4*)mmap(nullptr, pixels * sizeof(float4), PROT_WRITE, MAP_SHARED, shared, 0);
                CHECK(sums == MAP_FAILED);
                anchor = (CUdeviceptr)zeros<char>(pixels * (sizeof(Reservoir) + sizeof(float)));
                anchorCamera = request.view.camera;
                if (view.settings.denoise) for (CUdeviceptr array : {state, scratch, denoised, guides[0], guides[1],
                    (CUdeviceptr)scene.mean, (CUdeviceptr)scene.flow, (CUdeviceptr)scene.trust,
                    (CUdeviceptr)scene.seen, (CUdeviceptr)scene.previousSeen}) release(array);
                if (request.view.settings.denoise) {
                    const unsigned width = request.view.width, height = request.view.height;
                    CHECK(optixDenoiserComputeMemoryResources(denoiser, width, height, &sizes));
                    state = allocate(sizes.stateSizeInBytes);
                    scratch = allocate(sizes.withoutOverlapScratchSizeInBytes);
                    denoised = (CUdeviceptr)zeros<float4>(pixels);
                    for (CUdeviceptr& guide : guides)
                        guide = (CUdeviceptr)zeros<char>(pixels * sizes.internalGuideLayerPixelSizeInBytes);
                    scene.mean = zeros<float4>(pixels), scene.flow = zeros<float2>(pixels);
                    scene.trust = zeros<float>(pixels);
                    scene.seen = zeros<unsigned>(pixels), scene.previousSeen = zeros<unsigned>(pixels);
                    CHECK(optixDenoiserSetup(denoiser, nullptr, width, height, state, sizes.stateSizeInBytes, scratch,
                        sizes.withoutOverlapScratchSizeInBytes));
                }
            } else {
                CHECK(cuMemcpyDtoD((CUdeviceptr)scene.previous, anchor, pixels * (sizeof(Reservoir) + sizeof(float))));
                scene.previousCamera = anchorCamera;
            }
            view = request.view;
            history = history && reused;
            done = scene.frame = 0; // Random numbers repeat per view
            scene.camera = view.camera;
            scene.settings = view.settings;
            CHECK(cuMemsetD32((CUdeviceptr)scene.accumulation, 0, 4 * pixels));
        }
        // A ReSTIR frame per sample: its passes in order over the pixels times their depth, none of depth 0, then its
        // camera is the one the next frame reprojects from. Without ReSTIR only the initial pass runs, the duplication
        // map only for decorrelation.
        const unsigned restir = scene.settings.restir;
        const unsigned depths[PASSES] = {1, restir, restir * scene.settings.neighbors, restir,
            restir * scene.settings.decorrelation, 0};
        const unsigned samples = reused ? request.reuse : request.samples;
        for (launched = 0; launched < request.launches && done < samples; ++launched, ++done, ++scene.frame) {
            for (Record& record : records) record.data = scene;
            Scene& anchored = records[0].data;
            anchored.handle = scene.anchorHandle, anchored.vertices = scene.anchorVertices;
            anchored.normals = scene.anchorNormals, anchored.lights = scene.anchorLights;
            anchored.trails = scene.anchorTrails;
            CHECK(cuMemcpyHtoD(table, records, sizeof(records)));
            for (unsigned pass = 0; pass < PASSES; ++pass) if (depths[pass]) {
                sbt.raygenRecord = table + (pass + 1) * sizeof(Record);
                CHECK(optixLaunch(pipeline, nullptr, launch, sizeof(params), &sbt, view.width, view.height, depths[pass]));
            }
            scene.previousCamera = scene.camera;
        }
        if (!reused && launched && done == samples) {
            CHECK(cuMemcpyDtoD(anchor, (CUdeviceptr)scene.previous, pixels * (sizeof(Reservoir) + sizeof(float))));
            for (CUdeviceptr array : {(CUdeviceptr)scene.anchorVertices, (CUdeviceptr)scene.anchorNormals,
                (CUdeviceptr)scene.anchorLights, (CUdeviceptr)scene.anchorTrails, anchorTemp, anchorOutput})
                release(array);
            scene.anchorVertices = (float3*)copy((CUdeviceptr)scene.vertices);
            scene.anchorNormals = (float3*)copy((CUdeviceptr)scene.normals);
            scene.anchorLights = (LightNode*)copy((CUdeviceptr)scene.lights);
            scene.anchorTrails = (unsigned long long*)copy((CUdeviceptr)scene.trails);
            scene.anchorHandle = buildBVH(context, (CUdeviceptr)scene.anchorVertices, scene.count,
                OPTIX_BUILD_OPERATION_BUILD, anchorTemp, anchorOutput);
        }
        std::fwrite(&launched, sizeof(launched), 1, stdout);
        const float memory[] = {float(memory_used) / (1024 * 1024), float(memory_peak) / (1024 * 1024)};
        std::fwrite(memory, sizeof(memory), 1, stdout);
        if (!launched) continue;
        // Raw linear sums with the sample count in w, rows top to bottom, denoised if so set: once the view has its
        // samples, or every time at a denoise level above 1, continuing the sequence of the frame last denoised if the
        // view reused its reservoirs
        CUdeviceptr result = (CUdeviceptr)scene.accumulation;
        const bool denoise = view.settings.denoise && (done == samples || view.settings.denoise > 1);
        if (denoise) {
            for (Record& record : records) record.data = scene;
            CHECK(cuMemcpyHtoD(table, records, sizeof(records)));
            sbt.raygenRecord = table + PASSES * sizeof(Record);
            CHECK(optixLaunch(pipeline, nullptr, launch, sizeof(params), &sbt, view.width, view.height, 1));
            if (!history) { // The first of a sequence moves nowhere
                CHECK(cuMemsetD32((CUdeviceptr)scene.flow, 0, 2 * pixels));
                CHECK(cuMemsetD32((CUdeviceptr)scene.trust, 0, pixels));
            }
            const auto image = [&](CUdeviceptr data, unsigned bytes, OptixPixelFormat format) {
                return OptixImage2D{data, view.width, view.height, view.width * bytes, bytes, format}; };
            const unsigned stride = sizes.internalGuideLayerPixelSizeInBytes;
            const OptixImage2D beauty = image((CUdeviceptr)scene.mean, sizeof(float4), OPTIX_PIXEL_FORMAT_FLOAT4);
            OptixDenoiserLayer layer{.input = beauty, .previousOutput = beauty, .output = beauty,
                .type = OPTIX_DENOISER_AOV_TYPE_BEAUTY};
            layer.output.data = result = denoised;
            if (history) layer.previousOutput.data = denoised;
            const OptixDenoiserParams params{.temporalModeUsePreviousLayers = history};
            const OptixDenoiserGuideLayer guide{
                .flow = image((CUdeviceptr)scene.flow, sizeof(float2), OPTIX_PIXEL_FORMAT_FLOAT2),
                .previousOutputInternalGuideLayer = image(guides[0], stride, OPTIX_PIXEL_FORMAT_INTERNAL_GUIDE_LAYER),
                .outputInternalGuideLayer = image(guides[1], stride, OPTIX_PIXEL_FORMAT_INTERNAL_GUIDE_LAYER),
                .flowTrustworthiness = image((CUdeviceptr)scene.trust, sizeof(float), OPTIX_PIXEL_FORMAT_FLOAT1)};
            CHECK(optixDenoiserInvoke(denoiser, nullptr, &params, state, sizes.stateSizeInBytes, &guide, &layer, 1,
                0, 0, scratch, sizes.withoutOverlapScratchSizeInBytes));
            // The frame denoised is the last one now
            std::swap(guides[0], guides[1]);
            std::swap(scene.seen, scene.previousSeen);
            if (scene.previousVertices != scene.vertices) release((CUdeviceptr)scene.previousVertices);
            scene.previousVertices = scene.vertices;
            scene.denoisedCamera = scene.camera;
            history = true;
        }
        CHECK(cuMemcpyDtoH(sums, result, pixels * sizeof(float4)));
        if (denoise) for (size_t i = 0; i < pixels; ++i) sums[i] = {sums[i].x * done, sums[i].y * done,
            sums[i].z * done, float(done)};
    }
}
