#include "renderer.h"
#include <optix.h>
#include <cuda_runtime.h>

constexpr int STACK = 64;
constexpr int SLOTS = 32; // Values a program keeps for reuse, as the extension's
constexpr float PI = 3.14159265f;
constexpr float INV_PI = 0.3183098861837907f;
constexpr float BIAS = 0.0000152587890625f;
constexpr float MAX_SAFE_INTEGER_FOR_F32 = 8388607.0f;
// Columns
struct Matrix { float3 x, y, z; };
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
__device__ float decode(unsigned char srgb) {
    return srgb <= 10 ? srgb / 3294.6f : powf((srgb / 255.0f + 0.055f) / 1.055f, 2.4f);
}
__device__ unsigned hash(unsigned x) { // PCG
    x = x * 747796405u + 2891336453u;
    x = ((x >> ((x >> 28) + 4)) ^ x) * 277803737u;
    return (x >> 22) ^ x;
}
__device__ float random(unsigned& state) { return ((state = hash(state)) >> 8) * 0x1p-24f; }
// In [0, 1) to double precision, from 27 and 26 bits of two draws
__device__ double random53(unsigned& state) {
    const unsigned high = (state = hash(state)) >> 5;
    const unsigned low = (state = hash(state)) >> 6;
    return (high * 0x1p26 + low) * 0x1p-53;
}
__device__ float3 decode(uchar4 texel) { return make_float3(decode(texel.x), decode(texel.y), decode(texel.z)); }
struct Random { unsigned state; float value; };
struct RandomSphere { unsigned state; float3 value; };
struct RandomHemisphere { unsigned state; float3 value; };
// The state advanced and the value drawn from it
__device__ Random pcg(unsigned state) {
    const float value = random(state);
    return Random{state, value};
}
__device__ float rgb_to_greyscale(float3 rgb) { return dot(rgb, make_float3(0.299f, 0.587f, 0.114f)); }
// Exact Smith masking of GGX, the visible normal density sampleGGXVNDF draws from
__device__ float smithG1(float alpha, float n_dot_x) {
    const float alpha_sq = alpha * alpha;
    return 2.0f * n_dot_x / (n_dot_x + sqrtf(alpha_sq + (1.0f - alpha_sq) * n_dot_x * n_dot_x));
}


__device__ Random normal_distribution(unsigned state) {
    const Random r1 = pcg(state);
    const Random r2 = pcg(r1.state);
    // Sample normal distribution
    const float theta = 2.0f * PI * r1.value;
    const float rho = sqrtf(-2.0f * fminf(fmaxf(logf(r2.value), - MAX_SAFE_INTEGER_FOR_F32), 0.0f));
    return Random{r2.state, rho * cosf(theta)};
}

__device__ RandomSphere random_sphere(unsigned state) {
    const Random x = normal_distribution(state);
    const Random y = normal_distribution(x.state);
    const Random z = normal_distribution(y.state);
    return RandomSphere{z.state, normalize(make_float3(x.value, y.value, z.value))};
}

__device__ RandomHemisphere random_hemisphere(unsigned state, float3 normal) {
    const RandomSphere random_sphere = ::random_sphere(state);
    // If the random sphere is in the same hemisphere as the normal, return it
    if(dot(random_sphere.value, normal) > 0.0f) {
        return RandomHemisphere{random_sphere.state, random_sphere.value};
    } else {
        // Otherwise, return the opposite direction
        return RandomHemisphere{random_sphere.state, - random_sphere.value};
    }
}

__device__ float trowbridgeReitz(float alpha, float n_dot_h) {
    const float numerator = alpha * alpha;
    const float denom = n_dot_h * n_dot_h * (numerator - 1.0f) + 1.0f;
    return numerator / fmaxf(PI * denom * denom, BIAS);
}

__device__ float G1(float alpha, float n_dot_x) {
    return smithG1(alpha, n_dot_x);
}
/*
fn delta(v: vec3<f32>, alpha: f32) -> f32 {
    let alpha_sq: f32 = alpha * alpha;
    let nom: f32 = alpha_sq * (v.x + v.y)

    let sqrt_term: f32 = sqrt(alpha * alpha + v.z * v.z);
}
*/

__device__ float schlickBeckmann(float k, float n_dot_x) {
    return n_dot_x / fmaxf(n_dot_x * (1.0f - k) + k, BIAS);
}

__device__ float smith(float alpha, float n_dot_v, float n_dot_l) {
    return smithG1(alpha, n_dot_v) * smithG1(alpha, n_dot_l);
}

/*
fn smithAlt(alpha: f32, n_dot_v: f32, n_dot_l: f32) -> f32 {
    let k: f32 = alpha * 0.5f;
    return 1.0f / max((n_dot_v * (1.0f - k) + k) * (n_dot_l * (1.0f - k) + k), BIAS);
}
*/
/*
fn fresnel_schlick(f0: vec3<f32>, cos_theta: f32) -> vec3<f32> {
    // Use Schlick approximation
    return f0 + (1.0f - f0) * pow(1.0f - cos_theta, 5.0f);
}
*/

__device__ float fresnel(float cos_theta, float eta_i, float eta_o) {
    // Compute sini using Snell's law
    const float sin_theta = sqrtf(fmaxf(0.0f, 1.0f - cos_theta * cos_theta));
    const float sin_psi = (eta_i / eta_o) * sin_theta;
    // Total internal reflection
    float kr = 1.0f;
    if (sin_psi < 1.0f) {
        const float cos_psi = sqrtf(fmaxf(0.0f, 1.0f - sin_psi * sin_psi));
        // cos = abs(cosi);
        const float Rs = ((eta_o * cos_theta) - (eta_i * cos_psi)) / ((eta_o * cos_theta) + (eta_i * cos_psi));
        const float Rp = ((eta_i * cos_theta) - (eta_o * cos_psi)) / ((eta_i * cos_theta) + (eta_o * cos_psi));
        kr = (Rs * Rs + Rp * Rp) / 2.0f;
    }

    return kr;
}

// Helper function for GGX importance sampling
// Corresponding PDF is: pdf = trowbridgeReitz(alpha, n_dot_h) * n_dot_h
/*
fn sampleTrowbridgeReitz(alpha: f32, random_1: f32, random_2: f32) -> vec3<f32> {
    let theta: f32 = atan(alpha * sqrt(random_1) / sqrt(1.0f - random_1));
    let phi: f32 = 2.0f * PI * random_2;
    let sin_theta: f32 = sin(theta);
    return vec3<f32>(sin_theta * cos(phi), sin_theta * sin(phi), cos(theta));
}
*/

// Sampling of the GGX VNDF
__device__ float3 sampleGGXVNDF(float3 Ve, float alpha, float U1, float U2) {
    // The Ve argument is the view direction in tangent space, where the normal is (0, 0, 1).
    // Section 3.2: transforming the view direction to the hemisphere configuration.
    const float3 Vh = normalize(make_float3(alpha * Ve.x, alpha * Ve.y, Ve.z));
    // Section 4.1: orthonormal basis (with special case if cross product is zero).
    const float lensq = Vh.x * Vh.x + Vh.y * Vh.y;
    const float3 T1 = lensq > 0.0f ? make_float3(-Vh.y, Vh.x, 0.0f) * rsqrtf(lensq) : make_float3(1.0f, 0.0f, 0.0f);
    const float3 T2 = cross(Vh, T1);
    // Section 4.2: parameterization of the projected area.
    const float r = sqrtf(U1);
    const float phi = 2.0f * PI * U2;
    const float t1 = r * cosf(phi);
    float t2 = r * sinf(phi);
    const float s = 0.5f * (1.0f + Vh.z);
    t2 = (1.0f - s) * sqrtf(fmaxf(0.0f, 1.0f - t1 * t1)) + s * t2;
    // Section 4.3: reprojection onto hemisphere.
    const float3 Nh = t1 * T1 + t2 * T2 + sqrtf(fmaxf(0.0f, 1.0f - t1 * t1 - t2 * t2)) * Vh;
    // Section 3.4: transforming the normal back to the ellipsoid configuration.
    return normalize(make_float3(alpha * Nh.x, alpha * Nh.y, fmaxf(0.0f, Nh.z)));
}

// Corresponding PDF is: pdf = cos(theta) / PI
__device__ float3 sampleCosWeightedHemisphere(float random_1, float random_2) {
    const float r = sqrtf(random_1);
    const float theta = 2.0f * PI * random_2;
    const float x = r * cosf(theta);
    const float z = r * sinf(theta);
    const float y = sqrtf(fmaxf(0.0f, 1.0f - x * x - z * z));
    return make_float3(x, y, z);
}

__device__ float3 tangentToWorld(float3 v, float3 n) {
    float3 a = make_float3(0.0f, 1.0f, 0.0f);
    if (fabsf(dot(n, a)) > 1.0f - BIAS) {
        a = make_float3(1.0f, 0.0f, 0.0f);
    }
    const float3 tangent = normalize(cross(n, a));
    const float3 bitangent = cross(n, tangent);
    return v.x * tangent + v.y * n + v.z * bitangent;
}

__device__ float3 worldToTangent(float3 v, float3 n) {
    float3 a = make_float3(0.0f, 1.0f, 0.0f);
    if (fabsf(dot(n, a)) > 1.0f - BIAS) {
        a = make_float3(1.0f, 0.0f, 0.0f);
    }
    const float3 tangent = normalize(cross(n, a));
    const float3 bitangent = cross(n, tangent);
    return make_float3(dot(v, tangent), dot(v, n), dot(v, bitangent));
}

// Build TBN matrix for tangent-space normal mapping. Uses triangle edges and UV deltas to compute
// tangent (U direction) and bitangent (V direction), with handedness fix.
__device__ Matrix normalMapTBN(float3 p0, float3 p1, float3 p2, float2 uv0, float2 uv1, float2 uv2, float3 n) {
    const float3 e1 = p1 - p0;
    const float3 e2 = p2 - p0;
    const float2 duv1 = uv1 - uv0;
    const float2 duv2 = uv2 - uv0;
    // Compute inverse determinant for UV to world space transformation.
    const float det = duv1.x * duv2.y - duv1.y * duv2.x;
    const float inv_det = 1.0f / det;
    float3 t = (e1 * duv2.y - e2 * duv1.y) * inv_det;
    const float3 b_geom = (e2 * duv1.x - e1 * duv2.x) * inv_det;

    // Gram-Schmidt: make tangent perpendicular to interpolated normal.
    t = normalize(t - n * dot(n, t));
    // Handedness: bitangent along the geometric b, mirrored with the UVs, as Blender's tangent space.
    const float3 b = cross(n, t) * sign(dot(cross(n, t), b_geom));

    return Matrix{t, b, n};
}

__device__ float3 tangentToWorldNormalMap(float3 v, Matrix tbn) {
    return tbn.x * v.x + tbn.y * v.y + tbn.z * v.z;
}

// BSDF takes in incoming and outgoing directions and surface properties returning throughput for direct lighting
// Only consider lighting on the surface of the object, not the inside. Assume direct light is always outside the object as shadowing also makes that assumption.
__device__ float3 BSDF(float3 in_dir, float3 out_dir, float3 n, float3 g_n, const Surface& material, float eta_i,
    float eta_o, float2 screen_space) {
    const float3 v = - in_dir;
    // Precalculate dot products
    const float n_dot_v = dot(n, v);
    const float n_dot_l = dot(n, out_dir);
    // Calculate material constants needed for BRDF and BTDF
    float alpha = material.roughness * material.roughness;
    // Precalculate dot products for geometry normal
    const float g_n_dot_v = dot(g_n, v);
    const float g_n_dot_l = dot(g_n, out_dir);
    // Test if v and l are on the same side of the surface
    if (g_n_dot_v * g_n_dot_l > 0.0f) {
        // If v and l are on the same side of the surface do Torrance-Sparrow BRDF
        // Positive definite dot products
        const float pd_n_dot_v = fmaxf(n_dot_v, 0.0f);
        const float pd_n_dot_l = fmaxf(n_dot_l, 0.0f);
        // Precaluclate dot products and half vectors
        const float3 h_r = normalize(out_dir + v);
        const float v_dot_h = fmaxf(dot(v, h_r), 0.0f);
        const float n_dot_h = fmaxf(dot(n, h_r), 0.0f);
        // Lambertian diffuse
        const float3 lambert = material.albedo * INV_PI;
        // Torrance-Sparrow
        const float3 F = mix(make_float3(1.0f, 1.0f, 1.0f) * fresnel(fabsf(v_dot_h), eta_i, eta_o), material.albedo,
            material.metallic);

        const float F_greyscale = rgb_to_greyscale(F);
        const float D = trowbridgeReitz(alpha, n_dot_h);
        // let G = smithAlt(alpha, pd_n_dot_v, pd_n_dot_l);
        const float G = smith(alpha, pd_n_dot_v, pd_n_dot_l);
        const float diffuse_factor = (1.0f - F_greyscale) * (1.0f - material.metallic) * (1.0f - material.transparency);
        const float3 torrance_sparrow = D * F * G / fmaxf(4.0f * pd_n_dot_v * pd_n_dot_l, BIAS);
        const float3 radiance = diffuse_factor * lambert + torrance_sparrow;
        return radiance * n_dot_l;
    } else {
        // Refractive half-vector (eq. 16)
        const float3 ht_unorm = - (eta_i * v + eta_o * out_dir);
        const float3 ht = normalize(ht_unorm);
        // Precalculate dot products
        const float v_dot_ht = dot(v, ht);
        const float l_dot_ht = dot(out_dir, ht);
        const float n_dot_ht = fabsf(dot(n, ht));
        // Microfacet terms
        const float DT = trowbridgeReitz(alpha, fabsf(n_dot_ht));
        const float GT = smith(alpha, fabsf(n_dot_v), fabsf(n_dot_l));

        const float3 FT = mix(make_float3(1.0f, 1.0f, 1.0f) * fresnel(fabsf(v_dot_ht), eta_i, eta_o), material.albedo,
            material.metallic);
        // Geometry term numerator and denominator
        const float numerator_geom = fabsf(v_dot_ht) * fabsf(l_dot_ht);
        const float denominator_geom = fabsf(n_dot_v) * fabsf(n_dot_l);
        // Refractive term denominator
        const float denom_f = eta_i * v_dot_ht + eta_o * l_dot_ht;
        const float denom_f_sq = denom_f * denom_f;
        // Check if refraction is possible
        if (fabsf(denom_f) > BIAS && denominator_geom > BIAS) {
            // Term is uncolored by albedo, this is handled by Beer's law in lightTrace
            const float walter = (numerator_geom / denominator_geom) * (1.0f - rgb_to_greyscale(FT)) * DT * GT
                * (eta_o * eta_o / denom_f_sq);
            return make_float3(walter, walter, walter) * material.transparency * n_dot_l;
        }
        // If refraction is not possible, return black this case should never happen
        return make_float3(0.0f, 0.0f, 0.0f);
    }
}

struct SampleBSDF {
    float3 unit_direction;
    float3 throughput;
    unsigned random_state;
    bool refracted;
    unsigned lobe;
    // Solid angle density of the sampled direction as evalLobe defines it, zero for delta lobes
    float pdf;
};

// SampleBSDF takes in incoming direction, surface normal, material and random state and returns an outgoing direction with throughput according to the BSDF for global illumination
__device__ SampleBSDF sampleBSDF(float3 in_dir, float3 n, const Surface& material, float eta_i, float eta_o,
    unsigned random_init, float2 screen_space) {
    unsigned random_state = random_init;
    // Basic dot products
    const float3 v = - in_dir;
    const float n_dot_v = dot(n, v);
    float3 n_i = n * sign(n_dot_v);
    const float n_i_dot_v = fabsf(n_dot_v);
    // Material constants
    const float alpha = material.roughness * material.roughness;
    // Sample using GGX importance sampling for potential refractive or reflective case
    float3 ggx_n = n_i;
    // Generate random values for sampling
    const Random random_h_1 = pcg(random_state);
    const Random random_h_2 = pcg(random_h_1.state);
    random_state = random_h_2.state;
    const float3 v_tangent = worldToTangent(v, n_i);
    ggx_n = xzy(sampleGGXVNDF(xzy(v_tangent), alpha, random_h_1.value, random_h_2.value));
    // Transform half vector back to world space
    ggx_n = tangentToWorld(ggx_n, n_i);
    // Calculate shared half vector dot products
    const float v_dot_h = dot(ggx_n, v);
    const float n_dot_h = dot(n_i, ggx_n);
    // Visible normal density of the unclamped GGX distribution for the sampled half vector
    const float d_term = n_dot_h * n_dot_h * (alpha * alpha - 1.0f) + 1.0f;
    const float pdf_h = alpha > 0.0f && v_dot_h > 0.0f && n_dot_h > 0.0f && n_i_dot_v > 0.0f
        ? smithG1(alpha, n_i_dot_v) * v_dot_h * alpha * alpha / (PI * d_term * d_term * n_i_dot_v) : 0.0f;
    // Try refraction through the properly oriented half vector
    const float eta = eta_i / eta_o;
    const float3 refracted = normalize(refract(in_dir, ggx_n, eta));
    // let refracted_sign = sign(length(refracted));
    // Calculate fresnel term
    float3 F = mix(make_float3(1.0f, 1.0f, 1.0f) * fresnel(fabsf(v_dot_h), eta_i, eta_o), material.albedo,
        material.metallic);
    /*
    if (screen_space.x > 0.0f) {
        let f0_sqrt = (eta_i - eta_o) / (eta_i + eta_o);
        let f0: vec3<f32> = mix(vec3<f32>(f0_sqrt * f0_sqrt), material.albedo, material.metallic);
        F = fresnel_schlick(f0, n_i_dot_v);
    }
    */
    const float F_greyscale = rgb_to_greyscale(F);
    // BSDF weights (these are artistic choices to balance the lobes)
    const float reflect_weight = 1.0f;
    const float diffuse_weight = (1.0f - material.transparency) * (1.0f - material.metallic);
    const float refract_weight = material.transparency;
    // Add fresnel term for improved sampling performance
    const float reflect_component = fmaxf(reflect_weight * F_greyscale, 0.0f);
    const float diffuse_component = fmaxf(diffuse_weight * (1.0f - F_greyscale), 0.0f);
    const float refract_component = fmaxf(refract_weight * (1.0f - F_greyscale)
        * sign(sqrtf(dot(refracted, refracted))), 0.0f);
    // Do not account for chroma of reflection for transmissive materials as in this case our model uses albedo as proxy for absorption instead.
    float colorless_reflection = material.transparency;
    // Calculate sampling probabilities
    const float total_component = reflect_component + diffuse_component + refract_component;
    const float total_component_inv = 1.0f / fmaxf(total_component, BIAS);
    const float p_diffuse = diffuse_component * total_component_inv;
    const float p_reflect = reflect_component * total_component_inv;
    const float p_refract = refract_component * total_component_inv;
    //let p_total_reflect: f32 = total_reflection_component * total_component_inv;

    SampleBSDF sample = SampleBSDF{make_float3(1.0f, 1.0f, 1.0f), make_float3(1.0f, 1.0f, 1.0f), 0u, false, 0u, 0.0f};
    const Random random_p = pcg(random_state);
    random_state = random_p.state;
    // Diffuse case
    if (random_p.value < p_diffuse) {
        const Random random_d_1 = pcg(random_state);
        const Random random_d_2 = pcg(random_d_1.state);
        sample.random_state = random_d_2.state;
        // Sample cosine weighted hemisphere
        const float3 cosine_hemisphere = sampleCosWeightedHemisphere(random_d_1.value, random_d_2.value);
        sample.unit_direction = tangentToWorld(cosine_hemisphere, n_i);

        // BSDF = diffuse_weight * albedo / PI
        // => BSDF * n_dot_v = diffuse_weight * albedo * n_dot_l / PI

        // PDF_COSINE_HEMISPHERE = cosine_hemisphere.y / PI
        // => PDF = cosine_hemisphere.y / PI

        // throughput = BSDF * n_dot_l / PDF
        //            = diffuse_weight * albedo * n_dot_l / PI / cosine_hemisphere.y * PI
        //            = diffuse_weight * albedo * n_dot_l / cosine_hemisphere.y

        // Since cosine_hemisphere.y is n_dot_l over the unit hemisphere, we can simplify the throughput to:
        // => throughput = albedo * diffuse_weight
        sample.throughput = diffuse_weight * material.albedo / p_diffuse * (1.0f - rgb_to_greyscale(mix(make_float3(1.0f,
            1.0f, 1.0f) * fresnel(fabsf(dot(v, normalize(v + sample.unit_direction))), eta_i, eta_o), material.albedo,
            material.metallic)));
        sample.pdf = n_i_dot_v > 0.0f ? p_diffuse * cosine_hemisphere.y * INV_PI : 0.0f;
        return sample;
    }
    // Refractive case
    if (random_p.value < p_diffuse + p_refract) {
        // Refraction is valid
        sample.unit_direction = refracted;
        const float3 l = sample.unit_direction;
        const float m_n_i_dot_l = - dot(n_i, l);
        const float l_dot_h = dot(l, ggx_n);
        const float denom = eta_i * v_dot_h + eta_o * l_dot_h;
        sample.pdf = eta_i != eta_o && l_dot_h < 0.0f
            ? p_refract * pdf_h * eta_o * eta_o * fabsf(l_dot_h) / (denom * denom) : 0.0f;
        // Microfacet term
        // let GT: f32 = smith(alpha, n_i_dot_v, m_n_i_dot_l);
        const float G1_l = G1(alpha, fmaxf(m_n_i_dot_l, 0.0f));
        // JACOBIAN = eta_o^2 * l_dot_h / (eta_i * v_dot_h + eta_o * l_dot_h)^2

        // BSDF = refract_weight * v_dot_h / n_dot_v / n_dot_l * D * G * (1 - F) * JACOBIAN
        // => BSDF * n_dot_l = refract_weight * v_dot_h / n_dot_v * D * G * (1 - F) * JACOBIAN

        // PDF_VNDF = G1_v * v_dot_h * D / n_dot_v
        // PDF_REFRACT = PDF_VNDF * JACOBIAN
        //             = G1_v * v_dot_h * D / n_dot_v * JACOBIAN

        // PDF = PDF_REFRACT
        //     = G1_v * v_dot_h * D / n_dot_v * JACOBIAN

        // throughput = BSDF * n_dot_l
        //            = refract_weight * v_dot_h / n_dot_v * D * G * (1 - F) * JACOBIAN / G1_v / v_dot_h / D * n_dot_v / JACOBIAN
        //            = refract_weight * G * (1 - F) / G1_v

        // G = G1_v * G1_l
        // => throughput = refract_weight * G1_l * (1 - F)
        sample.throughput = make_float3(1.0f, 1.0f, 1.0f) * (refract_weight * G1_l * (1.0f - F_greyscale) / p_refract);
        sample.random_state = random_state;
        sample.refracted = true;
        sample.lobe = 1u;
        return sample;
    }
    // Otherwise assume reflective case.
    sample.unit_direction = normalize(reflect(in_dir, ggx_n));
    const float3 l = sample.unit_direction;
    const float n_i_dot_l = dot(n_i, l);
    // Torrance-Sparrow
    const float G1_l = G1(alpha, fmaxf(n_i_dot_l, 0.0f));
    // BSDF = reflect_weight * D * G * F / (4 * n_dot_v * n_dot_l)
    // => BSDF * n_dot_l = reflect_weight * D * G * F / (4 * n_dot_v)

    // PDF_VNDF = G1_v * v_dot_h * D / n_dot_v
    // JACOBIAN = 1 / (4 * v_dot_h)
    // PDF_REFLECT = PDF_VNDF * JACOBIAN
    // => PDF_REFLECT = G1_v * D / (4 * n_dot_v)

    // PDF = PDF_REFLECT
    // => PDF = G1_v * D / (4 * v_dot_n)

    // throughput = BSDF * n_dot_l / PDF
    //            = reflect_weight * D * G * F / (4 * n_dot_v) / G1_v / D * (4 * n_dot_v)
    //            = reflect_weight * G * F / G1_v

    // G = G1_v * G1_l
    // => throughput = reflect_weight * G1_l * F
    sample.throughput = reflect_weight * G1_l
        * mix(F, make_float3(F_greyscale, F_greyscale, F_greyscale), colorless_reflection) / p_reflect;
    sample.random_state = random_state;
    sample.lobe = 2u;
    sample.pdf = pdf_h > 0.0f ? p_reflect * pdf_h / (4.0f * v_dot_h) : 0.0f;
    return sample;
}

// Surface a program resolves to at a UV, facing along the normal with the tangent space tbn
__device__ Surface shade(const Scene& scene, unsigned program, float3 normal, Matrix tbn, float u, float v) {
    float3 stack[STACK], *top = stack, saved[SLOTS];
    for (const Op* op = scene.ops + program; op->code; ++op) switch (op->code) {
        case PUSH: *top++ = op->value; break;
        case STORE: saved[op->texel] = top[-1]; break;
        case LOAD: *top++ = saved[op->texel]; break;
        case UV: *top++ = make_float3(u, v, 0); break;
        case NORMAL: *top++ = normal; break;
        case IMAGE: case ALPHA: { // Repeating
            const uchar4 texel = scene.texels[op->texel + unsigned(wrap(top[-1].y) * op->height) * op->width
                + unsigned(wrap(top[-1].x) * op->width)];
            top[-1] = op->code == IMAGE ? decode(texel) : make_float3(1, 1, 1) * decode(texel.w);
        } break;
        case NORMAL_MAP: top[-1] = normalize(tangentToWorldNormalMap(top[-1] * 2 - make_float3(1, 1, 1), tbn)); break;
        case ADD: --top; top[-1] = top[-1] + *top; break;
        case SUBTRACT: --top; top[-1] = top[-1] - *top; break;
        case MULTIPLY: --top; top[-1] = top[-1] * *top; break;
        case DOT_PRODUCT: --top; top[-1] = make_float3(1, 1, 1) * dot(top[-1], *top); break;
    }
    return {normalize(stack[0]), stack[1], stack[2].x, stack[3].x, stack[4], stack[5].x, stack[6].x};
}
// Of a triangle at its barycentrics
__device__ Surface shade(const Scene& scene, unsigned triangle, float s, float t, float3 normal) {
    const float2* uv = scene.uvs + 3 * triangle;
    const float3* vertex = scene.vertices + 3 * triangle;
    return shade(scene, scene.materials[triangle].program, normal,
        normalMapTBN(vertex[0], vertex[1], vertex[2], uv[0], uv[1], uv[2], normal),
        uv[0].x + (uv[1].x - uv[0].x) * s + (uv[2].x - uv[0].x) * t,
        uv[0].y + (uv[1].y - uv[0].y) * s + (uv[2].y - uv[0].y) * t);
}
__device__ bool neeDecision(const Surface& material, float n_dot_v, float eta_i, float eta_o) {
    // Calculate fresnel term
    const float3 F_n = mix(make_float3(1.0f, 1.0f, 1.0f) * fresnel(fabsf(n_dot_v), eta_i, eta_o), material.albedo,
        material.metallic);
    const float F_n_greyscale = rgb_to_greyscale(F_n);
    const float diffuse_factor_estimate = fmaxf((1.0f - F_n_greyscale) * (1.0f - material.metallic)
        * (1.0f - material.transparency), 0.0f);
    return diffuse_factor_estimate > 0.04f || material.roughness > 0.2f;
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

constexpr unsigned LOBE_DIFFUSE = 0u;
constexpr unsigned LOBE_REFRACT = 1u;

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

struct Lobe {
    float3 f_cos;
    float pdf;
};

struct Selection {
    Reservoir r;
    float w_sum;
    float3 color;
    unsigned random_state;
};

__device__ unsigned stream(unsigned seed, unsigned index) {
    return hash(seed ^ hash(index));
}

__device__ unsigned extractBits(unsigned path, unsigned offset, unsigned count) {
    return path >> offset & ((1u << count) - 1u);
}

// Nearest hit of a ray within far and its distance, NONE on a miss
__device__ Hit traverse(const Scene& scene, float3 origin, float3 direction, float far, float& distance) {
    // Traverse only; hit data is read from the hit object below.
    optixTraverse(scene.handle, origin, direction, 1e-4f, far, 0.0f, 255, OPTIX_RAY_FLAG_NONE, 0, 1, 0);
    if (!optixHitObjectIsHit()) return {NONE};
    distance = optixHitObjectGetRayTmax();
    // Barycentrics from the first two attributes; optixHitObjectGetTriangleBarycentrics returns zeros here.
    return {optixHitObjectGetPrimitiveIndex(), make_float2(__uint_as_float(optixHitObjectGetAttribute_0()),
        __uint_as_float(optixHitObjectGetAttribute_1()))};
}

__device__ float3 hitPosition(const Scene& scene, Hit hit) {
    const float3* vertices = scene.vertices + 3 * hit.triangle;
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

// Whether a direction leaves a face to the other side than reflecting or refracting the incoming direction does
__device__ bool wrongSide(float3 in_dir, bool refracted, float3 out_dir, float3 face) {
    return (dot(in_dir, face) < 0 != refracted) != (dot(out_dir, face) > 0);
}

// Camera and primary hit of the ray through a pixel at the jitter its sample's seed draws, which makes the pixel's area
// part of the sample's primary sample space; hidden surfaces let camera rays through. On a miss x1 is one along the ray.
__device__ Domain pixelDomain(const Scene& scene, const Camera& camera, int pixel, uint3 size, unsigned seed) {
    unsigned state = stream(seed, STREAM_JITTER);
    const float x = pixel % size.x + random(state);
    const float y = pixel / size.x + random(state);
    const float3 direction = normalize(camera.x * (2 * x / size.x - 1) + camera.y * (1 - 2 * y / size.y) + camera.z);
    float3 origin = camera.origin;
    Hit hit;
    do {
        float distance = 0;
        hit = traverse(scene, origin, direction, 1e16f, distance);
        origin = origin + direction * distance;
    } while (hit.triangle != NONE && scene.materials[hit.triangle].hidden);
    return {camera.origin, hit.triangle == NONE ? camera.origin + direction : hitPosition(scene, hit), hit};
}

// World: equirectangular texture along the direction
__device__ float3 environment(const Scene& scene, float3 direction) {
    return shade(scene, scene.materials[scene.count].program, direction, Matrix{},
        0.5f - atan2f(direction.y, direction.x) / (2 * PI),
        0.5f + atan2f(direction.z, sqrtf(direction.x * direction.x + direction.y * direction.y)) / PI).emissive;
}

// Light sampling: a triangle picked by emitted power, a uniform point on it, counted if visible from in front of the
// normal, from offset along it. Returns emission * the light's cosine / distance^2 / pdf arriving along direction,
// pdf = power share / area and power = 2 * area * emitted.
__device__ float3 sampleLight(const Scene& scene, float3 origin, float3 normal, float offset, unsigned state,
    float3& direction) {
    // The first triangle whose cumulative power exceeds the pick, below the total: never one of no power
    const double total = scene.power[scene.count - 1];
    const double pick = random53(state) * total;
    unsigned light = 0;
    for (unsigned last = scene.count - 1; light < last;) {
        const unsigned middle = (light + last) / 2;
        if (scene.power[middle] <= pick) light = middle + 1; else last = middle;
    }
    const float3 la = scene.vertices[3 * light];
    const float3 lb = scene.vertices[3 * light + 1];
    const float3 lc = scene.vertices[3 * light + 2];
    const float3 lightNormal = cross(lb - la, lc - la);
    const float side = sqrtf(random(state));
    const float along = random(state);
    const float emitted = scene.materials[light].emitted;
    const float3 toLight = la * (1 - side) + lb * (side * (1 - along)) + lc * (side * along) - origin;
    const float distance = length(toLight);
    // Visibility along the segment from the offset start to the sampled point
    const float3 shadow = toLight - normal * offset;
    float occluder;
    direction = toLight * (1 / distance);
    if (!(emitted > 0 && dot(normal, toLight) > 0) || traverse(scene, origin + normal * offset, normalize(shadow),
            length(shadow) * (1 - 1e-4f), occluder).triangle != NONE)
        return make_float3(0, 0, 0);
    return shade(scene, light, side * (1 - along), side * along, lightNormal).emissive
        * (float(total) / (2 * emitted) * fabsf(dot(lightNormal, toLight))
        / (distance * distance * distance * length(lightNormal)));
}

__device__ float3 safeDivide(float3 a, float3 b) {
    return make_float3(b.x == 0.0f ? 0.0f : a.x / b.x, b.y == 0.0f ? 0.0f : a.y / b.y, b.z == 0.0f ? 0.0f : a.z / b.z);
}

// BSDF times cosine and solid angle density of sampleBSDF choosing lobe and producing out_dir.
// Both are the ones sampleBSDF's throughput implies, delta lobes have no density and evaluate to zero.
__device__ Lobe evalLobe(float3 in_dir, float3 out_dir, float3 n, const Surface& material, float eta_i, float eta_o,
    unsigned lobe, unsigned random_state) {
    const Lobe none = Lobe{make_float3(0.0f, 0.0f, 0.0f), 0.0f};
    const float3 v = - in_dir;
    const float3 n_i = n * sign(dot(n, v));
    const float n_i_dot_v = fabsf(dot(n, v));
    const float alpha = material.roughness * material.roughness;
    float3 h = normalize(v + out_dir);
    if (lobe == LOBE_DIFFUSE) {
        // The visible normal only steers the lobe choice of diffuse samples
        const Random random_h_1 = pcg(random_state);
        const Random random_h_2 = pcg(random_h_1.state);
        h = tangentToWorld(xzy(sampleGGXVNDF(xzy(worldToTangent(v, n_i)), alpha, random_h_1.value, random_h_2.value)),
            n_i);
    } else if (lobe == LOBE_REFRACT) {
        // Refraction without index change passes straight through
        if (eta_i == eta_o) {
            return none;
        }
        const float3 h_t = - (eta_i * v + eta_o * out_dir);
        h = normalize(h_t) * sign(dot(h_t, n_i));
    }
    const float v_dot_h = dot(v, h);
    const float l_dot_h = dot(out_dir, h);
    const float n_dot_l = dot(n_i, out_dir);
    const float n_dot_h = dot(n_i, h);
    const float3 F = mix(make_float3(1.0f, 1.0f, 1.0f) * fresnel(fabsf(v_dot_h), eta_i, eta_o), material.albedo,
        material.metallic);
    const float F_greyscale = rgb_to_greyscale(F);
    const float eta = eta_i / eta_o;
    const float refractable = 1.0f - eta * eta * (1.0f - v_dot_h * v_dot_h) >= 0.0f ? 1.0f : 0.0f;
    const float diffuse_weight = (1.0f - material.transparency) * (1.0f - material.metallic);
    // Lobe probabilities as sampleBSDF uses them and the chance its random number lands in each lobe
    const float components[3] = {fmaxf(diffuse_weight * (1.0f - F_greyscale), 0.0f),
        fmaxf(material.transparency * (1.0f - F_greyscale) * refractable, 0.0f), fmaxf(F_greyscale, 0.0f)};
    const float total = fmaxf(components[0] + components[1] + components[2], BIAS);
    const float p[3] = {components[0] / total, components[1] / total, components[2] / total};
    const float cdf[2] = {fminf(p[0], 1.0f), fminf(p[0] + p[1], 1.0f)};
    const float chance[3] = {cdf[0], cdf[1] - cdf[0], 1.0f - cdf[1]};
    if (chance[lobe] <= 0.0f || p[lobe] <= 0.0f || n_i_dot_v <= 0.0f) {
        return none;
    }
    if (lobe == LOBE_DIFFUSE) {
        const float pdf = chance[0] * fmaxf(n_dot_l, 0.0f) * INV_PI;
        return Lobe{pdf * diffuse_weight * material.albedo / p[0] * (1.0f - rgb_to_greyscale(mix(make_float3(1.0f, 1.0f,
            1.0f) * fresnel(fabsf(dot(v, normalize(v + out_dir))), eta_i, eta_o), material.albedo, material.metallic))),
            pdf};
    }
    if (alpha == 0.0f || v_dot_h <= 0.0f || n_dot_h <= 0.0f) {
        return none;
    }
    // Visible normal density of the unclamped GGX distribution
    const float d_term = n_dot_h * n_dot_h * (alpha * alpha - 1.0f) + 1.0f;
    const float pdf_h = smithG1(alpha, n_i_dot_v) * v_dot_h * alpha * alpha / (PI * d_term * d_term * n_i_dot_v);
    if (lobe == LOBE_REFRACT) {
        if (l_dot_h >= 0.0f) {
            return none;
        }
        const float denom = eta_i * v_dot_h + eta_o * l_dot_h;
        const float pdf = chance[1] * pdf_h * eta_o * eta_o * fabsf(l_dot_h) / (denom * denom);
        return Lobe{make_float3(1.0f, 1.0f, 1.0f)
            * (pdf * material.transparency * G1(alpha, fmaxf(- n_dot_l, 0.0f)) * (1.0f - F_greyscale) / p[1]), pdf};
    }
    const float pdf = chance[2] * pdf_h / (4.0f * v_dot_h);
    return Lobe{pdf * G1(alpha, fmaxf(n_dot_l, 0.0f))
        * mix(F, make_float3(F_greyscale, F_greyscale, F_greyscale), material.transparency) / p[2], pdf};
}

// Weighted reservoir sampling step, weight is the vector-valued resampling weight (Sec. 6.3)
__device__ void offer(Selection& sel, const Reservoir& candidate, float3 weight) {
    const float w = rgb_to_greyscale(weight);
    // Also rejects NaN and infinite weights of degenerate samples
    if (!(w > 0.0f && w < 3.0e38f)) {
        return;
    }
    sel.w_sum += w;
    sel.color = sel.color + weight;
    if (random(sel.random_state) * sel.w_sum <= w) {
        sel.r = candidate;
    }
}

// Resample a shifted sample with MIS weight mis, keeping its Jacobian for later shifts
__device__ void offerShifted(Selection& sel, const Reservoir& r, Shift shifted, float mis) {
    Reservoir candidate = r;
    candidate.f = shifted.f / shifted.jac;
    candidate.jac = r.jac * shifted.jac;
    offer(sel, candidate, mis * shifted.f * r.w);
}

__device__ Reservoir finalize(const Selection& sel, float c) {
    Reservoir r = sel.r;
    const float p_hat = rgb_to_greyscale(r.f);
    r.w = p_hat > 0.0f ? sel.w_sum / p_hat : 0.0f;
    r.c = c;
    return r;
}

__device__ Reservoir withEnd(const Reservoir& r, unsigned end_type, unsigned end, float3 f) {
    Reservoir candidate = r;
    candidate.path = r.path | end << PATH_END | end_type << PATH_TYPE;
    candidate.f = f;
    return candidate;
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
    float threshold = 0.0f;
    float3 reconnection = origin;
    Vertex prev = Vertex{false, 0u, 0.0f, 0.0f};
    // Template for generated paths reconnecting at the first vertex meeting both footprint criteria
    Reservoir chain = {};
    chain.seed = r.seed;
    float3 chain_throughput = make_float3(0.0f, 0.0f, 0.0f);
    for (unsigned b = 0u; ; b++) {
        const float3 face = faceNormal(scene, hit.triangle);
        Surface surface = shade(scene, hit.triangle, hit.uv.x, hit.uv.y, smoothNormal(scene, hit));
        // Surfaces transmitting nothing face the ray, as in Cycles
        const float facing = surface.transparency > 0 || dot(face, direction) < 0 ? 1.0f : -1.0f;
        const float3 geometry_n = face * facing;
        surface.normal = surface.normal * facing;
        const float offset = geometryOffset(scene, hit, geometry_n, origin);
        const float geometry_density = fabsf(dot(geometry_n, direction)) / (distance * distance);
        if (b == 0u) {
            // Primary ray footprint (Eq. 5)
            threshold = RESTIR_FOOTPRINT / geometry_density;
            seen = surface.emissive;
        }
        // Ray footprint criterion for reconnecting from the previous vertex to this one (Eq. 5)
        const bool footprint = prev.rough && prev.pdf * geometry_density * threshold <= 1.0f;
        const float n_dot_v = dot(surface.normal, - direction);
        const bool is_entering = n_dot_v < 0.0f;
        // Incident side is air, outgoing side is material (entering)
        const float eta_i = is_entering ? surface.ior : 1.0f;
        // Incident side is material, outgoing side is air (exiting)
        const float eta_o = is_entering ? 1.0f : surface.ior;
        const bool nee = neeDecision(surface, n_dot_v, eta_i, eta_o);
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
                if (!direct_light_emission) {
                    return fail;
                }
                return Shift{throughput * surface.emissive / r.jac, density / r.jac};
            }
            if (k == end && end_type == END_NEE) {
                if (!nee) {
                    return fail;
                }
                return Shift{throughput * BSDF(direction, r.dir, surface.normal, geometry_n, surface, eta_i, eta_o,
                    make_float2(0, 0)) * r.radiance / r.jac, density / r.jac};
            }
            if (nee != (extractBits(r.path, PATH_NEE, 1u) == 1u)) {
                return fail;
            }
        } else if (replay && b == stop && rc != RC_SURFACE && rc != RC_ENV) {
            if (rc == RC_LIGHT && nee && !footprint) {
                // Forced reconnection to the light vertex of next event estimation (Sec. 6.2.3), the point its replayed
                // random numbers pick again (unit Jacobian)
                float3 light_dir;
                const float3 radiance = sampleLight(scene, origin, surface.normal, offset,
                    stream(r.seed, b + STREAM_NEE), light_dir);
                return rgb_to_greyscale(radiance) > 0.0f ? Shift{throughput * BSDF(direction, light_dir, surface.normal,
                    geometry_n, surface, eta_i, eta_o, make_float2(0, 0)) * radiance, 1.0f} : fail;
            }
            // Emission seen right after a vertex that skipped next event estimation
            if (rc == RC_NONE && end_type == END_EMIT && direct_light_emission && !footprint) {
                return Shift{throughput * surface.emissive, 1.0f};
            }
            return fail;
        } else if (!replay) {
            // Emission seen directly carries no randomness to resample, shading adds it
            if (direct_light_emission && b > 0u) {
                Reservoir candidate = chain;
                if (chain_found) {
                    candidate.radiance = safeDivide(throughput * surface.emissive, chain_throughput);
                } else if (footprint) {
                    candidate = here;
                }
                offer(sel, withEnd(candidate, END_EMIT, b, throughput * surface.emissive),
                    throughput * surface.emissive * scale / density);
            }
            if (nee) {
                float3 light_dir;
                const float3 radiance = sampleLight(scene, origin, surface.normal, offset,
                    stream(r.seed, b + STREAM_NEE), light_dir);
                const float3 f = rgb_to_greyscale(radiance) > 0.0f ? throughput * BSDF(direction, light_dir,
                    surface.normal, geometry_n, surface, eta_i, eta_o, make_float2(0, 0)) * radiance : fail.f;
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
                offer(sel, withEnd(candidate, END_NEE, b, f), f * scale / density);
            }
        }
        direct_light_emission = !nee;
        // Replaying, x_k-1 connects to the reconnection vertex and x_k leaves along the stored direction with the stored lobes
        const bool connect = replay && b == stop;
        unsigned lobe_index = extractBits(r.path, arrived ? PATH_LOBE : PATH_LOBE_PREV, 2u);
        float3 dir = r.dir;
        float3 sample_throughput = make_float3(0.0f, 0.0f, 0.0f);
        // Density of the direction leaving this vertex
        Lobe lobe = Lobe{make_float3(0.0f, 0.0f, 0.0f), 0.0f};
        if (connect) {
            if (rc == RC_SURFACE) {
                reconnection = hitPosition(scene, r.rc);
                dir = normalize(reconnection - (origin
                    + surface.normal * (offset * sign(dot(reconnection - origin, geometry_n)))));
            }
            // The path tracer would resample such a direction against the geometry normal
            if (wrongSide(direction, lobe_index == LOBE_REFRACT, dir, geometry_n)) {
                return fail;
            }
        } else if (!arrived) {
            SampleBSDF bsdf_sampled = sampleBSDF(direction, surface.normal, surface, eta_i, eta_o,
                stream(r.seed, b), make_float2(0, 0));
            // Continue sampling with the face normal if the smooth normal sent the ray to the wrong side of the face,
            // pretending the self reflection faces along it
            const bool fallback = wrongSide(direction, bsdf_sampled.refracted, bsdf_sampled.unit_direction, geometry_n);
            if (fallback) {
                const SampleBSDF geometry_bsdf_sampled = sampleBSDF(bsdf_sampled.unit_direction, geometry_n, surface,
                    eta_i, eta_o, bsdf_sampled.random_state, make_float2(0, 0));
                bsdf_sampled.unit_direction = geometry_bsdf_sampled.unit_direction;
                bsdf_sampled.throughput = geometry_bsdf_sampled.throughput;
            }
            lobe_index = bsdf_sampled.lobe;
            dir = bsdf_sampled.unit_direction;
            sample_throughput = bsdf_sampled.throughput;
            // Density of the direction is unknown after the fallback
            lobe.pdf = fallback ? 0.0f : bsdf_sampled.pdf;
        }
        // Connections evaluate the given direction
        if (connect || arrived) {
            lobe = evalLobe(direction, dir, surface.normal, surface, eta_i, eta_o, lobe_index, stream(r.seed, b));
        }
        // Inverse ray footprint criterion for the density of the direction leaving this vertex (Eq. 5)
        const bool inverse_footprint = lobe.pdf > 0.0f
            && (lobe_index == LOBE_DIFFUSE || lobe.pdf * prev.cos / (distance * distance) * threshold <= 1.0f);
        const bool rough = lobe.pdf > 0.0f && (lobe_index == LOBE_DIFFUSE || surface.roughness >= RESTIR_ROUGHNESS);
        if (arrived) {
            if (!inverse_footprint) {
                return fail;
            }
            return Shift{throughput * lobe.f_cos * r.radiance / r.jac, density * lobe.pdf / r.jac};
        }
        // A replayed path meeting the criteria before x_k is not in the image of the shift
        if ((replay && footprint && inverse_footprint) || (connect && !rough)) {
            return fail;
        }
        if (connect) {
            throughput = throughput * lobe.f_cos;
            density = lobe.pdf;
        } else {
            throughput = throughput * make_float3(fmaxf(sample_throughput.x, 0.0f), fmaxf(sample_throughput.y, 0.0f),
                fmaxf(sample_throughput.z, 0.0f));
        }
        if (!replay && !chain_found && footprint && inverse_footprint) {
            chain = here;
            chain.path |= lobe_index << PATH_LOBE | (nee ? 1u : 0u) << PATH_NEE;
            chain.jac *= lobe.pdf;
            chain.dir = dir;
            chain_throughput = throughput;
        }
        prev = Vertex{rough, lobe_index, lobe.pdf, fabsf(dot(geometry_n, dir))};
        direction = dir;
        // Off the side it leaves through
        origin = origin + surface.normal * (offset * sign(dot(direction, geometry_n)));
        if (!replay) {
            const float survival_probability = fminf(fmaxf(fmaxf(throughput.x, fmaxf(throughput.y, throughput.z))
                / density, 0.0f), 1.0f);
            if (survival_probability < pcg(stream(r.seed, b + STREAM_RR)).value || b >= scene.settings.bounces) {
                break;
            }
            density *= survival_probability;
        }
        // Only occluders in front of the reconnection vertex matter
        const bool reconnecting = replay && b == stop && rc == RC_SURFACE;
        hit = traverse(scene, origin, direction, reconnecting ? length(reconnection - origin) * 1.001f : 1e16f,
            distance);
        // Reaching the reconnection vertex, it is shaded exactly where the stored path has it
        if (reconnecting && hit.triangle == r.rc.triangle) {
            hit.uv = r.rc.uv;
            distance = length(reconnection - origin);
        }
        // The connection to the environment direction has to escape the scene
        if (replay && b == stop && rc == RC_ENV && hit.triangle != NONE) {
            return fail;
        }
        if (hit.triangle == NONE) {
            const float3 f = throughput * environment(scene, direction);
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
            offer(sel, withEnd(candidate, END_ENV, b, f), f * scale / density);
            break;
        }
        // Project ray origin to hit point
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
        seen = seen + (dom.hit.triangle == NONE ? environment(scene, normalize(dom.x1 - dom.x0)) : first)
            / scene.settings.paths;
    }
    scene.initial[index] = finalize(initial, 1.0f);
    const float3 radiance = scene.settings.restir ? seen : seen + initial.color;
    float4& sum = scene.accumulation[index];
    sum = make_float4(sum.x + radiance.x, sum.y + radiance.y, sum.z + radiance.z, sum.w + 1);
}

// Temporal reuse: the initial sample against the one the previous frame left the pixel's temporal neighbor, which is
// the pixel itself under a still camera, where both shifts are the identity
extern "C" __global__ void __raygen__temporal() {
    const uint3 p = optixGetLaunchIndex();
    const uint3 size = optixGetLaunchDimensions();
    const unsigned index = p.y * size.x + p.x;
    const Scene& scene = *(Scene*)optixGetSbtDataPointer();
    Reservoir r = scene.initial[index];
    const bool still = scene.camera.origin == scene.previousCamera.origin && scene.camera.x == scene.previousCamera.x
        && scene.camera.y == scene.previousCamera.y && scene.camera.z == scene.previousCamera.z;
    int q = scene.previous[index].c > 0.0f ? int(index) : -1;
    if (!still) {
        const Domain dom = pixelDomain(scene, scene.camera, index, size, r.seed);
        q = dom.hit.triangle == NONE ? -1 : temporalNeighbor(scene, p, size, dom);
    }
    if (q >= 0) {
        const Reservoir temporal = scene.previous[q];
        // Optionally lower the confidence cap where the previous frame duplicated samples (Sec. 5), this biases the estimate
        const float duplicated = scene.settings.decorrelation ? scene.duplication[q] : 0.0f;
        const float cap = RESTIR_CAP + (RESTIR_CAP_MIN - RESTIR_CAP) * powf(duplicated, RESTIR_DUPLICATION_ALPHA);
        const float c_t = fminf(temporal.c, cap);
        const Shift to_current = still ? Shift{temporal.f, 1.0f} : shift(scene, scene.camera, index, size, temporal);
        const Shift to_previous = still ? Shift{r.f, 1.0f} : shift(scene, scene.previousCamera, q, size, r);
        const float p_c = rgb_to_greyscale(r.f);
        const float p_t = rgb_to_greyscale(temporal.f);
        Selection sel = {};
        sel.random_state = stream(r.seed, STREAM_SELECT + 1u);
        offerShifted(sel, r, Shift{r.f, 1.0f}, r.c * p_c / (r.c * p_c + c_t * rgb_to_greyscale(to_previous.f)));
        offerShifted(sel, temporal, to_current, c_t * p_t / (c_t * p_t + r.c * rgb_to_greyscale(to_current.f)));
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
            offerShifted(sel, neighbor, to_here,
                share * neighbor.c * p_n / (neighbor.c * p_n + c_pair * rgb_to_greyscale(to_here.f)));
        }
    }
    offerShifted(sel, r, Shift{r.f, 1.0f}, canonical_mis);
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
