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

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
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
    BSDFLobes _S95;
    (&_S95)->v_dot_h = v_dot_h_0;
    (&_S95)->n_dot_h = n_dot_h_1;
    (&_S95)->refracted = refracted_0;
    (&_S95)->F = F_0;
    (&_S95)->F_greyscale = F_greyscale_0;
    (&_S95)->reflect_weight = reflect_weight_0;
    (&_S95)->diffuse_weight = diffuse_weight_0;
    (&_S95)->refract_weight = refract_weight_0;
    (&_S95)->p_diffuse = p_diffuse_0;
    (&_S95)->p_reflect = p_reflect_0;
    (&_S95)->p_refract = p_refract_0;
    return _S95;
}

__device__ BSDFLobes bsdfLobes(float3  in_dir_0, float3  v_4, float3  n_i_1, float3  ggx_n_0, BSDFMaterial material_0, float eta_i_1, float eta_o_1)
{
    float _S96 = dot_0(ggx_n_0, v_4);
    float _S97 = dot_0(n_i_1, ggx_n_0);
    float _S98 = eta_i_1 / eta_o_1;
    float3  _S99 = refract_0(in_dir_0, ggx_n_0, _S98);
    float3  _S100 = ((((_S99)) * make_float3(rnorm3df(((_S99)).x, ((_S99)).y, ((_S99)).z))));
    float _S101 = fresnel((F32_abs((_S96))), eta_i_1, eta_o_1);
    float3  F_1 = mix_0(make_float3 (_S101), material_0.albedo, material_0.metallic);
    float _S102 = rgb_to_greyscale(F_1);
    float _S103 = (1.0f - material_0.transmission) * (1.0f - material_0.metallic);
    float _S104 = (F32_max((_S102), (0.0f)));
    float _S105 = 1.0f - _S102;
    float _S106 = (F32_max((_S103 * _S105), (0.0f)));
    float _S107 = material_0.transmission * _S105;
    float _S108 = sign_0(length_0(_S100));
    float _S109 = (F32_max((_S107 * _S108), (0.0f)));
    float _S110 = _S104 + _S106 + _S109;
    float _S111 = 1.0f / (F32_max((_S110), (0.0000152587890625f)));
    float _S112 = _S106 * _S111;
    float _S113 = _S104 * _S111;
    float _S114 = _S109 * _S111;
    return BSDFLobes_x24init_0(_S96, _S97, _S100, F_1, _S102, 1.0f, _S103, material_0.transmission, _S112, _S113, _S114);
}

__device__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_5, BSDFLobes lobes_0, float eta_i_2, float eta_o_2, uint lobe_0)
{
    bool _S115 = lobe_0 == 0U;
    if(_S115)
    {
        float _S116 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        bool _S117 = n_i_dot_v_0 > 0.0f;
        float _S118 = _slang_select(_S117, _S116,0.0f);
        return _S118;
    }
    float _S119 = smithG1(alpha_5, n_i_dot_v_0);
    float _S120 = _S119 * lobes_0.v_dot_h;
    float _S121 = trowbridgeReitz(alpha_5, lobes_0.n_dot_h);
    float _S122 = _S120 * _S121 / n_i_dot_v_0;
    bool _S123 = alpha_5 > 0.0f;
    bool _S124;
    if(_S123)
    {
        _S124 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S124 = false;
    }
    if(_S124)
    {
        _S124 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S124 = false;
    }
    if(_S124)
    {
        _S124 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S124 = false;
    }
    float _S125 = _slang_select(_S124, _S122,0.0f);
    bool _S126 = lobe_0 == 1U;
    if(_S126)
    {
        float _S127 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        float _S128 = lobes_0.p_refract * _S125 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S127 * _S127);
        bool _S129 = eta_i_2 != eta_o_2;
        if(_S129)
        {
            _S124 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S124 = false;
        }
        float _S130 = _slang_select(_S124, _S128,0.0f);
        return _S130;
    }
    float _S131 = lobes_0.p_reflect * _S125 / (4.0f * lobes_0.v_dot_h);
    bool _S132 = _S125 > 0.0f;
    float _S133 = _slang_select(_S132, _S131,0.0f);
    return _S133;
}

__device__ float3  lobeThroughput(float3  l_0, float3  n_i_2, float alpha_6, BSDFMaterial material_1, BSDFLobes lobes_1, uint lobe_1)
{
    bool _S134 = lobe_1 == 0U;
    if(_S134)
    {
        return make_float3 (lobes_1.diffuse_weight) * material_1.albedo / make_float3 (lobes_1.p_diffuse);
    }
    bool _S135 = lobe_1 == 1U;
    if(_S135)
    {
        float _S136 = - dot_0(n_i_2, l_0);
        float _S137 = G1(alpha_6, (F32_max((_S136), (0.0f))));
        return make_float3 (lobes_1.refract_weight * _S137 * (1.0f - lobes_1.F_greyscale)) * material_1.albedo / make_float3 (lobes_1.p_refract);
    }
    float _S138 = dot_0(n_i_2, l_0);
    float _S139 = G1(alpha_6, (F32_max((_S138), (0.0f))));
    return make_float3 (lobes_1.reflect_weight * _S139) * lobes_1.F / make_float3 (lobes_1.p_reflect);
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
    SampleBSDF _S140;
    (&_S140)->unit_direction = unit_direction_0;
    (&_S140)->throughput = throughput_0;
    (&_S140)->random_state = random_state_1;
    (&_S140)->refracted = refracted_1;
    (&_S140)->lobe = lobe_2;
    (&_S140)->pdf = pdf_0;
    return _S140;
}

__device__ SampleBSDF lobeBSDF(float3  in_dir_1, float3  out_dir_0, float3  n_5, BSDFMaterial material_2, float eta_i_3, float eta_o_3, uint lobe_3, uint random_init_0)
{
    uint random_state_2 = random_init_0;
    float3  _S141 = negate_0(in_dir_1);
    float _S142 = dot_0(n_5, _S141);
    float _S143 = sign_0(_S142);
    float3  _S144 = n_5 * make_float3 (_S143);
    float _S145 = material_2.roughness;
    float _S146 = _S145 * _S145;
    float3  _S147 = _S141 + out_dir_0;
    float3  _S148 = ((((_S147)) * make_float3(rnorm3df(((_S147)).x, ((_S147)).y, ((_S147)).z))));
    bool _S149 = lobe_3 == 0U;
    float3  ggx_n_1;
    if(_S149)
    {
        float3  _S150 = sampleHalfVector(_S141, _S144, _S146, &random_state_2);
        ggx_n_1 = _S150;
    }
    else
    {
        ggx_n_1 = _S148;
    }
    bool _S151 = lobe_3 == 1U;
    if(_S151)
    {
        float3  _S152 = negate_0(make_float3 (eta_i_3) * _S141 + make_float3 (eta_o_3) * out_dir_0);
        float3  _S153 = ((((_S152)) * make_float3(rnorm3df(((_S152)).x, ((_S152)).y, ((_S152)).z))));
        float _S154 = sign_0(dot_0(_S152, _S144));
        float3  _S155 = _S153 * make_float3 (_S154);
        ggx_n_1 = _S155;
    }
    else
    {
    }
    bool _S156 = lobe_3 == 2U;
    if(_S156)
    {
        float3  _S157 = ((((_S147)) * make_float3(rnorm3df(((_S147)).x, ((_S147)).y, ((_S147)).z))));
        ggx_n_1 = _S157;
    }
    else
    {
    }
    BSDFLobes _S158 = bsdfLobes(in_dir_1, _S141, _S144, ggx_n_1, material_2, eta_i_3, eta_o_3);
    float _S159 = lobeDensity(dot_0(_S144, out_dir_0), dot_0(out_dir_0, ggx_n_1), (F32_abs((_S142))), _S146, _S158, eta_i_3, eta_o_3, lobe_3);
    bool _S160 = !(_S159 > 0.0f);
    if(_S160)
    {
        float3  _S161 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S161, _S161, 0U, false, 0U, 0.0f);
    }
    float3  _S162 = lobeThroughput(out_dir_0, _S144, _S146, material_2, _S158, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S162, random_state_2, _S151, lobe_3, _S159);
}

__device__ float3  BSDF(float3  in_dir_2, float3  out_dir_1, float3  n_6, float3  g_n_0, BSDFMaterial material_3, float eta_i_4, float eta_o_4, uint random_state_3)
{
    float3  _S163 = negate_0(in_dir_2);
    bool _S164 = (dot_0(g_n_0, _S163) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S164)
    {
        SampleBSDF _S165 = lobeBSDF(in_dir_2, out_dir_1, n_6, material_3, eta_i_4, eta_o_4, 0U, random_state_3);
        SampleBSDF _S166 = lobeBSDF(in_dir_2, out_dir_1, n_6, material_3, eta_i_4, eta_o_4, 2U, random_state_3);
        return _S165.throughput * make_float3 (_S165.pdf) + _S166.throughput * make_float3 (_S166.pdf);
    }
    SampleBSDF _S167 = lobeBSDF(in_dir_2, out_dir_1, n_6, material_3, eta_i_4, eta_o_4, 1U, random_state_3);
    return _S167.throughput * make_float3 (_S167.pdf);
}

__device__ SampleBSDF sampleBSDF(float3  in_dir_3, float3  n_7, BSDFMaterial material_4, float eta_i_5, float eta_o_5, uint random_init_1, float2  screen_space_0)
{
    uint random_state_4 = random_init_1;
    float3  _S168 = negate_0(in_dir_3);
    float _S169 = dot_0(n_7, _S168);
    float _S170 = sign_0(_S169);
    float3  n_i_3 = n_7 * make_float3 (_S170);
    float _S171 = (F32_abs((_S169)));
    float _S172 = material_4.roughness;
    float _S173 = _S172 * _S172;
    float3  _S174 = sampleHalfVector(_S168, n_i_3, _S173, &random_state_4);
    BSDFLobes _S175 = bsdfLobes(in_dir_3, _S168, n_i_3, _S174, material_4, eta_i_5, eta_o_5);
    float3  _S176 = make_float3 (1.0f);
    SampleBSDF _S177 = SampleBSDF_x24init_0(_S176, _S176, 0U, false, 0U, 0.0f);
    SampleBSDF sample_0 = _S177;
    Random _S178 = pcg(random_state_4);
    random_state_4 = _S178.state;
    bool _S179 = (_S178.value) < (_S175.p_diffuse);
    if(_S179)
    {
        Random _S180 = pcg(random_state_4);
        Random _S181 = pcg(_S180.state);
        (&sample_0)->random_state = _S181.state;
        float3  _S182 = sampleCosWeightedHemisphere(_S180.value, _S181.value);
        float3  _S183 = tangentToWorld(_S182, n_i_3);
        (&sample_0)->unit_direction = _S183;
        float3  _S184 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S173, material_4, _S175, 0U);
        (&sample_0)->throughput = _S184;
        float _S185 = lobeDensity(_S182.y, 0.0f, _S171, _S173, _S175, eta_i_5, eta_o_5, 0U);
        (&sample_0)->pdf = _S185;
        return sample_0;
    }
    bool _S186 = (_S178.value) < (_S175.p_diffuse + _S175.p_refract);
    if(_S186)
    {
        (&sample_0)->unit_direction = _S175.refracted;
        float _S187 = lobeDensity(0.0f, dot_0((&sample_0)->unit_direction, _S174), _S171, _S173, _S175, eta_i_5, eta_o_5, 1U);
        (&sample_0)->pdf = _S187;
        float3  _S188 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S173, material_4, _S175, 1U);
        (&sample_0)->throughput = _S188;
        (&sample_0)->random_state = random_state_4;
        (&sample_0)->refracted = true;
        (&sample_0)->lobe = 1U;
        return sample_0;
    }
    float3  _S189 = reflect_0(in_dir_3, _S174);
    float3  _S190 = ((((_S189)) * make_float3(rnorm3df(((_S189)).x, ((_S189)).y, ((_S189)).z))));
    (&sample_0)->unit_direction = _S190;
    float3  _S191 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S173, material_4, _S175, 2U);
    (&sample_0)->throughput = _S191;
    (&sample_0)->random_state = random_state_4;
    (&sample_0)->lobe = 2U;
    float _S192 = lobeDensity(0.0f, 0.0f, _S171, _S173, _S175, eta_i_5, eta_o_5, 2U);
    (&sample_0)->pdf = _S192;
    return sample_0;
}

__device__ float3  pointLightRadiance(float3  color_0, float intensity_0, float radius_0)
{
    return color_0 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_0 * radius_0);
}

__device__ float3  beerLambert(float distance_0, float3  absorption_0)
{
    float3  _S193 = max_0(absorption_0, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_0) * log_0(_S193));
}

__device__ bool neeDecision(BSDFMaterial material_5, float n_dot_v_0, float eta_i_6, float eta_o_6)
{
    float _S194 = fresnel((F32_abs((n_dot_v_0))), eta_i_6, eta_o_6);
    float3  _S195 = mix_0(make_float3 (_S194), material_5.albedo, material_5.metallic);
    float _S196 = rgb_to_greyscale(_S195);
    float _S197 = (F32_max(((1.0f - _S196) * (1.0f - material_5.metallic) * (1.0f - material_5.transmission)), (0.0f)));
    bool _S198 = _S197 > 0.03999999910593033f;
    bool _S199;
    if(_S198)
    {
        _S199 = true;
    }
    else
    {
        _S199 = (material_5.roughness) > 0.20000000298023224f;
    }
    return _S199;
}

__device__ float3  neeBSDF(float3  in_dir_4, float3  dir_0, float3  n_8, BSDFMaterial material_6, float eta_i_7, float eta_o_7, bool refracted_2, float pdf_1, bool power_0, uint random_state_5)
{
    float3  _S200 = make_float3 (0.0f);
    uint lobe_4 = 0U;
    float3  f_0 = _S200;
    for(;;)
    {
        if(lobe_4 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S201 = (lobe_4 == 1U) == refracted_2;
        float3  f_1;
        if(_S201)
        {
            SampleBSDF _S202 = lobeBSDF(in_dir_4, dir_0, n_8, material_6, eta_i_7, eta_o_7, lobe_4, random_state_5);
            bool _S203 = (_S202.pdf) > 0.0f;
            if(_S203)
            {
                if(power_0)
                {
                    float _S204 = _S202.pdf / pdf_1;
                    float3  f_2 = f_0 + _S202.throughput * make_float3 (_S202.pdf) / make_float3 (pdf_1 * (1.0f + _S204 * _S204));
                    f_1 = f_2;
                }
                else
                {
                    float3  f_3 = f_0 + _S202.throughput * make_float3 (_S202.pdf) / make_float3 (_S202.pdf + pdf_1);
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
    float _S205 = rgb_to_greyscale(material_7.albedo * make_float3 (material_7.metallic));
    float _S206 = material_7.roughness;
    float _S207 = G1(_S206 * _S206, (F32_abs((dot_0(n_9, dir_1)))));
    return make_float3 (material_7.transmission * _S207 * (1.0f - _S205)) * material_7.albedo;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S208 = hash(index_0);
    uint _S209 = hash(seed_0 ^ _S208);
    return _S209;
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float3  _S210 = a_4 / b_0;
    float3  _S211 = make_float3 (0.0f);
    bool3  _S212 = b_0 == _S211;
    float3  _S213 = _slang_select(_S212, _S211,_S210);
    return _S213;
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
    float _S214 = rgb_to_greyscale(weight_0);
    bool _S215 = _S214 > 0.0f;
    bool _S216;
    if(_S215)
    {
        _S216 = _S214 < 3.00000000549775576e+38f;
    }
    else
    {
        _S216 = false;
    }
    bool _S217 = !_S216;
    if(_S217)
    {
        return;
    }
    float _S218 = sel_0->w_sum + _S214;
    sel_0->w_sum = _S218;
    float3  _S219 = sel_0->color + weight_0;
    sel_0->color = _S219;
    Random _S220 = pcg(sel_0->random_state);
    sel_0->random_state = _S220.state;
    bool _S221 = (_S220.value * sel_0->w_sum) <= _S214;
    if(_S221)
    {
        sel_0->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_1, Reservoir r_0, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_0;
    float3  _S222 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S222;
    float _S223 = r_0.jac * shifted_0.jac;
    (&candidate_1)->jac = _S223;
    offer(sel_1, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_0.w));
    return;
}

__device__ Reservoir finalize(Selection sel_2, float c_0)
{
    Reservoir r_1 = sel_2.r;
    float _S224 = rgb_to_greyscale((&r_1)->f);
    float _S225 = sel_2.w_sum / _S224;
    bool _S226 = _S224 > 0.0f;
    float _S227 = _slang_select(_S226, _S225,0.0f);
    (&r_1)->w = _S227;
    (&r_1)->c = c_0;
    return r_1;
}

static __device__ uint insertBits_0(uint e_1, uint newbits_0, uint offset_0, uint count_0)
{
    uint _S228 = (1U << count_0) - 1U;
    return (e_1 & (~(_S228 << offset_0))) | ((newbits_0 & _S228) << offset_0);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_0, float3  f_4)
{
    Reservoir candidate_2 = r_2;
    uint _S229 = insertBits_0(r_2.path, end_0, 0U, 5U);
    uint _S230 = insertBits_0(_S229, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S230;
    (&candidate_2)->f = f_4;
    return candidate_2;
}

__device__ float facingSign(float transmission_0, float3  face_0, float3  direction_0)
{
    bool _S231 = transmission_0 > 0.0f;
    bool _S232;
    if(_S231)
    {
        _S232 = true;
    }
    else
    {
        _S232 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S233;
    if(_S232)
    {
        _S233 = 1.0f;
    }
    else
    {
        _S233 = -1.0f;
    }
    return _S233;
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
    bool _S234;
    if(open_0)
    {
        _S234 = prev_rough_0;
    }
    else
    {
        _S234 = false;
    }
    if(_S234)
    {
        _S234 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S234 = false;
    }
    return _S234;
}

__device__ bool withinInverseFootprint(float pdf_2, bool diffuse_0, float prev_cos_0, float distance_2, float threshold_1)
{
    bool _S235 = pdf_2 > 0.0f;
    bool _S236;
    if(_S235)
    {
        if(diffuse_0)
        {
            _S236 = true;
        }
        else
        {
            _S236 = (pdf_2 * prev_cos_0 / (distance_2 * distance_2) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S236 = false;
    }
    return _S236;
}

__device__ bool roughLobe(float pdf_3, bool diffuse_1, float roughness_0)
{
    bool _S237 = pdf_3 > 0.0f;
    bool _S238;
    if(_S237)
    {
        if(diffuse_1)
        {
            _S238 = true;
        }
        else
        {
            _S238 = roughness_0 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S238 = false;
    }
    return _S238;
}

__device__ float survivalProbability(float3  throughput_1, float density_0)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_0), (0.0f)))), (1.0f)));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S239 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S240 = cos_a_0 > cos_b_0;
    float _S241 = _slang_select(_S240, 1.0f,_S239);
    return _S241;
}

__device__ float sinSubClamped(float sin_a_1, float cos_a_1, float sin_b_1, float cos_b_1)
{
    float _S242 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    bool _S243 = cos_a_1 > cos_b_1;
    float _S244 = _slang_select(_S243, 0.0f,_S242);
    return _S244;
}

__device__ float sine(float c_1)
{
    return (F32_sqrt(((F32_max((1.0f - c_1 * c_1), (0.0f))))));
}

__device__ float importance(LightNode node_0, float3  p_0, float3  normal_0)
{
    float3  _S245 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S246 = node_0.high - node_0.low;
    float3  _S247 = p_0 - _S245;
    float3  _S248 = ((((_S247)) * make_float3(rnorm3df(((_S247)).x, ((_S247)).y, ((_S247)).z))));
    float _S249 = dot_0(_S247, _S247);
    float _S250 = dot_0(_S246, _S246) / 4.0f;
    float _S251 = (F32_abs((dot_0(node_0.w, _S248))));
    float _S252 = sine(node_0.cos_theta_o);
    float _S253 = (F32_sqrt(((F32_max((1.0f - _S250 / _S249), (0.0f))))));
    bool _S254 = _S249 < _S250;
    float _S255 = _slang_select(_S254, -1.0f,_S253);
    float _S256 = sine(_S255);
    float _S257 = sine(_S251);
    float _S258 = cosSubClamped(_S257, _S251, _S252, node_0.cos_theta_o);
    float _S259 = sine(_S251);
    float _S260 = sinSubClamped(_S259, _S251, _S252, node_0.cos_theta_o);
    float _S261 = cosSubClamped(_S260, _S258, _S256, _S255);
    bool _S262 = _S261 <= 0.0f;
    if(_S262)
    {
        return 0.0f;
    }
    float _S263 = - dot_0(_S248, normal_0);
    float _S264 = node_0.phi * _S261 / (F32_max((_S249), (length_0(_S246) / 2.0f)));
    float _S265 = sine(_S263);
    float _S266 = cosSubClamped(_S265, _S263, _S256, _S255);
    bool _S267 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S268 = _slang_select(_S267, 1.0f,_S266);
    return (F32_max((_S264 * _S268), (0.0f)));
}

__device__ float solidAngle(float probability_0, float3  normal_1, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_1, toward_0))));
}

__device__ uint pickChild(LightNode first_0, LightNode second_0, float3  p_1, float3  normal_2, float * pick_0, float * probability_1)
{
    float _S269 = importance(first_0, p_1, normal_2);
    float _S270 = importance(second_0, p_1, normal_2);
    float2  _S271 = make_float2 (_S269, _S270);
    bool _S272 = _S269 == 0.0f;
    bool _S273;
    if(_S272)
    {
        _S273 = _S270 == 0.0f;
    }
    else
    {
        _S273 = false;
    }
    if(_S273)
    {
        return 2U;
    }
    float _S274 = _S269 + _S270;
    bool _S275 = _S270 > 0.0f;
    if(_S275)
    {
        _S273 = (*pick_0 * _S274) >= _S269;
    }
    else
    {
        _S273 = false;
    }
    uint _S276 = uint(_S273);
    float _S277 = (F32_min(((*pick_0 * _S274 - float(_S276) * _S269) / _slang_vector_get_element(_S271, _S276)), (0.99999994039535522f)));
    *pick_0 = _S277;
    float _S278 = *probability_1 * (_slang_vector_get_element(_S271, _S276) / _S274);
    *probability_1 = _S278;
    return _S276;
}

__device__ float childShare(LightNode first_1, LightNode second_1, float3  p_2, float3  normal_3, uint child_0)
{
    float _S279 = importance(first_1, p_2, normal_3);
    float _S280 = importance(second_1, p_2, normal_3);
    float2  _S281 = make_float2 (_S279, _S280);
    float _S282 = _slang_vector_get_element(_S281, child_0) / (_S279 + _S280);
    bool _S283 = _slang_vector_get_element(_S281, child_0) > 0.0f;
    float _S284 = _slang_select(_S283, _S282,0.0f);
    return _S284;
}

__device__ float powerHeuristic(float a_5, float b_1)
{
    float _S285 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    bool _S286 = b_1 > 0.0f;
    float _S287 = _slang_select(_S286, _S285,1.0f);
    return _S287;
}

__device__ float sphereDensity(float3  center_0, float radius_1, float3  p_3)
{
    float3  _S288 = center_0 - p_3;
    float _S289 = radius_1 * radius_1 / dot_0(_S288, _S288);
    bool _S290 = _S289 >= 1.0f;
    if(_S290)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S289)))) / (6.28318548202514648f * _S289);
}

__device__ float3  sampleSphere(float3  center_1, float radius_2, float3  p_4, float u1_0, float u2_0)
{
    float3  _S291 = center_1 - p_4;
    float _S292 = radius_2 * radius_2 / dot_0(_S291, _S291);
    float _S293 = u1_0 * _S292 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S292), (0.0f)))))));
    float _S294 = 2.0f * u1_0;
    bool _S295 = _S292 >= 1.0f;
    float _S296 = _slang_select(_S295, _S294,_S293);
    float _S297 = (F32_sqrt(((F32_max((_S296 * (2.0f - _S296)), (0.0f))))));
    float _S298 = 6.28318548202514648f * u2_0;
    float3  _S299 = make_float3 (_S297 * (F32_cos((_S298))), 1.0f - _S296, _S297 * (F32_sin((_S298))));
    float3  _S300 = ((((_S291)) * make_float3(rnorm3df(((_S291)).x, ((_S291)).y, ((_S291)).z))));
    float3  _S301 = tangentToWorld(_S299, _S300);
    return _S301;
}

#undef Matrix
