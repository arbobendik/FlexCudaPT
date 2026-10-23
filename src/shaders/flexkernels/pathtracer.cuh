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

__device__ float smithG1(float alpha_1, float n_dot_x_0)
{
    float _S30 = alpha_1 * alpha_1;
    float _S31 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S30 + (1.0f - _S30) * n_dot_x_0 * n_dot_x_0))));
    bool _S32 = alpha_1 > 0.0f;
    float _S33 = _slang_select(_S32, _S31,1.0f);
    return _S33;
}

__device__ float G1(float alpha_2, float n_dot_x_1)
{
    float _S34 = smithG1(alpha_2, n_dot_x_1);
    return _S34;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S35 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S36 = eta_i_0 / eta_o_0 * _S35;
    bool _S37 = _S36 < 1.0f;
    float kr_0;
    if(_S37)
    {
        float _S38 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S36 * _S36))))));
        float _S39 = eta_o_0 * cos_theta_0;
        float _S40 = eta_i_0 * _S38;
        float _S41 = (_S39 - _S40) / (_S39 + _S40);
        float _S42 = eta_i_0 * cos_theta_0;
        float _S43 = eta_o_0 * _S38;
        float _S44 = (_S42 - _S43) / (_S42 + _S43);
        float _S45 = (_S41 * _S41 + _S44 * _S44) / 2.0f;
        kr_0 = _S45;
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
    float3  _S46 = make_float3 (alpha_3 * Ve_0.x, alpha_3 * Ve_0.y, Ve_0.z);
    float3  _S47 = ((((_S46)) * make_float3(rnorm3df(((_S46)).x, ((_S46)).y, ((_S46)).z))));
    float _S48 = _S47.x;
    float _S49 = _S47.y;
    float _S50 = _S48 * _S48 + _S49 * _S49;
    float3  _S51;
    if(_S50 > 0.0f)
    {
        float3  _S52 = make_float3 (- _S49, _S48, 0.0f);
        float _S53 = (rsqrtf((_S50)));
        _S51 = _S52 * make_float3 (_S53);
    }
    else
    {
        _S51 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S54 = cross_0(_S47, _S51);
    float _S55 = (F32_sqrt((U1_0)));
    float _S56 = 6.28318548202514648f * U2_0;
    float _S57 = _S55 * (F32_cos((_S56)));
    float t2_0 = _S55 * (F32_sin((_S56)));
    float _S58 = 0.5f * (1.0f + _S47.z);
    float t2_1 = (1.0f - _S58) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S57 * _S57)))))) + _S58 * t2_0;
    float3  _S59 = make_float3 (_S57) * _S51 + make_float3 (t2_1) * _S54;
    float _S60 = unshared_0(_S57);
    float _S61 = unshared_0(_S57);
    float3  _S62 = _S59 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S60 * _S61 - t2_1 * t2_1))))))) * _S47;
    float3  _S63 = make_float3 (alpha_3 * _S62.x, alpha_3 * _S62.y, (F32_max((0.0f), (_S62.z))));
    float3  _S64 = ((((_S63)) * make_float3(rnorm3df(((_S63)).x, ((_S63)).y, ((_S63)).z))));
    return _S64;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S65 = (F32_sqrt((random_1_0)));
    float _S66 = 6.28318548202514648f * random_2_0;
    float _S67 = _S65 * (F32_cos((_S66)));
    float _S68 = _S65 * (F32_sin((_S66)));
    float _S69 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S67 * _S67 - _S68 * _S68))))));
    return make_float3 (_S67, _S69, _S68);
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_2)
{
    float3  a_0 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S70 = (F32_abs((dot_0(n_2, a_0)))) > 0.9999847412109375f;
    float3  a_1;
    if(_S70)
    {
        float3  _S71 = make_float3 (1.0f, 0.0f, 0.0f);
        a_1 = _S71;
    }
    else
    {
        a_1 = a_0;
    }
    float3  _S72 = cross_0(n_2, a_1);
    float3  _S73 = ((((_S72)) * make_float3(rnorm3df(((_S72)).x, ((_S72)).y, ((_S72)).z))));
    float3  _S74 = cross_0(n_2, _S73);
    return make_float3 (v_0.x) * _S73 + make_float3 (v_0.y) * n_2 + make_float3 (v_0.z) * _S74;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
{
    float3  a_2 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S75 = (F32_abs((dot_0(n_3, a_2)))) > 0.9999847412109375f;
    float3  a_3;
    if(_S75)
    {
        float3  _S76 = make_float3 (1.0f, 0.0f, 0.0f);
        a_3 = _S76;
    }
    else
    {
        a_3 = a_2;
    }
    float3  _S77 = cross_0(n_3, a_3);
    float3  _S78 = ((((_S77)) * make_float3(rnorm3df(((_S77)).x, ((_S77)).y, ((_S77)).z))));
    float3  _S79 = cross_0(n_3, _S78);
    return make_float3 (dot_0(v_1, _S78), dot_0(v_1, n_3), dot_0(v_1, _S79));
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_4)
{
    float3  _S80 = p1_0 - p0_0;
    float3  _S81 = p2_0 - p0_0;
    float2  _S82 = uv1_0 - uv0_0;
    float2  _S83 = uv2_0 - uv0_0;
    float _S84 = _S82.x;
    float _S85 = _S83.y;
    float _S86 = _S82.y;
    float _S87 = _S83.x;
    float _S88 = _S84 * _S85 - _S86 * _S87;
    float _S89 = 1.0f / _S88;
    float3  t_0 = (_S80 * make_float3 (_S85) - _S81 * make_float3 (_S86)) * make_float3 (_S89);
    float3  _S90 = (_S81 * make_float3 (_S84) - _S80 * make_float3 (_S87)) * make_float3 (_S89);
    float3  _S91 = t_0 - n_4 * make_float3 (dot_0(n_4, t_0));
    float3  t_1 = ((((_S91)) * make_float3(rnorm3df(((_S91)).x, ((_S91)).y, ((_S91)).z))));
    bool _S92 = (dot_0(cross_0(n_4, t_1), _S90)) > 0.0f;
    float3  t_2;
    if(_S92)
    {
        float3  _S93 = negate_0(t_1);
        t_2 = _S93;
    }
    else
    {
        t_2 = t_1;
    }
    float3  _S94 = cross_0(n_4, t_2);
    return makeMatrix<float, 3, 3> (t_2, _S94, n_4);
}

__device__ float3  tangentToWorldNormalMap(float3  v_2, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_2, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_0, float3  uvw_0, float3  position_0)
{
    float3  _S95 = t1_0 - t0_0;
    float3  _S96 = t2_2 - t0_0;
    float3  _S97 = t2_2 - t1_0;
    float _S98 = (F32_min((length_0(_S95)), ((F32_min((length_0(_S96)), (length_0(_S97)))))));
    float3  _S99 = make_float3 (distance_0(position_0, t0_0), distance_0(position_0, t1_0), distance_0(position_0, t2_2));
    float3  _S100 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S101 = dot_0(geometry_n_0, _S100);
    float3  _S102 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S103 = dot_0(geometry_n_0, _S102);
    float3  _S104 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S105 = acos_0(abs_0(make_float3 (_S101, _S103, dot_0(geometry_n_0, _S104))));
    float3  _S106 = clamp_0(tan_0(_S105), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S99 * _S106, uvw_0), 0.0f, _S98 * 0.125f);
}

__device__ float3  sampleHalfVector(float3  v_3, float3  n_i_0, float alpha_4, uint * random_state_0)
{
    Random _S107 = pcg(*random_state_0);
    Random _S108 = pcg(_S107.state);
    *random_state_0 = _S108.state;
    float3  _S109 = worldToTangent(v_3, n_i_0);
    float3  _S110 = sampleGGXVNDF(float3 {_S109.x, _S109.z, _S109.y}, alpha_4, _S107.value, _S108.value);
    float3  _S111 = float3 {_S110.x, _S110.z, _S110.y};
    float3  _S112 = tangentToWorld(_S111, n_i_0);
    return _S112;
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

static __device__ float sign_0(float e_0)
{
    float _S113;
    if(e_0 > 0.0f)
    {
        _S113 = 1.0f;
    }
    else
    {
        if(e_0 < 0.0f)
        {
            _S113 = -1.0f;
        }
        else
        {
            _S113 = 0.0f;
        }
    }
    return _S113;
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
    BSDFLobes _S114;
    (&_S114)->v_dot_h = v_dot_h_0;
    (&_S114)->n_dot_h = n_dot_h_1;
    (&_S114)->refracted = refracted_0;
    (&_S114)->F = F_0;
    (&_S114)->F_greyscale = F_greyscale_0;
    (&_S114)->reflect_weight = reflect_weight_0;
    (&_S114)->diffuse_weight = diffuse_weight_0;
    (&_S114)->refract_weight = refract_weight_0;
    (&_S114)->p_diffuse = p_diffuse_0;
    (&_S114)->p_reflect = p_reflect_0;
    (&_S114)->p_refract = p_refract_0;
    return _S114;
}

__device__ BSDFLobes bsdfLobes(float3  in_dir_0, float3  v_4, float3  n_i_1, float3  ggx_n_0, BSDFMaterial material_0, float eta_i_1, float eta_o_1)
{
    float _S115 = dot_0(ggx_n_0, v_4);
    float _S116 = dot_0(n_i_1, ggx_n_0);
    float _S117 = eta_i_1 / eta_o_1;
    float3  _S118 = refract_0(in_dir_0, ggx_n_0, _S117);
    float3  _S119 = ((((_S118)) * make_float3(rnorm3df(((_S118)).x, ((_S118)).y, ((_S118)).z))));
    float _S120 = fresnel((F32_abs((_S115))), eta_i_1, eta_o_1);
    float3  F_1 = mix_0(make_float3 (_S120), material_0.albedo, material_0.metallic);
    float _S121 = rgb_to_greyscale(F_1);
    float _S122 = (1.0f - material_0.transmission) * (1.0f - material_0.metallic);
    float _S123 = (F32_max((_S121), (0.0f)));
    float _S124 = 1.0f - _S121;
    float _S125 = (F32_max((_S122 * _S124), (0.0f)));
    float _S126 = material_0.transmission * _S124;
    float _S127 = sign_0(length_0(_S119));
    float _S128 = (F32_max((_S126 * _S127), (0.0f)));
    float _S129 = _S123 + _S125 + _S128;
    float _S130 = 1.0f / (F32_max((_S129), (0.0000152587890625f)));
    float _S131 = _S125 * _S130;
    float _S132 = _S123 * _S130;
    float _S133 = _S128 * _S130;
    return BSDFLobes_x24init_0(_S115, _S116, _S119, F_1, _S121, 1.0f, _S122, material_0.transmission, _S131, _S132, _S133);
}

__device__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_5, BSDFLobes lobes_0, float eta_i_2, float eta_o_2, uint lobe_0)
{
    bool _S134 = lobe_0 == 0U;
    if(_S134)
    {
        float _S135 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        bool _S136 = n_i_dot_v_0 > 0.0f;
        float _S137 = _slang_select(_S136, _S135,0.0f);
        return _S137;
    }
    float _S138 = smithG1(alpha_5, n_i_dot_v_0);
    float _S139 = _S138 * lobes_0.v_dot_h;
    float _S140 = trowbridgeReitz(alpha_5, lobes_0.n_dot_h);
    float _S141 = _S139 * _S140 / n_i_dot_v_0;
    bool _S142 = alpha_5 > 0.0f;
    bool _S143;
    if(_S142)
    {
        _S143 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S143 = false;
    }
    if(_S143)
    {
        _S143 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S143 = false;
    }
    if(_S143)
    {
        _S143 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S143 = false;
    }
    float _S144 = _slang_select(_S143, _S141,0.0f);
    bool _S145 = lobe_0 == 1U;
    if(_S145)
    {
        float _S146 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        float _S147 = lobes_0.p_refract * _S144 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S146 * _S146);
        bool _S148 = eta_i_2 != eta_o_2;
        if(_S148)
        {
            _S143 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S143 = false;
        }
        float _S149 = _slang_select(_S143, _S147,0.0f);
        return _S149;
    }
    float _S150 = lobes_0.p_reflect * _S144 / (4.0f * lobes_0.v_dot_h);
    bool _S151 = _S144 > 0.0f;
    float _S152 = _slang_select(_S151, _S150,0.0f);
    return _S152;
}

__device__ float3  lobeThroughput(float3  l_0, float3  n_i_2, float alpha_6, BSDFMaterial material_1, BSDFLobes lobes_1, uint lobe_1)
{
    bool _S153 = lobe_1 == 0U;
    if(_S153)
    {
        return make_float3 (lobes_1.diffuse_weight) * material_1.albedo / make_float3 (lobes_1.p_diffuse);
    }
    bool _S154 = lobe_1 == 1U;
    if(_S154)
    {
        float _S155 = - dot_0(n_i_2, l_0);
        float _S156 = G1(alpha_6, (F32_max((_S155), (0.0f))));
        return make_float3 (lobes_1.refract_weight * _S156 * (1.0f - lobes_1.F_greyscale)) * material_1.albedo / make_float3 (lobes_1.p_refract);
    }
    float _S157 = dot_0(n_i_2, l_0);
    float _S158 = G1(alpha_6, (F32_max((_S157), (0.0f))));
    return make_float3 (lobes_1.reflect_weight * _S158) * lobes_1.F / make_float3 (lobes_1.p_reflect);
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
    SampleBSDF _S159;
    (&_S159)->unit_direction = unit_direction_0;
    (&_S159)->throughput = throughput_0;
    (&_S159)->random_state = random_state_1;
    (&_S159)->refracted = refracted_1;
    (&_S159)->lobe = lobe_2;
    (&_S159)->pdf = pdf_0;
    return _S159;
}

__device__ SampleBSDF connectBSDF(float3  in_dir_1, float3  out_dir_0, float3  n_5, BSDFMaterial material_2, float eta_i_3, float eta_o_3, uint lobe_3, uint random_init_0)
{
    uint random_state_2 = random_init_0;
    float3  _S160 = negate_0(in_dir_1);
    float _S161 = dot_0(n_5, _S160);
    float _S162 = sign_0(_S161);
    float3  _S163 = n_5 * make_float3 (_S162);
    float _S164 = material_2.roughness;
    float _S165 = _S164 * _S164;
    float3  _S166 = _S160 + out_dir_0;
    float3  _S167 = ((((_S166)) * make_float3(rnorm3df(((_S166)).x, ((_S166)).y, ((_S166)).z))));
    bool _S168 = lobe_3 == 0U;
    float3  ggx_n_1;
    if(_S168)
    {
        float3  _S169 = sampleHalfVector(_S160, _S163, _S165, &random_state_2);
        ggx_n_1 = _S169;
    }
    else
    {
        bool _S170 = lobe_3 == 1U;
        if(_S170)
        {
            float3  _S171 = negate_0(make_float3 (eta_i_3) * _S160 + make_float3 (eta_o_3) * out_dir_0);
            float3  _S172 = ((((_S171)) * make_float3(rnorm3df(((_S171)).x, ((_S171)).y, ((_S171)).z))));
            float _S173 = sign_0(dot_0(_S171, _S163));
            float3  _S174 = _S172 * make_float3 (_S173);
            ggx_n_1 = _S174;
        }
        else
        {
            ggx_n_1 = _S167;
        }
    }
    BSDFLobes _S175 = bsdfLobes(in_dir_1, _S160, _S163, ggx_n_1, material_2, eta_i_3, eta_o_3);
    float _S176 = lobeDensity(dot_0(_S163, out_dir_0), dot_0(out_dir_0, ggx_n_1), (F32_abs((_S161))), _S165, _S175, eta_i_3, eta_o_3, lobe_3);
    bool _S177 = !(_S176 > 0.0f);
    if(_S177)
    {
        float3  _S178 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S178, _S178, 0U, false, 0U, 0.0f);
    }
    float3  _S179 = lobeThroughput(out_dir_0, _S163, _S165, material_2, _S175, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S179, random_state_2, lobe_3 == 1U, lobe_3, _S176);
}

__device__ float3  BSDF(float3  in_dir_2, float3  out_dir_1, float3  n_6, float3  g_n_0, BSDFMaterial material_3, float eta_i_4, float eta_o_4, uint random_state_3)
{
    float3  _S180 = negate_0(in_dir_2);
    bool _S181 = (dot_0(g_n_0, _S180) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S181)
    {
        SampleBSDF _S182 = connectBSDF(in_dir_2, out_dir_1, n_6, material_3, eta_i_4, eta_o_4, 0U, random_state_3);
        SampleBSDF _S183 = connectBSDF(in_dir_2, out_dir_1, n_6, material_3, eta_i_4, eta_o_4, 2U, random_state_3);
        return _S182.throughput * make_float3 (_S182.pdf) + _S183.throughput * make_float3 (_S183.pdf);
    }
    SampleBSDF _S184 = connectBSDF(in_dir_2, out_dir_1, n_6, material_3, eta_i_4, eta_o_4, 1U, random_state_3);
    return _S184.throughput * make_float3 (_S184.pdf);
}

__device__ SampleBSDF sampleBSDF(float3  in_dir_3, float3  n_7, BSDFMaterial material_4, float eta_i_5, float eta_o_5, uint random_init_1, float2  screen_space_0)
{
    uint random_state_4 = random_init_1;
    float3  _S185 = negate_0(in_dir_3);
    float _S186 = dot_0(n_7, _S185);
    float _S187 = sign_0(_S186);
    float3  n_i_3 = n_7 * make_float3 (_S187);
    float _S188 = (F32_abs((_S186)));
    float _S189 = material_4.roughness;
    float _S190 = _S189 * _S189;
    float3  _S191 = sampleHalfVector(_S185, n_i_3, _S190, &random_state_4);
    BSDFLobes _S192 = bsdfLobes(in_dir_3, _S185, n_i_3, _S191, material_4, eta_i_5, eta_o_5);
    float3  _S193 = make_float3 (1.0f);
    SampleBSDF _S194 = SampleBSDF_x24init_0(_S193, _S193, 0U, false, 0U, 0.0f);
    SampleBSDF sample_0 = _S194;
    Random _S195 = pcg(random_state_4);
    random_state_4 = _S195.state;
    bool _S196 = (_S195.value) < (_S192.p_diffuse);
    if(_S196)
    {
        Random _S197 = pcg(random_state_4);
        Random _S198 = pcg(_S197.state);
        (&sample_0)->random_state = _S198.state;
        float3  _S199 = sampleCosWeightedHemisphere(_S197.value, _S198.value);
        float3  _S200 = tangentToWorld(_S199, n_i_3);
        (&sample_0)->unit_direction = _S200;
        float3  _S201 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S190, material_4, _S192, 0U);
        (&sample_0)->throughput = _S201;
        float _S202 = lobeDensity(_S199.y, 0.0f, _S188, _S190, _S192, eta_i_5, eta_o_5, 0U);
        (&sample_0)->pdf = _S202;
        return sample_0;
    }
    bool _S203 = (_S195.value) < (_S192.p_diffuse + _S192.p_refract);
    if(_S203)
    {
        (&sample_0)->unit_direction = _S192.refracted;
        float _S204 = lobeDensity(0.0f, dot_0((&sample_0)->unit_direction, _S191), _S188, _S190, _S192, eta_i_5, eta_o_5, 1U);
        (&sample_0)->pdf = _S204;
        float3  _S205 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S190, material_4, _S192, 1U);
        (&sample_0)->throughput = _S205;
        (&sample_0)->random_state = random_state_4;
        (&sample_0)->refracted = true;
        (&sample_0)->lobe = 1U;
        return sample_0;
    }
    float3  _S206 = reflect_0(in_dir_3, _S191);
    float3  _S207 = ((((_S206)) * make_float3(rnorm3df(((_S206)).x, ((_S206)).y, ((_S206)).z))));
    (&sample_0)->unit_direction = _S207;
    float3  _S208 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S190, material_4, _S192, 2U);
    (&sample_0)->throughput = _S208;
    (&sample_0)->random_state = random_state_4;
    (&sample_0)->lobe = 2U;
    float _S209 = lobeDensity(0.0f, 0.0f, _S188, _S190, _S192, eta_i_5, eta_o_5, 2U);
    (&sample_0)->pdf = _S209;
    return sample_0;
}

__device__ float3  pointLightRadiance(float3  color_0, float intensity_0, float radius_0)
{
    return color_0 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_0 * radius_0);
}

__device__ float3  beerLambert(float distance_1, float3  absorption_0)
{
    float3  _S210 = max_0(absorption_0, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_1) * log_0(_S210));
}

__device__ bool samplesLights(BSDFMaterial material_5)
{
    bool _S211 = (material_5.roughness) > 0.0f;
    bool _S212;
    if(_S211)
    {
        _S212 = true;
    }
    else
    {
        bool _S213 = (material_5.metallic) < 1.0f;
        if(_S213)
        {
            _S212 = (material_5.transmission) < 1.0f;
        }
        else
        {
            _S212 = false;
        }
    }
    return _S212;
}

__device__ float3  neeBSDF(float3  in_dir_4, float3  dir_0, float3  n_8, BSDFMaterial material_6, float eta_i_6, float eta_o_6, bool refracted_2, float pdf_1, bool power_0, uint random_state_5)
{
    float3  _S214 = make_float3 (0.0f);
    uint lobe_4 = 0U;
    float3  f_0 = _S214;
    for(;;)
    {
        if(lobe_4 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S215 = (lobe_4 == 1U) == refracted_2;
        float3  f_1;
        if(_S215)
        {
            SampleBSDF _S216 = connectBSDF(in_dir_4, dir_0, n_8, material_6, eta_i_6, eta_o_6, lobe_4, random_state_5);
            bool _S217 = (_S216.pdf) > 0.0f;
            if(_S217)
            {
                if(power_0)
                {
                    float _S218 = _S216.pdf / pdf_1;
                    float3  f_2 = f_0 + _S216.throughput * make_float3 (_S216.pdf) / make_float3 (pdf_1 * (1.0f + _S218 * _S218));
                    f_1 = f_2;
                }
                else
                {
                    float3  f_3 = f_0 + _S216.throughput * make_float3 (_S216.pdf) / make_float3 (_S216.pdf + pdf_1);
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
    float _S219 = rgb_to_greyscale(material_7.albedo * make_float3 (material_7.metallic));
    float _S220 = material_7.roughness;
    float _S221 = G1(_S220 * _S220, (F32_abs((dot_0(n_9, dir_1)))));
    return make_float3 (material_7.transmission * _S221 * (1.0f - _S219)) * material_7.albedo;
}

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_0, float3  end_0)
{
    float _S222 = sign_0(dot_0(light_n_0, start_0 - end_0));
    return light_n_0 * make_float3 (_S222 * light_offset_0);
}

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

__device__ float3  occluderTransmittance(float3  toward_0, float3  n_10, BSDFMaterial material_8, float coverage_0)
{
    float3  _S223;
    if((material_8.ior) == 1.0f)
    {
        float3  _S224 = straightThrough(toward_0, n_10, material_8);
        _S223 = _S224;
    }
    else
    {
        _S223 = make_float3 (0.0f);
    }
    return _S223 * make_float3 (coverage_0) + make_float3 (1.0f - coverage_0);
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S225 = hash(index_0);
    uint _S226 = hash(seed_0 ^ _S225);
    return _S226;
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float3  _S227 = a_4 / b_0;
    float3  _S228 = make_float3 (0.0f);
    bool3  _S229 = b_0 == _S228;
    float3  _S230 = _slang_select(_S229, _S228,_S227);
    return _S230;
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
    float _S231 = rgb_to_greyscale(weight_0);
    bool _S232 = _S231 > 0.0f;
    bool _S233;
    if(_S232)
    {
        _S233 = _S231 < 3.00000000549775576e+38f;
    }
    else
    {
        _S233 = false;
    }
    bool _S234 = !_S233;
    if(_S234)
    {
        return;
    }
    float _S235 = sel_0->w_sum + _S231;
    sel_0->w_sum = _S235;
    float3  _S236 = sel_0->color + weight_0;
    sel_0->color = _S236;
    Random _S237 = pcg(sel_0->random_state);
    sel_0->random_state = _S237.state;
    bool _S238 = (_S237.value * sel_0->w_sum) <= _S231;
    if(_S238)
    {
        sel_0->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_1, Reservoir r_0, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_0;
    float3  _S239 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S239;
    float _S240 = r_0.jac * shifted_0.jac;
    (&candidate_1)->jac = _S240;
    offer(sel_1, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_0.w));
    return;
}

__device__ Reservoir finalize(Selection sel_2, float c_0)
{
    Reservoir r_1 = sel_2.r;
    float _S241 = rgb_to_greyscale((&r_1)->f);
    float _S242 = sel_2.w_sum / _S241;
    bool _S243 = _S241 > 0.0f;
    float _S244 = _slang_select(_S243, _S242,0.0f);
    (&r_1)->w = _S244;
    (&r_1)->c = c_0;
    return r_1;
}

static __device__ uint insertBits_0(uint e_1, uint newbits_0, uint offset_0, uint count_0)
{
    uint _S245 = (1U << count_0) - 1U;
    return (e_1 & (~(_S245 << offset_0))) | ((newbits_0 & _S245) << offset_0);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_1, float3  f_4)
{
    Reservoir candidate_2 = r_2;
    uint _S246 = insertBits_0(r_2.path, end_1, 0U, 5U);
    uint _S247 = insertBits_0(_S246, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S247;
    (&candidate_2)->f = f_4;
    return candidate_2;
}

__device__ float facingSign(float transmission_0, float3  face_0, float3  direction_0)
{
    bool _S248 = transmission_0 > 0.0f;
    bool _S249;
    if(_S248)
    {
        _S249 = true;
    }
    else
    {
        _S249 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S250;
    if(_S249)
    {
        _S250 = 1.0f;
    }
    else
    {
        _S250 = -1.0f;
    }
    return _S250;
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
    bool _S251;
    if(open_0)
    {
        _S251 = prev_rough_0;
    }
    else
    {
        _S251 = false;
    }
    if(_S251)
    {
        _S251 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S251 = false;
    }
    return _S251;
}

__device__ bool withinInverseFootprint(float pdf_2, bool diffuse_0, float prev_cos_0, float distance_3, float threshold_1)
{
    bool _S252 = pdf_2 > 0.0f;
    bool _S253;
    if(_S252)
    {
        if(diffuse_0)
        {
            _S253 = true;
        }
        else
        {
            _S253 = (pdf_2 * prev_cos_0 / (distance_3 * distance_3) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S253 = false;
    }
    return _S253;
}

__device__ bool roughLobe(float pdf_3, bool diffuse_1, float roughness_0)
{
    bool _S254 = pdf_3 > 0.0f;
    bool _S255;
    if(_S254)
    {
        if(diffuse_1)
        {
            _S255 = true;
        }
        else
        {
            _S255 = roughness_0 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S255 = false;
    }
    return _S255;
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
    float _S256 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S256;
}

__device__ float2  temporalWeights(float c_1, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S257 = c_1 * p_c_0;
    float _S258 = c_t_0 * p_t_0;
    return make_float2 (_S257 / (_S257 + c_t_0 * g_previous_0), _S258 / (_S258 + c_1 * g_current_0));
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
    float _S259 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S260 = cos_a_0 > cos_b_0;
    float _S261 = _slang_select(_S260, 1.0f,_S259);
    return _S261;
}

__device__ float sinSubClamped(float sin_a_1, float cos_a_1, float sin_b_1, float cos_b_1)
{
    float _S262 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    bool _S263 = cos_a_1 > cos_b_1;
    float _S264 = _slang_select(_S263, 0.0f,_S262);
    return _S264;
}

__device__ float sine(float c_2)
{
    return (F32_sqrt(((F32_max((1.0f - c_2 * c_2), (0.0f))))));
}

__device__ float importance(LightNode node_0, float3  p_0, float3  normal_1)
{
    float3  _S265 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S266 = node_0.high - node_0.low;
    float3  _S267 = p_0 - _S265;
    float3  _S268 = ((((_S267)) * make_float3(rnorm3df(((_S267)).x, ((_S267)).y, ((_S267)).z))));
    float _S269 = dot_0(_S267, _S267);
    float _S270 = dot_0(_S266, _S266) / 4.0f;
    float _S271 = (F32_abs((dot_0(node_0.w, _S268))));
    float _S272 = sine(node_0.cos_theta_o);
    float _S273 = (F32_sqrt(((F32_max((1.0f - _S270 / _S269), (0.0f))))));
    bool _S274 = _S269 < _S270;
    float _S275 = _slang_select(_S274, -1.0f,_S273);
    float _S276 = sine(_S275);
    float _S277 = sine(_S271);
    float _S278 = cosSubClamped(_S277, _S271, _S272, node_0.cos_theta_o);
    float _S279 = sine(_S271);
    float _S280 = sinSubClamped(_S279, _S271, _S272, node_0.cos_theta_o);
    float _S281 = cosSubClamped(_S280, _S278, _S276, _S275);
    bool _S282 = _S281 <= 0.0f;
    if(_S282)
    {
        return 0.0f;
    }
    float _S283 = - dot_0(_S268, normal_1);
    float _S284 = node_0.phi * _S281 / (F32_max((_S269), (length_0(_S266) / 2.0f)));
    float _S285 = sine(_S283);
    float _S286 = cosSubClamped(_S285, _S283, _S276, _S275);
    bool _S287 = (dot_0(normal_1, normal_1)) == 0.0f;
    float _S288 = _slang_select(_S287, 1.0f,_S286);
    return (F32_max((_S284 * _S288), (0.0f)));
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_1)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_1)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_1))));
}

__device__ uint pickChild(LightNode first_0, LightNode second_0, float3  p_1, float3  normal_3, float * pick_0, float * probability_1)
{
    float _S289 = importance(first_0, p_1, normal_3);
    float _S290 = importance(second_0, p_1, normal_3);
    float2  _S291 = make_float2 (_S289, _S290);
    bool _S292 = _S289 == 0.0f;
    bool _S293;
    if(_S292)
    {
        _S293 = _S290 == 0.0f;
    }
    else
    {
        _S293 = false;
    }
    if(_S293)
    {
        return 2U;
    }
    float _S294 = _S289 + _S290;
    bool _S295 = _S290 > 0.0f;
    if(_S295)
    {
        _S293 = (*pick_0 * _S294) >= _S289;
    }
    else
    {
        _S293 = false;
    }
    uint _S296 = uint(_S293);
    float _S297 = (F32_min(((*pick_0 * _S294 - float(_S296) * _S289) / _slang_vector_get_element(_S291, _S296)), (0.99999994039535522f)));
    *pick_0 = _S297;
    float _S298 = *probability_1 * (_slang_vector_get_element(_S291, _S296) / _S294);
    *probability_1 = _S298;
    return _S296;
}

__device__ float childShare(LightNode first_1, LightNode second_1, float3  p_2, float3  normal_4, uint child_0)
{
    float _S299 = importance(first_1, p_2, normal_4);
    float _S300 = importance(second_1, p_2, normal_4);
    float2  _S301 = make_float2 (_S299, _S300);
    float _S302 = _slang_vector_get_element(_S301, child_0) / (_S299 + _S300);
    bool _S303 = _slang_vector_get_element(_S301, child_0) > 0.0f;
    float _S304 = _slang_select(_S303, _S302,0.0f);
    return _S304;
}

__device__ float powerHeuristic(float a_6, float b_2)
{
    float _S305 = 1.0f / (1.0f + b_2 / a_6 * (b_2 / a_6));
    bool _S306 = b_2 > 0.0f;
    float _S307 = _slang_select(_S306, _S305,1.0f);
    return _S307;
}

__device__ float sphereDensity(float3  center_0, float radius_1, float3  p_3)
{
    float3  _S308 = center_0 - p_3;
    float _S309 = radius_1 * radius_1 / dot_0(_S308, _S308);
    bool _S310 = _S309 >= 1.0f;
    if(_S310)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S309)))) / (6.28318548202514648f * _S309);
}

__device__ float3  sampleSphere(float3  center_1, float radius_2, float3  p_4, float u1_0, float u2_0)
{
    float3  _S311 = center_1 - p_4;
    float _S312 = radius_2 * radius_2 / dot_0(_S311, _S311);
    float _S313 = u1_0 * _S312 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S312), (0.0f)))))));
    float _S314 = 2.0f * u1_0;
    bool _S315 = _S312 >= 1.0f;
    float _S316 = _slang_select(_S315, _S314,_S313);
    float _S317 = (F32_sqrt(((F32_max((_S316 * (2.0f - _S316)), (0.0f))))));
    float _S318 = 6.28318548202514648f * u2_0;
    float3  _S319 = make_float3 (_S317 * (F32_cos((_S318))), 1.0f - _S316, _S317 * (F32_sin((_S318))));
    float3  _S320 = ((((_S311)) * make_float3(rnorm3df(((_S311)).x, ((_S311)).y, ((_S311)).z))));
    float3  _S321 = tangentToWorld(_S319, _S320);
    return _S321;
}

#undef Matrix
