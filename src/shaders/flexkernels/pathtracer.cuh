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

__device__ float importance(LightNode node_0, float3  p_0, float3  normal_0)
{
    float3  _S41 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S42 = node_0.high - node_0.low;
    float3  _S43 = p_0 - _S41;
    float3  _S44 = ((((_S43)) * make_float3(rnorm3df(((_S43)).x, ((_S43)).y, ((_S43)).z))));
    float _S45 = dot_0(_S43, _S43);
    float _S46 = dot_0(_S42, _S42) / 4.0f;
    float _S47 = (F32_abs((dot_0(node_0.w, _S44))));
    float _S48 = sine(node_0.cos_theta_o);
    float _S49 = (F32_sqrt(((F32_max((1.0f - _S46 / _S45), (0.0f))))));
    bool _S50 = _S45 < _S46;
    float _S51 = _slang_select(_S50, -1.0f,_S49);
    float _S52 = sine(_S51);
    float _S53 = sine(_S47);
    float _S54 = cosSubClamped(_S53, _S47, _S48, node_0.cos_theta_o);
    float _S55 = sine(_S47);
    float _S56 = _S55 * node_0.cos_theta_o - _S47 * _S48;
    bool _S57 = _S47 > (node_0.cos_theta_o);
    float _S58 = _slang_select(_S57, 0.0f,_S56);
    float _S59 = cosSubClamped(_S58, _S54, _S52, _S51);
    bool _S60 = _S59 <= 0.0f;
    if(_S60)
    {
        return 0.0f;
    }
    float _S61 = - dot_0(_S44, normal_0);
    float _S62 = node_0.phi * _S59 / (F32_max((_S45), (length_0(_S42) / 2.0f)));
    float _S63 = sine(_S61);
    float _S64 = cosSubClamped(_S63, _S61, _S52, _S51);
    bool _S65 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S66 = _slang_select(_S65, 1.0f,_S64);
    return (F32_max((_S62 * _S66), (0.0f)));
}

__device__ __forceinline__ float childShare(LightNode first_0, LightNode second_0, float3  p_1, float3  normal_1, uint child_0)
{
    float _S67 = importance(first_0, p_1, normal_1);
    float _S68 = importance(second_0, p_1, normal_1);
    float2  _S69 = make_float2 (_S67, _S68);
    float _S70 = _slang_vector_get_element(_S69, child_0) / (_S67 + _S68);
    bool _S71 = _slang_vector_get_element(_S69, child_0) > 0.0f;
    float _S72 = _slang_select(_S71, _S70,0.0f);
    return _S72;
}

__device__ float sphereDensity(float3  center_0, float radius_0, float3  p_2)
{
    float3  _S73 = center_0 - p_2;
    float _S74 = radius_0 * radius_0 / dot_0(_S73, _S73);
    bool _S75 = _S74 >= 1.0f;
    if(_S75)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S74)))) / (6.28318548202514648f * _S74);
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S76 = left_0.y;
    float _S77 = right_0.z;
    float _S78 = left_0.z;
    float _S79 = right_0.y;
    float _S80 = right_0.x;
    float _S81 = left_0.x;
    return make_float3 (_S76 * _S77 - _S78 * _S79, _S78 * _S80 - _S81 * _S77, _S81 * _S79 - _S76 * _S80);
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_0))));
}

static __device__ float lightPdf_0(float3  origin_3, float3  smooth_n_1, float3  start_1, uint j_0, float3  light_point_0)
{
    bool _S82 = j_0 == 4294967295U;
    if(_S82)
    {
        return 0.0f;
    }
    uint4  _S83 = (fcptLightTrail((j_0)));
    uint2  _S84 = uint2 {_S83.x, _S83.y};
    uint n_0 = 0U;
    uint2  trail_0 = _S84;
    float probability_1 = 1.0f;
    for(;;)
    {
        uint4  _S85 = (fcptLightNode((n_0)));
        if((_S85.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S86 = (fcptLightSecond((n_0)));
        uint _S87 = n_0 + 1U;
        LightNode _S88 = (fcptLightBounds((_S87)));
        LightNode _S89 = (fcptLightBounds((_S86)));
        uint _S90 = trail_0.x;
        uint _S91 = _S90 & 1U;
        float _S92 = childShare(_S88, _S89, origin_3, smooth_n_1, _S91);
        float probability_2 = probability_1 * _S92;
        bool _S93 = _S91 == 1U;
        uint _S94 = _slang_select(_S93, _S86,_S87);
        uint _S95 = trail_0.y;
        uint2  _S96 = make_uint2 ((_S90 >> 1U) | (_S95 << 31U), _S95 >> 1U);
        n_0 = _S94;
        trail_0 = _S96;
        probability_1 = probability_2;
    }
    bool _S97 = (fcptSlotLeaf((n_0), (j_0)));
    bool _S98 = !_S97;
    bool _S99;
    if(_S98)
    {
        _S99 = true;
    }
    else
    {
        LightNode _S100 = (fcptLightBounds((n_0)));
        float _S101 = importance(_S100, origin_3, smooth_n_1);
        _S99 = !(_S101 > 0.0f);
    }
    if(_S99)
    {
        _S99 = true;
    }
    else
    {
        bool _S102 = (dot_0(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S102)
        {
            _S99 = !((dot_0(smooth_n_1, light_point_0 - origin_3)) > 0.0f);
        }
        else
        {
            _S99 = false;
        }
    }
    if(_S99)
    {
        return 0.0f;
    }
    uint4  _S103 = (fcptLightNode((n_0)));
    bool _S104 = (_S103.x) == 2U;
    if(_S104)
    {
        uint _S105 = _S103.y;
        FKLight _S106 = (fcptLight((_S105)));
        FKLight _S107 = (fcptLight((_S105)));
        float _S108 = sphereDensity(_S106.position, _S107.variance, start_1);
        return probability_1 * _S108;
    }
    uint _S109 = _S103.y;
    uint _S110 = (fcptTriangleOffset((_S109)));
    Matrix<float, 3, 3>  _S111 = (fcptWorldTriangle((_S109), (_S110 + _S103.z)));
    float _S112 = solidAngle(probability_1, cross_0(_S111.rows[int(1)] - _S111.rows[int(0)], _S111.rows[int(2)] - _S111.rows[int(0)]), light_point_0 - start_1);
    return _S112;
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
    uint _S113 = x_2 * 747796405U + 2891336453U;
    uint _S114 = ((_S113 >> ((_S113 >> 28U) + 4U)) ^ _S113) * 277803737U;
    return (_S114 >> 22U) ^ _S114;
}

static __device__ Random Random_x24init_0(uint state_0, float value_0)
{
    Random _S115;
    (&_S115)->state = state_0;
    (&_S115)->value = value_0;
    return _S115;
}

__device__ Random pcg(uint state_1)
{
    uint _S116 = hash(state_1);
    float value_1 = float(_S116 >> int(8)) * 5.9604644775390625e-08f;
    return Random_x24init_0(_S116, value_1);
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
    uint2  _S117 = (fcptEnvironmentCdfSize());
    uint2  _S118 = _S117 - make_uint2 (1U, 0U);
    float2  _S119 = make_float2 ((F32_atan2((- dir_2.z), (- dir_2.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_0(dir_2.y, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S120 = make_float2 ((float)_S118.x, (float)_S118.y);
    float2  _S121 = _S119 * _S120;
    uint2  _S122 = make_uint2 ((uint)_S121.x, (uint)_S121.y);
    uint2  _S123 = min_0(_S122, _S118 - make_uint2 (1U));
    float4  _S124 = (fcptEnvironmentCdf((_S123)));
    float _S125 = _S124.y;
    uint _S126 = _S118.x;
    float4  _S127 = (fcptEnvironmentCdf((make_uint2 (_S126, _S123.y))));
    float _S128 = _S125 * _S127.y;
    return _S128 * float(_S126 * _S118.y) / (19.73921012878417969f * length_1(float2 {dir_2.x, dir_2.z}));
}

static __device__ float3  negate_0(float3  x_7)
{
    return - x_7;
}

static __device__ float sign_0(float e_0)
{
    float _S129;
    if(e_0 > 0.0f)
    {
        _S129 = 1.0f;
    }
    else
    {
        if(e_0 < 0.0f)
        {
            _S129 = -1.0f;
        }
        else
        {
            _S129 = 0.0f;
        }
    }
    return _S129;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S130;
    (&_S130)->tangent = tangent_0;
    (&_S130)->alphas = alphas_0;
    return _S130;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_0 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S131 = (F32_abs((dot_0(n_1, a_0)))) > 0.9999847412109375f;
    float3  a_1;
    if(_S131)
    {
        float3  _S132 = make_float3 (1.0f, 0.0f, 0.0f);
        a_1 = _S132;
    }
    else
    {
        a_1 = a_0;
    }
    float3  _S133 = cross_0(n_1, a_1);
    float3  _S134 = ((((_S133)) * make_float3(rnorm3df(((_S133)).x, ((_S133)).y, ((_S133)).z))));
    float3  _S135 = cross_0(n_1, _S134);
    return make_float3 (v_0.x) * _S134 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S135;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_0, float3  n_i_0)
{
    float _S136 = material_0.roughness;
    float _S137 = _S136 * _S136;
    bool _S138 = (material_0.anisotropy) == 0.0f;
    bool _S139;
    if(_S138)
    {
        _S139 = true;
    }
    else
    {
        _S139 = !(_S137 > 0.0f);
    }
    if(_S139)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S140 = material_0.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_0.tangent));
    float3  _S141 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S142 = (dot_0(_S140, _S140)) > 0.0f;
    float3  _S143 = _slang_select(_S142, _S140,_S141);
    float3  _S144 = ((((_S143)) * make_float3(rnorm3df(((_S143)).x, ((_S143)).y, ((_S143)).z))));
    float _S145 = 6.28318548202514648f * material_0.anisotropic_rotation;
    float _S146 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_0.anisotropy))))));
    float _S147 = 1.0f / _S146;
    bool _S148 = (material_0.anisotropy) < 0.0f;
    float _S149 = _slang_select(_S148, _S147,_S146);
    return AnisotropicFrame_x24init_0(_S144 * make_float3 ((F32_cos((_S145)))) + cross_0(n_i_0, _S144) * make_float3 ((F32_sin((_S145)))), make_float2 (_S137 / _S149, _S137 * _S149));
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S150;
    (&_S150)->on = on_0;
    (&_S150)->albedo = albedo_0;
    return _S150;
}

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

__device__ static const FixedArray<float, 576>  SHEEN_ALBEDO_0 = { {
    0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f
} };
__device__ __forceinline__ SheenProfile sheenProfile(float3  v_1, float3  n_i_1, BSDFMaterial material_1)
{
    SheenProfile _S151 = SheenProfile_x24init_0(false, 0.0f);
    float _S152 = rgb_to_greyscale(material_1.sheen);
    bool _S153 = _S152 > 0.0f;
    SheenProfile profile_0;
    if(_S153)
    {
        float _S154 = clamp_0((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S155 = (U32_min((uint(_S154)), (22U)));
        float _S156 = (F32_sqrt((0.05000000074505806f)));
        float _S157 = (clamp_0((F32_sqrt(((F32_max((material_1.sheen_roughness), (0.0f)))))), _S156, 1.0f) - _S156) / (1.0f - _S156) * 23.0f;
        uint _S158 = (U32_min((uint(_S157)), (22U)));
        uint _S159 = _S155 * 24U + _S158;
        float _S160 = _S154 - float(_S155);
        float _S161 = _S157 - float(_S158);
        uint _S162 = _S159 + 24U;
        float _S163 = SHEEN_ALBEDO_0[_S159] + (SHEEN_ALBEDO_0[_S162] - SHEEN_ALBEDO_0[_S159]) * _S160;
        uint _S164 = _S159 + 1U;
        float _S165 = SHEEN_ALBEDO_0[_S164] + (SHEEN_ALBEDO_0[_S162 + 1U] - SHEEN_ALBEDO_0[_S164]) * _S160;
        SheenProfile _S166 = SheenProfile_x24init_0(true, (F32_exp((_S163 + (_S165 - _S163) * _S161))));
        profile_0 = _S166;
    }
    else
    {
        profile_0 = _S151;
    }
    return profile_0;
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
    BSDFLobes _S167;
    (&_S167)->v_dot_h = v_dot_h_0;
    (&_S167)->n_dot_h = n_dot_h_0;
    (&_S167)->refracted = refracted_1;
    (&_S167)->F = F_0;
    (&_S167)->F_greyscale = F_greyscale_0;
    (&_S167)->reflect_weight = reflect_weight_0;
    (&_S167)->diffuse_weight = diffuse_weight_0;
    (&_S167)->refract_weight = refract_weight_0;
    (&_S167)->p_diffuse = p_diffuse_0;
    (&_S167)->p_reflect = p_reflect_0;
    (&_S167)->p_refract = p_refract_0;
    (&_S167)->translucent_share = translucent_share_0;
    (&_S167)->sheen = sheen_0;
    (&_S167)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S167)->view = view_0;
    (&_S167)->tangent = tangent_1;
    (&_S167)->alphas = alphas_1;
    (&_S167)->visible = visible_0;
    return _S167;
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
    float3  _S168 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S169 = ((((_S168)) * make_float3(rnorm3df(((_S168)).x, ((_S168)).y, ((_S168)).z))));
    float _S170 = _S169.x;
    float _S171 = _S169.y;
    float _S172 = _S170 * _S170 + _S171 * _S171;
    float3  _S173;
    if(_S172 > 0.0f)
    {
        float3  _S174 = make_float3 (- _S171, _S170, 0.0f);
        float _S175 = (rsqrtf((_S172)));
        _S173 = _S174 * make_float3 (_S175);
    }
    else
    {
        _S173 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S176 = cross_0(_S169, _S173);
    float _S177 = (F32_sqrt((U1_0)));
    float _S178 = 6.28318548202514648f * U2_0;
    float _S179 = _S177 * (F32_cos((_S178)));
    float t2_0 = _S177 * (F32_sin((_S178)));
    float _S180 = 0.5f * (1.0f + _S169.z);
    float t2_1 = (1.0f - _S180) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S179 * _S179)))))) + _S180 * t2_0;
    float3  _S181 = make_float3 (_S179) * _S173 + make_float3 (t2_1) * _S176;
    float _S182 = unshared_0(_S179);
    float _S183 = unshared_0(_S179);
    float3  _S184 = _S181 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S182 * _S183 - t2_1 * t2_1))))))) * _S169;
    float3  _S185 = make_float3 (alpha_0 * _S184.x, alpha_0 * _S184.y, (F32_max((0.0f), (_S184.z))));
    float3  _S186 = ((((_S185)) * make_float3(rnorm3df(((_S185)).x, ((_S185)).y, ((_S185)).z))));
    return _S186;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_3)
{
    float3  a_2 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S187 = (F32_abs((dot_0(n_3, a_2)))) > 0.9999847412109375f;
    float3  a_3;
    if(_S187)
    {
        float3  _S188 = make_float3 (1.0f, 0.0f, 0.0f);
        a_3 = _S188;
    }
    else
    {
        a_3 = a_2;
    }
    float3  _S189 = cross_0(n_3, a_3);
    float3  _S190 = ((((_S189)) * make_float3(rnorm3df(((_S189)).x, ((_S189)).y, ((_S189)).z))));
    float3  _S191 = cross_0(n_3, _S190);
    return make_float3 (dot_0(v_2, _S190), dot_0(v_2, n_3), dot_0(v_2, _S191));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_0, uint * random_state_1)
{
    Random _S192 = pcg(*random_state_1);
    Random _S193 = pcg(_S192.state);
    *random_state_1 = _S193.state;
    float _S194 = frame_0.alphas.x;
    bool _S195 = _S194 > 0.0f;
    if(_S195)
    {
        float3  _S196 = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        float _S197 = frame_0.alphas.y;
        float3  _S198 = make_float3 (_S194 * _S196.x, _S197 * _S196.y, _S196.z);
        float3  _S199 = ((((_S198)) * make_float3(rnorm3df(((_S198)).x, ((_S198)).y, ((_S198)).z))));
        float3  _S200 = sampleGGXVNDF(_S199, 1.0f, _S192.value, _S193.value);
        float3  _S201 = make_float3 (_S194 * _S200.x, _S197 * _S200.y, _S200.z);
        float3  _S202 = ((((_S201)) * make_float3(rnorm3df(((_S201)).x, ((_S201)).y, ((_S201)).z))));
        return make_float3 (_S202.x) * frame_0.tangent + make_float3 (_S202.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S202.z) * n_i_2;
    }
    float3  _S203 = worldToTangent(v_3, n_i_2);
    float3  _S204 = sampleGGXVNDF(float3 {_S203.x, _S203.z, _S203.y}, alpha_1, _S192.value, _S193.value);
    float3  _S205 = float3 {_S204.x, _S204.z, _S204.y};
    float3  _S206 = tangentToWorld(_S205, n_i_2);
    return _S206;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_4, BSDFMaterial material_2, uint random_state_2, AnisotropicFrame frame_1)
{
    uint state_2 = random_state_2;
    float3  _S207 = negate_0(in_dir_0);
    float _S208 = sign_0(dot_0(n_4, _S207));
    float _S209 = material_2.roughness;
    float3  _S210 = sampleHalfVector(_S207, n_4 * make_float3 (_S208), _S209 * _S209, frame_1, &state_2);
    return _S210;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_5, float eta_i_0, float eta_o_0)
{
    float3  _S211 = negate_0(in_dir_1);
    float3  _S212 = negate_0(make_float3 (eta_i_0) * _S211 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S213 = ((((_S212)) * make_float3(rnorm3df(((_S212)).x, ((_S212)).y, ((_S212)).z))));
    float _S214 = sign_0(dot_0(n_5, _S211));
    float _S215 = sign_0(dot_0(_S212, n_5 * make_float3 (_S214)));
    return _S213 * make_float3 (_S215);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S216 = negate_0(in_dir_2);
    float3  _S217 = _S216 + out_dir_1;
    float3  _S218 = ((((_S217)) * make_float3(rnorm3df(((_S217)).x, ((_S217)).y, ((_S217)).z))));
    return _S218;
}

static __device__ float3  refract_0(float3  i_1, float3  n_6, float eta_0)
{
    float _S219 = dot_0(n_6, i_1);
    float _S220 = 1.0f - eta_0 * eta_0 * (1.0f - _S219 * _S219);
    if(_S220 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_1 - make_float3 (eta_0 * _S219 + (F32_sqrt((_S220)))) * n_6;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S221 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S222 = eta_i_1 / eta_o_1 * _S221;
    bool _S223 = _S222 < 1.0f;
    float kr_0;
    if(_S223)
    {
        float _S224 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S222 * _S222))))));
        float _S225 = eta_o_1 * cos_theta_0;
        float _S226 = eta_i_1 * _S224;
        float _S227 = (_S225 - _S226) / (_S225 + _S226);
        float _S228 = eta_i_1 * cos_theta_0;
        float _S229 = eta_o_1 * _S224;
        float _S230 = (_S228 - _S229) / (_S228 + _S229);
        float _S231 = (_S227 * _S227 + _S230 * _S230) / 2.0f;
        kr_0 = _S231;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

__device__ float anisotropicG1(float3  w_1, float2  alphas_2)
{
    float _S232 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S232 / (_S232 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S232)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S233 = alphas_3.x;
    float _S234 = h_0.x / _S233;
    float _S235 = alphas_3.y;
    float _S236 = h_0.y / _S235;
    float _S237 = h_0.z;
    float _S238 = _S234 * _S234 + _S236 * _S236 + _S237 * _S237;
    return 1.0f / (F32_max((3.14159274101257324f * _S233 * _S235 * _S238 * _S238), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_4, float3  n_i_3, float3  ggx_n_0, BSDFMaterial material_3, float eta_i_2, float eta_o_2, AnisotropicFrame frame_2, SheenProfile sheen_profile_0)
{
    float _S239 = dot_0(ggx_n_0, v_4);
    float _S240 = dot_0(n_i_3, ggx_n_0);
    float _S241 = eta_i_2 / eta_o_2;
    float3  _S242 = refract_0(in_dir_3, ggx_n_0, _S241);
    float3  _S243 = ((((_S242)) * make_float3(rnorm3df(((_S242)).x, ((_S242)).y, ((_S242)).z))));
    float _S244 = (F32_min(((F32_sqrt((material_3.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S245 = _S244 * _S244;
    float _S246 = (1.0f + _S244) / (1.0f - _S244);
    float _S247 = (F32_abs((_S239)));
    bool _S248 = eta_i_2 > eta_o_2;
    float sheen_component_0;
    if(_S248)
    {
        sheen_component_0 = _S246;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float visible_1;
    if(_S248)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S246;
    }
    float _S249 = fresnel(_S247, sheen_component_0, visible_1);
    bool _S250 = (eta_i_2 * eta_i_2 * (1.0f - _S239 * _S239)) >= (eta_o_2 * eta_o_2);
    float3  _S251;
    if(_S250)
    {
        _S251 = make_float3 (1.0f);
    }
    else
    {
        float3  _S252 = material_3.specular_tint * make_float3 (_S245);
        _S251 = _S252 + (make_float3 (1.0f) - _S252) * make_float3 (_S249 - _S245) / make_float3 (1.0f - _S245);
    }
    float3  _S253 = make_float3 (1.0f);
    float3  _S254 = make_float3 (0.0f);
    float3  scale_0;
    float3  sheen_1;
    float3  view_1;
    if(sheen_profile_0.on)
    {
        float _S255 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S256 = make_float3 (1.0f) - material_3.sheen * make_float3 (_S255);
        float _S257 = rgb_to_greyscale(material_3.sheen);
        float _S258 = _S257 * _S255;
        float3  _S259 = material_3.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        scale_0 = _S256;
        sheen_component_0 = _S258;
        sheen_1 = _S259;
        view_1 = v_4;
    }
    else
    {
        scale_0 = _S253;
        sheen_component_0 = 0.0f;
        sheen_1 = _S254;
        view_1 = _S254;
    }
    float3  _S260 = mix_0(_S251, material_3.albedo, material_3.metallic);
    float3  F_1 = _S260 * scale_0;
    float _S261 = rgb_to_greyscale(F_1);
    float _S262 = 1.0f - material_3.metallic;
    float3  _S263 = make_float3 (1.0f) - _S251;
    float3  _S264 = make_float3 ((1.0f - material_3.transmission) * _S262) * _S263 * scale_0;
    float3  _S265 = make_float3 (material_3.transmission * _S262) * _S263 * scale_0;
    float _S266 = (F32_max((_S261), (0.0f)));
    float _S267 = rgb_to_greyscale(_S264);
    float _S268 = (F32_max((_S267), (0.0f)));
    float _S269 = rgb_to_greyscale(_S265);
    float _S270 = sign_0(length_0(_S243));
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
        float3  _S282 = anisotropicLocal(v_4, frame_2.tangent, n_i_3);
        float _S283 = anisotropicG1(_S282, frame_2.alphas);
        float3  _S284 = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        float _S285 = anisotropicD(_S284, frame_2.alphas);
        float _S286 = _S283 * _S285;
        visible_1 = _S286;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S239, _S240, _S243, F_1, _S261, 1.0f, _S264, _S265, _S278, _S279, _S280, 0.0f, sheen_1, _S276, view_1, frame_2.tangent, frame_2.alphas, visible_1);
}

__device__ float translucentShare(BSDFMaterial material_4)
{
    float _S287 = rgb_to_greyscale(material_4.translucent);
    float _S288 = rgb_to_greyscale(material_4.albedo);
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

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_4, float alpha_3, BSDFMaterial material_5, BSDFLobes lobes_1)
{
    bool _S302 = (dot_0(n_i_4, l_0)) < 0.0f;
    float3  _S303 = _slang_select(_S302, material_5.translucent,material_5.albedo);
    float _S304 = 1.0f - lobes_1.translucent_share;
    float _S305 = _slang_select(_S302, lobes_1.translucent_share,_S304);
    float3  _S306 = _S303 / make_float3 (_S305);
    bool _S307 = (lobes_1.translucent_share) > 0.0f;
    float3  _S308 = _slang_select(_S307, _S306,material_5.albedo);
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

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_5, float alpha_8, BSDFMaterial material_6, BSDFLobes lobes_4)
{
    float _S332 = - dot_0(n_i_5, l_1);
    float _S333 = smithG1(alpha_8, (F32_max((_S332), (0.0f))));
    bool _S334 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S334)
    {
        float3  _S335 = negate_0(n_i_5);
        float3  _S336 = anisotropicLocal(l_1, lobes_4.tangent, _S335);
        float _S337 = anisotropicG1(_S336, lobes_4.alphas);
        G1_l_0 = _S337;
    }
    else
    {
        G1_l_0 = _S333;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_6.albedo / make_float3 (lobes_4.p_refract);
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

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_6, float alpha_10, BSDFMaterial material_7, BSDFLobes lobes_6)
{
    float3  _S342 = l_2 + lobes_6.view;
    float3  _S343 = ((((_S342)) * make_float3(rnorm3df(((_S342)).x, ((_S342)).y, ((_S342)).z))));
    float _S344 = dot_0(n_i_6, _S343);
    float _S345 = (F32_max((dot_0(n_i_6, l_2)), (0.0f)));
    float _S346 = (F32_max((dot_0(n_i_6, lobes_6.view)), (0.0f)));
    float _S347 = 1.0f / (F32_max((material_7.sheen_roughness), (0.05000000074505806f)));
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

__device__ __forceinline__ float3  reflectBSDF(float3  l_3, float3  n_i_7, float alpha_12, BSDFMaterial material_8, BSDFLobes lobes_8)
{
    float _S353 = dot_0(n_i_7, l_3);
    float _S354 = smithG1(alpha_12, (F32_max((_S353), (0.0f))));
    bool _S355 = (lobes_8.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S355)
    {
        float3  _S356 = anisotropicLocal(l_3, lobes_8.tangent, n_i_7);
        float _S357 = anisotropicG1(_S356, lobes_8.alphas);
        G1_l_1 = _S357;
    }
    else
    {
        G1_l_1 = _S354;
    }
    return make_float3 (lobes_8.reflect_weight * G1_l_1) * lobes_8.F / make_float3 (lobes_8.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_9, float eta_i_7, float eta_o_7, bool refracted_2, uint random_state_3, FixedArray<float3 , 4>  * throughputs_0, FixedArray<float, 4>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S358 = negate_0(in_dir_4);
    float _S359 = dot_0(n_7, _S358);
    float _S360 = sign_0(_S359);
    float3  _S361 = n_7 * make_float3 (_S360);
    AnisotropicFrame _S362 = anisotropicFrame(material_9, _S361);
    float _S363 = dot_0(_S361, out_dir_2);
    float _S364 = material_9.roughness;
    float _S365 = _S364 * _S364;
    SheenProfile _S366 = sheenProfile(_S358, _S361, material_9);
    float _S367 = rgb_to_greyscale(material_9.translucent);
    bool _S368 = _S367 > 0.0f;
    bool _S369 = (dot_0(n_7, out_dir_2) * _S359) < 0.0f;
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
        float3  _S370 = make_float3 (0.0f);
        (*throughputs_0)[i_2] = _S370;
        (*pdfs_0)[i_2] = 0.0f;
        uint i_3 = i_2 + 1U;
        i_2 = i_3;
    }
    float3  _S371 = make_float3 (0.0f);
    BSDFLobes _S372 = BSDFLobes_x24init_0(0.0f, 0.0f, _S371, _S371, 0.0f, 0.0f, _S371, _S371, 0.0f, 0.0f, 0.0f, 0.0f, _S371, 0.0f, _S371, _S371, make_float2 (0.0f), 0.0f);
    BSDFLobes lobe_terms_0 = _S372;
    uint half_of_0 = 4294967295U;
    float3  ggx_n_2 = _S371;
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
        uint _S373;
        if(i_2 == 3U)
        {
            _S373 = 4U;
        }
        else
        {
            _S373 = i_2;
        }
        bool _S374 = _S373 == 0U;
        bool _S375;
        if(_S374)
        {
            _S375 = _S368;
        }
        else
        {
            _S375 = false;
        }
        bool _S376;
        if(_S375)
        {
            _S376 = _S369;
        }
        else
        {
            _S376 = _S373 == 1U;
        }
        bool _S377 = _S376 != refracted_2;
        if(_S377)
        {
            ggx_n_1 = ggx_n_2;
            uint i_4 = i_2 + 1U;
            ggx_n_2 = ggx_n_1;
            i_2 = i_4;
            continue;
        }
        uint _S378;
        if(_S373 == 4U)
        {
            _S378 = 2U;
        }
        else
        {
            _S378 = _S373;
        }
        bool _S379 = _S378 != half_of_0;
        uint half_of_1;
        if(_S379)
        {
            bool _S380 = _S378 == 0U;
            if(_S380)
            {
                float3  _S381 = sampledHalf(in_dir_4, n_7, material_9, random_state_3, _S362);
                ggx_n_1 = _S381;
            }
            else
            {
                bool _S382 = _S378 == 1U;
                if(_S382)
                {
                    float3  _S383 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_7, eta_o_7);
                    ggx_n_1 = _S383;
                }
                else
                {
                    float3  _S384 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S384;
                }
            }
            float3  _S385 = negate_0(in_dir_4);
            BSDFLobes _S386 = bsdfLobes(in_dir_4, _S385, _S361, ggx_n_1, material_9, eta_i_7, eta_o_7, _S362, _S366);
            lobe_terms_0 = _S386;
            float _S387 = translucentShare(material_9);
            (&lobe_terms_0)->translucent_share = _S387;
            half_of_1 = _S378;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S373)
        {
        case 0U:
            {
                float _S388 = diffusePDF(_S363, 0.0f, (F32_abs((_S359))), _S365, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(0)] = _S388;
                float3  _S389 = diffuseBSDF(out_dir_2, _S361, _S365, material_9, lobe_terms_0);
                (*throughputs_0)[int(0)] = _S389;
                break;
            }
        case 1U:
            {
                float _S390 = refractPDF(_S363, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S359))), _S365, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(1)] = _S390;
                float3  _S391 = refractBSDF(out_dir_2, _S361, _S365, material_9, lobe_terms_0);
                (*throughputs_0)[int(1)] = _S391;
                break;
            }
        case 4U:
            {
                float _S392 = sheenVelvetPDF(_S363, 0.0f, (F32_abs((_S359))), _S365, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(3)] = _S392;
                float3  _S393 = sheenVelvetBSDF(out_dir_2, _S361, _S365, material_9, lobe_terms_0);
                (*throughputs_0)[int(3)] = _S393;
                break;
            }
        default:
            {
                float _S394 = reflectPDF(_S363, 0.0f, (F32_abs((_S359))), _S365, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(2)] = _S394;
                float3  _S395 = reflectBSDF(out_dir_2, _S361, _S365, material_9, lobe_terms_0);
                (*throughputs_0)[int(2)] = _S395;
                break;
            }
        }
        half_of_0 = half_of_1;
        uint i_4 = i_2 + 1U;
        ggx_n_2 = ggx_n_1;
        i_2 = i_4;
    }
    i_2 = 0U;
    ggx_n_1 = _S371;
    for(;;)
    {
        if(i_2 < 4U)
        {
        }
        else
        {
            break;
        }
        bool _S396 = ((*pdfs_0)[i_2]) > 0.0f;
        if(_S396)
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
    bool _S397 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    float3  _S398 = BSDF(in_dir_5, dir_3, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S397, random_state_4, terms_0, pdfs_1);
    float3  _S399 = make_float3 (0.0f);
    uint i_6 = 0U;
    float3  f_1 = _S399;
    for(;;)
    {
        if(i_6 < 4U)
        {
        }
        else
        {
            break;
        }
        bool _S400 = ((*pdfs_1)[i_6]) > 0.0f;
        if(_S400)
        {
            float3  _S401 = (*terms_0)[i_6] * make_float3 ((*pdfs_1)[i_6]) / make_float3 ((*pdfs_1)[i_6] + pdf_0);
            (*terms_0)[i_6] = _S401;
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
    FKSurface _S402 = surface_2;
    FixedArray<float3 , 4>  terms_1;
    FixedArray<float, 4>  pdfs_2;
    float3  _S403 = skyLobes_0(in_dir_6, dir_4, &_S402, eta_2, is_inside_3, pdf_1, random_state_5, &terms_1, &pdfs_2);
    return _S403;
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
    SkySample _S404;
    (&_S404)->dir = dir_5;
    (&_S404)->radiance = radiance_0;
    (&_S404)->color = color_0;
    (&_S404)->random_state = random_state_6;
    return _S404;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0)
{
    uint2  _S405 = (fcptEnvironmentCdfSize());
    uint2  _S406 = make_uint2 (1U, 0U);
    uint2  _S407 = _S405 - _S406;
    Random _S408 = pcg(init_random_state_0);
    Random _S409 = pcg(_S408.state);
    Random _S410 = pcg(_S409.state);
    Random _S411 = pcg(_S410.state);
    uint _S412 = _S407.x;
    uint _S413 = searchCDF_0(make_uint2 (_S412, 0U), make_uint2 (0U, 1U), _S407.y, _S408.value);
    uint _S414 = searchCDF_0(make_uint2 (0U, _S413), _S406, _S412, _S409.value);
    float2  _S415 = make_float2 ((float)_S407.x, (float)_S407.y);
    float2  _S416 = (make_float2 (float(_S414), float(_S413)) + make_float2 (_S410.value, _S411.value)) / _S415 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S417 = _S416.y;
    float _S418 = (F32_sin((_S417)));
    float _S419 = _S416.x;
    float3  _S420 = make_float3 (_S418 * (F32_cos((_S419))), (F32_cos((_S417))), _S418 * (F32_sin((_S419))));
    float _S421 = environmentPdf_0(_S420);
    float3  _S422 = skyBSDF(ray_0->unit_direction, _S420, *surface_3, eta_3, is_inside_4, _S421, lobe_state_0);
    bool _S423 = !(_S421 > 0.0f);
    bool _S424;
    if(_S423)
    {
        _S424 = true;
    }
    else
    {
        _S424 = all_0(_S422 == make_float3 (0.0f));
    }
    if(_S424)
    {
        float3  _S425 = make_float3 (0.0f);
        return SkySample_x24init_0(_S420, _S425, _S425, _S411.state);
    }
    float3  _S426 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S420);
    return SkySample_x24init_0(_S420, _S426, _S422 * _S426, _S411.state);
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
    SampleBSDF _S427 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S428 = _S427.throughput * make_float3 (_S427.pdf);
    float _S429 = light_1->density;
    float _S430 = 1.0f + _S427.pdf * _S427.pdf / (light_1->density * light_1->density);
    bool _S431;
    if(competing_0)
    {
        _S431 = _S429 > 0.0f;
    }
    else
    {
        _S431 = false;
    }
    float _S432 = _slang_select(_S431, _S430,1.0f);
    return _S428 / make_float3 (_S432) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_7)
{
    TreeSample _S433;
    (&_S433)->dir = dir_6;
    (&_S433)->radiance = radiance_1;
    (&_S433)->density = density_0;
    (&_S433)->random_state = random_state_7;
    return _S433;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_3, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S434 = importance(first_1, p_3, normal_3);
    float _S435 = importance(second_1, p_3, normal_3);
    float2  _S436 = make_float2 (_S434, _S435);
    bool _S437 = _S434 == 0.0f;
    bool _S438;
    if(_S437)
    {
        _S438 = _S435 == 0.0f;
    }
    else
    {
        _S438 = false;
    }
    if(_S438)
    {
        return 2U;
    }
    float _S439 = _S434 + _S435;
    bool _S440 = _S435 > 0.0f;
    if(_S440)
    {
        _S438 = (*pick_0 * _S439) >= _S434;
    }
    else
    {
        _S438 = false;
    }
    uint _S441 = uint(_S438);
    float _S442 = (F32_min(((*pick_0 * _S439 - float(_S441) * _S434) / _slang_vector_get_element(_S436, _S441)), (0.99999994039535522f)));
    *pick_0 = _S442;
    float _S443 = *probability_3 * (_slang_vector_get_element(_S436, _S441) / _S439);
    *probability_3 = _S443;
    return _S441;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_4, float u1_0, float u2_0)
{
    float3  _S444 = center_1 - p_4;
    float _S445 = radius_1 * radius_1 / dot_0(_S444, _S444);
    float _S446 = u1_0 * _S445 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S445), (0.0f)))))));
    float _S447 = 2.0f * u1_0;
    bool _S448 = _S445 >= 1.0f;
    float _S449 = _slang_select(_S448, _S447,_S446);
    float _S450 = (F32_sqrt(((F32_max((_S449 * (2.0f - _S449)), (0.0f))))));
    float _S451 = 6.28318548202514648f * u2_0;
    float3  _S452 = make_float3 (_S450 * (F32_cos((_S451))), 1.0f - _S449, _S450 * (F32_sin((_S451))));
    float3  _S453 = ((((_S444)) * make_float3(rnorm3df(((_S444)).x, ((_S444)).y, ((_S444)).z))));
    float3  _S454 = tangentToWorld(_S452, _S453);
    return _S454;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S455 = center_2 - ray_1->origin;
    float _S456 = dot_0(_S455, ray_1->unit_direction);
    float _S457 = dot_0(_S455, _S455) - _S456 * _S456;
    float _S458 = radius_3 * radius_3;
    bool _S459 = _S457 > _S458;
    if(_S459)
    {
        return 4.294967296e+09f;
    }
    float _S460 = (F32_sqrt((_S458 - _S457)));
    float _S461 = _S456 - _S460;
    float _S462 = _S456 + _S460;
    bool _S463 = _S461 > 0.0000152587890625f;
    bool _S464;
    if(_S463)
    {
        _S464 = _S461 < max_len_0;
    }
    else
    {
        _S464 = false;
    }
    if(_S464)
    {
        return _S461;
    }
    bool _S465 = _S462 > 0.0000152587890625f;
    if(_S465)
    {
        _S464 = _S462 < max_len_0;
    }
    else
    {
        _S464 = false;
    }
    if(_S464)
    {
        return _S462;
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
    Random _S466 = pcg(init_random_state_1);
    Random _S467 = pcg(_S466.state);
    Random _S468 = pcg(_S467.state);
    float3  _S469 = make_float3 (0.0f);
    TreeSample _S470 = TreeSample_x24init_0(_S469, _S469, 0.0f, _S468.state);
    TreeSample sample_0 = _S470;
    float3  _S471 = _slang_select(sided_0, _S469,smooth_n_2);
    float3  _S472 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S466.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S473 = (fcptLightNode((n_8)));
        if((_S473.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S474 = (fcptLightSecond((n_8)));
        uint _S475 = n_8 + 1U;
        LightNode _S476 = (fcptLightBounds((_S475)));
        LightNode _S477 = (fcptLightBounds((_S474)));
        uint _S478 = pickChild(_S476, _S477, origin_4, _S471, &pick_1, &probability_4);
        bool _S479 = _S478 > 1U;
        if(_S479)
        {
            return sample_0;
        }
        bool _S480 = _S478 == 1U;
        uint _S481 = _slang_select(_S480, _S474,_S475);
        n_8 = _S481;
    }
    bool _S482 = n_8 == 0U;
    bool _S483;
    if(_S482)
    {
        LightNode _S484 = (fcptLightBounds((0U)));
        float _S485 = importance(_S484, origin_4, _S471);
        _S483 = !(_S485 > 0.0f);
    }
    else
    {
        _S483 = false;
    }
    if(_S483)
    {
        return sample_0;
    }
    uint4  _S486 = (fcptLightNode((n_8)));
    FKHit _S487 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S488 = (_S486.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S488)
    {
        FKLight _S489 = (fcptLight((_S486.y)));
        if(sided_0)
        {
            float _S490 = sign_0(dot_0(geometry_n_1, _S489.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S490);
            float3  _S491 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S491;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S472;
            lift_n_0 = smooth_n_2;
        }
        bool _S492 = (_S489.variance) == 0.0f;
        if(_S492)
        {
            float3  _S493 = _S489.position - emitter_point_0;
            float3  _S494 = ((((_S493)) * make_float3(rnorm3df(((_S493)).x, ((_S493)).y, ((_S493)).z))));
            (&sample_0)->dir = _S494;
            float3  _S495 = _S489.color * make_float3 (_S489.intensity) / make_float3 (dot_0(_S493, _S493) * probability_4);
            (&sample_0)->radiance = _S495;
            shadow_1 = _S493;
        }
        else
        {
            float3  _S496 = sampleSphere(_S489.position, _S489.variance, emitter_point_0, _S467.value, _S468.value);
            (&sample_0)->dir = _S496;
            float _S497 = sphereDensity(_S489.position, _S489.variance, emitter_point_0);
            float _S498 = probability_4 * _S497;
            (&sample_0)->density = _S498;
            float3  _S499 = pointLightRadiance(_S489.color, _S489.intensity, _S489.variance);
            float3  _S500 = _S499 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S500;
            FKRay _S501 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S502 = raySphere_0(_S489.position, _S489.variance, &_S501, 4.294967296e+09f);
            float3  _S503 = (&sample_0)->dir * make_float3 (_S502);
            shadow_1 = _S503;
        }
        emitter_0 = _S487;
        emitter_point_0 = _S469;
    }
    else
    {
        uint _S504 = _S486.y;
        uint _S505 = (fcptTriangleOffset((_S504)));
        uint _S506 = _S505 + _S486.z;
        Matrix<float, 3, 3>  _S507 = (fcptWorldTriangle((_S504), (_S506)));
        float _S508 = (F32_sqrt((_S467.value)));
        float2  _S509 = make_float2 (_S508 * (1.0f - _S468.value), _S508 * _S468.value);
        float3  _S510 = mul_0(make_float3 (1.0f - _S508, _S509.x, _S509.y), _S507);
        if(sided_0)
        {
            float _S511 = sign_0(dot_0(geometry_n_1, _S510 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S511);
            float3  _S512 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S512;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S513 = !((dot_0(smooth_n_2, _S510 - origin_4)) > 0.0f);
            if(_S513)
            {
                return sample_0;
            }
            emitter_point_0 = _S472;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S509, _S504, _S506, 0U, 0.0f);
        float3  _S514 = _S510 - emitter_point_0;
        float3  _S515 = ((((_S514)) * make_float3(rnorm3df(((_S514)).x, ((_S514)).y, ((_S514)).z))));
        (&sample_0)->dir = _S515;
        float _S516 = solidAngle(probability_4, cross_0(_S507.rows[int(1)] - _S507.rows[int(0)], _S507.rows[int(2)] - _S507.rows[int(0)]), _S514);
        (&sample_0)->density = _S516;
        bool _S517 = (fcptShadowFirst());
        bool _S518 = !_S517;
        if(_S518)
        {
            FKSurface _S519 = (fcptLightSurfaceAt((emitter_1), (_S510), (_S468.state), ((&sample_0)->dir), (context_1->depth), (length_0(_S510 - origin_4))));
            (&sample_0)->random_state = _S519.random_state;
            float3  _S520 = _slang_select(_S519.skip, _S469,_S519.material.emissive);
            float3  _S521 = _S520 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S521;
        }
        shadow_1 = _S514;
        emitter_0 = emitter_1;
        emitter_point_0 = _S510;
    }
    FKHit _S522 = emitter_0;
    float3  _S523 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_1, _S468.state, &_S522);
    bool _S524 = (fcptShadowFirst());
    if(_S524)
    {
        _S483 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S483 = false;
    }
    if(_S483)
    {
        _S483 = !all_0(_S523 == _S469);
    }
    else
    {
        _S483 = false;
    }
    if(_S483)
    {
        FKSurface _S525 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S468.state), ((&sample_0)->dir), (context_1->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S525.random_state;
        float3  _S526 = _slang_select(_S525.skip, _S469,_S525.material.emissive);
        float3  _S527 = _S526 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S527;
    }
    float3  _S528 = (&sample_0)->radiance * _S523;
    bool _S529 = all_0(_S523 == _S469);
    float3  _S530 = _slang_select(_S529, _S469,_S528);
    (&sample_0)->radiance = _S530;
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
    float _S531 = 1.0f / (1.0f + b_0 / a_4 * (b_0 / a_4));
    bool _S532 = b_0 > 0.0f;
    float _S533 = _slang_select(_S532, _S531,1.0f);
    return _S533;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_0, float3  light_point_1)
{
    bool _S534 = vertex_0->none;
    if(_S534)
    {
        return 1.0f;
    }
    uint _S535 = (fcptLightSlot((*hit_0)));
    float _S536 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S535, light_point_1);
    float _S537 = powerHeuristic(vertex_0->pdf, _S536);
    return _S537;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_0)
{
    uint2  _S538 = (fcptEnvironmentMapSize());
    bool _S539 = (_S538.x) > 1U;
    bool _S540;
    if(_S539)
    {
        uint2  _S541 = (fcptEnvironmentMapSize());
        _S540 = (_S541.y) > 1U;
    }
    else
    {
        _S540 = false;
    }
    if(_S540)
    {
        float3  _S542 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_0)));
        return _S542;
    }
    float3  _S543 = (fcptAmbient());
    return _S543;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S544 = (fcptEnvironmentCdfSize());
    bool _S545 = (_S544.x) > 1U;
    bool _S546;
    if(_S545)
    {
        uint2  _S547 = (fcptEnvironmentCdfSize());
        _S546 = (_S547.y) > 1U;
    }
    else
    {
        _S546 = false;
    }
    bool _S548 = !_S546;
    if(_S548)
    {
        return false;
    }
    uint2  _S549 = (fcptEnvironmentMapSize());
    bool _S550 = (_S549.x) > 1U;
    if(_S550)
    {
        uint2  _S551 = (fcptEnvironmentMapSize());
        _S546 = (_S551.y) > 1U;
    }
    else
    {
        _S546 = false;
    }
    return _S546;
}

static __device__ float escapeWeight_0(float pdf_2, float3  dir_8)
{
    bool _S552 = pdf_2 <= 0.0f;
    bool _S553;
    if(_S552)
    {
        _S553 = true;
    }
    else
    {
        bool _S554 = environmentMapped_0();
        _S553 = !_S554;
    }
    if(_S553)
    {
        return 1.0f;
    }
    float _S555 = environmentPdf_0(dir_8);
    return pdf_2 / (pdf_2 + _S555);
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
    Shift _S556;
    (&_S556)->f = f_3;
    (&_S556)->jac = jac_0;
    return _S556;
}

static __device__ uint extractBits_0(uint e_1, uint offset_0, uint count_1)
{
    return (e_1 >> offset_0) & ((1U << count_1) - 1U);
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_3, float3  origin_5, float3  smooth_n_3, float3  start_2)
{
    NEEVertex _S557;
    (&_S557)->none = none_0;
    (&_S557)->pdf = pdf_3;
    (&_S557)->origin = origin_5;
    (&_S557)->smooth_n = smooth_n_3;
    (&_S557)->start = start_2;
    return _S557;
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
    Vertex _S558;
    (&_S558)->rough = rough_0;
    (&_S558)->lobe = lobe_1;
    (&_S558)->pdf = pdf_4;
    (&_S558)->cos = cos_0;
    (&_S558)->inside = inside_0;
    return _S558;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S559 = hash(index_0);
    uint _S560 = hash(seed_0 ^ _S559);
    return _S560;
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

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_0, float distance_1, bool scatters_0)
{
    float3  _S561 = exp_0((make_float3 (sigma_0) - extinction_0) * make_float3 (distance_1));
    float3  _S562 = scatter_0 * _S561 / make_float3 (sigma_0);
    float3  _S563 = _slang_select(scatters_0, _S562,_S561);
    return _S563;
}

static __device__ uint arrivalLobe_0(uint b_1, uint prev_lobe_0)
{
    bool _S564 = b_1 > 0U;
    uint _S565 = _slang_select(_S564, prev_lobe_0,3U);
    return _S565;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_5, float length_2, float width_0, FKHit * own_0, bool fiber_0)
{
    ShadowContext _S566;
    (&_S566)->extinction_behind = extinction_behind_0;
    (&_S566)->extinction_front = extinction_front_0;
    (&_S566)->fillings = fillings_0;
    (&_S566)->side = side_0;
    (&_S566)->depth = depth_1;
    (&_S566)->lobe = lobe_2;
    (&_S566)->surface = surface_5;
    (&_S566)->length = length_2;
    (&_S566)->width = width_0;
    (&_S566)->own = *own_0;
    (&_S566)->fiber = fiber_0;
    return _S566;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S567 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S567)
    {
        return 0.07957746833562851f;
    }
    float _S568 = g_0 * g_0;
    return (1.0f - _S568) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S568 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_5, float3  b_2)
{
    float3  _S569 = a_5 / b_2;
    float3  _S570 = make_float3 (0.0f);
    bool3  _S571 = b_2 == _S570;
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

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_9, float * pdf_5)
{
    bool _S591 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S591)
    {
        *pdf_5 = 0.07957746833562851f;
        float3  _S592 = isotropic_0(random_state_9);
        return _S592;
    }
    Random _S593 = pcg(random_state_9);
    Random _S594 = pcg(_S593.state);
    float _S595 = g_1 * g_1;
    float _S596 = 2.0f * g_1;
    float _S597 = (1.0f - _S595) / (1.0f - g_1 + _S596 * _S593.value);
    float _S598 = clamp_0((1.0f + _S595 - _S597 * _S597) / _S596, -1.0f, 1.0f);
    float _S599 = (F32_sqrt(((F32_max((1.0f - _S598 * _S598), (0.0f))))));
    float _S600 = 6.28318548202514648f * _S594.value;
    float _S601 = phaseHG_0(g_1, _S598);
    *pdf_5 = _S601;
    float3  _S602 = tangentToWorld(make_float3 (_S599 * (F32_cos((_S600))), _S598, _S599 * (F32_sin((_S600)))), dir_9);
    float3  _S603 = ((((_S602)) * make_float3(rnorm3df(((_S602)).x, ((_S602)).y, ((_S602)).z))));
    return _S603;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2)
{
    BSDFMaterial _S604;
    (&_S604)->albedo = albedo_1;
    (&_S604)->emissive = emissive_0;
    (&_S604)->roughness = roughness_0;
    (&_S604)->metallic = metallic_0;
    (&_S604)->transmission = transmission_0;
    (&_S604)->ior = ior_0;
    (&_S604)->absorption = absorption_0;
    (&_S604)->specular_tint = specular_tint_0;
    (&_S604)->specular_level = specular_level_0;
    (&_S604)->translucent = translucent_0;
    (&_S604)->sheen = sheen_2;
    (&_S604)->sheen_roughness = sheen_roughness_0;
    (&_S604)->anisotropy = anisotropy_0;
    (&_S604)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S604)->tangent = tangent_2;
    return _S604;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S605;
    (&_S605)->scatter = scatter_1;
    (&_S605)->extinction = extinction_1;
    (&_S605)->g = g_2;
    return _S605;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_10, bool skip_0, uint random_state_10, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S606;
    (&_S606)->smooth_n = smooth_n_4;
    (&_S606)->geometry_n = geometry_n_2;
    (&_S606)->geometry_offset = geometry_offset_2;
    (&_S606)->material = *material_10;
    (&_S606)->skip = skip_0;
    (&_S606)->random_state = random_state_10;
    (&_S606)->coverage = coverage_0;
    (&_S606)->encloses = encloses_0;
    (&_S606)->volume = *volume_0;
    (&_S606)->fills = fills_0;
    (&_S606)->hair = hair_0;
    return _S606;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S607 = (&surface_6->material)->emissive;
    float3  _S608 = make_float3 (0.0f);
    bool _S609 = !top_0;
    float3  _S610 = _slang_select(_S609, _S608,_S607);
    (&(&lower_0)->material)->emissive = _S610;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_1)
{
    float _S611 = surface_7->coverage;
    bool _S612 = u_1 < _S611;
    if(_S612)
    {
        return *surface_7;
    }
    float3  _S613 = make_float3 (0.0f);
    float3  _S614 = make_float3 (1.0f);
    BSDFMaterial _S615 = Material_x24init_0(_S613, _S613, 0.0f, 0.0f, 0.0f, 0.0f, _S613, _S614, 1.0f, _S613, _S613, 0.5f, 0.0f, 0.0f, _S613);
    BSDFMaterial material_11 = _S615;
    (&material_11)->albedo = _S614;
    (&material_11)->emissive = (&surface_7->material)->emissive;
    (&material_11)->transmission = 1.0f;
    (&material_11)->ior = 1.0f;
    (&material_11)->absorption = (&surface_7->material)->absorption;
    FKSurface through_0 = *surface_7;
    (&through_0)->material = material_11;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S616 = transmission_1 > 0.0f;
    bool _S617;
    if(_S616)
    {
        _S617 = true;
    }
    else
    {
        _S617 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S618;
    if(_S617)
    {
        _S618 = 1.0f;
    }
    else
    {
        _S618 = -1.0f;
    }
    return _S618;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_9)
{
    return (dot_0(dir_10, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_11)
{
    float3  _S619 = surface_8->geometry_n;
    float _S620 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_11);
    FKSurface faced_0 = *surface_8;
    float3  _S621 = surface_8->smooth_n * make_float3 (_S620);
    (&faced_0)->smooth_n = _S621;
    float3  _S622 = _S619 * make_float3 (_S620);
    (&faced_0)->geometry_n = _S622;
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
    float3  _S623 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_2) * log_0(_S623));
}

__device__ float2  vertexEta(BSDFMaterial material_12, float n_dot_v_0)
{
    bool _S624 = n_dot_v_0 < 0.0f;
    float _S625 = _slang_select(_S624, material_12.ior,1.0f);
    float _S626 = _slang_select(_S624, 1.0f,material_12.ior);
    return make_float2 (_S625, _S626);
}

__device__ bool neeDecision(BSDFMaterial material_13, float n_dot_v_1, float eta_i_8, float eta_o_8)
{
    float _S627 = fresnel((F32_abs((n_dot_v_1))), eta_i_8, eta_o_8);
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

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_12)
{
    float3  _S635 = surface_9->geometry_n;
    MediumSides _S636 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S636;
    bool _S637 = surface_9->encloses;
    if(_S637)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S638 = (dot_0(dir_12, _S635)) > 0.0f;
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

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_3, float length_3, float width_1, FKHit * own_1, bool fiber_1)
{
    float3  _S641 = surface_10->geometry_n;
    ShadowContext _S642 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
    bool _S643 = surface_10->encloses;
    ShadowContext context_2;
    if(_S643)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S644 = - _S641;
        float3  _S645 = _slang_select(turned_0, _S644,_S641);
        (&faced_1)->geometry_n = _S645;
        FKMedium _S646 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S647 = faced_1;
        FKMedium _S648 = _S646;
        MediumSides _S649 = mediumSides_0(&_S647, &_S648, filling_1, dir_13);
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

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_3, BSDFMaterial * material_15, float eta_i_9, float eta_o_9, bool competing_1, uint random_state_11)
{
    float3  _S653 = light_2->dir;
    bool _S654 = (dot_0(geometry_n_3, - in_dir_8) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 4>  throughputs_1;
    FixedArray<float, 4>  pdfs_3;
    float3  _S655 = BSDF(in_dir_8, _S653, smooth_n_5, *material_15, eta_i_9, eta_o_9, _S654, random_state_11, &throughputs_1, &pdfs_3);
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
        return _S655 * light_2->radiance;
    }
    float3  _S658 = make_float3 (0.0f);
    uint i_15 = 0U;
    float3  weighted_0 = _S658;
    for(;;)
    {
        if(i_15 < 4U)
        {
        }
        else
        {
            break;
        }
        bool _S659 = (pdfs_3[i_15]) > 0.0f;
        if(_S659)
        {
            float _S660 = light_2->density;
            float _S661 = pdfs_3[i_15] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_15] * make_float3 (pdfs_3[i_15]) / make_float3 (_S660 * (1.0f + _S661 * _S661));
            weighted_0 = weighted_1;
        }
        uint i_16 = i_15 + 1U;
        i_15 = i_16;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_12, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S662;
    (&_S662)->unit_direction = unit_direction_1;
    (&_S662)->throughput = throughput_1;
    (&_S662)->random_state = random_state_12;
    (&_S662)->refracted = refracted_3;
    (&_S662)->lobe = lobe_4;
    (&_S662)->pdf = pdf_6;
    return _S662;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_8, float n_i_dot_v_5, float alpha_13, BSDFMaterial material_16, BSDFLobes lobes_9, float eta_i_10, float eta_o_10, uint random_state_13)
{
    float3  _S663 = make_float3 (1.0f);
    SampleBSDF _S664 = SampleBSDF_x24init_0(_S663, _S663, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S664;
    Random _S665 = pcg(random_state_13);
    Random _S666 = pcg(_S665.state);
    (&sample_1)->random_state = _S666.state;
    float _S667 = _S665.value;
    float _S668 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S667 * _S667))))));
    float _S669 = 6.28318548202514648f * _S666.value;
    float3  _S670 = tangentToWorld(make_float3 (_S668 * (F32_cos((_S669))), _S665.value, _S668 * (F32_sin((_S669)))), n_i_8);
    (&sample_1)->unit_direction = _S670;
    (&sample_1)->lobe = 4U;
    float3  _S671 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_8, alpha_13, material_16, lobes_9);
    (&sample_1)->throughput = _S671;
    float _S672 = sheenVelvetPDF(_S665.value, 0.0f, n_i_dot_v_5, alpha_13, lobes_9, eta_i_10, eta_o_10);
    (&sample_1)->pdf = _S672;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S673 = (F32_sqrt((random_1_0)));
    float _S674 = 6.28318548202514648f * random_2_0;
    float _S675 = _S673 * (F32_cos((_S674)));
    float _S676 = _S673 * (F32_sin((_S674)));
    float _S677 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S675 * _S675 - _S676 * _S676))))));
    return make_float3 (_S675, _S677, _S676);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_2, float3  n_i_9, float n_i_dot_v_6, float alpha_14, BSDFMaterial material_17, BSDFLobes lobes_10, float eta_i_11, float eta_o_11, uint random_state_14)
{
    float3  _S678 = make_float3 (1.0f);
    SampleBSDF _S679 = SampleBSDF_x24init_0(_S678, _S678, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S679;
    Random _S680 = pcg(random_state_14);
    Random _S681 = pcg(_S680.state);
    (&sample_2)->random_state = _S681.state;
    float3  _S682 = sampleCosWeightedHemisphere(_S680.value, _S681.value);
    bool _S683 = u_2 < (lobes_10.p_diffuse * lobes_10.translucent_share);
    float _S684 = _S682.y;
    float _S685 = - _S684;
    float _S686 = _slang_select(_S683, _S685,_S684);
    float3  _S687 = tangentToWorld(make_float3 (_S682.x, _S686, _S682.z), n_i_9);
    (&sample_2)->unit_direction = _S687;
    (&sample_2)->refracted = _S683;
    (&sample_2)->lobe = 0U;
    float3  _S688 = diffuseBSDF((&sample_2)->unit_direction, n_i_9, alpha_14, material_17, lobes_10);
    (&sample_2)->throughput = _S688;
    float _S689 = diffusePDF(_S686, 0.0f, n_i_dot_v_6, alpha_14, lobes_10, eta_i_11, eta_o_11);
    (&sample_2)->pdf = _S689;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_10, float n_i_dot_v_7, float alpha_15, BSDFMaterial material_18, BSDFLobes lobes_11, float eta_i_12, float eta_o_12, uint random_state_15)
{
    float3  _S690 = make_float3 (1.0f);
    SampleBSDF _S691 = SampleBSDF_x24init_0(_S690, _S690, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S691;
    (&sample_3)->unit_direction = lobes_11.refracted;
    (&sample_3)->random_state = random_state_15;
    (&sample_3)->refracted = true;
    (&sample_3)->lobe = 1U;
    float3  _S692 = refractBSDF((&sample_3)->unit_direction, n_i_10, alpha_15, material_18, lobes_11);
    (&sample_3)->throughput = _S692;
    float _S693 = refractPDF(0.0f, dot_0((&sample_3)->unit_direction, ggx_n_3), n_i_dot_v_7, alpha_15, lobes_11, eta_i_12, eta_o_12);
    (&sample_3)->pdf = _S693;
    return sample_3;
}

static __device__ float3  reflect_0(float3  i_17, float3  n_10)
{
    return i_17 - make_float3 (2.0f * dot_0(n_10, i_17)) * n_10;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_11, float n_i_dot_v_8, float alpha_16, BSDFMaterial material_19, BSDFLobes lobes_12, float eta_i_13, float eta_o_13, uint random_state_16)
{
    float3  _S694 = make_float3 (1.0f);
    SampleBSDF _S695 = SampleBSDF_x24init_0(_S694, _S694, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S695;
    float3  _S696 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S697 = ((((_S696)) * make_float3(rnorm3df(((_S696)).x, ((_S696)).y, ((_S696)).z))));
    (&sample_4)->unit_direction = _S697;
    (&sample_4)->random_state = random_state_16;
    (&sample_4)->lobe = 2U;
    float3  _S698 = reflectBSDF((&sample_4)->unit_direction, n_i_11, alpha_16, material_19, lobes_12);
    (&sample_4)->throughput = _S698;
    float _S699 = reflectPDF(0.0f, 0.0f, n_i_dot_v_8, alpha_16, lobes_12, eta_i_13, eta_o_13);
    (&sample_4)->pdf = _S699;
    return sample_4;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_11, BSDFMaterial material_20, float eta_i_14, float eta_o_14, uint random_init_0, float2  screen_space_0)
{
    uint random_state_17 = random_init_0;
    float3  _S700 = negate_0(in_dir_10);
    float _S701 = dot_0(n_11, _S700);
    float _S702 = sign_0(_S701);
    float3  n_i_12 = n_11 * make_float3 (_S702);
    float _S703 = (F32_abs((_S701)));
    float _S704 = material_20.roughness;
    float _S705 = _S704 * _S704;
    AnisotropicFrame _S706 = anisotropicFrame(material_20, n_i_12);
    SheenProfile _S707 = sheenProfile(_S700, n_i_12, material_20);
    float3  _S708 = sampleHalfVector(_S700, n_i_12, _S705, _S706, &random_state_17);
    BSDFLobes _S709 = bsdfLobes(in_dir_10, _S700, n_i_12, _S708, material_20, eta_i_14, eta_o_14, _S706, _S707);
    BSDFLobes lobes_13 = _S709;
    float _S710 = translucentShare(material_20);
    (&lobes_13)->translucent_share = _S710;
    Random _S711 = pcg(random_state_17);
    random_state_17 = _S711.state;
    bool _S712 = (_S711.value) < ((&lobes_13)->p_sheen_velvet);
    if(_S712)
    {
        SampleBSDF _S713 = sheenVelvetSample(n_i_12, _S703, _S705, material_20, lobes_13, eta_i_14, eta_o_14, random_state_17);
        return _S713;
    }
    float _S714 = _S711.value - (&lobes_13)->p_sheen_velvet;
    bool _S715 = _S714 < ((&lobes_13)->p_diffuse);
    if(_S715)
    {
        SampleBSDF _S716 = diffuseSample(_S714, n_i_12, _S703, _S705, material_20, lobes_13, eta_i_14, eta_o_14, random_state_17);
        return _S716;
    }
    bool _S717 = _S714 < ((&lobes_13)->p_diffuse + (&lobes_13)->p_refract);
    if(_S717)
    {
        SampleBSDF _S718 = refractSample(_S708, n_i_12, _S703, _S705, material_20, lobes_13, eta_i_14, eta_o_14, random_state_17);
        return _S718;
    }
    SampleBSDF _S719 = reflectSample(in_dir_10, _S708, n_i_12, _S703, _S705, material_20, lobes_13, eta_i_14, eta_o_14, random_state_17);
    return _S719;
}

static __device__ bool boundsVolume_0(FKSurface * surface_11)
{
    return surface_11->encloses;
}

static __device__ float distance_3(float3  x_15, float3  y_5)
{
    return length_0(x_15 - y_5);
}

static __device__ Shift walk_0(Domain * dom_0, Reservoir * r_1, bool replay_0, float scale_1, Selection * sel_1)
{
    float spread_0;
    bool turned_1;
    bool is_inside_5;
    bool viewed_0;
    bool _S720;
    bool _S721;
    float density_2;
    float threshold_0;
    float width_2;
    float sky_pdf_0;
    float geometry_density_0;
    uint b_3;
    uint layer_0;
    float3  throughput_2;
    float3  chain_throughput_0;
    TreeSample light_3;
    int _S722;
    Shift ended_0;
    float density_3;
    float spread_1;
    float width_3;
    float sky_pdf_1;
    float spread_2;
    float width_4;
    uint b_4;
    float3  _S723 = make_float3 (0.0f);
    Shift _S724 = Shift_x24init_0(_S723, 0.0f);
    uint _S725 = r_1->path;
    uint _S726 = extractBits_0(r_1->path, 0U, 5U);
    uint _S727 = extractBits_0(_S725, 5U, 5U);
    uint _S728 = extractBits_0(_S725, 10U, 2U);
    uint _S729 = extractBits_0(_S725, 12U, 3U);
    bool passes_0;
    if(replay_0)
    {
        bool _S730 = _S729 >= 3U;
        uint _S731 = _slang_select(_S730, 1U,0U);
        uint _S732 = _S726 + _S731;
        uint _S733 = (fcptMaxBounces());
        passes_0 = _S732 > _S733;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S724;
    }
    uint _S734 = _S727 - 1U;
    bool _S735 = _S729 == 3U;
    uint _S736 = _slang_select(_S735, 1U,0U);
    uint _S737 = _S726 + _S736;
    bool _S738 = _S728 == 0U;
    uint _S739 = _slang_select(_S738, _S737,_S734);
    FKHit _S740 = (fcptReservoirHit((*r_1)));
    float3  _S741 = dom_0->x0;
    float3  _S742 = dom_0->x1 - dom_0->x0;
    float3  _S743 = ((((_S742)) * make_float3(rnorm3df(((_S742)).x, ((_S742)).y, ((_S742)).z))));
    FKRay _S744 = Ray_x24init_0(dom_0->x1, _S743);
    FKRay ray_2 = _S744;
    FKHit hit_1 = dom_0->hit;
    float3  scatter_in_0 = _S723;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S723;
    float3  extinction_in_0 = _S723;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S745 = dom_0->spread;
    float _S746 = dom_0->width;
    float _S747 = length_0(_S742);
    NEEVertex _S748 = NEEVertex_x24init_0(true, 0.0f, _S723, _S723, _S723);
    NEEVertex nee_vertex_0 = _S748;
    Vertex _S749 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S749;
    Reservoir _S750 = (Reservoir{});
    Reservoir chain_0 = _S750;
    uint _S751 = r_1->seed;
    (&chain_0)->seed = r_1->seed;
    (&ray_2)->origin = _S741;
    (&hit_1)->distance = _S747;
    FKMedium _S752 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_1)->distance), (&filling_2)));
    uint _S753 = filling_2;
    bool _S754 = (fcptVaryingUsed());
    uint _S755 = _slang_select(_S754, _S753,4294967295U);
    filling_2 = _S755;
    scatter_in_0 = _S752.scatter;
    extinction_in_0 = _S752.extinction;
    g_in_0 = _S752.g;
    Reservoir _S756 = chain_0;
    uint _S757 = filling_2;
    for(;;)
    {
        bool _S758 = (fcptVaryingUsed());
        if(_S758)
        {
            passes_0 = _S757 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S759 = (fcptMajorant((_S757)));
            spread_0 = _S759;
        }
        else
        {
            spread_0 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_0)
        {
            turned_1 = 4294967295U == _S739;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S728 == 1U;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = spread_0 > 0.0f;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            ended_0 = _S724;
            sky_pdf_0 = 0.0f;
            spread_0 = _S745;
            width_2 = _S746;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_3 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S760 = (&prev_0)->rough;
        if(_S760)
        {
            turned_1 = !(spread_0 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S761 = stream(_S751, 384U);
        uint tracking_0 = _S761;
        weight_1 = throughput_3;
        glowed_0 = _S723;
        b_3 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_0 = _S745;
        width_2 = _S746;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_1)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S722 = int(1);
                break;
            }
            uint _S762 = b_3 + 320U;
            bool _S763 = b_3 == 4294967295U;
            uint _S764 = _slang_select(_S763, 384U,_S762);
            uint _S765 = stream(_S751, _S764);
            Random _S766 = pcg(_S765);
            float _S767 = - (F32_log((1.0f - _S766.value))) / spread_0;
            if(passes_0)
            {
                float3  _S768 = (&ray_2)->origin;
                float3  _S769 = (&ray_2)->unit_direction;
                float _S770 = (&hit_1)->distance;
                uint _S771 = _slang_select(_S763, 0U,b_3);
                uint _S772 = (&prev_0)->lobe;
                uint _S773 = _slang_select(_S763, 3U,_S772);
                float _S774 = (fcptTrackMedium((_S757), (_S768), (_S769), (_S770), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S771), (_S773), (_S763)));
                geometry_density_0 = _S774;
            }
            else
            {
                geometry_density_0 = _S767;
            }
            bool _S775 = !(geometry_density_0 < ((&hit_1)->distance));
            if(_S775)
            {
                _S722 = int(1);
                break;
            }
            if(passes_0)
            {
                turned_1 = !replay_0;
            }
            else
            {
                turned_1 = false;
            }
            if(turned_1)
            {
                float3  _S776 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S777 = sel_1->glow + _S776;
                sel_1->glow = _S777;
            }
            else
            {
            }
            glowed_0 = _S723;
            uint b_5 = b_3 + 1U;
            float3  _S778 = (&ray_2)->origin + make_float3 (geometry_density_0) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S778;
            float3  _S779 = flightWeight_0(scatter_in_0, extinction_in_0, spread_0, geometry_density_0, true);
            float3  _S780 = weight_1;
            float3  _S781 = _slang_select(passes_0, _S780,_S779);
            float3  throughput_4 = throughput_2 * _S781;
            uint _S782 = stream(_S751, b_5 + 320U);
            tracking_0 = _S782;
            weight_1 = throughput_3;
            float width_5 = width_2 + threshold_0 * geometry_density_0;
            float _S783 = threshold_0 + 3.14159274101257324f;
            bool _S784 = !replay_0;
            if(_S784)
            {
                is_inside_5 = true;
            }
            else
            {
                bool _S785 = b_5 == _S739;
                if(_S785)
                {
                    is_inside_5 = !passes_0;
                }
                else
                {
                    is_inside_5 = false;
                }
            }
            TreeSample _S786 = TreeSample_x24init_0(_S723, _S723, 0.0f, 0U);
            if(is_inside_5)
            {
                float3  _S787 = (&ray_2)->origin;
                float3  _S788 = (&ray_2)->unit_direction;
                float3  _S789 = (&ray_2)->unit_direction;
                uint _S790 = stream(_S751, b_5 + 64U);
                float3  _S791 = extinction_in_0;
                float3  _S792 = extinction_in_0;
                uint2  _S793 = make_uint2 (_S757);
                float3  _S794 = (&ray_2)->unit_direction;
                uint _S795 = arrivalLobe_0(b_5, (&prev_0)->lobe);
                FKHit _S796 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S797 = _S796;
                ShadowContext _S798 = ShadowContext_x24init_0(_S791, _S792, _S793, _S794, b_5, _S795, false, geometry_density_0, width_5, &_S797, false);
                ShadowContext _S799 = _S798;
                TreeSample _S800 = sampleLightTree_0(_S787, _S788, _S789, 0.0f, true, _S790, &_S799);
                light_3 = _S800;
            }
            else
            {
                light_3 = _S786;
            }
            float _S801 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S802 = (fcptMaxBounces());
            bool _S803 = b_5 < _S802;
            if(_S803)
            {
                viewed_0 = (light_3.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S804 = _slang_select(viewed_0, _S801,0.0f);
            float3  _S805 = throughput_4 * light_3.radiance;
            float _S806 = powerHeuristic(light_3.density, _S804);
            float3  _S807 = _S805 * make_float3 (_S801 * _S806);
            float3  _S808 = _slang_select(is_inside_5, _S807,_S723);
            if(replay_0)
            {
                _S720 = b_5 == _S739;
            }
            else
            {
                _S720 = false;
            }
            if(_S720)
            {
                bool _S809 = _S728 == 2U;
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
                    _S722 = int(0);
                    ended_0 = _S811;
                    spread_0 = _S783;
                    geometry_density_0 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_5;
                    break;
                }
                _S722 = int(0);
                ended_0 = _S724;
                spread_0 = _S783;
                geometry_density_0 = width_5;
                chain_throughput_0 = throughput_4;
                layer_0 = b_5;
                break;
            }
            if(_S784)
            {
                Reservoir candidate_2 = _S756;
                uint _S812 = extractBits_0(_S756.path, 10U, 2U);
                bool _S813 = _S812 == 1U;
                if(_S813)
                {
                    float3  _S814 = safeDivide(_S808, _S723);
                    (&candidate_2)->radiance = _S814;
                }
                else
                {
                    uint _S815 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                    uint _S816 = insertBits_0(_S815, 2U, 10U, 2U);
                    (&candidate_2)->path = _S816;
                }
                Reservoir _S817 = withEnd(candidate_2, 0U, b_5, _S808);
                offer(sel_1, _S817, _S808 * make_float3 (scale_1) / make_float3 (density_2));
                float _S818 = survivalProbability(throughput_4, density_2);
                uint _S819 = stream(_S751, b_5 + 128U);
                Random _S820 = pcg(_S819);
                bool _S821 = _S818 < (_S820.value);
                if(_S821)
                {
                    _S721 = true;
                }
                else
                {
                    uint _S822 = (fcptMaxBounces());
                    _S721 = b_5 >= _S822;
                }
                if(_S721)
                {
                    _S722 = int(0);
                    ended_0 = _S724;
                    spread_0 = _S783;
                    geometry_density_0 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_5;
                    break;
                }
                float _S823 = density_2 * _S818;
                density_2 = _S823;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S824 = stream(_S751, b_5);
            float3  _S825 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S824, &phase_pdf_0);
            (&ray_2)->unit_direction = _S825;
            NEEVertex _S826 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S723, (&ray_2)->origin);
            nee_vertex_0 = _S826;
            Vertex _S827 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_0 = _S827;
            float _S828 = (&prev_0)->pdf;
            FKRay _S829 = ray_2;
            FKHit _S830 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S831 = (fcptTraverseInstanceBVH((_S829), (true), (4.294967296e+09f), (false), (_S830), (false)));
            hit_1 = _S831;
            b_3 = b_5;
            throughput_2 = throughput_4;
            threshold_0 = _S783;
            width_2 = width_5;
            sky_pdf_0 = _S828;
        }
        if(_S722 != int(1))
        {
            width_2 = geometry_density_0;
            throughput_2 = chain_throughput_0;
            b_3 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S724;
        spread_0 = threshold_0;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S832 = b_3 == 4294967295U;
    bool _S833 = ((&hit_1)->instance_index) == 4294967295U;
    if(_S833)
    {
        bool _S834 = !(&nee_vertex_0)->none;
        float _S835 = _slang_select(_S834, sky_pdf_0,0.0f);
        float _S836 = escapeWeight_0(_S835, (&ray_2)->unit_direction);
        float3  _S837 = environment_0((&ray_2)->unit_direction, b_3, (&prev_0)->lobe);
        float3  _S838 = throughput_2 * _S837;
        if(replay_0)
        {
            bool _S839 = b_3 == _S739;
            if(_S839)
            {
                passes_0 = _S728 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S838 * make_float3 (_S836) / make_float3 (r_1->jac), density_2 / r_1->jac);
            }
            if(_S738)
            {
                passes_0 = _S735;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_3 == _S726;
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
                return Shift_x24init_0(_S838 * make_float3 (_S836), 1.0f);
            }
            return _S724;
        }
        Reservoir candidate_3 = chain_0;
        uint _S840 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S841 = _S840 == 1U;
        if(_S841)
        {
            uint _S842 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S843 = _S842 == b_3;
            float _S844 = _slang_select(_S843, 1.0f,_S836);
            float3  _S845 = safeDivide(_S838 * make_float3 (_S844), _S723);
            (&candidate_3)->radiance = _S845;
        }
        else
        {
            bool _S846 = (&prev_0)->rough;
            if(_S846)
            {
                uint _S847 = insertBits_0(0U, b_3 + 1U, 5U, 5U);
                uint _S848 = insertBits_0(_S847, 3U, 10U, 2U);
                uint _S849 = insertBits_0(_S848, (&prev_0)->lobe, 15U, 3U);
                bool _S850 = (&prev_0)->inside;
                uint _S851 = _slang_select(_S850, 1U,0U);
                uint _S852 = insertBits_0(_S849, _S851, 22U, 1U);
                (&candidate_3)->path = _S852;
                (&candidate_3)->jac = (&prev_0)->pdf;
                (&candidate_3)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S853 = _S838 * make_float3 (_S836);
        Reservoir _S854 = withEnd(candidate_3, 3U, b_3, _S853);
        offer(sel_1, _S854, _S853 * make_float3 (scale_1) / make_float3 (density_2));
        return _S724;
    }
    float3  _S855 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S855;
    bool _S856 = (fcptVaryingUsed());
    if(_S856)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S857 = !replay_0;
        if(_S857)
        {
            float3  _S858 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S859 = sel_1->glow + _S858;
            sel_1->glow = _S859;
        }
        float3  _S860 = throughput_2 * weight_1;
        throughput_2 = _S860;
    }
    else
    {
        float3  _S861 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
        float3  _S862 = throughput_2 * _S861;
        throughput_2 = _S862;
    }
    float _S863 = width_2 + spread_0 * (&hit_1)->distance;
    uint _S864 = b_3 + 1U;
    b_3 = _S864;
    layer_0 = 0U;
    width_2 = _S863;
    passes_0 = false;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S723;
    float3  reconnection_0 = _S723;
    viewed_0 = _S832;
    for(;;)
    {
        bool _S865 = ((&hit_1)->is_point_light) == 1U;
        if(replay_0)
        {
            _S720 = _S728 == 1U;
        }
        else
        {
            _S720 = false;
        }
        if(_S720)
        {
            _S721 = b_3 == _S727;
        }
        else
        {
            _S721 = false;
        }
        bool _S866;
        if(_S721)
        {
            bool _S867 = ((&hit_1)->instance_index) != (_S740.instance_index);
            if(_S867)
            {
                _S866 = true;
            }
            else
            {
                _S866 = ((&hit_1)->triangle_index) != (_S740.triangle_index);
            }
        }
        else
        {
            _S866 = false;
        }
        if(_S866)
        {
            return _S724;
        }
        FKMedium _S868 = Medium_x24init_0(_S723, _S723, 0.0f);
        BSDFMaterial _S869 = Material_x24init_0(_S723, _S723, 0.0f, 0.0f, 0.0f, 0.0f, _S723, throughput_3, 1.0f, _S723, _S723, 0.5f, 0.0f, 0.0f, _S723);
        FKMedium _S870 = _S868;
        FKSurface _S871 = Surface_x24init_0(_S723, _S723, 0.0f, &_S869, false, 0U, 1.0f, false, &_S870, 4294967295U, _S723);
        bool _S872 = !_S865;
        bool scatter_2;
        bool is_inside_6;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S872)
        {
            uint _S873 = stream(_S751, b_3);
            uint _S874 = arrivalLobe_0(b_3, (&prev_0)->lobe);
            FKSurface _S875 = (fcptSurfaceAtPath((hit_1), ((&ray_2)->origin), (_S873), (width_2), (layer_0), (b_3), (_S874), ((&ray_2)->unit_direction)));
            bool _S876 = !passes_0;
            FKSurface _S877 = _S875;
            FKSurface _S878 = emitting_0(&_S877, _S876);
            uint _S879 = stream(_S751, b_3 + 256U);
            Random _S880 = pcg(_S879);
            FKSurface _S881 = _S878;
            FKSurface _S882 = uncovered_0(&_S881, _S880.value);
            float _S883 = facingSign(_S882.material.transmission, _S882.geometry_n, (&ray_2)->unit_direction);
            bool _S884 = _S883 < 0.0f;
            bool _S885 = (_S882.material.transmission) > 0.0f;
            if(_S885)
            {
                bool _S886 = arrivesBehind_0((&ray_2)->unit_direction, _S882.geometry_n);
                scatter_2 = _S886;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S887 = _S882;
            FKSurface _S888 = facingRay_0(&_S887, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S889 = arrivesBehind_0((&ray_2)->unit_direction, _S888.geometry_n);
                is_inside_6 = _S889;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S890 = beerLambert((&hit_1)->distance, _S888.material.absorption);
                float3  _S891 = throughput_2 * _S890;
                throughput_5 = _S891;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S892 = !_S888.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S888.geometry_n, (&ray_2)->unit_direction)))) / ((&hit_1)->distance * (&hit_1)->distance);
            bool _S893 = b_3 == _S864;
            if(_S893)
            {
                float _S894 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S894;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S895 = geometry_density_0;
            scatter_2 = _S892;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S895;
            surface_12 = _S888;
            turned_1 = _S884;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_12 = _S871;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S896;
        if(scatter_2)
        {
            _S896 = (&prev_0)->rough;
        }
        else
        {
            _S896 = false;
        }
        bool _S897;
        if(_S896)
        {
            _S897 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S897 = false;
        }
        FKSurface _S898 = surface_12;
        FKSurface _S899 = surface_12;
        float _S900 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        float2  _S901 = vertexEta(_S898.material, _S900);
        bool _S902;
        if(scatter_2)
        {
            bool _S903 = neeDecision(_S898.material, _S900, _S901.x, _S901.y);
            _S902 = _S903;
        }
        else
        {
            _S902 = false;
        }
        bool _S904;
        if(passes_0)
        {
            _S904 = true;
        }
        else
        {
            _S904 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S904)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S902;
        }
        bool _S905 = (fcptHairUsed());
        bool _S906;
        if(_S905)
        {
            float3  _S907 = surface_12.hair;
            _S906 = (dot_0(_S907, _S907)) > 0.0f;
        }
        else
        {
            _S906 = false;
        }
        bool _S908;
        if(_S906)
        {
            _S908 = true;
        }
        else
        {
            BSDFMaterial _S909 = _S898.material;
            bool _S910 = isTranslucent_0(&_S909);
            _S908 = _S910;
        }
        bool _S911;
        if(_S908)
        {
            _S911 = true;
        }
        else
        {
            bool _S912 = (_S898.material.transmission) > 0.0f;
            if(_S912)
            {
                uint _S913 = (fcptLayers((hit_1)));
                _S911 = _S913 == 1U;
            }
            else
            {
                _S911 = false;
            }
        }
        float3  emission_0;
        if(_S865)
        {
            float3  _S914 = (fcptCalculatePointLightContrib(((&hit_1)->instance_index)));
            emission_0 = _S914;
        }
        else
        {
            emission_0 = _S898.material.emissive;
        }
        bool _S915 = !replay_0;
        bool _S916;
        if(_S915)
        {
            _S916 = true;
        }
        else
        {
            _S916 = b_3 >= _S739;
        }
        bool _S917;
        if(_S916)
        {
            float _S918 = rgb_to_greyscale(emission_0);
            _S917 = _S918 > 0.0f;
        }
        else
        {
            _S917 = false;
        }
        float3  emission_1;
        if(_S917)
        {
            NEEVertex _S919 = nee_vertex_0;
            FKHit _S920 = hit_1;
            float _S921 = emissionWeight_0(&_S919, &_S920, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S921);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S922;
        if(replay_0)
        {
            _S922 = _S728 == 1U;
        }
        else
        {
            _S922 = false;
        }
        bool _S923;
        if(_S922)
        {
            _S923 = b_3 > _S727;
        }
        else
        {
            _S923 = false;
        }
        bool _S924;
        if(_S923)
        {
            _S924 = b_3 == _S726;
        }
        else
        {
            _S924 = false;
        }
        bool _S925;
        if(_S924)
        {
            bool _S926 = _S729 == 1U;
            if(_S926)
            {
                _S925 = true;
            }
            else
            {
                _S925 = _S729 == 2U;
            }
        }
        else
        {
            _S925 = false;
        }
        if(_S925)
        {
            bool _S927 = _S865 != (_S729 == 2U);
            if(_S927)
            {
                return _S724;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_1->jac), density_2 / r_1->jac);
        }
        uint _S928 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S929 = _S928 == 1U;
        Reservoir here_0 = chain_0;
        uint _S930 = insertBits_0(0U, b_3, 5U, 5U);
        uint _S931 = insertBits_0(_S930, 1U, 10U, 2U);
        uint _S932 = insertBits_0(_S931, (&prev_0)->lobe, 15U, 3U);
        bool _S933 = (&prev_0)->inside;
        uint _S934 = _slang_select(_S933, 1U,0U);
        uint _S935 = insertBits_0(_S932, _S934, 22U, 1U);
        (&here_0)->path = _S935;
        float _S936 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S936;
        fcptWithReservoirHit((&here_0), (&hit_1));
        bool _S937;
        if(replay_0)
        {
            _S937 = _S728 == 1U;
        }
        else
        {
            _S937 = false;
        }
        bool _S938;
        if(_S937)
        {
            _S938 = b_3 == _S727;
        }
        else
        {
            _S938 = false;
        }
        bool _S939 = b_3 == _S739;
        bool _S940;
        if(_S939)
        {
            bool _S941 = !scatter_2;
            if(_S941)
            {
                _S940 = true;
            }
            else
            {
                bool _S942 = _S728 != 1U;
                if(_S942)
                {
                    _S940 = _S728 != 3U;
                }
                else
                {
                    _S940 = false;
                }
            }
        }
        else
        {
            _S940 = false;
        }
        bool _S943;
        if(_S940)
        {
            _S943 = _S728 == 2U;
        }
        else
        {
            _S943 = false;
        }
        bool _S944;
        if(_S943)
        {
            _S944 = !_S897;
        }
        else
        {
            _S944 = false;
        }
        bool _S945;
        if(_S944)
        {
            _S945 = _S729 != 4U;
        }
        else
        {
            _S945 = false;
        }
        bool _S946 = _S727 == _S726;
        bool _S947;
        if(_S946)
        {
            _S947 = _S729 == 0U;
        }
        else
        {
            _S947 = false;
        }
        bool _S948;
        if(_S947)
        {
            _S948 = ((&hit_1)->instance_index) == (_S740.instance_index);
        }
        else
        {
            _S948 = false;
        }
        bool _S949;
        if(_S948)
        {
            _S949 = ((&hit_1)->triangle_index) == (_S740.triangle_index);
        }
        else
        {
            _S949 = false;
        }
        bool _S950;
        if(_S949)
        {
            _S950 = _S897;
        }
        else
        {
            _S950 = false;
        }
        bool _S951 = _slang_select(_S938, _S950,_S945);
        bool _S952;
        if(nee_0)
        {
            _S952 = _slang_select(replay_0, _S951,scatter_2);
        }
        else
        {
            _S952 = false;
        }
        TreeSample _S953 = TreeSample_x24init_0(_S723, _S723, 0.0f, 0U);
        float3  throughput_6;
        float3  lit_0;
        if(_S952)
        {
            float3  _S954 = (&ray_2)->origin;
            if(_S906)
            {
                throughput_6 = _S723;
            }
            else
            {
                throughput_6 = _S899.smooth_n;
            }
            FKSurface _S955 = surface_12;
            uint _S956 = stream(_S751, b_3 + 64U);
            uint _S957 = arrivalLobe_0(b_3, (&prev_0)->lobe);
            FKSurface _S958 = surface_12;
            FKHit _S959 = hit_1;
            ShadowContext _S960 = shadowContext_0(&_S958, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_3, _S957, (&hit_1)->distance, width_2, &_S959, _S906);
            ShadowContext _S961 = _S960;
            TreeSample _S962 = sampleLightTree_0(_S954, throughput_6, surface_12.geometry_n, surface_12.geometry_offset, _S911, _S956, &_S961);
            bool _S963 = any_0((_S962.radiance) != _S723);
            if(_S963)
            {
                if(_S906)
                {
                    uint _S964 = (fcptMaxBounces());
                    bool _S965 = b_3 < _S964;
                    FKSurface _S966 = surface_12;
                    TreeSample _S967 = _S962;
                    float3  _S968 = hairLight_0(&_S966, (&ray_2)->unit_direction, &_S967, _S965);
                    lit_0 = _S968;
                }
                else
                {
                    float _S969 = _S901.x;
                    float _S970 = _S901.y;
                    uint _S971 = (fcptMaxBounces());
                    bool _S972 = b_3 < _S971;
                    TreeSample _S973 = _S962;
                    BSDFMaterial _S974 = _S898.material;
                    float3  _S975 = lightBSDF_0((&ray_2)->unit_direction, &_S973, _S899.smooth_n, _S955.geometry_n, &_S974, _S969, _S970, _S972, surface_12.random_state);
                    lit_0 = _S975;
                }
            }
            else
            {
                lit_0 = _S723;
            }
            light_3 = _S962;
        }
        else
        {
            light_3 = _S953;
            lit_0 = _S723;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S976;
        bool _S977;
        float density_4;
        if(_S938)
        {
            bool _S978 = !_S897;
            if(_S978)
            {
                return _S724;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S946)
            {
                viewed_1 = _S729 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            if(_S946)
            {
                refracted_4 = _S729 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S979 = !nee_0;
                if(_S979)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S980 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S980 > 0.0f);
                }
                if(passes_0)
                {
                    return _S724;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            if(_S946)
            {
                wrong_side_0 = _S729 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S981 = !nee_0;
                if(_S981)
                {
                    return _S724;
                }
                float _S982 = environmentPdf_0(r_1->dir);
                float3  _S983 = skyBSDF((&ray_2)->unit_direction, r_1->dir, surface_12, _S901, is_inside_6, _S982, surface_12.random_state);
                return Shift_x24init_0(throughput_7 * _S983 * r_1->radiance / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            uint _S984 = extractBits_0(_S725, 21U, 1U);
            bool _S985 = nee_0 != (_S984 == 1U);
            if(_S985)
            {
                return _S724;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_0)
            {
                viewed_1 = _S939;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S986 = !scatter_2;
                if(_S986)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S987 = _S728 != 1U;
                    if(_S987)
                    {
                        refracted_4 = _S728 != 3U;
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
                bool _S988 = _S728 == 2U;
                if(_S988)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S897;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S729 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    uint _S989 = stream(_S751, b_3 + 448U);
                    FKRay _S990 = ray_2;
                    FKSurface _S991 = surface_12;
                    SkySample _S992 = sampleSky_0(&_S990, &_S991, _S901, is_inside_6, _S989, surface_12.random_state);
                    return Shift_x24init_0(throughput_5 * _S992.color, 1.0f);
                }
                if(_S988)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S897;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S993 = rgb_to_greyscale(light_3.radiance);
                    bool _S994 = !(_S993 > 0.0f);
                    if(_S994)
                    {
                        return _S724;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S738)
                {
                    passes_0 = _S729 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S865;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S738)
                {
                    passes_0 = _S729 == 1U;
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
                    passes_0 = !_S897;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S724;
            }
            else
            {
                if(_S915)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S995 = b_3 > 0U;
                    if(_S995)
                    {
                        Reservoir candidate_4 = chain_0;
                        if(_S929)
                        {
                            float3  _S996 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_4)->radiance = _S996;
                        }
                        else
                        {
                            if(_S897)
                            {
                                candidate_4 = here_0;
                            }
                        }
                        float3  _S997 = throughput_5 * emission_1;
                        Reservoir _S998 = withEnd(candidate_4, 1U, b_3, _S997);
                        offer(sel_1, _S998, _S997 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S999 = throughput_5 * emission_1;
                        float3  _S1000 = sel_1->glow + _S999;
                        sel_1->glow = _S1000;
                    }
                    if(nee_0)
                    {
                        float3  _S1001 = throughput_5 * lit_0;
                        Reservoir candidate_5 = chain_0;
                        if(_S929)
                        {
                            float3  _S1002 = safeDivide(_S1001, chain_throughput_0);
                            (&candidate_5)->radiance = _S1002;
                        }
                        else
                        {
                            if(_S897)
                            {
                                candidate_5 = here_0;
                                uint _S1003 = insertBits_0((&candidate_5)->path, 1U, 21U, 1U);
                                (&candidate_5)->path = _S1003;
                                (&candidate_5)->dir = light_3.dir;
                                (&candidate_5)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1004 = insertBits_0(0U, b_3 + 1U, 5U, 5U);
                                uint _S1005 = insertBits_0(_S1004, 2U, 10U, 2U);
                                (&candidate_5)->path = _S1005;
                            }
                        }
                        Reservoir _S1006 = withEnd(candidate_5, 0U, b_3, _S1001);
                        offer(sel_1, _S1006, _S1001 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S906)
                        {
                            _S976 = false;
                        }
                        else
                        {
                            bool _S1007 = environmentMapped_0();
                            _S976 = _S1007;
                        }
                    }
                    else
                    {
                        _S976 = false;
                    }
                    if(_S976)
                    {
                        uint _S1008 = (fcptMaxBounces());
                        _S977 = b_3 < _S1008;
                    }
                    else
                    {
                        _S977 = false;
                    }
                    if(_S977)
                    {
                        uint _S1009 = stream(_S751, b_3 + 448U);
                        FKRay _S1010 = ray_2;
                        FKSurface _S1011 = surface_12;
                        SkySample _S1012 = sampleSky_0(&_S1010, &_S1011, _S901, is_inside_6, _S1009, surface_12.random_state);
                        float3  _S1013 = throughput_5 * _S1012.color;
                        Reservoir candidate_6 = chain_0;
                        if(_S929)
                        {
                            float3  _S1014 = safeDivide(_S1013, chain_throughput_0);
                            (&candidate_6)->radiance = _S1014;
                        }
                        else
                        {
                            if(_S897)
                            {
                                candidate_6 = here_0;
                                uint _S1015 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1015;
                                (&candidate_6)->dir = _S1012.dir;
                                (&candidate_6)->radiance = _S1012.radiance;
                            }
                            else
                            {
                                uint _S1016 = insertBits_0(0U, b_3 + 1U, 5U, 5U);
                                uint _S1017 = insertBits_0(_S1016, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1017;
                            }
                        }
                        Reservoir _S1018 = withEnd(candidate_6, 4U, b_3, _S1013);
                        offer(sel_1, _S1018, _S1013 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1019;
        bool _S1020;
        bool straight_0;
        bool _S1021;
        bool _S1022;
        bool _S1023;
        bool _S1024;
        bool _S1025;
        bool _S1026;
        bool _S1027;
        bool _S1028;
        bool _S1029;
        bool _S1030;
        bool _S1031;
        bool _S1032;
        bool _S1033;
        bool _S1034;
        float density_6;
        float sky_pdf_2;
        float spread_3;
        uint b_6;
        float3  throughput_8;
        float3  throughput_9;
        float3  throughput_10;
        if(scatter_2)
        {
            if(replay_0)
            {
                viewed_1 = _S939;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1035 = extractBits_0(_S725, 15U, 3U);
            uint _S1036 = extractBits_0(_S725, 18U, 3U);
            uint _S1037 = _slang_select(_S938, _S1036,_S1035);
            float3  _S1038 = r_1->dir;
            bool refracted_5 = _S1037 == 1U;
            SampleBSDF _S1039 = SampleBSDF_x24init_0(_S723, _S723, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1039;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1040 = extractBits_0(_S725, 22U, 1U);
                bool _S1041 = is_inside_6 != (_S1040 == 1U);
                if(_S1041)
                {
                    return _S724;
                }
                bool _S1042 = _S728 == 1U;
                if(_S1042)
                {
                    float3  _S1043 = (fcptHitPosition((_S740)));
                    throughput_8 = _S1043;
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
                    BSDFMaterial _S1044 = _S898.material;
                    bool _S1045 = isTranslucent_0(&_S1044);
                    if(_S1045)
                    {
                        refracted_4 = _S1037 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1046 = throughput_8 - (&ray_2)->origin;
                        float3  _S1047 = _slang_select(_S1042, _S1046,_S1038);
                        wrong_side_0 = (dot_0(_S899.smooth_n, _S1047) * _S900) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1042)
                {
                    float3  _S1048 = (&ray_2)->origin;
                    FKSurface _S1049 = surface_12;
                    float3  _S1050 = - _S899.smooth_n;
                    bool _S1051 = is_inside_6 != refracted_4;
                    float3  _S1052 = _slang_select(_S1051, _S1050,_S899.smooth_n);
                    float3  _S1053 = throughput_8 - (_S1048 + make_float3 (_S1049.geometry_offset) * _S1052);
                    float3  _S1054 = ((((_S1053)) * make_float3(rnorm3df(((_S1053)).x, ((_S1053)).y, ((_S1053)).z))));
                    reconnection_1 = _S1054;
                }
                else
                {
                    reconnection_1 = _S1038;
                }
                if(_S906)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1055 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1055;
                }
                if(wrong_side_0)
                {
                    return _S724;
                }
                float3  _S1056 = throughput_8;
                throughput_8 = reconnection_1;
                b_6 = _S1037;
                wrong_side_0 = false;
                reconnection_1 = _S1056;
            }
            else
            {
                bool _S1057 = !_S938;
                if(_S1057)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1058;
                    if(_S906)
                    {
                        SampleBSDF _S1059 = (fcptSampleHair((surface_12.hair), (_S898.material.albedo), (_S898.material.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1058 = _S1059;
                    }
                    else
                    {
                        SampleBSDF _S1060 = sampleBSDF((&ray_2)->unit_direction, _S899.smooth_n, _S898.material, _S901.x, _S901.y, surface_12.random_state, make_float2 (0.0f));
                        _S1058 = _S1060;
                    }
                    bsdf_sampled_0 = _S1058;
                    if(_S906)
                    {
                        refracted_4 = !(((&bsdf_sampled_0)->pdf) > 0.0f);
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        if(replay_0)
                        {
                            return _S724;
                        }
                        break;
                    }
                    if(_S906)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1061 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1061;
                    }
                    if(wrong_side_0)
                    {
                        _S976 = (_S898.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S976 = false;
                    }
                    if(_S976)
                    {
                        SampleBSDF _S1062 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S898.material, _S901.x, _S901.y, (&bsdf_sampled_0)->random_state, make_float2 (0.0f));
                        (&bsdf_sampled_0)->unit_direction = _S1062.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1062.refracted;
                        (&bsdf_sampled_0)->throughput = _S1062.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1063 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1063;
                        }
                    }
                    uint _S1064 = (&bsdf_sampled_0)->lobe;
                    float3  _S1065 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1066 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1067 = (&bsdf_sampled_0)->pdf;
                    float _S1068 = _slang_select(wrong_side_0, 0.0f,_S1067);
                    (&lobe_5)->pdf = _S1068;
                    throughput_8 = _S1065;
                    b_6 = _S1064;
                    refracted_4 = _S1066;
                }
                else
                {
                    throughput_8 = _S1038;
                    b_6 = _S1037;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S976 = true;
            }
            else
            {
                _S976 = _S938;
            }
            float3  chain_throughput_1;
            if(_S976)
            {
                if(_S906)
                {
                    SampleBSDF _S1069 = (fcptConnectHair((surface_12.hair), (_S898.material.albedo), (_S898.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    lobe_5 = _S1069;
                }
                else
                {
                    float3  _S1070 = (&ray_2)->unit_direction;
                    float _S1071 = sign_0(_S900);
                    float3  _S1072 = _S899.smooth_n * make_float3 (_S1071);
                    float _S1073 = dot_0(_S1072, throughput_8);
                    float _S1074 = _S898.material.roughness;
                    float _S1075 = _S1074 * _S1074;
                    AnisotropicFrame _S1076 = anisotropicFrame(_S898.material, _S1072);
                    float3  _S1077 = negate_0(_S1070);
                    SheenProfile _S1078 = sheenProfile(_S1077, _S1072, _S898.material);
                    float3  _S1079 = reflectedHalf(_S1070, throughput_8);
                    bool _S1080 = b_6 == 1U;
                    if(_S1080)
                    {
                        float3  _S1081 = refractedHalf(_S1070, throughput_8, _S899.smooth_n, _S901.x, _S901.y);
                        throughput_9 = _S1081;
                    }
                    else
                    {
                        throughput_9 = _S1079;
                    }
                    bool _S1082 = b_6 == 0U;
                    if(_S1082)
                    {
                        float3  _S1083 = sampledHalf(_S1070, _S899.smooth_n, _S898.material, surface_12.random_state, _S1076);
                        throughput_10 = _S1083;
                    }
                    else
                    {
                        throughput_10 = throughput_9;
                    }
                    float3  _S1084 = negate_0(_S1070);
                    float _S1085 = _S901.x;
                    float _S1086 = _S901.y;
                    BSDFLobes _S1087 = bsdfLobes(_S1070, _S1084, _S1072, throughput_10, _S898.material, _S1085, _S1086, _S1076, _S1078);
                    BSDFLobes lobe_terms_1 = _S1087;
                    float _S1088 = translucentShare(_S898.material);
                    (&lobe_terms_1)->translucent_share = _S1088;
                    switch(b_6)
                    {
                    case 0U:
                        {
                            float _S1089 = diffusePDF(_S1073, 0.0f, (F32_abs((_S900))), _S1075, lobe_terms_1, _S1085, _S1086);
                            float3  _S1090 = diffuseBSDF(throughput_8, _S1072, _S1075, _S898.material, lobe_terms_1);
                            density_6 = _S1089;
                            chain_throughput_1 = _S1090;
                            break;
                        }
                    case 1U:
                        {
                            float _S1091 = refractPDF(_S1073, dot_0(throughput_8, throughput_10), (F32_abs((_S900))), _S1075, lobe_terms_1, _S1085, _S1086);
                            float3  _S1092 = refractBSDF(throughput_8, _S1072, _S1075, _S898.material, lobe_terms_1);
                            density_6 = _S1091;
                            chain_throughput_1 = _S1092;
                            break;
                        }
                    case 4U:
                        {
                            float _S1093 = sheenVelvetPDF(_S1073, 0.0f, (F32_abs((_S900))), _S1075, lobe_terms_1, _S1085, _S1086);
                            float3  _S1094 = sheenVelvetBSDF(throughput_8, _S1072, _S1075, _S898.material, lobe_terms_1);
                            density_6 = _S1093;
                            chain_throughput_1 = _S1094;
                            break;
                        }
                    default:
                        {
                            float _S1095 = reflectPDF(_S1073, 0.0f, (F32_abs((_S900))), _S1075, lobe_terms_1, _S1085, _S1086);
                            float3  _S1096 = reflectBSDF(throughput_8, _S1072, _S1075, _S898.material, lobe_terms_1);
                            density_6 = _S1095;
                            chain_throughput_1 = _S1096;
                            break;
                        }
                    }
                    bool _S1097 = density_6 > 0.0f;
                    if(_S1097)
                    {
                        SampleBSDF _S1098 = SampleBSDF_x24init_0(throughput_8, chain_throughput_1, surface_12.random_state, _S1080, b_6, density_6);
                        lobe_5 = _S1098;
                    }
                }
            }
            bool _S1099 = b_6 == 0U;
            if(_S1099)
            {
                _S977 = true;
            }
            else
            {
                _S977 = b_6 == 4U;
            }
            if(_S906)
            {
                _S1019 = false;
            }
            else
            {
                bool _S1100 = !_S977;
                if(_S1100)
                {
                    bool _S1101 = (_S898.material.roughness) == 0.0f;
                    if(_S1101)
                    {
                        _S1019 = true;
                    }
                    else
                    {
                        bool _S1102 = b_6 == 1U;
                        if(_S1102)
                        {
                            _S1019 = (_S901.x) == (_S901.y);
                        }
                        else
                        {
                            _S1019 = false;
                        }
                    }
                }
                else
                {
                    _S1019 = false;
                }
            }
            bool _S1103 = !_S906;
            if(_S1103)
            {
                _S1020 = b_6 == 1U;
            }
            else
            {
                _S1020 = false;
            }
            if(_S1020)
            {
                straight_0 = (_S898.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1021 = _S1103;
            }
            else
            {
                _S1021 = false;
            }
            if(_S1021)
            {
                _S1022 = b_6 == 1U;
            }
            else
            {
                _S1022 = false;
            }
            if(_S1022)
            {
                _S1023 = (_S901.x) == (_S901.y);
            }
            else
            {
                _S1023 = false;
            }
            BSDFMaterial _S1104 = _S898.material;
            bool _S1105 = isTranslucent_0(&_S1104);
            if(_S1105)
            {
                _S1024 = _S1099;
            }
            else
            {
                _S1024 = false;
            }
            if(_S1024)
            {
                _S1025 = (dot_0(throughput_8, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1025 = false;
            }
            if(nee_0)
            {
                _S1026 = !_S1019;
            }
            else
            {
                _S1026 = false;
            }
            if(_S1026)
            {
                _S1027 = !wrong_side_0;
            }
            else
            {
                _S1027 = false;
            }
            if(_S1027)
            {
                float _S1106 = (&lobe_5)->pdf;
                float3  _S1107 = (&ray_2)->origin;
                float3  _S1108 = _slang_select(_S911, _S723,_S899.smooth_n);
                float3  _S1109 = (&ray_2)->origin;
                FKSurface _S1110 = surface_12;
                float3  _S1111 = - _S899.smooth_n;
                float3  _S1112 = _slang_select(_S1025, _S1111,_S899.smooth_n);
                NEEVertex _S1113 = NEEVertex_x24init_0(false, _S1106, _S1107, _S1108, _S1109 + make_float3 (_S1110.geometry_offset) * _S1112);
                nee_vertex_0 = _S1113;
            }
            else
            {
                if(_S906)
                {
                    _S1028 = true;
                }
                else
                {
                    bool _S1114 = b_6 != 1U;
                    if(_S1114)
                    {
                        _S1028 = true;
                    }
                    else
                    {
                        _S1028 = (_S901.x) != (_S901.y);
                    }
                }
                if(_S1028)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1115 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1115)
            {
                if(_S977)
                {
                    _S1028 = true;
                }
                else
                {
                    _S1028 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_1)->distance * (&hit_1)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1028 = false;
            }
            bool _S1116 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1116)
            {
                if(_S977)
                {
                    _S1029 = true;
                }
                else
                {
                    _S1029 = (_S898.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1029 = false;
            }
            if(_S938)
            {
                bool _S1117 = !_S1028;
                if(_S1117)
                {
                    return _S724;
                }
                bool _S1118 = _S729 != 1U;
                if(_S1118)
                {
                    _S1030 = _S729 != 2U;
                }
                else
                {
                    _S1030 = false;
                }
                if(_S1030)
                {
                    float _S1119 = (&lobe_5)->pdf;
                    float _S1120 = _slang_select(nee_0, _S1119,0.0f);
                    float _S1121 = escapeWeight_0(_S1120, _S1038);
                    if(_S946)
                    {
                        passes_0 = _S735;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1122 = _slang_select(passes_0, _S1121,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_1->radiance * make_float3 (_S1122) / make_float3 (r_1->jac), density_4 * (&lobe_5)->pdf / r_1->jac);
                }
                float3  _S1123 = throughput_6 * make_float3 ((&lobe_5)->pdf);
                float _S1124 = density_4 * (&lobe_5)->pdf;
                throughput_9 = _S1123;
                density_6 = _S1124;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1125 = (fcptLayers((hit_1)));
            bool _S1126 = _S1125 > 1U;
            if(_S1126)
            {
                _S1030 = (b_6 == 1U) != passes_0;
            }
            else
            {
                _S1030 = false;
            }
            if(viewed_1)
            {
                _S1031 = _S1030;
            }
            else
            {
                _S1031 = false;
            }
            if(_S1031)
            {
                return _S724;
            }
            if(replay_0)
            {
                _S1032 = b_3 <= _S739;
            }
            else
            {
                _S1032 = false;
            }
            if(_S1032)
            {
                _S1033 = _S897;
            }
            else
            {
                _S1033 = false;
            }
            if(_S1033)
            {
                _S1034 = _S1028;
            }
            else
            {
                _S1034 = false;
            }
            bool _S1127;
            if(_S1034)
            {
                _S1127 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1127 = !_S1029;
                }
                else
                {
                    _S1127 = false;
                }
            }
            if(_S1127)
            {
                return _S724;
            }
            if(viewed_1)
            {
                float3  _S1128 = throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1129 = (&lobe_5)->pdf;
                throughput_10 = _S1128;
                sky_pdf_2 = _S1129;
            }
            else
            {
                float3  _S1130 = throughput_9 * max_0((&lobe_5)->throughput, _S723);
                throughput_10 = _S1130;
                sky_pdf_2 = density_6;
            }
            bool _S1131;
            if(_S915)
            {
                _S1131 = !_S929;
            }
            else
            {
                _S1131 = false;
            }
            bool _S1132;
            if(_S1131)
            {
                _S1132 = _S897;
            }
            else
            {
                _S1132 = false;
            }
            bool _S1133;
            if(_S1132)
            {
                _S1133 = _S1028;
            }
            else
            {
                _S1133 = false;
            }
            if(_S1133)
            {
                chain_0 = here_0;
                uint _S1134 = insertBits_0((&chain_0)->path, b_6, 18U, 3U);
                uint _S1135 = _slang_select(nee_0, 1U,0U);
                uint _S1136 = insertBits_0(_S1134, _S1135, 21U, 1U);
                (&chain_0)->path = _S1136;
                float _S1137 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1137;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1138 = surface_12;
            Vertex _S1139 = Vertex_x24init_0(_S1029, b_6, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1139;
            float _S1140 = (&lobe_5)->pdf;
            bool _S1141 = b_6 == 1U;
            bool _S1142;
            if(_S1141)
            {
                _S1142 = (_S901.x) == (_S901.y);
            }
            else
            {
                _S1142 = false;
            }
            float sky_pdf_3 = _slang_select(_S1142, sky_pdf_0,_S1140);
            float _S1143 = _slang_select(_S906, 0.0f,sky_pdf_3);
            float _S1144 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1145 = !_S1019;
            float _S1146 = _slang_select(_S1145, _S1144,0.0f);
            float _S1147 = spread_0 + _S1146;
            bool _S1148;
            if(refracted_4)
            {
                _S1148 = !_S1025;
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
            FKSurface _S1150 = surface_12;
            bool _S1151 = boundsVolume_0(&_S1150);
            bool _S1152;
            if(_S1151)
            {
                _S1152 = !_S1030;
            }
            else
            {
                _S1152 = false;
            }
            if(_S1152)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1153 = - _S1138.geometry_n;
                float3  _S1154 = _slang_select(turned_1, _S1153,_S1138.geometry_n);
                (&faced_2)->geometry_n = _S1154;
                FKMedium _S1155 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKSurface _S1156 = faced_2;
                FKMedium _S1157 = _S1155;
                MediumSides _S1158 = mediumSides_0(&_S1156, &_S1157, filling_2, (&ray_2)->unit_direction);
                bool _S1159 = ((dot_0(throughput_8, _S1138.geometry_n)) > 0.0f) == ((dot_0(_S1138.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1160 = _slang_select(_S1159, _S1158.front.scatter,_S1158.behind.scatter);
                scatter_in_0 = _S1160;
                float3  _S1161 = _slang_select(_S1159, _S1158.front.extinction,_S1158.behind.extinction);
                extinction_in_0 = _S1161;
                float _S1162 = _slang_select(_S1159, _S1158.front.g,_S1158.behind.g);
                g_in_0 = _S1162;
                uint _S1163 = _S1158.fillings.x;
                uint _S1164 = _S1158.fillings.y;
                uint _S1165 = _slang_select(_S1159, _S1164,_S1163);
                bool _S1166 = (fcptVaryingUsed());
                uint _S1167 = _slang_select(_S1166, _S1165,4294967295U);
                filling_2 = _S1167;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1168 = !_S1030;
            if(_S1168)
            {
                FKSurface _S1169 = surface_12;
                float _S1170 = _slang_select(straight_0, 0.0f,_S1169.geometry_offset);
                float3  _S1171 = - _S899.smooth_n;
                bool _S1172 = is_inside_7 != _S1025;
                float3  _S1173 = _slang_select(_S1172, _S1171,_S899.smooth_n);
                float3  _S1174 = (&ray_2)->origin + make_float3 (_S1170) * _S1173;
                (&ray_2)->origin = _S1174;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1030;
            viewed_1 = _S1023;
            sky_pdf_2 = _S1143;
            spread_3 = _S1147;
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
            spread_3 = spread_0;
            straight_0 = false;
            is_inside_5 = is_inside_6;
        }
        float density_7;
        if(_S915)
        {
            if(_S865)
            {
                float3  _S1175 = throughput_9 * emission_1;
                Reservoir candidate_7 = chain_0;
                uint _S1176 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1177 = _S1176 == 1U;
                if(_S1177)
                {
                    float3  _S1178 = safeDivide(_S1175, chain_throughput_0);
                    (&candidate_7)->radiance = _S1178;
                }
                Reservoir _S1179 = withEnd(candidate_7, 2U, b_3, _S1175);
                offer(sel_1, _S1179, _S1175 * make_float3 (scale_1) / make_float3 (density_6));
            }
            if(_S865)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1180 = survivalProbability(throughput_9, density_6);
                density_7 = _S1180;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1181 = stream(_S751, b_3 + 128U);
            Random _S1182 = pcg(_S1181);
            bool _S1183 = density_7 < (_S1182.value);
            if(_S1183)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1184 = (fcptMaxBounces());
                wrong_side_0 = b_3 >= _S1184;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1185 = density_6 * density_7;
            density_7 = _S1185;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1186 = layer_0 ^ 1U;
        uint _S1187 = _slang_select(passes_0, _S1186,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_1)->distance = 0.0f;
            b_6 = b_3;
            viewed_0 = viewed_1;
            throughput_2 = throughput_9;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_0 = spread_3;
            uint _S1188 = b_6 + 1U;
            b_3 = _S1188;
            layer_0 = _S1187;
            continue;
        }
        FKRay _S1189 = ray_2;
        float _S1190 = distance_3(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_0)
        {
            refracted_4 = _S939;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S728 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1191 = _slang_select(wrong_side_0, _S1190,4.294967296e+09f);
        bool _S1192 = !_S906;
        if(straight_0)
        {
            _S976 = true;
        }
        else
        {
            _S976 = _S906;
        }
        FKHit _S1193;
        if(_S976)
        {
            _S1193 = hit_1;
        }
        else
        {
            _S1193 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
        }
        FKHit _S1194 = (fcptTraverseInstanceBVH((_S1189), (_S872), (_S1191), (_S1192), (_S1193), (viewed_1)));
        hit_1 = _S1194;
        if(replay_0)
        {
            _S977 = _S939;
        }
        else
        {
            _S977 = false;
        }
        if(_S977)
        {
            _S1019 = _S728 == 1U;
        }
        else
        {
            _S1019 = false;
        }
        if(_S1019)
        {
            _S1020 = ((&hit_1)->instance_index) == (_S740.instance_index);
        }
        else
        {
            _S1020 = false;
        }
        if(_S1020)
        {
            _S1021 = ((&hit_1)->triangle_index) == (_S740.triangle_index);
        }
        else
        {
            _S1021 = false;
        }
        if(_S1021)
        {
            (&hit_1)->uv = _S740.uv;
            float _S1195 = distance_3(reconnection_0, (&ray_2)->origin);
            (&hit_1)->distance = _S1195;
        }
        if(replay_0)
        {
            _S1022 = _S939;
        }
        else
        {
            _S1022 = false;
        }
        if(_S1022)
        {
            _S1023 = _S728 == 3U;
        }
        else
        {
            _S1023 = false;
        }
        if(_S1023)
        {
            _S1024 = ((&hit_1)->instance_index) != 4294967295U;
        }
        else
        {
            _S1024 = false;
        }
        if(_S1024)
        {
            return _S724;
        }
        Reservoir _S1196 = chain_0;
        uint _S1197 = filling_2;
        for(;;)
        {
            bool _S1198 = (fcptVaryingUsed());
            if(_S1198)
            {
                _S1025 = _S1197 != 4294967295U;
            }
            else
            {
                _S1025 = false;
            }
            float _S1199;
            if(_S1025)
            {
                float _S1200 = (fcptMajorant((_S1197)));
                _S1199 = _S1200;
            }
            else
            {
                _S1199 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_0)
            {
                _S1026 = _S939;
            }
            else
            {
                _S1026 = false;
            }
            if(_S1026)
            {
                _S1027 = _S728 == 1U;
            }
            else
            {
                _S1027 = false;
            }
            if(_S1027)
            {
                _S1028 = _S1199 > 0.0f;
            }
            else
            {
                _S1028 = false;
            }
            if(_S1028)
            {
                ended_0 = _S724;
                sky_pdf_1 = sky_pdf_2;
                spread_1 = spread_3;
                width_3 = width_2;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_6 = b_3;
                _S1029 = true;
                break;
            }
            bool _S1201 = (&prev_0)->rough;
            if(_S1201)
            {
                _S1029 = !(_S1199 > 0.0f);
            }
            else
            {
                _S1029 = false;
            }
            (&prev_0)->rough = _S1029;
            uint _S1202 = b_3 + 320U;
            bool _S1203 = b_3 == 4294967295U;
            uint _S1204 = _slang_select(_S1203, 384U,_S1202);
            uint _S1205 = stream(_S751, _S1204);
            uint tracking_1 = _S1205;
            weight_1 = throughput_3;
            glowed_0 = _S723;
            b_6 = b_3;
            throughput_10 = throughput_9;
            density_3 = density_7;
            spread_1 = spread_3;
            width_3 = width_2;
            sky_pdf_1 = sky_pdf_2;
            for(;;)
            {
                if(((&hit_1)->instance_index) != 4294967295U)
                {
                }
                else
                {
                    _S722 = int(2);
                    break;
                }
                uint _S1206 = b_6 + 320U;
                bool _S1207 = b_6 == 4294967295U;
                uint _S1208 = _slang_select(_S1207, 384U,_S1206);
                uint _S1209 = stream(_S751, _S1208);
                Random _S1210 = pcg(_S1209);
                float _S1211 = - (F32_log((1.0f - _S1210.value))) / _S1199;
                if(_S1025)
                {
                    float3  _S1212 = (&ray_2)->origin;
                    float3  _S1213 = (&ray_2)->unit_direction;
                    float _S1214 = (&hit_1)->distance;
                    uint _S1215 = _slang_select(_S1207, 0U,b_6);
                    uint _S1216 = (&prev_0)->lobe;
                    uint _S1217 = _slang_select(_S1207, 3U,_S1216);
                    float _S1218 = (fcptTrackMedium((_S1197), (_S1212), (_S1213), (_S1214), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1215), (_S1217), (_S1207)));
                    spread_2 = _S1218;
                }
                else
                {
                    spread_2 = _S1211;
                }
                bool _S1219 = !(spread_2 < ((&hit_1)->distance));
                if(_S1219)
                {
                    _S722 = int(2);
                    break;
                }
                if(_S1025)
                {
                    _S1030 = _S915;
                }
                else
                {
                    _S1030 = false;
                }
                if(_S1030)
                {
                    float3  _S1220 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1221 = sel_1->glow + _S1220;
                    sel_1->glow = _S1221;
                }
                else
                {
                }
                glowed_0 = _S723;
                uint b_7 = b_6 + 1U;
                float3  _S1222 = (&ray_2)->origin + make_float3 (spread_2) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1222;
                float3  _S1223 = flightWeight_0(scatter_in_0, extinction_in_0, _S1199, spread_2, true);
                float3  _S1224 = weight_1;
                float3  _S1225 = _slang_select(_S1025, _S1224,_S1223);
                float3  throughput_11 = throughput_10 * _S1225;
                uint _S1226 = stream(_S751, b_7 + 320U);
                tracking_1 = _S1226;
                weight_1 = throughput_3;
                float width_6 = width_3 + spread_1 * spread_2;
                float _S1227 = spread_1 + 3.14159274101257324f;
                if(_S915)
                {
                    _S1031 = true;
                }
                else
                {
                    bool _S1228 = b_7 == _S739;
                    if(_S1228)
                    {
                        _S1031 = !_S1025;
                    }
                    else
                    {
                        _S1031 = false;
                    }
                }
                TreeSample light_4;
                if(_S1031)
                {
                    float3  _S1229 = (&ray_2)->origin;
                    float3  _S1230 = (&ray_2)->unit_direction;
                    float3  _S1231 = (&ray_2)->unit_direction;
                    uint _S1232 = stream(_S751, b_7 + 64U);
                    float3  _S1233 = extinction_in_0;
                    float3  _S1234 = extinction_in_0;
                    uint2  _S1235 = make_uint2 (_S1197);
                    float3  _S1236 = (&ray_2)->unit_direction;
                    uint _S1237 = arrivalLobe_0(b_7, (&prev_0)->lobe);
                    FKHit _S1238 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                    FKHit _S1239 = _S1238;
                    ShadowContext _S1240 = ShadowContext_x24init_0(_S1233, _S1234, _S1235, _S1236, b_7, _S1237, false, spread_2, width_6, &_S1239, false);
                    ShadowContext _S1241 = _S1240;
                    TreeSample _S1242 = sampleLightTree_0(_S1229, _S1230, _S1231, 0.0f, true, _S1232, &_S1241);
                    light_4 = _S1242;
                }
                else
                {
                    light_4 = _S953;
                }
                float _S1243 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1244 = (fcptMaxBounces());
                bool _S1245 = b_7 < _S1244;
                if(_S1245)
                {
                    _S1032 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1032 = false;
                }
                float _S1246 = _slang_select(_S1032, _S1243,0.0f);
                float3  _S1247 = throughput_11 * light_4.radiance;
                float _S1248 = powerHeuristic(light_4.density, _S1246);
                float3  _S1249 = _S1247 * make_float3 (_S1243 * _S1248);
                float3  _S1250 = _slang_select(_S1031, _S1249,_S723);
                if(replay_0)
                {
                    _S1033 = b_7 == _S739;
                }
                else
                {
                    _S1033 = false;
                }
                if(_S1033)
                {
                    bool _S1251 = _S728 == 2U;
                    if(_S1251)
                    {
                        float _S1252 = rgb_to_greyscale(_S1250);
                        _S1034 = _S1252 > 0.0f;
                    }
                    else
                    {
                        _S1034 = false;
                    }
                    if(_S1034)
                    {
                        Shift _S1253 = Shift_x24init_0(_S1250, 1.0f);
                        _S722 = int(1);
                        ended_0 = _S1253;
                        spread_2 = _S1227;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_4 = b_7;
                        break;
                    }
                    _S722 = int(1);
                    ended_0 = _S724;
                    spread_2 = _S1227;
                    width_4 = width_6;
                    throughput_8 = throughput_11;
                    b_4 = b_7;
                    break;
                }
                if(_S915)
                {
                    Reservoir candidate_8 = _S1196;
                    uint _S1254 = extractBits_0(_S1196.path, 10U, 2U);
                    bool _S1255 = _S1254 == 1U;
                    if(_S1255)
                    {
                        float3  _S1256 = safeDivide(_S1250, chain_throughput_0);
                        (&candidate_8)->radiance = _S1256;
                    }
                    else
                    {
                        uint _S1257 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                        uint _S1258 = insertBits_0(_S1257, 2U, 10U, 2U);
                        (&candidate_8)->path = _S1258;
                    }
                    Reservoir _S1259 = withEnd(candidate_8, 0U, b_7, _S1250);
                    offer(sel_1, _S1259, _S1250 * make_float3 (scale_1) / make_float3 (density_3));
                    float _S1260 = survivalProbability(throughput_11, density_3);
                    uint _S1261 = stream(_S751, b_7 + 128U);
                    Random _S1262 = pcg(_S1261);
                    bool _S1263 = _S1260 < (_S1262.value);
                    if(_S1263)
                    {
                        _S1034 = true;
                    }
                    else
                    {
                        uint _S1264 = (fcptMaxBounces());
                        _S1034 = b_7 >= _S1264;
                    }
                    if(_S1034)
                    {
                        _S722 = int(1);
                        ended_0 = _S724;
                        spread_2 = _S1227;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_4 = b_7;
                        break;
                    }
                    float _S1265 = density_3 * _S1260;
                    density_3 = _S1265;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1266 = stream(_S751, b_7);
                float3  _S1267 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1266, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1267;
                NEEVertex _S1268 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S723, (&ray_2)->origin);
                nee_vertex_0 = _S1268;
                Vertex _S1269 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
                prev_0 = _S1269;
                float _S1270 = (&prev_0)->pdf;
                FKRay _S1271 = ray_2;
                FKHit _S1272 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1273 = (fcptTraverseInstanceBVH((_S1271), (true), (4.294967296e+09f), (false), (_S1272), (false)));
                hit_1 = _S1273;
                b_6 = b_7;
                throughput_10 = throughput_11;
                spread_1 = _S1227;
                width_3 = width_6;
                sky_pdf_1 = _S1270;
            }
            if(_S722 != int(2))
            {
                spread_1 = spread_2;
                width_3 = width_4;
                throughput_10 = throughput_8;
                b_6 = b_4;
                _S1029 = true;
                break;
            }
            ended_0 = _S724;
            _S1029 = false;
            break;
        }
        if(_S1029)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1030 = b_6 == b_3;
        }
        else
        {
            _S1030 = false;
        }
        bool _S1274 = ((&hit_1)->instance_index) == 4294967295U;
        if(_S1274)
        {
            bool _S1275 = !(&nee_vertex_0)->none;
            float _S1276 = _slang_select(_S1275, sky_pdf_1,0.0f);
            float _S1277 = escapeWeight_0(_S1276, (&ray_2)->unit_direction);
            float3  _S1278 = environment_0((&ray_2)->unit_direction, b_6, (&prev_0)->lobe);
            float3  _S1279 = throughput_10 * _S1278;
            if(replay_0)
            {
                bool _S1280 = b_6 == _S739;
                if(_S1280)
                {
                    passes_0 = _S728 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1279 * make_float3 (_S1277) / make_float3 (r_1->jac), density_3 / r_1->jac);
                }
                if(_S738)
                {
                    passes_0 = _S735;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_6 == _S726;
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
                    return Shift_x24init_0(_S1279 * make_float3 (_S1277), 1.0f);
                }
                return _S724;
            }
            Reservoir candidate_9 = chain_0;
            uint _S1281 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1282 = _S1281 == 1U;
            if(_S1282)
            {
                uint _S1283 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1284 = _S1283 == b_6;
                float _S1285 = _slang_select(_S1284, 1.0f,_S1277);
                float3  _S1286 = safeDivide(_S1279 * make_float3 (_S1285), chain_throughput_0);
                (&candidate_9)->radiance = _S1286;
            }
            else
            {
                bool _S1287 = (&prev_0)->rough;
                if(_S1287)
                {
                    uint _S1288 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                    uint _S1289 = insertBits_0(_S1288, 3U, 10U, 2U);
                    uint _S1290 = insertBits_0(_S1289, (&prev_0)->lobe, 15U, 3U);
                    bool _S1291 = (&prev_0)->inside;
                    uint _S1292 = _slang_select(_S1291, 1U,0U);
                    uint _S1293 = insertBits_0(_S1290, _S1292, 22U, 1U);
                    (&candidate_9)->path = _S1293;
                    (&candidate_9)->jac = (&prev_0)->pdf;
                    (&candidate_9)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1294 = _S1279 * make_float3 (_S1277);
            Reservoir _S1295 = withEnd(candidate_9, 3U, b_6, _S1294);
            offer(sel_1, _S1295, _S1294 * make_float3 (scale_1) / make_float3 (density_3));
            break;
        }
        float3  _S1296 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1296;
        bool _S1297 = (fcptVaryingUsed());
        if(_S1297)
        {
            _S1031 = filling_2 != 4294967295U;
        }
        else
        {
            _S1031 = false;
        }
        if(_S1031)
        {
            if(_S915)
            {
                float3  _S1298 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1299 = sel_1->glow + _S1298;
                sel_1->glow = _S1299;
            }
            float3  _S1300 = throughput_10 * weight_1;
            throughput_8 = _S1300;
        }
        else
        {
            float3  _S1301 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
            float3  _S1302 = throughput_10 * _S1301;
            throughput_8 = _S1302;
        }
        float _S1303 = width_3 + spread_1 * (&hit_1)->distance;
        viewed_0 = _S1030;
        width_2 = _S1303;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_0 = spread_1;
        uint _S1188 = b_6 + 1U;
        b_3 = _S1188;
        layer_0 = _S1187;
    }
    return _S724;
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

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_12)
{
    float3  _S1314 = p1_0 - p0_0;
    float3  _S1315 = p2_0 - p0_0;
    float2  _S1316 = uv1_0 - uv0_0;
    float2  _S1317 = uv2_0 - uv0_0;
    float _S1318 = _S1316.x;
    float _S1319 = _S1317.y;
    float _S1320 = _S1316.y;
    float _S1321 = _S1317.x;
    float _S1322 = _S1318 * _S1319 - _S1320 * _S1321;
    float _S1323 = 1.0f / _S1322;
    float3  t_1 = (_S1314 * make_float3 (_S1319) - _S1315 * make_float3 (_S1320)) * make_float3 (_S1323);
    float3  _S1324 = (_S1315 * make_float3 (_S1318) - _S1314 * make_float3 (_S1321)) * make_float3 (_S1323);
    float3  _S1325 = t_1 - n_12 * make_float3 (dot_0(n_12, t_1));
    float3  t_2 = ((((_S1325)) * make_float3(rnorm3df(((_S1325)).x, ((_S1325)).y, ((_S1325)).z))));
    bool _S1326 = (dot_0(cross_0(n_12, t_2), _S1324)) > 0.0f;
    float3  t_3;
    if(_S1326)
    {
        float3  _S1327 = negate_0(t_2);
        t_3 = _S1327;
    }
    else
    {
        t_3 = t_2;
    }
    float3  _S1328 = cross_0(n_12, t_3);
    return makeMatrix<float, 3, 3> (t_3, _S1328, n_12);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_0)
{
    float3  _S1329 = t1_0 - t0_0;
    float3  _S1330 = t2_2 - t0_0;
    float3  _S1331 = t2_2 - t1_0;
    float _S1332 = (F32_min((length_0(_S1329)), ((F32_min((length_0(_S1330)), (length_0(_S1331)))))));
    float3  _S1333 = make_float3 (distance_3(position_0, t0_0), distance_3(position_0, t1_0), distance_3(position_0, t2_2));
    float3  _S1334 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1335 = dot_0(geometry_n_4, _S1334);
    float3  _S1336 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1337 = dot_0(geometry_n_4, _S1336);
    float3  _S1338 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1339 = acos_0(abs_0(make_float3 (_S1335, _S1337, dot_0(geometry_n_4, _S1338))));
    float3  _S1340 = clamp_1(tan_0(_S1339), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_0(dot_0(_S1333 * _S1340, uvw_0), 0.0f, _S1332 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_14, float3  n_13, BSDFMaterial material_21)
{
    float3  _S1341 = negate_0(dir_14);
    float _S1342 = sign_0(dot_0(n_13, _S1341));
    float3  _S1343 = n_13 * make_float3 (_S1342);
    AnisotropicFrame _S1344 = anisotropicFrame(material_21, _S1343);
    bool _S1345 = (_S1344.alphas.x) > 0.0f;
    if(_S1345)
    {
        float _S1346 = material_21.transmission * (1.0f - material_21.metallic);
        float3  _S1347 = negate_0(_S1343);
        float3  _S1348 = anisotropicLocal(dir_14, _S1344.tangent, _S1347);
        float _S1349 = anisotropicG1(_S1348, _S1344.alphas);
        return make_float3 (_S1346 * _S1349) * material_21.albedo;
    }
    float _S1350 = material_21.transmission * (1.0f - material_21.metallic);
    float _S1351 = material_21.roughness;
    float _S1352 = smithG1(_S1351 * _S1351, (F32_abs((dot_0(n_13, dir_14)))));
    return make_float3 (_S1350 * _S1352) * material_21.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_4, float3  out_dir_3, uint p_5, float w_2, float alpha_17, uint nt_0)
{
    uint _S1353 = p_5 % 4U;
    float _S1354 = w_2 * HAIR_WIDTHS_0[_S1353];
    float _S1355 = (F32_asin((clamp_0(dot_0(out_dir_3, t_4), -1.0f, 1.0f)))) - (F32_asin((clamp_0(dot_0(in_dir_11, t_4), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1353] * alpha_17;
    return ((F32_asinh((_S1355 / _S1354))) / (F32_asinh((3.14159274101257324f / _S1354))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_5, float3  out_dir_4, uint np_0)
{
    float3  _S1356 = worldToTangent(out_dir_4, t_5);
    float3  _S1357 = worldToTangent(in_dir_12, t_5);
    return (F32_frac((((F32_atan2((_S1356.z), (_S1356.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1357.z), (1.17549435082228751e-38f - _S1357.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_6, uint p_6, float row_0, float column_0, float w_3, float alpha_18, uint nt_1, uint np_1)
{
    float3  _S1358 = worldToTangent(in_dir_13, t_6);
    uint _S1359 = p_6 % 4U;
    float _S1360 = w_3 * HAIR_WIDTHS_0[_S1359];
    float _S1361 = (F32_asin((clamp_0(dot_0(in_dir_13, t_6), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1359] * alpha_18 + _S1360 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1360))))));
    float _S1362 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1358.z), (1.17549435082228751e-38f - _S1358.x)));
    float _S1363 = (F32_cos((_S1361)));
    float3  _S1364 = tangentToWorld(make_float3 (_S1363 * (F32_cos((_S1362))), (F32_sin((_S1361))), _S1363 * (F32_sin((_S1362)))), t_6);
    return _S1364;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_14, BSDFMaterial material_22, float coverage_1)
{
    float3  _S1365;
    if((material_22.ior) == 1.0f)
    {
        float3  _S1366 = straightThrough(toward_1, n_14, material_22);
        _S1365 = _S1366;
    }
    else
    {
        _S1365 = make_float3 (0.0f);
    }
    return _S1365 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ void offerShifted(Selection * sel_2, Reservoir r_2, Shift shifted_0, float mis_0)
{
    Reservoir candidate_10 = r_2;
    float3  _S1367 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_10)->f = _S1367;
    float _S1368 = r_2.jac * shifted_0.jac;
    (&candidate_10)->jac = _S1368;
    offer(sel_2, candidate_10, make_float3 (mis_0) * shifted_0.f * make_float3 (r_2.w));
    return;
}

__device__ Reservoir finalize(Selection sel_3, float c_1)
{
    Reservoir r_3 = sel_3.r;
    float _S1369 = rgb_to_greyscale((&r_3)->f);
    float _S1370 = sel_3.w_sum / _S1369;
    bool _S1371 = _S1369 > 0.0f;
    float _S1372 = _slang_select(_S1371, _S1370,0.0f);
    (&r_3)->w = _S1372;
    (&r_3)->c = c_1;
    return r_3;
}

__device__ Shift walk_hook(Domain dom_1, Reservoir r_4, bool replay_1, float scale_2, Selection * sel_4)
{
    Domain _S1373 = dom_1;
    Reservoir _S1374 = r_4;
    Shift _S1375 = walk_0(&_S1373, &_S1374, replay_1, scale_2, sel_4);
    return _S1375;
}

#undef Matrix
