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

static __device__ float3  negate_0(float3  x_7)
{
    return - x_7;
}

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

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S152;
    (&_S152)->on = on_0;
    (&_S152)->albedo = albedo_0;
    return _S152;
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
    SheenProfile _S153 = SheenProfile_x24init_0(false, 0.0f);
    float _S154 = rgb_to_greyscale(material_1.sheen);
    bool _S155 = _S154 > 0.0f;
    SheenProfile profile_0;
    if(_S155)
    {
        float _S156 = clamp_0((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S157 = (U32_min((uint(_S156)), (22U)));
        float _S158 = (F32_sqrt((0.05000000074505806f)));
        float _S159 = (clamp_0((F32_sqrt(((F32_max((material_1.sheen_roughness), (0.0f)))))), _S158, 1.0f) - _S158) / (1.0f - _S158) * 23.0f;
        uint _S160 = (U32_min((uint(_S159)), (22U)));
        uint _S161 = _S157 * 24U + _S160;
        float _S162 = _S156 - float(_S157);
        float _S163 = _S159 - float(_S160);
        uint _S164 = _S161 + 24U;
        float _S165 = SHEEN_ALBEDO_0[_S161] + (SHEEN_ALBEDO_0[_S164] - SHEEN_ALBEDO_0[_S161]) * _S162;
        uint _S166 = _S161 + 1U;
        float _S167 = SHEEN_ALBEDO_0[_S166] + (SHEEN_ALBEDO_0[_S164 + 1U] - SHEEN_ALBEDO_0[_S166]) * _S162;
        SheenProfile _S168 = SheenProfile_x24init_0(true, (F32_exp((_S165 + (_S167 - _S165) * _S163))));
        profile_0 = _S168;
    }
    else
    {
        profile_0 = _S153;
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
    BSDFLobes _S169;
    (&_S169)->v_dot_h = v_dot_h_0;
    (&_S169)->n_dot_h = n_dot_h_0;
    (&_S169)->refracted = refracted_1;
    (&_S169)->F = F_0;
    (&_S169)->F_greyscale = F_greyscale_0;
    (&_S169)->reflect_weight = reflect_weight_0;
    (&_S169)->diffuse_weight = diffuse_weight_0;
    (&_S169)->refract_weight = refract_weight_0;
    (&_S169)->p_diffuse = p_diffuse_0;
    (&_S169)->p_reflect = p_reflect_0;
    (&_S169)->p_refract = p_refract_0;
    (&_S169)->translucent_share = translucent_share_0;
    (&_S169)->sheen = sheen_0;
    (&_S169)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S169)->view = view_0;
    (&_S169)->tangent = tangent_1;
    (&_S169)->alphas = alphas_1;
    (&_S169)->visible = visible_0;
    return _S169;
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
    float3  _S170 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S171 = ((((_S170)) * make_float3(rnorm3df(((_S170)).x, ((_S170)).y, ((_S170)).z))));
    float _S172 = _S171.x;
    float _S173 = _S171.y;
    float _S174 = _S172 * _S172 + _S173 * _S173;
    float3  _S175;
    if(_S174 > 0.0f)
    {
        float3  _S176 = make_float3 (- _S173, _S172, 0.0f);
        float _S177 = (rsqrtf((_S174)));
        _S175 = _S176 * make_float3 (_S177);
    }
    else
    {
        _S175 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S178 = cross_0(_S171, _S175);
    float _S179 = (F32_sqrt((U1_0)));
    float _S180 = 6.28318548202514648f * U2_0;
    float _S181 = _S179 * (F32_cos((_S180)));
    float t2_0 = _S179 * (F32_sin((_S180)));
    float _S182 = 0.5f * (1.0f + _S171.z);
    float t2_1 = (1.0f - _S182) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S181 * _S181)))))) + _S182 * t2_0;
    float3  _S183 = make_float3 (_S181) * _S175 + make_float3 (t2_1) * _S178;
    float _S184 = unshared_0(_S181);
    float _S185 = unshared_0(_S181);
    float3  _S186 = _S183 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S184 * _S185 - t2_1 * t2_1))))))) * _S171;
    float3  _S187 = make_float3 (alpha_0 * _S186.x, alpha_0 * _S186.y, (F32_max((0.0f), (_S186.z))));
    float3  _S188 = ((((_S187)) * make_float3(rnorm3df(((_S187)).x, ((_S187)).y, ((_S187)).z))));
    return _S188;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_3)
{
    float3  a_2 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S189 = (F32_abs((dot_0(n_3, a_2)))) > 0.9999847412109375f;
    float3  a_3;
    if(_S189)
    {
        float3  _S190 = make_float3 (1.0f, 0.0f, 0.0f);
        a_3 = _S190;
    }
    else
    {
        a_3 = a_2;
    }
    float3  _S191 = cross_0(n_3, a_3);
    float3  _S192 = ((((_S191)) * make_float3(rnorm3df(((_S191)).x, ((_S191)).y, ((_S191)).z))));
    float3  _S193 = cross_0(n_3, _S192);
    return make_float3 (dot_0(v_2, _S192), dot_0(v_2, n_3), dot_0(v_2, _S193));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_0, uint * random_state_1)
{
    Random _S194 = pcg(*random_state_1);
    Random _S195 = pcg(_S194.state);
    *random_state_1 = _S195.state;
    float _S196 = frame_0.alphas.x;
    bool _S197 = _S196 > 0.0f;
    if(_S197)
    {
        float3  _S198 = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        float _S199 = frame_0.alphas.y;
        float3  _S200 = make_float3 (_S196 * _S198.x, _S199 * _S198.y, _S198.z);
        float3  _S201 = ((((_S200)) * make_float3(rnorm3df(((_S200)).x, ((_S200)).y, ((_S200)).z))));
        float3  _S202 = sampleGGXVNDF(_S201, 1.0f, _S194.value, _S195.value);
        float3  _S203 = make_float3 (_S196 * _S202.x, _S199 * _S202.y, _S202.z);
        float3  _S204 = ((((_S203)) * make_float3(rnorm3df(((_S203)).x, ((_S203)).y, ((_S203)).z))));
        return make_float3 (_S204.x) * frame_0.tangent + make_float3 (_S204.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S204.z) * n_i_2;
    }
    float3  _S205 = worldToTangent(v_3, n_i_2);
    float3  _S206 = sampleGGXVNDF(float3 {_S205.x, _S205.z, _S205.y}, alpha_1, _S194.value, _S195.value);
    float3  _S207 = float3 {_S206.x, _S206.z, _S206.y};
    float3  _S208 = tangentToWorld(_S207, n_i_2);
    return _S208;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_4, BSDFMaterial material_2, uint random_state_2, AnisotropicFrame frame_1)
{
    uint state_3 = random_state_2;
    float3  _S209 = negate_0(in_dir_0);
    float _S210 = sign_0(dot_0(n_4, _S209));
    float _S211 = material_2.roughness;
    float3  _S212 = sampleHalfVector(_S209, n_4 * make_float3 (_S210), _S211 * _S211, frame_1, &state_3);
    return _S212;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_5, float eta_i_0, float eta_o_0)
{
    float3  _S213 = negate_0(in_dir_1);
    float3  _S214 = negate_0(make_float3 (eta_i_0) * _S213 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S215 = ((((_S214)) * make_float3(rnorm3df(((_S214)).x, ((_S214)).y, ((_S214)).z))));
    float _S216 = sign_0(dot_0(n_5, _S213));
    float _S217 = sign_0(dot_0(_S214, n_5 * make_float3 (_S216)));
    return _S215 * make_float3 (_S217);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S218 = negate_0(in_dir_2);
    float3  _S219 = _S218 + out_dir_1;
    float3  _S220 = ((((_S219)) * make_float3(rnorm3df(((_S219)).x, ((_S219)).y, ((_S219)).z))));
    return _S220;
}

static __device__ float3  refract_0(float3  i_1, float3  n_6, float eta_0)
{
    float _S221 = dot_0(n_6, i_1);
    float _S222 = 1.0f - eta_0 * eta_0 * (1.0f - _S221 * _S221);
    if(_S222 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_1 - make_float3 (eta_0 * _S221 + (F32_sqrt((_S222)))) * n_6;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S223 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S224 = eta_i_1 / eta_o_1 * _S223;
    bool _S225 = _S224 < 1.0f;
    float kr_0;
    if(_S225)
    {
        float _S226 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S224 * _S224))))));
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

static __device__ float freeFlight_0(float u_1, float sigma_0)
{
    return - (F32_log((1.0f - u_1))) / sigma_0;
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

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_1, float distance_1, bool scatters_0)
{
    float3  _S563 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_1));
    float3  _S564 = scatter_0 * _S563 / make_float3 (sigma_1);
    float3  _S565 = _slang_select(scatters_0, _S564,_S563);
    return _S565;
}

static __device__ bool scatterSampled_0(bool replay_0, uint b_1, uint stop_0, bool varying_0)
{
    bool _S566 = !replay_0;
    bool _S567;
    if(_S566)
    {
        _S567 = true;
    }
    else
    {
        bool _S568 = b_1 == stop_0;
        if(_S568)
        {
            _S567 = !varying_0;
        }
        else
        {
            _S567 = false;
        }
    }
    return _S567;
}

static __device__ uint arrivalLobe_0(uint b_2, uint prev_lobe_0)
{
    bool _S569 = b_2 > 0U;
    uint _S570 = _slang_select(_S569, prev_lobe_0,3U);
    return _S570;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_5, float length_2, float width_0, FKHit * own_0, bool fiber_0)
{
    ShadowContext _S571;
    (&_S571)->extinction_behind = extinction_behind_0;
    (&_S571)->extinction_front = extinction_front_0;
    (&_S571)->fillings = fillings_0;
    (&_S571)->side = side_0;
    (&_S571)->depth = depth_1;
    (&_S571)->lobe = lobe_2;
    (&_S571)->surface = surface_5;
    (&_S571)->length = length_2;
    (&_S571)->width = width_0;
    (&_S571)->own = *own_0;
    (&_S571)->fiber = fiber_0;
    return _S571;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S572 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S572)
    {
        return 0.07957746833562851f;
    }
    float _S573 = g_0 * g_0;
    return (1.0f - _S573) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S573 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_5, float3  b_3)
{
    float3  _S574 = a_5 / b_3;
    float3  _S575 = make_float3 (0.0f);
    bool3  _S576 = b_3 == _S575;
    float3  _S577 = _slang_select(_S576, _S575,_S574);
    return _S577;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S578 = (1U << count_2) - 1U;
    return (e_2 & (~(_S578 << offset_1))) | ((newbits_0 & _S578) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_0, uint end_type_0, uint end_0, float3  f_4)
{
    Reservoir candidate_0 = r_0;
    uint _S579 = insertBits_0(r_0.path, end_0, 0U, 5U);
    uint _S580 = insertBits_0(_S579, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S580;
    (&candidate_0)->f = f_4;
    return candidate_0;
}

__device__ void offer(Selection * sel_0, Reservoir candidate_1, float3  weight_0)
{
    float _S581 = rgb_to_greyscale(weight_0);
    bool _S582 = _S581 > 0.0f;
    bool _S583;
    if(_S582)
    {
        _S583 = _S581 < 3.00000000549775576e+38f;
    }
    else
    {
        _S583 = false;
    }
    bool _S584 = !_S583;
    if(_S584)
    {
        return;
    }
    bool _S585 = sel_0->sums;
    if(_S585)
    {
        float3  _S586 = sel_0->color + weight_0;
        sel_0->color = _S586;
        return;
    }
    float _S587 = sel_0->w_sum + _S581;
    sel_0->w_sum = _S587;
    float3  _S588 = sel_0->color + weight_0;
    sel_0->color = _S588;
    Random _S589 = pcg(sel_0->random_state);
    sel_0->random_state = _S589.state;
    bool _S590 = (_S589.value * sel_0->w_sum) <= _S581;
    if(_S590)
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
    Random _S591 = pcg(random_state_8);
    Random _S592 = pcg(_S591.state);
    float _S593 = 1.0f - 2.0f * _S591.value;
    float _S594 = (F32_sqrt(((F32_max((1.0f - _S593 * _S593), (0.0f))))));
    float _S595 = 6.28318548202514648f * _S592.value;
    return make_float3 (_S594 * (F32_cos((_S595))), _S594 * (F32_sin((_S595))), _S593);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_9, float * pdf_5)
{
    bool _S596 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S596)
    {
        *pdf_5 = 0.07957746833562851f;
        float3  _S597 = isotropic_0(random_state_9);
        return _S597;
    }
    Random _S598 = pcg(random_state_9);
    Random _S599 = pcg(_S598.state);
    float _S600 = g_1 * g_1;
    float _S601 = 2.0f * g_1;
    float _S602 = (1.0f - _S600) / (1.0f - g_1 + _S601 * _S598.value);
    float _S603 = clamp_0((1.0f + _S600 - _S602 * _S602) / _S601, -1.0f, 1.0f);
    float _S604 = (F32_sqrt(((F32_max((1.0f - _S603 * _S603), (0.0f))))));
    float _S605 = 6.28318548202514648f * _S599.value;
    float _S606 = phaseHG_0(g_1, _S603);
    *pdf_5 = _S606;
    float3  _S607 = tangentToWorld(make_float3 (_S604 * (F32_cos((_S605))), _S603, _S604 * (F32_sin((_S605)))), dir_9);
    float3  _S608 = ((((_S607)) * make_float3(rnorm3df(((_S607)).x, ((_S607)).y, ((_S607)).z))));
    return _S608;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_5)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2)
{
    BSDFMaterial _S609;
    (&_S609)->albedo = albedo_1;
    (&_S609)->emissive = emissive_0;
    (&_S609)->roughness = roughness_0;
    (&_S609)->metallic = metallic_0;
    (&_S609)->transmission = transmission_0;
    (&_S609)->ior = ior_0;
    (&_S609)->absorption = absorption_0;
    (&_S609)->specular_tint = specular_tint_0;
    (&_S609)->specular_level = specular_level_0;
    (&_S609)->translucent = translucent_0;
    (&_S609)->sheen = sheen_2;
    (&_S609)->sheen_roughness = sheen_roughness_0;
    (&_S609)->anisotropy = anisotropy_0;
    (&_S609)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S609)->tangent = tangent_2;
    return _S609;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S610;
    (&_S610)->scatter = scatter_1;
    (&_S610)->extinction = extinction_1;
    (&_S610)->g = g_2;
    return _S610;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_10, bool skip_0, uint random_state_10, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S611;
    (&_S611)->smooth_n = smooth_n_4;
    (&_S611)->geometry_n = geometry_n_2;
    (&_S611)->geometry_offset = geometry_offset_2;
    (&_S611)->material = *material_10;
    (&_S611)->skip = skip_0;
    (&_S611)->random_state = random_state_10;
    (&_S611)->coverage = coverage_0;
    (&_S611)->encloses = encloses_0;
    (&_S611)->volume = *volume_0;
    (&_S611)->fills = fills_0;
    (&_S611)->hair = hair_0;
    return _S611;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S612 = (&surface_6->material)->emissive;
    float3  _S613 = make_float3 (0.0f);
    bool _S614 = !top_0;
    float3  _S615 = _slang_select(_S614, _S613,_S612);
    (&(&lower_0)->material)->emissive = _S615;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_2)
{
    float _S616 = surface_7->coverage;
    bool _S617 = u_2 < _S616;
    if(_S617)
    {
        return *surface_7;
    }
    float3  _S618 = make_float3 (0.0f);
    float3  _S619 = make_float3 (1.0f);
    BSDFMaterial _S620 = Material_x24init_0(_S618, _S618, 0.0f, 0.0f, 0.0f, 0.0f, _S618, _S619, 1.0f, _S618, _S618, 0.5f, 0.0f, 0.0f, _S618);
    BSDFMaterial material_11 = _S620;
    (&material_11)->albedo = _S619;
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
    bool _S621 = transmission_1 > 0.0f;
    bool _S622;
    if(_S621)
    {
        _S622 = true;
    }
    else
    {
        _S622 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S623;
    if(_S622)
    {
        _S623 = 1.0f;
    }
    else
    {
        _S623 = -1.0f;
    }
    return _S623;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_9)
{
    return (dot_0(dir_10, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_11)
{
    float3  _S624 = surface_8->geometry_n;
    float _S625 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_11);
    FKSurface faced_0 = *surface_8;
    float3  _S626 = surface_8->smooth_n * make_float3 (_S625);
    (&faced_0)->smooth_n = _S626;
    float3  _S627 = _S624 * make_float3 (_S625);
    (&faced_0)->geometry_n = _S627;
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
    float3  _S628 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_2) * log_0(_S628));
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
    bool _S629;
    if(open_0)
    {
        _S629 = prev_rough_0;
    }
    else
    {
        _S629 = false;
    }
    if(_S629)
    {
        _S629 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S629 = false;
    }
    return _S629;
}

__device__ float2  vertexEta(BSDFMaterial material_12, float n_dot_v_0)
{
    bool _S630 = n_dot_v_0 < 0.0f;
    float _S631 = _slang_select(_S630, material_12.ior,1.0f);
    float _S632 = _slang_select(_S630, 1.0f,material_12.ior);
    return make_float2 (_S631, _S632);
}

__device__ bool neeDecision(BSDFMaterial material_13, float n_dot_v_1, float eta_i_8, float eta_o_8)
{
    float _S633 = fresnel((F32_abs((n_dot_v_1))), eta_i_8, eta_o_8);
    float3  _S634 = mix_0(make_float3 (_S633), material_13.albedo, material_13.metallic);
    float _S635 = rgb_to_greyscale(_S634);
    float _S636 = (F32_max(((1.0f - _S635) * (1.0f - material_13.metallic) * (1.0f - material_13.transmission)), (0.0f)));
    bool _S637 = _S636 > 0.03999999910593033f;
    bool _S638;
    if(_S637)
    {
        _S638 = true;
    }
    else
    {
        _S638 = (material_13.roughness) > 0.20000000298023224f;
    }
    return _S638;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_14)
{
    float _S639 = rgb_to_greyscale(material_14->translucent);
    return _S639 > 0.0f;
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
    MediumSides _S640;
    (&_S640)->behind = *behind_0;
    (&_S640)->front = *front_0;
    (&_S640)->fillings = fillings_1;
    (&_S640)->face = face_1;
    return _S640;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S641 = surface_9->geometry_n;
    MediumSides _S642 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S642;
    bool _S643 = surface_9->encloses;
    if(_S643)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S644 = (dot_0(dir_12, _S641)) > 0.0f;
        if(_S644)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_3, float length_3, float width_1, FKHit * own_1, bool fiber_1, FKMedium * outside_1)
{
    float3  _S645 = surface_10->geometry_n;
    ShadowContext _S646 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
    bool _S647 = surface_10->encloses;
    ShadowContext context_2;
    if(_S647)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S648 = - _S645;
        float3  _S649 = _slang_select(turned_0, _S648,_S645);
        (&faced_1)->geometry_n = _S649;
        FKMedium _S650 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S651 = faced_1;
        FKMedium _S652 = _S650;
        MediumSides _S653 = mediumSides_0(&_S651, &_S652, filling_1, dir_13, outside_1);
        ShadowContext _S654 = ShadowContext_x24init_0(_S653.behind.extinction, _S653.front.extinction, _S653.fillings, _S645, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
        if(turned_0)
        {
            uint2  _S655 = _S653.fillings;
            ShadowContext _S656 = ShadowContext_x24init_0(_S653.front.extinction, _S653.behind.extinction, uint2 {_S655.y, _S655.x}, _S645, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
            context_2 = _S656;
        }
        else
        {
            context_2 = _S654;
        }
    }
    else
    {
        context_2 = _S646;
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

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_15, float eta_i_9, float eta_o_9, bool competing_1, uint random_state_11)
{
    float3  _S657 = light_2->dir;
    bool _S658 = (dot_0(geometry_n_4, - in_dir_8) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 4>  throughputs_1;
    FixedArray<float, 4>  pdfs_3;
    float3  _S659 = BSDF(in_dir_8, _S657, smooth_n_5, *material_15, eta_i_9, eta_o_9, _S658, random_state_11, &throughputs_1, &pdfs_3);
    bool _S660 = !competing_1;
    bool _S661;
    if(_S660)
    {
        _S661 = true;
    }
    else
    {
        _S661 = (light_2->density) == 0.0f;
    }
    if(_S661)
    {
        return _S659 * light_2->radiance;
    }
    float3  _S662 = make_float3 (0.0f);
    uint i_15 = 0U;
    float3  weighted_0 = _S662;
    for(;;)
    {
        if(i_15 < 4U)
        {
        }
        else
        {
            break;
        }
        bool _S663 = (pdfs_3[i_15]) > 0.0f;
        if(_S663)
        {
            float _S664 = light_2->density;
            float _S665 = pdfs_3[i_15] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_15] * make_float3 (pdfs_3[i_15]) / make_float3 (_S664 * (1.0f + _S665 * _S665));
            weighted_0 = weighted_1;
        }
        uint i_16 = i_15 + 1U;
        i_15 = i_16;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_12, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S666;
    (&_S666)->unit_direction = unit_direction_1;
    (&_S666)->throughput = throughput_1;
    (&_S666)->random_state = random_state_12;
    (&_S666)->refracted = refracted_3;
    (&_S666)->lobe = lobe_4;
    (&_S666)->pdf = pdf_6;
    return _S666;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_8, float n_i_dot_v_5, float alpha_13, BSDFMaterial material_16, BSDFLobes lobes_9, float eta_i_10, float eta_o_10, uint random_state_13)
{
    float3  _S667 = make_float3 (1.0f);
    SampleBSDF _S668 = SampleBSDF_x24init_0(_S667, _S667, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S668;
    Random _S669 = pcg(random_state_13);
    Random _S670 = pcg(_S669.state);
    (&sample_1)->random_state = _S670.state;
    float _S671 = _S669.value;
    float _S672 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S671 * _S671))))));
    float _S673 = 6.28318548202514648f * _S670.value;
    float3  _S674 = tangentToWorld(make_float3 (_S672 * (F32_cos((_S673))), _S669.value, _S672 * (F32_sin((_S673)))), n_i_8);
    (&sample_1)->unit_direction = _S674;
    (&sample_1)->lobe = 4U;
    float3  _S675 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_8, alpha_13, material_16, lobes_9);
    (&sample_1)->throughput = _S675;
    float _S676 = sheenVelvetPDF(_S669.value, 0.0f, n_i_dot_v_5, alpha_13, lobes_9, eta_i_10, eta_o_10);
    (&sample_1)->pdf = _S676;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S677 = (F32_sqrt((random_1_0)));
    float _S678 = 6.28318548202514648f * random_2_0;
    float _S679 = _S677 * (F32_cos((_S678)));
    float _S680 = _S677 * (F32_sin((_S678)));
    float _S681 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S679 * _S679 - _S680 * _S680))))));
    return make_float3 (_S679, _S681, _S680);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_9, float n_i_dot_v_6, float alpha_14, BSDFMaterial material_17, BSDFLobes lobes_10, float eta_i_11, float eta_o_11, uint random_state_14)
{
    float3  _S682 = make_float3 (1.0f);
    SampleBSDF _S683 = SampleBSDF_x24init_0(_S682, _S682, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S683;
    Random _S684 = pcg(random_state_14);
    Random _S685 = pcg(_S684.state);
    (&sample_2)->random_state = _S685.state;
    float3  _S686 = sampleCosWeightedHemisphere(_S684.value, _S685.value);
    bool _S687 = u_3 < (lobes_10.p_diffuse * lobes_10.translucent_share);
    float _S688 = _S686.y;
    float _S689 = - _S688;
    float _S690 = _slang_select(_S687, _S689,_S688);
    float3  _S691 = tangentToWorld(make_float3 (_S686.x, _S690, _S686.z), n_i_9);
    (&sample_2)->unit_direction = _S691;
    (&sample_2)->refracted = _S687;
    (&sample_2)->lobe = 0U;
    float3  _S692 = diffuseBSDF((&sample_2)->unit_direction, n_i_9, alpha_14, material_17, lobes_10);
    (&sample_2)->throughput = _S692;
    float _S693 = diffusePDF(_S690, 0.0f, n_i_dot_v_6, alpha_14, lobes_10, eta_i_11, eta_o_11);
    (&sample_2)->pdf = _S693;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_10, float n_i_dot_v_7, float alpha_15, BSDFMaterial material_18, BSDFLobes lobes_11, float eta_i_12, float eta_o_12, uint random_state_15)
{
    float3  _S694 = make_float3 (1.0f);
    SampleBSDF _S695 = SampleBSDF_x24init_0(_S694, _S694, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S695;
    (&sample_3)->unit_direction = lobes_11.refracted;
    (&sample_3)->random_state = random_state_15;
    (&sample_3)->refracted = true;
    (&sample_3)->lobe = 1U;
    float3  _S696 = refractBSDF((&sample_3)->unit_direction, n_i_10, alpha_15, material_18, lobes_11);
    (&sample_3)->throughput = _S696;
    float _S697 = refractPDF(0.0f, dot_0((&sample_3)->unit_direction, ggx_n_3), n_i_dot_v_7, alpha_15, lobes_11, eta_i_12, eta_o_12);
    (&sample_3)->pdf = _S697;
    return sample_3;
}

static __device__ float3  reflect_0(float3  i_17, float3  n_10)
{
    return i_17 - make_float3 (2.0f * dot_0(n_10, i_17)) * n_10;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_11, float n_i_dot_v_8, float alpha_16, BSDFMaterial material_19, BSDFLobes lobes_12, float eta_i_13, float eta_o_13, uint random_state_16)
{
    float3  _S698 = make_float3 (1.0f);
    SampleBSDF _S699 = SampleBSDF_x24init_0(_S698, _S698, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S699;
    float3  _S700 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S701 = ((((_S700)) * make_float3(rnorm3df(((_S700)).x, ((_S700)).y, ((_S700)).z))));
    (&sample_4)->unit_direction = _S701;
    (&sample_4)->random_state = random_state_16;
    (&sample_4)->lobe = 2U;
    float3  _S702 = reflectBSDF((&sample_4)->unit_direction, n_i_11, alpha_16, material_19, lobes_12);
    (&sample_4)->throughput = _S702;
    float _S703 = reflectPDF(0.0f, 0.0f, n_i_dot_v_8, alpha_16, lobes_12, eta_i_13, eta_o_13);
    (&sample_4)->pdf = _S703;
    return sample_4;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_11, BSDFMaterial material_20, float eta_i_14, float eta_o_14, uint random_init_0, float2  screen_space_0)
{
    uint random_state_17 = random_init_0;
    float3  _S704 = negate_0(in_dir_10);
    float _S705 = dot_0(n_11, _S704);
    float _S706 = sign_0(_S705);
    float3  n_i_12 = n_11 * make_float3 (_S706);
    float _S707 = (F32_abs((_S705)));
    float _S708 = material_20.roughness;
    float _S709 = _S708 * _S708;
    AnisotropicFrame _S710 = anisotropicFrame(material_20, n_i_12);
    SheenProfile _S711 = sheenProfile(_S704, n_i_12, material_20);
    float3  _S712 = sampleHalfVector(_S704, n_i_12, _S709, _S710, &random_state_17);
    BSDFLobes _S713 = bsdfLobes(in_dir_10, _S704, n_i_12, _S712, material_20, eta_i_14, eta_o_14, _S710, _S711);
    BSDFLobes lobes_13 = _S713;
    float _S714 = translucentShare(material_20);
    (&lobes_13)->translucent_share = _S714;
    Random _S715 = pcg(random_state_17);
    random_state_17 = _S715.state;
    bool _S716 = (_S715.value) < ((&lobes_13)->p_sheen_velvet);
    if(_S716)
    {
        SampleBSDF _S717 = sheenVelvetSample(n_i_12, _S707, _S709, material_20, lobes_13, eta_i_14, eta_o_14, random_state_17);
        return _S717;
    }
    float _S718 = _S715.value - (&lobes_13)->p_sheen_velvet;
    bool _S719 = _S718 < ((&lobes_13)->p_diffuse);
    if(_S719)
    {
        SampleBSDF _S720 = diffuseSample(_S718, n_i_12, _S707, _S709, material_20, lobes_13, eta_i_14, eta_o_14, random_state_17);
        return _S720;
    }
    bool _S721 = _S718 < ((&lobes_13)->p_diffuse + (&lobes_13)->p_refract);
    if(_S721)
    {
        SampleBSDF _S722 = refractSample(_S712, n_i_12, _S707, _S709, material_20, lobes_13, eta_i_14, eta_o_14, random_state_17);
        return _S722;
    }
    SampleBSDF _S723 = reflectSample(in_dir_10, _S712, n_i_12, _S707, _S709, material_20, lobes_13, eta_i_14, eta_o_14, random_state_17);
    return _S723;
}

__device__ bool withinInverseFootprint(float pdf_7, bool diffuse_0, float prev_cos_0, float distance_4, float threshold_1)
{
    bool _S724 = pdf_7 > 0.0f;
    bool _S725;
    if(_S724)
    {
        if(diffuse_0)
        {
            _S725 = true;
        }
        else
        {
            _S725 = (pdf_7 * prev_cos_0 / (distance_4 * distance_4) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S725 = false;
    }
    return _S725;
}

__device__ bool roughLobe(float pdf_8, bool diffuse_1, float roughness_1)
{
    bool _S726 = pdf_8 > 0.0f;
    bool _S727;
    if(_S726)
    {
        if(diffuse_1)
        {
            _S727 = true;
        }
        else
        {
            _S727 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S727 = false;
    }
    return _S727;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S728 = layers_0 > 1U;
    bool _S729;
    if(_S728)
    {
        _S729 = refracting_0 != passed_0;
    }
    else
    {
        _S729 = false;
    }
    return _S729;
}

static __device__ float widened_0(float spread_0, float pdf_9, bool delta_0)
{
    float _S730 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_9))))), (3.14159274101257324f)));
    bool _S731 = !delta_0;
    float _S732 = _slang_select(_S731, _S730,0.0f);
    return spread_0 + _S732;
}

static __device__ bool boundsVolume_0(FKSurface * surface_11)
{
    return surface_11->encloses;
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
    bool is_inside_6;
    bool viewed_0;
    bool _S733;
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
    int _S734;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_3;
    float sky_pdf_1;
    float spread_3;
    float width_4;
    uint b_5;
    float3  _S735 = make_float3 (0.0f);
    Shift _S736 = Shift_x24init_0(_S735, 0.0f);
    uint _S737 = r_1->path;
    uint _S738 = extractBits_0(r_1->path, 0U, 5U);
    uint _S739 = extractBits_0(_S737, 5U, 5U);
    uint _S740 = extractBits_0(_S737, 10U, 2U);
    uint _S741 = extractBits_0(_S737, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S742 = _S741 >= 3U;
        uint _S743 = _slang_select(_S742, 1U,0U);
        uint _S744 = _S738 + _S743;
        uint _S745 = (fcptMaxBounces());
        passes_0 = _S744 > _S745;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S736;
    }
    uint _S746 = _S739 - 1U;
    bool _S747 = _S741 == 3U;
    uint _S748 = _slang_select(_S747, 1U,0U);
    uint _S749 = _S738 + _S748;
    bool _S750 = _S740 == 0U;
    uint _S751 = _slang_select(_S750, _S749,_S746);
    FKHit _S752 = (fcptReservoirHit((*r_1)));
    float3  _S753 = dom_0->x0;
    float3  _S754 = dom_0->x1 - dom_0->x0;
    float3  _S755 = ((((_S754)) * make_float3(rnorm3df(((_S754)).x, ((_S754)).y, ((_S754)).z))));
    FKRay _S756 = Ray_x24init_0(dom_0->x1, _S755);
    FKRay ray_2 = _S756;
    FKHit hit_1 = dom_0->hit;
    float3  scatter_in_0 = _S735;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S735;
    float3  extinction_in_0 = _S735;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S757 = dom_0->spread;
    float _S758 = dom_0->width;
    float _S759 = length_0(_S754);
    NEEVertex _S760 = NEEVertex_x24init_0(true, 0.0f, _S735, _S735, _S735);
    NEEVertex nee_vertex_0 = _S760;
    Vertex _S761 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S761;
    Reservoir _S762 = (Reservoir{});
    Reservoir chain_0 = _S762;
    uint _S763 = r_1->seed;
    (&chain_0)->seed = r_1->seed;
    (&ray_2)->origin = _S753;
    (&hit_1)->distance = _S759;
    FKMedium _S764 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_1)->distance), (&filling_2)));
    uint _S765 = filling_2;
    bool _S766 = (fcptVaryingUsed());
    uint _S767 = _slang_select(_S766, _S765,4294967295U);
    filling_2 = _S767;
    scatter_in_0 = _S764.scatter;
    extinction_in_0 = _S764.extinction;
    g_in_0 = _S764.g;
    Reservoir _S768 = chain_0;
    uint _S769 = filling_2;
    for(;;)
    {
        bool _S770 = (fcptVaryingUsed());
        if(_S770)
        {
            passes_0 = _S769 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S771 = (fcptMajorant((_S769)));
            spread_1 = _S771;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S751;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S740 == 1U;
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
            ended_0 = _S736;
            sky_pdf_0 = 0.0f;
            spread_1 = _S757;
            width_2 = _S758;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_4 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S772 = (&prev_0)->rough;
        if(_S772)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S773 = stream(_S763, 384U);
        uint tracking_0 = _S773;
        weight_1 = throughput_3;
        glowed_0 = _S735;
        b_4 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_2 = _S757;
        width_2 = _S758;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_1)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S734 = int(1);
                break;
            }
            uint _S774 = b_4 + 320U;
            bool _S775 = b_4 == 4294967295U;
            uint _S776 = _slang_select(_S775, 384U,_S774);
            uint _S777 = stream(_S763, _S776);
            Random _S778 = pcg(_S777);
            float _S779 = freeFlight_0(_S778.value, spread_1);
            if(passes_0)
            {
                float3  _S780 = (&ray_2)->origin;
                float3  _S781 = (&ray_2)->unit_direction;
                float _S782 = (&hit_1)->distance;
                uint _S783 = _slang_select(_S775, 0U,b_4);
                uint _S784 = (&prev_0)->lobe;
                uint _S785 = _slang_select(_S775, 3U,_S784);
                float _S786 = (fcptTrackMedium((_S769), (_S780), (_S781), (_S782), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S783), (_S785), (_S775)));
                geometry_density_2 = _S786;
            }
            else
            {
                geometry_density_2 = _S779;
            }
            bool _S787 = !(geometry_density_2 < ((&hit_1)->distance));
            if(_S787)
            {
                _S734 = int(1);
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
                float3  _S788 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S789 = sel_1->glow + _S788;
                sel_1->glow = _S789;
            }
            else
            {
            }
            glowed_0 = _S735;
            uint b_6 = b_4 + 1U;
            float3  _S790 = (&ray_2)->origin + make_float3 (geometry_density_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S790;
            float3  _S791 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, geometry_density_2, true);
            float3  _S792 = weight_1;
            float3  _S793 = _slang_select(passes_0, _S792,_S791);
            float3  throughput_4 = throughput_2 * _S793;
            uint _S794 = stream(_S763, b_6 + 320U);
            tracking_0 = _S794;
            weight_1 = throughput_3;
            float width_5 = width_2 + threshold_2 * geometry_density_2;
            float _S795 = threshold_2 + 3.14159274101257324f;
            bool _S796 = scatterSampled_0(replay_1, b_6, _S751, passes_0);
            TreeSample _S797 = TreeSample_x24init_0(_S735, _S735, 0.0f, 0U);
            if(_S796)
            {
                float3  _S798 = (&ray_2)->origin;
                float3  _S799 = (&ray_2)->unit_direction;
                float3  _S800 = (&ray_2)->unit_direction;
                uint _S801 = stream(_S763, b_6 + 64U);
                float3  _S802 = extinction_in_0;
                float3  _S803 = extinction_in_0;
                uint2  _S804 = make_uint2 (_S769);
                float3  _S805 = (&ray_2)->unit_direction;
                uint _S806 = arrivalLobe_0(b_6, (&prev_0)->lobe);
                FKHit _S807 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S808 = _S807;
                ShadowContext _S809 = ShadowContext_x24init_0(_S802, _S803, _S804, _S805, b_6, _S806, false, geometry_density_2, width_5, &_S808, false);
                ShadowContext _S810 = _S809;
                TreeSample _S811 = sampleLightTree_0(_S798, _S799, _S800, 0.0f, true, _S801, &_S810);
                light_3 = _S811;
            }
            else
            {
                light_3 = _S797;
            }
            float _S812 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S813 = (fcptMaxBounces());
            bool _S814 = b_6 < _S813;
            if(_S814)
            {
                is_inside_6 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_6 = false;
            }
            float _S815 = _slang_select(is_inside_6, _S812,0.0f);
            float3  _S816 = throughput_4 * light_3.radiance;
            float _S817 = powerHeuristic(light_3.density, _S815);
            float3  _S818 = _S816 * make_float3 (_S812 * _S817);
            float3  _S819 = _slang_select(_S796, _S818,_S735);
            if(replay_1)
            {
                viewed_0 = b_6 == _S751;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S820 = _S740 == 2U;
                if(_S820)
                {
                    float _S821 = rgb_to_greyscale(_S819);
                    passes_0 = _S821 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S822 = Shift_x24init_0(_S819, 1.0f);
                    _S734 = int(0);
                    ended_0 = _S822;
                    spread_1 = _S795;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                _S734 = int(0);
                ended_0 = _S736;
                spread_1 = _S795;
                geometry_density_2 = width_5;
                chain_throughput_0 = throughput_4;
                layer_0 = b_6;
                break;
            }
            bool _S823 = !replay_1;
            if(_S823)
            {
                Reservoir candidate_2 = _S768;
                uint _S824 = extractBits_0(_S768.path, 10U, 2U);
                bool _S825 = _S824 == 1U;
                if(_S825)
                {
                    float3  _S826 = safeDivide(_S819, _S735);
                    (&candidate_2)->radiance = _S826;
                }
                else
                {
                    uint _S827 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                    uint _S828 = insertBits_0(_S827, 2U, 10U, 2U);
                    (&candidate_2)->path = _S828;
                }
                Reservoir _S829 = withEnd(candidate_2, 0U, b_6, _S819);
                offer(sel_1, _S829, _S819 * make_float3 (scale_1) / make_float3 (density_2));
                float _S830 = survivalProbability(throughput_4, density_2);
                uint _S831 = stream(_S763, b_6 + 128U);
                Random _S832 = pcg(_S831);
                bool _S833 = _S830 < (_S832.value);
                if(_S833)
                {
                    _S733 = true;
                }
                else
                {
                    uint _S834 = (fcptMaxBounces());
                    _S733 = b_6 >= _S834;
                }
                if(_S733)
                {
                    _S734 = int(0);
                    ended_0 = _S736;
                    spread_1 = _S795;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                float _S835 = density_2 * _S830;
                density_2 = _S835;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S836 = stream(_S763, b_6);
            float3  _S837 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S836, &phase_pdf_0);
            (&ray_2)->unit_direction = _S837;
            NEEVertex _S838 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S735, (&ray_2)->origin);
            nee_vertex_0 = _S838;
            Vertex _S839 = scatteredVertex_0(false);
            prev_0 = _S839;
            float _S840 = (&prev_0)->pdf;
            FKRay _S841 = ray_2;
            FKHit _S842 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S843 = (fcptTraverseInstanceBVH((_S841), (true), (4.294967296e+09f), (false), (_S842), (false)));
            hit_1 = _S843;
            b_4 = b_6;
            throughput_2 = throughput_4;
            threshold_2 = _S795;
            width_2 = width_5;
            sky_pdf_0 = _S840;
        }
        if(_S734 != int(1))
        {
            width_2 = geometry_density_2;
            throughput_2 = chain_throughput_0;
            b_4 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S736;
        spread_1 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S844 = b_4 == 4294967295U;
    bool _S845 = ((&hit_1)->instance_index) == 4294967295U;
    if(_S845)
    {
        bool _S846 = !(&nee_vertex_0)->none;
        float _S847 = _slang_select(_S846, sky_pdf_0,0.0f);
        float _S848 = escapeWeight_0(_S847, (&ray_2)->unit_direction);
        float3  _S849 = environment_0((&ray_2)->unit_direction, b_4, (&prev_0)->lobe);
        float3  _S850 = throughput_2 * _S849;
        if(replay_1)
        {
            bool _S851 = b_4 == _S751;
            if(_S851)
            {
                passes_0 = _S740 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S850 * make_float3 (_S848) / make_float3 (r_1->jac), density_2 / r_1->jac);
            }
            if(_S750)
            {
                passes_0 = _S747;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_4 == _S738;
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
                return Shift_x24init_0(_S850 * make_float3 (_S848), 1.0f);
            }
            return _S736;
        }
        Reservoir candidate_3 = chain_0;
        uint _S852 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S853 = _S852 == 1U;
        if(_S853)
        {
            uint _S854 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S855 = _S854 == b_4;
            float _S856 = _slang_select(_S855, 1.0f,_S848);
            float3  _S857 = safeDivide(_S850 * make_float3 (_S856), _S735);
            (&candidate_3)->radiance = _S857;
        }
        else
        {
            bool _S858 = (&prev_0)->rough;
            if(_S858)
            {
                uint _S859 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                uint _S860 = insertBits_0(_S859, 3U, 10U, 2U);
                uint _S861 = insertBits_0(_S860, (&prev_0)->lobe, 15U, 3U);
                bool _S862 = (&prev_0)->inside;
                uint _S863 = _slang_select(_S862, 1U,0U);
                uint _S864 = insertBits_0(_S861, _S863, 22U, 1U);
                (&candidate_3)->path = _S864;
                (&candidate_3)->jac = (&prev_0)->pdf;
                (&candidate_3)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S865 = _S850 * make_float3 (_S848);
        Reservoir _S866 = withEnd(candidate_3, 3U, b_4, _S865);
        offer(sel_1, _S866, _S865 * make_float3 (scale_1) / make_float3 (density_2));
        return _S736;
    }
    float3  _S867 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S867;
    bool _S868 = (fcptVaryingUsed());
    if(_S868)
    {
        passes_0 = filling_2 != 4294967295U;
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
            float3  _S870 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S871 = sel_1->glow + _S870;
            sel_1->glow = _S871;
        }
        float3  _S872 = throughput_2 * weight_1;
        throughput_2 = _S872;
    }
    else
    {
        float3  _S873 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
        float3  _S874 = throughput_2 * _S873;
        throughput_2 = _S874;
    }
    float _S875 = width_2 + spread_1 * (&hit_1)->distance;
    uint _S876 = b_4 + 1U;
    b_4 = _S876;
    layer_0 = 0U;
    width_2 = _S875;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_6 = false;
    chain_throughput_0 = _S735;
    float3  reconnection_0 = _S735;
    viewed_0 = _S844;
    for(;;)
    {
        bool _S877 = ((&hit_1)->is_point_light) == 1U;
        if(replay_1)
        {
            _S733 = _S740 == 1U;
        }
        else
        {
            _S733 = false;
        }
        bool _S878;
        if(_S733)
        {
            _S878 = b_4 == _S739;
        }
        else
        {
            _S878 = false;
        }
        bool _S879;
        if(_S878)
        {
            bool _S880 = ((&hit_1)->instance_index) != (_S752.instance_index);
            if(_S880)
            {
                _S879 = true;
            }
            else
            {
                _S879 = ((&hit_1)->triangle_index) != (_S752.triangle_index);
            }
        }
        else
        {
            _S879 = false;
        }
        if(_S879)
        {
            return _S736;
        }
        FKMedium _S881 = Medium_x24init_0(_S735, _S735, 0.0f);
        BSDFMaterial _S882 = Material_x24init_0(_S735, _S735, 0.0f, 0.0f, 0.0f, 0.0f, _S735, throughput_3, 1.0f, _S735, _S735, 0.5f, 0.0f, 0.0f, _S735);
        FKMedium _S883 = _S881;
        FKSurface _S884 = Surface_x24init_0(_S735, _S735, 0.0f, &_S882, false, 0U, 1.0f, false, &_S883, 4294967295U, _S735);
        bool _S885 = !_S877;
        bool scatter_2;
        bool is_inside_7;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S885)
        {
            uint _S886 = stream(_S763, b_4);
            uint _S887 = arrivalLobe_0(b_4, (&prev_0)->lobe);
            FKSurface _S888 = (fcptSurfaceAtPath((hit_1), ((&ray_2)->origin), (_S886), (width_2), (layer_0), (b_4), (_S887), ((&ray_2)->unit_direction)));
            bool _S889 = !passes_0;
            FKSurface _S890 = _S888;
            FKSurface _S891 = emitting_0(&_S890, _S889);
            uint _S892 = stream(_S763, b_4 + 256U);
            Random _S893 = pcg(_S892);
            FKSurface _S894 = _S891;
            FKSurface _S895 = uncovered_0(&_S894, _S893.value);
            float _S896 = facingSign(_S895.material.transmission, _S895.geometry_n, (&ray_2)->unit_direction);
            bool _S897 = _S896 < 0.0f;
            bool _S898 = (_S895.material.transmission) > 0.0f;
            if(_S898)
            {
                bool _S899 = arrivesBehind_0((&ray_2)->unit_direction, _S895.geometry_n);
                scatter_2 = _S899;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S900 = _S895;
            FKSurface _S901 = facingRay_0(&_S900, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S902 = arrivesBehind_0((&ray_2)->unit_direction, _S901.geometry_n);
                is_inside_7 = _S902;
            }
            else
            {
                is_inside_7 = scatter_2;
            }
            if(is_inside_7)
            {
                float3  _S903 = beerLambert((&hit_1)->distance, _S901.material.absorption);
                float3  _S904 = throughput_2 * _S903;
                throughput_5 = _S904;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S905 = !_S901.skip;
            float geometry_density_3 = geometryDensity(_S901.geometry_n, (&ray_2)->unit_direction, (&hit_1)->distance);
            bool _S906 = b_4 == _S876;
            if(_S906)
            {
                float _S907 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S907;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S908 = geometry_density_2;
            scatter_2 = _S905;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S908;
            surface_12 = _S901;
            turned_1 = _S897;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_12 = _S884;
            throughput_5 = throughput_2;
            is_inside_7 = is_inside_6;
        }
        bool _S909 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S910 = surface_12;
        FKSurface _S911 = surface_12;
        float _S912 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        float2  _S913 = vertexEta(_S910.material, _S912);
        bool _S914;
        if(scatter_2)
        {
            bool _S915 = neeDecision(_S910.material, _S912, _S913.x, _S913.y);
            _S914 = _S915;
        }
        else
        {
            _S914 = false;
        }
        bool _S916;
        if(passes_0)
        {
            _S916 = true;
        }
        else
        {
            _S916 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S916)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S914;
        }
        bool _S917 = (fcptHairUsed());
        bool _S918;
        if(_S917)
        {
            float3  _S919 = surface_12.hair;
            _S918 = (dot_0(_S919, _S919)) > 0.0f;
        }
        else
        {
            _S918 = false;
        }
        bool _S920;
        if(_S918)
        {
            _S920 = true;
        }
        else
        {
            BSDFMaterial _S921 = _S910.material;
            bool _S922 = isTranslucent_0(&_S921);
            _S920 = _S922;
        }
        bool _S923;
        if(_S920)
        {
            _S923 = true;
        }
        else
        {
            bool _S924 = (_S910.material.transmission) > 0.0f;
            if(_S924)
            {
                uint _S925 = (fcptLayers((hit_1)));
                _S923 = _S925 == 1U;
            }
            else
            {
                _S923 = false;
            }
        }
        float3  emission_0;
        if(_S877)
        {
            float3  _S926 = (fcptCalculatePointLightContrib(((&hit_1)->instance_index)));
            emission_0 = _S926;
        }
        else
        {
            emission_0 = _S910.material.emissive;
        }
        bool _S927 = !replay_1;
        bool _S928;
        if(_S927)
        {
            _S928 = true;
        }
        else
        {
            _S928 = b_4 >= _S751;
        }
        bool _S929;
        if(_S928)
        {
            float _S930 = rgb_to_greyscale(emission_0);
            _S929 = _S930 > 0.0f;
        }
        else
        {
            _S929 = false;
        }
        float3  emission_1;
        if(_S929)
        {
            NEEVertex _S931 = nee_vertex_0;
            FKHit _S932 = hit_1;
            float _S933 = emissionWeight_0(&_S931, &_S932, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S933);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S934;
        if(replay_1)
        {
            _S934 = _S740 == 1U;
        }
        else
        {
            _S934 = false;
        }
        bool _S935;
        if(_S934)
        {
            _S935 = b_4 > _S739;
        }
        else
        {
            _S935 = false;
        }
        bool _S936;
        if(_S935)
        {
            _S936 = b_4 == _S738;
        }
        else
        {
            _S936 = false;
        }
        bool _S937;
        if(_S936)
        {
            bool _S938 = _S741 == 1U;
            if(_S938)
            {
                _S937 = true;
            }
            else
            {
                _S937 = _S741 == 2U;
            }
        }
        else
        {
            _S937 = false;
        }
        if(_S937)
        {
            bool _S939 = _S877 != (_S741 == 2U);
            if(_S939)
            {
                return _S736;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_1->jac), density_2 / r_1->jac);
        }
        uint _S940 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S941 = _S940 == 1U;
        Reservoir here_0 = chain_0;
        uint _S942 = insertBits_0(0U, b_4, 5U, 5U);
        uint _S943 = insertBits_0(_S942, 1U, 10U, 2U);
        uint _S944 = insertBits_0(_S943, (&prev_0)->lobe, 15U, 3U);
        bool _S945 = (&prev_0)->inside;
        uint _S946 = _slang_select(_S945, 1U,0U);
        uint _S947 = insertBits_0(_S944, _S946, 22U, 1U);
        (&here_0)->path = _S947;
        float _S948 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S948;
        fcptWithReservoirHit((&here_0), (&hit_1));
        bool _S949;
        if(replay_1)
        {
            _S949 = _S740 == 1U;
        }
        else
        {
            _S949 = false;
        }
        bool _S950;
        if(_S949)
        {
            _S950 = b_4 == _S739;
        }
        else
        {
            _S950 = false;
        }
        bool _S951 = b_4 == _S751;
        bool _S952;
        if(_S951)
        {
            bool _S953 = !scatter_2;
            if(_S953)
            {
                _S952 = true;
            }
            else
            {
                bool _S954 = _S740 != 1U;
                if(_S954)
                {
                    _S952 = _S740 != 3U;
                }
                else
                {
                    _S952 = false;
                }
            }
        }
        else
        {
            _S952 = false;
        }
        bool _S955;
        if(_S952)
        {
            _S955 = _S740 == 2U;
        }
        else
        {
            _S955 = false;
        }
        bool _S956;
        if(_S955)
        {
            _S956 = !_S909;
        }
        else
        {
            _S956 = false;
        }
        bool _S957;
        if(_S956)
        {
            _S957 = _S741 != 4U;
        }
        else
        {
            _S957 = false;
        }
        bool _S958 = _S739 == _S738;
        bool _S959;
        if(_S958)
        {
            _S959 = _S741 == 0U;
        }
        else
        {
            _S959 = false;
        }
        bool _S960;
        if(_S959)
        {
            _S960 = ((&hit_1)->instance_index) == (_S752.instance_index);
        }
        else
        {
            _S960 = false;
        }
        bool _S961;
        if(_S960)
        {
            _S961 = ((&hit_1)->triangle_index) == (_S752.triangle_index);
        }
        else
        {
            _S961 = false;
        }
        bool _S962;
        if(_S961)
        {
            _S962 = _S909;
        }
        else
        {
            _S962 = false;
        }
        bool _S963 = _slang_select(_S950, _S962,_S957);
        bool _S964;
        if(nee_0)
        {
            _S964 = _slang_select(replay_1, _S963,scatter_2);
        }
        else
        {
            _S964 = false;
        }
        TreeSample _S965 = TreeSample_x24init_0(_S735, _S735, 0.0f, 0U);
        float3  throughput_6;
        float3  lit_0;
        if(_S964)
        {
            float3  _S966 = (&ray_2)->origin;
            if(_S918)
            {
                throughput_6 = _S735;
            }
            else
            {
                throughput_6 = _S911.smooth_n;
            }
            FKSurface _S967 = surface_12;
            uint _S968 = stream(_S763, b_4 + 64U);
            uint _S969 = arrivalLobe_0(b_4, (&prev_0)->lobe);
            FKMedium _S970 = (fcptOutsideMedium((hit_1)));
            FKSurface _S971 = surface_12;
            FKHit _S972 = hit_1;
            FKMedium _S973 = _S970;
            ShadowContext _S974 = shadowContext_0(&_S971, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_4, _S969, (&hit_1)->distance, width_2, &_S972, _S918, &_S973);
            ShadowContext _S975 = _S974;
            TreeSample _S976 = sampleLightTree_0(_S966, throughput_6, surface_12.geometry_n, surface_12.geometry_offset, _S923, _S968, &_S975);
            bool _S977 = any_0((_S976.radiance) != _S735);
            if(_S977)
            {
                if(_S918)
                {
                    uint _S978 = (fcptMaxBounces());
                    bool _S979 = b_4 < _S978;
                    FKSurface _S980 = surface_12;
                    TreeSample _S981 = _S976;
                    float3  _S982 = hairLight_0(&_S980, (&ray_2)->unit_direction, &_S981, _S979);
                    lit_0 = _S982;
                }
                else
                {
                    float _S983 = _S913.x;
                    float _S984 = _S913.y;
                    uint _S985 = (fcptMaxBounces());
                    bool _S986 = b_4 < _S985;
                    TreeSample _S987 = _S976;
                    BSDFMaterial _S988 = _S910.material;
                    float3  _S989 = lightBSDF_0((&ray_2)->unit_direction, &_S987, _S911.smooth_n, _S967.geometry_n, &_S988, _S983, _S984, _S986, surface_12.random_state);
                    lit_0 = _S989;
                }
            }
            else
            {
                lit_0 = _S735;
            }
            light_3 = _S976;
        }
        else
        {
            light_3 = _S965;
            lit_0 = _S735;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S990;
        bool _S991;
        float density_4;
        if(_S950)
        {
            bool _S992 = !_S909;
            if(_S992)
            {
                return _S736;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S958)
            {
                viewed_1 = _S741 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            if(_S958)
            {
                refracted_4 = _S741 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S993 = !nee_0;
                if(_S993)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S994 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S994 > 0.0f);
                }
                if(passes_0)
                {
                    return _S736;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            if(_S958)
            {
                wrong_side_0 = _S741 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S995 = !nee_0;
                if(_S995)
                {
                    return _S736;
                }
                float _S996 = environmentPdf_0(r_1->dir);
                float3  _S997 = skyBSDF((&ray_2)->unit_direction, r_1->dir, surface_12, _S913, is_inside_7, _S996, surface_12.random_state);
                return Shift_x24init_0(throughput_7 * _S997 * r_1->radiance / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            uint _S998 = extractBits_0(_S737, 21U, 1U);
            bool _S999 = nee_0 != (_S998 == 1U);
            if(_S999)
            {
                return _S736;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S951;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1000 = !scatter_2;
                if(_S1000)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1001 = _S740 != 1U;
                    if(_S1001)
                    {
                        refracted_4 = _S740 != 3U;
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
                bool _S1002 = _S740 == 2U;
                if(_S1002)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S909;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S741 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    uint _S1003 = stream(_S763, b_4 + 448U);
                    FKRay _S1004 = ray_2;
                    FKSurface _S1005 = surface_12;
                    SkySample _S1006 = sampleSky_0(&_S1004, &_S1005, _S913, is_inside_7, _S1003, surface_12.random_state);
                    return Shift_x24init_0(throughput_5 * _S1006.color, 1.0f);
                }
                if(_S1002)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S909;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1007 = rgb_to_greyscale(light_3.radiance);
                    bool _S1008 = !(_S1007 > 0.0f);
                    if(_S1008)
                    {
                        return _S736;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S750)
                {
                    passes_0 = _S741 == 2U;
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
                if(_S750)
                {
                    passes_0 = _S741 == 1U;
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
                    passes_0 = !_S909;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S736;
            }
            else
            {
                if(_S927)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1009 = b_4 > 0U;
                    if(_S1009)
                    {
                        Reservoir candidate_4 = chain_0;
                        if(_S941)
                        {
                            float3  _S1010 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_4)->radiance = _S1010;
                        }
                        else
                        {
                            if(_S909)
                            {
                                candidate_4 = here_0;
                            }
                        }
                        float3  _S1011 = throughput_5 * emission_1;
                        Reservoir _S1012 = withEnd(candidate_4, 1U, b_4, _S1011);
                        offer(sel_1, _S1012, _S1011 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1013 = throughput_5 * emission_1;
                        float3  _S1014 = sel_1->glow + _S1013;
                        sel_1->glow = _S1014;
                    }
                    if(nee_0)
                    {
                        float3  _S1015 = throughput_5 * lit_0;
                        Reservoir candidate_5 = chain_0;
                        if(_S941)
                        {
                            float3  _S1016 = safeDivide(_S1015, chain_throughput_0);
                            (&candidate_5)->radiance = _S1016;
                        }
                        else
                        {
                            if(_S909)
                            {
                                candidate_5 = here_0;
                                uint _S1017 = insertBits_0((&candidate_5)->path, 1U, 21U, 1U);
                                (&candidate_5)->path = _S1017;
                                (&candidate_5)->dir = light_3.dir;
                                (&candidate_5)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1018 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S1019 = insertBits_0(_S1018, 2U, 10U, 2U);
                                (&candidate_5)->path = _S1019;
                            }
                        }
                        Reservoir _S1020 = withEnd(candidate_5, 0U, b_4, _S1015);
                        offer(sel_1, _S1020, _S1015 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S918)
                        {
                            _S990 = false;
                        }
                        else
                        {
                            bool _S1021 = environmentMapped_0();
                            _S990 = _S1021;
                        }
                    }
                    else
                    {
                        _S990 = false;
                    }
                    if(_S990)
                    {
                        uint _S1022 = (fcptMaxBounces());
                        _S991 = b_4 < _S1022;
                    }
                    else
                    {
                        _S991 = false;
                    }
                    if(_S991)
                    {
                        uint _S1023 = stream(_S763, b_4 + 448U);
                        FKRay _S1024 = ray_2;
                        FKSurface _S1025 = surface_12;
                        SkySample _S1026 = sampleSky_0(&_S1024, &_S1025, _S913, is_inside_7, _S1023, surface_12.random_state);
                        float3  _S1027 = throughput_5 * _S1026.color;
                        Reservoir candidate_6 = chain_0;
                        if(_S941)
                        {
                            float3  _S1028 = safeDivide(_S1027, chain_throughput_0);
                            (&candidate_6)->radiance = _S1028;
                        }
                        else
                        {
                            if(_S909)
                            {
                                candidate_6 = here_0;
                                uint _S1029 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1029;
                                (&candidate_6)->dir = _S1026.dir;
                                (&candidate_6)->radiance = _S1026.radiance;
                            }
                            else
                            {
                                uint _S1030 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S1031 = insertBits_0(_S1030, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1031;
                            }
                        }
                        Reservoir _S1032 = withEnd(candidate_6, 4U, b_4, _S1027);
                        offer(sel_1, _S1032, _S1027 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1033;
        bool _S1034;
        bool straight_0;
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
                viewed_1 = _S951;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1048 = extractBits_0(_S737, 15U, 3U);
            uint _S1049 = extractBits_0(_S737, 18U, 3U);
            uint _S1050 = _slang_select(_S950, _S1049,_S1048);
            float3  _S1051 = r_1->dir;
            bool refracted_5 = _S1050 == 1U;
            SampleBSDF _S1052 = SampleBSDF_x24init_0(_S735, _S735, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1052;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1053 = extractBits_0(_S737, 22U, 1U);
                bool _S1054 = is_inside_7 != (_S1053 == 1U);
                if(_S1054)
                {
                    return _S736;
                }
                bool _S1055 = _S740 == 1U;
                if(_S1055)
                {
                    float3  _S1056 = (fcptHitPosition((_S752)));
                    throughput_8 = _S1056;
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
                    BSDFMaterial _S1057 = _S910.material;
                    bool _S1058 = isTranslucent_0(&_S1057);
                    if(_S1058)
                    {
                        refracted_4 = _S1050 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1059 = throughput_8 - (&ray_2)->origin;
                        float3  _S1060 = _slang_select(_S1055, _S1059,_S1051);
                        wrong_side_0 = (dot_0(_S911.smooth_n, _S1060) * _S912) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1055)
                {
                    float3  _S1061 = (&ray_2)->origin;
                    FKSurface _S1062 = surface_12;
                    float3  _S1063 = - _S911.smooth_n;
                    bool _S1064 = is_inside_7 != refracted_4;
                    float3  _S1065 = _slang_select(_S1064, _S1063,_S911.smooth_n);
                    float3  _S1066 = throughput_8 - (_S1061 + make_float3 (_S1062.geometry_offset) * _S1065);
                    float3  _S1067 = ((((_S1066)) * make_float3(rnorm3df(((_S1066)).x, ((_S1066)).y, ((_S1066)).z))));
                    reconnection_1 = _S1067;
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
                    bool _S1068 = wrongSide_0(is_inside_7, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1068;
                }
                if(wrong_side_0)
                {
                    return _S736;
                }
                float3  _S1069 = throughput_8;
                throughput_8 = reconnection_1;
                b_7 = _S1050;
                wrong_side_0 = false;
                reconnection_1 = _S1069;
            }
            else
            {
                bool _S1070 = !_S950;
                if(_S1070)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1071;
                    if(_S918)
                    {
                        SampleBSDF _S1072 = (fcptSampleHair((surface_12.hair), (_S910.material.albedo), (_S910.material.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1071 = _S1072;
                    }
                    else
                    {
                        SampleBSDF _S1073 = sampleBSDF((&ray_2)->unit_direction, _S911.smooth_n, _S910.material, _S913.x, _S913.y, surface_12.random_state, make_float2 (0.0f));
                        _S1071 = _S1073;
                    }
                    bsdf_sampled_0 = _S1071;
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
                            return _S736;
                        }
                        break;
                    }
                    if(_S918)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1074 = wrongSide_0(is_inside_7, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1074;
                    }
                    if(wrong_side_0)
                    {
                        _S990 = (_S910.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S990 = false;
                    }
                    if(_S990)
                    {
                        SampleBSDF _S1075 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S910.material, _S913.x, _S913.y, (&bsdf_sampled_0)->random_state, make_float2 (0.0f));
                        (&bsdf_sampled_0)->unit_direction = _S1075.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1075.refracted;
                        (&bsdf_sampled_0)->throughput = _S1075.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1076 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1076;
                        }
                    }
                    uint _S1077 = (&bsdf_sampled_0)->lobe;
                    float3  _S1078 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1079 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1080 = (&bsdf_sampled_0)->pdf;
                    float _S1081 = _slang_select(wrong_side_0, 0.0f,_S1080);
                    (&lobe_5)->pdf = _S1081;
                    throughput_8 = _S1078;
                    b_7 = _S1077;
                    refracted_4 = _S1079;
                }
                else
                {
                    throughput_8 = _S1051;
                    b_7 = _S1050;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S990 = true;
            }
            else
            {
                _S990 = _S950;
            }
            float3  chain_throughput_1;
            if(_S990)
            {
                if(_S918)
                {
                    SampleBSDF _S1082 = (fcptConnectHair((surface_12.hair), (_S910.material.albedo), (_S910.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    lobe_5 = _S1082;
                }
                else
                {
                    float3  _S1083 = (&ray_2)->unit_direction;
                    float _S1084 = sign_0(_S912);
                    float3  _S1085 = _S911.smooth_n * make_float3 (_S1084);
                    float _S1086 = dot_0(_S1085, throughput_8);
                    float _S1087 = _S910.material.roughness;
                    float _S1088 = _S1087 * _S1087;
                    AnisotropicFrame _S1089 = anisotropicFrame(_S910.material, _S1085);
                    float3  _S1090 = negate_0(_S1083);
                    SheenProfile _S1091 = sheenProfile(_S1090, _S1085, _S910.material);
                    float3  _S1092 = reflectedHalf(_S1083, throughput_8);
                    bool _S1093 = b_7 == 1U;
                    if(_S1093)
                    {
                        float3  _S1094 = refractedHalf(_S1083, throughput_8, _S911.smooth_n, _S913.x, _S913.y);
                        throughput_9 = _S1094;
                    }
                    else
                    {
                        throughput_9 = _S1092;
                    }
                    bool _S1095 = b_7 == 0U;
                    if(_S1095)
                    {
                        float3  _S1096 = sampledHalf(_S1083, _S911.smooth_n, _S910.material, surface_12.random_state, _S1089);
                        throughput_10 = _S1096;
                    }
                    else
                    {
                        throughput_10 = throughput_9;
                    }
                    float3  _S1097 = negate_0(_S1083);
                    float _S1098 = _S913.x;
                    float _S1099 = _S913.y;
                    BSDFLobes _S1100 = bsdfLobes(_S1083, _S1097, _S1085, throughput_10, _S910.material, _S1098, _S1099, _S1089, _S1091);
                    BSDFLobes lobe_terms_1 = _S1100;
                    float _S1101 = translucentShare(_S910.material);
                    (&lobe_terms_1)->translucent_share = _S1101;
                    switch(b_7)
                    {
                    case 0U:
                        {
                            float _S1102 = diffusePDF(_S1086, 0.0f, (F32_abs((_S912))), _S1088, lobe_terms_1, _S1098, _S1099);
                            float3  _S1103 = diffuseBSDF(throughput_8, _S1085, _S1088, _S910.material, lobe_terms_1);
                            density_6 = _S1102;
                            chain_throughput_1 = _S1103;
                            break;
                        }
                    case 1U:
                        {
                            float _S1104 = refractPDF(_S1086, dot_0(throughput_8, throughput_10), (F32_abs((_S912))), _S1088, lobe_terms_1, _S1098, _S1099);
                            float3  _S1105 = refractBSDF(throughput_8, _S1085, _S1088, _S910.material, lobe_terms_1);
                            density_6 = _S1104;
                            chain_throughput_1 = _S1105;
                            break;
                        }
                    case 4U:
                        {
                            float _S1106 = sheenVelvetPDF(_S1086, 0.0f, (F32_abs((_S912))), _S1088, lobe_terms_1, _S1098, _S1099);
                            float3  _S1107 = sheenVelvetBSDF(throughput_8, _S1085, _S1088, _S910.material, lobe_terms_1);
                            density_6 = _S1106;
                            chain_throughput_1 = _S1107;
                            break;
                        }
                    default:
                        {
                            float _S1108 = reflectPDF(_S1086, 0.0f, (F32_abs((_S912))), _S1088, lobe_terms_1, _S1098, _S1099);
                            float3  _S1109 = reflectBSDF(throughput_8, _S1085, _S1088, _S910.material, lobe_terms_1);
                            density_6 = _S1108;
                            chain_throughput_1 = _S1109;
                            break;
                        }
                    }
                    bool _S1110 = density_6 > 0.0f;
                    if(_S1110)
                    {
                        SampleBSDF _S1111 = SampleBSDF_x24init_0(throughput_8, chain_throughput_1, surface_12.random_state, _S1093, b_7, density_6);
                        lobe_5 = _S1111;
                    }
                }
            }
            bool _S1112 = b_7 == 0U;
            if(_S1112)
            {
                _S991 = true;
            }
            else
            {
                _S991 = b_7 == 4U;
            }
            if(_S918)
            {
                _S1033 = false;
            }
            else
            {
                bool _S1113 = !_S991;
                if(_S1113)
                {
                    bool _S1114 = (_S910.material.roughness) == 0.0f;
                    if(_S1114)
                    {
                        _S1033 = true;
                    }
                    else
                    {
                        bool _S1115 = b_7 == 1U;
                        if(_S1115)
                        {
                            _S1033 = (_S913.x) == (_S913.y);
                        }
                        else
                        {
                            _S1033 = false;
                        }
                    }
                }
                else
                {
                    _S1033 = false;
                }
            }
            bool _S1116 = !_S918;
            if(_S1116)
            {
                _S1034 = b_7 == 1U;
            }
            else
            {
                _S1034 = false;
            }
            if(_S1034)
            {
                straight_0 = (_S910.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1035 = _S1116;
            }
            else
            {
                _S1035 = false;
            }
            if(_S1035)
            {
                _S1036 = b_7 == 1U;
            }
            else
            {
                _S1036 = false;
            }
            if(_S1036)
            {
                _S1037 = (_S913.x) == (_S913.y);
            }
            else
            {
                _S1037 = false;
            }
            BSDFMaterial _S1117 = _S910.material;
            bool _S1118 = isTranslucent_0(&_S1117);
            if(_S1118)
            {
                _S1038 = _S1112;
            }
            else
            {
                _S1038 = false;
            }
            if(_S1038)
            {
                _S1039 = (dot_0(throughput_8, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1039 = false;
            }
            if(nee_0)
            {
                _S1040 = !_S1033;
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
                float _S1119 = (&lobe_5)->pdf;
                float3  _S1120 = (&ray_2)->origin;
                float3  _S1121 = _slang_select(_S923, _S735,_S911.smooth_n);
                float3  _S1122 = (&ray_2)->origin;
                FKSurface _S1123 = surface_12;
                float3  _S1124 = - _S911.smooth_n;
                float3  _S1125 = _slang_select(_S1039, _S1124,_S911.smooth_n);
                NEEVertex _S1126 = NEEVertex_x24init_0(false, _S1119, _S1120, _S1121, _S1122 + make_float3 (_S1123.geometry_offset) * _S1125);
                nee_vertex_0 = _S1126;
            }
            else
            {
                if(_S918)
                {
                    _S1042 = true;
                }
                else
                {
                    bool _S1127 = b_7 != 1U;
                    if(_S1127)
                    {
                        _S1042 = true;
                    }
                    else
                    {
                        _S1042 = (_S913.x) != (_S913.y);
                    }
                }
                if(_S1042)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1128 = withinInverseFootprint((&lobe_5)->pdf, _S991, (&prev_0)->cos, (&hit_1)->distance, threshold_2);
            bool _S1129 = roughLobe((&lobe_5)->pdf, _S991, _S910.material.roughness);
            if(_S950)
            {
                bool _S1130 = !_S1128;
                if(_S1130)
                {
                    return _S736;
                }
                bool _S1131 = _S741 != 1U;
                if(_S1131)
                {
                    _S1042 = _S741 != 2U;
                }
                else
                {
                    _S1042 = false;
                }
                if(_S1042)
                {
                    float _S1132 = (&lobe_5)->pdf;
                    float _S1133 = _slang_select(nee_0, _S1132,0.0f);
                    float _S1134 = escapeWeight_0(_S1133, _S1051);
                    if(_S958)
                    {
                        passes_0 = _S747;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1135 = _slang_select(passes_0, _S1134,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_1->radiance * make_float3 (_S1135) / make_float3 (r_1->jac), density_4 * (&lobe_5)->pdf / r_1->jac);
                }
                float3  _S1136 = throughput_6 * make_float3 ((&lobe_5)->pdf);
                float _S1137 = density_4 * (&lobe_5)->pdf;
                throughput_9 = _S1136;
                density_6 = _S1137;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1138 = (fcptLayers((hit_1)));
            bool _S1139 = b_7 == 1U;
            bool _S1140 = passesLayer_0(_S1138, _S1139, passes_0);
            if(viewed_1)
            {
                _S1042 = _S1140;
            }
            else
            {
                _S1042 = false;
            }
            if(_S1042)
            {
                return _S736;
            }
            if(replay_1)
            {
                _S1043 = b_4 <= _S751;
            }
            else
            {
                _S1043 = false;
            }
            if(_S1043)
            {
                _S1044 = _S909;
            }
            else
            {
                _S1044 = false;
            }
            if(_S1044)
            {
                _S1045 = _S1128;
            }
            else
            {
                _S1045 = false;
            }
            if(_S1045)
            {
                _S1046 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1046 = !_S1129;
                }
                else
                {
                    _S1046 = false;
                }
            }
            if(_S1046)
            {
                return _S736;
            }
            if(viewed_1)
            {
                float3  _S1141 = throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1142 = (&lobe_5)->pdf;
                throughput_10 = _S1141;
                sky_pdf_2 = _S1142;
            }
            else
            {
                float3  _S1143 = throughput_9 * max_0((&lobe_5)->throughput, _S735);
                throughput_10 = _S1143;
                sky_pdf_2 = density_6;
            }
            if(_S927)
            {
                _S1047 = !_S941;
            }
            else
            {
                _S1047 = false;
            }
            bool _S1144;
            if(_S1047)
            {
                _S1144 = _S909;
            }
            else
            {
                _S1144 = false;
            }
            bool _S1145;
            if(_S1144)
            {
                _S1145 = _S1128;
            }
            else
            {
                _S1145 = false;
            }
            if(_S1145)
            {
                chain_0 = here_0;
                uint _S1146 = insertBits_0((&chain_0)->path, b_7, 18U, 3U);
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
            Vertex _S1151 = Vertex_x24init_0(_S1129, b_7, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_8)))), is_inside_7);
            prev_0 = _S1151;
            float _S1152 = (&lobe_5)->pdf;
            bool _S1153;
            if(_S1139)
            {
                _S1153 = (_S913.x) == (_S913.y);
            }
            else
            {
                _S1153 = false;
            }
            float sky_pdf_3 = _slang_select(_S1153, sky_pdf_0,_S1152);
            float _S1154 = _slang_select(_S918, 0.0f,sky_pdf_3);
            float _S1155 = widened_0(spread_1, (&lobe_5)->pdf, _S1033);
            bool _S1156;
            if(refracted_4)
            {
                _S1156 = !_S1039;
            }
            else
            {
                _S1156 = false;
            }
            bool is_inside_8;
            if(_S1156)
            {
                bool _S1157 = !is_inside_7;
                is_inside_8 = _S1157;
            }
            else
            {
                is_inside_8 = is_inside_7;
            }
            FKSurface _S1158 = surface_12;
            bool _S1159 = boundsVolume_0(&_S1158);
            bool _S1160;
            if(_S1159)
            {
                _S1160 = !_S1140;
            }
            else
            {
                _S1160 = false;
            }
            if(_S1160)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1161 = - _S1150.geometry_n;
                float3  _S1162 = _slang_select(turned_1, _S1161,_S1150.geometry_n);
                (&faced_2)->geometry_n = _S1162;
                FKMedium _S1163 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1164 = (fcptOutsideMedium((hit_1)));
                FKSurface _S1165 = faced_2;
                FKMedium _S1166 = _S1163;
                FKMedium _S1167 = _S1164;
                MediumSides _S1168 = mediumSides_0(&_S1165, &_S1166, filling_2, (&ray_2)->unit_direction, &_S1167);
                bool _S1169 = leavesInFront_0((&faced_2)->geometry_n, throughput_8, _S1150.geometry_n);
                float3  _S1170 = _slang_select(_S1169, _S1168.front.scatter,_S1168.behind.scatter);
                scatter_in_0 = _S1170;
                float3  _S1171 = _slang_select(_S1169, _S1168.front.extinction,_S1168.behind.extinction);
                extinction_in_0 = _S1171;
                float _S1172 = _slang_select(_S1169, _S1168.front.g,_S1168.behind.g);
                g_in_0 = _S1172;
                uint _S1173 = _S1168.fillings.x;
                uint _S1174 = _S1168.fillings.y;
                uint _S1175 = _slang_select(_S1169, _S1174,_S1173);
                bool _S1176 = (fcptVaryingUsed());
                uint _S1177 = _slang_select(_S1176, _S1175,4294967295U);
                filling_2 = _S1177;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1178 = !_S1140;
            if(_S1178)
            {
                FKSurface _S1179 = surface_12;
                float _S1180 = _slang_select(straight_0, 0.0f,_S1179.geometry_offset);
                float3  _S1181 = - _S911.smooth_n;
                bool _S1182 = is_inside_8 != _S1039;
                float3  _S1183 = _slang_select(_S1182, _S1181,_S911.smooth_n);
                float3  _S1184 = (&ray_2)->origin + make_float3 (_S1180) * _S1183;
                (&ray_2)->origin = _S1184;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1140;
            viewed_1 = _S1037;
            sky_pdf_2 = _S1154;
            spread_4 = _S1155;
            reconnection_0 = reconnection_1;
            is_inside_6 = is_inside_8;
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
            is_inside_6 = is_inside_7;
        }
        float density_7;
        if(_S927)
        {
            if(_S877)
            {
                float3  _S1185 = throughput_9 * emission_1;
                Reservoir candidate_7 = chain_0;
                uint _S1186 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1187 = _S1186 == 1U;
                if(_S1187)
                {
                    float3  _S1188 = safeDivide(_S1185, chain_throughput_0);
                    (&candidate_7)->radiance = _S1188;
                }
                Reservoir _S1189 = withEnd(candidate_7, 2U, b_4, _S1185);
                offer(sel_1, _S1189, _S1185 * make_float3 (scale_1) / make_float3 (density_6));
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
                float _S1190 = survivalProbability(throughput_9, density_6);
                density_7 = _S1190;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1191 = stream(_S763, b_4 + 128U);
            Random _S1192 = pcg(_S1191);
            bool _S1193 = density_7 < (_S1192.value);
            if(_S1193)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1194 = (fcptMaxBounces());
                wrong_side_0 = b_4 >= _S1194;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1195 = density_6 * density_7;
            density_7 = _S1195;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1196 = layer_0 ^ 1U;
        uint _S1197 = _slang_select(passes_0, _S1196,0U);
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
            uint _S1198 = b_7 + 1U;
            b_4 = _S1198;
            layer_0 = _S1197;
            continue;
        }
        FKRay _S1199 = ray_2;
        float _S1200 = distance_5(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S951;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S740 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1201 = _slang_select(wrong_side_0, _S1200,4.294967296e+09f);
        bool _S1202 = !_S918;
        if(straight_0)
        {
            _S990 = true;
        }
        else
        {
            _S990 = _S918;
        }
        FKHit _S1203;
        if(_S990)
        {
            _S1203 = hit_1;
        }
        else
        {
            _S1203 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
        }
        FKHit _S1204 = (fcptTraverseInstanceBVH((_S1199), (_S885), (_S1201), (_S1202), (_S1203), (viewed_1)));
        hit_1 = _S1204;
        if(replay_1)
        {
            _S991 = _S951;
        }
        else
        {
            _S991 = false;
        }
        if(_S991)
        {
            _S1033 = _S740 == 1U;
        }
        else
        {
            _S1033 = false;
        }
        if(_S1033)
        {
            _S1034 = ((&hit_1)->instance_index) == (_S752.instance_index);
        }
        else
        {
            _S1034 = false;
        }
        if(_S1034)
        {
            _S1035 = ((&hit_1)->triangle_index) == (_S752.triangle_index);
        }
        else
        {
            _S1035 = false;
        }
        if(_S1035)
        {
            (&hit_1)->uv = _S752.uv;
            float _S1205 = distance_5(reconnection_0, (&ray_2)->origin);
            (&hit_1)->distance = _S1205;
        }
        if(replay_1)
        {
            _S1036 = _S951;
        }
        else
        {
            _S1036 = false;
        }
        if(_S1036)
        {
            _S1037 = _S740 == 3U;
        }
        else
        {
            _S1037 = false;
        }
        if(_S1037)
        {
            _S1038 = ((&hit_1)->instance_index) != 4294967295U;
        }
        else
        {
            _S1038 = false;
        }
        if(_S1038)
        {
            return _S736;
        }
        Reservoir _S1206 = chain_0;
        uint _S1207 = filling_2;
        for(;;)
        {
            bool _S1208 = (fcptVaryingUsed());
            if(_S1208)
            {
                _S1039 = _S1207 != 4294967295U;
            }
            else
            {
                _S1039 = false;
            }
            float _S1209;
            if(_S1039)
            {
                float _S1210 = (fcptMajorant((_S1207)));
                _S1209 = _S1210;
            }
            else
            {
                _S1209 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1040 = _S951;
            }
            else
            {
                _S1040 = false;
            }
            if(_S1040)
            {
                _S1041 = _S740 == 1U;
            }
            else
            {
                _S1041 = false;
            }
            if(_S1041)
            {
                _S1042 = _S1209 > 0.0f;
            }
            else
            {
                _S1042 = false;
            }
            if(_S1042)
            {
                ended_0 = _S736;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_3 = width_2;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_7 = b_4;
                _S1043 = true;
                break;
            }
            bool _S1211 = (&prev_0)->rough;
            if(_S1211)
            {
                _S1043 = !(_S1209 > 0.0f);
            }
            else
            {
                _S1043 = false;
            }
            (&prev_0)->rough = _S1043;
            uint _S1212 = b_4 + 320U;
            bool _S1213 = b_4 == 4294967295U;
            uint _S1214 = _slang_select(_S1213, 384U,_S1212);
            uint _S1215 = stream(_S763, _S1214);
            uint tracking_1 = _S1215;
            weight_1 = throughput_3;
            glowed_0 = _S735;
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
                    _S734 = int(2);
                    break;
                }
                uint _S1216 = b_7 + 320U;
                bool _S1217 = b_7 == 4294967295U;
                uint _S1218 = _slang_select(_S1217, 384U,_S1216);
                uint _S1219 = stream(_S763, _S1218);
                Random _S1220 = pcg(_S1219);
                float _S1221 = freeFlight_0(_S1220.value, _S1209);
                if(_S1039)
                {
                    float3  _S1222 = (&ray_2)->origin;
                    float3  _S1223 = (&ray_2)->unit_direction;
                    float _S1224 = (&hit_1)->distance;
                    uint _S1225 = _slang_select(_S1217, 0U,b_7);
                    uint _S1226 = (&prev_0)->lobe;
                    uint _S1227 = _slang_select(_S1217, 3U,_S1226);
                    float _S1228 = (fcptTrackMedium((_S1207), (_S1222), (_S1223), (_S1224), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1225), (_S1227), (_S1217)));
                    spread_3 = _S1228;
                }
                else
                {
                    spread_3 = _S1221;
                }
                bool _S1229 = !(spread_3 < ((&hit_1)->distance));
                if(_S1229)
                {
                    _S734 = int(2);
                    break;
                }
                if(_S1039)
                {
                    _S1044 = _S927;
                }
                else
                {
                    _S1044 = false;
                }
                if(_S1044)
                {
                    float3  _S1230 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1231 = sel_1->glow + _S1230;
                    sel_1->glow = _S1231;
                }
                else
                {
                }
                glowed_0 = _S735;
                uint b_8 = b_7 + 1U;
                float3  _S1232 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1232;
                float3  _S1233 = flightWeight_0(scatter_in_0, extinction_in_0, _S1209, spread_3, true);
                float3  _S1234 = weight_1;
                float3  _S1235 = _slang_select(_S1039, _S1234,_S1233);
                float3  throughput_11 = throughput_10 * _S1235;
                uint _S1236 = stream(_S763, b_8 + 320U);
                tracking_1 = _S1236;
                weight_1 = throughput_3;
                float width_6 = width_3 + spread_2 * spread_3;
                float _S1237 = spread_2 + 3.14159274101257324f;
                bool _S1238 = scatterSampled_0(replay_1, b_8, _S751, _S1039);
                TreeSample light_4;
                if(_S1238)
                {
                    float3  _S1239 = (&ray_2)->origin;
                    float3  _S1240 = (&ray_2)->unit_direction;
                    float3  _S1241 = (&ray_2)->unit_direction;
                    uint _S1242 = stream(_S763, b_8 + 64U);
                    float3  _S1243 = extinction_in_0;
                    float3  _S1244 = extinction_in_0;
                    uint2  _S1245 = make_uint2 (_S1207);
                    float3  _S1246 = (&ray_2)->unit_direction;
                    uint _S1247 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                    FKHit _S1248 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                    FKHit _S1249 = _S1248;
                    ShadowContext _S1250 = ShadowContext_x24init_0(_S1243, _S1244, _S1245, _S1246, b_8, _S1247, false, spread_3, width_6, &_S1249, false);
                    ShadowContext _S1251 = _S1250;
                    TreeSample _S1252 = sampleLightTree_0(_S1239, _S1240, _S1241, 0.0f, true, _S1242, &_S1251);
                    light_4 = _S1252;
                }
                else
                {
                    light_4 = _S965;
                }
                float _S1253 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1254 = (fcptMaxBounces());
                bool _S1255 = b_8 < _S1254;
                if(_S1255)
                {
                    _S1045 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1045 = false;
                }
                float _S1256 = _slang_select(_S1045, _S1253,0.0f);
                float3  _S1257 = throughput_11 * light_4.radiance;
                float _S1258 = powerHeuristic(light_4.density, _S1256);
                float3  _S1259 = _S1257 * make_float3 (_S1253 * _S1258);
                float3  _S1260 = _slang_select(_S1238, _S1259,_S735);
                if(replay_1)
                {
                    _S1046 = b_8 == _S751;
                }
                else
                {
                    _S1046 = false;
                }
                if(_S1046)
                {
                    bool _S1261 = _S740 == 2U;
                    if(_S1261)
                    {
                        float _S1262 = rgb_to_greyscale(_S1260);
                        _S1047 = _S1262 > 0.0f;
                    }
                    else
                    {
                        _S1047 = false;
                    }
                    if(_S1047)
                    {
                        Shift _S1263 = Shift_x24init_0(_S1260, 1.0f);
                        _S734 = int(1);
                        ended_0 = _S1263;
                        spread_3 = _S1237;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_5 = b_8;
                        break;
                    }
                    _S734 = int(1);
                    ended_0 = _S736;
                    spread_3 = _S1237;
                    width_4 = width_6;
                    throughput_8 = throughput_11;
                    b_5 = b_8;
                    break;
                }
                if(_S927)
                {
                    Reservoir candidate_8 = _S1206;
                    uint _S1264 = extractBits_0(_S1206.path, 10U, 2U);
                    bool _S1265 = _S1264 == 1U;
                    if(_S1265)
                    {
                        float3  _S1266 = safeDivide(_S1260, chain_throughput_0);
                        (&candidate_8)->radiance = _S1266;
                    }
                    else
                    {
                        uint _S1267 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                        uint _S1268 = insertBits_0(_S1267, 2U, 10U, 2U);
                        (&candidate_8)->path = _S1268;
                    }
                    Reservoir _S1269 = withEnd(candidate_8, 0U, b_8, _S1260);
                    offer(sel_1, _S1269, _S1260 * make_float3 (scale_1) / make_float3 (density_3));
                    float _S1270 = survivalProbability(throughput_11, density_3);
                    uint _S1271 = stream(_S763, b_8 + 128U);
                    Random _S1272 = pcg(_S1271);
                    bool _S1273 = _S1270 < (_S1272.value);
                    if(_S1273)
                    {
                        _S1047 = true;
                    }
                    else
                    {
                        uint _S1274 = (fcptMaxBounces());
                        _S1047 = b_8 >= _S1274;
                    }
                    if(_S1047)
                    {
                        _S734 = int(1);
                        ended_0 = _S736;
                        spread_3 = _S1237;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_5 = b_8;
                        break;
                    }
                    float _S1275 = density_3 * _S1270;
                    density_3 = _S1275;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1276 = stream(_S763, b_8);
                float3  _S1277 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1276, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1277;
                NEEVertex _S1278 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S735, (&ray_2)->origin);
                nee_vertex_0 = _S1278;
                Vertex _S1279 = scatteredVertex_0(is_inside_6);
                prev_0 = _S1279;
                float _S1280 = (&prev_0)->pdf;
                FKRay _S1281 = ray_2;
                FKHit _S1282 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1283 = (fcptTraverseInstanceBVH((_S1281), (true), (4.294967296e+09f), (false), (_S1282), (false)));
                hit_1 = _S1283;
                b_7 = b_8;
                throughput_10 = throughput_11;
                spread_2 = _S1237;
                width_3 = width_6;
                sky_pdf_1 = _S1280;
            }
            if(_S734 != int(2))
            {
                spread_2 = spread_3;
                width_3 = width_4;
                throughput_10 = throughput_8;
                b_7 = b_5;
                _S1043 = true;
                break;
            }
            ended_0 = _S736;
            _S1043 = false;
            break;
        }
        if(_S1043)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1044 = b_7 == b_4;
        }
        else
        {
            _S1044 = false;
        }
        bool _S1284 = ((&hit_1)->instance_index) == 4294967295U;
        if(_S1284)
        {
            bool _S1285 = !(&nee_vertex_0)->none;
            float _S1286 = _slang_select(_S1285, sky_pdf_1,0.0f);
            float _S1287 = escapeWeight_0(_S1286, (&ray_2)->unit_direction);
            float3  _S1288 = environment_0((&ray_2)->unit_direction, b_7, (&prev_0)->lobe);
            float3  _S1289 = throughput_10 * _S1288;
            if(replay_1)
            {
                bool _S1290 = b_7 == _S751;
                if(_S1290)
                {
                    passes_0 = _S740 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1289 * make_float3 (_S1287) / make_float3 (r_1->jac), density_3 / r_1->jac);
                }
                if(_S750)
                {
                    passes_0 = _S747;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_7 == _S738;
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
                    return Shift_x24init_0(_S1289 * make_float3 (_S1287), 1.0f);
                }
                return _S736;
            }
            Reservoir candidate_9 = chain_0;
            uint _S1291 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1292 = _S1291 == 1U;
            if(_S1292)
            {
                uint _S1293 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1294 = _S1293 == b_7;
                float _S1295 = _slang_select(_S1294, 1.0f,_S1287);
                float3  _S1296 = safeDivide(_S1289 * make_float3 (_S1295), chain_throughput_0);
                (&candidate_9)->radiance = _S1296;
            }
            else
            {
                bool _S1297 = (&prev_0)->rough;
                if(_S1297)
                {
                    uint _S1298 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                    uint _S1299 = insertBits_0(_S1298, 3U, 10U, 2U);
                    uint _S1300 = insertBits_0(_S1299, (&prev_0)->lobe, 15U, 3U);
                    bool _S1301 = (&prev_0)->inside;
                    uint _S1302 = _slang_select(_S1301, 1U,0U);
                    uint _S1303 = insertBits_0(_S1300, _S1302, 22U, 1U);
                    (&candidate_9)->path = _S1303;
                    (&candidate_9)->jac = (&prev_0)->pdf;
                    (&candidate_9)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1304 = _S1289 * make_float3 (_S1287);
            Reservoir _S1305 = withEnd(candidate_9, 3U, b_7, _S1304);
            offer(sel_1, _S1305, _S1304 * make_float3 (scale_1) / make_float3 (density_3));
            break;
        }
        float3  _S1306 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1306;
        bool _S1307 = (fcptVaryingUsed());
        if(_S1307)
        {
            _S1045 = filling_2 != 4294967295U;
        }
        else
        {
            _S1045 = false;
        }
        if(_S1045)
        {
            if(_S927)
            {
                float3  _S1308 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1309 = sel_1->glow + _S1308;
                sel_1->glow = _S1309;
            }
            float3  _S1310 = throughput_10 * weight_1;
            throughput_8 = _S1310;
        }
        else
        {
            float3  _S1311 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
            float3  _S1312 = throughput_10 * _S1311;
            throughput_8 = _S1312;
        }
        float _S1313 = width_3 + spread_2 * (&hit_1)->distance;
        viewed_0 = _S1044;
        width_2 = _S1313;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1198 = b_7 + 1U;
        b_4 = _S1198;
        layer_0 = _S1197;
    }
    return _S736;
}

static __device__ Shift shift_0(Domain * dom_1, Reservoir * r_2)
{
    Selection _S1314 = (Selection{});
    Selection sel_2 = _S1314;
    bool _S1315 = (r_2->w) <= 0.0f;
    if(_S1315)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1316 = walk_0(dom_1, r_2, true, 0.0f, &sel_2);
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

__device__ Random normal_distribution(uint state_4)
{
    Random _S1317 = pcg(state_4);
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

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S1321;
    (&_S1321)->state = state_5;
    (&_S1321)->value = value_2;
    return _S1321;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S1322 = normal_distribution(state_6);
    Random _S1323 = normal_distribution(_S1322.state);
    Random _S1324 = normal_distribution(_S1323.state);
    float3  _S1325 = make_float3 (_S1322.value, _S1323.value, _S1324.value);
    float3  _S1326 = ((((_S1325)) * make_float3(rnorm3df(((_S1325)).x, ((_S1325)).y, ((_S1325)).z))));
    return RandomSphere_x24init_0(_S1324.state, _S1326);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_12)
{
    float3  _S1327 = p1_0 - p0_0;
    float3  _S1328 = p2_0 - p0_0;
    float2  _S1329 = uv1_0 - uv0_0;
    float2  _S1330 = uv2_0 - uv0_0;
    float _S1331 = _S1329.x;
    float _S1332 = _S1330.y;
    float _S1333 = _S1329.y;
    float _S1334 = _S1330.x;
    float _S1335 = _S1331 * _S1332 - _S1333 * _S1334;
    float _S1336 = 1.0f / _S1335;
    float3  t_1 = (_S1327 * make_float3 (_S1332) - _S1328 * make_float3 (_S1333)) * make_float3 (_S1336);
    float3  _S1337 = (_S1328 * make_float3 (_S1331) - _S1327 * make_float3 (_S1334)) * make_float3 (_S1336);
    float3  _S1338 = t_1 - n_12 * make_float3 (dot_0(n_12, t_1));
    float3  t_2 = ((((_S1338)) * make_float3(rnorm3df(((_S1338)).x, ((_S1338)).y, ((_S1338)).z))));
    bool _S1339 = (dot_0(cross_0(n_12, t_2), _S1337)) > 0.0f;
    float3  t_3;
    if(_S1339)
    {
        float3  _S1340 = negate_0(t_2);
        t_3 = _S1340;
    }
    else
    {
        t_3 = t_2;
    }
    float3  _S1341 = cross_0(n_12, t_3);
    return makeMatrix<float, 3, 3> (t_3, _S1341, n_12);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1342 = t1_0 - t0_0;
    float3  _S1343 = t2_2 - t0_0;
    float3  _S1344 = t2_2 - t1_0;
    float _S1345 = (F32_min((length_0(_S1342)), ((F32_min((length_0(_S1343)), (length_0(_S1344)))))));
    float3  _S1346 = make_float3 (distance_5(position_0, t0_0), distance_5(position_0, t1_0), distance_5(position_0, t2_2));
    float3  _S1347 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1348 = dot_0(geometry_n_5, _S1347);
    float3  _S1349 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1350 = dot_0(geometry_n_5, _S1349);
    float3  _S1351 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1352 = acos_0(abs_0(make_float3 (_S1348, _S1350, dot_0(geometry_n_5, _S1351))));
    float3  _S1353 = clamp_1(tan_0(_S1352), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_0(dot_0(_S1346 * _S1353, uvw_0), 0.0f, _S1345 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_15, float3  n_13, BSDFMaterial material_21)
{
    float3  _S1354 = negate_0(dir_15);
    float _S1355 = sign_0(dot_0(n_13, _S1354));
    float3  _S1356 = n_13 * make_float3 (_S1355);
    AnisotropicFrame _S1357 = anisotropicFrame(material_21, _S1356);
    bool _S1358 = (_S1357.alphas.x) > 0.0f;
    if(_S1358)
    {
        float _S1359 = material_21.transmission * (1.0f - material_21.metallic);
        float3  _S1360 = negate_0(_S1356);
        float3  _S1361 = anisotropicLocal(dir_15, _S1357.tangent, _S1360);
        float _S1362 = anisotropicG1(_S1361, _S1357.alphas);
        return make_float3 (_S1359 * _S1362) * material_21.albedo;
    }
    float _S1363 = material_21.transmission * (1.0f - material_21.metallic);
    float _S1364 = material_21.roughness;
    float _S1365 = smithG1(_S1364 * _S1364, (F32_abs((dot_0(n_13, dir_15)))));
    return make_float3 (_S1363 * _S1365) * material_21.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_4, float3  out_dir_3, uint p_5, float w_2, float alpha_17, uint nt_0)
{
    uint _S1366 = p_5 % 4U;
    float _S1367 = w_2 * HAIR_WIDTHS_0[_S1366];
    float _S1368 = (F32_asin((clamp_0(dot_0(out_dir_3, t_4), -1.0f, 1.0f)))) - (F32_asin((clamp_0(dot_0(in_dir_11, t_4), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1366] * alpha_17;
    return ((F32_asinh((_S1368 / _S1367))) / (F32_asinh((3.14159274101257324f / _S1367))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_5, float3  out_dir_4, uint np_0)
{
    float3  _S1369 = worldToTangent(out_dir_4, t_5);
    float3  _S1370 = worldToTangent(in_dir_12, t_5);
    return (F32_frac((((F32_atan2((_S1369.z), (_S1369.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1370.z), (1.17549435082228751e-38f - _S1370.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_6, uint p_6, float row_0, float column_0, float w_3, float alpha_18, uint nt_1, uint np_1)
{
    float3  _S1371 = worldToTangent(in_dir_13, t_6);
    uint _S1372 = p_6 % 4U;
    float _S1373 = w_3 * HAIR_WIDTHS_0[_S1372];
    float _S1374 = (F32_asin((clamp_0(dot_0(in_dir_13, t_6), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1372] * alpha_18 + _S1373 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1373))))));
    float _S1375 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1371.z), (1.17549435082228751e-38f - _S1371.x)));
    float _S1376 = (F32_cos((_S1374)));
    float3  _S1377 = tangentToWorld(make_float3 (_S1376 * (F32_cos((_S1375))), (F32_sin((_S1374))), _S1376 * (F32_sin((_S1375)))), t_6);
    return _S1377;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_14, BSDFMaterial material_22, float coverage_1)
{
    float3  _S1378;
    if((material_22.ior) == 1.0f)
    {
        float3  _S1379 = straightThrough(toward_1, n_14, material_22);
        _S1378 = _S1379;
    }
    else
    {
        _S1378 = make_float3 (0.0f);
    }
    return _S1378 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_10 = r_3;
    float3  _S1380 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_10)->f = _S1380;
    float _S1381 = r_3.jac * shifted_0.jac;
    (&candidate_10)->jac = _S1381;
    offer(sel_3, candidate_10, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S1382 = rgb_to_greyscale((&r_4)->f);
    float _S1383 = sel_4.w_sum / _S1382;
    bool _S1384 = _S1382 > 0.0f;
    float _S1385 = _slang_select(_S1384, _S1383,0.0f);
    (&r_4)->w = _S1385;
    (&r_4)->c = c_1;
    return r_4;
}

static __device__ float interpolate_0(float a_6, float b_9, float t_7)
{
    return a_6 + (b_9 - a_6) * t_7;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S1386 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S1386;
}

__device__ float2  temporalWeights(float c_2, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S1387 = c_2 * p_c_0;
    float _S1388 = c_t_0 * p_t_0;
    return make_float2 (_S1387 / (_S1387 + c_t_0 * g_previous_0), _S1388 / (_S1388 + c_2 * g_current_0));
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
    Domain _S1389 = dom_2;
    Reservoir _S1390 = r_5;
    Shift _S1391 = walk_0(&_S1389, &_S1390, replay_2, scale_2, sel_5);
    return _S1391;
}

__device__ Shift shift_hook(Domain dom_3, Reservoir r_6)
{
    Domain _S1392 = dom_3;
    Reservoir _S1393 = r_6;
    Shift _S1394 = shift_0(&_S1392, &_S1393);
    return _S1394;
}

#undef Matrix
