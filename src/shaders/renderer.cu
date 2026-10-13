#include "renderer.h"
#include <optix.h>
#include <cuda_runtime.h>

constexpr int MAX_BOUNCES = 8;
constexpr int STACK = 64;
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
    // Handedness: ensure TBN is right-handed; flip T if geometric b disagrees with cross(n,t).
    if (dot(cross(n, t), b_geom) > 0.0f) {
        t = -t;
    }
    const float3 b = cross(n, t);

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

// Surface a program resolves to at a UV, facing along the normal
__device__ Surface shade(const Scene& scene, unsigned program, float3 normal, float u, float v) {
    float3 stack[STACK], *top = stack;
    for (const Op* op = scene.ops + program; op->code; ++op) switch (op->code) {
        case PUSH: *top++ = op->value; break;
        case UV: *top++ = make_float3(u, v, 0); break;
        case NORMAL: *top++ = normal; break;
        case IMAGE: case ALPHA: { // Repeating
            const uchar4 texel = scene.texels[op->texel + unsigned(wrap(top[-1].y) * op->height) * op->width
                + unsigned(wrap(top[-1].x) * op->width)];
            top[-1] = op->code == IMAGE ? decode(texel) : make_float3(1, 1, 1) * decode(texel.w);
        } break;
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
    return shade(scene, scene.materials[triangle].program, normal,
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
extern "C" __global__ void __raygen__camera() {
    const uint3 p = optixGetLaunchIndex();
    const uint3 size = optixGetLaunchDimensions();
    const unsigned index = p.y * size.x + p.x;
    const Scene& scene = *(Scene*)optixGetSbtDataPointer();
    float4& sum = scene.accumulation[index];
    unsigned state = hash(index + hash((unsigned)sum.w));
    float3 origin = scene.camera.origin;
    float3 radiance = make_float3(0, 0, 0);
    float3 throughput = make_float3(1, 1, 1);
    bool direct_light_emission = true;
    float3 direction = normalize(scene.camera.x * (2 * (p.x + random(state)) / size.x - 1)
                               + scene.camera.y * (1 - 2 * (p.y + random(state)) / size.y) + scene.camera.z);
    for (int bounce = 0; bounce < MAX_BOUNCES; ++bounce) {
        // Traverse only; hit data is read from the hit object below.
        optixTraverse(scene.handle, origin, direction, 1e-4f, 1e16f, 0.0f, 255, OPTIX_RAY_FLAG_NONE, 0, 1, 0);
        if (!optixHitObjectIsHit()) { // World: equirectangular texture along the direction
            const Material world = scene.materials[scene.count];
            radiance = radiance + throughput * shade(scene, world.program, direction,
                0.5f - atan2f(direction.y, direction.x) / (2 * PI),
                0.5f + atan2f(direction.z, sqrtf(direction.x * direction.x + direction.y * direction.y)) / PI).emissive;
            break;
        }
        // Bounce data: position, face normal, material.
        const unsigned i = optixHitObjectGetPrimitiveIndex();
        const float3 a = scene.vertices[3 * i];
        const float3 b = scene.vertices[3 * i + 1];
        const float3 c = scene.vertices[3 * i + 2];
        float3 normal = normalize(cross(b - a, c - a));
        origin = origin + direction * optixHitObjectGetRayTmax();
        const Material material = scene.materials[i];
        if (bounce == 0 && material.hidden) {
            --bounce;
            continue;
        }
        // Barycentrics from the first two attributes; optixHitObjectGetTriangleBarycentrics returns zeros here.
        const float s = __uint_as_float(optixHitObjectGetAttribute_0());
        const float t = __uint_as_float(optixHitObjectGetAttribute_1());
        // Emitters seen by the camera or past a surface without light sampling; others reach them through it instead.
        const Surface surface = shade(scene, i, s, t, normal);
        if (direct_light_emission) radiance = radiance + throughput * surface.emissive;
        const float n_dot_v = dot(surface.normal, - direction);
        const bool is_entering = n_dot_v < 0.0f;
        // Incident side is air, outgoing side is material (entering)
        const float eta_i = is_entering ? surface.ior : 1.0f;
        // Incident side is material, outgoing side is air (exiting)
        const float eta_o = is_entering ? 1.0f : surface.ior;
        direct_light_emission = !neeDecision(surface, n_dot_v, eta_i, eta_o);
        // Light sampling: a triangle picked by emitted power, a uniform point on it, counted if visible.
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
        const float distance = sqrtf(dot(toLight, toLight));
        const float cosine = dot(surface.normal, toLight) / distance;
        if (!direct_light_emission && emitted > 0 && cosine > 0) {
            optixTraverse(scene.handle, origin, toLight * (1 / distance), 1e-4f, distance * (1 - 1e-4f), 0.0f, 255,
                OPTIX_RAY_FLAG_NONE, 0, 1, 0);
            // BSDF with its cosine * emission * the light's cosine / distance^2 / pdf,
            // pdf = power share / area and power = 2 * area * emitted.
            if (!optixHitObjectIsHit()) radiance = radiance + throughput
                * BSDF(direction, toLight * (1 / distance), surface.normal, normal, surface, eta_i, eta_o,
                    make_float2(0, 0))
                * shade(scene, light, side * (1 - along), side * along, lightNormal).emissive
                * (float(total) / (2 * emitted) * fabsf(dot(lightNormal, toLight))
                / (distance * distance * distance * sqrtf(dot(lightNormal, lightNormal))));
        }
        // BSDF sampling: weight = f * cos / pdf.
        const SampleBSDF sampled = sampleBSDF(direction, surface.normal, surface, eta_i, eta_o, state,
            make_float2(0, 0));
        state = sampled.random_state;
        direction = sampled.unit_direction;
        throughput = throughput * make_float3(fmaxf(sampled.throughput.x, 0), fmaxf(sampled.throughput.y, 0),
            fmaxf(sampled.throughput.z, 0));
    }
    sum = make_float4(sum.x + radiance.x, sum.y + radiance.y, sum.z + radiance.z, sum.w + 1);
}
