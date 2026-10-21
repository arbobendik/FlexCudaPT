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

__device__ float trowbridgeReitz(float alpha_0, float n_dot_h_0)
{
    float _S24 = alpha_0 * alpha_0;
    float _S25 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S24 * n_dot_h_0 * n_dot_h_0;
    return _S24 / (F32_max((3.14159274101257324f * _S25 * _S25), (1.17549435082228751e-38f)));
}

__device__ float G1(float alpha_1, float n_dot_x_0)
{
    float _S26 = alpha_1 * 0.5f;
    return n_dot_x_0 / (F32_max((n_dot_x_0 * (1.0f - _S26) + _S26), (0.0000152587890625f)));
}

__device__ float smithG1(float alpha_2, float n_dot_x_1)
{
    float _S27 = alpha_2 * alpha_2;
    return 2.0f * n_dot_x_1 / (n_dot_x_1 + (F32_sqrt((_S27 + (1.0f - _S27) * n_dot_x_1 * n_dot_x_1))));
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S28 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S29 = eta_i_0 / eta_o_0 * _S28;
    bool _S30 = _S29 < 1.0f;
    float kr_0;
    if(_S30)
    {
        float _S31 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S29 * _S29))))));
        float _S32 = eta_o_0 * cos_theta_0;
        float _S33 = eta_i_0 * _S31;
        float _S34 = (_S32 - _S33) / (_S32 + _S33);
        float _S35 = eta_i_0 * cos_theta_0;
        float _S36 = eta_o_0 * _S31;
        float _S37 = (_S35 - _S36) / (_S35 + _S36);
        float _S38 = (_S34 * _S34 + _S37 * _S37) / 2.0f;
        kr_0 = _S38;
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
    float3  _S39 = make_float3 (alpha_3 * Ve_0.x, alpha_3 * Ve_0.y, Ve_0.z);
    float3  _S40 = ((((_S39)) * make_float3(rnorm3df(((_S39)).x, ((_S39)).y, ((_S39)).z))));
    float _S41 = _S40.x;
    float _S42 = _S40.y;
    float _S43 = _S41 * _S41 + _S42 * _S42;
    float3  _S44;
    if(_S43 > 0.0f)
    {
        float3  _S45 = make_float3 (- _S42, _S41, 0.0f);
        float _S46 = (rsqrtf((_S43)));
        _S44 = _S45 * make_float3 (_S46);
    }
    else
    {
        _S44 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S47 = cross_0(_S40, _S44);
    float _S48 = (F32_sqrt((U1_0)));
    float _S49 = 6.28318548202514648f * U2_0;
    float _S50 = _S48 * (F32_cos((_S49)));
    float t2_0 = _S48 * (F32_sin((_S49)));
    float _S51 = 0.5f * (1.0f + _S40.z);
    float t2_1 = (1.0f - _S51) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S50 * _S50)))))) + _S51 * t2_0;
    float3  _S52 = make_float3 (_S50) * _S44 + make_float3 (t2_1) * _S47;
    float _S53 = unshared_0(_S50);
    float _S54 = unshared_0(_S50);
    float3  _S55 = _S52 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S53 * _S54 - t2_1 * t2_1))))))) * _S40;
    float3  _S56 = make_float3 (alpha_3 * _S55.x, alpha_3 * _S55.y, (F32_max((0.0f), (_S55.z))));
    float3  _S57 = ((((_S56)) * make_float3(rnorm3df(((_S56)).x, ((_S56)).y, ((_S56)).z))));
    return _S57;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S58 = (F32_sqrt((random_1_0)));
    float _S59 = 6.28318548202514648f * random_2_0;
    float _S60 = _S58 * (F32_cos((_S59)));
    float _S61 = _S58 * (F32_sin((_S59)));
    float _S62 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S60 * _S60 - _S61 * _S61))))));
    return make_float3 (_S60, _S62, _S61);
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_2)
{
    float3  a_0 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S63 = (F32_abs((dot_0(n_2, a_0)))) > 0.9999847412109375f;
    float3  a_1;
    if(_S63)
    {
        float3  _S64 = make_float3 (1.0f, 0.0f, 0.0f);
        a_1 = _S64;
    }
    else
    {
        a_1 = a_0;
    }
    float3  _S65 = cross_0(n_2, a_1);
    float3  _S66 = ((((_S65)) * make_float3(rnorm3df(((_S65)).x, ((_S65)).y, ((_S65)).z))));
    float3  _S67 = cross_0(n_2, _S66);
    return make_float3 (v_0.x) * _S66 + make_float3 (v_0.y) * n_2 + make_float3 (v_0.z) * _S67;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
{
    float3  a_2 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S68 = (F32_abs((dot_0(n_3, a_2)))) > 0.9999847412109375f;
    float3  a_3;
    if(_S68)
    {
        float3  _S69 = make_float3 (1.0f, 0.0f, 0.0f);
        a_3 = _S69;
    }
    else
    {
        a_3 = a_2;
    }
    float3  _S70 = cross_0(n_3, a_3);
    float3  _S71 = ((((_S70)) * make_float3(rnorm3df(((_S70)).x, ((_S70)).y, ((_S70)).z))));
    float3  _S72 = cross_0(n_3, _S71);
    return make_float3 (dot_0(v_1, _S71), dot_0(v_1, n_3), dot_0(v_1, _S72));
}

static __device__ float3  negate_0(float3  x_14)
{
    return - x_14;
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_4)
{
    float3  _S73 = p1_0 - p0_0;
    float3  _S74 = p2_0 - p0_0;
    float2  _S75 = uv1_0 - uv0_0;
    float2  _S76 = uv2_0 - uv0_0;
    float _S77 = _S75.x;
    float _S78 = _S76.y;
    float _S79 = _S75.y;
    float _S80 = _S76.x;
    float _S81 = _S77 * _S78 - _S79 * _S80;
    float _S82 = 1.0f / _S81;
    float3  t_0 = (_S73 * make_float3 (_S78) - _S74 * make_float3 (_S79)) * make_float3 (_S82);
    float3  _S83 = (_S74 * make_float3 (_S77) - _S73 * make_float3 (_S80)) * make_float3 (_S82);
    float3  _S84 = t_0 - n_4 * make_float3 (dot_0(n_4, t_0));
    float3  t_1 = ((((_S84)) * make_float3(rnorm3df(((_S84)).x, ((_S84)).y, ((_S84)).z))));
    bool _S85 = (dot_0(cross_0(n_4, t_1), _S83)) > 0.0f;
    float3  t_2;
    if(_S85)
    {
        float3  _S86 = negate_0(t_1);
        t_2 = _S86;
    }
    else
    {
        t_2 = t_1;
    }
    float3  _S87 = cross_0(n_4, t_2);
    return makeMatrix<float, 3, 3> (t_2, _S87, n_4);
}

__device__ float3  tangentToWorldNormalMap(float3  v_2, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_2, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_0, float3  uvw_0, float3  position_0)
{
    float3  _S88 = t1_0 - t0_0;
    float3  _S89 = t2_2 - t0_0;
    float3  _S90 = t2_2 - t1_0;
    float _S91 = (F32_min((length_0(_S88)), ((F32_min((length_0(_S89)), (length_0(_S90)))))));
    float3  _S92 = make_float3 (distance_0(position_0, t0_0), distance_0(position_0, t1_0), distance_0(position_0, t2_2));
    float3  _S93 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S94 = dot_0(geometry_n_0, _S93);
    float3  _S95 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S96 = dot_0(geometry_n_0, _S95);
    float3  _S97 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S98 = acos_0(abs_0(make_float3 (_S94, _S96, dot_0(geometry_n_0, _S97))));
    float3  _S99 = clamp_0(tan_0(_S98), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S92 * _S99, uvw_0), 0.0f, _S91 * 0.125f);
}

__device__ float3  sampleHalfVector(float3  v_3, float3  n_i_0, float alpha_4, uint * random_state_0)
{
    Random _S100 = pcg(*random_state_0);
    Random _S101 = pcg(_S100.state);
    *random_state_0 = _S101.state;
    float3  _S102 = worldToTangent(v_3, n_i_0);
    float3  _S103 = sampleGGXVNDF(float3 {_S102.x, _S102.z, _S102.y}, alpha_4, _S100.value, _S101.value);
    float3  _S104 = float3 {_S103.x, _S103.z, _S103.y};
    float3  _S105 = tangentToWorld(_S104, n_i_0);
    return _S105;
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

static __device__ float sign_0(float e_0)
{
    float _S106;
    if(e_0 > 0.0f)
    {
        _S106 = 1.0f;
    }
    else
    {
        if(e_0 < 0.0f)
        {
            _S106 = -1.0f;
        }
        else
        {
            _S106 = 0.0f;
        }
    }
    return _S106;
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
    BSDFLobes _S107;
    (&_S107)->v_dot_h = v_dot_h_0;
    (&_S107)->n_dot_h = n_dot_h_1;
    (&_S107)->refracted = refracted_0;
    (&_S107)->F = F_0;
    (&_S107)->F_greyscale = F_greyscale_0;
    (&_S107)->reflect_weight = reflect_weight_0;
    (&_S107)->diffuse_weight = diffuse_weight_0;
    (&_S107)->refract_weight = refract_weight_0;
    (&_S107)->p_diffuse = p_diffuse_0;
    (&_S107)->p_reflect = p_reflect_0;
    (&_S107)->p_refract = p_refract_0;
    return _S107;
}

__device__ BSDFLobes bsdfLobes(float3  in_dir_0, float3  v_4, float3  n_i_1, float3  ggx_n_0, BSDFMaterial material_0, float eta_i_1, float eta_o_1)
{
    float _S108 = dot_0(ggx_n_0, v_4);
    float _S109 = dot_0(n_i_1, ggx_n_0);
    float _S110 = eta_i_1 / eta_o_1;
    float3  _S111 = refract_0(in_dir_0, ggx_n_0, _S110);
    float3  _S112 = ((((_S111)) * make_float3(rnorm3df(((_S111)).x, ((_S111)).y, ((_S111)).z))));
    float _S113 = fresnel((F32_abs((_S108))), eta_i_1, eta_o_1);
    float3  F_1 = mix_0(make_float3 (_S113), material_0.albedo, material_0.metallic);
    float _S114 = rgb_to_greyscale(F_1);
    float _S115 = (1.0f - material_0.transmission) * (1.0f - material_0.metallic);
    float _S116 = (F32_max((_S114), (0.0f)));
    float _S117 = 1.0f - _S114;
    float _S118 = (F32_max((_S115 * _S117), (0.0f)));
    float _S119 = material_0.transmission * _S117;
    float _S120 = sign_0(length_0(_S112));
    float _S121 = (F32_max((_S119 * _S120), (0.0f)));
    float _S122 = _S116 + _S118 + _S121;
    float _S123 = 1.0f / (F32_max((_S122), (0.0000152587890625f)));
    float _S124 = _S118 * _S123;
    float _S125 = _S116 * _S123;
    float _S126 = _S121 * _S123;
    return BSDFLobes_x24init_0(_S108, _S109, _S112, F_1, _S114, 1.0f, _S115, material_0.transmission, _S124, _S125, _S126);
}

__device__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_5, BSDFLobes lobes_0, float eta_i_2, float eta_o_2, uint lobe_0)
{
    bool _S127 = lobe_0 == 0U;
    if(_S127)
    {
        float _S128 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        bool _S129 = n_i_dot_v_0 > 0.0f;
        float _S130 = _slang_select(_S129, _S128,0.0f);
        return _S130;
    }
    float _S131 = smithG1(alpha_5, n_i_dot_v_0);
    float _S132 = _S131 * lobes_0.v_dot_h;
    float _S133 = trowbridgeReitz(alpha_5, lobes_0.n_dot_h);
    float _S134 = _S132 * _S133 / n_i_dot_v_0;
    bool _S135 = alpha_5 > 0.0f;
    bool _S136;
    if(_S135)
    {
        _S136 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S136 = false;
    }
    if(_S136)
    {
        _S136 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S136 = false;
    }
    if(_S136)
    {
        _S136 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S136 = false;
    }
    float _S137 = _slang_select(_S136, _S134,0.0f);
    bool _S138 = lobe_0 == 1U;
    if(_S138)
    {
        float _S139 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        float _S140 = lobes_0.p_refract * _S137 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S139 * _S139);
        bool _S141 = eta_i_2 != eta_o_2;
        if(_S141)
        {
            _S136 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S136 = false;
        }
        float _S142 = _slang_select(_S136, _S140,0.0f);
        return _S142;
    }
    float _S143 = lobes_0.p_reflect * _S137 / (4.0f * lobes_0.v_dot_h);
    bool _S144 = _S137 > 0.0f;
    float _S145 = _slang_select(_S144, _S143,0.0f);
    return _S145;
}

__device__ float3  lobeThroughput(float3  l_0, float3  n_i_2, float alpha_6, BSDFMaterial material_1, BSDFLobes lobes_1, uint lobe_1)
{
    bool _S146 = lobe_1 == 0U;
    if(_S146)
    {
        return make_float3 (lobes_1.diffuse_weight) * material_1.albedo / make_float3 (lobes_1.p_diffuse);
    }
    bool _S147 = lobe_1 == 1U;
    if(_S147)
    {
        float _S148 = - dot_0(n_i_2, l_0);
        float _S149 = G1(alpha_6, (F32_max((_S148), (0.0f))));
        return make_float3 (lobes_1.refract_weight * _S149 * (1.0f - lobes_1.F_greyscale)) * material_1.albedo / make_float3 (lobes_1.p_refract);
    }
    float _S150 = dot_0(n_i_2, l_0);
    float _S151 = G1(alpha_6, (F32_max((_S150), (0.0f))));
    return make_float3 (lobes_1.reflect_weight * _S151) * lobes_1.F / make_float3 (lobes_1.p_reflect);
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
    SampleBSDF _S152;
    (&_S152)->unit_direction = unit_direction_0;
    (&_S152)->throughput = throughput_0;
    (&_S152)->random_state = random_state_1;
    (&_S152)->refracted = refracted_1;
    (&_S152)->lobe = lobe_2;
    (&_S152)->pdf = pdf_0;
    return _S152;
}

__device__ SampleBSDF connectBSDF(float3  in_dir_1, float3  out_dir_0, float3  n_5, BSDFMaterial material_2, float eta_i_3, float eta_o_3, uint lobe_3, uint random_init_0)
{
    uint random_state_2 = random_init_0;
    float3  _S153 = negate_0(in_dir_1);
    float _S154 = dot_0(n_5, _S153);
    float _S155 = sign_0(_S154);
    float3  _S156 = n_5 * make_float3 (_S155);
    float _S157 = material_2.roughness;
    float _S158 = _S157 * _S157;
    float3  _S159 = _S153 + out_dir_0;
    float3  _S160 = ((((_S159)) * make_float3(rnorm3df(((_S159)).x, ((_S159)).y, ((_S159)).z))));
    bool _S161 = lobe_3 == 0U;
    float3  ggx_n_1;
    if(_S161)
    {
        float3  _S162 = sampleHalfVector(_S153, _S156, _S158, &random_state_2);
        ggx_n_1 = _S162;
    }
    else
    {
        ggx_n_1 = _S160;
    }
    bool _S163 = lobe_3 == 1U;
    if(_S163)
    {
        float3  _S164 = negate_0(make_float3 (eta_i_3) * _S153 + make_float3 (eta_o_3) * out_dir_0);
        float3  _S165 = ((((_S164)) * make_float3(rnorm3df(((_S164)).x, ((_S164)).y, ((_S164)).z))));
        float _S166 = sign_0(dot_0(_S164, _S156));
        float3  _S167 = _S165 * make_float3 (_S166);
        ggx_n_1 = _S167;
    }
    else
    {
    }
    bool _S168 = lobe_3 == 2U;
    if(_S168)
    {
        float3  _S169 = ((((_S159)) * make_float3(rnorm3df(((_S159)).x, ((_S159)).y, ((_S159)).z))));
        ggx_n_1 = _S169;
    }
    else
    {
    }
    BSDFLobes _S170 = bsdfLobes(in_dir_1, _S153, _S156, ggx_n_1, material_2, eta_i_3, eta_o_3);
    float _S171 = lobeDensity(dot_0(_S156, out_dir_0), dot_0(out_dir_0, ggx_n_1), (F32_abs((_S154))), _S158, _S170, eta_i_3, eta_o_3, lobe_3);
    bool _S172 = !(_S171 > 0.0f);
    if(_S172)
    {
        float3  _S173 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S173, _S173, 0U, false, 0U, 0.0f);
    }
    float3  _S174 = lobeThroughput(out_dir_0, _S156, _S158, material_2, _S170, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S174, random_state_2, _S163, lobe_3, _S171);
}

__device__ float3  BSDF(float3  in_dir_2, float3  out_dir_1, float3  n_6, float3  g_n_0, BSDFMaterial material_3, float eta_i_4, float eta_o_4, uint random_state_3)
{
    float3  _S175 = negate_0(in_dir_2);
    bool _S176 = (dot_0(g_n_0, _S175) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S176)
    {
        SampleBSDF _S177 = connectBSDF(in_dir_2, out_dir_1, n_6, material_3, eta_i_4, eta_o_4, 0U, random_state_3);
        SampleBSDF _S178 = connectBSDF(in_dir_2, out_dir_1, n_6, material_3, eta_i_4, eta_o_4, 2U, random_state_3);
        return _S177.throughput * make_float3 (_S177.pdf) + _S178.throughput * make_float3 (_S178.pdf);
    }
    SampleBSDF _S179 = connectBSDF(in_dir_2, out_dir_1, n_6, material_3, eta_i_4, eta_o_4, 1U, random_state_3);
    return _S179.throughput * make_float3 (_S179.pdf);
}

__device__ SampleBSDF sampleBSDF(float3  in_dir_3, float3  n_7, BSDFMaterial material_4, float eta_i_5, float eta_o_5, uint random_init_1, float2  screen_space_0)
{
    uint random_state_4 = random_init_1;
    float3  _S180 = negate_0(in_dir_3);
    float _S181 = dot_0(n_7, _S180);
    float _S182 = sign_0(_S181);
    float3  n_i_3 = n_7 * make_float3 (_S182);
    float _S183 = (F32_abs((_S181)));
    float _S184 = material_4.roughness;
    float _S185 = _S184 * _S184;
    float3  _S186 = sampleHalfVector(_S180, n_i_3, _S185, &random_state_4);
    BSDFLobes _S187 = bsdfLobes(in_dir_3, _S180, n_i_3, _S186, material_4, eta_i_5, eta_o_5);
    float3  _S188 = make_float3 (1.0f);
    SampleBSDF _S189 = SampleBSDF_x24init_0(_S188, _S188, 0U, false, 0U, 0.0f);
    SampleBSDF sample_0 = _S189;
    Random _S190 = pcg(random_state_4);
    random_state_4 = _S190.state;
    bool _S191 = (_S190.value) < (_S187.p_diffuse);
    if(_S191)
    {
        Random _S192 = pcg(random_state_4);
        Random _S193 = pcg(_S192.state);
        (&sample_0)->random_state = _S193.state;
        float3  _S194 = sampleCosWeightedHemisphere(_S192.value, _S193.value);
        float3  _S195 = tangentToWorld(_S194, n_i_3);
        (&sample_0)->unit_direction = _S195;
        float3  _S196 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S185, material_4, _S187, 0U);
        (&sample_0)->throughput = _S196;
        float _S197 = lobeDensity(_S194.y, 0.0f, _S183, _S185, _S187, eta_i_5, eta_o_5, 0U);
        (&sample_0)->pdf = _S197;
        return sample_0;
    }
    bool _S198 = (_S190.value) < (_S187.p_diffuse + _S187.p_refract);
    if(_S198)
    {
        (&sample_0)->unit_direction = _S187.refracted;
        float _S199 = lobeDensity(0.0f, dot_0((&sample_0)->unit_direction, _S186), _S183, _S185, _S187, eta_i_5, eta_o_5, 1U);
        (&sample_0)->pdf = _S199;
        float3  _S200 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S185, material_4, _S187, 1U);
        (&sample_0)->throughput = _S200;
        (&sample_0)->random_state = random_state_4;
        (&sample_0)->refracted = true;
        (&sample_0)->lobe = 1U;
        return sample_0;
    }
    float3  _S201 = reflect_0(in_dir_3, _S186);
    float3  _S202 = ((((_S201)) * make_float3(rnorm3df(((_S201)).x, ((_S201)).y, ((_S201)).z))));
    (&sample_0)->unit_direction = _S202;
    float3  _S203 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S185, material_4, _S187, 2U);
    (&sample_0)->throughput = _S203;
    (&sample_0)->random_state = random_state_4;
    (&sample_0)->lobe = 2U;
    float _S204 = lobeDensity(0.0f, 0.0f, _S183, _S185, _S187, eta_i_5, eta_o_5, 2U);
    (&sample_0)->pdf = _S204;
    return sample_0;
}

__device__ float3  pointLightRadiance(float3  color_0, float intensity_0, float radius_0)
{
    return color_0 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_0 * radius_0);
}

__device__ float3  beerLambert(float distance_1, float3  absorption_0)
{
    float3  _S205 = max_0(absorption_0, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_1) * log_0(_S205));
}

__device__ bool neeDecision(BSDFMaterial material_5, float n_dot_v_0, float eta_i_6, float eta_o_6)
{
    float _S206 = fresnel((F32_abs((n_dot_v_0))), eta_i_6, eta_o_6);
    float3  _S207 = mix_0(make_float3 (_S206), material_5.albedo, material_5.metallic);
    float _S208 = rgb_to_greyscale(_S207);
    float _S209 = (F32_max(((1.0f - _S208) * (1.0f - material_5.metallic) * (1.0f - material_5.transmission)), (0.0f)));
    bool _S210 = _S209 > 0.03999999910593033f;
    bool _S211;
    if(_S210)
    {
        _S211 = true;
    }
    else
    {
        _S211 = (material_5.roughness) > 0.20000000298023224f;
    }
    return _S211;
}

__device__ float3  neeBSDF(float3  in_dir_4, float3  dir_0, float3  n_8, BSDFMaterial material_6, float eta_i_7, float eta_o_7, bool refracted_2, float pdf_1, bool power_0, uint random_state_5)
{
    float3  _S212 = make_float3 (0.0f);
    uint lobe_4 = 0U;
    float3  f_0 = _S212;
    for(;;)
    {
        if(lobe_4 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S213 = (lobe_4 == 1U) == refracted_2;
        float3  f_1;
        if(_S213)
        {
            SampleBSDF _S214 = connectBSDF(in_dir_4, dir_0, n_8, material_6, eta_i_7, eta_o_7, lobe_4, random_state_5);
            bool _S215 = (_S214.pdf) > 0.0f;
            if(_S215)
            {
                if(power_0)
                {
                    float _S216 = _S214.pdf / pdf_1;
                    float3  f_2 = f_0 + _S214.throughput * make_float3 (_S214.pdf) / make_float3 (pdf_1 * (1.0f + _S216 * _S216));
                    f_1 = f_2;
                }
                else
                {
                    float3  f_3 = f_0 + _S214.throughput * make_float3 (_S214.pdf) / make_float3 (_S214.pdf + pdf_1);
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
    float _S217 = rgb_to_greyscale(material_7.albedo * make_float3 (material_7.metallic));
    float _S218 = material_7.roughness;
    float _S219 = G1(_S218 * _S218, (F32_abs((dot_0(n_9, dir_1)))));
    return make_float3 (material_7.transmission * _S219 * (1.0f - _S217)) * material_7.albedo;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S220 = hash(index_0);
    uint _S221 = hash(seed_0 ^ _S220);
    return _S221;
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float3  _S222 = a_4 / b_0;
    float3  _S223 = make_float3 (0.0f);
    bool3  _S224 = b_0 == _S223;
    float3  _S225 = _slang_select(_S224, _S223,_S222);
    return _S225;
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
    float _S226 = rgb_to_greyscale(weight_0);
    bool _S227 = _S226 > 0.0f;
    bool _S228;
    if(_S227)
    {
        _S228 = _S226 < 3.00000000549775576e+38f;
    }
    else
    {
        _S228 = false;
    }
    bool _S229 = !_S228;
    if(_S229)
    {
        return;
    }
    float _S230 = sel_0->w_sum + _S226;
    sel_0->w_sum = _S230;
    float3  _S231 = sel_0->color + weight_0;
    sel_0->color = _S231;
    Random _S232 = pcg(sel_0->random_state);
    sel_0->random_state = _S232.state;
    bool _S233 = (_S232.value * sel_0->w_sum) <= _S226;
    if(_S233)
    {
        sel_0->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_1, Reservoir r_0, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_0;
    float3  _S234 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S234;
    float _S235 = r_0.jac * shifted_0.jac;
    (&candidate_1)->jac = _S235;
    offer(sel_1, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_0.w));
    return;
}

__device__ Reservoir finalize(Selection sel_2, float c_0)
{
    Reservoir r_1 = sel_2.r;
    float _S236 = rgb_to_greyscale((&r_1)->f);
    float _S237 = sel_2.w_sum / _S236;
    bool _S238 = _S236 > 0.0f;
    float _S239 = _slang_select(_S238, _S237,0.0f);
    (&r_1)->w = _S239;
    (&r_1)->c = c_0;
    return r_1;
}

static __device__ uint insertBits_0(uint e_1, uint newbits_0, uint offset_0, uint count_0)
{
    uint _S240 = (1U << count_0) - 1U;
    return (e_1 & (~(_S240 << offset_0))) | ((newbits_0 & _S240) << offset_0);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_0, float3  f_4)
{
    Reservoir candidate_2 = r_2;
    uint _S241 = insertBits_0(r_2.path, end_0, 0U, 5U);
    uint _S242 = insertBits_0(_S241, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S242;
    (&candidate_2)->f = f_4;
    return candidate_2;
}

__device__ float facingSign(float transmission_0, float3  face_0, float3  direction_0)
{
    bool _S243 = transmission_0 > 0.0f;
    bool _S244;
    if(_S243)
    {
        _S244 = true;
    }
    else
    {
        _S244 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S245;
    if(_S244)
    {
        _S245 = 1.0f;
    }
    else
    {
        _S245 = -1.0f;
    }
    return _S245;
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
    bool _S246;
    if(open_0)
    {
        _S246 = prev_rough_0;
    }
    else
    {
        _S246 = false;
    }
    if(_S246)
    {
        _S246 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S246 = false;
    }
    return _S246;
}

__device__ bool withinInverseFootprint(float pdf_2, bool diffuse_0, float prev_cos_0, float distance_3, float threshold_1)
{
    bool _S247 = pdf_2 > 0.0f;
    bool _S248;
    if(_S247)
    {
        if(diffuse_0)
        {
            _S248 = true;
        }
        else
        {
            _S248 = (pdf_2 * prev_cos_0 / (distance_3 * distance_3) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S248 = false;
    }
    return _S248;
}

__device__ bool roughLobe(float pdf_3, bool diffuse_1, float roughness_0)
{
    bool _S249 = pdf_3 > 0.0f;
    bool _S250;
    if(_S249)
    {
        if(diffuse_1)
        {
            _S250 = true;
        }
        else
        {
            _S250 = roughness_0 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S250 = false;
    }
    return _S250;
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
    float _S251 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S251;
}

__device__ float2  temporalWeights(float c_1, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S252 = c_1 * p_c_0;
    float _S253 = c_t_0 * p_t_0;
    return make_float2 (_S252 / (_S252 + c_t_0 * g_previous_0), _S253 / (_S253 + c_1 * g_current_0));
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
    float _S254 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S255 = cos_a_0 > cos_b_0;
    float _S256 = _slang_select(_S255, 1.0f,_S254);
    return _S256;
}

__device__ float sinSubClamped(float sin_a_1, float cos_a_1, float sin_b_1, float cos_b_1)
{
    float _S257 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    bool _S258 = cos_a_1 > cos_b_1;
    float _S259 = _slang_select(_S258, 0.0f,_S257);
    return _S259;
}

__device__ float sine(float c_2)
{
    return (F32_sqrt(((F32_max((1.0f - c_2 * c_2), (0.0f))))));
}

__device__ float importance(LightNode node_0, float3  p_0, float3  normal_0)
{
    float3  _S260 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S261 = node_0.high - node_0.low;
    float3  _S262 = p_0 - _S260;
    float3  _S263 = ((((_S262)) * make_float3(rnorm3df(((_S262)).x, ((_S262)).y, ((_S262)).z))));
    float _S264 = dot_0(_S262, _S262);
    float _S265 = dot_0(_S261, _S261) / 4.0f;
    float _S266 = (F32_abs((dot_0(node_0.w, _S263))));
    float _S267 = sine(node_0.cos_theta_o);
    float _S268 = (F32_sqrt(((F32_max((1.0f - _S265 / _S264), (0.0f))))));
    bool _S269 = _S264 < _S265;
    float _S270 = _slang_select(_S269, -1.0f,_S268);
    float _S271 = sine(_S270);
    float _S272 = sine(_S266);
    float _S273 = cosSubClamped(_S272, _S266, _S267, node_0.cos_theta_o);
    float _S274 = sine(_S266);
    float _S275 = sinSubClamped(_S274, _S266, _S267, node_0.cos_theta_o);
    float _S276 = cosSubClamped(_S275, _S273, _S271, _S270);
    bool _S277 = _S276 <= 0.0f;
    if(_S277)
    {
        return 0.0f;
    }
    float _S278 = - dot_0(_S263, normal_0);
    float _S279 = node_0.phi * _S276 / (F32_max((_S264), (length_0(_S261) / 2.0f)));
    float _S280 = sine(_S278);
    float _S281 = cosSubClamped(_S280, _S278, _S271, _S270);
    bool _S282 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S283 = _slang_select(_S282, 1.0f,_S281);
    return (F32_max((_S279 * _S283), (0.0f)));
}

__device__ float solidAngle(float probability_0, float3  normal_1, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_1, toward_0))));
}

__device__ uint pickChild(LightNode first_0, LightNode second_0, float3  p_1, float3  normal_2, float * pick_0, float * probability_1)
{
    float _S284 = importance(first_0, p_1, normal_2);
    float _S285 = importance(second_0, p_1, normal_2);
    float2  _S286 = make_float2 (_S284, _S285);
    bool _S287 = _S284 == 0.0f;
    bool _S288;
    if(_S287)
    {
        _S288 = _S285 == 0.0f;
    }
    else
    {
        _S288 = false;
    }
    if(_S288)
    {
        return 2U;
    }
    float _S289 = _S284 + _S285;
    bool _S290 = _S285 > 0.0f;
    if(_S290)
    {
        _S288 = (*pick_0 * _S289) >= _S284;
    }
    else
    {
        _S288 = false;
    }
    uint _S291 = uint(_S288);
    float _S292 = (F32_min(((*pick_0 * _S289 - float(_S291) * _S284) / _slang_vector_get_element(_S286, _S291)), (0.99999994039535522f)));
    *pick_0 = _S292;
    float _S293 = *probability_1 * (_slang_vector_get_element(_S286, _S291) / _S289);
    *probability_1 = _S293;
    return _S291;
}

__device__ float childShare(LightNode first_1, LightNode second_1, float3  p_2, float3  normal_3, uint child_0)
{
    float _S294 = importance(first_1, p_2, normal_3);
    float _S295 = importance(second_1, p_2, normal_3);
    float2  _S296 = make_float2 (_S294, _S295);
    float _S297 = _slang_vector_get_element(_S296, child_0) / (_S294 + _S295);
    bool _S298 = _slang_vector_get_element(_S296, child_0) > 0.0f;
    float _S299 = _slang_select(_S298, _S297,0.0f);
    return _S299;
}

__device__ float powerHeuristic(float a_6, float b_2)
{
    float _S300 = 1.0f / (1.0f + b_2 / a_6 * (b_2 / a_6));
    bool _S301 = b_2 > 0.0f;
    float _S302 = _slang_select(_S301, _S300,1.0f);
    return _S302;
}

__device__ float sphereDensity(float3  center_0, float radius_1, float3  p_3)
{
    float3  _S303 = center_0 - p_3;
    float _S304 = radius_1 * radius_1 / dot_0(_S303, _S303);
    bool _S305 = _S304 >= 1.0f;
    if(_S305)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S304)))) / (6.28318548202514648f * _S304);
}

__device__ float3  sampleSphere(float3  center_1, float radius_2, float3  p_4, float u1_0, float u2_0)
{
    float3  _S306 = center_1 - p_4;
    float _S307 = radius_2 * radius_2 / dot_0(_S306, _S306);
    float _S308 = u1_0 * _S307 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S307), (0.0f)))))));
    float _S309 = 2.0f * u1_0;
    bool _S310 = _S307 >= 1.0f;
    float _S311 = _slang_select(_S310, _S309,_S308);
    float _S312 = (F32_sqrt(((F32_max((_S311 * (2.0f - _S311)), (0.0f))))));
    float _S313 = 6.28318548202514648f * u2_0;
    float3  _S314 = make_float3 (_S312 * (F32_cos((_S313))), 1.0f - _S311, _S312 * (F32_sin((_S313))));
    float3  _S315 = ((((_S306)) * make_float3(rnorm3df(((_S306)).x, ((_S306)).y, ((_S306)).z))));
    float3  _S316 = tangentToWorld(_S314, _S315);
    return _S316;
}

#undef Matrix
