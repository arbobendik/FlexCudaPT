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

__device__ float3  safeDivide(float3  a_5, float3  b_2)
{
    float3  _S575 = a_5 / b_2;
    float3  _S576 = make_float3 (0.0f);
    bool3  _S577 = b_2 == _S576;
    float3  _S578 = _slang_select(_S577, _S576,_S575);
    return _S578;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S579 = (1U << count_2) - 1U;
    return (e_2 & (~(_S579 << offset_1))) | ((newbits_0 & _S579) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_0, uint end_type_0, uint end_0, float3  f_4)
{
    Reservoir candidate_0 = r_0;
    uint _S580 = insertBits_0(r_0.path, end_0, 0U, 5U);
    uint _S581 = insertBits_0(_S580, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S581;
    (&candidate_0)->f = f_4;
    return candidate_0;
}

__device__ void offer(Selection * sel_0, Reservoir candidate_1, float3  weight_0)
{
    float _S582 = rgb_to_greyscale(weight_0);
    bool _S583 = _S582 > 0.0f;
    bool _S584;
    if(_S583)
    {
        _S584 = _S582 < 3.00000000549775576e+38f;
    }
    else
    {
        _S584 = false;
    }
    bool _S585 = !_S584;
    if(_S585)
    {
        return;
    }
    bool _S586 = sel_0->sums;
    if(_S586)
    {
        float3  _S587 = sel_0->color + weight_0;
        sel_0->color = _S587;
        return;
    }
    float _S588 = sel_0->w_sum + _S582;
    sel_0->w_sum = _S588;
    float3  _S589 = sel_0->color + weight_0;
    sel_0->color = _S589;
    Random _S590 = pcg(sel_0->random_state);
    sel_0->random_state = _S590.state;
    bool _S591 = (_S590.value * sel_0->w_sum) <= _S582;
    if(_S591)
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
    Random _S592 = pcg(random_state_8);
    Random _S593 = pcg(_S592.state);
    float _S594 = 1.0f - 2.0f * _S592.value;
    float _S595 = (F32_sqrt(((F32_max((1.0f - _S594 * _S594), (0.0f))))));
    float _S596 = 6.28318548202514648f * _S593.value;
    return make_float3 (_S595 * (F32_cos((_S596))), _S595 * (F32_sin((_S596))), _S594);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_1, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2)
{
    BSDFMaterial _S597;
    (&_S597)->albedo = albedo_1;
    (&_S597)->emissive = emissive_1;
    (&_S597)->roughness = roughness_0;
    (&_S597)->metallic = metallic_0;
    (&_S597)->transmission = transmission_0;
    (&_S597)->ior = ior_0;
    (&_S597)->absorption = absorption_0;
    (&_S597)->specular_tint = specular_tint_0;
    (&_S597)->specular_level = specular_level_0;
    (&_S597)->translucent = translucent_0;
    (&_S597)->sheen = sheen_2;
    (&_S597)->sheen_roughness = sheen_roughness_0;
    (&_S597)->anisotropy = anisotropy_0;
    (&_S597)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S597)->tangent = tangent_2;
    return _S597;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1)
{
    FKMedium _S598;
    (&_S598)->scatter = scatter_1;
    (&_S598)->extinction = extinction_1;
    return _S598;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_10, bool skip_0, uint random_state_9, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S599;
    (&_S599)->smooth_n = smooth_n_4;
    (&_S599)->geometry_n = geometry_n_2;
    (&_S599)->geometry_offset = geometry_offset_2;
    (&_S599)->material = *material_10;
    (&_S599)->skip = skip_0;
    (&_S599)->random_state = random_state_9;
    (&_S599)->coverage = coverage_0;
    (&_S599)->encloses = encloses_0;
    (&_S599)->volume = *volume_0;
    (&_S599)->fills = fills_0;
    (&_S599)->hair = hair_0;
    return _S599;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S600 = (&surface_6->material)->emissive;
    float3  _S601 = make_float3 (0.0f);
    bool _S602 = !top_0;
    float3  _S603 = _slang_select(_S602, _S601,_S600);
    (&(&lower_0)->material)->emissive = _S603;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_1)
{
    float _S604 = surface_7->coverage;
    bool _S605 = u_1 < _S604;
    if(_S605)
    {
        return *surface_7;
    }
    float3  _S606 = make_float3 (0.0f);
    float3  _S607 = make_float3 (1.0f);
    BSDFMaterial _S608 = Material_x24init_0(_S606, _S606, 0.0f, 0.0f, 0.0f, 0.0f, _S606, _S607, 1.0f, _S606, _S606, 0.5f, 0.0f, 0.0f, _S606);
    BSDFMaterial material_11 = _S608;
    (&material_11)->albedo = _S607;
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
    bool _S609 = transmission_1 > 0.0f;
    bool _S610;
    if(_S609)
    {
        _S610 = true;
    }
    else
    {
        _S610 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S611 = _slang_select(_S610, 1.0f,-1.0f);
    return _S611;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_10)
{
    return (dot_0(dir_10, n_10)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_11)
{
    float3  _S612 = surface_8->geometry_n;
    float _S613 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_11);
    FKSurface faced_0 = *surface_8;
    float3  _S614 = surface_8->smooth_n * make_float3 (_S613);
    (&faced_0)->smooth_n = _S614;
    float3  _S615 = _S612 * make_float3 (_S613);
    (&faced_0)->geometry_n = _S615;
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
    float3  _S616 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_2) * log_0(_S616));
}

__device__ float2  vertexEta(BSDFMaterial material_12, float n_dot_v_0)
{
    bool _S617 = n_dot_v_0 < 0.0f;
    float _S618 = _slang_select(_S617, material_12.ior,1.0f);
    float _S619 = _slang_select(_S617, 1.0f,material_12.ior);
    return make_float2 (_S618, _S619);
}

__device__ bool neeDecision(BSDFMaterial material_13, float n_dot_v_1, float eta_i_8, float eta_o_8)
{
    float _S620 = fresnel((F32_abs((n_dot_v_1))), eta_i_8, eta_o_8);
    float3  _S621 = mix_0(make_float3 (_S620), material_13.albedo, material_13.metallic);
    float _S622 = rgb_to_greyscale(_S621);
    float _S623 = (F32_max(((1.0f - _S622) * (1.0f - material_13.metallic) * (1.0f - material_13.transmission)), (0.0f)));
    bool _S624 = _S623 > 0.03999999910593033f;
    bool _S625;
    if(_S624)
    {
        _S625 = true;
    }
    else
    {
        _S625 = (material_13.roughness) > 0.20000000298023224f;
    }
    return _S625;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_14)
{
    float _S626 = rgb_to_greyscale(material_14->translucent);
    return _S626 > 0.0f;
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
    MediumSides _S627;
    (&_S627)->behind = *behind_0;
    (&_S627)->front = *front_0;
    (&_S627)->fillings = fillings_1;
    (&_S627)->face = face_1;
    return _S627;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_12)
{
    float3  _S628 = surface_9->geometry_n;
    MediumSides _S629 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S629;
    bool _S630 = surface_9->encloses;
    if(_S630)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S631 = (dot_0(dir_12, _S628)) > 0.0f;
        if(_S631)
        {
            float3  _S632 = make_float3 (0.0f);
            FKMedium _S633 = Medium_x24init_0(_S632, _S632);
            (&sides_0)->front = _S633;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_3, float length_3, float width_1, FKHit * own_1, bool fiber_1)
{
    float3  _S634 = surface_10->geometry_n;
    ShadowContext _S635 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
    bool _S636 = surface_10->encloses;
    ShadowContext context_2;
    if(_S636)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S637 = - _S634;
        float3  _S638 = _slang_select(turned_0, _S637,_S634);
        (&faced_1)->geometry_n = _S638;
        FKMedium _S639 = Medium_x24init_0(make_float3 (0.0f), extinction_2);
        FKSurface _S640 = faced_1;
        FKMedium _S641 = _S639;
        MediumSides _S642 = mediumSides_0(&_S640, &_S641, filling_1, dir_13);
        ShadowContext _S643 = ShadowContext_x24init_0(_S642.behind.extinction, _S642.front.extinction, _S642.fillings, _S634, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
        if(turned_0)
        {
            uint2  _S644 = _S642.fillings;
            ShadowContext _S645 = ShadowContext_x24init_0(_S642.front.extinction, _S642.behind.extinction, uint2 {_S644.y, _S644.x}, _S634, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
            context_2 = _S645;
        }
        else
        {
            context_2 = _S643;
        }
    }
    else
    {
        context_2 = _S635;
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

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_3, BSDFMaterial * material_15, float eta_i_9, float eta_o_9, bool competing_1, uint random_state_10)
{
    float3  _S646 = light_2->dir;
    bool _S647 = (dot_0(geometry_n_3, - in_dir_8) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 4>  throughputs_1;
    FixedArray<float, 4>  pdfs_3;
    float3  _S648 = BSDF(in_dir_8, _S646, smooth_n_5, *material_15, eta_i_9, eta_o_9, _S647, random_state_10, &throughputs_1, &pdfs_3);
    bool _S649 = !competing_1;
    bool _S650;
    if(_S649)
    {
        _S650 = true;
    }
    else
    {
        _S650 = (light_2->density) == 0.0f;
    }
    if(_S650)
    {
        return _S648 * light_2->radiance;
    }
    float3  _S651 = make_float3 (0.0f);
    uint i_16 = 0U;
    float3  weighted_0 = _S651;
    for(;;)
    {
        if(i_16 < 4U)
        {
        }
        else
        {
            break;
        }
        bool _S652 = (pdfs_3[i_16]) > 0.0f;
        if(_S652)
        {
            float _S653 = light_2->density;
            float _S654 = pdfs_3[i_16] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_16] * make_float3 (pdfs_3[i_16]) / make_float3 (_S653 * (1.0f + _S654 * _S654));
            weighted_0 = weighted_1;
        }
        uint i_17 = i_16 + 1U;
        i_16 = i_17;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_11, bool refracted_3, uint lobe_4, float pdf_5)
{
    SampleBSDF _S655;
    (&_S655)->unit_direction = unit_direction_1;
    (&_S655)->throughput = throughput_1;
    (&_S655)->random_state = random_state_11;
    (&_S655)->refracted = refracted_3;
    (&_S655)->lobe = lobe_4;
    (&_S655)->pdf = pdf_5;
    return _S655;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_8, float n_i_dot_v_5, float alpha_13, BSDFMaterial material_16, BSDFLobes lobes_9, float eta_i_10, float eta_o_10, uint random_state_12)
{
    float3  _S656 = make_float3 (1.0f);
    SampleBSDF _S657 = SampleBSDF_x24init_0(_S656, _S656, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S657;
    Random _S658 = pcg(random_state_12);
    Random _S659 = pcg(_S658.state);
    (&sample_1)->random_state = _S659.state;
    float _S660 = _S658.value;
    float _S661 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S660 * _S660))))));
    float _S662 = 6.28318548202514648f * _S659.value;
    float3  _S663 = tangentToWorld(make_float3 (_S661 * (F32_cos((_S662))), _S658.value, _S661 * (F32_sin((_S662)))), n_i_8);
    (&sample_1)->unit_direction = _S663;
    (&sample_1)->lobe = 4U;
    float3  _S664 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_8, alpha_13, material_16, lobes_9);
    (&sample_1)->throughput = _S664;
    float _S665 = sheenVelvetPDF(_S658.value, 0.0f, n_i_dot_v_5, alpha_13, lobes_9, eta_i_10, eta_o_10);
    (&sample_1)->pdf = _S665;
    return sample_1;
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

__device__ __forceinline__ SampleBSDF diffuseSample(float u_2, float3  n_i_9, float n_i_dot_v_6, float alpha_14, BSDFMaterial material_17, BSDFLobes lobes_10, float eta_i_11, float eta_o_11, uint random_state_13)
{
    float3  _S671 = make_float3 (1.0f);
    SampleBSDF _S672 = SampleBSDF_x24init_0(_S671, _S671, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S672;
    Random _S673 = pcg(random_state_13);
    Random _S674 = pcg(_S673.state);
    (&sample_2)->random_state = _S674.state;
    float3  _S675 = sampleCosWeightedHemisphere(_S673.value, _S674.value);
    bool _S676 = u_2 < (lobes_10.p_diffuse * lobes_10.translucent_share);
    float _S677 = _S675.y;
    float _S678 = - _S677;
    float _S679 = _slang_select(_S676, _S678,_S677);
    float3  _S680 = tangentToWorld(make_float3 (_S675.x, _S679, _S675.z), n_i_9);
    (&sample_2)->unit_direction = _S680;
    (&sample_2)->refracted = _S676;
    (&sample_2)->lobe = 0U;
    float3  _S681 = diffuseBSDF((&sample_2)->unit_direction, n_i_9, alpha_14, material_17, lobes_10);
    (&sample_2)->throughput = _S681;
    float _S682 = diffusePDF(_S679, 0.0f, n_i_dot_v_6, alpha_14, lobes_10, eta_i_11, eta_o_11);
    (&sample_2)->pdf = _S682;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_10, float n_i_dot_v_7, float alpha_15, BSDFMaterial material_18, BSDFLobes lobes_11, float eta_i_12, float eta_o_12, uint random_state_14)
{
    float3  _S683 = make_float3 (1.0f);
    SampleBSDF _S684 = SampleBSDF_x24init_0(_S683, _S683, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S684;
    (&sample_3)->unit_direction = lobes_11.refracted;
    (&sample_3)->random_state = random_state_14;
    (&sample_3)->refracted = true;
    (&sample_3)->lobe = 1U;
    float3  _S685 = refractBSDF((&sample_3)->unit_direction, n_i_10, alpha_15, material_18, lobes_11);
    (&sample_3)->throughput = _S685;
    float _S686 = refractPDF(0.0f, dot_0((&sample_3)->unit_direction, ggx_n_3), n_i_dot_v_7, alpha_15, lobes_11, eta_i_12, eta_o_12);
    (&sample_3)->pdf = _S686;
    return sample_3;
}

static __device__ float3  reflect_0(float3  i_18, float3  n_11)
{
    return i_18 - make_float3 (2.0f * dot_0(n_11, i_18)) * n_11;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_11, float n_i_dot_v_8, float alpha_16, BSDFMaterial material_19, BSDFLobes lobes_12, float eta_i_13, float eta_o_13, uint random_state_15)
{
    float3  _S687 = make_float3 (1.0f);
    SampleBSDF _S688 = SampleBSDF_x24init_0(_S687, _S687, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S688;
    float3  _S689 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S690 = ((((_S689)) * make_float3(rnorm3df(((_S689)).x, ((_S689)).y, ((_S689)).z))));
    (&sample_4)->unit_direction = _S690;
    (&sample_4)->random_state = random_state_15;
    (&sample_4)->lobe = 2U;
    float3  _S691 = reflectBSDF((&sample_4)->unit_direction, n_i_11, alpha_16, material_19, lobes_12);
    (&sample_4)->throughput = _S691;
    float _S692 = reflectPDF(0.0f, 0.0f, n_i_dot_v_8, alpha_16, lobes_12, eta_i_13, eta_o_13);
    (&sample_4)->pdf = _S692;
    return sample_4;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_12, BSDFMaterial material_20, float eta_i_14, float eta_o_14, uint random_init_0, float2  screen_space_0)
{
    uint random_state_16 = random_init_0;
    float3  _S693 = negate_0(in_dir_10);
    float _S694 = dot_0(n_12, _S693);
    float _S695 = sign_0(_S694);
    float3  n_i_12 = n_12 * make_float3 (_S695);
    float _S696 = (F32_abs((_S694)));
    float _S697 = material_20.roughness;
    float _S698 = _S697 * _S697;
    AnisotropicFrame _S699 = anisotropicFrame(material_20, n_i_12);
    SheenProfile _S700 = sheenProfile(_S693, n_i_12, material_20);
    float3  _S701 = sampleHalfVector(_S693, n_i_12, _S698, _S699, &random_state_16);
    BSDFLobes _S702 = bsdfLobes(in_dir_10, _S693, n_i_12, _S701, material_20, eta_i_14, eta_o_14, _S699, _S700);
    BSDFLobes lobes_13 = _S702;
    float _S703 = translucentShare(material_20);
    (&lobes_13)->translucent_share = _S703;
    Random _S704 = pcg(random_state_16);
    random_state_16 = _S704.state;
    bool _S705 = (_S704.value) < ((&lobes_13)->p_sheen_velvet);
    if(_S705)
    {
        SampleBSDF _S706 = sheenVelvetSample(n_i_12, _S696, _S698, material_20, lobes_13, eta_i_14, eta_o_14, random_state_16);
        return _S706;
    }
    float _S707 = _S704.value - (&lobes_13)->p_sheen_velvet;
    bool _S708 = _S707 < ((&lobes_13)->p_diffuse);
    if(_S708)
    {
        SampleBSDF _S709 = diffuseSample(_S707, n_i_12, _S696, _S698, material_20, lobes_13, eta_i_14, eta_o_14, random_state_16);
        return _S709;
    }
    bool _S710 = _S707 < ((&lobes_13)->p_diffuse + (&lobes_13)->p_refract);
    if(_S710)
    {
        SampleBSDF _S711 = refractSample(_S701, n_i_12, _S696, _S698, material_20, lobes_13, eta_i_14, eta_o_14, random_state_16);
        return _S711;
    }
    SampleBSDF _S712 = reflectSample(in_dir_10, _S701, n_i_12, _S696, _S698, material_20, lobes_13, eta_i_14, eta_o_14, random_state_16);
    return _S712;
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
    bool _S713;
    bool _S714;
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
    int _S715;
    Shift ended_0;
    float density_3;
    float spread_1;
    float width_3;
    float sky_pdf_1;
    float spread_2;
    float width_4;
    uint b_4;
    float3  _S716 = make_float3 (0.0f);
    Shift _S717 = Shift_x24init_0(_S716, 0.0f);
    uint _S718 = r_1->path;
    uint _S719 = extractBits_0(r_1->path, 0U, 5U);
    uint _S720 = extractBits_0(_S718, 5U, 5U);
    uint _S721 = extractBits_0(_S718, 10U, 2U);
    uint _S722 = extractBits_0(_S718, 12U, 3U);
    bool passes_0;
    if(replay_0)
    {
        bool _S723 = _S722 >= 3U;
        uint _S724 = _slang_select(_S723, 1U,0U);
        uint _S725 = _S719 + _S724;
        uint _S726 = (fcptMaxBounces());
        passes_0 = _S725 > _S726;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S717;
    }
    uint _S727 = _S720 - 1U;
    bool _S728 = _S722 == 3U;
    uint _S729 = _slang_select(_S728, 1U,0U);
    uint _S730 = _S719 + _S729;
    bool _S731 = _S721 == 0U;
    uint _S732 = _slang_select(_S731, _S730,_S727);
    FKHit _S733 = (fcptReservoirHit((*r_1)));
    float3  _S734 = dom_0->x0;
    float3  _S735 = dom_0->x1 - dom_0->x0;
    float3  _S736 = ((((_S735)) * make_float3(rnorm3df(((_S735)).x, ((_S735)).y, ((_S735)).z))));
    FKRay _S737 = Ray_x24init_0(dom_0->x1, _S736);
    FKRay ray_2 = _S737;
    FKHit hit_1 = dom_0->hit;
    float3  scatter_in_0 = _S716;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S716;
    float3  extinction_in_0 = _S716;
    uint filling_2 = 4294967295U;
    float _S738 = dom_0->spread;
    float _S739 = dom_0->width;
    float _S740 = length_0(_S735);
    NEEVertex _S741 = NEEVertex_x24init_0(true, 0.0f, _S716, _S716, _S716);
    NEEVertex nee_vertex_0 = _S741;
    Vertex _S742 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S742;
    Reservoir _S743 = (Reservoir{});
    Reservoir chain_0 = _S743;
    uint _S744 = r_1->seed;
    (&chain_0)->seed = r_1->seed;
    (&ray_2)->origin = _S734;
    (&hit_1)->distance = _S740;
    FKMedium _S745 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_1)->distance), (&filling_2)));
    uint _S746 = filling_2;
    bool _S747 = (fcptVaryingUsed());
    uint _S748 = _slang_select(_S747, _S746,4294967295U);
    filling_2 = _S748;
    scatter_in_0 = _S745.scatter;
    extinction_in_0 = _S745.extinction;
    Reservoir _S749 = chain_0;
    uint _S750 = filling_2;
    for(;;)
    {
        bool _S751 = (fcptVaryingUsed());
        if(_S751)
        {
            passes_0 = _S750 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S752 = (fcptMajorant((_S750)));
            spread_0 = _S752;
        }
        else
        {
            spread_0 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_0)
        {
            turned_1 = 4294967295U == _S732;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S721 == 1U;
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
            ended_0 = _S717;
            sky_pdf_0 = 0.0f;
            spread_0 = _S738;
            width_2 = _S739;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_3 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S753 = (&prev_0)->rough;
        if(_S753)
        {
            turned_1 = !(spread_0 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S754 = stream(_S744, 384U);
        uint tracking_0 = _S754;
        weight_1 = throughput_3;
        glowed_0 = _S716;
        b_3 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_0 = _S738;
        width_2 = _S739;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_1)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S715 = int(1);
                break;
            }
            uint _S755 = b_3 + 320U;
            bool _S756 = b_3 == 4294967295U;
            uint _S757 = _slang_select(_S756, 384U,_S755);
            uint _S758 = stream(_S744, _S757);
            Random _S759 = pcg(_S758);
            float _S760 = - (F32_log((1.0f - _S759.value))) / spread_0;
            if(passes_0)
            {
                float3  _S761 = (&ray_2)->origin;
                float3  _S762 = (&ray_2)->unit_direction;
                float _S763 = (&hit_1)->distance;
                uint _S764 = _slang_select(_S756, 0U,b_3);
                uint _S765 = (&prev_0)->lobe;
                uint _S766 = _slang_select(_S756, 3U,_S765);
                float _S767 = (fcptTrackMedium((_S750), (_S761), (_S762), (_S763), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S764), (_S766), (_S756)));
                geometry_density_0 = _S767;
            }
            else
            {
                geometry_density_0 = _S760;
            }
            bool _S768 = !(geometry_density_0 < ((&hit_1)->distance));
            if(_S768)
            {
                _S715 = int(1);
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
                float3  _S769 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S770 = sel_1->glow + _S769;
                sel_1->glow = _S770;
            }
            else
            {
            }
            glowed_0 = _S716;
            uint b_5 = b_3 + 1U;
            float3  _S771 = (&ray_2)->origin + make_float3 (geometry_density_0) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S771;
            float3  _S772 = flightWeight_0(scatter_in_0, extinction_in_0, spread_0, geometry_density_0, true);
            float3  _S773 = weight_1;
            float3  _S774 = _slang_select(passes_0, _S773,_S772);
            float3  throughput_4 = throughput_2 * _S774;
            uint _S775 = stream(_S744, b_5 + 320U);
            tracking_0 = _S775;
            weight_1 = throughput_3;
            float width_5 = width_2 + threshold_0 * geometry_density_0;
            float _S776 = threshold_0 + 3.14159274101257324f;
            bool _S777 = !replay_0;
            if(_S777)
            {
                is_inside_5 = true;
            }
            else
            {
                bool _S778 = b_5 == _S732;
                if(_S778)
                {
                    is_inside_5 = !passes_0;
                }
                else
                {
                    is_inside_5 = false;
                }
            }
            TreeSample _S779 = TreeSample_x24init_0(_S716, _S716, 0.0f, 0U);
            if(is_inside_5)
            {
                float3  _S780 = (&ray_2)->origin;
                float3  _S781 = (&ray_2)->unit_direction;
                float3  _S782 = (&ray_2)->unit_direction;
                uint _S783 = stream(_S744, b_5 + 64U);
                float3  _S784 = extinction_in_0;
                float3  _S785 = extinction_in_0;
                uint2  _S786 = make_uint2 (_S750);
                float3  _S787 = (&ray_2)->unit_direction;
                uint _S788 = arrivalLobe_0(b_5, (&prev_0)->lobe);
                FKHit _S789 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S790 = _S789;
                ShadowContext _S791 = ShadowContext_x24init_0(_S784, _S785, _S786, _S787, b_5, _S788, false, geometry_density_0, width_5, &_S790, false);
                ShadowContext _S792 = _S791;
                TreeSample _S793 = sampleLightTree_0(_S780, _S781, _S782, 0.0f, true, _S783, &_S792);
                light_3 = _S793;
            }
            else
            {
                light_3 = _S779;
            }
            uint _S794 = (fcptMaxBounces());
            bool _S795 = b_5 < _S794;
            if(_S795)
            {
                viewed_0 = (light_3.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S796 = _slang_select(viewed_0, 0.07957746833562851f,0.0f);
            float3  _S797 = throughput_4 * light_3.radiance;
            float _S798 = powerHeuristic(light_3.density, _S796);
            float3  _S799 = _S797 * make_float3 (0.07957746833562851f * _S798);
            float3  _S800 = _slang_select(is_inside_5, _S799,_S716);
            if(replay_0)
            {
                _S713 = b_5 == _S732;
            }
            else
            {
                _S713 = false;
            }
            if(_S713)
            {
                bool _S801 = _S721 == 2U;
                if(_S801)
                {
                    float _S802 = rgb_to_greyscale(_S800);
                    passes_0 = _S802 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S803 = Shift_x24init_0(_S800, 1.0f);
                    _S715 = int(0);
                    ended_0 = _S803;
                    spread_0 = _S776;
                    geometry_density_0 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_5;
                    break;
                }
                _S715 = int(0);
                ended_0 = _S717;
                spread_0 = _S776;
                geometry_density_0 = width_5;
                chain_throughput_0 = throughput_4;
                layer_0 = b_5;
                break;
            }
            if(_S777)
            {
                Reservoir candidate_2 = _S749;
                uint _S804 = extractBits_0(_S749.path, 10U, 2U);
                bool _S805 = _S804 == 1U;
                if(_S805)
                {
                    float3  _S806 = safeDivide(_S800, _S716);
                    (&candidate_2)->radiance = _S806;
                }
                else
                {
                    uint _S807 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                    uint _S808 = insertBits_0(_S807, 2U, 10U, 2U);
                    (&candidate_2)->path = _S808;
                }
                Reservoir _S809 = withEnd(candidate_2, 0U, b_5, _S800);
                offer(sel_1, _S809, _S800 * make_float3 (scale_1) / make_float3 (density_2));
                float _S810 = survivalProbability(throughput_4, density_2);
                uint _S811 = stream(_S744, b_5 + 128U);
                Random _S812 = pcg(_S811);
                bool _S813 = _S810 < (_S812.value);
                if(_S813)
                {
                    _S714 = true;
                }
                else
                {
                    uint _S814 = (fcptMaxBounces());
                    _S714 = b_5 >= _S814;
                }
                if(_S714)
                {
                    _S715 = int(0);
                    ended_0 = _S717;
                    spread_0 = _S776;
                    geometry_density_0 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_5;
                    break;
                }
                float _S815 = density_2 * _S810;
                density_2 = _S815;
            }
            else
            {
            }
            NEEVertex _S816 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_2)->origin, _S716, (&ray_2)->origin);
            nee_vertex_0 = _S816;
            uint _S817 = stream(_S744, b_5);
            float3  _S818 = isotropic_0(_S817);
            (&ray_2)->unit_direction = _S818;
            Vertex _S819 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_0 = _S819;
            float _S820 = (&prev_0)->pdf;
            FKRay _S821 = ray_2;
            FKHit _S822 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S823 = (fcptTraverseInstanceBVH((_S821), (true), (4.294967296e+09f), (false), (_S822), (false)));
            hit_1 = _S823;
            b_3 = b_5;
            throughput_2 = throughput_4;
            threshold_0 = _S776;
            width_2 = width_5;
            sky_pdf_0 = _S820;
        }
        if(_S715 != int(1))
        {
            width_2 = geometry_density_0;
            throughput_2 = chain_throughput_0;
            b_3 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S717;
        spread_0 = threshold_0;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S824 = b_3 == 4294967295U;
    bool _S825 = ((&hit_1)->instance_index) == 4294967295U;
    if(_S825)
    {
        bool _S826 = !(&nee_vertex_0)->none;
        float _S827 = _slang_select(_S826, sky_pdf_0,0.0f);
        float _S828 = escapeWeight_0(_S827, (&ray_2)->unit_direction);
        float3  _S829 = environment_0((&ray_2)->unit_direction, b_3, (&prev_0)->lobe);
        float3  _S830 = throughput_2 * _S829;
        if(replay_0)
        {
            bool _S831 = b_3 == _S732;
            if(_S831)
            {
                passes_0 = _S721 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S830 * make_float3 (_S828) / make_float3 (r_1->jac), density_2 / r_1->jac);
            }
            if(_S731)
            {
                passes_0 = _S728;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_3 == _S719;
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
                return Shift_x24init_0(_S830 * make_float3 (_S828), 1.0f);
            }
            return _S717;
        }
        Reservoir candidate_3 = chain_0;
        uint _S832 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S833 = _S832 == 1U;
        if(_S833)
        {
            uint _S834 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S835 = _S834 == b_3;
            float _S836 = _slang_select(_S835, 1.0f,_S828);
            float3  _S837 = safeDivide(_S830 * make_float3 (_S836), _S716);
            (&candidate_3)->radiance = _S837;
        }
        else
        {
            bool _S838 = (&prev_0)->rough;
            if(_S838)
            {
                uint _S839 = insertBits_0(0U, b_3 + 1U, 5U, 5U);
                uint _S840 = insertBits_0(_S839, 3U, 10U, 2U);
                uint _S841 = insertBits_0(_S840, (&prev_0)->lobe, 15U, 3U);
                bool _S842 = (&prev_0)->inside;
                uint _S843 = _slang_select(_S842, 1U,0U);
                uint _S844 = insertBits_0(_S841, _S843, 22U, 1U);
                (&candidate_3)->path = _S844;
                (&candidate_3)->jac = (&prev_0)->pdf;
                (&candidate_3)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S845 = _S830 * make_float3 (_S828);
        Reservoir _S846 = withEnd(candidate_3, 3U, b_3, _S845);
        offer(sel_1, _S846, _S845 * make_float3 (scale_1) / make_float3 (density_2));
        return _S717;
    }
    float3  _S847 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S847;
    bool _S848 = (fcptVaryingUsed());
    if(_S848)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S849 = !replay_0;
        if(_S849)
        {
            float3  _S850 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S851 = sel_1->glow + _S850;
            sel_1->glow = _S851;
        }
        float3  _S852 = throughput_2 * weight_1;
        throughput_2 = _S852;
    }
    else
    {
        float3  _S853 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
        float3  _S854 = throughput_2 * _S853;
        throughput_2 = _S854;
    }
    float _S855 = width_2 + spread_0 * (&hit_1)->distance;
    uint _S856 = b_3 + 1U;
    b_3 = _S856;
    layer_0 = 0U;
    width_2 = _S855;
    passes_0 = false;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S716;
    float3  reconnection_0 = _S716;
    viewed_0 = _S824;
    for(;;)
    {
        bool _S857 = ((&hit_1)->is_point_light) == 1U;
        if(replay_0)
        {
            _S713 = _S721 == 1U;
        }
        else
        {
            _S713 = false;
        }
        if(_S713)
        {
            _S714 = b_3 == _S720;
        }
        else
        {
            _S714 = false;
        }
        bool _S858;
        if(_S714)
        {
            bool _S859 = ((&hit_1)->instance_index) != (_S733.instance_index);
            if(_S859)
            {
                _S858 = true;
            }
            else
            {
                _S858 = ((&hit_1)->triangle_index) != (_S733.triangle_index);
            }
        }
        else
        {
            _S858 = false;
        }
        if(_S858)
        {
            return _S717;
        }
        FKMedium _S860 = Medium_x24init_0(_S716, _S716);
        BSDFMaterial _S861 = Material_x24init_0(_S716, _S716, 0.0f, 0.0f, 0.0f, 0.0f, _S716, throughput_3, 1.0f, _S716, _S716, 0.5f, 0.0f, 0.0f, _S716);
        FKMedium _S862 = _S860;
        FKSurface _S863 = Surface_x24init_0(_S716, _S716, 0.0f, &_S861, false, 0U, 1.0f, false, &_S862, 4294967295U, _S716);
        bool _S864 = !_S857;
        bool scatter_2;
        bool is_inside_6;
        float3  front_n_0;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S864)
        {
            uint _S865 = stream(_S744, b_3);
            uint _S866 = arrivalLobe_0(b_3, (&prev_0)->lobe);
            FKSurface _S867 = (fcptSurfaceAtPath((hit_1), ((&ray_2)->origin), (_S865), (width_2), (layer_0), (b_3), (_S866), ((&ray_2)->unit_direction)));
            bool _S868 = !passes_0;
            FKSurface _S869 = _S867;
            FKSurface _S870 = emitting_0(&_S869, _S868);
            uint _S871 = stream(_S744, b_3 + 256U);
            Random _S872 = pcg(_S871);
            FKSurface _S873 = _S870;
            FKSurface _S874 = uncovered_0(&_S873, _S872.value);
            float _S875 = facingSign(_S874.material.transmission, _S874.geometry_n, (&ray_2)->unit_direction);
            bool _S876 = _S875 < 0.0f;
            bool _S877 = (_S874.material.transmission) > 0.0f;
            if(_S877)
            {
                bool _S878 = arrivesBehind_0((&ray_2)->unit_direction, _S874.geometry_n);
                scatter_2 = _S878;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S879 = _S874;
            FKSurface _S880 = facingRay_0(&_S879, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S881 = arrivesBehind_0((&ray_2)->unit_direction, _S880.geometry_n);
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
                front_n_0 = _S883;
            }
            else
            {
                front_n_0 = throughput_2;
            }
            bool _S884 = !_S880.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S880.geometry_n, (&ray_2)->unit_direction)))) / ((&hit_1)->distance * (&hit_1)->distance);
            bool _S885 = b_3 == _S856;
            if(_S885)
            {
                float _S886 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S886;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float3  _S887 = front_n_0;
            float _S888 = geometry_density_0;
            scatter_2 = _S884;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S888;
            surface_12 = _S880;
            front_n_0 = _S874.smooth_n;
            throughput_5 = _S887;
            turned_1 = _S876;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_12 = _S863;
            front_n_0 = _S716;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S889;
        if(scatter_2)
        {
            _S889 = (&prev_0)->rough;
        }
        else
        {
            _S889 = false;
        }
        bool _S890;
        if(_S889)
        {
            _S890 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S890 = false;
        }
        FKSurface _S891 = surface_12;
        FKSurface _S892 = surface_12;
        float _S893 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        float2  _S894 = vertexEta(_S891.material, _S893);
        bool _S895;
        if(scatter_2)
        {
            uint _S896 = (fcptMaxBounces());
            bool _S897 = b_3 >= _S896;
            if(_S897)
            {
                _S895 = true;
            }
            else
            {
                bool _S898 = neeDecision(_S891.material, _S893, _S894.x, _S894.y);
                _S895 = _S898;
            }
        }
        else
        {
            _S895 = false;
        }
        bool _S899;
        if(passes_0)
        {
            _S899 = true;
        }
        else
        {
            _S899 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S899)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S895;
        }
        bool _S900 = (fcptHairUsed());
        bool _S901;
        if(_S900)
        {
            float3  _S902 = surface_12.hair;
            _S901 = (dot_0(_S902, _S902)) > 0.0f;
        }
        else
        {
            _S901 = false;
        }
        bool _S903;
        if(_S901)
        {
            _S903 = true;
        }
        else
        {
            BSDFMaterial _S904 = _S891.material;
            bool _S905 = isTranslucent_0(&_S904);
            _S903 = _S905;
        }
        bool _S906;
        if(_S903)
        {
            _S906 = true;
        }
        else
        {
            bool _S907 = (_S891.material.transmission) > 0.0f;
            if(_S907)
            {
                uint _S908 = (fcptLayers((hit_1)));
                _S906 = _S908 == 1U;
            }
            else
            {
                _S906 = false;
            }
        }
        float3  _S909 = emitted_0(_S891.material.emissive, (&ray_2)->unit_direction, front_n_0);
        float3  emission_0;
        if(_S857)
        {
            float3  _S910 = (fcptCalculatePointLightContrib(((&hit_1)->instance_index)));
            emission_0 = _S910;
        }
        else
        {
            emission_0 = _S909;
        }
        bool _S911 = !replay_0;
        bool _S912;
        if(_S911)
        {
            _S912 = true;
        }
        else
        {
            _S912 = b_3 >= _S732;
        }
        bool _S913;
        if(_S912)
        {
            float _S914 = rgb_to_greyscale(emission_0);
            _S913 = _S914 > 0.0f;
        }
        else
        {
            _S913 = false;
        }
        float3  emission_1;
        if(_S913)
        {
            NEEVertex _S915 = nee_vertex_0;
            FKHit _S916 = hit_1;
            float _S917 = emissionWeight_0(&_S915, &_S916, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S917);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S918;
        if(replay_0)
        {
            _S918 = _S721 == 1U;
        }
        else
        {
            _S918 = false;
        }
        bool _S919;
        if(_S918)
        {
            _S919 = b_3 > _S720;
        }
        else
        {
            _S919 = false;
        }
        bool _S920;
        if(_S919)
        {
            _S920 = b_3 == _S719;
        }
        else
        {
            _S920 = false;
        }
        bool _S921;
        if(_S920)
        {
            bool _S922 = _S722 == 1U;
            if(_S922)
            {
                _S921 = true;
            }
            else
            {
                _S921 = _S722 == 2U;
            }
        }
        else
        {
            _S921 = false;
        }
        if(_S921)
        {
            bool _S923 = _S857 != (_S722 == 2U);
            if(_S923)
            {
                return _S717;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_1->jac), density_2 / r_1->jac);
        }
        uint _S924 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S925 = _S924 == 1U;
        Reservoir here_0 = chain_0;
        uint _S926 = insertBits_0(0U, b_3, 5U, 5U);
        uint _S927 = insertBits_0(_S926, 1U, 10U, 2U);
        uint _S928 = insertBits_0(_S927, (&prev_0)->lobe, 15U, 3U);
        bool _S929 = (&prev_0)->inside;
        uint _S930 = _slang_select(_S929, 1U,0U);
        uint _S931 = insertBits_0(_S928, _S930, 22U, 1U);
        (&here_0)->path = _S931;
        float _S932 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S932;
        fcptWithReservoirHit((&here_0), (&hit_1));
        bool _S933;
        if(replay_0)
        {
            _S933 = _S721 == 1U;
        }
        else
        {
            _S933 = false;
        }
        bool _S934;
        if(_S933)
        {
            _S934 = b_3 == _S720;
        }
        else
        {
            _S934 = false;
        }
        bool _S935 = b_3 == _S732;
        bool _S936;
        if(_S935)
        {
            bool _S937 = !scatter_2;
            if(_S937)
            {
                _S936 = true;
            }
            else
            {
                bool _S938 = _S721 != 1U;
                if(_S938)
                {
                    _S936 = _S721 != 3U;
                }
                else
                {
                    _S936 = false;
                }
            }
        }
        else
        {
            _S936 = false;
        }
        bool _S939;
        if(_S936)
        {
            _S939 = _S721 == 2U;
        }
        else
        {
            _S939 = false;
        }
        bool _S940;
        if(_S939)
        {
            _S940 = !_S890;
        }
        else
        {
            _S940 = false;
        }
        bool _S941;
        if(_S940)
        {
            _S941 = _S722 != 4U;
        }
        else
        {
            _S941 = false;
        }
        bool _S942 = _S720 == _S719;
        bool _S943;
        if(_S942)
        {
            _S943 = _S722 == 0U;
        }
        else
        {
            _S943 = false;
        }
        bool _S944;
        if(_S943)
        {
            _S944 = ((&hit_1)->instance_index) == (_S733.instance_index);
        }
        else
        {
            _S944 = false;
        }
        bool _S945;
        if(_S944)
        {
            _S945 = ((&hit_1)->triangle_index) == (_S733.triangle_index);
        }
        else
        {
            _S945 = false;
        }
        bool _S946;
        if(_S945)
        {
            _S946 = _S890;
        }
        else
        {
            _S946 = false;
        }
        bool _S947 = _slang_select(_S934, _S946,_S941);
        bool _S948;
        if(nee_0)
        {
            _S948 = _slang_select(replay_0, _S947,scatter_2);
        }
        else
        {
            _S948 = false;
        }
        TreeSample _S949 = TreeSample_x24init_0(_S716, _S716, 0.0f, 0U);
        float3  throughput_6;
        float3  lit_0;
        if(_S948)
        {
            float3  _S950 = (&ray_2)->origin;
            if(_S901)
            {
                throughput_6 = _S716;
            }
            else
            {
                throughput_6 = _S892.smooth_n;
            }
            FKSurface _S951 = surface_12;
            uint _S952 = stream(_S744, b_3 + 64U);
            uint _S953 = arrivalLobe_0(b_3, (&prev_0)->lobe);
            FKSurface _S954 = surface_12;
            FKHit _S955 = hit_1;
            ShadowContext _S956 = shadowContext_0(&_S954, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_3, _S953, (&hit_1)->distance, width_2, &_S955, _S901);
            ShadowContext _S957 = _S956;
            TreeSample _S958 = sampleLightTree_0(_S950, throughput_6, surface_12.geometry_n, surface_12.geometry_offset, _S906, _S952, &_S957);
            bool _S959 = any_0((_S958.radiance) != _S716);
            if(_S959)
            {
                if(_S901)
                {
                    uint _S960 = (fcptMaxBounces());
                    bool _S961 = b_3 < _S960;
                    FKSurface _S962 = surface_12;
                    TreeSample _S963 = _S958;
                    float3  _S964 = hairLight_0(&_S962, (&ray_2)->unit_direction, &_S963, _S961);
                    lit_0 = _S964;
                }
                else
                {
                    float _S965 = _S894.x;
                    float _S966 = _S894.y;
                    uint _S967 = (fcptMaxBounces());
                    bool _S968 = b_3 < _S967;
                    TreeSample _S969 = _S958;
                    BSDFMaterial _S970 = _S891.material;
                    float3  _S971 = lightBSDF_0((&ray_2)->unit_direction, &_S969, _S892.smooth_n, _S951.geometry_n, &_S970, _S965, _S966, _S968, surface_12.random_state);
                    lit_0 = _S971;
                }
            }
            else
            {
                lit_0 = _S716;
            }
            light_3 = _S958;
        }
        else
        {
            light_3 = _S949;
            lit_0 = _S716;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S972;
        bool _S973;
        float density_4;
        if(_S934)
        {
            bool _S974 = !_S890;
            if(_S974)
            {
                return _S717;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S942)
            {
                viewed_1 = _S722 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            if(_S942)
            {
                refracted_4 = _S722 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S975 = !nee_0;
                if(_S975)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S976 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S976 > 0.0f);
                }
                if(passes_0)
                {
                    return _S717;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            if(_S942)
            {
                wrong_side_0 = _S722 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S977 = !nee_0;
                if(_S977)
                {
                    return _S717;
                }
                float _S978 = environmentPdf_0(r_1->dir);
                float3  _S979 = skyBSDF((&ray_2)->unit_direction, r_1->dir, surface_12, _S894, is_inside_6, _S978, surface_12.random_state);
                return Shift_x24init_0(throughput_7 * _S979 * r_1->radiance / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            uint _S980 = extractBits_0(_S718, 21U, 1U);
            bool _S981 = nee_0 != (_S980 == 1U);
            if(_S981)
            {
                return _S717;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_0)
            {
                viewed_1 = _S935;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S982 = !scatter_2;
                if(_S982)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S983 = _S721 != 1U;
                    if(_S983)
                    {
                        refracted_4 = _S721 != 3U;
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
                bool _S984 = _S721 == 2U;
                if(_S984)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S890;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S722 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    uint _S985 = stream(_S744, b_3 + 448U);
                    FKRay _S986 = ray_2;
                    FKSurface _S987 = surface_12;
                    SkySample _S988 = sampleSky_0(&_S986, &_S987, _S894, is_inside_6, _S985, surface_12.random_state);
                    return Shift_x24init_0(throughput_5 * _S988.color, 1.0f);
                }
                if(_S984)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S890;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S989 = rgb_to_greyscale(light_3.radiance);
                    bool _S990 = !(_S989 > 0.0f);
                    if(_S990)
                    {
                        return _S717;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S731)
                {
                    passes_0 = _S722 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S857;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S731)
                {
                    passes_0 = _S722 == 1U;
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
                    passes_0 = !_S890;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S717;
            }
            else
            {
                if(_S911)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S991 = b_3 > 0U;
                    if(_S991)
                    {
                        Reservoir candidate_4 = chain_0;
                        if(_S925)
                        {
                            float3  _S992 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_4)->radiance = _S992;
                        }
                        else
                        {
                            if(_S890)
                            {
                                candidate_4 = here_0;
                            }
                        }
                        float3  _S993 = throughput_5 * emission_1;
                        Reservoir _S994 = withEnd(candidate_4, 1U, b_3, _S993);
                        offer(sel_1, _S994, _S993 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S995 = throughput_5 * emission_1;
                        float3  _S996 = sel_1->glow + _S995;
                        sel_1->glow = _S996;
                    }
                    if(nee_0)
                    {
                        float3  _S997 = throughput_5 * lit_0;
                        Reservoir candidate_5 = chain_0;
                        if(_S925)
                        {
                            float3  _S998 = safeDivide(_S997, chain_throughput_0);
                            (&candidate_5)->radiance = _S998;
                        }
                        else
                        {
                            if(_S890)
                            {
                                candidate_5 = here_0;
                                uint _S999 = insertBits_0((&candidate_5)->path, 1U, 21U, 1U);
                                (&candidate_5)->path = _S999;
                                (&candidate_5)->dir = light_3.dir;
                                (&candidate_5)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1000 = insertBits_0(0U, b_3 + 1U, 5U, 5U);
                                uint _S1001 = insertBits_0(_S1000, 2U, 10U, 2U);
                                (&candidate_5)->path = _S1001;
                            }
                        }
                        Reservoir _S1002 = withEnd(candidate_5, 0U, b_3, _S997);
                        offer(sel_1, _S1002, _S997 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S901)
                        {
                            _S972 = false;
                        }
                        else
                        {
                            bool _S1003 = environmentMapped_0();
                            _S972 = _S1003;
                        }
                    }
                    else
                    {
                        _S972 = false;
                    }
                    if(_S972)
                    {
                        uint _S1004 = (fcptMaxBounces());
                        _S973 = b_3 < _S1004;
                    }
                    else
                    {
                        _S973 = false;
                    }
                    if(_S973)
                    {
                        uint _S1005 = stream(_S744, b_3 + 448U);
                        FKRay _S1006 = ray_2;
                        FKSurface _S1007 = surface_12;
                        SkySample _S1008 = sampleSky_0(&_S1006, &_S1007, _S894, is_inside_6, _S1005, surface_12.random_state);
                        float3  _S1009 = throughput_5 * _S1008.color;
                        Reservoir candidate_6 = chain_0;
                        if(_S925)
                        {
                            float3  _S1010 = safeDivide(_S1009, chain_throughput_0);
                            (&candidate_6)->radiance = _S1010;
                        }
                        else
                        {
                            if(_S890)
                            {
                                candidate_6 = here_0;
                                uint _S1011 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1011;
                                (&candidate_6)->dir = _S1008.dir;
                                (&candidate_6)->radiance = _S1008.radiance;
                            }
                            else
                            {
                                uint _S1012 = insertBits_0(0U, b_3 + 1U, 5U, 5U);
                                uint _S1013 = insertBits_0(_S1012, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1013;
                            }
                        }
                        Reservoir _S1014 = withEnd(candidate_6, 4U, b_3, _S1009);
                        offer(sel_1, _S1014, _S1009 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1015;
        bool _S1016;
        bool straight_0;
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
        bool _S1027;
        bool _S1028;
        bool _S1029;
        bool _S1030;
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
                viewed_1 = _S935;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1031 = extractBits_0(_S718, 15U, 3U);
            uint _S1032 = extractBits_0(_S718, 18U, 3U);
            uint _S1033 = _slang_select(_S934, _S1032,_S1031);
            float3  _S1034 = r_1->dir;
            bool refracted_5 = _S1033 == 1U;
            SampleBSDF _S1035 = SampleBSDF_x24init_0(_S716, _S716, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1035;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1036 = extractBits_0(_S718, 22U, 1U);
                bool _S1037 = is_inside_6 != (_S1036 == 1U);
                if(_S1037)
                {
                    return _S717;
                }
                bool _S1038 = _S721 == 1U;
                if(_S1038)
                {
                    float3  _S1039 = (fcptHitPosition((_S733)));
                    throughput_8 = _S1039;
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
                    BSDFMaterial _S1040 = _S891.material;
                    bool _S1041 = isTranslucent_0(&_S1040);
                    if(_S1041)
                    {
                        refracted_4 = _S1033 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1042 = throughput_8 - (&ray_2)->origin;
                        float3  _S1043 = _slang_select(_S1038, _S1042,_S1034);
                        wrong_side_0 = (dot_0(_S892.smooth_n, _S1043) * _S893) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1038)
                {
                    float3  _S1044 = (&ray_2)->origin;
                    FKSurface _S1045 = surface_12;
                    float3  _S1046 = - _S892.smooth_n;
                    bool _S1047 = is_inside_6 != refracted_4;
                    float3  _S1048 = _slang_select(_S1047, _S1046,_S892.smooth_n);
                    float3  _S1049 = throughput_8 - (_S1044 + make_float3 (_S1045.geometry_offset) * _S1048);
                    float3  _S1050 = ((((_S1049)) * make_float3(rnorm3df(((_S1049)).x, ((_S1049)).y, ((_S1049)).z))));
                    reconnection_1 = _S1050;
                }
                else
                {
                    reconnection_1 = _S1034;
                }
                if(_S901)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1051 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1051;
                }
                if(wrong_side_0)
                {
                    return _S717;
                }
                float3  _S1052 = throughput_8;
                throughput_8 = reconnection_1;
                b_6 = _S1033;
                wrong_side_0 = false;
                reconnection_1 = _S1052;
            }
            else
            {
                bool _S1053 = !_S934;
                if(_S1053)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1054;
                    if(_S901)
                    {
                        SampleBSDF _S1055 = (fcptSampleHair((surface_12.hair), (_S891.material.albedo), (_S891.material.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1054 = _S1055;
                    }
                    else
                    {
                        SampleBSDF _S1056 = sampleBSDF((&ray_2)->unit_direction, _S892.smooth_n, _S891.material, _S894.x, _S894.y, surface_12.random_state, make_float2 (0.0f));
                        _S1054 = _S1056;
                    }
                    bsdf_sampled_0 = _S1054;
                    if(_S901)
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
                            return _S717;
                        }
                        break;
                    }
                    if(_S901)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1057 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1057;
                    }
                    if(wrong_side_0)
                    {
                        _S972 = (_S891.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S972 = false;
                    }
                    if(_S972)
                    {
                        SampleBSDF _S1058 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S891.material, _S894.x, _S894.y, (&bsdf_sampled_0)->random_state, make_float2 (0.0f));
                        (&bsdf_sampled_0)->unit_direction = _S1058.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1058.refracted;
                        (&bsdf_sampled_0)->throughput = _S1058.throughput;
                        (&bsdf_sampled_0)->lobe = _S1058.lobe;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1059 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1059;
                        }
                    }
                    uint _S1060 = (&bsdf_sampled_0)->lobe;
                    float3  _S1061 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1062 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1063 = (&bsdf_sampled_0)->pdf;
                    float _S1064 = _slang_select(wrong_side_0, 0.0f,_S1063);
                    (&lobe_5)->pdf = _S1064;
                    throughput_8 = _S1061;
                    b_6 = _S1060;
                    refracted_4 = _S1062;
                }
                else
                {
                    throughput_8 = _S1034;
                    b_6 = _S1033;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S972 = true;
            }
            else
            {
                _S972 = _S934;
            }
            float3  chain_throughput_1;
            if(_S972)
            {
                if(_S901)
                {
                    SampleBSDF _S1065 = (fcptConnectHair((surface_12.hair), (_S891.material.albedo), (_S891.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    lobe_5 = _S1065;
                }
                else
                {
                    float3  _S1066 = (&ray_2)->unit_direction;
                    float _S1067 = sign_0(_S893);
                    float3  _S1068 = _S892.smooth_n * make_float3 (_S1067);
                    float _S1069 = dot_0(_S1068, throughput_8);
                    float _S1070 = _S891.material.roughness;
                    float _S1071 = _S1070 * _S1070;
                    AnisotropicFrame _S1072 = anisotropicFrame(_S891.material, _S1068);
                    float3  _S1073 = negate_0(_S1066);
                    SheenProfile _S1074 = sheenProfile(_S1073, _S1068, _S891.material);
                    float3  _S1075 = reflectedHalf(_S1066, throughput_8);
                    bool _S1076 = b_6 == 1U;
                    if(_S1076)
                    {
                        float3  _S1077 = refractedHalf(_S1066, throughput_8, _S892.smooth_n, _S894.x, _S894.y);
                        throughput_9 = _S1077;
                    }
                    else
                    {
                        throughput_9 = _S1075;
                    }
                    bool _S1078 = b_6 == 0U;
                    if(_S1078)
                    {
                        float3  _S1079 = sampledHalf(_S1066, _S892.smooth_n, _S891.material, surface_12.random_state, _S1072);
                        throughput_10 = _S1079;
                    }
                    else
                    {
                        throughput_10 = throughput_9;
                    }
                    float3  _S1080 = negate_0(_S1066);
                    float _S1081 = _S894.x;
                    float _S1082 = _S894.y;
                    BSDFLobes _S1083 = bsdfLobes(_S1066, _S1080, _S1068, throughput_10, _S891.material, _S1081, _S1082, _S1072, _S1074);
                    BSDFLobes lobe_terms_1 = _S1083;
                    float _S1084 = translucentShare(_S891.material);
                    (&lobe_terms_1)->translucent_share = _S1084;
                    switch(b_6)
                    {
                    case 0U:
                        {
                            float _S1085 = diffusePDF(_S1069, 0.0f, (F32_abs((_S893))), _S1071, lobe_terms_1, _S1081, _S1082);
                            float3  _S1086 = diffuseBSDF(throughput_8, _S1068, _S1071, _S891.material, lobe_terms_1);
                            density_6 = _S1085;
                            chain_throughput_1 = _S1086;
                            break;
                        }
                    case 1U:
                        {
                            float _S1087 = refractPDF(_S1069, dot_0(throughput_8, throughput_10), (F32_abs((_S893))), _S1071, lobe_terms_1, _S1081, _S1082);
                            float3  _S1088 = refractBSDF(throughput_8, _S1068, _S1071, _S891.material, lobe_terms_1);
                            density_6 = _S1087;
                            chain_throughput_1 = _S1088;
                            break;
                        }
                    case 4U:
                        {
                            float _S1089 = sheenVelvetPDF(_S1069, 0.0f, (F32_abs((_S893))), _S1071, lobe_terms_1, _S1081, _S1082);
                            float3  _S1090 = sheenVelvetBSDF(throughput_8, _S1068, _S1071, _S891.material, lobe_terms_1);
                            density_6 = _S1089;
                            chain_throughput_1 = _S1090;
                            break;
                        }
                    default:
                        {
                            float _S1091 = reflectPDF(_S1069, 0.0f, (F32_abs((_S893))), _S1071, lobe_terms_1, _S1081, _S1082);
                            float3  _S1092 = reflectBSDF(throughput_8, _S1068, _S1071, _S891.material, lobe_terms_1);
                            density_6 = _S1091;
                            chain_throughput_1 = _S1092;
                            break;
                        }
                    }
                    bool _S1093 = density_6 > 0.0f;
                    if(_S1093)
                    {
                        SampleBSDF _S1094 = SampleBSDF_x24init_0(throughput_8, chain_throughput_1, surface_12.random_state, _S1076, b_6, density_6);
                        lobe_5 = _S1094;
                    }
                }
            }
            bool _S1095 = b_6 == 0U;
            if(_S1095)
            {
                _S973 = true;
            }
            else
            {
                _S973 = b_6 == 4U;
            }
            if(_S901)
            {
                _S1015 = false;
            }
            else
            {
                bool _S1096 = !_S973;
                if(_S1096)
                {
                    bool _S1097 = (_S891.material.roughness) == 0.0f;
                    if(_S1097)
                    {
                        _S1015 = true;
                    }
                    else
                    {
                        bool _S1098 = b_6 == 1U;
                        if(_S1098)
                        {
                            _S1015 = (_S894.x) == (_S894.y);
                        }
                        else
                        {
                            _S1015 = false;
                        }
                    }
                }
                else
                {
                    _S1015 = false;
                }
            }
            bool _S1099 = !_S901;
            if(_S1099)
            {
                _S1016 = b_6 == 1U;
            }
            else
            {
                _S1016 = false;
            }
            if(_S1016)
            {
                straight_0 = (_S891.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1017 = _S1099;
            }
            else
            {
                _S1017 = false;
            }
            if(_S1017)
            {
                _S1018 = b_6 == 1U;
            }
            else
            {
                _S1018 = false;
            }
            if(_S1018)
            {
                _S1019 = (_S894.x) == (_S894.y);
            }
            else
            {
                _S1019 = false;
            }
            BSDFMaterial _S1100 = _S891.material;
            bool _S1101 = isTranslucent_0(&_S1100);
            if(_S1101)
            {
                _S1020 = _S1095;
            }
            else
            {
                _S1020 = false;
            }
            if(_S1020)
            {
                _S1021 = (dot_0(throughput_8, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1021 = false;
            }
            if(nee_0)
            {
                _S1022 = !_S1015;
            }
            else
            {
                _S1022 = false;
            }
            if(_S1022)
            {
                _S1023 = !wrong_side_0;
            }
            else
            {
                _S1023 = false;
            }
            if(_S1023)
            {
                float _S1102 = (&lobe_5)->pdf;
                float3  _S1103 = (&ray_2)->origin;
                float3  _S1104 = _slang_select(_S906, _S716,_S892.smooth_n);
                float3  _S1105 = (&ray_2)->origin;
                FKSurface _S1106 = surface_12;
                float3  _S1107 = - _S892.smooth_n;
                float3  _S1108 = _slang_select(_S1021, _S1107,_S892.smooth_n);
                NEEVertex _S1109 = NEEVertex_x24init_0(false, _S1102, _S1103, _S1104, _S1105 + make_float3 (_S1106.geometry_offset) * _S1108);
                nee_vertex_0 = _S1109;
            }
            else
            {
                if(_S901)
                {
                    _S1024 = true;
                }
                else
                {
                    bool _S1110 = b_6 != 1U;
                    if(_S1110)
                    {
                        _S1024 = true;
                    }
                    else
                    {
                        _S1024 = (_S894.x) != (_S894.y);
                    }
                }
                if(_S1024)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1111 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1111)
            {
                if(_S973)
                {
                    _S1024 = true;
                }
                else
                {
                    _S1024 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_1)->distance * (&hit_1)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1024 = false;
            }
            bool _S1112 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1112)
            {
                if(_S973)
                {
                    _S1025 = true;
                }
                else
                {
                    _S1025 = (_S891.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1025 = false;
            }
            if(_S934)
            {
                bool _S1113 = !_S1024;
                if(_S1113)
                {
                    return _S717;
                }
                bool _S1114 = _S722 != 1U;
                if(_S1114)
                {
                    _S1026 = _S722 != 2U;
                }
                else
                {
                    _S1026 = false;
                }
                if(_S1026)
                {
                    float _S1115 = (&lobe_5)->pdf;
                    float _S1116 = _slang_select(nee_0, _S1115,0.0f);
                    float _S1117 = escapeWeight_0(_S1116, _S1034);
                    if(_S942)
                    {
                        passes_0 = _S728;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1118 = _slang_select(passes_0, _S1117,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_1->radiance * make_float3 (_S1118) / make_float3 (r_1->jac), density_4 * (&lobe_5)->pdf / r_1->jac);
                }
                float3  _S1119 = throughput_6 * make_float3 ((&lobe_5)->pdf);
                float _S1120 = density_4 * (&lobe_5)->pdf;
                throughput_9 = _S1119;
                density_6 = _S1120;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1121 = (fcptLayers((hit_1)));
            bool _S1122 = _S1121 > 1U;
            if(_S1122)
            {
                _S1026 = (b_6 == 1U) != passes_0;
            }
            else
            {
                _S1026 = false;
            }
            if(viewed_1)
            {
                _S1027 = _S1026;
            }
            else
            {
                _S1027 = false;
            }
            if(_S1027)
            {
                return _S717;
            }
            if(replay_0)
            {
                _S1028 = b_3 <= _S732;
            }
            else
            {
                _S1028 = false;
            }
            if(_S1028)
            {
                _S1029 = _S890;
            }
            else
            {
                _S1029 = false;
            }
            if(_S1029)
            {
                _S1030 = _S1024;
            }
            else
            {
                _S1030 = false;
            }
            bool _S1123;
            if(_S1030)
            {
                _S1123 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1123 = !_S1025;
                }
                else
                {
                    _S1123 = false;
                }
            }
            if(_S1123)
            {
                return _S717;
            }
            if(viewed_1)
            {
                float3  _S1124 = throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1125 = (&lobe_5)->pdf;
                throughput_10 = _S1124;
                sky_pdf_2 = _S1125;
            }
            else
            {
                float3  _S1126 = throughput_9 * max_0((&lobe_5)->throughput, _S716);
                throughput_10 = _S1126;
                sky_pdf_2 = density_6;
            }
            bool _S1127;
            if(_S911)
            {
                _S1127 = !_S925;
            }
            else
            {
                _S1127 = false;
            }
            bool _S1128;
            if(_S1127)
            {
                _S1128 = _S890;
            }
            else
            {
                _S1128 = false;
            }
            bool _S1129;
            if(_S1128)
            {
                _S1129 = _S1024;
            }
            else
            {
                _S1129 = false;
            }
            if(_S1129)
            {
                chain_0 = here_0;
                uint _S1130 = insertBits_0((&chain_0)->path, b_6, 18U, 3U);
                uint _S1131 = _slang_select(nee_0, 1U,0U);
                uint _S1132 = insertBits_0(_S1130, _S1131, 21U, 1U);
                (&chain_0)->path = _S1132;
                float _S1133 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1133;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1134 = surface_12;
            Vertex _S1135 = Vertex_x24init_0(_S1025, b_6, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1135;
            float _S1136 = (&lobe_5)->pdf;
            bool _S1137 = b_6 == 1U;
            bool _S1138;
            if(_S1137)
            {
                _S1138 = (_S894.x) == (_S894.y);
            }
            else
            {
                _S1138 = false;
            }
            float sky_pdf_3 = _slang_select(_S1138, sky_pdf_0,_S1136);
            float _S1139 = _slang_select(_S901, 0.0f,sky_pdf_3);
            float _S1140 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1141 = !_S1015;
            float _S1142 = _slang_select(_S1141, _S1140,0.0f);
            float _S1143 = spread_0 + _S1142;
            bool _S1144;
            if(refracted_4)
            {
                _S1144 = !_S1021;
            }
            else
            {
                _S1144 = false;
            }
            bool is_inside_7;
            if(_S1144)
            {
                bool _S1145 = !is_inside_6;
                is_inside_7 = _S1145;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1146 = surface_12;
            bool _S1147 = boundsVolume_0(&_S1146);
            bool _S1148;
            if(_S1147)
            {
                _S1148 = !_S1026;
            }
            else
            {
                _S1148 = false;
            }
            if(_S1148)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1149 = - _S1134.geometry_n;
                float3  _S1150 = _slang_select(turned_1, _S1149,_S1134.geometry_n);
                (&faced_2)->geometry_n = _S1150;
                FKMedium _S1151 = Medium_x24init_0(scatter_in_0, extinction_in_0);
                FKSurface _S1152 = faced_2;
                FKMedium _S1153 = _S1151;
                MediumSides _S1154 = mediumSides_0(&_S1152, &_S1153, filling_2, (&ray_2)->unit_direction);
                bool _S1155 = ((dot_0(throughput_8, _S1134.geometry_n)) > 0.0f) == ((dot_0(_S1134.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1156 = _slang_select(_S1155, _S1154.front.scatter,_S1154.behind.scatter);
                scatter_in_0 = _S1156;
                float3  _S1157 = _slang_select(_S1155, _S1154.front.extinction,_S1154.behind.extinction);
                extinction_in_0 = _S1157;
                uint _S1158 = _S1154.fillings.x;
                uint _S1159 = _S1154.fillings.y;
                uint _S1160 = _slang_select(_S1155, _S1159,_S1158);
                bool _S1161 = (fcptVaryingUsed());
                uint _S1162 = _slang_select(_S1161, _S1160,4294967295U);
                filling_2 = _S1162;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1163 = !_S1026;
            if(_S1163)
            {
                FKSurface _S1164 = surface_12;
                float _S1165 = _slang_select(straight_0, 0.0f,_S1164.geometry_offset);
                float3  _S1166 = - _S892.smooth_n;
                bool _S1167 = is_inside_7 != _S1021;
                float3  _S1168 = _slang_select(_S1167, _S1166,_S892.smooth_n);
                float3  _S1169 = (&ray_2)->origin + make_float3 (_S1165) * _S1168;
                (&ray_2)->origin = _S1169;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1026;
            viewed_1 = _S1019;
            sky_pdf_2 = _S1139;
            spread_3 = _S1143;
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
        if(_S911)
        {
            if(_S857)
            {
                float3  _S1170 = throughput_9 * emission_1;
                Reservoir candidate_7 = chain_0;
                uint _S1171 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1172 = _S1171 == 1U;
                if(_S1172)
                {
                    float3  _S1173 = safeDivide(_S1170, chain_throughput_0);
                    (&candidate_7)->radiance = _S1173;
                }
                Reservoir _S1174 = withEnd(candidate_7, 2U, b_3, _S1170);
                offer(sel_1, _S1174, _S1170 * make_float3 (scale_1) / make_float3 (density_6));
            }
            if(_S857)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1175 = survivalProbability(throughput_9, density_6);
                density_7 = _S1175;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1176 = stream(_S744, b_3 + 128U);
            Random _S1177 = pcg(_S1176);
            bool _S1178 = density_7 < (_S1177.value);
            if(_S1178)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1179 = (fcptMaxBounces());
                wrong_side_0 = b_3 >= _S1179;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1180 = density_6 * density_7;
            density_7 = _S1180;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1181 = layer_0 ^ 1U;
        uint _S1182 = _slang_select(passes_0, _S1181,0U);
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
            uint _S1183 = b_6 + 1U;
            b_3 = _S1183;
            layer_0 = _S1182;
            continue;
        }
        FKRay _S1184 = ray_2;
        float _S1185 = distance_3(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_0)
        {
            refracted_4 = _S935;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S721 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1186 = _slang_select(wrong_side_0, _S1185,4.294967296e+09f);
        bool _S1187 = !_S901;
        if(straight_0)
        {
            _S972 = true;
        }
        else
        {
            _S972 = _S901;
        }
        FKHit _S1188;
        if(_S972)
        {
            _S1188 = hit_1;
        }
        else
        {
            _S1188 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
        }
        FKHit _S1189 = (fcptTraverseInstanceBVH((_S1184), (_S864), (_S1186), (_S1187), (_S1188), (viewed_1)));
        hit_1 = _S1189;
        if(replay_0)
        {
            _S973 = _S935;
        }
        else
        {
            _S973 = false;
        }
        if(_S973)
        {
            _S1015 = _S721 == 1U;
        }
        else
        {
            _S1015 = false;
        }
        if(_S1015)
        {
            _S1016 = ((&hit_1)->instance_index) == (_S733.instance_index);
        }
        else
        {
            _S1016 = false;
        }
        if(_S1016)
        {
            _S1017 = ((&hit_1)->triangle_index) == (_S733.triangle_index);
        }
        else
        {
            _S1017 = false;
        }
        if(_S1017)
        {
            (&hit_1)->uv = _S733.uv;
            float _S1190 = distance_3(reconnection_0, (&ray_2)->origin);
            (&hit_1)->distance = _S1190;
        }
        if(replay_0)
        {
            _S1018 = _S935;
        }
        else
        {
            _S1018 = false;
        }
        if(_S1018)
        {
            _S1019 = _S721 == 3U;
        }
        else
        {
            _S1019 = false;
        }
        if(_S1019)
        {
            _S1020 = ((&hit_1)->instance_index) != 4294967295U;
        }
        else
        {
            _S1020 = false;
        }
        if(_S1020)
        {
            return _S717;
        }
        Reservoir _S1191 = chain_0;
        uint _S1192 = filling_2;
        for(;;)
        {
            bool _S1193 = (fcptVaryingUsed());
            if(_S1193)
            {
                _S1021 = _S1192 != 4294967295U;
            }
            else
            {
                _S1021 = false;
            }
            float _S1194;
            if(_S1021)
            {
                float _S1195 = (fcptMajorant((_S1192)));
                _S1194 = _S1195;
            }
            else
            {
                _S1194 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_0)
            {
                _S1022 = _S935;
            }
            else
            {
                _S1022 = false;
            }
            if(_S1022)
            {
                _S1023 = _S721 == 1U;
            }
            else
            {
                _S1023 = false;
            }
            if(_S1023)
            {
                _S1024 = _S1194 > 0.0f;
            }
            else
            {
                _S1024 = false;
            }
            if(_S1024)
            {
                ended_0 = _S717;
                sky_pdf_1 = sky_pdf_2;
                spread_1 = spread_3;
                width_3 = width_2;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_6 = b_3;
                _S1025 = true;
                break;
            }
            bool _S1196 = (&prev_0)->rough;
            if(_S1196)
            {
                _S1025 = !(_S1194 > 0.0f);
            }
            else
            {
                _S1025 = false;
            }
            (&prev_0)->rough = _S1025;
            uint _S1197 = b_3 + 320U;
            bool _S1198 = b_3 == 4294967295U;
            uint _S1199 = _slang_select(_S1198, 384U,_S1197);
            uint _S1200 = stream(_S744, _S1199);
            uint tracking_1 = _S1200;
            weight_1 = throughput_3;
            glowed_0 = _S716;
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
                    _S715 = int(2);
                    break;
                }
                uint _S1201 = b_6 + 320U;
                bool _S1202 = b_6 == 4294967295U;
                uint _S1203 = _slang_select(_S1202, 384U,_S1201);
                uint _S1204 = stream(_S744, _S1203);
                Random _S1205 = pcg(_S1204);
                float _S1206 = - (F32_log((1.0f - _S1205.value))) / _S1194;
                if(_S1021)
                {
                    float3  _S1207 = (&ray_2)->origin;
                    float3  _S1208 = (&ray_2)->unit_direction;
                    float _S1209 = (&hit_1)->distance;
                    uint _S1210 = _slang_select(_S1202, 0U,b_6);
                    uint _S1211 = (&prev_0)->lobe;
                    uint _S1212 = _slang_select(_S1202, 3U,_S1211);
                    float _S1213 = (fcptTrackMedium((_S1192), (_S1207), (_S1208), (_S1209), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S1210), (_S1212), (_S1202)));
                    spread_2 = _S1213;
                }
                else
                {
                    spread_2 = _S1206;
                }
                bool _S1214 = !(spread_2 < ((&hit_1)->distance));
                if(_S1214)
                {
                    _S715 = int(2);
                    break;
                }
                if(_S1021)
                {
                    _S1026 = _S911;
                }
                else
                {
                    _S1026 = false;
                }
                if(_S1026)
                {
                    float3  _S1215 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1216 = sel_1->glow + _S1215;
                    sel_1->glow = _S1216;
                }
                else
                {
                }
                glowed_0 = _S716;
                uint b_7 = b_6 + 1U;
                float3  _S1217 = (&ray_2)->origin + make_float3 (spread_2) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1217;
                float3  _S1218 = flightWeight_0(scatter_in_0, extinction_in_0, _S1194, spread_2, true);
                float3  _S1219 = weight_1;
                float3  _S1220 = _slang_select(_S1021, _S1219,_S1218);
                float3  throughput_11 = throughput_10 * _S1220;
                uint _S1221 = stream(_S744, b_7 + 320U);
                tracking_1 = _S1221;
                weight_1 = throughput_3;
                float width_6 = width_3 + spread_1 * spread_2;
                float _S1222 = spread_1 + 3.14159274101257324f;
                if(_S911)
                {
                    _S1027 = true;
                }
                else
                {
                    bool _S1223 = b_7 == _S732;
                    if(_S1223)
                    {
                        _S1027 = !_S1021;
                    }
                    else
                    {
                        _S1027 = false;
                    }
                }
                TreeSample light_4;
                if(_S1027)
                {
                    float3  _S1224 = (&ray_2)->origin;
                    float3  _S1225 = (&ray_2)->unit_direction;
                    float3  _S1226 = (&ray_2)->unit_direction;
                    uint _S1227 = stream(_S744, b_7 + 64U);
                    float3  _S1228 = extinction_in_0;
                    float3  _S1229 = extinction_in_0;
                    uint2  _S1230 = make_uint2 (_S1192);
                    float3  _S1231 = (&ray_2)->unit_direction;
                    uint _S1232 = arrivalLobe_0(b_7, (&prev_0)->lobe);
                    FKHit _S1233 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                    FKHit _S1234 = _S1233;
                    ShadowContext _S1235 = ShadowContext_x24init_0(_S1228, _S1229, _S1230, _S1231, b_7, _S1232, false, spread_2, width_6, &_S1234, false);
                    ShadowContext _S1236 = _S1235;
                    TreeSample _S1237 = sampleLightTree_0(_S1224, _S1225, _S1226, 0.0f, true, _S1227, &_S1236);
                    light_4 = _S1237;
                }
                else
                {
                    light_4 = _S949;
                }
                uint _S1238 = (fcptMaxBounces());
                bool _S1239 = b_7 < _S1238;
                if(_S1239)
                {
                    _S1028 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1028 = false;
                }
                float _S1240 = _slang_select(_S1028, 0.07957746833562851f,0.0f);
                float3  _S1241 = throughput_11 * light_4.radiance;
                float _S1242 = powerHeuristic(light_4.density, _S1240);
                float3  _S1243 = _S1241 * make_float3 (0.07957746833562851f * _S1242);
                float3  _S1244 = _slang_select(_S1027, _S1243,_S716);
                if(replay_0)
                {
                    _S1029 = b_7 == _S732;
                }
                else
                {
                    _S1029 = false;
                }
                if(_S1029)
                {
                    bool _S1245 = _S721 == 2U;
                    if(_S1245)
                    {
                        float _S1246 = rgb_to_greyscale(_S1244);
                        _S1030 = _S1246 > 0.0f;
                    }
                    else
                    {
                        _S1030 = false;
                    }
                    if(_S1030)
                    {
                        Shift _S1247 = Shift_x24init_0(_S1244, 1.0f);
                        _S715 = int(1);
                        ended_0 = _S1247;
                        spread_2 = _S1222;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_4 = b_7;
                        break;
                    }
                    _S715 = int(1);
                    ended_0 = _S717;
                    spread_2 = _S1222;
                    width_4 = width_6;
                    throughput_8 = throughput_11;
                    b_4 = b_7;
                    break;
                }
                if(_S911)
                {
                    Reservoir candidate_8 = _S1191;
                    uint _S1248 = extractBits_0(_S1191.path, 10U, 2U);
                    bool _S1249 = _S1248 == 1U;
                    if(_S1249)
                    {
                        float3  _S1250 = safeDivide(_S1244, chain_throughput_0);
                        (&candidate_8)->radiance = _S1250;
                    }
                    else
                    {
                        uint _S1251 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                        uint _S1252 = insertBits_0(_S1251, 2U, 10U, 2U);
                        (&candidate_8)->path = _S1252;
                    }
                    Reservoir _S1253 = withEnd(candidate_8, 0U, b_7, _S1244);
                    offer(sel_1, _S1253, _S1244 * make_float3 (scale_1) / make_float3 (density_3));
                    float _S1254 = survivalProbability(throughput_11, density_3);
                    uint _S1255 = stream(_S744, b_7 + 128U);
                    Random _S1256 = pcg(_S1255);
                    bool _S1257 = _S1254 < (_S1256.value);
                    if(_S1257)
                    {
                        _S1030 = true;
                    }
                    else
                    {
                        uint _S1258 = (fcptMaxBounces());
                        _S1030 = b_7 >= _S1258;
                    }
                    if(_S1030)
                    {
                        _S715 = int(1);
                        ended_0 = _S717;
                        spread_2 = _S1222;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_4 = b_7;
                        break;
                    }
                    float _S1259 = density_3 * _S1254;
                    density_3 = _S1259;
                }
                else
                {
                }
                NEEVertex _S1260 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_2)->origin, _S716, (&ray_2)->origin);
                nee_vertex_0 = _S1260;
                uint _S1261 = stream(_S744, b_7);
                float3  _S1262 = isotropic_0(_S1261);
                (&ray_2)->unit_direction = _S1262;
                Vertex _S1263 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
                prev_0 = _S1263;
                float _S1264 = (&prev_0)->pdf;
                FKRay _S1265 = ray_2;
                FKHit _S1266 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1267 = (fcptTraverseInstanceBVH((_S1265), (true), (4.294967296e+09f), (false), (_S1266), (false)));
                hit_1 = _S1267;
                b_6 = b_7;
                throughput_10 = throughput_11;
                spread_1 = _S1222;
                width_3 = width_6;
                sky_pdf_1 = _S1264;
            }
            if(_S715 != int(2))
            {
                spread_1 = spread_2;
                width_3 = width_4;
                throughput_10 = throughput_8;
                b_6 = b_4;
                _S1025 = true;
                break;
            }
            ended_0 = _S717;
            _S1025 = false;
            break;
        }
        if(_S1025)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1026 = b_6 == b_3;
        }
        else
        {
            _S1026 = false;
        }
        bool _S1268 = ((&hit_1)->instance_index) == 4294967295U;
        if(_S1268)
        {
            bool _S1269 = !(&nee_vertex_0)->none;
            float _S1270 = _slang_select(_S1269, sky_pdf_1,0.0f);
            float _S1271 = escapeWeight_0(_S1270, (&ray_2)->unit_direction);
            float3  _S1272 = environment_0((&ray_2)->unit_direction, b_6, (&prev_0)->lobe);
            float3  _S1273 = throughput_10 * _S1272;
            if(replay_0)
            {
                bool _S1274 = b_6 == _S732;
                if(_S1274)
                {
                    passes_0 = _S721 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1273 * make_float3 (_S1271) / make_float3 (r_1->jac), density_3 / r_1->jac);
                }
                if(_S731)
                {
                    passes_0 = _S728;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_6 == _S719;
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
                    return Shift_x24init_0(_S1273 * make_float3 (_S1271), 1.0f);
                }
                return _S717;
            }
            Reservoir candidate_9 = chain_0;
            uint _S1275 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1276 = _S1275 == 1U;
            if(_S1276)
            {
                uint _S1277 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1278 = _S1277 == b_6;
                float _S1279 = _slang_select(_S1278, 1.0f,_S1271);
                float3  _S1280 = safeDivide(_S1273 * make_float3 (_S1279), chain_throughput_0);
                (&candidate_9)->radiance = _S1280;
            }
            else
            {
                bool _S1281 = (&prev_0)->rough;
                if(_S1281)
                {
                    uint _S1282 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                    uint _S1283 = insertBits_0(_S1282, 3U, 10U, 2U);
                    uint _S1284 = insertBits_0(_S1283, (&prev_0)->lobe, 15U, 3U);
                    bool _S1285 = (&prev_0)->inside;
                    uint _S1286 = _slang_select(_S1285, 1U,0U);
                    uint _S1287 = insertBits_0(_S1284, _S1286, 22U, 1U);
                    (&candidate_9)->path = _S1287;
                    (&candidate_9)->jac = (&prev_0)->pdf;
                    (&candidate_9)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1288 = _S1273 * make_float3 (_S1271);
            Reservoir _S1289 = withEnd(candidate_9, 3U, b_6, _S1288);
            offer(sel_1, _S1289, _S1288 * make_float3 (scale_1) / make_float3 (density_3));
            break;
        }
        float3  _S1290 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1290;
        bool _S1291 = (fcptVaryingUsed());
        if(_S1291)
        {
            _S1027 = filling_2 != 4294967295U;
        }
        else
        {
            _S1027 = false;
        }
        if(_S1027)
        {
            if(_S911)
            {
                float3  _S1292 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1293 = sel_1->glow + _S1292;
                sel_1->glow = _S1293;
            }
            float3  _S1294 = throughput_10 * weight_1;
            throughput_8 = _S1294;
        }
        else
        {
            float3  _S1295 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
            float3  _S1296 = throughput_10 * _S1295;
            throughput_8 = _S1296;
        }
        float _S1297 = width_3 + spread_1 * (&hit_1)->distance;
        viewed_0 = _S1026;
        width_2 = _S1297;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_0 = spread_1;
        uint _S1183 = b_6 + 1U;
        b_3 = _S1183;
        layer_0 = _S1182;
    }
    return _S717;
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
    Random _S1298 = pcg(state_3);
    Random _S1299 = pcg(_S1298.state);
    float _S1300 = 6.28318548202514648f * _S1298.value;
    float _S1301 = (F32_sqrt((-2.0f * clamp_0((F32_log((_S1299.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1299.state, _S1301 * (F32_cos((_S1300))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1302;
    (&_S1302)->state = state_4;
    (&_S1302)->value = value_2;
    return _S1302;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1303 = normal_distribution(state_5);
    Random _S1304 = normal_distribution(_S1303.state);
    Random _S1305 = normal_distribution(_S1304.state);
    float3  _S1306 = make_float3 (_S1303.value, _S1304.value, _S1305.value);
    float3  _S1307 = ((((_S1306)) * make_float3(rnorm3df(((_S1306)).x, ((_S1306)).y, ((_S1306)).z))));
    return RandomSphere_x24init_0(_S1305.state, _S1307);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_13)
{
    float3  _S1308 = p1_0 - p0_0;
    float3  _S1309 = p2_0 - p0_0;
    float2  _S1310 = uv1_0 - uv0_0;
    float2  _S1311 = uv2_0 - uv0_0;
    float _S1312 = _S1310.x;
    float _S1313 = _S1311.y;
    float _S1314 = _S1310.y;
    float _S1315 = _S1311.x;
    float _S1316 = _S1312 * _S1313 - _S1314 * _S1315;
    float _S1317 = 1.0f / _S1316;
    float3  t_1 = (_S1308 * make_float3 (_S1313) - _S1309 * make_float3 (_S1314)) * make_float3 (_S1317);
    float3  _S1318 = (_S1309 * make_float3 (_S1312) - _S1308 * make_float3 (_S1315)) * make_float3 (_S1317);
    float3  _S1319 = t_1 - n_13 * make_float3 (dot_0(n_13, t_1));
    float3  _S1320 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_13);
    bool _S1321 = (dot_0(_S1319, _S1319)) > 0.0f;
    float3  _S1322 = _slang_select(_S1321, _S1319,_S1320);
    float3  _S1323 = ((((_S1322)) * make_float3(rnorm3df(((_S1322)).x, ((_S1322)).y, ((_S1322)).z))));
    bool _S1324 = (dot_0(cross_0(n_13, _S1323), _S1318)) > 0.0f;
    float3  t_2;
    if(_S1324)
    {
        float3  _S1325 = negate_0(_S1323);
        t_2 = _S1325;
    }
    else
    {
        t_2 = _S1323;
    }
    float3  _S1326 = cross_0(n_13, t_2);
    return makeMatrix<float, 3, 3> (t_2, _S1326, n_13);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_0)
{
    float3  _S1327 = t1_0 - t0_0;
    float3  _S1328 = t2_2 - t0_0;
    float3  _S1329 = t2_2 - t1_0;
    float _S1330 = (F32_min((length_0(_S1327)), ((F32_min((length_0(_S1328)), (length_0(_S1329)))))));
    float3  _S1331 = make_float3 (distance_3(position_0, t0_0), distance_3(position_0, t1_0), distance_3(position_0, t2_2));
    float3  _S1332 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1333 = dot_0(geometry_n_4, _S1332);
    float3  _S1334 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1335 = dot_0(geometry_n_4, _S1334);
    float3  _S1336 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1337 = acos_0(abs_0(make_float3 (_S1333, _S1335, dot_0(geometry_n_4, _S1336))));
    float3  _S1338 = clamp_1(tan_0(_S1337), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_0(dot_0(_S1331 * _S1338, uvw_0), 0.0f, _S1330 * 0.125f);
}

__device__ float3  straightThrough(BSDFMaterial material_21)
{
    return make_float3 (material_21.transmission * (1.0f - material_21.metallic)) * material_21.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_3, float3  out_dir_3, uint p_5, float w_2, float alpha_17, uint nt_0)
{
    uint _S1339 = p_5 % 4U;
    float _S1340 = w_2 * HAIR_WIDTHS_0[_S1339];
    float _S1341 = (F32_asin((clamp_0(dot_0(out_dir_3, t_3), -1.0f, 1.0f)))) - (F32_asin((clamp_0(dot_0(in_dir_11, t_3), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1339] * alpha_17;
    return ((F32_asinh((_S1341 / _S1340))) / (F32_asinh((3.14159274101257324f / _S1340))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_4, float3  out_dir_4, uint np_0)
{
    float3  _S1342 = worldToTangent(out_dir_4, t_4);
    float3  _S1343 = worldToTangent(in_dir_12, t_4);
    return (F32_frac((((F32_atan2((_S1342.z), (_S1342.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1343.z), (1.17549435082228751e-38f - _S1343.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_5, uint p_6, float row_0, float column_0, float w_3, float alpha_18, uint nt_1, uint np_1)
{
    float3  _S1344 = worldToTangent(in_dir_13, t_5);
    uint _S1345 = p_6 % 4U;
    float _S1346 = w_3 * HAIR_WIDTHS_0[_S1345];
    float _S1347 = (F32_asin((clamp_0(dot_0(in_dir_13, t_5), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1345] * alpha_18 + _S1346 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1346))))));
    float _S1348 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1344.z), (1.17549435082228751e-38f - _S1344.x)));
    float _S1349 = (F32_cos((_S1347)));
    float3  _S1350 = tangentToWorld(make_float3 (_S1349 * (F32_cos((_S1348))), (F32_sin((_S1347))), _S1349 * (F32_sin((_S1348)))), t_5);
    return _S1350;
}

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_3, float3  end_1)
{
    float _S1351 = sign_0(dot_0(light_n_0, start_3 - end_1));
    return light_n_0 * make_float3 (_S1351 * light_offset_0);
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_14, BSDFMaterial material_22, float coverage_1)
{
    float3  _S1352;
    if((material_22.ior) == 1.0f)
    {
        float3  _S1353 = straightThrough(material_22);
        _S1352 = _S1353;
    }
    else
    {
        _S1352 = make_float3 (0.0f);
    }
    return _S1352 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ void offerShifted(Selection * sel_2, Reservoir r_2, Shift shifted_0, float mis_0)
{
    Reservoir candidate_10 = r_2;
    float3  _S1354 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_10)->f = _S1354;
    float _S1355 = r_2.jac * shifted_0.jac;
    (&candidate_10)->jac = _S1355;
    offer(sel_2, candidate_10, make_float3 (mis_0) * shifted_0.f * make_float3 (r_2.w));
    return;
}

__device__ Reservoir finalize(Selection sel_3, float c_1)
{
    Reservoir r_3 = sel_3.r;
    float _S1356 = rgb_to_greyscale((&r_3)->f);
    float _S1357 = sel_3.w_sum / _S1356;
    bool _S1358 = _S1356 > 0.0f;
    float _S1359 = _slang_select(_S1358, _S1357,0.0f);
    (&r_3)->w = _S1359;
    (&r_3)->c = c_1;
    return r_3;
}

__device__ Shift walk_hook(Domain dom_1, Reservoir r_4, bool replay_1, float scale_2, Selection * sel_4)
{
    Domain _S1360 = dom_1;
    Reservoir _S1361 = r_4;
    Shift _S1362 = walk_0(&_S1360, &_S1361, replay_1, scale_2, sel_4);
    return _S1362;
}

#undef Matrix
