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

__device__ float G1(float alpha_1, float n_dot_x_0)
{
    float _S25 = alpha_1 * 0.5f;
    return n_dot_x_0 / (F32_max((n_dot_x_0 * (1.0f - _S25) + _S25), (0.0000152587890625f)));
}

__device__ float smithG1(float alpha_2, float n_dot_x_1)
{
    float _S26 = alpha_2 * alpha_2;
    return 2.0f * n_dot_x_1 / (n_dot_x_1 + (F32_sqrt((_S26 + (1.0f - _S26) * n_dot_x_1 * n_dot_x_1))));
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S27 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S28 = eta_i_0 / eta_o_0 * _S27;
    bool _S29 = _S28 < 1.0f;
    float kr_0;
    if(_S29)
    {
        float _S30 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S28 * _S28))))));
        bool _S31 = eta_i_0 == eta_o_0;
        float _S32 = _slang_select(_S31, cos_theta_0,_S30);
        float _S33 = eta_o_0 * cos_theta_0;
        float _S34 = eta_i_0 * _S32;
        float _S35 = (_S33 - _S34) / (_S33 + _S34);
        float _S36 = eta_i_0 * cos_theta_0;
        float _S37 = eta_o_0 * _S32;
        float _S38 = (_S36 - _S37) / (_S36 + _S37);
        float _S39 = (_S35 * _S35 + _S38 * _S38) / 2.0f;
        kr_0 = _S39;
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

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_3, float U1_0, float U2_0)
{
    float3  _S40 = make_float3 (alpha_3 * Ve_0.x, alpha_3 * Ve_0.y, Ve_0.z);
    float3  _S41 = ((((_S40)) * make_float3(rnorm3df(((_S40)).x, ((_S40)).y, ((_S40)).z))));
    float _S42 = _S41.x;
    float _S43 = _S41.y;
    float _S44 = _S42 * _S42 + _S43 * _S43;
    float3  _S45 = make_float3 (1.0f, 0.0f, 0.0f);
    float3  _S46 = make_float3 (- _S43, _S42, 0.0f);
    float _S47 = (rsqrtf((_S44)));
    float3  _S48 = _S46 * make_float3 (_S47);
    bool _S49 = _S44 > 0.0f;
    float3  _S50 = _slang_select(_S49, _S48,_S45);
    float3  _S51 = cross_0(_S41, _S50);
    float _S52 = (F32_sqrt((U1_0)));
    float _S53 = 6.28318548202514648f * U2_0;
    float _S54 = _S52 * (F32_cos((_S53)));
    float t2_0 = _S52 * (F32_sin((_S53)));
    float _S55 = 0.5f * (1.0f + _S41.z);
    float t2_1 = (1.0f - _S55) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S54 * _S54)))))) + _S55 * t2_0;
    float3  _S56 = make_float3 (_S54) * _S50 + make_float3 (t2_1) * _S51;
    float _S57 = unshared_0(_S54);
    float _S58 = unshared_0(_S54);
    float3  _S59 = _S56 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S57 * _S58 - t2_1 * t2_1))))))) * _S41;
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

static __device__ float3  negate_0(float3  x_14)
{
    return - x_14;
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
    float3  _S89 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_4);
    bool _S90 = (dot_0(_S88, _S88)) > 0.0f;
    float3  _S91 = _slang_select(_S90, _S88,_S89);
    float3  _S92 = ((((_S91)) * make_float3(rnorm3df(((_S91)).x, ((_S91)).y, ((_S91)).z))));
    bool _S93 = (dot_0(cross_0(n_4, _S92), _S87)) > 0.0f;
    float3  t_1;
    if(_S93)
    {
        float3  _S94 = negate_0(_S92);
        t_1 = _S94;
    }
    else
    {
        t_1 = _S92;
    }
    float3  _S95 = cross_0(n_4, t_1);
    return makeMatrix<float, 3, 3> (t_1, _S95, n_4);
}

__device__ float3  tangentToWorldNormalMap(float3  v_2, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_2, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_0, float3  uvw_0, float3  position_0)
{
    float3  _S96 = t1_0 - t0_0;
    float3  _S97 = t2_2 - t0_0;
    float3  _S98 = t2_2 - t1_0;
    float _S99 = (F32_min((length_0(_S96)), ((F32_min((length_0(_S97)), (length_0(_S98)))))));
    float3  _S100 = make_float3 (distance_0(position_0, t0_0), distance_0(position_0, t1_0), distance_0(position_0, t2_2));
    float3  _S101 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S102 = dot_0(geometry_n_0, _S101);
    float3  _S103 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S104 = dot_0(geometry_n_0, _S103);
    float3  _S105 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S106 = acos_0(abs_0(make_float3 (_S102, _S104, dot_0(geometry_n_0, _S105))));
    float3  _S107 = clamp_0(tan_0(_S106), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S100 * _S107, uvw_0), 0.0f, _S99 * 0.125f);
}

__device__ float3  sampleHalfVector(float3  v_3, float3  n_i_0, float alpha_4, uint * random_state_0)
{
    Random _S108 = pcg(*random_state_0);
    Random _S109 = pcg(_S108.state);
    *random_state_0 = _S109.state;
    float3  _S110 = worldToTangent(v_3, n_i_0);
    float3  _S111 = sampleGGXVNDF(float3 {_S110.x, _S110.z, _S110.y}, alpha_4, _S108.value, _S109.value);
    float3  _S112 = float3 {_S111.x, _S111.z, _S111.y};
    float3  _S113 = tangentToWorld(_S112, n_i_0);
    return _S113;
}

static __device__ float sign_0(float e_0)
{
    bool _S114 = e_0 < 0.0f;
    float _S115 = _slang_select(_S114, -1.0f,0.0f);
    bool _S116 = e_0 > 0.0f;
    float _S117 = _slang_select(_S116, 1.0f,_S115);
    return _S117;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_5, BSDFMaterial material_0, uint random_state_1)
{
    uint state_5 = random_state_1;
    float3  _S118 = negate_0(in_dir_0);
    float _S119 = sign_0(dot_0(n_5, _S118));
    float _S120 = material_0.roughness;
    float3  _S121 = sampleHalfVector(_S118, n_5 * make_float3 (_S119), _S120 * _S120, &state_5);
    return _S121;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_6, float eta_i_1, float eta_o_1)
{
    float3  _S122 = negate_0(in_dir_1);
    float3  _S123 = negate_0(make_float3 (eta_i_1) * _S122 + make_float3 (eta_o_1) * out_dir_0);
    float3  _S124 = ((((_S123)) * make_float3(rnorm3df(((_S123)).x, ((_S123)).y, ((_S123)).z))));
    float _S125 = sign_0(dot_0(n_6, _S122));
    float _S126 = sign_0(dot_0(_S123, n_6 * make_float3 (_S125)));
    return _S124 * make_float3 (_S126);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S127 = negate_0(in_dir_2);
    float3  _S128 = _S127 + out_dir_1;
    float3  _S129 = ((((_S128)) * make_float3(rnorm3df(((_S128)).x, ((_S128)).y, ((_S128)).z))));
    return _S129;
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
    float diffuse_weight;
    float refract_weight;
    float p_diffuse;
    float p_reflect;
    float p_refract;
};

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_1, float3  refracted_0, float3  F_0, float F_greyscale_0, float reflect_weight_0, float diffuse_weight_0, float refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0)
{
    BSDFLobes _S130;
    (&_S130)->v_dot_h = v_dot_h_0;
    (&_S130)->n_dot_h = n_dot_h_1;
    (&_S130)->refracted = refracted_0;
    (&_S130)->F = F_0;
    (&_S130)->F_greyscale = F_greyscale_0;
    (&_S130)->reflect_weight = reflect_weight_0;
    (&_S130)->diffuse_weight = diffuse_weight_0;
    (&_S130)->refract_weight = refract_weight_0;
    (&_S130)->p_diffuse = p_diffuse_0;
    (&_S130)->p_reflect = p_reflect_0;
    (&_S130)->p_refract = p_refract_0;
    return _S130;
}

__device__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_4, float3  n_i_1, float3  ggx_n_0, BSDFMaterial material_1, float eta_i_2, float eta_o_2)
{
    float _S131 = dot_0(ggx_n_0, v_4);
    float _S132 = dot_0(n_i_1, ggx_n_0);
    float _S133 = eta_i_2 / eta_o_2;
    float3  _S134 = refract_0(in_dir_3, ggx_n_0, _S133);
    float3  _S135 = ((((_S134)) * make_float3(rnorm3df(((_S134)).x, ((_S134)).y, ((_S134)).z))));
    float _S136 = fresnel((F32_abs((_S131))), eta_i_2, eta_o_2);
    float3  F_1 = mix_0(make_float3 (_S136), material_1.albedo, material_1.metallic);
    float _S137 = rgb_to_greyscale(F_1);
    float _S138 = (1.0f - material_1.transmission) * (1.0f - material_1.metallic);
    float _S139 = (F32_max((_S137), (0.0f)));
    float _S140 = 1.0f - _S137;
    float _S141 = (F32_max((_S138 * _S140), (0.0f)));
    float _S142 = material_1.transmission * _S140;
    float _S143 = sign_0(length_0(_S135));
    float _S144 = (F32_max((_S142 * _S143), (0.0f)));
    float _S145 = _S139 + _S141 + _S144;
    float _S146 = 1.0f / (F32_max((_S145), (0.0000152587890625f)));
    float _S147 = _S141 * _S146;
    float _S148 = _S139 * _S146;
    float _S149 = _S144 * _S146;
    return BSDFLobes_x24init_0(_S131, _S132, _S135, F_1, _S137, 1.0f, _S138, material_1.transmission, _S147, _S148, _S149);
}

__device__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_5, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S150 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    bool _S151 = n_i_dot_v_0 > 0.0f;
    float _S152 = _slang_select(_S151, _S150,0.0f);
    return _S152;
}

__device__ float3  diffuseBSDF(float3  l_0, float3  n_i_2, float alpha_6, BSDFMaterial material_2, BSDFLobes lobes_1)
{
    return make_float3 (lobes_1.diffuse_weight) * material_2.albedo / make_float3 (lobes_1.p_diffuse);
}

__device__ float vndfPDF(float n_i_dot_v_1, float alpha_7, BSDFLobes lobes_2)
{
    float _S153 = smithG1(alpha_7, n_i_dot_v_1);
    float _S154 = _S153 * lobes_2.v_dot_h;
    float _S155 = trowbridgeReitz(alpha_7, lobes_2.n_dot_h);
    float _S156 = _S154 * _S155 / n_i_dot_v_1;
    bool _S157 = alpha_7 > 0.0f;
    bool _S158;
    if(_S157)
    {
        _S158 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S158 = false;
    }
    if(_S158)
    {
        _S158 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S158 = false;
    }
    if(_S158)
    {
        _S158 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S158 = false;
    }
    float _S159 = _slang_select(_S158, _S156,0.0f);
    return _S159;
}

__device__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_8, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S160 = vndfPDF(n_i_dot_v_2, alpha_8, lobes_3);
    float _S161 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S162 = lobes_3.p_refract * _S160 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S161 * _S161);
    bool _S163 = eta_i_4 != eta_o_4;
    bool _S164;
    if(_S163)
    {
        _S164 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S164 = false;
    }
    float _S165 = _slang_select(_S164, _S162,0.0f);
    return _S165;
}

__device__ float3  refractBSDF(float3  l_1, float3  n_i_3, float alpha_9, BSDFMaterial material_3, BSDFLobes lobes_4)
{
    float _S166 = - dot_0(n_i_3, l_1);
    float _S167 = G1(alpha_9, (F32_max((_S166), (0.0f))));
    return make_float3 (lobes_4.refract_weight * _S167 * (1.0f - lobes_4.F_greyscale)) * material_3.albedo / make_float3 (lobes_4.p_refract);
}

__device__ float reflectPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_10, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S168 = vndfPDF(n_i_dot_v_3, alpha_10, lobes_5);
    float _S169 = lobes_5.p_reflect * _S168 / (4.0f * lobes_5.v_dot_h);
    bool _S170 = _S168 > 0.0f;
    float _S171 = _slang_select(_S170, _S169,0.0f);
    return _S171;
}

__device__ float3  reflectBSDF(float3  l_2, float3  n_i_4, float alpha_11, BSDFMaterial material_4, BSDFLobes lobes_6)
{
    float _S172 = dot_0(n_i_4, l_2);
    float _S173 = G1(alpha_11, (F32_max((_S172), (0.0f))));
    return make_float3 (lobes_6.reflect_weight * _S173) * lobes_6.F / make_float3 (lobes_6.p_reflect);
}

__device__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_5, float eta_i_6, float eta_o_6, bool refracted_1, uint random_state_2, FixedArray<float3 , 3>  * throughputs_0, FixedArray<float, 3>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S174 = negate_0(in_dir_4);
    float _S175 = dot_0(n_7, _S174);
    float _S176 = sign_0(_S175);
    float3  _S177 = n_7 * make_float3 (_S176);
    float _S178 = dot_0(_S177, out_dir_2);
    float _S179 = material_5.roughness;
    float _S180 = _S179 * _S179;
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
        float3  _S181 = make_float3 (0.0f);
        (*throughputs_0)[i_10] = _S181;
        (*pdfs_0)[i_10] = 0.0f;
        uint i_11 = i_10 + 1U;
        i_10 = i_11;
    }
    float3  _S182 = make_float3 (0.0f);
    BSDFLobes _S183 = BSDFLobes_x24init_0(0.0f, 0.0f, _S182, _S182, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f);
    uint half_of_0 = 4294967295U;
    BSDFLobes lobe_terms_0 = _S183;
    float3  ggx_n_2 = _S182;
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
        bool _S184 = i_10 == 1U;
        bool _S185 = _S184 != refracted_1;
        if(_S185)
        {
            ggx_n_1 = ggx_n_2;
            uint i_12 = i_10 + 1U;
            ggx_n_2 = ggx_n_1;
            i_10 = i_12;
            continue;
        }
        bool _S186 = i_10 != half_of_0;
        uint half_of_1;
        BSDFLobes lobe_terms_1;
        if(_S186)
        {
            bool _S187 = i_10 == 0U;
            if(_S187)
            {
                float3  _S188 = sampledHalf(in_dir_4, n_7, material_5, random_state_2);
                ggx_n_1 = _S188;
            }
            else
            {
                if(_S184)
                {
                    float3  _S189 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_6, eta_o_6);
                    ggx_n_1 = _S189;
                }
                else
                {
                    float3  _S190 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S190;
                }
            }
            float3  _S191 = negate_0(in_dir_4);
            BSDFLobes _S192 = bsdfLobes(in_dir_4, _S191, _S177, ggx_n_1, material_5, eta_i_6, eta_o_6);
            lobe_terms_1 = _S192;
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
                float _S193 = diffusePDF(_S178, 0.0f, (F32_abs((_S175))), _S180, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[int(0)] = _S193;
                float3  _S194 = diffuseBSDF(out_dir_2, _S177, _S180, material_5, lobe_terms_1);
                (*throughputs_0)[int(0)] = _S194;
                break;
            }
        case 1U:
            {
                float _S195 = refractPDF(_S178, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S175))), _S180, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[int(1)] = _S195;
                float3  _S196 = refractBSDF(out_dir_2, _S177, _S180, material_5, lobe_terms_1);
                (*throughputs_0)[int(1)] = _S196;
                break;
            }
        default:
            {
                float _S197 = reflectPDF(_S178, 0.0f, (F32_abs((_S175))), _S180, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[int(2)] = _S197;
                float3  _S198 = reflectBSDF(out_dir_2, _S177, _S180, material_5, lobe_terms_1);
                (*throughputs_0)[int(2)] = _S198;
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
    ggx_n_1 = _S182;
    for(;;)
    {
        if(i_10 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S199 = ((*pdfs_0)[i_10]) > 0.0f;
        if(_S199)
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
    SampleBSDF _S200;
    (&_S200)->unit_direction = unit_direction_0;
    (&_S200)->throughput = throughput_0;
    (&_S200)->random_state = random_state_3;
    (&_S200)->refracted = refracted_2;
    (&_S200)->lobe = lobe_0;
    (&_S200)->pdf = pdf_0;
    return _S200;
}

__device__ SampleBSDF diffuseSample(float3  n_i_5, float n_i_dot_v_4, float alpha_12, BSDFMaterial material_6, BSDFLobes lobes_7, float eta_i_7, float eta_o_7, uint random_state_4)
{
    float3  _S201 = make_float3 (1.0f);
    SampleBSDF _S202 = SampleBSDF_x24init_0(_S201, _S201, 0U, false, 0U, 0.0f);
    SampleBSDF sample_0 = _S202;
    Random _S203 = pcg(random_state_4);
    Random _S204 = pcg(_S203.state);
    (&sample_0)->random_state = _S204.state;
    float3  _S205 = sampleCosWeightedHemisphere(_S203.value, _S204.value);
    float3  _S206 = tangentToWorld(_S205, n_i_5);
    (&sample_0)->unit_direction = _S206;
    (&sample_0)->lobe = 0U;
    float3  _S207 = diffuseBSDF((&sample_0)->unit_direction, n_i_5, alpha_12, material_6, lobes_7);
    (&sample_0)->throughput = _S207;
    float _S208 = diffusePDF(_S205.y, 0.0f, n_i_dot_v_4, alpha_12, lobes_7, eta_i_7, eta_o_7);
    (&sample_0)->pdf = _S208;
    return sample_0;
}

__device__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_6, float n_i_dot_v_5, float alpha_13, BSDFMaterial material_7, BSDFLobes lobes_8, float eta_i_8, float eta_o_8, uint random_state_5)
{
    float3  _S209 = make_float3 (1.0f);
    SampleBSDF _S210 = SampleBSDF_x24init_0(_S209, _S209, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S210;
    (&sample_1)->unit_direction = lobes_8.refracted;
    (&sample_1)->random_state = random_state_5;
    (&sample_1)->refracted = true;
    (&sample_1)->lobe = 1U;
    float3  _S211 = refractBSDF((&sample_1)->unit_direction, n_i_6, alpha_13, material_7, lobes_8);
    (&sample_1)->throughput = _S211;
    float _S212 = refractPDF(0.0f, dot_0((&sample_1)->unit_direction, ggx_n_3), n_i_dot_v_5, alpha_13, lobes_8, eta_i_8, eta_o_8);
    (&sample_1)->pdf = _S212;
    return sample_1;
}

__device__ SampleBSDF reflectSample(float3  in_dir_5, float3  ggx_n_4, float3  n_i_7, float n_i_dot_v_6, float alpha_14, BSDFMaterial material_8, BSDFLobes lobes_9, float eta_i_9, float eta_o_9, uint random_state_6)
{
    float3  _S213 = make_float3 (1.0f);
    SampleBSDF _S214 = SampleBSDF_x24init_0(_S213, _S213, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S214;
    float3  _S215 = reflect_0(in_dir_5, ggx_n_4);
    float3  _S216 = ((((_S215)) * make_float3(rnorm3df(((_S215)).x, ((_S215)).y, ((_S215)).z))));
    (&sample_2)->unit_direction = _S216;
    (&sample_2)->random_state = random_state_6;
    (&sample_2)->lobe = 2U;
    float3  _S217 = reflectBSDF((&sample_2)->unit_direction, n_i_7, alpha_14, material_8, lobes_9);
    (&sample_2)->throughput = _S217;
    float _S218 = reflectPDF(0.0f, 0.0f, n_i_dot_v_6, alpha_14, lobes_9, eta_i_9, eta_o_9);
    (&sample_2)->pdf = _S218;
    return sample_2;
}

__device__ SampleBSDF sampleBSDF(float3  in_dir_6, float3  n_8, BSDFMaterial material_9, float eta_i_10, float eta_o_10, uint random_init_0, float2  screen_space_0)
{
    uint random_state_7 = random_init_0;
    float3  _S219 = negate_0(in_dir_6);
    float _S220 = dot_0(n_8, _S219);
    float _S221 = sign_0(_S220);
    float3  n_i_8 = n_8 * make_float3 (_S221);
    float _S222 = (F32_abs((_S220)));
    float _S223 = material_9.roughness;
    float _S224 = _S223 * _S223;
    float3  _S225 = sampleHalfVector(_S219, n_i_8, _S224, &random_state_7);
    BSDFLobes _S226 = bsdfLobes(in_dir_6, _S219, n_i_8, _S225, material_9, eta_i_10, eta_o_10);
    Random _S227 = pcg(random_state_7);
    random_state_7 = _S227.state;
    bool _S228 = (_S227.value) < (_S226.p_diffuse);
    if(_S228)
    {
        SampleBSDF _S229 = diffuseSample(n_i_8, _S222, _S224, material_9, _S226, eta_i_10, eta_o_10, random_state_7);
        return _S229;
    }
    bool _S230 = (_S227.value) < (_S226.p_diffuse + _S226.p_refract);
    if(_S230)
    {
        SampleBSDF _S231 = refractSample(_S225, n_i_8, _S222, _S224, material_9, _S226, eta_i_10, eta_o_10, random_state_7);
        return _S231;
    }
    SampleBSDF _S232 = reflectSample(in_dir_6, _S225, n_i_8, _S222, _S224, material_9, _S226, eta_i_10, eta_o_10, random_state_7);
    return _S232;
}

__device__ float3  pointLightRadiance(float3  color_0, float intensity_0, float radius_0)
{
    return color_0 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_0 * radius_0);
}

__device__ float3  beerLambert(float distance_1, float3  absorption_0)
{
    float3  _S233 = max_0(absorption_0, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_1) * log_0(_S233));
}

__device__ bool neeDecision(BSDFMaterial material_10, float n_dot_v_0, float eta_i_11, float eta_o_11)
{
    float _S234 = fresnel((F32_abs((n_dot_v_0))), eta_i_11, eta_o_11);
    float3  _S235 = mix_0(make_float3 (_S234), material_10.albedo, material_10.metallic);
    float _S236 = rgb_to_greyscale(_S235);
    float _S237 = (F32_max(((1.0f - _S236) * (1.0f - material_10.metallic) * (1.0f - material_10.transmission)), (0.0f)));
    bool _S238 = _S237 > 0.03999999910593033f;
    bool _S239;
    if(_S238)
    {
        _S239 = true;
    }
    else
    {
        _S239 = (material_10.roughness) > 0.20000000298023224f;
    }
    return _S239;
}

__device__ float3  straightThrough(BSDFMaterial material_11)
{
    float _S240 = rgb_to_greyscale(material_11.albedo * make_float3 (material_11.metallic));
    return make_float3 (material_11.transmission * (1.0f - _S240)) * material_11.albedo;
}

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_0, float3  end_0)
{
    float _S241 = sign_0(dot_0(light_n_0, start_0 - end_0));
    return light_n_0 * make_float3 (_S241 * light_offset_0);
}

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

__device__ float3  occluderTransmittance(float3  toward_0, float3  n_9, BSDFMaterial material_12, float coverage_0)
{
    float3  _S242;
    if((material_12.ior) == 1.0f)
    {
        float3  _S243 = straightThrough(material_12);
        _S242 = _S243;
    }
    else
    {
        _S242 = make_float3 (0.0f);
    }
    return _S242 * make_float3 (coverage_0) + make_float3 (1.0f - coverage_0);
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S244 = hash(index_0);
    uint _S245 = hash(seed_0 ^ _S244);
    return _S245;
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float3  _S246 = a_4 / b_0;
    float3  _S247 = make_float3 (0.0f);
    bool3  _S248 = b_0 == _S247;
    float3  _S249 = _slang_select(_S248, _S247,_S246);
    return _S249;
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
    float _S250 = rgb_to_greyscale(weight_0);
    bool _S251 = _S250 > 0.0f;
    bool _S252;
    if(_S251)
    {
        _S252 = _S250 < 3.00000000549775576e+38f;
    }
    else
    {
        _S252 = false;
    }
    bool _S253 = !_S252;
    if(_S253)
    {
        return;
    }
    float _S254 = sel_0->w_sum + _S250;
    sel_0->w_sum = _S254;
    float3  _S255 = sel_0->color + weight_0;
    sel_0->color = _S255;
    Random _S256 = pcg(sel_0->random_state);
    sel_0->random_state = _S256.state;
    bool _S257 = (_S256.value * sel_0->w_sum) <= _S250;
    if(_S257)
    {
        sel_0->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_1, Reservoir r_0, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_0;
    float3  _S258 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S258;
    float _S259 = r_0.jac * shifted_0.jac;
    (&candidate_1)->jac = _S259;
    offer(sel_1, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_0.w));
    return;
}

__device__ Reservoir finalize(Selection sel_2, float c_0)
{
    Reservoir r_1 = sel_2.r;
    float _S260 = rgb_to_greyscale((&r_1)->f);
    float _S261 = sel_2.w_sum / _S260;
    bool _S262 = _S260 > 0.0f;
    float _S263 = _slang_select(_S262, _S261,0.0f);
    (&r_1)->w = _S263;
    (&r_1)->c = c_0;
    return r_1;
}

static __device__ uint insertBits_0(uint e_1, uint newbits_0, uint offset_0, uint count_0)
{
    uint _S264 = (1U << count_0) - 1U;
    return (e_1 & (~(_S264 << offset_0))) | ((newbits_0 & _S264) << offset_0);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_1, float3  f_1)
{
    Reservoir candidate_2 = r_2;
    uint _S265 = insertBits_0(r_2.path, end_1, 0U, 5U);
    uint _S266 = insertBits_0(_S265, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S266;
    (&candidate_2)->f = f_1;
    return candidate_2;
}

__device__ float facingSign(float transmission_0, float3  face_0, float3  direction_0)
{
    bool _S267 = transmission_0 > 0.0f;
    bool _S268;
    if(_S267)
    {
        _S268 = true;
    }
    else
    {
        _S268 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S269;
    if(_S268)
    {
        _S269 = 1.0f;
    }
    else
    {
        _S269 = -1.0f;
    }
    return _S269;
}

__device__ float survivalProbability(float3  throughput_1, float density_0)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_0), (0.0f)))), (1.0f)));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S270 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S271 = cos_a_0 > cos_b_0;
    float _S272 = _slang_select(_S271, 1.0f,_S270);
    return _S272;
}

__device__ float sine(float c_1)
{
    return (F32_sqrt(((F32_max((1.0f - c_1 * c_1), (0.0f))))));
}

__device__ float importance(LightNode node_0, float3  p_0, float3  normal_0)
{
    float3  _S273 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S274 = node_0.high - node_0.low;
    float3  _S275 = p_0 - _S273;
    float3  _S276 = ((((_S275)) * make_float3(rnorm3df(((_S275)).x, ((_S275)).y, ((_S275)).z))));
    float _S277 = dot_0(_S275, _S275);
    float _S278 = dot_0(_S274, _S274) / 4.0f;
    float _S279 = (F32_abs((dot_0(node_0.w, _S276))));
    float _S280 = sine(node_0.cos_theta_o);
    float _S281 = (F32_sqrt(((F32_max((1.0f - _S278 / _S277), (0.0f))))));
    bool _S282 = _S277 < _S278;
    float _S283 = _slang_select(_S282, -1.0f,_S281);
    float _S284 = sine(_S283);
    float _S285 = sine(_S279);
    float _S286 = cosSubClamped(_S285, _S279, _S280, node_0.cos_theta_o);
    float _S287 = sine(_S279);
    float _S288 = _S287 * node_0.cos_theta_o - _S279 * _S280;
    bool _S289 = _S279 > (node_0.cos_theta_o);
    float _S290 = _slang_select(_S289, 0.0f,_S288);
    float _S291 = cosSubClamped(_S290, _S286, _S284, _S283);
    bool _S292 = _S291 <= 0.0f;
    if(_S292)
    {
        return 0.0f;
    }
    float _S293 = - dot_0(_S276, normal_0);
    float _S294 = node_0.phi * _S291 / (F32_max((_S277), (length_0(_S274) / 2.0f)));
    float _S295 = sine(_S293);
    float _S296 = cosSubClamped(_S295, _S293, _S284, _S283);
    bool _S297 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S298 = _slang_select(_S297, 1.0f,_S296);
    return (F32_max((_S294 * _S298), (0.0f)));
}

__device__ float solidAngle(float probability_0, float3  normal_1, float3  toward_1)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_1)), (3.0f))) / (F32_abs((dot_0(normal_1, toward_1))));
}

__device__ uint pickChild(LightNode first_0, LightNode second_0, float3  p_1, float3  normal_2, float * pick_0, float * probability_1)
{
    float _S299 = importance(first_0, p_1, normal_2);
    float _S300 = importance(second_0, p_1, normal_2);
    float2  _S301 = make_float2 (_S299, _S300);
    bool _S302 = _S299 == 0.0f;
    bool _S303;
    if(_S302)
    {
        _S303 = _S300 == 0.0f;
    }
    else
    {
        _S303 = false;
    }
    if(_S303)
    {
        return 2U;
    }
    float _S304 = _S299 + _S300;
    bool _S305 = _S300 > 0.0f;
    if(_S305)
    {
        _S303 = (*pick_0 * _S304) >= _S299;
    }
    else
    {
        _S303 = false;
    }
    uint _S306 = uint(_S303);
    float _S307 = (F32_min(((*pick_0 * _S304 - float(_S306) * _S299) / _slang_vector_get_element(_S301, _S306)), (0.99999994039535522f)));
    *pick_0 = _S307;
    float _S308 = *probability_1 * (_slang_vector_get_element(_S301, _S306) / _S304);
    *probability_1 = _S308;
    return _S306;
}

__device__ float childShare(LightNode first_1, LightNode second_1, float3  p_2, float3  normal_3, uint child_0)
{
    float _S309 = importance(first_1, p_2, normal_3);
    float _S310 = importance(second_1, p_2, normal_3);
    float2  _S311 = make_float2 (_S309, _S310);
    float _S312 = _slang_vector_get_element(_S311, child_0) / (_S309 + _S310);
    bool _S313 = _slang_vector_get_element(_S311, child_0) > 0.0f;
    float _S314 = _slang_select(_S313, _S312,0.0f);
    return _S314;
}

__device__ float powerHeuristic(float a_5, float b_1)
{
    float _S315 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    bool _S316 = b_1 > 0.0f;
    float _S317 = _slang_select(_S316, _S315,1.0f);
    return _S317;
}

__device__ float sphereDensity(float3  center_0, float radius_1, float3  p_3)
{
    float3  _S318 = center_0 - p_3;
    float _S319 = radius_1 * radius_1 / dot_0(_S318, _S318);
    bool _S320 = _S319 >= 1.0f;
    if(_S320)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S319)))) / (6.28318548202514648f * _S319);
}

__device__ float3  sampleSphere(float3  center_1, float radius_2, float3  p_4, float u1_0, float u2_0)
{
    float3  _S321 = center_1 - p_4;
    float _S322 = radius_2 * radius_2 / dot_0(_S321, _S321);
    float _S323 = u1_0 * _S322 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S322), (0.0f)))))));
    float _S324 = 2.0f * u1_0;
    bool _S325 = _S322 >= 1.0f;
    float _S326 = _slang_select(_S325, _S324,_S323);
    float _S327 = (F32_sqrt(((F32_max((_S326 * (2.0f - _S326)), (0.0f))))));
    float _S328 = 6.28318548202514648f * u2_0;
    float3  _S329 = make_float3 (_S327 * (F32_cos((_S328))), 1.0f - _S326, _S327 * (F32_sin((_S328))));
    float3  _S330 = ((((_S321)) * make_float3(rnorm3df(((_S321)).x, ((_S321)).y, ((_S321)).z))));
    float3  _S331 = tangentToWorld(_S329, _S330);
    return _S331;
}

#undef Matrix
