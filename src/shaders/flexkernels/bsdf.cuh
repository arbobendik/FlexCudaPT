#pragma once
#define Matrix SlangMatrix
#include "slang-cuda-prelude.h"
#undef Matrix

static __device__ float dot_0(float3  x_0, float3  y_0)
{
    return x_0.x * y_0.x + x_0.y * y_0.y + x_0.z * y_0.z;
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S1 = left_0.y;
    float _S2 = right_0.z;
    float _S3 = left_0.z;
    float _S4 = right_0.y;
    float _S5 = right_0.x;
    float _S6 = left_0.x;
    return make_float3 (_S1 * _S2 - _S3 * _S4, _S3 * _S5 - _S6 * _S2, _S6 * _S4 - _S1 * _S5);
}

__device__ float smithG1(float alpha_0, float n_dot_x_0)
{
    float alpha_sq_0 = alpha_0 * alpha_0;
    return 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((alpha_sq_0 + (1.0f - alpha_sq_0) * n_dot_x_0 * n_dot_x_0))));
}

__device__ float trowbridgeReitz(float alpha_1, float n_dot_h_0)
{
    float numerator_0 = alpha_1 * alpha_1;
    float denom_0 = n_dot_h_0 * n_dot_h_0 * (numerator_0 - 1.0f) + 1.0f;
    return numerator_0 / (F32_max((3.14159274101257324f * denom_0 * denom_0), (0.0000152587890625f)));
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float sin_psi_0 = eta_i_0 / eta_o_0 * (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float kr_0;
    if(sin_psi_0 < 1.0f)
    {
        float cos_psi_0 = (F32_sqrt(((F32_max((0.0f), (1.0f - sin_psi_0 * sin_psi_0))))));
        float _S7 = eta_o_0 * cos_theta_0;
        float _S8 = eta_i_0 * cos_psi_0;
        float Rs_0 = (_S7 - _S8) / (_S7 + _S8);
        float _S9 = eta_i_0 * cos_theta_0;
        float _S10 = eta_o_0 * cos_psi_0;
        float Rp_0 = (_S9 - _S10) / (_S9 + _S10);
        kr_0 = (Rs_0 * Rs_0 + Rp_0 * Rp_0) / 2.0f;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_2, float U1_0, float U2_0)
{
    float3  _S11 = make_float3 (alpha_2 * Ve_0.x, alpha_2 * Ve_0.y, Ve_0.z);
    float3  Vh_0 = ((((_S11)) * make_float3(rnorm3df(((_S11)).x, ((_S11)).y, ((_S11)).z))));
    float _S12 = Vh_0.x;
    float _S13 = Vh_0.y;
    float lensq_0 = _S12 * _S12 + _S13 * _S13;
    float3  T1_0;
    if(lensq_0 > 0.0f)
    {
        float3  _S14 = make_float3 (- _S13, _S12, 0.0f);
        float _S15 = (rsqrtf((lensq_0)));
        T1_0 = _S14 * make_float3 (_S15);
    }
    else
    {
        T1_0 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float r_0 = (F32_sqrt((U1_0)));
    float phi_0 = 6.28318548202514648f * U2_0;
    float t1_0 = r_0 * (F32_cos((phi_0)));
    float s_0 = 0.5f * (1.0f + Vh_0.z);
    float _S16 = 1.0f - t1_0 * t1_0;
    float t2_0 = s_0 * (r_0 * (F32_sin((phi_0)))) + (1.0f - s_0) * (F32_sqrt(((F32_max((0.0f), (_S16))))));
    float3  Nh_0 = make_float3 (t1_0) * T1_0 + make_float3 (t2_0) * cross_0(Vh_0, T1_0) + make_float3 ((F32_sqrt(((F32_max((0.0f), (_S16 - t2_0 * t2_0))))))) * Vh_0;
    float3  _S17 = make_float3 (alpha_2 * Nh_0.x, alpha_2 * Nh_0.y, (F32_max((0.0f), (Nh_0.z))));
    float3  _S18 = ((((_S17)) * make_float3(rnorm3df(((_S17)).x, ((_S17)).y, ((_S17)).z))));
    return _S18;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float r_1 = (F32_sqrt((random_1_0)));
    float theta_0 = 6.28318548202514648f * random_2_0;
    float x_1 = r_1 * (F32_cos((theta_0)));
    float z_0 = r_1 * (F32_sin((theta_0)));
    return make_float3 (x_1, (F32_sqrt(((F32_max((0.0f), (1.0f - x_1 * x_1 - z_0 * z_0)))))), z_0);
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_0)
{
    float3  a_0 = make_float3 (0.0f, 1.0f, 0.0f);
    float3  a_1;
    if((F32_abs((dot_0(n_0, a_0)))) > 0.9999847412109375f)
    {
        a_1 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    else
    {
        a_1 = a_0;
    }
    float3  _S19 = cross_0(n_0, a_1);
    float3  tangent_0 = ((((_S19)) * make_float3(rnorm3df(((_S19)).x, ((_S19)).y, ((_S19)).z))));
    return make_float3 (v_0.x) * tangent_0 + make_float3 (v_0.y) * n_0 + make_float3 (v_0.z) * cross_0(n_0, tangent_0);
}

__device__ float3  worldToTangent(float3  v_1, float3  n_1)
{
    float3  a_2 = make_float3 (0.0f, 1.0f, 0.0f);
    float3  a_3;
    if((F32_abs((dot_0(n_1, a_2)))) > 0.9999847412109375f)
    {
        a_3 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    else
    {
        a_3 = a_2;
    }
    float3  _S20 = cross_0(n_1, a_3);
    float3  tangent_1 = ((((_S20)) * make_float3(rnorm3df(((_S20)).x, ((_S20)).y, ((_S20)).z))));
    return make_float3 (dot_0(v_1, tangent_1), dot_0(v_1, n_1), dot_0(v_1, cross_0(n_1, tangent_1)));
}

__device__ uint hash(uint x_2)
{
    uint _S21 = x_2 * 747796405U + 2891336453U;
    uint _S22 = ((_S21 >> ((_S21 >> int(28)) + 4U)) ^ _S21) * 277803737U;
    return (_S22 >> int(22)) ^ _S22;
}

struct Random
{
    uint state;
    float value;
};

static __device__ Random Random_x24init_0(uint state_0, float value_0)
{
    Random _S23;
    (&_S23)->state = state_0;
    (&_S23)->value = value_0;
    return _S23;
}

__device__ Random pcg(uint state_1)
{
    uint next_0 = hash(state_1);
    return Random_x24init_0(next_0, float(next_0 >> int(8)) * 5.9604644775390625e-08f);
}

__device__ float3  sampleHalfVector(float3  v_2, float3  n_i_0, float alpha_3, uint * random_state_0)
{
    Random random_h_1_0 = pcg(*random_state_0);
    Random random_h_2_0 = pcg(random_h_1_0.state);
    *random_state_0 = random_h_2_0.state;
    float3  v_tangent_0 = worldToTangent(v_2, n_i_0);
    float3  _S24 = sampleGGXVNDF(float3 {v_tangent_0.x, v_tangent_0.z, v_tangent_0.y}, alpha_3, random_h_1_0.value, random_h_2_0.value);
    float3  _S25 = tangentToWorld(float3 {_S24.x, _S24.z, _S24.y}, n_i_0);
    return _S25;
}

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float _S26 = b_0.x;
    float _S27;
    if(_S26 == 0.0f)
    {
        _S27 = 0.0f;
    }
    else
    {
        _S27 = a_4.x / _S26;
    }
    float _S28 = b_0.y;
    float _S29;
    if(_S28 == 0.0f)
    {
        _S29 = 0.0f;
    }
    else
    {
        _S29 = a_4.y / _S28;
    }
    float _S30 = b_0.z;
    float _S31;
    if(_S30 == 0.0f)
    {
        _S31 = 0.0f;
    }
    else
    {
        _S31 = a_4.z / _S30;
    }
    return make_float3 (_S27, _S29, _S31);
}

__device__ uint stream(uint seed_0, uint index_0)
{
    return hash(seed_0 ^ (hash(index_0)));
}

__device__ Random normal_distribution(uint state_2)
{
    Random r1_0 = pcg(state_2);
    Random r2_0 = pcg(r1_0.state);
    return Random_x24init_0(r2_0.state, (F32_sqrt((-2.0f * (F32_min(((F32_max(((F32_log((r2_0.value)))), (-8.388607e+06f)))), (0.0f)))))) * (F32_cos((6.28318548202514648f * r1_0.value))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_3, float3  value_1)
{
    RandomSphere _S32;
    (&_S32)->state = state_3;
    (&_S32)->value = value_1;
    return _S32;
}

__device__ RandomSphere random_sphere(uint state_4)
{
    Random x_3 = normal_distribution(state_4);
    Random y_1 = normal_distribution(x_3.state);
    Random z_1 = normal_distribution(y_1.state);
    float3  _S33 = make_float3 (x_3.value, y_1.value, z_1.value);
    float3  _S34 = ((((_S33)) * make_float3(rnorm3df(((_S33)).x, ((_S33)).y, ((_S33)).z))));
    return RandomSphere_x24init_0(z_1.state, _S34);
}

struct RandomHemisphere
{
    uint state;
    float3  value;
};

static __device__ RandomHemisphere RandomHemisphere_x24init_0(uint state_5, float3  value_2)
{
    RandomHemisphere _S35;
    (&_S35)->state = state_5;
    (&_S35)->value = value_2;
    return _S35;
}

__device__ RandomHemisphere random_hemisphere(uint state_6, float3  normal_0)
{
    RandomSphere random_sphere_0 = random_sphere(state_6);
    if((dot_0(random_sphere_0.value, normal_0)) > 0.0f)
    {
        return RandomHemisphere_x24init_0(random_sphere_0.state, random_sphere_0.value);
    }
    else
    {
        return RandomHemisphere_x24init_0(random_sphere_0.state, - random_sphere_0.value);
    }
}

