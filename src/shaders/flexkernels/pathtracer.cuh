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

static __device__ bool any_0(bool3  x_11)
{
    bool result_4 = false;
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
        if(result_4)
        {
            result_4 = true;
        }
        else
        {
            result_4 = (bool((_slang_vector_get_element(x_11, i_5))));
        }
        i_5 = i_5 + int(1);
    }
    return result_4;
}

static __device__ float escapeShare_0(bool miss_0, bool homogeneous_0, float3  extinction_0)
{
    bool _S539;
    if(miss_0)
    {
        _S539 = homogeneous_0;
    }
    else
    {
        _S539 = false;
    }
    if(_S539)
    {
        _S539 = any_0(extinction_0 == make_float3 (0.0f));
    }
    else
    {
        _S539 = false;
    }
    float _S540 = _slang_select(_S539, 0.5f,0.0f);
    return _S540;
}

static __device__ float freeFlight_0(float u_1, float sigma_0)
{
    return - (F32_log((1.0f - u_1))) / sigma_0;
}

static __device__ float3  exp_0(float3  x_12)
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
        *_slang_vector_get_element_ptr(&result_5, i_6) = (F32_exp((_slang_vector_get_element(x_12, i_6))));
        i_6 = i_6 + int(1);
    }
    return result_5;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_1, float sigma_1, float distance_1, bool scatters_0)
{
    float3  _S541 = exp_0((make_float3 (sigma_1) - extinction_1) * make_float3 (distance_1));
    float3  _S542 = scatter_0 * _S541 / make_float3 (sigma_1);
    float3  _S543 = _slang_select(scatters_0, _S542,_S541);
    return _S543;
}

static __device__ bool scatterSampled_0(bool replay_0, uint b_1, uint stop_0, bool varying_0)
{
    bool _S544 = !replay_0;
    bool _S545;
    if(_S544)
    {
        _S545 = true;
    }
    else
    {
        bool _S546 = b_1 == stop_0;
        if(_S546)
        {
            _S545 = !varying_0;
        }
        else
        {
            _S545 = false;
        }
    }
    return _S545;
}

static __device__ uint arrivalLobe_0(uint b_2, uint prev_lobe_0)
{
    bool _S547 = b_2 > 0U;
    uint _S548 = _slang_select(_S547, prev_lobe_0,3U);
    return _S548;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_8, bool surface_4, float length_2, float width_0, FKHit * own_0, bool fiber_0)
{
    ShadowContext _S549;
    (&_S549)->extinction_behind = extinction_behind_0;
    (&_S549)->extinction_front = extinction_front_0;
    (&_S549)->fillings = fillings_0;
    (&_S549)->side = side_0;
    (&_S549)->depth = depth_1;
    (&_S549)->lobe = lobe_8;
    (&_S549)->surface = surface_4;
    (&_S549)->length = length_2;
    (&_S549)->width = width_0;
    (&_S549)->own = *own_0;
    (&_S549)->fiber = fiber_0;
    return _S549;
}

static __device__ float phaseHG_0(float g_0, float mu_1)
{
    bool _S550 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S550)
    {
        return 0.07957746833562851f;
    }
    float _S551 = g_0 * g_0;
    return (1.0f - _S551) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S551 - 2.0f * g_0 * mu_1), (1.5f)));
}

__device__ float3  safeDivide(float3  a_5, float3  b_3)
{
    float3  _S552 = a_5 / b_3;
    float3  _S553 = make_float3 (0.0f);
    bool3  _S554 = b_3 == _S553;
    float3  _S555 = _slang_select(_S554, _S553,_S552);
    return _S555;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S556 = (1U << count_2) - 1U;
    return (e_2 & (~(_S556 << offset_1))) | ((newbits_0 & _S556) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_0 = r_2;
    uint _S557 = insertBits_0(r_2.path, end_0, 0U, 5U);
    uint _S558 = insertBits_0(_S557, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S558;
    (&candidate_0)->f = f_5;
    return candidate_0;
}

__device__ void offer(Selection * sel_0, Reservoir candidate_1, float3  weight_0)
{
    float _S559 = rgb_to_greyscale(weight_0);
    bool _S560 = _S559 > 0.0f;
    bool _S561;
    if(_S560)
    {
        _S561 = _S559 < 3.00000000549775576e+38f;
    }
    else
    {
        _S561 = false;
    }
    bool _S562 = !_S561;
    if(_S562)
    {
        return;
    }
    bool _S563 = sel_0->sums;
    if(_S563)
    {
        float3  _S564 = sel_0->color + weight_0;
        sel_0->color = _S564;
        return;
    }
    float _S565 = sel_0->w_sum + _S559;
    sel_0->w_sum = _S565;
    float3  _S566 = sel_0->color + weight_0;
    sel_0->color = _S566;
    Random _S567 = pcg(sel_0->random_state);
    sel_0->random_state = _S567.state;
    bool _S568 = (_S567.value * sel_0->w_sum) <= _S559;
    if(_S568)
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
    Random _S569 = pcg(random_state_8);
    Random _S570 = pcg(_S569.state);
    float _S571 = 1.0f - 2.0f * _S569.value;
    float _S572 = (F32_sqrt(((F32_max((1.0f - _S571 * _S571), (0.0f))))));
    float _S573 = 6.28318548202514648f * _S570.value;
    return make_float3 (_S572 * (F32_cos((_S573))), _S572 * (F32_sin((_S573))), _S571);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_9, float * pdf_6)
{
    bool _S574 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S574)
    {
        *pdf_6 = 0.07957746833562851f;
        float3  _S575 = isotropic_0(random_state_9);
        return _S575;
    }
    Random _S576 = pcg(random_state_9);
    Random _S577 = pcg(_S576.state);
    float _S578 = g_1 * g_1;
    float _S579 = 2.0f * g_1;
    float _S580 = (1.0f - _S578) / (1.0f - g_1 + _S579 * _S576.value);
    float _S581 = clamp_0((1.0f + _S578 - _S580 * _S580) / _S579, -1.0f, 1.0f);
    float _S582 = (F32_sqrt(((F32_max((1.0f - _S581 * _S581), (0.0f))))));
    float _S583 = 6.28318548202514648f * _S577.value;
    float _S584 = phaseHG_0(g_1, _S581);
    *pdf_6 = _S584;
    float3  _S585 = tangentToWorld(make_float3 (_S582 * (F32_cos((_S583))), _S581, _S582 * (F32_sin((_S583)))), dir_9);
    float3  _S586 = ((((_S585)) * make_float3(rnorm3df(((_S585)).x, ((_S585)).y, ((_S585)).z))));
    return _S586;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ float3  escaped_0(FKHit * hit_1, uint filling_0, float3  scatter_1, float3  extinction_2, bool varying_used_0, bool outside_used_0)
{
    bool _S587;
    if(varying_used_0)
    {
        _S587 = filling_0 != 4294967295U;
    }
    else
    {
        _S587 = false;
    }
    bool _S588 = !_S587;
    if(outside_used_0)
    {
        _S587 = (hit_1->instance_index) == 4294967295U;
    }
    else
    {
        _S587 = false;
    }
    float _S589 = escapeShare_0(_S587, _S588, extinction_2);
    float3  _S590 = exp_0(- extinction_2 * make_float3 (4.294967296e+09f));
    float _S591 = _S589 + (1.0f - _S589) * (F32_exp((- (scatter_1.x + scatter_1.y + scatter_1.z) / 3.0f * 4.294967296e+09f)));
    float3  _S592 = make_float3 (1.0f);
    float3  _S593 = _S590 / make_float3 (_S591);
    bool _S594 = _S589 > 0.0f;
    float3  _S595 = _slang_select(_S594, _S593,_S590);
    if(_S587)
    {
        _S587 = _S588;
    }
    else
    {
        _S587 = false;
    }
    float3  _S596 = _slang_select(_S587, _S595,_S592);
    return _S596;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2)
{
    BSDFMaterial _S597;
    (&_S597)->albedo = albedo_0;
    (&_S597)->emissive = emissive_0;
    (&_S597)->roughness = roughness_0;
    (&_S597)->metallic = metallic_0;
    (&_S597)->transmission = transmission_0;
    (&_S597)->ior = ior_0;
    (&_S597)->absorption = absorption_0;
    (&_S597)->specular_tint = specular_tint_0;
    (&_S597)->specular_level = specular_level_0;
    (&_S597)->translucent = translucent_0;
    (&_S597)->sheen = sheen_2;
    (&_S597)->sheen_roughness = sheen_roughness_0;
    (&_S597)->anisotropy = anisotropy_0;
    (&_S597)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S597)->tangent = tangent_2;
    return _S597;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_2, float3  extinction_3, float g_2)
{
    FKMedium _S598;
    (&_S598)->scatter = scatter_2;
    (&_S598)->extinction = extinction_3;
    (&_S598)->g = g_2;
    return _S598;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_6, bool skip_0, uint random_state_10, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S599;
    (&_S599)->smooth_n = smooth_n_4;
    (&_S599)->geometry_n = geometry_n_2;
    (&_S599)->geometry_offset = geometry_offset_2;
    (&_S599)->material = *material_6;
    (&_S599)->skip = skip_0;
    (&_S599)->random_state = random_state_10;
    (&_S599)->coverage = coverage_0;
    (&_S599)->encloses = encloses_0;
    (&_S599)->volume = *volume_0;
    (&_S599)->fills = fills_0;
    (&_S599)->hair = hair_0;
    return _S599;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S600 = (&surface_5->material)->emissive;
    float3  _S601 = make_float3 (0.0f);
    bool _S602 = !top_0;
    float3  _S603 = _slang_select(_S602, _S601,_S600);
    (&(&lower_0)->material)->emissive = _S603;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_2)
{
    float _S604 = surface_6->coverage;
    bool _S605 = u_2 < _S604;
    if(_S605)
    {
        return *surface_6;
    }
    float3  _S606 = make_float3 (0.0f);
    float3  _S607 = make_float3 (1.0f);
    BSDFMaterial _S608 = Material_x24init_0(_S606, _S606, 0.0f, 0.0f, 0.0f, 0.0f, _S606, _S607, 1.0f, _S606, _S606, 0.5f, 0.0f, 0.0f, _S606);
    BSDFMaterial material_7 = _S608;
    (&material_7)->albedo = _S607;
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
    bool _S609 = transmission_1 > 0.0f;
    bool _S610;
    if(_S609)
    {
        _S610 = true;
    }
    else
    {
        _S610 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S611;
    if(_S610)
    {
        _S611 = 1.0f;
    }
    else
    {
        _S611 = -1.0f;
    }
    return _S611;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_9)
{
    return (dot_0(dir_10, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_11)
{
    float3  _S612 = surface_7->geometry_n;
    float _S613 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_11);
    FKSurface faced_0 = *surface_7;
    float3  _S614 = surface_7->smooth_n * make_float3 (_S613);
    (&faced_0)->smooth_n = _S614;
    float3  _S615 = _S612 * make_float3 (_S613);
    (&faced_0)->geometry_n = _S615;
    return faced_0;
}

static __device__ float3  max_0(float3  x_13, float3  y_4)
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
        *_slang_vector_get_element_ptr(&result_6, i_7) = (F32_max((_slang_vector_get_element(x_13, i_7)), (_slang_vector_get_element(y_4, i_7))));
        i_7 = i_7 + int(1);
    }
    return result_6;
}

static __device__ float3  log_0(float3  x_14)
{
    float3  result_7;
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
        *_slang_vector_get_element_ptr(&result_7, i_8) = (F32_log((_slang_vector_get_element(x_14, i_8))));
        i_8 = i_8 + int(1);
    }
    return result_7;
}

__device__ float3  beerLambert(float distance_2, float3  absorption_1)
{
    float3  _S616 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_2) * log_0(_S616));
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
    bool _S617;
    if(open_0)
    {
        _S617 = prev_rough_0;
    }
    else
    {
        _S617 = false;
    }
    if(_S617)
    {
        _S617 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S617 = false;
    }
    return _S617;
}

static __device__ float2  vertexEta_0(BSDFMaterial * material_8, float n_dot_v_0)
{
    bool _S618 = n_dot_v_0 < 0.0f;
    float _S619 = material_8->ior;
    float _S620 = _slang_select(_S618, _S619,1.0f);
    float _S621 = _slang_select(_S618, 1.0f,_S619);
    return make_float2 (_S620, _S621);
}

__device__ bool samplesLights(BSDFMaterial material_9)
{
    bool _S622 = (material_9.roughness) > 0.0f;
    bool _S623;
    if(_S622)
    {
        _S623 = true;
    }
    else
    {
        bool _S624 = (material_9.metallic) < 1.0f;
        if(_S624)
        {
            _S623 = (material_9.transmission) < 1.0f;
        }
        else
        {
            _S623 = false;
        }
    }
    return _S623;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_10)
{
    float _S625 = rgb_to_greyscale(material_10->translucent);
    return _S625 > 0.0f;
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
    MediumSides _S626;
    (&_S626)->behind = *behind_0;
    (&_S626)->front = *front_0;
    (&_S626)->fillings = fillings_1;
    (&_S626)->face = face_1;
    return _S626;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_1, float3  dir_12, FKMedium * outside_0)
{
    float3  _S627 = surface_8->geometry_n;
    MediumSides _S628 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_1), surface_8->geometry_n);
    MediumSides sides_0 = _S628;
    bool _S629 = surface_8->encloses;
    if(_S629)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S630 = (dot_0(dir_12, _S627)) > 0.0f;
        if(_S630)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_4, uint filling_2, float3  dir_13, uint depth_2, uint lobe_9, float length_3, float width_1, FKHit * own_1, bool fiber_1, FKMedium * outside_1)
{
    float3  _S631 = surface_9->geometry_n;
    ShadowContext _S632 = ShadowContext_x24init_0(extinction_4, extinction_4, make_uint2 (filling_2), surface_9->geometry_n, depth_2, lobe_9, true, length_3, width_1, own_1, fiber_1);
    bool _S633 = surface_9->encloses;
    ShadowContext context_2;
    if(_S633)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S634 = - _S631;
        float3  _S635 = _slang_select(turned_0, _S634,_S631);
        (&faced_1)->geometry_n = _S635;
        FKMedium _S636 = Medium_x24init_0(make_float3 (0.0f), extinction_4, 0.0f);
        FKSurface _S637 = faced_1;
        FKMedium _S638 = _S636;
        MediumSides _S639 = mediumSides_0(&_S637, &_S638, filling_2, dir_13, outside_1);
        ShadowContext _S640 = ShadowContext_x24init_0(_S639.behind.extinction, _S639.front.extinction, _S639.fillings, _S631, depth_2, lobe_9, true, length_3, width_1, own_1, fiber_1);
        if(turned_0)
        {
            uint2  _S641 = _S639.fillings;
            ShadowContext _S642 = ShadowContext_x24init_0(_S639.front.extinction, _S639.behind.extinction, uint2 {_S641.y, _S641.x}, _S631, depth_2, lobe_9, true, length_3, width_1, own_1, fiber_1);
            context_2 = _S642;
        }
        else
        {
            context_2 = _S640;
        }
    }
    else
    {
        context_2 = _S632;
    }
    return context_2;
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_5, float3  out_dir_1, float3  n_10, float3  g_n_0, BSDFMaterial material_11, float eta_i_5, float eta_o_5, uint random_state_11)
{
    float3  _S643 = negate_0(in_dir_5);
    bool _S644 = (dot_0(g_n_0, _S643) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S644)
    {
        SampleBSDF _S645 = connectBSDF(in_dir_5, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 0U, random_state_11);
        SampleBSDF _S646 = connectBSDF(in_dir_5, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 2U, random_state_11);
        return _S645.throughput * make_float3 (_S645.pdf) + _S646.throughput * make_float3 (_S646.pdf);
    }
    SampleBSDF _S647 = connectBSDF(in_dir_5, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 1U, random_state_11);
    return _S647.throughput * make_float3 (_S647.pdf);
}

__device__ float3  translucentCorrection(float3  in_dir_6, float3  out_dir_2, float3  n_11, float3  g_n_1, BSDFMaterial material_12, float eta_i_6, float eta_o_6, uint random_state_12)
{
    float _S648 = dot_0(n_11, out_dir_2);
    float3  _S649 = negate_0(in_dir_6);
    bool _S650 = (_S648 * dot_0(n_11, _S649)) < 0.0f;
    SampleBSDF _S651 = connectBSDF(in_dir_6, out_dir_2, n_11, material_12, eta_i_6, eta_o_6, 0U, random_state_12);
    float3  _S652 = negate_0(in_dir_6);
    bool _S653 = (dot_0(g_n_1, _S652) * dot_0(g_n_1, out_dir_2)) > 0.0f;
    float3  _S654 = make_float3 (0.0f);
    float3  _S655 = _S651.throughput * make_float3 (_S651.pdf);
    float _S656 = _slang_select(_S653, -1.0f,1.0f);
    float3  _S657 = _S655 * make_float3 (_S656);
    float3  _S658 = _slang_select(_S650, _S657,_S654);
    return _S658;
}

__device__ float3  translucentBSDF(float3  in_dir_7, float3  out_dir_3, float3  n_12, float3  g_n_2, BSDFMaterial material_13, float eta_i_7, float eta_o_7, uint random_state_13)
{
    float3  _S659 = BSDF(in_dir_7, out_dir_3, n_12, g_n_2, material_13, eta_i_7, eta_o_7, random_state_13);
    float3  _S660 = translucentCorrection(in_dir_7, out_dir_3, n_12, g_n_2, material_13, eta_i_7, eta_o_7, random_state_13);
    return _S659 + _S660;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_14, float eta_i_8, float eta_o_8, bool competing_1, uint random_state_14)
{
    bool _S661 = !competing_1;
    bool _S662;
    if(_S661)
    {
        _S662 = true;
    }
    else
    {
        _S662 = (light_2->density) == 0.0f;
    }
    if(_S662)
    {
        bool _S663 = isTranslucent_0(material_14);
        if(_S663)
        {
            float3  _S664 = translucentBSDF(in_dir_8, light_2->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_8, eta_o_8, random_state_14);
            return _S664 * light_2->radiance;
        }
        float3  _S665 = BSDF(in_dir_8, light_2->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_8, eta_o_8, random_state_14);
        return _S665 * light_2->radiance;
    }
    float3  _S666 = light_2->dir;
    bool _S667 = (dot_0(geometry_n_4, - in_dir_8) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    float3  _S668 = neeBSDF(in_dir_8, _S666, smooth_n_5, *material_14, eta_i_8, eta_o_8, _S667, light_2->density, true, random_state_14);
    return _S668 * light_2->radiance * make_float3 (light_2->density);
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S669 = (F32_sqrt((random_1_0)));
    float _S670 = 6.28318548202514648f * random_2_0;
    float _S671 = _S669 * (F32_cos((_S670)));
    float _S672 = _S669 * (F32_sin((_S670)));
    float _S673 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S671 * _S671 - _S672 * _S672))))));
    return make_float3 (_S671, _S673, _S672);
}

static __device__ float3  reflect_0(float3  i_9, float3  n_13)
{
    return i_9 - make_float3 (2.0f * dot_0(n_13, i_9)) * n_13;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_9, float3  n_14, BSDFMaterial material_15, float eta_i_9, float eta_o_9, uint random_init_1, float2  screen_space_0)
{
    uint random_state_15 = random_init_1;
    float3  _S674 = negate_0(in_dir_9);
    float _S675 = dot_0(n_14, _S674);
    float _S676 = sign_0(_S675);
    float3  n_i_4 = n_14 * make_float3 (_S676);
    float _S677 = (F32_abs((_S675)));
    float _S678 = material_15.roughness;
    float _S679 = _S678 * _S678;
    AnisotropicFrame _S680 = anisotropicFrame(material_15, n_i_4);
    float3  _S681 = sampleMaterialHalfVector(_S674, n_i_4, _S679, _S680, &random_state_15);
    BSDFLobes _S682 = bsdfLobes(in_dir_9, _S674, n_i_4, _S681, material_15, eta_i_9, eta_o_9, _S680);
    BSDFLobes lobes_3 = _S682;
    float _S683 = translucentShare(material_15);
    (&lobes_3)->translucent_share = _S683;
    float3  _S684 = make_float3 (1.0f);
    SampleBSDF _S685 = SampleBSDF_x24init_0(_S684, _S684, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S685;
    Random _S686 = pcg(random_state_15);
    random_state_15 = _S686.state;
    bool _S687 = (_S686.value) < ((&lobes_3)->p_diffuse);
    if(_S687)
    {
        Random _S688 = pcg(random_state_15);
        Random _S689 = pcg(_S688.state);
        (&sample_1)->random_state = _S689.state;
        float3  _S690 = sampleCosWeightedHemisphere(_S688.value, _S689.value);
        bool _S691 = (_S686.value) < ((&lobes_3)->p_diffuse * (&lobes_3)->translucent_share);
        float _S692 = _S690.y;
        float _S693 = - _S692;
        float _S694 = _slang_select(_S691, _S693,_S692);
        float3  _S695 = tangentToWorld(make_float3 (_S690.x, _S694, _S690.z), n_i_4);
        (&sample_1)->unit_direction = _S695;
        float3  _S696 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S679, material_15, lobes_3, 0U);
        (&sample_1)->throughput = _S696;
        float _S697 = lobeDensity(_S694, 0.0f, _S677, _S679, lobes_3, eta_i_9, eta_o_9, 0U);
        (&sample_1)->pdf = _S697;
        (&sample_1)->refracted = _S691;
        return sample_1;
    }
    bool _S698 = (_S686.value) < ((&lobes_3)->p_diffuse + (&lobes_3)->p_refract);
    if(_S698)
    {
        (&sample_1)->unit_direction = (&lobes_3)->refracted;
        float _S699 = lobeDensity(0.0f, dot_0((&sample_1)->unit_direction, _S681), _S677, _S679, lobes_3, eta_i_9, eta_o_9, 1U);
        (&sample_1)->pdf = _S699;
        float3  _S700 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S679, material_15, lobes_3, 1U);
        (&sample_1)->throughput = _S700;
        (&sample_1)->random_state = random_state_15;
        (&sample_1)->refracted = true;
        (&sample_1)->lobe = 1U;
        return sample_1;
    }
    float3  _S701 = reflect_0(in_dir_9, _S681);
    float3  _S702 = ((((_S701)) * make_float3(rnorm3df(((_S701)).x, ((_S701)).y, ((_S701)).z))));
    (&sample_1)->unit_direction = _S702;
    float3  _S703 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S679, material_15, lobes_3, 2U);
    (&sample_1)->throughput = _S703;
    (&sample_1)->random_state = random_state_15;
    (&sample_1)->lobe = 2U;
    float _S704 = lobeDensity(0.0f, 0.0f, _S677, _S679, lobes_3, eta_i_9, eta_o_9, 2U);
    (&sample_1)->pdf = _S704;
    return sample_1;
}

__device__ bool withinInverseFootprint(float pdf_7, bool diffuse_0, float prev_cos_0, float distance_4, float threshold_1)
{
    bool _S705 = pdf_7 > 0.0f;
    bool _S706;
    if(_S705)
    {
        if(diffuse_0)
        {
            _S706 = true;
        }
        else
        {
            _S706 = (pdf_7 * prev_cos_0 / (distance_4 * distance_4) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S706 = false;
    }
    return _S706;
}

__device__ bool roughLobe(float pdf_8, bool diffuse_1, float roughness_1)
{
    bool _S707 = pdf_8 > 0.0f;
    bool _S708;
    if(_S707)
    {
        if(diffuse_1)
        {
            _S708 = true;
        }
        else
        {
            _S708 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S708 = false;
    }
    return _S708;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S709 = layers_0 > 1U;
    bool _S710;
    if(_S709)
    {
        _S710 = refracting_0 != passed_0;
    }
    else
    {
        _S710 = false;
    }
    return _S710;
}

static __device__ float widened_0(float spread_0, float pdf_9, bool delta_0)
{
    float _S711 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_9))))), (3.14159274101257324f)));
    bool _S712 = !delta_0;
    float _S713 = _slang_select(_S712, _S711,0.0f);
    return spread_0 + _S713;
}

static __device__ bool boundsVolume_0(FKSurface * surface_10)
{
    return surface_10->encloses;
}

static __device__ bool leavesInFront_0(float3  face_2, float3  dir_14, float3  g_3)
{
    return ((dot_0(dir_14, g_3)) > 0.0f) == ((dot_0(g_3, face_2)) > 0.0f);
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
    bool scatter_3;
    bool is_inside_6;
    bool _S714;
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
    int _S715;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_3;
    float sky_pdf_1;
    float spread_3;
    float width_4;
    uint b_5;
    float3  _S716 = make_float3 (0.0f);
    Shift _S717 = Shift_x24init_0(_S716, 0.0f);
    uint _S718 = r_3->path;
    uint _S719 = extractBits_0(r_3->path, 0U, 5U);
    uint _S720 = extractBits_0(_S718, 5U, 5U);
    uint _S721 = extractBits_0(_S718, 10U, 2U);
    uint _S722 = extractBits_0(_S718, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S723 = _S722 >= 3U;
        uint _S724 = _slang_select(_S723, 1U,0U);
        uint _S725 = _S719 + _S724;
        uint _S726 = (fcptMaxBounces());
        passes_0 = _S725 > _S726;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S717;
    }
    uint _S727 = _S720 - 1U;
    bool _S728 = _S722 == 3U;
    uint _S729 = _slang_select(_S728, 1U,0U);
    uint _S730 = _S719 + _S729;
    bool _S731 = _S721 == 0U;
    uint _S732 = _slang_select(_S731, _S730,_S727);
    FKHit _S733 = (fcptReservoirHit((*r_3)));
    float3  _S734 = dom_0->x0;
    float3  _S735 = dom_0->x1 - dom_0->x0;
    float3  _S736 = ((((_S735)) * make_float3(rnorm3df(((_S735)).x, ((_S735)).y, ((_S735)).z))));
    FKRay _S737 = Ray_x24init_0(dom_0->x1, _S736);
    FKRay ray_2 = _S737;
    FKHit hit_2 = dom_0->hit;
    float3  scatter_in_0 = _S716;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S716;
    float3  extinction_in_0 = _S716;
    float g_in_0 = 0.0f;
    uint filling_3 = 4294967295U;
    float _S738 = dom_0->spread;
    float _S739 = dom_0->width;
    float _S740 = length_0(_S735);
    NEEVertex _S741 = NEEVertex_x24init_0(true, 0.0f, _S716, _S716, _S716);
    NEEVertex nee_vertex_0 = _S741;
    Vertex _S742 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S742;
    Reservoir _S743 = (Reservoir{});
    Reservoir chain_0 = _S743;
    uint _S744 = r_3->seed;
    (&chain_0)->seed = r_3->seed;
    (&ray_2)->origin = _S734;
    (&hit_2)->distance = _S740;
    FKMedium _S745 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_2)->distance), (&filling_3)));
    uint _S746 = filling_3;
    bool _S747 = (fcptVaryingUsed());
    uint _S748 = _slang_select(_S747, _S746,4294967295U);
    filling_3 = _S748;
    scatter_in_0 = _S745.scatter;
    extinction_in_0 = _S745.extinction;
    g_in_0 = _S745.g;
    Reservoir _S749 = chain_0;
    uint _S750 = filling_3;
    for(;;)
    {
        bool _S751 = (fcptVaryingUsed());
        if(_S751)
        {
            passes_0 = _S750 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S752 = (fcptMajorant((_S750)));
            spread_1 = _S752;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S732;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S721 == 1U;
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
            ended_0 = _S717;
            sky_pdf_0 = 0.0f;
            spread_1 = _S738;
            width_2 = _S739;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_4 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S753 = (&prev_0)->rough;
        if(_S753)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S754 = stream(_S744, 384U);
        uint tracking_0 = _S754;
        weight_1 = throughput_3;
        glowed_0 = _S716;
        bool _S755 = (fcptOutsideUsed());
        b_4 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_2 = _S738;
        width_2 = _S739;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            bool _S756 = ((&hit_2)->instance_index) != 4294967295U;
            if(_S756)
            {
                turned_1 = true;
            }
            else
            {
                if(_S755)
                {
                    turned_1 = spread_1 > 0.0f;
                }
                else
                {
                    turned_1 = false;
                }
                if(turned_1)
                {
                    is_inside_5 = !passes_0;
                }
                else
                {
                    is_inside_5 = false;
                }
                turned_1 = is_inside_5;
            }
            if(turned_1)
            {
            }
            else
            {
                _S715 = int(1);
                break;
            }
            if(_S755)
            {
                is_inside_5 = ((&hit_2)->instance_index) == 4294967295U;
            }
            else
            {
                is_inside_5 = false;
            }
            float _S757 = (&hit_2)->distance;
            float _S758 = _slang_select(is_inside_5, 4.294967296e+09f,_S757);
            float _S759 = escapeShare_0(is_inside_5, !passes_0, extinction_in_0);
            uint _S760 = b_4 + 320U;
            bool _S761 = b_4 == 4294967295U;
            uint _S762 = _slang_select(_S761, 384U,_S760);
            uint _S763 = stream(_S744, _S762);
            Random _S764 = pcg(_S763);
            float _S765 = 1.0f - _S759;
            float _S766 = freeFlight_0((_S764.value - _S759) / _S765, spread_1);
            bool _S767 = (_S764.value) < _S759;
            float _S768 = _slang_select(_S767, 4.294967296e+09f,_S766);
            if(passes_0)
            {
                float3  _S769 = (&ray_2)->origin;
                float3  _S770 = (&ray_2)->unit_direction;
                float _S771 = (&hit_2)->distance;
                uint _S772 = _slang_select(_S761, 0U,b_4);
                uint _S773 = (&prev_0)->lobe;
                uint _S774 = _slang_select(_S761, 3U,_S773);
                float _S775 = (fcptTrackMedium((_S750), (_S769), (_S770), (_S771), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S772), (_S774), (_S761)));
                geometry_density_2 = _S775;
            }
            else
            {
                geometry_density_2 = _S768;
            }
            bool _S776 = !(geometry_density_2 < _S758);
            if(_S776)
            {
                _S715 = int(1);
                break;
            }
            if(passes_0)
            {
                viewed_0 = !replay_1;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                float3  _S777 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S778 = sel_1->glow + _S777;
                sel_1->glow = _S778;
            }
            else
            {
            }
            glowed_0 = _S716;
            uint b_6 = b_4 + 1U;
            float3  _S779 = (&ray_2)->origin + make_float3 (geometry_density_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S779;
            float3  _S780 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, geometry_density_2, true);
            float3  _S781 = _S780 / make_float3 (_S765);
            float3  _S782 = weight_1;
            float3  _S783 = _slang_select(passes_0, _S782,_S781);
            float3  throughput_4 = throughput_2 * _S783;
            uint _S784 = stream(_S744, b_6 + 320U);
            tracking_0 = _S784;
            weight_1 = throughput_3;
            float width_5 = width_2 + threshold_2 * geometry_density_2;
            float _S785 = threshold_2 + 3.14159274101257324f;
            bool _S786 = scatterSampled_0(replay_1, b_6, _S732, passes_0);
            TreeSample _S787 = TreeSample_x24init_0(_S716, _S716, 0.0f, 0U);
            if(_S786)
            {
                float3  _S788 = (&ray_2)->origin;
                float3  _S789 = (&ray_2)->unit_direction;
                float3  _S790 = (&ray_2)->unit_direction;
                uint _S791 = stream(_S744, b_6 + 64U);
                float3  _S792 = extinction_in_0;
                float3  _S793 = extinction_in_0;
                uint2  _S794 = make_uint2 (_S750);
                float3  _S795 = (&ray_2)->unit_direction;
                uint _S796 = arrivalLobe_0(b_6, (&prev_0)->lobe);
                FKHit _S797 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S798 = _S797;
                ShadowContext _S799 = ShadowContext_x24init_0(_S792, _S793, _S794, _S795, b_6, _S796, false, geometry_density_2, width_5, &_S798, false);
                ShadowContext _S800 = _S799;
                TreeSample _S801 = sampleLightTree_0(_S788, _S789, _S790, 0.0f, true, _S791, &_S800);
                light_3 = _S801;
            }
            else
            {
                light_3 = _S787;
            }
            float _S802 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S803 = (fcptMaxBounces());
            bool _S804 = b_6 < _S803;
            if(_S804)
            {
                scatter_3 = (light_3.density) > 0.0f;
            }
            else
            {
                scatter_3 = false;
            }
            float _S805 = _slang_select(scatter_3, _S802,0.0f);
            float3  _S806 = throughput_4 * light_3.radiance;
            float _S807 = powerHeuristic(light_3.density, _S805);
            float3  _S808 = _S806 * make_float3 (_S802 * _S807);
            float3  _S809 = _slang_select(_S786, _S808,_S716);
            if(replay_1)
            {
                is_inside_6 = b_6 == _S732;
            }
            else
            {
                is_inside_6 = false;
            }
            if(is_inside_6)
            {
                bool _S810 = _S721 == 2U;
                if(_S810)
                {
                    float _S811 = rgb_to_greyscale(_S809);
                    passes_0 = _S811 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S812 = Shift_x24init_0(_S809, 1.0f);
                    _S715 = int(0);
                    ended_0 = _S812;
                    spread_1 = _S785;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                _S715 = int(0);
                ended_0 = _S717;
                spread_1 = _S785;
                geometry_density_2 = width_5;
                chain_throughput_0 = throughput_4;
                layer_0 = b_6;
                break;
            }
            bool _S813 = !replay_1;
            if(_S813)
            {
                Reservoir candidate_2 = _S749;
                uint _S814 = extractBits_0(_S749.path, 10U, 2U);
                bool _S815 = _S814 == 1U;
                if(_S815)
                {
                    float3  _S816 = safeDivide(_S809, _S716);
                    (&candidate_2)->radiance = _S816;
                }
                else
                {
                    uint _S817 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                    uint _S818 = insertBits_0(_S817, 2U, 10U, 2U);
                    (&candidate_2)->path = _S818;
                }
                Reservoir _S819 = withEnd(candidate_2, 0U, b_6, _S809);
                offer(sel_1, _S819, _S809 * make_float3 (scale_1) / make_float3 (density_2));
                float _S820 = survivalProbability(throughput_4, density_2);
                uint _S821 = stream(_S744, b_6 + 128U);
                Random _S822 = pcg(_S821);
                bool _S823 = _S820 < (_S822.value);
                if(_S823)
                {
                    _S714 = true;
                }
                else
                {
                    uint _S824 = (fcptMaxBounces());
                    _S714 = b_6 >= _S824;
                }
                if(_S714)
                {
                    _S715 = int(0);
                    ended_0 = _S717;
                    spread_1 = _S785;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                float _S825 = density_2 * _S820;
                density_2 = _S825;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S826 = stream(_S744, b_6);
            float3  _S827 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S826, &phase_pdf_0);
            (&ray_2)->unit_direction = _S827;
            NEEVertex _S828 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S716, (&ray_2)->origin);
            nee_vertex_0 = _S828;
            Vertex _S829 = scatteredVertex_0(false);
            prev_0 = _S829;
            float _S830 = (&prev_0)->pdf;
            FKRay _S831 = ray_2;
            FKHit _S832 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S833 = (fcptTraverseInstanceBVH((_S831), (true), (4.294967296e+09f), (false), (_S832), (false)));
            hit_2 = _S833;
            b_4 = b_6;
            throughput_2 = throughput_4;
            threshold_2 = _S785;
            width_2 = width_5;
            sky_pdf_0 = _S830;
        }
        if(_S715 != int(1))
        {
            width_2 = geometry_density_2;
            throughput_2 = chain_throughput_0;
            b_4 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S717;
        spread_1 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S834 = b_4 == 4294967295U;
    bool _S835 = (fcptVaryingUsed());
    bool _S836 = (fcptOutsideUsed());
    FKHit _S837 = hit_2;
    float3  _S838 = escaped_0(&_S837, filling_3, scatter_in_0, extinction_in_0, _S835, _S836);
    float3  throughput_5 = throughput_2 * _S838;
    bool _S839 = ((&hit_2)->instance_index) == 4294967295U;
    if(_S839)
    {
        bool _S840 = !(&nee_vertex_0)->none;
        float _S841 = _slang_select(_S840, sky_pdf_0,0.0f);
        float _S842 = escapeWeight_0(_S841, (&ray_2)->unit_direction);
        float3  _S843 = (&ray_2)->unit_direction;
        uint _S844 = (&prev_0)->lobe;
        uint _S845 = _slang_select(_S834, 3U,_S844);
        float3  _S846 = environment_0(_S843, b_4, _S845);
        float3  _S847 = throughput_5 * _S846;
        if(replay_1)
        {
            bool _S848 = b_4 == _S732;
            if(_S848)
            {
                passes_0 = _S721 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S847 * make_float3 (_S842) / make_float3 (r_3->jac), density_2 / r_3->jac);
            }
            if(_S731)
            {
                passes_0 = _S728;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_4 == _S719;
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
                return Shift_x24init_0(_S847 * make_float3 (_S842), 1.0f);
            }
            return _S717;
        }
        Reservoir candidate_3 = chain_0;
        uint _S849 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S850 = _S849 == 1U;
        if(_S850)
        {
            uint _S851 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S852 = _S851 == b_4;
            float _S853 = _slang_select(_S852, 1.0f,_S842);
            float3  _S854 = safeDivide(_S847 * make_float3 (_S853), _S716);
            (&candidate_3)->radiance = _S854;
        }
        else
        {
            bool _S855 = (&prev_0)->rough;
            if(_S855)
            {
                uint _S856 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                uint _S857 = insertBits_0(_S856, 3U, 10U, 2U);
                uint _S858 = insertBits_0(_S857, (&prev_0)->lobe, 15U, 2U);
                bool _S859 = (&prev_0)->inside;
                uint _S860 = _slang_select(_S859, 1U,0U);
                uint _S861 = insertBits_0(_S858, _S860, 20U, 1U);
                (&candidate_3)->path = _S861;
                (&candidate_3)->jac = (&prev_0)->pdf;
                (&candidate_3)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S862 = _S847 * make_float3 (_S842);
        Reservoir _S863 = withEnd(candidate_3, 3U, b_4, _S862);
        offer(sel_1, _S863, _S862 * make_float3 (scale_1) / make_float3 (density_2));
        return _S717;
    }
    float3  _S864 = (&ray_2)->origin + make_float3 ((&hit_2)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S864;
    bool _S865 = (fcptVaryingUsed());
    if(_S865)
    {
        passes_0 = filling_3 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S866 = !replay_1;
        if(_S866)
        {
            float3  _S867 = throughput_5 * glowed_0 / make_float3 (density_2);
            float3  _S868 = sel_1->glow + _S867;
            sel_1->glow = _S868;
        }
        float3  _S869 = throughput_5 * weight_1;
        throughput_2 = _S869;
    }
    else
    {
        float3  _S870 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_2)->distance, false);
        float3  _S871 = throughput_5 * _S870;
        throughput_2 = _S871;
    }
    float _S872 = width_2 + spread_1 * (&hit_2)->distance;
    uint _S873 = b_4 + 1U;
    b_4 = _S873;
    layer_0 = 0U;
    width_2 = _S872;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S716;
    float3  reconnection_0 = _S716;
    viewed_0 = _S834;
    for(;;)
    {
        bool _S874 = ((&hit_2)->is_point_light) == 1U;
        FKMedium _S875 = Medium_x24init_0(_S716, _S716, 0.0f);
        BSDFMaterial _S876 = Material_x24init_0(_S716, _S716, 0.0f, 0.0f, 0.0f, 0.0f, _S716, throughput_3, 1.0f, _S716, _S716, 0.5f, 0.0f, 0.0f, _S716);
        FKMedium _S877 = _S875;
        FKSurface _S878 = Surface_x24init_0(_S716, _S716, 0.0f, &_S876, false, 0U, 1.0f, false, &_S877, 4294967295U, _S716);
        bool _S879 = !_S874;
        float3  throughput_6;
        FKSurface surface_11;
        if(_S879)
        {
            uint _S880 = stream(_S744, b_4);
            uint _S881 = arrivalLobe_0(b_4, (&prev_0)->lobe);
            FKSurface _S882 = (fcptSurfaceAtPath((hit_2), ((&ray_2)->origin), (_S880), (width_2), (layer_0), (b_4), (_S881), ((&ray_2)->unit_direction)));
            bool _S883 = !passes_0;
            FKSurface _S884 = _S882;
            FKSurface _S885 = emitting_0(&_S884, _S883);
            uint _S886 = stream(_S744, b_4 + 256U);
            Random _S887 = pcg(_S886);
            FKSurface _S888 = _S885;
            FKSurface _S889 = uncovered_0(&_S888, _S887.value);
            float _S890 = facingSign(_S889.material.transmission, _S889.geometry_n, (&ray_2)->unit_direction);
            bool _S891 = _S890 < 0.0f;
            bool _S892 = (_S889.material.transmission) > 0.0f;
            if(_S892)
            {
                bool _S893 = arrivesBehind_0((&ray_2)->unit_direction, _S889.geometry_n);
                scatter_3 = _S893;
            }
            else
            {
                scatter_3 = false;
            }
            FKSurface _S894 = _S889;
            FKSurface _S895 = facingRay_0(&_S894, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S896 = arrivesBehind_0((&ray_2)->unit_direction, _S895.geometry_n);
                is_inside_6 = _S896;
            }
            else
            {
                is_inside_6 = scatter_3;
            }
            if(is_inside_6)
            {
                float3  _S897 = beerLambert((&hit_2)->distance, _S895.material.absorption);
                float3  _S898 = throughput_2 * _S897;
                throughput_6 = _S898;
            }
            else
            {
                throughput_6 = throughput_2;
            }
            bool _S899 = !_S895.skip;
            float geometry_density_3 = geometryDensity(_S895.geometry_n, (&ray_2)->unit_direction, (&hit_2)->distance);
            bool _S900 = b_4 == _S873;
            if(_S900)
            {
                float _S901 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S901;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S902 = geometry_density_2;
            scatter_3 = _S899;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S902;
            surface_11 = _S895;
            turned_1 = _S891;
        }
        else
        {
            scatter_3 = false;
            geometry_density_2 = 0.0f;
            surface_11 = _S878;
            throughput_6 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S903 = withinFootprint(scatter_3, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S904 = surface_11;
        FKSurface _S905 = surface_11;
        float _S906 = dot_0(surface_11.smooth_n, - (&ray_2)->unit_direction);
        BSDFMaterial _S907 = _S904.material;
        float2  _S908 = vertexEta_0(&_S907, _S906);
        if(scatter_3)
        {
            bool _S909 = samplesLights(_S904.material);
            _S714 = _S909;
        }
        else
        {
            _S714 = false;
        }
        bool _S910;
        if(passes_0)
        {
            _S910 = true;
        }
        else
        {
            _S910 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S910)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S714;
        }
        bool _S911 = (fcptHairUsed());
        bool _S912;
        if(_S911)
        {
            float3  _S913 = surface_11.hair;
            _S912 = (dot_0(_S913, _S913)) > 0.0f;
        }
        else
        {
            _S912 = false;
        }
        bool _S914;
        if(_S912)
        {
            _S914 = true;
        }
        else
        {
            BSDFMaterial _S915 = _S904.material;
            bool _S916 = isTranslucent_0(&_S915);
            _S914 = _S916;
        }
        bool _S917;
        if(_S914)
        {
            _S917 = true;
        }
        else
        {
            bool _S918 = (_S904.material.transmission) > 0.0f;
            if(_S918)
            {
                uint _S919 = (fcptLayers((hit_2)));
                _S917 = _S919 == 1U;
            }
            else
            {
                _S917 = false;
            }
        }
        float3  emission_0;
        if(_S874)
        {
            float3  _S920 = (fcptCalculatePointLightContrib(((&hit_2)->instance_index)));
            emission_0 = _S920;
        }
        else
        {
            emission_0 = _S904.material.emissive;
        }
        float _S921 = rgb_to_greyscale(emission_0);
        bool _S922 = _S921 > 0.0f;
        float3  emission_1;
        if(_S922)
        {
            NEEVertex _S923 = nee_vertex_0;
            FKHit _S924 = hit_2;
            float _S925 = emissionWeight_0(&_S923, &_S924, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S925);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S926;
        if(replay_1)
        {
            _S926 = _S721 == 1U;
        }
        else
        {
            _S926 = false;
        }
        bool _S927;
        if(_S926)
        {
            _S927 = b_4 > _S720;
        }
        else
        {
            _S927 = false;
        }
        bool _S928;
        if(_S927)
        {
            _S928 = b_4 == _S719;
        }
        else
        {
            _S928 = false;
        }
        bool _S929;
        if(_S928)
        {
            bool _S930 = _S722 == 1U;
            if(_S930)
            {
                _S929 = true;
            }
            else
            {
                _S929 = _S722 == 2U;
            }
        }
        else
        {
            _S929 = false;
        }
        if(_S929)
        {
            bool _S931 = _S874 != (_S722 == 2U);
            if(_S931)
            {
                return _S717;
            }
            return Shift_x24init_0(throughput_6 * emission_1 / make_float3 (r_3->jac), density_2 / r_3->jac);
        }
        uint _S932 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S933 = _S932 == 1U;
        Reservoir here_0 = chain_0;
        uint _S934 = insertBits_0(0U, b_4, 5U, 5U);
        uint _S935 = insertBits_0(_S934, 1U, 10U, 2U);
        uint _S936 = insertBits_0(_S935, (&prev_0)->lobe, 15U, 2U);
        bool _S937 = (&prev_0)->inside;
        uint _S938 = _slang_select(_S937, 1U,0U);
        uint _S939 = insertBits_0(_S936, _S938, 20U, 1U);
        (&here_0)->path = _S939;
        float _S940 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S940;
        fcptWithReservoirHit((&here_0), (&hit_2));
        bool _S941;
        if(replay_1)
        {
            _S941 = _S721 == 1U;
        }
        else
        {
            _S941 = false;
        }
        bool _S942;
        if(_S941)
        {
            _S942 = b_4 == _S720;
        }
        else
        {
            _S942 = false;
        }
        bool _S943 = b_4 == _S732;
        bool _S944;
        if(_S943)
        {
            bool _S945 = !scatter_3;
            if(_S945)
            {
                _S944 = true;
            }
            else
            {
                bool _S946 = _S721 != 1U;
                if(_S946)
                {
                    _S944 = _S721 != 3U;
                }
                else
                {
                    _S944 = false;
                }
            }
        }
        else
        {
            _S944 = false;
        }
        bool _S947;
        if(_S944)
        {
            _S947 = _S721 == 2U;
        }
        else
        {
            _S947 = false;
        }
        bool _S948;
        if(_S947)
        {
            _S948 = !_S903;
        }
        else
        {
            _S948 = false;
        }
        bool _S949;
        if(_S948)
        {
            _S949 = _S722 != 4U;
        }
        else
        {
            _S949 = false;
        }
        bool _S950 = _S720 == _S719;
        bool _S951;
        if(_S950)
        {
            _S951 = _S722 == 0U;
        }
        else
        {
            _S951 = false;
        }
        bool _S952;
        if(_S951)
        {
            _S952 = ((&hit_2)->instance_index) == (_S733.instance_index);
        }
        else
        {
            _S952 = false;
        }
        bool _S953;
        if(_S952)
        {
            _S953 = ((&hit_2)->triangle_index) == (_S733.triangle_index);
        }
        else
        {
            _S953 = false;
        }
        bool _S954;
        if(_S953)
        {
            _S954 = _S903;
        }
        else
        {
            _S954 = false;
        }
        bool _S955 = _slang_select(_S942, _S954,_S949);
        bool _S956;
        if(nee_0)
        {
            _S956 = _slang_select(replay_1, _S955,scatter_3);
        }
        else
        {
            _S956 = false;
        }
        TreeSample _S957 = TreeSample_x24init_0(_S716, _S716, 0.0f, 0U);
        float3  throughput_7;
        float3  lit_0;
        if(_S956)
        {
            float3  _S958 = (&ray_2)->origin;
            if(_S912)
            {
                throughput_7 = _S716;
            }
            else
            {
                throughput_7 = _S905.smooth_n;
            }
            FKSurface _S959 = surface_11;
            uint _S960 = stream(_S744, b_4 + 64U);
            uint _S961 = arrivalLobe_0(b_4, (&prev_0)->lobe);
            FKMedium _S962 = (fcptOutsideMedium());
            FKSurface _S963 = surface_11;
            FKHit _S964 = hit_2;
            FKMedium _S965 = _S962;
            ShadowContext _S966 = shadowContext_0(&_S963, turned_1, extinction_in_0, filling_3, (&ray_2)->unit_direction, b_4, _S961, (&hit_2)->distance, width_2, &_S964, _S912, &_S965);
            ShadowContext _S967 = _S966;
            TreeSample _S968 = sampleLightTree_0(_S958, throughput_7, surface_11.geometry_n, surface_11.geometry_offset, _S917, _S960, &_S967);
            bool _S969 = any_0((_S968.radiance) != _S716);
            if(_S969)
            {
                if(_S912)
                {
                    uint _S970 = (fcptMaxBounces());
                    bool _S971 = b_4 < _S970;
                    FKSurface _S972 = surface_11;
                    TreeSample _S973 = _S968;
                    float3  _S974 = hairLight_0(&_S972, (&ray_2)->unit_direction, &_S973, _S971);
                    lit_0 = _S974;
                }
                else
                {
                    float _S975 = _S908.x;
                    float _S976 = _S908.y;
                    uint _S977 = (fcptMaxBounces());
                    bool _S978 = b_4 < _S977;
                    TreeSample _S979 = _S968;
                    BSDFMaterial _S980 = _S904.material;
                    float3  _S981 = lightBSDF_0((&ray_2)->unit_direction, &_S979, _S905.smooth_n, _S959.geometry_n, &_S980, _S975, _S976, _S978, surface_11.random_state);
                    lit_0 = _S981;
                }
            }
            else
            {
                lit_0 = _S716;
            }
            light_3 = _S968;
        }
        else
        {
            light_3 = _S957;
            lit_0 = _S716;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S982;
        bool _S983;
        float density_4;
        if(_S942)
        {
            bool _S984 = ((&hit_2)->instance_index) != (_S733.instance_index);
            if(_S984)
            {
                viewed_1 = true;
            }
            else
            {
                viewed_1 = ((&hit_2)->triangle_index) != (_S733.triangle_index);
            }
            if(viewed_1)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = !_S903;
            }
            if(refracted_4)
            {
                return _S717;
            }
            float3  throughput_8 = throughput_6 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S950)
            {
                wrong_side_0 = _S722 == 1U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                return Shift_x24init_0(throughput_8 * emission_1 / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            if(_S950)
            {
                _S982 = _S722 == 0U;
            }
            else
            {
                _S982 = false;
            }
            if(_S982)
            {
                bool _S985 = !nee_0;
                if(_S985)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S986 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S986 > 0.0f);
                }
                if(passes_0)
                {
                    return _S717;
                }
                return Shift_x24init_0(throughput_8 * lit_0 / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            if(_S950)
            {
                _S983 = _S722 == 4U;
            }
            else
            {
                _S983 = false;
            }
            if(_S983)
            {
                bool _S987 = !nee_0;
                if(_S987)
                {
                    return _S717;
                }
                float _S988 = environmentPdf_0(r_3->dir);
                float3  _S989 = skyBSDF((&ray_2)->unit_direction, r_3->dir, surface_11, _S908, is_inside_6, _S988, surface_11.random_state);
                return Shift_x24init_0(throughput_8 * _S989 * r_3->radiance / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            uint _S990 = extractBits_0(_S718, 19U, 1U);
            bool _S991 = nee_0 != (_S990 == 1U);
            if(_S991)
            {
                return _S717;
            }
            throughput_7 = throughput_8;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S943;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S992 = !scatter_3;
                if(_S992)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S993 = _S721 != 1U;
                    if(_S993)
                    {
                        refracted_4 = _S721 != 3U;
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
                bool _S994 = _S721 == 2U;
                if(_S994)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S903;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S722 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    uint _S995 = stream(_S744, b_4 + 448U);
                    FKRay _S996 = ray_2;
                    FKSurface _S997 = surface_11;
                    SkySample _S998 = sampleSky_0(&_S996, &_S997, _S908, is_inside_6, _S995, surface_11.random_state);
                    return Shift_x24init_0(throughput_6 * _S998.color, 1.0f);
                }
                if(_S994)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S903;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S999 = rgb_to_greyscale(light_3.radiance);
                    bool _S1000 = !(_S999 > 0.0f);
                    if(_S1000)
                    {
                        return _S717;
                    }
                    return Shift_x24init_0(throughput_6 * lit_0, 1.0f);
                }
                if(_S731)
                {
                    passes_0 = _S722 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S874;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_6 * emission_1, 1.0f);
                }
                if(_S731)
                {
                    passes_0 = _S722 == 1U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = scatter_3;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S903;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_6 * emission_1, 1.0f);
                }
                return _S717;
            }
            else
            {
                bool _S1001 = !replay_1;
                if(_S1001)
                {
                    wrong_side_0 = scatter_3;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1002 = b_4 > 0U;
                    if(_S1002)
                    {
                        Reservoir candidate_4 = chain_0;
                        if(_S933)
                        {
                            float3  _S1003 = safeDivide(throughput_6 * emission_1, chain_throughput_0);
                            (&candidate_4)->radiance = _S1003;
                        }
                        else
                        {
                            if(_S903)
                            {
                                candidate_4 = here_0;
                            }
                        }
                        float3  _S1004 = throughput_6 * emission_1;
                        Reservoir _S1005 = withEnd(candidate_4, 1U, b_4, _S1004);
                        offer(sel_1, _S1005, _S1004 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1006 = throughput_6 * emission_1;
                        float3  _S1007 = sel_1->glow + _S1006;
                        sel_1->glow = _S1007;
                    }
                    if(nee_0)
                    {
                        float3  _S1008 = throughput_6 * lit_0;
                        Reservoir candidate_5 = chain_0;
                        if(_S933)
                        {
                            float3  _S1009 = safeDivide(_S1008, chain_throughput_0);
                            (&candidate_5)->radiance = _S1009;
                        }
                        else
                        {
                            if(_S903)
                            {
                                candidate_5 = here_0;
                                uint _S1010 = insertBits_0((&candidate_5)->path, 1U, 19U, 1U);
                                (&candidate_5)->path = _S1010;
                                (&candidate_5)->dir = light_3.dir;
                                (&candidate_5)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1011 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S1012 = insertBits_0(_S1011, 2U, 10U, 2U);
                                (&candidate_5)->path = _S1012;
                            }
                        }
                        Reservoir _S1013 = withEnd(candidate_5, 0U, b_4, _S1008);
                        offer(sel_1, _S1013, _S1008 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S912)
                        {
                            _S982 = false;
                        }
                        else
                        {
                            bool _S1014 = environmentMapped_0();
                            _S982 = _S1014;
                        }
                    }
                    else
                    {
                        _S982 = false;
                    }
                    if(_S982)
                    {
                        uint _S1015 = (fcptMaxBounces());
                        _S983 = b_4 < _S1015;
                    }
                    else
                    {
                        _S983 = false;
                    }
                    if(_S983)
                    {
                        uint _S1016 = stream(_S744, b_4 + 448U);
                        FKRay _S1017 = ray_2;
                        FKSurface _S1018 = surface_11;
                        SkySample _S1019 = sampleSky_0(&_S1017, &_S1018, _S908, is_inside_6, _S1016, surface_11.random_state);
                        float3  _S1020 = throughput_6 * _S1019.color;
                        Reservoir candidate_6 = chain_0;
                        if(_S933)
                        {
                            float3  _S1021 = safeDivide(_S1020, chain_throughput_0);
                            (&candidate_6)->radiance = _S1021;
                        }
                        else
                        {
                            if(_S903)
                            {
                                candidate_6 = here_0;
                                uint _S1022 = insertBits_0((&candidate_6)->path, 1U, 19U, 1U);
                                (&candidate_6)->path = _S1022;
                                (&candidate_6)->dir = _S1019.dir;
                                (&candidate_6)->radiance = _S1019.radiance;
                            }
                            else
                            {
                                uint _S1023 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S1024 = insertBits_0(_S1023, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1024;
                            }
                        }
                        Reservoir _S1025 = withEnd(candidate_6, 4U, b_4, _S1020);
                        offer(sel_1, _S1025, _S1020 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                }
            }
            throughput_7 = throughput_6;
            density_4 = density_2;
        }
        bool _S1026;
        bool straight_0;
        bool _S1027;
        bool _S1028;
        bool _S1029;
        bool _S1030;
        bool _S1031;
        bool _S1032;
        bool _S1033;
        bool _S1034;
        bool _S1035;
        bool _S1036;
        bool _S1037;
        bool _S1038;
        bool _S1039;
        bool _S1040;
        bool _S1041;
        bool _S1042;
        float density_6;
        float sky_pdf_2;
        float spread_4;
        uint b_7;
        float3  throughput_9;
        float3  throughput_10;
        float3  throughput_11;
        if(scatter_3)
        {
            if(replay_1)
            {
                viewed_1 = _S943;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1043 = extractBits_0(_S718, 15U, 2U);
            uint _S1044 = extractBits_0(_S718, 17U, 2U);
            uint _S1045 = _slang_select(_S942, _S1044,_S1043);
            float3  _S1046 = r_3->dir;
            bool refracted_5 = _S1045 == 1U;
            SampleBSDF _S1047 = SampleBSDF_x24init_0(_S716, _S716, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_10 = _S1047;
            float3  reconnection_1;
            SampleBSDF _S1048;
            if(viewed_1)
            {
                uint _S1049 = extractBits_0(_S718, 20U, 1U);
                bool _S1050 = is_inside_6 != (_S1049 == 1U);
                if(_S1050)
                {
                    return _S717;
                }
                bool _S1051 = _S721 == 1U;
                if(_S1051)
                {
                    float3  _S1052 = (fcptHitPosition((_S733)));
                    throughput_9 = _S1052;
                }
                else
                {
                    throughput_9 = reconnection_0;
                }
                if(refracted_5)
                {
                    refracted_4 = true;
                }
                else
                {
                    BSDFMaterial _S1053 = _S904.material;
                    bool _S1054 = isTranslucent_0(&_S1053);
                    if(_S1054)
                    {
                        refracted_4 = _S1045 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1055 = throughput_9 - (&ray_2)->origin;
                        float3  _S1056 = _slang_select(_S1051, _S1055,_S1046);
                        wrong_side_0 = (dot_0(_S905.smooth_n, _S1056) * _S906) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1051)
                {
                    float3  _S1057 = (&ray_2)->origin;
                    FKSurface _S1058 = surface_11;
                    float3  _S1059 = - _S905.smooth_n;
                    bool _S1060 = is_inside_6 != refracted_4;
                    float3  _S1061 = _slang_select(_S1060, _S1059,_S905.smooth_n);
                    float3  _S1062 = throughput_9 - (_S1057 + make_float3 (_S1058.geometry_offset) * _S1061);
                    float3  _S1063 = ((((_S1062)) * make_float3(rnorm3df(((_S1062)).x, ((_S1062)).y, ((_S1062)).z))));
                    reconnection_1 = _S1063;
                }
                else
                {
                    reconnection_1 = _S1046;
                }
                if(_S912)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1064 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_11.geometry_n);
                    wrong_side_0 = _S1064;
                }
                if(wrong_side_0)
                {
                    return _S717;
                }
                float3  _S1065 = throughput_9;
                throughput_9 = reconnection_1;
                b_7 = _S1045;
                wrong_side_0 = false;
                reconnection_1 = _S1065;
            }
            else
            {
                bool _S1066 = !_S942;
                if(_S1066)
                {
                    SampleBSDF bsdf_sampled_0;
                    if(_S912)
                    {
                        SampleBSDF _S1067 = (fcptSampleHair((surface_11.hair), (_S904.material.albedo), (_S904.material.specular_tint), ((&ray_2)->unit_direction), (surface_11.random_state)));
                        _S1048 = _S1067;
                    }
                    else
                    {
                        SampleBSDF _S1068 = sampleBSDF((&ray_2)->unit_direction, _S905.smooth_n, _S904.material, _S908.x, _S908.y, surface_11.random_state, make_float2 (0.0f));
                        _S1048 = _S1068;
                    }
                    bsdf_sampled_0 = _S1048;
                    if(_S912)
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
                            return _S717;
                        }
                        break;
                    }
                    if(_S912)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1069 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_11.geometry_n);
                        wrong_side_0 = _S1069;
                    }
                    if(wrong_side_0)
                    {
                        _S982 = (_S904.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S982 = false;
                    }
                    if(_S982)
                    {
                        SampleBSDF _S1070 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n, _S904.material, _S908.x, _S908.y, (&bsdf_sampled_0)->random_state, make_float2 (0.0f));
                        (&bsdf_sampled_0)->unit_direction = _S1070.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1070.refracted;
                        (&bsdf_sampled_0)->throughput = _S1070.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1071 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n)) * surface_11.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1071;
                        }
                    }
                    uint _S1072 = (&bsdf_sampled_0)->lobe;
                    float3  _S1073 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1074 = (&bsdf_sampled_0)->refracted;
                    lobe_10 = bsdf_sampled_0;
                    float _S1075 = (&bsdf_sampled_0)->pdf;
                    float _S1076 = _slang_select(wrong_side_0, 0.0f,_S1075);
                    (&lobe_10)->pdf = _S1076;
                    throughput_9 = _S1073;
                    b_7 = _S1072;
                    refracted_4 = _S1074;
                }
                else
                {
                    throughput_9 = _S1046;
                    b_7 = _S1045;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S982 = true;
            }
            else
            {
                _S982 = _S942;
            }
            if(_S982)
            {
                if(_S912)
                {
                    SampleBSDF _S1077 = (fcptConnectHair((surface_11.hair), (_S904.material.albedo), (_S904.material.specular_tint), ((&ray_2)->unit_direction), (throughput_9)));
                    _S1048 = _S1077;
                }
                else
                {
                    SampleBSDF _S1078 = connectBSDF((&ray_2)->unit_direction, throughput_9, _S905.smooth_n, _S904.material, _S908.x, _S908.y, b_7, surface_11.random_state);
                    _S1048 = _S1078;
                }
                lobe_10 = _S1048;
            }
            if(_S912)
            {
                _S983 = false;
            }
            else
            {
                bool _S1079 = b_7 != 0U;
                if(_S1079)
                {
                    bool _S1080 = (_S904.material.roughness) == 0.0f;
                    if(_S1080)
                    {
                        _S983 = true;
                    }
                    else
                    {
                        bool _S1081 = b_7 == 1U;
                        if(_S1081)
                        {
                            _S983 = (_S908.x) == (_S908.y);
                        }
                        else
                        {
                            _S983 = false;
                        }
                    }
                }
                else
                {
                    _S983 = false;
                }
            }
            bool _S1082 = !_S912;
            if(_S1082)
            {
                _S1026 = b_7 == 1U;
            }
            else
            {
                _S1026 = false;
            }
            if(_S1026)
            {
                straight_0 = (_S904.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1027 = _S1082;
            }
            else
            {
                _S1027 = false;
            }
            if(_S1027)
            {
                _S1028 = b_7 == 1U;
            }
            else
            {
                _S1028 = false;
            }
            if(_S1028)
            {
                _S1029 = (_S908.x) == (_S908.y);
            }
            else
            {
                _S1029 = false;
            }
            BSDFMaterial _S1083 = _S904.material;
            bool _S1084 = isTranslucent_0(&_S1083);
            if(_S1084)
            {
                _S1030 = b_7 == 0U;
            }
            else
            {
                _S1030 = false;
            }
            if(_S1030)
            {
                _S1031 = (dot_0(throughput_9, surface_11.geometry_n)) < 0.0f;
            }
            else
            {
                _S1031 = false;
            }
            if(nee_0)
            {
                _S1032 = !_S983;
            }
            else
            {
                _S1032 = false;
            }
            if(_S1032)
            {
                _S1033 = !wrong_side_0;
            }
            else
            {
                _S1033 = false;
            }
            if(_S1033)
            {
                float _S1085 = (&lobe_10)->pdf;
                float3  _S1086 = (&ray_2)->origin;
                float3  _S1087 = _slang_select(_S917, _S716,_S905.smooth_n);
                float3  _S1088 = (&ray_2)->origin;
                FKSurface _S1089 = surface_11;
                float3  _S1090 = - _S905.smooth_n;
                float3  _S1091 = _slang_select(_S1031, _S1090,_S905.smooth_n);
                NEEVertex _S1092 = NEEVertex_x24init_0(false, _S1085, _S1086, _S1087, _S1088 + make_float3 (_S1089.geometry_offset) * _S1091);
                nee_vertex_0 = _S1092;
            }
            else
            {
                if(_S912)
                {
                    _S1034 = true;
                }
                else
                {
                    bool _S1093 = b_7 != 1U;
                    if(_S1093)
                    {
                        _S1034 = true;
                    }
                    else
                    {
                        _S1034 = (_S908.x) != (_S908.y);
                    }
                }
                if(_S1034)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1094 = b_7 == 0U;
            bool _S1095 = withinInverseFootprint((&lobe_10)->pdf, _S1094, (&prev_0)->cos, (&hit_2)->distance, threshold_2);
            bool _S1096 = roughLobe((&lobe_10)->pdf, _S1094, _S904.material.roughness);
            if(_S942)
            {
                bool _S1097 = !_S1095;
                if(_S1097)
                {
                    return _S717;
                }
                bool _S1098 = _S722 != 1U;
                if(_S1098)
                {
                    _S1034 = _S722 != 2U;
                }
                else
                {
                    _S1034 = false;
                }
                if(_S1034)
                {
                    float _S1099 = (&lobe_10)->pdf;
                    float _S1100 = _slang_select(nee_0, _S1099,0.0f);
                    float _S1101 = escapeWeight_0(_S1100, _S1046);
                    if(_S950)
                    {
                        passes_0 = _S728;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1102 = _slang_select(passes_0, _S1101,1.0f);
                    return Shift_x24init_0(throughput_7 * ((&lobe_10)->throughput * make_float3 ((&lobe_10)->pdf)) * r_3->radiance * make_float3 (_S1102) / make_float3 (r_3->jac), density_4 * (&lobe_10)->pdf / r_3->jac);
                }
                float3  _S1103 = throughput_7 * make_float3 ((&lobe_10)->pdf);
                float _S1104 = density_4 * (&lobe_10)->pdf;
                throughput_10 = _S1103;
                density_6 = _S1104;
            }
            else
            {
                throughput_10 = throughput_7;
                density_6 = density_4;
            }
            uint _S1105 = (fcptLayers((hit_2)));
            bool _S1106 = b_7 == 1U;
            bool _S1107 = passesLayer_0(_S1105, _S1106, passes_0);
            if(viewed_1)
            {
                _S1034 = _S1107;
            }
            else
            {
                _S1034 = false;
            }
            if(_S1034)
            {
                return _S717;
            }
            if(replay_1)
            {
                _S1035 = b_4 <= _S732;
            }
            else
            {
                _S1035 = false;
            }
            if(_S1035)
            {
                _S1036 = _S903;
            }
            else
            {
                _S1036 = false;
            }
            if(_S1036)
            {
                _S1037 = _S1095;
            }
            else
            {
                _S1037 = false;
            }
            if(_S1037)
            {
                _S1038 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1038 = !_S1096;
                }
                else
                {
                    _S1038 = false;
                }
            }
            if(_S1038)
            {
                return _S717;
            }
            if(viewed_1)
            {
                float3  _S1108 = throughput_10 * ((&lobe_10)->throughput * make_float3 ((&lobe_10)->pdf));
                float _S1109 = (&lobe_10)->pdf;
                throughput_11 = _S1108;
                sky_pdf_2 = _S1109;
            }
            else
            {
                float3  _S1110 = throughput_10 * max_0((&lobe_10)->throughput, _S716);
                throughput_11 = _S1110;
                sky_pdf_2 = density_6;
            }
            bool _S1111 = !replay_1;
            if(_S1111)
            {
                _S1039 = !_S933;
            }
            else
            {
                _S1039 = false;
            }
            if(_S1039)
            {
                _S1040 = _S903;
            }
            else
            {
                _S1040 = false;
            }
            if(_S1040)
            {
                _S1041 = _S1095;
            }
            else
            {
                _S1041 = false;
            }
            float3  chain_throughput_1;
            if(_S1041)
            {
                chain_0 = here_0;
                uint _S1112 = insertBits_0((&chain_0)->path, b_7, 17U, 2U);
                uint _S1113 = _slang_select(nee_0, 1U,0U);
                uint _S1114 = insertBits_0(_S1112, _S1113, 19U, 1U);
                (&chain_0)->path = _S1114;
                float _S1115 = (&chain_0)->jac * (&lobe_10)->pdf;
                (&chain_0)->jac = _S1115;
                (&chain_0)->dir = throughput_9;
                chain_throughput_1 = throughput_11;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1116 = surface_11;
            Vertex _S1117 = Vertex_x24init_0(_S1096, b_7, (&lobe_10)->pdf, (F32_abs((dot_0(surface_11.geometry_n, throughput_9)))), is_inside_6);
            prev_0 = _S1117;
            float _S1118 = (&lobe_10)->pdf;
            if(_S1106)
            {
                _S1042 = (_S908.x) == (_S908.y);
            }
            else
            {
                _S1042 = false;
            }
            float sky_pdf_3 = _slang_select(_S1042, sky_pdf_0,_S1118);
            float _S1119 = _slang_select(_S912, 0.0f,sky_pdf_3);
            float _S1120 = widened_0(spread_1, (&lobe_10)->pdf, _S983);
            bool _S1121;
            if(refracted_4)
            {
                _S1121 = !_S1031;
            }
            else
            {
                _S1121 = false;
            }
            bool is_inside_7;
            if(_S1121)
            {
                bool _S1122 = !is_inside_6;
                is_inside_7 = _S1122;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1123 = surface_11;
            bool _S1124 = boundsVolume_0(&_S1123);
            bool _S1125;
            if(_S1124)
            {
                _S1125 = !_S1107;
            }
            else
            {
                _S1125 = false;
            }
            if(_S1125)
            {
                FKSurface faced_2 = surface_11;
                float3  _S1126 = - _S1116.geometry_n;
                float3  _S1127 = _slang_select(turned_1, _S1126,_S1116.geometry_n);
                (&faced_2)->geometry_n = _S1127;
                FKMedium _S1128 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1129 = (fcptOutsideMedium());
                FKSurface _S1130 = faced_2;
                FKMedium _S1131 = _S1128;
                FKMedium _S1132 = _S1129;
                MediumSides _S1133 = mediumSides_0(&_S1130, &_S1131, filling_3, (&ray_2)->unit_direction, &_S1132);
                bool _S1134 = leavesInFront_0((&faced_2)->geometry_n, throughput_9, _S1116.geometry_n);
                float3  _S1135 = _slang_select(_S1134, _S1133.front.scatter,_S1133.behind.scatter);
                scatter_in_0 = _S1135;
                float3  _S1136 = _slang_select(_S1134, _S1133.front.extinction,_S1133.behind.extinction);
                extinction_in_0 = _S1136;
                float _S1137 = _slang_select(_S1134, _S1133.front.g,_S1133.behind.g);
                g_in_0 = _S1137;
                uint _S1138 = _S1133.fillings.x;
                uint _S1139 = _S1133.fillings.y;
                uint _S1140 = _slang_select(_S1134, _S1139,_S1138);
                bool _S1141 = (fcptVaryingUsed());
                uint _S1142 = _slang_select(_S1141, _S1140,4294967295U);
                filling_3 = _S1142;
            }
            (&ray_2)->unit_direction = throughput_9;
            bool _S1143 = !_S1107;
            if(_S1143)
            {
                FKSurface _S1144 = surface_11;
                float _S1145 = _slang_select(straight_0, 0.0f,_S1144.geometry_offset);
                float3  _S1146 = - _S905.smooth_n;
                bool _S1147 = is_inside_7 != _S1031;
                float3  _S1148 = _slang_select(_S1147, _S1146,_S905.smooth_n);
                float3  _S1149 = (&ray_2)->origin + make_float3 (_S1145) * _S1148;
                (&ray_2)->origin = _S1149;
            }
            throughput_10 = throughput_11;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1107;
            viewed_1 = _S1029;
            sky_pdf_2 = _S1119;
            spread_4 = _S1120;
            reconnection_0 = reconnection_1;
            is_inside_5 = is_inside_7;
        }
        else
        {
            (&prev_0)->rough = false;
            (&prev_0)->pdf = 0.0f;
            throughput_10 = throughput_7;
            density_6 = density_4;
            passes_0 = false;
            viewed_1 = viewed_0;
            sky_pdf_2 = 0.0f;
            spread_4 = spread_1;
            straight_0 = false;
            is_inside_5 = is_inside_6;
        }
        bool _S1150 = !replay_1;
        float density_7;
        if(_S1150)
        {
            if(_S874)
            {
                float3  _S1151 = throughput_10 * emission_1;
                Reservoir candidate_7 = chain_0;
                uint _S1152 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1153 = _S1152 == 1U;
                if(_S1153)
                {
                    float3  _S1154 = safeDivide(_S1151, chain_throughput_0);
                    (&candidate_7)->radiance = _S1154;
                }
                Reservoir _S1155 = withEnd(candidate_7, 2U, b_4, _S1151);
                offer(sel_1, _S1155, _S1151 * make_float3 (scale_1) / make_float3 (density_6));
            }
            if(_S874)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_3;
            }
            if(refracted_4)
            {
                float _S1156 = survivalProbability(throughput_10, density_6);
                density_7 = _S1156;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1157 = stream(_S744, b_4 + 128U);
            Random _S1158 = pcg(_S1157);
            bool _S1159 = density_7 < (_S1158.value);
            if(_S1159)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1160 = (fcptMaxBounces());
                wrong_side_0 = b_4 >= _S1160;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1161 = density_6 * density_7;
            density_7 = _S1161;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1162 = layer_0 ^ 1U;
        uint _S1163 = _slang_select(passes_0, _S1162,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_2)->distance = 0.0f;
            b_7 = b_4;
            viewed_0 = viewed_1;
            throughput_2 = throughput_10;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_1 = spread_4;
            uint _S1164 = b_7 + 1U;
            b_4 = _S1164;
            layer_0 = _S1163;
            continue;
        }
        FKRay _S1165 = ray_2;
        float _S1166 = distance_5(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S943;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S721 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1167 = _slang_select(wrong_side_0, _S1166,4.294967296e+09f);
        bool _S1168 = !_S912;
        if(straight_0)
        {
            _S982 = true;
        }
        else
        {
            _S982 = _S912;
        }
        FKHit _S1169;
        if(_S982)
        {
            _S1169 = hit_2;
        }
        else
        {
            _S1169 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
        }
        FKHit _S1170 = (fcptTraverseInstanceBVH((_S1165), (_S879), (_S1167), (_S1168), (_S1169), (viewed_1)));
        hit_2 = _S1170;
        if(replay_1)
        {
            _S983 = _S943;
        }
        else
        {
            _S983 = false;
        }
        if(_S983)
        {
            _S1026 = _S721 == 1U;
        }
        else
        {
            _S1026 = false;
        }
        if(_S1026)
        {
            _S1027 = ((&hit_2)->instance_index) == (_S733.instance_index);
        }
        else
        {
            _S1027 = false;
        }
        if(_S1027)
        {
            _S1028 = ((&hit_2)->triangle_index) == (_S733.triangle_index);
        }
        else
        {
            _S1028 = false;
        }
        if(_S1028)
        {
            (&hit_2)->uv = _S733.uv;
            float _S1171 = distance_5(reconnection_0, (&ray_2)->origin);
            (&hit_2)->distance = _S1171;
        }
        if(replay_1)
        {
            _S1029 = _S943;
        }
        else
        {
            _S1029 = false;
        }
        if(_S1029)
        {
            _S1030 = _S721 == 3U;
        }
        else
        {
            _S1030 = false;
        }
        if(_S1030)
        {
            _S1031 = ((&hit_2)->instance_index) != 4294967295U;
        }
        else
        {
            _S1031 = false;
        }
        if(_S1031)
        {
            return _S717;
        }
        Reservoir _S1172 = chain_0;
        uint _S1173 = filling_3;
        for(;;)
        {
            bool _S1174 = (fcptVaryingUsed());
            if(_S1174)
            {
                _S1032 = _S1173 != 4294967295U;
            }
            else
            {
                _S1032 = false;
            }
            float _S1175;
            if(_S1032)
            {
                float _S1176 = (fcptMajorant((_S1173)));
                _S1175 = _S1176;
            }
            else
            {
                _S1175 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1033 = _S943;
            }
            else
            {
                _S1033 = false;
            }
            if(_S1033)
            {
                _S1034 = _S721 == 1U;
            }
            else
            {
                _S1034 = false;
            }
            if(_S1034)
            {
                _S1035 = _S1175 > 0.0f;
            }
            else
            {
                _S1035 = false;
            }
            if(_S1035)
            {
                ended_0 = _S717;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_3 = width_2;
                density_3 = density_7;
                throughput_11 = throughput_10;
                b_7 = b_4;
                _S1036 = true;
                break;
            }
            bool _S1177 = (&prev_0)->rough;
            if(_S1177)
            {
                _S1036 = !(_S1175 > 0.0f);
            }
            else
            {
                _S1036 = false;
            }
            (&prev_0)->rough = _S1036;
            uint _S1178 = b_4 + 320U;
            bool _S1179 = b_4 == 4294967295U;
            uint _S1180 = _slang_select(_S1179, 384U,_S1178);
            uint _S1181 = stream(_S744, _S1180);
            uint tracking_1 = _S1181;
            weight_1 = throughput_3;
            glowed_0 = _S716;
            bool _S1182 = (fcptOutsideUsed());
            b_7 = b_4;
            throughput_11 = throughput_10;
            density_3 = density_7;
            spread_2 = spread_4;
            width_3 = width_2;
            sky_pdf_1 = sky_pdf_2;
            for(;;)
            {
                bool _S1183 = ((&hit_2)->instance_index) != 4294967295U;
                if(_S1183)
                {
                    _S1037 = true;
                }
                else
                {
                    if(_S1182)
                    {
                        _S1037 = _S1175 > 0.0f;
                    }
                    else
                    {
                        _S1037 = false;
                    }
                    if(_S1037)
                    {
                        _S1038 = !_S1032;
                    }
                    else
                    {
                        _S1038 = false;
                    }
                    _S1037 = _S1038;
                }
                if(_S1037)
                {
                }
                else
                {
                    _S715 = int(2);
                    break;
                }
                if(_S1182)
                {
                    _S1038 = ((&hit_2)->instance_index) == 4294967295U;
                }
                else
                {
                    _S1038 = false;
                }
                float _S1184 = (&hit_2)->distance;
                float _S1185 = _slang_select(_S1038, 4.294967296e+09f,_S1184);
                float _S1186 = escapeShare_0(_S1038, !_S1032, extinction_in_0);
                uint _S1187 = b_7 + 320U;
                bool _S1188 = b_7 == 4294967295U;
                uint _S1189 = _slang_select(_S1188, 384U,_S1187);
                uint _S1190 = stream(_S744, _S1189);
                Random _S1191 = pcg(_S1190);
                float _S1192 = 1.0f - _S1186;
                float _S1193 = freeFlight_0((_S1191.value - _S1186) / _S1192, _S1175);
                bool _S1194 = (_S1191.value) < _S1186;
                float _S1195 = _slang_select(_S1194, 4.294967296e+09f,_S1193);
                if(_S1032)
                {
                    float3  _S1196 = (&ray_2)->origin;
                    float3  _S1197 = (&ray_2)->unit_direction;
                    float _S1198 = (&hit_2)->distance;
                    uint _S1199 = _slang_select(_S1188, 0U,b_7);
                    uint _S1200 = (&prev_0)->lobe;
                    uint _S1201 = _slang_select(_S1188, 3U,_S1200);
                    float _S1202 = (fcptTrackMedium((_S1173), (_S1196), (_S1197), (_S1198), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1199), (_S1201), (_S1188)));
                    spread_3 = _S1202;
                }
                else
                {
                    spread_3 = _S1195;
                }
                bool _S1203 = !(spread_3 < _S1185);
                if(_S1203)
                {
                    _S715 = int(2);
                    break;
                }
                if(_S1032)
                {
                    _S1039 = _S1150;
                }
                else
                {
                    _S1039 = false;
                }
                if(_S1039)
                {
                    float3  _S1204 = throughput_11 * glowed_0 / make_float3 (density_3);
                    float3  _S1205 = sel_1->glow + _S1204;
                    sel_1->glow = _S1205;
                }
                else
                {
                }
                glowed_0 = _S716;
                uint b_8 = b_7 + 1U;
                float3  _S1206 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1206;
                float3  _S1207 = flightWeight_0(scatter_in_0, extinction_in_0, _S1175, spread_3, true);
                float3  _S1208 = _S1207 / make_float3 (_S1192);
                float3  _S1209 = weight_1;
                float3  _S1210 = _slang_select(_S1032, _S1209,_S1208);
                float3  throughput_12 = throughput_11 * _S1210;
                uint _S1211 = stream(_S744, b_8 + 320U);
                tracking_1 = _S1211;
                weight_1 = throughput_3;
                float width_6 = width_3 + spread_2 * spread_3;
                float _S1212 = spread_2 + 3.14159274101257324f;
                bool _S1213 = scatterSampled_0(replay_1, b_8, _S732, _S1032);
                TreeSample light_4;
                if(_S1213)
                {
                    float3  _S1214 = (&ray_2)->origin;
                    float3  _S1215 = (&ray_2)->unit_direction;
                    float3  _S1216 = (&ray_2)->unit_direction;
                    uint _S1217 = stream(_S744, b_8 + 64U);
                    float3  _S1218 = extinction_in_0;
                    float3  _S1219 = extinction_in_0;
                    uint2  _S1220 = make_uint2 (_S1173);
                    float3  _S1221 = (&ray_2)->unit_direction;
                    uint _S1222 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                    FKHit _S1223 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                    FKHit _S1224 = _S1223;
                    ShadowContext _S1225 = ShadowContext_x24init_0(_S1218, _S1219, _S1220, _S1221, b_8, _S1222, false, spread_3, width_6, &_S1224, false);
                    ShadowContext _S1226 = _S1225;
                    TreeSample _S1227 = sampleLightTree_0(_S1214, _S1215, _S1216, 0.0f, true, _S1217, &_S1226);
                    light_4 = _S1227;
                }
                else
                {
                    light_4 = _S957;
                }
                float _S1228 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1229 = (fcptMaxBounces());
                bool _S1230 = b_8 < _S1229;
                if(_S1230)
                {
                    _S1040 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1040 = false;
                }
                float _S1231 = _slang_select(_S1040, _S1228,0.0f);
                float3  _S1232 = throughput_12 * light_4.radiance;
                float _S1233 = powerHeuristic(light_4.density, _S1231);
                float3  _S1234 = _S1232 * make_float3 (_S1228 * _S1233);
                float3  _S1235 = _slang_select(_S1213, _S1234,_S716);
                if(replay_1)
                {
                    _S1041 = b_8 == _S732;
                }
                else
                {
                    _S1041 = false;
                }
                if(_S1041)
                {
                    bool _S1236 = _S721 == 2U;
                    if(_S1236)
                    {
                        float _S1237 = rgb_to_greyscale(_S1235);
                        _S1042 = _S1237 > 0.0f;
                    }
                    else
                    {
                        _S1042 = false;
                    }
                    if(_S1042)
                    {
                        Shift _S1238 = Shift_x24init_0(_S1235, 1.0f);
                        _S715 = int(1);
                        ended_0 = _S1238;
                        spread_3 = _S1212;
                        width_4 = width_6;
                        throughput_9 = throughput_12;
                        b_5 = b_8;
                        break;
                    }
                    _S715 = int(1);
                    ended_0 = _S717;
                    spread_3 = _S1212;
                    width_4 = width_6;
                    throughput_9 = throughput_12;
                    b_5 = b_8;
                    break;
                }
                if(_S1150)
                {
                    Reservoir candidate_8 = _S1172;
                    uint _S1239 = extractBits_0(_S1172.path, 10U, 2U);
                    bool _S1240 = _S1239 == 1U;
                    if(_S1240)
                    {
                        float3  _S1241 = safeDivide(_S1235, chain_throughput_0);
                        (&candidate_8)->radiance = _S1241;
                    }
                    else
                    {
                        uint _S1242 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                        uint _S1243 = insertBits_0(_S1242, 2U, 10U, 2U);
                        (&candidate_8)->path = _S1243;
                    }
                    Reservoir _S1244 = withEnd(candidate_8, 0U, b_8, _S1235);
                    offer(sel_1, _S1244, _S1235 * make_float3 (scale_1) / make_float3 (density_3));
                    float _S1245 = survivalProbability(throughput_12, density_3);
                    uint _S1246 = stream(_S744, b_8 + 128U);
                    Random _S1247 = pcg(_S1246);
                    bool _S1248 = _S1245 < (_S1247.value);
                    if(_S1248)
                    {
                        _S1042 = true;
                    }
                    else
                    {
                        uint _S1249 = (fcptMaxBounces());
                        _S1042 = b_8 >= _S1249;
                    }
                    if(_S1042)
                    {
                        _S715 = int(1);
                        ended_0 = _S717;
                        spread_3 = _S1212;
                        width_4 = width_6;
                        throughput_9 = throughput_12;
                        b_5 = b_8;
                        break;
                    }
                    float _S1250 = density_3 * _S1245;
                    density_3 = _S1250;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1251 = stream(_S744, b_8);
                float3  _S1252 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1251, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1252;
                NEEVertex _S1253 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S716, (&ray_2)->origin);
                nee_vertex_0 = _S1253;
                Vertex _S1254 = scatteredVertex_0(is_inside_5);
                prev_0 = _S1254;
                float _S1255 = (&prev_0)->pdf;
                FKRay _S1256 = ray_2;
                FKHit _S1257 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1258 = (fcptTraverseInstanceBVH((_S1256), (true), (4.294967296e+09f), (false), (_S1257), (false)));
                hit_2 = _S1258;
                b_7 = b_8;
                throughput_11 = throughput_12;
                spread_2 = _S1212;
                width_3 = width_6;
                sky_pdf_1 = _S1255;
            }
            if(_S715 != int(2))
            {
                spread_2 = spread_3;
                width_3 = width_4;
                throughput_11 = throughput_9;
                b_7 = b_5;
                _S1036 = true;
                break;
            }
            ended_0 = _S717;
            _S1036 = false;
            break;
        }
        if(_S1036)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1037 = b_7 == b_4;
        }
        else
        {
            _S1037 = false;
        }
        bool _S1259 = (fcptVaryingUsed());
        bool _S1260 = (fcptOutsideUsed());
        FKHit _S1261 = hit_2;
        float3  _S1262 = escaped_0(&_S1261, filling_3, scatter_in_0, extinction_in_0, _S1259, _S1260);
        float3  throughput_13 = throughput_11 * _S1262;
        bool _S1263 = ((&hit_2)->instance_index) == 4294967295U;
        if(_S1263)
        {
            bool _S1264 = !(&nee_vertex_0)->none;
            float _S1265 = _slang_select(_S1264, sky_pdf_1,0.0f);
            float _S1266 = escapeWeight_0(_S1265, (&ray_2)->unit_direction);
            float3  _S1267 = environment_0((&ray_2)->unit_direction, b_7, (&prev_0)->lobe);
            float3  _S1268 = throughput_13 * _S1267;
            if(replay_1)
            {
                bool _S1269 = b_7 == _S732;
                if(_S1269)
                {
                    passes_0 = _S721 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1268 * make_float3 (_S1266) / make_float3 (r_3->jac), density_3 / r_3->jac);
                }
                if(_S731)
                {
                    passes_0 = _S728;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_7 == _S719;
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
                    return Shift_x24init_0(_S1268 * make_float3 (_S1266), 1.0f);
                }
                return _S717;
            }
            Reservoir candidate_9 = chain_0;
            uint _S1270 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1271 = _S1270 == 1U;
            if(_S1271)
            {
                uint _S1272 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1273 = _S1272 == b_7;
                float _S1274 = _slang_select(_S1273, 1.0f,_S1266);
                float3  _S1275 = safeDivide(_S1268 * make_float3 (_S1274), chain_throughput_0);
                (&candidate_9)->radiance = _S1275;
            }
            else
            {
                bool _S1276 = (&prev_0)->rough;
                if(_S1276)
                {
                    uint _S1277 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                    uint _S1278 = insertBits_0(_S1277, 3U, 10U, 2U);
                    uint _S1279 = insertBits_0(_S1278, (&prev_0)->lobe, 15U, 2U);
                    bool _S1280 = (&prev_0)->inside;
                    uint _S1281 = _slang_select(_S1280, 1U,0U);
                    uint _S1282 = insertBits_0(_S1279, _S1281, 20U, 1U);
                    (&candidate_9)->path = _S1282;
                    (&candidate_9)->jac = (&prev_0)->pdf;
                    (&candidate_9)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1283 = _S1268 * make_float3 (_S1266);
            Reservoir _S1284 = withEnd(candidate_9, 3U, b_7, _S1283);
            offer(sel_1, _S1284, _S1283 * make_float3 (scale_1) / make_float3 (density_3));
            break;
        }
        float3  _S1285 = (&ray_2)->origin + make_float3 ((&hit_2)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1285;
        bool _S1286 = (fcptVaryingUsed());
        if(_S1286)
        {
            _S1038 = filling_3 != 4294967295U;
        }
        else
        {
            _S1038 = false;
        }
        if(_S1038)
        {
            if(_S1150)
            {
                float3  _S1287 = throughput_13 * glowed_0 / make_float3 (density_3);
                float3  _S1288 = sel_1->glow + _S1287;
                sel_1->glow = _S1288;
            }
            float3  _S1289 = throughput_13 * weight_1;
            throughput_9 = _S1289;
        }
        else
        {
            float3  _S1290 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_2)->distance, false);
            float3  _S1291 = throughput_13 * _S1290;
            throughput_9 = _S1291;
        }
        float _S1292 = width_3 + spread_2 * (&hit_2)->distance;
        viewed_0 = _S1037;
        width_2 = _S1292;
        throughput_2 = throughput_9;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1164 = b_7 + 1U;
        b_4 = _S1164;
        layer_0 = _S1163;
    }
    return _S717;
}

static __device__ Shift shift_0(Domain * dom_1, Reservoir * r_4)
{
    Selection _S1293 = (Selection{});
    Selection sel_2 = _S1293;
    bool _S1294 = (r_4->w) <= 0.0f;
    if(_S1294)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1295 = walk_0(dom_1, r_4, true, 0.0f, &sel_2);
    return _S1295;
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
    Random _S1296 = pcg(state_3);
    Random _S1297 = pcg(_S1296.state);
    float _S1298 = 6.28318548202514648f * _S1296.value;
    float _S1299 = (F32_sqrt((-2.0f * clamp_0((F32_log((_S1297.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1297.state, _S1299 * (F32_cos((_S1298))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1300;
    (&_S1300)->state = state_4;
    (&_S1300)->value = value_2;
    return _S1300;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1301 = normal_distribution(state_5);
    Random _S1302 = normal_distribution(_S1301.state);
    Random _S1303 = normal_distribution(_S1302.state);
    float3  _S1304 = make_float3 (_S1301.value, _S1302.value, _S1303.value);
    float3  _S1305 = ((((_S1304)) * make_float3(rnorm3df(((_S1304)).x, ((_S1304)).y, ((_S1304)).z))));
    return RandomSphere_x24init_0(_S1303.state, _S1305);
}

struct RandomHemisphere
{
    uint state;
    float3  value;
};

static __device__ RandomHemisphere RandomHemisphere_x24init_0(uint state_6, float3  value_3)
{
    RandomHemisphere _S1306;
    (&_S1306)->state = state_6;
    (&_S1306)->value = value_3;
    return _S1306;
}

__device__ RandomHemisphere random_hemisphere(uint state_7, float3  normal_4)
{
    RandomSphere _S1307 = random_sphere(state_7);
    bool _S1308 = (dot_0(_S1307.value, normal_4)) > 0.0f;
    if(_S1308)
    {
        return RandomHemisphere_x24init_0(_S1307.state, _S1307.value);
    }
    else
    {
        float3  _S1309 = negate_0(_S1307.value);
        return RandomHemisphere_x24init_0(_S1307.state, _S1309);
    }
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_15)
{
    float3  _S1310 = p1_0 - p0_0;
    float3  _S1311 = p2_0 - p0_0;
    float2  _S1312 = uv1_0 - uv0_0;
    float2  _S1313 = uv2_0 - uv0_0;
    float _S1314 = _S1312.x;
    float _S1315 = _S1313.y;
    float _S1316 = _S1312.y;
    float _S1317 = _S1313.x;
    float _S1318 = _S1314 * _S1315 - _S1316 * _S1317;
    float _S1319 = 1.0f / _S1318;
    float3  t_1 = (_S1310 * make_float3 (_S1315) - _S1311 * make_float3 (_S1316)) * make_float3 (_S1319);
    float3  _S1320 = (_S1311 * make_float3 (_S1314) - _S1310 * make_float3 (_S1317)) * make_float3 (_S1319);
    float3  _S1321 = t_1 - n_15 * make_float3 (dot_0(n_15, t_1));
    float3  t_2 = ((((_S1321)) * make_float3(rnorm3df(((_S1321)).x, ((_S1321)).y, ((_S1321)).z))));
    bool _S1322 = (dot_0(cross_0(n_15, t_2), _S1320)) > 0.0f;
    float3  t_3;
    if(_S1322)
    {
        float3  _S1323 = negate_0(t_2);
        t_3 = _S1323;
    }
    else
    {
        t_3 = t_2;
    }
    float3  _S1324 = cross_0(n_15, t_3);
    return makeMatrix<float, 3, 3> (t_3, _S1324, n_15);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1325 = t1_0 - t0_0;
    float3  _S1326 = t2_2 - t0_0;
    float3  _S1327 = t2_2 - t1_0;
    float _S1328 = (F32_min((length_0(_S1325)), ((F32_min((length_0(_S1326)), (length_0(_S1327)))))));
    float3  _S1329 = make_float3 (distance_5(position_0, t0_0), distance_5(position_0, t1_0), distance_5(position_0, t2_2));
    float3  _S1330 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1331 = dot_0(geometry_n_5, _S1330);
    float3  _S1332 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1333 = dot_0(geometry_n_5, _S1332);
    float3  _S1334 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1335 = acos_0(abs_0(make_float3 (_S1331, _S1333, dot_0(geometry_n_5, _S1334))));
    float3  _S1336 = clamp_1(tan_0(_S1335), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_0(dot_0(_S1329 * _S1336, uvw_0), 0.0f, _S1328 * 0.125f);
}

__device__ float3  sampleHalfVector(float3  v_6, float3  n_i_5, float alpha_6, uint * random_state_16)
{
    float3  _S1337 = sampleMaterialHalfVector(v_6, n_i_5, alpha_6, AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f)), random_state_16);
    return _S1337;
}

__device__ float3  straightThrough(float3  dir_15, float3  n_16, BSDFMaterial material_16)
{
    float3  _S1338 = negate_0(dir_15);
    float _S1339 = sign_0(dot_0(n_16, _S1338));
    float3  _S1340 = n_16 * make_float3 (_S1339);
    AnisotropicFrame _S1341 = anisotropicFrame(material_16, _S1340);
    bool _S1342 = (_S1341.alphas.x) > 0.0f;
    if(_S1342)
    {
        float _S1343 = material_16.transmission * (1.0f - material_16.metallic);
        float3  _S1344 = negate_0(_S1340);
        float3  _S1345 = anisotropicLocal(dir_15, _S1341.tangent, _S1344);
        float _S1346 = anisotropicG1(_S1345, _S1341.alphas);
        return make_float3 (_S1343 * _S1346) * material_16.albedo;
    }
    float _S1347 = material_16.transmission * (1.0f - material_16.metallic);
    float _S1348 = material_16.roughness;
    float _S1349 = smithG1(_S1348 * _S1348, (F32_abs((dot_0(n_16, dir_15)))));
    return make_float3 (_S1347 * _S1349) * material_16.albedo;
}

__device__ float hairRow(float3  in_dir_10, float3  t_4, float3  out_dir_4, uint p_5, float w_2, float alpha_7, uint nt_0)
{
    uint _S1350 = p_5 % 4U;
    float _S1351 = w_2 * HAIR_WIDTHS_0[_S1350];
    float _S1352 = (F32_asin((clamp_0(dot_0(out_dir_4, t_4), -1.0f, 1.0f)))) - (F32_asin((clamp_0(dot_0(in_dir_10, t_4), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1350] * alpha_7;
    return ((F32_asinh((_S1352 / _S1351))) / (F32_asinh((3.14159274101257324f / _S1351))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_11, float3  t_5, float3  out_dir_5, uint np_0)
{
    float3  _S1353 = worldToTangent(out_dir_5, t_5);
    float3  _S1354 = worldToTangent(in_dir_11, t_5);
    return (F32_frac((((F32_atan2((_S1353.z), (_S1353.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1354.z), (1.17549435082228751e-38f - _S1354.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_12, float3  t_6, uint p_6, float row_0, float column_0, float w_3, float alpha_8, uint nt_1, uint np_1)
{
    float3  _S1355 = worldToTangent(in_dir_12, t_6);
    uint _S1356 = p_6 % 4U;
    float _S1357 = w_3 * HAIR_WIDTHS_0[_S1356];
    float _S1358 = (F32_asin((clamp_0(dot_0(in_dir_12, t_6), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1356] * alpha_8 + _S1357 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1357))))));
    float _S1359 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1355.z), (1.17549435082228751e-38f - _S1355.x)));
    float _S1360 = (F32_cos((_S1358)));
    float3  _S1361 = tangentToWorld(make_float3 (_S1360 * (F32_cos((_S1359))), (F32_sin((_S1358))), _S1360 * (F32_sin((_S1359)))), t_6);
    return _S1361;
}

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_3, float3  end_1)
{
    float _S1362 = sign_0(dot_0(light_n_0, start_3 - end_1));
    return light_n_0 * make_float3 (_S1362 * light_offset_0);
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_17, BSDFMaterial material_17, float coverage_1)
{
    float3  _S1363;
    if((material_17.ior) == 1.0f)
    {
        float3  _S1364 = straightThrough(toward_1, n_17, material_17);
        _S1363 = _S1364;
    }
    else
    {
        _S1363 = make_float3 (0.0f);
    }
    return _S1363 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_5, Shift shifted_0, float mis_0)
{
    Reservoir candidate_10 = r_5;
    float3  _S1365 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_10)->f = _S1365;
    float _S1366 = r_5.jac * shifted_0.jac;
    (&candidate_10)->jac = _S1366;
    offer(sel_3, candidate_10, make_float3 (mis_0) * shifted_0.f * make_float3 (r_5.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_6 = sel_4.r;
    float _S1367 = rgb_to_greyscale((&r_6)->f);
    float _S1368 = sel_4.w_sum / _S1367;
    bool _S1369 = _S1367 > 0.0f;
    float _S1370 = _slang_select(_S1369, _S1368,0.0f);
    (&r_6)->w = _S1370;
    (&r_6)->c = c_1;
    return r_6;
}

static __device__ float interpolate_0(float a_6, float b_9, float t_7)
{
    return a_6 + (b_9 - a_6) * t_7;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S1371 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S1371;
}

__device__ float2  temporalWeights(float c_2, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S1372 = c_2 * p_c_0;
    float _S1373 = c_t_0 * p_t_0;
    return make_float2 (_S1372 / (_S1372 + c_t_0 * g_previous_0), _S1373 / (_S1373 + c_2 * g_current_0));
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
    Domain _S1374 = dom_2;
    Reservoir _S1375 = r_7;
    Shift _S1376 = walk_0(&_S1374, &_S1375, replay_2, scale_2, sel_5);
    return _S1376;
}

__device__ Shift shift_hook(Domain dom_3, Reservoir r_8)
{
    Domain _S1377 = dom_3;
    Reservoir _S1378 = r_8;
    Shift _S1379 = shift_0(&_S1377, &_S1378);
    return _S1379;
}

#undef Matrix
