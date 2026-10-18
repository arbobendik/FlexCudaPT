#pragma once
#include <vector_types.h>

// Thin lens: aperture radius, depth of its focus plane, polygon sides (0 for a disk), rotation and anamorphic ratio.
struct Lens { float aperture, focus, blades, rotation, ratio; };
// Perspective: the pinhole ray through NDC (u, v) leaves origin along x * u + y * v + z.
struct Camera { float3 origin, x, y, z; Lens lens; };
// Step of a program on a stack of values: pushes its value, the UV or the normal, replaces a UV with the color or alpha
// there of the width * height linear texels from texel on or a color with the normal it encodes in tangent space, or
// combines the two or three topmost. It also pushes the generated point or replaces a point with the noise there.
enum { END, PUSH, UV, NORMAL, IMAGE, ALPHA, NORMAL_MAP, ADD, SUBTRACT, MULTIPLY, DOT_PRODUCT, MAXIMUM, LOGARITHM,
    MULTIPLY_ADD, IMAGE_LINEAR, ALPHA_LINEAR, DIVIDE, SNAP, GENERATED, NOISE, STORE, LOAD };
struct Op { unsigned code; union { float3 value; struct { unsigned texel, width, height; }; }; };
// What a material's program leaves on the stack, from the bottom
struct Surface {
    float3 normal, albedo; float metallic, roughness; float3 emissive; float transparency, ior; float3 tint;
    float level, coverage; float3 absorption; float density;
};
// FlexLight's Material, which the shared BSDF takes of a surface
struct BSDFMaterial {
    float3 albedo, emissive; float roughness, metallic, transmission, ior; float3 absorption;
};
// Lights are sampled by emitted, their summed emission under mean textures; hidden surfaces let camera rays through.
// The programs of its layers follow each other from the top.
struct Material { float emitted; unsigned program, hidden, layers; };
// Light BVH node (Conty Estevez and Kulla 2018, as in pbrt-v4) over two sided, diffuse emitting triangles: bounds of
// their points, their power and the cone of their normals around w. A leaf holds triangle child, an interior node is
// followed by its first child, child is its second.
struct LightNode { float3 low, high, w; float phi, cos_theta_o; unsigned child; bool leaf; };
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
// Of the scene: whether ReSTIR reuses paths, whether it lowers temporal reuse where samples repeat, which biases it, the
// spatial neighbors it reuses from, the bounces of a path after the camera's hit and the paths per pixel and sample
struct Settings { unsigned restir, decorrelation, neighbors, bounces, paths, denoise; };
// Reuse texture sizes, different per neighbor to avoid repeating patterns (Sec. 3.2)
constexpr int PAIRING_SIZES[] = {254, 230, 210};
// Per triangle: three vertices, normals, generated points and UVs, one material; the world's material last. The light
// BVH from its root.
// Per pixel: the reservoir the last frame ended with and the share of its neighborhood holding the same sample, this
// frame's initial and temporal reservoir and the shifts of the latter to the pixel's partner in each reuse texture.
// The frame's number seeds it.
// Denoised, per pixel: the mean radiance, the motion of what the pixel sees since the frame last denoised, through its
// camera and vertices, how far the motion is trusted, and the triangle the pixel sees now and saw then.
// Of the scene the reservoirs a view's first frame reuses were traced in: its BVH, vertices, normals and light BVH.
struct Scene {
    float4* accumulation; unsigned long long handle; float3 *vertices, *normals, *generated; float2* uvs;
    Material* materials; LightNode* lights; Op* ops; float4* texels; unsigned count; Camera camera;
    Reservoir *previous, *initial, *temporal; float* duplication; Shift* shifts; char2* pairing[3];
    unsigned frame; Camera previousCamera; Settings settings;
    float4* mean; float2* flow; float* trust; unsigned *seen, *previousSeen; float3* previousVertices;
    Camera denoisedCamera;
    unsigned long long anchorHandle; float3 *anchorVertices, *anchorNormals; LightNode* anchorLights;
};
