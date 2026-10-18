#pragma once
#define Matrix SlangMatrix
#include "slang-cuda-prelude.h"

static __device__ float3  mul_0(float3  left_0, Matrix<float, 3, 3>  right_0)
{
    float3  result_0;
    int j_0 = int(0);
    for(;;)
    {
        if(j_0 < int(3))
        {
        }
        else
        {
            break;
        }
        int i_0 = int(0);
        float sum_0 = 0.0f;
        for(;;)
        {
            if(i_0 < int(3))
            {
            }
            else
            {
                break;
            }
            float sum_1 = sum_0 + _slang_vector_get_element(left_0, i_0) * _slang_vector_get_element(right_0.rows[i_0], j_0);
            i_0 = i_0 + int(1);
            sum_0 = sum_1;
        }
        *_slang_vector_get_element_ptr(&result_0, j_0) = sum_0;
        j_0 = j_0 + int(1);
    }
    return result_0;
}

static __device__ float3  cross_0(float3  left_1, float3  right_1)
{
    float _S1 = left_1.y;
    float _S2 = right_1.z;
    float _S3 = left_1.z;
    float _S4 = right_1.y;
    float _S5 = right_1.x;
    float _S6 = left_1.x;
    return make_float3 (_S1 * _S2 - _S3 * _S4, _S3 * _S5 - _S6 * _S2, _S6 * _S4 - _S1 * _S5);
}

static __device__ float clamp_0(float x_0, float minBound_0, float maxBound_0)
{
    return (F32_min(((F32_max((x_0), (minBound_0)))), (maxBound_0)));
}

static __device__ float dot_0(float3  x_1, float3  y_0)
{
    return x_1.x * y_0.x + x_1.y * y_0.y + x_1.z * y_0.z;
}

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

__device__ uint hash(uint x_2)
{
    uint _S7 = x_2 * 747796405U + 2891336453U;
    uint _S8 = ((_S7 >> ((_S7 >> 28U) + 4U)) ^ _S7) * 277803737U;
    return (_S8 >> 22U) ^ _S8;
}

struct Random
{
    uint state;
    float value;
};

static __device__ Random Random_x24init_0(uint state_0, float value_0)
{
    Random _S9;
    (&_S9)->state = state_0;
    (&_S9)->value = value_0;
    return _S9;
}

static __device__ float random_0(uint * state_1)
{
    uint _S10 = hash(*state_1);
    *state_1 = _S10;
    return float((*state_1) >> int(8)) * 5.9604644775390625e-08f;
}

__device__ Random pcg(uint state_2)
{
    uint _S11 = state_2;
    float value_1 = random_0(&_S11);
    return Random_x24init_0(_S11, value_1);
}

__device__ Random normal_distribution(uint state_3)
{
    Random _S12 = pcg(state_3);
    Random _S13 = pcg(_S12.state);
    float _S14 = 6.28318548202514648f * _S12.value;
    float _S15 = (F32_sqrt((-2.0f * clamp_0((F32_log((_S13.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S13.state, _S15 * (F32_cos((_S14))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S16;
    (&_S16)->state = state_4;
    (&_S16)->value = value_2;
    return _S16;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S17 = normal_distribution(state_5);
    Random _S18 = normal_distribution(_S17.state);
    Random _S19 = normal_distribution(_S18.state);
    float3  _S20 = make_float3 (_S17.value, _S18.value, _S19.value);
    float3  _S21 = ((((_S20)) * make_float3(rnorm3df(((_S20)).x, ((_S20)).y, ((_S20)).z))));
    return RandomSphere_x24init_0(_S19.state, _S21);
}

struct RandomHemisphere
{
    uint state;
    float3  value;
};

static __device__ RandomHemisphere RandomHemisphere_x24init_0(uint state_6, float3  value_3)
{
    RandomHemisphere _S22;
    (&_S22)->state = state_6;
    (&_S22)->value = value_3;
    return _S22;
}

static __device__ float3  negate_0(float3  x_3)
{
    return - x_3;
}

__device__ RandomHemisphere random_hemisphere(uint state_7, float3  normal_0)
{
    RandomSphere _S23 = random_sphere(state_7);
    bool _S24 = (dot_0(_S23.value, normal_0)) > 0.0f;
    if(_S24)
    {
        return RandomHemisphere_x24init_0(_S23.state, _S23.value);
    }
    else
    {
        float3  _S25 = negate_0(_S23.value);
        return RandomHemisphere_x24init_0(_S23.state, _S25);
    }
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S26 = hash(index_0);
    uint _S27 = hash(seed_0 ^ _S26);
    return _S27;
}

__device__ float trowbridgeReitz(float alpha_0, float n_dot_h_0)
{
    float _S28 = alpha_0 * alpha_0;
    float _S29 = n_dot_h_0 * n_dot_h_0 * (_S28 - 1.0f) + 1.0f;
    return _S28 / (F32_max((3.14159274101257324f * _S29 * _S29), (0.0000152587890625f)));
}

__device__ float G1(float alpha_1, float n_dot_x_0)
{
    float _S30 = alpha_1 * 0.5f;
    return n_dot_x_0 / (F32_max((n_dot_x_0 * (1.0f - _S30) + _S30), (0.0000152587890625f)));
}

__device__ float smithG1(float alpha_2, float n_dot_x_1)
{
    float _S31 = alpha_2 * alpha_2;
    return 2.0f * n_dot_x_1 / (n_dot_x_1 + (F32_sqrt((_S31 + (1.0f - _S31) * n_dot_x_1 * n_dot_x_1))));
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S32 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S33 = eta_i_0 / eta_o_0 * _S32;
    bool _S34 = _S33 < 1.0f;
    float kr_0;
    if(_S34)
    {
        float _S35 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S33 * _S33))))));
        float _S36 = eta_o_0 * cos_theta_0;
        float _S37 = eta_i_0 * _S35;
        float _S38 = (_S36 - _S37) / (_S36 + _S37);
        float _S39 = eta_i_0 * cos_theta_0;
        float _S40 = eta_o_0 * _S35;
        float _S41 = (_S39 - _S40) / (_S39 + _S40);
        float _S42 = (_S38 * _S38 + _S41 * _S41) / 2.0f;
        kr_0 = _S42;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

static __device__ float unshared_0(float x_4)
{
    return x_4;
}

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_3, float U1_0, float U2_0)
{
    float3  _S43 = make_float3 (alpha_3 * Ve_0.x, alpha_3 * Ve_0.y, Ve_0.z);
    float3  _S44 = ((((_S43)) * make_float3(rnorm3df(((_S43)).x, ((_S43)).y, ((_S43)).z))));
    float _S45 = _S44.x;
    float _S46 = _S44.y;
    float _S47 = _S45 * _S45 + _S46 * _S46;
    float3  _S48;
    if(_S47 > 0.0f)
    {
        float3  _S49 = make_float3 (- _S46, _S45, 0.0f);
        float _S50 = (rsqrtf((_S47)));
        _S48 = _S49 * make_float3 (_S50);
    }
    else
    {
        _S48 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S51 = cross_0(_S44, _S48);
    float _S52 = (F32_sqrt((U1_0)));
    float _S53 = 6.28318548202514648f * U2_0;
    float _S54 = _S52 * (F32_cos((_S53)));
    float t2_0 = _S52 * (F32_sin((_S53)));
    float _S55 = 0.5f * (1.0f + _S44.z);
    float t2_1 = (1.0f - _S55) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S54 * _S54)))))) + _S55 * t2_0;
    float3  _S56 = make_float3 (_S54) * _S48 + make_float3 (t2_1) * _S51;
    float _S57 = unshared_0(_S54);
    float _S58 = unshared_0(_S54);
    float3  _S59 = _S56 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S57 * _S58 - t2_1 * t2_1))))))) * _S44;
    float3  _S60 = make_float3 (alpha_3 * _S59.x, alpha_3 * _S59.y, (F32_max((0.0f), (_S59.z))));
    float3  _S61 = ((((_S60)) * make_float3(rnorm3df(((_S60)).x, ((_S60)).y, ((_S60)).z))));
    return _S61;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S62 = (F32_sqrt((random_1_0)));
    float _S63 = 6.28318548202514648f * random_2_0;
    float _S64 = _S62 * (F32_cos((_S63)));
    float _S65 = _S62 * (F32_sin((_S63)));
    float _S66 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S64 * _S64 - _S65 * _S65))))));
    return make_float3 (_S64, _S66, _S65);
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_0)
{
    float3  a_0 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S67 = (F32_abs((dot_0(n_0, a_0)))) > 0.9999847412109375f;
    float3  a_1;
    if(_S67)
    {
        float3  _S68 = make_float3 (1.0f, 0.0f, 0.0f);
        a_1 = _S68;
    }
    else
    {
        a_1 = a_0;
    }
    float3  _S69 = cross_0(n_0, a_1);
    float3  _S70 = ((((_S69)) * make_float3(rnorm3df(((_S69)).x, ((_S69)).y, ((_S69)).z))));
    float3  _S71 = cross_0(n_0, _S70);
    return make_float3 (v_0.x) * _S70 + make_float3 (v_0.y) * n_0 + make_float3 (v_0.z) * _S71;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_1)
{
    float3  a_2 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S72 = (F32_abs((dot_0(n_1, a_2)))) > 0.9999847412109375f;
    float3  a_3;
    if(_S72)
    {
        float3  _S73 = make_float3 (1.0f, 0.0f, 0.0f);
        a_3 = _S73;
    }
    else
    {
        a_3 = a_2;
    }
    float3  _S74 = cross_0(n_1, a_3);
    float3  _S75 = ((((_S74)) * make_float3(rnorm3df(((_S74)).x, ((_S74)).y, ((_S74)).z))));
    float3  _S76 = cross_0(n_1, _S75);
    return make_float3 (dot_0(v_1, _S75), dot_0(v_1, n_1), dot_0(v_1, _S76));
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_2)
{
    float3  _S77 = p1_0 - p0_0;
    float3  _S78 = p2_0 - p0_0;
    float2  _S79 = uv1_0 - uv0_0;
    float2  _S80 = uv2_0 - uv0_0;
    float _S81 = _S79.x;
    float _S82 = _S80.y;
    float _S83 = _S79.y;
    float _S84 = _S80.x;
    float _S85 = _S81 * _S82 - _S83 * _S84;
    float _S86 = 1.0f / _S85;
    float3  t_0 = (_S77 * make_float3 (_S82) - _S78 * make_float3 (_S83)) * make_float3 (_S86);
    float3  _S87 = (_S78 * make_float3 (_S81) - _S77 * make_float3 (_S84)) * make_float3 (_S86);
    float3  _S88 = t_0 - n_2 * make_float3 (dot_0(n_2, t_0));
    float3  t_1 = ((((_S88)) * make_float3(rnorm3df(((_S88)).x, ((_S88)).y, ((_S88)).z))));
    bool _S89 = (dot_0(cross_0(n_2, t_1), _S87)) > 0.0f;
    float3  t_2;
    if(_S89)
    {
        float3  _S90 = negate_0(t_1);
        t_2 = _S90;
    }
    else
    {
        t_2 = t_1;
    }
    float3  _S91 = cross_0(n_2, t_2);
    return makeMatrix<float, 3, 3> (t_2, _S91, n_2);
}

__device__ float3  tangentToWorldNormalMap(float3  v_2, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_2, tbn_0);
}

__device__ float3  sampleHalfVector(float3  v_3, float3  n_i_0, float alpha_4, uint * random_state_0)
{
    Random _S92 = pcg(*random_state_0);
    Random _S93 = pcg(_S92.state);
    *random_state_0 = _S93.state;
    float3  _S94 = worldToTangent(v_3, n_i_0);
    float3  _S95 = sampleGGXVNDF(float3 {_S94.x, _S94.z, _S94.y}, alpha_4, _S92.value, _S93.value);
    float3  _S96 = float3 {_S95.x, _S95.z, _S95.y};
    float3  _S97 = tangentToWorld(_S96, n_i_0);
    return _S97;
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float3  _S98 = a_4 / b_0;
    float3  _S99 = make_float3 (0.0f);
    bool3  _S100 = b_0 == _S99;
    float3  _S101 = _slang_select(_S100, _S99,_S98);
    return _S101;
}

#undef Matrix
