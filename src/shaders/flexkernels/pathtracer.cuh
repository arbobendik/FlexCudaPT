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

__device__ float smithG1(float alpha_1, float n_dot_x_0)
{
    float _S26 = alpha_1 * alpha_1;
    float _S27 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S26 + (1.0f - _S26) * n_dot_x_0 * n_dot_x_0))));
    bool _S28 = alpha_1 > 0.0f;
    float _S29 = _slang_select(_S28, _S27,1.0f);
    return _S29;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S30 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S31 = eta_i_0 / eta_o_0 * _S30;
    bool _S32 = _S31 < 1.0f;
    float kr_0;
    if(_S32)
    {
        float _S33 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S31 * _S31))))));
        float _S34 = eta_o_0 * cos_theta_0;
        float _S35 = eta_i_0 * _S33;
        float _S36 = (_S34 - _S35) / (_S34 + _S35);
        float _S37 = eta_i_0 * cos_theta_0;
        float _S38 = eta_o_0 * _S33;
        float _S39 = (_S37 - _S38) / (_S37 + _S38);
        float _S40 = (_S36 * _S36 + _S39 * _S39) / 2.0f;
        kr_0 = _S40;
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
    float3  _S41 = make_float3 (alpha_2 * Ve_0.x, alpha_2 * Ve_0.y, Ve_0.z);
    float3  _S42 = ((((_S41)) * make_float3(rnorm3df(((_S41)).x, ((_S41)).y, ((_S41)).z))));
    float _S43 = _S42.x;
    float _S44 = _S42.y;
    float _S45 = _S43 * _S43 + _S44 * _S44;
    float3  _S46;
    if(_S45 > 0.0f)
    {
        float3  _S47 = make_float3 (- _S44, _S43, 0.0f);
        float _S48 = (rsqrtf((_S45)));
        _S46 = _S47 * make_float3 (_S48);
    }
    else
    {
        _S46 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S49 = cross_0(_S42, _S46);
    float _S50 = (F32_sqrt((U1_0)));
    float _S51 = 6.28318548202514648f * U2_0;
    float _S52 = _S50 * (F32_cos((_S51)));
    float t2_0 = _S50 * (F32_sin((_S51)));
    float _S53 = 0.5f * (1.0f + _S42.z);
    float t2_1 = (1.0f - _S53) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S52 * _S52)))))) + _S53 * t2_0;
    float3  _S54 = make_float3 (_S52) * _S46 + make_float3 (t2_1) * _S49;
    float _S55 = unshared_0(_S52);
    float _S56 = unshared_0(_S52);
    float3  _S57 = _S54 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S55 * _S56 - t2_1 * t2_1))))))) * _S42;
    float3  _S58 = make_float3 (alpha_2 * _S57.x, alpha_2 * _S57.y, (F32_max((0.0f), (_S57.z))));
    float3  _S59 = ((((_S58)) * make_float3(rnorm3df(((_S58)).x, ((_S58)).y, ((_S58)).z))));
    return _S59;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S60 = (F32_sqrt((random_1_0)));
    float _S61 = 6.28318548202514648f * random_2_0;
    float _S62 = _S60 * (F32_cos((_S61)));
    float _S63 = _S60 * (F32_sin((_S61)));
    float _S64 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S62 * _S62 - _S63 * _S63))))));
    return make_float3 (_S62, _S64, _S63);
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_2)
{
    float3  a_0 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S65 = (F32_abs((dot_0(n_2, a_0)))) > 0.9999847412109375f;
    float3  a_1;
    if(_S65)
    {
        float3  _S66 = make_float3 (1.0f, 0.0f, 0.0f);
        a_1 = _S66;
    }
    else
    {
        a_1 = a_0;
    }
    float3  _S67 = cross_0(n_2, a_1);
    float3  _S68 = ((((_S67)) * make_float3(rnorm3df(((_S67)).x, ((_S67)).y, ((_S67)).z))));
    float3  _S69 = cross_0(n_2, _S68);
    return make_float3 (v_0.x) * _S68 + make_float3 (v_0.y) * n_2 + make_float3 (v_0.z) * _S69;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
{
    float3  a_2 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S70 = (F32_abs((dot_0(n_3, a_2)))) > 0.9999847412109375f;
    float3  a_3;
    if(_S70)
    {
        float3  _S71 = make_float3 (1.0f, 0.0f, 0.0f);
        a_3 = _S71;
    }
    else
    {
        a_3 = a_2;
    }
    float3  _S72 = cross_0(n_3, a_3);
    float3  _S73 = ((((_S72)) * make_float3(rnorm3df(((_S72)).x, ((_S72)).y, ((_S72)).z))));
    float3  _S74 = cross_0(n_3, _S73);
    return make_float3 (dot_0(v_1, _S73), dot_0(v_1, n_3), dot_0(v_1, _S74));
}

static __device__ float3  negate_0(float3  x_14)
{
    return - x_14;
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_4)
{
    float3  _S75 = p1_0 - p0_0;
    float3  _S76 = p2_0 - p0_0;
    float2  _S77 = uv1_0 - uv0_0;
    float2  _S78 = uv2_0 - uv0_0;
    float _S79 = _S77.x;
    float _S80 = _S78.y;
    float _S81 = _S77.y;
    float _S82 = _S78.x;
    float _S83 = _S79 * _S80 - _S81 * _S82;
    float _S84 = 1.0f / _S83;
    float3  t_0 = (_S75 * make_float3 (_S80) - _S76 * make_float3 (_S81)) * make_float3 (_S84);
    float3  _S85 = (_S76 * make_float3 (_S79) - _S75 * make_float3 (_S82)) * make_float3 (_S84);
    float3  _S86 = t_0 - n_4 * make_float3 (dot_0(n_4, t_0));
    float3  t_1 = ((((_S86)) * make_float3(rnorm3df(((_S86)).x, ((_S86)).y, ((_S86)).z))));
    bool _S87 = (dot_0(cross_0(n_4, t_1), _S85)) > 0.0f;
    float3  t_2;
    if(_S87)
    {
        float3  _S88 = negate_0(t_1);
        t_2 = _S88;
    }
    else
    {
        t_2 = t_1;
    }
    float3  _S89 = cross_0(n_4, t_2);
    return makeMatrix<float, 3, 3> (t_2, _S89, n_4);
}

__device__ float3  tangentToWorldNormalMap(float3  v_2, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_2, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_0, float3  uvw_0, float3  position_0)
{
    float3  _S90 = t1_0 - t0_0;
    float3  _S91 = t2_2 - t0_0;
    float3  _S92 = t2_2 - t1_0;
    float _S93 = (F32_min((length_0(_S90)), ((F32_min((length_0(_S91)), (length_0(_S92)))))));
    float3  _S94 = make_float3 (distance_0(position_0, t0_0), distance_0(position_0, t1_0), distance_0(position_0, t2_2));
    float3  _S95 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S96 = dot_0(geometry_n_0, _S95);
    float3  _S97 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S98 = dot_0(geometry_n_0, _S97);
    float3  _S99 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S100 = acos_0(abs_0(make_float3 (_S96, _S98, dot_0(geometry_n_0, _S99))));
    float3  _S101 = clamp_0(tan_0(_S100), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S94 * _S101, uvw_0), 0.0f, _S93 * 0.125f);
}

__device__ float3  sampleHalfVector(float3  v_3, float3  n_i_0, float alpha_3, uint * random_state_0)
{
    Random _S102 = pcg(*random_state_0);
    Random _S103 = pcg(_S102.state);
    *random_state_0 = _S103.state;
    float3  _S104 = worldToTangent(v_3, n_i_0);
    float3  _S105 = sampleGGXVNDF(float3 {_S104.x, _S104.z, _S104.y}, alpha_3, _S102.value, _S103.value);
    float3  _S106 = float3 {_S105.x, _S105.z, _S105.y};
    float3  _S107 = tangentToWorld(_S106, n_i_0);
    return _S107;
}

static __device__ float sign_0(float e_0)
{
    float _S108;
    if(e_0 > 0.0f)
    {
        _S108 = 1.0f;
    }
    else
    {
        if(e_0 < 0.0f)
        {
            _S108 = -1.0f;
        }
        else
        {
            _S108 = 0.0f;
        }
    }
    return _S108;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_5, BSDFMaterial material_0, uint random_state_1)
{
    uint state_6 = random_state_1;
    float3  _S109 = negate_0(in_dir_0);
    float _S110 = sign_0(dot_0(n_5, _S109));
    float _S111 = material_0.roughness;
    float3  _S112 = sampleHalfVector(_S109, n_5 * make_float3 (_S110), _S111 * _S111, &state_6);
    return _S112;
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
    BSDFLobes _S113;
    (&_S113)->v_dot_h = v_dot_h_0;
    (&_S113)->n_dot_h = n_dot_h_1;
    (&_S113)->refracted = refracted_0;
    (&_S113)->F = F_0;
    (&_S113)->F_greyscale = F_greyscale_0;
    (&_S113)->reflect_weight = reflect_weight_0;
    (&_S113)->diffuse_weight = diffuse_weight_0;
    (&_S113)->refract_weight = refract_weight_0;
    (&_S113)->p_diffuse = p_diffuse_0;
    (&_S113)->p_reflect = p_reflect_0;
    (&_S113)->p_refract = p_refract_0;
    return _S113;
}

__device__ BSDFLobes bsdfLobes(float3  in_dir_1, float3  v_4, float3  n_i_1, float3  ggx_n_0, BSDFMaterial material_1, float eta_i_1, float eta_o_1)
{
    float _S114 = dot_0(ggx_n_0, v_4);
    float _S115 = dot_0(n_i_1, ggx_n_0);
    float _S116 = eta_i_1 / eta_o_1;
    float3  _S117 = refract_0(in_dir_1, ggx_n_0, _S116);
    float3  _S118 = ((((_S117)) * make_float3(rnorm3df(((_S117)).x, ((_S117)).y, ((_S117)).z))));
    float _S119 = (F32_min(((F32_sqrt((material_1.specular_level))) * (F32_abs((eta_i_1 - eta_o_1))) / (eta_i_1 + eta_o_1)), (0.9999847412109375f)));
    float _S120 = _S119 * _S119;
    float _S121 = (1.0f + _S119) / (1.0f - _S119);
    float _S122 = (F32_abs((_S114)));
    bool _S123 = eta_i_1 > eta_o_1;
    float _S124;
    if(_S123)
    {
        _S124 = _S121;
    }
    else
    {
        _S124 = 1.0f;
    }
    float _S125;
    if(_S123)
    {
        _S125 = 1.0f;
    }
    else
    {
        _S125 = _S121;
    }
    float _S126 = fresnel(_S122, _S124, _S125);
    bool _S127 = (eta_i_1 * eta_i_1 * (1.0f - _S114 * _S114)) >= (eta_o_1 * eta_o_1);
    float3  _S128;
    if(_S127)
    {
        _S128 = make_float3 (1.0f);
    }
    else
    {
        float3  _S129 = material_1.specular_tint * make_float3 (_S120);
        _S128 = _S129 + (make_float3 (1.0f) - _S129) * make_float3 (_S126 - _S120) / make_float3 (1.0f - _S120);
    }
    float3  F_1 = mix_0(_S128, material_1.albedo, material_1.metallic);
    float _S130 = rgb_to_greyscale(F_1);
    float _S131 = 1.0f - material_1.metallic;
    float3  _S132 = make_float3 (1.0f) - _S128;
    float3  _S133 = make_float3 ((1.0f - material_1.transmission) * _S131) * _S132;
    float3  _S134 = make_float3 (material_1.transmission * _S131) * _S132;
    float _S135 = (F32_max((_S130), (0.0f)));
    float _S136 = rgb_to_greyscale(_S133);
    float _S137 = (F32_max((_S136), (0.0f)));
    float _S138 = rgb_to_greyscale(_S134);
    float _S139 = sign_0(length_0(_S118));
    float _S140 = (F32_max((_S138 * _S139), (0.0f)));
    float _S141 = _S135 + _S137 + _S140;
    float _S142 = 1.0f / (F32_max((_S141), (0.0000152587890625f)));
    float _S143 = _S137 * _S142;
    float _S144 = _S135 * _S142;
    float _S145 = _S140 * _S142;
    return BSDFLobes_x24init_0(_S114, _S115, _S118, F_1, _S130, 1.0f, _S133, _S134, _S143, _S144, _S145);
}

__device__ float3  refractedHalf(float3  in_dir_2, float3  out_dir_0, float3  n_6, float eta_i_2, float eta_o_2)
{
    float3  _S146 = negate_0(in_dir_2);
    float3  _S147 = negate_0(make_float3 (eta_i_2) * _S146 + make_float3 (eta_o_2) * out_dir_0);
    float3  _S148 = ((((_S147)) * make_float3(rnorm3df(((_S147)).x, ((_S147)).y, ((_S147)).z))));
    float _S149 = sign_0(dot_0(n_6, _S146));
    float _S150 = sign_0(dot_0(_S147, n_6 * make_float3 (_S149)));
    return _S148 * make_float3 (_S150);
}

__device__ float3  reflectedHalf(float3  in_dir_3, float3  out_dir_1)
{
    float3  _S151 = negate_0(in_dir_3);
    float3  _S152 = _S151 + out_dir_1;
    float3  _S153 = ((((_S152)) * make_float3(rnorm3df(((_S152)).x, ((_S152)).y, ((_S152)).z))));
    return _S153;
}

__device__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S154 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    bool _S155 = n_i_dot_v_0 > 0.0f;
    float _S156 = _slang_select(_S155, _S154,0.0f);
    return _S156;
}

__device__ float3  diffuseBSDF(float3  l_0, float3  n_i_2, float alpha_5, BSDFMaterial material_2, BSDFLobes lobes_1)
{
    return lobes_1.diffuse_weight * material_2.albedo / make_float3 (lobes_1.p_diffuse);
}

__device__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S157 = smithG1(alpha_6, n_i_dot_v_1);
    float _S158 = _S157 * lobes_2.v_dot_h;
    float _S159 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S160 = _S158 * _S159 / n_i_dot_v_1;
    bool _S161 = alpha_6 > 0.0f;
    bool _S162;
    if(_S161)
    {
        _S162 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S162 = false;
    }
    if(_S162)
    {
        _S162 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S162 = false;
    }
    if(_S162)
    {
        _S162 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S162 = false;
    }
    float _S163 = _slang_select(_S162, _S160,0.0f);
    return _S163;
}

__device__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S164 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S165 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S166 = lobes_3.p_refract * _S164 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S165 * _S165);
    bool _S167 = eta_i_4 != eta_o_4;
    bool _S168;
    if(_S167)
    {
        _S168 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S168 = false;
    }
    float _S169 = _slang_select(_S168, _S166,0.0f);
    return _S169;
}

__device__ float3  refractBSDF(float3  l_1, float3  n_i_3, float alpha_8, BSDFMaterial material_3, BSDFLobes lobes_4)
{
    float _S170 = - dot_0(n_i_3, l_1);
    float _S171 = smithG1(alpha_8, (F32_max((_S170), (0.0f))));
    return lobes_4.refract_weight * make_float3 (_S171) * material_3.albedo / make_float3 (lobes_4.p_refract);
}

__device__ float reflectPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S172 = vndfPDF(n_i_dot_v_3, alpha_9, lobes_5);
    float _S173 = lobes_5.p_reflect * _S172 / (4.0f * lobes_5.v_dot_h);
    bool _S174 = _S172 > 0.0f;
    float _S175 = _slang_select(_S174, _S173,0.0f);
    return _S175;
}

__device__ float3  reflectBSDF(float3  l_2, float3  n_i_4, float alpha_10, BSDFMaterial material_4, BSDFLobes lobes_6)
{
    float _S176 = dot_0(n_i_4, l_2);
    float _S177 = smithG1(alpha_10, (F32_max((_S176), (0.0f))));
    return make_float3 (lobes_6.reflect_weight * _S177) * lobes_6.F / make_float3 (lobes_6.p_reflect);
}

__device__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_5, float eta_i_6, float eta_o_6, bool refracted_1, uint random_state_2, FixedArray<float3 , 3>  * throughputs_0, FixedArray<float, 3>  * pdfs_0)
{
    float3  _S178 = negate_0(in_dir_4);
    float _S179 = dot_0(n_7, _S178);
    float _S180 = sign_0(_S179);
    float3  _S181 = n_7 * make_float3 (_S180);
    float _S182 = dot_0(_S181, out_dir_2);
    float _S183 = material_5.roughness;
    float _S184 = _S183 * _S183;
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
        float3  _S185 = make_float3 (0.0f);
        (*throughputs_0)[i_10] = _S185;
        (*pdfs_0)[i_10] = 0.0f;
        uint i_11 = i_10 + 1U;
        i_10 = i_11;
    }
    float3  _S186 = make_float3 (0.0f);
    BSDFLobes _S187 = BSDFLobes_x24init_0(0.0f, 0.0f, _S186, _S186, 0.0f, 0.0f, _S186, _S186, 0.0f, 0.0f, 0.0f);
    bool _S188 = !refracted_1;
    BSDFLobes sampled_terms_0;
    if(_S188)
    {
        float3  sampled_n_0 = sampledHalf(in_dir_4, n_7, material_5, random_state_2);
        float3  _S189 = negate_0(in_dir_4);
        BSDFLobes _S190 = bsdfLobes(in_dir_4, _S189, _S181, sampled_n_0, material_5, eta_i_6, eta_o_6);
        sampled_terms_0 = _S190;
    }
    else
    {
        sampled_terms_0 = _S187;
    }
    float3  f_0;
    if(refracted_1)
    {
        float3  _S191 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_6, eta_o_6);
        f_0 = _S191;
    }
    else
    {
        float3  _S192 = reflectedHalf(in_dir_4, out_dir_2);
        f_0 = _S192;
    }
    float3  _S193 = negate_0(in_dir_4);
    BSDFLobes _S194 = bsdfLobes(in_dir_4, _S193, _S181, f_0, material_5, eta_i_6, eta_o_6);
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
        bool _S195 = (i_10 == 1U) != refracted_1;
        if(_S195)
        {
            uint i_12 = i_10 + 1U;
            i_10 = i_12;
            continue;
        }
        switch(i_10)
        {
        case 0U:
            {
                float _S196 = diffusePDF(_S182, 0.0f, (F32_abs((_S179))), _S184, sampled_terms_0, eta_i_6, eta_o_6);
                (*pdfs_0)[int(0)] = _S196;
                float3  _S197 = diffuseBSDF(out_dir_2, _S181, _S184, material_5, sampled_terms_0);
                (*throughputs_0)[int(0)] = _S197;
                break;
            }
        case 1U:
            {
                float _S198 = refractPDF(_S182, dot_0(out_dir_2, f_0), (F32_abs((_S179))), _S184, _S194, eta_i_6, eta_o_6);
                (*pdfs_0)[int(1)] = _S198;
                float3  _S199 = refractBSDF(out_dir_2, _S181, _S184, material_5, _S194);
                (*throughputs_0)[int(1)] = _S199;
                break;
            }
        default:
            {
                float _S200 = reflectPDF(_S182, 0.0f, (F32_abs((_S179))), _S184, _S194, eta_i_6, eta_o_6);
                (*pdfs_0)[int(2)] = _S200;
                float3  _S201 = reflectBSDF(out_dir_2, _S181, _S184, material_5, _S194);
                (*throughputs_0)[int(2)] = _S201;
                break;
            }
        }
        uint i_12 = i_10 + 1U;
        i_10 = i_12;
    }
    i_10 = 0U;
    f_0 = _S186;
    for(;;)
    {
        if(i_10 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S202 = ((*pdfs_0)[i_10]) > 0.0f;
        if(_S202)
        {
            float3  f_1 = f_0 + (*throughputs_0)[i_10] * make_float3 ((*pdfs_0)[i_10]);
            f_0 = f_1;
        }
        uint i_13 = i_10 + 1U;
        i_10 = i_13;
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

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_0, float3  throughput_0, uint random_state_3, bool refracted_2, uint lobe_0, float pdf_0)
{
    SampleBSDF _S203;
    (&_S203)->unit_direction = unit_direction_0;
    (&_S203)->throughput = throughput_0;
    (&_S203)->random_state = random_state_3;
    (&_S203)->refracted = refracted_2;
    (&_S203)->lobe = lobe_0;
    (&_S203)->pdf = pdf_0;
    return _S203;
}

__device__ SampleBSDF diffuseSample(float3  n_i_5, float n_i_dot_v_4, float alpha_11, BSDFMaterial material_6, BSDFLobes lobes_7, float eta_i_7, float eta_o_7, uint random_state_4)
{
    float3  _S204 = make_float3 (1.0f);
    SampleBSDF _S205 = SampleBSDF_x24init_0(_S204, _S204, 0U, false, 0U, 0.0f);
    SampleBSDF sample_0 = _S205;
    Random _S206 = pcg(random_state_4);
    Random _S207 = pcg(_S206.state);
    (&sample_0)->random_state = _S207.state;
    float3  _S208 = sampleCosWeightedHemisphere(_S206.value, _S207.value);
    float3  _S209 = tangentToWorld(_S208, n_i_5);
    (&sample_0)->unit_direction = _S209;
    (&sample_0)->lobe = 0U;
    float3  _S210 = diffuseBSDF((&sample_0)->unit_direction, n_i_5, alpha_11, material_6, lobes_7);
    (&sample_0)->throughput = _S210;
    float _S211 = diffusePDF(_S208.y, 0.0f, n_i_dot_v_4, alpha_11, lobes_7, eta_i_7, eta_o_7);
    (&sample_0)->pdf = _S211;
    return sample_0;
}

__device__ SampleBSDF refractSample(float3  ggx_n_1, float3  n_i_6, float n_i_dot_v_5, float alpha_12, BSDFMaterial material_7, BSDFLobes lobes_8, float eta_i_8, float eta_o_8, uint random_state_5)
{
    float3  _S212 = make_float3 (1.0f);
    SampleBSDF _S213 = SampleBSDF_x24init_0(_S212, _S212, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S213;
    (&sample_1)->unit_direction = lobes_8.refracted;
    (&sample_1)->random_state = random_state_5;
    (&sample_1)->refracted = true;
    (&sample_1)->lobe = 1U;
    float3  _S214 = refractBSDF((&sample_1)->unit_direction, n_i_6, alpha_12, material_7, lobes_8);
    (&sample_1)->throughput = _S214;
    float _S215 = refractPDF(0.0f, dot_0((&sample_1)->unit_direction, ggx_n_1), n_i_dot_v_5, alpha_12, lobes_8, eta_i_8, eta_o_8);
    (&sample_1)->pdf = _S215;
    return sample_1;
}

__device__ SampleBSDF reflectSample(float3  in_dir_5, float3  ggx_n_2, float3  n_i_7, float n_i_dot_v_6, float alpha_13, BSDFMaterial material_8, BSDFLobes lobes_9, float eta_i_9, float eta_o_9, uint random_state_6)
{
    float3  _S216 = make_float3 (1.0f);
    SampleBSDF _S217 = SampleBSDF_x24init_0(_S216, _S216, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S217;
    float3  _S218 = reflect_0(in_dir_5, ggx_n_2);
    float3  _S219 = ((((_S218)) * make_float3(rnorm3df(((_S218)).x, ((_S218)).y, ((_S218)).z))));
    (&sample_2)->unit_direction = _S219;
    (&sample_2)->random_state = random_state_6;
    (&sample_2)->lobe = 2U;
    float3  _S220 = reflectBSDF((&sample_2)->unit_direction, n_i_7, alpha_13, material_8, lobes_9);
    (&sample_2)->throughput = _S220;
    float _S221 = reflectPDF(0.0f, 0.0f, n_i_dot_v_6, alpha_13, lobes_9, eta_i_9, eta_o_9);
    (&sample_2)->pdf = _S221;
    return sample_2;
}

__device__ SampleBSDF sampleBSDF(float3  in_dir_6, float3  n_8, BSDFMaterial material_9, float eta_i_10, float eta_o_10, uint random_init_0)
{
    uint random_state_7 = random_init_0;
    float3  _S222 = negate_0(in_dir_6);
    float _S223 = dot_0(n_8, _S222);
    float _S224 = sign_0(_S223);
    float3  n_i_8 = n_8 * make_float3 (_S224);
    float _S225 = (F32_abs((_S223)));
    float _S226 = material_9.roughness;
    float _S227 = _S226 * _S226;
    float3  _S228 = sampleHalfVector(_S222, n_i_8, _S227, &random_state_7);
    BSDFLobes _S229 = bsdfLobes(in_dir_6, _S222, n_i_8, _S228, material_9, eta_i_10, eta_o_10);
    Random _S230 = pcg(random_state_7);
    random_state_7 = _S230.state;
    bool _S231 = (_S230.value) < (_S229.p_diffuse);
    if(_S231)
    {
        SampleBSDF _S232 = diffuseSample(n_i_8, _S225, _S227, material_9, _S229, eta_i_10, eta_o_10, random_state_7);
        return _S232;
    }
    bool _S233 = (_S230.value) < (_S229.p_diffuse + _S229.p_refract);
    if(_S233)
    {
        SampleBSDF _S234 = refractSample(_S228, n_i_8, _S225, _S227, material_9, _S229, eta_i_10, eta_o_10, random_state_7);
        return _S234;
    }
    SampleBSDF _S235 = reflectSample(in_dir_6, _S228, n_i_8, _S225, _S227, material_9, _S229, eta_i_10, eta_o_10, random_state_7);
    return _S235;
}

__device__ float3  pointLightRadiance(float3  color_0, float intensity_0, float radius_0)
{
    return color_0 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_0 * radius_0);
}

__device__ float3  beerLambert(float distance_1, float3  absorption_0)
{
    float3  _S236 = max_0(absorption_0, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_1) * log_0(_S236));
}

__device__ bool neeDecision(BSDFMaterial material_10, float n_dot_v_0, float eta_i_11, float eta_o_11)
{
    float _S237 = fresnel((F32_abs((n_dot_v_0))), eta_i_11, eta_o_11);
    float3  _S238 = mix_0(make_float3 (_S237), material_10.albedo, material_10.metallic);
    float _S239 = rgb_to_greyscale(_S238);
    float _S240 = (F32_max(((1.0f - _S239) * (1.0f - material_10.metallic) * (1.0f - material_10.transmission)), (0.0f)));
    bool _S241 = _S240 > 0.03999999910593033f;
    bool _S242;
    if(_S241)
    {
        _S242 = true;
    }
    else
    {
        _S242 = (material_10.roughness) > 0.20000000298023224f;
    }
    return _S242;
}

__device__ float3  straightThrough(float3  dir_0, float3  n_9, BSDFMaterial material_11)
{
    float _S243 = material_11.transmission * (1.0f - material_11.metallic);
    float _S244 = material_11.roughness;
    float _S245 = smithG1(_S244 * _S244, (F32_abs((dot_0(n_9, dir_0)))));
    return make_float3 (_S243 * _S245) * material_11.albedo;
}

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_0, float3  end_0)
{
    float _S246 = sign_0(dot_0(light_n_0, start_0 - end_0));
    return light_n_0 * make_float3 (_S246 * light_offset_0);
}

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

__device__ float3  occluderTransmittance(float3  toward_0, float3  n_10, BSDFMaterial material_12, float coverage_0)
{
    float3  _S247;
    if((material_12.ior) == 1.0f)
    {
        float3  _S248 = straightThrough(toward_0, n_10, material_12);
        _S247 = _S248;
    }
    else
    {
        _S247 = make_float3 (0.0f);
    }
    return _S247 * make_float3 (coverage_0) + make_float3 (1.0f - coverage_0);
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S249 = hash(index_0);
    uint _S250 = hash(seed_0 ^ _S249);
    return _S250;
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float3  _S251 = a_4 / b_0;
    float3  _S252 = make_float3 (0.0f);
    bool3  _S253 = b_0 == _S252;
    float3  _S254 = _slang_select(_S253, _S252,_S251);
    return _S254;
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
    float _S255 = rgb_to_greyscale(weight_0);
    bool _S256 = _S255 > 0.0f;
    bool _S257;
    if(_S256)
    {
        _S257 = _S255 < 3.00000000549775576e+38f;
    }
    else
    {
        _S257 = false;
    }
    bool _S258 = !_S257;
    if(_S258)
    {
        return;
    }
    float _S259 = sel_0->w_sum + _S255;
    sel_0->w_sum = _S259;
    float3  _S260 = sel_0->color + weight_0;
    sel_0->color = _S260;
    Random _S261 = pcg(sel_0->random_state);
    sel_0->random_state = _S261.state;
    bool _S262 = (_S261.value * sel_0->w_sum) <= _S255;
    if(_S262)
    {
        sel_0->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_1, Reservoir r_0, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_0;
    float3  _S263 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S263;
    float _S264 = r_0.jac * shifted_0.jac;
    (&candidate_1)->jac = _S264;
    offer(sel_1, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_0.w));
    return;
}

__device__ Reservoir finalize(Selection sel_2, float c_0)
{
    Reservoir r_1 = sel_2.r;
    float _S265 = rgb_to_greyscale((&r_1)->f);
    float _S266 = sel_2.w_sum / _S265;
    bool _S267 = _S265 > 0.0f;
    float _S268 = _slang_select(_S267, _S266,0.0f);
    (&r_1)->w = _S268;
    (&r_1)->c = c_0;
    return r_1;
}

static __device__ uint insertBits_0(uint e_1, uint newbits_0, uint offset_0, uint count_0)
{
    uint _S269 = (1U << count_0) - 1U;
    return (e_1 & (~(_S269 << offset_0))) | ((newbits_0 & _S269) << offset_0);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_1, float3  f_2)
{
    Reservoir candidate_2 = r_2;
    uint _S270 = insertBits_0(r_2.path, end_1, 0U, 5U);
    uint _S271 = insertBits_0(_S270, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S271;
    (&candidate_2)->f = f_2;
    return candidate_2;
}

__device__ float facingSign(float transmission_0, float3  face_0, float3  direction_0)
{
    bool _S272 = transmission_0 > 0.0f;
    bool _S273;
    if(_S272)
    {
        _S273 = true;
    }
    else
    {
        _S273 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S274;
    if(_S273)
    {
        _S274 = 1.0f;
    }
    else
    {
        _S274 = -1.0f;
    }
    return _S274;
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
    bool _S275;
    if(open_0)
    {
        _S275 = prev_rough_0;
    }
    else
    {
        _S275 = false;
    }
    if(_S275)
    {
        _S275 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S275 = false;
    }
    return _S275;
}

__device__ bool withinInverseFootprint(float pdf_1, bool diffuse_0, float prev_cos_0, float distance_3, float threshold_1)
{
    bool _S276 = pdf_1 > 0.0f;
    bool _S277;
    if(_S276)
    {
        if(diffuse_0)
        {
            _S277 = true;
        }
        else
        {
            _S277 = (pdf_1 * prev_cos_0 / (distance_3 * distance_3) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S277 = false;
    }
    return _S277;
}

__device__ bool roughLobe(float pdf_2, bool diffuse_1, float roughness_0)
{
    bool _S278 = pdf_2 > 0.0f;
    bool _S279;
    if(_S278)
    {
        if(diffuse_1)
        {
            _S279 = true;
        }
        else
        {
            _S279 = roughness_0 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S279 = false;
    }
    return _S279;
}

__device__ float survivalProbability(float3  throughput_1, float density_0)
{
    float3  _S280 = throughput_1 / make_float3 (density_0);
    return clamp_1((F32_max((_S280.x), ((F32_max((_S280.y), (_S280.z)))))), 0.0f, 1.0f);
}

static __device__ float interpolate_0(float a_5, float b_1, float t_3)
{
    return a_5 + (b_1 - a_5) * t_3;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S281 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S281;
}

__device__ float2  temporalWeights(float c_1, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S282 = c_1 * p_c_0;
    float _S283 = c_t_0 * p_t_0;
    return make_float2 (_S282 / (_S282 + c_t_0 * g_previous_0), _S283 / (_S283 + c_1 * g_current_0));
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
    float _S284 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S285 = cos_a_0 > cos_b_0;
    float _S286 = _slang_select(_S285, 1.0f,_S284);
    return _S286;
}

__device__ float sinSubClamped(float sin_a_1, float cos_a_1, float sin_b_1, float cos_b_1)
{
    float _S287 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    bool _S288 = cos_a_1 > cos_b_1;
    float _S289 = _slang_select(_S288, 0.0f,_S287);
    return _S289;
}

__device__ float sine(float c_2)
{
    return (F32_sqrt(((F32_max((1.0f - c_2 * c_2), (0.0f))))));
}

__device__ float importance(LightNode node_0, float3  p_0, float3  normal_0)
{
    float3  _S290 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S291 = node_0.high - node_0.low;
    float3  _S292 = p_0 - _S290;
    float3  _S293 = ((((_S292)) * make_float3(rnorm3df(((_S292)).x, ((_S292)).y, ((_S292)).z))));
    float _S294 = dot_0(_S292, _S292);
    float _S295 = dot_0(_S291, _S291) / 4.0f;
    float _S296 = (F32_abs((dot_0(node_0.w, _S293))));
    float _S297 = sine(node_0.cos_theta_o);
    float _S298 = (F32_sqrt(((F32_max((1.0f - _S295 / _S294), (0.0f))))));
    bool _S299 = _S294 < _S295;
    float _S300 = _slang_select(_S299, -1.0f,_S298);
    float _S301 = sine(_S300);
    float _S302 = sine(_S296);
    float _S303 = cosSubClamped(_S302, _S296, _S297, node_0.cos_theta_o);
    float _S304 = sine(_S296);
    float _S305 = sinSubClamped(_S304, _S296, _S297, node_0.cos_theta_o);
    float _S306 = cosSubClamped(_S305, _S303, _S301, _S300);
    bool _S307 = _S306 <= 0.0f;
    if(_S307)
    {
        return 0.0f;
    }
    float _S308 = - dot_0(_S293, normal_0);
    float _S309 = node_0.phi * _S306 / (F32_max((_S294), (length_0(_S291) / 2.0f)));
    float _S310 = sine(_S308);
    float _S311 = cosSubClamped(_S310, _S308, _S301, _S300);
    bool _S312 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S313 = _slang_select(_S312, 1.0f,_S311);
    return (F32_max((_S309 * _S313), (0.0f)));
}

__device__ float solidAngle(float probability_0, float3  normal_1, float3  toward_1)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_1)), (3.0f))) / (F32_abs((dot_0(normal_1, toward_1))));
}

__device__ uint pickChild(LightNode first_0, LightNode second_0, float3  p_1, float3  normal_2, float * pick_0, float * probability_1)
{
    float _S314 = importance(first_0, p_1, normal_2);
    float _S315 = importance(second_0, p_1, normal_2);
    float2  _S316 = make_float2 (_S314, _S315);
    bool _S317 = _S314 == 0.0f;
    bool _S318;
    if(_S317)
    {
        _S318 = _S315 == 0.0f;
    }
    else
    {
        _S318 = false;
    }
    if(_S318)
    {
        return 2U;
    }
    float _S319 = _S314 + _S315;
    bool _S320 = _S315 > 0.0f;
    if(_S320)
    {
        _S318 = (*pick_0 * _S319) >= _S314;
    }
    else
    {
        _S318 = false;
    }
    uint _S321 = uint(_S318);
    float _S322 = (F32_min(((*pick_0 * _S319 - float(_S321) * _S314) / _slang_vector_get_element(_S316, _S321)), (0.99999994039535522f)));
    *pick_0 = _S322;
    float _S323 = *probability_1 * (_slang_vector_get_element(_S316, _S321) / _S319);
    *probability_1 = _S323;
    return _S321;
}

__device__ float childShare(LightNode first_1, LightNode second_1, float3  p_2, float3  normal_3, uint child_0)
{
    float _S324 = importance(first_1, p_2, normal_3);
    float _S325 = importance(second_1, p_2, normal_3);
    float2  _S326 = make_float2 (_S324, _S325);
    float _S327 = _slang_vector_get_element(_S326, child_0) / (_S324 + _S325);
    bool _S328 = _slang_vector_get_element(_S326, child_0) > 0.0f;
    float _S329 = _slang_select(_S328, _S327,0.0f);
    return _S329;
}

__device__ float powerHeuristic(float a_6, float b_2)
{
    float _S330 = 1.0f / (1.0f + b_2 / a_6 * (b_2 / a_6));
    bool _S331 = b_2 > 0.0f;
    float _S332 = _slang_select(_S331, _S330,1.0f);
    return _S332;
}

__device__ float sphereDensity(float3  center_0, float radius_1, float3  p_3)
{
    float3  _S333 = center_0 - p_3;
    float _S334 = radius_1 * radius_1 / dot_0(_S333, _S333);
    bool _S335 = _S334 >= 1.0f;
    if(_S335)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S334)))) / (6.28318548202514648f * _S334);
}

__device__ float3  sampleSphere(float3  center_1, float radius_2, float3  p_4, float u1_0, float u2_0)
{
    float3  _S336 = center_1 - p_4;
    float _S337 = radius_2 * radius_2 / dot_0(_S336, _S336);
    float _S338 = u1_0 * _S337 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S337), (0.0f)))))));
    float _S339 = 2.0f * u1_0;
    bool _S340 = _S337 >= 1.0f;
    float _S341 = _slang_select(_S340, _S339,_S338);
    float _S342 = (F32_sqrt(((F32_max((_S341 * (2.0f - _S341)), (0.0f))))));
    float _S343 = 6.28318548202514648f * u2_0;
    float3  _S344 = make_float3 (_S342 * (F32_cos((_S343))), 1.0f - _S341, _S342 * (F32_sin((_S343))));
    float3  _S345 = ((((_S336)) * make_float3(rnorm3df(((_S336)).x, ((_S336)).y, ((_S336)).z))));
    float3  _S346 = tangentToWorld(_S344, _S345);
    return _S346;
}

#undef Matrix
