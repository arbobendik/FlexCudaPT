#include "renderer.h"
#include <optix.h>
#include <cuda_runtime.h>

__device__ float4& pixel() {
    const uint3 p = optixGetLaunchIndex();
    return ((Scene*)optixGetSbtDataPointer())->pixels[p.y * optixGetLaunchDimensions().x + p.x];
}
extern "C" __global__ void __raygen__camera() {
    const uint3 p = optixGetLaunchIndex();
    const uint3 size = optixGetLaunchDimensions();
    const float3 direction = make_float3((2 * (p.x + 0.5f) - size.x) / size.y,
                                         (size.y - 2 * (p.y + 0.5f)) / size.y, -1);
    pixel() = make_float4(0.08f, 0.09f, 0.13f, 1);
    optixTrace(((Scene*)optixGetSbtDataPointer())->handle, make_float3(0, 0, 0), direction,
               0.0f, 1e16f, 0.0f, 255, OPTIX_RAY_FLAG_NONE, 0, 1, 0);
}
extern "C" __global__ void __closesthit__color() {
    const float2 uv = optixGetTriangleBarycentrics();
    pixel() = make_float4(1 - uv.x - uv.y, uv.x, uv.y, 1);
}
