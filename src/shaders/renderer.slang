import pathtracer;

// Imported types under names of their own
typealias FKHit = Hit;
typealias FKRay = Ray;
typealias FKSurface = Surface;
typealias FKMedium = Medium;
typealias FKDomain = Domain;
typealias FKLight = Light;

// Names apart from the imported ones
namespace fcpt {

struct Lens { float aperture, focus, blades, rotation, ratio, ortho, near, far; }; // Orthographic: rays along
// z's normal; near, far: depths rays start and end at
struct Camera { float3 origin, x, y, z; Lens lens; };
// A panorama: its number, 0 for none, the range of directions over u and v and the shift of its window
struct Projection { uint type; float range[4], shift[2]; };
[UnscopedEnum] enum Code : uint { END, PUSH, UV, NORMAL, IMAGE, ALPHA, NORMAL_MAP, ADD, SUBTRACT, MULTIPLY, DOT_PRODUCT,
    MAXIMUM, LOGARITHM, MULTIPLY_ADD, IMAGE_LINEAR, ALPHA_LINEAR, DIVIDE, SNAP, GENERATED, NOISE, IMAGE_CUBIC,
    ALPHA_CUBIC, POWER, EXPONENT, MINIMUM, LESS_THAN, FLOOR, MODULO, SINE, COSINE, TANGENT, ARCSINE, ARCCOSINE,
    ARCTANGENT, ARCTAN2, SINH, COSH, TANH, CROSS_PRODUCT, RGB_TO_HSV, HSV_TO_RGB, RGB_TO_HSL, HSL_TO_RGB,
    ROTATE, EQUIRECTANGULAR, MIRROR_BALL, POSITION, INCOMING, BACKFACING, DIELECTRIC,
    LIGHT_PATH, WHITE_NOISE, VORONOI, MAGIC, BRICK, OBJECT, VERTEX_COLOR, VERTEX_ALPHA,
    OBJECT_INFO, CAMERA_POINT, WINDOW, TRANSFORM, BOX, SHIFT, SHIFTED, BUMP, STORE, LOAD, ANIMATED, BAKED, SPECULAR,
    TRANSLUCENT, SHEEN, INSTANCER, ANISOTROPIC, MEDIUM, CURVES, HAIR_INFO, HAIR, PHASE, WORLD, GRID, VELVET, SKY,
    TOON, SELECT, PANORAMA, DISPERSION };
// MEDIUM, CURVES, WORLD, SKY and PANORAMA no program takes: a scene's varying media, strands, world volume, world
// sampled by its luminance and panoramic camera (CUDA's alone; its place kept, so the codes after it agree with the
// exporter's); PHASE marks a volume's Henyey-Greenstein asymmetry, VELVET a sheen of the Sheen BSDF's Ashikhmin
// distribution, TOON a toon lobe; SELECT, per channel, the second value where the first is not 0, else the third;
// DISPERSION a transmission's IOR spread by wavelength
struct Op { Code code; float3 value; };
struct Surface {
    float3 normal, albedo; float metallic, roughness; float3 emissive; float transparency, ior; float3 tint;
    float level, coverage; float3 absorption; float density; float3 scatter, translucent, sheen; float sheen_roughness;
    float anisotropy, anisotropic_rotation; float3 tangent, glow, hair; float phase, velvet; float3 toon;
    float dispersion;
};
static const uint SHADOWS = 1; // Visibility bit of shadow rays, which instances hidden from them clear
struct SceneMaterial { float emitted; uint program, hidden, layers, opaque, emission; };
struct Info { float location[3], color[4], index, random, axes[9]; uint attributes; };
struct LightNode { float3 low, high, w; float phi, cos_theta_o; uint child, instance; uint8_t leaf; };
// texspace: location and size of the mesh's texture space; majorant: its volume's largest extinction
static const uint STRANDS = 2; // An instance's world flag of strands, in its object's space
struct Instance { uint first, count, world; float matrix[12], adjugate[9]; Info info; float texspace[6], majorant;
    uint key; };
static const uint NONE = ~0u;
struct Hit { uint triangle, instance; float2 uv; };
struct Settings { uint restir, decorrelation, neighbors, bounces, paths, denoise, medium; };
static const int PAIRING_SIZES[] = {254, 230, 210};
static const uint QUEUE_HEADER = 3 + 2 * 40; // The shift queue's dispatch size, jobs per bin and jobs written per bin
// The passes by their indices in renderer.h's PROGRAMS
static const uint PASS_INITIAL = 0, PASS_TEMPORAL_COUNT = 1, PASS_TEMPORAL_PREPASS = 2, PASS_TEMPORAL_SHIFT = 3,
    PASS_TEMPORAL = 4, PASS_COUNT = 5, PASS_PREPASS = 6, PASS_SHIFT = 7, PASS_SPATIAL = 8, PASS_DUPLICATES = 9,
    PASS_BAKE = 10, PASS_LIGHTS = 11;
// Workgroups of a launch one high per row of them, the least count in x Vulkan guarantees, as FlexKernels' queue
// decodes them and optix_stubs.h dispatches them
static const uint ROW_GROUPS = 65535;
struct Scene {
    float4* accumulation; uint64_t handle; float3* vertices; float3* normals; float3* generated; float3* objects;
    float2* uvs; float4* colors; float4* tangents; Instance* instances; float4* attributes; float* passes;
    uint instanceCount;
    uint box; // The instance of the world's box, NONE without
    SceneMaterial* materials; LightNode* lights; uint64_t* trails; Op* ops; uint4* texels; uint count; Camera camera;
    Reservoir* previous; Reservoir* initial; Reservoir* temporal; float* duplication; Shift* shifts; int8_t* pairing[3];
    uint frame; Camera previousCamera; Settings settings;
    float4* mean; float2* flow; float* trust; uint* seen; uint* previousSeen; float3* previousVertices;
    Camera denoisedCamera;
    uint64_t anchorHandle; float3* anchorVertices; float3* anchorNormals; LightNode* anchorLights;
    uint64_t* anchorTrails;
    uint4* bakeTexels; // Texels only bakes read, images and tiles
    uint64_t* images; // Of each image the materials read, its texture by its index
    float4* points; uint* segments; // Strands: their points and radius, per segment its first point and strand,
    float4* strands; // per strand its first point, point count and random number, its root's UV and color
    float4* hairs; // Per level of a hair table
    uint environmentWidth, environmentHeight; // The grid the world bakes over, none where the same every way
    float2* environmentCdf; uint cdfWidth, cdfHeight; // Its luminance CDF, its marginal in the last column
    uint* queue; // The shift queue
    Scene* anchor; // The anchor's scene, in its record
    uint width, height; // The image's size, which shift passes launched over their queue need
    Projection cameraProjection, previousCameraProjection, denoisedCameraProjection;
};
// The images' textures, bindless: RGBA8 ones as their bytes, others as their floats' words
[[vk::binding(0, 0)]] Texture2D<uint4> textures[];
[[vk::binding(1, 0)]] Texture2D<float4> filtered[]; // And as floats, RGBA8 as k / 255 decoded from sRGB if it is
[[vk::binding(2, 0)]] SamplerState samplers[4]; // Linear, by extension: repeated, extended, clipped to none, mirrored

static const int STACK = 64;
static const int SLOTS = 32; // Values a program keeps for reuse
float4 mix(float4 a, float4 b, float t) { return a * (1 - t) + b * t; }
// Repeats into [0, 1)
float wrap(float coordinate) { return min(coordinate - floor(coordinate), 0.99999994f); }
// C's remainder, of the dividend's sign
int rem(int a, int b) { return a < 0 ? -(-a % b) : a % b; }
float random(inout uint state) { return ((state = hash(state)) >> 8) * (1.0f / 16777216.0f); }
// sin(PI * x) and cos(PI * x), x reduced exactly into [-1, 1] first
float sinpi(float x) { return sin(PI * (x - 2 * round(x / 2))); }
float cospi(float x) { return cos(PI * (x - 2 * round(x / 2))); }

static const uint LOBE_REFLECT = 2u;
static const uint LOBE_NONE = 3u;
static const uint LOBE_SHEEN_VELVET = 4u;  // The sheen or velvet lobe, which Light Path reads as a diffuse reflection
static const uint LOBE_TOON = 6u;  // The toon lobe, which Light Path reads as a diffuse reflection
// Share of a ray cone's width a mip level covers, 2^-1.5
static const float CONE_SHARE = 0.35355339;
// Ray a surface or the world is shaded for: from the camera or a shadow ray, its lobe, bounce and length,
// and its cone: its width where it hits and the mip level of the hit's UVs that width covers
struct Ray { bool camera, shadow; uint lobe; float depth, length, width = 0, level = 0; };
float lightPath(Ray ray, int output) {
    switch (output) {
        case 0: return float(ray.camera);
        case 1: return float(ray.shadow);
        case 2: return float(ray.lobe == LOBE_DIFFUSE || ray.lobe == LOBE_SHEEN_VELVET || ray.lobe == LOBE_TOON);
        case 3: return float(ray.lobe == LOBE_REFRACT || ray.lobe == LOBE_REFLECT);
        case 5: return float(ray.lobe == LOBE_DIFFUSE || ray.lobe == LOBE_REFLECT || ray.lobe == LOBE_SHEEN_VELVET
            || ray.lobe == LOBE_TOON);
        case 6: return float(ray.lobe == LOBE_REFRACT);
        case 8: return ray.length;
        default: return ray.depth;
    }
}

// Logarithm of a to the base b, zero where undefined
float logarithm(float a, float b) { return a > 0 && b > 0 && b != 1 ? log(a) / log(b) : 0; }
float3 logarithm(float3 a, float3 b) { return float3(logarithm(a.x, b.x), logarithm(a.y, b.y), logarithm(a.z, b.z)); }
// sRGB to linear
float decode(float c) { return c < 0.04045f ? max(c, 0) / 12.92f : pow((c + 0.055f) / 1.055f, 2.4f); }
// a to the power of b, zero where undefined
float power(float a, float b) {
    return b == 0 ? 1 : a == 0 || a < 0 && b != trunc(b) ? 0 : a > 0 ? pow(a, b)
        : (fmod(b, 2) == 0 ? 1 : -1) * pow(-a, b);
}
float3 power(float3 a, float3 b) { return float3(power(a.x, b.x), power(a.y, b.y), power(a.z, b.z)); }
// RGB to HSV and HSL and back
float3 toHsv(float3 c) {
    const float high = max(c.x, max(c.y, c.z)), delta = high - min(c.x, min(c.y, c.z));
    if (high == 0 || delta == 0) return float3(0, 0, high);
    const float3 d = (float3(high, high, high) - c) / delta;
    const float h = (c.x == high ? d.z - d.y : c.y == high ? 2 + d.x - d.z : 4 + d.y - d.x) / 6;
    return float3(h < 0 ? h + 1 : h, delta / high, high);
}
float3 fromHsv(float3 c) {
    const float s = c.y, v = c.z, h = (c.x == 1 ? 0 : c.x) * 6, i = floor(h), f = h - i;
    const float p = v * (1 - s), q = v * (1 - s * f), t = v * (1 - s * (1 - f));
    return s == 0 ? float3(v, v, v) : i == 0 ? float3(v, t, p) : i == 1 ? float3(q, v, p)
        : i == 2 ? float3(p, v, t) : i == 3 ? float3(p, q, v) : i == 4 ? float3(t, p, v)
        : float3(v, p, q);
}
float3 toHsl(float3 c) {
    const float high = max(c.x, max(c.y, c.z)), low = min(c.x, min(c.y, c.z));
    const float l = min(1, (high + low) / 2), delta = high - low;
    if (delta == 0) return float3(0, 0, l);
    const float h = c.x == high ? (c.y - c.z) / delta + (c.y < c.z ? 6 : 0) : c.y == high ? (c.z - c.x) / delta + 2
        : (c.x - c.y) / delta + 4;
    return float3(h / 6, l > 0.5f ? delta / (2 - high - low) : delta / (high + low), l);
}
float3 fromHsl(float3 c) {
    const float3 n = float3(abs(c.x * 6 - 3) - 1, 2 - abs(c.x * 6 - 2), 2 - abs(c.x * 6 - 4));
    const float chroma = (1 - abs(2 * c.z - 1)) * c.y;
    return (min(max(n, 0), 1) - 0.5f) * chroma + c.z;
}
uint rotate(uint x, int k) { return x << k | x >> (32 - k); }
// Bob Jenkins' lookup3 hash of n keys
uint jenkins(int n, uint x, uint y = 0, uint z = 0, uint w = 0) {
    uint a = 0xdeadbeefu + uint(n << 2) + 13 + x, b = 0xdeadbeefu + uint(n << 2) + 13 + y;
    uint c = 0xdeadbeefu + uint(n << 2) + 13 + z;
    if (n == 4) {
        a -= c; a ^= rotate(c, 4); c += b; b -= a; b ^= rotate(a, 6); a += c; c -= b; c ^= rotate(b, 8); b += a;
        a -= c; a ^= rotate(c, 16); c += b; b -= a; b ^= rotate(a, 19); a += c; c -= b; c ^= rotate(b, 4); b += a;
        a += w;
    }
    c ^= b; c -= rotate(b, 14); a ^= c; a -= rotate(c, 11); b ^= a; b -= rotate(a, 25); c ^= b; c -= rotate(b, 16);
    a ^= c; a -= rotate(c, 4); b ^= a; b -= rotate(a, 14); c ^= b; c -= rotate(b, 24);
    return c;
}
// Hash of the bits of n floats, in [0, 1]
float hashed(int n, float x, float y = 0, float z = 0, float w = 0) {
    return float(jenkins(n, asuint(x), asuint(y), asuint(z), asuint(w))) / float(0xFFFFFFFFu);
}
// White noise of the first dims components of p, w the fourth, its value or color
[noinline] float3 white(float3 p, int dims, bool color, float w) {
    const float v = dims == 1 ? hashed(1, p.x) : dims == 2 ? hashed(2, p.x, p.y) : dims == 3 ? hashed(3, p.x, p.y, p.z)
        : hashed(4, p.x, p.y, p.z, w);
    if (!color) return float3(v, v, v);
    return dims == 1 ? float3(v, hashed(2, p.x, 1), hashed(2, p.x, 2)) : dims == 2
        ? float3(v, hashed(3, p.x, p.y, 1), hashed(3, p.x, p.y, 2)) : dims == 3
        ? float3(v, hashed(4, p.x, p.y, p.z, 1), hashed(4, p.x, p.y, p.z, 2))
        : float3(v, hashed(4, p.z, p.x, w, p.y), hashed(4, w, p.z, p.y, p.x));
}
// PCG hash of 2 to 4 integers, shifting signed
void pcg(inout uint v[4], int dims) {
    for (int k = 0; k < dims; ++k) v[k] = v[k] * 1664525u + 1013904223u;
    for (int round = 0; round < 2; ++round) {
        if (round != 0) for (int k = 0; k < dims; ++k) v[k] ^= uint(int(v[k]) >> 16);
        if (dims == 2) { v[0] += v[1] * 1664525u; v[1] += v[0] * 1664525u; }
        else if (dims == 3) { v[0] += v[1] * v[2]; v[1] += v[2] * v[0]; v[2] += v[0] * v[1]; }
        else { v[0] += v[1] * v[3]; v[1] += v[2] * v[0]; v[2] += v[0] * v[1]; v[3] += v[1] * v[2]; }
    }
    for (int k = 0; k < dims; ++k) v[k] &= 0x7FFFFFFFu;
}
// Voronoi cell's point offset into o, and its color: lookup3 in 1D, signed PCG in 2D to 4D
float3 site(int c[4], int dims, out float o[4]) {
    o = {0, 0, 0, 0};
    if (dims == 1) return float3(o[0] = hashed(1, c[0]), hashed(2, c[0], 1), hashed(2, c[0], 2));
    uint v[4] = {uint(c[0]), uint(c[1]), uint(c[2]), uint(c[3])}, u[4] = {v[0], v[1], 0, 0};
    pcg(v, dims);
    for (int k = 0; k < dims; ++k) o[k] = float(v[k]) / float(0x7FFFFFFF);
    if (dims == 2) pcg(u, 3);
    return dims == 2 ? float3(u[0], u[1], u[2]) / float(0x7FFFFFFF) : float3(o[0], o[1], o[2]);
}
struct Cell { float distance; float3 color; float position[4]; };
// Voronoi texture: F1, F2 or smooth F1 and the metric by kind, randomness and smoothness in extra
Cell voronoi(float q[4], int dims, float3 kind, float3 extra) {
    const int feature = int(kind.x), metric = int(kind.y);
    const float randomness = min(max(extra.x, 0), 1), smoothness = min(max(extra.y / 2, 0), 0.5f);
    const int reach = feature == 2 && smoothness != 0 ? 2 : 1;
    int cell[4] = {0, 0, 0, 0}, count = 1;
    for (int k = 0; k < dims; ++k) { cell[k] = int(floor(q[k])); count *= 2 * reach + 1; }
    float best[2] = {3.402823e38f, 3.402823e38f}, smooth = 0, h = -1, positions[2][4] = {{0, 0, 0, 0}, {0, 0, 0, 0}};
    float3 colors[2] = {float3(0), float3(0)};
    for (int n = 0; n < count; ++n) { // Through the cells around, the first axis fastest
        int c[4] = {0, 0, 0, 0};
        float o[4], position[4] = {0, 0, 0, 0}, sum = 0, high = 0;
        for (int k = 0, m = n; k < dims; ++k, m /= 2 * reach + 1) c[k] = cell[k] + m % (2 * reach + 1) - reach;
        const float3 color = site(c, dims, o);
        for (int k = 0; k < dims; ++k) {
            position[k] = c[k] - cell[k] + o[k] * randomness;
            const float d = abs(position[k] - (q[k] - cell[k]));
            sum += metric == 0 ? d * d : metric == 3 ? pow(d, kind.z) : d;
            high = max(high, d);
        }
        const float d = metric == 0 ? sqrt(sum) : metric == 2 ? high : metric == 3 ? pow(sum, 1 / kind.z) : sum;
        if (reach == 2) { // Smooth F1, blending every cell's in
            if (h == -1) h = 1;
            else {
                const float x = min(max(0.5f + 0.5f * (smooth - d) / smoothness, 0), 1);
                h = x * x * (3 - 2 * x);
            }
            const float correction = smoothness * h * (1 - h);
            smooth = smooth * (1 - h) + d * h - correction;
            colors[0] = mix(colors[0], color, h) - float3(1, 1, 1) * (correction / (1 + 3 * smoothness));
            for (int k = 0; k < dims; ++k)
                positions[0][k] = positions[0][k] * (1 - h) + position[k] * h - correction / (1 + 3 * smoothness);
        } else if (d < best[0]) {
            best[1] = best[0]; best[0] = d; colors[1] = colors[0]; colors[0] = color;
            for (int k = 0; k < 4; ++k) { positions[1][k] = positions[0][k]; positions[0][k] = position[k]; }
        } else if (d < best[1]) {
            best[1] = d; colors[1] = color;
            for (int k = 0; k < 4; ++k) positions[1][k] = position[k];
        }
    }
    const int f = int(feature == 1);
    Cell result = {reach == 2 ? smooth : best[f], colors[f], {0, 0, 0, 0}};
    for (int k = 0; k < dims; ++k) result.position[dims == 1 ? 3 : k] = positions[f][k] + cell[k];
    return result;
}
// From the point to the point of the cell at offset from its own
void vectorTo(int cell[4], float local[4], int dims, float randomness, int offset[4], out float v[4]) {
    int c[4] = {0, 0, 0, 0};
    float o[4];
    for (int k = 0; k < dims; ++k) c[k] = cell[k] + offset[k];
    site(c, dims, o);
    v = {0, 0, 0, 0};
    for (int k = 0; k < dims; ++k) v[k] = offset[k] + o[k] * randomness - local[k];
}
// Distance of a point to its Voronoi cell's edge, or the cell's n-sphere radius
float edge(float q[4], int dims, float randomness, bool sphere) {
    int cell[4] = {0, 0, 0, 0}, count = 1;
    float local[4] = {0, 0, 0, 0};
    for (int k = 0; k < dims; ++k) { cell[k] = int(floor(q[k])); local[k] = q[k] - cell[k]; count *= 3; }
    if (dims == 1 && !sphere) {
        float v[3];
        for (int i = -1; i <= 1; ++i) {
            int offset[4] = {i, 0, 0, 0};
            float w[4];
            vectorTo(cell, local, dims, randomness, offset, w);
            v[i + 1] = w[0];
        }
        return min(abs((v[1] + v[0]) / 2), abs((v[1] + v[2]) / 2));
    }
    float best = 3.402823e38f, closest[4] = {0, 0, 0, 0};
    int offset[4] = {0, 0, 0, 0};
    for (int n = 0; n < count; ++n) {
        int c[4] = {0, 0, 0, 0};
        float v[4], d = 0;
        for (int k = 0, m = n; k < dims; ++k, m /= 3) c[k] = m % 3 - 1;
        vectorTo(cell, local, dims, randomness, c, v);
        for (int k = 0; k < dims; ++k) d += v[k] * v[k];
        if (d < best) {
            best = d;
            for (int k = 0; k < dims; ++k) { closest[k] = v[k]; offset[k] = c[k]; }
        }
    }
    best = 3.402823e38f;
    for (int n = 0; n < count; ++n) {
        int c[4] = {0, 0, 0, 0};
        float v[4], perpendicular = 0, along = 0;
        for (int k = 0, m = n; k < dims; ++k, m /= 3) c[k] = m % 3 - 1 + (sphere ? offset[k] : 0);
        if (sphere && n == (count - 1) / 2) continue; // The nearest other point to the closest
        vectorTo(cell, local, dims, randomness, c, v);
        for (int k = 0; k < dims; ++k) {
            const float e = v[k] - closest[k];
            perpendicular += e * e;
            along += (closest[k] + v[k]) / 2 * e;
        }
        if (sphere) best = min(best, perpendicular);
        else if (perpendicular > 0.0001f) best = min(best, along / sqrt(perpendicular));
    }
    return sphere ? sqrt(best) / 2 : best;
}
// Fractal Voronoi: octaves up to the detail of distance, color or position, edge distance, or n-sphere radius
[noinline] float3 fractalVoronoi(float3 p, float3 kind, float3 extra, float3 fractal, float3 shape) {
    const float detail = min(max(fractal.x, 0), 15), roughness = min(max(fractal.y, 0), 1);
    const float rmd = detail - floor(detail), randomness = min(max(extra.x, 0), 1);
    const float farthest = shape.x;
    const int dims = int(shape.z);
    float q[4] = {p.x, p.y, p.z, shape.y};
    if (kind.x == 4) return float3(1, 1, 1) * edge(q, dims, randomness, true);
    float amplitude = 1, total = 0, scale = 1;
    if (kind.x == 3) {
        float distance = 8;
        total = farthest;
        for (int i = 0; i <= ceil(detail); ++i) {
            float r[4];
            for (int k = 0; k < 4; ++k) r[k] = q[k] * scale;
            const float octave = edge(r, dims, randomness, false);
            if (detail == 0 || roughness == 0) {
                distance = octave;
                break;
            }
            const float weight = amplitude * (i <= detail ? 1 : rmd);
            total = total * (1 - weight) + farthest / scale * weight;
            distance = distance * (1 - weight) + min(distance, octave / scale) * weight;
            scale *= fractal.z;
            amplitude *= roughness;
        }
        return float3(1, 1, 1) * (farthest > 0 ? distance / total : distance);
    }
    Cell sum = {0, float3(0), {0, 0, 0, 0}};
    for (int i = 0; i <= ceil(detail); ++i) {
        float r[4];
        for (int k = 0; k < 4; ++k) r[k] = q[k] * scale;
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
    if (farthest > 0) { sum.distance /= total * farthest; sum.color = sum.color / total; }
    return extra.z == 0 ? float3(1, 1, 1) * sum.distance : extra.z == 1 ? sum.color : extra.z == 2
        ? float3(sum.position[0], sum.position[1], sum.position[2]) : float3(1, 1, 1) * sum.position[3];
}
// Magic texture by the scale, depth and distortion in params
float3 magic(float3 p, float3 params) {
    const float d = params.z;
    p = float3(fmod(p.x * params.x, 2 * PI), fmod(p.y * params.x, 2 * PI), fmod(p.z * params.x, 2 * PI));
    float x = sinpi((p.x + p.y + p.z) * 5 * INV_PI), y = cospi((-p.x + p.y - p.z) * 5 * INV_PI);
    float z = -cospi((-p.x - p.y + p.z) * 5 * INV_PI);
    if (params.y > 0) { x *= d; y *= d; z *= d; }
    for (int i = 0; i < min(params.y, 10); ++i) switch (i) {
        case 0: y = -cospi((x - y + z) * INV_PI) * d; break;
        case 1: x = cospi((x - y - z) * INV_PI) * d; break;
        case 2: z = sinpi((-x - y - z) * INV_PI) * d; break;
        case 3: x = -cospi((-x + y - z) * INV_PI) * d; break;
        case 4: y = -sinpi((-x + y + z) * INV_PI) * d; break;
        case 5: y = -cospi((-x + y + z) * INV_PI) * d; break;
        case 6: x = cospi((x + y + z) * INV_PI) * d; break;
        case 7: z = sinpi((x + y - z) * INV_PI) * d; break;
        case 8: x = -cospi((-x - y + z) * INV_PI) * d; break;
        default: y = -sinpi((x - y + z) * INV_PI) * d; break;
    }
    return float3(0.5f, 0.5f, 0.5f) - float3(x, y, z) / (d != 0 ? 2 * d : 1);
}
// Brick texture's tint and mortar; a: mortar size, smoothness, bias; b: width, height, offset; c: frequencies
float3 brick(float3 p, float3 a, float3 b, float3 c) {
    const int row = int(floor(p.y / b.y)), offset_frequency = int(c.x), squash_frequency = int(c.z);
    float width = b.x, offset = 0;
    if (offset_frequency != 0 && squash_frequency != 0) {
        width *= rem(row, squash_frequency) != 0 ? 1 : c.y;
        offset = rem(row, offset_frequency) != 0 ? 0 : width * b.z;
    }
    const int column = int(floor((p.x + offset) / width));
    const float x = p.x + offset - width * column, y = p.y - b.y * row;
    uint n = uint(((row << 16) + (column & 0xFFFF) + 1013) & 0x7fffffff); // Integer noise of the brick
    n = (n >> 13) ^ n;
    const float noise = 0.5f * float((n * (n * n * 60493u + 19990303u) + 1376312589u) & 0x7fffffffu) / 1073741824.0f;
    float distance = min(min(x, y), min(width - x, b.y - y)), mortar = float((distance) < a.x);
    if (mortar != 0 && a.y != 0) {
        distance = min(max((1 - distance / a.x) / a.y, 0), 1);
        mortar = distance * distance * (3 - 2 * distance);
    }
    return float3(min(max(noise + a.z, 0), 1), mortar, 0);
}
float ramp(float a, float b, float blend) { return min(max((a / (a + b) - 0.5f * (1 - blend)) / blend, 0), 1); }
// Weights of the box projection's axes by the normal
float3 box(float3 n, float blend) {
    n = abs(n) / (abs(n.x) + abs(n.y) + abs(n.z));
    const float limit = 0.5f * (1 + blend);
    if (n.x > limit * (n.x + n.y) && n.x > limit * (n.x + n.z)) return float3(1, 0, 0);
    if (n.y > limit * (n.x + n.y) && n.y > limit * (n.y + n.z)) return float3(0, 1, 0);
    if (n.z > limit * (n.x + n.z) && n.z > limit * (n.y + n.z)) return float3(0, 0, 1);
    if (blend <= 0) return float3(1, 0, 0);
    if (n.z < (1 - limit) * (n.y + n.x)) return float3(ramp(n.x, n.y, blend), 1 - ramp(n.x, n.y, blend), 0);
    if (n.x < (1 - limit) * (n.y + n.z)) return float3(0, ramp(n.y, n.z, blend), 1 - ramp(n.y, n.z, blend));
    if (n.y < (1 - limit) * (n.x + n.z)) return float3(ramp(n.x, n.z, blend), 0, 1 - ramp(n.x, n.z, blend));
    return (n * (2 - limit) + float3(1, 1, 1) * (limit - 1)) / (2 * limit - 1);
}
// Gradient of a lattice point picked by its hash, at the offset f from it
float gradient(uint h, float f[4], int dims) {
    if (dims == 1) return ((h & 8) != 0 ? -1 : 1) * float(1 + (h & 7)) * f[0];
    if (dims == 2) return ((h & 1) != 0 ? -1 : 1) * f[int((h & 7) >= 4)] + ((h & 2) != 0 ? -2 : 2) * f[int((h & 7) < 4)];
    if (dims == 3) h &= 15;
    const float u = f[int((h & 31) >= (dims == 3 ? 8 : 24))], v = dims == 3 ? f[h < 4 ? 1 : h == 12 || h == 14 ? 0 : 2]
        : f[(h & 31) < 16 ? 1 : 2], s = dims == 3 ? 0 : f[(h & 31) < 8 ? 2 : 3];
    return ((h & 1) != 0 ? -u : u) + ((h & 2) != 0 ? -v : v) + ((h & 4) != 0 ? -s : s);
}
float fade(float t) { return t * t * t * (t * (t * 6 - 15) + 10); }
// Repeats every 100000, half a cell off past a million, for float precision
float wrapped(float x) { return fmod(x, 100000) + 0.5f * float(abs(x) >= 1000000); }
// Signed Perlin noise of p's first components and w: lattice gradients blended by faded distances
float noise(float3 p, float w, int dims) {
    p = float3(wrapped(p.x), wrapped(p.y), wrapped(p.z));
    w = wrapped(w);
    if (dims == 3) {
        const float3 low = floor(p);
        float sum = 0;
        for (uint corner = 0; corner < 8; ++corner) {
            const float3 d = float3(corner & 1, corner >> 1 & 1, corner >> 2), f = p - low - d;
            const uint h = jenkins(3, uint(int(low.x) + int(d.x)), uint(int(low.y) + int(d.y)),
                uint(int(low.z) + int(d.z))) & 15;
            const float u = h < 8 ? f.x : f.y, v = h < 4 ? f.y : h == 12 || h == 14 ? f.x : f.z;
            const float weight = (d.x != 0 ? fade(f.x + 1) : 1 - fade(f.x))
                * (d.y != 0 ? fade(f.y + 1) : 1 - fade(f.y)) * (d.z != 0 ? fade(f.z + 1) : 1 - fade(f.z));
            sum += weight * (((h & 1) != 0 ? -u : u) + ((h & 2) != 0 ? -v : v));
        }
        return 0.9820f * sum;
    }
    const float q[4] = {p.x, p.y, p.z, w}, scales[4] = {0.25f, 0.6616f, 0.9820f, 0.8344f};
    float sum = 0;
    for (int corner = 0; corner < 1 << dims; ++corner) {
        float weight = 1, f[4] = {0, 0, 0, 0};
        int x[4] = {0, 0, 0, 0};
        for (int k = 0; k < dims; ++k) {
            const int b = corner >> k & 1;
            x[k] = int(floor(q[k])) + b;
            f[k] = q[k] - floor(q[k]) - b;
            weight *= b != 0 ? fade(f[k] + 1) : 1 - fade(f[k]);
        }
        sum += weight * gradient(jenkins(dims, uint(x[0]), uint(x[1]), uint(x[2]), uint(x[3])), f, dims);
    }
    return scales[dims - 1] * sum;
}
// Fractal noise: octaves up to the detail as fBm, multifractal, hetero terrain, hybrid or ridged multifractal
[noinline] float fractal(float3 p, float3 params, float3 extra, float w, int dims) {
    const float detail = min(max(params.x, 0), 15), roughness = max(params.y, 0), lacunarity = params.z;
    const float offset = extra.x, gain = extra.y, rmd = detail - floor(detail);
    const int octaves = int(detail), type = int(extra.z);
    if (type < 2) {
        float scale = 1, amp = 1, maxamp = 0, sum = 0;
        for (int i = 0; i <= octaves; ++i, amp *= roughness, scale *= lacunarity) {
            sum += noise(p * scale, w * scale, dims) * amp;
            maxamp += amp;
        }
        const float whole = type != 0 ? sum : 0.5f * sum / maxamp + 0.5f;
        if (rmd == 0) return whole;
        sum += noise(p * scale, w * scale, dims) * amp;
        return whole * (1 - rmd) + (type != 0 ? sum : 0.5f * sum / (maxamp + amp) + 0.5f) * rmd;
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
            p = p * lacunarity;
            w *= lacunarity;
            for (int i = 1; i <= octaves; ++i, pwr *= roughness, p = p * lacunarity, w *= lacunarity)
                value += (noise(p, w, dims) + offset) * pwr * value;
            return rmd != 0 ? value + rmd * (noise(p, w, dims) + offset) * pwr * value : value;
        case 4:
            for (int i = 0; weight > 0.001f && i <= octaves; ++i, p = p * lacunarity, w *= lacunarity) {
                weight = min(weight, 1);
                signal = (noise(p, w, dims) + offset) * pwr;
                pwr *= roughness;
                value += weight * signal;
                weight *= gain * signal;
            }
            return rmd != 0 && weight > 0.001f ? value + rmd * min(weight, 1) * (noise(p, w, dims) + offset) * pwr
                : value;
        default:
            signal = offset - abs(noise(p, w, dims));
            signal *= signal;
            value = signal;
            pwr = roughness;
            for (int i = 1; i <= octaves; ++i, pwr *= roughness) {
                p = p * lacunarity;
                w *= lacunarity;
                weight = min(max(signal * gain, 0), 1);
                signal = offset - abs(noise(p, w, dims));
                signal *= signal * weight;
                value += signal * pwr;
            }
            return value;
    }
}
// Cubic B-spline weights of the four texels around t
float spline(float t, int k) {
    return k == 0 ? (1 - t) * (1 - t) * (1 - t) / 6 : k == 1 ? (t * t * (3 * t - 6) + 4) / 6
        : k == 2 ? (t * (t * (3 - 3 * t) + 3) + 1) / 6 : t * t * t / 6;
}
// Texel of the op's image by its extension; RGBA8 as k / 255, sRGB decoded to linear
float4 texel(Scene* scene, Op op, uint image, int x, int y) {
    const int width = int(asuint(op.value.y) & 0xFFFFF), height = int(asuint(op.value.z) & 0xFFFFFF);
    const int extension = int(asuint(op.value.z) >> 24 & 3);
    if (extension == 2 && (x < 0 || x >= width || y < 0 || y >= height)) return float4(0, 0, 0, 0);
    if (extension == 1) { x = min(max(x, 0), width - 1); y = min(max(y, 0), height - 1); }
    // Repeated images wrap once, mirrored ones over an image and its reflection; extended and clipped are in range
    if (extension == 0) { x = (rem(x, width) + width) % width; y = (rem(y, height) + height) % height; }
    if (extension == 3) {
        x = (rem(x, 2 * width) + 2 * width) % (2 * width);
        y = (rem(y, 2 * height) + 2 * height) % (2 * height);
        x = x < width ? x : 2 * width - 1 - x; y = y < height ? y : 2 * height - 1 - y;
    }
    const uint i = y * width + x;
    uint4* texels = ((asuint(op.value.z) >> 30 & 1) != 0 ? scene.bakeTexels : scene.texels) + asuint(op.value.x);
    const bool apart = asuint(op.value.z) >> 31 != 0; // Bit 31: an image's texture, the read's; 30: of only bakes'
    if ((asuint(op.value.z) >> 26 & 3) != 1) // Floats, halves or 16-bit UNORM, a texture's whole texel by its view of
        return apart ? filtered[NonUniformResourceIndex(image)].Load(int3(x, y, 0)) : asfloat(texels[i]); // floats
    const uint4 b = apart ? textures[NonUniformResourceIndex(image)].Load(int3(x, y, 0))
        : texels[i / 4][i % 4] >> uint4(0, 8, 16, 24) & 255;
    const float4 c = float4(b) * (1.0f / 255);
    return (asuint(op.value.z) >> 29 & 1) != 0 ? float4(decode(c.x), decode(c.y), decode(c.z), c.w) : c;
}
// v from object to world or back, or from world to camera or back, by mode: point, direction or normal
float3 transform(Scene* scene, float3 v, int mode, Info info) {
    const float3 x = float3(info.axes[0], info.axes[1], info.axes[2]), y = float3(info.axes[3], info.axes[4], info.axes[5]);
    const float3 z = float3(info.axes[6], info.axes[7], info.axes[8]);
    const float3 t = float3(info.location[0], info.location[1], info.location[2]);
    const Camera c = scene.camera;
    const float3 r = normalize(c.x), u = normalize(c.y), f = normalize(cross(c.y, c.x));
    const float3 i = cross(y, z) / dot(x, cross(y, z)), j = cross(z, x) / dot(x, cross(y, z));
    const float3 k = cross(x, y) / dot(x, cross(y, z)); // The rows of the axes' inverse
    if (mode == 3) v = v - t;
    if (mode == 6) v = v - c.origin;
    switch (mode) {
        case 0: return x * v.x + y * v.y + z * v.z + t;
        case 1: return x * v.x + y * v.y + z * v.z;
        case 2: return normalize(i * v.x + j * v.y + k * v.z);
        case 3: case 4: return float3(dot(i, v), dot(j, v), dot(k, v));
        case 5: return normalize(float3(dot(x, v), dot(y, v), dot(z, v)));
        case 6: case 7: return float3(dot(r, v), dot(u, v), dot(f, v));
        case 8: return c.origin + r * v.x + u * v.y + f * v.z;
        default: return r * v.x + u * v.y + f * v.z;
    }
}
// Point shaded: UV, generated and object points, color, position, barycentrics, triangle and instance
struct Point {
    float u, v; float3 generated, object; float4 color; float3 position; float s, t; uint triangle, instance;
};
// Whether the scene's programs take the step
[vk::constant_id(0)] const uint64_t OPS0 = 0xFFFFFFFFFFFFFFFFull;
[vk::constant_id(1)] const uint64_t OPS1 = 0xFFFFFFFFFFFFFFFFull;
bool used(uint code) { return ((code >> 6 == 0 ? OPS0 : OPS1) >> (code & 63) & 1) != 0; }
#ifndef EXTENDED // Nor varying media and strands
#define used(code) (code != MEDIUM && code != CURVES && code != HAIR_INFO && code != HAIR && code != GRID && used(code))
#endif
#define CASE(code) case code: if (!used(code)) break;
// Surface the program resolves to at the point
[noinline] Surface shade(Scene* scene, uint program, float3 normal, float3x3 tbn, Point point, float3 incoming,
    bool backfacing, Ray ray, Info info, float material = 0) {
    Point at = point;
    float3 stack[STACK], saved[SLOTS];
    int top = 0;
    for (Op* op = scene.ops + program; op.code != END; ++op) switch (op.code) {
        CASE(PUSH) stack[top++] = op.value; break;
        CASE(STORE) saved[asuint(op.value.x)] = stack[top - 1]; break;
        CASE(LOAD) stack[top++] = saved[asuint(op.value.x)]; break;
        CASE(SPECULAR) break;
        CASE(TRANSLUCENT) break;
        CASE(SHEEN) break;
        CASE(ANISOTROPIC) break;
        CASE(PHASE) break;
        CASE(VELVET) break;
        CASE(TOON) break;
        CASE(DISPERSION) break;
        CASE(HAIR) stack[top - 1] = normalize(transform(scene, tbn[0], 1, info)) * stack[top - 1].x; break; // Its fiber
        CASE(UV) stack[top++] = float3(at.u, at.v, 0); break;
        CASE(GENERATED) stack[top++] = at.generated; break;
        CASE(OBJECT) stack[top++] = at.object; break;
        CASE(TRANSFORM) --top; stack[top - 1] = transform(scene, stack[top - 1], int(stack[top].x), info); break;
        case CAMERA_POINT: case WINDOW: { // In the camera's space, right, up and forward, or of its window, of the
            if (!used(CAMERA_POINT) && !used(WINDOW)) break;
            const Camera c = scene.camera; // world along its direction from the camera
            const float3 d = program == scene.materials[scene.count].program ? at.position : at.position - c.origin;
            const float3 forward = normalize(cross(c.y, c.x));
            const float3 q = c.lens.ortho != 0 ? d - c.z : d * (dot(c.z, forward) / dot(d, forward)) - c.z; // On its
            // image plane
            stack[top++] = op.code == CAMERA_POINT ? float3(dot(d, normalize(c.x)), dot(d, normalize(c.y)),
                dot(d, forward)) : float3(dot(q, c.x) / dot(c.x, c.x) + 1, dot(q, c.y) / dot(c.y, c.y) + 1, 0) / 2;
        } break;
        CASE(VERTEX_COLOR) stack[top++] = at.color.xyz; break;
        CASE(VERTEX_ALPHA) stack[top++] = float3(1, 1, 1) * at.color.w; break;
        CASE(OBJECT_INFO) { // Its location, color, alpha, pass index, material's pass index or random number
            const int output = int(stack[top - 1].x);
            stack[top - 1] = output == 0 ? float3(info.location[0], info.location[1], info.location[2]) : output == 1
                ? float3(info.color[0], info.color[1], info.color[2]) : float3(1, 1, 1)
                * (output == 2 ? info.color[3] : output == 3 ? info.index : output == 4 ? material : info.random);
        } break;
        CASE(HAIR_INFO) { // Of the strand at the point, else none: whether one, its intercept, by its points from the
            const bool strand = scene.instances[point.instance].world == STRANDS; // root, or random
            const float4 root = strand ? scene.strands[3 * scene.segments[2 * point.triangle + 1]] : float4(0, 0, 0, 0);
            const float output = stack[top - 1].x;
            stack[top - 1] = float3(1, 1, 1) * (output == 5 ? root.z : !strand ? 0 : output == 0 ? 1 : output == 1
                ? (point.s + scene.segments[2 * point.triangle] - asuint(root.x)) / (asuint(root.y) - 1) : 0);
        } break;
        CASE(INSTANCER) { // An instancer attribute of its instance, its color or, odd, its alpha
            const int k = int(stack[top - 1].x);
            const float4 v = scene.attributes[info.attributes + k / 2];
            stack[top - 1] = k % 2 != 0 ? float3(1, 1, 1) * v.w : v.xyz;
        } break;
        CASE(NORMAL) stack[top++] = normal; break;
        CASE(POSITION) stack[top++] = at.position; break;
        CASE(SHIFT) // Pushes its own point's index before the height there
            at = shifted(scene, point, ray, int(stack[top - 1].x)); break;
        CASE(SHIFTED) --top; stack[top - 1] = stack[top]; at = point; break;
        CASE(BUMP) { // The normal bent by the height's gradient
            top -= 4;
            const float3 n = stack[top - 1], dx = shifted(scene, point, ray, 1).position - at.position,
                dy = shifted(scene, point, ray, 2).position - at.position;
            const float3 rx = cross(dy, n), ry = cross(n, dx);
            const float det = dot(dx, rx);
            const float3 bent = n * abs(det) - ((stack[top + 1].x - stack[top].x) * rx
                + (stack[top + 2].x - stack[top].x) * ry) * (stack[top + 3].y * sign(det));
            stack[top - 1] = dot(bent, bent) > 0 ? normalize(normalize(bent) * max(stack[top + 3].x, 0)
                + n * (1 - max(stack[top + 3].x, 0))) : n;
        } break;
        CASE(INCOMING) stack[top++] = incoming; break;
        CASE(BACKFACING) stack[top++] = float3(1, 1, 1) * float(backfacing); break;
        CASE(LIGHT_PATH) stack[top - 1] = float3(1, 1, 1) * lightPath(ray, int(stack[top - 1].x)); break;
        CASE(BAKED) { // A bake's texels, halves two to a texel, read linearly at the UV, extended at its edges or
            const int width = int(asuint(op.value.y)), height = int(asuint(op.value.z) & 0xFFFFFF); // repeating
            const float x = stack[top - 1].x * width - 0.5f, y = stack[top - 1].y * height - 0.5f;
            const int i = int(floor(x)), j = int(floor(y));
            const bool repeating = (asuint(op.value.z) >> 29 & 1) != 0;
            float3 c[4];
            for (int k = 0; k < 4; ++k) {
                const int a = j + k / 2, b = i + k % 2;
                const uint t = (repeating ? (rem(a, height) + height) % height : min(max(a, 0), height - 1)) * width
                    + (repeating ? (rem(b, width) + width) % width : min(max(b, 0), width - 1));
                const uint4 pair = scene.texels[asuint(op.value.x) + t / 2];
                const uint2 h = t % 2 == 0 ? pair.xy : pair.zw;
                c[k] = float3(f16tof32(h.x), f16tof32(h.x >> 16), f16tof32(h.y));
            }
            stack[top - 1] = mix(mix(c[0], c[1], x - i), mix(c[2], c[3], x - i), y - j);
        } break;
        CASE(GRID) { // A grid's voxels, halves eight to a texel, read linearly at its point in [0, 1], faces extended
            const int n[3] = {int(asuint(op.value.y)), int(asuint(op.value.z) & 0xFFFF), int(asuint(op.value.z) >> 16)};
            const float3 g = stack[top - 1];
            const float x = g.x * n[0] - 0.5f, y = g.y * n[1] - 0.5f, z = g.z * n[2] - 0.5f;
            const int i = int(floor(x)), j = int(floor(y)), k = int(floor(z));
            float c = 0;
            for (int m = 0; m < 8; ++m) {
                const int a = min(max(i + (m & 1), 0), n[0] - 1), b = min(max(j + (m >> 1 & 1), 0), n[1] - 1);
                const int d = min(max(k + (m >> 2), 0), n[2] - 1);
                const uint t = uint((d * n[1] + b) * n[0] + a);
                const uint word = scene.texels[asuint(op.value.x) + t / 8][t / 2 % 4];
                c += ((m & 1) != 0 ? x - i : 1 - (x - i)) * ((m & 2) != 0 ? y - j : 1 - (y - j))
                    * ((m & 4) != 0 ? z - k : 1 - (z - k)) * f16tof32(t % 2 == 0 ? word : word >> 16);
            }
            stack[top - 1] = float3(c, c, c);
        } break;
        case IMAGE: case ALPHA: case IMAGE_LINEAR: case ALPHA_LINEAR: case IMAGE_CUBIC: case ALPHA_CUBIC: { // Repeating
            if (!used(IMAGE) && !used(ALPHA) && !used(IMAGE_LINEAR) && !used(ALPHA_LINEAR) && !used(IMAGE_CUBIC)
                && !used(ALPHA_CUBIC)) break;
            const uint width = asuint(op.value.y), height = asuint(op.value.z);
            const bool repeat = (height >> 24 & 3) == 0;
            const uint image = height >> 31 != 0 ? uint(scene.images[2 * asuint(op.value.x)]) : 0; // Its texture, once
            float x = (repeat ? wrap(stack[top - 1].x) : stack[top - 1].x) * (width & 0xFFFFF);
            float y = (repeat ? wrap(stack[top - 1].y) : stack[top - 1].y) * (height & 0xFFFFFF);
            float4 color;
            if (op.code == IMAGE || op.code == ALPHA) color = texel(scene, *op, image, int(floor(x)), int(floor(y)));
            if ((op.code == IMAGE_LINEAR || op.code == ALPHA_LINEAR) && height >> 31 != 0) // In hardware, by its
                color = filtered[NonUniformResourceIndex(uint(scene.images[2 * asuint(op.value.x) + 1]))].SampleLevel(
                    samplers[height >> 24 & 3], stack[top - 1].xy, ray.width > 0 ? ray.level + log2(float(width
                    & 0xFFFFF) * (height & 0xFFFFFF)) / 2 + (int(width) >> 20) / 64.0f : 0); // extension, at the level
                    // of its cone, its texels and the change of its point by the UVs
            else if (op.code == IMAGE_LINEAR || op.code == ALPHA_LINEAR) {
                x -= 0.5f; y -= 0.5f;
                const int i = int(floor(x)), j = int(floor(y));
                color = mix(mix(texel(scene, *op, image, i, j), texel(scene, *op, image, i + 1, j), x - i),
                    mix(texel(scene, *op, image, i, j + 1), texel(scene, *op, image, i + 1, j + 1), x - i), y - j);
            }
            if (op.code == IMAGE_CUBIC || op.code == ALPHA_CUBIC) {
                x -= 0.5f; y -= 0.5f;
                const int i = int(floor(x)), j = int(floor(y));
                color = float4(0, 0, 0, 0);
                for (int k = 0; k < 16; ++k) {
                    const float4 t = texel(scene, *op, image, i + k % 4 - 1, j + k / 4 - 1);
                    const float w = spline(x - i, k % 4) * spline(y - j, k / 4);
                    color = float4(color.x + t.x * w, color.y + t.y * w, color.z + t.z * w, color.w + t.w * w);
                }
            }
            stack[top - 1] = op.code == IMAGE || op.code == IMAGE_LINEAR || op.code == IMAGE_CUBIC
                ? color.xyz
                : float3(1, 1, 1) * color.w;
        } break;
        CASE(NORMAL_MAP) {
            const float3 n = transform(scene, tangentToWorldNormalMap(stack[top - 1] * 2 - float3(1, 1, 1), tbn), 2,
                info);
            stack[top - 1] = isfinite(dot(n, n)) ? n : normal;
        } break;
        CASE(ADD) --top; stack[top - 1] = stack[top - 1] + stack[top]; break;
        CASE(SUBTRACT) --top; stack[top - 1] = stack[top - 1] - stack[top]; break;
        CASE(MULTIPLY) --top; stack[top - 1] = stack[top - 1] * stack[top]; break;
        CASE(DOT_PRODUCT) --top; stack[top - 1] = float3(1, 1, 1) * dot(stack[top - 1], stack[top]); break;
        CASE(MAXIMUM) --top; stack[top - 1] = max(stack[top - 1], stack[top]); break;
        CASE(LOGARITHM) --top; stack[top - 1] = logarithm(stack[top - 1], stack[top]); break;
        CASE(MULTIPLY_ADD) top -= 2; stack[top - 1] = stack[top - 1] * stack[top] + stack[top + 1]; break;
        CASE(SELECT) top -= 2; stack[top - 1] = select(stack[top - 1] != float3(0, 0, 0), stack[top], stack[top + 1]);
            break;
        CASE(DIVIDE) --top; stack[top - 1] = safeDivide(stack[top - 1], stack[top]); break;
        CASE(SNAP) { --top;
            const float3 q = safeDivide(stack[top - 1], stack[top]);
            stack[top - 1] = floor(q) * stack[top];
        } break;
        CASE(BOX) --top; stack[top - 1] = box(stack[top - 1], stack[top].x); break;
        CASE(BRICK) top -= 3; stack[top - 1] = brick(stack[top - 1], stack[top], stack[top + 1], stack[top + 2]); break;
        CASE(MAGIC) --top; stack[top - 1] = magic(stack[top - 1], stack[top]); break;
        CASE(VORONOI) top -= 4;
            stack[top - 1] = fractalVoronoi(stack[top - 1], stack[top], stack[top + 1], stack[top + 2], stack[top + 3]);
            break;
        CASE(WHITE_NOISE) --top;
            stack[top - 1] = white(stack[top - 1], int(stack[top].x), stack[top].y != 0, stack[top].z);
            break;
        CASE(NOISE) top -= 3;
            stack[top - 1] = float3(1, 1, 1) * fractal(stack[top - 1], stack[top], stack[top + 1], stack[top + 2].x,
                int(stack[top + 2].y));
            break;
        CASE(POWER) --top; stack[top - 1] = power(stack[top - 1], stack[top]); break;
        CASE(EXPONENT) stack[top - 1] = exp(stack[top - 1]); break;
        CASE(MINIMUM) --top; stack[top - 1] = min(stack[top - 1], stack[top]); break;
        CASE(LESS_THAN) --top; stack[top - 1] = float3(stack[top - 1] < stack[top]); break;
        CASE(FLOOR) stack[top - 1] = floor(stack[top - 1]); break;
        CASE(MODULO) --top;
            stack[top - 1] = float3(stack[top].x != 0 ? fmod(stack[top - 1].x, stack[top].x) : 0,
                stack[top].y != 0 ? fmod(stack[top - 1].y, stack[top].y) : 0,
                stack[top].z != 0 ? fmod(stack[top - 1].z, stack[top].z) : 0);
            break;
        // Reduced exactly
        CASE(SINE) stack[top - 1] = float3(sinpi(stack[top - 1].x * INV_PI), sinpi(stack[top - 1].y * INV_PI),
            sinpi(stack[top - 1].z * INV_PI)); break;
        CASE(COSINE) stack[top - 1] = float3(cospi(stack[top - 1].x * INV_PI), cospi(stack[top - 1].y * INV_PI),
            cospi(stack[top - 1].z * INV_PI)); break;
        CASE(TANGENT) stack[top - 1] = float3(sinpi(stack[top - 1].x * INV_PI) / cospi(stack[top - 1].x * INV_PI),
            sinpi(stack[top - 1].y * INV_PI) / cospi(stack[top - 1].y * INV_PI),
            sinpi(stack[top - 1].z * INV_PI) / cospi(stack[top - 1].z * INV_PI)); break;
        CASE(ARCSINE) stack[top - 1] = asin(min(max(stack[top - 1], -1), 1)); break;
        CASE(ARCCOSINE) stack[top - 1] = acos(min(max(stack[top - 1], -1), 1)); break;
        CASE(ARCTANGENT) stack[top - 1] = atan(stack[top - 1]); break;
        CASE(ARCTAN2) --top; stack[top - 1] = atan2(stack[top - 1], stack[top]); break;
        CASE(SINH) stack[top - 1] = sinh(stack[top - 1]); break;
        CASE(COSH) stack[top - 1] = cosh(stack[top - 1]); break;
        CASE(TANH) stack[top - 1] = tanh(stack[top - 1]); break;
        CASE(CROSS_PRODUCT) --top; stack[top - 1] = cross(stack[top - 1], stack[top]); break;
        CASE(RGB_TO_HSV) stack[top - 1] = toHsv(stack[top - 1]); break;
        CASE(HSV_TO_RGB) stack[top - 1] = fromHsv(stack[top - 1]); break;
        CASE(RGB_TO_HSL) stack[top - 1] = toHsl(stack[top - 1]); break;
        CASE(HSL_TO_RGB) stack[top - 1] = fromHsl(stack[top - 1]); break;
        CASE(ROTATE) { // Around the unit axis by the angle, as Rodrigues'
            top -= 2;
            const float3 v = stack[top - 1], k = stack[top];
            const float c = cospi(stack[top + 1].x * INV_PI), s = sinpi(stack[top + 1].x * INV_PI);
            stack[top - 1] = v * c + cross(k, v) * s + k * (dot(k, v) * (1 - c));
        } break;
        // Image coordinates (u, v) of a direction; with rows (its texel), v a sky table's row, as equirectangular()
        CASE(EQUIRECTANGULAR) {
            const float3 d = stack[top - 1];
            const float v = 0.5f + atan2(d.z, sqrt(d.x * d.x + d.y * d.y)) / PI;
            stack[top - 1] = float3(0.5f - atan2(d.y, d.x) / (2 * PI),
                asuint(op.value.x) != 0 ? (0.5f + 128 * (1 + sign(2 * v - 1) * pow(abs(2 * v - 1), 1.0f / 3))) / 257
                : v, 0);
        } break;
        CASE(MIRROR_BALL) { // Image coordinates of a direction on a mirror ball
            float3 d = stack[top - 1] / (length(stack[top - 1]) > 0 ? length(stack[top - 1]) : 1) - float3(0, 1, 0);
            d = d / (d.y < 0 ? 2 * sqrt(-0.5f * d.y) : 1);
            stack[top - 1] = float3(0.5f * (d.x + 1), 0.5f * (d.z + 1), 0);
        } break;
        CASE(DIELECTRIC) --top; stack[top - 1] = float3(1, 1, 1) * fresnel(abs(stack[top - 1].x), 1, stack[top].x); break;
    }
    return Surface(normalize(stack[0]), stack[1], stack[2].x, stack[3].x, stack[4], stack[5].x, stack[6].x, stack[7],
        stack[8].x, stack[9].x, stack[10], stack[11].x, stack[12],
        used(TRANSLUCENT) && top > 13 ? stack[13] : float3(0, 0, 0), used(SHEEN) && top > 15 ? stack[14]
        : float3(0, 0, 0), used(SHEEN) && top > 15 ? stack[15].x : 0.5f, used(ANISOTROPIC) && top > 18 ? stack[16].x : 0,
        used(ANISOTROPIC) && top > 18 ? stack[17].x : 0, used(ANISOTROPIC) && top > 18 ? stack[18] : float3(0, 0, 0),
        used(MEDIUM) && top > 19 ? stack[19] : float3(0, 0, 0), used(HAIR) && top > 20 ? stack[20] : float3(0, 0, 0),
        used(PHASE) && top > 21 ? stack[21].x : 0, used(VELVET) && top > 22 ? stack[22].x : 0,
        used(TOON) && top > 23 ? stack[23] : float3(0, 0, 0), used(DISPERSION) && top > 24 ? stack[24].x : 0);
}
// Object-space MikkTSpace frame interpolated at the triangle's barycentrics
float3x3 tangentSpace(float4* p, float3 n, float s, float t) {
    const float3 a = p[0].xyz, b = p[1].xyz;
    const float3 tangent = a + (b - a) * s + (p[2].xyz - a) * t;
    return float3x3(tangent, cross(n, tangent) * p[0].w, n);
}
float3 place(Instance instance, float3 p) { // Through the instance's transform
    return float3(instance.matrix[0] * p.x + instance.matrix[1] * p.y + instance.matrix[2] * p.z + instance.matrix[3],
        instance.matrix[4] * p.x + instance.matrix[5] * p.y + instance.matrix[6] * p.z + instance.matrix[7],
        instance.matrix[8] * p.x + instance.matrix[9] * p.y + instance.matrix[10] * p.z + instance.matrix[11]);
}
float3 turn(Instance instance, float3 n) { // Through the instance's adjugate, normalized
    return normalize(float3(n.x * instance.adjugate[0] + n.y * instance.adjugate[3] + n.z * instance.adjugate[6],
        n.x * instance.adjugate[1] + n.y * instance.adjugate[4] + n.z * instance.adjugate[7],
        n.x * instance.adjugate[2] + n.y * instance.adjugate[5] + n.z * instance.adjugate[8]));
}
// Corner normal in its object's space, mirrored where the transform mirrors faces
float3 objectNormal(Scene* scene, Instance instance, float3 n) {
    return instance.world != 0 ? transform(scene, n, 5, instance.info) : n * sign(instance.matrix[0]
        * instance.adjugate[0] + instance.matrix[1] * instance.adjugate[3] + instance.matrix[2] * instance.adjugate[6]);
}
// A triangle's corners and normals in the world, placed and turned by the instance
struct Corners {
    float3* p; Instance instance; bool normal;
    __subscript(int k) -> float3 { get { return normal ? turn(instance, p[k]) : place(instance, p[k]); } }
    float3 at(float s, float t) { return place(instance, p[0] + (p[1] - p[0]) * s + (p[2] - p[0]) * t); }
    float3 face() { return turn(instance, cross(p[1] - p[0], p[2] - p[0])); }
};
Corners corners(float3* vertices, Instance instance, uint triangle) {
    return Corners(vertices + 3 * triangle, instance, false);
}
Corners cornerNormals(float3* normals, Instance instance, uint triangle) {
    return Corners(normals + 3 * triangle, instance, true);
}
// Instance of a triangle by its number in the scene's order: the last one numbered no higher, by bisection
uint owner(Scene* scene, uint number) {
    uint low = 0, high = scene.instanceCount;
    while (high - low > 1) {
        const uint middle = (low + high) / 2;
        if (scene.instances[middle].key <= number) low = middle; else high = middle;
    }
    return low;
}
// Number of an instance's triangle in the scene's order, and the triangle a number names
uint key(Scene* scene, uint instance, uint triangle) {
    return scene.instances[instance].key + triangle - scene.instances[instance].first;
}
uint key(Scene* scene, Hit hit) { return key(scene, hit.instance, hit.triangle); }
Hit owned(Scene* scene, uint key) {
    const uint instance = owner(scene, key);
    return Hit(scene.instances[instance].first + key - scene.instances[instance].key, instance, float2(0, 0));
}
// Of a triangle of an instance at its barycentrics
Point at(Scene* scene, uint instance, uint triangle, float s, float t) {
    float2* uv = scene.uvs + 3 * triangle;
    const Corners vertex = corners(scene.vertices, scene.instances[instance], triangle);
    float3* generated = scene.generated + 3 * triangle;
    float3* object = scene.objects + 3 * triangle;
    float4* color = scene.colors + 3 * triangle;
    return Point(uv[0].x + (uv[1].x - uv[0].x) * s + (uv[2].x - uv[0].x) * t,
        uv[0].y + (uv[1].y - uv[0].y) * s + (uv[2].y - uv[0].y) * t,
        generated[0] + (generated[1] - generated[0]) * s + (generated[2] - generated[0]) * t,
        object[0] + (object[1] - object[0]) * s + (object[2] - object[0]) * t,
        color[0] + (color[1] - color[0]) * s + (color[2] - color[0]) * t,
        vertex.at(s, t), s, t, triangle, instance);
}
// A strand segment's point and normal in its object, at its uv as hit
float3 strandPoint(Scene* scene, uint segment, float2 uv, out float3 n) {
    const uint code = asuint(uv.y), p = scene.segments[2 * segment];
    const float theta = (code >> 16) * (PI / 65535), phi = ((code & 65535) / 65535.0f - 0.5f) * (2 * PI);
    const float4 a = scene.points[p], b = scene.points[p + 1];
    n = float3(sin(theta) * cos(phi), sin(theta) * sin(phi), cos(theta));
    return a.xyz + (b.xyz - a.xyz) * uv.x + n * (a.w + (b.w - a.w) * uv.x);
}
// Along an edge only when a bump program asks for its height or position; the world's point stays fixed
Point shifted(Scene* scene, Point point, Ray ray, int axis) {
    if (point.triangle == NONE || used(CURVES) && scene.instances[point.instance].world == STRANDS) return point;
    const Corners vertex = corners(scene.vertices, scene.instances[point.instance], point.triangle);
    const float step = 1e-4f * max(ray.length, 1e-3f);
    return at(scene, point.instance, point.triangle,
        axis == 1 ? point.s + step / length(vertex[1] - vertex[0]) : point.s,
        axis == 2 ? point.t + step / length(vertex[2] - vertex[0]) : point.t);
}
// Surface of an instance's triangle at its barycentrics, in a layer of its material
Surface shade(Scene* scene, uint instance, uint triangle, float s, float t, float3 normal, float3 direction, Ray ray,
    uint layer = 0, bool emission = false) {
    if (used(CURVES) && scene.instances[instance].world == STRANDS) { // A strand's segment, its frame along its axis
        float3 n; // and normal
        const float3 o = strandPoint(scene, triangle, float2(s, t), n);
        const uint p = scene.segments[2 * triangle];
        const float3 along = normalize(scene.points[p + 1].xyz - scene.points[p].xyz);
        uint program = emission ? scene.materials[key(scene, instance, triangle)].emission
            : scene.materials[key(scene, instance, triangle)].program;
        while (layer != 0) layer -= uint(scene.ops[program++].code == END);
        float4* root = scene.strands + 3 * scene.segments[2 * triangle + 1]; // Its UV and color, and generated point
        const Instance placed = scene.instances[instance]; // by its emitter's texture space
        const float3 low = float3(placed.texspace[0], placed.texspace[1], placed.texspace[2]);
        const float3 size = float3(placed.texspace[3], placed.texspace[4], placed.texspace[5]);
        return shade(scene, program, normal, float3x3(along, cross(n, along), n), Point(root[1].x, root[1].y,
            (o - low) / (2 * size) + 0.5f, o, root[2], place(placed, o), s, t, triangle, instance), -direction, false,
            ray, placed.info);
    }
    const Corners vertex = corners(scene.vertices, scene.instances[instance], triangle);
    float3* normals = scene.normals + 3 * triangle;
    const Info object = scene.instances[instance].info;
    const float3 a = objectNormal(scene, vertex.instance, normals[0]);
    const float3 b = objectNormal(scene, vertex.instance, normals[1]);
    const float3 c = objectNormal(scene, vertex.instance, normals[2]);
    const SceneMaterial material = scene.materials[key(scene, instance, triangle)];
    uint program = emission ? material.emission : material.program;
    // Each layer's program follows the end of the one above it
    while (layer != 0) layer -= uint(scene.ops[program++].code == END);
    // Footprint of the ray cone over the UVs (Akenine-Moller et al. 2019)
    // FOOTPRINT = width^2 / |cos| * UV_AREA / AREA, |cos| = |dot(face, direction)| / |face|
    // uv_cross = (uv[1] - uv[0]) x (uv[2] - uv[0]), UV_AREA / AREA = |uv_cross| / |face|
    // => level = log2(width * CONE_SHARE * sqrt(|uv_cross| / |dot(face, direction)|))
    float2* uv = scene.uvs + 3 * triangle;
    const float3 face = cross(vertex[1] - vertex[0], vertex[2] - vertex[0]);
    Ray cone = ray;
    cone.level = log2(ray.width * CONE_SHARE * sqrt(abs(((uv[1].x - uv[0].x) * (uv[2].y - uv[0].y) - (uv[2].x - uv[0].x)
        * (uv[1].y - uv[0].y)) / dot(face, direction))));
    return shade(scene, program, normal,
        tangentSpace(scene.tangents + 3 * triangle, normalize(a + (b - a) * s + (c - a) * t), s, t),
        at(scene, instance, triangle, s, t), -direction,
        dot(vertex.face(), direction) > 0, cone, object, scene.passes[triangle]);
}

// ReSTIR PT Enhanced (Lin, Kettunen and Wyman 2026), paths in primary sample space

// Random streams besides the per vertex ones
static const uint STREAM_JITTER = 192u;
static const uint STREAM_SELECT = 193u;

// Camera and primary hit of a pixel
struct Domain {
    float3 x0;
    float3 x1;
    Hit hit;
    float width, spread;
};

// Nearest hit before t past lo of a ray and a strand's segment from a to b: the union of their spheres and
// tangent cone (Roth 1982, Max 1990); uv its axis parameter and its normal's polar angles, 16 bits each
bool strand(float3 o, float3 d, float4 a, float4 b, float lo, inout float t, inout float2 uv) {
    const float3 axis = b.xyz - a.xyz, w = normalize(axis);
    const float s = dot(a.xyz + axis * 0.5f - o, d) / dot(d, d); // From beside the segment, for float precision
    o = o + d * s, lo -= s, t -= s; // t and lo shifted alike
    const float length2 = dot(axis, axis), k = (a.w - b.w) / sqrt(length2), c = sine(k), t0 = t;
    float3 n = float3(0);
    for (int end = 0; end < 2; ++end) { // Each sphere
        const float3 center = end == 1 ? b.xyz : a.xyz, oc = o - center;
        const float r = end == 1 ? b.w : a.w, q = dot(oc, d), h = q * q - dot(d, d) * (dot(oc, oc) - r * r);
        for (float sign = -1; sign <= 1; sign += 2) {
            const float root = (-q + sign * sqrt(h)) / dot(d, d);
            if (h >= 0 && root > lo && root < t) t = root, n = (o + d * root - center) / r;
        }
    }
    const float3 oa = o - a.xyz, dp = d - w * dot(d, w), op = oa - w * dot(oa, w); // The cone, where the radius at
    const float m = k / max(c, 1e-6f), r0 = a.w / max(c, 1e-6f) - dot(oa, w) * m; // height y along the axis is r0 - y m
    const float qa = dot(dp, dp) - dot(d, w) * dot(d, w) * m * m, qb = dot(op, dp) + r0 * dot(d, w) * m;
    const float h = qb * qb - qa * (dot(op, op) - r0 * r0);
    for (float sign = -1; sign <= 1; sign += 2) {
        const float root = (-qb + sign * sqrt(h)) / qa, y = dot(oa + d * root, w);
        if (h >= 0 && c > 0 && root > lo && root < t && y >= a.w * k && y <= sqrt(length2) + b.w * k && r0 - root
            * dot(d, w) * m >= 0) t = root, n = normalize(oa + d * root - w * y) * c + w * k; // Between its circles
    }
    if (!(t < t0)) { t += s; return false; }
    uv = float2(clamp(dot(o + d * t - a.xyz, axis) / length2, 0.0f, 1.0f), asfloat(uint(acos(clamp(n.z, -1.0f, 1.0f))
        / PI * 65535.0f + 0.5f) << 16 | uint((atan2(n.y, n.x) / (2 * PI) + 0.5f) * 65535.0f + 0.5f)));
    t += s;
    return true;
}
// Whether segment number lies apart from segment other: not next to it in its strand
bool apart(Scene* scene, uint instance, uint number, uint other) {
    Instance* placed = &scene.instances[instance];
    const uint at = placed.first + number - placed.key, then = placed.first + other - placed.key;
    return placed.world != STRANDS || other - placed.key >= placed.count || scene.segments[2 * then + 1]
        != scene.segments[2 * at + 1] || scene.segments[2 * then] - scene.segments[2 * at] + 1 > 2;
}
// Distance of a candidate: a triangle's, or a strand segment's met before t; -1 if missed or next to skip
float candidate(Scene* scene, inout RayQuery<RAY_FLAG_NONE> query, uint skip, float t, inout float2 uv) {
    const uint instance = query.CandidateInstanceIndex(), primitive = query.CandidatePrimitiveIndex();
    if (query.CandidateType() == CANDIDATE_NON_OPAQUE_TRIANGLE) return query.CandidateTriangleRayT();
    const uint point = scene.segments[2 * (scene.instances[instance].first + primitive)];
    return used(CURVES) && apart(scene, instance, scene.instances[instance].key + primitive, skip) && strand(
        query.CandidateObjectRayOrigin(), query.CandidateObjectRayDirection(), scene.points[point],
        scene.points[point + 1], query.RayTMin(), t, uv) ? t : -1;
}

// Nearest hit of a ray within far and its distance, NONE on a miss
// Rays start past near; leaving the skipped triangle, back by near, to keep triangles there
Hit traverse(Scene* scene, float3 origin, float3 direction, float far, inout float distance, uint skip = NONE,
    float near = 1e-4f, uint mask = 255) {
    const float back = skip == NONE ? 0 : near;
    // Every candidate but the skipped triangle committed
    RayQuery<RAY_FLAG_NONE> query;
    query.TraceRayInline(RaytracingAccelerationStructure(scene.handle),
        skip == NONE ? RAY_FLAG_FORCE_OPAQUE : RAY_FLAG_NONE, mask,
        RayDesc(origin - direction * back, skip == NONE ? near : 0, direction, far + back));
    float2 uv = float2(0, 0);
    while (query.Proceed()) {
        const float t = candidate(scene, query, skip, query.CommittedStatus() == COMMITTED_NOTHING ? far + back
            : query.CommittedRayT(), uv);
        if (t >= 0 && scene.instances[query.CandidateInstanceIndex()].key + query.CandidatePrimitiveIndex() != skip)
            if (query.CandidateType() == CANDIDATE_NON_OPAQUE_TRIANGLE) query.CommitNonOpaqueTriangleHit();
            else query.CommitProceduralPrimitiveHit(t);
    }
    if (query.CommittedStatus() == COMMITTED_NOTHING) return Hit(NONE, NONE, float2(0, 0));
    distance = query.CommittedRayT() - back;
    const uint instance = query.CommittedInstanceIndex();
    return Hit(scene.instances[instance].first + query.CommittedPrimitiveIndex(), instance,
        query.CommittedStatus() == COMMITTED_TRIANGLE_HIT ? query.CommittedTriangleBarycentrics() : uv);
}

// Next layer past the triangle after at distance at, by distance then index; at becomes its distance
Hit nextLayer(Scene* scene, float3 origin, float3 direction, float far, inout float at, uint after,
    uint mask = 255) {
    RayQuery<RAY_FLAG_NONE> query;
    query.TraceRayInline(RaytracingAccelerationStructure(scene.handle), RAY_FLAG_NONE, mask,
        RayDesc(origin, at * (1 - 4.76837158203125e-7f), direction, far));
    float2 uv = float2(0, 0);
    while (query.Proceed()) {
        const float t = candidate(scene, query, after, query.CommittedStatus() == COMMITTED_NOTHING ? far
            : query.CommittedRayT(), uv);
        if (t >= 0 && pastLayer(t, scene.instances[query.CandidateInstanceIndex()].key
            + query.CandidatePrimitiveIndex(), at, after))
            if (query.CandidateType() == CANDIDATE_NON_OPAQUE_TRIANGLE) query.CommitNonOpaqueTriangleHit();
            else query.CommitProceduralPrimitiveHit(t);
    }
    if (query.CommittedStatus() == COMMITTED_NOTHING) return Hit(NONE, NONE, float2(0, 0));
    const float t = query.CommittedRayT();
    Hit hit = Hit(NONE, NONE, float2(0, 0));
    RayQuery<RAY_FLAG_NONE> gather;
    gather.TraceRayInline(RaytracingAccelerationStructure(scene.handle), RAY_FLAG_NONE, mask,
        RayDesc(origin, t * (1 - 4.76837158203125e-7f), direction, t * (1 + 4.76837158203125e-7f)));
    uint lowest = NONE; // Number of the hit kept
    while (gather.Proceed()) {
        const uint instance = gather.CandidateInstanceIndex();
        const uint number = scene.instances[instance].key + gather.CandidatePrimitiveIndex();
        if (candidate(scene, gather, after, t * (1 + 4.76837158203125e-7f), uv) == t && number < lowest
            && pastLayer(t, number, at, after))
            lowest = number, hit = Hit(scene.instances[instance].first + gather.CandidatePrimitiveIndex(), instance,
                gather.CandidateType() == CANDIDATE_NON_OPAQUE_TRIANGLE ? gather.CandidateTriangleBarycentrics() : uv);
    }
    at = t;
    return hit;
}

// Whether a hit at distance t of triangle lies past the layer of triangle after at distance at, by distance then index
bool pastLayer(float t, uint triangle, float at, uint after) { return t > at || (t == at && triangle > after); }


float3 hitPosition(Scene* scene, float3* vertices, Hit hit) { // Of those vertices
    float3 n;
    if (used(CURVES) && scene.instances[hit.instance].world == STRANDS)
        return place(scene.instances[hit.instance], strandPoint(scene, hit.triangle, hit.uv, n));
    return corners(vertices, scene.instances[hit.instance], hit.triangle).at(hit.uv.x, hit.uv.y);
}

float3 faceNormal(Scene* scene, uint instance, uint triangle) {
    return corners(scene.vertices, scene.instances[instance], triangle).face();
}

// Of a hit, a strand's as smooth
float3 faceNormal(Scene* scene, Hit hit) {
    float3 n;
    if (used(CURVES) && scene.instances[hit.instance].world == STRANDS)
        return strandPoint(scene, hit.triangle, hit.uv, n), turn(scene.instances[hit.instance], n);
    return faceNormal(scene, hit.instance, hit.triangle);
}

float3 smoothNormal(Scene* scene, Hit hit) {
    if (used(CURVES) && scene.instances[hit.instance].world == STRANDS) return faceNormal(scene, hit);
    const Corners normals = cornerNormals(scene.normals, scene.instances[hit.instance], hit.triangle);
    return normalize(normals[0] * (1 - hit.uv.x - hit.uv.y) + normals[1] * hit.uv.x + normals[2] * hit.uv.y);
}

// Uniform point of the aperture, squeezed horizontally by ratio
// Disk: CDF(radius) = radius^2 / aperture^2 = u => radius = aperture * sqrt(u)
// Polygon: a blade's triangle of height aperture * cos(half), its width 2 * x * tan(half) growing with x
// CDF(x) = x^2 / (aperture * cos(half))^2 = u => x = radius * cos(half), y uniform across the width
// => y = radius * (2 * (sector - floor(sector)) - 1) * sin(half)
float2 aperture(Lens lens, uint state) {
    float angle = 2 * PI * random(state), radius = lens.aperture * sqrt(random(state)), x = radius, y = 0;
    if (lens.blades >= 3) {
        const float sector = angle * lens.blades / (2 * PI), half = PI / lens.blades;
        x = radius * cos(half);
        y = radius * (2 * (sector - floor(sector)) - 1) * sin(half);
        angle = 2 * half * floor(sector) + lens.rotation;
    }
    return float2((x * cos(angle) - y * sin(angle)) / lens.ratio, x * sin(angle) + y * cos(angle));
}

// Camera and primary hit of a pixel by its seed's jitter and lens point; on a miss x1 is one along the ray
Domain pixelDomain(Scene* scene, Camera camera, int pixel, uint3 size, uint seed) {
    uint state = stream(seed, STREAM_JITTER);
    const float x = pixel % size.x + random(state);
    const float y = pixel / size.x + random(state);
    const float3 plane = camera.x * (2 * x / size.x - 1) + camera.y * (1 - 2 * y / size.y) + camera.z;
    float3 direction = camera.lens.ortho != 0 ? normalize(cross(camera.y, camera.x)) : normalize(plane);
    float3 origin = camera.lens.ortho != 0 ? camera.origin + plane : camera.origin;
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
    // Past hidden surfaces layer by layer, from an ulp short of a hidden first hit
    for (bool first = true; hit.triangle != NONE && scene.materials[key(scene, hit)].hidden != 0; first = false) {
        if (first) at = asfloat(asuint(at) - 1);
        hit = nextLayer(scene, origin, direction, reach, at, first ? NONE : key(scene, hit));
    }
    // A pixel's cone: from the lens a point spreading by the angle the pixel spans, orthographic a pixel wide
    const float across = 2 * length(camera.x) / size.x;
    return Domain(start, hit.triangle == NONE ? start + direction : hitPosition(scene, scene.vertices, hit),
        hit, camera.lens.ortho != 0 ? across : 0, camera.lens.ortho != 0 ? 0 : across / length(plane));
}

// World: equirectangular texture along the direction
float3 environment(Scene* scene, float3 direction, Ray ray) {
    const Point point = Point(0.5f - atan2(direction.y, direction.x) / (2 * PI),
        0.5f + atan2(direction.z, sqrt(direction.x * direction.x + direction.y * direction.y)) / PI, direction,
        direction, float4(0, 0, 0, 0), direction, 0, 0, NONE, NONE);
    const Info info = {{0, 0, 0}, {0, 0, 0, 0}, 0, 0, {1, 0, 0, 0, 1, 0, 0, 0, 1}};
    return shade(scene, scene.materials[scene.count].program, direction, float3x3(float3(0), float3(0), float3(0)),
        point, -direction, false, ray, info).emissive;
}

// Scattering and extinction coefficients and Henyey-Greenstein g of a medium, none by default
struct Medium { float3 scatter, extinction; float g = 0; };
static const Medium NO_MEDIUM = {float3(0), float3(0), 0};
// Of the volume filling the inside of a surface, behind its faces
Medium volume(Surface surface) {
    return Medium(surface.scatter * surface.density,
        (surface.scatter + float3(1, 1, 1) - surface.absorption) * surface.density, surface.phase);
}
// Of the volume behind a face of an instance's triangle: of one varying, its material's key, else NONE
uint fills(Scene* scene, uint instance, uint triangle) {
    return used(MEDIUM) && scene.instances[instance].majorant != 0 ? key(scene, instance, triangle) : NONE;
}
// Whether a face bounds a volume: shaded dense, or always of a varying one
bool encloses(Scene* scene, Surface surface, uint instance) {
    return surface.density > 0 || used(MEDIUM) && scene.instances[instance].majorant != 0;
}
// Coefficients of a varying medium at a point inside, by its material's volume there
Medium inside(Scene* scene, uint material, float3 p, float3 direction, Ray ray, out float3 glow) {
    const uint filled = owner(scene, material);
    const Instance instance = scene.instances[filled];
    const float3 o = transform(scene, p, 3, instance.info);
    const float3 low = float3(instance.texspace[0], instance.texspace[1], instance.texspace[2]);
    const float3 size = float3(instance.texspace[3], instance.texspace[4], instance.texspace[5]);
    const Point point = Point(0, 0, (o - low) / (2 * size) + 0.5f, o, float4(0), p, 0, 0, NONE, filled);
    const Surface surface = shade(scene, scene.materials[material].program, -direction,
        float3x3(float3(1, 0, 0), float3(0, 1, 0), -direction), point, -direction, false, ray, instance.info);
    glow = surface.glow;
    return volume(surface);
}
// Spectral tracking under the majorant (Kutz et al. 2017), next real scattering, past distance for none
// PDF(along) = majorant * exp(-majorant * along) => along -= log(1 - u) / majorant
// P_scatter = mean / majorant, P_null = (majorant - mean) / majorant
// scattered: weight *= at.scatter / majorant / P_scatter => weight * at.scatter / mean
// null: weight *= (majorant - at.extinction) / majorant / P_null
//    => weight * (majorant - at.extinction) / (majorant - mean)
// passing: mean = 0, ratio tracking (Novak et al. 2014); absorbing alone: at.extinction - at.scatter
// glowed += weight * glow / majorant at each tentative collision
float track(Scene* scene, inout Medium medium, uint material, float3 origin, float3 direction, float distance,
    inout uint state, inout float3 weight, inout float3 glowed, Ray ray, bool passing = false, bool absorbing = false) {
    const float stored = scene.instances[owner(scene, material)].majorant, majorant = abs(stored);
    // majorant = extinction, every collision real: weight *= at.scatter / majorant, glowed += weight * glow / majorant
    // passing => weight *= exp(-majorant * distance)
    if (stored < 0 && !absorbing) {
        if (passing) {
            weight = weight * exp(-majorant * distance);
            return distance;
        }
        const float along = -log(1 - random(state)) / majorant;
        if (!(along < distance)) return along;
        float3 glow;
        const Medium at = inside(scene, material, origin + direction * along, direction, ray, glow);
        glowed = glowed + weight * glow / majorant, weight = weight * at.scatter / majorant, medium = at;
        return along;
    }
    for (float along = 0;;) {
        along -= log(1 - random(state)) / majorant;
        if (!(along < distance)) return along;
        float3 glow;
        const Medium at = inside(scene, material, origin + direction * along, direction, ray, glow);
        glowed = glowed + weight * glow / majorant;
        const float mean = passing ? 0 : (at.scatter.x + at.scatter.y + at.scatter.z) / 3;
        if (random(state) * majorant < mean) {
            weight = weight * at.scatter / mean, medium = at;
            return along;
        }
        weight = weight * (float3(1, 1, 1) * majorant - at.extinction + (absorbing ? at.scatter : float3(0, 0, 0)))
            / (majorant - mean);
    }
}
// T = exp(-extinction * (to - from)), absorbing alone exp(-(extinction - scatter) * (to - from))
// Varying: ratio tracking
float3 passing(Scene* scene, Medium medium, uint material, float3 origin, float3 direction, float from, float to,
    inout uint state, Ray ray, bool absorbing = false) {
    float3 glowed = float3(0, 0, 0);
    return passing(scene, medium, material, origin, direction, from, to, state, ray, absorbing, glowed);
}
float3 passing(Scene* scene, Medium medium, uint material, float3 origin, float3 direction, float from, float to,
    inout uint state, Ray ray, bool absorbing, inout float3 glowed) {
    if (!used(MEDIUM) || material == NONE)
        return exp(absorbing ? (medium.scatter - medium.extinction) * (to - from)
            : medium.extinction * (from - to));
    float3 passed = float3(1, 1, 1);
    track(scene, medium, material, origin + direction * from, direction, to - from, state, passed, glowed, ray, true,
        absorbing);
    return passed;
}

// Medium entered leaving a volume: the world's inside its box, else none
Medium outside(Scene* scene, uint instance) {
    if (!used(WORLD) || scene.box == NONE || instance == scene.box) return NO_MEDIUM;
    const uint first = scene.instances[scene.box].first;
    return volume(shade(scene, scene.box, first, 0, 0, cornerNormals(scene.normals, scene.instances[scene.box],
        first)[0], float3(0, 0, 1), Ray(false, false, LOBE_NONE, 0.0f, 0.0f)));
}

// Whether a shadow ray is blocked; transmitted: the light passing its occluders' layers and media
[ForceInline] bool occluded(Scene* scene, float3 from, float3 toward, float left, Medium medium, uint filling,
    inout uint state, Ray ray, bool onSurface, out float3 transmitted, uint skip = NONE, uint mask = SHADOWS) {
    float before = 0, at = 0, occluder;
    transmitted = float3(1, 1, 1);
    // First hit off a surface past its margin, else from the start, a hair vertex's segment skipped;
    // where it lets light through, the layers start an ulp short of it
    Hit first = onSurface && skip == NONE ? traverse(scene, from, toward, left, at, NONE, 1e-4f, mask)
        : traverse(scene, from, toward, left, at, skip, 0, mask);
    if (first.triangle != NONE && scene.materials[key(scene, first)].opaque == 0)
        at = asfloat(asuint(at) - 1), first = nextLayer(scene, from, toward, left, at, NONE, mask);
    for (Hit hit = first; hit.triangle != NONE;
        before = at, hit = nextLayer(scene, from, toward, left, at, key(scene, hit), mask)) {
        occluder = at - before;
        if (scene.materials[key(scene, hit)].opaque != 0) return true;  // Shading it would pass nothing
        transmitted = transmitted * passing(scene, medium, filling, from, toward, before, at, state, ray);
        for (uint layer = 0; layer < scene.materials[key(scene, hit)].layers; ++layer) {
            const Surface surface = shade(scene, hit.instance, hit.triangle, hit.uv.x, hit.uv.y,
                smoothNormal(scene, hit), toward,
                Ray(ray.camera, true, ray.lobe, ray.depth + 1, occluder), layer);
            transmitted = transmitted * occluderTransmittance(toward, surface.normal, Material(surface.albedo, float3(0),
                surface.roughness, surface.metallic, surface.transparency, surface.ior, float3(0), float3(1), 1, float3(0),
                float3(0), 0.5f, used(ANISOTROPIC) ? surface.anisotropy : 0, used(ANISOTROPIC) ? surface.anisotropic_rotation
                : 0, used(ANISOTROPIC) ? surface.tangent : float3(0)), surface.coverage);
            if (layer == 0 && encloses(scene, surface, hit.instance)) {
                const bool leaves = dot(faceNormal(scene, hit), toward) > 0;
                medium = leaves ? outside(scene, hit.instance) : volume(surface), filling = leaves ? NONE : fills(scene, hit.instance,
                    hit.triangle);
            }
        }
        if (rgb_to_greyscale(transmitted) <= 0)
            return true;
    }
    transmitted = transmitted * passing(scene, medium, filling, from, toward, before, left, state, ray);
    return false;
}

// Medium the camera is in; filling: its material's key if varying, else NONE
[ForceInline] Medium cameraMedium(Scene* scene, float3 direction, float distance, out uint filling) {
    const Hit held = scene.settings.medium == NONE ? Hit(NONE, NONE, float2(0, 0))
        : owned(scene, scene.settings.medium);
    const Medium medium = held.triangle == NONE ? NO_MEDIUM : volume(shade(scene, held.instance, held.triangle, 0,
        0, cornerNormals(scene.normals, scene.instances[held.instance], held.triangle)[0], direction,
        Ray(true, false, LOBE_NONE, 0.0f, distance)));
    filling = held.triangle == NONE ? NONE : fills(scene, held.instance, held.triangle);
    return medium;
}

static const float MARGIN = 1e-4f; // A surface's, rays leaving it start past
Hit nativeHit(FKHit hit) { return Hit(hit.triangle_index, hit.instance_index, hit.uv); }
// Geometry offset of a triangle's point along its smooth normal by its corners' normals' tilt; none on a strand
float geometryOffsetAt(Scene* scene, Hit at, float3 face, float3 position) {
    if (used(CURVES) && scene.instances[at.instance].world == STRANDS) return 0;
    const Corners corner = corners(scene.vertices, scene.instances[at.instance], at.triangle);
    const Corners normal = cornerNormals(scene.normals, scene.instances[at.instance], at.triangle);
    return geometryOffset(corner[0], corner[1], corner[2], normal[0], normal[1], normal[2], face,
        float3(1 - at.uv.x - at.uv.y, at.uv.x, at.uv.y), position);
}
// The surface as the walk takes it: unfaced, offset only where it lets no light through
FKSurface walkSurface(Scene* scene, Hit at, Surface surface, float3 position, uint random_state) {
    const float3 face = faceNormal(scene, at);
    Material material = {surface.albedo, surface.emissive, surface.roughness, surface.metallic, surface.transparency,
        surface.ior, float3(1, 1, 1), used(SPECULAR) ? surface.tint : float3(1, 1, 1),
        used(SPECULAR) ? surface.level : 1, used(TRANSLUCENT) ? surface.translucent : float3(0, 0, 0),
        used(SHEEN) ? surface.sheen : float3(0, 0, 0), used(SHEEN) ? surface.sheen_roughness : 0.5f,
        used(ANISOTROPIC) ? surface.anisotropy : 0, used(ANISOTROPIC) ? surface.anisotropic_rotation : 0,
        used(ANISOTROPIC) ? surface.tangent : float3(0, 0, 0), used(VELVET) ? surface.velvet : 0,
        used(TOON) ? surface.toon : float3(0, 0, 0), used(DISPERSION) ? surface.dispersion : 0};
    const bool enclosed = encloses(scene, surface, at.instance);  // The medium it fills, only where it encloses one
    const Medium filled = enclosed ? volume(surface) : Medium(float3(0, 0, 0), float3(0, 0, 0));
    const bool hair = used(HAIR) && dot(surface.hair, surface.hair) > 0;  // Its fiber, which rays leave from the vertex
    const bool passes = surface.transparency > 0 || used(TRANSLUCENT) && rgb_to_greyscale(surface.translucent) > 0;
    return {surface.normal, face, hair || passes ? 0.0f : geometryOffsetAt(scene, at, face, position), material, false,
        random_state,
        surface.coverage, enclosed, {filled.scatter, filled.extinction, filled.g},
        enclosed ? fills(scene, at.instance, at.triangle) : NONE, surface.hair};
}
struct VkScene : IScene {
    Scene* scene;
    // Nearest hit, from past a surface's margin or from a medium's vertex; from the camera past hidden layers
    FKHit traverseInstanceBVH(FKRay ray, bool consider_point_lights, float max_len, bool surface, FKHit left,
        bool viewed) {
        float distance = 0;
        Hit hit = surface ? traverse(scene, ray.origin, ray.unit_direction, max_len, distance,
            left.instance_index != NONE && left.distance >= MARGIN ? key(scene, nativeHit(left)) : NONE)
            : traverse(scene, ray.origin, ray.unit_direction, max_len, distance,
            left.instance_index != NONE ? key(scene, nativeHit(left)) : NONE, 0);
        for (bool first = true; viewed && hit.triangle != NONE && scene.materials[key(scene, hit)].hidden != 0;
            first = false) {
            if (first) distance = asfloat(asuint(distance) - 1);
            hit = nextLayer(scene, ray.origin, ray.unit_direction, max_len, distance, first ? NONE : key(scene, hit));
        }
        return FKHit(hit.uv, hit.triangle == NONE ? NONE : hit.instance, hit.triangle, 0, distance);
    }
    // Transmittance toward the light, zero if blocked
    float3 shadowTransmittanceIn(FKRay ray, float l, float3 extinction, uint filling, uint random_state, uint depth,
        uint lobe, bool surface, float length, float width, FKHit left, FKHit light) {
        float3 transmitted;
        uint state = random_state;
        return occluded(scene, ray.origin, ray.unit_direction, l, Medium(float3(0, 0, 0), extinction), filling, state,
            Ray(depth == 0, false, lobe, float(depth), length, width), surface, transmitted,
            left.instance_index != NONE ? key(scene, nativeHit(left)) : NONE, light.instance_index != NONE
            && (scene.materials[key(scene, nativeHit(light))].opaque & 4) != 0 ? 0 : SHADOWS) ? float3(0, 0, 0)
            : transmitted;
    }
    // Unused
    FKSurface surfaceAt(FKHit hit, float3 origin, uint init_random_state) { return {}; }
    // A light sample's emission: its emission program toward the face, and its smooth normal
    FKSurface lightSurfaceAt(FKHit hit, float3 point, uint init_random_state, float3 dir, uint depth, float length) {
        const Hit at = nativeHit(hit);
        const Corners corner = corners(scene.vertices, scene.instances[at.instance], at.triangle);
        FKSurface light = walkSurface(scene, at, shade(scene, at.instance, at.triangle, at.uv.x, at.uv.y,
            cross(corner[1] - corner[0], corner[2] - corner[0]), dir, Ray(false, false, LOBE_NONE, float(depth + 1),
            length), 0, true), point, init_random_state);
        light.smooth_n = smoothNormal(scene, at);
        return light;
    }
    // The emitter shaded before its shadow query
    [ForceInline] bool shadowFirst() { return false; }
    // The surface at a path's hit
    FKSurface surfaceAtPath(FKHit hit, float3 origin, uint init_random_state, float width, uint layer, uint depth,
        uint lobe, float3 dir) {
        const Hit at = nativeHit(hit);
        return walkSurface(scene, at, shade(scene, at.instance, at.triangle, at.uv.x, at.uv.y, smoothNormal(scene, at),
            dir, Ray(depth == 0, false, lobe, float(depth), hit.distance, width), layer),
            hitPosition(scene, scene.vertices, at), init_random_state);
    }
    uint layers(FKHit hit) { return scene.materials[key(scene, nativeHit(hit))].layers; }
    // Its size: stored negative, it marks an extinction drawn exactly
    float majorant(uint filling) { return abs(scene.instances[owner(scene, filling)].majorant); }
    // Whether varying media are compiled in
    bool varyingUsed() { return used(MEDIUM); }
    // The medium a ray leaving a volume through the face of hit enters
    FKMedium outsideMedium(FKHit hit) {
        const Medium medium = outside(scene, hit.instance_index);
        return {medium.scatter, medium.extinction, medium.g};
    }
    // Whether hair is compiled in
    bool hairUsed() { return used(HAIR); }
    bool dispersionUsed() { return used(DISPERSION); }
    FKMedium cameraMedium(float3 direction, float distance, out uint filling) {
        const Medium medium = fcpt.cameraMedium(scene, direction, distance, filling);
        return {medium.scatter, medium.extinction, medium.g};
    }
    float trackMedium(uint filling, float3 origin, float3 dir, float distance, inout uint random_state,
        inout float3 weight, inout float3 glowed, inout float3 scatter, inout float3 extinction, inout float g,
        uint depth, uint lobe, bool camera) {
        Medium medium = Medium(scatter, extinction, g);
        const float along = track(scene, medium, filling, origin, dir, distance, random_state, weight, glowed,
            Ray(camera, false, lobe, float(depth), distance));
        scatter = medium.scatter, extinction = medium.extinction, g = medium.g;
        return along;
    }
    float3 hitPosition(FKHit hit) { return fcpt.hitPosition(scene, scene.vertices, nativeHit(hit)); }
    float3x3 worldTriangle(uint instance_index, uint triangle_index) {
        const Corners corner = corners(scene.vertices, scene.instances[instance_index], triangle_index);
        return float3x3(corner[0], corner[1], corner[2]);
    }
    // Light tree node: x 0 a node, 1 a triangle; a leaf's y its instance, z its triangle; the first child next
    LightBounds lightBounds(uint n) {
        const LightNode node = scene.lights[n];
        return {node.low, node.high, node.w, node.phi, node.cos_theta_o};
    }
    uint4 lightNode(uint n) {
        const LightNode node = scene.lights[n];
        return uint4(node.leaf, node.instance, node.child - scene.instances[node.instance].first, 0);
    }
    uint lightSecond(uint n) { return scene.lights[n].child; }
    // A light's slot, its triangle's number; none of a strand
    uint lightSlot(FKHit hit) {
        return used(CURVES) && scene.instances[hit.instance_index].world == STRANDS ? NONE
            : key(scene, nativeHit(hit));
    }
    uint4 lightTrail(uint j) {
        const uint64_t trail = scene.trails[j];
        return uint4(uint(trail), uint(trail >> 32), 0, 0);
    }
    bool slotLeaf(uint n, uint j, uint4 trail_texel) {
        const Hit light = owned(scene, j);
        return scene.lights[n].child == light.triangle && scene.lights[n].instance == light.instance;
    }
    // No point lights
    FKLight light(uint index) { return {}; }
    uint triangleOffset(uint instance_index) { return scene.instances[instance_index].first; }
    float3 calculatePointLightContrib(uint index) { return float3(0, 0, 0); }
    // The world along an escape's direction, shaded at bounce depth + 2 by lobe
    float3 env_map_sample(float3 dir, uint depth, uint lobe) {
        return environment(scene, dir, Ray(false, false, lobe, float(depth + 2u), 0));
    }
    // Blender's z up
    [ForceInline] bool zUp() { return true; }
    // Emitters emit on both sides
    [ForceInline] bool twoSided() { return true; }
    // Its luminance CDF by cell, (cdf, share), the marginal in the last column; none where the world is not sampled
    float4 environmentCdf(uint2 cell) {
        const float2 c = scene.environmentCdf[cell.y * scene.cdfWidth + cell.x];
        return float4(c, 0, 0);
    }
    uint2 environmentCdfSize() { return used(SKY) ? uint2(scene.cdfWidth, scene.cdfHeight) : uint2(0, 0); }
    uint2 environmentMapSize() { return uint2(2, 2); }
    float3 ambient() { return float3(0, 0, 0); }
    uint maxBounces() { return scene.settings.bounces; }
    // A hair fiber's scattering by its fiber, color and specular tint
    SampleBSDF connectHair(float3 hair, float3 albedo, float3 tint, float3 in_dir, float3 out_dir) {
        Surface fiber = {};
        fiber.hair = hair, fiber.albedo = albedo, fiber.tint = tint;
        return fcpt.connectHair(scene, fiber, in_dir, out_dir);
    }
    SampleBSDF sampleHair(float3 hair, float3 albedo, float3 tint, float3 in_dir, uint random_state) {
        Surface fiber = {};
        fiber.hair = hair, fiber.albedo = albedo, fiber.tint = tint;
        return fcpt.sampleHair(scene, fiber, in_dir, random_state);
    }
    // Reuse-pass hooks: a pixel's domain is its seed's camera ray (pixelDomain); none off the image or on a miss
    uint index(int2 p) { return p.y * scene.width + p.x; }
    bool onImage(int2 p) { return all(p >= int2(0)) && p.x < int(scene.width) && p.y < int(scene.height); }
    // The scene the previous frame traced: the anchor's on a view's first frame, which reuses its reservoirs
    Scene* previousScene() { return scene.frame == 0 ? scene.anchor : scene; }
    uint2 renderSize() { return uint2(scene.width, scene.height); }
    uint frame() { return scene.frame; }
    // Camera matrices the passes ask for, unused: pixelOf draws each camera ray
    float3x3 viewMatrix() { return float3x3(float3(0), float3(0), float3(0)); }
    float3 cameraPosition() { return float3(0); }
    float3x3 prevViewMatrix() { return float3x3(float3(0), float3(0), float3(0)); }
    float3 prevCameraPosition() { return float3(0); }
    int4 pairing(int2 texel, uint t) {
        int8_t* delta = scene.pairing[t] + 2 * (texel.y * PAIRING_SIZES[t] + texel.x);
        return int4(delta[0], delta[1], 0, 0);
    }
    // A reservoir's layer 0 as the passes read it: seed, path, unbiased contribution weight, confidence
    uint4 reservoirPrevious(int2 q, uint layer) {
        const Reservoir r = scene.previous[index(q)];
        return uint4(r.seed, r.path, asuint(r.w), asuint(r.c));
    }
    FKDomain previousDomain(int2 q, uint seed) {
        return fkDomain(pixelDomain(previousScene(), scene.previousCamera, index(q), uint3(renderSize(), 1), seed));
    }
    uint restirNeighbours() { return scene.settings.neighbors; }
    Reservoir loadReservoirPrevious(int2 q) { return scene.previous[index(q)]; }
    Reservoir loadReservoirInitial(int2 p) { return scene.initial[index(p)]; }
    Reservoir loadReservoirTemporal(int2 p) { return scene.temporal[index(p)]; }
    bool storedDomainInitial(int2 p, uint seed, out FKDomain dom) {
        dom = {};
        if (!onImage(p)) return false;
        dom = fkDomain(pixelDomain(scene, scene.camera, index(p), uint3(renderSize(), 1), seed));
        return dom.hit.instance_index != NONE;
    }
    bool storedDomainTemporal(int2 p, uint seed, out FKDomain dom) { return storedDomainInitial(p, seed, dom); }
    // Within a view the camera and the scene stay, so every sample keeps its domain; a view's first frame reuses the
    // anchor's, whose scene it shifts into
    bool sceneUnchanged() { return scene.frame > 0; }
    bool previousScenes() { return true; }
    Shift shiftPrevious(FKDomain dom, Reservoir r) {
        Selection sel = {};
        // Nothing to shift, or nothing seen there
        if (r.w <= 0.0f || dom.hit.instance_index == NONE) return Shift(float3(0, 0, 0), 0.0f);
        return walkDomain<true>(VkScene(previousScene()), dom, r, 0.0f, sel);
    }
    Shift walkCallable(FKDomain dom, Reservoir r, bool replay, float scale, inout Selection sel) {
        return replay ? walkDomain<true>(this, dom, r, scale, sel) : walkDomain<false>(this, dom, r, scale, sel);
    }
    float2 pixelOf(float3 position, bool previous) {
        return project(previous ? scene.previousCamera : scene.camera, position, uint3(renderSize(), 1));
    }
    // The queue by the workgroup's counts in shared memory, FlexKernels' branch outside CUDA
    uint queueCountAdd(uint bin, uint jobs) {
        uint old;
        InterlockedAdd(scene.queue[3 + bin], jobs, old);
        return old;
    }
    uint queueCountLoad(uint bin) { return scene.queue[3 + bin]; }
    uint queueCursorAdd(uint bin, uint jobs) {
        uint old;
        InterlockedAdd(scene.queue[43 + bin], jobs, old);
        return old;
    }
    void queueJobStore(uint index, uint job) { scene.queue[QUEUE_HEADER + index] = job; }
    // The indirect dispatch's size, which launches over the whole queue leave unread
    void queueDispatchStore(uint x, uint y, uint z) {}
    uint queuedShifts(uint index) { return scene.queue[index]; }
    // Every pixel on the image is current, a miss keeping its confidence; the passes draw its domain from the seed
    bool currentDomain(int2 p, out FKDomain dom) {
        dom = {};
        dom.hit.instance_index = NONE;
        return onImage(p);
    }
    uint samples() { return scene.settings.paths; }
    uint restirDecorrelation() { return scene.settings.decorrelation; }
    // Without ReSTIR the scene holds one reservoir and the initial pass stores none
    void storeReservoirInitial(int2 p, Reservoir r, FKHit x1) {
        if (onImage(p) && scene.settings.restir != 0) scene.initial[index(p)] = r;
    }
    void storeReservoirTemporal(int2 p, Reservoir r, FKHit x1) { if (onImage(p)) scene.temporal[index(p)] = r; }
    void storeReservoirPrevious(int2 p, Reservoir r, FKHit x1) { if (onImage(p)) scene.previous[index(p)] = r; }
    // No layer stored beside the reservoir: its primary hit is drawn again from the sample's seed
    void storePreviousLayer(int2 p, uint layer, uint4 value) {}
    uint4 duplication(int2 q) { return uint4(asuint(scene.duplication[index(q)]), 0, 0, 0); }
    void storeDuplication(int2 p, uint4 value) { if (onImage(p)) scene.duplication[index(p)] = asfloat(value.x); }
    uint4 shiftData(int2 p, uint layer) {
        const Shift shift = scene.shifts[3 * index(p) + layer];
        return uint4(asuint(shift.f), asuint(shift.jac));
    }
    void storeShiftData(int2 p, uint layer, uint4 value) {
        if (onImage(p)) scene.shifts[3 * index(p) + layer] = Shift(asfloat(value.xyz), asfloat(value.w));
    }
    // The temporal round's shifts in the spatial round's first two slots and its neighbours, a pixel index, -1 for
    // none, in the third: all three free until the spatial round's prepass rewrites them
    uint4 temporalShift(int2 p, uint layer) { return shiftData(p, layer); }
    void storeTemporalShift(int2 p, uint layer, uint4 value) { storeShiftData(p, layer, value); }
    void storeTemporalNeighbor(int2 p, int2 q) {
        if (onImage(p)) scene.shifts[3 * index(p) + 2].f.x = asfloat(q.x < 0 ? -1 : int(index(q)));
    }
    // Vulkan's temporal round queued, its passes in pipelines of their own
    bool temporalQueued() { return true; }
    int2 loadTemporalNeighbor(int2 p) {
        const int q = asint(scene.shifts[3 * index(p) + 2].f.x);
        return q < 0 ? int2(-1) : int2(q % int(scene.width), q / int(scene.width));
    }
    uint4 reservoirTemporal(int2 q, uint layer) {
        const Reservoir r = scene.temporal[index(q)];
        return uint4(r.seed, r.path, asuint(r.w), asuint(r.c));
    }
    // Temporal output, background and color store: no pass here calls them
    uint isTemporal() { return 0; }
    float3x3 invViewMatrix() { return float3x3(float3(0), float3(0), float3(0)); }
    void storeColor(int2 p, uint layer, float4 color) {}
    bool restirUsed() { return scene.settings.restir != 0; }
    // The world seen along a path whose camera ray hits nothing, at its share of the pixel's paths
    float3 missed(int2 p, FKDomain dom, float scale) {
        return environment(scene, normalize(dom.x1 - dom.x0), Ray(true, false, LOBE_NONE, 1, 0)) / scene.settings.paths;
    }
    // Added to the pixel's sum: the initial pass's with its sample counted, the spatial pass's without
    void addColor(int2 p, float4 color) { scene.accumulation[index(p)] += color; }
};
// The walk's domain of a renderer's domain, a miss of no instance
FKDomain fkDomain(Domain dom) {
    return FKDomain(dom.x0, dom.x1, FKHit(dom.hit.uv, dom.hit.triangle == NONE ? NONE : dom.hit.instance,
        dom.hit.triangle, 0, length(dom.x1 - dom.x0)), dom.width, dom.spread);
}

// Running sums of a hair table level's rows (image 0) or columns (1), RGBA by lobe, filtered at x and y
float4 hairSums(Scene* scene, float4* record, uint image, float x, float y) {
    const float2 size = image == 0 ? float2(record[1].y + 1, record[1].x) : float2(record[1].z + 2, 16 * record[1].x);
    return filtered[NonUniformResourceIndex(uint(scene.images[2 * uint(record[0].w) + 2 * image + 1]))].SampleLevel(
        samplers[1], float2(x, y) / size, 0);
}
uint hairSearch(Scene* scene, float4* record, uint image, float y, uint p, float q, uint count) {
    uint low = 0, high = count - 1;
    while (low < high) {
        const uint middle = (low + high + 1) / 2;
        if (hairSums(scene, record, image, middle + 0.5f, y)[p] <= q) low = middle; else high = middle - 1;
    }
    return low;
}
// Baked hair at slice o: per lobe its weight times the densities of its row y[p] and of column x,
// lobe R tinted, an artistic extension
static const float HAIR_WIDTHS[4] = {1, 0.5f, 2, 2};
static const float HAIR_TILTS[4] = {-2, 1, 4, 0};
// Rows of lobe p's poles for the viewer at in_angle
float2 hairPoles(float4* record, uint p, float w, float a, float in_angle) {
    const float nt = record[1].y, tilt = in_angle + HAIR_TILTS[p] * record[0].z;
    return float2(clamp((asinh((-PI / 2 - tilt) / w) / a + 1) * nt / 2, 0, nt),
        clamp((asinh((PI / 2 - tilt) / w) / a + 1) * nt / 2, 0, nt));
}
float3 hairSlice(Scene* scene, float4* record, float o, float4 y, float x, float3 u, float3 tint, bool binned,
    out float density, float in_angle) {
    const float nt = record[1].y, np = record[1].z, c = binned ? floor(x) : x - 0.5f - np * floor((x - 0.5f) / np);
    float4 n[3], total = 0;
    for (uint k = 0; k < 3; ++k) {
        const float level = o * 16 + saturate(u[k]) * 15 + 0.5f;
        n[k] = (hairSums(scene, record, 1, c + 1.5f, level) - hairSums(scene, record, 1, c + 0.5f, level)) * np
            / (2 * PI);
        if (binned) total += hairSums(scene, record, 1, np + 0.5f, level);
    }
    const float4 all = binned ? record[2] * hairSums(scene, record, 0, nt + 0.5f, o + 0.5f) : 0;
    float3 f = 0;
    density = 0;
    for (uint p = 0; p < 4; ++p) {
        const float w = record[0].x * (p == 0 ? record[0].y : 1) * HAIR_WIDTHS[p], a = asinh(PI / w);
        const float r = binned ? floor(y[p]) : clamp(y[p] - 0.5f, 0, nt - 1), m = y[p] >= 0 && y[p] < nt ? record[2][p]
            * (hairSums(scene, record, 0, r + 1.5f, o + 0.5f) - hairSums(scene, record, 0, r + 0.5f, o + 0.5f))[p]
            / (w * cosh((2 * y[p] / nt - 1) * a) * a * 2 / nt) : 0;
        const float2 pole = hairPoles(record, p, w, a, in_angle); // The lobe whole between the poles
        const float scale = hairSums(scene, record, 0, nt + 0.5f, o + 0.5f)[p] / max((hairSums(scene, record, 0,
            pole.y + 0.5f, o + 0.5f) - hairSums(scene, record, 0, pole.x + 0.5f, o + 0.5f))[p], 1e-30f);
        f += m * scale * float3(n[0][p], n[1][p], n[2][p]) * (p == 0 ? tint : float3(1, 1, 1));
        density += m * scale * (n[0][p] + n[1][p] + n[2][p]) / max(dot(all, total), 1e-30f);
    }
    return f;
}
// f cos toward out_dir and its density, blended between the slices about the viewer's sine
SampleBSDF connectHair(Scene* scene, Surface surface, float3 in_dir, float3 out_dir) {
    const float3 t = normalize(surface.hair);
    float4* record = scene.hairs + 3 * (uint(length(surface.hair) + 0.5f) - 1);
    const float no = record[1].x, s = clamp((asin(clamp(-dot(in_dir, t), -1, 1)) / PI + 0.5f) * (no - 1), 0, no - 1),
        o = min(floor(s), no - 2); // Its slices even in the viewer's angle from pole to pole
    float4 y;
    for (uint p = 0; p < 4; ++p)
        y[p] = hairRow(in_dir, t, out_dir, p, record[0].x * (p == 0 ? record[0].y : 1), record[0].z, uint(record[1].y));
    const float x = hairColumn(in_dir, t, out_dir, uint(record[1].z));
    const float cosine = max(length(cross(out_dir, t)), BIAS); // cos theta, off 0 along the fiber by BIAS
    const float3 tint = used(SPECULAR) ? surface.tint : float3(1, 1, 1); // The Specular Tint, R's
    float near, far, unused, in_angle = asin(clamp(dot(in_dir, t), -1, 1));
    const float3 f = lerp(hairSlice(scene, record, o, y, x, surface.albedo, tint, false, unused, in_angle),
        hairSlice(scene, record, o + 1, y, x, surface.albedo, tint, false, unused, in_angle), s - o);
    hairSlice(scene, record, o, y, x, surface.albedo, tint, true, near, in_angle), hairSlice(scene, record, o + 1, y, x,
        surface.albedo, tint, true, far, in_angle);
    const float density = lerp(near, far, s - o);
    return SampleBSDF(out_dir, density > 0 ? f / density : 0, 0, false, dot(out_dir, -in_dir) > dot(out_dir, t)
        * dot(-in_dir, t) ? LOBE_REFLECT : LOBE_REFRACT, density / cosine);
}
// Direction sampled by slice, lobe, row and column, each by its running sums
SampleBSDF sampleHair(Scene* scene, Surface surface, float3 in_dir, uint state) {
    const float3 t = normalize(surface.hair);
    float4* record = scene.hairs + 3 * (uint(length(surface.hair) + 0.5f) - 1);
    const float no = record[1].x, nt = record[1].y, np = record[1].z;
    const float s = clamp((asin(clamp(-dot(in_dir, t), -1, 1)) / PI + 0.5f) * (no - 1), 0, no - 1);
    Random r = pcg(state);
    const float o = min(floor(s), no - 2) + float(r.value < s - min(floor(s), no - 2));
    const float4 all = record[2] * hairSums(scene, record, 0, nt + 0.5f, o + 0.5f);
    float4 n[3], mass = 0;
    for (uint k = 0; k < 3; ++k)
        mass += n[k] = all * hairSums(scene, record, 1, np + 0.5f, o * 16 + saturate(surface.albedo[k]) * 15 + 0.5f);
    float q = (r = pcg(r.state)).value * (mass.x + mass.y + mass.z + mass.w);
    uint p = 0, k = 0;
    for (; p < 3 && q >= mass[p]; ++p) q -= mass[p];
    for (q = (r = pcg(r.state)).value * mass[p]; k < 2 && q >= n[k][p]; ++k) q -= n[k][p];
    // Its row between the poles, by the sums' linear inverse there: no draw crosses a pole
    const float w = record[0].x * (p == 0 ? record[0].y : 1) * HAIR_WIDTHS[p];
    const float2 pole = hairPoles(record, p, w, asinh(PI / w), asin(clamp(dot(in_dir, t), -1, 1)));
    const float low = hairSums(scene, record, 0, pole.x + 0.5f, o + 0.5f)[p], row_q = low + (r = pcg(r.state)).value
        * (hairSums(scene, record, 0, pole.y + 0.5f, o + 0.5f)[p] - low);
    const uint row = hairSearch(scene, record, 0, o + 0.5f, p, row_q, uint(nt));
    const float s0 = hairSums(scene, record, 0, row + 0.5f, o + 0.5f)[p];
    float y = row + (row_q - s0) / max(hairSums(scene, record, 0, row + 1.5f, o + 0.5f)[p] - s0, 1e-30f);
    r = pcg(r.state);
    r = pcg(r.state);
    float x = hairSearch(scene, record, 1, o * 16 + saturate(surface.albedo[k]) * 15 + 0.5f, p, r.value * n[k][p]
        / all[p], uint(np));
    x += (r = pcg(r.state)).value;
    SampleBSDF sampled = connectHair(scene, surface, in_dir, hairDirection(in_dir, t, p, y, x, record[0].x
        * (p == 0 ? record[0].y : 1), record[0].z, uint(nt), uint(np)));
    sampled.random_state = r.state;
    return sampled;
}
// Pixel coordinates a camera sees a position at
float2 project(Camera camera, float3 position, uint3 size) {
    const float3 d = position - camera.origin;
    if (camera.lens.ortho != 0)
        return float2((1 + dot(d - camera.z, camera.x) / dot(camera.x, camera.x)) * 0.5f * size.x,
            (1 - dot(d - camera.z, camera.y) / dot(camera.y, camera.y)) * 0.5f * size.y);
    // d = (x * u + y * v + z) * s, det = dot(cross(x, y), z)
    // depth = dot(cross(x, y), d) = s * det, dot(cross(d, y), z) = u * s * det, dot(cross(x, d), z) = v * s * det
    // => u = dot(cross(d, y), z) / depth, v = dot(cross(x, d), z) / depth
    const float depth = dot(cross(camera.x, camera.y), d);
    return float2((1 + dot(cross(d, camera.y), camera.z) / depth) * 0.5f * size.x,
        (1 - dot(cross(camera.x, d), camera.z) / depth) * 0.5f * size.y);
}


// A texel of the bake the frame numbers, its top bit the pass: the albedo the program's surface takes there
// Tiles of 16 x 16 texels over a triangle's UVs: owned by one triangle in the first pass, padding baked
// texels in the second
void bake(uint3 p, Scene* scene) {
    const uint program = scene.frame & ~(1u << 31);
    const uint first = asuint(scene.ops[program - 1].value.x), width = asuint(scene.ops[program - 1].value.y);
    const uint height = asuint(scene.ops[program - 1].value.z);
    uint2* texels = (uint2*)(scene.texels + first);
    const Info info = {{0, 0, 0}, {0, 0, 0, 0}, 0, 0, {0, 0, 0, 0, 0, 0, 0, 0, 0}};
    if (asuint(scene.ops[program - 2].value.y) == 0) { // Over UV space, without tiles: each texel at its UV
        if (p.x >= width || p.y >= (height & 0xFFFFFF)) return;
        Point point = {};
        point.u = (p.x + 0.5f) / width; point.v = (p.y + 0.5f) / (height & 0xFFFFFF);
        const float3 c = shade(scene, program, float3(0, 0, 1), float3x3(float3(0), float3(0), float3(0)), point,
            float3(0, 0, 1), false, Ray(false, false, LOBE_NONE, 0, 0), info).albedo;
        texels[p.y * width + p.x] = uint2(f32tof16(c.x) | f32tof16(c.y) << 16, f32tof16(c.z) | f32tof16(1.0f) << 16);
        return;
    }
    const uint4 tile = scene.bakeTexels[asuint(scene.ops[program - 2].value.x) + p.x / 16];
    const uint x = tile.y * 16 + p.x % 16, y = tile.z * 16 + p.y;
    if (x >= width || y >= height) return;
    if ((scene.frame >> 31) != 0) {
        const int u[] = {int(x) - 1, int(x) + 1, int(x), int(x)}, v[] = {int(y), int(y), int(y) - 1, int(y) + 1};
        for (int k = 0; k < 4 && texels[y * width + x].y >> 16 == 0; ++k) {
            if (u[k] < 0 || v[k] < 0 || u[k] >= int(width) || v[k] >= int(height)) continue;
            const uint2 texel = texels[v[k] * width + u[k]];
            if (texel.y >> 16 == 0x3C00) texels[y * width + x] = uint2(texel.x, texel.y & 0xFFFF | 0x38000000);
        }
        return;
    }
    const Hit unit = owned(scene, tile.x); // Its mesh's triangle, whose UVs it bakes over
    float2* uv = scene.uvs + 3 * unit.triangle;
    int64_t px[3], py[3];
    for (int k = 0; k < 3; ++k) {
        px[k] = int64_t(floor(uv[k].x * width * 512)); py[k] = int64_t(floor(uv[k].y * height * 512));
    }
    const int64_t area = (px[1] - px[0]) * (py[2] - py[0]) - (py[1] - py[0]) * (px[2] - px[0]);
    for (int k = 0; k < 3; ++k) {
        const int a = area > 0 ? k : (3 - k) % 3, b = area > 0 ? (k + 1) % 3 : (5 - k) % 3;
        const int64_t dx = px[b] - px[a], dy = py[b] - py[a];
        const int64_t w = dx * (int64_t(2 * y + 1) * 256 - py[a]) - dy * (int64_t(2 * x + 1) * 256 - px[a]);
        if (area == 0 || w < 0 || w == 0 && !(dy > 0 || dy == 0 && dx > 0)) return;
    }
    const float2 e = uv[1] - uv[0], f = uv[2] - uv[0], c = float2((x + 0.5f) / width, (y + 0.5f) / height) - uv[0];
    const float det = e.x * f.y - e.y * f.x;
    const Point point = at(scene, unit.instance, unit.triangle, (c.x * f.y - c.y * f.x) / det,
        (e.x * c.y - e.y * c.x) / det);
    const float3 albedo = shade(scene, program, float3(0, 0, 1), float3x3(float3(0), float3(0), float3(0)), point,
        float3(0, 0, 1), false, Ray(false, false, LOBE_NONE, 0, 0), info).albedo;
    texels[y * width + x] =
        uint2(f32tof16(albedo.x) | f32tof16(albedo.y) << 16, f32tof16(albedo.z) | f32tof16(1.0f) << 16);
}

// Mean emission over the triangle's UVs and generated coordinates
// Its frame's bit 30 set, the world instead at each texel center of a band of rows of its grid, from the frame's row
// phi = 2 * PI * (x + 0.5) / environmentWidth, theta = PI * (y + 0.5) / environmentHeight
// direction = (-sin(theta) * cos(phi), sin(theta) * sin(phi), cos(theta))
// => u = 0.5 - atan2(direction.y, direction.x) / (2 * PI) = phi / (2 * PI), v = 1 - theta / PI, row 0 the zenith
void lights(uint3 p, Scene* scene) {
    if ((scene.frame >> 30 & 1) != 0) {
        const float phi = 2 * PI * (p.x + 0.5f) / scene.environmentWidth;
        const float theta = PI * ((scene.frame & 0xFFFFFF) + p.y + 0.5f) / scene.environmentHeight;
        const float3 c = environment(scene, float3(-sin(theta) * cos(phi), sin(theta) * sin(phi), cos(theta)),
            Ray(false, false, LOBE_NONE, 2, 0)); // At the depth and lobe its sky samples see it
        scene.bakeTexels[p.y * scene.environmentWidth + p.x] = asuint(float4(c, 0));
        return;
    }
    const uint triangle = p.x;
    const float emitted = scene.materials[triangle].emitted;
    const Hit light = owned(scene, triangle);
    if (!(emitted > 0) || scene.instances[light.instance].world == STRANDS) return; // Sampled by no light
    static const uint LIGHT_SAMPLES = 256;
    uint state = hash(triangle);
    float mean = 0;
    for (uint i = 0; i < LIGHT_SAMPLES; ++i) {
        const float side = sqrt((i + random(state)) / LIGHT_SAMPLES), along = random(state);
        const float3 n = faceNormal(scene, light.instance, light.triangle);
        float3 emission = shade(scene, light.instance, light.triangle, side * (1 - along), side * along, n, -n,
            Ray(false, false, LOBE_NONE, 0, 0), 0, true).emissive;
        if (!(emission.x + emission.y + emission.z > 0)) // Its back's where its front emits nothing, as a portal's
            emission = shade(scene, light.instance, light.triangle, side * (1 - along), side * along, n, n,
                Ray(false, false, LOBE_NONE, 0, 0), 0, true).emissive;
        mean += max(emission.x + emission.y + emission.z, 0.0f) / LIGHT_SAMPLES;
    }
    scene.materials[triangle].emitted = max(mean, emitted * 0.001f);
}

// Denoiser input and guides of the pixel, and the motion of what it sees since the last denoised frame
void denoise(uint3 p, uint3 size, Scene* scene) {
    const uint index = p.y * size.x + p.x;
    const float4 sum = scene.accumulation[index];
    scene.mean[index] = float4(sum.xyz / sum.w, 1.0f);
    const Domain dom = pixelDomain(scene, scene.camera, index, size, index);
    const Camera last = scene.denoisedCamera;
    const uint seen = dom.hit.triangle == NONE ? NONE : key(scene, dom.hit);
    const float3 before = dom.hit.triangle == NONE ? last.origin + dom.x1 - dom.x0
        : hitPosition(scene, scene.previousVertices, dom.hit);
    const float2 then = project(last, before, size);
    scene.flow[index] = project(scene.camera, dom.x1, size) - then;
    const int x = int(floor(then.x)), y = int(floor(then.y));
    const float3 back = cross(last.x, last.y);
    scene.trust[index] = float(dot(back, before - last.origin) * dot(back, last.z) > 0.0f && x >= 0 && y >= 0
        && x < int(size.x) && y < int(size.y) && scene.previousSeen[y * size.x + x] == seen);
    scene.seen[index] = seen;
}

// Fraction of the 17 x 17 neighborhood sharing each pixel's sample (Sec. 5)
void duplicates(uint3 p, uint3 size, Scene* scene) {
    const uint index = p.y * size.x + p.x;
    const Reservoir own = scene.previous[index];
    uint count = 0u;
    for (int y = int(p.y) - 8; y <= int(p.y) + 8; y++) {
        for (int x = int(p.x) - 8; x <= int(p.x) + 8; x++) {
            if (x >= 0 && y >= 0 && x < int(size.x) && y < int(size.y)) {
                const Reservoir other = scene.previous[y * size.x + x];
                count += other.w > 0.0f && other.seed == own.seed ? 1u : 0u;
            }
        }
    }
    scene.duplication[index] = own.w > 0.0f ? (count - 1u) / 288.0f : 0.0f;
}

// A pass's record: its raygen program's number, then its scene
struct Record { uint program; uint header[7]; Scene scene; };
struct Launch { Record* record; uint width, height, depth; };
[[vk::push_constant]] Launch launch;

// The launch's raygen program at its index; a group's threads in a row for launches one high, its workgroups in rows of
// ROW_GROUPS
// The temporal round's count and queue in a pipeline of their own: every invocation of a workgroup, for their barriers
void runQueue(uint3 thread, uint3 group, uint index) {
    Scene* scene = &launch.record.scene;
    if (launch.record.program == PASS_TEMPORAL_COUNT) restir_temporal_count(VkScene(scene), thread, index);
    else restir_temporal_prepass(VkScene(scene), thread, index);
}
// The temporal round's queued shifts and reuse in a third pipeline, as run takes the passes
void runTemporal(uint3 thread, uint3 group, uint index) {
    const uint3 size = uint3(launch.width, launch.height, launch.depth);
    const uint3 p = size.y == 1 && size.z == 1 ? uint3((group.y * ROW_GROUPS + group.x) * 64 + index, 0, 0) : thread;
    Scene* scene = &launch.record.scene;
    if (any(p >= size)) return;
    if (launch.record.program == PASS_TEMPORAL_SHIFT) restir_temporal_shift(VkScene(scene), uint3(group.xy, 0), index);
    else restir_temporal(VkScene(scene), thread);
}
void run(uint3 thread, uint3 group, uint index) {
    const uint3 size = uint3(launch.width, launch.height, launch.depth);
    const uint3 p = size.y == 1 && size.z == 1 ? uint3((group.y * ROW_GROUPS + group.x) * 64 + index, 0, 0) : thread;
    Scene* scene = &launch.record.scene;
    // The spatial round's count and queue: every invocation of a workgroup, past the image too, which have no job,
    // for their barriers
    if (launch.record.program == PASS_COUNT) return restir_count(VkScene(scene), thread, index);
    if (launch.record.program == PASS_PREPASS) return restir_prepass(VkScene(scene), thread, index);
    if (any(p >= size)) return;
    switch (launch.record.program) {
        case PASS_INITIAL: restir_initial(VkScene(scene), thread); break;
        case PASS_SHIFT: restir_shift(VkScene(scene), uint3(group.xy, 0), index); break; // Jobs of the queue, 64 a bin
        case PASS_SPATIAL: restir_spatial(VkScene(scene), thread); break;
        case PASS_DUPLICATES: duplicates(p, size, scene); break;
        case PASS_BAKE: if (used(BAKED)) bake(p, scene); break; // Only for scenes that bake
        case PASS_LIGHTS: lights(p, scene); break;
        default: denoise(p, size, scene); break;
    }
}
}

// The walk through the scene hooks, of the walk's domain
[noinline] Shift walkDomain<let REPLAY: bool>(fcpt.VkScene scene, FKDomain dom, Reservoir r, float scale,
    inout Selection sel) {
    return walk(scene, dom, r, REPLAY, scale, sel);
}

// The entry point
[shader("compute")] [numthreads(8, 8, 1)]
void main(uint3 thread : SV_DispatchThreadID, uint3 group : SV_GroupID, uint index : SV_GroupIndex) {
    fcpt.run(thread, group, index);
}
[shader("compute")] [numthreads(8, 8, 1)]
void queue(uint3 thread : SV_DispatchThreadID, uint3 group : SV_GroupID, uint index : SV_GroupIndex) {
    fcpt.runQueue(thread, group, index);
}
[shader("compute")] [numthreads(8, 8, 1)]
void temporal(uint3 thread : SV_DispatchThreadID, uint3 group : SV_GroupID, uint index : SV_GroupIndex) {
    fcpt.runTemporal(thread, group, index);
}
