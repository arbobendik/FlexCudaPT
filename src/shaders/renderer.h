#pragma once
#include <vector_types.h>

struct Camera { float focal; float3 axes[3]; }; // At the origin looking down -z; world axes orient the world texture.
// width * height sRGB texels from texel on, seen through the 256 texels of a color ramp from ramp on if it is set
struct Texture { unsigned texel, width, height, ramp; };
// Base color and emission each tint a texture.
struct Material { float3 baseColor, emission; Texture baseTexture, emissionTexture; };
// Per triangle: three vertices and UVs, one material, cumulative emitted power; the world's material comes last.
struct Scene {
    float4* accumulation; unsigned long long handle; float3* vertices; float2* uvs; Material* materials; double* power;
    uchar4* texels; unsigned count; Camera camera;
};
