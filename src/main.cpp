#include "shaders/renderer.h"
#include <optix_function_table_definition.h>
#include <optix_stack_size.h>
#include "loader.h"
#include "host.h"
#include "environment.h"
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
#include <string>
#include <fcntl.h>
#include <sys/file.h>
#include <sys/resource.h>
#include <pwd.h>
#include <spawn.h>
#include <filesystem>
#include <span>
#include <signal.h>
#include <sys/wait.h>
#ifndef VK_VERSION_1_0
#include "native.h"
#endif

// Temporal shifts queued (Vulkan); else made by restir_temporal (OptiX), whose tasked compile lets the generic module
// stand in for a scene's: !QUEUED_TEMPORAL
#ifdef VK_VERSION_1_0
constexpr bool QUEUED_TEMPORAL = true;
#else
constexpr bool QUEUED_TEMPORAL = false;
#endif
constexpr unsigned NATIVE_AFTER = 8; // Launches of the scene's steps whose calls choose its native programs

// Kinds of what the extension pipes in
enum { SCENE, REQUEST, UPDATE, STEPS };

int main(int, char** argv) { // Usage: renderer file parent < scenes, requests > an answer per request, sums in the file
#ifndef VK_VERSION_1_0
    const bool nativeHelper = argv[1] && !std::strcmp(argv[1], "native"); // NVRTC first, without a context
    if (nativeHelper)
        if (const int failed = compileNative(argv[2], argv[3][0] == '1', argv[3][1] == '1', argv[4])) return failed;
#endif
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
    OptixPipelineCompileOptions compile{ // Rays traverse instances of BVHs of triangles
        .traversableGraphFlags = OPTIX_TRAVERSABLE_GRAPH_FLAG_ALLOW_SINGLE_LEVEL_INSTANCING,
        .numPayloadValues = 7, // The triangle a ray skips, a layer and its gathering
        .pipelineLaunchParamsVariableName = "params"};
#ifndef VK_VERSION_1_0
    if (nativeHelper) { // Its module of the PTX cached, as the renderer compiles it for the op set's words given, so
        // OptiX's disk cache holds it once the helper ends
        const std::string ptx = readFile(argv[4]);
        const Params words{{std::strtoull(argv[5], nullptr, 10), std::strtoull(argv[6], nullptr, 10)}};
        const OptixModuleCompileBoundValueEntry bound{0, sizeof(words.ops), &words};
        const OptixModuleCompileOptions options{.boundValues = &bound, .numBoundValues = 1};
        OptixModule module;
        CHECK(optixModuleCreate(context, &options, &compile, ptx.data(), ptx.size(), nullptr, nullptr, &module));
        return 0;
    }
#endif
    if (!argv[1]) return 0; // Probe: whether this machine's device runs it
#ifdef VK_VERSION_1_0
    if (!std::strcmp(argv[1], "compile")) { // A helper renderer: of the op mask and SPIR-V given, the temporal round's
        helping = argv[5]; // pipelines into the file given (optixPipelineCreate)
        Params params{{std::strtoull(argv[2], nullptr, 10), std::strtoull(argv[3], nullptr, 10)}};
        const OptixModuleCompileBoundValueEntry bound{0, sizeof(params), &params};
        const OptixModuleCompileOptions options{.boundValues = &bound, .numBoundValues = 1};
        const bool extended = argv[4][0] == '1';
        OptixModule module;
        CHECK(optixModuleCreate(context, &options, nullptr, (const char*)(extended ? build_extended_ptx
            : build_shaders_ptx), extended ? build_extended_ptx_len : build_shaders_ptx_len, nullptr, nullptr,
            &module));
        OptixProgramGroup_t group{module, 0};
        const OptixProgramGroup groups[] = {&group};
        OptixPipeline pipeline;
        CHECK(optixPipelineCreate(context, nullptr, nullptr, groups, 1, nullptr, nullptr, &pipeline));
        return 0;
    }
#endif
    // Ends within 0.1 s of its parent, the extension's process
    std::thread([parent = std::atoi(argv[2])] {
        while (getppid() == parent) std::this_thread::sleep_for(std::chrono::milliseconds(100));
        std::_Exit(0);
    }).detach();
    const int shared = std::atoi(argv[1]);
    const bool tiered = !QUEUED_TEMPORAL && !argv[3]; // Headless (a third argument): awaiting the scene's own module,
    // as it has no first frame to hurry
    // Scenes keep the reuse textures; the arrays of the last one loaded
    Scene scene{.pairing = {loadPairing(PAIRING_SIZES[0]), loadPairing(PAIRING_SIZES[1]),
        loadPairing(PAIRING_SIZES[2])}};
    Loaded loaded;
    // Temporal denoiser of the means, guided by their motion
    OptixDenoiserOptions denoiserOptions{};
    OptixDenoiser denoiser;
    CHECK(optixDenoiserCreate(context, OPTIX_DENOISER_MODEL_KIND_TEMPORAL_AOV, &denoiserOptions, &denoiser));

    // Embedded PTX for the scene's steps, bound in params
    Params params{}; // Those of the module launches take
    const CUdeviceptr launch = allocate(sizeof(params));
    // Raygen programs per pass, then the triangle-skipping any-hit (rays only traversed: no miss, no closest hit)
    constexpr unsigned PASSES = std::size(PROGRAMS);
    OptixProgramGroupOptions groupOptions{};
    // Link pipeline, no recursion
    OptixPipelineLinkOptions link{.maxTraceDepth = 1};
    OptixPipeline pipeline = nullptr; // That launches take: none until then
    // A module compiled for an op set, bound in its params, with its programs and pipeline once linked
    // quick: stand-in PTX (shading not inlined) while its op set's module compiles; ptx: a native tier's, else embedded
    struct Tier {
        Params params; OptixModule module; OptixProgramGroup groups[PASSES + 4]; OptixPipeline pipeline; bool quick;
        std::string ptx;
    };
    // SBT records of scene: the anchor's (scene of the reservoirs, reprojected into by a view's first temporal pass),
    // then one per pass
    struct alignas(OPTIX_SBT_RECORD_ALIGNMENT) Record { char header[OPTIX_SBT_RECORD_HEADER_SIZE]; Scene data; };
    // then the walk's three for its hooks: the first pass's, the pass's; the shift's: the pass's, the anchor's
    Record records[PASSES + 4]{};
    Record* const walk = records + PASSES + 1;
    const CUdeviceptr table = allocate(sizeof(records));
    struct alignas(OPTIX_SBT_RECORD_ALIGNMENT) HitRecord { // The triangles', then the strands' with what their
        char header[OPTIX_SBT_RECORD_HEADER_SIZE]; const Instance* instances; const unsigned* segments; // programs read
        const float4* points;
    } hit[2]{};
    OptixShaderBindingTable sbt = {.hitgroupRecordBase = allocate(sizeof(hit)),
        .hitgroupRecordStrideInBytes = sizeof(HitRecord), .hitgroupRecordCount = 2,
        .callablesRecordBase = table + (PASSES + 1) * sizeof(Record), .callablesRecordStrideInBytes = sizeof(Record),
        .callablesRecordCount = 3};
    // OptiX's compile tasks, one worker a core, for the renderer's lifetime (never freed: workers wait on it)
    struct Workers {
        std::vector<OptixTask> tasks; std::mutex mutex; std::condition_variable changed;
        bool yielding; // The warm-up's: each task waits while a renderer awaits its own compile
    };
    Workers& workers = *new Workers{};
    // OptiX's disk cache; busy held shared while awaiting its own compile
    const std::string cache = cacheDirectory();
    const int busy = open((cache + "/flex-busy.lock").c_str(), O_CREAT | O_RDWR, 0644);
#ifndef VK_VERSION_1_0 // On Vulkan a module is compiled whole at its create, of no task
    for (unsigned k = 0; k < std::max(1u, std::thread::hardware_concurrency()); ++k) std::thread([&workers, busy] {
        std::unique_lock lock(workers.mutex);
        while (true) {
            workers.changed.wait(lock, [&] { return !workers.tasks.empty(); });
            const OptixTask task = workers.tasks.back();
            workers.tasks.pop_back();
            lock.unlock();
            while (workers.yielding && flock(busy, LOCK_EX | LOCK_NB))
                std::this_thread::sleep_for(std::chrono::milliseconds(100));
            if (workers.yielding) flock(busy, LOCK_UN);
            OptixTask more[16];
            unsigned count = 0;
            CHECK(optixTaskExecute(task, more, std::size(more), &count));
            lock.lock();
            workers.tasks.insert(workers.tasks.end(), more, more + count);
            workers.changed.notify_all();
        }
    }).detach();
#endif
    const auto begin = [&](Tier& tier) { // Its module created: its compile's first task
        const OptixModuleCompileBoundValueEntry bound{0, sizeof(tier.params.ops), &tier.params}; // Not the noise side
        const OptixModuleCompileOptions options{.boundValues = &bound, .numBoundValues = 1};
        OptixTask first;
        const bool rare = extended(tier.params);
        const unsigned char* ptx[2][2] = {{build_shaders_ptx, build_standin_ptx}, {build_extended_ptx,
            build_extended_standin_ptx}};
        const unsigned lengths[2][2] = {{build_shaders_ptx_len, build_standin_ptx_len}, {build_extended_ptx_len,
            build_extended_standin_ptx_len}};
        CHECK(optixModuleCreateWithTasks(context, &options, &compile, tier.ptx.empty()
            ? (const char*)ptx[rare][tier.quick] : tier.ptx.data(), tier.ptx.empty() ? lengths[rare][tier.quick]
            : tier.ptx.size(), nullptr, nullptr, &tier.module, &first));
        return first;
    };
    const auto compiled = [&](const Tier& tier) { // OptiX's disk cache holding it, it is so at once
        OptixModuleCompileState state;
        CHECK(optixModuleGetCompilationState(tier.module, &state));
        return state == OPTIX_MODULE_COMPILE_STATE_COMPLETED;
    };
    const auto give = [&](OptixTask task) {
        if (!task) return; // Vulkan's, none
        const std::lock_guard lock(workers.mutex);
        workers.tasks.push_back(task);
        workers.changed.notify_all();
    };
    const auto start = [&](Tier& tier) { // Its compile's first task run here: OptiX's cache holding the module, it is
        OptixTask more[16]; // compiled then, else the tasks it leaves are dropped
        unsigned count = 0;
        CHECK(optixTaskExecute(begin(tier), more, std::size(more), &count));
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
        callable.callables.entryFunctionNameDC = "__direct_callable__first";
        CHECK(optixProgramGroupCreate(context, &callable, 1, &groupOptions, nullptr, nullptr,
            &tier.groups[PASSES + 2]));
        const bool strands = tier.params.ops[CURVES >> 6] >> (CURVES & 63) & 1; // Their segments intersected as well
        skip.hitgroup.moduleIS = tier.module, skip.hitgroup.entryFunctionNameIS = "__intersection__strand";
        if (strands) CHECK(optixProgramGroupCreate(context, &skip, 1, &groupOptions, nullptr, nullptr,
            &tier.groups[PASSES + 3]));
        CHECK(optixPipelineCreate(context, &compile, &link, tier.groups, PASSES + 3 + strands, nullptr, nullptr,
            &tier.pipeline));
        OptixStackSizes sizes{}; // The walk's stack beside the passes', which OptiX's default leaves out
        for (unsigned k = 0; k < PASSES + 3 + strands; ++k)
            CHECK(optixUtilAccumulateStackSizes(tier.groups[k], &sizes, tier.pipeline));
        unsigned traversal, state, continuation;
        CHECK(optixUtilComputeStackSizes(&sizes, 1, 0, 1, &traversal, &state, &continuation));
        CHECK(optixPipelineSetStackSize(tier.pipeline, traversal, state, continuation, 2));
    };
    const auto use = [&](const Tier& tier) { // Launches take it from here on: its params and its programs' headers
        params = tier.params, params.noise = scene.noiseSize, pipeline = tier.pipeline;
        CHECK(cuMemcpyHtoD(launch, &params, sizeof(params)));
        for (unsigned pass = 0; pass < PASSES; ++pass)
            CHECK(optixSbtRecordPackHeader(tier.groups[pass], &records[pass + 1]));
        for (unsigned k = 0; k < 1 + (tier.params.ops[CURVES >> 6] >> (CURVES & 63) & 1); ++k)
            CHECK(optixSbtRecordPackHeader(tier.groups[PASSES + 3 * k], &hit[k]));
        CHECK(cuMemcpyHtoD(sbt.hitgroupRecordBase, hit, sizeof(hit)));
        for (unsigned k = 0; k < 3; ++k) CHECK(optixSbtRecordPackHeader(tier.groups[PASSES + 1 + !k], &walk[k]));
    };
    const auto drop = [&](Tier* tier) {
        if (tier->pipeline) {
            CHECK(optixPipelineDestroy(tier->pipeline));
            for (OptixProgramGroup group : tier->groups) if (group) CHECK(optixProgramGroupDestroy(group));
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
    std::future<void> linking; // The generic's link beside the scene's export, or an at once compiled module's
    if (tiered) {
        Tier* tier = new Tier{.params = {{~0ull, ~0ull}}, .quick = true};
        start(*tier);
        if (compiled(*tier))
            generic = tier, linking = std::async(std::launch::async, [&linked, tier] { linked(*tier); });
        else drop(tier);
    }
    Tier* special = nullptr; // The module of the scene's op set, launches taking it once compiled
    Tier* interim = nullptr; // Its stand-in's, standing in without a generic until it is
    // The scene's native programs: once its steps ran so many launches, those chosen by their calls are compiled by a
    // helper process, into a tier of the special's params that launches take once compiled, until the steps change
    std::vector<std::pair<CUarray, CUtexObject>> bakes; // The bakes' textures, which their readers filter through
    Tier* native = nullptr;
    pid_t helper = 0;
    std::string helping, cached; // Its directory, of the programs' source and the PTX; the PTX's in OptiX's cache
    unsigned counted = 0; // Launches since the steps changed
    bool chosen = false; // Whether their programs were chosen since, none or some
    std::vector<Tier*> retiring; // Those of earlier op sets, compiling still or awaiting their end
    // A request: up to launches more samples (at most samples), answered with launched, memory used and peak (MiB),
    // sums in the shared file. A new view persists the last (reservoirs, denoised sequence, at most reuse samples) on
    // equal size and settings, a camera within distance and cosine and, after a new scene, equal triangles; else its
    // arrays are allocated zeroed. A persisted view starts from the last restart's reservoirs, scene and camera
    struct View { unsigned width, height; Settings settings; unsigned box; Camera camera; Projection projection; }
        view{};
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
    Projection anchorProjection{};
    scene.anchorVertices = (float3*)allocate(0), scene.anchorNormals = (float3*)allocate(0);
    scene.anchorLights = (LightNode*)allocate(0), scene.anchorTrails = (unsigned long long*)allocate(0);
    // Its instances then, for a view's first temporal pass; kept over a scene of instances moved only
    Instance* anchorInstances = (Instance*)allocate(0);
    bool stale = false; // Whether the scene changed since otherwise: a new scene, steps or a mesh deformed
    // Denoiser state, scratch, denoised means, guides (last and next frame); history: guides of this sequence
    OptixDenoiserSizes sizes;
    CUdeviceptr state, scratch, denoised, guides[2];
    bool history = false;
#ifndef VK_VERSION_1_0
    CUarray noiseArray = nullptr; // The blue-noise tensor's layers, once built or read
    CUmodule noiseModule; // FlexKernels' generation of the tensor, its own kernels
    CUfunction noiseStart, noiseSweep;
    CHECK(cuModuleLoadData(&noiseModule, build_noise_ptx));
    CHECK(cuModuleGetFunction(&noiseStart, noiseModule, "noiseStart"));
    CHECK(cuModuleGetFunction(&noiseSweep, noiseModule, "noiseSweep"));
#endif
    const std::string addon = selfDirectory(); // Its shipped tensor
    // Blue-noise tensor of a side: the user's, else shipped, else generated by FlexKernels and stored; a layered
    // texture on OptiX
    const auto noised = [&](unsigned size) {
        const size_t texels = size_t(size) * size * 32, bytes = texels * sizeof(unsigned);
#ifndef VK_VERSION_1_0
        if (scene.noiseTexture) { CHECK(cuTexObjectDestroy(scene.noiseTexture)); CHECK(cuArrayDestroy(noiseArray)); }
#endif
        if (scene.noise) release((CUdeviceptr)scene.noise);
        std::vector<unsigned> ranks(texels);
        const std::string name = "/bluenoise-" + std::to_string(size) + "x" + std::to_string(size) + "x32.bin";
        const char* directory = std::getenv("FLEX_NOISE");
        bool read = false;
        for (const std::string& file : {directory ? directory + name : std::string(), addon + name})
            if (FILE* stored = !read && !file.empty() ? std::fopen(file.c_str(), "rb") : nullptr) {
                read = std::fread(ranks.data(), 1, bytes, stored) == bytes && std::fgetc(stored) == EOF;
                std::fclose(stored);
            }
        scene.noise = (unsigned*)allocate(bytes, read ? ranks.data() : nullptr), scene.noiseSize = size;
        scene.noiseTexture = 0, params.noise = size;
        CHECK(cuMemcpyHtoD(launch, &params, sizeof(params)));
        if (!read) { // White, then 64 sweeps of 8 colours' blocks, by FlexKernels' own kernels or pipelines
#ifdef VK_VERSION_1_0
            CHECK(noiseGenerate((CUdeviceptr)scene.noise, size, 64));
#else
            struct { unsigned* data; size_t count; } tensor{scene.noise, texels}; // A RWStructuredBuffer<uint>
            const unsigned blocks = size / 16 * (size / 16) * 2;
            void* start[] = {&tensor, &size};
            CHECK(cuLaunchKernel(noiseStart, unsigned((texels + 63) / 64), 1, 1, 64, 1, 1, 0, nullptr, start, nullptr));
            for (unsigned sweep = 0; sweep < 64; ++sweep) for (unsigned colour = 0; colour < 8; ++colour) {
                void* step[] = {&tensor, &size, &sweep, &colour};
                CHECK(cuLaunchKernel(noiseSweep, (blocks + 63) / 64, 1, 1, 64, 1, 1, 0, nullptr, step, nullptr));
            }
#endif
            if (directory) { // Whole or not at all, a renderer storing it at once with another
                CHECK(cuMemcpyDtoH(ranks.data(), (CUdeviceptr)scene.noise, bytes));
                const std::string file = directory + name, part = file + "." + std::to_string(getpid());
                if (FILE* storing = std::fopen(part.c_str(), "wb")) {
                    const bool whole = std::fwrite(ranks.data(), 1, bytes, storing) == bytes;
                    if (!std::fclose(storing) && whole) std::rename(part.c_str(), file.c_str());
                    else std::remove(part.c_str());
                }
            }
        }
#ifndef VK_VERSION_1_0
        // Read from here on as a layered texture: a warp's tile of pixels reads one tile of it per draw
        const CUDA_ARRAY3D_DESCRIPTOR layers{size, size, 32, CU_AD_FORMAT_UNSIGNED_INT16, 2, CUDA_ARRAY3D_LAYERED};
        CHECK(cuArray3DCreate(&noiseArray, &layers));
        CUDA_MEMCPY3D copy{.srcMemoryType = CU_MEMORYTYPE_DEVICE, .srcDevice = (CUdeviceptr)scene.noise,
            .srcPitch = size * sizeof(unsigned), .srcHeight = size, .dstMemoryType = CU_MEMORYTYPE_ARRAY,
            .dstArray = noiseArray, .WidthInBytes = size * sizeof(unsigned), .Height = size, .Depth = 32};
        CHECK(cuMemcpy3D(&copy));
        const CUDA_RESOURCE_DESC resource{.resType = CU_RESOURCE_TYPE_ARRAY, .res = {.array = {noiseArray}}};
        const CUDA_TEXTURE_DESC texture{.filterMode = CU_TR_FILTER_MODE_POINT, .flags = CU_TRSF_READ_AS_INTEGER};
        CHECK(cuTexObjectCreate(&scene.noiseTexture, &resource, &texture, nullptr));
        release((CUdeviceptr)scene.noise), scene.noise = nullptr;
#endif
    };
    const auto launchRecord = [&](unsigned pass, unsigned width, unsigned height, unsigned depth) { // Its record's
        CHECK(cuMemcpyHtoD(table + (pass + 1) * sizeof(Record), &records[pass + 1], sizeof(Record))); // data uploaded
        sbt.raygenRecord = table + (pass + 1) * sizeof(Record);
        CHECK(optixLaunch(pipeline, nullptr, launch, sizeof(params), &sbt, width, height, depth));
    };
    for (unsigned done = 0, launched, kind;; std::fflush(stdout)) {
        receive(&kind, sizeof(kind), 1);
        // Frame start (launches ended): the scene's module swapped in once compiled (= stand-in's to rounding);
        // earlier op sets' dropped once compiled
        if (special && pipeline != special->pipeline && (!native || pipeline != native->pipeline)
            && compiled(*special)) {
            linked(*special), use(*special), flock(busy, LOCK_UN);
            if (interim) drop(interim), interim = nullptr;
        }
#ifndef VK_VERSION_1_0
        const auto adopt = [&] { // The PTX cached, compiled as the special's module
            if (std::filesystem::exists(cached))
                native = new Tier{.params = special->params, .ptx = readFile(cached)}, give(begin(*native));
        };
        int status;
        if (helper && waitpid(helper, &status, WNOHANG) == helper) {
            helper = 0; // Its PTX in the cache
            if (WIFEXITED(status) && !WEXITSTATUS(status)) adopt();
        }
        if (native && pipeline == special->pipeline && compiled(*native)) linked(*native), use(*native);
        if (!chosen && counted >= NATIVE_AFTER && special && pipeline == special->pipeline) {
            chosen = true;
            std::vector<unsigned> calls(loaded.header.rows); // Chosen by their calls so far
            CHECK(cuMemcpyDtoH(calls.data(), (CUdeviceptr)scene.calls, calls.size() * sizeof(unsigned)));
            const std::vector<unsigned> programs = chooseNative(loaded.ops, calls);
            if (!programs.empty()) { // Only with programs to compile
                const bool exact = std::getenv("FLEX_NATIVE_EXACT"), rare = extended(special->params);
                const std::string text = generateNative(loaded.ops, programs, exact);
                char key[17]; // Its source's, of this build and its options
                std::snprintf(key, sizeof(key), "%016zx", std::hash<std::string>{}(text + char('0' + 2 * exact + rare)
                    + nativeBuild()));
                cached = cache + "/flex-native-" + key + ".ptx";
                char dir[] = "/tmp/flex-native-XXXXXX";
                if (std::filesystem::exists(cached)) adopt();
                else if (mkdtemp(dir)) { // Else compiled by the helper
                    helping = dir;
                    FILE* file = std::fopen((helping + "/native.cuh").c_str(), "wb");
                    std::fwrite(text.data(), 1, text.size(), file), std::fclose(file);
                    char self[] = "/proc/self/exe", mode[] = "native";
                    char options[] = {char('0' + rare), char('0' + exact), 0};
                    std::string words[2] = {std::to_string(special->params.ops[0]),
                        std::to_string(special->params.ops[1])}; // Of its op set, which its module binds
                    char* args[] = {self, mode, dir, options, cached.data(), words[0].data(), words[1].data(), nullptr};
                    if (posix_spawn(&helper, self, nullptr, nullptr, args, environ)) helper = 0;
                }
            }
        }
#endif
        std::erase_if(retiring, [&](Tier* tier) { return compiled(*tier) && (drop(tier), true); });
        if (kind != REQUEST) {
#ifndef VK_VERSION_1_0
            if (kind != UPDATE) { // New steps: native programs dropped, their helper ended, calls counted anew
                if (helper) kill(helper, SIGKILL), waitpid(helper, nullptr, 0), helper = 0,
                    std::filesystem::remove_all(helping);
                if (native && pipeline == native->pipeline) use(*special);
                if (native) retiring.push_back(std::exchange(native, nullptr));
                counted = 0, chosen = false;
            }
#endif
            const unsigned count = scene.count;
            kind == SCENE ? loadSteps(scene, loaded) : kind == UPDATE ? updateScene(context, scene, loaded)
                : updateSteps(scene, loaded);
#ifndef VK_VERSION_1_0
            if (kind != UPDATE) { // Its programs' calls, counted from none
                if (scene.calls) release((CUdeviceptr)scene.calls);
                scene.calls = (unsigned*)allocate(loaded.header.rows * sizeof(unsigned));
                CHECK(cuMemsetD32((CUdeviceptr)scene.calls, 0, loaded.header.rows));
            }
#endif
            Params next{};
            for (const Op& op : loaded.ops) next.ops[(op.code & CODE) >> 6] |= 1ull << (op.code & 63);
            const bool another = !special || std::memcmp(&next, &special->params, sizeof(next));
            Tier* last = nullptr; // The last op set's stand-in: dropped once replaced
            bool early = false; // Its module compiled at once, as Vulkan's: its pipeline linked as the rest loads
            if (another) { // Another op set: its own module, one still compiling taken back, the generic standing in
                if (special) retiring.push_back(special); // as it compiles, or without one awaited
                const auto again = std::find_if(retiring.begin(), retiring.end(),
                    [&](const Tier* tier) { return !tier->quick && tier->ptx.empty()
                        && !std::memcmp(&tier->params, &next, sizeof(next)); });
                if (again != retiring.end()) special = *again, retiring.erase(again);
                else special = new Tier{.params = next}, give(begin(*special)); // Its compile, to the workers
                last = std::exchange(interim, nullptr);
                if (tiered && !generic && !compiled(*special)) // Its module from the stand-in PTX, quicker, stands in:
                    interim = new Tier{.params = next, .quick = true}, give(begin(*interim)); // its tasks taken first
                if ((early = compiled(*special) && !special->pipeline))
                    linking = std::async(std::launch::async, [&linked, tier = special] { linked(*tier); });
            }
            if (kind == SCENE) loadScene(context, scene, loaded); // The rest of a scene, as those compile
            hit[1].instances = scene.instances, hit[1].segments = scene.segments, hit[1].points = scene.points;
            CHECK(cuMemcpyHtoD(sbt.hitgroupRecordBase, hit, sizeof(hit))); // The strands' program reads them, loaded
            if (another) {
                std::unique_lock lock(workers.mutex); // Until its first task ran, which OptiX's cache holding it
                workers.changed.wait(lock, [&] { // compiles in some 0.02 s, else in some 2 s, beside the stand-in's
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
            if (!scene.noiseSize) noised(512); // Its prepass, the first scene's: the default side, or a request's later
            for (unsigned bake : std::exchange(kind == SCENE ? loaded.bakes : loaded.rebakes, {})) { // A scene's, or
                const Op& texture = loaded.ops[bake - 1]; // those new steps run again, once: numbered by its frame,
                CHECK(cuMemsetD32((CUdeviceptr)(scene.texels + texture.texel), 0, 2 * texture.width * texture.height));
                for (unsigned pass = 0, tiles = loaded.ops[bake - 2].width; pass < (tiles ? 2 : 1); ++pass) {
                    records[PASS_BAKE + 1].data = scene; // before the lights pass: 16 x 16 texels per tile, inside
                    records[PASS_BAKE + 1].data.frame = bake | pass << 31; // their triangles, then off their edges, as
                    records[PASS_BAKE + 1].data.ops = (Op*)loaded.bakeOps // halves; the bakes' steps, numbered on
                        - loaded.header.rows;
                    launchRecord(PASS_BAKE, tiles ? 16 * tiles : texture.width, tiles ? 16 : texture.height, 1); // or,
                    // without tiles, every texel at once
                }
            }
            if (loaded.bakeOps) // Freed once baked, as nothing else reads them: those the next steps need come again
                release(loaded.bakeOps), release((CUdeviceptr)scene.bakeTexels), loaded.bakeOps = 0,
                    scene.bakeTexels = {};
#ifndef VK_VERSION_1_0
            if (kind != UPDATE) { // The bakes' texels copied into textures, their readers' ops marked to read those
                for (const auto& [array, object] : bakes) {
                    CHECK(cuTexObjectDestroy(object));
                    CHECK(cuArrayDestroy(array));
                }
                bakes.clear();
                std::map<unsigned long long, unsigned> index; // Each bake's texture by its texels' place and wrapping
                for (Op& op : std::span(loaded.ops.data(), loaded.header.rows)) {
                    if ((op.code & CODE) != BAKED) continue;
                    const unsigned width = op.width, height = op.height & 0xFFFFFF;
                    const auto [at, fresh] = index.try_emplace(op.texel * 2ull | (op.height >> 29 & 1),
                        unsigned(bakes.size()));
                    if (fresh) {
                        const CUDA_ARRAY_DESCRIPTOR array{width, height, CU_AD_FORMAT_HALF, 4};
                        auto& [texels, object] = bakes.emplace_back();
                        CHECK(cuArrayCreate(&texels, &array));
                        const CUDA_MEMCPY2D copy{.srcMemoryType = CU_MEMORYTYPE_DEVICE,
                            .srcDevice = (CUdeviceptr)(scene.texels + op.texel), .srcPitch = width * 8,
                            .dstMemoryType = CU_MEMORYTYPE_ARRAY, .dstArray = texels, .WidthInBytes = width * 8,
                            .Height = height};
                        CHECK(cuMemcpy2D(&copy));
                        const CUDA_RESOURCE_DESC resource{.resType = CU_RESOURCE_TYPE_ARRAY,
                            .res = {.array = {texels}}};
                        const auto mode = op.height >> 29 & 1 ? CU_TR_ADDRESS_MODE_WRAP : CU_TR_ADDRESS_MODE_CLAMP;
                        const CUDA_TEXTURE_DESC filtering{.addressMode = {mode, mode},
                            .filterMode = CU_TR_FILTER_MODE_LINEAR, .flags = CU_TRSF_NORMALIZED_COORDINATES};
                        CHECK(cuTexObjectCreate(&object, &resource, &filtering, nullptr));
                    }
                    op.width = at->second, op.height |= 1u << 27;
                }
                std::vector<CUtexObject> objects;
                for (const auto& bake : bakes) objects.push_back(bake.second);
                if (scene.bakeTextures) release((CUdeviceptr)scene.bakeTextures);
                scene.bakeTextures = (unsigned long long*)allocate(objects.size() * sizeof(CUtexObject),
                    objects.data());
                CHECK(cuMemcpyHtoD((CUdeviceptr)scene.ops, loaded.ops.data(), loaded.header.rows * sizeof(Op)));
            }
#endif
            std::vector<Material> materials = loaded.materials;
            if (scene.count) {
                CHECK(cuMemcpyHtoD((CUdeviceptr)scene.materials, materials.data(),
                    materials.size() * sizeof(Material)));
                records[PASS_LIGHTS + 1].data = scene;
                launchRecord(PASS_LIGHTS, scene.count, 1, 1);
                CHECK(cuMemcpyDtoH(materials.data(), (CUdeviceptr)scene.materials,
                    materials.size() * sizeof(Material)));
            }
            if (kind == SCENE && scene.environmentCdf) // The last scene's
                release((CUdeviceptr)scene.environmentCdf), scene.environmentCdf = {},
                    scene.cdfWidth = scene.cdfHeight = 0;
            if (kind != UPDATE && scene.environmentWidth) { // The world over its grid, 64 rows a launch, and its CDF
                const unsigned width = scene.environmentWidth, height = scene.environmentHeight;
                LuminanceCDF luminance{width, height};
                std::vector<float4> texels(64 * size_t(width));
                const CUdeviceptr band = allocate(texels.size() * sizeof(float4));
                for (unsigned row = 0; row < height; row += 64) {
                    const unsigned span = std::min(64u, height - row);
                    records[PASS_LIGHTS + 1].data = scene, records[PASS_LIGHTS + 1].data.bakeTexels = (float4*)band;
                    records[PASS_LIGHTS + 1].data.frame = 1u << 30 | row;
                    launchRecord(PASS_LIGHTS, width, span, 1);
                    CHECK(cuMemcpyDtoH(texels.data(), band, span * size_t(width) * sizeof(float4)));
                    luminance.add(texels.data(), row, span);
                }
                release(band);
                const std::vector<float2> cdf = luminance.finish();
                if (scene.environmentCdf) release((CUdeviceptr)scene.environmentCdf); // A request's earlier one
                scene.environmentCdf = (float2*)allocate(cdf.size() * sizeof(float2), cdf.data());
                scene.cdfWidth = luminance.w + 1, scene.cdfHeight = luminance.h;
            }
            if (scene.lights) release((CUdeviceptr)scene.lights), release((CUdeviceptr)scene.trails); // The last ones
            scene.lights = loadLights(loaded.vertices, loaded.instances, materials, scene.trails);
            view.camera = {};
            if (scene.count != count) view.width = 0;
            stale |= kind != UPDATE || std::exchange(loaded.deformed, false);
            continue;
        }
        receive(&request, sizeof(request), 1);
        if (request.view.settings.noise != scene.noiseSize) noised(request.view.settings.noise); // A size changed
        if (std::memcmp(&view, &request.view, sizeof(View))) {
            const Camera &last = anchorCamera, &next = request.view.camera;
            reused = !stale && length(next.origin - last.origin) <= request.distance
                && dot(next.z, last.z) >= request.cosine * length(next.z) * length(last.z)
                && !std::memcmp(&next.lens, &last.lens, sizeof(Lens))
                && !std::memcmp(&request.view.projection, &anchorProjection, sizeof(Projection));
            if (!reused || std::memcmp(&view, &request.view, offsetof(View, camera))) {
                reused = false;
                for (void* array : {(void*)scene.accumulation, (void*)scene.previous, (void*)scene.initial,
                    (void*)scene.temporal, (void*)scene.shifts, (void*)scene.queue, (void*)anchor})
                    release((CUdeviceptr)array);
                CHECK(munmap(sums, pixels * sizeof(float4)));
                pixels = request.view.width * request.view.height;
                reservoirs = request.view.settings.restir ? pixels : 1;
                loadView(scene, pixels, reservoirs);
                CHECK(ftruncate(shared, pixels * sizeof(float4)));
                sums = (float4*)mmap(nullptr, pixels * sizeof(float4), PROT_WRITE, MAP_SHARED, shared, 0);
                CHECK(sums == MAP_FAILED);
                anchor = (CUdeviceptr)zeros<char>(reservoirs * (sizeof(Reservoir) + sizeof(float)));
                anchorCamera = request.view.camera, anchorProjection = request.view.projection;
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
                scene.previousCamera = anchorCamera, scene.previousCameraProjection = anchorProjection;
            }
            view = request.view;
            if (scene.lensed) release((CUdeviceptr)scene.lensed); // A custom camera's throughput per pixel, none for
            // other cameras
            scene.lensed = view.projection.type == CUSTOM_CAMERA ? zeros<float3>(pixels) : nullptr;
            history = history && reused;
            done = scene.frame = 0; // Random numbers repeat per view
            scene.camera = view.camera, scene.cameraProjection = view.projection;
            scene.settings = view.settings, scene.box = view.box;
            CHECK(cuMemsetD32((CUdeviceptr)scene.accumulation, 0, 4 * pixels));
        }
        // ReSTIR frame per sample: passes over pixels x depth (depth 0 skipped), its camera the next's reprojection;
        // without ReSTIR the initial pass (duplicates only for decorrelation). Queued shifts: one launch per job slot,
        // 2 a pixel temporal, 3 spatial, 64 a bin; each round's count from an empty queue
        const unsigned restir = scene.settings.restir;
        const unsigned depths[PASSES] = {1, restir, restir, restir, restir, restir, restir, restir, restir,
            restir * scene.settings.decorrelation, 0};
        const unsigned jobs[] = {(2 * pixels + 63) / 64 * 64 + 64 * 40, (3 * pixels + 63) / 64 * 64 + 64 * 40};
        scene.width = view.width, scene.height = view.height;
        scene.anchor = (const Scene*)(table + offsetof(Record, data));
        const unsigned samples = reused ? request.reuse : request.samples;
        for (launched = 0; launched < request.launches && done < samples; ++launched, ++done, ++scene.frame) {
            for (Record& record : records) record.data = scene;
            Scene& anchored = records[0].data;
            anchored.handle = scene.anchorHandle, anchored.vertices = scene.anchorVertices;
            anchored.normals = scene.anchorNormals, anchored.lights = scene.anchorLights;
            anchored.trails = scene.anchorTrails, anchored.instances = anchorInstances;
            walk[0].data = walk[1].data = scene, walk[2].data = anchored;
            CHECK(cuMemcpyHtoD(table, records, sizeof(records)));
            // A view's later frames keep its camera and scene, where the temporal round's queue finds no job: only a
            // view's first frame launches its count, queue and queued shifts, where the round queues them
            for (unsigned pass = 0; pass < PASSES; ++pass) if (depths[pass] && (QUEUED_TEMPORAL && scene.frame == 0
                || pass < PASS_TEMPORAL_COUNT || pass > PASS_TEMPORAL_SHIFT)) {
                if (pass == PASS_TEMPORAL_COUNT || pass == PASS_COUNT)
                    CHECK(cuMemsetD32((CUdeviceptr)scene.queue, 0, QUEUE_HEADER));
                sbt.raygenRecord = table + (pass + 1) * sizeof(Record);
                const bool shifts = pass == PASS_TEMPORAL_SHIFT || pass == PASS_SHIFT;
                CHECK(optixLaunch(pipeline, nullptr, launch, sizeof(params), &sbt, shifts ? jobs[pass == PASS_SHIFT]
                    : view.width, shifts ? 1 : view.height, shifts ? 1 : depths[pass]));
            }
            scene.previousCamera = scene.camera, scene.previousCameraProjection = scene.cameraProjection;
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
                OPTIX_BUILD_OPERATION_BUILD, anchorTop, loaded);
        }
        std::fwrite(&launched, sizeof(launched), 1, stdout);
        counted += launched;
        const float memory[] = {float(memory_used) / (1024 * 1024), float(memory_peak) / (1024 * 1024)};
        std::fwrite(memory, sizeof(memory), 1, stdout);
        if (!launched) continue;
        // Raw linear sums (w: samples), rows top down; denoised at the last sample, or each time at level > 1, the
        // sequence continued if the reservoirs were reused
        CUdeviceptr result = (CUdeviceptr)scene.accumulation;
        const bool denoise = view.settings.denoise && (done == samples || view.settings.denoise > 1);
        if (denoise) {
            for (unsigned k = 0; k <= PASSES; ++k) records[k].data = scene;
            // The walk's kept as the sample left them
            CHECK(cuMemcpyHtoD(table, records, (PASSES + 1) * sizeof(Record)));
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
            scene.denoisedCamera = scene.camera, scene.denoisedCameraProjection = scene.cameraProjection;
            history = true;
        }
        CHECK(cuMemcpyDtoH(sums, result, pixels * sizeof(float4)));
        if (denoise) for (size_t i = 0; i < pixels; ++i) sums[i] = {sums[i].x * done, sums[i].y * done,
            sums[i].z * done, float(done)};
    }
}
