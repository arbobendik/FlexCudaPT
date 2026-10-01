#pragma once
#include <vector>
#include <cuda.h>
#include <optix_stubs.h>
#include <cstdio>
#include <cstdlib>
#define CHECK(call) do { int error = (call); if (error) { \
    std::fprintf(stderr, "%s failed (%d)\n", #call, error); std::exit(1); } } while (0)

inline CUdeviceptr allocate(size_t bytes, const void* data = nullptr) {
    CUdeviceptr ptr;
    CHECK(cuMemAlloc(&ptr, bytes));
    if (data) CHECK(cuMemcpyHtoD(ptr, data, bytes));
    return ptr;
}

inline OptixTraversableHandle loadScene(OptixDeviceContext context) {
    const float vertices[] = {0, 0.6f, -1, -0.8f, -0.6f, -1, 0.8f, -0.6f, -1};
    CUdeviceptr vertexBuffer = allocate(sizeof(vertices), vertices);
    unsigned flags = OPTIX_GEOMETRY_FLAG_DISABLE_ANYHIT;
    OptixBuildInput input{.type = OPTIX_BUILD_INPUT_TYPE_TRIANGLES, .triangleArray = {
        .vertexBuffers = &vertexBuffer, .numVertices = 3,
        .vertexFormat = OPTIX_VERTEX_FORMAT_FLOAT3, .flags = &flags, .numSbtRecords = 1}};
    OptixAccelBuildOptions build{.operation = OPTIX_BUILD_OPERATION_BUILD};
    OptixAccelBufferSizes sizes{};
    CHECK(optixAccelComputeMemoryUsage(context, &build, &input, 1, &sizes));
    OptixTraversableHandle handle;
    CHECK(optixAccelBuild(context, nullptr, &build, &input, 1, allocate(sizes.tempSizeInBytes), sizes.tempSizeInBytes,
        allocate(sizes.outputSizeInBytes), sizes.outputSizeInBytes, &handle, nullptr, 0));
    return handle;
}
