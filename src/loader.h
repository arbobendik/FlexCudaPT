#pragma once
#include "shaders/renderer.h"
#include <algorithm>
#include <vector>
#include <random>
#include <cuda.h>
#include <optix_stubs.h>
#include <cstdio>
#include <cstdlib>
#include <cmath>
#define CHECK(call) do { int error = (call); if (error) { \
    std::fprintf(stderr, "%s failed (%d)\n", #call, error); std::exit(1); } } while (0)

inline size_t memory_used = 0, memory_peak = 0;

inline CUdeviceptr allocate(size_t bytes, const void* data = nullptr) {
    CUdeviceptr ptr;
    CHECK(cuMemAlloc(&ptr, bytes ? bytes : 1)); // CUDA allocates no empty arrays, as of scenes without triangles
    memory_used += bytes ? bytes : 1;
    memory_peak = std::max(memory_peak, memory_used);
    if (data) CHECK(cuMemcpyHtoD(ptr, data, bytes));
    return ptr;
}

inline void release(CUdeviceptr ptr) {
    CUdeviceptr base;
    size_t bytes;
    CHECK(cuMemGetAddressRange(&base, &bytes, ptr));
    CHECK(cuMemFree(ptr));
    memory_used -= bytes;
}

// Copy of an array on the GPU
inline CUdeviceptr copy(CUdeviceptr array) {
    CUdeviceptr base;
    size_t bytes;
    CHECK(cuMemGetAddressRange(&base, &bytes, array));
    const CUdeviceptr ptr = allocate(bytes);
    CHECK(cuMemcpyDtoD(ptr, array, bytes));
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
    scene.previous = (Reservoir*)zeros<char>(pixels * (sizeof(Reservoir) + sizeof(float)));
    scene.initial = zeros<Reservoir>(pixels);
    scene.temporal = zeros<Reservoir>(pixels);
    scene.duplication = (float*)(scene.previous + pixels); // After the reservoirs, as the anchor keeps them
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

// Array piped in by the extension into data, uploaded to the GPU.
template <typename T> T* load(size_t count, std::vector<T>& data) {
    data.resize(count);
    std::fread(data.data(), sizeof(T), count, stdin);
    return (T*)allocate(count * sizeof(T), data.data());
}
template <typename T> T* load(size_t count) {
    std::vector<T> data;
    return load(count, data);
}
// Count elements piped in by the extension into data, uploaded into array from first on
template <typename T> void update(T* array, size_t first, size_t count, void* data) {
    std::fread(data, sizeof(T), count, stdin);
    CHECK(cuMemcpyHtoD((CUdeviceptr)(array + first), data, count * sizeof(T)));
}

inline float3 operator+(float3 a, float3 b) { return {a.x + b.x, a.y + b.y, a.z + b.z}; }
inline float3 operator-(float3 a, float3 b) { return {a.x - b.x, a.y - b.y, a.z - b.z}; }
inline float3 operator*(float3 a, float s) { return {a.x * s, a.y * s, a.z * s}; }
inline float dot(float3 a, float3 b) { return a.x * b.x + a.y * b.y + a.z * b.z; }
inline float3 cross(float3 a, float3 b) { return {a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x}; }
inline float length(float3 a) { return std::sqrt(dot(a, a)); }
inline float3 lower(float3 a, float3 b) { return {std::min(a.x, b.x), std::min(a.y, b.y), std::min(a.z, b.z)}; }
inline float3 upper(float3 a, float3 b) { return {std::max(a.x, b.x), std::max(a.y, b.y), std::max(a.z, b.z)}; }

// Union of light bounds and of their normal cones, either for the other of no power (pbrt-v4's Union)
inline LightNode merge(const LightNode& a, const LightNode& b) {
    if (a.phi == 0) return b;
    if (b.phi == 0) return a;
    LightNode node{lower(a.low, b.low), upper(a.high, b.high), a.w, a.phi + b.phi, a.cos_theta_o};
    const float pi = M_PI, theta_a = std::acos(a.cos_theta_o), theta_b = std::acos(b.cos_theta_o);
    const float theta_d = std::acos(std::clamp(dot(a.w, b.w), -1.0f, 1.0f));
    if (std::min(theta_d + theta_b, pi) <= theta_a) return node;
    if (std::min(theta_d + theta_a, pi) <= theta_b) return node.w = b.w, node.cos_theta_o = b.cos_theta_o, node;
    // Spread over the entire sphere, else a's axis turned about the normal of both axes
    const float theta_o = (theta_a + theta_d + theta_b) / 2;
    const float3 wr = cross(a.w, b.w);
    if (theta_o >= pi || dot(wr, wr) == 0) return node.cos_theta_o = -1, node;
    node.w = a.w * std::cos(theta_o - theta_a) + cross(wr * (1 / length(wr)), a.w) * std::sin(theta_o - theta_a);
    node.cos_theta_o = std::cos(theta_o);
    return node;
}

// Surface area orientation heuristic of light bounds b in node bounds split along dimension, diffuse emitters spreading
// a quarter turn (pbrt-v4's EvaluateCost)
inline float cost(const LightNode& b, const LightNode& bounds, int dimension) {
    const float pi = M_PI, theta_o = std::acos(b.cos_theta_o), theta_w = std::min(theta_o + pi / 2, pi);
    const float sin_theta_o = std::sqrt(std::max(1 - b.cos_theta_o * b.cos_theta_o, 0.0f));
    const float m_omega = 2 * pi * (1 - b.cos_theta_o) + pi / 2 * (2 * theta_w * sin_theta_o
        - std::cos(theta_o - 2 * theta_w) - 2 * theta_o * sin_theta_o + b.cos_theta_o);
    const float3 d = bounds.high - bounds.low, e = b.high - b.low;
    return b.phi * m_omega * std::max({d.x, d.y, d.z}) / (&d.x)[dimension] * 2 * (e.x * e.y + e.y * e.z + e.z * e.x);
}

constexpr int LIGHT_BUCKETS = 12;

// Light BVH over lights[start, end) appended to nodes, split between the buckets of their centroids per dimension of
// least cost, else in the middle (pbrt-v4's buildBVH). Returns the bounds of its root.
inline LightNode buildLights(std::vector<LightNode>& nodes, std::vector<LightNode>& lights, size_t start, size_t end) {
    if (end - start == 1) return nodes.push_back(lights[start]), lights[start];
    LightNode bounds{};
    float3 low{INFINITY, INFINITY, INFINITY}, high = low * -1;
    for (size_t i = start; i < end; ++i) {
        bounds = merge(bounds, lights[i]);
        low = lower(low, (lights[i].low + lights[i].high) * 0.5f);
        high = upper(high, (lights[i].low + lights[i].high) * 0.5f);
    }
    const auto bucket = [&](const LightNode& light, int dimension) {
        const float3 centroid = (light.low + light.high) * 0.5f;
        return std::min(int(LIGHT_BUCKETS * ((&centroid.x)[dimension] - (&low.x)[dimension])
            / ((&high.x)[dimension] - (&low.x)[dimension])), LIGHT_BUCKETS - 1);
    };
    float least = INFINITY;
    int along = -1, split = 0;
    for (int dimension = 0; dimension < 3; ++dimension) if ((&high.x)[dimension] > (&low.x)[dimension]) {
        LightNode buckets[LIGHT_BUCKETS] = {};
        for (size_t i = start; i < end; ++i)
            buckets[bucket(lights[i], dimension)] = merge(buckets[bucket(lights[i], dimension)], lights[i]);
        for (int s = 1; s < LIGHT_BUCKETS - 1; ++s) {
            LightNode below{}, above{};
            for (int j = 0; j <= s; ++j) below = merge(below, buckets[j]);
            for (int j = s + 1; j < LIGHT_BUCKETS; ++j) above = merge(above, buckets[j]);
            const float total = cost(below, bounds, dimension) + cost(above, bounds, dimension);
            if (total > 0 && total < least) least = total, along = dimension, split = s;
        }
    }
    size_t middle = along < 0 ? start : std::partition(lights.begin() + start, lights.begin() + end,
        [&](const LightNode& light) { return bucket(light, along) <= split; }) - lights.begin();
    if (middle == start || middle == end) middle = (start + end) / 2;
    const size_t index = nodes.size();
    nodes.emplace_back();
    const LightNode first = buildLights(nodes, lights, start, middle);
    const unsigned second = nodes.size();
    LightNode node = merge(first, buildLights(nodes, lights, middle, end));
    node.child = second;
    node.leaf = false;
    return nodes[index] = node;
}

// Light BVH over the emitting triangles, as leaves of their bounds, normal and power pi * emitted * area, else a leaf
// of no power, uploaded to the GPU with the trails to the triangles' leaves (pbrt-v4's bit trails)
inline LightNode* loadLights(const std::vector<float3>& vertices, const std::vector<Material>& materials,
    unsigned long long*& trails) {
    std::vector<LightNode> lights, nodes;
    for (unsigned t = 0; t + 1 < materials.size(); ++t) {
        const float3 a = vertices[3 * t], b = vertices[3 * t + 1], c = vertices[3 * t + 2], n = cross(b - a, c - a);
        if (materials[t].emitted * length(n) > 0)
            lights.push_back({lower(lower(a, b), c), upper(upper(a, b), c), n * (1 / length(n)),
                float(M_PI) * materials[t].emitted * length(n) / 2, 1, t, true});
    }
    if (lights.empty()) lights.push_back({.leaf = true});
    buildLights(nodes, lights, 0, lights.size());
    std::vector<unsigned long long> trail(nodes.size()), leaves(materials.size());
    std::vector<unsigned> depth(nodes.size());
    for (size_t i = 0; i < nodes.size(); ++i) {
        if (nodes[i].leaf) leaves[nodes[i].child] = trail[i];
        else trail[i + 1] = trail[i], trail[nodes[i].child] = trail[i] | 1ull << depth[i],
            depth[i + 1] = depth[nodes[i].child] = depth[i] + 1;
    }
    trails = (unsigned long long*)allocate(leaves.size() * sizeof(unsigned long long), leaves.data());
    return (LightNode*)allocate(nodes.size() * sizeof(LightNode), nodes.data());
}

// Of the scene last loaded: its arrays besides the vertices, the vertices and materials its light BVH is built from and
// the scratch and output its BVH is refit in
struct Loaded { std::vector<CUdeviceptr> arrays; std::vector<float3> vertices; std::vector<Material> materials;
    std::vector<Op> ops; CUdeviceptr temp, output; };

// Refittable BVH over count triangles of vertices, built into temp and output allocated for it or refit in them
inline unsigned long long buildBVH(OptixDeviceContext context, CUdeviceptr vertices, unsigned count,
    OptixBuildOperation operation, CUdeviceptr& temp, CUdeviceptr& output) {
    unsigned flags = OPTIX_GEOMETRY_FLAG_NONE; // Any-hit only skips triangles, of rays enabling it
    OptixBuildInput input{.type = OPTIX_BUILD_INPUT_TYPE_TRIANGLES, .triangleArray = {
        .vertexBuffers = count ? &vertices : nullptr, .numVertices = 3 * count,
        .vertexFormat = OPTIX_VERTEX_FORMAT_FLOAT3, .flags = &flags, .numSbtRecords = 1}};
    OptixAccelBuildOptions build{.buildFlags = OPTIX_BUILD_FLAG_ALLOW_UPDATE, .operation = operation};
    OptixAccelBufferSizes sizes{};
    CHECK(optixAccelComputeMemoryUsage(context, &build, &input, 1, &sizes));
    const size_t scratch = std::max(sizes.tempSizeInBytes, sizes.tempUpdateSizeInBytes);
    if (operation == OPTIX_BUILD_OPERATION_BUILD) temp = allocate(scratch), output = allocate(sizes.outputSizeInBytes);
    unsigned long long handle;
    CHECK(optixAccelBuild(context, nullptr, &build, &input, 1, temp, scratch, output, sizes.outputSizeInBytes, &handle,
        nullptr, 0));
    return handle;
}

// World-space scene piped in by the extension into scene, in place of the one of arrays, then its arrays: triangle,
// step and texel counts, then the scene's arrays in order. The vertices last denoised stay the previous ones while the
// triangle count does, others are freed.
inline void loadScene(OptixDeviceContext context, Scene& scene, Loaded& loaded) {
    for (CUdeviceptr array : loaded.arrays) release(array);
    float3* const last = scene.vertices;
    const unsigned count = scene.count;
    struct { unsigned count, ops, texels; } header;
    std::fread(&header, sizeof(header), 1, stdin);
    scene.vertices = load<float3>(3 * header.count, loaded.vertices), scene.normals = load<float3>(3 * header.count);
    scene.generated = load<float3>(3 * header.count), scene.objects = load<float3>(3 * header.count);
    scene.uvs = load<float2>(3 * header.count), scene.colors = load<float4>(3 * header.count);
    scene.tangents = load<float4>(3 * header.count);
    scene.infos = load<Info>(header.count);
    scene.materials = load<Material>(header.count + 1, loaded.materials);
    scene.lights = (LightNode*)allocate(0), scene.trails = (unsigned long long*)allocate(0);
    scene.ops = load<Op>(header.ops, loaded.ops), scene.texels = load<float4>(header.texels), scene.count = header.count;
    scene.handle = buildBVH(context, (CUdeviceptr)scene.vertices, header.count, OPTIX_BUILD_OPERATION_BUILD,
        loaded.temp, loaded.output);
    if (last != scene.previousVertices) release((CUdeviceptr)last);
    if (header.count != count) release((CUdeviceptr)scene.previousVertices), scene.previousVertices = scene.vertices;
    loaded.arrays = {(CUdeviceptr)scene.normals, (CUdeviceptr)scene.generated, (CUdeviceptr)scene.objects,
        (CUdeviceptr)scene.uvs, (CUdeviceptr)scene.colors, (CUdeviceptr)scene.tangents, (CUdeviceptr)scene.infos,
        (CUdeviceptr)scene.materials,
        (CUdeviceptr)scene.lights, (CUdeviceptr)scene.trails, (CUdeviceptr)scene.ops, (CUdeviceptr)scene.texels, loaded.temp, loaded.output};
}

// Triangles of objects that moved or deformed, piped in by the extension into the scene in place, as FlexLight updates
// the slots of its instances: a count of ranges, then per range its first triangle and triangle count and theirs in
// the scene's order. The light BVH is built anew and the BVH refit. The vertices last denoised stay the previous ones.
inline void updateScene(OptixDeviceContext context, Scene& scene, Loaded& loaded) {
    const size_t bytes = loaded.vertices.size() * sizeof(float3);
    if (scene.previousVertices == scene.vertices) {
        scene.previousVertices = (float3*)allocate(bytes);
        CHECK(cuMemcpyDtoD((CUdeviceptr)scene.previousVertices, (CUdeviceptr)scene.vertices, bytes));
    }
    unsigned ranges;
    std::fread(&ranges, sizeof(ranges), 1, stdin);
    for (unsigned r = 0; r < ranges; ++r) {
        struct { unsigned first, count; } range;
        std::fread(&range, sizeof(range), 1, stdin);
        std::vector<Info> scratch(range.count); // As large as any of the range's arrays piped in
        update(scene.vertices, 3 * range.first, 3 * range.count, &loaded.vertices[3 * range.first]);
        update(scene.normals, 3 * range.first, 3 * range.count, scratch.data());
        update(scene.generated, 3 * range.first, 3 * range.count, scratch.data());
        update(scene.objects, 3 * range.first, 3 * range.count, scratch.data());
        update(scene.uvs, 3 * range.first, 3 * range.count, scratch.data());
        update(scene.colors, 3 * range.first, 3 * range.count, scratch.data());
        update(scene.tangents, 3 * range.first, 3 * range.count, scratch.data());
        update(scene.infos, range.first, range.count, scratch.data());
    }
    scene.handle = buildBVH(context, (CUdeviceptr)scene.vertices, scene.count, OPTIX_BUILD_OPERATION_UPDATE,
        loaded.temp, loaded.output);
}
