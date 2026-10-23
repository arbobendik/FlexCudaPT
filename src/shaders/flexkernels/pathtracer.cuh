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
    float diffuse_weight;
    float refract_weight;
    float p_diffuse;
    float p_reflect;
    float p_refract;
};

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_1, float3  refracted_0, float3  F_0, float F_greyscale_0, float reflect_weight_0, float diffuse_weight_0, float refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0)
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
    return _S120;
}

__device__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_4, float3  n_i_1, float3  ggx_n_0, BSDFMaterial material_1, float eta_i_2, float eta_o_2)
{
    float _S121 = dot_0(ggx_n_0, v_4);
    float _S122 = dot_0(n_i_1, ggx_n_0);
    float _S123 = eta_i_2 / eta_o_2;
    float3  _S124 = refract_0(in_dir_3, ggx_n_0, _S123);
    float3  _S125 = ((((_S124)) * make_float3(rnorm3df(((_S124)).x, ((_S124)).y, ((_S124)).z))));
    float _S126 = fresnel((F32_abs((_S121))), eta_i_2, eta_o_2);
    float3  F_1 = mix_0(make_float3 (_S126), material_1.albedo, material_1.metallic);
    float _S127 = rgb_to_greyscale(F_1);
    float _S128 = (1.0f - material_1.transmission) * (1.0f - material_1.metallic) * (1.0f - _S126);
    float _S129 = (F32_max((_S127), (0.0f)));
    float _S130 = (F32_max((_S128), (0.0f)));
    float _S131 = material_1.transmission * (1.0f - _S127);
    float _S132 = sign_0(length_0(_S125));
    float _S133 = (F32_max((_S131 * _S132), (0.0f)));
    float _S134 = _S129 + _S130 + _S133;
    float _S135 = 1.0f / (F32_max((_S134), (0.0000152587890625f)));
    float _S136 = _S130 * _S135;
    float _S137 = _S129 * _S135;
    float _S138 = _S133 * _S135;
    return BSDFLobes_x24init_0(_S121, _S122, _S125, F_1, _S127, 1.0f, _S128, material_1.transmission, _S136, _S137, _S138);
}

__device__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S139 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    bool _S140 = n_i_dot_v_0 > 0.0f;
    float _S141 = _slang_select(_S140, _S139,0.0f);
    return _S141;
}

__device__ float3  diffuseBSDF(float3  l_0, float3  n_i_2, float alpha_5, BSDFMaterial material_2, BSDFLobes lobes_1)
{
    return make_float3 (lobes_1.diffuse_weight) * material_2.albedo / make_float3 (lobes_1.p_diffuse);
}

__device__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S142 = smithG1(alpha_6, n_i_dot_v_1);
    float _S143 = _S142 * lobes_2.v_dot_h;
    float _S144 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S145 = _S143 * _S144 / n_i_dot_v_1;
    bool _S146 = alpha_6 > 0.0f;
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

__device__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S149 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
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

__device__ float3  refractBSDF(float3  l_1, float3  n_i_3, float alpha_8, BSDFMaterial material_3, BSDFLobes lobes_4)
{
    float _S155 = - dot_0(n_i_3, l_1);
    float _S156 = smithG1(alpha_8, (F32_max((_S155), (0.0f))));
    return make_float3 (lobes_4.refract_weight * _S156 * (1.0f - lobes_4.F_greyscale)) * material_3.albedo / make_float3 (lobes_4.p_refract);
}

__device__ float reflectPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S157 = vndfPDF(n_i_dot_v_3, alpha_9, lobes_5);
    float _S158 = lobes_5.p_reflect * _S157 / (4.0f * lobes_5.v_dot_h);
    bool _S159 = _S157 > 0.0f;
    float _S160 = _slang_select(_S159, _S158,0.0f);
    return _S160;
}

__device__ float3  reflectBSDF(float3  l_2, float3  n_i_4, float alpha_10, BSDFMaterial material_4, BSDFLobes lobes_6)
{
    float _S161 = dot_0(n_i_4, l_2);
    float _S162 = smithG1(alpha_10, (F32_max((_S161), (0.0f))));
    return make_float3 (lobes_6.reflect_weight * _S162) * lobes_6.F / make_float3 (lobes_6.p_reflect);
}

__device__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_5, float eta_i_6, float eta_o_6, bool refracted_1, uint random_state_2, FixedArray<float3 , 3>  * throughputs_0, FixedArray<float, 3>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S163 = negate_0(in_dir_4);
    float _S164 = dot_0(n_7, _S163);
    float _S165 = sign_0(_S164);
    float3  _S166 = n_7 * make_float3 (_S165);
    float _S167 = dot_0(_S166, out_dir_2);
    float _S168 = material_5.roughness;
    float _S169 = _S168 * _S168;
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
        float3  _S170 = make_float3 (0.0f);
        (*throughputs_0)[i_10] = _S170;
        (*pdfs_0)[i_10] = 0.0f;
        uint i_11 = i_10 + 1U;
        i_10 = i_11;
    }
    float3  _S171 = make_float3 (0.0f);
    BSDFLobes _S172 = BSDFLobes_x24init_0(0.0f, 0.0f, _S171, _S171, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f);
    uint half_of_0 = 4294967295U;
    BSDFLobes lobe_terms_0 = _S172;
    float3  ggx_n_2 = _S171;
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
        bool _S173 = i_10 == 1U;
        bool _S174 = _S173 != refracted_1;
        if(_S174)
        {
            ggx_n_1 = ggx_n_2;
            uint i_12 = i_10 + 1U;
            ggx_n_2 = ggx_n_1;
            i_10 = i_12;
            continue;
        }
        bool _S175 = i_10 != half_of_0;
        uint half_of_1;
        BSDFLobes lobe_terms_1;
        if(_S175)
        {
            bool _S176 = i_10 == 0U;
            if(_S176)
            {
                float3  _S177 = sampledHalf(in_dir_4, n_7, material_5, random_state_2);
                ggx_n_1 = _S177;
            }
            else
            {
                if(_S173)
                {
                    float3  _S178 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_6, eta_o_6);
                    ggx_n_1 = _S178;
                }
                else
                {
                    float3  _S179 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S179;
                }
            }
            float3  _S180 = negate_0(in_dir_4);
            BSDFLobes _S181 = bsdfLobes(in_dir_4, _S180, _S166, ggx_n_1, material_5, eta_i_6, eta_o_6);
            lobe_terms_1 = _S181;
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
                float _S182 = diffusePDF(_S167, 0.0f, (F32_abs((_S164))), _S169, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[int(0)] = _S182;
                float3  _S183 = diffuseBSDF(out_dir_2, _S166, _S169, material_5, lobe_terms_1);
                (*throughputs_0)[int(0)] = _S183;
                break;
            }
        case 1U:
            {
                float _S184 = refractPDF(_S167, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S164))), _S169, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[int(1)] = _S184;
                float3  _S185 = refractBSDF(out_dir_2, _S166, _S169, material_5, lobe_terms_1);
                (*throughputs_0)[int(1)] = _S185;
                break;
            }
        default:
            {
                float _S186 = reflectPDF(_S167, 0.0f, (F32_abs((_S164))), _S169, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[int(2)] = _S186;
                float3  _S187 = reflectBSDF(out_dir_2, _S166, _S169, material_5, lobe_terms_1);
                (*throughputs_0)[int(2)] = _S187;
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
    ggx_n_1 = _S171;
    for(;;)
    {
        if(i_10 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S188 = ((*pdfs_0)[i_10]) > 0.0f;
        if(_S188)
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
    SampleBSDF _S189;
    (&_S189)->unit_direction = unit_direction_0;
    (&_S189)->throughput = throughput_0;
    (&_S189)->random_state = random_state_3;
    (&_S189)->refracted = refracted_2;
    (&_S189)->lobe = lobe_0;
    (&_S189)->pdf = pdf_0;
    return _S189;
}

__device__ SampleBSDF diffuseSample(float3  n_i_5, float n_i_dot_v_4, float alpha_11, BSDFMaterial material_6, BSDFLobes lobes_7, float eta_i_7, float eta_o_7, uint random_state_4)
{
    float3  _S190 = make_float3 (1.0f);
    SampleBSDF _S191 = SampleBSDF_x24init_0(_S190, _S190, 0U, false, 0U, 0.0f);
    SampleBSDF sample_0 = _S191;
    Random _S192 = pcg(random_state_4);
    Random _S193 = pcg(_S192.state);
    (&sample_0)->random_state = _S193.state;
    float3  _S194 = sampleCosWeightedHemisphere(_S192.value, _S193.value);
    float3  _S195 = tangentToWorld(_S194, n_i_5);
    (&sample_0)->unit_direction = _S195;
    (&sample_0)->lobe = 0U;
    float3  _S196 = diffuseBSDF((&sample_0)->unit_direction, n_i_5, alpha_11, material_6, lobes_7);
    (&sample_0)->throughput = _S196;
    float _S197 = diffusePDF(_S194.y, 0.0f, n_i_dot_v_4, alpha_11, lobes_7, eta_i_7, eta_o_7);
    (&sample_0)->pdf = _S197;
    return sample_0;
}

__device__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_6, float n_i_dot_v_5, float alpha_12, BSDFMaterial material_7, BSDFLobes lobes_8, float eta_i_8, float eta_o_8, uint random_state_5)
{
    float3  _S198 = make_float3 (1.0f);
    SampleBSDF _S199 = SampleBSDF_x24init_0(_S198, _S198, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S199;
    (&sample_1)->unit_direction = lobes_8.refracted;
    (&sample_1)->random_state = random_state_5;
    (&sample_1)->refracted = true;
    (&sample_1)->lobe = 1U;
    float3  _S200 = refractBSDF((&sample_1)->unit_direction, n_i_6, alpha_12, material_7, lobes_8);
    (&sample_1)->throughput = _S200;
    float _S201 = refractPDF(0.0f, dot_0((&sample_1)->unit_direction, ggx_n_3), n_i_dot_v_5, alpha_12, lobes_8, eta_i_8, eta_o_8);
    (&sample_1)->pdf = _S201;
    return sample_1;
}

__device__ SampleBSDF reflectSample(float3  in_dir_5, float3  ggx_n_4, float3  n_i_7, float n_i_dot_v_6, float alpha_13, BSDFMaterial material_8, BSDFLobes lobes_9, float eta_i_9, float eta_o_9, uint random_state_6)
{
    float3  _S202 = make_float3 (1.0f);
    SampleBSDF _S203 = SampleBSDF_x24init_0(_S202, _S202, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S203;
    float3  _S204 = reflect_0(in_dir_5, ggx_n_4);
    float3  _S205 = ((((_S204)) * make_float3(rnorm3df(((_S204)).x, ((_S204)).y, ((_S204)).z))));
    (&sample_2)->unit_direction = _S205;
    (&sample_2)->random_state = random_state_6;
    (&sample_2)->lobe = 2U;
    float3  _S206 = reflectBSDF((&sample_2)->unit_direction, n_i_7, alpha_13, material_8, lobes_9);
    (&sample_2)->throughput = _S206;
    float _S207 = reflectPDF(0.0f, 0.0f, n_i_dot_v_6, alpha_13, lobes_9, eta_i_9, eta_o_9);
    (&sample_2)->pdf = _S207;
    return sample_2;
}

__device__ SampleBSDF sampleBSDF(float3  in_dir_6, float3  n_8, BSDFMaterial material_9, float eta_i_10, float eta_o_10, uint random_init_0, float2  screen_space_0)
{
    uint random_state_7 = random_init_0;
    float3  _S208 = negate_0(in_dir_6);
    float _S209 = dot_0(n_8, _S208);
    float _S210 = sign_0(_S209);
    float3  n_i_8 = n_8 * make_float3 (_S210);
    float _S211 = (F32_abs((_S209)));
    float _S212 = material_9.roughness;
    float _S213 = _S212 * _S212;
    float3  _S214 = sampleHalfVector(_S208, n_i_8, _S213, &random_state_7);
    BSDFLobes _S215 = bsdfLobes(in_dir_6, _S208, n_i_8, _S214, material_9, eta_i_10, eta_o_10);
    Random _S216 = pcg(random_state_7);
    random_state_7 = _S216.state;
    bool _S217 = (_S216.value) < (_S215.p_diffuse);
    if(_S217)
    {
        SampleBSDF _S218 = diffuseSample(n_i_8, _S211, _S213, material_9, _S215, eta_i_10, eta_o_10, random_state_7);
        return _S218;
    }
    bool _S219 = (_S216.value) < (_S215.p_diffuse + _S215.p_refract);
    if(_S219)
    {
        SampleBSDF _S220 = refractSample(_S214, n_i_8, _S211, _S213, material_9, _S215, eta_i_10, eta_o_10, random_state_7);
        return _S220;
    }
    SampleBSDF _S221 = reflectSample(in_dir_6, _S214, n_i_8, _S211, _S213, material_9, _S215, eta_i_10, eta_o_10, random_state_7);
    return _S221;
}

__device__ float3  pointLightRadiance(float3  color_0, float intensity_0, float radius_0)
{
    return color_0 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_0 * radius_0);
}

__device__ float3  beerLambert(float distance_1, float3  absorption_0)
{
    float3  _S222 = max_0(absorption_0, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_1) * log_0(_S222));
}

__device__ bool neeDecision(BSDFMaterial material_10, float n_dot_v_0, float eta_i_11, float eta_o_11)
{
    float _S223 = fresnel((F32_abs((n_dot_v_0))), eta_i_11, eta_o_11);
    float3  _S224 = mix_0(make_float3 (_S223), material_10.albedo, material_10.metallic);
    float _S225 = rgb_to_greyscale(_S224);
    float _S226 = (F32_max(((1.0f - _S225) * (1.0f - material_10.metallic) * (1.0f - material_10.transmission)), (0.0f)));
    bool _S227 = _S226 > 0.03999999910593033f;
    bool _S228;
    if(_S227)
    {
        _S228 = true;
    }
    else
    {
        _S228 = (material_10.roughness) > 0.20000000298023224f;
    }
    return _S228;
}

__device__ float3  straightThrough(float3  dir_0, float3  n_9, BSDFMaterial material_11)
{
    float _S229 = rgb_to_greyscale(material_11.albedo * make_float3 (material_11.metallic));
    float _S230 = material_11.roughness;
    float _S231 = smithG1(_S230 * _S230, (F32_abs((dot_0(n_9, dir_0)))));
    return make_float3 (material_11.transmission * _S231 * (1.0f - _S229)) * material_11.albedo;
}

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_0, float3  end_0)
{
    float _S232 = sign_0(dot_0(light_n_0, start_0 - end_0));
    return light_n_0 * make_float3 (_S232 * light_offset_0);
}

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

__device__ float3  occluderTransmittance(float3  toward_0, float3  n_10, BSDFMaterial material_12, float coverage_0)
{
    float3  _S233;
    if((material_12.ior) == 1.0f)
    {
        float3  _S234 = straightThrough(toward_0, n_10, material_12);
        _S233 = _S234;
    }
    else
    {
        _S233 = make_float3 (0.0f);
    }
    return _S233 * make_float3 (coverage_0) + make_float3 (1.0f - coverage_0);
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S235 = hash(index_0);
    uint _S236 = hash(seed_0 ^ _S235);
    return _S236;
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float3  _S237 = a_4 / b_0;
    float3  _S238 = make_float3 (0.0f);
    bool3  _S239 = b_0 == _S238;
    float3  _S240 = _slang_select(_S239, _S238,_S237);
    return _S240;
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
    float _S241 = rgb_to_greyscale(weight_0);
    bool _S242 = _S241 > 0.0f;
    bool _S243;
    if(_S242)
    {
        _S243 = _S241 < 3.00000000549775576e+38f;
    }
    else
    {
        _S243 = false;
    }
    bool _S244 = !_S243;
    if(_S244)
    {
        return;
    }
    float _S245 = sel_0->w_sum + _S241;
    sel_0->w_sum = _S245;
    float3  _S246 = sel_0->color + weight_0;
    sel_0->color = _S246;
    Random _S247 = pcg(sel_0->random_state);
    sel_0->random_state = _S247.state;
    bool _S248 = (_S247.value * sel_0->w_sum) <= _S241;
    if(_S248)
    {
        sel_0->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_1, Reservoir r_0, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_0;
    float3  _S249 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S249;
    float _S250 = r_0.jac * shifted_0.jac;
    (&candidate_1)->jac = _S250;
    offer(sel_1, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_0.w));
    return;
}

__device__ Reservoir finalize(Selection sel_2, float c_0)
{
    Reservoir r_1 = sel_2.r;
    float _S251 = rgb_to_greyscale((&r_1)->f);
    float _S252 = sel_2.w_sum / _S251;
    bool _S253 = _S251 > 0.0f;
    float _S254 = _slang_select(_S253, _S252,0.0f);
    (&r_1)->w = _S254;
    (&r_1)->c = c_0;
    return r_1;
}

static __device__ uint insertBits_0(uint e_1, uint newbits_0, uint offset_0, uint count_0)
{
    uint _S255 = (1U << count_0) - 1U;
    return (e_1 & (~(_S255 << offset_0))) | ((newbits_0 & _S255) << offset_0);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_1, float3  f_1)
{
    Reservoir candidate_2 = r_2;
    uint _S256 = insertBits_0(r_2.path, end_1, 0U, 5U);
    uint _S257 = insertBits_0(_S256, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S257;
    (&candidate_2)->f = f_1;
    return candidate_2;
}

__device__ float facingSign(float transmission_0, float3  face_0, float3  direction_0)
{
    bool _S258 = transmission_0 > 0.0f;
    bool _S259;
    if(_S258)
    {
        _S259 = true;
    }
    else
    {
        _S259 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S260;
    if(_S259)
    {
        _S260 = 1.0f;
    }
    else
    {
        _S260 = -1.0f;
    }
    return _S260;
}

__device__ float survivalProbability(float3  throughput_1, float density_0)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_0), (0.0f)))), (1.0f)));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S261 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S262 = cos_a_0 > cos_b_0;
    float _S263 = _slang_select(_S262, 1.0f,_S261);
    return _S263;
}

__device__ float sine(float c_1)
{
    return (F32_sqrt(((F32_max((1.0f - c_1 * c_1), (0.0f))))));
}

__device__ float importance(LightNode node_0, float3  p_0, float3  normal_0)
{
    float3  _S264 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S265 = node_0.high - node_0.low;
    float3  _S266 = p_0 - _S264;
    float3  _S267 = ((((_S266)) * make_float3(rnorm3df(((_S266)).x, ((_S266)).y, ((_S266)).z))));
    float _S268 = dot_0(_S266, _S266);
    float _S269 = dot_0(_S265, _S265) / 4.0f;
    float _S270 = (F32_abs((dot_0(node_0.w, _S267))));
    float _S271 = sine(node_0.cos_theta_o);
    float _S272 = (F32_sqrt(((F32_max((1.0f - _S269 / _S268), (0.0f))))));
    bool _S273 = _S268 < _S269;
    float _S274 = _slang_select(_S273, -1.0f,_S272);
    float _S275 = sine(_S274);
    float _S276 = sine(_S270);
    float _S277 = cosSubClamped(_S276, _S270, _S271, node_0.cos_theta_o);
    float _S278 = sine(_S270);
    float _S279 = _S278 * node_0.cos_theta_o - _S270 * _S271;
    bool _S280 = _S270 > (node_0.cos_theta_o);
    float _S281 = _slang_select(_S280, 0.0f,_S279);
    float _S282 = cosSubClamped(_S281, _S277, _S275, _S274);
    bool _S283 = _S282 <= 0.0f;
    if(_S283)
    {
        return 0.0f;
    }
    float _S284 = - dot_0(_S267, normal_0);
    float _S285 = node_0.phi * _S282 / (F32_max((_S268), (length_0(_S265) / 2.0f)));
    float _S286 = sine(_S284);
    float _S287 = cosSubClamped(_S286, _S284, _S275, _S274);
    bool _S288 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S289 = _slang_select(_S288, 1.0f,_S287);
    return (F32_max((_S285 * _S289), (0.0f)));
}

__device__ float solidAngle(float probability_0, float3  normal_1, float3  toward_1)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_1)), (3.0f))) / (F32_abs((dot_0(normal_1, toward_1))));
}

__device__ uint pickChild(LightNode first_0, LightNode second_0, float3  p_1, float3  normal_2, float * pick_0, float * probability_1)
{
    float _S290 = importance(first_0, p_1, normal_2);
    float _S291 = importance(second_0, p_1, normal_2);
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

__device__ float childShare(LightNode first_1, LightNode second_1, float3  p_2, float3  normal_3, uint child_0)
{
    float _S300 = importance(first_1, p_2, normal_3);
    float _S301 = importance(second_1, p_2, normal_3);
    float2  _S302 = make_float2 (_S300, _S301);
    float _S303 = _slang_vector_get_element(_S302, child_0) / (_S300 + _S301);
    bool _S304 = _slang_vector_get_element(_S302, child_0) > 0.0f;
    float _S305 = _slang_select(_S304, _S303,0.0f);
    return _S305;
}

__device__ float powerHeuristic(float a_5, float b_1)
{
    float _S306 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    bool _S307 = b_1 > 0.0f;
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
