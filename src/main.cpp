#include "shaders/renderer.h"
#include <optix_function_table_definition.h>
#include "loader.h"
#include "../build/shaders.h"

int main(int, char** argv) { // Usage: renderer width height samples < scene > sums
    const int width = std::atoi(argv[1]);
    const int height = std::atoi(argv[2]);
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
    // Build scene, alloc framebuffer
    Scene scene = loadScene(context);
    scene.accumulation = (float4*)allocate(width * height * sizeof(float4), std::vector<float4>(width * height).data());

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
    Record record{ {}, scene };
    CHECK(optixSbtRecordPackHeader(group, &record));
    OptixShaderBindingTable sbt = {.raygenRecord = allocate(sizeof(record), &record)};
    // One path per pixel and sample
    for (int sample = std::atoi(argv[3]); sample > 0; --sample)
        CHECK(optixLaunch(pipeline, nullptr, 0, 0, &sbt, width, height, 1));
    // Raw linear sums with the sample count in w, rows top to bottom
    std::vector<float4> sums(width * height);
    CHECK(cuMemcpyDtoH(sums.data(), (CUdeviceptr)scene.accumulation, sums.size() * sizeof(float4)));
    std::fwrite(sums.data(), sizeof(float4), sums.size(), stdout);
}
