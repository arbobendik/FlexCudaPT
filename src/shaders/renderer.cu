#include "renderer.h"
#include <optix.h>
#include <cuda_runtime.h>
#include "adapter.h"

constexpr int STACK = 64;
constexpr int SLOTS = 32; // Values a program keeps for reuse, as the extension's
extern "C" __constant__ Params params;
constexpr float PI = 3.14159265f;
constexpr float INV_PI = 0.3183098861837907f;
// The stand-in PTX's shading not inlined: a module of a third the size, quick to compile, standing in while the inlined
// one compiles
#ifdef STANDIN
#define SHADE_INLINE __noinline__
#else
#define SHADE_INLINE __forceinline__
#endif
__device__ float3 operator+(float3 a, float3 b) { return make_float3(a.x + b.x, a.y + b.y, a.z + b.z); }
__device__ float3 operator-(float3 a, float3 b) { return make_float3(a.x - b.x, a.y - b.y, a.z - b.z); }
__device__ float3 operator-(float3 a) { return make_float3(-a.x, -a.y, -a.z); }
__device__ float2 operator-(float2 a, float2 b) { return make_float2(a.x - b.x, a.y - b.y); }
__device__ float3 operator*(float3 a, float3 b) { return make_float3(a.x * b.x, a.y * b.y, a.z * b.z); }
__device__ float3 operator*(float3 a, float s) { return make_float3(a.x * s, a.y * s, a.z * s); }
__device__ float3 operator*(float s, float3 a) { return a * s; }
__device__ float3 operator/(float3 a, float s) { return make_float3(a.x / s, a.y / s, a.z / s); }
__device__ float3 mix(float3 a, float3 b, float t) { return a * (1 - t) + b * t; }
__device__ float4 mix(float4 a, float4 b, float t) {
    return make_float4(a.x * (1 - t) + b.x * t, a.y * (1 - t) + b.y * t,
        a.z * (1 - t) + b.z * t, a.w * (1 - t) + b.w * t);
}
// -1, 0 or 1
__device__ float sign(float x) { return (x > 0) - (x < 0); }
__device__ float dot(float3 a, float3 b) { return a.x * b.x + a.y * b.y + a.z * b.z; }
__device__ float3 cross(float3 a, float3 b) {
    return make_float3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x);
}
__device__ float3 normalize(float3 a) { return a * rnorm3df(a.x, a.y, a.z); }
__device__ float length(float3 a) { return sqrtf(dot(a, a)); }
__device__ bool operator==(float3 a, float3 b) { return a.x == b.x && a.y == b.y && a.z == b.z; }
// Repeats into [0, 1)
__device__ float wrap(float coordinate) { return fminf(coordinate - floorf(coordinate), 0x1.fffffep-1f); }
__device__ float random(unsigned& state) { return ((state = hash(state)) >> 8) * 0x1p-24f; }

constexpr unsigned LOBE_DIFFUSE = 0u;
constexpr unsigned LOBE_REFRACT = 1u;
constexpr unsigned LOBE_REFLECT = 2u;
constexpr unsigned LOBE_NONE = 3u;
constexpr float BIAS = 0.0000152587890625f; // FlexKernels' BIAS, which its CUDA output inlines and does not name
// Of the ray a surface or the world is shaded for, as Cycles' light path node tells: whether it left the camera or
// tests a shadow, the lobe it left by, its bounce, a bounce further for the world, and its length, none for the world
// Of a ray's cone, the share of its width a read's mip level covers: 2^-1.5, the least that passes both the seed
// floor against the converged level-0 render (tokyo at 1024 samples; at 2^-1 it blurred past it) and the grazing
// checker (at 2^-2 it aliased past 0.05)
constexpr float CONE_SHARE = 0.35355339f;
// Of a ray: its cone's width where it hits, none for rays of no cone, and the mip level of the hit's UVs that width
// covers, by which image reads pick theirs
struct Ray { bool camera, shadow; unsigned lobe; float depth, length, width, level; };
__device__ float lightPath(const Ray& ray, int output) {
    switch (output) {
        case 0: return ray.camera;
        case 1: return ray.shadow;
        case 2: return ray.lobe == LOBE_DIFFUSE;
        case 3: return ray.lobe == LOBE_REFRACT || ray.lobe == LOBE_REFLECT;
        case 5: return ray.lobe == LOBE_DIFFUSE || ray.lobe == LOBE_REFLECT;
        case 6: return ray.lobe == LOBE_REFRACT;
        case 8: return ray.length;
        default: return ray.depth;
    }
}

// Of a to the base b, zero where undefined as Blender's
__device__ float logarithm(float a, float b) { return a > 0 && b > 0 && b != 1 ? logf(a) / logf(b) : 0; }
// sRGB to linear, as Cycles'
__device__ float decode(float c) { return c < 0.04045f ? fmaxf(c, 0) / 12.92f : powf((c + 0.055f) / 1.055f, 2.4f); }
// Of a to the power of b, zero where undefined as Blender's on the GPU
__device__ float power(float a, float b) {
    return b == 0 ? 1 : a == 0 || a < 0 && b != truncf(b) ? 0 : a > 0 ? powf(a, b)
        : (fmodf(b, 2) == 0 ? 1 : -1) * powf(-a, b);
}
// Of f per component
template <class F> __device__ float3 each(float3 a, F f) { return make_float3(f(a.x), f(a.y), f(a.z)); }
template <class F> __device__ float3 each(float3 a, float3 b, F f) {
    return make_float3(f(a.x, b.x), f(a.y, b.y), f(a.z, b.z));
}
// Cycles' conversions of RGB to HSV and HSL and back
__device__ float3 toHsv(float3 c) {
    const float high = fmaxf(c.x, fmaxf(c.y, c.z)), delta = high - fminf(c.x, fminf(c.y, c.z));
    if (high == 0 || delta == 0) return make_float3(0, 0, high);
    const float3 d = (make_float3(high, high, high) - c) / delta;
    const float h = (c.x == high ? d.z - d.y : c.y == high ? 2 + d.x - d.z : 4 + d.y - d.x) / 6;
    return make_float3(h < 0 ? h + 1 : h, delta / high, high);
}
__device__ float3 fromHsv(float3 c) {
    const float s = c.y, v = c.z, h = (c.x == 1 ? 0 : c.x) * 6, i = floorf(h), f = h - i;
    const float p = v * (1 - s), q = v * (1 - s * f), t = v * (1 - s * (1 - f));
    return s == 0 ? make_float3(v, v, v) : i == 0 ? make_float3(v, t, p) : i == 1 ? make_float3(q, v, p)
        : i == 2 ? make_float3(p, v, t) : i == 3 ? make_float3(p, q, v) : i == 4 ? make_float3(t, p, v)
        : make_float3(v, p, q);
}
__device__ float3 toHsl(float3 c) {
    const float high = fmaxf(c.x, fmaxf(c.y, c.z)), low = fminf(c.x, fminf(c.y, c.z));
    const float l = fminf(1, (high + low) / 2), delta = high - low;
    if (delta == 0) return make_float3(0, 0, l);
    const float h = c.x == high ? (c.y - c.z) / delta + (c.y < c.z ? 6 : 0) : c.y == high ? (c.z - c.x) / delta + 2
        : (c.x - c.y) / delta + 4;
    return make_float3(h / 6, l > 0.5f ? delta / (2 - high - low) : delta / (high + low), l);
}
__device__ float3 fromHsl(float3 c) {
    const float3 n = make_float3(fabsf(c.x * 6 - 3) - 1, 2 - fabsf(c.x * 6 - 2), 2 - fabsf(c.x * 6 - 4));
    const float chroma = (1 - fabsf(2 * c.z - 1)) * c.y;
    return each(n, [&](float a) { return (fminf(fmaxf(a, 0), 1) - 0.5f) * chroma + c.z; });
}
__device__ float3 divide(float3 a, float3 b) {
    return make_float3(b.x != 0 ? a.x / b.x : 0, b.y != 0 ? a.y / b.y : 0, b.z != 0 ? a.z / b.z : 0);
}
__device__ unsigned rotate(unsigned x, int k) { return x << k | x >> (32 - k); }
// Bob Jenkins' lookup3 hash of n keys, as Cycles'
__device__ unsigned jenkins(int n, unsigned x, unsigned y = 0, unsigned z = 0, unsigned w = 0) {
    unsigned a = 0xdeadbeef + (n << 2) + 13 + x, b = 0xdeadbeef + (n << 2) + 13 + y, c = 0xdeadbeef + (n << 2) + 13 + z;
    if (n == 4) {
        a -= c; a ^= rotate(c, 4); c += b; b -= a; b ^= rotate(a, 6); a += c; c -= b; c ^= rotate(b, 8); b += a;
        a -= c; a ^= rotate(c, 16); c += b; b -= a; b ^= rotate(a, 19); a += c; c -= b; c ^= rotate(b, 4); b += a;
        a += w;
    }
    c ^= b; c -= rotate(b, 14); a ^= c; a -= rotate(c, 11); b ^= a; b -= rotate(a, 25); c ^= b; c -= rotate(b, 16);
    a ^= c; a -= rotate(c, 4); b ^= a; b -= rotate(a, 14); c ^= b; c -= rotate(b, 24);
    return c;
}
// Of the bits of n floats, in [0, 1], as Cycles'
__device__ float hashed(int n, float x, float y = 0, float z = 0, float w = 0) {
    return float(jenkins(n, __float_as_uint(x), __float_as_uint(y), __float_as_uint(z), __float_as_uint(w)))
        / float(0xFFFFFFFFu);
}
// Cycles' white noise of the first dims components of p, w the fourth, its value or color
__device__ __noinline__ float3 white(float3 p, int dims, bool color, float w) {
    const float v = dims == 1 ? hashed(1, p.x) : dims == 2 ? hashed(2, p.x, p.y) : dims == 3 ? hashed(3, p.x, p.y, p.z)
        : hashed(4, p.x, p.y, p.z, w);
    if (!color) return make_float3(v, v, v);
    return dims == 1 ? make_float3(v, hashed(2, p.x, 1), hashed(2, p.x, 2)) : dims == 2
        ? make_float3(v, hashed(3, p.x, p.y, 1), hashed(3, p.x, p.y, 2)) : dims == 3
        ? make_float3(v, hashed(4, p.x, p.y, p.z, 1), hashed(4, p.x, p.y, p.z, 2))
        : make_float3(v, hashed(4, p.z, p.x, w, p.y), hashed(4, w, p.z, p.y, p.x));
}
// Cycles' PCG hash of 2 to 4 integers, shifting signed
__device__ void pcg(unsigned* v, int dims) {
    for (int k = 0; k < dims; ++k) v[k] = v[k] * 1664525u + 1013904223u;
    for (int round = 0; round < 2; ++round) {
        if (round) for (int k = 0; k < dims; ++k) v[k] ^= int(v[k]) >> 16;
        if (dims == 2) v[0] += v[1] * 1664525u, v[1] += v[0] * 1664525u;
        else if (dims == 3) v[0] += v[1] * v[2], v[1] += v[2] * v[0], v[2] += v[0] * v[1];
        else v[0] += v[1] * v[3], v[1] += v[2] * v[0], v[2] += v[0] * v[1], v[3] += v[1] * v[2];
    }
    for (int k = 0; k < dims; ++k) v[k] &= 0x7FFFFFFF;
}
// Cycles' Voronoi cell offset into o, and its color: Jenkins in 1D, signed PCG in 2D to 4D
__device__ float3 site(const int* c, int dims, float* o) {
    if (dims == 1) return make_float3(o[0] = hashed(1, c[0]), hashed(2, c[0], 1), hashed(2, c[0], 2));
    unsigned v[4] = {unsigned(c[0]), unsigned(c[1]), unsigned(c[2]), unsigned(c[3])}, u[3] = {v[0], v[1], 0};
    pcg(v, dims);
    for (int k = 0; k < dims; ++k) o[k] = float(v[k]) / float(0x7FFFFFFF);
    if (dims == 2) pcg(u, 3);
    return dims == 2 ? make_float3(u[0], u[1], u[2]) / float(0x7FFFFFFF) : make_float3(o[0], o[1], o[2]);
}
struct Cell { float distance; float3 color; float position[4]; };
// Cycles' Voronoi texture of a point of the dimensions by its feature, F1, F2 or smooth F1, and metric of exponent in
// kind, the randomness and smoothness in extra
__device__ Cell voronoi(const float* q, int dims, float3 kind, float3 extra) {
    const int feature = int(kind.x), metric = int(kind.y);
    const float randomness = fminf(fmaxf(extra.x, 0), 1), smoothness = fminf(fmaxf(extra.y / 2, 0), 0.5f);
    const int reach = feature == 2 && smoothness != 0 ? 2 : 1;
    int cell[4] = {}, count = 1;
    for (int k = 0; k < dims; ++k) cell[k] = int(floorf(q[k])), count *= 2 * reach + 1;
    float best[2] = {3.402823e38f, 3.402823e38f}, smooth = 0, h = -1, positions[2][4] = {};
    float3 colors[2] = {};
    for (int n = 0; n < count; ++n) { // Through the cells around, the first axis fastest
        int c[4] = {};
        float o[4], position[4] = {}, sum = 0, high = 0;
        for (int k = 0, m = n; k < dims; ++k, m /= 2 * reach + 1) c[k] = cell[k] + m % (2 * reach + 1) - reach;
        const float3 color = site(c, dims, o);
        for (int k = 0; k < dims; ++k) {
            position[k] = c[k] - cell[k] + o[k] * randomness;
            const float d = fabsf(position[k] - (q[k] - cell[k]));
            sum += metric == 0 ? d * d : metric == 3 ? powf(d, kind.z) : d, high = fmaxf(high, d);
        }
        const float d = metric == 0 ? sqrtf(sum) : metric == 2 ? high : metric == 3 ? powf(sum, 1 / kind.z) : sum;
        if (reach == 2) { // Smooth F1, blending every cell's in
            if (h == -1) h = 1;
            else {
                const float x = fminf(fmaxf(0.5f + 0.5f * (smooth - d) / smoothness, 0), 1);
                h = x * x * (3 - 2 * x);
            }
            const float correction = smoothness * h * (1 - h);
            smooth = smooth * (1 - h) + d * h - correction;
            colors[0] = mix(colors[0], color, h) - make_float3(1, 1, 1) * (correction / (1 + 3 * smoothness));
            for (int k = 0; k < dims; ++k)
                positions[0][k] = positions[0][k] * (1 - h) + position[k] * h - correction / (1 + 3 * smoothness);
        } else if (d < best[0]) {
            best[1] = best[0], best[0] = d, colors[1] = colors[0], colors[0] = color;
            for (int k = 0; k < 4; ++k) positions[1][k] = positions[0][k], positions[0][k] = position[k];
        } else if (d < best[1]) {
            best[1] = d, colors[1] = color;
            for (int k = 0; k < 4; ++k) positions[1][k] = position[k];
        }
    }
    const int f = feature == 1;
    Cell out = {reach == 2 ? smooth : best[f], colors[f]};
    for (int k = 0; k < dims; ++k) out.position[dims == 1 ? 3 : k] = positions[f][k] + cell[k];
    return out;
}
// Cycles' distance of a point of the dimensions to the edge of its Voronoi cell, or its cell's n-sphere radius, by
// the randomness: in one dimension to the midpoints of its cell's point and its neighbors'
__device__ float edge(const float* q, int dims, float randomness, bool sphere) {
    int cell[4] = {}, count = 1;
    float local[4] = {};
    for (int k = 0; k < dims; ++k) cell[k] = int(floorf(q[k])), local[k] = q[k] - cell[k], count *= 3;
    const auto vectorTo = [&](const int* offset, float* v) { // From the point to the cell's point
        int c[4] = {};
        float o[4];
        for (int k = 0; k < dims; ++k) c[k] = cell[k] + offset[k];
        site(c, dims, o);
        for (int k = 0; k < dims; ++k) v[k] = offset[k] + o[k] * randomness - local[k];
    };
    if (dims == 1 && !sphere) {
        float v[3];
        for (int i = -1; i <= 1; ++i) vectorTo(&i, v + i + 1);
        return fminf(fabsf((v[1] + v[0]) / 2), fabsf((v[1] + v[2]) / 2));
    }
    float best = 3.402823e38f, closest[4] = {};
    int offset[4] = {};
    for (int n = 0; n < count; ++n) {
        int c[4] = {};
        float v[4], d = 0;
        for (int k = 0, m = n; k < dims; ++k, m /= 3) c[k] = m % 3 - 1;
        vectorTo(c, v);
        for (int k = 0; k < dims; ++k) d += v[k] * v[k];
        if (d < best) {
            best = d;
            for (int k = 0; k < dims; ++k) closest[k] = v[k], offset[k] = c[k];
        }
    }
    best = 3.402823e38f;
    for (int n = 0; n < count; ++n) {
        int c[4] = {};
        float v[4], perpendicular = 0, along = 0;
        for (int k = 0, m = n; k < dims; ++k, m /= 3) c[k] = m % 3 - 1 + (sphere ? offset[k] : 0);
        if (sphere && n == (count - 1) / 2) continue; // The nearest other point to the closest
        vectorTo(c, v);
        for (int k = 0; k < dims; ++k) {
            const float e = v[k] - closest[k];
            perpendicular += e * e, along += (closest[k] + v[k]) / 2 * e;
        }
        if (sphere) best = fminf(best, perpendicular);
        else if (perpendicular > 0.0001f) best = fminf(best, along / sqrtf(perpendicular));
    }
    return sphere ? sqrtf(best) / 2 : best;
}
// Cycles' fractal of Voronoi octaves up to the detail, as of noise: the distance, color or position, the output in
// extra, normalized by the farthest distance unless zero; or the distance to edges, of fractal minima, or the n-sphere
// radius
__device__ __noinline__ float3 fractalVoronoi(float3 p, float3 kind, float3 extra, float3 fractal, float3 shape) {
    const float detail = fminf(fmaxf(fractal.x, 0), 15), roughness = fminf(fmaxf(fractal.y, 0), 1);
    const float rmd = detail - floorf(detail), randomness = fminf(fmaxf(extra.x, 0), 1);
    const float farthest = shape.x;
    const int dims = int(shape.z);
    float q[4] = {p.x, p.y, p.z, shape.y};
    if (kind.x == 4) return make_float3(1, 1, 1) * edge(q, dims, randomness, true);
    float amplitude = 1, total = 0, scale = 1;
    const auto scaled = [&](float s, float* r) { for (int k = 0; k < 4; ++k) r[k] = q[k] * s; };
    if (kind.x == 3) {
        float distance = 8;
        total = farthest;
        for (int i = 0; i <= ceilf(detail); ++i) {
            float r[4];
            scaled(scale, r);
            const float octave = edge(r, dims, randomness, false);
            if (detail == 0 || roughness == 0) {
                distance = octave;
                break;
            }
            const float weight = amplitude * (i <= detail ? 1 : rmd);
            total = total * (1 - weight) + farthest / scale * weight;
            distance = distance * (1 - weight) + fminf(distance, octave / scale) * weight;
            scale *= fractal.z;
            amplitude *= roughness;
        }
        return make_float3(1, 1, 1) * (farthest > 0 ? distance / total : distance);
    }
    Cell sum = {};
    for (int i = 0; i <= ceilf(detail); ++i) {
        float r[4];
        scaled(scale, r);
        const Cell octave = voronoi(r, dims, kind, extra);
        if (detail == 0 || roughness == 0) {
            total = 1;
            sum = octave;
            break;
        }
        const float weight = i <= detail ? 1 : rmd;
        total += amplitude * weight;
        sum.distance += octave.distance * amplitude * weight;
        sum.color = sum.color + octave.color * (amplitude * weight);
        for (int k = 0; k < 4; ++k)
            sum.position[k] = sum.position[k] * (1 - amplitude * weight) + octave.position[k] / scale * amplitude * weight;
        scale *= fractal.z;
        amplitude *= roughness;
    }
    if (farthest > 0) sum.distance /= total * farthest, sum.color = sum.color / total;
    return extra.z == 0 ? make_float3(1, 1, 1) * sum.distance : extra.z == 1 ? sum.color : extra.z == 2
        ? make_float3(sum.position[0], sum.position[1], sum.position[2]) : make_float3(1, 1, 1) * sum.position[3];
}
// Cycles' magic texture of a point by the scale, depth and distortion in params
__device__ float3 magic(float3 p, float3 params) {
    const float d = params.z;
    const auto sine = [](float a) { return sinpif(a * INV_PI); };
    const auto cosine = [](float a) { return cospif(a * INV_PI); };
    p = make_float3(fmodf(p.x * params.x, 2 * PI), fmodf(p.y * params.x, 2 * PI), fmodf(p.z * params.x, 2 * PI));
    float x = sine((p.x + p.y + p.z) * 5), y = cosine((-p.x + p.y - p.z) * 5), z = -cosine((-p.x - p.y + p.z) * 5);
    if (params.y > 0) x *= d, y *= d, z *= d;
    for (int i = 0; i < fminf(params.y, 10); ++i) switch (i) {
        case 0: y = -cosine(x - y + z) * d; break;
        case 1: x = cosine(x - y - z) * d; break;
        case 2: z = sine(-x - y - z) * d; break;
        case 3: x = -cosine(-x + y - z) * d; break;
        case 4: y = -sine(-x + y + z) * d; break;
        case 5: y = -cosine(-x + y + z) * d; break;
        case 6: x = cosine(x + y + z) * d; break;
        case 7: z = sine(x + y - z) * d; break;
        case 8: x = -cosine(-x - y + z) * d; break;
        default: y = -sine(x - y + z) * d; break;
    }
    return make_float3(0.5f, 0.5f, 0.5f) - make_float3(x, y, z) / (d != 0 ? 2 * d : 1);
}
// Cycles' brick texture of a point by the mortar's size and smoothness and the tint's bias in a, the bricks' width,
// rows' height and offset in b and the offset's frequency and the squash and its frequency in c: tint and mortar
__device__ float3 brick(float3 p, float3 a, float3 b, float3 c) {
    const int row = int(floorf(p.y / b.y)), offset_frequency = int(c.x), squash_frequency = int(c.z);
    float width = b.x, offset = 0;
    if (offset_frequency && squash_frequency) {
        width *= row % squash_frequency ? 1 : c.y;
        offset = row % offset_frequency ? 0 : width * b.z;
    }
    const int column = int(floorf((p.x + offset) / width));
    const float x = p.x + offset - width * column, y = p.y - b.y * row;
    unsigned n = ((row << 16) + (column & 0xFFFF) + 1013) & 0x7fffffff; // Cycles' integer noise of the brick
    n = (n >> 13) ^ n;
    const float noise = 0.5f * float((n * (n * n * 60493 + 19990303) + 1376312589) & 0x7fffffff) / 1073741824.0f;
    float distance = fminf(fminf(x, y), fminf(width - x, b.y - y)), mortar = distance < a.x;
    if (mortar && a.y != 0) {
        distance = fminf(fmaxf((1 - distance / a.x) / a.y, 0), 1);
        mortar = distance * distance * (3 - 2 * distance);
    }
    return make_float3(fminf(fmaxf(noise + a.z, 0), 1), mortar, 0);
}
// Cycles' weights of the samples of a box projected image along each axis of its object, the normal's there
__device__ float3 box(float3 n, float blend) {
    n = make_float3(fabsf(n.x), fabsf(n.y), fabsf(n.z)) / (fabsf(n.x) + fabsf(n.y) + fabsf(n.z));
    const float limit = 0.5f * (1 + blend);
    const auto ramp = [&](float a, float b) { return fminf(fmaxf((a / (a + b) - 0.5f * (1 - blend)) / blend, 0), 1); };
    if (n.x > limit * (n.x + n.y) && n.x > limit * (n.x + n.z)) return make_float3(1, 0, 0);
    if (n.y > limit * (n.x + n.y) && n.y > limit * (n.y + n.z)) return make_float3(0, 1, 0);
    if (n.z > limit * (n.x + n.z) && n.z > limit * (n.y + n.z)) return make_float3(0, 0, 1);
    if (blend <= 0) return make_float3(1, 0, 0);
    if (n.z < (1 - limit) * (n.y + n.x)) return make_float3(ramp(n.x, n.y), 1 - ramp(n.x, n.y), 0);
    if (n.x < (1 - limit) * (n.y + n.z)) return make_float3(0, ramp(n.y, n.z), 1 - ramp(n.y, n.z));
    if (n.y < (1 - limit) * (n.x + n.z)) return make_float3(ramp(n.x, n.z), 0, 1 - ramp(n.x, n.z));
    return (n * (2 - limit) + make_float3(1, 1, 1) * (limit - 1)) / (2 * limit - 1);
}
// Cycles' gradient of a lattice point of the dimensions picked by its hash, at the offset f from it
__device__ float gradient(unsigned h, const float* f, int dims) {
    if (dims == 1) return (h & 8 ? -1 : 1) * float(1 + (h & 7)) * f[0];
    if (dims == 2) return (h & 1 ? -1 : 1) * f[(h & 7) >= 4] + (h & 2 ? -2 : 2) * f[(h & 7) < 4];
    if (dims == 3) h &= 15;
    const float u = f[(h & 31) >= (dims == 3 ? 8 : 24)], v = dims == 3 ? f[h < 4 ? 1 : h == 12 || h == 14 ? 0 : 2]
        : f[(h & 31) < 16 ? 1 : 2], s = dims == 3 ? 0 : f[(h & 31) < 8 ? 2 : 3];
    return (h & 1 ? -u : u) + (h & 2 ? -v : v) + (h & 4 ? -s : s);
}
__device__ float fade(float t) { return t * t * t * (t * (t * 6 - 15) + 10); }
// Cycles' repetition of noise every 100000 on an axis against float precision, by half a cell past a million
__device__ float wrapped(float x) { return fmodf(x, 100000) + 0.5f * (fabsf(x) >= 1000000); }
// Cycles' signed Perlin noise of a point of the dimensions, of p's first and w as the fourth: its lattice's gradients
// blended by their faded distances
__device__ float noise(float3 p, float w, int dims) {
    p = make_float3(wrapped(p.x), wrapped(p.y), wrapped(p.z)), w = wrapped(w);
    if (dims == 3) {
        const float3 low = make_float3(floorf(p.x), floorf(p.y), floorf(p.z));
        float sum = 0;
        for (unsigned corner = 0; corner < 8; ++corner) {
            const float3 d = make_float3(corner & 1, corner >> 1 & 1, corner >> 2), f = p - low - d;
            const unsigned h = jenkins(3, int(low.x) + int(d.x), int(low.y) + int(d.y), int(low.z) + int(d.z)) & 15;
            const float u = h < 8 ? f.x : f.y, v = h < 4 ? f.y : h == 12 || h == 14 ? f.x : f.z;
            const float weight = (d.x ? fade(f.x + 1) : 1 - fade(f.x))
                * (d.y ? fade(f.y + 1) : 1 - fade(f.y)) * (d.z ? fade(f.z + 1) : 1 - fade(f.z));
            sum += weight * ((h & 1 ? -u : u) + (h & 2 ? -v : v));
        }
        return 0.9820f * sum;
    }
    const float q[4] = {p.x, p.y, p.z, w}, scales[4] = {0.25f, 0.6616f, 0.9820f, 0.8344f};
    float sum = 0;
    for (int corner = 0; corner < 1 << dims; ++corner) {
        float weight = 1, f[4];
        int x[4] = {};
        for (int k = 0; k < dims; ++k) {
            const int b = corner >> k & 1;
            x[k] = int(floorf(q[k])) + b, f[k] = q[k] - floorf(q[k]) - b;
            weight *= b ? fade(f[k] + 1) : 1 - fade(f[k]);
        }
        sum += weight * gradient(jenkins(dims, x[0], x[1], x[2], x[3]), f, dims);
    }
    return scales[dims - 1] * sum;
}
// Cycles' fractal noise of a point: octaves of noise up to the detail, the last by its fraction, by type of extra as
// fractal Brownian motion normalized or not, multifractal, heterogeneous terrain or hybrid or ridged multifractal
__device__ __noinline__ float fractal(float3 p, float3 params, float3 extra, float w, int dims) {
    const float detail = fminf(fmaxf(params.x, 0), 15), roughness = fmaxf(params.y, 0), lacunarity = params.z;
    const float offset = extra.x, gain = extra.y, rmd = detail - floorf(detail);
    const int octaves = int(detail), type = int(extra.z);
    if (type < 2) {
        float scale = 1, amp = 1, maxamp = 0, sum = 0;
        for (int i = 0; i <= octaves; ++i, amp *= roughness, scale *= lacunarity) {
            sum += noise(p * scale, w * scale, dims) * amp;
            maxamp += amp;
        }
        const float whole = type ? sum : 0.5f * sum / maxamp + 0.5f;
        if (rmd == 0) return whole;
        sum += noise(p * scale, w * scale, dims) * amp;
        return whole * (1 - rmd) + (type ? sum : 0.5f * sum / (maxamp + amp) + 0.5f) * rmd;
    }
    float value = 0, pwr = 1, weight = 1, signal;
    switch (type) {
        case 2:
            value = 1;
            for (int i = 0; i <= octaves; ++i, pwr *= roughness, p = p * lacunarity, w *= lacunarity)
                value *= pwr * noise(p, w, dims) + 1;
            return rmd != 0 ? value * (rmd * pwr * noise(p, w, dims) + 1) : value;
        case 3:
            value = offset + noise(p, w, dims);
            pwr = roughness;
            p = p * lacunarity, w *= lacunarity;
            for (int i = 1; i <= octaves; ++i, pwr *= roughness, p = p * lacunarity, w *= lacunarity)
                value += (noise(p, w, dims) + offset) * pwr * value;
            return rmd != 0 ? value + rmd * (noise(p, w, dims) + offset) * pwr * value : value;
        case 4:
            for (int i = 0; weight > 0.001f && i <= octaves; ++i, p = p * lacunarity, w *= lacunarity) {
                weight = fminf(weight, 1);
                signal = (noise(p, w, dims) + offset) * pwr;
                pwr *= roughness;
                value += weight * signal;
                weight *= gain * signal;
            }
            return rmd != 0 && weight > 0.001f ? value + rmd * fminf(weight, 1) * (noise(p, w, dims) + offset) * pwr
                : value;
        default:
            signal = offset - fabsf(noise(p, w, dims));
            value = signal *= signal;
            pwr = roughness;
            for (int i = 1; i <= octaves; ++i, pwr *= roughness) {
                p = p * lacunarity, w *= lacunarity;
                weight = fminf(fmaxf(signal * gain, 0), 1);
                signal = offset - fabsf(noise(p, w, dims));
                signal *= signal * weight;
                value += signal * pwr;
            }
            return value;
    }
}
// Cycles' cubic B-spline weights of the four texels around a point t past the second
__device__ float spline(float t, int k) {
    return k == 0 ? (1 - t) * (1 - t) * (1 - t) / 6 : k == 1 ? (t * t * (3 * t - 6) + 4) / 6
        : k == 2 ? (t * (t * (3 - 3 * t) + 3) + 1) / 6 : t * t * t / 6;
}
// Of the op's image by its extension: repeated, extended, clipped to none or mirrored; an RGBA8 image's bytes as the
// floats Blender reads them as, k / 255, those of sRGB colors decoded to linear
__device__ float4 texel(const Scene& scene, const Op& op, unsigned long long image, int x, int y) {
    const int width = op.width & 0xFFFFF, height = op.height & 0xFFFFFF, extension = op.height >> 24 & 3;
    if (extension == 2 && (x < 0 || x >= width || y < 0 || y >= height)) return make_float4(0, 0, 0, 0);
    if (extension == 1) x = min(max(x, 0), width - 1), y = min(max(y, 0), height - 1);
    // Repeated images wrap once, mirrored ones over an image and its reflection; extended and clipped are in range
    if (extension == 0) x = (x % width + width) % width, y = (y % height + height) % height;
    if (extension == 3)
        x = (x % (2 * width) + 2 * width) % (2 * width), y = (y % (2 * height) + 2 * height) % (2 * height),
        x = x < width ? x : 2 * width - 1 - x, y = y < height ? y : 2 * height - 1 - y;
    const float4* texels = (op.height >> 30 & 1 ? scene.bakeTexels : scene.texels) + op.texel; // Bit 30: only bakes'
    if ((op.height >> 26 & 3) != 1) // Floats, halves or 16-bit UNORM; bit 31: the read's texture, at the texel's center
        return op.height >> 31 ? tex2D<float4>(image, x + 0.5f, y + 0.5f) : texels[y * width + x];
    const uchar4 b = op.height >> 31 ? tex2D<uchar4>(image, x + 0.5f, y + 0.5f)
        : ((const uchar4*)texels)[y * width + x];
    const float level = 1.0f / 255;
    const float4 c = make_float4(b.x * level, b.y * level, b.z * level, b.w * level);
    return op.height >> 29 & 1 ? make_float4(decode(c.x), decode(c.y), decode(c.z), c.w) : c;
}
// The vector transformed from its object into the world or back, or from the world into the camera's space or back, by
// the mode: as a point, direction or normal of the object, of the world, then as a point or direction of the camera
// Inlined, as nvcc inlines it without the sheen's code, which OptiX folds away only after nvcc chose
__device__ __forceinline__ float3 transform(const Scene& scene, float3 v, int mode, const Info& info) {
    const float* a = info.axes;
    const float3 x = make_float3(a[0], a[1], a[2]), y = make_float3(a[3], a[4], a[5]);
    const float3 z = make_float3(a[6], a[7], a[8]);
    const float3 t = make_float3(info.location[0], info.location[1], info.location[2]);
    const Camera& c = scene.camera;
    const float3 r = normalize(c.x), u = normalize(c.y), f = normalize(cross(c.y, c.x));
    const float3 i = cross(y, z) / dot(x, cross(y, z)), j = cross(z, x) / dot(x, cross(y, z));
    const float3 k = cross(x, y) / dot(x, cross(y, z)); // The rows of the axes' inverse
    if (mode == 3) v = v - t;
    if (mode == 6) v = v - c.origin;
    switch (mode) {
        case 0: return x * v.x + y * v.y + z * v.z + t;
        case 1: return x * v.x + y * v.y + z * v.z;
        case 2: return normalize(i * v.x + j * v.y + k * v.z);
        case 3: case 4: return make_float3(dot(i, v), dot(j, v), dot(k, v));
        case 5: return normalize(make_float3(dot(x, v), dot(y, v), dot(z, v)));
        case 6: case 7: return make_float3(dot(r, v), dot(u, v), dot(f, v));
        case 8: return c.origin + r * v.x + u * v.y + f * v.z;
        default: return r * v.x + u * v.y + f * v.z;
    }
}
// Of a point shaded: its UV, generated point, point in its object, color, position, triangle barycentrics, triangle
// and instance
struct Point {
    float u, v; float3 generated, object; float4 color; float3 position; float s, t; unsigned triangle, instance;
};
__device__ Point shifted(const Scene& scene, const Point& point, const Ray& ray, int axis);
// Whether the scene's programs take the step: bound at compile time, OptiX compiles out the cases of steps they do not
__device__ bool used(unsigned code) {
    return params.ops[code >> 6] >> (code & 63) & 1;
}
#ifdef EXTENDED // Whether an instance holds strands, which only this PTX compiles
#define STRAND(scene, i) (scene.instances[i].world == STRANDS)
#else // Nor varying media and strands, in a PTX compiled without their code
#define used(code) (code != MEDIUM && code != CURVES && code != HAIR_INFO && code != HAIR && used(code))
#define STRAND(scene, i) false
#endif
#define CASE(code) case code: if (!used(code)) break;
// Surface a program resolves to at the point, facing along the normal with the tangent space tbn, seen from the
// incoming direction, on the back of its face or not, for the ray, of the info's object and the material's pass index;
// heights are bumped along its edges
// Inlined likewise
__device__ SHADE_INLINE Surface shade(const Scene& scene, unsigned program, float3 normal,
    SlangMatrix<float, 3, 3> tbn, const Point& point, float3 incoming, bool backfacing, const Ray& ray,
    const Info& info, float material = 0) {
    float u, v;
    float3 generated, object, position;
    float4 color;
    const auto at = [&](const Point& p) {
        u = p.u, v = p.v, generated = p.generated, object = p.object, color = p.color, position = p.position;
    };
    at(point);
    float3 stack[STACK], *top = stack, saved[SLOTS];
    for (const Op* op = scene.ops + program; op->code; ++op) switch (op->code) {
        CASE(PUSH) *top++ = op->value; break;
        CASE(STORE) saved[op->texel] = top[-1]; break;
        CASE(LOAD) *top++ = saved[op->texel]; break;
        CASE(SPECULAR) break;
        CASE(TRANSLUCENT) break;
        CASE(SHEEN) break;
        CASE(ANISOTROPIC) break;
        CASE(HAIR) top[-1] = normalize(transform(scene, tbn.rows[0], 1, info)) * top[-1].x; break; // Its fiber
        CASE(UV) *top++ = make_float3(u, v, 0); break;
        CASE(GENERATED) *top++ = generated; break;
        CASE(OBJECT) *top++ = object; break;
        CASE(TRANSFORM) --top; top[-1] = transform(scene, top[-1], int(top->x), info); break;
        case CAMERA_POINT: case WINDOW: { // In the camera's space, right, up and forward, or of its window, of the
            if (!used(CAMERA_POINT) && !used(WINDOW)) break;
            const Camera& c = scene.camera; // world along its direction from the camera, as Cycles'
            const float3 d = program == scene.materials[scene.count].program ? position : position - c.origin;
            const float3 forward = normalize(cross(c.y, c.x));
            const float3 q = c.lens.ortho ? d - c.z : d * (dot(c.z, forward) / dot(d, forward)) - c.z; // On its
            // image plane
            *top++ = op->code == CAMERA_POINT ? make_float3(dot(d, normalize(c.x)), dot(d, normalize(c.y)),
                dot(d, forward)) : make_float3(dot(q, c.x) / dot(c.x, c.x) + 1, dot(q, c.y) / dot(c.y, c.y) + 1, 0) / 2;
        } break;
        CASE(VERTEX_COLOR) *top++ = make_float3(color.x, color.y, color.z); break;
        CASE(VERTEX_ALPHA) *top++ = make_float3(1, 1, 1) * color.w; break;
        CASE(OBJECT_INFO) { // Its location, color, alpha, pass index, material's pass index or random number
            const int output = int(top[-1].x);
            top[-1] = output == 0 ? make_float3(info.location[0], info.location[1], info.location[2]) : output == 1
                ? make_float3(info.color[0], info.color[1], info.color[2]) : make_float3(1, 1, 1)
                * (output == 2 ? info.color[3] : output == 3 ? info.index : output == 4 ? material : info.random);
        } break;
#ifdef EXTENDED
        CASE(HAIR_INFO) { // Of the strand at the point, else none: whether one, its intercept, by its points from the
            const bool strand = STRAND(scene, point.instance); // root, or random
            const float4 root = strand ? scene.strands[3 * scene.segments[2 * point.triangle + 1]] : make_float4(0, 0, 0, 0);
            const float output = top[-1].x;
            top[-1] = make_float3(1, 1, 1) * (output == 5 ? root.z : !strand ? 0 : output == 0 ? 1 : output == 1
                ? (point.s + scene.segments[2 * point.triangle] - __float_as_uint(root.x)) / (__float_as_uint(root.y) - 1)
                : 0);
        } break;
#endif
        CASE(INSTANCER) { // An instancer attribute of its instance, its color or, odd, its alpha
            const int k = int(top[-1].x);
            const float4 v = scene.attributes[info.attributes + k / 2];
            top[-1] = k % 2 ? make_float3(1, 1, 1) * v.w : make_float3(v.x, v.y, v.z);
        } break;
        CASE(NORMAL) *top++ = normal; break;
        CASE(POSITION) *top++ = position; break;
        CASE(SHIFT) // Pushes its own point's index before the height there
            at(shifted(scene, point, ray, int(top[-1].x))); break;
        CASE(SHIFTED) --top; top[-1] = *top; at(point); break;
        CASE(BUMP) { // The normal bent by the height's gradient, as Cycles' bump node
            top -= 4;
            const float3 n = top[-1], dx = shifted(scene, point, ray, 1).position - position,
                dy = shifted(scene, point, ray, 2).position - position;
            const float3 rx = cross(dy, n), ry = cross(n, dx);
            const float det = dot(dx, rx);
            const float3 bent = n * fabsf(det) - ((top[1].x - top[0].x) * rx + (top[2].x - top[0].x) * ry)
                * (top[3].y * sign(det));
            top[-1] = dot(bent, bent) > 0 ? normalize(normalize(bent) * fmaxf(top[3].x, 0) + n * (1 - fmaxf(top[3].x,
                0))) : n;
        } break;
        CASE(INCOMING) *top++ = incoming; break;
        CASE(BACKFACING) *top++ = make_float3(1, 1, 1) * backfacing; break;
        CASE(LIGHT_PATH) top[-1] = make_float3(1, 1, 1) * lightPath(ray, int(top[-1].x)); break;
        CASE(BAKED) { // A bake's texels, halves, read linearly at the UV, extended at its edges or repeating
            const int width = op->width, height = op->height & 0xFFFFFF;
            const float x = top[-1].x * width - 0.5f, y = top[-1].y * height - 0.5f;
            const int i = int(floorf(x)), j = int(floorf(y));
            const auto edged = [&](int k, int n) { return op->height >> 29 & 1 ? (k % n + n) % n
                : min(max(k, 0), n - 1); };
            float3 c[4];
            for (int k = 0; k < 4; ++k) {
                const ushort4 h = ((const ushort4*)(scene.texels + op->texel))[edged(j + k / 2, height) * width
                    + edged(i + k % 2, width)];
                c[k] = make_float3(__half2float(__ushort_as_half(h.x)), __half2float(__ushort_as_half(h.y)),
                    __half2float(__ushort_as_half(h.z)));
            }
            top[-1] = mix(mix(c[0], c[1], x - i), mix(c[2], c[3], x - i), y - j);
        } break;
        case IMAGE: case ALPHA: case IMAGE_LINEAR: case ALPHA_LINEAR: case IMAGE_CUBIC: case ALPHA_CUBIC: { // Repeating
            if (!used(IMAGE) && !used(ALPHA) && !used(IMAGE_LINEAR) && !used(ALPHA_LINEAR) && !used(IMAGE_CUBIC)
                && !used(ALPHA_CUBIC)) break;
            const bool repeat = (op->height >> 24 & 3) == 0;
            const unsigned long long image = op->height >> 31 ? scene.images[2 * op->texel] : 0; // Its texture, once
            float x = (repeat ? wrap(top[-1].x) : top[-1].x) * (op->width & 0xFFFFF);
            float y = (repeat ? wrap(top[-1].y) : top[-1].y) * (op->height & 0xFFFFFF);
            float4 color;
            if (op->code == IMAGE || op->code == ALPHA)
                color = texel(scene, *op, image, int(floorf(x)), int(floorf(y)));
            if ((op->code == IMAGE_LINEAR || op->code == ALPHA_LINEAR) && op->height >> 31) // In hardware, by its
                color = tex2DLod<float4>(scene.images[2 * op->texel + 1], top[-1].x, top[-1].y, ray.width > 0 // at the
                    ? ray.level + log2f(float(op->width & 0xFFFFF) * (op->height & 0xFFFFFF)) / 2 // level of its cone,
                    + (int(op->width) >> 20) / 64.0f : 0); // its texels and the change of its point by the UVs
            else if (op->code == IMAGE_LINEAR || op->code == ALPHA_LINEAR) {
                x -= 0.5f; y -= 0.5f;
                const int i = int(floorf(x)), j = int(floorf(y));
                color = mix(mix(texel(scene, *op, image, i, j), texel(scene, *op, image, i + 1, j), x - i),
                    mix(texel(scene, *op, image, i, j + 1), texel(scene, *op, image, i + 1, j + 1), x - i), y - j);
            }
            if (op->code == IMAGE_CUBIC || op->code == ALPHA_CUBIC) {
                x -= 0.5f; y -= 0.5f;
                const int i = int(floorf(x)), j = int(floorf(y));
                color = make_float4(0, 0, 0, 0);
                for (int k = 0; k < 16; ++k) {
                    const float4 t = texel(scene, *op, image, i + k % 4 - 1, j + k / 4 - 1);
                    const float w = spline(x - i, k % 4) * spline(y - j, k / 4);
                    color = make_float4(color.x + t.x * w, color.y + t.y * w, color.z + t.z * w, color.w + t.w * w);
                }
            }
            top[-1] = op->code == IMAGE || op->code == IMAGE_LINEAR || op->code == IMAGE_CUBIC
                ? make_float3(color.x, color.y, color.z)
                : make_float3(1, 1, 1) * color.w;
        } break;
        CASE(NORMAL_MAP) {
            const float3 n = transform(scene, tangentToWorldNormalMap(top[-1] * 2 - make_float3(1, 1, 1), tbn), 2, info);
            top[-1] = isfinite(dot(n, n)) ? n : normal;
        } break;
        CASE(ADD) --top; top[-1] = top[-1] + *top; break;
        CASE(SUBTRACT) --top; top[-1] = top[-1] - *top; break;
        CASE(MULTIPLY) --top; top[-1] = top[-1] * *top; break;
        CASE(DOT_PRODUCT) --top; top[-1] = make_float3(1, 1, 1) * dot(top[-1], *top); break;
        CASE(MAXIMUM) --top;
            top[-1] = make_float3(fmaxf(top[-1].x, top->x), fmaxf(top[-1].y, top->y), fmaxf(top[-1].z, top->z));
            break;
        CASE(LOGARITHM) --top;
            top[-1] = make_float3(logarithm(top[-1].x, top->x), logarithm(top[-1].y, top->y),
                logarithm(top[-1].z, top->z));
            break;
        CASE(MULTIPLY_ADD) top -= 2; top[-1] = top[-1] * top[0] + top[1]; break;
        CASE(DIVIDE) --top; top[-1] = divide(top[-1], *top); break;
        CASE(SNAP) { --top;
            const float3 q = divide(top[-1], *top);
            top[-1] = make_float3(floorf(q.x) * top->x, floorf(q.y) * top->y, floorf(q.z) * top->z);
        } break;
        CASE(BOX) --top; top[-1] = box(top[-1], top->x); break;
        CASE(BRICK) top -= 3; top[-1] = brick(top[-1], top[0], top[1], top[2]); break;
        CASE(MAGIC) --top; top[-1] = magic(top[-1], *top); break;
        CASE(VORONOI) top -= 4; top[-1] = fractalVoronoi(top[-1], top[0], top[1], top[2], top[3]); break;
        CASE(WHITE_NOISE) --top; top[-1] = white(top[-1], int(top->x), top->y != 0, top->z); break;
        CASE(NOISE) top -= 3; top[-1] = make_float3(1, 1, 1) * fractal(top[-1], top[0], top[1], top[2].x, top[2].y);
            break;
        CASE(POWER) --top; top[-1] = each(top[-1], *top, power); break;
        CASE(EXPONENT) top[-1] = each(top[-1], [](float a) { return expf(a); }); break;
        CASE(MINIMUM) --top; top[-1] = each(top[-1], *top, [](float a, float b) { return fminf(a, b); }); break;
        CASE(LESS_THAN) --top; top[-1] = each(top[-1], *top, [](float a, float b) { return float(a < b); }); break;
        CASE(FLOOR) top[-1] = each(top[-1], [](float a) { return floorf(a); }); break;
        CASE(MODULO) --top; top[-1] = each(top[-1], *top, [](float a, float b) { return b != 0 ? fmodf(a, b) : 0; });
            break;
        // Reduced exactly, which fast math's sines are not
        CASE(SINE) top[-1] = each(top[-1], [](float a) { return sinpif(a * INV_PI); }); break;
        CASE(COSINE) top[-1] = each(top[-1], [](float a) { return cospif(a * INV_PI); }); break;
        CASE(TANGENT) top[-1] = each(top[-1], [](float a) { return sinpif(a * INV_PI) / cospif(a * INV_PI); }); break;
        CASE(ARCSINE) top[-1] = each(top[-1], [](float a) { return asinf(fminf(fmaxf(a, -1), 1)); }); break;
        CASE(ARCCOSINE) top[-1] = each(top[-1], [](float a) { return acosf(fminf(fmaxf(a, -1), 1)); }); break;
        CASE(ARCTANGENT) top[-1] = each(top[-1], [](float a) { return atanf(a); }); break;
        CASE(ARCTAN2) --top; top[-1] = each(top[-1], *top, [](float a, float b) { return atan2f(a, b); }); break;
        CASE(SINH) top[-1] = each(top[-1], [](float a) { return sinhf(a); }); break;
        CASE(COSH) top[-1] = each(top[-1], [](float a) { return coshf(a); }); break;
        CASE(TANH) top[-1] = each(top[-1], [](float a) { return tanhf(a); }); break;
        CASE(CROSS_PRODUCT) --top; top[-1] = cross(top[-1], *top); break;
        CASE(RGB_TO_HSV) top[-1] = toHsv(top[-1]); break;
        CASE(HSV_TO_RGB) top[-1] = fromHsv(top[-1]); break;
        CASE(RGB_TO_HSL) top[-1] = toHsl(top[-1]); break;
        CASE(HSL_TO_RGB) top[-1] = fromHsl(top[-1]); break;
        CASE(ROTATE) { // Around the unit axis by the angle, as Rodrigues'
            top -= 2;
            const float3 v = top[-1], k = top[0];
            const float c = cospif(top[1].x * INV_PI), s = sinpif(top[1].x * INV_PI);
            top[-1] = v * c + cross(k, v) * s + k * (dot(k, v) * (1 - c));
        } break;
        CASE(EQUIRECTANGULAR) { // Image coordinates of a direction, as Cycles'
            const float3 d = top[-1];
            top[-1] = make_float3(0.5f - atan2f(d.y, d.x) / (2 * PI),
                0.5f + atan2f(d.z, sqrtf(d.x * d.x + d.y * d.y)) / PI, 0);
        } break;
        CASE(MIRROR_BALL) { // Image coordinates of a direction on a mirror ball, as Cycles'
            float3 d = top[-1] / (length(top[-1]) > 0 ? length(top[-1]) : 1) - make_float3(0, 1, 0);
            d = d / (d.y < 0 ? 2 * sqrtf(-0.5f * d.y) : 1);
            top[-1] = make_float3(0.5f * (d.x + 1), 0.5f * (d.z + 1), 0);
        } break;
        CASE(DIELECTRIC) --top; top[-1] = make_float3(1, 1, 1) * fresnel(fabsf(top[-1].x), 1, top->x); break;
    }
    return {normalize(stack[0]), stack[1], stack[2].x, stack[3].x, stack[4], stack[5].x, stack[6].x, stack[7],
        stack[8].x, stack[9].x, stack[10], stack[11].x, stack[12],
        used(TRANSLUCENT) && top - stack > 13 ? stack[13] : make_float3(0, 0, 0),
        used(SHEEN) && top - stack > 15 ? stack[14] : make_float3(0, 0, 0),
        used(SHEEN) && top - stack > 15 ? stack[15].x : 0.5f, used(ANISOTROPIC) && top - stack > 18 ? stack[16].x : 0,
        used(ANISOTROPIC) && top - stack > 18 ? stack[17].x : 0,
        used(ANISOTROPIC) && top - stack > 18 ? stack[18] : make_float3(0, 0, 0),
        used(MEDIUM) && top - stack > 19 ? stack[19] : make_float3(0, 0, 0),
        used(HAIR) && top - stack > 20 ? stack[20] : make_float3(0, 0, 0)};
}
// Object-space MikkTSpace frame interpolated at the triangle's barycentrics, as Cycles'
__device__ SlangMatrix<float, 3, 3> tangentSpace(const float4* p, float3 n, float s, float t) {
    const float3 a = make_float3(p[0].x, p[0].y, p[0].z), b = make_float3(p[1].x, p[1].y, p[1].z);
    const float3 tangent = a + (b - a) * s + (make_float3(p[2].x, p[2].y, p[2].z) - a) * t;
    return makeMatrix<float, 3, 3>(tangent, cross(n, tangent) * p[0].w, n);
}
__device__ float3 place(const Instance& instance, float3 p) { // Through the instance's transform
    const float* m = instance.matrix;
    return make_float3(m[0] * p.x + m[1] * p.y + m[2] * p.z + m[3], m[4] * p.x + m[5] * p.y + m[6] * p.z + m[7],
        m[8] * p.x + m[9] * p.y + m[10] * p.z + m[11]);
}
__device__ float3 turn(const Instance& instance, float3 n) { // Through the instance's adjugate, normalized
    const float* a = instance.adjugate;
    return normalize(make_float3(n.x * a[0] + n.y * a[3] + n.z * a[6], n.x * a[1] + n.y * a[4] + n.z * a[7],
        n.x * a[2] + n.y * a[5] + n.z * a[8]));
}
// In its object's space, of a corner of an instance's mesh: its normal, mirrored where the transform mirrors faces, or
// one of a mesh in world space turned there
__device__ float3 objectNormal(const Scene& scene, const Instance& instance, float3 n) {
    const float* m = instance.matrix, * a = instance.adjugate;
    return instance.world ? transform(scene, n, 5, instance.info) : n * sign(m[0] * a[0] + m[1] * a[3] + m[2] * a[6]);
}
// Of a triangle of an instance, from the vertices and normals of the meshes: its corners and normals in the world, each
// read where taken, a point placed by the instance, a normal turned; a point at barycentrics and the face's unit normal
// taken from the mesh's through the instance once
struct Corners {
    const float3* p; const Instance& instance; bool normal;
    __device__ float3 operator[](int k) const { return normal ? turn(instance, p[k]) : place(instance, p[k]); }
    __device__ float3 at(float s, float t) const {
        return place(instance, p[0] + (p[1] - p[0]) * s + (p[2] - p[0]) * t);
    }
    __device__ float3 face() const { return turn(instance, cross(p[1] - p[0], p[2] - p[0])); }
};
__device__ Corners corners(const float3* vertices, const Instance& instance, unsigned triangle) {
    return {vertices + 3 * triangle, instance, false};
}
__device__ Corners cornerNormals(const float3* normals, const Instance& instance, unsigned triangle) {
    return {normals + 3 * triangle, instance, true};
}
// Instance of a triangle by its number in the scene's order: the last one numbered no higher, by bisection
__device__ unsigned owner(const Scene& scene, unsigned number) {
    unsigned low = 0, high = scene.instanceCount;
    while (high - low > 1) {
        const unsigned middle = (low + high) / 2;
        (scene.instances[middle].key <= number ? low : high) = middle;
    }
    return low;
}
// Number in the scene's order of a triangle of an instance, which its material and trail and skipping it go by, and the
// triangle of an instance a number names
__device__ unsigned key(const Scene& scene, unsigned instance, unsigned triangle) {
    return scene.instances[instance].key + triangle - scene.instances[instance].first;
}
__device__ unsigned key(const Scene& scene, Hit hit) { return key(scene, hit.instance, hit.triangle); }
__device__ Hit owned(const Scene& scene, unsigned key) {
    const unsigned instance = owner(scene, key);
    return {scene.instances[instance].first + key - scene.instances[instance].key, instance};
}
// Of a triangle of an instance at its barycentrics
__device__ Point at(const Scene& scene, unsigned instance, unsigned triangle, float s, float t) {
    const float2* uv = scene.uvs + 3 * triangle;
    const Corners vertex = corners(scene.vertices, scene.instances[instance], triangle);
    const float3* generated = scene.generated + 3 * triangle;
    const float3* object = scene.objects + 3 * triangle;
    const float4* color = scene.colors + 3 * triangle;
    return {uv[0].x + (uv[1].x - uv[0].x) * s + (uv[2].x - uv[0].x) * t,
        uv[0].y + (uv[1].y - uv[0].y) * s + (uv[2].y - uv[0].y) * t,
        generated[0] + (generated[1] - generated[0]) * s + (generated[2] - generated[0]) * t,
        object[0] + (object[1] - object[0]) * s + (object[2] - object[0]) * t,
        make_float4(color[0].x + (color[1].x - color[0].x) * s + (color[2].x - color[0].x) * t,
            color[0].y + (color[1].y - color[0].y) * s + (color[2].y - color[0].y) * t,
            color[0].z + (color[1].z - color[0].z) * s + (color[2].z - color[0].z) * t,
            color[0].w + (color[1].w - color[0].w) * s + (color[2].w - color[0].w) * t),
        vertex.at(s, t), s, t, triangle, instance};
}
// Along an edge only when a bump program asks for its height or position; the world's point stays fixed
#ifdef EXTENDED
// Of a strand's segment at its axis parameter and its normal's polar angles, as hit: its point, normal and axis'
// direction, in its object
__device__ float3 strandPoint(const Scene& scene, unsigned segment, float2 uv, float3& n, float3& along) {
    const unsigned code = __float_as_uint(uv.y), p = scene.segments[2 * segment];
    const float theta = (code >> 16) * (PI / 65535), phi = ((code & 65535) / 65535.0f - 0.5f) * (2 * PI);
    const float4 a = scene.points[p], b = scene.points[p + 1];
    n = make_float3(sinf(theta) * cosf(phi), sinf(theta) * sinf(phi), cosf(theta));
    along = normalize(make_float3(b.x - a.x, b.y - a.y, b.z - a.z));
    return make_float3(a.x + (b.x - a.x) * uv.x, a.y + (b.y - a.y) * uv.x, a.z + (b.z - a.z) * uv.x)
        + n * (a.w + (b.w - a.w) * uv.x);
}
#endif
__device__ Point shifted(const Scene& scene, const Point& point, const Ray& ray, int axis) {
    if (point.triangle == NONE) return point;
    if (STRAND(scene, point.instance)) return point; // No bump along a strand
    const Corners vertex = corners(scene.vertices, scene.instances[point.instance], point.triangle);
    const float step = 1e-4f * fmaxf(ray.length, 1e-3f);
    return at(scene, point.instance, point.triangle,
        axis == 1 ? point.s + step / length(vertex[1] - vertex[0]) : point.s,
        axis == 2 ? point.t + step / length(vertex[2] - vertex[0]) : point.t);
}
// Of a triangle of an instance at its barycentrics, reached along the direction by the ray, in a layer of its material,
// bumped by points along its edges as near as the ray's length makes a pixel's; inlined likewise
__device__ __forceinline__ Surface shade(const Scene& scene, unsigned instance, unsigned triangle, float s, float t,
    float3 normal, float3 direction, const Ray& ray, unsigned layer = 0, bool emission = false) {
    const Material& material = scene.materials[key(scene, instance, triangle)];
    unsigned program = emission ? material.emission : material.program;
    // Each layer's program follows the end of the one above it
    while (layer) layer -= scene.ops[program++].code == END;
#ifdef EXTENDED
    if (STRAND(scene, instance)) { // A strand's segment, its frame along its axis and normal
        const Instance& placed = scene.instances[instance];
        float3 n, along;
        const float3 o = strandPoint(scene, triangle, make_float2(s, t), n, along);
        const float4* root = scene.strands + 3 * scene.segments[2 * triangle + 1]; // Its UV and color, and generated
        const float* space = placed.texspace; // point by its emitter's texture space
        return shade(scene, program, normal, makeMatrix<float, 3, 3>(along, cross(n, along), n), Point{root[1].x,
            root[1].y, make_float3((o.x - space[0]) / (2 * space[3]) + 0.5f, (o.y - space[1]) / (2 * space[4]) + 0.5f,
            (o.z - space[2]) / (2 * space[5]) + 0.5f), o, root[2], place(placed, o), s, t, triangle, instance},
            -direction, false, ray, placed.info);
    }
#endif
    const Corners vertex = corners(scene.vertices, scene.instances[instance], triangle);
    const float3* normals = scene.normals + 3 * triangle;
    const Info& object = scene.instances[instance].info;
    const float3 a = objectNormal(scene, vertex.instance, normals[0]);
    const float3 b = objectNormal(scene, vertex.instance, normals[1]);
    const float3 c = objectNormal(scene, vertex.instance, normals[2]);
    // Its cone's footprint over the hit's UVs, of the area the triangle's UVs span per area of its own (Akenine-Moller
    // et al. 2019, ray cones), its width the geometric mean of the axes it spans on the surface, by which reads pick a
    // level, of CONE_SHARE of that width
    const float2* uv = scene.uvs + 3 * triangle;
    const float3 face = cross(vertex[1] - vertex[0], vertex[2] - vertex[0]);
    Ray cone = ray;
    cone.level = log2f(ray.width * CONE_SHARE * sqrtf(fabsf(((uv[1].x - uv[0].x) * (uv[2].y - uv[0].y)
        - (uv[2].x - uv[0].x) * (uv[1].y - uv[0].y)) / dot(face, direction))));
    return shade(scene, program, normal,
        tangentSpace(scene.tangents + 3 * triangle, normalize(a + (b - a) * s + (c - a) * t), s, t),
        at(scene, instance, triangle, s, t), -direction,
        dot(vertex.face(), direction) > 0, cone, object, scene.passes[triangle]);
}

// ReSTIR PT Enhanced (Lin, Kettunen and Wyman 2026) on top of the path tracing of walk below.
// Paths live in primary sample space, vertex b draws its random numbers from stream(seed, b).

// How a path ends: next event estimation, emissive surface or environment
constexpr unsigned END_NEE = 0u;
constexpr unsigned END_EMIT = 1u;
constexpr unsigned END_ENV = 2u;

// Reconnection vertex: none (pure random replay), triangle hit, NEE light vertex or environment direction
constexpr unsigned RC_NONE = 0u;
constexpr unsigned RC_SURFACE = 1u;
constexpr unsigned RC_LIGHT = 2u;
constexpr unsigned RC_ENV = 3u;

// Bit offsets of the packed path description
constexpr unsigned PATH_END = 0u;
constexpr unsigned PATH_K = 5u;
constexpr unsigned PATH_RC = 10u;
constexpr unsigned PATH_TYPE = 12u;
constexpr unsigned PATH_LOBE_PREV = 15u;
constexpr unsigned PATH_LOBE = 17u;
constexpr unsigned PATH_NEE = 19u;

// Random streams besides the per vertex ones
constexpr unsigned STREAM_NEE = 64u;
constexpr unsigned STREAM_RR = 128u;
constexpr unsigned STREAM_JITTER = 192u;
constexpr unsigned STREAM_SELECT = 193u;
constexpr unsigned STREAM_COVERAGE = 256u;
constexpr unsigned STREAM_MEDIUM = 320u;
constexpr unsigned STREAM_CAMERA = 384u;  // Of what the medium the camera is in absorbs to the first hit

// Camera and primary hit of a pixel
struct Domain {
    float3 x0;
    float3 x1;
    Hit hit;
    float width, spread;
};

__device__ unsigned extractBits(unsigned path, unsigned offset, unsigned count) {
    return path >> offset & ((1u << count) - 1u);
}

// Nearest hit of a ray within far and its distance, NONE on a miss
// Of a ray leaving the skipped triangle, if any, from where it hit it, as Cycles skips it, starting back by the
// distance it otherwise starts after to keep triangles there; a ray then passing a triangle hit there skips none.
// Rays start after near, a surface's margin from where they leave it; a medium's vertex, on none, has none. Not
// near - back: Slang folds that to -back, a -0 that Vulkan's ray queries meet nothing past
constexpr float MARGIN = 1e-4f;  // A surface's, rays leaving it start past
__device__ Hit traverse(const Scene& scene, float3 origin, float3 direction, float far, float& distance,
    unsigned skip = NONE, float near = MARGIN) {
    const float back = skip == NONE ? 0 : near;
    unsigned layer = __float_as_uint(-INFINITY);
    // Traverse only; hit data is read from the hit object below.
    optixTraverse(scene.handle, origin - direction * back, direction, skip == NONE ? near : 0, far + back, 0.0f, 255,
        skip == NONE ? OPTIX_RAY_FLAG_DISABLE_ANYHIT : OPTIX_RAY_FLAG_NONE, 0, 1, 0, skip, layer);
    if (!optixHitObjectIsHit()) return {NONE};
    distance = optixHitObjectGetRayTmax() - back;
    // Barycentrics from the first two attributes; optixHitObjectGetTriangleBarycentrics returns zeros here.
    const unsigned instance = optixHitObjectGetInstanceIndex(), triangle = optixHitObjectGetPrimitiveIndex();
    return {scene.instances[instance].first + triangle, instance,
        make_float2(__uint_as_float(optixHitObjectGetAttribute_0()), __uint_as_float(optixHitObjectGetAttribute_1()))};
}

// Next layer along the ray from origin within far past the triangle after at distance at, by distance, then index, so
// that a loop over layers meets each once and ends; at becomes its distance. Traversal's bounds keep a few ulps of
// slack, the order is the any-hit program's alone: the nearest hit past the layer, traversal culling beyond it, then of
// the hits at exactly its distance the lowest index past the layer, every candidate skipped
__device__ Hit nextLayer(const Scene& scene, float3 origin, float3 direction, float far, float& at, unsigned after) {
    unsigned layer = __float_as_uint(at), gather = __float_as_uint(INFINITY), index = NONE, u, v, instance;
    optixTraverse(scene.handle, origin, direction, at * (1 - 4.76837158203125e-7f), far, 0.0f, 255, OPTIX_RAY_FLAG_NONE,
        0, 1, 0, after, layer, gather, index, u, v, instance);
    if (!optixHitObjectIsHit()) return {NONE};
    at = optixHitObjectGetRayTmax(), gather = __float_as_uint(at);
    optixTraverse(scene.handle, origin, direction, at * (1 - 4.76837158203125e-7f), at * (1 + 4.76837158203125e-7f), 0.0f,
        255, OPTIX_RAY_FLAG_NONE, 0, 1, 0, after, layer, gather, index, u, v, instance);
    if (index == NONE) return {NONE};
    return {scene.instances[instance].first + index - scene.instances[instance].key, instance,
        make_float2(__uint_as_float(u), __uint_as_float(v))};
}

#ifdef EXTENDED
// Of the strands' hit group, as main.cpp's record: the scene's instances, segments and points
struct HitData { const Instance* instances; const unsigned* segments; const float4* points; };
// Nearest hit before t past lo of a ray in an object's space and a segment of its strands, between points a and b:
// Roth's union of their spheres and the cone tangent to both, every root of each taken (Roth 1982, Max 1990); its axis
// parameter and its normal's polar angles, in 16 bits each
__device__ bool strand(float3 o, float3 d, float4 a, float4 b, float lo, float& t, float2& uv) {
    const float3 e = make_float3(a.x, a.y, a.z), axis = make_float3(b.x, b.y, b.z) - e, w = normalize(axis);
    const float s = dot(e + axis * 0.5f - o, d) / dot(d, d); // Measured from beside the segment, where float
    o = o + d * s, lo -= s, t -= s; // resolves a thin strand's silhouette; its distance then from the ray's origin
    const float length2 = dot(axis, axis), k = (a.w - b.w) / sqrtf(length2), c = sqrtf(fmaxf(1 - k * k, 0.0f)), t0 = t;
    float3 n;
    for (int end = 0; end < 2; ++end) { // Each sphere
        const float3 center = end ? make_float3(b.x, b.y, b.z) : e, oc = o - center;
        const float r = end ? b.w : a.w, q = dot(oc, d), h = q * q - dot(d, d) * (dot(oc, oc) - r * r);
        for (float sign : {-1.0f, 1.0f}) if (const float root = (-q + sign * sqrtf(h)) / dot(d, d); h >= 0 && root > lo
            && root < t) t = root, n = (o + d * root - center) / r;
    }
    const float3 oa = o - e, dp = d - w * dot(d, w), op = oa - w * dot(oa, w); // The cone, where the radius at height y
    const float m = k / fmaxf(c, 1e-6f), r0 = a.w / fmaxf(c, 1e-6f) - dot(oa, w) * m; // along the axis is r0 - y m
    const float qa = dot(dp, dp) - dot(d, w) * dot(d, w) * m * m, qb = dot(op, dp) + r0 * dot(d, w) * m;
    const float h = qb * qb - qa * (dot(op, op) - r0 * r0);
    for (float sign : {-1.0f, 1.0f}) if (const float root = (-qb + sign * sqrtf(h)) / qa, y = dot(oa + d * root, w);
        h >= 0 && c > 0 && root > lo && root < t && y >= a.w * k && y <= sqrtf(length2) + b.w * k && r0 - root
        * dot(d, w) * m >= 0) t = root, n = normalize(oa + d * root - w * y) * c + w * k; // Between its tangent circles
    if (!(t < t0)) { t += s; return false; }
    uv = make_float2(fminf(fmaxf(dot(o + d * t - e, axis) / length2, 0.0f), 1.0f), __uint_as_float(unsigned(acosf(
        fminf(fmaxf(n.z, -1.0f), 1.0f)) / PI * 65535.0f + 0.5f) << 16 | unsigned((atan2f(n.y, n.x) / (2 * PI) + 0.5f)
        * 65535.0f + 0.5f)));
    t += s;
    return true;
}
extern "C" __global__ void __intersection__strand() {
    const HitData& data = *(const HitData*)optixGetSbtDataPointer();
    const unsigned segment = data.instances[optixGetInstanceIndex()].first + optixGetPrimitiveIndex();
    const unsigned point = data.segments[2 * segment];
    float t = optixGetRayTmax();
    float2 uv;
    if (strand(optixGetObjectRayOrigin(), optixGetObjectRayDirection(), data.points[point], data.points[point + 1],
        optixGetRayTmin(), t, uv)) optixReportIntersection(t, 0, __float_as_uint(uv.x), __float_as_uint(uv.y));
}
#endif
// Rays skip the triangle of payload 0. Rays past a layer, of it at the distance of payload 1, skip the triangles before
// it by distance, then number; gathering at the distance of payload 2, they skip every candidate, keeping the lowest
// number there, its barycentrics and its instance in payloads 3 to 6. Triangles go by their numbers in the scene's
// order, each instance's id its first's; a strand's segment also skips the segments next to it in its strand
extern "C" __global__ void __anyhit__skip() {
    const unsigned triangle = optixGetInstanceId() + optixGetPrimitiveIndex(), skip = optixGetPayload_0();
#ifdef EXTENDED
    if (optixGetPrimitiveType() == OPTIX_PRIMITIVE_TYPE_CUSTOM) {
        const HitData& data = *(const HitData*)optixGetSbtDataPointer();
        const Instance& instance = data.instances[optixGetInstanceIndex()];
        const unsigned* at = data.segments + 2 * (instance.first + optixGetPrimitiveIndex());
        const unsigned other = skip - instance.key;
        if (other < instance.count && data.segments[2 * (instance.first + other) + 1] == at[1]
            && data.segments[2 * (instance.first + other)] - at[0] + 1 <= 2) optixIgnoreIntersection();
    }
#endif
    const float at = __uint_as_float(optixGetPayload_1());
    if (at == -INFINITY) {
        if (triangle == skip) optixIgnoreIntersection();
        return;
    }
    const float t = optixGetRayTmax(), gather = __uint_as_float(optixGetPayload_2());
    if (!(t > at || (t == at && triangle > skip)))
        optixIgnoreIntersection();
    else if (gather != INFINITY) {
        if (t == gather && triangle < optixGetPayload_3())
            optixSetPayload_3(triangle), optixSetPayload_4(optixGetAttribute_0()),
                optixSetPayload_5(optixGetAttribute_1()), optixSetPayload_6(optixGetInstanceIndex());
        optixIgnoreIntersection();
    }
}

__device__ float3 hitPosition(const Scene& scene, const float3* vertices, Hit hit) { // Of those vertices
#ifdef EXTENDED
    float3 n, along;
    if (STRAND(scene, hit.instance))
        return place(scene.instances[hit.instance], strandPoint(scene, hit.triangle, hit.uv, n, along));
#endif
    return corners(vertices, scene.instances[hit.instance], hit.triangle).at(hit.uv.x, hit.uv.y);
}

__device__ float3 faceNormal(const Scene& scene, unsigned instance, unsigned triangle) {
    return corners(scene.vertices, scene.instances[instance], triangle).face();
}

// Of a hit, a strand's as smooth
__device__ float3 faceNormal(const Scene& scene, Hit hit) {
#ifdef EXTENDED
    float3 n, along;
    if (STRAND(scene, hit.instance))
        return strandPoint(scene, hit.triangle, hit.uv, n, along), turn(scene.instances[hit.instance], n);
#endif
    return faceNormal(scene, hit.instance, hit.triangle);
}

__device__ float3 smoothNormal(const Scene& scene, Hit hit) {
    if (STRAND(scene, hit.instance)) return faceNormal(scene, hit);
    const Corners normals = cornerNormals(scene.normals, scene.instances[hit.instance], hit.triangle);
    return normalize(normals[0] * (1 - hit.uv.x - hit.uv.y) + normals[1] * hit.uv.x + normals[2] * hit.uv.y);
}

// Of surfaces transmitting light, the distance along the smooth normal rays leave a hit at position from, of its
// triangle, as FlexKernels shares it
__device__ float geometryOffset(const Scene& scene, Hit hit, float3 face, float3 position) {
    if (STRAND(scene, hit.instance)) return 0; // Rays leaving a strand skip its segments there
    const Corners vertex = corners(scene.vertices, scene.instances[hit.instance], hit.triangle);
    const Corners normal = cornerNormals(scene.normals, scene.instances[hit.instance], hit.triangle);
    return geometryOffset(vertex[0], vertex[1], vertex[2], normal[0], normal[1], normal[2], face,
        make_float3(1 - hit.uv.x - hit.uv.y, hit.uv.x, hit.uv.y), position);
}
// Point offset along the unit normal from origin, or origin where rays from there would skip what lies in between
__device__ float3 tracedLift(const Scene& scene, float3 origin, float3 normal, float offset) {
    float distance;
    return traverse(scene, origin, normal, offset, distance).triangle == NONE ? origin + normal * offset : origin;
}
// Of position, its distances under the hit's corner tangent planes by barycentrics: the Phong tessellation point's
// offset, sum of b_i dot(v_i - p, n_i) n_i, without its factors n_i.n_face, for which lift's one n_face.n_s stands, the
// same to first order in the normals' tilt; at most an eighth of the shortest edge, none where normals are the face's
__device__ float smoothHeight(const Scene& scene, Hit hit, float3 position) {
    const Corners vertex = corners(scene.vertices, scene.instances[hit.instance], hit.triangle);
    const Corners normal = cornerNormals(scene.normals, scene.instances[hit.instance], hit.triangle);
    const float height = (1 - hit.uv.x - hit.uv.y) * dot(vertex[0] - position, normalize(normal[0]))
        + hit.uv.x * dot(vertex[1] - position, normalize(normal[1]))
        + hit.uv.y * dot(vertex[2] - position, normalize(normal[2]));
    return fminf(fmaxf(height, 0.0f), fminf(length(vertex[1] - vertex[0]), fminf(length(vertex[2] - vertex[0]),
        length(vertex[2] - vertex[1]))) * 0.125f);
}

// Whether a direction leaves a face to the other side than reflecting or refracting the incoming direction does
__device__ bool wrongSide(float3 in_dir, bool refracted, float3 out_dir, float3 face) {
    return (dot(in_dir, face) < 0 != refracted) != (dot(out_dir, face) > 0);
}

// Uniform point of the circular or polygonal aperture, squeezed horizontally as in Cycles.
__device__ float2 aperture(const Lens& lens, unsigned state) {
    float angle = 2 * PI * random(state), radius = lens.aperture * sqrtf(random(state)), x = radius, y = 0;
    if (lens.blades >= 3) {
        const float sector = angle * lens.blades / (2 * PI), half = PI / lens.blades;
        x = radius * cosf(half), y = radius * (2 * (sector - floorf(sector)) - 1) * sinf(half);
        angle = 2 * half * floorf(sector) + lens.rotation;
    }
    return make_float2((x * cosf(angle) - y * sinf(angle)) / lens.ratio, x * sinf(angle) + y * cosf(angle));
}

// Camera and primary hit through the pixel jitter and lens point its seed draws, both replayed when ReSTIR shifts a
// sample; hidden surfaces let camera rays through. On a miss x1 is one along the ray.
__device__ Domain pixelDomain(const Scene& scene, const Camera& camera, int pixel, uint3 size, unsigned seed) {
    unsigned state = stream(seed, STREAM_JITTER);
    const float x = pixel % size.x + random(state);
    const float y = pixel / size.x + random(state);
    const float3 plane = camera.x * (2 * x / size.x - 1) + camera.y * (1 - 2 * y / size.y) + camera.z;
    float3 direction = camera.lens.ortho ? normalize(cross(camera.y, camera.x)) : normalize(plane);
    float3 origin = camera.lens.ortho ? camera.origin + plane : camera.origin;
    if (camera.lens.aperture > 0) {
        const float2 point = aperture(camera.lens, state);
        const float3 offset = normalize(camera.x) * point.x + normalize(camera.y) * point.y;
        const float3 forward = normalize(cross(camera.y, camera.x));
        direction = normalize(direction * (camera.lens.focus / dot(direction, forward)) - offset);
        origin = origin + offset;
    }
    const float along = dot(direction, normalize(cross(camera.y, camera.x))); // Clipped: from the near plane to the far
    origin = origin + direction * (camera.lens.near / along);
    float reach = (camera.lens.far - camera.lens.near) / along;
    const float3 start = origin;
    float at = 0;
    Hit hit = traverse(scene, origin, direction, reach, at);
    // Past hidden surfaces layer by layer, by distance then index, so that each is met once and the loop ends; a hidden
    // first hit starts the layers over an ulp short of it, from the lowest index there, in the one call it shares with
    // the layers after, which Vulkan's shader holds once per caller
    for (bool first = true; hit.triangle != NONE && scene.materials[key(scene, hit)].hidden != 0; first = false) {
        if (first) at = __uint_as_float(__float_as_uint(at) - 1);
        hit = nextLayer(scene, origin, direction, reach, at, first ? NONE : key(scene, hit));
    }
    // A pixel's cone: from the lens a point spreading by the angle the pixel spans, orthographic a pixel wide
    const float across = 2 * length(camera.x) / size.x;
    return {start, hit.triangle == NONE ? start + direction : hitPosition(scene, scene.vertices, hit), hit,
        camera.lens.ortho ? across : 0, camera.lens.ortho ? 0 : across / length(plane)};
}

// World: equirectangular texture along the direction
__device__ float3 environment(const Scene& scene, float3 direction, const Ray& ray) {
    const Point point = {0.5f - atan2f(direction.y, direction.x) / (2 * PI),
        0.5f + atan2f(direction.z, sqrtf(direction.x * direction.x + direction.y * direction.y)) / PI, direction,
        direction, make_float4(0, 0, 0, 0), direction, 0, 0, NONE};
    return shade(scene, scene.materials[scene.count].program, direction, SlangMatrix<float, 3, 3>{}, point, -direction,
        false, ray, Info{{}, {}, 0, 0, 0, {1, 0, 0, 0, 1, 0, 0, 0, 1}}).emissive;
}

__device__ float3 exponential(float3 a) { return make_float3(expf(a.x), expf(a.y), expf(a.z)); }
// Scattering and extinction coefficients of a homogeneous medium, none by default; of one varying from point to point,
// those where it was entered, carried beside the key of its material, whose owner is the instance it fills, else NONE
struct Medium { float3 scatter, extinction; };
// Of the volume filling the inside of a surface, behind its faces
__device__ Medium volume(const Surface& surface) {
    return {surface.scatter * surface.density,
        (surface.scatter + make_float3(1, 1, 1) - surface.absorption) * surface.density};
}
// Of the volume behind a face of an instance's triangle: of one varying, its material's key, else NONE
__device__ unsigned fills(const Scene& scene, unsigned instance, unsigned triangle) {
    return used(MEDIUM) && scene.instances[instance].majorant != 0 ? key(scene, instance, triangle) : NONE;
}
// Whether a face of an instance bounds a volume: where it is shaded dense, or always of one varying, which may be clear
// right at its faces and dense within
__device__ bool encloses(const Scene& scene, const Surface& surface, unsigned instance) {
    return surface.density > 0 || used(MEDIUM) && scene.instances[instance].majorant != 0;
}
// Of a varying medium, its coefficients at a point inside, seen along the direction, by its material's volume there: at
// the point in its object, the instance's transform undone, and the generated point its mesh's texture space makes it
__device__ Medium inside(const Scene& scene, unsigned material, float3 p, float3 direction, const Ray& ray,
    float3& glow) {
    const unsigned filled = owner(scene, material);
    const Instance& instance = scene.instances[filled];
    const float* space = instance.texspace;
    const float3 o = transform(scene, p, 3, instance.info);
    const Point point{0, 0, make_float3((o.x - space[0]) / (2 * space[3]) + 0.5f, (o.y - space[1]) / (2 * space[4])
        + 0.5f, (o.z - space[2]) / (2 * space[5]) + 0.5f), o, make_float4(0, 0, 0, 0), p, 0, 0, NONE, filled};
    const Surface surface = shade(scene, scene.materials[material].program, -direction,
        makeMatrix<float, 3, 3>(make_float3(1, 0, 0), make_float3(0, 1, 0), -direction), point, -direction, false, ray,
        instance.info);
    glow = surface.glow;
    return volume(surface);
}
// Of a varying medium, the distance along a ray to its next real scattering, past distance for none, by delta tracking
// under its majorant with weights per channel (Kutz et al. 2017's spectral tracking): each tentative collision scatters
// by its scattering's mean over the majorant, the throughput weighed by its scattering over that mean, or passes
// weighed by what of the majorant its extinction leaves over what passing has; the medium takes the scattering's point;
// passing alone, it scatters at none, its weight ratio tracking's (Novak et al. 2014), of what absorbs alone if so.
// Each tentative collision gathers its emission over the majorant by the weight reaching it, which estimates the
// transmittance there as ratio tracking does: glowed, what the medium emits along the ray up to the distance returned
__device__ float track(const Scene& scene, Medium& medium, unsigned material, float3 origin, float3 direction,
    float distance, unsigned& state, float3& weight, float3& glowed, const Ray& ray, bool passing = false,
    bool absorbing = false) {
    const float stored = scene.instances[owner(scene, material)].majorant, majorant = fabsf(stored);
    // Stored negative, the majorant is the medium's extinction itself, constant and gray as its export proves: a free
    // flight is drawn from it exactly and the medium shaded once, at its collision, which always scatters, the weight
    // taking the albedo and the emission gathered over the extinction (the collision estimator); passing alone, light
    // passes by its exponential, shading nothing. What absorbs alone still tracks, needing the scattering
    if (stored < 0 && !absorbing) {
        if (passing) return weight = weight * expf(-majorant * distance), distance;
        const float along = -logf(1 - random(state)) / majorant;
        if (!(along < distance)) return along;
        float3 glow;
        const Medium at = inside(scene, material, origin + direction * along, direction, ray, glow);
        return glowed = glowed + weight * glow / majorant, weight = weight * at.scatter / majorant, medium = at, along;
    }
    for (float along = 0;;) {
        along -= logf(1 - random(state)) / majorant;
        if (!(along < distance)) return along;
        float3 glow;
        const Medium at = inside(scene, material, origin + direction * along, direction, ray, glow);
        glowed = glowed + weight * glow / majorant;
        const float mean = passing ? 0 : (at.scatter.x + at.scatter.y + at.scatter.z) / 3;
        if (random(state) * majorant < mean)
            return weight = weight * at.scatter / mean, medium = at, along;
        weight = weight * (make_float3(1, 1, 1) * majorant - at.extinction + (absorbing ? at.scatter
            : make_float3(0, 0, 0))) / (majorant - mean);
    }
}
// Of a medium, the share of light passing it from one distance to another along a ray, of what it absorbs alone if so:
// homogeneous by its exponential, varying by tracking it passing alone; glowed, if given, gathers its emission
__device__ float3 passing(const Scene& scene, Medium medium, unsigned material, float3 origin, float3 direction,
    float from, float to, unsigned& state, const Ray& ray, bool absorbing = false, float3* glowed = nullptr) {
    if (!used(MEDIUM) || material == NONE)
        return exponential(absorbing ? (medium.scatter - medium.extinction) * (to - from)
            : medium.extinction * (from - to));
    float3 passed = make_float3(1, 1, 1);
    float3 dropped = make_float3(0, 0, 0);
    track(scene, medium, material, origin + direction * from, direction, to - from, state, passed,
        glowed ? *glowed : dropped, ray, true, absorbing);
    return passed;
}

// Of a shadow ray from from along toward, to the light left away, starting in medium of filling: through each layer of
// occluders, by distance then index, passing rays straight through, where uncovered or tinted by their transparency,
// entering the volumes of those it meets from the front and leaving them from the back; transmitted, the share of light
// reaching the light through them and the media between. Whether an occluder blocks it, opaque or passing nothing
__device__ __forceinline__ bool occluded(const Scene& scene, float3 from, float3 toward, float left, Medium medium,
    unsigned filling, unsigned& state, const Ray& ray, bool onSurface, float3& transmitted, unsigned skip = NONE) {
    float before = 0, at = 0, occluder;
    transmitted = make_float3(1, 1, 1);
    // The nearest hit, any of the triangles at its distance; where it lets light through, the layers start over an ulp
    // short of it, from the lowest index there
    // Off a surface past its margin; off a medium's vertex, or an opaque surface past skip, its own triangle, from none
    // A hair vertex's own segment skipped too, the ray starting at it, as its bounces do
    Hit first = onSurface && skip == NONE ? traverse(scene, from, toward, left, at)
        : traverse(scene, from, toward, left, at, skip, 0);
    if (first.triangle != NONE && !scene.materials[key(scene, first)].opaque)
        at = __uint_as_float(__float_as_uint(at) - 1), first = nextLayer(scene, from, toward, left, at, NONE);
    for (Hit hit = first; hit.triangle != NONE;
        before = at, hit = nextLayer(scene, from, toward, left, at, key(scene, hit))) {
        occluder = at - before;
        if (scene.materials[key(scene, hit)].opaque) return true;  // Shading it would pass nothing
        transmitted = transmitted * passing(scene, medium, filling, from, toward, before, at, state, ray);
        for (unsigned layer = 0; layer < scene.materials[key(scene, hit)].layers; ++layer) {
            const Surface surface = shade(scene, hit.instance, hit.triangle, hit.uv.x, hit.uv.y,
                smoothNormal(scene, hit), toward,
                Ray{ray.camera, true, ray.lobe, ray.depth + 1, occluder}, layer);
            transmitted = transmitted * occluderTransmittance(toward, surface.normal, BSDFMaterial{
                .albedo = surface.albedo, .roughness = surface.roughness, .metallic = surface.metallic,
                .transmission = surface.transparency, .ior = surface.ior,
                .anisotropy = used(ANISOTROPIC) ? surface.anisotropy : 0,
                .anisotropic_rotation = used(ANISOTROPIC) ? surface.anisotropic_rotation : 0,
                .tangent = used(ANISOTROPIC) ? surface.tangent : make_float3(0, 0, 0)}, surface.coverage);
            if (layer == 0 && encloses(scene, surface, hit.instance)) {
                const bool leaves = dot(faceNormal(scene, hit), toward) > 0;
                medium = leaves ? Medium{} : volume(surface), filling = leaves ? NONE : fills(scene, hit.instance,
                    hit.triangle);
            }
        }
        if (rgb_to_greyscale(transmitted) <= 0)
            return true;
    }
    transmitted = transmitted * passing(scene, medium, filling, from, toward, before, left, state, ray);
    return false;
}

// The medium the camera is in, seen along direction to the first hit distance away: that of the volume it is in, by the
// first triangle of the volume's instance; filling, its material's key if varying, else NONE
__device__ __forceinline__ Medium cameraMedium(const Scene& scene, float3 direction, float distance, unsigned& filling) {
    const Hit held = scene.settings.medium == NONE ? Hit{NONE} : owned(scene, scene.settings.medium);
    const Medium medium = held.triangle == NONE ? Medium{} : volume(shade(scene, held.instance, held.triangle, 0, 0,
        cornerNormals(scene.normals, scene.instances[held.instance], held.triangle)[0], direction,
        Ray{true, false, LOBE_NONE, 0.0f, distance}));
    filling = held.triangle == NONE ? NONE : fills(scene, held.instance, held.triangle);
    return medium;
}

// renderer.slang's baked hair: its level's sums and their search, a slice's f cos and density, connected and sampled
__device__ float4 operator+(float4 a, float4 b) { return make_float4(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w); }
__device__ float4 operator-(float4 a, float4 b) { return make_float4(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w); }
__device__ float4 operator*(float4 a, float4 b) { return make_float4(a.x * b.x, a.y * b.y, a.z * b.z, a.w * b.w); }
__device__ float at(float4 v, unsigned p) { return (&v.x)[p]; }
__device__ float4 hairSums(const Scene& scene, const float4* record, unsigned image, float x, float y) {
    return tex2DLod<float4>(scene.images[2 * unsigned(record[0].w) + 2 * image + 1],
        x / (image ? record[1].z + 2 : record[1].y + 1), y / (image ? 16 * record[1].x : record[1].x), 0);
}
__device__ unsigned hairSearch(const Scene& scene, const float4* record, unsigned image, float y, unsigned p, float q,
    unsigned count) {
    unsigned low = 0, high = count - 1;
    while (low < high) {
        const unsigned middle = (low + high + 1) / 2;
        if (at(hairSums(scene, record, image, middle + 0.5f, y), p) <= q) low = middle; else high = middle - 1;
    }
    return low;
}
__constant__ float HAIR_WIDTHS[4] = {1, 0.5f, 2, 2};
__constant__ float HAIR_TILTS[4] = {-2, 1, 4, 0};
// Rows of lobe p's poles for the viewer at in_angle, by hairRow's mapping of +-pi / 2, within the slice's rows
__device__ float2 hairPoles(const float4* record, unsigned p, float w, float a, float in_angle) {
    const float nt = record[1].y, tilt = in_angle + HAIR_TILTS[p] * record[0].z;
    return make_float2(fminf(fmaxf((asinhf((-PI / 2 - tilt) / w) / a + 1) * nt / 2, 0), nt),
        fminf(fmaxf((asinhf((PI / 2 - tilt) / w) / a + 1) * nt / 2, 0), nt));
}
__device__ float3 hairSlice(const Scene& scene, const float4* record, float o, const float* y, float x, float3 u,
    float3 tint, bool binned, float& density, float in_angle) { // Lobe R's tinted, an artistic extension: a
    // tint <= 1 adds nothing
    const float nt = record[1].y, np = record[1].z, c = binned ? floorf(x) : x - 0.5f - np * floorf((x - 0.5f) / np);
    float4 n[3], total = make_float4(0, 0, 0, 0), all = total;
    for (unsigned k = 0; k < 3; ++k) {
        const float level = o * 16 + __saturatef((&u.x)[k]) * 15 + 0.5f;
        n[k] = hairSums(scene, record, 1, c + 1.5f, level) - hairSums(scene, record, 1, c + 0.5f, level);
        if (binned) total = total + hairSums(scene, record, 1, np + 0.5f, level);
    }
    if (binned) all = record[2] * hairSums(scene, record, 0, nt + 0.5f, o + 0.5f);
    float3 f = make_float3(0, 0, 0);
    density = 0;
    for (unsigned p = 0; p < 4; ++p) {
        const float w = record[0].x * (p == 0 ? record[0].y : 1) * HAIR_WIDTHS[p], a = asinhf(PI / w);
        const float r = binned ? floorf(y[p]) : fminf(fmaxf(y[p] - 0.5f, 0), nt - 1), m = y[p] >= 0 && y[p] < nt
            ? at(record[2] * (hairSums(scene, record, 0, r + 1.5f, o + 0.5f) - hairSums(scene, record, 0, r + 0.5f,
            o + 0.5f)), p) / (w * coshf((2 * y[p] / nt - 1) * a) * a * 2 / nt) * np / (2 * PI) : 0;
        const float2 pole = hairPoles(record, p, w, a, in_angle); // The lobe whole between the poles
        const float scale = at(hairSums(scene, record, 0, nt + 0.5f, o + 0.5f), p) / fmaxf(at(hairSums(scene, record,
            0, pole.y + 0.5f, o + 0.5f) - hairSums(scene, record, 0, pole.x + 0.5f, o + 0.5f), p), 1e-30f);
        f = f + m * scale * make_float3(at(n[0], p), at(n[1], p), at(n[2], p)) * (p == 0 ? tint : make_float3(1, 1, 1));
        density += m * scale * (at(n[0], p) + at(n[1], p) + at(n[2], p)) / fmaxf(all.x * total.x + all.y * total.y
            + all.z * total.z + all.w * total.w, 1e-30f);
    }
    return f;
}
__device__ SampleBSDF connectHair(const Scene& scene, const Surface& surface, float3 in_dir, float3 out_dir) {
    const float3 t = normalize(surface.hair);
    const float4* record = scene.hairs + 3 * (unsigned(length(surface.hair) + 0.5f) - 1);
    const float no = record[1].x, s = fminf(fmaxf((asinf(fminf(fmaxf(-dot(in_dir, t), -1.0f), 1.0f)) / PI + 0.5f)
        * (no - 1), 0), no - 1); // Its slices even in the viewer's angle from pole to pole
    const float o = fminf(floorf(s), no - 2);
    float y[4];
    for (unsigned p = 0; p < 4; ++p)
        y[p] = hairRow(in_dir, t, out_dir, p, record[0].x * (p == 0 ? record[0].y : 1), record[0].z, record[1].y);
    const float x = hairColumn(in_dir, t, out_dir, record[1].z);
    const float cosine = fmaxf(length(cross(out_dir, t)), BIAS); // cos theta, off 0 along the fiber by BIAS
    const float3 tint = used(SPECULAR) ? surface.tint : make_float3(1, 1, 1); // The Specular Tint, R's
    float near, far, unused, in_angle = asinf(fminf(fmaxf(dot(in_dir, t), -1.0f), 1.0f));
    const float3 f = hairSlice(scene, record, o, y, x, surface.albedo, tint, false, unused, in_angle) * (1 - (s - o))
        + hairSlice(scene, record, o + 1, y, x, surface.albedo, tint, false, unused, in_angle) * (s - o);
    hairSlice(scene, record, o, y, x, surface.albedo, tint, true, near, in_angle), hairSlice(scene, record, o + 1, y, x,
        surface.albedo, tint, true, far, in_angle);
    const float density = near * (1 - (s - o)) + far * (s - o);
    return SampleBSDF{out_dir, density > 0 ? f / density : make_float3(0, 0, 0), 0, false, dot(out_dir, -in_dir)
        > dot(out_dir, t) * dot(-in_dir, t) ? LOBE_REFLECT : LOBE_REFRACT, density / cosine};
}
__device__ SampleBSDF sampleHair(const Scene& scene, const Surface& surface, float3 in_dir, unsigned state) {
    const float3 t = normalize(surface.hair);
    const float4* record = scene.hairs + 3 * (unsigned(length(surface.hair) + 0.5f) - 1);
    const float no = record[1].x, nt = record[1].y, np = record[1].z;
    const float s = fminf(fmaxf((asinf(fminf(fmaxf(-dot(in_dir, t), -1.0f), 1.0f)) / PI + 0.5f) * (no - 1), 0), no - 1);
    Random r = pcg(state);
    const float o = fminf(floorf(s), no - 2) + float(r.value < s - fminf(floorf(s), no - 2));
    const float4 all = record[2] * hairSums(scene, record, 0, nt + 0.5f, o + 0.5f);
    float4 n[3], mass = make_float4(0, 0, 0, 0);
    for (unsigned k = 0; k < 3; ++k)
        mass = mass + (n[k] = all * hairSums(scene, record, 1, np + 0.5f, o * 16 + __saturatef((&surface.albedo.x)[k])
            * 15 + 0.5f));
    float q = (r = pcg(r.state)).value * (mass.x + mass.y + mass.z + mass.w);
    unsigned p = 0, k = 0;
    for (; p < 3 && q >= at(mass, p); ++p) q -= at(mass, p);
    for (q = (r = pcg(r.state)).value * at(mass, p); k < 2 && q >= at(n[k], p); ++k) q -= at(n[k], p);
    // Its row between the poles, by the sums' linear inverse there: no draw crosses a pole
    const float w = record[0].x * (p == 0 ? record[0].y : 1) * HAIR_WIDTHS[p];
    const float2 pole = hairPoles(record, p, w, asinhf(PI / w), asinf(fminf(fmaxf(dot(in_dir, t), -1.0f), 1.0f)));
    const float low = at(hairSums(scene, record, 0, pole.x + 0.5f, o + 0.5f), p), row_q = low + (r = pcg(r.state)).value
        * (at(hairSums(scene, record, 0, pole.y + 0.5f, o + 0.5f), p) - low);
    const unsigned row = hairSearch(scene, record, 0, o + 0.5f, p, row_q, nt);
    const float s0 = at(hairSums(scene, record, 0, row + 0.5f, o + 0.5f), p);
    float y = row + (row_q - s0) / fmaxf(at(hairSums(scene, record, 0, row + 1.5f, o + 0.5f), p) - s0, 1e-30f);
    r = pcg(r.state);
    r = pcg(r.state);
    float x = hairSearch(scene, record, 1, o * 16 + __saturatef((&surface.albedo.x)[k]) * 15 + 0.5f, p, r.value
        * at(n[k], p) / at(all, p), np);
    x += (r = pcg(r.state)).value;
    SampleBSDF sampled = connectHair(scene, surface, in_dir, hairDirection(in_dir, t, p, y, x, record[0].x
        * (p == 0 ? record[0].y : 1), record[0].z, nt, np));
    sampled.random_state = r.state;
    return sampled;
}

// The walk a direct callable that the passes call: FlexKernels' walk through the adapter's hooks, compiled once as one
// function of its own, where OptiX would compile it into each pass calling it, its state spilled around each of its
// traces there. Its records hold the scene the hooks read: the pass's, then the anchor's
extern "C" __device__ Shift __direct_callable__walk(const Domain* dom, const Reservoir* r, bool replay, float scale,
    Selection* sel) {
    return walk_hook(FKDomain{dom->x0, dom->x1, {dom->hit.uv, dom->hit.instance, dom->hit.triangle, 0,
        length(dom->x1 - dom->x0)}, dom->width, dom->spread}, *r, replay, scale, sel);
}
#define WALK(scene, dom, r, replay, scale, sel) optixDirectCall<Shift>( \
    &(scene) == (const Scene*)optixGetSbtDataPointer() ? 0 : 1, &(dom), &(r), replay, scale, &(sel))

// The sample of r shifted into the pixel the camera sees, zero if its primary ray misses there
__device__ Shift shift(const Scene& scene, const Camera& camera, int pixel, uint3 size, const Reservoir& r) {
    Selection sel;
    if (r.w <= 0.0f) {
        return Shift{make_float3(0.0f, 0.0f, 0.0f), 0.0f};
    }
    const Domain dom = pixelDomain(scene, camera, pixel, size, r.seed);
    if (dom.hit.triangle == NONE) {
        return Shift{make_float3(0.0f, 0.0f, 0.0f), 0.0f};
    }
    return WALK(scene, dom, r, true, 0.0f, sel);
}

// Pixel coordinates a camera sees a position at
__device__ float2 project(const Camera& camera, float3 position, uint3 size) {
    const float3 d = position - camera.origin;
    if (camera.lens.ortho)
        return make_float2((1 + dot(d - camera.z, camera.x) / dot(camera.x, camera.x)) * 0.5f * size.x,
            (1 - dot(d - camera.z, camera.y) / dot(camera.y, camera.y)) * 0.5f * size.y);
    // d = (x * u + y * v + z) * depth
    const float depth = dot(cross(camera.x, camera.y), d);
    return make_float2((1 + dot(cross(d, camera.y), camera.z) / depth) * 0.5f * size.x,
        (1 - dot(cross(camera.x, d), camera.z) / depth) * 0.5f * size.y);
}

// Index of the pixel at q if the previous frame left it a sample, -1 otherwise
__device__ int previousValid(const Scene& scene, float2 q, uint3 size) {
    const int x = int(floorf(q.x));
    const int y = int(floorf(q.y));
    const bool valid = x >= 0 && y >= 0 && x < int(size.x) && y < int(size.y)
        && scene.previous[y * size.x + x].c > 0.0f;
    return valid ? y * int(size.x) + x : -1;
}

// Backprojection of the camera motion, or the dual motion vector of the surface previously seen there (Sec. 6.4)
__device__ int temporalNeighbor(const Scene& scene, uint3 p, uint3 size, const Domain& dom) {
    const float2 q = project(scene.previousCamera, dom.x1, size);
    const int index = previousValid(scene, q, size);
    if (index < 0) {
        return -1;
    }
    const float3 previous = pixelDomain(scene, scene.previousCamera, index, size, scene.previous[index].seed).x1;
    if (length(previous - dom.x1) <= length(dom.x1 - dom.x0) * 8.0f / size.x) {
        return index;
    }
    const float2 moved = project(scene.camera, previous, size);
    return previousValid(scene, make_float2(p.x + floorf(q.x) + 1.0f - moved.x, p.y + floorf(q.y) + 1.0f - moved.y),
        size);
}

// Index of the partner of p in reuse texture t, randomly flipped, transposed and offset every frame (Sec. 3.2),
// -1 off the image
__device__ int partner(const Scene& scene, uint3 p, uint3 size, unsigned t) {
    const int sizes[] = {PAIRING_SIZES[0], PAIRING_SIZES[1], PAIRING_SIZES[2]};
    const int texture = sizes[t];
    const unsigned random = hash(scene.frame * 3u + t);
    const int flip_x = (random & 1u) != 0u ? -1 : 1;
    const int flip_y = (random & 2u) != 0u ? -1 : 1;
    const bool transpose = (random & 4u) != 0u;
    const int x = ((int(transpose ? p.y : p.x) * flip_x + int((random >> 8u) & 255u)) % texture + texture) % texture;
    const int y = ((int(transpose ? p.x : p.y) * flip_y + int((random >> 16u) & 255u)) % texture + texture) % texture;
    const char2 delta = scene.pairing[t][y * texture + x];
    const int qx = int(p.x) + (transpose ? delta.y * flip_y : delta.x * flip_x);
    const int qy = int(p.y) + (transpose ? delta.x * flip_x : delta.y * flip_y);
    const bool valid = qx >= 0 && qy >= 0 && qx < int(size.x) && qy < int(size.y);
    return valid ? qy * int(size.x) + qx : -1;
}

// A texel of the bake whose program the frame numbers, its top bit the pass: what the program's surface takes as albedo
// there, as halves into the texels its end before the program gives the first and size of. The end before that gives
// its tiles, each 16 x 16 texels over a triangle's UVs, each texel's point at its center: owned by one triangle in the
// first pass, in the second one beside a baked texel where none was.
extern "C" __global__ void __raygen__bake() {
    const uint3 p = optixGetLaunchIndex();
    const Scene& scene = *(Scene*)optixGetSbtDataPointer();
    const unsigned program = scene.frame & ~(1u << 31);
    const Op &tiles = scene.ops[program - 2], &bake = scene.ops[program - 1];
    ushort4* const texels = (ushort4*)(scene.texels + bake.texel);
    if (!tiles.width) { // Over UV space, without tiles: each texel at the UV it stands for
        if (p.x >= bake.width || p.y >= (bake.height & 0xFFFFFF)) return;
        Point point = {};
        point.u = (p.x + 0.5f) / bake.width, point.v = (p.y + 0.5f) / (bake.height & 0xFFFFFF);
        const float3 z = make_float3(0, 0, 1), c = shade(scene, program, z, SlangMatrix<float, 3, 3>{}, point, z,
            false, {false, false, LOBE_NONE, 0, 0}, Info{}).albedo;
        texels[p.y * bake.width + p.x] = make_ushort4(__half_as_ushort(__float2half_rn(c.x)),
            __half_as_ushort(__float2half_rn(c.y)), __half_as_ushort(__float2half_rn(c.z)), 0x3C00);
        return;
    }
    const uint4 tile = ((const uint4*)scene.bakeTexels)[tiles.texel + p.x / 16];
    const unsigned x = tile.y * 16 + p.x % 16, y = tile.z * 16 + p.y;
    if (x >= bake.width || y >= bake.height) return;
    if (scene.frame >> 31) { // Off the edges: the first of left, right, below and above the first pass baked
        const int u[] = {int(x) - 1, int(x) + 1, int(x), int(x)}, v[] = {int(y), int(y), int(y) - 1, int(y) + 1};
        for (int k = 0; k < 4 && !texels[y * bake.width + x].w; ++k) {
            if (u[k] < 0 || v[k] < 0 || u[k] >= int(bake.width) || v[k] >= int(bake.height)) continue;
            const ushort4 texel = texels[v[k] * bake.width + u[k]];
            if (texel.w == 0x3C00) texels[y * bake.width + x] = make_ushort4(texel.x, texel.y, texel.z, 0x3800);
        } // Its alpha 1, the padding's a half, so padding takes only what the first pass baked
        return;
    }
    // Inside, or on an edge the triangle takes by the top-left rule, exactly on a grid of 512ths of a texel that
    // the triangles of a shared edge agree on: one of them bakes each texel
    const Hit unit = owned(scene, tile.x); // Its mesh's triangle, whose UVs it bakes over
    const float2* uv = scene.uvs + 3 * unit.triangle;
    long long px[3], py[3];
    for (int k = 0; k < 3; ++k)
        px[k] = floorf(uv[k].x * bake.width * 512), py[k] = floorf(uv[k].y * bake.height * 512);
    const long long area = (px[1] - px[0]) * (py[2] - py[0]) - (py[1] - py[0]) * (px[2] - px[0]);
    for (int k = 0; k < 3; ++k) { // Along its edges counterclockwise
        const int a = area > 0 ? k : (3 - k) % 3, b = area > 0 ? (k + 1) % 3 : (5 - k) % 3;
        const long long dx = px[b] - px[a], dy = py[b] - py[a];
        const long long w = dx * ((2 * y + 1) * 256ll - py[a]) - dy * ((2 * x + 1) * 256ll - px[a]);
        if (!area || w < 0 || !w && !(dy > 0 || !dy && dx > 0)) return;
    }
    const float2 e = uv[1] - uv[0], f = uv[2] - uv[0];
    const float2 c = make_float2((x + 0.5f) / bake.width - uv[0].x, (y + 0.5f) / bake.height - uv[0].y);
    const float det = e.x * f.y - e.y * f.x;
    const Point point = at(scene, unit.instance, unit.triangle, (c.x * f.y - c.y * f.x) / det,
        (e.x * c.y - e.y * c.x) / det);
    const float3 z = make_float3(0, 0, 1), albedo = shade(scene, program, z, SlangMatrix<float, 3, 3>{}, point, z,
        false, {false, false, LOBE_NONE, 0, 0}, Info{}).albedo;
    texels[y * bake.width + x] = make_ushort4(
        __half_as_ushort(__float2half_rn(albedo.x)), __half_as_ushort(__float2half_rn(albedo.y)),
        __half_as_ushort(__float2half_rn(albedo.z)), __half_as_ushort(__float2half_rn(1)));
}

// Mean emission over the triangle's actual UVs and generated coordinates, keeping support for small emitting regions.
extern "C" __global__ void __raygen__lights() {
    const unsigned triangle = optixGetLaunchIndex().x;
    const Scene& scene = *(Scene*)optixGetSbtDataPointer();
    Material& material = scene.materials[triangle];
    const Hit light = owned(scene, triangle);
    if (!(material.emitted > 0) || scene.instances[light.instance].world == STRANDS) return; // Sampled by no light
    constexpr unsigned LIGHT_SAMPLES = 256;
    unsigned state = hash(triangle);
    float mean = 0;
    for (unsigned i = 0; i < LIGHT_SAMPLES; ++i) {
        const float side = sqrtf((i + random(state)) / LIGHT_SAMPLES), along = random(state);
        const float3 n = faceNormal(scene, light.instance, light.triangle);
        float3 emission = shade(scene, light.instance, light.triangle, side * (1 - along), side * along, n, -n,
            {false, false, LOBE_NONE, 0, 0}, 0, true).emissive;
        if (!(emission.x + emission.y + emission.z > 0)) // Its back's where its front emits nothing, as a portal's
            emission = shade(scene, light.instance, light.triangle, side * (1 - along), side * along, n, n,
                {false, false, LOBE_NONE, 0, 0}, 0, true).emissive;
        mean += fmaxf(emission.x + emission.y + emission.z, 0.0f) / LIGHT_SAMPLES;
    }
    material.emitted = fmaxf(mean, material.emitted * 0.001f);
}

// Initial candidates: the path trees of the pixel's primary hits, each at a jitter of its own; it adds the radiance the
// camera sees right there, of an emitter or the world, as it carries no randomness to resample. Without ReSTIR it adds
// the path trees' estimate as well.
extern "C" __global__ void __raygen__initial() {
    const uint3 p = optixGetLaunchIndex();
    const uint3 size = optixGetLaunchDimensions();
    const unsigned index = p.y * size.x + p.x;
    const Scene& scene = *(Scene*)optixGetSbtDataPointer();
    const unsigned pixel_seed = stream(hash(scene.frame), index);
    Selection initial = {};
    initial.random_state = stream(pixel_seed, STREAM_SELECT);
    initial.sums = !scene.settings.restir;
    // The pixel's own seed even without a sample, its domain for later passes
    initial.r.seed = stream(pixel_seed, 0u);
    float3 seen = make_float3(0.0f, 0.0f, 0.0f);
    for (unsigned i = 0u; i < scene.settings.paths; i++) {
        Reservoir r = {};
        r.seed = stream(pixel_seed, i);
        const Domain dom = pixelDomain(scene, scene.camera, index, size, r.seed);
        if (dom.hit.triangle != NONE) {
            WALK(scene, dom, r, false, 1.0f / scene.settings.paths, initial);
        } else {
            seen = seen + environment(scene, normalize(dom.x1 - dom.x0), {true, false, LOBE_NONE, 1, 0})
                / scene.settings.paths;
        }
    }
    // What the walks saw at their first hits through the camera's medium, which they add up unresampled
    seen = seen + initial.glow / scene.settings.paths;
    if (scene.settings.restir) scene.initial[index] = finalize(initial, 1.0f);
    const float3 radiance = scene.settings.restir ? seen : seen + initial.color;
    float4& sum = scene.accumulation[index];
    sum = make_float4(sum.x + radiance.x, sum.y + radiance.y, sum.z + radiance.z, sum.w + 1);
}

// Denoiser input and guides of the pixel, then the triangle it sees for the next denoising: the mean radiance, and the
// motion of what the pixel sees since the frame last denoised, a point of the previous vertices or a direction of the
// world, trusted where it was in front of that frame's camera at a pixel that saw the same triangle
extern "C" __global__ void __raygen__denoise() {
    const uint3 p = optixGetLaunchIndex();
    const uint3 size = optixGetLaunchDimensions();
    const unsigned index = p.y * size.x + p.x;
    const Scene& scene = *(Scene*)optixGetSbtDataPointer();
    const float4 sum = scene.accumulation[index];
    scene.mean[index] = make_float4(sum.x / sum.w, sum.y / sum.w, sum.z / sum.w, 1.0f);
    const Domain dom = pixelDomain(scene, scene.camera, index, size, index);
    const Camera& last = scene.denoisedCamera;
    const unsigned seen = dom.hit.triangle == NONE ? NONE : key(scene, dom.hit);
    const float3 before = dom.hit.triangle == NONE ? last.origin + dom.x1 - dom.x0
        : hitPosition(scene, scene.previousVertices, dom.hit);
    const float2 then = project(last, before, size);
    scene.flow[index] = project(scene.camera, dom.x1, size) - then;
    const int x = int(floorf(then.x)), y = int(floorf(then.y));
    const float3 back = cross(last.x, last.y);
    scene.trust[index] = dot(back, before - last.origin) * dot(back, last.z) > 0.0f && x >= 0 && y >= 0
        && x < int(size.x) && y < int(size.y) && scene.previousSeen[y * size.x + x] == seen;
    scene.seen[index] = seen;
}

// Temporal reuse: the initial sample against the one the previous frame left the pixel's temporal neighbor, which is
// the pixel itself under a still camera, where both shifts are the identity. The view's first frame reuses reservoirs
// of the scene they were traced in, shifting into it there.
extern "C" __global__ void __raygen__temporal() {
    const uint3 p = optixGetLaunchIndex();
    const uint3 size = optixGetLaunchDimensions();
    const unsigned index = p.y * size.x + p.x;
    const Scene& scene = *(Scene*)optixGetSbtDataPointer();
    Reservoir r = scene.initial[index];
    const bool still = scene.frame > 0u && scene.camera.origin == scene.previousCamera.origin
        && scene.camera.x == scene.previousCamera.x && scene.camera.y == scene.previousCamera.y
        && scene.camera.z == scene.previousCamera.z;
    // The scene of the view's first frame's reservoirs is the anchor's, in the record two before temporal's own
    const Scene& before = scene.frame == 0u ? *(const Scene*)((const char*)&scene - 2 * RECORD_STRIDE) : scene;
    int q = scene.previous[index].c > 0.0f ? int(index) : -1;
    if (!still) {
        const Domain dom = pixelDomain(scene, scene.camera, index, size, r.seed);
        q = dom.hit.triangle == NONE ? -1 : temporalNeighbor(before, p, size, dom);
    }
    if (q >= 0) {
        const Reservoir temporal = scene.previous[q];
        // Optionally lower the confidence cap where the previous frame duplicated samples (Sec. 5), this biases the estimate
        const float duplicated = scene.settings.decorrelation ? scene.duplication[q] : 0.0f;
        const float c_t = fminf(temporal.c, confidenceCap(duplicated));
        const Shift to_current = still ? Shift{temporal.f, 1.0f} : shift(scene, scene.camera, index, size, temporal);
        const Shift to_previous = still ? Shift{r.f, 1.0f} : shift(before, scene.previousCamera, q, size, r);
        const float p_c = rgb_to_greyscale(r.f);
        const float p_t = rgb_to_greyscale(temporal.f);
        Selection sel = {};
        sel.random_state = stream(r.seed, STREAM_SELECT + 1u);
        const float2 weights = temporalWeights(r.c, p_c, c_t, p_t, rgb_to_greyscale(to_previous.f),
            rgb_to_greyscale(to_current.f));
        offerShifted(&sel, r, Shift{r.f, 1.0f}, weights.x);
        offerShifted(&sel, temporal, to_current, weights.y);
        r = finalize(sel, r.c + c_t);
    }
    scene.temporal[index] = r;
}

// Paired shifts (Sec. 3): the pixel's sample into the domain of its partner in the reuse texture of the launch's layer
extern "C" __global__ void __raygen__shift() {
    const uint3 p = optixGetLaunchIndex();
    const uint3 size = optixGetLaunchDimensions();
    const unsigned index = p.y * size.x + p.x;
    const Scene& scene = *(Scene*)optixGetSbtDataPointer();
    const int q = partner(scene, p, size, p.z);
    scene.shifts[3 * index + p.z] = q < 0 ? Shift{make_float3(0.0f, 0.0f, 0.0f), 0.0f}
        : shift(scene, scene.camera, q, size, scene.temporal[index]);
}

// Paired spatial reuse with pairwise MIS (Sec. 3) and shading with vector-valued weights (Sec. 6.3)
extern "C" __global__ void __raygen__spatial() {
    const uint3 p = optixGetLaunchIndex();
    const uint3 size = optixGetLaunchDimensions();
    const unsigned index = p.y * size.x + p.x;
    const Scene& scene = *(Scene*)optixGetSbtDataPointer();
    const Reservoir r = scene.temporal[index];
    float count = 0.0f;
    float c_sum = r.c;
    for (unsigned t = 0u; t < scene.settings.neighbors; t++) {
        const int q = partner(scene, p, size, t);
        if (q >= 0) {
            count += 1.0f;
            c_sum += scene.temporal[q].c;
        }
    }
    // Confidence of the current pixel is split evenly across the pairs
    const float c_pair = r.c / fmaxf(count, 1.0f);
    const float p_c = rgb_to_greyscale(r.f);
    float canonical_mis = count == 0.0f ? 1.0f : 0.0f;
    Selection sel = {};
    sel.random_state = stream(scene.initial[index].seed, STREAM_SELECT + 2u);
    for (unsigned t = 0u; t < scene.settings.neighbors; t++) {
        const int q = partner(scene, p, size, t);
        if (q >= 0) {
            const Reservoir neighbor = scene.temporal[q];
            const Shift to_here = scene.shifts[3 * q + t];
            const Shift to_there = scene.shifts[3 * index + t];
            const float share = pairShare(neighbor.c, c_pair, c_sum);
            if (p_c > 0.0f) {
                canonical_mis += canonicalWeight(share, c_pair, p_c, neighbor.c, rgb_to_greyscale(to_there.f));
            }
            offerShifted(&sel, neighbor, to_here,
                neighborWeight(share, neighbor.c, rgb_to_greyscale(neighbor.f), c_pair, rgb_to_greyscale(to_here.f)));
        }
    }
    offerShifted(&sel, r, Shift{r.f, 1.0f}, canonical_mis);
    scene.previous[index] = finalize(sel, c_sum);
    float4& sum = scene.accumulation[index];
    sum = make_float4(sum.x + sel.color.x, sum.y + sel.color.y, sum.z + sel.color.z, sum.w);
}

// Fraction of the 17 x 17 neighborhood sharing each pixel's sample (Sec. 5)
extern "C" __global__ void __raygen__duplicates() {
    const uint3 p = optixGetLaunchIndex();
    const uint3 size = optixGetLaunchDimensions();
    const unsigned index = p.y * size.x + p.x;
    const Scene& scene = *(Scene*)optixGetSbtDataPointer();
    const Reservoir& own = scene.previous[index];
    unsigned count = 0u;
    for (int y = int(p.y) - 8; y <= int(p.y) + 8; y++) {
        for (int x = int(p.x) - 8; x <= int(p.x) + 8; x++) {
            if (x >= 0 && y >= 0 && x < int(size.x) && y < int(size.y)) {
                const Reservoir& other = scene.previous[y * size.x + x];
                count += other.w > 0.0f && other.seed == own.seed ? 1u : 0u;
            }
        }
    }
    scene.duplication[index] = own.w > 0.0f ? (count - 1u) / 288.0f : 0.0f;
}
#include "adapter.cuh"
