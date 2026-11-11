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

__device__ float childShare(LightNode first_0, LightNode second_0, float3  p_1, float3  normal_1, uint child_0)
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

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_2, float3  end_0)
{
    float _S497 = sign_0(dot_0(light_n_0, start_2 - end_0));
    return light_n_0 * make_float3 (_S497 * light_offset_0);
}

static __device__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_1)
{
    Random _S498 = pcg(init_random_state_1);
    Random _S499 = pcg(_S498.state);
    Random _S500 = pcg(_S499.state);
    float3  _S501 = make_float3 (0.0f);
    TreeSample _S502 = TreeSample_x24init_0(_S501, _S501, 0.0f, _S500.state);
    TreeSample sample_0 = _S502;
    float3  _S503 = _slang_select(sided_0, _S501,smooth_n_2);
    bool _S504 = context_1->opaque;
    float3  lift_n_0;
    if(_S504)
    {
        float3  _S505 = context_1->lift;
        lift_n_0 = _S505;
    }
    else
    {
        lift_n_0 = smooth_n_2;
    }
    float3  start_3 = origin_4 + make_float3 (geometry_offset_1) * lift_n_0;
    float pick_1 = _S498.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S506 = (fcptLightNode((n_8)));
        if((_S506.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S507 = (fcptLightSecond((n_8)));
        uint _S508 = n_8 + 1U;
        LightNode _S509 = (fcptLightBounds((_S508)));
        LightNode _S510 = (fcptLightBounds((_S507)));
        uint _S511 = pickChild(_S509, _S510, origin_4, _S503, &pick_1, &probability_4);
        bool _S512 = _S511 > 1U;
        if(_S512)
        {
            return sample_0;
        }
        bool _S513 = _S511 == 1U;
        uint _S514 = _slang_select(_S513, _S507,_S508);
        n_8 = _S514;
    }
    bool _S515 = n_8 == 0U;
    bool _S516;
    if(_S515)
    {
        LightNode _S517 = (fcptLightBounds((0U)));
        float _S518 = importance(_S517, origin_4, _S503);
        _S516 = !(_S518 > 0.0f);
    }
    else
    {
        _S516 = false;
    }
    if(_S516)
    {
        return sample_0;
    }
    uint4  _S519 = (fcptLightNode((n_8)));
    bool _S520 = (_S519.x) == 2U;
    float3  start_4;
    float3  shadow_1;
    if(_S520)
    {
        FKLight _S521 = (fcptLight((_S519.y)));
        if(sided_0)
        {
            _S516 = !_S504;
        }
        else
        {
            _S516 = false;
        }
        if(_S516)
        {
            float _S522 = sign_0(dot_0(geometry_n_1, _S521.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S522);
            float3  _S523 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            start_4 = _S523;
            lift_n_0 = lift_n_1;
        }
        else
        {
            start_4 = start_3;
        }
        bool _S524 = (_S521.variance) == 0.0f;
        if(_S524)
        {
            float3  _S525 = _S521.position - start_4;
            float3  _S526 = ((((_S525)) * make_float3(rnorm3df(((_S525)).x, ((_S525)).y, ((_S525)).z))));
            (&sample_0)->dir = _S526;
            float3  _S527 = _S521.color * make_float3 (_S521.intensity) / make_float3 (dot_0(_S525, _S525) * probability_4);
            (&sample_0)->radiance = _S527;
            shadow_1 = _S525;
        }
        else
        {
            float3  _S528 = sampleSphere(_S521.position, _S521.variance, start_4, _S499.value, _S500.value);
            (&sample_0)->dir = _S528;
            float _S529 = sphereDensity(_S521.position, _S521.variance, start_4);
            float _S530 = probability_4 * _S529;
            (&sample_0)->density = _S530;
            float3  _S531 = pointLightRadiance(_S521.color, _S521.intensity, _S521.variance);
            float3  _S532 = _S531 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S532;
            FKRay _S533 = Ray_x24init_0(start_4, (&sample_0)->dir);
            float _S534 = raySphere_0(_S521.position, _S521.variance, &_S533, 4.294967296e+09f);
            float3  _S535 = (&sample_0)->dir * make_float3 (_S534);
            shadow_1 = _S535;
        }
    }
    else
    {
        uint _S536 = _S519.y;
        uint _S537 = (fcptTriangleOffset((_S536)));
        uint _S538 = _S537 + _S519.z;
        Matrix<float, 3, 3>  _S539 = (fcptWorldTriangle((_S536), (_S538)));
        float _S540 = (F32_sqrt((_S499.value)));
        float2  _S541 = make_float2 (_S540 * (1.0f - _S500.value), _S540 * _S500.value);
        float3  _S542 = mul_0(make_float3 (1.0f - _S540, _S541.x, _S541.y), _S539);
        if(sided_0)
        {
            _S516 = !_S504;
        }
        else
        {
            _S516 = false;
        }
        if(_S516)
        {
            float _S543 = sign_0(dot_0(geometry_n_1, _S542 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S543);
            float3  _S544 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            start_4 = _S544;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S545 = !((dot_0(smooth_n_2, _S542 - start_3)) > 0.0f);
            if(_S545)
            {
                return sample_0;
            }
            start_4 = start_3;
        }
        FKHit _S546 = Hit_x24init_0(_S541, _S536, _S538, 0U, 0.0f);
        float3  _S547 = _S542 - start_4;
        float3  _S548 = ((((_S547)) * make_float3(rnorm3df(((_S547)).x, ((_S547)).y, ((_S547)).z))));
        FKSurface _S549 = (fcptLightSurfaceAt((_S546), (_S542), (_S500.state), (_S548), (context_1->depth), (length_0(_S542 - origin_4))));
        (&sample_0)->random_state = _S549.random_state;
        float3  _S550 = ((((_S547)) * make_float3(rnorm3df(((_S547)).x, ((_S547)).y, ((_S547)).z))));
        (&sample_0)->dir = _S550;
        float _S551 = solidAngle(probability_4, cross_0(_S539.rows[int(1)] - _S539.rows[int(0)], _S539.rows[int(2)] - _S539.rows[int(0)]), _S547);
        (&sample_0)->density = _S551;
        float3  _S552 = _slang_select(_S549.skip, _S501,_S549.material.emissive);
        float3  _S553 = _S552 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S553;
        float3  _S554 = shadowLift(_S549.smooth_n, _S549.geometry_offset, start_4, _S542);
        float3  _S555 = _S542 + _S554 - start_4;
        shadow_1 = _S555;
    }
    float3  _S556 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_1, _S500.state);
    float3  _S557 = (&sample_0)->radiance * _S556;
    bool _S558 = all_0(_S556 == _S501);
    float3  _S559 = _slang_select(_S558, _S501,_S557);
    (&sample_0)->radiance = _S559;
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
    float _S560 = 1.0f / (1.0f + b_0 / a_4 * (b_0 / a_4));
    bool _S561 = b_0 > 0.0f;
    float _S562 = _slang_select(_S561, _S560,1.0f);
    return _S562;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_0, float3  light_point_1)
{
    bool _S563 = vertex_0->none;
    if(_S563)
    {
        return 1.0f;
    }
    uint _S564 = (fcptLightSlot((*hit_0)));
    float _S565 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S564, light_point_1);
    float _S566 = powerHeuristic(vertex_0->pdf, _S565);
    return _S566;
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
    Shift _S567;
    (&_S567)->f = f_4;
    (&_S567)->jac = jac_0;
    return _S567;
}

static __device__ uint extractBits_0(uint e_1, uint offset_0, uint count_1)
{
    return (e_1 >> offset_0) & ((1U << count_1) - 1U);
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_5)
{
    NEEVertex _S568;
    (&_S568)->none = none_0;
    (&_S568)->pdf = pdf_4;
    (&_S568)->origin = origin_5;
    (&_S568)->smooth_n = smooth_n_3;
    (&_S568)->start = start_5;
    return _S568;
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
    Vertex _S569;
    (&_S569)->rough = rough_0;
    (&_S569)->lobe = lobe_7;
    (&_S569)->pdf = pdf_5;
    (&_S569)->cos = cos_0;
    (&_S569)->inside = inside_0;
    return _S569;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S570 = hash(index_0);
    uint _S571 = hash(seed_0 ^ _S570);
    return _S571;
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
    float3  _S572 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_1));
    float3  _S573 = scatter_0 * _S572 / make_float3 (sigma_1);
    float3  _S574 = _slang_select(scatters_0, _S573,_S572);
    return _S574;
}

static __device__ uint arrivalLobe_0(uint b_1, uint prev_lobe_0)
{
    bool _S575 = b_1 > 0U;
    uint _S576 = _slang_select(_S575, prev_lobe_0,3U);
    return _S576;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_8, bool surface_4, float length_2, float width_0, bool opaque_0, float3  lift_0, FKHit * own_0, bool fiber_0, bool faced_0)
{
    ShadowContext _S577;
    (&_S577)->extinction_behind = extinction_behind_0;
    (&_S577)->extinction_front = extinction_front_0;
    (&_S577)->fillings = fillings_0;
    (&_S577)->side = side_0;
    (&_S577)->depth = depth_1;
    (&_S577)->lobe = lobe_8;
    (&_S577)->surface = surface_4;
    (&_S577)->length = length_2;
    (&_S577)->width = width_0;
    (&_S577)->opaque = opaque_0;
    (&_S577)->lift = lift_0;
    (&_S577)->own = *own_0;
    (&_S577)->fiber = fiber_0;
    (&_S577)->faced = faced_0;
    return _S577;
}

static __device__ bool scatterSampled_0(bool replay_0, uint b_2, uint stop_0, bool varying_0)
{
    bool _S578 = !replay_0;
    bool _S579;
    if(_S578)
    {
        _S579 = true;
    }
    else
    {
        bool _S580 = b_2 == stop_0;
        if(_S580)
        {
            _S579 = !varying_0;
        }
        else
        {
            _S579 = false;
        }
    }
    return _S579;
}

__device__ float3  safeDivide(float3  a_5, float3  b_3)
{
    float3  _S581 = a_5 / b_3;
    float3  _S582 = make_float3 (0.0f);
    bool3  _S583 = b_3 == _S582;
    float3  _S584 = _slang_select(_S583, _S582,_S581);
    return _S584;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S585 = (1U << count_2) - 1U;
    return (e_2 & (~(_S585 << offset_1))) | ((newbits_0 & _S585) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_1, float3  f_5)
{
    Reservoir candidate_0 = r_2;
    uint _S586 = insertBits_0(r_2.path, end_1, 0U, 5U);
    uint _S587 = insertBits_0(_S586, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S587;
    (&candidate_0)->f = f_5;
    return candidate_0;
}

__device__ void offer(Selection * sel_0, Reservoir candidate_1, float3  weight_0)
{
    float _S588 = rgb_to_greyscale(weight_0);
    bool _S589 = _S588 > 0.0f;
    bool _S590;
    if(_S589)
    {
        _S590 = _S588 < 3.00000000549775576e+38f;
    }
    else
    {
        _S590 = false;
    }
    bool _S591 = !_S590;
    if(_S591)
    {
        return;
    }
    bool _S592 = sel_0->sums;
    if(_S592)
    {
        float3  _S593 = sel_0->color + weight_0;
        sel_0->color = _S593;
        return;
    }
    float _S594 = sel_0->w_sum + _S588;
    sel_0->w_sum = _S594;
    float3  _S595 = sel_0->color + weight_0;
    sel_0->color = _S595;
    Random _S596 = pcg(sel_0->random_state);
    sel_0->random_state = _S596.state;
    bool _S597 = (_S596.value * sel_0->w_sum) <= _S588;
    if(_S597)
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
    Random _S598 = pcg(random_state_8);
    Random _S599 = pcg(_S598.state);
    float _S600 = 1.0f - 2.0f * _S598.value;
    float _S601 = (F32_sqrt(((F32_max((1.0f - _S600 * _S600), (0.0f))))));
    float _S602 = 6.28318548202514648f * _S599.value;
    return make_float3 (_S601 * (F32_cos((_S602))), _S601 * (F32_sin((_S602))), _S600);
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

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1)
{
    FKMedium _S604;
    (&_S604)->scatter = scatter_1;
    (&_S604)->extinction = extinction_1;
    return _S604;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_7, bool skip_0, uint random_state_9, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S605;
    (&_S605)->smooth_n = smooth_n_4;
    (&_S605)->geometry_n = geometry_n_2;
    (&_S605)->geometry_offset = geometry_offset_2;
    (&_S605)->material = *material_7;
    (&_S605)->skip = skip_0;
    (&_S605)->random_state = random_state_9;
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
    BSDFMaterial material_8 = _S614;
    (&material_8)->albedo = _S613;
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

static __device__ bool arrivesBehind_0(float3  dir_9, float3  n_9)
{
    return (dot_0(dir_9, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_10)
{
    float3  _S618 = surface_7->geometry_n;
    float _S619 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_10);
    FKSurface faced_1 = *surface_7;
    float3  _S620 = surface_7->smooth_n * make_float3 (_S619);
    (&faced_1)->smooth_n = _S620;
    float3  _S621 = _S618 * make_float3 (_S619);
    (&faced_1)->geometry_n = _S621;
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

static __device__ float2  vertexEta_0(BSDFMaterial * material_9, float n_dot_v_0)
{
    bool _S624 = n_dot_v_0 < 0.0f;
    float _S625 = material_9->ior;
    float _S626 = _slang_select(_S624, _S625,1.0f);
    float _S627 = _slang_select(_S624, 1.0f,_S625);
    return make_float2 (_S626, _S627);
}

__device__ bool samplesLights(BSDFMaterial material_10)
{
    bool _S628 = (material_10.roughness) > 0.0f;
    bool _S629;
    if(_S628)
    {
        _S629 = true;
    }
    else
    {
        bool _S630 = (material_10.metallic) < 1.0f;
        if(_S630)
        {
            _S629 = (material_10.transmission) < 1.0f;
        }
        else
        {
            _S629 = false;
        }
    }
    return _S629;
}

__device__ float3  sideNormal(FKSurface surface_8, float3  in_dir_5)
{
    bool _S631 = !((surface_8.material.transmission) > 0.0f);
    bool _S632;
    if(_S631)
    {
        BSDFMaterial _S633 = surface_8.material;
        bool _S634 = isTranslucent_0(&_S633);
        _S632 = !_S634;
    }
    else
    {
        _S632 = false;
    }
    if(_S632)
    {
        _S632 = (dot_0(surface_8.smooth_n, - in_dir_5)) > 0.0f;
    }
    else
    {
        _S632 = false;
    }
    float3  _S635 = _slang_select(_S632, surface_8.smooth_n,surface_8.geometry_n);
    return _S635;
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
    MediumSides _S636;
    (&_S636)->behind = *behind_0;
    (&_S636)->front = *front_0;
    (&_S636)->fillings = fillings_1;
    (&_S636)->face = face_1;
    return _S636;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_11)
{
    float3  _S637 = surface_9->geometry_n;
    MediumSides _S638 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S638;
    bool _S639 = surface_9->encloses;
    if(_S639)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S640 = (dot_0(dir_11, _S637)) > 0.0f;
        if(_S640)
        {
            float3  _S641 = make_float3 (0.0f);
            FKMedium _S642 = Medium_x24init_0(_S641, _S641);
            (&sides_0)->front = _S642;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  side_n_3, float3  extinction_2, uint filling_1, float3  dir_12, uint depth_2, uint lobe_9, float length_3, float width_1, bool opaque_1, float3  lift_1, FKHit * own_1, bool fiber_1)
{
    FKSurface faced_2 = *surface_10;
    float3  _S643 = surface_10->geometry_n;
    float3  _S644 = - surface_10->geometry_n;
    float3  _S645 = _slang_select(turned_0, _S644,_S643);
    (&faced_2)->geometry_n = _S645;
    FKMedium _S646 = Medium_x24init_0(make_float3 (0.0f), extinction_2);
    FKSurface _S647 = faced_2;
    FKMedium _S648 = _S646;
    MediumSides _S649 = mediumSides_0(&_S647, &_S648, filling_1, dir_12);
    ShadowContext _S650 = ShadowContext_x24init_0(_S649.behind.extinction, _S649.front.extinction, _S649.fillings, side_n_3, depth_2, lobe_9, true, length_3, width_1, opaque_1, lift_1, own_1, fiber_1, true);
    ShadowContext context_2 = _S650;
    if(turned_0)
    {
        uint2  _S651 = _S649.fillings;
        ShadowContext _S652 = ShadowContext_x24init_0(_S649.front.extinction, _S649.behind.extinction, uint2 {_S651.y, _S651.x}, side_n_3, depth_2, lobe_9, true, length_3, width_1, opaque_1, lift_1, own_1, fiber_1, true);
        context_2 = _S652;
    }
    bool _S653 = isTranslucent_0(&surface_10->material);
    bool _S654 = !_S653;
    (&context_2)->faced = _S654;
    return context_2;
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_6, float3  out_dir_1, float3  n_10, float3  g_n_0, BSDFMaterial material_11, float eta_i_5, float eta_o_5, uint random_state_10)
{
    float3  _S655 = negate_0(in_dir_6);
    bool _S656 = (dot_0(g_n_0, _S655) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S656)
    {
        SampleBSDF _S657 = connectBSDF(in_dir_6, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 0U, random_state_10);
        SampleBSDF _S658 = connectBSDF(in_dir_6, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 2U, random_state_10);
        return _S657.throughput * make_float3 (_S657.pdf) + _S658.throughput * make_float3 (_S658.pdf);
    }
    SampleBSDF _S659 = connectBSDF(in_dir_6, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 1U, random_state_10);
    return _S659.throughput * make_float3 (_S659.pdf);
}

__device__ float3  translucentCorrection(float3  in_dir_7, float3  out_dir_2, float3  n_11, float3  g_n_1, BSDFMaterial material_12, float eta_i_6, float eta_o_6, uint random_state_11)
{
    float _S660 = dot_0(n_11, out_dir_2);
    float3  _S661 = negate_0(in_dir_7);
    bool _S662 = (_S660 * dot_0(n_11, _S661)) < 0.0f;
    SampleBSDF _S663 = connectBSDF(in_dir_7, out_dir_2, n_11, material_12, eta_i_6, eta_o_6, 0U, random_state_11);
    float3  _S664 = negate_0(in_dir_7);
    bool _S665 = (dot_0(g_n_1, _S664) * dot_0(g_n_1, out_dir_2)) > 0.0f;
    float3  _S666 = make_float3 (0.0f);
    float3  _S667 = _S663.throughput * make_float3 (_S663.pdf);
    float _S668 = _slang_select(_S665, -1.0f,1.0f);
    float3  _S669 = _S667 * make_float3 (_S668);
    float3  _S670 = _slang_select(_S662, _S669,_S666);
    return _S670;
}

__device__ float3  translucentBSDF(float3  in_dir_8, float3  out_dir_3, float3  n_12, float3  g_n_2, BSDFMaterial material_13, float eta_i_7, float eta_o_7, uint random_state_12)
{
    float3  _S671 = BSDF(in_dir_8, out_dir_3, n_12, g_n_2, material_13, eta_i_7, eta_o_7, random_state_12);
    float3  _S672 = translucentCorrection(in_dir_8, out_dir_3, n_12, g_n_2, material_13, eta_i_7, eta_o_7, random_state_12);
    return _S671 + _S672;
}

static __device__ float3  lightBSDF_0(float3  in_dir_9, TreeSample * light_1, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_14, float eta_i_8, float eta_o_8, bool competing_1, uint random_state_13)
{
    bool _S673 = !competing_1;
    bool _S674;
    if(_S673)
    {
        _S674 = true;
    }
    else
    {
        _S674 = (light_1->density) == 0.0f;
    }
    if(_S674)
    {
        bool _S675 = isTranslucent_0(material_14);
        if(_S675)
        {
            float3  _S676 = translucentBSDF(in_dir_9, light_1->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_8, eta_o_8, random_state_13);
            return _S676 * light_1->radiance;
        }
        float3  _S677 = BSDF(in_dir_9, light_1->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_8, eta_o_8, random_state_13);
        return _S677 * light_1->radiance;
    }
    float3  _S678 = light_1->dir;
    bool _S679 = (dot_0(geometry_n_4, - in_dir_9) * dot_0(geometry_n_4, light_1->dir)) <= 0.0f;
    float3  _S680 = neeBSDF(in_dir_9, _S678, smooth_n_5, *material_14, eta_i_8, eta_o_8, _S679, light_1->density, true, random_state_13);
    return _S680 * light_1->radiance * make_float3 (light_1->density);
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S681 = (F32_sqrt((random_1_0)));
    float _S682 = 6.28318548202514648f * random_2_0;
    float _S683 = _S681 * (F32_cos((_S682)));
    float _S684 = _S681 * (F32_sin((_S682)));
    float _S685 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S683 * _S683 - _S684 * _S684))))));
    return make_float3 (_S683, _S685, _S684);
}

static __device__ float3  reflect_0(float3  i_8, float3  n_13)
{
    return i_8 - make_float3 (2.0f * dot_0(n_13, i_8)) * n_13;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_14, BSDFMaterial material_15, float eta_i_9, float eta_o_9, uint random_init_1, float2  screen_space_0)
{
    uint random_state_14 = random_init_1;
    float3  _S686 = negate_0(in_dir_10);
    float _S687 = dot_0(n_14, _S686);
    float _S688 = sign_0(_S687);
    float3  n_i_4 = n_14 * make_float3 (_S688);
    float _S689 = (F32_abs((_S687)));
    float _S690 = material_15.roughness;
    float _S691 = _S690 * _S690;
    AnisotropicFrame _S692 = anisotropicFrame(material_15, n_i_4);
    float3  _S693 = sampleMaterialHalfVector(_S686, n_i_4, _S691, _S692, &random_state_14);
    BSDFLobes _S694 = bsdfLobes(in_dir_10, _S686, n_i_4, _S693, material_15, eta_i_9, eta_o_9, _S692);
    BSDFLobes lobes_3 = _S694;
    float _S695 = translucentShare(material_15);
    (&lobes_3)->translucent_share = _S695;
    float3  _S696 = make_float3 (1.0f);
    SampleBSDF _S697 = SampleBSDF_x24init_0(_S696, _S696, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S697;
    Random _S698 = pcg(random_state_14);
    random_state_14 = _S698.state;
    bool _S699 = (_S698.value) < ((&lobes_3)->p_diffuse);
    if(_S699)
    {
        Random _S700 = pcg(random_state_14);
        Random _S701 = pcg(_S700.state);
        (&sample_1)->random_state = _S701.state;
        float3  _S702 = sampleCosWeightedHemisphere(_S700.value, _S701.value);
        bool _S703 = (_S698.value) < ((&lobes_3)->p_diffuse * (&lobes_3)->translucent_share);
        float _S704 = _S702.y;
        float _S705 = - _S704;
        float _S706 = _slang_select(_S703, _S705,_S704);
        float3  _S707 = tangentToWorld(make_float3 (_S702.x, _S706, _S702.z), n_i_4);
        (&sample_1)->unit_direction = _S707;
        float3  _S708 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S691, material_15, lobes_3, 0U);
        (&sample_1)->throughput = _S708;
        float _S709 = lobeDensity(_S706, 0.0f, _S689, _S691, lobes_3, eta_i_9, eta_o_9, 0U);
        (&sample_1)->pdf = _S709;
        (&sample_1)->refracted = _S703;
        return sample_1;
    }
    bool _S710 = (_S698.value) < ((&lobes_3)->p_diffuse + (&lobes_3)->p_refract);
    if(_S710)
    {
        (&sample_1)->unit_direction = (&lobes_3)->refracted;
        float _S711 = lobeDensity(0.0f, dot_0((&sample_1)->unit_direction, _S693), _S689, _S691, lobes_3, eta_i_9, eta_o_9, 1U);
        (&sample_1)->pdf = _S711;
        float3  _S712 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S691, material_15, lobes_3, 1U);
        (&sample_1)->throughput = _S712;
        (&sample_1)->random_state = random_state_14;
        (&sample_1)->refracted = true;
        (&sample_1)->lobe = 1U;
        return sample_1;
    }
    float3  _S713 = reflect_0(in_dir_10, _S693);
    float3  _S714 = ((((_S713)) * make_float3(rnorm3df(((_S713)).x, ((_S713)).y, ((_S713)).z))));
    (&sample_1)->unit_direction = _S714;
    float3  _S715 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S691, material_15, lobes_3, 2U);
    (&sample_1)->throughput = _S715;
    (&sample_1)->random_state = random_state_14;
    (&sample_1)->lobe = 2U;
    float _S716 = lobeDensity(0.0f, 0.0f, _S689, _S691, lobes_3, eta_i_9, eta_o_9, 2U);
    (&sample_1)->pdf = _S716;
    return sample_1;
}

__device__ bool withinInverseFootprint(float pdf_6, bool diffuse_0, float prev_cos_0, float distance_4, float threshold_1)
{
    bool _S717 = pdf_6 > 0.0f;
    bool _S718;
    if(_S717)
    {
        if(diffuse_0)
        {
            _S718 = true;
        }
        else
        {
            _S718 = (pdf_6 * prev_cos_0 / (distance_4 * distance_4) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S718 = false;
    }
    return _S718;
}

__device__ bool roughLobe(float pdf_7, bool diffuse_1, float roughness_1)
{
    bool _S719 = pdf_7 > 0.0f;
    bool _S720;
    if(_S719)
    {
        if(diffuse_1)
        {
            _S720 = true;
        }
        else
        {
            _S720 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S720 = false;
    }
    return _S720;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S721 = layers_0 > 1U;
    bool _S722;
    if(_S721)
    {
        _S722 = refracting_0 != passed_0;
    }
    else
    {
        _S722 = false;
    }
    return _S722;
}

static __device__ float widened_0(float spread_0, float pdf_8, bool delta_0)
{
    float _S723 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_8))))), (3.14159274101257324f)));
    bool _S724 = !delta_0;
    float _S725 = _slang_select(_S724, _S723,0.0f);
    return spread_0 + _S725;
}

static __device__ bool leavesInFront_0(float3  face_2, float3  dir_13, float3  side_n_4, float3  g_0)
{
    return ((dot_0(dir_13, side_n_4)) > 0.0f) == ((dot_0(g_0, face_2)) > 0.0f);
}

static __device__ float distance_5(float3  x_14, float3  y_5)
{
    return length_0(x_14 - y_5);
}

static __device__ Shift walk_0(Domain * dom_0, Reservoir * r_3, bool replay_1, float scale_1, Selection * sel_1)
{
    bool turned_1;
    bool is_inside_5;
    bool viewed_0;
    uint b_4;
    uint layer_0;
    float3  throughput_2;
    float3  chain_throughput_0;
    float density_2;
    float spread_1;
    float width_2;
    float sky_pdf_0;
    float threshold_2;
    float geometry_density_2;
    int _S726;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_3;
    float sky_pdf_1;
    float width_4;
    uint b_5;
    float spread_3;
    Shift arrived_end_0;
    float3  _S727 = make_float3 (0.0f);
    Shift _S728 = Shift_x24init_0(_S727, 0.0f);
    uint _S729 = r_3->path;
    uint _S730 = extractBits_0(r_3->path, 0U, 5U);
    uint _S731 = extractBits_0(_S729, 5U, 5U);
    uint _S732 = extractBits_0(_S729, 10U, 2U);
    uint _S733 = extractBits_0(_S729, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S734 = _S733 >= 3U;
        uint _S735 = _slang_select(_S734, 1U,0U);
        uint _S736 = _S730 + _S735;
        uint _S737 = (fcptMaxBounces());
        passes_0 = _S736 > _S737;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S728;
    }
    uint _S738 = _S731 - 1U;
    bool _S739 = _S733 == 3U;
    uint _S740 = _slang_select(_S739, 1U,0U);
    uint _S741 = _S730 + _S740;
    bool _S742 = _S732 == 0U;
    uint _S743 = _slang_select(_S742, _S741,_S738);
    FKHit _S744 = (fcptReservoirHit((*r_3)));
    float3  _S745 = dom_0->x0;
    float3  _S746 = dom_0->x1 - dom_0->x0;
    float3  _S747 = ((((_S746)) * make_float3(rnorm3df(((_S746)).x, ((_S746)).y, ((_S746)).z))));
    FKRay _S748 = Ray_x24init_0(dom_0->x1, _S747);
    FKRay ray_2 = _S748;
    FKHit hit_1 = dom_0->hit;
    float3  scatter_in_0 = _S727;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S727;
    float3  extinction_in_0 = _S727;
    uint filling_2 = 4294967295U;
    float _S749 = dom_0->spread;
    float _S750 = dom_0->width;
    float _S751 = length_0(_S746);
    NEEVertex _S752 = NEEVertex_x24init_0(true, 0.0f, _S727, _S727, _S727);
    NEEVertex nee_vertex_0 = _S752;
    Vertex _S753 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S753;
    Reservoir _S754 = (Reservoir{});
    Reservoir chain_0 = _S754;
    uint _S755 = r_3->seed;
    (&chain_0)->seed = r_3->seed;
    (&ray_2)->origin = _S745;
    (&hit_1)->distance = _S751;
    FKMedium _S756 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_1)->distance), (&filling_2)));
    scatter_in_0 = _S756.scatter;
    extinction_in_0 = _S756.extinction;
    Reservoir _S757 = chain_0;
    uint _S758 = filling_2;
    for(;;)
    {
        bool _S759 = _S758 != 4294967295U;
        float _S760 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        float _S761 = (fcptMajorant((_S758)));
        float _S762 = _slang_select(_S759, _S761,_S760);
        if(replay_1)
        {
            passes_0 = 4294967295U == _S743;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            passes_0 = _S732 == 1U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            passes_0 = _S762 > 0.0f;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            ended_0 = _S728;
            sky_pdf_0 = 0.0f;
            spread_1 = _S749;
            width_2 = _S750;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_4 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S763 = (&prev_0)->rough;
        if(_S763)
        {
            passes_0 = !(_S762 > 0.0f);
        }
        else
        {
            passes_0 = false;
        }
        (&prev_0)->rough = passes_0;
        uint _S764 = stream(_S755, 384U);
        uint tracking_0 = _S764;
        weight_1 = throughput_3;
        glowed_0 = _S727;
        b_4 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        spread_1 = _S749;
        width_2 = _S750;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_1)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S726 = int(1);
                break;
            }
            uint _S765 = b_4 + 320U;
            bool _S766 = b_4 == 4294967295U;
            uint _S767 = _slang_select(_S766, 384U,_S765);
            uint _S768 = stream(_S755, _S767);
            Random _S769 = pcg(_S768);
            float _S770 = freeFlight_0(_S769.value, _S762);
            if(_S759)
            {
                float3  _S771 = (&ray_2)->origin;
                float3  _S772 = (&ray_2)->unit_direction;
                float _S773 = (&hit_1)->distance;
                uint _S774 = _slang_select(_S766, 0U,b_4);
                uint _S775 = (&prev_0)->lobe;
                uint _S776 = _slang_select(_S766, 3U,_S775);
                float _S777 = (fcptTrackMedium((_S758), (_S771), (_S772), (_S773), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S774), (_S776), (_S766)));
                threshold_2 = _S777;
            }
            else
            {
                threshold_2 = _S770;
            }
            bool _S778 = !(threshold_2 < ((&hit_1)->distance));
            if(_S778)
            {
                _S726 = int(1);
                break;
            }
            if(_S759)
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
            glowed_0 = _S727;
            uint b_6 = b_4 + 1U;
            float3  _S781 = (&ray_2)->origin + make_float3 (threshold_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S781;
            float3  _S782 = flightWeight_0(scatter_in_0, extinction_in_0, _S762, threshold_2, true);
            float3  _S783 = weight_1;
            float3  _S784 = _slang_select(_S759, _S783,_S782);
            float3  throughput_4 = throughput_2 * _S784;
            uint _S785 = stream(_S755, b_6 + 320U);
            tracking_0 = _S785;
            weight_1 = throughput_3;
            float width_5 = width_2 + spread_1 * threshold_2;
            float _S786 = spread_1 + 3.14159274101257324f;
            float3  _S787 = (&ray_2)->origin;
            float3  _S788 = (&ray_2)->unit_direction;
            float3  _S789 = (&ray_2)->unit_direction;
            uint _S790 = stream(_S755, b_6 + 64U);
            float3  _S791 = extinction_in_0;
            float3  _S792 = extinction_in_0;
            uint2  _S793 = make_uint2 (_S758);
            float3  _S794 = (&ray_2)->unit_direction;
            uint _S795 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKHit _S796 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S797 = _S796;
            ShadowContext _S798 = ShadowContext_x24init_0(_S791, _S792, _S793, _S794, b_6, _S795, false, threshold_2, width_5, false, _S727, &_S797, false, true);
            ShadowContext _S799 = _S798;
            TreeSample _S800 = sampleLightTree_0(_S787, _S788, _S789, 0.0f, true, _S790, &_S799);
            bool _S801 = scatterSampled_0(replay_1, b_6, _S743, _S759);
            uint _S802 = (fcptMaxBounces());
            bool _S803 = b_6 < _S802;
            if(_S803)
            {
                turned_1 = (_S800.density) > 0.0f;
            }
            else
            {
                turned_1 = false;
            }
            float _S804 = _slang_select(turned_1, 0.07957746833562851f,0.0f);
            float3  _S805 = throughput_4 * _S800.radiance;
            float _S806 = powerHeuristic(_S800.density, _S804);
            float3  _S807 = _S805 * make_float3 (0.07957746833562851f * _S806);
            float3  _S808 = _slang_select(_S801, _S807,_S727);
            if(replay_1)
            {
                is_inside_5 = b_6 == _S743;
            }
            else
            {
                is_inside_5 = false;
            }
            if(is_inside_5)
            {
                bool _S809 = _S732 == 2U;
                if(_S809)
                {
                    float _S810 = rgb_to_greyscale(_S808);
                    passes_0 = _S810 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S811 = Shift_x24init_0(_S808, 1.0f);
                    _S726 = int(0);
                    ended_0 = _S811;
                    threshold_2 = _S786;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                _S726 = int(0);
                ended_0 = _S728;
                threshold_2 = _S786;
                geometry_density_2 = width_5;
                chain_throughput_0 = throughput_4;
                layer_0 = b_6;
                break;
            }
            bool _S812 = !replay_1;
            if(_S812)
            {
                Reservoir candidate_2 = _S757;
                uint _S813 = extractBits_0(_S757.path, 10U, 2U);
                bool _S814 = _S813 == 1U;
                if(_S814)
                {
                    float3  _S815 = safeDivide(_S808, _S727);
                    (&candidate_2)->radiance = _S815;
                }
                else
                {
                    uint _S816 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                    uint _S817 = insertBits_0(_S816, 2U, 10U, 2U);
                    (&candidate_2)->path = _S817;
                }
                Reservoir _S818 = withEnd(candidate_2, 0U, b_6, _S808);
                offer(sel_1, _S818, _S808 * make_float3 (scale_1) / make_float3 (density_2));
                float _S819 = survivalProbability(throughput_4, density_2);
                uint _S820 = stream(_S755, b_6 + 128U);
                Random _S821 = pcg(_S820);
                bool _S822 = _S819 < (_S821.value);
                if(_S822)
                {
                    viewed_0 = true;
                }
                else
                {
                    uint _S823 = (fcptMaxBounces());
                    viewed_0 = b_6 >= _S823;
                }
                if(viewed_0)
                {
                    _S726 = int(0);
                    ended_0 = _S728;
                    threshold_2 = _S786;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                float _S824 = density_2 * _S819;
                density_2 = _S824;
            }
            else
            {
            }
            NEEVertex _S825 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_2)->origin, _S727, (&ray_2)->origin);
            nee_vertex_0 = _S825;
            uint _S826 = stream(_S755, b_6);
            float3  _S827 = isotropic_0(_S826);
            (&ray_2)->unit_direction = _S827;
            Vertex _S828 = scatteredVertex_0(false);
            prev_0 = _S828;
            float _S829 = (&prev_0)->pdf;
            FKRay _S830 = ray_2;
            FKHit _S831 = (fcptTraverseInstanceBVH((_S830), (true), (4.294967296e+09f), (false), (_S796), (false)));
            hit_1 = _S831;
            b_4 = b_6;
            throughput_2 = throughput_4;
            spread_1 = _S786;
            width_2 = width_5;
            sky_pdf_0 = _S829;
        }
        if(_S726 != int(1))
        {
            spread_1 = threshold_2;
            width_2 = geometry_density_2;
            throughput_2 = chain_throughput_0;
            b_4 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S728;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S832 = b_4 == 4294967295U;
    Reservoir _S833 = chain_0;
    NEEVertex _S834 = nee_vertex_0;
    Vertex _S835 = prev_0;
    FKHit _S836 = hit_1;
    uint _S837 = filling_2;
    float3  _S838 = scatter_in_0;
    float3  _S839 = extinction_in_0;
    float3  _S840 = weight_1;
    float3  _S841 = glowed_0;
    for(;;)
    {
        bool _S842 = (_S836.instance_index) == 4294967295U;
        if(_S842)
        {
            bool _S843 = !_S834.none;
            float _S844 = _slang_select(_S843, sky_pdf_0,0.0f);
            float _S845 = escapeWeight_0(_S844, (&ray_2)->unit_direction);
            float3  _S846 = environment_0((&ray_2)->unit_direction, b_4, _S835.lobe);
            float3  _S847 = throughput_2 * _S846;
            if(replay_1)
            {
                bool _S848 = b_4 == _S743;
                if(_S848)
                {
                    passes_0 = _S732 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S849 = Shift_x24init_0(_S847 * make_float3 (_S845) / make_float3 (r_3->jac), density_2 / r_3->jac);
                    ended_0 = _S849;
                    passes_0 = true;
                    break;
                }
                if(_S742)
                {
                    passes_0 = _S739;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_4 == _S730;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S835.rough;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S850 = Shift_x24init_0(_S847 * make_float3 (_S845), 1.0f);
                    ended_0 = _S850;
                    passes_0 = true;
                    break;
                }
                ended_0 = _S728;
                passes_0 = true;
                break;
            }
            Reservoir candidate_3 = _S833;
            uint _S851 = extractBits_0(_S833.path, 10U, 2U);
            bool _S852 = _S851 == 1U;
            if(_S852)
            {
                uint _S853 = extractBits_0(_S833.path, 5U, 5U);
                bool _S854 = _S853 == b_4;
                float _S855 = _slang_select(_S854, 1.0f,_S845);
                float3  _S856 = safeDivide(_S847 * make_float3 (_S855), _S727);
                (&candidate_3)->radiance = _S856;
            }
            else
            {
                if(_S835.rough)
                {
                    uint _S857 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                    uint _S858 = insertBits_0(_S857, 3U, 10U, 2U);
                    uint _S859 = insertBits_0(_S858, _S835.lobe, 15U, 2U);
                    uint _S860 = _slang_select(_S835.inside, 1U,0U);
                    uint _S861 = insertBits_0(_S859, _S860, 20U, 1U);
                    (&candidate_3)->path = _S861;
                    (&candidate_3)->jac = _S835.pdf;
                    (&candidate_3)->dir = (&ray_2)->unit_direction;
                }
                else
                {
                }
            }
            float3  _S862 = _S847 * make_float3 (_S845);
            Reservoir _S863 = withEnd(candidate_3, 3U, b_4, _S862);
            offer(sel_1, _S863, _S862 * make_float3 (scale_1) / make_float3 (density_2));
            ended_0 = _S728;
            passes_0 = true;
            break;
        }
        float3  _S864 = (&ray_2)->origin + make_float3 (_S836.distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S864;
        bool _S865 = _S837 != 4294967295U;
        if(_S865)
        {
            bool _S866 = !replay_1;
            if(_S866)
            {
                float3  _S867 = throughput_2 * _S841 / make_float3 (density_2);
                float3  _S868 = sel_1->glow + _S867;
                sel_1->glow = _S868;
            }
            else
            {
            }
            float3  _S869 = throughput_2 * _S840;
            throughput_2 = _S869;
        }
        else
        {
            float3  _S870 = flightWeight_0(_S838, _S839, (_S838.x + _S838.y + _S838.z) / 3.0f, _S836.distance, false);
            float3  _S871 = throughput_2 * _S870;
            throughput_2 = _S871;
        }
        float _S872 = width_2 + spread_1 * _S836.distance;
        ended_0 = _S728;
        width_2 = _S872;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    uint _S873 = b_4 + 1U;
    b_4 = _S873;
    layer_0 = 0U;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S727;
    float3  reconnection_0 = _S727;
    viewed_0 = _S832;
    for(;;)
    {
        bool _S874 = ((&hit_1)->is_point_light) == 1U;
        FKMedium _S875 = Medium_x24init_0(_S727, _S727);
        BSDFMaterial _S876 = Material_x24init_0(_S727, _S727, 0.0f, 0.0f, 0.0f, 0.0f, _S727, throughput_3, 1.0f, _S727, _S727, 0.5f, 0.0f, 0.0f, _S727);
        FKMedium _S877 = _S875;
        FKSurface _S878 = Surface_x24init_0(_S727, _S727, 0.0f, &_S876, false, 0U, 1.0f, false, &_S877, 4294967295U, _S727);
        bool _S879 = !_S874;
        bool scatter_2;
        bool is_inside_6;
        float3  throughput_5;
        FKSurface surface_11;
        if(_S879)
        {
            uint _S880 = stream(_S755, b_4);
            uint _S881 = arrivalLobe_0(b_4, (&prev_0)->lobe);
            FKSurface _S882 = (fcptSurfaceAtPath((hit_1), ((&ray_2)->origin), (_S880), (width_2), (layer_0), (b_4), (_S881), ((&ray_2)->unit_direction)));
            bool _S883 = !passes_0;
            FKSurface _S884 = _S882;
            FKSurface _S885 = emitting_0(&_S884, _S883);
            uint _S886 = stream(_S755, b_4 + 256U);
            Random _S887 = pcg(_S886);
            FKSurface _S888 = _S885;
            FKSurface _S889 = uncovered_0(&_S888, _S887.value);
            float _S890 = facingSign(_S889.material.transmission, _S889.geometry_n, (&ray_2)->unit_direction);
            bool _S891 = _S890 < 0.0f;
            bool _S892 = (_S889.material.transmission) > 0.0f;
            if(_S892)
            {
                bool _S893 = arrivesBehind_0((&ray_2)->unit_direction, _S889.geometry_n);
                scatter_2 = _S893;
            }
            else
            {
                scatter_2 = false;
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
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S897 = beerLambert((&hit_1)->distance, _S895.material.absorption);
                float3  _S898 = throughput_2 * _S897;
                throughput_5 = _S898;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S899 = !_S895.skip;
            float geometry_density_3 = geometryDensity(_S895.geometry_n, (&ray_2)->unit_direction, (&hit_1)->distance);
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
            scatter_2 = _S899;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S902;
            surface_11 = _S895;
            turned_1 = _S891;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_11 = _S878;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S903 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S904 = surface_11;
        FKSurface _S905 = surface_11;
        float _S906 = dot_0(surface_11.smooth_n, - (&ray_2)->unit_direction);
        BSDFMaterial _S907 = _S904.material;
        float2  _S908 = vertexEta_0(&_S907, _S906);
        bool _S909;
        if(scatter_2)
        {
            bool _S910 = samplesLights(_S904.material);
            _S909 = _S910;
        }
        else
        {
            _S909 = false;
        }
        bool _S911;
        if(passes_0)
        {
            _S911 = true;
        }
        else
        {
            _S911 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S911)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S909;
        }
        float3  _S912 = sideNormal(surface_11, (&ray_2)->unit_direction);
        FKSurface _S913 = surface_11;
        float3  _S914 = surface_11.hair;
        bool _S915 = (dot_0(_S914, _S914)) > 0.0f;
        bool _S916 = !_S915;
        bool _S917;
        if(_S916)
        {
            _S917 = !((_S904.material.transmission) > 0.0f);
        }
        else
        {
            _S917 = false;
        }
        FKSurface _S918 = surface_11;
        float3  _S919 = surface_11.geometry_n * make_float3 (dot_0(surface_11.geometry_n, _S905.smooth_n));
        float3  emission_0;
        if(_S874)
        {
            float3  _S920 = (fcptCalculatePointLightContrib(((&hit_1)->instance_index)));
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
            FKHit _S924 = hit_1;
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
            _S926 = _S732 == 1U;
        }
        else
        {
            _S926 = false;
        }
        bool _S927;
        if(_S926)
        {
            _S927 = b_4 > _S731;
        }
        else
        {
            _S927 = false;
        }
        bool _S928;
        if(_S927)
        {
            _S928 = b_4 == _S730;
        }
        else
        {
            _S928 = false;
        }
        bool _S929;
        if(_S928)
        {
            bool _S930 = _S733 == 1U;
            if(_S930)
            {
                _S929 = true;
            }
            else
            {
                _S929 = _S733 == 2U;
            }
        }
        else
        {
            _S929 = false;
        }
        if(_S929)
        {
            bool _S931 = _S874 != (_S733 == 2U);
            if(_S931)
            {
                return _S728;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_3->jac), density_2 / r_3->jac);
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
        fcptWithReservoirHit((&here_0), (&hit_1));
        bool _S941;
        if(replay_1)
        {
            _S941 = _S732 == 1U;
        }
        else
        {
            _S941 = false;
        }
        bool _S942;
        if(_S941)
        {
            _S942 = b_4 == _S731;
        }
        else
        {
            _S942 = false;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S943;
        bool _S944;
        float3  throughput_6;
        float3  throughput_7;
        float density_4;
        if(_S942)
        {
            bool _S945 = ((&hit_1)->instance_index) != (_S744.instance_index);
            if(_S945)
            {
                viewed_1 = true;
            }
            else
            {
                viewed_1 = ((&hit_1)->triangle_index) != (_S744.triangle_index);
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
                return _S728;
            }
            float3  throughput_8 = throughput_5 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            bool _S946 = _S731 == _S730;
            if(_S946)
            {
                wrong_side_0 = _S733 == 1U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                return Shift_x24init_0(throughput_8 * emission_1 / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            if(_S946)
            {
                _S943 = _S733 == 0U;
            }
            else
            {
                _S943 = false;
            }
            if(_S943)
            {
                float3  _S947 = (&ray_2)->origin;
                if(_S915)
                {
                    throughput_2 = _S727;
                }
                else
                {
                    throughput_2 = _S905.smooth_n;
                }
                FKSurface _S948 = surface_11;
                if(_S915)
                {
                    passes_0 = true;
                }
                else
                {
                    BSDFMaterial _S949 = _S904.material;
                    bool _S950 = isTranslucent_0(&_S949);
                    passes_0 = _S950;
                }
                uint _S951 = stream(_S755, b_4 + 64U);
                uint _S952 = arrivalLobe_0(b_4, (&prev_0)->lobe);
                FKSurface _S953 = surface_11;
                FKHit _S954 = hit_1;
                ShadowContext _S955 = shadowContext_0(&_S953, turned_1, _S912, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_4, _S952, (&hit_1)->distance, width_2, _S917, _S919, &_S954, _S915);
                ShadowContext _S956 = _S955;
                TreeSample _S957 = sampleLightTree_0(_S947, throughput_2, _S918.geometry_n, _S948.geometry_offset, passes_0, _S951, &_S956);
                bool _S958 = !nee_0;
                if(_S958)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S959 = rgb_to_greyscale(_S957.radiance);
                    passes_0 = !(_S959 > 0.0f);
                }
                if(passes_0)
                {
                    return _S728;
                }
                if(_S915)
                {
                    uint _S960 = (fcptMaxBounces());
                    bool _S961 = b_4 < _S960;
                    FKSurface _S962 = surface_11;
                    TreeSample _S963 = _S957;
                    float3  _S964 = hairLight_0(&_S962, (&ray_2)->unit_direction, &_S963, _S961);
                    throughput_2 = _S964;
                }
                else
                {
                    float _S965 = _S908.x;
                    float _S966 = _S908.y;
                    uint _S967 = (fcptMaxBounces());
                    bool _S968 = b_4 < _S967;
                    TreeSample _S969 = _S957;
                    BSDFMaterial _S970 = _S904.material;
                    float3  _S971 = lightBSDF_0((&ray_2)->unit_direction, &_S969, _S905.smooth_n, _S912, &_S970, _S965, _S966, _S968, surface_11.random_state);
                    throughput_2 = _S971;
                }
                return Shift_x24init_0(throughput_8 * throughput_2 / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            if(_S946)
            {
                _S944 = _S733 == 4U;
            }
            else
            {
                _S944 = false;
            }
            if(_S944)
            {
                bool _S972 = !nee_0;
                if(_S972)
                {
                    return _S728;
                }
                float _S973 = environmentPdf_0(r_3->dir);
                float3  _S974 = skyBSDF((&ray_2)->unit_direction, r_3->dir, surface_11, _S912, _S908, is_inside_6, _S973, surface_11.random_state);
                return Shift_x24init_0(throughput_8 * _S974 * r_3->radiance / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            uint _S975 = extractBits_0(_S729, 19U, 1U);
            bool _S976 = nee_0 != (_S975 == 1U);
            if(_S976)
            {
                return _S728;
            }
            throughput_6 = throughput_8;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = b_4 == _S743;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S977 = !scatter_2;
                if(_S977)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S978 = _S732 != 1U;
                    if(_S978)
                    {
                        refracted_4 = _S732 != 3U;
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
                bool _S979 = _S732 == 2U;
                if(_S979)
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
                    passes_0 = _S733 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    uint _S980 = stream(_S755, b_4 + 448U);
                    FKRay _S981 = ray_2;
                    FKSurface _S982 = surface_11;
                    SkySample _S983 = sampleSky_0(&_S981, &_S982, _S912, _S908, is_inside_6, _S980, surface_11.random_state);
                    return Shift_x24init_0(throughput_5 * _S983.color, 1.0f);
                }
                if(_S979)
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
                    float3  _S984 = (&ray_2)->origin;
                    if(_S915)
                    {
                        throughput_2 = _S727;
                    }
                    else
                    {
                        throughput_2 = _S905.smooth_n;
                    }
                    FKSurface _S985 = surface_11;
                    if(_S915)
                    {
                        passes_0 = true;
                    }
                    else
                    {
                        BSDFMaterial _S986 = _S904.material;
                        bool _S987 = isTranslucent_0(&_S986);
                        passes_0 = _S987;
                    }
                    uint _S988 = stream(_S755, b_4 + 64U);
                    uint _S989 = arrivalLobe_0(b_4, (&prev_0)->lobe);
                    FKSurface _S990 = surface_11;
                    FKHit _S991 = hit_1;
                    ShadowContext _S992 = shadowContext_0(&_S990, turned_1, _S912, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_4, _S989, (&hit_1)->distance, width_2, _S917, _S919, &_S991, _S915);
                    ShadowContext _S993 = _S992;
                    TreeSample _S994 = sampleLightTree_0(_S984, throughput_2, _S918.geometry_n, _S985.geometry_offset, passes_0, _S988, &_S993);
                    float _S995 = rgb_to_greyscale(_S994.radiance);
                    bool _S996 = !(_S995 > 0.0f);
                    if(_S996)
                    {
                        return _S728;
                    }
                    if(_S915)
                    {
                        uint _S997 = (fcptMaxBounces());
                        bool _S998 = b_4 < _S997;
                        FKSurface _S999 = surface_11;
                        TreeSample _S1000 = _S994;
                        float3  _S1001 = hairLight_0(&_S999, (&ray_2)->unit_direction, &_S1000, _S998);
                        throughput_2 = _S1001;
                    }
                    else
                    {
                        float _S1002 = _S908.x;
                        float _S1003 = _S908.y;
                        uint _S1004 = (fcptMaxBounces());
                        bool _S1005 = b_4 < _S1004;
                        TreeSample _S1006 = _S994;
                        BSDFMaterial _S1007 = _S904.material;
                        float3  _S1008 = lightBSDF_0((&ray_2)->unit_direction, &_S1006, _S905.smooth_n, _S912, &_S1007, _S1002, _S1003, _S1005, surface_11.random_state);
                        throughput_2 = _S1008;
                    }
                    return Shift_x24init_0(throughput_5 * throughput_2, 1.0f);
                }
                if(_S742)
                {
                    passes_0 = _S733 == 2U;
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
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S742)
                {
                    passes_0 = _S733 == 1U;
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
                    passes_0 = !_S903;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S728;
            }
            else
            {
                bool _S1009 = !replay_1;
                if(_S1009)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1010 = b_4 > 0U;
                    if(_S1010)
                    {
                        Reservoir candidate_4 = chain_0;
                        if(_S933)
                        {
                            float3  _S1011 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_4)->radiance = _S1011;
                        }
                        else
                        {
                            if(_S903)
                            {
                                candidate_4 = here_0;
                            }
                        }
                        float3  _S1012 = throughput_5 * emission_1;
                        Reservoir _S1013 = withEnd(candidate_4, 1U, b_4, _S1012);
                        offer(sel_1, _S1013, _S1012 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1014 = throughput_5 * emission_1;
                        float3  _S1015 = sel_1->glow + _S1014;
                        sel_1->glow = _S1015;
                    }
                    if(nee_0)
                    {
                        float3  _S1016 = (&ray_2)->origin;
                        if(_S915)
                        {
                            throughput_6 = _S727;
                        }
                        else
                        {
                            throughput_6 = _S905.smooth_n;
                        }
                        FKSurface _S1017 = surface_11;
                        if(_S915)
                        {
                            _S943 = true;
                        }
                        else
                        {
                            BSDFMaterial _S1018 = _S904.material;
                            bool _S1019 = isTranslucent_0(&_S1018);
                            _S943 = _S1019;
                        }
                        uint _S1020 = stream(_S755, b_4 + 64U);
                        uint _S1021 = arrivalLobe_0(b_4, (&prev_0)->lobe);
                        FKSurface _S1022 = surface_11;
                        FKHit _S1023 = hit_1;
                        ShadowContext _S1024 = shadowContext_0(&_S1022, turned_1, _S912, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_4, _S1021, (&hit_1)->distance, width_2, _S917, _S919, &_S1023, _S915);
                        ShadowContext _S1025 = _S1024;
                        TreeSample _S1026 = sampleLightTree_0(_S1016, throughput_6, _S918.geometry_n, _S1017.geometry_offset, _S943, _S1020, &_S1025);
                        if(_S915)
                        {
                            uint _S1027 = (fcptMaxBounces());
                            bool _S1028 = b_4 < _S1027;
                            FKSurface _S1029 = surface_11;
                            TreeSample _S1030 = _S1026;
                            float3  _S1031 = hairLight_0(&_S1029, (&ray_2)->unit_direction, &_S1030, _S1028);
                            throughput_7 = _S1031;
                        }
                        else
                        {
                            float _S1032 = _S908.x;
                            float _S1033 = _S908.y;
                            uint _S1034 = (fcptMaxBounces());
                            bool _S1035 = b_4 < _S1034;
                            TreeSample _S1036 = _S1026;
                            BSDFMaterial _S1037 = _S904.material;
                            float3  _S1038 = lightBSDF_0((&ray_2)->unit_direction, &_S1036, _S905.smooth_n, _S912, &_S1037, _S1032, _S1033, _S1035, surface_11.random_state);
                            throughput_7 = _S1038;
                        }
                        float3  _S1039 = throughput_5 * throughput_7;
                        Reservoir candidate_5 = chain_0;
                        if(_S933)
                        {
                            float3  _S1040 = safeDivide(_S1039, chain_throughput_0);
                            (&candidate_5)->radiance = _S1040;
                        }
                        else
                        {
                            if(_S903)
                            {
                                candidate_5 = here_0;
                                uint _S1041 = insertBits_0((&candidate_5)->path, 1U, 19U, 1U);
                                (&candidate_5)->path = _S1041;
                                (&candidate_5)->dir = _S1026.dir;
                                (&candidate_5)->radiance = _S1026.radiance;
                            }
                            else
                            {
                                uint _S1042 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S1043 = insertBits_0(_S1042, 2U, 10U, 2U);
                                (&candidate_5)->path = _S1043;
                            }
                        }
                        Reservoir _S1044 = withEnd(candidate_5, 0U, b_4, _S1039);
                        offer(sel_1, _S1044, _S1039 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S915)
                        {
                            _S943 = false;
                        }
                        else
                        {
                            bool _S1045 = environmentMapped_0();
                            _S943 = _S1045;
                        }
                    }
                    else
                    {
                        _S943 = false;
                    }
                    if(_S943)
                    {
                        uint _S1046 = (fcptMaxBounces());
                        _S944 = b_4 < _S1046;
                    }
                    else
                    {
                        _S944 = false;
                    }
                    if(_S944)
                    {
                        uint _S1047 = stream(_S755, b_4 + 448U);
                        FKRay _S1048 = ray_2;
                        FKSurface _S1049 = surface_11;
                        SkySample _S1050 = sampleSky_0(&_S1048, &_S1049, _S912, _S908, is_inside_6, _S1047, surface_11.random_state);
                        float3  _S1051 = throughput_5 * _S1050.color;
                        Reservoir candidate_6 = chain_0;
                        if(_S933)
                        {
                            float3  _S1052 = safeDivide(_S1051, chain_throughput_0);
                            (&candidate_6)->radiance = _S1052;
                        }
                        else
                        {
                            if(_S903)
                            {
                                candidate_6 = here_0;
                                uint _S1053 = insertBits_0((&candidate_6)->path, 1U, 19U, 1U);
                                (&candidate_6)->path = _S1053;
                                (&candidate_6)->dir = _S1050.dir;
                                (&candidate_6)->radiance = _S1050.radiance;
                            }
                            else
                            {
                                uint _S1054 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S1055 = insertBits_0(_S1054, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1055;
                            }
                        }
                        Reservoir _S1056 = withEnd(candidate_6, 4U, b_4, _S1051);
                        offer(sel_1, _S1056, _S1051 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1057;
        bool straight_0;
        bool _S1058;
        bool _S1059;
        bool _S1060;
        bool _S1061;
        bool _S1062;
        bool _S1063;
        bool _S1064;
        bool _S1065;
        bool _S1066;
        bool _S1067;
        bool _S1068;
        bool _S1069;
        bool _S1070;
        bool _S1071;
        bool again_0;
        bool opaque_start_0;
        bool on_face_0;
        uint b_7;
        float3  throughput_9;
        float3  throughput_10;
        float density_6;
        float sky_pdf_2;
        float spread_4;
        if(scatter_2)
        {
            if(replay_1)
            {
                viewed_1 = b_4 == _S743;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1072 = extractBits_0(_S729, 15U, 2U);
            uint _S1073 = extractBits_0(_S729, 17U, 2U);
            uint _S1074 = _slang_select(_S942, _S1073,_S1072);
            float3  _S1075 = r_3->dir;
            bool refracted_5 = _S1074 == 1U;
            SampleBSDF _S1076 = SampleBSDF_x24init_0(_S727, _S727, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_10 = _S1076;
            float3  reconnection_1;
            SampleBSDF _S1077;
            if(viewed_1)
            {
                uint _S1078 = extractBits_0(_S729, 20U, 1U);
                bool _S1079 = is_inside_6 != (_S1078 == 1U);
                if(_S1079)
                {
                    return _S728;
                }
                bool _S1080 = _S732 == 1U;
                if(_S1080)
                {
                    float3  _S1081 = (fcptHitPosition((_S744)));
                    throughput_7 = _S1081;
                }
                else
                {
                    throughput_7 = reconnection_0;
                }
                if(refracted_5)
                {
                    refracted_4 = true;
                }
                else
                {
                    BSDFMaterial _S1082 = _S904.material;
                    bool _S1083 = isTranslucent_0(&_S1082);
                    if(_S1083)
                    {
                        refracted_4 = _S1074 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1084 = throughput_7 - (&ray_2)->origin;
                        float3  _S1085 = _slang_select(_S1080, _S1084,_S1075);
                        wrong_side_0 = (dot_0(_S905.smooth_n, _S1085) * _S906) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1080)
                {
                    float3  _S1086 = (&ray_2)->origin;
                    FKSurface _S1087 = surface_11;
                    float3  _S1088 = - _S905.smooth_n;
                    bool _S1089 = is_inside_6 != refracted_4;
                    float3  _S1090 = _slang_select(_S1089, _S1088,_S905.smooth_n);
                    float3  _S1091 = make_float3 (_S1087.geometry_offset) * _S1090;
                    bool _S1092 = (dot_0(throughput_7 - (&ray_2)->origin, _S912)) > 0.0f;
                    float _S1093 = _slang_select(_S1092, _S1087.geometry_offset,0.0f);
                    float3  _S1094 = _S919 * make_float3 (_S1093);
                    float3  _S1095 = _slang_select(_S917, _S1094,_S1091);
                    float3  _S1096 = throughput_7 - (_S1086 + _S1095);
                    float3  _S1097 = ((((_S1096)) * make_float3(rnorm3df(((_S1096)).x, ((_S1096)).y, ((_S1096)).z))));
                    reconnection_1 = _S1097;
                }
                else
                {
                    reconnection_1 = _S1075;
                }
                if(_S915)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1098 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, _S912);
                    wrong_side_0 = _S1098;
                }
                if(wrong_side_0)
                {
                    return _S728;
                }
                float3  _S1099 = throughput_7;
                throughput_7 = reconnection_1;
                b_7 = _S1074;
                wrong_side_0 = false;
                reconnection_1 = _S1099;
            }
            else
            {
                bool _S1100 = !_S942;
                if(_S1100)
                {
                    SampleBSDF bsdf_sampled_0;
                    if(_S915)
                    {
                        SampleBSDF _S1101 = (fcptSampleHair((_S913.hair), (_S904.material.albedo), (_S904.material.specular_tint), ((&ray_2)->unit_direction), (surface_11.random_state)));
                        _S1077 = _S1101;
                    }
                    else
                    {
                        SampleBSDF _S1102 = sampleBSDF((&ray_2)->unit_direction, _S905.smooth_n, _S904.material, _S908.x, _S908.y, surface_11.random_state, make_float2 (0.0f));
                        _S1077 = _S1102;
                    }
                    bsdf_sampled_0 = _S1077;
                    if(_S915)
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
                            return _S728;
                        }
                        break;
                    }
                    if(_S915)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1103 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, _S912);
                        wrong_side_0 = _S1103;
                    }
                    if(wrong_side_0)
                    {
                        _S943 = (_S904.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S943 = false;
                    }
                    if(_S943)
                    {
                        SampleBSDF _S1104 = sampleBSDF((&bsdf_sampled_0)->unit_direction, _S918.geometry_n, _S904.material, _S908.x, _S908.y, (&bsdf_sampled_0)->random_state, make_float2 (0.0f));
                        (&bsdf_sampled_0)->unit_direction = _S1104.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1104.refracted;
                        (&bsdf_sampled_0)->throughput = _S1104.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1105 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, _S918.geometry_n)) * _S918.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1105;
                        }
                    }
                    uint _S1106 = (&bsdf_sampled_0)->lobe;
                    float3  _S1107 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1108 = (&bsdf_sampled_0)->refracted;
                    lobe_10 = bsdf_sampled_0;
                    float _S1109 = (&bsdf_sampled_0)->pdf;
                    float _S1110 = _slang_select(wrong_side_0, 0.0f,_S1109);
                    (&lobe_10)->pdf = _S1110;
                    throughput_7 = _S1107;
                    b_7 = _S1106;
                    refracted_4 = _S1108;
                }
                else
                {
                    throughput_7 = _S1075;
                    b_7 = _S1074;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S943 = true;
            }
            else
            {
                _S943 = _S942;
            }
            if(_S943)
            {
                if(_S915)
                {
                    SampleBSDF _S1111 = (fcptConnectHair((_S913.hair), (_S904.material.albedo), (_S904.material.specular_tint), ((&ray_2)->unit_direction), (throughput_7)));
                    _S1077 = _S1111;
                }
                else
                {
                    SampleBSDF _S1112 = connectBSDF((&ray_2)->unit_direction, throughput_7, _S905.smooth_n, _S904.material, _S908.x, _S908.y, b_7, surface_11.random_state);
                    _S1077 = _S1112;
                }
                lobe_10 = _S1077;
            }
            if(_S915)
            {
                _S944 = false;
            }
            else
            {
                bool _S1113 = b_7 != 0U;
                if(_S1113)
                {
                    bool _S1114 = (_S904.material.roughness) == 0.0f;
                    if(_S1114)
                    {
                        _S944 = true;
                    }
                    else
                    {
                        bool _S1115 = b_7 == 1U;
                        if(_S1115)
                        {
                            _S944 = (_S908.x) == (_S908.y);
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
            }
            if(_S916)
            {
                _S1057 = b_7 == 1U;
            }
            else
            {
                _S1057 = false;
            }
            if(_S1057)
            {
                straight_0 = (_S904.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1058 = _S916;
            }
            else
            {
                _S1058 = false;
            }
            if(_S1058)
            {
                _S1059 = b_7 == 1U;
            }
            else
            {
                _S1059 = false;
            }
            if(_S1059)
            {
                _S1060 = (_S908.x) == (_S908.y);
            }
            else
            {
                _S1060 = false;
            }
            BSDFMaterial _S1116 = _S904.material;
            bool _S1117 = isTranslucent_0(&_S1116);
            if(_S1117)
            {
                _S1061 = b_7 == 0U;
            }
            else
            {
                _S1061 = false;
            }
            if(_S1061)
            {
                _S1062 = (dot_0(throughput_7, _S918.geometry_n)) < 0.0f;
            }
            else
            {
                _S1062 = false;
            }
            if(nee_0)
            {
                _S1063 = !_S944;
            }
            else
            {
                _S1063 = false;
            }
            if(_S1063)
            {
                _S1064 = !wrong_side_0;
            }
            else
            {
                _S1064 = false;
            }
            if(_S1064)
            {
                float _S1118 = (&lobe_10)->pdf;
                float3  _S1119 = (&ray_2)->origin;
                BSDFMaterial _S1120 = _S904.material;
                bool _S1121 = isTranslucent_0(&_S1120);
                if(_S1121)
                {
                    _S1065 = true;
                }
                else
                {
                    _S1065 = _S915;
                }
                float3  _S1122 = _slang_select(_S1065, _S727,_S905.smooth_n);
                float3  _S1123 = (&ray_2)->origin;
                FKSurface _S1124 = surface_11;
                float3  _S1125 = - _S905.smooth_n;
                float3  _S1126 = _slang_select(_S1062, _S1125,_S905.smooth_n);
                float3  _S1127 = make_float3 (_S1124.geometry_offset) * _S1126;
                bool _S1128 = (dot_0(throughput_7, _S912)) > 0.0f;
                float _S1129 = _slang_select(_S1128, _S1124.geometry_offset,0.0f);
                float3  _S1130 = _S919 * make_float3 (_S1129);
                float3  _S1131 = _slang_select(_S917, _S1130,_S1127);
                NEEVertex _S1132 = NEEVertex_x24init_0(false, _S1118, _S1119, _S1122, _S1123 + _S1131);
                nee_vertex_0 = _S1132;
            }
            else
            {
                if(_S915)
                {
                    _S1065 = true;
                }
                else
                {
                    bool _S1133 = b_7 != 1U;
                    if(_S1133)
                    {
                        _S1065 = true;
                    }
                    else
                    {
                        _S1065 = (_S908.x) != (_S908.y);
                    }
                }
                if(_S1065)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1134 = b_7 == 0U;
            bool _S1135 = withinInverseFootprint((&lobe_10)->pdf, _S1134, (&prev_0)->cos, (&hit_1)->distance, threshold_2);
            float _S1136 = dot_0(throughput_7, _S918.geometry_n);
            bool _S1137 = (dot_0(throughput_7, _S905.smooth_n) * _S1136) < 0.0f;
            bool _S1138 = !_S1137;
            if(_S1138)
            {
                bool _S1139 = roughLobe((&lobe_10)->pdf, _S1134, _S904.material.roughness);
                _S1065 = _S1139;
            }
            else
            {
                _S1065 = false;
            }
            if(_S942)
            {
                bool _S1140 = !_S1135;
                if(_S1140)
                {
                    return _S728;
                }
                bool _S1141 = _S733 != 1U;
                if(_S1141)
                {
                    _S1066 = _S733 != 2U;
                }
                else
                {
                    _S1066 = false;
                }
                if(_S1066)
                {
                    float _S1142 = (&lobe_10)->pdf;
                    float _S1143 = _slang_select(nee_0, _S1142,0.0f);
                    float _S1144 = escapeWeight_0(_S1143, _S1075);
                    bool _S1145 = _S731 == _S730;
                    if(_S1145)
                    {
                        passes_0 = _S739;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1146 = _slang_select(passes_0, _S1144,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_10)->throughput * make_float3 ((&lobe_10)->pdf)) * r_3->radiance * make_float3 (_S1146) / make_float3 (r_3->jac), density_4 * (&lobe_10)->pdf / r_3->jac);
                }
                float3  _S1147 = throughput_6 * make_float3 ((&lobe_10)->pdf);
                float _S1148 = density_4 * (&lobe_10)->pdf;
                throughput_9 = _S1147;
                density_6 = _S1148;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1149 = (fcptLayers((hit_1)));
            bool _S1150 = b_7 == 1U;
            bool _S1151 = passesLayer_0(_S1149, _S1150, passes_0);
            if(viewed_1)
            {
                _S1066 = _S1151;
            }
            else
            {
                _S1066 = false;
            }
            if(_S1066)
            {
                return _S728;
            }
            if(replay_1)
            {
                _S1067 = b_4 <= _S743;
            }
            else
            {
                _S1067 = false;
            }
            if(_S1067)
            {
                _S1068 = _S903;
            }
            else
            {
                _S1068 = false;
            }
            if(_S1068)
            {
                _S1069 = _S1135;
            }
            else
            {
                _S1069 = false;
            }
            if(_S1069)
            {
                _S1070 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1070 = !_S1065;
                }
                else
                {
                    _S1070 = false;
                }
            }
            if(_S1070)
            {
                return _S728;
            }
            if(viewed_1)
            {
                float3  _S1152 = throughput_9 * ((&lobe_10)->throughput * make_float3 ((&lobe_10)->pdf));
                float _S1153 = (&lobe_10)->pdf;
                throughput_10 = _S1152;
                sky_pdf_2 = _S1153;
            }
            else
            {
                float3  _S1154 = throughput_9 * max_0((&lobe_10)->throughput, _S727);
                throughput_10 = _S1154;
                sky_pdf_2 = density_6;
            }
            bool _S1155 = !replay_1;
            if(_S1155)
            {
                _S1071 = !_S933;
            }
            else
            {
                _S1071 = false;
            }
            bool _S1156;
            if(_S1071)
            {
                _S1156 = _S903;
            }
            else
            {
                _S1156 = false;
            }
            bool _S1157;
            if(_S1156)
            {
                _S1157 = _S1135;
            }
            else
            {
                _S1157 = false;
            }
            float3  chain_throughput_1;
            if(_S1157)
            {
                chain_0 = here_0;
                uint _S1158 = insertBits_0((&chain_0)->path, b_7, 17U, 2U);
                uint _S1159 = _slang_select(nee_0, 1U,0U);
                uint _S1160 = insertBits_0(_S1158, _S1159, 19U, 1U);
                (&chain_0)->path = _S1160;
                float _S1161 = (&chain_0)->jac * (&lobe_10)->pdf;
                (&chain_0)->jac = _S1161;
                (&chain_0)->dir = throughput_7;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            Vertex _S1162 = Vertex_x24init_0(_S1065, b_7, (&lobe_10)->pdf, (F32_abs((dot_0(_S918.geometry_n, throughput_7)))), is_inside_6);
            prev_0 = _S1162;
            float _S1163 = (&lobe_10)->pdf;
            bool _S1164;
            if(_S1150)
            {
                _S1164 = (_S908.x) == (_S908.y);
            }
            else
            {
                _S1164 = false;
            }
            float sky_pdf_3 = _slang_select(_S1164, sky_pdf_0,_S1163);
            float _S1165 = _slang_select(_S915, 0.0f,sky_pdf_3);
            float _S1166 = widened_0(spread_1, (&lobe_10)->pdf, _S944);
            bool _S1167;
            if(refracted_4)
            {
                _S1167 = !_S1062;
            }
            else
            {
                _S1167 = false;
            }
            bool is_inside_7;
            if(_S1167)
            {
                bool _S1168 = !is_inside_6;
                is_inside_7 = _S1168;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            bool _S1169 = !_S1151;
            if(_S1169)
            {
                FKSurface faced_3 = surface_11;
                float3  _S1170 = - _S918.geometry_n;
                float3  _S1171 = _slang_select(turned_1, _S1170,_S918.geometry_n);
                (&faced_3)->geometry_n = _S1171;
                FKMedium _S1172 = Medium_x24init_0(scatter_in_0, extinction_in_0);
                FKSurface _S1173 = faced_3;
                FKMedium _S1174 = _S1172;
                MediumSides _S1175 = mediumSides_0(&_S1173, &_S1174, filling_2, (&ray_2)->unit_direction);
                bool _S1176 = leavesInFront_0((&faced_3)->geometry_n, throughput_7, _S912, _S918.geometry_n);
                float3  _S1177 = _slang_select(_S1176, _S1175.front.scatter,_S1175.behind.scatter);
                scatter_in_0 = _S1177;
                float3  _S1178 = _slang_select(_S1176, _S1175.front.extinction,_S1175.behind.extinction);
                extinction_in_0 = _S1178;
                uint _S1179 = _S1175.fillings.x;
                uint _S1180 = _S1175.fillings.y;
                uint _S1181 = _slang_select(_S1176, _S1180,_S1179);
                filling_2 = _S1181;
            }
            (&ray_2)->unit_direction = throughput_7;
            if(_S1169)
            {
                if(_S917)
                {
                    bool _S1182 = (dot_0(throughput_7, _S912)) > 0.0f;
                    if(_S1182)
                    {
                        again_0 = (surface_11.geometry_offset) > 0.0f;
                    }
                    else
                    {
                        again_0 = false;
                    }
                    FKSurface _S1183 = surface_11;
                    float _S1184 = _slang_select(again_0, _S1183.geometry_offset,0.0f);
                    float3  _S1185 = (&ray_2)->origin + _S919 * make_float3 (_S1184);
                    (&ray_2)->origin = _S1185;
                    bool _S1186 = !again_0;
                    BSDFMaterial _S1187 = _S904.material;
                    bool _S1188 = isTranslucent_0(&_S1187);
                    bool _S1189 = !_S1188;
                    if(_S1189)
                    {
                        opaque_start_0 = !((_S1183.geometry_offset) > 0.0f);
                    }
                    else
                    {
                        opaque_start_0 = false;
                    }
                    if(opaque_start_0)
                    {
                        on_face_0 = _S1136 < 0.0f;
                    }
                    else
                    {
                        on_face_0 = false;
                    }
                    again_0 = on_face_0;
                    opaque_start_0 = true;
                    on_face_0 = _S1186;
                }
                else
                {
                    if(_S915)
                    {
                    }
                    else
                    {
                        FKSurface _S1190 = surface_11;
                        float _S1191 = _slang_select(straight_0, 0.0f,_S1190.geometry_offset);
                        float3  _S1192 = - _S905.smooth_n;
                        bool _S1193 = is_inside_7 != _S1062;
                        float3  _S1194 = _slang_select(_S1193, _S1192,_S905.smooth_n);
                        float3  _S1195 = (&ray_2)->origin + make_float3 (_S1191) * _S1194;
                        (&ray_2)->origin = _S1195;
                    }
                    again_0 = false;
                    opaque_start_0 = _S915;
                    on_face_0 = _S915;
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
            passes_0 = _S1151;
            viewed_1 = _S1060;
            sky_pdf_2 = _S1165;
            spread_4 = _S1166;
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
        bool _S1196 = !replay_1;
        float density_7;
        if(_S1196)
        {
            if(_S874)
            {
                float3  _S1197 = throughput_9 * emission_1;
                Reservoir candidate_7 = chain_0;
                uint _S1198 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1199 = _S1198 == 1U;
                if(_S1199)
                {
                    float3  _S1200 = safeDivide(_S1197, chain_throughput_0);
                    (&candidate_7)->radiance = _S1200;
                }
                Reservoir _S1201 = withEnd(candidate_7, 2U, b_4, _S1197);
                offer(sel_1, _S1201, _S1197 * make_float3 (scale_1) / make_float3 (density_6));
            }
            if(_S874)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1202 = survivalProbability(throughput_9, density_6);
                density_7 = _S1202;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1203 = stream(_S755, b_4 + 128U);
            Random _S1204 = pcg(_S1203);
            bool _S1205 = density_7 < (_S1204.value);
            if(_S1205)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1206 = (fcptMaxBounces());
                wrong_side_0 = b_4 >= _S1206;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1207 = density_6 * density_7;
            density_7 = _S1207;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1208 = layer_0 ^ 1U;
        uint _S1209 = _slang_select(passes_0, _S1208,0U);
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
            uint _S1210 = b_7 + 1U;
            b_4 = _S1210;
            layer_0 = _S1209;
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
            uint _S1210 = b_7 + 1U;
            b_4 = _S1210;
            layer_0 = _S1209;
            continue;
        }
        FKRay _S1211 = ray_2;
        float _S1212 = distance_5(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = b_4 == _S743;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S732 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1213 = _slang_select(wrong_side_0, _S1212,4.294967296e+09f);
        bool _S1214 = !opaque_start_0;
        if(straight_0)
        {
            _S943 = true;
        }
        else
        {
            _S943 = on_face_0;
        }
        FKHit _S1215;
        if(_S943)
        {
            _S1215 = hit_1;
        }
        else
        {
            _S1215 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
        }
        FKHit _S1216 = (fcptTraverseInstanceBVH((_S1211), (_S879), (_S1213), (_S1214), (_S1215), (viewed_1)));
        hit_1 = _S1216;
        if(replay_1)
        {
            _S944 = b_4 == _S743;
        }
        else
        {
            _S944 = false;
        }
        if(_S944)
        {
            _S1057 = _S732 == 1U;
        }
        else
        {
            _S1057 = false;
        }
        if(_S1057)
        {
            _S1058 = ((&hit_1)->instance_index) == (_S744.instance_index);
        }
        else
        {
            _S1058 = false;
        }
        if(_S1058)
        {
            _S1059 = ((&hit_1)->triangle_index) == (_S744.triangle_index);
        }
        else
        {
            _S1059 = false;
        }
        if(_S1059)
        {
            (&hit_1)->uv = _S744.uv;
            float _S1217 = distance_5(reconnection_0, (&ray_2)->origin);
            (&hit_1)->distance = _S1217;
        }
        if(replay_1)
        {
            _S1060 = b_4 == _S743;
        }
        else
        {
            _S1060 = false;
        }
        if(_S1060)
        {
            _S1061 = _S732 == 3U;
        }
        else
        {
            _S1061 = false;
        }
        if(_S1061)
        {
            _S1062 = ((&hit_1)->instance_index) != 4294967295U;
        }
        else
        {
            _S1062 = false;
        }
        if(_S1062)
        {
            return _S728;
        }
        Reservoir _S1218 = chain_0;
        uint _S1219 = filling_2;
        for(;;)
        {
            bool _S1220 = _S1219 != 4294967295U;
            float _S1221 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            float _S1222 = (fcptMajorant((_S1219)));
            float _S1223 = _slang_select(_S1220, _S1222,_S1221);
            if(replay_1)
            {
                _S1063 = b_4 == _S743;
            }
            else
            {
                _S1063 = false;
            }
            if(_S1063)
            {
                _S1064 = _S732 == 1U;
            }
            else
            {
                _S1064 = false;
            }
            if(_S1064)
            {
                _S1065 = _S1223 > 0.0f;
            }
            else
            {
                _S1065 = false;
            }
            if(_S1065)
            {
                ended_0 = _S728;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_3 = width_2;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_7 = b_4;
                _S1066 = true;
                break;
            }
            bool _S1224 = (&prev_0)->rough;
            if(_S1224)
            {
                _S1066 = !(_S1223 > 0.0f);
            }
            else
            {
                _S1066 = false;
            }
            (&prev_0)->rough = _S1066;
            uint _S1225 = b_4 + 320U;
            bool _S1226 = b_4 == 4294967295U;
            uint _S1227 = _slang_select(_S1226, 384U,_S1225);
            uint _S1228 = stream(_S755, _S1227);
            uint tracking_1 = _S1228;
            weight_1 = throughput_3;
            glowed_0 = _S727;
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
                    _S726 = int(2);
                    break;
                }
                uint _S1229 = b_7 + 320U;
                bool _S1230 = b_7 == 4294967295U;
                uint _S1231 = _slang_select(_S1230, 384U,_S1229);
                uint _S1232 = stream(_S755, _S1231);
                Random _S1233 = pcg(_S1232);
                float _S1234 = freeFlight_0(_S1233.value, _S1223);
                if(_S1220)
                {
                    float3  _S1235 = (&ray_2)->origin;
                    float3  _S1236 = (&ray_2)->unit_direction;
                    float _S1237 = (&hit_1)->distance;
                    uint _S1238 = _slang_select(_S1230, 0U,b_7);
                    uint _S1239 = (&prev_0)->lobe;
                    uint _S1240 = _slang_select(_S1230, 3U,_S1239);
                    float _S1241 = (fcptTrackMedium((_S1219), (_S1235), (_S1236), (_S1237), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S1238), (_S1240), (_S1230)));
                    spread_3 = _S1241;
                }
                else
                {
                    spread_3 = _S1234;
                }
                bool _S1242 = !(spread_3 < ((&hit_1)->distance));
                if(_S1242)
                {
                    _S726 = int(2);
                    break;
                }
                if(_S1220)
                {
                    _S1067 = _S1196;
                }
                else
                {
                    _S1067 = false;
                }
                if(_S1067)
                {
                    float3  _S1243 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1244 = sel_1->glow + _S1243;
                    sel_1->glow = _S1244;
                }
                else
                {
                }
                glowed_0 = _S727;
                uint b_8 = b_7 + 1U;
                float3  _S1245 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1245;
                float3  _S1246 = flightWeight_0(scatter_in_0, extinction_in_0, _S1223, spread_3, true);
                float3  _S1247 = weight_1;
                float3  _S1248 = _slang_select(_S1220, _S1247,_S1246);
                float3  throughput_11 = throughput_10 * _S1248;
                uint _S1249 = stream(_S755, b_8 + 320U);
                tracking_1 = _S1249;
                weight_1 = throughput_3;
                float width_6 = width_3 + spread_2 * spread_3;
                float _S1250 = spread_2 + 3.14159274101257324f;
                float3  _S1251 = (&ray_2)->origin;
                float3  _S1252 = (&ray_2)->unit_direction;
                float3  _S1253 = (&ray_2)->unit_direction;
                uint _S1254 = stream(_S755, b_8 + 64U);
                float3  _S1255 = extinction_in_0;
                float3  _S1256 = extinction_in_0;
                uint2  _S1257 = make_uint2 (_S1219);
                float3  _S1258 = (&ray_2)->unit_direction;
                uint _S1259 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                FKHit _S1260 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1261 = _S1260;
                ShadowContext _S1262 = ShadowContext_x24init_0(_S1255, _S1256, _S1257, _S1258, b_8, _S1259, false, spread_3, width_6, false, _S727, &_S1261, false, true);
                ShadowContext _S1263 = _S1262;
                TreeSample _S1264 = sampleLightTree_0(_S1251, _S1252, _S1253, 0.0f, true, _S1254, &_S1263);
                bool _S1265 = scatterSampled_0(replay_1, b_8, _S743, _S1220);
                uint _S1266 = (fcptMaxBounces());
                bool _S1267 = b_8 < _S1266;
                if(_S1267)
                {
                    _S1068 = (_S1264.density) > 0.0f;
                }
                else
                {
                    _S1068 = false;
                }
                float _S1268 = _slang_select(_S1068, 0.07957746833562851f,0.0f);
                float3  _S1269 = throughput_11 * _S1264.radiance;
                float _S1270 = powerHeuristic(_S1264.density, _S1268);
                float3  _S1271 = _S1269 * make_float3 (0.07957746833562851f * _S1270);
                float3  _S1272 = _slang_select(_S1265, _S1271,_S727);
                if(replay_1)
                {
                    _S1069 = b_8 == _S743;
                }
                else
                {
                    _S1069 = false;
                }
                if(_S1069)
                {
                    bool _S1273 = _S732 == 2U;
                    if(_S1273)
                    {
                        float _S1274 = rgb_to_greyscale(_S1272);
                        _S1070 = _S1274 > 0.0f;
                    }
                    else
                    {
                        _S1070 = false;
                    }
                    if(_S1070)
                    {
                        Shift _S1275 = Shift_x24init_0(_S1272, 1.0f);
                        _S726 = int(1);
                        ended_0 = _S1275;
                        spread_3 = _S1250;
                        width_4 = width_6;
                        throughput_7 = throughput_11;
                        b_5 = b_8;
                        break;
                    }
                    _S726 = int(1);
                    ended_0 = _S728;
                    spread_3 = _S1250;
                    width_4 = width_6;
                    throughput_7 = throughput_11;
                    b_5 = b_8;
                    break;
                }
                if(_S1196)
                {
                    Reservoir candidate_8 = _S1218;
                    uint _S1276 = extractBits_0(_S1218.path, 10U, 2U);
                    bool _S1277 = _S1276 == 1U;
                    if(_S1277)
                    {
                        float3  _S1278 = safeDivide(_S1272, chain_throughput_0);
                        (&candidate_8)->radiance = _S1278;
                    }
                    else
                    {
                        uint _S1279 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                        uint _S1280 = insertBits_0(_S1279, 2U, 10U, 2U);
                        (&candidate_8)->path = _S1280;
                    }
                    Reservoir _S1281 = withEnd(candidate_8, 0U, b_8, _S1272);
                    offer(sel_1, _S1281, _S1272 * make_float3 (scale_1) / make_float3 (density_3));
                    float _S1282 = survivalProbability(throughput_11, density_3);
                    uint _S1283 = stream(_S755, b_8 + 128U);
                    Random _S1284 = pcg(_S1283);
                    bool _S1285 = _S1282 < (_S1284.value);
                    if(_S1285)
                    {
                        _S1070 = true;
                    }
                    else
                    {
                        uint _S1286 = (fcptMaxBounces());
                        _S1070 = b_8 >= _S1286;
                    }
                    if(_S1070)
                    {
                        _S726 = int(1);
                        ended_0 = _S728;
                        spread_3 = _S1250;
                        width_4 = width_6;
                        throughput_7 = throughput_11;
                        b_5 = b_8;
                        break;
                    }
                    float _S1287 = density_3 * _S1282;
                    density_3 = _S1287;
                }
                else
                {
                }
                NEEVertex _S1288 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_2)->origin, _S727, (&ray_2)->origin);
                nee_vertex_0 = _S1288;
                uint _S1289 = stream(_S755, b_8);
                float3  _S1290 = isotropic_0(_S1289);
                (&ray_2)->unit_direction = _S1290;
                Vertex _S1291 = scatteredVertex_0(is_inside_5);
                prev_0 = _S1291;
                float _S1292 = (&prev_0)->pdf;
                FKRay _S1293 = ray_2;
                FKHit _S1294 = (fcptTraverseInstanceBVH((_S1293), (true), (4.294967296e+09f), (false), (_S1260), (false)));
                hit_1 = _S1294;
                b_7 = b_8;
                throughput_10 = throughput_11;
                spread_2 = _S1250;
                width_3 = width_6;
                sky_pdf_1 = _S1292;
            }
            if(_S726 != int(2))
            {
                spread_2 = spread_3;
                width_3 = width_4;
                throughput_10 = throughput_7;
                b_7 = b_5;
                _S1066 = true;
                break;
            }
            ended_0 = _S728;
            _S1066 = false;
            break;
        }
        if(_S1066)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1067 = b_7 == b_4;
        }
        else
        {
            _S1067 = false;
        }
        Reservoir _S1295 = chain_0;
        NEEVertex _S1296 = nee_vertex_0;
        Vertex _S1297 = prev_0;
        FKHit _S1298 = hit_1;
        uint _S1299 = filling_2;
        float3  _S1300 = scatter_in_0;
        float3  _S1301 = extinction_in_0;
        float3  _S1302 = weight_1;
        float3  _S1303 = glowed_0;
        for(;;)
        {
            bool _S1304 = (_S1298.instance_index) == 4294967295U;
            if(_S1304)
            {
                bool _S1305 = !_S1296.none;
                float _S1306 = _slang_select(_S1305, sky_pdf_1,0.0f);
                float _S1307 = escapeWeight_0(_S1306, (&ray_2)->unit_direction);
                float3  _S1308 = environment_0((&ray_2)->unit_direction, b_7, _S1297.lobe);
                float3  _S1309 = throughput_10 * _S1308;
                if(replay_1)
                {
                    bool _S1310 = b_7 == _S743;
                    if(_S1310)
                    {
                        _S1068 = _S732 == 3U;
                    }
                    else
                    {
                        _S1068 = false;
                    }
                    if(_S1068)
                    {
                        Shift _S1311 = Shift_x24init_0(_S1309 * make_float3 (_S1307) / make_float3 (r_3->jac), density_3 / r_3->jac);
                        arrived_end_0 = _S1311;
                        width_4 = width_3;
                        throughput_7 = throughput_10;
                        _S1068 = true;
                        break;
                    }
                    if(_S742)
                    {
                        _S1069 = _S739;
                    }
                    else
                    {
                        _S1069 = false;
                    }
                    if(_S1069)
                    {
                        _S1070 = b_7 == _S730;
                    }
                    else
                    {
                        _S1070 = false;
                    }
                    if(_S1070)
                    {
                        _S1071 = !_S1297.rough;
                    }
                    else
                    {
                        _S1071 = false;
                    }
                    if(_S1071)
                    {
                        Shift _S1312 = Shift_x24init_0(_S1309 * make_float3 (_S1307), 1.0f);
                        arrived_end_0 = _S1312;
                        width_4 = width_3;
                        throughput_7 = throughput_10;
                        _S1068 = true;
                        break;
                    }
                    arrived_end_0 = _S728;
                    width_4 = width_3;
                    throughput_7 = throughput_10;
                    _S1068 = true;
                    break;
                }
                Reservoir candidate_9 = _S1295;
                uint _S1313 = extractBits_0(_S1295.path, 10U, 2U);
                bool _S1314 = _S1313 == 1U;
                if(_S1314)
                {
                    uint _S1315 = extractBits_0(_S1295.path, 5U, 5U);
                    bool _S1316 = _S1315 == b_7;
                    float _S1317 = _slang_select(_S1316, 1.0f,_S1307);
                    float3  _S1318 = safeDivide(_S1309 * make_float3 (_S1317), chain_throughput_0);
                    (&candidate_9)->radiance = _S1318;
                }
                else
                {
                    if(_S1297.rough)
                    {
                        uint _S1319 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                        uint _S1320 = insertBits_0(_S1319, 3U, 10U, 2U);
                        uint _S1321 = insertBits_0(_S1320, _S1297.lobe, 15U, 2U);
                        uint _S1322 = _slang_select(_S1297.inside, 1U,0U);
                        uint _S1323 = insertBits_0(_S1321, _S1322, 20U, 1U);
                        (&candidate_9)->path = _S1323;
                        (&candidate_9)->jac = _S1297.pdf;
                        (&candidate_9)->dir = (&ray_2)->unit_direction;
                    }
                    else
                    {
                    }
                }
                float3  _S1324 = _S1309 * make_float3 (_S1307);
                Reservoir _S1325 = withEnd(candidate_9, 3U, b_7, _S1324);
                offer(sel_1, _S1325, _S1324 * make_float3 (scale_1) / make_float3 (density_3));
                arrived_end_0 = _S728;
                width_4 = width_3;
                throughput_7 = throughput_10;
                _S1068 = true;
                break;
            }
            float3  _S1326 = (&ray_2)->origin + make_float3 (_S1298.distance) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1326;
            bool _S1327 = _S1299 != 4294967295U;
            if(_S1327)
            {
                if(_S1196)
                {
                    float3  _S1328 = throughput_10 * _S1303 / make_float3 (density_3);
                    float3  _S1329 = sel_1->glow + _S1328;
                    sel_1->glow = _S1329;
                }
                else
                {
                }
                float3  _S1330 = throughput_10 * _S1302;
                throughput_7 = _S1330;
            }
            else
            {
                float3  _S1331 = flightWeight_0(_S1300, _S1301, (_S1300.x + _S1300.y + _S1300.z) / 3.0f, _S1298.distance, false);
                float3  _S1332 = throughput_10 * _S1331;
                throughput_7 = _S1332;
            }
            float _S1333 = width_3 + spread_2 * _S1298.distance;
            arrived_end_0 = _S728;
            width_4 = _S1333;
            _S1068 = false;
            break;
        }
        if(_S1068)
        {
            return arrived_end_0;
        }
        viewed_0 = _S1067;
        width_2 = width_4;
        throughput_2 = throughput_7;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1210 = b_7 + 1U;
        b_4 = _S1210;
        layer_0 = _S1209;
    }
    return _S728;
}

static __device__ Shift shift_0(Domain * dom_1, Reservoir * r_4)
{
    Selection _S1334 = (Selection{});
    Selection sel_2 = _S1334;
    bool _S1335 = (r_4->w) <= 0.0f;
    if(_S1335)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1336 = walk_0(dom_1, r_4, true, 0.0f, &sel_2);
    return _S1336;
}

__device__ static const FixedArray<float, 4>  HAIR_TILTS_0 = { {
    -2.0f, 1.0f, 4.0f, 0.0f
} };
__device__ static const FixedArray<float, 4>  HAIR_WIDTHS_0 = { {
    1.0f, 0.5f, 2.0f, 2.0f
} };
static __device__ float3  clamp_1(float3  x_15, float3  minBound_1, float3  maxBound_1)
{
    return min_1(max_0(x_15, minBound_1), maxBound_1);
}

static __device__ float3  tan_0(float3  x_16)
{
    float3  result_7;
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
        *_slang_vector_get_element_ptr(&result_7, i_9) = (F32_tan((_slang_vector_get_element(x_16, i_9))));
        i_9 = i_9 + int(1);
    }
    return result_7;
}

static __device__ float3  acos_0(float3  x_17)
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
        *_slang_vector_get_element_ptr(&result_8, i_10) = (F32_acos((_slang_vector_get_element(x_17, i_10))));
        i_10 = i_10 + int(1);
    }
    return result_8;
}

static __device__ float3  abs_0(float3  x_18)
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
        *_slang_vector_get_element_ptr(&result_9, i_11) = (F32_abs((_slang_vector_get_element(x_18, i_11))));
        i_11 = i_11 + int(1);
    }
    return result_9;
}

__device__ Random normal_distribution(uint state_3)
{
    Random _S1337 = pcg(state_3);
    Random _S1338 = pcg(_S1337.state);
    float _S1339 = 6.28318548202514648f * _S1337.value;
    float _S1340 = (F32_sqrt((-2.0f * clamp_0((F32_log((_S1338.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1338.state, _S1340 * (F32_cos((_S1339))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1341;
    (&_S1341)->state = state_4;
    (&_S1341)->value = value_2;
    return _S1341;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1342 = normal_distribution(state_5);
    Random _S1343 = normal_distribution(_S1342.state);
    Random _S1344 = normal_distribution(_S1343.state);
    float3  _S1345 = make_float3 (_S1342.value, _S1343.value, _S1344.value);
    float3  _S1346 = ((((_S1345)) * make_float3(rnorm3df(((_S1345)).x, ((_S1345)).y, ((_S1345)).z))));
    return RandomSphere_x24init_0(_S1344.state, _S1346);
}

struct RandomHemisphere
{
    uint state;
    float3  value;
};

static __device__ RandomHemisphere RandomHemisphere_x24init_0(uint state_6, float3  value_3)
{
    RandomHemisphere _S1347;
    (&_S1347)->state = state_6;
    (&_S1347)->value = value_3;
    return _S1347;
}

__device__ RandomHemisphere random_hemisphere(uint state_7, float3  normal_4)
{
    RandomSphere _S1348 = random_sphere(state_7);
    bool _S1349 = (dot_0(_S1348.value, normal_4)) > 0.0f;
    if(_S1349)
    {
        return RandomHemisphere_x24init_0(_S1348.state, _S1348.value);
    }
    else
    {
        float3  _S1350 = negate_0(_S1348.value);
        return RandomHemisphere_x24init_0(_S1348.state, _S1350);
    }
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_15)
{
    float3  _S1351 = p1_0 - p0_0;
    float3  _S1352 = p2_0 - p0_0;
    float2  _S1353 = uv1_0 - uv0_0;
    float2  _S1354 = uv2_0 - uv0_0;
    float _S1355 = _S1353.x;
    float _S1356 = _S1354.y;
    float _S1357 = _S1353.y;
    float _S1358 = _S1354.x;
    float _S1359 = _S1355 * _S1356 - _S1357 * _S1358;
    float _S1360 = 1.0f / _S1359;
    float3  t_1 = (_S1351 * make_float3 (_S1356) - _S1352 * make_float3 (_S1357)) * make_float3 (_S1360);
    float3  _S1361 = (_S1352 * make_float3 (_S1355) - _S1351 * make_float3 (_S1358)) * make_float3 (_S1360);
    float3  _S1362 = t_1 - n_15 * make_float3 (dot_0(n_15, t_1));
    float3  t_2 = ((((_S1362)) * make_float3(rnorm3df(((_S1362)).x, ((_S1362)).y, ((_S1362)).z))));
    bool _S1363 = (dot_0(cross_0(n_15, t_2), _S1361)) > 0.0f;
    float3  t_3;
    if(_S1363)
    {
        float3  _S1364 = negate_0(t_2);
        t_3 = _S1364;
    }
    else
    {
        t_3 = t_2;
    }
    float3  _S1365 = cross_0(n_15, t_3);
    return makeMatrix<float, 3, 3> (t_3, _S1365, n_15);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1366 = t1_0 - t0_0;
    float3  _S1367 = t2_2 - t0_0;
    float3  _S1368 = t2_2 - t1_0;
    float _S1369 = (F32_min((length_0(_S1366)), ((F32_min((length_0(_S1367)), (length_0(_S1368)))))));
    float3  _S1370 = make_float3 (distance_5(position_0, t0_0), distance_5(position_0, t1_0), distance_5(position_0, t2_2));
    float3  _S1371 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1372 = dot_0(geometry_n_5, _S1371);
    float3  _S1373 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1374 = dot_0(geometry_n_5, _S1373);
    float3  _S1375 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1376 = acos_0(abs_0(make_float3 (_S1372, _S1374, dot_0(geometry_n_5, _S1375))));
    float3  _S1377 = clamp_1(tan_0(_S1376), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_0(dot_0(_S1370 * _S1377, uvw_0), 0.0f, _S1369 * 0.125f);
}

__device__ float3  sampleHalfVector(float3  v_6, float3  n_i_5, float alpha_6, uint * random_state_15)
{
    float3  _S1378 = sampleMaterialHalfVector(v_6, n_i_5, alpha_6, AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f)), random_state_15);
    return _S1378;
}

__device__ float3  straightThrough(float3  dir_14, float3  n_16, BSDFMaterial material_16)
{
    float3  _S1379 = negate_0(dir_14);
    float _S1380 = sign_0(dot_0(n_16, _S1379));
    float3  _S1381 = n_16 * make_float3 (_S1380);
    AnisotropicFrame _S1382 = anisotropicFrame(material_16, _S1381);
    bool _S1383 = (_S1382.alphas.x) > 0.0f;
    if(_S1383)
    {
        float _S1384 = material_16.transmission * (1.0f - material_16.metallic);
        float3  _S1385 = negate_0(_S1381);
        float3  _S1386 = anisotropicLocal(dir_14, _S1382.tangent, _S1385);
        float _S1387 = anisotropicG1(_S1386, _S1382.alphas);
        return make_float3 (_S1384 * _S1387) * material_16.albedo;
    }
    float _S1388 = material_16.transmission * (1.0f - material_16.metallic);
    float _S1389 = material_16.roughness;
    float _S1390 = smithG1(_S1389 * _S1389, (F32_abs((dot_0(n_16, dir_14)))));
    return make_float3 (_S1388 * _S1390) * material_16.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_4, float3  out_dir_4, uint p_5, float w_2, float alpha_7, uint nt_0)
{
    uint _S1391 = p_5 % 4U;
    float _S1392 = w_2 * HAIR_WIDTHS_0[_S1391];
    float _S1393 = (F32_asin((clamp_0(dot_0(out_dir_4, t_4), -1.0f, 1.0f)))) - (F32_asin((clamp_0(dot_0(in_dir_11, t_4), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1391] * alpha_7;
    return ((F32_asinh((_S1393 / _S1392))) / (F32_asinh((3.14159274101257324f / _S1392))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_5, float3  out_dir_5, uint np_0)
{
    float3  _S1394 = worldToTangent(out_dir_5, t_5);
    float3  _S1395 = worldToTangent(in_dir_12, t_5);
    return (F32_frac((((F32_atan2((_S1394.z), (_S1394.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1395.z), (1.17549435082228751e-38f - _S1395.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_6, uint p_6, float row_0, float column_0, float w_3, float alpha_8, uint nt_1, uint np_1)
{
    float3  _S1396 = worldToTangent(in_dir_13, t_6);
    uint _S1397 = p_6 % 4U;
    float _S1398 = w_3 * HAIR_WIDTHS_0[_S1397];
    float _S1399 = (F32_asin((clamp_0(dot_0(in_dir_13, t_6), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1397] * alpha_8 + _S1398 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1398))))));
    float _S1400 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1396.z), (1.17549435082228751e-38f - _S1396.x)));
    float _S1401 = (F32_cos((_S1399)));
    float3  _S1402 = tangentToWorld(make_float3 (_S1401 * (F32_cos((_S1400))), (F32_sin((_S1399))), _S1401 * (F32_sin((_S1400)))), t_6);
    return _S1402;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_17, BSDFMaterial material_17, float coverage_1)
{
    float3  _S1403;
    if((material_17.ior) == 1.0f)
    {
        float3  _S1404 = straightThrough(toward_1, n_17, material_17);
        _S1403 = _S1404;
    }
    else
    {
        _S1403 = make_float3 (0.0f);
    }
    return _S1403 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_5, Shift shifted_0, float mis_0)
{
    Reservoir candidate_10 = r_5;
    float3  _S1405 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_10)->f = _S1405;
    float _S1406 = r_5.jac * shifted_0.jac;
    (&candidate_10)->jac = _S1406;
    offer(sel_3, candidate_10, make_float3 (mis_0) * shifted_0.f * make_float3 (r_5.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_6 = sel_4.r;
    float _S1407 = rgb_to_greyscale((&r_6)->f);
    float _S1408 = sel_4.w_sum / _S1407;
    bool _S1409 = _S1407 > 0.0f;
    float _S1410 = _slang_select(_S1409, _S1408,0.0f);
    (&r_6)->w = _S1410;
    (&r_6)->c = c_1;
    return r_6;
}

static __device__ float interpolate_0(float a_6, float b_9, float t_7)
{
    return a_6 + (b_9 - a_6) * t_7;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S1411 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S1411;
}

__device__ float2  temporalWeights(float c_2, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S1412 = c_2 * p_c_0;
    float _S1413 = c_t_0 * p_t_0;
    return make_float2 (_S1412 / (_S1412 + c_t_0 * g_previous_0), _S1413 / (_S1413 + c_2 * g_current_0));
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
    Domain _S1414 = dom_2;
    Reservoir _S1415 = r_7;
    Shift _S1416 = walk_0(&_S1414, &_S1415, replay_2, scale_2, sel_5);
    return _S1416;
}

__device__ Shift shift_hook(Domain dom_3, Reservoir r_8)
{
    Domain _S1417 = dom_3;
    Reservoir _S1418 = r_8;
    Shift _S1419 = shift_0(&_S1417, &_S1418);
    return _S1419;
}

#undef Matrix
