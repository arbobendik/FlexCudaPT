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

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

__device__ static const FixedArray<float, 576>  SHEEN_ALBEDO_0 = { {
    0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f
} };
__device__ float sheenAlbedo(float3  v_1, float3  n_i_1, BSDFMaterial material_1)
{
    float _S152 = rgb_to_greyscale(material_1.sheen);
    bool _S153 = _S152 > 0.0f;
    float albedo_0;
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
        float _S166 = (F32_exp((_S163 + (_S165 - _S163) * _S161)));
        albedo_0 = _S166;
    }
    else
    {
        albedo_0 = 0.0f;
    }
    return albedo_0;
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
    uint state_3 = random_state_2;
    float3  _S207 = negate_0(in_dir_0);
    float _S208 = sign_0(dot_0(n_4, _S207));
    float _S209 = material_2.roughness;
    float3  _S210 = sampleHalfVector(_S207, n_4 * make_float3 (_S208), _S209 * _S209, frame_1, &state_3);
    return _S210;
}

static __device__ float3  refract_0(float3  i_1, float3  n_5, float eta_0)
{
    float _S211 = dot_0(n_5, i_1);
    float _S212 = 1.0f - eta_0 * eta_0 * (1.0f - _S211 * _S211);
    if(_S212 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_1 - make_float3 (eta_0 * _S211 + (F32_sqrt((_S212)))) * n_5;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S213 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S214 = eta_i_0 / eta_o_0 * _S213;
    bool _S215 = _S214 < 1.0f;
    float kr_0;
    if(_S215)
    {
        float _S216 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S214 * _S214))))));
        float _S217 = eta_o_0 * cos_theta_0;
        float _S218 = eta_i_0 * _S216;
        float _S219 = (_S217 - _S218) / (_S217 + _S218);
        float _S220 = eta_i_0 * cos_theta_0;
        float _S221 = eta_o_0 * _S216;
        float _S222 = (_S220 - _S221) / (_S220 + _S221);
        float _S223 = (_S219 * _S219 + _S222 * _S222) / 2.0f;
        kr_0 = _S223;
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
    float _S224 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S224 / (_S224 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S224)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S225 = alphas_3.x;
    float _S226 = h_0.x / _S225;
    float _S227 = alphas_3.y;
    float _S228 = h_0.y / _S227;
    float _S229 = h_0.z;
    float _S230 = _S226 * _S226 + _S228 * _S228 + _S229 * _S229;
    return 1.0f / (F32_max((3.14159274101257324f * _S225 * _S227 * _S230 * _S230), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_1, float3  v_4, float3  n_i_3, float3  ggx_n_0, BSDFMaterial material_3, float eta_i_1, float eta_o_1, AnisotropicFrame frame_2, float sheen_albedo_0)
{
    float _S231 = dot_0(ggx_n_0, v_4);
    float _S232 = dot_0(n_i_3, ggx_n_0);
    float _S233 = eta_i_1 / eta_o_1;
    float3  _S234 = refract_0(in_dir_1, ggx_n_0, _S233);
    float3  _S235 = ((((_S234)) * make_float3(rnorm3df(((_S234)).x, ((_S234)).y, ((_S234)).z))));
    float _S236 = (F32_min(((F32_sqrt((material_3.specular_level))) * (F32_abs((eta_i_1 - eta_o_1))) / (eta_i_1 + eta_o_1)), (0.9999847412109375f)));
    float _S237 = _S236 * _S236;
    float _S238 = (1.0f + _S236) / (1.0f - _S236);
    float _S239 = (F32_abs((_S231)));
    bool _S240 = eta_i_1 > eta_o_1;
    float sheen_component_0;
    if(_S240)
    {
        sheen_component_0 = _S238;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float visible_1;
    if(_S240)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S238;
    }
    float _S241 = fresnel(_S239, sheen_component_0, visible_1);
    bool _S242 = (eta_i_1 * eta_i_1 * (1.0f - _S231 * _S231)) >= (eta_o_1 * eta_o_1);
    float3  _S243;
    if(_S242)
    {
        _S243 = make_float3 (1.0f);
    }
    else
    {
        float3  _S244 = material_3.specular_tint * make_float3 (_S237);
        _S243 = _S244 + (make_float3 (1.0f) - _S244) * make_float3 (_S241 - _S237) / make_float3 (1.0f - _S237);
    }
    float3  _S245 = make_float3 (1.0f);
    float3  _S246 = make_float3 (0.0f);
    float _S247 = rgb_to_greyscale(material_3.sheen);
    bool _S248 = _S247 > 0.0f;
    float3  scale_0;
    float3  sheen_1;
    float3  view_1;
    if(_S248)
    {
        float _S249 = (F32_min((sheen_albedo_0), (1.0f)));
        float3  _S250 = make_float3 (1.0f) - material_3.sheen * make_float3 (_S249);
        float _S251 = rgb_to_greyscale(material_3.sheen);
        float _S252 = _S251 * _S249;
        float3  _S253 = material_3.sheen / make_float3 ((F32_max((sheen_albedo_0), (1.0f))));
        scale_0 = _S250;
        sheen_component_0 = _S252;
        sheen_1 = _S253;
        view_1 = v_4;
    }
    else
    {
        scale_0 = _S245;
        sheen_component_0 = 0.0f;
        sheen_1 = _S246;
        view_1 = _S246;
    }
    float3  _S254 = mix_0(_S243, material_3.albedo, material_3.metallic);
    float3  F_1 = _S254 * scale_0;
    float _S255 = rgb_to_greyscale(F_1);
    float _S256 = 1.0f - material_3.metallic;
    float3  _S257 = make_float3 (1.0f) - _S243;
    float3  _S258 = make_float3 ((1.0f - material_3.transmission) * _S256) * _S257 * scale_0;
    float3  _S259 = make_float3 (material_3.transmission * _S256) * _S257 * scale_0;
    float _S260 = (F32_max((_S255), (0.0f)));
    float _S261 = rgb_to_greyscale(_S258);
    float _S262 = (F32_max((_S261), (0.0f)));
    float _S263 = rgb_to_greyscale(_S259);
    float _S264 = sign_0(length_0(_S235));
    float _S265 = (F32_max((_S263 * _S264), (0.0f)));
    float _S266 = _S260 + _S262 + _S265;
    float _S267 = (F32_min((sheen_component_0), (1.0f)));
    bool _S268 = sheen_component_0 > 0.0f;
    bool _S269;
    if(_S268)
    {
        _S269 = !(_S266 > 0.0f);
    }
    else
    {
        _S269 = false;
    }
    float _S270 = _slang_select(_S269, 1.0f,_S267);
    float _S271 = (1.0f - _S270) / (F32_max((_S266), (0.0000152587890625f)));
    float _S272 = _S262 * _S271;
    float _S273 = _S260 * _S271;
    float _S274 = _S265 * _S271;
    bool _S275 = (frame_2.alphas.x) > 0.0f;
    if(_S275)
    {
        float3  _S276 = anisotropicLocal(v_4, frame_2.tangent, n_i_3);
        float _S277 = anisotropicG1(_S276, frame_2.alphas);
        float3  _S278 = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        float _S279 = anisotropicD(_S278, frame_2.alphas);
        float _S280 = _S277 * _S279;
        visible_1 = _S280;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S231, _S232, _S235, F_1, _S255, 1.0f, _S258, _S259, _S272, _S273, _S274, 0.0f, sheen_1, _S270, view_1, frame_2.tangent, frame_2.alphas, visible_1);
}

__device__ float translucentShare(BSDFMaterial material_4)
{
    float _S281 = rgb_to_greyscale(material_4.translucent);
    float _S282 = rgb_to_greyscale(material_4.albedo);
    float _S283 = _S281 / (_S282 + _S281);
    bool _S284 = _S281 > 0.0f;
    float _S285 = _slang_select(_S284, _S283,0.0f);
    return _S285;
}

__device__ float3  refractedHalf(float3  in_dir_2, float3  out_dir_0, float3  n_6, float eta_i_2, float eta_o_2)
{
    float3  _S286 = negate_0(in_dir_2);
    float3  _S287 = negate_0(make_float3 (eta_i_2) * _S286 + make_float3 (eta_o_2) * out_dir_0);
    float3  _S288 = ((((_S287)) * make_float3(rnorm3df(((_S287)).x, ((_S287)).y, ((_S287)).z))));
    float _S289 = sign_0(dot_0(n_6, _S286));
    float _S290 = sign_0(dot_0(_S287, n_6 * make_float3 (_S289)));
    return _S288 * make_float3 (_S290);
}

__device__ float3  reflectedHalf(float3  in_dir_3, float3  out_dir_1)
{
    float3  _S291 = negate_0(in_dir_3);
    float3  _S292 = _S291 + out_dir_1;
    float3  _S293 = ((((_S292)) * make_float3(rnorm3df(((_S292)).x, ((_S292)).y, ((_S292)).z))));
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

__device__ __forceinline__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_9, float eta_i_7, float eta_o_7, bool refracted_2, uint random_state_3, uint mask_0, FixedArray<float3 , 4>  * throughputs_0, FixedArray<float, 4>  * pdfs_0)
{
    float3  _S360 = negate_0(in_dir_4);
    float _S361 = dot_0(n_7, _S360);
    float _S362 = sign_0(_S361);
    float3  _S363 = n_7 * make_float3 (_S362);
    AnisotropicFrame _S364 = anisotropicFrame(material_9, _S363);
    float _S365 = dot_0(_S363, out_dir_2);
    float _S366 = material_9.roughness;
    float _S367 = _S366 * _S366;
    float _S368 = sheenAlbedo(_S360, _S363, material_9);
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
    BSDFLobes sampled_terms_0 = _S374;
    bool _S375 = (mask_0 & 49U) != 0U;
    bool _S376;
    if(_S375)
    {
        if(_S370)
        {
            _S376 = _S371;
        }
        else
        {
            _S376 = false;
        }
        _S376 = _S376 == refracted_2;
    }
    else
    {
        _S376 = false;
    }
    if(_S376)
    {
        float3  sampled_n_0 = sampledHalf(in_dir_4, n_7, material_9, random_state_3, _S364);
        float3  _S377 = negate_0(in_dir_4);
        BSDFLobes _S378 = bsdfLobes(in_dir_4, _S377, _S363, sampled_n_0, material_9, eta_i_7, eta_o_7, _S364, _S368);
        sampled_terms_0 = _S378;
        float _S379 = translucentShare(material_9);
        (&sampled_terms_0)->translucent_share = _S379;
    }
    float3  f_0;
    if(refracted_2)
    {
        float3  _S380 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_7, eta_o_7);
        f_0 = _S380;
    }
    else
    {
        float3  _S381 = reflectedHalf(in_dir_4, out_dir_2);
        f_0 = _S381;
    }
    BSDFLobes lobe_terms_0 = _S374;
    bool _S382 = (mask_0 & 14U) != 0U;
    if(_S382)
    {
        float3  _S383 = negate_0(in_dir_4);
        BSDFLobes _S384 = bsdfLobes(in_dir_4, _S383, _S363, f_0, material_9, eta_i_7, eta_o_7, _S364, _S368);
        lobe_terms_0 = _S384;
        float _S385 = translucentShare(material_9);
        (&lobe_terms_0)->translucent_share = _S385;
    }
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
        uint _S386;
        if(i_2 == 3U)
        {
            _S386 = 4U;
        }
        else
        {
            _S386 = i_2;
        }
        bool _S387 = (mask_0 & (1U << i_2)) == 0U;
        if(_S387)
        {
            _S376 = true;
        }
        else
        {
            bool _S388 = _S386 == 0U;
            if(_S388)
            {
                _S376 = _S370;
            }
            else
            {
                _S376 = false;
            }
            bool _S389;
            if(_S376)
            {
                _S389 = _S371;
            }
            else
            {
                _S389 = _S386 == 1U;
            }
            _S376 = _S389 != refracted_2;
        }
        if(_S376)
        {
            uint i_4 = i_2 + 1U;
            i_2 = i_4;
            continue;
        }
        switch(_S386)
        {
        case 0U:
            {
                float _S390 = diffusePDF(_S365, 0.0f, (F32_abs((_S361))), _S367, sampled_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(0)] = _S390;
                float3  _S391 = diffuseBSDF(out_dir_2, _S363, _S367, material_9, sampled_terms_0);
                (*throughputs_0)[int(0)] = _S391;
                break;
            }
        case 1U:
            {
                float _S392 = refractPDF(_S365, dot_0(out_dir_2, f_0), (F32_abs((_S361))), _S367, lobe_terms_0, eta_i_7, eta_o_7);
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
        uint i_4 = i_2 + 1U;
        i_2 = i_4;
    }
    i_2 = 0U;
    f_0 = _S373;
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
            float3  f_1 = f_0 + (*throughputs_0)[i_2] * make_float3 ((*pdfs_0)[i_2]);
            f_0 = f_1;
        }
        uint i_5 = i_2 + 1U;
        i_2 = i_5;
    }
    return f_0;
}

__device__ float3  skyBSDF(float3  in_dir_5, float3  dir_3, FKSurface surface_1, float2  eta_1, bool is_inside_2, float pdf_0, uint random_state_4)
{
    float _S399 = eta_1.x;
    float _S400 = eta_1.y;
    bool _S401 = wrongSide_0(is_inside_2, false, dir_3, surface_1.geometry_n);
    FixedArray<float3 , 4>  throughputs_1;
    FixedArray<float, 4>  pdfs_1;
    float3  _S402 = BSDF(in_dir_5, dir_3, surface_1.smooth_n, surface_1.material, _S399, _S400, _S401, random_state_4, 4294967295U, &throughputs_1, &pdfs_1);
    float3  _S403 = make_float3 (0.0f);
    uint i_6 = 0U;
    float3  f_2 = _S403;
    for(;;)
    {
        if(i_6 < 4U)
        {
        }
        else
        {
            break;
        }
        bool _S404 = (pdfs_1[i_6]) > 0.0f;
        if(_S404)
        {
            float3  f_3 = f_2 + throughputs_1[i_6] * make_float3 (pdfs_1[i_6]) / make_float3 (pdfs_1[i_6] + pdf_0);
            f_2 = f_3;
        }
        uint i_7 = i_6 + 1U;
        i_6 = i_7;
    }
    return f_2;
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

static __device__ SkySample SkySample_x24init_0(float3  dir_4, float3  radiance_0, float3  color_0, uint random_state_5)
{
    SkySample _S405;
    (&_S405)->dir = dir_4;
    (&_S405)->radiance = radiance_0;
    (&_S405)->color = color_0;
    (&_S405)->random_state = random_state_5;
    return _S405;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0)
{
    uint2  _S406 = (fcptEnvironmentCdfSize());
    uint2  _S407 = make_uint2 (1U, 0U);
    uint2  _S408 = _S406 - _S407;
    Random _S409 = pcg(init_random_state_0);
    Random _S410 = pcg(_S409.state);
    Random _S411 = pcg(_S410.state);
    Random _S412 = pcg(_S411.state);
    uint _S413 = _S408.x;
    uint _S414 = searchCDF_0(make_uint2 (_S413, 0U), make_uint2 (0U, 1U), _S408.y, _S409.value);
    uint _S415 = searchCDF_0(make_uint2 (0U, _S414), _S407, _S413, _S410.value);
    float2  _S416 = make_float2 ((float)_S408.x, (float)_S408.y);
    float2  _S417 = (make_float2 (float(_S415), float(_S414)) + make_float2 (_S411.value, _S412.value)) / _S416 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S418 = _S417.y;
    float _S419 = (F32_sin((_S418)));
    float _S420 = _S417.x;
    float3  _S421 = make_float3 (_S419 * (F32_cos((_S420))), (F32_cos((_S418))), _S419 * (F32_sin((_S420))));
    float _S422 = environmentPdf_0(_S421);
    float3  _S423 = skyBSDF(ray_0->unit_direction, _S421, *surface_2, eta_2, is_inside_3, _S422, lobe_state_0);
    bool _S424 = !(_S422 > 0.0f);
    bool _S425;
    if(_S424)
    {
        _S425 = true;
    }
    else
    {
        _S425 = all_0(_S423 == make_float3 (0.0f));
    }
    if(_S425)
    {
        float3  _S426 = make_float3 (0.0f);
        return SkySample_x24init_0(_S421, _S426, _S426, _S412.state);
    }
    float3  _S427 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S421);
    return SkySample_x24init_0(_S421, _S427, _S423 * _S427, _S412.state);
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

static __device__ float3  hairLight_0(FKSurface * surface_3, float3  in_dir_6, TreeSample * light_1, bool competing_0)
{
    SampleBSDF _S428 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_6), (light_1->dir)));
    float3  _S429 = _S428.throughput * make_float3 (_S428.pdf);
    float _S430 = light_1->density;
    float _S431 = 1.0f + _S428.pdf * _S428.pdf / (light_1->density * light_1->density);
    bool _S432;
    if(competing_0)
    {
        _S432 = _S430 > 0.0f;
    }
    else
    {
        _S432 = false;
    }
    float _S433 = _slang_select(_S432, _S431,1.0f);
    return _S429 / make_float3 (_S433) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_5, float3  radiance_1, float density_0, uint random_state_6)
{
    TreeSample _S434;
    (&_S434)->dir = dir_5;
    (&_S434)->radiance = radiance_1;
    (&_S434)->density = density_0;
    (&_S434)->random_state = random_state_6;
    return _S434;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_3, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S435 = importance(first_1, p_3, normal_3);
    float _S436 = importance(second_1, p_3, normal_3);
    float2  _S437 = make_float2 (_S435, _S436);
    bool _S438 = _S435 == 0.0f;
    bool _S439;
    if(_S438)
    {
        _S439 = _S436 == 0.0f;
    }
    else
    {
        _S439 = false;
    }
    if(_S439)
    {
        return 2U;
    }
    float _S440 = _S435 + _S436;
    bool _S441 = _S436 > 0.0f;
    if(_S441)
    {
        _S439 = (*pick_0 * _S440) >= _S435;
    }
    else
    {
        _S439 = false;
    }
    uint _S442 = uint(_S439);
    float _S443 = (F32_min(((*pick_0 * _S440 - float(_S442) * _S435) / _slang_vector_get_element(_S437, _S442)), (0.99999994039535522f)));
    *pick_0 = _S443;
    float _S444 = *probability_3 * (_slang_vector_get_element(_S437, _S442) / _S440);
    *probability_3 = _S444;
    return _S442;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_4, float u1_0, float u2_0)
{
    float3  _S445 = center_1 - p_4;
    float _S446 = radius_1 * radius_1 / dot_0(_S445, _S445);
    float _S447 = u1_0 * _S446 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S446), (0.0f)))))));
    float _S448 = 2.0f * u1_0;
    bool _S449 = _S446 >= 1.0f;
    float _S450 = _slang_select(_S449, _S448,_S447);
    float _S451 = (F32_sqrt(((F32_max((_S450 * (2.0f - _S450)), (0.0f))))));
    float _S452 = 6.28318548202514648f * u2_0;
    float3  _S453 = make_float3 (_S451 * (F32_cos((_S452))), 1.0f - _S450, _S451 * (F32_sin((_S452))));
    float3  _S454 = ((((_S445)) * make_float3(rnorm3df(((_S445)).x, ((_S445)).y, ((_S445)).z))));
    float3  _S455 = tangentToWorld(_S453, _S454);
    return _S455;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S456 = center_2 - ray_1->origin;
    float _S457 = dot_0(_S456, ray_1->unit_direction);
    float _S458 = dot_0(_S456, _S456) - _S457 * _S457;
    float _S459 = radius_3 * radius_3;
    bool _S460 = _S458 > _S459;
    if(_S460)
    {
        return 4.294967296e+09f;
    }
    float _S461 = (F32_sqrt((_S459 - _S458)));
    float _S462 = _S457 - _S461;
    float _S463 = _S457 + _S461;
    bool _S464 = _S462 > 0.0000152587890625f;
    bool _S465;
    if(_S464)
    {
        _S465 = _S462 < max_len_0;
    }
    else
    {
        _S465 = false;
    }
    if(_S465)
    {
        return _S462;
    }
    bool _S466 = _S463 > 0.0000152587890625f;
    if(_S466)
    {
        _S465 = _S463 < max_len_0;
    }
    else
    {
        _S465 = false;
    }
    if(_S465)
    {
        return _S463;
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
    Random _S467 = pcg(init_random_state_1);
    Random _S468 = pcg(_S467.state);
    Random _S469 = pcg(_S468.state);
    float3  _S470 = make_float3 (0.0f);
    TreeSample _S471 = TreeSample_x24init_0(_S470, _S470, 0.0f, _S469.state);
    TreeSample sample_0 = _S471;
    float3  _S472 = _slang_select(sided_0, _S470,smooth_n_2);
    float3  _S473 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S467.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S474 = (fcptLightNode((n_8)));
        if((_S474.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S475 = (fcptLightSecond((n_8)));
        uint _S476 = n_8 + 1U;
        LightNode _S477 = (fcptLightBounds((_S476)));
        LightNode _S478 = (fcptLightBounds((_S475)));
        uint _S479 = pickChild(_S477, _S478, origin_4, _S472, &pick_1, &probability_4);
        bool _S480 = _S479 > 1U;
        if(_S480)
        {
            return sample_0;
        }
        bool _S481 = _S479 == 1U;
        uint _S482 = _slang_select(_S481, _S475,_S476);
        n_8 = _S482;
    }
    bool _S483 = n_8 == 0U;
    bool _S484;
    if(_S483)
    {
        LightNode _S485 = (fcptLightBounds((0U)));
        float _S486 = importance(_S485, origin_4, _S472);
        _S484 = !(_S486 > 0.0f);
    }
    else
    {
        _S484 = false;
    }
    if(_S484)
    {
        return sample_0;
    }
    uint4  _S487 = (fcptLightNode((n_8)));
    FKHit _S488 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S489 = (_S487.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S489)
    {
        FKLight _S490 = (fcptLight((_S487.y)));
        if(sided_0)
        {
            float _S491 = sign_0(dot_0(geometry_n_1, _S490.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S491);
            float3  _S492 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S492;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S473;
            lift_n_0 = smooth_n_2;
        }
        bool _S493 = (_S490.variance) == 0.0f;
        if(_S493)
        {
            float3  _S494 = _S490.position - emitter_point_0;
            float3  _S495 = ((((_S494)) * make_float3(rnorm3df(((_S494)).x, ((_S494)).y, ((_S494)).z))));
            (&sample_0)->dir = _S495;
            float3  _S496 = _S490.color * make_float3 (_S490.intensity) / make_float3 (dot_0(_S494, _S494) * probability_4);
            (&sample_0)->radiance = _S496;
            shadow_1 = _S494;
        }
        else
        {
            float3  _S497 = sampleSphere(_S490.position, _S490.variance, emitter_point_0, _S468.value, _S469.value);
            (&sample_0)->dir = _S497;
            float _S498 = sphereDensity(_S490.position, _S490.variance, emitter_point_0);
            float _S499 = probability_4 * _S498;
            (&sample_0)->density = _S499;
            float3  _S500 = pointLightRadiance(_S490.color, _S490.intensity, _S490.variance);
            float3  _S501 = _S500 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S501;
            FKRay _S502 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S503 = raySphere_0(_S490.position, _S490.variance, &_S502, 4.294967296e+09f);
            float3  _S504 = (&sample_0)->dir * make_float3 (_S503);
            shadow_1 = _S504;
        }
        emitter_0 = _S488;
        emitter_point_0 = _S470;
    }
    else
    {
        uint _S505 = _S487.y;
        uint _S506 = (fcptTriangleOffset((_S505)));
        uint _S507 = _S506 + _S487.z;
        Matrix<float, 3, 3>  _S508 = (fcptWorldTriangle((_S505), (_S507)));
        float _S509 = (F32_sqrt((_S468.value)));
        float2  _S510 = make_float2 (_S509 * (1.0f - _S469.value), _S509 * _S469.value);
        float3  _S511 = mul_0(make_float3 (1.0f - _S509, _S510.x, _S510.y), _S508);
        if(sided_0)
        {
            float _S512 = sign_0(dot_0(geometry_n_1, _S511 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S512);
            float3  _S513 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S513;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S514 = !((dot_0(smooth_n_2, _S511 - origin_4)) > 0.0f);
            if(_S514)
            {
                return sample_0;
            }
            emitter_point_0 = _S473;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S510, _S505, _S507, 0U, 0.0f);
        float3  _S515 = _S511 - emitter_point_0;
        float3  _S516 = ((((_S515)) * make_float3(rnorm3df(((_S515)).x, ((_S515)).y, ((_S515)).z))));
        (&sample_0)->dir = _S516;
        float _S517 = solidAngle(probability_4, cross_0(_S508.rows[int(1)] - _S508.rows[int(0)], _S508.rows[int(2)] - _S508.rows[int(0)]), _S515);
        (&sample_0)->density = _S517;
        bool _S518 = (fcptShadowFirst());
        bool _S519 = !_S518;
        if(_S519)
        {
            FKSurface _S520 = (fcptLightSurfaceAt((emitter_1), (_S511), (_S469.state), ((&sample_0)->dir), (context_1->depth), (length_0(_S511 - origin_4))));
            (&sample_0)->random_state = _S520.random_state;
            float3  _S521 = _slang_select(_S520.skip, _S470,_S520.material.emissive);
            float3  _S522 = _S521 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S522;
        }
        shadow_1 = _S515;
        emitter_0 = emitter_1;
        emitter_point_0 = _S511;
    }
    FKHit _S523 = emitter_0;
    float3  _S524 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_1, _S469.state, &_S523);
    bool _S525 = (fcptShadowFirst());
    if(_S525)
    {
        _S484 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S484 = false;
    }
    if(_S484)
    {
        _S484 = !all_0(_S524 == _S470);
    }
    else
    {
        _S484 = false;
    }
    if(_S484)
    {
        FKSurface _S526 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S469.state), ((&sample_0)->dir), (context_1->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S526.random_state;
        float3  _S527 = _slang_select(_S526.skip, _S470,_S526.material.emissive);
        float3  _S528 = _S527 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S528;
    }
    float3  _S529 = (&sample_0)->radiance * _S524;
    bool _S530 = all_0(_S524 == _S470);
    float3  _S531 = _slang_select(_S530, _S470,_S529);
    (&sample_0)->radiance = _S531;
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
    float _S532 = 1.0f / (1.0f + b_0 / a_4 * (b_0 / a_4));
    bool _S533 = b_0 > 0.0f;
    float _S534 = _slang_select(_S533, _S532,1.0f);
    return _S534;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_0, float3  light_point_1)
{
    bool _S535 = vertex_0->none;
    if(_S535)
    {
        return 1.0f;
    }
    uint _S536 = (fcptLightSlot((*hit_0)));
    float _S537 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S536, light_point_1);
    float _S538 = powerHeuristic(vertex_0->pdf, _S537);
    return _S538;
}

static __device__ float3  environment_0(float3  dir_6, uint depth_0, uint lobe_0)
{
    uint2  _S539 = (fcptEnvironmentMapSize());
    bool _S540 = (_S539.x) > 1U;
    bool _S541;
    if(_S540)
    {
        uint2  _S542 = (fcptEnvironmentMapSize());
        _S541 = (_S542.y) > 1U;
    }
    else
    {
        _S541 = false;
    }
    if(_S541)
    {
        float3  _S543 = (fcptEnvMapSample((dir_6), (depth_0), (lobe_0)));
        return _S543;
    }
    float3  _S544 = (fcptAmbient());
    return _S544;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S545 = (fcptEnvironmentCdfSize());
    bool _S546 = (_S545.x) > 1U;
    bool _S547;
    if(_S546)
    {
        uint2  _S548 = (fcptEnvironmentCdfSize());
        _S547 = (_S548.y) > 1U;
    }
    else
    {
        _S547 = false;
    }
    bool _S549 = !_S547;
    if(_S549)
    {
        return false;
    }
    uint2  _S550 = (fcptEnvironmentMapSize());
    bool _S551 = (_S550.x) > 1U;
    if(_S551)
    {
        uint2  _S552 = (fcptEnvironmentMapSize());
        _S547 = (_S552.y) > 1U;
    }
    else
    {
        _S547 = false;
    }
    return _S547;
}

static __device__ float escapeWeight_0(float pdf_1, float3  dir_7)
{
    bool _S553 = pdf_1 <= 0.0f;
    bool _S554;
    if(_S553)
    {
        _S554 = true;
    }
    else
    {
        bool _S555 = environmentMapped_0();
        _S554 = !_S555;
    }
    if(_S554)
    {
        return 1.0f;
    }
    float _S556 = environmentPdf_0(dir_7);
    return pdf_1 / (pdf_1 + _S556);
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

static __device__ Shift Shift_x24init_0(float3  f_4, float jac_0)
{
    Shift _S557;
    (&_S557)->f = f_4;
    (&_S557)->jac = jac_0;
    return _S557;
}

static __device__ uint extractBits_0(uint e_1, uint offset_0, uint count_1)
{
    return (e_1 >> offset_0) & ((1U << count_1) - 1U);
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_2, float3  origin_5, float3  smooth_n_3, float3  start_2)
{
    NEEVertex _S558;
    (&_S558)->none = none_0;
    (&_S558)->pdf = pdf_2;
    (&_S558)->origin = origin_5;
    (&_S558)->smooth_n = smooth_n_3;
    (&_S558)->start = start_2;
    return _S558;
}

struct Vertex
{
    bool rough;
    uint lobe;
    float pdf;
    float cos;
    bool inside;
};

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_1, float pdf_3, float cos_0, bool inside_0)
{
    Vertex _S559;
    (&_S559)->rough = rough_0;
    (&_S559)->lobe = lobe_1;
    (&_S559)->pdf = pdf_3;
    (&_S559)->cos = cos_0;
    (&_S559)->inside = inside_0;
    return _S559;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S560 = hash(index_0);
    uint _S561 = hash(seed_0 ^ _S560);
    return _S561;
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
    float3  _S562 = exp_0((make_float3 (sigma_0) - extinction_0) * make_float3 (distance_1));
    float3  _S563 = scatter_0 * _S562 / make_float3 (sigma_0);
    float3  _S564 = _slang_select(scatters_0, _S563,_S562);
    return _S564;
}

static __device__ uint arrivalLobe_0(uint b_1, uint prev_lobe_0)
{
    bool _S565 = b_1 > 0U;
    uint _S566 = _slang_select(_S565, prev_lobe_0,3U);
    return _S566;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_4, float length_2, float width_0, FKHit * own_0, bool fiber_0)
{
    ShadowContext _S567;
    (&_S567)->extinction_behind = extinction_behind_0;
    (&_S567)->extinction_front = extinction_front_0;
    (&_S567)->fillings = fillings_0;
    (&_S567)->side = side_0;
    (&_S567)->depth = depth_1;
    (&_S567)->lobe = lobe_2;
    (&_S567)->surface = surface_4;
    (&_S567)->length = length_2;
    (&_S567)->width = width_0;
    (&_S567)->own = *own_0;
    (&_S567)->fiber = fiber_0;
    return _S567;
}

__device__ float3  safeDivide(float3  a_5, float3  b_2)
{
    float3  _S568 = a_5 / b_2;
    float3  _S569 = make_float3 (0.0f);
    bool3  _S570 = b_2 == _S569;
    float3  _S571 = _slang_select(_S570, _S569,_S568);
    return _S571;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S572 = (1U << count_2) - 1U;
    return (e_2 & (~(_S572 << offset_1))) | ((newbits_0 & _S572) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_0, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_0 = r_0;
    uint _S573 = insertBits_0(r_0.path, end_0, 0U, 5U);
    uint _S574 = insertBits_0(_S573, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S574;
    (&candidate_0)->f = f_5;
    return candidate_0;
}

__device__ void offer(Selection * sel_0, Reservoir candidate_1, float3  weight_0)
{
    float _S575 = rgb_to_greyscale(weight_0);
    bool _S576 = _S575 > 0.0f;
    bool _S577;
    if(_S576)
    {
        _S577 = _S575 < 3.00000000549775576e+38f;
    }
    else
    {
        _S577 = false;
    }
    bool _S578 = !_S577;
    if(_S578)
    {
        return;
    }
    bool _S579 = sel_0->sums;
    if(_S579)
    {
        float3  _S580 = sel_0->color + weight_0;
        sel_0->color = _S580;
        return;
    }
    float _S581 = sel_0->w_sum + _S575;
    sel_0->w_sum = _S581;
    float3  _S582 = sel_0->color + weight_0;
    sel_0->color = _S582;
    Random _S583 = pcg(sel_0->random_state);
    sel_0->random_state = _S583.state;
    bool _S584 = (_S583.value * sel_0->w_sum) <= _S575;
    if(_S584)
    {
        sel_0->r = candidate_1;
    }
    return;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    float3  _S585 = throughput_0 / make_float3 (density_1);
    return clamp_0((F32_max((_S585.x), ((F32_max((_S585.y), (_S585.z)))))), 0.0f, 1.0f);
}

static __device__ float3  isotropic_0(uint random_state_7)
{
    Random _S586 = pcg(random_state_7);
    Random _S587 = pcg(_S586.state);
    float _S588 = 1.0f - 2.0f * _S586.value;
    float _S589 = (F32_sqrt(((F32_max((1.0f - _S588 * _S588), (0.0f))))));
    float _S590 = 6.28318548202514648f * _S587.value;
    return make_float3 (_S589 * (F32_cos((_S590))), _S589 * (F32_sin((_S590))), _S588);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2)
{
    BSDFMaterial _S591;
    (&_S591)->albedo = albedo_1;
    (&_S591)->emissive = emissive_0;
    (&_S591)->roughness = roughness_0;
    (&_S591)->metallic = metallic_0;
    (&_S591)->transmission = transmission_0;
    (&_S591)->ior = ior_0;
    (&_S591)->absorption = absorption_0;
    (&_S591)->specular_tint = specular_tint_0;
    (&_S591)->specular_level = specular_level_0;
    (&_S591)->translucent = translucent_0;
    (&_S591)->sheen = sheen_2;
    (&_S591)->sheen_roughness = sheen_roughness_0;
    (&_S591)->anisotropy = anisotropy_0;
    (&_S591)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S591)->tangent = tangent_2;
    return _S591;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1)
{
    FKMedium _S592;
    (&_S592)->scatter = scatter_1;
    (&_S592)->extinction = extinction_1;
    return _S592;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_10, bool skip_0, uint random_state_8, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S593;
    (&_S593)->smooth_n = smooth_n_4;
    (&_S593)->geometry_n = geometry_n_2;
    (&_S593)->geometry_offset = geometry_offset_2;
    (&_S593)->material = *material_10;
    (&_S593)->skip = skip_0;
    (&_S593)->random_state = random_state_8;
    (&_S593)->coverage = coverage_0;
    (&_S593)->encloses = encloses_0;
    (&_S593)->volume = *volume_0;
    (&_S593)->fills = fills_0;
    (&_S593)->hair = hair_0;
    return _S593;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_5, float u_1)
{
    float _S594 = surface_5->coverage;
    bool _S595 = u_1 < _S594;
    if(_S595)
    {
        return *surface_5;
    }
    float3  _S596 = make_float3 (0.0f);
    float3  _S597 = make_float3 (1.0f);
    BSDFMaterial _S598 = Material_x24init_0(_S596, _S596, 0.0f, 0.0f, 0.0f, 0.0f, _S596, _S597, 1.0f, _S596, _S596, 0.5f, 0.0f, 0.0f, _S596);
    BSDFMaterial material_11 = _S598;
    (&material_11)->albedo = _S597;
    (&material_11)->emissive = (&surface_5->material)->emissive;
    (&material_11)->transmission = 1.0f;
    (&material_11)->ior = 1.0f;
    (&material_11)->absorption = (&surface_5->material)->absorption;
    FKSurface through_0 = *surface_5;
    (&through_0)->material = material_11;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S599 = transmission_1 > 0.0f;
    bool _S600;
    if(_S599)
    {
        _S600 = true;
    }
    else
    {
        _S600 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S601;
    if(_S600)
    {
        _S601 = 1.0f;
    }
    else
    {
        _S601 = -1.0f;
    }
    return _S601;
}

static __device__ bool arrivesBehind_0(float3  dir_8, float3  n_9)
{
    return (dot_0(dir_8, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_6, float3  dir_9)
{
    float3  _S602 = surface_6->geometry_n;
    float _S603 = facingSign((&surface_6->material)->transmission, surface_6->geometry_n, dir_9);
    FKSurface faced_0 = *surface_6;
    float3  _S604 = surface_6->smooth_n * make_float3 (_S603);
    (&faced_0)->smooth_n = _S604;
    float3  _S605 = _S602 * make_float3 (_S603);
    (&faced_0)->geometry_n = _S605;
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
    float3  _S606 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_2) * log_0(_S606));
}

__device__ float2  vertexEta(BSDFMaterial material_12, float n_dot_v_0)
{
    bool _S607 = n_dot_v_0 < 0.0f;
    float _S608 = _slang_select(_S607, material_12.ior,1.0f);
    float _S609 = _slang_select(_S607, 1.0f,material_12.ior);
    return make_float2 (_S608, _S609);
}

__device__ bool neeDecision(BSDFMaterial material_13, float n_dot_v_1, float eta_i_8, float eta_o_8)
{
    float _S610 = fresnel((F32_abs((n_dot_v_1))), eta_i_8, eta_o_8);
    float3  _S611 = mix_0(make_float3 (_S610), material_13.albedo, material_13.metallic);
    float _S612 = rgb_to_greyscale(_S611);
    float _S613 = (F32_max(((1.0f - _S612) * (1.0f - material_13.metallic) * (1.0f - material_13.transmission)), (0.0f)));
    bool _S614 = _S613 > 0.03999999910593033f;
    bool _S615;
    if(_S614)
    {
        _S615 = true;
    }
    else
    {
        _S615 = (material_13.roughness) > 0.20000000298023224f;
    }
    return _S615;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_14)
{
    float _S616 = rgb_to_greyscale(material_14->translucent);
    bool _S617 = _S616 > 0.0f;
    return _S617;
}

struct MediumSides
{
    FKMedium behind;
    FKMedium front;
    uint2  fillings;
};

static __device__ MediumSides MediumSides_x24init_0(FKMedium * behind_0, FKMedium * front_0, uint2  fillings_1)
{
    MediumSides _S618;
    (&_S618)->behind = *behind_0;
    (&_S618)->front = *front_0;
    (&_S618)->fillings = fillings_1;
    return _S618;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_7, FKMedium * medium_0, uint filling_0, float3  dir_10)
{
    MediumSides _S619 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0));
    MediumSides sides_0 = _S619;
    bool _S620 = surface_7->encloses;
    if(_S620)
    {
        (&sides_0)->behind = surface_7->volume;
        *&((&(&sides_0)->fillings)->x) = surface_7->fills;
        bool _S621 = (dot_0(dir_10, surface_7->geometry_n)) > 0.0f;
        if(_S621)
        {
            float3  _S622 = make_float3 (0.0f);
            FKMedium _S623 = Medium_x24init_0(_S622, _S622);
            (&sides_0)->front = _S623;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_8, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_11, uint depth_2, uint lobe_3, float length_3, float width_1, FKHit * own_1, bool fiber_1)
{
    float3  _S624 = surface_8->geometry_n;
    ShadowContext _S625 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_8->geometry_n, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
    bool _S626 = surface_8->encloses;
    ShadowContext context_2;
    if(_S626)
    {
        FKSurface faced_1 = *surface_8;
        float3  _S627 = - _S624;
        float3  _S628 = _slang_select(turned_0, _S627,_S624);
        (&faced_1)->geometry_n = _S628;
        FKMedium _S629 = Medium_x24init_0(make_float3 (0.0f), extinction_2);
        FKSurface _S630 = faced_1;
        FKMedium _S631 = _S629;
        MediumSides _S632 = mediumSides_0(&_S630, &_S631, filling_1, dir_11);
        ShadowContext _S633 = ShadowContext_x24init_0(_S632.behind.extinction, _S632.front.extinction, _S632.fillings, _S624, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
        if(turned_0)
        {
            uint2  _S634 = _S632.fillings;
            ShadowContext _S635 = ShadowContext_x24init_0(_S632.front.extinction, _S632.behind.extinction, uint2 {_S634.y, _S634.x}, _S624, depth_2, lobe_3, true, length_3, width_1, own_1, fiber_1);
            context_2 = _S635;
        }
        else
        {
            context_2 = _S633;
        }
    }
    else
    {
        context_2 = _S625;
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

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_9, bool refracted_3, uint lobe_4, float pdf_4)
{
    SampleBSDF _S636;
    (&_S636)->unit_direction = unit_direction_1;
    (&_S636)->throughput = throughput_1;
    (&_S636)->random_state = random_state_9;
    (&_S636)->refracted = refracted_3;
    (&_S636)->lobe = lobe_4;
    (&_S636)->pdf = pdf_4;
    return _S636;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_8, float n_i_dot_v_5, float alpha_13, BSDFMaterial material_15, BSDFLobes lobes_9, float eta_i_9, float eta_o_9, uint random_state_10)
{
    float3  _S637 = make_float3 (1.0f);
    SampleBSDF _S638 = SampleBSDF_x24init_0(_S637, _S637, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S638;
    Random _S639 = pcg(random_state_10);
    Random _S640 = pcg(_S639.state);
    (&sample_1)->random_state = _S640.state;
    float _S641 = _S639.value;
    float _S642 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S641 * _S641))))));
    float _S643 = 6.28318548202514648f * _S640.value;
    float3  _S644 = tangentToWorld(make_float3 (_S642 * (F32_cos((_S643))), _S639.value, _S642 * (F32_sin((_S643)))), n_i_8);
    (&sample_1)->unit_direction = _S644;
    (&sample_1)->lobe = 4U;
    float3  _S645 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_8, alpha_13, material_15, lobes_9);
    (&sample_1)->throughput = _S645;
    float _S646 = sheenVelvetPDF(_S639.value, 0.0f, n_i_dot_v_5, alpha_13, lobes_9, eta_i_9, eta_o_9);
    (&sample_1)->pdf = _S646;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S647 = (F32_sqrt((random_1_0)));
    float _S648 = 6.28318548202514648f * random_2_0;
    float _S649 = _S647 * (F32_cos((_S648)));
    float _S650 = _S647 * (F32_sin((_S648)));
    float _S651 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S649 * _S649 - _S650 * _S650))))));
    return make_float3 (_S649, _S651, _S650);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_2, float3  n_i_9, float n_i_dot_v_6, float alpha_14, BSDFMaterial material_16, BSDFLobes lobes_10, float eta_i_10, float eta_o_10, uint random_state_11)
{
    float3  _S652 = make_float3 (1.0f);
    SampleBSDF _S653 = SampleBSDF_x24init_0(_S652, _S652, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S653;
    Random _S654 = pcg(random_state_11);
    Random _S655 = pcg(_S654.state);
    (&sample_2)->random_state = _S655.state;
    float3  _S656 = sampleCosWeightedHemisphere(_S654.value, _S655.value);
    bool _S657 = u_2 < (lobes_10.p_diffuse * lobes_10.translucent_share);
    float _S658 = _S656.y;
    float _S659 = - _S658;
    float _S660 = _slang_select(_S657, _S659,_S658);
    float3  _S661 = tangentToWorld(make_float3 (_S656.x, _S660, _S656.z), n_i_9);
    (&sample_2)->unit_direction = _S661;
    (&sample_2)->refracted = _S657;
    (&sample_2)->lobe = 0U;
    float3  _S662 = diffuseBSDF((&sample_2)->unit_direction, n_i_9, alpha_14, material_16, lobes_10);
    (&sample_2)->throughput = _S662;
    float _S663 = diffusePDF(_S660, 0.0f, n_i_dot_v_6, alpha_14, lobes_10, eta_i_10, eta_o_10);
    (&sample_2)->pdf = _S663;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_1, float3  n_i_10, float n_i_dot_v_7, float alpha_15, BSDFMaterial material_17, BSDFLobes lobes_11, float eta_i_11, float eta_o_11, uint random_state_12)
{
    float3  _S664 = make_float3 (1.0f);
    SampleBSDF _S665 = SampleBSDF_x24init_0(_S664, _S664, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S665;
    (&sample_3)->unit_direction = lobes_11.refracted;
    (&sample_3)->random_state = random_state_12;
    (&sample_3)->refracted = true;
    (&sample_3)->lobe = 1U;
    float3  _S666 = refractBSDF((&sample_3)->unit_direction, n_i_10, alpha_15, material_17, lobes_11);
    (&sample_3)->throughput = _S666;
    float _S667 = refractPDF(0.0f, dot_0((&sample_3)->unit_direction, ggx_n_1), n_i_dot_v_7, alpha_15, lobes_11, eta_i_11, eta_o_11);
    (&sample_3)->pdf = _S667;
    return sample_3;
}

static __device__ float3  reflect_0(float3  i_15, float3  n_10)
{
    return i_15 - make_float3 (2.0f * dot_0(n_10, i_15)) * n_10;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_7, float3  ggx_n_2, float3  n_i_11, float n_i_dot_v_8, float alpha_16, BSDFMaterial material_18, BSDFLobes lobes_12, float eta_i_12, float eta_o_12, uint random_state_13)
{
    float3  _S668 = make_float3 (1.0f);
    SampleBSDF _S669 = SampleBSDF_x24init_0(_S668, _S668, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S669;
    float3  _S670 = reflect_0(in_dir_7, ggx_n_2);
    float3  _S671 = ((((_S670)) * make_float3(rnorm3df(((_S670)).x, ((_S670)).y, ((_S670)).z))));
    (&sample_4)->unit_direction = _S671;
    (&sample_4)->random_state = random_state_13;
    (&sample_4)->lobe = 2U;
    float3  _S672 = reflectBSDF((&sample_4)->unit_direction, n_i_11, alpha_16, material_18, lobes_12);
    (&sample_4)->throughput = _S672;
    float _S673 = reflectPDF(0.0f, 0.0f, n_i_dot_v_8, alpha_16, lobes_12, eta_i_12, eta_o_12);
    (&sample_4)->pdf = _S673;
    return sample_4;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_8, float3  n_11, BSDFMaterial material_19, float eta_i_13, float eta_o_13, uint random_init_0)
{
    uint random_state_14 = random_init_0;
    float3  _S674 = negate_0(in_dir_8);
    float _S675 = dot_0(n_11, _S674);
    float _S676 = sign_0(_S675);
    float3  n_i_12 = n_11 * make_float3 (_S676);
    float _S677 = (F32_abs((_S675)));
    float _S678 = material_19.roughness;
    float _S679 = _S678 * _S678;
    AnisotropicFrame _S680 = anisotropicFrame(material_19, n_i_12);
    float _S681 = sheenAlbedo(_S674, n_i_12, material_19);
    float3  _S682 = sampleHalfVector(_S674, n_i_12, _S679, _S680, &random_state_14);
    BSDFLobes _S683 = bsdfLobes(in_dir_8, _S674, n_i_12, _S682, material_19, eta_i_13, eta_o_13, _S680, _S681);
    BSDFLobes lobes_13 = _S683;
    float _S684 = translucentShare(material_19);
    (&lobes_13)->translucent_share = _S684;
    Random _S685 = pcg(random_state_14);
    random_state_14 = _S685.state;
    bool _S686 = (_S685.value) < ((&lobes_13)->p_sheen_velvet);
    if(_S686)
    {
        SampleBSDF _S687 = sheenVelvetSample(n_i_12, _S677, _S679, material_19, lobes_13, eta_i_13, eta_o_13, random_state_14);
        return _S687;
    }
    float _S688 = _S685.value - (&lobes_13)->p_sheen_velvet;
    bool _S689 = _S688 < ((&lobes_13)->p_diffuse);
    if(_S689)
    {
        SampleBSDF _S690 = diffuseSample(_S688, n_i_12, _S677, _S679, material_19, lobes_13, eta_i_13, eta_o_13, random_state_14);
        return _S690;
    }
    bool _S691 = _S688 < ((&lobes_13)->p_diffuse + (&lobes_13)->p_refract);
    if(_S691)
    {
        SampleBSDF _S692 = refractSample(_S682, n_i_12, _S677, _S679, material_19, lobes_13, eta_i_13, eta_o_13, random_state_14);
        return _S692;
    }
    SampleBSDF _S693 = reflectSample(in_dir_8, _S682, n_i_12, _S677, _S679, material_19, lobes_13, eta_i_13, eta_o_13, random_state_14);
    return _S693;
}

static __device__ bool boundsVolume_0(FKSurface * surface_9)
{
    return surface_9->encloses;
}

static __device__ float distance_3(float3  x_15, float3  y_5)
{
    return length_0(x_15 - y_5);
}

static __device__ Shift walk_0(Domain * dom_0, Reservoir * r_1, bool replay_0, float scale_1, Selection * sel_1)
{
    float spread_0;
    bool turned_1;
    bool is_inside_4;
    bool viewed_0;
    bool _S694;
    bool _S695;
    float density_2;
    float threshold_0;
    float width_2;
    float sky_pdf_0;
    float geometry_density_0;
    uint b_3;
    uint layer_0;
    float3  throughput_2;
    float3  chain_throughput_0;
    TreeSample light_2;
    int _S696;
    Shift ended_0;
    float density_3;
    float spread_1;
    float width_3;
    float sky_pdf_1;
    float spread_2;
    float width_4;
    float3  _S697 = make_float3 (0.0f);
    Shift _S698 = Shift_x24init_0(_S697, 0.0f);
    uint _S699 = r_1->path;
    uint _S700 = extractBits_0(r_1->path, 0U, 5U);
    uint _S701 = extractBits_0(_S699, 5U, 5U);
    uint _S702 = extractBits_0(_S699, 10U, 2U);
    uint _S703 = extractBits_0(_S699, 12U, 3U);
    bool passes_0;
    if(replay_0)
    {
        bool _S704 = _S703 >= 3U;
        uint _S705 = _slang_select(_S704, 1U,0U);
        uint _S706 = _S700 + _S705;
        uint _S707 = (fcptMaxBounces());
        passes_0 = _S706 > _S707;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S698;
    }
    uint _S708 = _S701 - 1U;
    bool _S709 = _S703 == 3U;
    uint _S710 = _slang_select(_S709, 1U,0U);
    uint _S711 = _S700 + _S710;
    bool _S712 = _S702 == 0U;
    uint _S713 = _slang_select(_S712, _S711,_S708);
    FKHit _S714 = (fcptReservoirHit((*r_1)));
    float3  _S715 = dom_0->x0;
    float3  _S716 = dom_0->x1 - dom_0->x0;
    float3  _S717 = ((((_S716)) * make_float3(rnorm3df(((_S716)).x, ((_S716)).y, ((_S716)).z))));
    FKRay _S718 = Ray_x24init_0(dom_0->x1, _S717);
    FKRay ray_2 = _S718;
    FKHit hit_1 = dom_0->hit;
    float3  scatter_in_0 = _S697;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S697;
    float3  extinction_in_0 = _S697;
    uint filling_2 = 4294967295U;
    float _S719 = dom_0->spread;
    float _S720 = dom_0->width;
    float _S721 = length_0(_S716);
    NEEVertex _S722 = NEEVertex_x24init_0(true, 0.0f, _S697, _S697, _S697);
    NEEVertex nee_vertex_0 = _S722;
    Vertex _S723 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S723;
    Reservoir _S724 = (Reservoir{});
    Reservoir chain_0 = _S724;
    uint _S725 = r_1->seed;
    (&chain_0)->seed = r_1->seed;
    (&ray_2)->origin = _S715;
    (&hit_1)->distance = _S721;
    FKMedium _S726 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_1)->distance), (&filling_2)));
    uint _S727 = filling_2;
    bool _S728 = (fcptVaryingUsed());
    uint _S729 = _slang_select(_S728, _S727,4294967295U);
    filling_2 = _S729;
    scatter_in_0 = _S726.scatter;
    extinction_in_0 = _S726.extinction;
    Reservoir _S730 = chain_0;
    uint _S731 = filling_2;
    for(;;)
    {
        bool _S732 = (fcptVaryingUsed());
        if(_S732)
        {
            passes_0 = _S731 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S733 = (fcptMajorant((_S731)));
            spread_0 = _S733;
        }
        else
        {
            spread_0 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_0)
        {
            turned_1 = 4294967295U == _S713;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S702 == 1U;
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
            ended_0 = _S698;
            sky_pdf_0 = 0.0f;
            spread_0 = _S719;
            width_2 = _S720;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_3 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S734 = (&prev_0)->rough;
        if(_S734)
        {
            turned_1 = !(spread_0 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S735 = stream(_S725, 384U);
        uint tracking_0 = _S735;
        weight_1 = throughput_3;
        glowed_0 = _S697;
        b_3 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_0 = _S719;
        width_2 = _S720;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_1)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S696 = int(1);
                break;
            }
            uint _S736 = b_3 + 320U;
            bool _S737 = b_3 == 4294967295U;
            uint _S738 = _slang_select(_S737, 384U,_S736);
            uint _S739 = stream(_S725, _S738);
            Random _S740 = pcg(_S739);
            float _S741 = - (F32_log((1.0f - _S740.value))) / spread_0;
            if(passes_0)
            {
                float3  _S742 = (&ray_2)->origin;
                float3  _S743 = (&ray_2)->unit_direction;
                float _S744 = (&hit_1)->distance;
                uint _S745 = _slang_select(_S737, 0U,b_3);
                uint _S746 = (&prev_0)->lobe;
                uint _S747 = _slang_select(_S737, 3U,_S746);
                float _S748 = (fcptTrackMedium((_S731), (_S742), (_S743), (_S744), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S745), (_S747), (_S737)));
                geometry_density_0 = _S748;
            }
            else
            {
                geometry_density_0 = _S741;
            }
            bool _S749 = !(geometry_density_0 < ((&hit_1)->distance));
            if(_S749)
            {
                _S696 = int(1);
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
                float3  _S750 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S751 = sel_1->glow + _S750;
                sel_1->glow = _S751;
            }
            else
            {
            }
            glowed_0 = _S697;
            uint b_4 = b_3 + 1U;
            float3  _S752 = (&ray_2)->origin + make_float3 (geometry_density_0) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S752;
            float3  _S753 = flightWeight_0(scatter_in_0, extinction_in_0, spread_0, geometry_density_0, true);
            float3  _S754 = weight_1;
            float3  _S755 = _slang_select(passes_0, _S754,_S753);
            float3  throughput_4 = throughput_2 * _S755;
            uint _S756 = stream(_S725, b_4 + 320U);
            tracking_0 = _S756;
            weight_1 = throughput_3;
            float width_5 = width_2 + threshold_0 * geometry_density_0;
            float _S757 = threshold_0 + 3.14159274101257324f;
            bool _S758 = !replay_0;
            if(_S758)
            {
                is_inside_4 = true;
            }
            else
            {
                bool _S759 = b_4 == _S713;
                if(_S759)
                {
                    is_inside_4 = !passes_0;
                }
                else
                {
                    is_inside_4 = false;
                }
            }
            TreeSample _S760 = TreeSample_x24init_0(_S697, _S697, 0.0f, 0U);
            if(is_inside_4)
            {
                float3  _S761 = (&ray_2)->origin;
                float3  _S762 = (&ray_2)->unit_direction;
                float3  _S763 = (&ray_2)->unit_direction;
                uint _S764 = stream(_S725, b_4 + 64U);
                float3  _S765 = extinction_in_0;
                float3  _S766 = extinction_in_0;
                uint2  _S767 = make_uint2 (_S731);
                float3  _S768 = (&ray_2)->unit_direction;
                uint _S769 = arrivalLobe_0(b_4, (&prev_0)->lobe);
                FKHit _S770 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S771 = _S770;
                ShadowContext _S772 = ShadowContext_x24init_0(_S765, _S766, _S767, _S768, b_4, _S769, false, geometry_density_0, width_5, &_S771, false);
                ShadowContext _S773 = _S772;
                TreeSample _S774 = sampleLightTree_0(_S761, _S762, _S763, 0.0f, true, _S764, &_S773);
                light_2 = _S774;
            }
            else
            {
                light_2 = _S760;
            }
            uint _S775 = (fcptMaxBounces());
            bool _S776 = b_4 < _S775;
            if(_S776)
            {
                viewed_0 = (light_2.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S777 = _slang_select(viewed_0, 0.07957746833562851f,0.0f);
            float3  _S778 = throughput_4 * light_2.radiance;
            float _S779 = powerHeuristic(light_2.density, _S777);
            float3  _S780 = _S778 * make_float3 (0.07957746833562851f * _S779);
            float3  _S781 = _slang_select(is_inside_4, _S780,_S697);
            if(replay_0)
            {
                _S694 = b_4 == _S713;
            }
            else
            {
                _S694 = false;
            }
            if(_S694)
            {
                bool _S782 = _S702 == 2U;
                if(_S782)
                {
                    float _S783 = rgb_to_greyscale(_S781);
                    passes_0 = _S783 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S784 = Shift_x24init_0(_S781, 1.0f);
                    _S696 = int(0);
                    ended_0 = _S784;
                    spread_0 = _S757;
                    geometry_density_0 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_4;
                    break;
                }
                _S696 = int(0);
                ended_0 = _S698;
                spread_0 = _S757;
                geometry_density_0 = width_5;
                chain_throughput_0 = throughput_4;
                layer_0 = b_4;
                break;
            }
            if(_S758)
            {
                Reservoir candidate_2 = _S730;
                uint _S785 = extractBits_0(_S730.path, 10U, 2U);
                bool _S786 = _S785 == 1U;
                if(_S786)
                {
                    float3  _S787 = safeDivide(_S781, _S697);
                    (&candidate_2)->radiance = _S787;
                }
                else
                {
                    uint _S788 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                    uint _S789 = insertBits_0(_S788, 2U, 10U, 2U);
                    (&candidate_2)->path = _S789;
                }
                Reservoir _S790 = withEnd(candidate_2, 0U, b_4, _S781);
                offer(sel_1, _S790, _S781 * make_float3 (scale_1) / make_float3 (density_2));
                float _S791 = survivalProbability(throughput_4, density_2);
                uint _S792 = stream(_S725, b_4 + 128U);
                Random _S793 = pcg(_S792);
                bool _S794 = _S791 < (_S793.value);
                if(_S794)
                {
                    _S695 = true;
                }
                else
                {
                    uint _S795 = (fcptMaxBounces());
                    _S695 = b_4 >= _S795;
                }
                if(_S695)
                {
                    _S696 = int(0);
                    ended_0 = _S698;
                    spread_0 = _S757;
                    geometry_density_0 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_4;
                    break;
                }
                float _S796 = density_2 * _S791;
                density_2 = _S796;
            }
            else
            {
            }
            NEEVertex _S797 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_2)->origin, _S697, (&ray_2)->origin);
            nee_vertex_0 = _S797;
            uint _S798 = stream(_S725, b_4);
            float3  _S799 = isotropic_0(_S798);
            (&ray_2)->unit_direction = _S799;
            Vertex _S800 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_0 = _S800;
            float _S801 = (&prev_0)->pdf;
            FKRay _S802 = ray_2;
            FKHit _S803 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S804 = (fcptTraverseInstanceBVH((_S802), (true), (4.294967296e+09f), (false), (_S803), (false)));
            hit_1 = _S804;
            b_3 = b_4;
            throughput_2 = throughput_4;
            threshold_0 = _S757;
            width_2 = width_5;
            sky_pdf_0 = _S801;
        }
        if(_S696 != int(1))
        {
            width_2 = geometry_density_0;
            throughput_2 = chain_throughput_0;
            b_3 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S698;
        spread_0 = threshold_0;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S805 = b_3 == 4294967295U;
    bool _S806 = ((&hit_1)->instance_index) == 4294967295U;
    if(_S806)
    {
        bool _S807 = !(&nee_vertex_0)->none;
        float _S808 = _slang_select(_S807, sky_pdf_0,0.0f);
        float _S809 = escapeWeight_0(_S808, (&ray_2)->unit_direction);
        float3  _S810 = environment_0((&ray_2)->unit_direction, b_3, (&prev_0)->lobe);
        float3  _S811 = throughput_2 * _S810;
        if(replay_0)
        {
            bool _S812 = b_3 == _S713;
            if(_S812)
            {
                passes_0 = _S702 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S811 * make_float3 (_S809) / make_float3 (r_1->jac), density_2 / r_1->jac);
            }
            if(_S712)
            {
                passes_0 = _S709;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_3 == _S700;
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
                return Shift_x24init_0(_S811 * make_float3 (_S809), 1.0f);
            }
            return _S698;
        }
        Reservoir candidate_3 = chain_0;
        uint _S813 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S814 = _S813 == 1U;
        if(_S814)
        {
            uint _S815 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S816 = _S815 == b_3;
            float _S817 = _slang_select(_S816, 1.0f,_S809);
            float3  _S818 = safeDivide(_S811 * make_float3 (_S817), _S697);
            (&candidate_3)->radiance = _S818;
        }
        else
        {
            bool _S819 = (&prev_0)->rough;
            if(_S819)
            {
                uint _S820 = insertBits_0(0U, b_3 + 1U, 5U, 5U);
                uint _S821 = insertBits_0(_S820, 3U, 10U, 2U);
                uint _S822 = insertBits_0(_S821, (&prev_0)->lobe, 15U, 3U);
                bool _S823 = (&prev_0)->inside;
                uint _S824 = _slang_select(_S823, 1U,0U);
                uint _S825 = insertBits_0(_S822, _S824, 22U, 1U);
                (&candidate_3)->path = _S825;
                (&candidate_3)->jac = (&prev_0)->pdf;
                (&candidate_3)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S826 = _S811 * make_float3 (_S809);
        Reservoir _S827 = withEnd(candidate_3, 3U, b_3, _S826);
        offer(sel_1, _S827, _S826 * make_float3 (scale_1) / make_float3 (density_2));
        return _S698;
    }
    float3  _S828 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S828;
    bool _S829 = (fcptVaryingUsed());
    if(_S829)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S830 = !replay_0;
        if(_S830)
        {
            float3  _S831 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S832 = sel_1->glow + _S831;
            sel_1->glow = _S832;
        }
        float3  _S833 = throughput_2 * weight_1;
        throughput_2 = _S833;
    }
    else
    {
        float3  _S834 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
        float3  _S835 = throughput_2 * _S834;
        throughput_2 = _S835;
    }
    float _S836 = width_2 + spread_0 * (&hit_1)->distance;
    uint _S837 = b_3 + 1U;
    b_3 = _S837;
    layer_0 = 0U;
    width_2 = _S836;
    passes_0 = false;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_4 = false;
    chain_throughput_0 = _S697;
    float3  reconnection_0 = _S697;
    viewed_0 = _S805;
    for(;;)
    {
        bool _S838 = ((&hit_1)->is_point_light) == 1U;
        if(replay_0)
        {
            _S694 = _S702 == 1U;
        }
        else
        {
            _S694 = false;
        }
        if(_S694)
        {
            _S695 = b_3 == _S701;
        }
        else
        {
            _S695 = false;
        }
        bool _S839;
        if(_S695)
        {
            bool _S840 = ((&hit_1)->instance_index) != (_S714.instance_index);
            if(_S840)
            {
                _S839 = true;
            }
            else
            {
                _S839 = ((&hit_1)->triangle_index) != (_S714.triangle_index);
            }
        }
        else
        {
            _S839 = false;
        }
        if(_S839)
        {
            return _S698;
        }
        FKMedium _S841 = Medium_x24init_0(_S697, _S697);
        BSDFMaterial _S842 = Material_x24init_0(_S697, _S697, 0.0f, 0.0f, 0.0f, 0.0f, _S697, throughput_3, 1.0f, _S697, _S697, 0.5f, 0.0f, 0.0f, _S697);
        FKMedium _S843 = _S841;
        FKSurface _S844 = Surface_x24init_0(_S697, _S697, 0.0f, &_S842, false, 0U, 1.0f, false, &_S843, 4294967295U, _S697);
        FKSurface surface_10 = _S844;
        bool _S845 = !_S838;
        bool scatter_2;
        bool is_inside_5;
        float3  throughput_5;
        if(_S845)
        {
            uint _S846 = stream(_S725, b_3);
            uint _S847 = arrivalLobe_0(b_3, (&prev_0)->lobe);
            FKSurface _S848 = (fcptSurfaceAtPath((hit_1), ((&ray_2)->origin), (_S846), (width_2), (layer_0), (b_3), (_S847), ((&ray_2)->unit_direction)));
            surface_10 = _S848;
            float3  _S849 = (&(&surface_10)->material)->emissive;
            float3  _S850 = _slang_select(passes_0, _S697,_S849);
            (&(&surface_10)->material)->emissive = _S850;
            uint _S851 = stream(_S725, b_3 + 256U);
            Random _S852 = pcg(_S851);
            FKSurface _S853 = surface_10;
            FKSurface _S854 = uncovered_0(&_S853, _S852.value);
            surface_10 = _S854;
            float _S855 = facingSign((&(&surface_10)->material)->transmission, (&surface_10)->geometry_n, (&ray_2)->unit_direction);
            bool _S856 = _S855 < 0.0f;
            bool _S857 = ((&(&surface_10)->material)->transmission) > 0.0f;
            if(_S857)
            {
                bool _S858 = arrivesBehind_0((&ray_2)->unit_direction, (&surface_10)->geometry_n);
                scatter_2 = _S858;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S859 = surface_10;
            FKSurface _S860 = facingRay_0(&_S859, (&ray_2)->unit_direction);
            surface_10 = _S860;
            if(passes_0)
            {
                bool _S861 = arrivesBehind_0((&ray_2)->unit_direction, (&surface_10)->geometry_n);
                is_inside_5 = _S861;
            }
            else
            {
                is_inside_5 = scatter_2;
            }
            if(is_inside_5)
            {
                float3  _S862 = beerLambert((&hit_1)->distance, (&(&surface_10)->material)->absorption);
                float3  _S863 = throughput_2 * _S862;
                throughput_5 = _S863;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S864 = !(&surface_10)->skip;
            float geometry_density_1 = (F32_abs((dot_0((&surface_10)->geometry_n, (&ray_2)->unit_direction)))) / ((&hit_1)->distance * (&hit_1)->distance);
            bool _S865 = b_3 == _S837;
            if(_S865)
            {
                float _S866 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S866;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S867 = geometry_density_0;
            scatter_2 = _S864;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S867;
            turned_1 = _S856;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            throughput_5 = throughput_2;
            is_inside_5 = is_inside_4;
        }
        bool _S868;
        if(scatter_2)
        {
            _S868 = (&prev_0)->rough;
        }
        else
        {
            _S868 = false;
        }
        bool _S869;
        if(_S868)
        {
            _S869 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S869 = false;
        }
        BSDFMaterial _S870 = (&surface_10)->material;
        float _S871 = dot_0((&surface_10)->smooth_n, - (&ray_2)->unit_direction);
        float2  _S872 = vertexEta(_S870, _S871);
        bool _S873;
        if(scatter_2)
        {
            bool _S874 = neeDecision(_S870, _S871, _S872.x, _S872.y);
            _S873 = _S874;
        }
        else
        {
            _S873 = false;
        }
        bool _S875;
        if(passes_0)
        {
            _S875 = true;
        }
        else
        {
            _S875 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S875)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S873;
        }
        bool _S876 = (fcptHairUsed());
        bool _S877;
        if(_S876)
        {
            _S877 = (dot_0((&surface_10)->hair, (&surface_10)->hair)) > 0.0f;
        }
        else
        {
            _S877 = false;
        }
        bool _S878;
        if(_S877)
        {
            _S878 = true;
        }
        else
        {
            BSDFMaterial _S879 = _S870;
            bool _S880 = isTranslucent_0(&_S879);
            _S878 = _S880;
        }
        bool _S881;
        if(_S878)
        {
            _S881 = true;
        }
        else
        {
            bool _S882 = (_S870.transmission) > 0.0f;
            if(_S882)
            {
                uint _S883 = (fcptLayers((hit_1)));
                _S881 = _S883 == 1U;
            }
            else
            {
                _S881 = false;
            }
        }
        float3  emission_0;
        if(_S838)
        {
            float3  _S884 = (fcptCalculatePointLightContrib(((&hit_1)->instance_index)));
            emission_0 = _S884;
        }
        else
        {
            emission_0 = _S870.emissive;
        }
        bool _S885 = !replay_0;
        bool _S886;
        if(_S885)
        {
            _S886 = true;
        }
        else
        {
            _S886 = b_3 >= _S713;
        }
        bool _S887;
        if(_S886)
        {
            float _S888 = rgb_to_greyscale(emission_0);
            _S887 = _S888 > 0.0f;
        }
        else
        {
            _S887 = false;
        }
        float3  emission_1;
        if(_S887)
        {
            NEEVertex _S889 = nee_vertex_0;
            FKHit _S890 = hit_1;
            float _S891 = emissionWeight_0(&_S889, &_S890, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S891);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S892;
        if(replay_0)
        {
            _S892 = _S702 == 1U;
        }
        else
        {
            _S892 = false;
        }
        bool _S893;
        if(_S892)
        {
            _S893 = b_3 > _S701;
        }
        else
        {
            _S893 = false;
        }
        bool _S894;
        if(_S893)
        {
            _S894 = b_3 == _S700;
        }
        else
        {
            _S894 = false;
        }
        bool _S895;
        if(_S894)
        {
            bool _S896 = _S703 == 1U;
            if(_S896)
            {
                _S895 = true;
            }
            else
            {
                _S895 = _S703 == 2U;
            }
        }
        else
        {
            _S895 = false;
        }
        if(_S895)
        {
            bool _S897 = _S838 != (_S703 == 2U);
            if(_S897)
            {
                return _S698;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_1->jac), density_2 / r_1->jac);
        }
        uint _S898 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S899 = _S898 == 1U;
        Reservoir here_0 = chain_0;
        uint _S900 = insertBits_0(0U, b_3, 5U, 5U);
        uint _S901 = insertBits_0(_S900, 1U, 10U, 2U);
        uint _S902 = insertBits_0(_S901, (&prev_0)->lobe, 15U, 3U);
        bool _S903 = (&prev_0)->inside;
        uint _S904 = _slang_select(_S903, 1U,0U);
        uint _S905 = insertBits_0(_S902, _S904, 22U, 1U);
        (&here_0)->path = _S905;
        float _S906 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S906;
        fcptWithReservoirHit((&here_0), (&hit_1));
        bool _S907;
        if(replay_0)
        {
            _S907 = _S702 == 1U;
        }
        else
        {
            _S907 = false;
        }
        bool _S908;
        if(_S907)
        {
            _S908 = b_3 == _S701;
        }
        else
        {
            _S908 = false;
        }
        bool _S909 = b_3 == _S713;
        bool _S910;
        if(_S909)
        {
            bool _S911 = !scatter_2;
            if(_S911)
            {
                _S910 = true;
            }
            else
            {
                bool _S912 = _S702 != 1U;
                if(_S912)
                {
                    _S910 = _S702 != 3U;
                }
                else
                {
                    _S910 = false;
                }
            }
        }
        else
        {
            _S910 = false;
        }
        bool _S913;
        if(_S910)
        {
            _S913 = _S702 == 2U;
        }
        else
        {
            _S913 = false;
        }
        bool _S914;
        if(_S913)
        {
            _S914 = !_S869;
        }
        else
        {
            _S914 = false;
        }
        bool _S915;
        if(_S914)
        {
            _S915 = _S703 != 4U;
        }
        else
        {
            _S915 = false;
        }
        bool _S916 = _S701 == _S700;
        bool _S917;
        if(_S916)
        {
            _S917 = _S703 == 0U;
        }
        else
        {
            _S917 = false;
        }
        bool _S918;
        if(_S917)
        {
            _S918 = ((&hit_1)->instance_index) == (_S714.instance_index);
        }
        else
        {
            _S918 = false;
        }
        bool _S919;
        if(_S918)
        {
            _S919 = ((&hit_1)->triangle_index) == (_S714.triangle_index);
        }
        else
        {
            _S919 = false;
        }
        bool _S920;
        if(_S919)
        {
            _S920 = _S869;
        }
        else
        {
            _S920 = false;
        }
        bool _S921 = _slang_select(_S908, _S920,_S915);
        bool _S922;
        if(nee_0)
        {
            _S922 = _slang_select(replay_0, _S921,scatter_2);
        }
        else
        {
            _S922 = false;
        }
        TreeSample _S923 = TreeSample_x24init_0(_S697, _S697, 0.0f, 0U);
        bool viewed_1;
        uint b_5;
        float3  throughput_6;
        float3  lit_0;
        if(_S922)
        {
            float3  _S924 = (&ray_2)->origin;
            if(_S877)
            {
                throughput_6 = _S697;
            }
            else
            {
                throughput_6 = (&surface_10)->smooth_n;
            }
            uint _S925 = stream(_S725, b_3 + 64U);
            uint _S926 = arrivalLobe_0(b_3, (&prev_0)->lobe);
            FKSurface _S927 = surface_10;
            FKHit _S928 = hit_1;
            ShadowContext _S929 = shadowContext_0(&_S927, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_3, _S926, (&hit_1)->distance, width_2, &_S928, _S877);
            ShadowContext _S930 = _S929;
            TreeSample _S931 = sampleLightTree_0(_S924, throughput_6, (&surface_10)->geometry_n, (&surface_10)->geometry_offset, _S881, _S925, &_S930);
            bool _S932 = any_0((_S931.radiance) != _S697);
            if(_S932)
            {
                if(_S877)
                {
                    uint _S933 = (fcptMaxBounces());
                    bool _S934 = b_3 < _S933;
                    FKSurface _S935 = surface_10;
                    TreeSample _S936 = _S931;
                    float3  _S937 = hairLight_0(&_S935, (&ray_2)->unit_direction, &_S936, _S934);
                    lit_0 = _S937;
                }
                else
                {
                    FixedArray<float3 , 4>  throughputs_2;
                    FixedArray<float, 4>  pdfs_2;
                    float3  _S938 = BSDF((&ray_2)->unit_direction, _S931.dir, (&surface_10)->smooth_n, _S870, _S872.x, _S872.y, (dot_0((&surface_10)->geometry_n, - (&ray_2)->unit_direction) * dot_0((&surface_10)->geometry_n, _S931.dir)) <= 0.0f, (&surface_10)->random_state, 4294967295U, &throughputs_2, &pdfs_2);
                    uint _S939 = (fcptMaxBounces());
                    bool _S940 = !(b_3 < _S939);
                    if(_S940)
                    {
                        viewed_1 = true;
                    }
                    else
                    {
                        viewed_1 = (_S931.density) == 0.0f;
                    }
                    if(viewed_1)
                    {
                        float3  _S941 = _S938 * _S931.radiance;
                        lit_0 = _S941;
                    }
                    else
                    {
                        b_5 = 0U;
                        lit_0 = _S697;
                        for(;;)
                        {
                            if(b_5 < 4U)
                            {
                            }
                            else
                            {
                                break;
                            }
                            bool _S942 = (pdfs_2[b_5]) > 0.0f;
                            if(_S942)
                            {
                                float _S943 = pdfs_2[b_5] / _S931.density;
                                float3  lit_1 = lit_0 + throughputs_2[b_5] * make_float3 (pdfs_2[b_5]) / make_float3 (_S931.density * (1.0f + _S943 * _S943));
                                lit_0 = lit_1;
                            }
                            uint i_16 = b_5 + 1U;
                            b_5 = i_16;
                        }
                        float3  _S944 = lit_0 * _S931.radiance * make_float3 (_S931.density);
                        lit_0 = _S944;
                    }
                }
            }
            else
            {
                lit_0 = _S697;
            }
            light_2 = _S931;
        }
        else
        {
            light_2 = _S923;
            lit_0 = _S697;
        }
        bool refracted_4;
        bool wrong_side_0;
        bool _S945;
        bool _S946;
        float density_4;
        if(_S908)
        {
            bool _S947 = !_S869;
            if(_S947)
            {
                return _S698;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S916)
            {
                viewed_1 = _S703 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            if(_S916)
            {
                refracted_4 = _S703 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S948 = !nee_0;
                if(_S948)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S949 = rgb_to_greyscale(light_2.radiance);
                    passes_0 = !(_S949 > 0.0f);
                }
                if(passes_0)
                {
                    return _S698;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            if(_S916)
            {
                wrong_side_0 = _S703 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S950 = !nee_0;
                if(_S950)
                {
                    return _S698;
                }
                float _S951 = environmentPdf_0(r_1->dir);
                float3  _S952 = skyBSDF((&ray_2)->unit_direction, r_1->dir, surface_10, _S872, is_inside_5, _S951, (&surface_10)->random_state);
                return Shift_x24init_0(throughput_7 * _S952 * r_1->radiance / make_float3 (r_1->jac), density_5 / r_1->jac);
            }
            uint _S953 = extractBits_0(_S699, 21U, 1U);
            bool _S954 = nee_0 != (_S953 == 1U);
            if(_S954)
            {
                return _S698;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_0)
            {
                viewed_1 = _S909;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S955 = !scatter_2;
                if(_S955)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S956 = _S702 != 1U;
                    if(_S956)
                    {
                        refracted_4 = _S702 != 3U;
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
                bool _S957 = _S702 == 2U;
                if(_S957)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S869;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S703 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    uint _S958 = stream(_S725, b_3 + 448U);
                    FKRay _S959 = ray_2;
                    FKSurface _S960 = surface_10;
                    SkySample _S961 = sampleSky_0(&_S959, &_S960, _S872, is_inside_5, _S958, (&surface_10)->random_state);
                    return Shift_x24init_0(throughput_5 * _S961.color, 1.0f);
                }
                if(_S957)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S869;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S962 = rgb_to_greyscale(light_2.radiance);
                    bool _S963 = !(_S962 > 0.0f);
                    if(_S963)
                    {
                        return _S698;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S712)
                {
                    passes_0 = _S703 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S838;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S712)
                {
                    passes_0 = _S703 == 1U;
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
                    passes_0 = !_S869;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S698;
            }
            else
            {
                if(_S885)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S964 = b_3 > 0U;
                    if(_S964)
                    {
                        Reservoir candidate_4 = chain_0;
                        if(_S899)
                        {
                            float3  _S965 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_4)->radiance = _S965;
                        }
                        else
                        {
                            if(_S869)
                            {
                                candidate_4 = here_0;
                            }
                        }
                        float3  _S966 = throughput_5 * emission_1;
                        Reservoir _S967 = withEnd(candidate_4, 1U, b_3, _S966);
                        offer(sel_1, _S967, _S966 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S968 = throughput_5 * emission_1;
                        float3  _S969 = sel_1->glow + _S968;
                        sel_1->glow = _S969;
                    }
                    if(nee_0)
                    {
                        float3  _S970 = throughput_5 * lit_0;
                        Reservoir candidate_5 = chain_0;
                        if(_S899)
                        {
                            float3  _S971 = safeDivide(_S970, chain_throughput_0);
                            (&candidate_5)->radiance = _S971;
                        }
                        else
                        {
                            if(_S869)
                            {
                                candidate_5 = here_0;
                                uint _S972 = insertBits_0((&candidate_5)->path, 1U, 21U, 1U);
                                (&candidate_5)->path = _S972;
                                (&candidate_5)->dir = light_2.dir;
                                (&candidate_5)->radiance = light_2.radiance;
                            }
                            else
                            {
                                uint _S973 = insertBits_0(0U, b_3 + 1U, 5U, 5U);
                                uint _S974 = insertBits_0(_S973, 2U, 10U, 2U);
                                (&candidate_5)->path = _S974;
                            }
                        }
                        Reservoir _S975 = withEnd(candidate_5, 0U, b_3, _S970);
                        offer(sel_1, _S975, _S970 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S877)
                        {
                            _S945 = false;
                        }
                        else
                        {
                            bool _S976 = environmentMapped_0();
                            _S945 = _S976;
                        }
                    }
                    else
                    {
                        _S945 = false;
                    }
                    if(_S945)
                    {
                        uint _S977 = (fcptMaxBounces());
                        _S946 = b_3 < _S977;
                    }
                    else
                    {
                        _S946 = false;
                    }
                    if(_S946)
                    {
                        uint _S978 = stream(_S725, b_3 + 448U);
                        FKRay _S979 = ray_2;
                        FKSurface _S980 = surface_10;
                        SkySample _S981 = sampleSky_0(&_S979, &_S980, _S872, is_inside_5, _S978, (&surface_10)->random_state);
                        float3  _S982 = throughput_5 * _S981.color;
                        Reservoir candidate_6 = chain_0;
                        if(_S899)
                        {
                            float3  _S983 = safeDivide(_S982, chain_throughput_0);
                            (&candidate_6)->radiance = _S983;
                        }
                        else
                        {
                            if(_S869)
                            {
                                candidate_6 = here_0;
                                uint _S984 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S984;
                                (&candidate_6)->dir = _S981.dir;
                                (&candidate_6)->radiance = _S981.radiance;
                            }
                            else
                            {
                                uint _S985 = insertBits_0(0U, b_3 + 1U, 5U, 5U);
                                uint _S986 = insertBits_0(_S985, 2U, 10U, 2U);
                                (&candidate_6)->path = _S986;
                            }
                        }
                        Reservoir _S987 = withEnd(candidate_6, 4U, b_3, _S982);
                        offer(sel_1, _S987, _S982 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S988;
        bool _S989;
        bool straight_0;
        bool _S990;
        bool _S991;
        bool _S992;
        bool _S993;
        bool _S994;
        bool _S995;
        bool _S996;
        bool _S997;
        bool _S998;
        bool _S999;
        bool _S1000;
        bool _S1001;
        bool _S1002;
        bool _S1003;
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
                viewed_1 = _S909;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1004 = extractBits_0(_S699, 15U, 3U);
            uint _S1005 = extractBits_0(_S699, 18U, 3U);
            uint _S1006 = _slang_select(_S908, _S1005,_S1004);
            float3  _S1007 = r_1->dir;
            bool refracted_5 = _S1006 == 1U;
            SampleBSDF _S1008 = SampleBSDF_x24init_0(_S697, _S697, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1008;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1009 = extractBits_0(_S699, 22U, 1U);
                bool _S1010 = is_inside_5 != (_S1009 == 1U);
                if(_S1010)
                {
                    return _S698;
                }
                bool _S1011 = _S702 == 1U;
                if(_S1011)
                {
                    float3  _S1012 = (fcptHitPosition((_S714)));
                    throughput_8 = _S1012;
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
                    BSDFMaterial _S1013 = _S870;
                    bool _S1014 = isTranslucent_0(&_S1013);
                    if(_S1014)
                    {
                        refracted_4 = _S1006 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1015 = (&surface_10)->smooth_n;
                        float3  _S1016 = throughput_8 - (&ray_2)->origin;
                        float3  _S1017 = _slang_select(_S1011, _S1016,_S1007);
                        wrong_side_0 = (dot_0(_S1015, _S1017) * _S871) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1011)
                {
                    float3  _S1018 = (&ray_2)->origin;
                    float _S1019 = (&surface_10)->geometry_offset;
                    float3  _S1020 = (&surface_10)->smooth_n;
                    float3  _S1021 = - (&surface_10)->smooth_n;
                    bool _S1022 = is_inside_5 != refracted_4;
                    float3  _S1023 = _slang_select(_S1022, _S1021,_S1020);
                    float3  _S1024 = throughput_8 - (_S1018 + make_float3 (_S1019) * _S1023);
                    float3  _S1025 = ((((_S1024)) * make_float3(rnorm3df(((_S1024)).x, ((_S1024)).y, ((_S1024)).z))));
                    reconnection_1 = _S1025;
                }
                else
                {
                    reconnection_1 = _S1007;
                }
                if(_S877)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1026 = wrongSide_0(is_inside_5, refracted_4, reconnection_1, (&surface_10)->geometry_n);
                    wrong_side_0 = _S1026;
                }
                if(wrong_side_0)
                {
                    return _S698;
                }
                float3  _S1027 = throughput_8;
                throughput_8 = reconnection_1;
                b_5 = _S1006;
                wrong_side_0 = false;
                reconnection_1 = _S1027;
            }
            else
            {
                bool _S1028 = !_S908;
                if(_S1028)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1029;
                    if(_S877)
                    {
                        SampleBSDF _S1030 = (fcptSampleHair(((&surface_10)->hair), (_S870.albedo), (_S870.specular_tint), ((&ray_2)->unit_direction), ((&surface_10)->random_state)));
                        _S1029 = _S1030;
                    }
                    else
                    {
                        SampleBSDF _S1031 = sampleBSDF((&ray_2)->unit_direction, (&surface_10)->smooth_n, _S870, _S872.x, _S872.y, (&surface_10)->random_state);
                        _S1029 = _S1031;
                    }
                    bsdf_sampled_0 = _S1029;
                    if(_S877)
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
                            return _S698;
                        }
                        break;
                    }
                    if(_S877)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1032 = wrongSide_0(is_inside_5, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, (&surface_10)->geometry_n);
                        wrong_side_0 = _S1032;
                    }
                    if(wrong_side_0)
                    {
                        _S945 = (_S870.transmission) > 0.0f;
                    }
                    else
                    {
                        _S945 = false;
                    }
                    if(_S945)
                    {
                        SampleBSDF _S1033 = sampleBSDF((&bsdf_sampled_0)->unit_direction, (&surface_10)->geometry_n, _S870, _S872.x, _S872.y, (&bsdf_sampled_0)->random_state);
                        (&bsdf_sampled_0)->unit_direction = _S1033.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1033.refracted;
                        (&bsdf_sampled_0)->throughput = _S1033.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1034 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, (&surface_10)->geometry_n)) * (&surface_10)->geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1034;
                        }
                    }
                    uint _S1035 = (&bsdf_sampled_0)->lobe;
                    float3  _S1036 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1037 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1038 = (&bsdf_sampled_0)->pdf;
                    float _S1039 = _slang_select(wrong_side_0, 0.0f,_S1038);
                    (&lobe_5)->pdf = _S1039;
                    throughput_8 = _S1036;
                    b_5 = _S1035;
                    refracted_4 = _S1037;
                }
                else
                {
                    throughput_8 = _S1007;
                    b_5 = _S1006;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S945 = true;
            }
            else
            {
                _S945 = _S908;
            }
            if(_S945)
            {
                if(_S877)
                {
                    SampleBSDF _S1040 = (fcptConnectHair(((&surface_10)->hair), (_S870.albedo), (_S870.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    lobe_5 = _S1040;
                }
                else
                {
                    if(b_5 == 4U)
                    {
                        b_6 = 3U;
                    }
                    else
                    {
                        b_6 = b_5;
                    }
                    float _S1041 = _S872.x;
                    float _S1042 = _S872.y;
                    bool _S1043 = wrongSide_0(is_inside_5, false, throughput_8, (&surface_10)->geometry_n);
                    FixedArray<float3 , 4>  throughputs_3;
                    FixedArray<float, 4>  pdfs_3;
                    float3  _S1044 = BSDF((&ray_2)->unit_direction, throughput_8, (&surface_10)->smooth_n, _S870, _S1041, _S1042, _S1043, (&surface_10)->random_state, 1U << b_6, &throughputs_3, &pdfs_3);
                    bool _S1045 = (pdfs_3[b_6]) > 0.0f;
                    if(_S1045)
                    {
                        SampleBSDF _S1046 = SampleBSDF_x24init_0(throughput_8, throughputs_3[b_6], (&surface_10)->random_state, b_5 == 1U, b_5, pdfs_3[b_6]);
                        lobe_5 = _S1046;
                    }
                }
            }
            bool _S1047 = b_5 == 0U;
            if(_S1047)
            {
                _S946 = true;
            }
            else
            {
                _S946 = b_5 == 4U;
            }
            if(_S877)
            {
                _S988 = false;
            }
            else
            {
                bool _S1048 = !_S946;
                if(_S1048)
                {
                    bool _S1049 = (_S870.roughness) == 0.0f;
                    if(_S1049)
                    {
                        _S988 = true;
                    }
                    else
                    {
                        bool _S1050 = b_5 == 1U;
                        if(_S1050)
                        {
                            _S988 = (_S872.x) == (_S872.y);
                        }
                        else
                        {
                            _S988 = false;
                        }
                    }
                }
                else
                {
                    _S988 = false;
                }
            }
            bool _S1051 = !_S877;
            if(_S1051)
            {
                _S989 = b_5 == 1U;
            }
            else
            {
                _S989 = false;
            }
            if(_S989)
            {
                straight_0 = (_S870.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S990 = _S1051;
            }
            else
            {
                _S990 = false;
            }
            if(_S990)
            {
                _S991 = b_5 == 1U;
            }
            else
            {
                _S991 = false;
            }
            if(_S991)
            {
                _S992 = (_S872.x) == (_S872.y);
            }
            else
            {
                _S992 = false;
            }
            BSDFMaterial _S1052 = _S870;
            bool _S1053 = isTranslucent_0(&_S1052);
            if(_S1053)
            {
                _S993 = _S1047;
            }
            else
            {
                _S993 = false;
            }
            if(_S993)
            {
                _S994 = (dot_0(throughput_8, (&surface_10)->geometry_n)) < 0.0f;
            }
            else
            {
                _S994 = false;
            }
            if(nee_0)
            {
                _S995 = !_S988;
            }
            else
            {
                _S995 = false;
            }
            if(_S995)
            {
                _S996 = !wrong_side_0;
            }
            else
            {
                _S996 = false;
            }
            if(_S996)
            {
                float _S1054 = (&lobe_5)->pdf;
                float3  _S1055 = (&ray_2)->origin;
                float3  _S1056 = (&surface_10)->smooth_n;
                float3  _S1057 = _slang_select(_S881, _S697,_S1056);
                float3  _S1058 = (&ray_2)->origin;
                float _S1059 = (&surface_10)->geometry_offset;
                float3  _S1060 = (&surface_10)->smooth_n;
                float3  _S1061 = - (&surface_10)->smooth_n;
                float3  _S1062 = _slang_select(_S994, _S1061,_S1060);
                NEEVertex _S1063 = NEEVertex_x24init_0(false, _S1054, _S1055, _S1057, _S1058 + make_float3 (_S1059) * _S1062);
                nee_vertex_0 = _S1063;
            }
            else
            {
                if(_S877)
                {
                    _S997 = true;
                }
                else
                {
                    bool _S1064 = b_5 != 1U;
                    if(_S1064)
                    {
                        _S997 = true;
                    }
                    else
                    {
                        _S997 = (_S872.x) != (_S872.y);
                    }
                }
                if(_S997)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1065 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1065)
            {
                if(_S946)
                {
                    _S997 = true;
                }
                else
                {
                    _S997 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_1)->distance * (&hit_1)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S997 = false;
            }
            bool _S1066 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1066)
            {
                if(_S946)
                {
                    _S998 = true;
                }
                else
                {
                    _S998 = (_S870.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S998 = false;
            }
            if(_S908)
            {
                bool _S1067 = !_S997;
                if(_S1067)
                {
                    return _S698;
                }
                bool _S1068 = _S703 != 1U;
                if(_S1068)
                {
                    _S999 = _S703 != 2U;
                }
                else
                {
                    _S999 = false;
                }
                if(_S999)
                {
                    float _S1069 = (&lobe_5)->pdf;
                    float _S1070 = _slang_select(nee_0, _S1069,0.0f);
                    float _S1071 = escapeWeight_0(_S1070, _S1007);
                    if(_S916)
                    {
                        passes_0 = _S709;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1072 = _slang_select(passes_0, _S1071,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_1->radiance * make_float3 (_S1072) / make_float3 (r_1->jac), density_4 * (&lobe_5)->pdf / r_1->jac);
                }
                float3  _S1073 = throughput_6 * make_float3 ((&lobe_5)->pdf);
                float _S1074 = density_4 * (&lobe_5)->pdf;
                throughput_9 = _S1073;
                density_6 = _S1074;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1075 = (fcptLayers((hit_1)));
            bool _S1076 = _S1075 > 1U;
            if(_S1076)
            {
                _S999 = (b_5 == 1U) != passes_0;
            }
            else
            {
                _S999 = false;
            }
            if(viewed_1)
            {
                _S1000 = _S999;
            }
            else
            {
                _S1000 = false;
            }
            if(_S1000)
            {
                return _S698;
            }
            if(replay_0)
            {
                _S1001 = b_3 <= _S713;
            }
            else
            {
                _S1001 = false;
            }
            if(_S1001)
            {
                _S1002 = _S869;
            }
            else
            {
                _S1002 = false;
            }
            if(_S1002)
            {
                _S1003 = _S997;
            }
            else
            {
                _S1003 = false;
            }
            bool _S1077;
            if(_S1003)
            {
                _S1077 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1077 = !_S998;
                }
                else
                {
                    _S1077 = false;
                }
            }
            if(_S1077)
            {
                return _S698;
            }
            if(viewed_1)
            {
                float3  _S1078 = throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1079 = (&lobe_5)->pdf;
                throughput_10 = _S1078;
                sky_pdf_2 = _S1079;
            }
            else
            {
                float3  _S1080 = throughput_9 * max_0((&lobe_5)->throughput, _S697);
                throughput_10 = _S1080;
                sky_pdf_2 = density_6;
            }
            bool _S1081;
            if(_S885)
            {
                _S1081 = !_S899;
            }
            else
            {
                _S1081 = false;
            }
            bool _S1082;
            if(_S1081)
            {
                _S1082 = _S869;
            }
            else
            {
                _S1082 = false;
            }
            bool _S1083;
            if(_S1082)
            {
                _S1083 = _S997;
            }
            else
            {
                _S1083 = false;
            }
            float3  chain_throughput_1;
            if(_S1083)
            {
                chain_0 = here_0;
                uint _S1084 = insertBits_0((&chain_0)->path, b_5, 18U, 3U);
                uint _S1085 = _slang_select(nee_0, 1U,0U);
                uint _S1086 = insertBits_0(_S1084, _S1085, 21U, 1U);
                (&chain_0)->path = _S1086;
                float _S1087 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1087;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            Vertex _S1088 = Vertex_x24init_0(_S998, b_5, (&lobe_5)->pdf, (F32_abs((dot_0((&surface_10)->geometry_n, throughput_8)))), is_inside_5);
            prev_0 = _S1088;
            float _S1089 = (&lobe_5)->pdf;
            bool _S1090 = b_5 == 1U;
            bool _S1091;
            if(_S1090)
            {
                _S1091 = (_S872.x) == (_S872.y);
            }
            else
            {
                _S1091 = false;
            }
            float sky_pdf_3 = _slang_select(_S1091, sky_pdf_0,_S1089);
            float _S1092 = _slang_select(_S877, 0.0f,sky_pdf_3);
            float _S1093 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1094 = !_S988;
            float _S1095 = _slang_select(_S1094, _S1093,0.0f);
            float _S1096 = spread_0 + _S1095;
            bool _S1097;
            if(refracted_4)
            {
                _S1097 = !_S994;
            }
            else
            {
                _S1097 = false;
            }
            bool is_inside_6;
            if(_S1097)
            {
                bool _S1098 = !is_inside_5;
                is_inside_6 = _S1098;
            }
            else
            {
                is_inside_6 = is_inside_5;
            }
            FKSurface _S1099 = surface_10;
            bool _S1100 = boundsVolume_0(&_S1099);
            bool _S1101;
            if(_S1100)
            {
                _S1101 = !_S999;
            }
            else
            {
                _S1101 = false;
            }
            if(_S1101)
            {
                FKSurface faced_2 = surface_10;
                float3  _S1102 = (&surface_10)->geometry_n;
                float3  _S1103 = - (&surface_10)->geometry_n;
                float3  _S1104 = _slang_select(turned_1, _S1103,_S1102);
                (&faced_2)->geometry_n = _S1104;
                FKMedium _S1105 = Medium_x24init_0(scatter_in_0, extinction_in_0);
                FKSurface _S1106 = faced_2;
                FKMedium _S1107 = _S1105;
                MediumSides _S1108 = mediumSides_0(&_S1106, &_S1107, filling_2, (&ray_2)->unit_direction);
                bool _S1109 = ((dot_0(throughput_8, (&surface_10)->geometry_n)) > 0.0f) == ((dot_0((&surface_10)->geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1110 = _slang_select(_S1109, _S1108.front.scatter,_S1108.behind.scatter);
                scatter_in_0 = _S1110;
                float3  _S1111 = _slang_select(_S1109, _S1108.front.extinction,_S1108.behind.extinction);
                extinction_in_0 = _S1111;
                uint _S1112 = _S1108.fillings.x;
                uint _S1113 = _S1108.fillings.y;
                uint _S1114 = _slang_select(_S1109, _S1113,_S1112);
                bool _S1115 = (fcptVaryingUsed());
                uint _S1116 = _slang_select(_S1115, _S1114,4294967295U);
                filling_2 = _S1116;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1117 = !_S999;
            if(_S1117)
            {
                float _S1118 = (&surface_10)->geometry_offset;
                float _S1119 = _slang_select(straight_0, 0.0f,_S1118);
                float3  _S1120 = (&surface_10)->smooth_n;
                float3  _S1121 = - (&surface_10)->smooth_n;
                bool _S1122 = is_inside_6 != _S994;
                float3  _S1123 = _slang_select(_S1122, _S1121,_S1120);
                float3  _S1124 = (&ray_2)->origin + make_float3 (_S1119) * _S1123;
                (&ray_2)->origin = _S1124;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S999;
            viewed_1 = _S992;
            sky_pdf_2 = _S1092;
            spread_3 = _S1096;
            reconnection_0 = reconnection_1;
            is_inside_4 = is_inside_6;
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
            is_inside_4 = is_inside_5;
        }
        float density_7;
        if(_S885)
        {
            if(_S838)
            {
                float3  _S1125 = throughput_9 * emission_1;
                Reservoir candidate_7 = chain_0;
                uint _S1126 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1127 = _S1126 == 1U;
                if(_S1127)
                {
                    float3  _S1128 = safeDivide(_S1125, chain_throughput_0);
                    (&candidate_7)->radiance = _S1128;
                }
                Reservoir _S1129 = withEnd(candidate_7, 2U, b_3, _S1125);
                offer(sel_1, _S1129, _S1125 * make_float3 (scale_1) / make_float3 (density_6));
            }
            if(_S838)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1130 = survivalProbability(throughput_9, density_6);
                density_7 = _S1130;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1131 = stream(_S725, b_3 + 128U);
            Random _S1132 = pcg(_S1131);
            bool _S1133 = density_7 < (_S1132.value);
            if(_S1133)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1134 = (fcptMaxBounces());
                wrong_side_0 = b_3 >= _S1134;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1135 = density_6 * density_7;
            density_7 = _S1135;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1136 = layer_0 ^ 1U;
        uint _S1137 = _slang_select(passes_0, _S1136,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_1)->distance = 0.0f;
            b_5 = b_3;
            viewed_0 = viewed_1;
            throughput_2 = throughput_9;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_0 = spread_3;
            uint _S1138 = b_5 + 1U;
            b_3 = _S1138;
            layer_0 = _S1137;
            continue;
        }
        FKRay _S1139 = ray_2;
        float _S1140 = distance_3(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_0)
        {
            refracted_4 = _S909;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S702 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1141 = _slang_select(wrong_side_0, _S1140,4.294967296e+09f);
        bool _S1142 = !_S877;
        if(straight_0)
        {
            _S945 = true;
        }
        else
        {
            _S945 = _S877;
        }
        FKHit _S1143;
        if(_S945)
        {
            _S1143 = hit_1;
        }
        else
        {
            _S1143 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
        }
        FKHit _S1144 = (fcptTraverseInstanceBVH((_S1139), (_S845), (_S1141), (_S1142), (_S1143), (viewed_1)));
        hit_1 = _S1144;
        if(replay_0)
        {
            _S946 = _S909;
        }
        else
        {
            _S946 = false;
        }
        if(_S946)
        {
            _S988 = _S702 == 1U;
        }
        else
        {
            _S988 = false;
        }
        if(_S988)
        {
            _S989 = ((&hit_1)->instance_index) == (_S714.instance_index);
        }
        else
        {
            _S989 = false;
        }
        if(_S989)
        {
            _S990 = ((&hit_1)->triangle_index) == (_S714.triangle_index);
        }
        else
        {
            _S990 = false;
        }
        if(_S990)
        {
            (&hit_1)->uv = _S714.uv;
            float _S1145 = distance_3(reconnection_0, (&ray_2)->origin);
            (&hit_1)->distance = _S1145;
        }
        if(replay_0)
        {
            _S991 = _S909;
        }
        else
        {
            _S991 = false;
        }
        if(_S991)
        {
            _S992 = _S702 == 3U;
        }
        else
        {
            _S992 = false;
        }
        if(_S992)
        {
            _S993 = ((&hit_1)->instance_index) != 4294967295U;
        }
        else
        {
            _S993 = false;
        }
        if(_S993)
        {
            return _S698;
        }
        Reservoir _S1146 = chain_0;
        uint _S1147 = filling_2;
        for(;;)
        {
            bool _S1148 = (fcptVaryingUsed());
            if(_S1148)
            {
                _S994 = _S1147 != 4294967295U;
            }
            else
            {
                _S994 = false;
            }
            float _S1149;
            if(_S994)
            {
                float _S1150 = (fcptMajorant((_S1147)));
                _S1149 = _S1150;
            }
            else
            {
                _S1149 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_0)
            {
                _S995 = _S909;
            }
            else
            {
                _S995 = false;
            }
            if(_S995)
            {
                _S996 = _S702 == 1U;
            }
            else
            {
                _S996 = false;
            }
            if(_S996)
            {
                _S997 = _S1149 > 0.0f;
            }
            else
            {
                _S997 = false;
            }
            if(_S997)
            {
                ended_0 = _S698;
                sky_pdf_1 = sky_pdf_2;
                spread_1 = spread_3;
                width_3 = width_2;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_5 = b_3;
                _S998 = true;
                break;
            }
            bool _S1151 = (&prev_0)->rough;
            if(_S1151)
            {
                _S998 = !(_S1149 > 0.0f);
            }
            else
            {
                _S998 = false;
            }
            (&prev_0)->rough = _S998;
            uint _S1152 = b_3 + 320U;
            bool _S1153 = b_3 == 4294967295U;
            uint _S1154 = _slang_select(_S1153, 384U,_S1152);
            uint _S1155 = stream(_S725, _S1154);
            uint tracking_1 = _S1155;
            weight_1 = throughput_3;
            glowed_0 = _S697;
            b_5 = b_3;
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
                    _S696 = int(2);
                    break;
                }
                uint _S1156 = b_5 + 320U;
                bool _S1157 = b_5 == 4294967295U;
                uint _S1158 = _slang_select(_S1157, 384U,_S1156);
                uint _S1159 = stream(_S725, _S1158);
                Random _S1160 = pcg(_S1159);
                float _S1161 = - (F32_log((1.0f - _S1160.value))) / _S1149;
                if(_S994)
                {
                    float3  _S1162 = (&ray_2)->origin;
                    float3  _S1163 = (&ray_2)->unit_direction;
                    float _S1164 = (&hit_1)->distance;
                    uint _S1165 = _slang_select(_S1157, 0U,b_5);
                    uint _S1166 = (&prev_0)->lobe;
                    uint _S1167 = _slang_select(_S1157, 3U,_S1166);
                    float _S1168 = (fcptTrackMedium((_S1147), (_S1162), (_S1163), (_S1164), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S1165), (_S1167), (_S1157)));
                    spread_2 = _S1168;
                }
                else
                {
                    spread_2 = _S1161;
                }
                bool _S1169 = !(spread_2 < ((&hit_1)->distance));
                if(_S1169)
                {
                    _S696 = int(2);
                    break;
                }
                if(_S994)
                {
                    _S999 = _S885;
                }
                else
                {
                    _S999 = false;
                }
                if(_S999)
                {
                    float3  _S1170 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1171 = sel_1->glow + _S1170;
                    sel_1->glow = _S1171;
                }
                else
                {
                }
                glowed_0 = _S697;
                uint b_7 = b_5 + 1U;
                float3  _S1172 = (&ray_2)->origin + make_float3 (spread_2) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1172;
                float3  _S1173 = flightWeight_0(scatter_in_0, extinction_in_0, _S1149, spread_2, true);
                float3  _S1174 = weight_1;
                float3  _S1175 = _slang_select(_S994, _S1174,_S1173);
                float3  throughput_11 = throughput_10 * _S1175;
                uint _S1176 = stream(_S725, b_7 + 320U);
                tracking_1 = _S1176;
                weight_1 = throughput_3;
                float width_6 = width_3 + spread_1 * spread_2;
                float _S1177 = spread_1 + 3.14159274101257324f;
                if(_S885)
                {
                    _S1000 = true;
                }
                else
                {
                    bool _S1178 = b_7 == _S713;
                    if(_S1178)
                    {
                        _S1000 = !_S994;
                    }
                    else
                    {
                        _S1000 = false;
                    }
                }
                TreeSample light_3;
                if(_S1000)
                {
                    float3  _S1179 = (&ray_2)->origin;
                    float3  _S1180 = (&ray_2)->unit_direction;
                    float3  _S1181 = (&ray_2)->unit_direction;
                    uint _S1182 = stream(_S725, b_7 + 64U);
                    float3  _S1183 = extinction_in_0;
                    float3  _S1184 = extinction_in_0;
                    uint2  _S1185 = make_uint2 (_S1147);
                    float3  _S1186 = (&ray_2)->unit_direction;
                    uint _S1187 = arrivalLobe_0(b_7, (&prev_0)->lobe);
                    FKHit _S1188 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                    FKHit _S1189 = _S1188;
                    ShadowContext _S1190 = ShadowContext_x24init_0(_S1183, _S1184, _S1185, _S1186, b_7, _S1187, false, spread_2, width_6, &_S1189, false);
                    ShadowContext _S1191 = _S1190;
                    TreeSample _S1192 = sampleLightTree_0(_S1179, _S1180, _S1181, 0.0f, true, _S1182, &_S1191);
                    light_3 = _S1192;
                }
                else
                {
                    light_3 = _S923;
                }
                uint _S1193 = (fcptMaxBounces());
                bool _S1194 = b_7 < _S1193;
                if(_S1194)
                {
                    _S1001 = (light_3.density) > 0.0f;
                }
                else
                {
                    _S1001 = false;
                }
                float _S1195 = _slang_select(_S1001, 0.07957746833562851f,0.0f);
                float3  _S1196 = throughput_11 * light_3.radiance;
                float _S1197 = powerHeuristic(light_3.density, _S1195);
                float3  _S1198 = _S1196 * make_float3 (0.07957746833562851f * _S1197);
                float3  _S1199 = _slang_select(_S1000, _S1198,_S697);
                if(replay_0)
                {
                    _S1002 = b_7 == _S713;
                }
                else
                {
                    _S1002 = false;
                }
                if(_S1002)
                {
                    bool _S1200 = _S702 == 2U;
                    if(_S1200)
                    {
                        float _S1201 = rgb_to_greyscale(_S1199);
                        _S1003 = _S1201 > 0.0f;
                    }
                    else
                    {
                        _S1003 = false;
                    }
                    if(_S1003)
                    {
                        Shift _S1202 = Shift_x24init_0(_S1199, 1.0f);
                        _S696 = int(1);
                        ended_0 = _S1202;
                        spread_2 = _S1177;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_6 = b_7;
                        break;
                    }
                    _S696 = int(1);
                    ended_0 = _S698;
                    spread_2 = _S1177;
                    width_4 = width_6;
                    throughput_8 = throughput_11;
                    b_6 = b_7;
                    break;
                }
                if(_S885)
                {
                    Reservoir candidate_8 = _S1146;
                    uint _S1203 = extractBits_0(_S1146.path, 10U, 2U);
                    bool _S1204 = _S1203 == 1U;
                    if(_S1204)
                    {
                        float3  _S1205 = safeDivide(_S1199, chain_throughput_0);
                        (&candidate_8)->radiance = _S1205;
                    }
                    else
                    {
                        uint _S1206 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                        uint _S1207 = insertBits_0(_S1206, 2U, 10U, 2U);
                        (&candidate_8)->path = _S1207;
                    }
                    Reservoir _S1208 = withEnd(candidate_8, 0U, b_7, _S1199);
                    offer(sel_1, _S1208, _S1199 * make_float3 (scale_1) / make_float3 (density_3));
                    float _S1209 = survivalProbability(throughput_11, density_3);
                    uint _S1210 = stream(_S725, b_7 + 128U);
                    Random _S1211 = pcg(_S1210);
                    bool _S1212 = _S1209 < (_S1211.value);
                    if(_S1212)
                    {
                        _S1003 = true;
                    }
                    else
                    {
                        uint _S1213 = (fcptMaxBounces());
                        _S1003 = b_7 >= _S1213;
                    }
                    if(_S1003)
                    {
                        _S696 = int(1);
                        ended_0 = _S698;
                        spread_2 = _S1177;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_6 = b_7;
                        break;
                    }
                    float _S1214 = density_3 * _S1209;
                    density_3 = _S1214;
                }
                else
                {
                }
                NEEVertex _S1215 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_2)->origin, _S697, (&ray_2)->origin);
                nee_vertex_0 = _S1215;
                uint _S1216 = stream(_S725, b_7);
                float3  _S1217 = isotropic_0(_S1216);
                (&ray_2)->unit_direction = _S1217;
                Vertex _S1218 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
                prev_0 = _S1218;
                float _S1219 = (&prev_0)->pdf;
                FKRay _S1220 = ray_2;
                FKHit _S1221 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1222 = (fcptTraverseInstanceBVH((_S1220), (true), (4.294967296e+09f), (false), (_S1221), (false)));
                hit_1 = _S1222;
                b_5 = b_7;
                throughput_10 = throughput_11;
                spread_1 = _S1177;
                width_3 = width_6;
                sky_pdf_1 = _S1219;
            }
            if(_S696 != int(2))
            {
                spread_1 = spread_2;
                width_3 = width_4;
                throughput_10 = throughput_8;
                b_5 = b_6;
                _S998 = true;
                break;
            }
            ended_0 = _S698;
            _S998 = false;
            break;
        }
        if(_S998)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S999 = b_5 == b_3;
        }
        else
        {
            _S999 = false;
        }
        bool _S1223 = ((&hit_1)->instance_index) == 4294967295U;
        if(_S1223)
        {
            bool _S1224 = !(&nee_vertex_0)->none;
            float _S1225 = _slang_select(_S1224, sky_pdf_1,0.0f);
            float _S1226 = escapeWeight_0(_S1225, (&ray_2)->unit_direction);
            float3  _S1227 = environment_0((&ray_2)->unit_direction, b_5, (&prev_0)->lobe);
            float3  _S1228 = throughput_10 * _S1227;
            if(replay_0)
            {
                bool _S1229 = b_5 == _S713;
                if(_S1229)
                {
                    passes_0 = _S702 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1228 * make_float3 (_S1226) / make_float3 (r_1->jac), density_3 / r_1->jac);
                }
                if(_S712)
                {
                    passes_0 = _S709;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_5 == _S700;
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
                    return Shift_x24init_0(_S1228 * make_float3 (_S1226), 1.0f);
                }
                return _S698;
            }
            Reservoir candidate_9 = chain_0;
            uint _S1230 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1231 = _S1230 == 1U;
            if(_S1231)
            {
                uint _S1232 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1233 = _S1232 == b_5;
                float _S1234 = _slang_select(_S1233, 1.0f,_S1226);
                float3  _S1235 = safeDivide(_S1228 * make_float3 (_S1234), chain_throughput_0);
                (&candidate_9)->radiance = _S1235;
            }
            else
            {
                bool _S1236 = (&prev_0)->rough;
                if(_S1236)
                {
                    uint _S1237 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                    uint _S1238 = insertBits_0(_S1237, 3U, 10U, 2U);
                    uint _S1239 = insertBits_0(_S1238, (&prev_0)->lobe, 15U, 3U);
                    bool _S1240 = (&prev_0)->inside;
                    uint _S1241 = _slang_select(_S1240, 1U,0U);
                    uint _S1242 = insertBits_0(_S1239, _S1241, 22U, 1U);
                    (&candidate_9)->path = _S1242;
                    (&candidate_9)->jac = (&prev_0)->pdf;
                    (&candidate_9)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1243 = _S1228 * make_float3 (_S1226);
            Reservoir _S1244 = withEnd(candidate_9, 3U, b_5, _S1243);
            offer(sel_1, _S1244, _S1243 * make_float3 (scale_1) / make_float3 (density_3));
            break;
        }
        float3  _S1245 = (&ray_2)->origin + make_float3 ((&hit_1)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1245;
        bool _S1246 = (fcptVaryingUsed());
        if(_S1246)
        {
            _S1000 = filling_2 != 4294967295U;
        }
        else
        {
            _S1000 = false;
        }
        if(_S1000)
        {
            if(_S885)
            {
                float3  _S1247 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1248 = sel_1->glow + _S1247;
                sel_1->glow = _S1248;
            }
            float3  _S1249 = throughput_10 * weight_1;
            throughput_8 = _S1249;
        }
        else
        {
            float3  _S1250 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_1)->distance, false);
            float3  _S1251 = throughput_10 * _S1250;
            throughput_8 = _S1251;
        }
        float _S1252 = width_3 + spread_1 * (&hit_1)->distance;
        viewed_0 = _S999;
        width_2 = _S1252;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_0 = spread_1;
        uint _S1138 = b_5 + 1U;
        b_3 = _S1138;
        layer_0 = _S1137;
    }
    return _S698;
}

static __device__ Shift shift_0(Domain * dom_1, Reservoir * r_2)
{
    Selection _S1253 = (Selection{});
    Selection sel_2 = _S1253;
    bool _S1254 = (r_2->w) <= 0.0f;
    if(_S1254)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1255 = walk_0(dom_1, r_2, true, 0.0f, &sel_2);
    return _S1255;
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
    int i_17 = int(0);
    for(;;)
    {
        if(i_17 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_8, i_17) = (F32_tan((_slang_vector_get_element(x_17, i_17))));
        i_17 = i_17 + int(1);
    }
    return result_8;
}

static __device__ float3  acos_0(float3  x_18)
{
    float3  result_9;
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
        *_slang_vector_get_element_ptr(&result_9, i_18) = (F32_acos((_slang_vector_get_element(x_18, i_18))));
        i_18 = i_18 + int(1);
    }
    return result_9;
}

static __device__ float3  abs_0(float3  x_19)
{
    float3  result_10;
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
        *_slang_vector_get_element_ptr(&result_10, i_19) = (F32_abs((_slang_vector_get_element(x_19, i_19))));
        i_19 = i_19 + int(1);
    }
    return result_10;
}

__device__ Random normal_distribution(uint state_4)
{
    Random _S1256 = pcg(state_4);
    Random _S1257 = pcg(_S1256.state);
    float _S1258 = 6.28318548202514648f * _S1256.value;
    float _S1259 = (F32_sqrt((-2.0f * clamp_0((F32_log((_S1257.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1257.state, _S1259 * (F32_cos((_S1258))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S1260;
    (&_S1260)->state = state_5;
    (&_S1260)->value = value_2;
    return _S1260;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S1261 = normal_distribution(state_6);
    Random _S1262 = normal_distribution(_S1261.state);
    Random _S1263 = normal_distribution(_S1262.state);
    float3  _S1264 = make_float3 (_S1261.value, _S1262.value, _S1263.value);
    float3  _S1265 = ((((_S1264)) * make_float3(rnorm3df(((_S1264)).x, ((_S1264)).y, ((_S1264)).z))));
    return RandomSphere_x24init_0(_S1263.state, _S1265);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_12)
{
    float3  _S1266 = p1_0 - p0_0;
    float3  _S1267 = p2_0 - p0_0;
    float2  _S1268 = uv1_0 - uv0_0;
    float2  _S1269 = uv2_0 - uv0_0;
    float _S1270 = _S1268.x;
    float _S1271 = _S1269.y;
    float _S1272 = _S1268.y;
    float _S1273 = _S1269.x;
    float _S1274 = _S1270 * _S1271 - _S1272 * _S1273;
    float _S1275 = 1.0f / _S1274;
    float3  t_1 = (_S1266 * make_float3 (_S1271) - _S1267 * make_float3 (_S1272)) * make_float3 (_S1275);
    float3  _S1276 = (_S1267 * make_float3 (_S1270) - _S1266 * make_float3 (_S1273)) * make_float3 (_S1275);
    float3  _S1277 = t_1 - n_12 * make_float3 (dot_0(n_12, t_1));
    float3  t_2 = ((((_S1277)) * make_float3(rnorm3df(((_S1277)).x, ((_S1277)).y, ((_S1277)).z))));
    bool _S1278 = (dot_0(cross_0(n_12, t_2), _S1276)) > 0.0f;
    float3  t_3;
    if(_S1278)
    {
        float3  _S1279 = negate_0(t_2);
        t_3 = _S1279;
    }
    else
    {
        t_3 = t_2;
    }
    float3  _S1280 = cross_0(n_12, t_3);
    return makeMatrix<float, 3, 3> (t_3, _S1280, n_12);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_3, float3  uvw_0, float3  position_0)
{
    float3  _S1281 = t1_0 - t0_0;
    float3  _S1282 = t2_2 - t0_0;
    float3  _S1283 = t2_2 - t1_0;
    float _S1284 = (F32_min((length_0(_S1281)), ((F32_min((length_0(_S1282)), (length_0(_S1283)))))));
    float3  _S1285 = make_float3 (distance_3(position_0, t0_0), distance_3(position_0, t1_0), distance_3(position_0, t2_2));
    float3  _S1286 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1287 = dot_0(geometry_n_3, _S1286);
    float3  _S1288 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1289 = dot_0(geometry_n_3, _S1288);
    float3  _S1290 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1291 = acos_0(abs_0(make_float3 (_S1287, _S1289, dot_0(geometry_n_3, _S1290))));
    float3  _S1292 = clamp_1(tan_0(_S1291), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_0(dot_0(_S1285 * _S1292, uvw_0), 0.0f, _S1284 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_12, float3  n_13, BSDFMaterial material_20)
{
    float3  _S1293 = negate_0(dir_12);
    float _S1294 = sign_0(dot_0(n_13, _S1293));
    float3  _S1295 = n_13 * make_float3 (_S1294);
    AnisotropicFrame _S1296 = anisotropicFrame(material_20, _S1295);
    bool _S1297 = (_S1296.alphas.x) > 0.0f;
    if(_S1297)
    {
        float _S1298 = material_20.transmission * (1.0f - material_20.metallic);
        float3  _S1299 = negate_0(_S1295);
        float3  _S1300 = anisotropicLocal(dir_12, _S1296.tangent, _S1299);
        float _S1301 = anisotropicG1(_S1300, _S1296.alphas);
        return make_float3 (_S1298 * _S1301) * material_20.albedo;
    }
    float _S1302 = material_20.transmission * (1.0f - material_20.metallic);
    float _S1303 = material_20.roughness;
    float _S1304 = smithG1(_S1303 * _S1303, (F32_abs((dot_0(n_13, dir_12)))));
    return make_float3 (_S1302 * _S1304) * material_20.albedo;
}

__device__ float hairRow(float3  in_dir_9, float3  t_4, float3  out_dir_3, uint p_5, float w_2, float alpha_17, uint nt_0)
{
    uint _S1305 = p_5 % 4U;
    float _S1306 = w_2 * HAIR_WIDTHS_0[_S1305];
    float _S1307 = (F32_asin((clamp_0(dot_0(out_dir_3, t_4), -1.0f, 1.0f)))) - (F32_asin((clamp_0(dot_0(in_dir_9, t_4), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1305] * alpha_17;
    return ((F32_asinh((_S1307 / _S1306))) / (F32_asinh((3.14159274101257324f / _S1306))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_10, float3  t_5, float3  out_dir_4, uint np_0)
{
    float3  _S1308 = worldToTangent(out_dir_4, t_5);
    float3  _S1309 = worldToTangent(in_dir_10, t_5);
    return (F32_frac((((F32_atan2((_S1308.z), (_S1308.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1309.z), (1.17549435082228751e-38f - _S1309.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_11, float3  t_6, uint p_6, float row_0, float column_0, float w_3, float alpha_18, uint nt_1, uint np_1)
{
    float3  _S1310 = worldToTangent(in_dir_11, t_6);
    uint _S1311 = p_6 % 4U;
    float _S1312 = w_3 * HAIR_WIDTHS_0[_S1311];
    float _S1313 = (F32_asin((clamp_0(dot_0(in_dir_11, t_6), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1311] * alpha_18 + _S1312 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1312))))));
    float _S1314 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1310.z), (1.17549435082228751e-38f - _S1310.x)));
    float _S1315 = (F32_cos((_S1313)));
    float3  _S1316 = tangentToWorld(make_float3 (_S1315 * (F32_cos((_S1314))), (F32_sin((_S1313))), _S1315 * (F32_sin((_S1314)))), t_6);
    return _S1316;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_14, BSDFMaterial material_21, float coverage_1)
{
    float3  _S1317;
    if((material_21.ior) == 1.0f)
    {
        float3  _S1318 = straightThrough(toward_1, n_14, material_21);
        _S1317 = _S1318;
    }
    else
    {
        _S1317 = make_float3 (0.0f);
    }
    return _S1317 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_10 = r_3;
    float3  _S1319 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_10)->f = _S1319;
    float _S1320 = r_3.jac * shifted_0.jac;
    (&candidate_10)->jac = _S1320;
    offer(sel_3, candidate_10, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S1321 = rgb_to_greyscale((&r_4)->f);
    float _S1322 = sel_4.w_sum / _S1321;
    bool _S1323 = _S1321 > 0.0f;
    float _S1324 = _slang_select(_S1323, _S1322,0.0f);
    (&r_4)->w = _S1324;
    (&r_4)->c = c_1;
    return r_4;
}

static __device__ float interpolate_0(float a_6, float b_8, float t_7)
{
    return a_6 + (b_8 - a_6) * t_7;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S1325 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S1325;
}

__device__ float2  temporalWeights(float c_2, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S1326 = c_2 * p_c_0;
    float _S1327 = c_t_0 * p_t_0;
    return make_float2 (_S1326 / (_S1326 + c_t_0 * g_previous_0), _S1327 / (_S1327 + c_2 * g_current_0));
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

__device__ Shift walk_hook(Domain dom_2, Reservoir r_5, bool replay_1, float scale_2, Selection * sel_5)
{
    Domain _S1328 = dom_2;
    Reservoir _S1329 = r_5;
    Shift _S1330 = walk_0(&_S1328, &_S1329, replay_1, scale_2, sel_5);
    return _S1330;
}

__device__ Shift shift_hook(Domain dom_3, Reservoir r_6)
{
    Domain _S1331 = dom_3;
    Reservoir _S1332 = r_6;
    Shift _S1333 = shift_0(&_S1331, &_S1332);
    return _S1333;
}

#undef Matrix
