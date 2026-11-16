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

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
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

__device__ __forceinline__ float3  misWeighted(float3  throughput_0, float lobe_pdf_0, float pdf_0, bool power_0)
{
    if(power_0)
    {
        float _S413 = lobe_pdf_0 / pdf_0;
        return throughput_0 * make_float3 (lobe_pdf_0) / make_float3 (pdf_0 * (1.0f + _S413 * _S413));
    }
    return throughput_0 * make_float3 (lobe_pdf_0) / make_float3 (lobe_pdf_0 + pdf_0);
}

static __device__ float3  neeLobes_0(float3  in_dir_4, float3  dir_3, float3  n_7, BSDFMaterial * material_9, float eta_i_8, float eta_o_8, bool refracted_2, float pdf_1, bool power_1, uint random_state_4, FixedArray<float3 , 5>  * each_0, uint * reached_0)
{
    float3  _S414 = negate_0(in_dir_4);
    float _S415 = dot_0(n_7, _S414);
    float _S416 = sign_0(_S415);
    float3  _S417 = n_7 * make_float3 (_S416);
    AnisotropicFrame _S418 = anisotropicFrame(*material_9, _S417);
    float _S419 = dot_0(_S417, dir_3);
    float _S420 = material_9->roughness * material_9->roughness;
    float3  _S421 = make_float3 (0.0f);
    *reached_0 = 0U;
    BSDFLobes _S422 = BSDFLobes_x24init_0(0.0f, 0.0f, _S421, _S421, 0.0f, 0.0f, _S421, _S421, 0.0f, 0.0f, 0.0f, 0.0f, _S421, 0.0f, _S421, _S421, make_float2 (0.0f), 0.0f, 0.0f, _S421, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S421);
    BSDFLobes lobe_terms_0 = _S422;
    uint _S423;
    if((F32_abs((material_9->toon.x))) > 0.0f)
    {
        _S423 = 5U;
    }
    else
    {
        _S423 = 4U;
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
        (*each_0)[i_2] = _S421;
        uint i_3 = i_2 + 1U;
        i_2 = i_3;
    }
    uint half_of_0 = 4294967295U;
    float3  ggx_n_1 = _S421;
    i_2 = 0U;
    float3  f_1 = _S421;
    for(;;)
    {
        if(i_2 < _S423)
        {
        }
        else
        {
            break;
        }
        uint _S424;
        if(i_2 == 3U)
        {
            _S424 = 4U;
        }
        else
        {
            if(i_2 == 4U)
            {
                _S424 = 6U;
            }
            else
            {
                _S424 = i_2;
            }
        }
        bool _S425 = _S424 == 0U;
        if(_S425)
        {
        }
        bool _S426;
        if(_S425)
        {
            float _S427 = rgb_to_greyscale(material_9->translucent);
            _S426 = _S427 > 0.0f;
        }
        else
        {
            _S426 = false;
        }
        bool _S428;
        if(_S426)
        {
            float _S429 = dot_0(n_7, dir_3);
            float3  _S430 = negate_0(in_dir_4);
            _S428 = ((_S429 * dot_0(n_7, _S430)) < 0.0f) == refracted_2;
        }
        else
        {
            _S428 = (_S424 == 1U) == refracted_2;
        }
        float3  ggx_n_2;
        if(_S428)
        {
            uint _S431;
            if(_S424 == 6U)
            {
                _S431 = 0U;
            }
            else
            {
                if(_S424 == 4U)
                {
                    _S431 = 2U;
                }
                else
                {
                    _S431 = _S424;
                }
            }
            bool _S432 = _S431 != half_of_0;
            uint half_of_1;
            if(_S432)
            {
                bool _S433 = _S431 == 0U;
                if(_S433)
                {
                    float3  _S434 = sampledHalf(in_dir_4, n_7, *material_9, random_state_4, _S418);
                    ggx_n_2 = _S434;
                }
                else
                {
                    bool _S435 = _S431 == 1U;
                    if(_S435)
                    {
                        float3  _S436 = refractedHalf(in_dir_4, dir_3, n_7, eta_i_8, eta_o_8);
                        ggx_n_2 = _S436;
                    }
                    else
                    {
                        float3  _S437 = reflectedHalf(in_dir_4, dir_3);
                        ggx_n_2 = _S437;
                    }
                }
                float3  _S438 = negate_0(in_dir_4);
                BSDFLobes _S439 = bsdfLobes(in_dir_4, _S438, _S417, ggx_n_2, *material_9, eta_i_8, eta_o_8, _S418);
                lobe_terms_0 = _S439;
                float _S440 = translucentShare(*material_9);
                (&lobe_terms_0)->translucent_share = _S440;
                half_of_1 = _S431;
            }
            else
            {
                ggx_n_2 = ggx_n_1;
                half_of_1 = half_of_0;
            }
            float3  throughput_1;
            float lobe_pdf_1;
            switch(_S424)
            {
            case 0U:
                {
                    float _S441 = diffusePDF(_S419, 0.0f, (F32_abs((_S415))), _S420, lobe_terms_0, eta_i_8, eta_o_8);
                    float3  _S442 = diffuseBSDF(dir_3, _S417, _S420, *material_9, lobe_terms_0);
                    lobe_pdf_1 = _S441;
                    throughput_1 = _S442;
                    break;
                }
            case 1U:
                {
                    float _S443 = refractPDF(_S419, dot_0(dir_3, ggx_n_2), (F32_abs((_S415))), _S420, lobe_terms_0, eta_i_8, eta_o_8);
                    float3  _S444 = refractBSDF(dir_3, _S417, _S420, *material_9, lobe_terms_0);
                    lobe_pdf_1 = _S443;
                    throughput_1 = _S444;
                    break;
                }
            case 4U:
                {
                    float _S445 = sheenVelvetPDF(_S419, 0.0f, (F32_abs((_S415))), _S420, lobe_terms_0, eta_i_8, eta_o_8);
                    float3  _S446 = sheenVelvetBSDF(dir_3, _S417, _S420, *material_9, lobe_terms_0);
                    lobe_pdf_1 = _S445;
                    throughput_1 = _S446;
                    break;
                }
            case 6U:
                {
                    float _S447 = toonPDF(_S419, dot_0(dir_3, (&lobe_terms_0)->toon_axis), (F32_abs((_S415))), _S420, lobe_terms_0, eta_i_8, eta_o_8);
                    float3  _S448 = toonBSDF(dir_3, _S417, _S420, *material_9, lobe_terms_0);
                    lobe_pdf_1 = _S447;
                    throughput_1 = _S448;
                    break;
                }
            default:
                {
                    float _S449 = reflectPDF(_S419, 0.0f, (F32_abs((_S415))), _S420, lobe_terms_0, eta_i_8, eta_o_8);
                    float3  _S450 = reflectBSDF(dir_3, _S417, _S420, *material_9, lobe_terms_0);
                    lobe_pdf_1 = _S449;
                    throughput_1 = _S450;
                    break;
                }
            }
            bool _S451 = lobe_pdf_1 > 0.0f;
            float3  f_2;
            if(_S451)
            {
                float3  _S452 = misWeighted(throughput_1, lobe_pdf_1, pdf_1, power_1);
                (*each_0)[i_2] = _S452;
                uint _S453 = (*reached_0) | (1U << i_2);
                *reached_0 = _S453;
                float3  f_3 = f_1 + (*each_0)[i_2];
                f_2 = f_3;
            }
            else
            {
                f_2 = f_1;
            }
            half_of_0 = half_of_1;
            f_1 = f_2;
        }
        else
        {
            ggx_n_2 = ggx_n_1;
        }
        uint i_4 = i_2 + 1U;
        ggx_n_1 = ggx_n_2;
        i_2 = i_4;
    }
    return f_1;
}

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_5, float3  dir_4, float3  n_8, BSDFMaterial material_10, float eta_i_9, float eta_o_9, bool refracted_3, float pdf_2, bool power_2, uint random_state_5)
{
    uint reached_1 = 0U;
    BSDFMaterial _S454 = material_10;
    FixedArray<float3 , 5>  each_1;
    float3  _S455 = neeLobes_0(in_dir_5, dir_4, n_8, &_S454, eta_i_9, eta_o_9, refracted_3, pdf_2, power_2, random_state_5, &each_1, &reached_1);
    return _S455;
}

__device__ float3  skyBSDF(float3  in_dir_6, float3  dir_5, FKSurface surface_1, float2  eta_1, bool is_inside_2, float pdf_3, uint random_state_6)
{
    bool _S456 = wrongSide_0(is_inside_2, false, dir_5, surface_1.geometry_n);
    float3  _S457 = neeBSDF(in_dir_6, dir_5, surface_1.smooth_n, surface_1.material, eta_1.x, eta_1.y, _S456, pdf_3, false, random_state_6);
    return _S457;
}

static __device__ bool all_0(bool3  x_9)
{
    bool result_1 = true;
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
        if(result_1)
        {
            result_1 = (bool((_slang_vector_get_element(x_9, i_5))));
        }
        else
        {
            result_1 = false;
        }
        i_5 = i_5 + int(1);
    }
    return result_1;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_6, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S458;
    (&_S458)->dir = dir_6;
    (&_S458)->radiance = radiance_0;
    (&_S458)->color = color_0;
    (&_S458)->random_state = random_state_7;
    return _S458;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S459 = (fcptEnvironmentCdfSize());
    uint2  _S460 = make_uint2 (1U, 0U);
    uint2  _S461 = _S459 - _S460;
    Random _S462 = pcg(init_random_state_0);
    Random _S463 = pcg(_S462.state);
    Random _S464 = pcg(_S463.state);
    Random _S465 = pcg(_S464.state);
    uint _S466 = _S461.x;
    uint _S467 = searchCDF_0(make_uint2 (_S466, 0U), make_uint2 (0U, 1U), _S461.y, _S462.value);
    uint _S468 = searchCDF_0(make_uint2 (0U, _S467), _S460, _S466, _S463.value);
    float2  _S469 = make_float2 ((float)_S461.x, (float)_S461.y);
    float2  _S470 = (make_float2 (float(_S468), float(_S467)) + make_float2 (_S464.value, _S465.value)) / _S469 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S471 = _S470.y;
    float _S472 = (F32_sin((_S471)));
    float _S473 = _S470.x;
    float3  _S474 = make_float3 (- _S472 * (F32_cos((_S473))), _S472 * (F32_sin((_S473))), (F32_cos((_S471))));
    float _S475 = environmentPdf_0(_S474);
    float3  _S476 = skyBSDF(ray_0->unit_direction, _S474, *surface_2, eta_2, is_inside_3, _S475, lobe_state_0);
    bool _S477 = !(_S475 > 0.0f);
    bool _S478;
    if(_S477)
    {
        _S478 = true;
    }
    else
    {
        _S478 = all_0(_S476 == make_float3 (0.0f));
    }
    if(_S478)
    {
        float3  _S479 = make_float3 (0.0f);
        return SkySample_x24init_0(_S474, _S479, _S479, _S465.state);
    }
    float3  _S480 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S474, context_2, _S465.state);
    return SkySample_x24init_0(_S474, _S480, _S476 * _S480, _S465.state);
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

static __device__ float3  hairLight_0(FKSurface * surface_3, float3  in_dir_7, TreeSample * light_1, bool competing_0)
{
    SampleBSDF _S481 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S482 = _S481.throughput * make_float3 (_S481.pdf);
    float _S483 = light_1->density;
    float _S484 = 1.0f + _S481.pdf * _S481.pdf / (light_1->density * light_1->density);
    bool _S485;
    if(competing_0)
    {
        _S485 = _S483 > 0.0f;
    }
    else
    {
        _S485 = false;
    }
    float _S486 = _slang_select(_S485, _S484,1.0f);
    return _S482 / make_float3 (_S486) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_7, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S487;
    (&_S487)->dir = dir_7;
    (&_S487)->radiance = radiance_1;
    (&_S487)->density = density_0;
    (&_S487)->random_state = random_state_8;
    return _S487;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_3, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S488 = importance(first_1, p_3, normal_3);
    float _S489 = importance(second_1, p_3, normal_3);
    float2  _S490 = make_float2 (_S488, _S489);
    bool _S491 = _S488 == 0.0f;
    bool _S492;
    if(_S491)
    {
        _S492 = _S489 == 0.0f;
    }
    else
    {
        _S492 = false;
    }
    if(_S492)
    {
        return 2U;
    }
    float _S493 = _S488 + _S489;
    bool _S494 = _S489 > 0.0f;
    if(_S494)
    {
        _S492 = (*pick_0 * _S493) >= _S488;
    }
    else
    {
        _S492 = false;
    }
    uint _S495 = uint(_S492);
    float _S496 = (F32_min(((*pick_0 * _S493 - float(_S495) * _S488) / _slang_vector_get_element(_S490, _S495)), (0.99999994039535522f)));
    *pick_0 = _S496;
    float _S497 = *probability_3 * (_slang_vector_get_element(_S490, _S495) / _S493);
    *probability_3 = _S497;
    return _S495;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_4, float u1_0, float u2_0)
{
    float3  _S498 = center_1 - p_4;
    float _S499 = radius_1 * radius_1 / dot_0(_S498, _S498);
    float _S500 = u1_0 * _S499 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S499), (0.0f)))))));
    float _S501 = 2.0f * u1_0;
    bool _S502 = _S499 >= 1.0f;
    float _S503 = _slang_select(_S502, _S501,_S500);
    float _S504 = (F32_sqrt(((F32_max((_S503 * (2.0f - _S503)), (0.0f))))));
    float _S505 = 6.28318548202514648f * u2_0;
    float3  _S506 = make_float3 (_S504 * (F32_cos((_S505))), 1.0f - _S503, _S504 * (F32_sin((_S505))));
    float3  _S507 = ((((_S498)) * make_float3(rnorm3df(((_S498)).x, ((_S498)).y, ((_S498)).z))));
    float3  _S508 = tangentToWorld(_S506, _S507);
    return _S508;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S509 = center_2 - ray_1->origin;
    float _S510 = dot_0(_S509, ray_1->unit_direction);
    float _S511 = dot_0(_S509, _S509) - _S510 * _S510;
    float _S512 = radius_3 * radius_3;
    bool _S513 = _S511 > _S512;
    if(_S513)
    {
        return 4.294967296e+09f;
    }
    float _S514 = (F32_sqrt((_S512 - _S511)));
    float _S515 = _S510 - _S514;
    float _S516 = _S510 + _S514;
    bool _S517 = _S515 > 0.0000152587890625f;
    bool _S518;
    if(_S517)
    {
        _S518 = _S515 < max_len_0;
    }
    else
    {
        _S518 = false;
    }
    if(_S518)
    {
        return _S515;
    }
    bool _S519 = _S516 > 0.0000152587890625f;
    if(_S519)
    {
        _S518 = _S516 < max_len_0;
    }
    else
    {
        _S518 = false;
    }
    if(_S518)
    {
        return _S516;
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
        int i_6 = int(0);
        float sum_0 = 0.0f;
        for(;;)
        {
            if(i_6 < int(3))
            {
            }
            else
            {
                break;
            }
            float sum_1 = sum_0 + _slang_vector_get_element(left_1, i_6) * _slang_vector_get_element(right_1.rows[i_6], j_1);
            i_6 = i_6 + int(1);
            sum_0 = sum_1;
        }
        *_slang_vector_get_element_ptr(&result_2, j_1) = sum_0;
        j_1 = j_1 + int(1);
    }
    return result_2;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S520 = pcg(init_random_state_1);
    Random _S521 = pcg(_S520.state);
    Random _S522 = pcg(_S521.state);
    float3  _S523 = make_float3 (0.0f);
    TreeSample _S524 = TreeSample_x24init_0(_S523, _S523, 0.0f, _S522.state);
    TreeSample sample_0 = _S524;
    float3  _S525 = _slang_select(sided_0, _S523,smooth_n_2);
    float3  _S526 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S520.value;
    float probability_4 = 1.0f;
    uint n_9 = 0U;
    for(;;)
    {
        uint4  _S527 = (fcptLightNode((n_9)));
        if((_S527.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S528 = (fcptLightSecond((n_9)));
        uint _S529 = n_9 + 1U;
        LightNode _S530 = (fcptLightBounds((_S529)));
        LightNode _S531 = (fcptLightBounds((_S528)));
        uint _S532 = pickChild(_S530, _S531, origin_4, _S525, &pick_1, &probability_4);
        bool _S533 = _S532 > 1U;
        if(_S533)
        {
            return sample_0;
        }
        bool _S534 = _S532 == 1U;
        uint _S535 = _slang_select(_S534, _S528,_S529);
        n_9 = _S535;
    }
    bool _S536 = n_9 == 0U;
    bool _S537;
    if(_S536)
    {
        LightNode _S538 = (fcptLightBounds((0U)));
        float _S539 = importance(_S538, origin_4, _S525);
        _S537 = !(_S539 > 0.0f);
    }
    else
    {
        _S537 = false;
    }
    if(_S537)
    {
        return sample_0;
    }
    uint4  _S540 = (fcptLightNode((n_9)));
    FKHit _S541 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S542 = (_S540.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S542)
    {
        FKLight _S543 = (fcptLight((_S540.y)));
        if(sided_0)
        {
            float _S544 = sign_0(dot_0(geometry_n_1, _S543.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S544);
            float3  _S545 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S545;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S526;
            lift_n_0 = smooth_n_2;
        }
        bool _S546 = (_S543.variance) == 0.0f;
        if(_S546)
        {
            float3  _S547 = _S543.position - emitter_point_0;
            float3  _S548 = ((((_S547)) * make_float3(rnorm3df(((_S547)).x, ((_S547)).y, ((_S547)).z))));
            (&sample_0)->dir = _S548;
            float3  _S549 = _S543.color * make_float3 (_S543.intensity) / make_float3 (dot_0(_S547, _S547) * probability_4);
            (&sample_0)->radiance = _S549;
            shadow_1 = _S547;
        }
        else
        {
            float3  _S550 = sampleSphere(_S543.position, _S543.variance, emitter_point_0, _S521.value, _S522.value);
            (&sample_0)->dir = _S550;
            float _S551 = sphereDensity(_S543.position, _S543.variance, emitter_point_0);
            float _S552 = probability_4 * _S551;
            (&sample_0)->density = _S552;
            float3  _S553 = pointLightRadiance(_S543.color, _S543.intensity, _S543.variance);
            float3  _S554 = _S553 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S554;
            FKRay _S555 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S556 = raySphere_0(_S543.position, _S543.variance, &_S555, 4.294967296e+09f);
            float3  _S557 = (&sample_0)->dir * make_float3 (_S556);
            shadow_1 = _S557;
        }
        emitter_0 = _S541;
        emitter_point_0 = _S523;
    }
    else
    {
        uint _S558 = _S540.y;
        uint _S559 = (fcptTriangleOffset((_S558)));
        uint _S560 = _S559 + _S540.z;
        Matrix<float, 3, 3>  _S561 = (fcptWorldTriangle((_S558), (_S560)));
        float _S562 = (F32_sqrt((_S521.value)));
        float2  _S563 = make_float2 (_S562 * (1.0f - _S522.value), _S562 * _S522.value);
        float3  _S564 = mul_0(make_float3 (1.0f - _S562, _S563.x, _S563.y), _S561);
        if(sided_0)
        {
            float _S565 = sign_0(dot_0(geometry_n_1, _S564 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S565);
            float3  _S566 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S566;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S567 = !((dot_0(smooth_n_2, _S564 - origin_4)) > 0.0f);
            if(_S567)
            {
                return sample_0;
            }
            emitter_point_0 = _S526;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S563, _S558, _S560, 0U, 0.0f);
        float3  _S568 = _S564 - emitter_point_0;
        float3  _S569 = ((((_S568)) * make_float3(rnorm3df(((_S568)).x, ((_S568)).y, ((_S568)).z))));
        (&sample_0)->dir = _S569;
        float _S570 = solidAngle(probability_4, cross_0(_S561.rows[int(1)] - _S561.rows[int(0)], _S561.rows[int(2)] - _S561.rows[int(0)]), _S568);
        (&sample_0)->density = _S570;
        bool _S571 = (fcptShadowFirst());
        bool _S572 = !_S571;
        if(_S572)
        {
            FKSurface _S573 = (fcptLightSurfaceAt((emitter_1), (_S564), (_S522.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S564 - origin_4))));
            (&sample_0)->random_state = _S573.random_state;
            float3  _S574 = _slang_select(_S573.skip, _S523,_S573.material.emissive);
            float3  _S575 = _S574 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S575;
        }
        shadow_1 = _S568;
        emitter_0 = emitter_1;
        emitter_point_0 = _S564;
    }
    FKHit _S576 = emitter_0;
    float3  _S577 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S522.state, &_S576);
    bool _S578 = (fcptShadowFirst());
    if(_S578)
    {
        _S537 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S537 = false;
    }
    if(_S537)
    {
        _S537 = !all_0(_S577 == _S523);
    }
    else
    {
        _S537 = false;
    }
    if(_S537)
    {
        FKSurface _S579 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S522.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S579.random_state;
        float3  _S580 = _slang_select(_S579.skip, _S523,_S579.material.emissive);
        float3  _S581 = _S580 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S581;
    }
    float3  _S582 = (&sample_0)->radiance * _S577;
    bool _S583 = all_0(_S577 == _S523);
    float3  _S584 = _slang_select(_S583, _S523,_S582);
    (&sample_0)->radiance = _S584;
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
    float _S585 = 1.0f / (1.0f + b_2 / a_6 * (b_2 / a_6));
    bool _S586 = b_2 > 0.0f;
    float _S587 = _slang_select(_S586, _S585,1.0f);
    return _S587;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_0, float3  light_point_1)
{
    bool _S588 = vertex_0->none;
    if(_S588)
    {
        return 1.0f;
    }
    uint _S589 = (fcptLightSlot((*hit_0)));
    float _S590 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S589, light_point_1);
    float _S591 = powerHeuristic(vertex_0->pdf, _S590);
    return _S591;
}

static __device__ float3  environment_0(float3  dir_8, uint depth_0, uint lobe_0)
{
    uint2  _S592 = (fcptEnvironmentMapSize());
    bool _S593 = (_S592.x) > 1U;
    bool _S594;
    if(_S593)
    {
        uint2  _S595 = (fcptEnvironmentMapSize());
        _S594 = (_S595.y) > 1U;
    }
    else
    {
        _S594 = false;
    }
    if(_S594)
    {
        float3  _S596 = (fcptEnvMapSample((dir_8), (depth_0), (lobe_0)));
        return _S596;
    }
    float3  _S597 = (fcptAmbient());
    return _S597;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S598 = (fcptEnvironmentCdfSize());
    bool _S599 = (_S598.x) > 1U;
    bool _S600;
    if(_S599)
    {
        uint2  _S601 = (fcptEnvironmentCdfSize());
        _S600 = (_S601.y) > 1U;
    }
    else
    {
        _S600 = false;
    }
    bool _S602 = !_S600;
    if(_S602)
    {
        return false;
    }
    uint2  _S603 = (fcptEnvironmentMapSize());
    bool _S604 = (_S603.x) > 1U;
    if(_S604)
    {
        uint2  _S605 = (fcptEnvironmentMapSize());
        _S600 = (_S605.y) > 1U;
    }
    else
    {
        _S600 = false;
    }
    return _S600;
}

static __device__ float escapeWeight_0(float pdf_4, float3  dir_9)
{
    bool _S606 = pdf_4 <= 0.0f;
    bool _S607;
    if(_S606)
    {
        _S607 = true;
    }
    else
    {
        bool _S608 = environmentMapped_0();
        _S607 = !_S608;
    }
    if(_S607)
    {
        return 1.0f;
    }
    float _S609 = environmentPdf_0(dir_9);
    return pdf_4 / (pdf_4 + _S609);
}

static __device__ float3  min_1(float3  x_10, float3  y_3)
{
    float3  result_3;
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
        *_slang_vector_get_element_ptr(&result_3, i_7) = (F32_min((_slang_vector_get_element(x_10, i_7)), (_slang_vector_get_element(y_3, i_7))));
        i_7 = i_7 + int(1);
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
    Shift _S610;
    (&_S610)->f = f_4;
    (&_S610)->jac = jac_0;
    return _S610;
}

static __device__ uint extractBits_0(uint e_1, uint offset_0, uint count_1)
{
    return (e_1 >> offset_0) & ((1U << count_1) - 1U);
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_5, float3  origin_5, float3  smooth_n_3, float3  start_2)
{
    NEEVertex _S611;
    (&_S611)->none = none_0;
    (&_S611)->pdf = pdf_5;
    (&_S611)->origin = origin_5;
    (&_S611)->smooth_n = smooth_n_3;
    (&_S611)->start = start_2;
    return _S611;
}

struct Vertex
{
    bool rough;
    uint lobe;
    float pdf;
    float cos;
    bool inside;
};

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_1, float pdf_6, float cos_0, bool inside_0)
{
    Vertex _S612;
    (&_S612)->rough = rough_0;
    (&_S612)->lobe = lobe_1;
    (&_S612)->pdf = pdf_6;
    (&_S612)->cos = cos_0;
    (&_S612)->inside = inside_0;
    return _S612;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S613 = hash(index_0);
    uint _S614 = hash(seed_0 ^ _S613);
    return _S614;
}

static __device__ float freeFlight_0(float u_1, float sigma_0)
{
    return - (F32_log((1.0f - u_1))) / sigma_0;
}

static __device__ float3  exp_0(float3  x_11)
{
    float3  result_4;
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
        *_slang_vector_get_element_ptr(&result_4, i_8) = (F32_exp((_slang_vector_get_element(x_11, i_8))));
        i_8 = i_8 + int(1);
    }
    return result_4;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_1, float distance_1, bool scatters_0)
{
    float3  _S615 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_1));
    float3  _S616 = scatter_0 * _S615 / make_float3 (sigma_1);
    float3  _S617 = _slang_select(scatters_0, _S616,_S615);
    return _S617;
}

static __device__ bool scatterSampled_0(bool replay_0, uint b_3, uint stop_0, bool varying_0)
{
    bool _S618 = !replay_0;
    bool _S619;
    if(_S618)
    {
        _S619 = true;
    }
    else
    {
        bool _S620 = b_3 == stop_0;
        if(_S620)
        {
            _S619 = !varying_0;
        }
        else
        {
            _S619 = false;
        }
    }
    return _S619;
}

static __device__ uint arrivalLobe_0(uint b_4, uint prev_lobe_0)
{
    bool _S621 = b_4 > 0U;
    uint _S622 = _slang_select(_S621, prev_lobe_0,3U);
    return _S622;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_4, float length_2, float width_0, FKHit * own_0, bool fiber_0)
{
    ShadowContext _S623;
    (&_S623)->extinction_behind = extinction_behind_0;
    (&_S623)->extinction_front = extinction_front_0;
    (&_S623)->fillings = fillings_0;
    (&_S623)->side = side_0;
    (&_S623)->depth = depth_1;
    (&_S623)->lobe = lobe_2;
    (&_S623)->surface = surface_4;
    (&_S623)->length = length_2;
    (&_S623)->width = width_0;
    (&_S623)->own = *own_0;
    (&_S623)->fiber = fiber_0;
    return _S623;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S624 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S624)
    {
        return 0.07957746833562851f;
    }
    float _S625 = g_0 * g_0;
    return (1.0f - _S625) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S625 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_7, float3  b_5)
{
    float3  _S626 = a_7 / b_5;
    float3  _S627 = make_float3 (0.0f);
    bool3  _S628 = b_5 == _S627;
    float3  _S629 = _slang_select(_S628, _S627,_S626);
    return _S629;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S630 = (1U << count_2) - 1U;
    return (e_2 & (~(_S630 << offset_1))) | ((newbits_0 & _S630) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_0, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_0 = r_0;
    uint _S631 = insertBits_0(r_0.path, end_0, 0U, 5U);
    uint _S632 = insertBits_0(_S631, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S632;
    (&candidate_0)->f = f_5;
    return candidate_0;
}

__device__ void offer(Selection * sel_0, Reservoir candidate_1, float3  weight_0)
{
    float _S633 = rgb_to_greyscale(weight_0);
    bool _S634 = _S633 > 0.0f;
    bool _S635;
    if(_S634)
    {
        _S635 = _S633 < 3.00000000549775576e+38f;
    }
    else
    {
        _S635 = false;
    }
    bool _S636 = !_S635;
    if(_S636)
    {
        return;
    }
    bool _S637 = sel_0->sums;
    if(_S637)
    {
        float3  _S638 = sel_0->color + weight_0;
        sel_0->color = _S638;
        return;
    }
    float _S639 = sel_0->w_sum + _S633;
    sel_0->w_sum = _S639;
    float3  _S640 = sel_0->color + weight_0;
    sel_0->color = _S640;
    Random _S641 = pcg(sel_0->random_state);
    sel_0->random_state = _S641.state;
    bool _S642 = (_S641.value * sel_0->w_sum) <= _S633;
    if(_S642)
    {
        sel_0->r = candidate_1;
    }
    return;
}

__device__ float survivalProbability(float3  throughput_2, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_2.x), ((F32_max((throughput_2.y), (throughput_2.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S643 = pcg(random_state_9);
    Random _S644 = pcg(_S643.state);
    float _S645 = 1.0f - 2.0f * _S643.value;
    float _S646 = (F32_sqrt(((F32_max((1.0f - _S645 * _S645), (0.0f))))));
    float _S647 = 6.28318548202514648f * _S644.value;
    return make_float3 (_S646 * (F32_cos((_S647))), _S646 * (F32_sin((_S647))), _S645);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_10, uint random_state_10, float * pdf_7)
{
    bool _S648 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S648)
    {
        *pdf_7 = 0.07957746833562851f;
        float3  _S649 = isotropic_0(random_state_10);
        return _S649;
    }
    Random _S650 = pcg(random_state_10);
    Random _S651 = pcg(_S650.state);
    float _S652 = g_1 * g_1;
    float _S653 = 2.0f * g_1;
    float _S654 = (1.0f - _S652) / (1.0f - g_1 + _S653 * _S650.value);
    float _S655 = clamp_0((1.0f + _S652 - _S654 * _S654) / _S653, -1.0f, 1.0f);
    float _S656 = (F32_sqrt(((F32_max((1.0f - _S655 * _S655), (0.0f))))));
    float _S657 = 6.28318548202514648f * _S651.value;
    float _S658 = phaseHG_0(g_1, _S655);
    *pdf_7 = _S658;
    float3  _S659 = tangentToWorld(make_float3 (_S656 * (F32_cos((_S657))), _S655, _S656 * (F32_sin((_S657)))), dir_10);
    float3  _S660 = ((((_S659)) * make_float3(rnorm3df(((_S659)).x, ((_S659)).y, ((_S659)).z))));
    return _S660;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_2)
{
    BSDFMaterial _S661;
    (&_S661)->albedo = albedo_0;
    (&_S661)->emissive = emissive_0;
    (&_S661)->roughness = roughness_0;
    (&_S661)->metallic = metallic_0;
    (&_S661)->transmission = transmission_0;
    (&_S661)->ior = ior_0;
    (&_S661)->absorption = absorption_0;
    (&_S661)->specular_tint = specular_tint_0;
    (&_S661)->specular_level = specular_level_0;
    (&_S661)->translucent = translucent_0;
    (&_S661)->sheen = sheen_2;
    (&_S661)->sheen_roughness = sheen_roughness_0;
    (&_S661)->anisotropy = anisotropy_0;
    (&_S661)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S661)->tangent = tangent_2;
    (&_S661)->velvet = velvet_0;
    (&_S661)->toon = toon_2;
    return _S661;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S662;
    (&_S662)->scatter = scatter_1;
    (&_S662)->extinction = extinction_1;
    (&_S662)->g = g_2;
    return _S662;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_11, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S663;
    (&_S663)->smooth_n = smooth_n_4;
    (&_S663)->geometry_n = geometry_n_2;
    (&_S663)->geometry_offset = geometry_offset_2;
    (&_S663)->material = *material_11;
    (&_S663)->skip = skip_0;
    (&_S663)->random_state = random_state_11;
    (&_S663)->coverage = coverage_0;
    (&_S663)->encloses = encloses_0;
    (&_S663)->volume = *volume_0;
    (&_S663)->fills = fills_0;
    (&_S663)->hair = hair_0;
    return _S663;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S664 = (&surface_5->material)->emissive;
    float3  _S665 = make_float3 (0.0f);
    bool _S666 = !top_0;
    float3  _S667 = _slang_select(_S666, _S665,_S664);
    (&(&lower_0)->material)->emissive = _S667;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_2)
{
    float _S668 = surface_6->coverage;
    bool _S669 = u_2 < _S668;
    if(_S669)
    {
        return *surface_6;
    }
    float3  _S670 = make_float3 (0.0f);
    float3  _S671 = make_float3 (1.0f);
    BSDFMaterial _S672 = Material_x24init_0(_S670, _S670, 0.0f, 0.0f, 0.0f, 0.0f, _S670, _S671, 1.0f, _S670, _S670, 0.5f, 0.0f, 0.0f, _S670, 0.0f, _S670);
    BSDFMaterial material_12 = _S672;
    (&material_12)->albedo = _S671;
    (&material_12)->emissive = (&surface_6->material)->emissive;
    (&material_12)->transmission = 1.0f;
    (&material_12)->ior = 1.0f;
    (&material_12)->absorption = (&surface_6->material)->absorption;
    FKSurface through_0 = *surface_6;
    (&through_0)->material = material_12;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S673 = transmission_1 > 0.0f;
    bool _S674;
    if(_S673)
    {
        _S674 = true;
    }
    else
    {
        _S674 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S675;
    if(_S674)
    {
        _S675 = 1.0f;
    }
    else
    {
        _S675 = -1.0f;
    }
    return _S675;
}

static __device__ bool arrivesBehind_0(float3  dir_11, float3  n_10)
{
    return (dot_0(dir_11, n_10)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_12)
{
    float3  _S676 = surface_7->geometry_n;
    float _S677 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_12);
    FKSurface faced_0 = *surface_7;
    float3  _S678 = surface_7->smooth_n * make_float3 (_S677);
    (&faced_0)->smooth_n = _S678;
    float3  _S679 = _S676 * make_float3 (_S677);
    (&faced_0)->geometry_n = _S679;
    return faced_0;
}

static __device__ float3  max_0(float3  x_12, float3  y_4)
{
    float3  result_5;
    int i_9 = int(0);
    for(;;)
    {
        if(i_9 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_5, i_9) = (F32_max((_slang_vector_get_element(x_12, i_9)), (_slang_vector_get_element(y_4, i_9))));
        i_9 = i_9 + int(1);
    }
    return result_5;
}

static __device__ float3  log_0(float3  x_13)
{
    float3  result_6;
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
        *_slang_vector_get_element_ptr(&result_6, i_10) = (F32_log((_slang_vector_get_element(x_13, i_10))));
        i_10 = i_10 + int(1);
    }
    return result_6;
}

__device__ float3  beerLambert(float distance_2, float3  absorption_1)
{
    float3  _S680 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_2) * log_0(_S680));
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
    bool _S681;
    if(open_0)
    {
        _S681 = prev_rough_0;
    }
    else
    {
        _S681 = false;
    }
    if(_S681)
    {
        _S681 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S681 = false;
    }
    return _S681;
}

__device__ float2  vertexEta(BSDFMaterial material_13, float n_dot_v_0)
{
    bool _S682 = n_dot_v_0 < 0.0f;
    float _S683 = _slang_select(_S682, material_13.ior,1.0f);
    float _S684 = _slang_select(_S682, 1.0f,material_13.ior);
    return make_float2 (_S683, _S684);
}

__device__ bool neeDecision(BSDFMaterial material_14, float n_dot_v_1, float eta_i_10, float eta_o_10)
{
    float _S685 = fresnel((F32_abs((n_dot_v_1))), eta_i_10, eta_o_10);
    float3  _S686 = mix_0(make_float3 (_S685), material_14.albedo, material_14.metallic);
    float _S687 = rgb_to_greyscale(_S686);
    float _S688 = (F32_max(((1.0f - _S687) * (1.0f - material_14.metallic) * (1.0f - material_14.transmission)), (0.0f)));
    bool _S689 = _S688 > 0.03999999910593033f;
    bool _S690;
    if(_S689)
    {
        _S690 = true;
    }
    else
    {
        _S690 = (material_14.roughness) > 0.20000000298023224f;
    }
    return _S690;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_15)
{
    float _S691 = rgb_to_greyscale(material_15->translucent);
    return _S691 > 0.0f;
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
    MediumSides _S692;
    (&_S692)->behind = *behind_0;
    (&_S692)->front = *front_0;
    (&_S692)->fillings = fillings_1;
    (&_S692)->face = face_1;
    return _S692;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_13, FKMedium * outside_0)
{
    float3  _S693 = surface_8->geometry_n;
    MediumSides _S694 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S694;
    bool _S695 = surface_8->encloses;
    if(_S695)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S696 = (dot_0(dir_13, _S693)) > 0.0f;
        if(_S696)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_14, uint depth_2, uint lobe_3, float length_3, float width_1, FKHit * own_1, bool fiber_1, FKMedium * outside_1)
{
    float3  _S697 = surface_9->geometry_n;
    ShadowContext _S698 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
    bool _S699 = surface_9->encloses;
    ShadowContext context_4;
    if(_S699)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S700 = - _S697;
        float3  _S701 = _slang_select(turned_0, _S700,_S697);
        (&faced_1)->geometry_n = _S701;
        FKMedium _S702 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S703 = faced_1;
        FKMedium _S704 = _S702;
        MediumSides _S705 = mediumSides_0(&_S703, &_S704, filling_1, dir_14, outside_1);
        ShadowContext _S706 = ShadowContext_x24init_0(_S705.behind.extinction, _S705.front.extinction, _S705.fillings, _S697, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
        if(turned_0)
        {
            uint2  _S707 = _S705.fillings;
            ShadowContext _S708 = ShadowContext_x24init_0(_S705.front.extinction, _S705.behind.extinction, uint2 {_S707.y, _S707.x}, _S697, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
            context_4 = _S708;
        }
        else
        {
            context_4 = _S706;
        }
    }
    else
    {
        context_4 = _S698;
    }
    return context_4;
}

static __device__ bool any_0(bool3  x_14)
{
    bool result_7 = false;
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
        if(result_7)
        {
            result_7 = true;
        }
        else
        {
            result_7 = (bool((_slang_vector_get_element(x_14, i_11))));
        }
        i_11 = i_11 + int(1);
    }
    return result_7;
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_8, float3  out_dir_2, float3  n_11, float3  g_n_0, BSDFMaterial material_16, float eta_i_11, float eta_o_11, uint random_state_12)
{
    float3  _S709 = negate_0(in_dir_8);
    float _S710 = dot_0(n_11, _S709);
    float _S711 = sign_0(_S710);
    float3  _S712 = n_11 * make_float3 (_S711);
    AnisotropicFrame _S713 = anisotropicFrame(material_16, _S712);
    float _S714 = dot_0(_S712, out_dir_2);
    float _S715 = material_16.roughness;
    float _S716 = _S715 * _S715;
    bool _S717 = (dot_0(g_n_0, _S709) * dot_0(g_n_0, out_dir_2)) > 0.0f;
    uint _S718;
    if((F32_abs((material_16.toon.x))) > 0.0f)
    {
        _S718 = 1U;
    }
    else
    {
        _S718 = 0U;
    }
    if(_S717)
    {
        _S718 = 3U + _S718;
    }
    else
    {
        _S718 = 1U;
    }
    float3  _S719 = make_float3 (0.0f);
    BSDFLobes _S720 = BSDFLobes_x24init_0(0.0f, 0.0f, _S719, _S719, 0.0f, 0.0f, _S719, _S719, 0.0f, 0.0f, 0.0f, 0.0f, _S719, 0.0f, _S719, _S719, make_float2 (0.0f), 0.0f, 0.0f, _S719, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S719);
    BSDFLobes lobe_terms_1 = _S720;
    uint half_of_2 = 4294967295U;
    float3  ggx_n_3 = _S719;
    float3  f_6 = _S719;
    uint i_12 = 0U;
    for(;;)
    {
        if(i_12 < _S718)
        {
        }
        else
        {
            break;
        }
        uint _S721;
        if(!_S717)
        {
            _S721 = 1U;
        }
        else
        {
            if(i_12 == 0U)
            {
                _S721 = 0U;
            }
            else
            {
                if(i_12 == 1U)
                {
                    _S721 = 2U;
                }
                else
                {
                    if(i_12 == 2U)
                    {
                        _S721 = 4U;
                    }
                    else
                    {
                        _S721 = 6U;
                    }
                }
            }
        }
        uint _S722;
        if(_S721 == 6U)
        {
            _S722 = 0U;
        }
        else
        {
            if(_S721 == 4U)
            {
                _S722 = 2U;
            }
            else
            {
                _S722 = _S721;
            }
        }
        bool _S723 = _S722 != half_of_2;
        float3  ggx_n_4;
        if(_S723)
        {
            bool _S724 = _S722 == 0U;
            if(_S724)
            {
                float3  _S725 = sampledHalf(in_dir_8, n_11, material_16, random_state_12, _S713);
                ggx_n_4 = _S725;
            }
            else
            {
                bool _S726 = _S722 == 1U;
                if(_S726)
                {
                    float3  _S727 = refractedHalf(in_dir_8, out_dir_2, n_11, eta_i_11, eta_o_11);
                    ggx_n_4 = _S727;
                }
                else
                {
                    float3  _S728 = reflectedHalf(in_dir_8, out_dir_2);
                    ggx_n_4 = _S728;
                }
            }
            float3  _S729 = negate_0(in_dir_8);
            BSDFLobes _S730 = bsdfLobes(in_dir_8, _S729, _S712, ggx_n_4, material_16, eta_i_11, eta_o_11, _S713);
            lobe_terms_1 = _S730;
            float _S731 = translucentShare(material_16);
            (&lobe_terms_1)->translucent_share = _S731;
            half_of_2 = _S722;
        }
        else
        {
            ggx_n_4 = ggx_n_3;
        }
        float3  throughput_3;
        float pdf_8;
        switch(_S721)
        {
        case 0U:
            {
                float _S732 = diffusePDF(_S714, 0.0f, (F32_abs((_S710))), _S716, lobe_terms_1, eta_i_11, eta_o_11);
                float3  _S733 = diffuseBSDF(out_dir_2, _S712, _S716, material_16, lobe_terms_1);
                pdf_8 = _S732;
                throughput_3 = _S733;
                break;
            }
        case 1U:
            {
                float _S734 = refractPDF(_S714, dot_0(out_dir_2, ggx_n_4), (F32_abs((_S710))), _S716, lobe_terms_1, eta_i_11, eta_o_11);
                float3  _S735 = refractBSDF(out_dir_2, _S712, _S716, material_16, lobe_terms_1);
                pdf_8 = _S734;
                throughput_3 = _S735;
                break;
            }
        case 4U:
            {
                float _S736 = sheenVelvetPDF(_S714, 0.0f, (F32_abs((_S710))), _S716, lobe_terms_1, eta_i_11, eta_o_11);
                float3  _S737 = sheenVelvetBSDF(out_dir_2, _S712, _S716, material_16, lobe_terms_1);
                pdf_8 = _S736;
                throughput_3 = _S737;
                break;
            }
        case 6U:
            {
                float _S738 = toonPDF(_S714, dot_0(out_dir_2, (&lobe_terms_1)->toon_axis), (F32_abs((_S710))), _S716, lobe_terms_1, eta_i_11, eta_o_11);
                float3  _S739 = toonBSDF(out_dir_2, _S712, _S716, material_16, lobe_terms_1);
                pdf_8 = _S738;
                throughput_3 = _S739;
                break;
            }
        default:
            {
                float _S740 = reflectPDF(_S714, 0.0f, (F32_abs((_S710))), _S716, lobe_terms_1, eta_i_11, eta_o_11);
                float3  _S741 = reflectBSDF(out_dir_2, _S712, _S716, material_16, lobe_terms_1);
                pdf_8 = _S740;
                throughput_3 = _S741;
                break;
            }
        }
        float3  _S742;
        if(pdf_8 > 0.0f)
        {
            _S742 = throughput_3 * make_float3 (pdf_8);
        }
        else
        {
            _S742 = _S719;
        }
        if(i_12 == 0U)
        {
            f_6 = _S742;
        }
        else
        {
            f_6 = f_6 + _S742;
        }
        uint i_13 = i_12 + 1U;
        ggx_n_3 = ggx_n_4;
        i_12 = i_13;
    }
    return f_6;
}

__device__ float3  translucentCorrection(float3  in_dir_9, float3  out_dir_3, float3  n_12, float3  g_n_1, BSDFMaterial material_17, float eta_i_12, float eta_o_12, uint random_state_13)
{
    float _S743 = dot_0(n_12, out_dir_3);
    float3  _S744 = negate_0(in_dir_9);
    bool _S745 = (_S743 * dot_0(n_12, _S744)) < 0.0f;
    float3  _S746 = negate_0(in_dir_9);
    float _S747 = dot_0(n_12, _S746);
    float _S748 = sign_0(_S747);
    float3  _S749 = n_12 * make_float3 (_S748);
    AnisotropicFrame _S750 = anisotropicFrame(material_17, _S749);
    float _S751 = material_17.roughness;
    float _S752 = _S751 * _S751;
    float3  _S753 = negate_0(in_dir_9);
    float3  _S754 = sampledHalf(in_dir_9, n_12, material_17, random_state_13, _S750);
    BSDFLobes _S755 = bsdfLobes(in_dir_9, _S753, _S749, _S754, material_17, eta_i_12, eta_o_12, _S750);
    BSDFLobes sampled_0 = _S755;
    float _S756 = translucentShare(material_17);
    (&sampled_0)->translucent_share = _S756;
    float _S757 = diffusePDF(dot_0(_S749, out_dir_3), 0.0f, (F32_abs((_S747))), _S752, sampled_0, eta_i_12, eta_o_12);
    float3  _S758;
    if(_S757 > 0.0f)
    {
        float3  _S759 = diffuseBSDF(out_dir_3, _S749, _S752, material_17, sampled_0);
        _S758 = _S759 * make_float3 (_S757);
    }
    else
    {
        _S758 = make_float3 (0.0f);
    }
    float3  _S760 = negate_0(in_dir_9);
    bool _S761 = (dot_0(g_n_1, _S760) * dot_0(g_n_1, out_dir_3)) > 0.0f;
    float3  _S762 = make_float3 (0.0f);
    float _S763 = _slang_select(_S761, -1.0f,1.0f);
    float3  _S764 = _S758 * make_float3 (_S763);
    float3  _S765 = _slang_select(_S745, _S764,_S762);
    return _S765;
}

__device__ float3  translucentBSDF(float3  in_dir_10, float3  out_dir_4, float3  n_13, float3  g_n_2, BSDFMaterial material_18, float eta_i_13, float eta_o_13, uint random_state_14)
{
    float3  _S766 = BSDF(in_dir_10, out_dir_4, n_13, g_n_2, material_18, eta_i_13, eta_o_13, random_state_14);
    float3  _S767 = translucentCorrection(in_dir_10, out_dir_4, n_13, g_n_2, material_18, eta_i_13, eta_o_13, random_state_14);
    return _S766 + _S767;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_11, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_19, float eta_i_14, float eta_o_14, bool competing_1, uint random_state_15)
{
    bool _S768 = !competing_1;
    bool _S769;
    if(_S768)
    {
        _S769 = true;
    }
    else
    {
        _S769 = (light_2->density) == 0.0f;
    }
    if(_S769)
    {
        bool _S770 = isTranslucent_0(material_19);
        if(_S770)
        {
            float3  _S771 = translucentBSDF(in_dir_11, light_2->dir, smooth_n_5, geometry_n_4, *material_19, eta_i_14, eta_o_14, random_state_15);
            return _S771 * light_2->radiance;
        }
        float3  _S772 = BSDF(in_dir_11, light_2->dir, smooth_n_5, geometry_n_4, *material_19, eta_i_14, eta_o_14, random_state_15);
        return _S772 * light_2->radiance;
    }
    float3  _S773 = light_2->dir;
    bool _S774 = (dot_0(geometry_n_4, - in_dir_11) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    float3  _S775 = neeBSDF(in_dir_11, _S773, smooth_n_5, *material_19, eta_i_14, eta_o_14, _S774, light_2->density, true, random_state_15);
    return _S775 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_4, uint random_state_16, bool refracted_4, uint lobe_4, float pdf_9)
{
    SampleBSDF _S776;
    (&_S776)->unit_direction = unit_direction_1;
    (&_S776)->throughput = throughput_4;
    (&_S776)->random_state = random_state_16;
    (&_S776)->refracted = refracted_4;
    (&_S776)->lobe = lobe_4;
    (&_S776)->pdf = pdf_9;
    return _S776;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_8, float n_i_dot_v_6, float alpha_15, BSDFMaterial material_20, BSDFLobes lobes_11, float eta_i_15, float eta_o_15, uint random_state_17)
{
    float3  _S777 = make_float3 (1.0f);
    SampleBSDF _S778 = SampleBSDF_x24init_0(_S777, _S777, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S778;
    Random _S779 = pcg(random_state_17);
    Random _S780 = pcg(_S779.state);
    (&sample_1)->random_state = _S780.state;
    float _S781 = _S779.value;
    float _S782 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S781 * _S781))))));
    float _S783 = 6.28318548202514648f * _S780.value;
    float3  _S784 = tangentToWorld(make_float3 (_S782 * (F32_cos((_S783))), _S779.value, _S782 * (F32_sin((_S783)))), n_i_8);
    (&sample_1)->unit_direction = _S784;
    (&sample_1)->lobe = 4U;
    float3  _S785 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_8, alpha_15, material_20, lobes_11);
    (&sample_1)->throughput = _S785;
    float _S786 = sheenVelvetPDF(_S779.value, 0.0f, n_i_dot_v_6, alpha_15, lobes_11, eta_i_15, eta_o_15);
    (&sample_1)->pdf = _S786;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S787 = (F32_sqrt((random_1_0)));
    float _S788 = 6.28318548202514648f * random_2_0;
    float _S789 = _S787 * (F32_cos((_S788)));
    float _S790 = _S787 * (F32_sin((_S788)));
    float _S791 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S789 * _S789 - _S790 * _S790))))));
    return make_float3 (_S789, _S791, _S790);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_9, float n_i_dot_v_7, float alpha_16, BSDFMaterial material_21, BSDFLobes lobes_12, float eta_i_16, float eta_o_16, uint random_state_18)
{
    float3  _S792 = make_float3 (1.0f);
    SampleBSDF _S793 = SampleBSDF_x24init_0(_S792, _S792, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S793;
    Random _S794 = pcg(random_state_18);
    Random _S795 = pcg(_S794.state);
    (&sample_2)->random_state = _S795.state;
    float3  _S796 = sampleCosWeightedHemisphere(_S794.value, _S795.value);
    bool _S797 = u_3 < (lobes_12.p_diffuse * lobes_12.translucent_share);
    float _S798 = _S796.y;
    float _S799 = - _S798;
    float _S800 = _slang_select(_S797, _S799,_S798);
    float3  _S801 = tangentToWorld(make_float3 (_S796.x, _S800, _S796.z), n_i_9);
    (&sample_2)->unit_direction = _S801;
    (&sample_2)->refracted = _S797;
    (&sample_2)->lobe = 0U;
    float3  _S802 = diffuseBSDF((&sample_2)->unit_direction, n_i_9, alpha_16, material_21, lobes_12);
    (&sample_2)->throughput = _S802;
    float _S803 = diffusePDF(_S800, 0.0f, n_i_dot_v_7, alpha_16, lobes_12, eta_i_16, eta_o_16);
    (&sample_2)->pdf = _S803;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_10, float n_i_dot_v_8, float alpha_17, BSDFMaterial material_22, BSDFLobes lobes_13, float eta_i_17, float eta_o_17, uint random_state_19)
{
    float3  _S804 = make_float3 (1.0f);
    SampleBSDF _S805 = SampleBSDF_x24init_0(_S804, _S804, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S805;
    Random _S806 = pcg(random_state_19);
    Random _S807 = pcg(_S806.state);
    (&sample_3)->random_state = _S807.state;
    float _S808 = _S806.value * lobes_13.toon_norm / 6.28318548202514648f;
    float t_1;
    if(lobes_13.toon_glossy)
    {
        t_1 = (F32_acos((clamp_0(1.0f - _S808, -1.0f, 1.0f))));
    }
    else
    {
        t_1 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S808)))), (1.0f))))));
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
        float _S809;
        if(t_1 < (lobes_13.toon_a))
        {
            _S809 = 1.0f;
        }
        else
        {
            _S809 = (F32_max((1.0f - (t_1 - lobes_13.toon_a) / (F32_max((lobes_13.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float integral_1;
        if(lobes_13.toon_glossy)
        {
            integral_1 = 1.0f - (F32_cos(((F32_min((t_1), (lobes_13.toon_a))))));
        }
        else
        {
            float _S810 = (F32_sin(((F32_min((t_1), (lobes_13.toon_a))))));
            integral_1 = _S810 * _S810 / 2.0f;
        }
        bool _S811 = t_1 > (lobes_13.toon_a);
        bool _S812;
        if(_S811)
        {
            _S812 = (lobes_13.toon_s) > 0.0f;
        }
        else
        {
            _S812 = false;
        }
        float integral_2;
        if(_S812)
        {
            if(lobes_13.toon_glossy)
            {
                float _S813 = (F32_cos((lobes_13.toon_a)));
                float _S814 = (F32_cos((t_1)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S813 - _S814) - ((F32_sin((t_1))) - t_1 * _S814 - ((F32_sin((lobes_13.toon_a))) - lobes_13.toon_a * _S813)) / lobes_13.toon_s;
            }
            else
            {
                float _S815 = 2.0f * lobes_13.toon_a;
                float _S816 = (F32_cos((_S815)));
                float _S817 = 2.0f * t_1;
                float _S818 = (F32_cos((_S817)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S816 - _S818) / 4.0f - ((F32_sin((_S817))) / 8.0f - t_1 * _S818 / 4.0f - ((F32_sin((_S815))) / 8.0f - lobes_13.toon_a * _S816 / 4.0f)) / lobes_13.toon_s;
            }
            float integral_3 = integral_1 + integral_2;
            integral_2 = integral_3;
        }
        else
        {
            integral_2 = integral_1;
        }
        float _S819 = _S809 * (F32_sin((t_1)));
        float _S820;
        if(lobes_13.toon_glossy)
        {
            _S820 = 1.0f;
        }
        else
        {
            _S820 = (F32_cos((t_1)));
        }
        float _S821 = _S819 * _S820;
        float _S822 = (integral_2 - _S808) / _S821;
        bool _S823 = _S821 > 0.0f;
        float _S824 = _slang_select(_S823, _S822,0.0f);
        float _S825 = clamp_0(t_1 - _S824, 0.0f, lobes_13.toon_b);
        int k_1 = k_0 + int(1);
        t_1 = _S825;
        k_0 = k_1;
    }
    float _S826 = 6.28318548202514648f * _S807.value;
    float _S827 = (F32_sin((t_1)));
    float3  _S828 = tangentToWorld(make_float3 (_S827 * (F32_cos((_S826))), (F32_cos((t_1))), _S827 * (F32_sin((_S826)))), lobes_13.toon_axis);
    (&sample_3)->unit_direction = _S828;
    bool _S829 = (dot_0(n_i_10, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S829;
    (&sample_3)->lobe = 6U;
    float3  _S830 = toonBSDF((&sample_3)->unit_direction, n_i_10, alpha_17, material_22, lobes_13);
    (&sample_3)->throughput = _S830;
    float _S831 = toonPDF(dot_0(n_i_10, (&sample_3)->unit_direction), dot_0((&sample_3)->unit_direction, lobes_13.toon_axis), n_i_dot_v_8, alpha_17, lobes_13, eta_i_17, eta_o_17);
    (&sample_3)->pdf = _S831;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_5, float3  n_i_11, float n_i_dot_v_9, float alpha_18, BSDFMaterial material_23, BSDFLobes lobes_14, float eta_i_18, float eta_o_18, uint random_state_20)
{
    float3  _S832 = make_float3 (1.0f);
    SampleBSDF _S833 = SampleBSDF_x24init_0(_S832, _S832, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S833;
    (&sample_4)->unit_direction = lobes_14.refracted;
    (&sample_4)->random_state = random_state_20;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S834 = refractBSDF((&sample_4)->unit_direction, n_i_11, alpha_18, material_23, lobes_14);
    (&sample_4)->throughput = _S834;
    float _S835 = refractPDF(0.0f, dot_0((&sample_4)->unit_direction, ggx_n_5), n_i_dot_v_9, alpha_18, lobes_14, eta_i_18, eta_o_18);
    (&sample_4)->pdf = _S835;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_14, float3  n_14)
{
    return i_14 - make_float3 (2.0f * dot_0(n_14, i_14)) * n_14;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_12, float3  ggx_n_6, float3  n_i_12, float n_i_dot_v_10, float alpha_19, BSDFMaterial material_24, BSDFLobes lobes_15, float eta_i_19, float eta_o_19, uint random_state_21)
{
    float3  _S836 = make_float3 (1.0f);
    SampleBSDF _S837 = SampleBSDF_x24init_0(_S836, _S836, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S837;
    float3  _S838 = reflect_0(in_dir_12, ggx_n_6);
    float3  _S839 = ((((_S838)) * make_float3(rnorm3df(((_S838)).x, ((_S838)).y, ((_S838)).z))));
    (&sample_5)->unit_direction = _S839;
    (&sample_5)->random_state = random_state_21;
    (&sample_5)->lobe = 2U;
    float3  _S840 = reflectBSDF((&sample_5)->unit_direction, n_i_12, alpha_19, material_24, lobes_15);
    (&sample_5)->throughput = _S840;
    float _S841 = reflectPDF(0.0f, 0.0f, n_i_dot_v_10, alpha_19, lobes_15, eta_i_19, eta_o_19);
    (&sample_5)->pdf = _S841;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_13, float3  n_15, BSDFMaterial material_25, float eta_i_20, float eta_o_20, uint random_init_0, float2  screen_space_0)
{
    uint random_state_22 = random_init_0;
    float3  _S842 = negate_0(in_dir_13);
    float _S843 = dot_0(n_15, _S842);
    float _S844 = sign_0(_S843);
    float3  n_i_13 = n_15 * make_float3 (_S844);
    float _S845 = (F32_abs((_S843)));
    float _S846 = material_25.roughness;
    float _S847 = _S846 * _S846;
    AnisotropicFrame _S848 = anisotropicFrame(material_25, n_i_13);
    float3  _S849 = sampleHalfVector(_S842, n_i_13, _S847, _S848, &random_state_22);
    BSDFLobes _S850 = bsdfLobes(in_dir_13, _S842, n_i_13, _S849, material_25, eta_i_20, eta_o_20, _S848);
    BSDFLobes lobes_16 = _S850;
    float _S851 = translucentShare(material_25);
    (&lobes_16)->translucent_share = _S851;
    Random _S852 = pcg(random_state_22);
    random_state_22 = _S852.state;
    bool _S853 = (_S852.value) < ((&lobes_16)->p_sheen_velvet);
    if(_S853)
    {
        SampleBSDF _S854 = sheenVelvetSample(n_i_13, _S845, _S847, material_25, lobes_16, eta_i_20, eta_o_20, random_state_22);
        return _S854;
    }
    float _S855 = _S852.value - (&lobes_16)->p_sheen_velvet;
    bool _S856 = _S855 < ((&lobes_16)->p_diffuse);
    if(_S856)
    {
        SampleBSDF _S857 = diffuseSample(_S855, n_i_13, _S845, _S847, material_25, lobes_16, eta_i_20, eta_o_20, random_state_22);
        return _S857;
    }
    bool _S858 = _S855 < ((&lobes_16)->p_diffuse + (&lobes_16)->p_toon);
    if(_S858)
    {
        SampleBSDF _S859 = toonSample(n_i_13, _S845, _S847, material_25, lobes_16, eta_i_20, eta_o_20, random_state_22);
        return _S859;
    }
    float _S860 = (&lobes_16)->p_toon;
    bool _S861 = (_S855 - _S860) < ((&lobes_16)->p_diffuse + (&lobes_16)->p_refract);
    if(_S861)
    {
        SampleBSDF _S862 = refractSample(_S849, n_i_13, _S845, _S847, material_25, lobes_16, eta_i_20, eta_o_20, random_state_22);
        return _S862;
    }
    SampleBSDF _S863 = reflectSample(in_dir_13, _S849, n_i_13, _S845, _S847, material_25, lobes_16, eta_i_20, eta_o_20, random_state_22);
    return _S863;
}

__device__ bool withinInverseFootprint(float pdf_10, bool diffuse_0, float prev_cos_0, float distance_4, float threshold_1)
{
    bool _S864 = pdf_10 > 0.0f;
    bool _S865;
    if(_S864)
    {
        if(diffuse_0)
        {
            _S865 = true;
        }
        else
        {
            _S865 = (pdf_10 * prev_cos_0 / (distance_4 * distance_4) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S865 = false;
    }
    return _S865;
}

__device__ bool roughLobe(float pdf_11, bool diffuse_1, float roughness_1)
{
    bool _S866 = pdf_11 > 0.0f;
    bool _S867;
    if(_S866)
    {
        if(diffuse_1)
        {
            _S867 = true;
        }
        else
        {
            _S867 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S867 = false;
    }
    return _S867;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S868 = layers_0 > 1U;
    bool _S869;
    if(_S868)
    {
        _S869 = refracting_0 != passed_0;
    }
    else
    {
        _S869 = false;
    }
    return _S869;
}

static __device__ float widened_0(float spread_0, float pdf_12, bool delta_0)
{
    float _S870 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_12))))), (3.14159274101257324f)));
    bool _S871 = !delta_0;
    float _S872 = _slang_select(_S871, _S870,0.0f);
    return spread_0 + _S872;
}

static __device__ bool boundsVolume_0(FKSurface * surface_10)
{
    return surface_10->encloses;
}

static __device__ bool leavesInFront_0(float3  face_2, float3  dir_15, float3  g_3)
{
    return ((dot_0(dir_15, g_3)) > 0.0f) == ((dot_0(g_3, face_2)) > 0.0f);
}

static __device__ float distance_5(float3  x_15, float3  y_5)
{
    return length_0(x_15 - y_5);
}

static __device__ Shift walk_0(Domain * dom_0, Reservoir * r_1, bool replay_1, float scale_2, Selection * sel_1)
{
    float spread_1;
    bool turned_1;
    bool is_inside_5;
    bool viewed_0;
    bool _S873;
    float density_2;
    float threshold_2;
    float width_2;
    float sky_pdf_0;
    float geometry_density_2;
    uint b_6;
    uint layer_0;
    float3  throughput_5;
    float3  chain_throughput_0;
    TreeSample light_3;
    int _S874;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_3;
    float sky_pdf_1;
    float spread_3;
    float width_4;
    uint b_7;
    float3  _S875 = make_float3 (0.0f);
    Shift _S876 = Shift_x24init_0(_S875, 0.0f);
    uint _S877 = r_1->path;
    uint _S878 = extractBits_0(r_1->path, 0U, 5U);
    uint _S879 = extractBits_0(_S877, 5U, 5U);
    uint _S880 = extractBits_0(_S877, 10U, 2U);
    uint _S881 = extractBits_0(_S877, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S882 = _S881 >= 3U;
        uint _S883 = _slang_select(_S882, 1U,0U);
        uint _S884 = _S878 + _S883;
        uint _S885 = (fcptMaxBounces());
        passes_0 = _S884 > _S885;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S876;
    }
    uint _S886 = _S879 - 1U;
    bool _S887 = _S881 == 3U;
    uint _S888 = _slang_select(_S887, 1U,0U);
    uint _S889 = _S878 + _S888;
    bool _S890 = _S880 == 0U;
    uint _S891 = _slang_select(_S890, _S889,_S886);
    FKHit _S892 = (fcptReservoirHit((*r_1)));
    float3  _S893 = dom_0->x0;
    float3  _S894 = dom_0->x1 - dom_0->x0;
    float3  _S895 = ((((_S894)) * make_float3(rnorm3df(((_S894)).x, ((_S894)).y, ((_S894)).z))));
    FKRay _S896 = Ray_x24init_0(dom_0->x1, _S895);
    FKRay ray_2 = _S896;
    FKHit hit_1 = dom_0->hit;
    float3  scatter_in_0 = _S875;
    float3  throughput_6 = make_float3 (1.0f);
    float3  weight_1 = throughput_6;
    float3  glowed_0 = _S875;
    float3  extinction_in_0 = _S875;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S897 = dom_0->spread;
    float _S898 = dom_0->width;
    float _S899 = length_0(_S894);
    NEEVertex _S900 = NEEVertex_x24init_0(true, 0.0f, _S875, _S875, _S875);
    NEEVertex nee_vertex_0 = _S900;
    Vertex _S901 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S901;
    Reservoir _S902 = (Reservoir{});
    Reservoir chain_0 = _S902;
    uint _S903 = r_1->seed;
    (&chain_0)->seed = r_1->seed;
    (&ray_2)->origin = _S893;
    (&hit_1)->distance = _S899;
    FKMedium _S904 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_1)->distance), (&filling_2)));
    uint _S905 = filling_2;
    bool _S906 = (fcptVaryingUsed());
    uint _S907 = _slang_select(_S906, _S905,4294967295U);
    filling_2 = _S907;
    scatter_in_0 = _S904.scatter;
    extinction_in_0 = _S904.extinction;
    g_in_0 = _S904.g;
    Reservoir _S908 = chain_0;
    uint _S909 = filling_2;
    for(;;)
    {
        bool _S910 = (fcptVaryingUsed());
        if(_S910)
        {
            passes_0 = _S909 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S911 = (fcptMajorant((_S909)));
            spread_1 = _S911;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S891;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S880 == 1U;
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
            ended_0 = _S876;
            sky_pdf_0 = 0.0f;
            spread_1 = _S897;
            width_2 = _S898;
            density_2 = 1.0f;
            throughput_5 = throughput_6;
            b_6 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S912 = (&prev_0)->rough;
        if(_S912)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S913 = stream(_S903, 384U);
        uint tracking_0 = _S913;
        weight_1 = throughput_6;
        glowed_0 = _S875;
        b_6 = 4294967295U;
        throughput_5 = throughput_6;
        density_2 = 1.0f;
        threshold_2 = _S897;
        width_2 = _S898;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_1)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S874 = int(1);
                break;
            }
            uint _S914 = b_6 + 320U;
            bool _S915 = b_6 == 4294967295U;
            uint _S916 = _slang_select(_S915, 384U,_S914);
            uint _S917 = stream(_S903, _S916);
            Random _S918 = pcg(_S917);
            float _S919 = freeFlight_0(_S918.value, spread_1);
            if(passes_0)
            {
                float3  _S920 = (&ray_2)->origin;
                float3  _S921 = (&ray_2)->unit_direction;
                float _S922 = (&hit_1)->distance;
                uint _S923 = _slang_select(_S915, 0U,b_6);
                uint _S924 = (&prev_0)->lobe;
                uint _S925 = _slang_select(_S915, 3U,_S924);
                float _S926 = (fcptTrackMedium((_S909), (_S920), (_S921), (_S922), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S923), (_S925), (_S915)));
                geometry_density_2 = _S926;
            }
            else
            {
                geometry_density_2 = _S919;
            }
            bool _S927 = !(geometry_density_2 < ((&hit_1)->distance));
            if(_S927)
            {
                _S874 = int(1);
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
                float3  _S928 = throughput_5 * glowed_0 / make_float3 (density_2);
                float3  _S929 = sel_1->glow + _S928;
                sel_1->glow = _S929;
            }
            else
            {
            }
            glowed_0 = _S875;
            uint b_8 = b_6 + 1U;
            float3  _S930 = (&ray_2)->origin + make_float3 (geometry_density_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S930;
            float3  _S931 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, geometry_density_2, true);
            float3  _S932 = weight_1;
            float3  _S933 = _slang_select(passes_0, _S932,_S931);
            float3  throughput_7 = throughput_5 * _S933;
            uint _S934 = stream(_S903, b_8 + 320U);
            tracking_0 = _S934;
            weight_1 = throughput_6;
            float width_5 = width_2 + threshold_2 * geometry_density_2;
            float _S935 = threshold_2 + 3.14159274101257324f;
            bool _S936 = scatterSampled_0(replay_1, b_8, _S891, passes_0);
            TreeSample _S937 = TreeSample_x24init_0(_S875, _S875, 0.0f, 0U);
            if(_S936)
            {
                float3  _S938 = (&ray_2)->origin;
                float3  _S939 = (&ray_2)->unit_direction;
                float3  _S940 = (&ray_2)->unit_direction;
                uint _S941 = stream(_S903, b_8 + 64U);
                float3  _S942 = extinction_in_0;
                float3  _S943 = extinction_in_0;
                uint2  _S944 = make_uint2 (_S909);
                float3  _S945 = (&ray_2)->unit_direction;
                uint _S946 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                FKHit _S947 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S948 = _S947;
                ShadowContext _S949 = ShadowContext_x24init_0(_S942, _S943, _S944, _S945, b_8, _S946, false, geometry_density_2, width_5, &_S948, false);
                ShadowContext _S950 = _S949;
                TreeSample _S951 = sampleLightTree_0(_S938, _S939, _S940, 0.0f, true, _S941, &_S950);
                light_3 = _S951;
            }
            else
            {
                light_3 = _S937;
            }
            float _S952 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S953 = (fcptMaxBounces());
            bool _S954 = b_8 < _S953;
            if(_S954)
            {
                is_inside_5 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_5 = false;
            }
            float _S955 = _slang_select(is_inside_5, _S952,0.0f);
            float3  _S956 = throughput_7 * light_3.radiance;
            float _S957 = powerHeuristic(light_3.density, _S955);
            float3  _S958 = _S956 * make_float3 (_S952 * _S957);
            float3  _S959 = _slang_select(_S936, _S958,_S875);
            if(replay_1)
            {
                viewed_0 = b_8 == _S891;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S960 = _S880 == 2U;
                if(_S960)
                {
                    float _S961 = rgb_to_greyscale(_S959);
                    passes_0 = _S961 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S962 = Shift_x24init_0(_S959, 1.0f);
                    _S874 = int(0);
                    ended_0 = _S962;
                    spread_1 = _S935;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_7;
                    layer_0 = b_8;
                    break;
                }
                _S874 = int(0);
                ended_0 = _S876;
                spread_1 = _S935;
                geometry_density_2 = width_5;
                chain_throughput_0 = throughput_7;
                layer_0 = b_8;
                break;
            }
            bool _S963 = !replay_1;
            if(_S963)
            {
                Reservoir candidate_2 = _S908;
                uint _S964 = extractBits_0(_S908.path, 10U, 2U);
                bool _S965 = _S964 == 1U;
                if(_S965)
                {
                    float3  _S966 = safeDivide(_S959, _S875);
                    (&candidate_2)->radiance = _S966;
                }
                else
                {
                    uint _S967 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                    uint _S968 = insertBits_0(_S967, 2U, 10U, 2U);
                    (&candidate_2)->path = _S968;
                }
                Reservoir _S969 = withEnd(candidate_2, 0U, b_8, _S959);
                offer(sel_1, _S969, _S959 * make_float3 (scale_2) / make_float3 (density_2));
                float _S970 = survivalProbability(throughput_7, density_2);
                uint _S971 = stream(_S903, b_8 + 128U);
                Random _S972 = pcg(_S971);
                bool _S973 = _S970 < (_S972.value);
                if(_S973)
                {
                    _S873 = true;
                }
                else
                {
                    uint _S974 = (fcptMaxBounces());
                    _S873 = b_8 >= _S974;
                }
                if(_S873)
                {
                    _S874 = int(0);
                    ended_0 = _S876;
                    spread_1 = _S935;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_7;
                    layer_0 = b_8;
                    break;
                }
                float _S975 = density_2 * _S970;
                density_2 = _S975;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S976 = stream(_S903, b_8);
            float3  _S977 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S976, &phase_pdf_0);
            (&ray_2)->unit_direction = _S977;
            NEEVertex _S978 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S875, (&ray_2)->origin);
            nee_vertex_0 = _S978;
            Vertex _S979 = scatteredVertex_0(false);
            prev_0 = _S979;
            float _S980 = (&prev_0)->pdf;
            FKRay _S981 = ray_2;
            FKHit _S982 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S983 = (fcptTraverseInstanceBVH((_S981), (true), (4.294967296e+09f), (false), (_S982), (false)));
            hit_1 = _S983;
            b_6 = b_8;
            throughput_5 = throughput_7;
            threshold_2 = _S935;
            width_2 = width_5;
            sky_pdf_0 = _S980;
        }
        if(_S874 != int(1))
        {
            width_2 = geometry_density_2;
            throughput_5 = chain_throughput_0;
            b_6 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S876;
        spread_1 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S984 = b_6 == 4294967295U;
    bool _S985 = ((&hit_1)->instance_index) == 4294967295U;
    if(_S985)
    {
        bool _S986 = !(&nee_vertex_0)->none;
        float _S987 = _slang_select(_S986, sky_pdf_0,0.0f);
        float _S988 = escapeWeight_0(_S987, (&ray_2)->unit_direction);
        float3  _S989 = environment_0((&ray_2)->unit_direction, b_6, (&prev_0)->lobe);
        float3  _S990 = throughput_5 * _S989;
        if(replay_1)
        {
            bool _S991 = b_6 == _S891;
            if(_S991)
            {
                passes_0 = _S880 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S990 * make_float3 (_S988) / make_float3 (r_1->jac), density_2 / r_1->jac);
            }
            if(_S890)
            {
                passes_0 = _S887;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_6 == _S878;
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
                return Shift_x24init_0(_S990 * make_float3 (_S988), 1.0f);
            }
            return _S876;
        }
        Reservoir candidate_3 = chain_0;
        uint _S992 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S993 = _S992 == 1U;
        if(_S993)
        {
            uint _S994 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S995 = _S994 == b_6;
            float _S996 = _slang_select(_S995, 1.0f,_S988);
            float3  _S997 = safeDivide(_S990 * make_float3 (_S996), _S875);
            (&candidate_3)->radiance = _S997;
        }
        else
        {
            bool _S998 = (&prev_0)->rough;
            if(_S998)
            {
                uint _S999 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                uint _S1000 = insertBits_0(_S999, 3U, 10U, 2U);
                uint _S1001 = insertBits_0(_S1000, (&prev_0)->lobe, 15U, 3U);
                bool _S1002 = (&prev_0)->inside;
                uint _S1003 = _slang_select(_S1002, 1U,0U);
                uint _S1004 = insertBits_0(_S1001, _S1003, 22U, 1U);
                (&candidate_3)->path = _S1004;
                (&candidate_3)->jac = (&prev_0)->pdf;
                (&candidate_3)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1005 = _S990 * make_float3 (_S988);
        Reservoir _S1006 = withEnd(candidate_3, 3U, b_6, _S1005);
        offer(sel_1, _S1006, _S1005 * make_float3 (scale_2) / make_float3 (density_2));
        return _S876;
    }
    float3  _S1007 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1007;
    bool _S1008 = (fcptVaryingUsed());
    if(_S1008)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1009 = !replay_1;
        if(_S1009)
        {
            float3  _S1010 = throughput_5 * glowed_0 / make_float3 (density_2);
            float3  _S1011 = sel_1->glow + _S1010;
            sel_1->glow = _S1011;
        }
        float3  _S1012 = throughput_5 * weight_1;
        throughput_5 = _S1012;
    }
    else
    {
        float3  _S1013 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
        float3  _S1014 = throughput_5 * _S1013;
        throughput_5 = _S1014;
    }
    float _S1015 = width_2 + spread_1 * (&hit_1)->distance;
    uint _S1016 = b_6 + 1U;
    b_6 = _S1016;
    layer_0 = 0U;
    width_2 = _S1015;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S875;
    float3  reconnection_0 = _S875;
    viewed_0 = _S984;
    for(;;)
    {
        bool _S1017 = ((&hit_1)->is_point_light) == 1U;
        if(replay_1)
        {
            _S873 = _S880 == 1U;
        }
        else
        {
            _S873 = false;
        }
        bool _S1018;
        if(_S873)
        {
            _S1018 = b_6 == _S879;
        }
        else
        {
            _S1018 = false;
        }
        bool _S1019;
        if(_S1018)
        {
            bool _S1020 = ((&hit_1)->instance_index) != (_S892.instance_index);
            if(_S1020)
            {
                _S1019 = true;
            }
            else
            {
                _S1019 = ((&hit_1)->triangle_index) != (_S892.triangle_index);
            }
        }
        else
        {
            _S1019 = false;
        }
        if(_S1019)
        {
            return _S876;
        }
        FKMedium _S1021 = Medium_x24init_0(_S875, _S875, 0.0f);
        BSDFMaterial _S1022 = Material_x24init_0(_S875, _S875, 0.0f, 0.0f, 0.0f, 0.0f, _S875, throughput_6, 1.0f, _S875, _S875, 0.5f, 0.0f, 0.0f, _S875, 0.0f, _S875);
        FKMedium _S1023 = _S1021;
        FKSurface _S1024 = Surface_x24init_0(_S875, _S875, 0.0f, &_S1022, false, 0U, 1.0f, false, &_S1023, 4294967295U, _S875);
        bool _S1025 = !_S1017;
        bool scatter_2;
        bool is_inside_6;
        float3  throughput_8;
        FKSurface surface_11;
        if(_S1025)
        {
            uint _S1026 = stream(_S903, b_6);
            uint _S1027 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKSurface _S1028 = (fcptSurfaceAtPath((hit_1), ((&ray_2)->origin), (_S1026), (width_2), (layer_0), (b_6), (_S1027), ((&ray_2)->unit_direction)));
            bool _S1029 = !passes_0;
            FKSurface _S1030 = _S1028;
            FKSurface _S1031 = emitting_0(&_S1030, _S1029);
            uint _S1032 = stream(_S903, b_6 + 256U);
            Random _S1033 = pcg(_S1032);
            FKSurface _S1034 = _S1031;
            FKSurface _S1035 = uncovered_0(&_S1034, _S1033.value);
            float _S1036 = facingSign(_S1035.material.transmission, _S1035.geometry_n, (&ray_2)->unit_direction);
            bool _S1037 = _S1036 < 0.0f;
            bool _S1038 = (_S1035.material.transmission) > 0.0f;
            if(_S1038)
            {
                bool _S1039 = arrivesBehind_0((&ray_2)->unit_direction, _S1035.geometry_n);
                scatter_2 = _S1039;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1040 = _S1035;
            FKSurface _S1041 = facingRay_0(&_S1040, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1042 = arrivesBehind_0((&ray_2)->unit_direction, _S1041.geometry_n);
                is_inside_6 = _S1042;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S1043 = beerLambert((&hit_1)->distance, _S1041.material.absorption);
                float3  _S1044 = throughput_5 * _S1043;
                throughput_8 = _S1044;
            }
            else
            {
                throughput_8 = throughput_5;
            }
            bool _S1045 = !_S1041.skip;
            float geometry_density_3 = geometryDensity(_S1041.geometry_n, (&ray_2)->unit_direction, (&hit_1)->distance);
            bool _S1046 = b_6 == _S1016;
            if(_S1046)
            {
                float _S1047 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1047;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1048 = geometry_density_2;
            scatter_2 = _S1045;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1048;
            surface_11 = _S1041;
            turned_1 = _S1037;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_11 = _S1024;
            throughput_8 = throughput_5;
            is_inside_6 = is_inside_5;
        }
        bool _S1049 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1050 = surface_11;
        FKSurface _S1051 = surface_11;
        float _S1052 = dot_0(surface_11.smooth_n, - (&ray_2)->unit_direction);
        float2  _S1053 = vertexEta(_S1050.material, _S1052);
        bool _S1054;
        if(scatter_2)
        {
            bool _S1055 = neeDecision(_S1050.material, _S1052, _S1053.x, _S1053.y);
            _S1054 = _S1055;
        }
        else
        {
            _S1054 = false;
        }
        bool _S1056;
        if(passes_0)
        {
            _S1056 = true;
        }
        else
        {
            _S1056 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1056)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1054;
        }
        bool _S1057 = (fcptHairUsed());
        bool _S1058;
        if(_S1057)
        {
            float3  _S1059 = surface_11.hair;
            _S1058 = (dot_0(_S1059, _S1059)) > 0.0f;
        }
        else
        {
            _S1058 = false;
        }
        bool _S1060;
        if(_S1058)
        {
            _S1060 = true;
        }
        else
        {
            BSDFMaterial _S1061 = _S1050.material;
            bool _S1062 = isTranslucent_0(&_S1061);
            _S1060 = _S1062;
        }
        bool _S1063;
        if(_S1060)
        {
            _S1063 = true;
        }
        else
        {
            bool _S1064 = (_S1050.material.transmission) > 0.0f;
            if(_S1064)
            {
                uint _S1065 = (fcptLayers((hit_1)));
                _S1063 = _S1065 == 1U;
            }
            else
            {
                _S1063 = false;
            }
        }
        float3  emission_0;
        if(_S1017)
        {
            float3  _S1066 = (fcptCalculatePointLightContrib(((&hit_1)->instance_index)));
            emission_0 = _S1066;
        }
        else
        {
            emission_0 = _S1050.material.emissive;
        }
        float _S1067 = rgb_to_greyscale(emission_0);
        bool _S1068 = _S1067 > 0.0f;
        float3  emission_1;
        if(_S1068)
        {
            NEEVertex _S1069 = nee_vertex_0;
            FKHit _S1070 = hit_1;
            float _S1071 = emissionWeight_0(&_S1069, &_S1070, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1071);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1072;
        if(replay_1)
        {
            _S1072 = _S880 == 1U;
        }
        else
        {
            _S1072 = false;
        }
        bool _S1073;
        if(_S1072)
        {
            _S1073 = b_6 > _S879;
        }
        else
        {
            _S1073 = false;
        }
        bool _S1074;
        if(_S1073)
        {
            _S1074 = b_6 == _S878;
        }
        else
        {
            _S1074 = false;
        }
        bool _S1075;
        if(_S1074)
        {
            bool _S1076 = _S881 == 1U;
            if(_S1076)
            {
                _S1075 = true;
            }
            else
            {
                _S1075 = _S881 == 2U;
            }
        }
        else
        {
            _S1075 = false;
        }
        if(_S1075)
        {
            bool _S1077 = _S1017 != (_S881 == 2U);
            if(_S1077)
            {
                return _S876;
            }
            return Shift_x24init_0(throughput_8 * emission_1 / make_float3 (r_1->jac), density_2 / r_1->jac);
        }
        uint _S1078 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1079 = _S1078 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1080 = insertBits_0(0U, b_6, 5U, 5U);
        uint _S1081 = insertBits_0(_S1080, 1U, 10U, 2U);
        uint _S1082 = insertBits_0(_S1081, (&prev_0)->lobe, 15U, 3U);
        bool _S1083 = (&prev_0)->inside;
        uint _S1084 = _slang_select(_S1083, 1U,0U);
        uint _S1085 = insertBits_0(_S1082, _S1084, 22U, 1U);
        (&here_0)->path = _S1085;
        float _S1086 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1086;
        fcptWithReservoirHit((&here_0), (&hit_1));
        bool _S1087;
        if(replay_1)
        {
            _S1087 = _S880 == 1U;
        }
        else
        {
            _S1087 = false;
        }
        bool _S1088;
        if(_S1087)
        {
            _S1088 = b_6 == _S879;
        }
        else
        {
            _S1088 = false;
        }
        bool _S1089 = b_6 == _S891;
        bool _S1090;
        if(_S1089)
        {
            bool _S1091 = !scatter_2;
            if(_S1091)
            {
                _S1090 = true;
            }
            else
            {
                bool _S1092 = _S880 != 1U;
                if(_S1092)
                {
                    _S1090 = _S880 != 3U;
                }
                else
                {
                    _S1090 = false;
                }
            }
        }
        else
        {
            _S1090 = false;
        }
        bool _S1093;
        if(_S1090)
        {
            _S1093 = _S880 == 2U;
        }
        else
        {
            _S1093 = false;
        }
        bool _S1094;
        if(_S1093)
        {
            _S1094 = !_S1049;
        }
        else
        {
            _S1094 = false;
        }
        bool _S1095;
        if(_S1094)
        {
            _S1095 = _S881 != 4U;
        }
        else
        {
            _S1095 = false;
        }
        bool _S1096 = _S879 == _S878;
        bool _S1097;
        if(_S1096)
        {
            _S1097 = _S881 == 0U;
        }
        else
        {
            _S1097 = false;
        }
        bool _S1098;
        if(_S1097)
        {
            _S1098 = ((&hit_1)->instance_index) == (_S892.instance_index);
        }
        else
        {
            _S1098 = false;
        }
        bool _S1099;
        if(_S1098)
        {
            _S1099 = ((&hit_1)->triangle_index) == (_S892.triangle_index);
        }
        else
        {
            _S1099 = false;
        }
        bool _S1100;
        if(_S1099)
        {
            _S1100 = _S1049;
        }
        else
        {
            _S1100 = false;
        }
        bool _S1101 = _slang_select(_S1088, _S1100,_S1095);
        bool _S1102;
        if(nee_0)
        {
            _S1102 = _slang_select(replay_1, _S1101,scatter_2);
        }
        else
        {
            _S1102 = false;
        }
        TreeSample _S1103 = TreeSample_x24init_0(_S875, _S875, 0.0f, 0U);
        uint2  _S1104 = make_uint2 (0U);
        float2  _S1105 = make_float2 (0.0f);
        FKHit _S1106 = Hit_x24init_0(_S1105, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1107 = _S1106;
        ShadowContext _S1108 = ShadowContext_x24init_0(_S875, _S875, _S1104, _S875, 0U, 0U, false, 0.0f, 0.0f, &_S1107, false);
        ShadowContext context_5;
        if(nee_0)
        {
            uint _S1109 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKMedium _S1110 = (fcptOutsideMedium((hit_1)));
            FKSurface _S1111 = surface_11;
            FKHit _S1112 = hit_1;
            FKMedium _S1113 = _S1110;
            ShadowContext _S1114 = shadowContext_0(&_S1111, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_6, _S1109, (&hit_1)->distance, width_2, &_S1112, _S1058, &_S1113);
            context_5 = _S1114;
        }
        else
        {
            context_5 = _S1108;
        }
        float3  throughput_9;
        float3  lit_0;
        if(_S1102)
        {
            float3  _S1115 = (&ray_2)->origin;
            if(_S1058)
            {
                throughput_9 = _S875;
            }
            else
            {
                throughput_9 = _S1051.smooth_n;
            }
            FKSurface _S1116 = surface_11;
            uint _S1117 = stream(_S903, b_6 + 64U);
            ShadowContext _S1118 = context_5;
            TreeSample _S1119 = sampleLightTree_0(_S1115, throughput_9, surface_11.geometry_n, surface_11.geometry_offset, _S1063, _S1117, &_S1118);
            bool _S1120 = any_0((_S1119.radiance) != _S875);
            if(_S1120)
            {
                if(_S1058)
                {
                    uint _S1121 = (fcptMaxBounces());
                    bool _S1122 = b_6 < _S1121;
                    FKSurface _S1123 = surface_11;
                    TreeSample _S1124 = _S1119;
                    float3  _S1125 = hairLight_0(&_S1123, (&ray_2)->unit_direction, &_S1124, _S1122);
                    lit_0 = _S1125;
                }
                else
                {
                    float _S1126 = _S1053.x;
                    float _S1127 = _S1053.y;
                    uint _S1128 = (fcptMaxBounces());
                    bool _S1129 = b_6 < _S1128;
                    TreeSample _S1130 = _S1119;
                    BSDFMaterial _S1131 = _S1050.material;
                    float3  _S1132 = lightBSDF_0((&ray_2)->unit_direction, &_S1130, _S1051.smooth_n, _S1116.geometry_n, &_S1131, _S1126, _S1127, _S1129, surface_11.random_state);
                    lit_0 = _S1132;
                }
            }
            else
            {
                lit_0 = _S875;
            }
            light_3 = _S1119;
        }
        else
        {
            light_3 = _S1103;
            lit_0 = _S875;
        }
        bool viewed_1;
        bool refracted_5;
        bool wrong_side_0;
        bool _S1133;
        bool _S1134;
        float density_4;
        if(_S1088)
        {
            bool _S1135 = !_S1049;
            if(_S1135)
            {
                return _S876;
            }
            float3  throughput_10 = throughput_8 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1096)
            {
                viewed_1 = _S881 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_10 * emission_1 / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            if(_S1096)
            {
                refracted_5 = _S881 == 0U;
            }
            else
            {
                refracted_5 = false;
            }
            if(refracted_5)
            {
                bool _S1136 = !nee_0;
                if(_S1136)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1137 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1137 > 0.0f);
                }
                if(passes_0)
                {
                    return _S876;
                }
                return Shift_x24init_0(throughput_10 * lit_0 / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            if(_S1096)
            {
                wrong_side_0 = _S881 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1138 = !nee_0;
                if(_S1138)
                {
                    return _S876;
                }
                float _S1139 = environmentPdf_0(r_1->dir);
                float3  _S1140 = skyBSDF((&ray_2)->unit_direction, r_1->dir, surface_11, _S1053, is_inside_6, _S1139, surface_11.random_state);
                return Shift_x24init_0(throughput_10 * _S1140 * r_1->radiance / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            uint _S1141 = extractBits_0(_S877, 21U, 1U);
            bool _S1142 = nee_0 != (_S1141 == 1U);
            if(_S1142)
            {
                return _S876;
            }
            throughput_9 = throughput_10;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S1089;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1143 = !scatter_2;
                if(_S1143)
                {
                    refracted_5 = true;
                }
                else
                {
                    bool _S1144 = _S880 != 1U;
                    if(_S1144)
                    {
                        refracted_5 = _S880 != 3U;
                    }
                    else
                    {
                        refracted_5 = false;
                    }
                }
            }
            else
            {
                refracted_5 = false;
            }
            if(refracted_5)
            {
                bool _S1145 = _S880 == 2U;
                if(_S1145)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1049;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S881 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1058)
                    {
                        return _S876;
                    }
                    uint _S1146 = stream(_S903, b_6 + 448U);
                    FKRay _S1147 = ray_2;
                    FKSurface _S1148 = surface_11;
                    ShadowContext _S1149 = context_5;
                    SkySample _S1150 = sampleSky_0(&_S1147, &_S1148, _S1053, is_inside_6, _S1146, surface_11.random_state, &_S1149);
                    return Shift_x24init_0(throughput_8 * _S1150.color, 1.0f);
                }
                if(_S1145)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1049;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1151 = rgb_to_greyscale(light_3.radiance);
                    bool _S1152 = !(_S1151 > 0.0f);
                    if(_S1152)
                    {
                        return _S876;
                    }
                    return Shift_x24init_0(throughput_8 * lit_0, 1.0f);
                }
                if(_S890)
                {
                    passes_0 = _S881 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1017;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_8 * emission_1, 1.0f);
                }
                if(_S890)
                {
                    passes_0 = _S881 == 1U;
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
                    passes_0 = !_S1049;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_8 * emission_1, 1.0f);
                }
                return _S876;
            }
            else
            {
                bool _S1153 = !replay_1;
                if(_S1153)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1154 = b_6 > 0U;
                    if(_S1154)
                    {
                        Reservoir candidate_4 = chain_0;
                        if(_S1079)
                        {
                            float3  _S1155 = safeDivide(throughput_8 * emission_1, chain_throughput_0);
                            (&candidate_4)->radiance = _S1155;
                        }
                        else
                        {
                            if(_S1049)
                            {
                                candidate_4 = here_0;
                            }
                        }
                        float3  _S1156 = throughput_8 * emission_1;
                        Reservoir _S1157 = withEnd(candidate_4, 1U, b_6, _S1156);
                        offer(sel_1, _S1157, _S1156 * make_float3 (scale_2) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1158 = throughput_8 * emission_1;
                        float3  _S1159 = sel_1->glow + _S1158;
                        sel_1->glow = _S1159;
                    }
                    if(nee_0)
                    {
                        float3  _S1160 = throughput_8 * lit_0;
                        Reservoir candidate_5 = chain_0;
                        if(_S1079)
                        {
                            float3  _S1161 = safeDivide(_S1160, chain_throughput_0);
                            (&candidate_5)->radiance = _S1161;
                        }
                        else
                        {
                            if(_S1049)
                            {
                                candidate_5 = here_0;
                                uint _S1162 = insertBits_0((&candidate_5)->path, 1U, 21U, 1U);
                                (&candidate_5)->path = _S1162;
                                (&candidate_5)->dir = light_3.dir;
                                (&candidate_5)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1163 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                                uint _S1164 = insertBits_0(_S1163, 2U, 10U, 2U);
                                (&candidate_5)->path = _S1164;
                            }
                        }
                        Reservoir _S1165 = withEnd(candidate_5, 0U, b_6, _S1160);
                        offer(sel_1, _S1165, _S1160 * make_float3 (scale_2) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1058)
                        {
                            _S1133 = false;
                        }
                        else
                        {
                            bool _S1166 = environmentMapped_0();
                            _S1133 = _S1166;
                        }
                    }
                    else
                    {
                        _S1133 = false;
                    }
                    if(_S1133)
                    {
                        uint _S1167 = (fcptMaxBounces());
                        _S1134 = b_6 < _S1167;
                    }
                    else
                    {
                        _S1134 = false;
                    }
                    if(_S1134)
                    {
                        uint _S1168 = stream(_S903, b_6 + 448U);
                        FKRay _S1169 = ray_2;
                        FKSurface _S1170 = surface_11;
                        ShadowContext _S1171 = context_5;
                        SkySample _S1172 = sampleSky_0(&_S1169, &_S1170, _S1053, is_inside_6, _S1168, surface_11.random_state, &_S1171);
                        float3  _S1173 = throughput_8 * _S1172.color;
                        Reservoir candidate_6 = chain_0;
                        if(_S1079)
                        {
                            float3  _S1174 = safeDivide(_S1173, chain_throughput_0);
                            (&candidate_6)->radiance = _S1174;
                        }
                        else
                        {
                            if(_S1049)
                            {
                                candidate_6 = here_0;
                                uint _S1175 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1175;
                                (&candidate_6)->dir = _S1172.dir;
                                (&candidate_6)->radiance = _S1172.radiance;
                            }
                            else
                            {
                                uint _S1176 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                                uint _S1177 = insertBits_0(_S1176, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1177;
                            }
                        }
                        Reservoir _S1178 = withEnd(candidate_6, 4U, b_6, _S1173);
                        offer(sel_1, _S1178, _S1173 * make_float3 (scale_2) / make_float3 (density_2));
                    }
                }
            }
            throughput_9 = throughput_8;
            density_4 = density_2;
        }
        bool _S1179;
        bool _S1180;
        bool _S1181;
        bool straight_0;
        bool _S1182;
        bool _S1183;
        bool _S1184;
        bool _S1185;
        bool _S1186;
        bool _S1187;
        bool _S1188;
        bool _S1189;
        bool _S1190;
        bool _S1191;
        bool _S1192;
        bool _S1193;
        float density_6;
        float sky_pdf_2;
        float spread_4;
        uint b_9;
        float3  throughput_11;
        float3  throughput_12;
        float3  throughput_13;
        if(scatter_2)
        {
            if(replay_1)
            {
                viewed_1 = _S1089;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1194 = extractBits_0(_S877, 15U, 3U);
            uint _S1195 = extractBits_0(_S877, 18U, 3U);
            uint _S1196 = _slang_select(_S1088, _S1195,_S1194);
            float3  _S1197 = r_1->dir;
            bool refracted_6 = _S1196 == 1U;
            SampleBSDF _S1198 = SampleBSDF_x24init_0(_S875, _S875, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1198;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1199 = extractBits_0(_S877, 22U, 1U);
                bool _S1200 = is_inside_6 != (_S1199 == 1U);
                if(_S1200)
                {
                    return _S876;
                }
                bool _S1201 = _S880 == 1U;
                if(_S1201)
                {
                    float3  _S1202 = (fcptHitPosition((_S892)));
                    throughput_11 = _S1202;
                }
                else
                {
                    throughput_11 = reconnection_0;
                }
                if(refracted_6)
                {
                    refracted_5 = true;
                }
                else
                {
                    BSDFMaterial _S1203 = _S1050.material;
                    bool _S1204 = isTranslucent_0(&_S1203);
                    if(_S1204)
                    {
                        refracted_5 = _S1196 == 0U;
                    }
                    else
                    {
                        refracted_5 = false;
                    }
                    if(refracted_5)
                    {
                        float3  _S1205 = throughput_11 - (&ray_2)->origin;
                        float3  _S1206 = _slang_select(_S1201, _S1205,_S1197);
                        wrong_side_0 = (dot_0(_S1051.smooth_n, _S1206) * _S1052) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_5 = wrong_side_0;
                }
                if(_S1201)
                {
                    float3  _S1207 = (&ray_2)->origin;
                    FKSurface _S1208 = surface_11;
                    float3  _S1209 = - _S1051.smooth_n;
                    bool _S1210 = is_inside_6 != refracted_5;
                    float3  _S1211 = _slang_select(_S1210, _S1209,_S1051.smooth_n);
                    float3  _S1212 = throughput_11 - (_S1207 + make_float3 (_S1208.geometry_offset) * _S1211);
                    float3  _S1213 = ((((_S1212)) * make_float3(rnorm3df(((_S1212)).x, ((_S1212)).y, ((_S1212)).z))));
                    reconnection_1 = _S1213;
                }
                else
                {
                    reconnection_1 = _S1197;
                }
                if(_S1058)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1214 = wrongSide_0(is_inside_6, refracted_5, reconnection_1, surface_11.geometry_n);
                    wrong_side_0 = _S1214;
                }
                if(wrong_side_0)
                {
                    return _S876;
                }
                float3  _S1215 = throughput_11;
                throughput_11 = reconnection_1;
                b_9 = _S1196;
                wrong_side_0 = false;
                reconnection_1 = _S1215;
            }
            else
            {
                bool _S1216 = !_S1088;
                if(_S1216)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1217;
                    if(_S1058)
                    {
                        SampleBSDF _S1218 = (fcptSampleHair((surface_11.hair), (_S1050.material.albedo), (_S1050.material.specular_tint), ((&ray_2)->unit_direction), (surface_11.random_state)));
                        _S1217 = _S1218;
                    }
                    else
                    {
                        SampleBSDF _S1219 = sampleBSDF((&ray_2)->unit_direction, _S1051.smooth_n, _S1050.material, _S1053.x, _S1053.y, surface_11.random_state, _S1105);
                        _S1217 = _S1219;
                    }
                    bsdf_sampled_0 = _S1217;
                    if(_S1058)
                    {
                        refracted_5 = !(((&bsdf_sampled_0)->pdf) > 0.0f);
                    }
                    else
                    {
                        refracted_5 = false;
                    }
                    if(refracted_5)
                    {
                        if(replay_1)
                        {
                            return _S876;
                        }
                        break;
                    }
                    if(_S1058)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1220 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_11.geometry_n);
                        wrong_side_0 = _S1220;
                    }
                    if(wrong_side_0)
                    {
                        _S1133 = (_S1050.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1133 = false;
                    }
                    if(_S1133)
                    {
                        SampleBSDF _S1221 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n, _S1050.material, _S1053.x, _S1053.y, (&bsdf_sampled_0)->random_state, _S1105);
                        (&bsdf_sampled_0)->unit_direction = _S1221.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1221.refracted;
                        (&bsdf_sampled_0)->throughput = _S1221.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1222 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n)) * surface_11.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1222;
                        }
                    }
                    uint _S1223 = (&bsdf_sampled_0)->lobe;
                    float3  _S1224 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1225 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1226 = (&bsdf_sampled_0)->pdf;
                    float _S1227 = _slang_select(wrong_side_0, 0.0f,_S1226);
                    (&lobe_5)->pdf = _S1227;
                    throughput_11 = _S1224;
                    b_9 = _S1223;
                    refracted_5 = _S1225;
                }
                else
                {
                    throughput_11 = _S1197;
                    b_9 = _S1196;
                    wrong_side_0 = false;
                    refracted_5 = refracted_6;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1133 = true;
            }
            else
            {
                _S1133 = _S1088;
            }
            float3  chain_throughput_1;
            if(_S1133)
            {
                if(_S1058)
                {
                    SampleBSDF _S1228 = (fcptConnectHair((surface_11.hair), (_S1050.material.albedo), (_S1050.material.specular_tint), ((&ray_2)->unit_direction), (throughput_11)));
                    lobe_5 = _S1228;
                }
                else
                {
                    float3  _S1229 = (&ray_2)->unit_direction;
                    float _S1230 = sign_0(_S1052);
                    float3  _S1231 = _S1051.smooth_n * make_float3 (_S1230);
                    float _S1232 = dot_0(_S1231, throughput_11);
                    float _S1233 = _S1050.material.roughness;
                    float _S1234 = _S1233 * _S1233;
                    AnisotropicFrame _S1235 = anisotropicFrame(_S1050.material, _S1231);
                    float3  _S1236 = reflectedHalf(_S1229, throughput_11);
                    bool _S1237 = b_9 == 1U;
                    if(_S1237)
                    {
                        float3  _S1238 = refractedHalf(_S1229, throughput_11, _S1051.smooth_n, _S1053.x, _S1053.y);
                        throughput_12 = _S1238;
                    }
                    else
                    {
                        throughput_12 = _S1236;
                    }
                    bool _S1239 = b_9 == 0U;
                    if(_S1239)
                    {
                        _S1134 = true;
                    }
                    else
                    {
                        _S1134 = b_9 == 6U;
                    }
                    if(_S1134)
                    {
                        float3  _S1240 = sampledHalf(_S1229, _S1051.smooth_n, _S1050.material, surface_11.random_state, _S1235);
                        throughput_13 = _S1240;
                    }
                    else
                    {
                        throughput_13 = throughput_12;
                    }
                    float3  _S1241 = negate_0(_S1229);
                    float _S1242 = _S1053.x;
                    float _S1243 = _S1053.y;
                    BSDFLobes _S1244 = bsdfLobes(_S1229, _S1241, _S1231, throughput_13, _S1050.material, _S1242, _S1243, _S1235);
                    BSDFLobes lobe_terms_2 = _S1244;
                    float _S1245 = translucentShare(_S1050.material);
                    (&lobe_terms_2)->translucent_share = _S1245;
                    switch(b_9)
                    {
                    case 0U:
                        {
                            float _S1246 = diffusePDF(_S1232, 0.0f, (F32_abs((_S1052))), _S1234, lobe_terms_2, _S1242, _S1243);
                            float3  _S1247 = diffuseBSDF(throughput_11, _S1231, _S1234, _S1050.material, lobe_terms_2);
                            density_6 = _S1246;
                            chain_throughput_1 = _S1247;
                            break;
                        }
                    case 1U:
                        {
                            float _S1248 = refractPDF(_S1232, dot_0(throughput_11, throughput_13), (F32_abs((_S1052))), _S1234, lobe_terms_2, _S1242, _S1243);
                            float3  _S1249 = refractBSDF(throughput_11, _S1231, _S1234, _S1050.material, lobe_terms_2);
                            density_6 = _S1248;
                            chain_throughput_1 = _S1249;
                            break;
                        }
                    case 4U:
                        {
                            float _S1250 = sheenVelvetPDF(_S1232, 0.0f, (F32_abs((_S1052))), _S1234, lobe_terms_2, _S1242, _S1243);
                            float3  _S1251 = sheenVelvetBSDF(throughput_11, _S1231, _S1234, _S1050.material, lobe_terms_2);
                            density_6 = _S1250;
                            chain_throughput_1 = _S1251;
                            break;
                        }
                    case 6U:
                        {
                            float _S1252 = toonPDF(_S1232, dot_0(throughput_11, (&lobe_terms_2)->toon_axis), (F32_abs((_S1052))), _S1234, lobe_terms_2, _S1242, _S1243);
                            float3  _S1253 = toonBSDF(throughput_11, _S1231, _S1234, _S1050.material, lobe_terms_2);
                            density_6 = _S1252;
                            chain_throughput_1 = _S1253;
                            break;
                        }
                    default:
                        {
                            float _S1254 = reflectPDF(_S1232, 0.0f, (F32_abs((_S1052))), _S1234, lobe_terms_2, _S1242, _S1243);
                            float3  _S1255 = reflectBSDF(throughput_11, _S1231, _S1234, _S1050.material, lobe_terms_2);
                            density_6 = _S1254;
                            chain_throughput_1 = _S1255;
                            break;
                        }
                    }
                    bool _S1256 = density_6 > 0.0f;
                    if(_S1256)
                    {
                        SampleBSDF _S1257 = SampleBSDF_x24init_0(throughput_11, chain_throughput_1, surface_11.random_state, _S1237, b_9, density_6);
                        lobe_5 = _S1257;
                    }
                }
            }
            bool _S1258 = b_9 == 0U;
            if(_S1258)
            {
                _S1134 = true;
            }
            else
            {
                _S1134 = b_9 == 4U;
            }
            if(_S1134)
            {
                _S1179 = true;
            }
            else
            {
                _S1179 = b_9 == 6U;
            }
            if(_S1058)
            {
                _S1180 = false;
            }
            else
            {
                bool _S1259 = !_S1179;
                if(_S1259)
                {
                    bool _S1260 = (_S1050.material.roughness) == 0.0f;
                    if(_S1260)
                    {
                        _S1180 = true;
                    }
                    else
                    {
                        bool _S1261 = b_9 == 1U;
                        if(_S1261)
                        {
                            _S1180 = (_S1053.x) == (_S1053.y);
                        }
                        else
                        {
                            _S1180 = false;
                        }
                    }
                }
                else
                {
                    _S1180 = false;
                }
            }
            bool _S1262 = !_S1058;
            if(_S1262)
            {
                _S1181 = b_9 == 1U;
            }
            else
            {
                _S1181 = false;
            }
            if(_S1181)
            {
                straight_0 = (_S1050.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1182 = _S1262;
            }
            else
            {
                _S1182 = false;
            }
            if(_S1182)
            {
                _S1183 = b_9 == 1U;
            }
            else
            {
                _S1183 = false;
            }
            if(_S1183)
            {
                _S1184 = (_S1053.x) == (_S1053.y);
            }
            else
            {
                _S1184 = false;
            }
            BSDFMaterial _S1263 = _S1050.material;
            bool _S1264 = isTranslucent_0(&_S1263);
            if(_S1264)
            {
                _S1185 = _S1258;
            }
            else
            {
                _S1185 = false;
            }
            if(_S1185)
            {
                _S1186 = (dot_0(throughput_11, surface_11.geometry_n)) < 0.0f;
            }
            else
            {
                _S1186 = false;
            }
            if(nee_0)
            {
                _S1187 = !_S1180;
            }
            else
            {
                _S1187 = false;
            }
            if(_S1187)
            {
                _S1188 = !wrong_side_0;
            }
            else
            {
                _S1188 = false;
            }
            if(_S1188)
            {
                float _S1265 = (&lobe_5)->pdf;
                float3  _S1266 = (&ray_2)->origin;
                float3  _S1267 = _slang_select(_S1063, _S875,_S1051.smooth_n);
                float3  _S1268 = (&ray_2)->origin;
                FKSurface _S1269 = surface_11;
                float3  _S1270 = - _S1051.smooth_n;
                float3  _S1271 = _slang_select(_S1186, _S1270,_S1051.smooth_n);
                NEEVertex _S1272 = NEEVertex_x24init_0(false, _S1265, _S1266, _S1267, _S1268 + make_float3 (_S1269.geometry_offset) * _S1271);
                nee_vertex_0 = _S1272;
            }
            else
            {
                if(_S1058)
                {
                    _S1189 = true;
                }
                else
                {
                    bool _S1273 = b_9 != 1U;
                    if(_S1273)
                    {
                        _S1189 = true;
                    }
                    else
                    {
                        _S1189 = (_S1053.x) != (_S1053.y);
                    }
                }
                if(_S1189)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1274 = withinInverseFootprint((&lobe_5)->pdf, _S1179, (&prev_0)->cos, (&hit_1)->distance, threshold_2);
            bool _S1275 = roughLobe((&lobe_5)->pdf, _S1179, _S1050.material.roughness);
            if(_S1088)
            {
                bool _S1276 = !_S1274;
                if(_S1276)
                {
                    return _S876;
                }
                bool _S1277 = _S881 != 1U;
                if(_S1277)
                {
                    _S1189 = _S881 != 2U;
                }
                else
                {
                    _S1189 = false;
                }
                if(_S1189)
                {
                    float _S1278 = (&lobe_5)->pdf;
                    float _S1279 = _slang_select(nee_0, _S1278,0.0f);
                    float _S1280 = escapeWeight_0(_S1279, _S1197);
                    if(_S1096)
                    {
                        passes_0 = _S887;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1281 = _slang_select(passes_0, _S1280,1.0f);
                    return Shift_x24init_0(throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_1->radiance * make_float3 (_S1281) / make_float3 (r_1->jac), density_4 * (&lobe_5)->pdf / r_1->jac);
                }
                float3  _S1282 = throughput_9 * make_float3 ((&lobe_5)->pdf);
                float _S1283 = density_4 * (&lobe_5)->pdf;
                throughput_12 = _S1282;
                density_6 = _S1283;
            }
            else
            {
                throughput_12 = throughput_9;
                density_6 = density_4;
            }
            uint _S1284 = (fcptLayers((hit_1)));
            bool _S1285 = b_9 == 1U;
            bool _S1286 = passesLayer_0(_S1284, _S1285, passes_0);
            if(viewed_1)
            {
                _S1189 = _S1286;
            }
            else
            {
                _S1189 = false;
            }
            if(_S1189)
            {
                return _S876;
            }
            if(replay_1)
            {
                _S1190 = b_6 <= _S891;
            }
            else
            {
                _S1190 = false;
            }
            if(_S1190)
            {
                _S1191 = _S1049;
            }
            else
            {
                _S1191 = false;
            }
            if(_S1191)
            {
                _S1192 = _S1274;
            }
            else
            {
                _S1192 = false;
            }
            if(_S1192)
            {
                _S1193 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1193 = !_S1275;
                }
                else
                {
                    _S1193 = false;
                }
            }
            if(_S1193)
            {
                return _S876;
            }
            if(viewed_1)
            {
                float3  _S1287 = throughput_12 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1288 = (&lobe_5)->pdf;
                throughput_13 = _S1287;
                sky_pdf_2 = _S1288;
            }
            else
            {
                float3  _S1289 = throughput_12 * max_0((&lobe_5)->throughput, _S875);
                throughput_13 = _S1289;
                sky_pdf_2 = density_6;
            }
            bool _S1290 = !replay_1;
            bool _S1291;
            if(_S1290)
            {
                _S1291 = !_S1079;
            }
            else
            {
                _S1291 = false;
            }
            bool _S1292;
            if(_S1291)
            {
                _S1292 = _S1049;
            }
            else
            {
                _S1292 = false;
            }
            bool _S1293;
            if(_S1292)
            {
                _S1293 = _S1274;
            }
            else
            {
                _S1293 = false;
            }
            if(_S1293)
            {
                chain_0 = here_0;
                uint _S1294 = insertBits_0((&chain_0)->path, b_9, 18U, 3U);
                uint _S1295 = _slang_select(nee_0, 1U,0U);
                uint _S1296 = insertBits_0(_S1294, _S1295, 21U, 1U);
                (&chain_0)->path = _S1296;
                float _S1297 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1297;
                (&chain_0)->dir = throughput_11;
                chain_throughput_1 = throughput_13;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1298 = surface_11;
            Vertex _S1299 = Vertex_x24init_0(_S1275, b_9, (&lobe_5)->pdf, (F32_abs((dot_0(surface_11.geometry_n, throughput_11)))), is_inside_6);
            prev_0 = _S1299;
            float _S1300 = (&lobe_5)->pdf;
            bool _S1301;
            if(_S1285)
            {
                _S1301 = (_S1053.x) == (_S1053.y);
            }
            else
            {
                _S1301 = false;
            }
            float sky_pdf_3 = _slang_select(_S1301, sky_pdf_0,_S1300);
            float _S1302 = _slang_select(_S1058, 0.0f,sky_pdf_3);
            float _S1303 = widened_0(spread_1, (&lobe_5)->pdf, _S1180);
            bool _S1304;
            if(refracted_5)
            {
                _S1304 = !_S1186;
            }
            else
            {
                _S1304 = false;
            }
            bool is_inside_7;
            if(_S1304)
            {
                bool _S1305 = !is_inside_6;
                is_inside_7 = _S1305;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1306 = surface_11;
            bool _S1307 = boundsVolume_0(&_S1306);
            bool _S1308;
            if(_S1307)
            {
                _S1308 = !_S1286;
            }
            else
            {
                _S1308 = false;
            }
            if(_S1308)
            {
                FKSurface faced_2 = surface_11;
                float3  _S1309 = - _S1298.geometry_n;
                float3  _S1310 = _slang_select(turned_1, _S1309,_S1298.geometry_n);
                (&faced_2)->geometry_n = _S1310;
                FKMedium _S1311 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1312 = (fcptOutsideMedium((hit_1)));
                FKSurface _S1313 = faced_2;
                FKMedium _S1314 = _S1311;
                FKMedium _S1315 = _S1312;
                MediumSides _S1316 = mediumSides_0(&_S1313, &_S1314, filling_2, (&ray_2)->unit_direction, &_S1315);
                bool _S1317 = leavesInFront_0((&faced_2)->geometry_n, throughput_11, _S1298.geometry_n);
                float3  _S1318 = _slang_select(_S1317, _S1316.front.scatter,_S1316.behind.scatter);
                scatter_in_0 = _S1318;
                float3  _S1319 = _slang_select(_S1317, _S1316.front.extinction,_S1316.behind.extinction);
                extinction_in_0 = _S1319;
                float _S1320 = _slang_select(_S1317, _S1316.front.g,_S1316.behind.g);
                g_in_0 = _S1320;
                uint _S1321 = _S1316.fillings.x;
                uint _S1322 = _S1316.fillings.y;
                uint _S1323 = _slang_select(_S1317, _S1322,_S1321);
                bool _S1324 = (fcptVaryingUsed());
                uint _S1325 = _slang_select(_S1324, _S1323,4294967295U);
                filling_2 = _S1325;
            }
            (&ray_2)->unit_direction = throughput_11;
            bool _S1326 = !_S1286;
            if(_S1326)
            {
                FKSurface _S1327 = surface_11;
                float _S1328 = _slang_select(straight_0, 0.0f,_S1327.geometry_offset);
                float3  _S1329 = - _S1051.smooth_n;
                bool _S1330 = is_inside_7 != _S1186;
                float3  _S1331 = _slang_select(_S1330, _S1329,_S1051.smooth_n);
                float3  _S1332 = (&ray_2)->origin + make_float3 (_S1328) * _S1331;
                (&ray_2)->origin = _S1332;
            }
            throughput_12 = throughput_13;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1286;
            viewed_1 = _S1184;
            sky_pdf_2 = _S1302;
            spread_4 = _S1303;
            reconnection_0 = reconnection_1;
            is_inside_5 = is_inside_7;
        }
        else
        {
            (&prev_0)->rough = false;
            (&prev_0)->pdf = 0.0f;
            throughput_12 = throughput_9;
            density_6 = density_4;
            passes_0 = false;
            viewed_1 = viewed_0;
            sky_pdf_2 = 0.0f;
            spread_4 = spread_1;
            straight_0 = false;
            is_inside_5 = is_inside_6;
        }
        bool _S1333 = !replay_1;
        float density_7;
        if(_S1333)
        {
            if(_S1017)
            {
                float3  _S1334 = throughput_12 * emission_1;
                Reservoir candidate_7 = chain_0;
                uint _S1335 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1336 = _S1335 == 1U;
                if(_S1336)
                {
                    float3  _S1337 = safeDivide(_S1334, chain_throughput_0);
                    (&candidate_7)->radiance = _S1337;
                }
                Reservoir _S1338 = withEnd(candidate_7, 2U, b_6, _S1334);
                offer(sel_1, _S1338, _S1334 * make_float3 (scale_2) / make_float3 (density_6));
            }
            if(_S1017)
            {
                refracted_5 = true;
            }
            else
            {
                refracted_5 = scatter_2;
            }
            if(refracted_5)
            {
                float _S1339 = survivalProbability(throughput_12, density_6);
                density_7 = _S1339;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1340 = stream(_S903, b_6 + 128U);
            Random _S1341 = pcg(_S1340);
            bool _S1342 = density_7 < (_S1341.value);
            if(_S1342)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1343 = (fcptMaxBounces());
                wrong_side_0 = b_6 >= _S1343;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1344 = density_6 * density_7;
            density_7 = _S1344;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1345 = layer_0 ^ 1U;
        uint _S1346 = _slang_select(passes_0, _S1345,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_1)->distance = 0.0f;
            b_9 = b_6;
            viewed_0 = viewed_1;
            throughput_5 = throughput_12;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_1 = spread_4;
            uint _S1347 = b_9 + 1U;
            b_6 = _S1347;
            layer_0 = _S1346;
            continue;
        }
        FKRay _S1348 = ray_2;
        float _S1349 = distance_5(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_5 = _S1089;
        }
        else
        {
            refracted_5 = false;
        }
        if(refracted_5)
        {
            wrong_side_0 = _S880 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1350 = _slang_select(wrong_side_0, _S1349,4.294967296e+09f);
        bool _S1351 = !_S1058;
        if(straight_0)
        {
            _S1133 = true;
        }
        else
        {
            _S1133 = _S1058;
        }
        FKHit _S1352;
        if(_S1133)
        {
            _S1352 = hit_1;
        }
        else
        {
            _S1352 = _S1106;
        }
        FKHit _S1353 = (fcptTraverseInstanceBVH((_S1348), (_S1025), (_S1350), (_S1351), (_S1352), (viewed_1)));
        hit_1 = _S1353;
        if(replay_1)
        {
            _S1134 = _S1089;
        }
        else
        {
            _S1134 = false;
        }
        if(_S1134)
        {
            _S1179 = _S880 == 1U;
        }
        else
        {
            _S1179 = false;
        }
        if(_S1179)
        {
            _S1180 = ((&hit_1)->instance_index) == (_S892.instance_index);
        }
        else
        {
            _S1180 = false;
        }
        if(_S1180)
        {
            _S1181 = ((&hit_1)->triangle_index) == (_S892.triangle_index);
        }
        else
        {
            _S1181 = false;
        }
        if(_S1181)
        {
            (&hit_1)->uv = _S892.uv;
            float _S1354 = distance_5(reconnection_0, (&ray_2)->origin);
            (&hit_1)->distance = _S1354;
        }
        if(replay_1)
        {
            _S1182 = _S1089;
        }
        else
        {
            _S1182 = false;
        }
        if(_S1182)
        {
            _S1183 = _S880 == 3U;
        }
        else
        {
            _S1183 = false;
        }
        if(_S1183)
        {
            _S1184 = ((&hit_1)->instance_index) != 4294967295U;
        }
        else
        {
            _S1184 = false;
        }
        if(_S1184)
        {
            return _S876;
        }
        Reservoir _S1355 = chain_0;
        uint _S1356 = filling_2;
        for(;;)
        {
            bool _S1357 = (fcptVaryingUsed());
            if(_S1357)
            {
                _S1185 = _S1356 != 4294967295U;
            }
            else
            {
                _S1185 = false;
            }
            float _S1358;
            if(_S1185)
            {
                float _S1359 = (fcptMajorant((_S1356)));
                _S1358 = _S1359;
            }
            else
            {
                _S1358 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1186 = _S1089;
            }
            else
            {
                _S1186 = false;
            }
            if(_S1186)
            {
                _S1187 = _S880 == 1U;
            }
            else
            {
                _S1187 = false;
            }
            if(_S1187)
            {
                _S1188 = _S1358 > 0.0f;
            }
            else
            {
                _S1188 = false;
            }
            if(_S1188)
            {
                ended_0 = _S876;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_3 = width_2;
                density_3 = density_7;
                throughput_13 = throughput_12;
                b_9 = b_6;
                _S1189 = true;
                break;
            }
            bool _S1360 = (&prev_0)->rough;
            if(_S1360)
            {
                _S1189 = !(_S1358 > 0.0f);
            }
            else
            {
                _S1189 = false;
            }
            (&prev_0)->rough = _S1189;
            uint _S1361 = b_6 + 320U;
            bool _S1362 = b_6 == 4294967295U;
            uint _S1363 = _slang_select(_S1362, 384U,_S1361);
            uint _S1364 = stream(_S903, _S1363);
            uint tracking_1 = _S1364;
            weight_1 = throughput_6;
            glowed_0 = _S875;
            b_9 = b_6;
            throughput_13 = throughput_12;
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
                    _S874 = int(2);
                    break;
                }
                uint _S1365 = b_9 + 320U;
                bool _S1366 = b_9 == 4294967295U;
                uint _S1367 = _slang_select(_S1366, 384U,_S1365);
                uint _S1368 = stream(_S903, _S1367);
                Random _S1369 = pcg(_S1368);
                float _S1370 = freeFlight_0(_S1369.value, _S1358);
                if(_S1185)
                {
                    float3  _S1371 = (&ray_2)->origin;
                    float3  _S1372 = (&ray_2)->unit_direction;
                    float _S1373 = (&hit_1)->distance;
                    uint _S1374 = _slang_select(_S1366, 0U,b_9);
                    uint _S1375 = (&prev_0)->lobe;
                    uint _S1376 = _slang_select(_S1366, 3U,_S1375);
                    float _S1377 = (fcptTrackMedium((_S1356), (_S1371), (_S1372), (_S1373), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1374), (_S1376), (_S1366)));
                    spread_3 = _S1377;
                }
                else
                {
                    spread_3 = _S1370;
                }
                bool _S1378 = !(spread_3 < ((&hit_1)->distance));
                if(_S1378)
                {
                    _S874 = int(2);
                    break;
                }
                if(_S1185)
                {
                    _S1190 = _S1333;
                }
                else
                {
                    _S1190 = false;
                }
                if(_S1190)
                {
                    float3  _S1379 = throughput_13 * glowed_0 / make_float3 (density_3);
                    float3  _S1380 = sel_1->glow + _S1379;
                    sel_1->glow = _S1380;
                }
                else
                {
                }
                glowed_0 = _S875;
                uint b_10 = b_9 + 1U;
                float3  _S1381 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1381;
                float3  _S1382 = flightWeight_0(scatter_in_0, extinction_in_0, _S1358, spread_3, true);
                float3  _S1383 = weight_1;
                float3  _S1384 = _slang_select(_S1185, _S1383,_S1382);
                float3  throughput_14 = throughput_13 * _S1384;
                uint _S1385 = stream(_S903, b_10 + 320U);
                tracking_1 = _S1385;
                weight_1 = throughput_6;
                float width_6 = width_3 + spread_2 * spread_3;
                float _S1386 = spread_2 + 3.14159274101257324f;
                bool _S1387 = scatterSampled_0(replay_1, b_10, _S891, _S1185);
                TreeSample light_4;
                if(_S1387)
                {
                    float3  _S1388 = (&ray_2)->origin;
                    float3  _S1389 = (&ray_2)->unit_direction;
                    float3  _S1390 = (&ray_2)->unit_direction;
                    uint _S1391 = stream(_S903, b_10 + 64U);
                    float3  _S1392 = extinction_in_0;
                    float3  _S1393 = extinction_in_0;
                    uint2  _S1394 = make_uint2 (_S1356);
                    float3  _S1395 = (&ray_2)->unit_direction;
                    uint _S1396 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                    FKHit _S1397 = _S1106;
                    ShadowContext _S1398 = ShadowContext_x24init_0(_S1392, _S1393, _S1394, _S1395, b_10, _S1396, false, spread_3, width_6, &_S1397, false);
                    ShadowContext _S1399 = _S1398;
                    TreeSample _S1400 = sampleLightTree_0(_S1388, _S1389, _S1390, 0.0f, true, _S1391, &_S1399);
                    light_4 = _S1400;
                }
                else
                {
                    light_4 = _S1103;
                }
                float _S1401 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1402 = (fcptMaxBounces());
                bool _S1403 = b_10 < _S1402;
                if(_S1403)
                {
                    _S1191 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1191 = false;
                }
                float _S1404 = _slang_select(_S1191, _S1401,0.0f);
                float3  _S1405 = throughput_14 * light_4.radiance;
                float _S1406 = powerHeuristic(light_4.density, _S1404);
                float3  _S1407 = _S1405 * make_float3 (_S1401 * _S1406);
                float3  _S1408 = _slang_select(_S1387, _S1407,_S875);
                if(replay_1)
                {
                    _S1192 = b_10 == _S891;
                }
                else
                {
                    _S1192 = false;
                }
                if(_S1192)
                {
                    bool _S1409 = _S880 == 2U;
                    if(_S1409)
                    {
                        float _S1410 = rgb_to_greyscale(_S1408);
                        _S1193 = _S1410 > 0.0f;
                    }
                    else
                    {
                        _S1193 = false;
                    }
                    if(_S1193)
                    {
                        Shift _S1411 = Shift_x24init_0(_S1408, 1.0f);
                        _S874 = int(1);
                        ended_0 = _S1411;
                        spread_3 = _S1386;
                        width_4 = width_6;
                        throughput_11 = throughput_14;
                        b_7 = b_10;
                        break;
                    }
                    _S874 = int(1);
                    ended_0 = _S876;
                    spread_3 = _S1386;
                    width_4 = width_6;
                    throughput_11 = throughput_14;
                    b_7 = b_10;
                    break;
                }
                if(_S1333)
                {
                    Reservoir candidate_8 = _S1355;
                    uint _S1412 = extractBits_0(_S1355.path, 10U, 2U);
                    bool _S1413 = _S1412 == 1U;
                    if(_S1413)
                    {
                        float3  _S1414 = safeDivide(_S1408, chain_throughput_0);
                        (&candidate_8)->radiance = _S1414;
                    }
                    else
                    {
                        uint _S1415 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                        uint _S1416 = insertBits_0(_S1415, 2U, 10U, 2U);
                        (&candidate_8)->path = _S1416;
                    }
                    Reservoir _S1417 = withEnd(candidate_8, 0U, b_10, _S1408);
                    offer(sel_1, _S1417, _S1408 * make_float3 (scale_2) / make_float3 (density_3));
                    float _S1418 = survivalProbability(throughput_14, density_3);
                    uint _S1419 = stream(_S903, b_10 + 128U);
                    Random _S1420 = pcg(_S1419);
                    bool _S1421 = _S1418 < (_S1420.value);
                    if(_S1421)
                    {
                        _S1193 = true;
                    }
                    else
                    {
                        uint _S1422 = (fcptMaxBounces());
                        _S1193 = b_10 >= _S1422;
                    }
                    if(_S1193)
                    {
                        _S874 = int(1);
                        ended_0 = _S876;
                        spread_3 = _S1386;
                        width_4 = width_6;
                        throughput_11 = throughput_14;
                        b_7 = b_10;
                        break;
                    }
                    float _S1423 = density_3 * _S1418;
                    density_3 = _S1423;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1424 = stream(_S903, b_10);
                float3  _S1425 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1424, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1425;
                NEEVertex _S1426 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S875, (&ray_2)->origin);
                nee_vertex_0 = _S1426;
                Vertex _S1427 = scatteredVertex_0(is_inside_5);
                prev_0 = _S1427;
                float _S1428 = (&prev_0)->pdf;
                FKRay _S1429 = ray_2;
                FKHit _S1430 = (fcptTraverseInstanceBVH((_S1429), (true), (4.294967296e+09f), (false), (_S1106), (false)));
                hit_1 = _S1430;
                b_9 = b_10;
                throughput_13 = throughput_14;
                spread_2 = _S1386;
                width_3 = width_6;
                sky_pdf_1 = _S1428;
            }
            if(_S874 != int(2))
            {
                spread_2 = spread_3;
                width_3 = width_4;
                throughput_13 = throughput_11;
                b_9 = b_7;
                _S1189 = true;
                break;
            }
            ended_0 = _S876;
            _S1189 = false;
            break;
        }
        if(_S1189)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1190 = b_9 == b_6;
        }
        else
        {
            _S1190 = false;
        }
        bool _S1431 = ((&hit_1)->instance_index) == 4294967295U;
        if(_S1431)
        {
            bool _S1432 = !(&nee_vertex_0)->none;
            float _S1433 = _slang_select(_S1432, sky_pdf_1,0.0f);
            float _S1434 = escapeWeight_0(_S1433, (&ray_2)->unit_direction);
            float3  _S1435 = environment_0((&ray_2)->unit_direction, b_9, (&prev_0)->lobe);
            float3  _S1436 = throughput_13 * _S1435;
            if(replay_1)
            {
                bool _S1437 = b_9 == _S891;
                if(_S1437)
                {
                    passes_0 = _S880 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1436 * make_float3 (_S1434) / make_float3 (r_1->jac), density_3 / r_1->jac);
                }
                if(_S890)
                {
                    passes_0 = _S887;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_9 == _S878;
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
                    return Shift_x24init_0(_S1436 * make_float3 (_S1434), 1.0f);
                }
                return _S876;
            }
            Reservoir candidate_9 = chain_0;
            uint _S1438 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1439 = _S1438 == 1U;
            if(_S1439)
            {
                uint _S1440 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1441 = _S1440 == b_9;
                float _S1442 = _slang_select(_S1441, 1.0f,_S1434);
                float3  _S1443 = safeDivide(_S1436 * make_float3 (_S1442), chain_throughput_0);
                (&candidate_9)->radiance = _S1443;
            }
            else
            {
                bool _S1444 = (&prev_0)->rough;
                if(_S1444)
                {
                    uint _S1445 = insertBits_0(0U, b_9 + 1U, 5U, 5U);
                    uint _S1446 = insertBits_0(_S1445, 3U, 10U, 2U);
                    uint _S1447 = insertBits_0(_S1446, (&prev_0)->lobe, 15U, 3U);
                    bool _S1448 = (&prev_0)->inside;
                    uint _S1449 = _slang_select(_S1448, 1U,0U);
                    uint _S1450 = insertBits_0(_S1447, _S1449, 22U, 1U);
                    (&candidate_9)->path = _S1450;
                    (&candidate_9)->jac = (&prev_0)->pdf;
                    (&candidate_9)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1451 = _S1436 * make_float3 (_S1434);
            Reservoir _S1452 = withEnd(candidate_9, 3U, b_9, _S1451);
            offer(sel_1, _S1452, _S1451 * make_float3 (scale_2) / make_float3 (density_3));
            break;
        }
        float3  _S1453 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1453;
        bool _S1454 = (fcptVaryingUsed());
        if(_S1454)
        {
            _S1191 = filling_2 != 4294967295U;
        }
        else
        {
            _S1191 = false;
        }
        if(_S1191)
        {
            if(_S1333)
            {
                float3  _S1455 = throughput_13 * glowed_0 / make_float3 (density_3);
                float3  _S1456 = sel_1->glow + _S1455;
                sel_1->glow = _S1456;
            }
            float3  _S1457 = throughput_13 * weight_1;
            throughput_11 = _S1457;
        }
        else
        {
            float3  _S1458 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
            float3  _S1459 = throughput_13 * _S1458;
            throughput_11 = _S1459;
        }
        float _S1460 = width_3 + spread_2 * (&hit_1)->distance;
        viewed_0 = _S1190;
        width_2 = _S1460;
        throughput_5 = throughput_11;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1347 = b_9 + 1U;
        b_6 = _S1347;
        layer_0 = _S1346;
    }
    return _S876;
}

static __device__ Shift shift_0(Domain * dom_1, Reservoir * r_2)
{
    Selection _S1461 = (Selection{});
    Selection sel_2 = _S1461;
    bool _S1462 = (r_2->w) <= 0.0f;
    if(_S1462)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1463 = walk_0(dom_1, r_2, true, 0.0f, &sel_2);
    return _S1463;
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
    int i_15 = int(0);
    for(;;)
    {
        if(i_15 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_8, i_15) = (F32_tan((_slang_vector_get_element(x_17, i_15))));
        i_15 = i_15 + int(1);
    }
    return result_8;
}

static __device__ float3  acos_0(float3  x_18)
{
    float3  result_9;
    int i_16 = int(0);
    for(;;)
    {
        if(i_16 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_9, i_16) = (F32_acos((_slang_vector_get_element(x_18, i_16))));
        i_16 = i_16 + int(1);
    }
    return result_9;
}

static __device__ float3  abs_0(float3  x_19)
{
    float3  result_10;
    int i_17 = int(0);
    for(;;)
    {
        if(i_17 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_10, i_17) = (F32_abs((_slang_vector_get_element(x_19, i_17))));
        i_17 = i_17 + int(1);
    }
    return result_10;
}

__device__ Random normal_distribution(uint state_4)
{
    Random _S1464 = pcg(state_4);
    Random _S1465 = pcg(_S1464.state);
    float _S1466 = 6.28318548202514648f * _S1464.value;
    float _S1467 = (F32_sqrt((-2.0f * clamp_0((F32_log((_S1465.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1465.state, _S1467 * (F32_cos((_S1466))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S1468;
    (&_S1468)->state = state_5;
    (&_S1468)->value = value_2;
    return _S1468;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S1469 = normal_distribution(state_6);
    Random _S1470 = normal_distribution(_S1469.state);
    Random _S1471 = normal_distribution(_S1470.state);
    float3  _S1472 = make_float3 (_S1469.value, _S1470.value, _S1471.value);
    float3  _S1473 = ((((_S1472)) * make_float3(rnorm3df(((_S1472)).x, ((_S1472)).y, ((_S1472)).z))));
    return RandomSphere_x24init_0(_S1471.state, _S1473);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_16)
{
    float3  _S1474 = p1_0 - p0_0;
    float3  _S1475 = p2_0 - p0_0;
    float2  _S1476 = uv1_0 - uv0_0;
    float2  _S1477 = uv2_0 - uv0_0;
    float _S1478 = _S1476.x;
    float _S1479 = _S1477.y;
    float _S1480 = _S1476.y;
    float _S1481 = _S1477.x;
    float _S1482 = _S1478 * _S1479 - _S1480 * _S1481;
    float _S1483 = 1.0f / _S1482;
    float3  t_2 = (_S1474 * make_float3 (_S1479) - _S1475 * make_float3 (_S1480)) * make_float3 (_S1483);
    float3  _S1484 = (_S1475 * make_float3 (_S1478) - _S1474 * make_float3 (_S1481)) * make_float3 (_S1483);
    float3  _S1485 = t_2 - n_16 * make_float3 (dot_0(n_16, t_2));
    float3  t_3 = ((((_S1485)) * make_float3(rnorm3df(((_S1485)).x, ((_S1485)).y, ((_S1485)).z))));
    bool _S1486 = (dot_0(cross_0(n_16, t_3), _S1484)) > 0.0f;
    float3  t_4;
    if(_S1486)
    {
        float3  _S1487 = negate_0(t_3);
        t_4 = _S1487;
    }
    else
    {
        t_4 = t_3;
    }
    float3  _S1488 = cross_0(n_16, t_4);
    return makeMatrix<float, 3, 3> (t_4, _S1488, n_16);
}

__device__ float3  tangentToWorldNormalMap(float3  v_4, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_4, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1489 = t1_0 - t0_0;
    float3  _S1490 = t2_2 - t0_0;
    float3  _S1491 = t2_2 - t1_0;
    float _S1492 = (F32_min((length_0(_S1489)), ((F32_min((length_0(_S1490)), (length_0(_S1491)))))));
    float3  _S1493 = make_float3 (distance_5(position_0, t0_0), distance_5(position_0, t1_0), distance_5(position_0, t2_2));
    float3  _S1494 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1495 = dot_0(geometry_n_5, _S1494);
    float3  _S1496 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1497 = dot_0(geometry_n_5, _S1496);
    float3  _S1498 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1499 = acos_0(abs_0(make_float3 (_S1495, _S1497, dot_0(geometry_n_5, _S1498))));
    float3  _S1500 = clamp_1(tan_0(_S1499), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_0(dot_0(_S1493 * _S1500, uvw_0), 0.0f, _S1492 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_16, float3  n_17, BSDFMaterial material_26)
{
    float3  _S1501 = negate_0(dir_16);
    float _S1502 = sign_0(dot_0(n_17, _S1501));
    float3  _S1503 = n_17 * make_float3 (_S1502);
    AnisotropicFrame _S1504 = anisotropicFrame(material_26, _S1503);
    bool _S1505 = (_S1504.alphas.x) > 0.0f;
    if(_S1505)
    {
        float _S1506 = material_26.transmission * (1.0f - material_26.metallic);
        float3  _S1507 = negate_0(_S1503);
        float3  _S1508 = anisotropicLocal(dir_16, _S1504.tangent, _S1507);
        float _S1509 = anisotropicG1(_S1508, _S1504.alphas);
        return make_float3 (_S1506 * _S1509) * material_26.albedo;
    }
    float _S1510 = material_26.transmission * (1.0f - material_26.metallic);
    float _S1511 = material_26.roughness;
    float _S1512 = smithG1(_S1511 * _S1511, (F32_abs((dot_0(n_17, dir_16)))));
    return make_float3 (_S1510 * _S1512) * material_26.albedo;
}

__device__ float hairRow(float3  in_dir_14, float3  t_5, float3  out_dir_5, uint p_5, float w_2, float alpha_20, uint nt_0)
{
    uint _S1513 = p_5 % 4U;
    float _S1514 = w_2 * HAIR_WIDTHS_0[_S1513];
    float _S1515 = (F32_asin((clamp_0(dot_0(out_dir_5, t_5), -1.0f, 1.0f)))) - (F32_asin((clamp_0(dot_0(in_dir_14, t_5), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1513] * alpha_20;
    return ((F32_asinh((_S1515 / _S1514))) / (F32_asinh((3.14159274101257324f / _S1514))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_15, float3  t_6, float3  out_dir_6, uint np_0)
{
    float3  _S1516 = worldToTangent(out_dir_6, t_6);
    float3  _S1517 = worldToTangent(in_dir_15, t_6);
    return (F32_frac((((F32_atan2((_S1516.z), (_S1516.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1517.z), (1.17549435082228751e-38f - _S1517.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_16, float3  t_7, uint p_6, float row_0, float column_0, float w_3, float alpha_21, uint nt_1, uint np_1)
{
    float3  _S1518 = worldToTangent(in_dir_16, t_7);
    uint _S1519 = p_6 % 4U;
    float _S1520 = w_3 * HAIR_WIDTHS_0[_S1519];
    float _S1521 = (F32_asin((clamp_0(dot_0(in_dir_16, t_7), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1519] * alpha_21 + _S1520 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1520))))));
    float _S1522 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1518.z), (1.17549435082228751e-38f - _S1518.x)));
    float _S1523 = (F32_cos((_S1521)));
    float3  _S1524 = tangentToWorld(make_float3 (_S1523 * (F32_cos((_S1522))), (F32_sin((_S1521))), _S1523 * (F32_sin((_S1522)))), t_7);
    return _S1524;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_18, BSDFMaterial material_27, float coverage_1)
{
    float3  _S1525;
    if((material_27.ior) == 1.0f)
    {
        float3  _S1526 = straightThrough(toward_1, n_18, material_27);
        _S1525 = _S1526;
    }
    else
    {
        _S1525 = make_float3 (0.0f);
    }
    return _S1525 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_10 = r_3;
    float3  _S1527 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_10)->f = _S1527;
    float _S1528 = r_3.jac * shifted_0.jac;
    (&candidate_10)->jac = _S1528;
    offer(sel_3, candidate_10, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S1529 = rgb_to_greyscale((&r_4)->f);
    float _S1530 = sel_4.w_sum / _S1529;
    bool _S1531 = _S1529 > 0.0f;
    float _S1532 = _slang_select(_S1531, _S1530,0.0f);
    (&r_4)->w = _S1532;
    (&r_4)->c = c_1;
    return r_4;
}

static __device__ float interpolate_0(float a_8, float b_11, float t_8)
{
    return a_8 + (b_11 - a_8) * t_8;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S1533 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S1533;
}

__device__ float2  temporalWeights(float c_2, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S1534 = c_2 * p_c_0;
    float _S1535 = c_t_0 * p_t_0;
    return make_float2 (_S1534 / (_S1534 + c_t_0 * g_previous_0), _S1535 / (_S1535 + c_2 * g_current_0));
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
    Domain _S1536 = dom_2;
    Reservoir _S1537 = r_5;
    Shift _S1538 = walk_0(&_S1536, &_S1537, replay_2, scale_3, sel_5);
    return _S1538;
}

__device__ Shift shift_hook(Domain dom_3, Reservoir r_6)
{
    Domain _S1539 = dom_3;
    Reservoir _S1540 = r_6;
    Shift _S1541 = shift_0(&_S1539, &_S1540);
    return _S1541;
}

#undef Matrix
