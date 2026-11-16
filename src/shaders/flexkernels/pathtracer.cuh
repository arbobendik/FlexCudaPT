#pragma once
#define Matrix SlangMatrix
#include "slang-cuda-prelude.h"

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

static __device__ FKHit Hit_x24init_0(float2  uv_0, uint instance_index_0, uint triangle_index_0, uint is_point_light_0, float distance_0)
{
    FKHit _S2;
    (&_S2)->uv = uv_0;
    (&_S2)->instance_index = instance_index_0;
    (&_S2)->triangle_index = triangle_index_0;
    (&_S2)->is_point_light = is_point_light_0;
    (&_S2)->distance = distance_0;
    return _S2;
}

static __device__ float3  skyRadiance_0(float3  origin_1, FKSurface * surface_0, bool is_inside_1, float3  dir_1, ShadowContext * context_0, uint random_state_0)
{
    bool _S3 = wrongSide_0(is_inside_1, false, dir_1, surface_0->geometry_n);
    bool _S4 = is_inside_1 != _S3;
    float _S5 = surface_0->geometry_offset;
    float3  _S6 = surface_0->smooth_n;
    float3  _S7 = - surface_0->smooth_n;
    float3  _S8 = _slang_select(_S4, _S7,_S6);
    FKRay _S9 = Ray_x24init_0(origin_1 + make_float3 (_S5) * _S8, dir_1);
    bool _S10 = (dot_0(context_0->side, dir_1)) > 0.0f;
    float3  _S11 = (fcptEnvMapSample((dir_1), (0U), (3U)));
    float3  _S12 = context_0->extinction_behind;
    float3  _S13 = context_0->extinction_front;
    float3  _S14 = _slang_select(_S10, _S13,_S12);
    uint _S15 = context_0->fillings.x;
    uint _S16 = context_0->fillings.y;
    uint _S17 = _slang_select(_S10, _S16,_S15);
    uint _S18 = context_0->depth;
    uint _S19 = context_0->lobe;
    bool _S20 = context_0->surface;
    bool _S21;
    if(_S20)
    {
        _S21 = !context_0->fiber;
    }
    else
    {
        _S21 = false;
    }
    float _S22 = context_0->length;
    float _S23 = context_0->width;
    FKHit _S24 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    float3  _S25 = (fcptShadowTransmittanceIn((_S9), (4.294967296e+09f), (_S14), (_S17), (random_state_0), (_S18), (_S19), (_S21), (_S22), (_S23), (_S24), (_S24)));
    return _S11 * _S25;
}

static __device__ uint searchCDF_0(uint2  start_0, uint2  step_0, uint count_0, float u_0)
{
    uint _S26 = count_0 - 1U;
    uint low_0 = 0U;
    uint high_0 = _S26;
    for(;;)
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        uint _S27 = (low_0 + high_0) / 2U;
        float4  _S28 = (fcptEnvironmentCdf((start_0 + step_0 * make_uint2 (_S27))));
        bool _S29 = (_S28.x) > u_0;
        if(_S29)
        {
            high_0 = _S27;
        }
        else
        {
            uint _S30 = _S27 + 1U;
            low_0 = _S30;
        }
    }
    return low_0;
}

static __device__ float length_0(float3  x_1)
{
    return (F32_sqrt((dot_0(x_1, x_1))));
}

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

static __device__ float3  lightTransmittance_0(float3  origin_2, float3  smooth_n_0, float geometry_offset_0, float3  light_dir_0, ShadowContext * context_1, uint random_state_1, FKHit * light_0)
{
    float3  _S31 = ((((light_dir_0)) * make_float3(rnorm3df(((light_dir_0)).x, ((light_dir_0)).y, ((light_dir_0)).z))));
    bool _S32 = (dot_0(smooth_n_0, _S31)) < 0.0f;
    if(_S32)
    {
        return make_float3 (0.0f);
    }
    float3  _S33 = make_float3 (geometry_offset_0) * smooth_n_0;
    float3  _S34 = origin_2 + _S33;
    FKRay _S35 = Ray_x24init_0(_S34, _S31);
    bool _S36 = (dot_0(context_1->side, light_dir_0 + _S33)) > 0.0f;
    float _S37 = shadowLength(light_dir_0);
    float3  _S38 = context_1->extinction_behind;
    float3  _S39 = context_1->extinction_front;
    float3  _S40 = _slang_select(_S36, _S39,_S38);
    uint _S41 = context_1->fillings.x;
    uint _S42 = context_1->fillings.y;
    uint _S43 = _slang_select(_S36, _S42,_S41);
    uint _S44 = context_1->depth;
    uint _S45 = context_1->lobe;
    bool _S46 = context_1->surface;
    bool _S47;
    if(_S46)
    {
        _S47 = !context_1->fiber;
    }
    else
    {
        _S47 = false;
    }
    float _S48 = context_1->length;
    float _S49 = context_1->width;
    FKHit _S50;
    if(context_1->fiber)
    {
        _S50 = context_1->own;
    }
    else
    {
        _S50 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    }
    float3  _S51 = (fcptShadowTransmittanceIn((_S35), (_S37), (_S40), (_S43), (random_state_1), (_S44), (_S45), (_S47), (_S48), (_S49), (_S50), (*light_0)));
    return _S51;
}

__device__ float sine(float c_0)
{
    return (F32_sqrt(((F32_max((1.0f - c_0 * c_0), (0.0f))))));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S52 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S53 = cos_a_0 > cos_b_0;
    float _S54 = _slang_select(_S53, 1.0f,_S52);
    return _S54;
}

__device__ float sinSubClamped(float sin_a_1, float cos_a_1, float sin_b_1, float cos_b_1)
{
    float _S55 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    bool _S56 = cos_a_1 > cos_b_1;
    float _S57 = _slang_select(_S56, 0.0f,_S55);
    return _S57;
}

__device__ float importance(LightNode node_0, float3  p_0, float3  normal_0)
{
    float3  _S58 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S59 = node_0.high - node_0.low;
    float3  _S60 = p_0 - _S58;
    float3  _S61 = ((((_S60)) * make_float3(rnorm3df(((_S60)).x, ((_S60)).y, ((_S60)).z))));
    float _S62 = dot_0(_S60, _S60);
    float _S63 = dot_0(_S59, _S59) / 4.0f;
    float _S64 = (F32_abs((dot_0(node_0.w, _S61))));
    float _S65 = sine(node_0.cos_theta_o);
    float _S66 = (F32_sqrt(((F32_max((1.0f - _S63 / _S62), (0.0f))))));
    bool _S67 = _S62 < _S63;
    float _S68 = _slang_select(_S67, -1.0f,_S66);
    float _S69 = sine(_S68);
    float _S70 = sine(_S64);
    float _S71 = cosSubClamped(_S70, _S64, _S65, node_0.cos_theta_o);
    float _S72 = sine(_S64);
    float _S73 = sinSubClamped(_S72, _S64, _S65, node_0.cos_theta_o);
    float _S74 = cosSubClamped(_S73, _S71, _S69, _S68);
    bool _S75 = _S74 <= 0.0f;
    if(_S75)
    {
        return 0.0f;
    }
    float _S76 = - dot_0(_S61, normal_0);
    float _S77 = node_0.phi * _S74 / (F32_max((_S62), (length_0(_S59) / 2.0f)));
    float _S78 = sine(_S76);
    float _S79 = cosSubClamped(_S78, _S76, _S69, _S68);
    bool _S80 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S81 = _slang_select(_S80, 1.0f,_S79);
    return (F32_max((_S77 * _S81), (0.0f)));
}

__device__ __forceinline__ float childShare(LightNode first_0, LightNode second_0, float3  p_1, float3  normal_1, uint child_0)
{
    float _S82 = importance(first_0, p_1, normal_1);
    float _S83 = importance(second_0, p_1, normal_1);
    float2  _S84 = make_float2 (_S82, _S83);
    float _S85 = _slang_vector_get_element(_S84, child_0) / (_S82 + _S83);
    bool _S86 = _slang_vector_get_element(_S84, child_0) > 0.0f;
    float _S87 = _slang_select(_S86, _S85,0.0f);
    return _S87;
}

__device__ float sphereDensity(float3  center_0, float radius_0, float3  p_2)
{
    float3  _S88 = center_0 - p_2;
    float _S89 = radius_0 * radius_0 / dot_0(_S88, _S88);
    bool _S90 = _S89 >= 1.0f;
    if(_S90)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S89)))) / (6.28318548202514648f * _S89);
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S91 = left_0.y;
    float _S92 = right_0.z;
    float _S93 = left_0.z;
    float _S94 = right_0.y;
    float _S95 = right_0.x;
    float _S96 = left_0.x;
    return make_float3 (_S91 * _S92 - _S93 * _S94, _S93 * _S95 - _S96 * _S92, _S96 * _S94 - _S91 * _S95);
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_0))));
}

static __device__ float lightPdf_0(float3  origin_3, float3  smooth_n_1, float3  start_1, uint j_0, float3  light_point_0)
{
    bool _S97 = j_0 == 4294967295U;
    if(_S97)
    {
        return 0.0f;
    }
    uint4  _S98 = (fcptLightTrail((j_0)));
    uint2  _S99 = uint2 {_S98.x, _S98.y};
    uint n_0 = 0U;
    uint2  trail_0 = _S99;
    float probability_1 = 1.0f;
    for(;;)
    {
        uint4  _S100 = (fcptLightNode((n_0)));
        if((_S100.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S101 = (fcptLightSecond((n_0)));
        uint _S102 = n_0 + 1U;
        LightNode _S103 = (fcptLightBounds((_S102)));
        LightNode _S104 = (fcptLightBounds((_S101)));
        uint _S105 = trail_0.x;
        uint _S106 = _S105 & 1U;
        float _S107 = childShare(_S103, _S104, origin_3, smooth_n_1, _S106);
        float probability_2 = probability_1 * _S107;
        bool _S108 = _S106 == 1U;
        uint _S109 = _slang_select(_S108, _S101,_S102);
        uint _S110 = trail_0.y;
        uint2  _S111 = make_uint2 ((_S105 >> 1U) | (_S110 << 31U), _S110 >> 1U);
        n_0 = _S109;
        trail_0 = _S111;
        probability_1 = probability_2;
    }
    bool _S112 = (fcptSlotLeaf((n_0), (j_0)));
    bool _S113 = !_S112;
    bool _S114;
    if(_S113)
    {
        _S114 = true;
    }
    else
    {
        LightNode _S115 = (fcptLightBounds((n_0)));
        float _S116 = importance(_S115, origin_3, smooth_n_1);
        _S114 = !(_S116 > 0.0f);
    }
    if(_S114)
    {
        _S114 = true;
    }
    else
    {
        bool _S117 = (dot_0(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S117)
        {
            _S114 = !((dot_0(smooth_n_1, light_point_0 - origin_3)) > 0.0f);
        }
        else
        {
            _S114 = false;
        }
    }
    if(_S114)
    {
        return 0.0f;
    }
    uint4  _S118 = (fcptLightNode((n_0)));
    bool _S119 = (_S118.x) == 2U;
    if(_S119)
    {
        uint _S120 = _S118.y;
        FKLight _S121 = (fcptLight((_S120)));
        FKLight _S122 = (fcptLight((_S120)));
        float _S123 = sphereDensity(_S121.position, _S122.variance, start_1);
        return probability_1 * _S123;
    }
    uint _S124 = _S118.y;
    uint _S125 = (fcptTriangleOffset((_S124)));
    Matrix<float, 3, 3>  _S126 = (fcptWorldTriangle((_S124), (_S125 + _S118.z)));
    float _S127 = solidAngle(probability_1, cross_0(_S126.rows[int(1)] - _S126.rows[int(0)], _S126.rows[int(2)] - _S126.rows[int(0)]), light_point_0 - start_1);
    return _S127;
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
    uint _S128 = x_2 * 747796405U + 2891336453U;
    uint _S129 = ((_S128 >> ((_S128 >> 28U) + 4U)) ^ _S128) * 277803737U;
    return (_S129 >> 22U) ^ _S129;
}

static __device__ float random_0(uint * state_0)
{
    uint _S130 = hash(*state_0);
    *state_0 = _S130;
    return float((*state_0) >> int(8)) * 5.9604644775390625e-08f;
}

static __device__ Random Random_x24init_0(uint state_1, float value_0)
{
    Random _S131;
    (&_S131)->state = state_1;
    (&_S131)->value = value_0;
    return _S131;
}

__device__ Random pcg(uint state_2)
{
    uint _S132 = state_2;
    float value_1 = random_0(&_S132);
    return Random_x24init_0(_S132, value_1);
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
    uint2  _S133 = (fcptEnvironmentCdfSize());
    uint2  _S134 = _S133 - make_uint2 (1U, 0U);
    float2  _S135 = make_float2 ((F32_atan2((- dir_2.y), (dir_2.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_0(dir_2.z, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S136 = make_float2 ((float)_S134.x, (float)_S134.y);
    float2  _S137 = _S135 * _S136;
    uint2  _S138 = make_uint2 ((uint)_S137.x, (uint)_S137.y);
    uint2  _S139 = min_0(_S138, _S134 - make_uint2 (1U));
    float4  _S140 = (fcptEnvironmentCdf((_S139)));
    float _S141 = _S140.y;
    uint _S142 = _S134.x;
    float4  _S143 = (fcptEnvironmentCdf((make_uint2 (_S142, _S139.y))));
    float _S144 = _S141 * _S143.y;
    return _S144 * float(_S142 * _S134.y) / (19.73921012878417969f * length_1(float2 {dir_2.x, dir_2.y}));
}

static __device__ float3  negate_0(float3  x_7)
{
    return - x_7;
}

static __device__ float sign_0(float e_0)
{
    float _S145;
    if(e_0 > 0.0f)
    {
        _S145 = 1.0f;
    }
    else
    {
        if(e_0 < 0.0f)
        {
            _S145 = -1.0f;
        }
        else
        {
            _S145 = 0.0f;
        }
    }
    return _S145;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S146;
    (&_S146)->tangent = tangent_0;
    (&_S146)->alphas = alphas_0;
    return _S146;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_0 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S147 = (F32_abs((dot_0(n_1, a_0)))) > 0.9999847412109375f;
    float3  a_1;
    if(_S147)
    {
        float3  _S148 = make_float3 (1.0f, 0.0f, 0.0f);
        a_1 = _S148;
    }
    else
    {
        a_1 = a_0;
    }
    float3  _S149 = cross_0(n_1, a_1);
    float3  _S150 = ((((_S149)) * make_float3(rnorm3df(((_S149)).x, ((_S149)).y, ((_S149)).z))));
    float3  _S151 = cross_0(n_1, _S150);
    return make_float3 (v_0.x) * _S150 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S151;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_0, float3  n_i_0)
{
    float _S152 = material_0.roughness;
    float _S153 = _S152 * _S152;
    bool _S154 = (material_0.anisotropy) == 0.0f;
    bool _S155;
    if(_S154)
    {
        _S155 = true;
    }
    else
    {
        _S155 = !(_S153 > 0.0f);
    }
    if(_S155)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S156 = material_0.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_0.tangent));
    float3  _S157 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S158 = (dot_0(_S156, _S156)) > 0.0f;
    float3  _S159 = _slang_select(_S158, _S156,_S157);
    float3  _S160 = ((((_S159)) * make_float3(rnorm3df(((_S159)).x, ((_S159)).y, ((_S159)).z))));
    float _S161 = 6.28318548202514648f * material_0.anisotropic_rotation;
    float _S162 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_0.anisotropy))))));
    float _S163 = 1.0f / _S162;
    bool _S164 = (material_0.anisotropy) < 0.0f;
    float _S165 = _slang_select(_S164, _S163,_S162);
    return AnisotropicFrame_x24init_0(_S160 * make_float3 ((F32_cos((_S161)))) + cross_0(n_i_0, _S160) * make_float3 ((F32_sin((_S161)))), make_float2 (_S153 / _S165, _S153 * _S165));
}

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
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
    float p_sheen_velvet;
    float3  view;
    float3  tangent;
    float2  alphas;
    float visible;
    float p_toon;
    float3  toon;
    float toon_a;
    float toon_s;
    float toon_b;
    bool toon_glossy;
    float toon_norm;
    float toon_view;
    float3  toon_axis;
};

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_0, float3  refracted_1, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_0, float3  sheen_0, float p_sheen_velvet_0, float3  view_0, float3  tangent_1, float2  alphas_1, float visible_0, float p_toon_0, float3  toon_0, float toon_a_0, float toon_s_0, float toon_b_0, bool toon_glossy_0, float toon_norm_0, float toon_view_0, float3  toon_axis_0)
{
    BSDFLobes _S166;
    (&_S166)->v_dot_h = v_dot_h_0;
    (&_S166)->n_dot_h = n_dot_h_0;
    (&_S166)->refracted = refracted_1;
    (&_S166)->F = F_0;
    (&_S166)->F_greyscale = F_greyscale_0;
    (&_S166)->reflect_weight = reflect_weight_0;
    (&_S166)->diffuse_weight = diffuse_weight_0;
    (&_S166)->refract_weight = refract_weight_0;
    (&_S166)->p_diffuse = p_diffuse_0;
    (&_S166)->p_reflect = p_reflect_0;
    (&_S166)->p_refract = p_refract_0;
    (&_S166)->translucent_share = translucent_share_0;
    (&_S166)->sheen = sheen_0;
    (&_S166)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S166)->view = view_0;
    (&_S166)->tangent = tangent_1;
    (&_S166)->alphas = alphas_1;
    (&_S166)->visible = visible_0;
    (&_S166)->p_toon = p_toon_0;
    (&_S166)->toon = toon_0;
    (&_S166)->toon_a = toon_a_0;
    (&_S166)->toon_s = toon_s_0;
    (&_S166)->toon_b = toon_b_0;
    (&_S166)->toon_glossy = toon_glossy_0;
    (&_S166)->toon_norm = toon_norm_0;
    (&_S166)->toon_view = toon_view_0;
    (&_S166)->toon_axis = toon_axis_0;
    return _S166;
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
    float3  _S167 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S168 = ((((_S167)) * make_float3(rnorm3df(((_S167)).x, ((_S167)).y, ((_S167)).z))));
    float _S169 = _S168.x;
    float _S170 = _S168.y;
    float _S171 = _S169 * _S169 + _S170 * _S170;
    float3  _S172;
    if(_S171 > 0.0f)
    {
        float3  _S173 = make_float3 (- _S170, _S169, 0.0f);
        float _S174 = (rsqrtf((_S171)));
        _S172 = _S173 * make_float3 (_S174);
    }
    else
    {
        _S172 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S175 = cross_0(_S168, _S172);
    float _S176 = (F32_sqrt((U1_0)));
    float _S177 = 6.28318548202514648f * U2_0;
    float _S178 = _S176 * (F32_cos((_S177)));
    float t2_0 = _S176 * (F32_sin((_S177)));
    float _S179 = 0.5f * (1.0f + _S168.z);
    float t2_1 = (1.0f - _S179) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S178 * _S178)))))) + _S179 * t2_0;
    float3  _S180 = make_float3 (_S178) * _S172 + make_float3 (t2_1) * _S175;
    float _S181 = unshared_0(_S178);
    float _S182 = unshared_0(_S178);
    float3  _S183 = _S180 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S181 * _S182 - t2_1 * t2_1))))))) * _S168;
    float3  _S184 = make_float3 (alpha_0 * _S183.x, alpha_0 * _S183.y, (F32_max((0.0f), (_S183.z))));
    float3  _S185 = ((((_S184)) * make_float3(rnorm3df(((_S184)).x, ((_S184)).y, ((_S184)).z))));
    return _S185;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
{
    float3  a_2 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S186 = (F32_abs((dot_0(n_3, a_2)))) > 0.9999847412109375f;
    float3  a_3;
    if(_S186)
    {
        float3  _S187 = make_float3 (1.0f, 0.0f, 0.0f);
        a_3 = _S187;
    }
    else
    {
        a_3 = a_2;
    }
    float3  _S188 = cross_0(n_3, a_3);
    float3  _S189 = ((((_S188)) * make_float3(rnorm3df(((_S188)).x, ((_S188)).y, ((_S188)).z))));
    float3  _S190 = cross_0(n_3, _S189);
    return make_float3 (dot_0(v_1, _S189), dot_0(v_1, n_3), dot_0(v_1, _S190));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_2, float3  n_i_1, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S191 = pcg(*random_state_2);
    Random _S192 = pcg(_S191.state);
    *random_state_2 = _S192.state;
    float _S193 = frame_0.alphas.x;
    bool _S194 = _S193 > 0.0f;
    if(_S194)
    {
        float3  _S195 = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        float _S196 = frame_0.alphas.y;
        float3  _S197 = make_float3 (_S193 * _S195.x, _S196 * _S195.y, _S195.z);
        float3  _S198 = ((((_S197)) * make_float3(rnorm3df(((_S197)).x, ((_S197)).y, ((_S197)).z))));
        float3  _S199 = sampleGGXVNDF(_S198, 1.0f, _S191.value, _S192.value);
        float3  _S200 = make_float3 (_S193 * _S199.x, _S196 * _S199.y, _S199.z);
        float3  _S201 = ((((_S200)) * make_float3(rnorm3df(((_S200)).x, ((_S200)).y, ((_S200)).z))));
        return make_float3 (_S201.x) * frame_0.tangent + make_float3 (_S201.y) * cross_0(n_i_1, frame_0.tangent) + make_float3 (_S201.z) * n_i_1;
    }
    float3  _S202 = worldToTangent(v_2, n_i_1);
    float3  _S203 = sampleGGXVNDF(float3 {_S202.x, _S202.z, _S202.y}, alpha_1, _S191.value, _S192.value);
    float3  _S204 = float3 {_S203.x, _S203.z, _S203.y};
    float3  _S205 = tangentToWorld(_S204, n_i_1);
    return _S205;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_4, BSDFMaterial material_1, uint random_state_3, AnisotropicFrame frame_1)
{
    uint state_3 = random_state_3;
    float3  _S206 = negate_0(in_dir_0);
    float _S207 = sign_0(dot_0(n_4, _S206));
    float _S208 = material_1.roughness;
    float3  _S209 = sampleHalfVector(_S206, n_4 * make_float3 (_S207), _S208 * _S208, frame_1, &state_3);
    return _S209;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_5, float eta_i_0, float eta_o_0)
{
    float3  _S210 = negate_0(in_dir_1);
    float3  _S211 = negate_0(make_float3 (eta_i_0) * _S210 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S212 = ((((_S211)) * make_float3(rnorm3df(((_S211)).x, ((_S211)).y, ((_S211)).z))));
    float _S213 = sign_0(dot_0(n_5, _S210));
    float _S214 = sign_0(dot_0(_S211, n_5 * make_float3 (_S213)));
    return _S212 * make_float3 (_S214);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S215 = negate_0(in_dir_2);
    float3  _S216 = _S215 + out_dir_1;
    float3  _S217 = ((((_S216)) * make_float3(rnorm3df(((_S216)).x, ((_S216)).y, ((_S216)).z))));
    return _S217;
}

static __device__ float3  refract_0(float3  i_1, float3  n_6, float eta_0)
{
    float _S218 = dot_0(n_6, i_1);
    float _S219 = 1.0f - eta_0 * eta_0 * (1.0f - _S218 * _S218);
    if(_S219 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_1 - make_float3 (eta_0 * _S218 + (F32_sqrt((_S219)))) * n_6;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S220 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S221 = eta_i_1 / eta_o_1 * _S220;
    bool _S222 = _S221 < 1.0f;
    float kr_0;
    if(_S222)
    {
        float _S223 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S221 * _S221))))));
        float _S224 = eta_o_1 * cos_theta_0;
        float _S225 = eta_i_1 * _S223;
        float _S226 = (_S224 - _S225) / (_S224 + _S225);
        float _S227 = eta_i_1 * cos_theta_0;
        float _S228 = eta_o_1 * _S223;
        float _S229 = (_S227 - _S228) / (_S227 + _S228);
        float _S230 = (_S226 * _S226 + _S229 * _S229) / 2.0f;
        kr_0 = _S230;
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
__device__ static const FixedArray<float, 576>  VELVET_ALBEDO_0 = { {
    1.00383996963500977f, 1.00428998470306396f, 1.00356996059417725f, 1.00303995609283447f, 1.00261998176574707f, 1.00229001045227051f, 1.00198996067047119f, 1.00171005725860596f, 1.00144004821777344f, 1.00120997428894043f, 1.00102996826171875f, 1.00092005729675293f, 1.00088000297546387f, 1.0009000301361084f, 1.00095999240875244f, 1.00106000900268555f, 1.00115001201629639f, 1.00124001502990723f, 1.001289963722229f, 1.0013200044631958f, 1.00133001804351807f, 1.00133001804351807f, 1.0013200044631958f, 1.00129997730255127f, 0.99086397886276245f, 0.9934689998626709f, 0.99439799785614014f, 0.99513500928878784f, 0.99574202299118042f, 0.9962649941444397f, 0.99671798944473267f, 0.99709898233413696f, 0.997406005859375f, 0.99764800071716309f, 0.99783498048782349f, 0.99798601865768433f, 0.99811899662017822f, 0.99825501441955566f, 0.99840497970581055f, 0.99857097864151001f, 0.99874699115753174f, 0.99892902374267578f, 0.9990919828414917f, 0.99923902750015259f, 0.99936902523040771f, 0.99948000907897949f, 0.99957501888275146f, 0.99965798854827881f, 0.94088798761367798f, 0.95128101110458374f, 0.95866602659225464f, 0.96450901031494141f, 0.96921002864837646f, 0.973052978515625f, 0.97623497247695923f, 0.97890102863311768f, 0.98115700483322144f, 0.98308497667312622f, 0.98474901914596558f, 0.98619699478149414f, 0.98746699094772339f, 0.98858797550201416f, 0.98958402872085571f, 0.99047297239303589f, 0.99127000570297241f, 0.99198299646377563f, 0.99262100458145142f, 0.99318897724151611f, 0.99372398853302002f, 0.99426800012588501f, 0.99475300312042236f, 0.99514400959014893f, 0.86131101846694946f, 0.88463401794433594f, 0.90212702751159668f, 0.91595500707626343f, 0.92708200216293335f, 0.93617302179336548f, 0.94370102882385254f, 0.95000702142715454f, 0.95534700155258179f, 0.9599120020866394f, 0.96384698152542114f, 0.96726799011230469f, 0.97026199102401733f, 0.97289901971817017f, 0.97523599863052368f, 0.97731602191925049f, 0.97917401790618896f, 0.98083901405334473f, 0.98233497142791748f, 0.98368102312088013f, 0.98489302396774292f, 0.98598498106002808f, 0.98697298765182495f, 0.98787301778793335f, 0.75306302309036255f, 0.79328000545501709f, 0.82418698072433472f, 0.84881901741027832f, 0.86874997615814209f, 0.88506197929382324f, 0.89858502149581909f, 0.9099239706993103f, 0.91952997446060181f, 0.9277459979057312f, 0.93483197689056396f, 0.94099199771881104f, 0.9463840126991272f, 0.95113497972488403f, 0.95534402132034302f, 0.95908999443054199f, 0.9624369740486145f, 0.96543699502944946f, 0.96813201904296875f, 0.97055697441101074f, 0.97274202108383179f, 0.97471201419830322f, 0.97649002075195312f, 0.97809398174285889f, 0.62183499336242676f, 0.68052101135253906f, 0.72705197334289551f, 0.76452702283859253f, 0.79505598545074463f, 0.82021200656890869f, 0.84120297431945801f, 0.85885602235794067f, 0.87384098768234253f, 0.88667500019073486f, 0.89775800704956055f, 0.90739899873733521f, 0.91584599018096924f, 0.92329102754592896f, 0.929889976978302f, 0.93576502799987793f, 0.94101500511169434f, 0.94572198390960693f, 0.94994997978210449f, 0.95375597476959229f, 0.95718497037887573f, 0.9602770209312439f, 0.96306699514389038f, 0.96558600664138794f, 0.47742500901222229f, 0.5522189736366272f, 0.61415499448776245f, 0.66520899534225464f, 0.70744901895523071f, 0.74262100458145142f, 0.77213901281356812f, 0.7971159815788269f, 0.81841897964477539f, 0.83673000335693359f, 0.85258400440216064f, 0.86640900373458862f, 0.87854301929473877f, 0.88924998044967651f, 0.89874798059463501f, 0.90721100568771362f, 0.91477799415588379f, 0.92156499624252319f, 0.92766499519348145f, 0.93315702676773071f, 0.9381060004234314f, 0.94257098436355591f, 0.94660097360610962f, 0.95023900270462036f, 0.33539599180221558f, 0.41908100247383118f, 0.49247598648071289f, 0.55531197786331177f, 0.60879099369049072f, 0.65415602922439575f, 0.69274699687957764f, 0.72571200132369995f, 0.75402498245239258f, 0.77849102020263672f, 0.79976201057434082f, 0.81836599111557007f, 0.83474302291870117f, 0.84922301769256592f, 0.86208897829055786f, 0.87356698513031006f, 0.88384199142456055f, 0.89306402206420898f, 0.90135800838470459f, 0.9088289737701416f, 0.91556602716445923f, 0.92164498567581177f, 0.92713397741317749f, 0.93208998441696167f, 0.21194499731063843f, 0.29365798830986023f, 0.37110498547554016f, 0.44143900275230408f, 0.5036969780921936f, 0.55801302194595337f, 0.60521197319030762f, 0.64614301919937134f, 0.68169897794723511f, 0.71268302202224731f, 0.73979401588439941f, 0.76362699270248413f, 0.78467601537704468f, 0.80335497856140137f, 0.82000100612640381f, 0.83488202095031738f, 0.8482239842414856f, 0.86021500825881958f, 0.87101101875305176f, 0.88074499368667603f, 0.88952797651290894f, 0.89745801687240601f, 0.90461999177932739f, 0.91109001636505127f, 0.11949499696493149f, 0.18745699524879456f, 0.25997200608253479f, 0.33120998740196228f, 0.39773499965667725f, 0.45832300186157227f, 0.51248997449874878f, 0.56048798561096191f, 0.6028980016708374f, 0.64032697677612305f, 0.67339599132537842f, 0.70268499851226807f, 0.72870397567749023f, 0.75189602375030518f, 0.77263599634170532f, 0.7912449836730957f, 0.80796998739242554f, 0.82303100824356079f, 0.8366129994392395f, 0.84887397289276123f, 0.85994899272918701f, 0.86995697021484375f, 0.87900298833847046f, 0.88717901706695557f, 0.05942929908633232f, 0.10839699953794479f, 0.16785700619220734f, 0.23236599564552307f, 0.29767501354217529f, 0.36022999882698059f, 0.41842898726463318f, 0.47170799970626831f, 0.5198180079460144f, 0.56301301717758179f, 0.60171198844909668f, 0.63635998964309692f, 0.66739702224731445f, 0.69524997472763062f, 0.720287024974823f, 0.74283498525619507f, 0.76317602396011353f, 0.78155702352523804f, 0.79817098379135132f, 0.81319701671600342f, 0.8267899751663208f, 0.83908802270889282f, 0.85021400451660156f, 0.86027902364730835f, 0.02584660053253174f, 0.05619670078158379f, 0.09917669743299484f, 0.15162299573421478f, 0.20941600203514099f, 0.26902499794960022f, 0.32757499814033508f, 0.38318398594856262f, 0.43501600623130798f, 0.48271399736404419f, 0.52620798349380493f, 0.56570100784301758f, 0.60149699449539185f, 0.63392102718353271f, 0.66328197717666626f, 0.68988502025604248f, 0.7139970064163208f, 0.7358660101890564f, 0.75570398569107056f, 0.77369099855422974f, 0.78999698162078857f, 0.80477499961853027f, 0.81816202402114868f, 0.83028298616409302f, 0.00968609005212784f, 0.02591750025749207f, 0.05318830162286758f, 0.09121809899806976f, 0.13777700066566467f, 0.18976299464702606f, 0.244159996509552f, 0.29880800843238831f, 0.35169300436973572f, 0.40180501341819763f, 0.44872200489044189f, 0.49213200807571411f, 0.53206497430801392f, 0.5686650276184082f, 0.60214298963546753f, 0.63272500038146973f, 0.66062301397323608f, 0.68605399131774902f, 0.70922297239303589f, 0.73031198978424072f, 0.74948400259017944f, 0.76689702272415161f, 0.78270000219345093f, 0.79702901840209961f, 0.00303822988644242f, 0.01048239972442389f, 0.02568300068378448f, 0.05025380104780197f, 0.08408640325069427f, 0.12561400234699249f, 0.17249999940395355f, 0.22232000529766083f, 0.27309399843215942f, 0.32321798801422119f, 0.37149098515510559f, 0.4173240065574646f, 0.4603630006313324f, 0.50043797492980957f, 0.53755801916122437f, 0.57181298732757568f, 0.60333001613616943f, 0.63226902484893799f, 0.65877401828765869f, 0.68301999568939209f, 0.70514601469039917f, 0.7253040075302124f, 0.74363899230957031f, 0.76029098033905029f, 0.00076204299693927f, 0.00361976004205644f, 0.0110037000849843f, 0.02512970007956028f, 0.04727460071444511f, 0.07745999842882156f, 0.11460299789905548f, 0.1569570004940033f, 0.20258499681949615f, 0.24971699714660645f, 0.29707801342010498f, 0.34340900182723999f, 0.38799500465393066f, 0.43043500185012817f, 0.47039699554443359f, 0.50777101516723633f, 0.54253697395324707f, 0.57473397254943848f, 0.60444700717926025f, 0.63179397583007812f, 0.65686798095703125f, 0.67979699373245239f, 0.70071202516555786f, 0.71974599361419678f, 0.00014345299859997f, 0.00102306995540857f, 0.00407376000657678f, 0.01122699957340956f, 0.02423799969255924f, 0.04415180161595345f, 0.07109060138463974f, 0.10433399677276611f, 0.14259399473667145f, 0.184347003698349f, 0.2281080037355423f, 0.27265200018882751f, 0.31696400046348572f, 0.36016398668289185f, 0.40178799629211426f, 0.44139501452445984f, 0.47875601053237915f, 0.51375597715377808f, 0.54635101556777954f, 0.57658302783966064f, 0.60447400808334351f, 0.63009101152420044f, 0.65352898836135864f, 0.67488902807235718f, 0.00001858420000644f, 0.0002227969962405f, 0.00124967005103827f, 0.00435766018927097f, 0.01113030035048723f, 0.0229835007339716f, 0.04079980030655861f, 0.06477940082550049f, 0.09447769820690155f, 0.12897300720214844f, 0.16708999872207642f, 0.20760199427604675f, 0.24936899542808533f, 0.29154899716377258f, 0.3332040011882782f, 0.37377101182937622f, 0.41274300217628479f, 0.44977998733520508f, 0.4846780002117157f, 0.51733100414276123f, 0.54769200086593628f, 0.57572799921035767f, 0.6014779806137085f, 0.62501102685928345f, 1.46482000218384201e-06f, 0.00003429050047998f, 0.0002985020109918f, 0.00140504003502429f, 0.00443577999249101f, 0.01069260016083717f, 0.02133879996836185f, 0.0371410995721817f, 0.05836030095815659f, 0.08476380258798599f, 0.11572299897670746f, 0.1503559947013855f, 0.18766500055789948f, 0.22665500640869141f, 0.26647698879241943f, 0.30632400512695312f, 0.34550899267196655f, 0.38344401121139526f, 0.41970700025558472f, 0.45401400327682495f, 0.48618701100349426f, 0.51614201068878174f, 0.54384201765060425f, 0.56930899620056152f, 5.83937982412408019e-08f, 3.2765999549155822e-06f, 0.00005055400106357f, 0.00035111699253321f, 0.00145683996379375f, 0.00427943980321288f, 0.0098936902359128f, 0.01927389949560165f, 0.03310279920697212f, 0.05168719962239265f, 0.07495570182800293f, 0.10250899940729141f, 0.13370099663734436f, 0.1677280068397522f, 0.20372100174427032f, 0.24084299802780151f, 0.27840098738670349f, 0.31564199924468994f, 0.35190799832344055f, 0.38674798607826233f, 0.41985601186752319f, 0.45104199647903442f, 0.48021000623703003f, 0.50734001398086548f, 8.73966010672688753e-10f, 1.57741993689342053e-07f, 5.21975016454234719e-06f, 0.00006079579907237f, 0.00036219600588083f, 0.00138045998755842f, 0.00386844994500279f, 0.00871635042130947f, 0.01675550080835819f, 0.02860799990594387f, 0.04461279883980751f, 0.06480839848518372f, 0.08895269781351089f, 0.11656700074672699f, 0.1470009982585907f, 0.17950700223445892f, 0.21331800520420074f, 0.24785000085830688f, 0.28237700462341309f, 0.31631898880004883f, 0.34923198819160461f, 0.38083100318908691f, 0.41094100475311279f, 0.43946701288223267f, 2.8866399288257627e-12f, 2.63671995348602195e-09f, 2.51094007808205788e-07f, 5.97520011069718748e-06f, 0.00005859580051037f, 0.0003192939911969f, 0.00116373994387686f, 0.00319523992948234f, 0.00714873988181353f, 0.0137449000030756f, 0.0235638003796339f, 0.03696820139884949f, 0.05407309904694557f, 0.0747511014342308f, 0.09866459667682648f, 0.12531900405883789f, 0.15412400662899017f, 0.18446199595928192f, 0.21573600172996521f, 0.24741099774837494f, 0.27903899550437927f, 0.310263991355896f, 0.34082499146461487f, 0.37054198980331421f, 6.94488983838260476e-16f, 7.04290011727115584e-12f, 3.21448001550095341e-09f, 2.20180993437679717e-07f, 4.50593006462440826e-06f, 0.00004154839916737f, 0.00022262999846134f, 0.00081575999502093f, 0.00227530999109149f, 0.00519366981461644f, 0.01020010001957417f, 0.0178545992821455f, 0.02856850065290928f, 0.04256030172109604f, 0.05984469875693321f, 0.08025020360946655f, 0.10345599800348282f, 0.12904399633407593f, 0.15654699504375458f, 0.1854960024356842f, 0.21545499563217163f, 0.24603499472141266f, 0.27690801024436951f, 0.3078019917011261f, 5.46278023199234311e-22f, 3.43167987041791307e-16f, 2.29294990113093622e-12f, 9.57796952860689998e-10f, 6.87986982939037262e-08f, 1.5533599935224629e-06f, 0.00001600819996384f, 0.00009555240103509f, 0.00038631301140413f, 0.00117554003372788f, 0.00289549003355205f, 0.00607588002458215f, 0.01126710046082735f, 0.01896269991993904f, 0.02954130060970783f, 0.04323289915919304f, 0.06011129915714264f, 0.0801049992442131f, 0.10301999747753143f, 0.12857000529766083f, 0.15640300512313843f, 0.18612800538539886f, 0.21734000742435455f, 0.24963200092315674f, 0.0f, 0.0f, 3.09890004335006815e-24f, 2.21276004416278673e-18f, 2.67358004631774657e-14f, 2.24439997836833882e-11f, 3.13075010360819306e-09f, 1.26480998119404831e-07f, 2.12951999856159091e-06f, 0.00001907769910758f, 0.00010753999958979f, 0.00042892698547803f, 0.00131604995112866f, 0.00330013991333544f, 0.00707077002152801f, 0.01337909977883101f, 0.02291939966380596f, 0.03622379899024963f, 0.05359359830617905f, 0.07507230341434479f, 0.10045900195837021f, 0.12935000658035278f, 0.16119599342346191f, 0.19536399841308594f
} };
static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

__device__ float anisotropicG1(float3  w_1, float2  alphas_2)
{
    float _S231 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S231 / (_S231 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S231)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S232 = alphas_3.x;
    float _S233 = h_0.x / _S232;
    float _S234 = alphas_3.y;
    float _S235 = h_0.y / _S234;
    float _S236 = h_0.z;
    float _S237 = _S233 * _S233 + _S235 * _S235 + _S236 * _S236;
    return 1.0f / (F32_max((3.14159274101257324f * _S232 * _S234 * _S237 * _S237), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_3, float3  n_i_2, float3  ggx_n_0, BSDFMaterial material_2, float eta_i_2, float eta_o_2, AnisotropicFrame frame_2)
{
    float _S238 = dot_0(ggx_n_0, v_3);
    float _S239 = dot_0(n_i_2, ggx_n_0);
    float _S240 = eta_i_2 / eta_o_2;
    float3  _S241 = refract_0(in_dir_3, ggx_n_0, _S240);
    float3  _S242 = ((((_S241)) * make_float3(rnorm3df(((_S241)).x, ((_S241)).y, ((_S241)).z))));
    float _S243 = (F32_min(((F32_sqrt((material_2.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S244 = _S243 * _S243;
    float _S245 = (1.0f + _S243) / (1.0f - _S243);
    float _S246 = (F32_abs((_S238)));
    bool _S247 = eta_i_2 > eta_o_2;
    float sheen_component_0;
    if(_S247)
    {
        sheen_component_0 = _S245;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float toon_component_0;
    if(_S247)
    {
        toon_component_0 = 1.0f;
    }
    else
    {
        toon_component_0 = _S245;
    }
    float _S248 = fresnel(_S246, sheen_component_0, toon_component_0);
    bool _S249 = (eta_i_2 * eta_i_2 * (1.0f - _S238 * _S238)) >= (eta_o_2 * eta_o_2);
    float3  _S250;
    if(_S249)
    {
        _S250 = make_float3 (1.0f);
    }
    else
    {
        float3  _S251 = material_2.specular_tint * make_float3 (_S244);
        _S250 = _S251 + (make_float3 (1.0f) - _S251) * make_float3 (_S248 - _S244) / make_float3 (1.0f - _S244);
    }
    float3  _S252 = make_float3 (1.0f);
    float3  _S253 = make_float3 (0.0f);
    float _S254 = rgb_to_greyscale(material_2.sheen);
    bool _S255 = _S254 > 0.0f;
    float3  sheen_1;
    float3  view_1;
    float3  scale_0;
    if(_S255)
    {
        float _S256 = clamp_0((F32_sqrt(((F32_max((dot_0(n_i_2, v_3)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S257 = (U32_min((uint(_S256)), (22U)));
        float least_0 = (F32_sqrt((0.05000000074505806f)));
        float _S258 = (F32_sqrt((0.10000000149011612f)));
        bool _S259 = (material_2.velvet) > 0.0f;
        float _S260 = _slang_select(_S259, _S258,least_0);
        float _S261 = (clamp_0((F32_sqrt(((F32_max((material_2.sheen_roughness), (0.0f)))))), _S260, 1.0f) - _S260) / (1.0f - _S260) * 23.0f;
        uint _S262 = (U32_min((uint(_S261)), (22U)));
        uint _S263 = _S257 * 24U + _S262;
        float _S264 = _S256 - float(_S257);
        float _S265 = _S261 - float(_S262);
        uint _S266 = _S263 + 24U;
        float a_4 = SHEEN_ALBEDO_0[_S263] + (SHEEN_ALBEDO_0[_S266] - SHEEN_ALBEDO_0[_S263]) * _S264;
        uint _S267 = _S263 + 1U;
        uint _S268 = _S266 + 1U;
        float b_0 = SHEEN_ALBEDO_0[_S267] + (SHEEN_ALBEDO_0[_S268] - SHEEN_ALBEDO_0[_S267]) * _S264;
        float _S269 = (F32_exp((a_4 + (b_0 - a_4) * _S265)));
        if(_S259)
        {
            float a_5 = VELVET_ALBEDO_0[_S263] + (VELVET_ALBEDO_0[_S266] - VELVET_ALBEDO_0[_S263]) * _S264;
            float b_1 = VELVET_ALBEDO_0[_S267] + (VELVET_ALBEDO_0[_S268] - VELVET_ALBEDO_0[_S267]) * _S264;
            float _S270 = a_5 + (b_1 - a_5) * _S265;
            sheen_component_0 = _S270;
        }
        else
        {
            sheen_component_0 = _S269;
        }
        float _S271 = (F32_min((sheen_component_0), (1.0f)));
        float3  _S272 = make_float3 (1.0f) - material_2.sheen * make_float3 (_S271);
        float _S273 = rgb_to_greyscale(material_2.sheen);
        float _S274 = _S273 * _S271;
        float3  _S275 = material_2.sheen / make_float3 ((F32_max((sheen_component_0), (1.0f))));
        sheen_component_0 = _S274;
        sheen_1 = _S275;
        view_1 = v_3;
        scale_0 = _S272;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S253;
        view_1 = _S253;
        scale_0 = _S252;
    }
    float _S276 = material_2.toon.x;
    bool _S277 = _S276 < 0.0f;
    float _S278 = (F32_abs((_S276)));
    bool _S279 = _S278 > 0.0f;
    float toon_a_1;
    float toon_s_1;
    float toon_b_1;
    float toon_norm_1;
    float toon_view_1;
    float3  toon_1;
    float3  toon_axis_1;
    bool _S280;
    if(_S279)
    {
        float _S281 = (F32_min((_S278), (1.0f)));
        float3  scale_1 = scale_0 * make_float3 (1.0f - _S281);
        float _S282 = rgb_to_greyscale(material_2.albedo);
        float _S283 = _S281 * _S282;
        float3  _S284 = make_float3 (_S281) * material_2.albedo;
        float toon_a_2 = clamp_0(material_2.toon.y / _S276, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_2 = clamp_0(material_2.toon.z / _S276, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S285 = (F32_min((toon_a_2 + toon_s_2), (1.57079637050628662f)));
        if(_S277)
        {
            toon_component_0 = 1.0f - (F32_cos(((F32_min((_S285), (toon_a_2))))));
        }
        else
        {
            float _S286 = (F32_sin(((F32_min((_S285), (toon_a_2))))));
            toon_component_0 = _S286 * _S286 / 2.0f;
        }
        bool _S287 = _S285 > toon_a_2;
        if(_S287)
        {
            _S280 = toon_s_2 > 0.0f;
        }
        else
        {
            _S280 = false;
        }
        if(_S280)
        {
            if(_S277)
            {
                float _S288 = (F32_cos((toon_a_2)));
                float _S289 = (F32_cos((_S285)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S288 - _S289) - ((F32_sin((_S285))) - _S285 * _S289 - ((F32_sin((toon_a_2))) - toon_a_2 * _S288)) / toon_s_2;
            }
            else
            {
                float _S290 = 2.0f * toon_a_2;
                float _S291 = (F32_cos((_S290)));
                float _S292 = 2.0f * _S285;
                float _S293 = (F32_cos((_S292)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S291 - _S293) / 4.0f - ((F32_sin((_S292))) / 8.0f - _S285 * _S293 / 4.0f - ((F32_sin((_S290))) / 8.0f - toon_a_2 * _S291 / 4.0f)) / toon_s_2;
            }
            float integral_0 = toon_component_0 + toon_a_1;
            toon_component_0 = integral_0;
        }
        float _S294 = 6.28318548202514648f * toon_component_0;
        float _S295 = dot_0(n_i_2, v_3);
        float _S296 = (F32_acos(((F32_min((_S295), (1.0f))))));
        if(_S296 < toon_a_2)
        {
            toon_component_0 = 1.0f;
        }
        else
        {
            toon_component_0 = (F32_max((1.0f - (_S296 - toon_a_2) / (F32_max((toon_s_2), (0.0000152587890625f)))), (0.0f)));
        }
        if(_S277)
        {
            float3  _S297 = make_float3 (2.0f * _S295) * n_i_2 - v_3;
            float3  _S298 = ((((_S297)) * make_float3(rnorm3df(((_S297)).x, ((_S297)).y, ((_S297)).z))));
            scale_0 = _S298;
        }
        else
        {
            scale_0 = n_i_2;
        }
        float _S299 = toon_component_0;
        toon_component_0 = _S283;
        toon_1 = _S284;
        toon_a_1 = toon_a_2;
        toon_s_1 = toon_s_2;
        toon_b_1 = _S285;
        toon_norm_1 = _S294;
        toon_view_1 = _S299;
        toon_axis_1 = scale_0;
        scale_0 = scale_1;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S253;
        toon_a_1 = 0.0f;
        toon_s_1 = 0.0f;
        toon_b_1 = 0.0f;
        toon_norm_1 = 1.0f;
        toon_view_1 = 0.0f;
        toon_axis_1 = n_i_2;
    }
    float3  _S300 = mix_0(_S250, material_2.albedo, material_2.metallic);
    float3  F_1 = _S300 * scale_0;
    float _S301 = rgb_to_greyscale(F_1);
    float _S302 = 1.0f - material_2.metallic;
    float3  _S303 = make_float3 (1.0f) - _S250;
    float3  _S304 = make_float3 ((1.0f - material_2.transmission) * _S302) * _S303 * scale_0;
    float3  _S305 = make_float3 (material_2.transmission * _S302) * _S303 * scale_0;
    float _S306 = (F32_max((_S301), (0.0f)));
    float _S307 = rgb_to_greyscale(_S304);
    float _S308 = (F32_max((_S307), (0.0f)));
    float _S309 = rgb_to_greyscale(_S305);
    float _S310 = sign_0(length_0(_S242));
    float _S311 = (F32_max((_S309 * _S310), (0.0f)));
    float _S312 = _S306 + _S308 + _S311 + toon_component_0;
    float _S313 = (F32_min((sheen_component_0), (1.0f)));
    bool _S314 = sheen_component_0 > 0.0f;
    if(_S314)
    {
        _S280 = !(_S312 > 0.0f);
    }
    else
    {
        _S280 = false;
    }
    float _S315 = _slang_select(_S280, 1.0f,_S313);
    float _S316 = (1.0f - _S315) / (F32_max((_S312), (0.0000152587890625f)));
    float _S317 = _S308 * _S316;
    float _S318 = _S306 * _S316;
    float _S319 = _S311 * _S316;
    bool _S320 = (frame_2.alphas.x) > 0.0f;
    float visible_1;
    if(_S320)
    {
        float3  _S321 = anisotropicLocal(v_3, frame_2.tangent, n_i_2);
        float _S322 = anisotropicG1(_S321, frame_2.alphas);
        float3  _S323 = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_2);
        float _S324 = anisotropicD(_S323, frame_2.alphas);
        float _S325 = _S322 * _S324;
        visible_1 = _S325;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S238, _S239, _S242, F_1, _S301, 1.0f, _S304, _S305, _S317, _S318, _S319, 0.0f, sheen_1, _S315, view_1, frame_2.tangent, frame_2.alphas, visible_1, toon_component_0 * _S316, toon_1, toon_a_1, toon_s_1, toon_b_1, _S277, toon_norm_1, toon_view_1, toon_axis_1);
}

__device__ float translucentShare(BSDFMaterial material_3)
{
    float _S326 = rgb_to_greyscale(material_3.translucent);
    float _S327 = rgb_to_greyscale(material_3.albedo);
    float _S328 = _S326 / (_S327 + _S326);
    bool _S329 = _S326 > 0.0f;
    float _S330 = _slang_select(_S329, _S328,0.0f);
    return _S330;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_2, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S331 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S332 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S333 = 1.0f - lobes_0.translucent_share;
    bool _S334 = n_i_dot_l_0 < 0.0f;
    float _S335 = _slang_select(_S334, lobes_0.translucent_share,_S333);
    float _S336 = _S332 * _S335;
    bool _S337 = (lobes_0.translucent_share) > 0.0f;
    float _S338 = _slang_select(_S337, _S336,_S331);
    bool _S339 = n_i_dot_v_0 > 0.0f;
    float _S340 = _slang_select(_S339, _S338,0.0f);
    return _S340;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_3, float alpha_3, BSDFMaterial material_4, BSDFLobes lobes_1)
{
    bool _S341 = (dot_0(n_i_3, l_0)) < 0.0f;
    float3  _S342 = _slang_select(_S341, material_4.translucent,material_4.albedo);
    float _S343 = 1.0f - lobes_1.translucent_share;
    float _S344 = _slang_select(_S341, lobes_1.translucent_share,_S343);
    float3  _S345 = _S342 / make_float3 (_S344);
    bool _S346 = (lobes_1.translucent_share) > 0.0f;
    float3  _S347 = _slang_select(_S346, _S345,material_4.albedo);
    return lobes_1.diffuse_weight * _S347 / make_float3 (lobes_1.p_diffuse);
}

__device__ float smithG1(float alpha_4, float n_dot_x_0)
{
    float _S348 = alpha_4 * alpha_4;
    float _S349 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S348 + (1.0f - _S348) * n_dot_x_0 * n_dot_x_0))));
    bool _S350 = alpha_4 > 0.0f;
    float _S351 = _slang_select(_S350, _S349,1.0f);
    return _S351;
}

__device__ float trowbridgeReitz(float alpha_5, float n_dot_h_1)
{
    float _S352 = alpha_5 * alpha_5;
    float _S353 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S352 * n_dot_h_1 * n_dot_h_1;
    return _S352 / (F32_max((3.14159274101257324f * _S353 * _S353), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S354 = smithG1(alpha_6, n_i_dot_v_1);
    float _S355 = _S354 * lobes_2.v_dot_h;
    float _S356 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S357 = _S355 * _S356 / n_i_dot_v_1;
    bool _S358 = alpha_6 > 0.0f;
    bool _S359;
    if(_S358)
    {
        _S359 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S359 = false;
    }
    if(_S359)
    {
        _S359 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S359 = false;
    }
    if(_S359)
    {
        _S359 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S359 = false;
    }
    float _S360 = _slang_select(_S359, _S357,0.0f);
    bool _S361 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S361)
    {
        float _S362 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S363 = (lobes_2.v_dot_h) > 0.0f;
        if(_S363)
        {
            _S359 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S359 = false;
        }
        if(_S359)
        {
            _S359 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S359 = false;
        }
        float _S364 = _slang_select(_S359, _S362,0.0f);
        pdf_h_0 = _S364;
    }
    else
    {
        pdf_h_0 = _S360;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S365 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S366 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S367 = lobes_3.p_refract * _S365 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S366 * _S366);
    bool _S368 = eta_i_4 != eta_o_4;
    bool _S369;
    if(_S368)
    {
        _S369 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S369 = false;
    }
    float _S370 = _slang_select(_S369, _S367,0.0f);
    return _S370;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_4, float alpha_8, BSDFMaterial material_5, BSDFLobes lobes_4)
{
    float _S371 = - dot_0(n_i_4, l_1);
    float _S372 = smithG1(alpha_8, (F32_max((_S371), (0.0f))));
    bool _S373 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S373)
    {
        float3  _S374 = negate_0(n_i_4);
        float3  _S375 = anisotropicLocal(l_1, lobes_4.tangent, _S374);
        float _S376 = anisotropicG1(_S375, lobes_4.alphas);
        G1_l_0 = _S376;
    }
    else
    {
        G1_l_0 = _S372;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_5.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S377 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S378 = n_i_dot_l_2 > 0.0f;
    bool _S379;
    if(_S378)
    {
        _S379 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S379 = false;
    }
    float _S380 = _slang_select(_S379, _S377,0.0f);
    return _S380;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_5, float alpha_10, BSDFMaterial material_6, BSDFLobes lobes_6)
{
    float3  _S381 = l_2 + lobes_6.view;
    float3  _S382 = ((((_S381)) * make_float3(rnorm3df(((_S381)).x, ((_S381)).y, ((_S381)).z))));
    float _S383 = dot_0(n_i_5, _S382);
    float _S384 = (F32_max((dot_0(n_i_5, l_2)), (0.0f)));
    float _S385 = (F32_max((dot_0(n_i_5, lobes_6.view)), (0.0f)));
    float _S386 = 1.0f / (F32_max((material_6.sheen_roughness), (0.05000000074505806f)));
    float _S387 = 1.0f - _S383 * _S383;
    float _S388 = (2.0f + _S386) * (F32_pow(((F32_max((_S387), (0.0f)))), (0.5f * _S386))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S384 + _S385 - _S384 * _S385)), (0.0000152587890625f)));
    bool _S389 = (material_6.velvet) > 0.0f;
    float f_0;
    if(_S389)
    {
        float _S390 = (F32_max((material_6.sheen_roughness), (0.00999999977648258f)));
        float _S391 = _S390 * _S390;
        float _S392 = (F32_max((_S387), (0.0000152587890625f)));
        float _S393 = (F32_exp((- _S383 * _S383 / (_S392 * _S391)))) / (3.14159274101257324f * _S391 * _S392 * _S392) * (F32_min((1.0f), (2.0f * _S383 * (F32_min((_S384), (_S385))) / (F32_max(((F32_abs((dot_0(_S382, lobes_6.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S384 * _S385), (0.0000152587890625f)));
        f_0 = _S393;
    }
    else
    {
        f_0 = _S388;
    }
    return lobes_6.sheen * make_float3 (f_0 * _S384 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float toonPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, BSDFLobes lobes_7, float eta_i_6, float eta_o_6)
{
    float _S394 = _slang_select(lobes_7.toon_glossy, l_dot_h_3,n_i_dot_l_3);
    float _S395 = (F32_acos((clamp_0(_S394, -1.0f, 1.0f))));
    float _S396;
    if(_S395 < (lobes_7.toon_a))
    {
        _S396 = 1.0f;
    }
    else
    {
        _S396 = (F32_max((1.0f - (_S395 - lobes_7.toon_a) / (F32_max((lobes_7.toon_s), (0.0000152587890625f)))), (0.0f)));
    }
    float _S397 = lobes_7.p_toon * _S396;
    float _S398 = _slang_select(lobes_7.toon_glossy, 1.0f,n_i_dot_l_3);
    float _S399 = _S397 * _S398 / lobes_7.toon_norm;
    bool _S400;
    if(lobes_7.toon_glossy)
    {
        _S400 = true;
    }
    else
    {
        _S400 = n_i_dot_l_3 > 0.0f;
    }
    float _S401 = _slang_select(_S400, _S399,0.0f);
    return _S401;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_3, float3  n_i_6, float alpha_12, BSDFMaterial material_7, BSDFLobes lobes_8)
{
    float _S402 = (F32_max((dot_0(n_i_6, l_3)), (0.0f)));
    float _S403 = _slang_select(lobes_8.toon_glossy, _S402,lobes_8.toon_view);
    return lobes_8.toon * make_float3 (_S403) / make_float3 (lobes_8.p_toon);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_4, float l_dot_h_4, float n_i_dot_v_5, float alpha_13, BSDFLobes lobes_9, float eta_i_7, float eta_o_7)
{
    float _S404 = vndfPDF(n_i_dot_v_5, alpha_13, lobes_9);
    float _S405 = lobes_9.p_reflect * _S404 / (4.0f * lobes_9.v_dot_h);
    bool _S406 = _S404 > 0.0f;
    float _S407 = _slang_select(_S406, _S405,0.0f);
    return _S407;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_4, float3  n_i_7, float alpha_14, BSDFMaterial material_8, BSDFLobes lobes_10)
{
    float _S408 = dot_0(n_i_7, l_4);
    float _S409 = smithG1(alpha_14, (F32_max((_S408), (0.0f))));
    bool _S410 = (lobes_10.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S410)
    {
        float3  _S411 = anisotropicLocal(l_4, lobes_10.tangent, n_i_7);
        float _S412 = anisotropicG1(_S411, lobes_10.alphas);
        G1_l_1 = _S412;
    }
    else
    {
        G1_l_1 = _S409;
    }
    return make_float3 (lobes_10.reflect_weight * G1_l_1) * lobes_10.F / make_float3 (lobes_10.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_9, float eta_i_8, float eta_o_8, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S413 = negate_0(in_dir_4);
    float _S414 = dot_0(n_7, _S413);
    float _S415 = sign_0(_S414);
    float3  _S416 = n_7 * make_float3 (_S415);
    AnisotropicFrame _S417 = anisotropicFrame(material_9, _S416);
    float _S418 = dot_0(_S416, out_dir_2);
    float _S419 = material_9.roughness;
    float _S420 = _S419 * _S419;
    float _S421 = rgb_to_greyscale(material_9.translucent);
    bool _S422 = _S421 > 0.0f;
    bool _S423 = (dot_0(n_7, out_dir_2) * _S414) < 0.0f;
    uint _S424;
    if((F32_abs((material_9.toon.x))) > 0.0f)
    {
        _S424 = 5U;
    }
    else
    {
        _S424 = 4U;
    }
    uint i_2 = 0U;
    for(;;)
    {
        if(i_2 < 5U)
        {
        }
        else
        {
            break;
        }
        float3  _S425 = make_float3 (0.0f);
        (*throughputs_0)[i_2] = _S425;
        (*pdfs_0)[i_2] = 0.0f;
        uint i_3 = i_2 + 1U;
        i_2 = i_3;
    }
    float3  _S426 = make_float3 (0.0f);
    BSDFLobes _S427 = BSDFLobes_x24init_0(0.0f, 0.0f, _S426, _S426, 0.0f, 0.0f, _S426, _S426, 0.0f, 0.0f, 0.0f, 0.0f, _S426, 0.0f, _S426, _S426, make_float2 (0.0f), 0.0f, 0.0f, _S426, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S426);
    BSDFLobes lobe_terms_0 = _S427;
    uint half_of_0 = 4294967295U;
    float3  ggx_n_2 = _S426;
    i_2 = 0U;
    for(;;)
    {
        if(i_2 < _S424)
        {
        }
        else
        {
            break;
        }
        uint _S428;
        if(i_2 == 3U)
        {
            _S428 = 4U;
        }
        else
        {
            if(i_2 == 4U)
            {
                _S428 = 6U;
            }
            else
            {
                _S428 = i_2;
            }
        }
        bool _S429 = _S428 == 0U;
        bool _S430;
        if(_S429)
        {
            _S430 = _S422;
        }
        else
        {
            _S430 = false;
        }
        bool _S431;
        if(_S430)
        {
            _S431 = _S423;
        }
        else
        {
            _S431 = _S428 == 1U;
        }
        bool _S432 = _S431 != refracted_2;
        if(_S432)
        {
            ggx_n_1 = ggx_n_2;
            uint i_4 = i_2 + 1U;
            ggx_n_2 = ggx_n_1;
            i_2 = i_4;
            continue;
        }
        uint _S433;
        if(_S428 == 6U)
        {
            _S433 = 0U;
        }
        else
        {
            if(_S428 == 4U)
            {
                _S433 = 2U;
            }
            else
            {
                _S433 = _S428;
            }
        }
        bool _S434 = _S433 != half_of_0;
        uint half_of_1;
        if(_S434)
        {
            bool _S435 = _S433 == 0U;
            if(_S435)
            {
                float3  _S436 = sampledHalf(in_dir_4, n_7, material_9, random_state_4, _S417);
                ggx_n_1 = _S436;
            }
            else
            {
                bool _S437 = _S433 == 1U;
                if(_S437)
                {
                    float3  _S438 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_8, eta_o_8);
                    ggx_n_1 = _S438;
                }
                else
                {
                    float3  _S439 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S439;
                }
            }
            float3  _S440 = negate_0(in_dir_4);
            BSDFLobes _S441 = bsdfLobes(in_dir_4, _S440, _S416, ggx_n_1, material_9, eta_i_8, eta_o_8, _S417);
            lobe_terms_0 = _S441;
            float _S442 = translucentShare(material_9);
            (&lobe_terms_0)->translucent_share = _S442;
            half_of_1 = _S433;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S428)
        {
        case 0U:
            {
                float _S443 = diffusePDF(_S418, 0.0f, (F32_abs((_S414))), _S420, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(0)] = _S443;
                float3  _S444 = diffuseBSDF(out_dir_2, _S416, _S420, material_9, lobe_terms_0);
                (*throughputs_0)[int(0)] = _S444;
                break;
            }
        case 1U:
            {
                float _S445 = refractPDF(_S418, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S414))), _S420, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(1)] = _S445;
                float3  _S446 = refractBSDF(out_dir_2, _S416, _S420, material_9, lobe_terms_0);
                (*throughputs_0)[int(1)] = _S446;
                break;
            }
        case 4U:
            {
                float _S447 = sheenVelvetPDF(_S418, 0.0f, (F32_abs((_S414))), _S420, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(3)] = _S447;
                float3  _S448 = sheenVelvetBSDF(out_dir_2, _S416, _S420, material_9, lobe_terms_0);
                (*throughputs_0)[int(3)] = _S448;
                break;
            }
        case 6U:
            {
                float _S449 = toonPDF(_S418, dot_0(out_dir_2, (&lobe_terms_0)->toon_axis), (F32_abs((_S414))), _S420, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(4)] = _S449;
                float3  _S450 = toonBSDF(out_dir_2, _S416, _S420, material_9, lobe_terms_0);
                (*throughputs_0)[int(4)] = _S450;
                break;
            }
        default:
            {
                float _S451 = reflectPDF(_S418, 0.0f, (F32_abs((_S414))), _S420, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(2)] = _S451;
                float3  _S452 = reflectBSDF(out_dir_2, _S416, _S420, material_9, lobe_terms_0);
                (*throughputs_0)[int(2)] = _S452;
                break;
            }
        }
        half_of_0 = half_of_1;
        uint i_4 = i_2 + 1U;
        ggx_n_2 = ggx_n_1;
        i_2 = i_4;
    }
    i_2 = 0U;
    ggx_n_1 = _S426;
    for(;;)
    {
        if(i_2 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S453 = ((*pdfs_0)[i_2]) > 0.0f;
        if(_S453)
        {
            float3  f_1 = ggx_n_1 + (*throughputs_0)[i_2] * make_float3 ((*pdfs_0)[i_2]);
            ggx_n_1 = f_1;
        }
        uint i_5 = i_2 + 1U;
        i_2 = i_5;
    }
    return ggx_n_1;
}

static __device__ __forceinline__ float3  skyLobes_0(float3  in_dir_5, float3  dir_3, FKSurface * surface_1, float2  eta_1, bool is_inside_2, float pdf_0, uint random_state_5, FixedArray<float3 , 5>  * terms_0, FixedArray<float, 5>  * pdfs_1)
{
    bool _S454 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    float3  _S455 = BSDF(in_dir_5, dir_3, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S454, random_state_5, terms_0, pdfs_1);
    float3  _S456 = make_float3 (0.0f);
    uint i_6 = 0U;
    float3  f_2 = _S456;
    for(;;)
    {
        if(i_6 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S457 = ((*pdfs_1)[i_6]) > 0.0f;
        if(_S457)
        {
            float3  _S458 = (*terms_0)[i_6] * make_float3 ((*pdfs_1)[i_6]) / make_float3 ((*pdfs_1)[i_6] + pdf_0);
            (*terms_0)[i_6] = _S458;
            float3  f_3 = f_2 + (*terms_0)[i_6];
            f_2 = f_3;
        }
        uint i_7 = i_6 + 1U;
        i_6 = i_7;
    }
    return f_2;
}

__device__ float3  skyBSDF(float3  in_dir_6, float3  dir_4, FKSurface surface_2, float2  eta_2, bool is_inside_3, float pdf_1, uint random_state_6)
{
    FKSurface _S459 = surface_2;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S460 = skyLobes_0(in_dir_6, dir_4, &_S459, eta_2, is_inside_3, pdf_1, random_state_6, &terms_1, &pdfs_2);
    return _S460;
}

static __device__ bool all_0(bool3  x_9)
{
    bool result_1 = true;
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
        if(result_1)
        {
            result_1 = (bool((_slang_vector_get_element(x_9, i_8))));
        }
        else
        {
            result_1 = false;
        }
        i_8 = i_8 + int(1);
    }
    return result_1;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S461;
    (&_S461)->dir = dir_5;
    (&_S461)->radiance = radiance_0;
    (&_S461)->color = color_0;
    (&_S461)->random_state = random_state_7;
    return _S461;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S462 = (fcptEnvironmentCdfSize());
    uint2  _S463 = make_uint2 (1U, 0U);
    uint2  _S464 = _S462 - _S463;
    Random _S465 = pcg(init_random_state_0);
    Random _S466 = pcg(_S465.state);
    Random _S467 = pcg(_S466.state);
    Random _S468 = pcg(_S467.state);
    uint _S469 = _S464.x;
    uint _S470 = searchCDF_0(make_uint2 (_S469, 0U), make_uint2 (0U, 1U), _S464.y, _S465.value);
    uint _S471 = searchCDF_0(make_uint2 (0U, _S470), _S463, _S469, _S466.value);
    float2  _S472 = make_float2 ((float)_S464.x, (float)_S464.y);
    float2  _S473 = (make_float2 (float(_S471), float(_S470)) + make_float2 (_S467.value, _S468.value)) / _S472 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S474 = _S473.y;
    float _S475 = (F32_sin((_S474)));
    float _S476 = _S473.x;
    float3  _S477 = make_float3 (- _S475 * (F32_cos((_S476))), _S475 * (F32_sin((_S476))), (F32_cos((_S474))));
    float _S478 = environmentPdf_0(_S477);
    float3  _S479 = skyBSDF(ray_0->unit_direction, _S477, *surface_3, eta_3, is_inside_4, _S478, lobe_state_0);
    bool _S480 = !(_S478 > 0.0f);
    bool _S481;
    if(_S480)
    {
        _S481 = true;
    }
    else
    {
        _S481 = all_0(_S479 == make_float3 (0.0f));
    }
    if(_S481)
    {
        float3  _S482 = make_float3 (0.0f);
        return SkySample_x24init_0(_S477, _S482, _S482, _S468.state);
    }
    float3  _S483 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S477, context_2, _S468.state);
    return SkySample_x24init_0(_S477, _S483, _S479 * _S483, _S468.state);
}

struct TreeSample
{
    float3  dir;
    float3  radiance;
    float density;
    uint random_state;
};

struct SampleBSDF
{
    float3  unit_direction;
    float3  throughput;
    uint random_state;
    bool refracted;
    uint lobe;
    float pdf;
};

static __device__ float3  hairLight_0(FKSurface * surface_4, float3  in_dir_7, TreeSample * light_1, bool competing_0)
{
    SampleBSDF _S484 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S485 = _S484.throughput * make_float3 (_S484.pdf);
    float _S486 = light_1->density;
    float _S487 = 1.0f + _S484.pdf * _S484.pdf / (light_1->density * light_1->density);
    bool _S488;
    if(competing_0)
    {
        _S488 = _S486 > 0.0f;
    }
    else
    {
        _S488 = false;
    }
    float _S489 = _slang_select(_S488, _S487,1.0f);
    return _S485 / make_float3 (_S489) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S490;
    (&_S490)->dir = dir_6;
    (&_S490)->radiance = radiance_1;
    (&_S490)->density = density_0;
    (&_S490)->random_state = random_state_8;
    return _S490;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_3, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S491 = importance(first_1, p_3, normal_3);
    float _S492 = importance(second_1, p_3, normal_3);
    float2  _S493 = make_float2 (_S491, _S492);
    bool _S494 = _S491 == 0.0f;
    bool _S495;
    if(_S494)
    {
        _S495 = _S492 == 0.0f;
    }
    else
    {
        _S495 = false;
    }
    if(_S495)
    {
        return 2U;
    }
    float _S496 = _S491 + _S492;
    bool _S497 = _S492 > 0.0f;
    if(_S497)
    {
        _S495 = (*pick_0 * _S496) >= _S491;
    }
    else
    {
        _S495 = false;
    }
    uint _S498 = uint(_S495);
    float _S499 = (F32_min(((*pick_0 * _S496 - float(_S498) * _S491) / _slang_vector_get_element(_S493, _S498)), (0.99999994039535522f)));
    *pick_0 = _S499;
    float _S500 = *probability_3 * (_slang_vector_get_element(_S493, _S498) / _S496);
    *probability_3 = _S500;
    return _S498;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_4, float u1_0, float u2_0)
{
    float3  _S501 = center_1 - p_4;
    float _S502 = radius_1 * radius_1 / dot_0(_S501, _S501);
    float _S503 = u1_0 * _S502 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S502), (0.0f)))))));
    float _S504 = 2.0f * u1_0;
    bool _S505 = _S502 >= 1.0f;
    float _S506 = _slang_select(_S505, _S504,_S503);
    float _S507 = (F32_sqrt(((F32_max((_S506 * (2.0f - _S506)), (0.0f))))));
    float _S508 = 6.28318548202514648f * u2_0;
    float3  _S509 = make_float3 (_S507 * (F32_cos((_S508))), 1.0f - _S506, _S507 * (F32_sin((_S508))));
    float3  _S510 = ((((_S501)) * make_float3(rnorm3df(((_S501)).x, ((_S501)).y, ((_S501)).z))));
    float3  _S511 = tangentToWorld(_S509, _S510);
    return _S511;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S512 = center_2 - ray_1->origin;
    float _S513 = dot_0(_S512, ray_1->unit_direction);
    float _S514 = dot_0(_S512, _S512) - _S513 * _S513;
    float _S515 = radius_3 * radius_3;
    bool _S516 = _S514 > _S515;
    if(_S516)
    {
        return 4.294967296e+09f;
    }
    float _S517 = (F32_sqrt((_S515 - _S514)));
    float _S518 = _S513 - _S517;
    float _S519 = _S513 + _S517;
    bool _S520 = _S518 > 0.0000152587890625f;
    bool _S521;
    if(_S520)
    {
        _S521 = _S518 < max_len_0;
    }
    else
    {
        _S521 = false;
    }
    if(_S521)
    {
        return _S518;
    }
    bool _S522 = _S519 > 0.0000152587890625f;
    if(_S522)
    {
        _S521 = _S519 < max_len_0;
    }
    else
    {
        _S521 = false;
    }
    if(_S521)
    {
        return _S519;
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
            float sum_1 = sum_0 + _slang_vector_get_element(left_1, i_9) * _slang_vector_get_element(right_1.rows[i_9], j_1);
            i_9 = i_9 + int(1);
            sum_0 = sum_1;
        }
        *_slang_vector_get_element_ptr(&result_2, j_1) = sum_0;
        j_1 = j_1 + int(1);
    }
    return result_2;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S523 = pcg(init_random_state_1);
    Random _S524 = pcg(_S523.state);
    Random _S525 = pcg(_S524.state);
    float3  _S526 = make_float3 (0.0f);
    TreeSample _S527 = TreeSample_x24init_0(_S526, _S526, 0.0f, _S525.state);
    TreeSample sample_0 = _S527;
    float3  _S528 = _slang_select(sided_0, _S526,smooth_n_2);
    float3  _S529 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S523.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S530 = (fcptLightNode((n_8)));
        if((_S530.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S531 = (fcptLightSecond((n_8)));
        uint _S532 = n_8 + 1U;
        LightNode _S533 = (fcptLightBounds((_S532)));
        LightNode _S534 = (fcptLightBounds((_S531)));
        uint _S535 = pickChild(_S533, _S534, origin_4, _S528, &pick_1, &probability_4);
        bool _S536 = _S535 > 1U;
        if(_S536)
        {
            return sample_0;
        }
        bool _S537 = _S535 == 1U;
        uint _S538 = _slang_select(_S537, _S531,_S532);
        n_8 = _S538;
    }
    bool _S539 = n_8 == 0U;
    bool _S540;
    if(_S539)
    {
        LightNode _S541 = (fcptLightBounds((0U)));
        float _S542 = importance(_S541, origin_4, _S528);
        _S540 = !(_S542 > 0.0f);
    }
    else
    {
        _S540 = false;
    }
    if(_S540)
    {
        return sample_0;
    }
    uint4  _S543 = (fcptLightNode((n_8)));
    FKHit _S544 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S545 = (_S543.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S545)
    {
        FKLight _S546 = (fcptLight((_S543.y)));
        if(sided_0)
        {
            float _S547 = sign_0(dot_0(geometry_n_1, _S546.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S547);
            float3  _S548 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S548;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S529;
            lift_n_0 = smooth_n_2;
        }
        bool _S549 = (_S546.variance) == 0.0f;
        if(_S549)
        {
            float3  _S550 = _S546.position - emitter_point_0;
            float3  _S551 = ((((_S550)) * make_float3(rnorm3df(((_S550)).x, ((_S550)).y, ((_S550)).z))));
            (&sample_0)->dir = _S551;
            float3  _S552 = _S546.color * make_float3 (_S546.intensity) / make_float3 (dot_0(_S550, _S550) * probability_4);
            (&sample_0)->radiance = _S552;
            shadow_1 = _S550;
        }
        else
        {
            float3  _S553 = sampleSphere(_S546.position, _S546.variance, emitter_point_0, _S524.value, _S525.value);
            (&sample_0)->dir = _S553;
            float _S554 = sphereDensity(_S546.position, _S546.variance, emitter_point_0);
            float _S555 = probability_4 * _S554;
            (&sample_0)->density = _S555;
            float3  _S556 = pointLightRadiance(_S546.color, _S546.intensity, _S546.variance);
            float3  _S557 = _S556 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S557;
            FKRay _S558 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S559 = raySphere_0(_S546.position, _S546.variance, &_S558, 4.294967296e+09f);
            float3  _S560 = (&sample_0)->dir * make_float3 (_S559);
            shadow_1 = _S560;
        }
        emitter_0 = _S544;
        emitter_point_0 = _S526;
    }
    else
    {
        uint _S561 = _S543.y;
        uint _S562 = (fcptTriangleOffset((_S561)));
        uint _S563 = _S562 + _S543.z;
        Matrix<float, 3, 3>  _S564 = (fcptWorldTriangle((_S561), (_S563)));
        float _S565 = (F32_sqrt((_S524.value)));
        float2  _S566 = make_float2 (_S565 * (1.0f - _S525.value), _S565 * _S525.value);
        float3  _S567 = mul_0(make_float3 (1.0f - _S565, _S566.x, _S566.y), _S564);
        if(sided_0)
        {
            float _S568 = sign_0(dot_0(geometry_n_1, _S567 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S568);
            float3  _S569 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S569;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S570 = !((dot_0(smooth_n_2, _S567 - origin_4)) > 0.0f);
            if(_S570)
            {
                return sample_0;
            }
            emitter_point_0 = _S529;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S566, _S561, _S563, 0U, 0.0f);
        float3  _S571 = _S567 - emitter_point_0;
        float3  _S572 = ((((_S571)) * make_float3(rnorm3df(((_S571)).x, ((_S571)).y, ((_S571)).z))));
        (&sample_0)->dir = _S572;
        float _S573 = solidAngle(probability_4, cross_0(_S564.rows[int(1)] - _S564.rows[int(0)], _S564.rows[int(2)] - _S564.rows[int(0)]), _S571);
        (&sample_0)->density = _S573;
        bool _S574 = (fcptShadowFirst());
        bool _S575 = !_S574;
        if(_S575)
        {
            FKSurface _S576 = (fcptLightSurfaceAt((emitter_1), (_S567), (_S525.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S567 - origin_4))));
            (&sample_0)->random_state = _S576.random_state;
            float3  _S577 = _slang_select(_S576.skip, _S526,_S576.material.emissive);
            float3  _S578 = _S577 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S578;
        }
        shadow_1 = _S571;
        emitter_0 = emitter_1;
        emitter_point_0 = _S567;
    }
    FKHit _S579 = emitter_0;
    float3  _S580 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S525.state, &_S579);
    bool _S581 = (fcptShadowFirst());
    if(_S581)
    {
        _S540 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S540 = false;
    }
    if(_S540)
    {
        _S540 = !all_0(_S580 == _S526);
    }
    else
    {
        _S540 = false;
    }
    if(_S540)
    {
        FKSurface _S582 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S525.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S582.random_state;
        float3  _S583 = _slang_select(_S582.skip, _S526,_S582.material.emissive);
        float3  _S584 = _S583 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S584;
    }
    float3  _S585 = (&sample_0)->radiance * _S580;
    bool _S586 = all_0(_S580 == _S526);
    float3  _S587 = _slang_select(_S586, _S526,_S585);
    (&sample_0)->radiance = _S587;
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

__device__ float powerHeuristic(float a_6, float b_2)
{
    float _S588 = 1.0f / (1.0f + b_2 / a_6 * (b_2 / a_6));
    bool _S589 = b_2 > 0.0f;
    float _S590 = _slang_select(_S589, _S588,1.0f);
    return _S590;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_0, float3  light_point_1)
{
    bool _S591 = vertex_0->none;
    if(_S591)
    {
        return 1.0f;
    }
    uint _S592 = (fcptLightSlot((*hit_0)));
    float _S593 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S592, light_point_1);
    float _S594 = powerHeuristic(vertex_0->pdf, _S593);
    return _S594;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_0)
{
    uint2  _S595 = (fcptEnvironmentMapSize());
    bool _S596 = (_S595.x) > 1U;
    bool _S597;
    if(_S596)
    {
        uint2  _S598 = (fcptEnvironmentMapSize());
        _S597 = (_S598.y) > 1U;
    }
    else
    {
        _S597 = false;
    }
    if(_S597)
    {
        float3  _S599 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_0)));
        return _S599;
    }
    float3  _S600 = (fcptAmbient());
    return _S600;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S601 = (fcptEnvironmentCdfSize());
    bool _S602 = (_S601.x) > 1U;
    bool _S603;
    if(_S602)
    {
        uint2  _S604 = (fcptEnvironmentCdfSize());
        _S603 = (_S604.y) > 1U;
    }
    else
    {
        _S603 = false;
    }
    bool _S605 = !_S603;
    if(_S605)
    {
        return false;
    }
    uint2  _S606 = (fcptEnvironmentMapSize());
    bool _S607 = (_S606.x) > 1U;
    if(_S607)
    {
        uint2  _S608 = (fcptEnvironmentMapSize());
        _S603 = (_S608.y) > 1U;
    }
    else
    {
        _S603 = false;
    }
    return _S603;
}

static __device__ float escapeWeight_0(float pdf_2, float3  dir_8)
{
    bool _S609 = pdf_2 <= 0.0f;
    bool _S610;
    if(_S609)
    {
        _S610 = true;
    }
    else
    {
        bool _S611 = environmentMapped_0();
        _S610 = !_S611;
    }
    if(_S610)
    {
        return 1.0f;
    }
    float _S612 = environmentPdf_0(dir_8);
    return pdf_2 / (pdf_2 + _S612);
}

static __device__ float3  min_1(float3  x_10, float3  y_3)
{
    float3  result_3;
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
        *_slang_vector_get_element_ptr(&result_3, i_10) = (F32_min((_slang_vector_get_element(x_10, i_10)), (_slang_vector_get_element(y_3, i_10))));
        i_10 = i_10 + int(1);
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
    Shift _S613;
    (&_S613)->f = f_4;
    (&_S613)->jac = jac_0;
    return _S613;
}

static __device__ uint extractBits_0(uint e_1, uint offset_0, uint count_1)
{
    return (e_1 >> offset_0) & ((1U << count_1) - 1U);
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_3, float3  origin_5, float3  smooth_n_3, float3  start_2)
{
    NEEVertex _S614;
    (&_S614)->none = none_0;
    (&_S614)->pdf = pdf_3;
    (&_S614)->origin = origin_5;
    (&_S614)->smooth_n = smooth_n_3;
    (&_S614)->start = start_2;
    return _S614;
}

struct Vertex
{
    bool rough;
    uint lobe;
    float pdf;
    float cos;
    bool inside;
};

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_1, float pdf_4, float cos_0, bool inside_0)
{
    Vertex _S615;
    (&_S615)->rough = rough_0;
    (&_S615)->lobe = lobe_1;
    (&_S615)->pdf = pdf_4;
    (&_S615)->cos = cos_0;
    (&_S615)->inside = inside_0;
    return _S615;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S616 = hash(index_0);
    uint _S617 = hash(seed_0 ^ _S616);
    return _S617;
}

static __device__ float freeFlight_0(float u_1, float sigma_0)
{
    return - (F32_log((1.0f - u_1))) / sigma_0;
}

static __device__ float3  exp_0(float3  x_11)
{
    float3  result_4;
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
        *_slang_vector_get_element_ptr(&result_4, i_11) = (F32_exp((_slang_vector_get_element(x_11, i_11))));
        i_11 = i_11 + int(1);
    }
    return result_4;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_1, float distance_1, bool scatters_0)
{
    float3  _S618 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_1));
    float3  _S619 = scatter_0 * _S618 / make_float3 (sigma_1);
    float3  _S620 = _slang_select(scatters_0, _S619,_S618);
    return _S620;
}

static __device__ bool scatterSampled_0(bool replay_0, uint b_3, uint stop_0, bool varying_0)
{
    bool _S621 = !replay_0;
    bool _S622;
    if(_S621)
    {
        _S622 = true;
    }
    else
    {
        bool _S623 = b_3 == stop_0;
        if(_S623)
        {
            _S622 = !varying_0;
        }
        else
        {
            _S622 = false;
        }
    }
    return _S622;
}

static __device__ uint arrivalLobe_0(uint b_4, uint prev_lobe_0)
{
    bool _S624 = b_4 > 0U;
    uint _S625 = _slang_select(_S624, prev_lobe_0,3U);
    return _S625;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_5, float length_2, float width_0, FKHit * own_0, bool fiber_0)
{
    ShadowContext _S626;
    (&_S626)->extinction_behind = extinction_behind_0;
    (&_S626)->extinction_front = extinction_front_0;
    (&_S626)->fillings = fillings_0;
    (&_S626)->side = side_0;
    (&_S626)->depth = depth_1;
    (&_S626)->lobe = lobe_2;
    (&_S626)->surface = surface_5;
    (&_S626)->length = length_2;
    (&_S626)->width = width_0;
    (&_S626)->own = *own_0;
    (&_S626)->fiber = fiber_0;
    return _S626;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S627 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S627)
    {
        return 0.07957746833562851f;
    }
    float _S628 = g_0 * g_0;
    return (1.0f - _S628) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S628 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_7, float3  b_5)
{
    float3  _S629 = a_7 / b_5;
    float3  _S630 = make_float3 (0.0f);
    bool3  _S631 = b_5 == _S630;
    float3  _S632 = _slang_select(_S631, _S630,_S629);
    return _S632;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S633 = (1U << count_2) - 1U;
    return (e_2 & (~(_S633 << offset_1))) | ((newbits_0 & _S633) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_0, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_0 = r_0;
    uint _S634 = insertBits_0(r_0.path, end_0, 0U, 5U);
    uint _S635 = insertBits_0(_S634, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S635;
    (&candidate_0)->f = f_5;
    return candidate_0;
}

__device__ void offer(Selection * sel_0, Reservoir candidate_1, float3  weight_0)
{
    float _S636 = rgb_to_greyscale(weight_0);
    bool _S637 = _S636 > 0.0f;
    bool _S638;
    if(_S637)
    {
        _S638 = _S636 < 3.00000000549775576e+38f;
    }
    else
    {
        _S638 = false;
    }
    bool _S639 = !_S638;
    if(_S639)
    {
        return;
    }
    bool _S640 = sel_0->sums;
    if(_S640)
    {
        float3  _S641 = sel_0->color + weight_0;
        sel_0->color = _S641;
        return;
    }
    float _S642 = sel_0->w_sum + _S636;
    sel_0->w_sum = _S642;
    float3  _S643 = sel_0->color + weight_0;
    sel_0->color = _S643;
    Random _S644 = pcg(sel_0->random_state);
    sel_0->random_state = _S644.state;
    bool _S645 = (_S644.value * sel_0->w_sum) <= _S636;
    if(_S645)
    {
        sel_0->r = candidate_1;
    }
    return;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S646 = pcg(random_state_9);
    Random _S647 = pcg(_S646.state);
    float _S648 = 1.0f - 2.0f * _S646.value;
    float _S649 = (F32_sqrt(((F32_max((1.0f - _S648 * _S648), (0.0f))))));
    float _S650 = 6.28318548202514648f * _S647.value;
    return make_float3 (_S649 * (F32_cos((_S650))), _S649 * (F32_sin((_S650))), _S648);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_10, float * pdf_5)
{
    bool _S651 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S651)
    {
        *pdf_5 = 0.07957746833562851f;
        float3  _S652 = isotropic_0(random_state_10);
        return _S652;
    }
    Random _S653 = pcg(random_state_10);
    Random _S654 = pcg(_S653.state);
    float _S655 = g_1 * g_1;
    float _S656 = 2.0f * g_1;
    float _S657 = (1.0f - _S655) / (1.0f - g_1 + _S656 * _S653.value);
    float _S658 = clamp_0((1.0f + _S655 - _S657 * _S657) / _S656, -1.0f, 1.0f);
    float _S659 = (F32_sqrt(((F32_max((1.0f - _S658 * _S658), (0.0f))))));
    float _S660 = 6.28318548202514648f * _S654.value;
    float _S661 = phaseHG_0(g_1, _S658);
    *pdf_5 = _S661;
    float3  _S662 = tangentToWorld(make_float3 (_S659 * (F32_cos((_S660))), _S658, _S659 * (F32_sin((_S660)))), dir_9);
    float3  _S663 = ((((_S662)) * make_float3(rnorm3df(((_S662)).x, ((_S662)).y, ((_S662)).z))));
    return _S663;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_5)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_2)
{
    BSDFMaterial _S664;
    (&_S664)->albedo = albedo_0;
    (&_S664)->emissive = emissive_0;
    (&_S664)->roughness = roughness_0;
    (&_S664)->metallic = metallic_0;
    (&_S664)->transmission = transmission_0;
    (&_S664)->ior = ior_0;
    (&_S664)->absorption = absorption_0;
    (&_S664)->specular_tint = specular_tint_0;
    (&_S664)->specular_level = specular_level_0;
    (&_S664)->translucent = translucent_0;
    (&_S664)->sheen = sheen_2;
    (&_S664)->sheen_roughness = sheen_roughness_0;
    (&_S664)->anisotropy = anisotropy_0;
    (&_S664)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S664)->tangent = tangent_2;
    (&_S664)->velvet = velvet_0;
    (&_S664)->toon = toon_2;
    return _S664;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S665;
    (&_S665)->scatter = scatter_1;
    (&_S665)->extinction = extinction_1;
    (&_S665)->g = g_2;
    return _S665;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_10, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S666;
    (&_S666)->smooth_n = smooth_n_4;
    (&_S666)->geometry_n = geometry_n_2;
    (&_S666)->geometry_offset = geometry_offset_2;
    (&_S666)->material = *material_10;
    (&_S666)->skip = skip_0;
    (&_S666)->random_state = random_state_11;
    (&_S666)->coverage = coverage_0;
    (&_S666)->encloses = encloses_0;
    (&_S666)->volume = *volume_0;
    (&_S666)->fills = fills_0;
    (&_S666)->hair = hair_0;
    return _S666;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S667 = (&surface_6->material)->emissive;
    float3  _S668 = make_float3 (0.0f);
    bool _S669 = !top_0;
    float3  _S670 = _slang_select(_S669, _S668,_S667);
    (&(&lower_0)->material)->emissive = _S670;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_2)
{
    float _S671 = surface_7->coverage;
    bool _S672 = u_2 < _S671;
    if(_S672)
    {
        return *surface_7;
    }
    float3  _S673 = make_float3 (0.0f);
    float3  _S674 = make_float3 (1.0f);
    BSDFMaterial _S675 = Material_x24init_0(_S673, _S673, 0.0f, 0.0f, 0.0f, 0.0f, _S673, _S674, 1.0f, _S673, _S673, 0.5f, 0.0f, 0.0f, _S673, 0.0f, _S673);
    BSDFMaterial material_11 = _S675;
    (&material_11)->albedo = _S674;
    (&material_11)->emissive = (&surface_7->material)->emissive;
    (&material_11)->transmission = 1.0f;
    (&material_11)->ior = 1.0f;
    (&material_11)->absorption = (&surface_7->material)->absorption;
    FKSurface through_0 = *surface_7;
    (&through_0)->material = material_11;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S676 = transmission_1 > 0.0f;
    bool _S677;
    if(_S676)
    {
        _S677 = true;
    }
    else
    {
        _S677 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S678;
    if(_S677)
    {
        _S678 = 1.0f;
    }
    else
    {
        _S678 = -1.0f;
    }
    return _S678;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_9)
{
    return (dot_0(dir_10, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_11)
{
    float3  _S679 = surface_8->geometry_n;
    float _S680 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_11);
    FKSurface faced_0 = *surface_8;
    float3  _S681 = surface_8->smooth_n * make_float3 (_S680);
    (&faced_0)->smooth_n = _S681;
    float3  _S682 = _S679 * make_float3 (_S680);
    (&faced_0)->geometry_n = _S682;
    return faced_0;
}

static __device__ float3  max_0(float3  x_12, float3  y_4)
{
    float3  result_5;
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
        *_slang_vector_get_element_ptr(&result_5, i_12) = (F32_max((_slang_vector_get_element(x_12, i_12)), (_slang_vector_get_element(y_4, i_12))));
        i_12 = i_12 + int(1);
    }
    return result_5;
}

static __device__ float3  log_0(float3  x_13)
{
    float3  result_6;
    int i_13 = int(0);
    for(;;)
    {
        if(i_13 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_6, i_13) = (F32_log((_slang_vector_get_element(x_13, i_13))));
        i_13 = i_13 + int(1);
    }
    return result_6;
}

__device__ float3  beerLambert(float distance_2, float3  absorption_1)
{
    float3  _S683 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_2) * log_0(_S683));
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
    bool _S684;
    if(open_0)
    {
        _S684 = prev_rough_0;
    }
    else
    {
        _S684 = false;
    }
    if(_S684)
    {
        _S684 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S684 = false;
    }
    return _S684;
}

__device__ float2  vertexEta(BSDFMaterial material_12, float n_dot_v_0)
{
    bool _S685 = n_dot_v_0 < 0.0f;
    float _S686 = _slang_select(_S685, material_12.ior,1.0f);
    float _S687 = _slang_select(_S685, 1.0f,material_12.ior);
    return make_float2 (_S686, _S687);
}

__device__ bool neeDecision(BSDFMaterial material_13, float n_dot_v_1, float eta_i_9, float eta_o_9)
{
    float _S688 = fresnel((F32_abs((n_dot_v_1))), eta_i_9, eta_o_9);
    float3  _S689 = mix_0(make_float3 (_S688), material_13.albedo, material_13.metallic);
    float _S690 = rgb_to_greyscale(_S689);
    float _S691 = (F32_max(((1.0f - _S690) * (1.0f - material_13.metallic) * (1.0f - material_13.transmission)), (0.0f)));
    bool _S692 = _S691 > 0.03999999910593033f;
    bool _S693;
    if(_S692)
    {
        _S693 = true;
    }
    else
    {
        _S693 = (material_13.roughness) > 0.20000000298023224f;
    }
    return _S693;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_14)
{
    float _S694 = rgb_to_greyscale(material_14->translucent);
    return _S694 > 0.0f;
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
    MediumSides _S695;
    (&_S695)->behind = *behind_0;
    (&_S695)->front = *front_0;
    (&_S695)->fillings = fillings_1;
    (&_S695)->face = face_1;
    return _S695;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S696 = surface_9->geometry_n;
    MediumSides _S697 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S697;
    bool _S698 = surface_9->encloses;
    if(_S698)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S699 = (dot_0(dir_12, _S696)) > 0.0f;
        if(_S699)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_3, float length_3, float width_1, FKHit * own_1, bool fiber_1, FKMedium * outside_1)
{
    float3  _S700 = surface_10->geometry_n;
    ShadowContext _S701 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
    bool _S702 = surface_10->encloses;
    ShadowContext context_4;
    if(_S702)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S703 = - _S700;
        float3  _S704 = _slang_select(turned_0, _S703,_S700);
        (&faced_1)->geometry_n = _S704;
        FKMedium _S705 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S706 = faced_1;
        FKMedium _S707 = _S705;
        MediumSides _S708 = mediumSides_0(&_S706, &_S707, filling_1, dir_13, outside_1);
        ShadowContext _S709 = ShadowContext_x24init_0(_S708.behind.extinction, _S708.front.extinction, _S708.fillings, _S700, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
        if(turned_0)
        {
            uint2  _S710 = _S708.fillings;
            ShadowContext _S711 = ShadowContext_x24init_0(_S708.front.extinction, _S708.behind.extinction, uint2 {_S710.y, _S710.x}, _S700, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
            context_4 = _S711;
        }
        else
        {
            context_4 = _S709;
        }
    }
    else
    {
        context_4 = _S701;
    }
    return context_4;
}

static __device__ bool any_0(bool3  x_14)
{
    bool result_7 = false;
    int i_14 = int(0);
    for(;;)
    {
        if(i_14 < int(3))
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
            result_7 = (bool((_slang_vector_get_element(x_14, i_14))));
        }
        i_14 = i_14 + int(1);
    }
    return result_7;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_15, float eta_i_10, float eta_o_10, bool competing_1, uint random_state_12)
{
    float3  _S712 = light_2->dir;
    bool _S713 = (dot_0(geometry_n_4, - in_dir_8) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_3;
    float3  _S714 = BSDF(in_dir_8, _S712, smooth_n_5, *material_15, eta_i_10, eta_o_10, _S713, random_state_12, &throughputs_1, &pdfs_3);
    bool _S715 = !competing_1;
    bool _S716;
    if(_S715)
    {
        _S716 = true;
    }
    else
    {
        _S716 = (light_2->density) == 0.0f;
    }
    if(_S716)
    {
        return _S714 * light_2->radiance;
    }
    float3  _S717 = make_float3 (0.0f);
    uint i_15 = 0U;
    float3  weighted_0 = _S717;
    for(;;)
    {
        if(i_15 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S718 = (pdfs_3[i_15]) > 0.0f;
        if(_S718)
        {
            float _S719 = light_2->density;
            float _S720 = pdfs_3[i_15] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_15] * make_float3 (pdfs_3[i_15]) / make_float3 (_S719 * (1.0f + _S720 * _S720));
            weighted_0 = weighted_1;
        }
        uint i_16 = i_15 + 1U;
        i_15 = i_16;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_13, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S721;
    (&_S721)->unit_direction = unit_direction_1;
    (&_S721)->throughput = throughput_1;
    (&_S721)->random_state = random_state_13;
    (&_S721)->refracted = refracted_3;
    (&_S721)->lobe = lobe_4;
    (&_S721)->pdf = pdf_6;
    return _S721;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_8, float n_i_dot_v_6, float alpha_15, BSDFMaterial material_16, BSDFLobes lobes_11, float eta_i_11, float eta_o_11, uint random_state_14)
{
    float3  _S722 = make_float3 (1.0f);
    SampleBSDF _S723 = SampleBSDF_x24init_0(_S722, _S722, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S723;
    Random _S724 = pcg(random_state_14);
    Random _S725 = pcg(_S724.state);
    (&sample_1)->random_state = _S725.state;
    float _S726 = _S724.value;
    float _S727 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S726 * _S726))))));
    float _S728 = 6.28318548202514648f * _S725.value;
    float3  _S729 = tangentToWorld(make_float3 (_S727 * (F32_cos((_S728))), _S724.value, _S727 * (F32_sin((_S728)))), n_i_8);
    (&sample_1)->unit_direction = _S729;
    (&sample_1)->lobe = 4U;
    float3  _S730 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_8, alpha_15, material_16, lobes_11);
    (&sample_1)->throughput = _S730;
    float _S731 = sheenVelvetPDF(_S724.value, 0.0f, n_i_dot_v_6, alpha_15, lobes_11, eta_i_11, eta_o_11);
    (&sample_1)->pdf = _S731;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S732 = (F32_sqrt((random_1_0)));
    float _S733 = 6.28318548202514648f * random_2_0;
    float _S734 = _S732 * (F32_cos((_S733)));
    float _S735 = _S732 * (F32_sin((_S733)));
    float _S736 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S734 * _S734 - _S735 * _S735))))));
    return make_float3 (_S734, _S736, _S735);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_9, float n_i_dot_v_7, float alpha_16, BSDFMaterial material_17, BSDFLobes lobes_12, float eta_i_12, float eta_o_12, uint random_state_15)
{
    float3  _S737 = make_float3 (1.0f);
    SampleBSDF _S738 = SampleBSDF_x24init_0(_S737, _S737, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S738;
    Random _S739 = pcg(random_state_15);
    Random _S740 = pcg(_S739.state);
    (&sample_2)->random_state = _S740.state;
    float3  _S741 = sampleCosWeightedHemisphere(_S739.value, _S740.value);
    bool _S742 = u_3 < (lobes_12.p_diffuse * lobes_12.translucent_share);
    float _S743 = _S741.y;
    float _S744 = - _S743;
    float _S745 = _slang_select(_S742, _S744,_S743);
    float3  _S746 = tangentToWorld(make_float3 (_S741.x, _S745, _S741.z), n_i_9);
    (&sample_2)->unit_direction = _S746;
    (&sample_2)->refracted = _S742;
    (&sample_2)->lobe = 0U;
    float3  _S747 = diffuseBSDF((&sample_2)->unit_direction, n_i_9, alpha_16, material_17, lobes_12);
    (&sample_2)->throughput = _S747;
    float _S748 = diffusePDF(_S745, 0.0f, n_i_dot_v_7, alpha_16, lobes_12, eta_i_12, eta_o_12);
    (&sample_2)->pdf = _S748;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_10, float n_i_dot_v_8, float alpha_17, BSDFMaterial material_18, BSDFLobes lobes_13, float eta_i_13, float eta_o_13, uint random_state_16)
{
    float3  _S749 = make_float3 (1.0f);
    SampleBSDF _S750 = SampleBSDF_x24init_0(_S749, _S749, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S750;
    Random _S751 = pcg(random_state_16);
    Random _S752 = pcg(_S751.state);
    (&sample_3)->random_state = _S752.state;
    float _S753 = _S751.value * lobes_13.toon_norm / 6.28318548202514648f;
    float t_1;
    if(lobes_13.toon_glossy)
    {
        t_1 = (F32_acos((clamp_0(1.0f - _S753, -1.0f, 1.0f))));
    }
    else
    {
        t_1 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S753)))), (1.0f))))));
    }
    if(t_1 < (lobes_13.toon_a))
    {
    }
    else
    {
        t_1 = (lobes_13.toon_a + lobes_13.toon_b) / 2.0f;
    }
    int k_0 = int(0);
    for(;;)
    {
        if(k_0 < int(8))
        {
        }
        else
        {
            break;
        }
        float _S754;
        if(t_1 < (lobes_13.toon_a))
        {
            _S754 = 1.0f;
        }
        else
        {
            _S754 = (F32_max((1.0f - (t_1 - lobes_13.toon_a) / (F32_max((lobes_13.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float integral_1;
        if(lobes_13.toon_glossy)
        {
            integral_1 = 1.0f - (F32_cos(((F32_min((t_1), (lobes_13.toon_a))))));
        }
        else
        {
            float _S755 = (F32_sin(((F32_min((t_1), (lobes_13.toon_a))))));
            integral_1 = _S755 * _S755 / 2.0f;
        }
        bool _S756 = t_1 > (lobes_13.toon_a);
        bool _S757;
        if(_S756)
        {
            _S757 = (lobes_13.toon_s) > 0.0f;
        }
        else
        {
            _S757 = false;
        }
        float integral_2;
        if(_S757)
        {
            if(lobes_13.toon_glossy)
            {
                float _S758 = (F32_cos((lobes_13.toon_a)));
                float _S759 = (F32_cos((t_1)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S758 - _S759) - ((F32_sin((t_1))) - t_1 * _S759 - ((F32_sin((lobes_13.toon_a))) - lobes_13.toon_a * _S758)) / lobes_13.toon_s;
            }
            else
            {
                float _S760 = 2.0f * lobes_13.toon_a;
                float _S761 = (F32_cos((_S760)));
                float _S762 = 2.0f * t_1;
                float _S763 = (F32_cos((_S762)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S761 - _S763) / 4.0f - ((F32_sin((_S762))) / 8.0f - t_1 * _S763 / 4.0f - ((F32_sin((_S760))) / 8.0f - lobes_13.toon_a * _S761 / 4.0f)) / lobes_13.toon_s;
            }
            float integral_3 = integral_1 + integral_2;
            integral_2 = integral_3;
        }
        else
        {
            integral_2 = integral_1;
        }
        float _S764 = _S754 * (F32_sin((t_1)));
        float _S765;
        if(lobes_13.toon_glossy)
        {
            _S765 = 1.0f;
        }
        else
        {
            _S765 = (F32_cos((t_1)));
        }
        float _S766 = _S764 * _S765;
        float _S767 = (integral_2 - _S753) / _S766;
        bool _S768 = _S766 > 0.0f;
        float _S769 = _slang_select(_S768, _S767,0.0f);
        float _S770 = clamp_0(t_1 - _S769, 0.0f, lobes_13.toon_b);
        int k_1 = k_0 + int(1);
        t_1 = _S770;
        k_0 = k_1;
    }
    float _S771 = 6.28318548202514648f * _S752.value;
    float _S772 = (F32_sin((t_1)));
    float3  _S773 = tangentToWorld(make_float3 (_S772 * (F32_cos((_S771))), (F32_cos((t_1))), _S772 * (F32_sin((_S771)))), lobes_13.toon_axis);
    (&sample_3)->unit_direction = _S773;
    bool _S774 = (dot_0(n_i_10, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S774;
    (&sample_3)->lobe = 6U;
    float3  _S775 = toonBSDF((&sample_3)->unit_direction, n_i_10, alpha_17, material_18, lobes_13);
    (&sample_3)->throughput = _S775;
    float _S776 = toonPDF(dot_0(n_i_10, (&sample_3)->unit_direction), dot_0((&sample_3)->unit_direction, lobes_13.toon_axis), n_i_dot_v_8, alpha_17, lobes_13, eta_i_13, eta_o_13);
    (&sample_3)->pdf = _S776;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_11, float n_i_dot_v_9, float alpha_18, BSDFMaterial material_19, BSDFLobes lobes_14, float eta_i_14, float eta_o_14, uint random_state_17)
{
    float3  _S777 = make_float3 (1.0f);
    SampleBSDF _S778 = SampleBSDF_x24init_0(_S777, _S777, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S778;
    (&sample_4)->unit_direction = lobes_14.refracted;
    (&sample_4)->random_state = random_state_17;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S779 = refractBSDF((&sample_4)->unit_direction, n_i_11, alpha_18, material_19, lobes_14);
    (&sample_4)->throughput = _S779;
    float _S780 = refractPDF(0.0f, dot_0((&sample_4)->unit_direction, ggx_n_3), n_i_dot_v_9, alpha_18, lobes_14, eta_i_14, eta_o_14);
    (&sample_4)->pdf = _S780;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_17, float3  n_10)
{
    return i_17 - make_float3 (2.0f * dot_0(n_10, i_17)) * n_10;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_12, float n_i_dot_v_10, float alpha_19, BSDFMaterial material_20, BSDFLobes lobes_15, float eta_i_15, float eta_o_15, uint random_state_18)
{
    float3  _S781 = make_float3 (1.0f);
    SampleBSDF _S782 = SampleBSDF_x24init_0(_S781, _S781, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S782;
    float3  _S783 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S784 = ((((_S783)) * make_float3(rnorm3df(((_S783)).x, ((_S783)).y, ((_S783)).z))));
    (&sample_5)->unit_direction = _S784;
    (&sample_5)->random_state = random_state_18;
    (&sample_5)->lobe = 2U;
    float3  _S785 = reflectBSDF((&sample_5)->unit_direction, n_i_12, alpha_19, material_20, lobes_15);
    (&sample_5)->throughput = _S785;
    float _S786 = reflectPDF(0.0f, 0.0f, n_i_dot_v_10, alpha_19, lobes_15, eta_i_15, eta_o_15);
    (&sample_5)->pdf = _S786;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_11, BSDFMaterial material_21, float eta_i_16, float eta_o_16, uint random_init_0, float2  screen_space_0)
{
    uint random_state_19 = random_init_0;
    float3  _S787 = negate_0(in_dir_10);
    float _S788 = dot_0(n_11, _S787);
    float _S789 = sign_0(_S788);
    float3  n_i_13 = n_11 * make_float3 (_S789);
    float _S790 = (F32_abs((_S788)));
    float _S791 = material_21.roughness;
    float _S792 = _S791 * _S791;
    AnisotropicFrame _S793 = anisotropicFrame(material_21, n_i_13);
    float3  _S794 = sampleHalfVector(_S787, n_i_13, _S792, _S793, &random_state_19);
    BSDFLobes _S795 = bsdfLobes(in_dir_10, _S787, n_i_13, _S794, material_21, eta_i_16, eta_o_16, _S793);
    BSDFLobes lobes_16 = _S795;
    float _S796 = translucentShare(material_21);
    (&lobes_16)->translucent_share = _S796;
    Random _S797 = pcg(random_state_19);
    random_state_19 = _S797.state;
    bool _S798 = (_S797.value) < ((&lobes_16)->p_sheen_velvet);
    if(_S798)
    {
        SampleBSDF _S799 = sheenVelvetSample(n_i_13, _S790, _S792, material_21, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S799;
    }
    float _S800 = _S797.value - (&lobes_16)->p_sheen_velvet;
    bool _S801 = _S800 < ((&lobes_16)->p_diffuse);
    if(_S801)
    {
        SampleBSDF _S802 = diffuseSample(_S800, n_i_13, _S790, _S792, material_21, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S802;
    }
    bool _S803 = _S800 < ((&lobes_16)->p_diffuse + (&lobes_16)->p_toon);
    if(_S803)
    {
        SampleBSDF _S804 = toonSample(n_i_13, _S790, _S792, material_21, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S804;
    }
    float _S805 = (&lobes_16)->p_toon;
    bool _S806 = (_S800 - _S805) < ((&lobes_16)->p_diffuse + (&lobes_16)->p_refract);
    if(_S806)
    {
        SampleBSDF _S807 = refractSample(_S794, n_i_13, _S790, _S792, material_21, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S807;
    }
    SampleBSDF _S808 = reflectSample(in_dir_10, _S794, n_i_13, _S790, _S792, material_21, lobes_16, eta_i_16, eta_o_16, random_state_19);
    return _S808;
}

__device__ bool withinInverseFootprint(float pdf_7, bool diffuse_0, float prev_cos_0, float distance_4, float threshold_1)
{
    bool _S809 = pdf_7 > 0.0f;
    bool _S810;
    if(_S809)
    {
        if(diffuse_0)
        {
            _S810 = true;
        }
        else
        {
            _S810 = (pdf_7 * prev_cos_0 / (distance_4 * distance_4) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S810 = false;
    }
    return _S810;
}

__device__ bool roughLobe(float pdf_8, bool diffuse_1, float roughness_1)
{
    bool _S811 = pdf_8 > 0.0f;
    bool _S812;
    if(_S811)
    {
        if(diffuse_1)
        {
            _S812 = true;
        }
        else
        {
            _S812 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S812 = false;
    }
    return _S812;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S813 = layers_0 > 1U;
    bool _S814;
    if(_S813)
    {
        _S814 = refracting_0 != passed_0;
    }
    else
    {
        _S814 = false;
    }
    return _S814;
}

static __device__ float widened_0(float spread_0, float pdf_9, bool delta_0)
{
    float _S815 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_9))))), (3.14159274101257324f)));
    bool _S816 = !delta_0;
    float _S817 = _slang_select(_S816, _S815,0.0f);
    return spread_0 + _S817;
}

static __device__ bool boundsVolume_0(FKSurface * surface_11)
{
    return surface_11->encloses;
}

static __device__ bool leavesInFront_0(float3  face_2, float3  dir_14, float3  g_3)
{
    return ((dot_0(dir_14, g_3)) > 0.0f) == ((dot_0(g_3, face_2)) > 0.0f);
}

static __device__ float distance_5(float3  x_15, float3  y_5)
{
    return length_0(x_15 - y_5);
}

static __device__ Shift walk_0(Domain * dom_0, Reservoir * r_1, bool replay_1, float scale_2, Selection * sel_1)
{
    float spread_1;
    bool turned_1;
    bool is_inside_6;
    bool viewed_0;
    bool _S818;
    float density_2;
    float threshold_2;
    float width_2;
    float sky_pdf_0;
    float geometry_density_2;
    uint b_6;
    uint layer_0;
    float3  throughput_2;
    float3  chain_throughput_0;
    TreeSample light_3;
    int _S819;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_3;
    float sky_pdf_1;
    float spread_3;
    float width_4;
    uint b_7;
    float3  _S820 = make_float3 (0.0f);
    Shift _S821 = Shift_x24init_0(_S820, 0.0f);
    uint _S822 = r_1->path;
    uint _S823 = extractBits_0(r_1->path, 0U, 5U);
    uint _S824 = extractBits_0(_S822, 5U, 5U);
    uint _S825 = extractBits_0(_S822, 10U, 2U);
    uint _S826 = extractBits_0(_S822, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S827 = _S826 >= 3U;
        uint _S828 = _slang_select(_S827, 1U,0U);
        uint _S829 = _S823 + _S828;
        uint _S830 = (fcptMaxBounces());
        passes_0 = _S829 > _S830;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S821;
    }
    uint _S831 = _S824 - 1U;
    bool _S832 = _S826 == 3U;
    uint _S833 = _slang_select(_S832, 1U,0U);
    uint _S834 = _S823 + _S833;
    bool _S835 = _S825 == 0U;
    uint _S836 = _slang_select(_S835, _S834,_S831);
    FKHit _S837 = (fcptReservoirHit((*r_1)));
    float3  _S838 = dom_0->x0;
    float3  _S839 = dom_0->x1 - dom_0->x0;
    float3  _S840 = ((((_S839)) * make_float3(rnorm3df(((_S839)).x, ((_S839)).y, ((_S839)).z))));
    FKRay _S841 = Ray_x24init_0(dom_0->x1, _S840);
    FKRay ray_2 = _S841;
    FKHit hit_1 = dom_0->hit;
    float3  scatter_in_0 = _S820;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S820;
    float3  extinction_in_0 = _S820;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S842 = dom_0->spread;
    float _S843 = dom_0->width;
    float _S844 = length_0(_S839);
    NEEVertex _S845 = NEEVertex_x24init_0(true, 0.0f, _S820, _S820, _S820);
    NEEVertex nee_vertex_0 = _S845;
    Vertex _S846 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S846;
    Reservoir _S847 = (Reservoir{});
    Reservoir chain_0 = _S847;
    uint _S848 = r_1->seed;
    (&chain_0)->seed = r_1->seed;
    (&ray_2)->origin = _S838;
    (&hit_1)->distance = _S844;
    FKMedium _S849 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_1)->distance), (&filling_2)));
    uint _S850 = filling_2;
    bool _S851 = (fcptVaryingUsed());
    uint _S852 = _slang_select(_S851, _S850,4294967295U);
    filling_2 = _S852;
    scatter_in_0 = _S849.scatter;
    extinction_in_0 = _S849.extinction;
    g_in_0 = _S849.g;
    Reservoir _S853 = chain_0;
    uint _S854 = filling_2;
    for(;;)
    {
        bool _S855 = (fcptVaryingUsed());
        if(_S855)
        {
            passes_0 = _S854 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S856 = (fcptMajorant((_S854)));
            spread_1 = _S856;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S836;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S825 == 1U;
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
            ended_0 = _S821;
            sky_pdf_0 = 0.0f;
            spread_1 = _S842;
            width_2 = _S843;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_6 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S857 = (&prev_0)->rough;
        if(_S857)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S858 = stream(_S848, 384U);
        uint tracking_0 = _S858;
        weight_1 = throughput_3;
        glowed_0 = _S820;
        b_6 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_2 = _S842;
        width_2 = _S843;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_1)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S819 = int(1);
                break;
            }
            uint _S859 = b_6 + 320U;
            bool _S860 = b_6 == 4294967295U;
            uint _S861 = _slang_select(_S860, 384U,_S859);
            uint _S862 = stream(_S848, _S861);
            Random _S863 = pcg(_S862);
            float _S864 = freeFlight_0(_S863.value, spread_1);
            if(passes_0)
            {
                float3  _S865 = (&ray_2)->origin;
                float3  _S866 = (&ray_2)->unit_direction;
                float _S867 = (&hit_1)->distance;
                uint _S868 = _slang_select(_S860, 0U,b_6);
                uint _S869 = (&prev_0)->lobe;
                uint _S870 = _slang_select(_S860, 3U,_S869);
                float _S871 = (fcptTrackMedium((_S854), (_S865), (_S866), (_S867), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S868), (_S870), (_S860)));
                geometry_density_2 = _S871;
            }
            else
            {
                geometry_density_2 = _S864;
            }
            bool _S872 = !(geometry_density_2 < ((&hit_1)->distance));
            if(_S872)
            {
                _S819 = int(1);
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
                float3  _S873 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S874 = sel_1->glow + _S873;
                sel_1->glow = _S874;
            }
            else
            {
            }
            glowed_0 = _S820;
            uint b_8 = b_6 + 1U;
            float3  _S875 = (&ray_2)->origin + make_float3 (geometry_density_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S875;
            float3  _S876 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, geometry_density_2, true);
            float3  _S877 = weight_1;
            float3  _S878 = _slang_select(passes_0, _S877,_S876);
            float3  throughput_4 = throughput_2 * _S878;
            uint _S879 = stream(_S848, b_8 + 320U);
            tracking_0 = _S879;
            weight_1 = throughput_3;
            float width_5 = width_2 + threshold_2 * geometry_density_2;
            float _S880 = threshold_2 + 3.14159274101257324f;
            bool _S881 = scatterSampled_0(replay_1, b_8, _S836, passes_0);
            TreeSample _S882 = TreeSample_x24init_0(_S820, _S820, 0.0f, 0U);
            if(_S881)
            {
                float3  _S883 = (&ray_2)->origin;
                float3  _S884 = (&ray_2)->unit_direction;
                float3  _S885 = (&ray_2)->unit_direction;
                uint _S886 = stream(_S848, b_8 + 64U);
                float3  _S887 = extinction_in_0;
                float3  _S888 = extinction_in_0;
                uint2  _S889 = make_uint2 (_S854);
                float3  _S890 = (&ray_2)->unit_direction;
                uint _S891 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                FKHit _S892 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S893 = _S892;
                ShadowContext _S894 = ShadowContext_x24init_0(_S887, _S888, _S889, _S890, b_8, _S891, false, geometry_density_2, width_5, &_S893, false);
                ShadowContext _S895 = _S894;
                TreeSample _S896 = sampleLightTree_0(_S883, _S884, _S885, 0.0f, true, _S886, &_S895);
                light_3 = _S896;
            }
            else
            {
                light_3 = _S882;
            }
            float _S897 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S898 = (fcptMaxBounces());
            bool _S899 = b_8 < _S898;
            if(_S899)
            {
                is_inside_6 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_6 = false;
            }
            float _S900 = _slang_select(is_inside_6, _S897,0.0f);
            float3  _S901 = throughput_4 * light_3.radiance;
            float _S902 = powerHeuristic(light_3.density, _S900);
            float3  _S903 = _S901 * make_float3 (_S897 * _S902);
            float3  _S904 = _slang_select(_S881, _S903,_S820);
            if(replay_1)
            {
                viewed_0 = b_8 == _S836;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S905 = _S825 == 2U;
                if(_S905)
                {
                    float _S906 = rgb_to_greyscale(_S904);
                    passes_0 = _S906 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S907 = Shift_x24init_0(_S904, 1.0f);
                    _S819 = int(0);
                    ended_0 = _S907;
                    spread_1 = _S880;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_8;
                    break;
                }
                _S819 = int(0);
                ended_0 = _S821;
                spread_1 = _S880;
                geometry_density_2 = width_5;
                chain_throughput_0 = throughput_4;
                layer_0 = b_8;
                break;
            }
            bool _S908 = !replay_1;
            if(_S908)
            {
                Reservoir candidate_2 = _S853;
                uint _S909 = extractBits_0(_S853.path, 10U, 2U);
                bool _S910 = _S909 == 1U;
                if(_S910)
                {
                    float3  _S911 = safeDivide(_S904, _S820);
                    (&candidate_2)->radiance = _S911;
                }
                else
                {
                    uint _S912 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                    uint _S913 = insertBits_0(_S912, 2U, 10U, 2U);
                    (&candidate_2)->path = _S913;
                }
                Reservoir _S914 = withEnd(candidate_2, 0U, b_8, _S904);
                offer(sel_1, _S914, _S904 * make_float3 (scale_2) / make_float3 (density_2));
                float _S915 = survivalProbability(throughput_4, density_2);
                uint _S916 = stream(_S848, b_8 + 128U);
                Random _S917 = pcg(_S916);
                bool _S918 = _S915 < (_S917.value);
                if(_S918)
                {
                    _S818 = true;
                }
                else
                {
                    uint _S919 = (fcptMaxBounces());
                    _S818 = b_8 >= _S919;
                }
                if(_S818)
                {
                    _S819 = int(0);
                    ended_0 = _S821;
                    spread_1 = _S880;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_8;
                    break;
                }
                float _S920 = density_2 * _S915;
                density_2 = _S920;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S921 = stream(_S848, b_8);
            float3  _S922 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S921, &phase_pdf_0);
            (&ray_2)->unit_direction = _S922;
            NEEVertex _S923 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S820, (&ray_2)->origin);
            nee_vertex_0 = _S923;
            Vertex _S924 = scatteredVertex_0(false);
            prev_0 = _S924;
            float _S925 = (&prev_0)->pdf;
            FKRay _S926 = ray_2;
            FKHit _S927 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S928 = (fcptTraverseInstanceBVH((_S926), (true), (4.294967296e+09f), (false), (_S927), (false)));
            hit_1 = _S928;
            b_6 = b_8;
            throughput_2 = throughput_4;
            threshold_2 = _S880;
            width_2 = width_5;
            sky_pdf_0 = _S925;
        }
        if(_S819 != int(1))
        {
            width_2 = geometry_density_2;
            throughput_2 = chain_throughput_0;
            b_6 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S821;
        spread_1 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S929 = b_6 == 4294967295U;
    bool _S930 = ((&hit_1)->instance_index) == 4294967295U;
    if(_S930)
    {
        bool _S931 = !(&nee_vertex_0)->none;
        float _S932 = _slang_select(_S931, sky_pdf_0,0.0f);
        float _S933 = escapeWeight_0(_S932, (&ray_2)->unit_direction);
        float3  _S934 = environment_0((&ray_2)->unit_direction, b_6, (&prev_0)->lobe);
        float3  _S935 = throughput_2 * _S934;
        if(replay_1)
        {
            bool _S936 = b_6 == _S836;
            if(_S936)
            {
                passes_0 = _S825 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S935 * make_float3 (_S933) / make_float3 (r_1->jac), density_2 / r_1->jac);
            }
            if(_S835)
            {
                passes_0 = _S832;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_6 == _S823;
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
                return Shift_x24init_0(_S935 * make_float3 (_S933), 1.0f);
            }
            return _S821;
        }
        Reservoir candidate_3 = chain_0;
        uint _S937 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S938 = _S937 == 1U;
        if(_S938)
        {
            uint _S939 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S940 = _S939 == b_6;
            float _S941 = _slang_select(_S940, 1.0f,_S933);
            float3  _S942 = safeDivide(_S935 * make_float3 (_S941), _S820);
            (&candidate_3)->radiance = _S942;
        }
        else
        {
            bool _S943 = (&prev_0)->rough;
            if(_S943)
            {
                uint _S944 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                uint _S945 = insertBits_0(_S944, 3U, 10U, 2U);
                uint _S946 = insertBits_0(_S945, (&prev_0)->lobe, 15U, 3U);
                bool _S947 = (&prev_0)->inside;
                uint _S948 = _slang_select(_S947, 1U,0U);
                uint _S949 = insertBits_0(_S946, _S948, 22U, 1U);
                (&candidate_3)->path = _S949;
                (&candidate_3)->jac = (&prev_0)->pdf;
                (&candidate_3)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S950 = _S935 * make_float3 (_S933);
        Reservoir _S951 = withEnd(candidate_3, 3U, b_6, _S950);
        offer(sel_1, _S951, _S950 * make_float3 (scale_2) / make_float3 (density_2));
        return _S821;
    }
    float3  _S952 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S952;
    bool _S953 = (fcptVaryingUsed());
    if(_S953)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S954 = !replay_1;
        if(_S954)
        {
            float3  _S955 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S956 = sel_1->glow + _S955;
            sel_1->glow = _S956;
        }
        float3  _S957 = throughput_2 * weight_1;
        throughput_2 = _S957;
    }
    else
    {
        float3  _S958 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
        float3  _S959 = throughput_2 * _S958;
        throughput_2 = _S959;
    }
    float _S960 = width_2 + spread_1 * (&hit_1)->distance;
    uint _S961 = b_6 + 1U;
    b_6 = _S961;
    layer_0 = 0U;
    width_2 = _S960;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_6 = false;
    chain_throughput_0 = _S820;
    float3  reconnection_0 = _S820;
    viewed_0 = _S929;
    for(;;)
    {
        bool _S962 = ((&hit_1)->is_point_light) == 1U;
        if(replay_1)
        {
            _S818 = _S825 == 1U;
        }
        else
        {
            _S818 = false;
        }
        bool _S963;
        if(_S818)
        {
            _S963 = b_6 == _S824;
        }
        else
        {
            _S963 = false;
        }
        bool _S964;
        if(_S963)
        {
            bool _S965 = ((&hit_1)->instance_index) != (_S837.instance_index);
            if(_S965)
            {
                _S964 = true;
            }
            else
            {
                _S964 = ((&hit_1)->triangle_index) != (_S837.triangle_index);
            }
        }
        else
        {
            _S964 = false;
        }
        if(_S964)
        {
            return _S821;
        }
        FKMedium _S966 = Medium_x24init_0(_S820, _S820, 0.0f);
        BSDFMaterial _S967 = Material_x24init_0(_S820, _S820, 0.0f, 0.0f, 0.0f, 0.0f, _S820, throughput_3, 1.0f, _S820, _S820, 0.5f, 0.0f, 0.0f, _S820, 0.0f, _S820);
        FKMedium _S968 = _S966;
        FKSurface _S969 = Surface_x24init_0(_S820, _S820, 0.0f, &_S967, false, 0U, 1.0f, false, &_S968, 4294967295U, _S820);
        bool _S970 = !_S962;
        bool scatter_2;
        bool is_inside_7;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S970)
        {
            uint _S971 = stream(_S848, b_6);
            uint _S972 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKSurface _S973 = (fcptSurfaceAtPath((hit_1), ((&ray_2)->origin), (_S971), (width_2), (layer_0), (b_6), (_S972), ((&ray_2)->unit_direction)));
            bool _S974 = !passes_0;
            FKSurface _S975 = _S973;
            FKSurface _S976 = emitting_0(&_S975, _S974);
            uint _S977 = stream(_S848, b_6 + 256U);
            Random _S978 = pcg(_S977);
            FKSurface _S979 = _S976;
            FKSurface _S980 = uncovered_0(&_S979, _S978.value);
            float _S981 = facingSign(_S980.material.transmission, _S980.geometry_n, (&ray_2)->unit_direction);
            bool _S982 = _S981 < 0.0f;
            bool _S983 = (_S980.material.transmission) > 0.0f;
            if(_S983)
            {
                bool _S984 = arrivesBehind_0((&ray_2)->unit_direction, _S980.geometry_n);
                scatter_2 = _S984;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S985 = _S980;
            FKSurface _S986 = facingRay_0(&_S985, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S987 = arrivesBehind_0((&ray_2)->unit_direction, _S986.geometry_n);
                is_inside_7 = _S987;
            }
            else
            {
                is_inside_7 = scatter_2;
            }
            if(is_inside_7)
            {
                float3  _S988 = beerLambert((&hit_1)->distance, _S986.material.absorption);
                float3  _S989 = throughput_2 * _S988;
                throughput_5 = _S989;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S990 = !_S986.skip;
            float geometry_density_3 = geometryDensity(_S986.geometry_n, (&ray_2)->unit_direction, (&hit_1)->distance);
            bool _S991 = b_6 == _S961;
            if(_S991)
            {
                float _S992 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S992;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S993 = geometry_density_2;
            scatter_2 = _S990;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S993;
            surface_12 = _S986;
            turned_1 = _S982;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_12 = _S969;
            throughput_5 = throughput_2;
            is_inside_7 = is_inside_6;
        }
        bool _S994 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S995 = surface_12;
        FKSurface _S996 = surface_12;
        float _S997 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        float2  _S998 = vertexEta(_S995.material, _S997);
        bool _S999;
        if(scatter_2)
        {
            bool _S1000 = neeDecision(_S995.material, _S997, _S998.x, _S998.y);
            _S999 = _S1000;
        }
        else
        {
            _S999 = false;
        }
        bool _S1001;
        if(passes_0)
        {
            _S1001 = true;
        }
        else
        {
            _S1001 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1001)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S999;
        }
        bool _S1002 = (fcptHairUsed());
        bool _S1003;
        if(_S1002)
        {
            float3  _S1004 = surface_12.hair;
            _S1003 = (dot_0(_S1004, _S1004)) > 0.0f;
        }
        else
        {
            _S1003 = false;
        }
        bool _S1005;
        if(_S1003)
        {
            _S1005 = true;
        }
        else
        {
            BSDFMaterial _S1006 = _S995.material;
            bool _S1007 = isTranslucent_0(&_S1006);
            _S1005 = _S1007;
        }
        bool _S1008;
        if(_S1005)
        {
            _S1008 = true;
        }
        else
        {
            bool _S1009 = (_S995.material.transmission) > 0.0f;
            if(_S1009)
            {
                uint _S1010 = (fcptLayers((hit_1)));
                _S1008 = _S1010 == 1U;
            }
            else
            {
                _S1008 = false;
            }
        }
        float3  emission_0;
        if(_S962)
        {
            float3  _S1011 = (fcptCalculatePointLightContrib(((&hit_1)->instance_index)));
            emission_0 = _S1011;
        }
        else
        {
            emission_0 = _S995.material.emissive;
        }
        bool _S1012 = !replay_1;
        bool _S1013;
        if(_S1012)
        {
            _S1013 = true;
        }
        else
        {
            _S1013 = b_6 >= _S836;
        }
        bool _S1014;
        if(_S1013)
        {
            float _S1015 = rgb_to_greyscale(emission_0);
            _S1014 = _S1015 > 0.0f;
        }
        else
        {
            _S1014 = false;
        }
        float3  emission_1;
        if(_S1014)
        {
            NEEVertex _S1016 = nee_vertex_0;
            FKHit _S1017 = hit_1;
            float _S1018 = emissionWeight_0(&_S1016, &_S1017, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1018);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1019;
        if(replay_1)
        {
            _S1019 = _S825 == 1U;
        }
        else
        {
            _S1019 = false;
        }
        bool _S1020;
        if(_S1019)
        {
            _S1020 = b_6 > _S824;
        }
        else
        {
            _S1020 = false;
        }
        bool _S1021;
        if(_S1020)
        {
            _S1021 = b_6 == _S823;
        }
        else
        {
            _S1021 = false;
        }
        bool _S1022;
        if(_S1021)
        {
            bool _S1023 = _S826 == 1U;
            if(_S1023)
            {
                _S1022 = true;
            }
            else
            {
                _S1022 = _S826 == 2U;
            }
        }
        else
        {
            _S1022 = false;
        }
        if(_S1022)
        {
            bool _S1024 = _S962 != (_S826 == 2U);
            if(_S1024)
            {
                return _S821;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_1->jac), density_2 / r_1->jac);
        }
        uint _S1025 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1026 = _S1025 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1027 = insertBits_0(0U, b_6, 5U, 5U);
        uint _S1028 = insertBits_0(_S1027, 1U, 10U, 2U);
        uint _S1029 = insertBits_0(_S1028, (&prev_0)->lobe, 15U, 3U);
        bool _S1030 = (&prev_0)->inside;
        uint _S1031 = _slang_select(_S1030, 1U,0U);
        uint _S1032 = insertBits_0(_S1029, _S1031, 22U, 1U);
        (&here_0)->path = _S1032;
        float _S1033 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1033;
        fcptWithReservoirHit((&here_0), (&hit_1));
        bool _S1034;
        if(replay_1)
        {
            _S1034 = _S825 == 1U;
        }
        else
        {
            _S1034 = false;
        }
        bool _S1035;
        if(_S1034)
        {
            _S1035 = b_6 == _S824;
        }
        else
        {
            _S1035 = false;
        }
        bool _S1036 = b_6 == _S836;
        bool _S1037;
        if(_S1036)
        {
            bool _S1038 = !scatter_2;
            if(_S1038)
            {
                _S1037 = true;
            }
            else
            {
                bool _S1039 = _S825 != 1U;
                if(_S1039)
                {
                    _S1037 = _S825 != 3U;
                }
                else
                {
                    _S1037 = false;
                }
            }
        }
        else
        {
            _S1037 = false;
        }
        bool _S1040;
        if(_S1037)
        {
            _S1040 = _S825 == 2U;
        }
        else
        {
            _S1040 = false;
        }
        bool _S1041;
        if(_S1040)
        {
            _S1041 = !_S994;
        }
        else
        {
            _S1041 = false;
        }
        bool _S1042;
        if(_S1041)
        {
            _S1042 = _S826 != 4U;
        }
        else
        {
            _S1042 = false;
        }
        bool _S1043 = _S824 == _S823;
        bool _S1044;
        if(_S1043)
        {
            _S1044 = _S826 == 0U;
        }
        else
        {
            _S1044 = false;
        }
        bool _S1045;
        if(_S1044)
        {
            _S1045 = ((&hit_1)->instance_index) == (_S837.instance_index);
        }
        else
        {
            _S1045 = false;
        }
        bool _S1046;
        if(_S1045)
        {
            _S1046 = ((&hit_1)->triangle_index) == (_S837.triangle_index);
        }
        else
        {
            _S1046 = false;
        }
        bool _S1047;
        if(_S1046)
        {
            _S1047 = _S994;
        }
        else
        {
            _S1047 = false;
        }
        bool _S1048 = _slang_select(_S1035, _S1047,_S1042);
        bool _S1049;
        if(nee_0)
        {
            _S1049 = _slang_select(replay_1, _S1048,scatter_2);
        }
        else
        {
            _S1049 = false;
        }
        TreeSample _S1050 = TreeSample_x24init_0(_S820, _S820, 0.0f, 0U);
        uint2  _S1051 = make_uint2 (0U);
        float2  _S1052 = make_float2 (0.0f);
        FKHit _S1053 = Hit_x24init_0(_S1052, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1054 = _S1053;
        ShadowContext _S1055 = ShadowContext_x24init_0(_S820, _S820, _S1051, _S820, 0U, 0U, false, 0.0f, 0.0f, &_S1054, false);
        bool _S1056;
        if(nee_0)
        {
            _S1056 = _S1013;
        }
        else
        {
            _S1056 = false;
        }
        ShadowContext context_5;
        if(_S1056)
        {
            uint _S1057 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKMedium _S1058 = (fcptOutsideMedium((hit_1)));
            FKSurface _S1059 = surface_12;
            FKHit _S1060 = hit_1;
            FKMedium _S1061 = _S1058;
            ShadowContext _S1062 = shadowContext_0(&_S1059, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_6, _S1057, (&hit_1)->distance, width_2, &_S1060, _S1003, &_S1061);
            context_5 = _S1062;
        }
        else
        {
            context_5 = _S1055;
        }
        float3  throughput_6;
        float3  lit_0;
        if(_S1049)
        {
            float3  _S1063 = (&ray_2)->origin;
            if(_S1003)
            {
                throughput_6 = _S820;
            }
            else
            {
                throughput_6 = _S996.smooth_n;
            }
            FKSurface _S1064 = surface_12;
            uint _S1065 = stream(_S848, b_6 + 64U);
            ShadowContext _S1066 = context_5;
            TreeSample _S1067 = sampleLightTree_0(_S1063, throughput_6, surface_12.geometry_n, surface_12.geometry_offset, _S1008, _S1065, &_S1066);
            bool _S1068 = any_0((_S1067.radiance) != _S820);
            if(_S1068)
            {
                if(_S1003)
                {
                    uint _S1069 = (fcptMaxBounces());
                    bool _S1070 = b_6 < _S1069;
                    FKSurface _S1071 = surface_12;
                    TreeSample _S1072 = _S1067;
                    float3  _S1073 = hairLight_0(&_S1071, (&ray_2)->unit_direction, &_S1072, _S1070);
                    lit_0 = _S1073;
                }
                else
                {
                    float _S1074 = _S998.x;
                    float _S1075 = _S998.y;
                    uint _S1076 = (fcptMaxBounces());
                    bool _S1077 = b_6 < _S1076;
                    TreeSample _S1078 = _S1067;
                    BSDFMaterial _S1079 = _S995.material;
                    float3  _S1080 = lightBSDF_0((&ray_2)->unit_direction, &_S1078, _S996.smooth_n, _S1064.geometry_n, &_S1079, _S1074, _S1075, _S1077, surface_12.random_state);
                    lit_0 = _S1080;
                }
            }
            else
            {
                lit_0 = _S820;
            }
            light_3 = _S1067;
        }
        else
        {
            light_3 = _S1050;
            lit_0 = _S820;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1081;
        bool _S1082;
        float density_4;
        if(_S1035)
        {
            bool _S1083 = !_S994;
            if(_S1083)
            {
                return _S821;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1043)
            {
                viewed_1 = _S826 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            if(_S1043)
            {
                refracted_4 = _S826 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1084 = !nee_0;
                if(_S1084)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1085 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1085 > 0.0f);
                }
                if(passes_0)
                {
                    return _S821;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            if(_S1043)
            {
                wrong_side_0 = _S826 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1086 = !nee_0;
                if(_S1086)
                {
                    return _S821;
                }
                float _S1087 = environmentPdf_0(r_1->dir);
                float3  _S1088 = skyBSDF((&ray_2)->unit_direction, r_1->dir, surface_12, _S998, is_inside_7, _S1087, surface_12.random_state);
                return Shift_x24init_0(throughput_7 * _S1088 * r_1->radiance / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            uint _S1089 = extractBits_0(_S822, 21U, 1U);
            bool _S1090 = nee_0 != (_S1089 == 1U);
            if(_S1090)
            {
                return _S821;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S1036;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1091 = !scatter_2;
                if(_S1091)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1092 = _S825 != 1U;
                    if(_S1092)
                    {
                        refracted_4 = _S825 != 3U;
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
                bool _S1093 = _S825 == 2U;
                if(_S1093)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S994;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S826 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1003)
                    {
                        return _S821;
                    }
                    uint _S1094 = stream(_S848, b_6 + 448U);
                    FKRay _S1095 = ray_2;
                    FKSurface _S1096 = surface_12;
                    ShadowContext _S1097 = context_5;
                    SkySample _S1098 = sampleSky_0(&_S1095, &_S1096, _S998, is_inside_7, _S1094, surface_12.random_state, &_S1097);
                    return Shift_x24init_0(throughput_5 * _S1098.color, 1.0f);
                }
                if(_S1093)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S994;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1099 = rgb_to_greyscale(light_3.radiance);
                    bool _S1100 = !(_S1099 > 0.0f);
                    if(_S1100)
                    {
                        return _S821;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S835)
                {
                    passes_0 = _S826 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S962;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S835)
                {
                    passes_0 = _S826 == 1U;
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
                    passes_0 = !_S994;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S821;
            }
            else
            {
                if(_S1012)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1101 = b_6 > 0U;
                    if(_S1101)
                    {
                        Reservoir candidate_4 = chain_0;
                        if(_S1026)
                        {
                            float3  _S1102 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_4)->radiance = _S1102;
                        }
                        else
                        {
                            if(_S994)
                            {
                                candidate_4 = here_0;
                            }
                        }
                        float3  _S1103 = throughput_5 * emission_1;
                        Reservoir _S1104 = withEnd(candidate_4, 1U, b_6, _S1103);
                        offer(sel_1, _S1104, _S1103 * make_float3 (scale_2) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1105 = throughput_5 * emission_1;
                        float3  _S1106 = sel_1->glow + _S1105;
                        sel_1->glow = _S1106;
                    }
                    if(nee_0)
                    {
                        float3  _S1107 = throughput_5 * lit_0;
                        Reservoir candidate_5 = chain_0;
                        if(_S1026)
                        {
                            float3  _S1108 = safeDivide(_S1107, chain_throughput_0);
                            (&candidate_5)->radiance = _S1108;
                        }
                        else
                        {
                            if(_S994)
                            {
                                candidate_5 = here_0;
                                uint _S1109 = insertBits_0((&candidate_5)->path, 1U, 21U, 1U);
                                (&candidate_5)->path = _S1109;
                                (&candidate_5)->dir = light_3.dir;
                                (&candidate_5)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1110 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                                uint _S1111 = insertBits_0(_S1110, 2U, 10U, 2U);
                                (&candidate_5)->path = _S1111;
                            }
                        }
                        Reservoir _S1112 = withEnd(candidate_5, 0U, b_6, _S1107);
                        offer(sel_1, _S1112, _S1107 * make_float3 (scale_2) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1003)
                        {
                            _S1081 = false;
                        }
                        else
                        {
                            bool _S1113 = environmentMapped_0();
                            _S1081 = _S1113;
                        }
                    }
                    else
                    {
                        _S1081 = false;
                    }
                    if(_S1081)
                    {
                        uint _S1114 = (fcptMaxBounces());
                        _S1082 = b_6 < _S1114;
                    }
                    else
                    {
                        _S1082 = false;
                    }
                    if(_S1082)
                    {
                        uint _S1115 = stream(_S848, b_6 + 448U);
                        FKRay _S1116 = ray_2;
                        FKSurface _S1117 = surface_12;
                        ShadowContext _S1118 = context_5;
                        SkySample _S1119 = sampleSky_0(&_S1116, &_S1117, _S998, is_inside_7, _S1115, surface_12.random_state, &_S1118);
                        float3  _S1120 = throughput_5 * _S1119.color;
                        Reservoir candidate_6 = chain_0;
                        if(_S1026)
                        {
                            float3  _S1121 = safeDivide(_S1120, chain_throughput_0);
                            (&candidate_6)->radiance = _S1121;
                        }
                        else
                        {
                            if(_S994)
                            {
                                candidate_6 = here_0;
                                uint _S1122 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1122;
                                (&candidate_6)->dir = _S1119.dir;
                                (&candidate_6)->radiance = _S1119.radiance;
                            }
                            else
                            {
                                uint _S1123 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                                uint _S1124 = insertBits_0(_S1123, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1124;
                            }
                        }
                        Reservoir _S1125 = withEnd(candidate_6, 4U, b_6, _S1120);
                        offer(sel_1, _S1125, _S1120 * make_float3 (scale_2) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1126;
        bool _S1127;
        bool _S1128;
        bool straight_0;
        bool _S1129;
        bool _S1130;
        bool _S1131;
        bool _S1132;
        bool _S1133;
        bool _S1134;
        bool _S1135;
        bool _S1136;
        bool _S1137;
        bool _S1138;
        bool _S1139;
        bool _S1140;
        float density_6;
        float sky_pdf_2;
        float spread_4;
        uint b_9;
        float3  throughput_8;
        float3  throughput_9;
        float3  throughput_10;
        if(scatter_2)
        {
            if(replay_1)
            {
                viewed_1 = _S1036;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1141 = extractBits_0(_S822, 15U, 3U);
            uint _S1142 = extractBits_0(_S822, 18U, 3U);
            uint _S1143 = _slang_select(_S1035, _S1142,_S1141);
            float3  _S1144 = r_1->dir;
            bool refracted_5 = _S1143 == 1U;
            SampleBSDF _S1145 = SampleBSDF_x24init_0(_S820, _S820, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1145;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1146 = extractBits_0(_S822, 22U, 1U);
                bool _S1147 = is_inside_7 != (_S1146 == 1U);
                if(_S1147)
                {
                    return _S821;
                }
                bool _S1148 = _S825 == 1U;
                if(_S1148)
                {
                    float3  _S1149 = (fcptHitPosition((_S837)));
                    throughput_8 = _S1149;
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
                    BSDFMaterial _S1150 = _S995.material;
                    bool _S1151 = isTranslucent_0(&_S1150);
                    if(_S1151)
                    {
                        refracted_4 = _S1143 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1152 = throughput_8 - (&ray_2)->origin;
                        float3  _S1153 = _slang_select(_S1148, _S1152,_S1144);
                        wrong_side_0 = (dot_0(_S996.smooth_n, _S1153) * _S997) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1148)
                {
                    float3  _S1154 = (&ray_2)->origin;
                    FKSurface _S1155 = surface_12;
                    float3  _S1156 = - _S996.smooth_n;
                    bool _S1157 = is_inside_7 != refracted_4;
                    float3  _S1158 = _slang_select(_S1157, _S1156,_S996.smooth_n);
                    float3  _S1159 = throughput_8 - (_S1154 + make_float3 (_S1155.geometry_offset) * _S1158);
                    float3  _S1160 = ((((_S1159)) * make_float3(rnorm3df(((_S1159)).x, ((_S1159)).y, ((_S1159)).z))));
                    reconnection_1 = _S1160;
                }
                else
                {
                    reconnection_1 = _S1144;
                }
                if(_S1003)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1161 = wrongSide_0(is_inside_7, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1161;
                }
                if(wrong_side_0)
                {
                    return _S821;
                }
                float3  _S1162 = throughput_8;
                throughput_8 = reconnection_1;
                b_9 = _S1143;
                wrong_side_0 = false;
                reconnection_1 = _S1162;
            }
            else
            {
                bool _S1163 = !_S1035;
                if(_S1163)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1164;
                    if(_S1003)
                    {
                        SampleBSDF _S1165 = (fcptSampleHair((surface_12.hair), (_S995.material.albedo), (_S995.material.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1164 = _S1165;
                    }
                    else
                    {
                        SampleBSDF _S1166 = sampleBSDF((&ray_2)->unit_direction, _S996.smooth_n, _S995.material, _S998.x, _S998.y, surface_12.random_state, _S1052);
                        _S1164 = _S1166;
                    }
                    bsdf_sampled_0 = _S1164;
                    if(_S1003)
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
                            return _S821;
                        }
                        break;
                    }
                    if(_S1003)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1167 = wrongSide_0(is_inside_7, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1167;
                    }
                    if(wrong_side_0)
                    {
                        _S1081 = (_S995.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1081 = false;
                    }
                    if(_S1081)
                    {
                        SampleBSDF _S1168 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S995.material, _S998.x, _S998.y, (&bsdf_sampled_0)->random_state, _S1052);
                        (&bsdf_sampled_0)->unit_direction = _S1168.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1168.refracted;
                        (&bsdf_sampled_0)->throughput = _S1168.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1169 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1169;
                        }
                    }
                    uint _S1170 = (&bsdf_sampled_0)->lobe;
                    float3  _S1171 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1172 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1173 = (&bsdf_sampled_0)->pdf;
                    float _S1174 = _slang_select(wrong_side_0, 0.0f,_S1173);
                    (&lobe_5)->pdf = _S1174;
                    throughput_8 = _S1171;
                    b_9 = _S1170;
                    refracted_4 = _S1172;
                }
                else
                {
                    throughput_8 = _S1144;
                    b_9 = _S1143;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1081 = true;
            }
            else
            {
                _S1081 = _S1035;
            }
            float3  chain_throughput_1;
            if(_S1081)
            {
                if(_S1003)
                {
                    SampleBSDF _S1175 = (fcptConnectHair((surface_12.hair), (_S995.material.albedo), (_S995.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    lobe_5 = _S1175;
                }
                else
                {
                    float3  _S1176 = (&ray_2)->unit_direction;
                    float _S1177 = sign_0(_S997);
                    float3  _S1178 = _S996.smooth_n * make_float3 (_S1177);
                    float _S1179 = dot_0(_S1178, throughput_8);
                    float _S1180 = _S995.material.roughness;
                    float _S1181 = _S1180 * _S1180;
                    AnisotropicFrame _S1182 = anisotropicFrame(_S995.material, _S1178);
                    float3  _S1183 = reflectedHalf(_S1176, throughput_8);
                    bool _S1184 = b_9 == 1U;
                    if(_S1184)
                    {
                        float3  _S1185 = refractedHalf(_S1176, throughput_8, _S996.smooth_n, _S998.x, _S998.y);
                        throughput_9 = _S1185;
                    }
                    else
                    {
                        throughput_9 = _S1183;
                    }
                    bool _S1186 = b_9 == 0U;
                    if(_S1186)
                    {
                        _S1082 = true;
                    }
                    else
                    {
                        _S1082 = b_9 == 6U;
                    }
                    if(_S1082)
                    {
                        float3  _S1187 = sampledHalf(_S1176, _S996.smooth_n, _S995.material, surface_12.random_state, _S1182);
                        throughput_10 = _S1187;
                    }
                    else
                    {
                        throughput_10 = throughput_9;
                    }
                    float3  _S1188 = negate_0(_S1176);
                    float _S1189 = _S998.x;
                    float _S1190 = _S998.y;
                    BSDFLobes _S1191 = bsdfLobes(_S1176, _S1188, _S1178, throughput_10, _S995.material, _S1189, _S1190, _S1182);
                    BSDFLobes lobe_terms_1 = _S1191;
                    float _S1192 = translucentShare(_S995.material);
                    (&lobe_terms_1)->translucent_share = _S1192;
                    switch(b_9)
                    {
                    case 0U:
                        {
                            float _S1193 = diffusePDF(_S1179, 0.0f, (F32_abs((_S997))), _S1181, lobe_terms_1, _S1189, _S1190);
                            float3  _S1194 = diffuseBSDF(throughput_8, _S1178, _S1181, _S995.material, lobe_terms_1);
                            density_6 = _S1193;
                            chain_throughput_1 = _S1194;
                            break;
                        }
                    case 1U:
                        {
                            float _S1195 = refractPDF(_S1179, dot_0(throughput_8, throughput_10), (F32_abs((_S997))), _S1181, lobe_terms_1, _S1189, _S1190);
                            float3  _S1196 = refractBSDF(throughput_8, _S1178, _S1181, _S995.material, lobe_terms_1);
                            density_6 = _S1195;
                            chain_throughput_1 = _S1196;
                            break;
                        }
                    case 4U:
                        {
                            float _S1197 = sheenVelvetPDF(_S1179, 0.0f, (F32_abs((_S997))), _S1181, lobe_terms_1, _S1189, _S1190);
                            float3  _S1198 = sheenVelvetBSDF(throughput_8, _S1178, _S1181, _S995.material, lobe_terms_1);
                            density_6 = _S1197;
                            chain_throughput_1 = _S1198;
                            break;
                        }
                    case 6U:
                        {
                            float _S1199 = toonPDF(_S1179, dot_0(throughput_8, (&lobe_terms_1)->toon_axis), (F32_abs((_S997))), _S1181, lobe_terms_1, _S1189, _S1190);
                            float3  _S1200 = toonBSDF(throughput_8, _S1178, _S1181, _S995.material, lobe_terms_1);
                            density_6 = _S1199;
                            chain_throughput_1 = _S1200;
                            break;
                        }
                    default:
                        {
                            float _S1201 = reflectPDF(_S1179, 0.0f, (F32_abs((_S997))), _S1181, lobe_terms_1, _S1189, _S1190);
                            float3  _S1202 = reflectBSDF(throughput_8, _S1178, _S1181, _S995.material, lobe_terms_1);
                            density_6 = _S1201;
                            chain_throughput_1 = _S1202;
                            break;
                        }
                    }
                    bool _S1203 = density_6 > 0.0f;
                    if(_S1203)
                    {
                        SampleBSDF _S1204 = SampleBSDF_x24init_0(throughput_8, chain_throughput_1, surface_12.random_state, _S1184, b_9, density_6);
                        lobe_5 = _S1204;
                    }
                }
            }
            bool _S1205 = b_9 == 0U;
            if(_S1205)
            {
                _S1082 = true;
            }
            else
            {
                _S1082 = b_9 == 4U;
            }
            if(_S1082)
            {
                _S1126 = true;
            }
            else
            {
                _S1126 = b_9 == 6U;
            }
            if(_S1003)
            {
                _S1127 = false;
            }
            else
            {
                bool _S1206 = !_S1126;
                if(_S1206)
                {
                    bool _S1207 = (_S995.material.roughness) == 0.0f;
                    if(_S1207)
                    {
                        _S1127 = true;
                    }
                    else
                    {
                        bool _S1208 = b_9 == 1U;
                        if(_S1208)
                        {
                            _S1127 = (_S998.x) == (_S998.y);
                        }
                        else
                        {
                            _S1127 = false;
                        }
                    }
                }
                else
                {
                    _S1127 = false;
                }
            }
            bool _S1209 = !_S1003;
            if(_S1209)
            {
                _S1128 = b_9 == 1U;
            }
            else
            {
                _S1128 = false;
            }
            if(_S1128)
            {
                straight_0 = (_S995.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1129 = _S1209;
            }
            else
            {
                _S1129 = false;
            }
            if(_S1129)
            {
                _S1130 = b_9 == 1U;
            }
            else
            {
                _S1130 = false;
            }
            if(_S1130)
            {
                _S1131 = (_S998.x) == (_S998.y);
            }
            else
            {
                _S1131 = false;
            }
            BSDFMaterial _S1210 = _S995.material;
            bool _S1211 = isTranslucent_0(&_S1210);
            if(_S1211)
            {
                _S1132 = _S1205;
            }
            else
            {
                _S1132 = false;
            }
            if(_S1132)
            {
                _S1133 = (dot_0(throughput_8, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1133 = false;
            }
            if(nee_0)
            {
                _S1134 = !_S1127;
            }
            else
            {
                _S1134 = false;
            }
            if(_S1134)
            {
                _S1135 = !wrong_side_0;
            }
            else
            {
                _S1135 = false;
            }
            if(_S1135)
            {
                float _S1212 = (&lobe_5)->pdf;
                float3  _S1213 = (&ray_2)->origin;
                float3  _S1214 = _slang_select(_S1008, _S820,_S996.smooth_n);
                float3  _S1215 = (&ray_2)->origin;
                FKSurface _S1216 = surface_12;
                float3  _S1217 = - _S996.smooth_n;
                float3  _S1218 = _slang_select(_S1133, _S1217,_S996.smooth_n);
                NEEVertex _S1219 = NEEVertex_x24init_0(false, _S1212, _S1213, _S1214, _S1215 + make_float3 (_S1216.geometry_offset) * _S1218);
                nee_vertex_0 = _S1219;
            }
            else
            {
                if(_S1003)
                {
                    _S1136 = true;
                }
                else
                {
                    bool _S1220 = b_9 != 1U;
                    if(_S1220)
                    {
                        _S1136 = true;
                    }
                    else
                    {
                        _S1136 = (_S998.x) != (_S998.y);
                    }
                }
                if(_S1136)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1221 = withinInverseFootprint((&lobe_5)->pdf, _S1126, (&prev_0)->cos, (&hit_1)->distance, threshold_2);
            bool _S1222 = roughLobe((&lobe_5)->pdf, _S1126, _S995.material.roughness);
            if(_S1035)
            {
                bool _S1223 = !_S1221;
                if(_S1223)
                {
                    return _S821;
                }
                bool _S1224 = _S826 != 1U;
                if(_S1224)
                {
                    _S1136 = _S826 != 2U;
                }
                else
                {
                    _S1136 = false;
                }
                if(_S1136)
                {
                    float _S1225 = (&lobe_5)->pdf;
                    float _S1226 = _slang_select(nee_0, _S1225,0.0f);
                    float _S1227 = escapeWeight_0(_S1226, _S1144);
                    if(_S1043)
                    {
                        passes_0 = _S832;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1228 = _slang_select(passes_0, _S1227,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_1->radiance * make_float3 (_S1228) / make_float3 (r_1->jac), density_4 * (&lobe_5)->pdf / r_1->jac);
                }
                float3  _S1229 = throughput_6 * make_float3 ((&lobe_5)->pdf);
                float _S1230 = density_4 * (&lobe_5)->pdf;
                throughput_9 = _S1229;
                density_6 = _S1230;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1231 = (fcptLayers((hit_1)));
            bool _S1232 = b_9 == 1U;
            bool _S1233 = passesLayer_0(_S1231, _S1232, passes_0);
            if(viewed_1)
            {
                _S1136 = _S1233;
            }
            else
            {
                _S1136 = false;
            }
            if(_S1136)
            {
                return _S821;
            }
            if(replay_1)
            {
                _S1137 = b_6 <= _S836;
            }
            else
            {
                _S1137 = false;
            }
            if(_S1137)
            {
                _S1138 = _S994;
            }
            else
            {
                _S1138 = false;
            }
            if(_S1138)
            {
                _S1139 = _S1221;
            }
            else
            {
                _S1139 = false;
            }
            if(_S1139)
            {
                _S1140 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1140 = !_S1222;
                }
                else
                {
                    _S1140 = false;
                }
            }
            if(_S1140)
            {
                return _S821;
            }
            if(viewed_1)
            {
                float3  _S1234 = throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1235 = (&lobe_5)->pdf;
                throughput_10 = _S1234;
                sky_pdf_2 = _S1235;
            }
            else
            {
                float3  _S1236 = throughput_9 * max_0((&lobe_5)->throughput, _S820);
                throughput_10 = _S1236;
                sky_pdf_2 = density_6;
            }
            bool _S1237;
            if(_S1012)
            {
                _S1237 = !_S1026;
            }
            else
            {
                _S1237 = false;
            }
            bool _S1238;
            if(_S1237)
            {
                _S1238 = _S994;
            }
            else
            {
                _S1238 = false;
            }
            bool _S1239;
            if(_S1238)
            {
                _S1239 = _S1221;
            }
            else
            {
                _S1239 = false;
            }
            if(_S1239)
            {
                chain_0 = here_0;
                uint _S1240 = insertBits_0((&chain_0)->path, b_9, 18U, 3U);
                uint _S1241 = _slang_select(nee_0, 1U,0U);
                uint _S1242 = insertBits_0(_S1240, _S1241, 21U, 1U);
                (&chain_0)->path = _S1242;
                float _S1243 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1243;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1244 = surface_12;
            Vertex _S1245 = Vertex_x24init_0(_S1222, b_9, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_8)))), is_inside_7);
            prev_0 = _S1245;
            float _S1246 = (&lobe_5)->pdf;
            bool _S1247;
            if(_S1232)
            {
                _S1247 = (_S998.x) == (_S998.y);
            }
            else
            {
                _S1247 = false;
            }
            float sky_pdf_3 = _slang_select(_S1247, sky_pdf_0,_S1246);
            float _S1248 = _slang_select(_S1003, 0.0f,sky_pdf_3);
            float _S1249 = widened_0(spread_1, (&lobe_5)->pdf, _S1127);
            bool _S1250;
            if(refracted_4)
            {
                _S1250 = !_S1133;
            }
            else
            {
                _S1250 = false;
            }
            bool is_inside_8;
            if(_S1250)
            {
                bool _S1251 = !is_inside_7;
                is_inside_8 = _S1251;
            }
            else
            {
                is_inside_8 = is_inside_7;
            }
            FKSurface _S1252 = surface_12;
            bool _S1253 = boundsVolume_0(&_S1252);
            bool _S1254;
            if(_S1253)
            {
                _S1254 = !_S1233;
            }
            else
            {
                _S1254 = false;
            }
            if(_S1254)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1255 = - _S1244.geometry_n;
                float3  _S1256 = _slang_select(turned_1, _S1255,_S1244.geometry_n);
                (&faced_2)->geometry_n = _S1256;
                FKMedium _S1257 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1258 = (fcptOutsideMedium((hit_1)));
                FKSurface _S1259 = faced_2;
                FKMedium _S1260 = _S1257;
                FKMedium _S1261 = _S1258;
                MediumSides _S1262 = mediumSides_0(&_S1259, &_S1260, filling_2, (&ray_2)->unit_direction, &_S1261);
                bool _S1263 = leavesInFront_0((&faced_2)->geometry_n, throughput_8, _S1244.geometry_n);
                float3  _S1264 = _slang_select(_S1263, _S1262.front.scatter,_S1262.behind.scatter);
                scatter_in_0 = _S1264;
                float3  _S1265 = _slang_select(_S1263, _S1262.front.extinction,_S1262.behind.extinction);
                extinction_in_0 = _S1265;
                float _S1266 = _slang_select(_S1263, _S1262.front.g,_S1262.behind.g);
                g_in_0 = _S1266;
                uint _S1267 = _S1262.fillings.x;
                uint _S1268 = _S1262.fillings.y;
                uint _S1269 = _slang_select(_S1263, _S1268,_S1267);
                bool _S1270 = (fcptVaryingUsed());
                uint _S1271 = _slang_select(_S1270, _S1269,4294967295U);
                filling_2 = _S1271;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1272 = !_S1233;
            if(_S1272)
            {
                FKSurface _S1273 = surface_12;
                float _S1274 = _slang_select(straight_0, 0.0f,_S1273.geometry_offset);
                float3  _S1275 = - _S996.smooth_n;
                bool _S1276 = is_inside_8 != _S1133;
                float3  _S1277 = _slang_select(_S1276, _S1275,_S996.smooth_n);
                float3  _S1278 = (&ray_2)->origin + make_float3 (_S1274) * _S1277;
                (&ray_2)->origin = _S1278;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1233;
            viewed_1 = _S1131;
            sky_pdf_2 = _S1248;
            spread_4 = _S1249;
            reconnection_0 = reconnection_1;
            is_inside_6 = is_inside_8;
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
            is_inside_6 = is_inside_7;
        }
        float density_7;
        if(_S1012)
        {
            if(_S962)
            {
                float3  _S1279 = throughput_9 * emission_1;
                Reservoir candidate_7 = chain_0;
                uint _S1280 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1281 = _S1280 == 1U;
                if(_S1281)
                {
                    float3  _S1282 = safeDivide(_S1279, chain_throughput_0);
                    (&candidate_7)->radiance = _S1282;
                }
                Reservoir _S1283 = withEnd(candidate_7, 2U, b_6, _S1279);
                offer(sel_1, _S1283, _S1279 * make_float3 (scale_2) / make_float3 (density_6));
            }
            if(_S962)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1284 = survivalProbability(throughput_9, density_6);
                density_7 = _S1284;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1285 = stream(_S848, b_6 + 128U);
            Random _S1286 = pcg(_S1285);
            bool _S1287 = density_7 < (_S1286.value);
            if(_S1287)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1288 = (fcptMaxBounces());
                wrong_side_0 = b_6 >= _S1288;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1289 = density_6 * density_7;
            density_7 = _S1289;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1290 = layer_0 ^ 1U;
        uint _S1291 = _slang_select(passes_0, _S1290,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_1)->distance = 0.0f;
            b_9 = b_6;
            viewed_0 = viewed_1;
            throughput_2 = throughput_9;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_1 = spread_4;
            uint _S1292 = b_9 + 1U;
            b_6 = _S1292;
            layer_0 = _S1291;
            continue;
        }
        FKRay _S1293 = ray_2;
        float _S1294 = distance_5(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S1036;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S825 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1295 = _slang_select(wrong_side_0, _S1294,4.294967296e+09f);
        bool _S1296 = !_S1003;
        if(straight_0)
        {
            _S1081 = true;
        }
        else
        {
            _S1081 = _S1003;
        }
        FKHit _S1297;
        if(_S1081)
        {
            _S1297 = hit_1;
        }
        else
        {
            _S1297 = _S1053;
        }
        FKHit _S1298 = (fcptTraverseInstanceBVH((_S1293), (_S970), (_S1295), (_S1296), (_S1297), (viewed_1)));
        hit_1 = _S1298;
        if(replay_1)
        {
            _S1082 = _S1036;
        }
        else
        {
            _S1082 = false;
        }
        if(_S1082)
        {
            _S1126 = _S825 == 1U;
        }
        else
        {
            _S1126 = false;
        }
        if(_S1126)
        {
            _S1127 = ((&hit_1)->instance_index) == (_S837.instance_index);
        }
        else
        {
            _S1127 = false;
        }
        if(_S1127)
        {
            _S1128 = ((&hit_1)->triangle_index) == (_S837.triangle_index);
        }
        else
        {
            _S1128 = false;
        }
        if(_S1128)
        {
            (&hit_1)->uv = _S837.uv;
            float _S1299 = distance_5(reconnection_0, (&ray_2)->origin);
            (&hit_1)->distance = _S1299;
        }
        if(replay_1)
        {
            _S1129 = _S1036;
        }
        else
        {
            _S1129 = false;
        }
        if(_S1129)
        {
            _S1130 = _S825 == 3U;
        }
        else
        {
            _S1130 = false;
        }
        if(_S1130)
        {
            _S1131 = ((&hit_1)->instance_index) != 4294967295U;
        }
        else
        {
            _S1131 = false;
        }
        if(_S1131)
        {
            return _S821;
        }
        Reservoir _S1300 = chain_0;
        uint _S1301 = filling_2;
        for(;;)
        {
            bool _S1302 = (fcptVaryingUsed());
            if(_S1302)
            {
                _S1132 = _S1301 != 4294967295U;
            }
            else
            {
                _S1132 = false;
            }
            float _S1303;
            if(_S1132)
            {
                float _S1304 = (fcptMajorant((_S1301)));
                _S1303 = _S1304;
            }
            else
            {
                _S1303 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1133 = _S1036;
            }
            else
            {
                _S1133 = false;
            }
            if(_S1133)
            {
                _S1134 = _S825 == 1U;
            }
            else
            {
                _S1134 = false;
            }
            if(_S1134)
            {
                _S1135 = _S1303 > 0.0f;
            }
            else
            {
                _S1135 = false;
            }
            if(_S1135)
            {
                ended_0 = _S821;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_3 = width_2;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_9 = b_6;
                _S1136 = true;
                break;
            }
            bool _S1305 = (&prev_0)->rough;
            if(_S1305)
            {
                _S1136 = !(_S1303 > 0.0f);
            }
            else
            {
                _S1136 = false;
            }
            (&prev_0)->rough = _S1136;
            uint _S1306 = b_6 + 320U;
            bool _S1307 = b_6 == 4294967295U;
            uint _S1308 = _slang_select(_S1307, 384U,_S1306);
            uint _S1309 = stream(_S848, _S1308);
            uint tracking_1 = _S1309;
            weight_1 = throughput_3;
            glowed_0 = _S820;
            b_9 = b_6;
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
                    _S819 = int(2);
                    break;
                }
                uint _S1310 = b_9 + 320U;
                bool _S1311 = b_9 == 4294967295U;
                uint _S1312 = _slang_select(_S1311, 384U,_S1310);
                uint _S1313 = stream(_S848, _S1312);
                Random _S1314 = pcg(_S1313);
                float _S1315 = freeFlight_0(_S1314.value, _S1303);
                if(_S1132)
                {
                    float3  _S1316 = (&ray_2)->origin;
                    float3  _S1317 = (&ray_2)->unit_direction;
                    float _S1318 = (&hit_1)->distance;
                    uint _S1319 = _slang_select(_S1311, 0U,b_9);
                    uint _S1320 = (&prev_0)->lobe;
                    uint _S1321 = _slang_select(_S1311, 3U,_S1320);
                    float _S1322 = (fcptTrackMedium((_S1301), (_S1316), (_S1317), (_S1318), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1319), (_S1321), (_S1311)));
                    spread_3 = _S1322;
                }
                else
                {
                    spread_3 = _S1315;
                }
                bool _S1323 = !(spread_3 < ((&hit_1)->distance));
                if(_S1323)
                {
                    _S819 = int(2);
                    break;
                }
                if(_S1132)
                {
                    _S1137 = _S1012;
                }
                else
                {
                    _S1137 = false;
                }
                if(_S1137)
                {
                    float3  _S1324 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1325 = sel_1->glow + _S1324;
                    sel_1->glow = _S1325;
                }
                else
                {
                }
                glowed_0 = _S820;
                uint b_10 = b_9 + 1U;
                float3  _S1326 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1326;
                float3  _S1327 = flightWeight_0(scatter_in_0, extinction_in_0, _S1303, spread_3, true);
                float3  _S1328 = weight_1;
                float3  _S1329 = _slang_select(_S1132, _S1328,_S1327);
                float3  throughput_11 = throughput_10 * _S1329;
                uint _S1330 = stream(_S848, b_10 + 320U);
                tracking_1 = _S1330;
                weight_1 = throughput_3;
                float width_6 = width_3 + spread_2 * spread_3;
                float _S1331 = spread_2 + 3.14159274101257324f;
                bool _S1332 = scatterSampled_0(replay_1, b_10, _S836, _S1132);
                TreeSample light_4;
                if(_S1332)
                {
                    float3  _S1333 = (&ray_2)->origin;
                    float3  _S1334 = (&ray_2)->unit_direction;
                    float3  _S1335 = (&ray_2)->unit_direction;
                    uint _S1336 = stream(_S848, b_10 + 64U);
                    float3  _S1337 = extinction_in_0;
                    float3  _S1338 = extinction_in_0;
                    uint2  _S1339 = make_uint2 (_S1301);
                    float3  _S1340 = (&ray_2)->unit_direction;
                    uint _S1341 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                    FKHit _S1342 = _S1053;
                    ShadowContext _S1343 = ShadowContext_x24init_0(_S1337, _S1338, _S1339, _S1340, b_10, _S1341, false, spread_3, width_6, &_S1342, false);
                    ShadowContext _S1344 = _S1343;
                    TreeSample _S1345 = sampleLightTree_0(_S1333, _S1334, _S1335, 0.0f, true, _S1336, &_S1344);
                    light_4 = _S1345;
                }
                else
                {
                    light_4 = _S1050;
                }
                float _S1346 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1347 = (fcptMaxBounces());
                bool _S1348 = b_10 < _S1347;
                if(_S1348)
                {
                    _S1138 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1138 = false;
                }
                float _S1349 = _slang_select(_S1138, _S1346,0.0f);
                float3  _S1350 = throughput_11 * light_4.radiance;
                float _S1351 = powerHeuristic(light_4.density, _S1349);
                float3  _S1352 = _S1350 * make_float3 (_S1346 * _S1351);
                float3  _S1353 = _slang_select(_S1332, _S1352,_S820);
                if(replay_1)
                {
                    _S1139 = b_10 == _S836;
                }
                else
                {
                    _S1139 = false;
                }
                if(_S1139)
                {
                    bool _S1354 = _S825 == 2U;
                    if(_S1354)
                    {
                        float _S1355 = rgb_to_greyscale(_S1353);
                        _S1140 = _S1355 > 0.0f;
                    }
                    else
                    {
                        _S1140 = false;
                    }
                    if(_S1140)
                    {
                        Shift _S1356 = Shift_x24init_0(_S1353, 1.0f);
                        _S819 = int(1);
                        ended_0 = _S1356;
                        spread_3 = _S1331;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_7 = b_10;
                        break;
                    }
                    _S819 = int(1);
                    ended_0 = _S821;
                    spread_3 = _S1331;
                    width_4 = width_6;
                    throughput_8 = throughput_11;
                    b_7 = b_10;
                    break;
                }
                if(_S1012)
                {
                    Reservoir candidate_8 = _S1300;
                    uint _S1357 = extractBits_0(_S1300.path, 10U, 2U);
                    bool _S1358 = _S1357 == 1U;
                    if(_S1358)
                    {
                        float3  _S1359 = safeDivide(_S1353, chain_throughput_0);
                        (&candidate_8)->radiance = _S1359;
                    }
                    else
                    {
                        uint _S1360 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                        uint _S1361 = insertBits_0(_S1360, 2U, 10U, 2U);
                        (&candidate_8)->path = _S1361;
                    }
                    Reservoir _S1362 = withEnd(candidate_8, 0U, b_10, _S1353);
                    offer(sel_1, _S1362, _S1353 * make_float3 (scale_2) / make_float3 (density_3));
                    float _S1363 = survivalProbability(throughput_11, density_3);
                    uint _S1364 = stream(_S848, b_10 + 128U);
                    Random _S1365 = pcg(_S1364);
                    bool _S1366 = _S1363 < (_S1365.value);
                    if(_S1366)
                    {
                        _S1140 = true;
                    }
                    else
                    {
                        uint _S1367 = (fcptMaxBounces());
                        _S1140 = b_10 >= _S1367;
                    }
                    if(_S1140)
                    {
                        _S819 = int(1);
                        ended_0 = _S821;
                        spread_3 = _S1331;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_7 = b_10;
                        break;
                    }
                    float _S1368 = density_3 * _S1363;
                    density_3 = _S1368;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1369 = stream(_S848, b_10);
                float3  _S1370 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1369, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1370;
                NEEVertex _S1371 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S820, (&ray_2)->origin);
                nee_vertex_0 = _S1371;
                Vertex _S1372 = scatteredVertex_0(is_inside_6);
                prev_0 = _S1372;
                float _S1373 = (&prev_0)->pdf;
                FKRay _S1374 = ray_2;
                FKHit _S1375 = (fcptTraverseInstanceBVH((_S1374), (true), (4.294967296e+09f), (false), (_S1053), (false)));
                hit_1 = _S1375;
                b_9 = b_10;
                throughput_10 = throughput_11;
                spread_2 = _S1331;
                width_3 = width_6;
                sky_pdf_1 = _S1373;
            }
            if(_S819 != int(2))
            {
                spread_2 = spread_3;
                width_3 = width_4;
                throughput_10 = throughput_8;
                b_9 = b_7;
                _S1136 = true;
                break;
            }
            ended_0 = _S821;
            _S1136 = false;
            break;
        }
        if(_S1136)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1137 = b_9 == b_6;
        }
        else
        {
            _S1137 = false;
        }
        bool _S1376 = ((&hit_1)->instance_index) == 4294967295U;
        if(_S1376)
        {
            bool _S1377 = !(&nee_vertex_0)->none;
            float _S1378 = _slang_select(_S1377, sky_pdf_1,0.0f);
            float _S1379 = escapeWeight_0(_S1378, (&ray_2)->unit_direction);
            float3  _S1380 = environment_0((&ray_2)->unit_direction, b_9, (&prev_0)->lobe);
            float3  _S1381 = throughput_10 * _S1380;
            if(replay_1)
            {
                bool _S1382 = b_9 == _S836;
                if(_S1382)
                {
                    passes_0 = _S825 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1381 * make_float3 (_S1379) / make_float3 (r_1->jac), density_3 / r_1->jac);
                }
                if(_S835)
                {
                    passes_0 = _S832;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_9 == _S823;
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
                    return Shift_x24init_0(_S1381 * make_float3 (_S1379), 1.0f);
                }
                return _S821;
            }
            Reservoir candidate_9 = chain_0;
            uint _S1383 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1384 = _S1383 == 1U;
            if(_S1384)
            {
                uint _S1385 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1386 = _S1385 == b_9;
                float _S1387 = _slang_select(_S1386, 1.0f,_S1379);
                float3  _S1388 = safeDivide(_S1381 * make_float3 (_S1387), chain_throughput_0);
                (&candidate_9)->radiance = _S1388;
            }
            else
            {
                bool _S1389 = (&prev_0)->rough;
                if(_S1389)
                {
                    uint _S1390 = insertBits_0(0U, b_9 + 1U, 5U, 5U);
                    uint _S1391 = insertBits_0(_S1390, 3U, 10U, 2U);
                    uint _S1392 = insertBits_0(_S1391, (&prev_0)->lobe, 15U, 3U);
                    bool _S1393 = (&prev_0)->inside;
                    uint _S1394 = _slang_select(_S1393, 1U,0U);
                    uint _S1395 = insertBits_0(_S1392, _S1394, 22U, 1U);
                    (&candidate_9)->path = _S1395;
                    (&candidate_9)->jac = (&prev_0)->pdf;
                    (&candidate_9)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1396 = _S1381 * make_float3 (_S1379);
            Reservoir _S1397 = withEnd(candidate_9, 3U, b_9, _S1396);
            offer(sel_1, _S1397, _S1396 * make_float3 (scale_2) / make_float3 (density_3));
            break;
        }
        float3  _S1398 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1398;
        bool _S1399 = (fcptVaryingUsed());
        if(_S1399)
        {
            _S1138 = filling_2 != 4294967295U;
        }
        else
        {
            _S1138 = false;
        }
        if(_S1138)
        {
            if(_S1012)
            {
                float3  _S1400 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1401 = sel_1->glow + _S1400;
                sel_1->glow = _S1401;
            }
            float3  _S1402 = throughput_10 * weight_1;
            throughput_8 = _S1402;
        }
        else
        {
            float3  _S1403 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
            float3  _S1404 = throughput_10 * _S1403;
            throughput_8 = _S1404;
        }
        float _S1405 = width_3 + spread_2 * (&hit_1)->distance;
        viewed_0 = _S1137;
        width_2 = _S1405;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1292 = b_9 + 1U;
        b_6 = _S1292;
        layer_0 = _S1291;
    }
    return _S821;
}

static __device__ Shift shift_0(Domain * dom_1, Reservoir * r_2)
{
    Selection _S1406 = (Selection{});
    Selection sel_2 = _S1406;
    bool _S1407 = (r_2->w) <= 0.0f;
    if(_S1407)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1408 = walk_0(dom_1, r_2, true, 0.0f, &sel_2);
    return _S1408;
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
    int i_18 = int(0);
    for(;;)
    {
        if(i_18 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_8, i_18) = (F32_tan((_slang_vector_get_element(x_17, i_18))));
        i_18 = i_18 + int(1);
    }
    return result_8;
}

static __device__ float3  acos_0(float3  x_18)
{
    float3  result_9;
    int i_19 = int(0);
    for(;;)
    {
        if(i_19 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_9, i_19) = (F32_acos((_slang_vector_get_element(x_18, i_19))));
        i_19 = i_19 + int(1);
    }
    return result_9;
}

static __device__ float3  abs_0(float3  x_19)
{
    float3  result_10;
    int i_20 = int(0);
    for(;;)
    {
        if(i_20 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_10, i_20) = (F32_abs((_slang_vector_get_element(x_19, i_20))));
        i_20 = i_20 + int(1);
    }
    return result_10;
}

__device__ Random normal_distribution(uint state_4)
{
    Random _S1409 = pcg(state_4);
    Random _S1410 = pcg(_S1409.state);
    float _S1411 = 6.28318548202514648f * _S1409.value;
    float _S1412 = (F32_sqrt((-2.0f * clamp_0((F32_log((_S1410.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1410.state, _S1412 * (F32_cos((_S1411))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S1413;
    (&_S1413)->state = state_5;
    (&_S1413)->value = value_2;
    return _S1413;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S1414 = normal_distribution(state_6);
    Random _S1415 = normal_distribution(_S1414.state);
    Random _S1416 = normal_distribution(_S1415.state);
    float3  _S1417 = make_float3 (_S1414.value, _S1415.value, _S1416.value);
    float3  _S1418 = ((((_S1417)) * make_float3(rnorm3df(((_S1417)).x, ((_S1417)).y, ((_S1417)).z))));
    return RandomSphere_x24init_0(_S1416.state, _S1418);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_12)
{
    float3  _S1419 = p1_0 - p0_0;
    float3  _S1420 = p2_0 - p0_0;
    float2  _S1421 = uv1_0 - uv0_0;
    float2  _S1422 = uv2_0 - uv0_0;
    float _S1423 = _S1421.x;
    float _S1424 = _S1422.y;
    float _S1425 = _S1421.y;
    float _S1426 = _S1422.x;
    float _S1427 = _S1423 * _S1424 - _S1425 * _S1426;
    float _S1428 = 1.0f / _S1427;
    float3  t_2 = (_S1419 * make_float3 (_S1424) - _S1420 * make_float3 (_S1425)) * make_float3 (_S1428);
    float3  _S1429 = (_S1420 * make_float3 (_S1423) - _S1419 * make_float3 (_S1426)) * make_float3 (_S1428);
    float3  _S1430 = t_2 - n_12 * make_float3 (dot_0(n_12, t_2));
    float3  t_3 = ((((_S1430)) * make_float3(rnorm3df(((_S1430)).x, ((_S1430)).y, ((_S1430)).z))));
    bool _S1431 = (dot_0(cross_0(n_12, t_3), _S1429)) > 0.0f;
    float3  t_4;
    if(_S1431)
    {
        float3  _S1432 = negate_0(t_3);
        t_4 = _S1432;
    }
    else
    {
        t_4 = t_3;
    }
    float3  _S1433 = cross_0(n_12, t_4);
    return makeMatrix<float, 3, 3> (t_4, _S1433, n_12);
}

__device__ float3  tangentToWorldNormalMap(float3  v_4, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_4, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1434 = t1_0 - t0_0;
    float3  _S1435 = t2_2 - t0_0;
    float3  _S1436 = t2_2 - t1_0;
    float _S1437 = (F32_min((length_0(_S1434)), ((F32_min((length_0(_S1435)), (length_0(_S1436)))))));
    float3  _S1438 = make_float3 (distance_5(position_0, t0_0), distance_5(position_0, t1_0), distance_5(position_0, t2_2));
    float3  _S1439 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1440 = dot_0(geometry_n_5, _S1439);
    float3  _S1441 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1442 = dot_0(geometry_n_5, _S1441);
    float3  _S1443 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1444 = acos_0(abs_0(make_float3 (_S1440, _S1442, dot_0(geometry_n_5, _S1443))));
    float3  _S1445 = clamp_1(tan_0(_S1444), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_0(dot_0(_S1438 * _S1445, uvw_0), 0.0f, _S1437 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_15, float3  n_13, BSDFMaterial material_22)
{
    float3  _S1446 = negate_0(dir_15);
    float _S1447 = sign_0(dot_0(n_13, _S1446));
    float3  _S1448 = n_13 * make_float3 (_S1447);
    AnisotropicFrame _S1449 = anisotropicFrame(material_22, _S1448);
    bool _S1450 = (_S1449.alphas.x) > 0.0f;
    if(_S1450)
    {
        float _S1451 = material_22.transmission * (1.0f - material_22.metallic);
        float3  _S1452 = negate_0(_S1448);
        float3  _S1453 = anisotropicLocal(dir_15, _S1449.tangent, _S1452);
        float _S1454 = anisotropicG1(_S1453, _S1449.alphas);
        return make_float3 (_S1451 * _S1454) * material_22.albedo;
    }
    float _S1455 = material_22.transmission * (1.0f - material_22.metallic);
    float _S1456 = material_22.roughness;
    float _S1457 = smithG1(_S1456 * _S1456, (F32_abs((dot_0(n_13, dir_15)))));
    return make_float3 (_S1455 * _S1457) * material_22.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_5, float3  out_dir_3, uint p_5, float w_2, float alpha_20, uint nt_0)
{
    uint _S1458 = p_5 % 4U;
    float _S1459 = w_2 * HAIR_WIDTHS_0[_S1458];
    float _S1460 = (F32_asin((clamp_0(dot_0(out_dir_3, t_5), -1.0f, 1.0f)))) - (F32_asin((clamp_0(dot_0(in_dir_11, t_5), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1458] * alpha_20;
    return ((F32_asinh((_S1460 / _S1459))) / (F32_asinh((3.14159274101257324f / _S1459))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_6, float3  out_dir_4, uint np_0)
{
    float3  _S1461 = worldToTangent(out_dir_4, t_6);
    float3  _S1462 = worldToTangent(in_dir_12, t_6);
    return (F32_frac((((F32_atan2((_S1461.z), (_S1461.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1462.z), (1.17549435082228751e-38f - _S1462.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_7, uint p_6, float row_0, float column_0, float w_3, float alpha_21, uint nt_1, uint np_1)
{
    float3  _S1463 = worldToTangent(in_dir_13, t_7);
    uint _S1464 = p_6 % 4U;
    float _S1465 = w_3 * HAIR_WIDTHS_0[_S1464];
    float _S1466 = (F32_asin((clamp_0(dot_0(in_dir_13, t_7), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1464] * alpha_21 + _S1465 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1465))))));
    float _S1467 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1463.z), (1.17549435082228751e-38f - _S1463.x)));
    float _S1468 = (F32_cos((_S1466)));
    float3  _S1469 = tangentToWorld(make_float3 (_S1468 * (F32_cos((_S1467))), (F32_sin((_S1466))), _S1468 * (F32_sin((_S1467)))), t_7);
    return _S1469;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_14, BSDFMaterial material_23, float coverage_1)
{
    float3  _S1470;
    if((material_23.ior) == 1.0f)
    {
        float3  _S1471 = straightThrough(toward_1, n_14, material_23);
        _S1470 = _S1471;
    }
    else
    {
        _S1470 = make_float3 (0.0f);
    }
    return _S1470 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_10 = r_3;
    float3  _S1472 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_10)->f = _S1472;
    float _S1473 = r_3.jac * shifted_0.jac;
    (&candidate_10)->jac = _S1473;
    offer(sel_3, candidate_10, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S1474 = rgb_to_greyscale((&r_4)->f);
    float _S1475 = sel_4.w_sum / _S1474;
    bool _S1476 = _S1474 > 0.0f;
    float _S1477 = _slang_select(_S1476, _S1475,0.0f);
    (&r_4)->w = _S1477;
    (&r_4)->c = c_1;
    return r_4;
}

static __device__ float interpolate_0(float a_8, float b_11, float t_8)
{
    return a_8 + (b_11 - a_8) * t_8;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S1478 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S1478;
}

__device__ float2  temporalWeights(float c_2, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S1479 = c_2 * p_c_0;
    float _S1480 = c_t_0 * p_t_0;
    return make_float2 (_S1479 / (_S1479 + c_t_0 * g_previous_0), _S1480 / (_S1480 + c_2 * g_current_0));
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

__device__ Shift walk_hook(Domain dom_2, Reservoir r_5, bool replay_2, float scale_3, Selection * sel_5)
{
    Domain _S1481 = dom_2;
    Reservoir _S1482 = r_5;
    Shift _S1483 = walk_0(&_S1481, &_S1482, replay_2, scale_3, sel_5);
    return _S1483;
}

__device__ Shift shift_hook(Domain dom_3, Reservoir r_6)
{
    Domain _S1484 = dom_3;
    Reservoir _S1485 = r_6;
    Shift _S1486 = shift_0(&_S1484, &_S1485);
    return _S1486;
}

#undef Matrix
