#include "shaders/renderer.h"
#include <optix_function_table_definition.h>
#include "loader.h"
#include <cstring>
#include <cstddef>
#include <sys/mman.h>
#include <unistd.h>
#include "../build/shaders.h"

int main(int, char** argv) { // Usage: renderer file < scene, then requests > an answer per request, sums in the file
    const int shared = std::atoi(argv[1]);
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
    // Build scene
    Scene scene = loadScene(context);
    // Unguided denoiser of the sums: the AOV model's autoexposure leaves their scale, but not alpha, the sample count
    OptixDenoiserOptions denoiserOptions{};
    OptixDenoiser denoiser;
    CHECK(optixDenoiserCreate(context, OPTIX_DENOISER_MODEL_KIND_AOV, &denoiserOptions, &denoiser));

    // Load embedded PTX
    OptixPipelineCompileOptions compile{};
    OptixModuleCompileOptions moduleOptions{};
    OptixModule module;
    CHECK(optixModuleCreate(context, &moduleOptions, &compile,
        (const char*)build_shaders_ptx, build_shaders_ptx_len, nullptr, nullptr, &module));
    // Raygen programs of a frame's passes: rays are only traversed, so none runs on a miss or a hit
    const char* passes[] = {"__raygen__initial", "__raygen__temporal", "__raygen__shift", "__raygen__spatial",
        "__raygen__duplicates"};
    constexpr unsigned PASSES = sizeof(passes) / sizeof(*passes);
    OptixProgramGroup groups[PASSES];
    OptixProgramGroupOptions groupOptions{};
    for (unsigned pass = 0; pass < PASSES; ++pass) {
        OptixProgramGroupDesc desc{.kind = OPTIX_PROGRAM_GROUP_KIND_RAYGEN, .raygen = {module, passes[pass]}};
        CHECK(optixProgramGroupCreate(context, &desc, 1, &groupOptions, nullptr, nullptr, &groups[pass]));
    }
    // Link pipeline, no recursion
    OptixPipelineLinkOptions link{.maxTraceDepth = 1};
    OptixPipeline pipeline;
    CHECK(optixPipelineCreate(context, &compile, &link, groups, PASSES, nullptr, nullptr, &pipeline));
    // An SBT record per pass carries scene
    struct alignas(OPTIX_SBT_RECORD_ALIGNMENT) Record { char header[OPTIX_SBT_RECORD_HEADER_SIZE]; Scene data; };
    Record records[PASSES];
    for (unsigned pass = 0; pass < PASSES; ++pass) CHECK(optixSbtRecordPackHeader(groups[pass], &records[pass]));
    const CUdeviceptr table = allocate(sizeof(records));
    // Each request accumulates up to launches more samples of its view, samples at most, and is answered with the
    // number launched, memory used and peak in MiB, the sums left in the shared file if any were; a new view starts
    // over, from the reservoirs of the last one if it has its size and settings
    struct View { unsigned width, height; Settings settings; Camera camera; } view{};
    struct { unsigned samples, launches; View view; } request;
    size_t pixels = 1;
    float4* sums = (float4*)mmap(nullptr, sizeof(float4), PROT_WRITE, MAP_SHARED, shared, 0);
    loadView(scene, 1); // For the first view to free like any later one's
    OptixDenoiserSizes sizes; // Of a denoised view's state and scratch, besides its denoised sums
    CUdeviceptr state, scratch, denoised;
    for (unsigned done = 0, launched; std::fread(&request, sizeof(request), 1, stdin); std::fflush(stdout)) {
        if (std::memcmp(&view, &request.view, sizeof(View))) {
            if (std::memcmp(&view, &request.view, offsetof(View, camera))) {
                for (void* array : {(void*)scene.accumulation, (void*)scene.previous, (void*)scene.initial,
                    (void*)scene.temporal, (void*)scene.duplication, (void*)scene.shifts})
                    release((CUdeviceptr)array);
                loadView(scene, request.view.width * request.view.height);
                CHECK(munmap(sums, pixels * sizeof(float4)));
                pixels = request.view.width * request.view.height;
                CHECK(ftruncate(shared, pixels * sizeof(float4)));
                sums = (float4*)mmap(nullptr, pixels * sizeof(float4), PROT_WRITE, MAP_SHARED, shared, 0);
                CHECK(sums == MAP_FAILED);
                if (view.settings.denoise) for (CUdeviceptr array : {state, scratch, denoised}) release(array);
                if (request.view.settings.denoise) {
                    const unsigned width = request.view.width, height = request.view.height;
                    CHECK(optixDenoiserComputeMemoryResources(denoiser, width, height, &sizes));
                    state = allocate(sizes.stateSizeInBytes);
                    scratch = allocate(sizes.withoutOverlapScratchSizeInBytes);
                    denoised = allocate(pixels * sizeof(float4));
                    CHECK(optixDenoiserSetup(denoiser, nullptr, width, height, state, sizes.stateSizeInBytes, scratch,
                        sizes.withoutOverlapScratchSizeInBytes));
                }
            }
            view = request.view;
            done = 0;
            scene.camera = view.camera;
            scene.settings = view.settings;
            CHECK(cuMemsetD32((CUdeviceptr)scene.accumulation, 0, 4 * pixels));
        }
        // A ReSTIR frame per sample: its passes in order over the pixels times their depth, none of depth 0, then its
        // camera is the one the next frame reprojects from. Without ReSTIR only the initial pass runs, the duplication
        // map only for decorrelation.
        const unsigned restir = scene.settings.restir;
        const unsigned depths[PASSES] = {1, restir, restir * scene.settings.neighbors, restir,
            restir * scene.settings.decorrelation};
        for (launched = 0; launched < request.launches && done < request.samples; ++launched, ++done, ++scene.frame) {
            for (Record& record : records) record.data = scene;
            CHECK(cuMemcpyHtoD(table, records, sizeof(records)));
            for (unsigned pass = 0; pass < PASSES; ++pass) if (depths[pass]) {
                OptixShaderBindingTable sbt = {.raygenRecord = table + pass * sizeof(Record)};
                CHECK(optixLaunch(pipeline, nullptr, 0, 0, &sbt, view.width, view.height, depths[pass]));
            }
            scene.previousCamera = scene.camera;
        }
        std::fwrite(&launched, sizeof(launched), 1, stdout);
        const float memory[] = {float(memory_used) / (1024 * 1024), float(memory_peak) / (1024 * 1024)};
        std::fwrite(memory, sizeof(memory), 1, stdout);
        if (!launched) continue;
        // Raw linear sums with the sample count in w, rows top to bottom, denoised if so set
        CUdeviceptr result = (CUdeviceptr)scene.accumulation;
        if (view.settings.denoise) {
            const OptixImage2D image{result, view.width, view.height, view.width * unsigned(sizeof(float4)),
                sizeof(float4), OPTIX_PIXEL_FORMAT_FLOAT4};
            OptixDenoiserLayer layer{.input = image, .output = image};
            layer.output.data = result = denoised;
            const OptixDenoiserParams params{};
            const OptixDenoiserGuideLayer guide{};
            CHECK(optixDenoiserInvoke(denoiser, nullptr, &params, state, sizes.stateSizeInBytes, &guide, &layer, 1, 0,
                0, scratch, sizes.withoutOverlapScratchSizeInBytes));
        }
        CHECK(cuMemcpyDtoH(sums, result, pixels * sizeof(float4)));
        if (view.settings.denoise) for (size_t i = 0; i < pixels; ++i) sums[i].w = done;
    }
}
