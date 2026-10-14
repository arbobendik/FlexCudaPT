#pragma once
#include "shaders/renderer.h"
#include <vector>
#include <random>
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

// Zeroed array on the GPU
template <typename T> T* zeros(size_t count) {
    const CUdeviceptr ptr = allocate(count * sizeof(T));
    CHECK(cuMemsetD8(ptr, 0, count * sizeof(T)));
    return (T*)ptr;
}

// Per pixel arrays of a view
inline void loadView(Scene& scene, size_t pixels) {
    scene.accumulation = zeros<float4>(pixels);
    scene.previous = zeros<Reservoir>(pixels);
    scene.initial = zeros<Reservoir>(pixels);
    scene.temporal = zeros<Reservoir>(pixels);
    scene.duplication = zeros<float>(pixels);
    scene.shifts = zeros<Shift>(3 * pixels);
}

// Gaussian standard deviation with the mean distance of a 30 pixel uniform disk (Sec. 7)
constexpr float PAIRING_SIGMA = 16;

// Reuse texture pairing pixels by random 2 x 2 shuffles of consecutive link indices, giving Gaussian distributed
// offsets (Sec. 3.1): per pixel the offset to the pixel sharing its link index, wrapped to keep the texture tileable
inline char2* loadPairing(int size) {
    std::vector<int> link(size * size);
    for (int i = 0; i < size * size; ++i) link[i] = i >> 1;
    const int shuffles = PAIRING_SIGMA * PAIRING_SIGMA / 2 + 1.46f / PAIRING_SIGMA
        + 1.76f / (PAIRING_SIGMA * PAIRING_SIGMA) + 0.656f / (PAIRING_SIGMA * PAIRING_SIGMA * PAIRING_SIGMA) + 0.5f;
    std::minstd_rand random; // Seeded alike every run, for renders to repeat
    for (int s = 0; s < shuffles; ++s) // Every other shuffle is offset diagonally by one, looping over the edge
        for (int y = s % 2; y < size + s % 2; y += 2) for (int x = s % 2; x < size + s % 2; x += 2) {
            int block[4];
            for (int c = 0; c < 4; ++c) block[c] = (y + (c >> 1)) % size * size + (x + (c & 1)) % size;
            for (int c = 3; c > 0; --c) std::swap(link[block[c]], link[block[random() % (c + 1)]]);
        }
    const auto wrap = [size](int d) { return d > size / 2 ? d - size : d < -size / 2 ? d + size : d; };
    std::vector<int> first(size * size / 2, -1);
    std::vector<char2> deltas(size * size);
    for (int i = 0; i < size * size; ++i) {
        int& j = first[link[i]];
        if (j < 0) { j = i; continue; }
        const int dx = wrap(j % size - i % size), dy = wrap(j / size - i / size);
        deltas[i] = {(signed char)dx, (signed char)dy};
        deltas[j] = {(signed char)-dx, (signed char)-dy};
    }
    return (char2*)allocate(deltas.size() * sizeof(char2), deltas.data());
}

// Array piped in by the extension, uploaded to the GPU.
template <typename T> T* load(size_t count) {
    std::vector<T> data(count);
    std::fread(data.data(), sizeof(T), count, stdin);
    return (T*)allocate(count * sizeof(T), data.data());
}

// World-space scene piped in by the extension: triangle, step and texel counts, then the scene's arrays in order.
inline Scene loadScene(OptixDeviceContext context) {
    struct { unsigned count, ops, texels; } header;
    std::fread(&header, sizeof(header), 1, stdin);
    Scene scene{.vertices = load<float3>(3 * header.count), .normals = load<float3>(3 * header.count),
        .uvs = load<float2>(3 * header.count),
        .materials = load<Material>(header.count + 1), .power = load<float>(header.count),
        .ops = load<Op>(header.ops), .texels = load<float4>(header.texels), .count = header.count,
        .pairing = {loadPairing(PAIRING_SIZES[0]), loadPairing(PAIRING_SIZES[1]), loadPairing(PAIRING_SIZES[2])}};
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
