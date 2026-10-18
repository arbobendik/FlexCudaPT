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

static __device__ float dot_0(float3  x_1, float3  y_0)
{
    return x_1.x * y_0.x + x_1.y * y_0.y + x_1.z * y_0.z;
}

static __device__ float3  reflect_0(float3  i_1, float3  n_0)
{
    return i_1 - make_float3 (2.0f * dot_0(n_0, i_1)) * n_0;
}

static __device__ float length_0(float3  x_2)
{
    return (F32_sqrt((dot_0(x_2, x_2))));
}

static __device__ float3  refract_0(float3  i_2, float3  n_1, float eta_0)
{
    float _S1 = dot_0(n_1, i_2);
    float _S2 = 1.0f - eta_0 * eta_0 * (1.0f - _S1 * _S1);
    if(_S2 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_2 - make_float3 (eta_0 * _S1 + (F32_sqrt((_S2)))) * n_1;
}

static __device__ float3  mul_0(float3  left_0, Matrix<float, 3, 3>  right_0)
{
    float3  result_1;
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
        int i_3 = int(0);
        float sum_0 = 0.0f;
        for(;;)
        {
            if(i_3 < int(3))
            {
            }
            else
            {
                break;
            }
            float sum_1 = sum_0 + _slang_vector_get_element(left_0, i_3) * _slang_vector_get_element(right_0.rows[i_3], j_0);
            i_3 = i_3 + int(1);
            sum_0 = sum_1;
        }
        *_slang_vector_get_element_ptr(&result_1, j_0) = sum_0;
        j_0 = j_0 + int(1);
    }
    return result_1;
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

static __device__ float clamp_0(float x_3, float minBound_0, float maxBound_0)
{
    return (F32_min(((F32_max((x_3), (minBound_0)))), (maxBound_0)));
}

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

__device__ uint hash(uint x_4)
{
    uint _S9 = x_4 * 747796405U + 2891336453U;
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

static __device__ float3  negate_0(float3  x_5)
{
    return - x_5;
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

__device__ float trowbridgeReitz(float alpha_0, float n_dot_h_0)
{
    float _S28 = alpha_0 * alpha_0;
    float _S29 = n_dot_h_0 * n_dot_h_0 * (_S28 - 1.0f) + 1.0f;
    return _S28 / (F32_max((3.14159274101257324f * _S29 * _S29), (0.0000152587890625f)));
}

__device__ float G1(float alpha_1, float n_dot_x_0)
{
    float _S30 = alpha_1 * 0.5f;
    return n_dot_x_0 / (F32_max((n_dot_x_0 * (1.0f - _S30) + _S30), (0.0000152587890625f)));
}

__device__ float smithG1(float alpha_2, float n_dot_x_1)
{
    float _S31 = alpha_2 * alpha_2;
    return 2.0f * n_dot_x_1 / (n_dot_x_1 + (F32_sqrt((_S31 + (1.0f - _S31) * n_dot_x_1 * n_dot_x_1))));
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S32 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S33 = eta_i_0 / eta_o_0 * _S32;
    bool _S34 = _S33 < 1.0f;
    float kr_0;
    if(_S34)
    {
        float _S35 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S33 * _S33))))));
        float _S36 = eta_o_0 * cos_theta_0;
        float _S37 = eta_i_0 * _S35;
        float _S38 = (_S36 - _S37) / (_S36 + _S37);
        float _S39 = eta_i_0 * cos_theta_0;
        float _S40 = eta_o_0 * _S35;
        float _S41 = (_S39 - _S40) / (_S39 + _S40);
        float _S42 = (_S38 * _S38 + _S41 * _S41) / 2.0f;
        kr_0 = _S42;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

static __device__ float unshared_0(float x_6)
{
    return x_6;
}

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_3, float U1_0, float U2_0)
{
    float3  _S43 = make_float3 (alpha_3 * Ve_0.x, alpha_3 * Ve_0.y, Ve_0.z);
    float3  _S44 = ((((_S43)) * make_float3(rnorm3df(((_S43)).x, ((_S43)).y, ((_S43)).z))));
    float _S45 = _S44.x;
    float _S46 = _S44.y;
    float _S47 = _S45 * _S45 + _S46 * _S46;
    float3  _S48;
    if(_S47 > 0.0f)
    {
        float3  _S49 = make_float3 (- _S46, _S45, 0.0f);
        float _S50 = (rsqrtf((_S47)));
        _S48 = _S49 * make_float3 (_S50);
    }
    else
    {
        _S48 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S51 = cross_0(_S44, _S48);
    float _S52 = (F32_sqrt((U1_0)));
    float _S53 = 6.28318548202514648f * U2_0;
    float _S54 = _S52 * (F32_cos((_S53)));
    float t2_0 = _S52 * (F32_sin((_S53)));
    float _S55 = 0.5f * (1.0f + _S44.z);
    float t2_1 = (1.0f - _S55) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S54 * _S54)))))) + _S55 * t2_0;
    float3  _S56 = make_float3 (_S54) * _S48 + make_float3 (t2_1) * _S51;
    float _S57 = unshared_0(_S54);
    float _S58 = unshared_0(_S54);
    float3  _S59 = _S56 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S57 * _S58 - t2_1 * t2_1))))))) * _S44;
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
    float3  t_1 = ((((_S88)) * make_float3(rnorm3df(((_S88)).x, ((_S88)).y, ((_S88)).z))));
    bool _S89 = (dot_0(cross_0(n_4, t_1), _S87)) > 0.0f;
    float3  t_2;
    if(_S89)
    {
        float3  _S90 = negate_0(t_1);
        t_2 = _S90;
    }
    else
    {
        t_2 = t_1;
    }
    float3  _S91 = cross_0(n_4, t_2);
    return makeMatrix<float, 3, 3> (t_2, _S91, n_4);
}

__device__ float3  tangentToWorldNormalMap(float3  v_2, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_2, tbn_0);
}

__device__ float3  sampleHalfVector(float3  v_3, float3  n_i_0, float alpha_4, uint * random_state_0)
{
    Random _S92 = pcg(*random_state_0);
    Random _S93 = pcg(_S92.state);
    *random_state_0 = _S93.state;
    float3  _S94 = worldToTangent(v_3, n_i_0);
    float3  _S95 = sampleGGXVNDF(float3 {_S94.x, _S94.z, _S94.y}, alpha_4, _S92.value, _S93.value);
    float3  _S96 = float3 {_S95.x, _S95.z, _S95.y};
    float3  _S97 = tangentToWorld(_S96, n_i_0);
    return _S97;
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

static __device__ float sign_0(float e_0)
{
    float _S98;
    if(e_0 > 0.0f)
    {
        _S98 = 1.0f;
    }
    else
    {
        if(e_0 < 0.0f)
        {
            _S98 = -1.0f;
        }
        else
        {
            _S98 = 0.0f;
        }
    }
    return _S98;
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

__device__ BSDFLobes bsdfLobes(float3  in_dir_0, float3  v_4, float3  n_i_1, float3  ggx_n_0, BSDFMaterial material_0, float eta_i_1, float eta_o_1)
{
    float _S100 = dot_0(ggx_n_0, v_4);
    float _S101 = dot_0(n_i_1, ggx_n_0);
    float _S102 = eta_i_1 / eta_o_1;
    float3  _S103 = refract_0(in_dir_0, ggx_n_0, _S102);
    float3  _S104 = ((((_S103)) * make_float3(rnorm3df(((_S103)).x, ((_S103)).y, ((_S103)).z))));
    float _S105 = fresnel((F32_abs((_S100))), eta_i_1, eta_o_1);
    float3  F_1 = mix_0(make_float3 (_S105), material_0.albedo, material_0.metallic);
    float _S106 = rgb_to_greyscale(F_1);
    float _S107 = (1.0f - material_0.transmission) * (1.0f - material_0.metallic);
    float _S108 = (F32_max((_S106), (0.0f)));
    float _S109 = 1.0f - _S106;
    float _S110 = (F32_max((_S107 * _S109), (0.0f)));
    float _S111 = material_0.transmission * _S109;
    float _S112 = sign_0(length_0(_S104));
    float _S113 = (F32_max((_S111 * _S112), (0.0f)));
    float _S114 = _S108 + _S110 + _S113;
    float _S115 = 1.0f / (F32_max((_S114), (0.0000152587890625f)));
    float _S116 = _S110 * _S115;
    float _S117 = _S108 * _S115;
    float _S118 = _S113 * _S115;
    return BSDFLobes_x24init_0(_S100, _S101, _S104, F_1, _S106, 1.0f, _S107, material_0.transmission, _S116, _S117, _S118);
}

__device__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_5, BSDFLobes lobes_0, float eta_i_2, float eta_o_2, uint lobe_0)
{
    bool _S119 = lobe_0 == 0U;
    if(_S119)
    {
        float _S120 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        bool _S121 = n_i_dot_v_0 > 0.0f;
        float _S122 = _slang_select(_S121, _S120,0.0f);
        return _S122;
    }
    float _S123 = smithG1(alpha_5, n_i_dot_v_0);
    float _S124 = _S123 * lobes_0.v_dot_h;
    float _S125 = trowbridgeReitz(alpha_5, lobes_0.n_dot_h);
    float _S126 = _S124 * _S125 / n_i_dot_v_0;
    bool _S127 = alpha_5 > 0.0f;
    bool _S128;
    if(_S127)
    {
        _S128 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S128 = false;
    }
    if(_S128)
    {
        _S128 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S128 = false;
    }
    if(_S128)
    {
        _S128 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S128 = false;
    }
    float _S129 = _slang_select(_S128, _S126,0.0f);
    bool _S130 = lobe_0 == 1U;
    if(_S130)
    {
        float _S131 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        float _S132 = lobes_0.p_refract * _S129 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S131 * _S131);
        bool _S133 = eta_i_2 != eta_o_2;
        if(_S133)
        {
            _S128 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S128 = false;
        }
        float _S134 = _slang_select(_S128, _S132,0.0f);
        return _S134;
    }
    float _S135 = lobes_0.p_reflect * _S129 / (4.0f * lobes_0.v_dot_h);
    bool _S136 = _S129 > 0.0f;
    float _S137 = _slang_select(_S136, _S135,0.0f);
    return _S137;
}

__device__ float3  lobeThroughput(float3  l_0, float3  n_i_2, float alpha_6, BSDFMaterial material_1, BSDFLobes lobes_1, uint lobe_1)
{
    bool _S138 = lobe_1 == 0U;
    if(_S138)
    {
        return make_float3 (lobes_1.diffuse_weight) * material_1.albedo / make_float3 (lobes_1.p_diffuse);
    }
    bool _S139 = lobe_1 == 1U;
    if(_S139)
    {
        float _S140 = - dot_0(n_i_2, l_0);
        float _S141 = G1(alpha_6, (F32_max((_S140), (0.0f))));
        return make_float3 (lobes_1.refract_weight * _S141 * (1.0f - lobes_1.F_greyscale)) * material_1.albedo / make_float3 (lobes_1.p_refract);
    }
    float _S142 = dot_0(n_i_2, l_0);
    float _S143 = G1(alpha_6, (F32_max((_S142), (0.0f))));
    return make_float3 (lobes_1.reflect_weight * _S143) * lobes_1.F / make_float3 (lobes_1.p_reflect);
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
    SampleBSDF _S144;
    (&_S144)->unit_direction = unit_direction_0;
    (&_S144)->throughput = throughput_0;
    (&_S144)->random_state = random_state_1;
    (&_S144)->refracted = refracted_1;
    (&_S144)->lobe = lobe_2;
    (&_S144)->pdf = pdf_0;
    return _S144;
}

__device__ SampleBSDF connectBSDF(float3  in_dir_1, float3  out_dir_0, float3  n_5, BSDFMaterial material_2, float eta_i_3, float eta_o_3, uint lobe_3, uint random_init_0)
{
    uint random_state_2 = random_init_0;
    float3  _S145 = negate_0(in_dir_1);
    float _S146 = dot_0(n_5, _S145);
    float _S147 = sign_0(_S146);
    float3  _S148 = n_5 * make_float3 (_S147);
    float _S149 = material_2.roughness;
    float _S150 = _S149 * _S149;
    float3  _S151 = _S145 + out_dir_0;
    float3  _S152 = ((((_S151)) * make_float3(rnorm3df(((_S151)).x, ((_S151)).y, ((_S151)).z))));
    bool _S153 = lobe_3 == 0U;
    float3  ggx_n_1;
    if(_S153)
    {
        float3  _S154 = sampleHalfVector(_S145, _S148, _S150, &random_state_2);
        ggx_n_1 = _S154;
    }
    else
    {
        bool _S155 = lobe_3 == 1U;
        if(_S155)
        {
            float3  _S156 = negate_0(make_float3 (eta_i_3) * _S145 + make_float3 (eta_o_3) * out_dir_0);
            float3  _S157 = ((((_S156)) * make_float3(rnorm3df(((_S156)).x, ((_S156)).y, ((_S156)).z))));
            float _S158 = sign_0(dot_0(_S156, _S148));
            float3  _S159 = _S157 * make_float3 (_S158);
            ggx_n_1 = _S159;
        }
        else
        {
            ggx_n_1 = _S152;
        }
    }
    BSDFLobes _S160 = bsdfLobes(in_dir_1, _S145, _S148, ggx_n_1, material_2, eta_i_3, eta_o_3);
    float _S161 = lobeDensity(dot_0(_S148, out_dir_0), dot_0(out_dir_0, ggx_n_1), (F32_abs((_S146))), _S150, _S160, eta_i_3, eta_o_3, lobe_3);
    bool _S162 = !(_S161 > 0.0f);
    if(_S162)
    {
        float3  _S163 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S163, _S163, 0U, false, 0U, 0.0f);
    }
    float3  _S164 = lobeThroughput(out_dir_0, _S148, _S150, material_2, _S160, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S164, random_state_2, lobe_3 == 1U, lobe_3, _S161);
}

__device__ float3  BSDF(float3  in_dir_2, float3  out_dir_1, float3  n_6, float3  g_n_0, BSDFMaterial material_3, float eta_i_4, float eta_o_4, uint random_state_3)
{
    float3  _S165 = negate_0(in_dir_2);
    bool _S166 = (dot_0(g_n_0, _S165) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S166)
    {
        SampleBSDF _S167 = connectBSDF(in_dir_2, out_dir_1, n_6, material_3, eta_i_4, eta_o_4, 0U, random_state_3);
        SampleBSDF _S168 = connectBSDF(in_dir_2, out_dir_1, n_6, material_3, eta_i_4, eta_o_4, 2U, random_state_3);
        return _S167.throughput * make_float3 (_S167.pdf) + _S168.throughput * make_float3 (_S168.pdf);
    }
    SampleBSDF _S169 = connectBSDF(in_dir_2, out_dir_1, n_6, material_3, eta_i_4, eta_o_4, 1U, random_state_3);
    return _S169.throughput * make_float3 (_S169.pdf);
}

__device__ SampleBSDF sampleBSDF(float3  in_dir_3, float3  n_7, BSDFMaterial material_4, float eta_i_5, float eta_o_5, uint random_init_1, float2  screen_space_0)
{
    uint random_state_4 = random_init_1;
    float3  _S170 = negate_0(in_dir_3);
    float _S171 = dot_0(n_7, _S170);
    float _S172 = sign_0(_S171);
    float3  n_i_3 = n_7 * make_float3 (_S172);
    float _S173 = (F32_abs((_S171)));
    float _S174 = material_4.roughness;
    float _S175 = _S174 * _S174;
    float3  _S176 = sampleHalfVector(_S170, n_i_3, _S175, &random_state_4);
    BSDFLobes _S177 = bsdfLobes(in_dir_3, _S170, n_i_3, _S176, material_4, eta_i_5, eta_o_5);
    float3  _S178 = make_float3 (1.0f);
    SampleBSDF _S179 = SampleBSDF_x24init_0(_S178, _S178, 0U, false, 0U, 0.0f);
    SampleBSDF sample_0 = _S179;
    Random _S180 = pcg(random_state_4);
    random_state_4 = _S180.state;
    bool _S181 = (_S180.value) < (_S177.p_diffuse);
    if(_S181)
    {
        Random _S182 = pcg(random_state_4);
        Random _S183 = pcg(_S182.state);
        (&sample_0)->random_state = _S183.state;
        float3  _S184 = sampleCosWeightedHemisphere(_S182.value, _S183.value);
        float3  _S185 = tangentToWorld(_S184, n_i_3);
        (&sample_0)->unit_direction = _S185;
        float3  _S186 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S175, material_4, _S177, 0U);
        (&sample_0)->throughput = _S186;
        float _S187 = lobeDensity(_S184.y, 0.0f, _S173, _S175, _S177, eta_i_5, eta_o_5, 0U);
        (&sample_0)->pdf = _S187;
        return sample_0;
    }
    bool _S188 = (_S180.value) < (_S177.p_diffuse + _S177.p_refract);
    if(_S188)
    {
        (&sample_0)->unit_direction = _S177.refracted;
        float _S189 = lobeDensity(0.0f, dot_0((&sample_0)->unit_direction, _S176), _S173, _S175, _S177, eta_i_5, eta_o_5, 1U);
        (&sample_0)->pdf = _S189;
        float3  _S190 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S175, material_4, _S177, 1U);
        (&sample_0)->throughput = _S190;
        (&sample_0)->random_state = random_state_4;
        (&sample_0)->refracted = true;
        (&sample_0)->lobe = 1U;
        return sample_0;
    }
    float3  _S191 = reflect_0(in_dir_3, _S176);
    float3  _S192 = ((((_S191)) * make_float3(rnorm3df(((_S191)).x, ((_S191)).y, ((_S191)).z))));
    (&sample_0)->unit_direction = _S192;
    float3  _S193 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S175, material_4, _S177, 2U);
    (&sample_0)->throughput = _S193;
    (&sample_0)->random_state = random_state_4;
    (&sample_0)->lobe = 2U;
    float _S194 = lobeDensity(0.0f, 0.0f, _S173, _S175, _S177, eta_i_5, eta_o_5, 2U);
    (&sample_0)->pdf = _S194;
    return sample_0;
}

__device__ float3  beerLambert(float distance_0, float3  absorption_0, float density_0)
{
    return exp_0(make_float3 (distance_0 * density_0) * (absorption_0 - make_float3 (1.0f)));
}

__device__ bool neeDecision(BSDFMaterial material_5, float n_dot_v_0, float eta_i_6, float eta_o_6)
{
    float _S195 = fresnel((F32_abs((n_dot_v_0))), eta_i_6, eta_o_6);
    float3  _S196 = mix_0(make_float3 (_S195), material_5.albedo, material_5.metallic);
    float _S197 = rgb_to_greyscale(_S196);
    float _S198 = (F32_max(((1.0f - _S197) * (1.0f - material_5.metallic) * (1.0f - material_5.transmission)), (0.0f)));
    bool _S199 = _S198 > 0.03999999910593033f;
    bool _S200;
    if(_S199)
    {
        _S200 = true;
    }
    else
    {
        _S200 = (material_5.roughness) > 0.20000000298023224f;
    }
    return _S200;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S201 = hash(index_0);
    uint _S202 = hash(seed_0 ^ _S201);
    return _S202;
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float3  _S203 = a_4 / b_0;
    float3  _S204 = make_float3 (0.0f);
    bool3  _S205 = b_0 == _S204;
    float3  _S206 = _slang_select(_S205, _S204,_S203);
    return _S206;
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
    float _S207 = rgb_to_greyscale(weight_0);
    bool _S208 = _S207 > 0.0f;
    bool _S209;
    if(_S208)
    {
        _S209 = _S207 < 3.00000000549775576e+38f;
    }
    else
    {
        _S209 = false;
    }
    bool _S210 = !_S209;
    if(_S210)
    {
        return;
    }
    float _S211 = sel_0->w_sum + _S207;
    sel_0->w_sum = _S211;
    float3  _S212 = sel_0->color + weight_0;
    sel_0->color = _S212;
    Random _S213 = pcg(sel_0->random_state);
    sel_0->random_state = _S213.state;
    bool _S214 = (_S213.value * sel_0->w_sum) <= _S207;
    if(_S214)
    {
        sel_0->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_1, Reservoir r_0, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_0;
    float3  _S215 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S215;
    float _S216 = r_0.jac * shifted_0.jac;
    (&candidate_1)->jac = _S216;
    offer(sel_1, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_0.w));
    return;
}

__device__ Reservoir finalize(Selection sel_2, float c_0)
{
    Reservoir r_1 = sel_2.r;
    float _S217 = rgb_to_greyscale((&r_1)->f);
    float _S218 = sel_2.w_sum / _S217;
    bool _S219 = _S217 > 0.0f;
    float _S220 = _slang_select(_S219, _S218,0.0f);
    (&r_1)->w = _S220;
    (&r_1)->c = c_0;
    return r_1;
}

static __device__ uint insertBits_0(uint e_1, uint newbits_0, uint offset_0, uint count_0)
{
    uint _S221 = (1U << count_0) - 1U;
    return (e_1 & (~(_S221 << offset_0))) | ((newbits_0 & _S221) << offset_0);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_0, float3  f_0)
{
    Reservoir candidate_2 = r_2;
    uint _S222 = insertBits_0(r_2.path, end_0, 0U, 5U);
    uint _S223 = insertBits_0(_S222, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S223;
    (&candidate_2)->f = f_0;
    return candidate_2;
}

#undef Matrix
