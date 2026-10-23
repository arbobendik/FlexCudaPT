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
    float3  t_1 = ((((_S87)) * make_float3(rnorm3df(((_S87)).x, ((_S87)).y, ((_S87)).z))));
    bool _S88 = (dot_0(cross_0(n_4, t_1), _S86)) > 0.0f;
    float3  t_2;
    if(_S88)
    {
        float3  _S89 = negate_0(t_1);
        t_2 = _S89;
    }
    else
    {
        t_2 = t_1;
    }
    float3  _S90 = cross_0(n_4, t_2);
    return makeMatrix<float, 3, 3> (t_2, _S90, n_4);
}

__device__ float3  tangentToWorldNormalMap(float3  v_2, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_2, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_0, float3  uvw_0, float3  position_0)
{
    float3  _S91 = t1_0 - t0_0;
    float3  _S92 = t2_2 - t0_0;
    float3  _S93 = t2_2 - t1_0;
    float _S94 = (F32_min((length_0(_S91)), ((F32_min((length_0(_S92)), (length_0(_S93)))))));
    float3  _S95 = make_float3 (distance_0(position_0, t0_0), distance_0(position_0, t1_0), distance_0(position_0, t2_2));
    float3  _S96 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S97 = dot_0(geometry_n_0, _S96);
    float3  _S98 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S99 = dot_0(geometry_n_0, _S98);
    float3  _S100 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S101 = acos_0(abs_0(make_float3 (_S97, _S99, dot_0(geometry_n_0, _S100))));
    float3  _S102 = clamp_0(tan_0(_S101), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S95 * _S102, uvw_0), 0.0f, _S94 * 0.125f);
}

__device__ float3  sampleHalfVector(float3  v_3, float3  n_i_0, float alpha_3, uint * random_state_0)
{
    Random _S103 = pcg(*random_state_0);
    Random _S104 = pcg(_S103.state);
    *random_state_0 = _S104.state;
    float3  _S105 = worldToTangent(v_3, n_i_0);
    float3  _S106 = sampleGGXVNDF(float3 {_S105.x, _S105.z, _S105.y}, alpha_3, _S103.value, _S104.value);
    float3  _S107 = float3 {_S106.x, _S106.z, _S106.y};
    float3  _S108 = tangentToWorld(_S107, n_i_0);
    return _S108;
}

static __device__ float sign_0(float e_0)
{
    float _S109;
    if(e_0 > 0.0f)
    {
        _S109 = 1.0f;
    }
    else
    {
        if(e_0 < 0.0f)
        {
            _S109 = -1.0f;
        }
        else
        {
            _S109 = 0.0f;
        }
    }
    return _S109;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_5, BSDFMaterial material_0, uint random_state_1)
{
    uint state_5 = random_state_1;
    float3  _S110 = negate_0(in_dir_0);
    float _S111 = sign_0(dot_0(n_5, _S110));
    float _S112 = material_0.roughness;
    float3  _S113 = sampleHalfVector(_S110, n_5 * make_float3 (_S111), _S112 * _S112, &state_5);
    return _S113;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_6, float eta_i_1, float eta_o_1)
{
    float3  _S114 = negate_0(in_dir_1);
    float3  _S115 = negate_0(make_float3 (eta_i_1) * _S114 + make_float3 (eta_o_1) * out_dir_0);
    float3  _S116 = ((((_S115)) * make_float3(rnorm3df(((_S115)).x, ((_S115)).y, ((_S115)).z))));
    float _S117 = sign_0(dot_0(n_6, _S114));
    float _S118 = sign_0(dot_0(_S115, n_6 * make_float3 (_S117)));
    return _S116 * make_float3 (_S118);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S119 = negate_0(in_dir_2);
    float3  _S120 = _S119 + out_dir_1;
    float3  _S121 = ((((_S120)) * make_float3(rnorm3df(((_S120)).x, ((_S120)).y, ((_S120)).z))));
    return _S121;
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
    BSDFLobes _S122;
    (&_S122)->v_dot_h = v_dot_h_0;
    (&_S122)->n_dot_h = n_dot_h_1;
    (&_S122)->refracted = refracted_0;
    (&_S122)->F = F_0;
    (&_S122)->F_greyscale = F_greyscale_0;
    (&_S122)->reflect_weight = reflect_weight_0;
    (&_S122)->diffuse_weight = diffuse_weight_0;
    (&_S122)->refract_weight = refract_weight_0;
    (&_S122)->p_diffuse = p_diffuse_0;
    (&_S122)->p_reflect = p_reflect_0;
    (&_S122)->p_refract = p_refract_0;
    return _S122;
}

__device__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_4, float3  n_i_1, float3  ggx_n_0, BSDFMaterial material_1, float eta_i_2, float eta_o_2)
{
    float _S123 = dot_0(ggx_n_0, v_4);
    float _S124 = dot_0(n_i_1, ggx_n_0);
    float _S125 = eta_i_2 / eta_o_2;
    float3  _S126 = refract_0(in_dir_3, ggx_n_0, _S125);
    float3  _S127 = ((((_S126)) * make_float3(rnorm3df(((_S126)).x, ((_S126)).y, ((_S126)).z))));
    float _S128 = fresnel((F32_abs((_S123))), eta_i_2, eta_o_2);
    float3  F_1 = mix_0(make_float3 (_S128), material_1.albedo, material_1.metallic);
    float _S129 = rgb_to_greyscale(F_1);
    float _S130 = (1.0f - material_1.transmission) * (1.0f - material_1.metallic) * (1.0f - _S128);
    float _S131 = (F32_max((_S129), (0.0f)));
    float _S132 = (F32_max((_S130), (0.0f)));
    float _S133 = material_1.transmission * (1.0f - _S129);
    float _S134 = sign_0(length_0(_S127));
    float _S135 = (F32_max((_S133 * _S134), (0.0f)));
    float _S136 = _S131 + _S132 + _S135;
    float _S137 = 1.0f / (F32_max((_S136), (0.0000152587890625f)));
    float _S138 = _S132 * _S137;
    float _S139 = _S131 * _S137;
    float _S140 = _S135 * _S137;
    return BSDFLobes_x24init_0(_S123, _S124, _S127, F_1, _S129, 1.0f, _S130, material_1.transmission, _S138, _S139, _S140);
}

__device__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S141 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    bool _S142 = n_i_dot_v_0 > 0.0f;
    float _S143 = _slang_select(_S142, _S141,0.0f);
    return _S143;
}

__device__ float3  diffuseBSDF(float3  l_0, float3  n_i_2, float alpha_5, BSDFMaterial material_2, BSDFLobes lobes_1)
{
    return make_float3 (lobes_1.diffuse_weight) * material_2.albedo / make_float3 (lobes_1.p_diffuse);
}

__device__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S144 = smithG1(alpha_6, n_i_dot_v_1);
    float _S145 = _S144 * lobes_2.v_dot_h;
    float _S146 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S147 = _S145 * _S146 / n_i_dot_v_1;
    bool _S148 = alpha_6 > 0.0f;
    bool _S149;
    if(_S148)
    {
        _S149 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S149 = false;
    }
    if(_S149)
    {
        _S149 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S149 = false;
    }
    if(_S149)
    {
        _S149 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S149 = false;
    }
    float _S150 = _slang_select(_S149, _S147,0.0f);
    return _S150;
}

__device__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S151 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S152 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S153 = lobes_3.p_refract * _S151 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S152 * _S152);
    bool _S154 = eta_i_4 != eta_o_4;
    bool _S155;
    if(_S154)
    {
        _S155 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S155 = false;
    }
    float _S156 = _slang_select(_S155, _S153,0.0f);
    return _S156;
}

__device__ float3  refractBSDF(float3  l_1, float3  n_i_3, float alpha_8, BSDFMaterial material_3, BSDFLobes lobes_4)
{
    float _S157 = - dot_0(n_i_3, l_1);
    float _S158 = smithG1(alpha_8, (F32_max((_S157), (0.0f))));
    return make_float3 (lobes_4.refract_weight * _S158 * (1.0f - lobes_4.F_greyscale)) * material_3.albedo / make_float3 (lobes_4.p_refract);
}

__device__ float reflectPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S159 = vndfPDF(n_i_dot_v_3, alpha_9, lobes_5);
    float _S160 = lobes_5.p_reflect * _S159 / (4.0f * lobes_5.v_dot_h);
    bool _S161 = _S159 > 0.0f;
    float _S162 = _slang_select(_S161, _S160,0.0f);
    return _S162;
}

__device__ float3  reflectBSDF(float3  l_2, float3  n_i_4, float alpha_10, BSDFMaterial material_4, BSDFLobes lobes_6)
{
    float _S163 = dot_0(n_i_4, l_2);
    float _S164 = smithG1(alpha_10, (F32_max((_S163), (0.0f))));
    return make_float3 (lobes_6.reflect_weight * _S164) * lobes_6.F / make_float3 (lobes_6.p_reflect);
}

__device__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_5, float eta_i_6, float eta_o_6, bool refracted_1, uint random_state_2, FixedArray<float3 , 3>  * throughputs_0, FixedArray<float, 3>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S165 = negate_0(in_dir_4);
    float _S166 = dot_0(n_7, _S165);
    float _S167 = sign_0(_S166);
    float3  _S168 = n_7 * make_float3 (_S167);
    float _S169 = dot_0(_S168, out_dir_2);
    float _S170 = material_5.roughness;
    float _S171 = _S170 * _S170;
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
        float3  _S172 = make_float3 (0.0f);
        (*throughputs_0)[i_10] = _S172;
        (*pdfs_0)[i_10] = 0.0f;
        uint i_11 = i_10 + 1U;
        i_10 = i_11;
    }
    float3  _S173 = make_float3 (0.0f);
    BSDFLobes _S174 = BSDFLobes_x24init_0(0.0f, 0.0f, _S173, _S173, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f);
    uint half_of_0 = 4294967295U;
    BSDFLobes lobe_terms_0 = _S174;
    float3  ggx_n_2 = _S173;
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
        bool _S175 = i_10 == 1U;
        bool _S176 = _S175 != refracted_1;
        if(_S176)
        {
            ggx_n_1 = ggx_n_2;
            uint i_12 = i_10 + 1U;
            ggx_n_2 = ggx_n_1;
            i_10 = i_12;
            continue;
        }
        bool _S177 = i_10 != half_of_0;
        uint half_of_1;
        BSDFLobes lobe_terms_1;
        if(_S177)
        {
            bool _S178 = i_10 == 0U;
            if(_S178)
            {
                float3  _S179 = sampledHalf(in_dir_4, n_7, material_5, random_state_2);
                ggx_n_1 = _S179;
            }
            else
            {
                if(_S175)
                {
                    float3  _S180 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_6, eta_o_6);
                    ggx_n_1 = _S180;
                }
                else
                {
                    float3  _S181 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S181;
                }
            }
            float3  _S182 = negate_0(in_dir_4);
            BSDFLobes _S183 = bsdfLobes(in_dir_4, _S182, _S168, ggx_n_1, material_5, eta_i_6, eta_o_6);
            lobe_terms_1 = _S183;
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
                float _S184 = diffusePDF(_S169, 0.0f, (F32_abs((_S166))), _S171, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[int(0)] = _S184;
                float3  _S185 = diffuseBSDF(out_dir_2, _S168, _S171, material_5, lobe_terms_1);
                (*throughputs_0)[int(0)] = _S185;
                break;
            }
        case 1U:
            {
                float _S186 = refractPDF(_S169, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S166))), _S171, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[int(1)] = _S186;
                float3  _S187 = refractBSDF(out_dir_2, _S168, _S171, material_5, lobe_terms_1);
                (*throughputs_0)[int(1)] = _S187;
                break;
            }
        default:
            {
                float _S188 = reflectPDF(_S169, 0.0f, (F32_abs((_S166))), _S171, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[int(2)] = _S188;
                float3  _S189 = reflectBSDF(out_dir_2, _S168, _S171, material_5, lobe_terms_1);
                (*throughputs_0)[int(2)] = _S189;
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
    ggx_n_1 = _S173;
    for(;;)
    {
        if(i_10 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S190 = ((*pdfs_0)[i_10]) > 0.0f;
        if(_S190)
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
    SampleBSDF _S191;
    (&_S191)->unit_direction = unit_direction_0;
    (&_S191)->throughput = throughput_0;
    (&_S191)->random_state = random_state_3;
    (&_S191)->refracted = refracted_2;
    (&_S191)->lobe = lobe_0;
    (&_S191)->pdf = pdf_0;
    return _S191;
}

__device__ SampleBSDF diffuseSample(float3  n_i_5, float n_i_dot_v_4, float alpha_11, BSDFMaterial material_6, BSDFLobes lobes_7, float eta_i_7, float eta_o_7, uint random_state_4)
{
    float3  _S192 = make_float3 (1.0f);
    SampleBSDF _S193 = SampleBSDF_x24init_0(_S192, _S192, 0U, false, 0U, 0.0f);
    SampleBSDF sample_0 = _S193;
    Random _S194 = pcg(random_state_4);
    Random _S195 = pcg(_S194.state);
    (&sample_0)->random_state = _S195.state;
    float3  _S196 = sampleCosWeightedHemisphere(_S194.value, _S195.value);
    float3  _S197 = tangentToWorld(_S196, n_i_5);
    (&sample_0)->unit_direction = _S197;
    (&sample_0)->lobe = 0U;
    float3  _S198 = diffuseBSDF((&sample_0)->unit_direction, n_i_5, alpha_11, material_6, lobes_7);
    (&sample_0)->throughput = _S198;
    float _S199 = diffusePDF(_S196.y, 0.0f, n_i_dot_v_4, alpha_11, lobes_7, eta_i_7, eta_o_7);
    (&sample_0)->pdf = _S199;
    return sample_0;
}

__device__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_6, float n_i_dot_v_5, float alpha_12, BSDFMaterial material_7, BSDFLobes lobes_8, float eta_i_8, float eta_o_8, uint random_state_5)
{
    float3  _S200 = make_float3 (1.0f);
    SampleBSDF _S201 = SampleBSDF_x24init_0(_S200, _S200, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S201;
    (&sample_1)->unit_direction = lobes_8.refracted;
    (&sample_1)->random_state = random_state_5;
    (&sample_1)->refracted = true;
    (&sample_1)->lobe = 1U;
    float3  _S202 = refractBSDF((&sample_1)->unit_direction, n_i_6, alpha_12, material_7, lobes_8);
    (&sample_1)->throughput = _S202;
    float _S203 = refractPDF(0.0f, dot_0((&sample_1)->unit_direction, ggx_n_3), n_i_dot_v_5, alpha_12, lobes_8, eta_i_8, eta_o_8);
    (&sample_1)->pdf = _S203;
    return sample_1;
}

__device__ SampleBSDF reflectSample(float3  in_dir_5, float3  ggx_n_4, float3  n_i_7, float n_i_dot_v_6, float alpha_13, BSDFMaterial material_8, BSDFLobes lobes_9, float eta_i_9, float eta_o_9, uint random_state_6)
{
    float3  _S204 = make_float3 (1.0f);
    SampleBSDF _S205 = SampleBSDF_x24init_0(_S204, _S204, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S205;
    float3  _S206 = reflect_0(in_dir_5, ggx_n_4);
    float3  _S207 = ((((_S206)) * make_float3(rnorm3df(((_S206)).x, ((_S206)).y, ((_S206)).z))));
    (&sample_2)->unit_direction = _S207;
    (&sample_2)->random_state = random_state_6;
    (&sample_2)->lobe = 2U;
    float3  _S208 = reflectBSDF((&sample_2)->unit_direction, n_i_7, alpha_13, material_8, lobes_9);
    (&sample_2)->throughput = _S208;
    float _S209 = reflectPDF(0.0f, 0.0f, n_i_dot_v_6, alpha_13, lobes_9, eta_i_9, eta_o_9);
    (&sample_2)->pdf = _S209;
    return sample_2;
}

__device__ SampleBSDF sampleBSDF(float3  in_dir_6, float3  n_8, BSDFMaterial material_9, float eta_i_10, float eta_o_10, uint random_init_0, float2  screen_space_0)
{
    uint random_state_7 = random_init_0;
    float3  _S210 = negate_0(in_dir_6);
    float _S211 = dot_0(n_8, _S210);
    float _S212 = sign_0(_S211);
    float3  n_i_8 = n_8 * make_float3 (_S212);
    float _S213 = (F32_abs((_S211)));
    float _S214 = material_9.roughness;
    float _S215 = _S214 * _S214;
    float3  _S216 = sampleHalfVector(_S210, n_i_8, _S215, &random_state_7);
    BSDFLobes _S217 = bsdfLobes(in_dir_6, _S210, n_i_8, _S216, material_9, eta_i_10, eta_o_10);
    Random _S218 = pcg(random_state_7);
    random_state_7 = _S218.state;
    bool _S219 = (_S218.value) < (_S217.p_diffuse);
    if(_S219)
    {
        SampleBSDF _S220 = diffuseSample(n_i_8, _S213, _S215, material_9, _S217, eta_i_10, eta_o_10, random_state_7);
        return _S220;
    }
    bool _S221 = (_S218.value) < (_S217.p_diffuse + _S217.p_refract);
    if(_S221)
    {
        SampleBSDF _S222 = refractSample(_S216, n_i_8, _S213, _S215, material_9, _S217, eta_i_10, eta_o_10, random_state_7);
        return _S222;
    }
    SampleBSDF _S223 = reflectSample(in_dir_6, _S216, n_i_8, _S213, _S215, material_9, _S217, eta_i_10, eta_o_10, random_state_7);
    return _S223;
}

__device__ float3  pointLightRadiance(float3  color_0, float intensity_0, float radius_0)
{
    return color_0 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_0 * radius_0);
}

__device__ float3  beerLambert(float distance_1, float3  absorption_0)
{
    float3  _S224 = max_0(absorption_0, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_1) * log_0(_S224));
}

__device__ bool neeDecision(BSDFMaterial material_10, float n_dot_v_0, float eta_i_11, float eta_o_11)
{
    float _S225 = fresnel((F32_abs((n_dot_v_0))), eta_i_11, eta_o_11);
    float3  _S226 = mix_0(make_float3 (_S225), material_10.albedo, material_10.metallic);
    float _S227 = rgb_to_greyscale(_S226);
    float _S228 = (F32_max(((1.0f - _S227) * (1.0f - material_10.metallic) * (1.0f - material_10.transmission)), (0.0f)));
    bool _S229 = _S228 > 0.03999999910593033f;
    bool _S230;
    if(_S229)
    {
        _S230 = true;
    }
    else
    {
        _S230 = (material_10.roughness) > 0.20000000298023224f;
    }
    return _S230;
}

__device__ float3  straightThrough(float3  dir_0, float3  n_9, BSDFMaterial material_11)
{
    float _S231 = rgb_to_greyscale(material_11.albedo * make_float3 (material_11.metallic));
    float _S232 = material_11.roughness;
    float _S233 = smithG1(_S232 * _S232, (F32_abs((dot_0(n_9, dir_0)))));
    return make_float3 (material_11.transmission * _S233 * (1.0f - _S231)) * material_11.albedo;
}

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_0, float3  end_0)
{
    float _S234 = sign_0(dot_0(light_n_0, start_0 - end_0));
    return light_n_0 * make_float3 (_S234 * light_offset_0);
}

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

__device__ float3  occluderTransmittance(float3  toward_0, float3  n_10, BSDFMaterial material_12, float coverage_0)
{
    float3  _S235;
    if((material_12.ior) == 1.0f)
    {
        float3  _S236 = straightThrough(toward_0, n_10, material_12);
        _S235 = _S236;
    }
    else
    {
        _S235 = make_float3 (0.0f);
    }
    return _S235 * make_float3 (coverage_0) + make_float3 (1.0f - coverage_0);
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S237 = hash(index_0);
    uint _S238 = hash(seed_0 ^ _S237);
    return _S238;
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float3  _S239 = a_4 / b_0;
    float3  _S240 = make_float3 (0.0f);
    bool3  _S241 = b_0 == _S240;
    float3  _S242 = _slang_select(_S241, _S240,_S239);
    return _S242;
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
    float _S243 = rgb_to_greyscale(weight_0);
    bool _S244 = _S243 > 0.0f;
    bool _S245;
    if(_S244)
    {
        _S245 = _S243 < 3.00000000549775576e+38f;
    }
    else
    {
        _S245 = false;
    }
    bool _S246 = !_S245;
    if(_S246)
    {
        return;
    }
    float _S247 = sel_0->w_sum + _S243;
    sel_0->w_sum = _S247;
    float3  _S248 = sel_0->color + weight_0;
    sel_0->color = _S248;
    Random _S249 = pcg(sel_0->random_state);
    sel_0->random_state = _S249.state;
    bool _S250 = (_S249.value * sel_0->w_sum) <= _S243;
    if(_S250)
    {
        sel_0->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_1, Reservoir r_0, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_0;
    float3  _S251 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S251;
    float _S252 = r_0.jac * shifted_0.jac;
    (&candidate_1)->jac = _S252;
    offer(sel_1, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_0.w));
    return;
}

__device__ Reservoir finalize(Selection sel_2, float c_0)
{
    Reservoir r_1 = sel_2.r;
    float _S253 = rgb_to_greyscale((&r_1)->f);
    float _S254 = sel_2.w_sum / _S253;
    bool _S255 = _S253 > 0.0f;
    float _S256 = _slang_select(_S255, _S254,0.0f);
    (&r_1)->w = _S256;
    (&r_1)->c = c_0;
    return r_1;
}

static __device__ uint insertBits_0(uint e_1, uint newbits_0, uint offset_0, uint count_0)
{
    uint _S257 = (1U << count_0) - 1U;
    return (e_1 & (~(_S257 << offset_0))) | ((newbits_0 & _S257) << offset_0);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_1, float3  f_1)
{
    Reservoir candidate_2 = r_2;
    uint _S258 = insertBits_0(r_2.path, end_1, 0U, 5U);
    uint _S259 = insertBits_0(_S258, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S259;
    (&candidate_2)->f = f_1;
    return candidate_2;
}

__device__ float facingSign(float transmission_0, float3  face_0, float3  direction_0)
{
    bool _S260 = transmission_0 > 0.0f;
    bool _S261;
    if(_S260)
    {
        _S261 = true;
    }
    else
    {
        _S261 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S262;
    if(_S261)
    {
        _S262 = 1.0f;
    }
    else
    {
        _S262 = -1.0f;
    }
    return _S262;
}

__device__ float survivalProbability(float3  throughput_1, float density_0)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_0), (0.0f)))), (1.0f)));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S263 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S264 = cos_a_0 > cos_b_0;
    float _S265 = _slang_select(_S264, 1.0f,_S263);
    return _S265;
}

__device__ float sine(float c_1)
{
    return (F32_sqrt(((F32_max((1.0f - c_1 * c_1), (0.0f))))));
}

__device__ float importance(LightNode node_0, float3  p_0, float3  normal_0)
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
    float _S281 = _S280 * node_0.cos_theta_o - _S272 * _S273;
    bool _S282 = _S272 > (node_0.cos_theta_o);
    float _S283 = _slang_select(_S282, 0.0f,_S281);
    float _S284 = cosSubClamped(_S283, _S279, _S277, _S276);
    bool _S285 = _S284 <= 0.0f;
    if(_S285)
    {
        return 0.0f;
    }
    float _S286 = - dot_0(_S269, normal_0);
    float _S287 = node_0.phi * _S284 / (F32_max((_S270), (length_0(_S267) / 2.0f)));
    float _S288 = sine(_S286);
    float _S289 = cosSubClamped(_S288, _S286, _S277, _S276);
    bool _S290 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S291 = _slang_select(_S290, 1.0f,_S289);
    return (F32_max((_S287 * _S291), (0.0f)));
}

__device__ float solidAngle(float probability_0, float3  normal_1, float3  toward_1)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_1)), (3.0f))) / (F32_abs((dot_0(normal_1, toward_1))));
}

__device__ uint pickChild(LightNode first_0, LightNode second_0, float3  p_1, float3  normal_2, float * pick_0, float * probability_1)
{
    float _S292 = importance(first_0, p_1, normal_2);
    float _S293 = importance(second_0, p_1, normal_2);
    float2  _S294 = make_float2 (_S292, _S293);
    bool _S295 = _S292 == 0.0f;
    bool _S296;
    if(_S295)
    {
        _S296 = _S293 == 0.0f;
    }
    else
    {
        _S296 = false;
    }
    if(_S296)
    {
        return 2U;
    }
    float _S297 = _S292 + _S293;
    bool _S298 = _S293 > 0.0f;
    if(_S298)
    {
        _S296 = (*pick_0 * _S297) >= _S292;
    }
    else
    {
        _S296 = false;
    }
    uint _S299 = uint(_S296);
    float _S300 = (F32_min(((*pick_0 * _S297 - float(_S299) * _S292) / _slang_vector_get_element(_S294, _S299)), (0.99999994039535522f)));
    *pick_0 = _S300;
    float _S301 = *probability_1 * (_slang_vector_get_element(_S294, _S299) / _S297);
    *probability_1 = _S301;
    return _S299;
}

__device__ float childShare(LightNode first_1, LightNode second_1, float3  p_2, float3  normal_3, uint child_0)
{
    float _S302 = importance(first_1, p_2, normal_3);
    float _S303 = importance(second_1, p_2, normal_3);
    float2  _S304 = make_float2 (_S302, _S303);
    float _S305 = _slang_vector_get_element(_S304, child_0) / (_S302 + _S303);
    bool _S306 = _slang_vector_get_element(_S304, child_0) > 0.0f;
    float _S307 = _slang_select(_S306, _S305,0.0f);
    return _S307;
}

__device__ float powerHeuristic(float a_5, float b_1)
{
    float _S308 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    bool _S309 = b_1 > 0.0f;
    float _S310 = _slang_select(_S309, _S308,1.0f);
    return _S310;
}

__device__ float sphereDensity(float3  center_0, float radius_1, float3  p_3)
{
    float3  _S311 = center_0 - p_3;
    float _S312 = radius_1 * radius_1 / dot_0(_S311, _S311);
    bool _S313 = _S312 >= 1.0f;
    if(_S313)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S312)))) / (6.28318548202514648f * _S312);
}

__device__ float3  sampleSphere(float3  center_1, float radius_2, float3  p_4, float u1_0, float u2_0)
{
    float3  _S314 = center_1 - p_4;
    float _S315 = radius_2 * radius_2 / dot_0(_S314, _S314);
    float _S316 = u1_0 * _S315 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S315), (0.0f)))))));
    float _S317 = 2.0f * u1_0;
    bool _S318 = _S315 >= 1.0f;
    float _S319 = _slang_select(_S318, _S317,_S316);
    float _S320 = (F32_sqrt(((F32_max((_S319 * (2.0f - _S319)), (0.0f))))));
    float _S321 = 6.28318548202514648f * u2_0;
    float3  _S322 = make_float3 (_S320 * (F32_cos((_S321))), 1.0f - _S319, _S320 * (F32_sin((_S321))));
    float3  _S323 = ((((_S314)) * make_float3(rnorm3df(((_S314)).x, ((_S314)).y, ((_S314)).z))));
    float3  _S324 = tangentToWorld(_S322, _S323);
    return _S324;
}

#undef Matrix
