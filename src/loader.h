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

// Array piped in by the extension, uploaded to the GPU.
template <typename T> T* load(size_t count) {
    std::vector<T> data(count);
    std::fread(data.data(), sizeof(T), count, stdin);
    return (T*)allocate(count * sizeof(T), data.data());
}

// World-space scene piped in by the extension: triangle and texel counts, camera, then the scene's arrays in order.
inline Scene loadScene(OptixDeviceContext context) {
    struct { unsigned count, texels; Camera camera; } header;
    std::fread(&header, sizeof(header), 1, stdin);
    Scene scene{.vertices = load<float3>(3 * header.count), .uvs = load<float2>(3 * header.count),
        .materials = load<Material>(header.count + 1), .power = load<double>(header.count),
        .texels = load<uchar4>(header.texels), .count = header.count, .camera = header.camera};
    CUdeviceptr vertexBuffer = (CUdeviceptr)scene.vertices;
    unsigned flags = OPTIX_GEOMETRY_FLAG_DISABLE_ANYHIT;
    OptixBuildInput input{.type = OPTIX_BUILD_INPUT_TYPE_TRIANGLES, .triangleArray = {
        .vertexBuffers = &vertexBuffer, .numVertices = 3 * header.count,
        .vertexFormat = OPTIX_VERTEX_FORMAT_FLOAT3, .flags = &flags, .numSbtRecords = 1}};
    OptixAccelBuildOptions build{.operation = OPTIX_BUILD_OPERATION_BUILD};
    OptixAccelBufferSizes sizes{};
    CHECK(optixAccelComputeMemoryUsage(context, &build, &input, 1, &sizes));
    CHECK(optixAccelBuild(context, nullptr, &build, &input, 1, allocate(sizes.tempSizeInBytes), sizes.tempSizeInBytes,
        allocate(sizes.outputSizeInBytes), sizes.outputSizeInBytes, &scene.handle, nullptr, 0));
    return scene;
}
