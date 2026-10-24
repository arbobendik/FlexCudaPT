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

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_2, float U1_0, float U2_0)
{
    float3  _S40 = make_float3 (alpha_2 * Ve_0.x, alpha_2 * Ve_0.y, Ve_0.z);
    float3  _S41 = ((((_S40)) * make_float3(rnorm3df(((_S40)).x, ((_S40)).y, ((_S40)).z))));
    float _S42 = _S41.x;
    float _S43 = _S41.y;
    float _S44 = _S42 * _S42 + _S43 * _S43;
    float3  _S45;
    if(_S44 > 0.0f)
    {
        float3  _S46 = make_float3 (- _S43, _S42, 0.0f);
        float _S47 = (rsqrtf((_S44)));
        _S45 = _S46 * make_float3 (_S47);
    }
    else
    {
        _S45 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S48 = cross_0(_S41, _S45);
    float _S49 = (F32_sqrt((U1_0)));
    float _S50 = 6.28318548202514648f * U2_0;
    float _S51 = _S49 * (F32_cos((_S50)));
    float t2_0 = _S49 * (F32_sin((_S50)));
    float _S52 = 0.5f * (1.0f + _S41.z);
    float t2_1 = (1.0f - _S52) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S51 * _S51)))))) + _S52 * t2_0;
    float3  _S53 = make_float3 (_S51) * _S45 + make_float3 (t2_1) * _S48;
    float _S54 = unshared_0(_S51);
    float _S55 = unshared_0(_S51);
    float3  _S56 = _S53 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S54 * _S55 - t2_1 * t2_1))))))) * _S41;
    float3  _S57 = make_float3 (alpha_2 * _S56.x, alpha_2 * _S56.y, (F32_max((0.0f), (_S56.z))));
    float3  _S58 = ((((_S57)) * make_float3(rnorm3df(((_S57)).x, ((_S57)).y, ((_S57)).z))));
    return _S58;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S59 = (F32_sqrt((random_1_0)));
    float _S60 = 6.28318548202514648f * random_2_0;
    float _S61 = _S59 * (F32_cos((_S60)));
    float _S62 = _S59 * (F32_sin((_S60)));
    float _S63 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S61 * _S61 - _S62 * _S62))))));
    return make_float3 (_S61, _S63, _S62);
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_2)
{
    float3  a_0 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S64 = (F32_abs((dot_0(n_2, a_0)))) > 0.9999847412109375f;
    float3  a_1;
    if(_S64)
    {
        float3  _S65 = make_float3 (1.0f, 0.0f, 0.0f);
        a_1 = _S65;
    }
    else
    {
        a_1 = a_0;
    }
    float3  _S66 = cross_0(n_2, a_1);
    float3  _S67 = ((((_S66)) * make_float3(rnorm3df(((_S66)).x, ((_S66)).y, ((_S66)).z))));
    float3  _S68 = cross_0(n_2, _S67);
    return make_float3 (v_0.x) * _S67 + make_float3 (v_0.y) * n_2 + make_float3 (v_0.z) * _S68;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
{
    float3  a_2 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S69 = (F32_abs((dot_0(n_3, a_2)))) > 0.9999847412109375f;
    float3  a_3;
    if(_S69)
    {
        float3  _S70 = make_float3 (1.0f, 0.0f, 0.0f);
        a_3 = _S70;
    }
    else
    {
        a_3 = a_2;
    }
    float3  _S71 = cross_0(n_3, a_3);
    float3  _S72 = ((((_S71)) * make_float3(rnorm3df(((_S71)).x, ((_S71)).y, ((_S71)).z))));
    float3  _S73 = cross_0(n_3, _S72);
    return make_float3 (dot_0(v_1, _S72), dot_0(v_1, n_3), dot_0(v_1, _S73));
}

static __device__ float3  negate_0(float3  x_14)
{
    return - x_14;
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_4)
{
    float3  _S74 = p1_0 - p0_0;
    float3  _S75 = p2_0 - p0_0;
    float2  _S76 = uv1_0 - uv0_0;
    float2  _S77 = uv2_0 - uv0_0;
    float _S78 = _S76.x;
    float _S79 = _S77.y;
    float _S80 = _S76.y;
    float _S81 = _S77.x;
    float _S82 = _S78 * _S79 - _S80 * _S81;
    float _S83 = 1.0f / _S82;
    float3  t_0 = (_S74 * make_float3 (_S79) - _S75 * make_float3 (_S80)) * make_float3 (_S83);
    float3  _S84 = (_S75 * make_float3 (_S78) - _S74 * make_float3 (_S81)) * make_float3 (_S83);
    float3  _S85 = t_0 - n_4 * make_float3 (dot_0(n_4, t_0));
    float3  t_1 = ((((_S85)) * make_float3(rnorm3df(((_S85)).x, ((_S85)).y, ((_S85)).z))));
    bool _S86 = (dot_0(cross_0(n_4, t_1), _S84)) > 0.0f;
    float3  t_2;
    if(_S86)
    {
        float3  _S87 = negate_0(t_1);
        t_2 = _S87;
    }
    else
    {
        t_2 = t_1;
    }
    float3  _S88 = cross_0(n_4, t_2);
    return makeMatrix<float, 3, 3> (t_2, _S88, n_4);
}

__device__ float3  tangentToWorldNormalMap(float3  v_2, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_2, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_0, float3  uvw_0, float3  position_0)
{
    float3  _S89 = t1_0 - t0_0;
    float3  _S90 = t2_2 - t0_0;
    float3  _S91 = t2_2 - t1_0;
    float _S92 = (F32_min((length_0(_S89)), ((F32_min((length_0(_S90)), (length_0(_S91)))))));
    float3  _S93 = make_float3 (distance_0(position_0, t0_0), distance_0(position_0, t1_0), distance_0(position_0, t2_2));
    float3  _S94 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S95 = dot_0(geometry_n_0, _S94);
    float3  _S96 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S97 = dot_0(geometry_n_0, _S96);
    float3  _S98 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S99 = acos_0(abs_0(make_float3 (_S95, _S97, dot_0(geometry_n_0, _S98))));
    float3  _S100 = clamp_0(tan_0(_S99), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S93 * _S100, uvw_0), 0.0f, _S92 * 0.125f);
}

__device__ float3  sampleHalfVector(float3  v_3, float3  n_i_0, float alpha_3, uint * random_state_0)
{
    Random _S101 = pcg(*random_state_0);
    Random _S102 = pcg(_S101.state);
    *random_state_0 = _S102.state;
    float3  _S103 = worldToTangent(v_3, n_i_0);
    float3  _S104 = sampleGGXVNDF(float3 {_S103.x, _S103.z, _S103.y}, alpha_3, _S101.value, _S102.value);
    float3  _S105 = float3 {_S104.x, _S104.z, _S104.y};
    float3  _S106 = tangentToWorld(_S105, n_i_0);
    return _S106;
}

static __device__ float sign_0(float e_0)
{
    float _S107;
    if(e_0 > 0.0f)
    {
        _S107 = 1.0f;
    }
    else
    {
        if(e_0 < 0.0f)
        {
            _S107 = -1.0f;
        }
        else
        {
            _S107 = 0.0f;
        }
    }
    return _S107;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_5, BSDFMaterial material_0, uint random_state_1)
{
    uint state_5 = random_state_1;
    float3  _S108 = negate_0(in_dir_0);
    float _S109 = sign_0(dot_0(n_5, _S108));
    float _S110 = material_0.roughness;
    float3  _S111 = sampleHalfVector(_S108, n_5 * make_float3 (_S109), _S110 * _S110, &state_5);
    return _S111;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_6, float eta_i_1, float eta_o_1)
{
    float3  _S112 = negate_0(in_dir_1);
    float3  _S113 = negate_0(make_float3 (eta_i_1) * _S112 + make_float3 (eta_o_1) * out_dir_0);
    float3  _S114 = ((((_S113)) * make_float3(rnorm3df(((_S113)).x, ((_S113)).y, ((_S113)).z))));
    float _S115 = sign_0(dot_0(n_6, _S112));
    float _S116 = sign_0(dot_0(_S113, n_6 * make_float3 (_S115)));
    return _S114 * make_float3 (_S116);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S117 = negate_0(in_dir_2);
    float3  _S118 = _S117 + out_dir_1;
    float3  _S119 = ((((_S118)) * make_float3(rnorm3df(((_S118)).x, ((_S118)).y, ((_S118)).z))));
    return _S119;
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
    BSDFLobes _S120;
    (&_S120)->v_dot_h = v_dot_h_0;
    (&_S120)->n_dot_h = n_dot_h_1;
    (&_S120)->refracted = refracted_0;
    (&_S120)->F = F_0;
    (&_S120)->F_greyscale = F_greyscale_0;
    (&_S120)->reflect_weight = reflect_weight_0;
    (&_S120)->diffuse_weight = diffuse_weight_0;
    (&_S120)->refract_weight = refract_weight_0;
    (&_S120)->p_diffuse = p_diffuse_0;
    (&_S120)->p_reflect = p_reflect_0;
    (&_S120)->p_refract = p_refract_0;
    (&_S120)->translucent_share = translucent_share_0;
    return _S120;
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_4, float3  n_i_1, float3  ggx_n_0, BSDFMaterial material_1, float eta_i_2, float eta_o_2)
{
    float _S121 = dot_0(ggx_n_0, v_4);
    float _S122 = dot_0(n_i_1, ggx_n_0);
    float _S123 = eta_i_2 / eta_o_2;
    float3  _S124 = refract_0(in_dir_3, ggx_n_0, _S123);
    float3  _S125 = ((((_S124)) * make_float3(rnorm3df(((_S124)).x, ((_S124)).y, ((_S124)).z))));
    float _S126 = (F32_min(((F32_sqrt((material_1.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S127 = _S126 * _S126;
    float _S128 = (1.0f + _S126) / (1.0f - _S126);
    float _S129 = (F32_abs((_S121)));
    bool _S130 = eta_i_2 > eta_o_2;
    float _S131;
    if(_S130)
    {
        _S131 = _S128;
    }
    else
    {
        _S131 = 1.0f;
    }
    float _S132;
    if(_S130)
    {
        _S132 = 1.0f;
    }
    else
    {
        _S132 = _S128;
    }
    float _S133 = fresnel(_S129, _S131, _S132);
    bool _S134 = (eta_i_2 * eta_i_2 * (1.0f - _S121 * _S121)) >= (eta_o_2 * eta_o_2);
    float3  _S135;
    if(_S134)
    {
        _S135 = make_float3 (1.0f);
    }
    else
    {
        float3  _S136 = material_1.specular_tint * make_float3 (_S127);
        _S135 = _S136 + (make_float3 (1.0f) - _S136) * make_float3 (_S133 - _S127) / make_float3 (1.0f - _S127);
    }
    float3  F_1 = mix_0(_S135, material_1.albedo, material_1.metallic);
    float _S137 = rgb_to_greyscale(F_1);
    float _S138 = 1.0f - material_1.metallic;
    float3  _S139 = make_float3 (1.0f) - _S135;
    float3  _S140 = make_float3 ((1.0f - material_1.transmission) * _S138) * _S139;
    float3  _S141 = make_float3 (material_1.transmission * _S138) * _S139;
    float _S142 = (F32_max((_S137), (0.0f)));
    float _S143 = rgb_to_greyscale(_S140);
    float _S144 = (F32_max((_S143), (0.0f)));
    float _S145 = rgb_to_greyscale(_S141);
    float _S146 = sign_0(length_0(_S125));
    float _S147 = (F32_max((_S145 * _S146), (0.0f)));
    float _S148 = _S142 + _S144 + _S147;
    float _S149 = 1.0f / (F32_max((_S148), (0.0000152587890625f)));
    float _S150 = _S144 * _S149;
    float _S151 = _S142 * _S149;
    float _S152 = _S147 * _S149;
    return BSDFLobes_x24init_0(_S121, _S122, _S125, F_1, _S137, 1.0f, _S140, _S141, _S150, _S151, _S152, 0.0f);
}

__device__ float translucentShare(BSDFMaterial material_2)
{
    float _S153 = rgb_to_greyscale(material_2.translucent);
    float _S154 = rgb_to_greyscale(material_2.albedo);
    float _S155 = _S153 / (_S154 + _S153);
    bool _S156 = _S153 > 0.0f;
    float _S157 = _slang_select(_S156, _S155,0.0f);
    return _S157;
}

__device__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S158 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S159 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S160 = 1.0f - lobes_0.translucent_share;
    bool _S161 = n_i_dot_l_0 < 0.0f;
    float _S162 = _slang_select(_S161, lobes_0.translucent_share,_S160);
    float _S163 = _S159 * _S162;
    bool _S164 = (lobes_0.translucent_share) > 0.0f;
    float _S165 = _slang_select(_S164, _S163,_S158);
    bool _S166 = n_i_dot_v_0 > 0.0f;
    float _S167 = _slang_select(_S166, _S165,0.0f);
    return _S167;
}

__device__ float3  diffuseBSDF(float3  l_0, float3  n_i_2, float alpha_5, BSDFMaterial material_3, BSDFLobes lobes_1)
{
    bool _S168 = (dot_0(n_i_2, l_0)) < 0.0f;
    float3  _S169 = _slang_select(_S168, material_3.translucent,material_3.albedo);
    float _S170 = 1.0f - lobes_1.translucent_share;
    float _S171 = _slang_select(_S168, lobes_1.translucent_share,_S170);
    float3  _S172 = _S169 / make_float3 (_S171);
    bool _S173 = (lobes_1.translucent_share) > 0.0f;
    float3  _S174 = _slang_select(_S173, _S172,material_3.albedo);
    return lobes_1.diffuse_weight * _S174 / make_float3 (lobes_1.p_diffuse);
}

__device__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S175 = smithG1(alpha_6, n_i_dot_v_1);
    float _S176 = _S175 * lobes_2.v_dot_h;
    float _S177 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S178 = _S176 * _S177 / n_i_dot_v_1;
    bool _S179 = alpha_6 > 0.0f;
    bool _S180;
    if(_S179)
    {
        _S180 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S180 = false;
    }
    if(_S180)
    {
        _S180 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S180 = false;
    }
    if(_S180)
    {
        _S180 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S180 = false;
    }
    float _S181 = _slang_select(_S180, _S178,0.0f);
    return _S181;
}

__device__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S182 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S183 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S184 = lobes_3.p_refract * _S182 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S183 * _S183);
    bool _S185 = eta_i_4 != eta_o_4;
    bool _S186;
    if(_S185)
    {
        _S186 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S186 = false;
    }
    float _S187 = _slang_select(_S186, _S184,0.0f);
    return _S187;
}

__device__ float3  refractBSDF(float3  l_1, float3  n_i_3, float alpha_8, BSDFMaterial material_4, BSDFLobes lobes_4)
{
    float _S188 = - dot_0(n_i_3, l_1);
    float _S189 = smithG1(alpha_8, (F32_max((_S188), (0.0f))));
    return lobes_4.refract_weight * make_float3 (_S189) * material_4.albedo / make_float3 (lobes_4.p_refract);
}

__device__ float reflectPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S190 = vndfPDF(n_i_dot_v_3, alpha_9, lobes_5);
    float _S191 = lobes_5.p_reflect * _S190 / (4.0f * lobes_5.v_dot_h);
    bool _S192 = _S190 > 0.0f;
    float _S193 = _slang_select(_S192, _S191,0.0f);
    return _S193;
}

__device__ float3  reflectBSDF(float3  l_2, float3  n_i_4, float alpha_10, BSDFMaterial material_5, BSDFLobes lobes_6)
{
    float _S194 = dot_0(n_i_4, l_2);
    float _S195 = smithG1(alpha_10, (F32_max((_S194), (0.0f))));
    return make_float3 (lobes_6.reflect_weight * _S195) * lobes_6.F / make_float3 (lobes_6.p_reflect);
}

__device__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_6, float eta_i_6, float eta_o_6, bool refracted_1, uint random_state_2, FixedArray<float3 , 3>  * throughputs_0, FixedArray<float, 3>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S196 = negate_0(in_dir_4);
    float _S197 = dot_0(n_7, _S196);
    float _S198 = sign_0(_S197);
    float3  _S199 = n_7 * make_float3 (_S198);
    float _S200 = dot_0(_S199, out_dir_2);
    float _S201 = material_6.roughness;
    float _S202 = _S201 * _S201;
    float _S203 = rgb_to_greyscale(material_6.translucent);
    bool _S204 = _S203 > 0.0f;
    bool _S205 = (dot_0(n_7, out_dir_2) * _S197) < 0.0f;
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
        float3  _S206 = make_float3 (0.0f);
        (*throughputs_0)[i_10] = _S206;
        (*pdfs_0)[i_10] = 0.0f;
        uint i_11 = i_10 + 1U;
        i_10 = i_11;
    }
    float3  _S207 = make_float3 (0.0f);
    BSDFLobes _S208 = BSDFLobes_x24init_0(0.0f, 0.0f, _S207, _S207, 0.0f, 0.0f, _S207, _S207, 0.0f, 0.0f, 0.0f, 0.0f);
    BSDFLobes lobe_terms_0 = _S208;
    uint half_of_0 = 4294967295U;
    float3  ggx_n_2 = _S207;
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
        bool _S209 = i_10 == 0U;
        bool _S210;
        if(_S209)
        {
            _S210 = _S204;
        }
        else
        {
            _S210 = false;
        }
        bool _S211;
        if(_S210)
        {
            _S211 = _S205;
        }
        else
        {
            _S211 = i_10 == 1U;
        }
        bool _S212 = _S211 != refracted_1;
        if(_S212)
        {
            ggx_n_1 = ggx_n_2;
            uint i_12 = i_10 + 1U;
            ggx_n_2 = ggx_n_1;
            i_10 = i_12;
            continue;
        }
        bool _S213 = i_10 != half_of_0;
        uint half_of_1;
        if(_S213)
        {
            if(_S209)
            {
                float3  _S214 = sampledHalf(in_dir_4, n_7, material_6, random_state_2);
                ggx_n_1 = _S214;
            }
            else
            {
                bool _S215 = i_10 == 1U;
                if(_S215)
                {
                    float3  _S216 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_6, eta_o_6);
                    ggx_n_1 = _S216;
                }
                else
                {
                    float3  _S217 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S217;
                }
            }
            float3  _S218 = negate_0(in_dir_4);
            BSDFLobes _S219 = bsdfLobes(in_dir_4, _S218, _S199, ggx_n_1, material_6, eta_i_6, eta_o_6);
            lobe_terms_0 = _S219;
            float _S220 = translucentShare(material_6);
            (&lobe_terms_0)->translucent_share = _S220;
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
                float _S221 = diffusePDF(_S200, 0.0f, (F32_abs((_S197))), _S202, lobe_terms_0, eta_i_6, eta_o_6);
                (*pdfs_0)[int(0)] = _S221;
                float3  _S222 = diffuseBSDF(out_dir_2, _S199, _S202, material_6, lobe_terms_0);
                (*throughputs_0)[int(0)] = _S222;
                break;
            }
        case 1U:
            {
                float _S223 = refractPDF(_S200, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S197))), _S202, lobe_terms_0, eta_i_6, eta_o_6);
                (*pdfs_0)[int(1)] = _S223;
                float3  _S224 = refractBSDF(out_dir_2, _S199, _S202, material_6, lobe_terms_0);
                (*throughputs_0)[int(1)] = _S224;
                break;
            }
        default:
            {
                float _S225 = reflectPDF(_S200, 0.0f, (F32_abs((_S197))), _S202, lobe_terms_0, eta_i_6, eta_o_6);
                (*pdfs_0)[int(2)] = _S225;
                float3  _S226 = reflectBSDF(out_dir_2, _S199, _S202, material_6, lobe_terms_0);
                (*throughputs_0)[int(2)] = _S226;
                break;
            }
        }
        half_of_0 = half_of_1;
        uint i_12 = i_10 + 1U;
        ggx_n_2 = ggx_n_1;
        i_10 = i_12;
    }
    i_10 = 0U;
    ggx_n_1 = _S207;
    for(;;)
    {
        if(i_10 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S227 = ((*pdfs_0)[i_10]) > 0.0f;
        if(_S227)
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
    SampleBSDF _S228;
    (&_S228)->unit_direction = unit_direction_0;
    (&_S228)->throughput = throughput_0;
    (&_S228)->random_state = random_state_3;
    (&_S228)->refracted = refracted_2;
    (&_S228)->lobe = lobe_0;
    (&_S228)->pdf = pdf_0;
    return _S228;
}

__device__ SampleBSDF diffuseSample(float u_0, float3  n_i_5, float n_i_dot_v_4, float alpha_11, BSDFMaterial material_7, BSDFLobes lobes_7, float eta_i_7, float eta_o_7, uint random_state_4)
{
    float3  _S229 = make_float3 (1.0f);
    SampleBSDF _S230 = SampleBSDF_x24init_0(_S229, _S229, 0U, false, 0U, 0.0f);
    SampleBSDF sample_0 = _S230;
    Random _S231 = pcg(random_state_4);
    Random _S232 = pcg(_S231.state);
    (&sample_0)->random_state = _S232.state;
    float3  _S233 = sampleCosWeightedHemisphere(_S231.value, _S232.value);
    bool _S234 = u_0 < (lobes_7.p_diffuse * lobes_7.translucent_share);
    float _S235 = _S233.y;
    float _S236 = - _S235;
    float _S237 = _slang_select(_S234, _S236,_S235);
    float3  _S238 = tangentToWorld(make_float3 (_S233.x, _S237, _S233.z), n_i_5);
    (&sample_0)->unit_direction = _S238;
    (&sample_0)->refracted = _S234;
    (&sample_0)->lobe = 0U;
    float3  _S239 = diffuseBSDF((&sample_0)->unit_direction, n_i_5, alpha_11, material_7, lobes_7);
    (&sample_0)->throughput = _S239;
    float _S240 = diffusePDF(_S237, 0.0f, n_i_dot_v_4, alpha_11, lobes_7, eta_i_7, eta_o_7);
    (&sample_0)->pdf = _S240;
    return sample_0;
}

__device__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_6, float n_i_dot_v_5, float alpha_12, BSDFMaterial material_8, BSDFLobes lobes_8, float eta_i_8, float eta_o_8, uint random_state_5)
{
    float3  _S241 = make_float3 (1.0f);
    SampleBSDF _S242 = SampleBSDF_x24init_0(_S241, _S241, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S242;
    (&sample_1)->unit_direction = lobes_8.refracted;
    (&sample_1)->random_state = random_state_5;
    (&sample_1)->refracted = true;
    (&sample_1)->lobe = 1U;
    float3  _S243 = refractBSDF((&sample_1)->unit_direction, n_i_6, alpha_12, material_8, lobes_8);
    (&sample_1)->throughput = _S243;
    float _S244 = refractPDF(0.0f, dot_0((&sample_1)->unit_direction, ggx_n_3), n_i_dot_v_5, alpha_12, lobes_8, eta_i_8, eta_o_8);
    (&sample_1)->pdf = _S244;
    return sample_1;
}

__device__ SampleBSDF reflectSample(float3  in_dir_5, float3  ggx_n_4, float3  n_i_7, float n_i_dot_v_6, float alpha_13, BSDFMaterial material_9, BSDFLobes lobes_9, float eta_i_9, float eta_o_9, uint random_state_6)
{
    float3  _S245 = make_float3 (1.0f);
    SampleBSDF _S246 = SampleBSDF_x24init_0(_S245, _S245, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S246;
    float3  _S247 = reflect_0(in_dir_5, ggx_n_4);
    float3  _S248 = ((((_S247)) * make_float3(rnorm3df(((_S247)).x, ((_S247)).y, ((_S247)).z))));
    (&sample_2)->unit_direction = _S248;
    (&sample_2)->random_state = random_state_6;
    (&sample_2)->lobe = 2U;
    float3  _S249 = reflectBSDF((&sample_2)->unit_direction, n_i_7, alpha_13, material_9, lobes_9);
    (&sample_2)->throughput = _S249;
    float _S250 = reflectPDF(0.0f, 0.0f, n_i_dot_v_6, alpha_13, lobes_9, eta_i_9, eta_o_9);
    (&sample_2)->pdf = _S250;
    return sample_2;
}

__device__ SampleBSDF sampleBSDF(float3  in_dir_6, float3  n_8, BSDFMaterial material_10, float eta_i_10, float eta_o_10, uint random_init_0, float2  screen_space_0)
{
    uint random_state_7 = random_init_0;
    float3  _S251 = negate_0(in_dir_6);
    float _S252 = dot_0(n_8, _S251);
    float _S253 = sign_0(_S252);
    float3  n_i_8 = n_8 * make_float3 (_S253);
    float _S254 = (F32_abs((_S252)));
    float _S255 = material_10.roughness;
    float _S256 = _S255 * _S255;
    float3  _S257 = sampleHalfVector(_S251, n_i_8, _S256, &random_state_7);
    BSDFLobes _S258 = bsdfLobes(in_dir_6, _S251, n_i_8, _S257, material_10, eta_i_10, eta_o_10);
    BSDFLobes lobes_10 = _S258;
    float _S259 = translucentShare(material_10);
    (&lobes_10)->translucent_share = _S259;
    Random _S260 = pcg(random_state_7);
    random_state_7 = _S260.state;
    bool _S261 = (_S260.value) < ((&lobes_10)->p_diffuse);
    if(_S261)
    {
        SampleBSDF _S262 = diffuseSample(_S260.value, n_i_8, _S254, _S256, material_10, lobes_10, eta_i_10, eta_o_10, random_state_7);
        return _S262;
    }
    bool _S263 = (_S260.value) < ((&lobes_10)->p_diffuse + (&lobes_10)->p_refract);
    if(_S263)
    {
        SampleBSDF _S264 = refractSample(_S257, n_i_8, _S254, _S256, material_10, lobes_10, eta_i_10, eta_o_10, random_state_7);
        return _S264;
    }
    SampleBSDF _S265 = reflectSample(in_dir_6, _S257, n_i_8, _S254, _S256, material_10, lobes_10, eta_i_10, eta_o_10, random_state_7);
    return _S265;
}

__device__ float3  pointLightRadiance(float3  color_0, float intensity_0, float radius_0)
{
    return color_0 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_0 * radius_0);
}

__device__ float3  beerLambert(float distance_1, float3  absorption_0)
{
    float3  _S266 = max_0(absorption_0, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_1) * log_0(_S266));
}

__device__ bool neeDecision(BSDFMaterial material_11, float n_dot_v_0, float eta_i_11, float eta_o_11)
{
    float _S267 = fresnel((F32_abs((n_dot_v_0))), eta_i_11, eta_o_11);
    float3  _S268 = mix_0(make_float3 (_S267), material_11.albedo, material_11.metallic);
    float _S269 = rgb_to_greyscale(_S268);
    float _S270 = (F32_max(((1.0f - _S269) * (1.0f - material_11.metallic) * (1.0f - material_11.transmission)), (0.0f)));
    bool _S271 = _S270 > 0.03999999910593033f;
    bool _S272;
    if(_S271)
    {
        _S272 = true;
    }
    else
    {
        _S272 = (material_11.roughness) > 0.20000000298023224f;
    }
    return _S272;
}

__device__ float3  straightThrough(float3  dir_0, float3  n_9, BSDFMaterial material_12)
{
    float _S273 = material_12.transmission * (1.0f - material_12.metallic);
    float _S274 = material_12.roughness;
    float _S275 = smithG1(_S274 * _S274, (F32_abs((dot_0(n_9, dir_0)))));
    return make_float3 (_S273 * _S275) * material_12.albedo;
}

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_0, float3  end_0)
{
    float _S276 = sign_0(dot_0(light_n_0, start_0 - end_0));
    return light_n_0 * make_float3 (_S276 * light_offset_0);
}

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

__device__ float3  occluderTransmittance(float3  toward_0, float3  n_10, BSDFMaterial material_13, float coverage_0)
{
    float3  _S277;
    if((material_13.ior) == 1.0f)
    {
        float3  _S278 = straightThrough(toward_0, n_10, material_13);
        _S277 = _S278;
    }
    else
    {
        _S277 = make_float3 (0.0f);
    }
    return _S277 * make_float3 (coverage_0) + make_float3 (1.0f - coverage_0);
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S279 = hash(index_0);
    uint _S280 = hash(seed_0 ^ _S279);
    return _S280;
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float3  _S281 = a_4 / b_0;
    float3  _S282 = make_float3 (0.0f);
    bool3  _S283 = b_0 == _S282;
    float3  _S284 = _slang_select(_S283, _S282,_S281);
    return _S284;
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
    float _S285 = rgb_to_greyscale(weight_0);
    bool _S286 = _S285 > 0.0f;
    bool _S287;
    if(_S286)
    {
        _S287 = _S285 < 3.00000000549775576e+38f;
    }
    else
    {
        _S287 = false;
    }
    bool _S288 = !_S287;
    if(_S288)
    {
        return;
    }
    float _S289 = sel_0->w_sum + _S285;
    sel_0->w_sum = _S289;
    float3  _S290 = sel_0->color + weight_0;
    sel_0->color = _S290;
    Random _S291 = pcg(sel_0->random_state);
    sel_0->random_state = _S291.state;
    bool _S292 = (_S291.value * sel_0->w_sum) <= _S285;
    if(_S292)
    {
        sel_0->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_1, Reservoir r_0, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_0;
    float3  _S293 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S293;
    float _S294 = r_0.jac * shifted_0.jac;
    (&candidate_1)->jac = _S294;
    offer(sel_1, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_0.w));
    return;
}

__device__ Reservoir finalize(Selection sel_2, float c_0)
{
    Reservoir r_1 = sel_2.r;
    float _S295 = rgb_to_greyscale((&r_1)->f);
    float _S296 = sel_2.w_sum / _S295;
    bool _S297 = _S295 > 0.0f;
    float _S298 = _slang_select(_S297, _S296,0.0f);
    (&r_1)->w = _S298;
    (&r_1)->c = c_0;
    return r_1;
}

static __device__ uint insertBits_0(uint e_1, uint newbits_0, uint offset_0, uint count_0)
{
    uint _S299 = (1U << count_0) - 1U;
    return (e_1 & (~(_S299 << offset_0))) | ((newbits_0 & _S299) << offset_0);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_1, float3  f_1)
{
    Reservoir candidate_2 = r_2;
    uint _S300 = insertBits_0(r_2.path, end_1, 0U, 5U);
    uint _S301 = insertBits_0(_S300, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S301;
    (&candidate_2)->f = f_1;
    return candidate_2;
}

__device__ float facingSign(float transmission_0, float3  face_0, float3  direction_0)
{
    bool _S302 = transmission_0 > 0.0f;
    bool _S303;
    if(_S302)
    {
        _S303 = true;
    }
    else
    {
        _S303 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S304;
    if(_S303)
    {
        _S304 = 1.0f;
    }
    else
    {
        _S304 = -1.0f;
    }
    return _S304;
}

__device__ float survivalProbability(float3  throughput_1, float density_0)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_0), (0.0f)))), (1.0f)));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S305 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S306 = cos_a_0 > cos_b_0;
    float _S307 = _slang_select(_S306, 1.0f,_S305);
    return _S307;
}

__device__ float sine(float c_1)
{
    return (F32_sqrt(((F32_max((1.0f - c_1 * c_1), (0.0f))))));
}

__device__ float importance(LightNode node_0, float3  p_0, float3  normal_0)
{
    float3  _S308 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S309 = node_0.high - node_0.low;
    float3  _S310 = p_0 - _S308;
    float3  _S311 = ((((_S310)) * make_float3(rnorm3df(((_S310)).x, ((_S310)).y, ((_S310)).z))));
    float _S312 = dot_0(_S310, _S310);
    float _S313 = dot_0(_S309, _S309) / 4.0f;
    float _S314 = (F32_abs((dot_0(node_0.w, _S311))));
    float _S315 = sine(node_0.cos_theta_o);
    float _S316 = (F32_sqrt(((F32_max((1.0f - _S313 / _S312), (0.0f))))));
    bool _S317 = _S312 < _S313;
    float _S318 = _slang_select(_S317, -1.0f,_S316);
    float _S319 = sine(_S318);
    float _S320 = sine(_S314);
    float _S321 = cosSubClamped(_S320, _S314, _S315, node_0.cos_theta_o);
    float _S322 = sine(_S314);
    float _S323 = _S322 * node_0.cos_theta_o - _S314 * _S315;
    bool _S324 = _S314 > (node_0.cos_theta_o);
    float _S325 = _slang_select(_S324, 0.0f,_S323);
    float _S326 = cosSubClamped(_S325, _S321, _S319, _S318);
    bool _S327 = _S326 <= 0.0f;
    if(_S327)
    {
        return 0.0f;
    }
    float _S328 = - dot_0(_S311, normal_0);
    float _S329 = node_0.phi * _S326 / (F32_max((_S312), (length_0(_S309) / 2.0f)));
    float _S330 = sine(_S328);
    float _S331 = cosSubClamped(_S330, _S328, _S319, _S318);
    bool _S332 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S333 = _slang_select(_S332, 1.0f,_S331);
    return (F32_max((_S329 * _S333), (0.0f)));
}

__device__ float solidAngle(float probability_0, float3  normal_1, float3  toward_1)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_1)), (3.0f))) / (F32_abs((dot_0(normal_1, toward_1))));
}

__device__ uint pickChild(LightNode first_0, LightNode second_0, float3  p_1, float3  normal_2, float * pick_0, float * probability_1)
{
    float _S334 = importance(first_0, p_1, normal_2);
    float _S335 = importance(second_0, p_1, normal_2);
    float2  _S336 = make_float2 (_S334, _S335);
    bool _S337 = _S334 == 0.0f;
    bool _S338;
    if(_S337)
    {
        _S338 = _S335 == 0.0f;
    }
    else
    {
        _S338 = false;
    }
    if(_S338)
    {
        return 2U;
    }
    float _S339 = _S334 + _S335;
    bool _S340 = _S335 > 0.0f;
    if(_S340)
    {
        _S338 = (*pick_0 * _S339) >= _S334;
    }
    else
    {
        _S338 = false;
    }
    uint _S341 = uint(_S338);
    float _S342 = (F32_min(((*pick_0 * _S339 - float(_S341) * _S334) / _slang_vector_get_element(_S336, _S341)), (0.99999994039535522f)));
    *pick_0 = _S342;
    float _S343 = *probability_1 * (_slang_vector_get_element(_S336, _S341) / _S339);
    *probability_1 = _S343;
    return _S341;
}

__device__ float childShare(LightNode first_1, LightNode second_1, float3  p_2, float3  normal_3, uint child_0)
{
    float _S344 = importance(first_1, p_2, normal_3);
    float _S345 = importance(second_1, p_2, normal_3);
    float2  _S346 = make_float2 (_S344, _S345);
    float _S347 = _slang_vector_get_element(_S346, child_0) / (_S344 + _S345);
    bool _S348 = _slang_vector_get_element(_S346, child_0) > 0.0f;
    float _S349 = _slang_select(_S348, _S347,0.0f);
    return _S349;
}

__device__ float powerHeuristic(float a_5, float b_1)
{
    float _S350 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    bool _S351 = b_1 > 0.0f;
    float _S352 = _slang_select(_S351, _S350,1.0f);
    return _S352;
}

__device__ float sphereDensity(float3  center_0, float radius_1, float3  p_3)
{
    float3  _S353 = center_0 - p_3;
    float _S354 = radius_1 * radius_1 / dot_0(_S353, _S353);
    bool _S355 = _S354 >= 1.0f;
    if(_S355)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S354)))) / (6.28318548202514648f * _S354);
}

__device__ float3  sampleSphere(float3  center_1, float radius_2, float3  p_4, float u1_0, float u2_0)
{
    float3  _S356 = center_1 - p_4;
    float _S357 = radius_2 * radius_2 / dot_0(_S356, _S356);
    float _S358 = u1_0 * _S357 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S357), (0.0f)))))));
    float _S359 = 2.0f * u1_0;
    bool _S360 = _S357 >= 1.0f;
    float _S361 = _slang_select(_S360, _S359,_S358);
    float _S362 = (F32_sqrt(((F32_max((_S361 * (2.0f - _S361)), (0.0f))))));
    float _S363 = 6.28318548202514648f * u2_0;
    float3  _S364 = make_float3 (_S362 * (F32_cos((_S363))), 1.0f - _S361, _S362 * (F32_sin((_S363))));
    float3  _S365 = ((((_S356)) * make_float3(rnorm3df(((_S356)).x, ((_S356)).y, ((_S356)).z))));
    float3  _S366 = tangentToWorld(_S364, _S365);
    return _S366;
}

#undef Matrix
