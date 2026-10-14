#include "shaders/renderer.h"
#include <optix_function_table_definition.h>
#include "loader.h"
#include <cstring>
#include <cstddef>
#include "../build/shaders.h"

int main() { // Usage: renderer < scene, then requests > an answer per request
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
    // number launched, followed by the sums if any were; a new view starts over, from the reservoirs of the last one if
    // it has its size and settings
    struct View { unsigned width, height; Settings settings; Camera camera; } view{};
    struct { unsigned samples, launches; View view; } request;
    std::vector<float4> sums;
    loadView(scene, 1); // For the first view to free like any later one's
    for (unsigned done = 0, launched; std::fread(&request, sizeof(request), 1, stdin); std::fflush(stdout)) {
        if (std::memcmp(&view, &request.view, sizeof(View))) {
            if (std::memcmp(&view, &request.view, offsetof(View, camera))) {
                for (void* array : {(void*)scene.accumulation, (void*)scene.previous, (void*)scene.initial,
                    (void*)scene.temporal, (void*)scene.duplication, (void*)scene.shifts})
                    CHECK(cuMemFree((CUdeviceptr)array));
                loadView(scene, request.view.width * request.view.height);
            }
            view = request.view;
            done = 0;
            scene.camera = view.camera;
            scene.settings = view.settings;
            sums.resize(view.width * view.height);
            CHECK(cuMemsetD32((CUdeviceptr)scene.accumulation, 0, 4 * sums.size()));
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
        if (!launched) continue;
        // Raw linear sums with the sample count in w, rows top to bottom
        CHECK(cuMemcpyDtoH(sums.data(), (CUdeviceptr)scene.accumulation, sums.size() * sizeof(float4)));
        std::fwrite(sums.data(), sizeof(float4), sums.size(), stdout);
    }
}
