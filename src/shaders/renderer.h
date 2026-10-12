#pragma once
#include <vector_types.h>

struct Texture { unsigned texel, width, height; }; // width * height sRGB texels from texel on
// Base color tints a texture.
struct Material { float3 baseColor, emission; Texture baseTexture; };
// Camera at the origin looks down -z. Per triangle: three vertices and UVs, one material, cumulative emitted power.
struct Scene {
    float4* accumulation; unsigned long long handle; float3* vertices; float2* uvs; Material* materials; float* power;
    uchar4* texels; unsigned count; float focal;
};
