#pragma once
#include "shaders/renderer.h"
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

// Diffuse triangle lit by an emissive one behind the camera: three vertices and one material per triangle.
inline Scene loadScene(OptixDeviceContext context) {
    const std::vector<float3> vertices{{0, 0.6f, -1}, {-0.8f, -0.6f, -1}, {0.8f, -0.6f, -1},
        {0, 4, 1}, {-4, -4, 1}, {4, -4, 1}};
    const std::vector<Material> materials{{.baseColor = {0.8f, 0.8f, 0.8f}}, {.emission = {1, 1, 1}}};
    CUdeviceptr vertexBuffer = allocate(vertices.size() * sizeof(float3), vertices.data());
    unsigned flags = OPTIX_GEOMETRY_FLAG_DISABLE_ANYHIT;
    OptixBuildInput input{.type = OPTIX_BUILD_INPUT_TYPE_TRIANGLES, .triangleArray = {
        .vertexBuffers = &vertexBuffer, .numVertices = (unsigned)vertices.size(),
        .vertexFormat = OPTIX_VERTEX_FORMAT_FLOAT3, .flags = &flags, .numSbtRecords = 1}};
    OptixAccelBuildOptions build{.operation = OPTIX_BUILD_OPERATION_BUILD};
    OptixAccelBufferSizes sizes{};
    CHECK(optixAccelComputeMemoryUsage(context, &build, &input, 1, &sizes));
    OptixTraversableHandle handle;
    CHECK(optixAccelBuild(context, nullptr, &build, &input, 1, allocate(sizes.tempSizeInBytes), sizes.tempSizeInBytes,
        allocate(sizes.outputSizeInBytes), sizes.outputSizeInBytes, &handle, nullptr, 0));
    return {.handle = handle, .vertices = (float3*)vertexBuffer, .materials = (Material*)allocate(
        materials.size() * sizeof(Material), materials.data()), .focal = 1};
}
