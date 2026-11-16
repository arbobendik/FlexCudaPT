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

static __device__ float3  negate_0(float3  x_7)
{
    return - x_7;
}

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
};

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_0, float3  refracted_1, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_0, float3  sheen_0, float p_sheen_velvet_0, float3  view_0, float3  tangent_1, float2  alphas_1, float visible_0)
{
    BSDFLobes _S152;
    (&_S152)->v_dot_h = v_dot_h_0;
    (&_S152)->n_dot_h = n_dot_h_0;
    (&_S152)->refracted = refracted_1;
    (&_S152)->F = F_0;
    (&_S152)->F_greyscale = F_greyscale_0;
    (&_S152)->reflect_weight = reflect_weight_0;
    (&_S152)->diffuse_weight = diffuse_weight_0;
    (&_S152)->refract_weight = refract_weight_0;
    (&_S152)->p_diffuse = p_diffuse_0;
    (&_S152)->p_reflect = p_reflect_0;
    (&_S152)->p_refract = p_refract_0;
    (&_S152)->translucent_share = translucent_share_0;
    (&_S152)->sheen = sheen_0;
    (&_S152)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S152)->view = view_0;
    (&_S152)->tangent = tangent_1;
    (&_S152)->alphas = alphas_1;
    (&_S152)->visible = visible_0;
    return _S152;
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
    float3  _S153 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S154 = ((((_S153)) * make_float3(rnorm3df(((_S153)).x, ((_S153)).y, ((_S153)).z))));
    float _S155 = _S154.x;
    float _S156 = _S154.y;
    float _S157 = _S155 * _S155 + _S156 * _S156;
    float3  _S158;
    if(_S157 > 0.0f)
    {
        float3  _S159 = make_float3 (- _S156, _S155, 0.0f);
        float _S160 = (rsqrtf((_S157)));
        _S158 = _S159 * make_float3 (_S160);
    }
    else
    {
        _S158 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S161 = cross_0(_S154, _S158);
    float _S162 = (F32_sqrt((U1_0)));
    float _S163 = 6.28318548202514648f * U2_0;
    float _S164 = _S162 * (F32_cos((_S163)));
    float t2_0 = _S162 * (F32_sin((_S163)));
    float _S165 = 0.5f * (1.0f + _S154.z);
    float t2_1 = (1.0f - _S165) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S164 * _S164)))))) + _S165 * t2_0;
    float3  _S166 = make_float3 (_S164) * _S158 + make_float3 (t2_1) * _S161;
    float _S167 = unshared_0(_S164);
    float _S168 = unshared_0(_S164);
    float3  _S169 = _S166 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S167 * _S168 - t2_1 * t2_1))))))) * _S154;
    float3  _S170 = make_float3 (alpha_0 * _S169.x, alpha_0 * _S169.y, (F32_max((0.0f), (_S169.z))));
    float3  _S171 = ((((_S170)) * make_float3(rnorm3df(((_S170)).x, ((_S170)).y, ((_S170)).z))));
    return _S171;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
{
    float3  a_2 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S172 = (F32_abs((dot_0(n_3, a_2)))) > 0.9999847412109375f;
    float3  a_3;
    if(_S172)
    {
        float3  _S173 = make_float3 (1.0f, 0.0f, 0.0f);
        a_3 = _S173;
    }
    else
    {
        a_3 = a_2;
    }
    float3  _S174 = cross_0(n_3, a_3);
    float3  _S175 = ((((_S174)) * make_float3(rnorm3df(((_S174)).x, ((_S174)).y, ((_S174)).z))));
    float3  _S176 = cross_0(n_3, _S175);
    return make_float3 (dot_0(v_1, _S175), dot_0(v_1, n_3), dot_0(v_1, _S176));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_2, float3  n_i_1, float alpha_1, AnisotropicFrame frame_0, uint * random_state_1)
{
    Random _S177 = pcg(*random_state_1);
    Random _S178 = pcg(_S177.state);
    *random_state_1 = _S178.state;
    float _S179 = frame_0.alphas.x;
    bool _S180 = _S179 > 0.0f;
    if(_S180)
    {
        float3  _S181 = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        float _S182 = frame_0.alphas.y;
        float3  _S183 = make_float3 (_S179 * _S181.x, _S182 * _S181.y, _S181.z);
        float3  _S184 = ((((_S183)) * make_float3(rnorm3df(((_S183)).x, ((_S183)).y, ((_S183)).z))));
        float3  _S185 = sampleGGXVNDF(_S184, 1.0f, _S177.value, _S178.value);
        float3  _S186 = make_float3 (_S179 * _S185.x, _S182 * _S185.y, _S185.z);
        float3  _S187 = ((((_S186)) * make_float3(rnorm3df(((_S186)).x, ((_S186)).y, ((_S186)).z))));
        return make_float3 (_S187.x) * frame_0.tangent + make_float3 (_S187.y) * cross_0(n_i_1, frame_0.tangent) + make_float3 (_S187.z) * n_i_1;
    }
    float3  _S188 = worldToTangent(v_2, n_i_1);
    float3  _S189 = sampleGGXVNDF(float3 {_S188.x, _S188.z, _S188.y}, alpha_1, _S177.value, _S178.value);
    float3  _S190 = float3 {_S189.x, _S189.z, _S189.y};
    float3  _S191 = tangentToWorld(_S190, n_i_1);
    return _S191;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_4, BSDFMaterial material_1, uint random_state_2, AnisotropicFrame frame_1)
{
    uint state_3 = random_state_2;
    float3  _S192 = negate_0(in_dir_0);
    float _S193 = sign_0(dot_0(n_4, _S192));
    float _S194 = material_1.roughness;
    float3  _S195 = sampleHalfVector(_S192, n_4 * make_float3 (_S193), _S194 * _S194, frame_1, &state_3);
    return _S195;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_5, float eta_i_0, float eta_o_0)
{
    float3  _S196 = negate_0(in_dir_1);
    float3  _S197 = negate_0(make_float3 (eta_i_0) * _S196 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S198 = ((((_S197)) * make_float3(rnorm3df(((_S197)).x, ((_S197)).y, ((_S197)).z))));
    float _S199 = sign_0(dot_0(n_5, _S196));
    float _S200 = sign_0(dot_0(_S197, n_5 * make_float3 (_S199)));
    return _S198 * make_float3 (_S200);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S201 = negate_0(in_dir_2);
    float3  _S202 = _S201 + out_dir_1;
    float3  _S203 = ((((_S202)) * make_float3(rnorm3df(((_S202)).x, ((_S202)).y, ((_S202)).z))));
    return _S203;
}

static __device__ float3  refract_0(float3  i_1, float3  n_6, float eta_0)
{
    float _S204 = dot_0(n_6, i_1);
    float _S205 = 1.0f - eta_0 * eta_0 * (1.0f - _S204 * _S204);
    if(_S205 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_1 - make_float3 (eta_0 * _S204 + (F32_sqrt((_S205)))) * n_6;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S206 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S207 = eta_i_1 / eta_o_1 * _S206;
    bool _S208 = _S207 < 1.0f;
    float kr_0;
    if(_S208)
    {
        float _S209 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S207 * _S207))))));
        float _S210 = eta_o_1 * cos_theta_0;
        float _S211 = eta_i_1 * _S209;
        float _S212 = (_S210 - _S211) / (_S210 + _S211);
        float _S213 = eta_i_1 * cos_theta_0;
        float _S214 = eta_o_1 * _S209;
        float _S215 = (_S213 - _S214) / (_S213 + _S214);
        float _S216 = (_S212 * _S212 + _S215 * _S215) / 2.0f;
        kr_0 = _S216;
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

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_3, float3  n_i_2, float3  ggx_n_0, BSDFMaterial material_2, float eta_i_2, float eta_o_2, AnisotropicFrame frame_2)
{
    float _S224 = dot_0(ggx_n_0, v_3);
    float _S225 = dot_0(n_i_2, ggx_n_0);
    float _S226 = eta_i_2 / eta_o_2;
    float3  _S227 = refract_0(in_dir_3, ggx_n_0, _S226);
    float3  _S228 = ((((_S227)) * make_float3(rnorm3df(((_S227)).x, ((_S227)).y, ((_S227)).z))));
    float _S229 = (F32_min(((F32_sqrt((material_2.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S230 = _S229 * _S229;
    float _S231 = (1.0f + _S229) / (1.0f - _S229);
    float _S232 = (F32_abs((_S224)));
    bool _S233 = eta_i_2 > eta_o_2;
    float sheen_component_0;
    if(_S233)
    {
        sheen_component_0 = _S231;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float visible_1;
    if(_S233)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S231;
    }
    float _S234 = fresnel(_S232, sheen_component_0, visible_1);
    bool _S235 = (eta_i_2 * eta_i_2 * (1.0f - _S224 * _S224)) >= (eta_o_2 * eta_o_2);
    float3  _S236;
    if(_S235)
    {
        _S236 = make_float3 (1.0f);
    }
    else
    {
        float3  _S237 = material_2.specular_tint * make_float3 (_S230);
        _S236 = _S237 + (make_float3 (1.0f) - _S237) * make_float3 (_S234 - _S230) / make_float3 (1.0f - _S230);
    }
    float3  _S238 = make_float3 (1.0f);
    float3  _S239 = make_float3 (0.0f);
    float _S240 = rgb_to_greyscale(material_2.sheen);
    bool _S241 = _S240 > 0.0f;
    float3  scale_0;
    float3  sheen_1;
    float3  view_1;
    if(_S241)
    {
        float _S242 = clamp_0((F32_sqrt(((F32_max((dot_0(n_i_2, v_3)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S243 = (U32_min((uint(_S242)), (22U)));
        float least_0 = (F32_sqrt((0.05000000074505806f)));
        float _S244 = (F32_sqrt((0.10000000149011612f)));
        bool _S245 = (material_2.velvet) > 0.0f;
        float _S246 = _slang_select(_S245, _S244,least_0);
        float _S247 = (clamp_0((F32_sqrt(((F32_max((material_2.sheen_roughness), (0.0f)))))), _S246, 1.0f) - _S246) / (1.0f - _S246) * 23.0f;
        uint _S248 = (U32_min((uint(_S247)), (22U)));
        uint _S249 = _S243 * 24U + _S248;
        float _S250 = _S242 - float(_S243);
        float _S251 = _S247 - float(_S248);
        uint _S252 = _S249 + 24U;
        float a_4 = SHEEN_ALBEDO_0[_S249] + (SHEEN_ALBEDO_0[_S252] - SHEEN_ALBEDO_0[_S249]) * _S250;
        uint _S253 = _S249 + 1U;
        uint _S254 = _S252 + 1U;
        float b_0 = SHEEN_ALBEDO_0[_S253] + (SHEEN_ALBEDO_0[_S254] - SHEEN_ALBEDO_0[_S253]) * _S250;
        float _S255 = (F32_exp((a_4 + (b_0 - a_4) * _S251)));
        if(_S245)
        {
            float a_5 = VELVET_ALBEDO_0[_S249] + (VELVET_ALBEDO_0[_S252] - VELVET_ALBEDO_0[_S249]) * _S250;
            float b_1 = VELVET_ALBEDO_0[_S253] + (VELVET_ALBEDO_0[_S254] - VELVET_ALBEDO_0[_S253]) * _S250;
            float _S256 = a_5 + (b_1 - a_5) * _S251;
            sheen_component_0 = _S256;
        }
        else
        {
            sheen_component_0 = _S255;
        }
        float _S257 = (F32_min((sheen_component_0), (1.0f)));
        float3  _S258 = make_float3 (1.0f) - material_2.sheen * make_float3 (_S257);
        float _S259 = rgb_to_greyscale(material_2.sheen);
        float _S260 = _S259 * _S257;
        float3  _S261 = material_2.sheen / make_float3 ((F32_max((sheen_component_0), (1.0f))));
        scale_0 = _S258;
        sheen_component_0 = _S260;
        sheen_1 = _S261;
        view_1 = v_3;
    }
    else
    {
        scale_0 = _S238;
        sheen_component_0 = 0.0f;
        sheen_1 = _S239;
        view_1 = _S239;
    }
    float3  _S262 = mix_0(_S236, material_2.albedo, material_2.metallic);
    float3  F_1 = _S262 * scale_0;
    float _S263 = rgb_to_greyscale(F_1);
    float _S264 = 1.0f - material_2.metallic;
    float3  _S265 = make_float3 (1.0f) - _S236;
    float3  _S266 = make_float3 ((1.0f - material_2.transmission) * _S264) * _S265 * scale_0;
    float3  _S267 = make_float3 (material_2.transmission * _S264) * _S265 * scale_0;
    float _S268 = (F32_max((_S263), (0.0f)));
    float _S269 = rgb_to_greyscale(_S266);
    float _S270 = (F32_max((_S269), (0.0f)));
    float _S271 = rgb_to_greyscale(_S267);
    float _S272 = sign_0(length_0(_S228));
    float _S273 = (F32_max((_S271 * _S272), (0.0f)));
    float _S274 = _S268 + _S270 + _S273;
    float _S275 = (F32_min((sheen_component_0), (1.0f)));
    bool _S276 = sheen_component_0 > 0.0f;
    bool _S277;
    if(_S276)
    {
        _S277 = !(_S274 > 0.0f);
    }
    else
    {
        _S277 = false;
    }
    float _S278 = _slang_select(_S277, 1.0f,_S275);
    float _S279 = (1.0f - _S278) / (F32_max((_S274), (0.0000152587890625f)));
    float _S280 = _S270 * _S279;
    float _S281 = _S268 * _S279;
    float _S282 = _S273 * _S279;
    bool _S283 = (frame_2.alphas.x) > 0.0f;
    if(_S283)
    {
        float3  _S284 = anisotropicLocal(v_3, frame_2.tangent, n_i_2);
        float _S285 = anisotropicG1(_S284, frame_2.alphas);
        float3  _S286 = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_2);
        float _S287 = anisotropicD(_S286, frame_2.alphas);
        float _S288 = _S285 * _S287;
        visible_1 = _S288;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S224, _S225, _S228, F_1, _S263, 1.0f, _S266, _S267, _S280, _S281, _S282, 0.0f, sheen_1, _S278, view_1, frame_2.tangent, frame_2.alphas, visible_1);
}

__device__ float translucentShare(BSDFMaterial material_3)
{
    float _S289 = rgb_to_greyscale(material_3.translucent);
    float _S290 = rgb_to_greyscale(material_3.albedo);
    float _S291 = _S289 / (_S290 + _S289);
    bool _S292 = _S289 > 0.0f;
    float _S293 = _slang_select(_S292, _S291,0.0f);
    return _S293;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_2, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S294 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S295 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S296 = 1.0f - lobes_0.translucent_share;
    bool _S297 = n_i_dot_l_0 < 0.0f;
    float _S298 = _slang_select(_S297, lobes_0.translucent_share,_S296);
    float _S299 = _S295 * _S298;
    bool _S300 = (lobes_0.translucent_share) > 0.0f;
    float _S301 = _slang_select(_S300, _S299,_S294);
    bool _S302 = n_i_dot_v_0 > 0.0f;
    float _S303 = _slang_select(_S302, _S301,0.0f);
    return _S303;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_3, float alpha_3, BSDFMaterial material_4, BSDFLobes lobes_1)
{
    bool _S304 = (dot_0(n_i_3, l_0)) < 0.0f;
    float3  _S305 = _slang_select(_S304, material_4.translucent,material_4.albedo);
    float _S306 = 1.0f - lobes_1.translucent_share;
    float _S307 = _slang_select(_S304, lobes_1.translucent_share,_S306);
    float3  _S308 = _S305 / make_float3 (_S307);
    bool _S309 = (lobes_1.translucent_share) > 0.0f;
    float3  _S310 = _slang_select(_S309, _S308,material_4.albedo);
    return lobes_1.diffuse_weight * _S310 / make_float3 (lobes_1.p_diffuse);
}

__device__ float smithG1(float alpha_4, float n_dot_x_0)
{
    float _S311 = alpha_4 * alpha_4;
    float _S312 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S311 + (1.0f - _S311) * n_dot_x_0 * n_dot_x_0))));
    bool _S313 = alpha_4 > 0.0f;
    float _S314 = _slang_select(_S313, _S312,1.0f);
    return _S314;
}

__device__ float trowbridgeReitz(float alpha_5, float n_dot_h_1)
{
    float _S315 = alpha_5 * alpha_5;
    float _S316 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S315 * n_dot_h_1 * n_dot_h_1;
    return _S315 / (F32_max((3.14159274101257324f * _S316 * _S316), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S317 = smithG1(alpha_6, n_i_dot_v_1);
    float _S318 = _S317 * lobes_2.v_dot_h;
    float _S319 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S320 = _S318 * _S319 / n_i_dot_v_1;
    bool _S321 = alpha_6 > 0.0f;
    bool _S322;
    if(_S321)
    {
        _S322 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S322 = false;
    }
    if(_S322)
    {
        _S322 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S322 = false;
    }
    if(_S322)
    {
        _S322 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S322 = false;
    }
    float _S323 = _slang_select(_S322, _S320,0.0f);
    bool _S324 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S324)
    {
        float _S325 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S326 = (lobes_2.v_dot_h) > 0.0f;
        if(_S326)
        {
            _S322 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S322 = false;
        }
        if(_S322)
        {
            _S322 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S322 = false;
        }
        float _S327 = _slang_select(_S322, _S325,0.0f);
        pdf_h_0 = _S327;
    }
    else
    {
        pdf_h_0 = _S323;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S328 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S329 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S330 = lobes_3.p_refract * _S328 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S329 * _S329);
    bool _S331 = eta_i_4 != eta_o_4;
    bool _S332;
    if(_S331)
    {
        _S332 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S332 = false;
    }
    float _S333 = _slang_select(_S332, _S330,0.0f);
    return _S333;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_4, float alpha_8, BSDFMaterial material_5, BSDFLobes lobes_4)
{
    float _S334 = - dot_0(n_i_4, l_1);
    float _S335 = smithG1(alpha_8, (F32_max((_S334), (0.0f))));
    bool _S336 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S336)
    {
        float3  _S337 = negate_0(n_i_4);
        float3  _S338 = anisotropicLocal(l_1, lobes_4.tangent, _S337);
        float _S339 = anisotropicG1(_S338, lobes_4.alphas);
        G1_l_0 = _S339;
    }
    else
    {
        G1_l_0 = _S335;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_5.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S340 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S341 = n_i_dot_l_2 > 0.0f;
    bool _S342;
    if(_S341)
    {
        _S342 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S342 = false;
    }
    float _S343 = _slang_select(_S342, _S340,0.0f);
    return _S343;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_5, float alpha_10, BSDFMaterial material_6, BSDFLobes lobes_6)
{
    float3  _S344 = l_2 + lobes_6.view;
    float3  _S345 = ((((_S344)) * make_float3(rnorm3df(((_S344)).x, ((_S344)).y, ((_S344)).z))));
    float _S346 = dot_0(n_i_5, _S345);
    float _S347 = (F32_max((dot_0(n_i_5, l_2)), (0.0f)));
    float _S348 = (F32_max((dot_0(n_i_5, lobes_6.view)), (0.0f)));
    float _S349 = 1.0f / (F32_max((material_6.sheen_roughness), (0.05000000074505806f)));
    float _S350 = 1.0f - _S346 * _S346;
    float _S351 = (2.0f + _S349) * (F32_pow(((F32_max((_S350), (0.0f)))), (0.5f * _S349))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S347 + _S348 - _S347 * _S348)), (0.0000152587890625f)));
    bool _S352 = (material_6.velvet) > 0.0f;
    float f_0;
    if(_S352)
    {
        float _S353 = (F32_max((material_6.sheen_roughness), (0.00999999977648258f)));
        float _S354 = _S353 * _S353;
        float _S355 = (F32_max((_S350), (0.0000152587890625f)));
        float _S356 = (F32_exp((- _S346 * _S346 / (_S355 * _S354)))) / (3.14159274101257324f * _S354 * _S355 * _S355) * (F32_min((1.0f), (2.0f * _S346 * (F32_min((_S347), (_S348))) / (F32_max(((F32_abs((dot_0(_S345, lobes_6.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S347 * _S348), (0.0000152587890625f)));
        f_0 = _S356;
    }
    else
    {
        f_0 = _S351;
    }
    return lobes_6.sheen * make_float3 (f_0 * _S347 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, BSDFLobes lobes_7, float eta_i_6, float eta_o_6)
{
    float _S357 = vndfPDF(n_i_dot_v_4, alpha_11, lobes_7);
    float _S358 = lobes_7.p_reflect * _S357 / (4.0f * lobes_7.v_dot_h);
    bool _S359 = _S357 > 0.0f;
    float _S360 = _slang_select(_S359, _S358,0.0f);
    return _S360;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_3, float3  n_i_6, float alpha_12, BSDFMaterial material_7, BSDFLobes lobes_8)
{
    float _S361 = dot_0(n_i_6, l_3);
    float _S362 = smithG1(alpha_12, (F32_max((_S361), (0.0f))));
    bool _S363 = (lobes_8.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S363)
    {
        float3  _S364 = anisotropicLocal(l_3, lobes_8.tangent, n_i_6);
        float _S365 = anisotropicG1(_S364, lobes_8.alphas);
        G1_l_1 = _S365;
    }
    else
    {
        G1_l_1 = _S362;
    }
    return make_float3 (lobes_8.reflect_weight * G1_l_1) * lobes_8.F / make_float3 (lobes_8.p_reflect);
}

__device__ __forceinline__ float3  misWeighted(float3  throughput_0, float lobe_pdf_0, float pdf_0, bool power_0)
{
    if(power_0)
    {
        float _S366 = lobe_pdf_0 / pdf_0;
        return throughput_0 * make_float3 (lobe_pdf_0) / make_float3 (pdf_0 * (1.0f + _S366 * _S366));
    }
    return throughput_0 * make_float3 (lobe_pdf_0) / make_float3 (lobe_pdf_0 + pdf_0);
}

static __device__ float3  neeLobes_0(float3  in_dir_4, float3  dir_3, float3  n_7, BSDFMaterial * material_8, float eta_i_7, float eta_o_7, bool refracted_2, float pdf_1, bool power_1, uint random_state_3, FixedArray<float3 , 4>  * each_0, uint * reached_0)
{
    float3  _S367 = negate_0(in_dir_4);
    float _S368 = dot_0(n_7, _S367);
    float _S369 = sign_0(_S368);
    float3  _S370 = n_7 * make_float3 (_S369);
    AnisotropicFrame _S371 = anisotropicFrame(*material_8, _S370);
    float _S372 = dot_0(_S370, dir_3);
    float _S373 = material_8->roughness * material_8->roughness;
    float3  _S374 = make_float3 (0.0f);
    *reached_0 = 0U;
    BSDFLobes _S375 = BSDFLobes_x24init_0(0.0f, 0.0f, _S374, _S374, 0.0f, 0.0f, _S374, _S374, 0.0f, 0.0f, 0.0f, 0.0f, _S374, 0.0f, _S374, _S374, make_float2 (0.0f), 0.0f);
    BSDFLobes lobe_terms_0 = _S375;
    uint i_2 = 0U;
    for(;;)
    {
        if(i_2 < 4U)
        {
        }
        else
        {
            break;
        }
        (*each_0)[i_2] = _S374;
        uint i_3 = i_2 + 1U;
        i_2 = i_3;
    }
    uint half_of_0 = 4294967295U;
    float3  ggx_n_1 = _S374;
    i_2 = 0U;
    float3  f_1 = _S374;
    for(;;)
    {
        if(i_2 < 4U)
        {
        }
        else
        {
            break;
        }
        uint _S376;
        if(i_2 == 3U)
        {
            _S376 = 4U;
        }
        else
        {
            _S376 = i_2;
        }
        bool _S377 = _S376 == 0U;
        if(_S377)
        {
        }
        bool _S378;
        if(_S377)
        {
            float _S379 = rgb_to_greyscale(material_8->translucent);
            _S378 = _S379 > 0.0f;
        }
        else
        {
            _S378 = false;
        }
        bool _S380;
        if(_S378)
        {
            float _S381 = dot_0(n_7, dir_3);
            float3  _S382 = negate_0(in_dir_4);
            _S380 = ((_S381 * dot_0(n_7, _S382)) < 0.0f) == refracted_2;
        }
        else
        {
            _S380 = (_S376 == 1U) == refracted_2;
        }
        float3  ggx_n_2;
        if(_S380)
        {
            uint _S383;
            if(_S376 == 4U)
            {
                _S383 = 2U;
            }
            else
            {
                _S383 = _S376;
            }
            bool _S384 = _S383 != half_of_0;
            uint half_of_1;
            if(_S384)
            {
                bool _S385 = _S383 == 0U;
                if(_S385)
                {
                    float3  _S386 = sampledHalf(in_dir_4, n_7, *material_8, random_state_3, _S371);
                    ggx_n_2 = _S386;
                }
                else
                {
                    bool _S387 = _S383 == 1U;
                    if(_S387)
                    {
                        float3  _S388 = refractedHalf(in_dir_4, dir_3, n_7, eta_i_7, eta_o_7);
                        ggx_n_2 = _S388;
                    }
                    else
                    {
                        float3  _S389 = reflectedHalf(in_dir_4, dir_3);
                        ggx_n_2 = _S389;
                    }
                }
                float3  _S390 = negate_0(in_dir_4);
                BSDFLobes _S391 = bsdfLobes(in_dir_4, _S390, _S370, ggx_n_2, *material_8, eta_i_7, eta_o_7, _S371);
                lobe_terms_0 = _S391;
                float _S392 = translucentShare(*material_8);
                (&lobe_terms_0)->translucent_share = _S392;
                half_of_1 = _S383;
            }
            else
            {
                ggx_n_2 = ggx_n_1;
                half_of_1 = half_of_0;
            }
            float3  throughput_1;
            float lobe_pdf_1;
            switch(_S376)
            {
            case 0U:
                {
                    float _S393 = diffusePDF(_S372, 0.0f, (F32_abs((_S368))), _S373, lobe_terms_0, eta_i_7, eta_o_7);
                    float3  _S394 = diffuseBSDF(dir_3, _S370, _S373, *material_8, lobe_terms_0);
                    lobe_pdf_1 = _S393;
                    throughput_1 = _S394;
                    break;
                }
            case 1U:
                {
                    float _S395 = refractPDF(_S372, dot_0(dir_3, ggx_n_2), (F32_abs((_S368))), _S373, lobe_terms_0, eta_i_7, eta_o_7);
                    float3  _S396 = refractBSDF(dir_3, _S370, _S373, *material_8, lobe_terms_0);
                    lobe_pdf_1 = _S395;
                    throughput_1 = _S396;
                    break;
                }
            case 4U:
                {
                    float _S397 = sheenVelvetPDF(_S372, 0.0f, (F32_abs((_S368))), _S373, lobe_terms_0, eta_i_7, eta_o_7);
                    float3  _S398 = sheenVelvetBSDF(dir_3, _S370, _S373, *material_8, lobe_terms_0);
                    lobe_pdf_1 = _S397;
                    throughput_1 = _S398;
                    break;
                }
            default:
                {
                    float _S399 = reflectPDF(_S372, 0.0f, (F32_abs((_S368))), _S373, lobe_terms_0, eta_i_7, eta_o_7);
                    float3  _S400 = reflectBSDF(dir_3, _S370, _S373, *material_8, lobe_terms_0);
                    lobe_pdf_1 = _S399;
                    throughput_1 = _S400;
                    break;
                }
            }
            bool _S401 = lobe_pdf_1 > 0.0f;
            float3  f_2;
            if(_S401)
            {
                float3  _S402 = misWeighted(throughput_1, lobe_pdf_1, pdf_1, power_1);
                (*each_0)[i_2] = _S402;
                uint _S403 = (*reached_0) | (1U << i_2);
                *reached_0 = _S403;
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

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_5, float3  dir_4, float3  n_8, BSDFMaterial material_9, float eta_i_8, float eta_o_8, bool refracted_3, float pdf_2, bool power_2, uint random_state_4)
{
    uint reached_1 = 0U;
    BSDFMaterial _S404 = material_9;
    FixedArray<float3 , 4>  each_1;
    float3  _S405 = neeLobes_0(in_dir_5, dir_4, n_8, &_S404, eta_i_8, eta_o_8, refracted_3, pdf_2, power_2, random_state_4, &each_1, &reached_1);
    return _S405;
}

__device__ float3  skyBSDF(float3  in_dir_6, float3  dir_5, FKSurface surface_1, float2  eta_1, bool is_inside_2, float pdf_3, uint random_state_5)
{
    bool _S406 = wrongSide_0(is_inside_2, false, dir_5, surface_1.geometry_n);
    float3  _S407 = neeBSDF(in_dir_6, dir_5, surface_1.smooth_n, surface_1.material, eta_1.x, eta_1.y, _S406, pdf_3, false, random_state_5);
    return _S407;
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

static __device__ SkySample SkySample_x24init_0(float3  dir_6, float3  radiance_0, float3  color_0, uint random_state_6)
{
    SkySample _S408;
    (&_S408)->dir = dir_6;
    (&_S408)->radiance = radiance_0;
    (&_S408)->color = color_0;
    (&_S408)->random_state = random_state_6;
    return _S408;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0)
{
    uint2  _S409 = (fcptEnvironmentCdfSize());
    uint2  _S410 = make_uint2 (1U, 0U);
    uint2  _S411 = _S409 - _S410;
    Random _S412 = pcg(init_random_state_0);
    Random _S413 = pcg(_S412.state);
    Random _S414 = pcg(_S413.state);
    Random _S415 = pcg(_S414.state);
    uint _S416 = _S411.x;
    uint _S417 = searchCDF_0(make_uint2 (_S416, 0U), make_uint2 (0U, 1U), _S411.y, _S412.value);
    uint _S418 = searchCDF_0(make_uint2 (0U, _S417), _S410, _S416, _S413.value);
    float2  _S419 = make_float2 ((float)_S411.x, (float)_S411.y);
    float2  _S420 = (make_float2 (float(_S418), float(_S417)) + make_float2 (_S414.value, _S415.value)) / _S419 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S421 = _S420.y;
    float _S422 = (F32_sin((_S421)));
    float _S423 = _S420.x;
    float3  _S424 = make_float3 (_S422 * (F32_cos((_S423))), (F32_cos((_S421))), _S422 * (F32_sin((_S423))));
    float _S425 = environmentPdf_0(_S424);
    float3  _S426 = skyBSDF(ray_0->unit_direction, _S424, *surface_2, eta_2, is_inside_3, _S425, lobe_state_0);
    bool _S427 = !(_S425 > 0.0f);
    bool _S428;
    if(_S427)
    {
        _S428 = true;
    }
    else
    {
        _S428 = all_0(_S426 == make_float3 (0.0f));
    }
    if(_S428)
    {
        float3  _S429 = make_float3 (0.0f);
        return SkySample_x24init_0(_S424, _S429, _S429, _S415.state);
    }
    float3  _S430 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S424);
    return SkySample_x24init_0(_S424, _S430, _S426 * _S430, _S415.state);
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
    SampleBSDF _S431 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S432 = _S431.throughput * make_float3 (_S431.pdf);
    float _S433 = light_1->density;
    float _S434 = 1.0f + _S431.pdf * _S431.pdf / (light_1->density * light_1->density);
    bool _S435;
    if(competing_0)
    {
        _S435 = _S433 > 0.0f;
    }
    else
    {
        _S435 = false;
    }
    float _S436 = _slang_select(_S435, _S434,1.0f);
    return _S432 / make_float3 (_S436) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_7, float3  radiance_1, float density_0, uint random_state_7)
{
    TreeSample _S437;
    (&_S437)->dir = dir_7;
    (&_S437)->radiance = radiance_1;
    (&_S437)->density = density_0;
    (&_S437)->random_state = random_state_7;
    return _S437;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_3, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S438 = importance(first_1, p_3, normal_3);
    float _S439 = importance(second_1, p_3, normal_3);
    float2  _S440 = make_float2 (_S438, _S439);
    bool _S441 = _S438 == 0.0f;
    bool _S442;
    if(_S441)
    {
        _S442 = _S439 == 0.0f;
    }
    else
    {
        _S442 = false;
    }
    if(_S442)
    {
        return 2U;
    }
    float _S443 = _S438 + _S439;
    bool _S444 = _S439 > 0.0f;
    if(_S444)
    {
        _S442 = (*pick_0 * _S443) >= _S438;
    }
    else
    {
        _S442 = false;
    }
    uint _S445 = uint(_S442);
    float _S446 = (F32_min(((*pick_0 * _S443 - float(_S445) * _S438) / _slang_vector_get_element(_S440, _S445)), (0.99999994039535522f)));
    *pick_0 = _S446;
    float _S447 = *probability_3 * (_slang_vector_get_element(_S440, _S445) / _S443);
    *probability_3 = _S447;
    return _S445;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_4, float u1_0, float u2_0)
{
    float3  _S448 = center_1 - p_4;
    float _S449 = radius_1 * radius_1 / dot_0(_S448, _S448);
    float _S450 = u1_0 * _S449 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S449), (0.0f)))))));
    float _S451 = 2.0f * u1_0;
    bool _S452 = _S449 >= 1.0f;
    float _S453 = _slang_select(_S452, _S451,_S450);
    float _S454 = (F32_sqrt(((F32_max((_S453 * (2.0f - _S453)), (0.0f))))));
    float _S455 = 6.28318548202514648f * u2_0;
    float3  _S456 = make_float3 (_S454 * (F32_cos((_S455))), 1.0f - _S453, _S454 * (F32_sin((_S455))));
    float3  _S457 = ((((_S448)) * make_float3(rnorm3df(((_S448)).x, ((_S448)).y, ((_S448)).z))));
    float3  _S458 = tangentToWorld(_S456, _S457);
    return _S458;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S459 = center_2 - ray_1->origin;
    float _S460 = dot_0(_S459, ray_1->unit_direction);
    float _S461 = dot_0(_S459, _S459) - _S460 * _S460;
    float _S462 = radius_3 * radius_3;
    bool _S463 = _S461 > _S462;
    if(_S463)
    {
        return 4.294967296e+09f;
    }
    float _S464 = (F32_sqrt((_S462 - _S461)));
    float _S465 = _S460 - _S464;
    float _S466 = _S460 + _S464;
    bool _S467 = _S465 > 0.0000152587890625f;
    bool _S468;
    if(_S467)
    {
        _S468 = _S465 < max_len_0;
    }
    else
    {
        _S468 = false;
    }
    if(_S468)
    {
        return _S465;
    }
    bool _S469 = _S466 > 0.0000152587890625f;
    if(_S469)
    {
        _S468 = _S466 < max_len_0;
    }
    else
    {
        _S468 = false;
    }
    if(_S468)
    {
        return _S466;
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

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_1)
{
    Random _S470 = pcg(init_random_state_1);
    Random _S471 = pcg(_S470.state);
    Random _S472 = pcg(_S471.state);
    float3  _S473 = make_float3 (0.0f);
    TreeSample _S474 = TreeSample_x24init_0(_S473, _S473, 0.0f, _S472.state);
    TreeSample sample_0 = _S474;
    float3  _S475 = _slang_select(sided_0, _S473,smooth_n_2);
    float3  _S476 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S470.value;
    float probability_4 = 1.0f;
    uint n_9 = 0U;
    for(;;)
    {
        uint4  _S477 = (fcptLightNode((n_9)));
        if((_S477.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S478 = (fcptLightSecond((n_9)));
        uint _S479 = n_9 + 1U;
        LightNode _S480 = (fcptLightBounds((_S479)));
        LightNode _S481 = (fcptLightBounds((_S478)));
        uint _S482 = pickChild(_S480, _S481, origin_4, _S475, &pick_1, &probability_4);
        bool _S483 = _S482 > 1U;
        if(_S483)
        {
            return sample_0;
        }
        bool _S484 = _S482 == 1U;
        uint _S485 = _slang_select(_S484, _S478,_S479);
        n_9 = _S485;
    }
    bool _S486 = n_9 == 0U;
    bool _S487;
    if(_S486)
    {
        LightNode _S488 = (fcptLightBounds((0U)));
        float _S489 = importance(_S488, origin_4, _S475);
        _S487 = !(_S489 > 0.0f);
    }
    else
    {
        _S487 = false;
    }
    if(_S487)
    {
        return sample_0;
    }
    uint4  _S490 = (fcptLightNode((n_9)));
    FKHit _S491 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S492 = (_S490.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S492)
    {
        FKLight _S493 = (fcptLight((_S490.y)));
        if(sided_0)
        {
            float _S494 = sign_0(dot_0(geometry_n_1, _S493.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S494);
            float3  _S495 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S495;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S476;
            lift_n_0 = smooth_n_2;
        }
        bool _S496 = (_S493.variance) == 0.0f;
        if(_S496)
        {
            float3  _S497 = _S493.position - emitter_point_0;
            float3  _S498 = ((((_S497)) * make_float3(rnorm3df(((_S497)).x, ((_S497)).y, ((_S497)).z))));
            (&sample_0)->dir = _S498;
            float3  _S499 = _S493.color * make_float3 (_S493.intensity) / make_float3 (dot_0(_S497, _S497) * probability_4);
            (&sample_0)->radiance = _S499;
            shadow_1 = _S497;
        }
        else
        {
            float3  _S500 = sampleSphere(_S493.position, _S493.variance, emitter_point_0, _S471.value, _S472.value);
            (&sample_0)->dir = _S500;
            float _S501 = sphereDensity(_S493.position, _S493.variance, emitter_point_0);
            float _S502 = probability_4 * _S501;
            (&sample_0)->density = _S502;
            float3  _S503 = pointLightRadiance(_S493.color, _S493.intensity, _S493.variance);
            float3  _S504 = _S503 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S504;
            FKRay _S505 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S506 = raySphere_0(_S493.position, _S493.variance, &_S505, 4.294967296e+09f);
            float3  _S507 = (&sample_0)->dir * make_float3 (_S506);
            shadow_1 = _S507;
        }
        emitter_0 = _S491;
        emitter_point_0 = _S473;
    }
    else
    {
        uint _S508 = _S490.y;
        uint _S509 = (fcptTriangleOffset((_S508)));
        uint _S510 = _S509 + _S490.z;
        Matrix<float, 3, 3>  _S511 = (fcptWorldTriangle((_S508), (_S510)));
        float _S512 = (F32_sqrt((_S471.value)));
        float2  _S513 = make_float2 (_S512 * (1.0f - _S472.value), _S512 * _S472.value);
        float3  _S514 = mul_0(make_float3 (1.0f - _S512, _S513.x, _S513.y), _S511);
        if(sided_0)
        {
            float _S515 = sign_0(dot_0(geometry_n_1, _S514 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S515);
            float3  _S516 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S516;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S517 = !((dot_0(smooth_n_2, _S514 - origin_4)) > 0.0f);
            if(_S517)
            {
                return sample_0;
            }
            emitter_point_0 = _S476;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S513, _S508, _S510, 0U, 0.0f);
        float3  _S518 = _S514 - emitter_point_0;
        float3  _S519 = ((((_S518)) * make_float3(rnorm3df(((_S518)).x, ((_S518)).y, ((_S518)).z))));
        (&sample_0)->dir = _S519;
        float _S520 = solidAngle(probability_4, cross_0(_S511.rows[int(1)] - _S511.rows[int(0)], _S511.rows[int(2)] - _S511.rows[int(0)]), _S518);
        (&sample_0)->density = _S520;
        bool _S521 = (fcptShadowFirst());
        bool _S522 = !_S521;
        if(_S522)
        {
            FKSurface _S523 = (fcptLightSurfaceAt((emitter_1), (_S514), (_S472.state), ((&sample_0)->dir), (context_1->depth), (length_0(_S514 - origin_4))));
            (&sample_0)->random_state = _S523.random_state;
            float3  _S524 = _slang_select(_S523.skip, _S473,_S523.material.emissive);
            float3  _S525 = _S524 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S525;
        }
        shadow_1 = _S518;
        emitter_0 = emitter_1;
        emitter_point_0 = _S514;
    }
    FKHit _S526 = emitter_0;
    float3  _S527 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_1, _S472.state, &_S526);
    bool _S528 = (fcptShadowFirst());
    if(_S528)
    {
        _S487 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S487 = false;
    }
    if(_S487)
    {
        _S487 = !all_0(_S527 == _S473);
    }
    else
    {
        _S487 = false;
    }
    if(_S487)
    {
        FKSurface _S529 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S472.state), ((&sample_0)->dir), (context_1->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S529.random_state;
        float3  _S530 = _slang_select(_S529.skip, _S473,_S529.material.emissive);
        float3  _S531 = _S530 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S531;
    }
    float3  _S532 = (&sample_0)->radiance * _S527;
    bool _S533 = all_0(_S527 == _S473);
    float3  _S534 = _slang_select(_S533, _S473,_S532);
    (&sample_0)->radiance = _S534;
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
    float _S535 = 1.0f / (1.0f + b_2 / a_6 * (b_2 / a_6));
    bool _S536 = b_2 > 0.0f;
    float _S537 = _slang_select(_S536, _S535,1.0f);
    return _S537;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_0, float3  light_point_1)
{
    bool _S538 = vertex_0->none;
    if(_S538)
    {
        return 1.0f;
    }
    uint _S539 = (fcptLightSlot((*hit_0)));
    float _S540 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S539, light_point_1);
    float _S541 = powerHeuristic(vertex_0->pdf, _S540);
    return _S541;
}

static __device__ float3  environment_0(float3  dir_8, uint depth_0, uint lobe_0)
{
    uint2  _S542 = (fcptEnvironmentMapSize());
    bool _S543 = (_S542.x) > 1U;
    bool _S544;
    if(_S543)
    {
        uint2  _S545 = (fcptEnvironmentMapSize());
        _S544 = (_S545.y) > 1U;
    }
    else
    {
        _S544 = false;
    }
    if(_S544)
    {
        float3  _S546 = (fcptEnvMapSample((dir_8), (depth_0), (lobe_0)));
        return _S546;
    }
    float3  _S547 = (fcptAmbient());
    return _S547;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S548 = (fcptEnvironmentCdfSize());
    bool _S549 = (_S548.x) > 1U;
    bool _S550;
    if(_S549)
    {
        uint2  _S551 = (fcptEnvironmentCdfSize());
        _S550 = (_S551.y) > 1U;
    }
    else
    {
        _S550 = false;
    }
    bool _S552 = !_S550;
    if(_S552)
    {
        return false;
    }
    uint2  _S553 = (fcptEnvironmentMapSize());
    bool _S554 = (_S553.x) > 1U;
    if(_S554)
    {
        uint2  _S555 = (fcptEnvironmentMapSize());
        _S550 = (_S555.y) > 1U;
    }
    else
    {
        _S550 = false;
    }
    return _S550;
}

static __device__ float escapeWeight_0(float pdf_4, float3  dir_9)
{
    bool _S556 = pdf_4 <= 0.0f;
    bool _S557;
    if(_S556)
    {
        _S557 = true;
    }
    else
    {
        bool _S558 = environmentMapped_0();
        _S557 = !_S558;
    }
    if(_S557)
    {
        return 1.0f;
    }
    float _S559 = environmentPdf_0(dir_9);
    return pdf_4 / (pdf_4 + _S559);
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
    Shift _S560;
    (&_S560)->f = f_4;
    (&_S560)->jac = jac_0;
    return _S560;
}

static __device__ uint extractBits_0(uint e_1, uint offset_0, uint count_1)
{
    return (e_1 >> offset_0) & ((1U << count_1) - 1U);
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_5, float3  origin_5, float3  smooth_n_3, float3  start_2)
{
    NEEVertex _S561;
    (&_S561)->none = none_0;
    (&_S561)->pdf = pdf_5;
    (&_S561)->origin = origin_5;
    (&_S561)->smooth_n = smooth_n_3;
    (&_S561)->start = start_2;
    return _S561;
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
    Vertex _S562;
    (&_S562)->rough = rough_0;
    (&_S562)->lobe = lobe_1;
    (&_S562)->pdf = pdf_6;
    (&_S562)->cos = cos_0;
    (&_S562)->inside = inside_0;
    return _S562;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S563 = hash(index_0);
    uint _S564 = hash(seed_0 ^ _S563);
    return _S564;
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
    float3  _S565 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_1));
    float3  _S566 = scatter_0 * _S565 / make_float3 (sigma_1);
    float3  _S567 = _slang_select(scatters_0, _S566,_S565);
    return _S567;
}

static __device__ bool scatterSampled_0(bool replay_0, uint b_3, uint stop_0, bool varying_0)
{
    bool _S568 = !replay_0;
    bool _S569;
    if(_S568)
    {
        _S569 = true;
    }
    else
    {
        bool _S570 = b_3 == stop_0;
        if(_S570)
        {
            _S569 = !varying_0;
        }
        else
        {
            _S569 = false;
        }
    }
    return _S569;
}

static __device__ uint arrivalLobe_0(uint b_4, uint prev_lobe_0)
{
    bool _S571 = b_4 > 0U;
    uint _S572 = _slang_select(_S571, prev_lobe_0,3U);
    return _S572;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_4, float length_2, float width_0, FKHit * own_0, bool fiber_0)
{
    ShadowContext _S573;
    (&_S573)->extinction_behind = extinction_behind_0;
    (&_S573)->extinction_front = extinction_front_0;
    (&_S573)->fillings = fillings_0;
    (&_S573)->side = side_0;
    (&_S573)->depth = depth_1;
    (&_S573)->lobe = lobe_2;
    (&_S573)->surface = surface_4;
    (&_S573)->length = length_2;
    (&_S573)->width = width_0;
    (&_S573)->own = *own_0;
    (&_S573)->fiber = fiber_0;
    return _S573;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S574 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S574)
    {
        return 0.07957746833562851f;
    }
    float _S575 = g_0 * g_0;
    return (1.0f - _S575) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S575 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_7, float3  b_5)
{
    float3  _S576 = a_7 / b_5;
    float3  _S577 = make_float3 (0.0f);
    bool3  _S578 = b_5 == _S577;
    float3  _S579 = _slang_select(_S578, _S577,_S576);
    return _S579;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S580 = (1U << count_2) - 1U;
    return (e_2 & (~(_S580 << offset_1))) | ((newbits_0 & _S580) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_0, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_0 = r_0;
    uint _S581 = insertBits_0(r_0.path, end_0, 0U, 5U);
    uint _S582 = insertBits_0(_S581, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S582;
    (&candidate_0)->f = f_5;
    return candidate_0;
}

__device__ void offer(Selection * sel_0, Reservoir candidate_1, float3  weight_0)
{
    float _S583 = rgb_to_greyscale(weight_0);
    bool _S584 = _S583 > 0.0f;
    bool _S585;
    if(_S584)
    {
        _S585 = _S583 < 3.00000000549775576e+38f;
    }
    else
    {
        _S585 = false;
    }
    bool _S586 = !_S585;
    if(_S586)
    {
        return;
    }
    bool _S587 = sel_0->sums;
    if(_S587)
    {
        float3  _S588 = sel_0->color + weight_0;
        sel_0->color = _S588;
        return;
    }
    float _S589 = sel_0->w_sum + _S583;
    sel_0->w_sum = _S589;
    float3  _S590 = sel_0->color + weight_0;
    sel_0->color = _S590;
    Random _S591 = pcg(sel_0->random_state);
    sel_0->random_state = _S591.state;
    bool _S592 = (_S591.value * sel_0->w_sum) <= _S583;
    if(_S592)
    {
        sel_0->r = candidate_1;
    }
    return;
}

__device__ float survivalProbability(float3  throughput_2, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_2.x), ((F32_max((throughput_2.y), (throughput_2.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_8)
{
    Random _S593 = pcg(random_state_8);
    Random _S594 = pcg(_S593.state);
    float _S595 = 1.0f - 2.0f * _S593.value;
    float _S596 = (F32_sqrt(((F32_max((1.0f - _S595 * _S595), (0.0f))))));
    float _S597 = 6.28318548202514648f * _S594.value;
    return make_float3 (_S596 * (F32_cos((_S597))), _S596 * (F32_sin((_S597))), _S595);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_10, uint random_state_9, float * pdf_7)
{
    bool _S598 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S598)
    {
        *pdf_7 = 0.07957746833562851f;
        float3  _S599 = isotropic_0(random_state_9);
        return _S599;
    }
    Random _S600 = pcg(random_state_9);
    Random _S601 = pcg(_S600.state);
    float _S602 = g_1 * g_1;
    float _S603 = 2.0f * g_1;
    float _S604 = (1.0f - _S602) / (1.0f - g_1 + _S603 * _S600.value);
    float _S605 = clamp_0((1.0f + _S602 - _S604 * _S604) / _S603, -1.0f, 1.0f);
    float _S606 = (F32_sqrt(((F32_max((1.0f - _S605 * _S605), (0.0f))))));
    float _S607 = 6.28318548202514648f * _S601.value;
    float _S608 = phaseHG_0(g_1, _S605);
    *pdf_7 = _S608;
    float3  _S609 = tangentToWorld(make_float3 (_S606 * (F32_cos((_S607))), _S605, _S606 * (F32_sin((_S607)))), dir_10);
    float3  _S610 = ((((_S609)) * make_float3(rnorm3df(((_S609)).x, ((_S609)).y, ((_S609)).z))));
    return _S610;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0)
{
    BSDFMaterial _S611;
    (&_S611)->albedo = albedo_0;
    (&_S611)->emissive = emissive_0;
    (&_S611)->roughness = roughness_0;
    (&_S611)->metallic = metallic_0;
    (&_S611)->transmission = transmission_0;
    (&_S611)->ior = ior_0;
    (&_S611)->absorption = absorption_0;
    (&_S611)->specular_tint = specular_tint_0;
    (&_S611)->specular_level = specular_level_0;
    (&_S611)->translucent = translucent_0;
    (&_S611)->sheen = sheen_2;
    (&_S611)->sheen_roughness = sheen_roughness_0;
    (&_S611)->anisotropy = anisotropy_0;
    (&_S611)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S611)->tangent = tangent_2;
    (&_S611)->velvet = velvet_0;
    return _S611;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S612;
    (&_S612)->scatter = scatter_1;
    (&_S612)->extinction = extinction_1;
    (&_S612)->g = g_2;
    return _S612;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_10, bool skip_0, uint random_state_10, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S613;
    (&_S613)->smooth_n = smooth_n_4;
    (&_S613)->geometry_n = geometry_n_2;
    (&_S613)->geometry_offset = geometry_offset_2;
    (&_S613)->material = *material_10;
    (&_S613)->skip = skip_0;
    (&_S613)->random_state = random_state_10;
    (&_S613)->coverage = coverage_0;
    (&_S613)->encloses = encloses_0;
    (&_S613)->volume = *volume_0;
    (&_S613)->fills = fills_0;
    (&_S613)->hair = hair_0;
    return _S613;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S614 = (&surface_5->material)->emissive;
    float3  _S615 = make_float3 (0.0f);
    bool _S616 = !top_0;
    float3  _S617 = _slang_select(_S616, _S615,_S614);
    (&(&lower_0)->material)->emissive = _S617;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_2)
{
    float _S618 = surface_6->coverage;
    bool _S619 = u_2 < _S618;
    if(_S619)
    {
        return *surface_6;
    }
    float3  _S620 = make_float3 (0.0f);
    float3  _S621 = make_float3 (1.0f);
    BSDFMaterial _S622 = Material_x24init_0(_S620, _S620, 0.0f, 0.0f, 0.0f, 0.0f, _S620, _S621, 1.0f, _S620, _S620, 0.5f, 0.0f, 0.0f, _S620, 0.0f);
    BSDFMaterial material_11 = _S622;
    (&material_11)->albedo = _S621;
    (&material_11)->emissive = (&surface_6->material)->emissive;
    (&material_11)->transmission = 1.0f;
    (&material_11)->ior = 1.0f;
    (&material_11)->absorption = (&surface_6->material)->absorption;
    FKSurface through_0 = *surface_6;
    (&through_0)->material = material_11;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S623 = transmission_1 > 0.0f;
    bool _S624;
    if(_S623)
    {
        _S624 = true;
    }
    else
    {
        _S624 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S625;
    if(_S624)
    {
        _S625 = 1.0f;
    }
    else
    {
        _S625 = -1.0f;
    }
    return _S625;
}

static __device__ bool arrivesBehind_0(float3  dir_11, float3  n_10)
{
    return (dot_0(dir_11, n_10)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_12)
{
    float3  _S626 = surface_7->geometry_n;
    float _S627 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_12);
    FKSurface faced_0 = *surface_7;
    float3  _S628 = surface_7->smooth_n * make_float3 (_S627);
    (&faced_0)->smooth_n = _S628;
    float3  _S629 = _S626 * make_float3 (_S627);
    (&faced_0)->geometry_n = _S629;
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
    float3  _S630 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_2) * log_0(_S630));
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
    bool _S631;
    if(open_0)
    {
        _S631 = prev_rough_0;
    }
    else
    {
        _S631 = false;
    }
    if(_S631)
    {
        _S631 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S631 = false;
    }
    return _S631;
}

__device__ float2  vertexEta(BSDFMaterial material_12, float n_dot_v_0)
{
    bool _S632 = n_dot_v_0 < 0.0f;
    float _S633 = _slang_select(_S632, material_12.ior,1.0f);
    float _S634 = _slang_select(_S632, 1.0f,material_12.ior);
    return make_float2 (_S633, _S634);
}

__device__ bool neeDecision(BSDFMaterial material_13, float n_dot_v_1, float eta_i_9, float eta_o_9)
{
    float _S635 = fresnel((F32_abs((n_dot_v_1))), eta_i_9, eta_o_9);
    float3  _S636 = mix_0(make_float3 (_S635), material_13.albedo, material_13.metallic);
    float _S637 = rgb_to_greyscale(_S636);
    float _S638 = (F32_max(((1.0f - _S637) * (1.0f - material_13.metallic) * (1.0f - material_13.transmission)), (0.0f)));
    bool _S639 = _S638 > 0.03999999910593033f;
    bool _S640;
    if(_S639)
    {
        _S640 = true;
    }
    else
    {
        _S640 = (material_13.roughness) > 0.20000000298023224f;
    }
    return _S640;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_14)
{
    float _S641 = rgb_to_greyscale(material_14->translucent);
    return _S641 > 0.0f;
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
    MediumSides _S642;
    (&_S642)->behind = *behind_0;
    (&_S642)->front = *front_0;
    (&_S642)->fillings = fillings_1;
    (&_S642)->face = face_1;
    return _S642;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_13, FKMedium * outside_0)
{
    float3  _S643 = surface_8->geometry_n;
    MediumSides _S644 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S644;
    bool _S645 = surface_8->encloses;
    if(_S645)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S646 = (dot_0(dir_13, _S643)) > 0.0f;
        if(_S646)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_14, uint depth_2, uint lobe_3, float length_3, float width_1, FKHit * own_1, bool fiber_1, FKMedium * outside_1)
{
    float3  _S647 = surface_9->geometry_n;
    ShadowContext _S648 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
    bool _S649 = surface_9->encloses;
    ShadowContext context_2;
    if(_S649)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S650 = - _S647;
        float3  _S651 = _slang_select(turned_0, _S650,_S647);
        (&faced_1)->geometry_n = _S651;
        FKMedium _S652 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S653 = faced_1;
        FKMedium _S654 = _S652;
        MediumSides _S655 = mediumSides_0(&_S653, &_S654, filling_1, dir_14, outside_1);
        ShadowContext _S656 = ShadowContext_x24init_0(_S655.behind.extinction, _S655.front.extinction, _S655.fillings, _S647, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
        if(turned_0)
        {
            uint2  _S657 = _S655.fillings;
            ShadowContext _S658 = ShadowContext_x24init_0(_S655.front.extinction, _S655.behind.extinction, uint2 {_S657.y, _S657.x}, _S647, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
            context_2 = _S658;
        }
        else
        {
            context_2 = _S656;
        }
    }
    else
    {
        context_2 = _S648;
    }
    return context_2;
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

__device__ __forceinline__ float3  BSDF(float3  in_dir_8, float3  out_dir_2, float3  n_11, float3  g_n_0, BSDFMaterial material_15, float eta_i_10, float eta_o_10, uint random_state_11)
{
    float3  _S659 = negate_0(in_dir_8);
    float _S660 = dot_0(n_11, _S659);
    float _S661 = sign_0(_S660);
    float3  _S662 = n_11 * make_float3 (_S661);
    AnisotropicFrame _S663 = anisotropicFrame(material_15, _S662);
    float _S664 = dot_0(_S662, out_dir_2);
    float _S665 = material_15.roughness;
    float _S666 = _S665 * _S665;
    bool _S667 = (dot_0(g_n_0, _S659) * dot_0(g_n_0, out_dir_2)) > 0.0f;
    uint _S668;
    if(_S667)
    {
        _S668 = 3U;
    }
    else
    {
        _S668 = 1U;
    }
    float3  _S669 = make_float3 (0.0f);
    BSDFLobes _S670 = BSDFLobes_x24init_0(0.0f, 0.0f, _S669, _S669, 0.0f, 0.0f, _S669, _S669, 0.0f, 0.0f, 0.0f, 0.0f, _S669, 0.0f, _S669, _S669, make_float2 (0.0f), 0.0f);
    BSDFLobes lobe_terms_1 = _S670;
    uint half_of_2 = 4294967295U;
    float3  ggx_n_3 = _S669;
    float3  f_6 = _S669;
    uint i_12 = 0U;
    for(;;)
    {
        if(i_12 < _S668)
        {
        }
        else
        {
            break;
        }
        uint _S671;
        if(!_S667)
        {
            _S671 = 1U;
        }
        else
        {
            if(i_12 == 0U)
            {
                _S671 = 0U;
            }
            else
            {
                if(i_12 == 1U)
                {
                    _S671 = 2U;
                }
                else
                {
                    _S671 = 4U;
                }
            }
        }
        uint _S672;
        if(_S671 == 4U)
        {
            _S672 = 2U;
        }
        else
        {
            _S672 = _S671;
        }
        bool _S673 = _S672 != half_of_2;
        float3  ggx_n_4;
        if(_S673)
        {
            bool _S674 = _S672 == 0U;
            if(_S674)
            {
                float3  _S675 = sampledHalf(in_dir_8, n_11, material_15, random_state_11, _S663);
                ggx_n_4 = _S675;
            }
            else
            {
                bool _S676 = _S672 == 1U;
                if(_S676)
                {
                    float3  _S677 = refractedHalf(in_dir_8, out_dir_2, n_11, eta_i_10, eta_o_10);
                    ggx_n_4 = _S677;
                }
                else
                {
                    float3  _S678 = reflectedHalf(in_dir_8, out_dir_2);
                    ggx_n_4 = _S678;
                }
            }
            float3  _S679 = negate_0(in_dir_8);
            BSDFLobes _S680 = bsdfLobes(in_dir_8, _S679, _S662, ggx_n_4, material_15, eta_i_10, eta_o_10, _S663);
            lobe_terms_1 = _S680;
            float _S681 = translucentShare(material_15);
            (&lobe_terms_1)->translucent_share = _S681;
            half_of_2 = _S672;
        }
        else
        {
            ggx_n_4 = ggx_n_3;
        }
        float3  throughput_3;
        float pdf_8;
        switch(_S671)
        {
        case 0U:
            {
                float _S682 = diffusePDF(_S664, 0.0f, (F32_abs((_S660))), _S666, lobe_terms_1, eta_i_10, eta_o_10);
                float3  _S683 = diffuseBSDF(out_dir_2, _S662, _S666, material_15, lobe_terms_1);
                pdf_8 = _S682;
                throughput_3 = _S683;
                break;
            }
        case 1U:
            {
                float _S684 = refractPDF(_S664, dot_0(out_dir_2, ggx_n_4), (F32_abs((_S660))), _S666, lobe_terms_1, eta_i_10, eta_o_10);
                float3  _S685 = refractBSDF(out_dir_2, _S662, _S666, material_15, lobe_terms_1);
                pdf_8 = _S684;
                throughput_3 = _S685;
                break;
            }
        case 4U:
            {
                float _S686 = sheenVelvetPDF(_S664, 0.0f, (F32_abs((_S660))), _S666, lobe_terms_1, eta_i_10, eta_o_10);
                float3  _S687 = sheenVelvetBSDF(out_dir_2, _S662, _S666, material_15, lobe_terms_1);
                pdf_8 = _S686;
                throughput_3 = _S687;
                break;
            }
        default:
            {
                float _S688 = reflectPDF(_S664, 0.0f, (F32_abs((_S660))), _S666, lobe_terms_1, eta_i_10, eta_o_10);
                float3  _S689 = reflectBSDF(out_dir_2, _S662, _S666, material_15, lobe_terms_1);
                pdf_8 = _S688;
                throughput_3 = _S689;
                break;
            }
        }
        float3  _S690;
        if(pdf_8 > 0.0f)
        {
            _S690 = throughput_3 * make_float3 (pdf_8);
        }
        else
        {
            _S690 = _S669;
        }
        if(i_12 == 0U)
        {
            f_6 = _S690;
        }
        else
        {
            f_6 = f_6 + _S690;
        }
        uint i_13 = i_12 + 1U;
        ggx_n_3 = ggx_n_4;
        i_12 = i_13;
    }
    return f_6;
}

__device__ float3  translucentCorrection(float3  in_dir_9, float3  out_dir_3, float3  n_12, float3  g_n_1, BSDFMaterial material_16, float eta_i_11, float eta_o_11, uint random_state_12)
{
    float _S691 = dot_0(n_12, out_dir_3);
    float3  _S692 = negate_0(in_dir_9);
    bool _S693 = (_S691 * dot_0(n_12, _S692)) < 0.0f;
    float3  _S694 = negate_0(in_dir_9);
    float _S695 = dot_0(n_12, _S694);
    float _S696 = sign_0(_S695);
    float3  _S697 = n_12 * make_float3 (_S696);
    AnisotropicFrame _S698 = anisotropicFrame(material_16, _S697);
    float _S699 = material_16.roughness;
    float _S700 = _S699 * _S699;
    float3  _S701 = negate_0(in_dir_9);
    float3  _S702 = sampledHalf(in_dir_9, n_12, material_16, random_state_12, _S698);
    BSDFLobes _S703 = bsdfLobes(in_dir_9, _S701, _S697, _S702, material_16, eta_i_11, eta_o_11, _S698);
    BSDFLobes sampled_0 = _S703;
    float _S704 = translucentShare(material_16);
    (&sampled_0)->translucent_share = _S704;
    float _S705 = diffusePDF(dot_0(_S697, out_dir_3), 0.0f, (F32_abs((_S695))), _S700, sampled_0, eta_i_11, eta_o_11);
    float3  _S706;
    if(_S705 > 0.0f)
    {
        float3  _S707 = diffuseBSDF(out_dir_3, _S697, _S700, material_16, sampled_0);
        _S706 = _S707 * make_float3 (_S705);
    }
    else
    {
        _S706 = make_float3 (0.0f);
    }
    float3  _S708 = negate_0(in_dir_9);
    bool _S709 = (dot_0(g_n_1, _S708) * dot_0(g_n_1, out_dir_3)) > 0.0f;
    float3  _S710 = make_float3 (0.0f);
    float _S711 = _slang_select(_S709, -1.0f,1.0f);
    float3  _S712 = _S706 * make_float3 (_S711);
    float3  _S713 = _slang_select(_S693, _S712,_S710);
    return _S713;
}

__device__ float3  translucentBSDF(float3  in_dir_10, float3  out_dir_4, float3  n_13, float3  g_n_2, BSDFMaterial material_17, float eta_i_12, float eta_o_12, uint random_state_13)
{
    float3  _S714 = BSDF(in_dir_10, out_dir_4, n_13, g_n_2, material_17, eta_i_12, eta_o_12, random_state_13);
    float3  _S715 = translucentCorrection(in_dir_10, out_dir_4, n_13, g_n_2, material_17, eta_i_12, eta_o_12, random_state_13);
    return _S714 + _S715;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_11, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_18, float eta_i_13, float eta_o_13, bool competing_1, uint random_state_14)
{
    bool _S716 = !competing_1;
    bool _S717;
    if(_S716)
    {
        _S717 = true;
    }
    else
    {
        _S717 = (light_2->density) == 0.0f;
    }
    if(_S717)
    {
        bool _S718 = isTranslucent_0(material_18);
        if(_S718)
        {
            float3  _S719 = translucentBSDF(in_dir_11, light_2->dir, smooth_n_5, geometry_n_4, *material_18, eta_i_13, eta_o_13, random_state_14);
            return _S719 * light_2->radiance;
        }
        float3  _S720 = BSDF(in_dir_11, light_2->dir, smooth_n_5, geometry_n_4, *material_18, eta_i_13, eta_o_13, random_state_14);
        return _S720 * light_2->radiance;
    }
    float3  _S721 = light_2->dir;
    bool _S722 = (dot_0(geometry_n_4, - in_dir_11) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    float3  _S723 = neeBSDF(in_dir_11, _S721, smooth_n_5, *material_18, eta_i_13, eta_o_13, _S722, light_2->density, true, random_state_14);
    return _S723 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_4, uint random_state_15, bool refracted_4, uint lobe_4, float pdf_9)
{
    SampleBSDF _S724;
    (&_S724)->unit_direction = unit_direction_1;
    (&_S724)->throughput = throughput_4;
    (&_S724)->random_state = random_state_15;
    (&_S724)->refracted = refracted_4;
    (&_S724)->lobe = lobe_4;
    (&_S724)->pdf = pdf_9;
    return _S724;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_7, float n_i_dot_v_5, float alpha_13, BSDFMaterial material_19, BSDFLobes lobes_9, float eta_i_14, float eta_o_14, uint random_state_16)
{
    float3  _S725 = make_float3 (1.0f);
    SampleBSDF _S726 = SampleBSDF_x24init_0(_S725, _S725, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S726;
    Random _S727 = pcg(random_state_16);
    Random _S728 = pcg(_S727.state);
    (&sample_1)->random_state = _S728.state;
    float _S729 = _S727.value;
    float _S730 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S729 * _S729))))));
    float _S731 = 6.28318548202514648f * _S728.value;
    float3  _S732 = tangentToWorld(make_float3 (_S730 * (F32_cos((_S731))), _S727.value, _S730 * (F32_sin((_S731)))), n_i_7);
    (&sample_1)->unit_direction = _S732;
    (&sample_1)->lobe = 4U;
    float3  _S733 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_7, alpha_13, material_19, lobes_9);
    (&sample_1)->throughput = _S733;
    float _S734 = sheenVelvetPDF(_S727.value, 0.0f, n_i_dot_v_5, alpha_13, lobes_9, eta_i_14, eta_o_14);
    (&sample_1)->pdf = _S734;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S735 = (F32_sqrt((random_1_0)));
    float _S736 = 6.28318548202514648f * random_2_0;
    float _S737 = _S735 * (F32_cos((_S736)));
    float _S738 = _S735 * (F32_sin((_S736)));
    float _S739 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S737 * _S737 - _S738 * _S738))))));
    return make_float3 (_S737, _S739, _S738);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_8, float n_i_dot_v_6, float alpha_14, BSDFMaterial material_20, BSDFLobes lobes_10, float eta_i_15, float eta_o_15, uint random_state_17)
{
    float3  _S740 = make_float3 (1.0f);
    SampleBSDF _S741 = SampleBSDF_x24init_0(_S740, _S740, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S741;
    Random _S742 = pcg(random_state_17);
    Random _S743 = pcg(_S742.state);
    (&sample_2)->random_state = _S743.state;
    float3  _S744 = sampleCosWeightedHemisphere(_S742.value, _S743.value);
    bool _S745 = u_3 < (lobes_10.p_diffuse * lobes_10.translucent_share);
    float _S746 = _S744.y;
    float _S747 = - _S746;
    float _S748 = _slang_select(_S745, _S747,_S746);
    float3  _S749 = tangentToWorld(make_float3 (_S744.x, _S748, _S744.z), n_i_8);
    (&sample_2)->unit_direction = _S749;
    (&sample_2)->refracted = _S745;
    (&sample_2)->lobe = 0U;
    float3  _S750 = diffuseBSDF((&sample_2)->unit_direction, n_i_8, alpha_14, material_20, lobes_10);
    (&sample_2)->throughput = _S750;
    float _S751 = diffusePDF(_S748, 0.0f, n_i_dot_v_6, alpha_14, lobes_10, eta_i_15, eta_o_15);
    (&sample_2)->pdf = _S751;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_5, float3  n_i_9, float n_i_dot_v_7, float alpha_15, BSDFMaterial material_21, BSDFLobes lobes_11, float eta_i_16, float eta_o_16, uint random_state_18)
{
    float3  _S752 = make_float3 (1.0f);
    SampleBSDF _S753 = SampleBSDF_x24init_0(_S752, _S752, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S753;
    (&sample_3)->unit_direction = lobes_11.refracted;
    (&sample_3)->random_state = random_state_18;
    (&sample_3)->refracted = true;
    (&sample_3)->lobe = 1U;
    float3  _S754 = refractBSDF((&sample_3)->unit_direction, n_i_9, alpha_15, material_21, lobes_11);
    (&sample_3)->throughput = _S754;
    float _S755 = refractPDF(0.0f, dot_0((&sample_3)->unit_direction, ggx_n_5), n_i_dot_v_7, alpha_15, lobes_11, eta_i_16, eta_o_16);
    (&sample_3)->pdf = _S755;
    return sample_3;
}

static __device__ float3  reflect_0(float3  i_14, float3  n_14)
{
    return i_14 - make_float3 (2.0f * dot_0(n_14, i_14)) * n_14;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_12, float3  ggx_n_6, float3  n_i_10, float n_i_dot_v_8, float alpha_16, BSDFMaterial material_22, BSDFLobes lobes_12, float eta_i_17, float eta_o_17, uint random_state_19)
{
    float3  _S756 = make_float3 (1.0f);
    SampleBSDF _S757 = SampleBSDF_x24init_0(_S756, _S756, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S757;
    float3  _S758 = reflect_0(in_dir_12, ggx_n_6);
    float3  _S759 = ((((_S758)) * make_float3(rnorm3df(((_S758)).x, ((_S758)).y, ((_S758)).z))));
    (&sample_4)->unit_direction = _S759;
    (&sample_4)->random_state = random_state_19;
    (&sample_4)->lobe = 2U;
    float3  _S760 = reflectBSDF((&sample_4)->unit_direction, n_i_10, alpha_16, material_22, lobes_12);
    (&sample_4)->throughput = _S760;
    float _S761 = reflectPDF(0.0f, 0.0f, n_i_dot_v_8, alpha_16, lobes_12, eta_i_17, eta_o_17);
    (&sample_4)->pdf = _S761;
    return sample_4;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_13, float3  n_15, BSDFMaterial material_23, float eta_i_18, float eta_o_18, uint random_init_0, float2  screen_space_0)
{
    uint random_state_20 = random_init_0;
    float3  _S762 = negate_0(in_dir_13);
    float _S763 = dot_0(n_15, _S762);
    float _S764 = sign_0(_S763);
    float3  n_i_11 = n_15 * make_float3 (_S764);
    float _S765 = (F32_abs((_S763)));
    float _S766 = material_23.roughness;
    float _S767 = _S766 * _S766;
    AnisotropicFrame _S768 = anisotropicFrame(material_23, n_i_11);
    float3  _S769 = sampleHalfVector(_S762, n_i_11, _S767, _S768, &random_state_20);
    BSDFLobes _S770 = bsdfLobes(in_dir_13, _S762, n_i_11, _S769, material_23, eta_i_18, eta_o_18, _S768);
    BSDFLobes lobes_13 = _S770;
    float _S771 = translucentShare(material_23);
    (&lobes_13)->translucent_share = _S771;
    Random _S772 = pcg(random_state_20);
    random_state_20 = _S772.state;
    bool _S773 = (_S772.value) < ((&lobes_13)->p_sheen_velvet);
    if(_S773)
    {
        SampleBSDF _S774 = sheenVelvetSample(n_i_11, _S765, _S767, material_23, lobes_13, eta_i_18, eta_o_18, random_state_20);
        return _S774;
    }
    float _S775 = _S772.value - (&lobes_13)->p_sheen_velvet;
    bool _S776 = _S775 < ((&lobes_13)->p_diffuse);
    if(_S776)
    {
        SampleBSDF _S777 = diffuseSample(_S775, n_i_11, _S765, _S767, material_23, lobes_13, eta_i_18, eta_o_18, random_state_20);
        return _S777;
    }
    bool _S778 = _S775 < ((&lobes_13)->p_diffuse + (&lobes_13)->p_refract);
    if(_S778)
    {
        SampleBSDF _S779 = refractSample(_S769, n_i_11, _S765, _S767, material_23, lobes_13, eta_i_18, eta_o_18, random_state_20);
        return _S779;
    }
    SampleBSDF _S780 = reflectSample(in_dir_13, _S769, n_i_11, _S765, _S767, material_23, lobes_13, eta_i_18, eta_o_18, random_state_20);
    return _S780;
}

__device__ bool withinInverseFootprint(float pdf_10, bool diffuse_0, float prev_cos_0, float distance_4, float threshold_1)
{
    bool _S781 = pdf_10 > 0.0f;
    bool _S782;
    if(_S781)
    {
        if(diffuse_0)
        {
            _S782 = true;
        }
        else
        {
            _S782 = (pdf_10 * prev_cos_0 / (distance_4 * distance_4) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S782 = false;
    }
    return _S782;
}

__device__ bool roughLobe(float pdf_11, bool diffuse_1, float roughness_1)
{
    bool _S783 = pdf_11 > 0.0f;
    bool _S784;
    if(_S783)
    {
        if(diffuse_1)
        {
            _S784 = true;
        }
        else
        {
            _S784 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S784 = false;
    }
    return _S784;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S785 = layers_0 > 1U;
    bool _S786;
    if(_S785)
    {
        _S786 = refracting_0 != passed_0;
    }
    else
    {
        _S786 = false;
    }
    return _S786;
}

static __device__ float widened_0(float spread_0, float pdf_12, bool delta_0)
{
    float _S787 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_12))))), (3.14159274101257324f)));
    bool _S788 = !delta_0;
    float _S789 = _slang_select(_S788, _S787,0.0f);
    return spread_0 + _S789;
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

static __device__ Shift walk_0(Domain * dom_0, Reservoir * r_1, bool replay_1, float scale_1, Selection * sel_1)
{
    float spread_1;
    bool turned_1;
    bool is_inside_5;
    bool viewed_0;
    bool _S790;
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
    int _S791;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_3;
    float sky_pdf_1;
    float spread_3;
    float width_4;
    uint b_7;
    float3  _S792 = make_float3 (0.0f);
    Shift _S793 = Shift_x24init_0(_S792, 0.0f);
    uint _S794 = r_1->path;
    uint _S795 = extractBits_0(r_1->path, 0U, 5U);
    uint _S796 = extractBits_0(_S794, 5U, 5U);
    uint _S797 = extractBits_0(_S794, 10U, 2U);
    uint _S798 = extractBits_0(_S794, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S799 = _S798 >= 3U;
        uint _S800 = _slang_select(_S799, 1U,0U);
        uint _S801 = _S795 + _S800;
        uint _S802 = (fcptMaxBounces());
        passes_0 = _S801 > _S802;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S793;
    }
    uint _S803 = _S796 - 1U;
    bool _S804 = _S798 == 3U;
    uint _S805 = _slang_select(_S804, 1U,0U);
    uint _S806 = _S795 + _S805;
    bool _S807 = _S797 == 0U;
    uint _S808 = _slang_select(_S807, _S806,_S803);
    FKHit _S809 = (fcptReservoirHit((*r_1)));
    float3  _S810 = dom_0->x0;
    float3  _S811 = dom_0->x1 - dom_0->x0;
    float3  _S812 = ((((_S811)) * make_float3(rnorm3df(((_S811)).x, ((_S811)).y, ((_S811)).z))));
    FKRay _S813 = Ray_x24init_0(dom_0->x1, _S812);
    FKRay ray_2 = _S813;
    FKHit hit_1 = dom_0->hit;
    float3  scatter_in_0 = _S792;
    float3  throughput_6 = make_float3 (1.0f);
    float3  weight_1 = throughput_6;
    float3  glowed_0 = _S792;
    float3  extinction_in_0 = _S792;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S814 = dom_0->spread;
    float _S815 = dom_0->width;
    float _S816 = length_0(_S811);
    NEEVertex _S817 = NEEVertex_x24init_0(true, 0.0f, _S792, _S792, _S792);
    NEEVertex nee_vertex_0 = _S817;
    Vertex _S818 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S818;
    Reservoir _S819 = (Reservoir{});
    Reservoir chain_0 = _S819;
    uint _S820 = r_1->seed;
    (&chain_0)->seed = r_1->seed;
    (&ray_2)->origin = _S810;
    (&hit_1)->distance = _S816;
    FKMedium _S821 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_1)->distance), (&filling_2)));
    uint _S822 = filling_2;
    bool _S823 = (fcptVaryingUsed());
    uint _S824 = _slang_select(_S823, _S822,4294967295U);
    filling_2 = _S824;
    scatter_in_0 = _S821.scatter;
    extinction_in_0 = _S821.extinction;
    g_in_0 = _S821.g;
    Reservoir _S825 = chain_0;
    uint _S826 = filling_2;
    for(;;)
    {
        bool _S827 = (fcptVaryingUsed());
        if(_S827)
        {
            passes_0 = _S826 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S828 = (fcptMajorant((_S826)));
            spread_1 = _S828;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S808;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S797 == 1U;
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
            ended_0 = _S793;
            sky_pdf_0 = 0.0f;
            spread_1 = _S814;
            width_2 = _S815;
            density_2 = 1.0f;
            throughput_5 = throughput_6;
            b_6 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S829 = (&prev_0)->rough;
        if(_S829)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S830 = stream(_S820, 384U);
        uint tracking_0 = _S830;
        weight_1 = throughput_6;
        glowed_0 = _S792;
        b_6 = 4294967295U;
        throughput_5 = throughput_6;
        density_2 = 1.0f;
        threshold_2 = _S814;
        width_2 = _S815;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_1)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S791 = int(1);
                break;
            }
            uint _S831 = b_6 + 320U;
            bool _S832 = b_6 == 4294967295U;
            uint _S833 = _slang_select(_S832, 384U,_S831);
            uint _S834 = stream(_S820, _S833);
            Random _S835 = pcg(_S834);
            float _S836 = freeFlight_0(_S835.value, spread_1);
            if(passes_0)
            {
                float3  _S837 = (&ray_2)->origin;
                float3  _S838 = (&ray_2)->unit_direction;
                float _S839 = (&hit_1)->distance;
                uint _S840 = _slang_select(_S832, 0U,b_6);
                uint _S841 = (&prev_0)->lobe;
                uint _S842 = _slang_select(_S832, 3U,_S841);
                float _S843 = (fcptTrackMedium((_S826), (_S837), (_S838), (_S839), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S840), (_S842), (_S832)));
                geometry_density_2 = _S843;
            }
            else
            {
                geometry_density_2 = _S836;
            }
            bool _S844 = !(geometry_density_2 < ((&hit_1)->distance));
            if(_S844)
            {
                _S791 = int(1);
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
                float3  _S845 = throughput_5 * glowed_0 / make_float3 (density_2);
                float3  _S846 = sel_1->glow + _S845;
                sel_1->glow = _S846;
            }
            else
            {
            }
            glowed_0 = _S792;
            uint b_8 = b_6 + 1U;
            float3  _S847 = (&ray_2)->origin + make_float3 (geometry_density_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S847;
            float3  _S848 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, geometry_density_2, true);
            float3  _S849 = weight_1;
            float3  _S850 = _slang_select(passes_0, _S849,_S848);
            float3  throughput_7 = throughput_5 * _S850;
            uint _S851 = stream(_S820, b_8 + 320U);
            tracking_0 = _S851;
            weight_1 = throughput_6;
            float width_5 = width_2 + threshold_2 * geometry_density_2;
            float _S852 = threshold_2 + 3.14159274101257324f;
            bool _S853 = scatterSampled_0(replay_1, b_8, _S808, passes_0);
            TreeSample _S854 = TreeSample_x24init_0(_S792, _S792, 0.0f, 0U);
            if(_S853)
            {
                float3  _S855 = (&ray_2)->origin;
                float3  _S856 = (&ray_2)->unit_direction;
                float3  _S857 = (&ray_2)->unit_direction;
                uint _S858 = stream(_S820, b_8 + 64U);
                float3  _S859 = extinction_in_0;
                float3  _S860 = extinction_in_0;
                uint2  _S861 = make_uint2 (_S826);
                float3  _S862 = (&ray_2)->unit_direction;
                uint _S863 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                FKHit _S864 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S865 = _S864;
                ShadowContext _S866 = ShadowContext_x24init_0(_S859, _S860, _S861, _S862, b_8, _S863, false, geometry_density_2, width_5, &_S865, false);
                ShadowContext _S867 = _S866;
                TreeSample _S868 = sampleLightTree_0(_S855, _S856, _S857, 0.0f, true, _S858, &_S867);
                light_3 = _S868;
            }
            else
            {
                light_3 = _S854;
            }
            float _S869 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S870 = (fcptMaxBounces());
            bool _S871 = b_8 < _S870;
            if(_S871)
            {
                is_inside_5 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_5 = false;
            }
            float _S872 = _slang_select(is_inside_5, _S869,0.0f);
            float3  _S873 = throughput_7 * light_3.radiance;
            float _S874 = powerHeuristic(light_3.density, _S872);
            float3  _S875 = _S873 * make_float3 (_S869 * _S874);
            float3  _S876 = _slang_select(_S853, _S875,_S792);
            if(replay_1)
            {
                viewed_0 = b_8 == _S808;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S877 = _S797 == 2U;
                if(_S877)
                {
                    float _S878 = rgb_to_greyscale(_S876);
                    passes_0 = _S878 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S879 = Shift_x24init_0(_S876, 1.0f);
                    _S791 = int(0);
                    ended_0 = _S879;
                    spread_1 = _S852;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_7;
                    layer_0 = b_8;
                    break;
                }
                _S791 = int(0);
                ended_0 = _S793;
                spread_1 = _S852;
                geometry_density_2 = width_5;
                chain_throughput_0 = throughput_7;
                layer_0 = b_8;
                break;
            }
            bool _S880 = !replay_1;
            if(_S880)
            {
                Reservoir candidate_2 = _S825;
                uint _S881 = extractBits_0(_S825.path, 10U, 2U);
                bool _S882 = _S881 == 1U;
                if(_S882)
                {
                    float3  _S883 = safeDivide(_S876, _S792);
                    (&candidate_2)->radiance = _S883;
                }
                else
                {
                    uint _S884 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                    uint _S885 = insertBits_0(_S884, 2U, 10U, 2U);
                    (&candidate_2)->path = _S885;
                }
                Reservoir _S886 = withEnd(candidate_2, 0U, b_8, _S876);
                offer(sel_1, _S886, _S876 * make_float3 (scale_1) / make_float3 (density_2));
                float _S887 = survivalProbability(throughput_7, density_2);
                uint _S888 = stream(_S820, b_8 + 128U);
                Random _S889 = pcg(_S888);
                bool _S890 = _S887 < (_S889.value);
                if(_S890)
                {
                    _S790 = true;
                }
                else
                {
                    uint _S891 = (fcptMaxBounces());
                    _S790 = b_8 >= _S891;
                }
                if(_S790)
                {
                    _S791 = int(0);
                    ended_0 = _S793;
                    spread_1 = _S852;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_7;
                    layer_0 = b_8;
                    break;
                }
                float _S892 = density_2 * _S887;
                density_2 = _S892;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S893 = stream(_S820, b_8);
            float3  _S894 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S893, &phase_pdf_0);
            (&ray_2)->unit_direction = _S894;
            NEEVertex _S895 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S792, (&ray_2)->origin);
            nee_vertex_0 = _S895;
            Vertex _S896 = scatteredVertex_0(false);
            prev_0 = _S896;
            float _S897 = (&prev_0)->pdf;
            FKRay _S898 = ray_2;
            FKHit _S899 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S900 = (fcptTraverseInstanceBVH((_S898), (true), (4.294967296e+09f), (false), (_S899), (false)));
            hit_1 = _S900;
            b_6 = b_8;
            throughput_5 = throughput_7;
            threshold_2 = _S852;
            width_2 = width_5;
            sky_pdf_0 = _S897;
        }
        if(_S791 != int(1))
        {
            width_2 = geometry_density_2;
            throughput_5 = chain_throughput_0;
            b_6 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S793;
        spread_1 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S901 = b_6 == 4294967295U;
    bool _S902 = ((&hit_1)->instance_index) == 4294967295U;
    if(_S902)
    {
        bool _S903 = !(&nee_vertex_0)->none;
        float _S904 = _slang_select(_S903, sky_pdf_0,0.0f);
        float _S905 = escapeWeight_0(_S904, (&ray_2)->unit_direction);
        float3  _S906 = environment_0((&ray_2)->unit_direction, b_6, (&prev_0)->lobe);
        float3  _S907 = throughput_5 * _S906;
        if(replay_1)
        {
            bool _S908 = b_6 == _S808;
            if(_S908)
            {
                passes_0 = _S797 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S907 * make_float3 (_S905) / make_float3 (r_1->jac), density_2 / r_1->jac);
            }
            if(_S807)
            {
                passes_0 = _S804;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_6 == _S795;
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
                return Shift_x24init_0(_S907 * make_float3 (_S905), 1.0f);
            }
            return _S793;
        }
        Reservoir candidate_3 = chain_0;
        uint _S909 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S910 = _S909 == 1U;
        if(_S910)
        {
            uint _S911 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S912 = _S911 == b_6;
            float _S913 = _slang_select(_S912, 1.0f,_S905);
            float3  _S914 = safeDivide(_S907 * make_float3 (_S913), _S792);
            (&candidate_3)->radiance = _S914;
        }
        else
        {
            bool _S915 = (&prev_0)->rough;
            if(_S915)
            {
                uint _S916 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                uint _S917 = insertBits_0(_S916, 3U, 10U, 2U);
                uint _S918 = insertBits_0(_S917, (&prev_0)->lobe, 15U, 3U);
                bool _S919 = (&prev_0)->inside;
                uint _S920 = _slang_select(_S919, 1U,0U);
                uint _S921 = insertBits_0(_S918, _S920, 22U, 1U);
                (&candidate_3)->path = _S921;
                (&candidate_3)->jac = (&prev_0)->pdf;
                (&candidate_3)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S922 = _S907 * make_float3 (_S905);
        Reservoir _S923 = withEnd(candidate_3, 3U, b_6, _S922);
        offer(sel_1, _S923, _S922 * make_float3 (scale_1) / make_float3 (density_2));
        return _S793;
    }
    float3  _S924 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S924;
    bool _S925 = (fcptVaryingUsed());
    if(_S925)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S926 = !replay_1;
        if(_S926)
        {
            float3  _S927 = throughput_5 * glowed_0 / make_float3 (density_2);
            float3  _S928 = sel_1->glow + _S927;
            sel_1->glow = _S928;
        }
        float3  _S929 = throughput_5 * weight_1;
        throughput_5 = _S929;
    }
    else
    {
        float3  _S930 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
        float3  _S931 = throughput_5 * _S930;
        throughput_5 = _S931;
    }
    float _S932 = width_2 + spread_1 * (&hit_1)->distance;
    uint _S933 = b_6 + 1U;
    b_6 = _S933;
    layer_0 = 0U;
    width_2 = _S932;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S792;
    float3  reconnection_0 = _S792;
    viewed_0 = _S901;
    for(;;)
    {
        bool _S934 = ((&hit_1)->is_point_light) == 1U;
        if(replay_1)
        {
            _S790 = _S797 == 1U;
        }
        else
        {
            _S790 = false;
        }
        bool _S935;
        if(_S790)
        {
            _S935 = b_6 == _S796;
        }
        else
        {
            _S935 = false;
        }
        bool _S936;
        if(_S935)
        {
            bool _S937 = ((&hit_1)->instance_index) != (_S809.instance_index);
            if(_S937)
            {
                _S936 = true;
            }
            else
            {
                _S936 = ((&hit_1)->triangle_index) != (_S809.triangle_index);
            }
        }
        else
        {
            _S936 = false;
        }
        if(_S936)
        {
            return _S793;
        }
        FKMedium _S938 = Medium_x24init_0(_S792, _S792, 0.0f);
        BSDFMaterial _S939 = Material_x24init_0(_S792, _S792, 0.0f, 0.0f, 0.0f, 0.0f, _S792, throughput_6, 1.0f, _S792, _S792, 0.5f, 0.0f, 0.0f, _S792, 0.0f);
        FKMedium _S940 = _S938;
        FKSurface _S941 = Surface_x24init_0(_S792, _S792, 0.0f, &_S939, false, 0U, 1.0f, false, &_S940, 4294967295U, _S792);
        bool _S942 = !_S934;
        bool scatter_2;
        bool is_inside_6;
        float3  throughput_8;
        FKSurface surface_11;
        if(_S942)
        {
            uint _S943 = stream(_S820, b_6);
            uint _S944 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKSurface _S945 = (fcptSurfaceAtPath((hit_1), ((&ray_2)->origin), (_S943), (width_2), (layer_0), (b_6), (_S944), ((&ray_2)->unit_direction)));
            bool _S946 = !passes_0;
            FKSurface _S947 = _S945;
            FKSurface _S948 = emitting_0(&_S947, _S946);
            uint _S949 = stream(_S820, b_6 + 256U);
            Random _S950 = pcg(_S949);
            FKSurface _S951 = _S948;
            FKSurface _S952 = uncovered_0(&_S951, _S950.value);
            float _S953 = facingSign(_S952.material.transmission, _S952.geometry_n, (&ray_2)->unit_direction);
            bool _S954 = _S953 < 0.0f;
            bool _S955 = (_S952.material.transmission) > 0.0f;
            if(_S955)
            {
                bool _S956 = arrivesBehind_0((&ray_2)->unit_direction, _S952.geometry_n);
                scatter_2 = _S956;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S957 = _S952;
            FKSurface _S958 = facingRay_0(&_S957, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S959 = arrivesBehind_0((&ray_2)->unit_direction, _S958.geometry_n);
                is_inside_6 = _S959;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S960 = beerLambert((&hit_1)->distance, _S958.material.absorption);
                float3  _S961 = throughput_5 * _S960;
                throughput_8 = _S961;
            }
            else
            {
                throughput_8 = throughput_5;
            }
            bool _S962 = !_S958.skip;
            float geometry_density_3 = geometryDensity(_S958.geometry_n, (&ray_2)->unit_direction, (&hit_1)->distance);
            bool _S963 = b_6 == _S933;
            if(_S963)
            {
                float _S964 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S964;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S965 = geometry_density_2;
            scatter_2 = _S962;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S965;
            surface_11 = _S958;
            turned_1 = _S954;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_11 = _S941;
            throughput_8 = throughput_5;
            is_inside_6 = is_inside_5;
        }
        bool _S966 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S967 = surface_11;
        FKSurface _S968 = surface_11;
        float _S969 = dot_0(surface_11.smooth_n, - (&ray_2)->unit_direction);
        float2  _S970 = vertexEta(_S967.material, _S969);
        bool _S971;
        if(scatter_2)
        {
            bool _S972 = neeDecision(_S967.material, _S969, _S970.x, _S970.y);
            _S971 = _S972;
        }
        else
        {
            _S971 = false;
        }
        bool _S973;
        if(passes_0)
        {
            _S973 = true;
        }
        else
        {
            _S973 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S973)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S971;
        }
        bool _S974 = (fcptHairUsed());
        bool _S975;
        if(_S974)
        {
            float3  _S976 = surface_11.hair;
            _S975 = (dot_0(_S976, _S976)) > 0.0f;
        }
        else
        {
            _S975 = false;
        }
        bool _S977;
        if(_S975)
        {
            _S977 = true;
        }
        else
        {
            BSDFMaterial _S978 = _S967.material;
            bool _S979 = isTranslucent_0(&_S978);
            _S977 = _S979;
        }
        bool _S980;
        if(_S977)
        {
            _S980 = true;
        }
        else
        {
            bool _S981 = (_S967.material.transmission) > 0.0f;
            if(_S981)
            {
                uint _S982 = (fcptLayers((hit_1)));
                _S980 = _S982 == 1U;
            }
            else
            {
                _S980 = false;
            }
        }
        float3  emission_0;
        if(_S934)
        {
            float3  _S983 = (fcptCalculatePointLightContrib(((&hit_1)->instance_index)));
            emission_0 = _S983;
        }
        else
        {
            emission_0 = _S967.material.emissive;
        }
        bool _S984 = !replay_1;
        bool _S985;
        if(_S984)
        {
            _S985 = true;
        }
        else
        {
            _S985 = b_6 >= _S808;
        }
        bool _S986;
        if(_S985)
        {
            float _S987 = rgb_to_greyscale(emission_0);
            _S986 = _S987 > 0.0f;
        }
        else
        {
            _S986 = false;
        }
        float3  emission_1;
        if(_S986)
        {
            NEEVertex _S988 = nee_vertex_0;
            FKHit _S989 = hit_1;
            float _S990 = emissionWeight_0(&_S988, &_S989, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S990);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S991;
        if(replay_1)
        {
            _S991 = _S797 == 1U;
        }
        else
        {
            _S991 = false;
        }
        bool _S992;
        if(_S991)
        {
            _S992 = b_6 > _S796;
        }
        else
        {
            _S992 = false;
        }
        bool _S993;
        if(_S992)
        {
            _S993 = b_6 == _S795;
        }
        else
        {
            _S993 = false;
        }
        bool _S994;
        if(_S993)
        {
            bool _S995 = _S798 == 1U;
            if(_S995)
            {
                _S994 = true;
            }
            else
            {
                _S994 = _S798 == 2U;
            }
        }
        else
        {
            _S994 = false;
        }
        if(_S994)
        {
            bool _S996 = _S934 != (_S798 == 2U);
            if(_S996)
            {
                return _S793;
            }
            return Shift_x24init_0(throughput_8 * emission_1 / make_float3 (r_1->jac), density_2 / r_1->jac);
        }
        uint _S997 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S998 = _S997 == 1U;
        Reservoir here_0 = chain_0;
        uint _S999 = insertBits_0(0U, b_6, 5U, 5U);
        uint _S1000 = insertBits_0(_S999, 1U, 10U, 2U);
        uint _S1001 = insertBits_0(_S1000, (&prev_0)->lobe, 15U, 3U);
        bool _S1002 = (&prev_0)->inside;
        uint _S1003 = _slang_select(_S1002, 1U,0U);
        uint _S1004 = insertBits_0(_S1001, _S1003, 22U, 1U);
        (&here_0)->path = _S1004;
        float _S1005 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1005;
        fcptWithReservoirHit((&here_0), (&hit_1));
        bool _S1006;
        if(replay_1)
        {
            _S1006 = _S797 == 1U;
        }
        else
        {
            _S1006 = false;
        }
        bool _S1007;
        if(_S1006)
        {
            _S1007 = b_6 == _S796;
        }
        else
        {
            _S1007 = false;
        }
        bool _S1008 = b_6 == _S808;
        bool _S1009;
        if(_S1008)
        {
            bool _S1010 = !scatter_2;
            if(_S1010)
            {
                _S1009 = true;
            }
            else
            {
                bool _S1011 = _S797 != 1U;
                if(_S1011)
                {
                    _S1009 = _S797 != 3U;
                }
                else
                {
                    _S1009 = false;
                }
            }
        }
        else
        {
            _S1009 = false;
        }
        bool _S1012;
        if(_S1009)
        {
            _S1012 = _S797 == 2U;
        }
        else
        {
            _S1012 = false;
        }
        bool _S1013;
        if(_S1012)
        {
            _S1013 = !_S966;
        }
        else
        {
            _S1013 = false;
        }
        bool _S1014;
        if(_S1013)
        {
            _S1014 = _S798 != 4U;
        }
        else
        {
            _S1014 = false;
        }
        bool _S1015 = _S796 == _S795;
        bool _S1016;
        if(_S1015)
        {
            _S1016 = _S798 == 0U;
        }
        else
        {
            _S1016 = false;
        }
        bool _S1017;
        if(_S1016)
        {
            _S1017 = ((&hit_1)->instance_index) == (_S809.instance_index);
        }
        else
        {
            _S1017 = false;
        }
        bool _S1018;
        if(_S1017)
        {
            _S1018 = ((&hit_1)->triangle_index) == (_S809.triangle_index);
        }
        else
        {
            _S1018 = false;
        }
        bool _S1019;
        if(_S1018)
        {
            _S1019 = _S966;
        }
        else
        {
            _S1019 = false;
        }
        bool _S1020 = _slang_select(_S1007, _S1019,_S1014);
        bool _S1021;
        if(nee_0)
        {
            _S1021 = _slang_select(replay_1, _S1020,scatter_2);
        }
        else
        {
            _S1021 = false;
        }
        TreeSample _S1022 = TreeSample_x24init_0(_S792, _S792, 0.0f, 0U);
        float3  throughput_9;
        float3  lit_0;
        if(_S1021)
        {
            float3  _S1023 = (&ray_2)->origin;
            if(_S975)
            {
                throughput_9 = _S792;
            }
            else
            {
                throughput_9 = _S968.smooth_n;
            }
            FKSurface _S1024 = surface_11;
            uint _S1025 = stream(_S820, b_6 + 64U);
            uint _S1026 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKMedium _S1027 = (fcptOutsideMedium((hit_1)));
            FKSurface _S1028 = surface_11;
            FKHit _S1029 = hit_1;
            FKMedium _S1030 = _S1027;
            ShadowContext _S1031 = shadowContext_0(&_S1028, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_6, _S1026, (&hit_1)->distance, width_2, &_S1029, _S975, &_S1030);
            ShadowContext _S1032 = _S1031;
            TreeSample _S1033 = sampleLightTree_0(_S1023, throughput_9, surface_11.geometry_n, surface_11.geometry_offset, _S980, _S1025, &_S1032);
            bool _S1034 = any_0((_S1033.radiance) != _S792);
            if(_S1034)
            {
                if(_S975)
                {
                    uint _S1035 = (fcptMaxBounces());
                    bool _S1036 = b_6 < _S1035;
                    FKSurface _S1037 = surface_11;
                    TreeSample _S1038 = _S1033;
                    float3  _S1039 = hairLight_0(&_S1037, (&ray_2)->unit_direction, &_S1038, _S1036);
                    lit_0 = _S1039;
                }
                else
                {
                    float _S1040 = _S970.x;
                    float _S1041 = _S970.y;
                    uint _S1042 = (fcptMaxBounces());
                    bool _S1043 = b_6 < _S1042;
                    TreeSample _S1044 = _S1033;
                    BSDFMaterial _S1045 = _S967.material;
                    float3  _S1046 = lightBSDF_0((&ray_2)->unit_direction, &_S1044, _S968.smooth_n, _S1024.geometry_n, &_S1045, _S1040, _S1041, _S1043, surface_11.random_state);
                    lit_0 = _S1046;
                }
            }
            else
            {
                lit_0 = _S792;
            }
            light_3 = _S1033;
        }
        else
        {
            light_3 = _S1022;
            lit_0 = _S792;
        }
        bool viewed_1;
        bool refracted_5;
        bool wrong_side_0;
        bool _S1047;
        bool _S1048;
        float density_4;
        if(_S1007)
        {
            bool _S1049 = !_S966;
            if(_S1049)
            {
                return _S793;
            }
            float3  throughput_10 = throughput_8 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1015)
            {
                viewed_1 = _S798 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_10 * emission_1 / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            if(_S1015)
            {
                refracted_5 = _S798 == 0U;
            }
            else
            {
                refracted_5 = false;
            }
            if(refracted_5)
            {
                bool _S1050 = !nee_0;
                if(_S1050)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1051 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1051 > 0.0f);
                }
                if(passes_0)
                {
                    return _S793;
                }
                return Shift_x24init_0(throughput_10 * lit_0 / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            if(_S1015)
            {
                wrong_side_0 = _S798 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1052 = !nee_0;
                if(_S1052)
                {
                    return _S793;
                }
                float _S1053 = environmentPdf_0(r_1->dir);
                float3  _S1054 = skyBSDF((&ray_2)->unit_direction, r_1->dir, surface_11, _S970, is_inside_6, _S1053, surface_11.random_state);
                return Shift_x24init_0(throughput_10 * _S1054 * r_1->radiance / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            uint _S1055 = extractBits_0(_S794, 21U, 1U);
            bool _S1056 = nee_0 != (_S1055 == 1U);
            if(_S1056)
            {
                return _S793;
            }
            throughput_9 = throughput_10;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S1008;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1057 = !scatter_2;
                if(_S1057)
                {
                    refracted_5 = true;
                }
                else
                {
                    bool _S1058 = _S797 != 1U;
                    if(_S1058)
                    {
                        refracted_5 = _S797 != 3U;
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
                bool _S1059 = _S797 == 2U;
                if(_S1059)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S966;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S798 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    uint _S1060 = stream(_S820, b_6 + 448U);
                    FKRay _S1061 = ray_2;
                    FKSurface _S1062 = surface_11;
                    SkySample _S1063 = sampleSky_0(&_S1061, &_S1062, _S970, is_inside_6, _S1060, surface_11.random_state);
                    return Shift_x24init_0(throughput_8 * _S1063.color, 1.0f);
                }
                if(_S1059)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S966;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1064 = rgb_to_greyscale(light_3.radiance);
                    bool _S1065 = !(_S1064 > 0.0f);
                    if(_S1065)
                    {
                        return _S793;
                    }
                    return Shift_x24init_0(throughput_8 * lit_0, 1.0f);
                }
                if(_S807)
                {
                    passes_0 = _S798 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S934;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_8 * emission_1, 1.0f);
                }
                if(_S807)
                {
                    passes_0 = _S798 == 1U;
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
                    passes_0 = !_S966;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_8 * emission_1, 1.0f);
                }
                return _S793;
            }
            else
            {
                if(_S984)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1066 = b_6 > 0U;
                    if(_S1066)
                    {
                        Reservoir candidate_4 = chain_0;
                        if(_S998)
                        {
                            float3  _S1067 = safeDivide(throughput_8 * emission_1, chain_throughput_0);
                            (&candidate_4)->radiance = _S1067;
                        }
                        else
                        {
                            if(_S966)
                            {
                                candidate_4 = here_0;
                            }
                        }
                        float3  _S1068 = throughput_8 * emission_1;
                        Reservoir _S1069 = withEnd(candidate_4, 1U, b_6, _S1068);
                        offer(sel_1, _S1069, _S1068 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1070 = throughput_8 * emission_1;
                        float3  _S1071 = sel_1->glow + _S1070;
                        sel_1->glow = _S1071;
                    }
                    if(nee_0)
                    {
                        float3  _S1072 = throughput_8 * lit_0;
                        Reservoir candidate_5 = chain_0;
                        if(_S998)
                        {
                            float3  _S1073 = safeDivide(_S1072, chain_throughput_0);
                            (&candidate_5)->radiance = _S1073;
                        }
                        else
                        {
                            if(_S966)
                            {
                                candidate_5 = here_0;
                                uint _S1074 = insertBits_0((&candidate_5)->path, 1U, 21U, 1U);
                                (&candidate_5)->path = _S1074;
                                (&candidate_5)->dir = light_3.dir;
                                (&candidate_5)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1075 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                                uint _S1076 = insertBits_0(_S1075, 2U, 10U, 2U);
                                (&candidate_5)->path = _S1076;
                            }
                        }
                        Reservoir _S1077 = withEnd(candidate_5, 0U, b_6, _S1072);
                        offer(sel_1, _S1077, _S1072 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S975)
                        {
                            _S1047 = false;
                        }
                        else
                        {
                            bool _S1078 = environmentMapped_0();
                            _S1047 = _S1078;
                        }
                    }
                    else
                    {
                        _S1047 = false;
                    }
                    if(_S1047)
                    {
                        uint _S1079 = (fcptMaxBounces());
                        _S1048 = b_6 < _S1079;
                    }
                    else
                    {
                        _S1048 = false;
                    }
                    if(_S1048)
                    {
                        uint _S1080 = stream(_S820, b_6 + 448U);
                        FKRay _S1081 = ray_2;
                        FKSurface _S1082 = surface_11;
                        SkySample _S1083 = sampleSky_0(&_S1081, &_S1082, _S970, is_inside_6, _S1080, surface_11.random_state);
                        float3  _S1084 = throughput_8 * _S1083.color;
                        Reservoir candidate_6 = chain_0;
                        if(_S998)
                        {
                            float3  _S1085 = safeDivide(_S1084, chain_throughput_0);
                            (&candidate_6)->radiance = _S1085;
                        }
                        else
                        {
                            if(_S966)
                            {
                                candidate_6 = here_0;
                                uint _S1086 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1086;
                                (&candidate_6)->dir = _S1083.dir;
                                (&candidate_6)->radiance = _S1083.radiance;
                            }
                            else
                            {
                                uint _S1087 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                                uint _S1088 = insertBits_0(_S1087, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1088;
                            }
                        }
                        Reservoir _S1089 = withEnd(candidate_6, 4U, b_6, _S1084);
                        offer(sel_1, _S1089, _S1084 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                }
            }
            throughput_9 = throughput_8;
            density_4 = density_2;
        }
        bool _S1090;
        bool _S1091;
        bool straight_0;
        bool _S1092;
        bool _S1093;
        bool _S1094;
        bool _S1095;
        bool _S1096;
        bool _S1097;
        bool _S1098;
        bool _S1099;
        bool _S1100;
        bool _S1101;
        bool _S1102;
        bool _S1103;
        bool _S1104;
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
                viewed_1 = _S1008;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1105 = extractBits_0(_S794, 15U, 3U);
            uint _S1106 = extractBits_0(_S794, 18U, 3U);
            uint _S1107 = _slang_select(_S1007, _S1106,_S1105);
            float3  _S1108 = r_1->dir;
            bool refracted_6 = _S1107 == 1U;
            SampleBSDF _S1109 = SampleBSDF_x24init_0(_S792, _S792, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1109;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1110 = extractBits_0(_S794, 22U, 1U);
                bool _S1111 = is_inside_6 != (_S1110 == 1U);
                if(_S1111)
                {
                    return _S793;
                }
                bool _S1112 = _S797 == 1U;
                if(_S1112)
                {
                    float3  _S1113 = (fcptHitPosition((_S809)));
                    throughput_11 = _S1113;
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
                    BSDFMaterial _S1114 = _S967.material;
                    bool _S1115 = isTranslucent_0(&_S1114);
                    if(_S1115)
                    {
                        refracted_5 = _S1107 == 0U;
                    }
                    else
                    {
                        refracted_5 = false;
                    }
                    if(refracted_5)
                    {
                        float3  _S1116 = throughput_11 - (&ray_2)->origin;
                        float3  _S1117 = _slang_select(_S1112, _S1116,_S1108);
                        wrong_side_0 = (dot_0(_S968.smooth_n, _S1117) * _S969) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_5 = wrong_side_0;
                }
                if(_S1112)
                {
                    float3  _S1118 = (&ray_2)->origin;
                    FKSurface _S1119 = surface_11;
                    float3  _S1120 = - _S968.smooth_n;
                    bool _S1121 = is_inside_6 != refracted_5;
                    float3  _S1122 = _slang_select(_S1121, _S1120,_S968.smooth_n);
                    float3  _S1123 = throughput_11 - (_S1118 + make_float3 (_S1119.geometry_offset) * _S1122);
                    float3  _S1124 = ((((_S1123)) * make_float3(rnorm3df(((_S1123)).x, ((_S1123)).y, ((_S1123)).z))));
                    reconnection_1 = _S1124;
                }
                else
                {
                    reconnection_1 = _S1108;
                }
                if(_S975)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1125 = wrongSide_0(is_inside_6, refracted_5, reconnection_1, surface_11.geometry_n);
                    wrong_side_0 = _S1125;
                }
                if(wrong_side_0)
                {
                    return _S793;
                }
                float3  _S1126 = throughput_11;
                throughput_11 = reconnection_1;
                b_9 = _S1107;
                wrong_side_0 = false;
                reconnection_1 = _S1126;
            }
            else
            {
                bool _S1127 = !_S1007;
                if(_S1127)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1128;
                    if(_S975)
                    {
                        SampleBSDF _S1129 = (fcptSampleHair((surface_11.hair), (_S967.material.albedo), (_S967.material.specular_tint), ((&ray_2)->unit_direction), (surface_11.random_state)));
                        _S1128 = _S1129;
                    }
                    else
                    {
                        SampleBSDF _S1130 = sampleBSDF((&ray_2)->unit_direction, _S968.smooth_n, _S967.material, _S970.x, _S970.y, surface_11.random_state, make_float2 (0.0f));
                        _S1128 = _S1130;
                    }
                    bsdf_sampled_0 = _S1128;
                    if(_S975)
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
                            return _S793;
                        }
                        break;
                    }
                    if(_S975)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1131 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_11.geometry_n);
                        wrong_side_0 = _S1131;
                    }
                    if(wrong_side_0)
                    {
                        _S1047 = (_S967.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1047 = false;
                    }
                    if(_S1047)
                    {
                        SampleBSDF _S1132 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n, _S967.material, _S970.x, _S970.y, (&bsdf_sampled_0)->random_state, make_float2 (0.0f));
                        (&bsdf_sampled_0)->unit_direction = _S1132.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1132.refracted;
                        (&bsdf_sampled_0)->throughput = _S1132.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1133 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n)) * surface_11.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1133;
                        }
                    }
                    uint _S1134 = (&bsdf_sampled_0)->lobe;
                    float3  _S1135 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1136 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1137 = (&bsdf_sampled_0)->pdf;
                    float _S1138 = _slang_select(wrong_side_0, 0.0f,_S1137);
                    (&lobe_5)->pdf = _S1138;
                    throughput_11 = _S1135;
                    b_9 = _S1134;
                    refracted_5 = _S1136;
                }
                else
                {
                    throughput_11 = _S1108;
                    b_9 = _S1107;
                    wrong_side_0 = false;
                    refracted_5 = refracted_6;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1047 = true;
            }
            else
            {
                _S1047 = _S1007;
            }
            float3  chain_throughput_1;
            if(_S1047)
            {
                if(_S975)
                {
                    SampleBSDF _S1139 = (fcptConnectHair((surface_11.hair), (_S967.material.albedo), (_S967.material.specular_tint), ((&ray_2)->unit_direction), (throughput_11)));
                    lobe_5 = _S1139;
                }
                else
                {
                    float3  _S1140 = (&ray_2)->unit_direction;
                    float _S1141 = sign_0(_S969);
                    float3  _S1142 = _S968.smooth_n * make_float3 (_S1141);
                    float _S1143 = dot_0(_S1142, throughput_11);
                    float _S1144 = _S967.material.roughness;
                    float _S1145 = _S1144 * _S1144;
                    AnisotropicFrame _S1146 = anisotropicFrame(_S967.material, _S1142);
                    float3  _S1147 = reflectedHalf(_S1140, throughput_11);
                    bool _S1148 = b_9 == 1U;
                    if(_S1148)
                    {
                        float3  _S1149 = refractedHalf(_S1140, throughput_11, _S968.smooth_n, _S970.x, _S970.y);
                        throughput_12 = _S1149;
                    }
                    else
                    {
                        throughput_12 = _S1147;
                    }
                    bool _S1150 = b_9 == 0U;
                    if(_S1150)
                    {
                        float3  _S1151 = sampledHalf(_S1140, _S968.smooth_n, _S967.material, surface_11.random_state, _S1146);
                        throughput_13 = _S1151;
                    }
                    else
                    {
                        throughput_13 = throughput_12;
                    }
                    float3  _S1152 = negate_0(_S1140);
                    float _S1153 = _S970.x;
                    float _S1154 = _S970.y;
                    BSDFLobes _S1155 = bsdfLobes(_S1140, _S1152, _S1142, throughput_13, _S967.material, _S1153, _S1154, _S1146);
                    BSDFLobes lobe_terms_2 = _S1155;
                    float _S1156 = translucentShare(_S967.material);
                    (&lobe_terms_2)->translucent_share = _S1156;
                    switch(b_9)
                    {
                    case 0U:
                        {
                            float _S1157 = diffusePDF(_S1143, 0.0f, (F32_abs((_S969))), _S1145, lobe_terms_2, _S1153, _S1154);
                            float3  _S1158 = diffuseBSDF(throughput_11, _S1142, _S1145, _S967.material, lobe_terms_2);
                            density_6 = _S1157;
                            chain_throughput_1 = _S1158;
                            break;
                        }
                    case 1U:
                        {
                            float _S1159 = refractPDF(_S1143, dot_0(throughput_11, throughput_13), (F32_abs((_S969))), _S1145, lobe_terms_2, _S1153, _S1154);
                            float3  _S1160 = refractBSDF(throughput_11, _S1142, _S1145, _S967.material, lobe_terms_2);
                            density_6 = _S1159;
                            chain_throughput_1 = _S1160;
                            break;
                        }
                    case 4U:
                        {
                            float _S1161 = sheenVelvetPDF(_S1143, 0.0f, (F32_abs((_S969))), _S1145, lobe_terms_2, _S1153, _S1154);
                            float3  _S1162 = sheenVelvetBSDF(throughput_11, _S1142, _S1145, _S967.material, lobe_terms_2);
                            density_6 = _S1161;
                            chain_throughput_1 = _S1162;
                            break;
                        }
                    default:
                        {
                            float _S1163 = reflectPDF(_S1143, 0.0f, (F32_abs((_S969))), _S1145, lobe_terms_2, _S1153, _S1154);
                            float3  _S1164 = reflectBSDF(throughput_11, _S1142, _S1145, _S967.material, lobe_terms_2);
                            density_6 = _S1163;
                            chain_throughput_1 = _S1164;
                            break;
                        }
                    }
                    bool _S1165 = density_6 > 0.0f;
                    if(_S1165)
                    {
                        SampleBSDF _S1166 = SampleBSDF_x24init_0(throughput_11, chain_throughput_1, surface_11.random_state, _S1148, b_9, density_6);
                        lobe_5 = _S1166;
                    }
                }
            }
            bool _S1167 = b_9 == 0U;
            if(_S1167)
            {
                _S1048 = true;
            }
            else
            {
                _S1048 = b_9 == 4U;
            }
            if(_S975)
            {
                _S1090 = false;
            }
            else
            {
                bool _S1168 = !_S1048;
                if(_S1168)
                {
                    bool _S1169 = (_S967.material.roughness) == 0.0f;
                    if(_S1169)
                    {
                        _S1090 = true;
                    }
                    else
                    {
                        bool _S1170 = b_9 == 1U;
                        if(_S1170)
                        {
                            _S1090 = (_S970.x) == (_S970.y);
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
            }
            bool _S1171 = !_S975;
            if(_S1171)
            {
                _S1091 = b_9 == 1U;
            }
            else
            {
                _S1091 = false;
            }
            if(_S1091)
            {
                straight_0 = (_S967.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1092 = _S1171;
            }
            else
            {
                _S1092 = false;
            }
            if(_S1092)
            {
                _S1093 = b_9 == 1U;
            }
            else
            {
                _S1093 = false;
            }
            if(_S1093)
            {
                _S1094 = (_S970.x) == (_S970.y);
            }
            else
            {
                _S1094 = false;
            }
            BSDFMaterial _S1172 = _S967.material;
            bool _S1173 = isTranslucent_0(&_S1172);
            if(_S1173)
            {
                _S1095 = _S1167;
            }
            else
            {
                _S1095 = false;
            }
            if(_S1095)
            {
                _S1096 = (dot_0(throughput_11, surface_11.geometry_n)) < 0.0f;
            }
            else
            {
                _S1096 = false;
            }
            if(nee_0)
            {
                _S1097 = !_S1090;
            }
            else
            {
                _S1097 = false;
            }
            if(_S1097)
            {
                _S1098 = !wrong_side_0;
            }
            else
            {
                _S1098 = false;
            }
            if(_S1098)
            {
                float _S1174 = (&lobe_5)->pdf;
                float3  _S1175 = (&ray_2)->origin;
                float3  _S1176 = _slang_select(_S980, _S792,_S968.smooth_n);
                float3  _S1177 = (&ray_2)->origin;
                FKSurface _S1178 = surface_11;
                float3  _S1179 = - _S968.smooth_n;
                float3  _S1180 = _slang_select(_S1096, _S1179,_S968.smooth_n);
                NEEVertex _S1181 = NEEVertex_x24init_0(false, _S1174, _S1175, _S1176, _S1177 + make_float3 (_S1178.geometry_offset) * _S1180);
                nee_vertex_0 = _S1181;
            }
            else
            {
                if(_S975)
                {
                    _S1099 = true;
                }
                else
                {
                    bool _S1182 = b_9 != 1U;
                    if(_S1182)
                    {
                        _S1099 = true;
                    }
                    else
                    {
                        _S1099 = (_S970.x) != (_S970.y);
                    }
                }
                if(_S1099)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1183 = withinInverseFootprint((&lobe_5)->pdf, _S1048, (&prev_0)->cos, (&hit_1)->distance, threshold_2);
            bool _S1184 = roughLobe((&lobe_5)->pdf, _S1048, _S967.material.roughness);
            if(_S1007)
            {
                bool _S1185 = !_S1183;
                if(_S1185)
                {
                    return _S793;
                }
                bool _S1186 = _S798 != 1U;
                if(_S1186)
                {
                    _S1099 = _S798 != 2U;
                }
                else
                {
                    _S1099 = false;
                }
                if(_S1099)
                {
                    float _S1187 = (&lobe_5)->pdf;
                    float _S1188 = _slang_select(nee_0, _S1187,0.0f);
                    float _S1189 = escapeWeight_0(_S1188, _S1108);
                    if(_S1015)
                    {
                        passes_0 = _S804;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1190 = _slang_select(passes_0, _S1189,1.0f);
                    return Shift_x24init_0(throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_1->radiance * make_float3 (_S1190) / make_float3 (r_1->jac), density_4 * (&lobe_5)->pdf / r_1->jac);
                }
                float3  _S1191 = throughput_9 * make_float3 ((&lobe_5)->pdf);
                float _S1192 = density_4 * (&lobe_5)->pdf;
                throughput_12 = _S1191;
                density_6 = _S1192;
            }
            else
            {
                throughput_12 = throughput_9;
                density_6 = density_4;
            }
            uint _S1193 = (fcptLayers((hit_1)));
            bool _S1194 = b_9 == 1U;
            bool _S1195 = passesLayer_0(_S1193, _S1194, passes_0);
            if(viewed_1)
            {
                _S1099 = _S1195;
            }
            else
            {
                _S1099 = false;
            }
            if(_S1099)
            {
                return _S793;
            }
            if(replay_1)
            {
                _S1100 = b_6 <= _S808;
            }
            else
            {
                _S1100 = false;
            }
            if(_S1100)
            {
                _S1101 = _S966;
            }
            else
            {
                _S1101 = false;
            }
            if(_S1101)
            {
                _S1102 = _S1183;
            }
            else
            {
                _S1102 = false;
            }
            if(_S1102)
            {
                _S1103 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1103 = !_S1184;
                }
                else
                {
                    _S1103 = false;
                }
            }
            if(_S1103)
            {
                return _S793;
            }
            if(viewed_1)
            {
                float3  _S1196 = throughput_12 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1197 = (&lobe_5)->pdf;
                throughput_13 = _S1196;
                sky_pdf_2 = _S1197;
            }
            else
            {
                float3  _S1198 = throughput_12 * max_0((&lobe_5)->throughput, _S792);
                throughput_13 = _S1198;
                sky_pdf_2 = density_6;
            }
            if(_S984)
            {
                _S1104 = !_S998;
            }
            else
            {
                _S1104 = false;
            }
            bool _S1199;
            if(_S1104)
            {
                _S1199 = _S966;
            }
            else
            {
                _S1199 = false;
            }
            bool _S1200;
            if(_S1199)
            {
                _S1200 = _S1183;
            }
            else
            {
                _S1200 = false;
            }
            if(_S1200)
            {
                chain_0 = here_0;
                uint _S1201 = insertBits_0((&chain_0)->path, b_9, 18U, 3U);
                uint _S1202 = _slang_select(nee_0, 1U,0U);
                uint _S1203 = insertBits_0(_S1201, _S1202, 21U, 1U);
                (&chain_0)->path = _S1203;
                float _S1204 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1204;
                (&chain_0)->dir = throughput_11;
                chain_throughput_1 = throughput_13;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1205 = surface_11;
            Vertex _S1206 = Vertex_x24init_0(_S1184, b_9, (&lobe_5)->pdf, (F32_abs((dot_0(surface_11.geometry_n, throughput_11)))), is_inside_6);
            prev_0 = _S1206;
            float _S1207 = (&lobe_5)->pdf;
            bool _S1208;
            if(_S1194)
            {
                _S1208 = (_S970.x) == (_S970.y);
            }
            else
            {
                _S1208 = false;
            }
            float sky_pdf_3 = _slang_select(_S1208, sky_pdf_0,_S1207);
            float _S1209 = _slang_select(_S975, 0.0f,sky_pdf_3);
            float _S1210 = widened_0(spread_1, (&lobe_5)->pdf, _S1090);
            bool _S1211;
            if(refracted_5)
            {
                _S1211 = !_S1096;
            }
            else
            {
                _S1211 = false;
            }
            bool is_inside_7;
            if(_S1211)
            {
                bool _S1212 = !is_inside_6;
                is_inside_7 = _S1212;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1213 = surface_11;
            bool _S1214 = boundsVolume_0(&_S1213);
            bool _S1215;
            if(_S1214)
            {
                _S1215 = !_S1195;
            }
            else
            {
                _S1215 = false;
            }
            if(_S1215)
            {
                FKSurface faced_2 = surface_11;
                float3  _S1216 = - _S1205.geometry_n;
                float3  _S1217 = _slang_select(turned_1, _S1216,_S1205.geometry_n);
                (&faced_2)->geometry_n = _S1217;
                FKMedium _S1218 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1219 = (fcptOutsideMedium((hit_1)));
                FKSurface _S1220 = faced_2;
                FKMedium _S1221 = _S1218;
                FKMedium _S1222 = _S1219;
                MediumSides _S1223 = mediumSides_0(&_S1220, &_S1221, filling_2, (&ray_2)->unit_direction, &_S1222);
                bool _S1224 = leavesInFront_0((&faced_2)->geometry_n, throughput_11, _S1205.geometry_n);
                float3  _S1225 = _slang_select(_S1224, _S1223.front.scatter,_S1223.behind.scatter);
                scatter_in_0 = _S1225;
                float3  _S1226 = _slang_select(_S1224, _S1223.front.extinction,_S1223.behind.extinction);
                extinction_in_0 = _S1226;
                float _S1227 = _slang_select(_S1224, _S1223.front.g,_S1223.behind.g);
                g_in_0 = _S1227;
                uint _S1228 = _S1223.fillings.x;
                uint _S1229 = _S1223.fillings.y;
                uint _S1230 = _slang_select(_S1224, _S1229,_S1228);
                bool _S1231 = (fcptVaryingUsed());
                uint _S1232 = _slang_select(_S1231, _S1230,4294967295U);
                filling_2 = _S1232;
            }
            (&ray_2)->unit_direction = throughput_11;
            bool _S1233 = !_S1195;
            if(_S1233)
            {
                FKSurface _S1234 = surface_11;
                float _S1235 = _slang_select(straight_0, 0.0f,_S1234.geometry_offset);
                float3  _S1236 = - _S968.smooth_n;
                bool _S1237 = is_inside_7 != _S1096;
                float3  _S1238 = _slang_select(_S1237, _S1236,_S968.smooth_n);
                float3  _S1239 = (&ray_2)->origin + make_float3 (_S1235) * _S1238;
                (&ray_2)->origin = _S1239;
            }
            throughput_12 = throughput_13;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1195;
            viewed_1 = _S1094;
            sky_pdf_2 = _S1209;
            spread_4 = _S1210;
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
        float density_7;
        if(_S984)
        {
            if(_S934)
            {
                float3  _S1240 = throughput_12 * emission_1;
                Reservoir candidate_7 = chain_0;
                uint _S1241 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1242 = _S1241 == 1U;
                if(_S1242)
                {
                    float3  _S1243 = safeDivide(_S1240, chain_throughput_0);
                    (&candidate_7)->radiance = _S1243;
                }
                Reservoir _S1244 = withEnd(candidate_7, 2U, b_6, _S1240);
                offer(sel_1, _S1244, _S1240 * make_float3 (scale_1) / make_float3 (density_6));
            }
            if(_S934)
            {
                refracted_5 = true;
            }
            else
            {
                refracted_5 = scatter_2;
            }
            if(refracted_5)
            {
                float _S1245 = survivalProbability(throughput_12, density_6);
                density_7 = _S1245;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1246 = stream(_S820, b_6 + 128U);
            Random _S1247 = pcg(_S1246);
            bool _S1248 = density_7 < (_S1247.value);
            if(_S1248)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1249 = (fcptMaxBounces());
                wrong_side_0 = b_6 >= _S1249;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1250 = density_6 * density_7;
            density_7 = _S1250;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1251 = layer_0 ^ 1U;
        uint _S1252 = _slang_select(passes_0, _S1251,0U);
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
            uint _S1253 = b_9 + 1U;
            b_6 = _S1253;
            layer_0 = _S1252;
            continue;
        }
        FKRay _S1254 = ray_2;
        float _S1255 = distance_5(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_5 = _S1008;
        }
        else
        {
            refracted_5 = false;
        }
        if(refracted_5)
        {
            wrong_side_0 = _S797 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1256 = _slang_select(wrong_side_0, _S1255,4.294967296e+09f);
        bool _S1257 = !_S975;
        if(straight_0)
        {
            _S1047 = true;
        }
        else
        {
            _S1047 = _S975;
        }
        FKHit _S1258;
        if(_S1047)
        {
            _S1258 = hit_1;
        }
        else
        {
            _S1258 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
        }
        FKHit _S1259 = (fcptTraverseInstanceBVH((_S1254), (_S942), (_S1256), (_S1257), (_S1258), (viewed_1)));
        hit_1 = _S1259;
        if(replay_1)
        {
            _S1048 = _S1008;
        }
        else
        {
            _S1048 = false;
        }
        if(_S1048)
        {
            _S1090 = _S797 == 1U;
        }
        else
        {
            _S1090 = false;
        }
        if(_S1090)
        {
            _S1091 = ((&hit_1)->instance_index) == (_S809.instance_index);
        }
        else
        {
            _S1091 = false;
        }
        if(_S1091)
        {
            _S1092 = ((&hit_1)->triangle_index) == (_S809.triangle_index);
        }
        else
        {
            _S1092 = false;
        }
        if(_S1092)
        {
            (&hit_1)->uv = _S809.uv;
            float _S1260 = distance_5(reconnection_0, (&ray_2)->origin);
            (&hit_1)->distance = _S1260;
        }
        if(replay_1)
        {
            _S1093 = _S1008;
        }
        else
        {
            _S1093 = false;
        }
        if(_S1093)
        {
            _S1094 = _S797 == 3U;
        }
        else
        {
            _S1094 = false;
        }
        if(_S1094)
        {
            _S1095 = ((&hit_1)->instance_index) != 4294967295U;
        }
        else
        {
            _S1095 = false;
        }
        if(_S1095)
        {
            return _S793;
        }
        Reservoir _S1261 = chain_0;
        uint _S1262 = filling_2;
        for(;;)
        {
            bool _S1263 = (fcptVaryingUsed());
            if(_S1263)
            {
                _S1096 = _S1262 != 4294967295U;
            }
            else
            {
                _S1096 = false;
            }
            float _S1264;
            if(_S1096)
            {
                float _S1265 = (fcptMajorant((_S1262)));
                _S1264 = _S1265;
            }
            else
            {
                _S1264 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1097 = _S1008;
            }
            else
            {
                _S1097 = false;
            }
            if(_S1097)
            {
                _S1098 = _S797 == 1U;
            }
            else
            {
                _S1098 = false;
            }
            if(_S1098)
            {
                _S1099 = _S1264 > 0.0f;
            }
            else
            {
                _S1099 = false;
            }
            if(_S1099)
            {
                ended_0 = _S793;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_3 = width_2;
                density_3 = density_7;
                throughput_13 = throughput_12;
                b_9 = b_6;
                _S1100 = true;
                break;
            }
            bool _S1266 = (&prev_0)->rough;
            if(_S1266)
            {
                _S1100 = !(_S1264 > 0.0f);
            }
            else
            {
                _S1100 = false;
            }
            (&prev_0)->rough = _S1100;
            uint _S1267 = b_6 + 320U;
            bool _S1268 = b_6 == 4294967295U;
            uint _S1269 = _slang_select(_S1268, 384U,_S1267);
            uint _S1270 = stream(_S820, _S1269);
            uint tracking_1 = _S1270;
            weight_1 = throughput_6;
            glowed_0 = _S792;
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
                    _S791 = int(2);
                    break;
                }
                uint _S1271 = b_9 + 320U;
                bool _S1272 = b_9 == 4294967295U;
                uint _S1273 = _slang_select(_S1272, 384U,_S1271);
                uint _S1274 = stream(_S820, _S1273);
                Random _S1275 = pcg(_S1274);
                float _S1276 = freeFlight_0(_S1275.value, _S1264);
                if(_S1096)
                {
                    float3  _S1277 = (&ray_2)->origin;
                    float3  _S1278 = (&ray_2)->unit_direction;
                    float _S1279 = (&hit_1)->distance;
                    uint _S1280 = _slang_select(_S1272, 0U,b_9);
                    uint _S1281 = (&prev_0)->lobe;
                    uint _S1282 = _slang_select(_S1272, 3U,_S1281);
                    float _S1283 = (fcptTrackMedium((_S1262), (_S1277), (_S1278), (_S1279), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1280), (_S1282), (_S1272)));
                    spread_3 = _S1283;
                }
                else
                {
                    spread_3 = _S1276;
                }
                bool _S1284 = !(spread_3 < ((&hit_1)->distance));
                if(_S1284)
                {
                    _S791 = int(2);
                    break;
                }
                if(_S1096)
                {
                    _S1101 = _S984;
                }
                else
                {
                    _S1101 = false;
                }
                if(_S1101)
                {
                    float3  _S1285 = throughput_13 * glowed_0 / make_float3 (density_3);
                    float3  _S1286 = sel_1->glow + _S1285;
                    sel_1->glow = _S1286;
                }
                else
                {
                }
                glowed_0 = _S792;
                uint b_10 = b_9 + 1U;
                float3  _S1287 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1287;
                float3  _S1288 = flightWeight_0(scatter_in_0, extinction_in_0, _S1264, spread_3, true);
                float3  _S1289 = weight_1;
                float3  _S1290 = _slang_select(_S1096, _S1289,_S1288);
                float3  throughput_14 = throughput_13 * _S1290;
                uint _S1291 = stream(_S820, b_10 + 320U);
                tracking_1 = _S1291;
                weight_1 = throughput_6;
                float width_6 = width_3 + spread_2 * spread_3;
                float _S1292 = spread_2 + 3.14159274101257324f;
                bool _S1293 = scatterSampled_0(replay_1, b_10, _S808, _S1096);
                TreeSample light_4;
                if(_S1293)
                {
                    float3  _S1294 = (&ray_2)->origin;
                    float3  _S1295 = (&ray_2)->unit_direction;
                    float3  _S1296 = (&ray_2)->unit_direction;
                    uint _S1297 = stream(_S820, b_10 + 64U);
                    float3  _S1298 = extinction_in_0;
                    float3  _S1299 = extinction_in_0;
                    uint2  _S1300 = make_uint2 (_S1262);
                    float3  _S1301 = (&ray_2)->unit_direction;
                    uint _S1302 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                    FKHit _S1303 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                    FKHit _S1304 = _S1303;
                    ShadowContext _S1305 = ShadowContext_x24init_0(_S1298, _S1299, _S1300, _S1301, b_10, _S1302, false, spread_3, width_6, &_S1304, false);
                    ShadowContext _S1306 = _S1305;
                    TreeSample _S1307 = sampleLightTree_0(_S1294, _S1295, _S1296, 0.0f, true, _S1297, &_S1306);
                    light_4 = _S1307;
                }
                else
                {
                    light_4 = _S1022;
                }
                float _S1308 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1309 = (fcptMaxBounces());
                bool _S1310 = b_10 < _S1309;
                if(_S1310)
                {
                    _S1102 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1102 = false;
                }
                float _S1311 = _slang_select(_S1102, _S1308,0.0f);
                float3  _S1312 = throughput_14 * light_4.radiance;
                float _S1313 = powerHeuristic(light_4.density, _S1311);
                float3  _S1314 = _S1312 * make_float3 (_S1308 * _S1313);
                float3  _S1315 = _slang_select(_S1293, _S1314,_S792);
                if(replay_1)
                {
                    _S1103 = b_10 == _S808;
                }
                else
                {
                    _S1103 = false;
                }
                if(_S1103)
                {
                    bool _S1316 = _S797 == 2U;
                    if(_S1316)
                    {
                        float _S1317 = rgb_to_greyscale(_S1315);
                        _S1104 = _S1317 > 0.0f;
                    }
                    else
                    {
                        _S1104 = false;
                    }
                    if(_S1104)
                    {
                        Shift _S1318 = Shift_x24init_0(_S1315, 1.0f);
                        _S791 = int(1);
                        ended_0 = _S1318;
                        spread_3 = _S1292;
                        width_4 = width_6;
                        throughput_11 = throughput_14;
                        b_7 = b_10;
                        break;
                    }
                    _S791 = int(1);
                    ended_0 = _S793;
                    spread_3 = _S1292;
                    width_4 = width_6;
                    throughput_11 = throughput_14;
                    b_7 = b_10;
                    break;
                }
                if(_S984)
                {
                    Reservoir candidate_8 = _S1261;
                    uint _S1319 = extractBits_0(_S1261.path, 10U, 2U);
                    bool _S1320 = _S1319 == 1U;
                    if(_S1320)
                    {
                        float3  _S1321 = safeDivide(_S1315, chain_throughput_0);
                        (&candidate_8)->radiance = _S1321;
                    }
                    else
                    {
                        uint _S1322 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                        uint _S1323 = insertBits_0(_S1322, 2U, 10U, 2U);
                        (&candidate_8)->path = _S1323;
                    }
                    Reservoir _S1324 = withEnd(candidate_8, 0U, b_10, _S1315);
                    offer(sel_1, _S1324, _S1315 * make_float3 (scale_1) / make_float3 (density_3));
                    float _S1325 = survivalProbability(throughput_14, density_3);
                    uint _S1326 = stream(_S820, b_10 + 128U);
                    Random _S1327 = pcg(_S1326);
                    bool _S1328 = _S1325 < (_S1327.value);
                    if(_S1328)
                    {
                        _S1104 = true;
                    }
                    else
                    {
                        uint _S1329 = (fcptMaxBounces());
                        _S1104 = b_10 >= _S1329;
                    }
                    if(_S1104)
                    {
                        _S791 = int(1);
                        ended_0 = _S793;
                        spread_3 = _S1292;
                        width_4 = width_6;
                        throughput_11 = throughput_14;
                        b_7 = b_10;
                        break;
                    }
                    float _S1330 = density_3 * _S1325;
                    density_3 = _S1330;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1331 = stream(_S820, b_10);
                float3  _S1332 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1331, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1332;
                NEEVertex _S1333 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S792, (&ray_2)->origin);
                nee_vertex_0 = _S1333;
                Vertex _S1334 = scatteredVertex_0(is_inside_5);
                prev_0 = _S1334;
                float _S1335 = (&prev_0)->pdf;
                FKRay _S1336 = ray_2;
                FKHit _S1337 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1338 = (fcptTraverseInstanceBVH((_S1336), (true), (4.294967296e+09f), (false), (_S1337), (false)));
                hit_1 = _S1338;
                b_9 = b_10;
                throughput_13 = throughput_14;
                spread_2 = _S1292;
                width_3 = width_6;
                sky_pdf_1 = _S1335;
            }
            if(_S791 != int(2))
            {
                spread_2 = spread_3;
                width_3 = width_4;
                throughput_13 = throughput_11;
                b_9 = b_7;
                _S1100 = true;
                break;
            }
            ended_0 = _S793;
            _S1100 = false;
            break;
        }
        if(_S1100)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1101 = b_9 == b_6;
        }
        else
        {
            _S1101 = false;
        }
        bool _S1339 = ((&hit_1)->instance_index) == 4294967295U;
        if(_S1339)
        {
            bool _S1340 = !(&nee_vertex_0)->none;
            float _S1341 = _slang_select(_S1340, sky_pdf_1,0.0f);
            float _S1342 = escapeWeight_0(_S1341, (&ray_2)->unit_direction);
            float3  _S1343 = environment_0((&ray_2)->unit_direction, b_9, (&prev_0)->lobe);
            float3  _S1344 = throughput_13 * _S1343;
            if(replay_1)
            {
                bool _S1345 = b_9 == _S808;
                if(_S1345)
                {
                    passes_0 = _S797 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1344 * make_float3 (_S1342) / make_float3 (r_1->jac), density_3 / r_1->jac);
                }
                if(_S807)
                {
                    passes_0 = _S804;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_9 == _S795;
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
                    return Shift_x24init_0(_S1344 * make_float3 (_S1342), 1.0f);
                }
                return _S793;
            }
            Reservoir candidate_9 = chain_0;
            uint _S1346 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1347 = _S1346 == 1U;
            if(_S1347)
            {
                uint _S1348 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1349 = _S1348 == b_9;
                float _S1350 = _slang_select(_S1349, 1.0f,_S1342);
                float3  _S1351 = safeDivide(_S1344 * make_float3 (_S1350), chain_throughput_0);
                (&candidate_9)->radiance = _S1351;
            }
            else
            {
                bool _S1352 = (&prev_0)->rough;
                if(_S1352)
                {
                    uint _S1353 = insertBits_0(0U, b_9 + 1U, 5U, 5U);
                    uint _S1354 = insertBits_0(_S1353, 3U, 10U, 2U);
                    uint _S1355 = insertBits_0(_S1354, (&prev_0)->lobe, 15U, 3U);
                    bool _S1356 = (&prev_0)->inside;
                    uint _S1357 = _slang_select(_S1356, 1U,0U);
                    uint _S1358 = insertBits_0(_S1355, _S1357, 22U, 1U);
                    (&candidate_9)->path = _S1358;
                    (&candidate_9)->jac = (&prev_0)->pdf;
                    (&candidate_9)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1359 = _S1344 * make_float3 (_S1342);
            Reservoir _S1360 = withEnd(candidate_9, 3U, b_9, _S1359);
            offer(sel_1, _S1360, _S1359 * make_float3 (scale_1) / make_float3 (density_3));
            break;
        }
        float3  _S1361 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1361;
        bool _S1362 = (fcptVaryingUsed());
        if(_S1362)
        {
            _S1102 = filling_2 != 4294967295U;
        }
        else
        {
            _S1102 = false;
        }
        if(_S1102)
        {
            if(_S984)
            {
                float3  _S1363 = throughput_13 * glowed_0 / make_float3 (density_3);
                float3  _S1364 = sel_1->glow + _S1363;
                sel_1->glow = _S1364;
            }
            float3  _S1365 = throughput_13 * weight_1;
            throughput_11 = _S1365;
        }
        else
        {
            float3  _S1366 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
            float3  _S1367 = throughput_13 * _S1366;
            throughput_11 = _S1367;
        }
        float _S1368 = width_3 + spread_2 * (&hit_1)->distance;
        viewed_0 = _S1101;
        width_2 = _S1368;
        throughput_5 = throughput_11;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1253 = b_9 + 1U;
        b_6 = _S1253;
        layer_0 = _S1252;
    }
    return _S793;
}

static __device__ Shift shift_0(Domain * dom_1, Reservoir * r_2)
{
    Selection _S1369 = (Selection{});
    Selection sel_2 = _S1369;
    bool _S1370 = (r_2->w) <= 0.0f;
    if(_S1370)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1371 = walk_0(dom_1, r_2, true, 0.0f, &sel_2);
    return _S1371;
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
    Random _S1372 = pcg(state_4);
    Random _S1373 = pcg(_S1372.state);
    float _S1374 = 6.28318548202514648f * _S1372.value;
    float _S1375 = (F32_sqrt((-2.0f * clamp_0((F32_log((_S1373.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1373.state, _S1375 * (F32_cos((_S1374))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S1376;
    (&_S1376)->state = state_5;
    (&_S1376)->value = value_2;
    return _S1376;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S1377 = normal_distribution(state_6);
    Random _S1378 = normal_distribution(_S1377.state);
    Random _S1379 = normal_distribution(_S1378.state);
    float3  _S1380 = make_float3 (_S1377.value, _S1378.value, _S1379.value);
    float3  _S1381 = ((((_S1380)) * make_float3(rnorm3df(((_S1380)).x, ((_S1380)).y, ((_S1380)).z))));
    return RandomSphere_x24init_0(_S1379.state, _S1381);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_16)
{
    float3  _S1382 = p1_0 - p0_0;
    float3  _S1383 = p2_0 - p0_0;
    float2  _S1384 = uv1_0 - uv0_0;
    float2  _S1385 = uv2_0 - uv0_0;
    float _S1386 = _S1384.x;
    float _S1387 = _S1385.y;
    float _S1388 = _S1384.y;
    float _S1389 = _S1385.x;
    float _S1390 = _S1386 * _S1387 - _S1388 * _S1389;
    float _S1391 = 1.0f / _S1390;
    float3  t_1 = (_S1382 * make_float3 (_S1387) - _S1383 * make_float3 (_S1388)) * make_float3 (_S1391);
    float3  _S1392 = (_S1383 * make_float3 (_S1386) - _S1382 * make_float3 (_S1389)) * make_float3 (_S1391);
    float3  _S1393 = t_1 - n_16 * make_float3 (dot_0(n_16, t_1));
    float3  t_2 = ((((_S1393)) * make_float3(rnorm3df(((_S1393)).x, ((_S1393)).y, ((_S1393)).z))));
    bool _S1394 = (dot_0(cross_0(n_16, t_2), _S1392)) > 0.0f;
    float3  t_3;
    if(_S1394)
    {
        float3  _S1395 = negate_0(t_2);
        t_3 = _S1395;
    }
    else
    {
        t_3 = t_2;
    }
    float3  _S1396 = cross_0(n_16, t_3);
    return makeMatrix<float, 3, 3> (t_3, _S1396, n_16);
}

__device__ float3  tangentToWorldNormalMap(float3  v_4, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_4, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1397 = t1_0 - t0_0;
    float3  _S1398 = t2_2 - t0_0;
    float3  _S1399 = t2_2 - t1_0;
    float _S1400 = (F32_min((length_0(_S1397)), ((F32_min((length_0(_S1398)), (length_0(_S1399)))))));
    float3  _S1401 = make_float3 (distance_5(position_0, t0_0), distance_5(position_0, t1_0), distance_5(position_0, t2_2));
    float3  _S1402 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1403 = dot_0(geometry_n_5, _S1402);
    float3  _S1404 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1405 = dot_0(geometry_n_5, _S1404);
    float3  _S1406 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1407 = acos_0(abs_0(make_float3 (_S1403, _S1405, dot_0(geometry_n_5, _S1406))));
    float3  _S1408 = clamp_1(tan_0(_S1407), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_0(dot_0(_S1401 * _S1408, uvw_0), 0.0f, _S1400 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_16, float3  n_17, BSDFMaterial material_24)
{
    float3  _S1409 = negate_0(dir_16);
    float _S1410 = sign_0(dot_0(n_17, _S1409));
    float3  _S1411 = n_17 * make_float3 (_S1410);
    AnisotropicFrame _S1412 = anisotropicFrame(material_24, _S1411);
    bool _S1413 = (_S1412.alphas.x) > 0.0f;
    if(_S1413)
    {
        float _S1414 = material_24.transmission * (1.0f - material_24.metallic);
        float3  _S1415 = negate_0(_S1411);
        float3  _S1416 = anisotropicLocal(dir_16, _S1412.tangent, _S1415);
        float _S1417 = anisotropicG1(_S1416, _S1412.alphas);
        return make_float3 (_S1414 * _S1417) * material_24.albedo;
    }
    float _S1418 = material_24.transmission * (1.0f - material_24.metallic);
    float _S1419 = material_24.roughness;
    float _S1420 = smithG1(_S1419 * _S1419, (F32_abs((dot_0(n_17, dir_16)))));
    return make_float3 (_S1418 * _S1420) * material_24.albedo;
}

__device__ float hairRow(float3  in_dir_14, float3  t_4, float3  out_dir_5, uint p_5, float w_2, float alpha_17, uint nt_0)
{
    uint _S1421 = p_5 % 4U;
    float _S1422 = w_2 * HAIR_WIDTHS_0[_S1421];
    float _S1423 = (F32_asin((clamp_0(dot_0(out_dir_5, t_4), -1.0f, 1.0f)))) - (F32_asin((clamp_0(dot_0(in_dir_14, t_4), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1421] * alpha_17;
    return ((F32_asinh((_S1423 / _S1422))) / (F32_asinh((3.14159274101257324f / _S1422))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_15, float3  t_5, float3  out_dir_6, uint np_0)
{
    float3  _S1424 = worldToTangent(out_dir_6, t_5);
    float3  _S1425 = worldToTangent(in_dir_15, t_5);
    return (F32_frac((((F32_atan2((_S1424.z), (_S1424.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1425.z), (1.17549435082228751e-38f - _S1425.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_16, float3  t_6, uint p_6, float row_0, float column_0, float w_3, float alpha_18, uint nt_1, uint np_1)
{
    float3  _S1426 = worldToTangent(in_dir_16, t_6);
    uint _S1427 = p_6 % 4U;
    float _S1428 = w_3 * HAIR_WIDTHS_0[_S1427];
    float _S1429 = (F32_asin((clamp_0(dot_0(in_dir_16, t_6), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1427] * alpha_18 + _S1428 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1428))))));
    float _S1430 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1426.z), (1.17549435082228751e-38f - _S1426.x)));
    float _S1431 = (F32_cos((_S1429)));
    float3  _S1432 = tangentToWorld(make_float3 (_S1431 * (F32_cos((_S1430))), (F32_sin((_S1429))), _S1431 * (F32_sin((_S1430)))), t_6);
    return _S1432;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_18, BSDFMaterial material_25, float coverage_1)
{
    float3  _S1433;
    if((material_25.ior) == 1.0f)
    {
        float3  _S1434 = straightThrough(toward_1, n_18, material_25);
        _S1433 = _S1434;
    }
    else
    {
        _S1433 = make_float3 (0.0f);
    }
    return _S1433 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_10 = r_3;
    float3  _S1435 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_10)->f = _S1435;
    float _S1436 = r_3.jac * shifted_0.jac;
    (&candidate_10)->jac = _S1436;
    offer(sel_3, candidate_10, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S1437 = rgb_to_greyscale((&r_4)->f);
    float _S1438 = sel_4.w_sum / _S1437;
    bool _S1439 = _S1437 > 0.0f;
    float _S1440 = _slang_select(_S1439, _S1438,0.0f);
    (&r_4)->w = _S1440;
    (&r_4)->c = c_1;
    return r_4;
}

static __device__ float interpolate_0(float a_8, float b_11, float t_7)
{
    return a_8 + (b_11 - a_8) * t_7;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S1441 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S1441;
}

__device__ float2  temporalWeights(float c_2, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S1442 = c_2 * p_c_0;
    float _S1443 = c_t_0 * p_t_0;
    return make_float2 (_S1442 / (_S1442 + c_t_0 * g_previous_0), _S1443 / (_S1443 + c_2 * g_current_0));
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

__device__ Shift walk_hook(Domain dom_2, Reservoir r_5, bool replay_2, float scale_2, Selection * sel_5)
{
    Domain _S1444 = dom_2;
    Reservoir _S1445 = r_5;
    Shift _S1446 = walk_0(&_S1444, &_S1445, replay_2, scale_2, sel_5);
    return _S1446;
}

__device__ Shift shift_hook(Domain dom_3, Reservoir r_6)
{
    Domain _S1447 = dom_3;
    Reservoir _S1448 = r_6;
    Shift _S1449 = shift_0(&_S1447, &_S1448);
    return _S1449;
}

#undef Matrix
