#pragma once
#include "shaders/renderer.h"
#include <algorithm>
#include <vector>
#include <map>
#include <tuple>
#include <utility>
#include <unordered_map>
#include <random>
#include <cuda.h>
#include <optix_stubs.h>
#include <cstdio>
#include <fcntl.h>
#include <cstring>
#include <cstdlib>
#include <cmath>
#define CHECK(call) do { int error = (call); if (error) { \
    std::fprintf(stderr, "%s failed (%d)\n", #call, error); std::exit(1); } } while (0)

// Count items of size piped in by the extension into data. Its pipe ends only once the extension is gone, closed,
// crashed or killed, when the renderer ends too, whatever it was reading, rather than go on with what never came: true
// as it returns only with them all
inline const char* mapped = nullptr; // A scene's parts in Blender's memory, while it is read there, and what is left
inline size_t unread = 0;
inline int mappedFile = -1; // Its file and start, its pages punched out as they are read: none waits beside the copies
inline const char* mappedBase = nullptr; // made of it
inline size_t punched = 0;
inline bool receive(void* data, size_t size, size_t count) {
    if (mapped) {
        if (size * count > unread) std::exit(0);
        std::memcpy(data, mapped, size * count), mapped += size * count, unread -= size * count;
        const size_t read = size_t(mapped - mappedBase) / 4096 * 4096;
        if (read > punched) // Freed for every holder of the file
            CHECK(fallocate(mappedFile, FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE, punched, read - punched));
        punched = std::max(punched, read);
        return true;
    }
    if (std::fread(data, size, count, stdin) != count) std::exit(0);
    return true;
}

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
    receive(data.data(), sizeof(T), count);
    return (T*)allocate(count * sizeof(T), data.data());
}
template <typename T> T* load(size_t count) {
    std::vector<T> data;
    return load(count, data);
}
// Count elements piped in by the extension into data, uploaded into array from first on
template <typename T> void update(T* array, size_t first, size_t count, void* data) {
    receive(data, sizeof(T), count);
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

// A point of a mesh through an instance's transform, in doubles
inline float3 place(const Instance& instance, float3 p) {
    const float* m = instance.matrix;
    const auto row = [&](int j) { return float(double(p.x) * m[4 * j] + double(p.y) * m[4 * j + 1]
        + double(p.z) * m[4 * j + 2] + m[4 * j + 3]); };
    return {row(0), row(1), row(2)};
}

// Light BVH over the instances' emitting triangles, as leaves of their bounds, normal and power pi * emitted * area in
// the world, else a leaf of no power, uploaded to the GPU with the trails to the triangles' leaves by their numbers in
// the scene's order (pbrt-v4's bit trails)
inline LightNode* loadLights(const std::vector<float3>& vertices, const std::vector<Instance>& instances,
    const std::vector<Material>& materials, unsigned long long*& trails) {
    std::vector<LightNode> lights, nodes;
    for (unsigned i = 0; i < instances.size(); ++i) for (unsigned m = instances[i].first; m < instances[i].first +
        instances[i].count; ++m) {
        const unsigned t = instances[i].key + m - instances[i].first;
        if (!(materials[t].emitted > 0)) continue;
        const float3 a = place(instances[i], vertices[3 * m]), b = place(instances[i], vertices[3 * m + 1]);
        const float3 c = place(instances[i], vertices[3 * m + 2]), n = cross(b - a, c - a);
        if (length(n) > 0)
            lights.push_back({lower(lower(a, b), c), upper(upper(a, b), c), n * (1 / length(n)),
                float(M_PI) * materials[t].emitted * length(n) / 2, 1, m, i, true});
    }
    if (lights.empty()) lights.push_back({.leaf = true});
    buildLights(nodes, lights, 0, lights.size());
    std::vector<unsigned long long> trail(nodes.size()), leaves(materials.size());
    std::vector<unsigned> depth(nodes.size());
    for (size_t i = 0; i < nodes.size(); ++i) {
        if (!nodes[i].leaf) trail[i + 1] = trail[i], trail[nodes[i].child] = trail[i] | 1ull << depth[i],
            depth[i + 1] = depth[nodes[i].child] = depth[i] + 1;
        else if (nodes[i].phi > 0) leaves[instances[nodes[i].instance].key + nodes[i].child
            - instances[nodes[i].instance].first] = trail[i]; // Not the placeholder of a scene without emitters
    }
    trails = (unsigned long long*)allocate(leaves.size() * sizeof(unsigned long long), leaves.data());
    return (LightNode*)allocate(nodes.size() * sizeof(LightNode), nodes.data());
}

// BVH of a mesh's triangles and the scratch and output it is refit in
struct Mesh { unsigned long long handle; CUdeviceptr temp, output; };
// Of the scene last loaded: its arrays besides the vertices, the meshes' vertices, the instances and materials its
// light BVH is built from, the BVHs of its meshes by first triangle and the buffer of the BVH over its instances
struct Loaded { std::vector<CUdeviceptr> arrays; std::vector<float3> vertices; std::vector<Instance> instances;
    std::vector<Material> materials; std::map<unsigned, Mesh> meshes; CUdeviceptr top{};
    std::vector<Op> ops; std::vector<unsigned> bakes, rebakes; CUdeviceptr bakeOps; unsigned rows;
    std::vector<std::tuple<CUtexObject, CUtexObject, CUarray, size_t>> textures; };

// An image piped in, of its width and height, its extension in bits 24 and 25, in 26 and 27 its format (floats, RGBA8,
// halves or 16-bit UNORM, read as k / 65535 rounded) and sRGB in 29, as two
// textures: one the shaders read whole texels of, RGBA8 as their bytes, others as their floats; and one that filters
// linearly, by its extension, RGBA8 as k / 255 decoded from sRGB if it is, to the image's index's place and the next
inline void texture(unsigned width, unsigned shape, Loaded& loaded, CUtexObject* objects) {
    const unsigned form = shape >> 26 & 3, height = shape & 0xFFFFFF, sizes[] = {16, 4, 8, 8};
    const size_t row = width * sizes[form];
    std::vector<char> texels((row * height + 15) / 16 * 16); // As piped, in whole float4s
    receive(texels.data(), 1, texels.size());
    const decltype(CU_AD_FORMAT_FLOAT) formats[] = {CU_AD_FORMAT_FLOAT, CU_AD_FORMAT_UNSIGNED_INT8, CU_AD_FORMAT_HALF,
        CU_AD_FORMAT_UNSIGNED_INT16};
    const CUDA_ARRAY_DESCRIPTOR array{width, height, formats[form], 4};
    CUarray data;
    CHECK(cuArrayCreate(&data, &array));
    const CUDA_MEMCPY2D copy{.srcMemoryType = CU_MEMORYTYPE_HOST, .srcHost = texels.data(), .srcPitch = row,
        .dstMemoryType = CU_MEMORYTYPE_ARRAY, .dstArray = data, .WidthInBytes = row, .Height = height};
    CHECK(cuMemcpy2D(&copy));
    const CUDA_RESOURCE_DESC resource{.resType = CU_RESOURCE_TYPE_ARRAY, .res = {.array = {data}}};
    const CUDA_TEXTURE_DESC sampling{.addressMode = {CU_TR_ADDRESS_MODE_CLAMP, CU_TR_ADDRESS_MODE_CLAMP},
        .filterMode = CU_TR_FILTER_MODE_POINT, .flags = form == 1 ? unsigned(CU_TRSF_READ_AS_INTEGER) : 0};
    const decltype(CU_TR_ADDRESS_MODE_WRAP) extensions[] = {CU_TR_ADDRESS_MODE_WRAP, CU_TR_ADDRESS_MODE_CLAMP,
        CU_TR_ADDRESS_MODE_BORDER, CU_TR_ADDRESS_MODE_MIRROR}, extension = extensions[shape >> 24 & 3];
    const CUDA_TEXTURE_DESC filtering{.addressMode = {extension, extension}, .filterMode = CU_TR_FILTER_MODE_LINEAR,
        .flags = CU_TRSF_NORMALIZED_COORDINATES | (shape >> 29 & 1 ? CU_TRSF_SRGB : 0)};
    CHECK(cuTexObjectCreate(&objects[0], &resource, &sampling, nullptr));
    CHECK(cuTexObjectCreate(&objects[1], &resource, &filtering, nullptr));
    memory_peak = std::max(memory_peak, memory_used += row * height);
    loaded.textures.emplace_back(objects[0], objects[1], data, row * height);
}

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

// BVH rays traverse, over instances of BVHs of triangles by their transforms, built into the buffer allocated for it
// at its start, as Vulkan's levels start at multiples of 256, then the instances and its scratch, in place of the one it
// held
inline unsigned long long buildInstances(OptixDeviceContext context, const std::vector<OptixInstance>& instances,
    CUdeviceptr& buffer) {
    OptixBuildInput input{.type = OPTIX_BUILD_INPUT_TYPE_INSTANCES,
        .instanceArray = {.numInstances = unsigned(instances.size())}};
    const OptixAccelBuildOptions build{.operation = OPTIX_BUILD_OPERATION_BUILD};
    OptixAccelBufferSizes sizes{};
    CHECK(optixAccelComputeMemoryUsage(context, &build, &input, 1, &sizes));
    const auto aligned = [](size_t bytes) { return (bytes + OPTIX_ACCEL_BUFFER_BYTE_ALIGNMENT - 1)
        & ~size_t(OPTIX_ACCEL_BUFFER_BYTE_ALIGNMENT - 1); };
    const size_t placed = aligned(sizes.outputSizeInBytes);
    const size_t temp = placed + aligned(instances.size() * sizeof(OptixInstance));
    if (buffer) release(buffer);
    buffer = allocate(temp + sizes.tempSizeInBytes);
    CHECK(cuMemcpyHtoD(buffer + placed, instances.data(), instances.size() * sizeof(OptixInstance)));
    input.instanceArray.instances = buffer + placed;
    unsigned long long handle;
    CHECK(optixAccelBuild(context, nullptr, &build, &input, 1, buffer + temp, sizes.tempSizeInBytes, buffer,
        sizes.outputSizeInBytes, &handle, nullptr, 0));
    return handle;
}
// BVH rays traverse over the instances of the meshes of vertices by their transforms, each instance's id its first
// triangle's number in the scene's order: each mesh's BVH built or refit in its own, the instances' anew in top
inline unsigned long long buildScene(OptixDeviceContext context, const float3* vertices,
    const std::vector<Instance>& instances, std::map<unsigned, Mesh>& meshes, OptixBuildOperation operation,
    CUdeviceptr& top) {
    if (operation == OPTIX_BUILD_OPERATION_BUILD)
        for (auto& [first, mesh] : std::exchange(meshes, {})) release(mesh.temp), release(mesh.output);
    std::map<unsigned, unsigned> counts; // Of each mesh by first triangle its triangle count; a scene of no instance
    for (const Instance& instance : instances) counts[instance.first] = instance.count; // traces one of no triangles
    if (instances.empty()) counts[0] = 0;
    for (auto [first, count] : counts)
        meshes[first].handle = buildBVH(context, (CUdeviceptr)(vertices + 3 * first), count, operation,
            meshes[first].temp, meshes[first].output);
    std::vector<OptixInstance> placed(std::max<size_t>(instances.size(), 1), {.transform = {1, 0, 0, 0, 0, 1, 0, 0, 0,
        0, 1, 0}, .visibilityMask = 255, .traversableHandle = meshes.begin()->second.handle});
    for (size_t i = 0; i < instances.size(); ++i) {
        std::copy_n(instances[i].matrix, 12, placed[i].transform);
        placed[i].instanceId = instances[i].key, placed[i].visibilityMask = 255;
        placed[i].traversableHandle = meshes.at(instances[i].first).handle;
    }
    return buildInstances(context, placed, top);
}

template <typename T> T* upload(const std::vector<T>& data) {
    return (T*)allocate(data.size() * sizeof(T), data.data());
}
template <typename T> std::vector<T> read(size_t count) { // Piped in
    std::vector<T> data(count);
    receive(data.data(), sizeof(T), count);
    return data;
}
// Rows and adjugate of no transform, of an instance of a mesh in world space
constexpr float IDENTITY_ROWS[12] = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0};
constexpr float IDENTITY_ADJUGATE[9] = {1, 0, 0, 0, 1, 0, 0, 0, 1};

// Scene piped in by the extension into scene, in place of the one of arrays: triangle, step, texel, baked texel, bake,
// mesh triangle, instance and image counts, the meshes' arrays, the instances, then the steps, the texels, the
// programs of its bakes, which the bake pass fills the baked texels after those piped with, and each image's float4
// count and its texels. The meshes keep their own space, those of instances in world space untransformed. The vertices
// last denoised stay the previous ones while the meshes' triangle count does, others are freed.
inline void loadScene(OptixDeviceContext context, Scene& scene, Loaded& loaded) {
    for (CUdeviceptr array : loaded.arrays) release(array);
    for (auto [object, filtering, data, bytes] : loaded.textures) {
        CHECK(cuTexObjectDestroy(object));
        CHECK(cuTexObjectDestroy(filtering));
        CHECK(cuArrayDestroy(data));
        memory_used -= bytes;
    }
    loaded.textures.clear();
    float3* const last = scene.vertices;
    const size_t corners = loaded.vertices.size();
    struct { unsigned count, ops, texels, baked, bakes, rows, only, triangles, instances, images; } header;
    receive(&header, sizeof(header), 1);
    const size_t meshes = header.triangles;
    std::vector<Instance>& instances = loaded.instances; // Each piped without its first number in the scene's order
    instances.resize(header.instances);
    for (Instance& instance : instances) receive(&instance, offsetof(Instance, key), 1);
    std::erase_if(instances, [](const Instance& instance) { return !instance.count; }); // Of no triangles, nothing
    loaded.vertices = read<float3>(3 * meshes), scene.vertices = upload(loaded.vertices);
    scene.normals = upload(read<float3>(3 * meshes)), scene.generated = upload(read<float3>(3 * meshes));
    scene.objects = upload(read<float3>(3 * meshes)), scene.uvs = upload(read<float2>(3 * meshes));
    scene.colors = upload(read<float4>(3 * meshes)), scene.tangents = upload(read<float4>(3 * meshes));
    scene.passes = upload(read<float>(meshes)); // Per triangle of the meshes its material's pass index, then its
    const std::vector<Material> table = read<Material>(meshes + 1); // material and the world's
    loaded.materials.clear();
    for (Instance& instance : instances) {
        instance.key = loaded.materials.size();
        const auto mesh = table.begin() + instance.first;
        loaded.materials.insert(loaded.materials.end(), mesh, mesh + instance.count);
        if (instance.world)
            std::copy_n(IDENTITY_ROWS, 12, instance.matrix), std::copy_n(IDENTITY_ADJUGATE, 9, instance.adjugate);
    }
    loaded.materials.push_back(table[meshes]);
    scene.instances = upload(instances), scene.instanceCount = instances.size();
    scene.materials = upload(loaded.materials);
    scene.lights = (LightNode*)allocate(0), scene.trails = (unsigned long long*)allocate(0);
    loaded.ops.resize(header.ops), loaded.rows = header.rows, scene.count = header.count;
    receive(loaded.ops.data(), sizeof(Op), header.ops); // The materials' programs, then the bakes', apart
    scene.ops = (Op*)allocate(header.rows * sizeof(Op), loaded.ops.data());
    loaded.bakeOps = allocate((header.ops - header.rows) * sizeof(Op), loaded.ops.data() + header.rows);
    std::vector<float4> texels(header.texels + header.baked), only(header.only); // Those only bakes read apart
    receive(texels.data(), sizeof(float4), header.texels);
    receive(only.data(), sizeof(float4), header.only);
    scene.texels = (float4*)allocate(texels.size() * sizeof(float4), texels.data());
    scene.bakeTexels = (float4*)allocate(only.size() * sizeof(float4), only.data());
    loaded.bakes.resize(header.bakes);
    receive(loaded.bakes.data(), sizeof(unsigned), header.bakes);
    std::vector<unsigned> shapes(2 * header.images); // Each image a texture, found by its index
    receive(shapes.data(), sizeof(unsigned), shapes.size());
    std::vector<CUtexObject> images(2 * header.images); // Each image's two textures
    for (unsigned k = 0; k < header.images; ++k) texture(shapes[2 * k], shapes[2 * k + 1], loaded, &images[2 * k]);
    scene.images = (CUtexObject*)allocate(images.size() * sizeof(CUtexObject), images.data());
    unsigned attributes; // Instancer attributes, float4 each, each instance's info naming its first
    receive(&attributes, sizeof(unsigned), 1);
    scene.attributes = load<float4>(attributes);
    scene.handle = buildScene(context, scene.vertices, instances, loaded.meshes, OPTIX_BUILD_OPERATION_BUILD,
        loaded.top);
    if (last != scene.previousVertices) release((CUdeviceptr)last);
    if (3 * meshes != corners) release((CUdeviceptr)scene.previousVertices), scene.previousVertices = scene.vertices;
    loaded.arrays = {(CUdeviceptr)scene.normals, (CUdeviceptr)scene.generated, (CUdeviceptr)scene.objects,
        (CUdeviceptr)scene.uvs, (CUdeviceptr)scene.colors, (CUdeviceptr)scene.tangents, (CUdeviceptr)scene.instances,
        (CUdeviceptr)scene.passes, (CUdeviceptr)scene.materials, (CUdeviceptr)scene.lights, (CUdeviceptr)scene.trails,
        (CUdeviceptr)scene.ops, (CUdeviceptr)scene.texels, (CUdeviceptr)scene.images, (CUdeviceptr)scene.attributes};
}

// The steps of all programs anew, piped in by the extension as their count, the same, then the steps, as when only
// materials' values changed, an animated one's by frame; then the tables the programs read, rebuilt, each as its first
// texel and width and its texels, until a width of 0; then per program its first step and light power hint, until a
// first of 2^32 - 1, which the materials of the programs take; then the bakes to run again
inline void updateSteps(Scene& scene, Loaded& loaded) {
    unsigned count;
    receive(&count, sizeof(count), 1);
    update(scene.ops, 0, loaded.rows, loaded.ops.data());
    receive(loaded.ops.data() + loaded.rows, sizeof(Op), count - loaded.rows);
    std::vector<float4> only; // Texels only bakes read, sent again for bakes to run again: first flagged in bit 31
    for (unsigned table[2]; receive(table, sizeof(table), 1) && table[1];)
        if (table[0] >> 31) only.resize(std::max<size_t>(only.size(), (table[0] & ~(1u << 31)) + table[1])),
            receive(only.data() + (table[0] & ~(1u << 31)), sizeof(float4), table[1]);
        else update(scene.texels, table[0], table[1], std::vector<float4>(table[1]).data());
    std::unordered_map<unsigned, float> hints;
    for (std::pair<unsigned, float> hint; receive(&hint, sizeof(hint), 1) && hint.first != ~0u;)
        hints[hint.first] = hint.second;
    for (Material& material : loaded.materials) material.emitted = hints.at(material.program);
    receive(&count, sizeof(count), 1);
    loaded.rebakes.resize(count);
    receive(loaded.rebakes.data(), sizeof(unsigned), count);
    if (count) // Those bakes' programs and texels for their pass alone, as a scene's
        loaded.bakeOps = allocate((loaded.ops.size() - loaded.rows) * sizeof(Op), loaded.ops.data() + loaded.rows),
        scene.bakeTexels = (float4*)allocate(only.size() * sizeof(float4), only.data());
}

// Triangles of objects that moved or deformed, piped in by the extension into the scene in place, as FlexLight updates
// the slots of its instances: a count of ranges, then per range its first triangle's number and triangle count in the
// scene's order, each an instance's, then their arrays, in place, and its transform's rows and adjugate. The light BVH
// is built anew and the meshes' BVHs refit. The vertices last denoised stay the previous ones.
inline void updateScene(OptixDeviceContext context, Scene& scene, Loaded& loaded) {
    const size_t bytes = loaded.vertices.size() * sizeof(float3);
    if (scene.previousVertices == scene.vertices) {
        scene.previousVertices = (float3*)allocate(bytes);
        CHECK(cuMemcpyDtoD((CUdeviceptr)scene.previousVertices, (CUdeviceptr)scene.vertices, bytes));
    }
    unsigned ranges;
    receive(&ranges, sizeof(ranges), 1);
    for (unsigned r = 0; r < ranges; ++r) {
        struct { unsigned first, count; } range;
        receive(&range, sizeof(range), 1);
        const auto instance = std::upper_bound(loaded.instances.begin(), loaded.instances.end(), range.first,
            [](unsigned key, const Instance& instance) { return key < instance.key; }) - loaded.instances.begin() - 1;
        const unsigned first = loaded.instances[instance].first; // Of the instance's mesh, in place
        std::vector<Info> scratch(range.count); // As large as any of the range's arrays piped in, then its info
        update(scene.vertices, 3 * first, 3 * range.count, &loaded.vertices[3 * first]);
        update(scene.normals, 3 * first, 3 * range.count, scratch.data());
        update(scene.generated, 3 * first, 3 * range.count, scratch.data());
        update(scene.objects, 3 * first, 3 * range.count, scratch.data());
        update(scene.uvs, 3 * first, 3 * range.count, scratch.data());
        update(scene.colors, 3 * first, 3 * range.count, scratch.data());
        update(scene.tangents, 3 * first, 3 * range.count, scratch.data());
        receive(scratch.data(), sizeof(Info), range.count); // Its instance's info per triangle, with
        std::vector<float> passes(range.count); // the triangle's pass index
        for (unsigned t = 0; t < range.count; ++t) passes[t] = scratch[t].material;
        CHECK(cuMemcpyHtoD((CUdeviceptr)(scene.passes + first), passes.data(), range.count * sizeof(float)));
        float rows[21]; // Its transform's rows and adjugate, of no use to a mesh in world space
        receive(rows, sizeof(float), 21);
        Instance& entry = loaded.instances[instance];
        if (range.count) {
            if (!entry.world) std::copy_n(rows, 12, entry.matrix), std::copy_n(rows + 12, 9, entry.adjugate);
            const unsigned attributes = entry.info.attributes; // Its instancer attributes as last piped
            entry.info = scratch[0], entry.info.attributes = attributes;
            CHECK(cuMemcpyHtoD((CUdeviceptr)&scene.instances[instance], &entry, sizeof(Instance)));
        }
    }
    scene.handle = buildScene(context, scene.vertices, loaded.instances, loaded.meshes, OPTIX_BUILD_OPERATION_UPDATE,
        loaded.top);
}
