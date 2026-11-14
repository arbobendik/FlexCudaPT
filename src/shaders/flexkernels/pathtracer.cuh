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
    FKRay ray_0;
    if(_S4)
    {
        float3  _S6 = surface_0->geometry_n;
        bool _S7 = !((dot_0(surface_0->geometry_n, dir_1)) > 0.0f);
        if(_S7)
        {
            return make_float3 (0.0f);
        }
        FKRay _S8 = Ray_x24init_0(origin_1 + _S6 * make_float3 (dot_0(_S6, surface_0->smooth_n)) * make_float3 (surface_0->geometry_offset), dir_1);
        ray_0 = _S8;
    }
    else
    {
        bool _S9 = wrongSide_0(is_inside_1, false, dir_1, side_n_0);
        bool _S10 = is_inside_1 != _S9;
        float _S11 = surface_0->geometry_offset;
        float3  _S12 = surface_0->smooth_n;
        float3  _S13 = - surface_0->smooth_n;
        float3  _S14 = _slang_select(_S10, _S13,_S12);
        FKRay _S15 = Ray_x24init_0(origin_1 + make_float3 (_S11) * _S14, dir_1);
        ray_0 = _S15;
    }
    float3  _S16 = (fcptEnvMapSample((dir_1), (0U), (3U)));
    float3  _S17 = (fcptShadowTransmittance((ray_0), (4.294967296e+09f)));
    return _S16 * _S17;
}

static __device__ uint searchCDF_0(uint2  start_0, uint2  step_0, uint count_0, float u_0)
{
    uint _S18 = count_0 - 1U;
    uint low_0 = 0U;
    uint high_0 = _S18;
    for(;;)
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        uint _S19 = (low_0 + high_0) / 2U;
        float4  _S20 = (fcptEnvironmentCdf((start_0 + step_0 * make_uint2 (_S19))));
        bool _S21 = (_S20.x) > u_0;
        if(_S21)
        {
            high_0 = _S19;
        }
        else
        {
            uint _S22 = _S19 + 1U;
            low_0 = _S22;
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

static __device__ FKHit Hit_x24init_0(float2  uv_0, uint instance_index_0, uint triangle_index_0, uint is_point_light_0, float distance_0)
{
    FKHit _S23;
    (&_S23)->uv = uv_0;
    (&_S23)->instance_index = instance_index_0;
    (&_S23)->triangle_index = triangle_index_0;
    (&_S23)->is_point_light = is_point_light_0;
    (&_S23)->distance = distance_0;
    return _S23;
}

static __device__ float length_0(float3  x_1)
{
    return (F32_sqrt((dot_0(x_1, x_1))));
}

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

static __device__ float3  lightTransmittance_0(float3  origin_2, float3  smooth_n_0, float geometry_offset_0, float3  light_dir_0, ShadowContext * context_0, uint random_state_0, float traced_offset_0, FKHit * light_0)
{
    float3  _S24 = ((((light_dir_0)) * make_float3(rnorm3df(((light_dir_0)).x, ((light_dir_0)).y, ((light_dir_0)).z))));
    FKHit _S25 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S26 = context_0->opaque;
    bool front_0;
    bool surface_1;
    FKHit skip_0;
    FKRay ray_1;
    float l_0;
    if(_S26)
    {
        float3  _S27 = light_dir_0 + make_float3 (geometry_offset_0) * smooth_n_0;
        float3  _S28 = context_0->side;
        float _S29 = dot_0(context_0->side, _S27);
        bool _S30 = _S29 > 0.0f;
        bool _S31 = context_0->faced;
        if(_S31)
        {
            if(_S30)
            {
                bool _S32 = (dot_0(context_0->lift, _S27)) > 0.0f;
                if(_S32)
                {
                    front_0 = true;
                }
                else
                {
                    front_0 = geometry_offset_0 > 0.0f;
                }
            }
            else
            {
                front_0 = false;
            }
            front_0 = !front_0;
        }
        else
        {
            front_0 = false;
        }
        if(front_0)
        {
            return make_float3 (0.0f);
        }
        float _S33 = _slang_select(_S30, geometry_offset_0,0.0f);
        float3  _S34 = make_float3 (_S33) * context_0->lift;
        float3  _S35 = _S27 - _S34;
        bool _S36 = !_S31;
        if(_S36)
        {
            front_0 = !((dot_0(_S28, _S35) * _S29) > 0.0f);
        }
        else
        {
            front_0 = false;
        }
        if(front_0)
        {
            return make_float3 (0.0f);
        }
        float3  _S37 = origin_2 + _S34;
        float3  _S38 = ((((_S35)) * make_float3(rnorm3df(((_S35)).x, ((_S35)).y, ((_S35)).z))));
        FKRay _S39 = Ray_x24init_0(_S37, _S38);
        float _S40 = shadowLength(_S35);
        if(_S33 > 0.0f)
        {
            skip_0 = _S25;
        }
        else
        {
            skip_0 = context_0->own;
        }
        ray_1 = _S39;
        l_0 = _S40;
        front_0 = _S30;
        surface_1 = false;
    }
    else
    {
        bool _S41 = (dot_0(smooth_n_0, _S24)) < 0.0f;
        if(_S41)
        {
            return make_float3 (0.0f);
        }
        float3  _S42 = make_float3 (traced_offset_0) * smooth_n_0;
        FKRay _S43 = Ray_x24init_0(origin_2 + _S42, _S24);
        float _S44 = shadowLength(light_dir_0);
        bool _S45 = (dot_0(context_0->side, light_dir_0 + _S42)) > 0.0f;
        bool _S46 = context_0->surface;
        if(_S46)
        {
            front_0 = !context_0->fiber;
        }
        else
        {
            front_0 = false;
        }
        if(context_0->fiber)
        {
            skip_0 = context_0->own;
        }
        else
        {
            skip_0 = _S25;
        }
        bool _S47 = front_0;
        ray_1 = _S43;
        l_0 = _S44;
        front_0 = _S45;
        surface_1 = _S47;
    }
    float3  _S48 = context_0->extinction_behind;
    float3  _S49 = context_0->extinction_front;
    float3  _S50 = _slang_select(front_0, _S49,_S48);
    uint _S51 = context_0->fillings.x;
    uint _S52 = context_0->fillings.y;
    uint _S53 = _slang_select(front_0, _S52,_S51);
    float _S54 = l_0;
    float3  _S55 = (fcptShadowTransmittanceIn((ray_1), (_S54), (_S50), (_S53), (random_state_0), (context_0->depth), (context_0->lobe), (surface_1), (context_0->length), (context_0->width), (skip_0), (*light_0)));
    return _S55;
}

__device__ float sine(float c_0)
{
    return (F32_sqrt(((F32_max((1.0f - c_0 * c_0), (0.0f))))));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S56 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S57 = cos_a_0 > cos_b_0;
    float _S58 = _slang_select(_S57, 1.0f,_S56);
    return _S58;
}

__device__ float sinSubClamped(float sin_a_1, float cos_a_1, float sin_b_1, float cos_b_1)
{
    float _S59 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    bool _S60 = cos_a_1 > cos_b_1;
    float _S61 = _slang_select(_S60, 0.0f,_S59);
    return _S61;
}

__device__ float importance(LightNode node_0, float3  p_0, float3  normal_0)
{
    float3  _S62 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S63 = node_0.high - node_0.low;
    float3  _S64 = p_0 - _S62;
    float3  _S65 = ((((_S64)) * make_float3(rnorm3df(((_S64)).x, ((_S64)).y, ((_S64)).z))));
    float _S66 = dot_0(_S64, _S64);
    float _S67 = dot_0(_S63, _S63) / 4.0f;
    float _S68 = (F32_abs((dot_0(node_0.w, _S65))));
    float _S69 = sine(node_0.cos_theta_o);
    float _S70 = (F32_sqrt(((F32_max((1.0f - _S67 / _S66), (0.0f))))));
    bool _S71 = _S66 < _S67;
    float _S72 = _slang_select(_S71, -1.0f,_S70);
    float _S73 = sine(_S72);
    float _S74 = sine(_S68);
    float _S75 = cosSubClamped(_S74, _S68, _S69, node_0.cos_theta_o);
    float _S76 = sine(_S68);
    float _S77 = sinSubClamped(_S76, _S68, _S69, node_0.cos_theta_o);
    float _S78 = cosSubClamped(_S77, _S75, _S73, _S72);
    bool _S79 = _S78 <= 0.0f;
    if(_S79)
    {
        return 0.0f;
    }
    float _S80 = - dot_0(_S65, normal_0);
    float _S81 = node_0.phi * _S78 / (F32_max((_S66), (length_0(_S63) / 2.0f)));
    float _S82 = sine(_S80);
    float _S83 = cosSubClamped(_S82, _S80, _S73, _S72);
    bool _S84 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S85 = _slang_select(_S84, 1.0f,_S83);
    return (F32_max((_S81 * _S85), (0.0f)));
}

__device__ __forceinline__ float childShare(LightNode first_0, LightNode second_0, float3  p_1, float3  normal_1, uint child_0)
{
    float _S86 = importance(first_0, p_1, normal_1);
    float _S87 = importance(second_0, p_1, normal_1);
    float2  _S88 = make_float2 (_S86, _S87);
    float _S89 = _slang_vector_get_element(_S88, child_0) / (_S86 + _S87);
    bool _S90 = _slang_vector_get_element(_S88, child_0) > 0.0f;
    float _S91 = _slang_select(_S90, _S89,0.0f);
    return _S91;
}

__device__ float sphereDensity(float3  center_0, float radius_0, float3  p_2)
{
    float3  _S92 = center_0 - p_2;
    float _S93 = radius_0 * radius_0 / dot_0(_S92, _S92);
    bool _S94 = _S93 >= 1.0f;
    if(_S94)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S93)))) / (6.28318548202514648f * _S93);
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S95 = left_0.y;
    float _S96 = right_0.z;
    float _S97 = left_0.z;
    float _S98 = right_0.y;
    float _S99 = right_0.x;
    float _S100 = left_0.x;
    return make_float3 (_S95 * _S96 - _S97 * _S98, _S97 * _S99 - _S100 * _S96, _S100 * _S98 - _S95 * _S99);
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_0))));
}

static __device__ float lightPdf_0(float3  origin_3, float3  smooth_n_1, float3  start_1, uint j_0, float3  light_point_0)
{
    bool _S101 = j_0 == 4294967295U;
    if(_S101)
    {
        return 0.0f;
    }
    uint4  _S102 = (fcptLightTrail((j_0)));
    uint2  _S103 = uint2 {_S102.x, _S102.y};
    uint n_0 = 0U;
    uint2  trail_0 = _S103;
    float probability_1 = 1.0f;
    for(;;)
    {
        uint4  _S104 = (fcptLightNode((n_0)));
        if((_S104.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S105 = (fcptLightSecond((n_0)));
        uint _S106 = n_0 + 1U;
        LightNode _S107 = (fcptLightBounds((_S106)));
        LightNode _S108 = (fcptLightBounds((_S105)));
        uint _S109 = trail_0.x;
        uint _S110 = _S109 & 1U;
        float _S111 = childShare(_S107, _S108, origin_3, smooth_n_1, _S110);
        float probability_2 = probability_1 * _S111;
        bool _S112 = _S110 == 1U;
        uint _S113 = _slang_select(_S112, _S105,_S106);
        uint _S114 = trail_0.y;
        uint2  _S115 = make_uint2 ((_S109 >> 1U) | (_S114 << 31U), _S114 >> 1U);
        n_0 = _S113;
        trail_0 = _S115;
        probability_1 = probability_2;
    }
    bool _S116 = (fcptSlotLeaf((n_0), (j_0)));
    bool _S117 = !_S116;
    bool _S118;
    if(_S117)
    {
        _S118 = true;
    }
    else
    {
        LightNode _S119 = (fcptLightBounds((n_0)));
        float _S120 = importance(_S119, origin_3, smooth_n_1);
        _S118 = !(_S120 > 0.0f);
    }
    if(_S118)
    {
        _S118 = true;
    }
    else
    {
        bool _S121 = (dot_0(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S121)
        {
            _S118 = !((dot_0(smooth_n_1, light_point_0 - start_1)) > 0.0f);
        }
        else
        {
            _S118 = false;
        }
    }
    if(_S118)
    {
        return 0.0f;
    }
    uint4  _S122 = (fcptLightNode((n_0)));
    bool _S123 = (_S122.x) == 2U;
    if(_S123)
    {
        uint _S124 = _S122.y;
        FKLight _S125 = (fcptLight((_S124)));
        FKLight _S126 = (fcptLight((_S124)));
        float _S127 = sphereDensity(_S125.position, _S126.variance, start_1);
        return probability_1 * _S127;
    }
    uint _S128 = _S122.y;
    uint _S129 = (fcptTriangleOffset((_S128)));
    Matrix<float, 3, 3>  _S130 = (fcptWorldTriangle((_S128), (_S129 + _S122.z)));
    float _S131 = solidAngle(probability_1, cross_0(_S130.rows[int(1)] - _S130.rows[int(0)], _S130.rows[int(2)] - _S130.rows[int(0)]), light_point_0 - start_1);
    return _S131;
}

static __device__ float3  environment_0(float3  dir_2, uint depth_0, uint lobe_0)
{
    uint2  _S132 = (fcptEnvironmentMapSize());
    bool _S133 = (_S132.x) > 1U;
    bool _S134;
    if(_S133)
    {
        uint2  _S135 = (fcptEnvironmentMapSize());
        _S134 = (_S135.y) > 1U;
    }
    else
    {
        _S134 = false;
    }
    if(_S134)
    {
        float3  _S136 = (fcptEnvMapSample((dir_2), (depth_0), (lobe_0)));
        return _S136;
    }
    float3  _S137 = (fcptAmbient());
    return _S137;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S138 = (fcptEnvironmentCdfSize());
    bool _S139 = (_S138.x) > 1U;
    bool _S140;
    if(_S139)
    {
        uint2  _S141 = (fcptEnvironmentCdfSize());
        _S140 = (_S141.y) > 1U;
    }
    else
    {
        _S140 = false;
    }
    bool _S142 = !_S140;
    if(_S142)
    {
        return false;
    }
    uint2  _S143 = (fcptEnvironmentMapSize());
    bool _S144 = (_S143.x) > 1U;
    if(_S144)
    {
        uint2  _S145 = (fcptEnvironmentMapSize());
        _S140 = (_S145.y) > 1U;
    }
    else
    {
        _S140 = false;
    }
    return _S140;
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
    uint2  _S146 = (fcptEnvironmentCdfSize());
    uint2  _S147 = _S146 - make_uint2 (1U, 0U);
    float2  _S148 = make_float2 ((F32_atan2((- dir_3.z), (- dir_3.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_0(dir_3.y, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S149 = make_float2 ((float)_S147.x, (float)_S147.y);
    float2  _S150 = _S148 * _S149;
    uint2  _S151 = make_uint2 ((uint)_S150.x, (uint)_S150.y);
    uint2  _S152 = min_0(_S151, _S147 - make_uint2 (1U));
    float4  _S153 = (fcptEnvironmentCdf((_S152)));
    float _S154 = _S153.y;
    uint _S155 = _S147.x;
    float4  _S156 = (fcptEnvironmentCdf((make_uint2 (_S155, _S152.y))));
    float _S157 = _S154 * _S156.y;
    return _S157 * float(_S155 * _S147.y) / (19.73921012878417969f * length_1(float2 {dir_3.x, dir_3.z}));
}

static __device__ float escapeWeight_0(float pdf_0, float3  dir_4)
{
    bool _S158 = pdf_0 <= 0.0f;
    bool _S159;
    if(_S158)
    {
        _S159 = true;
    }
    else
    {
        bool _S160 = environmentMapped_0();
        _S159 = !_S160;
    }
    if(_S159)
    {
        return 1.0f;
    }
    float _S161 = environmentPdf_0(dir_4);
    return pdf_0 / (pdf_0 + _S161);
}

static __device__ float tracedOffset_0(float3  origin_4, float3  n_1, float offset_0)
{
    bool _S162 = !(offset_0 > 0.0f);
    if(_S162)
    {
        return 0.0f;
    }
    FKRay _S163 = Ray_x24init_0(origin_4, n_1);
    FKHit _S164 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    FKHit _S165 = (fcptTraverseInstanceBVH((_S163), (false), (offset_0), (true), (_S164), (false)));
    bool _S166 = (_S165.instance_index) != 4294967295U;
    float _S167 = _slang_select(_S166, 0.0f,offset_0);
    return _S167;
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
    uint _S168 = x_6 * 747796405U + 2891336453U;
    uint _S169 = ((_S168 >> ((_S168 >> 28U) + 4U)) ^ _S168) * 277803737U;
    return (_S169 >> 22U) ^ _S169;
}

static __device__ float random_0(uint * state_0)
{
    uint _S170 = hash(*state_0);
    *state_0 = _S170;
    return float((*state_0) >> int(8)) * 5.9604644775390625e-08f;
}

static __device__ Random Random_x24init_0(uint state_1, float value_0)
{
    Random _S171;
    (&_S171)->state = state_1;
    (&_S171)->value = value_0;
    return _S171;
}

__device__ Random pcg(uint state_2)
{
    uint _S172 = state_2;
    float value_1 = random_0(&_S172);
    return Random_x24init_0(_S172, value_1);
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
    float _S173;
    if(e_0 > 0.0f)
    {
        _S173 = 1.0f;
    }
    else
    {
        if(e_0 < 0.0f)
        {
            _S173 = -1.0f;
        }
        else
        {
            _S173 = 0.0f;
        }
    }
    return _S173;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S174;
    (&_S174)->tangent = tangent_0;
    (&_S174)->alphas = alphas_0;
    return _S174;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_2)
{
    float3  a_0 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S175 = (F32_abs((dot_0(n_2, a_0)))) > 0.9999847412109375f;
    float3  a_1;
    if(_S175)
    {
        float3  _S176 = make_float3 (1.0f, 0.0f, 0.0f);
        a_1 = _S176;
    }
    else
    {
        a_1 = a_0;
    }
    float3  _S177 = cross_0(n_2, a_1);
    float3  _S178 = ((((_S177)) * make_float3(rnorm3df(((_S177)).x, ((_S177)).y, ((_S177)).z))));
    float3  _S179 = cross_0(n_2, _S178);
    return make_float3 (v_0.x) * _S178 + make_float3 (v_0.y) * n_2 + make_float3 (v_0.z) * _S179;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_1, float3  n_i_0)
{
    float _S180 = material_1.roughness;
    float _S181 = _S180 * _S180;
    bool _S182 = (material_1.anisotropy) == 0.0f;
    bool _S183;
    if(_S182)
    {
        _S183 = true;
    }
    else
    {
        _S183 = !(_S181 > 0.0f);
    }
    if(_S183)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S184 = material_1.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_1.tangent));
    float3  _S185 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S186 = (dot_0(_S184, _S184)) > 0.0f;
    float3  _S187 = _slang_select(_S186, _S184,_S185);
    float3  _S188 = ((((_S187)) * make_float3(rnorm3df(((_S187)).x, ((_S187)).y, ((_S187)).z))));
    float _S189 = 6.28318548202514648f * material_1.anisotropic_rotation;
    float _S190 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_1.anisotropy))))));
    float _S191 = 1.0f / _S190;
    bool _S192 = (material_1.anisotropy) < 0.0f;
    float _S193 = _slang_select(_S192, _S191,_S190);
    return AnisotropicFrame_x24init_0(_S188 * make_float3 ((F32_cos((_S189)))) + cross_0(n_i_0, _S188) * make_float3 ((F32_sin((_S189)))), make_float2 (_S181 / _S193, _S181 * _S193));
}

__device__ float3  anisotropicLocal(float3  w_0, float3  t_0, float3  n_3)
{
    return make_float3 (dot_0(w_0, t_0), dot_0(w_0, cross_0(n_3, t_0)), dot_0(w_0, n_3));
}

static __device__ float unshared_0(float x_8)
{
    return x_8;
}

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_0, float U1_0, float U2_0)
{
    float3  _S194 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S195 = ((((_S194)) * make_float3(rnorm3df(((_S194)).x, ((_S194)).y, ((_S194)).z))));
    float _S196 = _S195.x;
    float _S197 = _S195.y;
    float _S198 = _S196 * _S196 + _S197 * _S197;
    float3  _S199;
    if(_S198 > 0.0f)
    {
        float3  _S200 = make_float3 (- _S197, _S196, 0.0f);
        float _S201 = (rsqrtf((_S198)));
        _S199 = _S200 * make_float3 (_S201);
    }
    else
    {
        _S199 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S202 = cross_0(_S195, _S199);
    float _S203 = (F32_sqrt((U1_0)));
    float _S204 = 6.28318548202514648f * U2_0;
    float _S205 = _S203 * (F32_cos((_S204)));
    float t2_0 = _S203 * (F32_sin((_S204)));
    float _S206 = 0.5f * (1.0f + _S195.z);
    float t2_1 = (1.0f - _S206) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S205 * _S205)))))) + _S206 * t2_0;
    float3  _S207 = make_float3 (_S205) * _S199 + make_float3 (t2_1) * _S202;
    float _S208 = unshared_0(_S205);
    float _S209 = unshared_0(_S205);
    float3  _S210 = _S207 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S208 * _S209 - t2_1 * t2_1))))))) * _S195;
    float3  _S211 = make_float3 (alpha_0 * _S210.x, alpha_0 * _S210.y, (F32_max((0.0f), (_S210.z))));
    float3  _S212 = ((((_S211)) * make_float3(rnorm3df(((_S211)).x, ((_S211)).y, ((_S211)).z))));
    return _S212;
}

__device__ float3  sampleAnisotropicVNDF(float3  Ve_1, float2  alphas_1, float U1_1, float U2_1)
{
    float _S213 = alphas_1.x;
    float _S214 = alphas_1.y;
    float3  _S215 = make_float3 (_S213 * Ve_1.x, _S214 * Ve_1.y, Ve_1.z);
    float3  _S216 = ((((_S215)) * make_float3(rnorm3df(((_S215)).x, ((_S215)).y, ((_S215)).z))));
    float3  _S217 = sampleGGXVNDF(_S216, 1.0f, U1_1, U2_1);
    float3  _S218 = make_float3 (_S213 * _S217.x, _S214 * _S217.y, _S217.z);
    float3  _S219 = ((((_S218)) * make_float3(rnorm3df(((_S218)).x, ((_S218)).y, ((_S218)).z))));
    return _S219;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_4)
{
    float3  a_2 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S220 = (F32_abs((dot_0(n_4, a_2)))) > 0.9999847412109375f;
    float3  a_3;
    if(_S220)
    {
        float3  _S221 = make_float3 (1.0f, 0.0f, 0.0f);
        a_3 = _S221;
    }
    else
    {
        a_3 = a_2;
    }
    float3  _S222 = cross_0(n_4, a_3);
    float3  _S223 = ((((_S222)) * make_float3(rnorm3df(((_S222)).x, ((_S222)).y, ((_S222)).z))));
    float3  _S224 = cross_0(n_4, _S223);
    return make_float3 (dot_0(v_1, _S223), dot_0(v_1, n_4), dot_0(v_1, _S224));
}

__device__ __forceinline__ float3  sampleMaterialHalfVector(float3  v_2, float3  n_i_1, float alpha_1, AnisotropicFrame frame_0, uint * random_state_1)
{
    Random _S225 = pcg(*random_state_1);
    Random _S226 = pcg(_S225.state);
    *random_state_1 = _S226.state;
    bool _S227 = (frame_0.alphas.x) > 0.0f;
    if(_S227)
    {
        float3  _S228 = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        float3  _S229 = sampleAnisotropicVNDF(_S228, frame_0.alphas, _S225.value, _S226.value);
        return make_float3 (_S229.x) * frame_0.tangent + make_float3 (_S229.y) * cross_0(n_i_1, frame_0.tangent) + make_float3 (_S229.z) * n_i_1;
    }
    float3  _S230 = worldToTangent(v_2, n_i_1);
    float3  _S231 = sampleGGXVNDF(float3 {_S230.x, _S230.z, _S230.y}, alpha_1, _S225.value, _S226.value);
    float3  _S232 = float3 {_S231.x, _S231.z, _S231.y};
    float3  _S233 = tangentToWorld(_S232, n_i_1);
    return _S233;
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

static __device__ float3  refract_0(float3  i_1, float3  n_5, float eta_0)
{
    float _S234 = dot_0(n_5, i_1);
    float _S235 = 1.0f - eta_0 * eta_0 * (1.0f - _S234 * _S234);
    if(_S235 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_1 - make_float3 (eta_0 * _S234 + (F32_sqrt((_S235)))) * n_5;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S236 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S237 = eta_i_0 / eta_o_0 * _S236;
    bool _S238 = _S237 < 1.0f;
    float kr_0;
    if(_S238)
    {
        float _S239 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S237 * _S237))))));
        float _S240 = eta_o_0 * cos_theta_0;
        float _S241 = eta_i_0 * _S239;
        float _S242 = (_S240 - _S241) / (_S240 + _S241);
        float _S243 = eta_i_0 * cos_theta_0;
        float _S244 = eta_o_0 * _S239;
        float _S245 = (_S243 - _S244) / (_S243 + _S244);
        float _S246 = (_S242 * _S242 + _S245 * _S245) / 2.0f;
        kr_0 = _S246;
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
    float _S247 = (F32_sqrt((0.05000000074505806f)));
    float _S248 = clamp_0((F32_sqrt(((F32_max((mu_0), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
    float _S249 = (clamp_0((F32_sqrt(((F32_max((r_0), (0.0f)))))), _S247, 1.0f) - _S247) / (1.0f - _S247) * 23.0f;
    uint _S250 = (U32_min((uint(_S248)), (22U)));
    uint _S251 = (U32_min((uint(_S249)), (22U)));
    float _S252 = _S248 - float(_S250);
    float _S253 = _S249 - float(_S251);
    uint _S254 = _S250 * 24U + _S251;
    uint _S255 = _S254 + 24U;
    float _S256 = SHEEN_ALBEDO_0[_S254] + (SHEEN_ALBEDO_0[_S255] - SHEEN_ALBEDO_0[_S254]) * _S252;
    uint _S257 = _S254 + 1U;
    float _S258 = SHEEN_ALBEDO_0[_S257] + (SHEEN_ALBEDO_0[_S255 + 1U] - SHEEN_ALBEDO_0[_S257]) * _S252;
    return (F32_exp((_S256 + (_S258 - _S256) * _S253)));
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

__device__ float anisotropicG1(float3  w_1, float2  alphas_2)
{
    float _S259 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S259 / (_S259 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S259)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S260 = alphas_3.x;
    float _S261 = h_0.x / _S260;
    float _S262 = alphas_3.y;
    float _S263 = h_0.y / _S262;
    float _S264 = h_0.z;
    float _S265 = _S261 * _S261 + _S263 * _S263 + _S264 * _S264;
    return 1.0f / (F32_max((3.14159274101257324f * _S260 * _S262 * _S265 * _S265), (1.17549435082228751e-38f)));
}

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_0, float3  refracted_1, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_0, float3  sheen_0, float3  view_0, float3  tangent_1, float2  alphas_4, float visible_0)
{
    BSDFLobes _S266;
    (&_S266)->v_dot_h = v_dot_h_0;
    (&_S266)->n_dot_h = n_dot_h_0;
    (&_S266)->refracted = refracted_1;
    (&_S266)->F = F_0;
    (&_S266)->F_greyscale = F_greyscale_0;
    (&_S266)->reflect_weight = reflect_weight_0;
    (&_S266)->diffuse_weight = diffuse_weight_0;
    (&_S266)->refract_weight = refract_weight_0;
    (&_S266)->p_diffuse = p_diffuse_0;
    (&_S266)->p_reflect = p_reflect_0;
    (&_S266)->p_refract = p_refract_0;
    (&_S266)->translucent_share = translucent_share_0;
    (&_S266)->sheen = sheen_0;
    (&_S266)->view = view_0;
    (&_S266)->tangent = tangent_1;
    (&_S266)->alphas = alphas_4;
    (&_S266)->visible = visible_0;
    return _S266;
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_0, float3  v_3, float3  n_i_2, float3  ggx_n_0, BSDFMaterial material_2, float eta_i_1, float eta_o_1, AnisotropicFrame frame_1)
{
    float _S267 = dot_0(ggx_n_0, v_3);
    float _S268 = dot_0(n_i_2, ggx_n_0);
    float _S269 = eta_i_1 / eta_o_1;
    float3  _S270 = refract_0(in_dir_0, ggx_n_0, _S269);
    float3  _S271 = ((((_S270)) * make_float3(rnorm3df(((_S270)).x, ((_S270)).y, ((_S270)).z))));
    float _S272 = (F32_min(((F32_sqrt((material_2.specular_level))) * (F32_abs((eta_i_1 - eta_o_1))) / (eta_i_1 + eta_o_1)), (0.9999847412109375f)));
    float _S273 = _S272 * _S272;
    float _S274 = (1.0f + _S272) / (1.0f - _S272);
    float _S275 = (F32_abs((_S267)));
    bool _S276 = eta_i_1 > eta_o_1;
    float sheen_component_0;
    if(_S276)
    {
        sheen_component_0 = _S274;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float visible_1;
    if(_S276)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S274;
    }
    float _S277 = fresnel(_S275, sheen_component_0, visible_1);
    bool _S278 = (eta_i_1 * eta_i_1 * (1.0f - _S267 * _S267)) >= (eta_o_1 * eta_o_1);
    float3  _S279;
    if(_S278)
    {
        _S279 = make_float3 (1.0f);
    }
    else
    {
        float3  _S280 = material_2.specular_tint * make_float3 (_S273);
        _S279 = _S280 + (make_float3 (1.0f) - _S280) * make_float3 (_S277 - _S273) / make_float3 (1.0f - _S273);
    }
    float3  _S281 = make_float3 (1.0f);
    float3  _S282 = make_float3 (0.0f);
    float _S283 = rgb_to_greyscale(material_2.sheen);
    bool _S284 = _S283 > 0.0f;
    float3  scale_0;
    float3  sheen_1;
    float3  view_1;
    if(_S284)
    {
        float _S285 = sheenAlbedo(dot_0(n_i_2, v_3), material_2.sheen_roughness);
        float _S286 = (F32_min((_S285), (1.0f)));
        float3  _S287 = make_float3 (1.0f) - material_2.sheen * make_float3 (_S286);
        float _S288 = rgb_to_greyscale(material_2.sheen);
        float _S289 = _S288 * _S286;
        float3  _S290 = material_2.sheen / make_float3 ((F32_max((_S285), (1.0f))));
        scale_0 = _S287;
        sheen_component_0 = _S289;
        sheen_1 = _S290;
        view_1 = v_3;
    }
    else
    {
        scale_0 = _S281;
        sheen_component_0 = 0.0f;
        sheen_1 = _S282;
        view_1 = _S282;
    }
    float3  _S291 = mix_0(_S279, material_2.albedo, material_2.metallic);
    float3  F_1 = _S291 * scale_0;
    float _S292 = rgb_to_greyscale(F_1);
    float _S293 = 1.0f - material_2.metallic;
    float3  _S294 = make_float3 (1.0f) - _S279;
    float3  _S295 = make_float3 ((1.0f - material_2.transmission) * _S293) * _S294 * scale_0;
    float3  _S296 = make_float3 (material_2.transmission * _S293) * _S294 * scale_0;
    float _S297 = (F32_max((_S292), (0.0f)));
    float _S298 = rgb_to_greyscale(_S295);
    float _S299 = (F32_max((_S298), (0.0f)));
    float _S300 = rgb_to_greyscale(_S296);
    float _S301 = sign_0(length_0(_S271));
    float _S302 = (F32_max((_S300 * _S301), (0.0f)));
    float _S303 = _S297 + _S299 + _S302 + sheen_component_0;
    float _S304 = 1.0f / (F32_max((_S303), (0.0000152587890625f)));
    float _S305 = (_S299 + sheen_component_0) * _S304;
    float _S306 = _S297 * _S304;
    float _S307 = _S302 * _S304;
    bool _S308 = (frame_1.alphas.x) > 0.0f;
    if(_S308)
    {
        float3  _S309 = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        float _S310 = anisotropicG1(_S309, frame_1.alphas);
        float3  _S311 = anisotropicLocal(ggx_n_0, frame_1.tangent, n_i_2);
        float _S312 = anisotropicD(_S311, frame_1.alphas);
        float _S313 = _S310 * _S312;
        visible_1 = _S313;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S267, _S268, _S271, F_1, _S292, 1.0f, _S295, _S296, _S305, _S306, _S307, 0.0f, sheen_1, view_1, frame_1.tangent, frame_1.alphas, visible_1);
}

__device__ float translucentShare(BSDFMaterial material_3)
{
    float _S314 = rgb_to_greyscale(material_3.translucent);
    float _S315 = rgb_to_greyscale(material_3.albedo);
    float _S316 = _S314 / (_S315 + _S314);
    bool _S317 = _S314 > 0.0f;
    float _S318 = _slang_select(_S317, _S316,0.0f);
    return _S318;
}

__device__ float smithG1(float alpha_2, float n_dot_x_0)
{
    float _S319 = alpha_2 * alpha_2;
    float _S320 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S319 + (1.0f - _S319) * n_dot_x_0 * n_dot_x_0))));
    bool _S321 = alpha_2 > 0.0f;
    float _S322 = _slang_select(_S321, _S320,1.0f);
    return _S322;
}

__device__ float trowbridgeReitz(float alpha_3, float n_dot_h_1)
{
    float _S323 = alpha_3 * alpha_3;
    float _S324 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S323 * n_dot_h_1 * n_dot_h_1;
    return _S323 / (F32_max((3.14159274101257324f * _S324 * _S324), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, BSDFLobes lobes_0, float eta_i_2, float eta_o_2, uint lobe_1)
{
    bool _S325 = lobe_1 == 0U;
    if(_S325)
    {
        float _S326 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        float _S327 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
        float _S328 = 1.0f - lobes_0.translucent_share;
        bool _S329 = n_i_dot_l_0 < 0.0f;
        float _S330 = _slang_select(_S329, lobes_0.translucent_share,_S328);
        float _S331 = _S327 * _S330;
        bool _S332 = (lobes_0.translucent_share) > 0.0f;
        float _S333 = _slang_select(_S332, _S331,_S326);
        bool _S334 = n_i_dot_v_0 > 0.0f;
        float _S335 = _slang_select(_S334, _S333,0.0f);
        return _S335;
    }
    float _S336 = smithG1(alpha_4, n_i_dot_v_0);
    float _S337 = _S336 * lobes_0.v_dot_h;
    float _S338 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    float _S339 = _S337 * _S338 / n_i_dot_v_0;
    bool _S340 = alpha_4 > 0.0f;
    bool _S341;
    if(_S340)
    {
        _S341 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S341 = false;
    }
    if(_S341)
    {
        _S341 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S341 = false;
    }
    if(_S341)
    {
        _S341 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S341 = false;
    }
    float _S342 = _slang_select(_S341, _S339,0.0f);
    bool _S343 = (lobes_0.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S343)
    {
        float _S344 = lobes_0.visible * lobes_0.v_dot_h / n_i_dot_v_0;
        bool _S345 = (lobes_0.v_dot_h) > 0.0f;
        if(_S345)
        {
            _S341 = (lobes_0.n_dot_h) > 0.0f;
        }
        else
        {
            _S341 = false;
        }
        if(_S341)
        {
            _S341 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S341 = false;
        }
        float _S346 = _slang_select(_S341, _S344,0.0f);
        pdf_h_0 = _S346;
    }
    else
    {
        pdf_h_0 = _S342;
    }
    bool _S347 = lobe_1 == 1U;
    if(_S347)
    {
        float _S348 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        float _S349 = lobes_0.p_refract * pdf_h_0 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S348 * _S348);
        bool _S350 = eta_i_2 != eta_o_2;
        if(_S350)
        {
            _S341 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S341 = false;
        }
        float _S351 = _slang_select(_S341, _S349,0.0f);
        return _S351;
    }
    float _S352 = lobes_0.p_reflect * pdf_h_0 / (4.0f * lobes_0.v_dot_h);
    bool _S353 = pdf_h_0 > 0.0f;
    float _S354 = _slang_select(_S353, _S352,0.0f);
    return _S354;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_0, uint random_state_2, bool refracted_2, uint lobe_2, float pdf_1)
{
    SampleBSDF _S355;
    (&_S355)->unit_direction = unit_direction_1;
    (&_S355)->throughput = throughput_0;
    (&_S355)->random_state = random_state_2;
    (&_S355)->refracted = refracted_2;
    (&_S355)->lobe = lobe_2;
    (&_S355)->pdf = pdf_1;
    return _S355;
}

__device__ float sheenBRDF(float3  l_1, float3  v_4, float3  n_6, float r_1)
{
    float _S356 = 1.0f / (F32_max((r_1), (0.05000000074505806f)));
    float3  _S357 = l_1 + v_4;
    float3  _S358 = ((((_S357)) * make_float3(rnorm3df(((_S357)).x, ((_S357)).y, ((_S357)).z))));
    float _S359 = dot_0(n_6, _S358);
    float _S360 = (F32_max((dot_0(n_6, l_1)), (0.0f)));
    float _S361 = (F32_max((dot_0(n_6, v_4)), (0.0f)));
    return (2.0f + _S356) * (F32_pow(((F32_max((1.0f - _S359 * _S359), (0.0f)))), (0.5f * _S356))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S360 + _S361 - _S360 * _S361)), (0.0000152587890625f)));
}

__device__ __forceinline__ float3  lobeThroughput(float3  l_2, float3  n_i_3, float alpha_5, BSDFMaterial material_4, BSDFLobes lobes_1, uint lobe_3)
{
    bool _S362 = lobe_3 == 0U;
    if(_S362)
    {
        bool _S363 = (dot_0(n_i_3, l_2)) < 0.0f;
        float3  _S364 = _slang_select(_S363, material_4.translucent,material_4.albedo);
        float _S365 = 1.0f - lobes_1.translucent_share;
        float _S366 = _slang_select(_S363, lobes_1.translucent_share,_S365);
        float3  _S367 = _S364 / make_float3 (_S366);
        bool _S368 = (lobes_1.translucent_share) > 0.0f;
        float3  _S369 = _slang_select(_S368, _S367,material_4.albedo);
        float _S370 = rgb_to_greyscale(material_4.sheen);
        bool _S371 = _S370 > 0.0f;
        bool _S372;
        if(_S371)
        {
            _S372 = !_S363;
        }
        else
        {
            _S372 = false;
        }
        if(_S372)
        {
            float3  _S373 = lobes_1.diffuse_weight * _S369;
            float3  _S374 = lobes_1.sheen * make_float3 (3.14159274101257324f);
            float _S375 = sheenBRDF(l_2, lobes_1.view, n_i_3, material_4.sheen_roughness);
            float3  _S376 = _S374 * make_float3 (_S375);
            float _S377 = _slang_select(_S368, _S365,1.0f);
            return (_S373 + _S376 / make_float3 (_S377)) / make_float3 (lobes_1.p_diffuse);
        }
        return lobes_1.diffuse_weight * _S369 / make_float3 (lobes_1.p_diffuse);
    }
    bool _S378 = lobe_3 == 1U;
    float G1_l_0;
    if(_S378)
    {
        float _S379 = - dot_0(n_i_3, l_2);
        float _S380 = smithG1(alpha_5, (F32_max((_S379), (0.0f))));
        bool _S381 = (lobes_1.alphas.x) > 0.0f;
        if(_S381)
        {
            float3  _S382 = negate_0(n_i_3);
            float3  _S383 = anisotropicLocal(l_2, lobes_1.tangent, _S382);
            float _S384 = anisotropicG1(_S383, lobes_1.alphas);
            G1_l_0 = _S384;
        }
        else
        {
            G1_l_0 = _S380;
        }
        return lobes_1.refract_weight * make_float3 (G1_l_0) * material_4.albedo / make_float3 (lobes_1.p_refract);
    }
    float _S385 = dot_0(n_i_3, l_2);
    float _S386 = smithG1(alpha_5, (F32_max((_S385), (0.0f))));
    bool _S387 = (lobes_1.alphas.x) > 0.0f;
    if(_S387)
    {
        float3  _S388 = anisotropicLocal(l_2, lobes_1.tangent, n_i_3);
        float _S389 = anisotropicG1(_S388, lobes_1.alphas);
        G1_l_0 = _S389;
    }
    else
    {
        G1_l_0 = _S386;
    }
    return make_float3 (lobes_1.reflect_weight * G1_l_0) * lobes_1.F / make_float3 (lobes_1.p_reflect);
}

__device__ __forceinline__ SampleBSDF connectBSDF(float3  in_dir_1, float3  out_dir_0, float3  n_7, BSDFMaterial material_5, float eta_i_3, float eta_o_3, uint lobe_4, uint random_init_0)
{
    uint random_state_3 = random_init_0;
    float3  _S390 = negate_0(in_dir_1);
    float _S391 = dot_0(n_7, _S390);
    float _S392 = sign_0(_S391);
    float3  _S393 = n_7 * make_float3 (_S392);
    float _S394 = material_5.roughness;
    float _S395 = _S394 * _S394;
    AnisotropicFrame _S396 = anisotropicFrame(material_5, _S393);
    float3  _S397 = _S390 + out_dir_0;
    float3  _S398 = ((((_S397)) * make_float3(rnorm3df(((_S397)).x, ((_S397)).y, ((_S397)).z))));
    bool _S399 = lobe_4 == 0U;
    float3  ggx_n_1;
    if(_S399)
    {
        float3  _S400 = sampleMaterialHalfVector(_S390, _S393, _S395, _S396, &random_state_3);
        ggx_n_1 = _S400;
    }
    else
    {
        bool _S401 = lobe_4 == 1U;
        if(_S401)
        {
            float3  _S402 = negate_0(make_float3 (eta_i_3) * _S390 + make_float3 (eta_o_3) * out_dir_0);
            float3  _S403 = ((((_S402)) * make_float3(rnorm3df(((_S402)).x, ((_S402)).y, ((_S402)).z))));
            float _S404 = sign_0(dot_0(_S402, _S393));
            float3  _S405 = _S403 * make_float3 (_S404);
            ggx_n_1 = _S405;
        }
        else
        {
            ggx_n_1 = _S398;
        }
    }
    BSDFLobes _S406 = bsdfLobes(in_dir_1, _S390, _S393, ggx_n_1, material_5, eta_i_3, eta_o_3, _S396);
    BSDFLobes lobes_2 = _S406;
    float _S407 = translucentShare(material_5);
    (&lobes_2)->translucent_share = _S407;
    float _S408 = lobeDensity(dot_0(_S393, out_dir_0), dot_0(out_dir_0, ggx_n_1), (F32_abs((_S391))), _S395, lobes_2, eta_i_3, eta_o_3, lobe_4);
    bool _S409 = !(_S408 > 0.0f);
    if(_S409)
    {
        float3  _S410 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S410, _S410, 0U, false, 0U, 0.0f);
    }
    float3  _S411 = lobeThroughput(out_dir_0, _S393, _S395, material_5, lobes_2, lobe_4);
    return SampleBSDF_x24init_0(out_dir_0, _S411, random_state_3, lobe_4 == 1U, lobe_4, _S408);
}

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_2, float3  dir_5, float3  n_8, BSDFMaterial material_6, float eta_i_4, float eta_o_4, bool refracted_3, float pdf_2, bool power_0, uint random_state_4)
{
    float3  _S412 = make_float3 (0.0f);
    uint lobe_5 = 0U;
    float3  f_0 = _S412;
    for(;;)
    {
        if(lobe_5 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S413 = lobe_5 == 0U;
        if(_S413)
        {
        }
        bool _S414;
        if(_S413)
        {
            float _S415 = rgb_to_greyscale(material_6.translucent);
            _S414 = _S415 > 0.0f;
        }
        else
        {
            _S414 = false;
        }
        bool _S416;
        if(_S414)
        {
            float _S417 = dot_0(n_8, dir_5);
            float3  _S418 = negate_0(in_dir_2);
            _S416 = ((_S417 * dot_0(n_8, _S418)) < 0.0f) == refracted_3;
        }
        else
        {
            _S416 = (lobe_5 == 1U) == refracted_3;
        }
        float3  f_1;
        if(_S416)
        {
            SampleBSDF _S419 = connectBSDF(in_dir_2, dir_5, n_8, material_6, eta_i_4, eta_o_4, lobe_5, random_state_4);
            bool _S420 = (_S419.pdf) > 0.0f;
            if(_S420)
            {
                if(power_0)
                {
                    float _S421 = _S419.pdf / pdf_2;
                    float3  f_2 = f_0 + _S419.throughput * make_float3 (_S419.pdf) / make_float3 (pdf_2 * (1.0f + _S421 * _S421));
                    f_1 = f_2;
                }
                else
                {
                    float3  f_3 = f_0 + _S419.throughput * make_float3 (_S419.pdf) / make_float3 (_S419.pdf + pdf_2);
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

__device__ float3  skyBSDF(float3  in_dir_3, float3  dir_6, FKSurface surface_2, float3  side_n_1, float2  eta_1, bool is_inside_2, float pdf_3, uint random_state_5)
{
    bool _S422 = wrongSide_0(is_inside_2, false, dir_6, side_n_1);
    float3  _S423 = neeBSDF(in_dir_3, dir_6, surface_2.smooth_n, surface_2.material, eta_1.x, eta_1.y, _S422, pdf_3, false, random_state_5);
    return _S423;
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
    SkySample _S424;
    (&_S424)->dir = dir_7;
    (&_S424)->radiance = radiance_0;
    (&_S424)->color = color_0;
    (&_S424)->random_state = random_state_6;
    return _S424;
}

static __device__ SkySample sampleSky_0(FKRay * ray_2, FKSurface * surface_3, float3  side_n_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0)
{
    uint2  _S425 = (fcptEnvironmentCdfSize());
    uint2  _S426 = make_uint2 (1U, 0U);
    uint2  _S427 = _S425 - _S426;
    Random _S428 = pcg(init_random_state_0);
    Random _S429 = pcg(_S428.state);
    Random _S430 = pcg(_S429.state);
    Random _S431 = pcg(_S430.state);
    uint _S432 = _S427.x;
    uint _S433 = searchCDF_0(make_uint2 (_S432, 0U), make_uint2 (0U, 1U), _S427.y, _S428.value);
    uint _S434 = searchCDF_0(make_uint2 (0U, _S433), _S426, _S432, _S429.value);
    float2  _S435 = make_float2 ((float)_S427.x, (float)_S427.y);
    float2  _S436 = (make_float2 (float(_S434), float(_S433)) + make_float2 (_S430.value, _S431.value)) / _S435 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S437 = _S436.y;
    float _S438 = (F32_sin((_S437)));
    float _S439 = _S436.x;
    float3  _S440 = make_float3 (_S438 * (F32_cos((_S439))), (F32_cos((_S437))), _S438 * (F32_sin((_S439))));
    float _S441 = environmentPdf_0(_S440);
    float3  _S442 = skyBSDF(ray_2->unit_direction, _S440, *surface_3, side_n_2, eta_2, is_inside_3, _S441, lobe_state_0);
    bool _S443 = !(_S441 > 0.0f);
    bool _S444;
    if(_S443)
    {
        _S444 = true;
    }
    else
    {
        _S444 = all_0(_S442 == make_float3 (0.0f));
    }
    if(_S444)
    {
        float3  _S445 = make_float3 (0.0f);
        return SkySample_x24init_0(_S440, _S445, _S445, _S431.state);
    }
    float3  _S446 = skyRadiance_0(ray_2->origin, surface_3, side_n_2, is_inside_3, _S440);
    return SkySample_x24init_0(_S440, _S446, _S442 * _S446, _S431.state);
}

struct TreeSample
{
    float3  dir;
    float3  radiance;
    float density;
    uint random_state;
};

static __device__ float3  hairLight_0(FKSurface * surface_4, float3  in_dir_4, TreeSample * light_1, bool competing_0)
{
    SampleBSDF _S447 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_4), (light_1->dir)));
    float3  _S448 = _S447.throughput * make_float3 (_S447.pdf);
    float _S449 = light_1->density;
    float _S450 = 1.0f + _S447.pdf * _S447.pdf / (light_1->density * light_1->density);
    bool _S451;
    if(competing_0)
    {
        _S451 = _S449 > 0.0f;
    }
    else
    {
        _S451 = false;
    }
    float _S452 = _slang_select(_S451, _S450,1.0f);
    return _S448 / make_float3 (_S452) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_8, float3  radiance_1, float density_0, uint random_state_7)
{
    TreeSample _S453;
    (&_S453)->dir = dir_8;
    (&_S453)->radiance = radiance_1;
    (&_S453)->density = density_0;
    (&_S453)->random_state = random_state_7;
    return _S453;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_3, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S454 = importance(first_1, p_3, normal_3);
    float _S455 = importance(second_1, p_3, normal_3);
    float2  _S456 = make_float2 (_S454, _S455);
    bool _S457 = _S454 == 0.0f;
    bool _S458;
    if(_S457)
    {
        _S458 = _S455 == 0.0f;
    }
    else
    {
        _S458 = false;
    }
    if(_S458)
    {
        return 2U;
    }
    float _S459 = _S454 + _S455;
    bool _S460 = _S455 > 0.0f;
    if(_S460)
    {
        _S458 = (*pick_0 * _S459) >= _S454;
    }
    else
    {
        _S458 = false;
    }
    uint _S461 = uint(_S458);
    float _S462 = (F32_min(((*pick_0 * _S459 - float(_S461) * _S454) / _slang_vector_get_element(_S456, _S461)), (0.99999994039535522f)));
    *pick_0 = _S462;
    float _S463 = *probability_3 * (_slang_vector_get_element(_S456, _S461) / _S459);
    *probability_3 = _S463;
    return _S461;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_4, float u1_0, float u2_0)
{
    float3  _S464 = center_1 - p_4;
    float _S465 = radius_1 * radius_1 / dot_0(_S464, _S464);
    float _S466 = u1_0 * _S465 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S465), (0.0f)))))));
    float _S467 = 2.0f * u1_0;
    bool _S468 = _S465 >= 1.0f;
    float _S469 = _slang_select(_S468, _S467,_S466);
    float _S470 = (F32_sqrt(((F32_max((_S469 * (2.0f - _S469)), (0.0f))))));
    float _S471 = 6.28318548202514648f * u2_0;
    float3  _S472 = make_float3 (_S470 * (F32_cos((_S471))), 1.0f - _S469, _S470 * (F32_sin((_S471))));
    float3  _S473 = ((((_S464)) * make_float3(rnorm3df(((_S464)).x, ((_S464)).y, ((_S464)).z))));
    float3  _S474 = tangentToWorld(_S472, _S473);
    return _S474;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_3, float max_len_0)
{
    float3  _S475 = center_2 - ray_3->origin;
    float _S476 = dot_0(_S475, ray_3->unit_direction);
    float _S477 = dot_0(_S475, _S475) - _S476 * _S476;
    float _S478 = radius_3 * radius_3;
    bool _S479 = _S477 > _S478;
    if(_S479)
    {
        return 4.294967296e+09f;
    }
    float _S480 = (F32_sqrt((_S478 - _S477)));
    float _S481 = _S476 - _S480;
    float _S482 = _S476 + _S480;
    bool _S483 = _S481 > 0.0000152587890625f;
    bool _S484;
    if(_S483)
    {
        _S484 = _S481 < max_len_0;
    }
    else
    {
        _S484 = false;
    }
    if(_S484)
    {
        return _S481;
    }
    bool _S485 = _S482 > 0.0000152587890625f;
    if(_S485)
    {
        _S484 = _S482 < max_len_0;
    }
    else
    {
        _S484 = false;
    }
    if(_S484)
    {
        return _S482;
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

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_5, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_1)
{
    Random _S486 = pcg(init_random_state_1);
    Random _S487 = pcg(_S486.state);
    Random _S488 = pcg(_S487.state);
    float3  _S489 = make_float3 (0.0f);
    TreeSample _S490 = TreeSample_x24init_0(_S489, _S489, 0.0f, _S488.state);
    TreeSample sample_0 = _S490;
    float3  _S491 = _slang_select(sided_0, _S489,smooth_n_2);
    bool _S492 = context_1->opaque;
    float3  lift_n_0;
    if(_S492)
    {
        float3  _S493 = context_1->lift;
        lift_n_0 = _S493;
    }
    else
    {
        lift_n_0 = smooth_n_2;
    }
    float3  start_2 = origin_5 + make_float3 (geometry_offset_1) * lift_n_0;
    float pick_1 = _S486.value;
    float probability_4 = 1.0f;
    uint n_9 = 0U;
    for(;;)
    {
        uint4  _S494 = (fcptLightNode((n_9)));
        if((_S494.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S495 = (fcptLightSecond((n_9)));
        uint _S496 = n_9 + 1U;
        LightNode _S497 = (fcptLightBounds((_S496)));
        LightNode _S498 = (fcptLightBounds((_S495)));
        uint _S499 = pickChild(_S497, _S498, origin_5, _S491, &pick_1, &probability_4);
        bool _S500 = _S499 > 1U;
        if(_S500)
        {
            return sample_0;
        }
        bool _S501 = _S499 == 1U;
        uint _S502 = _slang_select(_S501, _S495,_S496);
        n_9 = _S502;
    }
    bool _S503 = n_9 == 0U;
    bool _S504;
    if(_S503)
    {
        LightNode _S505 = (fcptLightBounds((0U)));
        float _S506 = importance(_S505, origin_5, _S491);
        _S504 = !(_S506 > 0.0f);
    }
    else
    {
        _S504 = false;
    }
    if(_S504)
    {
        return sample_0;
    }
    uint4  _S507 = (fcptLightNode((n_9)));
    FKHit _S508 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S509 = (_S507.x) == 2U;
    float3  emitter_normal_0;
    float3  shadow_1;
    float3  emitter_point_0;
    float3  start_3;
    float offset_1;
    FKHit emitter_0;
    if(_S509)
    {
        FKLight _S510 = (fcptLight((_S507.y)));
        if(sided_0)
        {
            _S504 = !_S492;
        }
        else
        {
            _S504 = false;
        }
        if(_S504)
        {
            float _S511 = sign_0(dot_0(geometry_n_1, _S510.position - origin_5));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S511);
            float3  _S512 = origin_5 + make_float3 (geometry_offset_1) * lift_n_1;
            lift_n_0 = lift_n_1;
            emitter_normal_0 = _S512;
        }
        else
        {
            if(sided_0)
            {
                _S504 = !((dot_0(context_1->side, _S510.position - origin_5)) > 0.0f);
            }
            else
            {
                _S504 = false;
            }
            if(_S504)
            {
                lift_n_0 = _S489;
                emitter_normal_0 = origin_5;
            }
            else
            {
                emitter_normal_0 = start_2;
            }
        }
        bool _S513 = !_S492;
        if(_S513)
        {
            float _S514 = tracedOffset_0(origin_5, lift_n_0, geometry_offset_1);
            float3  _S515 = origin_5 + make_float3 (_S514) * lift_n_0;
            emitter_normal_0 = _S515;
            offset_1 = _S514;
        }
        else
        {
            offset_1 = geometry_offset_1;
        }
        bool _S516 = (_S510.variance) == 0.0f;
        if(_S516)
        {
            float3  _S517 = _S510.position - emitter_normal_0;
            float3  _S518 = ((((_S517)) * make_float3(rnorm3df(((_S517)).x, ((_S517)).y, ((_S517)).z))));
            (&sample_0)->dir = _S518;
            float3  _S519 = _S510.color * make_float3 (_S510.intensity) / make_float3 (dot_0(_S517, _S517) * probability_4);
            (&sample_0)->radiance = _S519;
            shadow_1 = _S517;
        }
        else
        {
            float3  _S520 = sampleSphere(_S510.position, _S510.variance, emitter_normal_0, _S487.value, _S488.value);
            (&sample_0)->dir = _S520;
            float _S521 = sphereDensity(_S510.position, _S510.variance, emitter_normal_0);
            float _S522 = probability_4 * _S521;
            (&sample_0)->density = _S522;
            float3  _S523 = pointLightRadiance(_S510.color, _S510.intensity, _S510.variance);
            float3  _S524 = _S523 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S524;
            FKRay _S525 = Ray_x24init_0(emitter_normal_0, (&sample_0)->dir);
            float _S526 = raySphere_0(_S510.position, _S510.variance, &_S525, 4.294967296e+09f);
            float3  _S527 = (&sample_0)->dir * make_float3 (_S526);
            shadow_1 = _S527;
        }
        float3  _S528 = emitter_normal_0;
        emitter_0 = _S508;
        emitter_normal_0 = _S489;
        emitter_point_0 = _S489;
        start_3 = _S528;
    }
    else
    {
        uint _S529 = _S507.y;
        uint _S530 = (fcptTriangleOffset((_S529)));
        uint _S531 = _S530 + _S507.z;
        Matrix<float, 3, 3>  _S532 = (fcptWorldTriangle((_S529), (_S531)));
        float _S533 = (F32_sqrt((_S487.value)));
        float2  _S534 = make_float2 (_S533 * (1.0f - _S488.value), _S533 * _S488.value);
        float3  _S535 = mul_0(make_float3 (1.0f - _S533, _S534.x, _S534.y), _S532);
        if(sided_0)
        {
            _S504 = !_S492;
        }
        else
        {
            _S504 = false;
        }
        if(_S504)
        {
            float _S536 = sign_0(dot_0(geometry_n_1, _S535 - origin_5));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S536);
            float3  _S537 = origin_5 + make_float3 (geometry_offset_1) * lift_n_2;
            lift_n_0 = lift_n_2;
            emitter_normal_0 = _S537;
        }
        else
        {
            if(sided_0)
            {
                bool _S538 = !((dot_0(context_1->side, _S535 - origin_5)) > 0.0f);
                if(_S538)
                {
                    lift_n_0 = _S489;
                    emitter_normal_0 = origin_5;
                }
                else
                {
                    emitter_normal_0 = start_2;
                }
            }
            else
            {
                bool _S539 = !((dot_0(smooth_n_2, _S535 - start_2)) > 0.0f);
                if(_S539)
                {
                    return sample_0;
                }
                emitter_normal_0 = start_2;
            }
        }
        bool _S540 = !_S492;
        if(_S540)
        {
            float _S541 = tracedOffset_0(origin_5, lift_n_0, geometry_offset_1);
            float3  _S542 = origin_5 + make_float3 (_S541) * lift_n_0;
            emitter_normal_0 = _S542;
            offset_1 = _S541;
        }
        else
        {
            offset_1 = geometry_offset_1;
        }
        FKHit _S543 = Hit_x24init_0(_S534, _S529, _S531, 0U, 0.0f);
        float3  _S544 = cross_0(_S532.rows[int(1)] - _S532.rows[int(0)], _S532.rows[int(2)] - _S532.rows[int(0)]);
        float3  _S545 = _S535 - emitter_normal_0;
        float3  _S546 = ((((_S545)) * make_float3(rnorm3df(((_S545)).x, ((_S545)).y, ((_S545)).z))));
        (&sample_0)->dir = _S546;
        float3  _S547 = emitter_normal_0;
        shadow_1 = _S545;
        emitter_0 = _S543;
        emitter_normal_0 = _S544;
        emitter_point_0 = _S535;
        start_3 = _S547;
    }
    FKHit _S548 = emitter_0;
    float3  _S549 = lightTransmittance_0(origin_5, lift_n_0, geometry_offset_1, shadow_1, context_1, _S488.state, offset_1, &_S548);
    bool _S550 = (emitter_0.instance_index) != 4294967295U;
    if(_S550)
    {
        _S504 = !all_0(_S549 == _S489);
    }
    else
    {
        _S504 = false;
    }
    if(_S504)
    {
        float _S551 = solidAngle(probability_4, emitter_normal_0, emitter_point_0 - start_3);
        (&sample_0)->density = _S551;
        FKSurface _S552 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S488.state), ((&sample_0)->dir), (context_1->depth), (length_0(emitter_point_0 - origin_5))));
        (&sample_0)->random_state = _S552.random_state;
        float3  _S553 = _slang_select(_S552.skip, _S489,_S552.material.emissive);
        float3  _S554 = _S553 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S554;
    }
    float3  _S555 = (&sample_0)->radiance * _S549;
    bool _S556 = all_0(_S549 == _S489);
    float3  _S557 = _slang_select(_S556, _S489,_S555);
    (&sample_0)->radiance = _S557;
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
    float _S558 = 1.0f / (1.0f + b_0 / a_4 * (b_0 / a_4));
    bool _S559 = b_0 > 0.0f;
    float _S560 = _slang_select(_S559, _S558,1.0f);
    return _S560;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_0, float3  light_point_1)
{
    bool _S561 = vertex_0->none;
    if(_S561)
    {
        return 1.0f;
    }
    uint _S562 = (fcptLightSlot((*hit_0)));
    float _S563 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S562, light_point_1);
    float _S564 = powerHeuristic(vertex_0->pdf, _S563);
    return _S564;
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
    Shift _S565;
    (&_S565)->f = f_4;
    (&_S565)->jac = jac_0;
    return _S565;
}

static __device__ uint extractBits_0(uint e_1, uint offset_2, uint count_1)
{
    return (e_1 >> offset_2) & ((1U << count_1) - 1U);
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_6, float3  smooth_n_3, float3  start_4)
{
    NEEVertex _S566;
    (&_S566)->none = none_0;
    (&_S566)->pdf = pdf_4;
    (&_S566)->origin = origin_6;
    (&_S566)->smooth_n = smooth_n_3;
    (&_S566)->start = start_4;
    return _S566;
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
    Vertex _S567;
    (&_S567)->rough = rough_0;
    (&_S567)->lobe = lobe_7;
    (&_S567)->pdf = pdf_5;
    (&_S567)->cos = cos_0;
    (&_S567)->inside = inside_0;
    return _S567;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S568 = hash(index_0);
    uint _S569 = hash(seed_0 ^ _S568);
    return _S569;
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
    float3  _S570 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_1));
    float3  _S571 = scatter_0 * _S570 / make_float3 (sigma_1);
    float3  _S572 = _slang_select(scatters_0, _S571,_S570);
    return _S572;
}

static __device__ bool scatterSampled_0(bool replay_0, uint b_1, uint stop_0, bool varying_0)
{
    bool _S573 = !replay_0;
    bool _S574;
    if(_S573)
    {
        _S574 = true;
    }
    else
    {
        bool _S575 = b_1 == stop_0;
        if(_S575)
        {
            _S574 = !varying_0;
        }
        else
        {
            _S574 = false;
        }
    }
    return _S574;
}

static __device__ uint arrivalLobe_0(uint b_2, uint prev_lobe_0)
{
    bool _S576 = b_2 > 0U;
    uint _S577 = _slang_select(_S576, prev_lobe_0,3U);
    return _S577;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_8, bool surface_5, float length_2, float width_0, bool opaque_0, float3  lift_0, FKHit * own_0, bool fiber_0, bool faced_0)
{
    ShadowContext _S578;
    (&_S578)->extinction_behind = extinction_behind_0;
    (&_S578)->extinction_front = extinction_front_0;
    (&_S578)->fillings = fillings_0;
    (&_S578)->side = side_0;
    (&_S578)->depth = depth_1;
    (&_S578)->lobe = lobe_8;
    (&_S578)->surface = surface_5;
    (&_S578)->length = length_2;
    (&_S578)->width = width_0;
    (&_S578)->opaque = opaque_0;
    (&_S578)->lift = lift_0;
    (&_S578)->own = *own_0;
    (&_S578)->fiber = fiber_0;
    (&_S578)->faced = faced_0;
    return _S578;
}

__device__ float3  safeDivide(float3  a_5, float3  b_3)
{
    float3  _S579 = a_5 / b_3;
    float3  _S580 = make_float3 (0.0f);
    bool3  _S581 = b_3 == _S580;
    float3  _S582 = _slang_select(_S581, _S580,_S579);
    return _S582;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_3, uint count_2)
{
    uint _S583 = (1U << count_2) - 1U;
    return (e_2 & (~(_S583 << offset_3))) | ((newbits_0 & _S583) << offset_3);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_0 = r_2;
    uint _S584 = insertBits_0(r_2.path, end_0, 0U, 5U);
    uint _S585 = insertBits_0(_S584, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S585;
    (&candidate_0)->f = f_5;
    return candidate_0;
}

__device__ void offer(Selection * sel_0, Reservoir candidate_1, float3  weight_0)
{
    float _S586 = rgb_to_greyscale(weight_0);
    bool _S587 = _S586 > 0.0f;
    bool _S588;
    if(_S587)
    {
        _S588 = _S586 < 3.00000000549775576e+38f;
    }
    else
    {
        _S588 = false;
    }
    bool _S589 = !_S588;
    if(_S589)
    {
        return;
    }
    bool _S590 = sel_0->sums;
    if(_S590)
    {
        float3  _S591 = sel_0->color + weight_0;
        sel_0->color = _S591;
        return;
    }
    float _S592 = sel_0->w_sum + _S586;
    sel_0->w_sum = _S592;
    float3  _S593 = sel_0->color + weight_0;
    sel_0->color = _S593;
    Random _S594 = pcg(sel_0->random_state);
    sel_0->random_state = _S594.state;
    bool _S595 = (_S594.value * sel_0->w_sum) <= _S586;
    if(_S595)
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
    Random _S596 = pcg(random_state_8);
    Random _S597 = pcg(_S596.state);
    float _S598 = 1.0f - 2.0f * _S596.value;
    float _S599 = (F32_sqrt(((F32_max((1.0f - _S598 * _S598), (0.0f))))));
    float _S600 = 6.28318548202514648f * _S597.value;
    return make_float3 (_S599 * (F32_cos((_S600))), _S599 * (F32_sin((_S600))), _S598);
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2)
{
    BSDFMaterial _S601;
    (&_S601)->albedo = albedo_0;
    (&_S601)->emissive = emissive_0;
    (&_S601)->roughness = roughness_0;
    (&_S601)->metallic = metallic_0;
    (&_S601)->transmission = transmission_0;
    (&_S601)->ior = ior_0;
    (&_S601)->absorption = absorption_0;
    (&_S601)->specular_tint = specular_tint_0;
    (&_S601)->specular_level = specular_level_0;
    (&_S601)->translucent = translucent_0;
    (&_S601)->sheen = sheen_2;
    (&_S601)->sheen_roughness = sheen_roughness_0;
    (&_S601)->anisotropy = anisotropy_0;
    (&_S601)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S601)->tangent = tangent_2;
    return _S601;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1)
{
    FKMedium _S602;
    (&_S602)->scatter = scatter_1;
    (&_S602)->extinction = extinction_1;
    return _S602;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_7, bool skip_1, uint random_state_9, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S603;
    (&_S603)->smooth_n = smooth_n_4;
    (&_S603)->geometry_n = geometry_n_2;
    (&_S603)->geometry_offset = geometry_offset_2;
    (&_S603)->material = *material_7;
    (&_S603)->skip = skip_1;
    (&_S603)->random_state = random_state_9;
    (&_S603)->coverage = coverage_0;
    (&_S603)->encloses = encloses_0;
    (&_S603)->volume = *volume_0;
    (&_S603)->fills = fills_0;
    (&_S603)->hair = hair_0;
    return _S603;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S604 = (&surface_6->material)->emissive;
    float3  _S605 = make_float3 (0.0f);
    bool _S606 = !top_0;
    float3  _S607 = _slang_select(_S606, _S605,_S604);
    (&(&lower_0)->material)->emissive = _S607;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_2)
{
    float _S608 = surface_7->coverage;
    bool _S609 = u_2 < _S608;
    if(_S609)
    {
        return *surface_7;
    }
    float3  _S610 = make_float3 (0.0f);
    float3  _S611 = make_float3 (1.0f);
    BSDFMaterial _S612 = Material_x24init_0(_S610, _S610, 0.0f, 0.0f, 0.0f, 0.0f, _S610, _S611, 1.0f, _S610, _S610, 0.5f, 0.0f, 0.0f, _S610);
    BSDFMaterial material_8 = _S612;
    (&material_8)->albedo = _S611;
    (&material_8)->emissive = (&surface_7->material)->emissive;
    (&material_8)->transmission = 1.0f;
    (&material_8)->ior = 1.0f;
    (&material_8)->absorption = (&surface_7->material)->absorption;
    FKSurface through_0 = *surface_7;
    (&through_0)->material = material_8;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S613 = transmission_1 > 0.0f;
    bool _S614;
    if(_S613)
    {
        _S614 = true;
    }
    else
    {
        _S614 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S615;
    if(_S614)
    {
        _S615 = 1.0f;
    }
    else
    {
        _S615 = -1.0f;
    }
    return _S615;
}

static __device__ bool arrivesBehind_0(float3  dir_9, float3  n_10)
{
    return (dot_0(dir_9, n_10)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_10)
{
    float3  _S616 = surface_8->geometry_n;
    float _S617 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_10);
    FKSurface faced_1 = *surface_8;
    float3  _S618 = surface_8->smooth_n * make_float3 (_S617);
    (&faced_1)->smooth_n = _S618;
    float3  _S619 = _S616 * make_float3 (_S617);
    (&faced_1)->geometry_n = _S619;
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
    float3  _S620 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_2) * log_0(_S620));
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
    bool _S621;
    if(open_0)
    {
        _S621 = prev_rough_0;
    }
    else
    {
        _S621 = false;
    }
    if(_S621)
    {
        _S621 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S621 = false;
    }
    return _S621;
}

static __device__ float2  vertexEta_0(BSDFMaterial * material_9, float n_dot_v_0)
{
    bool _S622 = n_dot_v_0 < 0.0f;
    float _S623 = material_9->ior;
    float _S624 = _slang_select(_S622, _S623,1.0f);
    float _S625 = _slang_select(_S622, 1.0f,_S623);
    return make_float2 (_S624, _S625);
}

__device__ bool samplesLights(BSDFMaterial material_10)
{
    bool _S626 = (material_10.roughness) > 0.0f;
    bool _S627;
    if(_S626)
    {
        _S627 = true;
    }
    else
    {
        bool _S628 = (material_10.metallic) < 1.0f;
        if(_S628)
        {
            _S627 = (material_10.transmission) < 1.0f;
        }
        else
        {
            _S627 = false;
        }
    }
    return _S627;
}

__device__ float3  sideNormal(FKSurface surface_9, float3  in_dir_5)
{
    bool _S629 = !((surface_9.material.transmission) > 0.0f);
    bool _S630;
    if(_S629)
    {
        BSDFMaterial _S631 = surface_9.material;
        bool _S632 = isTranslucent_0(&_S631);
        _S630 = !_S632;
    }
    else
    {
        _S630 = false;
    }
    if(_S630)
    {
        _S630 = (dot_0(surface_9.smooth_n, - in_dir_5)) > 0.0f;
    }
    else
    {
        _S630 = false;
    }
    float3  _S633 = _slang_select(_S630, surface_9.smooth_n,surface_9.geometry_n);
    return _S633;
}

struct MediumSides
{
    FKMedium behind;
    FKMedium front;
    uint2  fillings;
    float3  face;
};

static __device__ MediumSides MediumSides_x24init_0(FKMedium * behind_0, FKMedium * front_1, uint2  fillings_1, float3  face_1)
{
    MediumSides _S634;
    (&_S634)->behind = *behind_0;
    (&_S634)->front = *front_1;
    (&_S634)->fillings = fillings_1;
    (&_S634)->face = face_1;
    return _S634;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_10, FKMedium * medium_0, uint filling_0, float3  dir_11)
{
    float3  _S635 = surface_10->geometry_n;
    MediumSides _S636 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_10->geometry_n);
    MediumSides sides_0 = _S636;
    bool _S637 = surface_10->encloses;
    if(_S637)
    {
        (&sides_0)->behind = surface_10->volume;
        *&((&(&sides_0)->fillings)->x) = surface_10->fills;
        bool _S638 = (dot_0(dir_11, _S635)) > 0.0f;
        if(_S638)
        {
            float3  _S639 = make_float3 (0.0f);
            FKMedium _S640 = Medium_x24init_0(_S639, _S639);
            (&sides_0)->front = _S640;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_11, bool turned_0, float3  side_n_3, float3  extinction_2, uint filling_1, float3  dir_12, uint depth_2, uint lobe_9, float length_3, float width_1, bool opaque_1, float3  lift_1, FKHit * own_1, bool fiber_1)
{
    ShadowContext _S641 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), side_n_3, depth_2, lobe_9, true, length_3, width_1, opaque_1, lift_1, own_1, fiber_1, true);
    ShadowContext context_2 = _S641;
    bool _S642 = surface_11->encloses;
    if(_S642)
    {
        FKSurface faced_2 = *surface_11;
        float3  _S643 = surface_11->geometry_n;
        float3  _S644 = - surface_11->geometry_n;
        float3  _S645 = _slang_select(turned_0, _S644,_S643);
        (&faced_2)->geometry_n = _S645;
        FKMedium _S646 = Medium_x24init_0(make_float3 (0.0f), extinction_2);
        FKSurface _S647 = faced_2;
        FKMedium _S648 = _S646;
        MediumSides _S649 = mediumSides_0(&_S647, &_S648, filling_1, dir_12);
        ShadowContext _S650 = ShadowContext_x24init_0(_S649.behind.extinction, _S649.front.extinction, _S649.fillings, side_n_3, depth_2, lobe_9, true, length_3, width_1, opaque_1, lift_1, own_1, fiber_1, true);
        context_2 = _S650;
        if(turned_0)
        {
            uint2  _S651 = _S649.fillings;
            ShadowContext _S652 = ShadowContext_x24init_0(_S649.front.extinction, _S649.behind.extinction, uint2 {_S651.y, _S651.x}, side_n_3, depth_2, lobe_9, true, length_3, width_1, opaque_1, lift_1, own_1, fiber_1, true);
            context_2 = _S652;
        }
    }
    bool _S653 = isTranslucent_0(&surface_11->material);
    bool _S654 = !_S653;
    (&context_2)->faced = _S654;
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

__device__ __forceinline__ float3  BSDF(float3  in_dir_6, float3  out_dir_1, float3  n_11, float3  g_n_0, BSDFMaterial material_11, float eta_i_5, float eta_o_5, uint random_state_10)
{
    float3  _S655 = negate_0(in_dir_6);
    bool _S656 = (dot_0(g_n_0, _S655) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S656)
    {
        SampleBSDF _S657 = connectBSDF(in_dir_6, out_dir_1, n_11, material_11, eta_i_5, eta_o_5, 0U, random_state_10);
        SampleBSDF _S658 = connectBSDF(in_dir_6, out_dir_1, n_11, material_11, eta_i_5, eta_o_5, 2U, random_state_10);
        return _S657.throughput * make_float3 (_S657.pdf) + _S658.throughput * make_float3 (_S658.pdf);
    }
    SampleBSDF _S659 = connectBSDF(in_dir_6, out_dir_1, n_11, material_11, eta_i_5, eta_o_5, 1U, random_state_10);
    return _S659.throughput * make_float3 (_S659.pdf);
}

__device__ float3  translucentCorrection(float3  in_dir_7, float3  out_dir_2, float3  n_12, float3  g_n_1, BSDFMaterial material_12, float eta_i_6, float eta_o_6, uint random_state_11)
{
    float _S660 = dot_0(n_12, out_dir_2);
    float3  _S661 = negate_0(in_dir_7);
    bool _S662 = (_S660 * dot_0(n_12, _S661)) < 0.0f;
    SampleBSDF _S663 = connectBSDF(in_dir_7, out_dir_2, n_12, material_12, eta_i_6, eta_o_6, 0U, random_state_11);
    float3  _S664 = negate_0(in_dir_7);
    bool _S665 = (dot_0(g_n_1, _S664) * dot_0(g_n_1, out_dir_2)) > 0.0f;
    float3  _S666 = make_float3 (0.0f);
    float3  _S667 = _S663.throughput * make_float3 (_S663.pdf);
    float _S668 = _slang_select(_S665, -1.0f,1.0f);
    float3  _S669 = _S667 * make_float3 (_S668);
    float3  _S670 = _slang_select(_S662, _S669,_S666);
    return _S670;
}

__device__ float3  translucentBSDF(float3  in_dir_8, float3  out_dir_3, float3  n_13, float3  g_n_2, BSDFMaterial material_13, float eta_i_7, float eta_o_7, uint random_state_12)
{
    float3  _S671 = BSDF(in_dir_8, out_dir_3, n_13, g_n_2, material_13, eta_i_7, eta_o_7, random_state_12);
    float3  _S672 = translucentCorrection(in_dir_8, out_dir_3, n_13, g_n_2, material_13, eta_i_7, eta_o_7, random_state_12);
    return _S671 + _S672;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_9, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_14, float eta_i_8, float eta_o_8, bool competing_1, uint random_state_13)
{
    bool _S673 = !competing_1;
    bool _S674;
    if(_S673)
    {
        _S674 = true;
    }
    else
    {
        _S674 = (light_2->density) == 0.0f;
    }
    if(_S674)
    {
        bool _S675 = isTranslucent_0(material_14);
        if(_S675)
        {
            float3  _S676 = translucentBSDF(in_dir_9, light_2->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_8, eta_o_8, random_state_13);
            return _S676 * light_2->radiance;
        }
        float3  _S677 = BSDF(in_dir_9, light_2->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_8, eta_o_8, random_state_13);
        return _S677 * light_2->radiance;
    }
    float3  _S678 = light_2->dir;
    bool _S679 = (dot_0(geometry_n_4, - in_dir_9) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    float3  _S680 = neeBSDF(in_dir_9, _S678, smooth_n_5, *material_14, eta_i_8, eta_o_8, _S679, light_2->density, true, random_state_13);
    return _S680 * light_2->radiance * make_float3 (light_2->density);
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

static __device__ float3  reflect_0(float3  i_9, float3  n_14)
{
    return i_9 - make_float3 (2.0f * dot_0(n_14, i_9)) * n_14;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_15, BSDFMaterial material_15, float eta_i_9, float eta_o_9, uint random_init_1, float2  screen_space_0)
{
    uint random_state_14 = random_init_1;
    float3  _S686 = negate_0(in_dir_10);
    float _S687 = dot_0(n_15, _S686);
    float _S688 = sign_0(_S687);
    float3  n_i_4 = n_15 * make_float3 (_S688);
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

static __device__ bool boundsVolume_0(FKSurface * surface_12)
{
    return surface_12->encloses;
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
    int _S726;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_3;
    float sky_pdf_1;
    float width_4;
    float spread_3;
    uint b_5;
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
    FKRay ray_4 = _S748;
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
    (&ray_4)->origin = _S745;
    (&hit_1)->distance = _S751;
    FKMedium _S756 = (fcptCameraMedium(((&ray_4)->unit_direction), ((&hit_1)->distance), (&filling_2)));
    uint _S757 = filling_2;
    bool _S758 = (fcptVaryingUsed());
    uint _S759 = _slang_select(_S758, _S757,4294967295U);
    filling_2 = _S759;
    scatter_in_0 = _S756.scatter;
    extinction_in_0 = _S756.extinction;
    Reservoir _S760 = chain_0;
    uint _S761 = filling_2;
    for(;;)
    {
        bool _S762 = (fcptVaryingUsed());
        if(_S762)
        {
            passes_0 = _S761 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S763 = (fcptMajorant((_S761)));
            spread_1 = _S763;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S743;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S732 == 1U;
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
        bool _S764 = (&prev_0)->rough;
        if(_S764)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S765 = stream(_S755, 384U);
        uint tracking_0 = _S765;
        weight_1 = throughput_3;
        glowed_0 = _S727;
        b_4 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_2 = _S749;
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
            uint _S766 = b_4 + 320U;
            bool _S767 = b_4 == 4294967295U;
            uint _S768 = _slang_select(_S767, 384U,_S766);
            uint _S769 = stream(_S755, _S768);
            Random _S770 = pcg(_S769);
            float _S771 = freeFlight_0(_S770.value, spread_1);
            if(passes_0)
            {
                float3  _S772 = (&ray_4)->origin;
                float3  _S773 = (&ray_4)->unit_direction;
                float _S774 = (&hit_1)->distance;
                uint _S775 = _slang_select(_S767, 0U,b_4);
                uint _S776 = (&prev_0)->lobe;
                uint _S777 = _slang_select(_S767, 3U,_S776);
                float _S778 = (fcptTrackMedium((_S761), (_S772), (_S773), (_S774), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S775), (_S777), (_S767)));
                geometry_density_2 = _S778;
            }
            else
            {
                geometry_density_2 = _S771;
            }
            bool _S779 = !(geometry_density_2 < ((&hit_1)->distance));
            if(_S779)
            {
                _S726 = int(1);
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
                float3  _S780 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S781 = sel_1->glow + _S780;
                sel_1->glow = _S781;
            }
            else
            {
            }
            glowed_0 = _S727;
            uint b_6 = b_4 + 1U;
            float3  _S782 = (&ray_4)->origin + make_float3 (geometry_density_2) * (&ray_4)->unit_direction;
            (&ray_4)->origin = _S782;
            float3  _S783 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, geometry_density_2, true);
            float3  _S784 = weight_1;
            float3  _S785 = _slang_select(passes_0, _S784,_S783);
            float3  throughput_4 = throughput_2 * _S785;
            uint _S786 = stream(_S755, b_6 + 320U);
            tracking_0 = _S786;
            weight_1 = throughput_3;
            float width_5 = width_2 + threshold_2 * geometry_density_2;
            float _S787 = threshold_2 + 3.14159274101257324f;
            bool _S788 = scatterSampled_0(replay_1, b_6, _S743, passes_0);
            TreeSample _S789 = TreeSample_x24init_0(_S727, _S727, 0.0f, 0U);
            if(_S788)
            {
                float3  _S790 = (&ray_4)->origin;
                float3  _S791 = (&ray_4)->unit_direction;
                float3  _S792 = (&ray_4)->unit_direction;
                uint _S793 = stream(_S755, b_6 + 64U);
                float3  _S794 = extinction_in_0;
                float3  _S795 = extinction_in_0;
                uint2  _S796 = make_uint2 (_S761);
                float3  _S797 = (&ray_4)->unit_direction;
                uint _S798 = arrivalLobe_0(b_6, (&prev_0)->lobe);
                FKHit _S799 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S800 = _S799;
                ShadowContext _S801 = ShadowContext_x24init_0(_S794, _S795, _S796, _S797, b_6, _S798, false, geometry_density_2, width_5, false, _S727, &_S800, false, true);
                ShadowContext _S802 = _S801;
                TreeSample _S803 = sampleLightTree_0(_S790, _S791, _S792, 0.0f, true, _S793, &_S802);
                light_3 = _S803;
            }
            else
            {
                light_3 = _S789;
            }
            uint _S804 = (fcptMaxBounces());
            bool _S805 = b_6 < _S804;
            if(_S805)
            {
                is_inside_5 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_5 = false;
            }
            float _S806 = _slang_select(is_inside_5, 0.07957746833562851f,0.0f);
            float3  _S807 = throughput_4 * light_3.radiance;
            float _S808 = powerHeuristic(light_3.density, _S806);
            float3  _S809 = _S807 * make_float3 (0.07957746833562851f * _S808);
            float3  _S810 = _slang_select(_S788, _S809,_S727);
            if(replay_1)
            {
                viewed_0 = b_6 == _S743;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S811 = _S732 == 2U;
                if(_S811)
                {
                    float _S812 = rgb_to_greyscale(_S810);
                    passes_0 = _S812 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S813 = Shift_x24init_0(_S810, 1.0f);
                    _S726 = int(0);
                    ended_0 = _S813;
                    spread_1 = _S787;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                _S726 = int(0);
                ended_0 = _S728;
                spread_1 = _S787;
                geometry_density_2 = width_5;
                chain_throughput_0 = throughput_4;
                layer_0 = b_6;
                break;
            }
            bool _S814 = !replay_1;
            if(_S814)
            {
                Reservoir candidate_2 = _S760;
                uint _S815 = extractBits_0(_S760.path, 10U, 2U);
                bool _S816 = _S815 == 1U;
                if(_S816)
                {
                    float3  _S817 = safeDivide(_S810, _S727);
                    (&candidate_2)->radiance = _S817;
                }
                else
                {
                    uint _S818 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                    uint _S819 = insertBits_0(_S818, 2U, 10U, 2U);
                    (&candidate_2)->path = _S819;
                }
                Reservoir _S820 = withEnd(candidate_2, 0U, b_6, _S810);
                offer(sel_1, _S820, _S810 * make_float3 (scale_1) / make_float3 (density_2));
                float _S821 = survivalProbability(throughput_4, density_2);
                uint _S822 = stream(_S755, b_6 + 128U);
                Random _S823 = pcg(_S822);
                bool _S824 = _S821 < (_S823.value);
                if(_S824)
                {
                    scatter_2 = true;
                }
                else
                {
                    uint _S825 = (fcptMaxBounces());
                    scatter_2 = b_6 >= _S825;
                }
                if(scatter_2)
                {
                    _S726 = int(0);
                    ended_0 = _S728;
                    spread_1 = _S787;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                float _S826 = density_2 * _S821;
                density_2 = _S826;
            }
            else
            {
            }
            NEEVertex _S827 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_4)->origin, _S727, (&ray_4)->origin);
            nee_vertex_0 = _S827;
            uint _S828 = stream(_S755, b_6);
            float3  _S829 = isotropic_0(_S828);
            (&ray_4)->unit_direction = _S829;
            Vertex _S830 = scatteredVertex_0(false);
            prev_0 = _S830;
            float _S831 = (&prev_0)->pdf;
            FKRay _S832 = ray_4;
            FKHit _S833 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S834 = (fcptTraverseInstanceBVH((_S832), (true), (4.294967296e+09f), (false), (_S833), (false)));
            hit_1 = _S834;
            b_4 = b_6;
            throughput_2 = throughput_4;
            threshold_2 = _S787;
            width_2 = width_5;
            sky_pdf_0 = _S831;
        }
        if(_S726 != int(1))
        {
            width_2 = geometry_density_2;
            throughput_2 = chain_throughput_0;
            b_4 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S728;
        spread_1 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S835 = b_4 == 4294967295U;
    Reservoir _S836 = chain_0;
    NEEVertex _S837 = nee_vertex_0;
    Vertex _S838 = prev_0;
    FKHit _S839 = hit_1;
    uint _S840 = filling_2;
    float3  _S841 = scatter_in_0;
    float3  _S842 = extinction_in_0;
    float3  _S843 = weight_1;
    float3  _S844 = glowed_0;
    for(;;)
    {
        bool _S845 = (_S839.instance_index) == 4294967295U;
        if(_S845)
        {
            bool _S846 = !_S837.none;
            float _S847 = _slang_select(_S846, sky_pdf_0,0.0f);
            float _S848 = escapeWeight_0(_S847, (&ray_4)->unit_direction);
            float3  _S849 = environment_0((&ray_4)->unit_direction, b_4, _S838.lobe);
            float3  _S850 = throughput_2 * _S849;
            if(replay_1)
            {
                bool _S851 = b_4 == _S743;
                if(_S851)
                {
                    passes_0 = _S732 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S852 = Shift_x24init_0(_S850 * make_float3 (_S848) / make_float3 (r_3->jac), density_2 / r_3->jac);
                    ended_0 = _S852;
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
                    passes_0 = !_S838.rough;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S853 = Shift_x24init_0(_S850 * make_float3 (_S848), 1.0f);
                    ended_0 = _S853;
                    passes_0 = true;
                    break;
                }
                ended_0 = _S728;
                passes_0 = true;
                break;
            }
            Reservoir candidate_3 = _S836;
            uint _S854 = extractBits_0(_S836.path, 10U, 2U);
            bool _S855 = _S854 == 1U;
            if(_S855)
            {
                uint _S856 = extractBits_0(_S836.path, 5U, 5U);
                bool _S857 = _S856 == b_4;
                float _S858 = _slang_select(_S857, 1.0f,_S848);
                float3  _S859 = safeDivide(_S850 * make_float3 (_S858), _S727);
                (&candidate_3)->radiance = _S859;
            }
            else
            {
                if(_S838.rough)
                {
                    uint _S860 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                    uint _S861 = insertBits_0(_S860, 3U, 10U, 2U);
                    uint _S862 = insertBits_0(_S861, _S838.lobe, 15U, 2U);
                    uint _S863 = _slang_select(_S838.inside, 1U,0U);
                    uint _S864 = insertBits_0(_S862, _S863, 20U, 1U);
                    (&candidate_3)->path = _S864;
                    (&candidate_3)->jac = _S838.pdf;
                    (&candidate_3)->dir = (&ray_4)->unit_direction;
                }
                else
                {
                }
            }
            float3  _S865 = _S850 * make_float3 (_S848);
            Reservoir _S866 = withEnd(candidate_3, 3U, b_4, _S865);
            offer(sel_1, _S866, _S865 * make_float3 (scale_1) / make_float3 (density_2));
            ended_0 = _S728;
            passes_0 = true;
            break;
        }
        float3  _S867 = (&ray_4)->origin + make_float3 (_S839.distance) * (&ray_4)->unit_direction;
        (&ray_4)->origin = _S867;
        bool _S868 = (fcptVaryingUsed());
        if(_S868)
        {
            passes_0 = _S840 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            bool _S869 = !replay_1;
            if(_S869)
            {
                float3  _S870 = throughput_2 * _S844 / make_float3 (density_2);
                float3  _S871 = sel_1->glow + _S870;
                sel_1->glow = _S871;
            }
            else
            {
            }
            float3  _S872 = throughput_2 * _S843;
            throughput_2 = _S872;
        }
        else
        {
            float3  _S873 = flightWeight_0(_S841, _S842, (_S841.x + _S841.y + _S841.z) / 3.0f, _S839.distance, false);
            float3  _S874 = throughput_2 * _S873;
            throughput_2 = _S874;
        }
        float _S875 = width_2 + spread_1 * _S839.distance;
        ended_0 = _S728;
        width_2 = _S875;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    uint _S876 = b_4 + 1U;
    b_4 = _S876;
    layer_0 = 0U;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S727;
    float3  reconnection_0 = _S727;
    viewed_0 = _S835;
    for(;;)
    {
        bool _S877 = ((&hit_1)->is_point_light) == 1U;
        FKMedium _S878 = Medium_x24init_0(_S727, _S727);
        BSDFMaterial _S879 = Material_x24init_0(_S727, _S727, 0.0f, 0.0f, 0.0f, 0.0f, _S727, throughput_3, 1.0f, _S727, _S727, 0.5f, 0.0f, 0.0f, _S727);
        FKMedium _S880 = _S878;
        FKSurface _S881 = Surface_x24init_0(_S727, _S727, 0.0f, &_S879, false, 0U, 1.0f, false, &_S880, 4294967295U, _S727);
        bool _S882 = !_S877;
        bool is_inside_6;
        float3  throughput_5;
        FKSurface surface_13;
        if(_S882)
        {
            uint _S883 = stream(_S755, b_4);
            uint _S884 = arrivalLobe_0(b_4, (&prev_0)->lobe);
            FKSurface _S885 = (fcptSurfaceAtPath((hit_1), ((&ray_4)->origin), (_S883), (width_2), (layer_0), (b_4), (_S884), ((&ray_4)->unit_direction)));
            bool _S886 = !passes_0;
            FKSurface _S887 = _S885;
            FKSurface _S888 = emitting_0(&_S887, _S886);
            uint _S889 = stream(_S755, b_4 + 256U);
            Random _S890 = pcg(_S889);
            FKSurface _S891 = _S888;
            FKSurface _S892 = uncovered_0(&_S891, _S890.value);
            float _S893 = facingSign(_S892.material.transmission, _S892.geometry_n, (&ray_4)->unit_direction);
            bool _S894 = _S893 < 0.0f;
            bool _S895 = (_S892.material.transmission) > 0.0f;
            if(_S895)
            {
                bool _S896 = arrivesBehind_0((&ray_4)->unit_direction, _S892.geometry_n);
                scatter_2 = _S896;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S897 = _S892;
            FKSurface _S898 = facingRay_0(&_S897, (&ray_4)->unit_direction);
            if(passes_0)
            {
                bool _S899 = arrivesBehind_0((&ray_4)->unit_direction, _S898.geometry_n);
                is_inside_6 = _S899;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S900 = beerLambert((&hit_1)->distance, _S898.material.absorption);
                float3  _S901 = throughput_2 * _S900;
                throughput_5 = _S901;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S902 = !_S898.skip;
            float geometry_density_3 = geometryDensity(_S898.geometry_n, (&ray_4)->unit_direction, (&hit_1)->distance);
            bool _S903 = b_4 == _S876;
            if(_S903)
            {
                float _S904 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S904;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S905 = geometry_density_2;
            scatter_2 = _S902;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S905;
            surface_13 = _S898;
            turned_1 = _S894;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_13 = _S881;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S906 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S907 = surface_13;
        FKSurface _S908 = surface_13;
        float _S909 = dot_0(surface_13.smooth_n, - (&ray_4)->unit_direction);
        BSDFMaterial _S910 = _S907.material;
        float2  _S911 = vertexEta_0(&_S910, _S909);
        bool _S912;
        if(scatter_2)
        {
            bool _S913 = samplesLights(_S907.material);
            _S912 = _S913;
        }
        else
        {
            _S912 = false;
        }
        bool _S914;
        if(passes_0)
        {
            _S914 = true;
        }
        else
        {
            _S914 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S914)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S912;
        }
        float3  _S915 = sideNormal(surface_13, (&ray_4)->unit_direction);
        FKSurface _S916 = surface_13;
        float3  _S917 = surface_13.hair;
        bool _S918 = (dot_0(_S917, _S917)) > 0.0f;
        bool _S919 = !_S918;
        bool _S920;
        if(_S919)
        {
            _S920 = !((_S907.material.transmission) > 0.0f);
        }
        else
        {
            _S920 = false;
        }
        FKSurface _S921 = surface_13;
        float3  _S922 = surface_13.geometry_n * make_float3 (dot_0(surface_13.geometry_n, _S908.smooth_n));
        bool _S923;
        if(_S918)
        {
            _S923 = true;
        }
        else
        {
            BSDFMaterial _S924 = _S907.material;
            bool _S925 = isTranslucent_0(&_S924);
            _S923 = _S925;
        }
        bool _S926;
        if(_S923)
        {
            _S926 = true;
        }
        else
        {
            bool _S927 = (_S907.material.transmission) > 0.0f;
            if(_S927)
            {
                uint _S928 = (fcptLayers((hit_1)));
                _S926 = _S928 == 1U;
            }
            else
            {
                _S926 = false;
            }
        }
        float3  emission_0;
        if(_S877)
        {
            float3  _S929 = (fcptCalculatePointLightContrib(((&hit_1)->instance_index)));
            emission_0 = _S929;
        }
        else
        {
            emission_0 = _S907.material.emissive;
        }
        float _S930 = rgb_to_greyscale(emission_0);
        bool _S931 = _S930 > 0.0f;
        float3  emission_1;
        if(_S931)
        {
            NEEVertex _S932 = nee_vertex_0;
            FKHit _S933 = hit_1;
            float _S934 = emissionWeight_0(&_S932, &_S933, (&ray_4)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S934);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S935;
        if(replay_1)
        {
            _S935 = _S732 == 1U;
        }
        else
        {
            _S935 = false;
        }
        bool _S936;
        if(_S935)
        {
            _S936 = b_4 > _S731;
        }
        else
        {
            _S936 = false;
        }
        bool _S937;
        if(_S936)
        {
            _S937 = b_4 == _S730;
        }
        else
        {
            _S937 = false;
        }
        bool _S938;
        if(_S937)
        {
            bool _S939 = _S733 == 1U;
            if(_S939)
            {
                _S938 = true;
            }
            else
            {
                _S938 = _S733 == 2U;
            }
        }
        else
        {
            _S938 = false;
        }
        if(_S938)
        {
            bool _S940 = _S877 != (_S733 == 2U);
            if(_S940)
            {
                return _S728;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_3->jac), density_2 / r_3->jac);
        }
        uint _S941 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S942 = _S941 == 1U;
        Reservoir here_0 = chain_0;
        uint _S943 = insertBits_0(0U, b_4, 5U, 5U);
        uint _S944 = insertBits_0(_S943, 1U, 10U, 2U);
        uint _S945 = insertBits_0(_S944, (&prev_0)->lobe, 15U, 2U);
        bool _S946 = (&prev_0)->inside;
        uint _S947 = _slang_select(_S946, 1U,0U);
        uint _S948 = insertBits_0(_S945, _S947, 20U, 1U);
        (&here_0)->path = _S948;
        float _S949 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S949;
        fcptWithReservoirHit((&here_0), (&hit_1));
        bool _S950;
        if(replay_1)
        {
            _S950 = _S732 == 1U;
        }
        else
        {
            _S950 = false;
        }
        bool _S951;
        if(_S950)
        {
            _S951 = b_4 == _S731;
        }
        else
        {
            _S951 = false;
        }
        bool _S952 = b_4 == _S743;
        bool _S953;
        if(_S952)
        {
            bool _S954 = !scatter_2;
            if(_S954)
            {
                _S953 = true;
            }
            else
            {
                bool _S955 = _S732 != 1U;
                if(_S955)
                {
                    _S953 = _S732 != 3U;
                }
                else
                {
                    _S953 = false;
                }
            }
        }
        else
        {
            _S953 = false;
        }
        bool _S956;
        if(_S953)
        {
            _S956 = _S732 == 2U;
        }
        else
        {
            _S956 = false;
        }
        bool _S957;
        if(_S956)
        {
            _S957 = !_S906;
        }
        else
        {
            _S957 = false;
        }
        bool _S958;
        if(_S957)
        {
            _S958 = _S733 != 4U;
        }
        else
        {
            _S958 = false;
        }
        bool _S959 = _S731 == _S730;
        bool _S960;
        if(_S959)
        {
            _S960 = _S733 == 0U;
        }
        else
        {
            _S960 = false;
        }
        bool _S961;
        if(_S960)
        {
            _S961 = ((&hit_1)->instance_index) == (_S744.instance_index);
        }
        else
        {
            _S961 = false;
        }
        bool _S962;
        if(_S961)
        {
            _S962 = ((&hit_1)->triangle_index) == (_S744.triangle_index);
        }
        else
        {
            _S962 = false;
        }
        bool _S963;
        if(_S962)
        {
            _S963 = _S906;
        }
        else
        {
            _S963 = false;
        }
        bool _S964 = _slang_select(_S951, _S963,_S958);
        bool _S965;
        if(nee_0)
        {
            _S965 = _slang_select(replay_1, _S964,scatter_2);
        }
        else
        {
            _S965 = false;
        }
        TreeSample _S966 = TreeSample_x24init_0(_S727, _S727, 0.0f, 0U);
        float3  throughput_6;
        float3  lit_0;
        if(_S965)
        {
            float3  _S967 = (&ray_4)->origin;
            if(_S918)
            {
                throughput_6 = _S727;
            }
            else
            {
                throughput_6 = _S908.smooth_n;
            }
            uint _S968 = stream(_S755, b_4 + 64U);
            uint _S969 = arrivalLobe_0(b_4, (&prev_0)->lobe);
            FKSurface _S970 = surface_13;
            FKHit _S971 = hit_1;
            ShadowContext _S972 = shadowContext_0(&_S970, turned_1, _S915, extinction_in_0, filling_2, (&ray_4)->unit_direction, b_4, _S969, (&hit_1)->distance, width_2, _S920, _S922, &_S971, _S918);
            ShadowContext _S973 = _S972;
            TreeSample _S974 = sampleLightTree_0(_S967, throughput_6, _S921.geometry_n, surface_13.geometry_offset, _S926, _S968, &_S973);
            bool _S975 = any_0((_S974.radiance) != _S727);
            if(_S975)
            {
                if(_S918)
                {
                    uint _S976 = (fcptMaxBounces());
                    bool _S977 = b_4 < _S976;
                    FKSurface _S978 = surface_13;
                    TreeSample _S979 = _S974;
                    float3  _S980 = hairLight_0(&_S978, (&ray_4)->unit_direction, &_S979, _S977);
                    lit_0 = _S980;
                }
                else
                {
                    float _S981 = _S911.x;
                    float _S982 = _S911.y;
                    uint _S983 = (fcptMaxBounces());
                    bool _S984 = b_4 < _S983;
                    TreeSample _S985 = _S974;
                    BSDFMaterial _S986 = _S907.material;
                    float3  _S987 = lightBSDF_0((&ray_4)->unit_direction, &_S985, _S908.smooth_n, _S915, &_S986, _S981, _S982, _S984, surface_13.random_state);
                    lit_0 = _S987;
                }
            }
            else
            {
                lit_0 = _S727;
            }
            light_3 = _S974;
        }
        else
        {
            light_3 = _S966;
            lit_0 = _S727;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S988;
        bool _S989;
        float density_4;
        if(_S951)
        {
            bool _S990 = ((&hit_1)->instance_index) != (_S744.instance_index);
            if(_S990)
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
                refracted_4 = !_S906;
            }
            if(refracted_4)
            {
                return _S728;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S959)
            {
                wrong_side_0 = _S733 == 1U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            if(_S959)
            {
                _S988 = _S733 == 0U;
            }
            else
            {
                _S988 = false;
            }
            if(_S988)
            {
                bool _S991 = !nee_0;
                if(_S991)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S992 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S992 > 0.0f);
                }
                if(passes_0)
                {
                    return _S728;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            if(_S959)
            {
                _S989 = _S733 == 4U;
            }
            else
            {
                _S989 = false;
            }
            if(_S989)
            {
                bool _S993 = !nee_0;
                if(_S993)
                {
                    return _S728;
                }
                float _S994 = environmentPdf_0(r_3->dir);
                float3  _S995 = skyBSDF((&ray_4)->unit_direction, r_3->dir, surface_13, _S915, _S911, is_inside_6, _S994, surface_13.random_state);
                return Shift_x24init_0(throughput_7 * _S995 * r_3->radiance / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            uint _S996 = extractBits_0(_S729, 19U, 1U);
            bool _S997 = nee_0 != (_S996 == 1U);
            if(_S997)
            {
                return _S728;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S952;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S998 = !scatter_2;
                if(_S998)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S999 = _S732 != 1U;
                    if(_S999)
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
                bool _S1000 = _S732 == 2U;
                if(_S1000)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S906;
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
                    uint _S1001 = stream(_S755, b_4 + 448U);
                    FKRay _S1002 = ray_4;
                    FKSurface _S1003 = surface_13;
                    SkySample _S1004 = sampleSky_0(&_S1002, &_S1003, _S915, _S911, is_inside_6, _S1001, surface_13.random_state);
                    return Shift_x24init_0(throughput_5 * _S1004.color, 1.0f);
                }
                if(_S1000)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S906;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1005 = rgb_to_greyscale(light_3.radiance);
                    bool _S1006 = !(_S1005 > 0.0f);
                    if(_S1006)
                    {
                        return _S728;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
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
                    passes_0 = _S877;
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
                    passes_0 = !_S906;
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
                bool _S1007 = !replay_1;
                if(_S1007)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1008 = b_4 > 0U;
                    if(_S1008)
                    {
                        Reservoir candidate_4 = chain_0;
                        if(_S942)
                        {
                            float3  _S1009 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_4)->radiance = _S1009;
                        }
                        else
                        {
                            if(_S906)
                            {
                                candidate_4 = here_0;
                            }
                        }
                        float3  _S1010 = throughput_5 * emission_1;
                        Reservoir _S1011 = withEnd(candidate_4, 1U, b_4, _S1010);
                        offer(sel_1, _S1011, _S1010 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1012 = throughput_5 * emission_1;
                        float3  _S1013 = sel_1->glow + _S1012;
                        sel_1->glow = _S1013;
                    }
                    if(nee_0)
                    {
                        float3  _S1014 = throughput_5 * lit_0;
                        Reservoir candidate_5 = chain_0;
                        if(_S942)
                        {
                            float3  _S1015 = safeDivide(_S1014, chain_throughput_0);
                            (&candidate_5)->radiance = _S1015;
                        }
                        else
                        {
                            if(_S906)
                            {
                                candidate_5 = here_0;
                                uint _S1016 = insertBits_0((&candidate_5)->path, 1U, 19U, 1U);
                                (&candidate_5)->path = _S1016;
                                (&candidate_5)->dir = light_3.dir;
                                (&candidate_5)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1017 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S1018 = insertBits_0(_S1017, 2U, 10U, 2U);
                                (&candidate_5)->path = _S1018;
                            }
                        }
                        Reservoir _S1019 = withEnd(candidate_5, 0U, b_4, _S1014);
                        offer(sel_1, _S1019, _S1014 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S918)
                        {
                            _S988 = false;
                        }
                        else
                        {
                            bool _S1020 = environmentMapped_0();
                            _S988 = _S1020;
                        }
                    }
                    else
                    {
                        _S988 = false;
                    }
                    if(_S988)
                    {
                        uint _S1021 = (fcptMaxBounces());
                        _S989 = b_4 < _S1021;
                    }
                    else
                    {
                        _S989 = false;
                    }
                    if(_S989)
                    {
                        uint _S1022 = stream(_S755, b_4 + 448U);
                        FKRay _S1023 = ray_4;
                        FKSurface _S1024 = surface_13;
                        SkySample _S1025 = sampleSky_0(&_S1023, &_S1024, _S915, _S911, is_inside_6, _S1022, surface_13.random_state);
                        float3  _S1026 = throughput_5 * _S1025.color;
                        Reservoir candidate_6 = chain_0;
                        if(_S942)
                        {
                            float3  _S1027 = safeDivide(_S1026, chain_throughput_0);
                            (&candidate_6)->radiance = _S1027;
                        }
                        else
                        {
                            if(_S906)
                            {
                                candidate_6 = here_0;
                                uint _S1028 = insertBits_0((&candidate_6)->path, 1U, 19U, 1U);
                                (&candidate_6)->path = _S1028;
                                (&candidate_6)->dir = _S1025.dir;
                                (&candidate_6)->radiance = _S1025.radiance;
                            }
                            else
                            {
                                uint _S1029 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S1030 = insertBits_0(_S1029, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1030;
                            }
                        }
                        Reservoir _S1031 = withEnd(candidate_6, 4U, b_4, _S1026);
                        offer(sel_1, _S1031, _S1026 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1032;
        bool straight_0;
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
        bool _S1043;
        bool _S1044;
        bool _S1045;
        bool _S1046;
        bool _S1047;
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
                viewed_1 = _S952;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1048 = extractBits_0(_S729, 15U, 2U);
            uint _S1049 = extractBits_0(_S729, 17U, 2U);
            uint _S1050 = _slang_select(_S951, _S1049,_S1048);
            float3  _S1051 = r_3->dir;
            bool refracted_5 = _S1050 == 1U;
            SampleBSDF _S1052 = SampleBSDF_x24init_0(_S727, _S727, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_10 = _S1052;
            float3  reconnection_1;
            SampleBSDF _S1053;
            if(viewed_1)
            {
                uint _S1054 = extractBits_0(_S729, 20U, 1U);
                bool _S1055 = is_inside_6 != (_S1054 == 1U);
                if(_S1055)
                {
                    return _S728;
                }
                bool _S1056 = _S732 == 1U;
                if(_S1056)
                {
                    float3  _S1057 = (fcptHitPosition((_S744)));
                    throughput_8 = _S1057;
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
                    BSDFMaterial _S1058 = _S907.material;
                    bool _S1059 = isTranslucent_0(&_S1058);
                    if(_S1059)
                    {
                        refracted_4 = _S1050 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1060 = throughput_8 - (&ray_4)->origin;
                        float3  _S1061 = _slang_select(_S1056, _S1060,_S1051);
                        wrong_side_0 = (dot_0(_S908.smooth_n, _S1061) * _S909) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1056)
                {
                    float3  _S1062 = - _S908.smooth_n;
                    bool _S1063 = is_inside_6 != refracted_4;
                    float3  _S1064 = _slang_select(_S1063, _S1062,_S908.smooth_n);
                    float3  _S1065 = (&ray_4)->origin;
                    float3  _S1066 = (&ray_4)->origin;
                    FKSurface _S1067 = surface_13;
                    float _S1068 = _slang_select(_S920, 0.0f,_S1067.geometry_offset);
                    float _S1069 = tracedOffset_0(_S1066, _S1064, _S1068);
                    float3  _S1070 = make_float3 (_S1069) * _S1064;
                    bool _S1071 = (dot_0(throughput_8 - (&ray_4)->origin, _S915)) > 0.0f;
                    float _S1072 = _slang_select(_S1071, _S1067.geometry_offset,0.0f);
                    float3  _S1073 = _S922 * make_float3 (_S1072);
                    float3  _S1074 = _slang_select(_S920, _S1073,_S1070);
                    float3  _S1075 = throughput_8 - (_S1065 + _S1074);
                    float3  _S1076 = ((((_S1075)) * make_float3(rnorm3df(((_S1075)).x, ((_S1075)).y, ((_S1075)).z))));
                    reconnection_1 = _S1076;
                }
                else
                {
                    reconnection_1 = _S1051;
                }
                if(_S918)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1077 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, _S915);
                    wrong_side_0 = _S1077;
                }
                if(wrong_side_0)
                {
                    return _S728;
                }
                float3  _S1078 = throughput_8;
                throughput_8 = reconnection_1;
                b_7 = _S1050;
                wrong_side_0 = false;
                reconnection_1 = _S1078;
            }
            else
            {
                bool _S1079 = !_S951;
                if(_S1079)
                {
                    SampleBSDF bsdf_sampled_0;
                    if(_S918)
                    {
                        SampleBSDF _S1080 = (fcptSampleHair((_S916.hair), (_S907.material.albedo), (_S907.material.specular_tint), ((&ray_4)->unit_direction), (surface_13.random_state)));
                        _S1053 = _S1080;
                    }
                    else
                    {
                        SampleBSDF _S1081 = sampleBSDF((&ray_4)->unit_direction, _S908.smooth_n, _S907.material, _S911.x, _S911.y, surface_13.random_state, make_float2 (0.0f));
                        _S1053 = _S1081;
                    }
                    bsdf_sampled_0 = _S1053;
                    if(_S918)
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
                    if(_S918)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1082 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, _S915);
                        wrong_side_0 = _S1082;
                    }
                    if(wrong_side_0)
                    {
                        _S988 = (_S907.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S988 = false;
                    }
                    if(_S988)
                    {
                        SampleBSDF _S1083 = sampleBSDF((&bsdf_sampled_0)->unit_direction, _S921.geometry_n, _S907.material, _S911.x, _S911.y, (&bsdf_sampled_0)->random_state, make_float2 (0.0f));
                        (&bsdf_sampled_0)->unit_direction = _S1083.unit_direction;
                        (&bsdf_sampled_0)->throughput = _S1083.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1084 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, _S921.geometry_n)) * _S921.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1084;
                        }
                    }
                    uint _S1085 = (&bsdf_sampled_0)->lobe;
                    float3  _S1086 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1087 = (&bsdf_sampled_0)->refracted;
                    lobe_10 = bsdf_sampled_0;
                    float _S1088 = (&bsdf_sampled_0)->pdf;
                    float _S1089 = _slang_select(wrong_side_0, 0.0f,_S1088);
                    (&lobe_10)->pdf = _S1089;
                    throughput_8 = _S1086;
                    b_7 = _S1085;
                    refracted_4 = _S1087;
                }
                else
                {
                    throughput_8 = _S1051;
                    b_7 = _S1050;
                    refracted_4 = refracted_5;
                    wrong_side_0 = false;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S988 = true;
            }
            else
            {
                _S988 = _S951;
            }
            if(_S988)
            {
                if(_S918)
                {
                    SampleBSDF _S1090 = (fcptConnectHair((_S916.hair), (_S907.material.albedo), (_S907.material.specular_tint), ((&ray_4)->unit_direction), (throughput_8)));
                    _S1053 = _S1090;
                }
                else
                {
                    SampleBSDF _S1091 = connectBSDF((&ray_4)->unit_direction, throughput_8, _S908.smooth_n, _S907.material, _S911.x, _S911.y, b_7, surface_13.random_state);
                    _S1053 = _S1091;
                }
                lobe_10 = _S1053;
            }
            if(_S918)
            {
                _S989 = false;
            }
            else
            {
                bool _S1092 = b_7 != 0U;
                if(_S1092)
                {
                    bool _S1093 = (_S907.material.roughness) == 0.0f;
                    if(_S1093)
                    {
                        _S989 = true;
                    }
                    else
                    {
                        bool _S1094 = b_7 == 1U;
                        if(_S1094)
                        {
                            _S989 = (_S911.x) == (_S911.y);
                        }
                        else
                        {
                            _S989 = false;
                        }
                    }
                }
                else
                {
                    _S989 = false;
                }
            }
            if(_S919)
            {
                _S1032 = b_7 == 1U;
            }
            else
            {
                _S1032 = false;
            }
            if(_S1032)
            {
                straight_0 = (_S907.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1033 = _S919;
            }
            else
            {
                _S1033 = false;
            }
            if(_S1033)
            {
                _S1034 = b_7 == 1U;
            }
            else
            {
                _S1034 = false;
            }
            if(_S1034)
            {
                _S1035 = (_S911.x) == (_S911.y);
            }
            else
            {
                _S1035 = false;
            }
            BSDFMaterial _S1095 = _S907.material;
            bool _S1096 = isTranslucent_0(&_S1095);
            if(_S1096)
            {
                _S1036 = b_7 == 0U;
            }
            else
            {
                _S1036 = false;
            }
            if(_S1036)
            {
                _S1037 = (dot_0(throughput_8, _S921.geometry_n)) < 0.0f;
            }
            else
            {
                _S1037 = false;
            }
            float3  _S1097 = - _S908.smooth_n;
            if(refracted_4)
            {
                _S1038 = !_S1037;
            }
            else
            {
                _S1038 = false;
            }
            bool _S1098 = (is_inside_6 != _S1038) != _S1037;
            float3  _S1099 = _slang_select(_S1098, _S1097,_S908.smooth_n);
            float3  _S1100 = (&ray_4)->origin;
            FKSurface _S1101 = surface_13;
            if(straight_0)
            {
                _S1039 = true;
            }
            else
            {
                _S1039 = _S920;
            }
            float _S1102 = _slang_select(_S1039, 0.0f,_S1101.geometry_offset);
            float _S1103 = tracedOffset_0(_S1100, _S1099, _S1102);
            if(nee_0)
            {
                _S1040 = !_S989;
            }
            else
            {
                _S1040 = false;
            }
            if(_S1040)
            {
                _S1041 = !wrong_side_0;
            }
            else
            {
                _S1041 = false;
            }
            if(_S1041)
            {
                float _S1104 = (&lobe_10)->pdf;
                float3  _S1105 = (&ray_4)->origin;
                float3  _S1106 = _slang_select(_S926, _S727,_S908.smooth_n);
                float3  _S1107 = (&ray_4)->origin;
                float3  _S1108 = make_float3 (_S1103) * _S1099;
                bool _S1109 = (dot_0(throughput_8, _S915)) > 0.0f;
                float _S1110 = _slang_select(_S1109, _S1101.geometry_offset,0.0f);
                float3  _S1111 = _S922 * make_float3 (_S1110);
                float3  _S1112 = _slang_select(_S920, _S1111,_S1108);
                NEEVertex _S1113 = NEEVertex_x24init_0(false, _S1104, _S1105, _S1106, _S1107 + _S1112);
                nee_vertex_0 = _S1113;
            }
            else
            {
                if(_S918)
                {
                    _S1042 = true;
                }
                else
                {
                    bool _S1114 = b_7 != 1U;
                    if(_S1114)
                    {
                        _S1042 = true;
                    }
                    else
                    {
                        _S1042 = (_S911.x) != (_S911.y);
                    }
                }
                if(_S1042)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1115 = b_7 == 0U;
            bool _S1116 = withinInverseFootprint((&lobe_10)->pdf, _S1115, (&prev_0)->cos, (&hit_1)->distance, threshold_2);
            float _S1117 = dot_0(throughput_8, _S921.geometry_n);
            bool _S1118 = (dot_0(throughput_8, _S908.smooth_n) * _S1117) < 0.0f;
            bool _S1119 = !_S1118;
            if(_S1119)
            {
                bool _S1120 = roughLobe((&lobe_10)->pdf, _S1115, _S907.material.roughness);
                _S1042 = _S1120;
            }
            else
            {
                _S1042 = false;
            }
            if(_S951)
            {
                bool _S1121 = !_S1116;
                if(_S1121)
                {
                    return _S728;
                }
                bool _S1122 = _S733 != 1U;
                if(_S1122)
                {
                    _S1043 = _S733 != 2U;
                }
                else
                {
                    _S1043 = false;
                }
                if(_S1043)
                {
                    float _S1123 = (&lobe_10)->pdf;
                    float _S1124 = _slang_select(nee_0, _S1123,0.0f);
                    float _S1125 = escapeWeight_0(_S1124, _S1051);
                    if(_S959)
                    {
                        passes_0 = _S739;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1126 = _slang_select(passes_0, _S1125,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_10)->throughput * make_float3 ((&lobe_10)->pdf)) * r_3->radiance * make_float3 (_S1126) / make_float3 (r_3->jac), density_4 * (&lobe_10)->pdf / r_3->jac);
                }
                float3  _S1127 = throughput_6 * make_float3 ((&lobe_10)->pdf);
                float _S1128 = density_4 * (&lobe_10)->pdf;
                throughput_9 = _S1127;
                density_6 = _S1128;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1129 = (fcptLayers((hit_1)));
            bool _S1130 = b_7 == 1U;
            bool _S1131 = passesLayer_0(_S1129, _S1130, passes_0);
            if(viewed_1)
            {
                _S1043 = _S1131;
            }
            else
            {
                _S1043 = false;
            }
            if(_S1043)
            {
                return _S728;
            }
            if(replay_1)
            {
                _S1044 = b_4 <= _S743;
            }
            else
            {
                _S1044 = false;
            }
            if(_S1044)
            {
                _S1045 = _S906;
            }
            else
            {
                _S1045 = false;
            }
            if(_S1045)
            {
                _S1046 = _S1116;
            }
            else
            {
                _S1046 = false;
            }
            if(_S1046)
            {
                _S1047 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1047 = !_S1042;
                }
                else
                {
                    _S1047 = false;
                }
            }
            if(_S1047)
            {
                return _S728;
            }
            if(viewed_1)
            {
                float3  _S1132 = throughput_9 * ((&lobe_10)->throughput * make_float3 ((&lobe_10)->pdf));
                float _S1133 = (&lobe_10)->pdf;
                throughput_10 = _S1132;
                sky_pdf_2 = _S1133;
            }
            else
            {
                float3  _S1134 = throughput_9 * max_0((&lobe_10)->throughput, _S727);
                throughput_10 = _S1134;
                sky_pdf_2 = density_6;
            }
            bool _S1135 = !replay_1;
            bool _S1136;
            if(_S1135)
            {
                _S1136 = !_S942;
            }
            else
            {
                _S1136 = false;
            }
            bool _S1137;
            if(_S1136)
            {
                _S1137 = _S906;
            }
            else
            {
                _S1137 = false;
            }
            bool _S1138;
            if(_S1137)
            {
                _S1138 = _S1116;
            }
            else
            {
                _S1138 = false;
            }
            float3  chain_throughput_1;
            if(_S1138)
            {
                chain_0 = here_0;
                uint _S1139 = insertBits_0((&chain_0)->path, b_7, 17U, 2U);
                uint _S1140 = _slang_select(nee_0, 1U,0U);
                uint _S1141 = insertBits_0(_S1139, _S1140, 19U, 1U);
                (&chain_0)->path = _S1141;
                float _S1142 = (&chain_0)->jac * (&lobe_10)->pdf;
                (&chain_0)->jac = _S1142;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            Vertex _S1143 = Vertex_x24init_0(_S1042, b_7, (&lobe_10)->pdf, (F32_abs((dot_0(_S921.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1143;
            float _S1144 = (&lobe_10)->pdf;
            bool _S1145;
            if(_S1130)
            {
                _S1145 = (_S911.x) == (_S911.y);
            }
            else
            {
                _S1145 = false;
            }
            float sky_pdf_3 = _slang_select(_S1145, sky_pdf_0,_S1144);
            float _S1146 = _slang_select(_S918, 0.0f,sky_pdf_3);
            float _S1147 = widened_0(spread_1, (&lobe_10)->pdf, _S989);
            bool _S1148;
            if(refracted_4)
            {
                _S1148 = !_S1037;
            }
            else
            {
                _S1148 = false;
            }
            bool is_inside_7;
            if(_S1148)
            {
                bool _S1149 = !is_inside_6;
                is_inside_7 = _S1149;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1150 = surface_13;
            bool _S1151 = boundsVolume_0(&_S1150);
            bool _S1152;
            if(_S1151)
            {
                _S1152 = !_S1131;
            }
            else
            {
                _S1152 = false;
            }
            if(_S1152)
            {
                FKSurface faced_3 = surface_13;
                float3  _S1153 = - _S921.geometry_n;
                float3  _S1154 = _slang_select(turned_1, _S1153,_S921.geometry_n);
                (&faced_3)->geometry_n = _S1154;
                FKMedium _S1155 = Medium_x24init_0(scatter_in_0, extinction_in_0);
                FKSurface _S1156 = faced_3;
                FKMedium _S1157 = _S1155;
                MediumSides _S1158 = mediumSides_0(&_S1156, &_S1157, filling_2, (&ray_4)->unit_direction);
                bool _S1159 = leavesInFront_0((&faced_3)->geometry_n, throughput_8, _S915, _S921.geometry_n);
                float3  _S1160 = _slang_select(_S1159, _S1158.front.scatter,_S1158.behind.scatter);
                scatter_in_0 = _S1160;
                float3  _S1161 = _slang_select(_S1159, _S1158.front.extinction,_S1158.behind.extinction);
                extinction_in_0 = _S1161;
                uint _S1162 = _S1158.fillings.x;
                uint _S1163 = _S1158.fillings.y;
                uint _S1164 = _slang_select(_S1159, _S1163,_S1162);
                bool _S1165 = (fcptVaryingUsed());
                uint _S1166 = _slang_select(_S1165, _S1164,4294967295U);
                filling_2 = _S1166;
            }
            (&ray_4)->unit_direction = throughput_8;
            bool _S1167 = !_S1131;
            if(_S1167)
            {
                if(_S920)
                {
                    bool _S1168 = (dot_0(throughput_8, _S915)) > 0.0f;
                    if(_S1168)
                    {
                        again_0 = (_S1101.geometry_offset) > 0.0f;
                    }
                    else
                    {
                        again_0 = false;
                    }
                    float _S1169 = _slang_select(again_0, _S1101.geometry_offset,0.0f);
                    float3  _S1170 = (&ray_4)->origin + _S922 * make_float3 (_S1169);
                    (&ray_4)->origin = _S1170;
                    bool _S1171 = !again_0;
                    BSDFMaterial _S1172 = _S907.material;
                    bool _S1173 = isTranslucent_0(&_S1172);
                    bool _S1174 = !_S1173;
                    if(_S1174)
                    {
                        opaque_start_0 = !((_S1101.geometry_offset) > 0.0f);
                    }
                    else
                    {
                        opaque_start_0 = false;
                    }
                    if(opaque_start_0)
                    {
                        on_face_0 = _S1117 < 0.0f;
                    }
                    else
                    {
                        on_face_0 = false;
                    }
                    again_0 = on_face_0;
                    opaque_start_0 = true;
                    on_face_0 = _S1171;
                }
                else
                {
                    if(_S918)
                    {
                    }
                    else
                    {
                        float3  _S1175 = (&ray_4)->origin + make_float3 (_S1103) * _S1099;
                        (&ray_4)->origin = _S1175;
                    }
                    again_0 = false;
                    opaque_start_0 = _S918;
                    on_face_0 = _S918;
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
            passes_0 = _S1131;
            viewed_1 = _S1035;
            sky_pdf_2 = _S1146;
            spread_4 = _S1147;
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
        bool _S1176 = !replay_1;
        float density_7;
        if(_S1176)
        {
            if(_S877)
            {
                float3  _S1177 = throughput_9 * emission_1;
                Reservoir candidate_7 = chain_0;
                uint _S1178 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1179 = _S1178 == 1U;
                if(_S1179)
                {
                    float3  _S1180 = safeDivide(_S1177, chain_throughput_0);
                    (&candidate_7)->radiance = _S1180;
                }
                Reservoir _S1181 = withEnd(candidate_7, 2U, b_4, _S1177);
                offer(sel_1, _S1181, _S1177 * make_float3 (scale_1) / make_float3 (density_6));
            }
            if(_S877)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1182 = survivalProbability(throughput_9, density_6);
                density_7 = _S1182;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1183 = stream(_S755, b_4 + 128U);
            Random _S1184 = pcg(_S1183);
            bool _S1185 = density_7 < (_S1184.value);
            if(_S1185)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1186 = (fcptMaxBounces());
                wrong_side_0 = b_4 >= _S1186;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1187 = density_6 * density_7;
            density_7 = _S1187;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1188 = layer_0 ^ 1U;
        uint _S1189 = _slang_select(passes_0, _S1188,0U);
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
            uint _S1190 = b_7 + 1U;
            b_4 = _S1190;
            layer_0 = _S1189;
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
            uint _S1190 = b_7 + 1U;
            b_4 = _S1190;
            layer_0 = _S1189;
            continue;
        }
        FKRay _S1191 = ray_4;
        float _S1192 = distance_5(reconnection_0, (&ray_4)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S952;
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
        float _S1193 = _slang_select(wrong_side_0, _S1192,4.294967296e+09f);
        bool _S1194 = !opaque_start_0;
        if(straight_0)
        {
            _S988 = true;
        }
        else
        {
            _S988 = on_face_0;
        }
        FKHit _S1195;
        if(_S988)
        {
            _S1195 = hit_1;
        }
        else
        {
            _S1195 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
        }
        FKHit _S1196 = (fcptTraverseInstanceBVH((_S1191), (_S882), (_S1193), (_S1194), (_S1195), (viewed_1)));
        hit_1 = _S1196;
        if(replay_1)
        {
            _S989 = _S952;
        }
        else
        {
            _S989 = false;
        }
        if(_S989)
        {
            _S1032 = _S732 == 1U;
        }
        else
        {
            _S1032 = false;
        }
        if(_S1032)
        {
            _S1033 = ((&hit_1)->instance_index) == (_S744.instance_index);
        }
        else
        {
            _S1033 = false;
        }
        if(_S1033)
        {
            _S1034 = ((&hit_1)->triangle_index) == (_S744.triangle_index);
        }
        else
        {
            _S1034 = false;
        }
        if(_S1034)
        {
            (&hit_1)->uv = _S744.uv;
            float _S1197 = distance_5(reconnection_0, (&ray_4)->origin);
            (&hit_1)->distance = _S1197;
        }
        if(replay_1)
        {
            _S1035 = _S952;
        }
        else
        {
            _S1035 = false;
        }
        if(_S1035)
        {
            _S1036 = _S732 == 3U;
        }
        else
        {
            _S1036 = false;
        }
        if(_S1036)
        {
            _S1037 = ((&hit_1)->instance_index) != 4294967295U;
        }
        else
        {
            _S1037 = false;
        }
        if(_S1037)
        {
            return _S728;
        }
        Reservoir _S1198 = chain_0;
        uint _S1199 = filling_2;
        for(;;)
        {
            bool _S1200 = (fcptVaryingUsed());
            if(_S1200)
            {
                _S1038 = _S1199 != 4294967295U;
            }
            else
            {
                _S1038 = false;
            }
            float _S1201;
            if(_S1038)
            {
                float _S1202 = (fcptMajorant((_S1199)));
                _S1201 = _S1202;
            }
            else
            {
                _S1201 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1039 = _S952;
            }
            else
            {
                _S1039 = false;
            }
            if(_S1039)
            {
                _S1040 = _S732 == 1U;
            }
            else
            {
                _S1040 = false;
            }
            if(_S1040)
            {
                _S1041 = _S1201 > 0.0f;
            }
            else
            {
                _S1041 = false;
            }
            if(_S1041)
            {
                ended_0 = _S728;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_3 = width_2;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_7 = b_4;
                _S1042 = true;
                break;
            }
            bool _S1203 = (&prev_0)->rough;
            if(_S1203)
            {
                _S1042 = !(_S1201 > 0.0f);
            }
            else
            {
                _S1042 = false;
            }
            (&prev_0)->rough = _S1042;
            uint _S1204 = b_4 + 320U;
            bool _S1205 = b_4 == 4294967295U;
            uint _S1206 = _slang_select(_S1205, 384U,_S1204);
            uint _S1207 = stream(_S755, _S1206);
            uint tracking_1 = _S1207;
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
                uint _S1208 = b_7 + 320U;
                bool _S1209 = b_7 == 4294967295U;
                uint _S1210 = _slang_select(_S1209, 384U,_S1208);
                uint _S1211 = stream(_S755, _S1210);
                Random _S1212 = pcg(_S1211);
                float _S1213 = freeFlight_0(_S1212.value, _S1201);
                if(_S1038)
                {
                    float3  _S1214 = (&ray_4)->origin;
                    float3  _S1215 = (&ray_4)->unit_direction;
                    float _S1216 = (&hit_1)->distance;
                    uint _S1217 = _slang_select(_S1209, 0U,b_7);
                    uint _S1218 = (&prev_0)->lobe;
                    uint _S1219 = _slang_select(_S1209, 3U,_S1218);
                    float _S1220 = (fcptTrackMedium((_S1199), (_S1214), (_S1215), (_S1216), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S1217), (_S1219), (_S1209)));
                    spread_3 = _S1220;
                }
                else
                {
                    spread_3 = _S1213;
                }
                bool _S1221 = !(spread_3 < ((&hit_1)->distance));
                if(_S1221)
                {
                    _S726 = int(2);
                    break;
                }
                if(_S1038)
                {
                    _S1043 = _S1176;
                }
                else
                {
                    _S1043 = false;
                }
                if(_S1043)
                {
                    float3  _S1222 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1223 = sel_1->glow + _S1222;
                    sel_1->glow = _S1223;
                }
                else
                {
                }
                glowed_0 = _S727;
                uint b_8 = b_7 + 1U;
                float3  _S1224 = (&ray_4)->origin + make_float3 (spread_3) * (&ray_4)->unit_direction;
                (&ray_4)->origin = _S1224;
                float3  _S1225 = flightWeight_0(scatter_in_0, extinction_in_0, _S1201, spread_3, true);
                float3  _S1226 = weight_1;
                float3  _S1227 = _slang_select(_S1038, _S1226,_S1225);
                float3  throughput_11 = throughput_10 * _S1227;
                uint _S1228 = stream(_S755, b_8 + 320U);
                tracking_1 = _S1228;
                weight_1 = throughput_3;
                float width_6 = width_3 + spread_2 * spread_3;
                float _S1229 = spread_2 + 3.14159274101257324f;
                bool _S1230 = scatterSampled_0(replay_1, b_8, _S743, _S1038);
                TreeSample light_4;
                if(_S1230)
                {
                    float3  _S1231 = (&ray_4)->origin;
                    float3  _S1232 = (&ray_4)->unit_direction;
                    float3  _S1233 = (&ray_4)->unit_direction;
                    uint _S1234 = stream(_S755, b_8 + 64U);
                    float3  _S1235 = extinction_in_0;
                    float3  _S1236 = extinction_in_0;
                    uint2  _S1237 = make_uint2 (_S1199);
                    float3  _S1238 = (&ray_4)->unit_direction;
                    uint _S1239 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                    FKHit _S1240 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                    FKHit _S1241 = _S1240;
                    ShadowContext _S1242 = ShadowContext_x24init_0(_S1235, _S1236, _S1237, _S1238, b_8, _S1239, false, spread_3, width_6, false, _S727, &_S1241, false, true);
                    ShadowContext _S1243 = _S1242;
                    TreeSample _S1244 = sampleLightTree_0(_S1231, _S1232, _S1233, 0.0f, true, _S1234, &_S1243);
                    light_4 = _S1244;
                }
                else
                {
                    light_4 = _S966;
                }
                uint _S1245 = (fcptMaxBounces());
                bool _S1246 = b_8 < _S1245;
                if(_S1246)
                {
                    _S1044 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1044 = false;
                }
                float _S1247 = _slang_select(_S1044, 0.07957746833562851f,0.0f);
                float3  _S1248 = throughput_11 * light_4.radiance;
                float _S1249 = powerHeuristic(light_4.density, _S1247);
                float3  _S1250 = _S1248 * make_float3 (0.07957746833562851f * _S1249);
                float3  _S1251 = _slang_select(_S1230, _S1250,_S727);
                if(replay_1)
                {
                    _S1045 = b_8 == _S743;
                }
                else
                {
                    _S1045 = false;
                }
                if(_S1045)
                {
                    bool _S1252 = _S732 == 2U;
                    if(_S1252)
                    {
                        float _S1253 = rgb_to_greyscale(_S1251);
                        _S1046 = _S1253 > 0.0f;
                    }
                    else
                    {
                        _S1046 = false;
                    }
                    if(_S1046)
                    {
                        Shift _S1254 = Shift_x24init_0(_S1251, 1.0f);
                        _S726 = int(1);
                        ended_0 = _S1254;
                        spread_3 = _S1229;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_5 = b_8;
                        break;
                    }
                    _S726 = int(1);
                    ended_0 = _S728;
                    spread_3 = _S1229;
                    width_4 = width_6;
                    throughput_8 = throughput_11;
                    b_5 = b_8;
                    break;
                }
                if(_S1176)
                {
                    Reservoir candidate_8 = _S1198;
                    uint _S1255 = extractBits_0(_S1198.path, 10U, 2U);
                    bool _S1256 = _S1255 == 1U;
                    if(_S1256)
                    {
                        float3  _S1257 = safeDivide(_S1251, chain_throughput_0);
                        (&candidate_8)->radiance = _S1257;
                    }
                    else
                    {
                        uint _S1258 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                        uint _S1259 = insertBits_0(_S1258, 2U, 10U, 2U);
                        (&candidate_8)->path = _S1259;
                    }
                    Reservoir _S1260 = withEnd(candidate_8, 0U, b_8, _S1251);
                    offer(sel_1, _S1260, _S1251 * make_float3 (scale_1) / make_float3 (density_3));
                    float _S1261 = survivalProbability(throughput_11, density_3);
                    uint _S1262 = stream(_S755, b_8 + 128U);
                    Random _S1263 = pcg(_S1262);
                    bool _S1264 = _S1261 < (_S1263.value);
                    if(_S1264)
                    {
                        _S1046 = true;
                    }
                    else
                    {
                        uint _S1265 = (fcptMaxBounces());
                        _S1046 = b_8 >= _S1265;
                    }
                    if(_S1046)
                    {
                        _S726 = int(1);
                        ended_0 = _S728;
                        spread_3 = _S1229;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_5 = b_8;
                        break;
                    }
                    float _S1266 = density_3 * _S1261;
                    density_3 = _S1266;
                }
                else
                {
                }
                NEEVertex _S1267 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_4)->origin, _S727, (&ray_4)->origin);
                nee_vertex_0 = _S1267;
                uint _S1268 = stream(_S755, b_8);
                float3  _S1269 = isotropic_0(_S1268);
                (&ray_4)->unit_direction = _S1269;
                Vertex _S1270 = scatteredVertex_0(is_inside_5);
                prev_0 = _S1270;
                float _S1271 = (&prev_0)->pdf;
                FKRay _S1272 = ray_4;
                FKHit _S1273 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1274 = (fcptTraverseInstanceBVH((_S1272), (true), (4.294967296e+09f), (false), (_S1273), (false)));
                hit_1 = _S1274;
                b_7 = b_8;
                throughput_10 = throughput_11;
                spread_2 = _S1229;
                width_3 = width_6;
                sky_pdf_1 = _S1271;
            }
            if(_S726 != int(2))
            {
                spread_2 = spread_3;
                width_3 = width_4;
                throughput_10 = throughput_8;
                b_7 = b_5;
                _S1042 = true;
                break;
            }
            ended_0 = _S728;
            _S1042 = false;
            break;
        }
        if(_S1042)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1043 = b_7 == b_4;
        }
        else
        {
            _S1043 = false;
        }
        Reservoir _S1275 = chain_0;
        NEEVertex _S1276 = nee_vertex_0;
        Vertex _S1277 = prev_0;
        FKHit _S1278 = hit_1;
        uint _S1279 = filling_2;
        float3  _S1280 = scatter_in_0;
        float3  _S1281 = extinction_in_0;
        float3  _S1282 = weight_1;
        float3  _S1283 = glowed_0;
        for(;;)
        {
            bool _S1284 = (_S1278.instance_index) == 4294967295U;
            if(_S1284)
            {
                bool _S1285 = !_S1276.none;
                float _S1286 = _slang_select(_S1285, sky_pdf_1,0.0f);
                float _S1287 = escapeWeight_0(_S1286, (&ray_4)->unit_direction);
                float3  _S1288 = environment_0((&ray_4)->unit_direction, b_7, _S1277.lobe);
                float3  _S1289 = throughput_10 * _S1288;
                if(replay_1)
                {
                    bool _S1290 = b_7 == _S743;
                    if(_S1290)
                    {
                        _S1044 = _S732 == 3U;
                    }
                    else
                    {
                        _S1044 = false;
                    }
                    if(_S1044)
                    {
                        Shift _S1291 = Shift_x24init_0(_S1289 * make_float3 (_S1287) / make_float3 (r_3->jac), density_3 / r_3->jac);
                        arrived_end_0 = _S1291;
                        width_4 = width_3;
                        throughput_8 = throughput_10;
                        _S1044 = true;
                        break;
                    }
                    if(_S742)
                    {
                        _S1045 = _S739;
                    }
                    else
                    {
                        _S1045 = false;
                    }
                    if(_S1045)
                    {
                        _S1046 = b_7 == _S730;
                    }
                    else
                    {
                        _S1046 = false;
                    }
                    if(_S1046)
                    {
                        _S1047 = !_S1277.rough;
                    }
                    else
                    {
                        _S1047 = false;
                    }
                    if(_S1047)
                    {
                        Shift _S1292 = Shift_x24init_0(_S1289 * make_float3 (_S1287), 1.0f);
                        arrived_end_0 = _S1292;
                        width_4 = width_3;
                        throughput_8 = throughput_10;
                        _S1044 = true;
                        break;
                    }
                    arrived_end_0 = _S728;
                    width_4 = width_3;
                    throughput_8 = throughput_10;
                    _S1044 = true;
                    break;
                }
                Reservoir candidate_9 = _S1275;
                uint _S1293 = extractBits_0(_S1275.path, 10U, 2U);
                bool _S1294 = _S1293 == 1U;
                if(_S1294)
                {
                    uint _S1295 = extractBits_0(_S1275.path, 5U, 5U);
                    bool _S1296 = _S1295 == b_7;
                    float _S1297 = _slang_select(_S1296, 1.0f,_S1287);
                    float3  _S1298 = safeDivide(_S1289 * make_float3 (_S1297), chain_throughput_0);
                    (&candidate_9)->radiance = _S1298;
                }
                else
                {
                    if(_S1277.rough)
                    {
                        uint _S1299 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                        uint _S1300 = insertBits_0(_S1299, 3U, 10U, 2U);
                        uint _S1301 = insertBits_0(_S1300, _S1277.lobe, 15U, 2U);
                        uint _S1302 = _slang_select(_S1277.inside, 1U,0U);
                        uint _S1303 = insertBits_0(_S1301, _S1302, 20U, 1U);
                        (&candidate_9)->path = _S1303;
                        (&candidate_9)->jac = _S1277.pdf;
                        (&candidate_9)->dir = (&ray_4)->unit_direction;
                    }
                    else
                    {
                    }
                }
                float3  _S1304 = _S1289 * make_float3 (_S1287);
                Reservoir _S1305 = withEnd(candidate_9, 3U, b_7, _S1304);
                offer(sel_1, _S1305, _S1304 * make_float3 (scale_1) / make_float3 (density_3));
                arrived_end_0 = _S728;
                width_4 = width_3;
                throughput_8 = throughput_10;
                _S1044 = true;
                break;
            }
            float3  _S1306 = (&ray_4)->origin + make_float3 (_S1278.distance) * (&ray_4)->unit_direction;
            (&ray_4)->origin = _S1306;
            bool _S1307 = (fcptVaryingUsed());
            if(_S1307)
            {
                _S1044 = _S1279 != 4294967295U;
            }
            else
            {
                _S1044 = false;
            }
            if(_S1044)
            {
                if(_S1176)
                {
                    float3  _S1308 = throughput_10 * _S1283 / make_float3 (density_3);
                    float3  _S1309 = sel_1->glow + _S1308;
                    sel_1->glow = _S1309;
                }
                else
                {
                }
                float3  _S1310 = throughput_10 * _S1282;
                throughput_8 = _S1310;
            }
            else
            {
                float3  _S1311 = flightWeight_0(_S1280, _S1281, (_S1280.x + _S1280.y + _S1280.z) / 3.0f, _S1278.distance, false);
                float3  _S1312 = throughput_10 * _S1311;
                throughput_8 = _S1312;
            }
            float _S1313 = width_3 + spread_2 * _S1278.distance;
            arrived_end_0 = _S728;
            width_4 = _S1313;
            _S1044 = false;
            break;
        }
        if(_S1044)
        {
            return arrived_end_0;
        }
        viewed_0 = _S1043;
        width_2 = width_4;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1190 = b_7 + 1U;
        b_4 = _S1190;
        layer_0 = _S1189;
    }
    return _S728;
}

static __device__ Shift shift_0(Domain * dom_1, Reservoir * r_4)
{
    Selection _S1314 = (Selection{});
    Selection sel_2 = _S1314;
    bool _S1315 = (r_4->w) <= 0.0f;
    if(_S1315)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1316 = walk_0(dom_1, r_4, true, 0.0f, &sel_2);
    return _S1316;
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
    Random _S1317 = pcg(state_3);
    Random _S1318 = pcg(_S1317.state);
    float _S1319 = 6.28318548202514648f * _S1317.value;
    float _S1320 = (F32_sqrt((-2.0f * clamp_0((F32_log((_S1318.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1318.state, _S1320 * (F32_cos((_S1319))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1321;
    (&_S1321)->state = state_4;
    (&_S1321)->value = value_2;
    return _S1321;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1322 = normal_distribution(state_5);
    Random _S1323 = normal_distribution(_S1322.state);
    Random _S1324 = normal_distribution(_S1323.state);
    float3  _S1325 = make_float3 (_S1322.value, _S1323.value, _S1324.value);
    float3  _S1326 = ((((_S1325)) * make_float3(rnorm3df(((_S1325)).x, ((_S1325)).y, ((_S1325)).z))));
    return RandomSphere_x24init_0(_S1324.state, _S1326);
}

struct RandomHemisphere
{
    uint state;
    float3  value;
};

static __device__ RandomHemisphere RandomHemisphere_x24init_0(uint state_6, float3  value_3)
{
    RandomHemisphere _S1327;
    (&_S1327)->state = state_6;
    (&_S1327)->value = value_3;
    return _S1327;
}

__device__ RandomHemisphere random_hemisphere(uint state_7, float3  normal_4)
{
    RandomSphere _S1328 = random_sphere(state_7);
    bool _S1329 = (dot_0(_S1328.value, normal_4)) > 0.0f;
    if(_S1329)
    {
        return RandomHemisphere_x24init_0(_S1328.state, _S1328.value);
    }
    else
    {
        float3  _S1330 = negate_0(_S1328.value);
        return RandomHemisphere_x24init_0(_S1328.state, _S1330);
    }
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_16)
{
    float3  _S1331 = p1_0 - p0_0;
    float3  _S1332 = p2_0 - p0_0;
    float2  _S1333 = uv1_0 - uv0_0;
    float2  _S1334 = uv2_0 - uv0_0;
    float _S1335 = _S1333.x;
    float _S1336 = _S1334.y;
    float _S1337 = _S1333.y;
    float _S1338 = _S1334.x;
    float _S1339 = _S1335 * _S1336 - _S1337 * _S1338;
    float _S1340 = 1.0f / _S1339;
    float3  t_1 = (_S1331 * make_float3 (_S1336) - _S1332 * make_float3 (_S1337)) * make_float3 (_S1340);
    float3  _S1341 = (_S1332 * make_float3 (_S1335) - _S1331 * make_float3 (_S1338)) * make_float3 (_S1340);
    float3  _S1342 = t_1 - n_16 * make_float3 (dot_0(n_16, t_1));
    float3  t_2 = ((((_S1342)) * make_float3(rnorm3df(((_S1342)).x, ((_S1342)).y, ((_S1342)).z))));
    bool _S1343 = (dot_0(cross_0(n_16, t_2), _S1341)) > 0.0f;
    float3  t_3;
    if(_S1343)
    {
        float3  _S1344 = negate_0(t_2);
        t_3 = _S1344;
    }
    else
    {
        t_3 = t_2;
    }
    float3  _S1345 = cross_0(n_16, t_3);
    return makeMatrix<float, 3, 3> (t_3, _S1345, n_16);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1346 = t1_0 - t0_0;
    float3  _S1347 = t2_2 - t0_0;
    float3  _S1348 = t2_2 - t1_0;
    float _S1349 = (F32_min((length_0(_S1346)), ((F32_min((length_0(_S1347)), (length_0(_S1348)))))));
    float3  _S1350 = make_float3 (distance_5(position_0, t0_0), distance_5(position_0, t1_0), distance_5(position_0, t2_2));
    float3  _S1351 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1352 = dot_0(geometry_n_5, _S1351);
    float3  _S1353 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1354 = dot_0(geometry_n_5, _S1353);
    float3  _S1355 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1356 = acos_0(abs_0(make_float3 (_S1352, _S1354, dot_0(geometry_n_5, _S1355))));
    float3  _S1357 = clamp_1(tan_0(_S1356), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_0(dot_0(_S1350 * _S1357, uvw_0), 0.0f, _S1349 * 0.125f);
}

__device__ float3  sampleHalfVector(float3  v_6, float3  n_i_5, float alpha_6, uint * random_state_15)
{
    float3  _S1358 = sampleMaterialHalfVector(v_6, n_i_5, alpha_6, AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f)), random_state_15);
    return _S1358;
}

__device__ float3  straightThrough(float3  dir_14, float3  n_17, BSDFMaterial material_16)
{
    float3  _S1359 = negate_0(dir_14);
    float _S1360 = sign_0(dot_0(n_17, _S1359));
    float3  _S1361 = n_17 * make_float3 (_S1360);
    AnisotropicFrame _S1362 = anisotropicFrame(material_16, _S1361);
    bool _S1363 = (_S1362.alphas.x) > 0.0f;
    if(_S1363)
    {
        float _S1364 = material_16.transmission * (1.0f - material_16.metallic);
        float3  _S1365 = negate_0(_S1361);
        float3  _S1366 = anisotropicLocal(dir_14, _S1362.tangent, _S1365);
        float _S1367 = anisotropicG1(_S1366, _S1362.alphas);
        return make_float3 (_S1364 * _S1367) * material_16.albedo;
    }
    float _S1368 = material_16.transmission * (1.0f - material_16.metallic);
    float _S1369 = material_16.roughness;
    float _S1370 = smithG1(_S1369 * _S1369, (F32_abs((dot_0(n_17, dir_14)))));
    return make_float3 (_S1368 * _S1370) * material_16.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_4, float3  out_dir_4, uint p_5, float w_2, float alpha_7, uint nt_0)
{
    uint _S1371 = p_5 % 4U;
    float _S1372 = w_2 * HAIR_WIDTHS_0[_S1371];
    float _S1373 = (F32_asin((clamp_0(dot_0(out_dir_4, t_4), -1.0f, 1.0f)))) - (F32_asin((clamp_0(dot_0(in_dir_11, t_4), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1371] * alpha_7;
    return ((F32_asinh((_S1373 / _S1372))) / (F32_asinh((3.14159274101257324f / _S1372))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_5, float3  out_dir_5, uint np_0)
{
    float3  _S1374 = worldToTangent(out_dir_5, t_5);
    float3  _S1375 = worldToTangent(in_dir_12, t_5);
    return (F32_frac((((F32_atan2((_S1374.z), (_S1374.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1375.z), (1.17549435082228751e-38f - _S1375.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_6, uint p_6, float row_0, float column_0, float w_3, float alpha_8, uint nt_1, uint np_1)
{
    float3  _S1376 = worldToTangent(in_dir_13, t_6);
    uint _S1377 = p_6 % 4U;
    float _S1378 = w_3 * HAIR_WIDTHS_0[_S1377];
    float _S1379 = (F32_asin((clamp_0(dot_0(in_dir_13, t_6), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1377] * alpha_8 + _S1378 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1378))))));
    float _S1380 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1376.z), (1.17549435082228751e-38f - _S1376.x)));
    float _S1381 = (F32_cos((_S1379)));
    float3  _S1382 = tangentToWorld(make_float3 (_S1381 * (F32_cos((_S1380))), (F32_sin((_S1379))), _S1381 * (F32_sin((_S1380)))), t_6);
    return _S1382;
}

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_5, float3  end_1)
{
    float _S1383 = sign_0(dot_0(light_n_0, start_5 - end_1));
    return light_n_0 * make_float3 (_S1383 * light_offset_0);
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_18, BSDFMaterial material_17, float coverage_1)
{
    float3  _S1384;
    if((material_17.ior) == 1.0f)
    {
        float3  _S1385 = straightThrough(toward_1, n_18, material_17);
        _S1384 = _S1385;
    }
    else
    {
        _S1384 = make_float3 (0.0f);
    }
    return _S1384 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_5, Shift shifted_0, float mis_0)
{
    Reservoir candidate_10 = r_5;
    float3  _S1386 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_10)->f = _S1386;
    float _S1387 = r_5.jac * shifted_0.jac;
    (&candidate_10)->jac = _S1387;
    offer(sel_3, candidate_10, make_float3 (mis_0) * shifted_0.f * make_float3 (r_5.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_6 = sel_4.r;
    float _S1388 = rgb_to_greyscale((&r_6)->f);
    float _S1389 = sel_4.w_sum / _S1388;
    bool _S1390 = _S1388 > 0.0f;
    float _S1391 = _slang_select(_S1390, _S1389,0.0f);
    (&r_6)->w = _S1391;
    (&r_6)->c = c_1;
    return r_6;
}

static __device__ float interpolate_0(float a_6, float b_9, float t_7)
{
    return a_6 + (b_9 - a_6) * t_7;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S1392 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S1392;
}

__device__ float2  temporalWeights(float c_2, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S1393 = c_2 * p_c_0;
    float _S1394 = c_t_0 * p_t_0;
    return make_float2 (_S1393 / (_S1393 + c_t_0 * g_previous_0), _S1394 / (_S1394 + c_2 * g_current_0));
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
    Domain _S1395 = dom_2;
    Reservoir _S1396 = r_7;
    Shift _S1397 = walk_0(&_S1395, &_S1396, replay_2, scale_2, sel_5);
    return _S1397;
}

__device__ Shift shift_hook(Domain dom_3, Reservoir r_8)
{
    Domain _S1398 = dom_3;
    Reservoir _S1399 = r_8;
    Shift _S1400 = shift_0(&_S1398, &_S1399);
    return _S1400;
}

#undef Matrix
