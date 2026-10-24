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
    float3  _S47 = make_float3 (1.0f, 0.0f, 0.0f);
    float3  _S48 = make_float3 (- _S45, _S44, 0.0f);
    float _S49 = (rsqrtf((_S46)));
    float3  _S50 = _S48 * make_float3 (_S49);
    bool _S51 = _S46 > 0.0f;
    float3  _S52 = _slang_select(_S51, _S50,_S47);
    float3  _S53 = cross_0(_S43, _S52);
    float _S54 = (F32_sqrt((U1_0)));
    float _S55 = 6.28318548202514648f * U2_0;
    float _S56 = _S54 * (F32_cos((_S55)));
    float t2_0 = _S54 * (F32_sin((_S55)));
    float _S57 = 0.5f * (1.0f + _S43.z);
    float t2_1 = (1.0f - _S57) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S56 * _S56)))))) + _S57 * t2_0;
    float3  _S58 = make_float3 (_S56) * _S52 + make_float3 (t2_1) * _S53;
    float _S59 = unshared_0(_S56);
    float _S60 = unshared_0(_S56);
    float3  _S61 = _S58 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S59 * _S60 - t2_1 * t2_1))))))) * _S43;
    float3  _S62 = make_float3 (alpha_2 * _S61.x, alpha_2 * _S61.y, (F32_max((0.0f), (_S61.z))));
    float3  _S63 = ((((_S62)) * make_float3(rnorm3df(((_S62)).x, ((_S62)).y, ((_S62)).z))));
    return _S63;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S64 = (F32_sqrt((random_1_0)));
    float _S65 = 6.28318548202514648f * random_2_0;
    float _S66 = _S64 * (F32_cos((_S65)));
    float _S67 = _S64 * (F32_sin((_S65)));
    float _S68 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S66 * _S66 - _S67 * _S67))))));
    return make_float3 (_S66, _S68, _S67);
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_2)
{
    float3  a_0 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S69 = (F32_abs((dot_0(n_2, a_0)))) > 0.9999847412109375f;
    float3  a_1;
    if(_S69)
    {
        float3  _S70 = make_float3 (1.0f, 0.0f, 0.0f);
        a_1 = _S70;
    }
    else
    {
        a_1 = a_0;
    }
    float3  _S71 = cross_0(n_2, a_1);
    float3  _S72 = ((((_S71)) * make_float3(rnorm3df(((_S71)).x, ((_S71)).y, ((_S71)).z))));
    float3  _S73 = cross_0(n_2, _S72);
    return make_float3 (v_0.x) * _S72 + make_float3 (v_0.y) * n_2 + make_float3 (v_0.z) * _S73;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
{
    float3  a_2 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S74 = (F32_abs((dot_0(n_3, a_2)))) > 0.9999847412109375f;
    float3  a_3;
    if(_S74)
    {
        float3  _S75 = make_float3 (1.0f, 0.0f, 0.0f);
        a_3 = _S75;
    }
    else
    {
        a_3 = a_2;
    }
    float3  _S76 = cross_0(n_3, a_3);
    float3  _S77 = ((((_S76)) * make_float3(rnorm3df(((_S76)).x, ((_S76)).y, ((_S76)).z))));
    float3  _S78 = cross_0(n_3, _S77);
    return make_float3 (dot_0(v_1, _S77), dot_0(v_1, n_3), dot_0(v_1, _S78));
}

static __device__ float3  negate_0(float3  x_14)
{
    return - x_14;
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_4)
{
    float3  _S79 = p1_0 - p0_0;
    float3  _S80 = p2_0 - p0_0;
    float2  _S81 = uv1_0 - uv0_0;
    float2  _S82 = uv2_0 - uv0_0;
    float _S83 = _S81.x;
    float _S84 = _S82.y;
    float _S85 = _S81.y;
    float _S86 = _S82.x;
    float _S87 = _S83 * _S84 - _S85 * _S86;
    float _S88 = 1.0f / _S87;
    float3  t_0 = (_S79 * make_float3 (_S84) - _S80 * make_float3 (_S85)) * make_float3 (_S88);
    float3  _S89 = (_S80 * make_float3 (_S83) - _S79 * make_float3 (_S86)) * make_float3 (_S88);
    float3  _S90 = t_0 - n_4 * make_float3 (dot_0(n_4, t_0));
    float3  _S91 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_4);
    bool _S92 = (dot_0(_S90, _S90)) > 0.0f;
    float3  _S93 = _slang_select(_S92, _S90,_S91);
    float3  _S94 = ((((_S93)) * make_float3(rnorm3df(((_S93)).x, ((_S93)).y, ((_S93)).z))));
    bool _S95 = (dot_0(cross_0(n_4, _S94), _S89)) > 0.0f;
    float3  t_1;
    if(_S95)
    {
        float3  _S96 = negate_0(_S94);
        t_1 = _S96;
    }
    else
    {
        t_1 = _S94;
    }
    float3  _S97 = cross_0(n_4, t_1);
    return makeMatrix<float, 3, 3> (t_1, _S97, n_4);
}

__device__ float3  tangentToWorldNormalMap(float3  v_2, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_2, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_0, float3  uvw_0, float3  position_0)
{
    float3  _S98 = t1_0 - t0_0;
    float3  _S99 = t2_2 - t0_0;
    float3  _S100 = t2_2 - t1_0;
    float _S101 = (F32_min((length_0(_S98)), ((F32_min((length_0(_S99)), (length_0(_S100)))))));
    float3  _S102 = make_float3 (distance_0(position_0, t0_0), distance_0(position_0, t1_0), distance_0(position_0, t2_2));
    float3  _S103 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S104 = dot_0(geometry_n_0, _S103);
    float3  _S105 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S106 = dot_0(geometry_n_0, _S105);
    float3  _S107 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S108 = acos_0(abs_0(make_float3 (_S104, _S106, dot_0(geometry_n_0, _S107))));
    float3  _S109 = clamp_0(tan_0(_S108), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S102 * _S109, uvw_0), 0.0f, _S101 * 0.125f);
}

__device__ float3  sampleHalfVector(float3  v_3, float3  n_i_0, float alpha_3, uint * random_state_0)
{
    Random _S110 = pcg(*random_state_0);
    Random _S111 = pcg(_S110.state);
    *random_state_0 = _S111.state;
    float3  _S112 = worldToTangent(v_3, n_i_0);
    float3  _S113 = sampleGGXVNDF(float3 {_S112.x, _S112.z, _S112.y}, alpha_3, _S110.value, _S111.value);
    float3  _S114 = float3 {_S113.x, _S113.z, _S113.y};
    float3  _S115 = tangentToWorld(_S114, n_i_0);
    return _S115;
}

static __device__ float sign_0(float e_0)
{
    bool _S116 = e_0 < 0.0f;
    float _S117 = _slang_select(_S116, -1.0f,0.0f);
    bool _S118 = e_0 > 0.0f;
    float _S119 = _slang_select(_S118, 1.0f,_S117);
    return _S119;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_5, BSDFMaterial material_0, uint random_state_1)
{
    uint state_5 = random_state_1;
    float3  _S120 = negate_0(in_dir_0);
    float _S121 = sign_0(dot_0(n_5, _S120));
    float _S122 = material_0.roughness;
    float3  _S123 = sampleHalfVector(_S120, n_5 * make_float3 (_S121), _S122 * _S122, &state_5);
    return _S123;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_6, float eta_i_1, float eta_o_1)
{
    float3  _S124 = negate_0(in_dir_1);
    float3  _S125 = negate_0(make_float3 (eta_i_1) * _S124 + make_float3 (eta_o_1) * out_dir_0);
    float3  _S126 = ((((_S125)) * make_float3(rnorm3df(((_S125)).x, ((_S125)).y, ((_S125)).z))));
    float _S127 = sign_0(dot_0(n_6, _S124));
    float _S128 = sign_0(dot_0(_S125, n_6 * make_float3 (_S127)));
    return _S126 * make_float3 (_S128);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S129 = negate_0(in_dir_2);
    float3  _S130 = _S129 + out_dir_1;
    float3  _S131 = ((((_S130)) * make_float3(rnorm3df(((_S130)).x, ((_S130)).y, ((_S130)).z))));
    return _S131;
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
    BSDFLobes _S132;
    (&_S132)->v_dot_h = v_dot_h_0;
    (&_S132)->n_dot_h = n_dot_h_1;
    (&_S132)->refracted = refracted_0;
    (&_S132)->F = F_0;
    (&_S132)->F_greyscale = F_greyscale_0;
    (&_S132)->reflect_weight = reflect_weight_0;
    (&_S132)->diffuse_weight = diffuse_weight_0;
    (&_S132)->refract_weight = refract_weight_0;
    (&_S132)->p_diffuse = p_diffuse_0;
    (&_S132)->p_reflect = p_reflect_0;
    (&_S132)->p_refract = p_refract_0;
    (&_S132)->translucent_share = translucent_share_0;
    return _S132;
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_4, float3  n_i_1, float3  ggx_n_0, BSDFMaterial material_1, float eta_i_2, float eta_o_2)
{
    float _S133 = dot_0(ggx_n_0, v_4);
    float _S134 = dot_0(n_i_1, ggx_n_0);
    float _S135 = eta_i_2 / eta_o_2;
    float3  _S136 = refract_0(in_dir_3, ggx_n_0, _S135);
    float3  _S137 = ((((_S136)) * make_float3(rnorm3df(((_S136)).x, ((_S136)).y, ((_S136)).z))));
    float _S138 = (F32_min(((F32_sqrt((material_1.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S139 = _S138 * _S138;
    float _S140 = (1.0f + _S138) / (1.0f - _S138);
    float _S141 = (F32_abs((_S133)));
    bool _S142 = eta_i_2 > eta_o_2;
    float _S143 = _slang_select(_S142, _S140,1.0f);
    float _S144 = _slang_select(_S142, 1.0f,_S140);
    float _S145 = fresnel(_S141, _S143, _S144);
    bool _S146 = (eta_i_2 * eta_i_2 * (1.0f - _S133 * _S133)) >= (eta_o_2 * eta_o_2);
    float3  _S147 = material_1.specular_tint * make_float3 (_S139);
    float3  _S148 = _S147 + (make_float3 (1.0f) - _S147) * make_float3 (_S145 - _S139) / make_float3 (1.0f - _S139);
    float3  _S149 = make_float3 (1.0f);
    float3  _S150 = _slang_select(_S146, _S149,_S148);
    float3  F_1 = mix_0(_S150, material_1.albedo, material_1.metallic);
    float _S151 = rgb_to_greyscale(F_1);
    float _S152 = 1.0f - material_1.metallic;
    float3  _S153 = make_float3 (1.0f) - _S150;
    float3  _S154 = make_float3 ((1.0f - material_1.transmission) * _S152) * _S153;
    float3  _S155 = make_float3 (material_1.transmission * _S152) * _S153;
    float _S156 = (F32_max((_S151), (0.0f)));
    float _S157 = rgb_to_greyscale(_S154);
    float _S158 = (F32_max((_S157), (0.0f)));
    float _S159 = rgb_to_greyscale(_S155);
    float _S160 = sign_0(length_0(_S137));
    float _S161 = (F32_max((_S159 * _S160), (0.0f)));
    float _S162 = _S156 + _S158 + _S161;
    float _S163 = 1.0f / (F32_max((_S162), (0.0000152587890625f)));
    float _S164 = _S158 * _S163;
    float _S165 = _S156 * _S163;
    float _S166 = _S161 * _S163;
    return BSDFLobes_x24init_0(_S133, _S134, _S137, F_1, _S151, 1.0f, _S154, _S155, _S164, _S165, _S166, 0.0f);
}

__device__ float translucentShare(BSDFMaterial material_2)
{
    float _S167 = rgb_to_greyscale(material_2.translucent);
    float _S168 = rgb_to_greyscale(material_2.albedo);
    float _S169 = _S167 / (_S168 + _S167);
    bool _S170 = _S167 > 0.0f;
    float _S171 = _slang_select(_S170, _S169,0.0f);
    return _S171;
}

__device__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S172 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S173 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S174 = 1.0f - lobes_0.translucent_share;
    bool _S175 = n_i_dot_l_0 < 0.0f;
    float _S176 = _slang_select(_S175, lobes_0.translucent_share,_S174);
    float _S177 = _S173 * _S176;
    bool _S178 = (lobes_0.translucent_share) > 0.0f;
    float _S179 = _slang_select(_S178, _S177,_S172);
    bool _S180 = n_i_dot_v_0 > 0.0f;
    float _S181 = _slang_select(_S180, _S179,0.0f);
    return _S181;
}

__device__ float3  diffuseBSDF(float3  l_0, float3  n_i_2, float alpha_5, BSDFMaterial material_3, BSDFLobes lobes_1)
{
    bool _S182 = (dot_0(n_i_2, l_0)) < 0.0f;
    float3  _S183 = _slang_select(_S182, material_3.translucent,material_3.albedo);
    float _S184 = 1.0f - lobes_1.translucent_share;
    float _S185 = _slang_select(_S182, lobes_1.translucent_share,_S184);
    float3  _S186 = _S183 / make_float3 (_S185);
    bool _S187 = (lobes_1.translucent_share) > 0.0f;
    float3  _S188 = _slang_select(_S187, _S186,material_3.albedo);
    return lobes_1.diffuse_weight * _S188 / make_float3 (lobes_1.p_diffuse);
}

__device__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S189 = smithG1(alpha_6, n_i_dot_v_1);
    float _S190 = _S189 * lobes_2.v_dot_h;
    float _S191 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S192 = _S190 * _S191 / n_i_dot_v_1;
    bool _S193 = alpha_6 > 0.0f;
    bool _S194;
    if(_S193)
    {
        _S194 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S194 = false;
    }
    if(_S194)
    {
        _S194 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S194 = false;
    }
    if(_S194)
    {
        _S194 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S194 = false;
    }
    float _S195 = _slang_select(_S194, _S192,0.0f);
    return _S195;
}

__device__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S196 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S197 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S198 = lobes_3.p_refract * _S196 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S197 * _S197);
    bool _S199 = eta_i_4 != eta_o_4;
    bool _S200;
    if(_S199)
    {
        _S200 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S200 = false;
    }
    float _S201 = _slang_select(_S200, _S198,0.0f);
    return _S201;
}

__device__ float3  refractBSDF(float3  l_1, float3  n_i_3, float alpha_8, BSDFMaterial material_4, BSDFLobes lobes_4)
{
    float _S202 = - dot_0(n_i_3, l_1);
    float _S203 = smithG1(alpha_8, (F32_max((_S202), (0.0f))));
    return lobes_4.refract_weight * make_float3 (_S203) * material_4.albedo / make_float3 (lobes_4.p_refract);
}

__device__ float reflectPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S204 = vndfPDF(n_i_dot_v_3, alpha_9, lobes_5);
    float _S205 = lobes_5.p_reflect * _S204 / (4.0f * lobes_5.v_dot_h);
    bool _S206 = _S204 > 0.0f;
    float _S207 = _slang_select(_S206, _S205,0.0f);
    return _S207;
}

__device__ float3  reflectBSDF(float3  l_2, float3  n_i_4, float alpha_10, BSDFMaterial material_5, BSDFLobes lobes_6)
{
    float _S208 = dot_0(n_i_4, l_2);
    float _S209 = smithG1(alpha_10, (F32_max((_S208), (0.0f))));
    return make_float3 (lobes_6.reflect_weight * _S209) * lobes_6.F / make_float3 (lobes_6.p_reflect);
}

__device__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_6, float eta_i_6, float eta_o_6, bool refracted_1, uint random_state_2, FixedArray<float3 , 3>  * throughputs_0, FixedArray<float, 3>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S210 = negate_0(in_dir_4);
    float _S211 = dot_0(n_7, _S210);
    float _S212 = sign_0(_S211);
    float3  _S213 = n_7 * make_float3 (_S212);
    float _S214 = dot_0(_S213, out_dir_2);
    float _S215 = material_6.roughness;
    float _S216 = _S215 * _S215;
    float _S217 = rgb_to_greyscale(material_6.translucent);
    bool _S218 = _S217 > 0.0f;
    bool _S219 = (dot_0(n_7, out_dir_2) * _S211) < 0.0f;
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
        float3  _S220 = make_float3 (0.0f);
        (*throughputs_0)[i_10] = _S220;
        (*pdfs_0)[i_10] = 0.0f;
        uint i_11 = i_10 + 1U;
        i_10 = i_11;
    }
    float3  _S221 = make_float3 (0.0f);
    BSDFLobes _S222 = BSDFLobes_x24init_0(0.0f, 0.0f, _S221, _S221, 0.0f, 0.0f, _S221, _S221, 0.0f, 0.0f, 0.0f, 0.0f);
    BSDFLobes lobe_terms_0 = _S222;
    uint half_of_0 = 4294967295U;
    float3  ggx_n_2 = _S221;
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
        bool _S223 = i_10 == 0U;
        bool _S224;
        if(_S223)
        {
            _S224 = _S218;
        }
        else
        {
            _S224 = false;
        }
        bool _S225;
        if(_S224)
        {
            _S225 = _S219;
        }
        else
        {
            _S225 = i_10 == 1U;
        }
        bool _S226 = _S225 != refracted_1;
        if(_S226)
        {
            ggx_n_1 = ggx_n_2;
            uint i_12 = i_10 + 1U;
            ggx_n_2 = ggx_n_1;
            i_10 = i_12;
            continue;
        }
        bool _S227 = i_10 != half_of_0;
        uint half_of_1;
        if(_S227)
        {
            if(_S223)
            {
                float3  _S228 = sampledHalf(in_dir_4, n_7, material_6, random_state_2);
                ggx_n_1 = _S228;
            }
            else
            {
                bool _S229 = i_10 == 1U;
                if(_S229)
                {
                    float3  _S230 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_6, eta_o_6);
                    ggx_n_1 = _S230;
                }
                else
                {
                    float3  _S231 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S231;
                }
            }
            float3  _S232 = negate_0(in_dir_4);
            BSDFLobes _S233 = bsdfLobes(in_dir_4, _S232, _S213, ggx_n_1, material_6, eta_i_6, eta_o_6);
            lobe_terms_0 = _S233;
            float _S234 = translucentShare(material_6);
            (&lobe_terms_0)->translucent_share = _S234;
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
                float _S235 = diffusePDF(_S214, 0.0f, (F32_abs((_S211))), _S216, lobe_terms_0, eta_i_6, eta_o_6);
                (*pdfs_0)[int(0)] = _S235;
                float3  _S236 = diffuseBSDF(out_dir_2, _S213, _S216, material_6, lobe_terms_0);
                (*throughputs_0)[int(0)] = _S236;
                break;
            }
        case 1U:
            {
                float _S237 = refractPDF(_S214, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S211))), _S216, lobe_terms_0, eta_i_6, eta_o_6);
                (*pdfs_0)[int(1)] = _S237;
                float3  _S238 = refractBSDF(out_dir_2, _S213, _S216, material_6, lobe_terms_0);
                (*throughputs_0)[int(1)] = _S238;
                break;
            }
        default:
            {
                float _S239 = reflectPDF(_S214, 0.0f, (F32_abs((_S211))), _S216, lobe_terms_0, eta_i_6, eta_o_6);
                (*pdfs_0)[int(2)] = _S239;
                float3  _S240 = reflectBSDF(out_dir_2, _S213, _S216, material_6, lobe_terms_0);
                (*throughputs_0)[int(2)] = _S240;
                break;
            }
        }
        half_of_0 = half_of_1;
        uint i_12 = i_10 + 1U;
        ggx_n_2 = ggx_n_1;
        i_10 = i_12;
    }
    i_10 = 0U;
    ggx_n_1 = _S221;
    for(;;)
    {
        if(i_10 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S241 = ((*pdfs_0)[i_10]) > 0.0f;
        if(_S241)
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
    SampleBSDF _S242;
    (&_S242)->unit_direction = unit_direction_0;
    (&_S242)->throughput = throughput_0;
    (&_S242)->random_state = random_state_3;
    (&_S242)->refracted = refracted_2;
    (&_S242)->lobe = lobe_0;
    (&_S242)->pdf = pdf_0;
    return _S242;
}

__device__ SampleBSDF diffuseSample(float u_0, float3  n_i_5, float n_i_dot_v_4, float alpha_11, BSDFMaterial material_7, BSDFLobes lobes_7, float eta_i_7, float eta_o_7, uint random_state_4)
{
    float3  _S243 = make_float3 (1.0f);
    SampleBSDF _S244 = SampleBSDF_x24init_0(_S243, _S243, 0U, false, 0U, 0.0f);
    SampleBSDF sample_0 = _S244;
    Random _S245 = pcg(random_state_4);
    Random _S246 = pcg(_S245.state);
    (&sample_0)->random_state = _S246.state;
    float3  _S247 = sampleCosWeightedHemisphere(_S245.value, _S246.value);
    bool _S248 = u_0 < (lobes_7.p_diffuse * lobes_7.translucent_share);
    float _S249 = _S247.y;
    float _S250 = - _S249;
    float _S251 = _slang_select(_S248, _S250,_S249);
    float3  _S252 = tangentToWorld(make_float3 (_S247.x, _S251, _S247.z), n_i_5);
    (&sample_0)->unit_direction = _S252;
    (&sample_0)->refracted = _S248;
    (&sample_0)->lobe = 0U;
    float3  _S253 = diffuseBSDF((&sample_0)->unit_direction, n_i_5, alpha_11, material_7, lobes_7);
    (&sample_0)->throughput = _S253;
    float _S254 = diffusePDF(_S251, 0.0f, n_i_dot_v_4, alpha_11, lobes_7, eta_i_7, eta_o_7);
    (&sample_0)->pdf = _S254;
    return sample_0;
}

__device__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_6, float n_i_dot_v_5, float alpha_12, BSDFMaterial material_8, BSDFLobes lobes_8, float eta_i_8, float eta_o_8, uint random_state_5)
{
    float3  _S255 = make_float3 (1.0f);
    SampleBSDF _S256 = SampleBSDF_x24init_0(_S255, _S255, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S256;
    (&sample_1)->unit_direction = lobes_8.refracted;
    (&sample_1)->random_state = random_state_5;
    (&sample_1)->refracted = true;
    (&sample_1)->lobe = 1U;
    float3  _S257 = refractBSDF((&sample_1)->unit_direction, n_i_6, alpha_12, material_8, lobes_8);
    (&sample_1)->throughput = _S257;
    float _S258 = refractPDF(0.0f, dot_0((&sample_1)->unit_direction, ggx_n_3), n_i_dot_v_5, alpha_12, lobes_8, eta_i_8, eta_o_8);
    (&sample_1)->pdf = _S258;
    return sample_1;
}

__device__ SampleBSDF reflectSample(float3  in_dir_5, float3  ggx_n_4, float3  n_i_7, float n_i_dot_v_6, float alpha_13, BSDFMaterial material_9, BSDFLobes lobes_9, float eta_i_9, float eta_o_9, uint random_state_6)
{
    float3  _S259 = make_float3 (1.0f);
    SampleBSDF _S260 = SampleBSDF_x24init_0(_S259, _S259, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S260;
    float3  _S261 = reflect_0(in_dir_5, ggx_n_4);
    float3  _S262 = ((((_S261)) * make_float3(rnorm3df(((_S261)).x, ((_S261)).y, ((_S261)).z))));
    (&sample_2)->unit_direction = _S262;
    (&sample_2)->random_state = random_state_6;
    (&sample_2)->lobe = 2U;
    float3  _S263 = reflectBSDF((&sample_2)->unit_direction, n_i_7, alpha_13, material_9, lobes_9);
    (&sample_2)->throughput = _S263;
    float _S264 = reflectPDF(0.0f, 0.0f, n_i_dot_v_6, alpha_13, lobes_9, eta_i_9, eta_o_9);
    (&sample_2)->pdf = _S264;
    return sample_2;
}

__device__ SampleBSDF sampleBSDF(float3  in_dir_6, float3  n_8, BSDFMaterial material_10, float eta_i_10, float eta_o_10, uint random_init_0, float2  screen_space_0)
{
    uint random_state_7 = random_init_0;
    float3  _S265 = negate_0(in_dir_6);
    float _S266 = dot_0(n_8, _S265);
    float _S267 = sign_0(_S266);
    float3  n_i_8 = n_8 * make_float3 (_S267);
    float _S268 = (F32_abs((_S266)));
    float _S269 = material_10.roughness;
    float _S270 = _S269 * _S269;
    float3  _S271 = sampleHalfVector(_S265, n_i_8, _S270, &random_state_7);
    BSDFLobes _S272 = bsdfLobes(in_dir_6, _S265, n_i_8, _S271, material_10, eta_i_10, eta_o_10);
    BSDFLobes lobes_10 = _S272;
    float _S273 = translucentShare(material_10);
    (&lobes_10)->translucent_share = _S273;
    Random _S274 = pcg(random_state_7);
    random_state_7 = _S274.state;
    bool _S275 = (_S274.value) < ((&lobes_10)->p_diffuse);
    if(_S275)
    {
        SampleBSDF _S276 = diffuseSample(_S274.value, n_i_8, _S268, _S270, material_10, lobes_10, eta_i_10, eta_o_10, random_state_7);
        return _S276;
    }
    bool _S277 = (_S274.value) < ((&lobes_10)->p_diffuse + (&lobes_10)->p_refract);
    if(_S277)
    {
        SampleBSDF _S278 = refractSample(_S271, n_i_8, _S268, _S270, material_10, lobes_10, eta_i_10, eta_o_10, random_state_7);
        return _S278;
    }
    SampleBSDF _S279 = reflectSample(in_dir_6, _S271, n_i_8, _S268, _S270, material_10, lobes_10, eta_i_10, eta_o_10, random_state_7);
    return _S279;
}

__device__ float3  pointLightRadiance(float3  color_0, float intensity_0, float radius_0)
{
    return color_0 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_0 * radius_0);
}

__device__ float3  beerLambert(float distance_1, float3  absorption_0)
{
    float3  _S280 = max_0(absorption_0, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_1) * log_0(_S280));
}

__device__ bool neeDecision(BSDFMaterial material_11, float n_dot_v_0, float eta_i_11, float eta_o_11)
{
    float _S281 = fresnel((F32_abs((n_dot_v_0))), eta_i_11, eta_o_11);
    float3  _S282 = mix_0(make_float3 (_S281), material_11.albedo, material_11.metallic);
    float _S283 = rgb_to_greyscale(_S282);
    float _S284 = (F32_max(((1.0f - _S283) * (1.0f - material_11.metallic) * (1.0f - material_11.transmission)), (0.0f)));
    bool _S285 = _S284 > 0.03999999910593033f;
    bool _S286;
    if(_S285)
    {
        _S286 = true;
    }
    else
    {
        _S286 = (material_11.roughness) > 0.20000000298023224f;
    }
    return _S286;
}

__device__ float3  straightThrough(BSDFMaterial material_12)
{
    return make_float3 (material_12.transmission * (1.0f - material_12.metallic)) * material_12.albedo;
}

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_0, float3  end_0)
{
    float _S287 = sign_0(dot_0(light_n_0, start_0 - end_0));
    return light_n_0 * make_float3 (_S287 * light_offset_0);
}

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

__device__ float3  occluderTransmittance(float3  toward_0, float3  n_9, BSDFMaterial material_13, float coverage_0)
{
    float3  _S288;
    if((material_13.ior) == 1.0f)
    {
        float3  _S289 = straightThrough(material_13);
        _S288 = _S289;
    }
    else
    {
        _S288 = make_float3 (0.0f);
    }
    return _S288 * make_float3 (coverage_0) + make_float3 (1.0f - coverage_0);
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S290 = hash(index_0);
    uint _S291 = hash(seed_0 ^ _S290);
    return _S291;
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float3  _S292 = a_4 / b_0;
    float3  _S293 = make_float3 (0.0f);
    bool3  _S294 = b_0 == _S293;
    float3  _S295 = _slang_select(_S294, _S293,_S292);
    return _S295;
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
    float _S296 = rgb_to_greyscale(weight_0);
    bool _S297 = _S296 > 0.0f;
    bool _S298;
    if(_S297)
    {
        _S298 = _S296 < 3.00000000549775576e+38f;
    }
    else
    {
        _S298 = false;
    }
    bool _S299 = !_S298;
    if(_S299)
    {
        return;
    }
    float _S300 = sel_0->w_sum + _S296;
    sel_0->w_sum = _S300;
    float3  _S301 = sel_0->color + weight_0;
    sel_0->color = _S301;
    Random _S302 = pcg(sel_0->random_state);
    sel_0->random_state = _S302.state;
    bool _S303 = (_S302.value * sel_0->w_sum) <= _S296;
    if(_S303)
    {
        sel_0->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_1, Reservoir r_0, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_0;
    float3  _S304 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S304;
    float _S305 = r_0.jac * shifted_0.jac;
    (&candidate_1)->jac = _S305;
    offer(sel_1, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_0.w));
    return;
}

__device__ Reservoir finalize(Selection sel_2, float c_0)
{
    Reservoir r_1 = sel_2.r;
    float _S306 = rgb_to_greyscale((&r_1)->f);
    float _S307 = sel_2.w_sum / _S306;
    bool _S308 = _S306 > 0.0f;
    float _S309 = _slang_select(_S308, _S307,0.0f);
    (&r_1)->w = _S309;
    (&r_1)->c = c_0;
    return r_1;
}

static __device__ uint insertBits_0(uint e_1, uint newbits_0, uint offset_0, uint count_0)
{
    uint _S310 = (1U << count_0) - 1U;
    return (e_1 & (~(_S310 << offset_0))) | ((newbits_0 & _S310) << offset_0);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_1, float3  f_1)
{
    Reservoir candidate_2 = r_2;
    uint _S311 = insertBits_0(r_2.path, end_1, 0U, 5U);
    uint _S312 = insertBits_0(_S311, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S312;
    (&candidate_2)->f = f_1;
    return candidate_2;
}

__device__ float facingSign(float transmission_0, float3  face_0, float3  direction_0)
{
    bool _S313 = transmission_0 > 0.0f;
    bool _S314;
    if(_S313)
    {
        _S314 = true;
    }
    else
    {
        _S314 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S315;
    if(_S314)
    {
        _S315 = 1.0f;
    }
    else
    {
        _S315 = -1.0f;
    }
    return _S315;
}

__device__ float survivalProbability(float3  throughput_1, float density_0)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_0), (0.0f)))), (1.0f)));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S316 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S317 = cos_a_0 > cos_b_0;
    float _S318 = _slang_select(_S317, 1.0f,_S316);
    return _S318;
}

__device__ float sine(float c_1)
{
    return (F32_sqrt(((F32_max((1.0f - c_1 * c_1), (0.0f))))));
}

__device__ float importance(LightNode node_0, float3  p_0, float3  normal_0)
{
    float3  _S319 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S320 = node_0.high - node_0.low;
    float3  _S321 = p_0 - _S319;
    float3  _S322 = ((((_S321)) * make_float3(rnorm3df(((_S321)).x, ((_S321)).y, ((_S321)).z))));
    float _S323 = dot_0(_S321, _S321);
    float _S324 = dot_0(_S320, _S320) / 4.0f;
    float _S325 = (F32_abs((dot_0(node_0.w, _S322))));
    float _S326 = sine(node_0.cos_theta_o);
    float _S327 = (F32_sqrt(((F32_max((1.0f - _S324 / _S323), (0.0f))))));
    bool _S328 = _S323 < _S324;
    float _S329 = _slang_select(_S328, -1.0f,_S327);
    float _S330 = sine(_S329);
    float _S331 = sine(_S325);
    float _S332 = cosSubClamped(_S331, _S325, _S326, node_0.cos_theta_o);
    float _S333 = sine(_S325);
    float _S334 = _S333 * node_0.cos_theta_o - _S325 * _S326;
    bool _S335 = _S325 > (node_0.cos_theta_o);
    float _S336 = _slang_select(_S335, 0.0f,_S334);
    float _S337 = cosSubClamped(_S336, _S332, _S330, _S329);
    bool _S338 = _S337 <= 0.0f;
    if(_S338)
    {
        return 0.0f;
    }
    float _S339 = - dot_0(_S322, normal_0);
    float _S340 = node_0.phi * _S337 / (F32_max((_S323), (length_0(_S320) / 2.0f)));
    float _S341 = sine(_S339);
    float _S342 = cosSubClamped(_S341, _S339, _S330, _S329);
    bool _S343 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S344 = _slang_select(_S343, 1.0f,_S342);
    return (F32_max((_S340 * _S344), (0.0f)));
}

__device__ float solidAngle(float probability_0, float3  normal_1, float3  toward_1)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_1)), (3.0f))) / (F32_abs((dot_0(normal_1, toward_1))));
}

__device__ uint pickChild(LightNode first_0, LightNode second_0, float3  p_1, float3  normal_2, float * pick_0, float * probability_1)
{
    float _S345 = importance(first_0, p_1, normal_2);
    float _S346 = importance(second_0, p_1, normal_2);
    float2  _S347 = make_float2 (_S345, _S346);
    bool _S348 = _S345 == 0.0f;
    bool _S349;
    if(_S348)
    {
        _S349 = _S346 == 0.0f;
    }
    else
    {
        _S349 = false;
    }
    if(_S349)
    {
        return 2U;
    }
    float _S350 = _S345 + _S346;
    bool _S351 = _S346 > 0.0f;
    if(_S351)
    {
        _S349 = (*pick_0 * _S350) >= _S345;
    }
    else
    {
        _S349 = false;
    }
    uint _S352 = uint(_S349);
    float _S353 = (F32_min(((*pick_0 * _S350 - float(_S352) * _S345) / _slang_vector_get_element(_S347, _S352)), (0.99999994039535522f)));
    *pick_0 = _S353;
    float _S354 = *probability_1 * (_slang_vector_get_element(_S347, _S352) / _S350);
    *probability_1 = _S354;
    return _S352;
}

__device__ float childShare(LightNode first_1, LightNode second_1, float3  p_2, float3  normal_3, uint child_0)
{
    float _S355 = importance(first_1, p_2, normal_3);
    float _S356 = importance(second_1, p_2, normal_3);
    float2  _S357 = make_float2 (_S355, _S356);
    float _S358 = _slang_vector_get_element(_S357, child_0) / (_S355 + _S356);
    bool _S359 = _slang_vector_get_element(_S357, child_0) > 0.0f;
    float _S360 = _slang_select(_S359, _S358,0.0f);
    return _S360;
}

__device__ float powerHeuristic(float a_5, float b_1)
{
    float _S361 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    bool _S362 = b_1 > 0.0f;
    float _S363 = _slang_select(_S362, _S361,1.0f);
    return _S363;
}

__device__ float sphereDensity(float3  center_0, float radius_1, float3  p_3)
{
    float3  _S364 = center_0 - p_3;
    float _S365 = radius_1 * radius_1 / dot_0(_S364, _S364);
    bool _S366 = _S365 >= 1.0f;
    if(_S366)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S365)))) / (6.28318548202514648f * _S365);
}

__device__ float3  sampleSphere(float3  center_1, float radius_2, float3  p_4, float u1_0, float u2_0)
{
    float3  _S367 = center_1 - p_4;
    float _S368 = radius_2 * radius_2 / dot_0(_S367, _S367);
    float _S369 = u1_0 * _S368 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S368), (0.0f)))))));
    float _S370 = 2.0f * u1_0;
    bool _S371 = _S368 >= 1.0f;
    float _S372 = _slang_select(_S371, _S370,_S369);
    float _S373 = (F32_sqrt(((F32_max((_S372 * (2.0f - _S372)), (0.0f))))));
    float _S374 = 6.28318548202514648f * u2_0;
    float3  _S375 = make_float3 (_S373 * (F32_cos((_S374))), 1.0f - _S372, _S373 * (F32_sin((_S374))));
    float3  _S376 = ((((_S367)) * make_float3(rnorm3df(((_S367)).x, ((_S367)).y, ((_S367)).z))));
    float3  _S377 = tangentToWorld(_S375, _S376);
    return _S377;
}

#undef Matrix
