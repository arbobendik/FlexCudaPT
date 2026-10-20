#include "renderer.h"
#include <optix.h>
#include <cuda_runtime.h>
#include "flexkernels/pathtracer.cuh"

constexpr int STACK = 64;
constexpr int SLOTS = 32; // Values a program keeps for reuse, as the extension's
extern "C" __constant__ Params params;
constexpr float PI = 3.14159265f;
constexpr float INV_PI = 0.3183098861837907f;
constexpr float BIAS = 0.0000152587890625f;
__device__ float3 operator+(float3 a, float3 b) { return make_float3(a.x + b.x, a.y + b.y, a.z + b.z); }
__device__ float3 operator-(float3 a, float3 b) { return make_float3(a.x - b.x, a.y - b.y, a.z - b.z); }
__device__ float3 operator-(float3 a) { return make_float3(-a.x, -a.y, -a.z); }
__device__ float2 operator-(float2 a, float2 b) { return make_float2(a.x - b.x, a.y - b.y); }
__device__ float3 operator*(float3 a, float3 b) { return make_float3(a.x * b.x, a.y * b.y, a.z * b.z); }
__device__ float3 operator*(float3 a, float s) { return make_float3(a.x * s, a.y * s, a.z * s); }
__device__ float3 operator*(float s, float3 a) { return a * s; }
__device__ float3 operator/(float3 a, float s) { return make_float3(a.x / s, a.y / s, a.z / s); }
__device__ float3 xzy(float3 a) { return make_float3(a.x, a.z, a.y); }
__device__ float3 mix(float3 a, float3 b, float t) { return a * (1 - t) + b * t; }
__device__ float4 mix(float4 a, float4 b, float t) {
    return make_float4(a.x * (1 - t) + b.x * t, a.y * (1 - t) + b.y * t,
        a.z * (1 - t) + b.z * t, a.w * (1 - t) + b.w * t);
}
// -1, 0 or 1
__device__ float sign(float x) { return (x > 0) - (x < 0); }
__device__ float dot(float3 a, float3 b) { return a.x * b.x + a.y * b.y + a.z * b.z; }
__device__ float3 reflect(float3 i, float3 n) { return i - n * (2 * dot(n, i)); }
// Zero under total internal reflection
__device__ float3 refract(float3 i, float3 n, float eta) {
    const float k = 1 - eta * eta * (1 - dot(n, i) * dot(n, i));
    return k < 0 ? make_float3(0, 0, 0) : i * eta - n * (eta * dot(n, i) + sqrtf(k));
}
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
// Of the ray a surface or the world is shaded for, as Cycles' light path node tells: whether it left the camera or
// tests a shadow, the lobe it left by, its bounce, a bounce further for the world, and its length, none for the world
struct Ray { bool camera, shadow; unsigned lobe; float depth, length; };
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
// floats Blender reads them as, k / 255
__device__ float4 texel(const Scene& scene, const Op& op, int x, int y) {
    const int width = op.width, height = op.height & 0xFFFFFF, extension = op.height >> 24 & 3;
    if (extension == 2 && (x < 0 || x >= width || y < 0 || y >= height)) return make_float4(0, 0, 0, 0);
    if (extension == 1) x = min(max(x, 0), width - 1), y = min(max(y, 0), height - 1);
    x = (x % (2 * width) + 2 * width) % (2 * width), y = (y % (2 * height) + 2 * height) % (2 * height);
    if (extension == 3) x = x < width ? x : 2 * width - 1 - x, y = y < height ? y : 2 * height - 1 - y;
    if (!(op.height >> 26 & 1)) return scene.texels[op.texel + y % height * width + x % width];
    const unsigned word = ((const unsigned*)(scene.texels + op.texel))[y % height * width + x % width];
    const float level = 1.0f / 255;
    return make_float4((word & 255) * level, (word >> 8 & 255) * level, (word >> 16 & 255) * level, (word >> 24) * level);
}
// The vector transformed from its object into the world or back, or from the world into the camera's space or back, by
// the mode: as a point, direction or normal of the object, of the world, then as a point or direction of the camera
__device__ float3 transform(const Scene& scene, float3 v, int mode, const Info& info) {
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
// Of a point shaded: its UV, generated point, point in its object, color, position and triangle barycentrics
struct Point { float u, v; float3 generated, object; float4 color; float3 position; float s, t; unsigned triangle; };
__device__ Point shifted(const Scene& scene, const Point& point, const Ray& ray, int axis);
// Whether the scene's programs take the step: bound at compile time, OptiX compiles out the cases of steps they do not
__device__ bool used(unsigned code) { return params.ops[code >> 6] >> (code & 63) & 1; }
#define CASE(code) case code: if (!used(code)) break;
// Surface a program resolves to at the point, facing along the normal with the tangent space tbn, seen from the
// incoming direction, on the back of its face or not, for the ray, of the info's object; heights are bumped along its edges
__device__ Surface shade(const Scene& scene, unsigned program, float3 normal, SlangMatrix<float, 3, 3> tbn,
    const Point& point, float3 incoming, bool backfacing, const Ray& ray, const Info& info) {
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
        CASE(UV) *top++ = make_float3(u, v, 0); break;
        CASE(GENERATED) *top++ = generated; break;
        CASE(OBJECT) *top++ = object; break;
        CASE(TRANSFORM) --top; top[-1] = transform(scene, top[-1], int(top->x), info); break;
        case CAMERA_POINT: case WINDOW: { // In the camera's space, right, up and forward, or of its window, of the
            if (!used(CAMERA_POINT) && !used(WINDOW)) break;
            const Camera& c = scene.camera; // world along its direction from the camera, as Cycles'
            const float3 d = program == scene.materials[scene.count].program ? position : position - c.origin;
            const float3 forward = normalize(cross(c.y, c.x));
            const float3 q = d * (dot(c.z, forward) / dot(d, forward)) - c.z; // On its image plane
            *top++ = op->code == CAMERA_POINT ? make_float3(dot(d, normalize(c.x)), dot(d, normalize(c.y)),
                dot(d, forward)) : make_float3(dot(q, c.x) / dot(c.x, c.x) + 1, dot(q, c.y) / dot(c.y, c.y) + 1, 0) / 2;
        } break;
        CASE(VERTEX_COLOR) *top++ = make_float3(color.x, color.y, color.z); break;
        CASE(VERTEX_ALPHA) *top++ = make_float3(1, 1, 1) * color.w; break;
        CASE(OBJECT_INFO) { // Its location, color, alpha, pass index, material's pass index or random number
            const int output = int(top[-1].x);
            top[-1] = output == 0 ? make_float3(info.location[0], info.location[1], info.location[2]) : output == 1
                ? make_float3(info.color[0], info.color[1], info.color[2]) : make_float3(1, 1, 1)
                * (output == 2 ? info.color[3] : output == 3 ? info.index : output == 4 ? info.material : info.random);
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
        case IMAGE: case ALPHA: case IMAGE_LINEAR: case ALPHA_LINEAR: case IMAGE_CUBIC: case ALPHA_CUBIC: { // Repeating
            if (!used(IMAGE) && !used(ALPHA) && !used(IMAGE_LINEAR) && !used(ALPHA_LINEAR) && !used(IMAGE_CUBIC)
                && !used(ALPHA_CUBIC)) break;
            const bool repeat = (op->height >> 24 & 3) == 0;
            float x = (repeat ? wrap(top[-1].x) : top[-1].x) * op->width;
            float y = (repeat ? wrap(top[-1].y) : top[-1].y) * (op->height & 0xFFFFFF);
            float4 color = texel(scene, *op, int(floorf(x)), int(floorf(y)));
            if (op->code == IMAGE_LINEAR || op->code == ALPHA_LINEAR) {
                x -= 0.5f; y -= 0.5f;
                const int i = int(floorf(x)), j = int(floorf(y));
                color = mix(mix(texel(scene, *op, i, j), texel(scene, *op, i + 1, j), x - i),
                    mix(texel(scene, *op, i, j + 1), texel(scene, *op, i + 1, j + 1), x - i), y - j);
            }
            if (op->code == IMAGE_CUBIC || op->code == ALPHA_CUBIC) {
                x -= 0.5f; y -= 0.5f;
                const int i = int(floorf(x)), j = int(floorf(y));
                color = make_float4(0, 0, 0, 0);
                for (int k = 0; k < 16; ++k) {
                    const float4 t = texel(scene, *op, i + k % 4 - 1, j + k / 4 - 1);
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
        CASE(DECODE) top[-1] = make_float3(decode(top[-1].x), decode(top[-1].y), decode(top[-1].z)); break;
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
        stack[8].x, stack[9].x, stack[10], stack[11].x, stack[12]};
}
// Object-space MikkTSpace frame interpolated at the triangle's barycentrics, as Cycles'
__device__ SlangMatrix<float, 3, 3> tangentSpace(const float4* p, float3 n, float s, float t) {
    const float3 a = make_float3(p[0].x, p[0].y, p[0].z), b = make_float3(p[1].x, p[1].y, p[1].z);
    const float3 tangent = a + (b - a) * s + (make_float3(p[2].x, p[2].y, p[2].z) - a) * t;
    return makeMatrix<float, 3, 3>(tangent, cross(n, tangent) * p[0].w, n);
}
// Of a triangle at its barycentrics
__device__ Point at(const Scene& scene, unsigned triangle, float s, float t) {
    const float2* uv = scene.uvs + 3 * triangle;
    const float3* vertex = scene.vertices + 3 * triangle;
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
        vertex[0] + (vertex[1] - vertex[0]) * s + (vertex[2] - vertex[0]) * t, s, t, triangle};
}
// Along an edge only when a bump program asks for its height or position; the world's point stays fixed
__device__ Point shifted(const Scene& scene, const Point& point, const Ray& ray, int axis) {
    if (point.triangle == NONE) return point;
    const float3* vertex = scene.vertices + 3 * point.triangle;
    const float step = 1e-4f * fmaxf(ray.length, 1e-3f);
    return at(scene, point.triangle, axis == 1 ? point.s + step / length(vertex[1] - vertex[0]) : point.s,
        axis == 2 ? point.t + step / length(vertex[2] - vertex[0]) : point.t);
}
// Of a triangle at its barycentrics, reached along the direction by the ray, in a layer of its material, bumped by
// points along its edges as near as the ray's length makes a pixel's
__device__ Surface shade(const Scene& scene, unsigned triangle, float s, float t, float3 normal, float3 direction,
    const Ray& ray, unsigned layer = 0) {
    const float3* vertex = scene.vertices + 3 * triangle;
    const float3* normals = scene.normals + 3 * triangle;
    const float3 a = transform(scene, normals[0], 5, scene.infos[triangle]);
    const float3 b = transform(scene, normals[1], 5, scene.infos[triangle]);
    const float3 c = transform(scene, normals[2], 5, scene.infos[triangle]);
    unsigned program = scene.materials[triangle].program;
    // Each layer's program follows the end of the one above it
    while (layer) layer -= scene.ops[program++].code == END;
    return shade(scene, program, normal,
        tangentSpace(scene.tangents + 3 * triangle, normalize(a + (b - a) * s + (c - a) * t), s, t),
        at(scene, triangle, s, t), -direction,
        dot(cross(vertex[1] - vertex[0], vertex[2] - vertex[0]), direction) > 0, ray, scene.infos[triangle]);
}

// ReSTIR PT Enhanced (Lin, Kettunen and Wyman 2026) on top of the path tracing of walk below.
// Paths live in primary sample space, vertex b draws its random numbers from stream(seed, b).

// Single-vertex roughness threshold (Sec. 4.2)
constexpr float RESTIR_ROUGHNESS = 0.2f;
// Dual ray footprint constant c / 100 * 4 PI of Eq. 5 with c = 0.02
constexpr float RESTIR_FOOTPRINT = 0.0025132741228718345f;
// Temporal confidence cap and its duplication-driven reduction (Sec. 5)
constexpr float RESTIR_CAP = 20.0f;
constexpr float RESTIR_CAP_MIN = 1.0f;
constexpr float RESTIR_DUPLICATION_ALPHA = 0.1f;

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

// Camera and primary hit of a pixel
struct Domain {
    float3 x0;
    float3 x1;
    Hit hit;
};

// Sampling record of the previous path vertex for the reconnection criteria (Sec. 4)
struct Vertex {
    bool rough;
    unsigned lobe;
    float pdf;
    float cos;
};

__device__ unsigned extractBits(unsigned path, unsigned offset, unsigned count) {
    return path >> offset & ((1u << count) - 1u);
}

// Nearest hit of a ray within far and its distance, NONE on a miss
// Of a ray leaving the skipped triangle, if any, from where it hit it, as Cycles skips it, starting back by the
// distance it otherwise starts after to keep triangles there; a ray then passing a triangle hit there skips none
__device__ Hit traverse(const Scene& scene, float3 origin, float3 direction, float far, float& distance,
    unsigned skip = NONE) {
    const float back = skip == NONE ? 0 : 1e-4f;
    // Traverse only; hit data is read from the hit object below.
    optixTraverse(scene.handle, origin - direction * back, direction, 1e-4f - back, far + back, 0.0f, 255,
        skip == NONE ? OPTIX_RAY_FLAG_DISABLE_ANYHIT : OPTIX_RAY_FLAG_NONE, 0, 1, 0, skip);
    if (!optixHitObjectIsHit()) return {NONE};
    distance = optixHitObjectGetRayTmax() - back;
    // Barycentrics from the first two attributes; optixHitObjectGetTriangleBarycentrics returns zeros here.
    return {optixHitObjectGetPrimitiveIndex(), make_float2(__uint_as_float(optixHitObjectGetAttribute_0()),
        __uint_as_float(optixHitObjectGetAttribute_1()))};
}

extern "C" __global__ void __anyhit__skip() {
    if (optixGetPrimitiveIndex() == optixGetPayload_0()) optixIgnoreIntersection();
}

__device__ float3 hitPosition(const float3* vertices, Hit hit) { // On the triangles of vertices
    vertices += 3 * hit.triangle;
    return vertices[0] + (vertices[1] - vertices[0]) * hit.uv.x + (vertices[2] - vertices[0]) * hit.uv.y;
}

__device__ float3 faceNormal(const Scene& scene, unsigned triangle) {
    const float3* vertices = scene.vertices + 3 * triangle;
    return normalize(cross(vertices[1] - vertices[0], vertices[2] - vertices[0]));
}

__device__ float3 smoothNormal(const Scene& scene, Hit hit) {
    const float3* normals = scene.normals + 3 * hit.triangle;
    return normalize(normals[0] * (1 - hit.uv.x - hit.uv.y) + normals[1] * hit.uv.x + normals[2] * hit.uv.y);
}

// Distance along the smooth normal rays leave a hit at position from, to prevent unnatural hard shadow / reflection
// borders due to the difference between the smooth normal and geometry: the corners' distances by the tangents of their
// normals' angles to the face, limited to PI / 4, interpolated and kept within an eighth of the shortest edge
__device__ float geometryOffset(const Scene& scene, Hit hit, float3 face, float3 position) {
    const float3* vertex = scene.vertices + 3 * hit.triangle;
    const float3* normal = scene.normals + 3 * hit.triangle;
    const float weight[3] = {1 - hit.uv.x - hit.uv.y, hit.uv.x, hit.uv.y};
    float offset = 0, edge = INFINITY;
    for (int k = 0; k < 3; ++k) {
        const float3 side = vertex[(k + 1) % 3] - vertex[k];
        const float3 diff = position - vertex[k];
        const float cosine = fabsf(dot(face, normalize(normal[k])));
        edge = fminf(edge, sqrtf(dot(side, side)));
        offset += weight[k] * sqrtf(dot(diff, diff)) * fminf(sqrtf(fmaxf(1 - cosine * cosine, 0)) / cosine, PI * 0.25f);
    }
    return fminf(fmaxf(offset, 0), edge * 0.125f);
}
// Point offset along the unit normal from origin, or origin where rays from there would skip what lies in between
__device__ float3 lift(const Scene& scene, float3 origin, float3 normal, float offset) {
    float distance;
    return traverse(scene, origin, normal, offset, distance).triangle == NONE ? origin + normal * offset : origin;
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
    float3 direction = normalize(camera.x * (2 * x / size.x - 1) + camera.y * (1 - 2 * y / size.y) + camera.z);
    float3 origin = camera.origin;
    if (camera.lens.aperture > 0) {
        const float2 point = aperture(camera.lens, state);
        const float3 offset = normalize(camera.x) * point.x + normalize(camera.y) * point.y;
        const float3 forward = normalize(cross(camera.y, camera.x));
        direction = normalize(direction * (camera.lens.focus / dot(direction, forward)) - offset);
        origin = origin + offset;
    }
    const float3 start = origin;
    Hit hit = {NONE};
    float distance = 0;
    do {
        hit = traverse(scene, origin, direction, 1e16f, distance, distance < 1e-4f ? NONE : hit.triangle);
        origin = origin + direction * distance;
    } while (hit.triangle != NONE && scene.materials[hit.triangle].hidden);
    return {start, hit.triangle == NONE ? start + direction : hitPosition(scene.vertices, hit), hit};
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
// Scattering and extinction coefficients of a homogeneous medium, none by default
struct Medium { float3 scatter, extinction; };
// Of the volume filling the inside of a surface, behind its faces
__device__ Medium volume(const Surface& surface) {
    return {surface.scatter * surface.density,
        (surface.scatter + make_float3(1, 1, 1) - surface.absorption) * surface.density};
}

// Light sampling: an emitting triangle picked by the light BVH, a uniform point on it, counted if visible from
// the start lifted along shading on its side of the face, through the medium on that side, of sides behind and in front
// of face, and those its shadow ray enters. Returns emission * the light's cosine / distance^2 / pdf
// arriving along direction, pdf = the triangle's probability / area, and the density in solid angle. The ray reached
// origin; shadows are tested for it and emission is shaded for no ray, both a bounce further, as Cycles shades them.
__device__ float3 sampleLight(const Scene& scene, float3 origin, float3 normal, float3 shading, float offset,
    float3 face, const Medium* sides, unsigned state, float3& direction, float& density, Ray ray) {
    direction = make_float3(0, 0, 0), density = 0;
    // From the root down to either child by its share of importance, the pick rescaled to choose again (pbrt-v4's
    // BVHLightSampler::Sample)
    float pick = random(state), probability = 1;
    unsigned node = 0;
    while (!scene.lights[node].leaf) {
        const unsigned child = pickChild(scene.lights[node + 1], scene.lights[scene.lights[node].child], origin, normal,
            &pick, &probability);
        if (child > 1)
            return make_float3(0, 0, 0);
        node = child ? scene.lights[node].child : node + 1;
    }
    if (node == 0 && !(importance(scene.lights[0], origin, normal) > 0))
        return make_float3(0, 0, 0);
    const unsigned light = scene.lights[node].child;
    const float3 la = scene.vertices[3 * light];
    const float3 lb = scene.vertices[3 * light + 1];
    const float3 lc = scene.vertices[3 * light + 2];
    const float3 lightNormal = cross(lb - la, lc - la);
    const float side = sqrtf(random(state));
    const float along = random(state);
    const float3 toLight = la * (1 - side) + lb * (side * (1 - along)) + lc * (side * along) - origin;
    if (dot(normal, normal) > 0 && !(dot(normal, toLight) > 0))
        return make_float3(0, 0, 0);
    float3 from = lift(scene, origin, shading * sign(dot(face, toLight)), offset), transmitted = make_float3(1, 1, 1);
    // Visibility along the segment from the offset start to the sampled point
    const float3 shadow = toLight + origin - from, toward = normalize(shadow);
    float occluder = 0, left = length(shadow) * (1 - 1e-4f);
    direction = toward;
    Medium medium = sides[dot(face, toLight) > 0];
    // Through each layer of occluders passing rays straight through, where uncovered or tinted by their transparency,
    // entering the volumes of those it meets from the front and leaving them from the back
    for (Hit hit = {NONE}; (hit = traverse(scene, from, toward, left, occluder, occluder < 1e-4f ? NONE
        : hit.triangle)).triangle != NONE; left -= occluder) {
        transmitted = transmitted * exponential(medium.extinction * -occluder);
        for (unsigned layer = 0; layer < scene.materials[hit.triangle].layers; ++layer) {
            const Surface surface = shade(scene, hit.triangle, hit.uv.x, hit.uv.y, smoothNormal(scene, hit), toward,
                Ray{ray.camera, true, ray.lobe, ray.depth + 1, occluder}, layer);
            const float3 through = surface.ior == 1 ? straightThrough(toward, surface.normal, BSDFMaterial{surface.albedo,
                {}, surface.roughness, surface.metallic, surface.transparency}) : make_float3(0, 0, 0);
            transmitted = transmitted * (through * surface.coverage + make_float3(1, 1, 1) * (1 - surface.coverage));
            if (layer == 0 && surface.density > 0)
                medium = dot(faceNormal(scene, hit.triangle), toward) > 0 ? Medium{} : volume(surface);
        }
        if (rgb_to_greyscale(transmitted) <= 0)
            return make_float3(0, 0, 0);
        from = from + toward * occluder;
    }
    return transmitted * exponential(medium.extinction * -left)
        * shade(scene, light, side * (1 - along), side * along, lightNormal, direction,
        Ray{false, false, LOBE_NONE, ray.depth + 1, length(toLight)}).emissive
        / (density = solidAngle(probability, lightNormal, shadow));
}

// Density in solid angle of light sampling from origin picking point on triangle, down the trail to its leaf
// (pbrt-v4's BVHLightSampler::PMF)
__device__ float lightPdf(const Scene& scene, float3 origin, float3 normal, float3 start, unsigned triangle, float3 point) {
    float probability = 1;
    unsigned node = 0;
    for (unsigned long long trail = scene.trails[triangle]; !scene.lights[node].leaf; trail >>= 1) {
        probability *= childShare(scene.lights[node + 1], scene.lights[scene.lights[node].child], origin, normal,
            trail & 1);
        node = trail & 1 ? scene.lights[node].child : node + 1;
    }
    const float3* vertices = scene.vertices + 3 * triangle;
    return scene.lights[node].child == triangle && importance(scene.lights[node], origin, normal) > 0
        && (dot(normal, normal) == 0 || dot(normal, point - origin) > 0) ? solidAngle(probability,
        cross(vertices[1] - vertices[0], vertices[2] - vertices[0]), point - start) : 0;
}

// Walk a path from dom. Generating, every path of the tree is resampled into sel with its reconnection
// vertex (Sec. 6.1), Russian roulette only modifies their source density (Sec. 6.2.4). Replaying, the hybrid shift maps r into
// dom (Sec. 2.3): random replay up to x_k-1 and reconnection to x_k. It returns the shifted integrand times the Jacobian
// determinant of Eq. 2, zero if the path is not in the image of the shift.
// Seen is what dom's hit emits toward the camera.
__device__ Shift walk(const Scene& scene, const Domain& dom, const Reservoir& r, bool replay, float scale,
    Selection& sel, float3& seen) {
    const Shift fail = Shift{make_float3(0.0f, 0.0f, 0.0f), 0.0f};
    const unsigned end = extractBits(r.path, PATH_END, 5u);
    const unsigned k = extractBits(r.path, PATH_K, 5u);
    const unsigned rc = extractBits(r.path, PATH_RC, 2u);
    const unsigned end_type = extractBits(r.path, PATH_TYPE, 3u);
    // Replaying stops sampling at x_k-1 for reconnections and at the path end otherwise
    const unsigned stop = rc == RC_NONE ? end + (end_type == END_ENV ? 1u : 0u) : k - 1u;
    float3 origin = dom.x1;
    float3 direction = normalize(dom.x1 - dom.x0);
    Hit hit = dom.hit;
    float distance = length(dom.x1 - dom.x0);
    float3 throughput = make_float3(1.0f, 1.0f, 1.0f);
    // Replaying the densities of the reconnection, generating the product of Russian roulette survival probabilities
    float density = 1.0f;
    bool direct_light_emission = true;
    // Where light was last sampled, against which normal, and the BSDF's density of the direction the ray left along
    float3 nee_origin = origin, nee_normal = direction, nee_start = origin;
    float nee_pdf = 0.0f;
    float threshold = 0.0f;
    float3 reconnection = origin;
    Vertex prev = Vertex{false, 0u, 0.0f, 0.0f};
    // Layer of the hit's material the ray meets, and whether it came there from another layer of the hit, between them
    unsigned layer = 0u;
    bool passed = false;
    // Template for generated paths reconnecting at the first vertex meeting both footprint criteria
    Reservoir chain = {};
    chain.seed = r.seed;
    float3 chain_throughput = make_float3(0.0f, 0.0f, 0.0f);
    // Medium the ray travels in, none at the camera
    Medium medium = {};
    // Generating, whether the path survives Russian roulette and the bounce limit after vertex b
    const auto survives = [&](unsigned b) {
        const float survival_probability = fminf(fmaxf(fmaxf(throughput.x, fmaxf(throughput.y, throughput.z))
            / density, 0.0f), 1.0f);
        if (survival_probability < pcg(stream(r.seed, b + STREAM_RR)).value || b >= scene.settings.bounces) {
            return false;
        }
        density *= survival_probability;
        return true;
    };
    for (unsigned b = 0u; ; b++) {
        const float3 face = faceNormal(scene, hit.triangle);
        const Ray ray = {b == 0u, false, b ? prev.lobe : LOBE_NONE, float(b), distance};
        Surface surface = shade(scene, hit.triangle, hit.uv.x, hit.uv.y, smoothNormal(scene, hit), direction, ray,
            layer);
        // Only the top layer emits, where the ray first meets it
        if (passed) surface.emissive = make_float3(0, 0, 0);
        // Rays pass straight through the uncovered share of surfaces, which keep their emission and medium
        if (pcg(stream(r.seed, b + STREAM_COVERAGE)).value >= surface.coverage)
            surface = Surface{surface.normal, make_float3(1, 1, 1), 0, 0, surface.emissive, 1, 1,
                make_float3(1, 1, 1), 1, 1, surface.absorption, surface.density, surface.scatter};
        // Surfaces transmitting nothing face the ray, as in Cycles
        const float facing = surface.transparency > 0 || dot(face, direction) < 0 ? 1.0f : -1.0f;
        const float3 geometry_n = face * facing;
        surface.normal = surface.normal * facing;
        // As FlexLight's Material, which the shared BSDF takes, absorbing the volume's transmittance over unit distance
        const BSDFMaterial material = {surface.albedo, surface.emissive, surface.roughness, surface.metallic,
            surface.transparency, surface.ior, make_float3(expf(surface.density * (surface.absorption.x - 1)),
            expf(surface.density * (surface.absorption.y - 1)), expf(surface.density * (surface.absorption.z - 1)))};
        const float offset = geometryOffset(scene, hit, geometry_n, origin);
        // Media behind and in front of geometry_n: a volume fills the back of its faces, the ray leaving it leaves any
        Medium sides[2] = {medium, medium};
        if (surface.density > 0) {
            sides[dot(geometry_n, face) < 0] = volume(surface);
            if (dot(direction, face) > 0) sides[dot(geometry_n, face) > 0] = Medium{};
        }
        const float geometry_density = fabsf(dot(geometry_n, direction)) / (distance * distance);
        if (b == 0u) {
            // Primary ray footprint (Eq. 5)
            threshold = RESTIR_FOOTPRINT / geometry_density;
            seen = surface.emissive;
        }
        // Ray footprint criterion for reconnecting from the previous vertex to this one (Eq. 5), never between layers
        const bool footprint = !passed && prev.rough && prev.pdf * geometry_density * threshold <= 1.0f;
        const float n_dot_v = dot(surface.normal, - direction);
        const bool is_entering = n_dot_v < 0.0f;
        // Incident side is air, outgoing side is material (entering)
        const float eta_i = is_entering ? surface.ior : 1.0f;
        // Incident side is material, outgoing side is air (exiting)
        const float eta_o = is_entering ? 1.0f : surface.ior;
        // Light is sampled at the top layer alone
        const bool nee = !passed && layer == 0u && samplesLights(material);
        const float3 light_normal = surface.transparency > 0 && scene.materials[hit.triangle].layers == 1
            ? make_float3(0, 0, 0) : surface.normal;
        // Emission met against light sampling at the vertex the ray left, light sampled here against sampling the BSDF,
        // which the last bounce skips (power heuristic)
        const float3 emitted = surface.emissive * (direct_light_emission || !(rgb_to_greyscale(surface.emissive) > 0.0f)
            ? 1.0f : powerHeuristic(nee_pdf, lightPdf(scene, nee_origin, nee_normal, nee_start, hit.triangle, origin)));
        if (replay && rc == RC_SURFACE && b > k && b == end && end_type == END_EMIT) {
            return Shift{throughput * emitted / r.jac, density / r.jac};
        }
        // Each lobe competes with light sampling separately, but on the last bounce, which samples no BSDF
        const auto lit = [&](float3 light_dir, float light) {
            return b < scene.settings.bounces ? neeBSDF(direction, light_dir, surface.normal, material, eta_i, eta_o,
                !(dot(geometry_n, -direction) * dot(geometry_n, light_dir) > 0), light, true, stream(r.seed, b)) * light
                : BSDF(direction, light_dir, surface.normal, geometry_n, material, eta_i, eta_o, stream(r.seed, b));
        };
        const bool chain_found = extractBits(chain.path, PATH_RC, 2u) == RC_SURFACE;
        // Reconnection at this vertex for paths ending here
        Reservoir here = chain;
        here.path = b << PATH_K | RC_SURFACE << PATH_RC | prev.lobe << PATH_LOBE_PREV;
        here.jac = prev.pdf * geometry_density;
        here.rc = hit;
        const bool arrived = replay && rc == RC_SURFACE && b == k;
        if (arrived) {
            // The stored path takes over at the reconnection vertex
            if (hit.triangle != r.rc.triangle || !footprint) {
                return fail;
            }
            throughput = throughput * geometry_density;
            density *= geometry_density;
            if (k == end && end_type == END_EMIT) {
                return Shift{throughput * emitted / r.jac, density / r.jac};
            }
            // Light sampling at the reconnection vertex replays its random numbers, as the light may have moved
            if (k == end && end_type == END_NEE) {
                float3 light_dir;
                float light;
                const float3 radiance = nee ? sampleLight(scene, origin, light_normal, surface.normal, offset, geometry_n,
                    sides, stream(r.seed, b + STREAM_NEE), light_dir, light, ray) : make_float3(0.0f, 0.0f, 0.0f);
                if (!(rgb_to_greyscale(radiance) > 0.0f)) {
                    return fail;
                }
                return Shift{throughput * lit(light_dir, light) * radiance / r.jac, density / r.jac};
            }
            if (nee != (extractBits(r.path, PATH_NEE, 1u) == 1u)) {
                return fail;
            }
        } else if (replay && b == stop && rc != RC_SURFACE && rc != RC_ENV) {
            if (rc == RC_LIGHT && nee && !footprint) {
                // Forced reconnection to the light vertex of next event estimation (Sec. 6.2.3), the point its replayed
                // random numbers pick again (unit Jacobian)
                float3 light_dir;
                float light;
                const float3 radiance = sampleLight(scene, origin, light_normal, surface.normal, offset, geometry_n,
                    sides, stream(r.seed, b + STREAM_NEE), light_dir, light, ray);
                return rgb_to_greyscale(radiance) > 0.0f
                    ? Shift{throughput * lit(light_dir, light) * radiance, 1.0f} : fail;
            }
            // Emission seen right after a vertex, against its next event estimation
            if (rc == RC_NONE && end_type == END_EMIT && !footprint) {
                return Shift{throughput * emitted, 1.0f};
            }
            return fail;
        } else if (!replay) {
            // Emission seen directly carries no randomness to resample, shading adds it
            if (b > 0u) {
                const Reservoir candidate = !chain_found && footprint ? here : chain;
                offer(&sel, withEnd(candidate, END_EMIT, b, throughput * emitted),
                    throughput * emitted * scale / density);
            }
            if (nee) {
                float3 light_dir;
                float light;
                const float3 radiance = sampleLight(scene, origin, light_normal, surface.normal, offset, geometry_n,
                    sides, stream(r.seed, b + STREAM_NEE), light_dir, light, ray);
                const float3 f = rgb_to_greyscale(radiance) > 0.0f
                    ? throughput * lit(light_dir, light) * radiance : fail.f;
                Reservoir candidate = chain;
                if (chain_found) {
                    candidate.radiance = safeDivide(f, chain_throughput);
                } else if (footprint) {
                    candidate = here;
                    candidate.path |= 1u << PATH_NEE;
                    candidate.dir = light_dir;
                    candidate.radiance = radiance;
                } else {
                    // Forced reconnection to the light vertex (Sec. 6.2.3)
                    candidate.path = (b + 1u) << PATH_K | RC_LIGHT << PATH_RC;
                }
                offer(&sel, withEnd(candidate, END_NEE, b, f), f * scale / density);
            }
        }
        // Replaying, x_k-1 connects to the reconnection vertex and x_k leaves along the stored direction with the stored lobes
        const bool connect = replay && b == stop;
        unsigned lobe_index = extractBits(r.path, arrived ? PATH_LOBE : PATH_LOBE_PREV, 2u);
        float3 dir = r.dir;
        // Sample leaving this vertex
        SampleBSDF lobe = SampleBSDF{};
        if (connect) {
            if (rc == RC_SURFACE) {
                reconnection = hitPosition(scene.vertices, r.rc);
                dir = normalize(reconnection - lift(scene, origin,
                    surface.normal * sign(dot(reconnection - origin, geometry_n)), offset));
            }
            // The path tracer rejects directions on the wrong side of the face
            if (wrongSide(direction, lobe_index == LOBE_REFRACT, dir, geometry_n)) {
                return fail;
            }
        } else if (!arrived) {
            const SampleBSDF bsdf_sampled = sampleBSDF(direction, surface.normal, material, eta_i, eta_o,
                stream(r.seed, b), make_float2(0, 0));
            if (wrongSide(direction, bsdf_sampled.refracted, bsdf_sampled.unit_direction, geometry_n)) return fail;
            lobe_index = bsdf_sampled.lobe;
            dir = bsdf_sampled.unit_direction;
            lobe = bsdf_sampled;
        }
        // Connections evaluate the given direction
        if (connect || arrived) {
            lobe = connectBSDF(direction, dir, surface.normal, material, eta_i, eta_o, lobe_index, stream(r.seed, b));
        }
        // Delta lobes have no competing light sample; straight transmission keeps the preceding vertex's weights.
        const bool delta = lobe_index != LOBE_DIFFUSE
            && (surface.roughness == 0.0f || (lobe_index == LOBE_REFRACT && eta_i == eta_o));
        const bool weighs = nee && !delta;
        direct_light_emission = !weighs && (direct_light_emission || lobe_index != LOBE_REFRACT || surface.ior != 1);
        if (weighs) {
            nee_origin = origin, nee_normal = light_normal;
            nee_pdf = lobe.pdf;
        }
        // Inverse ray footprint criterion for the density of the direction leaving this vertex (Eq. 5)
        const bool inverse_footprint = lobe.pdf > 0.0f
            && (lobe_index == LOBE_DIFFUSE || lobe.pdf * prev.cos / (distance * distance) * threshold <= 1.0f);
        const bool rough = lobe.pdf > 0.0f && (lobe_index == LOBE_DIFFUSE || surface.roughness >= RESTIR_ROUGHNESS);
        if (arrived) {
            if (!inverse_footprint) {
                return fail;
            }
            if (end_type != END_EMIT) {
                return Shift{throughput * (lobe.throughput * lobe.pdf) * r.radiance / r.jac, density * lobe.pdf / r.jac};
            }
            // Emission's MIS weight depends on the reconnected BSDF; replay its suffix instead of caching that weight.
            throughput = throughput * lobe.pdf;
            density *= lobe.pdf;
        }
        // Refracting into the hit from outside or reflecting between its layers, the ray meets the other layer there
        const bool passes = scene.materials[hit.triangle].layers > 1u && (lobe_index == LOBE_REFRACT) != passed;
        // A replayed path meeting the criteria before x_k is not in the image of the shift, nor one connecting there
        if ((replay && b <= stop && footprint && inverse_footprint) || (connect && (!rough || passes))) {
            return fail;
        }
        if (connect) {
            throughput = throughput * (lobe.throughput * lobe.pdf);
            density = lobe.pdf;
        } else {
            throughput = throughput * make_float3(fmaxf(lobe.throughput.x, 0.0f), fmaxf(lobe.throughput.y, 0.0f),
                fmaxf(lobe.throughput.z, 0.0f));
        }
        if (!replay && !chain_found && footprint && inverse_footprint) {
            chain = here;
            chain.path |= lobe_index << PATH_LOBE | (nee ? 1u : 0u) << PATH_NEE;
            chain.jac *= lobe.pdf;
            chain.dir = dir;
            chain_throughput = throughput;
        }
        prev = Vertex{rough, lobe_index, lobe.pdf, fabsf(dot(geometry_n, dir))};
        // Off the side it leaves through, or right from where it passes straight through
        const unsigned through = lobe_index == LOBE_REFRACT && surface.ior == 1 && distance >= 1e-4f ? hit.triangle
            : NONE;
        direction = dir;
        // Off the side it leaves through, where light sampling toward it starts as well
        const float3 leaving = lift(scene, origin, surface.normal * sign(dot(direction, geometry_n)),
            lobe_index == LOBE_REFRACT && eta_i == eta_o ? 0.0f : offset);
        if (weighs) nee_start = leaving;
        origin = passes || through != NONE ? origin : leaving;
        if (!passes) medium = sides[dot(direction, geometry_n) > 0];
        if (!replay && !survives(b)) {
            break;
        }
        // Passing, the next vertex is the same hit in the other layer, reached without distance
        passed = passes;
        layer = passes ? layer ^ 1u : 0u;
        if (passes) {
            distance = 0.0f;
            continue;
        }
        // Only occluders in front of the reconnection vertex matter
        const bool reconnecting = replay && b == stop && rc == RC_SURFACE;
        hit = traverse(scene, origin, direction, reconnecting ? length(reconnection - origin) * 1.001f : 1e16f,
            distance, through);
        // Reaching the reconnection vertex, it is shaded exactly where the stored path has it
        if (reconnecting && hit.triangle == r.rc.triangle) {
            hit.uv = r.rc.uv;
            distance = length(reconnection - origin);
        }
        // The connection to the environment direction has to escape the scene
        if (replay && b == stop && rc == RC_ENV && hit.triangle != NONE) {
            return fail;
        }
        // Before the hit, the medium scatters the ray at distances its mean scattering coefficient samples, at vertices
        // lighting it through the isotropic phase function 1 / (4 PI) which ReSTIR neither reconnects at nor across
        const float sigma = (medium.scatter.x + medium.scatter.y + medium.scatter.z) / 3;
        if (reconnecting && sigma > 0) {
            return fail;
        }
        prev.rough = prev.rough && !(sigma > 0);
        for (float along; hit.triangle != NONE
            && (along = -logf(1 - pcg(stream(r.seed, b + STREAM_MEDIUM)).value) / sigma) < distance;) {
            b++;
            origin = origin + direction * along;
            throughput = throughput * medium.scatter * exponential((make_float3(1, 1, 1) * sigma - medium.extinction)
                * along) / sigma;
            const Medium around[2] = {medium, medium};
            float3 light_dir;
            float light;
            const float3 f = !replay || b == stop ? throughput * sampleLight(scene, origin, make_float3(0, 0, 0),
                direction, 0, direction, around, stream(r.seed, b + STREAM_NEE), light_dir, light,
                {false, false, prev.lobe, float(b), along})
                * (INV_PI / 4 * powerHeuristic(light, b < scene.settings.bounces ? INV_PI / 4 : 0)) : fail.f;
            if (replay && b == stop) {
                return rc == RC_LIGHT && rgb_to_greyscale(f) > 0.0f ? Shift{f, 1.0f} : fail;
            }
            if (!replay) {
                Reservoir candidate = chain;
                if (extractBits(chain.path, PATH_RC, 2u) == RC_SURFACE) {
                    candidate.radiance = safeDivide(f, chain_throughput);
                } else {
                    candidate.path = (b + 1u) << PATH_K | RC_LIGHT << PATH_RC;
                }
                offer(&sel, withEnd(candidate, END_NEE, b, f), f * scale / density);
                if (!survives(b)) {
                    return fail;
                }
            }
            direct_light_emission = false;
            nee_origin = nee_start = origin, nee_normal = make_float3(0, 0, 0), nee_pdf = INV_PI / 4;
            unsigned state = stream(r.seed, b);
            const float z = 1 - 2 * random(state), angle = 2 * PI * random(state);
            direction = make_float3(sine(z) * cosf(angle), sine(z) * sinf(angle), z);
            prev = Vertex{false, LOBE_DIFFUSE, INV_PI / 4, 1.0f};
            hit = traverse(scene, origin, direction, 1e16f, distance);
        }
        if (hit.triangle == NONE) {
            const float3 f = throughput * environment(scene, direction, Ray{false, false, prev.lobe, float(b + 2u), 0});
            if (replay) {
                if (b == stop && rc == RC_ENV) {
                    return Shift{f / r.jac, density / r.jac};
                }
                if (rc == RC_NONE && end_type == END_ENV && b == end && !prev.rough) {
                    return Shift{f, 1.0f};
                }
                return fail;
            }
            Reservoir candidate = chain;
            if (extractBits(chain.path, PATH_RC, 2u) == RC_SURFACE) {
                candidate.radiance = safeDivide(f, chain_throughput);
            } else if (prev.rough) {
                // Reconnection to the environment direction, guarded by the roughness threshold only (Sec. 4.2)
                candidate.path = (b + 1u) << PATH_K | RC_ENV << PATH_RC | prev.lobe << PATH_LOBE_PREV;
                candidate.jac = prev.pdf;
                candidate.dir = direction;
            }
            offer(&sel, withEnd(candidate, END_ENV, b, f), f * scale / density);
            break;
        }
        // Project ray origin to hit point, through the medium
        throughput = throughput * exponential((make_float3(1, 1, 1) * sigma - medium.extinction) * distance);
        origin = origin + direction * distance;
    }
    return fail;
}

// The sample of r shifted into the pixel the camera sees, zero if its primary ray misses there
__device__ Shift shift(const Scene& scene, const Camera& camera, int pixel, uint3 size, const Reservoir& r) {
    Selection sel;
    float3 seen;
    if (r.w <= 0.0f) {
        return Shift{make_float3(0.0f, 0.0f, 0.0f), 0.0f};
    }
    const Domain dom = pixelDomain(scene, camera, pixel, size, r.seed);
    if (dom.hit.triangle == NONE) {
        return Shift{make_float3(0.0f, 0.0f, 0.0f), 0.0f};
    }
    return walk(scene, dom, r, true, 0.0f, sel, seen);
}

// Pixel coordinates a camera sees a position at
__device__ float2 project(const Camera& camera, float3 position, uint3 size) {
    const float3 d = position - camera.origin;
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

// Mean emission over the triangle's actual UVs and generated coordinates, keeping support for small emitting regions.
extern "C" __global__ void __raygen__lights() {
    const unsigned triangle = optixGetLaunchIndex().x;
    const Scene& scene = *(Scene*)optixGetSbtDataPointer();
    Material& material = scene.materials[triangle];
    if (!(material.emitted > 0)) return;
    constexpr unsigned LIGHT_SAMPLES = 256;
    unsigned state = hash(triangle);
    float mean = 0;
    for (unsigned i = 0; i < LIGHT_SAMPLES; ++i) {
        const float side = sqrtf((i + random(state)) / LIGHT_SAMPLES), along = random(state);
        const float3 emission = shade(scene, triangle, side * (1 - along), side * along,
            faceNormal(scene, triangle), -faceNormal(scene, triangle), {false, false, LOBE_NONE, 0, 0}).emissive;
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
    // The pixel's own seed even without a sample, its domain for later passes
    initial.r.seed = stream(pixel_seed, 0u);
    float3 seen = make_float3(0.0f, 0.0f, 0.0f);
    for (unsigned i = 0u; i < scene.settings.paths; i++) {
        Reservoir r = {};
        r.seed = stream(pixel_seed, i);
        const Domain dom = pixelDomain(scene, scene.camera, index, size, r.seed);
        float3 first;
        if (dom.hit.triangle != NONE) {
            walk(scene, dom, r, false, 1.0f / scene.settings.paths, initial, first);
        }
        seen = seen + (dom.hit.triangle == NONE
            ? environment(scene, normalize(dom.x1 - dom.x0), {true, false, LOBE_NONE, 1, 0}) : first)
            / scene.settings.paths;
    }
    scene.initial[index] = finalize(initial, 1.0f);
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
    const float3 before = dom.hit.triangle == NONE ? last.origin + dom.x1 - dom.x0
        : hitPosition(scene.previousVertices, dom.hit);
    const float2 then = project(last, before, size);
    scene.flow[index] = project(scene.camera, dom.x1, size) - then;
    const int x = int(floorf(then.x)), y = int(floorf(then.y));
    const float3 back = cross(last.x, last.y);
    scene.trust[index] = dot(back, before - last.origin) * dot(back, last.z) > 0.0f && x >= 0 && y >= 0
        && x < int(size.x) && y < int(size.y) && scene.previousSeen[y * size.x + x] == dom.hit.triangle;
    scene.seen[index] = dom.hit.triangle;
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
    Scene before = scene;
    if (scene.frame == 0u) {
        before.handle = scene.anchorHandle, before.vertices = scene.anchorVertices;
        before.normals = scene.anchorNormals, before.lights = scene.anchorLights, before.trails = scene.anchorTrails;
    }
    int q = scene.previous[index].c > 0.0f ? int(index) : -1;
    if (!still) {
        const Domain dom = pixelDomain(scene, scene.camera, index, size, r.seed);
        q = dom.hit.triangle == NONE ? -1 : temporalNeighbor(before, p, size, dom);
    }
    if (q >= 0) {
        const Reservoir temporal = scene.previous[q];
        // Optionally lower the confidence cap where the previous frame duplicated samples (Sec. 5), this biases the estimate
        const float duplicated = scene.settings.decorrelation ? scene.duplication[q] : 0.0f;
        const float cap = RESTIR_CAP + (RESTIR_CAP_MIN - RESTIR_CAP) * powf(duplicated, RESTIR_DUPLICATION_ALPHA);
        const float c_t = fminf(temporal.c, cap);
        const Shift to_current = still ? Shift{temporal.f, 1.0f} : shift(scene, scene.camera, index, size, temporal);
        const Shift to_previous = still ? Shift{r.f, 1.0f} : shift(before, scene.previousCamera, q, size, r);
        const float p_c = rgb_to_greyscale(r.f);
        const float p_t = rgb_to_greyscale(temporal.f);
        Selection sel = {};
        sel.random_state = stream(r.seed, STREAM_SELECT + 1u);
        offerShifted(&sel, r, Shift{r.f, 1.0f}, r.c * p_c / (r.c * p_c + c_t * rgb_to_greyscale(to_previous.f)));
        offerShifted(&sel, temporal, to_current, c_t * p_t / (c_t * p_t + r.c * rgb_to_greyscale(to_current.f)));
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
            const float share = (neighbor.c + c_pair) / c_sum;
            const float p_n = rgb_to_greyscale(neighbor.f);
            if (p_c > 0.0f) {
                canonical_mis += share * c_pair * p_c / (c_pair * p_c + neighbor.c * rgb_to_greyscale(to_there.f));
            }
            offerShifted(&sel, neighbor, to_here,
                share * neighbor.c * p_n / (neighbor.c * p_n + c_pair * rgb_to_greyscale(to_here.f)));
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
