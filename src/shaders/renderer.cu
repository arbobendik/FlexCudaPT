#include "renderer.h"
#include <optix.h>
#include <cuda_runtime.h>

constexpr int MAX_BOUNCES = 8;
constexpr float PI = 3.14159265f;
__device__ float3 operator+(float3 a, float3 b) { return make_float3(a.x + b.x, a.y + b.y, a.z + b.z); }
__device__ float3 operator-(float3 a, float3 b) { return make_float3(a.x - b.x, a.y - b.y, a.z - b.z); }
__device__ float3 operator*(float3 a, float3 b) { return make_float3(a.x * b.x, a.y * b.y, a.z * b.z); }
__device__ float3 operator*(float3 a, float s) { return make_float3(a.x * s, a.y * s, a.z * s); }
__device__ float dot(float3 a, float3 b) { return a.x * b.x + a.y * b.y + a.z * b.z; }
__device__ float3 cross(float3 a, float3 b) {
    return make_float3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x);
}
__device__ float3 normalize(float3 a) { return a * rnorm3df(a.x, a.y, a.z); }
__device__ unsigned hash(unsigned x) { // PCG
    x = x * 747796405u + 2891336453u;
    x = ((x >> ((x >> 28) + 4)) ^ x) * 277803737u;
    return (x >> 22) ^ x;
}
__device__ float random(unsigned& state) { return ((state = hash(state)) >> 8) * 0x1p-24f; }
// Cosine-weighted direction around axis.
__device__ float3 sampleCosine(float3 axis, unsigned& state) {
    const float cosine = sqrtf(random(state));
    const float sine = sqrtf(1 - cosine * cosine);
    const float phi = 2 * PI * random(state);
    const float3 tangent = normalize(cross(fabsf(axis.x) > 0.5f ? make_float3(0, 1, 0) : make_float3(1, 0, 0), axis));
    return tangent * (sine * cosf(phi)) + cross(axis, tangent) * (sine * sinf(phi)) + axis * cosine;
}
extern "C" __global__ void __raygen__camera() {
    const uint3 p = optixGetLaunchIndex();
    const uint3 size = optixGetLaunchDimensions();
    const unsigned index = p.y * size.x + p.x;
    const Scene& scene = *(Scene*)optixGetSbtDataPointer();
    float4& sum = scene.accumulation[index];
    unsigned state = hash(index + hash((unsigned)sum.w));
    float3 origin = make_float3(0, 0, 0);
    float3 radiance = make_float3(0, 0, 0);
    float3 throughput = make_float3(1, 1, 1);
    float3 direction = normalize(make_float3((2 * (p.x + random(state)) - size.x) / size.y,
                                             (size.y - 2 * (p.y + random(state))) / size.y, -scene.focal));
    for (int bounce = 0; bounce < MAX_BOUNCES; ++bounce) {
        // Traverse only; hit data is read from the hit object below.
        optixTraverse(scene.handle, origin, direction, 1e-4f, 1e16f, 0.0f, 255, OPTIX_RAY_FLAG_NONE, 0, 1, 0);
        if (!optixHitObjectIsHit()) break;
        // Bounce data: position, face normal facing the ray, material.
        const unsigned i = optixHitObjectGetPrimitiveIndex();
        const float3 a = scene.vertices[3 * i];
        const float3 b = scene.vertices[3 * i + 1];
        const float3 c = scene.vertices[3 * i + 2];
        float3 normal = normalize(cross(b - a, c - a));
        if (dot(normal, direction) > 0) normal = normal * -1;
        origin = origin + direction * optixHitObjectGetRayTmax();
        const Material material = scene.materials[i];
        radiance = radiance + throughput * material.emission;
        throughput = throughput * material.baseColor;
        // Lambert with cosine sampling: weight = f * cos / pdf = base color.
        direction = sampleCosine(normal, state);
    }
    sum = make_float4(sum.x + radiance.x, sum.y + radiance.y, sum.z + radiance.z, sum.w + 1);
}
