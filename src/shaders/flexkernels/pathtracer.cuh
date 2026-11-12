#pragma once
#define Matrix SlangMatrix
#include "slang-cuda-prelude.h"

static __device__ float dot_0(float3  x_0, float3  y_0)
{
    return x_0.x * y_0.x + x_0.y * y_0.y + x_0.z * y_0.z;
}

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_0)
{
    float _S1 = rgb_to_greyscale(material_0->translucent);
    return _S1 > 0.0f;
}

static __device__ FKRay Ray_x24init_0(float3  origin_0, float3  unit_direction_0)
{
    FKRay _S2;
    (&_S2)->origin = origin_0;
    (&_S2)->unit_direction = unit_direction_0;
    return _S2;
}

static __device__ bool wrongSide_0(bool is_inside_0, bool refracted_0, float3  dir_0, float3  geometry_n_0)
{
    return (is_inside_0 == refracted_0) != ((dot_0(dir_0, geometry_n_0)) > 0.0f);
}

static __device__ float3  skyRadiance_0(float3  origin_1, FKSurface * surface_0, float3  side_n_0, bool is_inside_1, float3  dir_1)
{
    bool _S3 = !(((&surface_0->material)->transmission) > 0.0f);
    bool _S4;
    if(_S3)
    {
        bool _S5 = isTranslucent_0(&surface_0->material);
        _S4 = !_S5;
    }
    else
    {
        _S4 = false;
    }
    if(_S4)
    {
        float3  _S6 = surface_0->geometry_n;
        bool _S7 = !((dot_0(surface_0->geometry_n, dir_1)) > 0.0f);
        if(_S7)
        {
            return make_float3 (0.0f);
        }
        FKRay _S8 = Ray_x24init_0(origin_1 + _S6 * make_float3 (dot_0(_S6, surface_0->smooth_n)) * make_float3 (surface_0->geometry_offset), dir_1);
        float3  _S9 = (fcptEnvMapSample((dir_1), (0U), (3U)));
        float3  _S10 = (fcptShadowTransmittance((_S8), (4.294967296e+09f)));
        return _S9 * _S10;
    }
    bool _S11 = wrongSide_0(is_inside_1, false, dir_1, side_n_0);
    bool _S12 = is_inside_1 != _S11;
    float _S13 = surface_0->geometry_offset;
    float3  _S14 = surface_0->smooth_n;
    float3  _S15 = - surface_0->smooth_n;
    float3  _S16 = _slang_select(_S12, _S15,_S14);
    FKRay _S17 = Ray_x24init_0(origin_1 + make_float3 (_S13) * _S16, dir_1);
    float3  _S18 = (fcptEnvMapSample((dir_1), (0U), (3U)));
    float3  _S19 = (fcptShadowTransmittance((_S17), (4.294967296e+09f)));
    return _S18 * _S19;
}

static __device__ uint searchCDF_0(uint2  start_0, uint2  step_0, uint count_0, float u_0)
{
    uint _S20 = count_0 - 1U;
    uint low_0 = 0U;
    uint high_0 = _S20;
    for(;;)
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        uint _S21 = (low_0 + high_0) / 2U;
        float4  _S22 = (fcptEnvironmentCdf((start_0 + step_0 * make_uint2 (_S21))));
        bool _S23 = (_S22.x) > u_0;
        if(_S23)
        {
            high_0 = _S21;
        }
        else
        {
            uint _S24 = _S21 + 1U;
            low_0 = _S24;
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
    bool opaque;
    float3  lift;
    FKHit own;
    bool fiber;
    bool faced;
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
    FKHit _S25;
    (&_S25)->uv = uv_0;
    (&_S25)->instance_index = instance_index_0;
    (&_S25)->triangle_index = triangle_index_0;
    (&_S25)->is_point_light = is_point_light_0;
    (&_S25)->distance = distance_0;
    return _S25;
}

static __device__ float3  lightTransmittance_0(float3  origin_2, float3  smooth_n_0, float geometry_offset_0, float3  light_dir_0, ShadowContext * context_0, uint random_state_0)
{
    float3  _S26 = ((((light_dir_0)) * make_float3(rnorm3df(((light_dir_0)).x, ((light_dir_0)).y, ((light_dir_0)).z))));
    bool _S27 = context_0->opaque;
    bool _S28;
    FKHit _S29;
    if(_S27)
    {
        float3  _S30 = light_dir_0 + make_float3 (geometry_offset_0) * smooth_n_0;
        float3  _S31 = context_0->side;
        float _S32 = dot_0(context_0->side, _S30);
        bool _S33 = _S32 > 0.0f;
        bool _S34 = context_0->faced;
        if(_S34)
        {
            if(_S33)
            {
                bool _S35 = (dot_0(context_0->lift, _S30)) > 0.0f;
                if(_S35)
                {
                    _S28 = true;
                }
                else
                {
                    _S28 = geometry_offset_0 > 0.0f;
                }
            }
            else
            {
                _S28 = false;
            }
            _S28 = !_S28;
        }
        else
        {
            _S28 = false;
        }
        if(_S28)
        {
            return make_float3 (0.0f);
        }
        float _S36 = _slang_select(_S33, geometry_offset_0,0.0f);
        float3  _S37 = make_float3 (_S36) * context_0->lift;
        float3  _S38 = _S30 - _S37;
        bool _S39 = !_S34;
        if(_S39)
        {
            _S28 = !((dot_0(_S31, _S38) * _S32) > 0.0f);
        }
        else
        {
            _S28 = false;
        }
        if(_S28)
        {
            return make_float3 (0.0f);
        }
        float3  _S40 = origin_2 + _S37;
        float3  _S41 = ((((_S38)) * make_float3(rnorm3df(((_S38)).x, ((_S38)).y, ((_S38)).z))));
        FKRay _S42 = Ray_x24init_0(_S40, _S41);
        float _S43 = shadowLength(_S38);
        float3  _S44 = context_0->extinction_behind;
        float3  _S45 = context_0->extinction_front;
        float3  _S46 = _slang_select(_S33, _S45,_S44);
        uint _S47 = context_0->fillings.x;
        uint _S48 = context_0->fillings.y;
        uint _S49 = _slang_select(_S33, _S48,_S47);
        uint _S50 = context_0->depth;
        uint _S51 = context_0->lobe;
        float _S52 = context_0->length;
        float _S53 = context_0->width;
        if(_S36 > 0.0f)
        {
            _S29 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
        }
        else
        {
            _S29 = context_0->own;
        }
        float3  _S54 = (fcptShadowTransmittanceIn((_S42), (_S43), (_S46), (_S49), (random_state_0), (_S50), (_S51), (false), (_S52), (_S53), (_S29)));
        return _S54;
    }
    bool _S55 = (dot_0(smooth_n_0, _S26)) < 0.0f;
    if(_S55)
    {
        return make_float3 (0.0f);
    }
    float3  _S56 = make_float3 (geometry_offset_0) * smooth_n_0;
    float3  _S57 = origin_2 + _S56;
    FKRay _S58 = Ray_x24init_0(_S57, _S26);
    bool _S59 = (dot_0(context_0->side, light_dir_0 + _S56)) > 0.0f;
    float _S60 = shadowLength(light_dir_0);
    float3  _S61 = context_0->extinction_behind;
    float3  _S62 = context_0->extinction_front;
    float3  _S63 = _slang_select(_S59, _S62,_S61);
    uint _S64 = context_0->fillings.x;
    uint _S65 = context_0->fillings.y;
    uint _S66 = _slang_select(_S59, _S65,_S64);
    uint _S67 = context_0->depth;
    uint _S68 = context_0->lobe;
    bool _S69 = context_0->surface;
    if(_S69)
    {
        _S28 = !context_0->fiber;
    }
    else
    {
        _S28 = false;
    }
    float _S70 = context_0->length;
    float _S71 = context_0->width;
    if(context_0->fiber)
    {
        _S29 = context_0->own;
    }
    else
    {
        _S29 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    }
    float3  _S72 = (fcptShadowTransmittanceIn((_S58), (_S60), (_S63), (_S66), (random_state_0), (_S67), (_S68), (_S28), (_S70), (_S71), (_S29)));
    return _S72;
}

__device__ float sine(float c_0)
{
    return (F32_sqrt(((F32_max((1.0f - c_0 * c_0), (0.0f))))));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S73 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S74 = cos_a_0 > cos_b_0;
    float _S75 = _slang_select(_S74, 1.0f,_S73);
    return _S75;
}

__device__ float sinSubClamped(float sin_a_1, float cos_a_1, float sin_b_1, float cos_b_1)
{
    float _S76 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    bool _S77 = cos_a_1 > cos_b_1;
    float _S78 = _slang_select(_S77, 0.0f,_S76);
    return _S78;
}

__device__ float importance(LightNode node_0, float3  p_0, float3  normal_0)
{
    float3  _S79 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S80 = node_0.high - node_0.low;
    float3  _S81 = p_0 - _S79;
    float3  _S82 = ((((_S81)) * make_float3(rnorm3df(((_S81)).x, ((_S81)).y, ((_S81)).z))));
    float _S83 = dot_0(_S81, _S81);
    float _S84 = dot_0(_S80, _S80) / 4.0f;
    float _S85 = (F32_abs((dot_0(node_0.w, _S82))));
    float _S86 = sine(node_0.cos_theta_o);
    float _S87 = (F32_sqrt(((F32_max((1.0f - _S84 / _S83), (0.0f))))));
    bool _S88 = _S83 < _S84;
    float _S89 = _slang_select(_S88, -1.0f,_S87);
    float _S90 = sine(_S89);
    float _S91 = sine(_S85);
    float _S92 = cosSubClamped(_S91, _S85, _S86, node_0.cos_theta_o);
    float _S93 = sine(_S85);
    float _S94 = sinSubClamped(_S93, _S85, _S86, node_0.cos_theta_o);
    float _S95 = cosSubClamped(_S94, _S92, _S90, _S89);
    bool _S96 = _S95 <= 0.0f;
    if(_S96)
    {
        return 0.0f;
    }
    float _S97 = - dot_0(_S82, normal_0);
    float _S98 = node_0.phi * _S95 / (F32_max((_S83), (length_0(_S80) / 2.0f)));
    float _S99 = sine(_S97);
    float _S100 = cosSubClamped(_S99, _S97, _S90, _S89);
    bool _S101 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S102 = _slang_select(_S101, 1.0f,_S100);
    return (F32_max((_S98 * _S102), (0.0f)));
}

__device__ __forceinline__ float childShare(LightNode first_0, LightNode second_0, float3  p_1, float3  normal_1, uint child_0)
{
    float _S103 = importance(first_0, p_1, normal_1);
    float _S104 = importance(second_0, p_1, normal_1);
    float2  _S105 = make_float2 (_S103, _S104);
    float _S106 = _slang_vector_get_element(_S105, child_0) / (_S103 + _S104);
    bool _S107 = _slang_vector_get_element(_S105, child_0) > 0.0f;
    float _S108 = _slang_select(_S107, _S106,0.0f);
    return _S108;
}

__device__ float sphereDensity(float3  center_0, float radius_0, float3  p_2)
{
    float3  _S109 = center_0 - p_2;
    float _S110 = radius_0 * radius_0 / dot_0(_S109, _S109);
    bool _S111 = _S110 >= 1.0f;
    if(_S111)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S110)))) / (6.28318548202514648f * _S110);
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S112 = left_0.y;
    float _S113 = right_0.z;
    float _S114 = left_0.z;
    float _S115 = right_0.y;
    float _S116 = right_0.x;
    float _S117 = left_0.x;
    return make_float3 (_S112 * _S113 - _S114 * _S115, _S114 * _S116 - _S117 * _S113, _S117 * _S115 - _S112 * _S116);
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_0))));
}

static __device__ float lightPdf_0(float3  origin_3, float3  smooth_n_1, float3  start_1, uint j_0, float3  light_point_0)
{
    bool _S118 = j_0 == 4294967295U;
    if(_S118)
    {
        return 0.0f;
    }
    uint4  _S119 = (fcptLightTrail((j_0)));
    uint2  _S120 = uint2 {_S119.x, _S119.y};
    uint n_0 = 0U;
    uint2  trail_0 = _S120;
    float probability_1 = 1.0f;
    for(;;)
    {
        uint4  _S121 = (fcptLightNode((n_0)));
        if((_S121.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S122 = (fcptLightSecond((n_0)));
        uint _S123 = n_0 + 1U;
        LightNode _S124 = (fcptLightBounds((_S123)));
        LightNode _S125 = (fcptLightBounds((_S122)));
        uint _S126 = trail_0.x;
        uint _S127 = _S126 & 1U;
        float _S128 = childShare(_S124, _S125, origin_3, smooth_n_1, _S127);
        float probability_2 = probability_1 * _S128;
        bool _S129 = _S127 == 1U;
        uint _S130 = _slang_select(_S129, _S122,_S123);
        uint _S131 = trail_0.y;
        uint2  _S132 = make_uint2 ((_S126 >> 1U) | (_S131 << 31U), _S131 >> 1U);
        n_0 = _S130;
        trail_0 = _S132;
        probability_1 = probability_2;
    }
    bool _S133 = (fcptSlotLeaf((n_0), (j_0)));
    bool _S134 = !_S133;
    bool _S135;
    if(_S134)
    {
        _S135 = true;
    }
    else
    {
        LightNode _S136 = (fcptLightBounds((n_0)));
        float _S137 = importance(_S136, origin_3, smooth_n_1);
        _S135 = !(_S137 > 0.0f);
    }
    if(_S135)
    {
        _S135 = true;
    }
    else
    {
        bool _S138 = (dot_0(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S138)
        {
            _S135 = !((dot_0(smooth_n_1, light_point_0 - start_1)) > 0.0f);
        }
        else
        {
            _S135 = false;
        }
    }
    if(_S135)
    {
        return 0.0f;
    }
    uint4  _S139 = (fcptLightNode((n_0)));
    bool _S140 = (_S139.x) == 2U;
    if(_S140)
    {
        uint _S141 = _S139.y;
        FKLight _S142 = (fcptLight((_S141)));
        FKLight _S143 = (fcptLight((_S141)));
        float _S144 = sphereDensity(_S142.position, _S143.variance, start_1);
        return probability_1 * _S144;
    }
    uint _S145 = _S139.y;
    uint _S146 = (fcptTriangleOffset((_S145)));
    Matrix<float, 3, 3>  _S147 = (fcptWorldTriangle((_S145), (_S146 + _S139.z)));
    float _S148 = solidAngle(probability_1, cross_0(_S147.rows[int(1)] - _S147.rows[int(0)], _S147.rows[int(2)] - _S147.rows[int(0)]), light_point_0 - start_1);
    return _S148;
}

static __device__ float3  environment_0(float3  dir_2, uint depth_0, uint lobe_0)
{
    uint2  _S149 = (fcptEnvironmentMapSize());
    bool _S150 = (_S149.x) > 1U;
    bool _S151;
    if(_S150)
    {
        uint2  _S152 = (fcptEnvironmentMapSize());
        _S151 = (_S152.y) > 1U;
    }
    else
    {
        _S151 = false;
    }
    if(_S151)
    {
        float3  _S153 = (fcptEnvMapSample((dir_2), (depth_0), (lobe_0)));
        return _S153;
    }
    float3  _S154 = (fcptAmbient());
    return _S154;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S155 = (fcptEnvironmentCdfSize());
    bool _S156 = (_S155.x) > 1U;
    bool _S157;
    if(_S156)
    {
        uint2  _S158 = (fcptEnvironmentCdfSize());
        _S157 = (_S158.y) > 1U;
    }
    else
    {
        _S157 = false;
    }
    bool _S159 = !_S157;
    if(_S159)
    {
        return false;
    }
    uint2  _S160 = (fcptEnvironmentMapSize());
    bool _S161 = (_S160.x) > 1U;
    if(_S161)
    {
        uint2  _S162 = (fcptEnvironmentMapSize());
        _S157 = (_S162.y) > 1U;
    }
    else
    {
        _S157 = false;
    }
    return _S157;
}

static __device__ float clamp_0(float x_2, float minBound_0, float maxBound_0)
{
    return (F32_min(((F32_max((x_2), (minBound_0)))), (maxBound_0)));
}

static __device__ uint2  min_0(uint2  x_3, uint2  y_1)
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
        *_slang_vector_get_element_ptr(&result_0, i_0) = (U32_min((_slang_vector_get_element(x_3, i_0)), (_slang_vector_get_element(y_1, i_0))));
        i_0 = i_0 + int(1);
    }
    return result_0;
}

static __device__ float dot_1(float2  x_4, float2  y_2)
{
    return x_4.x * y_2.x + x_4.y * y_2.y;
}

static __device__ float length_1(float2  x_5)
{
    return (F32_sqrt((dot_1(x_5, x_5))));
}

static __device__ float environmentPdf_0(float3  dir_3)
{
    uint2  _S163 = (fcptEnvironmentCdfSize());
    uint2  _S164 = _S163 - make_uint2 (1U, 0U);
    float2  _S165 = make_float2 ((F32_atan2((- dir_3.z), (- dir_3.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_0(dir_3.y, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S166 = make_float2 ((float)_S164.x, (float)_S164.y);
    float2  _S167 = _S165 * _S166;
    uint2  _S168 = make_uint2 ((uint)_S167.x, (uint)_S167.y);
    uint2  _S169 = min_0(_S168, _S164 - make_uint2 (1U));
    float4  _S170 = (fcptEnvironmentCdf((_S169)));
    float _S171 = _S170.y;
    uint _S172 = _S164.x;
    float4  _S173 = (fcptEnvironmentCdf((make_uint2 (_S172, _S169.y))));
    float _S174 = _S171 * _S173.y;
    return _S174 * float(_S172 * _S164.y) / (19.73921012878417969f * length_1(float2 {dir_3.x, dir_3.z}));
}

static __device__ float escapeWeight_0(float pdf_0, float3  dir_4)
{
    bool _S175 = pdf_0 <= 0.0f;
    bool _S176;
    if(_S175)
    {
        _S176 = true;
    }
    else
    {
        bool _S177 = environmentMapped_0();
        _S176 = !_S177;
    }
    if(_S176)
    {
        return 1.0f;
    }
    float _S178 = environmentPdf_0(dir_4);
    return pdf_0 / (pdf_0 + _S178);
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

__device__ uint hash(uint x_6)
{
    uint _S179 = x_6 * 747796405U + 2891336453U;
    uint _S180 = ((_S179 >> ((_S179 >> 28U) + 4U)) ^ _S179) * 277803737U;
    return (_S180 >> 22U) ^ _S180;
}

static __device__ float random_0(uint * state_0)
{
    uint _S181 = hash(*state_0);
    *state_0 = _S181;
    return float((*state_0) >> int(8)) * 5.9604644775390625e-08f;
}

static __device__ Random Random_x24init_0(uint state_1, float value_0)
{
    Random _S182;
    (&_S182)->state = state_1;
    (&_S182)->value = value_0;
    return _S182;
}

__device__ Random pcg(uint state_2)
{
    uint _S183 = state_2;
    float value_1 = random_0(&_S183);
    return Random_x24init_0(_S183, value_1);
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
    float _S184;
    if(e_0 > 0.0f)
    {
        _S184 = 1.0f;
    }
    else
    {
        if(e_0 < 0.0f)
        {
            _S184 = -1.0f;
        }
        else
        {
            _S184 = 0.0f;
        }
    }
    return _S184;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S185;
    (&_S185)->tangent = tangent_0;
    (&_S185)->alphas = alphas_0;
    return _S185;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_0 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S186 = (F32_abs((dot_0(n_1, a_0)))) > 0.9999847412109375f;
    float3  a_1;
    if(_S186)
    {
        float3  _S187 = make_float3 (1.0f, 0.0f, 0.0f);
        a_1 = _S187;
    }
    else
    {
        a_1 = a_0;
    }
    float3  _S188 = cross_0(n_1, a_1);
    float3  _S189 = ((((_S188)) * make_float3(rnorm3df(((_S188)).x, ((_S188)).y, ((_S188)).z))));
    float3  _S190 = cross_0(n_1, _S189);
    return make_float3 (v_0.x) * _S189 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S190;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_1, float3  n_i_0)
{
    float _S191 = material_1.roughness;
    float _S192 = _S191 * _S191;
    bool _S193 = (material_1.anisotropy) == 0.0f;
    bool _S194;
    if(_S193)
    {
        _S194 = true;
    }
    else
    {
        _S194 = !(_S192 > 0.0f);
    }
    if(_S194)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S195 = material_1.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_1.tangent));
    float3  _S196 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S197 = (dot_0(_S195, _S195)) > 0.0f;
    float3  _S198 = _slang_select(_S197, _S195,_S196);
    float3  _S199 = ((((_S198)) * make_float3(rnorm3df(((_S198)).x, ((_S198)).y, ((_S198)).z))));
    float _S200 = 6.28318548202514648f * material_1.anisotropic_rotation;
    float _S201 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_1.anisotropy))))));
    float _S202 = 1.0f / _S201;
    bool _S203 = (material_1.anisotropy) < 0.0f;
    float _S204 = _slang_select(_S203, _S202,_S201);
    return AnisotropicFrame_x24init_0(_S199 * make_float3 ((F32_cos((_S200)))) + cross_0(n_i_0, _S199) * make_float3 ((F32_sin((_S200)))), make_float2 (_S192 / _S204, _S192 * _S204));
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
    float3  _S205 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S206 = ((((_S205)) * make_float3(rnorm3df(((_S205)).x, ((_S205)).y, ((_S205)).z))));
    float _S207 = _S206.x;
    float _S208 = _S206.y;
    float _S209 = _S207 * _S207 + _S208 * _S208;
    float3  _S210;
    if(_S209 > 0.0f)
    {
        float3  _S211 = make_float3 (- _S208, _S207, 0.0f);
        float _S212 = (rsqrtf((_S209)));
        _S210 = _S211 * make_float3 (_S212);
    }
    else
    {
        _S210 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S213 = cross_0(_S206, _S210);
    float _S214 = (F32_sqrt((U1_0)));
    float _S215 = 6.28318548202514648f * U2_0;
    float _S216 = _S214 * (F32_cos((_S215)));
    float t2_0 = _S214 * (F32_sin((_S215)));
    float _S217 = 0.5f * (1.0f + _S206.z);
    float t2_1 = (1.0f - _S217) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S216 * _S216)))))) + _S217 * t2_0;
    float3  _S218 = make_float3 (_S216) * _S210 + make_float3 (t2_1) * _S213;
    float _S219 = unshared_0(_S216);
    float _S220 = unshared_0(_S216);
    float3  _S221 = _S218 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S219 * _S220 - t2_1 * t2_1))))))) * _S206;
    float3  _S222 = make_float3 (alpha_0 * _S221.x, alpha_0 * _S221.y, (F32_max((0.0f), (_S221.z))));
    float3  _S223 = ((((_S222)) * make_float3(rnorm3df(((_S222)).x, ((_S222)).y, ((_S222)).z))));
    return _S223;
}

__device__ float3  sampleAnisotropicVNDF(float3  Ve_1, float2  alphas_1, float U1_1, float U2_1)
{
    float _S224 = alphas_1.x;
    float _S225 = alphas_1.y;
    float3  _S226 = make_float3 (_S224 * Ve_1.x, _S225 * Ve_1.y, Ve_1.z);
    float3  _S227 = ((((_S226)) * make_float3(rnorm3df(((_S226)).x, ((_S226)).y, ((_S226)).z))));
    float3  _S228 = sampleGGXVNDF(_S227, 1.0f, U1_1, U2_1);
    float3  _S229 = make_float3 (_S224 * _S228.x, _S225 * _S228.y, _S228.z);
    float3  _S230 = ((((_S229)) * make_float3(rnorm3df(((_S229)).x, ((_S229)).y, ((_S229)).z))));
    return _S230;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
{
    float3  a_2 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S231 = (F32_abs((dot_0(n_3, a_2)))) > 0.9999847412109375f;
    float3  a_3;
    if(_S231)
    {
        float3  _S232 = make_float3 (1.0f, 0.0f, 0.0f);
        a_3 = _S232;
    }
    else
    {
        a_3 = a_2;
    }
    float3  _S233 = cross_0(n_3, a_3);
    float3  _S234 = ((((_S233)) * make_float3(rnorm3df(((_S233)).x, ((_S233)).y, ((_S233)).z))));
    float3  _S235 = cross_0(n_3, _S234);
    return make_float3 (dot_0(v_1, _S234), dot_0(v_1, n_3), dot_0(v_1, _S235));
}

__device__ __forceinline__ float3  sampleMaterialHalfVector(float3  v_2, float3  n_i_1, float alpha_1, AnisotropicFrame frame_0, uint * random_state_1)
{
    Random _S236 = pcg(*random_state_1);
    Random _S237 = pcg(_S236.state);
    *random_state_1 = _S237.state;
    bool _S238 = (frame_0.alphas.x) > 0.0f;
    if(_S238)
    {
        float3  _S239 = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        float3  _S240 = sampleAnisotropicVNDF(_S239, frame_0.alphas, _S236.value, _S237.value);
        return make_float3 (_S240.x) * frame_0.tangent + make_float3 (_S240.y) * cross_0(n_i_1, frame_0.tangent) + make_float3 (_S240.z) * n_i_1;
    }
    float3  _S241 = worldToTangent(v_2, n_i_1);
    float3  _S242 = sampleGGXVNDF(float3 {_S241.x, _S241.z, _S241.y}, alpha_1, _S236.value, _S237.value);
    float3  _S243 = float3 {_S242.x, _S242.z, _S242.y};
    float3  _S244 = tangentToWorld(_S243, n_i_1);
    return _S244;
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
    float _S245 = dot_0(n_4, i_1);
    float _S246 = 1.0f - eta_0 * eta_0 * (1.0f - _S245 * _S245);
    if(_S246 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_1 - make_float3 (eta_0 * _S245 + (F32_sqrt((_S246)))) * n_4;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S247 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S248 = eta_i_0 / eta_o_0 * _S247;
    bool _S249 = _S248 < 1.0f;
    float kr_0;
    if(_S249)
    {
        float _S250 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S248 * _S248))))));
        float _S251 = eta_o_0 * cos_theta_0;
        float _S252 = eta_i_0 * _S250;
        float _S253 = (_S251 - _S252) / (_S251 + _S252);
        float _S254 = eta_i_0 * cos_theta_0;
        float _S255 = eta_o_0 * _S250;
        float _S256 = (_S254 - _S255) / (_S254 + _S255);
        float _S257 = (_S253 * _S253 + _S256 * _S256) / 2.0f;
        kr_0 = _S257;
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
    float _S258 = (F32_sqrt((0.05000000074505806f)));
    float _S259 = clamp_0((F32_sqrt(((F32_max((mu_0), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
    float _S260 = (clamp_0((F32_sqrt(((F32_max((r_0), (0.0f)))))), _S258, 1.0f) - _S258) / (1.0f - _S258) * 23.0f;
    uint _S261 = (U32_min((uint(_S259)), (22U)));
    uint _S262 = (U32_min((uint(_S260)), (22U)));
    float _S263 = _S259 - float(_S261);
    float _S264 = _S260 - float(_S262);
    uint _S265 = _S261 * 24U + _S262;
    uint _S266 = _S265 + 24U;
    float _S267 = SHEEN_ALBEDO_0[_S265] + (SHEEN_ALBEDO_0[_S266] - SHEEN_ALBEDO_0[_S265]) * _S263;
    uint _S268 = _S265 + 1U;
    float _S269 = SHEEN_ALBEDO_0[_S268] + (SHEEN_ALBEDO_0[_S266 + 1U] - SHEEN_ALBEDO_0[_S268]) * _S263;
    return (F32_exp((_S267 + (_S269 - _S267) * _S264)));
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

__device__ float anisotropicG1(float3  w_1, float2  alphas_2)
{
    float _S270 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S270 / (_S270 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S270)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S271 = alphas_3.x;
    float _S272 = h_0.x / _S271;
    float _S273 = alphas_3.y;
    float _S274 = h_0.y / _S273;
    float _S275 = h_0.z;
    float _S276 = _S272 * _S272 + _S274 * _S274 + _S275 * _S275;
    return 1.0f / (F32_max((3.14159274101257324f * _S271 * _S273 * _S276 * _S276), (1.17549435082228751e-38f)));
}

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_0, float3  refracted_1, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_0, float3  sheen_0, float3  view_0, float3  tangent_1, float2  alphas_4, float visible_0)
{
    BSDFLobes _S277;
    (&_S277)->v_dot_h = v_dot_h_0;
    (&_S277)->n_dot_h = n_dot_h_0;
    (&_S277)->refracted = refracted_1;
    (&_S277)->F = F_0;
    (&_S277)->F_greyscale = F_greyscale_0;
    (&_S277)->reflect_weight = reflect_weight_0;
    (&_S277)->diffuse_weight = diffuse_weight_0;
    (&_S277)->refract_weight = refract_weight_0;
    (&_S277)->p_diffuse = p_diffuse_0;
    (&_S277)->p_reflect = p_reflect_0;
    (&_S277)->p_refract = p_refract_0;
    (&_S277)->translucent_share = translucent_share_0;
    (&_S277)->sheen = sheen_0;
    (&_S277)->view = view_0;
    (&_S277)->tangent = tangent_1;
    (&_S277)->alphas = alphas_4;
    (&_S277)->visible = visible_0;
    return _S277;
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_0, float3  v_3, float3  n_i_2, float3  ggx_n_0, BSDFMaterial material_2, float eta_i_1, float eta_o_1, AnisotropicFrame frame_1)
{
    float _S278 = dot_0(ggx_n_0, v_3);
    float _S279 = dot_0(n_i_2, ggx_n_0);
    float _S280 = eta_i_1 / eta_o_1;
    float3  _S281 = refract_0(in_dir_0, ggx_n_0, _S280);
    float3  _S282 = ((((_S281)) * make_float3(rnorm3df(((_S281)).x, ((_S281)).y, ((_S281)).z))));
    float _S283 = (F32_min(((F32_sqrt((material_2.specular_level))) * (F32_abs((eta_i_1 - eta_o_1))) / (eta_i_1 + eta_o_1)), (0.9999847412109375f)));
    float _S284 = _S283 * _S283;
    float _S285 = (1.0f + _S283) / (1.0f - _S283);
    float _S286 = (F32_abs((_S278)));
    bool _S287 = eta_i_1 > eta_o_1;
    float sheen_component_0;
    if(_S287)
    {
        sheen_component_0 = _S285;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float visible_1;
    if(_S287)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S285;
    }
    float _S288 = fresnel(_S286, sheen_component_0, visible_1);
    bool _S289 = (eta_i_1 * eta_i_1 * (1.0f - _S278 * _S278)) >= (eta_o_1 * eta_o_1);
    float3  _S290;
    if(_S289)
    {
        _S290 = make_float3 (1.0f);
    }
    else
    {
        float3  _S291 = material_2.specular_tint * make_float3 (_S284);
        _S290 = _S291 + (make_float3 (1.0f) - _S291) * make_float3 (_S288 - _S284) / make_float3 (1.0f - _S284);
    }
    float3  _S292 = make_float3 (1.0f);
    float3  _S293 = make_float3 (0.0f);
    float _S294 = rgb_to_greyscale(material_2.sheen);
    bool _S295 = _S294 > 0.0f;
    float3  scale_0;
    float3  sheen_1;
    float3  view_1;
    if(_S295)
    {
        float _S296 = sheenAlbedo(dot_0(n_i_2, v_3), material_2.sheen_roughness);
        float _S297 = (F32_min((_S296), (1.0f)));
        float3  _S298 = make_float3 (1.0f) - material_2.sheen * make_float3 (_S297);
        float _S299 = rgb_to_greyscale(material_2.sheen);
        float _S300 = _S299 * _S297;
        float3  _S301 = material_2.sheen / make_float3 ((F32_max((_S296), (1.0f))));
        scale_0 = _S298;
        sheen_component_0 = _S300;
        sheen_1 = _S301;
        view_1 = v_3;
    }
    else
    {
        scale_0 = _S292;
        sheen_component_0 = 0.0f;
        sheen_1 = _S293;
        view_1 = _S293;
    }
    float3  _S302 = mix_0(_S290, material_2.albedo, material_2.metallic);
    float3  F_1 = _S302 * scale_0;
    float _S303 = rgb_to_greyscale(F_1);
    float _S304 = 1.0f - material_2.metallic;
    float3  _S305 = make_float3 (1.0f) - _S290;
    float3  _S306 = make_float3 ((1.0f - material_2.transmission) * _S304) * _S305 * scale_0;
    float3  _S307 = make_float3 (material_2.transmission * _S304) * _S305 * scale_0;
    float _S308 = (F32_max((_S303), (0.0f)));
    float _S309 = rgb_to_greyscale(_S306);
    float _S310 = (F32_max((_S309), (0.0f)));
    float _S311 = rgb_to_greyscale(_S307);
    float _S312 = sign_0(length_0(_S282));
    float _S313 = (F32_max((_S311 * _S312), (0.0f)));
    float _S314 = _S308 + _S310 + _S313 + sheen_component_0;
    float _S315 = 1.0f / (F32_max((_S314), (0.0000152587890625f)));
    float _S316 = (_S310 + sheen_component_0) * _S315;
    float _S317 = _S308 * _S315;
    float _S318 = _S313 * _S315;
    bool _S319 = (frame_1.alphas.x) > 0.0f;
    if(_S319)
    {
        float3  _S320 = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        float _S321 = anisotropicG1(_S320, frame_1.alphas);
        float3  _S322 = anisotropicLocal(ggx_n_0, frame_1.tangent, n_i_2);
        float _S323 = anisotropicD(_S322, frame_1.alphas);
        float _S324 = _S321 * _S323;
        visible_1 = _S324;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S278, _S279, _S282, F_1, _S303, 1.0f, _S306, _S307, _S316, _S317, _S318, 0.0f, sheen_1, view_1, frame_1.tangent, frame_1.alphas, visible_1);
}

__device__ float translucentShare(BSDFMaterial material_3)
{
    float _S325 = rgb_to_greyscale(material_3.translucent);
    float _S326 = rgb_to_greyscale(material_3.albedo);
    float _S327 = _S325 / (_S326 + _S325);
    bool _S328 = _S325 > 0.0f;
    float _S329 = _slang_select(_S328, _S327,0.0f);
    return _S329;
}

__device__ float smithG1(float alpha_2, float n_dot_x_0)
{
    float _S330 = alpha_2 * alpha_2;
    float _S331 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S330 + (1.0f - _S330) * n_dot_x_0 * n_dot_x_0))));
    bool _S332 = alpha_2 > 0.0f;
    float _S333 = _slang_select(_S332, _S331,1.0f);
    return _S333;
}

__device__ float trowbridgeReitz(float alpha_3, float n_dot_h_1)
{
    float _S334 = alpha_3 * alpha_3;
    float _S335 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S334 * n_dot_h_1 * n_dot_h_1;
    return _S334 / (F32_max((3.14159274101257324f * _S335 * _S335), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, BSDFLobes lobes_0, float eta_i_2, float eta_o_2, uint lobe_1)
{
    bool _S336 = lobe_1 == 0U;
    if(_S336)
    {
        float _S337 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        float _S338 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
        float _S339 = 1.0f - lobes_0.translucent_share;
        bool _S340 = n_i_dot_l_0 < 0.0f;
        float _S341 = _slang_select(_S340, lobes_0.translucent_share,_S339);
        float _S342 = _S338 * _S341;
        bool _S343 = (lobes_0.translucent_share) > 0.0f;
        float _S344 = _slang_select(_S343, _S342,_S337);
        bool _S345 = n_i_dot_v_0 > 0.0f;
        float _S346 = _slang_select(_S345, _S344,0.0f);
        return _S346;
    }
    float _S347 = smithG1(alpha_4, n_i_dot_v_0);
    float _S348 = _S347 * lobes_0.v_dot_h;
    float _S349 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    float _S350 = _S348 * _S349 / n_i_dot_v_0;
    bool _S351 = alpha_4 > 0.0f;
    bool _S352;
    if(_S351)
    {
        _S352 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S352 = false;
    }
    if(_S352)
    {
        _S352 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S352 = false;
    }
    if(_S352)
    {
        _S352 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S352 = false;
    }
    float _S353 = _slang_select(_S352, _S350,0.0f);
    bool _S354 = (lobes_0.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S354)
    {
        float _S355 = lobes_0.visible * lobes_0.v_dot_h / n_i_dot_v_0;
        bool _S356 = (lobes_0.v_dot_h) > 0.0f;
        if(_S356)
        {
            _S352 = (lobes_0.n_dot_h) > 0.0f;
        }
        else
        {
            _S352 = false;
        }
        if(_S352)
        {
            _S352 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S352 = false;
        }
        float _S357 = _slang_select(_S352, _S355,0.0f);
        pdf_h_0 = _S357;
    }
    else
    {
        pdf_h_0 = _S353;
    }
    bool _S358 = lobe_1 == 1U;
    if(_S358)
    {
        float _S359 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        float _S360 = lobes_0.p_refract * pdf_h_0 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S359 * _S359);
        bool _S361 = eta_i_2 != eta_o_2;
        if(_S361)
        {
            _S352 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S352 = false;
        }
        float _S362 = _slang_select(_S352, _S360,0.0f);
        return _S362;
    }
    float _S363 = lobes_0.p_reflect * pdf_h_0 / (4.0f * lobes_0.v_dot_h);
    bool _S364 = pdf_h_0 > 0.0f;
    float _S365 = _slang_select(_S364, _S363,0.0f);
    return _S365;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_0, uint random_state_2, bool refracted_2, uint lobe_2, float pdf_1)
{
    SampleBSDF _S366;
    (&_S366)->unit_direction = unit_direction_1;
    (&_S366)->throughput = throughput_0;
    (&_S366)->random_state = random_state_2;
    (&_S366)->refracted = refracted_2;
    (&_S366)->lobe = lobe_2;
    (&_S366)->pdf = pdf_1;
    return _S366;
}

__device__ float sheenBRDF(float3  l_0, float3  v_4, float3  n_5, float r_1)
{
    float _S367 = 1.0f / (F32_max((r_1), (0.05000000074505806f)));
    float3  _S368 = l_0 + v_4;
    float3  _S369 = ((((_S368)) * make_float3(rnorm3df(((_S368)).x, ((_S368)).y, ((_S368)).z))));
    float _S370 = dot_0(n_5, _S369);
    float _S371 = (F32_max((dot_0(n_5, l_0)), (0.0f)));
    float _S372 = (F32_max((dot_0(n_5, v_4)), (0.0f)));
    return (2.0f + _S367) * (F32_pow(((F32_max((1.0f - _S370 * _S370), (0.0f)))), (0.5f * _S367))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S371 + _S372 - _S371 * _S372)), (0.0000152587890625f)));
}

__device__ __forceinline__ float3  lobeThroughput(float3  l_1, float3  n_i_3, float alpha_5, BSDFMaterial material_4, BSDFLobes lobes_1, uint lobe_3)
{
    bool _S373 = lobe_3 == 0U;
    if(_S373)
    {
        bool _S374 = (dot_0(n_i_3, l_1)) < 0.0f;
        float3  _S375 = _slang_select(_S374, material_4.translucent,material_4.albedo);
        float _S376 = 1.0f - lobes_1.translucent_share;
        float _S377 = _slang_select(_S374, lobes_1.translucent_share,_S376);
        float3  _S378 = _S375 / make_float3 (_S377);
        bool _S379 = (lobes_1.translucent_share) > 0.0f;
        float3  _S380 = _slang_select(_S379, _S378,material_4.albedo);
        float _S381 = rgb_to_greyscale(material_4.sheen);
        bool _S382 = _S381 > 0.0f;
        bool _S383;
        if(_S382)
        {
            _S383 = !_S374;
        }
        else
        {
            _S383 = false;
        }
        if(_S383)
        {
            float3  _S384 = lobes_1.diffuse_weight * _S380;
            float3  _S385 = lobes_1.sheen * make_float3 (3.14159274101257324f);
            float _S386 = sheenBRDF(l_1, lobes_1.view, n_i_3, material_4.sheen_roughness);
            float3  _S387 = _S385 * make_float3 (_S386);
            float _S388 = _slang_select(_S379, _S376,1.0f);
            return (_S384 + _S387 / make_float3 (_S388)) / make_float3 (lobes_1.p_diffuse);
        }
        return lobes_1.diffuse_weight * _S380 / make_float3 (lobes_1.p_diffuse);
    }
    bool _S389 = lobe_3 == 1U;
    float G1_l_0;
    if(_S389)
    {
        float _S390 = - dot_0(n_i_3, l_1);
        float _S391 = smithG1(alpha_5, (F32_max((_S390), (0.0f))));
        bool _S392 = (lobes_1.alphas.x) > 0.0f;
        if(_S392)
        {
            float3  _S393 = negate_0(n_i_3);
            float3  _S394 = anisotropicLocal(l_1, lobes_1.tangent, _S393);
            float _S395 = anisotropicG1(_S394, lobes_1.alphas);
            G1_l_0 = _S395;
        }
        else
        {
            G1_l_0 = _S391;
        }
        return lobes_1.refract_weight * make_float3 (G1_l_0) * material_4.albedo / make_float3 (lobes_1.p_refract);
    }
    float _S396 = dot_0(n_i_3, l_1);
    float _S397 = smithG1(alpha_5, (F32_max((_S396), (0.0f))));
    bool _S398 = (lobes_1.alphas.x) > 0.0f;
    if(_S398)
    {
        float3  _S399 = anisotropicLocal(l_1, lobes_1.tangent, n_i_3);
        float _S400 = anisotropicG1(_S399, lobes_1.alphas);
        G1_l_0 = _S400;
    }
    else
    {
        G1_l_0 = _S397;
    }
    return make_float3 (lobes_1.reflect_weight * G1_l_0) * lobes_1.F / make_float3 (lobes_1.p_reflect);
}

__device__ __forceinline__ SampleBSDF connectBSDF(float3  in_dir_1, float3  out_dir_0, float3  n_6, BSDFMaterial material_5, float eta_i_3, float eta_o_3, uint lobe_4, uint random_init_0)
{
    uint random_state_3 = random_init_0;
    float3  _S401 = negate_0(in_dir_1);
    float _S402 = dot_0(n_6, _S401);
    float _S403 = sign_0(_S402);
    float3  _S404 = n_6 * make_float3 (_S403);
    float _S405 = material_5.roughness;
    float _S406 = _S405 * _S405;
    AnisotropicFrame _S407 = anisotropicFrame(material_5, _S404);
    float3  _S408 = _S401 + out_dir_0;
    float3  _S409 = ((((_S408)) * make_float3(rnorm3df(((_S408)).x, ((_S408)).y, ((_S408)).z))));
    bool _S410 = lobe_4 == 0U;
    float3  ggx_n_1;
    if(_S410)
    {
        float3  _S411 = sampleMaterialHalfVector(_S401, _S404, _S406, _S407, &random_state_3);
        ggx_n_1 = _S411;
    }
    else
    {
        bool _S412 = lobe_4 == 1U;
        if(_S412)
        {
            float3  _S413 = negate_0(make_float3 (eta_i_3) * _S401 + make_float3 (eta_o_3) * out_dir_0);
            float3  _S414 = ((((_S413)) * make_float3(rnorm3df(((_S413)).x, ((_S413)).y, ((_S413)).z))));
            float _S415 = sign_0(dot_0(_S413, _S404));
            float3  _S416 = _S414 * make_float3 (_S415);
            ggx_n_1 = _S416;
        }
        else
        {
            ggx_n_1 = _S409;
        }
    }
    BSDFLobes _S417 = bsdfLobes(in_dir_1, _S401, _S404, ggx_n_1, material_5, eta_i_3, eta_o_3, _S407);
    BSDFLobes lobes_2 = _S417;
    float _S418 = translucentShare(material_5);
    (&lobes_2)->translucent_share = _S418;
    float _S419 = lobeDensity(dot_0(_S404, out_dir_0), dot_0(out_dir_0, ggx_n_1), (F32_abs((_S402))), _S406, lobes_2, eta_i_3, eta_o_3, lobe_4);
    bool _S420 = !(_S419 > 0.0f);
    if(_S420)
    {
        float3  _S421 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S421, _S421, 0U, false, 0U, 0.0f);
    }
    float3  _S422 = lobeThroughput(out_dir_0, _S404, _S406, material_5, lobes_2, lobe_4);
    return SampleBSDF_x24init_0(out_dir_0, _S422, random_state_3, lobe_4 == 1U, lobe_4, _S419);
}

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_2, float3  dir_5, float3  n_7, BSDFMaterial material_6, float eta_i_4, float eta_o_4, bool refracted_3, float pdf_2, bool power_0, uint random_state_4)
{
    float3  _S423 = make_float3 (0.0f);
    uint lobe_5 = 0U;
    float3  f_0 = _S423;
    for(;;)
    {
        if(lobe_5 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S424 = lobe_5 == 0U;
        if(_S424)
        {
        }
        bool _S425;
        if(_S424)
        {
            float _S426 = rgb_to_greyscale(material_6.translucent);
            _S425 = _S426 > 0.0f;
        }
        else
        {
            _S425 = false;
        }
        bool _S427;
        if(_S425)
        {
            float _S428 = dot_0(n_7, dir_5);
            float3  _S429 = negate_0(in_dir_2);
            _S427 = ((_S428 * dot_0(n_7, _S429)) < 0.0f) == refracted_3;
        }
        else
        {
            _S427 = (lobe_5 == 1U) == refracted_3;
        }
        float3  f_1;
        if(_S427)
        {
            SampleBSDF _S430 = connectBSDF(in_dir_2, dir_5, n_7, material_6, eta_i_4, eta_o_4, lobe_5, random_state_4);
            bool _S431 = (_S430.pdf) > 0.0f;
            if(_S431)
            {
                if(power_0)
                {
                    float _S432 = _S430.pdf / pdf_2;
                    float3  f_2 = f_0 + _S430.throughput * make_float3 (_S430.pdf) / make_float3 (pdf_2 * (1.0f + _S432 * _S432));
                    f_1 = f_2;
                }
                else
                {
                    float3  f_3 = f_0 + _S430.throughput * make_float3 (_S430.pdf) / make_float3 (_S430.pdf + pdf_2);
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
        uint lobe_6 = lobe_5 + 1U;
        lobe_5 = lobe_6;
        f_0 = f_1;
    }
    return f_0;
}

__device__ float3  skyBSDF(float3  in_dir_3, float3  dir_6, FKSurface surface_1, float3  side_n_1, float2  eta_1, bool is_inside_2, float pdf_3, uint random_state_5)
{
    bool _S433 = wrongSide_0(is_inside_2, false, dir_6, side_n_1);
    float3  _S434 = neeBSDF(in_dir_3, dir_6, surface_1.smooth_n, surface_1.material, eta_1.x, eta_1.y, _S433, pdf_3, false, random_state_5);
    return _S434;
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

static __device__ SkySample SkySample_x24init_0(float3  dir_7, float3  radiance_0, float3  color_0, uint random_state_6)
{
    SkySample _S435;
    (&_S435)->dir = dir_7;
    (&_S435)->radiance = radiance_0;
    (&_S435)->color = color_0;
    (&_S435)->random_state = random_state_6;
    return _S435;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float3  side_n_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0)
{
    uint2  _S436 = (fcptEnvironmentCdfSize());
    uint2  _S437 = make_uint2 (1U, 0U);
    uint2  _S438 = _S436 - _S437;
    Random _S439 = pcg(init_random_state_0);
    Random _S440 = pcg(_S439.state);
    Random _S441 = pcg(_S440.state);
    Random _S442 = pcg(_S441.state);
    uint _S443 = _S438.x;
    uint _S444 = searchCDF_0(make_uint2 (_S443, 0U), make_uint2 (0U, 1U), _S438.y, _S439.value);
    uint _S445 = searchCDF_0(make_uint2 (0U, _S444), _S437, _S443, _S440.value);
    float2  _S446 = make_float2 ((float)_S438.x, (float)_S438.y);
    float2  _S447 = (make_float2 (float(_S445), float(_S444)) + make_float2 (_S441.value, _S442.value)) / _S446 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S448 = _S447.y;
    float _S449 = (F32_sin((_S448)));
    float _S450 = _S447.x;
    float3  _S451 = make_float3 (_S449 * (F32_cos((_S450))), (F32_cos((_S448))), _S449 * (F32_sin((_S450))));
    float _S452 = environmentPdf_0(_S451);
    float3  _S453 = skyBSDF(ray_0->unit_direction, _S451, *surface_2, side_n_2, eta_2, is_inside_3, _S452, lobe_state_0);
    bool _S454 = !(_S452 > 0.0f);
    bool _S455;
    if(_S454)
    {
        _S455 = true;
    }
    else
    {
        _S455 = all_0(_S453 == make_float3 (0.0f));
    }
    if(_S455)
    {
        float3  _S456 = make_float3 (0.0f);
        return SkySample_x24init_0(_S451, _S456, _S456, _S442.state);
    }
    float3  _S457 = skyRadiance_0(ray_0->origin, surface_2, side_n_2, is_inside_3, _S451);
    return SkySample_x24init_0(_S451, _S457, _S453 * _S457, _S442.state);
}

struct TreeSample
{
    float3  dir;
    float3  radiance;
    float density;
    uint random_state;
};

static __device__ float3  hairLight_0(FKSurface * surface_3, float3  in_dir_4, TreeSample * light_0, bool competing_0)
{
    SampleBSDF _S458 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_4), (light_0->dir)));
    float3  _S459 = _S458.throughput * make_float3 (_S458.pdf);
    float _S460 = light_0->density;
    float _S461 = 1.0f + _S458.pdf * _S458.pdf / (light_0->density * light_0->density);
    bool _S462;
    if(competing_0)
    {
        _S462 = _S460 > 0.0f;
    }
    else
    {
        _S462 = false;
    }
    float _S463 = _slang_select(_S462, _S461,1.0f);
    return _S459 / make_float3 (_S463) * light_0->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_8, float3  radiance_1, float density_0, uint random_state_7)
{
    TreeSample _S464;
    (&_S464)->dir = dir_8;
    (&_S464)->radiance = radiance_1;
    (&_S464)->density = density_0;
    (&_S464)->random_state = random_state_7;
    return _S464;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_3, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S465 = importance(first_1, p_3, normal_3);
    float _S466 = importance(second_1, p_3, normal_3);
    float2  _S467 = make_float2 (_S465, _S466);
    bool _S468 = _S465 == 0.0f;
    bool _S469;
    if(_S468)
    {
        _S469 = _S466 == 0.0f;
    }
    else
    {
        _S469 = false;
    }
    if(_S469)
    {
        return 2U;
    }
    float _S470 = _S465 + _S466;
    bool _S471 = _S466 > 0.0f;
    if(_S471)
    {
        _S469 = (*pick_0 * _S470) >= _S465;
    }
    else
    {
        _S469 = false;
    }
    uint _S472 = uint(_S469);
    float _S473 = (F32_min(((*pick_0 * _S470 - float(_S472) * _S465) / _slang_vector_get_element(_S467, _S472)), (0.99999994039535522f)));
    *pick_0 = _S473;
    float _S474 = *probability_3 * (_slang_vector_get_element(_S467, _S472) / _S470);
    *probability_3 = _S474;
    return _S472;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_4, float u1_0, float u2_0)
{
    float3  _S475 = center_1 - p_4;
    float _S476 = radius_1 * radius_1 / dot_0(_S475, _S475);
    float _S477 = u1_0 * _S476 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S476), (0.0f)))))));
    float _S478 = 2.0f * u1_0;
    bool _S479 = _S476 >= 1.0f;
    float _S480 = _slang_select(_S479, _S478,_S477);
    float _S481 = (F32_sqrt(((F32_max((_S480 * (2.0f - _S480)), (0.0f))))));
    float _S482 = 6.28318548202514648f * u2_0;
    float3  _S483 = make_float3 (_S481 * (F32_cos((_S482))), 1.0f - _S480, _S481 * (F32_sin((_S482))));
    float3  _S484 = ((((_S475)) * make_float3(rnorm3df(((_S475)).x, ((_S475)).y, ((_S475)).z))));
    float3  _S485 = tangentToWorld(_S483, _S484);
    return _S485;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S486 = center_2 - ray_1->origin;
    float _S487 = dot_0(_S486, ray_1->unit_direction);
    float _S488 = dot_0(_S486, _S486) - _S487 * _S487;
    float _S489 = radius_3 * radius_3;
    bool _S490 = _S488 > _S489;
    if(_S490)
    {
        return 4.294967296e+09f;
    }
    float _S491 = (F32_sqrt((_S489 - _S488)));
    float _S492 = _S487 - _S491;
    float _S493 = _S487 + _S491;
    bool _S494 = _S492 > 0.0000152587890625f;
    bool _S495;
    if(_S494)
    {
        _S495 = _S492 < max_len_0;
    }
    else
    {
        _S495 = false;
    }
    if(_S495)
    {
        return _S492;
    }
    bool _S496 = _S493 > 0.0000152587890625f;
    if(_S496)
    {
        _S495 = _S493 < max_len_0;
    }
    else
    {
        _S495 = false;
    }
    if(_S495)
    {
        return _S493;
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
    Random _S497 = pcg(init_random_state_1);
    Random _S498 = pcg(_S497.state);
    Random _S499 = pcg(_S498.state);
    float3  _S500 = make_float3 (0.0f);
    TreeSample _S501 = TreeSample_x24init_0(_S500, _S500, 0.0f, _S499.state);
    TreeSample sample_0 = _S501;
    float3  _S502 = _slang_select(sided_0, _S500,smooth_n_2);
    bool _S503 = context_1->opaque;
    float3  lift_n_0;
    if(_S503)
    {
        float3  _S504 = context_1->lift;
        lift_n_0 = _S504;
    }
    else
    {
        lift_n_0 = smooth_n_2;
    }
    float3  start_2 = origin_4 + make_float3 (geometry_offset_1) * lift_n_0;
    float pick_1 = _S497.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S505 = (fcptLightNode((n_8)));
        if((_S505.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S506 = (fcptLightSecond((n_8)));
        uint _S507 = n_8 + 1U;
        LightNode _S508 = (fcptLightBounds((_S507)));
        LightNode _S509 = (fcptLightBounds((_S506)));
        uint _S510 = pickChild(_S508, _S509, origin_4, _S502, &pick_1, &probability_4);
        bool _S511 = _S510 > 1U;
        if(_S511)
        {
            return sample_0;
        }
        bool _S512 = _S510 == 1U;
        uint _S513 = _slang_select(_S512, _S506,_S507);
        n_8 = _S513;
    }
    bool _S514 = n_8 == 0U;
    bool _S515;
    if(_S514)
    {
        LightNode _S516 = (fcptLightBounds((0U)));
        float _S517 = importance(_S516, origin_4, _S502);
        _S515 = !(_S517 > 0.0f);
    }
    else
    {
        _S515 = false;
    }
    if(_S515)
    {
        return sample_0;
    }
    uint4  _S518 = (fcptLightNode((n_8)));
    FKHit _S519 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S520 = (_S518.x) == 2U;
    float3  emitter_point_0;
    float3  shadow_1;
    float3  start_3;
    FKHit emitter_0;
    if(_S520)
    {
        FKLight _S521 = (fcptLight((_S518.y)));
        if(sided_0)
        {
            _S515 = !_S503;
        }
        else
        {
            _S515 = false;
        }
        if(_S515)
        {
            float _S522 = sign_0(dot_0(geometry_n_1, _S521.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S522);
            float3  _S523 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S523;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = start_2;
        }
        bool _S524 = (_S521.variance) == 0.0f;
        if(_S524)
        {
            float3  _S525 = _S521.position - emitter_point_0;
            float3  _S526 = ((((_S525)) * make_float3(rnorm3df(((_S525)).x, ((_S525)).y, ((_S525)).z))));
            (&sample_0)->dir = _S526;
            float3  _S527 = _S521.color * make_float3 (_S521.intensity) / make_float3 (dot_0(_S525, _S525) * probability_4);
            (&sample_0)->radiance = _S527;
            shadow_1 = _S525;
        }
        else
        {
            float3  _S528 = sampleSphere(_S521.position, _S521.variance, emitter_point_0, _S498.value, _S499.value);
            (&sample_0)->dir = _S528;
            float _S529 = sphereDensity(_S521.position, _S521.variance, emitter_point_0);
            float _S530 = probability_4 * _S529;
            (&sample_0)->density = _S530;
            float3  _S531 = pointLightRadiance(_S521.color, _S521.intensity, _S521.variance);
            float3  _S532 = _S531 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S532;
            FKRay _S533 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S534 = raySphere_0(_S521.position, _S521.variance, &_S533, 4.294967296e+09f);
            float3  _S535 = (&sample_0)->dir * make_float3 (_S534);
            shadow_1 = _S535;
        }
        float3  _S536 = emitter_point_0;
        emitter_0 = _S519;
        emitter_point_0 = _S500;
        start_3 = _S536;
    }
    else
    {
        uint _S537 = _S518.y;
        uint _S538 = (fcptTriangleOffset((_S537)));
        uint _S539 = _S538 + _S518.z;
        Matrix<float, 3, 3>  _S540 = (fcptWorldTriangle((_S537), (_S539)));
        float _S541 = (F32_sqrt((_S498.value)));
        float2  _S542 = make_float2 (_S541 * (1.0f - _S499.value), _S541 * _S499.value);
        float3  _S543 = mul_0(make_float3 (1.0f - _S541, _S542.x, _S542.y), _S540);
        if(sided_0)
        {
            _S515 = !_S503;
        }
        else
        {
            _S515 = false;
        }
        if(_S515)
        {
            float _S544 = sign_0(dot_0(geometry_n_1, _S543 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S544);
            float3  _S545 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S545;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S546 = !((dot_0(smooth_n_2, _S543 - start_2)) > 0.0f);
            if(_S546)
            {
                return sample_0;
            }
            emitter_point_0 = start_2;
        }
        FKHit _S547 = Hit_x24init_0(_S542, _S537, _S539, 0U, 0.0f);
        float3  _S548 = _S543 - emitter_point_0;
        float3  _S549 = ((((_S548)) * make_float3(rnorm3df(((_S548)).x, ((_S548)).y, ((_S548)).z))));
        (&sample_0)->dir = _S549;
        float _S550 = solidAngle(probability_4, cross_0(_S540.rows[int(1)] - _S540.rows[int(0)], _S540.rows[int(2)] - _S540.rows[int(0)]), _S548);
        (&sample_0)->density = _S550;
        float3  _S551 = emitter_point_0;
        shadow_1 = _S548;
        emitter_0 = _S547;
        emitter_point_0 = _S543;
        start_3 = _S551;
    }
    float3  _S552 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_1, _S499.state);
    bool _S553 = (emitter_0.instance_index) != 4294967295U;
    if(_S553)
    {
        _S515 = !all_0(_S552 == _S500);
    }
    else
    {
        _S515 = false;
    }
    if(_S515)
    {
        float3  _S554 = emitter_point_0 - start_3;
        float3  _S555 = ((((_S554)) * make_float3(rnorm3df(((_S554)).x, ((_S554)).y, ((_S554)).z))));
        FKSurface _S556 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S499.state), (_S555), (context_1->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S556.random_state;
        float3  _S557 = _slang_select(_S556.skip, _S500,_S556.material.emissive);
        float3  _S558 = _S557 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S558;
    }
    float3  _S559 = (&sample_0)->radiance * _S552;
    bool _S560 = all_0(_S552 == _S500);
    float3  _S561 = _slang_select(_S560, _S500,_S559);
    (&sample_0)->radiance = _S561;
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
    float _S562 = 1.0f / (1.0f + b_0 / a_4 * (b_0 / a_4));
    bool _S563 = b_0 > 0.0f;
    float _S564 = _slang_select(_S563, _S562,1.0f);
    return _S564;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_0, float3  light_point_1)
{
    bool _S565 = vertex_0->none;
    if(_S565)
    {
        return 1.0f;
    }
    uint _S566 = (fcptLightSlot((*hit_0)));
    float _S567 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S566, light_point_1);
    float _S568 = powerHeuristic(vertex_0->pdf, _S567);
    return _S568;
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
    Shift _S569;
    (&_S569)->f = f_4;
    (&_S569)->jac = jac_0;
    return _S569;
}

static __device__ uint extractBits_0(uint e_1, uint offset_0, uint count_1)
{
    return (e_1 >> offset_0) & ((1U << count_1) - 1U);
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_4)
{
    NEEVertex _S570;
    (&_S570)->none = none_0;
    (&_S570)->pdf = pdf_4;
    (&_S570)->origin = origin_5;
    (&_S570)->smooth_n = smooth_n_3;
    (&_S570)->start = start_4;
    return _S570;
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
    Vertex _S571;
    (&_S571)->rough = rough_0;
    (&_S571)->lobe = lobe_7;
    (&_S571)->pdf = pdf_5;
    (&_S571)->cos = cos_0;
    (&_S571)->inside = inside_0;
    return _S571;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S572 = hash(index_0);
    uint _S573 = hash(seed_0 ^ _S572);
    return _S573;
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
    float3  _S574 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_1));
    float3  _S575 = scatter_0 * _S574 / make_float3 (sigma_1);
    float3  _S576 = _slang_select(scatters_0, _S575,_S574);
    return _S576;
}

static __device__ bool scatterSampled_0(bool replay_0, uint b_1, uint stop_0, bool varying_0)
{
    bool _S577 = !replay_0;
    bool _S578;
    if(_S577)
    {
        _S578 = true;
    }
    else
    {
        bool _S579 = b_1 == stop_0;
        if(_S579)
        {
            _S578 = !varying_0;
        }
        else
        {
            _S578 = false;
        }
    }
    return _S578;
}

static __device__ uint arrivalLobe_0(uint b_2, uint prev_lobe_0)
{
    bool _S580 = b_2 > 0U;
    uint _S581 = _slang_select(_S580, prev_lobe_0,3U);
    return _S581;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_8, bool surface_4, float length_2, float width_0, bool opaque_0, float3  lift_0, FKHit * own_0, bool fiber_0, bool faced_0)
{
    ShadowContext _S582;
    (&_S582)->extinction_behind = extinction_behind_0;
    (&_S582)->extinction_front = extinction_front_0;
    (&_S582)->fillings = fillings_0;
    (&_S582)->side = side_0;
    (&_S582)->depth = depth_1;
    (&_S582)->lobe = lobe_8;
    (&_S582)->surface = surface_4;
    (&_S582)->length = length_2;
    (&_S582)->width = width_0;
    (&_S582)->opaque = opaque_0;
    (&_S582)->lift = lift_0;
    (&_S582)->own = *own_0;
    (&_S582)->fiber = fiber_0;
    (&_S582)->faced = faced_0;
    return _S582;
}

__device__ float3  safeDivide(float3  a_5, float3  b_3)
{
    float3  _S583 = a_5 / b_3;
    float3  _S584 = make_float3 (0.0f);
    bool3  _S585 = b_3 == _S584;
    float3  _S586 = _slang_select(_S585, _S584,_S583);
    return _S586;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S587 = (1U << count_2) - 1U;
    return (e_2 & (~(_S587 << offset_1))) | ((newbits_0 & _S587) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_0 = r_2;
    uint _S588 = insertBits_0(r_2.path, end_0, 0U, 5U);
    uint _S589 = insertBits_0(_S588, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S589;
    (&candidate_0)->f = f_5;
    return candidate_0;
}

__device__ void offer(Selection * sel_0, Reservoir candidate_1, float3  weight_0)
{
    float _S590 = rgb_to_greyscale(weight_0);
    bool _S591 = _S590 > 0.0f;
    bool _S592;
    if(_S591)
    {
        _S592 = _S590 < 3.00000000549775576e+38f;
    }
    else
    {
        _S592 = false;
    }
    bool _S593 = !_S592;
    if(_S593)
    {
        return;
    }
    bool _S594 = sel_0->sums;
    if(_S594)
    {
        float3  _S595 = sel_0->color + weight_0;
        sel_0->color = _S595;
        return;
    }
    float _S596 = sel_0->w_sum + _S590;
    sel_0->w_sum = _S596;
    float3  _S597 = sel_0->color + weight_0;
    sel_0->color = _S597;
    Random _S598 = pcg(sel_0->random_state);
    sel_0->random_state = _S598.state;
    bool _S599 = (_S598.value * sel_0->w_sum) <= _S590;
    if(_S599)
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
    Random _S600 = pcg(random_state_8);
    Random _S601 = pcg(_S600.state);
    float _S602 = 1.0f - 2.0f * _S600.value;
    float _S603 = (F32_sqrt(((F32_max((1.0f - _S602 * _S602), (0.0f))))));
    float _S604 = 6.28318548202514648f * _S601.value;
    return make_float3 (_S603 * (F32_cos((_S604))), _S603 * (F32_sin((_S604))), _S602);
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2)
{
    BSDFMaterial _S605;
    (&_S605)->albedo = albedo_0;
    (&_S605)->emissive = emissive_0;
    (&_S605)->roughness = roughness_0;
    (&_S605)->metallic = metallic_0;
    (&_S605)->transmission = transmission_0;
    (&_S605)->ior = ior_0;
    (&_S605)->absorption = absorption_0;
    (&_S605)->specular_tint = specular_tint_0;
    (&_S605)->specular_level = specular_level_0;
    (&_S605)->translucent = translucent_0;
    (&_S605)->sheen = sheen_2;
    (&_S605)->sheen_roughness = sheen_roughness_0;
    (&_S605)->anisotropy = anisotropy_0;
    (&_S605)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S605)->tangent = tangent_2;
    return _S605;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1)
{
    FKMedium _S606;
    (&_S606)->scatter = scatter_1;
    (&_S606)->extinction = extinction_1;
    return _S606;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_7, bool skip_0, uint random_state_9, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S607;
    (&_S607)->smooth_n = smooth_n_4;
    (&_S607)->geometry_n = geometry_n_2;
    (&_S607)->geometry_offset = geometry_offset_2;
    (&_S607)->material = *material_7;
    (&_S607)->skip = skip_0;
    (&_S607)->random_state = random_state_9;
    (&_S607)->coverage = coverage_0;
    (&_S607)->encloses = encloses_0;
    (&_S607)->volume = *volume_0;
    (&_S607)->fills = fills_0;
    (&_S607)->hair = hair_0;
    return _S607;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S608 = (&surface_5->material)->emissive;
    float3  _S609 = make_float3 (0.0f);
    bool _S610 = !top_0;
    float3  _S611 = _slang_select(_S610, _S609,_S608);
    (&(&lower_0)->material)->emissive = _S611;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_2)
{
    float _S612 = surface_6->coverage;
    bool _S613 = u_2 < _S612;
    if(_S613)
    {
        return *surface_6;
    }
    float3  _S614 = make_float3 (0.0f);
    float3  _S615 = make_float3 (1.0f);
    BSDFMaterial _S616 = Material_x24init_0(_S614, _S614, 0.0f, 0.0f, 0.0f, 0.0f, _S614, _S615, 1.0f, _S614, _S614, 0.5f, 0.0f, 0.0f, _S614);
    BSDFMaterial material_8 = _S616;
    (&material_8)->albedo = _S615;
    (&material_8)->emissive = (&surface_6->material)->emissive;
    (&material_8)->transmission = 1.0f;
    (&material_8)->ior = 1.0f;
    (&material_8)->absorption = (&surface_6->material)->absorption;
    FKSurface through_0 = *surface_6;
    (&through_0)->material = material_8;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S617 = transmission_1 > 0.0f;
    bool _S618;
    if(_S617)
    {
        _S618 = true;
    }
    else
    {
        _S618 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S619;
    if(_S618)
    {
        _S619 = 1.0f;
    }
    else
    {
        _S619 = -1.0f;
    }
    return _S619;
}

static __device__ bool arrivesBehind_0(float3  dir_9, float3  n_9)
{
    return (dot_0(dir_9, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_10)
{
    float3  _S620 = surface_7->geometry_n;
    float _S621 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_10);
    FKSurface faced_1 = *surface_7;
    float3  _S622 = surface_7->smooth_n * make_float3 (_S621);
    (&faced_1)->smooth_n = _S622;
    float3  _S623 = _S620 * make_float3 (_S621);
    (&faced_1)->geometry_n = _S623;
    return faced_1;
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
    float3  _S624 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_2) * log_0(_S624));
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
    bool _S625;
    if(open_0)
    {
        _S625 = prev_rough_0;
    }
    else
    {
        _S625 = false;
    }
    if(_S625)
    {
        _S625 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S625 = false;
    }
    return _S625;
}

static __device__ float2  vertexEta_0(BSDFMaterial * material_9, float n_dot_v_0)
{
    bool _S626 = n_dot_v_0 < 0.0f;
    float _S627 = material_9->ior;
    float _S628 = _slang_select(_S626, _S627,1.0f);
    float _S629 = _slang_select(_S626, 1.0f,_S627);
    return make_float2 (_S628, _S629);
}

__device__ bool samplesLights(BSDFMaterial material_10)
{
    bool _S630 = (material_10.roughness) > 0.0f;
    bool _S631;
    if(_S630)
    {
        _S631 = true;
    }
    else
    {
        bool _S632 = (material_10.metallic) < 1.0f;
        if(_S632)
        {
            _S631 = (material_10.transmission) < 1.0f;
        }
        else
        {
            _S631 = false;
        }
    }
    return _S631;
}

__device__ float3  sideNormal(FKSurface surface_8, float3  in_dir_5)
{
    bool _S633 = !((surface_8.material.transmission) > 0.0f);
    bool _S634;
    if(_S633)
    {
        BSDFMaterial _S635 = surface_8.material;
        bool _S636 = isTranslucent_0(&_S635);
        _S634 = !_S636;
    }
    else
    {
        _S634 = false;
    }
    if(_S634)
    {
        _S634 = (dot_0(surface_8.smooth_n, - in_dir_5)) > 0.0f;
    }
    else
    {
        _S634 = false;
    }
    float3  _S637 = _slang_select(_S634, surface_8.smooth_n,surface_8.geometry_n);
    return _S637;
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
    MediumSides _S638;
    (&_S638)->behind = *behind_0;
    (&_S638)->front = *front_0;
    (&_S638)->fillings = fillings_1;
    (&_S638)->face = face_1;
    return _S638;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_11)
{
    float3  _S639 = surface_9->geometry_n;
    MediumSides _S640 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S640;
    bool _S641 = surface_9->encloses;
    if(_S641)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S642 = (dot_0(dir_11, _S639)) > 0.0f;
        if(_S642)
        {
            float3  _S643 = make_float3 (0.0f);
            FKMedium _S644 = Medium_x24init_0(_S643, _S643);
            (&sides_0)->front = _S644;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  side_n_3, float3  extinction_2, uint filling_1, float3  dir_12, uint depth_2, uint lobe_9, float length_3, float width_1, bool opaque_1, float3  lift_1, FKHit * own_1, bool fiber_1)
{
    FKSurface faced_2 = *surface_10;
    float3  _S645 = surface_10->geometry_n;
    float3  _S646 = - surface_10->geometry_n;
    float3  _S647 = _slang_select(turned_0, _S646,_S645);
    (&faced_2)->geometry_n = _S647;
    FKMedium _S648 = Medium_x24init_0(make_float3 (0.0f), extinction_2);
    FKSurface _S649 = faced_2;
    FKMedium _S650 = _S648;
    MediumSides _S651 = mediumSides_0(&_S649, &_S650, filling_1, dir_12);
    ShadowContext _S652 = ShadowContext_x24init_0(_S651.behind.extinction, _S651.front.extinction, _S651.fillings, side_n_3, depth_2, lobe_9, true, length_3, width_1, opaque_1, lift_1, own_1, fiber_1, true);
    ShadowContext context_2 = _S652;
    if(turned_0)
    {
        uint2  _S653 = _S651.fillings;
        ShadowContext _S654 = ShadowContext_x24init_0(_S651.front.extinction, _S651.behind.extinction, uint2 {_S653.y, _S653.x}, side_n_3, depth_2, lobe_9, true, length_3, width_1, opaque_1, lift_1, own_1, fiber_1, true);
        context_2 = _S654;
    }
    bool _S655 = isTranslucent_0(&surface_10->material);
    bool _S656 = !_S655;
    (&context_2)->faced = _S656;
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

__device__ __forceinline__ float3  BSDF(float3  in_dir_6, float3  out_dir_1, float3  n_10, float3  g_n_0, BSDFMaterial material_11, float eta_i_5, float eta_o_5, uint random_state_10)
{
    float3  _S657 = negate_0(in_dir_6);
    bool _S658 = (dot_0(g_n_0, _S657) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S658)
    {
        SampleBSDF _S659 = connectBSDF(in_dir_6, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 0U, random_state_10);
        SampleBSDF _S660 = connectBSDF(in_dir_6, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 2U, random_state_10);
        return _S659.throughput * make_float3 (_S659.pdf) + _S660.throughput * make_float3 (_S660.pdf);
    }
    SampleBSDF _S661 = connectBSDF(in_dir_6, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 1U, random_state_10);
    return _S661.throughput * make_float3 (_S661.pdf);
}

__device__ float3  translucentCorrection(float3  in_dir_7, float3  out_dir_2, float3  n_11, float3  g_n_1, BSDFMaterial material_12, float eta_i_6, float eta_o_6, uint random_state_11)
{
    float _S662 = dot_0(n_11, out_dir_2);
    float3  _S663 = negate_0(in_dir_7);
    bool _S664 = (_S662 * dot_0(n_11, _S663)) < 0.0f;
    SampleBSDF _S665 = connectBSDF(in_dir_7, out_dir_2, n_11, material_12, eta_i_6, eta_o_6, 0U, random_state_11);
    float3  _S666 = negate_0(in_dir_7);
    bool _S667 = (dot_0(g_n_1, _S666) * dot_0(g_n_1, out_dir_2)) > 0.0f;
    float3  _S668 = make_float3 (0.0f);
    float3  _S669 = _S665.throughput * make_float3 (_S665.pdf);
    float _S670 = _slang_select(_S667, -1.0f,1.0f);
    float3  _S671 = _S669 * make_float3 (_S670);
    float3  _S672 = _slang_select(_S664, _S671,_S668);
    return _S672;
}

__device__ float3  translucentBSDF(float3  in_dir_8, float3  out_dir_3, float3  n_12, float3  g_n_2, BSDFMaterial material_13, float eta_i_7, float eta_o_7, uint random_state_12)
{
    float3  _S673 = BSDF(in_dir_8, out_dir_3, n_12, g_n_2, material_13, eta_i_7, eta_o_7, random_state_12);
    float3  _S674 = translucentCorrection(in_dir_8, out_dir_3, n_12, g_n_2, material_13, eta_i_7, eta_o_7, random_state_12);
    return _S673 + _S674;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_9, TreeSample * light_1, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_14, float eta_i_8, float eta_o_8, bool competing_1, uint random_state_13)
{
    bool _S675 = !competing_1;
    bool _S676;
    if(_S675)
    {
        _S676 = true;
    }
    else
    {
        _S676 = (light_1->density) == 0.0f;
    }
    if(_S676)
    {
        bool _S677 = isTranslucent_0(material_14);
        if(_S677)
        {
            float3  _S678 = translucentBSDF(in_dir_9, light_1->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_8, eta_o_8, random_state_13);
            return _S678 * light_1->radiance;
        }
        float3  _S679 = BSDF(in_dir_9, light_1->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_8, eta_o_8, random_state_13);
        return _S679 * light_1->radiance;
    }
    float3  _S680 = light_1->dir;
    bool _S681 = (dot_0(geometry_n_4, - in_dir_9) * dot_0(geometry_n_4, light_1->dir)) <= 0.0f;
    float3  _S682 = neeBSDF(in_dir_9, _S680, smooth_n_5, *material_14, eta_i_8, eta_o_8, _S681, light_1->density, true, random_state_13);
    return _S682 * light_1->radiance * make_float3 (light_1->density);
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S683 = (F32_sqrt((random_1_0)));
    float _S684 = 6.28318548202514648f * random_2_0;
    float _S685 = _S683 * (F32_cos((_S684)));
    float _S686 = _S683 * (F32_sin((_S684)));
    float _S687 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S685 * _S685 - _S686 * _S686))))));
    return make_float3 (_S685, _S687, _S686);
}

static __device__ float3  reflect_0(float3  i_9, float3  n_13)
{
    return i_9 - make_float3 (2.0f * dot_0(n_13, i_9)) * n_13;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_14, BSDFMaterial material_15, float eta_i_9, float eta_o_9, uint random_init_1, float2  screen_space_0)
{
    uint random_state_14 = random_init_1;
    float3  _S688 = negate_0(in_dir_10);
    float _S689 = dot_0(n_14, _S688);
    float _S690 = sign_0(_S689);
    float3  n_i_4 = n_14 * make_float3 (_S690);
    float _S691 = (F32_abs((_S689)));
    float _S692 = material_15.roughness;
    float _S693 = _S692 * _S692;
    AnisotropicFrame _S694 = anisotropicFrame(material_15, n_i_4);
    float3  _S695 = sampleMaterialHalfVector(_S688, n_i_4, _S693, _S694, &random_state_14);
    BSDFLobes _S696 = bsdfLobes(in_dir_10, _S688, n_i_4, _S695, material_15, eta_i_9, eta_o_9, _S694);
    BSDFLobes lobes_3 = _S696;
    float _S697 = translucentShare(material_15);
    (&lobes_3)->translucent_share = _S697;
    float3  _S698 = make_float3 (1.0f);
    SampleBSDF _S699 = SampleBSDF_x24init_0(_S698, _S698, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S699;
    Random _S700 = pcg(random_state_14);
    random_state_14 = _S700.state;
    bool _S701 = (_S700.value) < ((&lobes_3)->p_diffuse);
    if(_S701)
    {
        Random _S702 = pcg(random_state_14);
        Random _S703 = pcg(_S702.state);
        (&sample_1)->random_state = _S703.state;
        float3  _S704 = sampleCosWeightedHemisphere(_S702.value, _S703.value);
        bool _S705 = (_S700.value) < ((&lobes_3)->p_diffuse * (&lobes_3)->translucent_share);
        float _S706 = _S704.y;
        float _S707 = - _S706;
        float _S708 = _slang_select(_S705, _S707,_S706);
        float3  _S709 = tangentToWorld(make_float3 (_S704.x, _S708, _S704.z), n_i_4);
        (&sample_1)->unit_direction = _S709;
        float3  _S710 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S693, material_15, lobes_3, 0U);
        (&sample_1)->throughput = _S710;
        float _S711 = lobeDensity(_S708, 0.0f, _S691, _S693, lobes_3, eta_i_9, eta_o_9, 0U);
        (&sample_1)->pdf = _S711;
        (&sample_1)->refracted = _S705;
        return sample_1;
    }
    bool _S712 = (_S700.value) < ((&lobes_3)->p_diffuse + (&lobes_3)->p_refract);
    if(_S712)
    {
        (&sample_1)->unit_direction = (&lobes_3)->refracted;
        float _S713 = lobeDensity(0.0f, dot_0((&sample_1)->unit_direction, _S695), _S691, _S693, lobes_3, eta_i_9, eta_o_9, 1U);
        (&sample_1)->pdf = _S713;
        float3  _S714 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S693, material_15, lobes_3, 1U);
        (&sample_1)->throughput = _S714;
        (&sample_1)->random_state = random_state_14;
        (&sample_1)->refracted = true;
        (&sample_1)->lobe = 1U;
        return sample_1;
    }
    float3  _S715 = reflect_0(in_dir_10, _S695);
    float3  _S716 = ((((_S715)) * make_float3(rnorm3df(((_S715)).x, ((_S715)).y, ((_S715)).z))));
    (&sample_1)->unit_direction = _S716;
    float3  _S717 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S693, material_15, lobes_3, 2U);
    (&sample_1)->throughput = _S717;
    (&sample_1)->random_state = random_state_14;
    (&sample_1)->lobe = 2U;
    float _S718 = lobeDensity(0.0f, 0.0f, _S691, _S693, lobes_3, eta_i_9, eta_o_9, 2U);
    (&sample_1)->pdf = _S718;
    return sample_1;
}

__device__ bool withinInverseFootprint(float pdf_6, bool diffuse_0, float prev_cos_0, float distance_4, float threshold_1)
{
    bool _S719 = pdf_6 > 0.0f;
    bool _S720;
    if(_S719)
    {
        if(diffuse_0)
        {
            _S720 = true;
        }
        else
        {
            _S720 = (pdf_6 * prev_cos_0 / (distance_4 * distance_4) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S720 = false;
    }
    return _S720;
}

__device__ bool roughLobe(float pdf_7, bool diffuse_1, float roughness_1)
{
    bool _S721 = pdf_7 > 0.0f;
    bool _S722;
    if(_S721)
    {
        if(diffuse_1)
        {
            _S722 = true;
        }
        else
        {
            _S722 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S722 = false;
    }
    return _S722;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S723 = layers_0 > 1U;
    bool _S724;
    if(_S723)
    {
        _S724 = refracting_0 != passed_0;
    }
    else
    {
        _S724 = false;
    }
    return _S724;
}

static __device__ float widened_0(float spread_0, float pdf_8, bool delta_0)
{
    float _S725 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_8))))), (3.14159274101257324f)));
    bool _S726 = !delta_0;
    float _S727 = _slang_select(_S726, _S725,0.0f);
    return spread_0 + _S727;
}

static __device__ bool leavesInFront_0(float3  face_2, float3  dir_13, float3  side_n_4, float3  g_0)
{
    return ((dot_0(dir_13, side_n_4)) > 0.0f) == ((dot_0(g_0, face_2)) > 0.0f);
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
    float density_2;
    float threshold_2;
    float width_2;
    float sky_pdf_0;
    float geometry_density_2;
    uint b_4;
    uint layer_0;
    float3  throughput_2;
    float3  chain_throughput_0;
    TreeSample light_2;
    int _S728;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_3;
    float sky_pdf_1;
    float width_4;
    float spread_3;
    uint b_5;
    Shift arrived_end_0;
    float3  _S729 = make_float3 (0.0f);
    Shift _S730 = Shift_x24init_0(_S729, 0.0f);
    uint _S731 = r_3->path;
    uint _S732 = extractBits_0(r_3->path, 0U, 5U);
    uint _S733 = extractBits_0(_S731, 5U, 5U);
    uint _S734 = extractBits_0(_S731, 10U, 2U);
    uint _S735 = extractBits_0(_S731, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S736 = _S735 >= 3U;
        uint _S737 = _slang_select(_S736, 1U,0U);
        uint _S738 = _S732 + _S737;
        uint _S739 = (fcptMaxBounces());
        passes_0 = _S738 > _S739;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S730;
    }
    uint _S740 = _S733 - 1U;
    bool _S741 = _S735 == 3U;
    uint _S742 = _slang_select(_S741, 1U,0U);
    uint _S743 = _S732 + _S742;
    bool _S744 = _S734 == 0U;
    uint _S745 = _slang_select(_S744, _S743,_S740);
    FKHit _S746 = (fcptReservoirHit((*r_3)));
    float3  _S747 = dom_0->x0;
    float3  _S748 = dom_0->x1 - dom_0->x0;
    float3  _S749 = ((((_S748)) * make_float3(rnorm3df(((_S748)).x, ((_S748)).y, ((_S748)).z))));
    FKRay _S750 = Ray_x24init_0(dom_0->x1, _S749);
    FKRay ray_2 = _S750;
    FKHit hit_1 = dom_0->hit;
    float3  scatter_in_0 = _S729;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S729;
    float3  extinction_in_0 = _S729;
    uint filling_2 = 4294967295U;
    float _S751 = dom_0->spread;
    float _S752 = dom_0->width;
    float _S753 = length_0(_S748);
    NEEVertex _S754 = NEEVertex_x24init_0(true, 0.0f, _S729, _S729, _S729);
    NEEVertex nee_vertex_0 = _S754;
    Vertex _S755 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S755;
    Reservoir _S756 = (Reservoir{});
    Reservoir chain_0 = _S756;
    uint _S757 = r_3->seed;
    (&chain_0)->seed = r_3->seed;
    (&ray_2)->origin = _S747;
    (&hit_1)->distance = _S753;
    FKMedium _S758 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_1)->distance), (&filling_2)));
    scatter_in_0 = _S758.scatter;
    extinction_in_0 = _S758.extinction;
    Reservoir _S759 = chain_0;
    uint _S760 = filling_2;
    for(;;)
    {
        bool _S761 = _S760 != 4294967295U;
        if(_S761)
        {
            float _S762 = (fcptMajorant((_S760)));
            spread_1 = _S762;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            passes_0 = 4294967295U == _S745;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            passes_0 = _S734 == 1U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            passes_0 = spread_1 > 0.0f;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            ended_0 = _S730;
            sky_pdf_0 = 0.0f;
            spread_1 = _S751;
            width_2 = _S752;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_4 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S763 = (&prev_0)->rough;
        if(_S763)
        {
            passes_0 = !(spread_1 > 0.0f);
        }
        else
        {
            passes_0 = false;
        }
        (&prev_0)->rough = passes_0;
        uint _S764 = stream(_S757, 384U);
        uint tracking_0 = _S764;
        weight_1 = throughput_3;
        glowed_0 = _S729;
        b_4 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_2 = _S751;
        width_2 = _S752;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_1)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S728 = int(1);
                break;
            }
            uint _S765 = b_4 + 320U;
            bool _S766 = b_4 == 4294967295U;
            uint _S767 = _slang_select(_S766, 384U,_S765);
            uint _S768 = stream(_S757, _S767);
            Random _S769 = pcg(_S768);
            float _S770 = freeFlight_0(_S769.value, spread_1);
            if(_S761)
            {
                float3  _S771 = (&ray_2)->origin;
                float3  _S772 = (&ray_2)->unit_direction;
                float _S773 = (&hit_1)->distance;
                uint _S774 = _slang_select(_S766, 0U,b_4);
                uint _S775 = (&prev_0)->lobe;
                uint _S776 = _slang_select(_S766, 3U,_S775);
                float _S777 = (fcptTrackMedium((_S760), (_S771), (_S772), (_S773), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S774), (_S776), (_S766)));
                geometry_density_2 = _S777;
            }
            else
            {
                geometry_density_2 = _S770;
            }
            bool _S778 = !(geometry_density_2 < ((&hit_1)->distance));
            if(_S778)
            {
                _S728 = int(1);
                break;
            }
            if(_S761)
            {
                passes_0 = !replay_1;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                float3  _S779 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S780 = sel_1->glow + _S779;
                sel_1->glow = _S780;
            }
            else
            {
            }
            glowed_0 = _S729;
            uint b_6 = b_4 + 1U;
            float3  _S781 = (&ray_2)->origin + make_float3 (geometry_density_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S781;
            float3  _S782 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, geometry_density_2, true);
            float3  _S783 = weight_1;
            float3  _S784 = _slang_select(_S761, _S783,_S782);
            float3  throughput_4 = throughput_2 * _S784;
            uint _S785 = stream(_S757, b_6 + 320U);
            tracking_0 = _S785;
            weight_1 = throughput_3;
            float width_5 = width_2 + threshold_2 * geometry_density_2;
            float _S786 = threshold_2 + 3.14159274101257324f;
            bool _S787 = scatterSampled_0(replay_1, b_6, _S745, _S761);
            TreeSample _S788 = TreeSample_x24init_0(_S729, _S729, 0.0f, 0U);
            if(_S787)
            {
                float3  _S789 = (&ray_2)->origin;
                float3  _S790 = (&ray_2)->unit_direction;
                float3  _S791 = (&ray_2)->unit_direction;
                uint _S792 = stream(_S757, b_6 + 64U);
                float3  _S793 = extinction_in_0;
                float3  _S794 = extinction_in_0;
                uint2  _S795 = make_uint2 (_S760);
                float3  _S796 = (&ray_2)->unit_direction;
                uint _S797 = arrivalLobe_0(b_6, (&prev_0)->lobe);
                FKHit _S798 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S799 = _S798;
                ShadowContext _S800 = ShadowContext_x24init_0(_S793, _S794, _S795, _S796, b_6, _S797, false, geometry_density_2, width_5, false, _S729, &_S799, false, true);
                ShadowContext _S801 = _S800;
                TreeSample _S802 = sampleLightTree_0(_S789, _S790, _S791, 0.0f, true, _S792, &_S801);
                light_2 = _S802;
            }
            else
            {
                light_2 = _S788;
            }
            uint _S803 = (fcptMaxBounces());
            bool _S804 = b_6 < _S803;
            if(_S804)
            {
                turned_1 = (light_2.density) > 0.0f;
            }
            else
            {
                turned_1 = false;
            }
            float _S805 = _slang_select(turned_1, 0.07957746833562851f,0.0f);
            float3  _S806 = throughput_4 * light_2.radiance;
            float _S807 = powerHeuristic(light_2.density, _S805);
            float3  _S808 = _S806 * make_float3 (0.07957746833562851f * _S807);
            float3  _S809 = _slang_select(_S787, _S808,_S729);
            if(replay_1)
            {
                is_inside_5 = b_6 == _S745;
            }
            else
            {
                is_inside_5 = false;
            }
            if(is_inside_5)
            {
                bool _S810 = _S734 == 2U;
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
                    _S728 = int(0);
                    ended_0 = _S812;
                    spread_1 = _S786;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                _S728 = int(0);
                ended_0 = _S730;
                spread_1 = _S786;
                geometry_density_2 = width_5;
                chain_throughput_0 = throughput_4;
                layer_0 = b_6;
                break;
            }
            bool _S813 = !replay_1;
            if(_S813)
            {
                Reservoir candidate_2 = _S759;
                uint _S814 = extractBits_0(_S759.path, 10U, 2U);
                bool _S815 = _S814 == 1U;
                if(_S815)
                {
                    float3  _S816 = safeDivide(_S809, _S729);
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
                uint _S821 = stream(_S757, b_6 + 128U);
                Random _S822 = pcg(_S821);
                bool _S823 = _S820 < (_S822.value);
                if(_S823)
                {
                    viewed_0 = true;
                }
                else
                {
                    uint _S824 = (fcptMaxBounces());
                    viewed_0 = b_6 >= _S824;
                }
                if(viewed_0)
                {
                    _S728 = int(0);
                    ended_0 = _S730;
                    spread_1 = _S786;
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
            NEEVertex _S826 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_2)->origin, _S729, (&ray_2)->origin);
            nee_vertex_0 = _S826;
            uint _S827 = stream(_S757, b_6);
            float3  _S828 = isotropic_0(_S827);
            (&ray_2)->unit_direction = _S828;
            Vertex _S829 = scatteredVertex_0(false);
            prev_0 = _S829;
            float _S830 = (&prev_0)->pdf;
            FKRay _S831 = ray_2;
            FKHit _S832 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S833 = (fcptTraverseInstanceBVH((_S831), (true), (4.294967296e+09f), (false), (_S832), (false)));
            hit_1 = _S833;
            b_4 = b_6;
            throughput_2 = throughput_4;
            threshold_2 = _S786;
            width_2 = width_5;
            sky_pdf_0 = _S830;
        }
        if(_S728 != int(1))
        {
            width_2 = geometry_density_2;
            throughput_2 = chain_throughput_0;
            b_4 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S730;
        spread_1 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S834 = b_4 == 4294967295U;
    Reservoir _S835 = chain_0;
    NEEVertex _S836 = nee_vertex_0;
    Vertex _S837 = prev_0;
    FKHit _S838 = hit_1;
    uint _S839 = filling_2;
    float3  _S840 = scatter_in_0;
    float3  _S841 = extinction_in_0;
    float3  _S842 = weight_1;
    float3  _S843 = glowed_0;
    for(;;)
    {
        bool _S844 = (_S838.instance_index) == 4294967295U;
        if(_S844)
        {
            bool _S845 = !_S836.none;
            float _S846 = _slang_select(_S845, sky_pdf_0,0.0f);
            float _S847 = escapeWeight_0(_S846, (&ray_2)->unit_direction);
            float3  _S848 = environment_0((&ray_2)->unit_direction, b_4, _S837.lobe);
            float3  _S849 = throughput_2 * _S848;
            if(replay_1)
            {
                bool _S850 = b_4 == _S745;
                if(_S850)
                {
                    passes_0 = _S734 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S851 = Shift_x24init_0(_S849 * make_float3 (_S847) / make_float3 (r_3->jac), density_2 / r_3->jac);
                    ended_0 = _S851;
                    passes_0 = true;
                    break;
                }
                if(_S744)
                {
                    passes_0 = _S741;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_4 == _S732;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S837.rough;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S852 = Shift_x24init_0(_S849 * make_float3 (_S847), 1.0f);
                    ended_0 = _S852;
                    passes_0 = true;
                    break;
                }
                ended_0 = _S730;
                passes_0 = true;
                break;
            }
            Reservoir candidate_3 = _S835;
            uint _S853 = extractBits_0(_S835.path, 10U, 2U);
            bool _S854 = _S853 == 1U;
            if(_S854)
            {
                uint _S855 = extractBits_0(_S835.path, 5U, 5U);
                bool _S856 = _S855 == b_4;
                float _S857 = _slang_select(_S856, 1.0f,_S847);
                float3  _S858 = safeDivide(_S849 * make_float3 (_S857), _S729);
                (&candidate_3)->radiance = _S858;
            }
            else
            {
                if(_S837.rough)
                {
                    uint _S859 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                    uint _S860 = insertBits_0(_S859, 3U, 10U, 2U);
                    uint _S861 = insertBits_0(_S860, _S837.lobe, 15U, 2U);
                    uint _S862 = _slang_select(_S837.inside, 1U,0U);
                    uint _S863 = insertBits_0(_S861, _S862, 20U, 1U);
                    (&candidate_3)->path = _S863;
                    (&candidate_3)->jac = _S837.pdf;
                    (&candidate_3)->dir = (&ray_2)->unit_direction;
                }
                else
                {
                }
            }
            float3  _S864 = _S849 * make_float3 (_S847);
            Reservoir _S865 = withEnd(candidate_3, 3U, b_4, _S864);
            offer(sel_1, _S865, _S864 * make_float3 (scale_1) / make_float3 (density_2));
            ended_0 = _S730;
            passes_0 = true;
            break;
        }
        float3  _S866 = (&ray_2)->origin + make_float3 (_S838.distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S866;
        bool _S867 = _S839 != 4294967295U;
        if(_S867)
        {
            bool _S868 = !replay_1;
            if(_S868)
            {
                float3  _S869 = throughput_2 * _S843 / make_float3 (density_2);
                float3  _S870 = sel_1->glow + _S869;
                sel_1->glow = _S870;
            }
            else
            {
            }
            float3  _S871 = throughput_2 * _S842;
            throughput_2 = _S871;
        }
        else
        {
            float3  _S872 = flightWeight_0(_S840, _S841, (_S840.x + _S840.y + _S840.z) / 3.0f, _S838.distance, false);
            float3  _S873 = throughput_2 * _S872;
            throughput_2 = _S873;
        }
        float _S874 = width_2 + spread_1 * _S838.distance;
        ended_0 = _S730;
        width_2 = _S874;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    uint _S875 = b_4 + 1U;
    b_4 = _S875;
    layer_0 = 0U;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S729;
    float3  reconnection_0 = _S729;
    viewed_0 = _S834;
    for(;;)
    {
        bool _S876 = ((&hit_1)->is_point_light) == 1U;
        FKMedium _S877 = Medium_x24init_0(_S729, _S729);
        BSDFMaterial _S878 = Material_x24init_0(_S729, _S729, 0.0f, 0.0f, 0.0f, 0.0f, _S729, throughput_3, 1.0f, _S729, _S729, 0.5f, 0.0f, 0.0f, _S729);
        FKMedium _S879 = _S877;
        FKSurface _S880 = Surface_x24init_0(_S729, _S729, 0.0f, &_S878, false, 0U, 1.0f, false, &_S879, 4294967295U, _S729);
        bool _S881 = !_S876;
        bool scatter_2;
        bool is_inside_6;
        float3  throughput_5;
        FKSurface surface_11;
        if(_S881)
        {
            uint _S882 = stream(_S757, b_4);
            uint _S883 = arrivalLobe_0(b_4, (&prev_0)->lobe);
            FKSurface _S884 = (fcptSurfaceAtPath((hit_1), ((&ray_2)->origin), (_S882), (width_2), (layer_0), (b_4), (_S883), ((&ray_2)->unit_direction)));
            bool _S885 = !passes_0;
            FKSurface _S886 = _S884;
            FKSurface _S887 = emitting_0(&_S886, _S885);
            uint _S888 = stream(_S757, b_4 + 256U);
            Random _S889 = pcg(_S888);
            FKSurface _S890 = _S887;
            FKSurface _S891 = uncovered_0(&_S890, _S889.value);
            float _S892 = facingSign(_S891.material.transmission, _S891.geometry_n, (&ray_2)->unit_direction);
            bool _S893 = _S892 < 0.0f;
            bool _S894 = (_S891.material.transmission) > 0.0f;
            if(_S894)
            {
                bool _S895 = arrivesBehind_0((&ray_2)->unit_direction, _S891.geometry_n);
                scatter_2 = _S895;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S896 = _S891;
            FKSurface _S897 = facingRay_0(&_S896, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S898 = arrivesBehind_0((&ray_2)->unit_direction, _S897.geometry_n);
                is_inside_6 = _S898;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S899 = beerLambert((&hit_1)->distance, _S897.material.absorption);
                float3  _S900 = throughput_2 * _S899;
                throughput_5 = _S900;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S901 = !_S897.skip;
            float geometry_density_3 = geometryDensity(_S897.geometry_n, (&ray_2)->unit_direction, (&hit_1)->distance);
            bool _S902 = b_4 == _S875;
            if(_S902)
            {
                float _S903 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S903;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S904 = geometry_density_2;
            scatter_2 = _S901;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S904;
            surface_11 = _S897;
            turned_1 = _S893;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_11 = _S880;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S905 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S906 = surface_11;
        FKSurface _S907 = surface_11;
        float _S908 = dot_0(surface_11.smooth_n, - (&ray_2)->unit_direction);
        BSDFMaterial _S909 = _S906.material;
        float2  _S910 = vertexEta_0(&_S909, _S908);
        bool _S911;
        if(scatter_2)
        {
            bool _S912 = samplesLights(_S906.material);
            _S911 = _S912;
        }
        else
        {
            _S911 = false;
        }
        bool _S913;
        if(passes_0)
        {
            _S913 = true;
        }
        else
        {
            _S913 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S913)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S911;
        }
        float3  _S914 = sideNormal(surface_11, (&ray_2)->unit_direction);
        FKSurface _S915 = surface_11;
        float3  _S916 = surface_11.hair;
        bool _S917 = (dot_0(_S916, _S916)) > 0.0f;
        bool _S918 = !_S917;
        bool _S919;
        if(_S918)
        {
            _S919 = !((_S906.material.transmission) > 0.0f);
        }
        else
        {
            _S919 = false;
        }
        FKSurface _S920 = surface_11;
        float3  _S921 = surface_11.geometry_n * make_float3 (dot_0(surface_11.geometry_n, _S907.smooth_n));
        float3  emission_0;
        if(_S876)
        {
            float3  _S922 = (fcptCalculatePointLightContrib(((&hit_1)->instance_index)));
            emission_0 = _S922;
        }
        else
        {
            emission_0 = _S906.material.emissive;
        }
        float _S923 = rgb_to_greyscale(emission_0);
        bool _S924 = _S923 > 0.0f;
        float3  emission_1;
        if(_S924)
        {
            NEEVertex _S925 = nee_vertex_0;
            FKHit _S926 = hit_1;
            float _S927 = emissionWeight_0(&_S925, &_S926, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S927);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S928;
        if(replay_1)
        {
            _S928 = _S734 == 1U;
        }
        else
        {
            _S928 = false;
        }
        bool _S929;
        if(_S928)
        {
            _S929 = b_4 > _S733;
        }
        else
        {
            _S929 = false;
        }
        bool _S930;
        if(_S929)
        {
            _S930 = b_4 == _S732;
        }
        else
        {
            _S930 = false;
        }
        bool _S931;
        if(_S930)
        {
            bool _S932 = _S735 == 1U;
            if(_S932)
            {
                _S931 = true;
            }
            else
            {
                _S931 = _S735 == 2U;
            }
        }
        else
        {
            _S931 = false;
        }
        if(_S931)
        {
            bool _S933 = _S876 != (_S735 == 2U);
            if(_S933)
            {
                return _S730;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_3->jac), density_2 / r_3->jac);
        }
        uint _S934 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S935 = _S934 == 1U;
        Reservoir here_0 = chain_0;
        uint _S936 = insertBits_0(0U, b_4, 5U, 5U);
        uint _S937 = insertBits_0(_S936, 1U, 10U, 2U);
        uint _S938 = insertBits_0(_S937, (&prev_0)->lobe, 15U, 2U);
        bool _S939 = (&prev_0)->inside;
        uint _S940 = _slang_select(_S939, 1U,0U);
        uint _S941 = insertBits_0(_S938, _S940, 20U, 1U);
        (&here_0)->path = _S941;
        float _S942 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S942;
        fcptWithReservoirHit((&here_0), (&hit_1));
        bool _S943;
        if(replay_1)
        {
            _S943 = _S734 == 1U;
        }
        else
        {
            _S943 = false;
        }
        bool _S944;
        if(_S943)
        {
            _S944 = b_4 == _S733;
        }
        else
        {
            _S944 = false;
        }
        bool _S945 = b_4 == _S745;
        bool _S946;
        if(_S945)
        {
            bool _S947 = !scatter_2;
            if(_S947)
            {
                _S946 = true;
            }
            else
            {
                bool _S948 = _S734 != 1U;
                if(_S948)
                {
                    _S946 = _S734 != 3U;
                }
                else
                {
                    _S946 = false;
                }
            }
        }
        else
        {
            _S946 = false;
        }
        bool _S949;
        if(_S946)
        {
            _S949 = _S734 == 2U;
        }
        else
        {
            _S949 = false;
        }
        bool _S950;
        if(_S949)
        {
            _S950 = !_S905;
        }
        else
        {
            _S950 = false;
        }
        bool _S951;
        if(_S950)
        {
            _S951 = _S735 != 4U;
        }
        else
        {
            _S951 = false;
        }
        bool _S952 = _S733 == _S732;
        bool _S953;
        if(_S952)
        {
            _S953 = _S735 == 0U;
        }
        else
        {
            _S953 = false;
        }
        bool _S954 = _slang_select(_S944, _S953,_S951);
        bool _S955;
        if(nee_0)
        {
            _S955 = _slang_select(replay_1, _S954,scatter_2);
        }
        else
        {
            _S955 = false;
        }
        TreeSample _S956 = TreeSample_x24init_0(_S729, _S729, 0.0f, 0U);
        bool viewed_1;
        float3  throughput_6;
        float3  lit_0;
        if(_S955)
        {
            float3  _S957 = (&ray_2)->origin;
            if(_S917)
            {
                throughput_6 = _S729;
            }
            else
            {
                throughput_6 = _S907.smooth_n;
            }
            FKSurface _S958 = surface_11;
            if(_S917)
            {
                viewed_1 = true;
            }
            else
            {
                BSDFMaterial _S959 = _S906.material;
                bool _S960 = isTranslucent_0(&_S959);
                viewed_1 = _S960;
            }
            uint _S961 = stream(_S757, b_4 + 64U);
            uint _S962 = arrivalLobe_0(b_4, (&prev_0)->lobe);
            FKSurface _S963 = surface_11;
            FKHit _S964 = hit_1;
            ShadowContext _S965 = shadowContext_0(&_S963, turned_1, _S914, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_4, _S962, (&hit_1)->distance, width_2, _S919, _S921, &_S964, _S917);
            ShadowContext _S966 = _S965;
            TreeSample _S967 = sampleLightTree_0(_S957, throughput_6, _S920.geometry_n, _S958.geometry_offset, viewed_1, _S961, &_S966);
            bool _S968 = any_0((_S967.radiance) != _S729);
            if(_S968)
            {
                if(_S917)
                {
                    uint _S969 = (fcptMaxBounces());
                    bool _S970 = b_4 < _S969;
                    FKSurface _S971 = surface_11;
                    TreeSample _S972 = _S967;
                    float3  _S973 = hairLight_0(&_S971, (&ray_2)->unit_direction, &_S972, _S970);
                    lit_0 = _S973;
                }
                else
                {
                    float _S974 = _S910.x;
                    float _S975 = _S910.y;
                    uint _S976 = (fcptMaxBounces());
                    bool _S977 = b_4 < _S976;
                    TreeSample _S978 = _S967;
                    BSDFMaterial _S979 = _S906.material;
                    float3  _S980 = lightBSDF_0((&ray_2)->unit_direction, &_S978, _S907.smooth_n, _S914, &_S979, _S974, _S975, _S977, surface_11.random_state);
                    lit_0 = _S980;
                }
            }
            else
            {
                lit_0 = _S729;
            }
            light_2 = _S967;
        }
        else
        {
            light_2 = _S956;
            lit_0 = _S729;
        }
        bool refracted_4;
        bool wrong_side_0;
        bool _S981;
        bool _S982;
        float density_4;
        if(_S944)
        {
            bool _S983 = ((&hit_1)->instance_index) != (_S746.instance_index);
            if(_S983)
            {
                viewed_1 = true;
            }
            else
            {
                viewed_1 = ((&hit_1)->triangle_index) != (_S746.triangle_index);
            }
            if(viewed_1)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = !_S905;
            }
            if(refracted_4)
            {
                return _S730;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S952)
            {
                wrong_side_0 = _S735 == 1U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            if(_S952)
            {
                _S981 = _S735 == 0U;
            }
            else
            {
                _S981 = false;
            }
            if(_S981)
            {
                bool _S984 = !nee_0;
                if(_S984)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S985 = rgb_to_greyscale(light_2.radiance);
                    passes_0 = !(_S985 > 0.0f);
                }
                if(passes_0)
                {
                    return _S730;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            if(_S952)
            {
                _S982 = _S735 == 4U;
            }
            else
            {
                _S982 = false;
            }
            if(_S982)
            {
                bool _S986 = !nee_0;
                if(_S986)
                {
                    return _S730;
                }
                float _S987 = environmentPdf_0(r_3->dir);
                float3  _S988 = skyBSDF((&ray_2)->unit_direction, r_3->dir, surface_11, _S914, _S910, is_inside_6, _S987, surface_11.random_state);
                return Shift_x24init_0(throughput_7 * _S988 * r_3->radiance / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            uint _S989 = extractBits_0(_S731, 19U, 1U);
            bool _S990 = nee_0 != (_S989 == 1U);
            if(_S990)
            {
                return _S730;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S945;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S991 = !scatter_2;
                if(_S991)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S992 = _S734 != 1U;
                    if(_S992)
                    {
                        refracted_4 = _S734 != 3U;
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
                bool _S993 = _S734 == 2U;
                if(_S993)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S905;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S735 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    uint _S994 = stream(_S757, b_4 + 448U);
                    FKRay _S995 = ray_2;
                    FKSurface _S996 = surface_11;
                    SkySample _S997 = sampleSky_0(&_S995, &_S996, _S914, _S910, is_inside_6, _S994, surface_11.random_state);
                    return Shift_x24init_0(throughput_5 * _S997.color, 1.0f);
                }
                if(_S993)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S905;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S998 = rgb_to_greyscale(light_2.radiance);
                    bool _S999 = !(_S998 > 0.0f);
                    if(_S999)
                    {
                        return _S730;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S744)
                {
                    passes_0 = _S735 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S876;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S744)
                {
                    passes_0 = _S735 == 1U;
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
                    passes_0 = !_S905;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S730;
            }
            else
            {
                bool _S1000 = !replay_1;
                if(_S1000)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1001 = b_4 > 0U;
                    if(_S1001)
                    {
                        Reservoir candidate_4 = chain_0;
                        if(_S935)
                        {
                            float3  _S1002 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_4)->radiance = _S1002;
                        }
                        else
                        {
                            if(_S905)
                            {
                                candidate_4 = here_0;
                            }
                        }
                        float3  _S1003 = throughput_5 * emission_1;
                        Reservoir _S1004 = withEnd(candidate_4, 1U, b_4, _S1003);
                        offer(sel_1, _S1004, _S1003 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1005 = throughput_5 * emission_1;
                        float3  _S1006 = sel_1->glow + _S1005;
                        sel_1->glow = _S1006;
                    }
                    if(nee_0)
                    {
                        float3  _S1007 = throughput_5 * lit_0;
                        Reservoir candidate_5 = chain_0;
                        if(_S935)
                        {
                            float3  _S1008 = safeDivide(_S1007, chain_throughput_0);
                            (&candidate_5)->radiance = _S1008;
                        }
                        else
                        {
                            if(_S905)
                            {
                                candidate_5 = here_0;
                                uint _S1009 = insertBits_0((&candidate_5)->path, 1U, 19U, 1U);
                                (&candidate_5)->path = _S1009;
                                (&candidate_5)->dir = light_2.dir;
                                (&candidate_5)->radiance = light_2.radiance;
                            }
                            else
                            {
                                uint _S1010 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S1011 = insertBits_0(_S1010, 2U, 10U, 2U);
                                (&candidate_5)->path = _S1011;
                            }
                        }
                        Reservoir _S1012 = withEnd(candidate_5, 0U, b_4, _S1007);
                        offer(sel_1, _S1012, _S1007 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S917)
                        {
                            _S981 = false;
                        }
                        else
                        {
                            bool _S1013 = environmentMapped_0();
                            _S981 = _S1013;
                        }
                    }
                    else
                    {
                        _S981 = false;
                    }
                    if(_S981)
                    {
                        uint _S1014 = (fcptMaxBounces());
                        _S982 = b_4 < _S1014;
                    }
                    else
                    {
                        _S982 = false;
                    }
                    if(_S982)
                    {
                        uint _S1015 = stream(_S757, b_4 + 448U);
                        FKRay _S1016 = ray_2;
                        FKSurface _S1017 = surface_11;
                        SkySample _S1018 = sampleSky_0(&_S1016, &_S1017, _S914, _S910, is_inside_6, _S1015, surface_11.random_state);
                        float3  _S1019 = throughput_5 * _S1018.color;
                        Reservoir candidate_6 = chain_0;
                        if(_S935)
                        {
                            float3  _S1020 = safeDivide(_S1019, chain_throughput_0);
                            (&candidate_6)->radiance = _S1020;
                        }
                        else
                        {
                            if(_S905)
                            {
                                candidate_6 = here_0;
                                uint _S1021 = insertBits_0((&candidate_6)->path, 1U, 19U, 1U);
                                (&candidate_6)->path = _S1021;
                                (&candidate_6)->dir = _S1018.dir;
                                (&candidate_6)->radiance = _S1018.radiance;
                            }
                            else
                            {
                                uint _S1022 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S1023 = insertBits_0(_S1022, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1023;
                            }
                        }
                        Reservoir _S1024 = withEnd(candidate_6, 4U, b_4, _S1019);
                        offer(sel_1, _S1024, _S1019 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1025;
        bool straight_0;
        bool _S1026;
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
        bool again_0;
        bool opaque_start_0;
        bool on_face_0;
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
                viewed_1 = _S945;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1040 = extractBits_0(_S731, 15U, 2U);
            uint _S1041 = extractBits_0(_S731, 17U, 2U);
            uint _S1042 = _slang_select(_S944, _S1041,_S1040);
            float3  _S1043 = r_3->dir;
            bool refracted_5 = _S1042 == 1U;
            SampleBSDF _S1044 = SampleBSDF_x24init_0(_S729, _S729, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_10 = _S1044;
            float3  reconnection_1;
            SampleBSDF _S1045;
            if(viewed_1)
            {
                uint _S1046 = extractBits_0(_S731, 20U, 1U);
                bool _S1047 = is_inside_6 != (_S1046 == 1U);
                if(_S1047)
                {
                    return _S730;
                }
                bool _S1048 = _S734 == 1U;
                if(_S1048)
                {
                    float3  _S1049 = (fcptHitPosition((_S746)));
                    throughput_8 = _S1049;
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
                    BSDFMaterial _S1050 = _S906.material;
                    bool _S1051 = isTranslucent_0(&_S1050);
                    if(_S1051)
                    {
                        refracted_4 = _S1042 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1052 = throughput_8 - (&ray_2)->origin;
                        float3  _S1053 = _slang_select(_S1048, _S1052,_S1043);
                        wrong_side_0 = (dot_0(_S907.smooth_n, _S1053) * _S908) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1048)
                {
                    float3  _S1054 = (&ray_2)->origin;
                    FKSurface _S1055 = surface_11;
                    float3  _S1056 = - _S907.smooth_n;
                    bool _S1057 = is_inside_6 != refracted_4;
                    float3  _S1058 = _slang_select(_S1057, _S1056,_S907.smooth_n);
                    float3  _S1059 = make_float3 (_S1055.geometry_offset) * _S1058;
                    bool _S1060 = (dot_0(throughput_8 - (&ray_2)->origin, _S914)) > 0.0f;
                    float _S1061 = _slang_select(_S1060, _S1055.geometry_offset,0.0f);
                    float3  _S1062 = _S921 * make_float3 (_S1061);
                    float3  _S1063 = _slang_select(_S919, _S1062,_S1059);
                    float3  _S1064 = throughput_8 - (_S1054 + _S1063);
                    float3  _S1065 = ((((_S1064)) * make_float3(rnorm3df(((_S1064)).x, ((_S1064)).y, ((_S1064)).z))));
                    reconnection_1 = _S1065;
                }
                else
                {
                    reconnection_1 = _S1043;
                }
                if(_S917)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1066 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, _S914);
                    wrong_side_0 = _S1066;
                }
                if(wrong_side_0)
                {
                    return _S730;
                }
                float3  _S1067 = throughput_8;
                throughput_8 = reconnection_1;
                b_7 = _S1042;
                wrong_side_0 = false;
                reconnection_1 = _S1067;
            }
            else
            {
                bool _S1068 = !_S944;
                if(_S1068)
                {
                    SampleBSDF bsdf_sampled_0;
                    if(_S917)
                    {
                        SampleBSDF _S1069 = (fcptSampleHair((_S915.hair), (_S906.material.albedo), (_S906.material.specular_tint), ((&ray_2)->unit_direction), (surface_11.random_state)));
                        _S1045 = _S1069;
                    }
                    else
                    {
                        SampleBSDF _S1070 = sampleBSDF((&ray_2)->unit_direction, _S907.smooth_n, _S906.material, _S910.x, _S910.y, surface_11.random_state, make_float2 (0.0f));
                        _S1045 = _S1070;
                    }
                    bsdf_sampled_0 = _S1045;
                    if(_S917)
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
                            return _S730;
                        }
                        break;
                    }
                    if(_S917)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1071 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, _S914);
                        wrong_side_0 = _S1071;
                    }
                    if(wrong_side_0)
                    {
                        _S981 = (_S906.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S981 = false;
                    }
                    if(_S981)
                    {
                        SampleBSDF _S1072 = sampleBSDF((&bsdf_sampled_0)->unit_direction, _S920.geometry_n, _S906.material, _S910.x, _S910.y, (&bsdf_sampled_0)->random_state, make_float2 (0.0f));
                        (&bsdf_sampled_0)->unit_direction = _S1072.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1072.refracted;
                        (&bsdf_sampled_0)->throughput = _S1072.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1073 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, _S920.geometry_n)) * _S920.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1073;
                        }
                    }
                    uint _S1074 = (&bsdf_sampled_0)->lobe;
                    float3  _S1075 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1076 = (&bsdf_sampled_0)->refracted;
                    lobe_10 = bsdf_sampled_0;
                    float _S1077 = (&bsdf_sampled_0)->pdf;
                    float _S1078 = _slang_select(wrong_side_0, 0.0f,_S1077);
                    (&lobe_10)->pdf = _S1078;
                    throughput_8 = _S1075;
                    b_7 = _S1074;
                    refracted_4 = _S1076;
                }
                else
                {
                    throughput_8 = _S1043;
                    b_7 = _S1042;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S981 = true;
            }
            else
            {
                _S981 = _S944;
            }
            if(_S981)
            {
                if(_S917)
                {
                    SampleBSDF _S1079 = (fcptConnectHair((_S915.hair), (_S906.material.albedo), (_S906.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    _S1045 = _S1079;
                }
                else
                {
                    SampleBSDF _S1080 = connectBSDF((&ray_2)->unit_direction, throughput_8, _S907.smooth_n, _S906.material, _S910.x, _S910.y, b_7, surface_11.random_state);
                    _S1045 = _S1080;
                }
                lobe_10 = _S1045;
            }
            if(_S917)
            {
                _S982 = false;
            }
            else
            {
                bool _S1081 = b_7 != 0U;
                if(_S1081)
                {
                    bool _S1082 = (_S906.material.roughness) == 0.0f;
                    if(_S1082)
                    {
                        _S982 = true;
                    }
                    else
                    {
                        bool _S1083 = b_7 == 1U;
                        if(_S1083)
                        {
                            _S982 = (_S910.x) == (_S910.y);
                        }
                        else
                        {
                            _S982 = false;
                        }
                    }
                }
                else
                {
                    _S982 = false;
                }
            }
            if(_S918)
            {
                _S1025 = b_7 == 1U;
            }
            else
            {
                _S1025 = false;
            }
            if(_S1025)
            {
                straight_0 = (_S906.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1026 = _S918;
            }
            else
            {
                _S1026 = false;
            }
            if(_S1026)
            {
                _S1027 = b_7 == 1U;
            }
            else
            {
                _S1027 = false;
            }
            if(_S1027)
            {
                _S1028 = (_S910.x) == (_S910.y);
            }
            else
            {
                _S1028 = false;
            }
            BSDFMaterial _S1084 = _S906.material;
            bool _S1085 = isTranslucent_0(&_S1084);
            if(_S1085)
            {
                _S1029 = b_7 == 0U;
            }
            else
            {
                _S1029 = false;
            }
            if(_S1029)
            {
                _S1030 = (dot_0(throughput_8, _S920.geometry_n)) < 0.0f;
            }
            else
            {
                _S1030 = false;
            }
            if(nee_0)
            {
                _S1031 = !_S982;
            }
            else
            {
                _S1031 = false;
            }
            if(_S1031)
            {
                _S1032 = !wrong_side_0;
            }
            else
            {
                _S1032 = false;
            }
            if(_S1032)
            {
                float _S1086 = (&lobe_10)->pdf;
                float3  _S1087 = (&ray_2)->origin;
                BSDFMaterial _S1088 = _S906.material;
                bool _S1089 = isTranslucent_0(&_S1088);
                if(_S1089)
                {
                    _S1033 = true;
                }
                else
                {
                    _S1033 = _S917;
                }
                float3  _S1090 = _slang_select(_S1033, _S729,_S907.smooth_n);
                float3  _S1091 = (&ray_2)->origin;
                FKSurface _S1092 = surface_11;
                float3  _S1093 = - _S907.smooth_n;
                float3  _S1094 = _slang_select(_S1030, _S1093,_S907.smooth_n);
                float3  _S1095 = make_float3 (_S1092.geometry_offset) * _S1094;
                bool _S1096 = (dot_0(throughput_8, _S914)) > 0.0f;
                float _S1097 = _slang_select(_S1096, _S1092.geometry_offset,0.0f);
                float3  _S1098 = _S921 * make_float3 (_S1097);
                float3  _S1099 = _slang_select(_S919, _S1098,_S1095);
                NEEVertex _S1100 = NEEVertex_x24init_0(false, _S1086, _S1087, _S1090, _S1091 + _S1099);
                nee_vertex_0 = _S1100;
            }
            else
            {
                if(_S917)
                {
                    _S1033 = true;
                }
                else
                {
                    bool _S1101 = b_7 != 1U;
                    if(_S1101)
                    {
                        _S1033 = true;
                    }
                    else
                    {
                        _S1033 = (_S910.x) != (_S910.y);
                    }
                }
                if(_S1033)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1102 = b_7 == 0U;
            bool _S1103 = withinInverseFootprint((&lobe_10)->pdf, _S1102, (&prev_0)->cos, (&hit_1)->distance, threshold_2);
            float _S1104 = dot_0(throughput_8, _S920.geometry_n);
            bool _S1105 = (dot_0(throughput_8, _S907.smooth_n) * _S1104) < 0.0f;
            bool _S1106 = !_S1105;
            if(_S1106)
            {
                bool _S1107 = roughLobe((&lobe_10)->pdf, _S1102, _S906.material.roughness);
                _S1033 = _S1107;
            }
            else
            {
                _S1033 = false;
            }
            if(_S944)
            {
                bool _S1108 = !_S1103;
                if(_S1108)
                {
                    return _S730;
                }
                bool _S1109 = _S735 != 1U;
                if(_S1109)
                {
                    _S1034 = _S735 != 2U;
                }
                else
                {
                    _S1034 = false;
                }
                if(_S1034)
                {
                    float _S1110 = (&lobe_10)->pdf;
                    float _S1111 = _slang_select(nee_0, _S1110,0.0f);
                    float _S1112 = escapeWeight_0(_S1111, _S1043);
                    if(_S952)
                    {
                        passes_0 = _S741;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1113 = _slang_select(passes_0, _S1112,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_10)->throughput * make_float3 ((&lobe_10)->pdf)) * r_3->radiance * make_float3 (_S1113) / make_float3 (r_3->jac), density_4 * (&lobe_10)->pdf / r_3->jac);
                }
                float3  _S1114 = throughput_6 * make_float3 ((&lobe_10)->pdf);
                float _S1115 = density_4 * (&lobe_10)->pdf;
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
                _S1034 = _S1118;
            }
            else
            {
                _S1034 = false;
            }
            if(_S1034)
            {
                return _S730;
            }
            if(replay_1)
            {
                _S1035 = b_4 <= _S745;
            }
            else
            {
                _S1035 = false;
            }
            if(_S1035)
            {
                _S1036 = _S905;
            }
            else
            {
                _S1036 = false;
            }
            if(_S1036)
            {
                _S1037 = _S1103;
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
                    _S1038 = !_S1033;
                }
                else
                {
                    _S1038 = false;
                }
            }
            if(_S1038)
            {
                return _S730;
            }
            if(viewed_1)
            {
                float3  _S1119 = throughput_9 * ((&lobe_10)->throughput * make_float3 ((&lobe_10)->pdf));
                float _S1120 = (&lobe_10)->pdf;
                throughput_10 = _S1119;
                sky_pdf_2 = _S1120;
            }
            else
            {
                float3  _S1121 = throughput_9 * max_0((&lobe_10)->throughput, _S729);
                throughput_10 = _S1121;
                sky_pdf_2 = density_6;
            }
            bool _S1122 = !replay_1;
            if(_S1122)
            {
                _S1039 = !_S935;
            }
            else
            {
                _S1039 = false;
            }
            bool _S1123;
            if(_S1039)
            {
                _S1123 = _S905;
            }
            else
            {
                _S1123 = false;
            }
            bool _S1124;
            if(_S1123)
            {
                _S1124 = _S1103;
            }
            else
            {
                _S1124 = false;
            }
            float3  chain_throughput_1;
            if(_S1124)
            {
                chain_0 = here_0;
                uint _S1125 = insertBits_0((&chain_0)->path, b_7, 17U, 2U);
                uint _S1126 = _slang_select(nee_0, 1U,0U);
                uint _S1127 = insertBits_0(_S1125, _S1126, 19U, 1U);
                (&chain_0)->path = _S1127;
                float _S1128 = (&chain_0)->jac * (&lobe_10)->pdf;
                (&chain_0)->jac = _S1128;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            Vertex _S1129 = Vertex_x24init_0(_S1033, b_7, (&lobe_10)->pdf, (F32_abs((dot_0(_S920.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1129;
            float _S1130 = (&lobe_10)->pdf;
            bool _S1131;
            if(_S1117)
            {
                _S1131 = (_S910.x) == (_S910.y);
            }
            else
            {
                _S1131 = false;
            }
            float sky_pdf_3 = _slang_select(_S1131, sky_pdf_0,_S1130);
            float _S1132 = _slang_select(_S917, 0.0f,sky_pdf_3);
            float _S1133 = widened_0(spread_1, (&lobe_10)->pdf, _S982);
            bool _S1134;
            if(refracted_4)
            {
                _S1134 = !_S1030;
            }
            else
            {
                _S1134 = false;
            }
            bool is_inside_7;
            if(_S1134)
            {
                bool _S1135 = !is_inside_6;
                is_inside_7 = _S1135;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            bool _S1136 = !_S1118;
            if(_S1136)
            {
                FKSurface faced_3 = surface_11;
                float3  _S1137 = - _S920.geometry_n;
                float3  _S1138 = _slang_select(turned_1, _S1137,_S920.geometry_n);
                (&faced_3)->geometry_n = _S1138;
                FKMedium _S1139 = Medium_x24init_0(scatter_in_0, extinction_in_0);
                FKSurface _S1140 = faced_3;
                FKMedium _S1141 = _S1139;
                MediumSides _S1142 = mediumSides_0(&_S1140, &_S1141, filling_2, (&ray_2)->unit_direction);
                bool _S1143 = leavesInFront_0((&faced_3)->geometry_n, throughput_8, _S914, _S920.geometry_n);
                float3  _S1144 = _slang_select(_S1143, _S1142.front.scatter,_S1142.behind.scatter);
                scatter_in_0 = _S1144;
                float3  _S1145 = _slang_select(_S1143, _S1142.front.extinction,_S1142.behind.extinction);
                extinction_in_0 = _S1145;
                uint _S1146 = _S1142.fillings.x;
                uint _S1147 = _S1142.fillings.y;
                uint _S1148 = _slang_select(_S1143, _S1147,_S1146);
                filling_2 = _S1148;
            }
            (&ray_2)->unit_direction = throughput_8;
            if(_S1136)
            {
                if(_S919)
                {
                    bool _S1149 = (dot_0(throughput_8, _S914)) > 0.0f;
                    if(_S1149)
                    {
                        again_0 = (surface_11.geometry_offset) > 0.0f;
                    }
                    else
                    {
                        again_0 = false;
                    }
                    FKSurface _S1150 = surface_11;
                    float _S1151 = _slang_select(again_0, _S1150.geometry_offset,0.0f);
                    float3  _S1152 = (&ray_2)->origin + _S921 * make_float3 (_S1151);
                    (&ray_2)->origin = _S1152;
                    bool _S1153 = !again_0;
                    BSDFMaterial _S1154 = _S906.material;
                    bool _S1155 = isTranslucent_0(&_S1154);
                    bool _S1156 = !_S1155;
                    if(_S1156)
                    {
                        opaque_start_0 = !((_S1150.geometry_offset) > 0.0f);
                    }
                    else
                    {
                        opaque_start_0 = false;
                    }
                    if(opaque_start_0)
                    {
                        on_face_0 = _S1104 < 0.0f;
                    }
                    else
                    {
                        on_face_0 = false;
                    }
                    again_0 = on_face_0;
                    opaque_start_0 = true;
                    on_face_0 = _S1153;
                }
                else
                {
                    if(_S917)
                    {
                    }
                    else
                    {
                        FKSurface _S1157 = surface_11;
                        float _S1158 = _slang_select(straight_0, 0.0f,_S1157.geometry_offset);
                        float3  _S1159 = - _S907.smooth_n;
                        bool _S1160 = is_inside_7 != _S1030;
                        float3  _S1161 = _slang_select(_S1160, _S1159,_S907.smooth_n);
                        float3  _S1162 = (&ray_2)->origin + make_float3 (_S1158) * _S1161;
                        (&ray_2)->origin = _S1162;
                    }
                    again_0 = false;
                    opaque_start_0 = _S917;
                    on_face_0 = _S917;
                }
            }
            else
            {
                again_0 = false;
                opaque_start_0 = false;
                on_face_0 = false;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1118;
            viewed_1 = _S1028;
            sky_pdf_2 = _S1132;
            spread_4 = _S1133;
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
            again_0 = false;
            opaque_start_0 = false;
            straight_0 = false;
            on_face_0 = false;
            is_inside_5 = is_inside_6;
        }
        bool _S1163 = !replay_1;
        float density_7;
        if(_S1163)
        {
            if(_S876)
            {
                float3  _S1164 = throughput_9 * emission_1;
                Reservoir candidate_7 = chain_0;
                uint _S1165 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1166 = _S1165 == 1U;
                if(_S1166)
                {
                    float3  _S1167 = safeDivide(_S1164, chain_throughput_0);
                    (&candidate_7)->radiance = _S1167;
                }
                Reservoir _S1168 = withEnd(candidate_7, 2U, b_4, _S1164);
                offer(sel_1, _S1168, _S1164 * make_float3 (scale_1) / make_float3 (density_6));
            }
            if(_S876)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1169 = survivalProbability(throughput_9, density_6);
                density_7 = _S1169;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1170 = stream(_S757, b_4 + 128U);
            Random _S1171 = pcg(_S1170);
            bool _S1172 = density_7 < (_S1171.value);
            if(_S1172)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1173 = (fcptMaxBounces());
                wrong_side_0 = b_4 >= _S1173;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1174 = density_6 * density_7;
            density_7 = _S1174;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1175 = layer_0 ^ 1U;
        uint _S1176 = _slang_select(passes_0, _S1175,0U);
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
            uint _S1177 = b_7 + 1U;
            b_4 = _S1177;
            layer_0 = _S1176;
            continue;
        }
        if(again_0)
        {
            b_7 = b_4;
            viewed_0 = viewed_1;
            throughput_2 = throughput_9;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_1 = spread_4;
            uint _S1177 = b_7 + 1U;
            b_4 = _S1177;
            layer_0 = _S1176;
            continue;
        }
        FKRay _S1178 = ray_2;
        float _S1179 = distance_5(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S945;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S734 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1180 = _slang_select(wrong_side_0, _S1179,4.294967296e+09f);
        bool _S1181 = !opaque_start_0;
        if(straight_0)
        {
            _S981 = true;
        }
        else
        {
            _S981 = on_face_0;
        }
        FKHit _S1182;
        if(_S981)
        {
            _S1182 = hit_1;
        }
        else
        {
            _S1182 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
        }
        FKHit _S1183 = (fcptTraverseInstanceBVH((_S1178), (_S881), (_S1180), (_S1181), (_S1182), (viewed_1)));
        hit_1 = _S1183;
        if(replay_1)
        {
            _S982 = _S945;
        }
        else
        {
            _S982 = false;
        }
        if(_S982)
        {
            _S1025 = _S734 == 1U;
        }
        else
        {
            _S1025 = false;
        }
        if(_S1025)
        {
            _S1026 = ((&hit_1)->instance_index) == (_S746.instance_index);
        }
        else
        {
            _S1026 = false;
        }
        if(_S1026)
        {
            _S1027 = ((&hit_1)->triangle_index) == (_S746.triangle_index);
        }
        else
        {
            _S1027 = false;
        }
        if(_S1027)
        {
            (&hit_1)->uv = _S746.uv;
            float _S1184 = distance_5(reconnection_0, (&ray_2)->origin);
            (&hit_1)->distance = _S1184;
        }
        if(replay_1)
        {
            _S1028 = _S945;
        }
        else
        {
            _S1028 = false;
        }
        if(_S1028)
        {
            _S1029 = _S734 == 3U;
        }
        else
        {
            _S1029 = false;
        }
        if(_S1029)
        {
            _S1030 = ((&hit_1)->instance_index) != 4294967295U;
        }
        else
        {
            _S1030 = false;
        }
        if(_S1030)
        {
            return _S730;
        }
        Reservoir _S1185 = chain_0;
        uint _S1186 = filling_2;
        for(;;)
        {
            bool _S1187 = _S1186 != 4294967295U;
            float _S1188;
            if(_S1187)
            {
                float _S1189 = (fcptMajorant((_S1186)));
                _S1188 = _S1189;
            }
            else
            {
                _S1188 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1031 = _S945;
            }
            else
            {
                _S1031 = false;
            }
            if(_S1031)
            {
                _S1032 = _S734 == 1U;
            }
            else
            {
                _S1032 = false;
            }
            if(_S1032)
            {
                _S1033 = _S1188 > 0.0f;
            }
            else
            {
                _S1033 = false;
            }
            if(_S1033)
            {
                ended_0 = _S730;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_3 = width_2;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_7 = b_4;
                _S1034 = true;
                break;
            }
            bool _S1190 = (&prev_0)->rough;
            if(_S1190)
            {
                _S1034 = !(_S1188 > 0.0f);
            }
            else
            {
                _S1034 = false;
            }
            (&prev_0)->rough = _S1034;
            uint _S1191 = b_4 + 320U;
            bool _S1192 = b_4 == 4294967295U;
            uint _S1193 = _slang_select(_S1192, 384U,_S1191);
            uint _S1194 = stream(_S757, _S1193);
            uint tracking_1 = _S1194;
            weight_1 = throughput_3;
            glowed_0 = _S729;
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
                    _S728 = int(2);
                    break;
                }
                uint _S1195 = b_7 + 320U;
                bool _S1196 = b_7 == 4294967295U;
                uint _S1197 = _slang_select(_S1196, 384U,_S1195);
                uint _S1198 = stream(_S757, _S1197);
                Random _S1199 = pcg(_S1198);
                float _S1200 = freeFlight_0(_S1199.value, _S1188);
                if(_S1187)
                {
                    float3  _S1201 = (&ray_2)->origin;
                    float3  _S1202 = (&ray_2)->unit_direction;
                    float _S1203 = (&hit_1)->distance;
                    uint _S1204 = _slang_select(_S1196, 0U,b_7);
                    uint _S1205 = (&prev_0)->lobe;
                    uint _S1206 = _slang_select(_S1196, 3U,_S1205);
                    float _S1207 = (fcptTrackMedium((_S1186), (_S1201), (_S1202), (_S1203), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S1204), (_S1206), (_S1196)));
                    spread_3 = _S1207;
                }
                else
                {
                    spread_3 = _S1200;
                }
                bool _S1208 = !(spread_3 < ((&hit_1)->distance));
                if(_S1208)
                {
                    _S728 = int(2);
                    break;
                }
                if(_S1187)
                {
                    _S1035 = _S1163;
                }
                else
                {
                    _S1035 = false;
                }
                if(_S1035)
                {
                    float3  _S1209 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1210 = sel_1->glow + _S1209;
                    sel_1->glow = _S1210;
                }
                else
                {
                }
                glowed_0 = _S729;
                uint b_8 = b_7 + 1U;
                float3  _S1211 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1211;
                float3  _S1212 = flightWeight_0(scatter_in_0, extinction_in_0, _S1188, spread_3, true);
                float3  _S1213 = weight_1;
                float3  _S1214 = _slang_select(_S1187, _S1213,_S1212);
                float3  throughput_11 = throughput_10 * _S1214;
                uint _S1215 = stream(_S757, b_8 + 320U);
                tracking_1 = _S1215;
                weight_1 = throughput_3;
                float width_6 = width_3 + spread_2 * spread_3;
                float _S1216 = spread_2 + 3.14159274101257324f;
                bool _S1217 = scatterSampled_0(replay_1, b_8, _S745, _S1187);
                TreeSample light_3;
                if(_S1217)
                {
                    float3  _S1218 = (&ray_2)->origin;
                    float3  _S1219 = (&ray_2)->unit_direction;
                    float3  _S1220 = (&ray_2)->unit_direction;
                    uint _S1221 = stream(_S757, b_8 + 64U);
                    float3  _S1222 = extinction_in_0;
                    float3  _S1223 = extinction_in_0;
                    uint2  _S1224 = make_uint2 (_S1186);
                    float3  _S1225 = (&ray_2)->unit_direction;
                    uint _S1226 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                    FKHit _S1227 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                    FKHit _S1228 = _S1227;
                    ShadowContext _S1229 = ShadowContext_x24init_0(_S1222, _S1223, _S1224, _S1225, b_8, _S1226, false, spread_3, width_6, false, _S729, &_S1228, false, true);
                    ShadowContext _S1230 = _S1229;
                    TreeSample _S1231 = sampleLightTree_0(_S1218, _S1219, _S1220, 0.0f, true, _S1221, &_S1230);
                    light_3 = _S1231;
                }
                else
                {
                    light_3 = _S956;
                }
                uint _S1232 = (fcptMaxBounces());
                bool _S1233 = b_8 < _S1232;
                if(_S1233)
                {
                    _S1036 = (light_3.density) > 0.0f;
                }
                else
                {
                    _S1036 = false;
                }
                float _S1234 = _slang_select(_S1036, 0.07957746833562851f,0.0f);
                float3  _S1235 = throughput_11 * light_3.radiance;
                float _S1236 = powerHeuristic(light_3.density, _S1234);
                float3  _S1237 = _S1235 * make_float3 (0.07957746833562851f * _S1236);
                float3  _S1238 = _slang_select(_S1217, _S1237,_S729);
                if(replay_1)
                {
                    _S1037 = b_8 == _S745;
                }
                else
                {
                    _S1037 = false;
                }
                if(_S1037)
                {
                    bool _S1239 = _S734 == 2U;
                    if(_S1239)
                    {
                        float _S1240 = rgb_to_greyscale(_S1238);
                        _S1038 = _S1240 > 0.0f;
                    }
                    else
                    {
                        _S1038 = false;
                    }
                    if(_S1038)
                    {
                        Shift _S1241 = Shift_x24init_0(_S1238, 1.0f);
                        _S728 = int(1);
                        ended_0 = _S1241;
                        spread_3 = _S1216;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_5 = b_8;
                        break;
                    }
                    _S728 = int(1);
                    ended_0 = _S730;
                    spread_3 = _S1216;
                    width_4 = width_6;
                    throughput_8 = throughput_11;
                    b_5 = b_8;
                    break;
                }
                if(_S1163)
                {
                    Reservoir candidate_8 = _S1185;
                    uint _S1242 = extractBits_0(_S1185.path, 10U, 2U);
                    bool _S1243 = _S1242 == 1U;
                    if(_S1243)
                    {
                        float3  _S1244 = safeDivide(_S1238, chain_throughput_0);
                        (&candidate_8)->radiance = _S1244;
                    }
                    else
                    {
                        uint _S1245 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                        uint _S1246 = insertBits_0(_S1245, 2U, 10U, 2U);
                        (&candidate_8)->path = _S1246;
                    }
                    Reservoir _S1247 = withEnd(candidate_8, 0U, b_8, _S1238);
                    offer(sel_1, _S1247, _S1238 * make_float3 (scale_1) / make_float3 (density_3));
                    float _S1248 = survivalProbability(throughput_11, density_3);
                    uint _S1249 = stream(_S757, b_8 + 128U);
                    Random _S1250 = pcg(_S1249);
                    bool _S1251 = _S1248 < (_S1250.value);
                    if(_S1251)
                    {
                        _S1038 = true;
                    }
                    else
                    {
                        uint _S1252 = (fcptMaxBounces());
                        _S1038 = b_8 >= _S1252;
                    }
                    if(_S1038)
                    {
                        _S728 = int(1);
                        ended_0 = _S730;
                        spread_3 = _S1216;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_5 = b_8;
                        break;
                    }
                    float _S1253 = density_3 * _S1248;
                    density_3 = _S1253;
                }
                else
                {
                }
                NEEVertex _S1254 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_2)->origin, _S729, (&ray_2)->origin);
                nee_vertex_0 = _S1254;
                uint _S1255 = stream(_S757, b_8);
                float3  _S1256 = isotropic_0(_S1255);
                (&ray_2)->unit_direction = _S1256;
                Vertex _S1257 = scatteredVertex_0(is_inside_5);
                prev_0 = _S1257;
                float _S1258 = (&prev_0)->pdf;
                FKRay _S1259 = ray_2;
                FKHit _S1260 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1261 = (fcptTraverseInstanceBVH((_S1259), (true), (4.294967296e+09f), (false), (_S1260), (false)));
                hit_1 = _S1261;
                b_7 = b_8;
                throughput_10 = throughput_11;
                spread_2 = _S1216;
                width_3 = width_6;
                sky_pdf_1 = _S1258;
            }
            if(_S728 != int(2))
            {
                spread_2 = spread_3;
                width_3 = width_4;
                throughput_10 = throughput_8;
                b_7 = b_5;
                _S1034 = true;
                break;
            }
            ended_0 = _S730;
            _S1034 = false;
            break;
        }
        if(_S1034)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1035 = b_7 == b_4;
        }
        else
        {
            _S1035 = false;
        }
        Reservoir _S1262 = chain_0;
        NEEVertex _S1263 = nee_vertex_0;
        Vertex _S1264 = prev_0;
        FKHit _S1265 = hit_1;
        uint _S1266 = filling_2;
        float3  _S1267 = scatter_in_0;
        float3  _S1268 = extinction_in_0;
        float3  _S1269 = weight_1;
        float3  _S1270 = glowed_0;
        for(;;)
        {
            bool _S1271 = (_S1265.instance_index) == 4294967295U;
            if(_S1271)
            {
                bool _S1272 = !_S1263.none;
                float _S1273 = _slang_select(_S1272, sky_pdf_1,0.0f);
                float _S1274 = escapeWeight_0(_S1273, (&ray_2)->unit_direction);
                float3  _S1275 = environment_0((&ray_2)->unit_direction, b_7, _S1264.lobe);
                float3  _S1276 = throughput_10 * _S1275;
                if(replay_1)
                {
                    bool _S1277 = b_7 == _S745;
                    if(_S1277)
                    {
                        _S1036 = _S734 == 3U;
                    }
                    else
                    {
                        _S1036 = false;
                    }
                    if(_S1036)
                    {
                        Shift _S1278 = Shift_x24init_0(_S1276 * make_float3 (_S1274) / make_float3 (r_3->jac), density_3 / r_3->jac);
                        arrived_end_0 = _S1278;
                        width_4 = width_3;
                        throughput_8 = throughput_10;
                        _S1036 = true;
                        break;
                    }
                    if(_S744)
                    {
                        _S1037 = _S741;
                    }
                    else
                    {
                        _S1037 = false;
                    }
                    if(_S1037)
                    {
                        _S1038 = b_7 == _S732;
                    }
                    else
                    {
                        _S1038 = false;
                    }
                    if(_S1038)
                    {
                        _S1039 = !_S1264.rough;
                    }
                    else
                    {
                        _S1039 = false;
                    }
                    if(_S1039)
                    {
                        Shift _S1279 = Shift_x24init_0(_S1276 * make_float3 (_S1274), 1.0f);
                        arrived_end_0 = _S1279;
                        width_4 = width_3;
                        throughput_8 = throughput_10;
                        _S1036 = true;
                        break;
                    }
                    arrived_end_0 = _S730;
                    width_4 = width_3;
                    throughput_8 = throughput_10;
                    _S1036 = true;
                    break;
                }
                Reservoir candidate_9 = _S1262;
                uint _S1280 = extractBits_0(_S1262.path, 10U, 2U);
                bool _S1281 = _S1280 == 1U;
                if(_S1281)
                {
                    uint _S1282 = extractBits_0(_S1262.path, 5U, 5U);
                    bool _S1283 = _S1282 == b_7;
                    float _S1284 = _slang_select(_S1283, 1.0f,_S1274);
                    float3  _S1285 = safeDivide(_S1276 * make_float3 (_S1284), chain_throughput_0);
                    (&candidate_9)->radiance = _S1285;
                }
                else
                {
                    if(_S1264.rough)
                    {
                        uint _S1286 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                        uint _S1287 = insertBits_0(_S1286, 3U, 10U, 2U);
                        uint _S1288 = insertBits_0(_S1287, _S1264.lobe, 15U, 2U);
                        uint _S1289 = _slang_select(_S1264.inside, 1U,0U);
                        uint _S1290 = insertBits_0(_S1288, _S1289, 20U, 1U);
                        (&candidate_9)->path = _S1290;
                        (&candidate_9)->jac = _S1264.pdf;
                        (&candidate_9)->dir = (&ray_2)->unit_direction;
                    }
                    else
                    {
                    }
                }
                float3  _S1291 = _S1276 * make_float3 (_S1274);
                Reservoir _S1292 = withEnd(candidate_9, 3U, b_7, _S1291);
                offer(sel_1, _S1292, _S1291 * make_float3 (scale_1) / make_float3 (density_3));
                arrived_end_0 = _S730;
                width_4 = width_3;
                throughput_8 = throughput_10;
                _S1036 = true;
                break;
            }
            float3  _S1293 = (&ray_2)->origin + make_float3 (_S1265.distance) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1293;
            bool _S1294 = _S1266 != 4294967295U;
            if(_S1294)
            {
                if(_S1163)
                {
                    float3  _S1295 = throughput_10 * _S1270 / make_float3 (density_3);
                    float3  _S1296 = sel_1->glow + _S1295;
                    sel_1->glow = _S1296;
                }
                else
                {
                }
                float3  _S1297 = throughput_10 * _S1269;
                throughput_8 = _S1297;
            }
            else
            {
                float3  _S1298 = flightWeight_0(_S1267, _S1268, (_S1267.x + _S1267.y + _S1267.z) / 3.0f, _S1265.distance, false);
                float3  _S1299 = throughput_10 * _S1298;
                throughput_8 = _S1299;
            }
            float _S1300 = width_3 + spread_2 * _S1265.distance;
            arrived_end_0 = _S730;
            width_4 = _S1300;
            _S1036 = false;
            break;
        }
        if(_S1036)
        {
            return arrived_end_0;
        }
        viewed_0 = _S1035;
        width_2 = width_4;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1177 = b_7 + 1U;
        b_4 = _S1177;
        layer_0 = _S1176;
    }
    return _S730;
}

static __device__ Shift shift_0(Domain * dom_1, Reservoir * r_4)
{
    Selection _S1301 = (Selection{});
    Selection sel_2 = _S1301;
    bool _S1302 = (r_4->w) <= 0.0f;
    if(_S1302)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1303 = walk_0(dom_1, r_4, true, 0.0f, &sel_2);
    return _S1303;
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
    Random _S1304 = pcg(state_3);
    Random _S1305 = pcg(_S1304.state);
    float _S1306 = 6.28318548202514648f * _S1304.value;
    float _S1307 = (F32_sqrt((-2.0f * clamp_0((F32_log((_S1305.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1305.state, _S1307 * (F32_cos((_S1306))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1308;
    (&_S1308)->state = state_4;
    (&_S1308)->value = value_2;
    return _S1308;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1309 = normal_distribution(state_5);
    Random _S1310 = normal_distribution(_S1309.state);
    Random _S1311 = normal_distribution(_S1310.state);
    float3  _S1312 = make_float3 (_S1309.value, _S1310.value, _S1311.value);
    float3  _S1313 = ((((_S1312)) * make_float3(rnorm3df(((_S1312)).x, ((_S1312)).y, ((_S1312)).z))));
    return RandomSphere_x24init_0(_S1311.state, _S1313);
}

struct RandomHemisphere
{
    uint state;
    float3  value;
};

static __device__ RandomHemisphere RandomHemisphere_x24init_0(uint state_6, float3  value_3)
{
    RandomHemisphere _S1314;
    (&_S1314)->state = state_6;
    (&_S1314)->value = value_3;
    return _S1314;
}

__device__ RandomHemisphere random_hemisphere(uint state_7, float3  normal_4)
{
    RandomSphere _S1315 = random_sphere(state_7);
    bool _S1316 = (dot_0(_S1315.value, normal_4)) > 0.0f;
    if(_S1316)
    {
        return RandomHemisphere_x24init_0(_S1315.state, _S1315.value);
    }
    else
    {
        float3  _S1317 = negate_0(_S1315.value);
        return RandomHemisphere_x24init_0(_S1315.state, _S1317);
    }
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_15)
{
    float3  _S1318 = p1_0 - p0_0;
    float3  _S1319 = p2_0 - p0_0;
    float2  _S1320 = uv1_0 - uv0_0;
    float2  _S1321 = uv2_0 - uv0_0;
    float _S1322 = _S1320.x;
    float _S1323 = _S1321.y;
    float _S1324 = _S1320.y;
    float _S1325 = _S1321.x;
    float _S1326 = _S1322 * _S1323 - _S1324 * _S1325;
    float _S1327 = 1.0f / _S1326;
    float3  t_1 = (_S1318 * make_float3 (_S1323) - _S1319 * make_float3 (_S1324)) * make_float3 (_S1327);
    float3  _S1328 = (_S1319 * make_float3 (_S1322) - _S1318 * make_float3 (_S1325)) * make_float3 (_S1327);
    float3  _S1329 = t_1 - n_15 * make_float3 (dot_0(n_15, t_1));
    float3  t_2 = ((((_S1329)) * make_float3(rnorm3df(((_S1329)).x, ((_S1329)).y, ((_S1329)).z))));
    bool _S1330 = (dot_0(cross_0(n_15, t_2), _S1328)) > 0.0f;
    float3  t_3;
    if(_S1330)
    {
        float3  _S1331 = negate_0(t_2);
        t_3 = _S1331;
    }
    else
    {
        t_3 = t_2;
    }
    float3  _S1332 = cross_0(n_15, t_3);
    return makeMatrix<float, 3, 3> (t_3, _S1332, n_15);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1333 = t1_0 - t0_0;
    float3  _S1334 = t2_2 - t0_0;
    float3  _S1335 = t2_2 - t1_0;
    float _S1336 = (F32_min((length_0(_S1333)), ((F32_min((length_0(_S1334)), (length_0(_S1335)))))));
    float3  _S1337 = make_float3 (distance_5(position_0, t0_0), distance_5(position_0, t1_0), distance_5(position_0, t2_2));
    float3  _S1338 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1339 = dot_0(geometry_n_5, _S1338);
    float3  _S1340 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1341 = dot_0(geometry_n_5, _S1340);
    float3  _S1342 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1343 = acos_0(abs_0(make_float3 (_S1339, _S1341, dot_0(geometry_n_5, _S1342))));
    float3  _S1344 = clamp_1(tan_0(_S1343), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_0(dot_0(_S1337 * _S1344, uvw_0), 0.0f, _S1336 * 0.125f);
}

__device__ float3  sampleHalfVector(float3  v_6, float3  n_i_5, float alpha_6, uint * random_state_15)
{
    float3  _S1345 = sampleMaterialHalfVector(v_6, n_i_5, alpha_6, AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f)), random_state_15);
    return _S1345;
}

__device__ float3  straightThrough(float3  dir_14, float3  n_16, BSDFMaterial material_16)
{
    float3  _S1346 = negate_0(dir_14);
    float _S1347 = sign_0(dot_0(n_16, _S1346));
    float3  _S1348 = n_16 * make_float3 (_S1347);
    AnisotropicFrame _S1349 = anisotropicFrame(material_16, _S1348);
    bool _S1350 = (_S1349.alphas.x) > 0.0f;
    if(_S1350)
    {
        float _S1351 = material_16.transmission * (1.0f - material_16.metallic);
        float3  _S1352 = negate_0(_S1348);
        float3  _S1353 = anisotropicLocal(dir_14, _S1349.tangent, _S1352);
        float _S1354 = anisotropicG1(_S1353, _S1349.alphas);
        return make_float3 (_S1351 * _S1354) * material_16.albedo;
    }
    float _S1355 = material_16.transmission * (1.0f - material_16.metallic);
    float _S1356 = material_16.roughness;
    float _S1357 = smithG1(_S1356 * _S1356, (F32_abs((dot_0(n_16, dir_14)))));
    return make_float3 (_S1355 * _S1357) * material_16.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_4, float3  out_dir_4, uint p_5, float w_2, float alpha_7, uint nt_0)
{
    uint _S1358 = p_5 % 4U;
    float _S1359 = w_2 * HAIR_WIDTHS_0[_S1358];
    float _S1360 = (F32_asin((clamp_0(dot_0(out_dir_4, t_4), -1.0f, 1.0f)))) - (F32_asin((clamp_0(dot_0(in_dir_11, t_4), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1358] * alpha_7;
    return ((F32_asinh((_S1360 / _S1359))) / (F32_asinh((3.14159274101257324f / _S1359))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_5, float3  out_dir_5, uint np_0)
{
    float3  _S1361 = worldToTangent(out_dir_5, t_5);
    float3  _S1362 = worldToTangent(in_dir_12, t_5);
    return (F32_frac((((F32_atan2((_S1361.z), (_S1361.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1362.z), (1.17549435082228751e-38f - _S1362.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_6, uint p_6, float row_0, float column_0, float w_3, float alpha_8, uint nt_1, uint np_1)
{
    float3  _S1363 = worldToTangent(in_dir_13, t_6);
    uint _S1364 = p_6 % 4U;
    float _S1365 = w_3 * HAIR_WIDTHS_0[_S1364];
    float _S1366 = (F32_asin((clamp_0(dot_0(in_dir_13, t_6), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1364] * alpha_8 + _S1365 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1365))))));
    float _S1367 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1363.z), (1.17549435082228751e-38f - _S1363.x)));
    float _S1368 = (F32_cos((_S1366)));
    float3  _S1369 = tangentToWorld(make_float3 (_S1368 * (F32_cos((_S1367))), (F32_sin((_S1366))), _S1368 * (F32_sin((_S1367)))), t_6);
    return _S1369;
}

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_5, float3  end_1)
{
    float _S1370 = sign_0(dot_0(light_n_0, start_5 - end_1));
    return light_n_0 * make_float3 (_S1370 * light_offset_0);
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_17, BSDFMaterial material_17, float coverage_1)
{
    float3  _S1371;
    if((material_17.ior) == 1.0f)
    {
        float3  _S1372 = straightThrough(toward_1, n_17, material_17);
        _S1371 = _S1372;
    }
    else
    {
        _S1371 = make_float3 (0.0f);
    }
    return _S1371 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_5, Shift shifted_0, float mis_0)
{
    Reservoir candidate_10 = r_5;
    float3  _S1373 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_10)->f = _S1373;
    float _S1374 = r_5.jac * shifted_0.jac;
    (&candidate_10)->jac = _S1374;
    offer(sel_3, candidate_10, make_float3 (mis_0) * shifted_0.f * make_float3 (r_5.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_6 = sel_4.r;
    float _S1375 = rgb_to_greyscale((&r_6)->f);
    float _S1376 = sel_4.w_sum / _S1375;
    bool _S1377 = _S1375 > 0.0f;
    float _S1378 = _slang_select(_S1377, _S1376,0.0f);
    (&r_6)->w = _S1378;
    (&r_6)->c = c_1;
    return r_6;
}

static __device__ float interpolate_0(float a_6, float b_9, float t_7)
{
    return a_6 + (b_9 - a_6) * t_7;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S1379 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S1379;
}

__device__ float2  temporalWeights(float c_2, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S1380 = c_2 * p_c_0;
    float _S1381 = c_t_0 * p_t_0;
    return make_float2 (_S1380 / (_S1380 + c_t_0 * g_previous_0), _S1381 / (_S1381 + c_2 * g_current_0));
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
    Domain _S1382 = dom_2;
    Reservoir _S1383 = r_7;
    Shift _S1384 = walk_0(&_S1382, &_S1383, replay_2, scale_2, sel_5);
    return _S1384;
}

__device__ Shift shift_hook(Domain dom_3, Reservoir r_8)
{
    Domain _S1385 = dom_3;
    Reservoir _S1386 = r_8;
    Shift _S1387 = shift_0(&_S1385, &_S1386);
    return _S1387;
}

#undef Matrix
