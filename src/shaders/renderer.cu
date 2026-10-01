#include "renderer.h"
#include <optix.h>
#include <cuda_runtime.h>

__device__ unsigned hash(unsigned x) { // PCG
    x = x * 747796405u + 2891336453u;
    x = ((x >> ((x >> 28) + 4)) ^ x) * 277803737u;
    return (x >> 22) ^ x;
}
__device__ float random(unsigned& state) { return ((state = hash(state)) >> 8) * 0x1p-24f; }
extern "C" __global__ void __raygen__camera() {
    const uint3 p = optixGetLaunchIndex();
    const uint3 size = optixGetLaunchDimensions();
    const unsigned index = p.y * size.x + p.x;
    const Scene& scene = *(Scene*)optixGetSbtDataPointer();
    float4& sum = scene.accumulation[index];
    unsigned state = hash(index + hash((unsigned)sum.w));
    const float3 direction = make_float3((2 * (p.x + random(state)) - size.x) / size.y,
                                         (size.y - 2 * (p.y + random(state))) / size.y, -1);
    // Traverse only; hit data is read from the hit object below.
    optixTraverse(scene.handle, make_float3(0, 0, 0), direction, 0.0f, 1e16f, 0.0f, 255, OPTIX_RAY_FLAG_NONE, 0, 1, 0);
    float3 color = make_float3(0.08f, 0.09f, 0.13f);
    if (optixHitObjectIsHit()) {
        // Barycentrics from the first two attributes; optixHitObjectGetTriangleBarycentrics returns zeros here.
        const float u = __uint_as_float(optixHitObjectGetAttribute_0());
        const float v = __uint_as_float(optixHitObjectGetAttribute_1());
        color = make_float3(1 - u - v, u, v);
    }
    sum = make_float4(sum.x + color.x, sum.y + color.y, sum.z + color.z, sum.w + 1);
}
