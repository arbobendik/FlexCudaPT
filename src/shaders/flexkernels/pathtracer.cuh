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
    float p_sheen_velvet;
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
static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

__device__ float anisotropicG1(float3  w_1, float2  alphas_1)
{
    float _S204 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S204 / (_S204 + length_0(make_float3 (alphas_1.x * w_1.x, alphas_1.y * w_1.y, _S204)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S205 = alphas_2.x;
    float _S206 = h_0.x / _S205;
    float _S207 = alphas_2.y;
    float _S208 = h_0.y / _S207;
    float _S209 = h_0.z;
    float _S210 = _S206 * _S206 + _S208 * _S208 + _S209 * _S209;
    return 1.0f / (F32_max((3.14159274101257324f * _S205 * _S207 * _S210 * _S210), (1.17549435082228751e-38f)));
}

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_0, float3  refracted_1, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_0, float3  sheen_0, float p_sheen_velvet_0, float3  view_0, float3  tangent_1, float2  alphas_3, float visible_0)
{
    BSDFLobes _S211;
    (&_S211)->v_dot_h = v_dot_h_0;
    (&_S211)->n_dot_h = n_dot_h_0;
    (&_S211)->refracted = refracted_1;
    (&_S211)->F = F_0;
    (&_S211)->F_greyscale = F_greyscale_0;
    (&_S211)->reflect_weight = reflect_weight_0;
    (&_S211)->diffuse_weight = diffuse_weight_0;
    (&_S211)->refract_weight = refract_weight_0;
    (&_S211)->p_diffuse = p_diffuse_0;
    (&_S211)->p_reflect = p_reflect_0;
    (&_S211)->p_refract = p_refract_0;
    (&_S211)->translucent_share = translucent_share_0;
    (&_S211)->sheen = sheen_0;
    (&_S211)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S211)->view = view_0;
    (&_S211)->tangent = tangent_1;
    (&_S211)->alphas = alphas_3;
    (&_S211)->visible = visible_0;
    return _S211;
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_0, float3  v_3, float3  n_i_2, float3  ggx_n_0, BSDFMaterial material_1, float eta_i_1, float eta_o_1, AnisotropicFrame frame_1)
{
    float _S212 = dot_0(ggx_n_0, v_3);
    float _S213 = dot_0(n_i_2, ggx_n_0);
    float _S214 = eta_i_1 / eta_o_1;
    float3  _S215 = refract_0(in_dir_0, ggx_n_0, _S214);
    float3  _S216 = ((((_S215)) * make_float3(rnorm3df(((_S215)).x, ((_S215)).y, ((_S215)).z))));
    float _S217 = (F32_min(((F32_sqrt((material_1.specular_level))) * (F32_abs((eta_i_1 - eta_o_1))) / (eta_i_1 + eta_o_1)), (0.9999847412109375f)));
    float _S218 = _S217 * _S217;
    float _S219 = (1.0f + _S217) / (1.0f - _S217);
    float _S220 = (F32_abs((_S212)));
    bool _S221 = eta_i_1 > eta_o_1;
    float sheen_component_0;
    if(_S221)
    {
        sheen_component_0 = _S219;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float visible_1;
    if(_S221)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S219;
    }
    float _S222 = fresnel(_S220, sheen_component_0, visible_1);
    bool _S223 = (eta_i_1 * eta_i_1 * (1.0f - _S212 * _S212)) >= (eta_o_1 * eta_o_1);
    float3  _S224;
    if(_S223)
    {
        _S224 = make_float3 (1.0f);
    }
    else
    {
        float3  _S225 = material_1.specular_tint * make_float3 (_S218);
        _S224 = _S225 + (make_float3 (1.0f) - _S225) * make_float3 (_S222 - _S218) / make_float3 (1.0f - _S218);
    }
    float3  _S226 = make_float3 (1.0f);
    float3  _S227 = make_float3 (0.0f);
    float _S228 = rgb_to_greyscale(material_1.sheen);
    bool _S229 = _S228 > 0.0f;
    float3  scale_0;
    float3  sheen_1;
    float3  view_1;
    if(_S229)
    {
        float _S230 = clamp_0((F32_sqrt(((F32_max((dot_0(n_i_2, v_3)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S231 = (U32_min((uint(_S230)), (22U)));
        float _S232 = (F32_sqrt((0.05000000074505806f)));
        float _S233 = (clamp_0((F32_sqrt(((F32_max((material_1.sheen_roughness), (0.0f)))))), _S232, 1.0f) - _S232) / (1.0f - _S232) * 23.0f;
        uint _S234 = (U32_min((uint(_S233)), (22U)));
        uint _S235 = _S231 * 24U + _S234;
        float _S236 = _S230 - float(_S231);
        float _S237 = _S233 - float(_S234);
        uint _S238 = _S235 + 24U;
        float _S239 = SHEEN_ALBEDO_0[_S235] + (SHEEN_ALBEDO_0[_S238] - SHEEN_ALBEDO_0[_S235]) * _S236;
        uint _S240 = _S235 + 1U;
        float _S241 = SHEEN_ALBEDO_0[_S240] + (SHEEN_ALBEDO_0[_S238 + 1U] - SHEEN_ALBEDO_0[_S240]) * _S236;
        float _S242 = (F32_exp((_S239 + (_S241 - _S239) * _S237)));
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
        scale_0 = _S226;
        sheen_component_0 = 0.0f;
        sheen_1 = _S227;
        view_1 = _S227;
    }
    float3  _S248 = mix_0(_S224, material_1.albedo, material_1.metallic);
    float3  F_1 = _S248 * scale_0;
    float _S249 = rgb_to_greyscale(F_1);
    float _S250 = 1.0f - material_1.metallic;
    float3  _S251 = make_float3 (1.0f) - _S224;
    float3  _S252 = make_float3 ((1.0f - material_1.transmission) * _S250) * _S251 * scale_0;
    float3  _S253 = make_float3 (material_1.transmission * _S250) * _S251 * scale_0;
    float _S254 = (F32_max((_S249), (0.0f)));
    float _S255 = rgb_to_greyscale(_S252);
    float _S256 = (F32_max((_S255), (0.0f)));
    float _S257 = rgb_to_greyscale(_S253);
    float _S258 = sign_0(length_0(_S216));
    float _S259 = (F32_max((_S257 * _S258), (0.0f)));
    float _S260 = _S254 + _S256 + _S259;
    float _S261 = (F32_min((sheen_component_0), (1.0f)));
    bool _S262 = sheen_component_0 > 0.0f;
    bool _S263;
    if(_S262)
    {
        _S263 = !(_S260 > 0.0f);
    }
    else
    {
        _S263 = false;
    }
    float _S264 = _slang_select(_S263, 1.0f,_S261);
    float _S265 = (1.0f - _S264) / (F32_max((_S260), (0.0000152587890625f)));
    float _S266 = _S256 * _S265;
    float _S267 = _S254 * _S265;
    float _S268 = _S259 * _S265;
    bool _S269 = (frame_1.alphas.x) > 0.0f;
    if(_S269)
    {
        float3  _S270 = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        float _S271 = anisotropicG1(_S270, frame_1.alphas);
        float3  _S272 = anisotropicLocal(ggx_n_0, frame_1.tangent, n_i_2);
        float _S273 = anisotropicD(_S272, frame_1.alphas);
        float _S274 = _S271 * _S273;
        visible_1 = _S274;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S212, _S213, _S216, F_1, _S249, 1.0f, _S252, _S253, _S266, _S267, _S268, 0.0f, sheen_1, _S264, view_1, frame_1.tangent, frame_1.alphas, visible_1);
}

__device__ float translucentShare(BSDFMaterial material_2)
{
    float _S275 = rgb_to_greyscale(material_2.translucent);
    float _S276 = rgb_to_greyscale(material_2.albedo);
    float _S277 = _S275 / (_S276 + _S275);
    bool _S278 = _S275 > 0.0f;
    float _S279 = _slang_select(_S278, _S277,0.0f);
    return _S279;
}

__device__ float smithG1(float alpha_2, float n_dot_x_0)
{
    float _S280 = alpha_2 * alpha_2;
    float _S281 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S280 + (1.0f - _S280) * n_dot_x_0 * n_dot_x_0))));
    bool _S282 = alpha_2 > 0.0f;
    float _S283 = _slang_select(_S282, _S281,1.0f);
    return _S283;
}

__device__ float trowbridgeReitz(float alpha_3, float n_dot_h_1)
{
    float _S284 = alpha_3 * alpha_3;
    float _S285 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S284 * n_dot_h_1 * n_dot_h_1;
    return _S284 / (F32_max((3.14159274101257324f * _S285 * _S285), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, BSDFLobes lobes_0, float eta_i_2, float eta_o_2, uint lobe_0)
{
    bool _S286 = lobe_0 == 0U;
    if(_S286)
    {
        float _S287 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        float _S288 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
        float _S289 = 1.0f - lobes_0.translucent_share;
        bool _S290 = n_i_dot_l_0 < 0.0f;
        float _S291 = _slang_select(_S290, lobes_0.translucent_share,_S289);
        float _S292 = _S288 * _S291;
        bool _S293 = (lobes_0.translucent_share) > 0.0f;
        float _S294 = _slang_select(_S293, _S292,_S287);
        bool _S295 = n_i_dot_v_0 > 0.0f;
        float _S296 = _slang_select(_S295, _S294,0.0f);
        return _S296;
    }
    bool _S297 = lobe_0 == 4U;
    bool _S298;
    if(_S297)
    {
        float _S299 = lobes_0.p_sheen_velvet * 0.5f * 0.31830987334251404f;
        bool _S300 = n_i_dot_l_0 > 0.0f;
        if(_S300)
        {
            _S298 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S298 = false;
        }
        float _S301 = _slang_select(_S298, _S299,0.0f);
        return _S301;
    }
    float _S302 = smithG1(alpha_4, n_i_dot_v_0);
    float _S303 = _S302 * lobes_0.v_dot_h;
    float _S304 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    float _S305 = _S303 * _S304 / n_i_dot_v_0;
    bool _S306 = alpha_4 > 0.0f;
    if(_S306)
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
    float _S307 = _slang_select(_S298, _S305,0.0f);
    bool _S308 = (lobes_0.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S308)
    {
        float _S309 = lobes_0.visible * lobes_0.v_dot_h / n_i_dot_v_0;
        bool _S310 = (lobes_0.v_dot_h) > 0.0f;
        if(_S310)
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
        float _S311 = _slang_select(_S298, _S309,0.0f);
        pdf_h_0 = _S311;
    }
    else
    {
        pdf_h_0 = _S307;
    }
    bool _S312 = lobe_0 == 1U;
    if(_S312)
    {
        float _S313 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        float _S314 = lobes_0.p_refract * pdf_h_0 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S313 * _S313);
        bool _S315 = eta_i_2 != eta_o_2;
        if(_S315)
        {
            _S298 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S298 = false;
        }
        float _S316 = _slang_select(_S298, _S314,0.0f);
        return _S316;
    }
    float _S317 = lobes_0.p_reflect * pdf_h_0 / (4.0f * lobes_0.v_dot_h);
    bool _S318 = pdf_h_0 > 0.0f;
    float _S319 = _slang_select(_S318, _S317,0.0f);
    return _S319;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_0, uint random_state_2, bool refracted_2, uint lobe_1, float pdf_0)
{
    SampleBSDF _S320;
    (&_S320)->unit_direction = unit_direction_1;
    (&_S320)->throughput = throughput_0;
    (&_S320)->random_state = random_state_2;
    (&_S320)->refracted = refracted_2;
    (&_S320)->lobe = lobe_1;
    (&_S320)->pdf = pdf_0;
    return _S320;
}

__device__ __forceinline__ float3  lobeThroughput(float3  l_0, float3  n_i_3, float alpha_5, BSDFMaterial material_3, BSDFLobes lobes_1, uint lobe_2)
{
    bool _S321 = lobe_2 == 0U;
    if(_S321)
    {
        bool _S322 = (dot_0(n_i_3, l_0)) < 0.0f;
        float3  _S323 = _slang_select(_S322, material_3.translucent,material_3.albedo);
        float _S324 = 1.0f - lobes_1.translucent_share;
        float _S325 = _slang_select(_S322, lobes_1.translucent_share,_S324);
        float3  _S326 = _S323 / make_float3 (_S325);
        bool _S327 = (lobes_1.translucent_share) > 0.0f;
        float3  _S328 = _slang_select(_S327, _S326,material_3.albedo);
        return lobes_1.diffuse_weight * _S328 / make_float3 (lobes_1.p_diffuse);
    }
    bool _S329 = lobe_2 == 4U;
    if(_S329)
    {
        float3  _S330 = l_0 + lobes_1.view;
        float3  _S331 = ((((_S330)) * make_float3(rnorm3df(((_S330)).x, ((_S330)).y, ((_S330)).z))));
        float _S332 = dot_0(n_i_3, _S331);
        float _S333 = (F32_max((dot_0(n_i_3, l_0)), (0.0f)));
        float _S334 = (F32_max((dot_0(n_i_3, lobes_1.view)), (0.0f)));
        float _S335 = 1.0f / (F32_max((material_3.sheen_roughness), (0.05000000074505806f)));
        float _S336 = (2.0f + _S335) * (F32_pow(((F32_max((1.0f - _S332 * _S332), (0.0f)))), (0.5f * _S335))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S333 + _S334 - _S333 * _S334)), (0.0000152587890625f)));
        return lobes_1.sheen * make_float3 (_S336 * _S333 * 2.0f * 3.14159274101257324f / lobes_1.p_sheen_velvet);
    }
    bool _S337 = lobe_2 == 1U;
    float G1_l_0;
    if(_S337)
    {
        float _S338 = - dot_0(n_i_3, l_0);
        float _S339 = smithG1(alpha_5, (F32_max((_S338), (0.0f))));
        bool _S340 = (lobes_1.alphas.x) > 0.0f;
        if(_S340)
        {
            float3  _S341 = negate_0(n_i_3);
            float3  _S342 = anisotropicLocal(l_0, lobes_1.tangent, _S341);
            float _S343 = anisotropicG1(_S342, lobes_1.alphas);
            G1_l_0 = _S343;
        }
        else
        {
            G1_l_0 = _S339;
        }
        return lobes_1.refract_weight * make_float3 (G1_l_0) * material_3.albedo / make_float3 (lobes_1.p_refract);
    }
    float _S344 = dot_0(n_i_3, l_0);
    float _S345 = smithG1(alpha_5, (F32_max((_S344), (0.0f))));
    bool _S346 = (lobes_1.alphas.x) > 0.0f;
    if(_S346)
    {
        float3  _S347 = anisotropicLocal(l_0, lobes_1.tangent, n_i_3);
        float _S348 = anisotropicG1(_S347, lobes_1.alphas);
        G1_l_0 = _S348;
    }
    else
    {
        G1_l_0 = _S345;
    }
    return make_float3 (lobes_1.reflect_weight * G1_l_0) * lobes_1.F / make_float3 (lobes_1.p_reflect);
}

__device__ __forceinline__ SampleBSDF connectBSDF(float3  in_dir_1, float3  out_dir_0, float3  n_5, BSDFMaterial material_4, float eta_i_3, float eta_o_3, uint lobe_3, uint random_init_0)
{
    uint random_state_3 = random_init_0;
    float3  _S349 = negate_0(in_dir_1);
    float _S350 = dot_0(n_5, _S349);
    float _S351 = sign_0(_S350);
    float3  _S352 = n_5 * make_float3 (_S351);
    float _S353 = material_4.roughness;
    float _S354 = _S353 * _S353;
    AnisotropicFrame _S355 = anisotropicFrame(material_4, _S352);
    float3  _S356 = _S349 + out_dir_0;
    float3  _S357 = ((((_S356)) * make_float3(rnorm3df(((_S356)).x, ((_S356)).y, ((_S356)).z))));
    bool _S358 = lobe_3 == 0U;
    float3  ggx_n_1;
    if(_S358)
    {
        float3  _S359 = sampleHalfVector(_S349, _S352, _S354, _S355, &random_state_3);
        ggx_n_1 = _S359;
    }
    else
    {
        bool _S360 = lobe_3 == 1U;
        if(_S360)
        {
            float3  _S361 = negate_0(make_float3 (eta_i_3) * _S349 + make_float3 (eta_o_3) * out_dir_0);
            float3  _S362 = ((((_S361)) * make_float3(rnorm3df(((_S361)).x, ((_S361)).y, ((_S361)).z))));
            float _S363 = sign_0(dot_0(_S361, _S352));
            float3  _S364 = _S362 * make_float3 (_S363);
            ggx_n_1 = _S364;
        }
        else
        {
            ggx_n_1 = _S357;
        }
    }
    BSDFLobes _S365 = bsdfLobes(in_dir_1, _S349, _S352, ggx_n_1, material_4, eta_i_3, eta_o_3, _S355);
    BSDFLobes lobes_2 = _S365;
    float _S366 = translucentShare(material_4);
    (&lobes_2)->translucent_share = _S366;
    float _S367 = lobeDensity(dot_0(_S352, out_dir_0), dot_0(out_dir_0, ggx_n_1), (F32_abs((_S350))), _S354, lobes_2, eta_i_3, eta_o_3, lobe_3);
    bool _S368 = !(_S367 > 0.0f);
    if(_S368)
    {
        float3  _S369 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S369, _S369, 0U, false, 0U, 0.0f);
    }
    float3  _S370 = lobeThroughput(out_dir_0, _S352, _S354, material_4, lobes_2, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S370, random_state_3, lobe_3 == 1U, lobe_3, _S367);
}

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_2, float3  dir_3, float3  n_6, BSDFMaterial material_5, float eta_i_4, float eta_o_4, bool refracted_3, float pdf_1, bool power_0, uint random_state_4)
{
    float3  _S371 = make_float3 (0.0f);
    uint i_2 = 0U;
    float3  f_0 = _S371;
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
        if(_S373)
        {
        }
        bool _S374;
        if(_S373)
        {
            float _S375 = rgb_to_greyscale(material_5.translucent);
            _S374 = _S375 > 0.0f;
        }
        else
        {
            _S374 = false;
        }
        bool _S376;
        if(_S374)
        {
            float _S377 = dot_0(n_6, dir_3);
            float3  _S378 = negate_0(in_dir_2);
            _S376 = ((_S377 * dot_0(n_6, _S378)) < 0.0f) == refracted_3;
        }
        else
        {
            _S376 = (_S372 == 1U) == refracted_3;
        }
        float3  f_1;
        if(_S376)
        {
            SampleBSDF _S379 = connectBSDF(in_dir_2, dir_3, n_6, material_5, eta_i_4, eta_o_4, _S372, random_state_4);
            bool _S380 = (_S379.pdf) > 0.0f;
            if(_S380)
            {
                if(power_0)
                {
                    float _S381 = _S379.pdf / pdf_1;
                    float3  f_2 = f_0 + _S379.throughput * make_float3 (_S379.pdf) / make_float3 (pdf_1 * (1.0f + _S381 * _S381));
                    f_1 = f_2;
                }
                else
                {
                    float3  f_3 = f_0 + _S379.throughput * make_float3 (_S379.pdf) / make_float3 (_S379.pdf + pdf_1);
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
        uint i_3 = i_2 + 1U;
        i_2 = i_3;
        f_0 = f_1;
    }
    return f_0;
}

__device__ float3  skyBSDF(float3  in_dir_3, float3  dir_4, FKSurface surface_1, float2  eta_1, bool is_inside_2, float pdf_2, uint random_state_5)
{
    bool _S382 = wrongSide_0(is_inside_2, false, dir_4, surface_1.geometry_n);
    float3  _S383 = neeBSDF(in_dir_3, dir_4, surface_1.smooth_n, surface_1.material, eta_1.x, eta_1.y, _S382, pdf_2, false, random_state_5);
    return _S383;
}

static __device__ bool all_0(bool3  x_9)
{
    bool result_1 = true;
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
        if(result_1)
        {
            result_1 = (bool((_slang_vector_get_element(x_9, i_4))));
        }
        else
        {
            result_1 = false;
        }
        i_4 = i_4 + int(1);
    }
    return result_1;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_6)
{
    SkySample _S384;
    (&_S384)->dir = dir_5;
    (&_S384)->radiance = radiance_0;
    (&_S384)->color = color_0;
    (&_S384)->random_state = random_state_6;
    return _S384;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0)
{
    uint2  _S385 = (fcptEnvironmentCdfSize());
    uint2  _S386 = make_uint2 (1U, 0U);
    uint2  _S387 = _S385 - _S386;
    Random _S388 = pcg(init_random_state_0);
    Random _S389 = pcg(_S388.state);
    Random _S390 = pcg(_S389.state);
    Random _S391 = pcg(_S390.state);
    uint _S392 = _S387.x;
    uint _S393 = searchCDF_0(make_uint2 (_S392, 0U), make_uint2 (0U, 1U), _S387.y, _S388.value);
    uint _S394 = searchCDF_0(make_uint2 (0U, _S393), _S386, _S392, _S389.value);
    float2  _S395 = make_float2 ((float)_S387.x, (float)_S387.y);
    float2  _S396 = (make_float2 (float(_S394), float(_S393)) + make_float2 (_S390.value, _S391.value)) / _S395 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S397 = _S396.y;
    float _S398 = (F32_sin((_S397)));
    float _S399 = _S396.x;
    float3  _S400 = make_float3 (_S398 * (F32_cos((_S399))), (F32_cos((_S397))), _S398 * (F32_sin((_S399))));
    float _S401 = environmentPdf_0(_S400);
    float3  _S402 = skyBSDF(ray_0->unit_direction, _S400, *surface_2, eta_2, is_inside_3, _S401, lobe_state_0);
    bool _S403 = !(_S401 > 0.0f);
    bool _S404;
    if(_S403)
    {
        _S404 = true;
    }
    else
    {
        _S404 = all_0(_S402 == make_float3 (0.0f));
    }
    if(_S404)
    {
        float3  _S405 = make_float3 (0.0f);
        return SkySample_x24init_0(_S400, _S405, _S405, _S391.state);
    }
    float3  _S406 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S400);
    return SkySample_x24init_0(_S400, _S406, _S402 * _S406, _S391.state);
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
    SampleBSDF _S407 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_4), (light_1->dir)));
    float3  _S408 = _S407.throughput * make_float3 (_S407.pdf);
    float _S409 = light_1->density;
    float _S410 = 1.0f + _S407.pdf * _S407.pdf / (light_1->density * light_1->density);
    bool _S411;
    if(competing_0)
    {
        _S411 = _S409 > 0.0f;
    }
    else
    {
        _S411 = false;
    }
    float _S412 = _slang_select(_S411, _S410,1.0f);
    return _S408 / make_float3 (_S412) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_7)
{
    TreeSample _S413;
    (&_S413)->dir = dir_6;
    (&_S413)->radiance = radiance_1;
    (&_S413)->density = density_0;
    (&_S413)->random_state = random_state_7;
    return _S413;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_3, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S414 = importance(first_1, p_3, normal_3);
    float _S415 = importance(second_1, p_3, normal_3);
    float2  _S416 = make_float2 (_S414, _S415);
    bool _S417 = _S414 == 0.0f;
    bool _S418;
    if(_S417)
    {
        _S418 = _S415 == 0.0f;
    }
    else
    {
        _S418 = false;
    }
    if(_S418)
    {
        return 2U;
    }
    float _S419 = _S414 + _S415;
    bool _S420 = _S415 > 0.0f;
    if(_S420)
    {
        _S418 = (*pick_0 * _S419) >= _S414;
    }
    else
    {
        _S418 = false;
    }
    uint _S421 = uint(_S418);
    float _S422 = (F32_min(((*pick_0 * _S419 - float(_S421) * _S414) / _slang_vector_get_element(_S416, _S421)), (0.99999994039535522f)));
    *pick_0 = _S422;
    float _S423 = *probability_3 * (_slang_vector_get_element(_S416, _S421) / _S419);
    *probability_3 = _S423;
    return _S421;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_4, float u1_0, float u2_0)
{
    float3  _S424 = center_1 - p_4;
    float _S425 = radius_1 * radius_1 / dot_0(_S424, _S424);
    float _S426 = u1_0 * _S425 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S425), (0.0f)))))));
    float _S427 = 2.0f * u1_0;
    bool _S428 = _S425 >= 1.0f;
    float _S429 = _slang_select(_S428, _S427,_S426);
    float _S430 = (F32_sqrt(((F32_max((_S429 * (2.0f - _S429)), (0.0f))))));
    float _S431 = 6.28318548202514648f * u2_0;
    float3  _S432 = make_float3 (_S430 * (F32_cos((_S431))), 1.0f - _S429, _S430 * (F32_sin((_S431))));
    float3  _S433 = ((((_S424)) * make_float3(rnorm3df(((_S424)).x, ((_S424)).y, ((_S424)).z))));
    float3  _S434 = tangentToWorld(_S432, _S433);
    return _S434;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S435 = center_2 - ray_1->origin;
    float _S436 = dot_0(_S435, ray_1->unit_direction);
    float _S437 = dot_0(_S435, _S435) - _S436 * _S436;
    float _S438 = radius_3 * radius_3;
    bool _S439 = _S437 > _S438;
    if(_S439)
    {
        return 4.294967296e+09f;
    }
    float _S440 = (F32_sqrt((_S438 - _S437)));
    float _S441 = _S436 - _S440;
    float _S442 = _S436 + _S440;
    bool _S443 = _S441 > 0.0000152587890625f;
    bool _S444;
    if(_S443)
    {
        _S444 = _S441 < max_len_0;
    }
    else
    {
        _S444 = false;
    }
    if(_S444)
    {
        return _S441;
    }
    bool _S445 = _S442 > 0.0000152587890625f;
    if(_S445)
    {
        _S444 = _S442 < max_len_0;
    }
    else
    {
        _S444 = false;
    }
    if(_S444)
    {
        return _S442;
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
        int i_5 = int(0);
        float sum_0 = 0.0f;
        for(;;)
        {
            if(i_5 < int(3))
            {
            }
            else
            {
                break;
            }
            float sum_1 = sum_0 + _slang_vector_get_element(left_1, i_5) * _slang_vector_get_element(right_1.rows[i_5], j_1);
            i_5 = i_5 + int(1);
            sum_0 = sum_1;
        }
        *_slang_vector_get_element_ptr(&result_2, j_1) = sum_0;
        j_1 = j_1 + int(1);
    }
    return result_2;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_1)
{
    Random _S446 = pcg(init_random_state_1);
    Random _S447 = pcg(_S446.state);
    Random _S448 = pcg(_S447.state);
    float3  _S449 = make_float3 (0.0f);
    TreeSample _S450 = TreeSample_x24init_0(_S449, _S449, 0.0f, _S448.state);
    TreeSample sample_0 = _S450;
    float3  _S451 = _slang_select(sided_0, _S449,smooth_n_2);
    float3  _S452 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S446.value;
    float probability_4 = 1.0f;
    uint n_7 = 0U;
    for(;;)
    {
        uint4  _S453 = (fcptLightNode((n_7)));
        if((_S453.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S454 = (fcptLightSecond((n_7)));
        uint _S455 = n_7 + 1U;
        LightNode _S456 = (fcptLightBounds((_S455)));
        LightNode _S457 = (fcptLightBounds((_S454)));
        uint _S458 = pickChild(_S456, _S457, origin_4, _S451, &pick_1, &probability_4);
        bool _S459 = _S458 > 1U;
        if(_S459)
        {
            return sample_0;
        }
        bool _S460 = _S458 == 1U;
        uint _S461 = _slang_select(_S460, _S454,_S455);
        n_7 = _S461;
    }
    bool _S462 = n_7 == 0U;
    bool _S463;
    if(_S462)
    {
        LightNode _S464 = (fcptLightBounds((0U)));
        float _S465 = importance(_S464, origin_4, _S451);
        _S463 = !(_S465 > 0.0f);
    }
    else
    {
        _S463 = false;
    }
    if(_S463)
    {
        return sample_0;
    }
    uint4  _S466 = (fcptLightNode((n_7)));
    FKHit _S467 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S468 = (_S466.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S468)
    {
        FKLight _S469 = (fcptLight((_S466.y)));
        if(sided_0)
        {
            float _S470 = sign_0(dot_0(geometry_n_1, _S469.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S470);
            float3  _S471 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S471;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S452;
            lift_n_0 = smooth_n_2;
        }
        bool _S472 = (_S469.variance) == 0.0f;
        if(_S472)
        {
            float3  _S473 = _S469.position - emitter_point_0;
            float3  _S474 = ((((_S473)) * make_float3(rnorm3df(((_S473)).x, ((_S473)).y, ((_S473)).z))));
            (&sample_0)->dir = _S474;
            float3  _S475 = _S469.color * make_float3 (_S469.intensity) / make_float3 (dot_0(_S473, _S473) * probability_4);
            (&sample_0)->radiance = _S475;
            shadow_1 = _S473;
        }
        else
        {
            float3  _S476 = sampleSphere(_S469.position, _S469.variance, emitter_point_0, _S447.value, _S448.value);
            (&sample_0)->dir = _S476;
            float _S477 = sphereDensity(_S469.position, _S469.variance, emitter_point_0);
            float _S478 = probability_4 * _S477;
            (&sample_0)->density = _S478;
            float3  _S479 = pointLightRadiance(_S469.color, _S469.intensity, _S469.variance);
            float3  _S480 = _S479 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S480;
            FKRay _S481 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S482 = raySphere_0(_S469.position, _S469.variance, &_S481, 4.294967296e+09f);
            float3  _S483 = (&sample_0)->dir * make_float3 (_S482);
            shadow_1 = _S483;
        }
        emitter_0 = _S467;
        emitter_point_0 = _S449;
    }
    else
    {
        uint _S484 = _S466.y;
        uint _S485 = (fcptTriangleOffset((_S484)));
        uint _S486 = _S485 + _S466.z;
        Matrix<float, 3, 3>  _S487 = (fcptWorldTriangle((_S484), (_S486)));
        float _S488 = (F32_sqrt((_S447.value)));
        float2  _S489 = make_float2 (_S488 * (1.0f - _S448.value), _S488 * _S448.value);
        float3  _S490 = mul_0(make_float3 (1.0f - _S488, _S489.x, _S489.y), _S487);
        if(sided_0)
        {
            float _S491 = sign_0(dot_0(geometry_n_1, _S490 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S491);
            float3  _S492 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S492;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S493 = !((dot_0(smooth_n_2, _S490 - origin_4)) > 0.0f);
            if(_S493)
            {
                return sample_0;
            }
            emitter_point_0 = _S452;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S489, _S484, _S486, 0U, 0.0f);
        float3  _S494 = _S490 - emitter_point_0;
        float3  _S495 = ((((_S494)) * make_float3(rnorm3df(((_S494)).x, ((_S494)).y, ((_S494)).z))));
        (&sample_0)->dir = _S495;
        float _S496 = solidAngle(probability_4, cross_0(_S487.rows[int(1)] - _S487.rows[int(0)], _S487.rows[int(2)] - _S487.rows[int(0)]), _S494);
        (&sample_0)->density = _S496;
        bool _S497 = (fcptShadowFirst());
        bool _S498 = !_S497;
        if(_S498)
        {
            FKSurface _S499 = (fcptLightSurfaceAt((emitter_1), (_S490), (_S448.state), ((&sample_0)->dir), (context_1->depth), (length_0(_S490 - origin_4))));
            (&sample_0)->random_state = _S499.random_state;
            float3  _S500 = _slang_select(_S499.skip, _S449,_S499.material.emissive);
            float3  _S501 = _S500 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S501;
        }
        shadow_1 = _S494;
        emitter_0 = emitter_1;
        emitter_point_0 = _S490;
    }
    FKHit _S502 = emitter_0;
    float3  _S503 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_1, _S448.state, &_S502);
    bool _S504 = (fcptShadowFirst());
    if(_S504)
    {
        _S463 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S463 = false;
    }
    if(_S463)
    {
        _S463 = !all_0(_S503 == _S449);
    }
    else
    {
        _S463 = false;
    }
    if(_S463)
    {
        FKSurface _S505 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S448.state), ((&sample_0)->dir), (context_1->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S505.random_state;
        float3  _S506 = _slang_select(_S505.skip, _S449,_S505.material.emissive);
        float3  _S507 = _S506 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S507;
    }
    float3  _S508 = (&sample_0)->radiance * _S503;
    bool _S509 = all_0(_S503 == _S449);
    float3  _S510 = _slang_select(_S509, _S449,_S508);
    (&sample_0)->radiance = _S510;
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
    float _S511 = 1.0f / (1.0f + b_0 / a_4 * (b_0 / a_4));
    bool _S512 = b_0 > 0.0f;
    float _S513 = _slang_select(_S512, _S511,1.0f);
    return _S513;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_0, float3  light_point_1)
{
    bool _S514 = vertex_0->none;
    if(_S514)
    {
        return 1.0f;
    }
    uint _S515 = (fcptLightSlot((*hit_0)));
    float _S516 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S515, light_point_1);
    float _S517 = powerHeuristic(vertex_0->pdf, _S516);
    return _S517;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_4)
{
    uint2  _S518 = (fcptEnvironmentMapSize());
    bool _S519 = (_S518.x) > 1U;
    bool _S520;
    if(_S519)
    {
        uint2  _S521 = (fcptEnvironmentMapSize());
        _S520 = (_S521.y) > 1U;
    }
    else
    {
        _S520 = false;
    }
    if(_S520)
    {
        float3  _S522 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_4)));
        return _S522;
    }
    float3  _S523 = (fcptAmbient());
    return _S523;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S524 = (fcptEnvironmentCdfSize());
    bool _S525 = (_S524.x) > 1U;
    bool _S526;
    if(_S525)
    {
        uint2  _S527 = (fcptEnvironmentCdfSize());
        _S526 = (_S527.y) > 1U;
    }
    else
    {
        _S526 = false;
    }
    bool _S528 = !_S526;
    if(_S528)
    {
        return false;
    }
    uint2  _S529 = (fcptEnvironmentMapSize());
    bool _S530 = (_S529.x) > 1U;
    if(_S530)
    {
        uint2  _S531 = (fcptEnvironmentMapSize());
        _S526 = (_S531.y) > 1U;
    }
    else
    {
        _S526 = false;
    }
    return _S526;
}

static __device__ float escapeWeight_0(float pdf_3, float3  dir_8)
{
    bool _S532 = pdf_3 <= 0.0f;
    bool _S533;
    if(_S532)
    {
        _S533 = true;
    }
    else
    {
        bool _S534 = environmentMapped_0();
        _S533 = !_S534;
    }
    if(_S533)
    {
        return 1.0f;
    }
    float _S535 = environmentPdf_0(dir_8);
    return pdf_3 / (pdf_3 + _S535);
}

static __device__ float3  min_1(float3  x_10, float3  y_3)
{
    float3  result_3;
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
        *_slang_vector_get_element_ptr(&result_3, i_6) = (F32_min((_slang_vector_get_element(x_10, i_6)), (_slang_vector_get_element(y_3, i_6))));
        i_6 = i_6 + int(1);
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
    Shift _S536;
    (&_S536)->f = f_4;
    (&_S536)->jac = jac_0;
    return _S536;
}

static __device__ uint extractBits_0(uint e_1, uint offset_0, uint count_1)
{
    return (e_1 >> offset_0) & ((1U << count_1) - 1U);
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_2)
{
    NEEVertex _S537;
    (&_S537)->none = none_0;
    (&_S537)->pdf = pdf_4;
    (&_S537)->origin = origin_5;
    (&_S537)->smooth_n = smooth_n_3;
    (&_S537)->start = start_2;
    return _S537;
}

struct Vertex
{
    bool rough;
    uint lobe;
    float pdf;
    float cos;
    bool inside;
};

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_5, float pdf_5, float cos_0, bool inside_0)
{
    Vertex _S538;
    (&_S538)->rough = rough_0;
    (&_S538)->lobe = lobe_5;
    (&_S538)->pdf = pdf_5;
    (&_S538)->cos = cos_0;
    (&_S538)->inside = inside_0;
    return _S538;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S539 = hash(index_0);
    uint _S540 = hash(seed_0 ^ _S539);
    return _S540;
}

static __device__ float freeFlight_0(float u_1, float sigma_0)
{
    return - (F32_log((1.0f - u_1))) / sigma_0;
}

static __device__ float3  exp_0(float3  x_11)
{
    float3  result_4;
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
        *_slang_vector_get_element_ptr(&result_4, i_7) = (F32_exp((_slang_vector_get_element(x_11, i_7))));
        i_7 = i_7 + int(1);
    }
    return result_4;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_1, float distance_1, bool scatters_0)
{
    float3  _S541 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_1));
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

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_6, bool surface_4, float length_2, float width_0, FKHit * own_0, bool fiber_0)
{
    ShadowContext _S549;
    (&_S549)->extinction_behind = extinction_behind_0;
    (&_S549)->extinction_front = extinction_front_0;
    (&_S549)->fillings = fillings_0;
    (&_S549)->side = side_0;
    (&_S549)->depth = depth_1;
    (&_S549)->lobe = lobe_6;
    (&_S549)->surface = surface_4;
    (&_S549)->length = length_2;
    (&_S549)->width = width_0;
    (&_S549)->own = *own_0;
    (&_S549)->fiber = fiber_0;
    return _S549;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S550 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S550)
    {
        return 0.07957746833562851f;
    }
    float _S551 = g_0 * g_0;
    return (1.0f - _S551) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S551 - 2.0f * g_0 * mu_0), (1.5f)));
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

__device__ Reservoir withEnd(Reservoir r_0, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_0 = r_0;
    uint _S557 = insertBits_0(r_0.path, end_0, 0U, 5U);
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

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2)
{
    BSDFMaterial _S587;
    (&_S587)->albedo = albedo_0;
    (&_S587)->emissive = emissive_0;
    (&_S587)->roughness = roughness_0;
    (&_S587)->metallic = metallic_0;
    (&_S587)->transmission = transmission_0;
    (&_S587)->ior = ior_0;
    (&_S587)->absorption = absorption_0;
    (&_S587)->specular_tint = specular_tint_0;
    (&_S587)->specular_level = specular_level_0;
    (&_S587)->translucent = translucent_0;
    (&_S587)->sheen = sheen_2;
    (&_S587)->sheen_roughness = sheen_roughness_0;
    (&_S587)->anisotropy = anisotropy_0;
    (&_S587)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S587)->tangent = tangent_2;
    return _S587;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S588;
    (&_S588)->scatter = scatter_1;
    (&_S588)->extinction = extinction_1;
    (&_S588)->g = g_2;
    return _S588;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_6, bool skip_0, uint random_state_10, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S589;
    (&_S589)->smooth_n = smooth_n_4;
    (&_S589)->geometry_n = geometry_n_2;
    (&_S589)->geometry_offset = geometry_offset_2;
    (&_S589)->material = *material_6;
    (&_S589)->skip = skip_0;
    (&_S589)->random_state = random_state_10;
    (&_S589)->coverage = coverage_0;
    (&_S589)->encloses = encloses_0;
    (&_S589)->volume = *volume_0;
    (&_S589)->fills = fills_0;
    (&_S589)->hair = hair_0;
    return _S589;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S590 = (&surface_5->material)->emissive;
    float3  _S591 = make_float3 (0.0f);
    bool _S592 = !top_0;
    float3  _S593 = _slang_select(_S592, _S591,_S590);
    (&(&lower_0)->material)->emissive = _S593;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_2)
{
    float _S594 = surface_6->coverage;
    bool _S595 = u_2 < _S594;
    if(_S595)
    {
        return *surface_6;
    }
    float3  _S596 = make_float3 (0.0f);
    float3  _S597 = make_float3 (1.0f);
    BSDFMaterial _S598 = Material_x24init_0(_S596, _S596, 0.0f, 0.0f, 0.0f, 0.0f, _S596, _S597, 1.0f, _S596, _S596, 0.5f, 0.0f, 0.0f, _S596);
    BSDFMaterial material_7 = _S598;
    (&material_7)->albedo = _S597;
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
    bool _S599 = transmission_1 > 0.0f;
    bool _S600;
    if(_S599)
    {
        _S600 = true;
    }
    else
    {
        _S600 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S601;
    if(_S600)
    {
        _S601 = 1.0f;
    }
    else
    {
        _S601 = -1.0f;
    }
    return _S601;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_8)
{
    return (dot_0(dir_10, n_8)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_11)
{
    float3  _S602 = surface_7->geometry_n;
    float _S603 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_11);
    FKSurface faced_0 = *surface_7;
    float3  _S604 = surface_7->smooth_n * make_float3 (_S603);
    (&faced_0)->smooth_n = _S604;
    float3  _S605 = _S602 * make_float3 (_S603);
    (&faced_0)->geometry_n = _S605;
    return faced_0;
}

static __device__ float3  max_0(float3  x_12, float3  y_4)
{
    float3  result_5;
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
        *_slang_vector_get_element_ptr(&result_5, i_8) = (F32_max((_slang_vector_get_element(x_12, i_8)), (_slang_vector_get_element(y_4, i_8))));
        i_8 = i_8 + int(1);
    }
    return result_5;
}

static __device__ float3  log_0(float3  x_13)
{
    float3  result_6;
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
        *_slang_vector_get_element_ptr(&result_6, i_9) = (F32_log((_slang_vector_get_element(x_13, i_9))));
        i_9 = i_9 + int(1);
    }
    return result_6;
}

__device__ float3  beerLambert(float distance_2, float3  absorption_1)
{
    float3  _S606 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_2) * log_0(_S606));
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
    bool _S607;
    if(open_0)
    {
        _S607 = prev_rough_0;
    }
    else
    {
        _S607 = false;
    }
    if(_S607)
    {
        _S607 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S607 = false;
    }
    return _S607;
}

__device__ float2  vertexEta(BSDFMaterial material_8, float n_dot_v_0)
{
    bool _S608 = n_dot_v_0 < 0.0f;
    float _S609 = _slang_select(_S608, material_8.ior,1.0f);
    float _S610 = _slang_select(_S608, 1.0f,material_8.ior);
    return make_float2 (_S609, _S610);
}

__device__ bool neeDecision(BSDFMaterial material_9, float n_dot_v_1, float eta_i_5, float eta_o_5)
{
    float _S611 = fresnel((F32_abs((n_dot_v_1))), eta_i_5, eta_o_5);
    float3  _S612 = mix_0(make_float3 (_S611), material_9.albedo, material_9.metallic);
    float _S613 = rgb_to_greyscale(_S612);
    float _S614 = (F32_max(((1.0f - _S613) * (1.0f - material_9.metallic) * (1.0f - material_9.transmission)), (0.0f)));
    bool _S615 = _S614 > 0.03999999910593033f;
    bool _S616;
    if(_S615)
    {
        _S616 = true;
    }
    else
    {
        _S616 = (material_9.roughness) > 0.20000000298023224f;
    }
    return _S616;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_10)
{
    float _S617 = rgb_to_greyscale(material_10->translucent);
    return _S617 > 0.0f;
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
    MediumSides _S618;
    (&_S618)->behind = *behind_0;
    (&_S618)->front = *front_0;
    (&_S618)->fillings = fillings_1;
    (&_S618)->face = face_1;
    return _S618;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_12)
{
    float3  _S619 = surface_8->geometry_n;
    MediumSides _S620 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S620;
    bool _S621 = surface_8->encloses;
    if(_S621)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S622 = (dot_0(dir_12, _S619)) > 0.0f;
        if(_S622)
        {
            float3  _S623 = make_float3 (0.0f);
            FKMedium _S624 = Medium_x24init_0(_S623, _S623, 0.0f);
            (&sides_0)->front = _S624;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_7, float length_3, float width_1, FKHit * own_1, bool fiber_1)
{
    float3  _S625 = surface_9->geometry_n;
    ShadowContext _S626 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_2, lobe_7, true, length_3, width_1, own_1, fiber_1);
    bool _S627 = surface_9->encloses;
    ShadowContext context_2;
    if(_S627)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S628 = - _S625;
        float3  _S629 = _slang_select(turned_0, _S628,_S625);
        (&faced_1)->geometry_n = _S629;
        FKMedium _S630 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S631 = faced_1;
        FKMedium _S632 = _S630;
        MediumSides _S633 = mediumSides_0(&_S631, &_S632, filling_1, dir_13);
        ShadowContext _S634 = ShadowContext_x24init_0(_S633.behind.extinction, _S633.front.extinction, _S633.fillings, _S625, depth_2, lobe_7, true, length_3, width_1, own_1, fiber_1);
        if(turned_0)
        {
            uint2  _S635 = _S633.fillings;
            ShadowContext _S636 = ShadowContext_x24init_0(_S633.front.extinction, _S633.behind.extinction, uint2 {_S635.y, _S635.x}, _S625, depth_2, lobe_7, true, length_3, width_1, own_1, fiber_1);
            context_2 = _S636;
        }
        else
        {
            context_2 = _S634;
        }
    }
    else
    {
        context_2 = _S626;
    }
    return context_2;
}

static __device__ bool any_0(bool3  x_14)
{
    bool result_7 = false;
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
        if(result_7)
        {
            result_7 = true;
        }
        else
        {
            result_7 = (bool((_slang_vector_get_element(x_14, i_10))));
        }
        i_10 = i_10 + int(1);
    }
    return result_7;
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_5, float3  out_dir_1, float3  n_9, float3  g_n_0, BSDFMaterial material_11, float eta_i_6, float eta_o_6, uint random_state_11)
{
    float3  _S637 = negate_0(in_dir_5);
    bool _S638 = (dot_0(g_n_0, _S637) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S638)
    {
        SampleBSDF _S639 = connectBSDF(in_dir_5, out_dir_1, n_9, material_11, eta_i_6, eta_o_6, 0U, random_state_11);
        SampleBSDF _S640 = connectBSDF(in_dir_5, out_dir_1, n_9, material_11, eta_i_6, eta_o_6, 2U, random_state_11);
        SampleBSDF _S641 = connectBSDF(in_dir_5, out_dir_1, n_9, material_11, eta_i_6, eta_o_6, 4U, random_state_11);
        return _S639.throughput * make_float3 (_S639.pdf) + _S640.throughput * make_float3 (_S640.pdf) + _S641.throughput * make_float3 (_S641.pdf);
    }
    SampleBSDF _S642 = connectBSDF(in_dir_5, out_dir_1, n_9, material_11, eta_i_6, eta_o_6, 1U, random_state_11);
    return _S642.throughput * make_float3 (_S642.pdf);
}

__device__ float3  translucentCorrection(float3  in_dir_6, float3  out_dir_2, float3  n_10, float3  g_n_1, BSDFMaterial material_12, float eta_i_7, float eta_o_7, uint random_state_12)
{
    float _S643 = dot_0(n_10, out_dir_2);
    float3  _S644 = negate_0(in_dir_6);
    bool _S645 = (_S643 * dot_0(n_10, _S644)) < 0.0f;
    SampleBSDF _S646 = connectBSDF(in_dir_6, out_dir_2, n_10, material_12, eta_i_7, eta_o_7, 0U, random_state_12);
    float3  _S647 = negate_0(in_dir_6);
    bool _S648 = (dot_0(g_n_1, _S647) * dot_0(g_n_1, out_dir_2)) > 0.0f;
    float3  _S649 = make_float3 (0.0f);
    float3  _S650 = _S646.throughput * make_float3 (_S646.pdf);
    float _S651 = _slang_select(_S648, -1.0f,1.0f);
    float3  _S652 = _S650 * make_float3 (_S651);
    float3  _S653 = _slang_select(_S645, _S652,_S649);
    return _S653;
}

__device__ float3  translucentBSDF(float3  in_dir_7, float3  out_dir_3, float3  n_11, float3  g_n_2, BSDFMaterial material_13, float eta_i_8, float eta_o_8, uint random_state_13)
{
    float3  _S654 = BSDF(in_dir_7, out_dir_3, n_11, g_n_2, material_13, eta_i_8, eta_o_8, random_state_13);
    float3  _S655 = translucentCorrection(in_dir_7, out_dir_3, n_11, g_n_2, material_13, eta_i_8, eta_o_8, random_state_13);
    return _S654 + _S655;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_14, float eta_i_9, float eta_o_9, bool competing_1, uint random_state_14)
{
    bool _S656 = !competing_1;
    bool _S657;
    if(_S656)
    {
        _S657 = true;
    }
    else
    {
        _S657 = (light_2->density) == 0.0f;
    }
    if(_S657)
    {
        bool _S658 = isTranslucent_0(material_14);
        if(_S658)
        {
            float3  _S659 = translucentBSDF(in_dir_8, light_2->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_9, eta_o_9, random_state_14);
            return _S659 * light_2->radiance;
        }
        float3  _S660 = BSDF(in_dir_8, light_2->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_9, eta_o_9, random_state_14);
        return _S660 * light_2->radiance;
    }
    float3  _S661 = light_2->dir;
    bool _S662 = (dot_0(geometry_n_4, - in_dir_8) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    float3  _S663 = neeBSDF(in_dir_8, _S661, smooth_n_5, *material_14, eta_i_9, eta_o_9, _S662, light_2->density, true, random_state_14);
    return _S663 * light_2->radiance * make_float3 (light_2->density);
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S664 = (F32_sqrt((random_1_0)));
    float _S665 = 6.28318548202514648f * random_2_0;
    float _S666 = _S664 * (F32_cos((_S665)));
    float _S667 = _S664 * (F32_sin((_S665)));
    float _S668 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S666 * _S666 - _S667 * _S667))))));
    return make_float3 (_S666, _S668, _S667);
}

static __device__ float3  reflect_0(float3  i_11, float3  n_12)
{
    return i_11 - make_float3 (2.0f * dot_0(n_12, i_11)) * n_12;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_9, float3  n_13, BSDFMaterial material_15, float eta_i_10, float eta_o_10, uint random_init_1, float2  screen_space_0)
{
    uint random_state_15 = random_init_1;
    float3  _S669 = negate_0(in_dir_9);
    float _S670 = dot_0(n_13, _S669);
    float _S671 = sign_0(_S670);
    float3  n_i_4 = n_13 * make_float3 (_S671);
    float _S672 = (F32_abs((_S670)));
    float _S673 = material_15.roughness;
    float _S674 = _S673 * _S673;
    AnisotropicFrame _S675 = anisotropicFrame(material_15, n_i_4);
    float3  _S676 = sampleHalfVector(_S669, n_i_4, _S674, _S675, &random_state_15);
    BSDFLobes _S677 = bsdfLobes(in_dir_9, _S669, n_i_4, _S676, material_15, eta_i_10, eta_o_10, _S675);
    BSDFLobes lobes_3 = _S677;
    float _S678 = translucentShare(material_15);
    (&lobes_3)->translucent_share = _S678;
    float3  _S679 = make_float3 (1.0f);
    SampleBSDF _S680 = SampleBSDF_x24init_0(_S679, _S679, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S680;
    Random _S681 = pcg(random_state_15);
    random_state_15 = _S681.state;
    bool _S682 = (_S681.value) < ((&lobes_3)->p_sheen_velvet);
    if(_S682)
    {
        Random _S683 = pcg(random_state_15);
        Random _S684 = pcg(_S683.state);
        (&sample_1)->random_state = _S684.state;
        float _S685 = _S683.value;
        float _S686 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S685 * _S685))))));
        float _S687 = 6.28318548202514648f * _S684.value;
        float3  _S688 = tangentToWorld(make_float3 (_S686 * (F32_cos((_S687))), _S683.value, _S686 * (F32_sin((_S687)))), n_i_4);
        (&sample_1)->unit_direction = _S688;
        float3  _S689 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S674, material_15, lobes_3, 4U);
        (&sample_1)->throughput = _S689;
        float _S690 = lobeDensity(_S683.value, 0.0f, _S672, _S674, lobes_3, eta_i_10, eta_o_10, 4U);
        (&sample_1)->pdf = _S690;
        (&sample_1)->lobe = 4U;
        return sample_1;
    }
    float _S691 = _S681.value - (&lobes_3)->p_sheen_velvet;
    bool _S692 = _S691 < ((&lobes_3)->p_diffuse);
    if(_S692)
    {
        Random _S693 = pcg(random_state_15);
        Random _S694 = pcg(_S693.state);
        (&sample_1)->random_state = _S694.state;
        float3  _S695 = sampleCosWeightedHemisphere(_S693.value, _S694.value);
        bool _S696 = _S691 < ((&lobes_3)->p_diffuse * (&lobes_3)->translucent_share);
        float _S697 = _S695.y;
        float _S698 = - _S697;
        float _S699 = _slang_select(_S696, _S698,_S697);
        float3  _S700 = tangentToWorld(make_float3 (_S695.x, _S699, _S695.z), n_i_4);
        (&sample_1)->unit_direction = _S700;
        float3  _S701 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S674, material_15, lobes_3, 0U);
        (&sample_1)->throughput = _S701;
        float _S702 = lobeDensity(_S699, 0.0f, _S672, _S674, lobes_3, eta_i_10, eta_o_10, 0U);
        (&sample_1)->pdf = _S702;
        (&sample_1)->refracted = _S696;
        return sample_1;
    }
    bool _S703 = _S691 < ((&lobes_3)->p_diffuse + (&lobes_3)->p_refract);
    if(_S703)
    {
        (&sample_1)->unit_direction = (&lobes_3)->refracted;
        float _S704 = lobeDensity(0.0f, dot_0((&sample_1)->unit_direction, _S676), _S672, _S674, lobes_3, eta_i_10, eta_o_10, 1U);
        (&sample_1)->pdf = _S704;
        float3  _S705 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S674, material_15, lobes_3, 1U);
        (&sample_1)->throughput = _S705;
        (&sample_1)->random_state = random_state_15;
        (&sample_1)->refracted = true;
        (&sample_1)->lobe = 1U;
        return sample_1;
    }
    float3  _S706 = reflect_0(in_dir_9, _S676);
    float3  _S707 = ((((_S706)) * make_float3(rnorm3df(((_S706)).x, ((_S706)).y, ((_S706)).z))));
    (&sample_1)->unit_direction = _S707;
    float3  _S708 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S674, material_15, lobes_3, 2U);
    (&sample_1)->throughput = _S708;
    (&sample_1)->random_state = random_state_15;
    (&sample_1)->lobe = 2U;
    float _S709 = lobeDensity(0.0f, 0.0f, _S672, _S674, lobes_3, eta_i_10, eta_o_10, 2U);
    (&sample_1)->pdf = _S709;
    return sample_1;
}

__device__ bool withinInverseFootprint(float pdf_7, bool diffuse_0, float prev_cos_0, float distance_4, float threshold_1)
{
    bool _S710 = pdf_7 > 0.0f;
    bool _S711;
    if(_S710)
    {
        if(diffuse_0)
        {
            _S711 = true;
        }
        else
        {
            _S711 = (pdf_7 * prev_cos_0 / (distance_4 * distance_4) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S711 = false;
    }
    return _S711;
}

__device__ bool roughLobe(float pdf_8, bool diffuse_1, float roughness_1)
{
    bool _S712 = pdf_8 > 0.0f;
    bool _S713;
    if(_S712)
    {
        if(diffuse_1)
        {
            _S713 = true;
        }
        else
        {
            _S713 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S713 = false;
    }
    return _S713;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S714 = layers_0 > 1U;
    bool _S715;
    if(_S714)
    {
        _S715 = refracting_0 != passed_0;
    }
    else
    {
        _S715 = false;
    }
    return _S715;
}

static __device__ float widened_0(float spread_0, float pdf_9, bool delta_0)
{
    float _S716 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_9))))), (3.14159274101257324f)));
    bool _S717 = !delta_0;
    float _S718 = _slang_select(_S717, _S716,0.0f);
    return spread_0 + _S718;
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

static __device__ Shift walk_0(Domain * dom_0, Reservoir * r_1, bool replay_1, float scale_1, Selection * sel_1)
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
    int _S719;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_3;
    float sky_pdf_1;
    float spread_3;
    float width_4;
    uint b_5;
    float3  _S720 = make_float3 (0.0f);
    Shift _S721 = Shift_x24init_0(_S720, 0.0f);
    uint _S722 = r_1->path;
    uint _S723 = extractBits_0(r_1->path, 0U, 5U);
    uint _S724 = extractBits_0(_S722, 5U, 5U);
    uint _S725 = extractBits_0(_S722, 10U, 2U);
    uint _S726 = extractBits_0(_S722, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S727 = _S726 >= 3U;
        uint _S728 = _slang_select(_S727, 1U,0U);
        uint _S729 = _S723 + _S728;
        uint _S730 = (fcptMaxBounces());
        passes_0 = _S729 > _S730;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S721;
    }
    uint _S731 = _S724 - 1U;
    bool _S732 = _S726 == 3U;
    uint _S733 = _slang_select(_S732, 1U,0U);
    uint _S734 = _S723 + _S733;
    bool _S735 = _S725 == 0U;
    uint _S736 = _slang_select(_S735, _S734,_S731);
    FKHit _S737 = (fcptReservoirHit((*r_1)));
    float3  _S738 = dom_0->x0;
    float3  _S739 = dom_0->x1 - dom_0->x0;
    float3  _S740 = ((((_S739)) * make_float3(rnorm3df(((_S739)).x, ((_S739)).y, ((_S739)).z))));
    FKRay _S741 = Ray_x24init_0(dom_0->x1, _S740);
    FKRay ray_2 = _S741;
    FKHit hit_1 = dom_0->hit;
    float3  scatter_in_0 = _S720;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S720;
    float3  extinction_in_0 = _S720;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S742 = dom_0->spread;
    float _S743 = dom_0->width;
    float _S744 = length_0(_S739);
    NEEVertex _S745 = NEEVertex_x24init_0(true, 0.0f, _S720, _S720, _S720);
    NEEVertex nee_vertex_0 = _S745;
    Vertex _S746 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S746;
    Reservoir _S747 = (Reservoir{});
    Reservoir chain_0 = _S747;
    uint _S748 = r_1->seed;
    (&chain_0)->seed = r_1->seed;
    (&ray_2)->origin = _S738;
    (&hit_1)->distance = _S744;
    FKMedium _S749 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_1)->distance), (&filling_2)));
    uint _S750 = filling_2;
    bool _S751 = (fcptVaryingUsed());
    uint _S752 = _slang_select(_S751, _S750,4294967295U);
    filling_2 = _S752;
    scatter_in_0 = _S749.scatter;
    extinction_in_0 = _S749.extinction;
    g_in_0 = _S749.g;
    Reservoir _S753 = chain_0;
    uint _S754 = filling_2;
    for(;;)
    {
        bool _S755 = (fcptVaryingUsed());
        if(_S755)
        {
            passes_0 = _S754 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S756 = (fcptMajorant((_S754)));
            spread_1 = _S756;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S736;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S725 == 1U;
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
            ended_0 = _S721;
            sky_pdf_0 = 0.0f;
            spread_1 = _S742;
            width_2 = _S743;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_4 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S757 = (&prev_0)->rough;
        if(_S757)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S758 = stream(_S748, 384U);
        uint tracking_0 = _S758;
        weight_1 = throughput_3;
        glowed_0 = _S720;
        b_4 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_2 = _S742;
        width_2 = _S743;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_1)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S719 = int(1);
                break;
            }
            uint _S759 = b_4 + 320U;
            bool _S760 = b_4 == 4294967295U;
            uint _S761 = _slang_select(_S760, 384U,_S759);
            uint _S762 = stream(_S748, _S761);
            Random _S763 = pcg(_S762);
            float _S764 = freeFlight_0(_S763.value, spread_1);
            if(passes_0)
            {
                float3  _S765 = (&ray_2)->origin;
                float3  _S766 = (&ray_2)->unit_direction;
                float _S767 = (&hit_1)->distance;
                uint _S768 = _slang_select(_S760, 0U,b_4);
                uint _S769 = (&prev_0)->lobe;
                uint _S770 = _slang_select(_S760, 3U,_S769);
                float _S771 = (fcptTrackMedium((_S754), (_S765), (_S766), (_S767), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S768), (_S770), (_S760)));
                geometry_density_2 = _S771;
            }
            else
            {
                geometry_density_2 = _S764;
            }
            bool _S772 = !(geometry_density_2 < ((&hit_1)->distance));
            if(_S772)
            {
                _S719 = int(1);
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
                float3  _S773 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S774 = sel_1->glow + _S773;
                sel_1->glow = _S774;
            }
            else
            {
            }
            glowed_0 = _S720;
            uint b_6 = b_4 + 1U;
            float3  _S775 = (&ray_2)->origin + make_float3 (geometry_density_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S775;
            float3  _S776 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, geometry_density_2, true);
            float3  _S777 = weight_1;
            float3  _S778 = _slang_select(passes_0, _S777,_S776);
            float3  throughput_4 = throughput_2 * _S778;
            uint _S779 = stream(_S748, b_6 + 320U);
            tracking_0 = _S779;
            weight_1 = throughput_3;
            float width_5 = width_2 + threshold_2 * geometry_density_2;
            float _S780 = threshold_2 + 3.14159274101257324f;
            bool _S781 = scatterSampled_0(replay_1, b_6, _S736, passes_0);
            TreeSample _S782 = TreeSample_x24init_0(_S720, _S720, 0.0f, 0U);
            if(_S781)
            {
                float3  _S783 = (&ray_2)->origin;
                float3  _S784 = (&ray_2)->unit_direction;
                float3  _S785 = (&ray_2)->unit_direction;
                uint _S786 = stream(_S748, b_6 + 64U);
                float3  _S787 = extinction_in_0;
                float3  _S788 = extinction_in_0;
                uint2  _S789 = make_uint2 (_S754);
                float3  _S790 = (&ray_2)->unit_direction;
                uint _S791 = arrivalLobe_0(b_6, (&prev_0)->lobe);
                FKHit _S792 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S793 = _S792;
                ShadowContext _S794 = ShadowContext_x24init_0(_S787, _S788, _S789, _S790, b_6, _S791, false, geometry_density_2, width_5, &_S793, false);
                ShadowContext _S795 = _S794;
                TreeSample _S796 = sampleLightTree_0(_S783, _S784, _S785, 0.0f, true, _S786, &_S795);
                light_3 = _S796;
            }
            else
            {
                light_3 = _S782;
            }
            float _S797 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S798 = (fcptMaxBounces());
            bool _S799 = b_6 < _S798;
            if(_S799)
            {
                is_inside_5 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_5 = false;
            }
            float _S800 = _slang_select(is_inside_5, _S797,0.0f);
            float3  _S801 = throughput_4 * light_3.radiance;
            float _S802 = powerHeuristic(light_3.density, _S800);
            float3  _S803 = _S801 * make_float3 (_S797 * _S802);
            float3  _S804 = _slang_select(_S781, _S803,_S720);
            if(replay_1)
            {
                viewed_0 = b_6 == _S736;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S805 = _S725 == 2U;
                if(_S805)
                {
                    float _S806 = rgb_to_greyscale(_S804);
                    passes_0 = _S806 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S807 = Shift_x24init_0(_S804, 1.0f);
                    _S719 = int(0);
                    ended_0 = _S807;
                    spread_1 = _S780;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                _S719 = int(0);
                ended_0 = _S721;
                spread_1 = _S780;
                geometry_density_2 = width_5;
                chain_throughput_0 = throughput_4;
                layer_0 = b_6;
                break;
            }
            bool _S808 = !replay_1;
            if(_S808)
            {
                Reservoir candidate_2 = _S753;
                uint _S809 = extractBits_0(_S753.path, 10U, 2U);
                bool _S810 = _S809 == 1U;
                if(_S810)
                {
                    float3  _S811 = safeDivide(_S804, _S720);
                    (&candidate_2)->radiance = _S811;
                }
                else
                {
                    uint _S812 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                    uint _S813 = insertBits_0(_S812, 2U, 10U, 2U);
                    (&candidate_2)->path = _S813;
                }
                Reservoir _S814 = withEnd(candidate_2, 0U, b_6, _S804);
                offer(sel_1, _S814, _S804 * make_float3 (scale_1) / make_float3 (density_2));
                float _S815 = survivalProbability(throughput_4, density_2);
                uint _S816 = stream(_S748, b_6 + 128U);
                Random _S817 = pcg(_S816);
                bool _S818 = _S815 < (_S817.value);
                if(_S818)
                {
                    scatter_2 = true;
                }
                else
                {
                    uint _S819 = (fcptMaxBounces());
                    scatter_2 = b_6 >= _S819;
                }
                if(scatter_2)
                {
                    _S719 = int(0);
                    ended_0 = _S721;
                    spread_1 = _S780;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                float _S820 = density_2 * _S815;
                density_2 = _S820;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S821 = stream(_S748, b_6);
            float3  _S822 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S821, &phase_pdf_0);
            (&ray_2)->unit_direction = _S822;
            NEEVertex _S823 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S720, (&ray_2)->origin);
            nee_vertex_0 = _S823;
            Vertex _S824 = scatteredVertex_0(false);
            prev_0 = _S824;
            float _S825 = (&prev_0)->pdf;
            FKRay _S826 = ray_2;
            FKHit _S827 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S828 = (fcptTraverseInstanceBVH((_S826), (true), (4.294967296e+09f), (false), (_S827), (false)));
            hit_1 = _S828;
            b_4 = b_6;
            throughput_2 = throughput_4;
            threshold_2 = _S780;
            width_2 = width_5;
            sky_pdf_0 = _S825;
        }
        if(_S719 != int(1))
        {
            width_2 = geometry_density_2;
            throughput_2 = chain_throughput_0;
            b_4 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S721;
        spread_1 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S829 = b_4 == 4294967295U;
    bool _S830 = ((&hit_1)->instance_index) == 4294967295U;
    if(_S830)
    {
        bool _S831 = !(&nee_vertex_0)->none;
        float _S832 = _slang_select(_S831, sky_pdf_0,0.0f);
        float _S833 = escapeWeight_0(_S832, (&ray_2)->unit_direction);
        float3  _S834 = environment_0((&ray_2)->unit_direction, b_4, (&prev_0)->lobe);
        float3  _S835 = throughput_2 * _S834;
        if(replay_1)
        {
            bool _S836 = b_4 == _S736;
            if(_S836)
            {
                passes_0 = _S725 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S835 * make_float3 (_S833) / make_float3 (r_1->jac), density_2 / r_1->jac);
            }
            if(_S735)
            {
                passes_0 = _S732;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_4 == _S723;
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
                return Shift_x24init_0(_S835 * make_float3 (_S833), 1.0f);
            }
            return _S721;
        }
        Reservoir candidate_3 = chain_0;
        uint _S837 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S838 = _S837 == 1U;
        if(_S838)
        {
            uint _S839 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S840 = _S839 == b_4;
            float _S841 = _slang_select(_S840, 1.0f,_S833);
            float3  _S842 = safeDivide(_S835 * make_float3 (_S841), _S720);
            (&candidate_3)->radiance = _S842;
        }
        else
        {
            bool _S843 = (&prev_0)->rough;
            if(_S843)
            {
                uint _S844 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                uint _S845 = insertBits_0(_S844, 3U, 10U, 2U);
                uint _S846 = insertBits_0(_S845, (&prev_0)->lobe, 15U, 3U);
                bool _S847 = (&prev_0)->inside;
                uint _S848 = _slang_select(_S847, 1U,0U);
                uint _S849 = insertBits_0(_S846, _S848, 22U, 1U);
                (&candidate_3)->path = _S849;
                (&candidate_3)->jac = (&prev_0)->pdf;
                (&candidate_3)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S850 = _S835 * make_float3 (_S833);
        Reservoir _S851 = withEnd(candidate_3, 3U, b_4, _S850);
        offer(sel_1, _S851, _S850 * make_float3 (scale_1) / make_float3 (density_2));
        return _S721;
    }
    float3  _S852 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S852;
    bool _S853 = (fcptVaryingUsed());
    if(_S853)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S854 = !replay_1;
        if(_S854)
        {
            float3  _S855 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S856 = sel_1->glow + _S855;
            sel_1->glow = _S856;
        }
        float3  _S857 = throughput_2 * weight_1;
        throughput_2 = _S857;
    }
    else
    {
        float3  _S858 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
        float3  _S859 = throughput_2 * _S858;
        throughput_2 = _S859;
    }
    float _S860 = width_2 + spread_1 * (&hit_1)->distance;
    uint _S861 = b_4 + 1U;
    b_4 = _S861;
    layer_0 = 0U;
    width_2 = _S860;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S720;
    float3  reconnection_0 = _S720;
    viewed_0 = _S829;
    for(;;)
    {
        bool _S862 = ((&hit_1)->is_point_light) == 1U;
        FKMedium _S863 = Medium_x24init_0(_S720, _S720, 0.0f);
        BSDFMaterial _S864 = Material_x24init_0(_S720, _S720, 0.0f, 0.0f, 0.0f, 0.0f, _S720, throughput_3, 1.0f, _S720, _S720, 0.5f, 0.0f, 0.0f, _S720);
        FKMedium _S865 = _S863;
        FKSurface _S866 = Surface_x24init_0(_S720, _S720, 0.0f, &_S864, false, 0U, 1.0f, false, &_S865, 4294967295U, _S720);
        bool _S867 = !_S862;
        bool is_inside_6;
        float3  throughput_5;
        FKSurface surface_11;
        if(_S867)
        {
            uint _S868 = stream(_S748, b_4);
            uint _S869 = arrivalLobe_0(b_4, (&prev_0)->lobe);
            FKSurface _S870 = (fcptSurfaceAtPath((hit_1), ((&ray_2)->origin), (_S868), (width_2), (layer_0), (b_4), (_S869), ((&ray_2)->unit_direction)));
            bool _S871 = !passes_0;
            FKSurface _S872 = _S870;
            FKSurface _S873 = emitting_0(&_S872, _S871);
            uint _S874 = stream(_S748, b_4 + 256U);
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
                is_inside_6 = _S884;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
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
            bool _S888 = b_4 == _S861;
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
            surface_11 = _S883;
            turned_1 = _S879;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_11 = _S866;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S891 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S892 = surface_11;
        FKSurface _S893 = surface_11;
        float _S894 = dot_0(surface_11.smooth_n, - (&ray_2)->unit_direction);
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
            float3  _S901 = surface_11.hair;
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
        if(_S862)
        {
            float3  _S908 = (fcptCalculatePointLightContrib(((&hit_1)->instance_index)));
            emission_0 = _S908;
        }
        else
        {
            emission_0 = _S892.material.emissive;
        }
        float _S909 = rgb_to_greyscale(emission_0);
        bool _S910 = _S909 > 0.0f;
        float3  emission_1;
        if(_S910)
        {
            NEEVertex _S911 = nee_vertex_0;
            FKHit _S912 = hit_1;
            float _S913 = emissionWeight_0(&_S911, &_S912, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S913);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S914;
        if(replay_1)
        {
            _S914 = _S725 == 1U;
        }
        else
        {
            _S914 = false;
        }
        bool _S915;
        if(_S914)
        {
            _S915 = b_4 > _S724;
        }
        else
        {
            _S915 = false;
        }
        bool _S916;
        if(_S915)
        {
            _S916 = b_4 == _S723;
        }
        else
        {
            _S916 = false;
        }
        bool _S917;
        if(_S916)
        {
            bool _S918 = _S726 == 1U;
            if(_S918)
            {
                _S917 = true;
            }
            else
            {
                _S917 = _S726 == 2U;
            }
        }
        else
        {
            _S917 = false;
        }
        if(_S917)
        {
            bool _S919 = _S862 != (_S726 == 2U);
            if(_S919)
            {
                return _S721;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_1->jac), density_2 / r_1->jac);
        }
        uint _S920 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S921 = _S920 == 1U;
        Reservoir here_0 = chain_0;
        uint _S922 = insertBits_0(0U, b_4, 5U, 5U);
        uint _S923 = insertBits_0(_S922, 1U, 10U, 2U);
        uint _S924 = insertBits_0(_S923, (&prev_0)->lobe, 15U, 3U);
        bool _S925 = (&prev_0)->inside;
        uint _S926 = _slang_select(_S925, 1U,0U);
        uint _S927 = insertBits_0(_S924, _S926, 22U, 1U);
        (&here_0)->path = _S927;
        float _S928 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S928;
        fcptWithReservoirHit((&here_0), (&hit_1));
        bool _S929;
        if(replay_1)
        {
            _S929 = _S725 == 1U;
        }
        else
        {
            _S929 = false;
        }
        bool _S930;
        if(_S929)
        {
            _S930 = b_4 == _S724;
        }
        else
        {
            _S930 = false;
        }
        bool _S931 = b_4 == _S736;
        bool _S932;
        if(_S931)
        {
            bool _S933 = !scatter_2;
            if(_S933)
            {
                _S932 = true;
            }
            else
            {
                bool _S934 = _S725 != 1U;
                if(_S934)
                {
                    _S932 = _S725 != 3U;
                }
                else
                {
                    _S932 = false;
                }
            }
        }
        else
        {
            _S932 = false;
        }
        bool _S935;
        if(_S932)
        {
            _S935 = _S725 == 2U;
        }
        else
        {
            _S935 = false;
        }
        bool _S936;
        if(_S935)
        {
            _S936 = !_S891;
        }
        else
        {
            _S936 = false;
        }
        bool _S937;
        if(_S936)
        {
            _S937 = _S726 != 4U;
        }
        else
        {
            _S937 = false;
        }
        bool _S938 = _S724 == _S723;
        bool _S939;
        if(_S938)
        {
            _S939 = _S726 == 0U;
        }
        else
        {
            _S939 = false;
        }
        bool _S940;
        if(_S939)
        {
            _S940 = ((&hit_1)->instance_index) == (_S737.instance_index);
        }
        else
        {
            _S940 = false;
        }
        bool _S941;
        if(_S940)
        {
            _S941 = ((&hit_1)->triangle_index) == (_S737.triangle_index);
        }
        else
        {
            _S941 = false;
        }
        bool _S942;
        if(_S941)
        {
            _S942 = _S891;
        }
        else
        {
            _S942 = false;
        }
        bool _S943 = _slang_select(_S930, _S942,_S937);
        bool _S944;
        if(nee_0)
        {
            _S944 = _slang_select(replay_1, _S943,scatter_2);
        }
        else
        {
            _S944 = false;
        }
        TreeSample _S945 = TreeSample_x24init_0(_S720, _S720, 0.0f, 0U);
        float3  throughput_6;
        float3  lit_0;
        if(_S944)
        {
            float3  _S946 = (&ray_2)->origin;
            if(_S900)
            {
                throughput_6 = _S720;
            }
            else
            {
                throughput_6 = _S893.smooth_n;
            }
            FKSurface _S947 = surface_11;
            uint _S948 = stream(_S748, b_4 + 64U);
            uint _S949 = arrivalLobe_0(b_4, (&prev_0)->lobe);
            FKSurface _S950 = surface_11;
            FKHit _S951 = hit_1;
            ShadowContext _S952 = shadowContext_0(&_S950, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_4, _S949, (&hit_1)->distance, width_2, &_S951, _S900);
            ShadowContext _S953 = _S952;
            TreeSample _S954 = sampleLightTree_0(_S946, throughput_6, surface_11.geometry_n, surface_11.geometry_offset, _S905, _S948, &_S953);
            bool _S955 = any_0((_S954.radiance) != _S720);
            if(_S955)
            {
                if(_S900)
                {
                    uint _S956 = (fcptMaxBounces());
                    bool _S957 = b_4 < _S956;
                    FKSurface _S958 = surface_11;
                    TreeSample _S959 = _S954;
                    float3  _S960 = hairLight_0(&_S958, (&ray_2)->unit_direction, &_S959, _S957);
                    lit_0 = _S960;
                }
                else
                {
                    float _S961 = _S895.x;
                    float _S962 = _S895.y;
                    uint _S963 = (fcptMaxBounces());
                    bool _S964 = b_4 < _S963;
                    TreeSample _S965 = _S954;
                    BSDFMaterial _S966 = _S892.material;
                    float3  _S967 = lightBSDF_0((&ray_2)->unit_direction, &_S965, _S893.smooth_n, _S947.geometry_n, &_S966, _S961, _S962, _S964, surface_11.random_state);
                    lit_0 = _S967;
                }
            }
            else
            {
                lit_0 = _S720;
            }
            light_3 = _S954;
        }
        else
        {
            light_3 = _S945;
            lit_0 = _S720;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S968;
        bool _S969;
        float density_4;
        if(_S930)
        {
            bool _S970 = ((&hit_1)->instance_index) != (_S737.instance_index);
            if(_S970)
            {
                viewed_1 = true;
            }
            else
            {
                viewed_1 = ((&hit_1)->triangle_index) != (_S737.triangle_index);
            }
            if(viewed_1)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = !_S891;
            }
            if(refracted_4)
            {
                return _S721;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S938)
            {
                wrong_side_0 = _S726 == 1U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            if(_S938)
            {
                _S968 = _S726 == 0U;
            }
            else
            {
                _S968 = false;
            }
            if(_S968)
            {
                bool _S971 = !nee_0;
                if(_S971)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S972 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S972 > 0.0f);
                }
                if(passes_0)
                {
                    return _S721;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            if(_S938)
            {
                _S969 = _S726 == 4U;
            }
            else
            {
                _S969 = false;
            }
            if(_S969)
            {
                bool _S973 = !nee_0;
                if(_S973)
                {
                    return _S721;
                }
                float _S974 = environmentPdf_0(r_1->dir);
                float3  _S975 = skyBSDF((&ray_2)->unit_direction, r_1->dir, surface_11, _S895, is_inside_6, _S974, surface_11.random_state);
                return Shift_x24init_0(throughput_7 * _S975 * r_1->radiance / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            uint _S976 = extractBits_0(_S722, 21U, 1U);
            bool _S977 = nee_0 != (_S976 == 1U);
            if(_S977)
            {
                return _S721;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S931;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S978 = !scatter_2;
                if(_S978)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S979 = _S725 != 1U;
                    if(_S979)
                    {
                        refracted_4 = _S725 != 3U;
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
                bool _S980 = _S725 == 2U;
                if(_S980)
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
                    passes_0 = _S726 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    uint _S981 = stream(_S748, b_4 + 448U);
                    FKRay _S982 = ray_2;
                    FKSurface _S983 = surface_11;
                    SkySample _S984 = sampleSky_0(&_S982, &_S983, _S895, is_inside_6, _S981, surface_11.random_state);
                    return Shift_x24init_0(throughput_5 * _S984.color, 1.0f);
                }
                if(_S980)
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
                    float _S985 = rgb_to_greyscale(light_3.radiance);
                    bool _S986 = !(_S985 > 0.0f);
                    if(_S986)
                    {
                        return _S721;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S735)
                {
                    passes_0 = _S726 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S862;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S735)
                {
                    passes_0 = _S726 == 1U;
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
                return _S721;
            }
            else
            {
                bool _S987 = !replay_1;
                if(_S987)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S988 = b_4 > 0U;
                    if(_S988)
                    {
                        Reservoir candidate_4 = chain_0;
                        if(_S921)
                        {
                            float3  _S989 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_4)->radiance = _S989;
                        }
                        else
                        {
                            if(_S891)
                            {
                                candidate_4 = here_0;
                            }
                        }
                        float3  _S990 = throughput_5 * emission_1;
                        Reservoir _S991 = withEnd(candidate_4, 1U, b_4, _S990);
                        offer(sel_1, _S991, _S990 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S992 = throughput_5 * emission_1;
                        float3  _S993 = sel_1->glow + _S992;
                        sel_1->glow = _S993;
                    }
                    if(nee_0)
                    {
                        float3  _S994 = throughput_5 * lit_0;
                        Reservoir candidate_5 = chain_0;
                        if(_S921)
                        {
                            float3  _S995 = safeDivide(_S994, chain_throughput_0);
                            (&candidate_5)->radiance = _S995;
                        }
                        else
                        {
                            if(_S891)
                            {
                                candidate_5 = here_0;
                                uint _S996 = insertBits_0((&candidate_5)->path, 1U, 21U, 1U);
                                (&candidate_5)->path = _S996;
                                (&candidate_5)->dir = light_3.dir;
                                (&candidate_5)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S997 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S998 = insertBits_0(_S997, 2U, 10U, 2U);
                                (&candidate_5)->path = _S998;
                            }
                        }
                        Reservoir _S999 = withEnd(candidate_5, 0U, b_4, _S994);
                        offer(sel_1, _S999, _S994 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S900)
                        {
                            _S968 = false;
                        }
                        else
                        {
                            bool _S1000 = environmentMapped_0();
                            _S968 = _S1000;
                        }
                    }
                    else
                    {
                        _S968 = false;
                    }
                    if(_S968)
                    {
                        uint _S1001 = (fcptMaxBounces());
                        _S969 = b_4 < _S1001;
                    }
                    else
                    {
                        _S969 = false;
                    }
                    if(_S969)
                    {
                        uint _S1002 = stream(_S748, b_4 + 448U);
                        FKRay _S1003 = ray_2;
                        FKSurface _S1004 = surface_11;
                        SkySample _S1005 = sampleSky_0(&_S1003, &_S1004, _S895, is_inside_6, _S1002, surface_11.random_state);
                        float3  _S1006 = throughput_5 * _S1005.color;
                        Reservoir candidate_6 = chain_0;
                        if(_S921)
                        {
                            float3  _S1007 = safeDivide(_S1006, chain_throughput_0);
                            (&candidate_6)->radiance = _S1007;
                        }
                        else
                        {
                            if(_S891)
                            {
                                candidate_6 = here_0;
                                uint _S1008 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1008;
                                (&candidate_6)->dir = _S1005.dir;
                                (&candidate_6)->radiance = _S1005.radiance;
                            }
                            else
                            {
                                uint _S1009 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S1010 = insertBits_0(_S1009, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1010;
                            }
                        }
                        Reservoir _S1011 = withEnd(candidate_6, 4U, b_4, _S1006);
                        offer(sel_1, _S1011, _S1006 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1012;
        bool _S1013;
        bool straight_0;
        bool _S1014;
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
                viewed_1 = _S931;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1027 = extractBits_0(_S722, 15U, 3U);
            uint _S1028 = extractBits_0(_S722, 18U, 3U);
            uint _S1029 = _slang_select(_S930, _S1028,_S1027);
            float3  _S1030 = r_1->dir;
            bool refracted_5 = _S1029 == 1U;
            SampleBSDF _S1031 = SampleBSDF_x24init_0(_S720, _S720, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_8 = _S1031;
            float3  reconnection_1;
            SampleBSDF _S1032;
            if(viewed_1)
            {
                uint _S1033 = extractBits_0(_S722, 22U, 1U);
                bool _S1034 = is_inside_6 != (_S1033 == 1U);
                if(_S1034)
                {
                    return _S721;
                }
                bool _S1035 = _S725 == 1U;
                if(_S1035)
                {
                    float3  _S1036 = (fcptHitPosition((_S737)));
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
                        refracted_4 = _S1029 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1039 = throughput_8 - (&ray_2)->origin;
                        float3  _S1040 = _slang_select(_S1035, _S1039,_S1030);
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
                    FKSurface _S1042 = surface_11;
                    float3  _S1043 = - _S893.smooth_n;
                    bool _S1044 = is_inside_6 != refracted_4;
                    float3  _S1045 = _slang_select(_S1044, _S1043,_S893.smooth_n);
                    float3  _S1046 = throughput_8 - (_S1041 + make_float3 (_S1042.geometry_offset) * _S1045);
                    float3  _S1047 = ((((_S1046)) * make_float3(rnorm3df(((_S1046)).x, ((_S1046)).y, ((_S1046)).z))));
                    reconnection_1 = _S1047;
                }
                else
                {
                    reconnection_1 = _S1030;
                }
                if(_S900)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1048 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_11.geometry_n);
                    wrong_side_0 = _S1048;
                }
                if(wrong_side_0)
                {
                    return _S721;
                }
                float3  _S1049 = throughput_8;
                throughput_8 = reconnection_1;
                b_7 = _S1029;
                wrong_side_0 = false;
                reconnection_1 = _S1049;
            }
            else
            {
                bool _S1050 = !_S930;
                if(_S1050)
                {
                    SampleBSDF bsdf_sampled_0;
                    if(_S900)
                    {
                        SampleBSDF _S1051 = (fcptSampleHair((surface_11.hair), (_S892.material.albedo), (_S892.material.specular_tint), ((&ray_2)->unit_direction), (surface_11.random_state)));
                        _S1032 = _S1051;
                    }
                    else
                    {
                        SampleBSDF _S1052 = sampleBSDF((&ray_2)->unit_direction, _S893.smooth_n, _S892.material, _S895.x, _S895.y, surface_11.random_state, make_float2 (0.0f));
                        _S1032 = _S1052;
                    }
                    bsdf_sampled_0 = _S1032;
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
                            return _S721;
                        }
                        break;
                    }
                    if(_S900)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1053 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_11.geometry_n);
                        wrong_side_0 = _S1053;
                    }
                    if(wrong_side_0)
                    {
                        _S968 = (_S892.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S968 = false;
                    }
                    if(_S968)
                    {
                        SampleBSDF _S1054 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n, _S892.material, _S895.x, _S895.y, (&bsdf_sampled_0)->random_state, make_float2 (0.0f));
                        (&bsdf_sampled_0)->unit_direction = _S1054.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1054.refracted;
                        (&bsdf_sampled_0)->throughput = _S1054.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1055 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n)) * surface_11.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1055;
                        }
                    }
                    uint _S1056 = (&bsdf_sampled_0)->lobe;
                    float3  _S1057 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1058 = (&bsdf_sampled_0)->refracted;
                    lobe_8 = bsdf_sampled_0;
                    float _S1059 = (&bsdf_sampled_0)->pdf;
                    float _S1060 = _slang_select(wrong_side_0, 0.0f,_S1059);
                    (&lobe_8)->pdf = _S1060;
                    throughput_8 = _S1057;
                    b_7 = _S1056;
                    refracted_4 = _S1058;
                }
                else
                {
                    throughput_8 = _S1030;
                    b_7 = _S1029;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S968 = true;
            }
            else
            {
                _S968 = _S930;
            }
            if(_S968)
            {
                if(_S900)
                {
                    SampleBSDF _S1061 = (fcptConnectHair((surface_11.hair), (_S892.material.albedo), (_S892.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    _S1032 = _S1061;
                }
                else
                {
                    SampleBSDF _S1062 = connectBSDF((&ray_2)->unit_direction, throughput_8, _S893.smooth_n, _S892.material, _S895.x, _S895.y, b_7, surface_11.random_state);
                    _S1032 = _S1062;
                }
                lobe_8 = _S1032;
            }
            bool _S1063 = b_7 == 0U;
            if(_S1063)
            {
                _S969 = true;
            }
            else
            {
                _S969 = b_7 == 4U;
            }
            if(_S900)
            {
                _S1012 = false;
            }
            else
            {
                bool _S1064 = !_S969;
                if(_S1064)
                {
                    bool _S1065 = (_S892.material.roughness) == 0.0f;
                    if(_S1065)
                    {
                        _S1012 = true;
                    }
                    else
                    {
                        bool _S1066 = b_7 == 1U;
                        if(_S1066)
                        {
                            _S1012 = (_S895.x) == (_S895.y);
                        }
                        else
                        {
                            _S1012 = false;
                        }
                    }
                }
                else
                {
                    _S1012 = false;
                }
            }
            bool _S1067 = !_S900;
            if(_S1067)
            {
                _S1013 = b_7 == 1U;
            }
            else
            {
                _S1013 = false;
            }
            if(_S1013)
            {
                straight_0 = (_S892.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1014 = _S1067;
            }
            else
            {
                _S1014 = false;
            }
            if(_S1014)
            {
                _S1015 = b_7 == 1U;
            }
            else
            {
                _S1015 = false;
            }
            if(_S1015)
            {
                _S1016 = (_S895.x) == (_S895.y);
            }
            else
            {
                _S1016 = false;
            }
            BSDFMaterial _S1068 = _S892.material;
            bool _S1069 = isTranslucent_0(&_S1068);
            if(_S1069)
            {
                _S1017 = _S1063;
            }
            else
            {
                _S1017 = false;
            }
            if(_S1017)
            {
                _S1018 = (dot_0(throughput_8, surface_11.geometry_n)) < 0.0f;
            }
            else
            {
                _S1018 = false;
            }
            if(nee_0)
            {
                _S1019 = !_S1012;
            }
            else
            {
                _S1019 = false;
            }
            if(_S1019)
            {
                _S1020 = !wrong_side_0;
            }
            else
            {
                _S1020 = false;
            }
            if(_S1020)
            {
                float _S1070 = (&lobe_8)->pdf;
                float3  _S1071 = (&ray_2)->origin;
                float3  _S1072 = _slang_select(_S905, _S720,_S893.smooth_n);
                float3  _S1073 = (&ray_2)->origin;
                FKSurface _S1074 = surface_11;
                float3  _S1075 = - _S893.smooth_n;
                float3  _S1076 = _slang_select(_S1018, _S1075,_S893.smooth_n);
                NEEVertex _S1077 = NEEVertex_x24init_0(false, _S1070, _S1071, _S1072, _S1073 + make_float3 (_S1074.geometry_offset) * _S1076);
                nee_vertex_0 = _S1077;
            }
            else
            {
                if(_S900)
                {
                    _S1021 = true;
                }
                else
                {
                    bool _S1078 = b_7 != 1U;
                    if(_S1078)
                    {
                        _S1021 = true;
                    }
                    else
                    {
                        _S1021 = (_S895.x) != (_S895.y);
                    }
                }
                if(_S1021)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1079 = withinInverseFootprint((&lobe_8)->pdf, _S969, (&prev_0)->cos, (&hit_1)->distance, threshold_2);
            bool _S1080 = roughLobe((&lobe_8)->pdf, _S969, _S892.material.roughness);
            if(_S930)
            {
                bool _S1081 = !_S1079;
                if(_S1081)
                {
                    return _S721;
                }
                bool _S1082 = _S726 != 1U;
                if(_S1082)
                {
                    _S1021 = _S726 != 2U;
                }
                else
                {
                    _S1021 = false;
                }
                if(_S1021)
                {
                    float _S1083 = (&lobe_8)->pdf;
                    float _S1084 = _slang_select(nee_0, _S1083,0.0f);
                    float _S1085 = escapeWeight_0(_S1084, _S1030);
                    if(_S938)
                    {
                        passes_0 = _S732;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1086 = _slang_select(passes_0, _S1085,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_8)->throughput * make_float3 ((&lobe_8)->pdf)) * r_1->radiance * make_float3 (_S1086) / make_float3 (r_1->jac), density_4 * (&lobe_8)->pdf / r_1->jac);
                }
                float3  _S1087 = throughput_6 * make_float3 ((&lobe_8)->pdf);
                float _S1088 = density_4 * (&lobe_8)->pdf;
                throughput_9 = _S1087;
                density_6 = _S1088;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1089 = (fcptLayers((hit_1)));
            bool _S1090 = b_7 == 1U;
            bool _S1091 = passesLayer_0(_S1089, _S1090, passes_0);
            if(viewed_1)
            {
                _S1021 = _S1091;
            }
            else
            {
                _S1021 = false;
            }
            if(_S1021)
            {
                return _S721;
            }
            if(replay_1)
            {
                _S1022 = b_4 <= _S736;
            }
            else
            {
                _S1022 = false;
            }
            if(_S1022)
            {
                _S1023 = _S891;
            }
            else
            {
                _S1023 = false;
            }
            if(_S1023)
            {
                _S1024 = _S1079;
            }
            else
            {
                _S1024 = false;
            }
            if(_S1024)
            {
                _S1025 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1025 = !_S1080;
                }
                else
                {
                    _S1025 = false;
                }
            }
            if(_S1025)
            {
                return _S721;
            }
            if(viewed_1)
            {
                float3  _S1092 = throughput_9 * ((&lobe_8)->throughput * make_float3 ((&lobe_8)->pdf));
                float _S1093 = (&lobe_8)->pdf;
                throughput_10 = _S1092;
                sky_pdf_2 = _S1093;
            }
            else
            {
                float3  _S1094 = throughput_9 * max_0((&lobe_8)->throughput, _S720);
                throughput_10 = _S1094;
                sky_pdf_2 = density_6;
            }
            bool _S1095 = !replay_1;
            if(_S1095)
            {
                _S1026 = !_S921;
            }
            else
            {
                _S1026 = false;
            }
            bool _S1096;
            if(_S1026)
            {
                _S1096 = _S891;
            }
            else
            {
                _S1096 = false;
            }
            bool _S1097;
            if(_S1096)
            {
                _S1097 = _S1079;
            }
            else
            {
                _S1097 = false;
            }
            float3  chain_throughput_1;
            if(_S1097)
            {
                chain_0 = here_0;
                uint _S1098 = insertBits_0((&chain_0)->path, b_7, 18U, 3U);
                uint _S1099 = _slang_select(nee_0, 1U,0U);
                uint _S1100 = insertBits_0(_S1098, _S1099, 21U, 1U);
                (&chain_0)->path = _S1100;
                float _S1101 = (&chain_0)->jac * (&lobe_8)->pdf;
                (&chain_0)->jac = _S1101;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1102 = surface_11;
            Vertex _S1103 = Vertex_x24init_0(_S1080, b_7, (&lobe_8)->pdf, (F32_abs((dot_0(surface_11.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1103;
            float _S1104 = (&lobe_8)->pdf;
            bool _S1105;
            if(_S1090)
            {
                _S1105 = (_S895.x) == (_S895.y);
            }
            else
            {
                _S1105 = false;
            }
            float sky_pdf_3 = _slang_select(_S1105, sky_pdf_0,_S1104);
            float _S1106 = _slang_select(_S900, 0.0f,sky_pdf_3);
            float _S1107 = widened_0(spread_1, (&lobe_8)->pdf, _S1012);
            bool _S1108;
            if(refracted_4)
            {
                _S1108 = !_S1018;
            }
            else
            {
                _S1108 = false;
            }
            bool is_inside_7;
            if(_S1108)
            {
                bool _S1109 = !is_inside_6;
                is_inside_7 = _S1109;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1110 = surface_11;
            bool _S1111 = boundsVolume_0(&_S1110);
            bool _S1112;
            if(_S1111)
            {
                _S1112 = !_S1091;
            }
            else
            {
                _S1112 = false;
            }
            if(_S1112)
            {
                FKSurface faced_2 = surface_11;
                float3  _S1113 = - _S1102.geometry_n;
                float3  _S1114 = _slang_select(turned_1, _S1113,_S1102.geometry_n);
                (&faced_2)->geometry_n = _S1114;
                FKMedium _S1115 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKSurface _S1116 = faced_2;
                FKMedium _S1117 = _S1115;
                MediumSides _S1118 = mediumSides_0(&_S1116, &_S1117, filling_2, (&ray_2)->unit_direction);
                bool _S1119 = leavesInFront_0((&faced_2)->geometry_n, throughput_8, _S1102.geometry_n);
                float3  _S1120 = _slang_select(_S1119, _S1118.front.scatter,_S1118.behind.scatter);
                scatter_in_0 = _S1120;
                float3  _S1121 = _slang_select(_S1119, _S1118.front.extinction,_S1118.behind.extinction);
                extinction_in_0 = _S1121;
                float _S1122 = _slang_select(_S1119, _S1118.front.g,_S1118.behind.g);
                g_in_0 = _S1122;
                uint _S1123 = _S1118.fillings.x;
                uint _S1124 = _S1118.fillings.y;
                uint _S1125 = _slang_select(_S1119, _S1124,_S1123);
                bool _S1126 = (fcptVaryingUsed());
                uint _S1127 = _slang_select(_S1126, _S1125,4294967295U);
                filling_2 = _S1127;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1128 = !_S1091;
            if(_S1128)
            {
                FKSurface _S1129 = surface_11;
                float _S1130 = _slang_select(straight_0, 0.0f,_S1129.geometry_offset);
                float3  _S1131 = - _S893.smooth_n;
                bool _S1132 = is_inside_7 != _S1018;
                float3  _S1133 = _slang_select(_S1132, _S1131,_S893.smooth_n);
                float3  _S1134 = (&ray_2)->origin + make_float3 (_S1130) * _S1133;
                (&ray_2)->origin = _S1134;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1091;
            viewed_1 = _S1016;
            sky_pdf_2 = _S1106;
            spread_4 = _S1107;
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
        bool _S1135 = !replay_1;
        float density_7;
        if(_S1135)
        {
            if(_S862)
            {
                float3  _S1136 = throughput_9 * emission_1;
                Reservoir candidate_7 = chain_0;
                uint _S1137 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1138 = _S1137 == 1U;
                if(_S1138)
                {
                    float3  _S1139 = safeDivide(_S1136, chain_throughput_0);
                    (&candidate_7)->radiance = _S1139;
                }
                Reservoir _S1140 = withEnd(candidate_7, 2U, b_4, _S1136);
                offer(sel_1, _S1140, _S1136 * make_float3 (scale_1) / make_float3 (density_6));
            }
            if(_S862)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1141 = survivalProbability(throughput_9, density_6);
                density_7 = _S1141;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1142 = stream(_S748, b_4 + 128U);
            Random _S1143 = pcg(_S1142);
            bool _S1144 = density_7 < (_S1143.value);
            if(_S1144)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1145 = (fcptMaxBounces());
                wrong_side_0 = b_4 >= _S1145;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1146 = density_6 * density_7;
            density_7 = _S1146;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1147 = layer_0 ^ 1U;
        uint _S1148 = _slang_select(passes_0, _S1147,0U);
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
            uint _S1149 = b_7 + 1U;
            b_4 = _S1149;
            layer_0 = _S1148;
            continue;
        }
        FKRay _S1150 = ray_2;
        float _S1151 = distance_5(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S931;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S725 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1152 = _slang_select(wrong_side_0, _S1151,4.294967296e+09f);
        bool _S1153 = !_S900;
        if(straight_0)
        {
            _S968 = true;
        }
        else
        {
            _S968 = _S900;
        }
        FKHit _S1154;
        if(_S968)
        {
            _S1154 = hit_1;
        }
        else
        {
            _S1154 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
        }
        FKHit _S1155 = (fcptTraverseInstanceBVH((_S1150), (_S867), (_S1152), (_S1153), (_S1154), (viewed_1)));
        hit_1 = _S1155;
        if(replay_1)
        {
            _S969 = _S931;
        }
        else
        {
            _S969 = false;
        }
        if(_S969)
        {
            _S1012 = _S725 == 1U;
        }
        else
        {
            _S1012 = false;
        }
        if(_S1012)
        {
            _S1013 = ((&hit_1)->instance_index) == (_S737.instance_index);
        }
        else
        {
            _S1013 = false;
        }
        if(_S1013)
        {
            _S1014 = ((&hit_1)->triangle_index) == (_S737.triangle_index);
        }
        else
        {
            _S1014 = false;
        }
        if(_S1014)
        {
            (&hit_1)->uv = _S737.uv;
            float _S1156 = distance_5(reconnection_0, (&ray_2)->origin);
            (&hit_1)->distance = _S1156;
        }
        if(replay_1)
        {
            _S1015 = _S931;
        }
        else
        {
            _S1015 = false;
        }
        if(_S1015)
        {
            _S1016 = _S725 == 3U;
        }
        else
        {
            _S1016 = false;
        }
        if(_S1016)
        {
            _S1017 = ((&hit_1)->instance_index) != 4294967295U;
        }
        else
        {
            _S1017 = false;
        }
        if(_S1017)
        {
            return _S721;
        }
        Reservoir _S1157 = chain_0;
        uint _S1158 = filling_2;
        for(;;)
        {
            bool _S1159 = (fcptVaryingUsed());
            if(_S1159)
            {
                _S1018 = _S1158 != 4294967295U;
            }
            else
            {
                _S1018 = false;
            }
            float _S1160;
            if(_S1018)
            {
                float _S1161 = (fcptMajorant((_S1158)));
                _S1160 = _S1161;
            }
            else
            {
                _S1160 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1019 = _S931;
            }
            else
            {
                _S1019 = false;
            }
            if(_S1019)
            {
                _S1020 = _S725 == 1U;
            }
            else
            {
                _S1020 = false;
            }
            if(_S1020)
            {
                _S1021 = _S1160 > 0.0f;
            }
            else
            {
                _S1021 = false;
            }
            if(_S1021)
            {
                ended_0 = _S721;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_3 = width_2;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_7 = b_4;
                _S1022 = true;
                break;
            }
            bool _S1162 = (&prev_0)->rough;
            if(_S1162)
            {
                _S1022 = !(_S1160 > 0.0f);
            }
            else
            {
                _S1022 = false;
            }
            (&prev_0)->rough = _S1022;
            uint _S1163 = b_4 + 320U;
            bool _S1164 = b_4 == 4294967295U;
            uint _S1165 = _slang_select(_S1164, 384U,_S1163);
            uint _S1166 = stream(_S748, _S1165);
            uint tracking_1 = _S1166;
            weight_1 = throughput_3;
            glowed_0 = _S720;
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
                    _S719 = int(2);
                    break;
                }
                uint _S1167 = b_7 + 320U;
                bool _S1168 = b_7 == 4294967295U;
                uint _S1169 = _slang_select(_S1168, 384U,_S1167);
                uint _S1170 = stream(_S748, _S1169);
                Random _S1171 = pcg(_S1170);
                float _S1172 = freeFlight_0(_S1171.value, _S1160);
                if(_S1018)
                {
                    float3  _S1173 = (&ray_2)->origin;
                    float3  _S1174 = (&ray_2)->unit_direction;
                    float _S1175 = (&hit_1)->distance;
                    uint _S1176 = _slang_select(_S1168, 0U,b_7);
                    uint _S1177 = (&prev_0)->lobe;
                    uint _S1178 = _slang_select(_S1168, 3U,_S1177);
                    float _S1179 = (fcptTrackMedium((_S1158), (_S1173), (_S1174), (_S1175), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1176), (_S1178), (_S1168)));
                    spread_3 = _S1179;
                }
                else
                {
                    spread_3 = _S1172;
                }
                bool _S1180 = !(spread_3 < ((&hit_1)->distance));
                if(_S1180)
                {
                    _S719 = int(2);
                    break;
                }
                if(_S1018)
                {
                    _S1023 = _S1135;
                }
                else
                {
                    _S1023 = false;
                }
                if(_S1023)
                {
                    float3  _S1181 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1182 = sel_1->glow + _S1181;
                    sel_1->glow = _S1182;
                }
                else
                {
                }
                glowed_0 = _S720;
                uint b_8 = b_7 + 1U;
                float3  _S1183 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1183;
                float3  _S1184 = flightWeight_0(scatter_in_0, extinction_in_0, _S1160, spread_3, true);
                float3  _S1185 = weight_1;
                float3  _S1186 = _slang_select(_S1018, _S1185,_S1184);
                float3  throughput_11 = throughput_10 * _S1186;
                uint _S1187 = stream(_S748, b_8 + 320U);
                tracking_1 = _S1187;
                weight_1 = throughput_3;
                float width_6 = width_3 + spread_2 * spread_3;
                float _S1188 = spread_2 + 3.14159274101257324f;
                bool _S1189 = scatterSampled_0(replay_1, b_8, _S736, _S1018);
                TreeSample light_4;
                if(_S1189)
                {
                    float3  _S1190 = (&ray_2)->origin;
                    float3  _S1191 = (&ray_2)->unit_direction;
                    float3  _S1192 = (&ray_2)->unit_direction;
                    uint _S1193 = stream(_S748, b_8 + 64U);
                    float3  _S1194 = extinction_in_0;
                    float3  _S1195 = extinction_in_0;
                    uint2  _S1196 = make_uint2 (_S1158);
                    float3  _S1197 = (&ray_2)->unit_direction;
                    uint _S1198 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                    FKHit _S1199 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                    FKHit _S1200 = _S1199;
                    ShadowContext _S1201 = ShadowContext_x24init_0(_S1194, _S1195, _S1196, _S1197, b_8, _S1198, false, spread_3, width_6, &_S1200, false);
                    ShadowContext _S1202 = _S1201;
                    TreeSample _S1203 = sampleLightTree_0(_S1190, _S1191, _S1192, 0.0f, true, _S1193, &_S1202);
                    light_4 = _S1203;
                }
                else
                {
                    light_4 = _S945;
                }
                float _S1204 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1205 = (fcptMaxBounces());
                bool _S1206 = b_8 < _S1205;
                if(_S1206)
                {
                    _S1024 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1024 = false;
                }
                float _S1207 = _slang_select(_S1024, _S1204,0.0f);
                float3  _S1208 = throughput_11 * light_4.radiance;
                float _S1209 = powerHeuristic(light_4.density, _S1207);
                float3  _S1210 = _S1208 * make_float3 (_S1204 * _S1209);
                float3  _S1211 = _slang_select(_S1189, _S1210,_S720);
                if(replay_1)
                {
                    _S1025 = b_8 == _S736;
                }
                else
                {
                    _S1025 = false;
                }
                if(_S1025)
                {
                    bool _S1212 = _S725 == 2U;
                    if(_S1212)
                    {
                        float _S1213 = rgb_to_greyscale(_S1211);
                        _S1026 = _S1213 > 0.0f;
                    }
                    else
                    {
                        _S1026 = false;
                    }
                    if(_S1026)
                    {
                        Shift _S1214 = Shift_x24init_0(_S1211, 1.0f);
                        _S719 = int(1);
                        ended_0 = _S1214;
                        spread_3 = _S1188;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_5 = b_8;
                        break;
                    }
                    _S719 = int(1);
                    ended_0 = _S721;
                    spread_3 = _S1188;
                    width_4 = width_6;
                    throughput_8 = throughput_11;
                    b_5 = b_8;
                    break;
                }
                if(_S1135)
                {
                    Reservoir candidate_8 = _S1157;
                    uint _S1215 = extractBits_0(_S1157.path, 10U, 2U);
                    bool _S1216 = _S1215 == 1U;
                    if(_S1216)
                    {
                        float3  _S1217 = safeDivide(_S1211, chain_throughput_0);
                        (&candidate_8)->radiance = _S1217;
                    }
                    else
                    {
                        uint _S1218 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                        uint _S1219 = insertBits_0(_S1218, 2U, 10U, 2U);
                        (&candidate_8)->path = _S1219;
                    }
                    Reservoir _S1220 = withEnd(candidate_8, 0U, b_8, _S1211);
                    offer(sel_1, _S1220, _S1211 * make_float3 (scale_1) / make_float3 (density_3));
                    float _S1221 = survivalProbability(throughput_11, density_3);
                    uint _S1222 = stream(_S748, b_8 + 128U);
                    Random _S1223 = pcg(_S1222);
                    bool _S1224 = _S1221 < (_S1223.value);
                    if(_S1224)
                    {
                        _S1026 = true;
                    }
                    else
                    {
                        uint _S1225 = (fcptMaxBounces());
                        _S1026 = b_8 >= _S1225;
                    }
                    if(_S1026)
                    {
                        _S719 = int(1);
                        ended_0 = _S721;
                        spread_3 = _S1188;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_5 = b_8;
                        break;
                    }
                    float _S1226 = density_3 * _S1221;
                    density_3 = _S1226;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1227 = stream(_S748, b_8);
                float3  _S1228 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1227, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1228;
                NEEVertex _S1229 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S720, (&ray_2)->origin);
                nee_vertex_0 = _S1229;
                Vertex _S1230 = scatteredVertex_0(is_inside_5);
                prev_0 = _S1230;
                float _S1231 = (&prev_0)->pdf;
                FKRay _S1232 = ray_2;
                FKHit _S1233 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1234 = (fcptTraverseInstanceBVH((_S1232), (true), (4.294967296e+09f), (false), (_S1233), (false)));
                hit_1 = _S1234;
                b_7 = b_8;
                throughput_10 = throughput_11;
                spread_2 = _S1188;
                width_3 = width_6;
                sky_pdf_1 = _S1231;
            }
            if(_S719 != int(2))
            {
                spread_2 = spread_3;
                width_3 = width_4;
                throughput_10 = throughput_8;
                b_7 = b_5;
                _S1022 = true;
                break;
            }
            ended_0 = _S721;
            _S1022 = false;
            break;
        }
        if(_S1022)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1023 = b_7 == b_4;
        }
        else
        {
            _S1023 = false;
        }
        bool _S1235 = ((&hit_1)->instance_index) == 4294967295U;
        if(_S1235)
        {
            bool _S1236 = !(&nee_vertex_0)->none;
            float _S1237 = _slang_select(_S1236, sky_pdf_1,0.0f);
            float _S1238 = escapeWeight_0(_S1237, (&ray_2)->unit_direction);
            float3  _S1239 = environment_0((&ray_2)->unit_direction, b_7, (&prev_0)->lobe);
            float3  _S1240 = throughput_10 * _S1239;
            if(replay_1)
            {
                bool _S1241 = b_7 == _S736;
                if(_S1241)
                {
                    passes_0 = _S725 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1240 * make_float3 (_S1238) / make_float3 (r_1->jac), density_3 / r_1->jac);
                }
                if(_S735)
                {
                    passes_0 = _S732;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_7 == _S723;
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
                    return Shift_x24init_0(_S1240 * make_float3 (_S1238), 1.0f);
                }
                return _S721;
            }
            Reservoir candidate_9 = chain_0;
            uint _S1242 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1243 = _S1242 == 1U;
            if(_S1243)
            {
                uint _S1244 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1245 = _S1244 == b_7;
                float _S1246 = _slang_select(_S1245, 1.0f,_S1238);
                float3  _S1247 = safeDivide(_S1240 * make_float3 (_S1246), chain_throughput_0);
                (&candidate_9)->radiance = _S1247;
            }
            else
            {
                bool _S1248 = (&prev_0)->rough;
                if(_S1248)
                {
                    uint _S1249 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                    uint _S1250 = insertBits_0(_S1249, 3U, 10U, 2U);
                    uint _S1251 = insertBits_0(_S1250, (&prev_0)->lobe, 15U, 3U);
                    bool _S1252 = (&prev_0)->inside;
                    uint _S1253 = _slang_select(_S1252, 1U,0U);
                    uint _S1254 = insertBits_0(_S1251, _S1253, 22U, 1U);
                    (&candidate_9)->path = _S1254;
                    (&candidate_9)->jac = (&prev_0)->pdf;
                    (&candidate_9)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1255 = _S1240 * make_float3 (_S1238);
            Reservoir _S1256 = withEnd(candidate_9, 3U, b_7, _S1255);
            offer(sel_1, _S1256, _S1255 * make_float3 (scale_1) / make_float3 (density_3));
            break;
        }
        float3  _S1257 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1257;
        bool _S1258 = (fcptVaryingUsed());
        if(_S1258)
        {
            _S1024 = filling_2 != 4294967295U;
        }
        else
        {
            _S1024 = false;
        }
        if(_S1024)
        {
            if(_S1135)
            {
                float3  _S1259 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1260 = sel_1->glow + _S1259;
                sel_1->glow = _S1260;
            }
            float3  _S1261 = throughput_10 * weight_1;
            throughput_8 = _S1261;
        }
        else
        {
            float3  _S1262 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
            float3  _S1263 = throughput_10 * _S1262;
            throughput_8 = _S1263;
        }
        float _S1264 = width_3 + spread_2 * (&hit_1)->distance;
        viewed_0 = _S1023;
        width_2 = _S1264;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1149 = b_7 + 1U;
        b_4 = _S1149;
        layer_0 = _S1148;
    }
    return _S721;
}

static __device__ Shift shift_0(Domain * dom_1, Reservoir * r_2)
{
    Selection _S1265 = (Selection{});
    Selection sel_2 = _S1265;
    bool _S1266 = (r_2->w) <= 0.0f;
    if(_S1266)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1267 = walk_0(dom_1, r_2, true, 0.0f, &sel_2);
    return _S1267;
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
        *_slang_vector_get_element_ptr(&result_8, i_12) = (F32_tan((_slang_vector_get_element(x_17, i_12))));
        i_12 = i_12 + int(1);
    }
    return result_8;
}

static __device__ float3  acos_0(float3  x_18)
{
    float3  result_9;
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
        *_slang_vector_get_element_ptr(&result_9, i_13) = (F32_acos((_slang_vector_get_element(x_18, i_13))));
        i_13 = i_13 + int(1);
    }
    return result_9;
}

static __device__ float3  abs_0(float3  x_19)
{
    float3  result_10;
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
        *_slang_vector_get_element_ptr(&result_10, i_14) = (F32_abs((_slang_vector_get_element(x_19, i_14))));
        i_14 = i_14 + int(1);
    }
    return result_10;
}

__device__ Random normal_distribution(uint state_3)
{
    Random _S1268 = pcg(state_3);
    Random _S1269 = pcg(_S1268.state);
    float _S1270 = 6.28318548202514648f * _S1268.value;
    float _S1271 = (F32_sqrt((-2.0f * clamp_0((F32_log((_S1269.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1269.state, _S1271 * (F32_cos((_S1270))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1272;
    (&_S1272)->state = state_4;
    (&_S1272)->value = value_2;
    return _S1272;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1273 = normal_distribution(state_5);
    Random _S1274 = normal_distribution(_S1273.state);
    Random _S1275 = normal_distribution(_S1274.state);
    float3  _S1276 = make_float3 (_S1273.value, _S1274.value, _S1275.value);
    float3  _S1277 = ((((_S1276)) * make_float3(rnorm3df(((_S1276)).x, ((_S1276)).y, ((_S1276)).z))));
    return RandomSphere_x24init_0(_S1275.state, _S1277);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_14)
{
    float3  _S1278 = p1_0 - p0_0;
    float3  _S1279 = p2_0 - p0_0;
    float2  _S1280 = uv1_0 - uv0_0;
    float2  _S1281 = uv2_0 - uv0_0;
    float _S1282 = _S1280.x;
    float _S1283 = _S1281.y;
    float _S1284 = _S1280.y;
    float _S1285 = _S1281.x;
    float _S1286 = _S1282 * _S1283 - _S1284 * _S1285;
    float _S1287 = 1.0f / _S1286;
    float3  t_1 = (_S1278 * make_float3 (_S1283) - _S1279 * make_float3 (_S1284)) * make_float3 (_S1287);
    float3  _S1288 = (_S1279 * make_float3 (_S1282) - _S1278 * make_float3 (_S1285)) * make_float3 (_S1287);
    float3  _S1289 = t_1 - n_14 * make_float3 (dot_0(n_14, t_1));
    float3  t_2 = ((((_S1289)) * make_float3(rnorm3df(((_S1289)).x, ((_S1289)).y, ((_S1289)).z))));
    bool _S1290 = (dot_0(cross_0(n_14, t_2), _S1288)) > 0.0f;
    float3  t_3;
    if(_S1290)
    {
        float3  _S1291 = negate_0(t_2);
        t_3 = _S1291;
    }
    else
    {
        t_3 = t_2;
    }
    float3  _S1292 = cross_0(n_14, t_3);
    return makeMatrix<float, 3, 3> (t_3, _S1292, n_14);
}

__device__ float3  tangentToWorldNormalMap(float3  v_4, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_4, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1293 = t1_0 - t0_0;
    float3  _S1294 = t2_2 - t0_0;
    float3  _S1295 = t2_2 - t1_0;
    float _S1296 = (F32_min((length_0(_S1293)), ((F32_min((length_0(_S1294)), (length_0(_S1295)))))));
    float3  _S1297 = make_float3 (distance_5(position_0, t0_0), distance_5(position_0, t1_0), distance_5(position_0, t2_2));
    float3  _S1298 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1299 = dot_0(geometry_n_5, _S1298);
    float3  _S1300 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1301 = dot_0(geometry_n_5, _S1300);
    float3  _S1302 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1303 = acos_0(abs_0(make_float3 (_S1299, _S1301, dot_0(geometry_n_5, _S1302))));
    float3  _S1304 = clamp_1(tan_0(_S1303), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_0(dot_0(_S1297 * _S1304, uvw_0), 0.0f, _S1296 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_15, float3  n_15, BSDFMaterial material_16)
{
    float3  _S1305 = negate_0(dir_15);
    float _S1306 = sign_0(dot_0(n_15, _S1305));
    float3  _S1307 = n_15 * make_float3 (_S1306);
    AnisotropicFrame _S1308 = anisotropicFrame(material_16, _S1307);
    bool _S1309 = (_S1308.alphas.x) > 0.0f;
    if(_S1309)
    {
        float _S1310 = material_16.transmission * (1.0f - material_16.metallic);
        float3  _S1311 = negate_0(_S1307);
        float3  _S1312 = anisotropicLocal(dir_15, _S1308.tangent, _S1311);
        float _S1313 = anisotropicG1(_S1312, _S1308.alphas);
        return make_float3 (_S1310 * _S1313) * material_16.albedo;
    }
    float _S1314 = material_16.transmission * (1.0f - material_16.metallic);
    float _S1315 = material_16.roughness;
    float _S1316 = smithG1(_S1315 * _S1315, (F32_abs((dot_0(n_15, dir_15)))));
    return make_float3 (_S1314 * _S1316) * material_16.albedo;
}

__device__ float hairRow(float3  in_dir_10, float3  t_4, float3  out_dir_4, uint p_5, float w_2, float alpha_6, uint nt_0)
{
    uint _S1317 = p_5 % 4U;
    float _S1318 = w_2 * HAIR_WIDTHS_0[_S1317];
    float _S1319 = (F32_asin((clamp_0(dot_0(out_dir_4, t_4), -1.0f, 1.0f)))) - (F32_asin((clamp_0(dot_0(in_dir_10, t_4), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1317] * alpha_6;
    return ((F32_asinh((_S1319 / _S1318))) / (F32_asinh((3.14159274101257324f / _S1318))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_11, float3  t_5, float3  out_dir_5, uint np_0)
{
    float3  _S1320 = worldToTangent(out_dir_5, t_5);
    float3  _S1321 = worldToTangent(in_dir_11, t_5);
    return (F32_frac((((F32_atan2((_S1320.z), (_S1320.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1321.z), (1.17549435082228751e-38f - _S1321.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_12, float3  t_6, uint p_6, float row_0, float column_0, float w_3, float alpha_7, uint nt_1, uint np_1)
{
    float3  _S1322 = worldToTangent(in_dir_12, t_6);
    uint _S1323 = p_6 % 4U;
    float _S1324 = w_3 * HAIR_WIDTHS_0[_S1323];
    float _S1325 = (F32_asin((clamp_0(dot_0(in_dir_12, t_6), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1323] * alpha_7 + _S1324 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1324))))));
    float _S1326 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1322.z), (1.17549435082228751e-38f - _S1322.x)));
    float _S1327 = (F32_cos((_S1325)));
    float3  _S1328 = tangentToWorld(make_float3 (_S1327 * (F32_cos((_S1326))), (F32_sin((_S1325))), _S1327 * (F32_sin((_S1326)))), t_6);
    return _S1328;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_16, BSDFMaterial material_17, float coverage_1)
{
    float3  _S1329;
    if((material_17.ior) == 1.0f)
    {
        float3  _S1330 = straightThrough(toward_1, n_16, material_17);
        _S1329 = _S1330;
    }
    else
    {
        _S1329 = make_float3 (0.0f);
    }
    return _S1329 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_10 = r_3;
    float3  _S1331 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_10)->f = _S1331;
    float _S1332 = r_3.jac * shifted_0.jac;
    (&candidate_10)->jac = _S1332;
    offer(sel_3, candidate_10, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S1333 = rgb_to_greyscale((&r_4)->f);
    float _S1334 = sel_4.w_sum / _S1333;
    bool _S1335 = _S1333 > 0.0f;
    float _S1336 = _slang_select(_S1335, _S1334,0.0f);
    (&r_4)->w = _S1336;
    (&r_4)->c = c_1;
    return r_4;
}

static __device__ float interpolate_0(float a_6, float b_9, float t_7)
{
    return a_6 + (b_9 - a_6) * t_7;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S1337 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S1337;
}

__device__ float2  temporalWeights(float c_2, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S1338 = c_2 * p_c_0;
    float _S1339 = c_t_0 * p_t_0;
    return make_float2 (_S1338 / (_S1338 + c_t_0 * g_previous_0), _S1339 / (_S1339 + c_2 * g_current_0));
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
    Domain _S1340 = dom_2;
    Reservoir _S1341 = r_5;
    Shift _S1342 = walk_0(&_S1340, &_S1341, replay_2, scale_2, sel_5);
    return _S1342;
}

__device__ Shift shift_hook(Domain dom_3, Reservoir r_6)
{
    Domain _S1343 = dom_3;
    Reservoir _S1344 = r_6;
    Shift _S1345 = shift_0(&_S1343, &_S1344);
    return _S1345;
}

#undef Matrix
