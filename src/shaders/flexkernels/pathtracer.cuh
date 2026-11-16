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
        FKLight _S105 = (fcptLight((_S103.y)));
        float _S106 = sphereDensity(_S105.position, _S105.variance, start_1);
        return probability_1 * _S106;
    }
    uint _S107 = _S103.y;
    uint _S108 = (fcptTriangleOffset((_S107)));
    Matrix<float, 3, 3>  _S109 = (fcptWorldTriangle((_S107), (_S108 + _S103.z)));
    float _S110 = solidAngle(probability_1, cross_0(_S109.rows[int(1)] - _S109.rows[int(0)], _S109.rows[int(2)] - _S109.rows[int(0)]), light_point_0 - start_1);
    return _S110;
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
    uint _S111 = x_2 * 747796405U + 2891336453U;
    uint _S112 = ((_S111 >> ((_S111 >> 28U) + 4U)) ^ _S111) * 277803737U;
    return (_S112 >> 22U) ^ _S112;
}

static __device__ Random Random_x24init_0(uint state_0, float value_0)
{
    Random _S113;
    (&_S113)->state = state_0;
    (&_S113)->value = value_0;
    return _S113;
}

__device__ Random pcg(uint state_1)
{
    uint _S114 = hash(state_1);
    float value_1 = float(_S114 >> int(8)) * 5.9604644775390625e-08f;
    return Random_x24init_0(_S114, value_1);
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
    uint2  _S115 = (fcptEnvironmentCdfSize());
    uint2  _S116 = _S115 - make_uint2 (1U, 0U);
    float2  _S117 = make_float2 ((F32_atan2((- dir_2.z), (- dir_2.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_0(dir_2.y, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S118 = make_float2 ((float)_S116.x, (float)_S116.y);
    float2  _S119 = _S117 * _S118;
    uint2  _S120 = make_uint2 ((uint)_S119.x, (uint)_S119.y);
    uint2  _S121 = min_0(_S120, _S116 - make_uint2 (1U));
    float4  _S122 = (fcptEnvironmentCdf((_S121)));
    float _S123 = _S122.y;
    uint _S124 = _S116.x;
    float4  _S125 = (fcptEnvironmentCdf((make_uint2 (_S124, _S121.y))));
    float _S126 = _S123 * _S125.y;
    return _S126 * float(_S124 * _S116.y) / (19.73921012878417969f * length_1(float2 {dir_2.x, dir_2.z}));
}

static __device__ float3  negate_0(float3  x_7)
{
    return - x_7;
}

static __device__ float sign_0(float e_0)
{
    bool _S127 = e_0 < 0.0f;
    float _S128 = _slang_select(_S127, -1.0f,0.0f);
    bool _S129 = e_0 > 0.0f;
    float _S130 = _slang_select(_S129, 1.0f,_S128);
    return _S130;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S131;
    (&_S131)->tangent = tangent_0;
    (&_S131)->alphas = alphas_0;
    return _S131;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_0 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S132 = (F32_abs((dot_0(n_1, a_0)))) > 0.9999847412109375f;
    float3  a_1;
    if(_S132)
    {
        float3  _S133 = make_float3 (1.0f, 0.0f, 0.0f);
        a_1 = _S133;
    }
    else
    {
        a_1 = a_0;
    }
    float3  _S134 = cross_0(n_1, a_1);
    float3  _S135 = ((((_S134)) * make_float3(rnorm3df(((_S134)).x, ((_S134)).y, ((_S134)).z))));
    float3  _S136 = cross_0(n_1, _S135);
    return make_float3 (v_0.x) * _S135 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S136;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_0, float3  n_i_0)
{
    float _S137 = material_0.roughness;
    float _S138 = _S137 * _S137;
    bool _S139 = (material_0.anisotropy) == 0.0f;
    bool _S140;
    if(_S139)
    {
        _S140 = true;
    }
    else
    {
        _S140 = !(_S138 > 0.0f);
    }
    if(_S140)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S141 = material_0.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_0.tangent));
    float3  _S142 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S143 = (dot_0(_S141, _S141)) > 0.0f;
    float3  _S144 = _slang_select(_S143, _S141,_S142);
    float3  _S145 = ((((_S144)) * make_float3(rnorm3df(((_S144)).x, ((_S144)).y, ((_S144)).z))));
    float _S146 = 6.28318548202514648f * material_0.anisotropic_rotation;
    float _S147 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_0.anisotropy))))));
    float _S148 = 1.0f / _S147;
    bool _S149 = (material_0.anisotropy) < 0.0f;
    float _S150 = _slang_select(_S149, _S148,_S147);
    return AnisotropicFrame_x24init_0(_S145 * make_float3 ((F32_cos((_S146)))) + cross_0(n_i_0, _S145) * make_float3 ((F32_sin((_S146)))), make_float2 (_S138 / _S150, _S138 * _S150));
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S151;
    (&_S151)->on = on_0;
    (&_S151)->albedo = albedo_0;
    return _S151;
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
    SheenProfile _S152 = SheenProfile_x24init_0(false, 0.0f);
    float _S153 = rgb_to_greyscale(material_1.sheen);
    bool _S154 = _S153 > 0.0f;
    SheenProfile profile_0;
    if(_S154)
    {
        float _S155 = clamp_0((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S156 = (U32_min((uint(_S155)), (22U)));
        float _S157 = (F32_sqrt((0.05000000074505806f)));
        float _S158 = (clamp_0((F32_sqrt(((F32_max((material_1.sheen_roughness), (0.0f)))))), _S157, 1.0f) - _S157) / (1.0f - _S157) * 23.0f;
        uint _S159 = (U32_min((uint(_S158)), (22U)));
        uint _S160 = _S156 * 24U + _S159;
        float _S161 = _S155 - float(_S156);
        float _S162 = _S158 - float(_S159);
        uint _S163 = _S160 + 24U;
        float _S164 = SHEEN_ALBEDO_0[_S160] + (SHEEN_ALBEDO_0[_S163] - SHEEN_ALBEDO_0[_S160]) * _S161;
        uint _S165 = _S160 + 1U;
        float _S166 = SHEEN_ALBEDO_0[_S165] + (SHEEN_ALBEDO_0[_S163 + 1U] - SHEEN_ALBEDO_0[_S165]) * _S161;
        SheenProfile _S167 = SheenProfile_x24init_0(true, (F32_exp((_S164 + (_S166 - _S164) * _S162))));
        profile_0 = _S167;
    }
    else
    {
        profile_0 = _S152;
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
    BSDFLobes _S168;
    (&_S168)->v_dot_h = v_dot_h_0;
    (&_S168)->n_dot_h = n_dot_h_0;
    (&_S168)->refracted = refracted_1;
    (&_S168)->F = F_0;
    (&_S168)->F_greyscale = F_greyscale_0;
    (&_S168)->reflect_weight = reflect_weight_0;
    (&_S168)->diffuse_weight = diffuse_weight_0;
    (&_S168)->refract_weight = refract_weight_0;
    (&_S168)->p_diffuse = p_diffuse_0;
    (&_S168)->p_reflect = p_reflect_0;
    (&_S168)->p_refract = p_refract_0;
    (&_S168)->translucent_share = translucent_share_0;
    (&_S168)->sheen = sheen_0;
    (&_S168)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S168)->view = view_0;
    (&_S168)->tangent = tangent_1;
    (&_S168)->alphas = alphas_1;
    (&_S168)->visible = visible_0;
    return _S168;
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
    float3  _S169 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S170 = ((((_S169)) * make_float3(rnorm3df(((_S169)).x, ((_S169)).y, ((_S169)).z))));
    float _S171 = _S170.x;
    float _S172 = _S170.y;
    float _S173 = _S171 * _S171 + _S172 * _S172;
    float3  _S174 = make_float3 (1.0f, 0.0f, 0.0f);
    float3  _S175 = make_float3 (- _S172, _S171, 0.0f);
    float _S176 = (rsqrtf((_S173)));
    float3  _S177 = _S175 * make_float3 (_S176);
    bool _S178 = _S173 > 0.0f;
    float3  _S179 = _slang_select(_S178, _S177,_S174);
    float3  _S180 = cross_0(_S170, _S179);
    float _S181 = (F32_sqrt((U1_0)));
    float _S182 = 6.28318548202514648f * U2_0;
    float _S183 = _S181 * (F32_cos((_S182)));
    float t2_0 = _S181 * (F32_sin((_S182)));
    float _S184 = 0.5f * (1.0f + _S170.z);
    float t2_1 = (1.0f - _S184) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S183 * _S183)))))) + _S184 * t2_0;
    float3  _S185 = make_float3 (_S183) * _S179 + make_float3 (t2_1) * _S180;
    float _S186 = unshared_0(_S183);
    float _S187 = unshared_0(_S183);
    float3  _S188 = _S185 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S186 * _S187 - t2_1 * t2_1))))))) * _S170;
    float3  _S189 = make_float3 (alpha_0 * _S188.x, alpha_0 * _S188.y, (F32_max((0.0f), (_S188.z))));
    float3  _S190 = ((((_S189)) * make_float3(rnorm3df(((_S189)).x, ((_S189)).y, ((_S189)).z))));
    return _S190;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_3)
{
    float3  a_2 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S191 = (F32_abs((dot_0(n_3, a_2)))) > 0.9999847412109375f;
    float3  a_3;
    if(_S191)
    {
        float3  _S192 = make_float3 (1.0f, 0.0f, 0.0f);
        a_3 = _S192;
    }
    else
    {
        a_3 = a_2;
    }
    float3  _S193 = cross_0(n_3, a_3);
    float3  _S194 = ((((_S193)) * make_float3(rnorm3df(((_S193)).x, ((_S193)).y, ((_S193)).z))));
    float3  _S195 = cross_0(n_3, _S194);
    return make_float3 (dot_0(v_2, _S194), dot_0(v_2, n_3), dot_0(v_2, _S195));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_0, uint * random_state_1)
{
    Random _S196 = pcg(*random_state_1);
    Random _S197 = pcg(_S196.state);
    *random_state_1 = _S197.state;
    float _S198 = frame_0.alphas.x;
    bool _S199 = _S198 > 0.0f;
    if(_S199)
    {
        float3  _S200 = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        float _S201 = frame_0.alphas.y;
        float3  _S202 = make_float3 (_S198 * _S200.x, _S201 * _S200.y, _S200.z);
        float3  _S203 = ((((_S202)) * make_float3(rnorm3df(((_S202)).x, ((_S202)).y, ((_S202)).z))));
        float3  _S204 = sampleGGXVNDF(_S203, 1.0f, _S196.value, _S197.value);
        float3  _S205 = make_float3 (_S198 * _S204.x, _S201 * _S204.y, _S204.z);
        float3  _S206 = ((((_S205)) * make_float3(rnorm3df(((_S205)).x, ((_S205)).y, ((_S205)).z))));
        return make_float3 (_S206.x) * frame_0.tangent + make_float3 (_S206.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S206.z) * n_i_2;
    }
    float3  _S207 = worldToTangent(v_3, n_i_2);
    float3  _S208 = sampleGGXVNDF(float3 {_S207.x, _S207.z, _S207.y}, alpha_1, _S196.value, _S197.value);
    float3  _S209 = float3 {_S208.x, _S208.z, _S208.y};
    float3  _S210 = tangentToWorld(_S209, n_i_2);
    return _S210;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_4, BSDFMaterial material_2, uint random_state_2, AnisotropicFrame frame_1)
{
    uint state_2 = random_state_2;
    float3  _S211 = negate_0(in_dir_0);
    float _S212 = sign_0(dot_0(n_4, _S211));
    float _S213 = material_2.roughness;
    float3  _S214 = sampleHalfVector(_S211, n_4 * make_float3 (_S212), _S213 * _S213, frame_1, &state_2);
    return _S214;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_5, float eta_i_0, float eta_o_0)
{
    float3  _S215 = negate_0(in_dir_1);
    float3  _S216 = negate_0(make_float3 (eta_i_0) * _S215 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S217 = ((((_S216)) * make_float3(rnorm3df(((_S216)).x, ((_S216)).y, ((_S216)).z))));
    float _S218 = sign_0(dot_0(n_5, _S215));
    float _S219 = sign_0(dot_0(_S216, n_5 * make_float3 (_S218)));
    return _S217 * make_float3 (_S219);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S220 = negate_0(in_dir_2);
    float3  _S221 = _S220 + out_dir_1;
    float3  _S222 = ((((_S221)) * make_float3(rnorm3df(((_S221)).x, ((_S221)).y, ((_S221)).z))));
    return _S222;
}

static __device__ float3  refract_0(float3  i_1, float3  n_6, float eta_0)
{
    float _S223 = dot_0(n_6, i_1);
    float _S224 = 1.0f - eta_0 * eta_0 * (1.0f - _S223 * _S223);
    if(_S224 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_1 - make_float3 (eta_0 * _S223 + (F32_sqrt((_S224)))) * n_6;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S225 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S226 = eta_i_1 / eta_o_1 * _S225;
    bool _S227 = _S226 < 1.0f;
    float kr_0;
    if(_S227)
    {
        float _S228 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S226 * _S226))))));
        bool _S229 = eta_i_1 == eta_o_1;
        float _S230 = _slang_select(_S229, cos_theta_0,_S228);
        float _S231 = eta_o_1 * cos_theta_0;
        float _S232 = eta_i_1 * _S230;
        float _S233 = (_S231 - _S232) / (_S231 + _S232);
        float _S234 = eta_i_1 * cos_theta_0;
        float _S235 = eta_o_1 * _S230;
        float _S236 = (_S234 - _S235) / (_S234 + _S235);
        float _S237 = (_S233 * _S233 + _S236 * _S236) / 2.0f;
        kr_0 = _S237;
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
    float _S238 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S238 / (_S238 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S238)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S239 = alphas_3.x;
    float _S240 = h_0.x / _S239;
    float _S241 = alphas_3.y;
    float _S242 = h_0.y / _S241;
    float _S243 = h_0.z;
    float _S244 = _S240 * _S240 + _S242 * _S242 + _S243 * _S243;
    return 1.0f / (F32_max((3.14159274101257324f * _S239 * _S241 * _S244 * _S244), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_4, float3  n_i_3, float3  ggx_n_0, BSDFMaterial material_3, float eta_i_2, float eta_o_2, AnisotropicFrame frame_2, SheenProfile sheen_profile_0)
{
    float _S245 = dot_0(ggx_n_0, v_4);
    float _S246 = dot_0(n_i_3, ggx_n_0);
    float _S247 = eta_i_2 / eta_o_2;
    float3  _S248 = refract_0(in_dir_3, ggx_n_0, _S247);
    float3  _S249 = ((((_S248)) * make_float3(rnorm3df(((_S248)).x, ((_S248)).y, ((_S248)).z))));
    float _S250 = (F32_min(((F32_sqrt((material_3.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S251 = _S250 * _S250;
    float _S252 = (1.0f + _S250) / (1.0f - _S250);
    float _S253 = (F32_abs((_S245)));
    bool _S254 = eta_i_2 > eta_o_2;
    float _S255 = _slang_select(_S254, _S252,1.0f);
    float _S256 = _slang_select(_S254, 1.0f,_S252);
    float _S257 = fresnel(_S253, _S255, _S256);
    bool _S258 = (eta_i_2 * eta_i_2 * (1.0f - _S245 * _S245)) >= (eta_o_2 * eta_o_2);
    float3  _S259 = material_3.specular_tint * make_float3 (_S251);
    float3  _S260 = _S259 + (make_float3 (1.0f) - _S259) * make_float3 (_S257 - _S251) / make_float3 (1.0f - _S251);
    float3  _S261 = make_float3 (1.0f);
    float3  _S262 = _slang_select(_S258, _S261,_S260);
    float3  _S263 = make_float3 (0.0f);
    float3  scale_0;
    float3  sheen_1;
    float3  view_1;
    float sheen_component_0;
    if(sheen_profile_0.on)
    {
        float _S264 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S265 = make_float3 (1.0f) - material_3.sheen * make_float3 (_S264);
        float _S266 = rgb_to_greyscale(material_3.sheen);
        float _S267 = _S266 * _S264;
        float3  _S268 = material_3.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        scale_0 = _S265;
        sheen_component_0 = _S267;
        sheen_1 = _S268;
        view_1 = v_4;
    }
    else
    {
        scale_0 = _S261;
        sheen_component_0 = 0.0f;
        sheen_1 = _S263;
        view_1 = _S263;
    }
    float3  _S269 = mix_0(_S262, material_3.albedo, material_3.metallic);
    float3  F_1 = _S269 * scale_0;
    float _S270 = rgb_to_greyscale(F_1);
    float _S271 = 1.0f - material_3.metallic;
    float3  _S272 = make_float3 (1.0f) - _S262;
    float3  _S273 = make_float3 ((1.0f - material_3.transmission) * _S271) * _S272 * scale_0;
    float3  _S274 = make_float3 (material_3.transmission * _S271) * _S272 * scale_0;
    float _S275 = (F32_max((_S270), (0.0f)));
    float _S276 = rgb_to_greyscale(_S273);
    float _S277 = (F32_max((_S276), (0.0f)));
    float _S278 = rgb_to_greyscale(_S274);
    float _S279 = sign_0(length_0(_S249));
    float _S280 = (F32_max((_S278 * _S279), (0.0f)));
    float _S281 = _S275 + _S277 + _S280;
    float _S282 = (F32_min((sheen_component_0), (1.0f)));
    bool _S283 = sheen_component_0 > 0.0f;
    bool _S284;
    if(_S283)
    {
        _S284 = !(_S281 > 0.0f);
    }
    else
    {
        _S284 = false;
    }
    float _S285 = _slang_select(_S284, 1.0f,_S282);
    float _S286 = (1.0f - _S285) / (F32_max((_S281), (0.0000152587890625f)));
    float _S287 = _S277 * _S286;
    float _S288 = _S275 * _S286;
    float _S289 = _S280 * _S286;
    bool _S290 = (frame_2.alphas.x) > 0.0f;
    float visible_1;
    if(_S290)
    {
        float3  _S291 = anisotropicLocal(v_4, frame_2.tangent, n_i_3);
        float _S292 = anisotropicG1(_S291, frame_2.alphas);
        float3  _S293 = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        float _S294 = anisotropicD(_S293, frame_2.alphas);
        float _S295 = _S292 * _S294;
        visible_1 = _S295;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S245, _S246, _S249, F_1, _S270, 1.0f, _S273, _S274, _S287, _S288, _S289, 0.0f, sheen_1, _S285, view_1, frame_2.tangent, frame_2.alphas, visible_1);
}

__device__ float translucentShare(BSDFMaterial material_4)
{
    float _S296 = rgb_to_greyscale(material_4.translucent);
    float _S297 = rgb_to_greyscale(material_4.albedo);
    float _S298 = _S296 / (_S297 + _S296);
    bool _S299 = _S296 > 0.0f;
    float _S300 = _slang_select(_S299, _S298,0.0f);
    return _S300;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_2, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S301 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S302 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S303 = 1.0f - lobes_0.translucent_share;
    bool _S304 = n_i_dot_l_0 < 0.0f;
    float _S305 = _slang_select(_S304, lobes_0.translucent_share,_S303);
    float _S306 = _S302 * _S305;
    bool _S307 = (lobes_0.translucent_share) > 0.0f;
    float _S308 = _slang_select(_S307, _S306,_S301);
    bool _S309 = n_i_dot_v_0 > 0.0f;
    float _S310 = _slang_select(_S309, _S308,0.0f);
    return _S310;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_4, float alpha_3, BSDFMaterial material_5, BSDFLobes lobes_1)
{
    bool _S311 = (dot_0(n_i_4, l_0)) < 0.0f;
    float3  _S312 = _slang_select(_S311, material_5.translucent,material_5.albedo);
    float _S313 = 1.0f - lobes_1.translucent_share;
    float _S314 = _slang_select(_S311, lobes_1.translucent_share,_S313);
    float3  _S315 = _S312 / make_float3 (_S314);
    bool _S316 = (lobes_1.translucent_share) > 0.0f;
    float3  _S317 = _slang_select(_S316, _S315,material_5.albedo);
    return lobes_1.diffuse_weight * _S317 / make_float3 (lobes_1.p_diffuse);
}

__device__ float smithG1(float alpha_4, float n_dot_x_0)
{
    float _S318 = alpha_4 * alpha_4;
    float _S319 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S318 + (1.0f - _S318) * n_dot_x_0 * n_dot_x_0))));
    bool _S320 = alpha_4 > 0.0f;
    float _S321 = _slang_select(_S320, _S319,1.0f);
    return _S321;
}

__device__ float trowbridgeReitz(float alpha_5, float n_dot_h_1)
{
    float _S322 = alpha_5 * alpha_5;
    float _S323 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S322 * n_dot_h_1 * n_dot_h_1;
    return _S322 / (F32_max((3.14159274101257324f * _S323 * _S323), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S324 = smithG1(alpha_6, n_i_dot_v_1);
    float _S325 = _S324 * lobes_2.v_dot_h;
    float _S326 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S327 = _S325 * _S326 / n_i_dot_v_1;
    bool _S328 = alpha_6 > 0.0f;
    bool _S329;
    if(_S328)
    {
        _S329 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S329 = false;
    }
    if(_S329)
    {
        _S329 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S329 = false;
    }
    if(_S329)
    {
        _S329 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S329 = false;
    }
    float _S330 = _slang_select(_S329, _S327,0.0f);
    bool _S331 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S331)
    {
        float _S332 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S333 = (lobes_2.v_dot_h) > 0.0f;
        if(_S333)
        {
            _S329 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S329 = false;
        }
        if(_S329)
        {
            _S329 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S329 = false;
        }
        float _S334 = _slang_select(_S329, _S332,0.0f);
        pdf_h_0 = _S334;
    }
    else
    {
        pdf_h_0 = _S330;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S335 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S336 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S337 = lobes_3.p_refract * _S335 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S336 * _S336);
    bool _S338 = eta_i_4 != eta_o_4;
    bool _S339;
    if(_S338)
    {
        _S339 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S339 = false;
    }
    float _S340 = _slang_select(_S339, _S337,0.0f);
    return _S340;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_5, float alpha_8, BSDFMaterial material_6, BSDFLobes lobes_4)
{
    float _S341 = - dot_0(n_i_5, l_1);
    float _S342 = smithG1(alpha_8, (F32_max((_S341), (0.0f))));
    bool _S343 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S343)
    {
        float3  _S344 = negate_0(n_i_5);
        float3  _S345 = anisotropicLocal(l_1, lobes_4.tangent, _S344);
        float _S346 = anisotropicG1(_S345, lobes_4.alphas);
        G1_l_0 = _S346;
    }
    else
    {
        G1_l_0 = _S342;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_6.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S347 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S348 = n_i_dot_l_2 > 0.0f;
    bool _S349;
    if(_S348)
    {
        _S349 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S349 = false;
    }
    float _S350 = _slang_select(_S349, _S347,0.0f);
    return _S350;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_6, float alpha_10, BSDFMaterial material_7, BSDFLobes lobes_6)
{
    float3  _S351 = l_2 + lobes_6.view;
    float3  _S352 = ((((_S351)) * make_float3(rnorm3df(((_S351)).x, ((_S351)).y, ((_S351)).z))));
    float _S353 = dot_0(n_i_6, _S352);
    float _S354 = (F32_max((dot_0(n_i_6, l_2)), (0.0f)));
    float _S355 = (F32_max((dot_0(n_i_6, lobes_6.view)), (0.0f)));
    float _S356 = 1.0f / (F32_max((material_7.sheen_roughness), (0.05000000074505806f)));
    float _S357 = (2.0f + _S356) * (F32_pow(((F32_max((1.0f - _S353 * _S353), (0.0f)))), (0.5f * _S356))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S354 + _S355 - _S354 * _S355)), (0.0000152587890625f)));
    return lobes_6.sheen * make_float3 (_S357 * _S354 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, BSDFLobes lobes_7, float eta_i_6, float eta_o_6)
{
    float _S358 = vndfPDF(n_i_dot_v_4, alpha_11, lobes_7);
    float _S359 = lobes_7.p_reflect * _S358 / (4.0f * lobes_7.v_dot_h);
    bool _S360 = _S358 > 0.0f;
    float _S361 = _slang_select(_S360, _S359,0.0f);
    return _S361;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_3, float3  n_i_7, float alpha_12, BSDFMaterial material_8, BSDFLobes lobes_8)
{
    float _S362 = dot_0(n_i_7, l_3);
    float _S363 = smithG1(alpha_12, (F32_max((_S362), (0.0f))));
    bool _S364 = (lobes_8.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S364)
    {
        float3  _S365 = anisotropicLocal(l_3, lobes_8.tangent, n_i_7);
        float _S366 = anisotropicG1(_S365, lobes_8.alphas);
        G1_l_1 = _S366;
    }
    else
    {
        G1_l_1 = _S363;
    }
    return make_float3 (lobes_8.reflect_weight * G1_l_1) * lobes_8.F / make_float3 (lobes_8.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_9, float eta_i_7, float eta_o_7, bool refracted_2, uint random_state_3, FixedArray<float3 , 4>  * throughputs_0, FixedArray<float, 4>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S367 = negate_0(in_dir_4);
    float _S368 = dot_0(n_7, _S367);
    float _S369 = sign_0(_S368);
    float3  _S370 = n_7 * make_float3 (_S369);
    AnisotropicFrame _S371 = anisotropicFrame(material_9, _S370);
    float _S372 = dot_0(_S370, out_dir_2);
    float _S373 = material_9.roughness;
    float _S374 = _S373 * _S373;
    SheenProfile _S375 = sheenProfile(_S367, _S370, material_9);
    float _S376 = rgb_to_greyscale(material_9.translucent);
    bool _S377 = _S376 > 0.0f;
    bool _S378 = (dot_0(n_7, out_dir_2) * _S368) < 0.0f;
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
        float3  _S379 = make_float3 (0.0f);
        (*throughputs_0)[i_2] = _S379;
        (*pdfs_0)[i_2] = 0.0f;
        uint i_3 = i_2 + 1U;
        i_2 = i_3;
    }
    float3  _S380 = make_float3 (0.0f);
    BSDFLobes _S381 = BSDFLobes_x24init_0(0.0f, 0.0f, _S380, _S380, 0.0f, 0.0f, _S380, _S380, 0.0f, 0.0f, 0.0f, 0.0f, _S380, 0.0f, _S380, _S380, make_float2 (0.0f), 0.0f);
    BSDFLobes lobe_terms_0 = _S381;
    uint half_of_0 = 4294967295U;
    float3  ggx_n_2 = _S380;
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
        uint _S382;
        if(i_2 == 3U)
        {
            _S382 = 4U;
        }
        else
        {
            _S382 = i_2;
        }
        bool _S383 = _S382 == 0U;
        bool _S384;
        if(_S383)
        {
            _S384 = _S377;
        }
        else
        {
            _S384 = false;
        }
        bool _S385;
        if(_S384)
        {
            _S385 = _S378;
        }
        else
        {
            _S385 = _S382 == 1U;
        }
        bool _S386 = _S385 != refracted_2;
        if(_S386)
        {
            ggx_n_1 = ggx_n_2;
            uint i_4 = i_2 + 1U;
            ggx_n_2 = ggx_n_1;
            i_2 = i_4;
            continue;
        }
        uint _S387;
        if(_S382 == 4U)
        {
            _S387 = 2U;
        }
        else
        {
            _S387 = _S382;
        }
        bool _S388 = _S387 != half_of_0;
        uint half_of_1;
        if(_S388)
        {
            bool _S389 = _S387 == 0U;
            if(_S389)
            {
                float3  _S390 = sampledHalf(in_dir_4, n_7, material_9, random_state_3, _S371);
                ggx_n_1 = _S390;
            }
            else
            {
                bool _S391 = _S387 == 1U;
                if(_S391)
                {
                    float3  _S392 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_7, eta_o_7);
                    ggx_n_1 = _S392;
                }
                else
                {
                    float3  _S393 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S393;
                }
            }
            float3  _S394 = negate_0(in_dir_4);
            BSDFLobes _S395 = bsdfLobes(in_dir_4, _S394, _S370, ggx_n_1, material_9, eta_i_7, eta_o_7, _S371, _S375);
            lobe_terms_0 = _S395;
            float _S396 = translucentShare(material_9);
            (&lobe_terms_0)->translucent_share = _S396;
            half_of_1 = _S387;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S382)
        {
        case 0U:
            {
                float _S397 = diffusePDF(_S372, 0.0f, (F32_abs((_S368))), _S374, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(0)] = _S397;
                float3  _S398 = diffuseBSDF(out_dir_2, _S370, _S374, material_9, lobe_terms_0);
                (*throughputs_0)[int(0)] = _S398;
                break;
            }
        case 1U:
            {
                float _S399 = refractPDF(_S372, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S368))), _S374, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(1)] = _S399;
                float3  _S400 = refractBSDF(out_dir_2, _S370, _S374, material_9, lobe_terms_0);
                (*throughputs_0)[int(1)] = _S400;
                break;
            }
        case 4U:
            {
                float _S401 = sheenVelvetPDF(_S372, 0.0f, (F32_abs((_S368))), _S374, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(3)] = _S401;
                float3  _S402 = sheenVelvetBSDF(out_dir_2, _S370, _S374, material_9, lobe_terms_0);
                (*throughputs_0)[int(3)] = _S402;
                break;
            }
        default:
            {
                float _S403 = reflectPDF(_S372, 0.0f, (F32_abs((_S368))), _S374, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(2)] = _S403;
                float3  _S404 = reflectBSDF(out_dir_2, _S370, _S374, material_9, lobe_terms_0);
                (*throughputs_0)[int(2)] = _S404;
                break;
            }
        }
        half_of_0 = half_of_1;
        uint i_4 = i_2 + 1U;
        ggx_n_2 = ggx_n_1;
        i_2 = i_4;
    }
    i_2 = 0U;
    ggx_n_1 = _S380;
    for(;;)
    {
        if(i_2 < 4U)
        {
        }
        else
        {
            break;
        }
        bool _S405 = ((*pdfs_0)[i_2]) > 0.0f;
        if(_S405)
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
    bool _S406 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    float3  _S407 = BSDF(in_dir_5, dir_3, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S406, random_state_4, terms_0, pdfs_1);
    float3  _S408 = make_float3 (0.0f);
    uint i_6 = 0U;
    float3  f_1 = _S408;
    for(;;)
    {
        if(i_6 < 4U)
        {
        }
        else
        {
            break;
        }
        bool _S409 = ((*pdfs_1)[i_6]) > 0.0f;
        if(_S409)
        {
            float3  _S410 = (*terms_0)[i_6] * make_float3 ((*pdfs_1)[i_6]) / make_float3 ((*pdfs_1)[i_6] + pdf_0);
            (*terms_0)[i_6] = _S410;
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
    FKSurface _S411 = surface_2;
    FixedArray<float3 , 4>  terms_1;
    FixedArray<float, 4>  pdfs_2;
    float3  _S412 = skyLobes_0(in_dir_6, dir_4, &_S411, eta_2, is_inside_3, pdf_1, random_state_5, &terms_1, &pdfs_2);
    return _S412;
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
    SkySample _S413;
    (&_S413)->dir = dir_5;
    (&_S413)->radiance = radiance_0;
    (&_S413)->color = color_0;
    (&_S413)->random_state = random_state_6;
    return _S413;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0)
{
    uint2  _S414 = (fcptEnvironmentCdfSize());
    uint2  _S415 = make_uint2 (1U, 0U);
    uint2  _S416 = _S414 - _S415;
    Random _S417 = pcg(init_random_state_0);
    Random _S418 = pcg(_S417.state);
    Random _S419 = pcg(_S418.state);
    Random _S420 = pcg(_S419.state);
    uint _S421 = _S416.x;
    uint _S422 = searchCDF_0(make_uint2 (_S421, 0U), make_uint2 (0U, 1U), _S416.y, _S417.value);
    uint _S423 = searchCDF_0(make_uint2 (0U, _S422), _S415, _S421, _S418.value);
    float2  _S424 = make_float2 ((float)_S416.x, (float)_S416.y);
    float2  _S425 = (make_float2 (float(_S423), float(_S422)) + make_float2 (_S419.value, _S420.value)) / _S424 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S426 = _S425.y;
    float _S427 = (F32_sin((_S426)));
    float _S428 = _S425.x;
    float3  _S429 = make_float3 (_S427 * (F32_cos((_S428))), (F32_cos((_S426))), _S427 * (F32_sin((_S428))));
    float _S430 = environmentPdf_0(_S429);
    float3  _S431 = skyBSDF(ray_0->unit_direction, _S429, *surface_3, eta_3, is_inside_4, _S430, lobe_state_0);
    bool _S432 = !(_S430 > 0.0f);
    bool _S433;
    if(_S432)
    {
        _S433 = true;
    }
    else
    {
        _S433 = all_0(_S431 == make_float3 (0.0f));
    }
    if(_S433)
    {
        float3  _S434 = make_float3 (0.0f);
        return SkySample_x24init_0(_S429, _S434, _S434, _S420.state);
    }
    float3  _S435 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S429);
    return SkySample_x24init_0(_S429, _S435, _S431 * _S435, _S420.state);
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
    SampleBSDF _S436 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S437 = _S436.throughput * make_float3 (_S436.pdf);
    float _S438 = light_1->density;
    float _S439 = 1.0f + _S436.pdf * _S436.pdf / (light_1->density * light_1->density);
    bool _S440;
    if(competing_0)
    {
        _S440 = _S438 > 0.0f;
    }
    else
    {
        _S440 = false;
    }
    float _S441 = _slang_select(_S440, _S439,1.0f);
    return _S437 / make_float3 (_S441) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_7)
{
    TreeSample _S442;
    (&_S442)->dir = dir_6;
    (&_S442)->radiance = radiance_1;
    (&_S442)->density = density_0;
    (&_S442)->random_state = random_state_7;
    return _S442;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_3, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S443 = importance(first_1, p_3, normal_3);
    float _S444 = importance(second_1, p_3, normal_3);
    float2  _S445 = make_float2 (_S443, _S444);
    bool _S446 = _S443 == 0.0f;
    bool _S447;
    if(_S446)
    {
        _S447 = _S444 == 0.0f;
    }
    else
    {
        _S447 = false;
    }
    if(_S447)
    {
        return 2U;
    }
    float _S448 = _S443 + _S444;
    bool _S449 = _S444 > 0.0f;
    if(_S449)
    {
        _S447 = (*pick_0 * _S448) >= _S443;
    }
    else
    {
        _S447 = false;
    }
    uint _S450 = uint(_S447);
    float _S451 = (F32_min(((*pick_0 * _S448 - float(_S450) * _S443) / _slang_vector_get_element(_S445, _S450)), (0.99999994039535522f)));
    *pick_0 = _S451;
    float _S452 = *probability_3 * (_slang_vector_get_element(_S445, _S450) / _S448);
    *probability_3 = _S452;
    return _S450;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_4, float u1_0, float u2_0)
{
    float3  _S453 = center_1 - p_4;
    float _S454 = radius_1 * radius_1 / dot_0(_S453, _S453);
    float _S455 = u1_0 * _S454 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S454), (0.0f)))))));
    float _S456 = 2.0f * u1_0;
    bool _S457 = _S454 >= 1.0f;
    float _S458 = _slang_select(_S457, _S456,_S455);
    float _S459 = (F32_sqrt(((F32_max((_S458 * (2.0f - _S458)), (0.0f))))));
    float _S460 = 6.28318548202514648f * u2_0;
    float3  _S461 = make_float3 (_S459 * (F32_cos((_S460))), 1.0f - _S458, _S459 * (F32_sin((_S460))));
    float3  _S462 = ((((_S453)) * make_float3(rnorm3df(((_S453)).x, ((_S453)).y, ((_S453)).z))));
    float3  _S463 = tangentToWorld(_S461, _S462);
    return _S463;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S464 = center_2 - ray_1->origin;
    float _S465 = dot_0(_S464, ray_1->unit_direction);
    float _S466 = dot_0(_S464, _S464) - _S465 * _S465;
    float _S467 = radius_3 * radius_3;
    bool _S468 = _S466 > _S467;
    if(_S468)
    {
        return 4.294967296e+09f;
    }
    float _S469 = (F32_sqrt((_S467 - _S466)));
    float _S470 = _S465 - _S469;
    float _S471 = _S465 + _S469;
    bool _S472 = _S470 > 0.0000152587890625f;
    bool _S473;
    if(_S472)
    {
        _S473 = _S470 < max_len_0;
    }
    else
    {
        _S473 = false;
    }
    if(_S473)
    {
        return _S470;
    }
    bool _S474 = _S471 > 0.0000152587890625f;
    if(_S474)
    {
        _S473 = _S471 < max_len_0;
    }
    else
    {
        _S473 = false;
    }
    if(_S473)
    {
        return _S471;
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

static __device__ float3  emitted_0(float3  emissive_0, float3  dir_7, float3  n_8)
{
    float _S475 = sign_0(dot_0(- dir_7, n_8));
    float3  _S476 = emissive_0 * make_float3 ((F32_max((_S475), (0.0f))));
    bool _S477 = ((true));
    float3  _S478 = _slang_select(_S477, emissive_0,_S476);
    return _S478;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_1)
{
    Random _S479 = pcg(init_random_state_1);
    Random _S480 = pcg(_S479.state);
    Random _S481 = pcg(_S480.state);
    float3  _S482 = make_float3 (0.0f);
    TreeSample _S483 = TreeSample_x24init_0(_S482, _S482, 0.0f, _S481.state);
    TreeSample sample_0 = _S483;
    float3  _S484 = _slang_select(sided_0, _S482,smooth_n_2);
    float3  _S485 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S479.value;
    float probability_4 = 1.0f;
    uint n_9 = 0U;
    for(;;)
    {
        uint4  _S486 = (fcptLightNode((n_9)));
        if((_S486.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S487 = (fcptLightSecond((n_9)));
        uint _S488 = n_9 + 1U;
        LightNode _S489 = (fcptLightBounds((_S488)));
        LightNode _S490 = (fcptLightBounds((_S487)));
        uint _S491 = pickChild(_S489, _S490, origin_4, _S484, &pick_1, &probability_4);
        bool _S492 = _S491 > 1U;
        if(_S492)
        {
            return sample_0;
        }
        bool _S493 = _S491 == 1U;
        uint _S494 = _slang_select(_S493, _S487,_S488);
        n_9 = _S494;
    }
    bool _S495 = n_9 == 0U;
    bool _S496;
    if(_S495)
    {
        LightNode _S497 = (fcptLightBounds((0U)));
        float _S498 = importance(_S497, origin_4, _S484);
        _S496 = !(_S498 > 0.0f);
    }
    else
    {
        _S496 = false;
    }
    if(_S496)
    {
        return sample_0;
    }
    uint4  _S499 = (fcptLightNode((n_9)));
    FKHit _S500 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S501 = (_S499.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S501)
    {
        FKLight _S502 = (fcptLight((_S499.y)));
        if(sided_0)
        {
            float _S503 = sign_0(dot_0(geometry_n_1, _S502.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S503);
            float3  _S504 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S504;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S485;
            lift_n_0 = smooth_n_2;
        }
        bool _S505 = (_S502.variance) == 0.0f;
        if(_S505)
        {
            float3  _S506 = _S502.position - emitter_point_0;
            float3  _S507 = ((((_S506)) * make_float3(rnorm3df(((_S506)).x, ((_S506)).y, ((_S506)).z))));
            (&sample_0)->dir = _S507;
            float3  _S508 = _S502.color * make_float3 (_S502.intensity) / make_float3 (dot_0(_S506, _S506) * probability_4);
            (&sample_0)->radiance = _S508;
            shadow_1 = _S506;
        }
        else
        {
            float3  _S509 = sampleSphere(_S502.position, _S502.variance, emitter_point_0, _S480.value, _S481.value);
            (&sample_0)->dir = _S509;
            float _S510 = sphereDensity(_S502.position, _S502.variance, emitter_point_0);
            float _S511 = probability_4 * _S510;
            (&sample_0)->density = _S511;
            float3  _S512 = pointLightRadiance(_S502.color, _S502.intensity, _S502.variance);
            float3  _S513 = _S512 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S513;
            FKRay _S514 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S515 = raySphere_0(_S502.position, _S502.variance, &_S514, 4.294967296e+09f);
            float3  _S516 = (&sample_0)->dir * make_float3 (_S515);
            shadow_1 = _S516;
        }
        emitter_0 = _S500;
        emitter_point_0 = _S482;
    }
    else
    {
        uint _S517 = _S499.y;
        uint _S518 = (fcptTriangleOffset((_S517)));
        uint _S519 = _S518 + _S499.z;
        Matrix<float, 3, 3>  _S520 = (fcptWorldTriangle((_S517), (_S519)));
        float _S521 = (F32_sqrt((_S480.value)));
        float2  _S522 = make_float2 (_S521 * (1.0f - _S481.value), _S521 * _S481.value);
        float3  _S523 = mul_0(make_float3 (1.0f - _S521, _S522.x, _S522.y), _S520);
        if(sided_0)
        {
            float _S524 = sign_0(dot_0(geometry_n_1, _S523 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S524);
            float3  _S525 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S525;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S526 = !((dot_0(smooth_n_2, _S523 - origin_4)) > 0.0f);
            if(_S526)
            {
                return sample_0;
            }
            emitter_point_0 = _S485;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S522, _S517, _S519, 0U, 0.0f);
        float3  _S527 = _S523 - emitter_point_0;
        float3  _S528 = ((((_S527)) * make_float3(rnorm3df(((_S527)).x, ((_S527)).y, ((_S527)).z))));
        (&sample_0)->dir = _S528;
        float _S529 = solidAngle(probability_4, cross_0(_S520.rows[int(1)] - _S520.rows[int(0)], _S520.rows[int(2)] - _S520.rows[int(0)]), _S527);
        (&sample_0)->density = _S529;
        bool _S530 = (fcptShadowFirst());
        bool _S531 = !_S530;
        if(_S531)
        {
            FKSurface _S532 = (fcptLightSurfaceAt((emitter_1), (_S523), (_S481.state), ((&sample_0)->dir), (context_1->depth), (length_0(_S523 - origin_4))));
            (&sample_0)->random_state = _S532.random_state;
            float3  _S533 = emitted_0(_S532.material.emissive, (&sample_0)->dir, _S532.smooth_n);
            float3  _S534 = _slang_select(_S532.skip, _S482,_S533);
            float3  _S535 = _S534 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S535;
        }
        shadow_1 = _S527;
        emitter_0 = emitter_1;
        emitter_point_0 = _S523;
    }
    FKHit _S536 = emitter_0;
    float3  _S537 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_1, _S481.state, &_S536);
    bool _S538 = (fcptShadowFirst());
    if(_S538)
    {
        _S496 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S496 = false;
    }
    if(_S496)
    {
        _S496 = !all_0(_S537 == _S482);
    }
    else
    {
        _S496 = false;
    }
    if(_S496)
    {
        FKSurface _S539 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S481.state), ((&sample_0)->dir), (context_1->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S539.random_state;
        float3  _S540 = emitted_0(_S539.material.emissive, (&sample_0)->dir, _S539.smooth_n);
        float3  _S541 = _slang_select(_S539.skip, _S482,_S540);
        float3  _S542 = _S541 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S542;
    }
    float3  _S543 = (&sample_0)->radiance * _S537;
    bool _S544 = all_0(_S537 == _S482);
    float3  _S545 = _slang_select(_S544, _S482,_S543);
    (&sample_0)->radiance = _S545;
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
    float _S546 = 1.0f / (1.0f + b_0 / a_4 * (b_0 / a_4));
    bool _S547 = b_0 > 0.0f;
    float _S548 = _slang_select(_S547, _S546,1.0f);
    return _S548;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_0, float3  light_point_1)
{
    bool _S549 = vertex_0->none;
    if(_S549)
    {
        return 1.0f;
    }
    uint _S550 = (fcptLightSlot((*hit_0)));
    float _S551 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S550, light_point_1);
    float _S552 = powerHeuristic(vertex_0->pdf, _S551);
    return _S552;
}

static __device__ bool all_1(bool2  x_10)
{
    bool result_3 = true;
    int i_10 = int(0);
    for(;;)
    {
        if(i_10 < int(2))
        {
        }
        else
        {
            break;
        }
        if(result_3)
        {
            result_3 = (bool((_slang_vector_get_element(x_10, i_10))));
        }
        else
        {
            result_3 = false;
        }
        i_10 = i_10 + int(1);
    }
    return result_3;
}

static __device__ float3  environment_0(float3  dir_8, uint depth_0, uint lobe_0)
{
    uint2  _S553 = (fcptEnvironmentMapSize());
    bool _S554 = all_1(_S553 > make_uint2 (1U));
    if(_S554)
    {
        float3  _S555 = (fcptEnvMapSample((dir_8), (depth_0), (lobe_0)));
        return _S555;
    }
    float3  _S556 = (fcptAmbient());
    return _S556;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S557 = (fcptEnvironmentCdfSize());
    bool _S558 = !all_1(_S557 > make_uint2 (1U));
    if(_S558)
    {
        return false;
    }
    uint2  _S559 = (fcptEnvironmentMapSize());
    return all_1(_S559 > make_uint2 (1U));
}

static __device__ float escapeWeight_0(float pdf_2, float3  dir_9)
{
    bool _S560 = pdf_2 <= 0.0f;
    bool _S561;
    if(_S560)
    {
        _S561 = true;
    }
    else
    {
        bool _S562 = environmentMapped_0();
        _S561 = !_S562;
    }
    if(_S561)
    {
        return 1.0f;
    }
    float _S563 = environmentPdf_0(dir_9);
    return pdf_2 / (pdf_2 + _S563);
}

static __device__ float3  min_1(float3  x_11, float3  y_3)
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
        *_slang_vector_get_element_ptr(&result_4, i_11) = (F32_min((_slang_vector_get_element(x_11, i_11)), (_slang_vector_get_element(y_3, i_11))));
        i_11 = i_11 + int(1);
    }
    return result_4;
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
    Shift _S564;
    (&_S564)->f = f_3;
    (&_S564)->jac = jac_0;
    return _S564;
}

static __device__ uint extractBits_0(uint e_1, uint offset_0, uint count_1)
{
    return (e_1 >> offset_0) & ((1U << count_1) - 1U);
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_3, float3  origin_5, float3  smooth_n_3, float3  start_2)
{
    NEEVertex _S565;
    (&_S565)->none = none_0;
    (&_S565)->pdf = pdf_3;
    (&_S565)->origin = origin_5;
    (&_S565)->smooth_n = smooth_n_3;
    (&_S565)->start = start_2;
    return _S565;
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
    Vertex _S566;
    (&_S566)->rough = rough_0;
    (&_S566)->lobe = lobe_1;
    (&_S566)->pdf = pdf_4;
    (&_S566)->cos = cos_0;
    (&_S566)->inside = inside_0;
    return _S566;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S567 = hash(index_0);
    uint _S568 = hash(seed_0 ^ _S567);
    return _S568;
}

static __device__ float3  exp_0(float3  x_12)
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
        *_slang_vector_get_element_ptr(&result_5, i_12) = (F32_exp((_slang_vector_get_element(x_12, i_12))));
        i_12 = i_12 + int(1);
    }
    return result_5;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_0, float distance_1, bool scatters_0)
{
    float3  _S569 = exp_0((make_float3 (sigma_0) - extinction_0) * make_float3 (distance_1));
    float3  _S570 = scatter_0 * _S569 / make_float3 (sigma_0);
    float3  _S571 = _slang_select(scatters_0, _S570,_S569);
    return _S571;
}

static __device__ uint arrivalLobe_0(uint b_1, uint prev_lobe_0)
{
    bool _S572 = b_1 > 0U;
    uint _S573 = _slang_select(_S572, prev_lobe_0,3U);
    return _S573;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_5, float length_2, float width_0, FKHit * own_0, bool fiber_0)
{
    ShadowContext _S574;
    (&_S574)->extinction_behind = extinction_behind_0;
    (&_S574)->extinction_front = extinction_front_0;
    (&_S574)->fillings = fillings_0;
    (&_S574)->side = side_0;
    (&_S574)->depth = depth_1;
    (&_S574)->lobe = lobe_2;
    (&_S574)->surface = surface_5;
    (&_S574)->length = length_2;
    (&_S574)->width = width_0;
    (&_S574)->own = *own_0;
    (&_S574)->fiber = fiber_0;
    return _S574;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S575 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S575)
    {
        return 0.07957746833562851f;
    }
    float _S576 = g_0 * g_0;
    return (1.0f - _S576) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S576 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_5, float3  b_2)
{
    float3  _S577 = a_5 / b_2;
    float3  _S578 = make_float3 (0.0f);
    bool3  _S579 = b_2 == _S578;
    float3  _S580 = _slang_select(_S579, _S578,_S577);
    return _S580;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S581 = (1U << count_2) - 1U;
    return (e_2 & (~(_S581 << offset_1))) | ((newbits_0 & _S581) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_0, uint end_type_0, uint end_0, float3  f_4)
{
    Reservoir candidate_0 = r_0;
    uint _S582 = insertBits_0(r_0.path, end_0, 0U, 5U);
    uint _S583 = insertBits_0(_S582, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S583;
    (&candidate_0)->f = f_4;
    return candidate_0;
}

__device__ void offer(Selection * sel_0, Reservoir candidate_1, float3  weight_0)
{
    float _S584 = rgb_to_greyscale(weight_0);
    bool _S585 = _S584 > 0.0f;
    bool _S586;
    if(_S585)
    {
        _S586 = _S584 < 3.00000000549775576e+38f;
    }
    else
    {
        _S586 = false;
    }
    bool _S587 = !_S586;
    if(_S587)
    {
        return;
    }
    bool _S588 = sel_0->sums;
    if(_S588)
    {
        float3  _S589 = sel_0->color + weight_0;
        sel_0->color = _S589;
        return;
    }
    float _S590 = sel_0->w_sum + _S584;
    sel_0->w_sum = _S590;
    float3  _S591 = sel_0->color + weight_0;
    sel_0->color = _S591;
    Random _S592 = pcg(sel_0->random_state);
    sel_0->random_state = _S592.state;
    bool _S593 = (_S592.value * sel_0->w_sum) <= _S584;
    if(_S593)
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
    Random _S594 = pcg(random_state_8);
    Random _S595 = pcg(_S594.state);
    float _S596 = 1.0f - 2.0f * _S594.value;
    float _S597 = (F32_sqrt(((F32_max((1.0f - _S596 * _S596), (0.0f))))));
    float _S598 = 6.28318548202514648f * _S595.value;
    return make_float3 (_S597 * (F32_cos((_S598))), _S597 * (F32_sin((_S598))), _S596);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_10, uint random_state_9, float * pdf_5)
{
    bool _S599 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S599)
    {
        *pdf_5 = 0.07957746833562851f;
        float3  _S600 = isotropic_0(random_state_9);
        return _S600;
    }
    Random _S601 = pcg(random_state_9);
    Random _S602 = pcg(_S601.state);
    float _S603 = g_1 * g_1;
    float _S604 = 2.0f * g_1;
    float _S605 = (1.0f - _S603) / (1.0f - g_1 + _S604 * _S601.value);
    float _S606 = clamp_0((1.0f + _S603 - _S605 * _S605) / _S604, -1.0f, 1.0f);
    float _S607 = (F32_sqrt(((F32_max((1.0f - _S606 * _S606), (0.0f))))));
    float _S608 = 6.28318548202514648f * _S602.value;
    float _S609 = phaseHG_0(g_1, _S606);
    *pdf_5 = _S609;
    float3  _S610 = tangentToWorld(make_float3 (_S607 * (F32_cos((_S608))), _S606, _S607 * (F32_sin((_S608)))), dir_10);
    float3  _S611 = ((((_S610)) * make_float3(rnorm3df(((_S610)).x, ((_S610)).y, ((_S610)).z))));
    return _S611;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_1, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2)
{
    BSDFMaterial _S612;
    (&_S612)->albedo = albedo_1;
    (&_S612)->emissive = emissive_1;
    (&_S612)->roughness = roughness_0;
    (&_S612)->metallic = metallic_0;
    (&_S612)->transmission = transmission_0;
    (&_S612)->ior = ior_0;
    (&_S612)->absorption = absorption_0;
    (&_S612)->specular_tint = specular_tint_0;
    (&_S612)->specular_level = specular_level_0;
    (&_S612)->translucent = translucent_0;
    (&_S612)->sheen = sheen_2;
    (&_S612)->sheen_roughness = sheen_roughness_0;
    (&_S612)->anisotropy = anisotropy_0;
    (&_S612)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S612)->tangent = tangent_2;
    return _S612;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S613;
    (&_S613)->scatter = scatter_1;
    (&_S613)->extinction = extinction_1;
    (&_S613)->g = g_2;
    return _S613;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_10, bool skip_0, uint random_state_10, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S614;
    (&_S614)->smooth_n = smooth_n_4;
    (&_S614)->geometry_n = geometry_n_2;
    (&_S614)->geometry_offset = geometry_offset_2;
    (&_S614)->material = *material_10;
    (&_S614)->skip = skip_0;
    (&_S614)->random_state = random_state_10;
    (&_S614)->coverage = coverage_0;
    (&_S614)->encloses = encloses_0;
    (&_S614)->volume = *volume_0;
    (&_S614)->fills = fills_0;
    (&_S614)->hair = hair_0;
    return _S614;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S615 = (&surface_6->material)->emissive;
    float3  _S616 = make_float3 (0.0f);
    bool _S617 = !top_0;
    float3  _S618 = _slang_select(_S617, _S616,_S615);
    (&(&lower_0)->material)->emissive = _S618;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_1)
{
    float _S619 = surface_7->coverage;
    bool _S620 = u_1 < _S619;
    if(_S620)
    {
        return *surface_7;
    }
    float3  _S621 = make_float3 (0.0f);
    float3  _S622 = make_float3 (1.0f);
    BSDFMaterial _S623 = Material_x24init_0(_S621, _S621, 0.0f, 0.0f, 0.0f, 0.0f, _S621, _S622, 1.0f, _S621, _S621, 0.5f, 0.0f, 0.0f, _S621);
    BSDFMaterial material_11 = _S623;
    (&material_11)->albedo = _S622;
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
    bool _S624 = transmission_1 > 0.0f;
    bool _S625;
    if(_S624)
    {
        _S625 = true;
    }
    else
    {
        _S625 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S626 = _slang_select(_S625, 1.0f,-1.0f);
    return _S626;
}

static __device__ bool arrivesBehind_0(float3  dir_11, float3  n_10)
{
    return (dot_0(dir_11, n_10)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_12)
{
    float3  _S627 = surface_8->geometry_n;
    float _S628 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_12);
    FKSurface faced_0 = *surface_8;
    float3  _S629 = surface_8->smooth_n * make_float3 (_S628);
    (&faced_0)->smooth_n = _S629;
    float3  _S630 = _S627 * make_float3 (_S628);
    (&faced_0)->geometry_n = _S630;
    return faced_0;
}

static __device__ float3  max_0(float3  x_13, float3  y_4)
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
        *_slang_vector_get_element_ptr(&result_6, i_13) = (F32_max((_slang_vector_get_element(x_13, i_13)), (_slang_vector_get_element(y_4, i_13))));
        i_13 = i_13 + int(1);
    }
    return result_6;
}

static __device__ float3  log_0(float3  x_14)
{
    float3  result_7;
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
        *_slang_vector_get_element_ptr(&result_7, i_14) = (F32_log((_slang_vector_get_element(x_14, i_14))));
        i_14 = i_14 + int(1);
    }
    return result_7;
}

__device__ float3  beerLambert(float distance_2, float3  absorption_1)
{
    float3  _S631 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_2) * log_0(_S631));
}

__device__ float2  vertexEta(BSDFMaterial material_12, float n_dot_v_0)
{
    bool _S632 = n_dot_v_0 < 0.0f;
    float _S633 = _slang_select(_S632, material_12.ior,1.0f);
    float _S634 = _slang_select(_S632, 1.0f,material_12.ior);
    return make_float2 (_S633, _S634);
}

__device__ bool neeDecision(BSDFMaterial material_13, float n_dot_v_1, float eta_i_8, float eta_o_8)
{
    float _S635 = fresnel((F32_abs((n_dot_v_1))), eta_i_8, eta_o_8);
    float3  _S636 = mix_0(make_float3 (_S635), material_13.albedo, material_13.metallic);
    float _S637 = rgb_to_greyscale(_S636);
    float _S638 = (F32_max(((1.0f - _S637) * (1.0f - material_13.metallic) * (1.0f - material_13.transmission)), (0.0f)));
    bool _S639 = _S638 > 0.03999999910593033f;
    bool _S640;
    if(_S639)
    {
        _S640 = true;
    }
    else
    {
        _S640 = (material_13.roughness) > 0.20000000298023224f;
    }
    return _S640;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_14)
{
    float _S641 = rgb_to_greyscale(material_14->translucent);
    return _S641 > 0.0f;
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
    MediumSides _S642;
    (&_S642)->behind = *behind_0;
    (&_S642)->front = *front_0;
    (&_S642)->fillings = fillings_1;
    (&_S642)->face = face_1;
    return _S642;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_13, FKMedium * outside_0)
{
    float3  _S643 = surface_9->geometry_n;
    MediumSides _S644 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S644;
    bool _S645 = surface_9->encloses;
    if(_S645)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S646 = (dot_0(dir_13, _S643)) > 0.0f;
        if(_S646)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_14, uint depth_2, uint lobe_3, float length_3, float width_1, FKHit * own_1, bool fiber_1, FKMedium * outside_1)
{
    float3  _S647 = surface_10->geometry_n;
    ShadowContext _S648 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
    bool _S649 = surface_10->encloses;
    ShadowContext context_2;
    if(_S649)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S650 = - _S647;
        float3  _S651 = _slang_select(turned_0, _S650,_S647);
        (&faced_1)->geometry_n = _S651;
        FKMedium _S652 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S653 = faced_1;
        FKMedium _S654 = _S652;
        MediumSides _S655 = mediumSides_0(&_S653, &_S654, filling_1, dir_14, outside_1);
        ShadowContext _S656 = ShadowContext_x24init_0(_S655.behind.extinction, _S655.front.extinction, _S655.fillings, _S647, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
        if(turned_0)
        {
            uint2  _S657 = _S655.fillings;
            ShadowContext _S658 = ShadowContext_x24init_0(_S655.front.extinction, _S655.behind.extinction, uint2 {_S657.y, _S657.x}, _S647, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
            context_2 = _S658;
        }
        else
        {
            context_2 = _S656;
        }
    }
    else
    {
        context_2 = _S648;
    }
    return context_2;
}

static __device__ bool any_0(bool3  x_15)
{
    bool result_8 = false;
    int i_15 = int(0);
    for(;;)
    {
        if(i_15 < int(3))
        {
        }
        else
        {
            break;
        }
        if(result_8)
        {
            result_8 = true;
        }
        else
        {
            result_8 = (bool((_slang_vector_get_element(x_15, i_15))));
        }
        i_15 = i_15 + int(1);
    }
    return result_8;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_3, BSDFMaterial * material_15, float eta_i_9, float eta_o_9, bool competing_1, uint random_state_11)
{
    float3  _S659 = light_2->dir;
    bool _S660 = (dot_0(geometry_n_3, - in_dir_8) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 4>  throughputs_1;
    FixedArray<float, 4>  pdfs_3;
    float3  _S661 = BSDF(in_dir_8, _S659, smooth_n_5, *material_15, eta_i_9, eta_o_9, _S660, random_state_11, &throughputs_1, &pdfs_3);
    bool _S662 = !competing_1;
    bool _S663;
    if(_S662)
    {
        _S663 = true;
    }
    else
    {
        _S663 = (light_2->density) == 0.0f;
    }
    if(_S663)
    {
        return _S661 * light_2->radiance;
    }
    float3  _S664 = make_float3 (0.0f);
    uint i_16 = 0U;
    float3  weighted_0 = _S664;
    for(;;)
    {
        if(i_16 < 4U)
        {
        }
        else
        {
            break;
        }
        bool _S665 = (pdfs_3[i_16]) > 0.0f;
        if(_S665)
        {
            float _S666 = light_2->density;
            float _S667 = pdfs_3[i_16] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_16] * make_float3 (pdfs_3[i_16]) / make_float3 (_S666 * (1.0f + _S667 * _S667));
            weighted_0 = weighted_1;
        }
        uint i_17 = i_16 + 1U;
        i_16 = i_17;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_12, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S668;
    (&_S668)->unit_direction = unit_direction_1;
    (&_S668)->throughput = throughput_1;
    (&_S668)->random_state = random_state_12;
    (&_S668)->refracted = refracted_3;
    (&_S668)->lobe = lobe_4;
    (&_S668)->pdf = pdf_6;
    return _S668;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_8, float n_i_dot_v_5, float alpha_13, BSDFMaterial material_16, BSDFLobes lobes_9, float eta_i_10, float eta_o_10, uint random_state_13)
{
    float3  _S669 = make_float3 (1.0f);
    SampleBSDF _S670 = SampleBSDF_x24init_0(_S669, _S669, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S670;
    Random _S671 = pcg(random_state_13);
    Random _S672 = pcg(_S671.state);
    (&sample_1)->random_state = _S672.state;
    float _S673 = _S671.value;
    float _S674 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S673 * _S673))))));
    float _S675 = 6.28318548202514648f * _S672.value;
    float3  _S676 = tangentToWorld(make_float3 (_S674 * (F32_cos((_S675))), _S671.value, _S674 * (F32_sin((_S675)))), n_i_8);
    (&sample_1)->unit_direction = _S676;
    (&sample_1)->lobe = 4U;
    float3  _S677 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_8, alpha_13, material_16, lobes_9);
    (&sample_1)->throughput = _S677;
    float _S678 = sheenVelvetPDF(_S671.value, 0.0f, n_i_dot_v_5, alpha_13, lobes_9, eta_i_10, eta_o_10);
    (&sample_1)->pdf = _S678;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S679 = (F32_sqrt((random_1_0)));
    float _S680 = 6.28318548202514648f * random_2_0;
    float _S681 = _S679 * (F32_cos((_S680)));
    float _S682 = _S679 * (F32_sin((_S680)));
    float _S683 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S681 * _S681 - _S682 * _S682))))));
    return make_float3 (_S681, _S683, _S682);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_2, float3  n_i_9, float n_i_dot_v_6, float alpha_14, BSDFMaterial material_17, BSDFLobes lobes_10, float eta_i_11, float eta_o_11, uint random_state_14)
{
    float3  _S684 = make_float3 (1.0f);
    SampleBSDF _S685 = SampleBSDF_x24init_0(_S684, _S684, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S685;
    Random _S686 = pcg(random_state_14);
    Random _S687 = pcg(_S686.state);
    (&sample_2)->random_state = _S687.state;
    float3  _S688 = sampleCosWeightedHemisphere(_S686.value, _S687.value);
    bool _S689 = u_2 < (lobes_10.p_diffuse * lobes_10.translucent_share);
    float _S690 = _S688.y;
    float _S691 = - _S690;
    float _S692 = _slang_select(_S689, _S691,_S690);
    float3  _S693 = tangentToWorld(make_float3 (_S688.x, _S692, _S688.z), n_i_9);
    (&sample_2)->unit_direction = _S693;
    (&sample_2)->refracted = _S689;
    (&sample_2)->lobe = 0U;
    float3  _S694 = diffuseBSDF((&sample_2)->unit_direction, n_i_9, alpha_14, material_17, lobes_10);
    (&sample_2)->throughput = _S694;
    float _S695 = diffusePDF(_S692, 0.0f, n_i_dot_v_6, alpha_14, lobes_10, eta_i_11, eta_o_11);
    (&sample_2)->pdf = _S695;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_10, float n_i_dot_v_7, float alpha_15, BSDFMaterial material_18, BSDFLobes lobes_11, float eta_i_12, float eta_o_12, uint random_state_15)
{
    float3  _S696 = make_float3 (1.0f);
    SampleBSDF _S697 = SampleBSDF_x24init_0(_S696, _S696, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S697;
    (&sample_3)->unit_direction = lobes_11.refracted;
    (&sample_3)->random_state = random_state_15;
    (&sample_3)->refracted = true;
    (&sample_3)->lobe = 1U;
    float3  _S698 = refractBSDF((&sample_3)->unit_direction, n_i_10, alpha_15, material_18, lobes_11);
    (&sample_3)->throughput = _S698;
    float _S699 = refractPDF(0.0f, dot_0((&sample_3)->unit_direction, ggx_n_3), n_i_dot_v_7, alpha_15, lobes_11, eta_i_12, eta_o_12);
    (&sample_3)->pdf = _S699;
    return sample_3;
}

static __device__ float3  reflect_0(float3  i_18, float3  n_11)
{
    return i_18 - make_float3 (2.0f * dot_0(n_11, i_18)) * n_11;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_11, float n_i_dot_v_8, float alpha_16, BSDFMaterial material_19, BSDFLobes lobes_12, float eta_i_13, float eta_o_13, uint random_state_16)
{
    float3  _S700 = make_float3 (1.0f);
    SampleBSDF _S701 = SampleBSDF_x24init_0(_S700, _S700, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S701;
    float3  _S702 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S703 = ((((_S702)) * make_float3(rnorm3df(((_S702)).x, ((_S702)).y, ((_S702)).z))));
    (&sample_4)->unit_direction = _S703;
    (&sample_4)->random_state = random_state_16;
    (&sample_4)->lobe = 2U;
    float3  _S704 = reflectBSDF((&sample_4)->unit_direction, n_i_11, alpha_16, material_19, lobes_12);
    (&sample_4)->throughput = _S704;
    float _S705 = reflectPDF(0.0f, 0.0f, n_i_dot_v_8, alpha_16, lobes_12, eta_i_13, eta_o_13);
    (&sample_4)->pdf = _S705;
    return sample_4;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_12, BSDFMaterial material_20, float eta_i_14, float eta_o_14, uint random_init_0, float2  screen_space_0)
{
    uint random_state_17 = random_init_0;
    float3  _S706 = negate_0(in_dir_10);
    float _S707 = dot_0(n_12, _S706);
    float _S708 = sign_0(_S707);
    float3  n_i_12 = n_12 * make_float3 (_S708);
    float _S709 = (F32_abs((_S707)));
    float _S710 = material_20.roughness;
    float _S711 = _S710 * _S710;
    AnisotropicFrame _S712 = anisotropicFrame(material_20, n_i_12);
    SheenProfile _S713 = sheenProfile(_S706, n_i_12, material_20);
    float3  _S714 = sampleHalfVector(_S706, n_i_12, _S711, _S712, &random_state_17);
    BSDFLobes _S715 = bsdfLobes(in_dir_10, _S706, n_i_12, _S714, material_20, eta_i_14, eta_o_14, _S712, _S713);
    BSDFLobes lobes_13 = _S715;
    float _S716 = translucentShare(material_20);
    (&lobes_13)->translucent_share = _S716;
    Random _S717 = pcg(random_state_17);
    random_state_17 = _S717.state;
    bool _S718 = (_S717.value) < ((&lobes_13)->p_sheen_velvet);
    if(_S718)
    {
        SampleBSDF _S719 = sheenVelvetSample(n_i_12, _S709, _S711, material_20, lobes_13, eta_i_14, eta_o_14, random_state_17);
        return _S719;
    }
    float _S720 = _S717.value - (&lobes_13)->p_sheen_velvet;
    bool _S721 = _S720 < ((&lobes_13)->p_diffuse);
    if(_S721)
    {
        SampleBSDF _S722 = diffuseSample(_S720, n_i_12, _S709, _S711, material_20, lobes_13, eta_i_14, eta_o_14, random_state_17);
        return _S722;
    }
    bool _S723 = _S720 < ((&lobes_13)->p_diffuse + (&lobes_13)->p_refract);
    if(_S723)
    {
        SampleBSDF _S724 = refractSample(_S714, n_i_12, _S709, _S711, material_20, lobes_13, eta_i_14, eta_o_14, random_state_17);
        return _S724;
    }
    SampleBSDF _S725 = reflectSample(in_dir_10, _S714, n_i_12, _S709, _S711, material_20, lobes_13, eta_i_14, eta_o_14, random_state_17);
    return _S725;
}

static __device__ bool boundsVolume_0(FKSurface * surface_11)
{
    return surface_11->encloses;
}

static __device__ float distance_3(float3  x_16, float3  y_5)
{
    return length_0(x_16 - y_5);
}

static __device__ Shift walk_0(Domain * dom_0, Reservoir * r_1, bool replay_0, float scale_1, Selection * sel_1)
{
    float spread_0;
    bool turned_1;
    bool is_inside_5;
    bool viewed_0;
    bool _S726;
    bool _S727;
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
    int _S728;
    Shift ended_0;
    float density_3;
    float spread_1;
    float width_3;
    float sky_pdf_1;
    float spread_2;
    float width_4;
    uint b_4;
    float3  _S729 = make_float3 (0.0f);
    Shift _S730 = Shift_x24init_0(_S729, 0.0f);
    uint _S731 = r_1->path;
    uint _S732 = extractBits_0(r_1->path, 0U, 5U);
    uint _S733 = extractBits_0(_S731, 5U, 5U);
    uint _S734 = extractBits_0(_S731, 10U, 2U);
    uint _S735 = extractBits_0(_S731, 12U, 3U);
    bool passes_0;
    if(replay_0)
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
    FKHit _S746 = (fcptReservoirHit((*r_1)));
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
    float g_in_0 = 0.0f;
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
    uint _S757 = r_1->seed;
    (&chain_0)->seed = r_1->seed;
    (&ray_2)->origin = _S747;
    (&hit_1)->distance = _S753;
    FKMedium _S758 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_1)->distance), (&filling_2)));
    uint _S759 = filling_2;
    bool _S760 = (fcptVaryingUsed());
    uint _S761 = _slang_select(_S760, _S759,4294967295U);
    filling_2 = _S761;
    scatter_in_0 = _S758.scatter;
    extinction_in_0 = _S758.extinction;
    g_in_0 = _S758.g;
    Reservoir _S762 = chain_0;
    uint _S763 = filling_2;
    for(;;)
    {
        bool _S764 = (fcptVaryingUsed());
        if(_S764)
        {
            passes_0 = _S763 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S765 = (fcptMajorant((_S763)));
            spread_0 = _S765;
        }
        else
        {
            spread_0 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_0)
        {
            turned_1 = 4294967295U == _S745;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S734 == 1U;
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
            ended_0 = _S730;
            sky_pdf_0 = 0.0f;
            spread_0 = _S751;
            width_2 = _S752;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_3 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S766 = (&prev_0)->rough;
        if(_S766)
        {
            turned_1 = !(spread_0 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S767 = stream(_S757, 384U);
        uint tracking_0 = _S767;
        weight_1 = throughput_3;
        glowed_0 = _S729;
        b_3 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_0 = _S751;
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
            uint _S768 = b_3 + 320U;
            bool _S769 = b_3 == 4294967295U;
            uint _S770 = _slang_select(_S769, 384U,_S768);
            uint _S771 = stream(_S757, _S770);
            Random _S772 = pcg(_S771);
            float _S773 = - (F32_log((1.0f - _S772.value))) / spread_0;
            if(passes_0)
            {
                float3  _S774 = (&ray_2)->origin;
                float3  _S775 = (&ray_2)->unit_direction;
                float _S776 = (&hit_1)->distance;
                uint _S777 = _slang_select(_S769, 0U,b_3);
                uint _S778 = (&prev_0)->lobe;
                uint _S779 = _slang_select(_S769, 3U,_S778);
                float _S780 = (fcptTrackMedium((_S763), (_S774), (_S775), (_S776), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S777), (_S779), (_S769)));
                geometry_density_0 = _S780;
            }
            else
            {
                geometry_density_0 = _S773;
            }
            bool _S781 = !(geometry_density_0 < ((&hit_1)->distance));
            if(_S781)
            {
                _S728 = int(1);
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
                float3  _S782 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S783 = sel_1->glow + _S782;
                sel_1->glow = _S783;
            }
            else
            {
            }
            glowed_0 = _S729;
            uint b_5 = b_3 + 1U;
            float3  _S784 = (&ray_2)->origin + make_float3 (geometry_density_0) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S784;
            float3  _S785 = flightWeight_0(scatter_in_0, extinction_in_0, spread_0, geometry_density_0, true);
            float3  _S786 = weight_1;
            float3  _S787 = _slang_select(passes_0, _S786,_S785);
            float3  throughput_4 = throughput_2 * _S787;
            uint _S788 = stream(_S757, b_5 + 320U);
            tracking_0 = _S788;
            weight_1 = throughput_3;
            float width_5 = width_2 + threshold_0 * geometry_density_0;
            float _S789 = threshold_0 + 3.14159274101257324f;
            bool _S790 = !replay_0;
            if(_S790)
            {
                is_inside_5 = true;
            }
            else
            {
                bool _S791 = b_5 == _S745;
                if(_S791)
                {
                    is_inside_5 = !passes_0;
                }
                else
                {
                    is_inside_5 = false;
                }
            }
            TreeSample _S792 = TreeSample_x24init_0(_S729, _S729, 0.0f, 0U);
            if(is_inside_5)
            {
                float3  _S793 = (&ray_2)->origin;
                float3  _S794 = (&ray_2)->unit_direction;
                float3  _S795 = (&ray_2)->unit_direction;
                uint _S796 = stream(_S757, b_5 + 64U);
                float3  _S797 = extinction_in_0;
                float3  _S798 = extinction_in_0;
                uint2  _S799 = make_uint2 (_S763);
                float3  _S800 = (&ray_2)->unit_direction;
                uint _S801 = arrivalLobe_0(b_5, (&prev_0)->lobe);
                FKHit _S802 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S803 = _S802;
                ShadowContext _S804 = ShadowContext_x24init_0(_S797, _S798, _S799, _S800, b_5, _S801, false, geometry_density_0, width_5, &_S803, false);
                ShadowContext _S805 = _S804;
                TreeSample _S806 = sampleLightTree_0(_S793, _S794, _S795, 0.0f, true, _S796, &_S805);
                light_3 = _S806;
            }
            else
            {
                light_3 = _S792;
            }
            float _S807 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S808 = (fcptMaxBounces());
            bool _S809 = b_5 < _S808;
            if(_S809)
            {
                viewed_0 = (light_3.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S810 = _slang_select(viewed_0, _S807,0.0f);
            float3  _S811 = throughput_4 * light_3.radiance;
            float _S812 = powerHeuristic(light_3.density, _S810);
            float3  _S813 = _S811 * make_float3 (_S807 * _S812);
            float3  _S814 = _slang_select(is_inside_5, _S813,_S729);
            if(replay_0)
            {
                _S726 = b_5 == _S745;
            }
            else
            {
                _S726 = false;
            }
            if(_S726)
            {
                bool _S815 = _S734 == 2U;
                if(_S815)
                {
                    float _S816 = rgb_to_greyscale(_S814);
                    passes_0 = _S816 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S817 = Shift_x24init_0(_S814, 1.0f);
                    _S728 = int(0);
                    ended_0 = _S817;
                    spread_0 = _S789;
                    geometry_density_0 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_5;
                    break;
                }
                _S728 = int(0);
                ended_0 = _S730;
                spread_0 = _S789;
                geometry_density_0 = width_5;
                chain_throughput_0 = throughput_4;
                layer_0 = b_5;
                break;
            }
            if(_S790)
            {
                Reservoir candidate_2 = _S762;
                uint _S818 = extractBits_0(_S762.path, 10U, 2U);
                bool _S819 = _S818 == 1U;
                if(_S819)
                {
                    float3  _S820 = safeDivide(_S814, _S729);
                    (&candidate_2)->radiance = _S820;
                }
                else
                {
                    uint _S821 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                    uint _S822 = insertBits_0(_S821, 2U, 10U, 2U);
                    (&candidate_2)->path = _S822;
                }
                Reservoir _S823 = withEnd(candidate_2, 0U, b_5, _S814);
                offer(sel_1, _S823, _S814 * make_float3 (scale_1) / make_float3 (density_2));
                float _S824 = survivalProbability(throughput_4, density_2);
                uint _S825 = stream(_S757, b_5 + 128U);
                Random _S826 = pcg(_S825);
                bool _S827 = _S824 < (_S826.value);
                if(_S827)
                {
                    _S727 = true;
                }
                else
                {
                    uint _S828 = (fcptMaxBounces());
                    _S727 = b_5 >= _S828;
                }
                if(_S727)
                {
                    _S728 = int(0);
                    ended_0 = _S730;
                    spread_0 = _S789;
                    geometry_density_0 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_5;
                    break;
                }
                float _S829 = density_2 * _S824;
                density_2 = _S829;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S830 = stream(_S757, b_5);
            float3  _S831 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S830, &phase_pdf_0);
            (&ray_2)->unit_direction = _S831;
            NEEVertex _S832 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S729, (&ray_2)->origin);
            nee_vertex_0 = _S832;
            Vertex _S833 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_0 = _S833;
            float _S834 = (&prev_0)->pdf;
            FKRay _S835 = ray_2;
            FKHit _S836 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S837 = (fcptTraverseInstanceBVH((_S835), (true), (4.294967296e+09f), (false), (_S836), (false)));
            hit_1 = _S837;
            b_3 = b_5;
            throughput_2 = throughput_4;
            threshold_0 = _S789;
            width_2 = width_5;
            sky_pdf_0 = _S834;
        }
        if(_S728 != int(1))
        {
            width_2 = geometry_density_0;
            throughput_2 = chain_throughput_0;
            b_3 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S730;
        spread_0 = threshold_0;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S838 = b_3 == 4294967295U;
    bool _S839 = ((&hit_1)->instance_index) == 4294967295U;
    if(_S839)
    {
        bool _S840 = !(&nee_vertex_0)->none;
        float _S841 = _slang_select(_S840, sky_pdf_0,0.0f);
        float _S842 = escapeWeight_0(_S841, (&ray_2)->unit_direction);
        float3  _S843 = environment_0((&ray_2)->unit_direction, b_3, (&prev_0)->lobe);
        float3  _S844 = throughput_2 * _S843;
        if(replay_0)
        {
            bool _S845 = b_3 == _S745;
            if(_S845)
            {
                passes_0 = _S734 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S844 * make_float3 (_S842) / make_float3 (r_1->jac), density_2 / r_1->jac);
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
                passes_0 = b_3 == _S732;
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
                return Shift_x24init_0(_S844 * make_float3 (_S842), 1.0f);
            }
            return _S730;
        }
        Reservoir candidate_3 = chain_0;
        uint _S846 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S847 = _S846 == 1U;
        if(_S847)
        {
            uint _S848 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S849 = _S848 == b_3;
            float _S850 = _slang_select(_S849, 1.0f,_S842);
            float3  _S851 = safeDivide(_S844 * make_float3 (_S850), _S729);
            (&candidate_3)->radiance = _S851;
        }
        else
        {
            bool _S852 = (&prev_0)->rough;
            if(_S852)
            {
                uint _S853 = insertBits_0(0U, b_3 + 1U, 5U, 5U);
                uint _S854 = insertBits_0(_S853, 3U, 10U, 2U);
                uint _S855 = insertBits_0(_S854, (&prev_0)->lobe, 15U, 3U);
                bool _S856 = (&prev_0)->inside;
                uint _S857 = _slang_select(_S856, 1U,0U);
                uint _S858 = insertBits_0(_S855, _S857, 22U, 1U);
                (&candidate_3)->path = _S858;
                (&candidate_3)->jac = (&prev_0)->pdf;
                (&candidate_3)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S859 = _S844 * make_float3 (_S842);
        Reservoir _S860 = withEnd(candidate_3, 3U, b_3, _S859);
        offer(sel_1, _S860, _S859 * make_float3 (scale_1) / make_float3 (density_2));
        return _S730;
    }
    float3  _S861 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S861;
    bool _S862 = (fcptVaryingUsed());
    if(_S862)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S863 = !replay_0;
        if(_S863)
        {
            float3  _S864 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S865 = sel_1->glow + _S864;
            sel_1->glow = _S865;
        }
        float3  _S866 = throughput_2 * weight_1;
        throughput_2 = _S866;
    }
    else
    {
        float3  _S867 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
        float3  _S868 = throughput_2 * _S867;
        throughput_2 = _S868;
    }
    float _S869 = width_2 + spread_0 * (&hit_1)->distance;
    uint _S870 = b_3 + 1U;
    b_3 = _S870;
    layer_0 = 0U;
    width_2 = _S869;
    passes_0 = false;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S729;
    float3  reconnection_0 = _S729;
    viewed_0 = _S838;
    for(;;)
    {
        bool _S871 = ((&hit_1)->is_point_light) == 1U;
        if(replay_0)
        {
            _S726 = _S734 == 1U;
        }
        else
        {
            _S726 = false;
        }
        if(_S726)
        {
            _S727 = b_3 == _S733;
        }
        else
        {
            _S727 = false;
        }
        bool _S872;
        if(_S727)
        {
            bool _S873 = ((&hit_1)->instance_index) != (_S746.instance_index);
            if(_S873)
            {
                _S872 = true;
            }
            else
            {
                _S872 = ((&hit_1)->triangle_index) != (_S746.triangle_index);
            }
        }
        else
        {
            _S872 = false;
        }
        if(_S872)
        {
            return _S730;
        }
        FKMedium _S874 = Medium_x24init_0(_S729, _S729, 0.0f);
        BSDFMaterial _S875 = Material_x24init_0(_S729, _S729, 0.0f, 0.0f, 0.0f, 0.0f, _S729, throughput_3, 1.0f, _S729, _S729, 0.5f, 0.0f, 0.0f, _S729);
        FKMedium _S876 = _S874;
        FKSurface _S877 = Surface_x24init_0(_S729, _S729, 0.0f, &_S875, false, 0U, 1.0f, false, &_S876, 4294967295U, _S729);
        bool _S878 = !_S871;
        bool scatter_2;
        bool is_inside_6;
        float3  front_n_0;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S878)
        {
            uint _S879 = stream(_S757, b_3);
            uint _S880 = arrivalLobe_0(b_3, (&prev_0)->lobe);
            FKSurface _S881 = (fcptSurfaceAtPath((hit_1), ((&ray_2)->origin), (_S879), (width_2), (layer_0), (b_3), (_S880), ((&ray_2)->unit_direction)));
            bool _S882 = !passes_0;
            FKSurface _S883 = _S881;
            FKSurface _S884 = emitting_0(&_S883, _S882);
            uint _S885 = stream(_S757, b_3 + 256U);
            Random _S886 = pcg(_S885);
            FKSurface _S887 = _S884;
            FKSurface _S888 = uncovered_0(&_S887, _S886.value);
            float _S889 = facingSign(_S888.material.transmission, _S888.geometry_n, (&ray_2)->unit_direction);
            bool _S890 = _S889 < 0.0f;
            bool _S891 = (_S888.material.transmission) > 0.0f;
            if(_S891)
            {
                bool _S892 = arrivesBehind_0((&ray_2)->unit_direction, _S888.geometry_n);
                scatter_2 = _S892;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S893 = _S888;
            FKSurface _S894 = facingRay_0(&_S893, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S895 = arrivesBehind_0((&ray_2)->unit_direction, _S894.geometry_n);
                is_inside_6 = _S895;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S896 = beerLambert((&hit_1)->distance, _S894.material.absorption);
                float3  _S897 = throughput_2 * _S896;
                front_n_0 = _S897;
            }
            else
            {
                front_n_0 = throughput_2;
            }
            bool _S898 = !_S894.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S894.geometry_n, (&ray_2)->unit_direction)))) / ((&hit_1)->distance * (&hit_1)->distance);
            bool _S899 = b_3 == _S870;
            if(_S899)
            {
                float _S900 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S900;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float3  _S901 = front_n_0;
            float _S902 = geometry_density_0;
            scatter_2 = _S898;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S902;
            surface_12 = _S894;
            front_n_0 = _S888.smooth_n;
            throughput_5 = _S901;
            turned_1 = _S890;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_12 = _S877;
            front_n_0 = _S729;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S903;
        if(scatter_2)
        {
            _S903 = (&prev_0)->rough;
        }
        else
        {
            _S903 = false;
        }
        bool _S904;
        if(_S903)
        {
            _S904 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S904 = false;
        }
        FKSurface _S905 = surface_12;
        FKSurface _S906 = surface_12;
        float _S907 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        float2  _S908 = vertexEta(_S905.material, _S907);
        bool _S909;
        if(scatter_2)
        {
            uint _S910 = (fcptMaxBounces());
            bool _S911 = b_3 >= _S910;
            if(_S911)
            {
                _S909 = true;
            }
            else
            {
                bool _S912 = neeDecision(_S905.material, _S907, _S908.x, _S908.y);
                _S909 = _S912;
            }
        }
        else
        {
            _S909 = false;
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
            nee_0 = _S909;
        }
        bool _S914 = (fcptHairUsed());
        bool _S915;
        if(_S914)
        {
            float3  _S916 = surface_12.hair;
            _S915 = (dot_0(_S916, _S916)) > 0.0f;
        }
        else
        {
            _S915 = false;
        }
        bool _S917;
        if(_S915)
        {
            _S917 = true;
        }
        else
        {
            BSDFMaterial _S918 = _S905.material;
            bool _S919 = isTranslucent_0(&_S918);
            _S917 = _S919;
        }
        bool _S920;
        if(_S917)
        {
            _S920 = true;
        }
        else
        {
            bool _S921 = (_S905.material.transmission) > 0.0f;
            if(_S921)
            {
                uint _S922 = (fcptLayers((hit_1)));
                _S920 = _S922 == 1U;
            }
            else
            {
                _S920 = false;
            }
        }
        float3  _S923 = emitted_0(_S905.material.emissive, (&ray_2)->unit_direction, front_n_0);
        float3  emission_0;
        if(_S871)
        {
            float3  _S924 = (fcptCalculatePointLightContrib(((&hit_1)->instance_index)));
            emission_0 = _S924;
        }
        else
        {
            emission_0 = _S923;
        }
        bool _S925 = !replay_0;
        bool _S926;
        if(_S925)
        {
            _S926 = true;
        }
        else
        {
            _S926 = b_3 >= _S745;
        }
        bool _S927;
        if(_S926)
        {
            float _S928 = rgb_to_greyscale(emission_0);
            _S927 = _S928 > 0.0f;
        }
        else
        {
            _S927 = false;
        }
        float3  emission_1;
        if(_S927)
        {
            NEEVertex _S929 = nee_vertex_0;
            FKHit _S930 = hit_1;
            float _S931 = emissionWeight_0(&_S929, &_S930, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S931);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S932;
        if(replay_0)
        {
            _S932 = _S734 == 1U;
        }
        else
        {
            _S932 = false;
        }
        bool _S933;
        if(_S932)
        {
            _S933 = b_3 > _S733;
        }
        else
        {
            _S933 = false;
        }
        bool _S934;
        if(_S933)
        {
            _S934 = b_3 == _S732;
        }
        else
        {
            _S934 = false;
        }
        bool _S935;
        if(_S934)
        {
            bool _S936 = _S735 == 1U;
            if(_S936)
            {
                _S935 = true;
            }
            else
            {
                _S935 = _S735 == 2U;
            }
        }
        else
        {
            _S935 = false;
        }
        if(_S935)
        {
            bool _S937 = _S871 != (_S735 == 2U);
            if(_S937)
            {
                return _S730;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_1->jac), density_2 / r_1->jac);
        }
        uint _S938 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S939 = _S938 == 1U;
        Reservoir here_0 = chain_0;
        uint _S940 = insertBits_0(0U, b_3, 5U, 5U);
        uint _S941 = insertBits_0(_S940, 1U, 10U, 2U);
        uint _S942 = insertBits_0(_S941, (&prev_0)->lobe, 15U, 3U);
        bool _S943 = (&prev_0)->inside;
        uint _S944 = _slang_select(_S943, 1U,0U);
        uint _S945 = insertBits_0(_S942, _S944, 22U, 1U);
        (&here_0)->path = _S945;
        float _S946 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S946;
        fcptWithReservoirHit((&here_0), (&hit_1));
        bool _S947;
        if(replay_0)
        {
            _S947 = _S734 == 1U;
        }
        else
        {
            _S947 = false;
        }
        bool _S948;
        if(_S947)
        {
            _S948 = b_3 == _S733;
        }
        else
        {
            _S948 = false;
        }
        bool _S949 = b_3 == _S745;
        bool _S950;
        if(_S949)
        {
            bool _S951 = !scatter_2;
            if(_S951)
            {
                _S950 = true;
            }
            else
            {
                bool _S952 = _S734 != 1U;
                if(_S952)
                {
                    _S950 = _S734 != 3U;
                }
                else
                {
                    _S950 = false;
                }
            }
        }
        else
        {
            _S950 = false;
        }
        bool _S953;
        if(_S950)
        {
            _S953 = _S734 == 2U;
        }
        else
        {
            _S953 = false;
        }
        bool _S954;
        if(_S953)
        {
            _S954 = !_S904;
        }
        else
        {
            _S954 = false;
        }
        bool _S955;
        if(_S954)
        {
            _S955 = _S735 != 4U;
        }
        else
        {
            _S955 = false;
        }
        bool _S956 = _S733 == _S732;
        bool _S957;
        if(_S956)
        {
            _S957 = _S735 == 0U;
        }
        else
        {
            _S957 = false;
        }
        bool _S958;
        if(_S957)
        {
            _S958 = ((&hit_1)->instance_index) == (_S746.instance_index);
        }
        else
        {
            _S958 = false;
        }
        bool _S959;
        if(_S958)
        {
            _S959 = ((&hit_1)->triangle_index) == (_S746.triangle_index);
        }
        else
        {
            _S959 = false;
        }
        bool _S960;
        if(_S959)
        {
            _S960 = _S904;
        }
        else
        {
            _S960 = false;
        }
        bool _S961 = _slang_select(_S948, _S960,_S955);
        bool _S962;
        if(nee_0)
        {
            _S962 = _slang_select(replay_0, _S961,scatter_2);
        }
        else
        {
            _S962 = false;
        }
        TreeSample _S963 = TreeSample_x24init_0(_S729, _S729, 0.0f, 0U);
        float3  throughput_6;
        float3  lit_0;
        if(_S962)
        {
            float3  _S964 = (&ray_2)->origin;
            if(_S915)
            {
                throughput_6 = _S729;
            }
            else
            {
                throughput_6 = _S906.smooth_n;
            }
            FKSurface _S965 = surface_12;
            uint _S966 = stream(_S757, b_3 + 64U);
            uint _S967 = arrivalLobe_0(b_3, (&prev_0)->lobe);
            FKMedium _S968 = (fcptOutsideMedium((hit_1)));
            FKSurface _S969 = surface_12;
            FKHit _S970 = hit_1;
            FKMedium _S971 = _S968;
            ShadowContext _S972 = shadowContext_0(&_S969, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_3, _S967, (&hit_1)->distance, width_2, &_S970, _S915, &_S971);
            ShadowContext _S973 = _S972;
            TreeSample _S974 = sampleLightTree_0(_S964, throughput_6, surface_12.geometry_n, surface_12.geometry_offset, _S920, _S966, &_S973);
            bool _S975 = any_0((_S974.radiance) != _S729);
            if(_S975)
            {
                if(_S915)
                {
                    uint _S976 = (fcptMaxBounces());
                    bool _S977 = b_3 < _S976;
                    FKSurface _S978 = surface_12;
                    TreeSample _S979 = _S974;
                    float3  _S980 = hairLight_0(&_S978, (&ray_2)->unit_direction, &_S979, _S977);
                    lit_0 = _S980;
                }
                else
                {
                    float _S981 = _S908.x;
                    float _S982 = _S908.y;
                    uint _S983 = (fcptMaxBounces());
                    bool _S984 = b_3 < _S983;
                    TreeSample _S985 = _S974;
                    BSDFMaterial _S986 = _S905.material;
                    float3  _S987 = lightBSDF_0((&ray_2)->unit_direction, &_S985, _S906.smooth_n, _S965.geometry_n, &_S986, _S981, _S982, _S984, surface_12.random_state);
                    lit_0 = _S987;
                }
            }
            else
            {
                lit_0 = _S729;
            }
            light_3 = _S974;
        }
        else
        {
            light_3 = _S963;
            lit_0 = _S729;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S988;
        bool _S989;
        float density_4;
        if(_S948)
        {
            bool _S990 = !_S904;
            if(_S990)
            {
                return _S730;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S956)
            {
                viewed_1 = _S735 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            if(_S956)
            {
                refracted_4 = _S735 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
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
                    return _S730;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            if(_S956)
            {
                wrong_side_0 = _S735 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S993 = !nee_0;
                if(_S993)
                {
                    return _S730;
                }
                float _S994 = environmentPdf_0(r_1->dir);
                float3  _S995 = skyBSDF((&ray_2)->unit_direction, r_1->dir, surface_12, _S908, is_inside_6, _S994, surface_12.random_state);
                return Shift_x24init_0(throughput_7 * _S995 * r_1->radiance / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            uint _S996 = extractBits_0(_S731, 21U, 1U);
            bool _S997 = nee_0 != (_S996 == 1U);
            if(_S997)
            {
                return _S730;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_0)
            {
                viewed_1 = _S949;
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
                    bool _S999 = _S734 != 1U;
                    if(_S999)
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
                bool _S1000 = _S734 == 2U;
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
                    passes_0 = !_S904;
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
                    uint _S1001 = stream(_S757, b_3 + 448U);
                    FKRay _S1002 = ray_2;
                    FKSurface _S1003 = surface_12;
                    SkySample _S1004 = sampleSky_0(&_S1002, &_S1003, _S908, is_inside_6, _S1001, surface_12.random_state);
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
                    passes_0 = !_S904;
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
                    passes_0 = _S871;
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
                    passes_0 = !_S904;
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
                if(_S925)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1007 = b_3 > 0U;
                    if(_S1007)
                    {
                        Reservoir candidate_4 = chain_0;
                        if(_S939)
                        {
                            float3  _S1008 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_4)->radiance = _S1008;
                        }
                        else
                        {
                            if(_S904)
                            {
                                candidate_4 = here_0;
                            }
                        }
                        float3  _S1009 = throughput_5 * emission_1;
                        Reservoir _S1010 = withEnd(candidate_4, 1U, b_3, _S1009);
                        offer(sel_1, _S1010, _S1009 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1011 = throughput_5 * emission_1;
                        float3  _S1012 = sel_1->glow + _S1011;
                        sel_1->glow = _S1012;
                    }
                    if(nee_0)
                    {
                        float3  _S1013 = throughput_5 * lit_0;
                        Reservoir candidate_5 = chain_0;
                        if(_S939)
                        {
                            float3  _S1014 = safeDivide(_S1013, chain_throughput_0);
                            (&candidate_5)->radiance = _S1014;
                        }
                        else
                        {
                            if(_S904)
                            {
                                candidate_5 = here_0;
                                uint _S1015 = insertBits_0((&candidate_5)->path, 1U, 21U, 1U);
                                (&candidate_5)->path = _S1015;
                                (&candidate_5)->dir = light_3.dir;
                                (&candidate_5)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1016 = insertBits_0(0U, b_3 + 1U, 5U, 5U);
                                uint _S1017 = insertBits_0(_S1016, 2U, 10U, 2U);
                                (&candidate_5)->path = _S1017;
                            }
                        }
                        Reservoir _S1018 = withEnd(candidate_5, 0U, b_3, _S1013);
                        offer(sel_1, _S1018, _S1013 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S915)
                        {
                            _S988 = false;
                        }
                        else
                        {
                            bool _S1019 = environmentMapped_0();
                            _S988 = _S1019;
                        }
                    }
                    else
                    {
                        _S988 = false;
                    }
                    if(_S988)
                    {
                        uint _S1020 = (fcptMaxBounces());
                        _S989 = b_3 < _S1020;
                    }
                    else
                    {
                        _S989 = false;
                    }
                    if(_S989)
                    {
                        uint _S1021 = stream(_S757, b_3 + 448U);
                        FKRay _S1022 = ray_2;
                        FKSurface _S1023 = surface_12;
                        SkySample _S1024 = sampleSky_0(&_S1022, &_S1023, _S908, is_inside_6, _S1021, surface_12.random_state);
                        float3  _S1025 = throughput_5 * _S1024.color;
                        Reservoir candidate_6 = chain_0;
                        if(_S939)
                        {
                            float3  _S1026 = safeDivide(_S1025, chain_throughput_0);
                            (&candidate_6)->radiance = _S1026;
                        }
                        else
                        {
                            if(_S904)
                            {
                                candidate_6 = here_0;
                                uint _S1027 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1027;
                                (&candidate_6)->dir = _S1024.dir;
                                (&candidate_6)->radiance = _S1024.radiance;
                            }
                            else
                            {
                                uint _S1028 = insertBits_0(0U, b_3 + 1U, 5U, 5U);
                                uint _S1029 = insertBits_0(_S1028, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1029;
                            }
                        }
                        Reservoir _S1030 = withEnd(candidate_6, 4U, b_3, _S1025);
                        offer(sel_1, _S1030, _S1025 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1031;
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
                viewed_1 = _S949;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1047 = extractBits_0(_S731, 15U, 3U);
            uint _S1048 = extractBits_0(_S731, 18U, 3U);
            uint _S1049 = _slang_select(_S948, _S1048,_S1047);
            float3  _S1050 = r_1->dir;
            bool refracted_5 = _S1049 == 1U;
            SampleBSDF _S1051 = SampleBSDF_x24init_0(_S729, _S729, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1051;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1052 = extractBits_0(_S731, 22U, 1U);
                bool _S1053 = is_inside_6 != (_S1052 == 1U);
                if(_S1053)
                {
                    return _S730;
                }
                bool _S1054 = _S734 == 1U;
                if(_S1054)
                {
                    float3  _S1055 = (fcptHitPosition((_S746)));
                    throughput_8 = _S1055;
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
                    BSDFMaterial _S1056 = _S905.material;
                    bool _S1057 = isTranslucent_0(&_S1056);
                    if(_S1057)
                    {
                        refracted_4 = _S1049 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1058 = throughput_8 - (&ray_2)->origin;
                        float3  _S1059 = _slang_select(_S1054, _S1058,_S1050);
                        wrong_side_0 = (dot_0(_S906.smooth_n, _S1059) * _S907) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1054)
                {
                    float3  _S1060 = (&ray_2)->origin;
                    FKSurface _S1061 = surface_12;
                    float3  _S1062 = - _S906.smooth_n;
                    bool _S1063 = is_inside_6 != refracted_4;
                    float3  _S1064 = _slang_select(_S1063, _S1062,_S906.smooth_n);
                    float3  _S1065 = throughput_8 - (_S1060 + make_float3 (_S1061.geometry_offset) * _S1064);
                    float3  _S1066 = ((((_S1065)) * make_float3(rnorm3df(((_S1065)).x, ((_S1065)).y, ((_S1065)).z))));
                    reconnection_1 = _S1066;
                }
                else
                {
                    reconnection_1 = _S1050;
                }
                if(_S915)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1067 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1067;
                }
                if(wrong_side_0)
                {
                    return _S730;
                }
                float3  _S1068 = throughput_8;
                throughput_8 = reconnection_1;
                b_6 = _S1049;
                wrong_side_0 = false;
                reconnection_1 = _S1068;
            }
            else
            {
                bool _S1069 = !_S948;
                if(_S1069)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1070;
                    if(_S915)
                    {
                        SampleBSDF _S1071 = (fcptSampleHair((surface_12.hair), (_S905.material.albedo), (_S905.material.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1070 = _S1071;
                    }
                    else
                    {
                        SampleBSDF _S1072 = sampleBSDF((&ray_2)->unit_direction, _S906.smooth_n, _S905.material, _S908.x, _S908.y, surface_12.random_state, make_float2 (0.0f));
                        _S1070 = _S1072;
                    }
                    bsdf_sampled_0 = _S1070;
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
                        if(replay_0)
                        {
                            return _S730;
                        }
                        break;
                    }
                    if(_S915)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1073 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1073;
                    }
                    if(wrong_side_0)
                    {
                        _S988 = (_S905.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S988 = false;
                    }
                    if(_S988)
                    {
                        SampleBSDF _S1074 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S905.material, _S908.x, _S908.y, (&bsdf_sampled_0)->random_state, make_float2 (0.0f));
                        (&bsdf_sampled_0)->unit_direction = _S1074.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1074.refracted;
                        (&bsdf_sampled_0)->throughput = _S1074.throughput;
                        (&bsdf_sampled_0)->lobe = _S1074.lobe;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1075 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1075;
                        }
                    }
                    uint _S1076 = (&bsdf_sampled_0)->lobe;
                    float3  _S1077 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1078 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1079 = (&bsdf_sampled_0)->pdf;
                    float _S1080 = _slang_select(wrong_side_0, 0.0f,_S1079);
                    (&lobe_5)->pdf = _S1080;
                    throughput_8 = _S1077;
                    b_6 = _S1076;
                    refracted_4 = _S1078;
                }
                else
                {
                    throughput_8 = _S1050;
                    b_6 = _S1049;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S988 = true;
            }
            else
            {
                _S988 = _S948;
            }
            float3  chain_throughput_1;
            if(_S988)
            {
                if(_S915)
                {
                    SampleBSDF _S1081 = (fcptConnectHair((surface_12.hair), (_S905.material.albedo), (_S905.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    lobe_5 = _S1081;
                }
                else
                {
                    float3  _S1082 = (&ray_2)->unit_direction;
                    float _S1083 = sign_0(_S907);
                    float3  _S1084 = _S906.smooth_n * make_float3 (_S1083);
                    float _S1085 = dot_0(_S1084, throughput_8);
                    float _S1086 = _S905.material.roughness;
                    float _S1087 = _S1086 * _S1086;
                    AnisotropicFrame _S1088 = anisotropicFrame(_S905.material, _S1084);
                    float3  _S1089 = negate_0(_S1082);
                    SheenProfile _S1090 = sheenProfile(_S1089, _S1084, _S905.material);
                    float3  _S1091 = reflectedHalf(_S1082, throughput_8);
                    bool _S1092 = b_6 == 1U;
                    if(_S1092)
                    {
                        float3  _S1093 = refractedHalf(_S1082, throughput_8, _S906.smooth_n, _S908.x, _S908.y);
                        throughput_9 = _S1093;
                    }
                    else
                    {
                        throughput_9 = _S1091;
                    }
                    bool _S1094 = b_6 == 0U;
                    if(_S1094)
                    {
                        float3  _S1095 = sampledHalf(_S1082, _S906.smooth_n, _S905.material, surface_12.random_state, _S1088);
                        throughput_10 = _S1095;
                    }
                    else
                    {
                        throughput_10 = throughput_9;
                    }
                    float3  _S1096 = negate_0(_S1082);
                    float _S1097 = _S908.x;
                    float _S1098 = _S908.y;
                    BSDFLobes _S1099 = bsdfLobes(_S1082, _S1096, _S1084, throughput_10, _S905.material, _S1097, _S1098, _S1088, _S1090);
                    BSDFLobes lobe_terms_1 = _S1099;
                    float _S1100 = translucentShare(_S905.material);
                    (&lobe_terms_1)->translucent_share = _S1100;
                    switch(b_6)
                    {
                    case 0U:
                        {
                            float _S1101 = diffusePDF(_S1085, 0.0f, (F32_abs((_S907))), _S1087, lobe_terms_1, _S1097, _S1098);
                            float3  _S1102 = diffuseBSDF(throughput_8, _S1084, _S1087, _S905.material, lobe_terms_1);
                            density_6 = _S1101;
                            chain_throughput_1 = _S1102;
                            break;
                        }
                    case 1U:
                        {
                            float _S1103 = refractPDF(_S1085, dot_0(throughput_8, throughput_10), (F32_abs((_S907))), _S1087, lobe_terms_1, _S1097, _S1098);
                            float3  _S1104 = refractBSDF(throughput_8, _S1084, _S1087, _S905.material, lobe_terms_1);
                            density_6 = _S1103;
                            chain_throughput_1 = _S1104;
                            break;
                        }
                    case 4U:
                        {
                            float _S1105 = sheenVelvetPDF(_S1085, 0.0f, (F32_abs((_S907))), _S1087, lobe_terms_1, _S1097, _S1098);
                            float3  _S1106 = sheenVelvetBSDF(throughput_8, _S1084, _S1087, _S905.material, lobe_terms_1);
                            density_6 = _S1105;
                            chain_throughput_1 = _S1106;
                            break;
                        }
                    default:
                        {
                            float _S1107 = reflectPDF(_S1085, 0.0f, (F32_abs((_S907))), _S1087, lobe_terms_1, _S1097, _S1098);
                            float3  _S1108 = reflectBSDF(throughput_8, _S1084, _S1087, _S905.material, lobe_terms_1);
                            density_6 = _S1107;
                            chain_throughput_1 = _S1108;
                            break;
                        }
                    }
                    bool _S1109 = density_6 > 0.0f;
                    if(_S1109)
                    {
                        SampleBSDF _S1110 = SampleBSDF_x24init_0(throughput_8, chain_throughput_1, surface_12.random_state, _S1092, b_6, density_6);
                        lobe_5 = _S1110;
                    }
                }
            }
            bool _S1111 = b_6 == 0U;
            if(_S1111)
            {
                _S989 = true;
            }
            else
            {
                _S989 = b_6 == 4U;
            }
            if(_S915)
            {
                _S1031 = false;
            }
            else
            {
                bool _S1112 = !_S989;
                if(_S1112)
                {
                    bool _S1113 = (_S905.material.roughness) == 0.0f;
                    if(_S1113)
                    {
                        _S1031 = true;
                    }
                    else
                    {
                        bool _S1114 = b_6 == 1U;
                        if(_S1114)
                        {
                            _S1031 = (_S908.x) == (_S908.y);
                        }
                        else
                        {
                            _S1031 = false;
                        }
                    }
                }
                else
                {
                    _S1031 = false;
                }
            }
            bool _S1115 = !_S915;
            if(_S1115)
            {
                _S1032 = b_6 == 1U;
            }
            else
            {
                _S1032 = false;
            }
            if(_S1032)
            {
                straight_0 = (_S905.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1033 = _S1115;
            }
            else
            {
                _S1033 = false;
            }
            if(_S1033)
            {
                _S1034 = b_6 == 1U;
            }
            else
            {
                _S1034 = false;
            }
            if(_S1034)
            {
                _S1035 = (_S908.x) == (_S908.y);
            }
            else
            {
                _S1035 = false;
            }
            BSDFMaterial _S1116 = _S905.material;
            bool _S1117 = isTranslucent_0(&_S1116);
            if(_S1117)
            {
                _S1036 = _S1111;
            }
            else
            {
                _S1036 = false;
            }
            if(_S1036)
            {
                _S1037 = (dot_0(throughput_8, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1037 = false;
            }
            if(nee_0)
            {
                _S1038 = !_S1031;
            }
            else
            {
                _S1038 = false;
            }
            if(_S1038)
            {
                _S1039 = !wrong_side_0;
            }
            else
            {
                _S1039 = false;
            }
            if(_S1039)
            {
                float _S1118 = (&lobe_5)->pdf;
                float3  _S1119 = (&ray_2)->origin;
                float3  _S1120 = _slang_select(_S920, _S729,_S906.smooth_n);
                float3  _S1121 = (&ray_2)->origin;
                FKSurface _S1122 = surface_12;
                float3  _S1123 = - _S906.smooth_n;
                float3  _S1124 = _slang_select(_S1037, _S1123,_S906.smooth_n);
                NEEVertex _S1125 = NEEVertex_x24init_0(false, _S1118, _S1119, _S1120, _S1121 + make_float3 (_S1122.geometry_offset) * _S1124);
                nee_vertex_0 = _S1125;
            }
            else
            {
                if(_S915)
                {
                    _S1040 = true;
                }
                else
                {
                    bool _S1126 = b_6 != 1U;
                    if(_S1126)
                    {
                        _S1040 = true;
                    }
                    else
                    {
                        _S1040 = (_S908.x) != (_S908.y);
                    }
                }
                if(_S1040)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1127 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1127)
            {
                if(_S989)
                {
                    _S1040 = true;
                }
                else
                {
                    _S1040 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_1)->distance * (&hit_1)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1040 = false;
            }
            bool _S1128 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1128)
            {
                if(_S989)
                {
                    _S1041 = true;
                }
                else
                {
                    _S1041 = (_S905.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1041 = false;
            }
            if(_S948)
            {
                bool _S1129 = !_S1040;
                if(_S1129)
                {
                    return _S730;
                }
                bool _S1130 = _S735 != 1U;
                if(_S1130)
                {
                    _S1042 = _S735 != 2U;
                }
                else
                {
                    _S1042 = false;
                }
                if(_S1042)
                {
                    float _S1131 = (&lobe_5)->pdf;
                    float _S1132 = _slang_select(nee_0, _S1131,0.0f);
                    float _S1133 = escapeWeight_0(_S1132, _S1050);
                    if(_S956)
                    {
                        passes_0 = _S741;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1134 = _slang_select(passes_0, _S1133,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_1->radiance * make_float3 (_S1134) / make_float3 (r_1->jac), density_4 * (&lobe_5)->pdf / r_1->jac);
                }
                float3  _S1135 = throughput_6 * make_float3 ((&lobe_5)->pdf);
                float _S1136 = density_4 * (&lobe_5)->pdf;
                throughput_9 = _S1135;
                density_6 = _S1136;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1137 = (fcptLayers((hit_1)));
            bool _S1138 = _S1137 > 1U;
            if(_S1138)
            {
                _S1042 = (b_6 == 1U) != passes_0;
            }
            else
            {
                _S1042 = false;
            }
            if(viewed_1)
            {
                _S1043 = _S1042;
            }
            else
            {
                _S1043 = false;
            }
            if(_S1043)
            {
                return _S730;
            }
            if(replay_0)
            {
                _S1044 = b_3 <= _S745;
            }
            else
            {
                _S1044 = false;
            }
            if(_S1044)
            {
                _S1045 = _S904;
            }
            else
            {
                _S1045 = false;
            }
            if(_S1045)
            {
                _S1046 = _S1040;
            }
            else
            {
                _S1046 = false;
            }
            bool _S1139;
            if(_S1046)
            {
                _S1139 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1139 = !_S1041;
                }
                else
                {
                    _S1139 = false;
                }
            }
            if(_S1139)
            {
                return _S730;
            }
            if(viewed_1)
            {
                float3  _S1140 = throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1141 = (&lobe_5)->pdf;
                throughput_10 = _S1140;
                sky_pdf_2 = _S1141;
            }
            else
            {
                float3  _S1142 = throughput_9 * max_0((&lobe_5)->throughput, _S729);
                throughput_10 = _S1142;
                sky_pdf_2 = density_6;
            }
            bool _S1143;
            if(_S925)
            {
                _S1143 = !_S939;
            }
            else
            {
                _S1143 = false;
            }
            bool _S1144;
            if(_S1143)
            {
                _S1144 = _S904;
            }
            else
            {
                _S1144 = false;
            }
            bool _S1145;
            if(_S1144)
            {
                _S1145 = _S1040;
            }
            else
            {
                _S1145 = false;
            }
            if(_S1145)
            {
                chain_0 = here_0;
                uint _S1146 = insertBits_0((&chain_0)->path, b_6, 18U, 3U);
                uint _S1147 = _slang_select(nee_0, 1U,0U);
                uint _S1148 = insertBits_0(_S1146, _S1147, 21U, 1U);
                (&chain_0)->path = _S1148;
                float _S1149 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1149;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1150 = surface_12;
            Vertex _S1151 = Vertex_x24init_0(_S1041, b_6, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1151;
            float _S1152 = (&lobe_5)->pdf;
            bool _S1153 = b_6 == 1U;
            bool _S1154;
            if(_S1153)
            {
                _S1154 = (_S908.x) == (_S908.y);
            }
            else
            {
                _S1154 = false;
            }
            float sky_pdf_3 = _slang_select(_S1154, sky_pdf_0,_S1152);
            float _S1155 = _slang_select(_S915, 0.0f,sky_pdf_3);
            float _S1156 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1157 = !_S1031;
            float _S1158 = _slang_select(_S1157, _S1156,0.0f);
            float _S1159 = spread_0 + _S1158;
            bool _S1160;
            if(refracted_4)
            {
                _S1160 = !_S1037;
            }
            else
            {
                _S1160 = false;
            }
            bool is_inside_7;
            if(_S1160)
            {
                bool _S1161 = !is_inside_6;
                is_inside_7 = _S1161;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1162 = surface_12;
            bool _S1163 = boundsVolume_0(&_S1162);
            bool _S1164;
            if(_S1163)
            {
                _S1164 = !_S1042;
            }
            else
            {
                _S1164 = false;
            }
            if(_S1164)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1165 = - _S1150.geometry_n;
                float3  _S1166 = _slang_select(turned_1, _S1165,_S1150.geometry_n);
                (&faced_2)->geometry_n = _S1166;
                FKMedium _S1167 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1168 = (fcptOutsideMedium((hit_1)));
                FKSurface _S1169 = faced_2;
                FKMedium _S1170 = _S1167;
                FKMedium _S1171 = _S1168;
                MediumSides _S1172 = mediumSides_0(&_S1169, &_S1170, filling_2, (&ray_2)->unit_direction, &_S1171);
                bool _S1173 = ((dot_0(throughput_8, _S1150.geometry_n)) > 0.0f) == ((dot_0(_S1150.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1174 = _slang_select(_S1173, _S1172.front.scatter,_S1172.behind.scatter);
                scatter_in_0 = _S1174;
                float3  _S1175 = _slang_select(_S1173, _S1172.front.extinction,_S1172.behind.extinction);
                extinction_in_0 = _S1175;
                float _S1176 = _slang_select(_S1173, _S1172.front.g,_S1172.behind.g);
                g_in_0 = _S1176;
                uint _S1177 = _S1172.fillings.x;
                uint _S1178 = _S1172.fillings.y;
                uint _S1179 = _slang_select(_S1173, _S1178,_S1177);
                bool _S1180 = (fcptVaryingUsed());
                uint _S1181 = _slang_select(_S1180, _S1179,4294967295U);
                filling_2 = _S1181;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1182 = !_S1042;
            if(_S1182)
            {
                FKSurface _S1183 = surface_12;
                float _S1184 = _slang_select(straight_0, 0.0f,_S1183.geometry_offset);
                float3  _S1185 = - _S906.smooth_n;
                bool _S1186 = is_inside_7 != _S1037;
                float3  _S1187 = _slang_select(_S1186, _S1185,_S906.smooth_n);
                float3  _S1188 = (&ray_2)->origin + make_float3 (_S1184) * _S1187;
                (&ray_2)->origin = _S1188;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1042;
            viewed_1 = _S1035;
            sky_pdf_2 = _S1155;
            spread_3 = _S1159;
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
        if(_S925)
        {
            if(_S871)
            {
                float3  _S1189 = throughput_9 * emission_1;
                Reservoir candidate_7 = chain_0;
                uint _S1190 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1191 = _S1190 == 1U;
                if(_S1191)
                {
                    float3  _S1192 = safeDivide(_S1189, chain_throughput_0);
                    (&candidate_7)->radiance = _S1192;
                }
                Reservoir _S1193 = withEnd(candidate_7, 2U, b_3, _S1189);
                offer(sel_1, _S1193, _S1189 * make_float3 (scale_1) / make_float3 (density_6));
            }
            if(_S871)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1194 = survivalProbability(throughput_9, density_6);
                density_7 = _S1194;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1195 = stream(_S757, b_3 + 128U);
            Random _S1196 = pcg(_S1195);
            bool _S1197 = density_7 < (_S1196.value);
            if(_S1197)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1198 = (fcptMaxBounces());
                wrong_side_0 = b_3 >= _S1198;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1199 = density_6 * density_7;
            density_7 = _S1199;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1200 = layer_0 ^ 1U;
        uint _S1201 = _slang_select(passes_0, _S1200,0U);
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
            uint _S1202 = b_6 + 1U;
            b_3 = _S1202;
            layer_0 = _S1201;
            continue;
        }
        FKRay _S1203 = ray_2;
        float _S1204 = distance_3(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_0)
        {
            refracted_4 = _S949;
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
        float _S1205 = _slang_select(wrong_side_0, _S1204,4.294967296e+09f);
        bool _S1206 = !_S915;
        if(straight_0)
        {
            _S988 = true;
        }
        else
        {
            _S988 = _S915;
        }
        FKHit _S1207;
        if(_S988)
        {
            _S1207 = hit_1;
        }
        else
        {
            _S1207 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
        }
        FKHit _S1208 = (fcptTraverseInstanceBVH((_S1203), (_S878), (_S1205), (_S1206), (_S1207), (viewed_1)));
        hit_1 = _S1208;
        if(replay_0)
        {
            _S989 = _S949;
        }
        else
        {
            _S989 = false;
        }
        if(_S989)
        {
            _S1031 = _S734 == 1U;
        }
        else
        {
            _S1031 = false;
        }
        if(_S1031)
        {
            _S1032 = ((&hit_1)->instance_index) == (_S746.instance_index);
        }
        else
        {
            _S1032 = false;
        }
        if(_S1032)
        {
            _S1033 = ((&hit_1)->triangle_index) == (_S746.triangle_index);
        }
        else
        {
            _S1033 = false;
        }
        if(_S1033)
        {
            (&hit_1)->uv = _S746.uv;
            float _S1209 = distance_3(reconnection_0, (&ray_2)->origin);
            (&hit_1)->distance = _S1209;
        }
        if(replay_0)
        {
            _S1034 = _S949;
        }
        else
        {
            _S1034 = false;
        }
        if(_S1034)
        {
            _S1035 = _S734 == 3U;
        }
        else
        {
            _S1035 = false;
        }
        if(_S1035)
        {
            _S1036 = ((&hit_1)->instance_index) != 4294967295U;
        }
        else
        {
            _S1036 = false;
        }
        if(_S1036)
        {
            return _S730;
        }
        Reservoir _S1210 = chain_0;
        uint _S1211 = filling_2;
        for(;;)
        {
            bool _S1212 = (fcptVaryingUsed());
            if(_S1212)
            {
                _S1037 = _S1211 != 4294967295U;
            }
            else
            {
                _S1037 = false;
            }
            float _S1213;
            if(_S1037)
            {
                float _S1214 = (fcptMajorant((_S1211)));
                _S1213 = _S1214;
            }
            else
            {
                _S1213 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_0)
            {
                _S1038 = _S949;
            }
            else
            {
                _S1038 = false;
            }
            if(_S1038)
            {
                _S1039 = _S734 == 1U;
            }
            else
            {
                _S1039 = false;
            }
            if(_S1039)
            {
                _S1040 = _S1213 > 0.0f;
            }
            else
            {
                _S1040 = false;
            }
            if(_S1040)
            {
                ended_0 = _S730;
                sky_pdf_1 = sky_pdf_2;
                spread_1 = spread_3;
                width_3 = width_2;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_6 = b_3;
                _S1041 = true;
                break;
            }
            bool _S1215 = (&prev_0)->rough;
            if(_S1215)
            {
                _S1041 = !(_S1213 > 0.0f);
            }
            else
            {
                _S1041 = false;
            }
            (&prev_0)->rough = _S1041;
            uint _S1216 = b_3 + 320U;
            bool _S1217 = b_3 == 4294967295U;
            uint _S1218 = _slang_select(_S1217, 384U,_S1216);
            uint _S1219 = stream(_S757, _S1218);
            uint tracking_1 = _S1219;
            weight_1 = throughput_3;
            glowed_0 = _S729;
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
                    _S728 = int(2);
                    break;
                }
                uint _S1220 = b_6 + 320U;
                bool _S1221 = b_6 == 4294967295U;
                uint _S1222 = _slang_select(_S1221, 384U,_S1220);
                uint _S1223 = stream(_S757, _S1222);
                Random _S1224 = pcg(_S1223);
                float _S1225 = - (F32_log((1.0f - _S1224.value))) / _S1213;
                if(_S1037)
                {
                    float3  _S1226 = (&ray_2)->origin;
                    float3  _S1227 = (&ray_2)->unit_direction;
                    float _S1228 = (&hit_1)->distance;
                    uint _S1229 = _slang_select(_S1221, 0U,b_6);
                    uint _S1230 = (&prev_0)->lobe;
                    uint _S1231 = _slang_select(_S1221, 3U,_S1230);
                    float _S1232 = (fcptTrackMedium((_S1211), (_S1226), (_S1227), (_S1228), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1229), (_S1231), (_S1221)));
                    spread_2 = _S1232;
                }
                else
                {
                    spread_2 = _S1225;
                }
                bool _S1233 = !(spread_2 < ((&hit_1)->distance));
                if(_S1233)
                {
                    _S728 = int(2);
                    break;
                }
                if(_S1037)
                {
                    _S1042 = _S925;
                }
                else
                {
                    _S1042 = false;
                }
                if(_S1042)
                {
                    float3  _S1234 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1235 = sel_1->glow + _S1234;
                    sel_1->glow = _S1235;
                }
                else
                {
                }
                glowed_0 = _S729;
                uint b_7 = b_6 + 1U;
                float3  _S1236 = (&ray_2)->origin + make_float3 (spread_2) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1236;
                float3  _S1237 = flightWeight_0(scatter_in_0, extinction_in_0, _S1213, spread_2, true);
                float3  _S1238 = weight_1;
                float3  _S1239 = _slang_select(_S1037, _S1238,_S1237);
                float3  throughput_11 = throughput_10 * _S1239;
                uint _S1240 = stream(_S757, b_7 + 320U);
                tracking_1 = _S1240;
                weight_1 = throughput_3;
                float width_6 = width_3 + spread_1 * spread_2;
                float _S1241 = spread_1 + 3.14159274101257324f;
                if(_S925)
                {
                    _S1043 = true;
                }
                else
                {
                    bool _S1242 = b_7 == _S745;
                    if(_S1242)
                    {
                        _S1043 = !_S1037;
                    }
                    else
                    {
                        _S1043 = false;
                    }
                }
                TreeSample light_4;
                if(_S1043)
                {
                    float3  _S1243 = (&ray_2)->origin;
                    float3  _S1244 = (&ray_2)->unit_direction;
                    float3  _S1245 = (&ray_2)->unit_direction;
                    uint _S1246 = stream(_S757, b_7 + 64U);
                    float3  _S1247 = extinction_in_0;
                    float3  _S1248 = extinction_in_0;
                    uint2  _S1249 = make_uint2 (_S1211);
                    float3  _S1250 = (&ray_2)->unit_direction;
                    uint _S1251 = arrivalLobe_0(b_7, (&prev_0)->lobe);
                    FKHit _S1252 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                    FKHit _S1253 = _S1252;
                    ShadowContext _S1254 = ShadowContext_x24init_0(_S1247, _S1248, _S1249, _S1250, b_7, _S1251, false, spread_2, width_6, &_S1253, false);
                    ShadowContext _S1255 = _S1254;
                    TreeSample _S1256 = sampleLightTree_0(_S1243, _S1244, _S1245, 0.0f, true, _S1246, &_S1255);
                    light_4 = _S1256;
                }
                else
                {
                    light_4 = _S963;
                }
                float _S1257 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1258 = (fcptMaxBounces());
                bool _S1259 = b_7 < _S1258;
                if(_S1259)
                {
                    _S1044 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1044 = false;
                }
                float _S1260 = _slang_select(_S1044, _S1257,0.0f);
                float3  _S1261 = throughput_11 * light_4.radiance;
                float _S1262 = powerHeuristic(light_4.density, _S1260);
                float3  _S1263 = _S1261 * make_float3 (_S1257 * _S1262);
                float3  _S1264 = _slang_select(_S1043, _S1263,_S729);
                if(replay_0)
                {
                    _S1045 = b_7 == _S745;
                }
                else
                {
                    _S1045 = false;
                }
                if(_S1045)
                {
                    bool _S1265 = _S734 == 2U;
                    if(_S1265)
                    {
                        float _S1266 = rgb_to_greyscale(_S1264);
                        _S1046 = _S1266 > 0.0f;
                    }
                    else
                    {
                        _S1046 = false;
                    }
                    if(_S1046)
                    {
                        Shift _S1267 = Shift_x24init_0(_S1264, 1.0f);
                        _S728 = int(1);
                        ended_0 = _S1267;
                        spread_2 = _S1241;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_4 = b_7;
                        break;
                    }
                    _S728 = int(1);
                    ended_0 = _S730;
                    spread_2 = _S1241;
                    width_4 = width_6;
                    throughput_8 = throughput_11;
                    b_4 = b_7;
                    break;
                }
                if(_S925)
                {
                    Reservoir candidate_8 = _S1210;
                    uint _S1268 = extractBits_0(_S1210.path, 10U, 2U);
                    bool _S1269 = _S1268 == 1U;
                    if(_S1269)
                    {
                        float3  _S1270 = safeDivide(_S1264, chain_throughput_0);
                        (&candidate_8)->radiance = _S1270;
                    }
                    else
                    {
                        uint _S1271 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                        uint _S1272 = insertBits_0(_S1271, 2U, 10U, 2U);
                        (&candidate_8)->path = _S1272;
                    }
                    Reservoir _S1273 = withEnd(candidate_8, 0U, b_7, _S1264);
                    offer(sel_1, _S1273, _S1264 * make_float3 (scale_1) / make_float3 (density_3));
                    float _S1274 = survivalProbability(throughput_11, density_3);
                    uint _S1275 = stream(_S757, b_7 + 128U);
                    Random _S1276 = pcg(_S1275);
                    bool _S1277 = _S1274 < (_S1276.value);
                    if(_S1277)
                    {
                        _S1046 = true;
                    }
                    else
                    {
                        uint _S1278 = (fcptMaxBounces());
                        _S1046 = b_7 >= _S1278;
                    }
                    if(_S1046)
                    {
                        _S728 = int(1);
                        ended_0 = _S730;
                        spread_2 = _S1241;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_4 = b_7;
                        break;
                    }
                    float _S1279 = density_3 * _S1274;
                    density_3 = _S1279;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1280 = stream(_S757, b_7);
                float3  _S1281 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1280, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1281;
                NEEVertex _S1282 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S729, (&ray_2)->origin);
                nee_vertex_0 = _S1282;
                Vertex _S1283 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
                prev_0 = _S1283;
                float _S1284 = (&prev_0)->pdf;
                FKRay _S1285 = ray_2;
                FKHit _S1286 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1287 = (fcptTraverseInstanceBVH((_S1285), (true), (4.294967296e+09f), (false), (_S1286), (false)));
                hit_1 = _S1287;
                b_6 = b_7;
                throughput_10 = throughput_11;
                spread_1 = _S1241;
                width_3 = width_6;
                sky_pdf_1 = _S1284;
            }
            if(_S728 != int(2))
            {
                spread_1 = spread_2;
                width_3 = width_4;
                throughput_10 = throughput_8;
                b_6 = b_4;
                _S1041 = true;
                break;
            }
            ended_0 = _S730;
            _S1041 = false;
            break;
        }
        if(_S1041)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1042 = b_6 == b_3;
        }
        else
        {
            _S1042 = false;
        }
        bool _S1288 = ((&hit_1)->instance_index) == 4294967295U;
        if(_S1288)
        {
            bool _S1289 = !(&nee_vertex_0)->none;
            float _S1290 = _slang_select(_S1289, sky_pdf_1,0.0f);
            float _S1291 = escapeWeight_0(_S1290, (&ray_2)->unit_direction);
            float3  _S1292 = environment_0((&ray_2)->unit_direction, b_6, (&prev_0)->lobe);
            float3  _S1293 = throughput_10 * _S1292;
            if(replay_0)
            {
                bool _S1294 = b_6 == _S745;
                if(_S1294)
                {
                    passes_0 = _S734 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1293 * make_float3 (_S1291) / make_float3 (r_1->jac), density_3 / r_1->jac);
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
                    passes_0 = b_6 == _S732;
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
                    return Shift_x24init_0(_S1293 * make_float3 (_S1291), 1.0f);
                }
                return _S730;
            }
            Reservoir candidate_9 = chain_0;
            uint _S1295 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1296 = _S1295 == 1U;
            if(_S1296)
            {
                uint _S1297 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1298 = _S1297 == b_6;
                float _S1299 = _slang_select(_S1298, 1.0f,_S1291);
                float3  _S1300 = safeDivide(_S1293 * make_float3 (_S1299), chain_throughput_0);
                (&candidate_9)->radiance = _S1300;
            }
            else
            {
                bool _S1301 = (&prev_0)->rough;
                if(_S1301)
                {
                    uint _S1302 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                    uint _S1303 = insertBits_0(_S1302, 3U, 10U, 2U);
                    uint _S1304 = insertBits_0(_S1303, (&prev_0)->lobe, 15U, 3U);
                    bool _S1305 = (&prev_0)->inside;
                    uint _S1306 = _slang_select(_S1305, 1U,0U);
                    uint _S1307 = insertBits_0(_S1304, _S1306, 22U, 1U);
                    (&candidate_9)->path = _S1307;
                    (&candidate_9)->jac = (&prev_0)->pdf;
                    (&candidate_9)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1308 = _S1293 * make_float3 (_S1291);
            Reservoir _S1309 = withEnd(candidate_9, 3U, b_6, _S1308);
            offer(sel_1, _S1309, _S1308 * make_float3 (scale_1) / make_float3 (density_3));
            break;
        }
        float3  _S1310 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1310;
        bool _S1311 = (fcptVaryingUsed());
        if(_S1311)
        {
            _S1043 = filling_2 != 4294967295U;
        }
        else
        {
            _S1043 = false;
        }
        if(_S1043)
        {
            if(_S925)
            {
                float3  _S1312 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1313 = sel_1->glow + _S1312;
                sel_1->glow = _S1313;
            }
            float3  _S1314 = throughput_10 * weight_1;
            throughput_8 = _S1314;
        }
        else
        {
            float3  _S1315 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
            float3  _S1316 = throughput_10 * _S1315;
            throughput_8 = _S1316;
        }
        float _S1317 = width_3 + spread_1 * (&hit_1)->distance;
        viewed_0 = _S1042;
        width_2 = _S1317;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_0 = spread_1;
        uint _S1202 = b_6 + 1U;
        b_3 = _S1202;
        layer_0 = _S1201;
    }
    return _S730;
}

__device__ static const FixedArray<float, 4>  HAIR_TILTS_0 = { {
    -2.0f, 1.0f, 4.0f, 0.0f
} };
__device__ static const FixedArray<float, 4>  HAIR_WIDTHS_0 = { {
    1.0f, 0.5f, 2.0f, 2.0f
} };
static __device__ float3  clamp_1(float3  x_17, float3  minBound_1, float3  maxBound_1)
{
    return min_1(max_0(x_17, minBound_1), maxBound_1);
}

static __device__ float3  tan_0(float3  x_18)
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
        *_slang_vector_get_element_ptr(&result_9, i_19) = (F32_tan((_slang_vector_get_element(x_18, i_19))));
        i_19 = i_19 + int(1);
    }
    return result_9;
}

static __device__ float3  acos_0(float3  x_19)
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
        *_slang_vector_get_element_ptr(&result_10, i_20) = (F32_acos((_slang_vector_get_element(x_19, i_20))));
        i_20 = i_20 + int(1);
    }
    return result_10;
}

static __device__ float3  abs_0(float3  x_20)
{
    float3  result_11;
    int i_21 = int(0);
    for(;;)
    {
        if(i_21 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_11, i_21) = (F32_abs((_slang_vector_get_element(x_20, i_21))));
        i_21 = i_21 + int(1);
    }
    return result_11;
}

__device__ Random normal_distribution(uint state_3)
{
    Random _S1318 = pcg(state_3);
    Random _S1319 = pcg(_S1318.state);
    float _S1320 = 6.28318548202514648f * _S1318.value;
    float _S1321 = (F32_sqrt((-2.0f * clamp_0((F32_log((_S1319.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1319.state, _S1321 * (F32_cos((_S1320))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1322;
    (&_S1322)->state = state_4;
    (&_S1322)->value = value_2;
    return _S1322;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1323 = normal_distribution(state_5);
    Random _S1324 = normal_distribution(_S1323.state);
    Random _S1325 = normal_distribution(_S1324.state);
    float3  _S1326 = make_float3 (_S1323.value, _S1324.value, _S1325.value);
    float3  _S1327 = ((((_S1326)) * make_float3(rnorm3df(((_S1326)).x, ((_S1326)).y, ((_S1326)).z))));
    return RandomSphere_x24init_0(_S1325.state, _S1327);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_13)
{
    float3  _S1328 = p1_0 - p0_0;
    float3  _S1329 = p2_0 - p0_0;
    float2  _S1330 = uv1_0 - uv0_0;
    float2  _S1331 = uv2_0 - uv0_0;
    float _S1332 = _S1330.x;
    float _S1333 = _S1331.y;
    float _S1334 = _S1330.y;
    float _S1335 = _S1331.x;
    float _S1336 = _S1332 * _S1333 - _S1334 * _S1335;
    float _S1337 = 1.0f / _S1336;
    float3  t_1 = (_S1328 * make_float3 (_S1333) - _S1329 * make_float3 (_S1334)) * make_float3 (_S1337);
    float3  _S1338 = (_S1329 * make_float3 (_S1332) - _S1328 * make_float3 (_S1335)) * make_float3 (_S1337);
    float3  _S1339 = t_1 - n_13 * make_float3 (dot_0(n_13, t_1));
    float3  _S1340 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_13);
    bool _S1341 = (dot_0(_S1339, _S1339)) > 0.0f;
    float3  _S1342 = _slang_select(_S1341, _S1339,_S1340);
    float3  _S1343 = ((((_S1342)) * make_float3(rnorm3df(((_S1342)).x, ((_S1342)).y, ((_S1342)).z))));
    bool _S1344 = (dot_0(cross_0(n_13, _S1343), _S1338)) > 0.0f;
    float3  t_2;
    if(_S1344)
    {
        float3  _S1345 = negate_0(_S1343);
        t_2 = _S1345;
    }
    else
    {
        t_2 = _S1343;
    }
    float3  _S1346 = cross_0(n_13, t_2);
    return makeMatrix<float, 3, 3> (t_2, _S1346, n_13);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_0)
{
    float3  _S1347 = t1_0 - t0_0;
    float3  _S1348 = t2_2 - t0_0;
    float3  _S1349 = t2_2 - t1_0;
    float _S1350 = (F32_min((length_0(_S1347)), ((F32_min((length_0(_S1348)), (length_0(_S1349)))))));
    float3  _S1351 = make_float3 (distance_3(position_0, t0_0), distance_3(position_0, t1_0), distance_3(position_0, t2_2));
    float3  _S1352 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1353 = dot_0(geometry_n_4, _S1352);
    float3  _S1354 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1355 = dot_0(geometry_n_4, _S1354);
    float3  _S1356 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1357 = acos_0(abs_0(make_float3 (_S1353, _S1355, dot_0(geometry_n_4, _S1356))));
    float3  _S1358 = clamp_1(tan_0(_S1357), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_0(dot_0(_S1351 * _S1358, uvw_0), 0.0f, _S1350 * 0.125f);
}

__device__ float3  straightThrough(BSDFMaterial material_21)
{
    return make_float3 (material_21.transmission * (1.0f - material_21.metallic)) * material_21.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_3, float3  out_dir_3, uint p_5, float w_2, float alpha_17, uint nt_0)
{
    uint _S1359 = p_5 % 4U;
    float _S1360 = w_2 * HAIR_WIDTHS_0[_S1359];
    float _S1361 = (F32_asin((clamp_0(dot_0(out_dir_3, t_3), -1.0f, 1.0f)))) - (F32_asin((clamp_0(dot_0(in_dir_11, t_3), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1359] * alpha_17;
    return ((F32_asinh((_S1361 / _S1360))) / (F32_asinh((3.14159274101257324f / _S1360))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_4, float3  out_dir_4, uint np_0)
{
    float3  _S1362 = worldToTangent(out_dir_4, t_4);
    float3  _S1363 = worldToTangent(in_dir_12, t_4);
    return (F32_frac((((F32_atan2((_S1362.z), (_S1362.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1363.z), (1.17549435082228751e-38f - _S1363.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_5, uint p_6, float row_0, float column_0, float w_3, float alpha_18, uint nt_1, uint np_1)
{
    float3  _S1364 = worldToTangent(in_dir_13, t_5);
    uint _S1365 = p_6 % 4U;
    float _S1366 = w_3 * HAIR_WIDTHS_0[_S1365];
    float _S1367 = (F32_asin((clamp_0(dot_0(in_dir_13, t_5), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1365] * alpha_18 + _S1366 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1366))))));
    float _S1368 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1364.z), (1.17549435082228751e-38f - _S1364.x)));
    float _S1369 = (F32_cos((_S1367)));
    float3  _S1370 = tangentToWorld(make_float3 (_S1369 * (F32_cos((_S1368))), (F32_sin((_S1367))), _S1369 * (F32_sin((_S1368)))), t_5);
    return _S1370;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_14, BSDFMaterial material_22, float coverage_1)
{
    float3  _S1371;
    if((material_22.ior) == 1.0f)
    {
        float3  _S1372 = straightThrough(material_22);
        _S1371 = _S1372;
    }
    else
    {
        _S1371 = make_float3 (0.0f);
    }
    return _S1371 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ void offerShifted(Selection * sel_2, Reservoir r_2, Shift shifted_0, float mis_0)
{
    Reservoir candidate_10 = r_2;
    float3  _S1373 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_10)->f = _S1373;
    float _S1374 = r_2.jac * shifted_0.jac;
    (&candidate_10)->jac = _S1374;
    offer(sel_2, candidate_10, make_float3 (mis_0) * shifted_0.f * make_float3 (r_2.w));
    return;
}

__device__ Reservoir finalize(Selection sel_3, float c_1)
{
    Reservoir r_3 = sel_3.r;
    float _S1375 = rgb_to_greyscale((&r_3)->f);
    float _S1376 = sel_3.w_sum / _S1375;
    bool _S1377 = _S1375 > 0.0f;
    float _S1378 = _slang_select(_S1377, _S1376,0.0f);
    (&r_3)->w = _S1378;
    (&r_3)->c = c_1;
    return r_3;
}

__device__ Shift walk_hook(Domain dom_1, Reservoir r_4, bool replay_1, float scale_2, Selection * sel_4)
{
    Domain _S1379 = dom_1;
    Reservoir _S1380 = r_4;
    Shift _S1381 = walk_0(&_S1379, &_S1380, replay_1, scale_2, sel_4);
    return _S1381;
}

#undef Matrix
