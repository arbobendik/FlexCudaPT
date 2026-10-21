#pragma once
#define Matrix SlangMatrix
#include "slang-cuda-prelude.h"

static __device__ float3  min_0(float3  x_0, float3  y_0)
{
    float3  result_0;
    int i_0 = int(0);
    for(;;)
    {
        if(i_0 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_0, i_0) = (F32_min((_slang_vector_get_element(x_0, i_0)), (_slang_vector_get_element(y_0, i_0))));
        i_0 = i_0 + int(1);
    }
    return result_0;
}

static __device__ float3  exp_0(float3  x_1)
{
    float3  result_1;
    int i_1 = int(0);
    for(;;)
    {
        if(i_1 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_1, i_1) = (F32_exp((_slang_vector_get_element(x_1, i_1))));
        i_1 = i_1 + int(1);
    }
    return result_1;
}

static __device__ float3  log_0(float3  x_2)
{
    float3  result_2;
    int i_2 = int(0);
    for(;;)
    {
        if(i_2 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_2, i_2) = (F32_log((_slang_vector_get_element(x_2, i_2))));
        i_2 = i_2 + int(1);
    }
    return result_2;
}

static __device__ float3  max_0(float3  x_3, float3  y_1)
{
    float3  result_3;
    int i_3 = int(0);
    for(;;)
    {
        if(i_3 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_3, i_3) = (F32_max((_slang_vector_get_element(x_3, i_3)), (_slang_vector_get_element(y_1, i_3))));
        i_3 = i_3 + int(1);
    }
    return result_3;
}

static __device__ float dot_0(float3  x_4, float3  y_2)
{
    return x_4.x * y_2.x + x_4.y * y_2.y + x_4.z * y_2.z;
}

static __device__ float3  reflect_0(float3  i_4, float3  n_0)
{
    return i_4 - make_float3 (2.0f * dot_0(n_0, i_4)) * n_0;
}

static __device__ float3  refract_0(float3  i_5, float3  n_1, float eta_0)
{
    float _S1 = dot_0(n_1, i_5);
    float _S2 = 1.0f - eta_0 * eta_0 * (1.0f - _S1 * _S1);
    if(_S2 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S1 + (F32_sqrt((_S2)))) * n_1;
}

static __device__ float3  clamp_0(float3  x_5, float3  minBound_0, float3  maxBound_0)
{
    return min_0(max_0(x_5, minBound_0), maxBound_0);
}

static __device__ float3  tan_0(float3  x_6)
{
    float3  result_4;
    int i_6 = int(0);
    for(;;)
    {
        if(i_6 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_4, i_6) = (F32_tan((_slang_vector_get_element(x_6, i_6))));
        i_6 = i_6 + int(1);
    }
    return result_4;
}

static __device__ float3  acos_0(float3  x_7)
{
    float3  result_5;
    int i_7 = int(0);
    for(;;)
    {
        if(i_7 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_5, i_7) = (F32_acos((_slang_vector_get_element(x_7, i_7))));
        i_7 = i_7 + int(1);
    }
    return result_5;
}

static __device__ float3  abs_0(float3  x_8)
{
    float3  result_6;
    int i_8 = int(0);
    for(;;)
    {
        if(i_8 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_6, i_8) = (F32_abs((_slang_vector_get_element(x_8, i_8))));
        i_8 = i_8 + int(1);
    }
    return result_6;
}

static __device__ float length_0(float3  x_9)
{
    return (F32_sqrt((dot_0(x_9, x_9))));
}

static __device__ float distance_0(float3  x_10, float3  y_3)
{
    return length_0(x_10 - y_3);
}

static __device__ float3  mul_0(float3  left_0, Matrix<float, 3, 3>  right_0)
{
    float3  result_7;
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
        int i_9 = int(0);
        float sum_0 = 0.0f;
        for(;;)
        {
            if(i_9 < int(3))
            {
            }
            else
            {
                break;
            }
            float sum_1 = sum_0 + _slang_vector_get_element(left_0, i_9) * _slang_vector_get_element(right_0.rows[i_9], j_0);
            i_9 = i_9 + int(1);
            sum_0 = sum_1;
        }
        *_slang_vector_get_element_ptr(&result_7, j_0) = sum_0;
        j_0 = j_0 + int(1);
    }
    return result_7;
}

static __device__ float3  cross_0(float3  left_1, float3  right_1)
{
    float _S3 = left_1.y;
    float _S4 = right_1.z;
    float _S5 = left_1.z;
    float _S6 = right_1.y;
    float _S7 = right_1.x;
    float _S8 = left_1.x;
    return make_float3 (_S3 * _S4 - _S5 * _S6, _S5 * _S7 - _S8 * _S4, _S8 * _S6 - _S3 * _S7);
}

static __device__ float clamp_1(float x_11, float minBound_1, float maxBound_1)
{
    return (F32_min(((F32_max((x_11), (minBound_1)))), (maxBound_1)));
}

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

__device__ uint hash(uint x_12)
{
    uint _S9 = x_12 * 747796405U + 2891336453U;
    uint _S10 = ((_S9 >> ((_S9 >> 28U) + 4U)) ^ _S9) * 277803737U;
    return (_S10 >> 22U) ^ _S10;
}

struct Random
{
    uint state;
    float value;
};

static __device__ Random Random_x24init_0(uint state_0, float value_0)
{
    Random _S11;
    (&_S11)->state = state_0;
    (&_S11)->value = value_0;
    return _S11;
}

static __device__ float random_0(uint * state_1)
{
    uint _S12 = hash(*state_1);
    *state_1 = _S12;
    return float((*state_1) >> int(8)) * 5.9604644775390625e-08f;
}

__device__ Random pcg(uint state_2)
{
    uint _S13 = state_2;
    float value_1 = random_0(&_S13);
    return Random_x24init_0(_S13, value_1);
}

__device__ Random normal_distribution(uint state_3)
{
    Random _S14 = pcg(state_3);
    Random _S15 = pcg(_S14.state);
    float _S16 = 6.28318548202514648f * _S14.value;
    float _S17 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S15.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S15.state, _S17 * (F32_cos((_S16))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S18;
    (&_S18)->state = state_4;
    (&_S18)->value = value_2;
    return _S18;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S19 = normal_distribution(state_5);
    Random _S20 = normal_distribution(_S19.state);
    Random _S21 = normal_distribution(_S20.state);
    float3  _S22 = make_float3 (_S19.value, _S20.value, _S21.value);
    float3  _S23 = ((((_S22)) * make_float3(rnorm3df(((_S22)).x, ((_S22)).y, ((_S22)).z))));
    return RandomSphere_x24init_0(_S21.state, _S23);
}

struct RandomHemisphere
{
    uint state;
    float3  value;
};

static __device__ RandomHemisphere RandomHemisphere_x24init_0(uint state_6, float3  value_3)
{
    RandomHemisphere _S24;
    (&_S24)->state = state_6;
    (&_S24)->value = value_3;
    return _S24;
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

__device__ RandomHemisphere random_hemisphere(uint state_7, float3  normal_0)
{
    RandomSphere _S25 = random_sphere(state_7);
    bool _S26 = (dot_0(_S25.value, normal_0)) > 0.0f;
    if(_S26)
    {
        return RandomHemisphere_x24init_0(_S25.state, _S25.value);
    }
    else
    {
        float3  _S27 = negate_0(_S25.value);
        return RandomHemisphere_x24init_0(_S25.state, _S27);
    }
}

__device__ float trowbridgeReitz(float alpha_0, float n_dot_h_0)
{
    float _S28 = alpha_0 * alpha_0;
    float _S29 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S28 * n_dot_h_0 * n_dot_h_0;
    return _S28 / (F32_max((3.14159274101257324f * _S29 * _S29), (1.17549435082228751e-38f)));
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

static __device__ float unshared_0(float x_14)
{
    return x_14;
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

__device__ float3  tangentToWorld(float3  v_0, float3  n_2)
{
    float3  a_0 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S67 = (F32_abs((dot_0(n_2, a_0)))) > 0.9999847412109375f;
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
    float3  _S69 = cross_0(n_2, a_1);
    float3  _S70 = ((((_S69)) * make_float3(rnorm3df(((_S69)).x, ((_S69)).y, ((_S69)).z))));
    float3  _S71 = cross_0(n_2, _S70);
    return make_float3 (v_0.x) * _S70 + make_float3 (v_0.y) * n_2 + make_float3 (v_0.z) * _S71;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
{
    float3  a_2 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S72 = (F32_abs((dot_0(n_3, a_2)))) > 0.9999847412109375f;
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
    float3  _S74 = cross_0(n_3, a_3);
    float3  _S75 = ((((_S74)) * make_float3(rnorm3df(((_S74)).x, ((_S74)).y, ((_S74)).z))));
    float3  _S76 = cross_0(n_3, _S75);
    return make_float3 (dot_0(v_1, _S75), dot_0(v_1, n_3), dot_0(v_1, _S76));
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_4)
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
    float3  _S88 = t_0 - n_4 * make_float3 (dot_0(n_4, t_0));
    float3  t_1 = ((((_S88)) * make_float3(rnorm3df(((_S88)).x, ((_S88)).y, ((_S88)).z))));
    bool _S89 = (dot_0(cross_0(n_4, t_1), _S87)) > 0.0f;
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
    float3  _S91 = cross_0(n_4, t_2);
    return makeMatrix<float, 3, 3> (t_2, _S91, n_4);
}

__device__ float3  tangentToWorldNormalMap(float3  v_2, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_2, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_0, float3  uvw_0, float3  position_0)
{
    float3  _S92 = t1_0 - t0_0;
    float3  _S93 = t2_2 - t0_0;
    float3  _S94 = t2_2 - t1_0;
    float _S95 = (F32_min((length_0(_S92)), ((F32_min((length_0(_S93)), (length_0(_S94)))))));
    float3  _S96 = make_float3 (distance_0(position_0, t0_0), distance_0(position_0, t1_0), distance_0(position_0, t2_2));
    float3  _S97 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S98 = dot_0(geometry_n_0, _S97);
    float3  _S99 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S100 = dot_0(geometry_n_0, _S99);
    float3  _S101 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S102 = acos_0(abs_0(make_float3 (_S98, _S100, dot_0(geometry_n_0, _S101))));
    float3  _S103 = clamp_0(tan_0(_S102), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S96 * _S103, uvw_0), 0.0f, _S95 * 0.125f);
}

__device__ float3  sampleHalfVector(float3  v_3, float3  n_i_0, float alpha_4, uint * random_state_0)
{
    Random _S104 = pcg(*random_state_0);
    Random _S105 = pcg(_S104.state);
    *random_state_0 = _S105.state;
    float3  _S106 = worldToTangent(v_3, n_i_0);
    float3  _S107 = sampleGGXVNDF(float3 {_S106.x, _S106.z, _S106.y}, alpha_4, _S104.value, _S105.value);
    float3  _S108 = float3 {_S107.x, _S107.z, _S107.y};
    float3  _S109 = tangentToWorld(_S108, n_i_0);
    return _S109;
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

static __device__ float sign_0(float e_0)
{
    float _S110;
    if(e_0 > 0.0f)
    {
        _S110 = 1.0f;
    }
    else
    {
        if(e_0 < 0.0f)
        {
            _S110 = -1.0f;
        }
        else
        {
            _S110 = 0.0f;
        }
    }
    return _S110;
}

struct BSDFLobes
{
    float v_dot_h;
    float n_dot_h;
    float3  refracted;
    float3  F;
    float F_greyscale;
    float reflect_weight;
    float diffuse_weight;
    float refract_weight;
    float p_diffuse;
    float p_reflect;
    float p_refract;
};

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_1, float3  refracted_0, float3  F_0, float F_greyscale_0, float reflect_weight_0, float diffuse_weight_0, float refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0)
{
    BSDFLobes _S111;
    (&_S111)->v_dot_h = v_dot_h_0;
    (&_S111)->n_dot_h = n_dot_h_1;
    (&_S111)->refracted = refracted_0;
    (&_S111)->F = F_0;
    (&_S111)->F_greyscale = F_greyscale_0;
    (&_S111)->reflect_weight = reflect_weight_0;
    (&_S111)->diffuse_weight = diffuse_weight_0;
    (&_S111)->refract_weight = refract_weight_0;
    (&_S111)->p_diffuse = p_diffuse_0;
    (&_S111)->p_reflect = p_reflect_0;
    (&_S111)->p_refract = p_refract_0;
    return _S111;
}

__device__ BSDFLobes bsdfLobes(float3  in_dir_0, float3  v_4, float3  n_i_1, float3  ggx_n_0, BSDFMaterial material_0, float eta_i_1, float eta_o_1)
{
    float _S112 = dot_0(ggx_n_0, v_4);
    float _S113 = dot_0(n_i_1, ggx_n_0);
    float _S114 = eta_i_1 / eta_o_1;
    float3  _S115 = refract_0(in_dir_0, ggx_n_0, _S114);
    float3  _S116 = ((((_S115)) * make_float3(rnorm3df(((_S115)).x, ((_S115)).y, ((_S115)).z))));
    float _S117 = fresnel((F32_abs((_S112))), eta_i_1, eta_o_1);
    float3  F_1 = mix_0(make_float3 (_S117), material_0.albedo, material_0.metallic);
    float _S118 = rgb_to_greyscale(F_1);
    float _S119 = (1.0f - material_0.transmission) * (1.0f - material_0.metallic);
    float _S120 = (F32_max((_S118), (0.0f)));
    float _S121 = 1.0f - _S118;
    float _S122 = (F32_max((_S119 * _S121), (0.0f)));
    float _S123 = material_0.transmission * _S121;
    float _S124 = sign_0(length_0(_S116));
    float _S125 = (F32_max((_S123 * _S124), (0.0f)));
    float _S126 = _S120 + _S122 + _S125;
    float _S127 = 1.0f / (F32_max((_S126), (0.0000152587890625f)));
    float _S128 = _S122 * _S127;
    float _S129 = _S120 * _S127;
    float _S130 = _S125 * _S127;
    return BSDFLobes_x24init_0(_S112, _S113, _S116, F_1, _S118, 1.0f, _S119, material_0.transmission, _S128, _S129, _S130);
}

__device__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_5, BSDFLobes lobes_0, float eta_i_2, float eta_o_2, uint lobe_0)
{
    bool _S131 = lobe_0 == 0U;
    if(_S131)
    {
        float _S132 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        bool _S133 = n_i_dot_v_0 > 0.0f;
        float _S134 = _slang_select(_S133, _S132,0.0f);
        return _S134;
    }
    float _S135 = smithG1(alpha_5, n_i_dot_v_0);
    float _S136 = _S135 * lobes_0.v_dot_h;
    float _S137 = trowbridgeReitz(alpha_5, lobes_0.n_dot_h);
    float _S138 = _S136 * _S137 / n_i_dot_v_0;
    bool _S139 = alpha_5 > 0.0f;
    bool _S140;
    if(_S139)
    {
        _S140 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S140 = false;
    }
    if(_S140)
    {
        _S140 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S140 = false;
    }
    if(_S140)
    {
        _S140 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S140 = false;
    }
    float _S141 = _slang_select(_S140, _S138,0.0f);
    bool _S142 = lobe_0 == 1U;
    if(_S142)
    {
        float _S143 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        float _S144 = lobes_0.p_refract * _S141 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S143 * _S143);
        bool _S145 = eta_i_2 != eta_o_2;
        if(_S145)
        {
            _S140 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S140 = false;
        }
        float _S146 = _slang_select(_S140, _S144,0.0f);
        return _S146;
    }
    float _S147 = lobes_0.p_reflect * _S141 / (4.0f * lobes_0.v_dot_h);
    bool _S148 = _S141 > 0.0f;
    float _S149 = _slang_select(_S148, _S147,0.0f);
    return _S149;
}

__device__ float3  lobeThroughput(float3  l_0, float3  n_i_2, float alpha_6, BSDFMaterial material_1, BSDFLobes lobes_1, uint lobe_1)
{
    bool _S150 = lobe_1 == 0U;
    if(_S150)
    {
        return make_float3 (lobes_1.diffuse_weight) * material_1.albedo / make_float3 (lobes_1.p_diffuse);
    }
    bool _S151 = lobe_1 == 1U;
    if(_S151)
    {
        float _S152 = - dot_0(n_i_2, l_0);
        float _S153 = G1(alpha_6, (F32_max((_S152), (0.0f))));
        return make_float3 (lobes_1.refract_weight * _S153 * (1.0f - lobes_1.F_greyscale)) * material_1.albedo / make_float3 (lobes_1.p_refract);
    }
    float _S154 = dot_0(n_i_2, l_0);
    float _S155 = G1(alpha_6, (F32_max((_S154), (0.0f))));
    return make_float3 (lobes_1.reflect_weight * _S155) * lobes_1.F / make_float3 (lobes_1.p_reflect);
}

struct SampleBSDF
{
    float3  unit_direction;
    float3  throughput;
    uint random_state;
    bool refracted;
    uint lobe;
    float pdf;
};

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_0, float3  throughput_0, uint random_state_1, bool refracted_1, uint lobe_2, float pdf_0)
{
    SampleBSDF _S156;
    (&_S156)->unit_direction = unit_direction_0;
    (&_S156)->throughput = throughput_0;
    (&_S156)->random_state = random_state_1;
    (&_S156)->refracted = refracted_1;
    (&_S156)->lobe = lobe_2;
    (&_S156)->pdf = pdf_0;
    return _S156;
}

__device__ SampleBSDF connectBSDF(float3  in_dir_1, float3  out_dir_0, float3  n_5, BSDFMaterial material_2, float eta_i_3, float eta_o_3, uint lobe_3, uint random_init_0)
{
    uint random_state_2 = random_init_0;
    float3  _S157 = negate_0(in_dir_1);
    float _S158 = dot_0(n_5, _S157);
    float _S159 = sign_0(_S158);
    float3  _S160 = n_5 * make_float3 (_S159);
    float _S161 = material_2.roughness;
    float _S162 = _S161 * _S161;
    float3  _S163 = _S157 + out_dir_0;
    float3  _S164 = ((((_S163)) * make_float3(rnorm3df(((_S163)).x, ((_S163)).y, ((_S163)).z))));
    bool _S165 = lobe_3 == 0U;
    float3  ggx_n_1;
    if(_S165)
    {
        float3  _S166 = sampleHalfVector(_S157, _S160, _S162, &random_state_2);
        ggx_n_1 = _S166;
    }
    else
    {
        bool _S167 = lobe_3 == 1U;
        if(_S167)
        {
            float3  _S168 = negate_0(make_float3 (eta_i_3) * _S157 + make_float3 (eta_o_3) * out_dir_0);
            float3  _S169 = ((((_S168)) * make_float3(rnorm3df(((_S168)).x, ((_S168)).y, ((_S168)).z))));
            float _S170 = sign_0(dot_0(_S168, _S160));
            float3  _S171 = _S169 * make_float3 (_S170);
            ggx_n_1 = _S171;
        }
        else
        {
            ggx_n_1 = _S164;
        }
    }
    BSDFLobes _S172 = bsdfLobes(in_dir_1, _S157, _S160, ggx_n_1, material_2, eta_i_3, eta_o_3);
    float _S173 = lobeDensity(dot_0(_S160, out_dir_0), dot_0(out_dir_0, ggx_n_1), (F32_abs((_S158))), _S162, _S172, eta_i_3, eta_o_3, lobe_3);
    bool _S174 = !(_S173 > 0.0f);
    if(_S174)
    {
        float3  _S175 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S175, _S175, 0U, false, 0U, 0.0f);
    }
    float3  _S176 = lobeThroughput(out_dir_0, _S160, _S162, material_2, _S172, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S176, random_state_2, lobe_3 == 1U, lobe_3, _S173);
}

__device__ float3  BSDF(float3  in_dir_2, float3  out_dir_1, float3  n_6, float3  g_n_0, BSDFMaterial material_3, float eta_i_4, float eta_o_4, uint random_state_3)
{
    float3  _S177 = negate_0(in_dir_2);
    bool _S178 = (dot_0(g_n_0, _S177) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S178)
    {
        SampleBSDF _S179 = connectBSDF(in_dir_2, out_dir_1, n_6, material_3, eta_i_4, eta_o_4, 0U, random_state_3);
        SampleBSDF _S180 = connectBSDF(in_dir_2, out_dir_1, n_6, material_3, eta_i_4, eta_o_4, 2U, random_state_3);
        return _S179.throughput * make_float3 (_S179.pdf) + _S180.throughput * make_float3 (_S180.pdf);
    }
    SampleBSDF _S181 = connectBSDF(in_dir_2, out_dir_1, n_6, material_3, eta_i_4, eta_o_4, 1U, random_state_3);
    return _S181.throughput * make_float3 (_S181.pdf);
}

__device__ SampleBSDF sampleBSDF(float3  in_dir_3, float3  n_7, BSDFMaterial material_4, float eta_i_5, float eta_o_5, uint random_init_1, float2  screen_space_0)
{
    uint random_state_4 = random_init_1;
    float3  _S182 = negate_0(in_dir_3);
    float _S183 = dot_0(n_7, _S182);
    float _S184 = sign_0(_S183);
    float3  n_i_3 = n_7 * make_float3 (_S184);
    float _S185 = (F32_abs((_S183)));
    float _S186 = material_4.roughness;
    float _S187 = _S186 * _S186;
    float3  _S188 = sampleHalfVector(_S182, n_i_3, _S187, &random_state_4);
    BSDFLobes _S189 = bsdfLobes(in_dir_3, _S182, n_i_3, _S188, material_4, eta_i_5, eta_o_5);
    float3  _S190 = make_float3 (1.0f);
    SampleBSDF _S191 = SampleBSDF_x24init_0(_S190, _S190, 0U, false, 0U, 0.0f);
    SampleBSDF sample_0 = _S191;
    Random _S192 = pcg(random_state_4);
    random_state_4 = _S192.state;
    bool _S193 = (_S192.value) < (_S189.p_diffuse);
    if(_S193)
    {
        Random _S194 = pcg(random_state_4);
        Random _S195 = pcg(_S194.state);
        (&sample_0)->random_state = _S195.state;
        float3  _S196 = sampleCosWeightedHemisphere(_S194.value, _S195.value);
        float3  _S197 = tangentToWorld(_S196, n_i_3);
        (&sample_0)->unit_direction = _S197;
        float3  _S198 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S187, material_4, _S189, 0U);
        (&sample_0)->throughput = _S198;
        float _S199 = lobeDensity(_S196.y, 0.0f, _S185, _S187, _S189, eta_i_5, eta_o_5, 0U);
        (&sample_0)->pdf = _S199;
        return sample_0;
    }
    bool _S200 = (_S192.value) < (_S189.p_diffuse + _S189.p_refract);
    if(_S200)
    {
        (&sample_0)->unit_direction = _S189.refracted;
        float _S201 = lobeDensity(0.0f, dot_0((&sample_0)->unit_direction, _S188), _S185, _S187, _S189, eta_i_5, eta_o_5, 1U);
        (&sample_0)->pdf = _S201;
        float3  _S202 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S187, material_4, _S189, 1U);
        (&sample_0)->throughput = _S202;
        (&sample_0)->random_state = random_state_4;
        (&sample_0)->refracted = true;
        (&sample_0)->lobe = 1U;
        return sample_0;
    }
    float3  _S203 = reflect_0(in_dir_3, _S188);
    float3  _S204 = ((((_S203)) * make_float3(rnorm3df(((_S203)).x, ((_S203)).y, ((_S203)).z))));
    (&sample_0)->unit_direction = _S204;
    float3  _S205 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S187, material_4, _S189, 2U);
    (&sample_0)->throughput = _S205;
    (&sample_0)->random_state = random_state_4;
    (&sample_0)->lobe = 2U;
    float _S206 = lobeDensity(0.0f, 0.0f, _S185, _S187, _S189, eta_i_5, eta_o_5, 2U);
    (&sample_0)->pdf = _S206;
    return sample_0;
}

__device__ float3  pointLightRadiance(float3  color_0, float intensity_0, float radius_0)
{
    return color_0 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_0 * radius_0);
}

__device__ float3  beerLambert(float distance_1, float3  absorption_0)
{
    float3  _S207 = max_0(absorption_0, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_1) * log_0(_S207));
}

__device__ bool samplesLights(BSDFMaterial material_5)
{
    bool _S208 = (material_5.roughness) > 0.0f;
    bool _S209;
    if(_S208)
    {
        _S209 = true;
    }
    else
    {
        bool _S210 = (material_5.metallic) < 1.0f;
        if(_S210)
        {
            _S209 = (material_5.transmission) < 1.0f;
        }
        else
        {
            _S209 = false;
        }
    }
    return _S209;
}

__device__ float3  neeBSDF(float3  in_dir_4, float3  dir_0, float3  n_8, BSDFMaterial material_6, float eta_i_6, float eta_o_6, bool refracted_2, float pdf_1, bool power_0, uint random_state_5)
{
    float3  _S211 = make_float3 (0.0f);
    uint lobe_4 = 0U;
    float3  f_0 = _S211;
    for(;;)
    {
        if(lobe_4 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S212 = (lobe_4 == 1U) == refracted_2;
        float3  f_1;
        if(_S212)
        {
            SampleBSDF _S213 = connectBSDF(in_dir_4, dir_0, n_8, material_6, eta_i_6, eta_o_6, lobe_4, random_state_5);
            bool _S214 = (_S213.pdf) > 0.0f;
            if(_S214)
            {
                if(power_0)
                {
                    float _S215 = _S213.pdf / pdf_1;
                    float3  f_2 = f_0 + _S213.throughput * make_float3 (_S213.pdf) / make_float3 (pdf_1 * (1.0f + _S215 * _S215));
                    f_1 = f_2;
                }
                else
                {
                    float3  f_3 = f_0 + _S213.throughput * make_float3 (_S213.pdf) / make_float3 (_S213.pdf + pdf_1);
                    f_1 = f_3;
                }
            }
            else
            {
                f_1 = f_0;
            }
        }
        else
        {
            f_1 = f_0;
        }
        uint lobe_5 = lobe_4 + 1U;
        lobe_4 = lobe_5;
        f_0 = f_1;
    }
    return f_0;
}

__device__ float3  straightThrough(float3  dir_1, float3  n_9, BSDFMaterial material_7)
{
    float _S216 = rgb_to_greyscale(material_7.albedo * make_float3 (material_7.metallic));
    float _S217 = material_7.roughness;
    float _S218 = G1(_S217 * _S217, (F32_abs((dot_0(n_9, dir_1)))));
    return make_float3 (material_7.transmission * _S218 * (1.0f - _S216)) * material_7.albedo;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S219 = hash(index_0);
    uint _S220 = hash(seed_0 ^ _S219);
    return _S220;
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float3  _S221 = a_4 / b_0;
    float3  _S222 = make_float3 (0.0f);
    bool3  _S223 = b_0 == _S222;
    float3  _S224 = _slang_select(_S223, _S222,_S221);
    return _S224;
}

struct Selection
{
    Reservoir r;
    float w_sum;
    float3  color;
    uint random_state;
};

__device__ void offer(Selection * sel_0, Reservoir candidate_0, float3  weight_0)
{
    float _S225 = rgb_to_greyscale(weight_0);
    bool _S226 = _S225 > 0.0f;
    bool _S227;
    if(_S226)
    {
        _S227 = _S225 < 3.00000000549775576e+38f;
    }
    else
    {
        _S227 = false;
    }
    bool _S228 = !_S227;
    if(_S228)
    {
        return;
    }
    float _S229 = sel_0->w_sum + _S225;
    sel_0->w_sum = _S229;
    float3  _S230 = sel_0->color + weight_0;
    sel_0->color = _S230;
    Random _S231 = pcg(sel_0->random_state);
    sel_0->random_state = _S231.state;
    bool _S232 = (_S231.value * sel_0->w_sum) <= _S225;
    if(_S232)
    {
        sel_0->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_1, Reservoir r_0, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_0;
    float3  _S233 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S233;
    float _S234 = r_0.jac * shifted_0.jac;
    (&candidate_1)->jac = _S234;
    offer(sel_1, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_0.w));
    return;
}

__device__ Reservoir finalize(Selection sel_2, float c_0)
{
    Reservoir r_1 = sel_2.r;
    float _S235 = rgb_to_greyscale((&r_1)->f);
    float _S236 = sel_2.w_sum / _S235;
    bool _S237 = _S235 > 0.0f;
    float _S238 = _slang_select(_S237, _S236,0.0f);
    (&r_1)->w = _S238;
    (&r_1)->c = c_0;
    return r_1;
}

static __device__ uint insertBits_0(uint e_1, uint newbits_0, uint offset_0, uint count_0)
{
    uint _S239 = (1U << count_0) - 1U;
    return (e_1 & (~(_S239 << offset_0))) | ((newbits_0 & _S239) << offset_0);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_0, float3  f_4)
{
    Reservoir candidate_2 = r_2;
    uint _S240 = insertBits_0(r_2.path, end_0, 0U, 5U);
    uint _S241 = insertBits_0(_S240, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S241;
    (&candidate_2)->f = f_4;
    return candidate_2;
}

__device__ float facingSign(float transmission_0, float3  face_0, float3  direction_0)
{
    bool _S242 = transmission_0 > 0.0f;
    bool _S243;
    if(_S242)
    {
        _S243 = true;
    }
    else
    {
        _S243 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S244;
    if(_S243)
    {
        _S244 = 1.0f;
    }
    else
    {
        _S244 = -1.0f;
    }
    return _S244;
}

__device__ float geometryDensity(float3  geometry_n_1, float3  direction_1, float distance_2)
{
    return (F32_abs((dot_0(geometry_n_1, direction_1)))) / (distance_2 * distance_2);
}

__device__ float footprintThreshold(float geometry_density_0)
{
    return 0.00251327408477664f / geometry_density_0;
}

__device__ bool withinFootprint(bool open_0, bool prev_rough_0, float prev_pdf_0, float geometry_density_1, float threshold_0)
{
    bool _S245;
    if(open_0)
    {
        _S245 = prev_rough_0;
    }
    else
    {
        _S245 = false;
    }
    if(_S245)
    {
        _S245 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S245 = false;
    }
    return _S245;
}

__device__ bool withinInverseFootprint(float pdf_2, bool diffuse_0, float prev_cos_0, float distance_3, float threshold_1)
{
    bool _S246 = pdf_2 > 0.0f;
    bool _S247;
    if(_S246)
    {
        if(diffuse_0)
        {
            _S247 = true;
        }
        else
        {
            _S247 = (pdf_2 * prev_cos_0 / (distance_3 * distance_3) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S247 = false;
    }
    return _S247;
}

__device__ bool roughLobe(float pdf_3, bool diffuse_1, float roughness_0)
{
    bool _S248 = pdf_3 > 0.0f;
    bool _S249;
    if(_S248)
    {
        if(diffuse_1)
        {
            _S249 = true;
        }
        else
        {
            _S249 = roughness_0 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S249 = false;
    }
    return _S249;
}

__device__ float survivalProbability(float3  throughput_1, float density_0)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_0), (0.0f)))), (1.0f)));
}

static __device__ float interpolate_0(float a_5, float b_1, float t_3)
{
    return a_5 + (b_1 - a_5) * t_3;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S250 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S250;
}

__device__ float2  temporalWeights(float c_1, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S251 = c_1 * p_c_0;
    float _S252 = c_t_0 * p_t_0;
    return make_float2 (_S251 / (_S251 + c_t_0 * g_previous_0), _S252 / (_S252 + c_1 * g_current_0));
}

__device__ float pairShare(float c_n_0, float c_pair_0, float c_sum_0)
{
    return (c_n_0 + c_pair_0) / c_sum_0;
}

__device__ float neighborWeight(float share_0, float c_n_1, float p_n_0, float c_pair_1, float g_here_0)
{
    return share_0 * c_n_1 * p_n_0 / (c_n_1 * p_n_0 + c_pair_1 * g_here_0);
}

__device__ float canonicalWeight(float share_1, float c_pair_2, float p_c_1, float c_n_2, float g_there_0)
{
    return share_1 * c_pair_2 * p_c_1 / (c_pair_2 * p_c_1 + c_n_2 * g_there_0);
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S253 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S254 = cos_a_0 > cos_b_0;
    float _S255 = _slang_select(_S254, 1.0f,_S253);
    return _S255;
}

__device__ float sinSubClamped(float sin_a_1, float cos_a_1, float sin_b_1, float cos_b_1)
{
    float _S256 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    bool _S257 = cos_a_1 > cos_b_1;
    float _S258 = _slang_select(_S257, 0.0f,_S256);
    return _S258;
}

__device__ float sine(float c_2)
{
    return (F32_sqrt(((F32_max((1.0f - c_2 * c_2), (0.0f))))));
}

__device__ float importance(LightNode node_0, float3  p_0, float3  normal_1)
{
    float3  _S259 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S260 = node_0.high - node_0.low;
    float3  _S261 = p_0 - _S259;
    float3  _S262 = ((((_S261)) * make_float3(rnorm3df(((_S261)).x, ((_S261)).y, ((_S261)).z))));
    float _S263 = dot_0(_S261, _S261);
    float _S264 = dot_0(_S260, _S260) / 4.0f;
    float _S265 = (F32_abs((dot_0(node_0.w, _S262))));
    float _S266 = sine(node_0.cos_theta_o);
    float _S267 = (F32_sqrt(((F32_max((1.0f - _S264 / _S263), (0.0f))))));
    bool _S268 = _S263 < _S264;
    float _S269 = _slang_select(_S268, -1.0f,_S267);
    float _S270 = sine(_S269);
    float _S271 = sine(_S265);
    float _S272 = cosSubClamped(_S271, _S265, _S266, node_0.cos_theta_o);
    float _S273 = sine(_S265);
    float _S274 = sinSubClamped(_S273, _S265, _S266, node_0.cos_theta_o);
    float _S275 = cosSubClamped(_S274, _S272, _S270, _S269);
    bool _S276 = _S275 <= 0.0f;
    if(_S276)
    {
        return 0.0f;
    }
    float _S277 = - dot_0(_S262, normal_1);
    float _S278 = node_0.phi * _S275 / (F32_max((_S263), (length_0(_S260) / 2.0f)));
    float _S279 = sine(_S277);
    float _S280 = cosSubClamped(_S279, _S277, _S270, _S269);
    bool _S281 = (dot_0(normal_1, normal_1)) == 0.0f;
    float _S282 = _slang_select(_S281, 1.0f,_S280);
    return (F32_max((_S278 * _S282), (0.0f)));
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_0))));
}

__device__ uint pickChild(LightNode first_0, LightNode second_0, float3  p_1, float3  normal_3, float * pick_0, float * probability_1)
{
    float _S283 = importance(first_0, p_1, normal_3);
    float _S284 = importance(second_0, p_1, normal_3);
    float2  _S285 = make_float2 (_S283, _S284);
    bool _S286 = _S283 == 0.0f;
    bool _S287;
    if(_S286)
    {
        _S287 = _S284 == 0.0f;
    }
    else
    {
        _S287 = false;
    }
    if(_S287)
    {
        return 2U;
    }
    float _S288 = _S283 + _S284;
    bool _S289 = _S284 > 0.0f;
    if(_S289)
    {
        _S287 = (*pick_0 * _S288) >= _S283;
    }
    else
    {
        _S287 = false;
    }
    uint _S290 = uint(_S287);
    float _S291 = (F32_min(((*pick_0 * _S288 - float(_S290) * _S283) / _slang_vector_get_element(_S285, _S290)), (0.99999994039535522f)));
    *pick_0 = _S291;
    float _S292 = *probability_1 * (_slang_vector_get_element(_S285, _S290) / _S288);
    *probability_1 = _S292;
    return _S290;
}

__device__ float childShare(LightNode first_1, LightNode second_1, float3  p_2, float3  normal_4, uint child_0)
{
    float _S293 = importance(first_1, p_2, normal_4);
    float _S294 = importance(second_1, p_2, normal_4);
    float2  _S295 = make_float2 (_S293, _S294);
    float _S296 = _slang_vector_get_element(_S295, child_0) / (_S293 + _S294);
    bool _S297 = _slang_vector_get_element(_S295, child_0) > 0.0f;
    float _S298 = _slang_select(_S297, _S296,0.0f);
    return _S298;
}

__device__ float powerHeuristic(float a_6, float b_2)
{
    float _S299 = 1.0f / (1.0f + b_2 / a_6 * (b_2 / a_6));
    bool _S300 = b_2 > 0.0f;
    float _S301 = _slang_select(_S300, _S299,1.0f);
    return _S301;
}

__device__ float sphereDensity(float3  center_0, float radius_1, float3  p_3)
{
    float3  _S302 = center_0 - p_3;
    float _S303 = radius_1 * radius_1 / dot_0(_S302, _S302);
    bool _S304 = _S303 >= 1.0f;
    if(_S304)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S303)))) / (6.28318548202514648f * _S303);
}

__device__ float3  sampleSphere(float3  center_1, float radius_2, float3  p_4, float u1_0, float u2_0)
{
    float3  _S305 = center_1 - p_4;
    float _S306 = radius_2 * radius_2 / dot_0(_S305, _S305);
    float _S307 = u1_0 * _S306 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S306), (0.0f)))))));
    float _S308 = 2.0f * u1_0;
    bool _S309 = _S306 >= 1.0f;
    float _S310 = _slang_select(_S309, _S308,_S307);
    float _S311 = (F32_sqrt(((F32_max((_S310 * (2.0f - _S310)), (0.0f))))));
    float _S312 = 6.28318548202514648f * u2_0;
    float3  _S313 = make_float3 (_S311 * (F32_cos((_S312))), 1.0f - _S310, _S311 * (F32_sin((_S312))));
    float3  _S314 = ((((_S305)) * make_float3(rnorm3df(((_S305)).x, ((_S305)).y, ((_S305)).z))));
    float3  _S315 = tangentToWorld(_S313, _S314);
    return _S315;
}

#undef Matrix
