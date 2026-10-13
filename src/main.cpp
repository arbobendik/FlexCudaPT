#include "shaders/renderer.h"
#include <optix_function_table_definition.h>
#include "loader.h"
#include <cstring>
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
    // Raygen program: rays are only traversed, so none runs on a miss or a hit
    OptixProgramGroupDesc desc{.kind = OPTIX_PROGRAM_GROUP_KIND_RAYGEN, .raygen = {module, "__raygen__camera"}};
    OptixProgramGroup group;
    OptixProgramGroupOptions groupOptions{};
    CHECK(optixProgramGroupCreate(context, &desc, 1, &groupOptions, nullptr, nullptr, &group));
    // Link pipeline, no recursion
    OptixPipelineLinkOptions link{.maxTraceDepth = 1};
    OptixPipeline pipeline;
    CHECK(optixPipelineCreate(context, &compile, &link, &group, 1, nullptr, nullptr, &pipeline));
    // Its SBT record carries scene
    struct alignas(OPTIX_SBT_RECORD_ALIGNMENT) Record { char header[OPTIX_SBT_RECORD_HEADER_SIZE]; Scene data; };
    Record record;
    CHECK(optixSbtRecordPackHeader(group, &record));
    const CUdeviceptr table = allocate(sizeof(record));
    OptixShaderBindingTable sbt = {.raygenRecord = table};
    // Each request accumulates up to launches more samples of its view, samples at most, and is answered with the
    // number launched, followed by the sums if any were; a new view starts over
    struct View { unsigned width, height; Camera camera; } view{};
    struct { unsigned samples, launches; View view; } request;
    std::vector<float4> sums;
    scene.accumulation = (float4*)allocate(sizeof(float4)); // For the first view to free like any later one's
    for (unsigned done = 0, launched; std::fread(&request, sizeof(request), 1, stdin); std::fflush(stdout)) {
        if (std::memcmp(&view, &request.view, sizeof(View))) {
            view = request.view;
            done = 0;
            scene.camera = view.camera;
            sums.resize(view.width * view.height);
            CHECK(cuMemFree((CUdeviceptr)scene.accumulation));
            scene.accumulation = (float4*)allocate(sums.size() * sizeof(float4));
            CHECK(cuMemsetD32((CUdeviceptr)scene.accumulation, 0, 4 * sums.size()));
            record.data = scene;
            CHECK(cuMemcpyHtoD(table, &record, sizeof(record)));
        }
        // One path per pixel and sample
        for (launched = 0; launched < request.launches && done < request.samples; ++launched, ++done)
            CHECK(optixLaunch(pipeline, nullptr, 0, 0, &sbt, view.width, view.height, 1));
        std::fwrite(&launched, sizeof(launched), 1, stdout);
        if (!launched) continue;
        // Raw linear sums with the sample count in w, rows top to bottom
        CHECK(cuMemcpyDtoH(sums.data(), (CUdeviceptr)scene.accumulation, sums.size() * sizeof(float4)));
        std::fwrite(sums.data(), sizeof(float4), sums.size(), stdout);
    }
}
