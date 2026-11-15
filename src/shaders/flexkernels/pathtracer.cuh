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

__device__ __forceinline__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_8, float eta_i_7, float eta_o_7, bool refracted_2, uint random_state_3, FixedArray<float3 , 4>  * throughputs_0, FixedArray<float, 4>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S358 = negate_0(in_dir_4);
    float _S359 = dot_0(n_7, _S358);
    float _S360 = sign_0(_S359);
    float3  _S361 = n_7 * make_float3 (_S360);
    AnisotropicFrame _S362 = anisotropicFrame(material_8, _S361);
    float _S363 = dot_0(_S361, out_dir_2);
    float _S364 = material_8.roughness;
    float _S365 = _S364 * _S364;
    float _S366 = rgb_to_greyscale(material_8.translucent);
    bool _S367 = _S366 > 0.0f;
    bool _S368 = (dot_0(n_7, out_dir_2) * _S359) < 0.0f;
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
        float3  _S369 = make_float3 (0.0f);
        (*throughputs_0)[i_2] = _S369;
        (*pdfs_0)[i_2] = 0.0f;
        uint i_3 = i_2 + 1U;
        i_2 = i_3;
    }
    float3  _S370 = make_float3 (0.0f);
    BSDFLobes _S371 = BSDFLobes_x24init_0(0.0f, 0.0f, _S370, _S370, 0.0f, 0.0f, _S370, _S370, 0.0f, 0.0f, 0.0f, 0.0f, _S370, 0.0f, _S370, _S370, make_float2 (0.0f), 0.0f);
    BSDFLobes lobe_terms_0 = _S371;
    uint half_of_0 = 4294967295U;
    float3  ggx_n_2 = _S370;
    i_2 = 0U;
    for(;;)
    {
        if(i_2 < 4U)
        {
        }
        else
        {
            break;
        }
        uint _S372;
        if(i_2 == 3U)
        {
            _S372 = 4U;
        }
        else
        {
            _S372 = i_2;
        }
        bool _S373 = _S372 == 0U;
        bool _S374;
        if(_S373)
        {
            _S374 = _S367;
        }
        else
        {
            _S374 = false;
        }
        bool _S375;
        if(_S374)
        {
            _S375 = _S368;
        }
        else
        {
            _S375 = _S372 == 1U;
        }
        bool _S376 = _S375 != refracted_2;
        if(_S376)
        {
            ggx_n_1 = ggx_n_2;
            uint i_4 = i_2 + 1U;
            ggx_n_2 = ggx_n_1;
            i_2 = i_4;
            continue;
        }
        uint _S377;
        if(_S372 == 4U)
        {
            _S377 = 2U;
        }
        else
        {
            _S377 = _S372;
        }
        bool _S378 = _S377 != half_of_0;
        uint half_of_1;
        if(_S378)
        {
            bool _S379 = _S377 == 0U;
            if(_S379)
            {
                float3  _S380 = sampledHalf(in_dir_4, n_7, material_8, random_state_3, _S362);
                ggx_n_1 = _S380;
            }
            else
            {
                bool _S381 = _S377 == 1U;
                if(_S381)
                {
                    float3  _S382 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_7, eta_o_7);
                    ggx_n_1 = _S382;
                }
                else
                {
                    float3  _S383 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S383;
                }
            }
            float3  _S384 = negate_0(in_dir_4);
            BSDFLobes _S385 = bsdfLobes(in_dir_4, _S384, _S361, ggx_n_1, material_8, eta_i_7, eta_o_7, _S362);
            lobe_terms_0 = _S385;
            float _S386 = translucentShare(material_8);
            (&lobe_terms_0)->translucent_share = _S386;
            half_of_1 = _S377;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S372)
        {
        case 0U:
            {
                float _S387 = diffusePDF(_S363, 0.0f, (F32_abs((_S359))), _S365, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(0)] = _S387;
                float3  _S388 = diffuseBSDF(out_dir_2, _S361, _S365, material_8, lobe_terms_0);
                (*throughputs_0)[int(0)] = _S388;
                break;
            }
        case 1U:
            {
                float _S389 = refractPDF(_S363, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S359))), _S365, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(1)] = _S389;
                float3  _S390 = refractBSDF(out_dir_2, _S361, _S365, material_8, lobe_terms_0);
                (*throughputs_0)[int(1)] = _S390;
                break;
            }
        case 4U:
            {
                float _S391 = sheenVelvetPDF(_S363, 0.0f, (F32_abs((_S359))), _S365, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(3)] = _S391;
                float3  _S392 = sheenVelvetBSDF(out_dir_2, _S361, _S365, material_8, lobe_terms_0);
                (*throughputs_0)[int(3)] = _S392;
                break;
            }
        default:
            {
                float _S393 = reflectPDF(_S363, 0.0f, (F32_abs((_S359))), _S365, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(2)] = _S393;
                float3  _S394 = reflectBSDF(out_dir_2, _S361, _S365, material_8, lobe_terms_0);
                (*throughputs_0)[int(2)] = _S394;
                break;
            }
        }
        half_of_0 = half_of_1;
        uint i_4 = i_2 + 1U;
        ggx_n_2 = ggx_n_1;
        i_2 = i_4;
    }
    i_2 = 0U;
    ggx_n_1 = _S370;
    for(;;)
    {
        if(i_2 < 4U)
        {
        }
        else
        {
            break;
        }
        bool _S395 = ((*pdfs_0)[i_2]) > 0.0f;
        if(_S395)
        {
            float3  f_0 = ggx_n_1 + (*throughputs_0)[i_2] * make_float3 ((*pdfs_0)[i_2]);
            ggx_n_1 = f_0;
        }
        uint i_5 = i_2 + 1U;
        i_2 = i_5;
    }
    return ggx_n_1;
}

static __device__ __forceinline__ float3  skyLobes_0(float3  in_dir_5, float3  dir_3, FKSurface * surface_1, float2  eta_1, bool is_inside_2, float pdf_0, uint random_state_4, FixedArray<float3 , 4>  * terms_0, FixedArray<float, 4>  * pdfs_1)
{
    bool _S396 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    float3  _S397 = BSDF(in_dir_5, dir_3, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S396, random_state_4, terms_0, pdfs_1);
    float3  _S398 = make_float3 (0.0f);
    uint i_6 = 0U;
    float3  f_1 = _S398;
    for(;;)
    {
        if(i_6 < 4U)
        {
        }
        else
        {
            break;
        }
        bool _S399 = ((*pdfs_1)[i_6]) > 0.0f;
        if(_S399)
        {
            float3  _S400 = (*terms_0)[i_6] * make_float3 ((*pdfs_1)[i_6]) / make_float3 ((*pdfs_1)[i_6] + pdf_0);
            (*terms_0)[i_6] = _S400;
            float3  f_2 = f_1 + (*terms_0)[i_6];
            f_1 = f_2;
        }
        uint i_7 = i_6 + 1U;
        i_6 = i_7;
    }
    return f_1;
}

__device__ float3  skyBSDF(float3  in_dir_6, float3  dir_4, FKSurface surface_2, float2  eta_2, bool is_inside_3, float pdf_1, uint random_state_5)
{
    FKSurface _S401 = surface_2;
    FixedArray<float3 , 4>  terms_1;
    FixedArray<float, 4>  pdfs_2;
    float3  _S402 = skyLobes_0(in_dir_6, dir_4, &_S401, eta_2, is_inside_3, pdf_1, random_state_5, &terms_1, &pdfs_2);
    return _S402;
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

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_6)
{
    SkySample _S403;
    (&_S403)->dir = dir_5;
    (&_S403)->radiance = radiance_0;
    (&_S403)->color = color_0;
    (&_S403)->random_state = random_state_6;
    return _S403;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0)
{
    uint2  _S404 = (fcptEnvironmentCdfSize());
    uint2  _S405 = make_uint2 (1U, 0U);
    uint2  _S406 = _S404 - _S405;
    Random _S407 = pcg(init_random_state_0);
    Random _S408 = pcg(_S407.state);
    Random _S409 = pcg(_S408.state);
    Random _S410 = pcg(_S409.state);
    uint _S411 = _S406.x;
    uint _S412 = searchCDF_0(make_uint2 (_S411, 0U), make_uint2 (0U, 1U), _S406.y, _S407.value);
    uint _S413 = searchCDF_0(make_uint2 (0U, _S412), _S405, _S411, _S408.value);
    float2  _S414 = make_float2 ((float)_S406.x, (float)_S406.y);
    float2  _S415 = (make_float2 (float(_S413), float(_S412)) + make_float2 (_S409.value, _S410.value)) / _S414 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S416 = _S415.y;
    float _S417 = (F32_sin((_S416)));
    float _S418 = _S415.x;
    float3  _S419 = make_float3 (_S417 * (F32_cos((_S418))), (F32_cos((_S416))), _S417 * (F32_sin((_S418))));
    float _S420 = environmentPdf_0(_S419);
    float3  _S421 = skyBSDF(ray_0->unit_direction, _S419, *surface_3, eta_3, is_inside_4, _S420, lobe_state_0);
    bool _S422 = !(_S420 > 0.0f);
    bool _S423;
    if(_S422)
    {
        _S423 = true;
    }
    else
    {
        _S423 = all_0(_S421 == make_float3 (0.0f));
    }
    if(_S423)
    {
        float3  _S424 = make_float3 (0.0f);
        return SkySample_x24init_0(_S419, _S424, _S424, _S410.state);
    }
    float3  _S425 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S419);
    return SkySample_x24init_0(_S419, _S425, _S421 * _S425, _S410.state);
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
    SampleBSDF _S426 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S427 = _S426.throughput * make_float3 (_S426.pdf);
    float _S428 = light_1->density;
    float _S429 = 1.0f + _S426.pdf * _S426.pdf / (light_1->density * light_1->density);
    bool _S430;
    if(competing_0)
    {
        _S430 = _S428 > 0.0f;
    }
    else
    {
        _S430 = false;
    }
    float _S431 = _slang_select(_S430, _S429,1.0f);
    return _S427 / make_float3 (_S431) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_7)
{
    TreeSample _S432;
    (&_S432)->dir = dir_6;
    (&_S432)->radiance = radiance_1;
    (&_S432)->density = density_0;
    (&_S432)->random_state = random_state_7;
    return _S432;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_3, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S433 = importance(first_1, p_3, normal_3);
    float _S434 = importance(second_1, p_3, normal_3);
    float2  _S435 = make_float2 (_S433, _S434);
    bool _S436 = _S433 == 0.0f;
    bool _S437;
    if(_S436)
    {
        _S437 = _S434 == 0.0f;
    }
    else
    {
        _S437 = false;
    }
    if(_S437)
    {
        return 2U;
    }
    float _S438 = _S433 + _S434;
    bool _S439 = _S434 > 0.0f;
    if(_S439)
    {
        _S437 = (*pick_0 * _S438) >= _S433;
    }
    else
    {
        _S437 = false;
    }
    uint _S440 = uint(_S437);
    float _S441 = (F32_min(((*pick_0 * _S438 - float(_S440) * _S433) / _slang_vector_get_element(_S435, _S440)), (0.99999994039535522f)));
    *pick_0 = _S441;
    float _S442 = *probability_3 * (_slang_vector_get_element(_S435, _S440) / _S438);
    *probability_3 = _S442;
    return _S440;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_4, float u1_0, float u2_0)
{
    float3  _S443 = center_1 - p_4;
    float _S444 = radius_1 * radius_1 / dot_0(_S443, _S443);
    float _S445 = u1_0 * _S444 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S444), (0.0f)))))));
    float _S446 = 2.0f * u1_0;
    bool _S447 = _S444 >= 1.0f;
    float _S448 = _slang_select(_S447, _S446,_S445);
    float _S449 = (F32_sqrt(((F32_max((_S448 * (2.0f - _S448)), (0.0f))))));
    float _S450 = 6.28318548202514648f * u2_0;
    float3  _S451 = make_float3 (_S449 * (F32_cos((_S450))), 1.0f - _S448, _S449 * (F32_sin((_S450))));
    float3  _S452 = ((((_S443)) * make_float3(rnorm3df(((_S443)).x, ((_S443)).y, ((_S443)).z))));
    float3  _S453 = tangentToWorld(_S451, _S452);
    return _S453;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S454 = center_2 - ray_1->origin;
    float _S455 = dot_0(_S454, ray_1->unit_direction);
    float _S456 = dot_0(_S454, _S454) - _S455 * _S455;
    float _S457 = radius_3 * radius_3;
    bool _S458 = _S456 > _S457;
    if(_S458)
    {
        return 4.294967296e+09f;
    }
    float _S459 = (F32_sqrt((_S457 - _S456)));
    float _S460 = _S455 - _S459;
    float _S461 = _S455 + _S459;
    bool _S462 = _S460 > 0.0000152587890625f;
    bool _S463;
    if(_S462)
    {
        _S463 = _S460 < max_len_0;
    }
    else
    {
        _S463 = false;
    }
    if(_S463)
    {
        return _S460;
    }
    bool _S464 = _S461 > 0.0000152587890625f;
    if(_S464)
    {
        _S463 = _S461 < max_len_0;
    }
    else
    {
        _S463 = false;
    }
    if(_S463)
    {
        return _S461;
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

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_1)
{
    Random _S465 = pcg(init_random_state_1);
    Random _S466 = pcg(_S465.state);
    Random _S467 = pcg(_S466.state);
    float3  _S468 = make_float3 (0.0f);
    TreeSample _S469 = TreeSample_x24init_0(_S468, _S468, 0.0f, _S467.state);
    TreeSample sample_0 = _S469;
    float3  _S470 = _slang_select(sided_0, _S468,smooth_n_2);
    float3  _S471 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S465.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S472 = (fcptLightNode((n_8)));
        if((_S472.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S473 = (fcptLightSecond((n_8)));
        uint _S474 = n_8 + 1U;
        LightNode _S475 = (fcptLightBounds((_S474)));
        LightNode _S476 = (fcptLightBounds((_S473)));
        uint _S477 = pickChild(_S475, _S476, origin_4, _S470, &pick_1, &probability_4);
        bool _S478 = _S477 > 1U;
        if(_S478)
        {
            return sample_0;
        }
        bool _S479 = _S477 == 1U;
        uint _S480 = _slang_select(_S479, _S473,_S474);
        n_8 = _S480;
    }
    bool _S481 = n_8 == 0U;
    bool _S482;
    if(_S481)
    {
        LightNode _S483 = (fcptLightBounds((0U)));
        float _S484 = importance(_S483, origin_4, _S470);
        _S482 = !(_S484 > 0.0f);
    }
    else
    {
        _S482 = false;
    }
    if(_S482)
    {
        return sample_0;
    }
    uint4  _S485 = (fcptLightNode((n_8)));
    FKHit _S486 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S487 = (_S485.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S487)
    {
        FKLight _S488 = (fcptLight((_S485.y)));
        if(sided_0)
        {
            float _S489 = sign_0(dot_0(geometry_n_1, _S488.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S489);
            float3  _S490 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S490;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S471;
            lift_n_0 = smooth_n_2;
        }
        bool _S491 = (_S488.variance) == 0.0f;
        if(_S491)
        {
            float3  _S492 = _S488.position - emitter_point_0;
            float3  _S493 = ((((_S492)) * make_float3(rnorm3df(((_S492)).x, ((_S492)).y, ((_S492)).z))));
            (&sample_0)->dir = _S493;
            float3  _S494 = _S488.color * make_float3 (_S488.intensity) / make_float3 (dot_0(_S492, _S492) * probability_4);
            (&sample_0)->radiance = _S494;
            shadow_1 = _S492;
        }
        else
        {
            float3  _S495 = sampleSphere(_S488.position, _S488.variance, emitter_point_0, _S466.value, _S467.value);
            (&sample_0)->dir = _S495;
            float _S496 = sphereDensity(_S488.position, _S488.variance, emitter_point_0);
            float _S497 = probability_4 * _S496;
            (&sample_0)->density = _S497;
            float3  _S498 = pointLightRadiance(_S488.color, _S488.intensity, _S488.variance);
            float3  _S499 = _S498 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S499;
            FKRay _S500 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S501 = raySphere_0(_S488.position, _S488.variance, &_S500, 4.294967296e+09f);
            float3  _S502 = (&sample_0)->dir * make_float3 (_S501);
            shadow_1 = _S502;
        }
        emitter_0 = _S486;
        emitter_point_0 = _S468;
    }
    else
    {
        uint _S503 = _S485.y;
        uint _S504 = (fcptTriangleOffset((_S503)));
        uint _S505 = _S504 + _S485.z;
        Matrix<float, 3, 3>  _S506 = (fcptWorldTriangle((_S503), (_S505)));
        float _S507 = (F32_sqrt((_S466.value)));
        float2  _S508 = make_float2 (_S507 * (1.0f - _S467.value), _S507 * _S467.value);
        float3  _S509 = mul_0(make_float3 (1.0f - _S507, _S508.x, _S508.y), _S506);
        if(sided_0)
        {
            float _S510 = sign_0(dot_0(geometry_n_1, _S509 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S510);
            float3  _S511 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S511;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S512 = !((dot_0(smooth_n_2, _S509 - origin_4)) > 0.0f);
            if(_S512)
            {
                return sample_0;
            }
            emitter_point_0 = _S471;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S508, _S503, _S505, 0U, 0.0f);
        float3  _S513 = _S509 - emitter_point_0;
        float3  _S514 = ((((_S513)) * make_float3(rnorm3df(((_S513)).x, ((_S513)).y, ((_S513)).z))));
        (&sample_0)->dir = _S514;
        float _S515 = solidAngle(probability_4, cross_0(_S506.rows[int(1)] - _S506.rows[int(0)], _S506.rows[int(2)] - _S506.rows[int(0)]), _S513);
        (&sample_0)->density = _S515;
        bool _S516 = (fcptShadowFirst());
        bool _S517 = !_S516;
        if(_S517)
        {
            FKSurface _S518 = (fcptLightSurfaceAt((emitter_1), (_S509), (_S467.state), ((&sample_0)->dir), (context_1->depth), (length_0(_S509 - origin_4))));
            (&sample_0)->random_state = _S518.random_state;
            float3  _S519 = _slang_select(_S518.skip, _S468,_S518.material.emissive);
            float3  _S520 = _S519 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S520;
        }
        shadow_1 = _S513;
        emitter_0 = emitter_1;
        emitter_point_0 = _S509;
    }
    FKHit _S521 = emitter_0;
    float3  _S522 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_1, _S467.state, &_S521);
    bool _S523 = (fcptShadowFirst());
    if(_S523)
    {
        _S482 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S482 = false;
    }
    if(_S482)
    {
        _S482 = !all_0(_S522 == _S468);
    }
    else
    {
        _S482 = false;
    }
    if(_S482)
    {
        FKSurface _S524 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S467.state), ((&sample_0)->dir), (context_1->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S524.random_state;
        float3  _S525 = _slang_select(_S524.skip, _S468,_S524.material.emissive);
        float3  _S526 = _S525 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S526;
    }
    float3  _S527 = (&sample_0)->radiance * _S522;
    bool _S528 = all_0(_S522 == _S468);
    float3  _S529 = _slang_select(_S528, _S468,_S527);
    (&sample_0)->radiance = _S529;
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
    float _S530 = 1.0f / (1.0f + b_0 / a_4 * (b_0 / a_4));
    bool _S531 = b_0 > 0.0f;
    float _S532 = _slang_select(_S531, _S530,1.0f);
    return _S532;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_0, float3  light_point_1)
{
    bool _S533 = vertex_0->none;
    if(_S533)
    {
        return 1.0f;
    }
    uint _S534 = (fcptLightSlot((*hit_0)));
    float _S535 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S534, light_point_1);
    float _S536 = powerHeuristic(vertex_0->pdf, _S535);
    return _S536;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_0)
{
    uint2  _S537 = (fcptEnvironmentMapSize());
    bool _S538 = (_S537.x) > 1U;
    bool _S539;
    if(_S538)
    {
        uint2  _S540 = (fcptEnvironmentMapSize());
        _S539 = (_S540.y) > 1U;
    }
    else
    {
        _S539 = false;
    }
    if(_S539)
    {
        float3  _S541 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_0)));
        return _S541;
    }
    float3  _S542 = (fcptAmbient());
    return _S542;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S543 = (fcptEnvironmentCdfSize());
    bool _S544 = (_S543.x) > 1U;
    bool _S545;
    if(_S544)
    {
        uint2  _S546 = (fcptEnvironmentCdfSize());
        _S545 = (_S546.y) > 1U;
    }
    else
    {
        _S545 = false;
    }
    bool _S547 = !_S545;
    if(_S547)
    {
        return false;
    }
    uint2  _S548 = (fcptEnvironmentMapSize());
    bool _S549 = (_S548.x) > 1U;
    if(_S549)
    {
        uint2  _S550 = (fcptEnvironmentMapSize());
        _S545 = (_S550.y) > 1U;
    }
    else
    {
        _S545 = false;
    }
    return _S545;
}

static __device__ float escapeWeight_0(float pdf_2, float3  dir_8)
{
    bool _S551 = pdf_2 <= 0.0f;
    bool _S552;
    if(_S551)
    {
        _S552 = true;
    }
    else
    {
        bool _S553 = environmentMapped_0();
        _S552 = !_S553;
    }
    if(_S552)
    {
        return 1.0f;
    }
    float _S554 = environmentPdf_0(dir_8);
    return pdf_2 / (pdf_2 + _S554);
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

static __device__ Shift Shift_x24init_0(float3  f_3, float jac_0)
{
    Shift _S555;
    (&_S555)->f = f_3;
    (&_S555)->jac = jac_0;
    return _S555;
}

static __device__ uint extractBits_0(uint e_1, uint offset_0, uint count_1)
{
    return (e_1 >> offset_0) & ((1U << count_1) - 1U);
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_3, float3  origin_5, float3  smooth_n_3, float3  start_2)
{
    NEEVertex _S556;
    (&_S556)->none = none_0;
    (&_S556)->pdf = pdf_3;
    (&_S556)->origin = origin_5;
    (&_S556)->smooth_n = smooth_n_3;
    (&_S556)->start = start_2;
    return _S556;
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
    Vertex _S557;
    (&_S557)->rough = rough_0;
    (&_S557)->lobe = lobe_1;
    (&_S557)->pdf = pdf_4;
    (&_S557)->cos = cos_0;
    (&_S557)->inside = inside_0;
    return _S557;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S558 = hash(index_0);
    uint _S559 = hash(seed_0 ^ _S558);
    return _S559;
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
    float3  _S560 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_1));
    float3  _S561 = scatter_0 * _S560 / make_float3 (sigma_1);
    float3  _S562 = _slang_select(scatters_0, _S561,_S560);
    return _S562;
}

static __device__ bool scatterSampled_0(bool replay_0, uint b_1, uint stop_0, bool varying_0)
{
    bool _S563 = !replay_0;
    bool _S564;
    if(_S563)
    {
        _S564 = true;
    }
    else
    {
        bool _S565 = b_1 == stop_0;
        if(_S565)
        {
            _S564 = !varying_0;
        }
        else
        {
            _S564 = false;
        }
    }
    return _S564;
}

static __device__ uint arrivalLobe_0(uint b_2, uint prev_lobe_0)
{
    bool _S566 = b_2 > 0U;
    uint _S567 = _slang_select(_S566, prev_lobe_0,3U);
    return _S567;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_5, float length_2, float width_0, FKHit * own_0, bool fiber_0)
{
    ShadowContext _S568;
    (&_S568)->extinction_behind = extinction_behind_0;
    (&_S568)->extinction_front = extinction_front_0;
    (&_S568)->fillings = fillings_0;
    (&_S568)->side = side_0;
    (&_S568)->depth = depth_1;
    (&_S568)->lobe = lobe_2;
    (&_S568)->surface = surface_5;
    (&_S568)->length = length_2;
    (&_S568)->width = width_0;
    (&_S568)->own = *own_0;
    (&_S568)->fiber = fiber_0;
    return _S568;
}

__device__ float3  safeDivide(float3  a_5, float3  b_3)
{
    float3  _S569 = a_5 / b_3;
    float3  _S570 = make_float3 (0.0f);
    bool3  _S571 = b_3 == _S570;
    float3  _S572 = _slang_select(_S571, _S570,_S569);
    return _S572;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S573 = (1U << count_2) - 1U;
    return (e_2 & (~(_S573 << offset_1))) | ((newbits_0 & _S573) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_0, uint end_type_0, uint end_0, float3  f_4)
{
    Reservoir candidate_0 = r_0;
    uint _S574 = insertBits_0(r_0.path, end_0, 0U, 5U);
    uint _S575 = insertBits_0(_S574, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S575;
    (&candidate_0)->f = f_4;
    return candidate_0;
}

__device__ void offer(Selection * sel_0, Reservoir candidate_1, float3  weight_0)
{
    float _S576 = rgb_to_greyscale(weight_0);
    bool _S577 = _S576 > 0.0f;
    bool _S578;
    if(_S577)
    {
        _S578 = _S576 < 3.00000000549775576e+38f;
    }
    else
    {
        _S578 = false;
    }
    bool _S579 = !_S578;
    if(_S579)
    {
        return;
    }
    bool _S580 = sel_0->sums;
    if(_S580)
    {
        float3  _S581 = sel_0->color + weight_0;
        sel_0->color = _S581;
        return;
    }
    float _S582 = sel_0->w_sum + _S576;
    sel_0->w_sum = _S582;
    float3  _S583 = sel_0->color + weight_0;
    sel_0->color = _S583;
    Random _S584 = pcg(sel_0->random_state);
    sel_0->random_state = _S584.state;
    bool _S585 = (_S584.value * sel_0->w_sum) <= _S576;
    if(_S585)
    {
        sel_0->r = candidate_1;
    }
    return;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_8)
{
    Random _S586 = pcg(random_state_8);
    Random _S587 = pcg(_S586.state);
    float _S588 = 1.0f - 2.0f * _S586.value;
    float _S589 = (F32_sqrt(((F32_max((1.0f - _S588 * _S588), (0.0f))))));
    float _S590 = 6.28318548202514648f * _S587.value;
    return make_float3 (_S589 * (F32_cos((_S590))), _S589 * (F32_sin((_S590))), _S588);
}

static __device__ Vertex scatteredVertex_0(bool is_inside_5)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2)
{
    BSDFMaterial _S591;
    (&_S591)->albedo = albedo_0;
    (&_S591)->emissive = emissive_0;
    (&_S591)->roughness = roughness_0;
    (&_S591)->metallic = metallic_0;
    (&_S591)->transmission = transmission_0;
    (&_S591)->ior = ior_0;
    (&_S591)->absorption = absorption_0;
    (&_S591)->specular_tint = specular_tint_0;
    (&_S591)->specular_level = specular_level_0;
    (&_S591)->translucent = translucent_0;
    (&_S591)->sheen = sheen_2;
    (&_S591)->sheen_roughness = sheen_roughness_0;
    (&_S591)->anisotropy = anisotropy_0;
    (&_S591)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S591)->tangent = tangent_2;
    return _S591;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1)
{
    FKMedium _S592;
    (&_S592)->scatter = scatter_1;
    (&_S592)->extinction = extinction_1;
    return _S592;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_9, bool skip_0, uint random_state_9, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S593;
    (&_S593)->smooth_n = smooth_n_4;
    (&_S593)->geometry_n = geometry_n_2;
    (&_S593)->geometry_offset = geometry_offset_2;
    (&_S593)->material = *material_9;
    (&_S593)->skip = skip_0;
    (&_S593)->random_state = random_state_9;
    (&_S593)->coverage = coverage_0;
    (&_S593)->encloses = encloses_0;
    (&_S593)->volume = *volume_0;
    (&_S593)->fills = fills_0;
    (&_S593)->hair = hair_0;
    return _S593;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S594 = (&surface_6->material)->emissive;
    float3  _S595 = make_float3 (0.0f);
    bool _S596 = !top_0;
    float3  _S597 = _slang_select(_S596, _S595,_S594);
    (&(&lower_0)->material)->emissive = _S597;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_2)
{
    float _S598 = surface_7->coverage;
    bool _S599 = u_2 < _S598;
    if(_S599)
    {
        return *surface_7;
    }
    float3  _S600 = make_float3 (0.0f);
    float3  _S601 = make_float3 (1.0f);
    BSDFMaterial _S602 = Material_x24init_0(_S600, _S600, 0.0f, 0.0f, 0.0f, 0.0f, _S600, _S601, 1.0f, _S600, _S600, 0.5f, 0.0f, 0.0f, _S600);
    BSDFMaterial material_10 = _S602;
    (&material_10)->albedo = _S601;
    (&material_10)->emissive = (&surface_7->material)->emissive;
    (&material_10)->transmission = 1.0f;
    (&material_10)->ior = 1.0f;
    (&material_10)->absorption = (&surface_7->material)->absorption;
    FKSurface through_0 = *surface_7;
    (&through_0)->material = material_10;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S603 = transmission_1 > 0.0f;
    bool _S604;
    if(_S603)
    {
        _S604 = true;
    }
    else
    {
        _S604 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S605;
    if(_S604)
    {
        _S605 = 1.0f;
    }
    else
    {
        _S605 = -1.0f;
    }
    return _S605;
}

static __device__ bool arrivesBehind_0(float3  dir_9, float3  n_9)
{
    return (dot_0(dir_9, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_10)
{
    float3  _S606 = surface_8->geometry_n;
    float _S607 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_10);
    FKSurface faced_0 = *surface_8;
    float3  _S608 = surface_8->smooth_n * make_float3 (_S607);
    (&faced_0)->smooth_n = _S608;
    float3  _S609 = _S606 * make_float3 (_S607);
    (&faced_0)->geometry_n = _S609;
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
    float3  _S610 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_2) * log_0(_S610));
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
    bool _S611;
    if(open_0)
    {
        _S611 = prev_rough_0;
    }
    else
    {
        _S611 = false;
    }
    if(_S611)
    {
        _S611 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S611 = false;
    }
    return _S611;
}

__device__ float2  vertexEta(BSDFMaterial material_11, float n_dot_v_0)
{
    bool _S612 = n_dot_v_0 < 0.0f;
    float _S613 = _slang_select(_S612, material_11.ior,1.0f);
    float _S614 = _slang_select(_S612, 1.0f,material_11.ior);
    return make_float2 (_S613, _S614);
}

__device__ bool neeDecision(BSDFMaterial material_12, float n_dot_v_1, float eta_i_8, float eta_o_8)
{
    float _S615 = fresnel((F32_abs((n_dot_v_1))), eta_i_8, eta_o_8);
    float3  _S616 = mix_0(make_float3 (_S615), material_12.albedo, material_12.metallic);
    float _S617 = rgb_to_greyscale(_S616);
    float _S618 = (F32_max(((1.0f - _S617) * (1.0f - material_12.metallic) * (1.0f - material_12.transmission)), (0.0f)));
    bool _S619 = _S618 > 0.03999999910593033f;
    bool _S620;
    if(_S619)
    {
        _S620 = true;
    }
    else
    {
        _S620 = (material_12.roughness) > 0.20000000298023224f;
    }
    return _S620;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_13)
{
    float _S621 = rgb_to_greyscale(material_13->translucent);
    return _S621 > 0.0f;
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
    MediumSides _S622;
    (&_S622)->behind = *behind_0;
    (&_S622)->front = *front_0;
    (&_S622)->fillings = fillings_1;
    (&_S622)->face = face_1;
    return _S622;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_11)
{
    float3  _S623 = surface_9->geometry_n;
    MediumSides _S624 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S624;
    bool _S625 = surface_9->encloses;
    if(_S625)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S626 = (dot_0(dir_11, _S623)) > 0.0f;
        if(_S626)
        {
            float3  _S627 = make_float3 (0.0f);
            FKMedium _S628 = Medium_x24init_0(_S627, _S627);
            (&sides_0)->front = _S628;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_12, uint depth_2, uint lobe_3, float length_3, float width_1, FKHit * own_1, bool fiber_1)
{
    float3  _S629 = surface_10->geometry_n;
    ShadowContext _S630 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
    bool _S631 = surface_10->encloses;
    ShadowContext context_2;
    if(_S631)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S632 = - _S629;
        float3  _S633 = _slang_select(turned_0, _S632,_S629);
        (&faced_1)->geometry_n = _S633;
        FKMedium _S634 = Medium_x24init_0(make_float3 (0.0f), extinction_2);
        FKSurface _S635 = faced_1;
        FKMedium _S636 = _S634;
        MediumSides _S637 = mediumSides_0(&_S635, &_S636, filling_1, dir_12);
        ShadowContext _S638 = ShadowContext_x24init_0(_S637.behind.extinction, _S637.front.extinction, _S637.fillings, _S629, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
        if(turned_0)
        {
            uint2  _S639 = _S637.fillings;
            ShadowContext _S640 = ShadowContext_x24init_0(_S637.front.extinction, _S637.behind.extinction, uint2 {_S639.y, _S639.x}, _S629, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
            context_2 = _S640;
        }
        else
        {
            context_2 = _S638;
        }
    }
    else
    {
        context_2 = _S630;
    }
    return context_2;
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

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_14, float eta_i_9, float eta_o_9, bool competing_1, uint random_state_10)
{
    float3  _S641 = light_2->dir;
    bool _S642 = (dot_0(geometry_n_4, - in_dir_8) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 4>  throughputs_1;
    FixedArray<float, 4>  pdfs_3;
    float3  _S643 = BSDF(in_dir_8, _S641, smooth_n_5, *material_14, eta_i_9, eta_o_9, _S642, random_state_10, &throughputs_1, &pdfs_3);
    bool _S644 = !competing_1;
    bool _S645;
    if(_S644)
    {
        _S645 = true;
    }
    else
    {
        _S645 = (light_2->density) == 0.0f;
    }
    if(_S645)
    {
        return _S643 * light_2->radiance;
    }
    float3  _S646 = make_float3 (0.0f);
    uint i_15 = 0U;
    float3  weighted_0 = _S646;
    for(;;)
    {
        if(i_15 < 4U)
        {
        }
        else
        {
            break;
        }
        bool _S647 = (pdfs_3[i_15]) > 0.0f;
        if(_S647)
        {
            float _S648 = light_2->density;
            float _S649 = pdfs_3[i_15] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_15] * make_float3 (pdfs_3[i_15]) / make_float3 (_S648 * (1.0f + _S649 * _S649));
            weighted_0 = weighted_1;
        }
        uint i_16 = i_15 + 1U;
        i_15 = i_16;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_11, bool refracted_3, uint lobe_4, float pdf_5)
{
    SampleBSDF _S650;
    (&_S650)->unit_direction = unit_direction_1;
    (&_S650)->throughput = throughput_1;
    (&_S650)->random_state = random_state_11;
    (&_S650)->refracted = refracted_3;
    (&_S650)->lobe = lobe_4;
    (&_S650)->pdf = pdf_5;
    return _S650;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_7, float n_i_dot_v_5, float alpha_13, BSDFMaterial material_15, BSDFLobes lobes_9, float eta_i_10, float eta_o_10, uint random_state_12)
{
    float3  _S651 = make_float3 (1.0f);
    SampleBSDF _S652 = SampleBSDF_x24init_0(_S651, _S651, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S652;
    Random _S653 = pcg(random_state_12);
    Random _S654 = pcg(_S653.state);
    (&sample_1)->random_state = _S654.state;
    float _S655 = _S653.value;
    float _S656 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S655 * _S655))))));
    float _S657 = 6.28318548202514648f * _S654.value;
    float3  _S658 = tangentToWorld(make_float3 (_S656 * (F32_cos((_S657))), _S653.value, _S656 * (F32_sin((_S657)))), n_i_7);
    (&sample_1)->unit_direction = _S658;
    (&sample_1)->lobe = 4U;
    float3  _S659 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_7, alpha_13, material_15, lobes_9);
    (&sample_1)->throughput = _S659;
    float _S660 = sheenVelvetPDF(_S653.value, 0.0f, n_i_dot_v_5, alpha_13, lobes_9, eta_i_10, eta_o_10);
    (&sample_1)->pdf = _S660;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S661 = (F32_sqrt((random_1_0)));
    float _S662 = 6.28318548202514648f * random_2_0;
    float _S663 = _S661 * (F32_cos((_S662)));
    float _S664 = _S661 * (F32_sin((_S662)));
    float _S665 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S663 * _S663 - _S664 * _S664))))));
    return make_float3 (_S663, _S665, _S664);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_8, float n_i_dot_v_6, float alpha_14, BSDFMaterial material_16, BSDFLobes lobes_10, float eta_i_11, float eta_o_11, uint random_state_13)
{
    float3  _S666 = make_float3 (1.0f);
    SampleBSDF _S667 = SampleBSDF_x24init_0(_S666, _S666, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S667;
    Random _S668 = pcg(random_state_13);
    Random _S669 = pcg(_S668.state);
    (&sample_2)->random_state = _S669.state;
    float3  _S670 = sampleCosWeightedHemisphere(_S668.value, _S669.value);
    bool _S671 = u_3 < (lobes_10.p_diffuse * lobes_10.translucent_share);
    float _S672 = _S670.y;
    float _S673 = - _S672;
    float _S674 = _slang_select(_S671, _S673,_S672);
    float3  _S675 = tangentToWorld(make_float3 (_S670.x, _S674, _S670.z), n_i_8);
    (&sample_2)->unit_direction = _S675;
    (&sample_2)->refracted = _S671;
    (&sample_2)->lobe = 0U;
    float3  _S676 = diffuseBSDF((&sample_2)->unit_direction, n_i_8, alpha_14, material_16, lobes_10);
    (&sample_2)->throughput = _S676;
    float _S677 = diffusePDF(_S674, 0.0f, n_i_dot_v_6, alpha_14, lobes_10, eta_i_11, eta_o_11);
    (&sample_2)->pdf = _S677;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_9, float n_i_dot_v_7, float alpha_15, BSDFMaterial material_17, BSDFLobes lobes_11, float eta_i_12, float eta_o_12, uint random_state_14)
{
    float3  _S678 = make_float3 (1.0f);
    SampleBSDF _S679 = SampleBSDF_x24init_0(_S678, _S678, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S679;
    (&sample_3)->unit_direction = lobes_11.refracted;
    (&sample_3)->random_state = random_state_14;
    (&sample_3)->refracted = true;
    (&sample_3)->lobe = 1U;
    float3  _S680 = refractBSDF((&sample_3)->unit_direction, n_i_9, alpha_15, material_17, lobes_11);
    (&sample_3)->throughput = _S680;
    float _S681 = refractPDF(0.0f, dot_0((&sample_3)->unit_direction, ggx_n_3), n_i_dot_v_7, alpha_15, lobes_11, eta_i_12, eta_o_12);
    (&sample_3)->pdf = _S681;
    return sample_3;
}

static __device__ float3  reflect_0(float3  i_17, float3  n_10)
{
    return i_17 - make_float3 (2.0f * dot_0(n_10, i_17)) * n_10;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_10, float n_i_dot_v_8, float alpha_16, BSDFMaterial material_18, BSDFLobes lobes_12, float eta_i_13, float eta_o_13, uint random_state_15)
{
    float3  _S682 = make_float3 (1.0f);
    SampleBSDF _S683 = SampleBSDF_x24init_0(_S682, _S682, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S683;
    float3  _S684 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S685 = ((((_S684)) * make_float3(rnorm3df(((_S684)).x, ((_S684)).y, ((_S684)).z))));
    (&sample_4)->unit_direction = _S685;
    (&sample_4)->random_state = random_state_15;
    (&sample_4)->lobe = 2U;
    float3  _S686 = reflectBSDF((&sample_4)->unit_direction, n_i_10, alpha_16, material_18, lobes_12);
    (&sample_4)->throughput = _S686;
    float _S687 = reflectPDF(0.0f, 0.0f, n_i_dot_v_8, alpha_16, lobes_12, eta_i_13, eta_o_13);
    (&sample_4)->pdf = _S687;
    return sample_4;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_11, BSDFMaterial material_19, float eta_i_14, float eta_o_14, uint random_init_0, float2  screen_space_0)
{
    uint random_state_16 = random_init_0;
    float3  _S688 = negate_0(in_dir_10);
    float _S689 = dot_0(n_11, _S688);
    float _S690 = sign_0(_S689);
    float3  n_i_11 = n_11 * make_float3 (_S690);
    float _S691 = (F32_abs((_S689)));
    float _S692 = material_19.roughness;
    float _S693 = _S692 * _S692;
    AnisotropicFrame _S694 = anisotropicFrame(material_19, n_i_11);
    float3  _S695 = sampleHalfVector(_S688, n_i_11, _S693, _S694, &random_state_16);
    BSDFLobes _S696 = bsdfLobes(in_dir_10, _S688, n_i_11, _S695, material_19, eta_i_14, eta_o_14, _S694);
    BSDFLobes lobes_13 = _S696;
    float _S697 = translucentShare(material_19);
    (&lobes_13)->translucent_share = _S697;
    Random _S698 = pcg(random_state_16);
    random_state_16 = _S698.state;
    bool _S699 = (_S698.value) < ((&lobes_13)->p_sheen_velvet);
    if(_S699)
    {
        SampleBSDF _S700 = sheenVelvetSample(n_i_11, _S691, _S693, material_19, lobes_13, eta_i_14, eta_o_14, random_state_16);
        return _S700;
    }
    float _S701 = _S698.value - (&lobes_13)->p_sheen_velvet;
    bool _S702 = _S701 < ((&lobes_13)->p_diffuse);
    if(_S702)
    {
        SampleBSDF _S703 = diffuseSample(_S701, n_i_11, _S691, _S693, material_19, lobes_13, eta_i_14, eta_o_14, random_state_16);
        return _S703;
    }
    bool _S704 = _S701 < ((&lobes_13)->p_diffuse + (&lobes_13)->p_refract);
    if(_S704)
    {
        SampleBSDF _S705 = refractSample(_S695, n_i_11, _S691, _S693, material_19, lobes_13, eta_i_14, eta_o_14, random_state_16);
        return _S705;
    }
    SampleBSDF _S706 = reflectSample(in_dir_10, _S695, n_i_11, _S691, _S693, material_19, lobes_13, eta_i_14, eta_o_14, random_state_16);
    return _S706;
}

__device__ bool withinInverseFootprint(float pdf_6, bool diffuse_0, float prev_cos_0, float distance_4, float threshold_1)
{
    bool _S707 = pdf_6 > 0.0f;
    bool _S708;
    if(_S707)
    {
        if(diffuse_0)
        {
            _S708 = true;
        }
        else
        {
            _S708 = (pdf_6 * prev_cos_0 / (distance_4 * distance_4) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S708 = false;
    }
    return _S708;
}

__device__ bool roughLobe(float pdf_7, bool diffuse_1, float roughness_1)
{
    bool _S709 = pdf_7 > 0.0f;
    bool _S710;
    if(_S709)
    {
        if(diffuse_1)
        {
            _S710 = true;
        }
        else
        {
            _S710 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S710 = false;
    }
    return _S710;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S711 = layers_0 > 1U;
    bool _S712;
    if(_S711)
    {
        _S712 = refracting_0 != passed_0;
    }
    else
    {
        _S712 = false;
    }
    return _S712;
}

static __device__ float widened_0(float spread_0, float pdf_8, bool delta_0)
{
    float _S713 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_8))))), (3.14159274101257324f)));
    bool _S714 = !delta_0;
    float _S715 = _slang_select(_S714, _S713,0.0f);
    return spread_0 + _S715;
}

static __device__ bool boundsVolume_0(FKSurface * surface_11)
{
    return surface_11->encloses;
}

static __device__ bool leavesInFront_0(float3  face_2, float3  dir_13, float3  g_0)
{
    return ((dot_0(dir_13, g_0)) > 0.0f) == ((dot_0(g_0, face_2)) > 0.0f);
}

static __device__ float distance_5(float3  x_15, float3  y_5)
{
    return length_0(x_15 - y_5);
}

static __device__ Shift walk_0(Domain * dom_0, Reservoir * r_1, bool replay_1, float scale_1, Selection * sel_1)
{
    float spread_1;
    bool turned_1;
    bool is_inside_6;
    bool viewed_0;
    bool _S716;
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
    int _S717;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_3;
    float sky_pdf_1;
    float spread_3;
    float width_4;
    uint b_5;
    float3  _S718 = make_float3 (0.0f);
    Shift _S719 = Shift_x24init_0(_S718, 0.0f);
    uint _S720 = r_1->path;
    uint _S721 = extractBits_0(r_1->path, 0U, 5U);
    uint _S722 = extractBits_0(_S720, 5U, 5U);
    uint _S723 = extractBits_0(_S720, 10U, 2U);
    uint _S724 = extractBits_0(_S720, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S725 = _S724 >= 3U;
        uint _S726 = _slang_select(_S725, 1U,0U);
        uint _S727 = _S721 + _S726;
        uint _S728 = (fcptMaxBounces());
        passes_0 = _S727 > _S728;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S719;
    }
    uint _S729 = _S722 - 1U;
    bool _S730 = _S724 == 3U;
    uint _S731 = _slang_select(_S730, 1U,0U);
    uint _S732 = _S721 + _S731;
    bool _S733 = _S723 == 0U;
    uint _S734 = _slang_select(_S733, _S732,_S729);
    FKHit _S735 = (fcptReservoirHit((*r_1)));
    float3  _S736 = dom_0->x0;
    float3  _S737 = dom_0->x1 - dom_0->x0;
    float3  _S738 = ((((_S737)) * make_float3(rnorm3df(((_S737)).x, ((_S737)).y, ((_S737)).z))));
    FKRay _S739 = Ray_x24init_0(dom_0->x1, _S738);
    FKRay ray_2 = _S739;
    FKHit hit_1 = dom_0->hit;
    float3  scatter_in_0 = _S718;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S718;
    float3  extinction_in_0 = _S718;
    uint filling_2 = 4294967295U;
    float _S740 = dom_0->spread;
    float _S741 = dom_0->width;
    float _S742 = length_0(_S737);
    NEEVertex _S743 = NEEVertex_x24init_0(true, 0.0f, _S718, _S718, _S718);
    NEEVertex nee_vertex_0 = _S743;
    Vertex _S744 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S744;
    Reservoir _S745 = (Reservoir{});
    Reservoir chain_0 = _S745;
    uint _S746 = r_1->seed;
    (&chain_0)->seed = r_1->seed;
    (&ray_2)->origin = _S736;
    (&hit_1)->distance = _S742;
    FKMedium _S747 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_1)->distance), (&filling_2)));
    uint _S748 = filling_2;
    bool _S749 = (fcptVaryingUsed());
    uint _S750 = _slang_select(_S749, _S748,4294967295U);
    filling_2 = _S750;
    scatter_in_0 = _S747.scatter;
    extinction_in_0 = _S747.extinction;
    Reservoir _S751 = chain_0;
    uint _S752 = filling_2;
    for(;;)
    {
        bool _S753 = (fcptVaryingUsed());
        if(_S753)
        {
            passes_0 = _S752 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S754 = (fcptMajorant((_S752)));
            spread_1 = _S754;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S734;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S723 == 1U;
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
            ended_0 = _S719;
            sky_pdf_0 = 0.0f;
            spread_1 = _S740;
            width_2 = _S741;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_4 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S755 = (&prev_0)->rough;
        if(_S755)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S756 = stream(_S746, 384U);
        uint tracking_0 = _S756;
        weight_1 = throughput_3;
        glowed_0 = _S718;
        b_4 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_2 = _S740;
        width_2 = _S741;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_1)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S717 = int(1);
                break;
            }
            uint _S757 = b_4 + 320U;
            bool _S758 = b_4 == 4294967295U;
            uint _S759 = _slang_select(_S758, 384U,_S757);
            uint _S760 = stream(_S746, _S759);
            Random _S761 = pcg(_S760);
            float _S762 = freeFlight_0(_S761.value, spread_1);
            if(passes_0)
            {
                float3  _S763 = (&ray_2)->origin;
                float3  _S764 = (&ray_2)->unit_direction;
                float _S765 = (&hit_1)->distance;
                uint _S766 = _slang_select(_S758, 0U,b_4);
                uint _S767 = (&prev_0)->lobe;
                uint _S768 = _slang_select(_S758, 3U,_S767);
                float _S769 = (fcptTrackMedium((_S752), (_S763), (_S764), (_S765), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S766), (_S768), (_S758)));
                geometry_density_2 = _S769;
            }
            else
            {
                geometry_density_2 = _S762;
            }
            bool _S770 = !(geometry_density_2 < ((&hit_1)->distance));
            if(_S770)
            {
                _S717 = int(1);
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
                float3  _S771 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S772 = sel_1->glow + _S771;
                sel_1->glow = _S772;
            }
            else
            {
            }
            glowed_0 = _S718;
            uint b_6 = b_4 + 1U;
            float3  _S773 = (&ray_2)->origin + make_float3 (geometry_density_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S773;
            float3  _S774 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, geometry_density_2, true);
            float3  _S775 = weight_1;
            float3  _S776 = _slang_select(passes_0, _S775,_S774);
            float3  throughput_4 = throughput_2 * _S776;
            uint _S777 = stream(_S746, b_6 + 320U);
            tracking_0 = _S777;
            weight_1 = throughput_3;
            float width_5 = width_2 + threshold_2 * geometry_density_2;
            float _S778 = threshold_2 + 3.14159274101257324f;
            bool _S779 = scatterSampled_0(replay_1, b_6, _S734, passes_0);
            TreeSample _S780 = TreeSample_x24init_0(_S718, _S718, 0.0f, 0U);
            if(_S779)
            {
                float3  _S781 = (&ray_2)->origin;
                float3  _S782 = (&ray_2)->unit_direction;
                float3  _S783 = (&ray_2)->unit_direction;
                uint _S784 = stream(_S746, b_6 + 64U);
                float3  _S785 = extinction_in_0;
                float3  _S786 = extinction_in_0;
                uint2  _S787 = make_uint2 (_S752);
                float3  _S788 = (&ray_2)->unit_direction;
                uint _S789 = arrivalLobe_0(b_6, (&prev_0)->lobe);
                FKHit _S790 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S791 = _S790;
                ShadowContext _S792 = ShadowContext_x24init_0(_S785, _S786, _S787, _S788, b_6, _S789, false, geometry_density_2, width_5, &_S791, false);
                ShadowContext _S793 = _S792;
                TreeSample _S794 = sampleLightTree_0(_S781, _S782, _S783, 0.0f, true, _S784, &_S793);
                light_3 = _S794;
            }
            else
            {
                light_3 = _S780;
            }
            uint _S795 = (fcptMaxBounces());
            bool _S796 = b_6 < _S795;
            if(_S796)
            {
                is_inside_6 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_6 = false;
            }
            float _S797 = _slang_select(is_inside_6, 0.07957746833562851f,0.0f);
            float3  _S798 = throughput_4 * light_3.radiance;
            float _S799 = powerHeuristic(light_3.density, _S797);
            float3  _S800 = _S798 * make_float3 (0.07957746833562851f * _S799);
            float3  _S801 = _slang_select(_S779, _S800,_S718);
            if(replay_1)
            {
                viewed_0 = b_6 == _S734;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S802 = _S723 == 2U;
                if(_S802)
                {
                    float _S803 = rgb_to_greyscale(_S801);
                    passes_0 = _S803 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S804 = Shift_x24init_0(_S801, 1.0f);
                    _S717 = int(0);
                    ended_0 = _S804;
                    spread_1 = _S778;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                _S717 = int(0);
                ended_0 = _S719;
                spread_1 = _S778;
                geometry_density_2 = width_5;
                chain_throughput_0 = throughput_4;
                layer_0 = b_6;
                break;
            }
            bool _S805 = !replay_1;
            if(_S805)
            {
                Reservoir candidate_2 = _S751;
                uint _S806 = extractBits_0(_S751.path, 10U, 2U);
                bool _S807 = _S806 == 1U;
                if(_S807)
                {
                    float3  _S808 = safeDivide(_S801, _S718);
                    (&candidate_2)->radiance = _S808;
                }
                else
                {
                    uint _S809 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                    uint _S810 = insertBits_0(_S809, 2U, 10U, 2U);
                    (&candidate_2)->path = _S810;
                }
                Reservoir _S811 = withEnd(candidate_2, 0U, b_6, _S801);
                offer(sel_1, _S811, _S801 * make_float3 (scale_1) / make_float3 (density_2));
                float _S812 = survivalProbability(throughput_4, density_2);
                uint _S813 = stream(_S746, b_6 + 128U);
                Random _S814 = pcg(_S813);
                bool _S815 = _S812 < (_S814.value);
                if(_S815)
                {
                    _S716 = true;
                }
                else
                {
                    uint _S816 = (fcptMaxBounces());
                    _S716 = b_6 >= _S816;
                }
                if(_S716)
                {
                    _S717 = int(0);
                    ended_0 = _S719;
                    spread_1 = _S778;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                float _S817 = density_2 * _S812;
                density_2 = _S817;
            }
            else
            {
            }
            NEEVertex _S818 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_2)->origin, _S718, (&ray_2)->origin);
            nee_vertex_0 = _S818;
            uint _S819 = stream(_S746, b_6);
            float3  _S820 = isotropic_0(_S819);
            (&ray_2)->unit_direction = _S820;
            Vertex _S821 = scatteredVertex_0(false);
            prev_0 = _S821;
            float _S822 = (&prev_0)->pdf;
            FKRay _S823 = ray_2;
            FKHit _S824 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S825 = (fcptTraverseInstanceBVH((_S823), (true), (4.294967296e+09f), (false), (_S824), (false)));
            hit_1 = _S825;
            b_4 = b_6;
            throughput_2 = throughput_4;
            threshold_2 = _S778;
            width_2 = width_5;
            sky_pdf_0 = _S822;
        }
        if(_S717 != int(1))
        {
            width_2 = geometry_density_2;
            throughput_2 = chain_throughput_0;
            b_4 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S719;
        spread_1 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S826 = b_4 == 4294967295U;
    bool _S827 = ((&hit_1)->instance_index) == 4294967295U;
    if(_S827)
    {
        bool _S828 = !(&nee_vertex_0)->none;
        float _S829 = _slang_select(_S828, sky_pdf_0,0.0f);
        float _S830 = escapeWeight_0(_S829, (&ray_2)->unit_direction);
        float3  _S831 = environment_0((&ray_2)->unit_direction, b_4, (&prev_0)->lobe);
        float3  _S832 = throughput_2 * _S831;
        if(replay_1)
        {
            bool _S833 = b_4 == _S734;
            if(_S833)
            {
                passes_0 = _S723 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S832 * make_float3 (_S830) / make_float3 (r_1->jac), density_2 / r_1->jac);
            }
            if(_S733)
            {
                passes_0 = _S730;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_4 == _S721;
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
                return Shift_x24init_0(_S832 * make_float3 (_S830), 1.0f);
            }
            return _S719;
        }
        Reservoir candidate_3 = chain_0;
        uint _S834 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S835 = _S834 == 1U;
        if(_S835)
        {
            uint _S836 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S837 = _S836 == b_4;
            float _S838 = _slang_select(_S837, 1.0f,_S830);
            float3  _S839 = safeDivide(_S832 * make_float3 (_S838), _S718);
            (&candidate_3)->radiance = _S839;
        }
        else
        {
            bool _S840 = (&prev_0)->rough;
            if(_S840)
            {
                uint _S841 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                uint _S842 = insertBits_0(_S841, 3U, 10U, 2U);
                uint _S843 = insertBits_0(_S842, (&prev_0)->lobe, 15U, 3U);
                bool _S844 = (&prev_0)->inside;
                uint _S845 = _slang_select(_S844, 1U,0U);
                uint _S846 = insertBits_0(_S843, _S845, 22U, 1U);
                (&candidate_3)->path = _S846;
                (&candidate_3)->jac = (&prev_0)->pdf;
                (&candidate_3)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S847 = _S832 * make_float3 (_S830);
        Reservoir _S848 = withEnd(candidate_3, 3U, b_4, _S847);
        offer(sel_1, _S848, _S847 * make_float3 (scale_1) / make_float3 (density_2));
        return _S719;
    }
    float3  _S849 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S849;
    bool _S850 = (fcptVaryingUsed());
    if(_S850)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S851 = !replay_1;
        if(_S851)
        {
            float3  _S852 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S853 = sel_1->glow + _S852;
            sel_1->glow = _S853;
        }
        float3  _S854 = throughput_2 * weight_1;
        throughput_2 = _S854;
    }
    else
    {
        float3  _S855 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
        float3  _S856 = throughput_2 * _S855;
        throughput_2 = _S856;
    }
    float _S857 = width_2 + spread_1 * (&hit_1)->distance;
    uint _S858 = b_4 + 1U;
    b_4 = _S858;
    layer_0 = 0U;
    width_2 = _S857;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_6 = false;
    chain_throughput_0 = _S718;
    float3  reconnection_0 = _S718;
    viewed_0 = _S826;
    for(;;)
    {
        bool _S859 = ((&hit_1)->is_point_light) == 1U;
        if(replay_1)
        {
            _S716 = _S723 == 1U;
        }
        else
        {
            _S716 = false;
        }
        bool _S860;
        if(_S716)
        {
            _S860 = b_4 == _S722;
        }
        else
        {
            _S860 = false;
        }
        bool _S861;
        if(_S860)
        {
            bool _S862 = ((&hit_1)->instance_index) != (_S735.instance_index);
            if(_S862)
            {
                _S861 = true;
            }
            else
            {
                _S861 = ((&hit_1)->triangle_index) != (_S735.triangle_index);
            }
        }
        else
        {
            _S861 = false;
        }
        if(_S861)
        {
            return _S719;
        }
        FKMedium _S863 = Medium_x24init_0(_S718, _S718);
        BSDFMaterial _S864 = Material_x24init_0(_S718, _S718, 0.0f, 0.0f, 0.0f, 0.0f, _S718, throughput_3, 1.0f, _S718, _S718, 0.5f, 0.0f, 0.0f, _S718);
        FKMedium _S865 = _S863;
        FKSurface _S866 = Surface_x24init_0(_S718, _S718, 0.0f, &_S864, false, 0U, 1.0f, false, &_S865, 4294967295U, _S718);
        bool _S867 = !_S859;
        bool scatter_2;
        bool is_inside_7;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S867)
        {
            uint _S868 = stream(_S746, b_4);
            uint _S869 = arrivalLobe_0(b_4, (&prev_0)->lobe);
            FKSurface _S870 = (fcptSurfaceAtPath((hit_1), ((&ray_2)->origin), (_S868), (width_2), (layer_0), (b_4), (_S869), ((&ray_2)->unit_direction)));
            bool _S871 = !passes_0;
            FKSurface _S872 = _S870;
            FKSurface _S873 = emitting_0(&_S872, _S871);
            uint _S874 = stream(_S746, b_4 + 256U);
            Random _S875 = pcg(_S874);
            FKSurface _S876 = _S873;
            FKSurface _S877 = uncovered_0(&_S876, _S875.value);
            float _S878 = facingSign(_S877.material.transmission, _S877.geometry_n, (&ray_2)->unit_direction);
            bool _S879 = _S878 < 0.0f;
            bool _S880 = (_S877.material.transmission) > 0.0f;
            if(_S880)
            {
                bool _S881 = arrivesBehind_0((&ray_2)->unit_direction, _S877.geometry_n);
                scatter_2 = _S881;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S882 = _S877;
            FKSurface _S883 = facingRay_0(&_S882, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S884 = arrivesBehind_0((&ray_2)->unit_direction, _S883.geometry_n);
                is_inside_7 = _S884;
            }
            else
            {
                is_inside_7 = scatter_2;
            }
            if(is_inside_7)
            {
                float3  _S885 = beerLambert((&hit_1)->distance, _S883.material.absorption);
                float3  _S886 = throughput_2 * _S885;
                throughput_5 = _S886;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S887 = !_S883.skip;
            float geometry_density_3 = geometryDensity(_S883.geometry_n, (&ray_2)->unit_direction, (&hit_1)->distance);
            bool _S888 = b_4 == _S858;
            if(_S888)
            {
                float _S889 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S889;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S890 = geometry_density_2;
            scatter_2 = _S887;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S890;
            surface_12 = _S883;
            turned_1 = _S879;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_12 = _S866;
            throughput_5 = throughput_2;
            is_inside_7 = is_inside_6;
        }
        bool _S891 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S892 = surface_12;
        FKSurface _S893 = surface_12;
        float _S894 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        float2  _S895 = vertexEta(_S892.material, _S894);
        bool _S896;
        if(scatter_2)
        {
            bool _S897 = neeDecision(_S892.material, _S894, _S895.x, _S895.y);
            _S896 = _S897;
        }
        else
        {
            _S896 = false;
        }
        bool _S898;
        if(passes_0)
        {
            _S898 = true;
        }
        else
        {
            _S898 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S898)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S896;
        }
        bool _S899 = (fcptHairUsed());
        bool _S900;
        if(_S899)
        {
            float3  _S901 = surface_12.hair;
            _S900 = (dot_0(_S901, _S901)) > 0.0f;
        }
        else
        {
            _S900 = false;
        }
        bool _S902;
        if(_S900)
        {
            _S902 = true;
        }
        else
        {
            BSDFMaterial _S903 = _S892.material;
            bool _S904 = isTranslucent_0(&_S903);
            _S902 = _S904;
        }
        bool _S905;
        if(_S902)
        {
            _S905 = true;
        }
        else
        {
            bool _S906 = (_S892.material.transmission) > 0.0f;
            if(_S906)
            {
                uint _S907 = (fcptLayers((hit_1)));
                _S905 = _S907 == 1U;
            }
            else
            {
                _S905 = false;
            }
        }
        float3  emission_0;
        if(_S859)
        {
            float3  _S908 = (fcptCalculatePointLightContrib(((&hit_1)->instance_index)));
            emission_0 = _S908;
        }
        else
        {
            emission_0 = _S892.material.emissive;
        }
        bool _S909 = !replay_1;
        bool _S910;
        if(_S909)
        {
            _S910 = true;
        }
        else
        {
            _S910 = b_4 >= _S734;
        }
        bool _S911;
        if(_S910)
        {
            float _S912 = rgb_to_greyscale(emission_0);
            _S911 = _S912 > 0.0f;
        }
        else
        {
            _S911 = false;
        }
        float3  emission_1;
        if(_S911)
        {
            NEEVertex _S913 = nee_vertex_0;
            FKHit _S914 = hit_1;
            float _S915 = emissionWeight_0(&_S913, &_S914, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S915);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S916;
        if(replay_1)
        {
            _S916 = _S723 == 1U;
        }
        else
        {
            _S916 = false;
        }
        bool _S917;
        if(_S916)
        {
            _S917 = b_4 > _S722;
        }
        else
        {
            _S917 = false;
        }
        bool _S918;
        if(_S917)
        {
            _S918 = b_4 == _S721;
        }
        else
        {
            _S918 = false;
        }
        bool _S919;
        if(_S918)
        {
            bool _S920 = _S724 == 1U;
            if(_S920)
            {
                _S919 = true;
            }
            else
            {
                _S919 = _S724 == 2U;
            }
        }
        else
        {
            _S919 = false;
        }
        if(_S919)
        {
            bool _S921 = _S859 != (_S724 == 2U);
            if(_S921)
            {
                return _S719;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_1->jac), density_2 / r_1->jac);
        }
        uint _S922 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S923 = _S922 == 1U;
        Reservoir here_0 = chain_0;
        uint _S924 = insertBits_0(0U, b_4, 5U, 5U);
        uint _S925 = insertBits_0(_S924, 1U, 10U, 2U);
        uint _S926 = insertBits_0(_S925, (&prev_0)->lobe, 15U, 3U);
        bool _S927 = (&prev_0)->inside;
        uint _S928 = _slang_select(_S927, 1U,0U);
        uint _S929 = insertBits_0(_S926, _S928, 22U, 1U);
        (&here_0)->path = _S929;
        float _S930 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S930;
        fcptWithReservoirHit((&here_0), (&hit_1));
        bool _S931;
        if(replay_1)
        {
            _S931 = _S723 == 1U;
        }
        else
        {
            _S931 = false;
        }
        bool _S932;
        if(_S931)
        {
            _S932 = b_4 == _S722;
        }
        else
        {
            _S932 = false;
        }
        bool _S933 = b_4 == _S734;
        bool _S934;
        if(_S933)
        {
            bool _S935 = !scatter_2;
            if(_S935)
            {
                _S934 = true;
            }
            else
            {
                bool _S936 = _S723 != 1U;
                if(_S936)
                {
                    _S934 = _S723 != 3U;
                }
                else
                {
                    _S934 = false;
                }
            }
        }
        else
        {
            _S934 = false;
        }
        bool _S937;
        if(_S934)
        {
            _S937 = _S723 == 2U;
        }
        else
        {
            _S937 = false;
        }
        bool _S938;
        if(_S937)
        {
            _S938 = !_S891;
        }
        else
        {
            _S938 = false;
        }
        bool _S939;
        if(_S938)
        {
            _S939 = _S724 != 4U;
        }
        else
        {
            _S939 = false;
        }
        bool _S940 = _S722 == _S721;
        bool _S941;
        if(_S940)
        {
            _S941 = _S724 == 0U;
        }
        else
        {
            _S941 = false;
        }
        bool _S942;
        if(_S941)
        {
            _S942 = ((&hit_1)->instance_index) == (_S735.instance_index);
        }
        else
        {
            _S942 = false;
        }
        bool _S943;
        if(_S942)
        {
            _S943 = ((&hit_1)->triangle_index) == (_S735.triangle_index);
        }
        else
        {
            _S943 = false;
        }
        bool _S944;
        if(_S943)
        {
            _S944 = _S891;
        }
        else
        {
            _S944 = false;
        }
        bool _S945 = _slang_select(_S932, _S944,_S939);
        bool _S946;
        if(nee_0)
        {
            _S946 = _slang_select(replay_1, _S945,scatter_2);
        }
        else
        {
            _S946 = false;
        }
        TreeSample _S947 = TreeSample_x24init_0(_S718, _S718, 0.0f, 0U);
        float3  throughput_6;
        float3  lit_0;
        if(_S946)
        {
            float3  _S948 = (&ray_2)->origin;
            if(_S900)
            {
                throughput_6 = _S718;
            }
            else
            {
                throughput_6 = _S893.smooth_n;
            }
            FKSurface _S949 = surface_12;
            uint _S950 = stream(_S746, b_4 + 64U);
            uint _S951 = arrivalLobe_0(b_4, (&prev_0)->lobe);
            FKSurface _S952 = surface_12;
            FKHit _S953 = hit_1;
            ShadowContext _S954 = shadowContext_0(&_S952, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_4, _S951, (&hit_1)->distance, width_2, &_S953, _S900);
            ShadowContext _S955 = _S954;
            TreeSample _S956 = sampleLightTree_0(_S948, throughput_6, surface_12.geometry_n, surface_12.geometry_offset, _S905, _S950, &_S955);
            bool _S957 = any_0((_S956.radiance) != _S718);
            if(_S957)
            {
                if(_S900)
                {
                    uint _S958 = (fcptMaxBounces());
                    bool _S959 = b_4 < _S958;
                    FKSurface _S960 = surface_12;
                    TreeSample _S961 = _S956;
                    float3  _S962 = hairLight_0(&_S960, (&ray_2)->unit_direction, &_S961, _S959);
                    lit_0 = _S962;
                }
                else
                {
                    float _S963 = _S895.x;
                    float _S964 = _S895.y;
                    uint _S965 = (fcptMaxBounces());
                    bool _S966 = b_4 < _S965;
                    TreeSample _S967 = _S956;
                    BSDFMaterial _S968 = _S892.material;
                    float3  _S969 = lightBSDF_0((&ray_2)->unit_direction, &_S967, _S893.smooth_n, _S949.geometry_n, &_S968, _S963, _S964, _S966, surface_12.random_state);
                    lit_0 = _S969;
                }
            }
            else
            {
                lit_0 = _S718;
            }
            light_3 = _S956;
        }
        else
        {
            light_3 = _S947;
            lit_0 = _S718;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S970;
        bool _S971;
        float density_4;
        if(_S932)
        {
            bool _S972 = !_S891;
            if(_S972)
            {
                return _S719;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S940)
            {
                viewed_1 = _S724 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            if(_S940)
            {
                refracted_4 = _S724 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S973 = !nee_0;
                if(_S973)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S974 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S974 > 0.0f);
                }
                if(passes_0)
                {
                    return _S719;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            if(_S940)
            {
                wrong_side_0 = _S724 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S975 = !nee_0;
                if(_S975)
                {
                    return _S719;
                }
                float _S976 = environmentPdf_0(r_1->dir);
                float3  _S977 = skyBSDF((&ray_2)->unit_direction, r_1->dir, surface_12, _S895, is_inside_7, _S976, surface_12.random_state);
                return Shift_x24init_0(throughput_7 * _S977 * r_1->radiance / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            uint _S978 = extractBits_0(_S720, 21U, 1U);
            bool _S979 = nee_0 != (_S978 == 1U);
            if(_S979)
            {
                return _S719;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S933;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S980 = !scatter_2;
                if(_S980)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S981 = _S723 != 1U;
                    if(_S981)
                    {
                        refracted_4 = _S723 != 3U;
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
                bool _S982 = _S723 == 2U;
                if(_S982)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S891;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S724 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    uint _S983 = stream(_S746, b_4 + 448U);
                    FKRay _S984 = ray_2;
                    FKSurface _S985 = surface_12;
                    SkySample _S986 = sampleSky_0(&_S984, &_S985, _S895, is_inside_7, _S983, surface_12.random_state);
                    return Shift_x24init_0(throughput_5 * _S986.color, 1.0f);
                }
                if(_S982)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S891;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S987 = rgb_to_greyscale(light_3.radiance);
                    bool _S988 = !(_S987 > 0.0f);
                    if(_S988)
                    {
                        return _S719;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S733)
                {
                    passes_0 = _S724 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S859;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S733)
                {
                    passes_0 = _S724 == 1U;
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
                    passes_0 = !_S891;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S719;
            }
            else
            {
                if(_S909)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S989 = b_4 > 0U;
                    if(_S989)
                    {
                        Reservoir candidate_4 = chain_0;
                        if(_S923)
                        {
                            float3  _S990 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_4)->radiance = _S990;
                        }
                        else
                        {
                            if(_S891)
                            {
                                candidate_4 = here_0;
                            }
                        }
                        float3  _S991 = throughput_5 * emission_1;
                        Reservoir _S992 = withEnd(candidate_4, 1U, b_4, _S991);
                        offer(sel_1, _S992, _S991 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S993 = throughput_5 * emission_1;
                        float3  _S994 = sel_1->glow + _S993;
                        sel_1->glow = _S994;
                    }
                    if(nee_0)
                    {
                        float3  _S995 = throughput_5 * lit_0;
                        Reservoir candidate_5 = chain_0;
                        if(_S923)
                        {
                            float3  _S996 = safeDivide(_S995, chain_throughput_0);
                            (&candidate_5)->radiance = _S996;
                        }
                        else
                        {
                            if(_S891)
                            {
                                candidate_5 = here_0;
                                uint _S997 = insertBits_0((&candidate_5)->path, 1U, 21U, 1U);
                                (&candidate_5)->path = _S997;
                                (&candidate_5)->dir = light_3.dir;
                                (&candidate_5)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S998 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S999 = insertBits_0(_S998, 2U, 10U, 2U);
                                (&candidate_5)->path = _S999;
                            }
                        }
                        Reservoir _S1000 = withEnd(candidate_5, 0U, b_4, _S995);
                        offer(sel_1, _S1000, _S995 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S900)
                        {
                            _S970 = false;
                        }
                        else
                        {
                            bool _S1001 = environmentMapped_0();
                            _S970 = _S1001;
                        }
                    }
                    else
                    {
                        _S970 = false;
                    }
                    if(_S970)
                    {
                        uint _S1002 = (fcptMaxBounces());
                        _S971 = b_4 < _S1002;
                    }
                    else
                    {
                        _S971 = false;
                    }
                    if(_S971)
                    {
                        uint _S1003 = stream(_S746, b_4 + 448U);
                        FKRay _S1004 = ray_2;
                        FKSurface _S1005 = surface_12;
                        SkySample _S1006 = sampleSky_0(&_S1004, &_S1005, _S895, is_inside_7, _S1003, surface_12.random_state);
                        float3  _S1007 = throughput_5 * _S1006.color;
                        Reservoir candidate_6 = chain_0;
                        if(_S923)
                        {
                            float3  _S1008 = safeDivide(_S1007, chain_throughput_0);
                            (&candidate_6)->radiance = _S1008;
                        }
                        else
                        {
                            if(_S891)
                            {
                                candidate_6 = here_0;
                                uint _S1009 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1009;
                                (&candidate_6)->dir = _S1006.dir;
                                (&candidate_6)->radiance = _S1006.radiance;
                            }
                            else
                            {
                                uint _S1010 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S1011 = insertBits_0(_S1010, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1011;
                            }
                        }
                        Reservoir _S1012 = withEnd(candidate_6, 4U, b_4, _S1007);
                        offer(sel_1, _S1012, _S1007 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1013;
        bool _S1014;
        bool straight_0;
        bool _S1015;
        bool _S1016;
        bool _S1017;
        bool _S1018;
        bool _S1019;
        bool _S1020;
        bool _S1021;
        bool _S1022;
        bool _S1023;
        bool _S1024;
        bool _S1025;
        bool _S1026;
        bool _S1027;
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
                viewed_1 = _S933;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1028 = extractBits_0(_S720, 15U, 3U);
            uint _S1029 = extractBits_0(_S720, 18U, 3U);
            uint _S1030 = _slang_select(_S932, _S1029,_S1028);
            float3  _S1031 = r_1->dir;
            bool refracted_5 = _S1030 == 1U;
            SampleBSDF _S1032 = SampleBSDF_x24init_0(_S718, _S718, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1032;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1033 = extractBits_0(_S720, 22U, 1U);
                bool _S1034 = is_inside_7 != (_S1033 == 1U);
                if(_S1034)
                {
                    return _S719;
                }
                bool _S1035 = _S723 == 1U;
                if(_S1035)
                {
                    float3  _S1036 = (fcptHitPosition((_S735)));
                    throughput_8 = _S1036;
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
                    BSDFMaterial _S1037 = _S892.material;
                    bool _S1038 = isTranslucent_0(&_S1037);
                    if(_S1038)
                    {
                        refracted_4 = _S1030 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1039 = throughput_8 - (&ray_2)->origin;
                        float3  _S1040 = _slang_select(_S1035, _S1039,_S1031);
                        wrong_side_0 = (dot_0(_S893.smooth_n, _S1040) * _S894) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1035)
                {
                    float3  _S1041 = (&ray_2)->origin;
                    FKSurface _S1042 = surface_12;
                    float3  _S1043 = - _S893.smooth_n;
                    bool _S1044 = is_inside_7 != refracted_4;
                    float3  _S1045 = _slang_select(_S1044, _S1043,_S893.smooth_n);
                    float3  _S1046 = throughput_8 - (_S1041 + make_float3 (_S1042.geometry_offset) * _S1045);
                    float3  _S1047 = ((((_S1046)) * make_float3(rnorm3df(((_S1046)).x, ((_S1046)).y, ((_S1046)).z))));
                    reconnection_1 = _S1047;
                }
                else
                {
                    reconnection_1 = _S1031;
                }
                if(_S900)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1048 = wrongSide_0(is_inside_7, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1048;
                }
                if(wrong_side_0)
                {
                    return _S719;
                }
                float3  _S1049 = throughput_8;
                throughput_8 = reconnection_1;
                b_7 = _S1030;
                wrong_side_0 = false;
                reconnection_1 = _S1049;
            }
            else
            {
                bool _S1050 = !_S932;
                if(_S1050)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1051;
                    if(_S900)
                    {
                        SampleBSDF _S1052 = (fcptSampleHair((surface_12.hair), (_S892.material.albedo), (_S892.material.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1051 = _S1052;
                    }
                    else
                    {
                        SampleBSDF _S1053 = sampleBSDF((&ray_2)->unit_direction, _S893.smooth_n, _S892.material, _S895.x, _S895.y, surface_12.random_state, make_float2 (0.0f));
                        _S1051 = _S1053;
                    }
                    bsdf_sampled_0 = _S1051;
                    if(_S900)
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
                            return _S719;
                        }
                        break;
                    }
                    if(_S900)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1054 = wrongSide_0(is_inside_7, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1054;
                    }
                    if(wrong_side_0)
                    {
                        _S970 = (_S892.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S970 = false;
                    }
                    if(_S970)
                    {
                        SampleBSDF _S1055 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S892.material, _S895.x, _S895.y, (&bsdf_sampled_0)->random_state, make_float2 (0.0f));
                        (&bsdf_sampled_0)->unit_direction = _S1055.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1055.refracted;
                        (&bsdf_sampled_0)->throughput = _S1055.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1056 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1056;
                        }
                    }
                    uint _S1057 = (&bsdf_sampled_0)->lobe;
                    float3  _S1058 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1059 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1060 = (&bsdf_sampled_0)->pdf;
                    float _S1061 = _slang_select(wrong_side_0, 0.0f,_S1060);
                    (&lobe_5)->pdf = _S1061;
                    throughput_8 = _S1058;
                    b_7 = _S1057;
                    refracted_4 = _S1059;
                }
                else
                {
                    throughput_8 = _S1031;
                    b_7 = _S1030;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S970 = true;
            }
            else
            {
                _S970 = _S932;
            }
            float3  chain_throughput_1;
            if(_S970)
            {
                if(_S900)
                {
                    SampleBSDF _S1062 = (fcptConnectHair((surface_12.hair), (_S892.material.albedo), (_S892.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    lobe_5 = _S1062;
                }
                else
                {
                    float3  _S1063 = (&ray_2)->unit_direction;
                    float _S1064 = sign_0(_S894);
                    float3  _S1065 = _S893.smooth_n * make_float3 (_S1064);
                    float _S1066 = dot_0(_S1065, throughput_8);
                    float _S1067 = _S892.material.roughness;
                    float _S1068 = _S1067 * _S1067;
                    AnisotropicFrame _S1069 = anisotropicFrame(_S892.material, _S1065);
                    float3  _S1070 = reflectedHalf(_S1063, throughput_8);
                    bool _S1071 = b_7 == 1U;
                    if(_S1071)
                    {
                        float3  _S1072 = refractedHalf(_S1063, throughput_8, _S893.smooth_n, _S895.x, _S895.y);
                        throughput_9 = _S1072;
                    }
                    else
                    {
                        throughput_9 = _S1070;
                    }
                    bool _S1073 = b_7 == 0U;
                    if(_S1073)
                    {
                        float3  _S1074 = sampledHalf(_S1063, _S893.smooth_n, _S892.material, surface_12.random_state, _S1069);
                        throughput_10 = _S1074;
                    }
                    else
                    {
                        throughput_10 = throughput_9;
                    }
                    float3  _S1075 = negate_0(_S1063);
                    float _S1076 = _S895.x;
                    float _S1077 = _S895.y;
                    BSDFLobes _S1078 = bsdfLobes(_S1063, _S1075, _S1065, throughput_10, _S892.material, _S1076, _S1077, _S1069);
                    BSDFLobes lobe_terms_1 = _S1078;
                    float _S1079 = translucentShare(_S892.material);
                    (&lobe_terms_1)->translucent_share = _S1079;
                    switch(b_7)
                    {
                    case 0U:
                        {
                            float _S1080 = diffusePDF(_S1066, 0.0f, (F32_abs((_S894))), _S1068, lobe_terms_1, _S1076, _S1077);
                            float3  _S1081 = diffuseBSDF(throughput_8, _S1065, _S1068, _S892.material, lobe_terms_1);
                            density_6 = _S1080;
                            chain_throughput_1 = _S1081;
                            break;
                        }
                    case 1U:
                        {
                            float _S1082 = refractPDF(_S1066, dot_0(throughput_8, throughput_10), (F32_abs((_S894))), _S1068, lobe_terms_1, _S1076, _S1077);
                            float3  _S1083 = refractBSDF(throughput_8, _S1065, _S1068, _S892.material, lobe_terms_1);
                            density_6 = _S1082;
                            chain_throughput_1 = _S1083;
                            break;
                        }
                    case 4U:
                        {
                            float _S1084 = sheenVelvetPDF(_S1066, 0.0f, (F32_abs((_S894))), _S1068, lobe_terms_1, _S1076, _S1077);
                            float3  _S1085 = sheenVelvetBSDF(throughput_8, _S1065, _S1068, _S892.material, lobe_terms_1);
                            density_6 = _S1084;
                            chain_throughput_1 = _S1085;
                            break;
                        }
                    default:
                        {
                            float _S1086 = reflectPDF(_S1066, 0.0f, (F32_abs((_S894))), _S1068, lobe_terms_1, _S1076, _S1077);
                            float3  _S1087 = reflectBSDF(throughput_8, _S1065, _S1068, _S892.material, lobe_terms_1);
                            density_6 = _S1086;
                            chain_throughput_1 = _S1087;
                            break;
                        }
                    }
                    bool _S1088 = density_6 > 0.0f;
                    if(_S1088)
                    {
                        SampleBSDF _S1089 = SampleBSDF_x24init_0(throughput_8, chain_throughput_1, surface_12.random_state, _S1071, b_7, density_6);
                        lobe_5 = _S1089;
                    }
                }
            }
            bool _S1090 = b_7 == 0U;
            if(_S1090)
            {
                _S971 = true;
            }
            else
            {
                _S971 = b_7 == 4U;
            }
            if(_S900)
            {
                _S1013 = false;
            }
            else
            {
                bool _S1091 = !_S971;
                if(_S1091)
                {
                    bool _S1092 = (_S892.material.roughness) == 0.0f;
                    if(_S1092)
                    {
                        _S1013 = true;
                    }
                    else
                    {
                        bool _S1093 = b_7 == 1U;
                        if(_S1093)
                        {
                            _S1013 = (_S895.x) == (_S895.y);
                        }
                        else
                        {
                            _S1013 = false;
                        }
                    }
                }
                else
                {
                    _S1013 = false;
                }
            }
            bool _S1094 = !_S900;
            if(_S1094)
            {
                _S1014 = b_7 == 1U;
            }
            else
            {
                _S1014 = false;
            }
            if(_S1014)
            {
                straight_0 = (_S892.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1015 = _S1094;
            }
            else
            {
                _S1015 = false;
            }
            if(_S1015)
            {
                _S1016 = b_7 == 1U;
            }
            else
            {
                _S1016 = false;
            }
            if(_S1016)
            {
                _S1017 = (_S895.x) == (_S895.y);
            }
            else
            {
                _S1017 = false;
            }
            BSDFMaterial _S1095 = _S892.material;
            bool _S1096 = isTranslucent_0(&_S1095);
            if(_S1096)
            {
                _S1018 = _S1090;
            }
            else
            {
                _S1018 = false;
            }
            if(_S1018)
            {
                _S1019 = (dot_0(throughput_8, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1019 = false;
            }
            if(nee_0)
            {
                _S1020 = !_S1013;
            }
            else
            {
                _S1020 = false;
            }
            if(_S1020)
            {
                _S1021 = !wrong_side_0;
            }
            else
            {
                _S1021 = false;
            }
            if(_S1021)
            {
                float _S1097 = (&lobe_5)->pdf;
                float3  _S1098 = (&ray_2)->origin;
                float3  _S1099 = _slang_select(_S905, _S718,_S893.smooth_n);
                float3  _S1100 = (&ray_2)->origin;
                FKSurface _S1101 = surface_12;
                float3  _S1102 = - _S893.smooth_n;
                float3  _S1103 = _slang_select(_S1019, _S1102,_S893.smooth_n);
                NEEVertex _S1104 = NEEVertex_x24init_0(false, _S1097, _S1098, _S1099, _S1100 + make_float3 (_S1101.geometry_offset) * _S1103);
                nee_vertex_0 = _S1104;
            }
            else
            {
                if(_S900)
                {
                    _S1022 = true;
                }
                else
                {
                    bool _S1105 = b_7 != 1U;
                    if(_S1105)
                    {
                        _S1022 = true;
                    }
                    else
                    {
                        _S1022 = (_S895.x) != (_S895.y);
                    }
                }
                if(_S1022)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1106 = withinInverseFootprint((&lobe_5)->pdf, _S971, (&prev_0)->cos, (&hit_1)->distance, threshold_2);
            bool _S1107 = roughLobe((&lobe_5)->pdf, _S971, _S892.material.roughness);
            if(_S932)
            {
                bool _S1108 = !_S1106;
                if(_S1108)
                {
                    return _S719;
                }
                bool _S1109 = _S724 != 1U;
                if(_S1109)
                {
                    _S1022 = _S724 != 2U;
                }
                else
                {
                    _S1022 = false;
                }
                if(_S1022)
                {
                    float _S1110 = (&lobe_5)->pdf;
                    float _S1111 = _slang_select(nee_0, _S1110,0.0f);
                    float _S1112 = escapeWeight_0(_S1111, _S1031);
                    if(_S940)
                    {
                        passes_0 = _S730;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1113 = _slang_select(passes_0, _S1112,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_1->radiance * make_float3 (_S1113) / make_float3 (r_1->jac), density_4 * (&lobe_5)->pdf / r_1->jac);
                }
                float3  _S1114 = throughput_6 * make_float3 ((&lobe_5)->pdf);
                float _S1115 = density_4 * (&lobe_5)->pdf;
                throughput_9 = _S1114;
                density_6 = _S1115;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1116 = (fcptLayers((hit_1)));
            bool _S1117 = b_7 == 1U;
            bool _S1118 = passesLayer_0(_S1116, _S1117, passes_0);
            if(viewed_1)
            {
                _S1022 = _S1118;
            }
            else
            {
                _S1022 = false;
            }
            if(_S1022)
            {
                return _S719;
            }
            if(replay_1)
            {
                _S1023 = b_4 <= _S734;
            }
            else
            {
                _S1023 = false;
            }
            if(_S1023)
            {
                _S1024 = _S891;
            }
            else
            {
                _S1024 = false;
            }
            if(_S1024)
            {
                _S1025 = _S1106;
            }
            else
            {
                _S1025 = false;
            }
            if(_S1025)
            {
                _S1026 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1026 = !_S1107;
                }
                else
                {
                    _S1026 = false;
                }
            }
            if(_S1026)
            {
                return _S719;
            }
            if(viewed_1)
            {
                float3  _S1119 = throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1120 = (&lobe_5)->pdf;
                throughput_10 = _S1119;
                sky_pdf_2 = _S1120;
            }
            else
            {
                float3  _S1121 = throughput_9 * max_0((&lobe_5)->throughput, _S718);
                throughput_10 = _S1121;
                sky_pdf_2 = density_6;
            }
            if(_S909)
            {
                _S1027 = !_S923;
            }
            else
            {
                _S1027 = false;
            }
            bool _S1122;
            if(_S1027)
            {
                _S1122 = _S891;
            }
            else
            {
                _S1122 = false;
            }
            bool _S1123;
            if(_S1122)
            {
                _S1123 = _S1106;
            }
            else
            {
                _S1123 = false;
            }
            if(_S1123)
            {
                chain_0 = here_0;
                uint _S1124 = insertBits_0((&chain_0)->path, b_7, 18U, 3U);
                uint _S1125 = _slang_select(nee_0, 1U,0U);
                uint _S1126 = insertBits_0(_S1124, _S1125, 21U, 1U);
                (&chain_0)->path = _S1126;
                float _S1127 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1127;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1128 = surface_12;
            Vertex _S1129 = Vertex_x24init_0(_S1107, b_7, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_8)))), is_inside_7);
            prev_0 = _S1129;
            float _S1130 = (&lobe_5)->pdf;
            bool _S1131;
            if(_S1117)
            {
                _S1131 = (_S895.x) == (_S895.y);
            }
            else
            {
                _S1131 = false;
            }
            float sky_pdf_3 = _slang_select(_S1131, sky_pdf_0,_S1130);
            float _S1132 = _slang_select(_S900, 0.0f,sky_pdf_3);
            float _S1133 = widened_0(spread_1, (&lobe_5)->pdf, _S1013);
            bool _S1134;
            if(refracted_4)
            {
                _S1134 = !_S1019;
            }
            else
            {
                _S1134 = false;
            }
            bool is_inside_8;
            if(_S1134)
            {
                bool _S1135 = !is_inside_7;
                is_inside_8 = _S1135;
            }
            else
            {
                is_inside_8 = is_inside_7;
            }
            FKSurface _S1136 = surface_12;
            bool _S1137 = boundsVolume_0(&_S1136);
            bool _S1138;
            if(_S1137)
            {
                _S1138 = !_S1118;
            }
            else
            {
                _S1138 = false;
            }
            if(_S1138)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1139 = - _S1128.geometry_n;
                float3  _S1140 = _slang_select(turned_1, _S1139,_S1128.geometry_n);
                (&faced_2)->geometry_n = _S1140;
                FKMedium _S1141 = Medium_x24init_0(scatter_in_0, extinction_in_0);
                FKSurface _S1142 = faced_2;
                FKMedium _S1143 = _S1141;
                MediumSides _S1144 = mediumSides_0(&_S1142, &_S1143, filling_2, (&ray_2)->unit_direction);
                bool _S1145 = leavesInFront_0((&faced_2)->geometry_n, throughput_8, _S1128.geometry_n);
                float3  _S1146 = _slang_select(_S1145, _S1144.front.scatter,_S1144.behind.scatter);
                scatter_in_0 = _S1146;
                float3  _S1147 = _slang_select(_S1145, _S1144.front.extinction,_S1144.behind.extinction);
                extinction_in_0 = _S1147;
                uint _S1148 = _S1144.fillings.x;
                uint _S1149 = _S1144.fillings.y;
                uint _S1150 = _slang_select(_S1145, _S1149,_S1148);
                bool _S1151 = (fcptVaryingUsed());
                uint _S1152 = _slang_select(_S1151, _S1150,4294967295U);
                filling_2 = _S1152;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1153 = !_S1118;
            if(_S1153)
            {
                FKSurface _S1154 = surface_12;
                float _S1155 = _slang_select(straight_0, 0.0f,_S1154.geometry_offset);
                float3  _S1156 = - _S893.smooth_n;
                bool _S1157 = is_inside_8 != _S1019;
                float3  _S1158 = _slang_select(_S1157, _S1156,_S893.smooth_n);
                float3  _S1159 = (&ray_2)->origin + make_float3 (_S1155) * _S1158;
                (&ray_2)->origin = _S1159;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1118;
            viewed_1 = _S1017;
            sky_pdf_2 = _S1132;
            spread_4 = _S1133;
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
        if(_S909)
        {
            if(_S859)
            {
                float3  _S1160 = throughput_9 * emission_1;
                Reservoir candidate_7 = chain_0;
                uint _S1161 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1162 = _S1161 == 1U;
                if(_S1162)
                {
                    float3  _S1163 = safeDivide(_S1160, chain_throughput_0);
                    (&candidate_7)->radiance = _S1163;
                }
                Reservoir _S1164 = withEnd(candidate_7, 2U, b_4, _S1160);
                offer(sel_1, _S1164, _S1160 * make_float3 (scale_1) / make_float3 (density_6));
            }
            if(_S859)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1165 = survivalProbability(throughput_9, density_6);
                density_7 = _S1165;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1166 = stream(_S746, b_4 + 128U);
            Random _S1167 = pcg(_S1166);
            bool _S1168 = density_7 < (_S1167.value);
            if(_S1168)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1169 = (fcptMaxBounces());
                wrong_side_0 = b_4 >= _S1169;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1170 = density_6 * density_7;
            density_7 = _S1170;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1171 = layer_0 ^ 1U;
        uint _S1172 = _slang_select(passes_0, _S1171,0U);
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
            uint _S1173 = b_7 + 1U;
            b_4 = _S1173;
            layer_0 = _S1172;
            continue;
        }
        FKRay _S1174 = ray_2;
        float _S1175 = distance_5(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S933;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S723 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1176 = _slang_select(wrong_side_0, _S1175,4.294967296e+09f);
        bool _S1177 = !_S900;
        if(straight_0)
        {
            _S970 = true;
        }
        else
        {
            _S970 = _S900;
        }
        FKHit _S1178;
        if(_S970)
        {
            _S1178 = hit_1;
        }
        else
        {
            _S1178 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
        }
        FKHit _S1179 = (fcptTraverseInstanceBVH((_S1174), (_S867), (_S1176), (_S1177), (_S1178), (viewed_1)));
        hit_1 = _S1179;
        if(replay_1)
        {
            _S971 = _S933;
        }
        else
        {
            _S971 = false;
        }
        if(_S971)
        {
            _S1013 = _S723 == 1U;
        }
        else
        {
            _S1013 = false;
        }
        if(_S1013)
        {
            _S1014 = ((&hit_1)->instance_index) == (_S735.instance_index);
        }
        else
        {
            _S1014 = false;
        }
        if(_S1014)
        {
            _S1015 = ((&hit_1)->triangle_index) == (_S735.triangle_index);
        }
        else
        {
            _S1015 = false;
        }
        if(_S1015)
        {
            (&hit_1)->uv = _S735.uv;
            float _S1180 = distance_5(reconnection_0, (&ray_2)->origin);
            (&hit_1)->distance = _S1180;
        }
        if(replay_1)
        {
            _S1016 = _S933;
        }
        else
        {
            _S1016 = false;
        }
        if(_S1016)
        {
            _S1017 = _S723 == 3U;
        }
        else
        {
            _S1017 = false;
        }
        if(_S1017)
        {
            _S1018 = ((&hit_1)->instance_index) != 4294967295U;
        }
        else
        {
            _S1018 = false;
        }
        if(_S1018)
        {
            return _S719;
        }
        Reservoir _S1181 = chain_0;
        uint _S1182 = filling_2;
        for(;;)
        {
            bool _S1183 = (fcptVaryingUsed());
            if(_S1183)
            {
                _S1019 = _S1182 != 4294967295U;
            }
            else
            {
                _S1019 = false;
            }
            float _S1184;
            if(_S1019)
            {
                float _S1185 = (fcptMajorant((_S1182)));
                _S1184 = _S1185;
            }
            else
            {
                _S1184 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1020 = _S933;
            }
            else
            {
                _S1020 = false;
            }
            if(_S1020)
            {
                _S1021 = _S723 == 1U;
            }
            else
            {
                _S1021 = false;
            }
            if(_S1021)
            {
                _S1022 = _S1184 > 0.0f;
            }
            else
            {
                _S1022 = false;
            }
            if(_S1022)
            {
                ended_0 = _S719;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_3 = width_2;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_7 = b_4;
                _S1023 = true;
                break;
            }
            bool _S1186 = (&prev_0)->rough;
            if(_S1186)
            {
                _S1023 = !(_S1184 > 0.0f);
            }
            else
            {
                _S1023 = false;
            }
            (&prev_0)->rough = _S1023;
            uint _S1187 = b_4 + 320U;
            bool _S1188 = b_4 == 4294967295U;
            uint _S1189 = _slang_select(_S1188, 384U,_S1187);
            uint _S1190 = stream(_S746, _S1189);
            uint tracking_1 = _S1190;
            weight_1 = throughput_3;
            glowed_0 = _S718;
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
                    _S717 = int(2);
                    break;
                }
                uint _S1191 = b_7 + 320U;
                bool _S1192 = b_7 == 4294967295U;
                uint _S1193 = _slang_select(_S1192, 384U,_S1191);
                uint _S1194 = stream(_S746, _S1193);
                Random _S1195 = pcg(_S1194);
                float _S1196 = freeFlight_0(_S1195.value, _S1184);
                if(_S1019)
                {
                    float3  _S1197 = (&ray_2)->origin;
                    float3  _S1198 = (&ray_2)->unit_direction;
                    float _S1199 = (&hit_1)->distance;
                    uint _S1200 = _slang_select(_S1192, 0U,b_7);
                    uint _S1201 = (&prev_0)->lobe;
                    uint _S1202 = _slang_select(_S1192, 3U,_S1201);
                    float _S1203 = (fcptTrackMedium((_S1182), (_S1197), (_S1198), (_S1199), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S1200), (_S1202), (_S1192)));
                    spread_3 = _S1203;
                }
                else
                {
                    spread_3 = _S1196;
                }
                bool _S1204 = !(spread_3 < ((&hit_1)->distance));
                if(_S1204)
                {
                    _S717 = int(2);
                    break;
                }
                if(_S1019)
                {
                    _S1024 = _S909;
                }
                else
                {
                    _S1024 = false;
                }
                if(_S1024)
                {
                    float3  _S1205 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1206 = sel_1->glow + _S1205;
                    sel_1->glow = _S1206;
                }
                else
                {
                }
                glowed_0 = _S718;
                uint b_8 = b_7 + 1U;
                float3  _S1207 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1207;
                float3  _S1208 = flightWeight_0(scatter_in_0, extinction_in_0, _S1184, spread_3, true);
                float3  _S1209 = weight_1;
                float3  _S1210 = _slang_select(_S1019, _S1209,_S1208);
                float3  throughput_11 = throughput_10 * _S1210;
                uint _S1211 = stream(_S746, b_8 + 320U);
                tracking_1 = _S1211;
                weight_1 = throughput_3;
                float width_6 = width_3 + spread_2 * spread_3;
                float _S1212 = spread_2 + 3.14159274101257324f;
                bool _S1213 = scatterSampled_0(replay_1, b_8, _S734, _S1019);
                TreeSample light_4;
                if(_S1213)
                {
                    float3  _S1214 = (&ray_2)->origin;
                    float3  _S1215 = (&ray_2)->unit_direction;
                    float3  _S1216 = (&ray_2)->unit_direction;
                    uint _S1217 = stream(_S746, b_8 + 64U);
                    float3  _S1218 = extinction_in_0;
                    float3  _S1219 = extinction_in_0;
                    uint2  _S1220 = make_uint2 (_S1182);
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
                    light_4 = _S947;
                }
                uint _S1228 = (fcptMaxBounces());
                bool _S1229 = b_8 < _S1228;
                if(_S1229)
                {
                    _S1025 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1025 = false;
                }
                float _S1230 = _slang_select(_S1025, 0.07957746833562851f,0.0f);
                float3  _S1231 = throughput_11 * light_4.radiance;
                float _S1232 = powerHeuristic(light_4.density, _S1230);
                float3  _S1233 = _S1231 * make_float3 (0.07957746833562851f * _S1232);
                float3  _S1234 = _slang_select(_S1213, _S1233,_S718);
                if(replay_1)
                {
                    _S1026 = b_8 == _S734;
                }
                else
                {
                    _S1026 = false;
                }
                if(_S1026)
                {
                    bool _S1235 = _S723 == 2U;
                    if(_S1235)
                    {
                        float _S1236 = rgb_to_greyscale(_S1234);
                        _S1027 = _S1236 > 0.0f;
                    }
                    else
                    {
                        _S1027 = false;
                    }
                    if(_S1027)
                    {
                        Shift _S1237 = Shift_x24init_0(_S1234, 1.0f);
                        _S717 = int(1);
                        ended_0 = _S1237;
                        spread_3 = _S1212;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_5 = b_8;
                        break;
                    }
                    _S717 = int(1);
                    ended_0 = _S719;
                    spread_3 = _S1212;
                    width_4 = width_6;
                    throughput_8 = throughput_11;
                    b_5 = b_8;
                    break;
                }
                if(_S909)
                {
                    Reservoir candidate_8 = _S1181;
                    uint _S1238 = extractBits_0(_S1181.path, 10U, 2U);
                    bool _S1239 = _S1238 == 1U;
                    if(_S1239)
                    {
                        float3  _S1240 = safeDivide(_S1234, chain_throughput_0);
                        (&candidate_8)->radiance = _S1240;
                    }
                    else
                    {
                        uint _S1241 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                        uint _S1242 = insertBits_0(_S1241, 2U, 10U, 2U);
                        (&candidate_8)->path = _S1242;
                    }
                    Reservoir _S1243 = withEnd(candidate_8, 0U, b_8, _S1234);
                    offer(sel_1, _S1243, _S1234 * make_float3 (scale_1) / make_float3 (density_3));
                    float _S1244 = survivalProbability(throughput_11, density_3);
                    uint _S1245 = stream(_S746, b_8 + 128U);
                    Random _S1246 = pcg(_S1245);
                    bool _S1247 = _S1244 < (_S1246.value);
                    if(_S1247)
                    {
                        _S1027 = true;
                    }
                    else
                    {
                        uint _S1248 = (fcptMaxBounces());
                        _S1027 = b_8 >= _S1248;
                    }
                    if(_S1027)
                    {
                        _S717 = int(1);
                        ended_0 = _S719;
                        spread_3 = _S1212;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_5 = b_8;
                        break;
                    }
                    float _S1249 = density_3 * _S1244;
                    density_3 = _S1249;
                }
                else
                {
                }
                NEEVertex _S1250 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_2)->origin, _S718, (&ray_2)->origin);
                nee_vertex_0 = _S1250;
                uint _S1251 = stream(_S746, b_8);
                float3  _S1252 = isotropic_0(_S1251);
                (&ray_2)->unit_direction = _S1252;
                Vertex _S1253 = scatteredVertex_0(is_inside_6);
                prev_0 = _S1253;
                float _S1254 = (&prev_0)->pdf;
                FKRay _S1255 = ray_2;
                FKHit _S1256 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1257 = (fcptTraverseInstanceBVH((_S1255), (true), (4.294967296e+09f), (false), (_S1256), (false)));
                hit_1 = _S1257;
                b_7 = b_8;
                throughput_10 = throughput_11;
                spread_2 = _S1212;
                width_3 = width_6;
                sky_pdf_1 = _S1254;
            }
            if(_S717 != int(2))
            {
                spread_2 = spread_3;
                width_3 = width_4;
                throughput_10 = throughput_8;
                b_7 = b_5;
                _S1023 = true;
                break;
            }
            ended_0 = _S719;
            _S1023 = false;
            break;
        }
        if(_S1023)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1024 = b_7 == b_4;
        }
        else
        {
            _S1024 = false;
        }
        bool _S1258 = ((&hit_1)->instance_index) == 4294967295U;
        if(_S1258)
        {
            bool _S1259 = !(&nee_vertex_0)->none;
            float _S1260 = _slang_select(_S1259, sky_pdf_1,0.0f);
            float _S1261 = escapeWeight_0(_S1260, (&ray_2)->unit_direction);
            float3  _S1262 = environment_0((&ray_2)->unit_direction, b_7, (&prev_0)->lobe);
            float3  _S1263 = throughput_10 * _S1262;
            if(replay_1)
            {
                bool _S1264 = b_7 == _S734;
                if(_S1264)
                {
                    passes_0 = _S723 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1263 * make_float3 (_S1261) / make_float3 (r_1->jac), density_3 / r_1->jac);
                }
                if(_S733)
                {
                    passes_0 = _S730;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_7 == _S721;
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
                    return Shift_x24init_0(_S1263 * make_float3 (_S1261), 1.0f);
                }
                return _S719;
            }
            Reservoir candidate_9 = chain_0;
            uint _S1265 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1266 = _S1265 == 1U;
            if(_S1266)
            {
                uint _S1267 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1268 = _S1267 == b_7;
                float _S1269 = _slang_select(_S1268, 1.0f,_S1261);
                float3  _S1270 = safeDivide(_S1263 * make_float3 (_S1269), chain_throughput_0);
                (&candidate_9)->radiance = _S1270;
            }
            else
            {
                bool _S1271 = (&prev_0)->rough;
                if(_S1271)
                {
                    uint _S1272 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                    uint _S1273 = insertBits_0(_S1272, 3U, 10U, 2U);
                    uint _S1274 = insertBits_0(_S1273, (&prev_0)->lobe, 15U, 3U);
                    bool _S1275 = (&prev_0)->inside;
                    uint _S1276 = _slang_select(_S1275, 1U,0U);
                    uint _S1277 = insertBits_0(_S1274, _S1276, 22U, 1U);
                    (&candidate_9)->path = _S1277;
                    (&candidate_9)->jac = (&prev_0)->pdf;
                    (&candidate_9)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1278 = _S1263 * make_float3 (_S1261);
            Reservoir _S1279 = withEnd(candidate_9, 3U, b_7, _S1278);
            offer(sel_1, _S1279, _S1278 * make_float3 (scale_1) / make_float3 (density_3));
            break;
        }
        float3  _S1280 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1280;
        bool _S1281 = (fcptVaryingUsed());
        if(_S1281)
        {
            _S1025 = filling_2 != 4294967295U;
        }
        else
        {
            _S1025 = false;
        }
        if(_S1025)
        {
            if(_S909)
            {
                float3  _S1282 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1283 = sel_1->glow + _S1282;
                sel_1->glow = _S1283;
            }
            float3  _S1284 = throughput_10 * weight_1;
            throughput_8 = _S1284;
        }
        else
        {
            float3  _S1285 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
            float3  _S1286 = throughput_10 * _S1285;
            throughput_8 = _S1286;
        }
        float _S1287 = width_3 + spread_2 * (&hit_1)->distance;
        viewed_0 = _S1024;
        width_2 = _S1287;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1173 = b_7 + 1U;
        b_4 = _S1173;
        layer_0 = _S1172;
    }
    return _S719;
}

static __device__ Shift shift_0(Domain * dom_1, Reservoir * r_2)
{
    Selection _S1288 = (Selection{});
    Selection sel_2 = _S1288;
    bool _S1289 = (r_2->w) <= 0.0f;
    if(_S1289)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1290 = walk_0(dom_1, r_2, true, 0.0f, &sel_2);
    return _S1290;
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
    Random _S1291 = pcg(state_4);
    Random _S1292 = pcg(_S1291.state);
    float _S1293 = 6.28318548202514648f * _S1291.value;
    float _S1294 = (F32_sqrt((-2.0f * clamp_0((F32_log((_S1292.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1292.state, _S1294 * (F32_cos((_S1293))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S1295;
    (&_S1295)->state = state_5;
    (&_S1295)->value = value_2;
    return _S1295;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S1296 = normal_distribution(state_6);
    Random _S1297 = normal_distribution(_S1296.state);
    Random _S1298 = normal_distribution(_S1297.state);
    float3  _S1299 = make_float3 (_S1296.value, _S1297.value, _S1298.value);
    float3  _S1300 = ((((_S1299)) * make_float3(rnorm3df(((_S1299)).x, ((_S1299)).y, ((_S1299)).z))));
    return RandomSphere_x24init_0(_S1298.state, _S1300);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_12)
{
    float3  _S1301 = p1_0 - p0_0;
    float3  _S1302 = p2_0 - p0_0;
    float2  _S1303 = uv1_0 - uv0_0;
    float2  _S1304 = uv2_0 - uv0_0;
    float _S1305 = _S1303.x;
    float _S1306 = _S1304.y;
    float _S1307 = _S1303.y;
    float _S1308 = _S1304.x;
    float _S1309 = _S1305 * _S1306 - _S1307 * _S1308;
    float _S1310 = 1.0f / _S1309;
    float3  t_1 = (_S1301 * make_float3 (_S1306) - _S1302 * make_float3 (_S1307)) * make_float3 (_S1310);
    float3  _S1311 = (_S1302 * make_float3 (_S1305) - _S1301 * make_float3 (_S1308)) * make_float3 (_S1310);
    float3  _S1312 = t_1 - n_12 * make_float3 (dot_0(n_12, t_1));
    float3  t_2 = ((((_S1312)) * make_float3(rnorm3df(((_S1312)).x, ((_S1312)).y, ((_S1312)).z))));
    bool _S1313 = (dot_0(cross_0(n_12, t_2), _S1311)) > 0.0f;
    float3  t_3;
    if(_S1313)
    {
        float3  _S1314 = negate_0(t_2);
        t_3 = _S1314;
    }
    else
    {
        t_3 = t_2;
    }
    float3  _S1315 = cross_0(n_12, t_3);
    return makeMatrix<float, 3, 3> (t_3, _S1315, n_12);
}

__device__ float3  tangentToWorldNormalMap(float3  v_4, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_4, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1316 = t1_0 - t0_0;
    float3  _S1317 = t2_2 - t0_0;
    float3  _S1318 = t2_2 - t1_0;
    float _S1319 = (F32_min((length_0(_S1316)), ((F32_min((length_0(_S1317)), (length_0(_S1318)))))));
    float3  _S1320 = make_float3 (distance_5(position_0, t0_0), distance_5(position_0, t1_0), distance_5(position_0, t2_2));
    float3  _S1321 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1322 = dot_0(geometry_n_5, _S1321);
    float3  _S1323 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1324 = dot_0(geometry_n_5, _S1323);
    float3  _S1325 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1326 = acos_0(abs_0(make_float3 (_S1322, _S1324, dot_0(geometry_n_5, _S1325))));
    float3  _S1327 = clamp_1(tan_0(_S1326), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_0(dot_0(_S1320 * _S1327, uvw_0), 0.0f, _S1319 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_14, float3  n_13, BSDFMaterial material_20)
{
    float3  _S1328 = negate_0(dir_14);
    float _S1329 = sign_0(dot_0(n_13, _S1328));
    float3  _S1330 = n_13 * make_float3 (_S1329);
    AnisotropicFrame _S1331 = anisotropicFrame(material_20, _S1330);
    bool _S1332 = (_S1331.alphas.x) > 0.0f;
    if(_S1332)
    {
        float _S1333 = material_20.transmission * (1.0f - material_20.metallic);
        float3  _S1334 = negate_0(_S1330);
        float3  _S1335 = anisotropicLocal(dir_14, _S1331.tangent, _S1334);
        float _S1336 = anisotropicG1(_S1335, _S1331.alphas);
        return make_float3 (_S1333 * _S1336) * material_20.albedo;
    }
    float _S1337 = material_20.transmission * (1.0f - material_20.metallic);
    float _S1338 = material_20.roughness;
    float _S1339 = smithG1(_S1338 * _S1338, (F32_abs((dot_0(n_13, dir_14)))));
    return make_float3 (_S1337 * _S1339) * material_20.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_4, float3  out_dir_3, uint p_5, float w_2, float alpha_17, uint nt_0)
{
    uint _S1340 = p_5 % 4U;
    float _S1341 = w_2 * HAIR_WIDTHS_0[_S1340];
    float _S1342 = (F32_asin((clamp_0(dot_0(out_dir_3, t_4), -1.0f, 1.0f)))) - (F32_asin((clamp_0(dot_0(in_dir_11, t_4), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1340] * alpha_17;
    return ((F32_asinh((_S1342 / _S1341))) / (F32_asinh((3.14159274101257324f / _S1341))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_5, float3  out_dir_4, uint np_0)
{
    float3  _S1343 = worldToTangent(out_dir_4, t_5);
    float3  _S1344 = worldToTangent(in_dir_12, t_5);
    return (F32_frac((((F32_atan2((_S1343.z), (_S1343.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1344.z), (1.17549435082228751e-38f - _S1344.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_6, uint p_6, float row_0, float column_0, float w_3, float alpha_18, uint nt_1, uint np_1)
{
    float3  _S1345 = worldToTangent(in_dir_13, t_6);
    uint _S1346 = p_6 % 4U;
    float _S1347 = w_3 * HAIR_WIDTHS_0[_S1346];
    float _S1348 = (F32_asin((clamp_0(dot_0(in_dir_13, t_6), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1346] * alpha_18 + _S1347 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1347))))));
    float _S1349 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1345.z), (1.17549435082228751e-38f - _S1345.x)));
    float _S1350 = (F32_cos((_S1348)));
    float3  _S1351 = tangentToWorld(make_float3 (_S1350 * (F32_cos((_S1349))), (F32_sin((_S1348))), _S1350 * (F32_sin((_S1349)))), t_6);
    return _S1351;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_14, BSDFMaterial material_21, float coverage_1)
{
    float3  _S1352;
    if((material_21.ior) == 1.0f)
    {
        float3  _S1353 = straightThrough(toward_1, n_14, material_21);
        _S1352 = _S1353;
    }
    else
    {
        _S1352 = make_float3 (0.0f);
    }
    return _S1352 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_10 = r_3;
    float3  _S1354 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_10)->f = _S1354;
    float _S1355 = r_3.jac * shifted_0.jac;
    (&candidate_10)->jac = _S1355;
    offer(sel_3, candidate_10, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S1356 = rgb_to_greyscale((&r_4)->f);
    float _S1357 = sel_4.w_sum / _S1356;
    bool _S1358 = _S1356 > 0.0f;
    float _S1359 = _slang_select(_S1358, _S1357,0.0f);
    (&r_4)->w = _S1359;
    (&r_4)->c = c_1;
    return r_4;
}

static __device__ float interpolate_0(float a_6, float b_9, float t_7)
{
    return a_6 + (b_9 - a_6) * t_7;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S1360 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S1360;
}

__device__ float2  temporalWeights(float c_2, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S1361 = c_2 * p_c_0;
    float _S1362 = c_t_0 * p_t_0;
    return make_float2 (_S1361 / (_S1361 + c_t_0 * g_previous_0), _S1362 / (_S1362 + c_2 * g_current_0));
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
    Domain _S1363 = dom_2;
    Reservoir _S1364 = r_5;
    Shift _S1365 = walk_0(&_S1363, &_S1364, replay_2, scale_2, sel_5);
    return _S1365;
}

__device__ Shift shift_hook(Domain dom_3, Reservoir r_6)
{
    Domain _S1366 = dom_3;
    Reservoir _S1367 = r_6;
    Shift _S1368 = shift_0(&_S1366, &_S1367);
    return _S1368;
}

#undef Matrix
