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

static __device__ float3  skyRadiance_0(float3  origin_1, FKSurface * surface_0, float3  side_n_0, bool is_inside_1, float3  dir_1)
{
    bool _S2 = wrongSide_0(is_inside_1, false, dir_1, side_n_0);
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
};

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
    float3  _S16 = ((((light_dir_0)) * make_float3(rnorm3df(((light_dir_0)).x, ((light_dir_0)).y, ((light_dir_0)).z))));
    bool _S17 = (dot_0(smooth_n_0, _S16)) < 0.0f;
    if(_S17)
    {
        return make_float3 (0.0f);
    }
    float3  _S18 = make_float3 (geometry_offset_0) * smooth_n_0;
    float3  _S19 = origin_2 + _S18;
    FKRay _S20 = Ray_x24init_0(_S19, _S16);
    bool _S21 = (dot_0(context_0->side, light_dir_0 + _S18)) > 0.0f;
    float _S22 = shadowLength(light_dir_0);
    float3  _S23 = context_0->extinction_behind;
    float3  _S24 = context_0->extinction_front;
    float3  _S25 = _slang_select(_S21, _S24,_S23);
    uint _S26 = context_0->fillings.x;
    uint _S27 = context_0->fillings.y;
    uint _S28 = _slang_select(_S21, _S27,_S26);
    float3  _S29 = (fcptShadowTransmittanceIn((_S20), (_S22), (_S25), (_S28), (random_state_0), (context_0->depth), (context_0->lobe), (context_0->surface), (context_0->length), (context_0->width)));
    return _S29;
}

__device__ float sine(float c_0)
{
    return (F32_sqrt(((F32_max((1.0f - c_0 * c_0), (0.0f))))));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S30 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S31 = cos_a_0 > cos_b_0;
    float _S32 = _slang_select(_S31, 1.0f,_S30);
    return _S32;
}

__device__ float sinSubClamped(float sin_a_1, float cos_a_1, float sin_b_1, float cos_b_1)
{
    float _S33 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    bool _S34 = cos_a_1 > cos_b_1;
    float _S35 = _slang_select(_S34, 0.0f,_S33);
    return _S35;
}

__device__ float importance(LightNode node_0, float3  p_0, float3  normal_0)
{
    float3  _S36 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S37 = node_0.high - node_0.low;
    float3  _S38 = p_0 - _S36;
    float3  _S39 = ((((_S38)) * make_float3(rnorm3df(((_S38)).x, ((_S38)).y, ((_S38)).z))));
    float _S40 = dot_0(_S38, _S38);
    float _S41 = dot_0(_S37, _S37) / 4.0f;
    float _S42 = (F32_abs((dot_0(node_0.w, _S39))));
    float _S43 = sine(node_0.cos_theta_o);
    float _S44 = (F32_sqrt(((F32_max((1.0f - _S41 / _S40), (0.0f))))));
    bool _S45 = _S40 < _S41;
    float _S46 = _slang_select(_S45, -1.0f,_S44);
    float _S47 = sine(_S46);
    float _S48 = sine(_S42);
    float _S49 = cosSubClamped(_S48, _S42, _S43, node_0.cos_theta_o);
    float _S50 = sine(_S42);
    float _S51 = sinSubClamped(_S50, _S42, _S43, node_0.cos_theta_o);
    float _S52 = cosSubClamped(_S51, _S49, _S47, _S46);
    bool _S53 = _S52 <= 0.0f;
    if(_S53)
    {
        return 0.0f;
    }
    float _S54 = - dot_0(_S39, normal_0);
    float _S55 = node_0.phi * _S52 / (F32_max((_S40), (length_0(_S37) / 2.0f)));
    float _S56 = sine(_S54);
    float _S57 = cosSubClamped(_S56, _S54, _S47, _S46);
    bool _S58 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S59 = _slang_select(_S58, 1.0f,_S57);
    return (F32_max((_S55 * _S59), (0.0f)));
}

__device__ float childShare(LightNode first_0, LightNode second_0, float3  p_1, float3  normal_1, uint child_0)
{
    float _S60 = importance(first_0, p_1, normal_1);
    float _S61 = importance(second_0, p_1, normal_1);
    float2  _S62 = make_float2 (_S60, _S61);
    float _S63 = _slang_vector_get_element(_S62, child_0) / (_S60 + _S61);
    bool _S64 = _slang_vector_get_element(_S62, child_0) > 0.0f;
    float _S65 = _slang_select(_S64, _S63,0.0f);
    return _S65;
}

__device__ float sphereDensity(float3  center_0, float radius_0, float3  p_2)
{
    float3  _S66 = center_0 - p_2;
    float _S67 = radius_0 * radius_0 / dot_0(_S66, _S66);
    bool _S68 = _S67 >= 1.0f;
    if(_S68)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S67)))) / (6.28318548202514648f * _S67);
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S69 = left_0.y;
    float _S70 = right_0.z;
    float _S71 = left_0.z;
    float _S72 = right_0.y;
    float _S73 = right_0.x;
    float _S74 = left_0.x;
    return make_float3 (_S69 * _S70 - _S71 * _S72, _S71 * _S73 - _S74 * _S70, _S74 * _S72 - _S69 * _S73);
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_0))));
}

static __device__ float lightPdf_0(float3  origin_3, float3  smooth_n_1, float3  start_1, uint j_0, float3  light_point_0)
{
    bool _S75 = j_0 == 4294967295U;
    if(_S75)
    {
        return 0.0f;
    }
    uint4  _S76 = (fcptLightTrail((j_0)));
    uint2  _S77 = uint2 {_S76.x, _S76.y};
    uint n_0 = 0U;
    uint2  trail_0 = _S77;
    float probability_1 = 1.0f;
    for(;;)
    {
        uint4  _S78 = (fcptLightNode((n_0)));
        if((_S78.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S79 = (fcptLightSecond((n_0)));
        uint _S80 = n_0 + 1U;
        LightNode _S81 = (fcptLightBounds((_S80)));
        LightNode _S82 = (fcptLightBounds((_S79)));
        uint _S83 = trail_0.x;
        uint _S84 = _S83 & 1U;
        float _S85 = childShare(_S81, _S82, origin_3, smooth_n_1, _S84);
        float probability_2 = probability_1 * _S85;
        bool _S86 = _S84 == 1U;
        uint _S87 = _slang_select(_S86, _S79,_S80);
        uint _S88 = trail_0.y;
        uint2  _S89 = make_uint2 ((_S83 >> 1U) | (_S88 << 31U), _S88 >> 1U);
        n_0 = _S87;
        trail_0 = _S89;
        probability_1 = probability_2;
    }
    bool _S90 = (fcptSlotLeaf((n_0), (j_0)));
    bool _S91 = !_S90;
    bool _S92;
    if(_S91)
    {
        _S92 = true;
    }
    else
    {
        LightNode _S93 = (fcptLightBounds((n_0)));
        float _S94 = importance(_S93, origin_3, smooth_n_1);
        _S92 = !(_S94 > 0.0f);
    }
    if(_S92)
    {
        _S92 = true;
    }
    else
    {
        bool _S95 = (dot_0(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S95)
        {
            _S92 = !((dot_0(smooth_n_1, light_point_0 - start_1)) > 0.0f);
        }
        else
        {
            _S92 = false;
        }
    }
    if(_S92)
    {
        return 0.0f;
    }
    uint4  _S96 = (fcptLightNode((n_0)));
    bool _S97 = (_S96.x) == 2U;
    if(_S97)
    {
        uint _S98 = _S96.y;
        FKLight _S99 = (fcptLight((_S98)));
        FKLight _S100 = (fcptLight((_S98)));
        float _S101 = sphereDensity(_S99.position, _S100.variance, start_1);
        return probability_1 * _S101;
    }
    uint _S102 = _S96.y;
    uint _S103 = (fcptTriangleOffset((_S102)));
    Matrix<float, 3, 3>  _S104 = (fcptWorldTriangle((_S102), (_S103 + _S96.z)));
    float _S105 = solidAngle(probability_1, cross_0(_S104.rows[int(1)] - _S104.rows[int(0)], _S104.rows[int(2)] - _S104.rows[int(0)]), light_point_0 - start_1);
    return _S105;
}

static __device__ float3  environment_0(float3  dir_2, uint depth_0, uint lobe_0)
{
    uint2  _S106 = (fcptEnvironmentMapSize());
    bool _S107 = (_S106.x) > 1U;
    bool _S108;
    if(_S107)
    {
        uint2  _S109 = (fcptEnvironmentMapSize());
        _S108 = (_S109.y) > 1U;
    }
    else
    {
        _S108 = false;
    }
    if(_S108)
    {
        float3  _S110 = (fcptEnvMapSample((dir_2), (depth_0), (lobe_0)));
        return _S110;
    }
    float3  _S111 = (fcptAmbient());
    return _S111;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S112 = (fcptEnvironmentCdfSize());
    bool _S113 = (_S112.x) > 1U;
    bool _S114;
    if(_S113)
    {
        uint2  _S115 = (fcptEnvironmentCdfSize());
        _S114 = (_S115.y) > 1U;
    }
    else
    {
        _S114 = false;
    }
    bool _S116 = !_S114;
    if(_S116)
    {
        return false;
    }
    uint2  _S117 = (fcptEnvironmentMapSize());
    bool _S118 = (_S117.x) > 1U;
    if(_S118)
    {
        uint2  _S119 = (fcptEnvironmentMapSize());
        _S114 = (_S119.y) > 1U;
    }
    else
    {
        _S114 = false;
    }
    return _S114;
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
    uint2  _S120 = (fcptEnvironmentCdfSize());
    uint2  _S121 = _S120 - make_uint2 (1U, 0U);
    float2  _S122 = make_float2 ((F32_atan2((- dir_3.z), (- dir_3.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_0(dir_3.y, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S123 = make_float2 ((float)_S121.x, (float)_S121.y);
    float2  _S124 = _S122 * _S123;
    uint2  _S125 = make_uint2 ((uint)_S124.x, (uint)_S124.y);
    uint2  _S126 = min_0(_S125, _S121 - make_uint2 (1U));
    float4  _S127 = (fcptEnvironmentCdf((_S126)));
    float _S128 = _S127.y;
    uint _S129 = _S121.x;
    float4  _S130 = (fcptEnvironmentCdf((make_uint2 (_S129, _S126.y))));
    float _S131 = _S128 * _S130.y;
    return _S131 * float(_S129 * _S121.y) / (19.73921012878417969f * length_1(float2 {dir_3.x, dir_3.z}));
}

static __device__ float escapeWeight_0(float pdf_0, float3  dir_4)
{
    bool _S132 = pdf_0 <= 0.0f;
    bool _S133;
    if(_S132)
    {
        _S133 = true;
    }
    else
    {
        bool _S134 = environmentMapped_0();
        _S133 = !_S134;
    }
    if(_S133)
    {
        return 1.0f;
    }
    float _S135 = environmentPdf_0(dir_4);
    return pdf_0 / (pdf_0 + _S135);
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
    uint _S136 = x_6 * 747796405U + 2891336453U;
    uint _S137 = ((_S136 >> ((_S136 >> 28U) + 4U)) ^ _S136) * 277803737U;
    return (_S137 >> 22U) ^ _S137;
}

static __device__ float random_0(uint * state_0)
{
    uint _S138 = hash(*state_0);
    *state_0 = _S138;
    return float((*state_0) >> int(8)) * 5.9604644775390625e-08f;
}

static __device__ Random Random_x24init_0(uint state_1, float value_0)
{
    Random _S139;
    (&_S139)->state = state_1;
    (&_S139)->value = value_0;
    return _S139;
}

__device__ Random pcg(uint state_2)
{
    uint _S140 = state_2;
    float value_1 = random_0(&_S140);
    return Random_x24init_0(_S140, value_1);
}

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
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
    float _S141;
    if(e_0 > 0.0f)
    {
        _S141 = 1.0f;
    }
    else
    {
        if(e_0 < 0.0f)
        {
            _S141 = -1.0f;
        }
        else
        {
            _S141 = 0.0f;
        }
    }
    return _S141;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S142;
    (&_S142)->tangent = tangent_0;
    (&_S142)->alphas = alphas_0;
    return _S142;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_0 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S143 = (F32_abs((dot_0(n_1, a_0)))) > 0.9999847412109375f;
    float3  a_1;
    if(_S143)
    {
        float3  _S144 = make_float3 (1.0f, 0.0f, 0.0f);
        a_1 = _S144;
    }
    else
    {
        a_1 = a_0;
    }
    float3  _S145 = cross_0(n_1, a_1);
    float3  _S146 = ((((_S145)) * make_float3(rnorm3df(((_S145)).x, ((_S145)).y, ((_S145)).z))));
    float3  _S147 = cross_0(n_1, _S146);
    return make_float3 (v_0.x) * _S146 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S147;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_0, float3  n_i_0)
{
    float _S148 = material_0.roughness;
    float _S149 = _S148 * _S148;
    bool _S150 = (material_0.anisotropy) == 0.0f;
    bool _S151;
    if(_S150)
    {
        _S151 = true;
    }
    else
    {
        _S151 = !(_S149 > 0.0f);
    }
    if(_S151)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S152 = material_0.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_0.tangent));
    float3  _S153 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S154 = (dot_0(_S152, _S152)) > 0.0f;
    float3  _S155 = _slang_select(_S154, _S152,_S153);
    float3  _S156 = ((((_S155)) * make_float3(rnorm3df(((_S155)).x, ((_S155)).y, ((_S155)).z))));
    float _S157 = 6.28318548202514648f * material_0.anisotropic_rotation;
    float _S158 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_0.anisotropy))))));
    float _S159 = 1.0f / _S158;
    bool _S160 = (material_0.anisotropy) < 0.0f;
    float _S161 = _slang_select(_S160, _S159,_S158);
    return AnisotropicFrame_x24init_0(_S156 * make_float3 ((F32_cos((_S157)))) + cross_0(n_i_0, _S156) * make_float3 ((F32_sin((_S157)))), make_float2 (_S149 / _S161, _S149 * _S161));
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
    float3  _S162 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S163 = ((((_S162)) * make_float3(rnorm3df(((_S162)).x, ((_S162)).y, ((_S162)).z))));
    float _S164 = _S163.x;
    float _S165 = _S163.y;
    float _S166 = _S164 * _S164 + _S165 * _S165;
    float3  _S167;
    if(_S166 > 0.0f)
    {
        float3  _S168 = make_float3 (- _S165, _S164, 0.0f);
        float _S169 = (rsqrtf((_S166)));
        _S167 = _S168 * make_float3 (_S169);
    }
    else
    {
        _S167 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S170 = cross_0(_S163, _S167);
    float _S171 = (F32_sqrt((U1_0)));
    float _S172 = 6.28318548202514648f * U2_0;
    float _S173 = _S171 * (F32_cos((_S172)));
    float t2_0 = _S171 * (F32_sin((_S172)));
    float _S174 = 0.5f * (1.0f + _S163.z);
    float t2_1 = (1.0f - _S174) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S173 * _S173)))))) + _S174 * t2_0;
    float3  _S175 = make_float3 (_S173) * _S167 + make_float3 (t2_1) * _S170;
    float _S176 = unshared_0(_S173);
    float _S177 = unshared_0(_S173);
    float3  _S178 = _S175 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S176 * _S177 - t2_1 * t2_1))))))) * _S163;
    float3  _S179 = make_float3 (alpha_0 * _S178.x, alpha_0 * _S178.y, (F32_max((0.0f), (_S178.z))));
    float3  _S180 = ((((_S179)) * make_float3(rnorm3df(((_S179)).x, ((_S179)).y, ((_S179)).z))));
    return _S180;
}

__device__ float3  sampleAnisotropicVNDF(float3  Ve_1, float2  alphas_1, float U1_1, float U2_1)
{
    float _S181 = alphas_1.x;
    float _S182 = alphas_1.y;
    float3  _S183 = make_float3 (_S181 * Ve_1.x, _S182 * Ve_1.y, Ve_1.z);
    float3  _S184 = ((((_S183)) * make_float3(rnorm3df(((_S183)).x, ((_S183)).y, ((_S183)).z))));
    float3  _S185 = sampleGGXVNDF(_S184, 1.0f, U1_1, U2_1);
    float3  _S186 = make_float3 (_S181 * _S185.x, _S182 * _S185.y, _S185.z);
    float3  _S187 = ((((_S186)) * make_float3(rnorm3df(((_S186)).x, ((_S186)).y, ((_S186)).z))));
    return _S187;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
{
    float3  a_2 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S188 = (F32_abs((dot_0(n_3, a_2)))) > 0.9999847412109375f;
    float3  a_3;
    if(_S188)
    {
        float3  _S189 = make_float3 (1.0f, 0.0f, 0.0f);
        a_3 = _S189;
    }
    else
    {
        a_3 = a_2;
    }
    float3  _S190 = cross_0(n_3, a_3);
    float3  _S191 = ((((_S190)) * make_float3(rnorm3df(((_S190)).x, ((_S190)).y, ((_S190)).z))));
    float3  _S192 = cross_0(n_3, _S191);
    return make_float3 (dot_0(v_1, _S191), dot_0(v_1, n_3), dot_0(v_1, _S192));
}

__device__ __forceinline__ float3  sampleMaterialHalfVector(float3  v_2, float3  n_i_1, float alpha_1, AnisotropicFrame frame_0, uint * random_state_1)
{
    Random _S193 = pcg(*random_state_1);
    Random _S194 = pcg(_S193.state);
    *random_state_1 = _S194.state;
    bool _S195 = (frame_0.alphas.x) > 0.0f;
    if(_S195)
    {
        float3  _S196 = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        float3  _S197 = sampleAnisotropicVNDF(_S196, frame_0.alphas, _S193.value, _S194.value);
        return make_float3 (_S197.x) * frame_0.tangent + make_float3 (_S197.y) * cross_0(n_i_1, frame_0.tangent) + make_float3 (_S197.z) * n_i_1;
    }
    float3  _S198 = worldToTangent(v_2, n_i_1);
    float3  _S199 = sampleGGXVNDF(float3 {_S198.x, _S198.z, _S198.y}, alpha_1, _S193.value, _S194.value);
    float3  _S200 = float3 {_S199.x, _S199.z, _S199.y};
    float3  _S201 = tangentToWorld(_S200, n_i_1);
    return _S201;
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
    float _S202 = dot_0(n_4, i_1);
    float _S203 = 1.0f - eta_0 * eta_0 * (1.0f - _S202 * _S202);
    if(_S203 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_1 - make_float3 (eta_0 * _S202 + (F32_sqrt((_S203)))) * n_4;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S204 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S205 = eta_i_0 / eta_o_0 * _S204;
    bool _S206 = _S205 < 1.0f;
    float kr_0;
    if(_S206)
    {
        float _S207 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S205 * _S205))))));
        float _S208 = eta_o_0 * cos_theta_0;
        float _S209 = eta_i_0 * _S207;
        float _S210 = (_S208 - _S209) / (_S208 + _S209);
        float _S211 = eta_i_0 * cos_theta_0;
        float _S212 = eta_o_0 * _S207;
        float _S213 = (_S211 - _S212) / (_S211 + _S212);
        float _S214 = (_S210 * _S210 + _S213 * _S213) / 2.0f;
        kr_0 = _S214;
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
    float _S215 = (F32_sqrt((0.05000000074505806f)));
    float _S216 = clamp_0((F32_sqrt(((F32_max((mu_0), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
    float _S217 = (clamp_0((F32_sqrt(((F32_max((r_0), (0.0f)))))), _S215, 1.0f) - _S215) / (1.0f - _S215) * 23.0f;
    uint _S218 = (U32_min((uint(_S216)), (22U)));
    uint _S219 = (U32_min((uint(_S217)), (22U)));
    float _S220 = _S216 - float(_S218);
    float _S221 = _S217 - float(_S219);
    uint _S222 = _S218 * 24U + _S219;
    uint _S223 = _S222 + 24U;
    float _S224 = SHEEN_ALBEDO_0[_S222] + (SHEEN_ALBEDO_0[_S223] - SHEEN_ALBEDO_0[_S222]) * _S220;
    uint _S225 = _S222 + 1U;
    float _S226 = SHEEN_ALBEDO_0[_S225] + (SHEEN_ALBEDO_0[_S223 + 1U] - SHEEN_ALBEDO_0[_S225]) * _S220;
    return (F32_exp((_S224 + (_S226 - _S224) * _S221)));
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

__device__ float anisotropicG1(float3  w_1, float2  alphas_2)
{
    float _S227 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S227 / (_S227 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S227)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S228 = alphas_3.x;
    float _S229 = h_0.x / _S228;
    float _S230 = alphas_3.y;
    float _S231 = h_0.y / _S230;
    float _S232 = h_0.z;
    float _S233 = _S229 * _S229 + _S231 * _S231 + _S232 * _S232;
    return 1.0f / (F32_max((3.14159274101257324f * _S228 * _S230 * _S233 * _S233), (1.17549435082228751e-38f)));
}

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_0, float3  refracted_1, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_0, float3  sheen_0, float3  view_0, float3  tangent_1, float2  alphas_4, float visible_0)
{
    BSDFLobes _S234;
    (&_S234)->v_dot_h = v_dot_h_0;
    (&_S234)->n_dot_h = n_dot_h_0;
    (&_S234)->refracted = refracted_1;
    (&_S234)->F = F_0;
    (&_S234)->F_greyscale = F_greyscale_0;
    (&_S234)->reflect_weight = reflect_weight_0;
    (&_S234)->diffuse_weight = diffuse_weight_0;
    (&_S234)->refract_weight = refract_weight_0;
    (&_S234)->p_diffuse = p_diffuse_0;
    (&_S234)->p_reflect = p_reflect_0;
    (&_S234)->p_refract = p_refract_0;
    (&_S234)->translucent_share = translucent_share_0;
    (&_S234)->sheen = sheen_0;
    (&_S234)->view = view_0;
    (&_S234)->tangent = tangent_1;
    (&_S234)->alphas = alphas_4;
    (&_S234)->visible = visible_0;
    return _S234;
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_0, float3  v_3, float3  n_i_2, float3  ggx_n_0, BSDFMaterial material_1, float eta_i_1, float eta_o_1, AnisotropicFrame frame_1)
{
    float _S235 = dot_0(ggx_n_0, v_3);
    float _S236 = dot_0(n_i_2, ggx_n_0);
    float _S237 = eta_i_1 / eta_o_1;
    float3  _S238 = refract_0(in_dir_0, ggx_n_0, _S237);
    float3  _S239 = ((((_S238)) * make_float3(rnorm3df(((_S238)).x, ((_S238)).y, ((_S238)).z))));
    float _S240 = (F32_min(((F32_sqrt((material_1.specular_level))) * (F32_abs((eta_i_1 - eta_o_1))) / (eta_i_1 + eta_o_1)), (0.9999847412109375f)));
    float _S241 = _S240 * _S240;
    float _S242 = (1.0f + _S240) / (1.0f - _S240);
    float _S243 = (F32_abs((_S235)));
    bool _S244 = eta_i_1 > eta_o_1;
    float sheen_component_0;
    if(_S244)
    {
        sheen_component_0 = _S242;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float visible_1;
    if(_S244)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S242;
    }
    float _S245 = fresnel(_S243, sheen_component_0, visible_1);
    bool _S246 = (eta_i_1 * eta_i_1 * (1.0f - _S235 * _S235)) >= (eta_o_1 * eta_o_1);
    float3  _S247;
    if(_S246)
    {
        _S247 = make_float3 (1.0f);
    }
    else
    {
        float3  _S248 = material_1.specular_tint * make_float3 (_S241);
        _S247 = _S248 + (make_float3 (1.0f) - _S248) * make_float3 (_S245 - _S241) / make_float3 (1.0f - _S241);
    }
    float3  _S249 = make_float3 (1.0f);
    float3  _S250 = make_float3 (0.0f);
    float _S251 = rgb_to_greyscale(material_1.sheen);
    bool _S252 = _S251 > 0.0f;
    float3  scale_0;
    float3  sheen_1;
    float3  view_1;
    if(_S252)
    {
        float _S253 = sheenAlbedo(dot_0(n_i_2, v_3), material_1.sheen_roughness);
        float _S254 = (F32_min((_S253), (1.0f)));
        float3  _S255 = make_float3 (1.0f) - material_1.sheen * make_float3 (_S254);
        float _S256 = rgb_to_greyscale(material_1.sheen);
        float _S257 = _S256 * _S254;
        float3  _S258 = material_1.sheen / make_float3 ((F32_max((_S253), (1.0f))));
        scale_0 = _S255;
        sheen_component_0 = _S257;
        sheen_1 = _S258;
        view_1 = v_3;
    }
    else
    {
        scale_0 = _S249;
        sheen_component_0 = 0.0f;
        sheen_1 = _S250;
        view_1 = _S250;
    }
    float3  _S259 = mix_0(_S247, material_1.albedo, material_1.metallic);
    float3  F_1 = _S259 * scale_0;
    float _S260 = rgb_to_greyscale(F_1);
    float _S261 = 1.0f - material_1.metallic;
    float3  _S262 = make_float3 (1.0f) - _S247;
    float3  _S263 = make_float3 ((1.0f - material_1.transmission) * _S261) * _S262 * scale_0;
    float3  _S264 = make_float3 (material_1.transmission * _S261) * _S262 * scale_0;
    float _S265 = (F32_max((_S260), (0.0f)));
    float _S266 = rgb_to_greyscale(_S263);
    float _S267 = (F32_max((_S266), (0.0f)));
    float _S268 = rgb_to_greyscale(_S264);
    float _S269 = sign_0(length_0(_S239));
    float _S270 = (F32_max((_S268 * _S269), (0.0f)));
    float _S271 = _S265 + _S267 + _S270 + sheen_component_0;
    float _S272 = 1.0f / (F32_max((_S271), (0.0000152587890625f)));
    float _S273 = (_S267 + sheen_component_0) * _S272;
    float _S274 = _S265 * _S272;
    float _S275 = _S270 * _S272;
    bool _S276 = (frame_1.alphas.x) > 0.0f;
    if(_S276)
    {
        float3  _S277 = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        float _S278 = anisotropicG1(_S277, frame_1.alphas);
        float3  _S279 = anisotropicLocal(ggx_n_0, frame_1.tangent, n_i_2);
        float _S280 = anisotropicD(_S279, frame_1.alphas);
        float _S281 = _S278 * _S280;
        visible_1 = _S281;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S235, _S236, _S239, F_1, _S260, 1.0f, _S263, _S264, _S273, _S274, _S275, 0.0f, sheen_1, view_1, frame_1.tangent, frame_1.alphas, visible_1);
}

__device__ float translucentShare(BSDFMaterial material_2)
{
    float _S282 = rgb_to_greyscale(material_2.translucent);
    float _S283 = rgb_to_greyscale(material_2.albedo);
    float _S284 = _S282 / (_S283 + _S282);
    bool _S285 = _S282 > 0.0f;
    float _S286 = _slang_select(_S285, _S284,0.0f);
    return _S286;
}

__device__ float smithG1(float alpha_2, float n_dot_x_0)
{
    float _S287 = alpha_2 * alpha_2;
    float _S288 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S287 + (1.0f - _S287) * n_dot_x_0 * n_dot_x_0))));
    bool _S289 = alpha_2 > 0.0f;
    float _S290 = _slang_select(_S289, _S288,1.0f);
    return _S290;
}

__device__ float trowbridgeReitz(float alpha_3, float n_dot_h_1)
{
    float _S291 = alpha_3 * alpha_3;
    float _S292 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S291 * n_dot_h_1 * n_dot_h_1;
    return _S291 / (F32_max((3.14159274101257324f * _S292 * _S292), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, BSDFLobes lobes_0, float eta_i_2, float eta_o_2, uint lobe_1)
{
    bool _S293 = lobe_1 == 0U;
    if(_S293)
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
    float _S304 = smithG1(alpha_4, n_i_dot_v_0);
    float _S305 = _S304 * lobes_0.v_dot_h;
    float _S306 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    float _S307 = _S305 * _S306 / n_i_dot_v_0;
    bool _S308 = alpha_4 > 0.0f;
    bool _S309;
    if(_S308)
    {
        _S309 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S309 = false;
    }
    if(_S309)
    {
        _S309 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S309 = false;
    }
    if(_S309)
    {
        _S309 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S309 = false;
    }
    float _S310 = _slang_select(_S309, _S307,0.0f);
    bool _S311 = (lobes_0.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S311)
    {
        float _S312 = lobes_0.visible * lobes_0.v_dot_h / n_i_dot_v_0;
        bool _S313 = (lobes_0.v_dot_h) > 0.0f;
        if(_S313)
        {
            _S309 = (lobes_0.n_dot_h) > 0.0f;
        }
        else
        {
            _S309 = false;
        }
        if(_S309)
        {
            _S309 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S309 = false;
        }
        float _S314 = _slang_select(_S309, _S312,0.0f);
        pdf_h_0 = _S314;
    }
    else
    {
        pdf_h_0 = _S310;
    }
    bool _S315 = lobe_1 == 1U;
    if(_S315)
    {
        float _S316 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        float _S317 = lobes_0.p_refract * pdf_h_0 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S316 * _S316);
        bool _S318 = eta_i_2 != eta_o_2;
        if(_S318)
        {
            _S309 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S309 = false;
        }
        float _S319 = _slang_select(_S309, _S317,0.0f);
        return _S319;
    }
    float _S320 = lobes_0.p_reflect * pdf_h_0 / (4.0f * lobes_0.v_dot_h);
    bool _S321 = pdf_h_0 > 0.0f;
    float _S322 = _slang_select(_S321, _S320,0.0f);
    return _S322;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_0, uint random_state_2, bool refracted_2, uint lobe_2, float pdf_1)
{
    SampleBSDF _S323;
    (&_S323)->unit_direction = unit_direction_1;
    (&_S323)->throughput = throughput_0;
    (&_S323)->random_state = random_state_2;
    (&_S323)->refracted = refracted_2;
    (&_S323)->lobe = lobe_2;
    (&_S323)->pdf = pdf_1;
    return _S323;
}

__device__ float sheenBRDF(float3  l_0, float3  v_4, float3  n_5, float r_1)
{
    float _S324 = 1.0f / (F32_max((r_1), (0.05000000074505806f)));
    float3  _S325 = l_0 + v_4;
    float3  _S326 = ((((_S325)) * make_float3(rnorm3df(((_S325)).x, ((_S325)).y, ((_S325)).z))));
    float _S327 = dot_0(n_5, _S326);
    float _S328 = (F32_max((dot_0(n_5, l_0)), (0.0f)));
    float _S329 = (F32_max((dot_0(n_5, v_4)), (0.0f)));
    return (2.0f + _S324) * (F32_pow(((F32_max((1.0f - _S327 * _S327), (0.0f)))), (0.5f * _S324))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S328 + _S329 - _S328 * _S329)), (0.0000152587890625f)));
}

__device__ __forceinline__ float3  lobeThroughput(float3  l_1, float3  n_i_3, float alpha_5, BSDFMaterial material_3, BSDFLobes lobes_1, uint lobe_3)
{
    bool _S330 = lobe_3 == 0U;
    if(_S330)
    {
        bool _S331 = (dot_0(n_i_3, l_1)) < 0.0f;
        float3  _S332 = _slang_select(_S331, material_3.translucent,material_3.albedo);
        float _S333 = 1.0f - lobes_1.translucent_share;
        float _S334 = _slang_select(_S331, lobes_1.translucent_share,_S333);
        float3  _S335 = _S332 / make_float3 (_S334);
        bool _S336 = (lobes_1.translucent_share) > 0.0f;
        float3  _S337 = _slang_select(_S336, _S335,material_3.albedo);
        float _S338 = rgb_to_greyscale(material_3.sheen);
        bool _S339 = _S338 > 0.0f;
        bool _S340;
        if(_S339)
        {
            _S340 = !_S331;
        }
        else
        {
            _S340 = false;
        }
        if(_S340)
        {
            float3  _S341 = lobes_1.diffuse_weight * _S337;
            float3  _S342 = lobes_1.sheen * make_float3 (3.14159274101257324f);
            float _S343 = sheenBRDF(l_1, lobes_1.view, n_i_3, material_3.sheen_roughness);
            float3  _S344 = _S342 * make_float3 (_S343);
            float _S345 = _slang_select(_S336, _S333,1.0f);
            return (_S341 + _S344 / make_float3 (_S345)) / make_float3 (lobes_1.p_diffuse);
        }
        return lobes_1.diffuse_weight * _S337 / make_float3 (lobes_1.p_diffuse);
    }
    bool _S346 = lobe_3 == 1U;
    float G1_l_0;
    if(_S346)
    {
        float _S347 = - dot_0(n_i_3, l_1);
        float _S348 = smithG1(alpha_5, (F32_max((_S347), (0.0f))));
        bool _S349 = (lobes_1.alphas.x) > 0.0f;
        if(_S349)
        {
            float3  _S350 = negate_0(n_i_3);
            float3  _S351 = anisotropicLocal(l_1, lobes_1.tangent, _S350);
            float _S352 = anisotropicG1(_S351, lobes_1.alphas);
            G1_l_0 = _S352;
        }
        else
        {
            G1_l_0 = _S348;
        }
        return lobes_1.refract_weight * make_float3 (G1_l_0) * material_3.albedo / make_float3 (lobes_1.p_refract);
    }
    float _S353 = dot_0(n_i_3, l_1);
    float _S354 = smithG1(alpha_5, (F32_max((_S353), (0.0f))));
    bool _S355 = (lobes_1.alphas.x) > 0.0f;
    if(_S355)
    {
        float3  _S356 = anisotropicLocal(l_1, lobes_1.tangent, n_i_3);
        float _S357 = anisotropicG1(_S356, lobes_1.alphas);
        G1_l_0 = _S357;
    }
    else
    {
        G1_l_0 = _S354;
    }
    return make_float3 (lobes_1.reflect_weight * G1_l_0) * lobes_1.F / make_float3 (lobes_1.p_reflect);
}

__device__ __forceinline__ SampleBSDF connectBSDF(float3  in_dir_1, float3  out_dir_0, float3  n_6, BSDFMaterial material_4, float eta_i_3, float eta_o_3, uint lobe_4, uint random_init_0)
{
    uint random_state_3 = random_init_0;
    float3  _S358 = negate_0(in_dir_1);
    float _S359 = dot_0(n_6, _S358);
    float _S360 = sign_0(_S359);
    float3  _S361 = n_6 * make_float3 (_S360);
    float _S362 = material_4.roughness;
    float _S363 = _S362 * _S362;
    AnisotropicFrame _S364 = anisotropicFrame(material_4, _S361);
    float3  _S365 = _S358 + out_dir_0;
    float3  _S366 = ((((_S365)) * make_float3(rnorm3df(((_S365)).x, ((_S365)).y, ((_S365)).z))));
    bool _S367 = lobe_4 == 0U;
    float3  ggx_n_1;
    if(_S367)
    {
        float3  _S368 = sampleMaterialHalfVector(_S358, _S361, _S363, _S364, &random_state_3);
        ggx_n_1 = _S368;
    }
    else
    {
        bool _S369 = lobe_4 == 1U;
        if(_S369)
        {
            float3  _S370 = negate_0(make_float3 (eta_i_3) * _S358 + make_float3 (eta_o_3) * out_dir_0);
            float3  _S371 = ((((_S370)) * make_float3(rnorm3df(((_S370)).x, ((_S370)).y, ((_S370)).z))));
            float _S372 = sign_0(dot_0(_S370, _S361));
            float3  _S373 = _S371 * make_float3 (_S372);
            ggx_n_1 = _S373;
        }
        else
        {
            ggx_n_1 = _S366;
        }
    }
    BSDFLobes _S374 = bsdfLobes(in_dir_1, _S358, _S361, ggx_n_1, material_4, eta_i_3, eta_o_3, _S364);
    BSDFLobes lobes_2 = _S374;
    float _S375 = translucentShare(material_4);
    (&lobes_2)->translucent_share = _S375;
    float _S376 = lobeDensity(dot_0(_S361, out_dir_0), dot_0(out_dir_0, ggx_n_1), (F32_abs((_S359))), _S363, lobes_2, eta_i_3, eta_o_3, lobe_4);
    bool _S377 = !(_S376 > 0.0f);
    if(_S377)
    {
        float3  _S378 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S378, _S378, 0U, false, 0U, 0.0f);
    }
    float3  _S379 = lobeThroughput(out_dir_0, _S361, _S363, material_4, lobes_2, lobe_4);
    return SampleBSDF_x24init_0(out_dir_0, _S379, random_state_3, lobe_4 == 1U, lobe_4, _S376);
}

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_2, float3  dir_5, float3  n_7, BSDFMaterial material_5, float eta_i_4, float eta_o_4, bool refracted_3, float pdf_2, bool power_0, uint random_state_4)
{
    float3  _S380 = make_float3 (0.0f);
    uint lobe_5 = 0U;
    float3  f_0 = _S380;
    for(;;)
    {
        if(lobe_5 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S381 = lobe_5 == 0U;
        if(_S381)
        {
        }
        bool _S382;
        if(_S381)
        {
            float _S383 = rgb_to_greyscale(material_5.translucent);
            _S382 = _S383 > 0.0f;
        }
        else
        {
            _S382 = false;
        }
        bool _S384;
        if(_S382)
        {
            float _S385 = dot_0(n_7, dir_5);
            float3  _S386 = negate_0(in_dir_2);
            _S384 = ((_S385 * dot_0(n_7, _S386)) < 0.0f) == refracted_3;
        }
        else
        {
            _S384 = (lobe_5 == 1U) == refracted_3;
        }
        float3  f_1;
        if(_S384)
        {
            SampleBSDF _S387 = connectBSDF(in_dir_2, dir_5, n_7, material_5, eta_i_4, eta_o_4, lobe_5, random_state_4);
            bool _S388 = (_S387.pdf) > 0.0f;
            if(_S388)
            {
                if(power_0)
                {
                    float _S389 = _S387.pdf / pdf_2;
                    float3  f_2 = f_0 + _S387.throughput * make_float3 (_S387.pdf) / make_float3 (pdf_2 * (1.0f + _S389 * _S389));
                    f_1 = f_2;
                }
                else
                {
                    float3  f_3 = f_0 + _S387.throughput * make_float3 (_S387.pdf) / make_float3 (_S387.pdf + pdf_2);
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
    bool _S390 = wrongSide_0(is_inside_2, false, dir_6, side_n_1);
    float3  _S391 = neeBSDF(in_dir_3, dir_6, surface_1.smooth_n, surface_1.material, eta_1.x, eta_1.y, _S390, pdf_3, false, random_state_5);
    return _S391;
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
    SkySample _S392;
    (&_S392)->dir = dir_7;
    (&_S392)->radiance = radiance_0;
    (&_S392)->color = color_0;
    (&_S392)->random_state = random_state_6;
    return _S392;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float3  side_n_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0)
{
    uint2  _S393 = (fcptEnvironmentCdfSize());
    uint2  _S394 = make_uint2 (1U, 0U);
    uint2  _S395 = _S393 - _S394;
    Random _S396 = pcg(init_random_state_0);
    Random _S397 = pcg(_S396.state);
    Random _S398 = pcg(_S397.state);
    Random _S399 = pcg(_S398.state);
    uint _S400 = _S395.x;
    uint _S401 = searchCDF_0(make_uint2 (_S400, 0U), make_uint2 (0U, 1U), _S395.y, _S396.value);
    uint _S402 = searchCDF_0(make_uint2 (0U, _S401), _S394, _S400, _S397.value);
    float2  _S403 = make_float2 ((float)_S395.x, (float)_S395.y);
    float2  _S404 = (make_float2 (float(_S402), float(_S401)) + make_float2 (_S398.value, _S399.value)) / _S403 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S405 = _S404.y;
    float _S406 = (F32_sin((_S405)));
    float _S407 = _S404.x;
    float3  _S408 = make_float3 (_S406 * (F32_cos((_S407))), (F32_cos((_S405))), _S406 * (F32_sin((_S407))));
    float _S409 = environmentPdf_0(_S408);
    float3  _S410 = skyBSDF(ray_0->unit_direction, _S408, *surface_2, side_n_2, eta_2, is_inside_3, _S409, lobe_state_0);
    bool _S411 = !(_S409 > 0.0f);
    bool _S412;
    if(_S411)
    {
        _S412 = true;
    }
    else
    {
        _S412 = all_0(_S410 == make_float3 (0.0f));
    }
    if(_S412)
    {
        float3  _S413 = make_float3 (0.0f);
        return SkySample_x24init_0(_S408, _S413, _S413, _S399.state);
    }
    float3  _S414 = skyRadiance_0(ray_0->origin, surface_2, side_n_2, is_inside_3, _S408);
    return SkySample_x24init_0(_S408, _S414, _S410 * _S414, _S399.state);
}

struct TreeSample
{
    float3  dir;
    float3  radiance;
    float density;
    uint random_state;
};

static __device__ TreeSample TreeSample_x24init_0(float3  dir_8, float3  radiance_1, float density_0, uint random_state_7)
{
    TreeSample _S415;
    (&_S415)->dir = dir_8;
    (&_S415)->radiance = radiance_1;
    (&_S415)->density = density_0;
    (&_S415)->random_state = random_state_7;
    return _S415;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_3, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S416 = importance(first_1, p_3, normal_3);
    float _S417 = importance(second_1, p_3, normal_3);
    float2  _S418 = make_float2 (_S416, _S417);
    bool _S419 = _S416 == 0.0f;
    bool _S420;
    if(_S419)
    {
        _S420 = _S417 == 0.0f;
    }
    else
    {
        _S420 = false;
    }
    if(_S420)
    {
        return 2U;
    }
    float _S421 = _S416 + _S417;
    bool _S422 = _S417 > 0.0f;
    if(_S422)
    {
        _S420 = (*pick_0 * _S421) >= _S416;
    }
    else
    {
        _S420 = false;
    }
    uint _S423 = uint(_S420);
    float _S424 = (F32_min(((*pick_0 * _S421 - float(_S423) * _S416) / _slang_vector_get_element(_S418, _S423)), (0.99999994039535522f)));
    *pick_0 = _S424;
    float _S425 = *probability_3 * (_slang_vector_get_element(_S418, _S423) / _S421);
    *probability_3 = _S425;
    return _S423;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_4, float u1_0, float u2_0)
{
    float3  _S426 = center_1 - p_4;
    float _S427 = radius_1 * radius_1 / dot_0(_S426, _S426);
    float _S428 = u1_0 * _S427 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S427), (0.0f)))))));
    float _S429 = 2.0f * u1_0;
    bool _S430 = _S427 >= 1.0f;
    float _S431 = _slang_select(_S430, _S429,_S428);
    float _S432 = (F32_sqrt(((F32_max((_S431 * (2.0f - _S431)), (0.0f))))));
    float _S433 = 6.28318548202514648f * u2_0;
    float3  _S434 = make_float3 (_S432 * (F32_cos((_S433))), 1.0f - _S431, _S432 * (F32_sin((_S433))));
    float3  _S435 = ((((_S426)) * make_float3(rnorm3df(((_S426)).x, ((_S426)).y, ((_S426)).z))));
    float3  _S436 = tangentToWorld(_S434, _S435);
    return _S436;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S437 = center_2 - ray_1->origin;
    float _S438 = dot_0(_S437, ray_1->unit_direction);
    float _S439 = dot_0(_S437, _S437) - _S438 * _S438;
    float _S440 = radius_3 * radius_3;
    bool _S441 = _S439 > _S440;
    if(_S441)
    {
        return 4.294967296e+09f;
    }
    float _S442 = (F32_sqrt((_S440 - _S439)));
    float _S443 = _S438 - _S442;
    float _S444 = _S438 + _S442;
    bool _S445 = _S443 > 0.0000152587890625f;
    bool _S446;
    if(_S445)
    {
        _S446 = _S443 < max_len_0;
    }
    else
    {
        _S446 = false;
    }
    if(_S446)
    {
        return _S443;
    }
    bool _S447 = _S444 > 0.0000152587890625f;
    if(_S447)
    {
        _S446 = _S444 < max_len_0;
    }
    else
    {
        _S446 = false;
    }
    if(_S446)
    {
        return _S444;
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

static __device__ FKHit Hit_x24init_0(float2  uv_0, uint instance_index_0, uint triangle_index_0, uint is_point_light_0, float distance_0)
{
    FKHit _S448;
    (&_S448)->uv = uv_0;
    (&_S448)->instance_index = instance_index_0;
    (&_S448)->triangle_index = triangle_index_0;
    (&_S448)->is_point_light = is_point_light_0;
    (&_S448)->distance = distance_0;
    return _S448;
}

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_2, float3  end_0)
{
    float _S449 = sign_0(dot_0(light_n_0, start_2 - end_0));
    return light_n_0 * make_float3 (_S449 * light_offset_0);
}

static __device__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_1)
{
    Random _S450 = pcg(init_random_state_1);
    Random _S451 = pcg(_S450.state);
    Random _S452 = pcg(_S451.state);
    float3  _S453 = make_float3 (0.0f);
    TreeSample _S454 = TreeSample_x24init_0(_S453, _S453, 0.0f, _S452.state);
    TreeSample sample_0 = _S454;
    float3  _S455 = _slang_select(sided_0, _S453,smooth_n_2);
    float3  start_3 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S450.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S456 = (fcptLightNode((n_8)));
        if((_S456.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S457 = (fcptLightSecond((n_8)));
        uint _S458 = n_8 + 1U;
        LightNode _S459 = (fcptLightBounds((_S458)));
        LightNode _S460 = (fcptLightBounds((_S457)));
        uint _S461 = pickChild(_S459, _S460, origin_4, _S455, &pick_1, &probability_4);
        bool _S462 = _S461 > 1U;
        if(_S462)
        {
            return sample_0;
        }
        bool _S463 = _S461 == 1U;
        uint _S464 = _slang_select(_S463, _S457,_S458);
        n_8 = _S464;
    }
    bool _S465 = n_8 == 0U;
    bool _S466;
    if(_S465)
    {
        LightNode _S467 = (fcptLightBounds((0U)));
        float _S468 = importance(_S467, origin_4, _S455);
        _S466 = !(_S468 > 0.0f);
    }
    else
    {
        _S466 = false;
    }
    if(_S466)
    {
        return sample_0;
    }
    uint4  _S469 = (fcptLightNode((n_8)));
    bool _S470 = (_S469.x) == 2U;
    float3  start_4;
    float3  lift_n_0;
    float3  shadow_1;
    if(_S470)
    {
        FKLight _S471 = (fcptLight((_S469.y)));
        if(sided_0)
        {
            float _S472 = sign_0(dot_0(geometry_n_1, _S471.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S472);
            float3  _S473 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            start_4 = _S473;
            lift_n_0 = lift_n_1;
        }
        else
        {
            start_4 = start_3;
            lift_n_0 = smooth_n_2;
        }
        bool _S474 = (_S471.variance) == 0.0f;
        if(_S474)
        {
            float3  _S475 = _S471.position - start_4;
            float3  _S476 = ((((_S475)) * make_float3(rnorm3df(((_S475)).x, ((_S475)).y, ((_S475)).z))));
            (&sample_0)->dir = _S476;
            float3  _S477 = _S471.color * make_float3 (_S471.intensity) / make_float3 (dot_0(_S475, _S475) * probability_4);
            (&sample_0)->radiance = _S477;
            shadow_1 = _S475;
        }
        else
        {
            float3  _S478 = sampleSphere(_S471.position, _S471.variance, start_4, _S451.value, _S452.value);
            (&sample_0)->dir = _S478;
            float _S479 = sphereDensity(_S471.position, _S471.variance, start_4);
            float _S480 = probability_4 * _S479;
            (&sample_0)->density = _S480;
            float3  _S481 = pointLightRadiance(_S471.color, _S471.intensity, _S471.variance);
            float3  _S482 = _S481 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S482;
            FKRay _S483 = Ray_x24init_0(start_4, (&sample_0)->dir);
            float _S484 = raySphere_0(_S471.position, _S471.variance, &_S483, 4.294967296e+09f);
            float3  _S485 = (&sample_0)->dir * make_float3 (_S484);
            shadow_1 = _S485;
        }
    }
    else
    {
        uint _S486 = _S469.y;
        uint _S487 = (fcptTriangleOffset((_S486)));
        uint _S488 = _S487 + _S469.z;
        Matrix<float, 3, 3>  _S489 = (fcptWorldTriangle((_S486), (_S488)));
        float _S490 = (F32_sqrt((_S451.value)));
        float2  _S491 = make_float2 (_S490 * (1.0f - _S452.value), _S490 * _S452.value);
        float3  _S492 = mul_0(make_float3 (1.0f - _S490, _S491.x, _S491.y), _S489);
        if(sided_0)
        {
            float _S493 = sign_0(dot_0(geometry_n_1, _S492 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S493);
            float3  _S494 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            start_4 = _S494;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S495 = !((dot_0(smooth_n_2, _S492 - start_3)) > 0.0f);
            if(_S495)
            {
                return sample_0;
            }
            start_4 = start_3;
            lift_n_0 = smooth_n_2;
        }
        FKHit _S496 = Hit_x24init_0(_S491, _S486, _S488, 0U, 0.0f);
        float3  _S497 = _S492 - start_4;
        float3  _S498 = ((((_S497)) * make_float3(rnorm3df(((_S497)).x, ((_S497)).y, ((_S497)).z))));
        FKSurface _S499 = (fcptLightSurfaceAt((_S496), (_S492), (_S452.state), (_S498), (context_1->depth), (length_0(_S492 - origin_4))));
        (&sample_0)->random_state = _S499.random_state;
        float3  _S500 = ((((_S497)) * make_float3(rnorm3df(((_S497)).x, ((_S497)).y, ((_S497)).z))));
        (&sample_0)->dir = _S500;
        float _S501 = solidAngle(probability_4, cross_0(_S489.rows[int(1)] - _S489.rows[int(0)], _S489.rows[int(2)] - _S489.rows[int(0)]), _S497);
        (&sample_0)->density = _S501;
        float _S502 = sign_0(dot_0(- (&sample_0)->dir, _S499.smooth_n));
        float3  _S503 = _S499.material.emissive * make_float3 ((F32_max((_S502), (0.0f))));
        float3  _S504 = _slang_select(_S499.skip, _S453,_S503);
        float3  _S505 = _S504 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S505;
        float3  _S506 = shadowLift(_S499.smooth_n, _S499.geometry_offset, start_4, _S492);
        float3  _S507 = _S492 + _S506 - start_4;
        shadow_1 = _S507;
    }
    float3  _S508 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_1, _S452.state);
    float3  _S509 = (&sample_0)->radiance * _S508;
    bool _S510 = all_0(_S508 == _S453);
    float3  _S511 = _slang_select(_S510, _S453,_S509);
    (&sample_0)->radiance = _S511;
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
    float _S512 = 1.0f / (1.0f + b_0 / a_4 * (b_0 / a_4));
    bool _S513 = b_0 > 0.0f;
    float _S514 = _slang_select(_S513, _S512,1.0f);
    return _S514;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_0, float3  light_point_1)
{
    bool _S515 = vertex_0->none;
    if(_S515)
    {
        return 1.0f;
    }
    uint _S516 = (fcptLightSlot((*hit_0)));
    float _S517 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S516, light_point_1);
    float _S518 = powerHeuristic(vertex_0->pdf, _S517);
    return _S518;
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
    Shift _S519;
    (&_S519)->f = f_4;
    (&_S519)->jac = jac_0;
    return _S519;
}

static __device__ uint extractBits_0(uint e_1, uint offset_0, uint count_1)
{
    return (e_1 >> offset_0) & ((1U << count_1) - 1U);
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_5)
{
    NEEVertex _S520;
    (&_S520)->none = none_0;
    (&_S520)->pdf = pdf_4;
    (&_S520)->origin = origin_5;
    (&_S520)->smooth_n = smooth_n_3;
    (&_S520)->start = start_5;
    return _S520;
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
    Vertex _S521;
    (&_S521)->rough = rough_0;
    (&_S521)->lobe = lobe_7;
    (&_S521)->pdf = pdf_5;
    (&_S521)->cos = cos_0;
    (&_S521)->inside = inside_0;
    return _S521;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S522 = hash(index_0);
    uint _S523 = hash(seed_0 ^ _S522);
    return _S523;
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
    float3  _S524 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_1));
    float3  _S525 = scatter_0 * _S524 / make_float3 (sigma_1);
    float3  _S526 = _slang_select(scatters_0, _S525,_S524);
    return _S526;
}

static __device__ uint arrivalLobe_0(uint b_1, uint prev_lobe_0)
{
    bool _S527 = b_1 > 0U;
    uint _S528 = _slang_select(_S527, prev_lobe_0,3U);
    return _S528;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_8, bool surface_3, float length_2, float width_0)
{
    ShadowContext _S529;
    (&_S529)->extinction_behind = extinction_behind_0;
    (&_S529)->extinction_front = extinction_front_0;
    (&_S529)->fillings = fillings_0;
    (&_S529)->side = side_0;
    (&_S529)->depth = depth_1;
    (&_S529)->lobe = lobe_8;
    (&_S529)->surface = surface_3;
    (&_S529)->length = length_2;
    (&_S529)->width = width_0;
    return _S529;
}

static __device__ bool scatterSampled_0(bool replay_0, uint b_2, uint stop_0, bool varying_0)
{
    bool _S530 = !replay_0;
    bool _S531;
    if(_S530)
    {
        _S531 = true;
    }
    else
    {
        bool _S532 = b_2 == stop_0;
        if(_S532)
        {
            _S531 = !varying_0;
        }
        else
        {
            _S531 = false;
        }
    }
    return _S531;
}

__device__ float3  safeDivide(float3  a_5, float3  b_3)
{
    float3  _S533 = a_5 / b_3;
    float3  _S534 = make_float3 (0.0f);
    bool3  _S535 = b_3 == _S534;
    float3  _S536 = _slang_select(_S535, _S534,_S533);
    return _S536;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S537 = (1U << count_2) - 1U;
    return (e_2 & (~(_S537 << offset_1))) | ((newbits_0 & _S537) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_1, float3  f_5)
{
    Reservoir candidate_0 = r_2;
    uint _S538 = insertBits_0(r_2.path, end_1, 0U, 5U);
    uint _S539 = insertBits_0(_S538, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S539;
    (&candidate_0)->f = f_5;
    return candidate_0;
}

__device__ void offer(Selection * sel_0, Reservoir candidate_1, float3  weight_0)
{
    float _S540 = rgb_to_greyscale(weight_0);
    bool _S541 = _S540 > 0.0f;
    bool _S542;
    if(_S541)
    {
        _S542 = _S540 < 3.00000000549775576e+38f;
    }
    else
    {
        _S542 = false;
    }
    bool _S543 = !_S542;
    if(_S543)
    {
        return;
    }
    bool _S544 = sel_0->sums;
    if(_S544)
    {
        float3  _S545 = sel_0->color + weight_0;
        sel_0->color = _S545;
        return;
    }
    float _S546 = sel_0->w_sum + _S540;
    sel_0->w_sum = _S546;
    float3  _S547 = sel_0->color + weight_0;
    sel_0->color = _S547;
    Random _S548 = pcg(sel_0->random_state);
    sel_0->random_state = _S548.state;
    bool _S549 = (_S548.value * sel_0->w_sum) <= _S540;
    if(_S549)
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
    Random _S550 = pcg(random_state_8);
    Random _S551 = pcg(_S550.state);
    float _S552 = 1.0f - 2.0f * _S550.value;
    float _S553 = (F32_sqrt(((F32_max((1.0f - _S552 * _S552), (0.0f))))));
    float _S554 = 6.28318548202514648f * _S551.value;
    return make_float3 (_S553 * (F32_cos((_S554))), _S553 * (F32_sin((_S554))), _S552);
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2)
{
    BSDFMaterial _S555;
    (&_S555)->albedo = albedo_0;
    (&_S555)->emissive = emissive_0;
    (&_S555)->roughness = roughness_0;
    (&_S555)->metallic = metallic_0;
    (&_S555)->transmission = transmission_0;
    (&_S555)->ior = ior_0;
    (&_S555)->absorption = absorption_0;
    (&_S555)->specular_tint = specular_tint_0;
    (&_S555)->specular_level = specular_level_0;
    (&_S555)->translucent = translucent_0;
    (&_S555)->sheen = sheen_2;
    (&_S555)->sheen_roughness = sheen_roughness_0;
    (&_S555)->anisotropy = anisotropy_0;
    (&_S555)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S555)->tangent = tangent_2;
    return _S555;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1)
{
    FKMedium _S556;
    (&_S556)->scatter = scatter_1;
    (&_S556)->extinction = extinction_1;
    return _S556;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_6, bool skip_0, uint random_state_9, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0)
{
    FKSurface _S557;
    (&_S557)->smooth_n = smooth_n_4;
    (&_S557)->geometry_n = geometry_n_2;
    (&_S557)->geometry_offset = geometry_offset_2;
    (&_S557)->material = *material_6;
    (&_S557)->skip = skip_0;
    (&_S557)->random_state = random_state_9;
    (&_S557)->coverage = coverage_0;
    (&_S557)->encloses = encloses_0;
    (&_S557)->volume = *volume_0;
    (&_S557)->fills = fills_0;
    return _S557;
}

static __device__ FKSurface emitting_0(FKSurface * surface_4, bool top_0)
{
    FKSurface lower_0 = *surface_4;
    float3  _S558 = (&surface_4->material)->emissive;
    float3  _S559 = make_float3 (0.0f);
    bool _S560 = !top_0;
    float3  _S561 = _slang_select(_S560, _S559,_S558);
    (&(&lower_0)->material)->emissive = _S561;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_5, float u_2)
{
    float _S562 = surface_5->coverage;
    bool _S563 = u_2 < _S562;
    if(_S563)
    {
        return *surface_5;
    }
    float3  _S564 = make_float3 (0.0f);
    float3  _S565 = make_float3 (1.0f);
    BSDFMaterial _S566 = Material_x24init_0(_S564, _S564, 0.0f, 0.0f, 0.0f, 0.0f, _S564, _S565, 1.0f, _S564, _S564, 0.5f, 0.0f, 0.0f, _S564);
    BSDFMaterial material_7 = _S566;
    (&material_7)->albedo = _S565;
    (&material_7)->emissive = (&surface_5->material)->emissive;
    (&material_7)->transmission = 1.0f;
    (&material_7)->ior = 1.0f;
    (&material_7)->absorption = (&surface_5->material)->absorption;
    FKSurface through_0 = *surface_5;
    (&through_0)->material = material_7;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S567 = transmission_1 > 0.0f;
    bool _S568;
    if(_S567)
    {
        _S568 = true;
    }
    else
    {
        _S568 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S569;
    if(_S568)
    {
        _S569 = 1.0f;
    }
    else
    {
        _S569 = -1.0f;
    }
    return _S569;
}

static __device__ bool arrivesBehind_0(float3  dir_9, float3  n_9)
{
    return (dot_0(dir_9, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_6, float3  dir_10)
{
    float3  _S570 = surface_6->geometry_n;
    float _S571 = facingSign((&surface_6->material)->transmission, surface_6->geometry_n, dir_10);
    FKSurface faced_0 = *surface_6;
    float3  _S572 = surface_6->smooth_n * make_float3 (_S571);
    (&faced_0)->smooth_n = _S572;
    float3  _S573 = _S570 * make_float3 (_S571);
    (&faced_0)->geometry_n = _S573;
    return faced_0;
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
    float3  _S574 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_2) * log_0(_S574));
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
    bool _S575;
    if(open_0)
    {
        _S575 = prev_rough_0;
    }
    else
    {
        _S575 = false;
    }
    if(_S575)
    {
        _S575 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S575 = false;
    }
    return _S575;
}

static __device__ float2  vertexEta_0(BSDFMaterial * material_8, float n_dot_v_0)
{
    bool _S576 = n_dot_v_0 < 0.0f;
    float _S577 = material_8->ior;
    float _S578 = _slang_select(_S576, _S577,1.0f);
    float _S579 = _slang_select(_S576, 1.0f,_S577);
    return make_float2 (_S578, _S579);
}

__device__ bool samplesLights(BSDFMaterial material_9)
{
    bool _S580 = (material_9.roughness) > 0.0f;
    bool _S581;
    if(_S580)
    {
        _S581 = true;
    }
    else
    {
        bool _S582 = (material_9.metallic) < 1.0f;
        if(_S582)
        {
            _S581 = (material_9.transmission) < 1.0f;
        }
        else
        {
            _S581 = false;
        }
    }
    return _S581;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_10)
{
    float _S583 = rgb_to_greyscale(material_10->translucent);
    return _S583 > 0.0f;
}

__device__ float3  sideNormal(FKSurface surface_7, float3  in_dir_4)
{
    bool _S584 = !((surface_7.material.transmission) > 0.0f);
    bool _S585;
    if(_S584)
    {
        BSDFMaterial _S586 = surface_7.material;
        bool _S587 = isTranslucent_0(&_S586);
        _S585 = !_S587;
    }
    else
    {
        _S585 = false;
    }
    if(_S585)
    {
        _S585 = (dot_0(surface_7.smooth_n, - in_dir_4)) > 0.0f;
    }
    else
    {
        _S585 = false;
    }
    float3  _S588 = _slang_select(_S585, surface_7.smooth_n,surface_7.geometry_n);
    return _S588;
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
    MediumSides _S589;
    (&_S589)->behind = *behind_0;
    (&_S589)->front = *front_0;
    (&_S589)->fillings = fillings_1;
    (&_S589)->face = face_1;
    return _S589;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_11)
{
    float3  _S590 = surface_8->geometry_n;
    MediumSides _S591 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S591;
    bool _S592 = surface_8->encloses;
    if(_S592)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S593 = (dot_0(dir_11, _S590)) > 0.0f;
        if(_S593)
        {
            float3  _S594 = make_float3 (0.0f);
            FKMedium _S595 = Medium_x24init_0(_S594, _S594);
            (&sides_0)->front = _S595;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  side_n_3, float3  extinction_2, uint filling_1, float3  dir_12, uint depth_2, uint lobe_9, float length_3, float width_1)
{
    FKSurface faced_1 = *surface_9;
    float3  _S596 = surface_9->geometry_n;
    float3  _S597 = - surface_9->geometry_n;
    float3  _S598 = _slang_select(turned_0, _S597,_S596);
    (&faced_1)->geometry_n = _S598;
    FKMedium _S599 = Medium_x24init_0(make_float3 (0.0f), extinction_2);
    FKSurface _S600 = faced_1;
    FKMedium _S601 = _S599;
    MediumSides _S602 = mediumSides_0(&_S600, &_S601, filling_1, dir_12);
    ShadowContext _S603 = ShadowContext_x24init_0(_S602.behind.extinction, _S602.front.extinction, _S602.fillings, side_n_3, depth_2, lobe_9, true, length_3, width_1);
    ShadowContext context_2;
    if(turned_0)
    {
        uint2  _S604 = _S602.fillings;
        ShadowContext _S605 = ShadowContext_x24init_0(_S602.front.extinction, _S602.behind.extinction, uint2 {_S604.y, _S604.x}, side_n_3, depth_2, lobe_9, true, length_3, width_1);
        context_2 = _S605;
    }
    else
    {
        context_2 = _S603;
    }
    return context_2;
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_5, float3  out_dir_1, float3  n_10, float3  g_n_0, BSDFMaterial material_11, float eta_i_5, float eta_o_5, uint random_state_10)
{
    float3  _S606 = negate_0(in_dir_5);
    bool _S607 = (dot_0(g_n_0, _S606) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S607)
    {
        SampleBSDF _S608 = connectBSDF(in_dir_5, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 0U, random_state_10);
        SampleBSDF _S609 = connectBSDF(in_dir_5, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 2U, random_state_10);
        return _S608.throughput * make_float3 (_S608.pdf) + _S609.throughput * make_float3 (_S609.pdf);
    }
    SampleBSDF _S610 = connectBSDF(in_dir_5, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 1U, random_state_10);
    return _S610.throughput * make_float3 (_S610.pdf);
}

__device__ float3  translucentCorrection(float3  in_dir_6, float3  out_dir_2, float3  n_11, float3  g_n_1, BSDFMaterial material_12, float eta_i_6, float eta_o_6, uint random_state_11)
{
    float _S611 = dot_0(n_11, out_dir_2);
    float3  _S612 = negate_0(in_dir_6);
    bool _S613 = (_S611 * dot_0(n_11, _S612)) < 0.0f;
    SampleBSDF _S614 = connectBSDF(in_dir_6, out_dir_2, n_11, material_12, eta_i_6, eta_o_6, 0U, random_state_11);
    float3  _S615 = negate_0(in_dir_6);
    bool _S616 = (dot_0(g_n_1, _S615) * dot_0(g_n_1, out_dir_2)) > 0.0f;
    float3  _S617 = make_float3 (0.0f);
    float3  _S618 = _S614.throughput * make_float3 (_S614.pdf);
    float _S619 = _slang_select(_S616, -1.0f,1.0f);
    float3  _S620 = _S618 * make_float3 (_S619);
    float3  _S621 = _slang_select(_S613, _S620,_S617);
    return _S621;
}

__device__ float3  translucentBSDF(float3  in_dir_7, float3  out_dir_3, float3  n_12, float3  g_n_2, BSDFMaterial material_13, float eta_i_7, float eta_o_7, uint random_state_12)
{
    float3  _S622 = BSDF(in_dir_7, out_dir_3, n_12, g_n_2, material_13, eta_i_7, eta_o_7, random_state_12);
    float3  _S623 = translucentCorrection(in_dir_7, out_dir_3, n_12, g_n_2, material_13, eta_i_7, eta_o_7, random_state_12);
    return _S622 + _S623;
}

static __device__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_0, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_14, float eta_i_8, float eta_o_8, bool competing_0, uint random_state_13)
{
    bool _S624 = !competing_0;
    bool _S625;
    if(_S624)
    {
        _S625 = true;
    }
    else
    {
        _S625 = (light_0->density) == 0.0f;
    }
    if(_S625)
    {
        bool _S626 = isTranslucent_0(material_14);
        if(_S626)
        {
            float3  _S627 = translucentBSDF(in_dir_8, light_0->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_8, eta_o_8, random_state_13);
            return _S627 * light_0->radiance;
        }
        float3  _S628 = BSDF(in_dir_8, light_0->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_8, eta_o_8, random_state_13);
        return _S628 * light_0->radiance;
    }
    float3  _S629 = light_0->dir;
    bool _S630 = (dot_0(geometry_n_4, - in_dir_8) * dot_0(geometry_n_4, light_0->dir)) <= 0.0f;
    float3  _S631 = neeBSDF(in_dir_8, _S629, smooth_n_5, *material_14, eta_i_8, eta_o_8, _S630, light_0->density, true, random_state_13);
    return _S631 * light_0->radiance * make_float3 (light_0->density);
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S632 = (F32_sqrt((random_1_0)));
    float _S633 = 6.28318548202514648f * random_2_0;
    float _S634 = _S632 * (F32_cos((_S633)));
    float _S635 = _S632 * (F32_sin((_S633)));
    float _S636 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S634 * _S634 - _S635 * _S635))))));
    return make_float3 (_S634, _S636, _S635);
}

static __device__ float3  reflect_0(float3  i_8, float3  n_13)
{
    return i_8 - make_float3 (2.0f * dot_0(n_13, i_8)) * n_13;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_9, float3  n_14, BSDFMaterial material_15, float eta_i_9, float eta_o_9, uint random_init_1, float2  screen_space_0)
{
    uint random_state_14 = random_init_1;
    float3  _S637 = negate_0(in_dir_9);
    float _S638 = dot_0(n_14, _S637);
    float _S639 = sign_0(_S638);
    float3  n_i_4 = n_14 * make_float3 (_S639);
    float _S640 = (F32_abs((_S638)));
    float _S641 = material_15.roughness;
    float _S642 = _S641 * _S641;
    AnisotropicFrame _S643 = anisotropicFrame(material_15, n_i_4);
    float3  _S644 = sampleMaterialHalfVector(_S637, n_i_4, _S642, _S643, &random_state_14);
    BSDFLobes _S645 = bsdfLobes(in_dir_9, _S637, n_i_4, _S644, material_15, eta_i_9, eta_o_9, _S643);
    BSDFLobes lobes_3 = _S645;
    float _S646 = translucentShare(material_15);
    (&lobes_3)->translucent_share = _S646;
    float3  _S647 = make_float3 (1.0f);
    SampleBSDF _S648 = SampleBSDF_x24init_0(_S647, _S647, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S648;
    Random _S649 = pcg(random_state_14);
    random_state_14 = _S649.state;
    bool _S650 = (_S649.value) < ((&lobes_3)->p_diffuse);
    if(_S650)
    {
        Random _S651 = pcg(random_state_14);
        Random _S652 = pcg(_S651.state);
        (&sample_1)->random_state = _S652.state;
        float3  _S653 = sampleCosWeightedHemisphere(_S651.value, _S652.value);
        bool _S654 = (_S649.value) < ((&lobes_3)->p_diffuse * (&lobes_3)->translucent_share);
        float _S655 = _S653.y;
        float _S656 = - _S655;
        float _S657 = _slang_select(_S654, _S656,_S655);
        float3  _S658 = tangentToWorld(make_float3 (_S653.x, _S657, _S653.z), n_i_4);
        (&sample_1)->unit_direction = _S658;
        float3  _S659 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S642, material_15, lobes_3, 0U);
        (&sample_1)->throughput = _S659;
        float _S660 = lobeDensity(_S657, 0.0f, _S640, _S642, lobes_3, eta_i_9, eta_o_9, 0U);
        (&sample_1)->pdf = _S660;
        (&sample_1)->refracted = _S654;
        return sample_1;
    }
    bool _S661 = (_S649.value) < ((&lobes_3)->p_diffuse + (&lobes_3)->p_refract);
    if(_S661)
    {
        (&sample_1)->unit_direction = (&lobes_3)->refracted;
        float _S662 = lobeDensity(0.0f, dot_0((&sample_1)->unit_direction, _S644), _S640, _S642, lobes_3, eta_i_9, eta_o_9, 1U);
        (&sample_1)->pdf = _S662;
        float3  _S663 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S642, material_15, lobes_3, 1U);
        (&sample_1)->throughput = _S663;
        (&sample_1)->random_state = random_state_14;
        (&sample_1)->refracted = true;
        (&sample_1)->lobe = 1U;
        return sample_1;
    }
    float3  _S664 = reflect_0(in_dir_9, _S644);
    float3  _S665 = ((((_S664)) * make_float3(rnorm3df(((_S664)).x, ((_S664)).y, ((_S664)).z))));
    (&sample_1)->unit_direction = _S665;
    float3  _S666 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S642, material_15, lobes_3, 2U);
    (&sample_1)->throughput = _S666;
    (&sample_1)->random_state = random_state_14;
    (&sample_1)->lobe = 2U;
    float _S667 = lobeDensity(0.0f, 0.0f, _S640, _S642, lobes_3, eta_i_9, eta_o_9, 2U);
    (&sample_1)->pdf = _S667;
    return sample_1;
}

__device__ bool withinInverseFootprint(float pdf_6, bool diffuse_0, float prev_cos_0, float distance_4, float threshold_1)
{
    bool _S668 = pdf_6 > 0.0f;
    bool _S669;
    if(_S668)
    {
        if(diffuse_0)
        {
            _S669 = true;
        }
        else
        {
            _S669 = (pdf_6 * prev_cos_0 / (distance_4 * distance_4) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S669 = false;
    }
    return _S669;
}

__device__ bool roughLobe(float pdf_7, bool diffuse_1, float roughness_1)
{
    bool _S670 = pdf_7 > 0.0f;
    bool _S671;
    if(_S670)
    {
        if(diffuse_1)
        {
            _S671 = true;
        }
        else
        {
            _S671 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S671 = false;
    }
    return _S671;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S672 = layers_0 > 1U;
    bool _S673;
    if(_S672)
    {
        _S673 = refracting_0 != passed_0;
    }
    else
    {
        _S673 = false;
    }
    return _S673;
}

static __device__ float widened_0(float spread_0, float pdf_8, bool delta_0)
{
    float _S674 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_8))))), (3.14159274101257324f)));
    bool _S675 = !delta_0;
    float _S676 = _slang_select(_S675, _S674,0.0f);
    return spread_0 + _S676;
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
    bool scatter_2;
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
    int _S677;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_3;
    float sky_pdf_1;
    float width_4;
    uint b_5;
    float spread_3;
    Shift arrived_end_0;
    float3  _S678 = make_float3 (0.0f);
    Shift _S679 = Shift_x24init_0(_S678, 0.0f);
    uint _S680 = r_3->path;
    uint _S681 = extractBits_0(r_3->path, 0U, 5U);
    uint _S682 = extractBits_0(_S680, 5U, 5U);
    uint _S683 = extractBits_0(_S680, 10U, 2U);
    uint _S684 = extractBits_0(_S680, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S685 = _S684 >= 3U;
        uint _S686 = _slang_select(_S685, 1U,0U);
        uint _S687 = _S681 + _S686;
        uint _S688 = (fcptMaxBounces());
        passes_0 = _S687 > _S688;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S679;
    }
    uint _S689 = _S682 - 1U;
    bool _S690 = _S684 == 3U;
    uint _S691 = _slang_select(_S690, 1U,0U);
    uint _S692 = _S681 + _S691;
    bool _S693 = _S683 == 0U;
    uint _S694 = _slang_select(_S693, _S692,_S689);
    FKHit _S695 = (fcptReservoirHit((*r_3)));
    float3  _S696 = dom_0->x0;
    float3  _S697 = dom_0->x1 - dom_0->x0;
    float3  _S698 = ((((_S697)) * make_float3(rnorm3df(((_S697)).x, ((_S697)).y, ((_S697)).z))));
    FKRay _S699 = Ray_x24init_0(dom_0->x1, _S698);
    FKRay ray_2 = _S699;
    FKHit hit_1 = dom_0->hit;
    float3  scatter_in_0 = _S678;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S678;
    float3  extinction_in_0 = _S678;
    uint filling_2 = 4294967295U;
    float _S700 = dom_0->spread;
    float _S701 = dom_0->width;
    float _S702 = length_0(_S697);
    NEEVertex _S703 = NEEVertex_x24init_0(true, 0.0f, _S678, _S678, _S678);
    NEEVertex nee_vertex_0 = _S703;
    Vertex _S704 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S704;
    Reservoir _S705 = (Reservoir{});
    Reservoir chain_0 = _S705;
    uint _S706 = r_3->seed;
    (&chain_0)->seed = r_3->seed;
    (&ray_2)->origin = _S696;
    (&hit_1)->distance = _S702;
    FKMedium _S707 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_1)->distance), (&filling_2)));
    scatter_in_0 = _S707.scatter;
    extinction_in_0 = _S707.extinction;
    Reservoir _S708 = chain_0;
    uint _S709 = filling_2;
    for(;;)
    {
        bool _S710 = _S709 != 4294967295U;
        float _S711 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        float _S712 = (fcptMajorant((_S709)));
        float _S713 = _slang_select(_S710, _S712,_S711);
        if(replay_1)
        {
            passes_0 = 4294967295U == _S694;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            passes_0 = _S683 == 1U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            passes_0 = _S713 > 0.0f;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            ended_0 = _S679;
            sky_pdf_0 = 0.0f;
            spread_1 = _S700;
            width_2 = _S701;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_4 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S714 = (&prev_0)->rough;
        if(_S714)
        {
            passes_0 = !(_S713 > 0.0f);
        }
        else
        {
            passes_0 = false;
        }
        (&prev_0)->rough = passes_0;
        uint _S715 = stream(_S706, 384U);
        uint tracking_0 = _S715;
        weight_1 = throughput_3;
        glowed_0 = _S678;
        b_4 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        spread_1 = _S700;
        width_2 = _S701;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_1)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S677 = int(1);
                break;
            }
            uint _S716 = b_4 + 320U;
            bool _S717 = b_4 == 4294967295U;
            uint _S718 = _slang_select(_S717, 384U,_S716);
            uint _S719 = stream(_S706, _S718);
            Random _S720 = pcg(_S719);
            float _S721 = freeFlight_0(_S720.value, _S713);
            if(_S710)
            {
                float3  _S722 = (&ray_2)->origin;
                float3  _S723 = (&ray_2)->unit_direction;
                float _S724 = (&hit_1)->distance;
                uint _S725 = _slang_select(_S717, 0U,b_4);
                uint _S726 = (&prev_0)->lobe;
                uint _S727 = _slang_select(_S717, 3U,_S726);
                float _S728 = (fcptTrackMedium((_S709), (_S722), (_S723), (_S724), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S725), (_S727), (_S717)));
                threshold_2 = _S728;
            }
            else
            {
                threshold_2 = _S721;
            }
            bool _S729 = !(threshold_2 < ((&hit_1)->distance));
            if(_S729)
            {
                _S677 = int(1);
                break;
            }
            if(_S710)
            {
                passes_0 = !replay_1;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                float3  _S730 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S731 = sel_1->glow + _S730;
                sel_1->glow = _S731;
            }
            else
            {
            }
            glowed_0 = _S678;
            uint b_6 = b_4 + 1U;
            float3  _S732 = (&ray_2)->origin + make_float3 (threshold_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S732;
            float3  _S733 = flightWeight_0(scatter_in_0, extinction_in_0, _S713, threshold_2, true);
            float3  _S734 = weight_1;
            float3  _S735 = _slang_select(_S710, _S734,_S733);
            float3  throughput_4 = throughput_2 * _S735;
            uint _S736 = stream(_S706, b_6 + 320U);
            tracking_0 = _S736;
            weight_1 = throughput_3;
            float width_5 = width_2 + spread_1 * threshold_2;
            float _S737 = spread_1 + 3.14159274101257324f;
            uint _S738 = stream(_S706, b_6 + 64U);
            uint2  _S739 = make_uint2 (_S709);
            uint _S740 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            ShadowContext _S741 = ShadowContext_x24init_0(extinction_in_0, extinction_in_0, _S739, (&ray_2)->unit_direction, b_6, _S740, false, threshold_2, width_5);
            TreeSample _S742 = sampleLightTree_0((&ray_2)->origin, (&ray_2)->unit_direction, (&ray_2)->unit_direction, 0.0f, true, _S738, &_S741);
            bool _S743 = scatterSampled_0(replay_1, b_6, _S694, _S710);
            uint _S744 = (fcptMaxBounces());
            bool _S745 = b_6 < _S744;
            if(_S745)
            {
                turned_1 = (_S742.density) > 0.0f;
            }
            else
            {
                turned_1 = false;
            }
            float _S746 = _slang_select(turned_1, 0.07957746833562851f,0.0f);
            float3  _S747 = throughput_4 * _S742.radiance;
            float _S748 = powerHeuristic(_S742.density, _S746);
            float3  _S749 = _S747 * make_float3 (0.07957746833562851f * _S748);
            float3  _S750 = _slang_select(_S743, _S749,_S678);
            if(replay_1)
            {
                is_inside_5 = b_6 == _S694;
            }
            else
            {
                is_inside_5 = false;
            }
            if(is_inside_5)
            {
                bool _S751 = _S683 == 2U;
                if(_S751)
                {
                    float _S752 = rgb_to_greyscale(_S750);
                    passes_0 = _S752 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S753 = Shift_x24init_0(_S750, 1.0f);
                    _S677 = int(0);
                    ended_0 = _S753;
                    threshold_2 = _S737;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                _S677 = int(0);
                ended_0 = _S679;
                threshold_2 = _S737;
                geometry_density_2 = width_5;
                chain_throughput_0 = throughput_4;
                layer_0 = b_6;
                break;
            }
            bool _S754 = !replay_1;
            if(_S754)
            {
                Reservoir candidate_2 = _S708;
                uint _S755 = extractBits_0(_S708.path, 10U, 2U);
                bool _S756 = _S755 == 1U;
                if(_S756)
                {
                    float3  _S757 = safeDivide(_S750, _S678);
                    (&candidate_2)->radiance = _S757;
                }
                else
                {
                    uint _S758 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                    uint _S759 = insertBits_0(_S758, 2U, 10U, 2U);
                    (&candidate_2)->path = _S759;
                }
                Reservoir _S760 = withEnd(candidate_2, 0U, b_6, _S750);
                offer(sel_1, _S760, _S750 * make_float3 (scale_1) / make_float3 (density_2));
                float _S761 = survivalProbability(throughput_4, density_2);
                uint _S762 = stream(_S706, b_6 + 128U);
                Random _S763 = pcg(_S762);
                bool _S764 = _S761 < (_S763.value);
                if(_S764)
                {
                    scatter_2 = true;
                }
                else
                {
                    uint _S765 = (fcptMaxBounces());
                    scatter_2 = b_6 >= _S765;
                }
                if(scatter_2)
                {
                    _S677 = int(0);
                    ended_0 = _S679;
                    threshold_2 = _S737;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                float _S766 = density_2 * _S761;
                density_2 = _S766;
            }
            else
            {
            }
            NEEVertex _S767 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_2)->origin, _S678, (&ray_2)->origin);
            nee_vertex_0 = _S767;
            uint _S768 = stream(_S706, b_6);
            float3  _S769 = isotropic_0(_S768);
            (&ray_2)->unit_direction = _S769;
            Vertex _S770 = scatteredVertex_0(false);
            prev_0 = _S770;
            float _S771 = (&prev_0)->pdf;
            FKRay _S772 = ray_2;
            FKHit _S773 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S774 = (fcptTraverseInstanceBVH((_S772), (true), (4.294967296e+09f), (false), (_S773)));
            hit_1 = _S774;
            b_4 = b_6;
            throughput_2 = throughput_4;
            spread_1 = _S737;
            width_2 = width_5;
            sky_pdf_0 = _S771;
        }
        if(_S677 != int(1))
        {
            spread_1 = threshold_2;
            width_2 = geometry_density_2;
            throughput_2 = chain_throughput_0;
            b_4 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S679;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    Reservoir _S775 = chain_0;
    NEEVertex _S776 = nee_vertex_0;
    Vertex _S777 = prev_0;
    FKHit _S778 = hit_1;
    uint _S779 = filling_2;
    float3  _S780 = scatter_in_0;
    float3  _S781 = extinction_in_0;
    float3  _S782 = weight_1;
    float3  _S783 = glowed_0;
    for(;;)
    {
        bool _S784 = (_S778.instance_index) == 4294967295U;
        if(_S784)
        {
            bool _S785 = !_S776.none;
            float _S786 = _slang_select(_S785, sky_pdf_0,0.0f);
            float _S787 = escapeWeight_0(_S786, (&ray_2)->unit_direction);
            float3  _S788 = environment_0((&ray_2)->unit_direction, b_4, _S777.lobe);
            float3  _S789 = throughput_2 * _S788;
            if(replay_1)
            {
                bool _S790 = b_4 == _S694;
                if(_S790)
                {
                    passes_0 = _S683 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S791 = Shift_x24init_0(_S789 * make_float3 (_S787) / make_float3 (r_3->jac), density_2 / r_3->jac);
                    ended_0 = _S791;
                    passes_0 = true;
                    break;
                }
                if(_S693)
                {
                    passes_0 = _S690;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_4 == _S681;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S777.rough;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S792 = Shift_x24init_0(_S789 * make_float3 (_S787), 1.0f);
                    ended_0 = _S792;
                    passes_0 = true;
                    break;
                }
                ended_0 = _S679;
                passes_0 = true;
                break;
            }
            Reservoir candidate_3 = _S775;
            uint _S793 = extractBits_0(_S775.path, 10U, 2U);
            bool _S794 = _S793 == 1U;
            if(_S794)
            {
                uint _S795 = extractBits_0(_S775.path, 5U, 5U);
                bool _S796 = _S795 == b_4;
                float _S797 = _slang_select(_S796, 1.0f,_S787);
                float3  _S798 = safeDivide(_S789 * make_float3 (_S797), _S678);
                (&candidate_3)->radiance = _S798;
            }
            else
            {
                if(_S777.rough)
                {
                    uint _S799 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                    uint _S800 = insertBits_0(_S799, 3U, 10U, 2U);
                    uint _S801 = insertBits_0(_S800, _S777.lobe, 15U, 2U);
                    uint _S802 = _slang_select(_S777.inside, 1U,0U);
                    uint _S803 = insertBits_0(_S801, _S802, 20U, 1U);
                    (&candidate_3)->path = _S803;
                    (&candidate_3)->jac = _S777.pdf;
                    (&candidate_3)->dir = (&ray_2)->unit_direction;
                }
                else
                {
                }
            }
            float3  _S804 = _S789 * make_float3 (_S787);
            Reservoir _S805 = withEnd(candidate_3, 3U, b_4, _S804);
            offer(sel_1, _S805, _S804 * make_float3 (scale_1) / make_float3 (density_2));
            ended_0 = _S679;
            passes_0 = true;
            break;
        }
        float3  _S806 = (&ray_2)->origin + make_float3 (_S778.distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S806;
        bool _S807 = _S779 != 4294967295U;
        if(_S807)
        {
            bool _S808 = !replay_1;
            if(_S808)
            {
                float3  _S809 = throughput_2 * _S783 / make_float3 (density_2);
                float3  _S810 = sel_1->glow + _S809;
                sel_1->glow = _S810;
            }
            else
            {
            }
            float3  _S811 = throughput_2 * _S782;
            throughput_2 = _S811;
        }
        else
        {
            float3  _S812 = flightWeight_0(_S780, _S781, (_S780.x + _S780.y + _S780.z) / 3.0f, _S778.distance, false);
            float3  _S813 = throughput_2 * _S812;
            throughput_2 = _S813;
        }
        float _S814 = width_2 + spread_1 * _S778.distance;
        ended_0 = _S679;
        width_2 = _S814;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    uint _S815 = b_4 + 1U;
    b_4 = _S815;
    layer_0 = 0U;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S678;
    float3  reconnection_0 = _S678;
    for(;;)
    {
        bool _S816 = ((&hit_1)->is_point_light) == 1U;
        FKMedium _S817 = Medium_x24init_0(_S678, _S678);
        BSDFMaterial _S818 = Material_x24init_0(_S678, _S678, 0.0f, 0.0f, 0.0f, 0.0f, _S678, throughput_3, 1.0f, _S678, _S678, 0.5f, 0.0f, 0.0f, _S678);
        FKMedium _S819 = _S817;
        FKSurface _S820 = Surface_x24init_0(_S678, _S678, 0.0f, &_S818, false, 0U, 1.0f, false, &_S819, 4294967295U);
        bool _S821 = !_S816;
        bool is_inside_6;
        float3  front_n_0;
        float3  throughput_5;
        FKSurface surface_10;
        if(_S821)
        {
            uint _S822 = stream(_S706, b_4);
            uint _S823 = arrivalLobe_0(b_4, (&prev_0)->lobe);
            FKSurface _S824 = (fcptSurfaceAtPath((hit_1), ((&ray_2)->origin), (_S822), (width_2), (layer_0), (b_4), (_S823), ((&ray_2)->unit_direction)));
            bool _S825 = !passes_0;
            FKSurface _S826 = _S824;
            FKSurface _S827 = emitting_0(&_S826, _S825);
            uint _S828 = stream(_S706, b_4 + 256U);
            Random _S829 = pcg(_S828);
            FKSurface _S830 = _S827;
            FKSurface _S831 = uncovered_0(&_S830, _S829.value);
            float _S832 = facingSign(_S831.material.transmission, _S831.geometry_n, (&ray_2)->unit_direction);
            bool _S833 = _S832 < 0.0f;
            bool _S834 = (_S831.material.transmission) > 0.0f;
            if(_S834)
            {
                bool _S835 = arrivesBehind_0((&ray_2)->unit_direction, _S831.geometry_n);
                scatter_2 = _S835;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S836 = _S831;
            FKSurface _S837 = facingRay_0(&_S836, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S838 = arrivesBehind_0((&ray_2)->unit_direction, _S837.geometry_n);
                is_inside_6 = _S838;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S839 = beerLambert((&hit_1)->distance, _S837.material.absorption);
                float3  _S840 = throughput_2 * _S839;
                front_n_0 = _S840;
            }
            else
            {
                front_n_0 = throughput_2;
            }
            bool _S841 = !_S837.skip;
            float geometry_density_3 = geometryDensity(_S837.geometry_n, (&ray_2)->unit_direction, (&hit_1)->distance);
            bool _S842 = b_4 == _S815;
            if(_S842)
            {
                float _S843 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S843;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float3  _S844 = front_n_0;
            float _S845 = geometry_density_2;
            scatter_2 = _S841;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S845;
            surface_10 = _S837;
            front_n_0 = _S831.smooth_n;
            throughput_5 = _S844;
            turned_1 = _S833;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_10 = _S820;
            front_n_0 = _S678;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S846 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S847 = surface_10;
        FKSurface _S848 = surface_10;
        float _S849 = dot_0(surface_10.smooth_n, - (&ray_2)->unit_direction);
        BSDFMaterial _S850 = _S847.material;
        float2  _S851 = vertexEta_0(&_S850, _S849);
        bool _S852;
        if(scatter_2)
        {
            bool _S853 = samplesLights(_S847.material);
            _S852 = _S853;
        }
        else
        {
            _S852 = false;
        }
        bool _S854;
        if(passes_0)
        {
            _S854 = true;
        }
        else
        {
            _S854 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S854)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S852;
        }
        float3  _S855 = sideNormal(surface_10, (&ray_2)->unit_direction);
        float _S856 = sign_0(dot_0(- (&ray_2)->unit_direction, front_n_0));
        float3  _S857 = _S847.material.emissive * make_float3 ((F32_max((_S856), (0.0f))));
        float3  emission_0;
        if(_S816)
        {
            float3  _S858 = (fcptCalculatePointLightContrib(((&hit_1)->instance_index)));
            emission_0 = _S858;
        }
        else
        {
            emission_0 = _S857;
        }
        float _S859 = rgb_to_greyscale(emission_0);
        bool _S860 = _S859 > 0.0f;
        float3  emission_1;
        if(_S860)
        {
            NEEVertex _S861 = nee_vertex_0;
            FKHit _S862 = hit_1;
            float _S863 = emissionWeight_0(&_S861, &_S862, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S863);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S864;
        if(replay_1)
        {
            _S864 = _S683 == 1U;
        }
        else
        {
            _S864 = false;
        }
        bool _S865;
        if(_S864)
        {
            _S865 = b_4 > _S682;
        }
        else
        {
            _S865 = false;
        }
        bool _S866;
        if(_S865)
        {
            _S866 = b_4 == _S681;
        }
        else
        {
            _S866 = false;
        }
        bool _S867;
        if(_S866)
        {
            bool _S868 = _S684 == 1U;
            if(_S868)
            {
                _S867 = true;
            }
            else
            {
                _S867 = _S684 == 2U;
            }
        }
        else
        {
            _S867 = false;
        }
        if(_S867)
        {
            bool _S869 = _S816 != (_S684 == 2U);
            if(_S869)
            {
                return _S679;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_3->jac), density_2 / r_3->jac);
        }
        uint _S870 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S871 = _S870 == 1U;
        Reservoir here_0 = chain_0;
        uint _S872 = insertBits_0(0U, b_4, 5U, 5U);
        uint _S873 = insertBits_0(_S872, 1U, 10U, 2U);
        uint _S874 = insertBits_0(_S873, (&prev_0)->lobe, 15U, 2U);
        bool _S875 = (&prev_0)->inside;
        uint _S876 = _slang_select(_S875, 1U,0U);
        uint _S877 = insertBits_0(_S874, _S876, 20U, 1U);
        (&here_0)->path = _S877;
        float _S878 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S878;
        fcptWithReservoirHit((&here_0), (&hit_1));
        bool _S879;
        if(replay_1)
        {
            _S879 = _S683 == 1U;
        }
        else
        {
            _S879 = false;
        }
        bool _S880;
        if(_S879)
        {
            _S880 = b_4 == _S682;
        }
        else
        {
            _S880 = false;
        }
        bool _S881;
        bool wrong_side_0;
        bool refracted_4;
        bool _S882;
        bool _S883;
        float3  throughput_6;
        float density_4;
        if(_S880)
        {
            bool _S884 = ((&hit_1)->instance_index) != (_S695.instance_index);
            if(_S884)
            {
                _S881 = true;
            }
            else
            {
                _S881 = ((&hit_1)->triangle_index) != (_S695.triangle_index);
            }
            if(_S881)
            {
                wrong_side_0 = true;
            }
            else
            {
                wrong_side_0 = !_S846;
            }
            if(wrong_side_0)
            {
                return _S679;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            bool _S885 = _S682 == _S681;
            if(_S885)
            {
                refracted_4 = _S684 == 1U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            if(_S885)
            {
                _S882 = _S684 == 0U;
            }
            else
            {
                _S882 = false;
            }
            if(_S882)
            {
                BSDFMaterial _S886 = _S847.material;
                bool _S887 = isTranslucent_0(&_S886);
                uint _S888 = stream(_S706, b_4 + 64U);
                uint _S889 = arrivalLobe_0(b_4, (&prev_0)->lobe);
                FKSurface _S890 = surface_10;
                ShadowContext _S891 = shadowContext_0(&_S890, turned_1, _S855, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_4, _S889, (&hit_1)->distance, width_2);
                ShadowContext _S892 = _S891;
                TreeSample _S893 = sampleLightTree_0((&ray_2)->origin, _S848.smooth_n, surface_10.geometry_n, surface_10.geometry_offset, _S887, _S888, &_S892);
                bool _S894 = !nee_0;
                if(_S894)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S895 = rgb_to_greyscale(_S893.radiance);
                    passes_0 = !(_S895 > 0.0f);
                }
                if(passes_0)
                {
                    return _S679;
                }
                float _S896 = _S851.x;
                float _S897 = _S851.y;
                uint _S898 = (fcptMaxBounces());
                bool _S899 = b_4 < _S898;
                TreeSample _S900 = _S893;
                BSDFMaterial _S901 = _S847.material;
                float3  _S902 = lightBSDF_0((&ray_2)->unit_direction, &_S900, _S848.smooth_n, _S855, &_S901, _S896, _S897, _S899, surface_10.random_state);
                return Shift_x24init_0(throughput_7 * _S902 / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            if(_S885)
            {
                _S883 = _S684 == 4U;
            }
            else
            {
                _S883 = false;
            }
            if(_S883)
            {
                bool _S903 = !nee_0;
                if(_S903)
                {
                    return _S679;
                }
                float _S904 = environmentPdf_0(r_3->dir);
                float3  _S905 = skyBSDF((&ray_2)->unit_direction, r_3->dir, surface_10, _S855, _S851, is_inside_6, _S904, surface_10.random_state);
                return Shift_x24init_0(throughput_7 * _S905 * r_3->radiance / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            uint _S906 = extractBits_0(_S680, 19U, 1U);
            bool _S907 = nee_0 != (_S906 == 1U);
            if(_S907)
            {
                return _S679;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                _S881 = b_4 == _S694;
            }
            else
            {
                _S881 = false;
            }
            if(_S881)
            {
                bool _S908 = !scatter_2;
                if(_S908)
                {
                    wrong_side_0 = true;
                }
                else
                {
                    bool _S909 = _S683 != 1U;
                    if(_S909)
                    {
                        wrong_side_0 = _S683 != 3U;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                }
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S910 = _S683 == 2U;
                if(_S910)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S846;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S684 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    uint _S911 = stream(_S706, b_4 + 448U);
                    FKRay _S912 = ray_2;
                    FKSurface _S913 = surface_10;
                    SkySample _S914 = sampleSky_0(&_S912, &_S913, _S855, _S851, is_inside_6, _S911, surface_10.random_state);
                    return Shift_x24init_0(throughput_5 * _S914.color, 1.0f);
                }
                if(_S910)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S846;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    BSDFMaterial _S915 = _S847.material;
                    bool _S916 = isTranslucent_0(&_S915);
                    uint _S917 = stream(_S706, b_4 + 64U);
                    uint _S918 = arrivalLobe_0(b_4, (&prev_0)->lobe);
                    FKSurface _S919 = surface_10;
                    ShadowContext _S920 = shadowContext_0(&_S919, turned_1, _S855, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_4, _S918, (&hit_1)->distance, width_2);
                    ShadowContext _S921 = _S920;
                    TreeSample _S922 = sampleLightTree_0((&ray_2)->origin, _S848.smooth_n, surface_10.geometry_n, surface_10.geometry_offset, _S916, _S917, &_S921);
                    float _S923 = rgb_to_greyscale(_S922.radiance);
                    bool _S924 = !(_S923 > 0.0f);
                    if(_S924)
                    {
                        return _S679;
                    }
                    float _S925 = _S851.x;
                    float _S926 = _S851.y;
                    uint _S927 = (fcptMaxBounces());
                    bool _S928 = b_4 < _S927;
                    TreeSample _S929 = _S922;
                    BSDFMaterial _S930 = _S847.material;
                    float3  _S931 = lightBSDF_0((&ray_2)->unit_direction, &_S929, _S848.smooth_n, _S855, &_S930, _S925, _S926, _S928, surface_10.random_state);
                    return Shift_x24init_0(throughput_5 * _S931, 1.0f);
                }
                if(_S693)
                {
                    passes_0 = _S684 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S816;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S693)
                {
                    passes_0 = _S684 == 1U;
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
                    passes_0 = !_S846;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S679;
            }
            else
            {
                bool _S932 = !replay_1;
                if(_S932)
                {
                    refracted_4 = scatter_2;
                }
                else
                {
                    refracted_4 = false;
                }
                if(refracted_4)
                {
                    bool _S933 = b_4 > 0U;
                    if(_S933)
                    {
                        Reservoir candidate_4 = chain_0;
                        if(_S871)
                        {
                            float3  _S934 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_4)->radiance = _S934;
                        }
                        else
                        {
                            if(_S846)
                            {
                                candidate_4 = here_0;
                            }
                        }
                        float3  _S935 = throughput_5 * emission_1;
                        Reservoir _S936 = withEnd(candidate_4, 1U, b_4, _S935);
                        offer(sel_1, _S936, _S935 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S937 = throughput_5 * emission_1;
                        float3  _S938 = sel_1->glow + _S937;
                        sel_1->glow = _S938;
                    }
                    if(nee_0)
                    {
                        BSDFMaterial _S939 = _S847.material;
                        bool _S940 = isTranslucent_0(&_S939);
                        uint _S941 = stream(_S706, b_4 + 64U);
                        uint _S942 = arrivalLobe_0(b_4, (&prev_0)->lobe);
                        FKSurface _S943 = surface_10;
                        ShadowContext _S944 = shadowContext_0(&_S943, turned_1, _S855, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_4, _S942, (&hit_1)->distance, width_2);
                        ShadowContext _S945 = _S944;
                        TreeSample _S946 = sampleLightTree_0((&ray_2)->origin, _S848.smooth_n, surface_10.geometry_n, surface_10.geometry_offset, _S940, _S941, &_S945);
                        float _S947 = _S851.x;
                        float _S948 = _S851.y;
                        uint _S949 = (fcptMaxBounces());
                        bool _S950 = b_4 < _S949;
                        TreeSample _S951 = _S946;
                        BSDFMaterial _S952 = _S847.material;
                        float3  _S953 = lightBSDF_0((&ray_2)->unit_direction, &_S951, _S848.smooth_n, _S855, &_S952, _S947, _S948, _S950, surface_10.random_state);
                        float3  _S954 = throughput_5 * _S953;
                        Reservoir candidate_5 = chain_0;
                        if(_S871)
                        {
                            float3  _S955 = safeDivide(_S954, chain_throughput_0);
                            (&candidate_5)->radiance = _S955;
                        }
                        else
                        {
                            if(_S846)
                            {
                                candidate_5 = here_0;
                                uint _S956 = insertBits_0((&candidate_5)->path, 1U, 19U, 1U);
                                (&candidate_5)->path = _S956;
                                (&candidate_5)->dir = _S946.dir;
                                (&candidate_5)->radiance = _S946.radiance;
                            }
                            else
                            {
                                uint _S957 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S958 = insertBits_0(_S957, 2U, 10U, 2U);
                                (&candidate_5)->path = _S958;
                            }
                        }
                        Reservoir _S959 = withEnd(candidate_5, 0U, b_4, _S954);
                        offer(sel_1, _S959, _S954 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        bool _S960 = environmentMapped_0();
                        _S882 = _S960;
                    }
                    else
                    {
                        _S882 = false;
                    }
                    if(_S882)
                    {
                        uint _S961 = (fcptMaxBounces());
                        _S883 = b_4 < _S961;
                    }
                    else
                    {
                        _S883 = false;
                    }
                    if(_S883)
                    {
                        uint _S962 = stream(_S706, b_4 + 448U);
                        FKRay _S963 = ray_2;
                        FKSurface _S964 = surface_10;
                        SkySample _S965 = sampleSky_0(&_S963, &_S964, _S855, _S851, is_inside_6, _S962, surface_10.random_state);
                        float3  _S966 = throughput_5 * _S965.color;
                        Reservoir candidate_6 = chain_0;
                        if(_S871)
                        {
                            float3  _S967 = safeDivide(_S966, chain_throughput_0);
                            (&candidate_6)->radiance = _S967;
                        }
                        else
                        {
                            if(_S846)
                            {
                                candidate_6 = here_0;
                                uint _S968 = insertBits_0((&candidate_6)->path, 1U, 19U, 1U);
                                (&candidate_6)->path = _S968;
                                (&candidate_6)->dir = _S965.dir;
                                (&candidate_6)->radiance = _S965.radiance;
                            }
                            else
                            {
                                uint _S969 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S970 = insertBits_0(_S969, 2U, 10U, 2U);
                                (&candidate_6)->path = _S970;
                            }
                        }
                        Reservoir _S971 = withEnd(candidate_6, 4U, b_4, _S966);
                        offer(sel_1, _S971, _S966 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool straight_0;
        bool _S972;
        bool _S973;
        bool _S974;
        bool _S975;
        bool _S976;
        bool _S977;
        bool _S978;
        bool _S979;
        bool _S980;
        bool _S981;
        bool _S982;
        bool _S983;
        uint b_7;
        float3  throughput_8;
        float3  throughput_9;
        float3  throughput_10;
        float density_6;
        float sky_pdf_2;
        float spread_4;
        if(scatter_2)
        {
            if(replay_1)
            {
                _S881 = b_4 == _S694;
            }
            else
            {
                _S881 = false;
            }
            uint _S984 = extractBits_0(_S680, 15U, 2U);
            uint _S985 = extractBits_0(_S680, 17U, 2U);
            uint _S986 = _slang_select(_S880, _S985,_S984);
            float3  _S987 = r_3->dir;
            bool refracted_5 = _S986 == 1U;
            SampleBSDF _S988 = SampleBSDF_x24init_0(_S678, _S678, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_10 = _S988;
            float3  reconnection_1;
            if(_S881)
            {
                uint _S989 = extractBits_0(_S680, 20U, 1U);
                bool _S990 = is_inside_6 != (_S989 == 1U);
                if(_S990)
                {
                    return _S679;
                }
                bool _S991 = _S683 == 1U;
                if(_S991)
                {
                    float3  _S992 = (fcptHitPosition((_S695)));
                    throughput_8 = _S992;
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
                    BSDFMaterial _S993 = _S847.material;
                    bool _S994 = isTranslucent_0(&_S993);
                    if(_S994)
                    {
                        wrong_side_0 = _S986 == 0U;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        float3  _S995 = throughput_8 - (&ray_2)->origin;
                        float3  _S996 = _slang_select(_S991, _S995,_S987);
                        refracted_4 = (dot_0(_S848.smooth_n, _S996) * _S849) < 0.0f;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                }
                if(_S991)
                {
                    float3  _S997 = (&ray_2)->origin;
                    FKSurface _S998 = surface_10;
                    float3  _S999 = - _S848.smooth_n;
                    bool _S1000 = is_inside_6 != refracted_4;
                    float3  _S1001 = _slang_select(_S1000, _S999,_S848.smooth_n);
                    float3  _S1002 = throughput_8 - (_S997 + make_float3 (_S998.geometry_offset) * _S1001);
                    float3  _S1003 = ((((_S1002)) * make_float3(rnorm3df(((_S1002)).x, ((_S1002)).y, ((_S1002)).z))));
                    reconnection_1 = _S1003;
                }
                else
                {
                    reconnection_1 = _S987;
                }
                bool _S1004 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, _S855);
                if(_S1004)
                {
                    return _S679;
                }
                float3  _S1005 = throughput_8;
                throughput_8 = reconnection_1;
                b_7 = _S986;
                wrong_side_0 = false;
                reconnection_1 = _S1005;
            }
            else
            {
                bool _S1006 = !_S880;
                if(_S1006)
                {
                    float _S1007 = _S851.x;
                    float _S1008 = _S851.y;
                    float2  _S1009 = make_float2 (0.0f);
                    SampleBSDF _S1010 = sampleBSDF((&ray_2)->unit_direction, _S848.smooth_n, _S847.material, _S1007, _S1008, surface_10.random_state, _S1009);
                    SampleBSDF bsdf_sampled_0 = _S1010;
                    bool wrong_side_1 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, _S855);
                    if(wrong_side_1)
                    {
                        wrong_side_0 = (_S847.material.transmission) > 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        SampleBSDF _S1011 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_10.geometry_n, _S847.material, _S1007, _S1008, (&bsdf_sampled_0)->random_state, _S1009);
                        (&bsdf_sampled_0)->unit_direction = _S1011.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1011.refracted;
                        (&bsdf_sampled_0)->throughput = _S1011.throughput;
                    }
                    else
                    {
                        if(wrong_side_1)
                        {
                            float3  _S1012 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_10.geometry_n)) * surface_10.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1012;
                        }
                    }
                    uint _S1013 = (&bsdf_sampled_0)->lobe;
                    float3  _S1014 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1015 = (&bsdf_sampled_0)->refracted;
                    lobe_10 = bsdf_sampled_0;
                    float _S1016 = (&bsdf_sampled_0)->pdf;
                    float _S1017 = _slang_select(wrong_side_1, 0.0f,_S1016);
                    (&lobe_10)->pdf = _S1017;
                    throughput_8 = _S1014;
                    b_7 = _S1013;
                    wrong_side_0 = wrong_side_1;
                    refracted_4 = _S1015;
                }
                else
                {
                    throughput_8 = _S987;
                    b_7 = _S986;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(_S881)
            {
                _S882 = true;
            }
            else
            {
                _S882 = _S880;
            }
            if(_S882)
            {
                SampleBSDF _S1018 = connectBSDF((&ray_2)->unit_direction, throughput_8, _S848.smooth_n, _S847.material, _S851.x, _S851.y, b_7, surface_10.random_state);
                lobe_10 = _S1018;
            }
            bool _S1019 = b_7 != 0U;
            if(_S1019)
            {
                bool _S1020 = (_S847.material.roughness) == 0.0f;
                if(_S1020)
                {
                    _S883 = true;
                }
                else
                {
                    bool _S1021 = b_7 == 1U;
                    if(_S1021)
                    {
                        _S883 = (_S851.x) == (_S851.y);
                    }
                    else
                    {
                        _S883 = false;
                    }
                }
            }
            else
            {
                _S883 = false;
            }
            bool _S1022 = b_7 == 1U;
            if(_S1022)
            {
                straight_0 = (_S847.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            BSDFMaterial _S1023 = _S847.material;
            bool _S1024 = isTranslucent_0(&_S1023);
            if(_S1024)
            {
                _S972 = b_7 == 0U;
            }
            else
            {
                _S972 = false;
            }
            if(_S972)
            {
                _S973 = (dot_0(throughput_8, surface_10.geometry_n)) < 0.0f;
            }
            else
            {
                _S973 = false;
            }
            if(nee_0)
            {
                _S974 = !_S883;
            }
            else
            {
                _S974 = false;
            }
            if(_S974)
            {
                _S975 = !wrong_side_0;
            }
            else
            {
                _S975 = false;
            }
            if(_S975)
            {
                float _S1025 = (&lobe_10)->pdf;
                float3  _S1026 = (&ray_2)->origin;
                BSDFMaterial _S1027 = _S847.material;
                bool _S1028 = isTranslucent_0(&_S1027);
                float3  _S1029 = _slang_select(_S1028, _S678,_S848.smooth_n);
                float3  _S1030 = (&ray_2)->origin;
                FKSurface _S1031 = surface_10;
                float3  _S1032 = - _S848.smooth_n;
                float3  _S1033 = _slang_select(_S973, _S1032,_S848.smooth_n);
                NEEVertex _S1034 = NEEVertex_x24init_0(false, _S1025, _S1026, _S1029, _S1030 + make_float3 (_S1031.geometry_offset) * _S1033);
                nee_vertex_0 = _S1034;
            }
            else
            {
                bool _S1035 = b_7 != 1U;
                if(_S1035)
                {
                    _S976 = true;
                }
                else
                {
                    _S976 = (_S851.x) != (_S851.y);
                }
                if(_S976)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1036 = b_7 == 0U;
            bool _S1037 = withinInverseFootprint((&lobe_10)->pdf, _S1036, (&prev_0)->cos, (&hit_1)->distance, threshold_2);
            FKSurface _S1038 = surface_10;
            bool _S1039 = (dot_0(throughput_8, _S848.smooth_n) * dot_0(throughput_8, surface_10.geometry_n)) < 0.0f;
            bool _S1040 = !_S1039;
            if(_S1040)
            {
                bool _S1041 = roughLobe((&lobe_10)->pdf, _S1036, _S847.material.roughness);
                _S976 = _S1041;
            }
            else
            {
                _S976 = false;
            }
            if(_S880)
            {
                bool _S1042 = !_S1037;
                if(_S1042)
                {
                    return _S679;
                }
                bool _S1043 = _S684 != 1U;
                if(_S1043)
                {
                    _S977 = _S684 != 2U;
                }
                else
                {
                    _S977 = false;
                }
                if(_S977)
                {
                    float _S1044 = (&lobe_10)->pdf;
                    float _S1045 = _slang_select(nee_0, _S1044,0.0f);
                    float _S1046 = escapeWeight_0(_S1045, _S987);
                    bool _S1047 = _S682 == _S681;
                    if(_S1047)
                    {
                        passes_0 = _S690;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1048 = _slang_select(passes_0, _S1046,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_10)->throughput * make_float3 ((&lobe_10)->pdf)) * r_3->radiance * make_float3 (_S1048) / make_float3 (r_3->jac), density_4 * (&lobe_10)->pdf / r_3->jac);
                }
                float3  _S1049 = throughput_6 * make_float3 ((&lobe_10)->pdf);
                float _S1050 = density_4 * (&lobe_10)->pdf;
                throughput_9 = _S1049;
                density_6 = _S1050;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1051 = (fcptLayers((hit_1)));
            bool _S1052 = passesLayer_0(_S1051, _S1022, passes_0);
            if(_S881)
            {
                _S977 = _S1052;
            }
            else
            {
                _S977 = false;
            }
            if(_S977)
            {
                return _S679;
            }
            if(replay_1)
            {
                _S978 = b_4 <= _S694;
            }
            else
            {
                _S978 = false;
            }
            if(_S978)
            {
                _S979 = _S846;
            }
            else
            {
                _S979 = false;
            }
            if(_S979)
            {
                _S980 = _S1037;
            }
            else
            {
                _S980 = false;
            }
            if(_S980)
            {
                _S981 = true;
            }
            else
            {
                if(_S881)
                {
                    _S981 = !_S976;
                }
                else
                {
                    _S981 = false;
                }
            }
            if(_S981)
            {
                return _S679;
            }
            if(_S881)
            {
                float3  _S1053 = throughput_9 * ((&lobe_10)->throughput * make_float3 ((&lobe_10)->pdf));
                float _S1054 = (&lobe_10)->pdf;
                throughput_10 = _S1053;
                sky_pdf_2 = _S1054;
            }
            else
            {
                float3  _S1055 = throughput_9 * max_0((&lobe_10)->throughput, _S678);
                throughput_10 = _S1055;
                sky_pdf_2 = density_6;
            }
            bool _S1056 = !replay_1;
            if(_S1056)
            {
                _S982 = !_S871;
            }
            else
            {
                _S982 = false;
            }
            if(_S982)
            {
                _S983 = _S846;
            }
            else
            {
                _S983 = false;
            }
            bool _S1057;
            if(_S983)
            {
                _S1057 = _S1037;
            }
            else
            {
                _S1057 = false;
            }
            float3  chain_throughput_1;
            if(_S1057)
            {
                chain_0 = here_0;
                uint _S1058 = insertBits_0((&chain_0)->path, b_7, 17U, 2U);
                uint _S1059 = _slang_select(nee_0, 1U,0U);
                uint _S1060 = insertBits_0(_S1058, _S1059, 19U, 1U);
                (&chain_0)->path = _S1060;
                float _S1061 = (&chain_0)->jac * (&lobe_10)->pdf;
                (&chain_0)->jac = _S1061;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            Vertex _S1062 = Vertex_x24init_0(_S976, b_7, (&lobe_10)->pdf, (F32_abs((dot_0(_S1038.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1062;
            float _S1063 = (&lobe_10)->pdf;
            bool _S1064;
            if(_S1022)
            {
                _S1064 = (_S851.x) == (_S851.y);
            }
            else
            {
                _S1064 = false;
            }
            float _S1065 = _slang_select(_S1064, sky_pdf_0,_S1063);
            float _S1066 = widened_0(spread_1, (&lobe_10)->pdf, _S883);
            bool _S1067;
            if(refracted_4)
            {
                _S1067 = !_S973;
            }
            else
            {
                _S1067 = false;
            }
            bool is_inside_7;
            if(_S1067)
            {
                bool _S1068 = !is_inside_6;
                is_inside_7 = _S1068;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            bool _S1069 = !_S1052;
            if(_S1069)
            {
                FKSurface faced_2 = surface_10;
                float3  _S1070 = - _S1038.geometry_n;
                float3  _S1071 = _slang_select(turned_1, _S1070,_S1038.geometry_n);
                (&faced_2)->geometry_n = _S1071;
                FKMedium _S1072 = Medium_x24init_0(scatter_in_0, extinction_in_0);
                FKSurface _S1073 = faced_2;
                FKMedium _S1074 = _S1072;
                MediumSides _S1075 = mediumSides_0(&_S1073, &_S1074, filling_2, (&ray_2)->unit_direction);
                bool _S1076 = leavesInFront_0((&faced_2)->geometry_n, throughput_8, _S855, _S1038.geometry_n);
                float3  _S1077 = _slang_select(_S1076, _S1075.front.scatter,_S1075.behind.scatter);
                scatter_in_0 = _S1077;
                float3  _S1078 = _slang_select(_S1076, _S1075.front.extinction,_S1075.behind.extinction);
                extinction_in_0 = _S1078;
                uint _S1079 = _S1075.fillings.x;
                uint _S1080 = _S1075.fillings.y;
                uint _S1081 = _slang_select(_S1076, _S1080,_S1079);
                filling_2 = _S1081;
            }
            (&ray_2)->unit_direction = throughput_8;
            if(_S1069)
            {
                FKSurface _S1082 = surface_10;
                float _S1083 = _slang_select(straight_0, 0.0f,_S1082.geometry_offset);
                float3  _S1084 = - _S848.smooth_n;
                bool _S1085 = is_inside_7 != _S973;
                float3  _S1086 = _slang_select(_S1085, _S1084,_S848.smooth_n);
                float3  _S1087 = (&ray_2)->origin + make_float3 (_S1083) * _S1086;
                (&ray_2)->origin = _S1087;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1052;
            sky_pdf_2 = _S1065;
            spread_4 = _S1066;
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
            sky_pdf_2 = 0.0f;
            spread_4 = spread_1;
            straight_0 = false;
            is_inside_5 = is_inside_6;
        }
        bool _S1088 = !replay_1;
        float density_7;
        if(_S1088)
        {
            if(_S816)
            {
                float3  _S1089 = throughput_9 * emission_1;
                Reservoir candidate_7 = chain_0;
                uint _S1090 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1091 = _S1090 == 1U;
                if(_S1091)
                {
                    float3  _S1092 = safeDivide(_S1089, chain_throughput_0);
                    (&candidate_7)->radiance = _S1092;
                }
                Reservoir _S1093 = withEnd(candidate_7, 2U, b_4, _S1089);
                offer(sel_1, _S1093, _S1089 * make_float3 (scale_1) / make_float3 (density_6));
            }
            if(_S816)
            {
                _S881 = true;
            }
            else
            {
                _S881 = scatter_2;
            }
            if(_S881)
            {
                float _S1094 = survivalProbability(throughput_9, density_6);
                density_7 = _S1094;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1095 = stream(_S706, b_4 + 128U);
            Random _S1096 = pcg(_S1095);
            bool _S1097 = density_7 < (_S1096.value);
            if(_S1097)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1098 = (fcptMaxBounces());
                wrong_side_0 = b_4 >= _S1098;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1099 = density_6 * density_7;
            density_7 = _S1099;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1100 = layer_0 ^ 1U;
        uint _S1101 = _slang_select(passes_0, _S1100,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_1)->distance = 0.0f;
            b_7 = b_4;
            throughput_2 = throughput_9;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_1 = spread_4;
            uint _S1102 = b_7 + 1U;
            b_4 = _S1102;
            layer_0 = _S1101;
            continue;
        }
        FKRay _S1103 = ray_2;
        float _S1104 = distance_5(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            _S881 = b_4 == _S694;
        }
        else
        {
            _S881 = false;
        }
        if(_S881)
        {
            wrong_side_0 = _S683 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1105 = _slang_select(wrong_side_0, _S1104,4.294967296e+09f);
        FKHit _S1106;
        if(straight_0)
        {
            _S1106 = hit_1;
        }
        else
        {
            _S1106 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
        }
        FKHit _S1107 = (fcptTraverseInstanceBVH((_S1103), (_S821), (_S1105), (true), (_S1106)));
        hit_1 = _S1107;
        if(replay_1)
        {
            refracted_4 = b_4 == _S694;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            _S882 = _S683 == 1U;
        }
        else
        {
            _S882 = false;
        }
        if(_S882)
        {
            _S883 = ((&hit_1)->instance_index) == (_S695.instance_index);
        }
        else
        {
            _S883 = false;
        }
        if(_S883)
        {
            _S972 = ((&hit_1)->triangle_index) == (_S695.triangle_index);
        }
        else
        {
            _S972 = false;
        }
        if(_S972)
        {
            (&hit_1)->uv = _S695.uv;
            float _S1108 = distance_5(reconnection_0, (&ray_2)->origin);
            (&hit_1)->distance = _S1108;
        }
        if(replay_1)
        {
            _S973 = b_4 == _S694;
        }
        else
        {
            _S973 = false;
        }
        if(_S973)
        {
            _S974 = _S683 == 3U;
        }
        else
        {
            _S974 = false;
        }
        if(_S974)
        {
            _S975 = ((&hit_1)->instance_index) != 4294967295U;
        }
        else
        {
            _S975 = false;
        }
        if(_S975)
        {
            return _S679;
        }
        Reservoir _S1109 = chain_0;
        uint _S1110 = filling_2;
        for(;;)
        {
            bool _S1111 = _S1110 != 4294967295U;
            float _S1112 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            float _S1113 = (fcptMajorant((_S1110)));
            float _S1114 = _slang_select(_S1111, _S1113,_S1112);
            if(replay_1)
            {
                _S976 = b_4 == _S694;
            }
            else
            {
                _S976 = false;
            }
            if(_S976)
            {
                _S977 = _S683 == 1U;
            }
            else
            {
                _S977 = false;
            }
            if(_S977)
            {
                _S978 = _S1114 > 0.0f;
            }
            else
            {
                _S978 = false;
            }
            if(_S978)
            {
                ended_0 = _S679;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_3 = width_2;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_7 = b_4;
                _S979 = true;
                break;
            }
            bool _S1115 = (&prev_0)->rough;
            if(_S1115)
            {
                _S979 = !(_S1114 > 0.0f);
            }
            else
            {
                _S979 = false;
            }
            (&prev_0)->rough = _S979;
            uint _S1116 = b_4 + 320U;
            bool _S1117 = b_4 == 4294967295U;
            uint _S1118 = _slang_select(_S1117, 384U,_S1116);
            uint _S1119 = stream(_S706, _S1118);
            uint tracking_1 = _S1119;
            weight_1 = throughput_3;
            glowed_0 = _S678;
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
                    _S677 = int(2);
                    break;
                }
                uint _S1120 = b_7 + 320U;
                bool _S1121 = b_7 == 4294967295U;
                uint _S1122 = _slang_select(_S1121, 384U,_S1120);
                uint _S1123 = stream(_S706, _S1122);
                Random _S1124 = pcg(_S1123);
                float _S1125 = freeFlight_0(_S1124.value, _S1114);
                if(_S1111)
                {
                    float3  _S1126 = (&ray_2)->origin;
                    float3  _S1127 = (&ray_2)->unit_direction;
                    float _S1128 = (&hit_1)->distance;
                    uint _S1129 = _slang_select(_S1121, 0U,b_7);
                    uint _S1130 = (&prev_0)->lobe;
                    uint _S1131 = _slang_select(_S1121, 3U,_S1130);
                    float _S1132 = (fcptTrackMedium((_S1110), (_S1126), (_S1127), (_S1128), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S1129), (_S1131), (_S1121)));
                    spread_3 = _S1132;
                }
                else
                {
                    spread_3 = _S1125;
                }
                bool _S1133 = !(spread_3 < ((&hit_1)->distance));
                if(_S1133)
                {
                    _S677 = int(2);
                    break;
                }
                if(_S1111)
                {
                    _S980 = _S1088;
                }
                else
                {
                    _S980 = false;
                }
                if(_S980)
                {
                    float3  _S1134 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1135 = sel_1->glow + _S1134;
                    sel_1->glow = _S1135;
                }
                else
                {
                }
                glowed_0 = _S678;
                uint b_8 = b_7 + 1U;
                float3  _S1136 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1136;
                float3  _S1137 = flightWeight_0(scatter_in_0, extinction_in_0, _S1114, spread_3, true);
                float3  _S1138 = weight_1;
                float3  _S1139 = _slang_select(_S1111, _S1138,_S1137);
                float3  throughput_11 = throughput_10 * _S1139;
                uint _S1140 = stream(_S706, b_8 + 320U);
                tracking_1 = _S1140;
                weight_1 = throughput_3;
                float width_6 = width_3 + spread_2 * spread_3;
                float _S1141 = spread_2 + 3.14159274101257324f;
                uint _S1142 = stream(_S706, b_8 + 64U);
                uint2  _S1143 = make_uint2 (_S1110);
                uint _S1144 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                ShadowContext _S1145 = ShadowContext_x24init_0(extinction_in_0, extinction_in_0, _S1143, (&ray_2)->unit_direction, b_8, _S1144, false, spread_3, width_6);
                TreeSample _S1146 = sampleLightTree_0((&ray_2)->origin, (&ray_2)->unit_direction, (&ray_2)->unit_direction, 0.0f, true, _S1142, &_S1145);
                bool _S1147 = scatterSampled_0(replay_1, b_8, _S694, _S1111);
                uint _S1148 = (fcptMaxBounces());
                bool _S1149 = b_8 < _S1148;
                if(_S1149)
                {
                    _S981 = (_S1146.density) > 0.0f;
                }
                else
                {
                    _S981 = false;
                }
                float _S1150 = _slang_select(_S981, 0.07957746833562851f,0.0f);
                float3  _S1151 = throughput_11 * _S1146.radiance;
                float _S1152 = powerHeuristic(_S1146.density, _S1150);
                float3  _S1153 = _S1151 * make_float3 (0.07957746833562851f * _S1152);
                float3  _S1154 = _slang_select(_S1147, _S1153,_S678);
                if(replay_1)
                {
                    _S982 = b_8 == _S694;
                }
                else
                {
                    _S982 = false;
                }
                if(_S982)
                {
                    bool _S1155 = _S683 == 2U;
                    if(_S1155)
                    {
                        float _S1156 = rgb_to_greyscale(_S1154);
                        _S983 = _S1156 > 0.0f;
                    }
                    else
                    {
                        _S983 = false;
                    }
                    if(_S983)
                    {
                        Shift _S1157 = Shift_x24init_0(_S1154, 1.0f);
                        _S677 = int(1);
                        ended_0 = _S1157;
                        spread_3 = _S1141;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_5 = b_8;
                        break;
                    }
                    _S677 = int(1);
                    ended_0 = _S679;
                    spread_3 = _S1141;
                    width_4 = width_6;
                    throughput_8 = throughput_11;
                    b_5 = b_8;
                    break;
                }
                if(_S1088)
                {
                    Reservoir candidate_8 = _S1109;
                    uint _S1158 = extractBits_0(_S1109.path, 10U, 2U);
                    bool _S1159 = _S1158 == 1U;
                    if(_S1159)
                    {
                        float3  _S1160 = safeDivide(_S1154, chain_throughput_0);
                        (&candidate_8)->radiance = _S1160;
                    }
                    else
                    {
                        uint _S1161 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                        uint _S1162 = insertBits_0(_S1161, 2U, 10U, 2U);
                        (&candidate_8)->path = _S1162;
                    }
                    Reservoir _S1163 = withEnd(candidate_8, 0U, b_8, _S1154);
                    offer(sel_1, _S1163, _S1154 * make_float3 (scale_1) / make_float3 (density_3));
                    float _S1164 = survivalProbability(throughput_11, density_3);
                    uint _S1165 = stream(_S706, b_8 + 128U);
                    Random _S1166 = pcg(_S1165);
                    bool _S1167 = _S1164 < (_S1166.value);
                    if(_S1167)
                    {
                        _S983 = true;
                    }
                    else
                    {
                        uint _S1168 = (fcptMaxBounces());
                        _S983 = b_8 >= _S1168;
                    }
                    if(_S983)
                    {
                        _S677 = int(1);
                        ended_0 = _S679;
                        spread_3 = _S1141;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_5 = b_8;
                        break;
                    }
                    float _S1169 = density_3 * _S1164;
                    density_3 = _S1169;
                }
                else
                {
                }
                NEEVertex _S1170 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_2)->origin, _S678, (&ray_2)->origin);
                nee_vertex_0 = _S1170;
                uint _S1171 = stream(_S706, b_8);
                float3  _S1172 = isotropic_0(_S1171);
                (&ray_2)->unit_direction = _S1172;
                Vertex _S1173 = scatteredVertex_0(is_inside_5);
                prev_0 = _S1173;
                float _S1174 = (&prev_0)->pdf;
                FKRay _S1175 = ray_2;
                FKHit _S1176 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1177 = (fcptTraverseInstanceBVH((_S1175), (true), (4.294967296e+09f), (false), (_S1176)));
                hit_1 = _S1177;
                b_7 = b_8;
                throughput_10 = throughput_11;
                spread_2 = _S1141;
                width_3 = width_6;
                sky_pdf_1 = _S1174;
            }
            if(_S677 != int(2))
            {
                spread_2 = spread_3;
                width_3 = width_4;
                throughput_10 = throughput_8;
                b_7 = b_5;
                _S979 = true;
                break;
            }
            ended_0 = _S679;
            _S979 = false;
            break;
        }
        if(_S979)
        {
            return ended_0;
        }
        Reservoir _S1178 = chain_0;
        NEEVertex _S1179 = nee_vertex_0;
        Vertex _S1180 = prev_0;
        FKHit _S1181 = hit_1;
        uint _S1182 = filling_2;
        float3  _S1183 = scatter_in_0;
        float3  _S1184 = extinction_in_0;
        float3  _S1185 = weight_1;
        float3  _S1186 = glowed_0;
        for(;;)
        {
            bool _S1187 = (_S1181.instance_index) == 4294967295U;
            if(_S1187)
            {
                bool _S1188 = !_S1179.none;
                float _S1189 = _slang_select(_S1188, sky_pdf_1,0.0f);
                float _S1190 = escapeWeight_0(_S1189, (&ray_2)->unit_direction);
                float3  _S1191 = environment_0((&ray_2)->unit_direction, b_7, _S1180.lobe);
                float3  _S1192 = throughput_10 * _S1191;
                if(replay_1)
                {
                    bool _S1193 = b_7 == _S694;
                    if(_S1193)
                    {
                        _S980 = _S683 == 3U;
                    }
                    else
                    {
                        _S980 = false;
                    }
                    if(_S980)
                    {
                        Shift _S1194 = Shift_x24init_0(_S1192 * make_float3 (_S1190) / make_float3 (r_3->jac), density_3 / r_3->jac);
                        arrived_end_0 = _S1194;
                        width_4 = width_3;
                        throughput_8 = throughput_10;
                        _S980 = true;
                        break;
                    }
                    if(_S693)
                    {
                        _S981 = _S690;
                    }
                    else
                    {
                        _S981 = false;
                    }
                    if(_S981)
                    {
                        _S982 = b_7 == _S681;
                    }
                    else
                    {
                        _S982 = false;
                    }
                    if(_S982)
                    {
                        _S983 = !_S1180.rough;
                    }
                    else
                    {
                        _S983 = false;
                    }
                    if(_S983)
                    {
                        Shift _S1195 = Shift_x24init_0(_S1192 * make_float3 (_S1190), 1.0f);
                        arrived_end_0 = _S1195;
                        width_4 = width_3;
                        throughput_8 = throughput_10;
                        _S980 = true;
                        break;
                    }
                    arrived_end_0 = _S679;
                    width_4 = width_3;
                    throughput_8 = throughput_10;
                    _S980 = true;
                    break;
                }
                Reservoir candidate_9 = _S1178;
                uint _S1196 = extractBits_0(_S1178.path, 10U, 2U);
                bool _S1197 = _S1196 == 1U;
                if(_S1197)
                {
                    uint _S1198 = extractBits_0(_S1178.path, 5U, 5U);
                    bool _S1199 = _S1198 == b_7;
                    float _S1200 = _slang_select(_S1199, 1.0f,_S1190);
                    float3  _S1201 = safeDivide(_S1192 * make_float3 (_S1200), chain_throughput_0);
                    (&candidate_9)->radiance = _S1201;
                }
                else
                {
                    if(_S1180.rough)
                    {
                        uint _S1202 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                        uint _S1203 = insertBits_0(_S1202, 3U, 10U, 2U);
                        uint _S1204 = insertBits_0(_S1203, _S1180.lobe, 15U, 2U);
                        uint _S1205 = _slang_select(_S1180.inside, 1U,0U);
                        uint _S1206 = insertBits_0(_S1204, _S1205, 20U, 1U);
                        (&candidate_9)->path = _S1206;
                        (&candidate_9)->jac = _S1180.pdf;
                        (&candidate_9)->dir = (&ray_2)->unit_direction;
                    }
                    else
                    {
                    }
                }
                float3  _S1207 = _S1192 * make_float3 (_S1190);
                Reservoir _S1208 = withEnd(candidate_9, 3U, b_7, _S1207);
                offer(sel_1, _S1208, _S1207 * make_float3 (scale_1) / make_float3 (density_3));
                arrived_end_0 = _S679;
                width_4 = width_3;
                throughput_8 = throughput_10;
                _S980 = true;
                break;
            }
            float3  _S1209 = (&ray_2)->origin + make_float3 (_S1181.distance) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1209;
            bool _S1210 = _S1182 != 4294967295U;
            if(_S1210)
            {
                if(_S1088)
                {
                    float3  _S1211 = throughput_10 * _S1186 / make_float3 (density_3);
                    float3  _S1212 = sel_1->glow + _S1211;
                    sel_1->glow = _S1212;
                }
                else
                {
                }
                float3  _S1213 = throughput_10 * _S1185;
                throughput_8 = _S1213;
            }
            else
            {
                float3  _S1214 = flightWeight_0(_S1183, _S1184, (_S1183.x + _S1183.y + _S1183.z) / 3.0f, _S1181.distance, false);
                float3  _S1215 = throughput_10 * _S1214;
                throughput_8 = _S1215;
            }
            float _S1216 = width_3 + spread_2 * _S1181.distance;
            arrived_end_0 = _S679;
            width_4 = _S1216;
            _S980 = false;
            break;
        }
        if(_S980)
        {
            return arrived_end_0;
        }
        width_2 = width_4;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1102 = b_7 + 1U;
        b_4 = _S1102;
        layer_0 = _S1101;
    }
    return _S679;
}

static __device__ Shift shift_0(Domain * dom_1, Reservoir * r_4)
{
    Selection _S1217 = (Selection{});
    Selection sel_2 = _S1217;
    bool _S1218 = (r_4->w) <= 0.0f;
    if(_S1218)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1219 = walk_0(dom_1, r_4, true, 0.0f, &sel_2);
    return _S1219;
}

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
    Random _S1220 = pcg(state_3);
    Random _S1221 = pcg(_S1220.state);
    float _S1222 = 6.28318548202514648f * _S1220.value;
    float _S1223 = (F32_sqrt((-2.0f * clamp_0((F32_log((_S1221.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1221.state, _S1223 * (F32_cos((_S1222))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1224;
    (&_S1224)->state = state_4;
    (&_S1224)->value = value_2;
    return _S1224;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1225 = normal_distribution(state_5);
    Random _S1226 = normal_distribution(_S1225.state);
    Random _S1227 = normal_distribution(_S1226.state);
    float3  _S1228 = make_float3 (_S1225.value, _S1226.value, _S1227.value);
    float3  _S1229 = ((((_S1228)) * make_float3(rnorm3df(((_S1228)).x, ((_S1228)).y, ((_S1228)).z))));
    return RandomSphere_x24init_0(_S1227.state, _S1229);
}

struct RandomHemisphere
{
    uint state;
    float3  value;
};

static __device__ RandomHemisphere RandomHemisphere_x24init_0(uint state_6, float3  value_3)
{
    RandomHemisphere _S1230;
    (&_S1230)->state = state_6;
    (&_S1230)->value = value_3;
    return _S1230;
}

__device__ RandomHemisphere random_hemisphere(uint state_7, float3  normal_4)
{
    RandomSphere _S1231 = random_sphere(state_7);
    bool _S1232 = (dot_0(_S1231.value, normal_4)) > 0.0f;
    if(_S1232)
    {
        return RandomHemisphere_x24init_0(_S1231.state, _S1231.value);
    }
    else
    {
        float3  _S1233 = negate_0(_S1231.value);
        return RandomHemisphere_x24init_0(_S1231.state, _S1233);
    }
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_15)
{
    float3  _S1234 = p1_0 - p0_0;
    float3  _S1235 = p2_0 - p0_0;
    float2  _S1236 = uv1_0 - uv0_0;
    float2  _S1237 = uv2_0 - uv0_0;
    float _S1238 = _S1236.x;
    float _S1239 = _S1237.y;
    float _S1240 = _S1236.y;
    float _S1241 = _S1237.x;
    float _S1242 = _S1238 * _S1239 - _S1240 * _S1241;
    float _S1243 = 1.0f / _S1242;
    float3  t_1 = (_S1234 * make_float3 (_S1239) - _S1235 * make_float3 (_S1240)) * make_float3 (_S1243);
    float3  _S1244 = (_S1235 * make_float3 (_S1238) - _S1234 * make_float3 (_S1241)) * make_float3 (_S1243);
    float3  _S1245 = t_1 - n_15 * make_float3 (dot_0(n_15, t_1));
    float3  t_2 = ((((_S1245)) * make_float3(rnorm3df(((_S1245)).x, ((_S1245)).y, ((_S1245)).z))));
    bool _S1246 = (dot_0(cross_0(n_15, t_2), _S1244)) > 0.0f;
    float3  t_3;
    if(_S1246)
    {
        float3  _S1247 = negate_0(t_2);
        t_3 = _S1247;
    }
    else
    {
        t_3 = t_2;
    }
    float3  _S1248 = cross_0(n_15, t_3);
    return makeMatrix<float, 3, 3> (t_3, _S1248, n_15);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1249 = t1_0 - t0_0;
    float3  _S1250 = t2_2 - t0_0;
    float3  _S1251 = t2_2 - t1_0;
    float _S1252 = (F32_min((length_0(_S1249)), ((F32_min((length_0(_S1250)), (length_0(_S1251)))))));
    float3  _S1253 = make_float3 (distance_5(position_0, t0_0), distance_5(position_0, t1_0), distance_5(position_0, t2_2));
    float3  _S1254 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1255 = dot_0(geometry_n_5, _S1254);
    float3  _S1256 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1257 = dot_0(geometry_n_5, _S1256);
    float3  _S1258 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1259 = acos_0(abs_0(make_float3 (_S1255, _S1257, dot_0(geometry_n_5, _S1258))));
    float3  _S1260 = clamp_1(tan_0(_S1259), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_0(dot_0(_S1253 * _S1260, uvw_0), 0.0f, _S1252 * 0.125f);
}

__device__ float3  sampleHalfVector(float3  v_6, float3  n_i_5, float alpha_6, uint * random_state_15)
{
    float3  _S1261 = sampleMaterialHalfVector(v_6, n_i_5, alpha_6, AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f)), random_state_15);
    return _S1261;
}

__device__ float3  straightThrough(float3  dir_14, float3  n_16, BSDFMaterial material_16)
{
    float3  _S1262 = negate_0(dir_14);
    float _S1263 = sign_0(dot_0(n_16, _S1262));
    float3  _S1264 = n_16 * make_float3 (_S1263);
    AnisotropicFrame _S1265 = anisotropicFrame(material_16, _S1264);
    bool _S1266 = (_S1265.alphas.x) > 0.0f;
    if(_S1266)
    {
        float _S1267 = material_16.transmission * (1.0f - material_16.metallic);
        float3  _S1268 = negate_0(_S1264);
        float3  _S1269 = anisotropicLocal(dir_14, _S1265.tangent, _S1268);
        float _S1270 = anisotropicG1(_S1269, _S1265.alphas);
        return make_float3 (_S1267 * _S1270) * material_16.albedo;
    }
    float _S1271 = material_16.transmission * (1.0f - material_16.metallic);
    float _S1272 = material_16.roughness;
    float _S1273 = smithG1(_S1272 * _S1272, (F32_abs((dot_0(n_16, dir_14)))));
    return make_float3 (_S1271 * _S1273) * material_16.albedo;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_17, BSDFMaterial material_17, float coverage_1)
{
    float3  _S1274;
    if((material_17.ior) == 1.0f)
    {
        float3  _S1275 = straightThrough(toward_1, n_17, material_17);
        _S1274 = _S1275;
    }
    else
    {
        _S1274 = make_float3 (0.0f);
    }
    return _S1274 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_5, Shift shifted_0, float mis_0)
{
    Reservoir candidate_10 = r_5;
    float3  _S1276 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_10)->f = _S1276;
    float _S1277 = r_5.jac * shifted_0.jac;
    (&candidate_10)->jac = _S1277;
    offer(sel_3, candidate_10, make_float3 (mis_0) * shifted_0.f * make_float3 (r_5.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_6 = sel_4.r;
    float _S1278 = rgb_to_greyscale((&r_6)->f);
    float _S1279 = sel_4.w_sum / _S1278;
    bool _S1280 = _S1278 > 0.0f;
    float _S1281 = _slang_select(_S1280, _S1279,0.0f);
    (&r_6)->w = _S1281;
    (&r_6)->c = c_1;
    return r_6;
}

static __device__ float interpolate_0(float a_6, float b_9, float t_4)
{
    return a_6 + (b_9 - a_6) * t_4;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S1282 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S1282;
}

__device__ float2  temporalWeights(float c_2, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S1283 = c_2 * p_c_0;
    float _S1284 = c_t_0 * p_t_0;
    return make_float2 (_S1283 / (_S1283 + c_t_0 * g_previous_0), _S1284 / (_S1284 + c_2 * g_current_0));
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
    Domain _S1285 = dom_2;
    Reservoir _S1286 = r_7;
    Shift _S1287 = walk_0(&_S1285, &_S1286, replay_2, scale_2, sel_5);
    return _S1287;
}

__device__ Shift shift_hook(Domain dom_3, Reservoir r_8)
{
    Domain _S1288 = dom_3;
    Reservoir _S1289 = r_8;
    Shift _S1290 = shift_0(&_S1288, &_S1289);
    return _S1290;
}

#undef Matrix
