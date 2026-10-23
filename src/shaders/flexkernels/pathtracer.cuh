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

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_6, float eta_i_1, float eta_o_1)
{
    float3  _S113 = negate_0(in_dir_1);
    float3  _S114 = negate_0(make_float3 (eta_i_1) * _S113 + make_float3 (eta_o_1) * out_dir_0);
    float3  _S115 = ((((_S114)) * make_float3(rnorm3df(((_S114)).x, ((_S114)).y, ((_S114)).z))));
    float _S116 = sign_0(dot_0(n_6, _S113));
    float _S117 = sign_0(dot_0(_S114, n_6 * make_float3 (_S116)));
    return _S115 * make_float3 (_S117);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S118 = negate_0(in_dir_2);
    float3  _S119 = _S118 + out_dir_1;
    float3  _S120 = ((((_S119)) * make_float3(rnorm3df(((_S119)).x, ((_S119)).y, ((_S119)).z))));
    return _S120;
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
    BSDFLobes _S121;
    (&_S121)->v_dot_h = v_dot_h_0;
    (&_S121)->n_dot_h = n_dot_h_1;
    (&_S121)->refracted = refracted_0;
    (&_S121)->F = F_0;
    (&_S121)->F_greyscale = F_greyscale_0;
    (&_S121)->reflect_weight = reflect_weight_0;
    (&_S121)->diffuse_weight = diffuse_weight_0;
    (&_S121)->refract_weight = refract_weight_0;
    (&_S121)->p_diffuse = p_diffuse_0;
    (&_S121)->p_reflect = p_reflect_0;
    (&_S121)->p_refract = p_refract_0;
    return _S121;
}

__device__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_4, float3  n_i_1, float3  ggx_n_0, BSDFMaterial material_1, float eta_i_2, float eta_o_2)
{
    float _S122 = dot_0(ggx_n_0, v_4);
    float _S123 = dot_0(n_i_1, ggx_n_0);
    float _S124 = eta_i_2 / eta_o_2;
    float3  _S125 = refract_0(in_dir_3, ggx_n_0, _S124);
    float3  _S126 = ((((_S125)) * make_float3(rnorm3df(((_S125)).x, ((_S125)).y, ((_S125)).z))));
    float _S127 = (F32_min(((F32_sqrt((material_1.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S128 = _S127 * _S127;
    float _S129 = (1.0f + _S127) / (1.0f - _S127);
    float _S130 = (F32_abs((_S122)));
    bool _S131 = eta_i_2 > eta_o_2;
    float _S132;
    if(_S131)
    {
        _S132 = _S129;
    }
    else
    {
        _S132 = 1.0f;
    }
    float _S133;
    if(_S131)
    {
        _S133 = 1.0f;
    }
    else
    {
        _S133 = _S129;
    }
    float _S134 = fresnel(_S130, _S132, _S133);
    bool _S135 = (eta_i_2 * eta_i_2 * (1.0f - _S122 * _S122)) >= (eta_o_2 * eta_o_2);
    float3  _S136;
    if(_S135)
    {
        _S136 = make_float3 (1.0f);
    }
    else
    {
        float3  _S137 = material_1.specular_tint * make_float3 (_S128);
        _S136 = _S137 + (make_float3 (1.0f) - _S137) * make_float3 (_S134 - _S128) / make_float3 (1.0f - _S128);
    }
    float3  F_1 = mix_0(_S136, material_1.albedo, material_1.metallic);
    float _S138 = rgb_to_greyscale(F_1);
    float _S139 = 1.0f - material_1.metallic;
    float3  _S140 = make_float3 (1.0f) - _S136;
    float3  _S141 = make_float3 ((1.0f - material_1.transmission) * _S139) * _S140;
    float3  _S142 = make_float3 (material_1.transmission * _S139) * _S140;
    float _S143 = (F32_max((_S138), (0.0f)));
    float _S144 = rgb_to_greyscale(_S141);
    float _S145 = (F32_max((_S144), (0.0f)));
    float _S146 = rgb_to_greyscale(_S142);
    float _S147 = sign_0(length_0(_S126));
    float _S148 = (F32_max((_S146 * _S147), (0.0f)));
    float _S149 = _S143 + _S145 + _S148;
    float _S150 = 1.0f / (F32_max((_S149), (0.0000152587890625f)));
    float _S151 = _S145 * _S150;
    float _S152 = _S143 * _S150;
    float _S153 = _S148 * _S150;
    return BSDFLobes_x24init_0(_S122, _S123, _S126, F_1, _S138, 1.0f, _S141, _S142, _S151, _S152, _S153);
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

__device__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, float3  g_n_0, BSDFMaterial material_5, float eta_i_6, float eta_o_6, uint random_state_2)
{
    float3  _S178 = negate_0(in_dir_4);
    float _S179 = dot_0(n_7, _S178);
    float _S180 = sign_0(_S179);
    float3  _S181 = n_7 * make_float3 (_S180);
    float _S182 = dot_0(_S181, out_dir_2);
    float _S183 = material_5.roughness;
    float _S184 = _S183 * _S183;
    bool _S185 = (dot_0(g_n_0, _S178) * dot_0(g_n_0, out_dir_2)) > 0.0f;
    uint _S186;
    if(_S185)
    {
        _S186 = 2U;
    }
    else
    {
        _S186 = 1U;
    }
    float3  _S187 = make_float3 (0.0f);
    BSDFLobes _S188 = BSDFLobes_x24init_0(0.0f, 0.0f, _S187, _S187, 0.0f, 0.0f, _S187, _S187, 0.0f, 0.0f, 0.0f);
    uint half_of_0 = 4294967295U;
    BSDFLobes lobe_terms_0 = _S188;
    float3  ggx_n_1 = _S187;
    float3  f_0 = _S187;
    uint i_10 = 0U;
    for(;;)
    {
        if(i_10 < _S186)
        {
        }
        else
        {
            break;
        }
        uint _S189;
        if(!_S185)
        {
            _S189 = 1U;
        }
        else
        {
            if(i_10 == 0U)
            {
                _S189 = 0U;
            }
            else
            {
                _S189 = 2U;
            }
        }
        bool _S190 = _S189 != half_of_0;
        float3  ggx_n_2;
        if(_S190)
        {
            bool _S191 = _S189 == 0U;
            if(_S191)
            {
                float3  _S192 = sampledHalf(in_dir_4, n_7, material_5, random_state_2);
                ggx_n_2 = _S192;
            }
            else
            {
                bool _S193 = _S189 == 1U;
                if(_S193)
                {
                    float3  _S194 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_6, eta_o_6);
                    ggx_n_2 = _S194;
                }
                else
                {
                    float3  _S195 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_2 = _S195;
                }
            }
            float3  _S196 = negate_0(in_dir_4);
            BSDFLobes _S197 = bsdfLobes(in_dir_4, _S196, _S181, ggx_n_2, material_5, eta_i_6, eta_o_6);
            lobe_terms_0 = _S197;
            half_of_0 = _S189;
        }
        else
        {
            ggx_n_2 = ggx_n_1;
        }
        float3  throughput_0;
        float pdf_0;
        switch(_S189)
        {
        case 0U:
            {
                float _S198 = diffusePDF(_S182, 0.0f, (F32_abs((_S179))), _S184, lobe_terms_0, eta_i_6, eta_o_6);
                float3  _S199 = diffuseBSDF(out_dir_2, _S181, _S184, material_5, lobe_terms_0);
                pdf_0 = _S198;
                throughput_0 = _S199;
                break;
            }
        case 1U:
            {
                float _S200 = refractPDF(_S182, dot_0(out_dir_2, ggx_n_2), (F32_abs((_S179))), _S184, lobe_terms_0, eta_i_6, eta_o_6);
                float3  _S201 = refractBSDF(out_dir_2, _S181, _S184, material_5, lobe_terms_0);
                pdf_0 = _S200;
                throughput_0 = _S201;
                break;
            }
        default:
            {
                float _S202 = reflectPDF(_S182, 0.0f, (F32_abs((_S179))), _S184, lobe_terms_0, eta_i_6, eta_o_6);
                float3  _S203 = reflectBSDF(out_dir_2, _S181, _S184, material_5, lobe_terms_0);
                pdf_0 = _S202;
                throughput_0 = _S203;
                break;
            }
        }
        float3  _S204;
        if(pdf_0 > 0.0f)
        {
            _S204 = throughput_0 * make_float3 (pdf_0);
        }
        else
        {
            _S204 = _S187;
        }
        if(i_10 == 0U)
        {
            f_0 = _S204;
        }
        else
        {
            f_0 = f_0 + _S204;
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
    SampleBSDF _S205;
    (&_S205)->unit_direction = unit_direction_0;
    (&_S205)->throughput = throughput_1;
    (&_S205)->random_state = random_state_3;
    (&_S205)->refracted = refracted_1;
    (&_S205)->lobe = lobe_0;
    (&_S205)->pdf = pdf_1;
    return _S205;
}

__device__ SampleBSDF diffuseSample(float3  n_i_5, float n_i_dot_v_4, float alpha_11, BSDFMaterial material_6, BSDFLobes lobes_7, float eta_i_7, float eta_o_7, uint random_state_4)
{
    float3  _S206 = make_float3 (1.0f);
    SampleBSDF _S207 = SampleBSDF_x24init_0(_S206, _S206, 0U, false, 0U, 0.0f);
    SampleBSDF sample_0 = _S207;
    Random _S208 = pcg(random_state_4);
    Random _S209 = pcg(_S208.state);
    (&sample_0)->random_state = _S209.state;
    float3  _S210 = sampleCosWeightedHemisphere(_S208.value, _S209.value);
    float3  _S211 = tangentToWorld(_S210, n_i_5);
    (&sample_0)->unit_direction = _S211;
    (&sample_0)->lobe = 0U;
    float3  _S212 = diffuseBSDF((&sample_0)->unit_direction, n_i_5, alpha_11, material_6, lobes_7);
    (&sample_0)->throughput = _S212;
    float _S213 = diffusePDF(_S210.y, 0.0f, n_i_dot_v_4, alpha_11, lobes_7, eta_i_7, eta_o_7);
    (&sample_0)->pdf = _S213;
    return sample_0;
}

__device__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_6, float n_i_dot_v_5, float alpha_12, BSDFMaterial material_7, BSDFLobes lobes_8, float eta_i_8, float eta_o_8, uint random_state_5)
{
    float3  _S214 = make_float3 (1.0f);
    SampleBSDF _S215 = SampleBSDF_x24init_0(_S214, _S214, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S215;
    (&sample_1)->unit_direction = lobes_8.refracted;
    (&sample_1)->random_state = random_state_5;
    (&sample_1)->refracted = true;
    (&sample_1)->lobe = 1U;
    float3  _S216 = refractBSDF((&sample_1)->unit_direction, n_i_6, alpha_12, material_7, lobes_8);
    (&sample_1)->throughput = _S216;
    float _S217 = refractPDF(0.0f, dot_0((&sample_1)->unit_direction, ggx_n_3), n_i_dot_v_5, alpha_12, lobes_8, eta_i_8, eta_o_8);
    (&sample_1)->pdf = _S217;
    return sample_1;
}

__device__ SampleBSDF reflectSample(float3  in_dir_5, float3  ggx_n_4, float3  n_i_7, float n_i_dot_v_6, float alpha_13, BSDFMaterial material_8, BSDFLobes lobes_9, float eta_i_9, float eta_o_9, uint random_state_6)
{
    float3  _S218 = make_float3 (1.0f);
    SampleBSDF _S219 = SampleBSDF_x24init_0(_S218, _S218, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S219;
    float3  _S220 = reflect_0(in_dir_5, ggx_n_4);
    float3  _S221 = ((((_S220)) * make_float3(rnorm3df(((_S220)).x, ((_S220)).y, ((_S220)).z))));
    (&sample_2)->unit_direction = _S221;
    (&sample_2)->random_state = random_state_6;
    (&sample_2)->lobe = 2U;
    float3  _S222 = reflectBSDF((&sample_2)->unit_direction, n_i_7, alpha_13, material_8, lobes_9);
    (&sample_2)->throughput = _S222;
    float _S223 = reflectPDF(0.0f, 0.0f, n_i_dot_v_6, alpha_13, lobes_9, eta_i_9, eta_o_9);
    (&sample_2)->pdf = _S223;
    return sample_2;
}

__device__ SampleBSDF sampleBSDF(float3  in_dir_6, float3  n_8, BSDFMaterial material_9, float eta_i_10, float eta_o_10, uint random_init_0, float2  screen_space_0)
{
    uint random_state_7 = random_init_0;
    float3  _S224 = negate_0(in_dir_6);
    float _S225 = dot_0(n_8, _S224);
    float _S226 = sign_0(_S225);
    float3  n_i_8 = n_8 * make_float3 (_S226);
    float _S227 = (F32_abs((_S225)));
    float _S228 = material_9.roughness;
    float _S229 = _S228 * _S228;
    float3  _S230 = sampleHalfVector(_S224, n_i_8, _S229, &random_state_7);
    BSDFLobes _S231 = bsdfLobes(in_dir_6, _S224, n_i_8, _S230, material_9, eta_i_10, eta_o_10);
    Random _S232 = pcg(random_state_7);
    random_state_7 = _S232.state;
    bool _S233 = (_S232.value) < (_S231.p_diffuse);
    if(_S233)
    {
        SampleBSDF _S234 = diffuseSample(n_i_8, _S227, _S229, material_9, _S231, eta_i_10, eta_o_10, random_state_7);
        return _S234;
    }
    bool _S235 = (_S232.value) < (_S231.p_diffuse + _S231.p_refract);
    if(_S235)
    {
        SampleBSDF _S236 = refractSample(_S230, n_i_8, _S227, _S229, material_9, _S231, eta_i_10, eta_o_10, random_state_7);
        return _S236;
    }
    SampleBSDF _S237 = reflectSample(in_dir_6, _S230, n_i_8, _S227, _S229, material_9, _S231, eta_i_10, eta_o_10, random_state_7);
    return _S237;
}

__device__ float3  pointLightRadiance(float3  color_0, float intensity_0, float radius_0)
{
    return color_0 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_0 * radius_0);
}

__device__ float3  beerLambert(float distance_1, float3  absorption_0)
{
    float3  _S238 = max_0(absorption_0, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_1) * log_0(_S238));
}

__device__ bool neeDecision(BSDFMaterial material_10, float n_dot_v_0, float eta_i_11, float eta_o_11)
{
    float _S239 = fresnel((F32_abs((n_dot_v_0))), eta_i_11, eta_o_11);
    float3  _S240 = mix_0(make_float3 (_S239), material_10.albedo, material_10.metallic);
    float _S241 = rgb_to_greyscale(_S240);
    float _S242 = (F32_max(((1.0f - _S241) * (1.0f - material_10.metallic) * (1.0f - material_10.transmission)), (0.0f)));
    bool _S243 = _S242 > 0.03999999910593033f;
    bool _S244;
    if(_S243)
    {
        _S244 = true;
    }
    else
    {
        _S244 = (material_10.roughness) > 0.20000000298023224f;
    }
    return _S244;
}

__device__ float3  misWeighted(float3  throughput_2, float lobe_pdf_0, float pdf_2, bool power_0)
{
    if(power_0)
    {
        float _S245 = lobe_pdf_0 / pdf_2;
        return throughput_2 * make_float3 (lobe_pdf_0) / make_float3 (pdf_2 * (1.0f + _S245 * _S245));
    }
    return throughput_2 * make_float3 (lobe_pdf_0) / make_float3 (lobe_pdf_0 + pdf_2);
}

static __device__ float3  neeLobes_0(float3  in_dir_7, float3  dir_0, float3  n_9, BSDFMaterial * material_11, float eta_i_12, float eta_o_12, bool refracted_2, float pdf_3, bool power_1, uint random_state_8, FixedArray<float3 , 3>  * each_0, uint * reached_0)
{
    float3  _S246 = negate_0(in_dir_7);
    float _S247 = dot_0(n_9, _S246);
    float _S248 = sign_0(_S247);
    float3  _S249 = n_9 * make_float3 (_S248);
    float _S250 = dot_0(_S249, dir_0);
    float _S251 = material_11->roughness * material_11->roughness;
    float3  _S252 = make_float3 (0.0f);
    *reached_0 = 0U;
    BSDFLobes _S253 = BSDFLobes_x24init_0(0.0f, 0.0f, _S252, _S252, 0.0f, 0.0f, _S252, _S252, 0.0f, 0.0f, 0.0f);
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
        (*each_0)[i_12] = _S252;
        uint i_13 = i_12 + 1U;
        i_12 = i_13;
    }
    uint half_of_1 = 4294967295U;
    BSDFLobes lobe_terms_1 = _S253;
    float3  ggx_n_5 = _S252;
    i_12 = 0U;
    float3  f_1 = _S252;
    for(;;)
    {
        if(i_12 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S254 = i_12 == 1U;
        bool _S255 = _S254 == refracted_2;
        float3  ggx_n_6;
        if(_S255)
        {
            bool _S256 = i_12 != half_of_1;
            uint half_of_2;
            BSDFLobes lobe_terms_2;
            if(_S256)
            {
                bool _S257 = i_12 == 0U;
                if(_S257)
                {
                    float3  _S258 = sampledHalf(in_dir_7, n_9, *material_11, random_state_8);
                    ggx_n_6 = _S258;
                }
                else
                {
                    if(_S254)
                    {
                        float3  _S259 = refractedHalf(in_dir_7, dir_0, n_9, eta_i_12, eta_o_12);
                        ggx_n_6 = _S259;
                    }
                    else
                    {
                        float3  _S260 = reflectedHalf(in_dir_7, dir_0);
                        ggx_n_6 = _S260;
                    }
                }
                float3  _S261 = negate_0(in_dir_7);
                BSDFLobes _S262 = bsdfLobes(in_dir_7, _S261, _S249, ggx_n_6, *material_11, eta_i_12, eta_o_12);
                lobe_terms_2 = _S262;
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
                    float _S263 = diffusePDF(_S250, 0.0f, (F32_abs((_S247))), _S251, lobe_terms_2, eta_i_12, eta_o_12);
                    float3  _S264 = diffuseBSDF(dir_0, _S249, _S251, *material_11, lobe_terms_2);
                    lobe_pdf_1 = _S263;
                    throughput_3 = _S264;
                    break;
                }
            case 1U:
                {
                    float _S265 = refractPDF(_S250, dot_0(dir_0, ggx_n_6), (F32_abs((_S247))), _S251, lobe_terms_2, eta_i_12, eta_o_12);
                    float3  _S266 = refractBSDF(dir_0, _S249, _S251, *material_11, lobe_terms_2);
                    lobe_pdf_1 = _S265;
                    throughput_3 = _S266;
                    break;
                }
            default:
                {
                    float _S267 = reflectPDF(_S250, 0.0f, (F32_abs((_S247))), _S251, lobe_terms_2, eta_i_12, eta_o_12);
                    float3  _S268 = reflectBSDF(dir_0, _S249, _S251, *material_11, lobe_terms_2);
                    lobe_pdf_1 = _S267;
                    throughput_3 = _S268;
                    break;
                }
            }
            bool _S269 = lobe_pdf_1 > 0.0f;
            float3  f_2;
            if(_S269)
            {
                float3  _S270 = misWeighted(throughput_3, lobe_pdf_1, pdf_3, power_1);
                (*each_0)[i_12] = _S270;
                uint _S271 = (*reached_0) | (1U << i_12);
                *reached_0 = _S271;
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
    BSDFMaterial _S272 = material_12;
    FixedArray<float3 , 3>  each_1;
    float3  _S273 = neeLobes_0(in_dir_8, dir_1, n_10, &_S272, eta_i_13, eta_o_13, refracted_3, pdf_4, power_2, random_state_9, &each_1, &reached_1);
    return _S273;
}

__device__ float3  straightThrough(float3  dir_2, float3  n_11, BSDFMaterial material_13)
{
    float _S274 = material_13.transmission * (1.0f - material_13.metallic);
    float _S275 = material_13.roughness;
    float _S276 = smithG1(_S275 * _S275, (F32_abs((dot_0(n_11, dir_2)))));
    return make_float3 (_S274 * _S276) * material_13.albedo;
}

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_0, float3  end_0)
{
    float _S277 = sign_0(dot_0(light_n_0, start_0 - end_0));
    return light_n_0 * make_float3 (_S277 * light_offset_0);
}

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

__device__ float3  occluderTransmittance(float3  toward_0, float3  n_12, BSDFMaterial material_14, float coverage_0)
{
    float3  _S278;
    if((material_14.ior) == 1.0f)
    {
        float3  _S279 = straightThrough(toward_0, n_12, material_14);
        _S278 = _S279;
    }
    else
    {
        _S278 = make_float3 (0.0f);
    }
    return _S278 * make_float3 (coverage_0) + make_float3 (1.0f - coverage_0);
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S280 = hash(index_0);
    uint _S281 = hash(seed_0 ^ _S280);
    return _S281;
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float3  _S282 = a_4 / b_0;
    float3  _S283 = make_float3 (0.0f);
    bool3  _S284 = b_0 == _S283;
    float3  _S285 = _slang_select(_S284, _S283,_S282);
    return _S285;
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
    float _S286 = rgb_to_greyscale(weight_0);
    bool _S287 = _S286 > 0.0f;
    bool _S288;
    if(_S287)
    {
        _S288 = _S286 < 3.00000000549775576e+38f;
    }
    else
    {
        _S288 = false;
    }
    bool _S289 = !_S288;
    if(_S289)
    {
        return;
    }
    float _S290 = sel_0->w_sum + _S286;
    sel_0->w_sum = _S290;
    float3  _S291 = sel_0->color + weight_0;
    sel_0->color = _S291;
    Random _S292 = pcg(sel_0->random_state);
    sel_0->random_state = _S292.state;
    bool _S293 = (_S292.value * sel_0->w_sum) <= _S286;
    if(_S293)
    {
        sel_0->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_1, Reservoir r_0, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_0;
    float3  _S294 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S294;
    float _S295 = r_0.jac * shifted_0.jac;
    (&candidate_1)->jac = _S295;
    offer(sel_1, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_0.w));
    return;
}

__device__ Reservoir finalize(Selection sel_2, float c_0)
{
    Reservoir r_1 = sel_2.r;
    float _S296 = rgb_to_greyscale((&r_1)->f);
    float _S297 = sel_2.w_sum / _S296;
    bool _S298 = _S296 > 0.0f;
    float _S299 = _slang_select(_S298, _S297,0.0f);
    (&r_1)->w = _S299;
    (&r_1)->c = c_0;
    return r_1;
}

static __device__ uint insertBits_0(uint e_1, uint newbits_0, uint offset_0, uint count_0)
{
    uint _S300 = (1U << count_0) - 1U;
    return (e_1 & (~(_S300 << offset_0))) | ((newbits_0 & _S300) << offset_0);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_1, float3  f_4)
{
    Reservoir candidate_2 = r_2;
    uint _S301 = insertBits_0(r_2.path, end_1, 0U, 5U);
    uint _S302 = insertBits_0(_S301, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S302;
    (&candidate_2)->f = f_4;
    return candidate_2;
}

__device__ float facingSign(float transmission_0, float3  face_0, float3  direction_0)
{
    bool _S303 = transmission_0 > 0.0f;
    bool _S304;
    if(_S303)
    {
        _S304 = true;
    }
    else
    {
        _S304 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S305;
    if(_S304)
    {
        _S305 = 1.0f;
    }
    else
    {
        _S305 = -1.0f;
    }
    return _S305;
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
    bool _S306;
    if(open_0)
    {
        _S306 = prev_rough_0;
    }
    else
    {
        _S306 = false;
    }
    if(_S306)
    {
        _S306 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S306 = false;
    }
    return _S306;
}

__device__ bool withinInverseFootprint(float pdf_5, bool diffuse_0, float prev_cos_0, float distance_3, float threshold_1)
{
    bool _S307 = pdf_5 > 0.0f;
    bool _S308;
    if(_S307)
    {
        if(diffuse_0)
        {
            _S308 = true;
        }
        else
        {
            _S308 = (pdf_5 * prev_cos_0 / (distance_3 * distance_3) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S308 = false;
    }
    return _S308;
}

__device__ bool roughLobe(float pdf_6, bool diffuse_1, float roughness_0)
{
    bool _S309 = pdf_6 > 0.0f;
    bool _S310;
    if(_S309)
    {
        if(diffuse_1)
        {
            _S310 = true;
        }
        else
        {
            _S310 = roughness_0 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S310 = false;
    }
    return _S310;
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
    float _S311 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S311;
}

__device__ float2  temporalWeights(float c_1, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S312 = c_1 * p_c_0;
    float _S313 = c_t_0 * p_t_0;
    return make_float2 (_S312 / (_S312 + c_t_0 * g_previous_0), _S313 / (_S313 + c_1 * g_current_0));
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
    float _S314 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S315 = cos_a_0 > cos_b_0;
    float _S316 = _slang_select(_S315, 1.0f,_S314);
    return _S316;
}

__device__ float sinSubClamped(float sin_a_1, float cos_a_1, float sin_b_1, float cos_b_1)
{
    float _S317 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    bool _S318 = cos_a_1 > cos_b_1;
    float _S319 = _slang_select(_S318, 0.0f,_S317);
    return _S319;
}

__device__ float sine(float c_2)
{
    return (F32_sqrt(((F32_max((1.0f - c_2 * c_2), (0.0f))))));
}

__device__ float importance(LightNode node_0, float3  p_0, float3  normal_0)
{
    float3  _S320 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S321 = node_0.high - node_0.low;
    float3  _S322 = p_0 - _S320;
    float3  _S323 = ((((_S322)) * make_float3(rnorm3df(((_S322)).x, ((_S322)).y, ((_S322)).z))));
    float _S324 = dot_0(_S322, _S322);
    float _S325 = dot_0(_S321, _S321) / 4.0f;
    float _S326 = (F32_abs((dot_0(node_0.w, _S323))));
    float _S327 = sine(node_0.cos_theta_o);
    float _S328 = (F32_sqrt(((F32_max((1.0f - _S325 / _S324), (0.0f))))));
    bool _S329 = _S324 < _S325;
    float _S330 = _slang_select(_S329, -1.0f,_S328);
    float _S331 = sine(_S330);
    float _S332 = sine(_S326);
    float _S333 = cosSubClamped(_S332, _S326, _S327, node_0.cos_theta_o);
    float _S334 = sine(_S326);
    float _S335 = sinSubClamped(_S334, _S326, _S327, node_0.cos_theta_o);
    float _S336 = cosSubClamped(_S335, _S333, _S331, _S330);
    bool _S337 = _S336 <= 0.0f;
    if(_S337)
    {
        return 0.0f;
    }
    float _S338 = - dot_0(_S323, normal_0);
    float _S339 = node_0.phi * _S336 / (F32_max((_S324), (length_0(_S321) / 2.0f)));
    float _S340 = sine(_S338);
    float _S341 = cosSubClamped(_S340, _S338, _S331, _S330);
    bool _S342 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S343 = _slang_select(_S342, 1.0f,_S341);
    return (F32_max((_S339 * _S343), (0.0f)));
}

__device__ float solidAngle(float probability_0, float3  normal_1, float3  toward_1)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_1)), (3.0f))) / (F32_abs((dot_0(normal_1, toward_1))));
}

__device__ uint pickChild(LightNode first_0, LightNode second_0, float3  p_1, float3  normal_2, float * pick_0, float * probability_1)
{
    float _S344 = importance(first_0, p_1, normal_2);
    float _S345 = importance(second_0, p_1, normal_2);
    float2  _S346 = make_float2 (_S344, _S345);
    bool _S347 = _S344 == 0.0f;
    bool _S348;
    if(_S347)
    {
        _S348 = _S345 == 0.0f;
    }
    else
    {
        _S348 = false;
    }
    if(_S348)
    {
        return 2U;
    }
    float _S349 = _S344 + _S345;
    bool _S350 = _S345 > 0.0f;
    if(_S350)
    {
        _S348 = (*pick_0 * _S349) >= _S344;
    }
    else
    {
        _S348 = false;
    }
    uint _S351 = uint(_S348);
    float _S352 = (F32_min(((*pick_0 * _S349 - float(_S351) * _S344) / _slang_vector_get_element(_S346, _S351)), (0.99999994039535522f)));
    *pick_0 = _S352;
    float _S353 = *probability_1 * (_slang_vector_get_element(_S346, _S351) / _S349);
    *probability_1 = _S353;
    return _S351;
}

__device__ float childShare(LightNode first_1, LightNode second_1, float3  p_2, float3  normal_3, uint child_0)
{
    float _S354 = importance(first_1, p_2, normal_3);
    float _S355 = importance(second_1, p_2, normal_3);
    float2  _S356 = make_float2 (_S354, _S355);
    float _S357 = _slang_vector_get_element(_S356, child_0) / (_S354 + _S355);
    bool _S358 = _slang_vector_get_element(_S356, child_0) > 0.0f;
    float _S359 = _slang_select(_S358, _S357,0.0f);
    return _S359;
}

__device__ float powerHeuristic(float a_6, float b_2)
{
    float _S360 = 1.0f / (1.0f + b_2 / a_6 * (b_2 / a_6));
    bool _S361 = b_2 > 0.0f;
    float _S362 = _slang_select(_S361, _S360,1.0f);
    return _S362;
}

__device__ float sphereDensity(float3  center_0, float radius_1, float3  p_3)
{
    float3  _S363 = center_0 - p_3;
    float _S364 = radius_1 * radius_1 / dot_0(_S363, _S363);
    bool _S365 = _S364 >= 1.0f;
    if(_S365)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S364)))) / (6.28318548202514648f * _S364);
}

__device__ float3  sampleSphere(float3  center_1, float radius_2, float3  p_4, float u1_0, float u2_0)
{
    float3  _S366 = center_1 - p_4;
    float _S367 = radius_2 * radius_2 / dot_0(_S366, _S366);
    float _S368 = u1_0 * _S367 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S367), (0.0f)))))));
    float _S369 = 2.0f * u1_0;
    bool _S370 = _S367 >= 1.0f;
    float _S371 = _slang_select(_S370, _S369,_S368);
    float _S372 = (F32_sqrt(((F32_max((_S371 * (2.0f - _S371)), (0.0f))))));
    float _S373 = 6.28318548202514648f * u2_0;
    float3  _S374 = make_float3 (_S372 * (F32_cos((_S373))), 1.0f - _S371, _S372 * (F32_sin((_S373))));
    float3  _S375 = ((((_S366)) * make_float3(rnorm3df(((_S366)).x, ((_S366)).y, ((_S366)).z))));
    float3  _S376 = tangentToWorld(_S374, _S375);
    return _S376;
}

#undef Matrix
