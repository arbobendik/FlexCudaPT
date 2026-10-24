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
    float translucent_share;
};

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_1, float3  refracted_0, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_0)
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
    (&_S126)->translucent_share = translucent_share_0;
    return _S126;
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_4, float3  n_i_1, float3  ggx_n_0, BSDFMaterial material_1, float eta_i_2, float eta_o_2)
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
    return BSDFLobes_x24init_0(_S127, _S128, _S131, F_1, _S143, 1.0f, _S146, _S147, _S156, _S157, _S158, 0.0f);
}

__device__ float translucentShare(BSDFMaterial material_2)
{
    float _S159 = rgb_to_greyscale(material_2.translucent);
    float _S160 = rgb_to_greyscale(material_2.albedo);
    float _S161 = _S159 / (_S160 + _S159);
    bool _S162 = _S159 > 0.0f;
    float _S163 = _slang_select(_S162, _S161,0.0f);
    return _S163;
}

__device__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S164 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S165 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S166 = 1.0f - lobes_0.translucent_share;
    bool _S167 = n_i_dot_l_0 < 0.0f;
    float _S168 = _slang_select(_S167, lobes_0.translucent_share,_S166);
    float _S169 = _S165 * _S168;
    bool _S170 = (lobes_0.translucent_share) > 0.0f;
    float _S171 = _slang_select(_S170, _S169,_S164);
    bool _S172 = n_i_dot_v_0 > 0.0f;
    float _S173 = _slang_select(_S172, _S171,0.0f);
    return _S173;
}

__device__ float3  diffuseBSDF(float3  l_0, float3  n_i_2, float alpha_5, BSDFMaterial material_3, BSDFLobes lobes_1)
{
    bool _S174 = (dot_0(n_i_2, l_0)) < 0.0f;
    float3  _S175 = _slang_select(_S174, material_3.translucent,material_3.albedo);
    float _S176 = 1.0f - lobes_1.translucent_share;
    float _S177 = _slang_select(_S174, lobes_1.translucent_share,_S176);
    float3  _S178 = _S175 / make_float3 (_S177);
    bool _S179 = (lobes_1.translucent_share) > 0.0f;
    float3  _S180 = _slang_select(_S179, _S178,material_3.albedo);
    return lobes_1.diffuse_weight * _S180 / make_float3 (lobes_1.p_diffuse);
}

__device__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S181 = smithG1(alpha_6, n_i_dot_v_1);
    float _S182 = _S181 * lobes_2.v_dot_h;
    float _S183 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S184 = _S182 * _S183 / n_i_dot_v_1;
    bool _S185 = alpha_6 > 0.0f;
    bool _S186;
    if(_S185)
    {
        _S186 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S186 = false;
    }
    if(_S186)
    {
        _S186 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S186 = false;
    }
    if(_S186)
    {
        _S186 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S186 = false;
    }
    float _S187 = _slang_select(_S186, _S184,0.0f);
    return _S187;
}

__device__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S188 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S189 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S190 = lobes_3.p_refract * _S188 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S189 * _S189);
    bool _S191 = eta_i_4 != eta_o_4;
    bool _S192;
    if(_S191)
    {
        _S192 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S192 = false;
    }
    float _S193 = _slang_select(_S192, _S190,0.0f);
    return _S193;
}

__device__ float3  refractBSDF(float3  l_1, float3  n_i_3, float alpha_8, BSDFMaterial material_4, BSDFLobes lobes_4)
{
    float _S194 = - dot_0(n_i_3, l_1);
    float _S195 = smithG1(alpha_8, (F32_max((_S194), (0.0f))));
    return lobes_4.refract_weight * make_float3 (_S195) * material_4.albedo / make_float3 (lobes_4.p_refract);
}

__device__ float reflectPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S196 = vndfPDF(n_i_dot_v_3, alpha_9, lobes_5);
    float _S197 = lobes_5.p_reflect * _S196 / (4.0f * lobes_5.v_dot_h);
    bool _S198 = _S196 > 0.0f;
    float _S199 = _slang_select(_S198, _S197,0.0f);
    return _S199;
}

__device__ float3  reflectBSDF(float3  l_2, float3  n_i_4, float alpha_10, BSDFMaterial material_5, BSDFLobes lobes_6)
{
    float _S200 = dot_0(n_i_4, l_2);
    float _S201 = smithG1(alpha_10, (F32_max((_S200), (0.0f))));
    return make_float3 (lobes_6.reflect_weight * _S201) * lobes_6.F / make_float3 (lobes_6.p_reflect);
}

__device__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_6, float eta_i_6, float eta_o_6, bool refracted_1, uint random_state_2, FixedArray<float3 , 3>  * throughputs_0, FixedArray<float, 3>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S202 = negate_0(in_dir_4);
    float _S203 = dot_0(n_7, _S202);
    float _S204 = sign_0(_S203);
    float3  _S205 = n_7 * make_float3 (_S204);
    float _S206 = dot_0(_S205, out_dir_2);
    float _S207 = material_6.roughness;
    float _S208 = _S207 * _S207;
    float _S209 = rgb_to_greyscale(material_6.translucent);
    bool _S210 = _S209 > 0.0f;
    bool _S211 = (dot_0(n_7, out_dir_2) * _S203) < 0.0f;
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
        float3  _S212 = make_float3 (0.0f);
        (*throughputs_0)[i_10] = _S212;
        (*pdfs_0)[i_10] = 0.0f;
        uint i_11 = i_10 + 1U;
        i_10 = i_11;
    }
    float3  _S213 = make_float3 (0.0f);
    BSDFLobes _S214 = BSDFLobes_x24init_0(0.0f, 0.0f, _S213, _S213, 0.0f, 0.0f, _S213, _S213, 0.0f, 0.0f, 0.0f, 0.0f);
    BSDFLobes lobe_terms_0 = _S214;
    uint half_of_0 = 4294967295U;
    float3  ggx_n_2 = _S213;
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
        bool _S215 = i_10 == 0U;
        bool _S216;
        if(_S215)
        {
            _S216 = _S210;
        }
        else
        {
            _S216 = false;
        }
        bool _S217;
        if(_S216)
        {
            _S217 = _S211;
        }
        else
        {
            _S217 = i_10 == 1U;
        }
        bool _S218 = _S217 != refracted_1;
        if(_S218)
        {
            ggx_n_1 = ggx_n_2;
            uint i_12 = i_10 + 1U;
            ggx_n_2 = ggx_n_1;
            i_10 = i_12;
            continue;
        }
        bool _S219 = i_10 != half_of_0;
        uint half_of_1;
        if(_S219)
        {
            if(_S215)
            {
                float3  _S220 = sampledHalf(in_dir_4, n_7, material_6, random_state_2);
                ggx_n_1 = _S220;
            }
            else
            {
                bool _S221 = i_10 == 1U;
                if(_S221)
                {
                    float3  _S222 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_6, eta_o_6);
                    ggx_n_1 = _S222;
                }
                else
                {
                    float3  _S223 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S223;
                }
            }
            float3  _S224 = negate_0(in_dir_4);
            BSDFLobes _S225 = bsdfLobes(in_dir_4, _S224, _S205, ggx_n_1, material_6, eta_i_6, eta_o_6);
            lobe_terms_0 = _S225;
            float _S226 = translucentShare(material_6);
            (&lobe_terms_0)->translucent_share = _S226;
            half_of_1 = i_10;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(i_10)
        {
        case 0U:
            {
                float _S227 = diffusePDF(_S206, 0.0f, (F32_abs((_S203))), _S208, lobe_terms_0, eta_i_6, eta_o_6);
                (*pdfs_0)[int(0)] = _S227;
                float3  _S228 = diffuseBSDF(out_dir_2, _S205, _S208, material_6, lobe_terms_0);
                (*throughputs_0)[int(0)] = _S228;
                break;
            }
        case 1U:
            {
                float _S229 = refractPDF(_S206, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S203))), _S208, lobe_terms_0, eta_i_6, eta_o_6);
                (*pdfs_0)[int(1)] = _S229;
                float3  _S230 = refractBSDF(out_dir_2, _S205, _S208, material_6, lobe_terms_0);
                (*throughputs_0)[int(1)] = _S230;
                break;
            }
        default:
            {
                float _S231 = reflectPDF(_S206, 0.0f, (F32_abs((_S203))), _S208, lobe_terms_0, eta_i_6, eta_o_6);
                (*pdfs_0)[int(2)] = _S231;
                float3  _S232 = reflectBSDF(out_dir_2, _S205, _S208, material_6, lobe_terms_0);
                (*throughputs_0)[int(2)] = _S232;
                break;
            }
        }
        half_of_0 = half_of_1;
        uint i_12 = i_10 + 1U;
        ggx_n_2 = ggx_n_1;
        i_10 = i_12;
    }
    i_10 = 0U;
    ggx_n_1 = _S213;
    for(;;)
    {
        if(i_10 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S233 = ((*pdfs_0)[i_10]) > 0.0f;
        if(_S233)
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
    SampleBSDF _S234;
    (&_S234)->unit_direction = unit_direction_0;
    (&_S234)->throughput = throughput_0;
    (&_S234)->random_state = random_state_3;
    (&_S234)->refracted = refracted_2;
    (&_S234)->lobe = lobe_0;
    (&_S234)->pdf = pdf_0;
    return _S234;
}

__device__ SampleBSDF diffuseSample(float u_0, float3  n_i_5, float n_i_dot_v_4, float alpha_11, BSDFMaterial material_7, BSDFLobes lobes_7, float eta_i_7, float eta_o_7, uint random_state_4)
{
    float3  _S235 = make_float3 (1.0f);
    SampleBSDF _S236 = SampleBSDF_x24init_0(_S235, _S235, 0U, false, 0U, 0.0f);
    SampleBSDF sample_0 = _S236;
    Random _S237 = pcg(random_state_4);
    Random _S238 = pcg(_S237.state);
    (&sample_0)->random_state = _S238.state;
    float3  _S239 = sampleCosWeightedHemisphere(_S237.value, _S238.value);
    bool _S240 = u_0 < (lobes_7.p_diffuse * lobes_7.translucent_share);
    float _S241 = _S239.y;
    float _S242 = - _S241;
    float _S243 = _slang_select(_S240, _S242,_S241);
    float3  _S244 = tangentToWorld(make_float3 (_S239.x, _S243, _S239.z), n_i_5);
    (&sample_0)->unit_direction = _S244;
    (&sample_0)->refracted = _S240;
    (&sample_0)->lobe = 0U;
    float3  _S245 = diffuseBSDF((&sample_0)->unit_direction, n_i_5, alpha_11, material_7, lobes_7);
    (&sample_0)->throughput = _S245;
    float _S246 = diffusePDF(_S243, 0.0f, n_i_dot_v_4, alpha_11, lobes_7, eta_i_7, eta_o_7);
    (&sample_0)->pdf = _S246;
    return sample_0;
}

__device__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_6, float n_i_dot_v_5, float alpha_12, BSDFMaterial material_8, BSDFLobes lobes_8, float eta_i_8, float eta_o_8, uint random_state_5)
{
    float3  _S247 = make_float3 (1.0f);
    SampleBSDF _S248 = SampleBSDF_x24init_0(_S247, _S247, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S248;
    (&sample_1)->unit_direction = lobes_8.refracted;
    (&sample_1)->random_state = random_state_5;
    (&sample_1)->refracted = true;
    (&sample_1)->lobe = 1U;
    float3  _S249 = refractBSDF((&sample_1)->unit_direction, n_i_6, alpha_12, material_8, lobes_8);
    (&sample_1)->throughput = _S249;
    float _S250 = refractPDF(0.0f, dot_0((&sample_1)->unit_direction, ggx_n_3), n_i_dot_v_5, alpha_12, lobes_8, eta_i_8, eta_o_8);
    (&sample_1)->pdf = _S250;
    return sample_1;
}

__device__ SampleBSDF reflectSample(float3  in_dir_5, float3  ggx_n_4, float3  n_i_7, float n_i_dot_v_6, float alpha_13, BSDFMaterial material_9, BSDFLobes lobes_9, float eta_i_9, float eta_o_9, uint random_state_6)
{
    float3  _S251 = make_float3 (1.0f);
    SampleBSDF _S252 = SampleBSDF_x24init_0(_S251, _S251, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S252;
    float3  _S253 = reflect_0(in_dir_5, ggx_n_4);
    float3  _S254 = ((((_S253)) * make_float3(rnorm3df(((_S253)).x, ((_S253)).y, ((_S253)).z))));
    (&sample_2)->unit_direction = _S254;
    (&sample_2)->random_state = random_state_6;
    (&sample_2)->lobe = 2U;
    float3  _S255 = reflectBSDF((&sample_2)->unit_direction, n_i_7, alpha_13, material_9, lobes_9);
    (&sample_2)->throughput = _S255;
    float _S256 = reflectPDF(0.0f, 0.0f, n_i_dot_v_6, alpha_13, lobes_9, eta_i_9, eta_o_9);
    (&sample_2)->pdf = _S256;
    return sample_2;
}

__device__ SampleBSDF sampleBSDF(float3  in_dir_6, float3  n_8, BSDFMaterial material_10, float eta_i_10, float eta_o_10, uint random_init_0, float2  screen_space_0)
{
    uint random_state_7 = random_init_0;
    float3  _S257 = negate_0(in_dir_6);
    float _S258 = dot_0(n_8, _S257);
    float _S259 = sign_0(_S258);
    float3  n_i_8 = n_8 * make_float3 (_S259);
    float _S260 = (F32_abs((_S258)));
    float _S261 = material_10.roughness;
    float _S262 = _S261 * _S261;
    float3  _S263 = sampleHalfVector(_S257, n_i_8, _S262, &random_state_7);
    BSDFLobes _S264 = bsdfLobes(in_dir_6, _S257, n_i_8, _S263, material_10, eta_i_10, eta_o_10);
    BSDFLobes lobes_10 = _S264;
    float _S265 = translucentShare(material_10);
    (&lobes_10)->translucent_share = _S265;
    Random _S266 = pcg(random_state_7);
    random_state_7 = _S266.state;
    bool _S267 = (_S266.value) < ((&lobes_10)->p_diffuse);
    if(_S267)
    {
        SampleBSDF _S268 = diffuseSample(_S266.value, n_i_8, _S260, _S262, material_10, lobes_10, eta_i_10, eta_o_10, random_state_7);
        return _S268;
    }
    bool _S269 = (_S266.value) < ((&lobes_10)->p_diffuse + (&lobes_10)->p_refract);
    if(_S269)
    {
        SampleBSDF _S270 = refractSample(_S263, n_i_8, _S260, _S262, material_10, lobes_10, eta_i_10, eta_o_10, random_state_7);
        return _S270;
    }
    SampleBSDF _S271 = reflectSample(in_dir_6, _S263, n_i_8, _S260, _S262, material_10, lobes_10, eta_i_10, eta_o_10, random_state_7);
    return _S271;
}

__device__ float3  pointLightRadiance(float3  color_0, float intensity_0, float radius_0)
{
    return color_0 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_0 * radius_0);
}

__device__ float3  beerLambert(float distance_1, float3  absorption_0)
{
    float3  _S272 = max_0(absorption_0, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_1) * log_0(_S272));
}

__device__ bool neeDecision(BSDFMaterial material_11, float n_dot_v_0, float eta_i_11, float eta_o_11)
{
    float _S273 = fresnel((F32_abs((n_dot_v_0))), eta_i_11, eta_o_11);
    float3  _S274 = mix_0(make_float3 (_S273), material_11.albedo, material_11.metallic);
    float _S275 = rgb_to_greyscale(_S274);
    float _S276 = (F32_max(((1.0f - _S275) * (1.0f - material_11.metallic) * (1.0f - material_11.transmission)), (0.0f)));
    bool _S277 = _S276 > 0.03999999910593033f;
    bool _S278;
    if(_S277)
    {
        _S278 = true;
    }
    else
    {
        _S278 = (material_11.roughness) > 0.20000000298023224f;
    }
    return _S278;
}

__device__ float3  straightThrough(BSDFMaterial material_12)
{
    return make_float3 (material_12.transmission * (1.0f - material_12.metallic)) * material_12.albedo;
}

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_0, float3  end_0)
{
    float _S279 = sign_0(dot_0(light_n_0, start_0 - end_0));
    return light_n_0 * make_float3 (_S279 * light_offset_0);
}

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

__device__ float3  occluderTransmittance(float3  toward_0, float3  n_9, BSDFMaterial material_13, float coverage_0)
{
    float3  _S280;
    if((material_13.ior) == 1.0f)
    {
        float3  _S281 = straightThrough(material_13);
        _S280 = _S281;
    }
    else
    {
        _S280 = make_float3 (0.0f);
    }
    return _S280 * make_float3 (coverage_0) + make_float3 (1.0f - coverage_0);
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S282 = hash(index_0);
    uint _S283 = hash(seed_0 ^ _S282);
    return _S283;
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float3  _S284 = a_4 / b_0;
    float3  _S285 = make_float3 (0.0f);
    bool3  _S286 = b_0 == _S285;
    float3  _S287 = _slang_select(_S286, _S285,_S284);
    return _S287;
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
    float _S288 = rgb_to_greyscale(weight_0);
    bool _S289 = _S288 > 0.0f;
    bool _S290;
    if(_S289)
    {
        _S290 = _S288 < 3.00000000549775576e+38f;
    }
    else
    {
        _S290 = false;
    }
    bool _S291 = !_S290;
    if(_S291)
    {
        return;
    }
    float _S292 = sel_0->w_sum + _S288;
    sel_0->w_sum = _S292;
    float3  _S293 = sel_0->color + weight_0;
    sel_0->color = _S293;
    Random _S294 = pcg(sel_0->random_state);
    sel_0->random_state = _S294.state;
    bool _S295 = (_S294.value * sel_0->w_sum) <= _S288;
    if(_S295)
    {
        sel_0->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_1, Reservoir r_0, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_0;
    float3  _S296 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S296;
    float _S297 = r_0.jac * shifted_0.jac;
    (&candidate_1)->jac = _S297;
    offer(sel_1, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_0.w));
    return;
}

__device__ Reservoir finalize(Selection sel_2, float c_0)
{
    Reservoir r_1 = sel_2.r;
    float _S298 = rgb_to_greyscale((&r_1)->f);
    float _S299 = sel_2.w_sum / _S298;
    bool _S300 = _S298 > 0.0f;
    float _S301 = _slang_select(_S300, _S299,0.0f);
    (&r_1)->w = _S301;
    (&r_1)->c = c_0;
    return r_1;
}

static __device__ uint insertBits_0(uint e_1, uint newbits_0, uint offset_0, uint count_0)
{
    uint _S302 = (1U << count_0) - 1U;
    return (e_1 & (~(_S302 << offset_0))) | ((newbits_0 & _S302) << offset_0);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_1, float3  f_1)
{
    Reservoir candidate_2 = r_2;
    uint _S303 = insertBits_0(r_2.path, end_1, 0U, 5U);
    uint _S304 = insertBits_0(_S303, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S304;
    (&candidate_2)->f = f_1;
    return candidate_2;
}

__device__ float facingSign(float transmission_0, float3  face_0, float3  direction_0)
{
    bool _S305 = transmission_0 > 0.0f;
    bool _S306;
    if(_S305)
    {
        _S306 = true;
    }
    else
    {
        _S306 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S307;
    if(_S306)
    {
        _S307 = 1.0f;
    }
    else
    {
        _S307 = -1.0f;
    }
    return _S307;
}

__device__ float survivalProbability(float3  throughput_1, float density_0)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_0), (0.0f)))), (1.0f)));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S308 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S309 = cos_a_0 > cos_b_0;
    float _S310 = _slang_select(_S309, 1.0f,_S308);
    return _S310;
}

__device__ float sine(float c_1)
{
    return (F32_sqrt(((F32_max((1.0f - c_1 * c_1), (0.0f))))));
}

__device__ float importance(LightNode node_0, float3  p_0, float3  normal_0)
{
    float3  _S311 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S312 = node_0.high - node_0.low;
    float3  _S313 = p_0 - _S311;
    float3  _S314 = ((((_S313)) * make_float3(rnorm3df(((_S313)).x, ((_S313)).y, ((_S313)).z))));
    float _S315 = dot_0(_S313, _S313);
    float _S316 = dot_0(_S312, _S312) / 4.0f;
    float _S317 = (F32_abs((dot_0(node_0.w, _S314))));
    float _S318 = sine(node_0.cos_theta_o);
    float _S319 = (F32_sqrt(((F32_max((1.0f - _S316 / _S315), (0.0f))))));
    bool _S320 = _S315 < _S316;
    float _S321 = _slang_select(_S320, -1.0f,_S319);
    float _S322 = sine(_S321);
    float _S323 = sine(_S317);
    float _S324 = cosSubClamped(_S323, _S317, _S318, node_0.cos_theta_o);
    float _S325 = sine(_S317);
    float _S326 = _S325 * node_0.cos_theta_o - _S317 * _S318;
    bool _S327 = _S317 > (node_0.cos_theta_o);
    float _S328 = _slang_select(_S327, 0.0f,_S326);
    float _S329 = cosSubClamped(_S328, _S324, _S322, _S321);
    bool _S330 = _S329 <= 0.0f;
    if(_S330)
    {
        return 0.0f;
    }
    float _S331 = - dot_0(_S314, normal_0);
    float _S332 = node_0.phi * _S329 / (F32_max((_S315), (length_0(_S312) / 2.0f)));
    float _S333 = sine(_S331);
    float _S334 = cosSubClamped(_S333, _S331, _S322, _S321);
    bool _S335 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S336 = _slang_select(_S335, 1.0f,_S334);
    return (F32_max((_S332 * _S336), (0.0f)));
}

__device__ float solidAngle(float probability_0, float3  normal_1, float3  toward_1)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_1)), (3.0f))) / (F32_abs((dot_0(normal_1, toward_1))));
}

__device__ uint pickChild(LightNode first_0, LightNode second_0, float3  p_1, float3  normal_2, float * pick_0, float * probability_1)
{
    float _S337 = importance(first_0, p_1, normal_2);
    float _S338 = importance(second_0, p_1, normal_2);
    float2  _S339 = make_float2 (_S337, _S338);
    bool _S340 = _S337 == 0.0f;
    bool _S341;
    if(_S340)
    {
        _S341 = _S338 == 0.0f;
    }
    else
    {
        _S341 = false;
    }
    if(_S341)
    {
        return 2U;
    }
    float _S342 = _S337 + _S338;
    bool _S343 = _S338 > 0.0f;
    if(_S343)
    {
        _S341 = (*pick_0 * _S342) >= _S337;
    }
    else
    {
        _S341 = false;
    }
    uint _S344 = uint(_S341);
    float _S345 = (F32_min(((*pick_0 * _S342 - float(_S344) * _S337) / _slang_vector_get_element(_S339, _S344)), (0.99999994039535522f)));
    *pick_0 = _S345;
    float _S346 = *probability_1 * (_slang_vector_get_element(_S339, _S344) / _S342);
    *probability_1 = _S346;
    return _S344;
}

__device__ float childShare(LightNode first_1, LightNode second_1, float3  p_2, float3  normal_3, uint child_0)
{
    float _S347 = importance(first_1, p_2, normal_3);
    float _S348 = importance(second_1, p_2, normal_3);
    float2  _S349 = make_float2 (_S347, _S348);
    float _S350 = _slang_vector_get_element(_S349, child_0) / (_S347 + _S348);
    bool _S351 = _slang_vector_get_element(_S349, child_0) > 0.0f;
    float _S352 = _slang_select(_S351, _S350,0.0f);
    return _S352;
}

__device__ float powerHeuristic(float a_5, float b_1)
{
    float _S353 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    bool _S354 = b_1 > 0.0f;
    float _S355 = _slang_select(_S354, _S353,1.0f);
    return _S355;
}

__device__ float sphereDensity(float3  center_0, float radius_1, float3  p_3)
{
    float3  _S356 = center_0 - p_3;
    float _S357 = radius_1 * radius_1 / dot_0(_S356, _S356);
    bool _S358 = _S357 >= 1.0f;
    if(_S358)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S357)))) / (6.28318548202514648f * _S357);
}

__device__ float3  sampleSphere(float3  center_1, float radius_2, float3  p_4, float u1_0, float u2_0)
{
    float3  _S359 = center_1 - p_4;
    float _S360 = radius_2 * radius_2 / dot_0(_S359, _S359);
    float _S361 = u1_0 * _S360 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S360), (0.0f)))))));
    float _S362 = 2.0f * u1_0;
    bool _S363 = _S360 >= 1.0f;
    float _S364 = _slang_select(_S363, _S362,_S361);
    float _S365 = (F32_sqrt(((F32_max((_S364 * (2.0f - _S364)), (0.0f))))));
    float _S366 = 6.28318548202514648f * u2_0;
    float3  _S367 = make_float3 (_S365 * (F32_cos((_S366))), 1.0f - _S364, _S365 * (F32_sin((_S366))));
    float3  _S368 = ((((_S359)) * make_float3(rnorm3df(((_S359)).x, ((_S359)).y, ((_S359)).z))));
    float3  _S369 = tangentToWorld(_S367, _S368);
    return _S369;
}

#undef Matrix
