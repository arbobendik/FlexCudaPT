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

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
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
    BSDFLobes _S109;
    (&_S109)->v_dot_h = v_dot_h_0;
    (&_S109)->n_dot_h = n_dot_h_1;
    (&_S109)->refracted = refracted_0;
    (&_S109)->F = F_0;
    (&_S109)->F_greyscale = F_greyscale_0;
    (&_S109)->reflect_weight = reflect_weight_0;
    (&_S109)->diffuse_weight = diffuse_weight_0;
    (&_S109)->refract_weight = refract_weight_0;
    (&_S109)->p_diffuse = p_diffuse_0;
    (&_S109)->p_reflect = p_reflect_0;
    (&_S109)->p_refract = p_refract_0;
    return _S109;
}

__device__ BSDFLobes bsdfLobes(float3  in_dir_0, float3  v_4, float3  n_i_1, float3  ggx_n_0, BSDFMaterial material_0, float eta_i_1, float eta_o_1)
{
    float _S110 = dot_0(ggx_n_0, v_4);
    float _S111 = dot_0(n_i_1, ggx_n_0);
    float _S112 = eta_i_1 / eta_o_1;
    float3  _S113 = refract_0(in_dir_0, ggx_n_0, _S112);
    float3  _S114 = ((((_S113)) * make_float3(rnorm3df(((_S113)).x, ((_S113)).y, ((_S113)).z))));
    float _S115 = fresnel((F32_abs((_S110))), eta_i_1, eta_o_1);
    float3  F_1 = mix_0(make_float3 (_S115), material_0.albedo, material_0.metallic);
    float _S116 = rgb_to_greyscale(F_1);
    float _S117 = 1.0f - material_0.metallic;
    float _S118 = 1.0f - _S115;
    float _S119 = (1.0f - material_0.transmission) * _S117 * _S118;
    float _S120 = material_0.transmission * _S117 * _S118;
    float _S121 = (F32_max((_S116), (0.0f)));
    float _S122 = (F32_max((_S119), (0.0f)));
    float _S123 = sign_0(length_0(_S114));
    float _S124 = (F32_max((_S120 * _S123), (0.0f)));
    float _S125 = _S121 + _S122 + _S124;
    float _S126 = 1.0f / (F32_max((_S125), (0.0000152587890625f)));
    float _S127 = _S122 * _S126;
    float _S128 = _S121 * _S126;
    float _S129 = _S124 * _S126;
    return BSDFLobes_x24init_0(_S110, _S111, _S114, F_1, _S116, 1.0f, _S119, _S120, _S127, _S128, _S129);
}

__device__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, BSDFLobes lobes_0, float eta_i_2, float eta_o_2, uint lobe_0)
{
    bool _S130 = lobe_0 == 0U;
    if(_S130)
    {
        float _S131 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        bool _S132 = n_i_dot_v_0 > 0.0f;
        float _S133 = _slang_select(_S132, _S131,0.0f);
        return _S133;
    }
    float _S134 = smithG1(alpha_4, n_i_dot_v_0);
    float _S135 = _S134 * lobes_0.v_dot_h;
    float _S136 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    float _S137 = _S135 * _S136 / n_i_dot_v_0;
    bool _S138 = alpha_4 > 0.0f;
    bool _S139;
    if(_S138)
    {
        _S139 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S139 = false;
    }
    if(_S139)
    {
        _S139 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S139 = false;
    }
    if(_S139)
    {
        _S139 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S139 = false;
    }
    float _S140 = _slang_select(_S139, _S137,0.0f);
    bool _S141 = lobe_0 == 1U;
    if(_S141)
    {
        float _S142 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        float _S143 = lobes_0.p_refract * _S140 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S142 * _S142);
        bool _S144 = eta_i_2 != eta_o_2;
        if(_S144)
        {
            _S139 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S139 = false;
        }
        float _S145 = _slang_select(_S139, _S143,0.0f);
        return _S145;
    }
    float _S146 = lobes_0.p_reflect * _S140 / (4.0f * lobes_0.v_dot_h);
    bool _S147 = _S140 > 0.0f;
    float _S148 = _slang_select(_S147, _S146,0.0f);
    return _S148;
}

__device__ float3  lobeThroughput(float3  l_0, float3  n_i_2, float alpha_5, BSDFMaterial material_1, BSDFLobes lobes_1, uint lobe_1)
{
    bool _S149 = lobe_1 == 0U;
    if(_S149)
    {
        return make_float3 (lobes_1.diffuse_weight) * material_1.albedo / make_float3 (lobes_1.p_diffuse);
    }
    bool _S150 = lobe_1 == 1U;
    if(_S150)
    {
        float _S151 = - dot_0(n_i_2, l_0);
        float _S152 = smithG1(alpha_5, (F32_max((_S151), (0.0f))));
        return make_float3 (lobes_1.refract_weight * _S152) * material_1.albedo / make_float3 (lobes_1.p_refract);
    }
    float _S153 = dot_0(n_i_2, l_0);
    float _S154 = smithG1(alpha_5, (F32_max((_S153), (0.0f))));
    return make_float3 (lobes_1.reflect_weight * _S154) * lobes_1.F / make_float3 (lobes_1.p_reflect);
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
    SampleBSDF _S155;
    (&_S155)->unit_direction = unit_direction_0;
    (&_S155)->throughput = throughput_0;
    (&_S155)->random_state = random_state_1;
    (&_S155)->refracted = refracted_1;
    (&_S155)->lobe = lobe_2;
    (&_S155)->pdf = pdf_0;
    return _S155;
}

__device__ SampleBSDF connectBSDF(float3  in_dir_1, float3  out_dir_0, float3  n_5, BSDFMaterial material_2, float eta_i_3, float eta_o_3, uint lobe_3, uint random_init_0)
{
    uint random_state_2 = random_init_0;
    float3  _S156 = negate_0(in_dir_1);
    float _S157 = dot_0(n_5, _S156);
    float _S158 = sign_0(_S157);
    float3  _S159 = n_5 * make_float3 (_S158);
    float _S160 = material_2.roughness;
    float _S161 = _S160 * _S160;
    float3  _S162 = _S156 + out_dir_0;
    float3  _S163 = ((((_S162)) * make_float3(rnorm3df(((_S162)).x, ((_S162)).y, ((_S162)).z))));
    bool _S164 = lobe_3 == 0U;
    float3  ggx_n_1;
    if(_S164)
    {
        float3  _S165 = sampleHalfVector(_S156, _S159, _S161, &random_state_2);
        ggx_n_1 = _S165;
    }
    else
    {
        ggx_n_1 = _S163;
    }
    bool _S166 = lobe_3 == 1U;
    if(_S166)
    {
        float3  _S167 = negate_0(make_float3 (eta_i_3) * _S156 + make_float3 (eta_o_3) * out_dir_0);
        float3  _S168 = ((((_S167)) * make_float3(rnorm3df(((_S167)).x, ((_S167)).y, ((_S167)).z))));
        float _S169 = sign_0(dot_0(_S167, _S159));
        float3  _S170 = _S168 * make_float3 (_S169);
        ggx_n_1 = _S170;
    }
    else
    {
    }
    bool _S171 = lobe_3 == 2U;
    if(_S171)
    {
        float3  _S172 = ((((_S162)) * make_float3(rnorm3df(((_S162)).x, ((_S162)).y, ((_S162)).z))));
        ggx_n_1 = _S172;
    }
    else
    {
    }
    BSDFLobes _S173 = bsdfLobes(in_dir_1, _S156, _S159, ggx_n_1, material_2, eta_i_3, eta_o_3);
    float _S174 = lobeDensity(dot_0(_S159, out_dir_0), dot_0(out_dir_0, ggx_n_1), (F32_abs((_S157))), _S161, _S173, eta_i_3, eta_o_3, lobe_3);
    bool _S175 = !(_S174 > 0.0f);
    if(_S175)
    {
        float3  _S176 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S176, _S176, 0U, false, 0U, 0.0f);
    }
    float3  _S177 = lobeThroughput(out_dir_0, _S159, _S161, material_2, _S173, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S177, random_state_2, _S166, lobe_3, _S174);
}

__device__ float3  BSDF(float3  in_dir_2, float3  out_dir_1, float3  n_6, float3  g_n_0, BSDFMaterial material_3, float eta_i_4, float eta_o_4, uint random_state_3)
{
    float3  _S178 = negate_0(in_dir_2);
    bool _S179 = (dot_0(g_n_0, _S178) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S179)
    {
        SampleBSDF _S180 = connectBSDF(in_dir_2, out_dir_1, n_6, material_3, eta_i_4, eta_o_4, 0U, random_state_3);
        SampleBSDF _S181 = connectBSDF(in_dir_2, out_dir_1, n_6, material_3, eta_i_4, eta_o_4, 2U, random_state_3);
        return _S180.throughput * make_float3 (_S180.pdf) + _S181.throughput * make_float3 (_S181.pdf);
    }
    SampleBSDF _S182 = connectBSDF(in_dir_2, out_dir_1, n_6, material_3, eta_i_4, eta_o_4, 1U, random_state_3);
    return _S182.throughput * make_float3 (_S182.pdf);
}

__device__ SampleBSDF sampleBSDF(float3  in_dir_3, float3  n_7, BSDFMaterial material_4, float eta_i_5, float eta_o_5, uint random_init_1, float2  screen_space_0)
{
    uint random_state_4 = random_init_1;
    float3  _S183 = negate_0(in_dir_3);
    float _S184 = dot_0(n_7, _S183);
    float _S185 = sign_0(_S184);
    float3  n_i_3 = n_7 * make_float3 (_S185);
    float _S186 = (F32_abs((_S184)));
    float _S187 = material_4.roughness;
    float _S188 = _S187 * _S187;
    float3  _S189 = sampleHalfVector(_S183, n_i_3, _S188, &random_state_4);
    BSDFLobes _S190 = bsdfLobes(in_dir_3, _S183, n_i_3, _S189, material_4, eta_i_5, eta_o_5);
    float3  _S191 = make_float3 (1.0f);
    SampleBSDF _S192 = SampleBSDF_x24init_0(_S191, _S191, 0U, false, 0U, 0.0f);
    SampleBSDF sample_0 = _S192;
    Random _S193 = pcg(random_state_4);
    random_state_4 = _S193.state;
    bool _S194 = (_S193.value) < (_S190.p_diffuse);
    if(_S194)
    {
        Random _S195 = pcg(random_state_4);
        Random _S196 = pcg(_S195.state);
        (&sample_0)->random_state = _S196.state;
        float3  _S197 = sampleCosWeightedHemisphere(_S195.value, _S196.value);
        float3  _S198 = tangentToWorld(_S197, n_i_3);
        (&sample_0)->unit_direction = _S198;
        float3  _S199 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S188, material_4, _S190, 0U);
        (&sample_0)->throughput = _S199;
        float _S200 = lobeDensity(_S197.y, 0.0f, _S186, _S188, _S190, eta_i_5, eta_o_5, 0U);
        (&sample_0)->pdf = _S200;
        return sample_0;
    }
    bool _S201 = (_S193.value) < (_S190.p_diffuse + _S190.p_refract);
    if(_S201)
    {
        (&sample_0)->unit_direction = _S190.refracted;
        float _S202 = lobeDensity(0.0f, dot_0((&sample_0)->unit_direction, _S189), _S186, _S188, _S190, eta_i_5, eta_o_5, 1U);
        (&sample_0)->pdf = _S202;
        float3  _S203 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S188, material_4, _S190, 1U);
        (&sample_0)->throughput = _S203;
        (&sample_0)->random_state = random_state_4;
        (&sample_0)->refracted = true;
        (&sample_0)->lobe = 1U;
        return sample_0;
    }
    float3  _S204 = reflect_0(in_dir_3, _S189);
    float3  _S205 = ((((_S204)) * make_float3(rnorm3df(((_S204)).x, ((_S204)).y, ((_S204)).z))));
    (&sample_0)->unit_direction = _S205;
    float3  _S206 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S188, material_4, _S190, 2U);
    (&sample_0)->throughput = _S206;
    (&sample_0)->random_state = random_state_4;
    (&sample_0)->lobe = 2U;
    float _S207 = lobeDensity(0.0f, 0.0f, _S186, _S188, _S190, eta_i_5, eta_o_5, 2U);
    (&sample_0)->pdf = _S207;
    return sample_0;
}

__device__ float3  pointLightRadiance(float3  color_0, float intensity_0, float radius_0)
{
    return color_0 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_0 * radius_0);
}

__device__ float3  beerLambert(float distance_1, float3  absorption_0)
{
    float3  _S208 = max_0(absorption_0, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_1) * log_0(_S208));
}

__device__ bool neeDecision(BSDFMaterial material_5, float n_dot_v_0, float eta_i_6, float eta_o_6)
{
    float _S209 = fresnel((F32_abs((n_dot_v_0))), eta_i_6, eta_o_6);
    float3  _S210 = mix_0(make_float3 (_S209), material_5.albedo, material_5.metallic);
    float _S211 = rgb_to_greyscale(_S210);
    float _S212 = (F32_max(((1.0f - _S211) * (1.0f - material_5.metallic) * (1.0f - material_5.transmission)), (0.0f)));
    bool _S213 = _S212 > 0.03999999910593033f;
    bool _S214;
    if(_S213)
    {
        _S214 = true;
    }
    else
    {
        _S214 = (material_5.roughness) > 0.20000000298023224f;
    }
    return _S214;
}

__device__ float3  neeBSDF(float3  in_dir_4, float3  dir_0, float3  n_8, BSDFMaterial material_6, float eta_i_7, float eta_o_7, bool refracted_2, float pdf_1, bool power_0, uint random_state_5)
{
    float3  _S215 = make_float3 (0.0f);
    uint lobe_4 = 0U;
    float3  f_0 = _S215;
    for(;;)
    {
        if(lobe_4 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S216 = (lobe_4 == 1U) == refracted_2;
        float3  f_1;
        if(_S216)
        {
            SampleBSDF _S217 = connectBSDF(in_dir_4, dir_0, n_8, material_6, eta_i_7, eta_o_7, lobe_4, random_state_5);
            bool _S218 = (_S217.pdf) > 0.0f;
            if(_S218)
            {
                if(power_0)
                {
                    float _S219 = _S217.pdf / pdf_1;
                    float3  f_2 = f_0 + _S217.throughput * make_float3 (_S217.pdf) / make_float3 (pdf_1 * (1.0f + _S219 * _S219));
                    f_1 = f_2;
                }
                else
                {
                    float3  f_3 = f_0 + _S217.throughput * make_float3 (_S217.pdf) / make_float3 (_S217.pdf + pdf_1);
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
    float _S220 = material_7.transmission * (1.0f - material_7.metallic);
    float _S221 = material_7.roughness;
    float _S222 = smithG1(_S221 * _S221, (F32_abs((dot_0(n_9, dir_1)))));
    return make_float3 (_S220 * _S222) * material_7.albedo;
}

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_0, float3  end_0)
{
    float _S223 = sign_0(dot_0(light_n_0, start_0 - end_0));
    return light_n_0 * make_float3 (_S223 * light_offset_0);
}

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

__device__ float3  occluderTransmittance(float3  toward_0, float3  n_10, BSDFMaterial material_8, float coverage_0)
{
    float3  _S224;
    if((material_8.ior) == 1.0f)
    {
        float3  _S225 = straightThrough(toward_0, n_10, material_8);
        _S224 = _S225;
    }
    else
    {
        _S224 = make_float3 (0.0f);
    }
    return _S224 * make_float3 (coverage_0) + make_float3 (1.0f - coverage_0);
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S226 = hash(index_0);
    uint _S227 = hash(seed_0 ^ _S226);
    return _S227;
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float3  _S228 = a_4 / b_0;
    float3  _S229 = make_float3 (0.0f);
    bool3  _S230 = b_0 == _S229;
    float3  _S231 = _slang_select(_S230, _S229,_S228);
    return _S231;
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
    float _S232 = rgb_to_greyscale(weight_0);
    bool _S233 = _S232 > 0.0f;
    bool _S234;
    if(_S233)
    {
        _S234 = _S232 < 3.00000000549775576e+38f;
    }
    else
    {
        _S234 = false;
    }
    bool _S235 = !_S234;
    if(_S235)
    {
        return;
    }
    float _S236 = sel_0->w_sum + _S232;
    sel_0->w_sum = _S236;
    float3  _S237 = sel_0->color + weight_0;
    sel_0->color = _S237;
    Random _S238 = pcg(sel_0->random_state);
    sel_0->random_state = _S238.state;
    bool _S239 = (_S238.value * sel_0->w_sum) <= _S232;
    if(_S239)
    {
        sel_0->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_1, Reservoir r_0, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_0;
    float3  _S240 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S240;
    float _S241 = r_0.jac * shifted_0.jac;
    (&candidate_1)->jac = _S241;
    offer(sel_1, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_0.w));
    return;
}

__device__ Reservoir finalize(Selection sel_2, float c_0)
{
    Reservoir r_1 = sel_2.r;
    float _S242 = rgb_to_greyscale((&r_1)->f);
    float _S243 = sel_2.w_sum / _S242;
    bool _S244 = _S242 > 0.0f;
    float _S245 = _slang_select(_S244, _S243,0.0f);
    (&r_1)->w = _S245;
    (&r_1)->c = c_0;
    return r_1;
}

static __device__ uint insertBits_0(uint e_1, uint newbits_0, uint offset_0, uint count_0)
{
    uint _S246 = (1U << count_0) - 1U;
    return (e_1 & (~(_S246 << offset_0))) | ((newbits_0 & _S246) << offset_0);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_1, float3  f_4)
{
    Reservoir candidate_2 = r_2;
    uint _S247 = insertBits_0(r_2.path, end_1, 0U, 5U);
    uint _S248 = insertBits_0(_S247, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S248;
    (&candidate_2)->f = f_4;
    return candidate_2;
}

__device__ float facingSign(float transmission_0, float3  face_0, float3  direction_0)
{
    bool _S249 = transmission_0 > 0.0f;
    bool _S250;
    if(_S249)
    {
        _S250 = true;
    }
    else
    {
        _S250 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S251;
    if(_S250)
    {
        _S251 = 1.0f;
    }
    else
    {
        _S251 = -1.0f;
    }
    return _S251;
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
    bool _S252;
    if(open_0)
    {
        _S252 = prev_rough_0;
    }
    else
    {
        _S252 = false;
    }
    if(_S252)
    {
        _S252 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S252 = false;
    }
    return _S252;
}

__device__ bool withinInverseFootprint(float pdf_2, bool diffuse_0, float prev_cos_0, float distance_3, float threshold_1)
{
    bool _S253 = pdf_2 > 0.0f;
    bool _S254;
    if(_S253)
    {
        if(diffuse_0)
        {
            _S254 = true;
        }
        else
        {
            _S254 = (pdf_2 * prev_cos_0 / (distance_3 * distance_3) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S254 = false;
    }
    return _S254;
}

__device__ bool roughLobe(float pdf_3, bool diffuse_1, float roughness_0)
{
    bool _S255 = pdf_3 > 0.0f;
    bool _S256;
    if(_S255)
    {
        if(diffuse_1)
        {
            _S256 = true;
        }
        else
        {
            _S256 = roughness_0 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S256 = false;
    }
    return _S256;
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
    float _S257 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S257;
}

__device__ float2  temporalWeights(float c_1, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S258 = c_1 * p_c_0;
    float _S259 = c_t_0 * p_t_0;
    return make_float2 (_S258 / (_S258 + c_t_0 * g_previous_0), _S259 / (_S259 + c_1 * g_current_0));
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
    float _S260 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S261 = cos_a_0 > cos_b_0;
    float _S262 = _slang_select(_S261, 1.0f,_S260);
    return _S262;
}

__device__ float sinSubClamped(float sin_a_1, float cos_a_1, float sin_b_1, float cos_b_1)
{
    float _S263 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    bool _S264 = cos_a_1 > cos_b_1;
    float _S265 = _slang_select(_S264, 0.0f,_S263);
    return _S265;
}

__device__ float sine(float c_2)
{
    return (F32_sqrt(((F32_max((1.0f - c_2 * c_2), (0.0f))))));
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
    float _S281 = sinSubClamped(_S280, _S272, _S273, node_0.cos_theta_o);
    float _S282 = cosSubClamped(_S281, _S279, _S277, _S276);
    bool _S283 = _S282 <= 0.0f;
    if(_S283)
    {
        return 0.0f;
    }
    float _S284 = - dot_0(_S269, normal_0);
    float _S285 = node_0.phi * _S282 / (F32_max((_S270), (length_0(_S267) / 2.0f)));
    float _S286 = sine(_S284);
    float _S287 = cosSubClamped(_S286, _S284, _S277, _S276);
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

__device__ float powerHeuristic(float a_6, float b_2)
{
    float _S306 = 1.0f / (1.0f + b_2 / a_6 * (b_2 / a_6));
    bool _S307 = b_2 > 0.0f;
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
