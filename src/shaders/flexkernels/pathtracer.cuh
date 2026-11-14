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

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
{
    float3  a_2 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S171 = (F32_abs((dot_0(n_3, a_2)))) > 0.9999847412109375f;
    float3  a_3;
    if(_S171)
    {
        float3  _S172 = make_float3 (1.0f, 0.0f, 0.0f);
        a_3 = _S172;
    }
    else
    {
        a_3 = a_2;
    }
    float3  _S173 = cross_0(n_3, a_3);
    float3  _S174 = ((((_S173)) * make_float3(rnorm3df(((_S173)).x, ((_S173)).y, ((_S173)).z))));
    float3  _S175 = cross_0(n_3, _S174);
    return make_float3 (dot_0(v_1, _S174), dot_0(v_1, n_3), dot_0(v_1, _S175));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_2, float3  n_i_1, float alpha_1, AnisotropicFrame frame_0, uint * random_state_1)
{
    Random _S176 = pcg(*random_state_1);
    Random _S177 = pcg(_S176.state);
    *random_state_1 = _S177.state;
    float _S178 = frame_0.alphas.x;
    bool _S179 = _S178 > 0.0f;
    if(_S179)
    {
        float3  _S180 = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        float _S181 = frame_0.alphas.y;
        float3  _S182 = make_float3 (_S178 * _S180.x, _S181 * _S180.y, _S180.z);
        float3  _S183 = ((((_S182)) * make_float3(rnorm3df(((_S182)).x, ((_S182)).y, ((_S182)).z))));
        float3  _S184 = sampleGGXVNDF(_S183, 1.0f, _S176.value, _S177.value);
        float3  _S185 = make_float3 (_S178 * _S184.x, _S181 * _S184.y, _S184.z);
        float3  _S186 = ((((_S185)) * make_float3(rnorm3df(((_S185)).x, ((_S185)).y, ((_S185)).z))));
        return make_float3 (_S186.x) * frame_0.tangent + make_float3 (_S186.y) * cross_0(n_i_1, frame_0.tangent) + make_float3 (_S186.z) * n_i_1;
    }
    float3  _S187 = worldToTangent(v_2, n_i_1);
    float3  _S188 = sampleGGXVNDF(float3 {_S187.x, _S187.z, _S187.y}, alpha_1, _S176.value, _S177.value);
    float3  _S189 = float3 {_S188.x, _S188.z, _S188.y};
    float3  _S190 = tangentToWorld(_S189, n_i_1);
    return _S190;
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
    float _S191 = dot_0(n_4, i_1);
    float _S192 = 1.0f - eta_0 * eta_0 * (1.0f - _S191 * _S191);
    if(_S192 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_1 - make_float3 (eta_0 * _S191 + (F32_sqrt((_S192)))) * n_4;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S193 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S194 = eta_i_0 / eta_o_0 * _S193;
    bool _S195 = _S194 < 1.0f;
    float kr_0;
    if(_S195)
    {
        float _S196 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S194 * _S194))))));
        float _S197 = eta_o_0 * cos_theta_0;
        float _S198 = eta_i_0 * _S196;
        float _S199 = (_S197 - _S198) / (_S197 + _S198);
        float _S200 = eta_i_0 * cos_theta_0;
        float _S201 = eta_o_0 * _S196;
        float _S202 = (_S200 - _S201) / (_S200 + _S201);
        float _S203 = (_S199 * _S199 + _S202 * _S202) / 2.0f;
        kr_0 = _S203;
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
    float _S204 = (F32_sqrt((0.05000000074505806f)));
    float _S205 = clamp_0((F32_sqrt(((F32_max((mu_0), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
    float _S206 = (clamp_0((F32_sqrt(((F32_max((r_0), (0.0f)))))), _S204, 1.0f) - _S204) / (1.0f - _S204) * 23.0f;
    uint _S207 = (U32_min((uint(_S205)), (22U)));
    uint _S208 = (U32_min((uint(_S206)), (22U)));
    float _S209 = _S205 - float(_S207);
    float _S210 = _S206 - float(_S208);
    uint _S211 = _S207 * 24U + _S208;
    uint _S212 = _S211 + 24U;
    float _S213 = SHEEN_ALBEDO_0[_S211] + (SHEEN_ALBEDO_0[_S212] - SHEEN_ALBEDO_0[_S211]) * _S209;
    uint _S214 = _S211 + 1U;
    float _S215 = SHEEN_ALBEDO_0[_S214] + (SHEEN_ALBEDO_0[_S212 + 1U] - SHEEN_ALBEDO_0[_S214]) * _S209;
    return (F32_exp((_S213 + (_S215 - _S213) * _S210)));
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

__device__ float anisotropicG1(float3  w_1, float2  alphas_1)
{
    float _S216 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S216 / (_S216 + length_0(make_float3 (alphas_1.x * w_1.x, alphas_1.y * w_1.y, _S216)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S217 = alphas_2.x;
    float _S218 = h_0.x / _S217;
    float _S219 = alphas_2.y;
    float _S220 = h_0.y / _S219;
    float _S221 = h_0.z;
    float _S222 = _S218 * _S218 + _S220 * _S220 + _S221 * _S221;
    return 1.0f / (F32_max((3.14159274101257324f * _S217 * _S219 * _S222 * _S222), (1.17549435082228751e-38f)));
}

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_0, float3  refracted_1, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_0, float3  sheen_0, float3  view_0, float3  tangent_1, float2  alphas_3, float visible_0)
{
    BSDFLobes _S223;
    (&_S223)->v_dot_h = v_dot_h_0;
    (&_S223)->n_dot_h = n_dot_h_0;
    (&_S223)->refracted = refracted_1;
    (&_S223)->F = F_0;
    (&_S223)->F_greyscale = F_greyscale_0;
    (&_S223)->reflect_weight = reflect_weight_0;
    (&_S223)->diffuse_weight = diffuse_weight_0;
    (&_S223)->refract_weight = refract_weight_0;
    (&_S223)->p_diffuse = p_diffuse_0;
    (&_S223)->p_reflect = p_reflect_0;
    (&_S223)->p_refract = p_refract_0;
    (&_S223)->translucent_share = translucent_share_0;
    (&_S223)->sheen = sheen_0;
    (&_S223)->view = view_0;
    (&_S223)->tangent = tangent_1;
    (&_S223)->alphas = alphas_3;
    (&_S223)->visible = visible_0;
    return _S223;
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_0, float3  v_3, float3  n_i_2, float3  ggx_n_0, BSDFMaterial material_1, float eta_i_1, float eta_o_1, AnisotropicFrame frame_1)
{
    float _S224 = dot_0(ggx_n_0, v_3);
    float _S225 = dot_0(n_i_2, ggx_n_0);
    float _S226 = eta_i_1 / eta_o_1;
    float3  _S227 = refract_0(in_dir_0, ggx_n_0, _S226);
    float3  _S228 = ((((_S227)) * make_float3(rnorm3df(((_S227)).x, ((_S227)).y, ((_S227)).z))));
    float _S229 = (F32_min(((F32_sqrt((material_1.specular_level))) * (F32_abs((eta_i_1 - eta_o_1))) / (eta_i_1 + eta_o_1)), (0.9999847412109375f)));
    float _S230 = _S229 * _S229;
    float _S231 = (1.0f + _S229) / (1.0f - _S229);
    float _S232 = (F32_abs((_S224)));
    bool _S233 = eta_i_1 > eta_o_1;
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
    bool _S235 = (eta_i_1 * eta_i_1 * (1.0f - _S224 * _S224)) >= (eta_o_1 * eta_o_1);
    float3  _S236;
    if(_S235)
    {
        _S236 = make_float3 (1.0f);
    }
    else
    {
        float3  _S237 = material_1.specular_tint * make_float3 (_S230);
        _S236 = _S237 + (make_float3 (1.0f) - _S237) * make_float3 (_S234 - _S230) / make_float3 (1.0f - _S230);
    }
    float3  _S238 = make_float3 (1.0f);
    float3  _S239 = make_float3 (0.0f);
    float _S240 = rgb_to_greyscale(material_1.sheen);
    bool _S241 = _S240 > 0.0f;
    float3  scale_0;
    float3  sheen_1;
    float3  view_1;
    if(_S241)
    {
        float _S242 = sheenAlbedo(dot_0(n_i_2, v_3), material_1.sheen_roughness);
        float _S243 = (F32_min((_S242), (1.0f)));
        float3  _S244 = make_float3 (1.0f) - material_1.sheen * make_float3 (_S243);
        float _S245 = rgb_to_greyscale(material_1.sheen);
        float _S246 = _S245 * _S243;
        float3  _S247 = material_1.sheen / make_float3 ((F32_max((_S242), (1.0f))));
        scale_0 = _S244;
        sheen_component_0 = _S246;
        sheen_1 = _S247;
        view_1 = v_3;
    }
    else
    {
        scale_0 = _S238;
        sheen_component_0 = 0.0f;
        sheen_1 = _S239;
        view_1 = _S239;
    }
    float3  _S248 = mix_0(_S236, material_1.albedo, material_1.metallic);
    float3  F_1 = _S248 * scale_0;
    float _S249 = rgb_to_greyscale(F_1);
    float _S250 = 1.0f - material_1.metallic;
    float3  _S251 = make_float3 (1.0f) - _S236;
    float3  _S252 = make_float3 ((1.0f - material_1.transmission) * _S250) * _S251 * scale_0;
    float3  _S253 = make_float3 (material_1.transmission * _S250) * _S251 * scale_0;
    float _S254 = (F32_max((_S249), (0.0f)));
    float _S255 = rgb_to_greyscale(_S252);
    float _S256 = (F32_max((_S255), (0.0f)));
    float _S257 = rgb_to_greyscale(_S253);
    float _S258 = sign_0(length_0(_S228));
    float _S259 = (F32_max((_S257 * _S258), (0.0f)));
    float _S260 = _S254 + _S256 + _S259 + sheen_component_0;
    float _S261 = 1.0f / (F32_max((_S260), (0.0000152587890625f)));
    float _S262 = (_S256 + sheen_component_0) * _S261;
    float _S263 = _S254 * _S261;
    float _S264 = _S259 * _S261;
    bool _S265 = (frame_1.alphas.x) > 0.0f;
    if(_S265)
    {
        float3  _S266 = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        float _S267 = anisotropicG1(_S266, frame_1.alphas);
        float3  _S268 = anisotropicLocal(ggx_n_0, frame_1.tangent, n_i_2);
        float _S269 = anisotropicD(_S268, frame_1.alphas);
        float _S270 = _S267 * _S269;
        visible_1 = _S270;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S224, _S225, _S228, F_1, _S249, 1.0f, _S252, _S253, _S262, _S263, _S264, 0.0f, sheen_1, view_1, frame_1.tangent, frame_1.alphas, visible_1);
}

__device__ float translucentShare(BSDFMaterial material_2)
{
    float _S271 = rgb_to_greyscale(material_2.translucent);
    float _S272 = rgb_to_greyscale(material_2.albedo);
    float _S273 = _S271 / (_S272 + _S271);
    bool _S274 = _S271 > 0.0f;
    float _S275 = _slang_select(_S274, _S273,0.0f);
    return _S275;
}

__device__ float smithG1(float alpha_2, float n_dot_x_0)
{
    float _S276 = alpha_2 * alpha_2;
    float _S277 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S276 + (1.0f - _S276) * n_dot_x_0 * n_dot_x_0))));
    bool _S278 = alpha_2 > 0.0f;
    float _S279 = _slang_select(_S278, _S277,1.0f);
    return _S279;
}

__device__ float trowbridgeReitz(float alpha_3, float n_dot_h_1)
{
    float _S280 = alpha_3 * alpha_3;
    float _S281 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S280 * n_dot_h_1 * n_dot_h_1;
    return _S280 / (F32_max((3.14159274101257324f * _S281 * _S281), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, BSDFLobes lobes_0, float eta_i_2, float eta_o_2, uint lobe_0)
{
    bool _S282 = lobe_0 == 0U;
    if(_S282)
    {
        float _S283 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        float _S284 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
        float _S285 = 1.0f - lobes_0.translucent_share;
        bool _S286 = n_i_dot_l_0 < 0.0f;
        float _S287 = _slang_select(_S286, lobes_0.translucent_share,_S285);
        float _S288 = _S284 * _S287;
        bool _S289 = (lobes_0.translucent_share) > 0.0f;
        float _S290 = _slang_select(_S289, _S288,_S283);
        bool _S291 = n_i_dot_v_0 > 0.0f;
        float _S292 = _slang_select(_S291, _S290,0.0f);
        return _S292;
    }
    float _S293 = smithG1(alpha_4, n_i_dot_v_0);
    float _S294 = _S293 * lobes_0.v_dot_h;
    float _S295 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    float _S296 = _S294 * _S295 / n_i_dot_v_0;
    bool _S297 = alpha_4 > 0.0f;
    bool _S298;
    if(_S297)
    {
        _S298 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S298 = false;
    }
    if(_S298)
    {
        _S298 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S298 = false;
    }
    if(_S298)
    {
        _S298 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S298 = false;
    }
    float _S299 = _slang_select(_S298, _S296,0.0f);
    bool _S300 = (lobes_0.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S300)
    {
        float _S301 = lobes_0.visible * lobes_0.v_dot_h / n_i_dot_v_0;
        bool _S302 = (lobes_0.v_dot_h) > 0.0f;
        if(_S302)
        {
            _S298 = (lobes_0.n_dot_h) > 0.0f;
        }
        else
        {
            _S298 = false;
        }
        if(_S298)
        {
            _S298 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S298 = false;
        }
        float _S303 = _slang_select(_S298, _S301,0.0f);
        pdf_h_0 = _S303;
    }
    else
    {
        pdf_h_0 = _S299;
    }
    bool _S304 = lobe_0 == 1U;
    if(_S304)
    {
        float _S305 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        float _S306 = lobes_0.p_refract * pdf_h_0 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S305 * _S305);
        bool _S307 = eta_i_2 != eta_o_2;
        if(_S307)
        {
            _S298 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S298 = false;
        }
        float _S308 = _slang_select(_S298, _S306,0.0f);
        return _S308;
    }
    float _S309 = lobes_0.p_reflect * pdf_h_0 / (4.0f * lobes_0.v_dot_h);
    bool _S310 = pdf_h_0 > 0.0f;
    float _S311 = _slang_select(_S310, _S309,0.0f);
    return _S311;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_0, uint random_state_2, bool refracted_2, uint lobe_1, float pdf_0)
{
    SampleBSDF _S312;
    (&_S312)->unit_direction = unit_direction_1;
    (&_S312)->throughput = throughput_0;
    (&_S312)->random_state = random_state_2;
    (&_S312)->refracted = refracted_2;
    (&_S312)->lobe = lobe_1;
    (&_S312)->pdf = pdf_0;
    return _S312;
}

__device__ float sheenBRDF(float3  l_0, float3  v_4, float3  n_5, float r_1)
{
    float _S313 = 1.0f / (F32_max((r_1), (0.05000000074505806f)));
    float3  _S314 = l_0 + v_4;
    float3  _S315 = ((((_S314)) * make_float3(rnorm3df(((_S314)).x, ((_S314)).y, ((_S314)).z))));
    float _S316 = dot_0(n_5, _S315);
    float _S317 = (F32_max((dot_0(n_5, l_0)), (0.0f)));
    float _S318 = (F32_max((dot_0(n_5, v_4)), (0.0f)));
    return (2.0f + _S313) * (F32_pow(((F32_max((1.0f - _S316 * _S316), (0.0f)))), (0.5f * _S313))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S317 + _S318 - _S317 * _S318)), (0.0000152587890625f)));
}

__device__ __forceinline__ float3  lobeThroughput(float3  l_1, float3  n_i_3, float alpha_5, BSDFMaterial material_3, BSDFLobes lobes_1, uint lobe_2)
{
    bool _S319 = lobe_2 == 0U;
    if(_S319)
    {
        bool _S320 = (dot_0(n_i_3, l_1)) < 0.0f;
        float3  _S321 = _slang_select(_S320, material_3.translucent,material_3.albedo);
        float _S322 = 1.0f - lobes_1.translucent_share;
        float _S323 = _slang_select(_S320, lobes_1.translucent_share,_S322);
        float3  _S324 = _S321 / make_float3 (_S323);
        bool _S325 = (lobes_1.translucent_share) > 0.0f;
        float3  _S326 = _slang_select(_S325, _S324,material_3.albedo);
        float _S327 = rgb_to_greyscale(material_3.sheen);
        bool _S328 = _S327 > 0.0f;
        bool _S329;
        if(_S328)
        {
            _S329 = !_S320;
        }
        else
        {
            _S329 = false;
        }
        if(_S329)
        {
            float3  _S330 = lobes_1.diffuse_weight * _S326;
            float3  _S331 = lobes_1.sheen * make_float3 (3.14159274101257324f);
            float _S332 = sheenBRDF(l_1, lobes_1.view, n_i_3, material_3.sheen_roughness);
            float3  _S333 = _S331 * make_float3 (_S332);
            float _S334 = _slang_select(_S325, _S322,1.0f);
            return (_S330 + _S333 / make_float3 (_S334)) / make_float3 (lobes_1.p_diffuse);
        }
        return lobes_1.diffuse_weight * _S326 / make_float3 (lobes_1.p_diffuse);
    }
    bool _S335 = lobe_2 == 1U;
    float G1_l_0;
    if(_S335)
    {
        float _S336 = - dot_0(n_i_3, l_1);
        float _S337 = smithG1(alpha_5, (F32_max((_S336), (0.0f))));
        bool _S338 = (lobes_1.alphas.x) > 0.0f;
        if(_S338)
        {
            float3  _S339 = negate_0(n_i_3);
            float3  _S340 = anisotropicLocal(l_1, lobes_1.tangent, _S339);
            float _S341 = anisotropicG1(_S340, lobes_1.alphas);
            G1_l_0 = _S341;
        }
        else
        {
            G1_l_0 = _S337;
        }
        return lobes_1.refract_weight * make_float3 (G1_l_0) * material_3.albedo / make_float3 (lobes_1.p_refract);
    }
    float _S342 = dot_0(n_i_3, l_1);
    float _S343 = smithG1(alpha_5, (F32_max((_S342), (0.0f))));
    bool _S344 = (lobes_1.alphas.x) > 0.0f;
    if(_S344)
    {
        float3  _S345 = anisotropicLocal(l_1, lobes_1.tangent, n_i_3);
        float _S346 = anisotropicG1(_S345, lobes_1.alphas);
        G1_l_0 = _S346;
    }
    else
    {
        G1_l_0 = _S343;
    }
    return make_float3 (lobes_1.reflect_weight * G1_l_0) * lobes_1.F / make_float3 (lobes_1.p_reflect);
}

__device__ __forceinline__ SampleBSDF connectBSDF(float3  in_dir_1, float3  out_dir_0, float3  n_6, BSDFMaterial material_4, float eta_i_3, float eta_o_3, uint lobe_3, uint random_init_0)
{
    uint random_state_3 = random_init_0;
    float3  _S347 = negate_0(in_dir_1);
    float _S348 = dot_0(n_6, _S347);
    float _S349 = sign_0(_S348);
    float3  _S350 = n_6 * make_float3 (_S349);
    float _S351 = material_4.roughness;
    float _S352 = _S351 * _S351;
    AnisotropicFrame _S353 = anisotropicFrame(material_4, _S350);
    float3  _S354 = _S347 + out_dir_0;
    float3  _S355 = ((((_S354)) * make_float3(rnorm3df(((_S354)).x, ((_S354)).y, ((_S354)).z))));
    bool _S356 = lobe_3 == 0U;
    float3  ggx_n_1;
    if(_S356)
    {
        float3  _S357 = sampleHalfVector(_S347, _S350, _S352, _S353, &random_state_3);
        ggx_n_1 = _S357;
    }
    else
    {
        bool _S358 = lobe_3 == 1U;
        if(_S358)
        {
            float3  _S359 = negate_0(make_float3 (eta_i_3) * _S347 + make_float3 (eta_o_3) * out_dir_0);
            float3  _S360 = ((((_S359)) * make_float3(rnorm3df(((_S359)).x, ((_S359)).y, ((_S359)).z))));
            float _S361 = sign_0(dot_0(_S359, _S350));
            float3  _S362 = _S360 * make_float3 (_S361);
            ggx_n_1 = _S362;
        }
        else
        {
            ggx_n_1 = _S355;
        }
    }
    BSDFLobes _S363 = bsdfLobes(in_dir_1, _S347, _S350, ggx_n_1, material_4, eta_i_3, eta_o_3, _S353);
    BSDFLobes lobes_2 = _S363;
    float _S364 = translucentShare(material_4);
    (&lobes_2)->translucent_share = _S364;
    float _S365 = lobeDensity(dot_0(_S350, out_dir_0), dot_0(out_dir_0, ggx_n_1), (F32_abs((_S348))), _S352, lobes_2, eta_i_3, eta_o_3, lobe_3);
    bool _S366 = !(_S365 > 0.0f);
    if(_S366)
    {
        float3  _S367 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S367, _S367, 0U, false, 0U, 0.0f);
    }
    float3  _S368 = lobeThroughput(out_dir_0, _S350, _S352, material_4, lobes_2, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S368, random_state_3, lobe_3 == 1U, lobe_3, _S365);
}

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_2, float3  dir_3, float3  n_7, BSDFMaterial material_5, float eta_i_4, float eta_o_4, bool refracted_3, float pdf_1, bool power_0, uint random_state_4)
{
    float3  _S369 = make_float3 (0.0f);
    uint lobe_4 = 0U;
    float3  f_0 = _S369;
    for(;;)
    {
        if(lobe_4 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S370 = lobe_4 == 0U;
        if(_S370)
        {
        }
        bool _S371;
        if(_S370)
        {
            float _S372 = rgb_to_greyscale(material_5.translucent);
            _S371 = _S372 > 0.0f;
        }
        else
        {
            _S371 = false;
        }
        bool _S373;
        if(_S371)
        {
            float _S374 = dot_0(n_7, dir_3);
            float3  _S375 = negate_0(in_dir_2);
            _S373 = ((_S374 * dot_0(n_7, _S375)) < 0.0f) == refracted_3;
        }
        else
        {
            _S373 = (lobe_4 == 1U) == refracted_3;
        }
        float3  f_1;
        if(_S373)
        {
            SampleBSDF _S376 = connectBSDF(in_dir_2, dir_3, n_7, material_5, eta_i_4, eta_o_4, lobe_4, random_state_4);
            bool _S377 = (_S376.pdf) > 0.0f;
            if(_S377)
            {
                if(power_0)
                {
                    float _S378 = _S376.pdf / pdf_1;
                    float3  f_2 = f_0 + _S376.throughput * make_float3 (_S376.pdf) / make_float3 (pdf_1 * (1.0f + _S378 * _S378));
                    f_1 = f_2;
                }
                else
                {
                    float3  f_3 = f_0 + _S376.throughput * make_float3 (_S376.pdf) / make_float3 (_S376.pdf + pdf_1);
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
    bool _S379 = wrongSide_0(is_inside_2, false, dir_4, surface_1.geometry_n);
    float3  _S380 = neeBSDF(in_dir_3, dir_4, surface_1.smooth_n, surface_1.material, eta_1.x, eta_1.y, _S379, pdf_2, false, random_state_5);
    return _S380;
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
    SkySample _S381;
    (&_S381)->dir = dir_5;
    (&_S381)->radiance = radiance_0;
    (&_S381)->color = color_0;
    (&_S381)->random_state = random_state_6;
    return _S381;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0)
{
    uint2  _S382 = (fcptEnvironmentCdfSize());
    uint2  _S383 = make_uint2 (1U, 0U);
    uint2  _S384 = _S382 - _S383;
    Random _S385 = pcg(init_random_state_0);
    Random _S386 = pcg(_S385.state);
    Random _S387 = pcg(_S386.state);
    Random _S388 = pcg(_S387.state);
    uint _S389 = _S384.x;
    uint _S390 = searchCDF_0(make_uint2 (_S389, 0U), make_uint2 (0U, 1U), _S384.y, _S385.value);
    uint _S391 = searchCDF_0(make_uint2 (0U, _S390), _S383, _S389, _S386.value);
    float2  _S392 = make_float2 ((float)_S384.x, (float)_S384.y);
    float2  _S393 = (make_float2 (float(_S391), float(_S390)) + make_float2 (_S387.value, _S388.value)) / _S392 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S394 = _S393.y;
    float _S395 = (F32_sin((_S394)));
    float _S396 = _S393.x;
    float3  _S397 = make_float3 (_S395 * (F32_cos((_S396))), (F32_cos((_S394))), _S395 * (F32_sin((_S396))));
    float _S398 = environmentPdf_0(_S397);
    float3  _S399 = skyBSDF(ray_0->unit_direction, _S397, *surface_2, eta_2, is_inside_3, _S398, lobe_state_0);
    bool _S400 = !(_S398 > 0.0f);
    bool _S401;
    if(_S400)
    {
        _S401 = true;
    }
    else
    {
        _S401 = all_0(_S399 == make_float3 (0.0f));
    }
    if(_S401)
    {
        float3  _S402 = make_float3 (0.0f);
        return SkySample_x24init_0(_S397, _S402, _S402, _S388.state);
    }
    float3  _S403 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S397);
    return SkySample_x24init_0(_S397, _S403, _S399 * _S403, _S388.state);
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
    SampleBSDF _S404 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_4), (light_1->dir)));
    float3  _S405 = _S404.throughput * make_float3 (_S404.pdf);
    float _S406 = light_1->density;
    float _S407 = 1.0f + _S404.pdf * _S404.pdf / (light_1->density * light_1->density);
    bool _S408;
    if(competing_0)
    {
        _S408 = _S406 > 0.0f;
    }
    else
    {
        _S408 = false;
    }
    float _S409 = _slang_select(_S408, _S407,1.0f);
    return _S405 / make_float3 (_S409) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_7)
{
    TreeSample _S410;
    (&_S410)->dir = dir_6;
    (&_S410)->radiance = radiance_1;
    (&_S410)->density = density_0;
    (&_S410)->random_state = random_state_7;
    return _S410;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_3, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S411 = importance(first_1, p_3, normal_3);
    float _S412 = importance(second_1, p_3, normal_3);
    float2  _S413 = make_float2 (_S411, _S412);
    bool _S414 = _S411 == 0.0f;
    bool _S415;
    if(_S414)
    {
        _S415 = _S412 == 0.0f;
    }
    else
    {
        _S415 = false;
    }
    if(_S415)
    {
        return 2U;
    }
    float _S416 = _S411 + _S412;
    bool _S417 = _S412 > 0.0f;
    if(_S417)
    {
        _S415 = (*pick_0 * _S416) >= _S411;
    }
    else
    {
        _S415 = false;
    }
    uint _S418 = uint(_S415);
    float _S419 = (F32_min(((*pick_0 * _S416 - float(_S418) * _S411) / _slang_vector_get_element(_S413, _S418)), (0.99999994039535522f)));
    *pick_0 = _S419;
    float _S420 = *probability_3 * (_slang_vector_get_element(_S413, _S418) / _S416);
    *probability_3 = _S420;
    return _S418;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_4, float u1_0, float u2_0)
{
    float3  _S421 = center_1 - p_4;
    float _S422 = radius_1 * radius_1 / dot_0(_S421, _S421);
    float _S423 = u1_0 * _S422 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S422), (0.0f)))))));
    float _S424 = 2.0f * u1_0;
    bool _S425 = _S422 >= 1.0f;
    float _S426 = _slang_select(_S425, _S424,_S423);
    float _S427 = (F32_sqrt(((F32_max((_S426 * (2.0f - _S426)), (0.0f))))));
    float _S428 = 6.28318548202514648f * u2_0;
    float3  _S429 = make_float3 (_S427 * (F32_cos((_S428))), 1.0f - _S426, _S427 * (F32_sin((_S428))));
    float3  _S430 = ((((_S421)) * make_float3(rnorm3df(((_S421)).x, ((_S421)).y, ((_S421)).z))));
    float3  _S431 = tangentToWorld(_S429, _S430);
    return _S431;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S432 = center_2 - ray_1->origin;
    float _S433 = dot_0(_S432, ray_1->unit_direction);
    float _S434 = dot_0(_S432, _S432) - _S433 * _S433;
    float _S435 = radius_3 * radius_3;
    bool _S436 = _S434 > _S435;
    if(_S436)
    {
        return 4.294967296e+09f;
    }
    float _S437 = (F32_sqrt((_S435 - _S434)));
    float _S438 = _S433 - _S437;
    float _S439 = _S433 + _S437;
    bool _S440 = _S438 > 0.0000152587890625f;
    bool _S441;
    if(_S440)
    {
        _S441 = _S438 < max_len_0;
    }
    else
    {
        _S441 = false;
    }
    if(_S441)
    {
        return _S438;
    }
    bool _S442 = _S439 > 0.0000152587890625f;
    if(_S442)
    {
        _S441 = _S439 < max_len_0;
    }
    else
    {
        _S441 = false;
    }
    if(_S441)
    {
        return _S439;
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
    Random _S443 = pcg(init_random_state_1);
    Random _S444 = pcg(_S443.state);
    Random _S445 = pcg(_S444.state);
    float3  _S446 = make_float3 (0.0f);
    TreeSample _S447 = TreeSample_x24init_0(_S446, _S446, 0.0f, _S445.state);
    TreeSample sample_0 = _S447;
    float3  _S448 = _slang_select(sided_0, _S446,smooth_n_2);
    float3  _S449 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S443.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S450 = (fcptLightNode((n_8)));
        if((_S450.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S451 = (fcptLightSecond((n_8)));
        uint _S452 = n_8 + 1U;
        LightNode _S453 = (fcptLightBounds((_S452)));
        LightNode _S454 = (fcptLightBounds((_S451)));
        uint _S455 = pickChild(_S453, _S454, origin_4, _S448, &pick_1, &probability_4);
        bool _S456 = _S455 > 1U;
        if(_S456)
        {
            return sample_0;
        }
        bool _S457 = _S455 == 1U;
        uint _S458 = _slang_select(_S457, _S451,_S452);
        n_8 = _S458;
    }
    bool _S459 = n_8 == 0U;
    bool _S460;
    if(_S459)
    {
        LightNode _S461 = (fcptLightBounds((0U)));
        float _S462 = importance(_S461, origin_4, _S448);
        _S460 = !(_S462 > 0.0f);
    }
    else
    {
        _S460 = false;
    }
    if(_S460)
    {
        return sample_0;
    }
    uint4  _S463 = (fcptLightNode((n_8)));
    FKHit _S464 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S465 = (_S463.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S465)
    {
        FKLight _S466 = (fcptLight((_S463.y)));
        if(sided_0)
        {
            float _S467 = sign_0(dot_0(geometry_n_1, _S466.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S467);
            float3  _S468 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S468;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S449;
            lift_n_0 = smooth_n_2;
        }
        bool _S469 = (_S466.variance) == 0.0f;
        if(_S469)
        {
            float3  _S470 = _S466.position - emitter_point_0;
            float3  _S471 = ((((_S470)) * make_float3(rnorm3df(((_S470)).x, ((_S470)).y, ((_S470)).z))));
            (&sample_0)->dir = _S471;
            float3  _S472 = _S466.color * make_float3 (_S466.intensity) / make_float3 (dot_0(_S470, _S470) * probability_4);
            (&sample_0)->radiance = _S472;
            shadow_1 = _S470;
        }
        else
        {
            float3  _S473 = sampleSphere(_S466.position, _S466.variance, emitter_point_0, _S444.value, _S445.value);
            (&sample_0)->dir = _S473;
            float _S474 = sphereDensity(_S466.position, _S466.variance, emitter_point_0);
            float _S475 = probability_4 * _S474;
            (&sample_0)->density = _S475;
            float3  _S476 = pointLightRadiance(_S466.color, _S466.intensity, _S466.variance);
            float3  _S477 = _S476 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S477;
            FKRay _S478 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S479 = raySphere_0(_S466.position, _S466.variance, &_S478, 4.294967296e+09f);
            float3  _S480 = (&sample_0)->dir * make_float3 (_S479);
            shadow_1 = _S480;
        }
        emitter_0 = _S464;
        emitter_point_0 = _S446;
    }
    else
    {
        uint _S481 = _S463.y;
        uint _S482 = (fcptTriangleOffset((_S481)));
        uint _S483 = _S482 + _S463.z;
        Matrix<float, 3, 3>  _S484 = (fcptWorldTriangle((_S481), (_S483)));
        float _S485 = (F32_sqrt((_S444.value)));
        float2  _S486 = make_float2 (_S485 * (1.0f - _S445.value), _S485 * _S445.value);
        float3  _S487 = mul_0(make_float3 (1.0f - _S485, _S486.x, _S486.y), _S484);
        if(sided_0)
        {
            float _S488 = sign_0(dot_0(geometry_n_1, _S487 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S488);
            float3  _S489 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S489;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S490 = !((dot_0(smooth_n_2, _S487 - origin_4)) > 0.0f);
            if(_S490)
            {
                return sample_0;
            }
            emitter_point_0 = _S449;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S486, _S481, _S483, 0U, 0.0f);
        float3  _S491 = _S487 - emitter_point_0;
        float3  _S492 = ((((_S491)) * make_float3(rnorm3df(((_S491)).x, ((_S491)).y, ((_S491)).z))));
        (&sample_0)->dir = _S492;
        float _S493 = solidAngle(probability_4, cross_0(_S484.rows[int(1)] - _S484.rows[int(0)], _S484.rows[int(2)] - _S484.rows[int(0)]), _S491);
        (&sample_0)->density = _S493;
        bool _S494 = (fcptShadowFirst());
        bool _S495 = !_S494;
        if(_S495)
        {
            FKSurface _S496 = (fcptLightSurfaceAt((emitter_1), (_S487), (_S445.state), ((&sample_0)->dir), (context_1->depth), (length_0(_S487 - origin_4))));
            (&sample_0)->random_state = _S496.random_state;
            float3  _S497 = _slang_select(_S496.skip, _S446,_S496.material.emissive);
            float3  _S498 = _S497 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S498;
        }
        shadow_1 = _S491;
        emitter_0 = emitter_1;
        emitter_point_0 = _S487;
    }
    FKHit _S499 = emitter_0;
    float3  _S500 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_1, _S445.state, &_S499);
    bool _S501 = (fcptShadowFirst());
    if(_S501)
    {
        _S460 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S460 = false;
    }
    if(_S460)
    {
        _S460 = !all_0(_S500 == _S446);
    }
    else
    {
        _S460 = false;
    }
    if(_S460)
    {
        FKSurface _S502 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S445.state), ((&sample_0)->dir), (context_1->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S502.random_state;
        float3  _S503 = _slang_select(_S502.skip, _S446,_S502.material.emissive);
        float3  _S504 = _S503 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S504;
    }
    float3  _S505 = (&sample_0)->radiance * _S500;
    bool _S506 = all_0(_S500 == _S446);
    float3  _S507 = _slang_select(_S506, _S446,_S505);
    (&sample_0)->radiance = _S507;
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
    float _S508 = 1.0f / (1.0f + b_0 / a_4 * (b_0 / a_4));
    bool _S509 = b_0 > 0.0f;
    float _S510 = _slang_select(_S509, _S508,1.0f);
    return _S510;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_0, float3  light_point_1)
{
    bool _S511 = vertex_0->none;
    if(_S511)
    {
        return 1.0f;
    }
    uint _S512 = (fcptLightSlot((*hit_0)));
    float _S513 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S512, light_point_1);
    float _S514 = powerHeuristic(vertex_0->pdf, _S513);
    return _S514;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_6)
{
    uint2  _S515 = (fcptEnvironmentMapSize());
    bool _S516 = (_S515.x) > 1U;
    bool _S517;
    if(_S516)
    {
        uint2  _S518 = (fcptEnvironmentMapSize());
        _S517 = (_S518.y) > 1U;
    }
    else
    {
        _S517 = false;
    }
    if(_S517)
    {
        float3  _S519 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_6)));
        return _S519;
    }
    float3  _S520 = (fcptAmbient());
    return _S520;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S521 = (fcptEnvironmentCdfSize());
    bool _S522 = (_S521.x) > 1U;
    bool _S523;
    if(_S522)
    {
        uint2  _S524 = (fcptEnvironmentCdfSize());
        _S523 = (_S524.y) > 1U;
    }
    else
    {
        _S523 = false;
    }
    bool _S525 = !_S523;
    if(_S525)
    {
        return false;
    }
    uint2  _S526 = (fcptEnvironmentMapSize());
    bool _S527 = (_S526.x) > 1U;
    if(_S527)
    {
        uint2  _S528 = (fcptEnvironmentMapSize());
        _S523 = (_S528.y) > 1U;
    }
    else
    {
        _S523 = false;
    }
    return _S523;
}

static __device__ float escapeWeight_0(float pdf_3, float3  dir_8)
{
    bool _S529 = pdf_3 <= 0.0f;
    bool _S530;
    if(_S529)
    {
        _S530 = true;
    }
    else
    {
        bool _S531 = environmentMapped_0();
        _S530 = !_S531;
    }
    if(_S530)
    {
        return 1.0f;
    }
    float _S532 = environmentPdf_0(dir_8);
    return pdf_3 / (pdf_3 + _S532);
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
    Shift _S533;
    (&_S533)->f = f_4;
    (&_S533)->jac = jac_0;
    return _S533;
}

static __device__ uint extractBits_0(uint e_1, uint offset_0, uint count_1)
{
    return (e_1 >> offset_0) & ((1U << count_1) - 1U);
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_2)
{
    NEEVertex _S534;
    (&_S534)->none = none_0;
    (&_S534)->pdf = pdf_4;
    (&_S534)->origin = origin_5;
    (&_S534)->smooth_n = smooth_n_3;
    (&_S534)->start = start_2;
    return _S534;
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
    Vertex _S535;
    (&_S535)->rough = rough_0;
    (&_S535)->lobe = lobe_7;
    (&_S535)->pdf = pdf_5;
    (&_S535)->cos = cos_0;
    (&_S535)->inside = inside_0;
    return _S535;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S536 = hash(index_0);
    uint _S537 = hash(seed_0 ^ _S536);
    return _S537;
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
    float3  _S538 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_1));
    float3  _S539 = scatter_0 * _S538 / make_float3 (sigma_1);
    float3  _S540 = _slang_select(scatters_0, _S539,_S538);
    return _S540;
}

static __device__ bool scatterSampled_0(bool replay_0, uint b_1, uint stop_0, bool varying_0)
{
    bool _S541 = !replay_0;
    bool _S542;
    if(_S541)
    {
        _S542 = true;
    }
    else
    {
        bool _S543 = b_1 == stop_0;
        if(_S543)
        {
            _S542 = !varying_0;
        }
        else
        {
            _S542 = false;
        }
    }
    return _S542;
}

static __device__ uint arrivalLobe_0(uint b_2, uint prev_lobe_0)
{
    bool _S544 = b_2 > 0U;
    uint _S545 = _slang_select(_S544, prev_lobe_0,3U);
    return _S545;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_8, bool surface_4, float length_2, float width_0, FKHit * own_0, bool fiber_0)
{
    ShadowContext _S546;
    (&_S546)->extinction_behind = extinction_behind_0;
    (&_S546)->extinction_front = extinction_front_0;
    (&_S546)->fillings = fillings_0;
    (&_S546)->side = side_0;
    (&_S546)->depth = depth_1;
    (&_S546)->lobe = lobe_8;
    (&_S546)->surface = surface_4;
    (&_S546)->length = length_2;
    (&_S546)->width = width_0;
    (&_S546)->own = *own_0;
    (&_S546)->fiber = fiber_0;
    return _S546;
}

__device__ float3  safeDivide(float3  a_5, float3  b_3)
{
    float3  _S547 = a_5 / b_3;
    float3  _S548 = make_float3 (0.0f);
    bool3  _S549 = b_3 == _S548;
    float3  _S550 = _slang_select(_S549, _S548,_S547);
    return _S550;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S551 = (1U << count_2) - 1U;
    return (e_2 & (~(_S551 << offset_1))) | ((newbits_0 & _S551) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_0 = r_2;
    uint _S552 = insertBits_0(r_2.path, end_0, 0U, 5U);
    uint _S553 = insertBits_0(_S552, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S553;
    (&candidate_0)->f = f_5;
    return candidate_0;
}

__device__ void offer(Selection * sel_0, Reservoir candidate_1, float3  weight_0)
{
    float _S554 = rgb_to_greyscale(weight_0);
    bool _S555 = _S554 > 0.0f;
    bool _S556;
    if(_S555)
    {
        _S556 = _S554 < 3.00000000549775576e+38f;
    }
    else
    {
        _S556 = false;
    }
    bool _S557 = !_S556;
    if(_S557)
    {
        return;
    }
    bool _S558 = sel_0->sums;
    if(_S558)
    {
        float3  _S559 = sel_0->color + weight_0;
        sel_0->color = _S559;
        return;
    }
    float _S560 = sel_0->w_sum + _S554;
    sel_0->w_sum = _S560;
    float3  _S561 = sel_0->color + weight_0;
    sel_0->color = _S561;
    Random _S562 = pcg(sel_0->random_state);
    sel_0->random_state = _S562.state;
    bool _S563 = (_S562.value * sel_0->w_sum) <= _S554;
    if(_S563)
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
    Random _S564 = pcg(random_state_8);
    Random _S565 = pcg(_S564.state);
    float _S566 = 1.0f - 2.0f * _S564.value;
    float _S567 = (F32_sqrt(((F32_max((1.0f - _S566 * _S566), (0.0f))))));
    float _S568 = 6.28318548202514648f * _S565.value;
    return make_float3 (_S567 * (F32_cos((_S568))), _S567 * (F32_sin((_S568))), _S566);
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2)
{
    BSDFMaterial _S569;
    (&_S569)->albedo = albedo_0;
    (&_S569)->emissive = emissive_0;
    (&_S569)->roughness = roughness_0;
    (&_S569)->metallic = metallic_0;
    (&_S569)->transmission = transmission_0;
    (&_S569)->ior = ior_0;
    (&_S569)->absorption = absorption_0;
    (&_S569)->specular_tint = specular_tint_0;
    (&_S569)->specular_level = specular_level_0;
    (&_S569)->translucent = translucent_0;
    (&_S569)->sheen = sheen_2;
    (&_S569)->sheen_roughness = sheen_roughness_0;
    (&_S569)->anisotropy = anisotropy_0;
    (&_S569)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S569)->tangent = tangent_2;
    return _S569;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1)
{
    FKMedium _S570;
    (&_S570)->scatter = scatter_1;
    (&_S570)->extinction = extinction_1;
    return _S570;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_6, bool skip_0, uint random_state_9, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S571;
    (&_S571)->smooth_n = smooth_n_4;
    (&_S571)->geometry_n = geometry_n_2;
    (&_S571)->geometry_offset = geometry_offset_2;
    (&_S571)->material = *material_6;
    (&_S571)->skip = skip_0;
    (&_S571)->random_state = random_state_9;
    (&_S571)->coverage = coverage_0;
    (&_S571)->encloses = encloses_0;
    (&_S571)->volume = *volume_0;
    (&_S571)->fills = fills_0;
    (&_S571)->hair = hair_0;
    return _S571;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S572 = (&surface_5->material)->emissive;
    float3  _S573 = make_float3 (0.0f);
    bool _S574 = !top_0;
    float3  _S575 = _slang_select(_S574, _S573,_S572);
    (&(&lower_0)->material)->emissive = _S575;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_2)
{
    float _S576 = surface_6->coverage;
    bool _S577 = u_2 < _S576;
    if(_S577)
    {
        return *surface_6;
    }
    float3  _S578 = make_float3 (0.0f);
    float3  _S579 = make_float3 (1.0f);
    BSDFMaterial _S580 = Material_x24init_0(_S578, _S578, 0.0f, 0.0f, 0.0f, 0.0f, _S578, _S579, 1.0f, _S578, _S578, 0.5f, 0.0f, 0.0f, _S578);
    BSDFMaterial material_7 = _S580;
    (&material_7)->albedo = _S579;
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
    bool _S581 = transmission_1 > 0.0f;
    bool _S582;
    if(_S581)
    {
        _S582 = true;
    }
    else
    {
        _S582 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S583;
    if(_S582)
    {
        _S583 = 1.0f;
    }
    else
    {
        _S583 = -1.0f;
    }
    return _S583;
}

static __device__ bool arrivesBehind_0(float3  dir_9, float3  n_9)
{
    return (dot_0(dir_9, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_10)
{
    float3  _S584 = surface_7->geometry_n;
    float _S585 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_10);
    FKSurface faced_0 = *surface_7;
    float3  _S586 = surface_7->smooth_n * make_float3 (_S585);
    (&faced_0)->smooth_n = _S586;
    float3  _S587 = _S584 * make_float3 (_S585);
    (&faced_0)->geometry_n = _S587;
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
    float3  _S588 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_2) * log_0(_S588));
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
    bool _S589;
    if(open_0)
    {
        _S589 = prev_rough_0;
    }
    else
    {
        _S589 = false;
    }
    if(_S589)
    {
        _S589 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S589 = false;
    }
    return _S589;
}

static __device__ float2  vertexEta_0(BSDFMaterial * material_8, float n_dot_v_0)
{
    bool _S590 = n_dot_v_0 < 0.0f;
    float _S591 = material_8->ior;
    float _S592 = _slang_select(_S590, _S591,1.0f);
    float _S593 = _slang_select(_S590, 1.0f,_S591);
    return make_float2 (_S592, _S593);
}

__device__ bool samplesLights(BSDFMaterial material_9)
{
    bool _S594 = (material_9.roughness) > 0.0f;
    bool _S595;
    if(_S594)
    {
        _S595 = true;
    }
    else
    {
        bool _S596 = (material_9.metallic) < 1.0f;
        if(_S596)
        {
            _S595 = (material_9.transmission) < 1.0f;
        }
        else
        {
            _S595 = false;
        }
    }
    return _S595;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_10)
{
    float _S597 = rgb_to_greyscale(material_10->translucent);
    return _S597 > 0.0f;
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
    MediumSides _S598;
    (&_S598)->behind = *behind_0;
    (&_S598)->front = *front_0;
    (&_S598)->fillings = fillings_1;
    (&_S598)->face = face_1;
    return _S598;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_11)
{
    float3  _S599 = surface_8->geometry_n;
    MediumSides _S600 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S600;
    bool _S601 = surface_8->encloses;
    if(_S601)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S602 = (dot_0(dir_11, _S599)) > 0.0f;
        if(_S602)
        {
            float3  _S603 = make_float3 (0.0f);
            FKMedium _S604 = Medium_x24init_0(_S603, _S603);
            (&sides_0)->front = _S604;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_12, uint depth_2, uint lobe_9, float length_3, float width_1, FKHit * own_1, bool fiber_1)
{
    float3  _S605 = surface_9->geometry_n;
    ShadowContext _S606 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_2, lobe_9, true, length_3, width_1, own_1, fiber_1);
    bool _S607 = surface_9->encloses;
    ShadowContext context_2;
    if(_S607)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S608 = - _S605;
        float3  _S609 = _slang_select(turned_0, _S608,_S605);
        (&faced_1)->geometry_n = _S609;
        FKMedium _S610 = Medium_x24init_0(make_float3 (0.0f), extinction_2);
        FKSurface _S611 = faced_1;
        FKMedium _S612 = _S610;
        MediumSides _S613 = mediumSides_0(&_S611, &_S612, filling_1, dir_12);
        ShadowContext _S614 = ShadowContext_x24init_0(_S613.behind.extinction, _S613.front.extinction, _S613.fillings, _S605, depth_2, lobe_9, true, length_3, width_1, own_1, fiber_1);
        if(turned_0)
        {
            uint2  _S615 = _S613.fillings;
            ShadowContext _S616 = ShadowContext_x24init_0(_S613.front.extinction, _S613.behind.extinction, uint2 {_S615.y, _S615.x}, _S605, depth_2, lobe_9, true, length_3, width_1, own_1, fiber_1);
            context_2 = _S616;
        }
        else
        {
            context_2 = _S614;
        }
    }
    else
    {
        context_2 = _S606;
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
    float3  _S617 = negate_0(in_dir_5);
    bool _S618 = (dot_0(g_n_0, _S617) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S618)
    {
        SampleBSDF _S619 = connectBSDF(in_dir_5, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 0U, random_state_10);
        SampleBSDF _S620 = connectBSDF(in_dir_5, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 2U, random_state_10);
        return _S619.throughput * make_float3 (_S619.pdf) + _S620.throughput * make_float3 (_S620.pdf);
    }
    SampleBSDF _S621 = connectBSDF(in_dir_5, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 1U, random_state_10);
    return _S621.throughput * make_float3 (_S621.pdf);
}

__device__ float3  translucentCorrection(float3  in_dir_6, float3  out_dir_2, float3  n_11, float3  g_n_1, BSDFMaterial material_12, float eta_i_6, float eta_o_6, uint random_state_11)
{
    float _S622 = dot_0(n_11, out_dir_2);
    float3  _S623 = negate_0(in_dir_6);
    bool _S624 = (_S622 * dot_0(n_11, _S623)) < 0.0f;
    SampleBSDF _S625 = connectBSDF(in_dir_6, out_dir_2, n_11, material_12, eta_i_6, eta_o_6, 0U, random_state_11);
    float3  _S626 = negate_0(in_dir_6);
    bool _S627 = (dot_0(g_n_1, _S626) * dot_0(g_n_1, out_dir_2)) > 0.0f;
    float3  _S628 = make_float3 (0.0f);
    float3  _S629 = _S625.throughput * make_float3 (_S625.pdf);
    float _S630 = _slang_select(_S627, -1.0f,1.0f);
    float3  _S631 = _S629 * make_float3 (_S630);
    float3  _S632 = _slang_select(_S624, _S631,_S628);
    return _S632;
}

__device__ float3  translucentBSDF(float3  in_dir_7, float3  out_dir_3, float3  n_12, float3  g_n_2, BSDFMaterial material_13, float eta_i_7, float eta_o_7, uint random_state_12)
{
    float3  _S633 = BSDF(in_dir_7, out_dir_3, n_12, g_n_2, material_13, eta_i_7, eta_o_7, random_state_12);
    float3  _S634 = translucentCorrection(in_dir_7, out_dir_3, n_12, g_n_2, material_13, eta_i_7, eta_o_7, random_state_12);
    return _S633 + _S634;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_14, float eta_i_8, float eta_o_8, bool competing_1, uint random_state_13)
{
    bool _S635 = !competing_1;
    bool _S636;
    if(_S635)
    {
        _S636 = true;
    }
    else
    {
        _S636 = (light_2->density) == 0.0f;
    }
    if(_S636)
    {
        bool _S637 = isTranslucent_0(material_14);
        if(_S637)
        {
            float3  _S638 = translucentBSDF(in_dir_8, light_2->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_8, eta_o_8, random_state_13);
            return _S638 * light_2->radiance;
        }
        float3  _S639 = BSDF(in_dir_8, light_2->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_8, eta_o_8, random_state_13);
        return _S639 * light_2->radiance;
    }
    float3  _S640 = light_2->dir;
    bool _S641 = (dot_0(geometry_n_4, - in_dir_8) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    float3  _S642 = neeBSDF(in_dir_8, _S640, smooth_n_5, *material_14, eta_i_8, eta_o_8, _S641, light_2->density, true, random_state_13);
    return _S642 * light_2->radiance * make_float3 (light_2->density);
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S643 = (F32_sqrt((random_1_0)));
    float _S644 = 6.28318548202514648f * random_2_0;
    float _S645 = _S643 * (F32_cos((_S644)));
    float _S646 = _S643 * (F32_sin((_S644)));
    float _S647 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S645 * _S645 - _S646 * _S646))))));
    return make_float3 (_S645, _S647, _S646);
}

static __device__ float3  reflect_0(float3  i_9, float3  n_13)
{
    return i_9 - make_float3 (2.0f * dot_0(n_13, i_9)) * n_13;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_9, float3  n_14, BSDFMaterial material_15, float eta_i_9, float eta_o_9, uint random_init_1, float2  screen_space_0)
{
    uint random_state_14 = random_init_1;
    float3  _S648 = negate_0(in_dir_9);
    float _S649 = dot_0(n_14, _S648);
    float _S650 = sign_0(_S649);
    float3  n_i_4 = n_14 * make_float3 (_S650);
    float _S651 = (F32_abs((_S649)));
    float _S652 = material_15.roughness;
    float _S653 = _S652 * _S652;
    AnisotropicFrame _S654 = anisotropicFrame(material_15, n_i_4);
    float3  _S655 = sampleHalfVector(_S648, n_i_4, _S653, _S654, &random_state_14);
    BSDFLobes _S656 = bsdfLobes(in_dir_9, _S648, n_i_4, _S655, material_15, eta_i_9, eta_o_9, _S654);
    BSDFLobes lobes_3 = _S656;
    float _S657 = translucentShare(material_15);
    (&lobes_3)->translucent_share = _S657;
    float3  _S658 = make_float3 (1.0f);
    SampleBSDF _S659 = SampleBSDF_x24init_0(_S658, _S658, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S659;
    Random _S660 = pcg(random_state_14);
    random_state_14 = _S660.state;
    bool _S661 = (_S660.value) < ((&lobes_3)->p_diffuse);
    if(_S661)
    {
        Random _S662 = pcg(random_state_14);
        Random _S663 = pcg(_S662.state);
        (&sample_1)->random_state = _S663.state;
        float3  _S664 = sampleCosWeightedHemisphere(_S662.value, _S663.value);
        bool _S665 = (_S660.value) < ((&lobes_3)->p_diffuse * (&lobes_3)->translucent_share);
        float _S666 = _S664.y;
        float _S667 = - _S666;
        float _S668 = _slang_select(_S665, _S667,_S666);
        float3  _S669 = tangentToWorld(make_float3 (_S664.x, _S668, _S664.z), n_i_4);
        (&sample_1)->unit_direction = _S669;
        float3  _S670 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S653, material_15, lobes_3, 0U);
        (&sample_1)->throughput = _S670;
        float _S671 = lobeDensity(_S668, 0.0f, _S651, _S653, lobes_3, eta_i_9, eta_o_9, 0U);
        (&sample_1)->pdf = _S671;
        (&sample_1)->refracted = _S665;
        return sample_1;
    }
    bool _S672 = (_S660.value) < ((&lobes_3)->p_diffuse + (&lobes_3)->p_refract);
    if(_S672)
    {
        (&sample_1)->unit_direction = (&lobes_3)->refracted;
        float _S673 = lobeDensity(0.0f, dot_0((&sample_1)->unit_direction, _S655), _S651, _S653, lobes_3, eta_i_9, eta_o_9, 1U);
        (&sample_1)->pdf = _S673;
        float3  _S674 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S653, material_15, lobes_3, 1U);
        (&sample_1)->throughput = _S674;
        (&sample_1)->random_state = random_state_14;
        (&sample_1)->refracted = true;
        (&sample_1)->lobe = 1U;
        return sample_1;
    }
    float3  _S675 = reflect_0(in_dir_9, _S655);
    float3  _S676 = ((((_S675)) * make_float3(rnorm3df(((_S675)).x, ((_S675)).y, ((_S675)).z))));
    (&sample_1)->unit_direction = _S676;
    float3  _S677 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S653, material_15, lobes_3, 2U);
    (&sample_1)->throughput = _S677;
    (&sample_1)->random_state = random_state_14;
    (&sample_1)->lobe = 2U;
    float _S678 = lobeDensity(0.0f, 0.0f, _S651, _S653, lobes_3, eta_i_9, eta_o_9, 2U);
    (&sample_1)->pdf = _S678;
    return sample_1;
}

__device__ bool withinInverseFootprint(float pdf_6, bool diffuse_0, float prev_cos_0, float distance_4, float threshold_1)
{
    bool _S679 = pdf_6 > 0.0f;
    bool _S680;
    if(_S679)
    {
        if(diffuse_0)
        {
            _S680 = true;
        }
        else
        {
            _S680 = (pdf_6 * prev_cos_0 / (distance_4 * distance_4) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S680 = false;
    }
    return _S680;
}

__device__ bool roughLobe(float pdf_7, bool diffuse_1, float roughness_1)
{
    bool _S681 = pdf_7 > 0.0f;
    bool _S682;
    if(_S681)
    {
        if(diffuse_1)
        {
            _S682 = true;
        }
        else
        {
            _S682 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S682 = false;
    }
    return _S682;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S683 = layers_0 > 1U;
    bool _S684;
    if(_S683)
    {
        _S684 = refracting_0 != passed_0;
    }
    else
    {
        _S684 = false;
    }
    return _S684;
}

static __device__ float widened_0(float spread_0, float pdf_8, bool delta_0)
{
    float _S685 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_8))))), (3.14159274101257324f)));
    bool _S686 = !delta_0;
    float _S687 = _slang_select(_S686, _S685,0.0f);
    return spread_0 + _S687;
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
    int _S688;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_3;
    float sky_pdf_1;
    float spread_3;
    float width_4;
    uint b_5;
    float3  _S689 = make_float3 (0.0f);
    Shift _S690 = Shift_x24init_0(_S689, 0.0f);
    uint _S691 = r_3->path;
    uint _S692 = extractBits_0(r_3->path, 0U, 5U);
    uint _S693 = extractBits_0(_S691, 5U, 5U);
    uint _S694 = extractBits_0(_S691, 10U, 2U);
    uint _S695 = extractBits_0(_S691, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S696 = _S695 >= 3U;
        uint _S697 = _slang_select(_S696, 1U,0U);
        uint _S698 = _S692 + _S697;
        uint _S699 = (fcptMaxBounces());
        passes_0 = _S698 > _S699;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S690;
    }
    uint _S700 = _S693 - 1U;
    bool _S701 = _S695 == 3U;
    uint _S702 = _slang_select(_S701, 1U,0U);
    uint _S703 = _S692 + _S702;
    bool _S704 = _S694 == 0U;
    uint _S705 = _slang_select(_S704, _S703,_S700);
    FKHit _S706 = (fcptReservoirHit((*r_3)));
    float3  _S707 = dom_0->x0;
    float3  _S708 = dom_0->x1 - dom_0->x0;
    float3  _S709 = ((((_S708)) * make_float3(rnorm3df(((_S708)).x, ((_S708)).y, ((_S708)).z))));
    FKRay _S710 = Ray_x24init_0(dom_0->x1, _S709);
    FKRay ray_2 = _S710;
    FKHit hit_1 = dom_0->hit;
    float3  scatter_in_0 = _S689;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S689;
    float3  extinction_in_0 = _S689;
    uint filling_2 = 4294967295U;
    float _S711 = dom_0->spread;
    float _S712 = dom_0->width;
    float _S713 = length_0(_S708);
    NEEVertex _S714 = NEEVertex_x24init_0(true, 0.0f, _S689, _S689, _S689);
    NEEVertex nee_vertex_0 = _S714;
    Vertex _S715 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S715;
    Reservoir _S716 = (Reservoir{});
    Reservoir chain_0 = _S716;
    uint _S717 = r_3->seed;
    (&chain_0)->seed = r_3->seed;
    (&ray_2)->origin = _S707;
    (&hit_1)->distance = _S713;
    FKMedium _S718 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_1)->distance), (&filling_2)));
    uint _S719 = filling_2;
    bool _S720 = (fcptVaryingUsed());
    uint _S721 = _slang_select(_S720, _S719,4294967295U);
    filling_2 = _S721;
    scatter_in_0 = _S718.scatter;
    extinction_in_0 = _S718.extinction;
    Reservoir _S722 = chain_0;
    uint _S723 = filling_2;
    for(;;)
    {
        bool _S724 = (fcptVaryingUsed());
        if(_S724)
        {
            passes_0 = _S723 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S725 = (fcptMajorant((_S723)));
            spread_1 = _S725;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S705;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S694 == 1U;
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
            ended_0 = _S690;
            sky_pdf_0 = 0.0f;
            spread_1 = _S711;
            width_2 = _S712;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_4 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S726 = (&prev_0)->rough;
        if(_S726)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S727 = stream(_S717, 384U);
        uint tracking_0 = _S727;
        weight_1 = throughput_3;
        glowed_0 = _S689;
        b_4 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_2 = _S711;
        width_2 = _S712;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_1)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S688 = int(1);
                break;
            }
            uint _S728 = b_4 + 320U;
            bool _S729 = b_4 == 4294967295U;
            uint _S730 = _slang_select(_S729, 384U,_S728);
            uint _S731 = stream(_S717, _S730);
            Random _S732 = pcg(_S731);
            float _S733 = freeFlight_0(_S732.value, spread_1);
            if(passes_0)
            {
                float3  _S734 = (&ray_2)->origin;
                float3  _S735 = (&ray_2)->unit_direction;
                float _S736 = (&hit_1)->distance;
                uint _S737 = _slang_select(_S729, 0U,b_4);
                uint _S738 = (&prev_0)->lobe;
                uint _S739 = _slang_select(_S729, 3U,_S738);
                float _S740 = (fcptTrackMedium((_S723), (_S734), (_S735), (_S736), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S737), (_S739), (_S729)));
                geometry_density_2 = _S740;
            }
            else
            {
                geometry_density_2 = _S733;
            }
            bool _S741 = !(geometry_density_2 < ((&hit_1)->distance));
            if(_S741)
            {
                _S688 = int(1);
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
                float3  _S742 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S743 = sel_1->glow + _S742;
                sel_1->glow = _S743;
            }
            else
            {
            }
            glowed_0 = _S689;
            uint b_6 = b_4 + 1U;
            float3  _S744 = (&ray_2)->origin + make_float3 (geometry_density_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S744;
            float3  _S745 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, geometry_density_2, true);
            float3  _S746 = weight_1;
            float3  _S747 = _slang_select(passes_0, _S746,_S745);
            float3  throughput_4 = throughput_2 * _S747;
            uint _S748 = stream(_S717, b_6 + 320U);
            tracking_0 = _S748;
            weight_1 = throughput_3;
            float width_5 = width_2 + threshold_2 * geometry_density_2;
            float _S749 = threshold_2 + 3.14159274101257324f;
            bool _S750 = scatterSampled_0(replay_1, b_6, _S705, passes_0);
            TreeSample _S751 = TreeSample_x24init_0(_S689, _S689, 0.0f, 0U);
            if(_S750)
            {
                float3  _S752 = (&ray_2)->origin;
                float3  _S753 = (&ray_2)->unit_direction;
                float3  _S754 = (&ray_2)->unit_direction;
                uint _S755 = stream(_S717, b_6 + 64U);
                float3  _S756 = extinction_in_0;
                float3  _S757 = extinction_in_0;
                uint2  _S758 = make_uint2 (_S723);
                float3  _S759 = (&ray_2)->unit_direction;
                uint _S760 = arrivalLobe_0(b_6, (&prev_0)->lobe);
                FKHit _S761 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S762 = _S761;
                ShadowContext _S763 = ShadowContext_x24init_0(_S756, _S757, _S758, _S759, b_6, _S760, false, geometry_density_2, width_5, &_S762, false);
                ShadowContext _S764 = _S763;
                TreeSample _S765 = sampleLightTree_0(_S752, _S753, _S754, 0.0f, true, _S755, &_S764);
                light_3 = _S765;
            }
            else
            {
                light_3 = _S751;
            }
            uint _S766 = (fcptMaxBounces());
            bool _S767 = b_6 < _S766;
            if(_S767)
            {
                is_inside_5 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_5 = false;
            }
            float _S768 = _slang_select(is_inside_5, 0.07957746833562851f,0.0f);
            float3  _S769 = throughput_4 * light_3.radiance;
            float _S770 = powerHeuristic(light_3.density, _S768);
            float3  _S771 = _S769 * make_float3 (0.07957746833562851f * _S770);
            float3  _S772 = _slang_select(_S750, _S771,_S689);
            if(replay_1)
            {
                viewed_0 = b_6 == _S705;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S773 = _S694 == 2U;
                if(_S773)
                {
                    float _S774 = rgb_to_greyscale(_S772);
                    passes_0 = _S774 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S775 = Shift_x24init_0(_S772, 1.0f);
                    _S688 = int(0);
                    ended_0 = _S775;
                    spread_1 = _S749;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                _S688 = int(0);
                ended_0 = _S690;
                spread_1 = _S749;
                geometry_density_2 = width_5;
                chain_throughput_0 = throughput_4;
                layer_0 = b_6;
                break;
            }
            bool _S776 = !replay_1;
            if(_S776)
            {
                Reservoir candidate_2 = _S722;
                uint _S777 = extractBits_0(_S722.path, 10U, 2U);
                bool _S778 = _S777 == 1U;
                if(_S778)
                {
                    float3  _S779 = safeDivide(_S772, _S689);
                    (&candidate_2)->radiance = _S779;
                }
                else
                {
                    uint _S780 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                    uint _S781 = insertBits_0(_S780, 2U, 10U, 2U);
                    (&candidate_2)->path = _S781;
                }
                Reservoir _S782 = withEnd(candidate_2, 0U, b_6, _S772);
                offer(sel_1, _S782, _S772 * make_float3 (scale_1) / make_float3 (density_2));
                float _S783 = survivalProbability(throughput_4, density_2);
                uint _S784 = stream(_S717, b_6 + 128U);
                Random _S785 = pcg(_S784);
                bool _S786 = _S783 < (_S785.value);
                if(_S786)
                {
                    scatter_2 = true;
                }
                else
                {
                    uint _S787 = (fcptMaxBounces());
                    scatter_2 = b_6 >= _S787;
                }
                if(scatter_2)
                {
                    _S688 = int(0);
                    ended_0 = _S690;
                    spread_1 = _S749;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                float _S788 = density_2 * _S783;
                density_2 = _S788;
            }
            else
            {
            }
            NEEVertex _S789 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_2)->origin, _S689, (&ray_2)->origin);
            nee_vertex_0 = _S789;
            uint _S790 = stream(_S717, b_6);
            float3  _S791 = isotropic_0(_S790);
            (&ray_2)->unit_direction = _S791;
            Vertex _S792 = scatteredVertex_0(false);
            prev_0 = _S792;
            float _S793 = (&prev_0)->pdf;
            FKRay _S794 = ray_2;
            FKHit _S795 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S796 = (fcptTraverseInstanceBVH((_S794), (true), (4.294967296e+09f), (false), (_S795), (false)));
            hit_1 = _S796;
            b_4 = b_6;
            throughput_2 = throughput_4;
            threshold_2 = _S749;
            width_2 = width_5;
            sky_pdf_0 = _S793;
        }
        if(_S688 != int(1))
        {
            width_2 = geometry_density_2;
            throughput_2 = chain_throughput_0;
            b_4 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S690;
        spread_1 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S797 = b_4 == 4294967295U;
    bool _S798 = ((&hit_1)->instance_index) == 4294967295U;
    if(_S798)
    {
        bool _S799 = !(&nee_vertex_0)->none;
        float _S800 = _slang_select(_S799, sky_pdf_0,0.0f);
        float _S801 = escapeWeight_0(_S800, (&ray_2)->unit_direction);
        float3  _S802 = environment_0((&ray_2)->unit_direction, b_4, (&prev_0)->lobe);
        float3  _S803 = throughput_2 * _S802;
        if(replay_1)
        {
            bool _S804 = b_4 == _S705;
            if(_S804)
            {
                passes_0 = _S694 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S803 * make_float3 (_S801) / make_float3 (r_3->jac), density_2 / r_3->jac);
            }
            if(_S704)
            {
                passes_0 = _S701;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_4 == _S692;
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
                return Shift_x24init_0(_S803 * make_float3 (_S801), 1.0f);
            }
            return _S690;
        }
        Reservoir candidate_3 = chain_0;
        uint _S805 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S806 = _S805 == 1U;
        if(_S806)
        {
            uint _S807 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S808 = _S807 == b_4;
            float _S809 = _slang_select(_S808, 1.0f,_S801);
            float3  _S810 = safeDivide(_S803 * make_float3 (_S809), _S689);
            (&candidate_3)->radiance = _S810;
        }
        else
        {
            bool _S811 = (&prev_0)->rough;
            if(_S811)
            {
                uint _S812 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                uint _S813 = insertBits_0(_S812, 3U, 10U, 2U);
                uint _S814 = insertBits_0(_S813, (&prev_0)->lobe, 15U, 2U);
                bool _S815 = (&prev_0)->inside;
                uint _S816 = _slang_select(_S815, 1U,0U);
                uint _S817 = insertBits_0(_S814, _S816, 20U, 1U);
                (&candidate_3)->path = _S817;
                (&candidate_3)->jac = (&prev_0)->pdf;
                (&candidate_3)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S818 = _S803 * make_float3 (_S801);
        Reservoir _S819 = withEnd(candidate_3, 3U, b_4, _S818);
        offer(sel_1, _S819, _S818 * make_float3 (scale_1) / make_float3 (density_2));
        return _S690;
    }
    float3  _S820 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S820;
    bool _S821 = (fcptVaryingUsed());
    if(_S821)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S822 = !replay_1;
        if(_S822)
        {
            float3  _S823 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S824 = sel_1->glow + _S823;
            sel_1->glow = _S824;
        }
        float3  _S825 = throughput_2 * weight_1;
        throughput_2 = _S825;
    }
    else
    {
        float3  _S826 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
        float3  _S827 = throughput_2 * _S826;
        throughput_2 = _S827;
    }
    float _S828 = width_2 + spread_1 * (&hit_1)->distance;
    uint _S829 = b_4 + 1U;
    b_4 = _S829;
    layer_0 = 0U;
    width_2 = _S828;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S689;
    float3  reconnection_0 = _S689;
    viewed_0 = _S797;
    for(;;)
    {
        bool _S830 = ((&hit_1)->is_point_light) == 1U;
        FKMedium _S831 = Medium_x24init_0(_S689, _S689);
        BSDFMaterial _S832 = Material_x24init_0(_S689, _S689, 0.0f, 0.0f, 0.0f, 0.0f, _S689, throughput_3, 1.0f, _S689, _S689, 0.5f, 0.0f, 0.0f, _S689);
        FKMedium _S833 = _S831;
        FKSurface _S834 = Surface_x24init_0(_S689, _S689, 0.0f, &_S832, false, 0U, 1.0f, false, &_S833, 4294967295U, _S689);
        bool _S835 = !_S830;
        bool is_inside_6;
        float3  throughput_5;
        FKSurface surface_11;
        if(_S835)
        {
            uint _S836 = stream(_S717, b_4);
            uint _S837 = arrivalLobe_0(b_4, (&prev_0)->lobe);
            FKSurface _S838 = (fcptSurfaceAtPath((hit_1), ((&ray_2)->origin), (_S836), (width_2), (layer_0), (b_4), (_S837), ((&ray_2)->unit_direction)));
            bool _S839 = !passes_0;
            FKSurface _S840 = _S838;
            FKSurface _S841 = emitting_0(&_S840, _S839);
            uint _S842 = stream(_S717, b_4 + 256U);
            Random _S843 = pcg(_S842);
            FKSurface _S844 = _S841;
            FKSurface _S845 = uncovered_0(&_S844, _S843.value);
            float _S846 = facingSign(_S845.material.transmission, _S845.geometry_n, (&ray_2)->unit_direction);
            bool _S847 = _S846 < 0.0f;
            bool _S848 = (_S845.material.transmission) > 0.0f;
            if(_S848)
            {
                bool _S849 = arrivesBehind_0((&ray_2)->unit_direction, _S845.geometry_n);
                scatter_2 = _S849;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S850 = _S845;
            FKSurface _S851 = facingRay_0(&_S850, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S852 = arrivesBehind_0((&ray_2)->unit_direction, _S851.geometry_n);
                is_inside_6 = _S852;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S853 = beerLambert((&hit_1)->distance, _S851.material.absorption);
                float3  _S854 = throughput_2 * _S853;
                throughput_5 = _S854;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S855 = !_S851.skip;
            float geometry_density_3 = geometryDensity(_S851.geometry_n, (&ray_2)->unit_direction, (&hit_1)->distance);
            bool _S856 = b_4 == _S829;
            if(_S856)
            {
                float _S857 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S857;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S858 = geometry_density_2;
            scatter_2 = _S855;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S858;
            surface_11 = _S851;
            turned_1 = _S847;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_11 = _S834;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S859 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S860 = surface_11;
        FKSurface _S861 = surface_11;
        float _S862 = dot_0(surface_11.smooth_n, - (&ray_2)->unit_direction);
        BSDFMaterial _S863 = _S860.material;
        float2  _S864 = vertexEta_0(&_S863, _S862);
        bool _S865;
        if(scatter_2)
        {
            bool _S866 = samplesLights(_S860.material);
            _S865 = _S866;
        }
        else
        {
            _S865 = false;
        }
        bool _S867;
        if(passes_0)
        {
            _S867 = true;
        }
        else
        {
            _S867 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S867)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S865;
        }
        bool _S868 = (fcptHairUsed());
        bool _S869;
        if(_S868)
        {
            float3  _S870 = surface_11.hair;
            _S869 = (dot_0(_S870, _S870)) > 0.0f;
        }
        else
        {
            _S869 = false;
        }
        bool _S871;
        if(_S869)
        {
            _S871 = true;
        }
        else
        {
            BSDFMaterial _S872 = _S860.material;
            bool _S873 = isTranslucent_0(&_S872);
            _S871 = _S873;
        }
        bool _S874;
        if(_S871)
        {
            _S874 = true;
        }
        else
        {
            bool _S875 = (_S860.material.transmission) > 0.0f;
            if(_S875)
            {
                uint _S876 = (fcptLayers((hit_1)));
                _S874 = _S876 == 1U;
            }
            else
            {
                _S874 = false;
            }
        }
        float3  emission_0;
        if(_S830)
        {
            float3  _S877 = (fcptCalculatePointLightContrib(((&hit_1)->instance_index)));
            emission_0 = _S877;
        }
        else
        {
            emission_0 = _S860.material.emissive;
        }
        float _S878 = rgb_to_greyscale(emission_0);
        bool _S879 = _S878 > 0.0f;
        float3  emission_1;
        if(_S879)
        {
            NEEVertex _S880 = nee_vertex_0;
            FKHit _S881 = hit_1;
            float _S882 = emissionWeight_0(&_S880, &_S881, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S882);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S883;
        if(replay_1)
        {
            _S883 = _S694 == 1U;
        }
        else
        {
            _S883 = false;
        }
        bool _S884;
        if(_S883)
        {
            _S884 = b_4 > _S693;
        }
        else
        {
            _S884 = false;
        }
        bool _S885;
        if(_S884)
        {
            _S885 = b_4 == _S692;
        }
        else
        {
            _S885 = false;
        }
        bool _S886;
        if(_S885)
        {
            bool _S887 = _S695 == 1U;
            if(_S887)
            {
                _S886 = true;
            }
            else
            {
                _S886 = _S695 == 2U;
            }
        }
        else
        {
            _S886 = false;
        }
        if(_S886)
        {
            bool _S888 = _S830 != (_S695 == 2U);
            if(_S888)
            {
                return _S690;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_3->jac), density_2 / r_3->jac);
        }
        uint _S889 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S890 = _S889 == 1U;
        Reservoir here_0 = chain_0;
        uint _S891 = insertBits_0(0U, b_4, 5U, 5U);
        uint _S892 = insertBits_0(_S891, 1U, 10U, 2U);
        uint _S893 = insertBits_0(_S892, (&prev_0)->lobe, 15U, 2U);
        bool _S894 = (&prev_0)->inside;
        uint _S895 = _slang_select(_S894, 1U,0U);
        uint _S896 = insertBits_0(_S893, _S895, 20U, 1U);
        (&here_0)->path = _S896;
        float _S897 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S897;
        fcptWithReservoirHit((&here_0), (&hit_1));
        bool _S898;
        if(replay_1)
        {
            _S898 = _S694 == 1U;
        }
        else
        {
            _S898 = false;
        }
        bool _S899;
        if(_S898)
        {
            _S899 = b_4 == _S693;
        }
        else
        {
            _S899 = false;
        }
        bool _S900 = b_4 == _S705;
        bool _S901;
        if(_S900)
        {
            bool _S902 = !scatter_2;
            if(_S902)
            {
                _S901 = true;
            }
            else
            {
                bool _S903 = _S694 != 1U;
                if(_S903)
                {
                    _S901 = _S694 != 3U;
                }
                else
                {
                    _S901 = false;
                }
            }
        }
        else
        {
            _S901 = false;
        }
        bool _S904;
        if(_S901)
        {
            _S904 = _S694 == 2U;
        }
        else
        {
            _S904 = false;
        }
        bool _S905;
        if(_S904)
        {
            _S905 = !_S859;
        }
        else
        {
            _S905 = false;
        }
        bool _S906;
        if(_S905)
        {
            _S906 = _S695 != 4U;
        }
        else
        {
            _S906 = false;
        }
        bool _S907 = _S693 == _S692;
        bool _S908;
        if(_S907)
        {
            _S908 = _S695 == 0U;
        }
        else
        {
            _S908 = false;
        }
        bool _S909;
        if(_S908)
        {
            _S909 = ((&hit_1)->instance_index) == (_S706.instance_index);
        }
        else
        {
            _S909 = false;
        }
        bool _S910;
        if(_S909)
        {
            _S910 = ((&hit_1)->triangle_index) == (_S706.triangle_index);
        }
        else
        {
            _S910 = false;
        }
        bool _S911;
        if(_S910)
        {
            _S911 = _S859;
        }
        else
        {
            _S911 = false;
        }
        bool _S912 = _slang_select(_S899, _S911,_S906);
        bool _S913;
        if(nee_0)
        {
            _S913 = _slang_select(replay_1, _S912,scatter_2);
        }
        else
        {
            _S913 = false;
        }
        TreeSample _S914 = TreeSample_x24init_0(_S689, _S689, 0.0f, 0U);
        float3  throughput_6;
        float3  lit_0;
        if(_S913)
        {
            float3  _S915 = (&ray_2)->origin;
            if(_S869)
            {
                throughput_6 = _S689;
            }
            else
            {
                throughput_6 = _S861.smooth_n;
            }
            FKSurface _S916 = surface_11;
            uint _S917 = stream(_S717, b_4 + 64U);
            uint _S918 = arrivalLobe_0(b_4, (&prev_0)->lobe);
            FKSurface _S919 = surface_11;
            FKHit _S920 = hit_1;
            ShadowContext _S921 = shadowContext_0(&_S919, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_4, _S918, (&hit_1)->distance, width_2, &_S920, _S869);
            ShadowContext _S922 = _S921;
            TreeSample _S923 = sampleLightTree_0(_S915, throughput_6, surface_11.geometry_n, surface_11.geometry_offset, _S874, _S917, &_S922);
            bool _S924 = any_0((_S923.radiance) != _S689);
            if(_S924)
            {
                if(_S869)
                {
                    uint _S925 = (fcptMaxBounces());
                    bool _S926 = b_4 < _S925;
                    FKSurface _S927 = surface_11;
                    TreeSample _S928 = _S923;
                    float3  _S929 = hairLight_0(&_S927, (&ray_2)->unit_direction, &_S928, _S926);
                    lit_0 = _S929;
                }
                else
                {
                    float _S930 = _S864.x;
                    float _S931 = _S864.y;
                    uint _S932 = (fcptMaxBounces());
                    bool _S933 = b_4 < _S932;
                    TreeSample _S934 = _S923;
                    BSDFMaterial _S935 = _S860.material;
                    float3  _S936 = lightBSDF_0((&ray_2)->unit_direction, &_S934, _S861.smooth_n, _S916.geometry_n, &_S935, _S930, _S931, _S933, surface_11.random_state);
                    lit_0 = _S936;
                }
            }
            else
            {
                lit_0 = _S689;
            }
            light_3 = _S923;
        }
        else
        {
            light_3 = _S914;
            lit_0 = _S689;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S937;
        bool _S938;
        float density_4;
        if(_S899)
        {
            bool _S939 = ((&hit_1)->instance_index) != (_S706.instance_index);
            if(_S939)
            {
                viewed_1 = true;
            }
            else
            {
                viewed_1 = ((&hit_1)->triangle_index) != (_S706.triangle_index);
            }
            if(viewed_1)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = !_S859;
            }
            if(refracted_4)
            {
                return _S690;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S907)
            {
                wrong_side_0 = _S695 == 1U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            if(_S907)
            {
                _S937 = _S695 == 0U;
            }
            else
            {
                _S937 = false;
            }
            if(_S937)
            {
                bool _S940 = !nee_0;
                if(_S940)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S941 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S941 > 0.0f);
                }
                if(passes_0)
                {
                    return _S690;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            if(_S907)
            {
                _S938 = _S695 == 4U;
            }
            else
            {
                _S938 = false;
            }
            if(_S938)
            {
                bool _S942 = !nee_0;
                if(_S942)
                {
                    return _S690;
                }
                float _S943 = environmentPdf_0(r_3->dir);
                float3  _S944 = skyBSDF((&ray_2)->unit_direction, r_3->dir, surface_11, _S864, is_inside_6, _S943, surface_11.random_state);
                return Shift_x24init_0(throughput_7 * _S944 * r_3->radiance / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            uint _S945 = extractBits_0(_S691, 19U, 1U);
            bool _S946 = nee_0 != (_S945 == 1U);
            if(_S946)
            {
                return _S690;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S900;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S947 = !scatter_2;
                if(_S947)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S948 = _S694 != 1U;
                    if(_S948)
                    {
                        refracted_4 = _S694 != 3U;
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
                bool _S949 = _S694 == 2U;
                if(_S949)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S859;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S695 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    uint _S950 = stream(_S717, b_4 + 448U);
                    FKRay _S951 = ray_2;
                    FKSurface _S952 = surface_11;
                    SkySample _S953 = sampleSky_0(&_S951, &_S952, _S864, is_inside_6, _S950, surface_11.random_state);
                    return Shift_x24init_0(throughput_5 * _S953.color, 1.0f);
                }
                if(_S949)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S859;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S954 = rgb_to_greyscale(light_3.radiance);
                    bool _S955 = !(_S954 > 0.0f);
                    if(_S955)
                    {
                        return _S690;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S704)
                {
                    passes_0 = _S695 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S830;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S704)
                {
                    passes_0 = _S695 == 1U;
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
                    passes_0 = !_S859;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S690;
            }
            else
            {
                bool _S956 = !replay_1;
                if(_S956)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S957 = b_4 > 0U;
                    if(_S957)
                    {
                        Reservoir candidate_4 = chain_0;
                        if(_S890)
                        {
                            float3  _S958 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_4)->radiance = _S958;
                        }
                        else
                        {
                            if(_S859)
                            {
                                candidate_4 = here_0;
                            }
                        }
                        float3  _S959 = throughput_5 * emission_1;
                        Reservoir _S960 = withEnd(candidate_4, 1U, b_4, _S959);
                        offer(sel_1, _S960, _S959 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S961 = throughput_5 * emission_1;
                        float3  _S962 = sel_1->glow + _S961;
                        sel_1->glow = _S962;
                    }
                    if(nee_0)
                    {
                        float3  _S963 = throughput_5 * lit_0;
                        Reservoir candidate_5 = chain_0;
                        if(_S890)
                        {
                            float3  _S964 = safeDivide(_S963, chain_throughput_0);
                            (&candidate_5)->radiance = _S964;
                        }
                        else
                        {
                            if(_S859)
                            {
                                candidate_5 = here_0;
                                uint _S965 = insertBits_0((&candidate_5)->path, 1U, 19U, 1U);
                                (&candidate_5)->path = _S965;
                                (&candidate_5)->dir = light_3.dir;
                                (&candidate_5)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S966 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S967 = insertBits_0(_S966, 2U, 10U, 2U);
                                (&candidate_5)->path = _S967;
                            }
                        }
                        Reservoir _S968 = withEnd(candidate_5, 0U, b_4, _S963);
                        offer(sel_1, _S968, _S963 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S869)
                        {
                            _S937 = false;
                        }
                        else
                        {
                            bool _S969 = environmentMapped_0();
                            _S937 = _S969;
                        }
                    }
                    else
                    {
                        _S937 = false;
                    }
                    if(_S937)
                    {
                        uint _S970 = (fcptMaxBounces());
                        _S938 = b_4 < _S970;
                    }
                    else
                    {
                        _S938 = false;
                    }
                    if(_S938)
                    {
                        uint _S971 = stream(_S717, b_4 + 448U);
                        FKRay _S972 = ray_2;
                        FKSurface _S973 = surface_11;
                        SkySample _S974 = sampleSky_0(&_S972, &_S973, _S864, is_inside_6, _S971, surface_11.random_state);
                        float3  _S975 = throughput_5 * _S974.color;
                        Reservoir candidate_6 = chain_0;
                        if(_S890)
                        {
                            float3  _S976 = safeDivide(_S975, chain_throughput_0);
                            (&candidate_6)->radiance = _S976;
                        }
                        else
                        {
                            if(_S859)
                            {
                                candidate_6 = here_0;
                                uint _S977 = insertBits_0((&candidate_6)->path, 1U, 19U, 1U);
                                (&candidate_6)->path = _S977;
                                (&candidate_6)->dir = _S974.dir;
                                (&candidate_6)->radiance = _S974.radiance;
                            }
                            else
                            {
                                uint _S978 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S979 = insertBits_0(_S978, 2U, 10U, 2U);
                                (&candidate_6)->path = _S979;
                            }
                        }
                        Reservoir _S980 = withEnd(candidate_6, 4U, b_4, _S975);
                        offer(sel_1, _S980, _S975 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S981;
        bool straight_0;
        bool _S982;
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
                viewed_1 = _S900;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S996 = extractBits_0(_S691, 15U, 2U);
            uint _S997 = extractBits_0(_S691, 17U, 2U);
            uint _S998 = _slang_select(_S899, _S997,_S996);
            float3  _S999 = r_3->dir;
            bool refracted_5 = _S998 == 1U;
            SampleBSDF _S1000 = SampleBSDF_x24init_0(_S689, _S689, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_10 = _S1000;
            float3  reconnection_1;
            SampleBSDF _S1001;
            if(viewed_1)
            {
                uint _S1002 = extractBits_0(_S691, 20U, 1U);
                bool _S1003 = is_inside_6 != (_S1002 == 1U);
                if(_S1003)
                {
                    return _S690;
                }
                bool _S1004 = _S694 == 1U;
                if(_S1004)
                {
                    float3  _S1005 = (fcptHitPosition((_S706)));
                    throughput_8 = _S1005;
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
                    BSDFMaterial _S1006 = _S860.material;
                    bool _S1007 = isTranslucent_0(&_S1006);
                    if(_S1007)
                    {
                        refracted_4 = _S998 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1008 = throughput_8 - (&ray_2)->origin;
                        float3  _S1009 = _slang_select(_S1004, _S1008,_S999);
                        wrong_side_0 = (dot_0(_S861.smooth_n, _S1009) * _S862) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1004)
                {
                    float3  _S1010 = (&ray_2)->origin;
                    FKSurface _S1011 = surface_11;
                    float3  _S1012 = - _S861.smooth_n;
                    bool _S1013 = is_inside_6 != refracted_4;
                    float3  _S1014 = _slang_select(_S1013, _S1012,_S861.smooth_n);
                    float3  _S1015 = throughput_8 - (_S1010 + make_float3 (_S1011.geometry_offset) * _S1014);
                    float3  _S1016 = ((((_S1015)) * make_float3(rnorm3df(((_S1015)).x, ((_S1015)).y, ((_S1015)).z))));
                    reconnection_1 = _S1016;
                }
                else
                {
                    reconnection_1 = _S999;
                }
                if(_S869)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1017 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_11.geometry_n);
                    wrong_side_0 = _S1017;
                }
                if(wrong_side_0)
                {
                    return _S690;
                }
                float3  _S1018 = throughput_8;
                throughput_8 = reconnection_1;
                b_7 = _S998;
                wrong_side_0 = false;
                reconnection_1 = _S1018;
            }
            else
            {
                bool _S1019 = !_S899;
                if(_S1019)
                {
                    SampleBSDF bsdf_sampled_0;
                    if(_S869)
                    {
                        SampleBSDF _S1020 = (fcptSampleHair((surface_11.hair), (_S860.material.albedo), (_S860.material.specular_tint), ((&ray_2)->unit_direction), (surface_11.random_state)));
                        _S1001 = _S1020;
                    }
                    else
                    {
                        SampleBSDF _S1021 = sampleBSDF((&ray_2)->unit_direction, _S861.smooth_n, _S860.material, _S864.x, _S864.y, surface_11.random_state, make_float2 (0.0f));
                        _S1001 = _S1021;
                    }
                    bsdf_sampled_0 = _S1001;
                    if(_S869)
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
                            return _S690;
                        }
                        break;
                    }
                    if(_S869)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1022 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_11.geometry_n);
                        wrong_side_0 = _S1022;
                    }
                    if(wrong_side_0)
                    {
                        _S937 = (_S860.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S937 = false;
                    }
                    if(_S937)
                    {
                        SampleBSDF _S1023 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n, _S860.material, _S864.x, _S864.y, (&bsdf_sampled_0)->random_state, make_float2 (0.0f));
                        (&bsdf_sampled_0)->unit_direction = _S1023.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1023.refracted;
                        (&bsdf_sampled_0)->throughput = _S1023.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1024 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n)) * surface_11.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1024;
                        }
                    }
                    uint _S1025 = (&bsdf_sampled_0)->lobe;
                    float3  _S1026 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1027 = (&bsdf_sampled_0)->refracted;
                    lobe_10 = bsdf_sampled_0;
                    float _S1028 = (&bsdf_sampled_0)->pdf;
                    float _S1029 = _slang_select(wrong_side_0, 0.0f,_S1028);
                    (&lobe_10)->pdf = _S1029;
                    throughput_8 = _S1026;
                    b_7 = _S1025;
                    refracted_4 = _S1027;
                }
                else
                {
                    throughput_8 = _S999;
                    b_7 = _S998;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S937 = true;
            }
            else
            {
                _S937 = _S899;
            }
            if(_S937)
            {
                if(_S869)
                {
                    SampleBSDF _S1030 = (fcptConnectHair((surface_11.hair), (_S860.material.albedo), (_S860.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    _S1001 = _S1030;
                }
                else
                {
                    SampleBSDF _S1031 = connectBSDF((&ray_2)->unit_direction, throughput_8, _S861.smooth_n, _S860.material, _S864.x, _S864.y, b_7, surface_11.random_state);
                    _S1001 = _S1031;
                }
                lobe_10 = _S1001;
            }
            if(_S869)
            {
                _S938 = false;
            }
            else
            {
                bool _S1032 = b_7 != 0U;
                if(_S1032)
                {
                    bool _S1033 = (_S860.material.roughness) == 0.0f;
                    if(_S1033)
                    {
                        _S938 = true;
                    }
                    else
                    {
                        bool _S1034 = b_7 == 1U;
                        if(_S1034)
                        {
                            _S938 = (_S864.x) == (_S864.y);
                        }
                        else
                        {
                            _S938 = false;
                        }
                    }
                }
                else
                {
                    _S938 = false;
                }
            }
            bool _S1035 = !_S869;
            if(_S1035)
            {
                _S981 = b_7 == 1U;
            }
            else
            {
                _S981 = false;
            }
            if(_S981)
            {
                straight_0 = (_S860.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S982 = _S1035;
            }
            else
            {
                _S982 = false;
            }
            if(_S982)
            {
                _S983 = b_7 == 1U;
            }
            else
            {
                _S983 = false;
            }
            if(_S983)
            {
                _S984 = (_S864.x) == (_S864.y);
            }
            else
            {
                _S984 = false;
            }
            BSDFMaterial _S1036 = _S860.material;
            bool _S1037 = isTranslucent_0(&_S1036);
            if(_S1037)
            {
                _S985 = b_7 == 0U;
            }
            else
            {
                _S985 = false;
            }
            if(_S985)
            {
                _S986 = (dot_0(throughput_8, surface_11.geometry_n)) < 0.0f;
            }
            else
            {
                _S986 = false;
            }
            if(nee_0)
            {
                _S987 = !_S938;
            }
            else
            {
                _S987 = false;
            }
            if(_S987)
            {
                _S988 = !wrong_side_0;
            }
            else
            {
                _S988 = false;
            }
            if(_S988)
            {
                float _S1038 = (&lobe_10)->pdf;
                float3  _S1039 = (&ray_2)->origin;
                float3  _S1040 = _slang_select(_S874, _S689,_S861.smooth_n);
                float3  _S1041 = (&ray_2)->origin;
                FKSurface _S1042 = surface_11;
                float3  _S1043 = - _S861.smooth_n;
                float3  _S1044 = _slang_select(_S986, _S1043,_S861.smooth_n);
                NEEVertex _S1045 = NEEVertex_x24init_0(false, _S1038, _S1039, _S1040, _S1041 + make_float3 (_S1042.geometry_offset) * _S1044);
                nee_vertex_0 = _S1045;
            }
            else
            {
                if(_S869)
                {
                    _S989 = true;
                }
                else
                {
                    bool _S1046 = b_7 != 1U;
                    if(_S1046)
                    {
                        _S989 = true;
                    }
                    else
                    {
                        _S989 = (_S864.x) != (_S864.y);
                    }
                }
                if(_S989)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1047 = b_7 == 0U;
            bool _S1048 = withinInverseFootprint((&lobe_10)->pdf, _S1047, (&prev_0)->cos, (&hit_1)->distance, threshold_2);
            bool _S1049 = roughLobe((&lobe_10)->pdf, _S1047, _S860.material.roughness);
            if(_S899)
            {
                bool _S1050 = !_S1048;
                if(_S1050)
                {
                    return _S690;
                }
                bool _S1051 = _S695 != 1U;
                if(_S1051)
                {
                    _S989 = _S695 != 2U;
                }
                else
                {
                    _S989 = false;
                }
                if(_S989)
                {
                    float _S1052 = (&lobe_10)->pdf;
                    float _S1053 = _slang_select(nee_0, _S1052,0.0f);
                    float _S1054 = escapeWeight_0(_S1053, _S999);
                    if(_S907)
                    {
                        passes_0 = _S701;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1055 = _slang_select(passes_0, _S1054,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_10)->throughput * make_float3 ((&lobe_10)->pdf)) * r_3->radiance * make_float3 (_S1055) / make_float3 (r_3->jac), density_4 * (&lobe_10)->pdf / r_3->jac);
                }
                float3  _S1056 = throughput_6 * make_float3 ((&lobe_10)->pdf);
                float _S1057 = density_4 * (&lobe_10)->pdf;
                throughput_9 = _S1056;
                density_6 = _S1057;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1058 = (fcptLayers((hit_1)));
            bool _S1059 = b_7 == 1U;
            bool _S1060 = passesLayer_0(_S1058, _S1059, passes_0);
            if(viewed_1)
            {
                _S989 = _S1060;
            }
            else
            {
                _S989 = false;
            }
            if(_S989)
            {
                return _S690;
            }
            if(replay_1)
            {
                _S990 = b_4 <= _S705;
            }
            else
            {
                _S990 = false;
            }
            if(_S990)
            {
                _S991 = _S859;
            }
            else
            {
                _S991 = false;
            }
            if(_S991)
            {
                _S992 = _S1048;
            }
            else
            {
                _S992 = false;
            }
            if(_S992)
            {
                _S993 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S993 = !_S1049;
                }
                else
                {
                    _S993 = false;
                }
            }
            if(_S993)
            {
                return _S690;
            }
            if(viewed_1)
            {
                float3  _S1061 = throughput_9 * ((&lobe_10)->throughput * make_float3 ((&lobe_10)->pdf));
                float _S1062 = (&lobe_10)->pdf;
                throughput_10 = _S1061;
                sky_pdf_2 = _S1062;
            }
            else
            {
                float3  _S1063 = throughput_9 * max_0((&lobe_10)->throughput, _S689);
                throughput_10 = _S1063;
                sky_pdf_2 = density_6;
            }
            bool _S1064 = !replay_1;
            if(_S1064)
            {
                _S994 = !_S890;
            }
            else
            {
                _S994 = false;
            }
            if(_S994)
            {
                _S995 = _S859;
            }
            else
            {
                _S995 = false;
            }
            bool _S1065;
            if(_S995)
            {
                _S1065 = _S1048;
            }
            else
            {
                _S1065 = false;
            }
            float3  chain_throughput_1;
            if(_S1065)
            {
                chain_0 = here_0;
                uint _S1066 = insertBits_0((&chain_0)->path, b_7, 17U, 2U);
                uint _S1067 = _slang_select(nee_0, 1U,0U);
                uint _S1068 = insertBits_0(_S1066, _S1067, 19U, 1U);
                (&chain_0)->path = _S1068;
                float _S1069 = (&chain_0)->jac * (&lobe_10)->pdf;
                (&chain_0)->jac = _S1069;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1070 = surface_11;
            Vertex _S1071 = Vertex_x24init_0(_S1049, b_7, (&lobe_10)->pdf, (F32_abs((dot_0(surface_11.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1071;
            float _S1072 = (&lobe_10)->pdf;
            bool _S1073;
            if(_S1059)
            {
                _S1073 = (_S864.x) == (_S864.y);
            }
            else
            {
                _S1073 = false;
            }
            float sky_pdf_3 = _slang_select(_S1073, sky_pdf_0,_S1072);
            float _S1074 = _slang_select(_S869, 0.0f,sky_pdf_3);
            float _S1075 = widened_0(spread_1, (&lobe_10)->pdf, _S938);
            bool _S1076;
            if(refracted_4)
            {
                _S1076 = !_S986;
            }
            else
            {
                _S1076 = false;
            }
            bool is_inside_7;
            if(_S1076)
            {
                bool _S1077 = !is_inside_6;
                is_inside_7 = _S1077;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1078 = surface_11;
            bool _S1079 = boundsVolume_0(&_S1078);
            bool _S1080;
            if(_S1079)
            {
                _S1080 = !_S1060;
            }
            else
            {
                _S1080 = false;
            }
            if(_S1080)
            {
                FKSurface faced_2 = surface_11;
                float3  _S1081 = - _S1070.geometry_n;
                float3  _S1082 = _slang_select(turned_1, _S1081,_S1070.geometry_n);
                (&faced_2)->geometry_n = _S1082;
                FKMedium _S1083 = Medium_x24init_0(scatter_in_0, extinction_in_0);
                FKSurface _S1084 = faced_2;
                FKMedium _S1085 = _S1083;
                MediumSides _S1086 = mediumSides_0(&_S1084, &_S1085, filling_2, (&ray_2)->unit_direction);
                bool _S1087 = leavesInFront_0((&faced_2)->geometry_n, throughput_8, _S1070.geometry_n);
                float3  _S1088 = _slang_select(_S1087, _S1086.front.scatter,_S1086.behind.scatter);
                scatter_in_0 = _S1088;
                float3  _S1089 = _slang_select(_S1087, _S1086.front.extinction,_S1086.behind.extinction);
                extinction_in_0 = _S1089;
                uint _S1090 = _S1086.fillings.x;
                uint _S1091 = _S1086.fillings.y;
                uint _S1092 = _slang_select(_S1087, _S1091,_S1090);
                bool _S1093 = (fcptVaryingUsed());
                uint _S1094 = _slang_select(_S1093, _S1092,4294967295U);
                filling_2 = _S1094;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1095 = !_S1060;
            if(_S1095)
            {
                FKSurface _S1096 = surface_11;
                float _S1097 = _slang_select(straight_0, 0.0f,_S1096.geometry_offset);
                float3  _S1098 = - _S861.smooth_n;
                bool _S1099 = is_inside_7 != _S986;
                float3  _S1100 = _slang_select(_S1099, _S1098,_S861.smooth_n);
                float3  _S1101 = (&ray_2)->origin + make_float3 (_S1097) * _S1100;
                (&ray_2)->origin = _S1101;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1060;
            viewed_1 = _S984;
            sky_pdf_2 = _S1074;
            spread_4 = _S1075;
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
        bool _S1102 = !replay_1;
        float density_7;
        if(_S1102)
        {
            if(_S830)
            {
                float3  _S1103 = throughput_9 * emission_1;
                Reservoir candidate_7 = chain_0;
                uint _S1104 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1105 = _S1104 == 1U;
                if(_S1105)
                {
                    float3  _S1106 = safeDivide(_S1103, chain_throughput_0);
                    (&candidate_7)->radiance = _S1106;
                }
                Reservoir _S1107 = withEnd(candidate_7, 2U, b_4, _S1103);
                offer(sel_1, _S1107, _S1103 * make_float3 (scale_1) / make_float3 (density_6));
            }
            if(_S830)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1108 = survivalProbability(throughput_9, density_6);
                density_7 = _S1108;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1109 = stream(_S717, b_4 + 128U);
            Random _S1110 = pcg(_S1109);
            bool _S1111 = density_7 < (_S1110.value);
            if(_S1111)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1112 = (fcptMaxBounces());
                wrong_side_0 = b_4 >= _S1112;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1113 = density_6 * density_7;
            density_7 = _S1113;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1114 = layer_0 ^ 1U;
        uint _S1115 = _slang_select(passes_0, _S1114,0U);
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
            uint _S1116 = b_7 + 1U;
            b_4 = _S1116;
            layer_0 = _S1115;
            continue;
        }
        FKRay _S1117 = ray_2;
        float _S1118 = distance_5(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S900;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S694 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1119 = _slang_select(wrong_side_0, _S1118,4.294967296e+09f);
        bool _S1120 = !_S869;
        if(straight_0)
        {
            _S937 = true;
        }
        else
        {
            _S937 = _S869;
        }
        FKHit _S1121;
        if(_S937)
        {
            _S1121 = hit_1;
        }
        else
        {
            _S1121 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
        }
        FKHit _S1122 = (fcptTraverseInstanceBVH((_S1117), (_S835), (_S1119), (_S1120), (_S1121), (viewed_1)));
        hit_1 = _S1122;
        if(replay_1)
        {
            _S938 = _S900;
        }
        else
        {
            _S938 = false;
        }
        if(_S938)
        {
            _S981 = _S694 == 1U;
        }
        else
        {
            _S981 = false;
        }
        if(_S981)
        {
            _S982 = ((&hit_1)->instance_index) == (_S706.instance_index);
        }
        else
        {
            _S982 = false;
        }
        if(_S982)
        {
            _S983 = ((&hit_1)->triangle_index) == (_S706.triangle_index);
        }
        else
        {
            _S983 = false;
        }
        if(_S983)
        {
            (&hit_1)->uv = _S706.uv;
            float _S1123 = distance_5(reconnection_0, (&ray_2)->origin);
            (&hit_1)->distance = _S1123;
        }
        if(replay_1)
        {
            _S984 = _S900;
        }
        else
        {
            _S984 = false;
        }
        if(_S984)
        {
            _S985 = _S694 == 3U;
        }
        else
        {
            _S985 = false;
        }
        if(_S985)
        {
            _S986 = ((&hit_1)->instance_index) != 4294967295U;
        }
        else
        {
            _S986 = false;
        }
        if(_S986)
        {
            return _S690;
        }
        Reservoir _S1124 = chain_0;
        uint _S1125 = filling_2;
        for(;;)
        {
            bool _S1126 = (fcptVaryingUsed());
            if(_S1126)
            {
                _S987 = _S1125 != 4294967295U;
            }
            else
            {
                _S987 = false;
            }
            float _S1127;
            if(_S987)
            {
                float _S1128 = (fcptMajorant((_S1125)));
                _S1127 = _S1128;
            }
            else
            {
                _S1127 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S988 = _S900;
            }
            else
            {
                _S988 = false;
            }
            if(_S988)
            {
                _S989 = _S694 == 1U;
            }
            else
            {
                _S989 = false;
            }
            if(_S989)
            {
                _S990 = _S1127 > 0.0f;
            }
            else
            {
                _S990 = false;
            }
            if(_S990)
            {
                ended_0 = _S690;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_3 = width_2;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_7 = b_4;
                _S991 = true;
                break;
            }
            bool _S1129 = (&prev_0)->rough;
            if(_S1129)
            {
                _S991 = !(_S1127 > 0.0f);
            }
            else
            {
                _S991 = false;
            }
            (&prev_0)->rough = _S991;
            uint _S1130 = b_4 + 320U;
            bool _S1131 = b_4 == 4294967295U;
            uint _S1132 = _slang_select(_S1131, 384U,_S1130);
            uint _S1133 = stream(_S717, _S1132);
            uint tracking_1 = _S1133;
            weight_1 = throughput_3;
            glowed_0 = _S689;
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
                    _S688 = int(2);
                    break;
                }
                uint _S1134 = b_7 + 320U;
                bool _S1135 = b_7 == 4294967295U;
                uint _S1136 = _slang_select(_S1135, 384U,_S1134);
                uint _S1137 = stream(_S717, _S1136);
                Random _S1138 = pcg(_S1137);
                float _S1139 = freeFlight_0(_S1138.value, _S1127);
                if(_S987)
                {
                    float3  _S1140 = (&ray_2)->origin;
                    float3  _S1141 = (&ray_2)->unit_direction;
                    float _S1142 = (&hit_1)->distance;
                    uint _S1143 = _slang_select(_S1135, 0U,b_7);
                    uint _S1144 = (&prev_0)->lobe;
                    uint _S1145 = _slang_select(_S1135, 3U,_S1144);
                    float _S1146 = (fcptTrackMedium((_S1125), (_S1140), (_S1141), (_S1142), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S1143), (_S1145), (_S1135)));
                    spread_3 = _S1146;
                }
                else
                {
                    spread_3 = _S1139;
                }
                bool _S1147 = !(spread_3 < ((&hit_1)->distance));
                if(_S1147)
                {
                    _S688 = int(2);
                    break;
                }
                if(_S987)
                {
                    _S992 = _S1102;
                }
                else
                {
                    _S992 = false;
                }
                if(_S992)
                {
                    float3  _S1148 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1149 = sel_1->glow + _S1148;
                    sel_1->glow = _S1149;
                }
                else
                {
                }
                glowed_0 = _S689;
                uint b_8 = b_7 + 1U;
                float3  _S1150 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1150;
                float3  _S1151 = flightWeight_0(scatter_in_0, extinction_in_0, _S1127, spread_3, true);
                float3  _S1152 = weight_1;
                float3  _S1153 = _slang_select(_S987, _S1152,_S1151);
                float3  throughput_11 = throughput_10 * _S1153;
                uint _S1154 = stream(_S717, b_8 + 320U);
                tracking_1 = _S1154;
                weight_1 = throughput_3;
                float width_6 = width_3 + spread_2 * spread_3;
                float _S1155 = spread_2 + 3.14159274101257324f;
                bool _S1156 = scatterSampled_0(replay_1, b_8, _S705, _S987);
                TreeSample light_4;
                if(_S1156)
                {
                    float3  _S1157 = (&ray_2)->origin;
                    float3  _S1158 = (&ray_2)->unit_direction;
                    float3  _S1159 = (&ray_2)->unit_direction;
                    uint _S1160 = stream(_S717, b_8 + 64U);
                    float3  _S1161 = extinction_in_0;
                    float3  _S1162 = extinction_in_0;
                    uint2  _S1163 = make_uint2 (_S1125);
                    float3  _S1164 = (&ray_2)->unit_direction;
                    uint _S1165 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                    FKHit _S1166 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                    FKHit _S1167 = _S1166;
                    ShadowContext _S1168 = ShadowContext_x24init_0(_S1161, _S1162, _S1163, _S1164, b_8, _S1165, false, spread_3, width_6, &_S1167, false);
                    ShadowContext _S1169 = _S1168;
                    TreeSample _S1170 = sampleLightTree_0(_S1157, _S1158, _S1159, 0.0f, true, _S1160, &_S1169);
                    light_4 = _S1170;
                }
                else
                {
                    light_4 = _S914;
                }
                uint _S1171 = (fcptMaxBounces());
                bool _S1172 = b_8 < _S1171;
                if(_S1172)
                {
                    _S993 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S993 = false;
                }
                float _S1173 = _slang_select(_S993, 0.07957746833562851f,0.0f);
                float3  _S1174 = throughput_11 * light_4.radiance;
                float _S1175 = powerHeuristic(light_4.density, _S1173);
                float3  _S1176 = _S1174 * make_float3 (0.07957746833562851f * _S1175);
                float3  _S1177 = _slang_select(_S1156, _S1176,_S689);
                if(replay_1)
                {
                    _S994 = b_8 == _S705;
                }
                else
                {
                    _S994 = false;
                }
                if(_S994)
                {
                    bool _S1178 = _S694 == 2U;
                    if(_S1178)
                    {
                        float _S1179 = rgb_to_greyscale(_S1177);
                        _S995 = _S1179 > 0.0f;
                    }
                    else
                    {
                        _S995 = false;
                    }
                    if(_S995)
                    {
                        Shift _S1180 = Shift_x24init_0(_S1177, 1.0f);
                        _S688 = int(1);
                        ended_0 = _S1180;
                        spread_3 = _S1155;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_5 = b_8;
                        break;
                    }
                    _S688 = int(1);
                    ended_0 = _S690;
                    spread_3 = _S1155;
                    width_4 = width_6;
                    throughput_8 = throughput_11;
                    b_5 = b_8;
                    break;
                }
                if(_S1102)
                {
                    Reservoir candidate_8 = _S1124;
                    uint _S1181 = extractBits_0(_S1124.path, 10U, 2U);
                    bool _S1182 = _S1181 == 1U;
                    if(_S1182)
                    {
                        float3  _S1183 = safeDivide(_S1177, chain_throughput_0);
                        (&candidate_8)->radiance = _S1183;
                    }
                    else
                    {
                        uint _S1184 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                        uint _S1185 = insertBits_0(_S1184, 2U, 10U, 2U);
                        (&candidate_8)->path = _S1185;
                    }
                    Reservoir _S1186 = withEnd(candidate_8, 0U, b_8, _S1177);
                    offer(sel_1, _S1186, _S1177 * make_float3 (scale_1) / make_float3 (density_3));
                    float _S1187 = survivalProbability(throughput_11, density_3);
                    uint _S1188 = stream(_S717, b_8 + 128U);
                    Random _S1189 = pcg(_S1188);
                    bool _S1190 = _S1187 < (_S1189.value);
                    if(_S1190)
                    {
                        _S995 = true;
                    }
                    else
                    {
                        uint _S1191 = (fcptMaxBounces());
                        _S995 = b_8 >= _S1191;
                    }
                    if(_S995)
                    {
                        _S688 = int(1);
                        ended_0 = _S690;
                        spread_3 = _S1155;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_5 = b_8;
                        break;
                    }
                    float _S1192 = density_3 * _S1187;
                    density_3 = _S1192;
                }
                else
                {
                }
                NEEVertex _S1193 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_2)->origin, _S689, (&ray_2)->origin);
                nee_vertex_0 = _S1193;
                uint _S1194 = stream(_S717, b_8);
                float3  _S1195 = isotropic_0(_S1194);
                (&ray_2)->unit_direction = _S1195;
                Vertex _S1196 = scatteredVertex_0(is_inside_5);
                prev_0 = _S1196;
                float _S1197 = (&prev_0)->pdf;
                FKRay _S1198 = ray_2;
                FKHit _S1199 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1200 = (fcptTraverseInstanceBVH((_S1198), (true), (4.294967296e+09f), (false), (_S1199), (false)));
                hit_1 = _S1200;
                b_7 = b_8;
                throughput_10 = throughput_11;
                spread_2 = _S1155;
                width_3 = width_6;
                sky_pdf_1 = _S1197;
            }
            if(_S688 != int(2))
            {
                spread_2 = spread_3;
                width_3 = width_4;
                throughput_10 = throughput_8;
                b_7 = b_5;
                _S991 = true;
                break;
            }
            ended_0 = _S690;
            _S991 = false;
            break;
        }
        if(_S991)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S992 = b_7 == b_4;
        }
        else
        {
            _S992 = false;
        }
        bool _S1201 = ((&hit_1)->instance_index) == 4294967295U;
        if(_S1201)
        {
            bool _S1202 = !(&nee_vertex_0)->none;
            float _S1203 = _slang_select(_S1202, sky_pdf_1,0.0f);
            float _S1204 = escapeWeight_0(_S1203, (&ray_2)->unit_direction);
            float3  _S1205 = environment_0((&ray_2)->unit_direction, b_7, (&prev_0)->lobe);
            float3  _S1206 = throughput_10 * _S1205;
            if(replay_1)
            {
                bool _S1207 = b_7 == _S705;
                if(_S1207)
                {
                    passes_0 = _S694 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1206 * make_float3 (_S1204) / make_float3 (r_3->jac), density_3 / r_3->jac);
                }
                if(_S704)
                {
                    passes_0 = _S701;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_7 == _S692;
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
                    return Shift_x24init_0(_S1206 * make_float3 (_S1204), 1.0f);
                }
                return _S690;
            }
            Reservoir candidate_9 = chain_0;
            uint _S1208 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1209 = _S1208 == 1U;
            if(_S1209)
            {
                uint _S1210 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1211 = _S1210 == b_7;
                float _S1212 = _slang_select(_S1211, 1.0f,_S1204);
                float3  _S1213 = safeDivide(_S1206 * make_float3 (_S1212), chain_throughput_0);
                (&candidate_9)->radiance = _S1213;
            }
            else
            {
                bool _S1214 = (&prev_0)->rough;
                if(_S1214)
                {
                    uint _S1215 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                    uint _S1216 = insertBits_0(_S1215, 3U, 10U, 2U);
                    uint _S1217 = insertBits_0(_S1216, (&prev_0)->lobe, 15U, 2U);
                    bool _S1218 = (&prev_0)->inside;
                    uint _S1219 = _slang_select(_S1218, 1U,0U);
                    uint _S1220 = insertBits_0(_S1217, _S1219, 20U, 1U);
                    (&candidate_9)->path = _S1220;
                    (&candidate_9)->jac = (&prev_0)->pdf;
                    (&candidate_9)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1221 = _S1206 * make_float3 (_S1204);
            Reservoir _S1222 = withEnd(candidate_9, 3U, b_7, _S1221);
            offer(sel_1, _S1222, _S1221 * make_float3 (scale_1) / make_float3 (density_3));
            break;
        }
        float3  _S1223 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1223;
        bool _S1224 = (fcptVaryingUsed());
        if(_S1224)
        {
            _S993 = filling_2 != 4294967295U;
        }
        else
        {
            _S993 = false;
        }
        if(_S993)
        {
            if(_S1102)
            {
                float3  _S1225 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1226 = sel_1->glow + _S1225;
                sel_1->glow = _S1226;
            }
            float3  _S1227 = throughput_10 * weight_1;
            throughput_8 = _S1227;
        }
        else
        {
            float3  _S1228 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
            float3  _S1229 = throughput_10 * _S1228;
            throughput_8 = _S1229;
        }
        float _S1230 = width_3 + spread_2 * (&hit_1)->distance;
        viewed_0 = _S992;
        width_2 = _S1230;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1116 = b_7 + 1U;
        b_4 = _S1116;
        layer_0 = _S1115;
    }
    return _S690;
}

static __device__ Shift shift_0(Domain * dom_1, Reservoir * r_4)
{
    Selection _S1231 = (Selection{});
    Selection sel_2 = _S1231;
    bool _S1232 = (r_4->w) <= 0.0f;
    if(_S1232)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1233 = walk_0(dom_1, r_4, true, 0.0f, &sel_2);
    return _S1233;
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
    Random _S1234 = pcg(state_3);
    Random _S1235 = pcg(_S1234.state);
    float _S1236 = 6.28318548202514648f * _S1234.value;
    float _S1237 = (F32_sqrt((-2.0f * clamp_0((F32_log((_S1235.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1235.state, _S1237 * (F32_cos((_S1236))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1238;
    (&_S1238)->state = state_4;
    (&_S1238)->value = value_2;
    return _S1238;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1239 = normal_distribution(state_5);
    Random _S1240 = normal_distribution(_S1239.state);
    Random _S1241 = normal_distribution(_S1240.state);
    float3  _S1242 = make_float3 (_S1239.value, _S1240.value, _S1241.value);
    float3  _S1243 = ((((_S1242)) * make_float3(rnorm3df(((_S1242)).x, ((_S1242)).y, ((_S1242)).z))));
    return RandomSphere_x24init_0(_S1241.state, _S1243);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_15)
{
    float3  _S1244 = p1_0 - p0_0;
    float3  _S1245 = p2_0 - p0_0;
    float2  _S1246 = uv1_0 - uv0_0;
    float2  _S1247 = uv2_0 - uv0_0;
    float _S1248 = _S1246.x;
    float _S1249 = _S1247.y;
    float _S1250 = _S1246.y;
    float _S1251 = _S1247.x;
    float _S1252 = _S1248 * _S1249 - _S1250 * _S1251;
    float _S1253 = 1.0f / _S1252;
    float3  t_1 = (_S1244 * make_float3 (_S1249) - _S1245 * make_float3 (_S1250)) * make_float3 (_S1253);
    float3  _S1254 = (_S1245 * make_float3 (_S1248) - _S1244 * make_float3 (_S1251)) * make_float3 (_S1253);
    float3  _S1255 = t_1 - n_15 * make_float3 (dot_0(n_15, t_1));
    float3  t_2 = ((((_S1255)) * make_float3(rnorm3df(((_S1255)).x, ((_S1255)).y, ((_S1255)).z))));
    bool _S1256 = (dot_0(cross_0(n_15, t_2), _S1254)) > 0.0f;
    float3  t_3;
    if(_S1256)
    {
        float3  _S1257 = negate_0(t_2);
        t_3 = _S1257;
    }
    else
    {
        t_3 = t_2;
    }
    float3  _S1258 = cross_0(n_15, t_3);
    return makeMatrix<float, 3, 3> (t_3, _S1258, n_15);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1259 = t1_0 - t0_0;
    float3  _S1260 = t2_2 - t0_0;
    float3  _S1261 = t2_2 - t1_0;
    float _S1262 = (F32_min((length_0(_S1259)), ((F32_min((length_0(_S1260)), (length_0(_S1261)))))));
    float3  _S1263 = make_float3 (distance_5(position_0, t0_0), distance_5(position_0, t1_0), distance_5(position_0, t2_2));
    float3  _S1264 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1265 = dot_0(geometry_n_5, _S1264);
    float3  _S1266 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1267 = dot_0(geometry_n_5, _S1266);
    float3  _S1268 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1269 = acos_0(abs_0(make_float3 (_S1265, _S1267, dot_0(geometry_n_5, _S1268))));
    float3  _S1270 = clamp_1(tan_0(_S1269), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_0(dot_0(_S1263 * _S1270, uvw_0), 0.0f, _S1262 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_14, float3  n_16, BSDFMaterial material_16)
{
    float3  _S1271 = negate_0(dir_14);
    float _S1272 = sign_0(dot_0(n_16, _S1271));
    float3  _S1273 = n_16 * make_float3 (_S1272);
    AnisotropicFrame _S1274 = anisotropicFrame(material_16, _S1273);
    bool _S1275 = (_S1274.alphas.x) > 0.0f;
    if(_S1275)
    {
        float _S1276 = material_16.transmission * (1.0f - material_16.metallic);
        float3  _S1277 = negate_0(_S1273);
        float3  _S1278 = anisotropicLocal(dir_14, _S1274.tangent, _S1277);
        float _S1279 = anisotropicG1(_S1278, _S1274.alphas);
        return make_float3 (_S1276 * _S1279) * material_16.albedo;
    }
    float _S1280 = material_16.transmission * (1.0f - material_16.metallic);
    float _S1281 = material_16.roughness;
    float _S1282 = smithG1(_S1281 * _S1281, (F32_abs((dot_0(n_16, dir_14)))));
    return make_float3 (_S1280 * _S1282) * material_16.albedo;
}

__device__ float hairRow(float3  in_dir_10, float3  t_4, float3  out_dir_4, uint p_5, float w_2, float alpha_6, uint nt_0)
{
    uint _S1283 = p_5 % 4U;
    float _S1284 = w_2 * HAIR_WIDTHS_0[_S1283];
    float _S1285 = (F32_asin((clamp_0(dot_0(out_dir_4, t_4), -1.0f, 1.0f)))) - (F32_asin((clamp_0(dot_0(in_dir_10, t_4), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1283] * alpha_6;
    return ((F32_asinh((_S1285 / _S1284))) / (F32_asinh((3.14159274101257324f / _S1284))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_11, float3  t_5, float3  out_dir_5, uint np_0)
{
    float3  _S1286 = worldToTangent(out_dir_5, t_5);
    float3  _S1287 = worldToTangent(in_dir_11, t_5);
    return (F32_frac((((F32_atan2((_S1286.z), (_S1286.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1287.z), (1.17549435082228751e-38f - _S1287.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_12, float3  t_6, uint p_6, float row_0, float column_0, float w_3, float alpha_7, uint nt_1, uint np_1)
{
    float3  _S1288 = worldToTangent(in_dir_12, t_6);
    uint _S1289 = p_6 % 4U;
    float _S1290 = w_3 * HAIR_WIDTHS_0[_S1289];
    float _S1291 = (F32_asin((clamp_0(dot_0(in_dir_12, t_6), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1289] * alpha_7 + _S1290 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1290))))));
    float _S1292 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1288.z), (1.17549435082228751e-38f - _S1288.x)));
    float _S1293 = (F32_cos((_S1291)));
    float3  _S1294 = tangentToWorld(make_float3 (_S1293 * (F32_cos((_S1292))), (F32_sin((_S1291))), _S1293 * (F32_sin((_S1292)))), t_6);
    return _S1294;
}

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_3, float3  end_1)
{
    float _S1295 = sign_0(dot_0(light_n_0, start_3 - end_1));
    return light_n_0 * make_float3 (_S1295 * light_offset_0);
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_17, BSDFMaterial material_17, float coverage_1)
{
    float3  _S1296;
    if((material_17.ior) == 1.0f)
    {
        float3  _S1297 = straightThrough(toward_1, n_17, material_17);
        _S1296 = _S1297;
    }
    else
    {
        _S1296 = make_float3 (0.0f);
    }
    return _S1296 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_5, Shift shifted_0, float mis_0)
{
    Reservoir candidate_10 = r_5;
    float3  _S1298 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_10)->f = _S1298;
    float _S1299 = r_5.jac * shifted_0.jac;
    (&candidate_10)->jac = _S1299;
    offer(sel_3, candidate_10, make_float3 (mis_0) * shifted_0.f * make_float3 (r_5.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_6 = sel_4.r;
    float _S1300 = rgb_to_greyscale((&r_6)->f);
    float _S1301 = sel_4.w_sum / _S1300;
    bool _S1302 = _S1300 > 0.0f;
    float _S1303 = _slang_select(_S1302, _S1301,0.0f);
    (&r_6)->w = _S1303;
    (&r_6)->c = c_1;
    return r_6;
}

static __device__ float interpolate_0(float a_6, float b_9, float t_7)
{
    return a_6 + (b_9 - a_6) * t_7;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S1304 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S1304;
}

__device__ float2  temporalWeights(float c_2, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S1305 = c_2 * p_c_0;
    float _S1306 = c_t_0 * p_t_0;
    return make_float2 (_S1305 / (_S1305 + c_t_0 * g_previous_0), _S1306 / (_S1306 + c_2 * g_current_0));
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
    Domain _S1307 = dom_2;
    Reservoir _S1308 = r_7;
    Shift _S1309 = walk_0(&_S1307, &_S1308, replay_2, scale_2, sel_5);
    return _S1309;
}

__device__ Shift shift_hook(Domain dom_3, Reservoir r_8)
{
    Domain _S1310 = dom_3;
    Reservoir _S1311 = r_8;
    Shift _S1312 = shift_0(&_S1310, &_S1311);
    return _S1312;
}

#undef Matrix
