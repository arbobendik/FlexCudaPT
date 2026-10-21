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

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_5, BSDFMaterial material_0, uint random_state_1)
{
    uint state_6 = random_state_1;
    float3  _S107 = negate_0(in_dir_0);
    float _S108 = sign_0(dot_0(n_5, _S107));
    float _S109 = material_0.roughness;
    float3  _S110 = sampleHalfVector(_S107, n_5 * make_float3 (_S108), _S109 * _S109, &state_6);
    return _S110;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_6, float eta_i_1, float eta_o_1)
{
    float3  _S111 = negate_0(in_dir_1);
    float3  _S112 = negate_0(make_float3 (eta_i_1) * _S111 + make_float3 (eta_o_1) * out_dir_0);
    float3  _S113 = ((((_S112)) * make_float3(rnorm3df(((_S112)).x, ((_S112)).y, ((_S112)).z))));
    float _S114 = sign_0(dot_0(n_6, _S111));
    float _S115 = sign_0(dot_0(_S112, n_6 * make_float3 (_S114)));
    return _S113 * make_float3 (_S115);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S116 = negate_0(in_dir_2);
    float3  _S117 = _S116 + out_dir_1;
    float3  _S118 = ((((_S117)) * make_float3(rnorm3df(((_S117)).x, ((_S117)).y, ((_S117)).z))));
    return _S118;
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
    BSDFLobes _S119;
    (&_S119)->v_dot_h = v_dot_h_0;
    (&_S119)->n_dot_h = n_dot_h_1;
    (&_S119)->refracted = refracted_0;
    (&_S119)->F = F_0;
    (&_S119)->F_greyscale = F_greyscale_0;
    (&_S119)->reflect_weight = reflect_weight_0;
    (&_S119)->diffuse_weight = diffuse_weight_0;
    (&_S119)->refract_weight = refract_weight_0;
    (&_S119)->p_diffuse = p_diffuse_0;
    (&_S119)->p_reflect = p_reflect_0;
    (&_S119)->p_refract = p_refract_0;
    return _S119;
}

__device__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_4, float3  n_i_1, float3  ggx_n_0, BSDFMaterial material_1, float eta_i_2, float eta_o_2)
{
    float _S120 = dot_0(ggx_n_0, v_4);
    float _S121 = dot_0(n_i_1, ggx_n_0);
    float _S122 = eta_i_2 / eta_o_2;
    float3  _S123 = refract_0(in_dir_3, ggx_n_0, _S122);
    float3  _S124 = ((((_S123)) * make_float3(rnorm3df(((_S123)).x, ((_S123)).y, ((_S123)).z))));
    float _S125 = fresnel((F32_abs((_S120))), eta_i_2, eta_o_2);
    float3  F_1 = mix_0(make_float3 (_S125), material_1.albedo, material_1.metallic);
    float _S126 = rgb_to_greyscale(F_1);
    float _S127 = (1.0f - material_1.transmission) * (1.0f - material_1.metallic);
    float _S128 = (F32_max((_S126), (0.0f)));
    float _S129 = 1.0f - _S126;
    float _S130 = (F32_max((_S127 * _S129), (0.0f)));
    float _S131 = material_1.transmission * _S129;
    float _S132 = sign_0(length_0(_S124));
    float _S133 = (F32_max((_S131 * _S132), (0.0f)));
    float _S134 = _S128 + _S130 + _S133;
    float _S135 = 1.0f / (F32_max((_S134), (0.0000152587890625f)));
    float _S136 = _S130 * _S135;
    float _S137 = _S128 * _S135;
    float _S138 = _S133 * _S135;
    return BSDFLobes_x24init_0(_S120, _S121, _S124, F_1, _S126, 1.0f, _S127, material_1.transmission, _S136, _S137, _S138);
}

__device__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_5, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S139 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    bool _S140 = n_i_dot_v_0 > 0.0f;
    float _S141 = _slang_select(_S140, _S139,0.0f);
    return _S141;
}

__device__ float3  diffuseBSDF(float3  l_0, float3  n_i_2, float alpha_6, BSDFMaterial material_2, BSDFLobes lobes_1)
{
    return make_float3 (lobes_1.diffuse_weight) * material_2.albedo / make_float3 (lobes_1.p_diffuse);
}

__device__ float vndfPDF(float n_i_dot_v_1, float alpha_7, BSDFLobes lobes_2)
{
    float _S142 = smithG1(alpha_7, n_i_dot_v_1);
    float _S143 = _S142 * lobes_2.v_dot_h;
    float _S144 = trowbridgeReitz(alpha_7, lobes_2.n_dot_h);
    float _S145 = _S143 * _S144 / n_i_dot_v_1;
    bool _S146 = alpha_7 > 0.0f;
    bool _S147;
    if(_S146)
    {
        _S147 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S147 = false;
    }
    if(_S147)
    {
        _S147 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S147 = false;
    }
    if(_S147)
    {
        _S147 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S147 = false;
    }
    float _S148 = _slang_select(_S147, _S145,0.0f);
    return _S148;
}

__device__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_8, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S149 = vndfPDF(n_i_dot_v_2, alpha_8, lobes_3);
    float _S150 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S151 = lobes_3.p_refract * _S149 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S150 * _S150);
    bool _S152 = eta_i_4 != eta_o_4;
    bool _S153;
    if(_S152)
    {
        _S153 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S153 = false;
    }
    float _S154 = _slang_select(_S153, _S151,0.0f);
    return _S154;
}

__device__ float3  refractBSDF(float3  l_1, float3  n_i_3, float alpha_9, BSDFMaterial material_3, BSDFLobes lobes_4)
{
    float _S155 = - dot_0(n_i_3, l_1);
    float _S156 = G1(alpha_9, (F32_max((_S155), (0.0f))));
    return make_float3 (lobes_4.refract_weight * _S156 * (1.0f - lobes_4.F_greyscale)) * material_3.albedo / make_float3 (lobes_4.p_refract);
}

__device__ float reflectPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_10, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S157 = vndfPDF(n_i_dot_v_3, alpha_10, lobes_5);
    float _S158 = lobes_5.p_reflect * _S157 / (4.0f * lobes_5.v_dot_h);
    bool _S159 = _S157 > 0.0f;
    float _S160 = _slang_select(_S159, _S158,0.0f);
    return _S160;
}

__device__ float3  reflectBSDF(float3  l_2, float3  n_i_4, float alpha_11, BSDFMaterial material_4, BSDFLobes lobes_6)
{
    float _S161 = dot_0(n_i_4, l_2);
    float _S162 = G1(alpha_11, (F32_max((_S161), (0.0f))));
    return make_float3 (lobes_6.reflect_weight * _S162) * lobes_6.F / make_float3 (lobes_6.p_reflect);
}

__device__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, float3  g_n_0, BSDFMaterial material_5, float eta_i_6, float eta_o_6, uint random_state_2)
{
    float3  _S163 = negate_0(in_dir_4);
    float _S164 = dot_0(n_7, _S163);
    float _S165 = sign_0(_S164);
    float3  _S166 = n_7 * make_float3 (_S165);
    float _S167 = dot_0(_S166, out_dir_2);
    float _S168 = material_5.roughness;
    float _S169 = _S168 * _S168;
    bool _S170 = (dot_0(g_n_0, _S163) * dot_0(g_n_0, out_dir_2)) > 0.0f;
    uint _S171;
    if(_S170)
    {
        _S171 = 2U;
    }
    else
    {
        _S171 = 1U;
    }
    float3  _S172 = make_float3 (0.0f);
    BSDFLobes _S173 = BSDFLobes_x24init_0(0.0f, 0.0f, _S172, _S172, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f);
    uint half_of_0 = 4294967295U;
    BSDFLobes lobe_terms_0 = _S173;
    float3  ggx_n_1 = _S172;
    float3  f_0 = _S172;
    uint i_10 = 0U;
    for(;;)
    {
        if(i_10 < _S171)
        {
        }
        else
        {
            break;
        }
        uint _S174;
        if(!_S170)
        {
            _S174 = 1U;
        }
        else
        {
            if(i_10 == 0U)
            {
                _S174 = 0U;
            }
            else
            {
                _S174 = 2U;
            }
        }
        bool _S175 = _S174 != half_of_0;
        float3  ggx_n_2;
        if(_S175)
        {
            bool _S176 = _S174 == 0U;
            if(_S176)
            {
                float3  _S177 = sampledHalf(in_dir_4, n_7, material_5, random_state_2);
                ggx_n_2 = _S177;
            }
            else
            {
                bool _S178 = _S174 == 1U;
                if(_S178)
                {
                    float3  _S179 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_6, eta_o_6);
                    ggx_n_2 = _S179;
                }
                else
                {
                    float3  _S180 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_2 = _S180;
                }
            }
            float3  _S181 = negate_0(in_dir_4);
            BSDFLobes _S182 = bsdfLobes(in_dir_4, _S181, _S166, ggx_n_2, material_5, eta_i_6, eta_o_6);
            lobe_terms_0 = _S182;
            half_of_0 = _S174;
        }
        else
        {
            ggx_n_2 = ggx_n_1;
        }
        float3  throughput_0;
        float pdf_0;
        switch(_S174)
        {
        case 0U:
            {
                float _S183 = diffusePDF(_S167, 0.0f, (F32_abs((_S164))), _S169, lobe_terms_0, eta_i_6, eta_o_6);
                float3  _S184 = diffuseBSDF(out_dir_2, _S166, _S169, material_5, lobe_terms_0);
                pdf_0 = _S183;
                throughput_0 = _S184;
                break;
            }
        case 1U:
            {
                float _S185 = refractPDF(_S167, dot_0(out_dir_2, ggx_n_2), (F32_abs((_S164))), _S169, lobe_terms_0, eta_i_6, eta_o_6);
                float3  _S186 = refractBSDF(out_dir_2, _S166, _S169, material_5, lobe_terms_0);
                pdf_0 = _S185;
                throughput_0 = _S186;
                break;
            }
        default:
            {
                float _S187 = reflectPDF(_S167, 0.0f, (F32_abs((_S164))), _S169, lobe_terms_0, eta_i_6, eta_o_6);
                float3  _S188 = reflectBSDF(out_dir_2, _S166, _S169, material_5, lobe_terms_0);
                pdf_0 = _S187;
                throughput_0 = _S188;
                break;
            }
        }
        float3  _S189;
        if(pdf_0 > 0.0f)
        {
            _S189 = throughput_0 * make_float3 (pdf_0);
        }
        else
        {
            _S189 = _S172;
        }
        if(i_10 == 0U)
        {
            f_0 = _S189;
        }
        else
        {
            f_0 = f_0 + _S189;
        }
        uint i_11 = i_10 + 1U;
        ggx_n_1 = ggx_n_2;
        i_10 = i_11;
    }
    return f_0;
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

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_0, float3  throughput_1, uint random_state_3, bool refracted_1, uint lobe_0, float pdf_1)
{
    SampleBSDF _S190;
    (&_S190)->unit_direction = unit_direction_0;
    (&_S190)->throughput = throughput_1;
    (&_S190)->random_state = random_state_3;
    (&_S190)->refracted = refracted_1;
    (&_S190)->lobe = lobe_0;
    (&_S190)->pdf = pdf_1;
    return _S190;
}

__device__ SampleBSDF diffuseSample(float3  n_i_5, float n_i_dot_v_4, float alpha_12, BSDFMaterial material_6, BSDFLobes lobes_7, float eta_i_7, float eta_o_7, uint random_state_4)
{
    float3  _S191 = make_float3 (1.0f);
    SampleBSDF _S192 = SampleBSDF_x24init_0(_S191, _S191, 0U, false, 0U, 0.0f);
    SampleBSDF sample_0 = _S192;
    Random _S193 = pcg(random_state_4);
    Random _S194 = pcg(_S193.state);
    (&sample_0)->random_state = _S194.state;
    float3  _S195 = sampleCosWeightedHemisphere(_S193.value, _S194.value);
    float3  _S196 = tangentToWorld(_S195, n_i_5);
    (&sample_0)->unit_direction = _S196;
    (&sample_0)->lobe = 0U;
    float3  _S197 = diffuseBSDF((&sample_0)->unit_direction, n_i_5, alpha_12, material_6, lobes_7);
    (&sample_0)->throughput = _S197;
    float _S198 = diffusePDF(_S195.y, 0.0f, n_i_dot_v_4, alpha_12, lobes_7, eta_i_7, eta_o_7);
    (&sample_0)->pdf = _S198;
    return sample_0;
}

__device__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_6, float n_i_dot_v_5, float alpha_13, BSDFMaterial material_7, BSDFLobes lobes_8, float eta_i_8, float eta_o_8, uint random_state_5)
{
    float3  _S199 = make_float3 (1.0f);
    SampleBSDF _S200 = SampleBSDF_x24init_0(_S199, _S199, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S200;
    (&sample_1)->unit_direction = lobes_8.refracted;
    (&sample_1)->random_state = random_state_5;
    (&sample_1)->refracted = true;
    (&sample_1)->lobe = 1U;
    float3  _S201 = refractBSDF((&sample_1)->unit_direction, n_i_6, alpha_13, material_7, lobes_8);
    (&sample_1)->throughput = _S201;
    float _S202 = refractPDF(0.0f, dot_0((&sample_1)->unit_direction, ggx_n_3), n_i_dot_v_5, alpha_13, lobes_8, eta_i_8, eta_o_8);
    (&sample_1)->pdf = _S202;
    return sample_1;
}

__device__ SampleBSDF reflectSample(float3  in_dir_5, float3  ggx_n_4, float3  n_i_7, float n_i_dot_v_6, float alpha_14, BSDFMaterial material_8, BSDFLobes lobes_9, float eta_i_9, float eta_o_9, uint random_state_6)
{
    float3  _S203 = make_float3 (1.0f);
    SampleBSDF _S204 = SampleBSDF_x24init_0(_S203, _S203, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S204;
    float3  _S205 = reflect_0(in_dir_5, ggx_n_4);
    float3  _S206 = ((((_S205)) * make_float3(rnorm3df(((_S205)).x, ((_S205)).y, ((_S205)).z))));
    (&sample_2)->unit_direction = _S206;
    (&sample_2)->random_state = random_state_6;
    (&sample_2)->lobe = 2U;
    float3  _S207 = reflectBSDF((&sample_2)->unit_direction, n_i_7, alpha_14, material_8, lobes_9);
    (&sample_2)->throughput = _S207;
    float _S208 = reflectPDF(0.0f, 0.0f, n_i_dot_v_6, alpha_14, lobes_9, eta_i_9, eta_o_9);
    (&sample_2)->pdf = _S208;
    return sample_2;
}

__device__ SampleBSDF sampleBSDF(float3  in_dir_6, float3  n_8, BSDFMaterial material_9, float eta_i_10, float eta_o_10, uint random_init_0, float2  screen_space_0)
{
    uint random_state_7 = random_init_0;
    float3  _S209 = negate_0(in_dir_6);
    float _S210 = dot_0(n_8, _S209);
    float _S211 = sign_0(_S210);
    float3  n_i_8 = n_8 * make_float3 (_S211);
    float _S212 = (F32_abs((_S210)));
    float _S213 = material_9.roughness;
    float _S214 = _S213 * _S213;
    float3  _S215 = sampleHalfVector(_S209, n_i_8, _S214, &random_state_7);
    BSDFLobes _S216 = bsdfLobes(in_dir_6, _S209, n_i_8, _S215, material_9, eta_i_10, eta_o_10);
    Random _S217 = pcg(random_state_7);
    random_state_7 = _S217.state;
    bool _S218 = (_S217.value) < (_S216.p_diffuse);
    if(_S218)
    {
        SampleBSDF _S219 = diffuseSample(n_i_8, _S212, _S214, material_9, _S216, eta_i_10, eta_o_10, random_state_7);
        return _S219;
    }
    bool _S220 = (_S217.value) < (_S216.p_diffuse + _S216.p_refract);
    if(_S220)
    {
        SampleBSDF _S221 = refractSample(_S215, n_i_8, _S212, _S214, material_9, _S216, eta_i_10, eta_o_10, random_state_7);
        return _S221;
    }
    SampleBSDF _S222 = reflectSample(in_dir_6, _S215, n_i_8, _S212, _S214, material_9, _S216, eta_i_10, eta_o_10, random_state_7);
    return _S222;
}

__device__ float3  pointLightRadiance(float3  color_0, float intensity_0, float radius_0)
{
    return color_0 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_0 * radius_0);
}

__device__ float3  beerLambert(float distance_1, float3  absorption_0)
{
    float3  _S223 = max_0(absorption_0, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_1) * log_0(_S223));
}

__device__ bool neeDecision(BSDFMaterial material_10, float n_dot_v_0, float eta_i_11, float eta_o_11)
{
    float _S224 = fresnel((F32_abs((n_dot_v_0))), eta_i_11, eta_o_11);
    float3  _S225 = mix_0(make_float3 (_S224), material_10.albedo, material_10.metallic);
    float _S226 = rgb_to_greyscale(_S225);
    float _S227 = (F32_max(((1.0f - _S226) * (1.0f - material_10.metallic) * (1.0f - material_10.transmission)), (0.0f)));
    bool _S228 = _S227 > 0.03999999910593033f;
    bool _S229;
    if(_S228)
    {
        _S229 = true;
    }
    else
    {
        _S229 = (material_10.roughness) > 0.20000000298023224f;
    }
    return _S229;
}

__device__ float3  misWeighted(float3  throughput_2, float lobe_pdf_0, float pdf_2, bool power_0)
{
    if(power_0)
    {
        float _S230 = lobe_pdf_0 / pdf_2;
        return throughput_2 * make_float3 (lobe_pdf_0) / make_float3 (pdf_2 * (1.0f + _S230 * _S230));
    }
    return throughput_2 * make_float3 (lobe_pdf_0) / make_float3 (lobe_pdf_0 + pdf_2);
}

static __device__ float3  neeLobes_0(float3  in_dir_7, float3  dir_0, float3  n_9, BSDFMaterial * material_11, float eta_i_12, float eta_o_12, bool refracted_2, float pdf_3, bool power_1, uint random_state_8, FixedArray<float3 , 3>  * each_0, uint * reached_0)
{
    float3  _S231 = negate_0(in_dir_7);
    float _S232 = dot_0(n_9, _S231);
    float _S233 = sign_0(_S232);
    float3  _S234 = n_9 * make_float3 (_S233);
    float _S235 = dot_0(_S234, dir_0);
    float _S236 = material_11->roughness * material_11->roughness;
    float3  _S237 = make_float3 (0.0f);
    *reached_0 = 0U;
    BSDFLobes _S238 = BSDFLobes_x24init_0(0.0f, 0.0f, _S237, _S237, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f);
    uint i_12 = 0U;
    for(;;)
    {
        if(i_12 < 3U)
        {
        }
        else
        {
            break;
        }
        (*each_0)[i_12] = _S237;
        uint i_13 = i_12 + 1U;
        i_12 = i_13;
    }
    uint half_of_1 = 4294967295U;
    BSDFLobes lobe_terms_1 = _S238;
    float3  ggx_n_5 = _S237;
    i_12 = 0U;
    float3  f_1 = _S237;
    for(;;)
    {
        if(i_12 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S239 = i_12 == 1U;
        bool _S240 = _S239 == refracted_2;
        float3  ggx_n_6;
        if(_S240)
        {
            bool _S241 = i_12 != half_of_1;
            uint half_of_2;
            BSDFLobes lobe_terms_2;
            if(_S241)
            {
                bool _S242 = i_12 == 0U;
                if(_S242)
                {
                    float3  _S243 = sampledHalf(in_dir_7, n_9, *material_11, random_state_8);
                    ggx_n_6 = _S243;
                }
                else
                {
                    if(_S239)
                    {
                        float3  _S244 = refractedHalf(in_dir_7, dir_0, n_9, eta_i_12, eta_o_12);
                        ggx_n_6 = _S244;
                    }
                    else
                    {
                        float3  _S245 = reflectedHalf(in_dir_7, dir_0);
                        ggx_n_6 = _S245;
                    }
                }
                float3  _S246 = negate_0(in_dir_7);
                BSDFLobes _S247 = bsdfLobes(in_dir_7, _S246, _S234, ggx_n_6, *material_11, eta_i_12, eta_o_12);
                lobe_terms_2 = _S247;
                half_of_2 = i_12;
            }
            else
            {
                lobe_terms_2 = lobe_terms_1;
                ggx_n_6 = ggx_n_5;
                half_of_2 = half_of_1;
            }
            float3  throughput_3;
            float lobe_pdf_1;
            switch(i_12)
            {
            case 0U:
                {
                    float _S248 = diffusePDF(_S235, 0.0f, (F32_abs((_S232))), _S236, lobe_terms_2, eta_i_12, eta_o_12);
                    float3  _S249 = diffuseBSDF(dir_0, _S234, _S236, *material_11, lobe_terms_2);
                    lobe_pdf_1 = _S248;
                    throughput_3 = _S249;
                    break;
                }
            case 1U:
                {
                    float _S250 = refractPDF(_S235, dot_0(dir_0, ggx_n_6), (F32_abs((_S232))), _S236, lobe_terms_2, eta_i_12, eta_o_12);
                    float3  _S251 = refractBSDF(dir_0, _S234, _S236, *material_11, lobe_terms_2);
                    lobe_pdf_1 = _S250;
                    throughput_3 = _S251;
                    break;
                }
            default:
                {
                    float _S252 = reflectPDF(_S235, 0.0f, (F32_abs((_S232))), _S236, lobe_terms_2, eta_i_12, eta_o_12);
                    float3  _S253 = reflectBSDF(dir_0, _S234, _S236, *material_11, lobe_terms_2);
                    lobe_pdf_1 = _S252;
                    throughput_3 = _S253;
                    break;
                }
            }
            bool _S254 = lobe_pdf_1 > 0.0f;
            float3  f_2;
            if(_S254)
            {
                float3  _S255 = misWeighted(throughput_3, lobe_pdf_1, pdf_3, power_1);
                (*each_0)[i_12] = _S255;
                uint _S256 = (*reached_0) | (1U << i_12);
                *reached_0 = _S256;
                float3  f_3 = f_1 + (*each_0)[i_12];
                f_2 = f_3;
            }
            else
            {
                f_2 = f_1;
            }
            half_of_1 = half_of_2;
            lobe_terms_1 = lobe_terms_2;
            f_1 = f_2;
        }
        else
        {
            ggx_n_6 = ggx_n_5;
        }
        uint i_14 = i_12 + 1U;
        ggx_n_5 = ggx_n_6;
        i_12 = i_14;
    }
    return f_1;
}

__device__ float3  neeBSDF(float3  in_dir_8, float3  dir_1, float3  n_10, BSDFMaterial material_12, float eta_i_13, float eta_o_13, bool refracted_3, float pdf_4, bool power_2, uint random_state_9)
{
    uint reached_1 = 0U;
    BSDFMaterial _S257 = material_12;
    FixedArray<float3 , 3>  each_1;
    float3  _S258 = neeLobes_0(in_dir_8, dir_1, n_10, &_S257, eta_i_13, eta_o_13, refracted_3, pdf_4, power_2, random_state_9, &each_1, &reached_1);
    return _S258;
}

__device__ float3  straightThrough(float3  dir_2, float3  n_11, BSDFMaterial material_13)
{
    float _S259 = rgb_to_greyscale(material_13.albedo * make_float3 (material_13.metallic));
    float _S260 = material_13.roughness;
    float _S261 = G1(_S260 * _S260, (F32_abs((dot_0(n_11, dir_2)))));
    return make_float3 (material_13.transmission * _S261 * (1.0f - _S259)) * material_13.albedo;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S262 = hash(index_0);
    uint _S263 = hash(seed_0 ^ _S262);
    return _S263;
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float3  _S264 = a_4 / b_0;
    float3  _S265 = make_float3 (0.0f);
    bool3  _S266 = b_0 == _S265;
    float3  _S267 = _slang_select(_S266, _S265,_S264);
    return _S267;
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
    float _S268 = rgb_to_greyscale(weight_0);
    bool _S269 = _S268 > 0.0f;
    bool _S270;
    if(_S269)
    {
        _S270 = _S268 < 3.00000000549775576e+38f;
    }
    else
    {
        _S270 = false;
    }
    bool _S271 = !_S270;
    if(_S271)
    {
        return;
    }
    float _S272 = sel_0->w_sum + _S268;
    sel_0->w_sum = _S272;
    float3  _S273 = sel_0->color + weight_0;
    sel_0->color = _S273;
    Random _S274 = pcg(sel_0->random_state);
    sel_0->random_state = _S274.state;
    bool _S275 = (_S274.value * sel_0->w_sum) <= _S268;
    if(_S275)
    {
        sel_0->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_1, Reservoir r_0, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_0;
    float3  _S276 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S276;
    float _S277 = r_0.jac * shifted_0.jac;
    (&candidate_1)->jac = _S277;
    offer(sel_1, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_0.w));
    return;
}

__device__ Reservoir finalize(Selection sel_2, float c_0)
{
    Reservoir r_1 = sel_2.r;
    float _S278 = rgb_to_greyscale((&r_1)->f);
    float _S279 = sel_2.w_sum / _S278;
    bool _S280 = _S278 > 0.0f;
    float _S281 = _slang_select(_S280, _S279,0.0f);
    (&r_1)->w = _S281;
    (&r_1)->c = c_0;
    return r_1;
}

static __device__ uint insertBits_0(uint e_1, uint newbits_0, uint offset_0, uint count_0)
{
    uint _S282 = (1U << count_0) - 1U;
    return (e_1 & (~(_S282 << offset_0))) | ((newbits_0 & _S282) << offset_0);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_0, float3  f_4)
{
    Reservoir candidate_2 = r_2;
    uint _S283 = insertBits_0(r_2.path, end_0, 0U, 5U);
    uint _S284 = insertBits_0(_S283, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S284;
    (&candidate_2)->f = f_4;
    return candidate_2;
}

__device__ float facingSign(float transmission_0, float3  face_0, float3  direction_0)
{
    bool _S285 = transmission_0 > 0.0f;
    bool _S286;
    if(_S285)
    {
        _S286 = true;
    }
    else
    {
        _S286 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S287;
    if(_S286)
    {
        _S287 = 1.0f;
    }
    else
    {
        _S287 = -1.0f;
    }
    return _S287;
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
    bool _S288;
    if(open_0)
    {
        _S288 = prev_rough_0;
    }
    else
    {
        _S288 = false;
    }
    if(_S288)
    {
        _S288 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S288 = false;
    }
    return _S288;
}

__device__ bool withinInverseFootprint(float pdf_5, bool diffuse_0, float prev_cos_0, float distance_3, float threshold_1)
{
    bool _S289 = pdf_5 > 0.0f;
    bool _S290;
    if(_S289)
    {
        if(diffuse_0)
        {
            _S290 = true;
        }
        else
        {
            _S290 = (pdf_5 * prev_cos_0 / (distance_3 * distance_3) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S290 = false;
    }
    return _S290;
}

__device__ bool roughLobe(float pdf_6, bool diffuse_1, float roughness_0)
{
    bool _S291 = pdf_6 > 0.0f;
    bool _S292;
    if(_S291)
    {
        if(diffuse_1)
        {
            _S292 = true;
        }
        else
        {
            _S292 = roughness_0 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S292 = false;
    }
    return _S292;
}

__device__ float survivalProbability(float3  throughput_4, float density_0)
{
    return (F32_min(((F32_max(((F32_max((throughput_4.x), ((F32_max((throughput_4.y), (throughput_4.z)))))) / density_0), (0.0f)))), (1.0f)));
}

static __device__ float interpolate_0(float a_5, float b_1, float t_3)
{
    return a_5 + (b_1 - a_5) * t_3;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S293 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S293;
}

__device__ float2  temporalWeights(float c_1, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S294 = c_1 * p_c_0;
    float _S295 = c_t_0 * p_t_0;
    return make_float2 (_S294 / (_S294 + c_t_0 * g_previous_0), _S295 / (_S295 + c_1 * g_current_0));
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
    float _S296 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S297 = cos_a_0 > cos_b_0;
    float _S298 = _slang_select(_S297, 1.0f,_S296);
    return _S298;
}

__device__ float sinSubClamped(float sin_a_1, float cos_a_1, float sin_b_1, float cos_b_1)
{
    float _S299 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    bool _S300 = cos_a_1 > cos_b_1;
    float _S301 = _slang_select(_S300, 0.0f,_S299);
    return _S301;
}

__device__ float sine(float c_2)
{
    return (F32_sqrt(((F32_max((1.0f - c_2 * c_2), (0.0f))))));
}

__device__ float importance(LightNode node_0, float3  p_0, float3  normal_0)
{
    float3  _S302 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S303 = node_0.high - node_0.low;
    float3  _S304 = p_0 - _S302;
    float3  _S305 = ((((_S304)) * make_float3(rnorm3df(((_S304)).x, ((_S304)).y, ((_S304)).z))));
    float _S306 = dot_0(_S304, _S304);
    float _S307 = dot_0(_S303, _S303) / 4.0f;
    float _S308 = (F32_abs((dot_0(node_0.w, _S305))));
    float _S309 = sine(node_0.cos_theta_o);
    float _S310 = (F32_sqrt(((F32_max((1.0f - _S307 / _S306), (0.0f))))));
    bool _S311 = _S306 < _S307;
    float _S312 = _slang_select(_S311, -1.0f,_S310);
    float _S313 = sine(_S312);
    float _S314 = sine(_S308);
    float _S315 = cosSubClamped(_S314, _S308, _S309, node_0.cos_theta_o);
    float _S316 = sine(_S308);
    float _S317 = sinSubClamped(_S316, _S308, _S309, node_0.cos_theta_o);
    float _S318 = cosSubClamped(_S317, _S315, _S313, _S312);
    bool _S319 = _S318 <= 0.0f;
    if(_S319)
    {
        return 0.0f;
    }
    float _S320 = - dot_0(_S305, normal_0);
    float _S321 = node_0.phi * _S318 / (F32_max((_S306), (length_0(_S303) / 2.0f)));
    float _S322 = sine(_S320);
    float _S323 = cosSubClamped(_S322, _S320, _S313, _S312);
    bool _S324 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S325 = _slang_select(_S324, 1.0f,_S323);
    return (F32_max((_S321 * _S325), (0.0f)));
}

__device__ float solidAngle(float probability_0, float3  normal_1, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_1, toward_0))));
}

__device__ uint pickChild(LightNode first_0, LightNode second_0, float3  p_1, float3  normal_2, float * pick_0, float * probability_1)
{
    float _S326 = importance(first_0, p_1, normal_2);
    float _S327 = importance(second_0, p_1, normal_2);
    float2  _S328 = make_float2 (_S326, _S327);
    bool _S329 = _S326 == 0.0f;
    bool _S330;
    if(_S329)
    {
        _S330 = _S327 == 0.0f;
    }
    else
    {
        _S330 = false;
    }
    if(_S330)
    {
        return 2U;
    }
    float _S331 = _S326 + _S327;
    bool _S332 = _S327 > 0.0f;
    if(_S332)
    {
        _S330 = (*pick_0 * _S331) >= _S326;
    }
    else
    {
        _S330 = false;
    }
    uint _S333 = uint(_S330);
    float _S334 = (F32_min(((*pick_0 * _S331 - float(_S333) * _S326) / _slang_vector_get_element(_S328, _S333)), (0.99999994039535522f)));
    *pick_0 = _S334;
    float _S335 = *probability_1 * (_slang_vector_get_element(_S328, _S333) / _S331);
    *probability_1 = _S335;
    return _S333;
}

__device__ float childShare(LightNode first_1, LightNode second_1, float3  p_2, float3  normal_3, uint child_0)
{
    float _S336 = importance(first_1, p_2, normal_3);
    float _S337 = importance(second_1, p_2, normal_3);
    float2  _S338 = make_float2 (_S336, _S337);
    float _S339 = _slang_vector_get_element(_S338, child_0) / (_S336 + _S337);
    bool _S340 = _slang_vector_get_element(_S338, child_0) > 0.0f;
    float _S341 = _slang_select(_S340, _S339,0.0f);
    return _S341;
}

__device__ float powerHeuristic(float a_6, float b_2)
{
    float _S342 = 1.0f / (1.0f + b_2 / a_6 * (b_2 / a_6));
    bool _S343 = b_2 > 0.0f;
    float _S344 = _slang_select(_S343, _S342,1.0f);
    return _S344;
}

__device__ float sphereDensity(float3  center_0, float radius_1, float3  p_3)
{
    float3  _S345 = center_0 - p_3;
    float _S346 = radius_1 * radius_1 / dot_0(_S345, _S345);
    bool _S347 = _S346 >= 1.0f;
    if(_S347)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S346)))) / (6.28318548202514648f * _S346);
}

__device__ float3  sampleSphere(float3  center_1, float radius_2, float3  p_4, float u1_0, float u2_0)
{
    float3  _S348 = center_1 - p_4;
    float _S349 = radius_2 * radius_2 / dot_0(_S348, _S348);
    float _S350 = u1_0 * _S349 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S349), (0.0f)))))));
    float _S351 = 2.0f * u1_0;
    bool _S352 = _S349 >= 1.0f;
    float _S353 = _slang_select(_S352, _S351,_S350);
    float _S354 = (F32_sqrt(((F32_max((_S353 * (2.0f - _S353)), (0.0f))))));
    float _S355 = 6.28318548202514648f * u2_0;
    float3  _S356 = make_float3 (_S354 * (F32_cos((_S355))), 1.0f - _S353, _S354 * (F32_sin((_S355))));
    float3  _S357 = ((((_S348)) * make_float3(rnorm3df(((_S348)).x, ((_S348)).y, ((_S348)).z))));
    float3  _S358 = tangentToWorld(_S356, _S357);
    return _S358;
}

#undef Matrix
