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
// Point of a triangle at its barycentrics, triangle NONE for no point
constexpr unsigned NONE = ~0u;
struct Hit { unsigned triangle; float2 uv; };
// ReSTIR sample of a pixel: the path its seed draws, described by path, and how to reconnect to it
struct Reservoir {
    unsigned seed, path;
    // Unbiased contribution weight and confidence
    float w, c;
    // Integrand of the sample in the owning pixel
    float3 f;
    // Source densities p(x_k-1 -> x_k) G(x_k-1 -> x_k) p(x_k -> x_k+1) of the reconnection
    float jac;
    // Reconnection vertex
    Hit rc;
    // Direction leaving the reconnection vertex and the radiance arriving along it
    float3 dir, radiance;
};
// Integrand of a sample shifted into another pixel times the Jacobian determinant of the shift, and the latter
struct Shift { float3 f; float jac; };
// Of the scene: whether ReSTIR reuses paths, whether it lowers temporal reuse where samples repeat, which biases it, and
// the spatial neighbors it reuses from
struct Settings { unsigned restir, decorrelation, neighbors; };
// Reuse texture sizes, different per neighbor to avoid repeating patterns (Sec. 3.2)
constexpr int PAIRING_SIZES[] = {254, 230, 210};
// Per triangle: three vertices and UVs, one material, cumulative emitted power; the world's material comes last.
// Per pixel: the reservoir the last frame ended with and the share of its neighborhood holding the same sample, this
// frame's initial and temporal reservoir and the shifts of the latter to the pixel's partner in each reuse texture.
// The frame's number seeds it.
struct Scene {
    float4* accumulation; unsigned long long handle; float3* vertices; float2* uvs; Material* materials; float* power;
    Op* ops; uchar4* texels; unsigned count; Camera camera;
    Reservoir *previous, *initial, *temporal; float* duplication; Shift* shifts; char2* pairing[3];
    unsigned frame; Camera previousCamera; Settings settings;
};
