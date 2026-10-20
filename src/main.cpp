#include "shaders/renderer.h"
#include <optix_function_table_definition.h>
#include "loader.h"
#include <cstring>
#include <cstddef>
#include <sys/mman.h>
#include <unistd.h>
#include "shaders.h"

// Kinds of what the extension pipes in
enum { SCENE, REQUEST, UPDATE };

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

    // Load embedded PTX
    OptixPipelineCompileOptions compile{.numPayloadValues = 1}; // The triangle a ray skips
    OptixModuleCompileOptions moduleOptions{};
    OptixModule module;
    CHECK(optixModuleCreate(context, &moduleOptions, &compile,
        (const char*)build_shaders_ptx, build_shaders_ptx_len, nullptr, nullptr, &module));
    // Raygen programs of a frame's passes, then the any-hit program skipping a triangle: rays are only traversed, so
    // none runs on a miss or a closest hit
    const char* passes[] = {"__raygen__initial", "__raygen__temporal", "__raygen__shift", "__raygen__spatial",
        "__raygen__duplicates", "__raygen__lights", "__raygen__denoise"};
    constexpr unsigned PASSES = sizeof(passes) / sizeof(*passes);
    OptixProgramGroup groups[PASSES + 1];
    OptixProgramGroupOptions groupOptions{};
    for (unsigned pass = 0; pass < PASSES; ++pass) {
        OptixProgramGroupDesc desc{.kind = OPTIX_PROGRAM_GROUP_KIND_RAYGEN, .raygen = {module, passes[pass]}};
        CHECK(optixProgramGroupCreate(context, &desc, 1, &groupOptions, nullptr, nullptr, &groups[pass]));
    }
    OptixProgramGroupDesc skip{.kind = OPTIX_PROGRAM_GROUP_KIND_HITGROUP,
        .hitgroup = {.moduleAH = module, .entryFunctionNameAH = "__anyhit__skip"}};
    CHECK(optixProgramGroupCreate(context, &skip, 1, &groupOptions, nullptr, nullptr, &groups[PASSES]));
    // Link pipeline, no recursion
    OptixPipelineLinkOptions link{.maxTraceDepth = 1};
    OptixPipeline pipeline;
    CHECK(optixPipelineCreate(context, &compile, &link, groups, PASSES + 1, nullptr, nullptr, &pipeline));
    // An SBT record per pass carries scene
    struct alignas(OPTIX_SBT_RECORD_ALIGNMENT) Record { char header[OPTIX_SBT_RECORD_HEADER_SIZE]; Scene data; };
    Record records[PASSES];
    for (unsigned pass = 0; pass < PASSES; ++pass) CHECK(optixSbtRecordPackHeader(groups[pass], &records[pass]));
    const CUdeviceptr table = allocate(sizeof(records));
    struct alignas(OPTIX_SBT_RECORD_ALIGNMENT) HitRecord { char header[OPTIX_SBT_RECORD_HEADER_SIZE]; } hit;
    CHECK(optixSbtRecordPackHeader(groups[PASSES], &hit));
    OptixShaderBindingTable sbt = {.hitgroupRecordBase = allocate(sizeof(hit), &hit),
        .hitgroupRecordStrideInBytes = sizeof(hit), .hitgroupRecordCount = 1};
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
            kind == SCENE ? loadScene(context, scene, loaded) : updateScene(context, scene, loaded);
            std::vector<Material> materials = loaded.materials;
            if (scene.count) {
                CHECK(cuMemcpyHtoD((CUdeviceptr)scene.materials, materials.data(), materials.size() * sizeof(Material)));
                records[PASSES - 2].data = scene;
                CHECK(cuMemcpyHtoD(table + (PASSES - 2) * sizeof(Record), &records[PASSES - 2], sizeof(Record)));
                const OptixShaderBindingTable sbt = {.raygenRecord = table + (PASSES - 2) * sizeof(Record)};
                CHECK(optixLaunch(pipeline, nullptr, 0, 0, &sbt, scene.count, 1, 1));
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
                    (void*)scene.temporal, (void*)scene.duplication, (void*)scene.shifts, (void*)anchor})
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
                CHECK(cuMemcpyDtoD((CUdeviceptr)scene.previous, anchor, pixels * sizeof(Reservoir)));
                CHECK(cuMemcpyDtoD((CUdeviceptr)scene.duplication, anchor + pixels * sizeof(Reservoir),
                    pixels * sizeof(float)));
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
            CHECK(cuMemcpyHtoD(table, records, sizeof(records)));
            for (unsigned pass = 0; pass < PASSES; ++pass) if (depths[pass]) {
                sbt.raygenRecord = table + pass * sizeof(Record);
                CHECK(optixLaunch(pipeline, nullptr, 0, 0, &sbt, view.width, view.height, depths[pass]));
            }
            scene.previousCamera = scene.camera;
        }
        if (!reused && launched && done == samples) {
            CHECK(cuMemcpyDtoD(anchor, (CUdeviceptr)scene.previous, pixels * sizeof(Reservoir)));
            CHECK(cuMemcpyDtoD(anchor + pixels * sizeof(Reservoir), (CUdeviceptr)scene.duplication,
                pixels * sizeof(float)));
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
            sbt.raygenRecord = table + (PASSES - 1) * sizeof(Record);
            CHECK(optixLaunch(pipeline, nullptr, 0, 0, &sbt, view.width, view.height, 1));
            if (!history) { // The first of a sequence moves nowhere
                CHECK(cuMemsetD32((CUdeviceptr)scene.flow, 0, 2 * pixels));
                CHECK(cuMemsetD32((CUdeviceptr)scene.trust, 0, pixels));
            }
            const unsigned width = view.width, height = view.height, stride = sizes.internalGuideLayerPixelSizeInBytes;
            const OptixImage2D image{(CUdeviceptr)scene.mean, width, height, width * unsigned(sizeof(float4)),
                sizeof(float4), OPTIX_PIXEL_FORMAT_FLOAT4};
            OptixDenoiserLayer layer{.input = image, .previousOutput = image, .output = image,
                .type = OPTIX_DENOISER_AOV_TYPE_BEAUTY};
            layer.output.data = result = denoised;
            if (history) layer.previousOutput.data = denoised;
            const OptixDenoiserParams params{.temporalModeUsePreviousLayers = history};
            const OptixDenoiserGuideLayer guide{
                .flow = {(CUdeviceptr)scene.flow, width, height, width * unsigned(sizeof(float2)), sizeof(float2),
                    OPTIX_PIXEL_FORMAT_FLOAT2},
                .previousOutputInternalGuideLayer = {guides[0], width, height, width * stride, stride,
                    OPTIX_PIXEL_FORMAT_INTERNAL_GUIDE_LAYER},
                .outputInternalGuideLayer = {guides[1], width, height, width * stride, stride,
                    OPTIX_PIXEL_FORMAT_INTERNAL_GUIDE_LAYER},
                .flowTrustworthiness = {(CUdeviceptr)scene.trust, width, height, width * unsigned(sizeof(float)),
                    sizeof(float), OPTIX_PIXEL_FORMAT_FLOAT1}};
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
