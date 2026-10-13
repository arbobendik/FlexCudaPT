#pragma once
#include <vector_types.h>

// Perspective: the ray through NDC (u, v) leaves origin along x * u + y * v + z.
struct Camera { float3 origin, x, y, z; };
// width * height sRGB texels from texel on, seen through the 256 texels of a color ramp from ramp on if it is set
struct Texture { unsigned texel, width, height, ramp; };
// Base color and emission each tint a texture; hidden surfaces let camera rays through.
struct Material { float3 baseColor, emission; Texture baseTexture, emissionTexture; unsigned hidden; };
// Per triangle: three vertices and UVs, one material, cumulative emitted power; the world's material comes last.
struct Scene {
    float4* accumulation; unsigned long long handle; float3* vertices; float2* uvs; Material* materials; double* power;
    uchar4* texels; unsigned count; Camera camera;
};
