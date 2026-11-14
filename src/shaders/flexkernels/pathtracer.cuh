#pragma once
#define Matrix SlangMatrix
#include "slang-cuda-prelude.h"

static __device__ float dot_0(float3  x_0, float3  y_0)
{
    return x_0.x * y_0.x + x_0.y * y_0.y + x_0.z * y_0.z;
}

static __device__ bool wrongSide_0(bool is_inside_0, bool refracted_0, float3  dir_0, float3  geometry_n_0)
{
    return (is_inside_0 == refracted_0) != ((dot_0(dir_0, geometry_n_0)) > 0.0f);
}

static __device__ FKRay Ray_x24init_0(float3  origin_0, float3  unit_direction_0)
{
    FKRay _S1;
    (&_S1)->origin = origin_0;
    (&_S1)->unit_direction = unit_direction_0;
    return _S1;
}

static __device__ float3  skyRadiance_0(float3  origin_1, FKSurface * surface_0, bool is_inside_1, float3  dir_1)
{
    bool _S2 = wrongSide_0(is_inside_1, false, dir_1, surface_0->geometry_n);
    bool _S3 = is_inside_1 != _S2;
    float _S4 = surface_0->geometry_offset;
    float3  _S5 = surface_0->smooth_n;
    float3  _S6 = - surface_0->smooth_n;
    float3  _S7 = _slang_select(_S3, _S6,_S5);
    FKRay _S8 = Ray_x24init_0(origin_1 + make_float3 (_S4) * _S7, dir_1);
    float3  _S9 = (fcptEnvMapSample((dir_1), (0U), (3U)));
    float3  _S10 = (fcptShadowTransmittance((_S8), (4.294967296e+09f)));
    return _S9 * _S10;
}

static __device__ uint searchCDF_0(uint2  start_0, uint2  step_0, uint count_0, float u_0)
{
    uint _S11 = count_0 - 1U;
    uint low_0 = 0U;
    uint high_0 = _S11;
    for(;;)
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        uint _S12 = (low_0 + high_0) / 2U;
        float4  _S13 = (fcptEnvironmentCdf((start_0 + step_0 * make_uint2 (_S12))));
        bool _S14 = (_S13.x) > u_0;
        if(_S14)
        {
            high_0 = _S12;
        }
        else
        {
            uint _S15 = _S12 + 1U;
            low_0 = _S15;
        }
    }
    return low_0;
}

struct ShadowContext
{
    float3  extinction_behind;
    float3  extinction_front;
    uint2  fillings;
    float3  side;
    uint depth;
    uint lobe;
    bool surface;
    float length;
    float width;
    FKHit own;
    bool fiber;
};

static __device__ float length_0(float3  x_1)
{
    return (F32_sqrt((dot_0(x_1, x_1))));
}

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

static __device__ FKHit Hit_x24init_0(float2  uv_0, uint instance_index_0, uint triangle_index_0, uint is_point_light_0, float distance_0)
{
    FKHit _S16;
    (&_S16)->uv = uv_0;
    (&_S16)->instance_index = instance_index_0;
    (&_S16)->triangle_index = triangle_index_0;
    (&_S16)->is_point_light = is_point_light_0;
    (&_S16)->distance = distance_0;
    return _S16;
}

static __device__ float3  lightTransmittance_0(float3  origin_2, float3  smooth_n_0, float geometry_offset_0, float3  light_dir_0, ShadowContext * context_0, uint random_state_0, FKHit * light_0)
{
    float3  _S17 = ((((light_dir_0)) * make_float3(rnorm3df(((light_dir_0)).x, ((light_dir_0)).y, ((light_dir_0)).z))));
    bool _S18 = (dot_0(smooth_n_0, _S17)) < 0.0f;
    if(_S18)
    {
        return make_float3 (0.0f);
    }
    float3  _S19 = make_float3 (geometry_offset_0) * smooth_n_0;
    float3  _S20 = origin_2 + _S19;
    FKRay _S21 = Ray_x24init_0(_S20, _S17);
    bool _S22 = (dot_0(context_0->side, light_dir_0 + _S19)) > 0.0f;
    float _S23 = shadowLength(light_dir_0);
    float3  _S24 = context_0->extinction_behind;
    float3  _S25 = context_0->extinction_front;
    float3  _S26 = _slang_select(_S22, _S25,_S24);
    uint _S27 = context_0->fillings.x;
    uint _S28 = context_0->fillings.y;
    uint _S29 = _slang_select(_S22, _S28,_S27);
    uint _S30 = context_0->depth;
    uint _S31 = context_0->lobe;
    bool _S32 = context_0->surface;
    bool _S33;
    if(_S32)
    {
        _S33 = !context_0->fiber;
    }
    else
    {
        _S33 = false;
    }
    float _S34 = context_0->length;
    float _S35 = context_0->width;
    FKHit _S36;
    if(context_0->fiber)
    {
        _S36 = context_0->own;
    }
    else
    {
        _S36 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    }
    float3  _S37 = (fcptShadowTransmittanceIn((_S21), (_S23), (_S26), (_S29), (random_state_0), (_S30), (_S31), (_S33), (_S34), (_S35), (_S36), (*light_0)));
    return _S37;
}

__device__ float sine(float c_0)
{
    return (F32_sqrt(((F32_max((1.0f - c_0 * c_0), (0.0f))))));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S38 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S39 = cos_a_0 > cos_b_0;
    float _S40 = _slang_select(_S39, 1.0f,_S38);
    return _S40;
}

__device__ float sinSubClamped(float sin_a_1, float cos_a_1, float sin_b_1, float cos_b_1)
{
    float _S41 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    bool _S42 = cos_a_1 > cos_b_1;
    float _S43 = _slang_select(_S42, 0.0f,_S41);
    return _S43;
}

__device__ float importance(LightNode node_0, float3  p_0, float3  normal_0)
{
    float3  _S44 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S45 = node_0.high - node_0.low;
    float3  _S46 = p_0 - _S44;
    float3  _S47 = ((((_S46)) * make_float3(rnorm3df(((_S46)).x, ((_S46)).y, ((_S46)).z))));
    float _S48 = dot_0(_S46, _S46);
    float _S49 = dot_0(_S45, _S45) / 4.0f;
    float _S50 = (F32_abs((dot_0(node_0.w, _S47))));
    float _S51 = sine(node_0.cos_theta_o);
    float _S52 = (F32_sqrt(((F32_max((1.0f - _S49 / _S48), (0.0f))))));
    bool _S53 = _S48 < _S49;
    float _S54 = _slang_select(_S53, -1.0f,_S52);
    float _S55 = sine(_S54);
    float _S56 = sine(_S50);
    float _S57 = cosSubClamped(_S56, _S50, _S51, node_0.cos_theta_o);
    float _S58 = sine(_S50);
    float _S59 = sinSubClamped(_S58, _S50, _S51, node_0.cos_theta_o);
    float _S60 = cosSubClamped(_S59, _S57, _S55, _S54);
    bool _S61 = _S60 <= 0.0f;
    if(_S61)
    {
        return 0.0f;
    }
    float _S62 = - dot_0(_S47, normal_0);
    float _S63 = node_0.phi * _S60 / (F32_max((_S48), (length_0(_S45) / 2.0f)));
    float _S64 = sine(_S62);
    float _S65 = cosSubClamped(_S64, _S62, _S55, _S54);
    bool _S66 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S67 = _slang_select(_S66, 1.0f,_S65);
    return (F32_max((_S63 * _S67), (0.0f)));
}

__device__ __forceinline__ float childShare(LightNode first_0, LightNode second_0, float3  p_1, float3  normal_1, uint child_0)
{
    float _S68 = importance(first_0, p_1, normal_1);
    float _S69 = importance(second_0, p_1, normal_1);
    float2  _S70 = make_float2 (_S68, _S69);
    float _S71 = _slang_vector_get_element(_S70, child_0) / (_S68 + _S69);
    bool _S72 = _slang_vector_get_element(_S70, child_0) > 0.0f;
    float _S73 = _slang_select(_S72, _S71,0.0f);
    return _S73;
}

__device__ float sphereDensity(float3  center_0, float radius_0, float3  p_2)
{
    float3  _S74 = center_0 - p_2;
    float _S75 = radius_0 * radius_0 / dot_0(_S74, _S74);
    bool _S76 = _S75 >= 1.0f;
    if(_S76)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S75)))) / (6.28318548202514648f * _S75);
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S77 = left_0.y;
    float _S78 = right_0.z;
    float _S79 = left_0.z;
    float _S80 = right_0.y;
    float _S81 = right_0.x;
    float _S82 = left_0.x;
    return make_float3 (_S77 * _S78 - _S79 * _S80, _S79 * _S81 - _S82 * _S78, _S82 * _S80 - _S77 * _S81);
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_0))));
}

static __device__ float lightPdf_0(float3  origin_3, float3  smooth_n_1, float3  start_1, uint j_0, float3  light_point_0)
{
    bool _S83 = j_0 == 4294967295U;
    if(_S83)
    {
        return 0.0f;
    }
    uint4  _S84 = (fcptLightTrail((j_0)));
    uint2  _S85 = uint2 {_S84.x, _S84.y};
    uint n_0 = 0U;
    uint2  trail_0 = _S85;
    float probability_1 = 1.0f;
    for(;;)
    {
        uint4  _S86 = (fcptLightNode((n_0)));
        if((_S86.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S87 = (fcptLightSecond((n_0)));
        uint _S88 = n_0 + 1U;
        LightNode _S89 = (fcptLightBounds((_S88)));
        LightNode _S90 = (fcptLightBounds((_S87)));
        uint _S91 = trail_0.x;
        uint _S92 = _S91 & 1U;
        float _S93 = childShare(_S89, _S90, origin_3, smooth_n_1, _S92);
        float probability_2 = probability_1 * _S93;
        bool _S94 = _S92 == 1U;
        uint _S95 = _slang_select(_S94, _S87,_S88);
        uint _S96 = trail_0.y;
        uint2  _S97 = make_uint2 ((_S91 >> 1U) | (_S96 << 31U), _S96 >> 1U);
        n_0 = _S95;
        trail_0 = _S97;
        probability_1 = probability_2;
    }
    bool _S98 = (fcptSlotLeaf((n_0), (j_0)));
    bool _S99 = !_S98;
    bool _S100;
    if(_S99)
    {
        _S100 = true;
    }
    else
    {
        LightNode _S101 = (fcptLightBounds((n_0)));
        float _S102 = importance(_S101, origin_3, smooth_n_1);
        _S100 = !(_S102 > 0.0f);
    }
    if(_S100)
    {
        _S100 = true;
    }
    else
    {
        bool _S103 = (dot_0(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S103)
        {
            _S100 = !((dot_0(smooth_n_1, light_point_0 - origin_3)) > 0.0f);
        }
        else
        {
            _S100 = false;
        }
    }
    if(_S100)
    {
        return 0.0f;
    }
    uint4  _S104 = (fcptLightNode((n_0)));
    bool _S105 = (_S104.x) == 2U;
    if(_S105)
    {
        uint _S106 = _S104.y;
        FKLight _S107 = (fcptLight((_S106)));
        FKLight _S108 = (fcptLight((_S106)));
        float _S109 = sphereDensity(_S107.position, _S108.variance, start_1);
        return probability_1 * _S109;
    }
    uint _S110 = _S104.y;
    uint _S111 = (fcptTriangleOffset((_S110)));
    Matrix<float, 3, 3>  _S112 = (fcptWorldTriangle((_S110), (_S111 + _S104.z)));
    float _S113 = solidAngle(probability_1, cross_0(_S112.rows[int(1)] - _S112.rows[int(0)], _S112.rows[int(2)] - _S112.rows[int(0)]), light_point_0 - start_1);
    return _S113;
}

struct SkySample
{
    float3  dir;
    float3  radiance;
    float3  color;
    uint random_state;
};

struct Random
{
    uint state;
    float value;
};

__device__ uint hash(uint x_2)
{
    uint _S114 = x_2 * 747796405U + 2891336453U;
    uint _S115 = ((_S114 >> ((_S114 >> 28U) + 4U)) ^ _S114) * 277803737U;
    return (_S115 >> 22U) ^ _S115;
}

static __device__ float random_0(uint * state_0)
{
    uint _S116 = hash(*state_0);
    *state_0 = _S116;
    return float((*state_0) >> int(8)) * 5.9604644775390625e-08f;
}

static __device__ Random Random_x24init_0(uint state_1, float value_0)
{
    Random _S117;
    (&_S117)->state = state_1;
    (&_S117)->value = value_0;
    return _S117;
}

__device__ Random pcg(uint state_2)
{
    uint _S118 = state_2;
    float value_1 = random_0(&_S118);
    return Random_x24init_0(_S118, value_1);
}

static __device__ float clamp_0(float x_3, float minBound_0, float maxBound_0)
{
    return (F32_min(((F32_max((x_3), (minBound_0)))), (maxBound_0)));
}

static __device__ uint2  min_0(uint2  x_4, uint2  y_1)
{
    uint2  result_0;
    int i_0 = int(0);
    for(;;)
    {
        if(i_0 < int(2))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_0, i_0) = (U32_min((_slang_vector_get_element(x_4, i_0)), (_slang_vector_get_element(y_1, i_0))));
        i_0 = i_0 + int(1);
    }
    return result_0;
}

static __device__ float dot_1(float2  x_5, float2  y_2)
{
    return x_5.x * y_2.x + x_5.y * y_2.y;
}

static __device__ float length_1(float2  x_6)
{
    return (F32_sqrt((dot_1(x_6, x_6))));
}

static __device__ float environmentPdf_0(float3  dir_2)
{
    uint2  _S119 = (fcptEnvironmentCdfSize());
    uint2  _S120 = _S119 - make_uint2 (1U, 0U);
    float2  _S121 = make_float2 ((F32_atan2((- dir_2.z), (- dir_2.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_0(dir_2.y, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S122 = make_float2 ((float)_S120.x, (float)_S120.y);
    float2  _S123 = _S121 * _S122;
    uint2  _S124 = make_uint2 ((uint)_S123.x, (uint)_S123.y);
    uint2  _S125 = min_0(_S124, _S120 - make_uint2 (1U));
    float4  _S126 = (fcptEnvironmentCdf((_S125)));
    float _S127 = _S126.y;
    uint _S128 = _S120.x;
    float4  _S129 = (fcptEnvironmentCdf((make_uint2 (_S128, _S125.y))));
    float _S130 = _S127 * _S129.y;
    return _S130 * float(_S128 * _S120.y) / (19.73921012878417969f * length_1(float2 {dir_2.x, dir_2.z}));
}

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

static __device__ float3  negate_0(float3  x_7)
{
    return - x_7;
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

static __device__ float sign_0(float e_0)
{
    float _S131;
    if(e_0 > 0.0f)
    {
        _S131 = 1.0f;
    }
    else
    {
        if(e_0 < 0.0f)
        {
            _S131 = -1.0f;
        }
        else
        {
            _S131 = 0.0f;
        }
    }
    return _S131;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S132;
    (&_S132)->tangent = tangent_0;
    (&_S132)->alphas = alphas_0;
    return _S132;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_0 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S133 = (F32_abs((dot_0(n_1, a_0)))) > 0.9999847412109375f;
    float3  a_1;
    if(_S133)
    {
        float3  _S134 = make_float3 (1.0f, 0.0f, 0.0f);
        a_1 = _S134;
    }
    else
    {
        a_1 = a_0;
    }
    float3  _S135 = cross_0(n_1, a_1);
    float3  _S136 = ((((_S135)) * make_float3(rnorm3df(((_S135)).x, ((_S135)).y, ((_S135)).z))));
    float3  _S137 = cross_0(n_1, _S136);
    return make_float3 (v_0.x) * _S136 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S137;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_0, float3  n_i_0)
{
    float _S138 = material_0.roughness;
    float _S139 = _S138 * _S138;
    bool _S140 = (material_0.anisotropy) == 0.0f;
    bool _S141;
    if(_S140)
    {
        _S141 = true;
    }
    else
    {
        _S141 = !(_S139 > 0.0f);
    }
    if(_S141)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S142 = material_0.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_0.tangent));
    float3  _S143 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S144 = (dot_0(_S142, _S142)) > 0.0f;
    float3  _S145 = _slang_select(_S144, _S142,_S143);
    float3  _S146 = ((((_S145)) * make_float3(rnorm3df(((_S145)).x, ((_S145)).y, ((_S145)).z))));
    float _S147 = 6.28318548202514648f * material_0.anisotropic_rotation;
    float _S148 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_0.anisotropy))))));
    float _S149 = 1.0f / _S148;
    bool _S150 = (material_0.anisotropy) < 0.0f;
    float _S151 = _slang_select(_S150, _S149,_S148);
    return AnisotropicFrame_x24init_0(_S146 * make_float3 ((F32_cos((_S147)))) + cross_0(n_i_0, _S146) * make_float3 ((F32_sin((_S147)))), make_float2 (_S139 / _S151, _S139 * _S151));
}

__device__ float3  anisotropicLocal(float3  w_0, float3  t_0, float3  n_2)
{
    return make_float3 (dot_0(w_0, t_0), dot_0(w_0, cross_0(n_2, t_0)), dot_0(w_0, n_2));
}

static __device__ float unshared_0(float x_8)
{
    return x_8;
}

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_0, float U1_0, float U2_0)
{
    float3  _S152 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S153 = ((((_S152)) * make_float3(rnorm3df(((_S152)).x, ((_S152)).y, ((_S152)).z))));
    float _S154 = _S153.x;
    float _S155 = _S153.y;
    float _S156 = _S154 * _S154 + _S155 * _S155;
    float3  _S157;
    if(_S156 > 0.0f)
    {
        float3  _S158 = make_float3 (- _S155, _S154, 0.0f);
        float _S159 = (rsqrtf((_S156)));
        _S157 = _S158 * make_float3 (_S159);
    }
    else
    {
        _S157 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S160 = cross_0(_S153, _S157);
    float _S161 = (F32_sqrt((U1_0)));
    float _S162 = 6.28318548202514648f * U2_0;
    float _S163 = _S161 * (F32_cos((_S162)));
    float t2_0 = _S161 * (F32_sin((_S162)));
    float _S164 = 0.5f * (1.0f + _S153.z);
    float t2_1 = (1.0f - _S164) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S163 * _S163)))))) + _S164 * t2_0;
    float3  _S165 = make_float3 (_S163) * _S157 + make_float3 (t2_1) * _S160;
    float _S166 = unshared_0(_S163);
    float _S167 = unshared_0(_S163);
    float3  _S168 = _S165 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S166 * _S167 - t2_1 * t2_1))))))) * _S153;
    float3  _S169 = make_float3 (alpha_0 * _S168.x, alpha_0 * _S168.y, (F32_max((0.0f), (_S168.z))));
    float3  _S170 = ((((_S169)) * make_float3(rnorm3df(((_S169)).x, ((_S169)).y, ((_S169)).z))));
    return _S170;
}

__device__ float3  sampleAnisotropicVNDF(float3  Ve_1, float2  alphas_1, float U1_1, float U2_1)
{
    float _S171 = alphas_1.x;
    float _S172 = alphas_1.y;
    float3  _S173 = make_float3 (_S171 * Ve_1.x, _S172 * Ve_1.y, Ve_1.z);
    float3  _S174 = ((((_S173)) * make_float3(rnorm3df(((_S173)).x, ((_S173)).y, ((_S173)).z))));
    float3  _S175 = sampleGGXVNDF(_S174, 1.0f, U1_1, U2_1);
    float3  _S176 = make_float3 (_S171 * _S175.x, _S172 * _S175.y, _S175.z);
    float3  _S177 = ((((_S176)) * make_float3(rnorm3df(((_S176)).x, ((_S176)).y, ((_S176)).z))));
    return _S177;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
{
    float3  a_2 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S178 = (F32_abs((dot_0(n_3, a_2)))) > 0.9999847412109375f;
    float3  a_3;
    if(_S178)
    {
        float3  _S179 = make_float3 (1.0f, 0.0f, 0.0f);
        a_3 = _S179;
    }
    else
    {
        a_3 = a_2;
    }
    float3  _S180 = cross_0(n_3, a_3);
    float3  _S181 = ((((_S180)) * make_float3(rnorm3df(((_S180)).x, ((_S180)).y, ((_S180)).z))));
    float3  _S182 = cross_0(n_3, _S181);
    return make_float3 (dot_0(v_1, _S181), dot_0(v_1, n_3), dot_0(v_1, _S182));
}

__device__ __forceinline__ float3  sampleMaterialHalfVector(float3  v_2, float3  n_i_1, float alpha_1, AnisotropicFrame frame_0, uint * random_state_1)
{
    Random _S183 = pcg(*random_state_1);
    Random _S184 = pcg(_S183.state);
    *random_state_1 = _S184.state;
    bool _S185 = (frame_0.alphas.x) > 0.0f;
    if(_S185)
    {
        float3  _S186 = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        float3  _S187 = sampleAnisotropicVNDF(_S186, frame_0.alphas, _S183.value, _S184.value);
        return make_float3 (_S187.x) * frame_0.tangent + make_float3 (_S187.y) * cross_0(n_i_1, frame_0.tangent) + make_float3 (_S187.z) * n_i_1;
    }
    float3  _S188 = worldToTangent(v_2, n_i_1);
    float3  _S189 = sampleGGXVNDF(float3 {_S188.x, _S188.z, _S188.y}, alpha_1, _S183.value, _S184.value);
    float3  _S190 = float3 {_S189.x, _S189.z, _S189.y};
    float3  _S191 = tangentToWorld(_S190, n_i_1);
    return _S191;
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
    float translucent_share;
    float3  sheen;
    float3  view;
    float3  tangent;
    float2  alphas;
    float visible;
};

static __device__ float3  refract_0(float3  i_1, float3  n_4, float eta_0)
{
    float _S192 = dot_0(n_4, i_1);
    float _S193 = 1.0f - eta_0 * eta_0 * (1.0f - _S192 * _S192);
    if(_S193 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_1 - make_float3 (eta_0 * _S192 + (F32_sqrt((_S193)))) * n_4;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S194 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S195 = eta_i_0 / eta_o_0 * _S194;
    bool _S196 = _S195 < 1.0f;
    float kr_0;
    if(_S196)
    {
        float _S197 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S195 * _S195))))));
        float _S198 = eta_o_0 * cos_theta_0;
        float _S199 = eta_i_0 * _S197;
        float _S200 = (_S198 - _S199) / (_S198 + _S199);
        float _S201 = eta_i_0 * cos_theta_0;
        float _S202 = eta_o_0 * _S197;
        float _S203 = (_S201 - _S202) / (_S201 + _S202);
        float _S204 = (_S200 * _S200 + _S203 * _S203) / 2.0f;
        kr_0 = _S204;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

__device__ static const FixedArray<float, 576>  SHEEN_ALBEDO_0 = { {
    0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f
} };
__device__ float sheenAlbedo(float mu_0, float r_0)
{
    float _S205 = (F32_sqrt((0.05000000074505806f)));
    float _S206 = clamp_0((F32_sqrt(((F32_max((mu_0), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
    float _S207 = (clamp_0((F32_sqrt(((F32_max((r_0), (0.0f)))))), _S205, 1.0f) - _S205) / (1.0f - _S205) * 23.0f;
    uint _S208 = (U32_min((uint(_S206)), (22U)));
    uint _S209 = (U32_min((uint(_S207)), (22U)));
    float _S210 = _S206 - float(_S208);
    float _S211 = _S207 - float(_S209);
    uint _S212 = _S208 * 24U + _S209;
    uint _S213 = _S212 + 24U;
    float _S214 = SHEEN_ALBEDO_0[_S212] + (SHEEN_ALBEDO_0[_S213] - SHEEN_ALBEDO_0[_S212]) * _S210;
    uint _S215 = _S212 + 1U;
    float _S216 = SHEEN_ALBEDO_0[_S215] + (SHEEN_ALBEDO_0[_S213 + 1U] - SHEEN_ALBEDO_0[_S215]) * _S210;
    return (F32_exp((_S214 + (_S216 - _S214) * _S211)));
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

__device__ float anisotropicG1(float3  w_1, float2  alphas_2)
{
    float _S217 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S217 / (_S217 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S217)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S218 = alphas_3.x;
    float _S219 = h_0.x / _S218;
    float _S220 = alphas_3.y;
    float _S221 = h_0.y / _S220;
    float _S222 = h_0.z;
    float _S223 = _S219 * _S219 + _S221 * _S221 + _S222 * _S222;
    return 1.0f / (F32_max((3.14159274101257324f * _S218 * _S220 * _S223 * _S223), (1.17549435082228751e-38f)));
}

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_0, float3  refracted_1, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_0, float3  sheen_0, float3  view_0, float3  tangent_1, float2  alphas_4, float visible_0)
{
    BSDFLobes _S224;
    (&_S224)->v_dot_h = v_dot_h_0;
    (&_S224)->n_dot_h = n_dot_h_0;
    (&_S224)->refracted = refracted_1;
    (&_S224)->F = F_0;
    (&_S224)->F_greyscale = F_greyscale_0;
    (&_S224)->reflect_weight = reflect_weight_0;
    (&_S224)->diffuse_weight = diffuse_weight_0;
    (&_S224)->refract_weight = refract_weight_0;
    (&_S224)->p_diffuse = p_diffuse_0;
    (&_S224)->p_reflect = p_reflect_0;
    (&_S224)->p_refract = p_refract_0;
    (&_S224)->translucent_share = translucent_share_0;
    (&_S224)->sheen = sheen_0;
    (&_S224)->view = view_0;
    (&_S224)->tangent = tangent_1;
    (&_S224)->alphas = alphas_4;
    (&_S224)->visible = visible_0;
    return _S224;
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_0, float3  v_3, float3  n_i_2, float3  ggx_n_0, BSDFMaterial material_1, float eta_i_1, float eta_o_1, AnisotropicFrame frame_1)
{
    float _S225 = dot_0(ggx_n_0, v_3);
    float _S226 = dot_0(n_i_2, ggx_n_0);
    float _S227 = eta_i_1 / eta_o_1;
    float3  _S228 = refract_0(in_dir_0, ggx_n_0, _S227);
    float3  _S229 = ((((_S228)) * make_float3(rnorm3df(((_S228)).x, ((_S228)).y, ((_S228)).z))));
    float _S230 = (F32_min(((F32_sqrt((material_1.specular_level))) * (F32_abs((eta_i_1 - eta_o_1))) / (eta_i_1 + eta_o_1)), (0.9999847412109375f)));
    float _S231 = _S230 * _S230;
    float _S232 = (1.0f + _S230) / (1.0f - _S230);
    float _S233 = (F32_abs((_S225)));
    bool _S234 = eta_i_1 > eta_o_1;
    float sheen_component_0;
    if(_S234)
    {
        sheen_component_0 = _S232;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float visible_1;
    if(_S234)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S232;
    }
    float _S235 = fresnel(_S233, sheen_component_0, visible_1);
    bool _S236 = (eta_i_1 * eta_i_1 * (1.0f - _S225 * _S225)) >= (eta_o_1 * eta_o_1);
    float3  _S237;
    if(_S236)
    {
        _S237 = make_float3 (1.0f);
    }
    else
    {
        float3  _S238 = material_1.specular_tint * make_float3 (_S231);
        _S237 = _S238 + (make_float3 (1.0f) - _S238) * make_float3 (_S235 - _S231) / make_float3 (1.0f - _S231);
    }
    float3  _S239 = make_float3 (1.0f);
    float3  _S240 = make_float3 (0.0f);
    float _S241 = rgb_to_greyscale(material_1.sheen);
    bool _S242 = _S241 > 0.0f;
    float3  scale_0;
    float3  sheen_1;
    float3  view_1;
    if(_S242)
    {
        float _S243 = sheenAlbedo(dot_0(n_i_2, v_3), material_1.sheen_roughness);
        float _S244 = (F32_min((_S243), (1.0f)));
        float3  _S245 = make_float3 (1.0f) - material_1.sheen * make_float3 (_S244);
        float _S246 = rgb_to_greyscale(material_1.sheen);
        float _S247 = _S246 * _S244;
        float3  _S248 = material_1.sheen / make_float3 ((F32_max((_S243), (1.0f))));
        scale_0 = _S245;
        sheen_component_0 = _S247;
        sheen_1 = _S248;
        view_1 = v_3;
    }
    else
    {
        scale_0 = _S239;
        sheen_component_0 = 0.0f;
        sheen_1 = _S240;
        view_1 = _S240;
    }
    float3  _S249 = mix_0(_S237, material_1.albedo, material_1.metallic);
    float3  F_1 = _S249 * scale_0;
    float _S250 = rgb_to_greyscale(F_1);
    float _S251 = 1.0f - material_1.metallic;
    float3  _S252 = make_float3 (1.0f) - _S237;
    float3  _S253 = make_float3 ((1.0f - material_1.transmission) * _S251) * _S252 * scale_0;
    float3  _S254 = make_float3 (material_1.transmission * _S251) * _S252 * scale_0;
    float _S255 = (F32_max((_S250), (0.0f)));
    float _S256 = rgb_to_greyscale(_S253);
    float _S257 = (F32_max((_S256), (0.0f)));
    float _S258 = rgb_to_greyscale(_S254);
    float _S259 = sign_0(length_0(_S229));
    float _S260 = (F32_max((_S258 * _S259), (0.0f)));
    float _S261 = _S255 + _S257 + _S260 + sheen_component_0;
    float _S262 = 1.0f / (F32_max((_S261), (0.0000152587890625f)));
    float _S263 = (_S257 + sheen_component_0) * _S262;
    float _S264 = _S255 * _S262;
    float _S265 = _S260 * _S262;
    bool _S266 = (frame_1.alphas.x) > 0.0f;
    if(_S266)
    {
        float3  _S267 = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        float _S268 = anisotropicG1(_S267, frame_1.alphas);
        float3  _S269 = anisotropicLocal(ggx_n_0, frame_1.tangent, n_i_2);
        float _S270 = anisotropicD(_S269, frame_1.alphas);
        float _S271 = _S268 * _S270;
        visible_1 = _S271;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S225, _S226, _S229, F_1, _S250, 1.0f, _S253, _S254, _S263, _S264, _S265, 0.0f, sheen_1, view_1, frame_1.tangent, frame_1.alphas, visible_1);
}

__device__ float translucentShare(BSDFMaterial material_2)
{
    float _S272 = rgb_to_greyscale(material_2.translucent);
    float _S273 = rgb_to_greyscale(material_2.albedo);
    float _S274 = _S272 / (_S273 + _S272);
    bool _S275 = _S272 > 0.0f;
    float _S276 = _slang_select(_S275, _S274,0.0f);
    return _S276;
}

__device__ float smithG1(float alpha_2, float n_dot_x_0)
{
    float _S277 = alpha_2 * alpha_2;
    float _S278 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S277 + (1.0f - _S277) * n_dot_x_0 * n_dot_x_0))));
    bool _S279 = alpha_2 > 0.0f;
    float _S280 = _slang_select(_S279, _S278,1.0f);
    return _S280;
}

__device__ float trowbridgeReitz(float alpha_3, float n_dot_h_1)
{
    float _S281 = alpha_3 * alpha_3;
    float _S282 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S281 * n_dot_h_1 * n_dot_h_1;
    return _S281 / (F32_max((3.14159274101257324f * _S282 * _S282), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, BSDFLobes lobes_0, float eta_i_2, float eta_o_2, uint lobe_0)
{
    bool _S283 = lobe_0 == 0U;
    if(_S283)
    {
        float _S284 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        float _S285 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
        float _S286 = 1.0f - lobes_0.translucent_share;
        bool _S287 = n_i_dot_l_0 < 0.0f;
        float _S288 = _slang_select(_S287, lobes_0.translucent_share,_S286);
        float _S289 = _S285 * _S288;
        bool _S290 = (lobes_0.translucent_share) > 0.0f;
        float _S291 = _slang_select(_S290, _S289,_S284);
        bool _S292 = n_i_dot_v_0 > 0.0f;
        float _S293 = _slang_select(_S292, _S291,0.0f);
        return _S293;
    }
    float _S294 = smithG1(alpha_4, n_i_dot_v_0);
    float _S295 = _S294 * lobes_0.v_dot_h;
    float _S296 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    float _S297 = _S295 * _S296 / n_i_dot_v_0;
    bool _S298 = alpha_4 > 0.0f;
    bool _S299;
    if(_S298)
    {
        _S299 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S299 = false;
    }
    if(_S299)
    {
        _S299 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S299 = false;
    }
    if(_S299)
    {
        _S299 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S299 = false;
    }
    float _S300 = _slang_select(_S299, _S297,0.0f);
    bool _S301 = (lobes_0.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S301)
    {
        float _S302 = lobes_0.visible * lobes_0.v_dot_h / n_i_dot_v_0;
        bool _S303 = (lobes_0.v_dot_h) > 0.0f;
        if(_S303)
        {
            _S299 = (lobes_0.n_dot_h) > 0.0f;
        }
        else
        {
            _S299 = false;
        }
        if(_S299)
        {
            _S299 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S299 = false;
        }
        float _S304 = _slang_select(_S299, _S302,0.0f);
        pdf_h_0 = _S304;
    }
    else
    {
        pdf_h_0 = _S300;
    }
    bool _S305 = lobe_0 == 1U;
    if(_S305)
    {
        float _S306 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        float _S307 = lobes_0.p_refract * pdf_h_0 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S306 * _S306);
        bool _S308 = eta_i_2 != eta_o_2;
        if(_S308)
        {
            _S299 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S299 = false;
        }
        float _S309 = _slang_select(_S299, _S307,0.0f);
        return _S309;
    }
    float _S310 = lobes_0.p_reflect * pdf_h_0 / (4.0f * lobes_0.v_dot_h);
    bool _S311 = pdf_h_0 > 0.0f;
    float _S312 = _slang_select(_S311, _S310,0.0f);
    return _S312;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_0, uint random_state_2, bool refracted_2, uint lobe_1, float pdf_0)
{
    SampleBSDF _S313;
    (&_S313)->unit_direction = unit_direction_1;
    (&_S313)->throughput = throughput_0;
    (&_S313)->random_state = random_state_2;
    (&_S313)->refracted = refracted_2;
    (&_S313)->lobe = lobe_1;
    (&_S313)->pdf = pdf_0;
    return _S313;
}

__device__ float sheenBRDF(float3  l_0, float3  v_4, float3  n_5, float r_1)
{
    float _S314 = 1.0f / (F32_max((r_1), (0.05000000074505806f)));
    float3  _S315 = l_0 + v_4;
    float3  _S316 = ((((_S315)) * make_float3(rnorm3df(((_S315)).x, ((_S315)).y, ((_S315)).z))));
    float _S317 = dot_0(n_5, _S316);
    float _S318 = (F32_max((dot_0(n_5, l_0)), (0.0f)));
    float _S319 = (F32_max((dot_0(n_5, v_4)), (0.0f)));
    return (2.0f + _S314) * (F32_pow(((F32_max((1.0f - _S317 * _S317), (0.0f)))), (0.5f * _S314))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S318 + _S319 - _S318 * _S319)), (0.0000152587890625f)));
}

__device__ __forceinline__ float3  lobeThroughput(float3  l_1, float3  n_i_3, float alpha_5, BSDFMaterial material_3, BSDFLobes lobes_1, uint lobe_2)
{
    bool _S320 = lobe_2 == 0U;
    if(_S320)
    {
        bool _S321 = (dot_0(n_i_3, l_1)) < 0.0f;
        float3  _S322 = _slang_select(_S321, material_3.translucent,material_3.albedo);
        float _S323 = 1.0f - lobes_1.translucent_share;
        float _S324 = _slang_select(_S321, lobes_1.translucent_share,_S323);
        float3  _S325 = _S322 / make_float3 (_S324);
        bool _S326 = (lobes_1.translucent_share) > 0.0f;
        float3  _S327 = _slang_select(_S326, _S325,material_3.albedo);
        float _S328 = rgb_to_greyscale(material_3.sheen);
        bool _S329 = _S328 > 0.0f;
        bool _S330;
        if(_S329)
        {
            _S330 = !_S321;
        }
        else
        {
            _S330 = false;
        }
        if(_S330)
        {
            float3  _S331 = lobes_1.diffuse_weight * _S327;
            float3  _S332 = lobes_1.sheen * make_float3 (3.14159274101257324f);
            float _S333 = sheenBRDF(l_1, lobes_1.view, n_i_3, material_3.sheen_roughness);
            float3  _S334 = _S332 * make_float3 (_S333);
            float _S335 = _slang_select(_S326, _S323,1.0f);
            return (_S331 + _S334 / make_float3 (_S335)) / make_float3 (lobes_1.p_diffuse);
        }
        return lobes_1.diffuse_weight * _S327 / make_float3 (lobes_1.p_diffuse);
    }
    bool _S336 = lobe_2 == 1U;
    float G1_l_0;
    if(_S336)
    {
        float _S337 = - dot_0(n_i_3, l_1);
        float _S338 = smithG1(alpha_5, (F32_max((_S337), (0.0f))));
        bool _S339 = (lobes_1.alphas.x) > 0.0f;
        if(_S339)
        {
            float3  _S340 = negate_0(n_i_3);
            float3  _S341 = anisotropicLocal(l_1, lobes_1.tangent, _S340);
            float _S342 = anisotropicG1(_S341, lobes_1.alphas);
            G1_l_0 = _S342;
        }
        else
        {
            G1_l_0 = _S338;
        }
        return lobes_1.refract_weight * make_float3 (G1_l_0) * material_3.albedo / make_float3 (lobes_1.p_refract);
    }
    float _S343 = dot_0(n_i_3, l_1);
    float _S344 = smithG1(alpha_5, (F32_max((_S343), (0.0f))));
    bool _S345 = (lobes_1.alphas.x) > 0.0f;
    if(_S345)
    {
        float3  _S346 = anisotropicLocal(l_1, lobes_1.tangent, n_i_3);
        float _S347 = anisotropicG1(_S346, lobes_1.alphas);
        G1_l_0 = _S347;
    }
    else
    {
        G1_l_0 = _S344;
    }
    return make_float3 (lobes_1.reflect_weight * G1_l_0) * lobes_1.F / make_float3 (lobes_1.p_reflect);
}

__device__ __forceinline__ SampleBSDF connectBSDF(float3  in_dir_1, float3  out_dir_0, float3  n_6, BSDFMaterial material_4, float eta_i_3, float eta_o_3, uint lobe_3, uint random_init_0)
{
    uint random_state_3 = random_init_0;
    float3  _S348 = negate_0(in_dir_1);
    float _S349 = dot_0(n_6, _S348);
    float _S350 = sign_0(_S349);
    float3  _S351 = n_6 * make_float3 (_S350);
    float _S352 = material_4.roughness;
    float _S353 = _S352 * _S352;
    AnisotropicFrame _S354 = anisotropicFrame(material_4, _S351);
    float3  _S355 = _S348 + out_dir_0;
    float3  _S356 = ((((_S355)) * make_float3(rnorm3df(((_S355)).x, ((_S355)).y, ((_S355)).z))));
    bool _S357 = lobe_3 == 0U;
    float3  ggx_n_1;
    if(_S357)
    {
        float3  _S358 = sampleMaterialHalfVector(_S348, _S351, _S353, _S354, &random_state_3);
        ggx_n_1 = _S358;
    }
    else
    {
        bool _S359 = lobe_3 == 1U;
        if(_S359)
        {
            float3  _S360 = negate_0(make_float3 (eta_i_3) * _S348 + make_float3 (eta_o_3) * out_dir_0);
            float3  _S361 = ((((_S360)) * make_float3(rnorm3df(((_S360)).x, ((_S360)).y, ((_S360)).z))));
            float _S362 = sign_0(dot_0(_S360, _S351));
            float3  _S363 = _S361 * make_float3 (_S362);
            ggx_n_1 = _S363;
        }
        else
        {
            ggx_n_1 = _S356;
        }
    }
    BSDFLobes _S364 = bsdfLobes(in_dir_1, _S348, _S351, ggx_n_1, material_4, eta_i_3, eta_o_3, _S354);
    BSDFLobes lobes_2 = _S364;
    float _S365 = translucentShare(material_4);
    (&lobes_2)->translucent_share = _S365;
    float _S366 = lobeDensity(dot_0(_S351, out_dir_0), dot_0(out_dir_0, ggx_n_1), (F32_abs((_S349))), _S353, lobes_2, eta_i_3, eta_o_3, lobe_3);
    bool _S367 = !(_S366 > 0.0f);
    if(_S367)
    {
        float3  _S368 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S368, _S368, 0U, false, 0U, 0.0f);
    }
    float3  _S369 = lobeThroughput(out_dir_0, _S351, _S353, material_4, lobes_2, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S369, random_state_3, lobe_3 == 1U, lobe_3, _S366);
}

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_2, float3  dir_3, float3  n_7, BSDFMaterial material_5, float eta_i_4, float eta_o_4, bool refracted_3, float pdf_1, bool power_0, uint random_state_4)
{
    float3  _S370 = make_float3 (0.0f);
    uint lobe_4 = 0U;
    float3  f_0 = _S370;
    for(;;)
    {
        if(lobe_4 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S371 = lobe_4 == 0U;
        if(_S371)
        {
        }
        bool _S372;
        if(_S371)
        {
            float _S373 = rgb_to_greyscale(material_5.translucent);
            _S372 = _S373 > 0.0f;
        }
        else
        {
            _S372 = false;
        }
        bool _S374;
        if(_S372)
        {
            float _S375 = dot_0(n_7, dir_3);
            float3  _S376 = negate_0(in_dir_2);
            _S374 = ((_S375 * dot_0(n_7, _S376)) < 0.0f) == refracted_3;
        }
        else
        {
            _S374 = (lobe_4 == 1U) == refracted_3;
        }
        float3  f_1;
        if(_S374)
        {
            SampleBSDF _S377 = connectBSDF(in_dir_2, dir_3, n_7, material_5, eta_i_4, eta_o_4, lobe_4, random_state_4);
            bool _S378 = (_S377.pdf) > 0.0f;
            if(_S378)
            {
                if(power_0)
                {
                    float _S379 = _S377.pdf / pdf_1;
                    float3  f_2 = f_0 + _S377.throughput * make_float3 (_S377.pdf) / make_float3 (pdf_1 * (1.0f + _S379 * _S379));
                    f_1 = f_2;
                }
                else
                {
                    float3  f_3 = f_0 + _S377.throughput * make_float3 (_S377.pdf) / make_float3 (_S377.pdf + pdf_1);
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

__device__ float3  skyBSDF(float3  in_dir_3, float3  dir_4, FKSurface surface_1, float2  eta_1, bool is_inside_2, float pdf_2, uint random_state_5)
{
    bool _S380 = wrongSide_0(is_inside_2, false, dir_4, surface_1.geometry_n);
    float3  _S381 = neeBSDF(in_dir_3, dir_4, surface_1.smooth_n, surface_1.material, eta_1.x, eta_1.y, _S380, pdf_2, false, random_state_5);
    return _S381;
}

static __device__ bool all_0(bool3  x_9)
{
    bool result_1 = true;
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
        if(result_1)
        {
            result_1 = (bool((_slang_vector_get_element(x_9, i_2))));
        }
        else
        {
            result_1 = false;
        }
        i_2 = i_2 + int(1);
    }
    return result_1;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_6)
{
    SkySample _S382;
    (&_S382)->dir = dir_5;
    (&_S382)->radiance = radiance_0;
    (&_S382)->color = color_0;
    (&_S382)->random_state = random_state_6;
    return _S382;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0)
{
    uint2  _S383 = (fcptEnvironmentCdfSize());
    uint2  _S384 = make_uint2 (1U, 0U);
    uint2  _S385 = _S383 - _S384;
    Random _S386 = pcg(init_random_state_0);
    Random _S387 = pcg(_S386.state);
    Random _S388 = pcg(_S387.state);
    Random _S389 = pcg(_S388.state);
    uint _S390 = _S385.x;
    uint _S391 = searchCDF_0(make_uint2 (_S390, 0U), make_uint2 (0U, 1U), _S385.y, _S386.value);
    uint _S392 = searchCDF_0(make_uint2 (0U, _S391), _S384, _S390, _S387.value);
    float2  _S393 = make_float2 ((float)_S385.x, (float)_S385.y);
    float2  _S394 = (make_float2 (float(_S392), float(_S391)) + make_float2 (_S388.value, _S389.value)) / _S393 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S395 = _S394.y;
    float _S396 = (F32_sin((_S395)));
    float _S397 = _S394.x;
    float3  _S398 = make_float3 (_S396 * (F32_cos((_S397))), (F32_cos((_S395))), _S396 * (F32_sin((_S397))));
    float _S399 = environmentPdf_0(_S398);
    float3  _S400 = skyBSDF(ray_0->unit_direction, _S398, *surface_2, eta_2, is_inside_3, _S399, lobe_state_0);
    bool _S401 = !(_S399 > 0.0f);
    bool _S402;
    if(_S401)
    {
        _S402 = true;
    }
    else
    {
        _S402 = all_0(_S400 == make_float3 (0.0f));
    }
    if(_S402)
    {
        float3  _S403 = make_float3 (0.0f);
        return SkySample_x24init_0(_S398, _S403, _S403, _S389.state);
    }
    float3  _S404 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S398);
    return SkySample_x24init_0(_S398, _S404, _S400 * _S404, _S389.state);
}

struct TreeSample
{
    float3  dir;
    float3  radiance;
    float density;
    uint random_state;
};

static __device__ float3  hairLight_0(FKSurface * surface_3, float3  in_dir_4, TreeSample * light_1, bool competing_0)
{
    SampleBSDF _S405 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_4), (light_1->dir)));
    float3  _S406 = _S405.throughput * make_float3 (_S405.pdf);
    float _S407 = light_1->density;
    float _S408 = 1.0f + _S405.pdf * _S405.pdf / (light_1->density * light_1->density);
    bool _S409;
    if(competing_0)
    {
        _S409 = _S407 > 0.0f;
    }
    else
    {
        _S409 = false;
    }
    float _S410 = _slang_select(_S409, _S408,1.0f);
    return _S406 / make_float3 (_S410) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_7)
{
    TreeSample _S411;
    (&_S411)->dir = dir_6;
    (&_S411)->radiance = radiance_1;
    (&_S411)->density = density_0;
    (&_S411)->random_state = random_state_7;
    return _S411;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_3, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S412 = importance(first_1, p_3, normal_3);
    float _S413 = importance(second_1, p_3, normal_3);
    float2  _S414 = make_float2 (_S412, _S413);
    bool _S415 = _S412 == 0.0f;
    bool _S416;
    if(_S415)
    {
        _S416 = _S413 == 0.0f;
    }
    else
    {
        _S416 = false;
    }
    if(_S416)
    {
        return 2U;
    }
    float _S417 = _S412 + _S413;
    bool _S418 = _S413 > 0.0f;
    if(_S418)
    {
        _S416 = (*pick_0 * _S417) >= _S412;
    }
    else
    {
        _S416 = false;
    }
    uint _S419 = uint(_S416);
    float _S420 = (F32_min(((*pick_0 * _S417 - float(_S419) * _S412) / _slang_vector_get_element(_S414, _S419)), (0.99999994039535522f)));
    *pick_0 = _S420;
    float _S421 = *probability_3 * (_slang_vector_get_element(_S414, _S419) / _S417);
    *probability_3 = _S421;
    return _S419;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_4, float u1_0, float u2_0)
{
    float3  _S422 = center_1 - p_4;
    float _S423 = radius_1 * radius_1 / dot_0(_S422, _S422);
    float _S424 = u1_0 * _S423 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S423), (0.0f)))))));
    float _S425 = 2.0f * u1_0;
    bool _S426 = _S423 >= 1.0f;
    float _S427 = _slang_select(_S426, _S425,_S424);
    float _S428 = (F32_sqrt(((F32_max((_S427 * (2.0f - _S427)), (0.0f))))));
    float _S429 = 6.28318548202514648f * u2_0;
    float3  _S430 = make_float3 (_S428 * (F32_cos((_S429))), 1.0f - _S427, _S428 * (F32_sin((_S429))));
    float3  _S431 = ((((_S422)) * make_float3(rnorm3df(((_S422)).x, ((_S422)).y, ((_S422)).z))));
    float3  _S432 = tangentToWorld(_S430, _S431);
    return _S432;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S433 = center_2 - ray_1->origin;
    float _S434 = dot_0(_S433, ray_1->unit_direction);
    float _S435 = dot_0(_S433, _S433) - _S434 * _S434;
    float _S436 = radius_3 * radius_3;
    bool _S437 = _S435 > _S436;
    if(_S437)
    {
        return 4.294967296e+09f;
    }
    float _S438 = (F32_sqrt((_S436 - _S435)));
    float _S439 = _S434 - _S438;
    float _S440 = _S434 + _S438;
    bool _S441 = _S439 > 0.0000152587890625f;
    bool _S442;
    if(_S441)
    {
        _S442 = _S439 < max_len_0;
    }
    else
    {
        _S442 = false;
    }
    if(_S442)
    {
        return _S439;
    }
    bool _S443 = _S440 > 0.0000152587890625f;
    if(_S443)
    {
        _S442 = _S440 < max_len_0;
    }
    else
    {
        _S442 = false;
    }
    if(_S442)
    {
        return _S440;
    }
    return 4.294967296e+09f;
}

static __device__ float3  mul_0(float3  left_1, Matrix<float, 3, 3>  right_1)
{
    float3  result_2;
    int j_1 = int(0);
    for(;;)
    {
        if(j_1 < int(3))
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
            float sum_1 = sum_0 + _slang_vector_get_element(left_1, i_3) * _slang_vector_get_element(right_1.rows[i_3], j_1);
            i_3 = i_3 + int(1);
            sum_0 = sum_1;
        }
        *_slang_vector_get_element_ptr(&result_2, j_1) = sum_0;
        j_1 = j_1 + int(1);
    }
    return result_2;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_1)
{
    Random _S444 = pcg(init_random_state_1);
    Random _S445 = pcg(_S444.state);
    Random _S446 = pcg(_S445.state);
    float3  _S447 = make_float3 (0.0f);
    TreeSample _S448 = TreeSample_x24init_0(_S447, _S447, 0.0f, _S446.state);
    TreeSample sample_0 = _S448;
    float3  _S449 = _slang_select(sided_0, _S447,smooth_n_2);
    float3  _S450 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S444.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S451 = (fcptLightNode((n_8)));
        if((_S451.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S452 = (fcptLightSecond((n_8)));
        uint _S453 = n_8 + 1U;
        LightNode _S454 = (fcptLightBounds((_S453)));
        LightNode _S455 = (fcptLightBounds((_S452)));
        uint _S456 = pickChild(_S454, _S455, origin_4, _S449, &pick_1, &probability_4);
        bool _S457 = _S456 > 1U;
        if(_S457)
        {
            return sample_0;
        }
        bool _S458 = _S456 == 1U;
        uint _S459 = _slang_select(_S458, _S452,_S453);
        n_8 = _S459;
    }
    bool _S460 = n_8 == 0U;
    bool _S461;
    if(_S460)
    {
        LightNode _S462 = (fcptLightBounds((0U)));
        float _S463 = importance(_S462, origin_4, _S449);
        _S461 = !(_S463 > 0.0f);
    }
    else
    {
        _S461 = false;
    }
    if(_S461)
    {
        return sample_0;
    }
    uint4  _S464 = (fcptLightNode((n_8)));
    FKHit _S465 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S466 = (_S464.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S466)
    {
        FKLight _S467 = (fcptLight((_S464.y)));
        if(sided_0)
        {
            float _S468 = sign_0(dot_0(geometry_n_1, _S467.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S468);
            float3  _S469 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S469;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S450;
            lift_n_0 = smooth_n_2;
        }
        bool _S470 = (_S467.variance) == 0.0f;
        if(_S470)
        {
            float3  _S471 = _S467.position - emitter_point_0;
            float3  _S472 = ((((_S471)) * make_float3(rnorm3df(((_S471)).x, ((_S471)).y, ((_S471)).z))));
            (&sample_0)->dir = _S472;
            float3  _S473 = _S467.color * make_float3 (_S467.intensity) / make_float3 (dot_0(_S471, _S471) * probability_4);
            (&sample_0)->radiance = _S473;
            shadow_1 = _S471;
        }
        else
        {
            float3  _S474 = sampleSphere(_S467.position, _S467.variance, emitter_point_0, _S445.value, _S446.value);
            (&sample_0)->dir = _S474;
            float _S475 = sphereDensity(_S467.position, _S467.variance, emitter_point_0);
            float _S476 = probability_4 * _S475;
            (&sample_0)->density = _S476;
            float3  _S477 = pointLightRadiance(_S467.color, _S467.intensity, _S467.variance);
            float3  _S478 = _S477 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S478;
            FKRay _S479 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S480 = raySphere_0(_S467.position, _S467.variance, &_S479, 4.294967296e+09f);
            float3  _S481 = (&sample_0)->dir * make_float3 (_S480);
            shadow_1 = _S481;
        }
        emitter_0 = _S465;
        emitter_point_0 = _S447;
    }
    else
    {
        uint _S482 = _S464.y;
        uint _S483 = (fcptTriangleOffset((_S482)));
        uint _S484 = _S483 + _S464.z;
        Matrix<float, 3, 3>  _S485 = (fcptWorldTriangle((_S482), (_S484)));
        float _S486 = (F32_sqrt((_S445.value)));
        float2  _S487 = make_float2 (_S486 * (1.0f - _S446.value), _S486 * _S446.value);
        float3  _S488 = mul_0(make_float3 (1.0f - _S486, _S487.x, _S487.y), _S485);
        if(sided_0)
        {
            float _S489 = sign_0(dot_0(geometry_n_1, _S488 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S489);
            float3  _S490 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S490;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S491 = !((dot_0(smooth_n_2, _S488 - origin_4)) > 0.0f);
            if(_S491)
            {
                return sample_0;
            }
            emitter_point_0 = _S450;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S487, _S482, _S484, 0U, 0.0f);
        float3  _S492 = _S488 - emitter_point_0;
        float3  _S493 = ((((_S492)) * make_float3(rnorm3df(((_S492)).x, ((_S492)).y, ((_S492)).z))));
        (&sample_0)->dir = _S493;
        float _S494 = solidAngle(probability_4, cross_0(_S485.rows[int(1)] - _S485.rows[int(0)], _S485.rows[int(2)] - _S485.rows[int(0)]), _S492);
        (&sample_0)->density = _S494;
        bool _S495 = (fcptShadowFirst());
        bool _S496 = !_S495;
        if(_S496)
        {
            FKSurface _S497 = (fcptLightSurfaceAt((emitter_1), (_S488), (_S446.state), ((&sample_0)->dir), (context_1->depth), (length_0(_S488 - origin_4))));
            (&sample_0)->random_state = _S497.random_state;
            float3  _S498 = _slang_select(_S497.skip, _S447,_S497.material.emissive);
            float3  _S499 = _S498 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S499;
        }
        shadow_1 = _S492;
        emitter_0 = emitter_1;
        emitter_point_0 = _S488;
    }
    FKHit _S500 = emitter_0;
    float3  _S501 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_1, _S446.state, &_S500);
    bool _S502 = (fcptShadowFirst());
    if(_S502)
    {
        _S461 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S461 = false;
    }
    if(_S461)
    {
        _S461 = !all_0(_S501 == _S447);
    }
    else
    {
        _S461 = false;
    }
    if(_S461)
    {
        FKSurface _S503 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S446.state), ((&sample_0)->dir), (context_1->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S503.random_state;
        float3  _S504 = _slang_select(_S503.skip, _S447,_S503.material.emissive);
        float3  _S505 = _S504 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S505;
    }
    float3  _S506 = (&sample_0)->radiance * _S501;
    bool _S507 = all_0(_S501 == _S447);
    float3  _S508 = _slang_select(_S507, _S447,_S506);
    (&sample_0)->radiance = _S508;
    return sample_0;
}

struct NEEVertex
{
    bool none;
    float pdf;
    float3  origin;
    float3  smooth_n;
    float3  start;
};

__device__ float powerHeuristic(float a_4, float b_0)
{
    float _S509 = 1.0f / (1.0f + b_0 / a_4 * (b_0 / a_4));
    bool _S510 = b_0 > 0.0f;
    float _S511 = _slang_select(_S510, _S509,1.0f);
    return _S511;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_0, float3  light_point_1)
{
    bool _S512 = vertex_0->none;
    if(_S512)
    {
        return 1.0f;
    }
    uint _S513 = (fcptLightSlot((*hit_0)));
    float _S514 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S513, light_point_1);
    float _S515 = powerHeuristic(vertex_0->pdf, _S514);
    return _S515;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_6)
{
    uint2  _S516 = (fcptEnvironmentMapSize());
    bool _S517 = (_S516.x) > 1U;
    bool _S518;
    if(_S517)
    {
        uint2  _S519 = (fcptEnvironmentMapSize());
        _S518 = (_S519.y) > 1U;
    }
    else
    {
        _S518 = false;
    }
    if(_S518)
    {
        float3  _S520 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_6)));
        return _S520;
    }
    float3  _S521 = (fcptAmbient());
    return _S521;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S522 = (fcptEnvironmentCdfSize());
    bool _S523 = (_S522.x) > 1U;
    bool _S524;
    if(_S523)
    {
        uint2  _S525 = (fcptEnvironmentCdfSize());
        _S524 = (_S525.y) > 1U;
    }
    else
    {
        _S524 = false;
    }
    bool _S526 = !_S524;
    if(_S526)
    {
        return false;
    }
    uint2  _S527 = (fcptEnvironmentMapSize());
    bool _S528 = (_S527.x) > 1U;
    if(_S528)
    {
        uint2  _S529 = (fcptEnvironmentMapSize());
        _S524 = (_S529.y) > 1U;
    }
    else
    {
        _S524 = false;
    }
    return _S524;
}

static __device__ float escapeWeight_0(float pdf_3, float3  dir_8)
{
    bool _S530 = pdf_3 <= 0.0f;
    bool _S531;
    if(_S530)
    {
        _S531 = true;
    }
    else
    {
        bool _S532 = environmentMapped_0();
        _S531 = !_S532;
    }
    if(_S531)
    {
        return 1.0f;
    }
    float _S533 = environmentPdf_0(dir_8);
    return pdf_3 / (pdf_3 + _S533);
}

static __device__ float3  min_1(float3  x_10, float3  y_3)
{
    float3  result_3;
    int i_4 = int(0);
    for(;;)
    {
        if(i_4 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_3, i_4) = (F32_min((_slang_vector_get_element(x_10, i_4)), (_slang_vector_get_element(y_3, i_4))));
        i_4 = i_4 + int(1);
    }
    return result_3;
}

struct Domain
{
    float3  x0;
    float3  x1;
    FKHit hit;
    float width;
    float spread;
};

struct Selection
{
    Reservoir r;
    float w_sum;
    float3  color;
    uint random_state;
    float3  glow;
    bool sums;
};

static __device__ Shift Shift_x24init_0(float3  f_4, float jac_0)
{
    Shift _S534;
    (&_S534)->f = f_4;
    (&_S534)->jac = jac_0;
    return _S534;
}

static __device__ uint extractBits_0(uint e_1, uint offset_0, uint count_1)
{
    return (e_1 >> offset_0) & ((1U << count_1) - 1U);
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_2)
{
    NEEVertex _S535;
    (&_S535)->none = none_0;
    (&_S535)->pdf = pdf_4;
    (&_S535)->origin = origin_5;
    (&_S535)->smooth_n = smooth_n_3;
    (&_S535)->start = start_2;
    return _S535;
}

struct Vertex
{
    bool rough;
    uint lobe;
    float pdf;
    float cos;
    bool inside;
};

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_7, float pdf_5, float cos_0, bool inside_0)
{
    Vertex _S536;
    (&_S536)->rough = rough_0;
    (&_S536)->lobe = lobe_7;
    (&_S536)->pdf = pdf_5;
    (&_S536)->cos = cos_0;
    (&_S536)->inside = inside_0;
    return _S536;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S537 = hash(index_0);
    uint _S538 = hash(seed_0 ^ _S537);
    return _S538;
}

static __device__ float freeFlight_0(float u_1, float sigma_0)
{
    return - (F32_log((1.0f - u_1))) / sigma_0;
}

static __device__ float3  exp_0(float3  x_11)
{
    float3  result_4;
    int i_5 = int(0);
    for(;;)
    {
        if(i_5 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_4, i_5) = (F32_exp((_slang_vector_get_element(x_11, i_5))));
        i_5 = i_5 + int(1);
    }
    return result_4;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_1, float distance_1, bool scatters_0)
{
    float3  _S539 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_1));
    float3  _S540 = scatter_0 * _S539 / make_float3 (sigma_1);
    float3  _S541 = _slang_select(scatters_0, _S540,_S539);
    return _S541;
}

static __device__ bool scatterSampled_0(bool replay_0, uint b_1, uint stop_0, bool varying_0)
{
    bool _S542 = !replay_0;
    bool _S543;
    if(_S542)
    {
        _S543 = true;
    }
    else
    {
        bool _S544 = b_1 == stop_0;
        if(_S544)
        {
            _S543 = !varying_0;
        }
        else
        {
            _S543 = false;
        }
    }
    return _S543;
}

static __device__ uint arrivalLobe_0(uint b_2, uint prev_lobe_0)
{
    bool _S545 = b_2 > 0U;
    uint _S546 = _slang_select(_S545, prev_lobe_0,3U);
    return _S546;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_8, bool surface_4, float length_2, float width_0, FKHit * own_0, bool fiber_0)
{
    ShadowContext _S547;
    (&_S547)->extinction_behind = extinction_behind_0;
    (&_S547)->extinction_front = extinction_front_0;
    (&_S547)->fillings = fillings_0;
    (&_S547)->side = side_0;
    (&_S547)->depth = depth_1;
    (&_S547)->lobe = lobe_8;
    (&_S547)->surface = surface_4;
    (&_S547)->length = length_2;
    (&_S547)->width = width_0;
    (&_S547)->own = *own_0;
    (&_S547)->fiber = fiber_0;
    return _S547;
}

__device__ float3  safeDivide(float3  a_5, float3  b_3)
{
    float3  _S548 = a_5 / b_3;
    float3  _S549 = make_float3 (0.0f);
    bool3  _S550 = b_3 == _S549;
    float3  _S551 = _slang_select(_S550, _S549,_S548);
    return _S551;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S552 = (1U << count_2) - 1U;
    return (e_2 & (~(_S552 << offset_1))) | ((newbits_0 & _S552) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_0 = r_2;
    uint _S553 = insertBits_0(r_2.path, end_0, 0U, 5U);
    uint _S554 = insertBits_0(_S553, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S554;
    (&candidate_0)->f = f_5;
    return candidate_0;
}

__device__ void offer(Selection * sel_0, Reservoir candidate_1, float3  weight_0)
{
    float _S555 = rgb_to_greyscale(weight_0);
    bool _S556 = _S555 > 0.0f;
    bool _S557;
    if(_S556)
    {
        _S557 = _S555 < 3.00000000549775576e+38f;
    }
    else
    {
        _S557 = false;
    }
    bool _S558 = !_S557;
    if(_S558)
    {
        return;
    }
    bool _S559 = sel_0->sums;
    if(_S559)
    {
        float3  _S560 = sel_0->color + weight_0;
        sel_0->color = _S560;
        return;
    }
    float _S561 = sel_0->w_sum + _S555;
    sel_0->w_sum = _S561;
    float3  _S562 = sel_0->color + weight_0;
    sel_0->color = _S562;
    Random _S563 = pcg(sel_0->random_state);
    sel_0->random_state = _S563.state;
    bool _S564 = (_S563.value * sel_0->w_sum) <= _S555;
    if(_S564)
    {
        sel_0->r = candidate_1;
    }
    return;
}

__device__ float survivalProbability(float3  throughput_1, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_8)
{
    Random _S565 = pcg(random_state_8);
    Random _S566 = pcg(_S565.state);
    float _S567 = 1.0f - 2.0f * _S565.value;
    float _S568 = (F32_sqrt(((F32_max((1.0f - _S567 * _S567), (0.0f))))));
    float _S569 = 6.28318548202514648f * _S566.value;
    return make_float3 (_S568 * (F32_cos((_S569))), _S568 * (F32_sin((_S569))), _S567);
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2)
{
    BSDFMaterial _S570;
    (&_S570)->albedo = albedo_0;
    (&_S570)->emissive = emissive_0;
    (&_S570)->roughness = roughness_0;
    (&_S570)->metallic = metallic_0;
    (&_S570)->transmission = transmission_0;
    (&_S570)->ior = ior_0;
    (&_S570)->absorption = absorption_0;
    (&_S570)->specular_tint = specular_tint_0;
    (&_S570)->specular_level = specular_level_0;
    (&_S570)->translucent = translucent_0;
    (&_S570)->sheen = sheen_2;
    (&_S570)->sheen_roughness = sheen_roughness_0;
    (&_S570)->anisotropy = anisotropy_0;
    (&_S570)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S570)->tangent = tangent_2;
    return _S570;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1)
{
    FKMedium _S571;
    (&_S571)->scatter = scatter_1;
    (&_S571)->extinction = extinction_1;
    return _S571;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_6, bool skip_0, uint random_state_9, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S572;
    (&_S572)->smooth_n = smooth_n_4;
    (&_S572)->geometry_n = geometry_n_2;
    (&_S572)->geometry_offset = geometry_offset_2;
    (&_S572)->material = *material_6;
    (&_S572)->skip = skip_0;
    (&_S572)->random_state = random_state_9;
    (&_S572)->coverage = coverage_0;
    (&_S572)->encloses = encloses_0;
    (&_S572)->volume = *volume_0;
    (&_S572)->fills = fills_0;
    (&_S572)->hair = hair_0;
    return _S572;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S573 = (&surface_5->material)->emissive;
    float3  _S574 = make_float3 (0.0f);
    bool _S575 = !top_0;
    float3  _S576 = _slang_select(_S575, _S574,_S573);
    (&(&lower_0)->material)->emissive = _S576;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_2)
{
    float _S577 = surface_6->coverage;
    bool _S578 = u_2 < _S577;
    if(_S578)
    {
        return *surface_6;
    }
    float3  _S579 = make_float3 (0.0f);
    float3  _S580 = make_float3 (1.0f);
    BSDFMaterial _S581 = Material_x24init_0(_S579, _S579, 0.0f, 0.0f, 0.0f, 0.0f, _S579, _S580, 1.0f, _S579, _S579, 0.5f, 0.0f, 0.0f, _S579);
    BSDFMaterial material_7 = _S581;
    (&material_7)->albedo = _S580;
    (&material_7)->emissive = (&surface_6->material)->emissive;
    (&material_7)->transmission = 1.0f;
    (&material_7)->ior = 1.0f;
    (&material_7)->absorption = (&surface_6->material)->absorption;
    FKSurface through_0 = *surface_6;
    (&through_0)->material = material_7;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S582 = transmission_1 > 0.0f;
    bool _S583;
    if(_S582)
    {
        _S583 = true;
    }
    else
    {
        _S583 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S584;
    if(_S583)
    {
        _S584 = 1.0f;
    }
    else
    {
        _S584 = -1.0f;
    }
    return _S584;
}

static __device__ bool arrivesBehind_0(float3  dir_9, float3  n_9)
{
    return (dot_0(dir_9, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_10)
{
    float3  _S585 = surface_7->geometry_n;
    float _S586 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_10);
    FKSurface faced_0 = *surface_7;
    float3  _S587 = surface_7->smooth_n * make_float3 (_S586);
    (&faced_0)->smooth_n = _S587;
    float3  _S588 = _S585 * make_float3 (_S586);
    (&faced_0)->geometry_n = _S588;
    return faced_0;
}

static __device__ float3  max_0(float3  x_12, float3  y_4)
{
    float3  result_5;
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
        *_slang_vector_get_element_ptr(&result_5, i_6) = (F32_max((_slang_vector_get_element(x_12, i_6)), (_slang_vector_get_element(y_4, i_6))));
        i_6 = i_6 + int(1);
    }
    return result_5;
}

static __device__ float3  log_0(float3  x_13)
{
    float3  result_6;
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
        *_slang_vector_get_element_ptr(&result_6, i_7) = (F32_log((_slang_vector_get_element(x_13, i_7))));
        i_7 = i_7 + int(1);
    }
    return result_6;
}

__device__ float3  beerLambert(float distance_2, float3  absorption_1)
{
    float3  _S589 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_2) * log_0(_S589));
}

__device__ float geometryDensity(float3  geometry_n_3, float3  direction_1, float distance_3)
{
    return (F32_abs((dot_0(geometry_n_3, direction_1)))) / (distance_3 * distance_3);
}

__device__ float footprintThreshold(float geometry_density_0)
{
    return 0.00251327408477664f / geometry_density_0;
}

__device__ bool withinFootprint(bool open_0, bool prev_rough_0, float prev_pdf_0, float geometry_density_1, float threshold_0)
{
    bool _S590;
    if(open_0)
    {
        _S590 = prev_rough_0;
    }
    else
    {
        _S590 = false;
    }
    if(_S590)
    {
        _S590 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S590 = false;
    }
    return _S590;
}

static __device__ float2  vertexEta_0(BSDFMaterial * material_8, float n_dot_v_0)
{
    bool _S591 = n_dot_v_0 < 0.0f;
    float _S592 = material_8->ior;
    float _S593 = _slang_select(_S591, _S592,1.0f);
    float _S594 = _slang_select(_S591, 1.0f,_S592);
    return make_float2 (_S593, _S594);
}

__device__ bool samplesLights(BSDFMaterial material_9)
{
    bool _S595 = (material_9.roughness) > 0.0f;
    bool _S596;
    if(_S595)
    {
        _S596 = true;
    }
    else
    {
        bool _S597 = (material_9.metallic) < 1.0f;
        if(_S597)
        {
            _S596 = (material_9.transmission) < 1.0f;
        }
        else
        {
            _S596 = false;
        }
    }
    return _S596;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_10)
{
    float _S598 = rgb_to_greyscale(material_10->translucent);
    return _S598 > 0.0f;
}

struct MediumSides
{
    FKMedium behind;
    FKMedium front;
    uint2  fillings;
    float3  face;
};

static __device__ MediumSides MediumSides_x24init_0(FKMedium * behind_0, FKMedium * front_0, uint2  fillings_1, float3  face_1)
{
    MediumSides _S599;
    (&_S599)->behind = *behind_0;
    (&_S599)->front = *front_0;
    (&_S599)->fillings = fillings_1;
    (&_S599)->face = face_1;
    return _S599;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_11)
{
    float3  _S600 = surface_8->geometry_n;
    MediumSides _S601 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S601;
    bool _S602 = surface_8->encloses;
    if(_S602)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S603 = (dot_0(dir_11, _S600)) > 0.0f;
        if(_S603)
        {
            float3  _S604 = make_float3 (0.0f);
            FKMedium _S605 = Medium_x24init_0(_S604, _S604);
            (&sides_0)->front = _S605;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_12, uint depth_2, uint lobe_9, float length_3, float width_1, FKHit * own_1, bool fiber_1)
{
    float3  _S606 = surface_9->geometry_n;
    ShadowContext _S607 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_2, lobe_9, true, length_3, width_1, own_1, fiber_1);
    bool _S608 = surface_9->encloses;
    ShadowContext context_2;
    if(_S608)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S609 = - _S606;
        float3  _S610 = _slang_select(turned_0, _S609,_S606);
        (&faced_1)->geometry_n = _S610;
        FKMedium _S611 = Medium_x24init_0(make_float3 (0.0f), extinction_2);
        FKSurface _S612 = faced_1;
        FKMedium _S613 = _S611;
        MediumSides _S614 = mediumSides_0(&_S612, &_S613, filling_1, dir_12);
        ShadowContext _S615 = ShadowContext_x24init_0(_S614.behind.extinction, _S614.front.extinction, _S614.fillings, _S606, depth_2, lobe_9, true, length_3, width_1, own_1, fiber_1);
        if(turned_0)
        {
            uint2  _S616 = _S614.fillings;
            ShadowContext _S617 = ShadowContext_x24init_0(_S614.front.extinction, _S614.behind.extinction, uint2 {_S616.y, _S616.x}, _S606, depth_2, lobe_9, true, length_3, width_1, own_1, fiber_1);
            context_2 = _S617;
        }
        else
        {
            context_2 = _S615;
        }
    }
    else
    {
        context_2 = _S607;
    }
    return context_2;
}

static __device__ bool any_0(bool3  x_14)
{
    bool result_7 = false;
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
        if(result_7)
        {
            result_7 = true;
        }
        else
        {
            result_7 = (bool((_slang_vector_get_element(x_14, i_8))));
        }
        i_8 = i_8 + int(1);
    }
    return result_7;
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_5, float3  out_dir_1, float3  n_10, float3  g_n_0, BSDFMaterial material_11, float eta_i_5, float eta_o_5, uint random_state_10)
{
    float3  _S618 = negate_0(in_dir_5);
    bool _S619 = (dot_0(g_n_0, _S618) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S619)
    {
        SampleBSDF _S620 = connectBSDF(in_dir_5, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 0U, random_state_10);
        SampleBSDF _S621 = connectBSDF(in_dir_5, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 2U, random_state_10);
        return _S620.throughput * make_float3 (_S620.pdf) + _S621.throughput * make_float3 (_S621.pdf);
    }
    SampleBSDF _S622 = connectBSDF(in_dir_5, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 1U, random_state_10);
    return _S622.throughput * make_float3 (_S622.pdf);
}

__device__ float3  translucentCorrection(float3  in_dir_6, float3  out_dir_2, float3  n_11, float3  g_n_1, BSDFMaterial material_12, float eta_i_6, float eta_o_6, uint random_state_11)
{
    float _S623 = dot_0(n_11, out_dir_2);
    float3  _S624 = negate_0(in_dir_6);
    bool _S625 = (_S623 * dot_0(n_11, _S624)) < 0.0f;
    SampleBSDF _S626 = connectBSDF(in_dir_6, out_dir_2, n_11, material_12, eta_i_6, eta_o_6, 0U, random_state_11);
    float3  _S627 = negate_0(in_dir_6);
    bool _S628 = (dot_0(g_n_1, _S627) * dot_0(g_n_1, out_dir_2)) > 0.0f;
    float3  _S629 = make_float3 (0.0f);
    float3  _S630 = _S626.throughput * make_float3 (_S626.pdf);
    float _S631 = _slang_select(_S628, -1.0f,1.0f);
    float3  _S632 = _S630 * make_float3 (_S631);
    float3  _S633 = _slang_select(_S625, _S632,_S629);
    return _S633;
}

__device__ float3  translucentBSDF(float3  in_dir_7, float3  out_dir_3, float3  n_12, float3  g_n_2, BSDFMaterial material_13, float eta_i_7, float eta_o_7, uint random_state_12)
{
    float3  _S634 = BSDF(in_dir_7, out_dir_3, n_12, g_n_2, material_13, eta_i_7, eta_o_7, random_state_12);
    float3  _S635 = translucentCorrection(in_dir_7, out_dir_3, n_12, g_n_2, material_13, eta_i_7, eta_o_7, random_state_12);
    return _S634 + _S635;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_14, float eta_i_8, float eta_o_8, bool competing_1, uint random_state_13)
{
    bool _S636 = !competing_1;
    bool _S637;
    if(_S636)
    {
        _S637 = true;
    }
    else
    {
        _S637 = (light_2->density) == 0.0f;
    }
    if(_S637)
    {
        bool _S638 = isTranslucent_0(material_14);
        if(_S638)
        {
            float3  _S639 = translucentBSDF(in_dir_8, light_2->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_8, eta_o_8, random_state_13);
            return _S639 * light_2->radiance;
        }
        float3  _S640 = BSDF(in_dir_8, light_2->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_8, eta_o_8, random_state_13);
        return _S640 * light_2->radiance;
    }
    float3  _S641 = light_2->dir;
    bool _S642 = (dot_0(geometry_n_4, - in_dir_8) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    float3  _S643 = neeBSDF(in_dir_8, _S641, smooth_n_5, *material_14, eta_i_8, eta_o_8, _S642, light_2->density, true, random_state_13);
    return _S643 * light_2->radiance * make_float3 (light_2->density);
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S644 = (F32_sqrt((random_1_0)));
    float _S645 = 6.28318548202514648f * random_2_0;
    float _S646 = _S644 * (F32_cos((_S645)));
    float _S647 = _S644 * (F32_sin((_S645)));
    float _S648 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S646 * _S646 - _S647 * _S647))))));
    return make_float3 (_S646, _S648, _S647);
}

static __device__ float3  reflect_0(float3  i_9, float3  n_13)
{
    return i_9 - make_float3 (2.0f * dot_0(n_13, i_9)) * n_13;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_9, float3  n_14, BSDFMaterial material_15, float eta_i_9, float eta_o_9, uint random_init_1, float2  screen_space_0)
{
    uint random_state_14 = random_init_1;
    float3  _S649 = negate_0(in_dir_9);
    float _S650 = dot_0(n_14, _S649);
    float _S651 = sign_0(_S650);
    float3  n_i_4 = n_14 * make_float3 (_S651);
    float _S652 = (F32_abs((_S650)));
    float _S653 = material_15.roughness;
    float _S654 = _S653 * _S653;
    AnisotropicFrame _S655 = anisotropicFrame(material_15, n_i_4);
    float3  _S656 = sampleMaterialHalfVector(_S649, n_i_4, _S654, _S655, &random_state_14);
    BSDFLobes _S657 = bsdfLobes(in_dir_9, _S649, n_i_4, _S656, material_15, eta_i_9, eta_o_9, _S655);
    BSDFLobes lobes_3 = _S657;
    float _S658 = translucentShare(material_15);
    (&lobes_3)->translucent_share = _S658;
    float3  _S659 = make_float3 (1.0f);
    SampleBSDF _S660 = SampleBSDF_x24init_0(_S659, _S659, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S660;
    Random _S661 = pcg(random_state_14);
    random_state_14 = _S661.state;
    bool _S662 = (_S661.value) < ((&lobes_3)->p_diffuse);
    if(_S662)
    {
        Random _S663 = pcg(random_state_14);
        Random _S664 = pcg(_S663.state);
        (&sample_1)->random_state = _S664.state;
        float3  _S665 = sampleCosWeightedHemisphere(_S663.value, _S664.value);
        bool _S666 = (_S661.value) < ((&lobes_3)->p_diffuse * (&lobes_3)->translucent_share);
        float _S667 = _S665.y;
        float _S668 = - _S667;
        float _S669 = _slang_select(_S666, _S668,_S667);
        float3  _S670 = tangentToWorld(make_float3 (_S665.x, _S669, _S665.z), n_i_4);
        (&sample_1)->unit_direction = _S670;
        float3  _S671 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S654, material_15, lobes_3, 0U);
        (&sample_1)->throughput = _S671;
        float _S672 = lobeDensity(_S669, 0.0f, _S652, _S654, lobes_3, eta_i_9, eta_o_9, 0U);
        (&sample_1)->pdf = _S672;
        (&sample_1)->refracted = _S666;
        return sample_1;
    }
    bool _S673 = (_S661.value) < ((&lobes_3)->p_diffuse + (&lobes_3)->p_refract);
    if(_S673)
    {
        (&sample_1)->unit_direction = (&lobes_3)->refracted;
        float _S674 = lobeDensity(0.0f, dot_0((&sample_1)->unit_direction, _S656), _S652, _S654, lobes_3, eta_i_9, eta_o_9, 1U);
        (&sample_1)->pdf = _S674;
        float3  _S675 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S654, material_15, lobes_3, 1U);
        (&sample_1)->throughput = _S675;
        (&sample_1)->random_state = random_state_14;
        (&sample_1)->refracted = true;
        (&sample_1)->lobe = 1U;
        return sample_1;
    }
    float3  _S676 = reflect_0(in_dir_9, _S656);
    float3  _S677 = ((((_S676)) * make_float3(rnorm3df(((_S676)).x, ((_S676)).y, ((_S676)).z))));
    (&sample_1)->unit_direction = _S677;
    float3  _S678 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S654, material_15, lobes_3, 2U);
    (&sample_1)->throughput = _S678;
    (&sample_1)->random_state = random_state_14;
    (&sample_1)->lobe = 2U;
    float _S679 = lobeDensity(0.0f, 0.0f, _S652, _S654, lobes_3, eta_i_9, eta_o_9, 2U);
    (&sample_1)->pdf = _S679;
    return sample_1;
}

__device__ bool withinInverseFootprint(float pdf_6, bool diffuse_0, float prev_cos_0, float distance_4, float threshold_1)
{
    bool _S680 = pdf_6 > 0.0f;
    bool _S681;
    if(_S680)
    {
        if(diffuse_0)
        {
            _S681 = true;
        }
        else
        {
            _S681 = (pdf_6 * prev_cos_0 / (distance_4 * distance_4) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S681 = false;
    }
    return _S681;
}

__device__ bool roughLobe(float pdf_7, bool diffuse_1, float roughness_1)
{
    bool _S682 = pdf_7 > 0.0f;
    bool _S683;
    if(_S682)
    {
        if(diffuse_1)
        {
            _S683 = true;
        }
        else
        {
            _S683 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S683 = false;
    }
    return _S683;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S684 = layers_0 > 1U;
    bool _S685;
    if(_S684)
    {
        _S685 = refracting_0 != passed_0;
    }
    else
    {
        _S685 = false;
    }
    return _S685;
}

static __device__ float widened_0(float spread_0, float pdf_8, bool delta_0)
{
    float _S686 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_8))))), (3.14159274101257324f)));
    bool _S687 = !delta_0;
    float _S688 = _slang_select(_S687, _S686,0.0f);
    return spread_0 + _S688;
}

static __device__ bool boundsVolume_0(FKSurface * surface_10)
{
    return surface_10->encloses;
}

static __device__ bool leavesInFront_0(float3  face_2, float3  dir_13, float3  g_0)
{
    return ((dot_0(dir_13, g_0)) > 0.0f) == ((dot_0(g_0, face_2)) > 0.0f);
}

static __device__ float distance_5(float3  x_15, float3  y_5)
{
    return length_0(x_15 - y_5);
}

static __device__ Shift walk_0(Domain * dom_0, Reservoir * r_3, bool replay_1, float scale_1, Selection * sel_1)
{
    float spread_1;
    bool turned_1;
    bool is_inside_5;
    bool viewed_0;
    bool scatter_2;
    float density_2;
    float threshold_2;
    float width_2;
    float sky_pdf_0;
    float geometry_density_2;
    uint b_4;
    uint layer_0;
    float3  throughput_2;
    float3  chain_throughput_0;
    TreeSample light_3;
    int _S689;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_3;
    float sky_pdf_1;
    float spread_3;
    float width_4;
    uint b_5;
    float3  _S690 = make_float3 (0.0f);
    Shift _S691 = Shift_x24init_0(_S690, 0.0f);
    uint _S692 = r_3->path;
    uint _S693 = extractBits_0(r_3->path, 0U, 5U);
    uint _S694 = extractBits_0(_S692, 5U, 5U);
    uint _S695 = extractBits_0(_S692, 10U, 2U);
    uint _S696 = extractBits_0(_S692, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S697 = _S696 >= 3U;
        uint _S698 = _slang_select(_S697, 1U,0U);
        uint _S699 = _S693 + _S698;
        uint _S700 = (fcptMaxBounces());
        passes_0 = _S699 > _S700;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S691;
    }
    uint _S701 = _S694 - 1U;
    bool _S702 = _S696 == 3U;
    uint _S703 = _slang_select(_S702, 1U,0U);
    uint _S704 = _S693 + _S703;
    bool _S705 = _S695 == 0U;
    uint _S706 = _slang_select(_S705, _S704,_S701);
    FKHit _S707 = (fcptReservoirHit((*r_3)));
    float3  _S708 = dom_0->x0;
    float3  _S709 = dom_0->x1 - dom_0->x0;
    float3  _S710 = ((((_S709)) * make_float3(rnorm3df(((_S709)).x, ((_S709)).y, ((_S709)).z))));
    FKRay _S711 = Ray_x24init_0(dom_0->x1, _S710);
    FKRay ray_2 = _S711;
    FKHit hit_1 = dom_0->hit;
    float3  scatter_in_0 = _S690;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S690;
    float3  extinction_in_0 = _S690;
    uint filling_2 = 4294967295U;
    float _S712 = dom_0->spread;
    float _S713 = dom_0->width;
    float _S714 = length_0(_S709);
    NEEVertex _S715 = NEEVertex_x24init_0(true, 0.0f, _S690, _S690, _S690);
    NEEVertex nee_vertex_0 = _S715;
    Vertex _S716 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S716;
    Reservoir _S717 = (Reservoir{});
    Reservoir chain_0 = _S717;
    uint _S718 = r_3->seed;
    (&chain_0)->seed = r_3->seed;
    (&ray_2)->origin = _S708;
    (&hit_1)->distance = _S714;
    FKMedium _S719 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_1)->distance), (&filling_2)));
    uint _S720 = filling_2;
    bool _S721 = (fcptVaryingUsed());
    uint _S722 = _slang_select(_S721, _S720,4294967295U);
    filling_2 = _S722;
    scatter_in_0 = _S719.scatter;
    extinction_in_0 = _S719.extinction;
    Reservoir _S723 = chain_0;
    uint _S724 = filling_2;
    for(;;)
    {
        bool _S725 = (fcptVaryingUsed());
        if(_S725)
        {
            passes_0 = _S724 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S726 = (fcptMajorant((_S724)));
            spread_1 = _S726;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S706;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S695 == 1U;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = spread_1 > 0.0f;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            ended_0 = _S691;
            sky_pdf_0 = 0.0f;
            spread_1 = _S712;
            width_2 = _S713;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_4 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S727 = (&prev_0)->rough;
        if(_S727)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S728 = stream(_S718, 384U);
        uint tracking_0 = _S728;
        weight_1 = throughput_3;
        glowed_0 = _S690;
        b_4 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_2 = _S712;
        width_2 = _S713;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_1)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S689 = int(1);
                break;
            }
            uint _S729 = b_4 + 320U;
            bool _S730 = b_4 == 4294967295U;
            uint _S731 = _slang_select(_S730, 384U,_S729);
            uint _S732 = stream(_S718, _S731);
            Random _S733 = pcg(_S732);
            float _S734 = freeFlight_0(_S733.value, spread_1);
            if(passes_0)
            {
                float3  _S735 = (&ray_2)->origin;
                float3  _S736 = (&ray_2)->unit_direction;
                float _S737 = (&hit_1)->distance;
                uint _S738 = _slang_select(_S730, 0U,b_4);
                uint _S739 = (&prev_0)->lobe;
                uint _S740 = _slang_select(_S730, 3U,_S739);
                float _S741 = (fcptTrackMedium((_S724), (_S735), (_S736), (_S737), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S738), (_S740), (_S730)));
                geometry_density_2 = _S741;
            }
            else
            {
                geometry_density_2 = _S734;
            }
            bool _S742 = !(geometry_density_2 < ((&hit_1)->distance));
            if(_S742)
            {
                _S689 = int(1);
                break;
            }
            if(passes_0)
            {
                turned_1 = !replay_1;
            }
            else
            {
                turned_1 = false;
            }
            if(turned_1)
            {
                float3  _S743 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S744 = sel_1->glow + _S743;
                sel_1->glow = _S744;
            }
            else
            {
            }
            glowed_0 = _S690;
            uint b_6 = b_4 + 1U;
            float3  _S745 = (&ray_2)->origin + make_float3 (geometry_density_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S745;
            float3  _S746 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, geometry_density_2, true);
            float3  _S747 = weight_1;
            float3  _S748 = _slang_select(passes_0, _S747,_S746);
            float3  throughput_4 = throughput_2 * _S748;
            uint _S749 = stream(_S718, b_6 + 320U);
            tracking_0 = _S749;
            weight_1 = throughput_3;
            float width_5 = width_2 + threshold_2 * geometry_density_2;
            float _S750 = threshold_2 + 3.14159274101257324f;
            bool _S751 = scatterSampled_0(replay_1, b_6, _S706, passes_0);
            TreeSample _S752 = TreeSample_x24init_0(_S690, _S690, 0.0f, 0U);
            if(_S751)
            {
                float3  _S753 = (&ray_2)->origin;
                float3  _S754 = (&ray_2)->unit_direction;
                float3  _S755 = (&ray_2)->unit_direction;
                uint _S756 = stream(_S718, b_6 + 64U);
                float3  _S757 = extinction_in_0;
                float3  _S758 = extinction_in_0;
                uint2  _S759 = make_uint2 (_S724);
                float3  _S760 = (&ray_2)->unit_direction;
                uint _S761 = arrivalLobe_0(b_6, (&prev_0)->lobe);
                FKHit _S762 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S763 = _S762;
                ShadowContext _S764 = ShadowContext_x24init_0(_S757, _S758, _S759, _S760, b_6, _S761, false, geometry_density_2, width_5, &_S763, false);
                ShadowContext _S765 = _S764;
                TreeSample _S766 = sampleLightTree_0(_S753, _S754, _S755, 0.0f, true, _S756, &_S765);
                light_3 = _S766;
            }
            else
            {
                light_3 = _S752;
            }
            uint _S767 = (fcptMaxBounces());
            bool _S768 = b_6 < _S767;
            if(_S768)
            {
                is_inside_5 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_5 = false;
            }
            float _S769 = _slang_select(is_inside_5, 0.07957746833562851f,0.0f);
            float3  _S770 = throughput_4 * light_3.radiance;
            float _S771 = powerHeuristic(light_3.density, _S769);
            float3  _S772 = _S770 * make_float3 (0.07957746833562851f * _S771);
            float3  _S773 = _slang_select(_S751, _S772,_S690);
            if(replay_1)
            {
                viewed_0 = b_6 == _S706;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S774 = _S695 == 2U;
                if(_S774)
                {
                    float _S775 = rgb_to_greyscale(_S773);
                    passes_0 = _S775 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S776 = Shift_x24init_0(_S773, 1.0f);
                    _S689 = int(0);
                    ended_0 = _S776;
                    spread_1 = _S750;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                _S689 = int(0);
                ended_0 = _S691;
                spread_1 = _S750;
                geometry_density_2 = width_5;
                chain_throughput_0 = throughput_4;
                layer_0 = b_6;
                break;
            }
            bool _S777 = !replay_1;
            if(_S777)
            {
                Reservoir candidate_2 = _S723;
                uint _S778 = extractBits_0(_S723.path, 10U, 2U);
                bool _S779 = _S778 == 1U;
                if(_S779)
                {
                    float3  _S780 = safeDivide(_S773, _S690);
                    (&candidate_2)->radiance = _S780;
                }
                else
                {
                    uint _S781 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                    uint _S782 = insertBits_0(_S781, 2U, 10U, 2U);
                    (&candidate_2)->path = _S782;
                }
                Reservoir _S783 = withEnd(candidate_2, 0U, b_6, _S773);
                offer(sel_1, _S783, _S773 * make_float3 (scale_1) / make_float3 (density_2));
                float _S784 = survivalProbability(throughput_4, density_2);
                uint _S785 = stream(_S718, b_6 + 128U);
                Random _S786 = pcg(_S785);
                bool _S787 = _S784 < (_S786.value);
                if(_S787)
                {
                    scatter_2 = true;
                }
                else
                {
                    uint _S788 = (fcptMaxBounces());
                    scatter_2 = b_6 >= _S788;
                }
                if(scatter_2)
                {
                    _S689 = int(0);
                    ended_0 = _S691;
                    spread_1 = _S750;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                float _S789 = density_2 * _S784;
                density_2 = _S789;
            }
            else
            {
            }
            NEEVertex _S790 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_2)->origin, _S690, (&ray_2)->origin);
            nee_vertex_0 = _S790;
            uint _S791 = stream(_S718, b_6);
            float3  _S792 = isotropic_0(_S791);
            (&ray_2)->unit_direction = _S792;
            Vertex _S793 = scatteredVertex_0(false);
            prev_0 = _S793;
            float _S794 = (&prev_0)->pdf;
            FKRay _S795 = ray_2;
            FKHit _S796 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S797 = (fcptTraverseInstanceBVH((_S795), (true), (4.294967296e+09f), (false), (_S796), (false)));
            hit_1 = _S797;
            b_4 = b_6;
            throughput_2 = throughput_4;
            threshold_2 = _S750;
            width_2 = width_5;
            sky_pdf_0 = _S794;
        }
        if(_S689 != int(1))
        {
            width_2 = geometry_density_2;
            throughput_2 = chain_throughput_0;
            b_4 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S691;
        spread_1 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S798 = b_4 == 4294967295U;
    bool _S799 = ((&hit_1)->instance_index) == 4294967295U;
    if(_S799)
    {
        bool _S800 = !(&nee_vertex_0)->none;
        float _S801 = _slang_select(_S800, sky_pdf_0,0.0f);
        float _S802 = escapeWeight_0(_S801, (&ray_2)->unit_direction);
        float3  _S803 = environment_0((&ray_2)->unit_direction, b_4, (&prev_0)->lobe);
        float3  _S804 = throughput_2 * _S803;
        if(replay_1)
        {
            bool _S805 = b_4 == _S706;
            if(_S805)
            {
                passes_0 = _S695 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S804 * make_float3 (_S802) / make_float3 (r_3->jac), density_2 / r_3->jac);
            }
            if(_S705)
            {
                passes_0 = _S702;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_4 == _S693;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = !(&prev_0)->rough;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S804 * make_float3 (_S802), 1.0f);
            }
            return _S691;
        }
        Reservoir candidate_3 = chain_0;
        uint _S806 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S807 = _S806 == 1U;
        if(_S807)
        {
            uint _S808 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S809 = _S808 == b_4;
            float _S810 = _slang_select(_S809, 1.0f,_S802);
            float3  _S811 = safeDivide(_S804 * make_float3 (_S810), _S690);
            (&candidate_3)->radiance = _S811;
        }
        else
        {
            bool _S812 = (&prev_0)->rough;
            if(_S812)
            {
                uint _S813 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                uint _S814 = insertBits_0(_S813, 3U, 10U, 2U);
                uint _S815 = insertBits_0(_S814, (&prev_0)->lobe, 15U, 2U);
                bool _S816 = (&prev_0)->inside;
                uint _S817 = _slang_select(_S816, 1U,0U);
                uint _S818 = insertBits_0(_S815, _S817, 20U, 1U);
                (&candidate_3)->path = _S818;
                (&candidate_3)->jac = (&prev_0)->pdf;
                (&candidate_3)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S819 = _S804 * make_float3 (_S802);
        Reservoir _S820 = withEnd(candidate_3, 3U, b_4, _S819);
        offer(sel_1, _S820, _S819 * make_float3 (scale_1) / make_float3 (density_2));
        return _S691;
    }
    float3  _S821 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S821;
    bool _S822 = (fcptVaryingUsed());
    if(_S822)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S823 = !replay_1;
        if(_S823)
        {
            float3  _S824 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S825 = sel_1->glow + _S824;
            sel_1->glow = _S825;
        }
        float3  _S826 = throughput_2 * weight_1;
        throughput_2 = _S826;
    }
    else
    {
        float3  _S827 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
        float3  _S828 = throughput_2 * _S827;
        throughput_2 = _S828;
    }
    float _S829 = width_2 + spread_1 * (&hit_1)->distance;
    uint _S830 = b_4 + 1U;
    b_4 = _S830;
    layer_0 = 0U;
    width_2 = _S829;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S690;
    float3  reconnection_0 = _S690;
    viewed_0 = _S798;
    for(;;)
    {
        bool _S831 = ((&hit_1)->is_point_light) == 1U;
        FKMedium _S832 = Medium_x24init_0(_S690, _S690);
        BSDFMaterial _S833 = Material_x24init_0(_S690, _S690, 0.0f, 0.0f, 0.0f, 0.0f, _S690, throughput_3, 1.0f, _S690, _S690, 0.5f, 0.0f, 0.0f, _S690);
        FKMedium _S834 = _S832;
        FKSurface _S835 = Surface_x24init_0(_S690, _S690, 0.0f, &_S833, false, 0U, 1.0f, false, &_S834, 4294967295U, _S690);
        bool _S836 = !_S831;
        bool is_inside_6;
        float3  throughput_5;
        FKSurface surface_11;
        if(_S836)
        {
            uint _S837 = stream(_S718, b_4);
            uint _S838 = arrivalLobe_0(b_4, (&prev_0)->lobe);
            FKSurface _S839 = (fcptSurfaceAtPath((hit_1), ((&ray_2)->origin), (_S837), (width_2), (layer_0), (b_4), (_S838), ((&ray_2)->unit_direction)));
            bool _S840 = !passes_0;
            FKSurface _S841 = _S839;
            FKSurface _S842 = emitting_0(&_S841, _S840);
            uint _S843 = stream(_S718, b_4 + 256U);
            Random _S844 = pcg(_S843);
            FKSurface _S845 = _S842;
            FKSurface _S846 = uncovered_0(&_S845, _S844.value);
            float _S847 = facingSign(_S846.material.transmission, _S846.geometry_n, (&ray_2)->unit_direction);
            bool _S848 = _S847 < 0.0f;
            bool _S849 = (_S846.material.transmission) > 0.0f;
            if(_S849)
            {
                bool _S850 = arrivesBehind_0((&ray_2)->unit_direction, _S846.geometry_n);
                scatter_2 = _S850;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S851 = _S846;
            FKSurface _S852 = facingRay_0(&_S851, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S853 = arrivesBehind_0((&ray_2)->unit_direction, _S852.geometry_n);
                is_inside_6 = _S853;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S854 = beerLambert((&hit_1)->distance, _S852.material.absorption);
                float3  _S855 = throughput_2 * _S854;
                throughput_5 = _S855;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S856 = !_S852.skip;
            float geometry_density_3 = geometryDensity(_S852.geometry_n, (&ray_2)->unit_direction, (&hit_1)->distance);
            bool _S857 = b_4 == _S830;
            if(_S857)
            {
                float _S858 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S858;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S859 = geometry_density_2;
            scatter_2 = _S856;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S859;
            surface_11 = _S852;
            turned_1 = _S848;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_11 = _S835;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S860 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S861 = surface_11;
        FKSurface _S862 = surface_11;
        float _S863 = dot_0(surface_11.smooth_n, - (&ray_2)->unit_direction);
        BSDFMaterial _S864 = _S861.material;
        float2  _S865 = vertexEta_0(&_S864, _S863);
        bool _S866;
        if(scatter_2)
        {
            bool _S867 = samplesLights(_S861.material);
            _S866 = _S867;
        }
        else
        {
            _S866 = false;
        }
        bool _S868;
        if(passes_0)
        {
            _S868 = true;
        }
        else
        {
            _S868 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S868)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S866;
        }
        bool _S869 = (fcptHairUsed());
        bool _S870;
        if(_S869)
        {
            float3  _S871 = surface_11.hair;
            _S870 = (dot_0(_S871, _S871)) > 0.0f;
        }
        else
        {
            _S870 = false;
        }
        bool _S872;
        if(_S870)
        {
            _S872 = true;
        }
        else
        {
            BSDFMaterial _S873 = _S861.material;
            bool _S874 = isTranslucent_0(&_S873);
            _S872 = _S874;
        }
        bool _S875;
        if(_S872)
        {
            _S875 = true;
        }
        else
        {
            bool _S876 = (_S861.material.transmission) > 0.0f;
            if(_S876)
            {
                uint _S877 = (fcptLayers((hit_1)));
                _S875 = _S877 == 1U;
            }
            else
            {
                _S875 = false;
            }
        }
        float3  emission_0;
        if(_S831)
        {
            float3  _S878 = (fcptCalculatePointLightContrib(((&hit_1)->instance_index)));
            emission_0 = _S878;
        }
        else
        {
            emission_0 = _S861.material.emissive;
        }
        float _S879 = rgb_to_greyscale(emission_0);
        bool _S880 = _S879 > 0.0f;
        float3  emission_1;
        if(_S880)
        {
            NEEVertex _S881 = nee_vertex_0;
            FKHit _S882 = hit_1;
            float _S883 = emissionWeight_0(&_S881, &_S882, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S883);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S884;
        if(replay_1)
        {
            _S884 = _S695 == 1U;
        }
        else
        {
            _S884 = false;
        }
        bool _S885;
        if(_S884)
        {
            _S885 = b_4 > _S694;
        }
        else
        {
            _S885 = false;
        }
        bool _S886;
        if(_S885)
        {
            _S886 = b_4 == _S693;
        }
        else
        {
            _S886 = false;
        }
        bool _S887;
        if(_S886)
        {
            bool _S888 = _S696 == 1U;
            if(_S888)
            {
                _S887 = true;
            }
            else
            {
                _S887 = _S696 == 2U;
            }
        }
        else
        {
            _S887 = false;
        }
        if(_S887)
        {
            bool _S889 = _S831 != (_S696 == 2U);
            if(_S889)
            {
                return _S691;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_3->jac), density_2 / r_3->jac);
        }
        uint _S890 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S891 = _S890 == 1U;
        Reservoir here_0 = chain_0;
        uint _S892 = insertBits_0(0U, b_4, 5U, 5U);
        uint _S893 = insertBits_0(_S892, 1U, 10U, 2U);
        uint _S894 = insertBits_0(_S893, (&prev_0)->lobe, 15U, 2U);
        bool _S895 = (&prev_0)->inside;
        uint _S896 = _slang_select(_S895, 1U,0U);
        uint _S897 = insertBits_0(_S894, _S896, 20U, 1U);
        (&here_0)->path = _S897;
        float _S898 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S898;
        fcptWithReservoirHit((&here_0), (&hit_1));
        bool _S899;
        if(replay_1)
        {
            _S899 = _S695 == 1U;
        }
        else
        {
            _S899 = false;
        }
        bool _S900;
        if(_S899)
        {
            _S900 = b_4 == _S694;
        }
        else
        {
            _S900 = false;
        }
        bool _S901 = b_4 == _S706;
        bool _S902;
        if(_S901)
        {
            bool _S903 = !scatter_2;
            if(_S903)
            {
                _S902 = true;
            }
            else
            {
                bool _S904 = _S695 != 1U;
                if(_S904)
                {
                    _S902 = _S695 != 3U;
                }
                else
                {
                    _S902 = false;
                }
            }
        }
        else
        {
            _S902 = false;
        }
        bool _S905;
        if(_S902)
        {
            _S905 = _S695 == 2U;
        }
        else
        {
            _S905 = false;
        }
        bool _S906;
        if(_S905)
        {
            _S906 = !_S860;
        }
        else
        {
            _S906 = false;
        }
        bool _S907;
        if(_S906)
        {
            _S907 = _S696 != 4U;
        }
        else
        {
            _S907 = false;
        }
        bool _S908 = _S694 == _S693;
        bool _S909;
        if(_S908)
        {
            _S909 = _S696 == 0U;
        }
        else
        {
            _S909 = false;
        }
        bool _S910;
        if(_S909)
        {
            _S910 = ((&hit_1)->instance_index) == (_S707.instance_index);
        }
        else
        {
            _S910 = false;
        }
        bool _S911;
        if(_S910)
        {
            _S911 = ((&hit_1)->triangle_index) == (_S707.triangle_index);
        }
        else
        {
            _S911 = false;
        }
        bool _S912;
        if(_S911)
        {
            _S912 = _S860;
        }
        else
        {
            _S912 = false;
        }
        bool _S913 = _slang_select(_S900, _S912,_S907);
        bool _S914;
        if(nee_0)
        {
            _S914 = _slang_select(replay_1, _S913,scatter_2);
        }
        else
        {
            _S914 = false;
        }
        TreeSample _S915 = TreeSample_x24init_0(_S690, _S690, 0.0f, 0U);
        float3  throughput_6;
        float3  lit_0;
        if(_S914)
        {
            float3  _S916 = (&ray_2)->origin;
            if(_S870)
            {
                throughput_6 = _S690;
            }
            else
            {
                throughput_6 = _S862.smooth_n;
            }
            FKSurface _S917 = surface_11;
            uint _S918 = stream(_S718, b_4 + 64U);
            uint _S919 = arrivalLobe_0(b_4, (&prev_0)->lobe);
            FKSurface _S920 = surface_11;
            FKHit _S921 = hit_1;
            ShadowContext _S922 = shadowContext_0(&_S920, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_4, _S919, (&hit_1)->distance, width_2, &_S921, _S870);
            ShadowContext _S923 = _S922;
            TreeSample _S924 = sampleLightTree_0(_S916, throughput_6, surface_11.geometry_n, surface_11.geometry_offset, _S875, _S918, &_S923);
            bool _S925 = any_0((_S924.radiance) != _S690);
            if(_S925)
            {
                if(_S870)
                {
                    uint _S926 = (fcptMaxBounces());
                    bool _S927 = b_4 < _S926;
                    FKSurface _S928 = surface_11;
                    TreeSample _S929 = _S924;
                    float3  _S930 = hairLight_0(&_S928, (&ray_2)->unit_direction, &_S929, _S927);
                    lit_0 = _S930;
                }
                else
                {
                    float _S931 = _S865.x;
                    float _S932 = _S865.y;
                    uint _S933 = (fcptMaxBounces());
                    bool _S934 = b_4 < _S933;
                    TreeSample _S935 = _S924;
                    BSDFMaterial _S936 = _S861.material;
                    float3  _S937 = lightBSDF_0((&ray_2)->unit_direction, &_S935, _S862.smooth_n, _S917.geometry_n, &_S936, _S931, _S932, _S934, surface_11.random_state);
                    lit_0 = _S937;
                }
            }
            else
            {
                lit_0 = _S690;
            }
            light_3 = _S924;
        }
        else
        {
            light_3 = _S915;
            lit_0 = _S690;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S938;
        bool _S939;
        float density_4;
        if(_S900)
        {
            bool _S940 = ((&hit_1)->instance_index) != (_S707.instance_index);
            if(_S940)
            {
                viewed_1 = true;
            }
            else
            {
                viewed_1 = ((&hit_1)->triangle_index) != (_S707.triangle_index);
            }
            if(viewed_1)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = !_S860;
            }
            if(refracted_4)
            {
                return _S691;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S908)
            {
                wrong_side_0 = _S696 == 1U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            if(_S908)
            {
                _S938 = _S696 == 0U;
            }
            else
            {
                _S938 = false;
            }
            if(_S938)
            {
                bool _S941 = !nee_0;
                if(_S941)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S942 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S942 > 0.0f);
                }
                if(passes_0)
                {
                    return _S691;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            if(_S908)
            {
                _S939 = _S696 == 4U;
            }
            else
            {
                _S939 = false;
            }
            if(_S939)
            {
                bool _S943 = !nee_0;
                if(_S943)
                {
                    return _S691;
                }
                float _S944 = environmentPdf_0(r_3->dir);
                float3  _S945 = skyBSDF((&ray_2)->unit_direction, r_3->dir, surface_11, _S865, is_inside_6, _S944, surface_11.random_state);
                return Shift_x24init_0(throughput_7 * _S945 * r_3->radiance / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            uint _S946 = extractBits_0(_S692, 19U, 1U);
            bool _S947 = nee_0 != (_S946 == 1U);
            if(_S947)
            {
                return _S691;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S901;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S948 = !scatter_2;
                if(_S948)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S949 = _S695 != 1U;
                    if(_S949)
                    {
                        refracted_4 = _S695 != 3U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                }
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S950 = _S695 == 2U;
                if(_S950)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S860;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S696 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    uint _S951 = stream(_S718, b_4 + 448U);
                    FKRay _S952 = ray_2;
                    FKSurface _S953 = surface_11;
                    SkySample _S954 = sampleSky_0(&_S952, &_S953, _S865, is_inside_6, _S951, surface_11.random_state);
                    return Shift_x24init_0(throughput_5 * _S954.color, 1.0f);
                }
                if(_S950)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S860;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S955 = rgb_to_greyscale(light_3.radiance);
                    bool _S956 = !(_S955 > 0.0f);
                    if(_S956)
                    {
                        return _S691;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S705)
                {
                    passes_0 = _S696 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S831;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S705)
                {
                    passes_0 = _S696 == 1U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = scatter_2;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S860;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S691;
            }
            else
            {
                bool _S957 = !replay_1;
                if(_S957)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S958 = b_4 > 0U;
                    if(_S958)
                    {
                        Reservoir candidate_4 = chain_0;
                        if(_S891)
                        {
                            float3  _S959 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_4)->radiance = _S959;
                        }
                        else
                        {
                            if(_S860)
                            {
                                candidate_4 = here_0;
                            }
                        }
                        float3  _S960 = throughput_5 * emission_1;
                        Reservoir _S961 = withEnd(candidate_4, 1U, b_4, _S960);
                        offer(sel_1, _S961, _S960 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S962 = throughput_5 * emission_1;
                        float3  _S963 = sel_1->glow + _S962;
                        sel_1->glow = _S963;
                    }
                    if(nee_0)
                    {
                        float3  _S964 = throughput_5 * lit_0;
                        Reservoir candidate_5 = chain_0;
                        if(_S891)
                        {
                            float3  _S965 = safeDivide(_S964, chain_throughput_0);
                            (&candidate_5)->radiance = _S965;
                        }
                        else
                        {
                            if(_S860)
                            {
                                candidate_5 = here_0;
                                uint _S966 = insertBits_0((&candidate_5)->path, 1U, 19U, 1U);
                                (&candidate_5)->path = _S966;
                                (&candidate_5)->dir = light_3.dir;
                                (&candidate_5)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S967 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S968 = insertBits_0(_S967, 2U, 10U, 2U);
                                (&candidate_5)->path = _S968;
                            }
                        }
                        Reservoir _S969 = withEnd(candidate_5, 0U, b_4, _S964);
                        offer(sel_1, _S969, _S964 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S870)
                        {
                            _S938 = false;
                        }
                        else
                        {
                            bool _S970 = environmentMapped_0();
                            _S938 = _S970;
                        }
                    }
                    else
                    {
                        _S938 = false;
                    }
                    if(_S938)
                    {
                        uint _S971 = (fcptMaxBounces());
                        _S939 = b_4 < _S971;
                    }
                    else
                    {
                        _S939 = false;
                    }
                    if(_S939)
                    {
                        uint _S972 = stream(_S718, b_4 + 448U);
                        FKRay _S973 = ray_2;
                        FKSurface _S974 = surface_11;
                        SkySample _S975 = sampleSky_0(&_S973, &_S974, _S865, is_inside_6, _S972, surface_11.random_state);
                        float3  _S976 = throughput_5 * _S975.color;
                        Reservoir candidate_6 = chain_0;
                        if(_S891)
                        {
                            float3  _S977 = safeDivide(_S976, chain_throughput_0);
                            (&candidate_6)->radiance = _S977;
                        }
                        else
                        {
                            if(_S860)
                            {
                                candidate_6 = here_0;
                                uint _S978 = insertBits_0((&candidate_6)->path, 1U, 19U, 1U);
                                (&candidate_6)->path = _S978;
                                (&candidate_6)->dir = _S975.dir;
                                (&candidate_6)->radiance = _S975.radiance;
                            }
                            else
                            {
                                uint _S979 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S980 = insertBits_0(_S979, 2U, 10U, 2U);
                                (&candidate_6)->path = _S980;
                            }
                        }
                        Reservoir _S981 = withEnd(candidate_6, 4U, b_4, _S976);
                        offer(sel_1, _S981, _S976 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S982;
        bool straight_0;
        bool _S983;
        bool _S984;
        bool _S985;
        bool _S986;
        bool _S987;
        bool _S988;
        bool _S989;
        bool _S990;
        bool _S991;
        bool _S992;
        bool _S993;
        bool _S994;
        bool _S995;
        bool _S996;
        float density_6;
        float sky_pdf_2;
        float spread_4;
        uint b_7;
        float3  throughput_8;
        float3  throughput_9;
        float3  throughput_10;
        if(scatter_2)
        {
            if(replay_1)
            {
                viewed_1 = _S901;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S997 = extractBits_0(_S692, 15U, 2U);
            uint _S998 = extractBits_0(_S692, 17U, 2U);
            uint _S999 = _slang_select(_S900, _S998,_S997);
            float3  _S1000 = r_3->dir;
            bool refracted_5 = _S999 == 1U;
            SampleBSDF _S1001 = SampleBSDF_x24init_0(_S690, _S690, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_10 = _S1001;
            float3  reconnection_1;
            SampleBSDF _S1002;
            if(viewed_1)
            {
                uint _S1003 = extractBits_0(_S692, 20U, 1U);
                bool _S1004 = is_inside_6 != (_S1003 == 1U);
                if(_S1004)
                {
                    return _S691;
                }
                bool _S1005 = _S695 == 1U;
                if(_S1005)
                {
                    float3  _S1006 = (fcptHitPosition((_S707)));
                    throughput_8 = _S1006;
                }
                else
                {
                    throughput_8 = reconnection_0;
                }
                if(refracted_5)
                {
                    refracted_4 = true;
                }
                else
                {
                    BSDFMaterial _S1007 = _S861.material;
                    bool _S1008 = isTranslucent_0(&_S1007);
                    if(_S1008)
                    {
                        refracted_4 = _S999 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1009 = throughput_8 - (&ray_2)->origin;
                        float3  _S1010 = _slang_select(_S1005, _S1009,_S1000);
                        wrong_side_0 = (dot_0(_S862.smooth_n, _S1010) * _S863) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1005)
                {
                    float3  _S1011 = (&ray_2)->origin;
                    FKSurface _S1012 = surface_11;
                    float3  _S1013 = - _S862.smooth_n;
                    bool _S1014 = is_inside_6 != refracted_4;
                    float3  _S1015 = _slang_select(_S1014, _S1013,_S862.smooth_n);
                    float3  _S1016 = throughput_8 - (_S1011 + make_float3 (_S1012.geometry_offset) * _S1015);
                    float3  _S1017 = ((((_S1016)) * make_float3(rnorm3df(((_S1016)).x, ((_S1016)).y, ((_S1016)).z))));
                    reconnection_1 = _S1017;
                }
                else
                {
                    reconnection_1 = _S1000;
                }
                if(_S870)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1018 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_11.geometry_n);
                    wrong_side_0 = _S1018;
                }
                if(wrong_side_0)
                {
                    return _S691;
                }
                float3  _S1019 = throughput_8;
                throughput_8 = reconnection_1;
                b_7 = _S999;
                wrong_side_0 = false;
                reconnection_1 = _S1019;
            }
            else
            {
                bool _S1020 = !_S900;
                if(_S1020)
                {
                    SampleBSDF bsdf_sampled_0;
                    if(_S870)
                    {
                        SampleBSDF _S1021 = (fcptSampleHair((surface_11.hair), (_S861.material.albedo), (_S861.material.specular_tint), ((&ray_2)->unit_direction), (surface_11.random_state)));
                        _S1002 = _S1021;
                    }
                    else
                    {
                        SampleBSDF _S1022 = sampleBSDF((&ray_2)->unit_direction, _S862.smooth_n, _S861.material, _S865.x, _S865.y, surface_11.random_state, make_float2 (0.0f));
                        _S1002 = _S1022;
                    }
                    bsdf_sampled_0 = _S1002;
                    if(_S870)
                    {
                        refracted_4 = !(((&bsdf_sampled_0)->pdf) > 0.0f);
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        if(replay_1)
                        {
                            return _S691;
                        }
                        break;
                    }
                    if(_S870)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1023 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_11.geometry_n);
                        wrong_side_0 = _S1023;
                    }
                    if(wrong_side_0)
                    {
                        _S938 = (_S861.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S938 = false;
                    }
                    if(_S938)
                    {
                        SampleBSDF _S1024 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n, _S861.material, _S865.x, _S865.y, (&bsdf_sampled_0)->random_state, make_float2 (0.0f));
                        (&bsdf_sampled_0)->unit_direction = _S1024.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1024.refracted;
                        (&bsdf_sampled_0)->throughput = _S1024.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1025 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n)) * surface_11.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1025;
                        }
                    }
                    uint _S1026 = (&bsdf_sampled_0)->lobe;
                    float3  _S1027 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1028 = (&bsdf_sampled_0)->refracted;
                    lobe_10 = bsdf_sampled_0;
                    float _S1029 = (&bsdf_sampled_0)->pdf;
                    float _S1030 = _slang_select(wrong_side_0, 0.0f,_S1029);
                    (&lobe_10)->pdf = _S1030;
                    throughput_8 = _S1027;
                    b_7 = _S1026;
                    refracted_4 = _S1028;
                }
                else
                {
                    throughput_8 = _S1000;
                    b_7 = _S999;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S938 = true;
            }
            else
            {
                _S938 = _S900;
            }
            if(_S938)
            {
                if(_S870)
                {
                    SampleBSDF _S1031 = (fcptConnectHair((surface_11.hair), (_S861.material.albedo), (_S861.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    _S1002 = _S1031;
                }
                else
                {
                    SampleBSDF _S1032 = connectBSDF((&ray_2)->unit_direction, throughput_8, _S862.smooth_n, _S861.material, _S865.x, _S865.y, b_7, surface_11.random_state);
                    _S1002 = _S1032;
                }
                lobe_10 = _S1002;
            }
            if(_S870)
            {
                _S939 = false;
            }
            else
            {
                bool _S1033 = b_7 != 0U;
                if(_S1033)
                {
                    bool _S1034 = (_S861.material.roughness) == 0.0f;
                    if(_S1034)
                    {
                        _S939 = true;
                    }
                    else
                    {
                        bool _S1035 = b_7 == 1U;
                        if(_S1035)
                        {
                            _S939 = (_S865.x) == (_S865.y);
                        }
                        else
                        {
                            _S939 = false;
                        }
                    }
                }
                else
                {
                    _S939 = false;
                }
            }
            bool _S1036 = !_S870;
            if(_S1036)
            {
                _S982 = b_7 == 1U;
            }
            else
            {
                _S982 = false;
            }
            if(_S982)
            {
                straight_0 = (_S861.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S983 = _S1036;
            }
            else
            {
                _S983 = false;
            }
            if(_S983)
            {
                _S984 = b_7 == 1U;
            }
            else
            {
                _S984 = false;
            }
            if(_S984)
            {
                _S985 = (_S865.x) == (_S865.y);
            }
            else
            {
                _S985 = false;
            }
            BSDFMaterial _S1037 = _S861.material;
            bool _S1038 = isTranslucent_0(&_S1037);
            if(_S1038)
            {
                _S986 = b_7 == 0U;
            }
            else
            {
                _S986 = false;
            }
            if(_S986)
            {
                _S987 = (dot_0(throughput_8, surface_11.geometry_n)) < 0.0f;
            }
            else
            {
                _S987 = false;
            }
            if(nee_0)
            {
                _S988 = !_S939;
            }
            else
            {
                _S988 = false;
            }
            if(_S988)
            {
                _S989 = !wrong_side_0;
            }
            else
            {
                _S989 = false;
            }
            if(_S989)
            {
                float _S1039 = (&lobe_10)->pdf;
                float3  _S1040 = (&ray_2)->origin;
                float3  _S1041 = _slang_select(_S875, _S690,_S862.smooth_n);
                float3  _S1042 = (&ray_2)->origin;
                FKSurface _S1043 = surface_11;
                float3  _S1044 = - _S862.smooth_n;
                float3  _S1045 = _slang_select(_S987, _S1044,_S862.smooth_n);
                NEEVertex _S1046 = NEEVertex_x24init_0(false, _S1039, _S1040, _S1041, _S1042 + make_float3 (_S1043.geometry_offset) * _S1045);
                nee_vertex_0 = _S1046;
            }
            else
            {
                if(_S870)
                {
                    _S990 = true;
                }
                else
                {
                    bool _S1047 = b_7 != 1U;
                    if(_S1047)
                    {
                        _S990 = true;
                    }
                    else
                    {
                        _S990 = (_S865.x) != (_S865.y);
                    }
                }
                if(_S990)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1048 = b_7 == 0U;
            bool _S1049 = withinInverseFootprint((&lobe_10)->pdf, _S1048, (&prev_0)->cos, (&hit_1)->distance, threshold_2);
            bool _S1050 = roughLobe((&lobe_10)->pdf, _S1048, _S861.material.roughness);
            if(_S900)
            {
                bool _S1051 = !_S1049;
                if(_S1051)
                {
                    return _S691;
                }
                bool _S1052 = _S696 != 1U;
                if(_S1052)
                {
                    _S990 = _S696 != 2U;
                }
                else
                {
                    _S990 = false;
                }
                if(_S990)
                {
                    float _S1053 = (&lobe_10)->pdf;
                    float _S1054 = _slang_select(nee_0, _S1053,0.0f);
                    float _S1055 = escapeWeight_0(_S1054, _S1000);
                    if(_S908)
                    {
                        passes_0 = _S702;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1056 = _slang_select(passes_0, _S1055,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_10)->throughput * make_float3 ((&lobe_10)->pdf)) * r_3->radiance * make_float3 (_S1056) / make_float3 (r_3->jac), density_4 * (&lobe_10)->pdf / r_3->jac);
                }
                float3  _S1057 = throughput_6 * make_float3 ((&lobe_10)->pdf);
                float _S1058 = density_4 * (&lobe_10)->pdf;
                throughput_9 = _S1057;
                density_6 = _S1058;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1059 = (fcptLayers((hit_1)));
            bool _S1060 = b_7 == 1U;
            bool _S1061 = passesLayer_0(_S1059, _S1060, passes_0);
            if(viewed_1)
            {
                _S990 = _S1061;
            }
            else
            {
                _S990 = false;
            }
            if(_S990)
            {
                return _S691;
            }
            if(replay_1)
            {
                _S991 = b_4 <= _S706;
            }
            else
            {
                _S991 = false;
            }
            if(_S991)
            {
                _S992 = _S860;
            }
            else
            {
                _S992 = false;
            }
            if(_S992)
            {
                _S993 = _S1049;
            }
            else
            {
                _S993 = false;
            }
            if(_S993)
            {
                _S994 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S994 = !_S1050;
                }
                else
                {
                    _S994 = false;
                }
            }
            if(_S994)
            {
                return _S691;
            }
            if(viewed_1)
            {
                float3  _S1062 = throughput_9 * ((&lobe_10)->throughput * make_float3 ((&lobe_10)->pdf));
                float _S1063 = (&lobe_10)->pdf;
                throughput_10 = _S1062;
                sky_pdf_2 = _S1063;
            }
            else
            {
                float3  _S1064 = throughput_9 * max_0((&lobe_10)->throughput, _S690);
                throughput_10 = _S1064;
                sky_pdf_2 = density_6;
            }
            bool _S1065 = !replay_1;
            if(_S1065)
            {
                _S995 = !_S891;
            }
            else
            {
                _S995 = false;
            }
            if(_S995)
            {
                _S996 = _S860;
            }
            else
            {
                _S996 = false;
            }
            bool _S1066;
            if(_S996)
            {
                _S1066 = _S1049;
            }
            else
            {
                _S1066 = false;
            }
            float3  chain_throughput_1;
            if(_S1066)
            {
                chain_0 = here_0;
                uint _S1067 = insertBits_0((&chain_0)->path, b_7, 17U, 2U);
                uint _S1068 = _slang_select(nee_0, 1U,0U);
                uint _S1069 = insertBits_0(_S1067, _S1068, 19U, 1U);
                (&chain_0)->path = _S1069;
                float _S1070 = (&chain_0)->jac * (&lobe_10)->pdf;
                (&chain_0)->jac = _S1070;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1071 = surface_11;
            Vertex _S1072 = Vertex_x24init_0(_S1050, b_7, (&lobe_10)->pdf, (F32_abs((dot_0(surface_11.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1072;
            float _S1073 = (&lobe_10)->pdf;
            bool _S1074;
            if(_S1060)
            {
                _S1074 = (_S865.x) == (_S865.y);
            }
            else
            {
                _S1074 = false;
            }
            float sky_pdf_3 = _slang_select(_S1074, sky_pdf_0,_S1073);
            float _S1075 = _slang_select(_S870, 0.0f,sky_pdf_3);
            float _S1076 = widened_0(spread_1, (&lobe_10)->pdf, _S939);
            bool _S1077;
            if(refracted_4)
            {
                _S1077 = !_S987;
            }
            else
            {
                _S1077 = false;
            }
            bool is_inside_7;
            if(_S1077)
            {
                bool _S1078 = !is_inside_6;
                is_inside_7 = _S1078;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1079 = surface_11;
            bool _S1080 = boundsVolume_0(&_S1079);
            bool _S1081;
            if(_S1080)
            {
                _S1081 = !_S1061;
            }
            else
            {
                _S1081 = false;
            }
            if(_S1081)
            {
                FKSurface faced_2 = surface_11;
                float3  _S1082 = - _S1071.geometry_n;
                float3  _S1083 = _slang_select(turned_1, _S1082,_S1071.geometry_n);
                (&faced_2)->geometry_n = _S1083;
                FKMedium _S1084 = Medium_x24init_0(scatter_in_0, extinction_in_0);
                FKSurface _S1085 = faced_2;
                FKMedium _S1086 = _S1084;
                MediumSides _S1087 = mediumSides_0(&_S1085, &_S1086, filling_2, (&ray_2)->unit_direction);
                bool _S1088 = leavesInFront_0((&faced_2)->geometry_n, throughput_8, _S1071.geometry_n);
                float3  _S1089 = _slang_select(_S1088, _S1087.front.scatter,_S1087.behind.scatter);
                scatter_in_0 = _S1089;
                float3  _S1090 = _slang_select(_S1088, _S1087.front.extinction,_S1087.behind.extinction);
                extinction_in_0 = _S1090;
                uint _S1091 = _S1087.fillings.x;
                uint _S1092 = _S1087.fillings.y;
                uint _S1093 = _slang_select(_S1088, _S1092,_S1091);
                bool _S1094 = (fcptVaryingUsed());
                uint _S1095 = _slang_select(_S1094, _S1093,4294967295U);
                filling_2 = _S1095;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1096 = !_S1061;
            if(_S1096)
            {
                FKSurface _S1097 = surface_11;
                float _S1098 = _slang_select(straight_0, 0.0f,_S1097.geometry_offset);
                float3  _S1099 = - _S862.smooth_n;
                bool _S1100 = is_inside_7 != _S987;
                float3  _S1101 = _slang_select(_S1100, _S1099,_S862.smooth_n);
                float3  _S1102 = (&ray_2)->origin + make_float3 (_S1098) * _S1101;
                (&ray_2)->origin = _S1102;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1061;
            viewed_1 = _S985;
            sky_pdf_2 = _S1075;
            spread_4 = _S1076;
            reconnection_0 = reconnection_1;
            is_inside_5 = is_inside_7;
        }
        else
        {
            (&prev_0)->rough = false;
            (&prev_0)->pdf = 0.0f;
            throughput_9 = throughput_6;
            density_6 = density_4;
            passes_0 = false;
            viewed_1 = viewed_0;
            sky_pdf_2 = 0.0f;
            spread_4 = spread_1;
            straight_0 = false;
            is_inside_5 = is_inside_6;
        }
        bool _S1103 = !replay_1;
        float density_7;
        if(_S1103)
        {
            if(_S831)
            {
                float3  _S1104 = throughput_9 * emission_1;
                Reservoir candidate_7 = chain_0;
                uint _S1105 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1106 = _S1105 == 1U;
                if(_S1106)
                {
                    float3  _S1107 = safeDivide(_S1104, chain_throughput_0);
                    (&candidate_7)->radiance = _S1107;
                }
                Reservoir _S1108 = withEnd(candidate_7, 2U, b_4, _S1104);
                offer(sel_1, _S1108, _S1104 * make_float3 (scale_1) / make_float3 (density_6));
            }
            if(_S831)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1109 = survivalProbability(throughput_9, density_6);
                density_7 = _S1109;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1110 = stream(_S718, b_4 + 128U);
            Random _S1111 = pcg(_S1110);
            bool _S1112 = density_7 < (_S1111.value);
            if(_S1112)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1113 = (fcptMaxBounces());
                wrong_side_0 = b_4 >= _S1113;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1114 = density_6 * density_7;
            density_7 = _S1114;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1115 = layer_0 ^ 1U;
        uint _S1116 = _slang_select(passes_0, _S1115,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_1)->distance = 0.0f;
            b_7 = b_4;
            viewed_0 = viewed_1;
            throughput_2 = throughput_9;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_1 = spread_4;
            uint _S1117 = b_7 + 1U;
            b_4 = _S1117;
            layer_0 = _S1116;
            continue;
        }
        FKRay _S1118 = ray_2;
        float _S1119 = distance_5(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S901;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S695 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1120 = _slang_select(wrong_side_0, _S1119,4.294967296e+09f);
        bool _S1121 = !_S870;
        if(straight_0)
        {
            _S938 = true;
        }
        else
        {
            _S938 = _S870;
        }
        FKHit _S1122;
        if(_S938)
        {
            _S1122 = hit_1;
        }
        else
        {
            _S1122 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
        }
        FKHit _S1123 = (fcptTraverseInstanceBVH((_S1118), (_S836), (_S1120), (_S1121), (_S1122), (viewed_1)));
        hit_1 = _S1123;
        if(replay_1)
        {
            _S939 = _S901;
        }
        else
        {
            _S939 = false;
        }
        if(_S939)
        {
            _S982 = _S695 == 1U;
        }
        else
        {
            _S982 = false;
        }
        if(_S982)
        {
            _S983 = ((&hit_1)->instance_index) == (_S707.instance_index);
        }
        else
        {
            _S983 = false;
        }
        if(_S983)
        {
            _S984 = ((&hit_1)->triangle_index) == (_S707.triangle_index);
        }
        else
        {
            _S984 = false;
        }
        if(_S984)
        {
            (&hit_1)->uv = _S707.uv;
            float _S1124 = distance_5(reconnection_0, (&ray_2)->origin);
            (&hit_1)->distance = _S1124;
        }
        if(replay_1)
        {
            _S985 = _S901;
        }
        else
        {
            _S985 = false;
        }
        if(_S985)
        {
            _S986 = _S695 == 3U;
        }
        else
        {
            _S986 = false;
        }
        if(_S986)
        {
            _S987 = ((&hit_1)->instance_index) != 4294967295U;
        }
        else
        {
            _S987 = false;
        }
        if(_S987)
        {
            return _S691;
        }
        Reservoir _S1125 = chain_0;
        uint _S1126 = filling_2;
        for(;;)
        {
            bool _S1127 = (fcptVaryingUsed());
            if(_S1127)
            {
                _S988 = _S1126 != 4294967295U;
            }
            else
            {
                _S988 = false;
            }
            float _S1128;
            if(_S988)
            {
                float _S1129 = (fcptMajorant((_S1126)));
                _S1128 = _S1129;
            }
            else
            {
                _S1128 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S989 = _S901;
            }
            else
            {
                _S989 = false;
            }
            if(_S989)
            {
                _S990 = _S695 == 1U;
            }
            else
            {
                _S990 = false;
            }
            if(_S990)
            {
                _S991 = _S1128 > 0.0f;
            }
            else
            {
                _S991 = false;
            }
            if(_S991)
            {
                ended_0 = _S691;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_3 = width_2;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_7 = b_4;
                _S992 = true;
                break;
            }
            bool _S1130 = (&prev_0)->rough;
            if(_S1130)
            {
                _S992 = !(_S1128 > 0.0f);
            }
            else
            {
                _S992 = false;
            }
            (&prev_0)->rough = _S992;
            uint _S1131 = b_4 + 320U;
            bool _S1132 = b_4 == 4294967295U;
            uint _S1133 = _slang_select(_S1132, 384U,_S1131);
            uint _S1134 = stream(_S718, _S1133);
            uint tracking_1 = _S1134;
            weight_1 = throughput_3;
            glowed_0 = _S690;
            b_7 = b_4;
            throughput_10 = throughput_9;
            density_3 = density_7;
            spread_2 = spread_4;
            width_3 = width_2;
            sky_pdf_1 = sky_pdf_2;
            for(;;)
            {
                if(((&hit_1)->instance_index) != 4294967295U)
                {
                }
                else
                {
                    _S689 = int(2);
                    break;
                }
                uint _S1135 = b_7 + 320U;
                bool _S1136 = b_7 == 4294967295U;
                uint _S1137 = _slang_select(_S1136, 384U,_S1135);
                uint _S1138 = stream(_S718, _S1137);
                Random _S1139 = pcg(_S1138);
                float _S1140 = freeFlight_0(_S1139.value, _S1128);
                if(_S988)
                {
                    float3  _S1141 = (&ray_2)->origin;
                    float3  _S1142 = (&ray_2)->unit_direction;
                    float _S1143 = (&hit_1)->distance;
                    uint _S1144 = _slang_select(_S1136, 0U,b_7);
                    uint _S1145 = (&prev_0)->lobe;
                    uint _S1146 = _slang_select(_S1136, 3U,_S1145);
                    float _S1147 = (fcptTrackMedium((_S1126), (_S1141), (_S1142), (_S1143), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S1144), (_S1146), (_S1136)));
                    spread_3 = _S1147;
                }
                else
                {
                    spread_3 = _S1140;
                }
                bool _S1148 = !(spread_3 < ((&hit_1)->distance));
                if(_S1148)
                {
                    _S689 = int(2);
                    break;
                }
                if(_S988)
                {
                    _S993 = _S1103;
                }
                else
                {
                    _S993 = false;
                }
                if(_S993)
                {
                    float3  _S1149 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1150 = sel_1->glow + _S1149;
                    sel_1->glow = _S1150;
                }
                else
                {
                }
                glowed_0 = _S690;
                uint b_8 = b_7 + 1U;
                float3  _S1151 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1151;
                float3  _S1152 = flightWeight_0(scatter_in_0, extinction_in_0, _S1128, spread_3, true);
                float3  _S1153 = weight_1;
                float3  _S1154 = _slang_select(_S988, _S1153,_S1152);
                float3  throughput_11 = throughput_10 * _S1154;
                uint _S1155 = stream(_S718, b_8 + 320U);
                tracking_1 = _S1155;
                weight_1 = throughput_3;
                float width_6 = width_3 + spread_2 * spread_3;
                float _S1156 = spread_2 + 3.14159274101257324f;
                bool _S1157 = scatterSampled_0(replay_1, b_8, _S706, _S988);
                TreeSample light_4;
                if(_S1157)
                {
                    float3  _S1158 = (&ray_2)->origin;
                    float3  _S1159 = (&ray_2)->unit_direction;
                    float3  _S1160 = (&ray_2)->unit_direction;
                    uint _S1161 = stream(_S718, b_8 + 64U);
                    float3  _S1162 = extinction_in_0;
                    float3  _S1163 = extinction_in_0;
                    uint2  _S1164 = make_uint2 (_S1126);
                    float3  _S1165 = (&ray_2)->unit_direction;
                    uint _S1166 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                    FKHit _S1167 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                    FKHit _S1168 = _S1167;
                    ShadowContext _S1169 = ShadowContext_x24init_0(_S1162, _S1163, _S1164, _S1165, b_8, _S1166, false, spread_3, width_6, &_S1168, false);
                    ShadowContext _S1170 = _S1169;
                    TreeSample _S1171 = sampleLightTree_0(_S1158, _S1159, _S1160, 0.0f, true, _S1161, &_S1170);
                    light_4 = _S1171;
                }
                else
                {
                    light_4 = _S915;
                }
                uint _S1172 = (fcptMaxBounces());
                bool _S1173 = b_8 < _S1172;
                if(_S1173)
                {
                    _S994 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S994 = false;
                }
                float _S1174 = _slang_select(_S994, 0.07957746833562851f,0.0f);
                float3  _S1175 = throughput_11 * light_4.radiance;
                float _S1176 = powerHeuristic(light_4.density, _S1174);
                float3  _S1177 = _S1175 * make_float3 (0.07957746833562851f * _S1176);
                float3  _S1178 = _slang_select(_S1157, _S1177,_S690);
                if(replay_1)
                {
                    _S995 = b_8 == _S706;
                }
                else
                {
                    _S995 = false;
                }
                if(_S995)
                {
                    bool _S1179 = _S695 == 2U;
                    if(_S1179)
                    {
                        float _S1180 = rgb_to_greyscale(_S1178);
                        _S996 = _S1180 > 0.0f;
                    }
                    else
                    {
                        _S996 = false;
                    }
                    if(_S996)
                    {
                        Shift _S1181 = Shift_x24init_0(_S1178, 1.0f);
                        _S689 = int(1);
                        ended_0 = _S1181;
                        spread_3 = _S1156;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_5 = b_8;
                        break;
                    }
                    _S689 = int(1);
                    ended_0 = _S691;
                    spread_3 = _S1156;
                    width_4 = width_6;
                    throughput_8 = throughput_11;
                    b_5 = b_8;
                    break;
                }
                if(_S1103)
                {
                    Reservoir candidate_8 = _S1125;
                    uint _S1182 = extractBits_0(_S1125.path, 10U, 2U);
                    bool _S1183 = _S1182 == 1U;
                    if(_S1183)
                    {
                        float3  _S1184 = safeDivide(_S1178, chain_throughput_0);
                        (&candidate_8)->radiance = _S1184;
                    }
                    else
                    {
                        uint _S1185 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                        uint _S1186 = insertBits_0(_S1185, 2U, 10U, 2U);
                        (&candidate_8)->path = _S1186;
                    }
                    Reservoir _S1187 = withEnd(candidate_8, 0U, b_8, _S1178);
                    offer(sel_1, _S1187, _S1178 * make_float3 (scale_1) / make_float3 (density_3));
                    float _S1188 = survivalProbability(throughput_11, density_3);
                    uint _S1189 = stream(_S718, b_8 + 128U);
                    Random _S1190 = pcg(_S1189);
                    bool _S1191 = _S1188 < (_S1190.value);
                    if(_S1191)
                    {
                        _S996 = true;
                    }
                    else
                    {
                        uint _S1192 = (fcptMaxBounces());
                        _S996 = b_8 >= _S1192;
                    }
                    if(_S996)
                    {
                        _S689 = int(1);
                        ended_0 = _S691;
                        spread_3 = _S1156;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_5 = b_8;
                        break;
                    }
                    float _S1193 = density_3 * _S1188;
                    density_3 = _S1193;
                }
                else
                {
                }
                NEEVertex _S1194 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_2)->origin, _S690, (&ray_2)->origin);
                nee_vertex_0 = _S1194;
                uint _S1195 = stream(_S718, b_8);
                float3  _S1196 = isotropic_0(_S1195);
                (&ray_2)->unit_direction = _S1196;
                Vertex _S1197 = scatteredVertex_0(is_inside_5);
                prev_0 = _S1197;
                float _S1198 = (&prev_0)->pdf;
                FKRay _S1199 = ray_2;
                FKHit _S1200 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1201 = (fcptTraverseInstanceBVH((_S1199), (true), (4.294967296e+09f), (false), (_S1200), (false)));
                hit_1 = _S1201;
                b_7 = b_8;
                throughput_10 = throughput_11;
                spread_2 = _S1156;
                width_3 = width_6;
                sky_pdf_1 = _S1198;
            }
            if(_S689 != int(2))
            {
                spread_2 = spread_3;
                width_3 = width_4;
                throughput_10 = throughput_8;
                b_7 = b_5;
                _S992 = true;
                break;
            }
            ended_0 = _S691;
            _S992 = false;
            break;
        }
        if(_S992)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S993 = b_7 == b_4;
        }
        else
        {
            _S993 = false;
        }
        bool _S1202 = ((&hit_1)->instance_index) == 4294967295U;
        if(_S1202)
        {
            bool _S1203 = !(&nee_vertex_0)->none;
            float _S1204 = _slang_select(_S1203, sky_pdf_1,0.0f);
            float _S1205 = escapeWeight_0(_S1204, (&ray_2)->unit_direction);
            float3  _S1206 = environment_0((&ray_2)->unit_direction, b_7, (&prev_0)->lobe);
            float3  _S1207 = throughput_10 * _S1206;
            if(replay_1)
            {
                bool _S1208 = b_7 == _S706;
                if(_S1208)
                {
                    passes_0 = _S695 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1207 * make_float3 (_S1205) / make_float3 (r_3->jac), density_3 / r_3->jac);
                }
                if(_S705)
                {
                    passes_0 = _S702;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_7 == _S693;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !(&prev_0)->rough;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1207 * make_float3 (_S1205), 1.0f);
                }
                return _S691;
            }
            Reservoir candidate_9 = chain_0;
            uint _S1209 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1210 = _S1209 == 1U;
            if(_S1210)
            {
                uint _S1211 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1212 = _S1211 == b_7;
                float _S1213 = _slang_select(_S1212, 1.0f,_S1205);
                float3  _S1214 = safeDivide(_S1207 * make_float3 (_S1213), chain_throughput_0);
                (&candidate_9)->radiance = _S1214;
            }
            else
            {
                bool _S1215 = (&prev_0)->rough;
                if(_S1215)
                {
                    uint _S1216 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                    uint _S1217 = insertBits_0(_S1216, 3U, 10U, 2U);
                    uint _S1218 = insertBits_0(_S1217, (&prev_0)->lobe, 15U, 2U);
                    bool _S1219 = (&prev_0)->inside;
                    uint _S1220 = _slang_select(_S1219, 1U,0U);
                    uint _S1221 = insertBits_0(_S1218, _S1220, 20U, 1U);
                    (&candidate_9)->path = _S1221;
                    (&candidate_9)->jac = (&prev_0)->pdf;
                    (&candidate_9)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1222 = _S1207 * make_float3 (_S1205);
            Reservoir _S1223 = withEnd(candidate_9, 3U, b_7, _S1222);
            offer(sel_1, _S1223, _S1222 * make_float3 (scale_1) / make_float3 (density_3));
            break;
        }
        float3  _S1224 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1224;
        bool _S1225 = (fcptVaryingUsed());
        if(_S1225)
        {
            _S994 = filling_2 != 4294967295U;
        }
        else
        {
            _S994 = false;
        }
        if(_S994)
        {
            if(_S1103)
            {
                float3  _S1226 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1227 = sel_1->glow + _S1226;
                sel_1->glow = _S1227;
            }
            float3  _S1228 = throughput_10 * weight_1;
            throughput_8 = _S1228;
        }
        else
        {
            float3  _S1229 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
            float3  _S1230 = throughput_10 * _S1229;
            throughput_8 = _S1230;
        }
        float _S1231 = width_3 + spread_2 * (&hit_1)->distance;
        viewed_0 = _S993;
        width_2 = _S1231;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1117 = b_7 + 1U;
        b_4 = _S1117;
        layer_0 = _S1116;
    }
    return _S691;
}

static __device__ Shift shift_0(Domain * dom_1, Reservoir * r_4)
{
    Selection _S1232 = (Selection{});
    Selection sel_2 = _S1232;
    bool _S1233 = (r_4->w) <= 0.0f;
    if(_S1233)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1234 = walk_0(dom_1, r_4, true, 0.0f, &sel_2);
    return _S1234;
}

__device__ static const FixedArray<float, 4>  HAIR_TILTS_0 = { {
    -2.0f, 1.0f, 4.0f, 0.0f
} };
__device__ static const FixedArray<float, 4>  HAIR_WIDTHS_0 = { {
    1.0f, 0.5f, 2.0f, 2.0f
} };
static __device__ float3  clamp_1(float3  x_16, float3  minBound_1, float3  maxBound_1)
{
    return min_1(max_0(x_16, minBound_1), maxBound_1);
}

static __device__ float3  tan_0(float3  x_17)
{
    float3  result_8;
    int i_10 = int(0);
    for(;;)
    {
        if(i_10 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_8, i_10) = (F32_tan((_slang_vector_get_element(x_17, i_10))));
        i_10 = i_10 + int(1);
    }
    return result_8;
}

static __device__ float3  acos_0(float3  x_18)
{
    float3  result_9;
    int i_11 = int(0);
    for(;;)
    {
        if(i_11 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_9, i_11) = (F32_acos((_slang_vector_get_element(x_18, i_11))));
        i_11 = i_11 + int(1);
    }
    return result_9;
}

static __device__ float3  abs_0(float3  x_19)
{
    float3  result_10;
    int i_12 = int(0);
    for(;;)
    {
        if(i_12 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_10, i_12) = (F32_abs((_slang_vector_get_element(x_19, i_12))));
        i_12 = i_12 + int(1);
    }
    return result_10;
}

__device__ Random normal_distribution(uint state_3)
{
    Random _S1235 = pcg(state_3);
    Random _S1236 = pcg(_S1235.state);
    float _S1237 = 6.28318548202514648f * _S1235.value;
    float _S1238 = (F32_sqrt((-2.0f * clamp_0((F32_log((_S1236.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1236.state, _S1238 * (F32_cos((_S1237))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1239;
    (&_S1239)->state = state_4;
    (&_S1239)->value = value_2;
    return _S1239;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1240 = normal_distribution(state_5);
    Random _S1241 = normal_distribution(_S1240.state);
    Random _S1242 = normal_distribution(_S1241.state);
    float3  _S1243 = make_float3 (_S1240.value, _S1241.value, _S1242.value);
    float3  _S1244 = ((((_S1243)) * make_float3(rnorm3df(((_S1243)).x, ((_S1243)).y, ((_S1243)).z))));
    return RandomSphere_x24init_0(_S1242.state, _S1244);
}

struct RandomHemisphere
{
    uint state;
    float3  value;
};

static __device__ RandomHemisphere RandomHemisphere_x24init_0(uint state_6, float3  value_3)
{
    RandomHemisphere _S1245;
    (&_S1245)->state = state_6;
    (&_S1245)->value = value_3;
    return _S1245;
}

__device__ RandomHemisphere random_hemisphere(uint state_7, float3  normal_4)
{
    RandomSphere _S1246 = random_sphere(state_7);
    bool _S1247 = (dot_0(_S1246.value, normal_4)) > 0.0f;
    if(_S1247)
    {
        return RandomHemisphere_x24init_0(_S1246.state, _S1246.value);
    }
    else
    {
        float3  _S1248 = negate_0(_S1246.value);
        return RandomHemisphere_x24init_0(_S1246.state, _S1248);
    }
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_15)
{
    float3  _S1249 = p1_0 - p0_0;
    float3  _S1250 = p2_0 - p0_0;
    float2  _S1251 = uv1_0 - uv0_0;
    float2  _S1252 = uv2_0 - uv0_0;
    float _S1253 = _S1251.x;
    float _S1254 = _S1252.y;
    float _S1255 = _S1251.y;
    float _S1256 = _S1252.x;
    float _S1257 = _S1253 * _S1254 - _S1255 * _S1256;
    float _S1258 = 1.0f / _S1257;
    float3  t_1 = (_S1249 * make_float3 (_S1254) - _S1250 * make_float3 (_S1255)) * make_float3 (_S1258);
    float3  _S1259 = (_S1250 * make_float3 (_S1253) - _S1249 * make_float3 (_S1256)) * make_float3 (_S1258);
    float3  _S1260 = t_1 - n_15 * make_float3 (dot_0(n_15, t_1));
    float3  t_2 = ((((_S1260)) * make_float3(rnorm3df(((_S1260)).x, ((_S1260)).y, ((_S1260)).z))));
    bool _S1261 = (dot_0(cross_0(n_15, t_2), _S1259)) > 0.0f;
    float3  t_3;
    if(_S1261)
    {
        float3  _S1262 = negate_0(t_2);
        t_3 = _S1262;
    }
    else
    {
        t_3 = t_2;
    }
    float3  _S1263 = cross_0(n_15, t_3);
    return makeMatrix<float, 3, 3> (t_3, _S1263, n_15);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1264 = t1_0 - t0_0;
    float3  _S1265 = t2_2 - t0_0;
    float3  _S1266 = t2_2 - t1_0;
    float _S1267 = (F32_min((length_0(_S1264)), ((F32_min((length_0(_S1265)), (length_0(_S1266)))))));
    float3  _S1268 = make_float3 (distance_5(position_0, t0_0), distance_5(position_0, t1_0), distance_5(position_0, t2_2));
    float3  _S1269 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1270 = dot_0(geometry_n_5, _S1269);
    float3  _S1271 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1272 = dot_0(geometry_n_5, _S1271);
    float3  _S1273 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1274 = acos_0(abs_0(make_float3 (_S1270, _S1272, dot_0(geometry_n_5, _S1273))));
    float3  _S1275 = clamp_1(tan_0(_S1274), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_0(dot_0(_S1268 * _S1275, uvw_0), 0.0f, _S1267 * 0.125f);
}

__device__ float3  sampleHalfVector(float3  v_6, float3  n_i_5, float alpha_6, uint * random_state_15)
{
    float3  _S1276 = sampleMaterialHalfVector(v_6, n_i_5, alpha_6, AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f)), random_state_15);
    return _S1276;
}

__device__ float3  straightThrough(float3  dir_14, float3  n_16, BSDFMaterial material_16)
{
    float3  _S1277 = negate_0(dir_14);
    float _S1278 = sign_0(dot_0(n_16, _S1277));
    float3  _S1279 = n_16 * make_float3 (_S1278);
    AnisotropicFrame _S1280 = anisotropicFrame(material_16, _S1279);
    bool _S1281 = (_S1280.alphas.x) > 0.0f;
    if(_S1281)
    {
        float _S1282 = material_16.transmission * (1.0f - material_16.metallic);
        float3  _S1283 = negate_0(_S1279);
        float3  _S1284 = anisotropicLocal(dir_14, _S1280.tangent, _S1283);
        float _S1285 = anisotropicG1(_S1284, _S1280.alphas);
        return make_float3 (_S1282 * _S1285) * material_16.albedo;
    }
    float _S1286 = material_16.transmission * (1.0f - material_16.metallic);
    float _S1287 = material_16.roughness;
    float _S1288 = smithG1(_S1287 * _S1287, (F32_abs((dot_0(n_16, dir_14)))));
    return make_float3 (_S1286 * _S1288) * material_16.albedo;
}

__device__ float hairRow(float3  in_dir_10, float3  t_4, float3  out_dir_4, uint p_5, float w_2, float alpha_7, uint nt_0)
{
    uint _S1289 = p_5 % 4U;
    float _S1290 = w_2 * HAIR_WIDTHS_0[_S1289];
    float _S1291 = (F32_asin((clamp_0(dot_0(out_dir_4, t_4), -1.0f, 1.0f)))) - (F32_asin((clamp_0(dot_0(in_dir_10, t_4), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1289] * alpha_7;
    return ((F32_asinh((_S1291 / _S1290))) / (F32_asinh((3.14159274101257324f / _S1290))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_11, float3  t_5, float3  out_dir_5, uint np_0)
{
    float3  _S1292 = worldToTangent(out_dir_5, t_5);
    float3  _S1293 = worldToTangent(in_dir_11, t_5);
    return (F32_frac((((F32_atan2((_S1292.z), (_S1292.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1293.z), (1.17549435082228751e-38f - _S1293.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_12, float3  t_6, uint p_6, float row_0, float column_0, float w_3, float alpha_8, uint nt_1, uint np_1)
{
    float3  _S1294 = worldToTangent(in_dir_12, t_6);
    uint _S1295 = p_6 % 4U;
    float _S1296 = w_3 * HAIR_WIDTHS_0[_S1295];
    float _S1297 = (F32_asin((clamp_0(dot_0(in_dir_12, t_6), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1295] * alpha_8 + _S1296 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1296))))));
    float _S1298 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1294.z), (1.17549435082228751e-38f - _S1294.x)));
    float _S1299 = (F32_cos((_S1297)));
    float3  _S1300 = tangentToWorld(make_float3 (_S1299 * (F32_cos((_S1298))), (F32_sin((_S1297))), _S1299 * (F32_sin((_S1298)))), t_6);
    return _S1300;
}

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_3, float3  end_1)
{
    float _S1301 = sign_0(dot_0(light_n_0, start_3 - end_1));
    return light_n_0 * make_float3 (_S1301 * light_offset_0);
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_17, BSDFMaterial material_17, float coverage_1)
{
    float3  _S1302;
    if((material_17.ior) == 1.0f)
    {
        float3  _S1303 = straightThrough(toward_1, n_17, material_17);
        _S1302 = _S1303;
    }
    else
    {
        _S1302 = make_float3 (0.0f);
    }
    return _S1302 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_5, Shift shifted_0, float mis_0)
{
    Reservoir candidate_10 = r_5;
    float3  _S1304 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_10)->f = _S1304;
    float _S1305 = r_5.jac * shifted_0.jac;
    (&candidate_10)->jac = _S1305;
    offer(sel_3, candidate_10, make_float3 (mis_0) * shifted_0.f * make_float3 (r_5.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_6 = sel_4.r;
    float _S1306 = rgb_to_greyscale((&r_6)->f);
    float _S1307 = sel_4.w_sum / _S1306;
    bool _S1308 = _S1306 > 0.0f;
    float _S1309 = _slang_select(_S1308, _S1307,0.0f);
    (&r_6)->w = _S1309;
    (&r_6)->c = c_1;
    return r_6;
}

static __device__ float interpolate_0(float a_6, float b_9, float t_7)
{
    return a_6 + (b_9 - a_6) * t_7;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S1310 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S1310;
}

__device__ float2  temporalWeights(float c_2, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S1311 = c_2 * p_c_0;
    float _S1312 = c_t_0 * p_t_0;
    return make_float2 (_S1311 / (_S1311 + c_t_0 * g_previous_0), _S1312 / (_S1312 + c_2 * g_current_0));
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

__device__ Shift walk_hook(Domain dom_2, Reservoir r_7, bool replay_2, float scale_2, Selection * sel_5)
{
    Domain _S1313 = dom_2;
    Reservoir _S1314 = r_7;
    Shift _S1315 = walk_0(&_S1313, &_S1314, replay_2, scale_2, sel_5);
    return _S1315;
}

__device__ Shift shift_hook(Domain dom_3, Reservoir r_8)
{
    Domain _S1316 = dom_3;
    Reservoir _S1317 = r_8;
    Shift _S1318 = shift_0(&_S1316, &_S1317);
    return _S1318;
}

#undef Matrix
