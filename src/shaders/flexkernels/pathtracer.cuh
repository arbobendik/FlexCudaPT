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
    float _S16 = (F32_sqrt((-2.0f * clamp_0((F32_log((_S14.value))), -8.388607e+06f, 0.0f))));
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

__device__ float G1(float alpha_1, float n_dot_x_0)
{
    float _S25 = alpha_1 * 0.5f;
    return n_dot_x_0 / (F32_max((n_dot_x_0 * (1.0f - _S25) + _S25), (0.0000152587890625f)));
}

__device__ float smithG1(float alpha_2, float n_dot_x_1)
{
    float _S26 = alpha_2 * alpha_2;
    return 2.0f * n_dot_x_1 / (n_dot_x_1 + (F32_sqrt((_S26 + (1.0f - _S26) * n_dot_x_1 * n_dot_x_1))));
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S27 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S28 = eta_i_0 / eta_o_0 * _S27;
    bool _S29 = _S28 < 1.0f;
    float kr_0;
    if(_S29)
    {
        float _S30 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S28 * _S28))))));
        bool _S31 = eta_i_0 == eta_o_0;
        float _S32 = _slang_select(_S31, cos_theta_0,_S30);
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

static __device__ float unshared_0(float x_7)
{
    return x_7;
}

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_3, float U1_0, float U2_0)
{
    float3  _S40 = make_float3 (alpha_3 * Ve_0.x, alpha_3 * Ve_0.y, Ve_0.z);
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
    float3  _S57 = make_float3 (alpha_3 * _S56.x, alpha_3 * _S56.y, (F32_max((0.0f), (_S56.z))));
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

static __device__ float3  negate_0(float3  x_8)
{
    return - x_8;
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

__device__ float3  sampleHalfVector(float3  v_3, float3  n_i_0, float alpha_4, uint * random_state_0)
{
    Random _S89 = pcg(*random_state_0);
    Random _S90 = pcg(_S89.state);
    *random_state_0 = _S90.state;
    float3  _S91 = worldToTangent(v_3, n_i_0);
    float3  _S92 = sampleGGXVNDF(float3 {_S91.x, _S91.z, _S91.y}, alpha_4, _S89.value, _S90.value);
    float3  _S93 = float3 {_S92.x, _S92.z, _S92.y};
    float3  _S94 = tangentToWorld(_S93, n_i_0);
    return _S94;
}

static __device__ float sign_0(float e_0)
{
    float _S95;
    if(e_0 > 0.0f)
    {
        _S95 = 1.0f;
    }
    else
    {
        if(e_0 < 0.0f)
        {
            _S95 = -1.0f;
        }
        else
        {
            _S95 = 0.0f;
        }
    }
    return _S95;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_5, BSDFMaterial material_0, uint random_state_1)
{
    uint state_5 = random_state_1;
    float3  _S96 = negate_0(in_dir_0);
    float _S97 = sign_0(dot_0(n_5, _S96));
    float _S98 = material_0.roughness;
    float3  _S99 = sampleHalfVector(_S96, n_5 * make_float3 (_S97), _S98 * _S98, &state_5);
    return _S99;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_6, float eta_i_1, float eta_o_1)
{
    float3  _S100 = negate_0(in_dir_1);
    float3  _S101 = negate_0(make_float3 (eta_i_1) * _S100 + make_float3 (eta_o_1) * out_dir_0);
    float3  _S102 = ((((_S101)) * make_float3(rnorm3df(((_S101)).x, ((_S101)).y, ((_S101)).z))));
    float _S103 = sign_0(dot_0(n_6, _S100));
    float _S104 = sign_0(dot_0(_S101, n_6 * make_float3 (_S103)));
    return _S102 * make_float3 (_S104);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S105 = negate_0(in_dir_2);
    float3  _S106 = _S105 + out_dir_1;
    float3  _S107 = ((((_S106)) * make_float3(rnorm3df(((_S106)).x, ((_S106)).y, ((_S106)).z))));
    return _S107;
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
    BSDFLobes _S108;
    (&_S108)->v_dot_h = v_dot_h_0;
    (&_S108)->n_dot_h = n_dot_h_1;
    (&_S108)->refracted = refracted_0;
    (&_S108)->F = F_0;
    (&_S108)->F_greyscale = F_greyscale_0;
    (&_S108)->reflect_weight = reflect_weight_0;
    (&_S108)->diffuse_weight = diffuse_weight_0;
    (&_S108)->refract_weight = refract_weight_0;
    (&_S108)->p_diffuse = p_diffuse_0;
    (&_S108)->p_reflect = p_reflect_0;
    (&_S108)->p_refract = p_refract_0;
    return _S108;
}

__device__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_4, float3  n_i_1, float3  ggx_n_0, BSDFMaterial material_1, float eta_i_2, float eta_o_2)
{
    float _S109 = dot_0(ggx_n_0, v_4);
    float _S110 = dot_0(n_i_1, ggx_n_0);
    float _S111 = eta_i_2 / eta_o_2;
    float3  _S112 = refract_0(in_dir_3, ggx_n_0, _S111);
    float3  _S113 = ((((_S112)) * make_float3(rnorm3df(((_S112)).x, ((_S112)).y, ((_S112)).z))));
    float _S114 = fresnel((F32_abs((_S109))), eta_i_2, eta_o_2);
    float3  F_1 = mix_0(make_float3 (_S114), material_1.albedo, material_1.metallic);
    float _S115 = rgb_to_greyscale(F_1);
    float _S116 = (1.0f - material_1.transmission) * (1.0f - material_1.metallic);
    float _S117 = (F32_max((_S115), (0.0f)));
    float _S118 = 1.0f - _S115;
    float _S119 = (F32_max((_S116 * _S118), (0.0f)));
    float _S120 = material_1.transmission * _S118;
    float _S121 = sign_0(length_0(_S113));
    float _S122 = (F32_max((_S120 * _S121), (0.0f)));
    float _S123 = _S117 + _S119 + _S122;
    float _S124 = 1.0f / (F32_max((_S123), (0.0000152587890625f)));
    float _S125 = _S119 * _S124;
    float _S126 = _S117 * _S124;
    float _S127 = _S122 * _S124;
    return BSDFLobes_x24init_0(_S109, _S110, _S113, F_1, _S115, 1.0f, _S116, material_1.transmission, _S125, _S126, _S127);
}

__device__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_5, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S128 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    bool _S129 = n_i_dot_v_0 > 0.0f;
    float _S130 = _slang_select(_S129, _S128,0.0f);
    return _S130;
}

__device__ float3  diffuseBSDF(float3  l_0, float3  n_i_2, float alpha_6, BSDFMaterial material_2, BSDFLobes lobes_1)
{
    return make_float3 (lobes_1.diffuse_weight) * material_2.albedo / make_float3 (lobes_1.p_diffuse);
}

__device__ float vndfPDF(float n_i_dot_v_1, float alpha_7, BSDFLobes lobes_2)
{
    float _S131 = smithG1(alpha_7, n_i_dot_v_1);
    float _S132 = _S131 * lobes_2.v_dot_h;
    float _S133 = trowbridgeReitz(alpha_7, lobes_2.n_dot_h);
    float _S134 = _S132 * _S133 / n_i_dot_v_1;
    bool _S135 = alpha_7 > 0.0f;
    bool _S136;
    if(_S135)
    {
        _S136 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S136 = false;
    }
    if(_S136)
    {
        _S136 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S136 = false;
    }
    if(_S136)
    {
        _S136 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S136 = false;
    }
    float _S137 = _slang_select(_S136, _S134,0.0f);
    return _S137;
}

__device__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_8, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S138 = vndfPDF(n_i_dot_v_2, alpha_8, lobes_3);
    float _S139 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S140 = lobes_3.p_refract * _S138 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S139 * _S139);
    bool _S141 = eta_i_4 != eta_o_4;
    bool _S142;
    if(_S141)
    {
        _S142 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S142 = false;
    }
    float _S143 = _slang_select(_S142, _S140,0.0f);
    return _S143;
}

__device__ float3  refractBSDF(float3  l_1, float3  n_i_3, float alpha_9, BSDFMaterial material_3, BSDFLobes lobes_4)
{
    float _S144 = - dot_0(n_i_3, l_1);
    float _S145 = G1(alpha_9, (F32_max((_S144), (0.0f))));
    return make_float3 (lobes_4.refract_weight * _S145 * (1.0f - lobes_4.F_greyscale)) * material_3.albedo / make_float3 (lobes_4.p_refract);
}

__device__ float reflectPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_10, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S146 = vndfPDF(n_i_dot_v_3, alpha_10, lobes_5);
    float _S147 = lobes_5.p_reflect * _S146 / (4.0f * lobes_5.v_dot_h);
    bool _S148 = _S146 > 0.0f;
    float _S149 = _slang_select(_S148, _S147,0.0f);
    return _S149;
}

__device__ float3  reflectBSDF(float3  l_2, float3  n_i_4, float alpha_11, BSDFMaterial material_4, BSDFLobes lobes_6)
{
    float _S150 = dot_0(n_i_4, l_2);
    float _S151 = G1(alpha_11, (F32_max((_S150), (0.0f))));
    return make_float3 (lobes_6.reflect_weight * _S151) * lobes_6.F / make_float3 (lobes_6.p_reflect);
}

__device__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_5, float eta_i_6, float eta_o_6, bool refracted_1, uint random_state_2, FixedArray<float3 , 3>  * throughputs_0, FixedArray<float, 3>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S152 = negate_0(in_dir_4);
    float _S153 = dot_0(n_7, _S152);
    float _S154 = sign_0(_S153);
    float3  _S155 = n_7 * make_float3 (_S154);
    float _S156 = dot_0(_S155, out_dir_2);
    float _S157 = material_5.roughness;
    float _S158 = _S157 * _S157;
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
        float3  _S159 = make_float3 (0.0f);
        (*throughputs_0)[i_6] = _S159;
        (*pdfs_0)[i_6] = 0.0f;
        uint i_7 = i_6 + 1U;
        i_6 = i_7;
    }
    float3  _S160 = make_float3 (0.0f);
    BSDFLobes _S161 = BSDFLobes_x24init_0(0.0f, 0.0f, _S160, _S160, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f);
    uint half_of_0 = 4294967295U;
    BSDFLobes lobe_terms_0 = _S161;
    float3  ggx_n_2 = _S160;
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
        bool _S162 = i_6 == 1U;
        bool _S163 = _S162 != refracted_1;
        if(_S163)
        {
            ggx_n_1 = ggx_n_2;
            uint i_8 = i_6 + 1U;
            ggx_n_2 = ggx_n_1;
            i_6 = i_8;
            continue;
        }
        bool _S164 = i_6 != half_of_0;
        uint half_of_1;
        BSDFLobes lobe_terms_1;
        if(_S164)
        {
            bool _S165 = i_6 == 0U;
            if(_S165)
            {
                float3  _S166 = sampledHalf(in_dir_4, n_7, material_5, random_state_2);
                ggx_n_1 = _S166;
            }
            else
            {
                if(_S162)
                {
                    float3  _S167 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_6, eta_o_6);
                    ggx_n_1 = _S167;
                }
                else
                {
                    float3  _S168 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S168;
                }
            }
            float3  _S169 = negate_0(in_dir_4);
            BSDFLobes _S170 = bsdfLobes(in_dir_4, _S169, _S155, ggx_n_1, material_5, eta_i_6, eta_o_6);
            lobe_terms_1 = _S170;
            half_of_1 = i_6;
        }
        else
        {
            lobe_terms_1 = lobe_terms_0;
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(i_6)
        {
        case 0U:
            {
                float _S171 = diffusePDF(_S156, 0.0f, (F32_abs((_S153))), _S158, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[int(0)] = _S171;
                float3  _S172 = diffuseBSDF(out_dir_2, _S155, _S158, material_5, lobe_terms_1);
                (*throughputs_0)[int(0)] = _S172;
                break;
            }
        case 1U:
            {
                float _S173 = refractPDF(_S156, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S153))), _S158, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[int(1)] = _S173;
                float3  _S174 = refractBSDF(out_dir_2, _S155, _S158, material_5, lobe_terms_1);
                (*throughputs_0)[int(1)] = _S174;
                break;
            }
        default:
            {
                float _S175 = reflectPDF(_S156, 0.0f, (F32_abs((_S153))), _S158, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[int(2)] = _S175;
                float3  _S176 = reflectBSDF(out_dir_2, _S155, _S158, material_5, lobe_terms_1);
                (*throughputs_0)[int(2)] = _S176;
                break;
            }
        }
        half_of_0 = half_of_1;
        lobe_terms_0 = lobe_terms_1;
        uint i_8 = i_6 + 1U;
        ggx_n_2 = ggx_n_1;
        i_6 = i_8;
    }
    i_6 = 0U;
    ggx_n_1 = _S160;
    for(;;)
    {
        if(i_6 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S177 = ((*pdfs_0)[i_6]) > 0.0f;
        if(_S177)
        {
            float3  f_0 = ggx_n_1 + (*throughputs_0)[i_6] * make_float3 ((*pdfs_0)[i_6]);
            ggx_n_1 = f_0;
        }
        uint i_9 = i_6 + 1U;
        i_6 = i_9;
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
    SampleBSDF _S178;
    (&_S178)->unit_direction = unit_direction_0;
    (&_S178)->throughput = throughput_0;
    (&_S178)->random_state = random_state_3;
    (&_S178)->refracted = refracted_2;
    (&_S178)->lobe = lobe_0;
    (&_S178)->pdf = pdf_0;
    return _S178;
}

__device__ SampleBSDF diffuseSample(float3  n_i_5, float n_i_dot_v_4, float alpha_12, BSDFMaterial material_6, BSDFLobes lobes_7, float eta_i_7, float eta_o_7, uint random_state_4)
{
    float3  _S179 = make_float3 (1.0f);
    SampleBSDF _S180 = SampleBSDF_x24init_0(_S179, _S179, 0U, false, 0U, 0.0f);
    SampleBSDF sample_0 = _S180;
    Random _S181 = pcg(random_state_4);
    Random _S182 = pcg(_S181.state);
    (&sample_0)->random_state = _S182.state;
    float3  _S183 = sampleCosWeightedHemisphere(_S181.value, _S182.value);
    float3  _S184 = tangentToWorld(_S183, n_i_5);
    (&sample_0)->unit_direction = _S184;
    (&sample_0)->lobe = 0U;
    float3  _S185 = diffuseBSDF((&sample_0)->unit_direction, n_i_5, alpha_12, material_6, lobes_7);
    (&sample_0)->throughput = _S185;
    float _S186 = diffusePDF(_S183.y, 0.0f, n_i_dot_v_4, alpha_12, lobes_7, eta_i_7, eta_o_7);
    (&sample_0)->pdf = _S186;
    return sample_0;
}

__device__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_6, float n_i_dot_v_5, float alpha_13, BSDFMaterial material_7, BSDFLobes lobes_8, float eta_i_8, float eta_o_8, uint random_state_5)
{
    float3  _S187 = make_float3 (1.0f);
    SampleBSDF _S188 = SampleBSDF_x24init_0(_S187, _S187, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S188;
    (&sample_1)->unit_direction = lobes_8.refracted;
    (&sample_1)->random_state = random_state_5;
    (&sample_1)->refracted = true;
    (&sample_1)->lobe = 1U;
    float3  _S189 = refractBSDF((&sample_1)->unit_direction, n_i_6, alpha_13, material_7, lobes_8);
    (&sample_1)->throughput = _S189;
    float _S190 = refractPDF(0.0f, dot_0((&sample_1)->unit_direction, ggx_n_3), n_i_dot_v_5, alpha_13, lobes_8, eta_i_8, eta_o_8);
    (&sample_1)->pdf = _S190;
    return sample_1;
}

__device__ SampleBSDF reflectSample(float3  in_dir_5, float3  ggx_n_4, float3  n_i_7, float n_i_dot_v_6, float alpha_14, BSDFMaterial material_8, BSDFLobes lobes_9, float eta_i_9, float eta_o_9, uint random_state_6)
{
    float3  _S191 = make_float3 (1.0f);
    SampleBSDF _S192 = SampleBSDF_x24init_0(_S191, _S191, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S192;
    float3  _S193 = reflect_0(in_dir_5, ggx_n_4);
    float3  _S194 = ((((_S193)) * make_float3(rnorm3df(((_S193)).x, ((_S193)).y, ((_S193)).z))));
    (&sample_2)->unit_direction = _S194;
    (&sample_2)->random_state = random_state_6;
    (&sample_2)->lobe = 2U;
    float3  _S195 = reflectBSDF((&sample_2)->unit_direction, n_i_7, alpha_14, material_8, lobes_9);
    (&sample_2)->throughput = _S195;
    float _S196 = reflectPDF(0.0f, 0.0f, n_i_dot_v_6, alpha_14, lobes_9, eta_i_9, eta_o_9);
    (&sample_2)->pdf = _S196;
    return sample_2;
}

__device__ SampleBSDF sampleBSDF(float3  in_dir_6, float3  n_8, BSDFMaterial material_9, float eta_i_10, float eta_o_10, uint random_init_0, float2  screen_space_0)
{
    uint random_state_7 = random_init_0;
    float3  _S197 = negate_0(in_dir_6);
    float _S198 = dot_0(n_8, _S197);
    float _S199 = sign_0(_S198);
    float3  n_i_8 = n_8 * make_float3 (_S199);
    float _S200 = (F32_abs((_S198)));
    float _S201 = material_9.roughness;
    float _S202 = _S201 * _S201;
    float3  _S203 = sampleHalfVector(_S197, n_i_8, _S202, &random_state_7);
    BSDFLobes _S204 = bsdfLobes(in_dir_6, _S197, n_i_8, _S203, material_9, eta_i_10, eta_o_10);
    Random _S205 = pcg(random_state_7);
    random_state_7 = _S205.state;
    bool _S206 = (_S205.value) < (_S204.p_diffuse);
    if(_S206)
    {
        SampleBSDF _S207 = diffuseSample(n_i_8, _S200, _S202, material_9, _S204, eta_i_10, eta_o_10, random_state_7);
        return _S207;
    }
    bool _S208 = (_S205.value) < (_S204.p_diffuse + _S204.p_refract);
    if(_S208)
    {
        SampleBSDF _S209 = refractSample(_S203, n_i_8, _S200, _S202, material_9, _S204, eta_i_10, eta_o_10, random_state_7);
        return _S209;
    }
    SampleBSDF _S210 = reflectSample(in_dir_6, _S203, n_i_8, _S200, _S202, material_9, _S204, eta_i_10, eta_o_10, random_state_7);
    return _S210;
}

__device__ float3  pointLightRadiance(float3  color_0, float intensity_0, float radius_0)
{
    return color_0 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_0 * radius_0);
}

__device__ float3  beerLambert(float distance_0, float3  absorption_0)
{
    float3  _S211 = max_0(absorption_0, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_0) * log_0(_S211));
}

__device__ bool neeDecision(BSDFMaterial material_10, float n_dot_v_0, float eta_i_11, float eta_o_11)
{
    float _S212 = fresnel((F32_abs((n_dot_v_0))), eta_i_11, eta_o_11);
    float3  _S213 = mix_0(make_float3 (_S212), material_10.albedo, material_10.metallic);
    float _S214 = rgb_to_greyscale(_S213);
    float _S215 = (F32_max(((1.0f - _S214) * (1.0f - material_10.metallic) * (1.0f - material_10.transmission)), (0.0f)));
    bool _S216 = _S215 > 0.03999999910593033f;
    bool _S217;
    if(_S216)
    {
        _S217 = true;
    }
    else
    {
        _S217 = (material_10.roughness) > 0.20000000298023224f;
    }
    return _S217;
}

__device__ float3  straightThrough(float3  dir_0, float3  n_9, BSDFMaterial material_11)
{
    float _S218 = rgb_to_greyscale(material_11.albedo * make_float3 (material_11.metallic));
    float _S219 = material_11.roughness;
    float _S220 = G1(_S219 * _S219, (F32_abs((dot_0(n_9, dir_0)))));
    return make_float3 (material_11.transmission * _S220 * (1.0f - _S218)) * material_11.albedo;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S221 = hash(index_0);
    uint _S222 = hash(seed_0 ^ _S221);
    return _S222;
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float3  _S223 = a_4 / b_0;
    float3  _S224 = make_float3 (0.0f);
    bool3  _S225 = b_0 == _S224;
    float3  _S226 = _slang_select(_S225, _S224,_S223);
    return _S226;
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
    float _S227 = rgb_to_greyscale(weight_0);
    bool _S228 = _S227 > 0.0f;
    bool _S229;
    if(_S228)
    {
        _S229 = _S227 < 3.00000000549775576e+38f;
    }
    else
    {
        _S229 = false;
    }
    bool _S230 = !_S229;
    if(_S230)
    {
        return;
    }
    float _S231 = sel_0->w_sum + _S227;
    sel_0->w_sum = _S231;
    float3  _S232 = sel_0->color + weight_0;
    sel_0->color = _S232;
    Random _S233 = pcg(sel_0->random_state);
    sel_0->random_state = _S233.state;
    bool _S234 = (_S233.value * sel_0->w_sum) <= _S227;
    if(_S234)
    {
        sel_0->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_1, Reservoir r_0, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_0;
    float3  _S235 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S235;
    float _S236 = r_0.jac * shifted_0.jac;
    (&candidate_1)->jac = _S236;
    offer(sel_1, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_0.w));
    return;
}

__device__ Reservoir finalize(Selection sel_2, float c_0)
{
    Reservoir r_1 = sel_2.r;
    float _S237 = rgb_to_greyscale((&r_1)->f);
    float _S238 = sel_2.w_sum / _S237;
    bool _S239 = _S237 > 0.0f;
    float _S240 = _slang_select(_S239, _S238,0.0f);
    (&r_1)->w = _S240;
    (&r_1)->c = c_0;
    return r_1;
}

static __device__ uint insertBits_0(uint e_1, uint newbits_0, uint offset_0, uint count_0)
{
    uint _S241 = (1U << count_0) - 1U;
    return (e_1 & (~(_S241 << offset_0))) | ((newbits_0 & _S241) << offset_0);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_0, float3  f_1)
{
    Reservoir candidate_2 = r_2;
    uint _S242 = insertBits_0(r_2.path, end_0, 0U, 5U);
    uint _S243 = insertBits_0(_S242, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S243;
    (&candidate_2)->f = f_1;
    return candidate_2;
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S244 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S245 = cos_a_0 > cos_b_0;
    float _S246 = _slang_select(_S245, 1.0f,_S244);
    return _S246;
}

__device__ float sine(float c_1)
{
    return (F32_sqrt(((F32_max((1.0f - c_1 * c_1), (0.0f))))));
}

__device__ float importance(LightNode node_0, float3  p_0, float3  normal_0)
{
    float3  _S247 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S248 = node_0.high - node_0.low;
    float3  _S249 = p_0 - _S247;
    float3  _S250 = ((((_S249)) * make_float3(rnorm3df(((_S249)).x, ((_S249)).y, ((_S249)).z))));
    float _S251 = dot_0(_S249, _S249);
    float _S252 = dot_0(_S248, _S248) / 4.0f;
    float _S253 = (F32_abs((dot_0(node_0.w, _S250))));
    float _S254 = sine(node_0.cos_theta_o);
    float _S255 = (F32_sqrt(((F32_max((1.0f - _S252 / _S251), (0.0f))))));
    bool _S256 = _S251 < _S252;
    float _S257 = _slang_select(_S256, -1.0f,_S255);
    float _S258 = sine(_S257);
    float _S259 = sine(_S253);
    float _S260 = cosSubClamped(_S259, _S253, _S254, node_0.cos_theta_o);
    float _S261 = sine(_S253);
    float _S262 = _S261 * node_0.cos_theta_o - _S253 * _S254;
    bool _S263 = _S253 > (node_0.cos_theta_o);
    float _S264 = _slang_select(_S263, 0.0f,_S262);
    float _S265 = cosSubClamped(_S264, _S260, _S258, _S257);
    bool _S266 = _S265 <= 0.0f;
    if(_S266)
    {
        return 0.0f;
    }
    float _S267 = - dot_0(_S250, normal_0);
    float _S268 = node_0.phi * _S265 / (F32_max((_S251), (length_0(_S248) / 2.0f)));
    float _S269 = sine(_S267);
    float _S270 = cosSubClamped(_S269, _S267, _S258, _S257);
    bool _S271 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S272 = _slang_select(_S271, 1.0f,_S270);
    return (F32_max((_S268 * _S272), (0.0f)));
}

__device__ float solidAngle(float probability_0, float3  normal_1, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_1, toward_0))));
}

__device__ uint pickChild(LightNode first_0, LightNode second_0, float3  p_1, float3  normal_2, float * pick_0, float * probability_1)
{
    float _S273 = importance(first_0, p_1, normal_2);
    float _S274 = importance(second_0, p_1, normal_2);
    float2  _S275 = make_float2 (_S273, _S274);
    bool _S276 = _S273 == 0.0f;
    bool _S277;
    if(_S276)
    {
        _S277 = _S274 == 0.0f;
    }
    else
    {
        _S277 = false;
    }
    if(_S277)
    {
        return 2U;
    }
    float _S278 = _S273 + _S274;
    bool _S279 = _S274 > 0.0f;
    if(_S279)
    {
        _S277 = (*pick_0 * _S278) >= _S273;
    }
    else
    {
        _S277 = false;
    }
    uint _S280 = uint(_S277);
    float _S281 = (F32_min(((*pick_0 * _S278 - float(_S280) * _S273) / _slang_vector_get_element(_S275, _S280)), (0.99999994039535522f)));
    *pick_0 = _S281;
    float _S282 = *probability_1 * (_slang_vector_get_element(_S275, _S280) / _S278);
    *probability_1 = _S282;
    return _S280;
}

__device__ float childShare(LightNode first_1, LightNode second_1, float3  p_2, float3  normal_3, uint child_0)
{
    float _S283 = importance(first_1, p_2, normal_3);
    float _S284 = importance(second_1, p_2, normal_3);
    float2  _S285 = make_float2 (_S283, _S284);
    float _S286 = _slang_vector_get_element(_S285, child_0) / (_S283 + _S284);
    bool _S287 = _slang_vector_get_element(_S285, child_0) > 0.0f;
    float _S288 = _slang_select(_S287, _S286,0.0f);
    return _S288;
}

__device__ float powerHeuristic(float a_5, float b_1)
{
    float _S289 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    bool _S290 = b_1 > 0.0f;
    float _S291 = _slang_select(_S290, _S289,1.0f);
    return _S291;
}

__device__ float sphereDensity(float3  center_0, float radius_1, float3  p_3)
{
    float3  _S292 = center_0 - p_3;
    float _S293 = radius_1 * radius_1 / dot_0(_S292, _S292);
    bool _S294 = _S293 >= 1.0f;
    if(_S294)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S293)))) / (6.28318548202514648f * _S293);
}

__device__ float3  sampleSphere(float3  center_1, float radius_2, float3  p_4, float u1_0, float u2_0)
{
    float3  _S295 = center_1 - p_4;
    float _S296 = radius_2 * radius_2 / dot_0(_S295, _S295);
    float _S297 = u1_0 * _S296 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S296), (0.0f)))))));
    float _S298 = 2.0f * u1_0;
    bool _S299 = _S296 >= 1.0f;
    float _S300 = _slang_select(_S299, _S298,_S297);
    float _S301 = (F32_sqrt(((F32_max((_S300 * (2.0f - _S300)), (0.0f))))));
    float _S302 = 6.28318548202514648f * u2_0;
    float3  _S303 = make_float3 (_S301 * (F32_cos((_S302))), 1.0f - _S300, _S301 * (F32_sin((_S302))));
    float3  _S304 = ((((_S295)) * make_float3(rnorm3df(((_S295)).x, ((_S295)).y, ((_S295)).z))));
    float3  _S305 = tangentToWorld(_S303, _S304);
    return _S305;
}

#undef Matrix
