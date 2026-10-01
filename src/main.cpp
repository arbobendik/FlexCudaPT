#include "shaders/renderer.h"
#include <optix_function_table_definition.h>
#include "loader.h"
#include "../build/shaders.h"

int main(int, char** argv) { // Usage: renderer width height > pixels
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
    Scene scene{.handle = loadScene(context)};
    scene.pixels = (float4*)allocate(width * height * sizeof(float4));

    // Load embedded PTX
    OptixPipelineCompileOptions compile{};
    OptixModuleCompileOptions moduleOptions{};
    OptixModule module;
    CHECK(optixModuleCreate(context, &moduleOptions, &compile,
        (const char*)build_shaders_ptx, build_shaders_ptx_len, nullptr, nullptr, &module));
    // Raygen, miss, hit programs
    OptixProgramGroupDesc desc[] = {
        {.kind = OPTIX_PROGRAM_GROUP_KIND_RAYGEN, .raygen = {module, "__raygen__camera"}},
        {.kind = OPTIX_PROGRAM_GROUP_KIND_MISS}, // Null miss leaves the background unchanged.
        {.kind = OPTIX_PROGRAM_GROUP_KIND_HITGROUP, .hitgroup = {module, "__closesthit__color"}}};
    OptixProgramGroup groups[3];
    OptixProgramGroupOptions groupOptions{};
    CHECK(optixProgramGroupCreate(context, desc, 3, &groupOptions, nullptr, nullptr, groups));
    // Link pipeline, no recursion
    OptixPipelineLinkOptions link{.maxTraceDepth = 1};
    OptixPipeline pipeline;
    CHECK(optixPipelineCreate(context, &compile, &link, groups, 3, nullptr, nullptr, &pipeline));
    // One SBT record per group, the raygen's and the hit's carrying scene
    struct alignas(OPTIX_SBT_RECORD_ALIGNMENT) Record { char header[OPTIX_SBT_RECORD_HEADER_SIZE]; Scene data; };
    Record records[] = {{ {}, scene }, {}, { {}, scene }};
    for (int i = 0; i < 3; ++i) CHECK(optixSbtRecordPackHeader(groups[i], &records[i]));
    // Upload records, point SBT at them
    const CUdeviceptr table = allocate(sizeof(records), records);
    OptixShaderBindingTable sbt = {.raygenRecord = table,
        .missRecordBase = table + sizeof(Record), .missRecordStrideInBytes = sizeof(Record), .missRecordCount = 1,
        .hitgroupRecordBase = table + 2 * sizeof(Record), .hitgroupRecordStrideInBytes = sizeof(Record),
        .hitgroupRecordCount = 1};
    CHECK(optixLaunch(pipeline, nullptr, 0, 0, &sbt, width, height, 1));
    // Raw linear RGBA, rows top to bottom
    std::vector<float4> pixels(width * height);
    CHECK(cuMemcpyDtoH(pixels.data(), (CUdeviceptr)scene.pixels, pixels.size() * sizeof(float4)));
    std::fwrite(pixels.data(), sizeof(float4), pixels.size(), stdout);
}
