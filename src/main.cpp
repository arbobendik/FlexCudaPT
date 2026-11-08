#include "shaders/renderer.h"
#include <optix_function_table_definition.h>
#include <optix_stack_size.h>
#include "loader.h"
#include <cstring>
#include <cstddef>
#include <utility>
#include <thread>
#include <future>
#include <mutex>
#include <condition_variable>
#include <vector>
#include <algorithm>
#include <chrono>
#include <sys/mman.h>
#include <unistd.h>
#include "shaders.h"
#include <algorithm>
#include <string>
#include <fcntl.h>
#include <sys/file.h>
#include <sys/resource.h>
#include <pwd.h>

// Whether a scene's module, while it compiles, has the generic one stand in: OptiX's compile runs as tasks beside
// frames; Vulkan compiles a pipeline whole, at once, so there each scene takes its own as before
#ifdef VK_VERSION_1_0
constexpr bool TIERED = false;
#else
constexpr bool TIERED = true;
#endif

// Kinds of what the extension pipes in
enum { SCENE, REQUEST, UPDATE, STEPS };

int main(int, char** argv) { // Usage: renderer file parent < scenes, requests > an answer per request, sums in the file
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
    // Once the extension's process, its parent, is gone, closed, crashed or killed, the renderer ends with it within a
    // tenth of a second, whatever it is doing
    std::thread([parent = std::atoi(argv[2])] {
        while (getppid() == parent) std::this_thread::sleep_for(std::chrono::milliseconds(100));
        std::_Exit(0);
    }).detach();
    // Scenes come through a pipe of 1 MiB, the most Linux grants unprivileged by default, which reads their gigabytes
    // some four times as fast as its 64 KiB default
    fcntl(0, F_SETPIPE_SZ, 1 << 20);
    const int shared = std::atoi(argv[1]);
    const bool tiered = TIERED && !argv[3]; // Headless (a third argument): awaiting the scene's own module, as it
    // has no first frame to hurry
    // Scenes keep the reuse textures; the arrays of the last one loaded
    Scene scene{.pairing = {loadPairing(PAIRING_SIZES[0]), loadPairing(PAIRING_SIZES[1]),
        loadPairing(PAIRING_SIZES[2])}};
    Loaded loaded;
    // Temporal denoiser of the means, guided by their motion
    OptixDenoiserOptions denoiserOptions{};
    OptixDenoiser denoiser;
    CHECK(optixDenoiserCreate(context, OPTIX_DENOISER_MODEL_KIND_TEMPORAL_AOV, &denoiserOptions, &denoiser));

    // Embedded PTX compiled for the steps the scene's programs take, bound in params, once the first scene's arrive
    OptixPipelineCompileOptions compile{ // Rays traverse instances of BVHs of triangles
        .traversableGraphFlags = OPTIX_TRAVERSABLE_GRAPH_FLAG_ALLOW_SINGLE_LEVEL_INSTANCING,
        .numPayloadValues = 7, // The triangle a ray skips, a layer and its gathering
        .pipelineLaunchParamsVariableName = "params"};
    Params params{}; // Those of the module launches take
    const CUdeviceptr launch = allocate(sizeof(params));
    // Raygen programs of a frame's passes, then the any-hit program skipping a triangle: rays are only traversed, so
    // none runs on a miss or a closest hit
    constexpr unsigned PASSES = std::size(PROGRAMS);
    OptixProgramGroupOptions groupOptions{};
    // Link pipeline, no recursion
    OptixPipelineLinkOptions link{.maxTraceDepth = 1};
    OptixPipeline pipeline = nullptr; // That launches take: none until then
    // A module compiled for an op set, bound in its params, with its programs and pipeline once linked
    // quick: from the stand-in PTX, its shading not inlined, quicker to compile, to stand in while the module of its
    // op set compiles
    struct Tier {
        Params params; OptixModule module; OptixProgramGroup groups[PASSES + 2]; OptixPipeline pipeline; bool quick;
    };
    // SBT records carrying scene: first the anchor's, scene in the BVH, triangles and lights its reservoirs were last
    // traced in, which a view's first temporal pass reprojects into, then one per pass
    struct alignas(OPTIX_SBT_RECORD_ALIGNMENT) Record { char header[OPTIX_SBT_RECORD_HEADER_SIZE]; Scene data; };
    static_assert(sizeof(Record) == RECORD_STRIDE, "The shaders step back to the anchor's record by RECORD_STRIDE");
    Record records[PASSES + 1]{};
    const CUdeviceptr table = allocate(sizeof(records));
    struct alignas(OPTIX_SBT_RECORD_ALIGNMENT) HitRecord { char header[OPTIX_SBT_RECORD_HEADER_SIZE]; } hit;
    HitRecord walk; // The stand-in's walk
    OptixShaderBindingTable sbt = {.hitgroupRecordBase = allocate(sizeof(hit)),
        .hitgroupRecordStrideInBytes = sizeof(hit), .hitgroupRecordCount = 1, .callablesRecordBase = allocate(sizeof(walk)),
        .callablesRecordStrideInBytes = sizeof(walk), .callablesRecordCount = 1};
    // OptiX's compile tasks, taken by a worker on every core while any is given: the renderer's for its lifetime, never
    // freed, as its workers wait on it to the end
    struct Workers {
        std::vector<OptixTask> tasks; std::mutex mutex; std::condition_variable changed; unsigned running;
        bool yielding; // The warm-up's: each task waits while a renderer awaits its own compile
    };
    Workers& workers = *new Workers{};
    // OptiX's disk cache, by the user's name, where a renderer awaiting its own compile holds busy shared
    const char* cacheDirectory = std::getenv("OPTIX_CACHE_PATH");
    const std::string cache = cacheDirectory ? std::string(cacheDirectory)
        : "/var/tmp/OptixCache_" + std::string(getpwuid(getuid())->pw_name);
    const int busy = open((cache + "/flex-busy.lock").c_str(), O_CREAT | O_RDWR, 0644);
    for (unsigned k = 0; k < std::max(1u, std::thread::hardware_concurrency()); ++k) std::thread([&workers, busy] {
        std::unique_lock lock(workers.mutex);
        while (true) {
            workers.changed.wait(lock, [&] { return !workers.tasks.empty(); });
            const OptixTask task = workers.tasks.back();
            workers.tasks.pop_back();
            ++workers.running;
            lock.unlock();
            while (workers.yielding && flock(busy, LOCK_EX | LOCK_NB))
                std::this_thread::sleep_for(std::chrono::milliseconds(100));
            if (workers.yielding) flock(busy, LOCK_UN);
            OptixTask more[16];
            unsigned count = 0;
            CHECK(optixTaskExecute(task, more, std::size(more), &count));
            lock.lock();
            workers.tasks.insert(workers.tasks.end(), more, more + count);
            --workers.running;
            workers.changed.notify_all();
        }
    }).detach();
    const auto begin = [&](Tier& tier) { // Its module created: its compile's first task
        const OptixModuleCompileBoundValueEntry bound{0, sizeof(tier.params), &tier.params};
        const OptixModuleCompileOptions options{.boundValues = &bound, .numBoundValues = 1};
        OptixTask first;
        const bool rare = tier.params.ops[MEDIUM >> 6] >> (MEDIUM & 63) & 1; // Varying media: the extended PTX alone
        const unsigned char* ptx[2][2] = {{build_shaders_ptx, build_standin_ptx}, {build_extended_ptx,
            build_extended_standin_ptx}};
        const unsigned lengths[2][2] = {{build_shaders_ptx_len, build_standin_ptx_len}, {build_extended_ptx_len,
            build_extended_standin_ptx_len}};
        CHECK(optixModuleCreateWithTasks(context, &options, &compile, (const char*)ptx[rare][tier.quick],
            lengths[rare][tier.quick], nullptr, nullptr, &tier.module, &first));
        return first;
    };
    const auto compiled = [&](const Tier& tier) { // OptiX's disk cache holding it, it is so at once
        OptixModuleCompileState state;
        CHECK(optixModuleGetCompilationState(tier.module, &state));
        return state == OPTIX_MODULE_COMPILE_STATE_COMPLETED;
    };
    const auto give = [&](OptixTask task) {
        const std::lock_guard lock(workers.mutex);
        workers.tasks.push_back(task);
        workers.changed.notify_all();
    };
    const auto start = [&](Tier& tier) { // Its compile's first task run here: OptiX's cache holding the module, it is
        OptixTask more[16]; // compiled then (in some 0.02 s), else the tasks it leaves follow
        unsigned count = 0;
        CHECK(optixTaskExecute(begin(tier), more, std::size(more), &count));
        return std::vector<OptixTask>(more, more + count);
    };
    const auto finish = [&](const Tier& tier) {
        std::unique_lock lock(workers.mutex);
        workers.changed.wait(lock, [&] { return compiled(tier); });
    };
    const auto linked = [&](Tier& tier) { // Its programs and pipeline
        for (unsigned pass = 0; pass < PASSES; ++pass) {
            OptixProgramGroupDesc desc{.kind = OPTIX_PROGRAM_GROUP_KIND_RAYGEN,
                .raygen = {tier.module, PROGRAMS[pass]}};
            CHECK(optixProgramGroupCreate(context, &desc, 1, &groupOptions, nullptr, nullptr, &tier.groups[pass]));
        }
        OptixProgramGroupDesc skip{.kind = OPTIX_PROGRAM_GROUP_KIND_HITGROUP,
            .hitgroup = {.moduleAH = tier.module, .entryFunctionNameAH = "__anyhit__skip"}};
        CHECK(optixProgramGroupCreate(context, &skip, 1, &groupOptions, nullptr, nullptr, &tier.groups[PASSES]));
        OptixProgramGroupDesc callable{.kind = OPTIX_PROGRAM_GROUP_KIND_CALLABLES,
            .callables = {.moduleDC = tier.module, .entryFunctionNameDC = "__direct_callable__walk"}};
        CHECK(optixProgramGroupCreate(context, &callable, 1, &groupOptions, nullptr, nullptr,
            &tier.groups[PASSES + 1]));
        CHECK(optixPipelineCreate(context, &compile, &link, tier.groups, PASSES + 2, nullptr, nullptr, &tier.pipeline));
        OptixStackSizes sizes{}; // The walk's stack beside the passes', which OptiX's default leaves out
        for (OptixProgramGroup group : tier.groups) CHECK(optixUtilAccumulateStackSizes(group, &sizes, tier.pipeline));
        unsigned traversal, state, continuation;
        CHECK(optixUtilComputeStackSizes(&sizes, 1, 0, 1, &traversal, &state, &continuation));
        CHECK(optixPipelineSetStackSize(tier.pipeline, traversal, state, continuation, 2));
    };
    const auto use = [&](const Tier& tier) { // Launches take it from here on: its params and its programs' headers
        params = tier.params, pipeline = tier.pipeline;
        CHECK(cuMemcpyHtoD(launch, &params, sizeof(params)));
        for (unsigned pass = 0; pass < PASSES; ++pass)
            CHECK(optixSbtRecordPackHeader(tier.groups[pass], &records[pass + 1]));
        CHECK(optixSbtRecordPackHeader(tier.groups[PASSES], &hit));
        CHECK(cuMemcpyHtoD(sbt.hitgroupRecordBase, &hit, sizeof(hit)));
        CHECK(optixSbtRecordPackHeader(tier.groups[PASSES + 1], &walk));
        CHECK(cuMemcpyHtoD(sbt.callablesRecordBase, &walk, sizeof(walk)));
    };
    const auto drop = [&](Tier* tier) {
        if (tier->pipeline) {
            CHECK(optixPipelineDestroy(tier->pipeline));
            for (OptixProgramGroup group : tier->groups) CHECK(optixProgramGroupDestroy(group));
        }
        CHECK(optixModuleDestroy(tier->module));
        delete tier;
    };
    // The generic module, every op compiled in: bound to no scene, compiled once per release by the warm-up Blender
    // starts, then found in OptiX's disk cache. Taken only if found there: this renderer compiles none of it
    if (!std::strcmp(argv[1], "warm")) { // Blender's warm-up, at its start: the generic module into OptiX's disk cache,
        // at the lowest priority, by one warm-up at a time, none if it is there already, yielding to renderers
        if (flock(open((cache + "/flex-warm.lock").c_str(), O_CREAT | O_RDWR, 0644), LOCK_EX | LOCK_NB)) return 0;
        CHECK(setpriority(PRIO_PROCESS, 0, 19));
        workers.yielding = true;
        Tier tier{.params = {{~0ull, ~0ull}}, .quick = true};
        const OptixTask first = begin(tier);
        if (!compiled(tier)) give(first), finish(tier);
        return 0;
    }
    flock(busy, LOCK_SH); // From its start to its own compile: the warm-up yields
    Tier* generic = nullptr;
    std::future<void> linking; // The generic's programs and pipeline, linked beside the scene's export, or a module's
    // compiled at once, beside its scene's load
    if (tiered) {
        Tier* tier = new Tier{.params = {{~0ull, ~0ull}}, .quick = true};
        start(*tier);
        if (compiled(*tier))
            generic = tier, linking = std::async(std::launch::async, [&linked, tier] { linked(*tier); });
        else drop(tier);
    }
    Tier* special = nullptr; // The module of the scene's op set, launches taking it once compiled
    Tier* interim = nullptr; // Its stand-in's, standing in without a generic until it is
    std::vector<Tier*> retiring; // Those of earlier op sets, compiling still or awaiting their end
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
    size_t pixels = 1, reservoirs = 1; // The view's pixels, and of them those with reservoirs: one without ReSTIR
    float4* sums = (float4*)mmap(nullptr, sizeof(float4), PROT_WRITE, MAP_SHARED, shared, 0);
    loadView(scene, 1, 1); // For the first view to free like any later one's
    scene.vertices = scene.previousVertices = (float3*)allocate(0); // For the first scene to keep or free
    // The reservoirs the last view starting over ended with and their duplication, its camera and the BVHs of the
    // meshes of the scene it was traced in and over its instances
    CUdeviceptr anchor = allocate(0), anchorTop = allocate(0);
    std::map<unsigned, Mesh> anchorMeshes;
    Camera anchorCamera{};
    scene.anchorVertices = (float3*)allocate(0), scene.anchorNormals = (float3*)allocate(0);
    scene.anchorLights = (LightNode*)allocate(0), scene.anchorTrails = (unsigned long long*)allocate(0);
    // Its instances as then, which a view's first temporal pass reads: a scene since only of instances moved keeps it
    Instance* anchorInstances = (Instance*)allocate(0);
    bool stale = false; // Whether the scene changed since otherwise: a new scene, steps or a mesh deformed
    // Of a denoised view's state and scratch, besides its denoised means and the internal guides of the frame last
    // denoised and the next; whether those hold one of its sequence
    OptixDenoiserSizes sizes;
    CUdeviceptr state, scratch, denoised, guides[2];
    bool history = false;
    for (unsigned done = 0, launched, kind; receive(&kind, sizeof(kind), 1); std::fflush(stdout)) {
        // At a frame's start, every launch before it ended: the scene's module swapped in once compiled, its renders
        // a stand-in's to rounding; those of earlier op sets dropped once compiled
        if (special && pipeline != special->pipeline && compiled(*special)) {
            linked(*special), use(*special), flock(busy, LOCK_UN);
            if (interim) drop(interim), interim = nullptr;
        }
        std::erase_if(retiring, [&](Tier* tier) { return compiled(*tier) && (drop(tier), true); });
        if (kind != REQUEST) {
            const unsigned count = scene.count;
            kind == SCENE ? loadSteps(scene, loaded) : kind == UPDATE ? updateScene(context, scene, loaded)
                : updateSteps(scene, loaded);
            Params next{};
            for (const Op& op : loaded.ops) next.ops[op.code >> 6] |= 1ull << (op.code & 63);
            const bool another = !special || std::memcmp(&next, &special->params, sizeof(next));
            Tier* last = nullptr; // The last op set's stand-in: dropped once replaced
            bool early = false; // Its module compiled at once, as Vulkan's: its pipeline linked as the rest loads
            if (another) { // Another op set: its own module, one still compiling taken back, the generic standing in
                if (special) retiring.push_back(special); // as it compiles, or without one awaited
                const auto again = std::find_if(retiring.begin(), retiring.end(),
                    [&](const Tier* tier) { return !tier->quick && !std::memcmp(&tier->params, &next, sizeof(next)); });
                if (again != retiring.end()) special = *again, retiring.erase(again);
                else special = new Tier{.params = next}, give(begin(*special)); // Its compile, to the workers
                last = std::exchange(interim, nullptr);
                if (tiered && !generic && !compiled(*special)) // Its module from the stand-in PTX, quicker, stands in:
                    interim = new Tier{.params = next, .quick = true}, give(begin(*interim)); // its tasks taken first
                if ((early = compiled(*special) && !special->pipeline))
                    linking = std::async(std::launch::async, [&linked, tier = special] { linked(*tier); });
            }
            if (kind == SCENE) loadScene(context, scene, loaded); // The rest of a scene, as those compile
            if (another) {
                std::unique_lock lock(workers.mutex); // Until its first task ran, which OptiX's cache holding it compiles
                workers.changed.wait(lock, [&] { // in some 0.02 s, else in some 2 s, beside the stand-in's
                    OptixModuleCompileState state;
                    CHECK(optixModuleGetCompilationState(special->module, &state));
                    return state != OPTIX_MODULE_COMPILE_STATE_NOT_STARTED;
                });
                lock.unlock();
                if (interim && compiled(*special)) retiring.push_back(std::exchange(interim, nullptr)); // Not needed
                if (interim) finish(*interim), linked(*interim);
                if (!generic && !interim) finish(*special);
                if (early || (!compiled(*special) && generic)) linking.wait(); // Linked early, or standing in
                if (compiled(*special) && !special->pipeline) linked(*special);
                use(compiled(*special) ? *special : interim ? *interim : *generic);
                if (last) drop(last);
                flock(busy, compiled(*special) ? LOCK_UN : LOCK_SH); // Awaiting its own: the warm-up yields
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
            LightNode* const lights = loadLights(loaded.vertices, loaded.instances, materials, trails);
            std::replace(loaded.arrays.begin(), loaded.arrays.end(), (CUdeviceptr)scene.lights, (CUdeviceptr)lights);
            std::replace(loaded.arrays.begin(), loaded.arrays.end(), (CUdeviceptr)scene.trails, (CUdeviceptr)trails);
            release((CUdeviceptr)scene.lights), release((CUdeviceptr)scene.trails);
            scene.lights = lights, scene.trails = trails;
            view.camera = {};
            if (scene.count != count) view.width = 0;
            stale |= kind != UPDATE || std::exchange(loaded.deformed, false);
            continue;
        }
        receive(&request, sizeof(request), 1);
        if (std::memcmp(&view, &request.view, sizeof(View))) {
            const Camera &last = anchorCamera, &next = request.view.camera;
            reused = !stale && length(next.origin - last.origin) <= request.distance
                && dot(next.z, last.z) >= request.cosine * length(next.z) * length(last.z)
                && !std::memcmp(&next.lens, &last.lens, sizeof(Lens));
            if (!reused || std::memcmp(&view, &request.view, offsetof(View, camera))) {
                reused = false;
                for (void* array : {(void*)scene.accumulation, (void*)scene.previous, (void*)scene.initial,
                    (void*)scene.temporal, (void*)scene.shifts, (void*)anchor})
                    release((CUdeviceptr)array);
                CHECK(munmap(sums, pixels * sizeof(float4)));
                pixels = request.view.width * request.view.height;
                reservoirs = request.view.settings.restir ? pixels : 1;
                loadView(scene, pixels, reservoirs);
                CHECK(ftruncate(shared, pixels * sizeof(float4)));
                sums = (float4*)mmap(nullptr, pixels * sizeof(float4), PROT_WRITE, MAP_SHARED, shared, 0);
                CHECK(sums == MAP_FAILED);
                anchor = (CUdeviceptr)zeros<char>(reservoirs * (sizeof(Reservoir) + sizeof(float)));
                anchorCamera = request.view.camera;
                if (!request.view.settings.restir) { // Without ReSTIR no anchor's scene, as before the first view
                    for (CUdeviceptr array : {(CUdeviceptr)scene.anchorVertices, (CUdeviceptr)scene.anchorNormals,
                        (CUdeviceptr)scene.anchorLights, (CUdeviceptr)scene.anchorTrails, anchorTop,
                        (CUdeviceptr)anchorInstances}) release(array);
                    for (auto& [first, mesh] : std::exchange(anchorMeshes, {}))
                        release(mesh.temp), release(mesh.output);
                    scene.anchorVertices = (float3*)allocate(0), scene.anchorNormals = (float3*)allocate(0);
                    scene.anchorLights = (LightNode*)allocate(0), scene.anchorTrails = (unsigned long long*)allocate(0);
                    anchorTop = allocate(0), scene.anchorHandle = 0, anchorInstances = (Instance*)allocate(0);
                }
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
                CHECK(cuMemcpyDtoD((CUdeviceptr)scene.previous, anchor,
                    reservoirs * (sizeof(Reservoir) + sizeof(float))));
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
            anchored.trails = scene.anchorTrails, anchored.instances = anchorInstances;
            CHECK(cuMemcpyHtoD(table, records, sizeof(records)));
            for (unsigned pass = 0; pass < PASSES; ++pass) if (depths[pass]) {
                sbt.raygenRecord = table + (pass + 1) * sizeof(Record);
                CHECK(optixLaunch(pipeline, nullptr, launch, sizeof(params), &sbt, view.width, view.height, depths[pass]));
            }
            scene.previousCamera = scene.camera;
        }
        if (!reused && launched && done == samples && view.settings.restir) {
            CHECK(cuMemcpyDtoD(anchor, (CUdeviceptr)scene.previous, pixels * (sizeof(Reservoir) + sizeof(float))));
            for (CUdeviceptr array : {(CUdeviceptr)scene.anchorVertices, (CUdeviceptr)scene.anchorNormals,
                (CUdeviceptr)scene.anchorLights, (CUdeviceptr)scene.anchorTrails, (CUdeviceptr)anchorInstances})
                release(array);
            anchorInstances = (Instance*)copy((CUdeviceptr)scene.instances), stale = false;
            scene.anchorVertices = (float3*)copy((CUdeviceptr)scene.vertices);
            scene.anchorNormals = (float3*)copy((CUdeviceptr)scene.normals);
            scene.anchorLights = (LightNode*)copy((CUdeviceptr)scene.lights);
            scene.anchorTrails = (unsigned long long*)copy((CUdeviceptr)scene.trails);
            scene.anchorHandle = buildScene(context, scene.anchorVertices, loaded.instances, anchorMeshes,
                OPTIX_BUILD_OPERATION_BUILD, anchorTop);
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
