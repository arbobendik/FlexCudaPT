#pragma once
#define Matrix SlangMatrix
#include "slang-cuda-prelude.h"

static __device__ float3  exp_0(float3  x_0)
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
        *_slang_vector_get_element_ptr(&result_0, i_0) = (F32_exp((_slang_vector_get_element(x_0, i_0))));
        i_0 = i_0 + int(1);
    }
    return result_0;
}

static __device__ float3  log_0(float3  x_1)
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
        *_slang_vector_get_element_ptr(&result_1, i_1) = (F32_log((_slang_vector_get_element(x_1, i_1))));
        i_1 = i_1 + int(1);
    }
    return result_1;
}

static __device__ float3  max_0(float3  x_2, float3  y_0)
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
        *_slang_vector_get_element_ptr(&result_2, i_2) = (F32_max((_slang_vector_get_element(x_2, i_2)), (_slang_vector_get_element(y_0, i_2))));
        i_2 = i_2 + int(1);
    }
    return result_2;
}

static __device__ float dot_0(float3  x_3, float3  y_1)
{
    return x_3.x * y_1.x + x_3.y * y_1.y + x_3.z * y_1.z;
}

static __device__ float3  reflect_0(float3  i_3, float3  n_0)
{
    return i_3 - make_float3 (2.0f * dot_0(n_0, i_3)) * n_0;
}

static __device__ float length_0(float3  x_4)
{
    return (F32_sqrt((dot_0(x_4, x_4))));
}

static __device__ float3  refract_0(float3  i_4, float3  n_1, float eta_0)
{
    float _S1 = dot_0(n_1, i_4);
    float _S2 = 1.0f - eta_0 * eta_0 * (1.0f - _S1 * _S1);
    if(_S2 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_4 - make_float3 (eta_0 * _S1 + (F32_sqrt((_S2)))) * n_1;
}

static __device__ float3  mul_0(float3  left_0, Matrix<float, 3, 3>  right_0)
{
    float3  result_3;
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
        int i_5 = int(0);
        float sum_0 = 0.0f;
        for(;;)
        {
            if(i_5 < int(3))
            {
            }
            else
            {
                break;
            }
            float sum_1 = sum_0 + _slang_vector_get_element(left_0, i_5) * _slang_vector_get_element(right_0.rows[i_5], j_0);
            i_5 = i_5 + int(1);
            sum_0 = sum_1;
        }
        *_slang_vector_get_element_ptr(&result_3, j_0) = sum_0;
        j_0 = j_0 + int(1);
    }
    return result_3;
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

static __device__ float clamp_0(float x_5, float minBound_0, float maxBound_0)
{
    return (F32_min(((F32_max((x_5), (minBound_0)))), (maxBound_0)));
}

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

__device__ uint hash(uint x_6)
{
    uint _S9 = x_6 * 747796405U + 2891336453U;
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
    float _S17 = (F32_sqrt((-2.0f * clamp_0((F32_log((_S15.value))), -8.388607e+06f, 0.0f))));
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

static __device__ float unshared_0(float x_7)
{
    return x_7;
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

static __device__ float3  negate_0(float3  x_8)
{
    return - x_8;
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

__device__ float3  sampleHalfVector(float3  v_3, float3  n_i_0, float alpha_4, uint * random_state_0)
{
    Random _S88 = pcg(*random_state_0);
    Random _S89 = pcg(_S88.state);
    *random_state_0 = _S89.state;
    float3  _S90 = worldToTangent(v_3, n_i_0);
    float3  _S91 = sampleGGXVNDF(float3 {_S90.x, _S90.z, _S90.y}, alpha_4, _S88.value, _S89.value);
    float3  _S92 = float3 {_S91.x, _S91.z, _S91.y};
    float3  _S93 = tangentToWorld(_S92, n_i_0);
    return _S93;
}

static __device__ float sign_0(float e_0)
{
    float _S94;
    if(e_0 > 0.0f)
    {
        _S94 = 1.0f;
    }
    else
    {
        if(e_0 < 0.0f)
        {
            _S94 = -1.0f;
        }
        else
        {
            _S94 = 0.0f;
        }
    }
    return _S94;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_5, BSDFMaterial material_0, uint random_state_1)
{
    uint state_6 = random_state_1;
    float3  _S95 = negate_0(in_dir_0);
    float _S96 = sign_0(dot_0(n_5, _S95));
    float _S97 = material_0.roughness;
    float3  _S98 = sampleHalfVector(_S95, n_5 * make_float3 (_S96), _S97 * _S97, &state_6);
    return _S98;
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
    BSDFLobes _S99;
    (&_S99)->v_dot_h = v_dot_h_0;
    (&_S99)->n_dot_h = n_dot_h_1;
    (&_S99)->refracted = refracted_0;
    (&_S99)->F = F_0;
    (&_S99)->F_greyscale = F_greyscale_0;
    (&_S99)->reflect_weight = reflect_weight_0;
    (&_S99)->diffuse_weight = diffuse_weight_0;
    (&_S99)->refract_weight = refract_weight_0;
    (&_S99)->p_diffuse = p_diffuse_0;
    (&_S99)->p_reflect = p_reflect_0;
    (&_S99)->p_refract = p_refract_0;
    return _S99;
}

__device__ BSDFLobes bsdfLobes(float3  in_dir_1, float3  v_4, float3  n_i_1, float3  ggx_n_0, BSDFMaterial material_1, float eta_i_1, float eta_o_1)
{
    float _S100 = dot_0(ggx_n_0, v_4);
    float _S101 = dot_0(n_i_1, ggx_n_0);
    float _S102 = eta_i_1 / eta_o_1;
    float3  _S103 = refract_0(in_dir_1, ggx_n_0, _S102);
    float3  _S104 = ((((_S103)) * make_float3(rnorm3df(((_S103)).x, ((_S103)).y, ((_S103)).z))));
    float _S105 = fresnel((F32_abs((_S100))), eta_i_1, eta_o_1);
    float3  F_1 = mix_0(make_float3 (_S105), material_1.albedo, material_1.metallic);
    float _S106 = rgb_to_greyscale(F_1);
    float _S107 = (1.0f - material_1.transmission) * (1.0f - material_1.metallic);
    float _S108 = (F32_max((_S106), (0.0f)));
    float _S109 = 1.0f - _S106;
    float _S110 = (F32_max((_S107 * _S109), (0.0f)));
    float _S111 = material_1.transmission * _S109;
    float _S112 = sign_0(length_0(_S104));
    float _S113 = (F32_max((_S111 * _S112), (0.0f)));
    float _S114 = _S108 + _S110 + _S113;
    float _S115 = 1.0f / (F32_max((_S114), (0.0000152587890625f)));
    float _S116 = _S110 * _S115;
    float _S117 = _S108 * _S115;
    float _S118 = _S113 * _S115;
    return BSDFLobes_x24init_0(_S100, _S101, _S104, F_1, _S106, 1.0f, _S107, material_1.transmission, _S116, _S117, _S118);
}

__device__ float3  refractedHalf(float3  in_dir_2, float3  out_dir_0, float3  n_6, float eta_i_2, float eta_o_2)
{
    float3  _S119 = negate_0(in_dir_2);
    float3  _S120 = negate_0(make_float3 (eta_i_2) * _S119 + make_float3 (eta_o_2) * out_dir_0);
    float3  _S121 = ((((_S120)) * make_float3(rnorm3df(((_S120)).x, ((_S120)).y, ((_S120)).z))));
    float _S122 = sign_0(dot_0(n_6, _S119));
    float _S123 = sign_0(dot_0(_S120, n_6 * make_float3 (_S122)));
    return _S121 * make_float3 (_S123);
}

__device__ float3  reflectedHalf(float3  in_dir_3, float3  out_dir_1)
{
    float3  _S124 = negate_0(in_dir_3);
    float3  _S125 = _S124 + out_dir_1;
    float3  _S126 = ((((_S125)) * make_float3(rnorm3df(((_S125)).x, ((_S125)).y, ((_S125)).z))));
    return _S126;
}

__device__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_5, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S127 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    bool _S128 = n_i_dot_v_0 > 0.0f;
    float _S129 = _slang_select(_S128, _S127,0.0f);
    return _S129;
}

__device__ float3  diffuseBSDF(float3  l_0, float3  n_i_2, float alpha_6, BSDFMaterial material_2, BSDFLobes lobes_1)
{
    return make_float3 (lobes_1.diffuse_weight) * material_2.albedo / make_float3 (lobes_1.p_diffuse);
}

__device__ float vndfPDF(float n_i_dot_v_1, float alpha_7, BSDFLobes lobes_2)
{
    float _S130 = smithG1(alpha_7, n_i_dot_v_1);
    float _S131 = _S130 * lobes_2.v_dot_h;
    float _S132 = trowbridgeReitz(alpha_7, lobes_2.n_dot_h);
    float _S133 = _S131 * _S132 / n_i_dot_v_1;
    bool _S134 = alpha_7 > 0.0f;
    bool _S135;
    if(_S134)
    {
        _S135 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S135 = false;
    }
    if(_S135)
    {
        _S135 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S135 = false;
    }
    if(_S135)
    {
        _S135 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S135 = false;
    }
    float _S136 = _slang_select(_S135, _S133,0.0f);
    return _S136;
}

__device__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_8, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S137 = vndfPDF(n_i_dot_v_2, alpha_8, lobes_3);
    float _S138 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S139 = lobes_3.p_refract * _S137 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S138 * _S138);
    bool _S140 = eta_i_4 != eta_o_4;
    bool _S141;
    if(_S140)
    {
        _S141 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S141 = false;
    }
    float _S142 = _slang_select(_S141, _S139,0.0f);
    return _S142;
}

__device__ float3  refractBSDF(float3  l_1, float3  n_i_3, float alpha_9, BSDFMaterial material_3, BSDFLobes lobes_4)
{
    float _S143 = - dot_0(n_i_3, l_1);
    float _S144 = G1(alpha_9, (F32_max((_S143), (0.0f))));
    return make_float3 (lobes_4.refract_weight * _S144 * (1.0f - lobes_4.F_greyscale)) * material_3.albedo / make_float3 (lobes_4.p_refract);
}

__device__ float reflectPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_10, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S145 = vndfPDF(n_i_dot_v_3, alpha_10, lobes_5);
    float _S146 = lobes_5.p_reflect * _S145 / (4.0f * lobes_5.v_dot_h);
    bool _S147 = _S145 > 0.0f;
    float _S148 = _slang_select(_S147, _S146,0.0f);
    return _S148;
}

__device__ float3  reflectBSDF(float3  l_2, float3  n_i_4, float alpha_11, BSDFMaterial material_4, BSDFLobes lobes_6)
{
    float _S149 = dot_0(n_i_4, l_2);
    float _S150 = G1(alpha_11, (F32_max((_S149), (0.0f))));
    return make_float3 (lobes_6.reflect_weight * _S150) * lobes_6.F / make_float3 (lobes_6.p_reflect);
}

__device__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_5, float eta_i_6, float eta_o_6, bool refracted_1, uint random_state_2, FixedArray<float3 , 3>  * throughputs_0, FixedArray<float, 3>  * pdfs_0)
{
    float3  _S151 = negate_0(in_dir_4);
    float _S152 = dot_0(n_7, _S151);
    float _S153 = sign_0(_S152);
    float3  _S154 = n_7 * make_float3 (_S153);
    float _S155 = dot_0(_S154, out_dir_2);
    float _S156 = material_5.roughness;
    float _S157 = _S156 * _S156;
    uint i_6 = 0U;
    for(;;)
    {
        if(i_6 < 3U)
        {
        }
        else
        {
            break;
        }
        float3  _S158 = make_float3 (0.0f);
        (*throughputs_0)[i_6] = _S158;
        (*pdfs_0)[i_6] = 0.0f;
        uint i_7 = i_6 + 1U;
        i_6 = i_7;
    }
    float3  _S159 = make_float3 (0.0f);
    BSDFLobes _S160 = BSDFLobes_x24init_0(0.0f, 0.0f, _S159, _S159, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f);
    bool _S161 = !refracted_1;
    BSDFLobes sampled_terms_0;
    if(_S161)
    {
        float3  sampled_n_0 = sampledHalf(in_dir_4, n_7, material_5, random_state_2);
        float3  _S162 = negate_0(in_dir_4);
        BSDFLobes _S163 = bsdfLobes(in_dir_4, _S162, _S154, sampled_n_0, material_5, eta_i_6, eta_o_6);
        sampled_terms_0 = _S163;
    }
    else
    {
        sampled_terms_0 = _S160;
    }
    float3  f_0;
    if(refracted_1)
    {
        float3  _S164 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_6, eta_o_6);
        f_0 = _S164;
    }
    else
    {
        float3  _S165 = reflectedHalf(in_dir_4, out_dir_2);
        f_0 = _S165;
    }
    float3  _S166 = negate_0(in_dir_4);
    BSDFLobes _S167 = bsdfLobes(in_dir_4, _S166, _S154, f_0, material_5, eta_i_6, eta_o_6);
    i_6 = 0U;
    for(;;)
    {
        if(i_6 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S168 = (i_6 == 1U) != refracted_1;
        if(_S168)
        {
            uint i_8 = i_6 + 1U;
            i_6 = i_8;
            continue;
        }
        switch(i_6)
        {
        case 0U:
            {
                float _S169 = diffusePDF(_S155, 0.0f, (F32_abs((_S152))), _S157, sampled_terms_0, eta_i_6, eta_o_6);
                (*pdfs_0)[int(0)] = _S169;
                float3  _S170 = diffuseBSDF(out_dir_2, _S154, _S157, material_5, sampled_terms_0);
                (*throughputs_0)[int(0)] = _S170;
                break;
            }
        case 1U:
            {
                float _S171 = refractPDF(_S155, dot_0(out_dir_2, f_0), (F32_abs((_S152))), _S157, _S167, eta_i_6, eta_o_6);
                (*pdfs_0)[int(1)] = _S171;
                float3  _S172 = refractBSDF(out_dir_2, _S154, _S157, material_5, _S167);
                (*throughputs_0)[int(1)] = _S172;
                break;
            }
        default:
            {
                float _S173 = reflectPDF(_S155, 0.0f, (F32_abs((_S152))), _S157, _S167, eta_i_6, eta_o_6);
                (*pdfs_0)[int(2)] = _S173;
                float3  _S174 = reflectBSDF(out_dir_2, _S154, _S157, material_5, _S167);
                (*throughputs_0)[int(2)] = _S174;
                break;
            }
        }
        uint i_8 = i_6 + 1U;
        i_6 = i_8;
    }
    i_6 = 0U;
    f_0 = _S159;
    for(;;)
    {
        if(i_6 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S175 = ((*pdfs_0)[i_6]) > 0.0f;
        if(_S175)
        {
            float3  f_1 = f_0 + (*throughputs_0)[i_6] * make_float3 ((*pdfs_0)[i_6]);
            f_0 = f_1;
        }
        uint i_9 = i_6 + 1U;
        i_6 = i_9;
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
    SampleBSDF _S176;
    (&_S176)->unit_direction = unit_direction_0;
    (&_S176)->throughput = throughput_0;
    (&_S176)->random_state = random_state_3;
    (&_S176)->refracted = refracted_2;
    (&_S176)->lobe = lobe_0;
    (&_S176)->pdf = pdf_0;
    return _S176;
}

__device__ SampleBSDF diffuseSample(float3  n_i_5, float n_i_dot_v_4, float alpha_12, BSDFMaterial material_6, BSDFLobes lobes_7, float eta_i_7, float eta_o_7, uint random_state_4)
{
    float3  _S177 = make_float3 (1.0f);
    SampleBSDF _S178 = SampleBSDF_x24init_0(_S177, _S177, 0U, false, 0U, 0.0f);
    SampleBSDF sample_0 = _S178;
    Random _S179 = pcg(random_state_4);
    Random _S180 = pcg(_S179.state);
    (&sample_0)->random_state = _S180.state;
    float3  _S181 = sampleCosWeightedHemisphere(_S179.value, _S180.value);
    float3  _S182 = tangentToWorld(_S181, n_i_5);
    (&sample_0)->unit_direction = _S182;
    (&sample_0)->lobe = 0U;
    float3  _S183 = diffuseBSDF((&sample_0)->unit_direction, n_i_5, alpha_12, material_6, lobes_7);
    (&sample_0)->throughput = _S183;
    float _S184 = diffusePDF(_S181.y, 0.0f, n_i_dot_v_4, alpha_12, lobes_7, eta_i_7, eta_o_7);
    (&sample_0)->pdf = _S184;
    return sample_0;
}

__device__ SampleBSDF refractSample(float3  ggx_n_1, float3  n_i_6, float n_i_dot_v_5, float alpha_13, BSDFMaterial material_7, BSDFLobes lobes_8, float eta_i_8, float eta_o_8, uint random_state_5)
{
    float3  _S185 = make_float3 (1.0f);
    SampleBSDF _S186 = SampleBSDF_x24init_0(_S185, _S185, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S186;
    (&sample_1)->unit_direction = lobes_8.refracted;
    (&sample_1)->random_state = random_state_5;
    (&sample_1)->refracted = true;
    (&sample_1)->lobe = 1U;
    float3  _S187 = refractBSDF((&sample_1)->unit_direction, n_i_6, alpha_13, material_7, lobes_8);
    (&sample_1)->throughput = _S187;
    float _S188 = refractPDF(0.0f, dot_0((&sample_1)->unit_direction, ggx_n_1), n_i_dot_v_5, alpha_13, lobes_8, eta_i_8, eta_o_8);
    (&sample_1)->pdf = _S188;
    return sample_1;
}

__device__ SampleBSDF reflectSample(float3  in_dir_5, float3  ggx_n_2, float3  n_i_7, float n_i_dot_v_6, float alpha_14, BSDFMaterial material_8, BSDFLobes lobes_9, float eta_i_9, float eta_o_9, uint random_state_6)
{
    float3  _S189 = make_float3 (1.0f);
    SampleBSDF _S190 = SampleBSDF_x24init_0(_S189, _S189, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S190;
    float3  _S191 = reflect_0(in_dir_5, ggx_n_2);
    float3  _S192 = ((((_S191)) * make_float3(rnorm3df(((_S191)).x, ((_S191)).y, ((_S191)).z))));
    (&sample_2)->unit_direction = _S192;
    (&sample_2)->random_state = random_state_6;
    (&sample_2)->lobe = 2U;
    float3  _S193 = reflectBSDF((&sample_2)->unit_direction, n_i_7, alpha_14, material_8, lobes_9);
    (&sample_2)->throughput = _S193;
    float _S194 = reflectPDF(0.0f, 0.0f, n_i_dot_v_6, alpha_14, lobes_9, eta_i_9, eta_o_9);
    (&sample_2)->pdf = _S194;
    return sample_2;
}

__device__ SampleBSDF sampleBSDF(float3  in_dir_6, float3  n_8, BSDFMaterial material_9, float eta_i_10, float eta_o_10, uint random_init_0)
{
    uint random_state_7 = random_init_0;
    float3  _S195 = negate_0(in_dir_6);
    float _S196 = dot_0(n_8, _S195);
    float _S197 = sign_0(_S196);
    float3  n_i_8 = n_8 * make_float3 (_S197);
    float _S198 = (F32_abs((_S196)));
    float _S199 = material_9.roughness;
    float _S200 = _S199 * _S199;
    float3  _S201 = sampleHalfVector(_S195, n_i_8, _S200, &random_state_7);
    BSDFLobes _S202 = bsdfLobes(in_dir_6, _S195, n_i_8, _S201, material_9, eta_i_10, eta_o_10);
    Random _S203 = pcg(random_state_7);
    random_state_7 = _S203.state;
    bool _S204 = (_S203.value) < (_S202.p_diffuse);
    if(_S204)
    {
        SampleBSDF _S205 = diffuseSample(n_i_8, _S198, _S200, material_9, _S202, eta_i_10, eta_o_10, random_state_7);
        return _S205;
    }
    bool _S206 = (_S203.value) < (_S202.p_diffuse + _S202.p_refract);
    if(_S206)
    {
        SampleBSDF _S207 = refractSample(_S201, n_i_8, _S198, _S200, material_9, _S202, eta_i_10, eta_o_10, random_state_7);
        return _S207;
    }
    SampleBSDF _S208 = reflectSample(in_dir_6, _S201, n_i_8, _S198, _S200, material_9, _S202, eta_i_10, eta_o_10, random_state_7);
    return _S208;
}

__device__ float3  pointLightRadiance(float3  color_0, float intensity_0, float radius_0)
{
    return color_0 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_0 * radius_0);
}

__device__ float3  beerLambert(float distance_0, float3  absorption_0)
{
    float3  _S209 = max_0(absorption_0, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_0) * log_0(_S209));
}

__device__ bool neeDecision(BSDFMaterial material_10, float n_dot_v_0, float eta_i_11, float eta_o_11)
{
    float _S210 = fresnel((F32_abs((n_dot_v_0))), eta_i_11, eta_o_11);
    float3  _S211 = mix_0(make_float3 (_S210), material_10.albedo, material_10.metallic);
    float _S212 = rgb_to_greyscale(_S211);
    float _S213 = (F32_max(((1.0f - _S212) * (1.0f - material_10.metallic) * (1.0f - material_10.transmission)), (0.0f)));
    bool _S214 = _S213 > 0.03999999910593033f;
    bool _S215;
    if(_S214)
    {
        _S215 = true;
    }
    else
    {
        _S215 = (material_10.roughness) > 0.20000000298023224f;
    }
    return _S215;
}

__device__ float3  straightThrough(float3  dir_0, float3  n_9, BSDFMaterial material_11)
{
    float _S216 = rgb_to_greyscale(material_11.albedo * make_float3 (material_11.metallic));
    float _S217 = material_11.roughness;
    float _S218 = G1(_S217 * _S217, (F32_abs((dot_0(n_9, dir_0)))));
    return make_float3 (material_11.transmission * _S218 * (1.0f - _S216)) * material_11.albedo;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S219 = hash(index_0);
    uint _S220 = hash(seed_0 ^ _S219);
    return _S220;
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float3  _S221 = a_4 / b_0;
    float3  _S222 = make_float3 (0.0f);
    bool3  _S223 = b_0 == _S222;
    float3  _S224 = _slang_select(_S223, _S222,_S221);
    return _S224;
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
    float _S225 = rgb_to_greyscale(weight_0);
    bool _S226 = _S225 > 0.0f;
    bool _S227;
    if(_S226)
    {
        _S227 = _S225 < 3.00000000549775576e+38f;
    }
    else
    {
        _S227 = false;
    }
    bool _S228 = !_S227;
    if(_S228)
    {
        return;
    }
    float _S229 = sel_0->w_sum + _S225;
    sel_0->w_sum = _S229;
    float3  _S230 = sel_0->color + weight_0;
    sel_0->color = _S230;
    Random _S231 = pcg(sel_0->random_state);
    sel_0->random_state = _S231.state;
    bool _S232 = (_S231.value * sel_0->w_sum) <= _S225;
    if(_S232)
    {
        sel_0->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_1, Reservoir r_0, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_0;
    float3  _S233 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S233;
    float _S234 = r_0.jac * shifted_0.jac;
    (&candidate_1)->jac = _S234;
    offer(sel_1, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_0.w));
    return;
}

__device__ Reservoir finalize(Selection sel_2, float c_0)
{
    Reservoir r_1 = sel_2.r;
    float _S235 = rgb_to_greyscale((&r_1)->f);
    float _S236 = sel_2.w_sum / _S235;
    bool _S237 = _S235 > 0.0f;
    float _S238 = _slang_select(_S237, _S236,0.0f);
    (&r_1)->w = _S238;
    (&r_1)->c = c_0;
    return r_1;
}

static __device__ uint insertBits_0(uint e_1, uint newbits_0, uint offset_0, uint count_0)
{
    uint _S239 = (1U << count_0) - 1U;
    return (e_1 & (~(_S239 << offset_0))) | ((newbits_0 & _S239) << offset_0);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_0, float3  f_2)
{
    Reservoir candidate_2 = r_2;
    uint _S240 = insertBits_0(r_2.path, end_0, 0U, 5U);
    uint _S241 = insertBits_0(_S240, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S241;
    (&candidate_2)->f = f_2;
    return candidate_2;
}

__device__ float facingSign(float transmission_0, float3  face_0, float3  direction_0)
{
    bool _S242 = transmission_0 > 0.0f;
    bool _S243;
    if(_S242)
    {
        _S243 = true;
    }
    else
    {
        _S243 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S244;
    if(_S243)
    {
        _S244 = 1.0f;
    }
    else
    {
        _S244 = -1.0f;
    }
    return _S244;
}

__device__ float geometryDensity(float3  geometry_n_0, float3  direction_1, float distance_1)
{
    return (F32_abs((dot_0(geometry_n_0, direction_1)))) / (distance_1 * distance_1);
}

__device__ float footprintThreshold(float geometry_density_0)
{
    return 0.00251327408477664f / geometry_density_0;
}

__device__ bool withinFootprint(bool open_0, bool prev_rough_0, float prev_pdf_0, float geometry_density_1, float threshold_0)
{
    bool _S245;
    if(open_0)
    {
        _S245 = prev_rough_0;
    }
    else
    {
        _S245 = false;
    }
    if(_S245)
    {
        _S245 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S245 = false;
    }
    return _S245;
}

__device__ bool withinInverseFootprint(float pdf_1, bool diffuse_0, float prev_cos_0, float distance_2, float threshold_1)
{
    bool _S246 = pdf_1 > 0.0f;
    bool _S247;
    if(_S246)
    {
        if(diffuse_0)
        {
            _S247 = true;
        }
        else
        {
            _S247 = (pdf_1 * prev_cos_0 / (distance_2 * distance_2) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S247 = false;
    }
    return _S247;
}

__device__ bool roughLobe(float pdf_2, bool diffuse_1, float roughness_0)
{
    bool _S248 = pdf_2 > 0.0f;
    bool _S249;
    if(_S248)
    {
        if(diffuse_1)
        {
            _S249 = true;
        }
        else
        {
            _S249 = roughness_0 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S249 = false;
    }
    return _S249;
}

__device__ float survivalProbability(float3  throughput_1, float density_0)
{
    float3  _S250 = throughput_1 / make_float3 (density_0);
    return clamp_0((F32_max((_S250.x), ((F32_max((_S250.y), (_S250.z)))))), 0.0f, 1.0f);
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S251 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S252 = cos_a_0 > cos_b_0;
    float _S253 = _slang_select(_S252, 1.0f,_S251);
    return _S253;
}

__device__ float sinSubClamped(float sin_a_1, float cos_a_1, float sin_b_1, float cos_b_1)
{
    float _S254 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    bool _S255 = cos_a_1 > cos_b_1;
    float _S256 = _slang_select(_S255, 0.0f,_S254);
    return _S256;
}

__device__ float sine(float c_1)
{
    return (F32_sqrt(((F32_max((1.0f - c_1 * c_1), (0.0f))))));
}

__device__ float importance(LightNode node_0, float3  p_0, float3  normal_0)
{
    float3  _S257 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S258 = node_0.high - node_0.low;
    float3  _S259 = p_0 - _S257;
    float3  _S260 = ((((_S259)) * make_float3(rnorm3df(((_S259)).x, ((_S259)).y, ((_S259)).z))));
    float _S261 = dot_0(_S259, _S259);
    float _S262 = dot_0(_S258, _S258) / 4.0f;
    float _S263 = (F32_abs((dot_0(node_0.w, _S260))));
    float _S264 = sine(node_0.cos_theta_o);
    float _S265 = (F32_sqrt(((F32_max((1.0f - _S262 / _S261), (0.0f))))));
    bool _S266 = _S261 < _S262;
    float _S267 = _slang_select(_S266, -1.0f,_S265);
    float _S268 = sine(_S267);
    float _S269 = sine(_S263);
    float _S270 = cosSubClamped(_S269, _S263, _S264, node_0.cos_theta_o);
    float _S271 = sine(_S263);
    float _S272 = sinSubClamped(_S271, _S263, _S264, node_0.cos_theta_o);
    float _S273 = cosSubClamped(_S272, _S270, _S268, _S267);
    bool _S274 = _S273 <= 0.0f;
    if(_S274)
    {
        return 0.0f;
    }
    float _S275 = - dot_0(_S260, normal_0);
    float _S276 = node_0.phi * _S273 / (F32_max((_S261), (length_0(_S258) / 2.0f)));
    float _S277 = sine(_S275);
    float _S278 = cosSubClamped(_S277, _S275, _S268, _S267);
    bool _S279 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S280 = _slang_select(_S279, 1.0f,_S278);
    return (F32_max((_S276 * _S280), (0.0f)));
}

__device__ float solidAngle(float probability_0, float3  normal_1, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_1, toward_0))));
}

__device__ uint pickChild(LightNode first_0, LightNode second_0, float3  p_1, float3  normal_2, float * pick_0, float * probability_1)
{
    float _S281 = importance(first_0, p_1, normal_2);
    float _S282 = importance(second_0, p_1, normal_2);
    float2  _S283 = make_float2 (_S281, _S282);
    bool _S284 = _S281 == 0.0f;
    bool _S285;
    if(_S284)
    {
        _S285 = _S282 == 0.0f;
    }
    else
    {
        _S285 = false;
    }
    if(_S285)
    {
        return 2U;
    }
    float _S286 = _S281 + _S282;
    bool _S287 = _S282 > 0.0f;
    if(_S287)
    {
        _S285 = (*pick_0 * _S286) >= _S281;
    }
    else
    {
        _S285 = false;
    }
    uint _S288 = uint(_S285);
    float _S289 = (F32_min(((*pick_0 * _S286 - float(_S288) * _S281) / _slang_vector_get_element(_S283, _S288)), (0.99999994039535522f)));
    *pick_0 = _S289;
    float _S290 = *probability_1 * (_slang_vector_get_element(_S283, _S288) / _S286);
    *probability_1 = _S290;
    return _S288;
}

__device__ float childShare(LightNode first_1, LightNode second_1, float3  p_2, float3  normal_3, uint child_0)
{
    float _S291 = importance(first_1, p_2, normal_3);
    float _S292 = importance(second_1, p_2, normal_3);
    float2  _S293 = make_float2 (_S291, _S292);
    float _S294 = _slang_vector_get_element(_S293, child_0) / (_S291 + _S292);
    bool _S295 = _slang_vector_get_element(_S293, child_0) > 0.0f;
    float _S296 = _slang_select(_S295, _S294,0.0f);
    return _S296;
}

__device__ float powerHeuristic(float a_5, float b_1)
{
    float _S297 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    bool _S298 = b_1 > 0.0f;
    float _S299 = _slang_select(_S298, _S297,1.0f);
    return _S299;
}

__device__ float sphereDensity(float3  center_0, float radius_1, float3  p_3)
{
    float3  _S300 = center_0 - p_3;
    float _S301 = radius_1 * radius_1 / dot_0(_S300, _S300);
    bool _S302 = _S301 >= 1.0f;
    if(_S302)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S301)))) / (6.28318548202514648f * _S301);
}

__device__ float3  sampleSphere(float3  center_1, float radius_2, float3  p_4, float u1_0, float u2_0)
{
    float3  _S303 = center_1 - p_4;
    float _S304 = radius_2 * radius_2 / dot_0(_S303, _S303);
    float _S305 = u1_0 * _S304 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S304), (0.0f)))))));
    float _S306 = 2.0f * u1_0;
    bool _S307 = _S304 >= 1.0f;
    float _S308 = _slang_select(_S307, _S306,_S305);
    float _S309 = (F32_sqrt(((F32_max((_S308 * (2.0f - _S308)), (0.0f))))));
    float _S310 = 6.28318548202514648f * u2_0;
    float3  _S311 = make_float3 (_S309 * (F32_cos((_S310))), 1.0f - _S308, _S309 * (F32_sin((_S310))));
    float3  _S312 = ((((_S303)) * make_float3(rnorm3df(((_S303)).x, ((_S303)).y, ((_S303)).z))));
    float3  _S313 = tangentToWorld(_S311, _S312);
    return _S313;
}

#undef Matrix
