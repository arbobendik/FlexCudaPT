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

__device__ float3  safeDivide(float3  a_5, float3  b_2)
{
    float3  _S567 = a_5 / b_2;
    float3  _S568 = make_float3 (0.0f);
    bool3  _S569 = b_2 == _S568;
    float3  _S570 = _slang_select(_S569, _S568,_S567);
    return _S570;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S571 = (1U << count_2) - 1U;
    return (e_2 & (~(_S571 << offset_1))) | ((newbits_0 & _S571) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_0, uint end_type_0, uint end_0, float3  f_4)
{
    Reservoir candidate_0 = r_0;
    uint _S572 = insertBits_0(r_0.path, end_0, 0U, 5U);
    uint _S573 = insertBits_0(_S572, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S573;
    (&candidate_0)->f = f_4;
    return candidate_0;
}

__device__ void offer(Selection * sel_0, Reservoir candidate_1, float3  weight_0)
{
    float _S574 = rgb_to_greyscale(weight_0);
    bool _S575 = _S574 > 0.0f;
    bool _S576;
    if(_S575)
    {
        _S576 = _S574 < 3.00000000549775576e+38f;
    }
    else
    {
        _S576 = false;
    }
    bool _S577 = !_S576;
    if(_S577)
    {
        return;
    }
    bool _S578 = sel_0->sums;
    if(_S578)
    {
        float3  _S579 = sel_0->color + weight_0;
        sel_0->color = _S579;
        return;
    }
    float _S580 = sel_0->w_sum + _S574;
    sel_0->w_sum = _S580;
    float3  _S581 = sel_0->color + weight_0;
    sel_0->color = _S581;
    Random _S582 = pcg(sel_0->random_state);
    sel_0->random_state = _S582.state;
    bool _S583 = (_S582.value * sel_0->w_sum) <= _S574;
    if(_S583)
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
    Random _S584 = pcg(random_state_8);
    Random _S585 = pcg(_S584.state);
    float _S586 = 1.0f - 2.0f * _S584.value;
    float _S587 = (F32_sqrt(((F32_max((1.0f - _S586 * _S586), (0.0f))))));
    float _S588 = 6.28318548202514648f * _S585.value;
    return make_float3 (_S587 * (F32_cos((_S588))), _S587 * (F32_sin((_S588))), _S586);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2)
{
    BSDFMaterial _S589;
    (&_S589)->albedo = albedo_1;
    (&_S589)->emissive = emissive_0;
    (&_S589)->roughness = roughness_0;
    (&_S589)->metallic = metallic_0;
    (&_S589)->transmission = transmission_0;
    (&_S589)->ior = ior_0;
    (&_S589)->absorption = absorption_0;
    (&_S589)->specular_tint = specular_tint_0;
    (&_S589)->specular_level = specular_level_0;
    (&_S589)->translucent = translucent_0;
    (&_S589)->sheen = sheen_2;
    (&_S589)->sheen_roughness = sheen_roughness_0;
    (&_S589)->anisotropy = anisotropy_0;
    (&_S589)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S589)->tangent = tangent_2;
    return _S589;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1)
{
    FKMedium _S590;
    (&_S590)->scatter = scatter_1;
    (&_S590)->extinction = extinction_1;
    return _S590;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_10, bool skip_0, uint random_state_9, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S591;
    (&_S591)->smooth_n = smooth_n_4;
    (&_S591)->geometry_n = geometry_n_2;
    (&_S591)->geometry_offset = geometry_offset_2;
    (&_S591)->material = *material_10;
    (&_S591)->skip = skip_0;
    (&_S591)->random_state = random_state_9;
    (&_S591)->coverage = coverage_0;
    (&_S591)->encloses = encloses_0;
    (&_S591)->volume = *volume_0;
    (&_S591)->fills = fills_0;
    (&_S591)->hair = hair_0;
    return _S591;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S592 = (&surface_6->material)->emissive;
    float3  _S593 = make_float3 (0.0f);
    bool _S594 = !top_0;
    float3  _S595 = _slang_select(_S594, _S593,_S592);
    (&(&lower_0)->material)->emissive = _S595;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_1)
{
    float _S596 = surface_7->coverage;
    bool _S597 = u_1 < _S596;
    if(_S597)
    {
        return *surface_7;
    }
    float3  _S598 = make_float3 (0.0f);
    float3  _S599 = make_float3 (1.0f);
    BSDFMaterial _S600 = Material_x24init_0(_S598, _S598, 0.0f, 0.0f, 0.0f, 0.0f, _S598, _S599, 1.0f, _S598, _S598, 0.5f, 0.0f, 0.0f, _S598);
    BSDFMaterial material_11 = _S600;
    (&material_11)->albedo = _S599;
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
    bool _S601 = transmission_1 > 0.0f;
    bool _S602;
    if(_S601)
    {
        _S602 = true;
    }
    else
    {
        _S602 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S603;
    if(_S602)
    {
        _S603 = 1.0f;
    }
    else
    {
        _S603 = -1.0f;
    }
    return _S603;
}

static __device__ bool arrivesBehind_0(float3  dir_9, float3  n_9)
{
    return (dot_0(dir_9, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_10)
{
    float3  _S604 = surface_8->geometry_n;
    float _S605 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_10);
    FKSurface faced_0 = *surface_8;
    float3  _S606 = surface_8->smooth_n * make_float3 (_S605);
    (&faced_0)->smooth_n = _S606;
    float3  _S607 = _S604 * make_float3 (_S605);
    (&faced_0)->geometry_n = _S607;
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
    float3  _S608 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_2) * log_0(_S608));
}

__device__ float2  vertexEta(BSDFMaterial material_12, float n_dot_v_0)
{
    bool _S609 = n_dot_v_0 < 0.0f;
    float _S610 = _slang_select(_S609, material_12.ior,1.0f);
    float _S611 = _slang_select(_S609, 1.0f,material_12.ior);
    return make_float2 (_S610, _S611);
}

__device__ bool neeDecision(BSDFMaterial material_13, float n_dot_v_1, float eta_i_8, float eta_o_8)
{
    float _S612 = fresnel((F32_abs((n_dot_v_1))), eta_i_8, eta_o_8);
    float3  _S613 = mix_0(make_float3 (_S612), material_13.albedo, material_13.metallic);
    float _S614 = rgb_to_greyscale(_S613);
    float _S615 = (F32_max(((1.0f - _S614) * (1.0f - material_13.metallic) * (1.0f - material_13.transmission)), (0.0f)));
    bool _S616 = _S615 > 0.03999999910593033f;
    bool _S617;
    if(_S616)
    {
        _S617 = true;
    }
    else
    {
        _S617 = (material_13.roughness) > 0.20000000298023224f;
    }
    return _S617;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_14)
{
    float _S618 = rgb_to_greyscale(material_14->translucent);
    return _S618 > 0.0f;
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
    MediumSides _S619;
    (&_S619)->behind = *behind_0;
    (&_S619)->front = *front_0;
    (&_S619)->fillings = fillings_1;
    (&_S619)->face = face_1;
    return _S619;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_11)
{
    float3  _S620 = surface_9->geometry_n;
    MediumSides _S621 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S621;
    bool _S622 = surface_9->encloses;
    if(_S622)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S623 = (dot_0(dir_11, _S620)) > 0.0f;
        if(_S623)
        {
            float3  _S624 = make_float3 (0.0f);
            FKMedium _S625 = Medium_x24init_0(_S624, _S624);
            (&sides_0)->front = _S625;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_12, uint depth_2, uint lobe_3, float length_3, float width_1, FKHit * own_1, bool fiber_1)
{
    float3  _S626 = surface_10->geometry_n;
    ShadowContext _S627 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
    bool _S628 = surface_10->encloses;
    ShadowContext context_2;
    if(_S628)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S629 = - _S626;
        float3  _S630 = _slang_select(turned_0, _S629,_S626);
        (&faced_1)->geometry_n = _S630;
        FKMedium _S631 = Medium_x24init_0(make_float3 (0.0f), extinction_2);
        FKSurface _S632 = faced_1;
        FKMedium _S633 = _S631;
        MediumSides _S634 = mediumSides_0(&_S632, &_S633, filling_1, dir_12);
        ShadowContext _S635 = ShadowContext_x24init_0(_S634.behind.extinction, _S634.front.extinction, _S634.fillings, _S626, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
        if(turned_0)
        {
            uint2  _S636 = _S634.fillings;
            ShadowContext _S637 = ShadowContext_x24init_0(_S634.front.extinction, _S634.behind.extinction, uint2 {_S636.y, _S636.x}, _S626, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
            context_2 = _S637;
        }
        else
        {
            context_2 = _S635;
        }
    }
    else
    {
        context_2 = _S627;
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

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_3, BSDFMaterial * material_15, float eta_i_9, float eta_o_9, bool competing_1, uint random_state_10)
{
    float3  _S638 = light_2->dir;
    bool _S639 = (dot_0(geometry_n_3, - in_dir_8) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 4>  throughputs_1;
    FixedArray<float, 4>  pdfs_3;
    float3  _S640 = BSDF(in_dir_8, _S638, smooth_n_5, *material_15, eta_i_9, eta_o_9, _S639, random_state_10, &throughputs_1, &pdfs_3);
    bool _S641 = !competing_1;
    bool _S642;
    if(_S641)
    {
        _S642 = true;
    }
    else
    {
        _S642 = (light_2->density) == 0.0f;
    }
    if(_S642)
    {
        return _S640 * light_2->radiance;
    }
    float3  _S643 = make_float3 (0.0f);
    uint i_15 = 0U;
    float3  weighted_0 = _S643;
    for(;;)
    {
        if(i_15 < 4U)
        {
        }
        else
        {
            break;
        }
        bool _S644 = (pdfs_3[i_15]) > 0.0f;
        if(_S644)
        {
            float _S645 = light_2->density;
            float _S646 = pdfs_3[i_15] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_15] * make_float3 (pdfs_3[i_15]) / make_float3 (_S645 * (1.0f + _S646 * _S646));
            weighted_0 = weighted_1;
        }
        uint i_16 = i_15 + 1U;
        i_15 = i_16;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_11, bool refracted_3, uint lobe_4, float pdf_5)
{
    SampleBSDF _S647;
    (&_S647)->unit_direction = unit_direction_1;
    (&_S647)->throughput = throughput_1;
    (&_S647)->random_state = random_state_11;
    (&_S647)->refracted = refracted_3;
    (&_S647)->lobe = lobe_4;
    (&_S647)->pdf = pdf_5;
    return _S647;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_8, float n_i_dot_v_5, float alpha_13, BSDFMaterial material_16, BSDFLobes lobes_9, float eta_i_10, float eta_o_10, uint random_state_12)
{
    float3  _S648 = make_float3 (1.0f);
    SampleBSDF _S649 = SampleBSDF_x24init_0(_S648, _S648, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S649;
    Random _S650 = pcg(random_state_12);
    Random _S651 = pcg(_S650.state);
    (&sample_1)->random_state = _S651.state;
    float _S652 = _S650.value;
    float _S653 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S652 * _S652))))));
    float _S654 = 6.28318548202514648f * _S651.value;
    float3  _S655 = tangentToWorld(make_float3 (_S653 * (F32_cos((_S654))), _S650.value, _S653 * (F32_sin((_S654)))), n_i_8);
    (&sample_1)->unit_direction = _S655;
    (&sample_1)->lobe = 4U;
    float3  _S656 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_8, alpha_13, material_16, lobes_9);
    (&sample_1)->throughput = _S656;
    float _S657 = sheenVelvetPDF(_S650.value, 0.0f, n_i_dot_v_5, alpha_13, lobes_9, eta_i_10, eta_o_10);
    (&sample_1)->pdf = _S657;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S658 = (F32_sqrt((random_1_0)));
    float _S659 = 6.28318548202514648f * random_2_0;
    float _S660 = _S658 * (F32_cos((_S659)));
    float _S661 = _S658 * (F32_sin((_S659)));
    float _S662 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S660 * _S660 - _S661 * _S661))))));
    return make_float3 (_S660, _S662, _S661);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_2, float3  n_i_9, float n_i_dot_v_6, float alpha_14, BSDFMaterial material_17, BSDFLobes lobes_10, float eta_i_11, float eta_o_11, uint random_state_13)
{
    float3  _S663 = make_float3 (1.0f);
    SampleBSDF _S664 = SampleBSDF_x24init_0(_S663, _S663, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S664;
    Random _S665 = pcg(random_state_13);
    Random _S666 = pcg(_S665.state);
    (&sample_2)->random_state = _S666.state;
    float3  _S667 = sampleCosWeightedHemisphere(_S665.value, _S666.value);
    bool _S668 = u_2 < (lobes_10.p_diffuse * lobes_10.translucent_share);
    float _S669 = _S667.y;
    float _S670 = - _S669;
    float _S671 = _slang_select(_S668, _S670,_S669);
    float3  _S672 = tangentToWorld(make_float3 (_S667.x, _S671, _S667.z), n_i_9);
    (&sample_2)->unit_direction = _S672;
    (&sample_2)->refracted = _S668;
    (&sample_2)->lobe = 0U;
    float3  _S673 = diffuseBSDF((&sample_2)->unit_direction, n_i_9, alpha_14, material_17, lobes_10);
    (&sample_2)->throughput = _S673;
    float _S674 = diffusePDF(_S671, 0.0f, n_i_dot_v_6, alpha_14, lobes_10, eta_i_11, eta_o_11);
    (&sample_2)->pdf = _S674;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_10, float n_i_dot_v_7, float alpha_15, BSDFMaterial material_18, BSDFLobes lobes_11, float eta_i_12, float eta_o_12, uint random_state_14)
{
    float3  _S675 = make_float3 (1.0f);
    SampleBSDF _S676 = SampleBSDF_x24init_0(_S675, _S675, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S676;
    (&sample_3)->unit_direction = lobes_11.refracted;
    (&sample_3)->random_state = random_state_14;
    (&sample_3)->refracted = true;
    (&sample_3)->lobe = 1U;
    float3  _S677 = refractBSDF((&sample_3)->unit_direction, n_i_10, alpha_15, material_18, lobes_11);
    (&sample_3)->throughput = _S677;
    float _S678 = refractPDF(0.0f, dot_0((&sample_3)->unit_direction, ggx_n_3), n_i_dot_v_7, alpha_15, lobes_11, eta_i_12, eta_o_12);
    (&sample_3)->pdf = _S678;
    return sample_3;
}

static __device__ float3  reflect_0(float3  i_17, float3  n_10)
{
    return i_17 - make_float3 (2.0f * dot_0(n_10, i_17)) * n_10;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_11, float n_i_dot_v_8, float alpha_16, BSDFMaterial material_19, BSDFLobes lobes_12, float eta_i_13, float eta_o_13, uint random_state_15)
{
    float3  _S679 = make_float3 (1.0f);
    SampleBSDF _S680 = SampleBSDF_x24init_0(_S679, _S679, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S680;
    float3  _S681 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S682 = ((((_S681)) * make_float3(rnorm3df(((_S681)).x, ((_S681)).y, ((_S681)).z))));
    (&sample_4)->unit_direction = _S682;
    (&sample_4)->random_state = random_state_15;
    (&sample_4)->lobe = 2U;
    float3  _S683 = reflectBSDF((&sample_4)->unit_direction, n_i_11, alpha_16, material_19, lobes_12);
    (&sample_4)->throughput = _S683;
    float _S684 = reflectPDF(0.0f, 0.0f, n_i_dot_v_8, alpha_16, lobes_12, eta_i_13, eta_o_13);
    (&sample_4)->pdf = _S684;
    return sample_4;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_11, BSDFMaterial material_20, float eta_i_14, float eta_o_14, uint random_init_0, float2  screen_space_0)
{
    uint random_state_16 = random_init_0;
    float3  _S685 = negate_0(in_dir_10);
    float _S686 = dot_0(n_11, _S685);
    float _S687 = sign_0(_S686);
    float3  n_i_12 = n_11 * make_float3 (_S687);
    float _S688 = (F32_abs((_S686)));
    float _S689 = material_20.roughness;
    float _S690 = _S689 * _S689;
    AnisotropicFrame _S691 = anisotropicFrame(material_20, n_i_12);
    SheenProfile _S692 = sheenProfile(_S685, n_i_12, material_20);
    float3  _S693 = sampleHalfVector(_S685, n_i_12, _S690, _S691, &random_state_16);
    BSDFLobes _S694 = bsdfLobes(in_dir_10, _S685, n_i_12, _S693, material_20, eta_i_14, eta_o_14, _S691, _S692);
    BSDFLobes lobes_13 = _S694;
    float _S695 = translucentShare(material_20);
    (&lobes_13)->translucent_share = _S695;
    Random _S696 = pcg(random_state_16);
    random_state_16 = _S696.state;
    bool _S697 = (_S696.value) < ((&lobes_13)->p_sheen_velvet);
    if(_S697)
    {
        SampleBSDF _S698 = sheenVelvetSample(n_i_12, _S688, _S690, material_20, lobes_13, eta_i_14, eta_o_14, random_state_16);
        return _S698;
    }
    float _S699 = _S696.value - (&lobes_13)->p_sheen_velvet;
    bool _S700 = _S699 < ((&lobes_13)->p_diffuse);
    if(_S700)
    {
        SampleBSDF _S701 = diffuseSample(_S699, n_i_12, _S688, _S690, material_20, lobes_13, eta_i_14, eta_o_14, random_state_16);
        return _S701;
    }
    bool _S702 = _S699 < ((&lobes_13)->p_diffuse + (&lobes_13)->p_refract);
    if(_S702)
    {
        SampleBSDF _S703 = refractSample(_S693, n_i_12, _S688, _S690, material_20, lobes_13, eta_i_14, eta_o_14, random_state_16);
        return _S703;
    }
    SampleBSDF _S704 = reflectSample(in_dir_10, _S693, n_i_12, _S688, _S690, material_20, lobes_13, eta_i_14, eta_o_14, random_state_16);
    return _S704;
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
    bool _S705;
    bool _S706;
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
    int _S707;
    Shift ended_0;
    float density_3;
    float spread_1;
    float width_3;
    float sky_pdf_1;
    float spread_2;
    float width_4;
    uint b_4;
    float3  _S708 = make_float3 (0.0f);
    Shift _S709 = Shift_x24init_0(_S708, 0.0f);
    uint _S710 = r_1->path;
    uint _S711 = extractBits_0(r_1->path, 0U, 5U);
    uint _S712 = extractBits_0(_S710, 5U, 5U);
    uint _S713 = extractBits_0(_S710, 10U, 2U);
    uint _S714 = extractBits_0(_S710, 12U, 3U);
    bool passes_0;
    if(replay_0)
    {
        bool _S715 = _S714 >= 3U;
        uint _S716 = _slang_select(_S715, 1U,0U);
        uint _S717 = _S711 + _S716;
        uint _S718 = (fcptMaxBounces());
        passes_0 = _S717 > _S718;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S709;
    }
    uint _S719 = _S712 - 1U;
    bool _S720 = _S714 == 3U;
    uint _S721 = _slang_select(_S720, 1U,0U);
    uint _S722 = _S711 + _S721;
    bool _S723 = _S713 == 0U;
    uint _S724 = _slang_select(_S723, _S722,_S719);
    FKHit _S725 = (fcptReservoirHit((*r_1)));
    float3  _S726 = dom_0->x0;
    float3  _S727 = dom_0->x1 - dom_0->x0;
    float3  _S728 = ((((_S727)) * make_float3(rnorm3df(((_S727)).x, ((_S727)).y, ((_S727)).z))));
    FKRay _S729 = Ray_x24init_0(dom_0->x1, _S728);
    FKRay ray_2 = _S729;
    FKHit hit_1 = dom_0->hit;
    float3  scatter_in_0 = _S708;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S708;
    float3  extinction_in_0 = _S708;
    uint filling_2 = 4294967295U;
    float _S730 = dom_0->spread;
    float _S731 = dom_0->width;
    float _S732 = length_0(_S727);
    NEEVertex _S733 = NEEVertex_x24init_0(true, 0.0f, _S708, _S708, _S708);
    NEEVertex nee_vertex_0 = _S733;
    Vertex _S734 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S734;
    Reservoir _S735 = (Reservoir{});
    Reservoir chain_0 = _S735;
    uint _S736 = r_1->seed;
    (&chain_0)->seed = r_1->seed;
    (&ray_2)->origin = _S726;
    (&hit_1)->distance = _S732;
    FKMedium _S737 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_1)->distance), (&filling_2)));
    uint _S738 = filling_2;
    bool _S739 = (fcptVaryingUsed());
    uint _S740 = _slang_select(_S739, _S738,4294967295U);
    filling_2 = _S740;
    scatter_in_0 = _S737.scatter;
    extinction_in_0 = _S737.extinction;
    Reservoir _S741 = chain_0;
    uint _S742 = filling_2;
    for(;;)
    {
        bool _S743 = (fcptVaryingUsed());
        if(_S743)
        {
            passes_0 = _S742 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S744 = (fcptMajorant((_S742)));
            spread_0 = _S744;
        }
        else
        {
            spread_0 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_0)
        {
            turned_1 = 4294967295U == _S724;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S713 == 1U;
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
            ended_0 = _S709;
            sky_pdf_0 = 0.0f;
            spread_0 = _S730;
            width_2 = _S731;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_3 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S745 = (&prev_0)->rough;
        if(_S745)
        {
            turned_1 = !(spread_0 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S746 = stream(_S736, 384U);
        uint tracking_0 = _S746;
        weight_1 = throughput_3;
        glowed_0 = _S708;
        b_3 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_0 = _S730;
        width_2 = _S731;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_1)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S707 = int(1);
                break;
            }
            uint _S747 = b_3 + 320U;
            bool _S748 = b_3 == 4294967295U;
            uint _S749 = _slang_select(_S748, 384U,_S747);
            uint _S750 = stream(_S736, _S749);
            Random _S751 = pcg(_S750);
            float _S752 = - (F32_log((1.0f - _S751.value))) / spread_0;
            if(passes_0)
            {
                float3  _S753 = (&ray_2)->origin;
                float3  _S754 = (&ray_2)->unit_direction;
                float _S755 = (&hit_1)->distance;
                uint _S756 = _slang_select(_S748, 0U,b_3);
                uint _S757 = (&prev_0)->lobe;
                uint _S758 = _slang_select(_S748, 3U,_S757);
                float _S759 = (fcptTrackMedium((_S742), (_S753), (_S754), (_S755), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S756), (_S758), (_S748)));
                geometry_density_0 = _S759;
            }
            else
            {
                geometry_density_0 = _S752;
            }
            bool _S760 = !(geometry_density_0 < ((&hit_1)->distance));
            if(_S760)
            {
                _S707 = int(1);
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
                float3  _S761 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S762 = sel_1->glow + _S761;
                sel_1->glow = _S762;
            }
            else
            {
            }
            glowed_0 = _S708;
            uint b_5 = b_3 + 1U;
            float3  _S763 = (&ray_2)->origin + make_float3 (geometry_density_0) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S763;
            float3  _S764 = flightWeight_0(scatter_in_0, extinction_in_0, spread_0, geometry_density_0, true);
            float3  _S765 = weight_1;
            float3  _S766 = _slang_select(passes_0, _S765,_S764);
            float3  throughput_4 = throughput_2 * _S766;
            uint _S767 = stream(_S736, b_5 + 320U);
            tracking_0 = _S767;
            weight_1 = throughput_3;
            float width_5 = width_2 + threshold_0 * geometry_density_0;
            float _S768 = threshold_0 + 3.14159274101257324f;
            bool _S769 = !replay_0;
            if(_S769)
            {
                is_inside_5 = true;
            }
            else
            {
                bool _S770 = b_5 == _S724;
                if(_S770)
                {
                    is_inside_5 = !passes_0;
                }
                else
                {
                    is_inside_5 = false;
                }
            }
            TreeSample _S771 = TreeSample_x24init_0(_S708, _S708, 0.0f, 0U);
            if(is_inside_5)
            {
                float3  _S772 = (&ray_2)->origin;
                float3  _S773 = (&ray_2)->unit_direction;
                float3  _S774 = (&ray_2)->unit_direction;
                uint _S775 = stream(_S736, b_5 + 64U);
                float3  _S776 = extinction_in_0;
                float3  _S777 = extinction_in_0;
                uint2  _S778 = make_uint2 (_S742);
                float3  _S779 = (&ray_2)->unit_direction;
                uint _S780 = arrivalLobe_0(b_5, (&prev_0)->lobe);
                FKHit _S781 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S782 = _S781;
                ShadowContext _S783 = ShadowContext_x24init_0(_S776, _S777, _S778, _S779, b_5, _S780, false, geometry_density_0, width_5, &_S782, false);
                ShadowContext _S784 = _S783;
                TreeSample _S785 = sampleLightTree_0(_S772, _S773, _S774, 0.0f, true, _S775, &_S784);
                light_3 = _S785;
            }
            else
            {
                light_3 = _S771;
            }
            uint _S786 = (fcptMaxBounces());
            bool _S787 = b_5 < _S786;
            if(_S787)
            {
                viewed_0 = (light_3.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S788 = _slang_select(viewed_0, 0.07957746833562851f,0.0f);
            float3  _S789 = throughput_4 * light_3.radiance;
            float _S790 = powerHeuristic(light_3.density, _S788);
            float3  _S791 = _S789 * make_float3 (0.07957746833562851f * _S790);
            float3  _S792 = _slang_select(is_inside_5, _S791,_S708);
            if(replay_0)
            {
                _S705 = b_5 == _S724;
            }
            else
            {
                _S705 = false;
            }
            if(_S705)
            {
                bool _S793 = _S713 == 2U;
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
                    _S707 = int(0);
                    ended_0 = _S795;
                    spread_0 = _S768;
                    geometry_density_0 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_5;
                    break;
                }
                _S707 = int(0);
                ended_0 = _S709;
                spread_0 = _S768;
                geometry_density_0 = width_5;
                chain_throughput_0 = throughput_4;
                layer_0 = b_5;
                break;
            }
            if(_S769)
            {
                Reservoir candidate_2 = _S741;
                uint _S796 = extractBits_0(_S741.path, 10U, 2U);
                bool _S797 = _S796 == 1U;
                if(_S797)
                {
                    float3  _S798 = safeDivide(_S792, _S708);
                    (&candidate_2)->radiance = _S798;
                }
                else
                {
                    uint _S799 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                    uint _S800 = insertBits_0(_S799, 2U, 10U, 2U);
                    (&candidate_2)->path = _S800;
                }
                Reservoir _S801 = withEnd(candidate_2, 0U, b_5, _S792);
                offer(sel_1, _S801, _S792 * make_float3 (scale_1) / make_float3 (density_2));
                float _S802 = survivalProbability(throughput_4, density_2);
                uint _S803 = stream(_S736, b_5 + 128U);
                Random _S804 = pcg(_S803);
                bool _S805 = _S802 < (_S804.value);
                if(_S805)
                {
                    _S706 = true;
                }
                else
                {
                    uint _S806 = (fcptMaxBounces());
                    _S706 = b_5 >= _S806;
                }
                if(_S706)
                {
                    _S707 = int(0);
                    ended_0 = _S709;
                    spread_0 = _S768;
                    geometry_density_0 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_5;
                    break;
                }
                float _S807 = density_2 * _S802;
                density_2 = _S807;
            }
            else
            {
            }
            NEEVertex _S808 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_2)->origin, _S708, (&ray_2)->origin);
            nee_vertex_0 = _S808;
            uint _S809 = stream(_S736, b_5);
            float3  _S810 = isotropic_0(_S809);
            (&ray_2)->unit_direction = _S810;
            Vertex _S811 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_0 = _S811;
            float _S812 = (&prev_0)->pdf;
            FKRay _S813 = ray_2;
            FKHit _S814 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S815 = (fcptTraverseInstanceBVH((_S813), (true), (4.294967296e+09f), (false), (_S814), (false)));
            hit_1 = _S815;
            b_3 = b_5;
            throughput_2 = throughput_4;
            threshold_0 = _S768;
            width_2 = width_5;
            sky_pdf_0 = _S812;
        }
        if(_S707 != int(1))
        {
            width_2 = geometry_density_0;
            throughput_2 = chain_throughput_0;
            b_3 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S709;
        spread_0 = threshold_0;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S816 = b_3 == 4294967295U;
    bool _S817 = ((&hit_1)->instance_index) == 4294967295U;
    if(_S817)
    {
        bool _S818 = !(&nee_vertex_0)->none;
        float _S819 = _slang_select(_S818, sky_pdf_0,0.0f);
        float _S820 = escapeWeight_0(_S819, (&ray_2)->unit_direction);
        float3  _S821 = environment_0((&ray_2)->unit_direction, b_3, (&prev_0)->lobe);
        float3  _S822 = throughput_2 * _S821;
        if(replay_0)
        {
            bool _S823 = b_3 == _S724;
            if(_S823)
            {
                passes_0 = _S713 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S822 * make_float3 (_S820) / make_float3 (r_1->jac), density_2 / r_1->jac);
            }
            if(_S723)
            {
                passes_0 = _S720;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_3 == _S711;
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
                return Shift_x24init_0(_S822 * make_float3 (_S820), 1.0f);
            }
            return _S709;
        }
        Reservoir candidate_3 = chain_0;
        uint _S824 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S825 = _S824 == 1U;
        if(_S825)
        {
            uint _S826 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S827 = _S826 == b_3;
            float _S828 = _slang_select(_S827, 1.0f,_S820);
            float3  _S829 = safeDivide(_S822 * make_float3 (_S828), _S708);
            (&candidate_3)->radiance = _S829;
        }
        else
        {
            bool _S830 = (&prev_0)->rough;
            if(_S830)
            {
                uint _S831 = insertBits_0(0U, b_3 + 1U, 5U, 5U);
                uint _S832 = insertBits_0(_S831, 3U, 10U, 2U);
                uint _S833 = insertBits_0(_S832, (&prev_0)->lobe, 15U, 3U);
                bool _S834 = (&prev_0)->inside;
                uint _S835 = _slang_select(_S834, 1U,0U);
                uint _S836 = insertBits_0(_S833, _S835, 22U, 1U);
                (&candidate_3)->path = _S836;
                (&candidate_3)->jac = (&prev_0)->pdf;
                (&candidate_3)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S837 = _S822 * make_float3 (_S820);
        Reservoir _S838 = withEnd(candidate_3, 3U, b_3, _S837);
        offer(sel_1, _S838, _S837 * make_float3 (scale_1) / make_float3 (density_2));
        return _S709;
    }
    float3  _S839 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S839;
    bool _S840 = (fcptVaryingUsed());
    if(_S840)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S841 = !replay_0;
        if(_S841)
        {
            float3  _S842 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S843 = sel_1->glow + _S842;
            sel_1->glow = _S843;
        }
        float3  _S844 = throughput_2 * weight_1;
        throughput_2 = _S844;
    }
    else
    {
        float3  _S845 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
        float3  _S846 = throughput_2 * _S845;
        throughput_2 = _S846;
    }
    float _S847 = width_2 + spread_0 * (&hit_1)->distance;
    uint _S848 = b_3 + 1U;
    b_3 = _S848;
    layer_0 = 0U;
    width_2 = _S847;
    passes_0 = false;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S708;
    float3  reconnection_0 = _S708;
    viewed_0 = _S816;
    for(;;)
    {
        bool _S849 = ((&hit_1)->is_point_light) == 1U;
        if(replay_0)
        {
            _S705 = _S713 == 1U;
        }
        else
        {
            _S705 = false;
        }
        if(_S705)
        {
            _S706 = b_3 == _S712;
        }
        else
        {
            _S706 = false;
        }
        bool _S850;
        if(_S706)
        {
            bool _S851 = ((&hit_1)->instance_index) != (_S725.instance_index);
            if(_S851)
            {
                _S850 = true;
            }
            else
            {
                _S850 = ((&hit_1)->triangle_index) != (_S725.triangle_index);
            }
        }
        else
        {
            _S850 = false;
        }
        if(_S850)
        {
            return _S709;
        }
        FKMedium _S852 = Medium_x24init_0(_S708, _S708);
        BSDFMaterial _S853 = Material_x24init_0(_S708, _S708, 0.0f, 0.0f, 0.0f, 0.0f, _S708, throughput_3, 1.0f, _S708, _S708, 0.5f, 0.0f, 0.0f, _S708);
        FKMedium _S854 = _S852;
        FKSurface _S855 = Surface_x24init_0(_S708, _S708, 0.0f, &_S853, false, 0U, 1.0f, false, &_S854, 4294967295U, _S708);
        bool _S856 = !_S849;
        bool scatter_2;
        bool is_inside_6;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S856)
        {
            uint _S857 = stream(_S736, b_3);
            uint _S858 = arrivalLobe_0(b_3, (&prev_0)->lobe);
            FKSurface _S859 = (fcptSurfaceAtPath((hit_1), ((&ray_2)->origin), (_S857), (width_2), (layer_0), (b_3), (_S858), ((&ray_2)->unit_direction)));
            bool _S860 = !passes_0;
            FKSurface _S861 = _S859;
            FKSurface _S862 = emitting_0(&_S861, _S860);
            uint _S863 = stream(_S736, b_3 + 256U);
            Random _S864 = pcg(_S863);
            FKSurface _S865 = _S862;
            FKSurface _S866 = uncovered_0(&_S865, _S864.value);
            float _S867 = facingSign(_S866.material.transmission, _S866.geometry_n, (&ray_2)->unit_direction);
            bool _S868 = _S867 < 0.0f;
            bool _S869 = (_S866.material.transmission) > 0.0f;
            if(_S869)
            {
                bool _S870 = arrivesBehind_0((&ray_2)->unit_direction, _S866.geometry_n);
                scatter_2 = _S870;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S871 = _S866;
            FKSurface _S872 = facingRay_0(&_S871, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S873 = arrivesBehind_0((&ray_2)->unit_direction, _S872.geometry_n);
                is_inside_6 = _S873;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S874 = beerLambert((&hit_1)->distance, _S872.material.absorption);
                float3  _S875 = throughput_2 * _S874;
                throughput_5 = _S875;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S876 = !_S872.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S872.geometry_n, (&ray_2)->unit_direction)))) / ((&hit_1)->distance * (&hit_1)->distance);
            bool _S877 = b_3 == _S848;
            if(_S877)
            {
                float _S878 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S878;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S879 = geometry_density_0;
            scatter_2 = _S876;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S879;
            surface_12 = _S872;
            turned_1 = _S868;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_12 = _S855;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S880;
        if(scatter_2)
        {
            _S880 = (&prev_0)->rough;
        }
        else
        {
            _S880 = false;
        }
        bool _S881;
        if(_S880)
        {
            _S881 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S881 = false;
        }
        FKSurface _S882 = surface_12;
        FKSurface _S883 = surface_12;
        float _S884 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        float2  _S885 = vertexEta(_S882.material, _S884);
        bool _S886;
        if(scatter_2)
        {
            bool _S887 = neeDecision(_S882.material, _S884, _S885.x, _S885.y);
            _S886 = _S887;
        }
        else
        {
            _S886 = false;
        }
        bool _S888;
        if(passes_0)
        {
            _S888 = true;
        }
        else
        {
            _S888 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S888)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S886;
        }
        bool _S889 = (fcptHairUsed());
        bool _S890;
        if(_S889)
        {
            float3  _S891 = surface_12.hair;
            _S890 = (dot_0(_S891, _S891)) > 0.0f;
        }
        else
        {
            _S890 = false;
        }
        bool _S892;
        if(_S890)
        {
            _S892 = true;
        }
        else
        {
            BSDFMaterial _S893 = _S882.material;
            bool _S894 = isTranslucent_0(&_S893);
            _S892 = _S894;
        }
        bool _S895;
        if(_S892)
        {
            _S895 = true;
        }
        else
        {
            bool _S896 = (_S882.material.transmission) > 0.0f;
            if(_S896)
            {
                uint _S897 = (fcptLayers((hit_1)));
                _S895 = _S897 == 1U;
            }
            else
            {
                _S895 = false;
            }
        }
        float3  emission_0;
        if(_S849)
        {
            float3  _S898 = (fcptCalculatePointLightContrib(((&hit_1)->instance_index)));
            emission_0 = _S898;
        }
        else
        {
            emission_0 = _S882.material.emissive;
        }
        bool _S899 = !replay_0;
        bool _S900;
        if(_S899)
        {
            _S900 = true;
        }
        else
        {
            _S900 = b_3 >= _S724;
        }
        bool _S901;
        if(_S900)
        {
            float _S902 = rgb_to_greyscale(emission_0);
            _S901 = _S902 > 0.0f;
        }
        else
        {
            _S901 = false;
        }
        float3  emission_1;
        if(_S901)
        {
            NEEVertex _S903 = nee_vertex_0;
            FKHit _S904 = hit_1;
            float _S905 = emissionWeight_0(&_S903, &_S904, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S905);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S906;
        if(replay_0)
        {
            _S906 = _S713 == 1U;
        }
        else
        {
            _S906 = false;
        }
        bool _S907;
        if(_S906)
        {
            _S907 = b_3 > _S712;
        }
        else
        {
            _S907 = false;
        }
        bool _S908;
        if(_S907)
        {
            _S908 = b_3 == _S711;
        }
        else
        {
            _S908 = false;
        }
        bool _S909;
        if(_S908)
        {
            bool _S910 = _S714 == 1U;
            if(_S910)
            {
                _S909 = true;
            }
            else
            {
                _S909 = _S714 == 2U;
            }
        }
        else
        {
            _S909 = false;
        }
        if(_S909)
        {
            bool _S911 = _S849 != (_S714 == 2U);
            if(_S911)
            {
                return _S709;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_1->jac), density_2 / r_1->jac);
        }
        uint _S912 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S913 = _S912 == 1U;
        Reservoir here_0 = chain_0;
        uint _S914 = insertBits_0(0U, b_3, 5U, 5U);
        uint _S915 = insertBits_0(_S914, 1U, 10U, 2U);
        uint _S916 = insertBits_0(_S915, (&prev_0)->lobe, 15U, 3U);
        bool _S917 = (&prev_0)->inside;
        uint _S918 = _slang_select(_S917, 1U,0U);
        uint _S919 = insertBits_0(_S916, _S918, 22U, 1U);
        (&here_0)->path = _S919;
        float _S920 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S920;
        fcptWithReservoirHit((&here_0), (&hit_1));
        bool _S921;
        if(replay_0)
        {
            _S921 = _S713 == 1U;
        }
        else
        {
            _S921 = false;
        }
        bool _S922;
        if(_S921)
        {
            _S922 = b_3 == _S712;
        }
        else
        {
            _S922 = false;
        }
        bool _S923 = b_3 == _S724;
        bool _S924;
        if(_S923)
        {
            bool _S925 = !scatter_2;
            if(_S925)
            {
                _S924 = true;
            }
            else
            {
                bool _S926 = _S713 != 1U;
                if(_S926)
                {
                    _S924 = _S713 != 3U;
                }
                else
                {
                    _S924 = false;
                }
            }
        }
        else
        {
            _S924 = false;
        }
        bool _S927;
        if(_S924)
        {
            _S927 = _S713 == 2U;
        }
        else
        {
            _S927 = false;
        }
        bool _S928;
        if(_S927)
        {
            _S928 = !_S881;
        }
        else
        {
            _S928 = false;
        }
        bool _S929;
        if(_S928)
        {
            _S929 = _S714 != 4U;
        }
        else
        {
            _S929 = false;
        }
        bool _S930 = _S712 == _S711;
        bool _S931;
        if(_S930)
        {
            _S931 = _S714 == 0U;
        }
        else
        {
            _S931 = false;
        }
        bool _S932;
        if(_S931)
        {
            _S932 = ((&hit_1)->instance_index) == (_S725.instance_index);
        }
        else
        {
            _S932 = false;
        }
        bool _S933;
        if(_S932)
        {
            _S933 = ((&hit_1)->triangle_index) == (_S725.triangle_index);
        }
        else
        {
            _S933 = false;
        }
        bool _S934;
        if(_S933)
        {
            _S934 = _S881;
        }
        else
        {
            _S934 = false;
        }
        bool _S935 = _slang_select(_S922, _S934,_S929);
        bool _S936;
        if(nee_0)
        {
            _S936 = _slang_select(replay_0, _S935,scatter_2);
        }
        else
        {
            _S936 = false;
        }
        TreeSample _S937 = TreeSample_x24init_0(_S708, _S708, 0.0f, 0U);
        float3  throughput_6;
        float3  lit_0;
        if(_S936)
        {
            float3  _S938 = (&ray_2)->origin;
            if(_S890)
            {
                throughput_6 = _S708;
            }
            else
            {
                throughput_6 = _S883.smooth_n;
            }
            FKSurface _S939 = surface_12;
            uint _S940 = stream(_S736, b_3 + 64U);
            uint _S941 = arrivalLobe_0(b_3, (&prev_0)->lobe);
            FKSurface _S942 = surface_12;
            FKHit _S943 = hit_1;
            ShadowContext _S944 = shadowContext_0(&_S942, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_3, _S941, (&hit_1)->distance, width_2, &_S943, _S890);
            ShadowContext _S945 = _S944;
            TreeSample _S946 = sampleLightTree_0(_S938, throughput_6, surface_12.geometry_n, surface_12.geometry_offset, _S895, _S940, &_S945);
            bool _S947 = any_0((_S946.radiance) != _S708);
            if(_S947)
            {
                if(_S890)
                {
                    uint _S948 = (fcptMaxBounces());
                    bool _S949 = b_3 < _S948;
                    FKSurface _S950 = surface_12;
                    TreeSample _S951 = _S946;
                    float3  _S952 = hairLight_0(&_S950, (&ray_2)->unit_direction, &_S951, _S949);
                    lit_0 = _S952;
                }
                else
                {
                    float _S953 = _S885.x;
                    float _S954 = _S885.y;
                    uint _S955 = (fcptMaxBounces());
                    bool _S956 = b_3 < _S955;
                    TreeSample _S957 = _S946;
                    BSDFMaterial _S958 = _S882.material;
                    float3  _S959 = lightBSDF_0((&ray_2)->unit_direction, &_S957, _S883.smooth_n, _S939.geometry_n, &_S958, _S953, _S954, _S956, surface_12.random_state);
                    lit_0 = _S959;
                }
            }
            else
            {
                lit_0 = _S708;
            }
            light_3 = _S946;
        }
        else
        {
            light_3 = _S937;
            lit_0 = _S708;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S960;
        bool _S961;
        float density_4;
        if(_S922)
        {
            bool _S962 = !_S881;
            if(_S962)
            {
                return _S709;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S930)
            {
                viewed_1 = _S714 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            if(_S930)
            {
                refracted_4 = _S714 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S963 = !nee_0;
                if(_S963)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S964 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S964 > 0.0f);
                }
                if(passes_0)
                {
                    return _S709;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            if(_S930)
            {
                wrong_side_0 = _S714 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S965 = !nee_0;
                if(_S965)
                {
                    return _S709;
                }
                float _S966 = environmentPdf_0(r_1->dir);
                float3  _S967 = skyBSDF((&ray_2)->unit_direction, r_1->dir, surface_12, _S885, is_inside_6, _S966, surface_12.random_state);
                return Shift_x24init_0(throughput_7 * _S967 * r_1->radiance / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            uint _S968 = extractBits_0(_S710, 21U, 1U);
            bool _S969 = nee_0 != (_S968 == 1U);
            if(_S969)
            {
                return _S709;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_0)
            {
                viewed_1 = _S923;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S970 = !scatter_2;
                if(_S970)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S971 = _S713 != 1U;
                    if(_S971)
                    {
                        refracted_4 = _S713 != 3U;
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
                bool _S972 = _S713 == 2U;
                if(_S972)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S881;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S714 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    uint _S973 = stream(_S736, b_3 + 448U);
                    FKRay _S974 = ray_2;
                    FKSurface _S975 = surface_12;
                    SkySample _S976 = sampleSky_0(&_S974, &_S975, _S885, is_inside_6, _S973, surface_12.random_state);
                    return Shift_x24init_0(throughput_5 * _S976.color, 1.0f);
                }
                if(_S972)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S881;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S977 = rgb_to_greyscale(light_3.radiance);
                    bool _S978 = !(_S977 > 0.0f);
                    if(_S978)
                    {
                        return _S709;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S723)
                {
                    passes_0 = _S714 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S849;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S723)
                {
                    passes_0 = _S714 == 1U;
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
                    passes_0 = !_S881;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S709;
            }
            else
            {
                if(_S899)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S979 = b_3 > 0U;
                    if(_S979)
                    {
                        Reservoir candidate_4 = chain_0;
                        if(_S913)
                        {
                            float3  _S980 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_4)->radiance = _S980;
                        }
                        else
                        {
                            if(_S881)
                            {
                                candidate_4 = here_0;
                            }
                        }
                        float3  _S981 = throughput_5 * emission_1;
                        Reservoir _S982 = withEnd(candidate_4, 1U, b_3, _S981);
                        offer(sel_1, _S982, _S981 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S983 = throughput_5 * emission_1;
                        float3  _S984 = sel_1->glow + _S983;
                        sel_1->glow = _S984;
                    }
                    if(nee_0)
                    {
                        float3  _S985 = throughput_5 * lit_0;
                        Reservoir candidate_5 = chain_0;
                        if(_S913)
                        {
                            float3  _S986 = safeDivide(_S985, chain_throughput_0);
                            (&candidate_5)->radiance = _S986;
                        }
                        else
                        {
                            if(_S881)
                            {
                                candidate_5 = here_0;
                                uint _S987 = insertBits_0((&candidate_5)->path, 1U, 21U, 1U);
                                (&candidate_5)->path = _S987;
                                (&candidate_5)->dir = light_3.dir;
                                (&candidate_5)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S988 = insertBits_0(0U, b_3 + 1U, 5U, 5U);
                                uint _S989 = insertBits_0(_S988, 2U, 10U, 2U);
                                (&candidate_5)->path = _S989;
                            }
                        }
                        Reservoir _S990 = withEnd(candidate_5, 0U, b_3, _S985);
                        offer(sel_1, _S990, _S985 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S890)
                        {
                            _S960 = false;
                        }
                        else
                        {
                            bool _S991 = environmentMapped_0();
                            _S960 = _S991;
                        }
                    }
                    else
                    {
                        _S960 = false;
                    }
                    if(_S960)
                    {
                        uint _S992 = (fcptMaxBounces());
                        _S961 = b_3 < _S992;
                    }
                    else
                    {
                        _S961 = false;
                    }
                    if(_S961)
                    {
                        uint _S993 = stream(_S736, b_3 + 448U);
                        FKRay _S994 = ray_2;
                        FKSurface _S995 = surface_12;
                        SkySample _S996 = sampleSky_0(&_S994, &_S995, _S885, is_inside_6, _S993, surface_12.random_state);
                        float3  _S997 = throughput_5 * _S996.color;
                        Reservoir candidate_6 = chain_0;
                        if(_S913)
                        {
                            float3  _S998 = safeDivide(_S997, chain_throughput_0);
                            (&candidate_6)->radiance = _S998;
                        }
                        else
                        {
                            if(_S881)
                            {
                                candidate_6 = here_0;
                                uint _S999 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S999;
                                (&candidate_6)->dir = _S996.dir;
                                (&candidate_6)->radiance = _S996.radiance;
                            }
                            else
                            {
                                uint _S1000 = insertBits_0(0U, b_3 + 1U, 5U, 5U);
                                uint _S1001 = insertBits_0(_S1000, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1001;
                            }
                        }
                        Reservoir _S1002 = withEnd(candidate_6, 4U, b_3, _S997);
                        offer(sel_1, _S1002, _S997 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1003;
        bool _S1004;
        bool straight_0;
        bool _S1005;
        bool _S1006;
        bool _S1007;
        bool _S1008;
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
                viewed_1 = _S923;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1019 = extractBits_0(_S710, 15U, 3U);
            uint _S1020 = extractBits_0(_S710, 18U, 3U);
            uint _S1021 = _slang_select(_S922, _S1020,_S1019);
            float3  _S1022 = r_1->dir;
            bool refracted_5 = _S1021 == 1U;
            SampleBSDF _S1023 = SampleBSDF_x24init_0(_S708, _S708, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1023;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1024 = extractBits_0(_S710, 22U, 1U);
                bool _S1025 = is_inside_6 != (_S1024 == 1U);
                if(_S1025)
                {
                    return _S709;
                }
                bool _S1026 = _S713 == 1U;
                if(_S1026)
                {
                    float3  _S1027 = (fcptHitPosition((_S725)));
                    throughput_8 = _S1027;
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
                    BSDFMaterial _S1028 = _S882.material;
                    bool _S1029 = isTranslucent_0(&_S1028);
                    if(_S1029)
                    {
                        refracted_4 = _S1021 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1030 = throughput_8 - (&ray_2)->origin;
                        float3  _S1031 = _slang_select(_S1026, _S1030,_S1022);
                        wrong_side_0 = (dot_0(_S883.smooth_n, _S1031) * _S884) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1026)
                {
                    float3  _S1032 = (&ray_2)->origin;
                    FKSurface _S1033 = surface_12;
                    float3  _S1034 = - _S883.smooth_n;
                    bool _S1035 = is_inside_6 != refracted_4;
                    float3  _S1036 = _slang_select(_S1035, _S1034,_S883.smooth_n);
                    float3  _S1037 = throughput_8 - (_S1032 + make_float3 (_S1033.geometry_offset) * _S1036);
                    float3  _S1038 = ((((_S1037)) * make_float3(rnorm3df(((_S1037)).x, ((_S1037)).y, ((_S1037)).z))));
                    reconnection_1 = _S1038;
                }
                else
                {
                    reconnection_1 = _S1022;
                }
                if(_S890)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1039 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1039;
                }
                if(wrong_side_0)
                {
                    return _S709;
                }
                float3  _S1040 = throughput_8;
                throughput_8 = reconnection_1;
                b_6 = _S1021;
                wrong_side_0 = false;
                reconnection_1 = _S1040;
            }
            else
            {
                bool _S1041 = !_S922;
                if(_S1041)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1042;
                    if(_S890)
                    {
                        SampleBSDF _S1043 = (fcptSampleHair((surface_12.hair), (_S882.material.albedo), (_S882.material.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1042 = _S1043;
                    }
                    else
                    {
                        SampleBSDF _S1044 = sampleBSDF((&ray_2)->unit_direction, _S883.smooth_n, _S882.material, _S885.x, _S885.y, surface_12.random_state, make_float2 (0.0f));
                        _S1042 = _S1044;
                    }
                    bsdf_sampled_0 = _S1042;
                    if(_S890)
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
                            return _S709;
                        }
                        break;
                    }
                    if(_S890)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1045 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1045;
                    }
                    if(wrong_side_0)
                    {
                        _S960 = (_S882.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S960 = false;
                    }
                    if(_S960)
                    {
                        SampleBSDF _S1046 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S882.material, _S885.x, _S885.y, (&bsdf_sampled_0)->random_state, make_float2 (0.0f));
                        (&bsdf_sampled_0)->unit_direction = _S1046.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1046.refracted;
                        (&bsdf_sampled_0)->throughput = _S1046.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1047 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1047;
                        }
                    }
                    uint _S1048 = (&bsdf_sampled_0)->lobe;
                    float3  _S1049 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1050 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1051 = (&bsdf_sampled_0)->pdf;
                    float _S1052 = _slang_select(wrong_side_0, 0.0f,_S1051);
                    (&lobe_5)->pdf = _S1052;
                    throughput_8 = _S1049;
                    b_6 = _S1048;
                    refracted_4 = _S1050;
                }
                else
                {
                    throughput_8 = _S1022;
                    b_6 = _S1021;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S960 = true;
            }
            else
            {
                _S960 = _S922;
            }
            float3  chain_throughput_1;
            if(_S960)
            {
                if(_S890)
                {
                    SampleBSDF _S1053 = (fcptConnectHair((surface_12.hair), (_S882.material.albedo), (_S882.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    lobe_5 = _S1053;
                }
                else
                {
                    float3  _S1054 = (&ray_2)->unit_direction;
                    float _S1055 = sign_0(_S884);
                    float3  _S1056 = _S883.smooth_n * make_float3 (_S1055);
                    float _S1057 = dot_0(_S1056, throughput_8);
                    float _S1058 = _S882.material.roughness;
                    float _S1059 = _S1058 * _S1058;
                    AnisotropicFrame _S1060 = anisotropicFrame(_S882.material, _S1056);
                    float3  _S1061 = negate_0(_S1054);
                    SheenProfile _S1062 = sheenProfile(_S1061, _S1056, _S882.material);
                    float3  _S1063 = reflectedHalf(_S1054, throughput_8);
                    bool _S1064 = b_6 == 1U;
                    if(_S1064)
                    {
                        float3  _S1065 = refractedHalf(_S1054, throughput_8, _S883.smooth_n, _S885.x, _S885.y);
                        throughput_9 = _S1065;
                    }
                    else
                    {
                        throughput_9 = _S1063;
                    }
                    bool _S1066 = b_6 == 0U;
                    if(_S1066)
                    {
                        float3  _S1067 = sampledHalf(_S1054, _S883.smooth_n, _S882.material, surface_12.random_state, _S1060);
                        throughput_10 = _S1067;
                    }
                    else
                    {
                        throughput_10 = throughput_9;
                    }
                    float3  _S1068 = negate_0(_S1054);
                    float _S1069 = _S885.x;
                    float _S1070 = _S885.y;
                    BSDFLobes _S1071 = bsdfLobes(_S1054, _S1068, _S1056, throughput_10, _S882.material, _S1069, _S1070, _S1060, _S1062);
                    BSDFLobes lobe_terms_1 = _S1071;
                    float _S1072 = translucentShare(_S882.material);
                    (&lobe_terms_1)->translucent_share = _S1072;
                    switch(b_6)
                    {
                    case 0U:
                        {
                            float _S1073 = diffusePDF(_S1057, 0.0f, (F32_abs((_S884))), _S1059, lobe_terms_1, _S1069, _S1070);
                            float3  _S1074 = diffuseBSDF(throughput_8, _S1056, _S1059, _S882.material, lobe_terms_1);
                            density_6 = _S1073;
                            chain_throughput_1 = _S1074;
                            break;
                        }
                    case 1U:
                        {
                            float _S1075 = refractPDF(_S1057, dot_0(throughput_8, throughput_10), (F32_abs((_S884))), _S1059, lobe_terms_1, _S1069, _S1070);
                            float3  _S1076 = refractBSDF(throughput_8, _S1056, _S1059, _S882.material, lobe_terms_1);
                            density_6 = _S1075;
                            chain_throughput_1 = _S1076;
                            break;
                        }
                    case 4U:
                        {
                            float _S1077 = sheenVelvetPDF(_S1057, 0.0f, (F32_abs((_S884))), _S1059, lobe_terms_1, _S1069, _S1070);
                            float3  _S1078 = sheenVelvetBSDF(throughput_8, _S1056, _S1059, _S882.material, lobe_terms_1);
                            density_6 = _S1077;
                            chain_throughput_1 = _S1078;
                            break;
                        }
                    default:
                        {
                            float _S1079 = reflectPDF(_S1057, 0.0f, (F32_abs((_S884))), _S1059, lobe_terms_1, _S1069, _S1070);
                            float3  _S1080 = reflectBSDF(throughput_8, _S1056, _S1059, _S882.material, lobe_terms_1);
                            density_6 = _S1079;
                            chain_throughput_1 = _S1080;
                            break;
                        }
                    }
                    bool _S1081 = density_6 > 0.0f;
                    if(_S1081)
                    {
                        SampleBSDF _S1082 = SampleBSDF_x24init_0(throughput_8, chain_throughput_1, surface_12.random_state, _S1064, b_6, density_6);
                        lobe_5 = _S1082;
                    }
                }
            }
            bool _S1083 = b_6 == 0U;
            if(_S1083)
            {
                _S961 = true;
            }
            else
            {
                _S961 = b_6 == 4U;
            }
            if(_S890)
            {
                _S1003 = false;
            }
            else
            {
                bool _S1084 = !_S961;
                if(_S1084)
                {
                    bool _S1085 = (_S882.material.roughness) == 0.0f;
                    if(_S1085)
                    {
                        _S1003 = true;
                    }
                    else
                    {
                        bool _S1086 = b_6 == 1U;
                        if(_S1086)
                        {
                            _S1003 = (_S885.x) == (_S885.y);
                        }
                        else
                        {
                            _S1003 = false;
                        }
                    }
                }
                else
                {
                    _S1003 = false;
                }
            }
            bool _S1087 = !_S890;
            if(_S1087)
            {
                _S1004 = b_6 == 1U;
            }
            else
            {
                _S1004 = false;
            }
            if(_S1004)
            {
                straight_0 = (_S882.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1005 = _S1087;
            }
            else
            {
                _S1005 = false;
            }
            if(_S1005)
            {
                _S1006 = b_6 == 1U;
            }
            else
            {
                _S1006 = false;
            }
            if(_S1006)
            {
                _S1007 = (_S885.x) == (_S885.y);
            }
            else
            {
                _S1007 = false;
            }
            BSDFMaterial _S1088 = _S882.material;
            bool _S1089 = isTranslucent_0(&_S1088);
            if(_S1089)
            {
                _S1008 = _S1083;
            }
            else
            {
                _S1008 = false;
            }
            if(_S1008)
            {
                _S1009 = (dot_0(throughput_8, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1009 = false;
            }
            if(nee_0)
            {
                _S1010 = !_S1003;
            }
            else
            {
                _S1010 = false;
            }
            if(_S1010)
            {
                _S1011 = !wrong_side_0;
            }
            else
            {
                _S1011 = false;
            }
            if(_S1011)
            {
                float _S1090 = (&lobe_5)->pdf;
                float3  _S1091 = (&ray_2)->origin;
                float3  _S1092 = _slang_select(_S895, _S708,_S883.smooth_n);
                float3  _S1093 = (&ray_2)->origin;
                FKSurface _S1094 = surface_12;
                float3  _S1095 = - _S883.smooth_n;
                float3  _S1096 = _slang_select(_S1009, _S1095,_S883.smooth_n);
                NEEVertex _S1097 = NEEVertex_x24init_0(false, _S1090, _S1091, _S1092, _S1093 + make_float3 (_S1094.geometry_offset) * _S1096);
                nee_vertex_0 = _S1097;
            }
            else
            {
                if(_S890)
                {
                    _S1012 = true;
                }
                else
                {
                    bool _S1098 = b_6 != 1U;
                    if(_S1098)
                    {
                        _S1012 = true;
                    }
                    else
                    {
                        _S1012 = (_S885.x) != (_S885.y);
                    }
                }
                if(_S1012)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1099 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1099)
            {
                if(_S961)
                {
                    _S1012 = true;
                }
                else
                {
                    _S1012 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_1)->distance * (&hit_1)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1012 = false;
            }
            bool _S1100 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1100)
            {
                if(_S961)
                {
                    _S1013 = true;
                }
                else
                {
                    _S1013 = (_S882.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1013 = false;
            }
            if(_S922)
            {
                bool _S1101 = !_S1012;
                if(_S1101)
                {
                    return _S709;
                }
                bool _S1102 = _S714 != 1U;
                if(_S1102)
                {
                    _S1014 = _S714 != 2U;
                }
                else
                {
                    _S1014 = false;
                }
                if(_S1014)
                {
                    float _S1103 = (&lobe_5)->pdf;
                    float _S1104 = _slang_select(nee_0, _S1103,0.0f);
                    float _S1105 = escapeWeight_0(_S1104, _S1022);
                    if(_S930)
                    {
                        passes_0 = _S720;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1106 = _slang_select(passes_0, _S1105,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_1->radiance * make_float3 (_S1106) / make_float3 (r_1->jac), density_4 * (&lobe_5)->pdf / r_1->jac);
                }
                float3  _S1107 = throughput_6 * make_float3 ((&lobe_5)->pdf);
                float _S1108 = density_4 * (&lobe_5)->pdf;
                throughput_9 = _S1107;
                density_6 = _S1108;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1109 = (fcptLayers((hit_1)));
            bool _S1110 = _S1109 > 1U;
            if(_S1110)
            {
                _S1014 = (b_6 == 1U) != passes_0;
            }
            else
            {
                _S1014 = false;
            }
            if(viewed_1)
            {
                _S1015 = _S1014;
            }
            else
            {
                _S1015 = false;
            }
            if(_S1015)
            {
                return _S709;
            }
            if(replay_0)
            {
                _S1016 = b_3 <= _S724;
            }
            else
            {
                _S1016 = false;
            }
            if(_S1016)
            {
                _S1017 = _S881;
            }
            else
            {
                _S1017 = false;
            }
            if(_S1017)
            {
                _S1018 = _S1012;
            }
            else
            {
                _S1018 = false;
            }
            bool _S1111;
            if(_S1018)
            {
                _S1111 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1111 = !_S1013;
                }
                else
                {
                    _S1111 = false;
                }
            }
            if(_S1111)
            {
                return _S709;
            }
            if(viewed_1)
            {
                float3  _S1112 = throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1113 = (&lobe_5)->pdf;
                throughput_10 = _S1112;
                sky_pdf_2 = _S1113;
            }
            else
            {
                float3  _S1114 = throughput_9 * max_0((&lobe_5)->throughput, _S708);
                throughput_10 = _S1114;
                sky_pdf_2 = density_6;
            }
            bool _S1115;
            if(_S899)
            {
                _S1115 = !_S913;
            }
            else
            {
                _S1115 = false;
            }
            bool _S1116;
            if(_S1115)
            {
                _S1116 = _S881;
            }
            else
            {
                _S1116 = false;
            }
            bool _S1117;
            if(_S1116)
            {
                _S1117 = _S1012;
            }
            else
            {
                _S1117 = false;
            }
            if(_S1117)
            {
                chain_0 = here_0;
                uint _S1118 = insertBits_0((&chain_0)->path, b_6, 18U, 3U);
                uint _S1119 = _slang_select(nee_0, 1U,0U);
                uint _S1120 = insertBits_0(_S1118, _S1119, 21U, 1U);
                (&chain_0)->path = _S1120;
                float _S1121 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1121;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1122 = surface_12;
            Vertex _S1123 = Vertex_x24init_0(_S1013, b_6, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1123;
            float _S1124 = (&lobe_5)->pdf;
            bool _S1125 = b_6 == 1U;
            bool _S1126;
            if(_S1125)
            {
                _S1126 = (_S885.x) == (_S885.y);
            }
            else
            {
                _S1126 = false;
            }
            float sky_pdf_3 = _slang_select(_S1126, sky_pdf_0,_S1124);
            float _S1127 = _slang_select(_S890, 0.0f,sky_pdf_3);
            float _S1128 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1129 = !_S1003;
            float _S1130 = _slang_select(_S1129, _S1128,0.0f);
            float _S1131 = spread_0 + _S1130;
            bool _S1132;
            if(refracted_4)
            {
                _S1132 = !_S1009;
            }
            else
            {
                _S1132 = false;
            }
            bool is_inside_7;
            if(_S1132)
            {
                bool _S1133 = !is_inside_6;
                is_inside_7 = _S1133;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1134 = surface_12;
            bool _S1135 = boundsVolume_0(&_S1134);
            bool _S1136;
            if(_S1135)
            {
                _S1136 = !_S1014;
            }
            else
            {
                _S1136 = false;
            }
            if(_S1136)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1137 = - _S1122.geometry_n;
                float3  _S1138 = _slang_select(turned_1, _S1137,_S1122.geometry_n);
                (&faced_2)->geometry_n = _S1138;
                FKMedium _S1139 = Medium_x24init_0(scatter_in_0, extinction_in_0);
                FKSurface _S1140 = faced_2;
                FKMedium _S1141 = _S1139;
                MediumSides _S1142 = mediumSides_0(&_S1140, &_S1141, filling_2, (&ray_2)->unit_direction);
                bool _S1143 = ((dot_0(throughput_8, _S1122.geometry_n)) > 0.0f) == ((dot_0(_S1122.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1144 = _slang_select(_S1143, _S1142.front.scatter,_S1142.behind.scatter);
                scatter_in_0 = _S1144;
                float3  _S1145 = _slang_select(_S1143, _S1142.front.extinction,_S1142.behind.extinction);
                extinction_in_0 = _S1145;
                uint _S1146 = _S1142.fillings.x;
                uint _S1147 = _S1142.fillings.y;
                uint _S1148 = _slang_select(_S1143, _S1147,_S1146);
                bool _S1149 = (fcptVaryingUsed());
                uint _S1150 = _slang_select(_S1149, _S1148,4294967295U);
                filling_2 = _S1150;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1151 = !_S1014;
            if(_S1151)
            {
                FKSurface _S1152 = surface_12;
                float _S1153 = _slang_select(straight_0, 0.0f,_S1152.geometry_offset);
                float3  _S1154 = - _S883.smooth_n;
                bool _S1155 = is_inside_7 != _S1009;
                float3  _S1156 = _slang_select(_S1155, _S1154,_S883.smooth_n);
                float3  _S1157 = (&ray_2)->origin + make_float3 (_S1153) * _S1156;
                (&ray_2)->origin = _S1157;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1014;
            viewed_1 = _S1007;
            sky_pdf_2 = _S1127;
            spread_3 = _S1131;
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
        if(_S899)
        {
            if(_S849)
            {
                float3  _S1158 = throughput_9 * emission_1;
                Reservoir candidate_7 = chain_0;
                uint _S1159 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1160 = _S1159 == 1U;
                if(_S1160)
                {
                    float3  _S1161 = safeDivide(_S1158, chain_throughput_0);
                    (&candidate_7)->radiance = _S1161;
                }
                Reservoir _S1162 = withEnd(candidate_7, 2U, b_3, _S1158);
                offer(sel_1, _S1162, _S1158 * make_float3 (scale_1) / make_float3 (density_6));
            }
            if(_S849)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1163 = survivalProbability(throughput_9, density_6);
                density_7 = _S1163;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1164 = stream(_S736, b_3 + 128U);
            Random _S1165 = pcg(_S1164);
            bool _S1166 = density_7 < (_S1165.value);
            if(_S1166)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1167 = (fcptMaxBounces());
                wrong_side_0 = b_3 >= _S1167;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1168 = density_6 * density_7;
            density_7 = _S1168;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1169 = layer_0 ^ 1U;
        uint _S1170 = _slang_select(passes_0, _S1169,0U);
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
            uint _S1171 = b_6 + 1U;
            b_3 = _S1171;
            layer_0 = _S1170;
            continue;
        }
        FKRay _S1172 = ray_2;
        float _S1173 = distance_3(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_0)
        {
            refracted_4 = _S923;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S713 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1174 = _slang_select(wrong_side_0, _S1173,4.294967296e+09f);
        bool _S1175 = !_S890;
        if(straight_0)
        {
            _S960 = true;
        }
        else
        {
            _S960 = _S890;
        }
        FKHit _S1176;
        if(_S960)
        {
            _S1176 = hit_1;
        }
        else
        {
            _S1176 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
        }
        FKHit _S1177 = (fcptTraverseInstanceBVH((_S1172), (_S856), (_S1174), (_S1175), (_S1176), (viewed_1)));
        hit_1 = _S1177;
        if(replay_0)
        {
            _S961 = _S923;
        }
        else
        {
            _S961 = false;
        }
        if(_S961)
        {
            _S1003 = _S713 == 1U;
        }
        else
        {
            _S1003 = false;
        }
        if(_S1003)
        {
            _S1004 = ((&hit_1)->instance_index) == (_S725.instance_index);
        }
        else
        {
            _S1004 = false;
        }
        if(_S1004)
        {
            _S1005 = ((&hit_1)->triangle_index) == (_S725.triangle_index);
        }
        else
        {
            _S1005 = false;
        }
        if(_S1005)
        {
            (&hit_1)->uv = _S725.uv;
            float _S1178 = distance_3(reconnection_0, (&ray_2)->origin);
            (&hit_1)->distance = _S1178;
        }
        if(replay_0)
        {
            _S1006 = _S923;
        }
        else
        {
            _S1006 = false;
        }
        if(_S1006)
        {
            _S1007 = _S713 == 3U;
        }
        else
        {
            _S1007 = false;
        }
        if(_S1007)
        {
            _S1008 = ((&hit_1)->instance_index) != 4294967295U;
        }
        else
        {
            _S1008 = false;
        }
        if(_S1008)
        {
            return _S709;
        }
        Reservoir _S1179 = chain_0;
        uint _S1180 = filling_2;
        for(;;)
        {
            bool _S1181 = (fcptVaryingUsed());
            if(_S1181)
            {
                _S1009 = _S1180 != 4294967295U;
            }
            else
            {
                _S1009 = false;
            }
            float _S1182;
            if(_S1009)
            {
                float _S1183 = (fcptMajorant((_S1180)));
                _S1182 = _S1183;
            }
            else
            {
                _S1182 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_0)
            {
                _S1010 = _S923;
            }
            else
            {
                _S1010 = false;
            }
            if(_S1010)
            {
                _S1011 = _S713 == 1U;
            }
            else
            {
                _S1011 = false;
            }
            if(_S1011)
            {
                _S1012 = _S1182 > 0.0f;
            }
            else
            {
                _S1012 = false;
            }
            if(_S1012)
            {
                ended_0 = _S709;
                sky_pdf_1 = sky_pdf_2;
                spread_1 = spread_3;
                width_3 = width_2;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_6 = b_3;
                _S1013 = true;
                break;
            }
            bool _S1184 = (&prev_0)->rough;
            if(_S1184)
            {
                _S1013 = !(_S1182 > 0.0f);
            }
            else
            {
                _S1013 = false;
            }
            (&prev_0)->rough = _S1013;
            uint _S1185 = b_3 + 320U;
            bool _S1186 = b_3 == 4294967295U;
            uint _S1187 = _slang_select(_S1186, 384U,_S1185);
            uint _S1188 = stream(_S736, _S1187);
            uint tracking_1 = _S1188;
            weight_1 = throughput_3;
            glowed_0 = _S708;
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
                    _S707 = int(2);
                    break;
                }
                uint _S1189 = b_6 + 320U;
                bool _S1190 = b_6 == 4294967295U;
                uint _S1191 = _slang_select(_S1190, 384U,_S1189);
                uint _S1192 = stream(_S736, _S1191);
                Random _S1193 = pcg(_S1192);
                float _S1194 = - (F32_log((1.0f - _S1193.value))) / _S1182;
                if(_S1009)
                {
                    float3  _S1195 = (&ray_2)->origin;
                    float3  _S1196 = (&ray_2)->unit_direction;
                    float _S1197 = (&hit_1)->distance;
                    uint _S1198 = _slang_select(_S1190, 0U,b_6);
                    uint _S1199 = (&prev_0)->lobe;
                    uint _S1200 = _slang_select(_S1190, 3U,_S1199);
                    float _S1201 = (fcptTrackMedium((_S1180), (_S1195), (_S1196), (_S1197), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S1198), (_S1200), (_S1190)));
                    spread_2 = _S1201;
                }
                else
                {
                    spread_2 = _S1194;
                }
                bool _S1202 = !(spread_2 < ((&hit_1)->distance));
                if(_S1202)
                {
                    _S707 = int(2);
                    break;
                }
                if(_S1009)
                {
                    _S1014 = _S899;
                }
                else
                {
                    _S1014 = false;
                }
                if(_S1014)
                {
                    float3  _S1203 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1204 = sel_1->glow + _S1203;
                    sel_1->glow = _S1204;
                }
                else
                {
                }
                glowed_0 = _S708;
                uint b_7 = b_6 + 1U;
                float3  _S1205 = (&ray_2)->origin + make_float3 (spread_2) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1205;
                float3  _S1206 = flightWeight_0(scatter_in_0, extinction_in_0, _S1182, spread_2, true);
                float3  _S1207 = weight_1;
                float3  _S1208 = _slang_select(_S1009, _S1207,_S1206);
                float3  throughput_11 = throughput_10 * _S1208;
                uint _S1209 = stream(_S736, b_7 + 320U);
                tracking_1 = _S1209;
                weight_1 = throughput_3;
                float width_6 = width_3 + spread_1 * spread_2;
                float _S1210 = spread_1 + 3.14159274101257324f;
                if(_S899)
                {
                    _S1015 = true;
                }
                else
                {
                    bool _S1211 = b_7 == _S724;
                    if(_S1211)
                    {
                        _S1015 = !_S1009;
                    }
                    else
                    {
                        _S1015 = false;
                    }
                }
                TreeSample light_4;
                if(_S1015)
                {
                    float3  _S1212 = (&ray_2)->origin;
                    float3  _S1213 = (&ray_2)->unit_direction;
                    float3  _S1214 = (&ray_2)->unit_direction;
                    uint _S1215 = stream(_S736, b_7 + 64U);
                    float3  _S1216 = extinction_in_0;
                    float3  _S1217 = extinction_in_0;
                    uint2  _S1218 = make_uint2 (_S1180);
                    float3  _S1219 = (&ray_2)->unit_direction;
                    uint _S1220 = arrivalLobe_0(b_7, (&prev_0)->lobe);
                    FKHit _S1221 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                    FKHit _S1222 = _S1221;
                    ShadowContext _S1223 = ShadowContext_x24init_0(_S1216, _S1217, _S1218, _S1219, b_7, _S1220, false, spread_2, width_6, &_S1222, false);
                    ShadowContext _S1224 = _S1223;
                    TreeSample _S1225 = sampleLightTree_0(_S1212, _S1213, _S1214, 0.0f, true, _S1215, &_S1224);
                    light_4 = _S1225;
                }
                else
                {
                    light_4 = _S937;
                }
                uint _S1226 = (fcptMaxBounces());
                bool _S1227 = b_7 < _S1226;
                if(_S1227)
                {
                    _S1016 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1016 = false;
                }
                float _S1228 = _slang_select(_S1016, 0.07957746833562851f,0.0f);
                float3  _S1229 = throughput_11 * light_4.radiance;
                float _S1230 = powerHeuristic(light_4.density, _S1228);
                float3  _S1231 = _S1229 * make_float3 (0.07957746833562851f * _S1230);
                float3  _S1232 = _slang_select(_S1015, _S1231,_S708);
                if(replay_0)
                {
                    _S1017 = b_7 == _S724;
                }
                else
                {
                    _S1017 = false;
                }
                if(_S1017)
                {
                    bool _S1233 = _S713 == 2U;
                    if(_S1233)
                    {
                        float _S1234 = rgb_to_greyscale(_S1232);
                        _S1018 = _S1234 > 0.0f;
                    }
                    else
                    {
                        _S1018 = false;
                    }
                    if(_S1018)
                    {
                        Shift _S1235 = Shift_x24init_0(_S1232, 1.0f);
                        _S707 = int(1);
                        ended_0 = _S1235;
                        spread_2 = _S1210;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_4 = b_7;
                        break;
                    }
                    _S707 = int(1);
                    ended_0 = _S709;
                    spread_2 = _S1210;
                    width_4 = width_6;
                    throughput_8 = throughput_11;
                    b_4 = b_7;
                    break;
                }
                if(_S899)
                {
                    Reservoir candidate_8 = _S1179;
                    uint _S1236 = extractBits_0(_S1179.path, 10U, 2U);
                    bool _S1237 = _S1236 == 1U;
                    if(_S1237)
                    {
                        float3  _S1238 = safeDivide(_S1232, chain_throughput_0);
                        (&candidate_8)->radiance = _S1238;
                    }
                    else
                    {
                        uint _S1239 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                        uint _S1240 = insertBits_0(_S1239, 2U, 10U, 2U);
                        (&candidate_8)->path = _S1240;
                    }
                    Reservoir _S1241 = withEnd(candidate_8, 0U, b_7, _S1232);
                    offer(sel_1, _S1241, _S1232 * make_float3 (scale_1) / make_float3 (density_3));
                    float _S1242 = survivalProbability(throughput_11, density_3);
                    uint _S1243 = stream(_S736, b_7 + 128U);
                    Random _S1244 = pcg(_S1243);
                    bool _S1245 = _S1242 < (_S1244.value);
                    if(_S1245)
                    {
                        _S1018 = true;
                    }
                    else
                    {
                        uint _S1246 = (fcptMaxBounces());
                        _S1018 = b_7 >= _S1246;
                    }
                    if(_S1018)
                    {
                        _S707 = int(1);
                        ended_0 = _S709;
                        spread_2 = _S1210;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_4 = b_7;
                        break;
                    }
                    float _S1247 = density_3 * _S1242;
                    density_3 = _S1247;
                }
                else
                {
                }
                NEEVertex _S1248 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_2)->origin, _S708, (&ray_2)->origin);
                nee_vertex_0 = _S1248;
                uint _S1249 = stream(_S736, b_7);
                float3  _S1250 = isotropic_0(_S1249);
                (&ray_2)->unit_direction = _S1250;
                Vertex _S1251 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
                prev_0 = _S1251;
                float _S1252 = (&prev_0)->pdf;
                FKRay _S1253 = ray_2;
                FKHit _S1254 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1255 = (fcptTraverseInstanceBVH((_S1253), (true), (4.294967296e+09f), (false), (_S1254), (false)));
                hit_1 = _S1255;
                b_6 = b_7;
                throughput_10 = throughput_11;
                spread_1 = _S1210;
                width_3 = width_6;
                sky_pdf_1 = _S1252;
            }
            if(_S707 != int(2))
            {
                spread_1 = spread_2;
                width_3 = width_4;
                throughput_10 = throughput_8;
                b_6 = b_4;
                _S1013 = true;
                break;
            }
            ended_0 = _S709;
            _S1013 = false;
            break;
        }
        if(_S1013)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1014 = b_6 == b_3;
        }
        else
        {
            _S1014 = false;
        }
        bool _S1256 = ((&hit_1)->instance_index) == 4294967295U;
        if(_S1256)
        {
            bool _S1257 = !(&nee_vertex_0)->none;
            float _S1258 = _slang_select(_S1257, sky_pdf_1,0.0f);
            float _S1259 = escapeWeight_0(_S1258, (&ray_2)->unit_direction);
            float3  _S1260 = environment_0((&ray_2)->unit_direction, b_6, (&prev_0)->lobe);
            float3  _S1261 = throughput_10 * _S1260;
            if(replay_0)
            {
                bool _S1262 = b_6 == _S724;
                if(_S1262)
                {
                    passes_0 = _S713 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1261 * make_float3 (_S1259) / make_float3 (r_1->jac), density_3 / r_1->jac);
                }
                if(_S723)
                {
                    passes_0 = _S720;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_6 == _S711;
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
                    return Shift_x24init_0(_S1261 * make_float3 (_S1259), 1.0f);
                }
                return _S709;
            }
            Reservoir candidate_9 = chain_0;
            uint _S1263 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1264 = _S1263 == 1U;
            if(_S1264)
            {
                uint _S1265 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1266 = _S1265 == b_6;
                float _S1267 = _slang_select(_S1266, 1.0f,_S1259);
                float3  _S1268 = safeDivide(_S1261 * make_float3 (_S1267), chain_throughput_0);
                (&candidate_9)->radiance = _S1268;
            }
            else
            {
                bool _S1269 = (&prev_0)->rough;
                if(_S1269)
                {
                    uint _S1270 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                    uint _S1271 = insertBits_0(_S1270, 3U, 10U, 2U);
                    uint _S1272 = insertBits_0(_S1271, (&prev_0)->lobe, 15U, 3U);
                    bool _S1273 = (&prev_0)->inside;
                    uint _S1274 = _slang_select(_S1273, 1U,0U);
                    uint _S1275 = insertBits_0(_S1272, _S1274, 22U, 1U);
                    (&candidate_9)->path = _S1275;
                    (&candidate_9)->jac = (&prev_0)->pdf;
                    (&candidate_9)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1276 = _S1261 * make_float3 (_S1259);
            Reservoir _S1277 = withEnd(candidate_9, 3U, b_6, _S1276);
            offer(sel_1, _S1277, _S1276 * make_float3 (scale_1) / make_float3 (density_3));
            break;
        }
        float3  _S1278 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1278;
        bool _S1279 = (fcptVaryingUsed());
        if(_S1279)
        {
            _S1015 = filling_2 != 4294967295U;
        }
        else
        {
            _S1015 = false;
        }
        if(_S1015)
        {
            if(_S899)
            {
                float3  _S1280 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1281 = sel_1->glow + _S1280;
                sel_1->glow = _S1281;
            }
            float3  _S1282 = throughput_10 * weight_1;
            throughput_8 = _S1282;
        }
        else
        {
            float3  _S1283 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
            float3  _S1284 = throughput_10 * _S1283;
            throughput_8 = _S1284;
        }
        float _S1285 = width_3 + spread_1 * (&hit_1)->distance;
        viewed_0 = _S1014;
        width_2 = _S1285;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_0 = spread_1;
        uint _S1171 = b_6 + 1U;
        b_3 = _S1171;
        layer_0 = _S1170;
    }
    return _S709;
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
    Random _S1286 = pcg(state_3);
    Random _S1287 = pcg(_S1286.state);
    float _S1288 = 6.28318548202514648f * _S1286.value;
    float _S1289 = (F32_sqrt((-2.0f * clamp_0((F32_log((_S1287.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1287.state, _S1289 * (F32_cos((_S1288))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1290;
    (&_S1290)->state = state_4;
    (&_S1290)->value = value_2;
    return _S1290;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1291 = normal_distribution(state_5);
    Random _S1292 = normal_distribution(_S1291.state);
    Random _S1293 = normal_distribution(_S1292.state);
    float3  _S1294 = make_float3 (_S1291.value, _S1292.value, _S1293.value);
    float3  _S1295 = ((((_S1294)) * make_float3(rnorm3df(((_S1294)).x, ((_S1294)).y, ((_S1294)).z))));
    return RandomSphere_x24init_0(_S1293.state, _S1295);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_12)
{
    float3  _S1296 = p1_0 - p0_0;
    float3  _S1297 = p2_0 - p0_0;
    float2  _S1298 = uv1_0 - uv0_0;
    float2  _S1299 = uv2_0 - uv0_0;
    float _S1300 = _S1298.x;
    float _S1301 = _S1299.y;
    float _S1302 = _S1298.y;
    float _S1303 = _S1299.x;
    float _S1304 = _S1300 * _S1301 - _S1302 * _S1303;
    float _S1305 = 1.0f / _S1304;
    float3  t_1 = (_S1296 * make_float3 (_S1301) - _S1297 * make_float3 (_S1302)) * make_float3 (_S1305);
    float3  _S1306 = (_S1297 * make_float3 (_S1300) - _S1296 * make_float3 (_S1303)) * make_float3 (_S1305);
    float3  _S1307 = t_1 - n_12 * make_float3 (dot_0(n_12, t_1));
    float3  t_2 = ((((_S1307)) * make_float3(rnorm3df(((_S1307)).x, ((_S1307)).y, ((_S1307)).z))));
    bool _S1308 = (dot_0(cross_0(n_12, t_2), _S1306)) > 0.0f;
    float3  t_3;
    if(_S1308)
    {
        float3  _S1309 = negate_0(t_2);
        t_3 = _S1309;
    }
    else
    {
        t_3 = t_2;
    }
    float3  _S1310 = cross_0(n_12, t_3);
    return makeMatrix<float, 3, 3> (t_3, _S1310, n_12);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_0)
{
    float3  _S1311 = t1_0 - t0_0;
    float3  _S1312 = t2_2 - t0_0;
    float3  _S1313 = t2_2 - t1_0;
    float _S1314 = (F32_min((length_0(_S1311)), ((F32_min((length_0(_S1312)), (length_0(_S1313)))))));
    float3  _S1315 = make_float3 (distance_3(position_0, t0_0), distance_3(position_0, t1_0), distance_3(position_0, t2_2));
    float3  _S1316 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1317 = dot_0(geometry_n_4, _S1316);
    float3  _S1318 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1319 = dot_0(geometry_n_4, _S1318);
    float3  _S1320 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1321 = acos_0(abs_0(make_float3 (_S1317, _S1319, dot_0(geometry_n_4, _S1320))));
    float3  _S1322 = clamp_1(tan_0(_S1321), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_0(dot_0(_S1315 * _S1322, uvw_0), 0.0f, _S1314 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_13, float3  n_13, BSDFMaterial material_21)
{
    float3  _S1323 = negate_0(dir_13);
    float _S1324 = sign_0(dot_0(n_13, _S1323));
    float3  _S1325 = n_13 * make_float3 (_S1324);
    AnisotropicFrame _S1326 = anisotropicFrame(material_21, _S1325);
    bool _S1327 = (_S1326.alphas.x) > 0.0f;
    if(_S1327)
    {
        float _S1328 = material_21.transmission * (1.0f - material_21.metallic);
        float3  _S1329 = negate_0(_S1325);
        float3  _S1330 = anisotropicLocal(dir_13, _S1326.tangent, _S1329);
        float _S1331 = anisotropicG1(_S1330, _S1326.alphas);
        return make_float3 (_S1328 * _S1331) * material_21.albedo;
    }
    float _S1332 = material_21.transmission * (1.0f - material_21.metallic);
    float _S1333 = material_21.roughness;
    float _S1334 = smithG1(_S1333 * _S1333, (F32_abs((dot_0(n_13, dir_13)))));
    return make_float3 (_S1332 * _S1334) * material_21.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_4, float3  out_dir_3, uint p_5, float w_2, float alpha_17, uint nt_0)
{
    uint _S1335 = p_5 % 4U;
    float _S1336 = w_2 * HAIR_WIDTHS_0[_S1335];
    float _S1337 = (F32_asin((clamp_0(dot_0(out_dir_3, t_4), -1.0f, 1.0f)))) - (F32_asin((clamp_0(dot_0(in_dir_11, t_4), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1335] * alpha_17;
    return ((F32_asinh((_S1337 / _S1336))) / (F32_asinh((3.14159274101257324f / _S1336))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_5, float3  out_dir_4, uint np_0)
{
    float3  _S1338 = worldToTangent(out_dir_4, t_5);
    float3  _S1339 = worldToTangent(in_dir_12, t_5);
    return (F32_frac((((F32_atan2((_S1338.z), (_S1338.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1339.z), (1.17549435082228751e-38f - _S1339.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_6, uint p_6, float row_0, float column_0, float w_3, float alpha_18, uint nt_1, uint np_1)
{
    float3  _S1340 = worldToTangent(in_dir_13, t_6);
    uint _S1341 = p_6 % 4U;
    float _S1342 = w_3 * HAIR_WIDTHS_0[_S1341];
    float _S1343 = (F32_asin((clamp_0(dot_0(in_dir_13, t_6), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1341] * alpha_18 + _S1342 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1342))))));
    float _S1344 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1340.z), (1.17549435082228751e-38f - _S1340.x)));
    float _S1345 = (F32_cos((_S1343)));
    float3  _S1346 = tangentToWorld(make_float3 (_S1345 * (F32_cos((_S1344))), (F32_sin((_S1343))), _S1345 * (F32_sin((_S1344)))), t_6);
    return _S1346;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_14, BSDFMaterial material_22, float coverage_1)
{
    float3  _S1347;
    if((material_22.ior) == 1.0f)
    {
        float3  _S1348 = straightThrough(toward_1, n_14, material_22);
        _S1347 = _S1348;
    }
    else
    {
        _S1347 = make_float3 (0.0f);
    }
    return _S1347 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ void offerShifted(Selection * sel_2, Reservoir r_2, Shift shifted_0, float mis_0)
{
    Reservoir candidate_10 = r_2;
    float3  _S1349 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_10)->f = _S1349;
    float _S1350 = r_2.jac * shifted_0.jac;
    (&candidate_10)->jac = _S1350;
    offer(sel_2, candidate_10, make_float3 (mis_0) * shifted_0.f * make_float3 (r_2.w));
    return;
}

__device__ Reservoir finalize(Selection sel_3, float c_1)
{
    Reservoir r_3 = sel_3.r;
    float _S1351 = rgb_to_greyscale((&r_3)->f);
    float _S1352 = sel_3.w_sum / _S1351;
    bool _S1353 = _S1351 > 0.0f;
    float _S1354 = _slang_select(_S1353, _S1352,0.0f);
    (&r_3)->w = _S1354;
    (&r_3)->c = c_1;
    return r_3;
}

__device__ Shift walk_hook(Domain dom_1, Reservoir r_4, bool replay_1, float scale_2, Selection * sel_4)
{
    Domain _S1355 = dom_1;
    Reservoir _S1356 = r_4;
    Shift _S1357 = walk_0(&_S1355, &_S1356, replay_1, scale_2, sel_4);
    return _S1357;
}

#undef Matrix
