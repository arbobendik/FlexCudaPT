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
        bool _S225 = eta_i_1 == eta_o_1;
        float _S226 = _slang_select(_S225, cos_theta_0,_S224);
        float _S227 = eta_o_1 * cos_theta_0;
        float _S228 = eta_i_1 * _S226;
        float _S229 = (_S227 - _S228) / (_S227 + _S228);
        float _S230 = eta_i_1 * cos_theta_0;
        float _S231 = eta_o_1 * _S226;
        float _S232 = (_S230 - _S231) / (_S230 + _S231);
        float _S233 = (_S229 * _S229 + _S232 * _S232) / 2.0f;
        kr_0 = _S233;
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
    float _S234 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S234 / (_S234 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S234)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S235 = alphas_3.x;
    float _S236 = h_0.x / _S235;
    float _S237 = alphas_3.y;
    float _S238 = h_0.y / _S237;
    float _S239 = h_0.z;
    float _S240 = _S236 * _S236 + _S238 * _S238 + _S239 * _S239;
    return 1.0f / (F32_max((3.14159274101257324f * _S235 * _S237 * _S240 * _S240), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_4, float3  n_i_3, float3  ggx_n_0, BSDFMaterial material_3, float eta_i_2, float eta_o_2, AnisotropicFrame frame_2, SheenProfile sheen_profile_0)
{
    float _S241 = dot_0(ggx_n_0, v_4);
    float _S242 = dot_0(n_i_3, ggx_n_0);
    float _S243 = eta_i_2 / eta_o_2;
    float3  _S244 = refract_0(in_dir_3, ggx_n_0, _S243);
    float3  _S245 = ((((_S244)) * make_float3(rnorm3df(((_S244)).x, ((_S244)).y, ((_S244)).z))));
    float _S246 = (F32_min(((F32_sqrt((material_3.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S247 = _S246 * _S246;
    float _S248 = (1.0f + _S246) / (1.0f - _S246);
    float _S249 = (F32_abs((_S241)));
    bool _S250 = eta_i_2 > eta_o_2;
    float sheen_component_0;
    if(_S250)
    {
        sheen_component_0 = _S248;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float visible_1;
    if(_S250)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S248;
    }
    float _S251 = fresnel(_S249, sheen_component_0, visible_1);
    bool _S252 = (eta_i_2 * eta_i_2 * (1.0f - _S241 * _S241)) >= (eta_o_2 * eta_o_2);
    float3  _S253;
    if(_S252)
    {
        _S253 = make_float3 (1.0f);
    }
    else
    {
        float3  _S254 = material_3.specular_tint * make_float3 (_S247);
        _S253 = _S254 + (make_float3 (1.0f) - _S254) * make_float3 (_S251 - _S247) / make_float3 (1.0f - _S247);
    }
    float3  _S255 = make_float3 (1.0f);
    float3  _S256 = make_float3 (0.0f);
    float3  scale_0;
    float3  sheen_1;
    float3  view_1;
    if(sheen_profile_0.on)
    {
        float _S257 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S258 = make_float3 (1.0f) - material_3.sheen * make_float3 (_S257);
        float _S259 = rgb_to_greyscale(material_3.sheen);
        float _S260 = _S259 * _S257;
        float3  _S261 = material_3.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        scale_0 = _S258;
        sheen_component_0 = _S260;
        sheen_1 = _S261;
        view_1 = v_4;
    }
    else
    {
        scale_0 = _S255;
        sheen_component_0 = 0.0f;
        sheen_1 = _S256;
        view_1 = _S256;
    }
    float3  _S262 = mix_0(_S253, material_3.albedo, material_3.metallic);
    float3  F_1 = _S262 * scale_0;
    float _S263 = rgb_to_greyscale(F_1);
    float _S264 = 1.0f - material_3.metallic;
    float3  _S265 = make_float3 (1.0f) - _S253;
    float3  _S266 = make_float3 ((1.0f - material_3.transmission) * _S264) * _S265 * scale_0;
    float3  _S267 = make_float3 (material_3.transmission * _S264) * _S265 * scale_0;
    float _S268 = (F32_max((_S263), (0.0f)));
    float _S269 = rgb_to_greyscale(_S266);
    float _S270 = (F32_max((_S269), (0.0f)));
    float _S271 = rgb_to_greyscale(_S267);
    float _S272 = sign_0(length_0(_S245));
    float _S273 = (F32_max((_S271 * _S272), (0.0f)));
    float _S274 = _S268 + _S270 + _S273;
    float _S275 = (F32_min((sheen_component_0), (1.0f)));
    bool _S276 = sheen_component_0 > 0.0f;
    bool _S277;
    if(_S276)
    {
        _S277 = !(_S274 > 0.0f);
    }
    else
    {
        _S277 = false;
    }
    float _S278 = _slang_select(_S277, 1.0f,_S275);
    float _S279 = (1.0f - _S278) / (F32_max((_S274), (0.0000152587890625f)));
    float _S280 = _S270 * _S279;
    float _S281 = _S268 * _S279;
    float _S282 = _S273 * _S279;
    bool _S283 = (frame_2.alphas.x) > 0.0f;
    if(_S283)
    {
        float3  _S284 = anisotropicLocal(v_4, frame_2.tangent, n_i_3);
        float _S285 = anisotropicG1(_S284, frame_2.alphas);
        float3  _S286 = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        float _S287 = anisotropicD(_S286, frame_2.alphas);
        float _S288 = _S285 * _S287;
        visible_1 = _S288;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S241, _S242, _S245, F_1, _S263, 1.0f, _S266, _S267, _S280, _S281, _S282, 0.0f, sheen_1, _S278, view_1, frame_2.tangent, frame_2.alphas, visible_1);
}

__device__ float translucentShare(BSDFMaterial material_4)
{
    float _S289 = rgb_to_greyscale(material_4.translucent);
    float _S290 = rgb_to_greyscale(material_4.albedo);
    float _S291 = _S289 / (_S290 + _S289);
    bool _S292 = _S289 > 0.0f;
    float _S293 = _slang_select(_S292, _S291,0.0f);
    return _S293;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_2, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S294 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S295 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S296 = 1.0f - lobes_0.translucent_share;
    bool _S297 = n_i_dot_l_0 < 0.0f;
    float _S298 = _slang_select(_S297, lobes_0.translucent_share,_S296);
    float _S299 = _S295 * _S298;
    bool _S300 = (lobes_0.translucent_share) > 0.0f;
    float _S301 = _slang_select(_S300, _S299,_S294);
    bool _S302 = n_i_dot_v_0 > 0.0f;
    float _S303 = _slang_select(_S302, _S301,0.0f);
    return _S303;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_4, float alpha_3, BSDFMaterial material_5, BSDFLobes lobes_1)
{
    bool _S304 = (dot_0(n_i_4, l_0)) < 0.0f;
    float3  _S305 = _slang_select(_S304, material_5.translucent,material_5.albedo);
    float _S306 = 1.0f - lobes_1.translucent_share;
    float _S307 = _slang_select(_S304, lobes_1.translucent_share,_S306);
    float3  _S308 = _S305 / make_float3 (_S307);
    bool _S309 = (lobes_1.translucent_share) > 0.0f;
    float3  _S310 = _slang_select(_S309, _S308,material_5.albedo);
    return lobes_1.diffuse_weight * _S310 / make_float3 (lobes_1.p_diffuse);
}

__device__ float smithG1(float alpha_4, float n_dot_x_0)
{
    float _S311 = alpha_4 * alpha_4;
    float _S312 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S311 + (1.0f - _S311) * n_dot_x_0 * n_dot_x_0))));
    bool _S313 = alpha_4 > 0.0f;
    float _S314 = _slang_select(_S313, _S312,1.0f);
    return _S314;
}

__device__ float trowbridgeReitz(float alpha_5, float n_dot_h_1)
{
    float _S315 = alpha_5 * alpha_5;
    float _S316 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S315 * n_dot_h_1 * n_dot_h_1;
    return _S315 / (F32_max((3.14159274101257324f * _S316 * _S316), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S317 = smithG1(alpha_6, n_i_dot_v_1);
    float _S318 = _S317 * lobes_2.v_dot_h;
    float _S319 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S320 = _S318 * _S319 / n_i_dot_v_1;
    bool _S321 = alpha_6 > 0.0f;
    bool _S322;
    if(_S321)
    {
        _S322 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S322 = false;
    }
    if(_S322)
    {
        _S322 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S322 = false;
    }
    if(_S322)
    {
        _S322 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S322 = false;
    }
    float _S323 = _slang_select(_S322, _S320,0.0f);
    bool _S324 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S324)
    {
        float _S325 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S326 = (lobes_2.v_dot_h) > 0.0f;
        if(_S326)
        {
            _S322 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S322 = false;
        }
        if(_S322)
        {
            _S322 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S322 = false;
        }
        float _S327 = _slang_select(_S322, _S325,0.0f);
        pdf_h_0 = _S327;
    }
    else
    {
        pdf_h_0 = _S323;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S328 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S329 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S330 = lobes_3.p_refract * _S328 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S329 * _S329);
    bool _S331 = eta_i_4 != eta_o_4;
    bool _S332;
    if(_S331)
    {
        _S332 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S332 = false;
    }
    float _S333 = _slang_select(_S332, _S330,0.0f);
    return _S333;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_5, float alpha_8, BSDFMaterial material_6, BSDFLobes lobes_4)
{
    float _S334 = - dot_0(n_i_5, l_1);
    float _S335 = smithG1(alpha_8, (F32_max((_S334), (0.0f))));
    bool _S336 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S336)
    {
        float3  _S337 = negate_0(n_i_5);
        float3  _S338 = anisotropicLocal(l_1, lobes_4.tangent, _S337);
        float _S339 = anisotropicG1(_S338, lobes_4.alphas);
        G1_l_0 = _S339;
    }
    else
    {
        G1_l_0 = _S335;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_6.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S340 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S341 = n_i_dot_l_2 > 0.0f;
    bool _S342;
    if(_S341)
    {
        _S342 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S342 = false;
    }
    float _S343 = _slang_select(_S342, _S340,0.0f);
    return _S343;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_6, float alpha_10, BSDFMaterial material_7, BSDFLobes lobes_6)
{
    float3  _S344 = l_2 + lobes_6.view;
    float3  _S345 = ((((_S344)) * make_float3(rnorm3df(((_S344)).x, ((_S344)).y, ((_S344)).z))));
    float _S346 = dot_0(n_i_6, _S345);
    float _S347 = (F32_max((dot_0(n_i_6, l_2)), (0.0f)));
    float _S348 = (F32_max((dot_0(n_i_6, lobes_6.view)), (0.0f)));
    float _S349 = 1.0f / (F32_max((material_7.sheen_roughness), (0.05000000074505806f)));
    float _S350 = (2.0f + _S349) * (F32_pow(((F32_max((1.0f - _S346 * _S346), (0.0f)))), (0.5f * _S349))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S347 + _S348 - _S347 * _S348)), (0.0000152587890625f)));
    return lobes_6.sheen * make_float3 (_S350 * _S347 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, BSDFLobes lobes_7, float eta_i_6, float eta_o_6)
{
    float _S351 = vndfPDF(n_i_dot_v_4, alpha_11, lobes_7);
    float _S352 = lobes_7.p_reflect * _S351 / (4.0f * lobes_7.v_dot_h);
    bool _S353 = _S351 > 0.0f;
    float _S354 = _slang_select(_S353, _S352,0.0f);
    return _S354;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_3, float3  n_i_7, float alpha_12, BSDFMaterial material_8, BSDFLobes lobes_8)
{
    float _S355 = dot_0(n_i_7, l_3);
    float _S356 = smithG1(alpha_12, (F32_max((_S355), (0.0f))));
    bool _S357 = (lobes_8.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S357)
    {
        float3  _S358 = anisotropicLocal(l_3, lobes_8.tangent, n_i_7);
        float _S359 = anisotropicG1(_S358, lobes_8.alphas);
        G1_l_1 = _S359;
    }
    else
    {
        G1_l_1 = _S356;
    }
    return make_float3 (lobes_8.reflect_weight * G1_l_1) * lobes_8.F / make_float3 (lobes_8.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_9, float eta_i_7, float eta_o_7, bool refracted_2, uint random_state_3, FixedArray<float3 , 4>  * throughputs_0, FixedArray<float, 4>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S360 = negate_0(in_dir_4);
    float _S361 = dot_0(n_7, _S360);
    float _S362 = sign_0(_S361);
    float3  _S363 = n_7 * make_float3 (_S362);
    AnisotropicFrame _S364 = anisotropicFrame(material_9, _S363);
    float _S365 = dot_0(_S363, out_dir_2);
    float _S366 = material_9.roughness;
    float _S367 = _S366 * _S366;
    SheenProfile _S368 = sheenProfile(_S360, _S363, material_9);
    float _S369 = rgb_to_greyscale(material_9.translucent);
    bool _S370 = _S369 > 0.0f;
    bool _S371 = (dot_0(n_7, out_dir_2) * _S361) < 0.0f;
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
        float3  _S372 = make_float3 (0.0f);
        (*throughputs_0)[i_2] = _S372;
        (*pdfs_0)[i_2] = 0.0f;
        uint i_3 = i_2 + 1U;
        i_2 = i_3;
    }
    float3  _S373 = make_float3 (0.0f);
    BSDFLobes _S374 = BSDFLobes_x24init_0(0.0f, 0.0f, _S373, _S373, 0.0f, 0.0f, _S373, _S373, 0.0f, 0.0f, 0.0f, 0.0f, _S373, 0.0f, _S373, _S373, make_float2 (0.0f), 0.0f);
    BSDFLobes lobe_terms_0 = _S374;
    uint half_of_0 = 4294967295U;
    float3  ggx_n_2 = _S373;
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
        uint _S375;
        if(i_2 == 3U)
        {
            _S375 = 4U;
        }
        else
        {
            _S375 = i_2;
        }
        bool _S376 = _S375 == 0U;
        bool _S377;
        if(_S376)
        {
            _S377 = _S370;
        }
        else
        {
            _S377 = false;
        }
        bool _S378;
        if(_S377)
        {
            _S378 = _S371;
        }
        else
        {
            _S378 = _S375 == 1U;
        }
        bool _S379 = _S378 != refracted_2;
        if(_S379)
        {
            ggx_n_1 = ggx_n_2;
            uint i_4 = i_2 + 1U;
            ggx_n_2 = ggx_n_1;
            i_2 = i_4;
            continue;
        }
        uint _S380;
        if(_S375 == 4U)
        {
            _S380 = 2U;
        }
        else
        {
            _S380 = _S375;
        }
        bool _S381 = _S380 != half_of_0;
        uint half_of_1;
        if(_S381)
        {
            bool _S382 = _S380 == 0U;
            if(_S382)
            {
                float3  _S383 = sampledHalf(in_dir_4, n_7, material_9, random_state_3, _S364);
                ggx_n_1 = _S383;
            }
            else
            {
                bool _S384 = _S380 == 1U;
                if(_S384)
                {
                    float3  _S385 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_7, eta_o_7);
                    ggx_n_1 = _S385;
                }
                else
                {
                    float3  _S386 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S386;
                }
            }
            float3  _S387 = negate_0(in_dir_4);
            BSDFLobes _S388 = bsdfLobes(in_dir_4, _S387, _S363, ggx_n_1, material_9, eta_i_7, eta_o_7, _S364, _S368);
            lobe_terms_0 = _S388;
            float _S389 = translucentShare(material_9);
            (&lobe_terms_0)->translucent_share = _S389;
            half_of_1 = _S380;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S375)
        {
        case 0U:
            {
                float _S390 = diffusePDF(_S365, 0.0f, (F32_abs((_S361))), _S367, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(0)] = _S390;
                float3  _S391 = diffuseBSDF(out_dir_2, _S363, _S367, material_9, lobe_terms_0);
                (*throughputs_0)[int(0)] = _S391;
                break;
            }
        case 1U:
            {
                float _S392 = refractPDF(_S365, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S361))), _S367, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(1)] = _S392;
                float3  _S393 = refractBSDF(out_dir_2, _S363, _S367, material_9, lobe_terms_0);
                (*throughputs_0)[int(1)] = _S393;
                break;
            }
        case 4U:
            {
                float _S394 = sheenVelvetPDF(_S365, 0.0f, (F32_abs((_S361))), _S367, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(3)] = _S394;
                float3  _S395 = sheenVelvetBSDF(out_dir_2, _S363, _S367, material_9, lobe_terms_0);
                (*throughputs_0)[int(3)] = _S395;
                break;
            }
        default:
            {
                float _S396 = reflectPDF(_S365, 0.0f, (F32_abs((_S361))), _S367, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(2)] = _S396;
                float3  _S397 = reflectBSDF(out_dir_2, _S363, _S367, material_9, lobe_terms_0);
                (*throughputs_0)[int(2)] = _S397;
                break;
            }
        }
        half_of_0 = half_of_1;
        uint i_4 = i_2 + 1U;
        ggx_n_2 = ggx_n_1;
        i_2 = i_4;
    }
    i_2 = 0U;
    ggx_n_1 = _S373;
    for(;;)
    {
        if(i_2 < 4U)
        {
        }
        else
        {
            break;
        }
        bool _S398 = ((*pdfs_0)[i_2]) > 0.0f;
        if(_S398)
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
    bool _S399 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    float3  _S400 = BSDF(in_dir_5, dir_3, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S399, random_state_4, terms_0, pdfs_1);
    float3  _S401 = make_float3 (0.0f);
    uint i_6 = 0U;
    float3  f_1 = _S401;
    for(;;)
    {
        if(i_6 < 4U)
        {
        }
        else
        {
            break;
        }
        bool _S402 = ((*pdfs_1)[i_6]) > 0.0f;
        if(_S402)
        {
            float3  _S403 = (*terms_0)[i_6] * make_float3 ((*pdfs_1)[i_6]) / make_float3 ((*pdfs_1)[i_6] + pdf_0);
            (*terms_0)[i_6] = _S403;
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
    FKSurface _S404 = surface_2;
    FixedArray<float3 , 4>  terms_1;
    FixedArray<float, 4>  pdfs_2;
    float3  _S405 = skyLobes_0(in_dir_6, dir_4, &_S404, eta_2, is_inside_3, pdf_1, random_state_5, &terms_1, &pdfs_2);
    return _S405;
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
    SkySample _S406;
    (&_S406)->dir = dir_5;
    (&_S406)->radiance = radiance_0;
    (&_S406)->color = color_0;
    (&_S406)->random_state = random_state_6;
    return _S406;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0)
{
    uint2  _S407 = (fcptEnvironmentCdfSize());
    uint2  _S408 = make_uint2 (1U, 0U);
    uint2  _S409 = _S407 - _S408;
    Random _S410 = pcg(init_random_state_0);
    Random _S411 = pcg(_S410.state);
    Random _S412 = pcg(_S411.state);
    Random _S413 = pcg(_S412.state);
    uint _S414 = _S409.x;
    uint _S415 = searchCDF_0(make_uint2 (_S414, 0U), make_uint2 (0U, 1U), _S409.y, _S410.value);
    uint _S416 = searchCDF_0(make_uint2 (0U, _S415), _S408, _S414, _S411.value);
    float2  _S417 = make_float2 ((float)_S409.x, (float)_S409.y);
    float2  _S418 = (make_float2 (float(_S416), float(_S415)) + make_float2 (_S412.value, _S413.value)) / _S417 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S419 = _S418.y;
    float _S420 = (F32_sin((_S419)));
    float _S421 = _S418.x;
    float3  _S422 = make_float3 (_S420 * (F32_cos((_S421))), (F32_cos((_S419))), _S420 * (F32_sin((_S421))));
    float _S423 = environmentPdf_0(_S422);
    float3  _S424 = skyBSDF(ray_0->unit_direction, _S422, *surface_3, eta_3, is_inside_4, _S423, lobe_state_0);
    bool _S425 = !(_S423 > 0.0f);
    bool _S426;
    if(_S425)
    {
        _S426 = true;
    }
    else
    {
        _S426 = all_0(_S424 == make_float3 (0.0f));
    }
    if(_S426)
    {
        float3  _S427 = make_float3 (0.0f);
        return SkySample_x24init_0(_S422, _S427, _S427, _S413.state);
    }
    float3  _S428 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S422);
    return SkySample_x24init_0(_S422, _S428, _S424 * _S428, _S413.state);
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
    SampleBSDF _S429 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S430 = _S429.throughput * make_float3 (_S429.pdf);
    float _S431 = light_1->density;
    float _S432 = 1.0f + _S429.pdf * _S429.pdf / (light_1->density * light_1->density);
    bool _S433;
    if(competing_0)
    {
        _S433 = _S431 > 0.0f;
    }
    else
    {
        _S433 = false;
    }
    float _S434 = _slang_select(_S433, _S432,1.0f);
    return _S430 / make_float3 (_S434) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_7)
{
    TreeSample _S435;
    (&_S435)->dir = dir_6;
    (&_S435)->radiance = radiance_1;
    (&_S435)->density = density_0;
    (&_S435)->random_state = random_state_7;
    return _S435;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_3, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S436 = importance(first_1, p_3, normal_3);
    float _S437 = importance(second_1, p_3, normal_3);
    float2  _S438 = make_float2 (_S436, _S437);
    bool _S439 = _S436 == 0.0f;
    bool _S440;
    if(_S439)
    {
        _S440 = _S437 == 0.0f;
    }
    else
    {
        _S440 = false;
    }
    if(_S440)
    {
        return 2U;
    }
    float _S441 = _S436 + _S437;
    bool _S442 = _S437 > 0.0f;
    if(_S442)
    {
        _S440 = (*pick_0 * _S441) >= _S436;
    }
    else
    {
        _S440 = false;
    }
    uint _S443 = uint(_S440);
    float _S444 = (F32_min(((*pick_0 * _S441 - float(_S443) * _S436) / _slang_vector_get_element(_S438, _S443)), (0.99999994039535522f)));
    *pick_0 = _S444;
    float _S445 = *probability_3 * (_slang_vector_get_element(_S438, _S443) / _S441);
    *probability_3 = _S445;
    return _S443;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_4, float u1_0, float u2_0)
{
    float3  _S446 = center_1 - p_4;
    float _S447 = radius_1 * radius_1 / dot_0(_S446, _S446);
    float _S448 = u1_0 * _S447 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S447), (0.0f)))))));
    float _S449 = 2.0f * u1_0;
    bool _S450 = _S447 >= 1.0f;
    float _S451 = _slang_select(_S450, _S449,_S448);
    float _S452 = (F32_sqrt(((F32_max((_S451 * (2.0f - _S451)), (0.0f))))));
    float _S453 = 6.28318548202514648f * u2_0;
    float3  _S454 = make_float3 (_S452 * (F32_cos((_S453))), 1.0f - _S451, _S452 * (F32_sin((_S453))));
    float3  _S455 = ((((_S446)) * make_float3(rnorm3df(((_S446)).x, ((_S446)).y, ((_S446)).z))));
    float3  _S456 = tangentToWorld(_S454, _S455);
    return _S456;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S457 = center_2 - ray_1->origin;
    float _S458 = dot_0(_S457, ray_1->unit_direction);
    float _S459 = dot_0(_S457, _S457) - _S458 * _S458;
    float _S460 = radius_3 * radius_3;
    bool _S461 = _S459 > _S460;
    if(_S461)
    {
        return 4.294967296e+09f;
    }
    float _S462 = (F32_sqrt((_S460 - _S459)));
    float _S463 = _S458 - _S462;
    float _S464 = _S458 + _S462;
    bool _S465 = _S463 > 0.0000152587890625f;
    bool _S466;
    if(_S465)
    {
        _S466 = _S463 < max_len_0;
    }
    else
    {
        _S466 = false;
    }
    if(_S466)
    {
        return _S463;
    }
    bool _S467 = _S464 > 0.0000152587890625f;
    if(_S467)
    {
        _S466 = _S464 < max_len_0;
    }
    else
    {
        _S466 = false;
    }
    if(_S466)
    {
        return _S464;
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
    Random _S468 = pcg(init_random_state_1);
    Random _S469 = pcg(_S468.state);
    Random _S470 = pcg(_S469.state);
    float3  _S471 = make_float3 (0.0f);
    TreeSample _S472 = TreeSample_x24init_0(_S471, _S471, 0.0f, _S470.state);
    TreeSample sample_0 = _S472;
    float3  _S473 = _slang_select(sided_0, _S471,smooth_n_2);
    float3  _S474 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S468.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S475 = (fcptLightNode((n_8)));
        if((_S475.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S476 = (fcptLightSecond((n_8)));
        uint _S477 = n_8 + 1U;
        LightNode _S478 = (fcptLightBounds((_S477)));
        LightNode _S479 = (fcptLightBounds((_S476)));
        uint _S480 = pickChild(_S478, _S479, origin_4, _S473, &pick_1, &probability_4);
        bool _S481 = _S480 > 1U;
        if(_S481)
        {
            return sample_0;
        }
        bool _S482 = _S480 == 1U;
        uint _S483 = _slang_select(_S482, _S476,_S477);
        n_8 = _S483;
    }
    bool _S484 = n_8 == 0U;
    bool _S485;
    if(_S484)
    {
        LightNode _S486 = (fcptLightBounds((0U)));
        float _S487 = importance(_S486, origin_4, _S473);
        _S485 = !(_S487 > 0.0f);
    }
    else
    {
        _S485 = false;
    }
    if(_S485)
    {
        return sample_0;
    }
    uint4  _S488 = (fcptLightNode((n_8)));
    FKHit _S489 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S490 = (_S488.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S490)
    {
        FKLight _S491 = (fcptLight((_S488.y)));
        if(sided_0)
        {
            float _S492 = sign_0(dot_0(geometry_n_1, _S491.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S492);
            float3  _S493 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S493;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S474;
            lift_n_0 = smooth_n_2;
        }
        bool _S494 = (_S491.variance) == 0.0f;
        if(_S494)
        {
            float3  _S495 = _S491.position - emitter_point_0;
            float3  _S496 = ((((_S495)) * make_float3(rnorm3df(((_S495)).x, ((_S495)).y, ((_S495)).z))));
            (&sample_0)->dir = _S496;
            float3  _S497 = _S491.color * make_float3 (_S491.intensity) / make_float3 (dot_0(_S495, _S495) * probability_4);
            (&sample_0)->radiance = _S497;
            shadow_1 = _S495;
        }
        else
        {
            float3  _S498 = sampleSphere(_S491.position, _S491.variance, emitter_point_0, _S469.value, _S470.value);
            (&sample_0)->dir = _S498;
            float _S499 = sphereDensity(_S491.position, _S491.variance, emitter_point_0);
            float _S500 = probability_4 * _S499;
            (&sample_0)->density = _S500;
            float3  _S501 = pointLightRadiance(_S491.color, _S491.intensity, _S491.variance);
            float3  _S502 = _S501 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S502;
            FKRay _S503 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S504 = raySphere_0(_S491.position, _S491.variance, &_S503, 4.294967296e+09f);
            float3  _S505 = (&sample_0)->dir * make_float3 (_S504);
            shadow_1 = _S505;
        }
        emitter_0 = _S489;
        emitter_point_0 = _S471;
    }
    else
    {
        uint _S506 = _S488.y;
        uint _S507 = (fcptTriangleOffset((_S506)));
        uint _S508 = _S507 + _S488.z;
        Matrix<float, 3, 3>  _S509 = (fcptWorldTriangle((_S506), (_S508)));
        float _S510 = (F32_sqrt((_S469.value)));
        float2  _S511 = make_float2 (_S510 * (1.0f - _S470.value), _S510 * _S470.value);
        float3  _S512 = mul_0(make_float3 (1.0f - _S510, _S511.x, _S511.y), _S509);
        if(sided_0)
        {
            float _S513 = sign_0(dot_0(geometry_n_1, _S512 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S513);
            float3  _S514 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S514;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S515 = !((dot_0(smooth_n_2, _S512 - origin_4)) > 0.0f);
            if(_S515)
            {
                return sample_0;
            }
            emitter_point_0 = _S474;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S511, _S506, _S508, 0U, 0.0f);
        float3  _S516 = _S512 - emitter_point_0;
        float3  _S517 = ((((_S516)) * make_float3(rnorm3df(((_S516)).x, ((_S516)).y, ((_S516)).z))));
        (&sample_0)->dir = _S517;
        float _S518 = solidAngle(probability_4, cross_0(_S509.rows[int(1)] - _S509.rows[int(0)], _S509.rows[int(2)] - _S509.rows[int(0)]), _S516);
        (&sample_0)->density = _S518;
        bool _S519 = (fcptShadowFirst());
        bool _S520 = !_S519;
        if(_S520)
        {
            FKSurface _S521 = (fcptLightSurfaceAt((emitter_1), (_S512), (_S470.state), ((&sample_0)->dir), (context_1->depth), (length_0(_S512 - origin_4))));
            (&sample_0)->random_state = _S521.random_state;
            float3  _S522 = _slang_select(_S521.skip, _S471,_S521.material.emissive);
            float3  _S523 = _S522 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S523;
        }
        shadow_1 = _S516;
        emitter_0 = emitter_1;
        emitter_point_0 = _S512;
    }
    FKHit _S524 = emitter_0;
    float3  _S525 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_1, _S470.state, &_S524);
    bool _S526 = (fcptShadowFirst());
    if(_S526)
    {
        _S485 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S485 = false;
    }
    if(_S485)
    {
        _S485 = !all_0(_S525 == _S471);
    }
    else
    {
        _S485 = false;
    }
    if(_S485)
    {
        FKSurface _S527 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S470.state), ((&sample_0)->dir), (context_1->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S527.random_state;
        float3  _S528 = _slang_select(_S527.skip, _S471,_S527.material.emissive);
        float3  _S529 = _S528 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S529;
    }
    float3  _S530 = (&sample_0)->radiance * _S525;
    bool _S531 = all_0(_S525 == _S471);
    float3  _S532 = _slang_select(_S531, _S471,_S530);
    (&sample_0)->radiance = _S532;
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
    float _S533 = 1.0f / (1.0f + b_0 / a_4 * (b_0 / a_4));
    bool _S534 = b_0 > 0.0f;
    float _S535 = _slang_select(_S534, _S533,1.0f);
    return _S535;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_0, float3  light_point_1)
{
    bool _S536 = vertex_0->none;
    if(_S536)
    {
        return 1.0f;
    }
    uint _S537 = (fcptLightSlot((*hit_0)));
    float _S538 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S537, light_point_1);
    float _S539 = powerHeuristic(vertex_0->pdf, _S538);
    return _S539;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_0)
{
    uint2  _S540 = (fcptEnvironmentMapSize());
    bool _S541 = (_S540.x) > 1U;
    bool _S542;
    if(_S541)
    {
        uint2  _S543 = (fcptEnvironmentMapSize());
        _S542 = (_S543.y) > 1U;
    }
    else
    {
        _S542 = false;
    }
    if(_S542)
    {
        float3  _S544 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_0)));
        return _S544;
    }
    float3  _S545 = (fcptAmbient());
    return _S545;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S546 = (fcptEnvironmentCdfSize());
    bool _S547 = (_S546.x) > 1U;
    bool _S548;
    if(_S547)
    {
        uint2  _S549 = (fcptEnvironmentCdfSize());
        _S548 = (_S549.y) > 1U;
    }
    else
    {
        _S548 = false;
    }
    bool _S550 = !_S548;
    if(_S550)
    {
        return false;
    }
    uint2  _S551 = (fcptEnvironmentMapSize());
    bool _S552 = (_S551.x) > 1U;
    if(_S552)
    {
        uint2  _S553 = (fcptEnvironmentMapSize());
        _S548 = (_S553.y) > 1U;
    }
    else
    {
        _S548 = false;
    }
    return _S548;
}

static __device__ float escapeWeight_0(float pdf_2, float3  dir_8)
{
    bool _S554 = pdf_2 <= 0.0f;
    bool _S555;
    if(_S554)
    {
        _S555 = true;
    }
    else
    {
        bool _S556 = environmentMapped_0();
        _S555 = !_S556;
    }
    if(_S555)
    {
        return 1.0f;
    }
    float _S557 = environmentPdf_0(dir_8);
    return pdf_2 / (pdf_2 + _S557);
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
    Shift _S558;
    (&_S558)->f = f_3;
    (&_S558)->jac = jac_0;
    return _S558;
}

static __device__ uint extractBits_0(uint e_1, uint offset_0, uint count_1)
{
    return (e_1 >> offset_0) & ((1U << count_1) - 1U);
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_3, float3  origin_5, float3  smooth_n_3, float3  start_2)
{
    NEEVertex _S559;
    (&_S559)->none = none_0;
    (&_S559)->pdf = pdf_3;
    (&_S559)->origin = origin_5;
    (&_S559)->smooth_n = smooth_n_3;
    (&_S559)->start = start_2;
    return _S559;
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
    Vertex _S560;
    (&_S560)->rough = rough_0;
    (&_S560)->lobe = lobe_1;
    (&_S560)->pdf = pdf_4;
    (&_S560)->cos = cos_0;
    (&_S560)->inside = inside_0;
    return _S560;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S561 = hash(index_0);
    uint _S562 = hash(seed_0 ^ _S561);
    return _S562;
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
    float3  _S563 = exp_0((make_float3 (sigma_0) - extinction_0) * make_float3 (distance_1));
    float3  _S564 = scatter_0 * _S563 / make_float3 (sigma_0);
    float3  _S565 = _slang_select(scatters_0, _S564,_S563);
    return _S565;
}

static __device__ uint arrivalLobe_0(uint b_1, uint prev_lobe_0)
{
    bool _S566 = b_1 > 0U;
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

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S569 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S569)
    {
        return 0.07957746833562851f;
    }
    float _S570 = g_0 * g_0;
    return (1.0f - _S570) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S570 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_5, float3  b_2)
{
    float3  _S571 = a_5 / b_2;
    float3  _S572 = make_float3 (0.0f);
    bool3  _S573 = b_2 == _S572;
    float3  _S574 = _slang_select(_S573, _S572,_S571);
    return _S574;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S575 = (1U << count_2) - 1U;
    return (e_2 & (~(_S575 << offset_1))) | ((newbits_0 & _S575) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_0, uint end_type_0, uint end_0, float3  f_4)
{
    Reservoir candidate_0 = r_0;
    uint _S576 = insertBits_0(r_0.path, end_0, 0U, 5U);
    uint _S577 = insertBits_0(_S576, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S577;
    (&candidate_0)->f = f_4;
    return candidate_0;
}

__device__ void offer(Selection * sel_0, Reservoir candidate_1, float3  weight_0)
{
    float _S578 = rgb_to_greyscale(weight_0);
    bool _S579 = _S578 > 0.0f;
    bool _S580;
    if(_S579)
    {
        _S580 = _S578 < 3.00000000549775576e+38f;
    }
    else
    {
        _S580 = false;
    }
    bool _S581 = !_S580;
    if(_S581)
    {
        return;
    }
    bool _S582 = sel_0->sums;
    if(_S582)
    {
        float3  _S583 = sel_0->color + weight_0;
        sel_0->color = _S583;
        return;
    }
    float _S584 = sel_0->w_sum + _S578;
    sel_0->w_sum = _S584;
    float3  _S585 = sel_0->color + weight_0;
    sel_0->color = _S585;
    Random _S586 = pcg(sel_0->random_state);
    sel_0->random_state = _S586.state;
    bool _S587 = (_S586.value * sel_0->w_sum) <= _S578;
    if(_S587)
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
    Random _S588 = pcg(random_state_8);
    Random _S589 = pcg(_S588.state);
    float _S590 = 1.0f - 2.0f * _S588.value;
    float _S591 = (F32_sqrt(((F32_max((1.0f - _S590 * _S590), (0.0f))))));
    float _S592 = 6.28318548202514648f * _S589.value;
    return make_float3 (_S591 * (F32_cos((_S592))), _S591 * (F32_sin((_S592))), _S590);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_9, float * pdf_5)
{
    bool _S593 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S593)
    {
        *pdf_5 = 0.07957746833562851f;
        float3  _S594 = isotropic_0(random_state_9);
        return _S594;
    }
    Random _S595 = pcg(random_state_9);
    Random _S596 = pcg(_S595.state);
    float _S597 = g_1 * g_1;
    float _S598 = 2.0f * g_1;
    float _S599 = (1.0f - _S597) / (1.0f - g_1 + _S598 * _S595.value);
    float _S600 = clamp_0((1.0f + _S597 - _S599 * _S599) / _S598, -1.0f, 1.0f);
    float _S601 = (F32_sqrt(((F32_max((1.0f - _S600 * _S600), (0.0f))))));
    float _S602 = 6.28318548202514648f * _S596.value;
    float _S603 = phaseHG_0(g_1, _S600);
    *pdf_5 = _S603;
    float3  _S604 = tangentToWorld(make_float3 (_S601 * (F32_cos((_S602))), _S600, _S601 * (F32_sin((_S602)))), dir_9);
    float3  _S605 = ((((_S604)) * make_float3(rnorm3df(((_S604)).x, ((_S604)).y, ((_S604)).z))));
    return _S605;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2)
{
    BSDFMaterial _S606;
    (&_S606)->albedo = albedo_1;
    (&_S606)->emissive = emissive_0;
    (&_S606)->roughness = roughness_0;
    (&_S606)->metallic = metallic_0;
    (&_S606)->transmission = transmission_0;
    (&_S606)->ior = ior_0;
    (&_S606)->absorption = absorption_0;
    (&_S606)->specular_tint = specular_tint_0;
    (&_S606)->specular_level = specular_level_0;
    (&_S606)->translucent = translucent_0;
    (&_S606)->sheen = sheen_2;
    (&_S606)->sheen_roughness = sheen_roughness_0;
    (&_S606)->anisotropy = anisotropy_0;
    (&_S606)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S606)->tangent = tangent_2;
    return _S606;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S607;
    (&_S607)->scatter = scatter_1;
    (&_S607)->extinction = extinction_1;
    (&_S607)->g = g_2;
    return _S607;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_10, bool skip_0, uint random_state_10, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S608;
    (&_S608)->smooth_n = smooth_n_4;
    (&_S608)->geometry_n = geometry_n_2;
    (&_S608)->geometry_offset = geometry_offset_2;
    (&_S608)->material = *material_10;
    (&_S608)->skip = skip_0;
    (&_S608)->random_state = random_state_10;
    (&_S608)->coverage = coverage_0;
    (&_S608)->encloses = encloses_0;
    (&_S608)->volume = *volume_0;
    (&_S608)->fills = fills_0;
    (&_S608)->hair = hair_0;
    return _S608;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S609 = (&surface_6->material)->emissive;
    float3  _S610 = make_float3 (0.0f);
    bool _S611 = !top_0;
    float3  _S612 = _slang_select(_S611, _S610,_S609);
    (&(&lower_0)->material)->emissive = _S612;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_1)
{
    float _S613 = surface_7->coverage;
    bool _S614 = u_1 < _S613;
    if(_S614)
    {
        return *surface_7;
    }
    float3  _S615 = make_float3 (0.0f);
    float3  _S616 = make_float3 (1.0f);
    BSDFMaterial _S617 = Material_x24init_0(_S615, _S615, 0.0f, 0.0f, 0.0f, 0.0f, _S615, _S616, 1.0f, _S615, _S615, 0.5f, 0.0f, 0.0f, _S615);
    BSDFMaterial material_11 = _S617;
    (&material_11)->albedo = _S616;
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
    bool _S618 = transmission_1 > 0.0f;
    bool _S619;
    if(_S618)
    {
        _S619 = true;
    }
    else
    {
        _S619 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S620;
    if(_S619)
    {
        _S620 = 1.0f;
    }
    else
    {
        _S620 = -1.0f;
    }
    return _S620;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_9)
{
    return (dot_0(dir_10, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_11)
{
    float3  _S621 = surface_8->geometry_n;
    float _S622 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_11);
    FKSurface faced_0 = *surface_8;
    float3  _S623 = surface_8->smooth_n * make_float3 (_S622);
    (&faced_0)->smooth_n = _S623;
    float3  _S624 = _S621 * make_float3 (_S622);
    (&faced_0)->geometry_n = _S624;
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
    float3  _S625 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_2) * log_0(_S625));
}

__device__ float2  vertexEta(BSDFMaterial material_12, float n_dot_v_0)
{
    bool _S626 = n_dot_v_0 < 0.0f;
    float _S627 = _slang_select(_S626, material_12.ior,1.0f);
    float _S628 = _slang_select(_S626, 1.0f,material_12.ior);
    return make_float2 (_S627, _S628);
}

__device__ bool neeDecision(BSDFMaterial material_13, float n_dot_v_1, float eta_i_8, float eta_o_8)
{
    float _S629 = fresnel((F32_abs((n_dot_v_1))), eta_i_8, eta_o_8);
    float3  _S630 = mix_0(make_float3 (_S629), material_13.albedo, material_13.metallic);
    float _S631 = rgb_to_greyscale(_S630);
    float _S632 = (F32_max(((1.0f - _S631) * (1.0f - material_13.metallic) * (1.0f - material_13.transmission)), (0.0f)));
    bool _S633 = _S632 > 0.03999999910593033f;
    bool _S634;
    if(_S633)
    {
        _S634 = true;
    }
    else
    {
        _S634 = (material_13.roughness) > 0.20000000298023224f;
    }
    return _S634;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_14)
{
    float _S635 = rgb_to_greyscale(material_14->translucent);
    return _S635 > 0.0f;
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

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_12)
{
    float3  _S637 = surface_9->geometry_n;
    MediumSides _S638 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S638;
    bool _S639 = surface_9->encloses;
    if(_S639)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S640 = (dot_0(dir_12, _S637)) > 0.0f;
        if(_S640)
        {
            float3  _S641 = make_float3 (0.0f);
            FKMedium _S642 = Medium_x24init_0(_S641, _S641, 0.0f);
            (&sides_0)->front = _S642;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_3, float length_3, float width_1, FKHit * own_1, bool fiber_1)
{
    float3  _S643 = surface_10->geometry_n;
    ShadowContext _S644 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
    bool _S645 = surface_10->encloses;
    ShadowContext context_2;
    if(_S645)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S646 = - _S643;
        float3  _S647 = _slang_select(turned_0, _S646,_S643);
        (&faced_1)->geometry_n = _S647;
        FKMedium _S648 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S649 = faced_1;
        FKMedium _S650 = _S648;
        MediumSides _S651 = mediumSides_0(&_S649, &_S650, filling_1, dir_13);
        ShadowContext _S652 = ShadowContext_x24init_0(_S651.behind.extinction, _S651.front.extinction, _S651.fillings, _S643, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
        if(turned_0)
        {
            uint2  _S653 = _S651.fillings;
            ShadowContext _S654 = ShadowContext_x24init_0(_S651.front.extinction, _S651.behind.extinction, uint2 {_S653.y, _S653.x}, _S643, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
            context_2 = _S654;
        }
        else
        {
            context_2 = _S652;
        }
    }
    else
    {
        context_2 = _S644;
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
    float3  _S655 = light_2->dir;
    bool _S656 = (dot_0(geometry_n_3, - in_dir_8) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 4>  throughputs_1;
    FixedArray<float, 4>  pdfs_3;
    float3  _S657 = BSDF(in_dir_8, _S655, smooth_n_5, *material_15, eta_i_9, eta_o_9, _S656, random_state_11, &throughputs_1, &pdfs_3);
    bool _S658 = !competing_1;
    bool _S659;
    if(_S658)
    {
        _S659 = true;
    }
    else
    {
        _S659 = (light_2->density) == 0.0f;
    }
    if(_S659)
    {
        return _S657 * light_2->radiance;
    }
    float3  _S660 = make_float3 (0.0f);
    uint i_15 = 0U;
    float3  weighted_0 = _S660;
    for(;;)
    {
        if(i_15 < 4U)
        {
        }
        else
        {
            break;
        }
        bool _S661 = (pdfs_3[i_15]) > 0.0f;
        if(_S661)
        {
            float _S662 = light_2->density;
            float _S663 = pdfs_3[i_15] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_15] * make_float3 (pdfs_3[i_15]) / make_float3 (_S662 * (1.0f + _S663 * _S663));
            weighted_0 = weighted_1;
        }
        uint i_16 = i_15 + 1U;
        i_15 = i_16;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_12, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S664;
    (&_S664)->unit_direction = unit_direction_1;
    (&_S664)->throughput = throughput_1;
    (&_S664)->random_state = random_state_12;
    (&_S664)->refracted = refracted_3;
    (&_S664)->lobe = lobe_4;
    (&_S664)->pdf = pdf_6;
    return _S664;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_8, float n_i_dot_v_5, float alpha_13, BSDFMaterial material_16, BSDFLobes lobes_9, float eta_i_10, float eta_o_10, uint random_state_13)
{
    float3  _S665 = make_float3 (1.0f);
    SampleBSDF _S666 = SampleBSDF_x24init_0(_S665, _S665, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S666;
    Random _S667 = pcg(random_state_13);
    Random _S668 = pcg(_S667.state);
    (&sample_1)->random_state = _S668.state;
    float _S669 = _S667.value;
    float _S670 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S669 * _S669))))));
    float _S671 = 6.28318548202514648f * _S668.value;
    float3  _S672 = tangentToWorld(make_float3 (_S670 * (F32_cos((_S671))), _S667.value, _S670 * (F32_sin((_S671)))), n_i_8);
    (&sample_1)->unit_direction = _S672;
    (&sample_1)->lobe = 4U;
    float3  _S673 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_8, alpha_13, material_16, lobes_9);
    (&sample_1)->throughput = _S673;
    float _S674 = sheenVelvetPDF(_S667.value, 0.0f, n_i_dot_v_5, alpha_13, lobes_9, eta_i_10, eta_o_10);
    (&sample_1)->pdf = _S674;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S675 = (F32_sqrt((random_1_0)));
    float _S676 = 6.28318548202514648f * random_2_0;
    float _S677 = _S675 * (F32_cos((_S676)));
    float _S678 = _S675 * (F32_sin((_S676)));
    float _S679 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S677 * _S677 - _S678 * _S678))))));
    return make_float3 (_S677, _S679, _S678);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_2, float3  n_i_9, float n_i_dot_v_6, float alpha_14, BSDFMaterial material_17, BSDFLobes lobes_10, float eta_i_11, float eta_o_11, uint random_state_14)
{
    float3  _S680 = make_float3 (1.0f);
    SampleBSDF _S681 = SampleBSDF_x24init_0(_S680, _S680, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S681;
    Random _S682 = pcg(random_state_14);
    Random _S683 = pcg(_S682.state);
    (&sample_2)->random_state = _S683.state;
    float3  _S684 = sampleCosWeightedHemisphere(_S682.value, _S683.value);
    bool _S685 = u_2 < (lobes_10.p_diffuse * lobes_10.translucent_share);
    float _S686 = _S684.y;
    float _S687 = - _S686;
    float _S688 = _slang_select(_S685, _S687,_S686);
    float3  _S689 = tangentToWorld(make_float3 (_S684.x, _S688, _S684.z), n_i_9);
    (&sample_2)->unit_direction = _S689;
    (&sample_2)->refracted = _S685;
    (&sample_2)->lobe = 0U;
    float3  _S690 = diffuseBSDF((&sample_2)->unit_direction, n_i_9, alpha_14, material_17, lobes_10);
    (&sample_2)->throughput = _S690;
    float _S691 = diffusePDF(_S688, 0.0f, n_i_dot_v_6, alpha_14, lobes_10, eta_i_11, eta_o_11);
    (&sample_2)->pdf = _S691;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_10, float n_i_dot_v_7, float alpha_15, BSDFMaterial material_18, BSDFLobes lobes_11, float eta_i_12, float eta_o_12, uint random_state_15)
{
    float3  _S692 = make_float3 (1.0f);
    SampleBSDF _S693 = SampleBSDF_x24init_0(_S692, _S692, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S693;
    (&sample_3)->unit_direction = lobes_11.refracted;
    (&sample_3)->random_state = random_state_15;
    (&sample_3)->refracted = true;
    (&sample_3)->lobe = 1U;
    float3  _S694 = refractBSDF((&sample_3)->unit_direction, n_i_10, alpha_15, material_18, lobes_11);
    (&sample_3)->throughput = _S694;
    float _S695 = refractPDF(0.0f, dot_0((&sample_3)->unit_direction, ggx_n_3), n_i_dot_v_7, alpha_15, lobes_11, eta_i_12, eta_o_12);
    (&sample_3)->pdf = _S695;
    return sample_3;
}

static __device__ float3  reflect_0(float3  i_17, float3  n_10)
{
    return i_17 - make_float3 (2.0f * dot_0(n_10, i_17)) * n_10;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_11, float n_i_dot_v_8, float alpha_16, BSDFMaterial material_19, BSDFLobes lobes_12, float eta_i_13, float eta_o_13, uint random_state_16)
{
    float3  _S696 = make_float3 (1.0f);
    SampleBSDF _S697 = SampleBSDF_x24init_0(_S696, _S696, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S697;
    float3  _S698 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S699 = ((((_S698)) * make_float3(rnorm3df(((_S698)).x, ((_S698)).y, ((_S698)).z))));
    (&sample_4)->unit_direction = _S699;
    (&sample_4)->random_state = random_state_16;
    (&sample_4)->lobe = 2U;
    float3  _S700 = reflectBSDF((&sample_4)->unit_direction, n_i_11, alpha_16, material_19, lobes_12);
    (&sample_4)->throughput = _S700;
    float _S701 = reflectPDF(0.0f, 0.0f, n_i_dot_v_8, alpha_16, lobes_12, eta_i_13, eta_o_13);
    (&sample_4)->pdf = _S701;
    return sample_4;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_11, BSDFMaterial material_20, float eta_i_14, float eta_o_14, uint random_init_0, float2  screen_space_0)
{
    uint random_state_17 = random_init_0;
    float3  _S702 = negate_0(in_dir_10);
    float _S703 = dot_0(n_11, _S702);
    float _S704 = sign_0(_S703);
    float3  n_i_12 = n_11 * make_float3 (_S704);
    float _S705 = (F32_abs((_S703)));
    float _S706 = material_20.roughness;
    float _S707 = _S706 * _S706;
    AnisotropicFrame _S708 = anisotropicFrame(material_20, n_i_12);
    SheenProfile _S709 = sheenProfile(_S702, n_i_12, material_20);
    float3  _S710 = sampleHalfVector(_S702, n_i_12, _S707, _S708, &random_state_17);
    BSDFLobes _S711 = bsdfLobes(in_dir_10, _S702, n_i_12, _S710, material_20, eta_i_14, eta_o_14, _S708, _S709);
    BSDFLobes lobes_13 = _S711;
    float _S712 = translucentShare(material_20);
    (&lobes_13)->translucent_share = _S712;
    Random _S713 = pcg(random_state_17);
    random_state_17 = _S713.state;
    bool _S714 = (_S713.value) < ((&lobes_13)->p_sheen_velvet);
    if(_S714)
    {
        SampleBSDF _S715 = sheenVelvetSample(n_i_12, _S705, _S707, material_20, lobes_13, eta_i_14, eta_o_14, random_state_17);
        return _S715;
    }
    float _S716 = _S713.value - (&lobes_13)->p_sheen_velvet;
    bool _S717 = _S716 < ((&lobes_13)->p_diffuse);
    if(_S717)
    {
        SampleBSDF _S718 = diffuseSample(_S716, n_i_12, _S705, _S707, material_20, lobes_13, eta_i_14, eta_o_14, random_state_17);
        return _S718;
    }
    bool _S719 = _S716 < ((&lobes_13)->p_diffuse + (&lobes_13)->p_refract);
    if(_S719)
    {
        SampleBSDF _S720 = refractSample(_S710, n_i_12, _S705, _S707, material_20, lobes_13, eta_i_14, eta_o_14, random_state_17);
        return _S720;
    }
    SampleBSDF _S721 = reflectSample(in_dir_10, _S710, n_i_12, _S705, _S707, material_20, lobes_13, eta_i_14, eta_o_14, random_state_17);
    return _S721;
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
    bool _S722;
    bool _S723;
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
    int _S724;
    Shift ended_0;
    float density_3;
    float spread_1;
    float width_3;
    float sky_pdf_1;
    float spread_2;
    float width_4;
    uint b_4;
    float3  _S725 = make_float3 (0.0f);
    Shift _S726 = Shift_x24init_0(_S725, 0.0f);
    uint _S727 = r_1->path;
    uint _S728 = extractBits_0(r_1->path, 0U, 5U);
    uint _S729 = extractBits_0(_S727, 5U, 5U);
    uint _S730 = extractBits_0(_S727, 10U, 2U);
    uint _S731 = extractBits_0(_S727, 12U, 3U);
    bool passes_0;
    if(replay_0)
    {
        bool _S732 = _S731 >= 3U;
        uint _S733 = _slang_select(_S732, 1U,0U);
        uint _S734 = _S728 + _S733;
        uint _S735 = (fcptMaxBounces());
        passes_0 = _S734 > _S735;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S726;
    }
    uint _S736 = _S729 - 1U;
    bool _S737 = _S731 == 3U;
    uint _S738 = _slang_select(_S737, 1U,0U);
    uint _S739 = _S728 + _S738;
    bool _S740 = _S730 == 0U;
    uint _S741 = _slang_select(_S740, _S739,_S736);
    FKHit _S742 = (fcptReservoirHit((*r_1)));
    float3  _S743 = dom_0->x0;
    float3  _S744 = dom_0->x1 - dom_0->x0;
    float3  _S745 = ((((_S744)) * make_float3(rnorm3df(((_S744)).x, ((_S744)).y, ((_S744)).z))));
    FKRay _S746 = Ray_x24init_0(dom_0->x1, _S745);
    FKRay ray_2 = _S746;
    FKHit hit_1 = dom_0->hit;
    float3  scatter_in_0 = _S725;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S725;
    float3  extinction_in_0 = _S725;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S747 = dom_0->spread;
    float _S748 = dom_0->width;
    float _S749 = length_0(_S744);
    NEEVertex _S750 = NEEVertex_x24init_0(true, 0.0f, _S725, _S725, _S725);
    NEEVertex nee_vertex_0 = _S750;
    Vertex _S751 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S751;
    Reservoir _S752 = (Reservoir{});
    Reservoir chain_0 = _S752;
    uint _S753 = r_1->seed;
    (&chain_0)->seed = r_1->seed;
    (&ray_2)->origin = _S743;
    (&hit_1)->distance = _S749;
    FKMedium _S754 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_1)->distance), (&filling_2)));
    uint _S755 = filling_2;
    bool _S756 = (fcptVaryingUsed());
    uint _S757 = _slang_select(_S756, _S755,4294967295U);
    filling_2 = _S757;
    scatter_in_0 = _S754.scatter;
    extinction_in_0 = _S754.extinction;
    g_in_0 = _S754.g;
    Reservoir _S758 = chain_0;
    uint _S759 = filling_2;
    for(;;)
    {
        bool _S760 = (fcptVaryingUsed());
        if(_S760)
        {
            passes_0 = _S759 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S761 = (fcptMajorant((_S759)));
            spread_0 = _S761;
        }
        else
        {
            spread_0 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_0)
        {
            turned_1 = 4294967295U == _S741;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S730 == 1U;
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
            ended_0 = _S726;
            sky_pdf_0 = 0.0f;
            spread_0 = _S747;
            width_2 = _S748;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_3 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S762 = (&prev_0)->rough;
        if(_S762)
        {
            turned_1 = !(spread_0 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S763 = stream(_S753, 384U);
        uint tracking_0 = _S763;
        weight_1 = throughput_3;
        glowed_0 = _S725;
        b_3 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_0 = _S747;
        width_2 = _S748;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_1)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S724 = int(1);
                break;
            }
            uint _S764 = b_3 + 320U;
            bool _S765 = b_3 == 4294967295U;
            uint _S766 = _slang_select(_S765, 384U,_S764);
            uint _S767 = stream(_S753, _S766);
            Random _S768 = pcg(_S767);
            float _S769 = - (F32_log((1.0f - _S768.value))) / spread_0;
            if(passes_0)
            {
                float3  _S770 = (&ray_2)->origin;
                float3  _S771 = (&ray_2)->unit_direction;
                float _S772 = (&hit_1)->distance;
                uint _S773 = _slang_select(_S765, 0U,b_3);
                uint _S774 = (&prev_0)->lobe;
                uint _S775 = _slang_select(_S765, 3U,_S774);
                float _S776 = (fcptTrackMedium((_S759), (_S770), (_S771), (_S772), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S773), (_S775), (_S765)));
                geometry_density_0 = _S776;
            }
            else
            {
                geometry_density_0 = _S769;
            }
            bool _S777 = !(geometry_density_0 < ((&hit_1)->distance));
            if(_S777)
            {
                _S724 = int(1);
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
                float3  _S778 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S779 = sel_1->glow + _S778;
                sel_1->glow = _S779;
            }
            else
            {
            }
            glowed_0 = _S725;
            uint b_5 = b_3 + 1U;
            float3  _S780 = (&ray_2)->origin + make_float3 (geometry_density_0) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S780;
            float3  _S781 = flightWeight_0(scatter_in_0, extinction_in_0, spread_0, geometry_density_0, true);
            float3  _S782 = weight_1;
            float3  _S783 = _slang_select(passes_0, _S782,_S781);
            float3  throughput_4 = throughput_2 * _S783;
            uint _S784 = stream(_S753, b_5 + 320U);
            tracking_0 = _S784;
            weight_1 = throughput_3;
            float width_5 = width_2 + threshold_0 * geometry_density_0;
            float _S785 = threshold_0 + 3.14159274101257324f;
            bool _S786 = !replay_0;
            if(_S786)
            {
                is_inside_5 = true;
            }
            else
            {
                bool _S787 = b_5 == _S741;
                if(_S787)
                {
                    is_inside_5 = !passes_0;
                }
                else
                {
                    is_inside_5 = false;
                }
            }
            TreeSample _S788 = TreeSample_x24init_0(_S725, _S725, 0.0f, 0U);
            if(is_inside_5)
            {
                float3  _S789 = (&ray_2)->origin;
                float3  _S790 = (&ray_2)->unit_direction;
                float3  _S791 = (&ray_2)->unit_direction;
                uint _S792 = stream(_S753, b_5 + 64U);
                float3  _S793 = extinction_in_0;
                float3  _S794 = extinction_in_0;
                uint2  _S795 = make_uint2 (_S759);
                float3  _S796 = (&ray_2)->unit_direction;
                uint _S797 = arrivalLobe_0(b_5, (&prev_0)->lobe);
                FKHit _S798 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S799 = _S798;
                ShadowContext _S800 = ShadowContext_x24init_0(_S793, _S794, _S795, _S796, b_5, _S797, false, geometry_density_0, width_5, &_S799, false);
                ShadowContext _S801 = _S800;
                TreeSample _S802 = sampleLightTree_0(_S789, _S790, _S791, 0.0f, true, _S792, &_S801);
                light_3 = _S802;
            }
            else
            {
                light_3 = _S788;
            }
            float _S803 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S804 = (fcptMaxBounces());
            bool _S805 = b_5 < _S804;
            if(_S805)
            {
                viewed_0 = (light_3.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S806 = _slang_select(viewed_0, _S803,0.0f);
            float3  _S807 = throughput_4 * light_3.radiance;
            float _S808 = powerHeuristic(light_3.density, _S806);
            float3  _S809 = _S807 * make_float3 (_S803 * _S808);
            float3  _S810 = _slang_select(is_inside_5, _S809,_S725);
            if(replay_0)
            {
                _S722 = b_5 == _S741;
            }
            else
            {
                _S722 = false;
            }
            if(_S722)
            {
                bool _S811 = _S730 == 2U;
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
                    _S724 = int(0);
                    ended_0 = _S813;
                    spread_0 = _S785;
                    geometry_density_0 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_5;
                    break;
                }
                _S724 = int(0);
                ended_0 = _S726;
                spread_0 = _S785;
                geometry_density_0 = width_5;
                chain_throughput_0 = throughput_4;
                layer_0 = b_5;
                break;
            }
            if(_S786)
            {
                Reservoir candidate_2 = _S758;
                uint _S814 = extractBits_0(_S758.path, 10U, 2U);
                bool _S815 = _S814 == 1U;
                if(_S815)
                {
                    float3  _S816 = safeDivide(_S810, _S725);
                    (&candidate_2)->radiance = _S816;
                }
                else
                {
                    uint _S817 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                    uint _S818 = insertBits_0(_S817, 2U, 10U, 2U);
                    (&candidate_2)->path = _S818;
                }
                Reservoir _S819 = withEnd(candidate_2, 0U, b_5, _S810);
                offer(sel_1, _S819, _S810 * make_float3 (scale_1) / make_float3 (density_2));
                float _S820 = survivalProbability(throughput_4, density_2);
                uint _S821 = stream(_S753, b_5 + 128U);
                Random _S822 = pcg(_S821);
                bool _S823 = _S820 < (_S822.value);
                if(_S823)
                {
                    _S723 = true;
                }
                else
                {
                    uint _S824 = (fcptMaxBounces());
                    _S723 = b_5 >= _S824;
                }
                if(_S723)
                {
                    _S724 = int(0);
                    ended_0 = _S726;
                    spread_0 = _S785;
                    geometry_density_0 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_5;
                    break;
                }
                float _S825 = density_2 * _S820;
                density_2 = _S825;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S826 = stream(_S753, b_5);
            float3  _S827 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S826, &phase_pdf_0);
            (&ray_2)->unit_direction = _S827;
            NEEVertex _S828 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S725, (&ray_2)->origin);
            nee_vertex_0 = _S828;
            Vertex _S829 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_0 = _S829;
            float _S830 = (&prev_0)->pdf;
            FKRay _S831 = ray_2;
            FKHit _S832 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S833 = (fcptTraverseInstanceBVH((_S831), (true), (4.294967296e+09f), (false), (_S832), (false)));
            hit_1 = _S833;
            b_3 = b_5;
            throughput_2 = throughput_4;
            threshold_0 = _S785;
            width_2 = width_5;
            sky_pdf_0 = _S830;
        }
        if(_S724 != int(1))
        {
            width_2 = geometry_density_0;
            throughput_2 = chain_throughput_0;
            b_3 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S726;
        spread_0 = threshold_0;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S834 = b_3 == 4294967295U;
    bool _S835 = ((&hit_1)->instance_index) == 4294967295U;
    if(_S835)
    {
        bool _S836 = !(&nee_vertex_0)->none;
        float _S837 = _slang_select(_S836, sky_pdf_0,0.0f);
        float _S838 = escapeWeight_0(_S837, (&ray_2)->unit_direction);
        float3  _S839 = environment_0((&ray_2)->unit_direction, b_3, (&prev_0)->lobe);
        float3  _S840 = throughput_2 * _S839;
        if(replay_0)
        {
            bool _S841 = b_3 == _S741;
            if(_S841)
            {
                passes_0 = _S730 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S840 * make_float3 (_S838) / make_float3 (r_1->jac), density_2 / r_1->jac);
            }
            if(_S740)
            {
                passes_0 = _S737;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_3 == _S728;
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
                return Shift_x24init_0(_S840 * make_float3 (_S838), 1.0f);
            }
            return _S726;
        }
        Reservoir candidate_3 = chain_0;
        uint _S842 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S843 = _S842 == 1U;
        if(_S843)
        {
            uint _S844 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S845 = _S844 == b_3;
            float _S846 = _slang_select(_S845, 1.0f,_S838);
            float3  _S847 = safeDivide(_S840 * make_float3 (_S846), _S725);
            (&candidate_3)->radiance = _S847;
        }
        else
        {
            bool _S848 = (&prev_0)->rough;
            if(_S848)
            {
                uint _S849 = insertBits_0(0U, b_3 + 1U, 5U, 5U);
                uint _S850 = insertBits_0(_S849, 3U, 10U, 2U);
                uint _S851 = insertBits_0(_S850, (&prev_0)->lobe, 15U, 3U);
                bool _S852 = (&prev_0)->inside;
                uint _S853 = _slang_select(_S852, 1U,0U);
                uint _S854 = insertBits_0(_S851, _S853, 22U, 1U);
                (&candidate_3)->path = _S854;
                (&candidate_3)->jac = (&prev_0)->pdf;
                (&candidate_3)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S855 = _S840 * make_float3 (_S838);
        Reservoir _S856 = withEnd(candidate_3, 3U, b_3, _S855);
        offer(sel_1, _S856, _S855 * make_float3 (scale_1) / make_float3 (density_2));
        return _S726;
    }
    float3  _S857 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S857;
    bool _S858 = (fcptVaryingUsed());
    if(_S858)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S859 = !replay_0;
        if(_S859)
        {
            float3  _S860 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S861 = sel_1->glow + _S860;
            sel_1->glow = _S861;
        }
        float3  _S862 = throughput_2 * weight_1;
        throughput_2 = _S862;
    }
    else
    {
        float3  _S863 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
        float3  _S864 = throughput_2 * _S863;
        throughput_2 = _S864;
    }
    float _S865 = width_2 + spread_0 * (&hit_1)->distance;
    uint _S866 = b_3 + 1U;
    b_3 = _S866;
    layer_0 = 0U;
    width_2 = _S865;
    passes_0 = false;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S725;
    float3  reconnection_0 = _S725;
    viewed_0 = _S834;
    for(;;)
    {
        bool _S867 = ((&hit_1)->is_point_light) == 1U;
        if(replay_0)
        {
            _S722 = _S730 == 1U;
        }
        else
        {
            _S722 = false;
        }
        if(_S722)
        {
            _S723 = b_3 == _S729;
        }
        else
        {
            _S723 = false;
        }
        bool _S868;
        if(_S723)
        {
            bool _S869 = ((&hit_1)->instance_index) != (_S742.instance_index);
            if(_S869)
            {
                _S868 = true;
            }
            else
            {
                _S868 = ((&hit_1)->triangle_index) != (_S742.triangle_index);
            }
        }
        else
        {
            _S868 = false;
        }
        if(_S868)
        {
            return _S726;
        }
        FKMedium _S870 = Medium_x24init_0(_S725, _S725, 0.0f);
        BSDFMaterial _S871 = Material_x24init_0(_S725, _S725, 0.0f, 0.0f, 0.0f, 0.0f, _S725, throughput_3, 1.0f, _S725, _S725, 0.5f, 0.0f, 0.0f, _S725);
        FKMedium _S872 = _S870;
        FKSurface _S873 = Surface_x24init_0(_S725, _S725, 0.0f, &_S871, false, 0U, 1.0f, false, &_S872, 4294967295U, _S725);
        bool _S874 = !_S867;
        bool scatter_2;
        bool is_inside_6;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S874)
        {
            uint _S875 = stream(_S753, b_3);
            uint _S876 = arrivalLobe_0(b_3, (&prev_0)->lobe);
            FKSurface _S877 = (fcptSurfaceAtPath((hit_1), ((&ray_2)->origin), (_S875), (width_2), (layer_0), (b_3), (_S876), ((&ray_2)->unit_direction)));
            bool _S878 = !passes_0;
            FKSurface _S879 = _S877;
            FKSurface _S880 = emitting_0(&_S879, _S878);
            uint _S881 = stream(_S753, b_3 + 256U);
            Random _S882 = pcg(_S881);
            FKSurface _S883 = _S880;
            FKSurface _S884 = uncovered_0(&_S883, _S882.value);
            float _S885 = facingSign(_S884.material.transmission, _S884.geometry_n, (&ray_2)->unit_direction);
            bool _S886 = _S885 < 0.0f;
            bool _S887 = (_S884.material.transmission) > 0.0f;
            if(_S887)
            {
                bool _S888 = arrivesBehind_0((&ray_2)->unit_direction, _S884.geometry_n);
                scatter_2 = _S888;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S889 = _S884;
            FKSurface _S890 = facingRay_0(&_S889, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S891 = arrivesBehind_0((&ray_2)->unit_direction, _S890.geometry_n);
                is_inside_6 = _S891;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S892 = beerLambert((&hit_1)->distance, _S890.material.absorption);
                float3  _S893 = throughput_2 * _S892;
                throughput_5 = _S893;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S894 = !_S890.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S890.geometry_n, (&ray_2)->unit_direction)))) / ((&hit_1)->distance * (&hit_1)->distance);
            bool _S895 = b_3 == _S866;
            if(_S895)
            {
                float _S896 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S896;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S897 = geometry_density_0;
            scatter_2 = _S894;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S897;
            surface_12 = _S890;
            turned_1 = _S886;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_12 = _S873;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S898;
        if(scatter_2)
        {
            _S898 = (&prev_0)->rough;
        }
        else
        {
            _S898 = false;
        }
        bool _S899;
        if(_S898)
        {
            _S899 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S899 = false;
        }
        FKSurface _S900 = surface_12;
        FKSurface _S901 = surface_12;
        float _S902 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        float2  _S903 = vertexEta(_S900.material, _S902);
        bool _S904;
        if(scatter_2)
        {
            uint _S905 = (fcptMaxBounces());
            bool _S906 = b_3 >= _S905;
            if(_S906)
            {
                _S904 = true;
            }
            else
            {
                bool _S907 = neeDecision(_S900.material, _S902, _S903.x, _S903.y);
                _S904 = _S907;
            }
        }
        else
        {
            _S904 = false;
        }
        bool _S908;
        if(passes_0)
        {
            _S908 = true;
        }
        else
        {
            _S908 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S908)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S904;
        }
        bool _S909 = (fcptHairUsed());
        bool _S910;
        if(_S909)
        {
            float3  _S911 = surface_12.hair;
            _S910 = (dot_0(_S911, _S911)) > 0.0f;
        }
        else
        {
            _S910 = false;
        }
        bool _S912;
        if(_S910)
        {
            _S912 = true;
        }
        else
        {
            BSDFMaterial _S913 = _S900.material;
            bool _S914 = isTranslucent_0(&_S913);
            _S912 = _S914;
        }
        bool _S915;
        if(_S912)
        {
            _S915 = true;
        }
        else
        {
            bool _S916 = (_S900.material.transmission) > 0.0f;
            if(_S916)
            {
                uint _S917 = (fcptLayers((hit_1)));
                _S915 = _S917 == 1U;
            }
            else
            {
                _S915 = false;
            }
        }
        float3  emission_0;
        if(_S867)
        {
            float3  _S918 = (fcptCalculatePointLightContrib(((&hit_1)->instance_index)));
            emission_0 = _S918;
        }
        else
        {
            emission_0 = _S900.material.emissive;
        }
        bool _S919 = !replay_0;
        bool _S920;
        if(_S919)
        {
            _S920 = true;
        }
        else
        {
            _S920 = b_3 >= _S741;
        }
        bool _S921;
        if(_S920)
        {
            float _S922 = rgb_to_greyscale(emission_0);
            _S921 = _S922 > 0.0f;
        }
        else
        {
            _S921 = false;
        }
        float3  emission_1;
        if(_S921)
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
        if(replay_0)
        {
            _S926 = _S730 == 1U;
        }
        else
        {
            _S926 = false;
        }
        bool _S927;
        if(_S926)
        {
            _S927 = b_3 > _S729;
        }
        else
        {
            _S927 = false;
        }
        bool _S928;
        if(_S927)
        {
            _S928 = b_3 == _S728;
        }
        else
        {
            _S928 = false;
        }
        bool _S929;
        if(_S928)
        {
            bool _S930 = _S731 == 1U;
            if(_S930)
            {
                _S929 = true;
            }
            else
            {
                _S929 = _S731 == 2U;
            }
        }
        else
        {
            _S929 = false;
        }
        if(_S929)
        {
            bool _S931 = _S867 != (_S731 == 2U);
            if(_S931)
            {
                return _S726;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_1->jac), density_2 / r_1->jac);
        }
        uint _S932 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S933 = _S932 == 1U;
        Reservoir here_0 = chain_0;
        uint _S934 = insertBits_0(0U, b_3, 5U, 5U);
        uint _S935 = insertBits_0(_S934, 1U, 10U, 2U);
        uint _S936 = insertBits_0(_S935, (&prev_0)->lobe, 15U, 3U);
        bool _S937 = (&prev_0)->inside;
        uint _S938 = _slang_select(_S937, 1U,0U);
        uint _S939 = insertBits_0(_S936, _S938, 22U, 1U);
        (&here_0)->path = _S939;
        float _S940 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S940;
        fcptWithReservoirHit((&here_0), (&hit_1));
        bool _S941;
        if(replay_0)
        {
            _S941 = _S730 == 1U;
        }
        else
        {
            _S941 = false;
        }
        bool _S942;
        if(_S941)
        {
            _S942 = b_3 == _S729;
        }
        else
        {
            _S942 = false;
        }
        bool _S943 = b_3 == _S741;
        bool _S944;
        if(_S943)
        {
            bool _S945 = !scatter_2;
            if(_S945)
            {
                _S944 = true;
            }
            else
            {
                bool _S946 = _S730 != 1U;
                if(_S946)
                {
                    _S944 = _S730 != 3U;
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
        bool _S947;
        if(_S944)
        {
            _S947 = _S730 == 2U;
        }
        else
        {
            _S947 = false;
        }
        bool _S948;
        if(_S947)
        {
            _S948 = !_S899;
        }
        else
        {
            _S948 = false;
        }
        bool _S949;
        if(_S948)
        {
            _S949 = _S731 != 4U;
        }
        else
        {
            _S949 = false;
        }
        bool _S950 = _S729 == _S728;
        bool _S951;
        if(_S950)
        {
            _S951 = _S731 == 0U;
        }
        else
        {
            _S951 = false;
        }
        bool _S952;
        if(_S951)
        {
            _S952 = ((&hit_1)->instance_index) == (_S742.instance_index);
        }
        else
        {
            _S952 = false;
        }
        bool _S953;
        if(_S952)
        {
            _S953 = ((&hit_1)->triangle_index) == (_S742.triangle_index);
        }
        else
        {
            _S953 = false;
        }
        bool _S954;
        if(_S953)
        {
            _S954 = _S899;
        }
        else
        {
            _S954 = false;
        }
        bool _S955 = _slang_select(_S942, _S954,_S949);
        bool _S956;
        if(nee_0)
        {
            _S956 = _slang_select(replay_0, _S955,scatter_2);
        }
        else
        {
            _S956 = false;
        }
        TreeSample _S957 = TreeSample_x24init_0(_S725, _S725, 0.0f, 0U);
        float3  throughput_6;
        float3  lit_0;
        if(_S956)
        {
            float3  _S958 = (&ray_2)->origin;
            if(_S910)
            {
                throughput_6 = _S725;
            }
            else
            {
                throughput_6 = _S901.smooth_n;
            }
            FKSurface _S959 = surface_12;
            uint _S960 = stream(_S753, b_3 + 64U);
            uint _S961 = arrivalLobe_0(b_3, (&prev_0)->lobe);
            FKSurface _S962 = surface_12;
            FKHit _S963 = hit_1;
            ShadowContext _S964 = shadowContext_0(&_S962, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_3, _S961, (&hit_1)->distance, width_2, &_S963, _S910);
            ShadowContext _S965 = _S964;
            TreeSample _S966 = sampleLightTree_0(_S958, throughput_6, surface_12.geometry_n, surface_12.geometry_offset, _S915, _S960, &_S965);
            bool _S967 = any_0((_S966.radiance) != _S725);
            if(_S967)
            {
                if(_S910)
                {
                    uint _S968 = (fcptMaxBounces());
                    bool _S969 = b_3 < _S968;
                    FKSurface _S970 = surface_12;
                    TreeSample _S971 = _S966;
                    float3  _S972 = hairLight_0(&_S970, (&ray_2)->unit_direction, &_S971, _S969);
                    lit_0 = _S972;
                }
                else
                {
                    float _S973 = _S903.x;
                    float _S974 = _S903.y;
                    uint _S975 = (fcptMaxBounces());
                    bool _S976 = b_3 < _S975;
                    TreeSample _S977 = _S966;
                    BSDFMaterial _S978 = _S900.material;
                    float3  _S979 = lightBSDF_0((&ray_2)->unit_direction, &_S977, _S901.smooth_n, _S959.geometry_n, &_S978, _S973, _S974, _S976, surface_12.random_state);
                    lit_0 = _S979;
                }
            }
            else
            {
                lit_0 = _S725;
            }
            light_3 = _S966;
        }
        else
        {
            light_3 = _S957;
            lit_0 = _S725;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S980;
        bool _S981;
        float density_4;
        if(_S942)
        {
            bool _S982 = !_S899;
            if(_S982)
            {
                return _S726;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S950)
            {
                viewed_1 = _S731 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            if(_S950)
            {
                refracted_4 = _S731 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S983 = !nee_0;
                if(_S983)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S984 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S984 > 0.0f);
                }
                if(passes_0)
                {
                    return _S726;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            if(_S950)
            {
                wrong_side_0 = _S731 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S985 = !nee_0;
                if(_S985)
                {
                    return _S726;
                }
                float _S986 = environmentPdf_0(r_1->dir);
                float3  _S987 = skyBSDF((&ray_2)->unit_direction, r_1->dir, surface_12, _S903, is_inside_6, _S986, surface_12.random_state);
                return Shift_x24init_0(throughput_7 * _S987 * r_1->radiance / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            uint _S988 = extractBits_0(_S727, 21U, 1U);
            bool _S989 = nee_0 != (_S988 == 1U);
            if(_S989)
            {
                return _S726;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_0)
            {
                viewed_1 = _S943;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S990 = !scatter_2;
                if(_S990)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S991 = _S730 != 1U;
                    if(_S991)
                    {
                        refracted_4 = _S730 != 3U;
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
                bool _S992 = _S730 == 2U;
                if(_S992)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S899;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S731 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    uint _S993 = stream(_S753, b_3 + 448U);
                    FKRay _S994 = ray_2;
                    FKSurface _S995 = surface_12;
                    SkySample _S996 = sampleSky_0(&_S994, &_S995, _S903, is_inside_6, _S993, surface_12.random_state);
                    return Shift_x24init_0(throughput_5 * _S996.color, 1.0f);
                }
                if(_S992)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S899;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S997 = rgb_to_greyscale(light_3.radiance);
                    bool _S998 = !(_S997 > 0.0f);
                    if(_S998)
                    {
                        return _S726;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S740)
                {
                    passes_0 = _S731 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S867;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S740)
                {
                    passes_0 = _S731 == 1U;
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
                    passes_0 = !_S899;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S726;
            }
            else
            {
                if(_S919)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S999 = b_3 > 0U;
                    if(_S999)
                    {
                        Reservoir candidate_4 = chain_0;
                        if(_S933)
                        {
                            float3  _S1000 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_4)->radiance = _S1000;
                        }
                        else
                        {
                            if(_S899)
                            {
                                candidate_4 = here_0;
                            }
                        }
                        float3  _S1001 = throughput_5 * emission_1;
                        Reservoir _S1002 = withEnd(candidate_4, 1U, b_3, _S1001);
                        offer(sel_1, _S1002, _S1001 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1003 = throughput_5 * emission_1;
                        float3  _S1004 = sel_1->glow + _S1003;
                        sel_1->glow = _S1004;
                    }
                    if(nee_0)
                    {
                        float3  _S1005 = throughput_5 * lit_0;
                        Reservoir candidate_5 = chain_0;
                        if(_S933)
                        {
                            float3  _S1006 = safeDivide(_S1005, chain_throughput_0);
                            (&candidate_5)->radiance = _S1006;
                        }
                        else
                        {
                            if(_S899)
                            {
                                candidate_5 = here_0;
                                uint _S1007 = insertBits_0((&candidate_5)->path, 1U, 21U, 1U);
                                (&candidate_5)->path = _S1007;
                                (&candidate_5)->dir = light_3.dir;
                                (&candidate_5)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1008 = insertBits_0(0U, b_3 + 1U, 5U, 5U);
                                uint _S1009 = insertBits_0(_S1008, 2U, 10U, 2U);
                                (&candidate_5)->path = _S1009;
                            }
                        }
                        Reservoir _S1010 = withEnd(candidate_5, 0U, b_3, _S1005);
                        offer(sel_1, _S1010, _S1005 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S910)
                        {
                            _S980 = false;
                        }
                        else
                        {
                            bool _S1011 = environmentMapped_0();
                            _S980 = _S1011;
                        }
                    }
                    else
                    {
                        _S980 = false;
                    }
                    if(_S980)
                    {
                        uint _S1012 = (fcptMaxBounces());
                        _S981 = b_3 < _S1012;
                    }
                    else
                    {
                        _S981 = false;
                    }
                    if(_S981)
                    {
                        uint _S1013 = stream(_S753, b_3 + 448U);
                        FKRay _S1014 = ray_2;
                        FKSurface _S1015 = surface_12;
                        SkySample _S1016 = sampleSky_0(&_S1014, &_S1015, _S903, is_inside_6, _S1013, surface_12.random_state);
                        float3  _S1017 = throughput_5 * _S1016.color;
                        Reservoir candidate_6 = chain_0;
                        if(_S933)
                        {
                            float3  _S1018 = safeDivide(_S1017, chain_throughput_0);
                            (&candidate_6)->radiance = _S1018;
                        }
                        else
                        {
                            if(_S899)
                            {
                                candidate_6 = here_0;
                                uint _S1019 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1019;
                                (&candidate_6)->dir = _S1016.dir;
                                (&candidate_6)->radiance = _S1016.radiance;
                            }
                            else
                            {
                                uint _S1020 = insertBits_0(0U, b_3 + 1U, 5U, 5U);
                                uint _S1021 = insertBits_0(_S1020, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1021;
                            }
                        }
                        Reservoir _S1022 = withEnd(candidate_6, 4U, b_3, _S1017);
                        offer(sel_1, _S1022, _S1017 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1023;
        bool _S1024;
        bool straight_0;
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
        bool _S1035;
        bool _S1036;
        bool _S1037;
        bool _S1038;
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
                viewed_1 = _S943;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1039 = extractBits_0(_S727, 15U, 3U);
            uint _S1040 = extractBits_0(_S727, 18U, 3U);
            uint _S1041 = _slang_select(_S942, _S1040,_S1039);
            float3  _S1042 = r_1->dir;
            bool refracted_5 = _S1041 == 1U;
            SampleBSDF _S1043 = SampleBSDF_x24init_0(_S725, _S725, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1043;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1044 = extractBits_0(_S727, 22U, 1U);
                bool _S1045 = is_inside_6 != (_S1044 == 1U);
                if(_S1045)
                {
                    return _S726;
                }
                bool _S1046 = _S730 == 1U;
                if(_S1046)
                {
                    float3  _S1047 = (fcptHitPosition((_S742)));
                    throughput_8 = _S1047;
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
                    BSDFMaterial _S1048 = _S900.material;
                    bool _S1049 = isTranslucent_0(&_S1048);
                    if(_S1049)
                    {
                        refracted_4 = _S1041 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1050 = throughput_8 - (&ray_2)->origin;
                        float3  _S1051 = _slang_select(_S1046, _S1050,_S1042);
                        wrong_side_0 = (dot_0(_S901.smooth_n, _S1051) * _S902) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1046)
                {
                    float3  _S1052 = (&ray_2)->origin;
                    FKSurface _S1053 = surface_12;
                    float3  _S1054 = - _S901.smooth_n;
                    bool _S1055 = is_inside_6 != refracted_4;
                    float3  _S1056 = _slang_select(_S1055, _S1054,_S901.smooth_n);
                    float3  _S1057 = throughput_8 - (_S1052 + make_float3 (_S1053.geometry_offset) * _S1056);
                    float3  _S1058 = ((((_S1057)) * make_float3(rnorm3df(((_S1057)).x, ((_S1057)).y, ((_S1057)).z))));
                    reconnection_1 = _S1058;
                }
                else
                {
                    reconnection_1 = _S1042;
                }
                if(_S910)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1059 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1059;
                }
                if(wrong_side_0)
                {
                    return _S726;
                }
                float3  _S1060 = throughput_8;
                throughput_8 = reconnection_1;
                b_6 = _S1041;
                wrong_side_0 = false;
                reconnection_1 = _S1060;
            }
            else
            {
                bool _S1061 = !_S942;
                if(_S1061)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1062;
                    if(_S910)
                    {
                        SampleBSDF _S1063 = (fcptSampleHair((surface_12.hair), (_S900.material.albedo), (_S900.material.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1062 = _S1063;
                    }
                    else
                    {
                        SampleBSDF _S1064 = sampleBSDF((&ray_2)->unit_direction, _S901.smooth_n, _S900.material, _S903.x, _S903.y, surface_12.random_state, make_float2 (0.0f));
                        _S1062 = _S1064;
                    }
                    bsdf_sampled_0 = _S1062;
                    if(_S910)
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
                            return _S726;
                        }
                        break;
                    }
                    if(_S910)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1065 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1065;
                    }
                    if(wrong_side_0)
                    {
                        _S980 = (_S900.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S980 = false;
                    }
                    if(_S980)
                    {
                        SampleBSDF _S1066 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S900.material, _S903.x, _S903.y, (&bsdf_sampled_0)->random_state, make_float2 (0.0f));
                        (&bsdf_sampled_0)->unit_direction = _S1066.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1066.refracted;
                        (&bsdf_sampled_0)->throughput = _S1066.throughput;
                        (&bsdf_sampled_0)->lobe = _S1066.lobe;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1067 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1067;
                        }
                    }
                    uint _S1068 = (&bsdf_sampled_0)->lobe;
                    float3  _S1069 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1070 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1071 = (&bsdf_sampled_0)->pdf;
                    float _S1072 = _slang_select(wrong_side_0, 0.0f,_S1071);
                    (&lobe_5)->pdf = _S1072;
                    throughput_8 = _S1069;
                    b_6 = _S1068;
                    refracted_4 = _S1070;
                }
                else
                {
                    throughput_8 = _S1042;
                    b_6 = _S1041;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S980 = true;
            }
            else
            {
                _S980 = _S942;
            }
            float3  chain_throughput_1;
            if(_S980)
            {
                if(_S910)
                {
                    SampleBSDF _S1073 = (fcptConnectHair((surface_12.hair), (_S900.material.albedo), (_S900.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    lobe_5 = _S1073;
                }
                else
                {
                    float3  _S1074 = (&ray_2)->unit_direction;
                    float _S1075 = sign_0(_S902);
                    float3  _S1076 = _S901.smooth_n * make_float3 (_S1075);
                    float _S1077 = dot_0(_S1076, throughput_8);
                    float _S1078 = _S900.material.roughness;
                    float _S1079 = _S1078 * _S1078;
                    AnisotropicFrame _S1080 = anisotropicFrame(_S900.material, _S1076);
                    float3  _S1081 = negate_0(_S1074);
                    SheenProfile _S1082 = sheenProfile(_S1081, _S1076, _S900.material);
                    float3  _S1083 = reflectedHalf(_S1074, throughput_8);
                    bool _S1084 = b_6 == 1U;
                    if(_S1084)
                    {
                        float3  _S1085 = refractedHalf(_S1074, throughput_8, _S901.smooth_n, _S903.x, _S903.y);
                        throughput_9 = _S1085;
                    }
                    else
                    {
                        throughput_9 = _S1083;
                    }
                    bool _S1086 = b_6 == 0U;
                    if(_S1086)
                    {
                        float3  _S1087 = sampledHalf(_S1074, _S901.smooth_n, _S900.material, surface_12.random_state, _S1080);
                        throughput_10 = _S1087;
                    }
                    else
                    {
                        throughput_10 = throughput_9;
                    }
                    float3  _S1088 = negate_0(_S1074);
                    float _S1089 = _S903.x;
                    float _S1090 = _S903.y;
                    BSDFLobes _S1091 = bsdfLobes(_S1074, _S1088, _S1076, throughput_10, _S900.material, _S1089, _S1090, _S1080, _S1082);
                    BSDFLobes lobe_terms_1 = _S1091;
                    float _S1092 = translucentShare(_S900.material);
                    (&lobe_terms_1)->translucent_share = _S1092;
                    switch(b_6)
                    {
                    case 0U:
                        {
                            float _S1093 = diffusePDF(_S1077, 0.0f, (F32_abs((_S902))), _S1079, lobe_terms_1, _S1089, _S1090);
                            float3  _S1094 = diffuseBSDF(throughput_8, _S1076, _S1079, _S900.material, lobe_terms_1);
                            density_6 = _S1093;
                            chain_throughput_1 = _S1094;
                            break;
                        }
                    case 1U:
                        {
                            float _S1095 = refractPDF(_S1077, dot_0(throughput_8, throughput_10), (F32_abs((_S902))), _S1079, lobe_terms_1, _S1089, _S1090);
                            float3  _S1096 = refractBSDF(throughput_8, _S1076, _S1079, _S900.material, lobe_terms_1);
                            density_6 = _S1095;
                            chain_throughput_1 = _S1096;
                            break;
                        }
                    case 4U:
                        {
                            float _S1097 = sheenVelvetPDF(_S1077, 0.0f, (F32_abs((_S902))), _S1079, lobe_terms_1, _S1089, _S1090);
                            float3  _S1098 = sheenVelvetBSDF(throughput_8, _S1076, _S1079, _S900.material, lobe_terms_1);
                            density_6 = _S1097;
                            chain_throughput_1 = _S1098;
                            break;
                        }
                    default:
                        {
                            float _S1099 = reflectPDF(_S1077, 0.0f, (F32_abs((_S902))), _S1079, lobe_terms_1, _S1089, _S1090);
                            float3  _S1100 = reflectBSDF(throughput_8, _S1076, _S1079, _S900.material, lobe_terms_1);
                            density_6 = _S1099;
                            chain_throughput_1 = _S1100;
                            break;
                        }
                    }
                    bool _S1101 = density_6 > 0.0f;
                    if(_S1101)
                    {
                        SampleBSDF _S1102 = SampleBSDF_x24init_0(throughput_8, chain_throughput_1, surface_12.random_state, _S1084, b_6, density_6);
                        lobe_5 = _S1102;
                    }
                }
            }
            bool _S1103 = b_6 == 0U;
            if(_S1103)
            {
                _S981 = true;
            }
            else
            {
                _S981 = b_6 == 4U;
            }
            if(_S910)
            {
                _S1023 = false;
            }
            else
            {
                bool _S1104 = !_S981;
                if(_S1104)
                {
                    bool _S1105 = (_S900.material.roughness) == 0.0f;
                    if(_S1105)
                    {
                        _S1023 = true;
                    }
                    else
                    {
                        bool _S1106 = b_6 == 1U;
                        if(_S1106)
                        {
                            _S1023 = (_S903.x) == (_S903.y);
                        }
                        else
                        {
                            _S1023 = false;
                        }
                    }
                }
                else
                {
                    _S1023 = false;
                }
            }
            bool _S1107 = !_S910;
            if(_S1107)
            {
                _S1024 = b_6 == 1U;
            }
            else
            {
                _S1024 = false;
            }
            if(_S1024)
            {
                straight_0 = (_S900.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1025 = _S1107;
            }
            else
            {
                _S1025 = false;
            }
            if(_S1025)
            {
                _S1026 = b_6 == 1U;
            }
            else
            {
                _S1026 = false;
            }
            if(_S1026)
            {
                _S1027 = (_S903.x) == (_S903.y);
            }
            else
            {
                _S1027 = false;
            }
            BSDFMaterial _S1108 = _S900.material;
            bool _S1109 = isTranslucent_0(&_S1108);
            if(_S1109)
            {
                _S1028 = _S1103;
            }
            else
            {
                _S1028 = false;
            }
            if(_S1028)
            {
                _S1029 = (dot_0(throughput_8, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1029 = false;
            }
            if(nee_0)
            {
                _S1030 = !_S1023;
            }
            else
            {
                _S1030 = false;
            }
            if(_S1030)
            {
                _S1031 = !wrong_side_0;
            }
            else
            {
                _S1031 = false;
            }
            if(_S1031)
            {
                float _S1110 = (&lobe_5)->pdf;
                float3  _S1111 = (&ray_2)->origin;
                float3  _S1112 = _slang_select(_S915, _S725,_S901.smooth_n);
                float3  _S1113 = (&ray_2)->origin;
                FKSurface _S1114 = surface_12;
                float3  _S1115 = - _S901.smooth_n;
                float3  _S1116 = _slang_select(_S1029, _S1115,_S901.smooth_n);
                NEEVertex _S1117 = NEEVertex_x24init_0(false, _S1110, _S1111, _S1112, _S1113 + make_float3 (_S1114.geometry_offset) * _S1116);
                nee_vertex_0 = _S1117;
            }
            else
            {
                if(_S910)
                {
                    _S1032 = true;
                }
                else
                {
                    bool _S1118 = b_6 != 1U;
                    if(_S1118)
                    {
                        _S1032 = true;
                    }
                    else
                    {
                        _S1032 = (_S903.x) != (_S903.y);
                    }
                }
                if(_S1032)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1119 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1119)
            {
                if(_S981)
                {
                    _S1032 = true;
                }
                else
                {
                    _S1032 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_1)->distance * (&hit_1)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1032 = false;
            }
            bool _S1120 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1120)
            {
                if(_S981)
                {
                    _S1033 = true;
                }
                else
                {
                    _S1033 = (_S900.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1033 = false;
            }
            if(_S942)
            {
                bool _S1121 = !_S1032;
                if(_S1121)
                {
                    return _S726;
                }
                bool _S1122 = _S731 != 1U;
                if(_S1122)
                {
                    _S1034 = _S731 != 2U;
                }
                else
                {
                    _S1034 = false;
                }
                if(_S1034)
                {
                    float _S1123 = (&lobe_5)->pdf;
                    float _S1124 = _slang_select(nee_0, _S1123,0.0f);
                    float _S1125 = escapeWeight_0(_S1124, _S1042);
                    if(_S950)
                    {
                        passes_0 = _S737;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1126 = _slang_select(passes_0, _S1125,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_1->radiance * make_float3 (_S1126) / make_float3 (r_1->jac), density_4 * (&lobe_5)->pdf / r_1->jac);
                }
                float3  _S1127 = throughput_6 * make_float3 ((&lobe_5)->pdf);
                float _S1128 = density_4 * (&lobe_5)->pdf;
                throughput_9 = _S1127;
                density_6 = _S1128;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1129 = (fcptLayers((hit_1)));
            bool _S1130 = _S1129 > 1U;
            if(_S1130)
            {
                _S1034 = (b_6 == 1U) != passes_0;
            }
            else
            {
                _S1034 = false;
            }
            if(viewed_1)
            {
                _S1035 = _S1034;
            }
            else
            {
                _S1035 = false;
            }
            if(_S1035)
            {
                return _S726;
            }
            if(replay_0)
            {
                _S1036 = b_3 <= _S741;
            }
            else
            {
                _S1036 = false;
            }
            if(_S1036)
            {
                _S1037 = _S899;
            }
            else
            {
                _S1037 = false;
            }
            if(_S1037)
            {
                _S1038 = _S1032;
            }
            else
            {
                _S1038 = false;
            }
            bool _S1131;
            if(_S1038)
            {
                _S1131 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1131 = !_S1033;
                }
                else
                {
                    _S1131 = false;
                }
            }
            if(_S1131)
            {
                return _S726;
            }
            if(viewed_1)
            {
                float3  _S1132 = throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1133 = (&lobe_5)->pdf;
                throughput_10 = _S1132;
                sky_pdf_2 = _S1133;
            }
            else
            {
                float3  _S1134 = throughput_9 * max_0((&lobe_5)->throughput, _S725);
                throughput_10 = _S1134;
                sky_pdf_2 = density_6;
            }
            bool _S1135;
            if(_S919)
            {
                _S1135 = !_S933;
            }
            else
            {
                _S1135 = false;
            }
            bool _S1136;
            if(_S1135)
            {
                _S1136 = _S899;
            }
            else
            {
                _S1136 = false;
            }
            bool _S1137;
            if(_S1136)
            {
                _S1137 = _S1032;
            }
            else
            {
                _S1137 = false;
            }
            if(_S1137)
            {
                chain_0 = here_0;
                uint _S1138 = insertBits_0((&chain_0)->path, b_6, 18U, 3U);
                uint _S1139 = _slang_select(nee_0, 1U,0U);
                uint _S1140 = insertBits_0(_S1138, _S1139, 21U, 1U);
                (&chain_0)->path = _S1140;
                float _S1141 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1141;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1142 = surface_12;
            Vertex _S1143 = Vertex_x24init_0(_S1033, b_6, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1143;
            float _S1144 = (&lobe_5)->pdf;
            bool _S1145 = b_6 == 1U;
            bool _S1146;
            if(_S1145)
            {
                _S1146 = (_S903.x) == (_S903.y);
            }
            else
            {
                _S1146 = false;
            }
            float sky_pdf_3 = _slang_select(_S1146, sky_pdf_0,_S1144);
            float _S1147 = _slang_select(_S910, 0.0f,sky_pdf_3);
            float _S1148 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1149 = !_S1023;
            float _S1150 = _slang_select(_S1149, _S1148,0.0f);
            float _S1151 = spread_0 + _S1150;
            bool _S1152;
            if(refracted_4)
            {
                _S1152 = !_S1029;
            }
            else
            {
                _S1152 = false;
            }
            bool is_inside_7;
            if(_S1152)
            {
                bool _S1153 = !is_inside_6;
                is_inside_7 = _S1153;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1154 = surface_12;
            bool _S1155 = boundsVolume_0(&_S1154);
            bool _S1156;
            if(_S1155)
            {
                _S1156 = !_S1034;
            }
            else
            {
                _S1156 = false;
            }
            if(_S1156)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1157 = - _S1142.geometry_n;
                float3  _S1158 = _slang_select(turned_1, _S1157,_S1142.geometry_n);
                (&faced_2)->geometry_n = _S1158;
                FKMedium _S1159 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKSurface _S1160 = faced_2;
                FKMedium _S1161 = _S1159;
                MediumSides _S1162 = mediumSides_0(&_S1160, &_S1161, filling_2, (&ray_2)->unit_direction);
                bool _S1163 = ((dot_0(throughput_8, _S1142.geometry_n)) > 0.0f) == ((dot_0(_S1142.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1164 = _slang_select(_S1163, _S1162.front.scatter,_S1162.behind.scatter);
                scatter_in_0 = _S1164;
                float3  _S1165 = _slang_select(_S1163, _S1162.front.extinction,_S1162.behind.extinction);
                extinction_in_0 = _S1165;
                float _S1166 = _slang_select(_S1163, _S1162.front.g,_S1162.behind.g);
                g_in_0 = _S1166;
                uint _S1167 = _S1162.fillings.x;
                uint _S1168 = _S1162.fillings.y;
                uint _S1169 = _slang_select(_S1163, _S1168,_S1167);
                bool _S1170 = (fcptVaryingUsed());
                uint _S1171 = _slang_select(_S1170, _S1169,4294967295U);
                filling_2 = _S1171;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1172 = !_S1034;
            if(_S1172)
            {
                FKSurface _S1173 = surface_12;
                float _S1174 = _slang_select(straight_0, 0.0f,_S1173.geometry_offset);
                float3  _S1175 = - _S901.smooth_n;
                bool _S1176 = is_inside_7 != _S1029;
                float3  _S1177 = _slang_select(_S1176, _S1175,_S901.smooth_n);
                float3  _S1178 = (&ray_2)->origin + make_float3 (_S1174) * _S1177;
                (&ray_2)->origin = _S1178;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1034;
            viewed_1 = _S1027;
            sky_pdf_2 = _S1147;
            spread_3 = _S1151;
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
        if(_S919)
        {
            if(_S867)
            {
                float3  _S1179 = throughput_9 * emission_1;
                Reservoir candidate_7 = chain_0;
                uint _S1180 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1181 = _S1180 == 1U;
                if(_S1181)
                {
                    float3  _S1182 = safeDivide(_S1179, chain_throughput_0);
                    (&candidate_7)->radiance = _S1182;
                }
                Reservoir _S1183 = withEnd(candidate_7, 2U, b_3, _S1179);
                offer(sel_1, _S1183, _S1179 * make_float3 (scale_1) / make_float3 (density_6));
            }
            if(_S867)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1184 = survivalProbability(throughput_9, density_6);
                density_7 = _S1184;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1185 = stream(_S753, b_3 + 128U);
            Random _S1186 = pcg(_S1185);
            bool _S1187 = density_7 < (_S1186.value);
            if(_S1187)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1188 = (fcptMaxBounces());
                wrong_side_0 = b_3 >= _S1188;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1189 = density_6 * density_7;
            density_7 = _S1189;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1190 = layer_0 ^ 1U;
        uint _S1191 = _slang_select(passes_0, _S1190,0U);
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
            uint _S1192 = b_6 + 1U;
            b_3 = _S1192;
            layer_0 = _S1191;
            continue;
        }
        FKRay _S1193 = ray_2;
        float _S1194 = distance_3(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_0)
        {
            refracted_4 = _S943;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S730 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1195 = _slang_select(wrong_side_0, _S1194,4.294967296e+09f);
        bool _S1196 = !_S910;
        if(straight_0)
        {
            _S980 = true;
        }
        else
        {
            _S980 = _S910;
        }
        FKHit _S1197;
        if(_S980)
        {
            _S1197 = hit_1;
        }
        else
        {
            _S1197 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
        }
        FKHit _S1198 = (fcptTraverseInstanceBVH((_S1193), (_S874), (_S1195), (_S1196), (_S1197), (viewed_1)));
        hit_1 = _S1198;
        if(replay_0)
        {
            _S981 = _S943;
        }
        else
        {
            _S981 = false;
        }
        if(_S981)
        {
            _S1023 = _S730 == 1U;
        }
        else
        {
            _S1023 = false;
        }
        if(_S1023)
        {
            _S1024 = ((&hit_1)->instance_index) == (_S742.instance_index);
        }
        else
        {
            _S1024 = false;
        }
        if(_S1024)
        {
            _S1025 = ((&hit_1)->triangle_index) == (_S742.triangle_index);
        }
        else
        {
            _S1025 = false;
        }
        if(_S1025)
        {
            (&hit_1)->uv = _S742.uv;
            float _S1199 = distance_3(reconnection_0, (&ray_2)->origin);
            (&hit_1)->distance = _S1199;
        }
        if(replay_0)
        {
            _S1026 = _S943;
        }
        else
        {
            _S1026 = false;
        }
        if(_S1026)
        {
            _S1027 = _S730 == 3U;
        }
        else
        {
            _S1027 = false;
        }
        if(_S1027)
        {
            _S1028 = ((&hit_1)->instance_index) != 4294967295U;
        }
        else
        {
            _S1028 = false;
        }
        if(_S1028)
        {
            return _S726;
        }
        Reservoir _S1200 = chain_0;
        uint _S1201 = filling_2;
        for(;;)
        {
            bool _S1202 = (fcptVaryingUsed());
            if(_S1202)
            {
                _S1029 = _S1201 != 4294967295U;
            }
            else
            {
                _S1029 = false;
            }
            float _S1203;
            if(_S1029)
            {
                float _S1204 = (fcptMajorant((_S1201)));
                _S1203 = _S1204;
            }
            else
            {
                _S1203 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_0)
            {
                _S1030 = _S943;
            }
            else
            {
                _S1030 = false;
            }
            if(_S1030)
            {
                _S1031 = _S730 == 1U;
            }
            else
            {
                _S1031 = false;
            }
            if(_S1031)
            {
                _S1032 = _S1203 > 0.0f;
            }
            else
            {
                _S1032 = false;
            }
            if(_S1032)
            {
                ended_0 = _S726;
                sky_pdf_1 = sky_pdf_2;
                spread_1 = spread_3;
                width_3 = width_2;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_6 = b_3;
                _S1033 = true;
                break;
            }
            bool _S1205 = (&prev_0)->rough;
            if(_S1205)
            {
                _S1033 = !(_S1203 > 0.0f);
            }
            else
            {
                _S1033 = false;
            }
            (&prev_0)->rough = _S1033;
            uint _S1206 = b_3 + 320U;
            bool _S1207 = b_3 == 4294967295U;
            uint _S1208 = _slang_select(_S1207, 384U,_S1206);
            uint _S1209 = stream(_S753, _S1208);
            uint tracking_1 = _S1209;
            weight_1 = throughput_3;
            glowed_0 = _S725;
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
                    _S724 = int(2);
                    break;
                }
                uint _S1210 = b_6 + 320U;
                bool _S1211 = b_6 == 4294967295U;
                uint _S1212 = _slang_select(_S1211, 384U,_S1210);
                uint _S1213 = stream(_S753, _S1212);
                Random _S1214 = pcg(_S1213);
                float _S1215 = - (F32_log((1.0f - _S1214.value))) / _S1203;
                if(_S1029)
                {
                    float3  _S1216 = (&ray_2)->origin;
                    float3  _S1217 = (&ray_2)->unit_direction;
                    float _S1218 = (&hit_1)->distance;
                    uint _S1219 = _slang_select(_S1211, 0U,b_6);
                    uint _S1220 = (&prev_0)->lobe;
                    uint _S1221 = _slang_select(_S1211, 3U,_S1220);
                    float _S1222 = (fcptTrackMedium((_S1201), (_S1216), (_S1217), (_S1218), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1219), (_S1221), (_S1211)));
                    spread_2 = _S1222;
                }
                else
                {
                    spread_2 = _S1215;
                }
                bool _S1223 = !(spread_2 < ((&hit_1)->distance));
                if(_S1223)
                {
                    _S724 = int(2);
                    break;
                }
                if(_S1029)
                {
                    _S1034 = _S919;
                }
                else
                {
                    _S1034 = false;
                }
                if(_S1034)
                {
                    float3  _S1224 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1225 = sel_1->glow + _S1224;
                    sel_1->glow = _S1225;
                }
                else
                {
                }
                glowed_0 = _S725;
                uint b_7 = b_6 + 1U;
                float3  _S1226 = (&ray_2)->origin + make_float3 (spread_2) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1226;
                float3  _S1227 = flightWeight_0(scatter_in_0, extinction_in_0, _S1203, spread_2, true);
                float3  _S1228 = weight_1;
                float3  _S1229 = _slang_select(_S1029, _S1228,_S1227);
                float3  throughput_11 = throughput_10 * _S1229;
                uint _S1230 = stream(_S753, b_7 + 320U);
                tracking_1 = _S1230;
                weight_1 = throughput_3;
                float width_6 = width_3 + spread_1 * spread_2;
                float _S1231 = spread_1 + 3.14159274101257324f;
                if(_S919)
                {
                    _S1035 = true;
                }
                else
                {
                    bool _S1232 = b_7 == _S741;
                    if(_S1232)
                    {
                        _S1035 = !_S1029;
                    }
                    else
                    {
                        _S1035 = false;
                    }
                }
                TreeSample light_4;
                if(_S1035)
                {
                    float3  _S1233 = (&ray_2)->origin;
                    float3  _S1234 = (&ray_2)->unit_direction;
                    float3  _S1235 = (&ray_2)->unit_direction;
                    uint _S1236 = stream(_S753, b_7 + 64U);
                    float3  _S1237 = extinction_in_0;
                    float3  _S1238 = extinction_in_0;
                    uint2  _S1239 = make_uint2 (_S1201);
                    float3  _S1240 = (&ray_2)->unit_direction;
                    uint _S1241 = arrivalLobe_0(b_7, (&prev_0)->lobe);
                    FKHit _S1242 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                    FKHit _S1243 = _S1242;
                    ShadowContext _S1244 = ShadowContext_x24init_0(_S1237, _S1238, _S1239, _S1240, b_7, _S1241, false, spread_2, width_6, &_S1243, false);
                    ShadowContext _S1245 = _S1244;
                    TreeSample _S1246 = sampleLightTree_0(_S1233, _S1234, _S1235, 0.0f, true, _S1236, &_S1245);
                    light_4 = _S1246;
                }
                else
                {
                    light_4 = _S957;
                }
                float _S1247 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1248 = (fcptMaxBounces());
                bool _S1249 = b_7 < _S1248;
                if(_S1249)
                {
                    _S1036 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1036 = false;
                }
                float _S1250 = _slang_select(_S1036, _S1247,0.0f);
                float3  _S1251 = throughput_11 * light_4.radiance;
                float _S1252 = powerHeuristic(light_4.density, _S1250);
                float3  _S1253 = _S1251 * make_float3 (_S1247 * _S1252);
                float3  _S1254 = _slang_select(_S1035, _S1253,_S725);
                if(replay_0)
                {
                    _S1037 = b_7 == _S741;
                }
                else
                {
                    _S1037 = false;
                }
                if(_S1037)
                {
                    bool _S1255 = _S730 == 2U;
                    if(_S1255)
                    {
                        float _S1256 = rgb_to_greyscale(_S1254);
                        _S1038 = _S1256 > 0.0f;
                    }
                    else
                    {
                        _S1038 = false;
                    }
                    if(_S1038)
                    {
                        Shift _S1257 = Shift_x24init_0(_S1254, 1.0f);
                        _S724 = int(1);
                        ended_0 = _S1257;
                        spread_2 = _S1231;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_4 = b_7;
                        break;
                    }
                    _S724 = int(1);
                    ended_0 = _S726;
                    spread_2 = _S1231;
                    width_4 = width_6;
                    throughput_8 = throughput_11;
                    b_4 = b_7;
                    break;
                }
                if(_S919)
                {
                    Reservoir candidate_8 = _S1200;
                    uint _S1258 = extractBits_0(_S1200.path, 10U, 2U);
                    bool _S1259 = _S1258 == 1U;
                    if(_S1259)
                    {
                        float3  _S1260 = safeDivide(_S1254, chain_throughput_0);
                        (&candidate_8)->radiance = _S1260;
                    }
                    else
                    {
                        uint _S1261 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                        uint _S1262 = insertBits_0(_S1261, 2U, 10U, 2U);
                        (&candidate_8)->path = _S1262;
                    }
                    Reservoir _S1263 = withEnd(candidate_8, 0U, b_7, _S1254);
                    offer(sel_1, _S1263, _S1254 * make_float3 (scale_1) / make_float3 (density_3));
                    float _S1264 = survivalProbability(throughput_11, density_3);
                    uint _S1265 = stream(_S753, b_7 + 128U);
                    Random _S1266 = pcg(_S1265);
                    bool _S1267 = _S1264 < (_S1266.value);
                    if(_S1267)
                    {
                        _S1038 = true;
                    }
                    else
                    {
                        uint _S1268 = (fcptMaxBounces());
                        _S1038 = b_7 >= _S1268;
                    }
                    if(_S1038)
                    {
                        _S724 = int(1);
                        ended_0 = _S726;
                        spread_2 = _S1231;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_4 = b_7;
                        break;
                    }
                    float _S1269 = density_3 * _S1264;
                    density_3 = _S1269;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1270 = stream(_S753, b_7);
                float3  _S1271 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1270, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1271;
                NEEVertex _S1272 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S725, (&ray_2)->origin);
                nee_vertex_0 = _S1272;
                Vertex _S1273 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
                prev_0 = _S1273;
                float _S1274 = (&prev_0)->pdf;
                FKRay _S1275 = ray_2;
                FKHit _S1276 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1277 = (fcptTraverseInstanceBVH((_S1275), (true), (4.294967296e+09f), (false), (_S1276), (false)));
                hit_1 = _S1277;
                b_6 = b_7;
                throughput_10 = throughput_11;
                spread_1 = _S1231;
                width_3 = width_6;
                sky_pdf_1 = _S1274;
            }
            if(_S724 != int(2))
            {
                spread_1 = spread_2;
                width_3 = width_4;
                throughput_10 = throughput_8;
                b_6 = b_4;
                _S1033 = true;
                break;
            }
            ended_0 = _S726;
            _S1033 = false;
            break;
        }
        if(_S1033)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1034 = b_6 == b_3;
        }
        else
        {
            _S1034 = false;
        }
        bool _S1278 = ((&hit_1)->instance_index) == 4294967295U;
        if(_S1278)
        {
            bool _S1279 = !(&nee_vertex_0)->none;
            float _S1280 = _slang_select(_S1279, sky_pdf_1,0.0f);
            float _S1281 = escapeWeight_0(_S1280, (&ray_2)->unit_direction);
            float3  _S1282 = environment_0((&ray_2)->unit_direction, b_6, (&prev_0)->lobe);
            float3  _S1283 = throughput_10 * _S1282;
            if(replay_0)
            {
                bool _S1284 = b_6 == _S741;
                if(_S1284)
                {
                    passes_0 = _S730 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1283 * make_float3 (_S1281) / make_float3 (r_1->jac), density_3 / r_1->jac);
                }
                if(_S740)
                {
                    passes_0 = _S737;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_6 == _S728;
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
                    return Shift_x24init_0(_S1283 * make_float3 (_S1281), 1.0f);
                }
                return _S726;
            }
            Reservoir candidate_9 = chain_0;
            uint _S1285 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1286 = _S1285 == 1U;
            if(_S1286)
            {
                uint _S1287 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1288 = _S1287 == b_6;
                float _S1289 = _slang_select(_S1288, 1.0f,_S1281);
                float3  _S1290 = safeDivide(_S1283 * make_float3 (_S1289), chain_throughput_0);
                (&candidate_9)->radiance = _S1290;
            }
            else
            {
                bool _S1291 = (&prev_0)->rough;
                if(_S1291)
                {
                    uint _S1292 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                    uint _S1293 = insertBits_0(_S1292, 3U, 10U, 2U);
                    uint _S1294 = insertBits_0(_S1293, (&prev_0)->lobe, 15U, 3U);
                    bool _S1295 = (&prev_0)->inside;
                    uint _S1296 = _slang_select(_S1295, 1U,0U);
                    uint _S1297 = insertBits_0(_S1294, _S1296, 22U, 1U);
                    (&candidate_9)->path = _S1297;
                    (&candidate_9)->jac = (&prev_0)->pdf;
                    (&candidate_9)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1298 = _S1283 * make_float3 (_S1281);
            Reservoir _S1299 = withEnd(candidate_9, 3U, b_6, _S1298);
            offer(sel_1, _S1299, _S1298 * make_float3 (scale_1) / make_float3 (density_3));
            break;
        }
        float3  _S1300 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1300;
        bool _S1301 = (fcptVaryingUsed());
        if(_S1301)
        {
            _S1035 = filling_2 != 4294967295U;
        }
        else
        {
            _S1035 = false;
        }
        if(_S1035)
        {
            if(_S919)
            {
                float3  _S1302 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1303 = sel_1->glow + _S1302;
                sel_1->glow = _S1303;
            }
            float3  _S1304 = throughput_10 * weight_1;
            throughput_8 = _S1304;
        }
        else
        {
            float3  _S1305 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
            float3  _S1306 = throughput_10 * _S1305;
            throughput_8 = _S1306;
        }
        float _S1307 = width_3 + spread_1 * (&hit_1)->distance;
        viewed_0 = _S1034;
        width_2 = _S1307;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_0 = spread_1;
        uint _S1192 = b_6 + 1U;
        b_3 = _S1192;
        layer_0 = _S1191;
    }
    return _S726;
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
    Random _S1308 = pcg(state_3);
    Random _S1309 = pcg(_S1308.state);
    float _S1310 = 6.28318548202514648f * _S1308.value;
    float _S1311 = (F32_sqrt((-2.0f * clamp_0((F32_log((_S1309.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1309.state, _S1311 * (F32_cos((_S1310))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1312;
    (&_S1312)->state = state_4;
    (&_S1312)->value = value_2;
    return _S1312;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1313 = normal_distribution(state_5);
    Random _S1314 = normal_distribution(_S1313.state);
    Random _S1315 = normal_distribution(_S1314.state);
    float3  _S1316 = make_float3 (_S1313.value, _S1314.value, _S1315.value);
    float3  _S1317 = ((((_S1316)) * make_float3(rnorm3df(((_S1316)).x, ((_S1316)).y, ((_S1316)).z))));
    return RandomSphere_x24init_0(_S1315.state, _S1317);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_12)
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
    float3  _S1329 = t_1 - n_12 * make_float3 (dot_0(n_12, t_1));
    float3  _S1330 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_12);
    bool _S1331 = (dot_0(_S1329, _S1329)) > 0.0f;
    float3  _S1332 = _slang_select(_S1331, _S1329,_S1330);
    float3  _S1333 = ((((_S1332)) * make_float3(rnorm3df(((_S1332)).x, ((_S1332)).y, ((_S1332)).z))));
    bool _S1334 = (dot_0(cross_0(n_12, _S1333), _S1328)) > 0.0f;
    float3  t_2;
    if(_S1334)
    {
        float3  _S1335 = negate_0(_S1333);
        t_2 = _S1335;
    }
    else
    {
        t_2 = _S1333;
    }
    float3  _S1336 = cross_0(n_12, t_2);
    return makeMatrix<float, 3, 3> (t_2, _S1336, n_12);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_0)
{
    float3  _S1337 = t1_0 - t0_0;
    float3  _S1338 = t2_2 - t0_0;
    float3  _S1339 = t2_2 - t1_0;
    float _S1340 = (F32_min((length_0(_S1337)), ((F32_min((length_0(_S1338)), (length_0(_S1339)))))));
    float3  _S1341 = make_float3 (distance_3(position_0, t0_0), distance_3(position_0, t1_0), distance_3(position_0, t2_2));
    float3  _S1342 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1343 = dot_0(geometry_n_4, _S1342);
    float3  _S1344 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1345 = dot_0(geometry_n_4, _S1344);
    float3  _S1346 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1347 = acos_0(abs_0(make_float3 (_S1343, _S1345, dot_0(geometry_n_4, _S1346))));
    float3  _S1348 = clamp_1(tan_0(_S1347), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_0(dot_0(_S1341 * _S1348, uvw_0), 0.0f, _S1340 * 0.125f);
}

__device__ float3  straightThrough(BSDFMaterial material_21)
{
    return make_float3 (material_21.transmission * (1.0f - material_21.metallic)) * material_21.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_3, float3  out_dir_3, uint p_5, float w_2, float alpha_17, uint nt_0)
{
    uint _S1349 = p_5 % 4U;
    float _S1350 = w_2 * HAIR_WIDTHS_0[_S1349];
    float _S1351 = (F32_asin((clamp_0(dot_0(out_dir_3, t_3), -1.0f, 1.0f)))) - (F32_asin((clamp_0(dot_0(in_dir_11, t_3), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1349] * alpha_17;
    return ((F32_asinh((_S1351 / _S1350))) / (F32_asinh((3.14159274101257324f / _S1350))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_4, float3  out_dir_4, uint np_0)
{
    float3  _S1352 = worldToTangent(out_dir_4, t_4);
    float3  _S1353 = worldToTangent(in_dir_12, t_4);
    return (F32_frac((((F32_atan2((_S1352.z), (_S1352.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1353.z), (1.17549435082228751e-38f - _S1353.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_5, uint p_6, float row_0, float column_0, float w_3, float alpha_18, uint nt_1, uint np_1)
{
    float3  _S1354 = worldToTangent(in_dir_13, t_5);
    uint _S1355 = p_6 % 4U;
    float _S1356 = w_3 * HAIR_WIDTHS_0[_S1355];
    float _S1357 = (F32_asin((clamp_0(dot_0(in_dir_13, t_5), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1355] * alpha_18 + _S1356 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1356))))));
    float _S1358 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1354.z), (1.17549435082228751e-38f - _S1354.x)));
    float _S1359 = (F32_cos((_S1357)));
    float3  _S1360 = tangentToWorld(make_float3 (_S1359 * (F32_cos((_S1358))), (F32_sin((_S1357))), _S1359 * (F32_sin((_S1358)))), t_5);
    return _S1360;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_13, BSDFMaterial material_22, float coverage_1)
{
    float3  _S1361;
    if((material_22.ior) == 1.0f)
    {
        float3  _S1362 = straightThrough(material_22);
        _S1361 = _S1362;
    }
    else
    {
        _S1361 = make_float3 (0.0f);
    }
    return _S1361 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ void offerShifted(Selection * sel_2, Reservoir r_2, Shift shifted_0, float mis_0)
{
    Reservoir candidate_10 = r_2;
    float3  _S1363 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_10)->f = _S1363;
    float _S1364 = r_2.jac * shifted_0.jac;
    (&candidate_10)->jac = _S1364;
    offer(sel_2, candidate_10, make_float3 (mis_0) * shifted_0.f * make_float3 (r_2.w));
    return;
}

__device__ Reservoir finalize(Selection sel_3, float c_1)
{
    Reservoir r_3 = sel_3.r;
    float _S1365 = rgb_to_greyscale((&r_3)->f);
    float _S1366 = sel_3.w_sum / _S1365;
    bool _S1367 = _S1365 > 0.0f;
    float _S1368 = _slang_select(_S1367, _S1366,0.0f);
    (&r_3)->w = _S1368;
    (&r_3)->c = c_1;
    return r_3;
}

__device__ Shift walk_hook(Domain dom_1, Reservoir r_4, bool replay_1, float scale_2, Selection * sel_4)
{
    Domain _S1369 = dom_1;
    Reservoir _S1370 = r_4;
    Shift _S1371 = walk_0(&_S1369, &_S1370, replay_1, scale_2, sel_4);
    return _S1371;
}

#undef Matrix
