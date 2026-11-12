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

static __device__ float3  lightTransmittance_0(float3  origin_2, float3  smooth_n_0, float geometry_offset_0, float3  light_dir_0, ShadowContext * context_0, uint random_state_0)
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
        float3  _S42 = make_float3 (geometry_offset_0) * smooth_n_0;
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
    float3  _S55 = (fcptShadowTransmittanceIn((ray_1), (_S54), (_S50), (_S53), (random_state_0), (context_0->depth), (context_0->lobe), (surface_1), (context_0->length), (context_0->width), (skip_0)));
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
    uint _S162 = x_6 * 747796405U + 2891336453U;
    uint _S163 = ((_S162 >> ((_S162 >> 28U) + 4U)) ^ _S162) * 277803737U;
    return (_S163 >> 22U) ^ _S163;
}

static __device__ float random_0(uint * state_0)
{
    uint _S164 = hash(*state_0);
    *state_0 = _S164;
    return float((*state_0) >> int(8)) * 5.9604644775390625e-08f;
}

static __device__ Random Random_x24init_0(uint state_1, float value_0)
{
    Random _S165;
    (&_S165)->state = state_1;
    (&_S165)->value = value_0;
    return _S165;
}

__device__ Random pcg(uint state_2)
{
    uint _S166 = state_2;
    float value_1 = random_0(&_S166);
    return Random_x24init_0(_S166, value_1);
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
    float _S167;
    if(e_0 > 0.0f)
    {
        _S167 = 1.0f;
    }
    else
    {
        if(e_0 < 0.0f)
        {
            _S167 = -1.0f;
        }
        else
        {
            _S167 = 0.0f;
        }
    }
    return _S167;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S168;
    (&_S168)->tangent = tangent_0;
    (&_S168)->alphas = alphas_0;
    return _S168;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_0 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S169 = (F32_abs((dot_0(n_1, a_0)))) > 0.9999847412109375f;
    float3  a_1;
    if(_S169)
    {
        float3  _S170 = make_float3 (1.0f, 0.0f, 0.0f);
        a_1 = _S170;
    }
    else
    {
        a_1 = a_0;
    }
    float3  _S171 = cross_0(n_1, a_1);
    float3  _S172 = ((((_S171)) * make_float3(rnorm3df(((_S171)).x, ((_S171)).y, ((_S171)).z))));
    float3  _S173 = cross_0(n_1, _S172);
    return make_float3 (v_0.x) * _S172 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S173;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_1, float3  n_i_0)
{
    float _S174 = material_1.roughness;
    float _S175 = _S174 * _S174;
    bool _S176 = (material_1.anisotropy) == 0.0f;
    bool _S177;
    if(_S176)
    {
        _S177 = true;
    }
    else
    {
        _S177 = !(_S175 > 0.0f);
    }
    if(_S177)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S178 = material_1.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_1.tangent));
    float3  _S179 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S180 = (dot_0(_S178, _S178)) > 0.0f;
    float3  _S181 = _slang_select(_S180, _S178,_S179);
    float3  _S182 = ((((_S181)) * make_float3(rnorm3df(((_S181)).x, ((_S181)).y, ((_S181)).z))));
    float _S183 = 6.28318548202514648f * material_1.anisotropic_rotation;
    float _S184 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_1.anisotropy))))));
    float _S185 = 1.0f / _S184;
    bool _S186 = (material_1.anisotropy) < 0.0f;
    float _S187 = _slang_select(_S186, _S185,_S184);
    return AnisotropicFrame_x24init_0(_S182 * make_float3 ((F32_cos((_S183)))) + cross_0(n_i_0, _S182) * make_float3 ((F32_sin((_S183)))), make_float2 (_S175 / _S187, _S175 * _S187));
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
    float3  _S188 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S189 = ((((_S188)) * make_float3(rnorm3df(((_S188)).x, ((_S188)).y, ((_S188)).z))));
    float _S190 = _S189.x;
    float _S191 = _S189.y;
    float _S192 = _S190 * _S190 + _S191 * _S191;
    float3  _S193;
    if(_S192 > 0.0f)
    {
        float3  _S194 = make_float3 (- _S191, _S190, 0.0f);
        float _S195 = (rsqrtf((_S192)));
        _S193 = _S194 * make_float3 (_S195);
    }
    else
    {
        _S193 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S196 = cross_0(_S189, _S193);
    float _S197 = (F32_sqrt((U1_0)));
    float _S198 = 6.28318548202514648f * U2_0;
    float _S199 = _S197 * (F32_cos((_S198)));
    float t2_0 = _S197 * (F32_sin((_S198)));
    float _S200 = 0.5f * (1.0f + _S189.z);
    float t2_1 = (1.0f - _S200) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S199 * _S199)))))) + _S200 * t2_0;
    float3  _S201 = make_float3 (_S199) * _S193 + make_float3 (t2_1) * _S196;
    float _S202 = unshared_0(_S199);
    float _S203 = unshared_0(_S199);
    float3  _S204 = _S201 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S202 * _S203 - t2_1 * t2_1))))))) * _S189;
    float3  _S205 = make_float3 (alpha_0 * _S204.x, alpha_0 * _S204.y, (F32_max((0.0f), (_S204.z))));
    float3  _S206 = ((((_S205)) * make_float3(rnorm3df(((_S205)).x, ((_S205)).y, ((_S205)).z))));
    return _S206;
}

__device__ float3  sampleAnisotropicVNDF(float3  Ve_1, float2  alphas_1, float U1_1, float U2_1)
{
    float _S207 = alphas_1.x;
    float _S208 = alphas_1.y;
    float3  _S209 = make_float3 (_S207 * Ve_1.x, _S208 * Ve_1.y, Ve_1.z);
    float3  _S210 = ((((_S209)) * make_float3(rnorm3df(((_S209)).x, ((_S209)).y, ((_S209)).z))));
    float3  _S211 = sampleGGXVNDF(_S210, 1.0f, U1_1, U2_1);
    float3  _S212 = make_float3 (_S207 * _S211.x, _S208 * _S211.y, _S211.z);
    float3  _S213 = ((((_S212)) * make_float3(rnorm3df(((_S212)).x, ((_S212)).y, ((_S212)).z))));
    return _S213;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
{
    float3  a_2 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S214 = (F32_abs((dot_0(n_3, a_2)))) > 0.9999847412109375f;
    float3  a_3;
    if(_S214)
    {
        float3  _S215 = make_float3 (1.0f, 0.0f, 0.0f);
        a_3 = _S215;
    }
    else
    {
        a_3 = a_2;
    }
    float3  _S216 = cross_0(n_3, a_3);
    float3  _S217 = ((((_S216)) * make_float3(rnorm3df(((_S216)).x, ((_S216)).y, ((_S216)).z))));
    float3  _S218 = cross_0(n_3, _S217);
    return make_float3 (dot_0(v_1, _S217), dot_0(v_1, n_3), dot_0(v_1, _S218));
}

__device__ __forceinline__ float3  sampleMaterialHalfVector(float3  v_2, float3  n_i_1, float alpha_1, AnisotropicFrame frame_0, uint * random_state_1)
{
    Random _S219 = pcg(*random_state_1);
    Random _S220 = pcg(_S219.state);
    *random_state_1 = _S220.state;
    bool _S221 = (frame_0.alphas.x) > 0.0f;
    if(_S221)
    {
        float3  _S222 = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        float3  _S223 = sampleAnisotropicVNDF(_S222, frame_0.alphas, _S219.value, _S220.value);
        return make_float3 (_S223.x) * frame_0.tangent + make_float3 (_S223.y) * cross_0(n_i_1, frame_0.tangent) + make_float3 (_S223.z) * n_i_1;
    }
    float3  _S224 = worldToTangent(v_2, n_i_1);
    float3  _S225 = sampleGGXVNDF(float3 {_S224.x, _S224.z, _S224.y}, alpha_1, _S219.value, _S220.value);
    float3  _S226 = float3 {_S225.x, _S225.z, _S225.y};
    float3  _S227 = tangentToWorld(_S226, n_i_1);
    return _S227;
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
    float _S228 = dot_0(n_4, i_1);
    float _S229 = 1.0f - eta_0 * eta_0 * (1.0f - _S228 * _S228);
    if(_S229 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_1 - make_float3 (eta_0 * _S228 + (F32_sqrt((_S229)))) * n_4;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S230 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S231 = eta_i_0 / eta_o_0 * _S230;
    bool _S232 = _S231 < 1.0f;
    float kr_0;
    if(_S232)
    {
        float _S233 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S231 * _S231))))));
        float _S234 = eta_o_0 * cos_theta_0;
        float _S235 = eta_i_0 * _S233;
        float _S236 = (_S234 - _S235) / (_S234 + _S235);
        float _S237 = eta_i_0 * cos_theta_0;
        float _S238 = eta_o_0 * _S233;
        float _S239 = (_S237 - _S238) / (_S237 + _S238);
        float _S240 = (_S236 * _S236 + _S239 * _S239) / 2.0f;
        kr_0 = _S240;
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
    float _S241 = (F32_sqrt((0.05000000074505806f)));
    float _S242 = clamp_0((F32_sqrt(((F32_max((mu_0), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
    float _S243 = (clamp_0((F32_sqrt(((F32_max((r_0), (0.0f)))))), _S241, 1.0f) - _S241) / (1.0f - _S241) * 23.0f;
    uint _S244 = (U32_min((uint(_S242)), (22U)));
    uint _S245 = (U32_min((uint(_S243)), (22U)));
    float _S246 = _S242 - float(_S244);
    float _S247 = _S243 - float(_S245);
    uint _S248 = _S244 * 24U + _S245;
    uint _S249 = _S248 + 24U;
    float _S250 = SHEEN_ALBEDO_0[_S248] + (SHEEN_ALBEDO_0[_S249] - SHEEN_ALBEDO_0[_S248]) * _S246;
    uint _S251 = _S248 + 1U;
    float _S252 = SHEEN_ALBEDO_0[_S251] + (SHEEN_ALBEDO_0[_S249 + 1U] - SHEEN_ALBEDO_0[_S251]) * _S246;
    return (F32_exp((_S250 + (_S252 - _S250) * _S247)));
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

__device__ float anisotropicG1(float3  w_1, float2  alphas_2)
{
    float _S253 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S253 / (_S253 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S253)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S254 = alphas_3.x;
    float _S255 = h_0.x / _S254;
    float _S256 = alphas_3.y;
    float _S257 = h_0.y / _S256;
    float _S258 = h_0.z;
    float _S259 = _S255 * _S255 + _S257 * _S257 + _S258 * _S258;
    return 1.0f / (F32_max((3.14159274101257324f * _S254 * _S256 * _S259 * _S259), (1.17549435082228751e-38f)));
}

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_0, float3  refracted_1, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_0, float3  sheen_0, float3  view_0, float3  tangent_1, float2  alphas_4, float visible_0)
{
    BSDFLobes _S260;
    (&_S260)->v_dot_h = v_dot_h_0;
    (&_S260)->n_dot_h = n_dot_h_0;
    (&_S260)->refracted = refracted_1;
    (&_S260)->F = F_0;
    (&_S260)->F_greyscale = F_greyscale_0;
    (&_S260)->reflect_weight = reflect_weight_0;
    (&_S260)->diffuse_weight = diffuse_weight_0;
    (&_S260)->refract_weight = refract_weight_0;
    (&_S260)->p_diffuse = p_diffuse_0;
    (&_S260)->p_reflect = p_reflect_0;
    (&_S260)->p_refract = p_refract_0;
    (&_S260)->translucent_share = translucent_share_0;
    (&_S260)->sheen = sheen_0;
    (&_S260)->view = view_0;
    (&_S260)->tangent = tangent_1;
    (&_S260)->alphas = alphas_4;
    (&_S260)->visible = visible_0;
    return _S260;
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_0, float3  v_3, float3  n_i_2, float3  ggx_n_0, BSDFMaterial material_2, float eta_i_1, float eta_o_1, AnisotropicFrame frame_1)
{
    float _S261 = dot_0(ggx_n_0, v_3);
    float _S262 = dot_0(n_i_2, ggx_n_0);
    float _S263 = eta_i_1 / eta_o_1;
    float3  _S264 = refract_0(in_dir_0, ggx_n_0, _S263);
    float3  _S265 = ((((_S264)) * make_float3(rnorm3df(((_S264)).x, ((_S264)).y, ((_S264)).z))));
    float _S266 = (F32_min(((F32_sqrt((material_2.specular_level))) * (F32_abs((eta_i_1 - eta_o_1))) / (eta_i_1 + eta_o_1)), (0.9999847412109375f)));
    float _S267 = _S266 * _S266;
    float _S268 = (1.0f + _S266) / (1.0f - _S266);
    float _S269 = (F32_abs((_S261)));
    bool _S270 = eta_i_1 > eta_o_1;
    float sheen_component_0;
    if(_S270)
    {
        sheen_component_0 = _S268;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float visible_1;
    if(_S270)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S268;
    }
    float _S271 = fresnel(_S269, sheen_component_0, visible_1);
    bool _S272 = (eta_i_1 * eta_i_1 * (1.0f - _S261 * _S261)) >= (eta_o_1 * eta_o_1);
    float3  _S273;
    if(_S272)
    {
        _S273 = make_float3 (1.0f);
    }
    else
    {
        float3  _S274 = material_2.specular_tint * make_float3 (_S267);
        _S273 = _S274 + (make_float3 (1.0f) - _S274) * make_float3 (_S271 - _S267) / make_float3 (1.0f - _S267);
    }
    float3  _S275 = make_float3 (1.0f);
    float3  _S276 = make_float3 (0.0f);
    float _S277 = rgb_to_greyscale(material_2.sheen);
    bool _S278 = _S277 > 0.0f;
    float3  scale_0;
    float3  sheen_1;
    float3  view_1;
    if(_S278)
    {
        float _S279 = sheenAlbedo(dot_0(n_i_2, v_3), material_2.sheen_roughness);
        float _S280 = (F32_min((_S279), (1.0f)));
        float3  _S281 = make_float3 (1.0f) - material_2.sheen * make_float3 (_S280);
        float _S282 = rgb_to_greyscale(material_2.sheen);
        float _S283 = _S282 * _S280;
        float3  _S284 = material_2.sheen / make_float3 ((F32_max((_S279), (1.0f))));
        scale_0 = _S281;
        sheen_component_0 = _S283;
        sheen_1 = _S284;
        view_1 = v_3;
    }
    else
    {
        scale_0 = _S275;
        sheen_component_0 = 0.0f;
        sheen_1 = _S276;
        view_1 = _S276;
    }
    float3  _S285 = mix_0(_S273, material_2.albedo, material_2.metallic);
    float3  F_1 = _S285 * scale_0;
    float _S286 = rgb_to_greyscale(F_1);
    float _S287 = 1.0f - material_2.metallic;
    float3  _S288 = make_float3 (1.0f) - _S273;
    float3  _S289 = make_float3 ((1.0f - material_2.transmission) * _S287) * _S288 * scale_0;
    float3  _S290 = make_float3 (material_2.transmission * _S287) * _S288 * scale_0;
    float _S291 = (F32_max((_S286), (0.0f)));
    float _S292 = rgb_to_greyscale(_S289);
    float _S293 = (F32_max((_S292), (0.0f)));
    float _S294 = rgb_to_greyscale(_S290);
    float _S295 = sign_0(length_0(_S265));
    float _S296 = (F32_max((_S294 * _S295), (0.0f)));
    float _S297 = _S291 + _S293 + _S296 + sheen_component_0;
    float _S298 = 1.0f / (F32_max((_S297), (0.0000152587890625f)));
    float _S299 = (_S293 + sheen_component_0) * _S298;
    float _S300 = _S291 * _S298;
    float _S301 = _S296 * _S298;
    bool _S302 = (frame_1.alphas.x) > 0.0f;
    if(_S302)
    {
        float3  _S303 = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        float _S304 = anisotropicG1(_S303, frame_1.alphas);
        float3  _S305 = anisotropicLocal(ggx_n_0, frame_1.tangent, n_i_2);
        float _S306 = anisotropicD(_S305, frame_1.alphas);
        float _S307 = _S304 * _S306;
        visible_1 = _S307;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S261, _S262, _S265, F_1, _S286, 1.0f, _S289, _S290, _S299, _S300, _S301, 0.0f, sheen_1, view_1, frame_1.tangent, frame_1.alphas, visible_1);
}

__device__ float translucentShare(BSDFMaterial material_3)
{
    float _S308 = rgb_to_greyscale(material_3.translucent);
    float _S309 = rgb_to_greyscale(material_3.albedo);
    float _S310 = _S308 / (_S309 + _S308);
    bool _S311 = _S308 > 0.0f;
    float _S312 = _slang_select(_S311, _S310,0.0f);
    return _S312;
}

__device__ float smithG1(float alpha_2, float n_dot_x_0)
{
    float _S313 = alpha_2 * alpha_2;
    float _S314 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S313 + (1.0f - _S313) * n_dot_x_0 * n_dot_x_0))));
    bool _S315 = alpha_2 > 0.0f;
    float _S316 = _slang_select(_S315, _S314,1.0f);
    return _S316;
}

__device__ float trowbridgeReitz(float alpha_3, float n_dot_h_1)
{
    float _S317 = alpha_3 * alpha_3;
    float _S318 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S317 * n_dot_h_1 * n_dot_h_1;
    return _S317 / (F32_max((3.14159274101257324f * _S318 * _S318), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, BSDFLobes lobes_0, float eta_i_2, float eta_o_2, uint lobe_1)
{
    bool _S319 = lobe_1 == 0U;
    if(_S319)
    {
        float _S320 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        float _S321 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
        float _S322 = 1.0f - lobes_0.translucent_share;
        bool _S323 = n_i_dot_l_0 < 0.0f;
        float _S324 = _slang_select(_S323, lobes_0.translucent_share,_S322);
        float _S325 = _S321 * _S324;
        bool _S326 = (lobes_0.translucent_share) > 0.0f;
        float _S327 = _slang_select(_S326, _S325,_S320);
        bool _S328 = n_i_dot_v_0 > 0.0f;
        float _S329 = _slang_select(_S328, _S327,0.0f);
        return _S329;
    }
    float _S330 = smithG1(alpha_4, n_i_dot_v_0);
    float _S331 = _S330 * lobes_0.v_dot_h;
    float _S332 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    float _S333 = _S331 * _S332 / n_i_dot_v_0;
    bool _S334 = alpha_4 > 0.0f;
    bool _S335;
    if(_S334)
    {
        _S335 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S335 = false;
    }
    if(_S335)
    {
        _S335 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S335 = false;
    }
    if(_S335)
    {
        _S335 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S335 = false;
    }
    float _S336 = _slang_select(_S335, _S333,0.0f);
    bool _S337 = (lobes_0.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S337)
    {
        float _S338 = lobes_0.visible * lobes_0.v_dot_h / n_i_dot_v_0;
        bool _S339 = (lobes_0.v_dot_h) > 0.0f;
        if(_S339)
        {
            _S335 = (lobes_0.n_dot_h) > 0.0f;
        }
        else
        {
            _S335 = false;
        }
        if(_S335)
        {
            _S335 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S335 = false;
        }
        float _S340 = _slang_select(_S335, _S338,0.0f);
        pdf_h_0 = _S340;
    }
    else
    {
        pdf_h_0 = _S336;
    }
    bool _S341 = lobe_1 == 1U;
    if(_S341)
    {
        float _S342 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        float _S343 = lobes_0.p_refract * pdf_h_0 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S342 * _S342);
        bool _S344 = eta_i_2 != eta_o_2;
        if(_S344)
        {
            _S335 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S335 = false;
        }
        float _S345 = _slang_select(_S335, _S343,0.0f);
        return _S345;
    }
    float _S346 = lobes_0.p_reflect * pdf_h_0 / (4.0f * lobes_0.v_dot_h);
    bool _S347 = pdf_h_0 > 0.0f;
    float _S348 = _slang_select(_S347, _S346,0.0f);
    return _S348;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_0, uint random_state_2, bool refracted_2, uint lobe_2, float pdf_1)
{
    SampleBSDF _S349;
    (&_S349)->unit_direction = unit_direction_1;
    (&_S349)->throughput = throughput_0;
    (&_S349)->random_state = random_state_2;
    (&_S349)->refracted = refracted_2;
    (&_S349)->lobe = lobe_2;
    (&_S349)->pdf = pdf_1;
    return _S349;
}

__device__ float sheenBRDF(float3  l_1, float3  v_4, float3  n_5, float r_1)
{
    float _S350 = 1.0f / (F32_max((r_1), (0.05000000074505806f)));
    float3  _S351 = l_1 + v_4;
    float3  _S352 = ((((_S351)) * make_float3(rnorm3df(((_S351)).x, ((_S351)).y, ((_S351)).z))));
    float _S353 = dot_0(n_5, _S352);
    float _S354 = (F32_max((dot_0(n_5, l_1)), (0.0f)));
    float _S355 = (F32_max((dot_0(n_5, v_4)), (0.0f)));
    return (2.0f + _S350) * (F32_pow(((F32_max((1.0f - _S353 * _S353), (0.0f)))), (0.5f * _S350))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S354 + _S355 - _S354 * _S355)), (0.0000152587890625f)));
}

__device__ __forceinline__ float3  lobeThroughput(float3  l_2, float3  n_i_3, float alpha_5, BSDFMaterial material_4, BSDFLobes lobes_1, uint lobe_3)
{
    bool _S356 = lobe_3 == 0U;
    if(_S356)
    {
        bool _S357 = (dot_0(n_i_3, l_2)) < 0.0f;
        float3  _S358 = _slang_select(_S357, material_4.translucent,material_4.albedo);
        float _S359 = 1.0f - lobes_1.translucent_share;
        float _S360 = _slang_select(_S357, lobes_1.translucent_share,_S359);
        float3  _S361 = _S358 / make_float3 (_S360);
        bool _S362 = (lobes_1.translucent_share) > 0.0f;
        float3  _S363 = _slang_select(_S362, _S361,material_4.albedo);
        float _S364 = rgb_to_greyscale(material_4.sheen);
        bool _S365 = _S364 > 0.0f;
        bool _S366;
        if(_S365)
        {
            _S366 = !_S357;
        }
        else
        {
            _S366 = false;
        }
        if(_S366)
        {
            float3  _S367 = lobes_1.diffuse_weight * _S363;
            float3  _S368 = lobes_1.sheen * make_float3 (3.14159274101257324f);
            float _S369 = sheenBRDF(l_2, lobes_1.view, n_i_3, material_4.sheen_roughness);
            float3  _S370 = _S368 * make_float3 (_S369);
            float _S371 = _slang_select(_S362, _S359,1.0f);
            return (_S367 + _S370 / make_float3 (_S371)) / make_float3 (lobes_1.p_diffuse);
        }
        return lobes_1.diffuse_weight * _S363 / make_float3 (lobes_1.p_diffuse);
    }
    bool _S372 = lobe_3 == 1U;
    float G1_l_0;
    if(_S372)
    {
        float _S373 = - dot_0(n_i_3, l_2);
        float _S374 = smithG1(alpha_5, (F32_max((_S373), (0.0f))));
        bool _S375 = (lobes_1.alphas.x) > 0.0f;
        if(_S375)
        {
            float3  _S376 = negate_0(n_i_3);
            float3  _S377 = anisotropicLocal(l_2, lobes_1.tangent, _S376);
            float _S378 = anisotropicG1(_S377, lobes_1.alphas);
            G1_l_0 = _S378;
        }
        else
        {
            G1_l_0 = _S374;
        }
        return lobes_1.refract_weight * make_float3 (G1_l_0) * material_4.albedo / make_float3 (lobes_1.p_refract);
    }
    float _S379 = dot_0(n_i_3, l_2);
    float _S380 = smithG1(alpha_5, (F32_max((_S379), (0.0f))));
    bool _S381 = (lobes_1.alphas.x) > 0.0f;
    if(_S381)
    {
        float3  _S382 = anisotropicLocal(l_2, lobes_1.tangent, n_i_3);
        float _S383 = anisotropicG1(_S382, lobes_1.alphas);
        G1_l_0 = _S383;
    }
    else
    {
        G1_l_0 = _S380;
    }
    return make_float3 (lobes_1.reflect_weight * G1_l_0) * lobes_1.F / make_float3 (lobes_1.p_reflect);
}

__device__ __forceinline__ SampleBSDF connectBSDF(float3  in_dir_1, float3  out_dir_0, float3  n_6, BSDFMaterial material_5, float eta_i_3, float eta_o_3, uint lobe_4, uint random_init_0)
{
    uint random_state_3 = random_init_0;
    float3  _S384 = negate_0(in_dir_1);
    float _S385 = dot_0(n_6, _S384);
    float _S386 = sign_0(_S385);
    float3  _S387 = n_6 * make_float3 (_S386);
    float _S388 = material_5.roughness;
    float _S389 = _S388 * _S388;
    AnisotropicFrame _S390 = anisotropicFrame(material_5, _S387);
    float3  _S391 = _S384 + out_dir_0;
    float3  _S392 = ((((_S391)) * make_float3(rnorm3df(((_S391)).x, ((_S391)).y, ((_S391)).z))));
    bool _S393 = lobe_4 == 0U;
    float3  ggx_n_1;
    if(_S393)
    {
        float3  _S394 = sampleMaterialHalfVector(_S384, _S387, _S389, _S390, &random_state_3);
        ggx_n_1 = _S394;
    }
    else
    {
        bool _S395 = lobe_4 == 1U;
        if(_S395)
        {
            float3  _S396 = negate_0(make_float3 (eta_i_3) * _S384 + make_float3 (eta_o_3) * out_dir_0);
            float3  _S397 = ((((_S396)) * make_float3(rnorm3df(((_S396)).x, ((_S396)).y, ((_S396)).z))));
            float _S398 = sign_0(dot_0(_S396, _S387));
            float3  _S399 = _S397 * make_float3 (_S398);
            ggx_n_1 = _S399;
        }
        else
        {
            ggx_n_1 = _S392;
        }
    }
    BSDFLobes _S400 = bsdfLobes(in_dir_1, _S384, _S387, ggx_n_1, material_5, eta_i_3, eta_o_3, _S390);
    BSDFLobes lobes_2 = _S400;
    float _S401 = translucentShare(material_5);
    (&lobes_2)->translucent_share = _S401;
    float _S402 = lobeDensity(dot_0(_S387, out_dir_0), dot_0(out_dir_0, ggx_n_1), (F32_abs((_S385))), _S389, lobes_2, eta_i_3, eta_o_3, lobe_4);
    bool _S403 = !(_S402 > 0.0f);
    if(_S403)
    {
        float3  _S404 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S404, _S404, 0U, false, 0U, 0.0f);
    }
    float3  _S405 = lobeThroughput(out_dir_0, _S387, _S389, material_5, lobes_2, lobe_4);
    return SampleBSDF_x24init_0(out_dir_0, _S405, random_state_3, lobe_4 == 1U, lobe_4, _S402);
}

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_2, float3  dir_5, float3  n_7, BSDFMaterial material_6, float eta_i_4, float eta_o_4, bool refracted_3, float pdf_2, bool power_0, uint random_state_4)
{
    float3  _S406 = make_float3 (0.0f);
    uint lobe_5 = 0U;
    float3  f_0 = _S406;
    for(;;)
    {
        if(lobe_5 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S407 = lobe_5 == 0U;
        if(_S407)
        {
        }
        bool _S408;
        if(_S407)
        {
            float _S409 = rgb_to_greyscale(material_6.translucent);
            _S408 = _S409 > 0.0f;
        }
        else
        {
            _S408 = false;
        }
        bool _S410;
        if(_S408)
        {
            float _S411 = dot_0(n_7, dir_5);
            float3  _S412 = negate_0(in_dir_2);
            _S410 = ((_S411 * dot_0(n_7, _S412)) < 0.0f) == refracted_3;
        }
        else
        {
            _S410 = (lobe_5 == 1U) == refracted_3;
        }
        float3  f_1;
        if(_S410)
        {
            SampleBSDF _S413 = connectBSDF(in_dir_2, dir_5, n_7, material_6, eta_i_4, eta_o_4, lobe_5, random_state_4);
            bool _S414 = (_S413.pdf) > 0.0f;
            if(_S414)
            {
                if(power_0)
                {
                    float _S415 = _S413.pdf / pdf_2;
                    float3  f_2 = f_0 + _S413.throughput * make_float3 (_S413.pdf) / make_float3 (pdf_2 * (1.0f + _S415 * _S415));
                    f_1 = f_2;
                }
                else
                {
                    float3  f_3 = f_0 + _S413.throughput * make_float3 (_S413.pdf) / make_float3 (_S413.pdf + pdf_2);
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
    bool _S416 = wrongSide_0(is_inside_2, false, dir_6, side_n_1);
    float3  _S417 = neeBSDF(in_dir_3, dir_6, surface_2.smooth_n, surface_2.material, eta_1.x, eta_1.y, _S416, pdf_3, false, random_state_5);
    return _S417;
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
    SkySample _S418;
    (&_S418)->dir = dir_7;
    (&_S418)->radiance = radiance_0;
    (&_S418)->color = color_0;
    (&_S418)->random_state = random_state_6;
    return _S418;
}

static __device__ SkySample sampleSky_0(FKRay * ray_2, FKSurface * surface_3, float3  side_n_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0)
{
    uint2  _S419 = (fcptEnvironmentCdfSize());
    uint2  _S420 = make_uint2 (1U, 0U);
    uint2  _S421 = _S419 - _S420;
    Random _S422 = pcg(init_random_state_0);
    Random _S423 = pcg(_S422.state);
    Random _S424 = pcg(_S423.state);
    Random _S425 = pcg(_S424.state);
    uint _S426 = _S421.x;
    uint _S427 = searchCDF_0(make_uint2 (_S426, 0U), make_uint2 (0U, 1U), _S421.y, _S422.value);
    uint _S428 = searchCDF_0(make_uint2 (0U, _S427), _S420, _S426, _S423.value);
    float2  _S429 = make_float2 ((float)_S421.x, (float)_S421.y);
    float2  _S430 = (make_float2 (float(_S428), float(_S427)) + make_float2 (_S424.value, _S425.value)) / _S429 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S431 = _S430.y;
    float _S432 = (F32_sin((_S431)));
    float _S433 = _S430.x;
    float3  _S434 = make_float3 (_S432 * (F32_cos((_S433))), (F32_cos((_S431))), _S432 * (F32_sin((_S433))));
    float _S435 = environmentPdf_0(_S434);
    float3  _S436 = skyBSDF(ray_2->unit_direction, _S434, *surface_3, side_n_2, eta_2, is_inside_3, _S435, lobe_state_0);
    bool _S437 = !(_S435 > 0.0f);
    bool _S438;
    if(_S437)
    {
        _S438 = true;
    }
    else
    {
        _S438 = all_0(_S436 == make_float3 (0.0f));
    }
    if(_S438)
    {
        float3  _S439 = make_float3 (0.0f);
        return SkySample_x24init_0(_S434, _S439, _S439, _S425.state);
    }
    float3  _S440 = skyRadiance_0(ray_2->origin, surface_3, side_n_2, is_inside_3, _S434);
    return SkySample_x24init_0(_S434, _S440, _S436 * _S440, _S425.state);
}

struct TreeSample
{
    float3  dir;
    float3  radiance;
    float density;
    uint random_state;
};

static __device__ float3  hairLight_0(FKSurface * surface_4, float3  in_dir_4, TreeSample * light_0, bool competing_0)
{
    SampleBSDF _S441 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_4), (light_0->dir)));
    float3  _S442 = _S441.throughput * make_float3 (_S441.pdf);
    float _S443 = light_0->density;
    float _S444 = 1.0f + _S441.pdf * _S441.pdf / (light_0->density * light_0->density);
    bool _S445;
    if(competing_0)
    {
        _S445 = _S443 > 0.0f;
    }
    else
    {
        _S445 = false;
    }
    float _S446 = _slang_select(_S445, _S444,1.0f);
    return _S442 / make_float3 (_S446) * light_0->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_8, float3  radiance_1, float density_0, uint random_state_7)
{
    TreeSample _S447;
    (&_S447)->dir = dir_8;
    (&_S447)->radiance = radiance_1;
    (&_S447)->density = density_0;
    (&_S447)->random_state = random_state_7;
    return _S447;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_3, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S448 = importance(first_1, p_3, normal_3);
    float _S449 = importance(second_1, p_3, normal_3);
    float2  _S450 = make_float2 (_S448, _S449);
    bool _S451 = _S448 == 0.0f;
    bool _S452;
    if(_S451)
    {
        _S452 = _S449 == 0.0f;
    }
    else
    {
        _S452 = false;
    }
    if(_S452)
    {
        return 2U;
    }
    float _S453 = _S448 + _S449;
    bool _S454 = _S449 > 0.0f;
    if(_S454)
    {
        _S452 = (*pick_0 * _S453) >= _S448;
    }
    else
    {
        _S452 = false;
    }
    uint _S455 = uint(_S452);
    float _S456 = (F32_min(((*pick_0 * _S453 - float(_S455) * _S448) / _slang_vector_get_element(_S450, _S455)), (0.99999994039535522f)));
    *pick_0 = _S456;
    float _S457 = *probability_3 * (_slang_vector_get_element(_S450, _S455) / _S453);
    *probability_3 = _S457;
    return _S455;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_4, float u1_0, float u2_0)
{
    float3  _S458 = center_1 - p_4;
    float _S459 = radius_1 * radius_1 / dot_0(_S458, _S458);
    float _S460 = u1_0 * _S459 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S459), (0.0f)))))));
    float _S461 = 2.0f * u1_0;
    bool _S462 = _S459 >= 1.0f;
    float _S463 = _slang_select(_S462, _S461,_S460);
    float _S464 = (F32_sqrt(((F32_max((_S463 * (2.0f - _S463)), (0.0f))))));
    float _S465 = 6.28318548202514648f * u2_0;
    float3  _S466 = make_float3 (_S464 * (F32_cos((_S465))), 1.0f - _S463, _S464 * (F32_sin((_S465))));
    float3  _S467 = ((((_S458)) * make_float3(rnorm3df(((_S458)).x, ((_S458)).y, ((_S458)).z))));
    float3  _S468 = tangentToWorld(_S466, _S467);
    return _S468;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_3, float max_len_0)
{
    float3  _S469 = center_2 - ray_3->origin;
    float _S470 = dot_0(_S469, ray_3->unit_direction);
    float _S471 = dot_0(_S469, _S469) - _S470 * _S470;
    float _S472 = radius_3 * radius_3;
    bool _S473 = _S471 > _S472;
    if(_S473)
    {
        return 4.294967296e+09f;
    }
    float _S474 = (F32_sqrt((_S472 - _S471)));
    float _S475 = _S470 - _S474;
    float _S476 = _S470 + _S474;
    bool _S477 = _S475 > 0.0000152587890625f;
    bool _S478;
    if(_S477)
    {
        _S478 = _S475 < max_len_0;
    }
    else
    {
        _S478 = false;
    }
    if(_S478)
    {
        return _S475;
    }
    bool _S479 = _S476 > 0.0000152587890625f;
    if(_S479)
    {
        _S478 = _S476 < max_len_0;
    }
    else
    {
        _S478 = false;
    }
    if(_S478)
    {
        return _S476;
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
    Random _S480 = pcg(init_random_state_1);
    Random _S481 = pcg(_S480.state);
    Random _S482 = pcg(_S481.state);
    float3  _S483 = make_float3 (0.0f);
    TreeSample _S484 = TreeSample_x24init_0(_S483, _S483, 0.0f, _S482.state);
    TreeSample sample_0 = _S484;
    float3  _S485 = _slang_select(sided_0, _S483,smooth_n_2);
    bool _S486 = context_1->opaque;
    float3  lift_n_0;
    if(_S486)
    {
        float3  _S487 = context_1->lift;
        lift_n_0 = _S487;
    }
    else
    {
        lift_n_0 = smooth_n_2;
    }
    float3  start_2 = origin_4 + make_float3 (geometry_offset_1) * lift_n_0;
    float pick_1 = _S480.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S488 = (fcptLightNode((n_8)));
        if((_S488.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S489 = (fcptLightSecond((n_8)));
        uint _S490 = n_8 + 1U;
        LightNode _S491 = (fcptLightBounds((_S490)));
        LightNode _S492 = (fcptLightBounds((_S489)));
        uint _S493 = pickChild(_S491, _S492, origin_4, _S485, &pick_1, &probability_4);
        bool _S494 = _S493 > 1U;
        if(_S494)
        {
            return sample_0;
        }
        bool _S495 = _S493 == 1U;
        uint _S496 = _slang_select(_S495, _S489,_S490);
        n_8 = _S496;
    }
    bool _S497 = n_8 == 0U;
    bool _S498;
    if(_S497)
    {
        LightNode _S499 = (fcptLightBounds((0U)));
        float _S500 = importance(_S499, origin_4, _S485);
        _S498 = !(_S500 > 0.0f);
    }
    else
    {
        _S498 = false;
    }
    if(_S498)
    {
        return sample_0;
    }
    uint4  _S501 = (fcptLightNode((n_8)));
    FKHit _S502 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S503 = (_S501.x) == 2U;
    float3  emitter_point_0;
    float3  shadow_1;
    float3  start_3;
    FKHit emitter_0;
    if(_S503)
    {
        FKLight _S504 = (fcptLight((_S501.y)));
        if(sided_0)
        {
            _S498 = !_S486;
        }
        else
        {
            _S498 = false;
        }
        if(_S498)
        {
            float _S505 = sign_0(dot_0(geometry_n_1, _S504.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S505);
            float3  _S506 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S506;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = start_2;
        }
        bool _S507 = (_S504.variance) == 0.0f;
        if(_S507)
        {
            float3  _S508 = _S504.position - emitter_point_0;
            float3  _S509 = ((((_S508)) * make_float3(rnorm3df(((_S508)).x, ((_S508)).y, ((_S508)).z))));
            (&sample_0)->dir = _S509;
            float3  _S510 = _S504.color * make_float3 (_S504.intensity) / make_float3 (dot_0(_S508, _S508) * probability_4);
            (&sample_0)->radiance = _S510;
            shadow_1 = _S508;
        }
        else
        {
            float3  _S511 = sampleSphere(_S504.position, _S504.variance, emitter_point_0, _S481.value, _S482.value);
            (&sample_0)->dir = _S511;
            float _S512 = sphereDensity(_S504.position, _S504.variance, emitter_point_0);
            float _S513 = probability_4 * _S512;
            (&sample_0)->density = _S513;
            float3  _S514 = pointLightRadiance(_S504.color, _S504.intensity, _S504.variance);
            float3  _S515 = _S514 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S515;
            FKRay _S516 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S517 = raySphere_0(_S504.position, _S504.variance, &_S516, 4.294967296e+09f);
            float3  _S518 = (&sample_0)->dir * make_float3 (_S517);
            shadow_1 = _S518;
        }
        float3  _S519 = emitter_point_0;
        emitter_0 = _S502;
        emitter_point_0 = _S483;
        start_3 = _S519;
    }
    else
    {
        uint _S520 = _S501.y;
        uint _S521 = (fcptTriangleOffset((_S520)));
        uint _S522 = _S521 + _S501.z;
        Matrix<float, 3, 3>  _S523 = (fcptWorldTriangle((_S520), (_S522)));
        float _S524 = (F32_sqrt((_S481.value)));
        float2  _S525 = make_float2 (_S524 * (1.0f - _S482.value), _S524 * _S482.value);
        float3  _S526 = mul_0(make_float3 (1.0f - _S524, _S525.x, _S525.y), _S523);
        if(sided_0)
        {
            _S498 = !_S486;
        }
        else
        {
            _S498 = false;
        }
        if(_S498)
        {
            float _S527 = sign_0(dot_0(geometry_n_1, _S526 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S527);
            float3  _S528 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S528;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S529 = !((dot_0(smooth_n_2, _S526 - start_2)) > 0.0f);
            if(_S529)
            {
                return sample_0;
            }
            emitter_point_0 = start_2;
        }
        FKHit _S530 = Hit_x24init_0(_S525, _S520, _S522, 0U, 0.0f);
        float3  _S531 = _S526 - emitter_point_0;
        float3  _S532 = ((((_S531)) * make_float3(rnorm3df(((_S531)).x, ((_S531)).y, ((_S531)).z))));
        (&sample_0)->dir = _S532;
        float _S533 = solidAngle(probability_4, cross_0(_S523.rows[int(1)] - _S523.rows[int(0)], _S523.rows[int(2)] - _S523.rows[int(0)]), _S531);
        (&sample_0)->density = _S533;
        float3  _S534 = emitter_point_0;
        shadow_1 = _S531;
        emitter_0 = _S530;
        emitter_point_0 = _S526;
        start_3 = _S534;
    }
    float3  _S535 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_1, _S482.state);
    bool _S536 = (emitter_0.instance_index) != 4294967295U;
    if(_S536)
    {
        _S498 = !all_0(_S535 == _S483);
    }
    else
    {
        _S498 = false;
    }
    if(_S498)
    {
        float3  _S537 = emitter_point_0 - start_3;
        float3  _S538 = ((((_S537)) * make_float3(rnorm3df(((_S537)).x, ((_S537)).y, ((_S537)).z))));
        FKSurface _S539 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S482.state), (_S538), (context_1->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S539.random_state;
        float3  _S540 = _slang_select(_S539.skip, _S483,_S539.material.emissive);
        float3  _S541 = _S540 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S541;
    }
    float3  _S542 = (&sample_0)->radiance * _S535;
    bool _S543 = all_0(_S535 == _S483);
    float3  _S544 = _slang_select(_S543, _S483,_S542);
    (&sample_0)->radiance = _S544;
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
    float _S545 = 1.0f / (1.0f + b_0 / a_4 * (b_0 / a_4));
    bool _S546 = b_0 > 0.0f;
    float _S547 = _slang_select(_S546, _S545,1.0f);
    return _S547;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_0, float3  light_point_1)
{
    bool _S548 = vertex_0->none;
    if(_S548)
    {
        return 1.0f;
    }
    uint _S549 = (fcptLightSlot((*hit_0)));
    float _S550 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S549, light_point_1);
    float _S551 = powerHeuristic(vertex_0->pdf, _S550);
    return _S551;
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
    Shift _S552;
    (&_S552)->f = f_4;
    (&_S552)->jac = jac_0;
    return _S552;
}

static __device__ uint extractBits_0(uint e_1, uint offset_0, uint count_1)
{
    return (e_1 >> offset_0) & ((1U << count_1) - 1U);
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_4)
{
    NEEVertex _S553;
    (&_S553)->none = none_0;
    (&_S553)->pdf = pdf_4;
    (&_S553)->origin = origin_5;
    (&_S553)->smooth_n = smooth_n_3;
    (&_S553)->start = start_4;
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

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_7, float pdf_5, float cos_0, bool inside_0)
{
    Vertex _S554;
    (&_S554)->rough = rough_0;
    (&_S554)->lobe = lobe_7;
    (&_S554)->pdf = pdf_5;
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

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_8, bool surface_5, float length_2, float width_0, bool opaque_0, float3  lift_0, FKHit * own_0, bool fiber_0, bool faced_0)
{
    ShadowContext _S565;
    (&_S565)->extinction_behind = extinction_behind_0;
    (&_S565)->extinction_front = extinction_front_0;
    (&_S565)->fillings = fillings_0;
    (&_S565)->side = side_0;
    (&_S565)->depth = depth_1;
    (&_S565)->lobe = lobe_8;
    (&_S565)->surface = surface_5;
    (&_S565)->length = length_2;
    (&_S565)->width = width_0;
    (&_S565)->opaque = opaque_0;
    (&_S565)->lift = lift_0;
    (&_S565)->own = *own_0;
    (&_S565)->fiber = fiber_0;
    (&_S565)->faced = faced_0;
    return _S565;
}

__device__ float3  safeDivide(float3  a_5, float3  b_3)
{
    float3  _S566 = a_5 / b_3;
    float3  _S567 = make_float3 (0.0f);
    bool3  _S568 = b_3 == _S567;
    float3  _S569 = _slang_select(_S568, _S567,_S566);
    return _S569;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S570 = (1U << count_2) - 1U;
    return (e_2 & (~(_S570 << offset_1))) | ((newbits_0 & _S570) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_0 = r_2;
    uint _S571 = insertBits_0(r_2.path, end_0, 0U, 5U);
    uint _S572 = insertBits_0(_S571, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S572;
    (&candidate_0)->f = f_5;
    return candidate_0;
}

__device__ void offer(Selection * sel_0, Reservoir candidate_1, float3  weight_0)
{
    float _S573 = rgb_to_greyscale(weight_0);
    bool _S574 = _S573 > 0.0f;
    bool _S575;
    if(_S574)
    {
        _S575 = _S573 < 3.00000000549775576e+38f;
    }
    else
    {
        _S575 = false;
    }
    bool _S576 = !_S575;
    if(_S576)
    {
        return;
    }
    bool _S577 = sel_0->sums;
    if(_S577)
    {
        float3  _S578 = sel_0->color + weight_0;
        sel_0->color = _S578;
        return;
    }
    float _S579 = sel_0->w_sum + _S573;
    sel_0->w_sum = _S579;
    float3  _S580 = sel_0->color + weight_0;
    sel_0->color = _S580;
    Random _S581 = pcg(sel_0->random_state);
    sel_0->random_state = _S581.state;
    bool _S582 = (_S581.value * sel_0->w_sum) <= _S573;
    if(_S582)
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
    Random _S583 = pcg(random_state_8);
    Random _S584 = pcg(_S583.state);
    float _S585 = 1.0f - 2.0f * _S583.value;
    float _S586 = (F32_sqrt(((F32_max((1.0f - _S585 * _S585), (0.0f))))));
    float _S587 = 6.28318548202514648f * _S584.value;
    return make_float3 (_S586 * (F32_cos((_S587))), _S586 * (F32_sin((_S587))), _S585);
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2)
{
    BSDFMaterial _S588;
    (&_S588)->albedo = albedo_0;
    (&_S588)->emissive = emissive_0;
    (&_S588)->roughness = roughness_0;
    (&_S588)->metallic = metallic_0;
    (&_S588)->transmission = transmission_0;
    (&_S588)->ior = ior_0;
    (&_S588)->absorption = absorption_0;
    (&_S588)->specular_tint = specular_tint_0;
    (&_S588)->specular_level = specular_level_0;
    (&_S588)->translucent = translucent_0;
    (&_S588)->sheen = sheen_2;
    (&_S588)->sheen_roughness = sheen_roughness_0;
    (&_S588)->anisotropy = anisotropy_0;
    (&_S588)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S588)->tangent = tangent_2;
    return _S588;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1)
{
    FKMedium _S589;
    (&_S589)->scatter = scatter_1;
    (&_S589)->extinction = extinction_1;
    return _S589;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_7, bool skip_1, uint random_state_9, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S590;
    (&_S590)->smooth_n = smooth_n_4;
    (&_S590)->geometry_n = geometry_n_2;
    (&_S590)->geometry_offset = geometry_offset_2;
    (&_S590)->material = *material_7;
    (&_S590)->skip = skip_1;
    (&_S590)->random_state = random_state_9;
    (&_S590)->coverage = coverage_0;
    (&_S590)->encloses = encloses_0;
    (&_S590)->volume = *volume_0;
    (&_S590)->fills = fills_0;
    (&_S590)->hair = hair_0;
    return _S590;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S591 = (&surface_6->material)->emissive;
    float3  _S592 = make_float3 (0.0f);
    bool _S593 = !top_0;
    float3  _S594 = _slang_select(_S593, _S592,_S591);
    (&(&lower_0)->material)->emissive = _S594;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_2)
{
    float _S595 = surface_7->coverage;
    bool _S596 = u_2 < _S595;
    if(_S596)
    {
        return *surface_7;
    }
    float3  _S597 = make_float3 (0.0f);
    float3  _S598 = make_float3 (1.0f);
    BSDFMaterial _S599 = Material_x24init_0(_S597, _S597, 0.0f, 0.0f, 0.0f, 0.0f, _S597, _S598, 1.0f, _S597, _S597, 0.5f, 0.0f, 0.0f, _S597);
    BSDFMaterial material_8 = _S599;
    (&material_8)->albedo = _S598;
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
    bool _S600 = transmission_1 > 0.0f;
    bool _S601;
    if(_S600)
    {
        _S601 = true;
    }
    else
    {
        _S601 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S602;
    if(_S601)
    {
        _S602 = 1.0f;
    }
    else
    {
        _S602 = -1.0f;
    }
    return _S602;
}

static __device__ bool arrivesBehind_0(float3  dir_9, float3  n_9)
{
    return (dot_0(dir_9, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_10)
{
    float3  _S603 = surface_8->geometry_n;
    float _S604 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_10);
    FKSurface faced_1 = *surface_8;
    float3  _S605 = surface_8->smooth_n * make_float3 (_S604);
    (&faced_1)->smooth_n = _S605;
    float3  _S606 = _S603 * make_float3 (_S604);
    (&faced_1)->geometry_n = _S606;
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
    float3  _S607 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_2) * log_0(_S607));
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
    bool _S608;
    if(open_0)
    {
        _S608 = prev_rough_0;
    }
    else
    {
        _S608 = false;
    }
    if(_S608)
    {
        _S608 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S608 = false;
    }
    return _S608;
}

static __device__ float2  vertexEta_0(BSDFMaterial * material_9, float n_dot_v_0)
{
    bool _S609 = n_dot_v_0 < 0.0f;
    float _S610 = material_9->ior;
    float _S611 = _slang_select(_S609, _S610,1.0f);
    float _S612 = _slang_select(_S609, 1.0f,_S610);
    return make_float2 (_S611, _S612);
}

__device__ bool samplesLights(BSDFMaterial material_10)
{
    bool _S613 = (material_10.roughness) > 0.0f;
    bool _S614;
    if(_S613)
    {
        _S614 = true;
    }
    else
    {
        bool _S615 = (material_10.metallic) < 1.0f;
        if(_S615)
        {
            _S614 = (material_10.transmission) < 1.0f;
        }
        else
        {
            _S614 = false;
        }
    }
    return _S614;
}

__device__ float3  sideNormal(FKSurface surface_9, float3  in_dir_5)
{
    bool _S616 = !((surface_9.material.transmission) > 0.0f);
    bool _S617;
    if(_S616)
    {
        BSDFMaterial _S618 = surface_9.material;
        bool _S619 = isTranslucent_0(&_S618);
        _S617 = !_S619;
    }
    else
    {
        _S617 = false;
    }
    if(_S617)
    {
        _S617 = (dot_0(surface_9.smooth_n, - in_dir_5)) > 0.0f;
    }
    else
    {
        _S617 = false;
    }
    float3  _S620 = _slang_select(_S617, surface_9.smooth_n,surface_9.geometry_n);
    return _S620;
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
    MediumSides _S621;
    (&_S621)->behind = *behind_0;
    (&_S621)->front = *front_1;
    (&_S621)->fillings = fillings_1;
    (&_S621)->face = face_1;
    return _S621;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_10, FKMedium * medium_0, uint filling_0, float3  dir_11)
{
    float3  _S622 = surface_10->geometry_n;
    MediumSides _S623 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_10->geometry_n);
    MediumSides sides_0 = _S623;
    bool _S624 = surface_10->encloses;
    if(_S624)
    {
        (&sides_0)->behind = surface_10->volume;
        *&((&(&sides_0)->fillings)->x) = surface_10->fills;
        bool _S625 = (dot_0(dir_11, _S622)) > 0.0f;
        if(_S625)
        {
            float3  _S626 = make_float3 (0.0f);
            FKMedium _S627 = Medium_x24init_0(_S626, _S626);
            (&sides_0)->front = _S627;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_11, bool turned_0, float3  side_n_3, float3  extinction_2, uint filling_1, float3  dir_12, uint depth_2, uint lobe_9, float length_3, float width_1, bool opaque_1, float3  lift_1, FKHit * own_1, bool fiber_1)
{
    FKSurface faced_2 = *surface_11;
    float3  _S628 = surface_11->geometry_n;
    float3  _S629 = - surface_11->geometry_n;
    float3  _S630 = _slang_select(turned_0, _S629,_S628);
    (&faced_2)->geometry_n = _S630;
    FKMedium _S631 = Medium_x24init_0(make_float3 (0.0f), extinction_2);
    FKSurface _S632 = faced_2;
    FKMedium _S633 = _S631;
    MediumSides _S634 = mediumSides_0(&_S632, &_S633, filling_1, dir_12);
    ShadowContext _S635 = ShadowContext_x24init_0(_S634.behind.extinction, _S634.front.extinction, _S634.fillings, side_n_3, depth_2, lobe_9, true, length_3, width_1, opaque_1, lift_1, own_1, fiber_1, true);
    ShadowContext context_2 = _S635;
    if(turned_0)
    {
        uint2  _S636 = _S634.fillings;
        ShadowContext _S637 = ShadowContext_x24init_0(_S634.front.extinction, _S634.behind.extinction, uint2 {_S636.y, _S636.x}, side_n_3, depth_2, lobe_9, true, length_3, width_1, opaque_1, lift_1, own_1, fiber_1, true);
        context_2 = _S637;
    }
    bool _S638 = isTranslucent_0(&surface_11->material);
    bool _S639 = !_S638;
    (&context_2)->faced = _S639;
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
    float3  _S640 = negate_0(in_dir_6);
    bool _S641 = (dot_0(g_n_0, _S640) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S641)
    {
        SampleBSDF _S642 = connectBSDF(in_dir_6, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 0U, random_state_10);
        SampleBSDF _S643 = connectBSDF(in_dir_6, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 2U, random_state_10);
        return _S642.throughput * make_float3 (_S642.pdf) + _S643.throughput * make_float3 (_S643.pdf);
    }
    SampleBSDF _S644 = connectBSDF(in_dir_6, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 1U, random_state_10);
    return _S644.throughput * make_float3 (_S644.pdf);
}

__device__ float3  translucentCorrection(float3  in_dir_7, float3  out_dir_2, float3  n_11, float3  g_n_1, BSDFMaterial material_12, float eta_i_6, float eta_o_6, uint random_state_11)
{
    float _S645 = dot_0(n_11, out_dir_2);
    float3  _S646 = negate_0(in_dir_7);
    bool _S647 = (_S645 * dot_0(n_11, _S646)) < 0.0f;
    SampleBSDF _S648 = connectBSDF(in_dir_7, out_dir_2, n_11, material_12, eta_i_6, eta_o_6, 0U, random_state_11);
    float3  _S649 = negate_0(in_dir_7);
    bool _S650 = (dot_0(g_n_1, _S649) * dot_0(g_n_1, out_dir_2)) > 0.0f;
    float3  _S651 = make_float3 (0.0f);
    float3  _S652 = _S648.throughput * make_float3 (_S648.pdf);
    float _S653 = _slang_select(_S650, -1.0f,1.0f);
    float3  _S654 = _S652 * make_float3 (_S653);
    float3  _S655 = _slang_select(_S647, _S654,_S651);
    return _S655;
}

__device__ float3  translucentBSDF(float3  in_dir_8, float3  out_dir_3, float3  n_12, float3  g_n_2, BSDFMaterial material_13, float eta_i_7, float eta_o_7, uint random_state_12)
{
    float3  _S656 = BSDF(in_dir_8, out_dir_3, n_12, g_n_2, material_13, eta_i_7, eta_o_7, random_state_12);
    float3  _S657 = translucentCorrection(in_dir_8, out_dir_3, n_12, g_n_2, material_13, eta_i_7, eta_o_7, random_state_12);
    return _S656 + _S657;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_9, TreeSample * light_1, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_14, float eta_i_8, float eta_o_8, bool competing_1, uint random_state_13)
{
    bool _S658 = !competing_1;
    bool _S659;
    if(_S658)
    {
        _S659 = true;
    }
    else
    {
        _S659 = (light_1->density) == 0.0f;
    }
    if(_S659)
    {
        bool _S660 = isTranslucent_0(material_14);
        if(_S660)
        {
            float3  _S661 = translucentBSDF(in_dir_9, light_1->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_8, eta_o_8, random_state_13);
            return _S661 * light_1->radiance;
        }
        float3  _S662 = BSDF(in_dir_9, light_1->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_8, eta_o_8, random_state_13);
        return _S662 * light_1->radiance;
    }
    float3  _S663 = light_1->dir;
    bool _S664 = (dot_0(geometry_n_4, - in_dir_9) * dot_0(geometry_n_4, light_1->dir)) <= 0.0f;
    float3  _S665 = neeBSDF(in_dir_9, _S663, smooth_n_5, *material_14, eta_i_8, eta_o_8, _S664, light_1->density, true, random_state_13);
    return _S665 * light_1->radiance * make_float3 (light_1->density);
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S666 = (F32_sqrt((random_1_0)));
    float _S667 = 6.28318548202514648f * random_2_0;
    float _S668 = _S666 * (F32_cos((_S667)));
    float _S669 = _S666 * (F32_sin((_S667)));
    float _S670 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S668 * _S668 - _S669 * _S669))))));
    return make_float3 (_S668, _S670, _S669);
}

static __device__ float3  reflect_0(float3  i_9, float3  n_13)
{
    return i_9 - make_float3 (2.0f * dot_0(n_13, i_9)) * n_13;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_14, BSDFMaterial material_15, float eta_i_9, float eta_o_9, uint random_init_1, float2  screen_space_0)
{
    uint random_state_14 = random_init_1;
    float3  _S671 = negate_0(in_dir_10);
    float _S672 = dot_0(n_14, _S671);
    float _S673 = sign_0(_S672);
    float3  n_i_4 = n_14 * make_float3 (_S673);
    float _S674 = (F32_abs((_S672)));
    float _S675 = material_15.roughness;
    float _S676 = _S675 * _S675;
    AnisotropicFrame _S677 = anisotropicFrame(material_15, n_i_4);
    float3  _S678 = sampleMaterialHalfVector(_S671, n_i_4, _S676, _S677, &random_state_14);
    BSDFLobes _S679 = bsdfLobes(in_dir_10, _S671, n_i_4, _S678, material_15, eta_i_9, eta_o_9, _S677);
    BSDFLobes lobes_3 = _S679;
    float _S680 = translucentShare(material_15);
    (&lobes_3)->translucent_share = _S680;
    float3  _S681 = make_float3 (1.0f);
    SampleBSDF _S682 = SampleBSDF_x24init_0(_S681, _S681, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S682;
    Random _S683 = pcg(random_state_14);
    random_state_14 = _S683.state;
    bool _S684 = (_S683.value) < ((&lobes_3)->p_diffuse);
    if(_S684)
    {
        Random _S685 = pcg(random_state_14);
        Random _S686 = pcg(_S685.state);
        (&sample_1)->random_state = _S686.state;
        float3  _S687 = sampleCosWeightedHemisphere(_S685.value, _S686.value);
        bool _S688 = (_S683.value) < ((&lobes_3)->p_diffuse * (&lobes_3)->translucent_share);
        float _S689 = _S687.y;
        float _S690 = - _S689;
        float _S691 = _slang_select(_S688, _S690,_S689);
        float3  _S692 = tangentToWorld(make_float3 (_S687.x, _S691, _S687.z), n_i_4);
        (&sample_1)->unit_direction = _S692;
        float3  _S693 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S676, material_15, lobes_3, 0U);
        (&sample_1)->throughput = _S693;
        float _S694 = lobeDensity(_S691, 0.0f, _S674, _S676, lobes_3, eta_i_9, eta_o_9, 0U);
        (&sample_1)->pdf = _S694;
        (&sample_1)->refracted = _S688;
        return sample_1;
    }
    bool _S695 = (_S683.value) < ((&lobes_3)->p_diffuse + (&lobes_3)->p_refract);
    if(_S695)
    {
        (&sample_1)->unit_direction = (&lobes_3)->refracted;
        float _S696 = lobeDensity(0.0f, dot_0((&sample_1)->unit_direction, _S678), _S674, _S676, lobes_3, eta_i_9, eta_o_9, 1U);
        (&sample_1)->pdf = _S696;
        float3  _S697 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S676, material_15, lobes_3, 1U);
        (&sample_1)->throughput = _S697;
        (&sample_1)->random_state = random_state_14;
        (&sample_1)->refracted = true;
        (&sample_1)->lobe = 1U;
        return sample_1;
    }
    float3  _S698 = reflect_0(in_dir_10, _S678);
    float3  _S699 = ((((_S698)) * make_float3(rnorm3df(((_S698)).x, ((_S698)).y, ((_S698)).z))));
    (&sample_1)->unit_direction = _S699;
    float3  _S700 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S676, material_15, lobes_3, 2U);
    (&sample_1)->throughput = _S700;
    (&sample_1)->random_state = random_state_14;
    (&sample_1)->lobe = 2U;
    float _S701 = lobeDensity(0.0f, 0.0f, _S674, _S676, lobes_3, eta_i_9, eta_o_9, 2U);
    (&sample_1)->pdf = _S701;
    return sample_1;
}

__device__ bool withinInverseFootprint(float pdf_6, bool diffuse_0, float prev_cos_0, float distance_4, float threshold_1)
{
    bool _S702 = pdf_6 > 0.0f;
    bool _S703;
    if(_S702)
    {
        if(diffuse_0)
        {
            _S703 = true;
        }
        else
        {
            _S703 = (pdf_6 * prev_cos_0 / (distance_4 * distance_4) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S703 = false;
    }
    return _S703;
}

__device__ bool roughLobe(float pdf_7, bool diffuse_1, float roughness_1)
{
    bool _S704 = pdf_7 > 0.0f;
    bool _S705;
    if(_S704)
    {
        if(diffuse_1)
        {
            _S705 = true;
        }
        else
        {
            _S705 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S705 = false;
    }
    return _S705;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S706 = layers_0 > 1U;
    bool _S707;
    if(_S706)
    {
        _S707 = refracting_0 != passed_0;
    }
    else
    {
        _S707 = false;
    }
    return _S707;
}

static __device__ float widened_0(float spread_0, float pdf_8, bool delta_0)
{
    float _S708 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_8))))), (3.14159274101257324f)));
    bool _S709 = !delta_0;
    float _S710 = _slang_select(_S709, _S708,0.0f);
    return spread_0 + _S710;
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
    int _S711;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_3;
    float sky_pdf_1;
    float width_4;
    float spread_3;
    uint b_5;
    Shift arrived_end_0;
    float3  _S712 = make_float3 (0.0f);
    Shift _S713 = Shift_x24init_0(_S712, 0.0f);
    uint _S714 = r_3->path;
    uint _S715 = extractBits_0(r_3->path, 0U, 5U);
    uint _S716 = extractBits_0(_S714, 5U, 5U);
    uint _S717 = extractBits_0(_S714, 10U, 2U);
    uint _S718 = extractBits_0(_S714, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S719 = _S718 >= 3U;
        uint _S720 = _slang_select(_S719, 1U,0U);
        uint _S721 = _S715 + _S720;
        uint _S722 = (fcptMaxBounces());
        passes_0 = _S721 > _S722;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S713;
    }
    uint _S723 = _S716 - 1U;
    bool _S724 = _S718 == 3U;
    uint _S725 = _slang_select(_S724, 1U,0U);
    uint _S726 = _S715 + _S725;
    bool _S727 = _S717 == 0U;
    uint _S728 = _slang_select(_S727, _S726,_S723);
    FKHit _S729 = (fcptReservoirHit((*r_3)));
    float3  _S730 = dom_0->x0;
    float3  _S731 = dom_0->x1 - dom_0->x0;
    float3  _S732 = ((((_S731)) * make_float3(rnorm3df(((_S731)).x, ((_S731)).y, ((_S731)).z))));
    FKRay _S733 = Ray_x24init_0(dom_0->x1, _S732);
    FKRay ray_4 = _S733;
    FKHit hit_1 = dom_0->hit;
    float3  scatter_in_0 = _S712;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S712;
    float3  extinction_in_0 = _S712;
    uint filling_2 = 4294967295U;
    float _S734 = dom_0->spread;
    float _S735 = dom_0->width;
    float _S736 = length_0(_S731);
    NEEVertex _S737 = NEEVertex_x24init_0(true, 0.0f, _S712, _S712, _S712);
    NEEVertex nee_vertex_0 = _S737;
    Vertex _S738 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S738;
    Reservoir _S739 = (Reservoir{});
    Reservoir chain_0 = _S739;
    uint _S740 = r_3->seed;
    (&chain_0)->seed = r_3->seed;
    (&ray_4)->origin = _S730;
    (&hit_1)->distance = _S736;
    FKMedium _S741 = (fcptCameraMedium(((&ray_4)->unit_direction), ((&hit_1)->distance), (&filling_2)));
    scatter_in_0 = _S741.scatter;
    extinction_in_0 = _S741.extinction;
    Reservoir _S742 = chain_0;
    uint _S743 = filling_2;
    for(;;)
    {
        bool _S744 = _S743 != 4294967295U;
        if(_S744)
        {
            float _S745 = (fcptMajorant((_S743)));
            spread_1 = _S745;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            passes_0 = 4294967295U == _S728;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            passes_0 = _S717 == 1U;
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
            ended_0 = _S713;
            sky_pdf_0 = 0.0f;
            spread_1 = _S734;
            width_2 = _S735;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_4 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S746 = (&prev_0)->rough;
        if(_S746)
        {
            passes_0 = !(spread_1 > 0.0f);
        }
        else
        {
            passes_0 = false;
        }
        (&prev_0)->rough = passes_0;
        uint _S747 = stream(_S740, 384U);
        uint tracking_0 = _S747;
        weight_1 = throughput_3;
        glowed_0 = _S712;
        b_4 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_2 = _S734;
        width_2 = _S735;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_1)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S711 = int(1);
                break;
            }
            uint _S748 = b_4 + 320U;
            bool _S749 = b_4 == 4294967295U;
            uint _S750 = _slang_select(_S749, 384U,_S748);
            uint _S751 = stream(_S740, _S750);
            Random _S752 = pcg(_S751);
            float _S753 = freeFlight_0(_S752.value, spread_1);
            if(_S744)
            {
                float3  _S754 = (&ray_4)->origin;
                float3  _S755 = (&ray_4)->unit_direction;
                float _S756 = (&hit_1)->distance;
                uint _S757 = _slang_select(_S749, 0U,b_4);
                uint _S758 = (&prev_0)->lobe;
                uint _S759 = _slang_select(_S749, 3U,_S758);
                float _S760 = (fcptTrackMedium((_S743), (_S754), (_S755), (_S756), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S757), (_S759), (_S749)));
                geometry_density_2 = _S760;
            }
            else
            {
                geometry_density_2 = _S753;
            }
            bool _S761 = !(geometry_density_2 < ((&hit_1)->distance));
            if(_S761)
            {
                _S711 = int(1);
                break;
            }
            if(_S744)
            {
                passes_0 = !replay_1;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                float3  _S762 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S763 = sel_1->glow + _S762;
                sel_1->glow = _S763;
            }
            else
            {
            }
            glowed_0 = _S712;
            uint b_6 = b_4 + 1U;
            float3  _S764 = (&ray_4)->origin + make_float3 (geometry_density_2) * (&ray_4)->unit_direction;
            (&ray_4)->origin = _S764;
            float3  _S765 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, geometry_density_2, true);
            float3  _S766 = weight_1;
            float3  _S767 = _slang_select(_S744, _S766,_S765);
            float3  throughput_4 = throughput_2 * _S767;
            uint _S768 = stream(_S740, b_6 + 320U);
            tracking_0 = _S768;
            weight_1 = throughput_3;
            float width_5 = width_2 + threshold_2 * geometry_density_2;
            float _S769 = threshold_2 + 3.14159274101257324f;
            bool _S770 = scatterSampled_0(replay_1, b_6, _S728, _S744);
            TreeSample _S771 = TreeSample_x24init_0(_S712, _S712, 0.0f, 0U);
            if(_S770)
            {
                float3  _S772 = (&ray_4)->origin;
                float3  _S773 = (&ray_4)->unit_direction;
                float3  _S774 = (&ray_4)->unit_direction;
                uint _S775 = stream(_S740, b_6 + 64U);
                float3  _S776 = extinction_in_0;
                float3  _S777 = extinction_in_0;
                uint2  _S778 = make_uint2 (_S743);
                float3  _S779 = (&ray_4)->unit_direction;
                uint _S780 = arrivalLobe_0(b_6, (&prev_0)->lobe);
                FKHit _S781 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S782 = _S781;
                ShadowContext _S783 = ShadowContext_x24init_0(_S776, _S777, _S778, _S779, b_6, _S780, false, geometry_density_2, width_5, false, _S712, &_S782, false, true);
                ShadowContext _S784 = _S783;
                TreeSample _S785 = sampleLightTree_0(_S772, _S773, _S774, 0.0f, true, _S775, &_S784);
                light_2 = _S785;
            }
            else
            {
                light_2 = _S771;
            }
            uint _S786 = (fcptMaxBounces());
            bool _S787 = b_6 < _S786;
            if(_S787)
            {
                turned_1 = (light_2.density) > 0.0f;
            }
            else
            {
                turned_1 = false;
            }
            float _S788 = _slang_select(turned_1, 0.07957746833562851f,0.0f);
            float3  _S789 = throughput_4 * light_2.radiance;
            float _S790 = powerHeuristic(light_2.density, _S788);
            float3  _S791 = _S789 * make_float3 (0.07957746833562851f * _S790);
            float3  _S792 = _slang_select(_S770, _S791,_S712);
            if(replay_1)
            {
                is_inside_5 = b_6 == _S728;
            }
            else
            {
                is_inside_5 = false;
            }
            if(is_inside_5)
            {
                bool _S793 = _S717 == 2U;
                if(_S793)
                {
                    float _S794 = rgb_to_greyscale(_S792);
                    passes_0 = _S794 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S795 = Shift_x24init_0(_S792, 1.0f);
                    _S711 = int(0);
                    ended_0 = _S795;
                    spread_1 = _S769;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                _S711 = int(0);
                ended_0 = _S713;
                spread_1 = _S769;
                geometry_density_2 = width_5;
                chain_throughput_0 = throughput_4;
                layer_0 = b_6;
                break;
            }
            bool _S796 = !replay_1;
            if(_S796)
            {
                Reservoir candidate_2 = _S742;
                uint _S797 = extractBits_0(_S742.path, 10U, 2U);
                bool _S798 = _S797 == 1U;
                if(_S798)
                {
                    float3  _S799 = safeDivide(_S792, _S712);
                    (&candidate_2)->radiance = _S799;
                }
                else
                {
                    uint _S800 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                    uint _S801 = insertBits_0(_S800, 2U, 10U, 2U);
                    (&candidate_2)->path = _S801;
                }
                Reservoir _S802 = withEnd(candidate_2, 0U, b_6, _S792);
                offer(sel_1, _S802, _S792 * make_float3 (scale_1) / make_float3 (density_2));
                float _S803 = survivalProbability(throughput_4, density_2);
                uint _S804 = stream(_S740, b_6 + 128U);
                Random _S805 = pcg(_S804);
                bool _S806 = _S803 < (_S805.value);
                if(_S806)
                {
                    viewed_0 = true;
                }
                else
                {
                    uint _S807 = (fcptMaxBounces());
                    viewed_0 = b_6 >= _S807;
                }
                if(viewed_0)
                {
                    _S711 = int(0);
                    ended_0 = _S713;
                    spread_1 = _S769;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                float _S808 = density_2 * _S803;
                density_2 = _S808;
            }
            else
            {
            }
            NEEVertex _S809 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_4)->origin, _S712, (&ray_4)->origin);
            nee_vertex_0 = _S809;
            uint _S810 = stream(_S740, b_6);
            float3  _S811 = isotropic_0(_S810);
            (&ray_4)->unit_direction = _S811;
            Vertex _S812 = scatteredVertex_0(false);
            prev_0 = _S812;
            float _S813 = (&prev_0)->pdf;
            FKRay _S814 = ray_4;
            FKHit _S815 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S816 = (fcptTraverseInstanceBVH((_S814), (true), (4.294967296e+09f), (false), (_S815), (false)));
            hit_1 = _S816;
            b_4 = b_6;
            throughput_2 = throughput_4;
            threshold_2 = _S769;
            width_2 = width_5;
            sky_pdf_0 = _S813;
        }
        if(_S711 != int(1))
        {
            width_2 = geometry_density_2;
            throughput_2 = chain_throughput_0;
            b_4 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S713;
        spread_1 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S817 = b_4 == 4294967295U;
    Reservoir _S818 = chain_0;
    NEEVertex _S819 = nee_vertex_0;
    Vertex _S820 = prev_0;
    FKHit _S821 = hit_1;
    uint _S822 = filling_2;
    float3  _S823 = scatter_in_0;
    float3  _S824 = extinction_in_0;
    float3  _S825 = weight_1;
    float3  _S826 = glowed_0;
    for(;;)
    {
        bool _S827 = (_S821.instance_index) == 4294967295U;
        if(_S827)
        {
            bool _S828 = !_S819.none;
            float _S829 = _slang_select(_S828, sky_pdf_0,0.0f);
            float _S830 = escapeWeight_0(_S829, (&ray_4)->unit_direction);
            float3  _S831 = environment_0((&ray_4)->unit_direction, b_4, _S820.lobe);
            float3  _S832 = throughput_2 * _S831;
            if(replay_1)
            {
                bool _S833 = b_4 == _S728;
                if(_S833)
                {
                    passes_0 = _S717 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S834 = Shift_x24init_0(_S832 * make_float3 (_S830) / make_float3 (r_3->jac), density_2 / r_3->jac);
                    ended_0 = _S834;
                    passes_0 = true;
                    break;
                }
                if(_S727)
                {
                    passes_0 = _S724;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_4 == _S715;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S820.rough;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S835 = Shift_x24init_0(_S832 * make_float3 (_S830), 1.0f);
                    ended_0 = _S835;
                    passes_0 = true;
                    break;
                }
                ended_0 = _S713;
                passes_0 = true;
                break;
            }
            Reservoir candidate_3 = _S818;
            uint _S836 = extractBits_0(_S818.path, 10U, 2U);
            bool _S837 = _S836 == 1U;
            if(_S837)
            {
                uint _S838 = extractBits_0(_S818.path, 5U, 5U);
                bool _S839 = _S838 == b_4;
                float _S840 = _slang_select(_S839, 1.0f,_S830);
                float3  _S841 = safeDivide(_S832 * make_float3 (_S840), _S712);
                (&candidate_3)->radiance = _S841;
            }
            else
            {
                if(_S820.rough)
                {
                    uint _S842 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                    uint _S843 = insertBits_0(_S842, 3U, 10U, 2U);
                    uint _S844 = insertBits_0(_S843, _S820.lobe, 15U, 2U);
                    uint _S845 = _slang_select(_S820.inside, 1U,0U);
                    uint _S846 = insertBits_0(_S844, _S845, 20U, 1U);
                    (&candidate_3)->path = _S846;
                    (&candidate_3)->jac = _S820.pdf;
                    (&candidate_3)->dir = (&ray_4)->unit_direction;
                }
                else
                {
                }
            }
            float3  _S847 = _S832 * make_float3 (_S830);
            Reservoir _S848 = withEnd(candidate_3, 3U, b_4, _S847);
            offer(sel_1, _S848, _S847 * make_float3 (scale_1) / make_float3 (density_2));
            ended_0 = _S713;
            passes_0 = true;
            break;
        }
        float3  _S849 = (&ray_4)->origin + make_float3 (_S821.distance) * (&ray_4)->unit_direction;
        (&ray_4)->origin = _S849;
        bool _S850 = _S822 != 4294967295U;
        if(_S850)
        {
            bool _S851 = !replay_1;
            if(_S851)
            {
                float3  _S852 = throughput_2 * _S826 / make_float3 (density_2);
                float3  _S853 = sel_1->glow + _S852;
                sel_1->glow = _S853;
            }
            else
            {
            }
            float3  _S854 = throughput_2 * _S825;
            throughput_2 = _S854;
        }
        else
        {
            float3  _S855 = flightWeight_0(_S823, _S824, (_S823.x + _S823.y + _S823.z) / 3.0f, _S821.distance, false);
            float3  _S856 = throughput_2 * _S855;
            throughput_2 = _S856;
        }
        float _S857 = width_2 + spread_1 * _S821.distance;
        ended_0 = _S713;
        width_2 = _S857;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    uint _S858 = b_4 + 1U;
    b_4 = _S858;
    layer_0 = 0U;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S712;
    float3  reconnection_0 = _S712;
    viewed_0 = _S817;
    for(;;)
    {
        bool _S859 = ((&hit_1)->is_point_light) == 1U;
        FKMedium _S860 = Medium_x24init_0(_S712, _S712);
        BSDFMaterial _S861 = Material_x24init_0(_S712, _S712, 0.0f, 0.0f, 0.0f, 0.0f, _S712, throughput_3, 1.0f, _S712, _S712, 0.5f, 0.0f, 0.0f, _S712);
        FKMedium _S862 = _S860;
        FKSurface _S863 = Surface_x24init_0(_S712, _S712, 0.0f, &_S861, false, 0U, 1.0f, false, &_S862, 4294967295U, _S712);
        bool _S864 = !_S859;
        bool scatter_2;
        bool is_inside_6;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S864)
        {
            uint _S865 = stream(_S740, b_4);
            uint _S866 = arrivalLobe_0(b_4, (&prev_0)->lobe);
            FKSurface _S867 = (fcptSurfaceAtPath((hit_1), ((&ray_4)->origin), (_S865), (width_2), (layer_0), (b_4), (_S866), ((&ray_4)->unit_direction)));
            bool _S868 = !passes_0;
            FKSurface _S869 = _S867;
            FKSurface _S870 = emitting_0(&_S869, _S868);
            uint _S871 = stream(_S740, b_4 + 256U);
            Random _S872 = pcg(_S871);
            FKSurface _S873 = _S870;
            FKSurface _S874 = uncovered_0(&_S873, _S872.value);
            float _S875 = facingSign(_S874.material.transmission, _S874.geometry_n, (&ray_4)->unit_direction);
            bool _S876 = _S875 < 0.0f;
            bool _S877 = (_S874.material.transmission) > 0.0f;
            if(_S877)
            {
                bool _S878 = arrivesBehind_0((&ray_4)->unit_direction, _S874.geometry_n);
                scatter_2 = _S878;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S879 = _S874;
            FKSurface _S880 = facingRay_0(&_S879, (&ray_4)->unit_direction);
            if(passes_0)
            {
                bool _S881 = arrivesBehind_0((&ray_4)->unit_direction, _S880.geometry_n);
                is_inside_6 = _S881;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S882 = beerLambert((&hit_1)->distance, _S880.material.absorption);
                float3  _S883 = throughput_2 * _S882;
                throughput_5 = _S883;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S884 = !_S880.skip;
            float geometry_density_3 = geometryDensity(_S880.geometry_n, (&ray_4)->unit_direction, (&hit_1)->distance);
            bool _S885 = b_4 == _S858;
            if(_S885)
            {
                float _S886 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S886;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S887 = geometry_density_2;
            scatter_2 = _S884;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S887;
            surface_12 = _S880;
            turned_1 = _S876;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_12 = _S863;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S888 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S889 = surface_12;
        FKSurface _S890 = surface_12;
        float _S891 = dot_0(surface_12.smooth_n, - (&ray_4)->unit_direction);
        BSDFMaterial _S892 = _S889.material;
        float2  _S893 = vertexEta_0(&_S892, _S891);
        bool _S894;
        if(scatter_2)
        {
            bool _S895 = samplesLights(_S889.material);
            _S894 = _S895;
        }
        else
        {
            _S894 = false;
        }
        bool _S896;
        if(passes_0)
        {
            _S896 = true;
        }
        else
        {
            _S896 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S896)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S894;
        }
        float3  _S897 = sideNormal(surface_12, (&ray_4)->unit_direction);
        FKSurface _S898 = surface_12;
        float3  _S899 = surface_12.hair;
        bool _S900 = (dot_0(_S899, _S899)) > 0.0f;
        bool _S901 = !_S900;
        bool _S902;
        if(_S901)
        {
            _S902 = !((_S889.material.transmission) > 0.0f);
        }
        else
        {
            _S902 = false;
        }
        FKSurface _S903 = surface_12;
        float3  _S904 = surface_12.geometry_n * make_float3 (dot_0(surface_12.geometry_n, _S890.smooth_n));
        float3  emission_0;
        if(_S859)
        {
            float3  _S905 = (fcptCalculatePointLightContrib(((&hit_1)->instance_index)));
            emission_0 = _S905;
        }
        else
        {
            emission_0 = _S889.material.emissive;
        }
        float _S906 = rgb_to_greyscale(emission_0);
        bool _S907 = _S906 > 0.0f;
        float3  emission_1;
        if(_S907)
        {
            NEEVertex _S908 = nee_vertex_0;
            FKHit _S909 = hit_1;
            float _S910 = emissionWeight_0(&_S908, &_S909, (&ray_4)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S910);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S911;
        if(replay_1)
        {
            _S911 = _S717 == 1U;
        }
        else
        {
            _S911 = false;
        }
        bool _S912;
        if(_S911)
        {
            _S912 = b_4 > _S716;
        }
        else
        {
            _S912 = false;
        }
        bool _S913;
        if(_S912)
        {
            _S913 = b_4 == _S715;
        }
        else
        {
            _S913 = false;
        }
        bool _S914;
        if(_S913)
        {
            bool _S915 = _S718 == 1U;
            if(_S915)
            {
                _S914 = true;
            }
            else
            {
                _S914 = _S718 == 2U;
            }
        }
        else
        {
            _S914 = false;
        }
        if(_S914)
        {
            bool _S916 = _S859 != (_S718 == 2U);
            if(_S916)
            {
                return _S713;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_3->jac), density_2 / r_3->jac);
        }
        uint _S917 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S918 = _S917 == 1U;
        Reservoir here_0 = chain_0;
        uint _S919 = insertBits_0(0U, b_4, 5U, 5U);
        uint _S920 = insertBits_0(_S919, 1U, 10U, 2U);
        uint _S921 = insertBits_0(_S920, (&prev_0)->lobe, 15U, 2U);
        bool _S922 = (&prev_0)->inside;
        uint _S923 = _slang_select(_S922, 1U,0U);
        uint _S924 = insertBits_0(_S921, _S923, 20U, 1U);
        (&here_0)->path = _S924;
        float _S925 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S925;
        fcptWithReservoirHit((&here_0), (&hit_1));
        bool _S926;
        if(replay_1)
        {
            _S926 = _S717 == 1U;
        }
        else
        {
            _S926 = false;
        }
        bool _S927;
        if(_S926)
        {
            _S927 = b_4 == _S716;
        }
        else
        {
            _S927 = false;
        }
        bool _S928 = b_4 == _S728;
        bool _S929;
        if(_S928)
        {
            bool _S930 = !scatter_2;
            if(_S930)
            {
                _S929 = true;
            }
            else
            {
                bool _S931 = _S717 != 1U;
                if(_S931)
                {
                    _S929 = _S717 != 3U;
                }
                else
                {
                    _S929 = false;
                }
            }
        }
        else
        {
            _S929 = false;
        }
        bool _S932;
        if(_S929)
        {
            _S932 = _S717 == 2U;
        }
        else
        {
            _S932 = false;
        }
        bool _S933;
        if(_S932)
        {
            _S933 = !_S888;
        }
        else
        {
            _S933 = false;
        }
        bool _S934;
        if(_S933)
        {
            _S934 = _S718 != 4U;
        }
        else
        {
            _S934 = false;
        }
        bool _S935 = _S716 == _S715;
        bool _S936;
        if(_S935)
        {
            _S936 = _S718 == 0U;
        }
        else
        {
            _S936 = false;
        }
        bool _S937 = _slang_select(_S927, _S936,_S934);
        bool _S938;
        if(nee_0)
        {
            _S938 = _slang_select(replay_1, _S937,scatter_2);
        }
        else
        {
            _S938 = false;
        }
        TreeSample _S939 = TreeSample_x24init_0(_S712, _S712, 0.0f, 0U);
        bool viewed_1;
        float3  throughput_6;
        float3  lit_0;
        if(_S938)
        {
            float3  _S940 = (&ray_4)->origin;
            if(_S900)
            {
                throughput_6 = _S712;
            }
            else
            {
                throughput_6 = _S890.smooth_n;
            }
            FKSurface _S941 = surface_12;
            if(_S900)
            {
                viewed_1 = true;
            }
            else
            {
                BSDFMaterial _S942 = _S889.material;
                bool _S943 = isTranslucent_0(&_S942);
                viewed_1 = _S943;
            }
            uint _S944 = stream(_S740, b_4 + 64U);
            uint _S945 = arrivalLobe_0(b_4, (&prev_0)->lobe);
            FKSurface _S946 = surface_12;
            FKHit _S947 = hit_1;
            ShadowContext _S948 = shadowContext_0(&_S946, turned_1, _S897, extinction_in_0, filling_2, (&ray_4)->unit_direction, b_4, _S945, (&hit_1)->distance, width_2, _S902, _S904, &_S947, _S900);
            ShadowContext _S949 = _S948;
            TreeSample _S950 = sampleLightTree_0(_S940, throughput_6, _S903.geometry_n, _S941.geometry_offset, viewed_1, _S944, &_S949);
            bool _S951 = any_0((_S950.radiance) != _S712);
            if(_S951)
            {
                if(_S900)
                {
                    uint _S952 = (fcptMaxBounces());
                    bool _S953 = b_4 < _S952;
                    FKSurface _S954 = surface_12;
                    TreeSample _S955 = _S950;
                    float3  _S956 = hairLight_0(&_S954, (&ray_4)->unit_direction, &_S955, _S953);
                    lit_0 = _S956;
                }
                else
                {
                    float _S957 = _S893.x;
                    float _S958 = _S893.y;
                    uint _S959 = (fcptMaxBounces());
                    bool _S960 = b_4 < _S959;
                    TreeSample _S961 = _S950;
                    BSDFMaterial _S962 = _S889.material;
                    float3  _S963 = lightBSDF_0((&ray_4)->unit_direction, &_S961, _S890.smooth_n, _S897, &_S962, _S957, _S958, _S960, surface_12.random_state);
                    lit_0 = _S963;
                }
            }
            else
            {
                lit_0 = _S712;
            }
            light_2 = _S950;
        }
        else
        {
            light_2 = _S939;
            lit_0 = _S712;
        }
        bool refracted_4;
        bool wrong_side_0;
        bool _S964;
        bool _S965;
        float density_4;
        if(_S927)
        {
            bool _S966 = ((&hit_1)->instance_index) != (_S729.instance_index);
            if(_S966)
            {
                viewed_1 = true;
            }
            else
            {
                viewed_1 = ((&hit_1)->triangle_index) != (_S729.triangle_index);
            }
            if(viewed_1)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = !_S888;
            }
            if(refracted_4)
            {
                return _S713;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S935)
            {
                wrong_side_0 = _S718 == 1U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            if(_S935)
            {
                _S964 = _S718 == 0U;
            }
            else
            {
                _S964 = false;
            }
            if(_S964)
            {
                bool _S967 = !nee_0;
                if(_S967)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S968 = rgb_to_greyscale(light_2.radiance);
                    passes_0 = !(_S968 > 0.0f);
                }
                if(passes_0)
                {
                    return _S713;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            if(_S935)
            {
                _S965 = _S718 == 4U;
            }
            else
            {
                _S965 = false;
            }
            if(_S965)
            {
                bool _S969 = !nee_0;
                if(_S969)
                {
                    return _S713;
                }
                float _S970 = environmentPdf_0(r_3->dir);
                float3  _S971 = skyBSDF((&ray_4)->unit_direction, r_3->dir, surface_12, _S897, _S893, is_inside_6, _S970, surface_12.random_state);
                return Shift_x24init_0(throughput_7 * _S971 * r_3->radiance / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            uint _S972 = extractBits_0(_S714, 19U, 1U);
            bool _S973 = nee_0 != (_S972 == 1U);
            if(_S973)
            {
                return _S713;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S928;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S974 = !scatter_2;
                if(_S974)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S975 = _S717 != 1U;
                    if(_S975)
                    {
                        refracted_4 = _S717 != 3U;
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
                bool _S976 = _S717 == 2U;
                if(_S976)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S888;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S718 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    uint _S977 = stream(_S740, b_4 + 448U);
                    FKRay _S978 = ray_4;
                    FKSurface _S979 = surface_12;
                    SkySample _S980 = sampleSky_0(&_S978, &_S979, _S897, _S893, is_inside_6, _S977, surface_12.random_state);
                    return Shift_x24init_0(throughput_5 * _S980.color, 1.0f);
                }
                if(_S976)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S888;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S981 = rgb_to_greyscale(light_2.radiance);
                    bool _S982 = !(_S981 > 0.0f);
                    if(_S982)
                    {
                        return _S713;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S727)
                {
                    passes_0 = _S718 == 2U;
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
                if(_S727)
                {
                    passes_0 = _S718 == 1U;
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
                    passes_0 = !_S888;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S713;
            }
            else
            {
                bool _S983 = !replay_1;
                if(_S983)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S984 = b_4 > 0U;
                    if(_S984)
                    {
                        Reservoir candidate_4 = chain_0;
                        if(_S918)
                        {
                            float3  _S985 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_4)->radiance = _S985;
                        }
                        else
                        {
                            if(_S888)
                            {
                                candidate_4 = here_0;
                            }
                        }
                        float3  _S986 = throughput_5 * emission_1;
                        Reservoir _S987 = withEnd(candidate_4, 1U, b_4, _S986);
                        offer(sel_1, _S987, _S986 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S988 = throughput_5 * emission_1;
                        float3  _S989 = sel_1->glow + _S988;
                        sel_1->glow = _S989;
                    }
                    if(nee_0)
                    {
                        float3  _S990 = throughput_5 * lit_0;
                        Reservoir candidate_5 = chain_0;
                        if(_S918)
                        {
                            float3  _S991 = safeDivide(_S990, chain_throughput_0);
                            (&candidate_5)->radiance = _S991;
                        }
                        else
                        {
                            if(_S888)
                            {
                                candidate_5 = here_0;
                                uint _S992 = insertBits_0((&candidate_5)->path, 1U, 19U, 1U);
                                (&candidate_5)->path = _S992;
                                (&candidate_5)->dir = light_2.dir;
                                (&candidate_5)->radiance = light_2.radiance;
                            }
                            else
                            {
                                uint _S993 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S994 = insertBits_0(_S993, 2U, 10U, 2U);
                                (&candidate_5)->path = _S994;
                            }
                        }
                        Reservoir _S995 = withEnd(candidate_5, 0U, b_4, _S990);
                        offer(sel_1, _S995, _S990 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S900)
                        {
                            _S964 = false;
                        }
                        else
                        {
                            bool _S996 = environmentMapped_0();
                            _S964 = _S996;
                        }
                    }
                    else
                    {
                        _S964 = false;
                    }
                    if(_S964)
                    {
                        uint _S997 = (fcptMaxBounces());
                        _S965 = b_4 < _S997;
                    }
                    else
                    {
                        _S965 = false;
                    }
                    if(_S965)
                    {
                        uint _S998 = stream(_S740, b_4 + 448U);
                        FKRay _S999 = ray_4;
                        FKSurface _S1000 = surface_12;
                        SkySample _S1001 = sampleSky_0(&_S999, &_S1000, _S897, _S893, is_inside_6, _S998, surface_12.random_state);
                        float3  _S1002 = throughput_5 * _S1001.color;
                        Reservoir candidate_6 = chain_0;
                        if(_S918)
                        {
                            float3  _S1003 = safeDivide(_S1002, chain_throughput_0);
                            (&candidate_6)->radiance = _S1003;
                        }
                        else
                        {
                            if(_S888)
                            {
                                candidate_6 = here_0;
                                uint _S1004 = insertBits_0((&candidate_6)->path, 1U, 19U, 1U);
                                (&candidate_6)->path = _S1004;
                                (&candidate_6)->dir = _S1001.dir;
                                (&candidate_6)->radiance = _S1001.radiance;
                            }
                            else
                            {
                                uint _S1005 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S1006 = insertBits_0(_S1005, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1006;
                            }
                        }
                        Reservoir _S1007 = withEnd(candidate_6, 4U, b_4, _S1002);
                        offer(sel_1, _S1007, _S1002 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1008;
        bool straight_0;
        bool _S1009;
        bool _S1010;
        bool _S1011;
        bool _S1012;
        bool _S1013;
        bool _S1014;
        bool _S1015;
        bool _S1016;
        bool _S1017;
        bool _S1018;
        bool _S1019;
        bool _S1020;
        bool _S1021;
        bool _S1022;
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
                viewed_1 = _S928;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1023 = extractBits_0(_S714, 15U, 2U);
            uint _S1024 = extractBits_0(_S714, 17U, 2U);
            uint _S1025 = _slang_select(_S927, _S1024,_S1023);
            float3  _S1026 = r_3->dir;
            bool refracted_5 = _S1025 == 1U;
            SampleBSDF _S1027 = SampleBSDF_x24init_0(_S712, _S712, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_10 = _S1027;
            float3  reconnection_1;
            SampleBSDF _S1028;
            if(viewed_1)
            {
                uint _S1029 = extractBits_0(_S714, 20U, 1U);
                bool _S1030 = is_inside_6 != (_S1029 == 1U);
                if(_S1030)
                {
                    return _S713;
                }
                bool _S1031 = _S717 == 1U;
                if(_S1031)
                {
                    float3  _S1032 = (fcptHitPosition((_S729)));
                    throughput_8 = _S1032;
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
                    BSDFMaterial _S1033 = _S889.material;
                    bool _S1034 = isTranslucent_0(&_S1033);
                    if(_S1034)
                    {
                        refracted_4 = _S1025 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1035 = throughput_8 - (&ray_4)->origin;
                        float3  _S1036 = _slang_select(_S1031, _S1035,_S1026);
                        wrong_side_0 = (dot_0(_S890.smooth_n, _S1036) * _S891) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1031)
                {
                    float3  _S1037 = (&ray_4)->origin;
                    FKSurface _S1038 = surface_12;
                    float3  _S1039 = - _S890.smooth_n;
                    bool _S1040 = is_inside_6 != refracted_4;
                    float3  _S1041 = _slang_select(_S1040, _S1039,_S890.smooth_n);
                    float3  _S1042 = make_float3 (_S1038.geometry_offset) * _S1041;
                    bool _S1043 = (dot_0(throughput_8 - (&ray_4)->origin, _S897)) > 0.0f;
                    float _S1044 = _slang_select(_S1043, _S1038.geometry_offset,0.0f);
                    float3  _S1045 = _S904 * make_float3 (_S1044);
                    float3  _S1046 = _slang_select(_S902, _S1045,_S1042);
                    float3  _S1047 = throughput_8 - (_S1037 + _S1046);
                    float3  _S1048 = ((((_S1047)) * make_float3(rnorm3df(((_S1047)).x, ((_S1047)).y, ((_S1047)).z))));
                    reconnection_1 = _S1048;
                }
                else
                {
                    reconnection_1 = _S1026;
                }
                if(_S900)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1049 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, _S897);
                    wrong_side_0 = _S1049;
                }
                if(wrong_side_0)
                {
                    return _S713;
                }
                float3  _S1050 = throughput_8;
                throughput_8 = reconnection_1;
                b_7 = _S1025;
                wrong_side_0 = false;
                reconnection_1 = _S1050;
            }
            else
            {
                bool _S1051 = !_S927;
                if(_S1051)
                {
                    SampleBSDF bsdf_sampled_0;
                    if(_S900)
                    {
                        SampleBSDF _S1052 = (fcptSampleHair((_S898.hair), (_S889.material.albedo), (_S889.material.specular_tint), ((&ray_4)->unit_direction), (surface_12.random_state)));
                        _S1028 = _S1052;
                    }
                    else
                    {
                        SampleBSDF _S1053 = sampleBSDF((&ray_4)->unit_direction, _S890.smooth_n, _S889.material, _S893.x, _S893.y, surface_12.random_state, make_float2 (0.0f));
                        _S1028 = _S1053;
                    }
                    bsdf_sampled_0 = _S1028;
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
                            return _S713;
                        }
                        break;
                    }
                    if(_S900)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1054 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, _S897);
                        wrong_side_0 = _S1054;
                    }
                    if(wrong_side_0)
                    {
                        _S964 = (_S889.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S964 = false;
                    }
                    if(_S964)
                    {
                        SampleBSDF _S1055 = sampleBSDF((&bsdf_sampled_0)->unit_direction, _S903.geometry_n, _S889.material, _S893.x, _S893.y, (&bsdf_sampled_0)->random_state, make_float2 (0.0f));
                        (&bsdf_sampled_0)->unit_direction = _S1055.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1055.refracted;
                        (&bsdf_sampled_0)->throughput = _S1055.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1056 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, _S903.geometry_n)) * _S903.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1056;
                        }
                    }
                    uint _S1057 = (&bsdf_sampled_0)->lobe;
                    float3  _S1058 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1059 = (&bsdf_sampled_0)->refracted;
                    lobe_10 = bsdf_sampled_0;
                    float _S1060 = (&bsdf_sampled_0)->pdf;
                    float _S1061 = _slang_select(wrong_side_0, 0.0f,_S1060);
                    (&lobe_10)->pdf = _S1061;
                    throughput_8 = _S1058;
                    b_7 = _S1057;
                    refracted_4 = _S1059;
                }
                else
                {
                    throughput_8 = _S1026;
                    b_7 = _S1025;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S964 = true;
            }
            else
            {
                _S964 = _S927;
            }
            if(_S964)
            {
                if(_S900)
                {
                    SampleBSDF _S1062 = (fcptConnectHair((_S898.hair), (_S889.material.albedo), (_S889.material.specular_tint), ((&ray_4)->unit_direction), (throughput_8)));
                    _S1028 = _S1062;
                }
                else
                {
                    SampleBSDF _S1063 = connectBSDF((&ray_4)->unit_direction, throughput_8, _S890.smooth_n, _S889.material, _S893.x, _S893.y, b_7, surface_12.random_state);
                    _S1028 = _S1063;
                }
                lobe_10 = _S1028;
            }
            if(_S900)
            {
                _S965 = false;
            }
            else
            {
                bool _S1064 = b_7 != 0U;
                if(_S1064)
                {
                    bool _S1065 = (_S889.material.roughness) == 0.0f;
                    if(_S1065)
                    {
                        _S965 = true;
                    }
                    else
                    {
                        bool _S1066 = b_7 == 1U;
                        if(_S1066)
                        {
                            _S965 = (_S893.x) == (_S893.y);
                        }
                        else
                        {
                            _S965 = false;
                        }
                    }
                }
                else
                {
                    _S965 = false;
                }
            }
            if(_S901)
            {
                _S1008 = b_7 == 1U;
            }
            else
            {
                _S1008 = false;
            }
            if(_S1008)
            {
                straight_0 = (_S889.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1009 = _S901;
            }
            else
            {
                _S1009 = false;
            }
            if(_S1009)
            {
                _S1010 = b_7 == 1U;
            }
            else
            {
                _S1010 = false;
            }
            if(_S1010)
            {
                _S1011 = (_S893.x) == (_S893.y);
            }
            else
            {
                _S1011 = false;
            }
            BSDFMaterial _S1067 = _S889.material;
            bool _S1068 = isTranslucent_0(&_S1067);
            if(_S1068)
            {
                _S1012 = b_7 == 0U;
            }
            else
            {
                _S1012 = false;
            }
            if(_S1012)
            {
                _S1013 = (dot_0(throughput_8, _S903.geometry_n)) < 0.0f;
            }
            else
            {
                _S1013 = false;
            }
            if(nee_0)
            {
                _S1014 = !_S965;
            }
            else
            {
                _S1014 = false;
            }
            if(_S1014)
            {
                _S1015 = !wrong_side_0;
            }
            else
            {
                _S1015 = false;
            }
            if(_S1015)
            {
                float _S1069 = (&lobe_10)->pdf;
                float3  _S1070 = (&ray_4)->origin;
                BSDFMaterial _S1071 = _S889.material;
                bool _S1072 = isTranslucent_0(&_S1071);
                if(_S1072)
                {
                    _S1016 = true;
                }
                else
                {
                    _S1016 = _S900;
                }
                float3  _S1073 = _slang_select(_S1016, _S712,_S890.smooth_n);
                float3  _S1074 = (&ray_4)->origin;
                FKSurface _S1075 = surface_12;
                float3  _S1076 = - _S890.smooth_n;
                float3  _S1077 = _slang_select(_S1013, _S1076,_S890.smooth_n);
                float3  _S1078 = make_float3 (_S1075.geometry_offset) * _S1077;
                bool _S1079 = (dot_0(throughput_8, _S897)) > 0.0f;
                float _S1080 = _slang_select(_S1079, _S1075.geometry_offset,0.0f);
                float3  _S1081 = _S904 * make_float3 (_S1080);
                float3  _S1082 = _slang_select(_S902, _S1081,_S1078);
                NEEVertex _S1083 = NEEVertex_x24init_0(false, _S1069, _S1070, _S1073, _S1074 + _S1082);
                nee_vertex_0 = _S1083;
            }
            else
            {
                if(_S900)
                {
                    _S1016 = true;
                }
                else
                {
                    bool _S1084 = b_7 != 1U;
                    if(_S1084)
                    {
                        _S1016 = true;
                    }
                    else
                    {
                        _S1016 = (_S893.x) != (_S893.y);
                    }
                }
                if(_S1016)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1085 = b_7 == 0U;
            bool _S1086 = withinInverseFootprint((&lobe_10)->pdf, _S1085, (&prev_0)->cos, (&hit_1)->distance, threshold_2);
            float _S1087 = dot_0(throughput_8, _S903.geometry_n);
            bool _S1088 = (dot_0(throughput_8, _S890.smooth_n) * _S1087) < 0.0f;
            bool _S1089 = !_S1088;
            if(_S1089)
            {
                bool _S1090 = roughLobe((&lobe_10)->pdf, _S1085, _S889.material.roughness);
                _S1016 = _S1090;
            }
            else
            {
                _S1016 = false;
            }
            if(_S927)
            {
                bool _S1091 = !_S1086;
                if(_S1091)
                {
                    return _S713;
                }
                bool _S1092 = _S718 != 1U;
                if(_S1092)
                {
                    _S1017 = _S718 != 2U;
                }
                else
                {
                    _S1017 = false;
                }
                if(_S1017)
                {
                    float _S1093 = (&lobe_10)->pdf;
                    float _S1094 = _slang_select(nee_0, _S1093,0.0f);
                    float _S1095 = escapeWeight_0(_S1094, _S1026);
                    if(_S935)
                    {
                        passes_0 = _S724;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1096 = _slang_select(passes_0, _S1095,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_10)->throughput * make_float3 ((&lobe_10)->pdf)) * r_3->radiance * make_float3 (_S1096) / make_float3 (r_3->jac), density_4 * (&lobe_10)->pdf / r_3->jac);
                }
                float3  _S1097 = throughput_6 * make_float3 ((&lobe_10)->pdf);
                float _S1098 = density_4 * (&lobe_10)->pdf;
                throughput_9 = _S1097;
                density_6 = _S1098;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1099 = (fcptLayers((hit_1)));
            bool _S1100 = b_7 == 1U;
            bool _S1101 = passesLayer_0(_S1099, _S1100, passes_0);
            if(viewed_1)
            {
                _S1017 = _S1101;
            }
            else
            {
                _S1017 = false;
            }
            if(_S1017)
            {
                return _S713;
            }
            if(replay_1)
            {
                _S1018 = b_4 <= _S728;
            }
            else
            {
                _S1018 = false;
            }
            if(_S1018)
            {
                _S1019 = _S888;
            }
            else
            {
                _S1019 = false;
            }
            if(_S1019)
            {
                _S1020 = _S1086;
            }
            else
            {
                _S1020 = false;
            }
            if(_S1020)
            {
                _S1021 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1021 = !_S1016;
                }
                else
                {
                    _S1021 = false;
                }
            }
            if(_S1021)
            {
                return _S713;
            }
            if(viewed_1)
            {
                float3  _S1102 = throughput_9 * ((&lobe_10)->throughput * make_float3 ((&lobe_10)->pdf));
                float _S1103 = (&lobe_10)->pdf;
                throughput_10 = _S1102;
                sky_pdf_2 = _S1103;
            }
            else
            {
                float3  _S1104 = throughput_9 * max_0((&lobe_10)->throughput, _S712);
                throughput_10 = _S1104;
                sky_pdf_2 = density_6;
            }
            bool _S1105 = !replay_1;
            if(_S1105)
            {
                _S1022 = !_S918;
            }
            else
            {
                _S1022 = false;
            }
            bool _S1106;
            if(_S1022)
            {
                _S1106 = _S888;
            }
            else
            {
                _S1106 = false;
            }
            bool _S1107;
            if(_S1106)
            {
                _S1107 = _S1086;
            }
            else
            {
                _S1107 = false;
            }
            float3  chain_throughput_1;
            if(_S1107)
            {
                chain_0 = here_0;
                uint _S1108 = insertBits_0((&chain_0)->path, b_7, 17U, 2U);
                uint _S1109 = _slang_select(nee_0, 1U,0U);
                uint _S1110 = insertBits_0(_S1108, _S1109, 19U, 1U);
                (&chain_0)->path = _S1110;
                float _S1111 = (&chain_0)->jac * (&lobe_10)->pdf;
                (&chain_0)->jac = _S1111;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            Vertex _S1112 = Vertex_x24init_0(_S1016, b_7, (&lobe_10)->pdf, (F32_abs((dot_0(_S903.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1112;
            float _S1113 = (&lobe_10)->pdf;
            bool _S1114;
            if(_S1100)
            {
                _S1114 = (_S893.x) == (_S893.y);
            }
            else
            {
                _S1114 = false;
            }
            float sky_pdf_3 = _slang_select(_S1114, sky_pdf_0,_S1113);
            float _S1115 = _slang_select(_S900, 0.0f,sky_pdf_3);
            float _S1116 = widened_0(spread_1, (&lobe_10)->pdf, _S965);
            bool _S1117;
            if(refracted_4)
            {
                _S1117 = !_S1013;
            }
            else
            {
                _S1117 = false;
            }
            bool is_inside_7;
            if(_S1117)
            {
                bool _S1118 = !is_inside_6;
                is_inside_7 = _S1118;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            bool _S1119 = !_S1101;
            if(_S1119)
            {
                FKSurface faced_3 = surface_12;
                float3  _S1120 = - _S903.geometry_n;
                float3  _S1121 = _slang_select(turned_1, _S1120,_S903.geometry_n);
                (&faced_3)->geometry_n = _S1121;
                FKMedium _S1122 = Medium_x24init_0(scatter_in_0, extinction_in_0);
                FKSurface _S1123 = faced_3;
                FKMedium _S1124 = _S1122;
                MediumSides _S1125 = mediumSides_0(&_S1123, &_S1124, filling_2, (&ray_4)->unit_direction);
                bool _S1126 = leavesInFront_0((&faced_3)->geometry_n, throughput_8, _S897, _S903.geometry_n);
                float3  _S1127 = _slang_select(_S1126, _S1125.front.scatter,_S1125.behind.scatter);
                scatter_in_0 = _S1127;
                float3  _S1128 = _slang_select(_S1126, _S1125.front.extinction,_S1125.behind.extinction);
                extinction_in_0 = _S1128;
                uint _S1129 = _S1125.fillings.x;
                uint _S1130 = _S1125.fillings.y;
                uint _S1131 = _slang_select(_S1126, _S1130,_S1129);
                filling_2 = _S1131;
            }
            (&ray_4)->unit_direction = throughput_8;
            if(_S1119)
            {
                if(_S902)
                {
                    bool _S1132 = (dot_0(throughput_8, _S897)) > 0.0f;
                    if(_S1132)
                    {
                        again_0 = (surface_12.geometry_offset) > 0.0f;
                    }
                    else
                    {
                        again_0 = false;
                    }
                    FKSurface _S1133 = surface_12;
                    float _S1134 = _slang_select(again_0, _S1133.geometry_offset,0.0f);
                    float3  _S1135 = (&ray_4)->origin + _S904 * make_float3 (_S1134);
                    (&ray_4)->origin = _S1135;
                    bool _S1136 = !again_0;
                    BSDFMaterial _S1137 = _S889.material;
                    bool _S1138 = isTranslucent_0(&_S1137);
                    bool _S1139 = !_S1138;
                    if(_S1139)
                    {
                        opaque_start_0 = !((_S1133.geometry_offset) > 0.0f);
                    }
                    else
                    {
                        opaque_start_0 = false;
                    }
                    if(opaque_start_0)
                    {
                        on_face_0 = _S1087 < 0.0f;
                    }
                    else
                    {
                        on_face_0 = false;
                    }
                    again_0 = on_face_0;
                    opaque_start_0 = true;
                    on_face_0 = _S1136;
                }
                else
                {
                    if(_S900)
                    {
                    }
                    else
                    {
                        FKSurface _S1140 = surface_12;
                        float _S1141 = _slang_select(straight_0, 0.0f,_S1140.geometry_offset);
                        float3  _S1142 = - _S890.smooth_n;
                        bool _S1143 = is_inside_7 != _S1013;
                        float3  _S1144 = _slang_select(_S1143, _S1142,_S890.smooth_n);
                        float3  _S1145 = (&ray_4)->origin + make_float3 (_S1141) * _S1144;
                        (&ray_4)->origin = _S1145;
                    }
                    again_0 = false;
                    opaque_start_0 = _S900;
                    on_face_0 = _S900;
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
            passes_0 = _S1101;
            viewed_1 = _S1011;
            sky_pdf_2 = _S1115;
            spread_4 = _S1116;
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
        bool _S1146 = !replay_1;
        float density_7;
        if(_S1146)
        {
            if(_S859)
            {
                float3  _S1147 = throughput_9 * emission_1;
                Reservoir candidate_7 = chain_0;
                uint _S1148 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1149 = _S1148 == 1U;
                if(_S1149)
                {
                    float3  _S1150 = safeDivide(_S1147, chain_throughput_0);
                    (&candidate_7)->radiance = _S1150;
                }
                Reservoir _S1151 = withEnd(candidate_7, 2U, b_4, _S1147);
                offer(sel_1, _S1151, _S1147 * make_float3 (scale_1) / make_float3 (density_6));
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
                float _S1152 = survivalProbability(throughput_9, density_6);
                density_7 = _S1152;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1153 = stream(_S740, b_4 + 128U);
            Random _S1154 = pcg(_S1153);
            bool _S1155 = density_7 < (_S1154.value);
            if(_S1155)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1156 = (fcptMaxBounces());
                wrong_side_0 = b_4 >= _S1156;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1157 = density_6 * density_7;
            density_7 = _S1157;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1158 = layer_0 ^ 1U;
        uint _S1159 = _slang_select(passes_0, _S1158,0U);
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
            uint _S1160 = b_7 + 1U;
            b_4 = _S1160;
            layer_0 = _S1159;
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
            uint _S1160 = b_7 + 1U;
            b_4 = _S1160;
            layer_0 = _S1159;
            continue;
        }
        FKRay _S1161 = ray_4;
        float _S1162 = distance_5(reconnection_0, (&ray_4)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S928;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S717 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1163 = _slang_select(wrong_side_0, _S1162,4.294967296e+09f);
        bool _S1164 = !opaque_start_0;
        if(straight_0)
        {
            _S964 = true;
        }
        else
        {
            _S964 = on_face_0;
        }
        FKHit _S1165;
        if(_S964)
        {
            _S1165 = hit_1;
        }
        else
        {
            _S1165 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
        }
        FKHit _S1166 = (fcptTraverseInstanceBVH((_S1161), (_S864), (_S1163), (_S1164), (_S1165), (viewed_1)));
        hit_1 = _S1166;
        if(replay_1)
        {
            _S965 = _S928;
        }
        else
        {
            _S965 = false;
        }
        if(_S965)
        {
            _S1008 = _S717 == 1U;
        }
        else
        {
            _S1008 = false;
        }
        if(_S1008)
        {
            _S1009 = ((&hit_1)->instance_index) == (_S729.instance_index);
        }
        else
        {
            _S1009 = false;
        }
        if(_S1009)
        {
            _S1010 = ((&hit_1)->triangle_index) == (_S729.triangle_index);
        }
        else
        {
            _S1010 = false;
        }
        if(_S1010)
        {
            (&hit_1)->uv = _S729.uv;
            float _S1167 = distance_5(reconnection_0, (&ray_4)->origin);
            (&hit_1)->distance = _S1167;
        }
        if(replay_1)
        {
            _S1011 = _S928;
        }
        else
        {
            _S1011 = false;
        }
        if(_S1011)
        {
            _S1012 = _S717 == 3U;
        }
        else
        {
            _S1012 = false;
        }
        if(_S1012)
        {
            _S1013 = ((&hit_1)->instance_index) != 4294967295U;
        }
        else
        {
            _S1013 = false;
        }
        if(_S1013)
        {
            return _S713;
        }
        Reservoir _S1168 = chain_0;
        uint _S1169 = filling_2;
        for(;;)
        {
            bool _S1170 = _S1169 != 4294967295U;
            float _S1171;
            if(_S1170)
            {
                float _S1172 = (fcptMajorant((_S1169)));
                _S1171 = _S1172;
            }
            else
            {
                _S1171 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1014 = _S928;
            }
            else
            {
                _S1014 = false;
            }
            if(_S1014)
            {
                _S1015 = _S717 == 1U;
            }
            else
            {
                _S1015 = false;
            }
            if(_S1015)
            {
                _S1016 = _S1171 > 0.0f;
            }
            else
            {
                _S1016 = false;
            }
            if(_S1016)
            {
                ended_0 = _S713;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_3 = width_2;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_7 = b_4;
                _S1017 = true;
                break;
            }
            bool _S1173 = (&prev_0)->rough;
            if(_S1173)
            {
                _S1017 = !(_S1171 > 0.0f);
            }
            else
            {
                _S1017 = false;
            }
            (&prev_0)->rough = _S1017;
            uint _S1174 = b_4 + 320U;
            bool _S1175 = b_4 == 4294967295U;
            uint _S1176 = _slang_select(_S1175, 384U,_S1174);
            uint _S1177 = stream(_S740, _S1176);
            uint tracking_1 = _S1177;
            weight_1 = throughput_3;
            glowed_0 = _S712;
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
                    _S711 = int(2);
                    break;
                }
                uint _S1178 = b_7 + 320U;
                bool _S1179 = b_7 == 4294967295U;
                uint _S1180 = _slang_select(_S1179, 384U,_S1178);
                uint _S1181 = stream(_S740, _S1180);
                Random _S1182 = pcg(_S1181);
                float _S1183 = freeFlight_0(_S1182.value, _S1171);
                if(_S1170)
                {
                    float3  _S1184 = (&ray_4)->origin;
                    float3  _S1185 = (&ray_4)->unit_direction;
                    float _S1186 = (&hit_1)->distance;
                    uint _S1187 = _slang_select(_S1179, 0U,b_7);
                    uint _S1188 = (&prev_0)->lobe;
                    uint _S1189 = _slang_select(_S1179, 3U,_S1188);
                    float _S1190 = (fcptTrackMedium((_S1169), (_S1184), (_S1185), (_S1186), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S1187), (_S1189), (_S1179)));
                    spread_3 = _S1190;
                }
                else
                {
                    spread_3 = _S1183;
                }
                bool _S1191 = !(spread_3 < ((&hit_1)->distance));
                if(_S1191)
                {
                    _S711 = int(2);
                    break;
                }
                if(_S1170)
                {
                    _S1018 = _S1146;
                }
                else
                {
                    _S1018 = false;
                }
                if(_S1018)
                {
                    float3  _S1192 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1193 = sel_1->glow + _S1192;
                    sel_1->glow = _S1193;
                }
                else
                {
                }
                glowed_0 = _S712;
                uint b_8 = b_7 + 1U;
                float3  _S1194 = (&ray_4)->origin + make_float3 (spread_3) * (&ray_4)->unit_direction;
                (&ray_4)->origin = _S1194;
                float3  _S1195 = flightWeight_0(scatter_in_0, extinction_in_0, _S1171, spread_3, true);
                float3  _S1196 = weight_1;
                float3  _S1197 = _slang_select(_S1170, _S1196,_S1195);
                float3  throughput_11 = throughput_10 * _S1197;
                uint _S1198 = stream(_S740, b_8 + 320U);
                tracking_1 = _S1198;
                weight_1 = throughput_3;
                float width_6 = width_3 + spread_2 * spread_3;
                float _S1199 = spread_2 + 3.14159274101257324f;
                bool _S1200 = scatterSampled_0(replay_1, b_8, _S728, _S1170);
                TreeSample light_3;
                if(_S1200)
                {
                    float3  _S1201 = (&ray_4)->origin;
                    float3  _S1202 = (&ray_4)->unit_direction;
                    float3  _S1203 = (&ray_4)->unit_direction;
                    uint _S1204 = stream(_S740, b_8 + 64U);
                    float3  _S1205 = extinction_in_0;
                    float3  _S1206 = extinction_in_0;
                    uint2  _S1207 = make_uint2 (_S1169);
                    float3  _S1208 = (&ray_4)->unit_direction;
                    uint _S1209 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                    FKHit _S1210 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                    FKHit _S1211 = _S1210;
                    ShadowContext _S1212 = ShadowContext_x24init_0(_S1205, _S1206, _S1207, _S1208, b_8, _S1209, false, spread_3, width_6, false, _S712, &_S1211, false, true);
                    ShadowContext _S1213 = _S1212;
                    TreeSample _S1214 = sampleLightTree_0(_S1201, _S1202, _S1203, 0.0f, true, _S1204, &_S1213);
                    light_3 = _S1214;
                }
                else
                {
                    light_3 = _S939;
                }
                uint _S1215 = (fcptMaxBounces());
                bool _S1216 = b_8 < _S1215;
                if(_S1216)
                {
                    _S1019 = (light_3.density) > 0.0f;
                }
                else
                {
                    _S1019 = false;
                }
                float _S1217 = _slang_select(_S1019, 0.07957746833562851f,0.0f);
                float3  _S1218 = throughput_11 * light_3.radiance;
                float _S1219 = powerHeuristic(light_3.density, _S1217);
                float3  _S1220 = _S1218 * make_float3 (0.07957746833562851f * _S1219);
                float3  _S1221 = _slang_select(_S1200, _S1220,_S712);
                if(replay_1)
                {
                    _S1020 = b_8 == _S728;
                }
                else
                {
                    _S1020 = false;
                }
                if(_S1020)
                {
                    bool _S1222 = _S717 == 2U;
                    if(_S1222)
                    {
                        float _S1223 = rgb_to_greyscale(_S1221);
                        _S1021 = _S1223 > 0.0f;
                    }
                    else
                    {
                        _S1021 = false;
                    }
                    if(_S1021)
                    {
                        Shift _S1224 = Shift_x24init_0(_S1221, 1.0f);
                        _S711 = int(1);
                        ended_0 = _S1224;
                        spread_3 = _S1199;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_5 = b_8;
                        break;
                    }
                    _S711 = int(1);
                    ended_0 = _S713;
                    spread_3 = _S1199;
                    width_4 = width_6;
                    throughput_8 = throughput_11;
                    b_5 = b_8;
                    break;
                }
                if(_S1146)
                {
                    Reservoir candidate_8 = _S1168;
                    uint _S1225 = extractBits_0(_S1168.path, 10U, 2U);
                    bool _S1226 = _S1225 == 1U;
                    if(_S1226)
                    {
                        float3  _S1227 = safeDivide(_S1221, chain_throughput_0);
                        (&candidate_8)->radiance = _S1227;
                    }
                    else
                    {
                        uint _S1228 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                        uint _S1229 = insertBits_0(_S1228, 2U, 10U, 2U);
                        (&candidate_8)->path = _S1229;
                    }
                    Reservoir _S1230 = withEnd(candidate_8, 0U, b_8, _S1221);
                    offer(sel_1, _S1230, _S1221 * make_float3 (scale_1) / make_float3 (density_3));
                    float _S1231 = survivalProbability(throughput_11, density_3);
                    uint _S1232 = stream(_S740, b_8 + 128U);
                    Random _S1233 = pcg(_S1232);
                    bool _S1234 = _S1231 < (_S1233.value);
                    if(_S1234)
                    {
                        _S1021 = true;
                    }
                    else
                    {
                        uint _S1235 = (fcptMaxBounces());
                        _S1021 = b_8 >= _S1235;
                    }
                    if(_S1021)
                    {
                        _S711 = int(1);
                        ended_0 = _S713;
                        spread_3 = _S1199;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_5 = b_8;
                        break;
                    }
                    float _S1236 = density_3 * _S1231;
                    density_3 = _S1236;
                }
                else
                {
                }
                NEEVertex _S1237 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_4)->origin, _S712, (&ray_4)->origin);
                nee_vertex_0 = _S1237;
                uint _S1238 = stream(_S740, b_8);
                float3  _S1239 = isotropic_0(_S1238);
                (&ray_4)->unit_direction = _S1239;
                Vertex _S1240 = scatteredVertex_0(is_inside_5);
                prev_0 = _S1240;
                float _S1241 = (&prev_0)->pdf;
                FKRay _S1242 = ray_4;
                FKHit _S1243 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1244 = (fcptTraverseInstanceBVH((_S1242), (true), (4.294967296e+09f), (false), (_S1243), (false)));
                hit_1 = _S1244;
                b_7 = b_8;
                throughput_10 = throughput_11;
                spread_2 = _S1199;
                width_3 = width_6;
                sky_pdf_1 = _S1241;
            }
            if(_S711 != int(2))
            {
                spread_2 = spread_3;
                width_3 = width_4;
                throughput_10 = throughput_8;
                b_7 = b_5;
                _S1017 = true;
                break;
            }
            ended_0 = _S713;
            _S1017 = false;
            break;
        }
        if(_S1017)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1018 = b_7 == b_4;
        }
        else
        {
            _S1018 = false;
        }
        Reservoir _S1245 = chain_0;
        NEEVertex _S1246 = nee_vertex_0;
        Vertex _S1247 = prev_0;
        FKHit _S1248 = hit_1;
        uint _S1249 = filling_2;
        float3  _S1250 = scatter_in_0;
        float3  _S1251 = extinction_in_0;
        float3  _S1252 = weight_1;
        float3  _S1253 = glowed_0;
        for(;;)
        {
            bool _S1254 = (_S1248.instance_index) == 4294967295U;
            if(_S1254)
            {
                bool _S1255 = !_S1246.none;
                float _S1256 = _slang_select(_S1255, sky_pdf_1,0.0f);
                float _S1257 = escapeWeight_0(_S1256, (&ray_4)->unit_direction);
                float3  _S1258 = environment_0((&ray_4)->unit_direction, b_7, _S1247.lobe);
                float3  _S1259 = throughput_10 * _S1258;
                if(replay_1)
                {
                    bool _S1260 = b_7 == _S728;
                    if(_S1260)
                    {
                        _S1019 = _S717 == 3U;
                    }
                    else
                    {
                        _S1019 = false;
                    }
                    if(_S1019)
                    {
                        Shift _S1261 = Shift_x24init_0(_S1259 * make_float3 (_S1257) / make_float3 (r_3->jac), density_3 / r_3->jac);
                        arrived_end_0 = _S1261;
                        width_4 = width_3;
                        throughput_8 = throughput_10;
                        _S1019 = true;
                        break;
                    }
                    if(_S727)
                    {
                        _S1020 = _S724;
                    }
                    else
                    {
                        _S1020 = false;
                    }
                    if(_S1020)
                    {
                        _S1021 = b_7 == _S715;
                    }
                    else
                    {
                        _S1021 = false;
                    }
                    if(_S1021)
                    {
                        _S1022 = !_S1247.rough;
                    }
                    else
                    {
                        _S1022 = false;
                    }
                    if(_S1022)
                    {
                        Shift _S1262 = Shift_x24init_0(_S1259 * make_float3 (_S1257), 1.0f);
                        arrived_end_0 = _S1262;
                        width_4 = width_3;
                        throughput_8 = throughput_10;
                        _S1019 = true;
                        break;
                    }
                    arrived_end_0 = _S713;
                    width_4 = width_3;
                    throughput_8 = throughput_10;
                    _S1019 = true;
                    break;
                }
                Reservoir candidate_9 = _S1245;
                uint _S1263 = extractBits_0(_S1245.path, 10U, 2U);
                bool _S1264 = _S1263 == 1U;
                if(_S1264)
                {
                    uint _S1265 = extractBits_0(_S1245.path, 5U, 5U);
                    bool _S1266 = _S1265 == b_7;
                    float _S1267 = _slang_select(_S1266, 1.0f,_S1257);
                    float3  _S1268 = safeDivide(_S1259 * make_float3 (_S1267), chain_throughput_0);
                    (&candidate_9)->radiance = _S1268;
                }
                else
                {
                    if(_S1247.rough)
                    {
                        uint _S1269 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                        uint _S1270 = insertBits_0(_S1269, 3U, 10U, 2U);
                        uint _S1271 = insertBits_0(_S1270, _S1247.lobe, 15U, 2U);
                        uint _S1272 = _slang_select(_S1247.inside, 1U,0U);
                        uint _S1273 = insertBits_0(_S1271, _S1272, 20U, 1U);
                        (&candidate_9)->path = _S1273;
                        (&candidate_9)->jac = _S1247.pdf;
                        (&candidate_9)->dir = (&ray_4)->unit_direction;
                    }
                    else
                    {
                    }
                }
                float3  _S1274 = _S1259 * make_float3 (_S1257);
                Reservoir _S1275 = withEnd(candidate_9, 3U, b_7, _S1274);
                offer(sel_1, _S1275, _S1274 * make_float3 (scale_1) / make_float3 (density_3));
                arrived_end_0 = _S713;
                width_4 = width_3;
                throughput_8 = throughput_10;
                _S1019 = true;
                break;
            }
            float3  _S1276 = (&ray_4)->origin + make_float3 (_S1248.distance) * (&ray_4)->unit_direction;
            (&ray_4)->origin = _S1276;
            bool _S1277 = _S1249 != 4294967295U;
            if(_S1277)
            {
                if(_S1146)
                {
                    float3  _S1278 = throughput_10 * _S1253 / make_float3 (density_3);
                    float3  _S1279 = sel_1->glow + _S1278;
                    sel_1->glow = _S1279;
                }
                else
                {
                }
                float3  _S1280 = throughput_10 * _S1252;
                throughput_8 = _S1280;
            }
            else
            {
                float3  _S1281 = flightWeight_0(_S1250, _S1251, (_S1250.x + _S1250.y + _S1250.z) / 3.0f, _S1248.distance, false);
                float3  _S1282 = throughput_10 * _S1281;
                throughput_8 = _S1282;
            }
            float _S1283 = width_3 + spread_2 * _S1248.distance;
            arrived_end_0 = _S713;
            width_4 = _S1283;
            _S1019 = false;
            break;
        }
        if(_S1019)
        {
            return arrived_end_0;
        }
        viewed_0 = _S1018;
        width_2 = width_4;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1160 = b_7 + 1U;
        b_4 = _S1160;
        layer_0 = _S1159;
    }
    return _S713;
}

static __device__ Shift shift_0(Domain * dom_1, Reservoir * r_4)
{
    Selection _S1284 = (Selection{});
    Selection sel_2 = _S1284;
    bool _S1285 = (r_4->w) <= 0.0f;
    if(_S1285)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1286 = walk_0(dom_1, r_4, true, 0.0f, &sel_2);
    return _S1286;
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
    Random _S1287 = pcg(state_3);
    Random _S1288 = pcg(_S1287.state);
    float _S1289 = 6.28318548202514648f * _S1287.value;
    float _S1290 = (F32_sqrt((-2.0f * clamp_0((F32_log((_S1288.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1288.state, _S1290 * (F32_cos((_S1289))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1291;
    (&_S1291)->state = state_4;
    (&_S1291)->value = value_2;
    return _S1291;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1292 = normal_distribution(state_5);
    Random _S1293 = normal_distribution(_S1292.state);
    Random _S1294 = normal_distribution(_S1293.state);
    float3  _S1295 = make_float3 (_S1292.value, _S1293.value, _S1294.value);
    float3  _S1296 = ((((_S1295)) * make_float3(rnorm3df(((_S1295)).x, ((_S1295)).y, ((_S1295)).z))));
    return RandomSphere_x24init_0(_S1294.state, _S1296);
}

struct RandomHemisphere
{
    uint state;
    float3  value;
};

static __device__ RandomHemisphere RandomHemisphere_x24init_0(uint state_6, float3  value_3)
{
    RandomHemisphere _S1297;
    (&_S1297)->state = state_6;
    (&_S1297)->value = value_3;
    return _S1297;
}

__device__ RandomHemisphere random_hemisphere(uint state_7, float3  normal_4)
{
    RandomSphere _S1298 = random_sphere(state_7);
    bool _S1299 = (dot_0(_S1298.value, normal_4)) > 0.0f;
    if(_S1299)
    {
        return RandomHemisphere_x24init_0(_S1298.state, _S1298.value);
    }
    else
    {
        float3  _S1300 = negate_0(_S1298.value);
        return RandomHemisphere_x24init_0(_S1298.state, _S1300);
    }
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_15)
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
    float3  _S1312 = t_1 - n_15 * make_float3 (dot_0(n_15, t_1));
    float3  t_2 = ((((_S1312)) * make_float3(rnorm3df(((_S1312)).x, ((_S1312)).y, ((_S1312)).z))));
    bool _S1313 = (dot_0(cross_0(n_15, t_2), _S1311)) > 0.0f;
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
    float3  _S1315 = cross_0(n_15, t_3);
    return makeMatrix<float, 3, 3> (t_3, _S1315, n_15);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
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

__device__ float3  sampleHalfVector(float3  v_6, float3  n_i_5, float alpha_6, uint * random_state_15)
{
    float3  _S1328 = sampleMaterialHalfVector(v_6, n_i_5, alpha_6, AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f)), random_state_15);
    return _S1328;
}

__device__ float3  straightThrough(float3  dir_14, float3  n_16, BSDFMaterial material_16)
{
    float3  _S1329 = negate_0(dir_14);
    float _S1330 = sign_0(dot_0(n_16, _S1329));
    float3  _S1331 = n_16 * make_float3 (_S1330);
    AnisotropicFrame _S1332 = anisotropicFrame(material_16, _S1331);
    bool _S1333 = (_S1332.alphas.x) > 0.0f;
    if(_S1333)
    {
        float _S1334 = material_16.transmission * (1.0f - material_16.metallic);
        float3  _S1335 = negate_0(_S1331);
        float3  _S1336 = anisotropicLocal(dir_14, _S1332.tangent, _S1335);
        float _S1337 = anisotropicG1(_S1336, _S1332.alphas);
        return make_float3 (_S1334 * _S1337) * material_16.albedo;
    }
    float _S1338 = material_16.transmission * (1.0f - material_16.metallic);
    float _S1339 = material_16.roughness;
    float _S1340 = smithG1(_S1339 * _S1339, (F32_abs((dot_0(n_16, dir_14)))));
    return make_float3 (_S1338 * _S1340) * material_16.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_4, float3  out_dir_4, uint p_5, float w_2, float alpha_7, uint nt_0)
{
    uint _S1341 = p_5 % 4U;
    float _S1342 = w_2 * HAIR_WIDTHS_0[_S1341];
    float _S1343 = (F32_asin((clamp_0(dot_0(out_dir_4, t_4), -1.0f, 1.0f)))) - (F32_asin((clamp_0(dot_0(in_dir_11, t_4), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1341] * alpha_7;
    return ((F32_asinh((_S1343 / _S1342))) / (F32_asinh((3.14159274101257324f / _S1342))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_5, float3  out_dir_5, uint np_0)
{
    float3  _S1344 = worldToTangent(out_dir_5, t_5);
    float3  _S1345 = worldToTangent(in_dir_12, t_5);
    return (F32_frac((((F32_atan2((_S1344.z), (_S1344.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1345.z), (1.17549435082228751e-38f - _S1345.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_6, uint p_6, float row_0, float column_0, float w_3, float alpha_8, uint nt_1, uint np_1)
{
    float3  _S1346 = worldToTangent(in_dir_13, t_6);
    uint _S1347 = p_6 % 4U;
    float _S1348 = w_3 * HAIR_WIDTHS_0[_S1347];
    float _S1349 = (F32_asin((clamp_0(dot_0(in_dir_13, t_6), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1347] * alpha_8 + _S1348 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1348))))));
    float _S1350 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1346.z), (1.17549435082228751e-38f - _S1346.x)));
    float _S1351 = (F32_cos((_S1349)));
    float3  _S1352 = tangentToWorld(make_float3 (_S1351 * (F32_cos((_S1350))), (F32_sin((_S1349))), _S1351 * (F32_sin((_S1350)))), t_6);
    return _S1352;
}

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_5, float3  end_1)
{
    float _S1353 = sign_0(dot_0(light_n_0, start_5 - end_1));
    return light_n_0 * make_float3 (_S1353 * light_offset_0);
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_17, BSDFMaterial material_17, float coverage_1)
{
    float3  _S1354;
    if((material_17.ior) == 1.0f)
    {
        float3  _S1355 = straightThrough(toward_1, n_17, material_17);
        _S1354 = _S1355;
    }
    else
    {
        _S1354 = make_float3 (0.0f);
    }
    return _S1354 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_5, Shift shifted_0, float mis_0)
{
    Reservoir candidate_10 = r_5;
    float3  _S1356 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_10)->f = _S1356;
    float _S1357 = r_5.jac * shifted_0.jac;
    (&candidate_10)->jac = _S1357;
    offer(sel_3, candidate_10, make_float3 (mis_0) * shifted_0.f * make_float3 (r_5.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_6 = sel_4.r;
    float _S1358 = rgb_to_greyscale((&r_6)->f);
    float _S1359 = sel_4.w_sum / _S1358;
    bool _S1360 = _S1358 > 0.0f;
    float _S1361 = _slang_select(_S1360, _S1359,0.0f);
    (&r_6)->w = _S1361;
    (&r_6)->c = c_1;
    return r_6;
}

static __device__ float interpolate_0(float a_6, float b_9, float t_7)
{
    return a_6 + (b_9 - a_6) * t_7;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S1362 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S1362;
}

__device__ float2  temporalWeights(float c_2, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S1363 = c_2 * p_c_0;
    float _S1364 = c_t_0 * p_t_0;
    return make_float2 (_S1363 / (_S1363 + c_t_0 * g_previous_0), _S1364 / (_S1364 + c_2 * g_current_0));
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
    Domain _S1365 = dom_2;
    Reservoir _S1366 = r_7;
    Shift _S1367 = walk_0(&_S1365, &_S1366, replay_2, scale_2, sel_5);
    return _S1367;
}

__device__ Shift shift_hook(Domain dom_3, Reservoir r_8)
{
    Domain _S1368 = dom_3;
    Reservoir _S1369 = r_8;
    Shift _S1370 = shift_0(&_S1368, &_S1369);
    return _S1370;
}

#undef Matrix
