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
    float _S122 = 1.0f - material_0.metallic;
    float _S123 = 1.0f - _S120;
    float _S124 = (1.0f - material_0.transmission) * _S122 * _S123;
    float _S125 = material_0.transmission * _S122 * _S123;
    float _S126 = (F32_max((_S121), (0.0f)));
    float _S127 = (F32_max((_S124), (0.0f)));
    float _S128 = sign_0(length_0(_S119));
    float _S129 = (F32_max((_S125 * _S128), (0.0f)));
    float _S130 = _S126 + _S127 + _S129;
    float _S131 = 1.0f / (F32_max((_S130), (0.0000152587890625f)));
    float _S132 = _S127 * _S131;
    float _S133 = _S126 * _S131;
    float _S134 = _S129 * _S131;
    return BSDFLobes_x24init_0(_S115, _S116, _S119, F_1, _S121, 1.0f, _S124, _S125, _S132, _S133, _S134);
}

__device__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_5, BSDFLobes lobes_0, float eta_i_2, float eta_o_2, uint lobe_0)
{
    bool _S135 = lobe_0 == 0U;
    if(_S135)
    {
        float _S136 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        bool _S137 = n_i_dot_v_0 > 0.0f;
        float _S138 = _slang_select(_S137, _S136,0.0f);
        return _S138;
    }
    float _S139 = smithG1(alpha_5, n_i_dot_v_0);
    float _S140 = _S139 * lobes_0.v_dot_h;
    float _S141 = trowbridgeReitz(alpha_5, lobes_0.n_dot_h);
    float _S142 = _S140 * _S141 / n_i_dot_v_0;
    bool _S143 = alpha_5 > 0.0f;
    bool _S144;
    if(_S143)
    {
        _S144 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S144 = false;
    }
    if(_S144)
    {
        _S144 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S144 = false;
    }
    if(_S144)
    {
        _S144 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S144 = false;
    }
    float _S145 = _slang_select(_S144, _S142,0.0f);
    bool _S146 = lobe_0 == 1U;
    if(_S146)
    {
        float _S147 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        float _S148 = lobes_0.p_refract * _S145 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S147 * _S147);
        bool _S149 = eta_i_2 != eta_o_2;
        if(_S149)
        {
            _S144 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S144 = false;
        }
        float _S150 = _slang_select(_S144, _S148,0.0f);
        return _S150;
    }
    float _S151 = lobes_0.p_reflect * _S145 / (4.0f * lobes_0.v_dot_h);
    bool _S152 = _S145 > 0.0f;
    float _S153 = _slang_select(_S152, _S151,0.0f);
    return _S153;
}

__device__ float3  lobeThroughput(float3  l_0, float3  n_i_2, float alpha_6, BSDFMaterial material_1, BSDFLobes lobes_1, uint lobe_1)
{
    bool _S154 = lobe_1 == 0U;
    if(_S154)
    {
        return make_float3 (lobes_1.diffuse_weight) * material_1.albedo / make_float3 (lobes_1.p_diffuse);
    }
    bool _S155 = lobe_1 == 1U;
    if(_S155)
    {
        float _S156 = - dot_0(n_i_2, l_0);
        float _S157 = G1(alpha_6, (F32_max((_S156), (0.0f))));
        return make_float3 (lobes_1.refract_weight * _S157) * material_1.albedo / make_float3 (lobes_1.p_refract);
    }
    float _S158 = dot_0(n_i_2, l_0);
    float _S159 = G1(alpha_6, (F32_max((_S158), (0.0f))));
    return make_float3 (lobes_1.reflect_weight * _S159) * lobes_1.F / make_float3 (lobes_1.p_reflect);
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
    SampleBSDF _S160;
    (&_S160)->unit_direction = unit_direction_0;
    (&_S160)->throughput = throughput_0;
    (&_S160)->random_state = random_state_1;
    (&_S160)->refracted = refracted_1;
    (&_S160)->lobe = lobe_2;
    (&_S160)->pdf = pdf_0;
    return _S160;
}

__device__ SampleBSDF connectBSDF(float3  in_dir_1, float3  out_dir_0, float3  n_5, BSDFMaterial material_2, float eta_i_3, float eta_o_3, uint lobe_3, uint random_init_0)
{
    uint random_state_2 = random_init_0;
    float3  _S161 = negate_0(in_dir_1);
    float _S162 = dot_0(n_5, _S161);
    float _S163 = sign_0(_S162);
    float3  _S164 = n_5 * make_float3 (_S163);
    float _S165 = material_2.roughness;
    float _S166 = _S165 * _S165;
    float3  _S167 = _S161 + out_dir_0;
    float3  _S168 = ((((_S167)) * make_float3(rnorm3df(((_S167)).x, ((_S167)).y, ((_S167)).z))));
    bool _S169 = lobe_3 == 0U;
    float3  ggx_n_1;
    if(_S169)
    {
        float3  _S170 = sampleHalfVector(_S161, _S164, _S166, &random_state_2);
        ggx_n_1 = _S170;
    }
    else
    {
        bool _S171 = lobe_3 == 1U;
        if(_S171)
        {
            float3  _S172 = negate_0(make_float3 (eta_i_3) * _S161 + make_float3 (eta_o_3) * out_dir_0);
            float3  _S173 = ((((_S172)) * make_float3(rnorm3df(((_S172)).x, ((_S172)).y, ((_S172)).z))));
            float _S174 = sign_0(dot_0(_S172, _S164));
            float3  _S175 = _S173 * make_float3 (_S174);
            ggx_n_1 = _S175;
        }
        else
        {
            ggx_n_1 = _S168;
        }
    }
    BSDFLobes _S176 = bsdfLobes(in_dir_1, _S161, _S164, ggx_n_1, material_2, eta_i_3, eta_o_3);
    float _S177 = lobeDensity(dot_0(_S164, out_dir_0), dot_0(out_dir_0, ggx_n_1), (F32_abs((_S162))), _S166, _S176, eta_i_3, eta_o_3, lobe_3);
    bool _S178 = !(_S177 > 0.0f);
    if(_S178)
    {
        float3  _S179 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S179, _S179, 0U, false, 0U, 0.0f);
    }
    float3  _S180 = lobeThroughput(out_dir_0, _S164, _S166, material_2, _S176, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S180, random_state_2, lobe_3 == 1U, lobe_3, _S177);
}

__device__ float3  BSDF(float3  in_dir_2, float3  out_dir_1, float3  n_6, float3  g_n_0, BSDFMaterial material_3, float eta_i_4, float eta_o_4, uint random_state_3)
{
    float3  _S181 = negate_0(in_dir_2);
    bool _S182 = (dot_0(g_n_0, _S181) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S182)
    {
        SampleBSDF _S183 = connectBSDF(in_dir_2, out_dir_1, n_6, material_3, eta_i_4, eta_o_4, 0U, random_state_3);
        SampleBSDF _S184 = connectBSDF(in_dir_2, out_dir_1, n_6, material_3, eta_i_4, eta_o_4, 2U, random_state_3);
        return _S183.throughput * make_float3 (_S183.pdf) + _S184.throughput * make_float3 (_S184.pdf);
    }
    SampleBSDF _S185 = connectBSDF(in_dir_2, out_dir_1, n_6, material_3, eta_i_4, eta_o_4, 1U, random_state_3);
    return _S185.throughput * make_float3 (_S185.pdf);
}

__device__ SampleBSDF sampleBSDF(float3  in_dir_3, float3  n_7, BSDFMaterial material_4, float eta_i_5, float eta_o_5, uint random_init_1, float2  screen_space_0)
{
    uint random_state_4 = random_init_1;
    float3  _S186 = negate_0(in_dir_3);
    float _S187 = dot_0(n_7, _S186);
    float _S188 = sign_0(_S187);
    float3  n_i_3 = n_7 * make_float3 (_S188);
    float _S189 = (F32_abs((_S187)));
    float _S190 = material_4.roughness;
    float _S191 = _S190 * _S190;
    float3  _S192 = sampleHalfVector(_S186, n_i_3, _S191, &random_state_4);
    BSDFLobes _S193 = bsdfLobes(in_dir_3, _S186, n_i_3, _S192, material_4, eta_i_5, eta_o_5);
    float3  _S194 = make_float3 (1.0f);
    SampleBSDF _S195 = SampleBSDF_x24init_0(_S194, _S194, 0U, false, 0U, 0.0f);
    SampleBSDF sample_0 = _S195;
    Random _S196 = pcg(random_state_4);
    random_state_4 = _S196.state;
    bool _S197 = (_S196.value) < (_S193.p_diffuse);
    if(_S197)
    {
        Random _S198 = pcg(random_state_4);
        Random _S199 = pcg(_S198.state);
        (&sample_0)->random_state = _S199.state;
        float3  _S200 = sampleCosWeightedHemisphere(_S198.value, _S199.value);
        float3  _S201 = tangentToWorld(_S200, n_i_3);
        (&sample_0)->unit_direction = _S201;
        float3  _S202 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S191, material_4, _S193, 0U);
        (&sample_0)->throughput = _S202;
        float _S203 = lobeDensity(_S200.y, 0.0f, _S189, _S191, _S193, eta_i_5, eta_o_5, 0U);
        (&sample_0)->pdf = _S203;
        return sample_0;
    }
    bool _S204 = (_S196.value) < (_S193.p_diffuse + _S193.p_refract);
    if(_S204)
    {
        (&sample_0)->unit_direction = _S193.refracted;
        float _S205 = lobeDensity(0.0f, dot_0((&sample_0)->unit_direction, _S192), _S189, _S191, _S193, eta_i_5, eta_o_5, 1U);
        (&sample_0)->pdf = _S205;
        float3  _S206 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S191, material_4, _S193, 1U);
        (&sample_0)->throughput = _S206;
        (&sample_0)->random_state = random_state_4;
        (&sample_0)->refracted = true;
        (&sample_0)->lobe = 1U;
        return sample_0;
    }
    float3  _S207 = reflect_0(in_dir_3, _S192);
    float3  _S208 = ((((_S207)) * make_float3(rnorm3df(((_S207)).x, ((_S207)).y, ((_S207)).z))));
    (&sample_0)->unit_direction = _S208;
    float3  _S209 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S191, material_4, _S193, 2U);
    (&sample_0)->throughput = _S209;
    (&sample_0)->random_state = random_state_4;
    (&sample_0)->lobe = 2U;
    float _S210 = lobeDensity(0.0f, 0.0f, _S189, _S191, _S193, eta_i_5, eta_o_5, 2U);
    (&sample_0)->pdf = _S210;
    return sample_0;
}

__device__ float3  pointLightRadiance(float3  color_0, float intensity_0, float radius_0)
{
    return color_0 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_0 * radius_0);
}

__device__ float3  beerLambert(float distance_1, float3  absorption_0)
{
    float3  _S211 = max_0(absorption_0, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_1) * log_0(_S211));
}

__device__ bool samplesLights(BSDFMaterial material_5)
{
    bool _S212 = (material_5.roughness) > 0.0f;
    bool _S213;
    if(_S212)
    {
        _S213 = true;
    }
    else
    {
        bool _S214 = (material_5.metallic) < 1.0f;
        if(_S214)
        {
            _S213 = (material_5.transmission) < 1.0f;
        }
        else
        {
            _S213 = false;
        }
    }
    return _S213;
}

__device__ float3  neeBSDF(float3  in_dir_4, float3  dir_0, float3  n_8, BSDFMaterial material_6, float eta_i_6, float eta_o_6, bool refracted_2, float pdf_1, bool power_0, uint random_state_5)
{
    float3  _S215 = make_float3 (0.0f);
    uint lobe_4 = 0U;
    float3  f_0 = _S215;
    for(;;)
    {
        if(lobe_4 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S216 = (lobe_4 == 1U) == refracted_2;
        float3  f_1;
        if(_S216)
        {
            SampleBSDF _S217 = connectBSDF(in_dir_4, dir_0, n_8, material_6, eta_i_6, eta_o_6, lobe_4, random_state_5);
            bool _S218 = (_S217.pdf) > 0.0f;
            if(_S218)
            {
                if(power_0)
                {
                    float _S219 = _S217.pdf / pdf_1;
                    float3  f_2 = f_0 + _S217.throughput * make_float3 (_S217.pdf) / make_float3 (pdf_1 * (1.0f + _S219 * _S219));
                    f_1 = f_2;
                }
                else
                {
                    float3  f_3 = f_0 + _S217.throughput * make_float3 (_S217.pdf) / make_float3 (_S217.pdf + pdf_1);
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
    float _S220 = material_7.transmission * (1.0f - material_7.metallic);
    float _S221 = material_7.roughness;
    float _S222 = G1(_S221 * _S221, (F32_abs((dot_0(n_9, dir_1)))));
    return make_float3 (_S220 * _S222) * material_7.albedo;
}

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_0, float3  end_0)
{
    float _S223 = sign_0(dot_0(light_n_0, start_0 - end_0));
    return light_n_0 * make_float3 (_S223 * light_offset_0);
}

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

__device__ float3  occluderTransmittance(float3  toward_0, float3  n_10, BSDFMaterial material_8, float coverage_0)
{
    float3  _S224;
    if((material_8.ior) == 1.0f)
    {
        float3  _S225 = straightThrough(toward_0, n_10, material_8);
        _S224 = _S225;
    }
    else
    {
        _S224 = make_float3 (0.0f);
    }
    return _S224 * make_float3 (coverage_0) + make_float3 (1.0f - coverage_0);
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S226 = hash(index_0);
    uint _S227 = hash(seed_0 ^ _S226);
    return _S227;
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float3  _S228 = a_4 / b_0;
    float3  _S229 = make_float3 (0.0f);
    bool3  _S230 = b_0 == _S229;
    float3  _S231 = _slang_select(_S230, _S229,_S228);
    return _S231;
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
    float _S232 = rgb_to_greyscale(weight_0);
    bool _S233 = _S232 > 0.0f;
    bool _S234;
    if(_S233)
    {
        _S234 = _S232 < 3.00000000549775576e+38f;
    }
    else
    {
        _S234 = false;
    }
    bool _S235 = !_S234;
    if(_S235)
    {
        return;
    }
    float _S236 = sel_0->w_sum + _S232;
    sel_0->w_sum = _S236;
    float3  _S237 = sel_0->color + weight_0;
    sel_0->color = _S237;
    Random _S238 = pcg(sel_0->random_state);
    sel_0->random_state = _S238.state;
    bool _S239 = (_S238.value * sel_0->w_sum) <= _S232;
    if(_S239)
    {
        sel_0->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_1, Reservoir r_0, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_0;
    float3  _S240 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S240;
    float _S241 = r_0.jac * shifted_0.jac;
    (&candidate_1)->jac = _S241;
    offer(sel_1, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_0.w));
    return;
}

__device__ Reservoir finalize(Selection sel_2, float c_0)
{
    Reservoir r_1 = sel_2.r;
    float _S242 = rgb_to_greyscale((&r_1)->f);
    float _S243 = sel_2.w_sum / _S242;
    bool _S244 = _S242 > 0.0f;
    float _S245 = _slang_select(_S244, _S243,0.0f);
    (&r_1)->w = _S245;
    (&r_1)->c = c_0;
    return r_1;
}

static __device__ uint insertBits_0(uint e_1, uint newbits_0, uint offset_0, uint count_0)
{
    uint _S246 = (1U << count_0) - 1U;
    return (e_1 & (~(_S246 << offset_0))) | ((newbits_0 & _S246) << offset_0);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_1, float3  f_4)
{
    Reservoir candidate_2 = r_2;
    uint _S247 = insertBits_0(r_2.path, end_1, 0U, 5U);
    uint _S248 = insertBits_0(_S247, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S248;
    (&candidate_2)->f = f_4;
    return candidate_2;
}

__device__ float facingSign(float transmission_0, float3  face_0, float3  direction_0)
{
    bool _S249 = transmission_0 > 0.0f;
    bool _S250;
    if(_S249)
    {
        _S250 = true;
    }
    else
    {
        _S250 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S251;
    if(_S250)
    {
        _S251 = 1.0f;
    }
    else
    {
        _S251 = -1.0f;
    }
    return _S251;
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
    bool _S252;
    if(open_0)
    {
        _S252 = prev_rough_0;
    }
    else
    {
        _S252 = false;
    }
    if(_S252)
    {
        _S252 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S252 = false;
    }
    return _S252;
}

__device__ bool withinInverseFootprint(float pdf_2, bool diffuse_0, float prev_cos_0, float distance_3, float threshold_1)
{
    bool _S253 = pdf_2 > 0.0f;
    bool _S254;
    if(_S253)
    {
        if(diffuse_0)
        {
            _S254 = true;
        }
        else
        {
            _S254 = (pdf_2 * prev_cos_0 / (distance_3 * distance_3) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S254 = false;
    }
    return _S254;
}

__device__ bool roughLobe(float pdf_3, bool diffuse_1, float roughness_0)
{
    bool _S255 = pdf_3 > 0.0f;
    bool _S256;
    if(_S255)
    {
        if(diffuse_1)
        {
            _S256 = true;
        }
        else
        {
            _S256 = roughness_0 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S256 = false;
    }
    return _S256;
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
    float _S257 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S257;
}

__device__ float2  temporalWeights(float c_1, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S258 = c_1 * p_c_0;
    float _S259 = c_t_0 * p_t_0;
    return make_float2 (_S258 / (_S258 + c_t_0 * g_previous_0), _S259 / (_S259 + c_1 * g_current_0));
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
    float _S260 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S261 = cos_a_0 > cos_b_0;
    float _S262 = _slang_select(_S261, 1.0f,_S260);
    return _S262;
}

__device__ float sinSubClamped(float sin_a_1, float cos_a_1, float sin_b_1, float cos_b_1)
{
    float _S263 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    bool _S264 = cos_a_1 > cos_b_1;
    float _S265 = _slang_select(_S264, 0.0f,_S263);
    return _S265;
}

__device__ float sine(float c_2)
{
    return (F32_sqrt(((F32_max((1.0f - c_2 * c_2), (0.0f))))));
}

__device__ float importance(LightNode node_0, float3  p_0, float3  normal_1)
{
    float3  _S266 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S267 = node_0.high - node_0.low;
    float3  _S268 = p_0 - _S266;
    float3  _S269 = ((((_S268)) * make_float3(rnorm3df(((_S268)).x, ((_S268)).y, ((_S268)).z))));
    float _S270 = dot_0(_S268, _S268);
    float _S271 = dot_0(_S267, _S267) / 4.0f;
    float _S272 = (F32_abs((dot_0(node_0.w, _S269))));
    float _S273 = sine(node_0.cos_theta_o);
    float _S274 = (F32_sqrt(((F32_max((1.0f - _S271 / _S270), (0.0f))))));
    bool _S275 = _S270 < _S271;
    float _S276 = _slang_select(_S275, -1.0f,_S274);
    float _S277 = sine(_S276);
    float _S278 = sine(_S272);
    float _S279 = cosSubClamped(_S278, _S272, _S273, node_0.cos_theta_o);
    float _S280 = sine(_S272);
    float _S281 = sinSubClamped(_S280, _S272, _S273, node_0.cos_theta_o);
    float _S282 = cosSubClamped(_S281, _S279, _S277, _S276);
    bool _S283 = _S282 <= 0.0f;
    if(_S283)
    {
        return 0.0f;
    }
    float _S284 = - dot_0(_S269, normal_1);
    float _S285 = node_0.phi * _S282 / (F32_max((_S270), (length_0(_S267) / 2.0f)));
    float _S286 = sine(_S284);
    float _S287 = cosSubClamped(_S286, _S284, _S277, _S276);
    bool _S288 = (dot_0(normal_1, normal_1)) == 0.0f;
    float _S289 = _slang_select(_S288, 1.0f,_S287);
    return (F32_max((_S285 * _S289), (0.0f)));
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_1)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_1)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_1))));
}

__device__ uint pickChild(LightNode first_0, LightNode second_0, float3  p_1, float3  normal_3, float * pick_0, float * probability_1)
{
    float _S290 = importance(first_0, p_1, normal_3);
    float _S291 = importance(second_0, p_1, normal_3);
    float2  _S292 = make_float2 (_S290, _S291);
    bool _S293 = _S290 == 0.0f;
    bool _S294;
    if(_S293)
    {
        _S294 = _S291 == 0.0f;
    }
    else
    {
        _S294 = false;
    }
    if(_S294)
    {
        return 2U;
    }
    float _S295 = _S290 + _S291;
    bool _S296 = _S291 > 0.0f;
    if(_S296)
    {
        _S294 = (*pick_0 * _S295) >= _S290;
    }
    else
    {
        _S294 = false;
    }
    uint _S297 = uint(_S294);
    float _S298 = (F32_min(((*pick_0 * _S295 - float(_S297) * _S290) / _slang_vector_get_element(_S292, _S297)), (0.99999994039535522f)));
    *pick_0 = _S298;
    float _S299 = *probability_1 * (_slang_vector_get_element(_S292, _S297) / _S295);
    *probability_1 = _S299;
    return _S297;
}

__device__ float childShare(LightNode first_1, LightNode second_1, float3  p_2, float3  normal_4, uint child_0)
{
    float _S300 = importance(first_1, p_2, normal_4);
    float _S301 = importance(second_1, p_2, normal_4);
    float2  _S302 = make_float2 (_S300, _S301);
    float _S303 = _slang_vector_get_element(_S302, child_0) / (_S300 + _S301);
    bool _S304 = _slang_vector_get_element(_S302, child_0) > 0.0f;
    float _S305 = _slang_select(_S304, _S303,0.0f);
    return _S305;
}

__device__ float powerHeuristic(float a_6, float b_2)
{
    float _S306 = 1.0f / (1.0f + b_2 / a_6 * (b_2 / a_6));
    bool _S307 = b_2 > 0.0f;
    float _S308 = _slang_select(_S307, _S306,1.0f);
    return _S308;
}

__device__ float sphereDensity(float3  center_0, float radius_1, float3  p_3)
{
    float3  _S309 = center_0 - p_3;
    float _S310 = radius_1 * radius_1 / dot_0(_S309, _S309);
    bool _S311 = _S310 >= 1.0f;
    if(_S311)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S310)))) / (6.28318548202514648f * _S310);
}

__device__ float3  sampleSphere(float3  center_1, float radius_2, float3  p_4, float u1_0, float u2_0)
{
    float3  _S312 = center_1 - p_4;
    float _S313 = radius_2 * radius_2 / dot_0(_S312, _S312);
    float _S314 = u1_0 * _S313 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S313), (0.0f)))))));
    float _S315 = 2.0f * u1_0;
    bool _S316 = _S313 >= 1.0f;
    float _S317 = _slang_select(_S316, _S315,_S314);
    float _S318 = (F32_sqrt(((F32_max((_S317 * (2.0f - _S317)), (0.0f))))));
    float _S319 = 6.28318548202514648f * u2_0;
    float3  _S320 = make_float3 (_S318 * (F32_cos((_S319))), 1.0f - _S317, _S318 * (F32_sin((_S319))));
    float3  _S321 = ((((_S312)) * make_float3(rnorm3df(((_S312)).x, ((_S312)).y, ((_S312)).z))));
    float3  _S322 = tangentToWorld(_S320, _S321);
    return _S322;
}

#undef Matrix
