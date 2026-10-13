#pragma once
#include <vector_types.h>

// Perspective: the ray through NDC (u, v) leaves origin along x * u + y * v + z.
struct Camera { float3 origin, x, y, z; };
// Step of a program on a stack of values: pushes its value, the UV or the normal, replaces a UV with the color or alpha
// there of the width * height sRGB texels from texel on, or combines the two topmost.
enum { END, PUSH, UV, NORMAL, IMAGE, ALPHA, ADD, SUBTRACT, MULTIPLY, DOT_PRODUCT };
struct Op { unsigned code; union { float3 value; struct { unsigned texel, width, height; }; }; };
// What a material's program leaves on the stack, from the bottom
struct Surface { float3 normal, albedo; float metallic, roughness; float3 emissive; float transparency, ior; };
// Lights are sampled by emitted, their summed emission under white textures; hidden surfaces let camera rays through.
struct Material { float emitted; unsigned program, hidden; };
// Per triangle: three vertices and UVs, one material, cumulative emitted power; the world's material comes last.
struct Scene {
    float4* accumulation; unsigned long long handle; float3* vertices; float2* uvs; Material* materials; float* power;
    Op* ops; uchar4* texels; unsigned count; Camera camera;
};
