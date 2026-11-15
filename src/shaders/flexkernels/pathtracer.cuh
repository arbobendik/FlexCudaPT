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
        float _S244 = (F32_sqrt((0.05000000074505806f)));
        float _S245 = (clamp_0((F32_sqrt(((F32_max((material_2.sheen_roughness), (0.0f)))))), _S244, 1.0f) - _S244) / (1.0f - _S244) * 23.0f;
        uint _S246 = (U32_min((uint(_S245)), (22U)));
        uint _S247 = _S243 * 24U + _S246;
        float _S248 = _S242 - float(_S243);
        float _S249 = _S245 - float(_S246);
        uint _S250 = _S247 + 24U;
        float _S251 = SHEEN_ALBEDO_0[_S247] + (SHEEN_ALBEDO_0[_S250] - SHEEN_ALBEDO_0[_S247]) * _S248;
        uint _S252 = _S247 + 1U;
        float _S253 = SHEEN_ALBEDO_0[_S252] + (SHEEN_ALBEDO_0[_S250 + 1U] - SHEEN_ALBEDO_0[_S252]) * _S248;
        float _S254 = (F32_exp((_S251 + (_S253 - _S251) * _S249)));
        float _S255 = (F32_min((_S254), (1.0f)));
        float3  _S256 = make_float3 (1.0f) - material_2.sheen * make_float3 (_S255);
        float _S257 = rgb_to_greyscale(material_2.sheen);
        float _S258 = _S257 * _S255;
        float3  _S259 = material_2.sheen / make_float3 ((F32_max((_S254), (1.0f))));
        scale_0 = _S256;
        sheen_component_0 = _S258;
        sheen_1 = _S259;
        view_1 = v_3;
    }
    else
    {
        scale_0 = _S238;
        sheen_component_0 = 0.0f;
        sheen_1 = _S239;
        view_1 = _S239;
    }
    float3  _S260 = mix_0(_S236, material_2.albedo, material_2.metallic);
    float3  F_1 = _S260 * scale_0;
    float _S261 = rgb_to_greyscale(F_1);
    float _S262 = 1.0f - material_2.metallic;
    float3  _S263 = make_float3 (1.0f) - _S236;
    float3  _S264 = make_float3 ((1.0f - material_2.transmission) * _S262) * _S263 * scale_0;
    float3  _S265 = make_float3 (material_2.transmission * _S262) * _S263 * scale_0;
    float _S266 = (F32_max((_S261), (0.0f)));
    float _S267 = rgb_to_greyscale(_S264);
    float _S268 = (F32_max((_S267), (0.0f)));
    float _S269 = rgb_to_greyscale(_S265);
    float _S270 = sign_0(length_0(_S228));
    float _S271 = (F32_max((_S269 * _S270), (0.0f)));
    float _S272 = _S266 + _S268 + _S271;
    float _S273 = (F32_min((sheen_component_0), (1.0f)));
    bool _S274 = sheen_component_0 > 0.0f;
    bool _S275;
    if(_S274)
    {
        _S275 = !(_S272 > 0.0f);
    }
    else
    {
        _S275 = false;
    }
    float _S276 = _slang_select(_S275, 1.0f,_S273);
    float _S277 = (1.0f - _S276) / (F32_max((_S272), (0.0000152587890625f)));
    float _S278 = _S268 * _S277;
    float _S279 = _S266 * _S277;
    float _S280 = _S271 * _S277;
    bool _S281 = (frame_2.alphas.x) > 0.0f;
    if(_S281)
    {
        float3  _S282 = anisotropicLocal(v_3, frame_2.tangent, n_i_2);
        float _S283 = anisotropicG1(_S282, frame_2.alphas);
        float3  _S284 = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_2);
        float _S285 = anisotropicD(_S284, frame_2.alphas);
        float _S286 = _S283 * _S285;
        visible_1 = _S286;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S224, _S225, _S228, F_1, _S261, 1.0f, _S264, _S265, _S278, _S279, _S280, 0.0f, sheen_1, _S276, view_1, frame_2.tangent, frame_2.alphas, visible_1);
}

__device__ float translucentShare(BSDFMaterial material_3)
{
    float _S287 = rgb_to_greyscale(material_3.translucent);
    float _S288 = rgb_to_greyscale(material_3.albedo);
    float _S289 = _S287 / (_S288 + _S287);
    bool _S290 = _S287 > 0.0f;
    float _S291 = _slang_select(_S290, _S289,0.0f);
    return _S291;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_2, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S292 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S293 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S294 = 1.0f - lobes_0.translucent_share;
    bool _S295 = n_i_dot_l_0 < 0.0f;
    float _S296 = _slang_select(_S295, lobes_0.translucent_share,_S294);
    float _S297 = _S293 * _S296;
    bool _S298 = (lobes_0.translucent_share) > 0.0f;
    float _S299 = _slang_select(_S298, _S297,_S292);
    bool _S300 = n_i_dot_v_0 > 0.0f;
    float _S301 = _slang_select(_S300, _S299,0.0f);
    return _S301;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_3, float alpha_3, BSDFMaterial material_4, BSDFLobes lobes_1)
{
    bool _S302 = (dot_0(n_i_3, l_0)) < 0.0f;
    float3  _S303 = _slang_select(_S302, material_4.translucent,material_4.albedo);
    float _S304 = 1.0f - lobes_1.translucent_share;
    float _S305 = _slang_select(_S302, lobes_1.translucent_share,_S304);
    float3  _S306 = _S303 / make_float3 (_S305);
    bool _S307 = (lobes_1.translucent_share) > 0.0f;
    float3  _S308 = _slang_select(_S307, _S306,material_4.albedo);
    return lobes_1.diffuse_weight * _S308 / make_float3 (lobes_1.p_diffuse);
}

__device__ float smithG1(float alpha_4, float n_dot_x_0)
{
    float _S309 = alpha_4 * alpha_4;
    float _S310 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S309 + (1.0f - _S309) * n_dot_x_0 * n_dot_x_0))));
    bool _S311 = alpha_4 > 0.0f;
    float _S312 = _slang_select(_S311, _S310,1.0f);
    return _S312;
}

__device__ float trowbridgeReitz(float alpha_5, float n_dot_h_1)
{
    float _S313 = alpha_5 * alpha_5;
    float _S314 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S313 * n_dot_h_1 * n_dot_h_1;
    return _S313 / (F32_max((3.14159274101257324f * _S314 * _S314), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S315 = smithG1(alpha_6, n_i_dot_v_1);
    float _S316 = _S315 * lobes_2.v_dot_h;
    float _S317 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S318 = _S316 * _S317 / n_i_dot_v_1;
    bool _S319 = alpha_6 > 0.0f;
    bool _S320;
    if(_S319)
    {
        _S320 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S320 = false;
    }
    if(_S320)
    {
        _S320 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S320 = false;
    }
    if(_S320)
    {
        _S320 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S320 = false;
    }
    float _S321 = _slang_select(_S320, _S318,0.0f);
    bool _S322 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S322)
    {
        float _S323 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S324 = (lobes_2.v_dot_h) > 0.0f;
        if(_S324)
        {
            _S320 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S320 = false;
        }
        if(_S320)
        {
            _S320 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S320 = false;
        }
        float _S325 = _slang_select(_S320, _S323,0.0f);
        pdf_h_0 = _S325;
    }
    else
    {
        pdf_h_0 = _S321;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S326 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S327 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S328 = lobes_3.p_refract * _S326 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S327 * _S327);
    bool _S329 = eta_i_4 != eta_o_4;
    bool _S330;
    if(_S329)
    {
        _S330 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S330 = false;
    }
    float _S331 = _slang_select(_S330, _S328,0.0f);
    return _S331;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_4, float alpha_8, BSDFMaterial material_5, BSDFLobes lobes_4)
{
    float _S332 = - dot_0(n_i_4, l_1);
    float _S333 = smithG1(alpha_8, (F32_max((_S332), (0.0f))));
    bool _S334 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S334)
    {
        float3  _S335 = negate_0(n_i_4);
        float3  _S336 = anisotropicLocal(l_1, lobes_4.tangent, _S335);
        float _S337 = anisotropicG1(_S336, lobes_4.alphas);
        G1_l_0 = _S337;
    }
    else
    {
        G1_l_0 = _S333;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_5.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S338 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S339 = n_i_dot_l_2 > 0.0f;
    bool _S340;
    if(_S339)
    {
        _S340 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S340 = false;
    }
    float _S341 = _slang_select(_S340, _S338,0.0f);
    return _S341;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_5, float alpha_10, BSDFMaterial material_6, BSDFLobes lobes_6)
{
    float3  _S342 = l_2 + lobes_6.view;
    float3  _S343 = ((((_S342)) * make_float3(rnorm3df(((_S342)).x, ((_S342)).y, ((_S342)).z))));
    float _S344 = dot_0(n_i_5, _S343);
    float _S345 = (F32_max((dot_0(n_i_5, l_2)), (0.0f)));
    float _S346 = (F32_max((dot_0(n_i_5, lobes_6.view)), (0.0f)));
    float _S347 = 1.0f / (F32_max((material_6.sheen_roughness), (0.05000000074505806f)));
    float _S348 = (2.0f + _S347) * (F32_pow(((F32_max((1.0f - _S344 * _S344), (0.0f)))), (0.5f * _S347))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S345 + _S346 - _S345 * _S346)), (0.0000152587890625f)));
    return lobes_6.sheen * make_float3 (_S348 * _S345 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, BSDFLobes lobes_7, float eta_i_6, float eta_o_6)
{
    float _S349 = vndfPDF(n_i_dot_v_4, alpha_11, lobes_7);
    float _S350 = lobes_7.p_reflect * _S349 / (4.0f * lobes_7.v_dot_h);
    bool _S351 = _S349 > 0.0f;
    float _S352 = _slang_select(_S351, _S350,0.0f);
    return _S352;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_3, float3  n_i_6, float alpha_12, BSDFMaterial material_7, BSDFLobes lobes_8)
{
    float _S353 = dot_0(n_i_6, l_3);
    float _S354 = smithG1(alpha_12, (F32_max((_S353), (0.0f))));
    bool _S355 = (lobes_8.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S355)
    {
        float3  _S356 = anisotropicLocal(l_3, lobes_8.tangent, n_i_6);
        float _S357 = anisotropicG1(_S356, lobes_8.alphas);
        G1_l_1 = _S357;
    }
    else
    {
        G1_l_1 = _S354;
    }
    return make_float3 (lobes_8.reflect_weight * G1_l_1) * lobes_8.F / make_float3 (lobes_8.p_reflect);
}

__device__ __forceinline__ float3  misWeighted(float3  throughput_0, float lobe_pdf_0, float pdf_0, bool power_0)
{
    if(power_0)
    {
        float _S358 = lobe_pdf_0 / pdf_0;
        return throughput_0 * make_float3 (lobe_pdf_0) / make_float3 (pdf_0 * (1.0f + _S358 * _S358));
    }
    return throughput_0 * make_float3 (lobe_pdf_0) / make_float3 (lobe_pdf_0 + pdf_0);
}

static __device__ float3  neeLobes_0(float3  in_dir_4, float3  dir_3, float3  n_7, BSDFMaterial * material_8, float eta_i_7, float eta_o_7, bool refracted_2, float pdf_1, bool power_1, uint random_state_3, FixedArray<float3 , 4>  * each_0, uint * reached_0)
{
    float3  _S359 = negate_0(in_dir_4);
    float _S360 = dot_0(n_7, _S359);
    float _S361 = sign_0(_S360);
    float3  _S362 = n_7 * make_float3 (_S361);
    AnisotropicFrame _S363 = anisotropicFrame(*material_8, _S362);
    float _S364 = dot_0(_S362, dir_3);
    float _S365 = material_8->roughness * material_8->roughness;
    float3  _S366 = make_float3 (0.0f);
    *reached_0 = 0U;
    BSDFLobes _S367 = BSDFLobes_x24init_0(0.0f, 0.0f, _S366, _S366, 0.0f, 0.0f, _S366, _S366, 0.0f, 0.0f, 0.0f, 0.0f, _S366, 0.0f, _S366, _S366, make_float2 (0.0f), 0.0f);
    BSDFLobes lobe_terms_0 = _S367;
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
        (*each_0)[i_2] = _S366;
        uint i_3 = i_2 + 1U;
        i_2 = i_3;
    }
    uint half_of_0 = 4294967295U;
    float3  ggx_n_1 = _S366;
    i_2 = 0U;
    float3  f_0 = _S366;
    for(;;)
    {
        if(i_2 < 4U)
        {
        }
        else
        {
            break;
        }
        uint _S368;
        if(i_2 == 3U)
        {
            _S368 = 4U;
        }
        else
        {
            _S368 = i_2;
        }
        bool _S369 = _S368 == 0U;
        if(_S369)
        {
        }
        bool _S370;
        if(_S369)
        {
            float _S371 = rgb_to_greyscale(material_8->translucent);
            _S370 = _S371 > 0.0f;
        }
        else
        {
            _S370 = false;
        }
        bool _S372;
        if(_S370)
        {
            float _S373 = dot_0(n_7, dir_3);
            float3  _S374 = negate_0(in_dir_4);
            _S372 = ((_S373 * dot_0(n_7, _S374)) < 0.0f) == refracted_2;
        }
        else
        {
            _S372 = (_S368 == 1U) == refracted_2;
        }
        float3  ggx_n_2;
        if(_S372)
        {
            uint _S375;
            if(_S368 == 4U)
            {
                _S375 = 2U;
            }
            else
            {
                _S375 = _S368;
            }
            bool _S376 = _S375 != half_of_0;
            uint half_of_1;
            if(_S376)
            {
                bool _S377 = _S375 == 0U;
                if(_S377)
                {
                    float3  _S378 = sampledHalf(in_dir_4, n_7, *material_8, random_state_3, _S363);
                    ggx_n_2 = _S378;
                }
                else
                {
                    bool _S379 = _S375 == 1U;
                    if(_S379)
                    {
                        float3  _S380 = refractedHalf(in_dir_4, dir_3, n_7, eta_i_7, eta_o_7);
                        ggx_n_2 = _S380;
                    }
                    else
                    {
                        float3  _S381 = reflectedHalf(in_dir_4, dir_3);
                        ggx_n_2 = _S381;
                    }
                }
                float3  _S382 = negate_0(in_dir_4);
                BSDFLobes _S383 = bsdfLobes(in_dir_4, _S382, _S362, ggx_n_2, *material_8, eta_i_7, eta_o_7, _S363);
                lobe_terms_0 = _S383;
                float _S384 = translucentShare(*material_8);
                (&lobe_terms_0)->translucent_share = _S384;
                half_of_1 = _S375;
            }
            else
            {
                ggx_n_2 = ggx_n_1;
                half_of_1 = half_of_0;
            }
            float3  throughput_1;
            float lobe_pdf_1;
            switch(_S368)
            {
            case 0U:
                {
                    float _S385 = diffusePDF(_S364, 0.0f, (F32_abs((_S360))), _S365, lobe_terms_0, eta_i_7, eta_o_7);
                    float3  _S386 = diffuseBSDF(dir_3, _S362, _S365, *material_8, lobe_terms_0);
                    lobe_pdf_1 = _S385;
                    throughput_1 = _S386;
                    break;
                }
            case 1U:
                {
                    float _S387 = refractPDF(_S364, dot_0(dir_3, ggx_n_2), (F32_abs((_S360))), _S365, lobe_terms_0, eta_i_7, eta_o_7);
                    float3  _S388 = refractBSDF(dir_3, _S362, _S365, *material_8, lobe_terms_0);
                    lobe_pdf_1 = _S387;
                    throughput_1 = _S388;
                    break;
                }
            case 4U:
                {
                    float _S389 = sheenVelvetPDF(_S364, 0.0f, (F32_abs((_S360))), _S365, lobe_terms_0, eta_i_7, eta_o_7);
                    float3  _S390 = sheenVelvetBSDF(dir_3, _S362, _S365, *material_8, lobe_terms_0);
                    lobe_pdf_1 = _S389;
                    throughput_1 = _S390;
                    break;
                }
            default:
                {
                    float _S391 = reflectPDF(_S364, 0.0f, (F32_abs((_S360))), _S365, lobe_terms_0, eta_i_7, eta_o_7);
                    float3  _S392 = reflectBSDF(dir_3, _S362, _S365, *material_8, lobe_terms_0);
                    lobe_pdf_1 = _S391;
                    throughput_1 = _S392;
                    break;
                }
            }
            bool _S393 = lobe_pdf_1 > 0.0f;
            float3  f_1;
            if(_S393)
            {
                float3  _S394 = misWeighted(throughput_1, lobe_pdf_1, pdf_1, power_1);
                (*each_0)[i_2] = _S394;
                uint _S395 = (*reached_0) | (1U << i_2);
                *reached_0 = _S395;
                float3  f_2 = f_0 + (*each_0)[i_2];
                f_1 = f_2;
            }
            else
            {
                f_1 = f_0;
            }
            half_of_0 = half_of_1;
            f_0 = f_1;
        }
        else
        {
            ggx_n_2 = ggx_n_1;
        }
        uint i_4 = i_2 + 1U;
        ggx_n_1 = ggx_n_2;
        i_2 = i_4;
    }
    return f_0;
}

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_5, float3  dir_4, float3  n_8, BSDFMaterial material_9, float eta_i_8, float eta_o_8, bool refracted_3, float pdf_2, bool power_2, uint random_state_4)
{
    uint reached_1 = 0U;
    BSDFMaterial _S396 = material_9;
    FixedArray<float3 , 4>  each_1;
    float3  _S397 = neeLobes_0(in_dir_5, dir_4, n_8, &_S396, eta_i_8, eta_o_8, refracted_3, pdf_2, power_2, random_state_4, &each_1, &reached_1);
    return _S397;
}

__device__ float3  skyBSDF(float3  in_dir_6, float3  dir_5, FKSurface surface_1, float2  eta_1, bool is_inside_2, float pdf_3, uint random_state_5)
{
    bool _S398 = wrongSide_0(is_inside_2, false, dir_5, surface_1.geometry_n);
    float3  _S399 = neeBSDF(in_dir_6, dir_5, surface_1.smooth_n, surface_1.material, eta_1.x, eta_1.y, _S398, pdf_3, false, random_state_5);
    return _S399;
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
    SkySample _S400;
    (&_S400)->dir = dir_6;
    (&_S400)->radiance = radiance_0;
    (&_S400)->color = color_0;
    (&_S400)->random_state = random_state_6;
    return _S400;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0)
{
    uint2  _S401 = (fcptEnvironmentCdfSize());
    uint2  _S402 = make_uint2 (1U, 0U);
    uint2  _S403 = _S401 - _S402;
    Random _S404 = pcg(init_random_state_0);
    Random _S405 = pcg(_S404.state);
    Random _S406 = pcg(_S405.state);
    Random _S407 = pcg(_S406.state);
    uint _S408 = _S403.x;
    uint _S409 = searchCDF_0(make_uint2 (_S408, 0U), make_uint2 (0U, 1U), _S403.y, _S404.value);
    uint _S410 = searchCDF_0(make_uint2 (0U, _S409), _S402, _S408, _S405.value);
    float2  _S411 = make_float2 ((float)_S403.x, (float)_S403.y);
    float2  _S412 = (make_float2 (float(_S410), float(_S409)) + make_float2 (_S406.value, _S407.value)) / _S411 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S413 = _S412.y;
    float _S414 = (F32_sin((_S413)));
    float _S415 = _S412.x;
    float3  _S416 = make_float3 (_S414 * (F32_cos((_S415))), (F32_cos((_S413))), _S414 * (F32_sin((_S415))));
    float _S417 = environmentPdf_0(_S416);
    float3  _S418 = skyBSDF(ray_0->unit_direction, _S416, *surface_2, eta_2, is_inside_3, _S417, lobe_state_0);
    bool _S419 = !(_S417 > 0.0f);
    bool _S420;
    if(_S419)
    {
        _S420 = true;
    }
    else
    {
        _S420 = all_0(_S418 == make_float3 (0.0f));
    }
    if(_S420)
    {
        float3  _S421 = make_float3 (0.0f);
        return SkySample_x24init_0(_S416, _S421, _S421, _S407.state);
    }
    float3  _S422 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S416);
    return SkySample_x24init_0(_S416, _S422, _S418 * _S422, _S407.state);
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
    SampleBSDF _S423 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S424 = _S423.throughput * make_float3 (_S423.pdf);
    float _S425 = light_1->density;
    float _S426 = 1.0f + _S423.pdf * _S423.pdf / (light_1->density * light_1->density);
    bool _S427;
    if(competing_0)
    {
        _S427 = _S425 > 0.0f;
    }
    else
    {
        _S427 = false;
    }
    float _S428 = _slang_select(_S427, _S426,1.0f);
    return _S424 / make_float3 (_S428) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_7, float3  radiance_1, float density_0, uint random_state_7)
{
    TreeSample _S429;
    (&_S429)->dir = dir_7;
    (&_S429)->radiance = radiance_1;
    (&_S429)->density = density_0;
    (&_S429)->random_state = random_state_7;
    return _S429;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_3, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S430 = importance(first_1, p_3, normal_3);
    float _S431 = importance(second_1, p_3, normal_3);
    float2  _S432 = make_float2 (_S430, _S431);
    bool _S433 = _S430 == 0.0f;
    bool _S434;
    if(_S433)
    {
        _S434 = _S431 == 0.0f;
    }
    else
    {
        _S434 = false;
    }
    if(_S434)
    {
        return 2U;
    }
    float _S435 = _S430 + _S431;
    bool _S436 = _S431 > 0.0f;
    if(_S436)
    {
        _S434 = (*pick_0 * _S435) >= _S430;
    }
    else
    {
        _S434 = false;
    }
    uint _S437 = uint(_S434);
    float _S438 = (F32_min(((*pick_0 * _S435 - float(_S437) * _S430) / _slang_vector_get_element(_S432, _S437)), (0.99999994039535522f)));
    *pick_0 = _S438;
    float _S439 = *probability_3 * (_slang_vector_get_element(_S432, _S437) / _S435);
    *probability_3 = _S439;
    return _S437;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_4, float u1_0, float u2_0)
{
    float3  _S440 = center_1 - p_4;
    float _S441 = radius_1 * radius_1 / dot_0(_S440, _S440);
    float _S442 = u1_0 * _S441 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S441), (0.0f)))))));
    float _S443 = 2.0f * u1_0;
    bool _S444 = _S441 >= 1.0f;
    float _S445 = _slang_select(_S444, _S443,_S442);
    float _S446 = (F32_sqrt(((F32_max((_S445 * (2.0f - _S445)), (0.0f))))));
    float _S447 = 6.28318548202514648f * u2_0;
    float3  _S448 = make_float3 (_S446 * (F32_cos((_S447))), 1.0f - _S445, _S446 * (F32_sin((_S447))));
    float3  _S449 = ((((_S440)) * make_float3(rnorm3df(((_S440)).x, ((_S440)).y, ((_S440)).z))));
    float3  _S450 = tangentToWorld(_S448, _S449);
    return _S450;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S451 = center_2 - ray_1->origin;
    float _S452 = dot_0(_S451, ray_1->unit_direction);
    float _S453 = dot_0(_S451, _S451) - _S452 * _S452;
    float _S454 = radius_3 * radius_3;
    bool _S455 = _S453 > _S454;
    if(_S455)
    {
        return 4.294967296e+09f;
    }
    float _S456 = (F32_sqrt((_S454 - _S453)));
    float _S457 = _S452 - _S456;
    float _S458 = _S452 + _S456;
    bool _S459 = _S457 > 0.0000152587890625f;
    bool _S460;
    if(_S459)
    {
        _S460 = _S457 < max_len_0;
    }
    else
    {
        _S460 = false;
    }
    if(_S460)
    {
        return _S457;
    }
    bool _S461 = _S458 > 0.0000152587890625f;
    if(_S461)
    {
        _S460 = _S458 < max_len_0;
    }
    else
    {
        _S460 = false;
    }
    if(_S460)
    {
        return _S458;
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
    Random _S462 = pcg(init_random_state_1);
    Random _S463 = pcg(_S462.state);
    Random _S464 = pcg(_S463.state);
    float3  _S465 = make_float3 (0.0f);
    TreeSample _S466 = TreeSample_x24init_0(_S465, _S465, 0.0f, _S464.state);
    TreeSample sample_0 = _S466;
    float3  _S467 = _slang_select(sided_0, _S465,smooth_n_2);
    float3  _S468 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S462.value;
    float probability_4 = 1.0f;
    uint n_9 = 0U;
    for(;;)
    {
        uint4  _S469 = (fcptLightNode((n_9)));
        if((_S469.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S470 = (fcptLightSecond((n_9)));
        uint _S471 = n_9 + 1U;
        LightNode _S472 = (fcptLightBounds((_S471)));
        LightNode _S473 = (fcptLightBounds((_S470)));
        uint _S474 = pickChild(_S472, _S473, origin_4, _S467, &pick_1, &probability_4);
        bool _S475 = _S474 > 1U;
        if(_S475)
        {
            return sample_0;
        }
        bool _S476 = _S474 == 1U;
        uint _S477 = _slang_select(_S476, _S470,_S471);
        n_9 = _S477;
    }
    bool _S478 = n_9 == 0U;
    bool _S479;
    if(_S478)
    {
        LightNode _S480 = (fcptLightBounds((0U)));
        float _S481 = importance(_S480, origin_4, _S467);
        _S479 = !(_S481 > 0.0f);
    }
    else
    {
        _S479 = false;
    }
    if(_S479)
    {
        return sample_0;
    }
    uint4  _S482 = (fcptLightNode((n_9)));
    FKHit _S483 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S484 = (_S482.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S484)
    {
        FKLight _S485 = (fcptLight((_S482.y)));
        if(sided_0)
        {
            float _S486 = sign_0(dot_0(geometry_n_1, _S485.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S486);
            float3  _S487 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S487;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S468;
            lift_n_0 = smooth_n_2;
        }
        bool _S488 = (_S485.variance) == 0.0f;
        if(_S488)
        {
            float3  _S489 = _S485.position - emitter_point_0;
            float3  _S490 = ((((_S489)) * make_float3(rnorm3df(((_S489)).x, ((_S489)).y, ((_S489)).z))));
            (&sample_0)->dir = _S490;
            float3  _S491 = _S485.color * make_float3 (_S485.intensity) / make_float3 (dot_0(_S489, _S489) * probability_4);
            (&sample_0)->radiance = _S491;
            shadow_1 = _S489;
        }
        else
        {
            float3  _S492 = sampleSphere(_S485.position, _S485.variance, emitter_point_0, _S463.value, _S464.value);
            (&sample_0)->dir = _S492;
            float _S493 = sphereDensity(_S485.position, _S485.variance, emitter_point_0);
            float _S494 = probability_4 * _S493;
            (&sample_0)->density = _S494;
            float3  _S495 = pointLightRadiance(_S485.color, _S485.intensity, _S485.variance);
            float3  _S496 = _S495 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S496;
            FKRay _S497 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S498 = raySphere_0(_S485.position, _S485.variance, &_S497, 4.294967296e+09f);
            float3  _S499 = (&sample_0)->dir * make_float3 (_S498);
            shadow_1 = _S499;
        }
        emitter_0 = _S483;
        emitter_point_0 = _S465;
    }
    else
    {
        uint _S500 = _S482.y;
        uint _S501 = (fcptTriangleOffset((_S500)));
        uint _S502 = _S501 + _S482.z;
        Matrix<float, 3, 3>  _S503 = (fcptWorldTriangle((_S500), (_S502)));
        float _S504 = (F32_sqrt((_S463.value)));
        float2  _S505 = make_float2 (_S504 * (1.0f - _S464.value), _S504 * _S464.value);
        float3  _S506 = mul_0(make_float3 (1.0f - _S504, _S505.x, _S505.y), _S503);
        if(sided_0)
        {
            float _S507 = sign_0(dot_0(geometry_n_1, _S506 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S507);
            float3  _S508 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S508;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S509 = !((dot_0(smooth_n_2, _S506 - origin_4)) > 0.0f);
            if(_S509)
            {
                return sample_0;
            }
            emitter_point_0 = _S468;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S505, _S500, _S502, 0U, 0.0f);
        float3  _S510 = _S506 - emitter_point_0;
        float3  _S511 = ((((_S510)) * make_float3(rnorm3df(((_S510)).x, ((_S510)).y, ((_S510)).z))));
        (&sample_0)->dir = _S511;
        float _S512 = solidAngle(probability_4, cross_0(_S503.rows[int(1)] - _S503.rows[int(0)], _S503.rows[int(2)] - _S503.rows[int(0)]), _S510);
        (&sample_0)->density = _S512;
        bool _S513 = (fcptShadowFirst());
        bool _S514 = !_S513;
        if(_S514)
        {
            FKSurface _S515 = (fcptLightSurfaceAt((emitter_1), (_S506), (_S464.state), ((&sample_0)->dir), (context_1->depth), (length_0(_S506 - origin_4))));
            (&sample_0)->random_state = _S515.random_state;
            float3  _S516 = _slang_select(_S515.skip, _S465,_S515.material.emissive);
            float3  _S517 = _S516 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S517;
        }
        shadow_1 = _S510;
        emitter_0 = emitter_1;
        emitter_point_0 = _S506;
    }
    FKHit _S518 = emitter_0;
    float3  _S519 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_1, _S464.state, &_S518);
    bool _S520 = (fcptShadowFirst());
    if(_S520)
    {
        _S479 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S479 = false;
    }
    if(_S479)
    {
        _S479 = !all_0(_S519 == _S465);
    }
    else
    {
        _S479 = false;
    }
    if(_S479)
    {
        FKSurface _S521 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S464.state), ((&sample_0)->dir), (context_1->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S521.random_state;
        float3  _S522 = _slang_select(_S521.skip, _S465,_S521.material.emissive);
        float3  _S523 = _S522 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S523;
    }
    float3  _S524 = (&sample_0)->radiance * _S519;
    bool _S525 = all_0(_S519 == _S465);
    float3  _S526 = _slang_select(_S525, _S465,_S524);
    (&sample_0)->radiance = _S526;
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
    float _S527 = 1.0f / (1.0f + b_0 / a_4 * (b_0 / a_4));
    bool _S528 = b_0 > 0.0f;
    float _S529 = _slang_select(_S528, _S527,1.0f);
    return _S529;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_0, float3  light_point_1)
{
    bool _S530 = vertex_0->none;
    if(_S530)
    {
        return 1.0f;
    }
    uint _S531 = (fcptLightSlot((*hit_0)));
    float _S532 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S531, light_point_1);
    float _S533 = powerHeuristic(vertex_0->pdf, _S532);
    return _S533;
}

static __device__ float3  environment_0(float3  dir_8, uint depth_0, uint lobe_0)
{
    uint2  _S534 = (fcptEnvironmentMapSize());
    bool _S535 = (_S534.x) > 1U;
    bool _S536;
    if(_S535)
    {
        uint2  _S537 = (fcptEnvironmentMapSize());
        _S536 = (_S537.y) > 1U;
    }
    else
    {
        _S536 = false;
    }
    if(_S536)
    {
        float3  _S538 = (fcptEnvMapSample((dir_8), (depth_0), (lobe_0)));
        return _S538;
    }
    float3  _S539 = (fcptAmbient());
    return _S539;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S540 = (fcptEnvironmentCdfSize());
    bool _S541 = (_S540.x) > 1U;
    bool _S542;
    if(_S541)
    {
        uint2  _S543 = (fcptEnvironmentCdfSize());
        _S542 = (_S543.y) > 1U;
    }
    else
    {
        _S542 = false;
    }
    bool _S544 = !_S542;
    if(_S544)
    {
        return false;
    }
    uint2  _S545 = (fcptEnvironmentMapSize());
    bool _S546 = (_S545.x) > 1U;
    if(_S546)
    {
        uint2  _S547 = (fcptEnvironmentMapSize());
        _S542 = (_S547.y) > 1U;
    }
    else
    {
        _S542 = false;
    }
    return _S542;
}

static __device__ float escapeWeight_0(float pdf_4, float3  dir_9)
{
    bool _S548 = pdf_4 <= 0.0f;
    bool _S549;
    if(_S548)
    {
        _S549 = true;
    }
    else
    {
        bool _S550 = environmentMapped_0();
        _S549 = !_S550;
    }
    if(_S549)
    {
        return 1.0f;
    }
    float _S551 = environmentPdf_0(dir_9);
    return pdf_4 / (pdf_4 + _S551);
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

static __device__ Shift Shift_x24init_0(float3  f_3, float jac_0)
{
    Shift _S552;
    (&_S552)->f = f_3;
    (&_S552)->jac = jac_0;
    return _S552;
}

static __device__ uint extractBits_0(uint e_1, uint offset_0, uint count_1)
{
    return (e_1 >> offset_0) & ((1U << count_1) - 1U);
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_5, float3  origin_5, float3  smooth_n_3, float3  start_2)
{
    NEEVertex _S553;
    (&_S553)->none = none_0;
    (&_S553)->pdf = pdf_5;
    (&_S553)->origin = origin_5;
    (&_S553)->smooth_n = smooth_n_3;
    (&_S553)->start = start_2;
    return _S553;
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
    Vertex _S554;
    (&_S554)->rough = rough_0;
    (&_S554)->lobe = lobe_1;
    (&_S554)->pdf = pdf_6;
    (&_S554)->cos = cos_0;
    (&_S554)->inside = inside_0;
    return _S554;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S555 = hash(index_0);
    uint _S556 = hash(seed_0 ^ _S555);
    return _S556;
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
    float3  _S557 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_1));
    float3  _S558 = scatter_0 * _S557 / make_float3 (sigma_1);
    float3  _S559 = _slang_select(scatters_0, _S558,_S557);
    return _S559;
}

static __device__ bool scatterSampled_0(bool replay_0, uint b_1, uint stop_0, bool varying_0)
{
    bool _S560 = !replay_0;
    bool _S561;
    if(_S560)
    {
        _S561 = true;
    }
    else
    {
        bool _S562 = b_1 == stop_0;
        if(_S562)
        {
            _S561 = !varying_0;
        }
        else
        {
            _S561 = false;
        }
    }
    return _S561;
}

static __device__ uint arrivalLobe_0(uint b_2, uint prev_lobe_0)
{
    bool _S563 = b_2 > 0U;
    uint _S564 = _slang_select(_S563, prev_lobe_0,3U);
    return _S564;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_4, float length_2, float width_0, FKHit * own_0, bool fiber_0)
{
    ShadowContext _S565;
    (&_S565)->extinction_behind = extinction_behind_0;
    (&_S565)->extinction_front = extinction_front_0;
    (&_S565)->fillings = fillings_0;
    (&_S565)->side = side_0;
    (&_S565)->depth = depth_1;
    (&_S565)->lobe = lobe_2;
    (&_S565)->surface = surface_4;
    (&_S565)->length = length_2;
    (&_S565)->width = width_0;
    (&_S565)->own = *own_0;
    (&_S565)->fiber = fiber_0;
    return _S565;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S566 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S566)
    {
        return 0.07957746833562851f;
    }
    float _S567 = g_0 * g_0;
    return (1.0f - _S567) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S567 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_5, float3  b_3)
{
    float3  _S568 = a_5 / b_3;
    float3  _S569 = make_float3 (0.0f);
    bool3  _S570 = b_3 == _S569;
    float3  _S571 = _slang_select(_S570, _S569,_S568);
    return _S571;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S572 = (1U << count_2) - 1U;
    return (e_2 & (~(_S572 << offset_1))) | ((newbits_0 & _S572) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_0, uint end_type_0, uint end_0, float3  f_4)
{
    Reservoir candidate_0 = r_0;
    uint _S573 = insertBits_0(r_0.path, end_0, 0U, 5U);
    uint _S574 = insertBits_0(_S573, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S574;
    (&candidate_0)->f = f_4;
    return candidate_0;
}

__device__ void offer(Selection * sel_0, Reservoir candidate_1, float3  weight_0)
{
    float _S575 = rgb_to_greyscale(weight_0);
    bool _S576 = _S575 > 0.0f;
    bool _S577;
    if(_S576)
    {
        _S577 = _S575 < 3.00000000549775576e+38f;
    }
    else
    {
        _S577 = false;
    }
    bool _S578 = !_S577;
    if(_S578)
    {
        return;
    }
    bool _S579 = sel_0->sums;
    if(_S579)
    {
        float3  _S580 = sel_0->color + weight_0;
        sel_0->color = _S580;
        return;
    }
    float _S581 = sel_0->w_sum + _S575;
    sel_0->w_sum = _S581;
    float3  _S582 = sel_0->color + weight_0;
    sel_0->color = _S582;
    Random _S583 = pcg(sel_0->random_state);
    sel_0->random_state = _S583.state;
    bool _S584 = (_S583.value * sel_0->w_sum) <= _S575;
    if(_S584)
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
    Random _S585 = pcg(random_state_8);
    Random _S586 = pcg(_S585.state);
    float _S587 = 1.0f - 2.0f * _S585.value;
    float _S588 = (F32_sqrt(((F32_max((1.0f - _S587 * _S587), (0.0f))))));
    float _S589 = 6.28318548202514648f * _S586.value;
    return make_float3 (_S588 * (F32_cos((_S589))), _S588 * (F32_sin((_S589))), _S587);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_10, uint random_state_9, float * pdf_7)
{
    bool _S590 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S590)
    {
        *pdf_7 = 0.07957746833562851f;
        float3  _S591 = isotropic_0(random_state_9);
        return _S591;
    }
    Random _S592 = pcg(random_state_9);
    Random _S593 = pcg(_S592.state);
    float _S594 = g_1 * g_1;
    float _S595 = 2.0f * g_1;
    float _S596 = (1.0f - _S594) / (1.0f - g_1 + _S595 * _S592.value);
    float _S597 = clamp_0((1.0f + _S594 - _S596 * _S596) / _S595, -1.0f, 1.0f);
    float _S598 = (F32_sqrt(((F32_max((1.0f - _S597 * _S597), (0.0f))))));
    float _S599 = 6.28318548202514648f * _S593.value;
    float _S600 = phaseHG_0(g_1, _S597);
    *pdf_7 = _S600;
    float3  _S601 = tangentToWorld(make_float3 (_S598 * (F32_cos((_S599))), _S597, _S598 * (F32_sin((_S599)))), dir_10);
    float3  _S602 = ((((_S601)) * make_float3(rnorm3df(((_S601)).x, ((_S601)).y, ((_S601)).z))));
    return _S602;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2)
{
    BSDFMaterial _S603;
    (&_S603)->albedo = albedo_0;
    (&_S603)->emissive = emissive_0;
    (&_S603)->roughness = roughness_0;
    (&_S603)->metallic = metallic_0;
    (&_S603)->transmission = transmission_0;
    (&_S603)->ior = ior_0;
    (&_S603)->absorption = absorption_0;
    (&_S603)->specular_tint = specular_tint_0;
    (&_S603)->specular_level = specular_level_0;
    (&_S603)->translucent = translucent_0;
    (&_S603)->sheen = sheen_2;
    (&_S603)->sheen_roughness = sheen_roughness_0;
    (&_S603)->anisotropy = anisotropy_0;
    (&_S603)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S603)->tangent = tangent_2;
    return _S603;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S604;
    (&_S604)->scatter = scatter_1;
    (&_S604)->extinction = extinction_1;
    (&_S604)->g = g_2;
    return _S604;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_10, bool skip_0, uint random_state_10, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S605;
    (&_S605)->smooth_n = smooth_n_4;
    (&_S605)->geometry_n = geometry_n_2;
    (&_S605)->geometry_offset = geometry_offset_2;
    (&_S605)->material = *material_10;
    (&_S605)->skip = skip_0;
    (&_S605)->random_state = random_state_10;
    (&_S605)->coverage = coverage_0;
    (&_S605)->encloses = encloses_0;
    (&_S605)->volume = *volume_0;
    (&_S605)->fills = fills_0;
    (&_S605)->hair = hair_0;
    return _S605;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S606 = (&surface_5->material)->emissive;
    float3  _S607 = make_float3 (0.0f);
    bool _S608 = !top_0;
    float3  _S609 = _slang_select(_S608, _S607,_S606);
    (&(&lower_0)->material)->emissive = _S609;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_2)
{
    float _S610 = surface_6->coverage;
    bool _S611 = u_2 < _S610;
    if(_S611)
    {
        return *surface_6;
    }
    float3  _S612 = make_float3 (0.0f);
    float3  _S613 = make_float3 (1.0f);
    BSDFMaterial _S614 = Material_x24init_0(_S612, _S612, 0.0f, 0.0f, 0.0f, 0.0f, _S612, _S613, 1.0f, _S612, _S612, 0.5f, 0.0f, 0.0f, _S612);
    BSDFMaterial material_11 = _S614;
    (&material_11)->albedo = _S613;
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
    bool _S615 = transmission_1 > 0.0f;
    bool _S616;
    if(_S615)
    {
        _S616 = true;
    }
    else
    {
        _S616 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S617;
    if(_S616)
    {
        _S617 = 1.0f;
    }
    else
    {
        _S617 = -1.0f;
    }
    return _S617;
}

static __device__ bool arrivesBehind_0(float3  dir_11, float3  n_10)
{
    return (dot_0(dir_11, n_10)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_12)
{
    float3  _S618 = surface_7->geometry_n;
    float _S619 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_12);
    FKSurface faced_0 = *surface_7;
    float3  _S620 = surface_7->smooth_n * make_float3 (_S619);
    (&faced_0)->smooth_n = _S620;
    float3  _S621 = _S618 * make_float3 (_S619);
    (&faced_0)->geometry_n = _S621;
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
    float3  _S622 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_2) * log_0(_S622));
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
    bool _S623;
    if(open_0)
    {
        _S623 = prev_rough_0;
    }
    else
    {
        _S623 = false;
    }
    if(_S623)
    {
        _S623 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S623 = false;
    }
    return _S623;
}

__device__ float2  vertexEta(BSDFMaterial material_12, float n_dot_v_0)
{
    bool _S624 = n_dot_v_0 < 0.0f;
    float _S625 = _slang_select(_S624, material_12.ior,1.0f);
    float _S626 = _slang_select(_S624, 1.0f,material_12.ior);
    return make_float2 (_S625, _S626);
}

__device__ bool neeDecision(BSDFMaterial material_13, float n_dot_v_1, float eta_i_9, float eta_o_9)
{
    float _S627 = fresnel((F32_abs((n_dot_v_1))), eta_i_9, eta_o_9);
    float3  _S628 = mix_0(make_float3 (_S627), material_13.albedo, material_13.metallic);
    float _S629 = rgb_to_greyscale(_S628);
    float _S630 = (F32_max(((1.0f - _S629) * (1.0f - material_13.metallic) * (1.0f - material_13.transmission)), (0.0f)));
    bool _S631 = _S630 > 0.03999999910593033f;
    bool _S632;
    if(_S631)
    {
        _S632 = true;
    }
    else
    {
        _S632 = (material_13.roughness) > 0.20000000298023224f;
    }
    return _S632;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_14)
{
    float _S633 = rgb_to_greyscale(material_14->translucent);
    return _S633 > 0.0f;
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
    MediumSides _S634;
    (&_S634)->behind = *behind_0;
    (&_S634)->front = *front_0;
    (&_S634)->fillings = fillings_1;
    (&_S634)->face = face_1;
    return _S634;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_13)
{
    float3  _S635 = surface_8->geometry_n;
    MediumSides _S636 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S636;
    bool _S637 = surface_8->encloses;
    if(_S637)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S638 = (dot_0(dir_13, _S635)) > 0.0f;
        if(_S638)
        {
            float3  _S639 = make_float3 (0.0f);
            FKMedium _S640 = Medium_x24init_0(_S639, _S639, 0.0f);
            (&sides_0)->front = _S640;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_14, uint depth_2, uint lobe_3, float length_3, float width_1, FKHit * own_1, bool fiber_1)
{
    float3  _S641 = surface_9->geometry_n;
    ShadowContext _S642 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
    bool _S643 = surface_9->encloses;
    ShadowContext context_2;
    if(_S643)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S644 = - _S641;
        float3  _S645 = _slang_select(turned_0, _S644,_S641);
        (&faced_1)->geometry_n = _S645;
        FKMedium _S646 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S647 = faced_1;
        FKMedium _S648 = _S646;
        MediumSides _S649 = mediumSides_0(&_S647, &_S648, filling_1, dir_14);
        ShadowContext _S650 = ShadowContext_x24init_0(_S649.behind.extinction, _S649.front.extinction, _S649.fillings, _S641, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
        if(turned_0)
        {
            uint2  _S651 = _S649.fillings;
            ShadowContext _S652 = ShadowContext_x24init_0(_S649.front.extinction, _S649.behind.extinction, uint2 {_S651.y, _S651.x}, _S641, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
            context_2 = _S652;
        }
        else
        {
            context_2 = _S650;
        }
    }
    else
    {
        context_2 = _S642;
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
    float3  _S653 = negate_0(in_dir_8);
    float _S654 = dot_0(n_11, _S653);
    float _S655 = sign_0(_S654);
    float3  _S656 = n_11 * make_float3 (_S655);
    AnisotropicFrame _S657 = anisotropicFrame(material_15, _S656);
    float _S658 = dot_0(_S656, out_dir_2);
    float _S659 = material_15.roughness;
    float _S660 = _S659 * _S659;
    bool _S661 = (dot_0(g_n_0, _S653) * dot_0(g_n_0, out_dir_2)) > 0.0f;
    uint _S662;
    if(_S661)
    {
        _S662 = 3U;
    }
    else
    {
        _S662 = 1U;
    }
    float3  _S663 = make_float3 (0.0f);
    BSDFLobes _S664 = BSDFLobes_x24init_0(0.0f, 0.0f, _S663, _S663, 0.0f, 0.0f, _S663, _S663, 0.0f, 0.0f, 0.0f, 0.0f, _S663, 0.0f, _S663, _S663, make_float2 (0.0f), 0.0f);
    BSDFLobes lobe_terms_1 = _S664;
    uint half_of_2 = 4294967295U;
    float3  ggx_n_3 = _S663;
    float3  f_5 = _S663;
    uint i_12 = 0U;
    for(;;)
    {
        if(i_12 < _S662)
        {
        }
        else
        {
            break;
        }
        uint _S665;
        if(!_S661)
        {
            _S665 = 1U;
        }
        else
        {
            if(i_12 == 0U)
            {
                _S665 = 0U;
            }
            else
            {
                if(i_12 == 1U)
                {
                    _S665 = 2U;
                }
                else
                {
                    _S665 = 4U;
                }
            }
        }
        uint _S666;
        if(_S665 == 4U)
        {
            _S666 = 2U;
        }
        else
        {
            _S666 = _S665;
        }
        bool _S667 = _S666 != half_of_2;
        float3  ggx_n_4;
        if(_S667)
        {
            bool _S668 = _S666 == 0U;
            if(_S668)
            {
                float3  _S669 = sampledHalf(in_dir_8, n_11, material_15, random_state_11, _S657);
                ggx_n_4 = _S669;
            }
            else
            {
                bool _S670 = _S666 == 1U;
                if(_S670)
                {
                    float3  _S671 = refractedHalf(in_dir_8, out_dir_2, n_11, eta_i_10, eta_o_10);
                    ggx_n_4 = _S671;
                }
                else
                {
                    float3  _S672 = reflectedHalf(in_dir_8, out_dir_2);
                    ggx_n_4 = _S672;
                }
            }
            float3  _S673 = negate_0(in_dir_8);
            BSDFLobes _S674 = bsdfLobes(in_dir_8, _S673, _S656, ggx_n_4, material_15, eta_i_10, eta_o_10, _S657);
            lobe_terms_1 = _S674;
            float _S675 = translucentShare(material_15);
            (&lobe_terms_1)->translucent_share = _S675;
            half_of_2 = _S666;
        }
        else
        {
            ggx_n_4 = ggx_n_3;
        }
        float3  throughput_3;
        float pdf_8;
        switch(_S665)
        {
        case 0U:
            {
                float _S676 = diffusePDF(_S658, 0.0f, (F32_abs((_S654))), _S660, lobe_terms_1, eta_i_10, eta_o_10);
                float3  _S677 = diffuseBSDF(out_dir_2, _S656, _S660, material_15, lobe_terms_1);
                pdf_8 = _S676;
                throughput_3 = _S677;
                break;
            }
        case 1U:
            {
                float _S678 = refractPDF(_S658, dot_0(out_dir_2, ggx_n_4), (F32_abs((_S654))), _S660, lobe_terms_1, eta_i_10, eta_o_10);
                float3  _S679 = refractBSDF(out_dir_2, _S656, _S660, material_15, lobe_terms_1);
                pdf_8 = _S678;
                throughput_3 = _S679;
                break;
            }
        case 4U:
            {
                float _S680 = sheenVelvetPDF(_S658, 0.0f, (F32_abs((_S654))), _S660, lobe_terms_1, eta_i_10, eta_o_10);
                float3  _S681 = sheenVelvetBSDF(out_dir_2, _S656, _S660, material_15, lobe_terms_1);
                pdf_8 = _S680;
                throughput_3 = _S681;
                break;
            }
        default:
            {
                float _S682 = reflectPDF(_S658, 0.0f, (F32_abs((_S654))), _S660, lobe_terms_1, eta_i_10, eta_o_10);
                float3  _S683 = reflectBSDF(out_dir_2, _S656, _S660, material_15, lobe_terms_1);
                pdf_8 = _S682;
                throughput_3 = _S683;
                break;
            }
        }
        float3  _S684;
        if(pdf_8 > 0.0f)
        {
            _S684 = throughput_3 * make_float3 (pdf_8);
        }
        else
        {
            _S684 = _S663;
        }
        if(i_12 == 0U)
        {
            f_5 = _S684;
        }
        else
        {
            f_5 = f_5 + _S684;
        }
        uint i_13 = i_12 + 1U;
        ggx_n_3 = ggx_n_4;
        i_12 = i_13;
    }
    return f_5;
}

__device__ float3  translucentCorrection(float3  in_dir_9, float3  out_dir_3, float3  n_12, float3  g_n_1, BSDFMaterial material_16, float eta_i_11, float eta_o_11, uint random_state_12)
{
    float _S685 = dot_0(n_12, out_dir_3);
    float3  _S686 = negate_0(in_dir_9);
    bool _S687 = (_S685 * dot_0(n_12, _S686)) < 0.0f;
    float3  _S688 = negate_0(in_dir_9);
    float _S689 = dot_0(n_12, _S688);
    float _S690 = sign_0(_S689);
    float3  _S691 = n_12 * make_float3 (_S690);
    AnisotropicFrame _S692 = anisotropicFrame(material_16, _S691);
    float _S693 = material_16.roughness;
    float _S694 = _S693 * _S693;
    float3  _S695 = negate_0(in_dir_9);
    float3  _S696 = sampledHalf(in_dir_9, n_12, material_16, random_state_12, _S692);
    BSDFLobes _S697 = bsdfLobes(in_dir_9, _S695, _S691, _S696, material_16, eta_i_11, eta_o_11, _S692);
    BSDFLobes sampled_0 = _S697;
    float _S698 = translucentShare(material_16);
    (&sampled_0)->translucent_share = _S698;
    float _S699 = diffusePDF(dot_0(_S691, out_dir_3), 0.0f, (F32_abs((_S689))), _S694, sampled_0, eta_i_11, eta_o_11);
    float3  _S700;
    if(_S699 > 0.0f)
    {
        float3  _S701 = diffuseBSDF(out_dir_3, _S691, _S694, material_16, sampled_0);
        _S700 = _S701 * make_float3 (_S699);
    }
    else
    {
        _S700 = make_float3 (0.0f);
    }
    float3  _S702 = negate_0(in_dir_9);
    bool _S703 = (dot_0(g_n_1, _S702) * dot_0(g_n_1, out_dir_3)) > 0.0f;
    float3  _S704 = make_float3 (0.0f);
    float _S705 = _slang_select(_S703, -1.0f,1.0f);
    float3  _S706 = _S700 * make_float3 (_S705);
    float3  _S707 = _slang_select(_S687, _S706,_S704);
    return _S707;
}

__device__ float3  translucentBSDF(float3  in_dir_10, float3  out_dir_4, float3  n_13, float3  g_n_2, BSDFMaterial material_17, float eta_i_12, float eta_o_12, uint random_state_13)
{
    float3  _S708 = BSDF(in_dir_10, out_dir_4, n_13, g_n_2, material_17, eta_i_12, eta_o_12, random_state_13);
    float3  _S709 = translucentCorrection(in_dir_10, out_dir_4, n_13, g_n_2, material_17, eta_i_12, eta_o_12, random_state_13);
    return _S708 + _S709;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_11, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_18, float eta_i_13, float eta_o_13, bool competing_1, uint random_state_14)
{
    bool _S710 = !competing_1;
    bool _S711;
    if(_S710)
    {
        _S711 = true;
    }
    else
    {
        _S711 = (light_2->density) == 0.0f;
    }
    if(_S711)
    {
        bool _S712 = isTranslucent_0(material_18);
        if(_S712)
        {
            float3  _S713 = translucentBSDF(in_dir_11, light_2->dir, smooth_n_5, geometry_n_4, *material_18, eta_i_13, eta_o_13, random_state_14);
            return _S713 * light_2->radiance;
        }
        float3  _S714 = BSDF(in_dir_11, light_2->dir, smooth_n_5, geometry_n_4, *material_18, eta_i_13, eta_o_13, random_state_14);
        return _S714 * light_2->radiance;
    }
    float3  _S715 = light_2->dir;
    bool _S716 = (dot_0(geometry_n_4, - in_dir_11) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    float3  _S717 = neeBSDF(in_dir_11, _S715, smooth_n_5, *material_18, eta_i_13, eta_o_13, _S716, light_2->density, true, random_state_14);
    return _S717 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_4, uint random_state_15, bool refracted_4, uint lobe_4, float pdf_9)
{
    SampleBSDF _S718;
    (&_S718)->unit_direction = unit_direction_1;
    (&_S718)->throughput = throughput_4;
    (&_S718)->random_state = random_state_15;
    (&_S718)->refracted = refracted_4;
    (&_S718)->lobe = lobe_4;
    (&_S718)->pdf = pdf_9;
    return _S718;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_7, float n_i_dot_v_5, float alpha_13, BSDFMaterial material_19, BSDFLobes lobes_9, float eta_i_14, float eta_o_14, uint random_state_16)
{
    float3  _S719 = make_float3 (1.0f);
    SampleBSDF _S720 = SampleBSDF_x24init_0(_S719, _S719, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S720;
    Random _S721 = pcg(random_state_16);
    Random _S722 = pcg(_S721.state);
    (&sample_1)->random_state = _S722.state;
    float _S723 = _S721.value;
    float _S724 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S723 * _S723))))));
    float _S725 = 6.28318548202514648f * _S722.value;
    float3  _S726 = tangentToWorld(make_float3 (_S724 * (F32_cos((_S725))), _S721.value, _S724 * (F32_sin((_S725)))), n_i_7);
    (&sample_1)->unit_direction = _S726;
    (&sample_1)->lobe = 4U;
    float3  _S727 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_7, alpha_13, material_19, lobes_9);
    (&sample_1)->throughput = _S727;
    float _S728 = sheenVelvetPDF(_S721.value, 0.0f, n_i_dot_v_5, alpha_13, lobes_9, eta_i_14, eta_o_14);
    (&sample_1)->pdf = _S728;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S729 = (F32_sqrt((random_1_0)));
    float _S730 = 6.28318548202514648f * random_2_0;
    float _S731 = _S729 * (F32_cos((_S730)));
    float _S732 = _S729 * (F32_sin((_S730)));
    float _S733 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S731 * _S731 - _S732 * _S732))))));
    return make_float3 (_S731, _S733, _S732);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_8, float n_i_dot_v_6, float alpha_14, BSDFMaterial material_20, BSDFLobes lobes_10, float eta_i_15, float eta_o_15, uint random_state_17)
{
    float3  _S734 = make_float3 (1.0f);
    SampleBSDF _S735 = SampleBSDF_x24init_0(_S734, _S734, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S735;
    Random _S736 = pcg(random_state_17);
    Random _S737 = pcg(_S736.state);
    (&sample_2)->random_state = _S737.state;
    float3  _S738 = sampleCosWeightedHemisphere(_S736.value, _S737.value);
    bool _S739 = u_3 < (lobes_10.p_diffuse * lobes_10.translucent_share);
    float _S740 = _S738.y;
    float _S741 = - _S740;
    float _S742 = _slang_select(_S739, _S741,_S740);
    float3  _S743 = tangentToWorld(make_float3 (_S738.x, _S742, _S738.z), n_i_8);
    (&sample_2)->unit_direction = _S743;
    (&sample_2)->refracted = _S739;
    (&sample_2)->lobe = 0U;
    float3  _S744 = diffuseBSDF((&sample_2)->unit_direction, n_i_8, alpha_14, material_20, lobes_10);
    (&sample_2)->throughput = _S744;
    float _S745 = diffusePDF(_S742, 0.0f, n_i_dot_v_6, alpha_14, lobes_10, eta_i_15, eta_o_15);
    (&sample_2)->pdf = _S745;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_5, float3  n_i_9, float n_i_dot_v_7, float alpha_15, BSDFMaterial material_21, BSDFLobes lobes_11, float eta_i_16, float eta_o_16, uint random_state_18)
{
    float3  _S746 = make_float3 (1.0f);
    SampleBSDF _S747 = SampleBSDF_x24init_0(_S746, _S746, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S747;
    (&sample_3)->unit_direction = lobes_11.refracted;
    (&sample_3)->random_state = random_state_18;
    (&sample_3)->refracted = true;
    (&sample_3)->lobe = 1U;
    float3  _S748 = refractBSDF((&sample_3)->unit_direction, n_i_9, alpha_15, material_21, lobes_11);
    (&sample_3)->throughput = _S748;
    float _S749 = refractPDF(0.0f, dot_0((&sample_3)->unit_direction, ggx_n_5), n_i_dot_v_7, alpha_15, lobes_11, eta_i_16, eta_o_16);
    (&sample_3)->pdf = _S749;
    return sample_3;
}

static __device__ float3  reflect_0(float3  i_14, float3  n_14)
{
    return i_14 - make_float3 (2.0f * dot_0(n_14, i_14)) * n_14;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_12, float3  ggx_n_6, float3  n_i_10, float n_i_dot_v_8, float alpha_16, BSDFMaterial material_22, BSDFLobes lobes_12, float eta_i_17, float eta_o_17, uint random_state_19)
{
    float3  _S750 = make_float3 (1.0f);
    SampleBSDF _S751 = SampleBSDF_x24init_0(_S750, _S750, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S751;
    float3  _S752 = reflect_0(in_dir_12, ggx_n_6);
    float3  _S753 = ((((_S752)) * make_float3(rnorm3df(((_S752)).x, ((_S752)).y, ((_S752)).z))));
    (&sample_4)->unit_direction = _S753;
    (&sample_4)->random_state = random_state_19;
    (&sample_4)->lobe = 2U;
    float3  _S754 = reflectBSDF((&sample_4)->unit_direction, n_i_10, alpha_16, material_22, lobes_12);
    (&sample_4)->throughput = _S754;
    float _S755 = reflectPDF(0.0f, 0.0f, n_i_dot_v_8, alpha_16, lobes_12, eta_i_17, eta_o_17);
    (&sample_4)->pdf = _S755;
    return sample_4;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_13, float3  n_15, BSDFMaterial material_23, float eta_i_18, float eta_o_18, uint random_init_0, float2  screen_space_0)
{
    uint random_state_20 = random_init_0;
    float3  _S756 = negate_0(in_dir_13);
    float _S757 = dot_0(n_15, _S756);
    float _S758 = sign_0(_S757);
    float3  n_i_11 = n_15 * make_float3 (_S758);
    float _S759 = (F32_abs((_S757)));
    float _S760 = material_23.roughness;
    float _S761 = _S760 * _S760;
    AnisotropicFrame _S762 = anisotropicFrame(material_23, n_i_11);
    float3  _S763 = sampleHalfVector(_S756, n_i_11, _S761, _S762, &random_state_20);
    BSDFLobes _S764 = bsdfLobes(in_dir_13, _S756, n_i_11, _S763, material_23, eta_i_18, eta_o_18, _S762);
    BSDFLobes lobes_13 = _S764;
    float _S765 = translucentShare(material_23);
    (&lobes_13)->translucent_share = _S765;
    Random _S766 = pcg(random_state_20);
    random_state_20 = _S766.state;
    bool _S767 = (_S766.value) < ((&lobes_13)->p_sheen_velvet);
    if(_S767)
    {
        SampleBSDF _S768 = sheenVelvetSample(n_i_11, _S759, _S761, material_23, lobes_13, eta_i_18, eta_o_18, random_state_20);
        return _S768;
    }
    float _S769 = _S766.value - (&lobes_13)->p_sheen_velvet;
    bool _S770 = _S769 < ((&lobes_13)->p_diffuse);
    if(_S770)
    {
        SampleBSDF _S771 = diffuseSample(_S769, n_i_11, _S759, _S761, material_23, lobes_13, eta_i_18, eta_o_18, random_state_20);
        return _S771;
    }
    bool _S772 = _S769 < ((&lobes_13)->p_diffuse + (&lobes_13)->p_refract);
    if(_S772)
    {
        SampleBSDF _S773 = refractSample(_S763, n_i_11, _S759, _S761, material_23, lobes_13, eta_i_18, eta_o_18, random_state_20);
        return _S773;
    }
    SampleBSDF _S774 = reflectSample(in_dir_13, _S763, n_i_11, _S759, _S761, material_23, lobes_13, eta_i_18, eta_o_18, random_state_20);
    return _S774;
}

__device__ bool withinInverseFootprint(float pdf_10, bool diffuse_0, float prev_cos_0, float distance_4, float threshold_1)
{
    bool _S775 = pdf_10 > 0.0f;
    bool _S776;
    if(_S775)
    {
        if(diffuse_0)
        {
            _S776 = true;
        }
        else
        {
            _S776 = (pdf_10 * prev_cos_0 / (distance_4 * distance_4) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S776 = false;
    }
    return _S776;
}

__device__ bool roughLobe(float pdf_11, bool diffuse_1, float roughness_1)
{
    bool _S777 = pdf_11 > 0.0f;
    bool _S778;
    if(_S777)
    {
        if(diffuse_1)
        {
            _S778 = true;
        }
        else
        {
            _S778 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S778 = false;
    }
    return _S778;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S779 = layers_0 > 1U;
    bool _S780;
    if(_S779)
    {
        _S780 = refracting_0 != passed_0;
    }
    else
    {
        _S780 = false;
    }
    return _S780;
}

static __device__ float widened_0(float spread_0, float pdf_12, bool delta_0)
{
    float _S781 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_12))))), (3.14159274101257324f)));
    bool _S782 = !delta_0;
    float _S783 = _slang_select(_S782, _S781,0.0f);
    return spread_0 + _S783;
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
    bool _S784;
    float density_2;
    float threshold_2;
    float width_2;
    float sky_pdf_0;
    float geometry_density_2;
    uint b_4;
    uint layer_0;
    float3  throughput_5;
    float3  chain_throughput_0;
    TreeSample light_3;
    int _S785;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_3;
    float sky_pdf_1;
    float spread_3;
    float width_4;
    uint b_5;
    float3  _S786 = make_float3 (0.0f);
    Shift _S787 = Shift_x24init_0(_S786, 0.0f);
    uint _S788 = r_1->path;
    uint _S789 = extractBits_0(r_1->path, 0U, 5U);
    uint _S790 = extractBits_0(_S788, 5U, 5U);
    uint _S791 = extractBits_0(_S788, 10U, 2U);
    uint _S792 = extractBits_0(_S788, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S793 = _S792 >= 3U;
        uint _S794 = _slang_select(_S793, 1U,0U);
        uint _S795 = _S789 + _S794;
        uint _S796 = (fcptMaxBounces());
        passes_0 = _S795 > _S796;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S787;
    }
    uint _S797 = _S790 - 1U;
    bool _S798 = _S792 == 3U;
    uint _S799 = _slang_select(_S798, 1U,0U);
    uint _S800 = _S789 + _S799;
    bool _S801 = _S791 == 0U;
    uint _S802 = _slang_select(_S801, _S800,_S797);
    FKHit _S803 = (fcptReservoirHit((*r_1)));
    float3  _S804 = dom_0->x0;
    float3  _S805 = dom_0->x1 - dom_0->x0;
    float3  _S806 = ((((_S805)) * make_float3(rnorm3df(((_S805)).x, ((_S805)).y, ((_S805)).z))));
    FKRay _S807 = Ray_x24init_0(dom_0->x1, _S806);
    FKRay ray_2 = _S807;
    FKHit hit_1 = dom_0->hit;
    float3  scatter_in_0 = _S786;
    float3  throughput_6 = make_float3 (1.0f);
    float3  weight_1 = throughput_6;
    float3  glowed_0 = _S786;
    float3  extinction_in_0 = _S786;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S808 = dom_0->spread;
    float _S809 = dom_0->width;
    float _S810 = length_0(_S805);
    NEEVertex _S811 = NEEVertex_x24init_0(true, 0.0f, _S786, _S786, _S786);
    NEEVertex nee_vertex_0 = _S811;
    Vertex _S812 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S812;
    Reservoir _S813 = (Reservoir{});
    Reservoir chain_0 = _S813;
    uint _S814 = r_1->seed;
    (&chain_0)->seed = r_1->seed;
    (&ray_2)->origin = _S804;
    (&hit_1)->distance = _S810;
    FKMedium _S815 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_1)->distance), (&filling_2)));
    uint _S816 = filling_2;
    bool _S817 = (fcptVaryingUsed());
    uint _S818 = _slang_select(_S817, _S816,4294967295U);
    filling_2 = _S818;
    scatter_in_0 = _S815.scatter;
    extinction_in_0 = _S815.extinction;
    g_in_0 = _S815.g;
    Reservoir _S819 = chain_0;
    uint _S820 = filling_2;
    for(;;)
    {
        bool _S821 = (fcptVaryingUsed());
        if(_S821)
        {
            passes_0 = _S820 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S822 = (fcptMajorant((_S820)));
            spread_1 = _S822;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S802;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S791 == 1U;
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
            ended_0 = _S787;
            sky_pdf_0 = 0.0f;
            spread_1 = _S808;
            width_2 = _S809;
            density_2 = 1.0f;
            throughput_5 = throughput_6;
            b_4 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S823 = (&prev_0)->rough;
        if(_S823)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S824 = stream(_S814, 384U);
        uint tracking_0 = _S824;
        weight_1 = throughput_6;
        glowed_0 = _S786;
        b_4 = 4294967295U;
        throughput_5 = throughput_6;
        density_2 = 1.0f;
        threshold_2 = _S808;
        width_2 = _S809;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_1)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S785 = int(1);
                break;
            }
            uint _S825 = b_4 + 320U;
            bool _S826 = b_4 == 4294967295U;
            uint _S827 = _slang_select(_S826, 384U,_S825);
            uint _S828 = stream(_S814, _S827);
            Random _S829 = pcg(_S828);
            float _S830 = freeFlight_0(_S829.value, spread_1);
            if(passes_0)
            {
                float3  _S831 = (&ray_2)->origin;
                float3  _S832 = (&ray_2)->unit_direction;
                float _S833 = (&hit_1)->distance;
                uint _S834 = _slang_select(_S826, 0U,b_4);
                uint _S835 = (&prev_0)->lobe;
                uint _S836 = _slang_select(_S826, 3U,_S835);
                float _S837 = (fcptTrackMedium((_S820), (_S831), (_S832), (_S833), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S834), (_S836), (_S826)));
                geometry_density_2 = _S837;
            }
            else
            {
                geometry_density_2 = _S830;
            }
            bool _S838 = !(geometry_density_2 < ((&hit_1)->distance));
            if(_S838)
            {
                _S785 = int(1);
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
                float3  _S839 = throughput_5 * glowed_0 / make_float3 (density_2);
                float3  _S840 = sel_1->glow + _S839;
                sel_1->glow = _S840;
            }
            else
            {
            }
            glowed_0 = _S786;
            uint b_6 = b_4 + 1U;
            float3  _S841 = (&ray_2)->origin + make_float3 (geometry_density_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S841;
            float3  _S842 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, geometry_density_2, true);
            float3  _S843 = weight_1;
            float3  _S844 = _slang_select(passes_0, _S843,_S842);
            float3  throughput_7 = throughput_5 * _S844;
            uint _S845 = stream(_S814, b_6 + 320U);
            tracking_0 = _S845;
            weight_1 = throughput_6;
            float width_5 = width_2 + threshold_2 * geometry_density_2;
            float _S846 = threshold_2 + 3.14159274101257324f;
            bool _S847 = scatterSampled_0(replay_1, b_6, _S802, passes_0);
            TreeSample _S848 = TreeSample_x24init_0(_S786, _S786, 0.0f, 0U);
            if(_S847)
            {
                float3  _S849 = (&ray_2)->origin;
                float3  _S850 = (&ray_2)->unit_direction;
                float3  _S851 = (&ray_2)->unit_direction;
                uint _S852 = stream(_S814, b_6 + 64U);
                float3  _S853 = extinction_in_0;
                float3  _S854 = extinction_in_0;
                uint2  _S855 = make_uint2 (_S820);
                float3  _S856 = (&ray_2)->unit_direction;
                uint _S857 = arrivalLobe_0(b_6, (&prev_0)->lobe);
                FKHit _S858 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S859 = _S858;
                ShadowContext _S860 = ShadowContext_x24init_0(_S853, _S854, _S855, _S856, b_6, _S857, false, geometry_density_2, width_5, &_S859, false);
                ShadowContext _S861 = _S860;
                TreeSample _S862 = sampleLightTree_0(_S849, _S850, _S851, 0.0f, true, _S852, &_S861);
                light_3 = _S862;
            }
            else
            {
                light_3 = _S848;
            }
            float _S863 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S864 = (fcptMaxBounces());
            bool _S865 = b_6 < _S864;
            if(_S865)
            {
                is_inside_5 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_5 = false;
            }
            float _S866 = _slang_select(is_inside_5, _S863,0.0f);
            float3  _S867 = throughput_7 * light_3.radiance;
            float _S868 = powerHeuristic(light_3.density, _S866);
            float3  _S869 = _S867 * make_float3 (_S863 * _S868);
            float3  _S870 = _slang_select(_S847, _S869,_S786);
            if(replay_1)
            {
                viewed_0 = b_6 == _S802;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S871 = _S791 == 2U;
                if(_S871)
                {
                    float _S872 = rgb_to_greyscale(_S870);
                    passes_0 = _S872 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S873 = Shift_x24init_0(_S870, 1.0f);
                    _S785 = int(0);
                    ended_0 = _S873;
                    spread_1 = _S846;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_7;
                    layer_0 = b_6;
                    break;
                }
                _S785 = int(0);
                ended_0 = _S787;
                spread_1 = _S846;
                geometry_density_2 = width_5;
                chain_throughput_0 = throughput_7;
                layer_0 = b_6;
                break;
            }
            bool _S874 = !replay_1;
            if(_S874)
            {
                Reservoir candidate_2 = _S819;
                uint _S875 = extractBits_0(_S819.path, 10U, 2U);
                bool _S876 = _S875 == 1U;
                if(_S876)
                {
                    float3  _S877 = safeDivide(_S870, _S786);
                    (&candidate_2)->radiance = _S877;
                }
                else
                {
                    uint _S878 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                    uint _S879 = insertBits_0(_S878, 2U, 10U, 2U);
                    (&candidate_2)->path = _S879;
                }
                Reservoir _S880 = withEnd(candidate_2, 0U, b_6, _S870);
                offer(sel_1, _S880, _S870 * make_float3 (scale_1) / make_float3 (density_2));
                float _S881 = survivalProbability(throughput_7, density_2);
                uint _S882 = stream(_S814, b_6 + 128U);
                Random _S883 = pcg(_S882);
                bool _S884 = _S881 < (_S883.value);
                if(_S884)
                {
                    _S784 = true;
                }
                else
                {
                    uint _S885 = (fcptMaxBounces());
                    _S784 = b_6 >= _S885;
                }
                if(_S784)
                {
                    _S785 = int(0);
                    ended_0 = _S787;
                    spread_1 = _S846;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_7;
                    layer_0 = b_6;
                    break;
                }
                float _S886 = density_2 * _S881;
                density_2 = _S886;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S887 = stream(_S814, b_6);
            float3  _S888 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S887, &phase_pdf_0);
            (&ray_2)->unit_direction = _S888;
            NEEVertex _S889 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S786, (&ray_2)->origin);
            nee_vertex_0 = _S889;
            Vertex _S890 = scatteredVertex_0(false);
            prev_0 = _S890;
            float _S891 = (&prev_0)->pdf;
            FKRay _S892 = ray_2;
            FKHit _S893 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S894 = (fcptTraverseInstanceBVH((_S892), (true), (4.294967296e+09f), (false), (_S893), (false)));
            hit_1 = _S894;
            b_4 = b_6;
            throughput_5 = throughput_7;
            threshold_2 = _S846;
            width_2 = width_5;
            sky_pdf_0 = _S891;
        }
        if(_S785 != int(1))
        {
            width_2 = geometry_density_2;
            throughput_5 = chain_throughput_0;
            b_4 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S787;
        spread_1 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S895 = b_4 == 4294967295U;
    bool _S896 = ((&hit_1)->instance_index) == 4294967295U;
    if(_S896)
    {
        bool _S897 = !(&nee_vertex_0)->none;
        float _S898 = _slang_select(_S897, sky_pdf_0,0.0f);
        float _S899 = escapeWeight_0(_S898, (&ray_2)->unit_direction);
        float3  _S900 = environment_0((&ray_2)->unit_direction, b_4, (&prev_0)->lobe);
        float3  _S901 = throughput_5 * _S900;
        if(replay_1)
        {
            bool _S902 = b_4 == _S802;
            if(_S902)
            {
                passes_0 = _S791 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S901 * make_float3 (_S899) / make_float3 (r_1->jac), density_2 / r_1->jac);
            }
            if(_S801)
            {
                passes_0 = _S798;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_4 == _S789;
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
                return Shift_x24init_0(_S901 * make_float3 (_S899), 1.0f);
            }
            return _S787;
        }
        Reservoir candidate_3 = chain_0;
        uint _S903 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S904 = _S903 == 1U;
        if(_S904)
        {
            uint _S905 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S906 = _S905 == b_4;
            float _S907 = _slang_select(_S906, 1.0f,_S899);
            float3  _S908 = safeDivide(_S901 * make_float3 (_S907), _S786);
            (&candidate_3)->radiance = _S908;
        }
        else
        {
            bool _S909 = (&prev_0)->rough;
            if(_S909)
            {
                uint _S910 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                uint _S911 = insertBits_0(_S910, 3U, 10U, 2U);
                uint _S912 = insertBits_0(_S911, (&prev_0)->lobe, 15U, 3U);
                bool _S913 = (&prev_0)->inside;
                uint _S914 = _slang_select(_S913, 1U,0U);
                uint _S915 = insertBits_0(_S912, _S914, 22U, 1U);
                (&candidate_3)->path = _S915;
                (&candidate_3)->jac = (&prev_0)->pdf;
                (&candidate_3)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S916 = _S901 * make_float3 (_S899);
        Reservoir _S917 = withEnd(candidate_3, 3U, b_4, _S916);
        offer(sel_1, _S917, _S916 * make_float3 (scale_1) / make_float3 (density_2));
        return _S787;
    }
    float3  _S918 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S918;
    bool _S919 = (fcptVaryingUsed());
    if(_S919)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S920 = !replay_1;
        if(_S920)
        {
            float3  _S921 = throughput_5 * glowed_0 / make_float3 (density_2);
            float3  _S922 = sel_1->glow + _S921;
            sel_1->glow = _S922;
        }
        float3  _S923 = throughput_5 * weight_1;
        throughput_5 = _S923;
    }
    else
    {
        float3  _S924 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
        float3  _S925 = throughput_5 * _S924;
        throughput_5 = _S925;
    }
    float _S926 = width_2 + spread_1 * (&hit_1)->distance;
    uint _S927 = b_4 + 1U;
    b_4 = _S927;
    layer_0 = 0U;
    width_2 = _S926;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S786;
    float3  reconnection_0 = _S786;
    viewed_0 = _S895;
    for(;;)
    {
        bool _S928 = ((&hit_1)->is_point_light) == 1U;
        if(replay_1)
        {
            _S784 = _S791 == 1U;
        }
        else
        {
            _S784 = false;
        }
        bool _S929;
        if(_S784)
        {
            _S929 = b_4 == _S790;
        }
        else
        {
            _S929 = false;
        }
        bool _S930;
        if(_S929)
        {
            bool _S931 = ((&hit_1)->instance_index) != (_S803.instance_index);
            if(_S931)
            {
                _S930 = true;
            }
            else
            {
                _S930 = ((&hit_1)->triangle_index) != (_S803.triangle_index);
            }
        }
        else
        {
            _S930 = false;
        }
        if(_S930)
        {
            return _S787;
        }
        FKMedium _S932 = Medium_x24init_0(_S786, _S786, 0.0f);
        BSDFMaterial _S933 = Material_x24init_0(_S786, _S786, 0.0f, 0.0f, 0.0f, 0.0f, _S786, throughput_6, 1.0f, _S786, _S786, 0.5f, 0.0f, 0.0f, _S786);
        FKMedium _S934 = _S932;
        FKSurface _S935 = Surface_x24init_0(_S786, _S786, 0.0f, &_S933, false, 0U, 1.0f, false, &_S934, 4294967295U, _S786);
        bool _S936 = !_S928;
        bool scatter_2;
        bool is_inside_6;
        float3  throughput_8;
        FKSurface surface_11;
        if(_S936)
        {
            uint _S937 = stream(_S814, b_4);
            uint _S938 = arrivalLobe_0(b_4, (&prev_0)->lobe);
            FKSurface _S939 = (fcptSurfaceAtPath((hit_1), ((&ray_2)->origin), (_S937), (width_2), (layer_0), (b_4), (_S938), ((&ray_2)->unit_direction)));
            bool _S940 = !passes_0;
            FKSurface _S941 = _S939;
            FKSurface _S942 = emitting_0(&_S941, _S940);
            uint _S943 = stream(_S814, b_4 + 256U);
            Random _S944 = pcg(_S943);
            FKSurface _S945 = _S942;
            FKSurface _S946 = uncovered_0(&_S945, _S944.value);
            float _S947 = facingSign(_S946.material.transmission, _S946.geometry_n, (&ray_2)->unit_direction);
            bool _S948 = _S947 < 0.0f;
            bool _S949 = (_S946.material.transmission) > 0.0f;
            if(_S949)
            {
                bool _S950 = arrivesBehind_0((&ray_2)->unit_direction, _S946.geometry_n);
                scatter_2 = _S950;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S951 = _S946;
            FKSurface _S952 = facingRay_0(&_S951, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S953 = arrivesBehind_0((&ray_2)->unit_direction, _S952.geometry_n);
                is_inside_6 = _S953;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S954 = beerLambert((&hit_1)->distance, _S952.material.absorption);
                float3  _S955 = throughput_5 * _S954;
                throughput_8 = _S955;
            }
            else
            {
                throughput_8 = throughput_5;
            }
            bool _S956 = !_S952.skip;
            float geometry_density_3 = geometryDensity(_S952.geometry_n, (&ray_2)->unit_direction, (&hit_1)->distance);
            bool _S957 = b_4 == _S927;
            if(_S957)
            {
                float _S958 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S958;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S959 = geometry_density_2;
            scatter_2 = _S956;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S959;
            surface_11 = _S952;
            turned_1 = _S948;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_11 = _S935;
            throughput_8 = throughput_5;
            is_inside_6 = is_inside_5;
        }
        bool _S960 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S961 = surface_11;
        FKSurface _S962 = surface_11;
        float _S963 = dot_0(surface_11.smooth_n, - (&ray_2)->unit_direction);
        float2  _S964 = vertexEta(_S961.material, _S963);
        bool _S965;
        if(scatter_2)
        {
            bool _S966 = neeDecision(_S961.material, _S963, _S964.x, _S964.y);
            _S965 = _S966;
        }
        else
        {
            _S965 = false;
        }
        bool _S967;
        if(passes_0)
        {
            _S967 = true;
        }
        else
        {
            _S967 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S967)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S965;
        }
        bool _S968 = (fcptHairUsed());
        bool _S969;
        if(_S968)
        {
            float3  _S970 = surface_11.hair;
            _S969 = (dot_0(_S970, _S970)) > 0.0f;
        }
        else
        {
            _S969 = false;
        }
        bool _S971;
        if(_S969)
        {
            _S971 = true;
        }
        else
        {
            BSDFMaterial _S972 = _S961.material;
            bool _S973 = isTranslucent_0(&_S972);
            _S971 = _S973;
        }
        bool _S974;
        if(_S971)
        {
            _S974 = true;
        }
        else
        {
            bool _S975 = (_S961.material.transmission) > 0.0f;
            if(_S975)
            {
                uint _S976 = (fcptLayers((hit_1)));
                _S974 = _S976 == 1U;
            }
            else
            {
                _S974 = false;
            }
        }
        float3  emission_0;
        if(_S928)
        {
            float3  _S977 = (fcptCalculatePointLightContrib(((&hit_1)->instance_index)));
            emission_0 = _S977;
        }
        else
        {
            emission_0 = _S961.material.emissive;
        }
        float _S978 = rgb_to_greyscale(emission_0);
        bool _S979 = _S978 > 0.0f;
        float3  emission_1;
        if(_S979)
        {
            NEEVertex _S980 = nee_vertex_0;
            FKHit _S981 = hit_1;
            float _S982 = emissionWeight_0(&_S980, &_S981, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S982);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S983;
        if(replay_1)
        {
            _S983 = _S791 == 1U;
        }
        else
        {
            _S983 = false;
        }
        bool _S984;
        if(_S983)
        {
            _S984 = b_4 > _S790;
        }
        else
        {
            _S984 = false;
        }
        bool _S985;
        if(_S984)
        {
            _S985 = b_4 == _S789;
        }
        else
        {
            _S985 = false;
        }
        bool _S986;
        if(_S985)
        {
            bool _S987 = _S792 == 1U;
            if(_S987)
            {
                _S986 = true;
            }
            else
            {
                _S986 = _S792 == 2U;
            }
        }
        else
        {
            _S986 = false;
        }
        if(_S986)
        {
            bool _S988 = _S928 != (_S792 == 2U);
            if(_S988)
            {
                return _S787;
            }
            return Shift_x24init_0(throughput_8 * emission_1 / make_float3 (r_1->jac), density_2 / r_1->jac);
        }
        uint _S989 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S990 = _S989 == 1U;
        Reservoir here_0 = chain_0;
        uint _S991 = insertBits_0(0U, b_4, 5U, 5U);
        uint _S992 = insertBits_0(_S991, 1U, 10U, 2U);
        uint _S993 = insertBits_0(_S992, (&prev_0)->lobe, 15U, 3U);
        bool _S994 = (&prev_0)->inside;
        uint _S995 = _slang_select(_S994, 1U,0U);
        uint _S996 = insertBits_0(_S993, _S995, 22U, 1U);
        (&here_0)->path = _S996;
        float _S997 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S997;
        fcptWithReservoirHit((&here_0), (&hit_1));
        bool _S998;
        if(replay_1)
        {
            _S998 = _S791 == 1U;
        }
        else
        {
            _S998 = false;
        }
        bool _S999;
        if(_S998)
        {
            _S999 = b_4 == _S790;
        }
        else
        {
            _S999 = false;
        }
        bool _S1000 = b_4 == _S802;
        bool _S1001;
        if(_S1000)
        {
            bool _S1002 = !scatter_2;
            if(_S1002)
            {
                _S1001 = true;
            }
            else
            {
                bool _S1003 = _S791 != 1U;
                if(_S1003)
                {
                    _S1001 = _S791 != 3U;
                }
                else
                {
                    _S1001 = false;
                }
            }
        }
        else
        {
            _S1001 = false;
        }
        bool _S1004;
        if(_S1001)
        {
            _S1004 = _S791 == 2U;
        }
        else
        {
            _S1004 = false;
        }
        bool _S1005;
        if(_S1004)
        {
            _S1005 = !_S960;
        }
        else
        {
            _S1005 = false;
        }
        bool _S1006;
        if(_S1005)
        {
            _S1006 = _S792 != 4U;
        }
        else
        {
            _S1006 = false;
        }
        bool _S1007 = _S790 == _S789;
        bool _S1008;
        if(_S1007)
        {
            _S1008 = _S792 == 0U;
        }
        else
        {
            _S1008 = false;
        }
        bool _S1009;
        if(_S1008)
        {
            _S1009 = ((&hit_1)->instance_index) == (_S803.instance_index);
        }
        else
        {
            _S1009 = false;
        }
        bool _S1010;
        if(_S1009)
        {
            _S1010 = ((&hit_1)->triangle_index) == (_S803.triangle_index);
        }
        else
        {
            _S1010 = false;
        }
        bool _S1011;
        if(_S1010)
        {
            _S1011 = _S960;
        }
        else
        {
            _S1011 = false;
        }
        bool _S1012 = _slang_select(_S999, _S1011,_S1006);
        bool _S1013;
        if(nee_0)
        {
            _S1013 = _slang_select(replay_1, _S1012,scatter_2);
        }
        else
        {
            _S1013 = false;
        }
        TreeSample _S1014 = TreeSample_x24init_0(_S786, _S786, 0.0f, 0U);
        float3  throughput_9;
        float3  lit_0;
        if(_S1013)
        {
            float3  _S1015 = (&ray_2)->origin;
            if(_S969)
            {
                throughput_9 = _S786;
            }
            else
            {
                throughput_9 = _S962.smooth_n;
            }
            FKSurface _S1016 = surface_11;
            uint _S1017 = stream(_S814, b_4 + 64U);
            uint _S1018 = arrivalLobe_0(b_4, (&prev_0)->lobe);
            FKSurface _S1019 = surface_11;
            FKHit _S1020 = hit_1;
            ShadowContext _S1021 = shadowContext_0(&_S1019, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_4, _S1018, (&hit_1)->distance, width_2, &_S1020, _S969);
            ShadowContext _S1022 = _S1021;
            TreeSample _S1023 = sampleLightTree_0(_S1015, throughput_9, surface_11.geometry_n, surface_11.geometry_offset, _S974, _S1017, &_S1022);
            bool _S1024 = any_0((_S1023.radiance) != _S786);
            if(_S1024)
            {
                if(_S969)
                {
                    uint _S1025 = (fcptMaxBounces());
                    bool _S1026 = b_4 < _S1025;
                    FKSurface _S1027 = surface_11;
                    TreeSample _S1028 = _S1023;
                    float3  _S1029 = hairLight_0(&_S1027, (&ray_2)->unit_direction, &_S1028, _S1026);
                    lit_0 = _S1029;
                }
                else
                {
                    float _S1030 = _S964.x;
                    float _S1031 = _S964.y;
                    uint _S1032 = (fcptMaxBounces());
                    bool _S1033 = b_4 < _S1032;
                    TreeSample _S1034 = _S1023;
                    BSDFMaterial _S1035 = _S961.material;
                    float3  _S1036 = lightBSDF_0((&ray_2)->unit_direction, &_S1034, _S962.smooth_n, _S1016.geometry_n, &_S1035, _S1030, _S1031, _S1033, surface_11.random_state);
                    lit_0 = _S1036;
                }
            }
            else
            {
                lit_0 = _S786;
            }
            light_3 = _S1023;
        }
        else
        {
            light_3 = _S1014;
            lit_0 = _S786;
        }
        bool viewed_1;
        bool refracted_5;
        bool wrong_side_0;
        bool _S1037;
        bool _S1038;
        float density_4;
        if(_S999)
        {
            bool _S1039 = !_S960;
            if(_S1039)
            {
                return _S787;
            }
            float3  throughput_10 = throughput_8 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1007)
            {
                viewed_1 = _S792 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_10 * emission_1 / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            if(_S1007)
            {
                refracted_5 = _S792 == 0U;
            }
            else
            {
                refracted_5 = false;
            }
            if(refracted_5)
            {
                bool _S1040 = !nee_0;
                if(_S1040)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1041 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1041 > 0.0f);
                }
                if(passes_0)
                {
                    return _S787;
                }
                return Shift_x24init_0(throughput_10 * lit_0 / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            if(_S1007)
            {
                wrong_side_0 = _S792 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1042 = !nee_0;
                if(_S1042)
                {
                    return _S787;
                }
                float _S1043 = environmentPdf_0(r_1->dir);
                float3  _S1044 = skyBSDF((&ray_2)->unit_direction, r_1->dir, surface_11, _S964, is_inside_6, _S1043, surface_11.random_state);
                return Shift_x24init_0(throughput_10 * _S1044 * r_1->radiance / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            uint _S1045 = extractBits_0(_S788, 21U, 1U);
            bool _S1046 = nee_0 != (_S1045 == 1U);
            if(_S1046)
            {
                return _S787;
            }
            throughput_9 = throughput_10;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S1000;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1047 = !scatter_2;
                if(_S1047)
                {
                    refracted_5 = true;
                }
                else
                {
                    bool _S1048 = _S791 != 1U;
                    if(_S1048)
                    {
                        refracted_5 = _S791 != 3U;
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
                bool _S1049 = _S791 == 2U;
                if(_S1049)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S960;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S792 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    uint _S1050 = stream(_S814, b_4 + 448U);
                    FKRay _S1051 = ray_2;
                    FKSurface _S1052 = surface_11;
                    SkySample _S1053 = sampleSky_0(&_S1051, &_S1052, _S964, is_inside_6, _S1050, surface_11.random_state);
                    return Shift_x24init_0(throughput_8 * _S1053.color, 1.0f);
                }
                if(_S1049)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S960;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1054 = rgb_to_greyscale(light_3.radiance);
                    bool _S1055 = !(_S1054 > 0.0f);
                    if(_S1055)
                    {
                        return _S787;
                    }
                    return Shift_x24init_0(throughput_8 * lit_0, 1.0f);
                }
                if(_S801)
                {
                    passes_0 = _S792 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S928;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_8 * emission_1, 1.0f);
                }
                if(_S801)
                {
                    passes_0 = _S792 == 1U;
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
                    passes_0 = !_S960;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_8 * emission_1, 1.0f);
                }
                return _S787;
            }
            else
            {
                bool _S1056 = !replay_1;
                if(_S1056)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1057 = b_4 > 0U;
                    if(_S1057)
                    {
                        Reservoir candidate_4 = chain_0;
                        if(_S990)
                        {
                            float3  _S1058 = safeDivide(throughput_8 * emission_1, chain_throughput_0);
                            (&candidate_4)->radiance = _S1058;
                        }
                        else
                        {
                            if(_S960)
                            {
                                candidate_4 = here_0;
                            }
                        }
                        float3  _S1059 = throughput_8 * emission_1;
                        Reservoir _S1060 = withEnd(candidate_4, 1U, b_4, _S1059);
                        offer(sel_1, _S1060, _S1059 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1061 = throughput_8 * emission_1;
                        float3  _S1062 = sel_1->glow + _S1061;
                        sel_1->glow = _S1062;
                    }
                    if(nee_0)
                    {
                        float3  _S1063 = throughput_8 * lit_0;
                        Reservoir candidate_5 = chain_0;
                        if(_S990)
                        {
                            float3  _S1064 = safeDivide(_S1063, chain_throughput_0);
                            (&candidate_5)->radiance = _S1064;
                        }
                        else
                        {
                            if(_S960)
                            {
                                candidate_5 = here_0;
                                uint _S1065 = insertBits_0((&candidate_5)->path, 1U, 21U, 1U);
                                (&candidate_5)->path = _S1065;
                                (&candidate_5)->dir = light_3.dir;
                                (&candidate_5)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1066 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S1067 = insertBits_0(_S1066, 2U, 10U, 2U);
                                (&candidate_5)->path = _S1067;
                            }
                        }
                        Reservoir _S1068 = withEnd(candidate_5, 0U, b_4, _S1063);
                        offer(sel_1, _S1068, _S1063 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S969)
                        {
                            _S1037 = false;
                        }
                        else
                        {
                            bool _S1069 = environmentMapped_0();
                            _S1037 = _S1069;
                        }
                    }
                    else
                    {
                        _S1037 = false;
                    }
                    if(_S1037)
                    {
                        uint _S1070 = (fcptMaxBounces());
                        _S1038 = b_4 < _S1070;
                    }
                    else
                    {
                        _S1038 = false;
                    }
                    if(_S1038)
                    {
                        uint _S1071 = stream(_S814, b_4 + 448U);
                        FKRay _S1072 = ray_2;
                        FKSurface _S1073 = surface_11;
                        SkySample _S1074 = sampleSky_0(&_S1072, &_S1073, _S964, is_inside_6, _S1071, surface_11.random_state);
                        float3  _S1075 = throughput_8 * _S1074.color;
                        Reservoir candidate_6 = chain_0;
                        if(_S990)
                        {
                            float3  _S1076 = safeDivide(_S1075, chain_throughput_0);
                            (&candidate_6)->radiance = _S1076;
                        }
                        else
                        {
                            if(_S960)
                            {
                                candidate_6 = here_0;
                                uint _S1077 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1077;
                                (&candidate_6)->dir = _S1074.dir;
                                (&candidate_6)->radiance = _S1074.radiance;
                            }
                            else
                            {
                                uint _S1078 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S1079 = insertBits_0(_S1078, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1079;
                            }
                        }
                        Reservoir _S1080 = withEnd(candidate_6, 4U, b_4, _S1075);
                        offer(sel_1, _S1080, _S1075 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                }
            }
            throughput_9 = throughput_8;
            density_4 = density_2;
        }
        bool _S1081;
        bool _S1082;
        bool straight_0;
        bool _S1083;
        bool _S1084;
        bool _S1085;
        bool _S1086;
        bool _S1087;
        bool _S1088;
        bool _S1089;
        bool _S1090;
        bool _S1091;
        bool _S1092;
        bool _S1093;
        bool _S1094;
        bool _S1095;
        float density_6;
        float sky_pdf_2;
        float spread_4;
        uint b_7;
        float3  throughput_11;
        float3  throughput_12;
        float3  throughput_13;
        if(scatter_2)
        {
            if(replay_1)
            {
                viewed_1 = _S1000;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1096 = extractBits_0(_S788, 15U, 3U);
            uint _S1097 = extractBits_0(_S788, 18U, 3U);
            uint _S1098 = _slang_select(_S999, _S1097,_S1096);
            float3  _S1099 = r_1->dir;
            bool refracted_6 = _S1098 == 1U;
            SampleBSDF _S1100 = SampleBSDF_x24init_0(_S786, _S786, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1100;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1101 = extractBits_0(_S788, 22U, 1U);
                bool _S1102 = is_inside_6 != (_S1101 == 1U);
                if(_S1102)
                {
                    return _S787;
                }
                bool _S1103 = _S791 == 1U;
                if(_S1103)
                {
                    float3  _S1104 = (fcptHitPosition((_S803)));
                    throughput_11 = _S1104;
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
                    BSDFMaterial _S1105 = _S961.material;
                    bool _S1106 = isTranslucent_0(&_S1105);
                    if(_S1106)
                    {
                        refracted_5 = _S1098 == 0U;
                    }
                    else
                    {
                        refracted_5 = false;
                    }
                    if(refracted_5)
                    {
                        float3  _S1107 = throughput_11 - (&ray_2)->origin;
                        float3  _S1108 = _slang_select(_S1103, _S1107,_S1099);
                        wrong_side_0 = (dot_0(_S962.smooth_n, _S1108) * _S963) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_5 = wrong_side_0;
                }
                if(_S1103)
                {
                    float3  _S1109 = (&ray_2)->origin;
                    FKSurface _S1110 = surface_11;
                    float3  _S1111 = - _S962.smooth_n;
                    bool _S1112 = is_inside_6 != refracted_5;
                    float3  _S1113 = _slang_select(_S1112, _S1111,_S962.smooth_n);
                    float3  _S1114 = throughput_11 - (_S1109 + make_float3 (_S1110.geometry_offset) * _S1113);
                    float3  _S1115 = ((((_S1114)) * make_float3(rnorm3df(((_S1114)).x, ((_S1114)).y, ((_S1114)).z))));
                    reconnection_1 = _S1115;
                }
                else
                {
                    reconnection_1 = _S1099;
                }
                if(_S969)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1116 = wrongSide_0(is_inside_6, refracted_5, reconnection_1, surface_11.geometry_n);
                    wrong_side_0 = _S1116;
                }
                if(wrong_side_0)
                {
                    return _S787;
                }
                float3  _S1117 = throughput_11;
                throughput_11 = reconnection_1;
                b_7 = _S1098;
                wrong_side_0 = false;
                reconnection_1 = _S1117;
            }
            else
            {
                bool _S1118 = !_S999;
                if(_S1118)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1119;
                    if(_S969)
                    {
                        SampleBSDF _S1120 = (fcptSampleHair((surface_11.hair), (_S961.material.albedo), (_S961.material.specular_tint), ((&ray_2)->unit_direction), (surface_11.random_state)));
                        _S1119 = _S1120;
                    }
                    else
                    {
                        SampleBSDF _S1121 = sampleBSDF((&ray_2)->unit_direction, _S962.smooth_n, _S961.material, _S964.x, _S964.y, surface_11.random_state, make_float2 (0.0f));
                        _S1119 = _S1121;
                    }
                    bsdf_sampled_0 = _S1119;
                    if(_S969)
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
                            return _S787;
                        }
                        break;
                    }
                    if(_S969)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1122 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_11.geometry_n);
                        wrong_side_0 = _S1122;
                    }
                    if(wrong_side_0)
                    {
                        _S1037 = (_S961.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1037 = false;
                    }
                    if(_S1037)
                    {
                        SampleBSDF _S1123 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n, _S961.material, _S964.x, _S964.y, (&bsdf_sampled_0)->random_state, make_float2 (0.0f));
                        (&bsdf_sampled_0)->unit_direction = _S1123.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1123.refracted;
                        (&bsdf_sampled_0)->throughput = _S1123.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1124 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n)) * surface_11.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1124;
                        }
                    }
                    uint _S1125 = (&bsdf_sampled_0)->lobe;
                    float3  _S1126 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1127 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1128 = (&bsdf_sampled_0)->pdf;
                    float _S1129 = _slang_select(wrong_side_0, 0.0f,_S1128);
                    (&lobe_5)->pdf = _S1129;
                    throughput_11 = _S1126;
                    b_7 = _S1125;
                    refracted_5 = _S1127;
                }
                else
                {
                    throughput_11 = _S1099;
                    b_7 = _S1098;
                    wrong_side_0 = false;
                    refracted_5 = refracted_6;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1037 = true;
            }
            else
            {
                _S1037 = _S999;
            }
            float3  chain_throughput_1;
            if(_S1037)
            {
                if(_S969)
                {
                    SampleBSDF _S1130 = (fcptConnectHair((surface_11.hair), (_S961.material.albedo), (_S961.material.specular_tint), ((&ray_2)->unit_direction), (throughput_11)));
                    lobe_5 = _S1130;
                }
                else
                {
                    float3  _S1131 = (&ray_2)->unit_direction;
                    float _S1132 = sign_0(_S963);
                    float3  _S1133 = _S962.smooth_n * make_float3 (_S1132);
                    float _S1134 = dot_0(_S1133, throughput_11);
                    float _S1135 = _S961.material.roughness;
                    float _S1136 = _S1135 * _S1135;
                    AnisotropicFrame _S1137 = anisotropicFrame(_S961.material, _S1133);
                    float3  _S1138 = reflectedHalf(_S1131, throughput_11);
                    bool _S1139 = b_7 == 1U;
                    if(_S1139)
                    {
                        float3  _S1140 = refractedHalf(_S1131, throughput_11, _S962.smooth_n, _S964.x, _S964.y);
                        throughput_12 = _S1140;
                    }
                    else
                    {
                        throughput_12 = _S1138;
                    }
                    bool _S1141 = b_7 == 0U;
                    if(_S1141)
                    {
                        float3  _S1142 = sampledHalf(_S1131, _S962.smooth_n, _S961.material, surface_11.random_state, _S1137);
                        throughput_13 = _S1142;
                    }
                    else
                    {
                        throughput_13 = throughput_12;
                    }
                    float3  _S1143 = negate_0(_S1131);
                    float _S1144 = _S964.x;
                    float _S1145 = _S964.y;
                    BSDFLobes _S1146 = bsdfLobes(_S1131, _S1143, _S1133, throughput_13, _S961.material, _S1144, _S1145, _S1137);
                    BSDFLobes lobe_terms_2 = _S1146;
                    float _S1147 = translucentShare(_S961.material);
                    (&lobe_terms_2)->translucent_share = _S1147;
                    switch(b_7)
                    {
                    case 0U:
                        {
                            float _S1148 = diffusePDF(_S1134, 0.0f, (F32_abs((_S963))), _S1136, lobe_terms_2, _S1144, _S1145);
                            float3  _S1149 = diffuseBSDF(throughput_11, _S1133, _S1136, _S961.material, lobe_terms_2);
                            density_6 = _S1148;
                            chain_throughput_1 = _S1149;
                            break;
                        }
                    case 1U:
                        {
                            float _S1150 = refractPDF(_S1134, dot_0(throughput_11, throughput_13), (F32_abs((_S963))), _S1136, lobe_terms_2, _S1144, _S1145);
                            float3  _S1151 = refractBSDF(throughput_11, _S1133, _S1136, _S961.material, lobe_terms_2);
                            density_6 = _S1150;
                            chain_throughput_1 = _S1151;
                            break;
                        }
                    case 4U:
                        {
                            float _S1152 = sheenVelvetPDF(_S1134, 0.0f, (F32_abs((_S963))), _S1136, lobe_terms_2, _S1144, _S1145);
                            float3  _S1153 = sheenVelvetBSDF(throughput_11, _S1133, _S1136, _S961.material, lobe_terms_2);
                            density_6 = _S1152;
                            chain_throughput_1 = _S1153;
                            break;
                        }
                    default:
                        {
                            float _S1154 = reflectPDF(_S1134, 0.0f, (F32_abs((_S963))), _S1136, lobe_terms_2, _S1144, _S1145);
                            float3  _S1155 = reflectBSDF(throughput_11, _S1133, _S1136, _S961.material, lobe_terms_2);
                            density_6 = _S1154;
                            chain_throughput_1 = _S1155;
                            break;
                        }
                    }
                    bool _S1156 = density_6 > 0.0f;
                    if(_S1156)
                    {
                        SampleBSDF _S1157 = SampleBSDF_x24init_0(throughput_11, chain_throughput_1, surface_11.random_state, _S1139, b_7, density_6);
                        lobe_5 = _S1157;
                    }
                }
            }
            bool _S1158 = b_7 == 0U;
            if(_S1158)
            {
                _S1038 = true;
            }
            else
            {
                _S1038 = b_7 == 4U;
            }
            if(_S969)
            {
                _S1081 = false;
            }
            else
            {
                bool _S1159 = !_S1038;
                if(_S1159)
                {
                    bool _S1160 = (_S961.material.roughness) == 0.0f;
                    if(_S1160)
                    {
                        _S1081 = true;
                    }
                    else
                    {
                        bool _S1161 = b_7 == 1U;
                        if(_S1161)
                        {
                            _S1081 = (_S964.x) == (_S964.y);
                        }
                        else
                        {
                            _S1081 = false;
                        }
                    }
                }
                else
                {
                    _S1081 = false;
                }
            }
            bool _S1162 = !_S969;
            if(_S1162)
            {
                _S1082 = b_7 == 1U;
            }
            else
            {
                _S1082 = false;
            }
            if(_S1082)
            {
                straight_0 = (_S961.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1083 = _S1162;
            }
            else
            {
                _S1083 = false;
            }
            if(_S1083)
            {
                _S1084 = b_7 == 1U;
            }
            else
            {
                _S1084 = false;
            }
            if(_S1084)
            {
                _S1085 = (_S964.x) == (_S964.y);
            }
            else
            {
                _S1085 = false;
            }
            BSDFMaterial _S1163 = _S961.material;
            bool _S1164 = isTranslucent_0(&_S1163);
            if(_S1164)
            {
                _S1086 = _S1158;
            }
            else
            {
                _S1086 = false;
            }
            if(_S1086)
            {
                _S1087 = (dot_0(throughput_11, surface_11.geometry_n)) < 0.0f;
            }
            else
            {
                _S1087 = false;
            }
            if(nee_0)
            {
                _S1088 = !_S1081;
            }
            else
            {
                _S1088 = false;
            }
            if(_S1088)
            {
                _S1089 = !wrong_side_0;
            }
            else
            {
                _S1089 = false;
            }
            if(_S1089)
            {
                float _S1165 = (&lobe_5)->pdf;
                float3  _S1166 = (&ray_2)->origin;
                float3  _S1167 = _slang_select(_S974, _S786,_S962.smooth_n);
                float3  _S1168 = (&ray_2)->origin;
                FKSurface _S1169 = surface_11;
                float3  _S1170 = - _S962.smooth_n;
                float3  _S1171 = _slang_select(_S1087, _S1170,_S962.smooth_n);
                NEEVertex _S1172 = NEEVertex_x24init_0(false, _S1165, _S1166, _S1167, _S1168 + make_float3 (_S1169.geometry_offset) * _S1171);
                nee_vertex_0 = _S1172;
            }
            else
            {
                if(_S969)
                {
                    _S1090 = true;
                }
                else
                {
                    bool _S1173 = b_7 != 1U;
                    if(_S1173)
                    {
                        _S1090 = true;
                    }
                    else
                    {
                        _S1090 = (_S964.x) != (_S964.y);
                    }
                }
                if(_S1090)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1174 = withinInverseFootprint((&lobe_5)->pdf, _S1038, (&prev_0)->cos, (&hit_1)->distance, threshold_2);
            bool _S1175 = roughLobe((&lobe_5)->pdf, _S1038, _S961.material.roughness);
            if(_S999)
            {
                bool _S1176 = !_S1174;
                if(_S1176)
                {
                    return _S787;
                }
                bool _S1177 = _S792 != 1U;
                if(_S1177)
                {
                    _S1090 = _S792 != 2U;
                }
                else
                {
                    _S1090 = false;
                }
                if(_S1090)
                {
                    float _S1178 = (&lobe_5)->pdf;
                    float _S1179 = _slang_select(nee_0, _S1178,0.0f);
                    float _S1180 = escapeWeight_0(_S1179, _S1099);
                    if(_S1007)
                    {
                        passes_0 = _S798;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1181 = _slang_select(passes_0, _S1180,1.0f);
                    return Shift_x24init_0(throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_1->radiance * make_float3 (_S1181) / make_float3 (r_1->jac), density_4 * (&lobe_5)->pdf / r_1->jac);
                }
                float3  _S1182 = throughput_9 * make_float3 ((&lobe_5)->pdf);
                float _S1183 = density_4 * (&lobe_5)->pdf;
                throughput_12 = _S1182;
                density_6 = _S1183;
            }
            else
            {
                throughput_12 = throughput_9;
                density_6 = density_4;
            }
            uint _S1184 = (fcptLayers((hit_1)));
            bool _S1185 = b_7 == 1U;
            bool _S1186 = passesLayer_0(_S1184, _S1185, passes_0);
            if(viewed_1)
            {
                _S1090 = _S1186;
            }
            else
            {
                _S1090 = false;
            }
            if(_S1090)
            {
                return _S787;
            }
            if(replay_1)
            {
                _S1091 = b_4 <= _S802;
            }
            else
            {
                _S1091 = false;
            }
            if(_S1091)
            {
                _S1092 = _S960;
            }
            else
            {
                _S1092 = false;
            }
            if(_S1092)
            {
                _S1093 = _S1174;
            }
            else
            {
                _S1093 = false;
            }
            if(_S1093)
            {
                _S1094 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1094 = !_S1175;
                }
                else
                {
                    _S1094 = false;
                }
            }
            if(_S1094)
            {
                return _S787;
            }
            if(viewed_1)
            {
                float3  _S1187 = throughput_12 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1188 = (&lobe_5)->pdf;
                throughput_13 = _S1187;
                sky_pdf_2 = _S1188;
            }
            else
            {
                float3  _S1189 = throughput_12 * max_0((&lobe_5)->throughput, _S786);
                throughput_13 = _S1189;
                sky_pdf_2 = density_6;
            }
            bool _S1190 = !replay_1;
            if(_S1190)
            {
                _S1095 = !_S990;
            }
            else
            {
                _S1095 = false;
            }
            bool _S1191;
            if(_S1095)
            {
                _S1191 = _S960;
            }
            else
            {
                _S1191 = false;
            }
            bool _S1192;
            if(_S1191)
            {
                _S1192 = _S1174;
            }
            else
            {
                _S1192 = false;
            }
            if(_S1192)
            {
                chain_0 = here_0;
                uint _S1193 = insertBits_0((&chain_0)->path, b_7, 18U, 3U);
                uint _S1194 = _slang_select(nee_0, 1U,0U);
                uint _S1195 = insertBits_0(_S1193, _S1194, 21U, 1U);
                (&chain_0)->path = _S1195;
                float _S1196 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1196;
                (&chain_0)->dir = throughput_11;
                chain_throughput_1 = throughput_13;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1197 = surface_11;
            Vertex _S1198 = Vertex_x24init_0(_S1175, b_7, (&lobe_5)->pdf, (F32_abs((dot_0(surface_11.geometry_n, throughput_11)))), is_inside_6);
            prev_0 = _S1198;
            float _S1199 = (&lobe_5)->pdf;
            bool _S1200;
            if(_S1185)
            {
                _S1200 = (_S964.x) == (_S964.y);
            }
            else
            {
                _S1200 = false;
            }
            float sky_pdf_3 = _slang_select(_S1200, sky_pdf_0,_S1199);
            float _S1201 = _slang_select(_S969, 0.0f,sky_pdf_3);
            float _S1202 = widened_0(spread_1, (&lobe_5)->pdf, _S1081);
            bool _S1203;
            if(refracted_5)
            {
                _S1203 = !_S1087;
            }
            else
            {
                _S1203 = false;
            }
            bool is_inside_7;
            if(_S1203)
            {
                bool _S1204 = !is_inside_6;
                is_inside_7 = _S1204;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1205 = surface_11;
            bool _S1206 = boundsVolume_0(&_S1205);
            bool _S1207;
            if(_S1206)
            {
                _S1207 = !_S1186;
            }
            else
            {
                _S1207 = false;
            }
            if(_S1207)
            {
                FKSurface faced_2 = surface_11;
                float3  _S1208 = - _S1197.geometry_n;
                float3  _S1209 = _slang_select(turned_1, _S1208,_S1197.geometry_n);
                (&faced_2)->geometry_n = _S1209;
                FKMedium _S1210 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKSurface _S1211 = faced_2;
                FKMedium _S1212 = _S1210;
                MediumSides _S1213 = mediumSides_0(&_S1211, &_S1212, filling_2, (&ray_2)->unit_direction);
                bool _S1214 = leavesInFront_0((&faced_2)->geometry_n, throughput_11, _S1197.geometry_n);
                float3  _S1215 = _slang_select(_S1214, _S1213.front.scatter,_S1213.behind.scatter);
                scatter_in_0 = _S1215;
                float3  _S1216 = _slang_select(_S1214, _S1213.front.extinction,_S1213.behind.extinction);
                extinction_in_0 = _S1216;
                float _S1217 = _slang_select(_S1214, _S1213.front.g,_S1213.behind.g);
                g_in_0 = _S1217;
                uint _S1218 = _S1213.fillings.x;
                uint _S1219 = _S1213.fillings.y;
                uint _S1220 = _slang_select(_S1214, _S1219,_S1218);
                bool _S1221 = (fcptVaryingUsed());
                uint _S1222 = _slang_select(_S1221, _S1220,4294967295U);
                filling_2 = _S1222;
            }
            (&ray_2)->unit_direction = throughput_11;
            bool _S1223 = !_S1186;
            if(_S1223)
            {
                FKSurface _S1224 = surface_11;
                float _S1225 = _slang_select(straight_0, 0.0f,_S1224.geometry_offset);
                float3  _S1226 = - _S962.smooth_n;
                bool _S1227 = is_inside_7 != _S1087;
                float3  _S1228 = _slang_select(_S1227, _S1226,_S962.smooth_n);
                float3  _S1229 = (&ray_2)->origin + make_float3 (_S1225) * _S1228;
                (&ray_2)->origin = _S1229;
            }
            throughput_12 = throughput_13;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1186;
            viewed_1 = _S1085;
            sky_pdf_2 = _S1201;
            spread_4 = _S1202;
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
        bool _S1230 = !replay_1;
        float density_7;
        if(_S1230)
        {
            if(_S928)
            {
                float3  _S1231 = throughput_12 * emission_1;
                Reservoir candidate_7 = chain_0;
                uint _S1232 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1233 = _S1232 == 1U;
                if(_S1233)
                {
                    float3  _S1234 = safeDivide(_S1231, chain_throughput_0);
                    (&candidate_7)->radiance = _S1234;
                }
                Reservoir _S1235 = withEnd(candidate_7, 2U, b_4, _S1231);
                offer(sel_1, _S1235, _S1231 * make_float3 (scale_1) / make_float3 (density_6));
            }
            if(_S928)
            {
                refracted_5 = true;
            }
            else
            {
                refracted_5 = scatter_2;
            }
            if(refracted_5)
            {
                float _S1236 = survivalProbability(throughput_12, density_6);
                density_7 = _S1236;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1237 = stream(_S814, b_4 + 128U);
            Random _S1238 = pcg(_S1237);
            bool _S1239 = density_7 < (_S1238.value);
            if(_S1239)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1240 = (fcptMaxBounces());
                wrong_side_0 = b_4 >= _S1240;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1241 = density_6 * density_7;
            density_7 = _S1241;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1242 = layer_0 ^ 1U;
        uint _S1243 = _slang_select(passes_0, _S1242,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_1)->distance = 0.0f;
            b_7 = b_4;
            viewed_0 = viewed_1;
            throughput_5 = throughput_12;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_1 = spread_4;
            uint _S1244 = b_7 + 1U;
            b_4 = _S1244;
            layer_0 = _S1243;
            continue;
        }
        FKRay _S1245 = ray_2;
        float _S1246 = distance_5(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_5 = _S1000;
        }
        else
        {
            refracted_5 = false;
        }
        if(refracted_5)
        {
            wrong_side_0 = _S791 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1247 = _slang_select(wrong_side_0, _S1246,4.294967296e+09f);
        bool _S1248 = !_S969;
        if(straight_0)
        {
            _S1037 = true;
        }
        else
        {
            _S1037 = _S969;
        }
        FKHit _S1249;
        if(_S1037)
        {
            _S1249 = hit_1;
        }
        else
        {
            _S1249 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
        }
        FKHit _S1250 = (fcptTraverseInstanceBVH((_S1245), (_S936), (_S1247), (_S1248), (_S1249), (viewed_1)));
        hit_1 = _S1250;
        if(replay_1)
        {
            _S1038 = _S1000;
        }
        else
        {
            _S1038 = false;
        }
        if(_S1038)
        {
            _S1081 = _S791 == 1U;
        }
        else
        {
            _S1081 = false;
        }
        if(_S1081)
        {
            _S1082 = ((&hit_1)->instance_index) == (_S803.instance_index);
        }
        else
        {
            _S1082 = false;
        }
        if(_S1082)
        {
            _S1083 = ((&hit_1)->triangle_index) == (_S803.triangle_index);
        }
        else
        {
            _S1083 = false;
        }
        if(_S1083)
        {
            (&hit_1)->uv = _S803.uv;
            float _S1251 = distance_5(reconnection_0, (&ray_2)->origin);
            (&hit_1)->distance = _S1251;
        }
        if(replay_1)
        {
            _S1084 = _S1000;
        }
        else
        {
            _S1084 = false;
        }
        if(_S1084)
        {
            _S1085 = _S791 == 3U;
        }
        else
        {
            _S1085 = false;
        }
        if(_S1085)
        {
            _S1086 = ((&hit_1)->instance_index) != 4294967295U;
        }
        else
        {
            _S1086 = false;
        }
        if(_S1086)
        {
            return _S787;
        }
        Reservoir _S1252 = chain_0;
        uint _S1253 = filling_2;
        for(;;)
        {
            bool _S1254 = (fcptVaryingUsed());
            if(_S1254)
            {
                _S1087 = _S1253 != 4294967295U;
            }
            else
            {
                _S1087 = false;
            }
            float _S1255;
            if(_S1087)
            {
                float _S1256 = (fcptMajorant((_S1253)));
                _S1255 = _S1256;
            }
            else
            {
                _S1255 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1088 = _S1000;
            }
            else
            {
                _S1088 = false;
            }
            if(_S1088)
            {
                _S1089 = _S791 == 1U;
            }
            else
            {
                _S1089 = false;
            }
            if(_S1089)
            {
                _S1090 = _S1255 > 0.0f;
            }
            else
            {
                _S1090 = false;
            }
            if(_S1090)
            {
                ended_0 = _S787;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_3 = width_2;
                density_3 = density_7;
                throughput_13 = throughput_12;
                b_7 = b_4;
                _S1091 = true;
                break;
            }
            bool _S1257 = (&prev_0)->rough;
            if(_S1257)
            {
                _S1091 = !(_S1255 > 0.0f);
            }
            else
            {
                _S1091 = false;
            }
            (&prev_0)->rough = _S1091;
            uint _S1258 = b_4 + 320U;
            bool _S1259 = b_4 == 4294967295U;
            uint _S1260 = _slang_select(_S1259, 384U,_S1258);
            uint _S1261 = stream(_S814, _S1260);
            uint tracking_1 = _S1261;
            weight_1 = throughput_6;
            glowed_0 = _S786;
            b_7 = b_4;
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
                    _S785 = int(2);
                    break;
                }
                uint _S1262 = b_7 + 320U;
                bool _S1263 = b_7 == 4294967295U;
                uint _S1264 = _slang_select(_S1263, 384U,_S1262);
                uint _S1265 = stream(_S814, _S1264);
                Random _S1266 = pcg(_S1265);
                float _S1267 = freeFlight_0(_S1266.value, _S1255);
                if(_S1087)
                {
                    float3  _S1268 = (&ray_2)->origin;
                    float3  _S1269 = (&ray_2)->unit_direction;
                    float _S1270 = (&hit_1)->distance;
                    uint _S1271 = _slang_select(_S1263, 0U,b_7);
                    uint _S1272 = (&prev_0)->lobe;
                    uint _S1273 = _slang_select(_S1263, 3U,_S1272);
                    float _S1274 = (fcptTrackMedium((_S1253), (_S1268), (_S1269), (_S1270), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1271), (_S1273), (_S1263)));
                    spread_3 = _S1274;
                }
                else
                {
                    spread_3 = _S1267;
                }
                bool _S1275 = !(spread_3 < ((&hit_1)->distance));
                if(_S1275)
                {
                    _S785 = int(2);
                    break;
                }
                if(_S1087)
                {
                    _S1092 = _S1230;
                }
                else
                {
                    _S1092 = false;
                }
                if(_S1092)
                {
                    float3  _S1276 = throughput_13 * glowed_0 / make_float3 (density_3);
                    float3  _S1277 = sel_1->glow + _S1276;
                    sel_1->glow = _S1277;
                }
                else
                {
                }
                glowed_0 = _S786;
                uint b_8 = b_7 + 1U;
                float3  _S1278 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1278;
                float3  _S1279 = flightWeight_0(scatter_in_0, extinction_in_0, _S1255, spread_3, true);
                float3  _S1280 = weight_1;
                float3  _S1281 = _slang_select(_S1087, _S1280,_S1279);
                float3  throughput_14 = throughput_13 * _S1281;
                uint _S1282 = stream(_S814, b_8 + 320U);
                tracking_1 = _S1282;
                weight_1 = throughput_6;
                float width_6 = width_3 + spread_2 * spread_3;
                float _S1283 = spread_2 + 3.14159274101257324f;
                bool _S1284 = scatterSampled_0(replay_1, b_8, _S802, _S1087);
                TreeSample light_4;
                if(_S1284)
                {
                    float3  _S1285 = (&ray_2)->origin;
                    float3  _S1286 = (&ray_2)->unit_direction;
                    float3  _S1287 = (&ray_2)->unit_direction;
                    uint _S1288 = stream(_S814, b_8 + 64U);
                    float3  _S1289 = extinction_in_0;
                    float3  _S1290 = extinction_in_0;
                    uint2  _S1291 = make_uint2 (_S1253);
                    float3  _S1292 = (&ray_2)->unit_direction;
                    uint _S1293 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                    FKHit _S1294 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                    FKHit _S1295 = _S1294;
                    ShadowContext _S1296 = ShadowContext_x24init_0(_S1289, _S1290, _S1291, _S1292, b_8, _S1293, false, spread_3, width_6, &_S1295, false);
                    ShadowContext _S1297 = _S1296;
                    TreeSample _S1298 = sampleLightTree_0(_S1285, _S1286, _S1287, 0.0f, true, _S1288, &_S1297);
                    light_4 = _S1298;
                }
                else
                {
                    light_4 = _S1014;
                }
                float _S1299 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1300 = (fcptMaxBounces());
                bool _S1301 = b_8 < _S1300;
                if(_S1301)
                {
                    _S1093 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1093 = false;
                }
                float _S1302 = _slang_select(_S1093, _S1299,0.0f);
                float3  _S1303 = throughput_14 * light_4.radiance;
                float _S1304 = powerHeuristic(light_4.density, _S1302);
                float3  _S1305 = _S1303 * make_float3 (_S1299 * _S1304);
                float3  _S1306 = _slang_select(_S1284, _S1305,_S786);
                if(replay_1)
                {
                    _S1094 = b_8 == _S802;
                }
                else
                {
                    _S1094 = false;
                }
                if(_S1094)
                {
                    bool _S1307 = _S791 == 2U;
                    if(_S1307)
                    {
                        float _S1308 = rgb_to_greyscale(_S1306);
                        _S1095 = _S1308 > 0.0f;
                    }
                    else
                    {
                        _S1095 = false;
                    }
                    if(_S1095)
                    {
                        Shift _S1309 = Shift_x24init_0(_S1306, 1.0f);
                        _S785 = int(1);
                        ended_0 = _S1309;
                        spread_3 = _S1283;
                        width_4 = width_6;
                        throughput_11 = throughput_14;
                        b_5 = b_8;
                        break;
                    }
                    _S785 = int(1);
                    ended_0 = _S787;
                    spread_3 = _S1283;
                    width_4 = width_6;
                    throughput_11 = throughput_14;
                    b_5 = b_8;
                    break;
                }
                if(_S1230)
                {
                    Reservoir candidate_8 = _S1252;
                    uint _S1310 = extractBits_0(_S1252.path, 10U, 2U);
                    bool _S1311 = _S1310 == 1U;
                    if(_S1311)
                    {
                        float3  _S1312 = safeDivide(_S1306, chain_throughput_0);
                        (&candidate_8)->radiance = _S1312;
                    }
                    else
                    {
                        uint _S1313 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                        uint _S1314 = insertBits_0(_S1313, 2U, 10U, 2U);
                        (&candidate_8)->path = _S1314;
                    }
                    Reservoir _S1315 = withEnd(candidate_8, 0U, b_8, _S1306);
                    offer(sel_1, _S1315, _S1306 * make_float3 (scale_1) / make_float3 (density_3));
                    float _S1316 = survivalProbability(throughput_14, density_3);
                    uint _S1317 = stream(_S814, b_8 + 128U);
                    Random _S1318 = pcg(_S1317);
                    bool _S1319 = _S1316 < (_S1318.value);
                    if(_S1319)
                    {
                        _S1095 = true;
                    }
                    else
                    {
                        uint _S1320 = (fcptMaxBounces());
                        _S1095 = b_8 >= _S1320;
                    }
                    if(_S1095)
                    {
                        _S785 = int(1);
                        ended_0 = _S787;
                        spread_3 = _S1283;
                        width_4 = width_6;
                        throughput_11 = throughput_14;
                        b_5 = b_8;
                        break;
                    }
                    float _S1321 = density_3 * _S1316;
                    density_3 = _S1321;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1322 = stream(_S814, b_8);
                float3  _S1323 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1322, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1323;
                NEEVertex _S1324 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S786, (&ray_2)->origin);
                nee_vertex_0 = _S1324;
                Vertex _S1325 = scatteredVertex_0(is_inside_5);
                prev_0 = _S1325;
                float _S1326 = (&prev_0)->pdf;
                FKRay _S1327 = ray_2;
                FKHit _S1328 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1329 = (fcptTraverseInstanceBVH((_S1327), (true), (4.294967296e+09f), (false), (_S1328), (false)));
                hit_1 = _S1329;
                b_7 = b_8;
                throughput_13 = throughput_14;
                spread_2 = _S1283;
                width_3 = width_6;
                sky_pdf_1 = _S1326;
            }
            if(_S785 != int(2))
            {
                spread_2 = spread_3;
                width_3 = width_4;
                throughput_13 = throughput_11;
                b_7 = b_5;
                _S1091 = true;
                break;
            }
            ended_0 = _S787;
            _S1091 = false;
            break;
        }
        if(_S1091)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1092 = b_7 == b_4;
        }
        else
        {
            _S1092 = false;
        }
        bool _S1330 = ((&hit_1)->instance_index) == 4294967295U;
        if(_S1330)
        {
            bool _S1331 = !(&nee_vertex_0)->none;
            float _S1332 = _slang_select(_S1331, sky_pdf_1,0.0f);
            float _S1333 = escapeWeight_0(_S1332, (&ray_2)->unit_direction);
            float3  _S1334 = environment_0((&ray_2)->unit_direction, b_7, (&prev_0)->lobe);
            float3  _S1335 = throughput_13 * _S1334;
            if(replay_1)
            {
                bool _S1336 = b_7 == _S802;
                if(_S1336)
                {
                    passes_0 = _S791 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1335 * make_float3 (_S1333) / make_float3 (r_1->jac), density_3 / r_1->jac);
                }
                if(_S801)
                {
                    passes_0 = _S798;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_7 == _S789;
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
                    return Shift_x24init_0(_S1335 * make_float3 (_S1333), 1.0f);
                }
                return _S787;
            }
            Reservoir candidate_9 = chain_0;
            uint _S1337 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1338 = _S1337 == 1U;
            if(_S1338)
            {
                uint _S1339 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1340 = _S1339 == b_7;
                float _S1341 = _slang_select(_S1340, 1.0f,_S1333);
                float3  _S1342 = safeDivide(_S1335 * make_float3 (_S1341), chain_throughput_0);
                (&candidate_9)->radiance = _S1342;
            }
            else
            {
                bool _S1343 = (&prev_0)->rough;
                if(_S1343)
                {
                    uint _S1344 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                    uint _S1345 = insertBits_0(_S1344, 3U, 10U, 2U);
                    uint _S1346 = insertBits_0(_S1345, (&prev_0)->lobe, 15U, 3U);
                    bool _S1347 = (&prev_0)->inside;
                    uint _S1348 = _slang_select(_S1347, 1U,0U);
                    uint _S1349 = insertBits_0(_S1346, _S1348, 22U, 1U);
                    (&candidate_9)->path = _S1349;
                    (&candidate_9)->jac = (&prev_0)->pdf;
                    (&candidate_9)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1350 = _S1335 * make_float3 (_S1333);
            Reservoir _S1351 = withEnd(candidate_9, 3U, b_7, _S1350);
            offer(sel_1, _S1351, _S1350 * make_float3 (scale_1) / make_float3 (density_3));
            break;
        }
        float3  _S1352 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1352;
        bool _S1353 = (fcptVaryingUsed());
        if(_S1353)
        {
            _S1093 = filling_2 != 4294967295U;
        }
        else
        {
            _S1093 = false;
        }
        if(_S1093)
        {
            if(_S1230)
            {
                float3  _S1354 = throughput_13 * glowed_0 / make_float3 (density_3);
                float3  _S1355 = sel_1->glow + _S1354;
                sel_1->glow = _S1355;
            }
            float3  _S1356 = throughput_13 * weight_1;
            throughput_11 = _S1356;
        }
        else
        {
            float3  _S1357 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
            float3  _S1358 = throughput_13 * _S1357;
            throughput_11 = _S1358;
        }
        float _S1359 = width_3 + spread_2 * (&hit_1)->distance;
        viewed_0 = _S1092;
        width_2 = _S1359;
        throughput_5 = throughput_11;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1244 = b_7 + 1U;
        b_4 = _S1244;
        layer_0 = _S1243;
    }
    return _S787;
}

static __device__ Shift shift_0(Domain * dom_1, Reservoir * r_2)
{
    Selection _S1360 = (Selection{});
    Selection sel_2 = _S1360;
    bool _S1361 = (r_2->w) <= 0.0f;
    if(_S1361)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1362 = walk_0(dom_1, r_2, true, 0.0f, &sel_2);
    return _S1362;
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
    Random _S1363 = pcg(state_4);
    Random _S1364 = pcg(_S1363.state);
    float _S1365 = 6.28318548202514648f * _S1363.value;
    float _S1366 = (F32_sqrt((-2.0f * clamp_0((F32_log((_S1364.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1364.state, _S1366 * (F32_cos((_S1365))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S1367;
    (&_S1367)->state = state_5;
    (&_S1367)->value = value_2;
    return _S1367;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S1368 = normal_distribution(state_6);
    Random _S1369 = normal_distribution(_S1368.state);
    Random _S1370 = normal_distribution(_S1369.state);
    float3  _S1371 = make_float3 (_S1368.value, _S1369.value, _S1370.value);
    float3  _S1372 = ((((_S1371)) * make_float3(rnorm3df(((_S1371)).x, ((_S1371)).y, ((_S1371)).z))));
    return RandomSphere_x24init_0(_S1370.state, _S1372);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_16)
{
    float3  _S1373 = p1_0 - p0_0;
    float3  _S1374 = p2_0 - p0_0;
    float2  _S1375 = uv1_0 - uv0_0;
    float2  _S1376 = uv2_0 - uv0_0;
    float _S1377 = _S1375.x;
    float _S1378 = _S1376.y;
    float _S1379 = _S1375.y;
    float _S1380 = _S1376.x;
    float _S1381 = _S1377 * _S1378 - _S1379 * _S1380;
    float _S1382 = 1.0f / _S1381;
    float3  t_1 = (_S1373 * make_float3 (_S1378) - _S1374 * make_float3 (_S1379)) * make_float3 (_S1382);
    float3  _S1383 = (_S1374 * make_float3 (_S1377) - _S1373 * make_float3 (_S1380)) * make_float3 (_S1382);
    float3  _S1384 = t_1 - n_16 * make_float3 (dot_0(n_16, t_1));
    float3  t_2 = ((((_S1384)) * make_float3(rnorm3df(((_S1384)).x, ((_S1384)).y, ((_S1384)).z))));
    bool _S1385 = (dot_0(cross_0(n_16, t_2), _S1383)) > 0.0f;
    float3  t_3;
    if(_S1385)
    {
        float3  _S1386 = negate_0(t_2);
        t_3 = _S1386;
    }
    else
    {
        t_3 = t_2;
    }
    float3  _S1387 = cross_0(n_16, t_3);
    return makeMatrix<float, 3, 3> (t_3, _S1387, n_16);
}

__device__ float3  tangentToWorldNormalMap(float3  v_4, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_4, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1388 = t1_0 - t0_0;
    float3  _S1389 = t2_2 - t0_0;
    float3  _S1390 = t2_2 - t1_0;
    float _S1391 = (F32_min((length_0(_S1388)), ((F32_min((length_0(_S1389)), (length_0(_S1390)))))));
    float3  _S1392 = make_float3 (distance_5(position_0, t0_0), distance_5(position_0, t1_0), distance_5(position_0, t2_2));
    float3  _S1393 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1394 = dot_0(geometry_n_5, _S1393);
    float3  _S1395 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1396 = dot_0(geometry_n_5, _S1395);
    float3  _S1397 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1398 = acos_0(abs_0(make_float3 (_S1394, _S1396, dot_0(geometry_n_5, _S1397))));
    float3  _S1399 = clamp_1(tan_0(_S1398), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_0(dot_0(_S1392 * _S1399, uvw_0), 0.0f, _S1391 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_16, float3  n_17, BSDFMaterial material_24)
{
    float3  _S1400 = negate_0(dir_16);
    float _S1401 = sign_0(dot_0(n_17, _S1400));
    float3  _S1402 = n_17 * make_float3 (_S1401);
    AnisotropicFrame _S1403 = anisotropicFrame(material_24, _S1402);
    bool _S1404 = (_S1403.alphas.x) > 0.0f;
    if(_S1404)
    {
        float _S1405 = material_24.transmission * (1.0f - material_24.metallic);
        float3  _S1406 = negate_0(_S1402);
        float3  _S1407 = anisotropicLocal(dir_16, _S1403.tangent, _S1406);
        float _S1408 = anisotropicG1(_S1407, _S1403.alphas);
        return make_float3 (_S1405 * _S1408) * material_24.albedo;
    }
    float _S1409 = material_24.transmission * (1.0f - material_24.metallic);
    float _S1410 = material_24.roughness;
    float _S1411 = smithG1(_S1410 * _S1410, (F32_abs((dot_0(n_17, dir_16)))));
    return make_float3 (_S1409 * _S1411) * material_24.albedo;
}

__device__ float hairRow(float3  in_dir_14, float3  t_4, float3  out_dir_5, uint p_5, float w_2, float alpha_17, uint nt_0)
{
    uint _S1412 = p_5 % 4U;
    float _S1413 = w_2 * HAIR_WIDTHS_0[_S1412];
    float _S1414 = (F32_asin((clamp_0(dot_0(out_dir_5, t_4), -1.0f, 1.0f)))) - (F32_asin((clamp_0(dot_0(in_dir_14, t_4), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1412] * alpha_17;
    return ((F32_asinh((_S1414 / _S1413))) / (F32_asinh((3.14159274101257324f / _S1413))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_15, float3  t_5, float3  out_dir_6, uint np_0)
{
    float3  _S1415 = worldToTangent(out_dir_6, t_5);
    float3  _S1416 = worldToTangent(in_dir_15, t_5);
    return (F32_frac((((F32_atan2((_S1415.z), (_S1415.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1416.z), (1.17549435082228751e-38f - _S1416.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_16, float3  t_6, uint p_6, float row_0, float column_0, float w_3, float alpha_18, uint nt_1, uint np_1)
{
    float3  _S1417 = worldToTangent(in_dir_16, t_6);
    uint _S1418 = p_6 % 4U;
    float _S1419 = w_3 * HAIR_WIDTHS_0[_S1418];
    float _S1420 = (F32_asin((clamp_0(dot_0(in_dir_16, t_6), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1418] * alpha_18 + _S1419 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1419))))));
    float _S1421 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1417.z), (1.17549435082228751e-38f - _S1417.x)));
    float _S1422 = (F32_cos((_S1420)));
    float3  _S1423 = tangentToWorld(make_float3 (_S1422 * (F32_cos((_S1421))), (F32_sin((_S1420))), _S1422 * (F32_sin((_S1421)))), t_6);
    return _S1423;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_18, BSDFMaterial material_25, float coverage_1)
{
    float3  _S1424;
    if((material_25.ior) == 1.0f)
    {
        float3  _S1425 = straightThrough(toward_1, n_18, material_25);
        _S1424 = _S1425;
    }
    else
    {
        _S1424 = make_float3 (0.0f);
    }
    return _S1424 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_10 = r_3;
    float3  _S1426 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_10)->f = _S1426;
    float _S1427 = r_3.jac * shifted_0.jac;
    (&candidate_10)->jac = _S1427;
    offer(sel_3, candidate_10, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S1428 = rgb_to_greyscale((&r_4)->f);
    float _S1429 = sel_4.w_sum / _S1428;
    bool _S1430 = _S1428 > 0.0f;
    float _S1431 = _slang_select(_S1430, _S1429,0.0f);
    (&r_4)->w = _S1431;
    (&r_4)->c = c_1;
    return r_4;
}

static __device__ float interpolate_0(float a_6, float b_9, float t_7)
{
    return a_6 + (b_9 - a_6) * t_7;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S1432 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S1432;
}

__device__ float2  temporalWeights(float c_2, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S1433 = c_2 * p_c_0;
    float _S1434 = c_t_0 * p_t_0;
    return make_float2 (_S1433 / (_S1433 + c_t_0 * g_previous_0), _S1434 / (_S1434 + c_2 * g_current_0));
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
    Domain _S1435 = dom_2;
    Reservoir _S1436 = r_5;
    Shift _S1437 = walk_0(&_S1435, &_S1436, replay_2, scale_2, sel_5);
    return _S1437;
}

__device__ Shift shift_hook(Domain dom_3, Reservoir r_6)
{
    Domain _S1438 = dom_3;
    Reservoir _S1439 = r_6;
    Shift _S1440 = shift_0(&_S1438, &_S1439);
    return _S1440;
}

#undef Matrix
