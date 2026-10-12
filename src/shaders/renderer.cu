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
// Repeats into [0, 1)
__device__ float wrap(float coordinate) { return fminf(coordinate - floorf(coordinate), 0x1.fffffep-1f); }
__device__ float decode(unsigned char srgb) {
    return srgb <= 10 ? srgb / 3294.6f : powf((srgb / 255.0f + 0.055f) / 1.055f, 2.4f);
}
__device__ unsigned hash(unsigned x) { // PCG
    x = x * 747796405u + 2891336453u;
    x = ((x >> ((x >> 28) + 4)) ^ x) * 277803737u;
    return (x >> 22) ^ x;
}
__device__ float random(unsigned& state) { return ((state = hash(state)) >> 8) * 0x1p-24f; }
// In [0, 1) to double precision, from 27 and 26 bits of two draws
__device__ double random53(unsigned& state) {
    const unsigned high = (state = hash(state)) >> 5;
    const unsigned low = (state = hash(state)) >> 6;
    return (high * 0x1p26 + low) * 0x1p-53;
}
__device__ float3 decode(uchar4 texel) { return make_float3(decode(texel.x), decode(texel.y), decode(texel.z)); }
// Linear color of the texel at a UV, repeating; a ramp replaces it with its color at the texel's luminance
__device__ float3 lookup(const Scene& scene, const Texture& texture, float u, float v) {
    const float3 color = decode(scene.texels[texture.texel + unsigned(wrap(v) * texture.height) * texture.width
        + unsigned(wrap(u) * texture.width)]);
    if (!texture.ramp) return color;
    const float luminance = dot(color, make_float3(0.2126f, 0.7152f, 0.0722f));
    return decode(scene.texels[texture.ramp + unsigned(luminance * 255 + 0.5f)]);
}
// At a triangle's barycentrics
__device__ float3 lookup(const Scene& scene, const Texture& texture, unsigned triangle, float s, float t) {
    const float2* uv = scene.uvs + 3 * triangle;
    return lookup(scene, texture, uv[0].x + (uv[1].x - uv[0].x) * s + (uv[2].x - uv[0].x) * t,
        uv[0].y + (uv[1].y - uv[0].y) * s + (uv[2].y - uv[0].y) * t);
}
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
        // Barycentrics from the first two attributes; optixHitObjectGetTriangleBarycentrics returns zeros here.
        const float s = __uint_as_float(optixHitObjectGetAttribute_0());
        const float t = __uint_as_float(optixHitObjectGetAttribute_1());
        // Emitters seen by the camera; later bounces reach them through light sampling instead.
        if (bounce == 0)
            radiance = radiance + throughput * material.emission * lookup(scene, material.emissionTexture, i, s, t);
        throughput = throughput * material.baseColor * lookup(scene, material.baseTexture, i, s, t);
        // Light sampling: a triangle picked by emitted power, a uniform point on it, counted if visible.
        // The first triangle whose cumulative power exceeds the pick, below the total: never one of no power
        const double total = scene.power[scene.count - 1];
        const double pick = random53(state) * total;
        unsigned light = 0;
        for (unsigned last = scene.count - 1; light < last;) {
            const unsigned middle = (light + last) / 2;
            if (scene.power[middle] <= pick) light = middle + 1; else last = middle;
        }
        const float3 la = scene.vertices[3 * light];
        const float3 lb = scene.vertices[3 * light + 1];
        const float3 lc = scene.vertices[3 * light + 2];
        const Material lit = scene.materials[light];
        const float3 lightNormal = cross(lb - la, lc - la);
        const float side = sqrtf(random(state));
        const float along = random(state);
        const float emitted = lit.emission.x + lit.emission.y + lit.emission.z;
        const float3 toLight = la * (1 - side) + lb * (side * (1 - along)) + lc * (side * along) - origin;
        const float distance = sqrtf(dot(toLight, toLight));
        const float cosine = dot(normal, toLight) / distance;
        if (emitted > 0 && cosine > 0) {
            optixTraverse(scene.handle, origin, toLight * (1 / distance), 1e-4f, distance * (1 - 1e-4f), 0.0f, 255,
                OPTIX_RAY_FLAG_NONE, 0, 1, 0);
            // Lambert f * emission * cosines / distance^2 / pdf,
            // pdf = power share / area and power = 2 * area * emitted.
            if (!optixHitObjectIsHit()) radiance = radiance + throughput * lit.emission
                * lookup(scene, lit.emissionTexture, light, side * (1 - along), side * along)
                * (float(total) / (2 * PI * emitted) * cosine * fabsf(dot(lightNormal, toLight))
                / (distance * distance * distance * sqrtf(dot(lightNormal, lightNormal))));
        }
        // Lambert with cosine sampling: weight = f * cos / pdf = base color.
        direction = sampleCosine(normal, state);
    }
    sum = make_float4(sum.x + radiance.x, sum.y + radiance.y, sum.z + radiance.z, sum.w + 1);
}
