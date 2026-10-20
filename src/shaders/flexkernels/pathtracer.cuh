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
    float3  _S45 = make_float3 (1.0f, 0.0f, 0.0f);
    float3  _S46 = make_float3 (- _S43, _S42, 0.0f);
    float _S47 = (rsqrtf((_S44)));
    float3  _S48 = _S46 * make_float3 (_S47);
    bool _S49 = _S44 > 0.0f;
    float3  _S50 = _slang_select(_S49, _S48,_S45);
    float3  _S51 = cross_0(_S41, _S50);
    float _S52 = (F32_sqrt((U1_0)));
    float _S53 = 6.28318548202514648f * U2_0;
    float _S54 = _S52 * (F32_cos((_S53)));
    float t2_0 = _S52 * (F32_sin((_S53)));
    float _S55 = 0.5f * (1.0f + _S41.z);
    float t2_1 = (1.0f - _S55) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S54 * _S54)))))) + _S55 * t2_0;
    float3  _S56 = make_float3 (_S54) * _S50 + make_float3 (t2_1) * _S51;
    float _S57 = unshared_0(_S54);
    float _S58 = unshared_0(_S54);
    float3  _S59 = _S56 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S57 * _S58 - t2_1 * t2_1))))))) * _S41;
    float3  _S60 = make_float3 (alpha_3 * _S59.x, alpha_3 * _S59.y, (F32_max((0.0f), (_S59.z))));
    float3  _S61 = ((((_S60)) * make_float3(rnorm3df(((_S60)).x, ((_S60)).y, ((_S60)).z))));
    return _S61;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S62 = (F32_sqrt((random_1_0)));
    float _S63 = 6.28318548202514648f * random_2_0;
    float _S64 = _S62 * (F32_cos((_S63)));
    float _S65 = _S62 * (F32_sin((_S63)));
    float _S66 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S64 * _S64 - _S65 * _S65))))));
    return make_float3 (_S64, _S66, _S65);
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_2)
{
    float3  a_0 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S67 = (F32_abs((dot_0(n_2, a_0)))) > 0.9999847412109375f;
    float3  a_1;
    if(_S67)
    {
        float3  _S68 = make_float3 (1.0f, 0.0f, 0.0f);
        a_1 = _S68;
    }
    else
    {
        a_1 = a_0;
    }
    float3  _S69 = cross_0(n_2, a_1);
    float3  _S70 = ((((_S69)) * make_float3(rnorm3df(((_S69)).x, ((_S69)).y, ((_S69)).z))));
    float3  _S71 = cross_0(n_2, _S70);
    return make_float3 (v_0.x) * _S70 + make_float3 (v_0.y) * n_2 + make_float3 (v_0.z) * _S71;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
{
    float3  a_2 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S72 = (F32_abs((dot_0(n_3, a_2)))) > 0.9999847412109375f;
    float3  a_3;
    if(_S72)
    {
        float3  _S73 = make_float3 (1.0f, 0.0f, 0.0f);
        a_3 = _S73;
    }
    else
    {
        a_3 = a_2;
    }
    float3  _S74 = cross_0(n_3, a_3);
    float3  _S75 = ((((_S74)) * make_float3(rnorm3df(((_S74)).x, ((_S74)).y, ((_S74)).z))));
    float3  _S76 = cross_0(n_3, _S75);
    return make_float3 (dot_0(v_1, _S75), dot_0(v_1, n_3), dot_0(v_1, _S76));
}

static __device__ float3  negate_0(float3  x_8)
{
    return - x_8;
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_4)
{
    float3  _S77 = p1_0 - p0_0;
    float3  _S78 = p2_0 - p0_0;
    float2  _S79 = uv1_0 - uv0_0;
    float2  _S80 = uv2_0 - uv0_0;
    float _S81 = _S79.x;
    float _S82 = _S80.y;
    float _S83 = _S79.y;
    float _S84 = _S80.x;
    float _S85 = _S81 * _S82 - _S83 * _S84;
    float _S86 = 1.0f / _S85;
    float3  t_0 = (_S77 * make_float3 (_S82) - _S78 * make_float3 (_S83)) * make_float3 (_S86);
    float3  _S87 = (_S78 * make_float3 (_S81) - _S77 * make_float3 (_S84)) * make_float3 (_S86);
    float3  _S88 = t_0 - n_4 * make_float3 (dot_0(n_4, t_0));
    float3  _S89 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_4);
    bool _S90 = (dot_0(_S88, _S88)) > 0.0f;
    float3  _S91 = _slang_select(_S90, _S88,_S89);
    float3  _S92 = ((((_S91)) * make_float3(rnorm3df(((_S91)).x, ((_S91)).y, ((_S91)).z))));
    bool _S93 = (dot_0(cross_0(n_4, _S92), _S87)) > 0.0f;
    float3  t_1;
    if(_S93)
    {
        float3  _S94 = negate_0(_S92);
        t_1 = _S94;
    }
    else
    {
        t_1 = _S92;
    }
    float3  _S95 = cross_0(n_4, t_1);
    return makeMatrix<float, 3, 3> (t_1, _S95, n_4);
}

__device__ float3  tangentToWorldNormalMap(float3  v_2, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_2, tbn_0);
}

__device__ float3  sampleHalfVector(float3  v_3, float3  n_i_0, float alpha_4, uint * random_state_0)
{
    Random _S96 = pcg(*random_state_0);
    Random _S97 = pcg(_S96.state);
    *random_state_0 = _S97.state;
    float3  _S98 = worldToTangent(v_3, n_i_0);
    float3  _S99 = sampleGGXVNDF(float3 {_S98.x, _S98.z, _S98.y}, alpha_4, _S96.value, _S97.value);
    float3  _S100 = float3 {_S99.x, _S99.z, _S99.y};
    float3  _S101 = tangentToWorld(_S100, n_i_0);
    return _S101;
}

static __device__ float sign_0(float e_0)
{
    bool _S102 = e_0 < 0.0f;
    float _S103 = _slang_select(_S102, -1.0f,0.0f);
    bool _S104 = e_0 > 0.0f;
    float _S105 = _slang_select(_S104, 1.0f,_S103);
    return _S105;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_5, BSDFMaterial material_0, uint random_state_1)
{
    uint state_5 = random_state_1;
    float3  _S106 = negate_0(in_dir_0);
    float _S107 = sign_0(dot_0(n_5, _S106));
    float _S108 = material_0.roughness;
    float3  _S109 = sampleHalfVector(_S106, n_5 * make_float3 (_S107), _S108 * _S108, &state_5);
    return _S109;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_6, float eta_i_1, float eta_o_1)
{
    float3  _S110 = negate_0(in_dir_1);
    float3  _S111 = negate_0(make_float3 (eta_i_1) * _S110 + make_float3 (eta_o_1) * out_dir_0);
    float3  _S112 = ((((_S111)) * make_float3(rnorm3df(((_S111)).x, ((_S111)).y, ((_S111)).z))));
    float _S113 = sign_0(dot_0(n_6, _S110));
    float _S114 = sign_0(dot_0(_S111, n_6 * make_float3 (_S113)));
    return _S112 * make_float3 (_S114);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S115 = negate_0(in_dir_2);
    float3  _S116 = _S115 + out_dir_1;
    float3  _S117 = ((((_S116)) * make_float3(rnorm3df(((_S116)).x, ((_S116)).y, ((_S116)).z))));
    return _S117;
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
    BSDFLobes _S118;
    (&_S118)->v_dot_h = v_dot_h_0;
    (&_S118)->n_dot_h = n_dot_h_1;
    (&_S118)->refracted = refracted_0;
    (&_S118)->F = F_0;
    (&_S118)->F_greyscale = F_greyscale_0;
    (&_S118)->reflect_weight = reflect_weight_0;
    (&_S118)->diffuse_weight = diffuse_weight_0;
    (&_S118)->refract_weight = refract_weight_0;
    (&_S118)->p_diffuse = p_diffuse_0;
    (&_S118)->p_reflect = p_reflect_0;
    (&_S118)->p_refract = p_refract_0;
    return _S118;
}

__device__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_4, float3  n_i_1, float3  ggx_n_0, BSDFMaterial material_1, float eta_i_2, float eta_o_2)
{
    float _S119 = dot_0(ggx_n_0, v_4);
    float _S120 = dot_0(n_i_1, ggx_n_0);
    float _S121 = eta_i_2 / eta_o_2;
    float3  _S122 = refract_0(in_dir_3, ggx_n_0, _S121);
    float3  _S123 = ((((_S122)) * make_float3(rnorm3df(((_S122)).x, ((_S122)).y, ((_S122)).z))));
    float _S124 = fresnel((F32_abs((_S119))), eta_i_2, eta_o_2);
    float3  F_1 = mix_0(make_float3 (_S124), material_1.albedo, material_1.metallic);
    float _S125 = rgb_to_greyscale(F_1);
    float _S126 = (1.0f - material_1.transmission) * (1.0f - material_1.metallic);
    float _S127 = (F32_max((_S125), (0.0f)));
    float _S128 = 1.0f - _S125;
    float _S129 = (F32_max((_S126 * _S128), (0.0f)));
    float _S130 = material_1.transmission * _S128;
    float _S131 = sign_0(length_0(_S123));
    float _S132 = (F32_max((_S130 * _S131), (0.0f)));
    float _S133 = _S127 + _S129 + _S132;
    float _S134 = 1.0f / (F32_max((_S133), (0.0000152587890625f)));
    float _S135 = _S129 * _S134;
    float _S136 = _S127 * _S134;
    float _S137 = _S132 * _S134;
    return BSDFLobes_x24init_0(_S119, _S120, _S123, F_1, _S125, 1.0f, _S126, material_1.transmission, _S135, _S136, _S137);
}

__device__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_5, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S138 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    bool _S139 = n_i_dot_v_0 > 0.0f;
    float _S140 = _slang_select(_S139, _S138,0.0f);
    return _S140;
}

__device__ float3  diffuseBSDF(float3  l_0, float3  n_i_2, float alpha_6, BSDFMaterial material_2, BSDFLobes lobes_1)
{
    return make_float3 (lobes_1.diffuse_weight) * material_2.albedo / make_float3 (lobes_1.p_diffuse);
}

__device__ float vndfPDF(float n_i_dot_v_1, float alpha_7, BSDFLobes lobes_2)
{
    float _S141 = smithG1(alpha_7, n_i_dot_v_1);
    float _S142 = _S141 * lobes_2.v_dot_h;
    float _S143 = trowbridgeReitz(alpha_7, lobes_2.n_dot_h);
    float _S144 = _S142 * _S143 / n_i_dot_v_1;
    bool _S145 = alpha_7 > 0.0f;
    bool _S146;
    if(_S145)
    {
        _S146 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S146 = false;
    }
    if(_S146)
    {
        _S146 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S146 = false;
    }
    if(_S146)
    {
        _S146 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S146 = false;
    }
    float _S147 = _slang_select(_S146, _S144,0.0f);
    return _S147;
}

__device__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_8, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S148 = vndfPDF(n_i_dot_v_2, alpha_8, lobes_3);
    float _S149 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S150 = lobes_3.p_refract * _S148 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S149 * _S149);
    bool _S151 = eta_i_4 != eta_o_4;
    bool _S152;
    if(_S151)
    {
        _S152 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S152 = false;
    }
    float _S153 = _slang_select(_S152, _S150,0.0f);
    return _S153;
}

__device__ float3  refractBSDF(float3  l_1, float3  n_i_3, float alpha_9, BSDFMaterial material_3, BSDFLobes lobes_4)
{
    float _S154 = - dot_0(n_i_3, l_1);
    float _S155 = G1(alpha_9, (F32_max((_S154), (0.0f))));
    return make_float3 (lobes_4.refract_weight * _S155 * (1.0f - lobes_4.F_greyscale)) * material_3.albedo / make_float3 (lobes_4.p_refract);
}

__device__ float reflectPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_10, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S156 = vndfPDF(n_i_dot_v_3, alpha_10, lobes_5);
    float _S157 = lobes_5.p_reflect * _S156 / (4.0f * lobes_5.v_dot_h);
    bool _S158 = _S156 > 0.0f;
    float _S159 = _slang_select(_S158, _S157,0.0f);
    return _S159;
}

__device__ float3  reflectBSDF(float3  l_2, float3  n_i_4, float alpha_11, BSDFMaterial material_4, BSDFLobes lobes_6)
{
    float _S160 = dot_0(n_i_4, l_2);
    float _S161 = G1(alpha_11, (F32_max((_S160), (0.0f))));
    return make_float3 (lobes_6.reflect_weight * _S161) * lobes_6.F / make_float3 (lobes_6.p_reflect);
}

__device__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_5, float eta_i_6, float eta_o_6, bool refracted_1, uint random_state_2, FixedArray<float3 , 3>  * throughputs_0, FixedArray<float, 3>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S162 = negate_0(in_dir_4);
    float _S163 = dot_0(n_7, _S162);
    float _S164 = sign_0(_S163);
    float3  _S165 = n_7 * make_float3 (_S164);
    float _S166 = dot_0(_S165, out_dir_2);
    float _S167 = material_5.roughness;
    float _S168 = _S167 * _S167;
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
        float3  _S169 = make_float3 (0.0f);
        (*throughputs_0)[i_6] = _S169;
        (*pdfs_0)[i_6] = 0.0f;
        uint i_7 = i_6 + 1U;
        i_6 = i_7;
    }
    float3  _S170 = make_float3 (0.0f);
    BSDFLobes _S171 = BSDFLobes_x24init_0(0.0f, 0.0f, _S170, _S170, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f);
    uint half_of_0 = 4294967295U;
    BSDFLobes lobe_terms_0 = _S171;
    float3  ggx_n_2 = _S170;
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
        bool _S172 = i_6 == 1U;
        bool _S173 = _S172 != refracted_1;
        if(_S173)
        {
            ggx_n_1 = ggx_n_2;
            uint i_8 = i_6 + 1U;
            ggx_n_2 = ggx_n_1;
            i_6 = i_8;
            continue;
        }
        bool _S174 = i_6 != half_of_0;
        uint half_of_1;
        BSDFLobes lobe_terms_1;
        if(_S174)
        {
            bool _S175 = i_6 == 0U;
            if(_S175)
            {
                float3  _S176 = sampledHalf(in_dir_4, n_7, material_5, random_state_2);
                ggx_n_1 = _S176;
            }
            else
            {
                if(_S172)
                {
                    float3  _S177 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_6, eta_o_6);
                    ggx_n_1 = _S177;
                }
                else
                {
                    float3  _S178 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S178;
                }
            }
            float3  _S179 = negate_0(in_dir_4);
            BSDFLobes _S180 = bsdfLobes(in_dir_4, _S179, _S165, ggx_n_1, material_5, eta_i_6, eta_o_6);
            lobe_terms_1 = _S180;
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
                float _S181 = diffusePDF(_S166, 0.0f, (F32_abs((_S163))), _S168, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[int(0)] = _S181;
                float3  _S182 = diffuseBSDF(out_dir_2, _S165, _S168, material_5, lobe_terms_1);
                (*throughputs_0)[int(0)] = _S182;
                break;
            }
        case 1U:
            {
                float _S183 = refractPDF(_S166, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S163))), _S168, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[int(1)] = _S183;
                float3  _S184 = refractBSDF(out_dir_2, _S165, _S168, material_5, lobe_terms_1);
                (*throughputs_0)[int(1)] = _S184;
                break;
            }
        default:
            {
                float _S185 = reflectPDF(_S166, 0.0f, (F32_abs((_S163))), _S168, lobe_terms_1, eta_i_6, eta_o_6);
                (*pdfs_0)[int(2)] = _S185;
                float3  _S186 = reflectBSDF(out_dir_2, _S165, _S168, material_5, lobe_terms_1);
                (*throughputs_0)[int(2)] = _S186;
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
    ggx_n_1 = _S170;
    for(;;)
    {
        if(i_6 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S187 = ((*pdfs_0)[i_6]) > 0.0f;
        if(_S187)
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
    SampleBSDF _S188;
    (&_S188)->unit_direction = unit_direction_0;
    (&_S188)->throughput = throughput_0;
    (&_S188)->random_state = random_state_3;
    (&_S188)->refracted = refracted_2;
    (&_S188)->lobe = lobe_0;
    (&_S188)->pdf = pdf_0;
    return _S188;
}

__device__ SampleBSDF diffuseSample(float3  n_i_5, float n_i_dot_v_4, float alpha_12, BSDFMaterial material_6, BSDFLobes lobes_7, float eta_i_7, float eta_o_7, uint random_state_4)
{
    float3  _S189 = make_float3 (1.0f);
    SampleBSDF _S190 = SampleBSDF_x24init_0(_S189, _S189, 0U, false, 0U, 0.0f);
    SampleBSDF sample_0 = _S190;
    Random _S191 = pcg(random_state_4);
    Random _S192 = pcg(_S191.state);
    (&sample_0)->random_state = _S192.state;
    float3  _S193 = sampleCosWeightedHemisphere(_S191.value, _S192.value);
    float3  _S194 = tangentToWorld(_S193, n_i_5);
    (&sample_0)->unit_direction = _S194;
    (&sample_0)->lobe = 0U;
    float3  _S195 = diffuseBSDF((&sample_0)->unit_direction, n_i_5, alpha_12, material_6, lobes_7);
    (&sample_0)->throughput = _S195;
    float _S196 = diffusePDF(_S193.y, 0.0f, n_i_dot_v_4, alpha_12, lobes_7, eta_i_7, eta_o_7);
    (&sample_0)->pdf = _S196;
    return sample_0;
}

__device__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_6, float n_i_dot_v_5, float alpha_13, BSDFMaterial material_7, BSDFLobes lobes_8, float eta_i_8, float eta_o_8, uint random_state_5)
{
    float3  _S197 = make_float3 (1.0f);
    SampleBSDF _S198 = SampleBSDF_x24init_0(_S197, _S197, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S198;
    (&sample_1)->unit_direction = lobes_8.refracted;
    (&sample_1)->random_state = random_state_5;
    (&sample_1)->refracted = true;
    (&sample_1)->lobe = 1U;
    float3  _S199 = refractBSDF((&sample_1)->unit_direction, n_i_6, alpha_13, material_7, lobes_8);
    (&sample_1)->throughput = _S199;
    float _S200 = refractPDF(0.0f, dot_0((&sample_1)->unit_direction, ggx_n_3), n_i_dot_v_5, alpha_13, lobes_8, eta_i_8, eta_o_8);
    (&sample_1)->pdf = _S200;
    return sample_1;
}

__device__ SampleBSDF reflectSample(float3  in_dir_5, float3  ggx_n_4, float3  n_i_7, float n_i_dot_v_6, float alpha_14, BSDFMaterial material_8, BSDFLobes lobes_9, float eta_i_9, float eta_o_9, uint random_state_6)
{
    float3  _S201 = make_float3 (1.0f);
    SampleBSDF _S202 = SampleBSDF_x24init_0(_S201, _S201, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S202;
    float3  _S203 = reflect_0(in_dir_5, ggx_n_4);
    float3  _S204 = ((((_S203)) * make_float3(rnorm3df(((_S203)).x, ((_S203)).y, ((_S203)).z))));
    (&sample_2)->unit_direction = _S204;
    (&sample_2)->random_state = random_state_6;
    (&sample_2)->lobe = 2U;
    float3  _S205 = reflectBSDF((&sample_2)->unit_direction, n_i_7, alpha_14, material_8, lobes_9);
    (&sample_2)->throughput = _S205;
    float _S206 = reflectPDF(0.0f, 0.0f, n_i_dot_v_6, alpha_14, lobes_9, eta_i_9, eta_o_9);
    (&sample_2)->pdf = _S206;
    return sample_2;
}

__device__ SampleBSDF sampleBSDF(float3  in_dir_6, float3  n_8, BSDFMaterial material_9, float eta_i_10, float eta_o_10, uint random_init_0, float2  screen_space_0)
{
    uint random_state_7 = random_init_0;
    float3  _S207 = negate_0(in_dir_6);
    float _S208 = dot_0(n_8, _S207);
    float _S209 = sign_0(_S208);
    float3  n_i_8 = n_8 * make_float3 (_S209);
    float _S210 = (F32_abs((_S208)));
    float _S211 = material_9.roughness;
    float _S212 = _S211 * _S211;
    float3  _S213 = sampleHalfVector(_S207, n_i_8, _S212, &random_state_7);
    BSDFLobes _S214 = bsdfLobes(in_dir_6, _S207, n_i_8, _S213, material_9, eta_i_10, eta_o_10);
    Random _S215 = pcg(random_state_7);
    random_state_7 = _S215.state;
    bool _S216 = (_S215.value) < (_S214.p_diffuse);
    if(_S216)
    {
        SampleBSDF _S217 = diffuseSample(n_i_8, _S210, _S212, material_9, _S214, eta_i_10, eta_o_10, random_state_7);
        return _S217;
    }
    bool _S218 = (_S215.value) < (_S214.p_diffuse + _S214.p_refract);
    if(_S218)
    {
        SampleBSDF _S219 = refractSample(_S213, n_i_8, _S210, _S212, material_9, _S214, eta_i_10, eta_o_10, random_state_7);
        return _S219;
    }
    SampleBSDF _S220 = reflectSample(in_dir_6, _S213, n_i_8, _S210, _S212, material_9, _S214, eta_i_10, eta_o_10, random_state_7);
    return _S220;
}

__device__ float3  pointLightRadiance(float3  color_0, float intensity_0, float radius_0)
{
    return color_0 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_0 * radius_0);
}

__device__ float3  beerLambert(float distance_0, float3  absorption_0)
{
    float3  _S221 = max_0(absorption_0, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_0) * log_0(_S221));
}

__device__ bool neeDecision(BSDFMaterial material_10, float n_dot_v_0, float eta_i_11, float eta_o_11)
{
    float _S222 = fresnel((F32_abs((n_dot_v_0))), eta_i_11, eta_o_11);
    float3  _S223 = mix_0(make_float3 (_S222), material_10.albedo, material_10.metallic);
    float _S224 = rgb_to_greyscale(_S223);
    float _S225 = (F32_max(((1.0f - _S224) * (1.0f - material_10.metallic) * (1.0f - material_10.transmission)), (0.0f)));
    bool _S226 = _S225 > 0.03999999910593033f;
    bool _S227;
    if(_S226)
    {
        _S227 = true;
    }
    else
    {
        _S227 = (material_10.roughness) > 0.20000000298023224f;
    }
    return _S227;
}

__device__ float3  straightThrough(BSDFMaterial material_11)
{
    float _S228 = rgb_to_greyscale(material_11.albedo * make_float3 (material_11.metallic));
    return make_float3 (material_11.transmission * (1.0f - _S228)) * material_11.albedo;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S229 = hash(index_0);
    uint _S230 = hash(seed_0 ^ _S229);
    return _S230;
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float3  _S231 = a_4 / b_0;
    float3  _S232 = make_float3 (0.0f);
    bool3  _S233 = b_0 == _S232;
    float3  _S234 = _slang_select(_S233, _S232,_S231);
    return _S234;
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
    float _S235 = rgb_to_greyscale(weight_0);
    bool _S236 = _S235 > 0.0f;
    bool _S237;
    if(_S236)
    {
        _S237 = _S235 < 3.00000000549775576e+38f;
    }
    else
    {
        _S237 = false;
    }
    bool _S238 = !_S237;
    if(_S238)
    {
        return;
    }
    float _S239 = sel_0->w_sum + _S235;
    sel_0->w_sum = _S239;
    float3  _S240 = sel_0->color + weight_0;
    sel_0->color = _S240;
    Random _S241 = pcg(sel_0->random_state);
    sel_0->random_state = _S241.state;
    bool _S242 = (_S241.value * sel_0->w_sum) <= _S235;
    if(_S242)
    {
        sel_0->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_1, Reservoir r_0, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_0;
    float3  _S243 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S243;
    float _S244 = r_0.jac * shifted_0.jac;
    (&candidate_1)->jac = _S244;
    offer(sel_1, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_0.w));
    return;
}

__device__ Reservoir finalize(Selection sel_2, float c_0)
{
    Reservoir r_1 = sel_2.r;
    float _S245 = rgb_to_greyscale((&r_1)->f);
    float _S246 = sel_2.w_sum / _S245;
    bool _S247 = _S245 > 0.0f;
    float _S248 = _slang_select(_S247, _S246,0.0f);
    (&r_1)->w = _S248;
    (&r_1)->c = c_0;
    return r_1;
}

static __device__ uint insertBits_0(uint e_1, uint newbits_0, uint offset_0, uint count_0)
{
    uint _S249 = (1U << count_0) - 1U;
    return (e_1 & (~(_S249 << offset_0))) | ((newbits_0 & _S249) << offset_0);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_0, float3  f_1)
{
    Reservoir candidate_2 = r_2;
    uint _S250 = insertBits_0(r_2.path, end_0, 0U, 5U);
    uint _S251 = insertBits_0(_S250, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S251;
    (&candidate_2)->f = f_1;
    return candidate_2;
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S252 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S253 = cos_a_0 > cos_b_0;
    float _S254 = _slang_select(_S253, 1.0f,_S252);
    return _S254;
}

__device__ float sine(float c_1)
{
    return (F32_sqrt(((F32_max((1.0f - c_1 * c_1), (0.0f))))));
}

__device__ float importance(LightNode node_0, float3  p_0, float3  normal_0)
{
    float3  _S255 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S256 = node_0.high - node_0.low;
    float3  _S257 = p_0 - _S255;
    float3  _S258 = ((((_S257)) * make_float3(rnorm3df(((_S257)).x, ((_S257)).y, ((_S257)).z))));
    float _S259 = dot_0(_S257, _S257);
    float _S260 = dot_0(_S256, _S256) / 4.0f;
    float _S261 = (F32_abs((dot_0(node_0.w, _S258))));
    float _S262 = sine(node_0.cos_theta_o);
    float _S263 = (F32_sqrt(((F32_max((1.0f - _S260 / _S259), (0.0f))))));
    bool _S264 = _S259 < _S260;
    float _S265 = _slang_select(_S264, -1.0f,_S263);
    float _S266 = sine(_S265);
    float _S267 = sine(_S261);
    float _S268 = cosSubClamped(_S267, _S261, _S262, node_0.cos_theta_o);
    float _S269 = sine(_S261);
    float _S270 = _S269 * node_0.cos_theta_o - _S261 * _S262;
    bool _S271 = _S261 > (node_0.cos_theta_o);
    float _S272 = _slang_select(_S271, 0.0f,_S270);
    float _S273 = cosSubClamped(_S272, _S268, _S266, _S265);
    bool _S274 = _S273 <= 0.0f;
    if(_S274)
    {
        return 0.0f;
    }
    float _S275 = - dot_0(_S258, normal_0);
    float _S276 = node_0.phi * _S273 / (F32_max((_S259), (length_0(_S256) / 2.0f)));
    float _S277 = sine(_S275);
    float _S278 = cosSubClamped(_S277, _S275, _S266, _S265);
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
