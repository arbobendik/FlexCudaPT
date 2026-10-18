#pragma once
#define Matrix SlangMatrix
#include "slang-cuda-prelude.h"

static __device__ float dot_0(float3  x_0, float3  y_0)
{
    return x_0.x * y_0.x + x_0.y * y_0.y + x_0.z * y_0.z;
}

static __device__ float3  reflect_0(float3  i_0, float3  n_0)
{
    return i_0 - make_float3 (2.0f * dot_0(n_0, i_0)) * n_0;
}

static __device__ float length_0(float3  x_1)
{
    return (F32_sqrt((dot_0(x_1, x_1))));
}

static __device__ float3  refract_0(float3  i_1, float3  n_1, float eta_0)
{
    float _S1 = dot_0(n_1, i_1);
    float _S2 = 1.0f - eta_0 * eta_0 * (1.0f - _S1 * _S1);
    if(_S2 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_1 - make_float3 (eta_0 * _S1 + (F32_sqrt((_S2)))) * n_1;
}

static __device__ float3  mul_0(float3  left_0, Matrix<float, 3, 3>  right_0)
{
    float3  result_0;
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
        int i_2 = int(0);
        float sum_0 = 0.0f;
        for(;;)
        {
            if(i_2 < int(3))
            {
            }
            else
            {
                break;
            }
            float sum_1 = sum_0 + _slang_vector_get_element(left_0, i_2) * _slang_vector_get_element(right_0.rows[i_2], j_0);
            i_2 = i_2 + int(1);
            sum_0 = sum_1;
        }
        *_slang_vector_get_element_ptr(&result_0, j_0) = sum_0;
        j_0 = j_0 + int(1);
    }
    return result_0;
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

static __device__ float clamp_0(float x_2, float minBound_0, float maxBound_0)
{
    return (F32_min(((F32_max((x_2), (minBound_0)))), (maxBound_0)));
}

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

__device__ uint hash(uint x_3)
{
    uint _S9 = x_3 * 747796405U + 2891336453U;
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

struct RandomHemisphere
{
    uint state;
    float3  value;
};

static __device__ RandomHemisphere RandomHemisphere_x24init_0(uint state_6, float3  value_3)
{
    RandomHemisphere _S24;
    (&_S24)->state = state_6;
    (&_S24)->value = value_3;
    return _S24;
}

static __device__ float3  negate_0(float3  x_4)
{
    return - x_4;
}

__device__ RandomHemisphere random_hemisphere(uint state_7, float3  normal_0)
{
    RandomSphere _S25 = random_sphere(state_7);
    bool _S26 = (dot_0(_S25.value, normal_0)) > 0.0f;
    if(_S26)
    {
        return RandomHemisphere_x24init_0(_S25.state, _S25.value);
    }
    else
    {
        float3  _S27 = negate_0(_S25.value);
        return RandomHemisphere_x24init_0(_S25.state, _S27);
    }
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S28 = hash(index_0);
    uint _S29 = hash(seed_0 ^ _S28);
    return _S29;
}

__device__ float trowbridgeReitz(float alpha_0, float n_dot_h_0)
{
    float _S30 = alpha_0 * alpha_0;
    float _S31 = n_dot_h_0 * n_dot_h_0 * (_S30 - 1.0f) + 1.0f;
    return _S30 / (F32_max((3.14159274101257324f * _S31 * _S31), (0.0000152587890625f)));
}

__device__ float G1(float alpha_1, float n_dot_x_0)
{
    float _S32 = alpha_1 * 0.5f;
    return n_dot_x_0 / (F32_max((n_dot_x_0 * (1.0f - _S32) + _S32), (0.0000152587890625f)));
}

__device__ float smithG1(float alpha_2, float n_dot_x_1)
{
    float _S33 = alpha_2 * alpha_2;
    return 2.0f * n_dot_x_1 / (n_dot_x_1 + (F32_sqrt((_S33 + (1.0f - _S33) * n_dot_x_1 * n_dot_x_1))));
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S34 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S35 = eta_i_0 / eta_o_0 * _S34;
    bool _S36 = _S35 < 1.0f;
    float kr_0;
    if(_S36)
    {
        float _S37 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S35 * _S35))))));
        float _S38 = eta_o_0 * cos_theta_0;
        float _S39 = eta_i_0 * _S37;
        float _S40 = (_S38 - _S39) / (_S38 + _S39);
        float _S41 = eta_i_0 * cos_theta_0;
        float _S42 = eta_o_0 * _S37;
        float _S43 = (_S41 - _S42) / (_S41 + _S42);
        float _S44 = (_S40 * _S40 + _S43 * _S43) / 2.0f;
        kr_0 = _S44;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

static __device__ float unshared_0(float x_5)
{
    return x_5;
}

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_3, float U1_0, float U2_0)
{
    float3  _S45 = make_float3 (alpha_3 * Ve_0.x, alpha_3 * Ve_0.y, Ve_0.z);
    float3  _S46 = ((((_S45)) * make_float3(rnorm3df(((_S45)).x, ((_S45)).y, ((_S45)).z))));
    float _S47 = _S46.x;
    float _S48 = _S46.y;
    float _S49 = _S47 * _S47 + _S48 * _S48;
    float3  _S50;
    if(_S49 > 0.0f)
    {
        float3  _S51 = make_float3 (- _S48, _S47, 0.0f);
        float _S52 = (rsqrtf((_S49)));
        _S50 = _S51 * make_float3 (_S52);
    }
    else
    {
        _S50 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S53 = cross_0(_S46, _S50);
    float _S54 = (F32_sqrt((U1_0)));
    float _S55 = 6.28318548202514648f * U2_0;
    float _S56 = _S54 * (F32_cos((_S55)));
    float t2_0 = _S54 * (F32_sin((_S55)));
    float _S57 = 0.5f * (1.0f + _S46.z);
    float t2_1 = (1.0f - _S57) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S56 * _S56)))))) + _S57 * t2_0;
    float3  _S58 = make_float3 (_S56) * _S50 + make_float3 (t2_1) * _S53;
    float _S59 = unshared_0(_S56);
    float _S60 = unshared_0(_S56);
    float3  _S61 = _S58 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S59 * _S60 - t2_1 * t2_1))))))) * _S46;
    float3  _S62 = make_float3 (alpha_3 * _S61.x, alpha_3 * _S61.y, (F32_max((0.0f), (_S61.z))));
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
    float3  t_1 = ((((_S90)) * make_float3(rnorm3df(((_S90)).x, ((_S90)).y, ((_S90)).z))));
    bool _S91 = (dot_0(cross_0(n_4, t_1), _S89)) > 0.0f;
    float3  t_2;
    if(_S91)
    {
        float3  _S92 = negate_0(t_1);
        t_2 = _S92;
    }
    else
    {
        t_2 = t_1;
    }
    float3  _S93 = cross_0(n_4, t_2);
    return makeMatrix<float, 3, 3> (t_2, _S93, n_4);
}

__device__ float3  tangentToWorldNormalMap(float3  v_2, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_2, tbn_0);
}

__device__ float3  sampleHalfVector(float3  v_3, float3  n_i_0, float alpha_4, uint * random_state_0)
{
    Random _S94 = pcg(*random_state_0);
    Random _S95 = pcg(_S94.state);
    *random_state_0 = _S95.state;
    float3  _S96 = worldToTangent(v_3, n_i_0);
    float3  _S97 = sampleGGXVNDF(float3 {_S96.x, _S96.z, _S96.y}, alpha_4, _S94.value, _S95.value);
    float3  _S98 = float3 {_S97.x, _S97.z, _S97.y};
    float3  _S99 = tangentToWorld(_S98, n_i_0);
    return _S99;
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

static __device__ float sign_0(float e_0)
{
    float _S100;
    if(e_0 > 0.0f)
    {
        _S100 = 1.0f;
    }
    else
    {
        if(e_0 < 0.0f)
        {
            _S100 = -1.0f;
        }
        else
        {
            _S100 = 0.0f;
        }
    }
    return _S100;
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
    float colorless_reflection;
    float p_diffuse;
    float p_reflect;
    float p_refract;
};

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_1, float3  refracted_0, float3  F_0, float F_greyscale_0, float reflect_weight_0, float diffuse_weight_0, float refract_weight_0, float colorless_reflection_0, float p_diffuse_0, float p_reflect_0, float p_refract_0)
{
    BSDFLobes _S101;
    (&_S101)->v_dot_h = v_dot_h_0;
    (&_S101)->n_dot_h = n_dot_h_1;
    (&_S101)->refracted = refracted_0;
    (&_S101)->F = F_0;
    (&_S101)->F_greyscale = F_greyscale_0;
    (&_S101)->reflect_weight = reflect_weight_0;
    (&_S101)->diffuse_weight = diffuse_weight_0;
    (&_S101)->refract_weight = refract_weight_0;
    (&_S101)->colorless_reflection = colorless_reflection_0;
    (&_S101)->p_diffuse = p_diffuse_0;
    (&_S101)->p_reflect = p_reflect_0;
    (&_S101)->p_refract = p_refract_0;
    return _S101;
}

__device__ BSDFLobes bsdfLobes(float3  in_dir_0, float3  v_4, float3  n_i_1, float3  ggx_n_0, BSDFMaterial material_0, float eta_i_1, float eta_o_1)
{
    float _S102 = dot_0(ggx_n_0, v_4);
    float _S103 = dot_0(n_i_1, ggx_n_0);
    float _S104 = eta_i_1 / eta_o_1;
    float3  _S105 = refract_0(in_dir_0, ggx_n_0, _S104);
    float3  _S106 = ((((_S105)) * make_float3(rnorm3df(((_S105)).x, ((_S105)).y, ((_S105)).z))));
    float _S107 = fresnel((F32_abs((_S102))), eta_i_1, eta_o_1);
    float3  F_1 = mix_0(make_float3 (_S107), material_0.albedo, material_0.metallic);
    float _S108 = rgb_to_greyscale(F_1);
    float _S109 = (1.0f - material_0.transmission) * (1.0f - material_0.metallic);
    float _S110 = (F32_max((_S108), (0.0f)));
    float _S111 = 1.0f - _S108;
    float _S112 = (F32_max((_S109 * _S111), (0.0f)));
    float _S113 = material_0.transmission * _S111;
    float _S114 = sign_0(length_0(_S106));
    float _S115 = (F32_max((_S113 * _S114), (0.0f)));
    float _S116 = _S110 + _S112 + _S115;
    float _S117 = 1.0f / (F32_max((_S116), (0.0000152587890625f)));
    float _S118 = _S112 * _S117;
    float _S119 = _S110 * _S117;
    float _S120 = _S115 * _S117;
    return BSDFLobes_x24init_0(_S102, _S103, _S106, F_1, _S108, 1.0f, _S109, material_0.transmission, material_0.transmission, _S118, _S119, _S120);
}

__device__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_5, BSDFLobes lobes_0, float eta_i_2, float eta_o_2, uint lobe_0)
{
    bool _S121 = lobe_0 == 0U;
    if(_S121)
    {
        float _S122 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        bool _S123 = n_i_dot_v_0 > 0.0f;
        float _S124 = _slang_select(_S123, _S122,0.0f);
        return _S124;
    }
    float _S125 = smithG1(alpha_5, n_i_dot_v_0);
    float _S126 = _S125 * lobes_0.v_dot_h;
    float _S127 = trowbridgeReitz(alpha_5, lobes_0.n_dot_h);
    float _S128 = _S126 * _S127 / n_i_dot_v_0;
    bool _S129 = alpha_5 > 0.0f;
    bool _S130;
    if(_S129)
    {
        _S130 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S130 = false;
    }
    if(_S130)
    {
        _S130 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S130 = false;
    }
    if(_S130)
    {
        _S130 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S130 = false;
    }
    float _S131 = _slang_select(_S130, _S128,0.0f);
    bool _S132 = lobe_0 == 1U;
    if(_S132)
    {
        float _S133 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        float _S134 = lobes_0.p_refract * _S131 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S133 * _S133);
        bool _S135 = eta_i_2 != eta_o_2;
        if(_S135)
        {
            _S130 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S130 = false;
        }
        float _S136 = _slang_select(_S130, _S134,0.0f);
        return _S136;
    }
    float _S137 = lobes_0.p_reflect * _S131 / (4.0f * lobes_0.v_dot_h);
    bool _S138 = _S131 > 0.0f;
    float _S139 = _slang_select(_S138, _S137,0.0f);
    return _S139;
}

__device__ float3  lobeThroughput(float3  l_0, float3  n_i_2, float alpha_6, BSDFMaterial material_1, BSDFLobes lobes_1, uint lobe_1)
{
    bool _S140 = lobe_1 == 0U;
    if(_S140)
    {
        return make_float3 (lobes_1.diffuse_weight) * material_1.albedo / make_float3 (lobes_1.p_diffuse);
    }
    bool _S141 = lobe_1 == 1U;
    if(_S141)
    {
        float _S142 = - dot_0(n_i_2, l_0);
        float _S143 = G1(alpha_6, (F32_max((_S142), (0.0f))));
        return make_float3 (lobes_1.refract_weight * _S143 * (1.0f - lobes_1.F_greyscale) / lobes_1.p_refract);
    }
    float _S144 = dot_0(n_i_2, l_0);
    float _S145 = G1(alpha_6, (F32_max((_S144), (0.0f))));
    float _S146 = lobes_1.reflect_weight * _S145;
    float3  _S147 = mix_0(lobes_1.F, make_float3 (lobes_1.F_greyscale), lobes_1.colorless_reflection);
    return make_float3 (_S146) * _S147 / make_float3 (lobes_1.p_reflect);
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
    SampleBSDF _S148;
    (&_S148)->unit_direction = unit_direction_0;
    (&_S148)->throughput = throughput_0;
    (&_S148)->random_state = random_state_1;
    (&_S148)->refracted = refracted_1;
    (&_S148)->lobe = lobe_2;
    (&_S148)->pdf = pdf_0;
    return _S148;
}

__device__ SampleBSDF connectBSDF(float3  in_dir_1, float3  out_dir_0, float3  n_5, BSDFMaterial material_2, float eta_i_3, float eta_o_3, uint lobe_3, uint random_init_0)
{
    uint random_state_2 = random_init_0;
    float3  _S149 = negate_0(in_dir_1);
    float _S150 = dot_0(n_5, _S149);
    float _S151 = sign_0(_S150);
    float3  _S152 = n_5 * make_float3 (_S151);
    float _S153 = material_2.roughness;
    float _S154 = _S153 * _S153;
    float3  _S155 = _S149 + out_dir_0;
    float3  _S156 = ((((_S155)) * make_float3(rnorm3df(((_S155)).x, ((_S155)).y, ((_S155)).z))));
    bool _S157 = lobe_3 == 0U;
    float3  ggx_n_1;
    if(_S157)
    {
        float3  _S158 = sampleHalfVector(_S149, _S152, _S154, &random_state_2);
        ggx_n_1 = _S158;
    }
    else
    {
        bool _S159 = lobe_3 == 1U;
        if(_S159)
        {
            float3  _S160 = negate_0(make_float3 (eta_i_3) * _S149 + make_float3 (eta_o_3) * out_dir_0);
            float3  _S161 = ((((_S160)) * make_float3(rnorm3df(((_S160)).x, ((_S160)).y, ((_S160)).z))));
            float _S162 = sign_0(dot_0(_S160, _S152));
            float3  _S163 = _S161 * make_float3 (_S162);
            ggx_n_1 = _S163;
        }
        else
        {
            ggx_n_1 = _S156;
        }
    }
    BSDFLobes _S164 = bsdfLobes(in_dir_1, _S149, _S152, ggx_n_1, material_2, eta_i_3, eta_o_3);
    float _S165 = lobeDensity(dot_0(_S152, out_dir_0), dot_0(out_dir_0, ggx_n_1), (F32_abs((_S150))), _S154, _S164, eta_i_3, eta_o_3, lobe_3);
    bool _S166 = !(_S165 > 0.0f);
    if(_S166)
    {
        float3  _S167 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S167, _S167, 0U, false, 0U, 0.0f);
    }
    float3  _S168 = lobeThroughput(out_dir_0, _S152, _S154, material_2, _S164, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S168, random_state_2, lobe_3 == 1U, lobe_3, _S165);
}

__device__ float3  BSDF(float3  in_dir_2, float3  out_dir_1, float3  n_6, float3  g_n_0, BSDFMaterial material_3, float eta_i_4, float eta_o_4, uint random_state_3)
{
    float3  _S169 = negate_0(in_dir_2);
    bool _S170 = (dot_0(g_n_0, _S169) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S170)
    {
        SampleBSDF _S171 = connectBSDF(in_dir_2, out_dir_1, n_6, material_3, eta_i_4, eta_o_4, 0U, random_state_3);
        SampleBSDF _S172 = connectBSDF(in_dir_2, out_dir_1, n_6, material_3, eta_i_4, eta_o_4, 2U, random_state_3);
        return _S171.throughput * make_float3 (_S171.pdf) + _S172.throughput * make_float3 (_S172.pdf);
    }
    SampleBSDF _S173 = connectBSDF(in_dir_2, out_dir_1, n_6, material_3, eta_i_4, eta_o_4, 1U, random_state_3);
    return _S173.throughput * make_float3 (_S173.pdf);
}

__device__ SampleBSDF sampleBSDF(float3  in_dir_3, float3  n_7, BSDFMaterial material_4, float eta_i_5, float eta_o_5, uint random_init_1, float2  screen_space_0)
{
    uint random_state_4 = random_init_1;
    float3  _S174 = negate_0(in_dir_3);
    float _S175 = dot_0(n_7, _S174);
    float _S176 = sign_0(_S175);
    float3  n_i_3 = n_7 * make_float3 (_S176);
    float _S177 = (F32_abs((_S175)));
    float _S178 = material_4.roughness;
    float _S179 = _S178 * _S178;
    float3  _S180 = sampleHalfVector(_S174, n_i_3, _S179, &random_state_4);
    BSDFLobes _S181 = bsdfLobes(in_dir_3, _S174, n_i_3, _S180, material_4, eta_i_5, eta_o_5);
    float3  _S182 = make_float3 (1.0f);
    SampleBSDF _S183 = SampleBSDF_x24init_0(_S182, _S182, 0U, false, 0U, 0.0f);
    SampleBSDF sample_0 = _S183;
    Random _S184 = pcg(random_state_4);
    random_state_4 = _S184.state;
    bool _S185 = (_S184.value) < (_S181.p_diffuse);
    if(_S185)
    {
        Random _S186 = pcg(random_state_4);
        Random _S187 = pcg(_S186.state);
        (&sample_0)->random_state = _S187.state;
        float3  _S188 = sampleCosWeightedHemisphere(_S186.value, _S187.value);
        float3  _S189 = tangentToWorld(_S188, n_i_3);
        (&sample_0)->unit_direction = _S189;
        float3  _S190 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S179, material_4, _S181, 0U);
        (&sample_0)->throughput = _S190;
        float _S191 = lobeDensity(_S188.y, 0.0f, _S177, _S179, _S181, eta_i_5, eta_o_5, 0U);
        (&sample_0)->pdf = _S191;
        return sample_0;
    }
    bool _S192 = (_S184.value) < (_S181.p_diffuse + _S181.p_refract);
    if(_S192)
    {
        (&sample_0)->unit_direction = _S181.refracted;
        float _S193 = lobeDensity(0.0f, dot_0((&sample_0)->unit_direction, _S180), _S177, _S179, _S181, eta_i_5, eta_o_5, 1U);
        (&sample_0)->pdf = _S193;
        float3  _S194 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S179, material_4, _S181, 1U);
        (&sample_0)->throughput = _S194;
        (&sample_0)->random_state = random_state_4;
        (&sample_0)->refracted = true;
        (&sample_0)->lobe = 1U;
        return sample_0;
    }
    float3  _S195 = reflect_0(in_dir_3, _S180);
    float3  _S196 = ((((_S195)) * make_float3(rnorm3df(((_S195)).x, ((_S195)).y, ((_S195)).z))));
    (&sample_0)->unit_direction = _S196;
    float3  _S197 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S179, material_4, _S181, 2U);
    (&sample_0)->throughput = _S197;
    (&sample_0)->random_state = random_state_4;
    (&sample_0)->lobe = 2U;
    float _S198 = lobeDensity(0.0f, 0.0f, _S177, _S179, _S181, eta_i_5, eta_o_5, 2U);
    (&sample_0)->pdf = _S198;
    return sample_0;
}

__device__ bool neeDecision(BSDFMaterial material_5, float n_dot_v_0, float eta_i_6, float eta_o_6)
{
    float _S199 = fresnel((F32_abs((n_dot_v_0))), eta_i_6, eta_o_6);
    float3  _S200 = mix_0(make_float3 (_S199), material_5.albedo, material_5.metallic);
    float _S201 = rgb_to_greyscale(_S200);
    float _S202 = (F32_max(((1.0f - _S201) * (1.0f - material_5.metallic) * (1.0f - material_5.transmission)), (0.0f)));
    bool _S203 = _S202 > 0.03999999910593033f;
    bool _S204;
    if(_S203)
    {
        _S204 = true;
    }
    else
    {
        _S204 = (material_5.roughness) > 0.20000000298023224f;
    }
    return _S204;
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float3  _S205 = a_4 / b_0;
    float3  _S206 = make_float3 (0.0f);
    bool3  _S207 = b_0 == _S206;
    float3  _S208 = _slang_select(_S207, _S206,_S205);
    return _S208;
}

#undef Matrix
