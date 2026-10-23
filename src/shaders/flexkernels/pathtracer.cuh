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

__device__ Random pcg(uint state_1)
{
    uint _S12 = hash(state_1);
    float value_1 = float(_S12 >> int(8)) * 5.9604644775390625e-08f;
    return Random_x24init_0(_S12, value_1);
}

__device__ Random normal_distribution(uint state_2)
{
    Random _S13 = pcg(state_2);
    Random _S14 = pcg(_S13.state);
    float _S15 = 6.28318548202514648f * _S13.value;
    float _S16 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S14.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S14.state, _S16 * (F32_cos((_S15))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_3, float3  value_2)
{
    RandomSphere _S17;
    (&_S17)->state = state_3;
    (&_S17)->value = value_2;
    return _S17;
}

__device__ RandomSphere random_sphere(uint state_4)
{
    Random _S18 = normal_distribution(state_4);
    Random _S19 = normal_distribution(_S18.state);
    Random _S20 = normal_distribution(_S19.state);
    float3  _S21 = make_float3 (_S18.value, _S19.value, _S20.value);
    float3  _S22 = ((((_S21)) * make_float3(rnorm3df(((_S21)).x, ((_S21)).y, ((_S21)).z))));
    return RandomSphere_x24init_0(_S20.state, _S22);
}

__device__ float trowbridgeReitz(float alpha_0, float n_dot_h_0)
{
    float _S23 = alpha_0 * alpha_0;
    float _S24 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S23 * n_dot_h_0 * n_dot_h_0;
    return _S23 / (F32_max((3.14159274101257324f * _S24 * _S24), (1.17549435082228751e-38f)));
}

__device__ float smithG1(float alpha_1, float n_dot_x_0)
{
    float _S25 = alpha_1 * alpha_1;
    float _S26 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S25 + (1.0f - _S25) * n_dot_x_0 * n_dot_x_0))));
    bool _S27 = alpha_1 > 0.0f;
    float _S28 = _slang_select(_S27, _S26,1.0f);
    return _S28;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S29 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S30 = eta_i_0 / eta_o_0 * _S29;
    bool _S31 = _S30 < 1.0f;
    float kr_0;
    if(_S31)
    {
        float _S32 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S30 * _S30))))));
        bool _S33 = eta_i_0 == eta_o_0;
        float _S34 = _slang_select(_S33, cos_theta_0,_S32);
        float _S35 = eta_o_0 * cos_theta_0;
        float _S36 = eta_i_0 * _S34;
        float _S37 = (_S35 - _S36) / (_S35 + _S36);
        float _S38 = eta_i_0 * cos_theta_0;
        float _S39 = eta_o_0 * _S34;
        float _S40 = (_S38 - _S39) / (_S38 + _S39);
        float _S41 = (_S37 * _S37 + _S40 * _S40) / 2.0f;
        kr_0 = _S41;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

static __device__ float unshared_0(float x_13)
{
    return x_13;
}

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_2, float U1_0, float U2_0)
{
    float3  _S42 = make_float3 (alpha_2 * Ve_0.x, alpha_2 * Ve_0.y, Ve_0.z);
    float3  _S43 = ((((_S42)) * make_float3(rnorm3df(((_S42)).x, ((_S42)).y, ((_S42)).z))));
    float _S44 = _S43.x;
    float _S45 = _S43.y;
    float _S46 = _S44 * _S44 + _S45 * _S45;
    float3  _S47;
    if(_S46 > 0.0f)
    {
        float3  _S48 = make_float3 (- _S45, _S44, 0.0f);
        float _S49 = (rsqrtf((_S46)));
        _S47 = _S48 * make_float3 (_S49);
    }
    else
    {
        _S47 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S50 = cross_0(_S43, _S47);
    float _S51 = (F32_sqrt((U1_0)));
    float _S52 = 6.28318548202514648f * U2_0;
    float _S53 = _S51 * (F32_cos((_S52)));
    float t2_0 = _S51 * (F32_sin((_S52)));
    float _S54 = 0.5f * (1.0f + _S43.z);
    float t2_1 = (1.0f - _S54) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S53 * _S53)))))) + _S54 * t2_0;
    float3  _S55 = make_float3 (_S53) * _S47 + make_float3 (t2_1) * _S50;
    float _S56 = unshared_0(_S53);
    float _S57 = unshared_0(_S53);
    float3  _S58 = _S55 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S56 * _S57 - t2_1 * t2_1))))))) * _S43;
    float3  _S59 = make_float3 (alpha_2 * _S58.x, alpha_2 * _S58.y, (F32_max((0.0f), (_S58.z))));
    float3  _S60 = ((((_S59)) * make_float3(rnorm3df(((_S59)).x, ((_S59)).y, ((_S59)).z))));
    return _S60;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S61 = (F32_sqrt((random_1_0)));
    float _S62 = 6.28318548202514648f * random_2_0;
    float _S63 = _S61 * (F32_cos((_S62)));
    float _S64 = _S61 * (F32_sin((_S62)));
    float _S65 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S63 * _S63 - _S64 * _S64))))));
    return make_float3 (_S63, _S65, _S64);
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_2)
{
    float3  a_0 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S66 = (F32_abs((dot_0(n_2, a_0)))) > 0.9999847412109375f;
    float3  a_1;
    if(_S66)
    {
        float3  _S67 = make_float3 (1.0f, 0.0f, 0.0f);
        a_1 = _S67;
    }
    else
    {
        a_1 = a_0;
    }
    float3  _S68 = cross_0(n_2, a_1);
    float3  _S69 = ((((_S68)) * make_float3(rnorm3df(((_S68)).x, ((_S68)).y, ((_S68)).z))));
    float3  _S70 = cross_0(n_2, _S69);
    return make_float3 (v_0.x) * _S69 + make_float3 (v_0.y) * n_2 + make_float3 (v_0.z) * _S70;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
{
    float3  a_2 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S71 = (F32_abs((dot_0(n_3, a_2)))) > 0.9999847412109375f;
    float3  a_3;
    if(_S71)
    {
        float3  _S72 = make_float3 (1.0f, 0.0f, 0.0f);
        a_3 = _S72;
    }
    else
    {
        a_3 = a_2;
    }
    float3  _S73 = cross_0(n_3, a_3);
    float3  _S74 = ((((_S73)) * make_float3(rnorm3df(((_S73)).x, ((_S73)).y, ((_S73)).z))));
    float3  _S75 = cross_0(n_3, _S74);
    return make_float3 (dot_0(v_1, _S74), dot_0(v_1, n_3), dot_0(v_1, _S75));
}

static __device__ float3  negate_0(float3  x_14)
{
    return - x_14;
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_4)
{
    float3  _S76 = p1_0 - p0_0;
    float3  _S77 = p2_0 - p0_0;
    float2  _S78 = uv1_0 - uv0_0;
    float2  _S79 = uv2_0 - uv0_0;
    float _S80 = _S78.x;
    float _S81 = _S79.y;
    float _S82 = _S78.y;
    float _S83 = _S79.x;
    float _S84 = _S80 * _S81 - _S82 * _S83;
    float _S85 = 1.0f / _S84;
    float3  t_0 = (_S76 * make_float3 (_S81) - _S77 * make_float3 (_S82)) * make_float3 (_S85);
    float3  _S86 = (_S77 * make_float3 (_S80) - _S76 * make_float3 (_S83)) * make_float3 (_S85);
    float3  _S87 = t_0 - n_4 * make_float3 (dot_0(n_4, t_0));
    float3  _S88 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_4);
    bool _S89 = (dot_0(_S87, _S87)) > 0.0f;
    float3  _S90 = _slang_select(_S89, _S87,_S88);
    float3  _S91 = ((((_S90)) * make_float3(rnorm3df(((_S90)).x, ((_S90)).y, ((_S90)).z))));
    bool _S92 = (dot_0(cross_0(n_4, _S91), _S86)) > 0.0f;
    float3  t_1;
    if(_S92)
    {
        float3  _S93 = negate_0(_S91);
        t_1 = _S93;
    }
    else
    {
        t_1 = _S91;
    }
    float3  _S94 = cross_0(n_4, t_1);
    return makeMatrix<float, 3, 3> (t_1, _S94, n_4);
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

__device__ float3  sampleHalfVector(float3  v_3, float3  n_i_0, float alpha_3, uint * random_state_0)
{
    Random _S107 = pcg(*random_state_0);
    Random _S108 = pcg(_S107.state);
    *random_state_0 = _S108.state;
    float3  _S109 = worldToTangent(v_3, n_i_0);
    float3  _S110 = sampleGGXVNDF(float3 {_S109.x, _S109.z, _S109.y}, alpha_3, _S107.value, _S108.value);
    float3  _S111 = float3 {_S110.x, _S110.z, _S110.y};
    float3  _S112 = tangentToWorld(_S111, n_i_0);
    return _S112;
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

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_5, BSDFMaterial material_0, uint random_state_1)
{
    uint state_5 = random_state_1;
    float3  _S114 = negate_0(in_dir_0);
    float _S115 = sign_0(dot_0(n_5, _S114));
    float _S116 = material_0.roughness;
    float3  _S117 = sampleHalfVector(_S114, n_5 * make_float3 (_S115), _S116 * _S116, &state_5);
    return _S117;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_6, float eta_i_1, float eta_o_1)
{
    float3  _S118 = negate_0(in_dir_1);
    float3  _S119 = negate_0(make_float3 (eta_i_1) * _S118 + make_float3 (eta_o_1) * out_dir_0);
    float3  _S120 = ((((_S119)) * make_float3(rnorm3df(((_S119)).x, ((_S119)).y, ((_S119)).z))));
    float _S121 = sign_0(dot_0(n_6, _S118));
    float _S122 = sign_0(dot_0(_S119, n_6 * make_float3 (_S121)));
    return _S120 * make_float3 (_S122);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S123 = negate_0(in_dir_2);
    float3  _S124 = _S123 + out_dir_1;
    float3  _S125 = ((((_S124)) * make_float3(rnorm3df(((_S124)).x, ((_S124)).y, ((_S124)).z))));
    return _S125;
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

struct BSDFLobes
{
    float v_dot_h;
    float n_dot_h;
    float3  refracted;
    float3  F;
    float F_greyscale;
    float reflect_weight;
    float3  diffuse_weight;
    float3  refract_weight;
    float p_diffuse;
    float p_reflect;
    float p_refract;
};

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_1, float3  refracted_0, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0)
{
    BSDFLobes _S126;
    (&_S126)->v_dot_h = v_dot_h_0;
    (&_S126)->n_dot_h = n_dot_h_1;
    (&_S126)->refracted = refracted_0;
    (&_S126)->F = F_0;
    (&_S126)->F_greyscale = F_greyscale_0;
    (&_S126)->reflect_weight = reflect_weight_0;
    (&_S126)->diffuse_weight = diffuse_weight_0;
    (&_S126)->refract_weight = refract_weight_0;
    (&_S126)->p_diffuse = p_diffuse_0;
    (&_S126)->p_reflect = p_reflect_0;
    (&_S126)->p_refract = p_refract_0;
    return _S126;
}

__device__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_4, float3  n_i_1, float3  ggx_n_0, BSDFMaterial material_1, float eta_i_2, float eta_o_2)
{
    float _S127 = dot_0(ggx_n_0, v_4);
    float _S128 = dot_0(n_i_1, ggx_n_0);
    float _S129 = eta_i_2 / eta_o_2;
    float3  _S130 = refract_0(in_dir_3, ggx_n_0, _S129);
    float3  _S131 = ((((_S130)) * make_float3(rnorm3df(((_S130)).x, ((_S130)).y, ((_S130)).z))));
    float _S132 = (F32_min(((F32_sqrt((material_1.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S133 = _S132 * _S132;
    float _S134 = (1.0f + _S132) / (1.0f - _S132);
    float _S135 = (F32_abs((_S127)));
    bool _S136 = eta_i_2 > eta_o_2;
    float _S137;
    if(_S136)
    {
        _S137 = _S134;
    }
    else
    {
        _S137 = 1.0f;
    }
    float _S138;
    if(_S136)
    {
        _S138 = 1.0f;
    }
    else
    {
        _S138 = _S134;
    }
    float _S139 = fresnel(_S135, _S137, _S138);
    bool _S140 = (eta_i_2 * eta_i_2 * (1.0f - _S127 * _S127)) >= (eta_o_2 * eta_o_2);
    float3  _S141;
    if(_S140)
    {
        _S141 = make_float3 (1.0f);
    }
    else
    {
        float3  _S142 = material_1.specular_tint * make_float3 (_S133);
        _S141 = _S142 + (make_float3 (1.0f) - _S142) * make_float3 (_S139 - _S133) / make_float3 (1.0f - _S133);
    }
    float3  F_1 = mix_0(_S141, material_1.albedo, material_1.metallic);
    float _S143 = rgb_to_greyscale(F_1);
    float _S144 = 1.0f - material_1.metallic;
    float3  _S145 = make_float3 (1.0f) - _S141;
    float3  _S146 = make_float3 ((1.0f - material_1.transmission) * _S144) * _S145;
    float3  _S147 = make_float3 (material_1.transmission * _S144) * _S145;
    float _S148 = (F32_max((_S143), (0.0f)));
    float _S149 = rgb_to_greyscale(_S146);
    float _S150 = (F32_max((_S149), (0.0f)));
    float _S151 = rgb_to_greyscale(_S147);
    float _S152 = sign_0(length_0(_S131));
    float _S153 = (F32_max((_S151 * _S152), (0.0f)));
    float _S154 = _S148 + _S150 + _S153;
    float _S155 = 1.0f / (F32_max((_S154), (0.0000152587890625f)));
    float _S156 = _S150 * _S155;
    float _S157 = _S148 * _S155;
    float _S158 = _S153 * _S155;
    return BSDFLobes_x24init_0(_S127, _S128, _S131, F_1, _S143, 1.0f, _S146, _S147, _S156, _S157, _S158);
}

__device__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S159 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    bool _S160 = n_i_dot_v_0 > 0.0f;
    float _S161 = _slang_select(_S160, _S159,0.0f);
    return _S161;
}

__device__ float3  diffuseBSDF(float3  l_0, float3  n_i_2, float alpha_5, BSDFMaterial material_2, BSDFLobes lobes_1)
{
    return lobes_1.diffuse_weight * material_2.albedo / make_float3 (lobes_1.p_diffuse);
}

__device__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S162 = smithG1(alpha_6, n_i_dot_v_1);
    float _S163 = _S162 * lobes_2.v_dot_h;
    float _S164 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S165 = _S163 * _S164 / n_i_dot_v_1;
    bool _S166 = alpha_6 > 0.0f;
    bool _S167;
    if(_S166)
    {
        _S167 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S167 = false;
    }
    if(_S167)
    {
        _S167 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S167 = false;
    }
    if(_S167)
    {
        _S167 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S167 = false;
    }
    float _S168 = _slang_select(_S167, _S165,0.0f);
    return _S168;
}

__device__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S169 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S170 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S171 = lobes_3.p_refract * _S169 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S170 * _S170);
    bool _S172 = eta_i_4 != eta_o_4;
    bool _S173;
    if(_S172)
    {
        _S173 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S173 = false;
    }
    float _S174 = _slang_select(_S173, _S171,0.0f);
    return _S174;
}

__device__ float3  refractBSDF(float3  l_1, float3  n_i_3, float alpha_8, BSDFMaterial material_3, BSDFLobes lobes_4)
{
    float _S175 = - dot_0(n_i_3, l_1);
    float _S176 = smithG1(alpha_8, (F32_max((_S175), (0.0f))));
    return lobes_4.refract_weight * make_float3 (_S176) * material_3.albedo / make_float3 (lobes_4.p_refract);
}

__device__ float reflectPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S177 = vndfPDF(n_i_dot_v_3, alpha_9, lobes_5);
    float _S178 = lobes_5.p_reflect * _S177 / (4.0f * lobes_5.v_dot_h);
    bool _S179 = _S177 > 0.0f;
    float _S180 = _slang_select(_S179, _S178,0.0f);
    return _S180;
}

__device__ float3  reflectBSDF(float3  l_2, float3  n_i_4, float alpha_10, BSDFMaterial material_4, BSDFLobes lobes_6)
{
    float _S181 = dot_0(n_i_4, l_2);
    float _S182 = smithG1(alpha_10, (F32_max((_S181), (0.0f))));
    return make_float3 (lobes_6.reflect_weight * _S182) * lobes_6.F / make_float3 (lobes_6.p_reflect);
}

__device__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_5, float eta_i_6, float eta_o_6, bool refracted_1, uint random_state_2, FixedArray<float3 , 3>  * throughputs_0, FixedArray<float, 3>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S183 = negate_0(in_dir_4);
    float _S184 = dot_0(n_7, _S183);
    float _S185 = sign_0(_S184);
    float3  _S186 = n_7 * make_float3 (_S185);
    float _S187 = dot_0(_S186, out_dir_2);
    float _S188 = material_5.roughness;
    float _S189 = _S188 * _S188;
    uint i_10 = 0U;
    for(;;)
    {
        if(i_10 < 3U)
        {
        }
        else
        {
            break;
        }
        float3  _S190 = make_float3 (0.0f);
        (*throughputs_0)[i_10] = _S190;
        (*pdfs_0)[i_10] = 0.0f;
        uint i_11 = i_10 + 1U;
        i_10 = i_11;
    }
    float3  _S191 = make_float3 (0.0f);
    BSDFLobes _S192 = BSDFLobes_x24init_0(0.0f, 0.0f, _S191, _S191, 0.0f, 0.0f, _S191, _S191, 0.0f, 0.0f, 0.0f);
    uint half_of_0 = 4294967295U;
    BSDFLobes lobe_terms_0 = _S192;
    float3  ggx_n_2 = _S191;
    i_10 = 0U;
    for(;;)
    {
        if(i_10 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S193 = i_10 == 1U;
        bool _S194 = _S193 != refracted_1;
        if(_S194)
        {
            ggx_n_1 = ggx_n_2;
            uint i_12 = i_10 + 1U;
            ggx_n_2 = ggx_n_1;
            i_10 = i_12;
            continue;
        }
        bool _S195 = i_10 != half_of_0;
        uint half_of_1;
        BSDFLobes lobe_terms_1;
        if(_S195)
        {
            bool _S196 = i_10 == 0U;
            if(_S196)
            {
                float3  _S197 = sampledHalf(in_dir_4, n_7, material_5, random_state_2);
                ggx_n_1 = _S197;
            }
            else
            {
                if(_S193)
                {
                    float3  _S198 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_6, eta_o_6);
                    ggx_n_1 = _S198;
                }
                else
                {
                    float3  _S199 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S199;
                }
            }
            float3  _S200 = negate_0(in_dir_4);
            BSDFLobes _S201 = bsdfLobes(in_dir_4, _S200, _S186, ggx_n_1, material_5, eta_i_6, eta_o_6);
            lobe_terms_1 = _S201;
            half_of_1 = i_10;
        }
        else
        {
            lobe_terms_1 = lobe_terms_0;
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(i_10)
        {
        case 0U:
            {
                float _S202 = diffusePDF(_S187, 0.0f, (F32_abs((_S184))), _S189, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[int(0)] = _S202;
                float3  _S203 = diffuseBSDF(out_dir_2, _S186, _S189, material_5, lobe_terms_1);
                (*throughputs_0)[int(0)] = _S203;
                break;
            }
        case 1U:
            {
                float _S204 = refractPDF(_S187, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S184))), _S189, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[int(1)] = _S204;
                float3  _S205 = refractBSDF(out_dir_2, _S186, _S189, material_5, lobe_terms_1);
                (*throughputs_0)[int(1)] = _S205;
                break;
            }
        default:
            {
                float _S206 = reflectPDF(_S187, 0.0f, (F32_abs((_S184))), _S189, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[int(2)] = _S206;
                float3  _S207 = reflectBSDF(out_dir_2, _S186, _S189, material_5, lobe_terms_1);
                (*throughputs_0)[int(2)] = _S207;
                break;
            }
        }
        half_of_0 = half_of_1;
        lobe_terms_0 = lobe_terms_1;
        uint i_12 = i_10 + 1U;
        ggx_n_2 = ggx_n_1;
        i_10 = i_12;
    }
    i_10 = 0U;
    ggx_n_1 = _S191;
    for(;;)
    {
        if(i_10 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S208 = ((*pdfs_0)[i_10]) > 0.0f;
        if(_S208)
        {
            float3  f_0 = ggx_n_1 + (*throughputs_0)[i_10] * make_float3 ((*pdfs_0)[i_10]);
            ggx_n_1 = f_0;
        }
        uint i_13 = i_10 + 1U;
        i_10 = i_13;
    }
    return ggx_n_1;
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

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_0, float3  throughput_0, uint random_state_3, bool refracted_2, uint lobe_0, float pdf_0)
{
    SampleBSDF _S209;
    (&_S209)->unit_direction = unit_direction_0;
    (&_S209)->throughput = throughput_0;
    (&_S209)->random_state = random_state_3;
    (&_S209)->refracted = refracted_2;
    (&_S209)->lobe = lobe_0;
    (&_S209)->pdf = pdf_0;
    return _S209;
}

__device__ SampleBSDF diffuseSample(float3  n_i_5, float n_i_dot_v_4, float alpha_11, BSDFMaterial material_6, BSDFLobes lobes_7, float eta_i_7, float eta_o_7, uint random_state_4)
{
    float3  _S210 = make_float3 (1.0f);
    SampleBSDF _S211 = SampleBSDF_x24init_0(_S210, _S210, 0U, false, 0U, 0.0f);
    SampleBSDF sample_0 = _S211;
    Random _S212 = pcg(random_state_4);
    Random _S213 = pcg(_S212.state);
    (&sample_0)->random_state = _S213.state;
    float3  _S214 = sampleCosWeightedHemisphere(_S212.value, _S213.value);
    float3  _S215 = tangentToWorld(_S214, n_i_5);
    (&sample_0)->unit_direction = _S215;
    (&sample_0)->lobe = 0U;
    float3  _S216 = diffuseBSDF((&sample_0)->unit_direction, n_i_5, alpha_11, material_6, lobes_7);
    (&sample_0)->throughput = _S216;
    float _S217 = diffusePDF(_S214.y, 0.0f, n_i_dot_v_4, alpha_11, lobes_7, eta_i_7, eta_o_7);
    (&sample_0)->pdf = _S217;
    return sample_0;
}

__device__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_6, float n_i_dot_v_5, float alpha_12, BSDFMaterial material_7, BSDFLobes lobes_8, float eta_i_8, float eta_o_8, uint random_state_5)
{
    float3  _S218 = make_float3 (1.0f);
    SampleBSDF _S219 = SampleBSDF_x24init_0(_S218, _S218, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S219;
    (&sample_1)->unit_direction = lobes_8.refracted;
    (&sample_1)->random_state = random_state_5;
    (&sample_1)->refracted = true;
    (&sample_1)->lobe = 1U;
    float3  _S220 = refractBSDF((&sample_1)->unit_direction, n_i_6, alpha_12, material_7, lobes_8);
    (&sample_1)->throughput = _S220;
    float _S221 = refractPDF(0.0f, dot_0((&sample_1)->unit_direction, ggx_n_3), n_i_dot_v_5, alpha_12, lobes_8, eta_i_8, eta_o_8);
    (&sample_1)->pdf = _S221;
    return sample_1;
}

__device__ SampleBSDF reflectSample(float3  in_dir_5, float3  ggx_n_4, float3  n_i_7, float n_i_dot_v_6, float alpha_13, BSDFMaterial material_8, BSDFLobes lobes_9, float eta_i_9, float eta_o_9, uint random_state_6)
{
    float3  _S222 = make_float3 (1.0f);
    SampleBSDF _S223 = SampleBSDF_x24init_0(_S222, _S222, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S223;
    float3  _S224 = reflect_0(in_dir_5, ggx_n_4);
    float3  _S225 = ((((_S224)) * make_float3(rnorm3df(((_S224)).x, ((_S224)).y, ((_S224)).z))));
    (&sample_2)->unit_direction = _S225;
    (&sample_2)->random_state = random_state_6;
    (&sample_2)->lobe = 2U;
    float3  _S226 = reflectBSDF((&sample_2)->unit_direction, n_i_7, alpha_13, material_8, lobes_9);
    (&sample_2)->throughput = _S226;
    float _S227 = reflectPDF(0.0f, 0.0f, n_i_dot_v_6, alpha_13, lobes_9, eta_i_9, eta_o_9);
    (&sample_2)->pdf = _S227;
    return sample_2;
}

__device__ SampleBSDF sampleBSDF(float3  in_dir_6, float3  n_8, BSDFMaterial material_9, float eta_i_10, float eta_o_10, uint random_init_0, float2  screen_space_0)
{
    uint random_state_7 = random_init_0;
    float3  _S228 = negate_0(in_dir_6);
    float _S229 = dot_0(n_8, _S228);
    float _S230 = sign_0(_S229);
    float3  n_i_8 = n_8 * make_float3 (_S230);
    float _S231 = (F32_abs((_S229)));
    float _S232 = material_9.roughness;
    float _S233 = _S232 * _S232;
    float3  _S234 = sampleHalfVector(_S228, n_i_8, _S233, &random_state_7);
    BSDFLobes _S235 = bsdfLobes(in_dir_6, _S228, n_i_8, _S234, material_9, eta_i_10, eta_o_10);
    Random _S236 = pcg(random_state_7);
    random_state_7 = _S236.state;
    bool _S237 = (_S236.value) < (_S235.p_diffuse);
    if(_S237)
    {
        SampleBSDF _S238 = diffuseSample(n_i_8, _S231, _S233, material_9, _S235, eta_i_10, eta_o_10, random_state_7);
        return _S238;
    }
    bool _S239 = (_S236.value) < (_S235.p_diffuse + _S235.p_refract);
    if(_S239)
    {
        SampleBSDF _S240 = refractSample(_S234, n_i_8, _S231, _S233, material_9, _S235, eta_i_10, eta_o_10, random_state_7);
        return _S240;
    }
    SampleBSDF _S241 = reflectSample(in_dir_6, _S234, n_i_8, _S231, _S233, material_9, _S235, eta_i_10, eta_o_10, random_state_7);
    return _S241;
}

__device__ float3  pointLightRadiance(float3  color_0, float intensity_0, float radius_0)
{
    return color_0 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_0 * radius_0);
}

__device__ float3  beerLambert(float distance_1, float3  absorption_0)
{
    float3  _S242 = max_0(absorption_0, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_1) * log_0(_S242));
}

__device__ bool neeDecision(BSDFMaterial material_10, float n_dot_v_0, float eta_i_11, float eta_o_11)
{
    float _S243 = fresnel((F32_abs((n_dot_v_0))), eta_i_11, eta_o_11);
    float3  _S244 = mix_0(make_float3 (_S243), material_10.albedo, material_10.metallic);
    float _S245 = rgb_to_greyscale(_S244);
    float _S246 = (F32_max(((1.0f - _S245) * (1.0f - material_10.metallic) * (1.0f - material_10.transmission)), (0.0f)));
    bool _S247 = _S246 > 0.03999999910593033f;
    bool _S248;
    if(_S247)
    {
        _S248 = true;
    }
    else
    {
        _S248 = (material_10.roughness) > 0.20000000298023224f;
    }
    return _S248;
}

__device__ float3  straightThrough(BSDFMaterial material_11)
{
    return make_float3 (material_11.transmission * (1.0f - material_11.metallic)) * material_11.albedo;
}

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_0, float3  end_0)
{
    float _S249 = sign_0(dot_0(light_n_0, start_0 - end_0));
    return light_n_0 * make_float3 (_S249 * light_offset_0);
}

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

__device__ float3  occluderTransmittance(float3  toward_0, float3  n_9, BSDFMaterial material_12, float coverage_0)
{
    float3  _S250;
    if((material_12.ior) == 1.0f)
    {
        float3  _S251 = straightThrough(material_12);
        _S250 = _S251;
    }
    else
    {
        _S250 = make_float3 (0.0f);
    }
    return _S250 * make_float3 (coverage_0) + make_float3 (1.0f - coverage_0);
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S252 = hash(index_0);
    uint _S253 = hash(seed_0 ^ _S252);
    return _S253;
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float3  _S254 = a_4 / b_0;
    float3  _S255 = make_float3 (0.0f);
    bool3  _S256 = b_0 == _S255;
    float3  _S257 = _slang_select(_S256, _S255,_S254);
    return _S257;
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
    float _S258 = rgb_to_greyscale(weight_0);
    bool _S259 = _S258 > 0.0f;
    bool _S260;
    if(_S259)
    {
        _S260 = _S258 < 3.00000000549775576e+38f;
    }
    else
    {
        _S260 = false;
    }
    bool _S261 = !_S260;
    if(_S261)
    {
        return;
    }
    float _S262 = sel_0->w_sum + _S258;
    sel_0->w_sum = _S262;
    float3  _S263 = sel_0->color + weight_0;
    sel_0->color = _S263;
    Random _S264 = pcg(sel_0->random_state);
    sel_0->random_state = _S264.state;
    bool _S265 = (_S264.value * sel_0->w_sum) <= _S258;
    if(_S265)
    {
        sel_0->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_1, Reservoir r_0, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_0;
    float3  _S266 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S266;
    float _S267 = r_0.jac * shifted_0.jac;
    (&candidate_1)->jac = _S267;
    offer(sel_1, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_0.w));
    return;
}

__device__ Reservoir finalize(Selection sel_2, float c_0)
{
    Reservoir r_1 = sel_2.r;
    float _S268 = rgb_to_greyscale((&r_1)->f);
    float _S269 = sel_2.w_sum / _S268;
    bool _S270 = _S268 > 0.0f;
    float _S271 = _slang_select(_S270, _S269,0.0f);
    (&r_1)->w = _S271;
    (&r_1)->c = c_0;
    return r_1;
}

static __device__ uint insertBits_0(uint e_1, uint newbits_0, uint offset_0, uint count_0)
{
    uint _S272 = (1U << count_0) - 1U;
    return (e_1 & (~(_S272 << offset_0))) | ((newbits_0 & _S272) << offset_0);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_1, float3  f_1)
{
    Reservoir candidate_2 = r_2;
    uint _S273 = insertBits_0(r_2.path, end_1, 0U, 5U);
    uint _S274 = insertBits_0(_S273, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S274;
    (&candidate_2)->f = f_1;
    return candidate_2;
}

__device__ float facingSign(float transmission_0, float3  face_0, float3  direction_0)
{
    bool _S275 = transmission_0 > 0.0f;
    bool _S276;
    if(_S275)
    {
        _S276 = true;
    }
    else
    {
        _S276 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S277;
    if(_S276)
    {
        _S277 = 1.0f;
    }
    else
    {
        _S277 = -1.0f;
    }
    return _S277;
}

__device__ float survivalProbability(float3  throughput_1, float density_0)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_0), (0.0f)))), (1.0f)));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S278 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S279 = cos_a_0 > cos_b_0;
    float _S280 = _slang_select(_S279, 1.0f,_S278);
    return _S280;
}

__device__ float sine(float c_1)
{
    return (F32_sqrt(((F32_max((1.0f - c_1 * c_1), (0.0f))))));
}

__device__ float importance(LightNode node_0, float3  p_0, float3  normal_0)
{
    float3  _S281 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S282 = node_0.high - node_0.low;
    float3  _S283 = p_0 - _S281;
    float3  _S284 = ((((_S283)) * make_float3(rnorm3df(((_S283)).x, ((_S283)).y, ((_S283)).z))));
    float _S285 = dot_0(_S283, _S283);
    float _S286 = dot_0(_S282, _S282) / 4.0f;
    float _S287 = (F32_abs((dot_0(node_0.w, _S284))));
    float _S288 = sine(node_0.cos_theta_o);
    float _S289 = (F32_sqrt(((F32_max((1.0f - _S286 / _S285), (0.0f))))));
    bool _S290 = _S285 < _S286;
    float _S291 = _slang_select(_S290, -1.0f,_S289);
    float _S292 = sine(_S291);
    float _S293 = sine(_S287);
    float _S294 = cosSubClamped(_S293, _S287, _S288, node_0.cos_theta_o);
    float _S295 = sine(_S287);
    float _S296 = _S295 * node_0.cos_theta_o - _S287 * _S288;
    bool _S297 = _S287 > (node_0.cos_theta_o);
    float _S298 = _slang_select(_S297, 0.0f,_S296);
    float _S299 = cosSubClamped(_S298, _S294, _S292, _S291);
    bool _S300 = _S299 <= 0.0f;
    if(_S300)
    {
        return 0.0f;
    }
    float _S301 = - dot_0(_S284, normal_0);
    float _S302 = node_0.phi * _S299 / (F32_max((_S285), (length_0(_S282) / 2.0f)));
    float _S303 = sine(_S301);
    float _S304 = cosSubClamped(_S303, _S301, _S292, _S291);
    bool _S305 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S306 = _slang_select(_S305, 1.0f,_S304);
    return (F32_max((_S302 * _S306), (0.0f)));
}

__device__ float solidAngle(float probability_0, float3  normal_1, float3  toward_1)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_1)), (3.0f))) / (F32_abs((dot_0(normal_1, toward_1))));
}

__device__ uint pickChild(LightNode first_0, LightNode second_0, float3  p_1, float3  normal_2, float * pick_0, float * probability_1)
{
    float _S307 = importance(first_0, p_1, normal_2);
    float _S308 = importance(second_0, p_1, normal_2);
    float2  _S309 = make_float2 (_S307, _S308);
    bool _S310 = _S307 == 0.0f;
    bool _S311;
    if(_S310)
    {
        _S311 = _S308 == 0.0f;
    }
    else
    {
        _S311 = false;
    }
    if(_S311)
    {
        return 2U;
    }
    float _S312 = _S307 + _S308;
    bool _S313 = _S308 > 0.0f;
    if(_S313)
    {
        _S311 = (*pick_0 * _S312) >= _S307;
    }
    else
    {
        _S311 = false;
    }
    uint _S314 = uint(_S311);
    float _S315 = (F32_min(((*pick_0 * _S312 - float(_S314) * _S307) / _slang_vector_get_element(_S309, _S314)), (0.99999994039535522f)));
    *pick_0 = _S315;
    float _S316 = *probability_1 * (_slang_vector_get_element(_S309, _S314) / _S312);
    *probability_1 = _S316;
    return _S314;
}

__device__ float childShare(LightNode first_1, LightNode second_1, float3  p_2, float3  normal_3, uint child_0)
{
    float _S317 = importance(first_1, p_2, normal_3);
    float _S318 = importance(second_1, p_2, normal_3);
    float2  _S319 = make_float2 (_S317, _S318);
    float _S320 = _slang_vector_get_element(_S319, child_0) / (_S317 + _S318);
    bool _S321 = _slang_vector_get_element(_S319, child_0) > 0.0f;
    float _S322 = _slang_select(_S321, _S320,0.0f);
    return _S322;
}

__device__ float powerHeuristic(float a_5, float b_1)
{
    float _S323 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    bool _S324 = b_1 > 0.0f;
    float _S325 = _slang_select(_S324, _S323,1.0f);
    return _S325;
}

__device__ float sphereDensity(float3  center_0, float radius_1, float3  p_3)
{
    float3  _S326 = center_0 - p_3;
    float _S327 = radius_1 * radius_1 / dot_0(_S326, _S326);
    bool _S328 = _S327 >= 1.0f;
    if(_S328)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S327)))) / (6.28318548202514648f * _S327);
}

__device__ float3  sampleSphere(float3  center_1, float radius_2, float3  p_4, float u1_0, float u2_0)
{
    float3  _S329 = center_1 - p_4;
    float _S330 = radius_2 * radius_2 / dot_0(_S329, _S329);
    float _S331 = u1_0 * _S330 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S330), (0.0f)))))));
    float _S332 = 2.0f * u1_0;
    bool _S333 = _S330 >= 1.0f;
    float _S334 = _slang_select(_S333, _S332,_S331);
    float _S335 = (F32_sqrt(((F32_max((_S334 * (2.0f - _S334)), (0.0f))))));
    float _S336 = 6.28318548202514648f * u2_0;
    float3  _S337 = make_float3 (_S335 * (F32_cos((_S336))), 1.0f - _S334, _S335 * (F32_sin((_S336))));
    float3  _S338 = ((((_S329)) * make_float3(rnorm3df(((_S329)).x, ((_S329)).y, ((_S329)).z))));
    float3  _S339 = tangentToWorld(_S337, _S338);
    return _S339;
}

#undef Matrix
