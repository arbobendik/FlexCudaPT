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
    uint4  _S75 = (fcptLightTrail((j_0)));
    uint2  _S76 = uint2 {_S75.x, _S75.y};
    uint n_0 = 0U;
    uint2  trail_0 = _S76;
    float probability_1 = 1.0f;
    for(;;)
    {
        uint4  _S77 = (fcptLightNode((n_0)));
        if((_S77.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S78 = (fcptLightSecond((n_0)));
        uint _S79 = n_0 + 1U;
        LightNode _S80 = (fcptLightBounds((_S79)));
        LightNode _S81 = (fcptLightBounds((_S78)));
        uint _S82 = trail_0.x;
        uint _S83 = _S82 & 1U;
        float _S84 = childShare(_S80, _S81, origin_3, smooth_n_1, _S83);
        float probability_2 = probability_1 * _S84;
        bool _S85 = _S83 == 1U;
        uint _S86 = _slang_select(_S85, _S78,_S79);
        uint _S87 = trail_0.y;
        uint2  _S88 = make_uint2 ((_S82 >> 1U) | (_S87 << 31U), _S87 >> 1U);
        n_0 = _S86;
        trail_0 = _S88;
        probability_1 = probability_2;
    }
    bool _S89 = (fcptSlotLeaf((n_0), (j_0)));
    bool _S90 = !_S89;
    bool _S91;
    if(_S90)
    {
        _S91 = true;
    }
    else
    {
        LightNode _S92 = (fcptLightBounds((n_0)));
        float _S93 = importance(_S92, origin_3, smooth_n_1);
        _S91 = !(_S93 > 0.0f);
    }
    if(_S91)
    {
        _S91 = true;
    }
    else
    {
        bool _S94 = (dot_0(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S94)
        {
            _S91 = !((dot_0(smooth_n_1, light_point_0 - start_1)) > 0.0f);
        }
        else
        {
            _S91 = false;
        }
    }
    if(_S91)
    {
        return 0.0f;
    }
    uint4  _S95 = (fcptLightNode((n_0)));
    bool _S96 = (_S95.x) == 2U;
    if(_S96)
    {
        uint _S97 = _S95.y;
        FKLight _S98 = (fcptLight((_S97)));
        FKLight _S99 = (fcptLight((_S97)));
        float _S100 = sphereDensity(_S98.position, _S99.variance, start_1);
        return probability_1 * _S100;
    }
    uint _S101 = _S95.y;
    uint _S102 = (fcptTriangleOffset((_S101)));
    Matrix<float, 3, 3>  _S103 = (fcptWorldTriangle((_S101), (_S102 + _S95.z)));
    float _S104 = solidAngle(probability_1, cross_0(_S103.rows[int(1)] - _S103.rows[int(0)], _S103.rows[int(2)] - _S103.rows[int(0)]), light_point_0 - start_1);
    return _S104;
}

static __device__ float3  environment_0(float3  dir_2, uint depth_0, uint lobe_0)
{
    uint2  _S105 = (fcptEnvironmentMapSize());
    bool _S106 = (_S105.x) > 1U;
    bool _S107;
    if(_S106)
    {
        uint2  _S108 = (fcptEnvironmentMapSize());
        _S107 = (_S108.y) > 1U;
    }
    else
    {
        _S107 = false;
    }
    if(_S107)
    {
        float3  _S109 = (fcptEnvMapSample((dir_2), (depth_0), (lobe_0)));
        return _S109;
    }
    float3  _S110 = (fcptAmbient());
    return _S110;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S111 = (fcptEnvironmentCdfSize());
    bool _S112 = (_S111.x) > 1U;
    bool _S113;
    if(_S112)
    {
        uint2  _S114 = (fcptEnvironmentCdfSize());
        _S113 = (_S114.y) > 1U;
    }
    else
    {
        _S113 = false;
    }
    bool _S115 = !_S113;
    if(_S115)
    {
        return false;
    }
    uint2  _S116 = (fcptEnvironmentMapSize());
    bool _S117 = (_S116.x) > 1U;
    if(_S117)
    {
        uint2  _S118 = (fcptEnvironmentMapSize());
        _S113 = (_S118.y) > 1U;
    }
    else
    {
        _S113 = false;
    }
    return _S113;
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
    uint2  _S119 = (fcptEnvironmentCdfSize());
    uint2  _S120 = _S119 - make_uint2 (1U, 0U);
    float2  _S121 = make_float2 ((F32_atan2((- dir_3.z), (- dir_3.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_0(dir_3.y, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S122 = make_float2 ((float)_S120.x, (float)_S120.y);
    float2  _S123 = _S121 * _S122;
    uint2  _S124 = make_uint2 ((uint)_S123.x, (uint)_S123.y);
    uint2  _S125 = min_0(_S124, _S120 - make_uint2 (1U));
    float4  _S126 = (fcptEnvironmentCdf((_S125)));
    float _S127 = _S126.y;
    uint _S128 = _S120.x;
    float4  _S129 = (fcptEnvironmentCdf((make_uint2 (_S128, _S125.y))));
    float _S130 = _S127 * _S129.y;
    return _S130 * float(_S128 * _S120.y) / (19.73921012878417969f * length_1(float2 {dir_3.x, dir_3.z}));
}

static __device__ float escapeWeight_0(float pdf_0, float3  dir_4)
{
    bool _S131 = pdf_0 <= 0.0f;
    bool _S132;
    if(_S131)
    {
        _S132 = true;
    }
    else
    {
        bool _S133 = environmentMapped_0();
        _S132 = !_S133;
    }
    if(_S132)
    {
        return 1.0f;
    }
    float _S134 = environmentPdf_0(dir_4);
    return pdf_0 / (pdf_0 + _S134);
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
    uint _S135 = x_6 * 747796405U + 2891336453U;
    uint _S136 = ((_S135 >> ((_S135 >> 28U) + 4U)) ^ _S135) * 277803737U;
    return (_S136 >> 22U) ^ _S136;
}

static __device__ float random_0(uint * state_0)
{
    uint _S137 = hash(*state_0);
    *state_0 = _S137;
    return float((*state_0) >> int(8)) * 5.9604644775390625e-08f;
}

static __device__ Random Random_x24init_0(uint state_1, float value_0)
{
    Random _S138;
    (&_S138)->state = state_1;
    (&_S138)->value = value_0;
    return _S138;
}

__device__ Random pcg(uint state_2)
{
    uint _S139 = state_2;
    float value_1 = random_0(&_S139);
    return Random_x24init_0(_S139, value_1);
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
    float _S140;
    if(e_0 > 0.0f)
    {
        _S140 = 1.0f;
    }
    else
    {
        if(e_0 < 0.0f)
        {
            _S140 = -1.0f;
        }
        else
        {
            _S140 = 0.0f;
        }
    }
    return _S140;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S141;
    (&_S141)->tangent = tangent_0;
    (&_S141)->alphas = alphas_0;
    return _S141;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_0 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S142 = (F32_abs((dot_0(n_1, a_0)))) > 0.9999847412109375f;
    float3  a_1;
    if(_S142)
    {
        float3  _S143 = make_float3 (1.0f, 0.0f, 0.0f);
        a_1 = _S143;
    }
    else
    {
        a_1 = a_0;
    }
    float3  _S144 = cross_0(n_1, a_1);
    float3  _S145 = ((((_S144)) * make_float3(rnorm3df(((_S144)).x, ((_S144)).y, ((_S144)).z))));
    float3  _S146 = cross_0(n_1, _S145);
    return make_float3 (v_0.x) * _S145 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S146;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_0, float3  n_i_0)
{
    float _S147 = material_0.roughness;
    float _S148 = _S147 * _S147;
    bool _S149 = (material_0.anisotropy) == 0.0f;
    bool _S150;
    if(_S149)
    {
        _S150 = true;
    }
    else
    {
        _S150 = !(_S148 > 0.0f);
    }
    if(_S150)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S151 = material_0.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_0.tangent));
    float3  _S152 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S153 = (dot_0(_S151, _S151)) > 0.0f;
    float3  _S154 = _slang_select(_S153, _S151,_S152);
    float3  _S155 = ((((_S154)) * make_float3(rnorm3df(((_S154)).x, ((_S154)).y, ((_S154)).z))));
    float _S156 = 6.28318548202514648f * material_0.anisotropic_rotation;
    float _S157 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_0.anisotropy))))));
    float _S158 = 1.0f / _S157;
    bool _S159 = (material_0.anisotropy) < 0.0f;
    float _S160 = _slang_select(_S159, _S158,_S157);
    return AnisotropicFrame_x24init_0(_S155 * make_float3 ((F32_cos((_S156)))) + cross_0(n_i_0, _S155) * make_float3 ((F32_sin((_S156)))), make_float2 (_S148 / _S160, _S148 * _S160));
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
    float3  _S161 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S162 = ((((_S161)) * make_float3(rnorm3df(((_S161)).x, ((_S161)).y, ((_S161)).z))));
    float _S163 = _S162.x;
    float _S164 = _S162.y;
    float _S165 = _S163 * _S163 + _S164 * _S164;
    float3  _S166;
    if(_S165 > 0.0f)
    {
        float3  _S167 = make_float3 (- _S164, _S163, 0.0f);
        float _S168 = (rsqrtf((_S165)));
        _S166 = _S167 * make_float3 (_S168);
    }
    else
    {
        _S166 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S169 = cross_0(_S162, _S166);
    float _S170 = (F32_sqrt((U1_0)));
    float _S171 = 6.28318548202514648f * U2_0;
    float _S172 = _S170 * (F32_cos((_S171)));
    float t2_0 = _S170 * (F32_sin((_S171)));
    float _S173 = 0.5f * (1.0f + _S162.z);
    float t2_1 = (1.0f - _S173) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S172 * _S172)))))) + _S173 * t2_0;
    float3  _S174 = make_float3 (_S172) * _S166 + make_float3 (t2_1) * _S169;
    float _S175 = unshared_0(_S172);
    float _S176 = unshared_0(_S172);
    float3  _S177 = _S174 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S175 * _S176 - t2_1 * t2_1))))))) * _S162;
    float3  _S178 = make_float3 (alpha_0 * _S177.x, alpha_0 * _S177.y, (F32_max((0.0f), (_S177.z))));
    float3  _S179 = ((((_S178)) * make_float3(rnorm3df(((_S178)).x, ((_S178)).y, ((_S178)).z))));
    return _S179;
}

__device__ float3  sampleAnisotropicVNDF(float3  Ve_1, float2  alphas_1, float U1_1, float U2_1)
{
    float _S180 = alphas_1.x;
    float _S181 = alphas_1.y;
    float3  _S182 = make_float3 (_S180 * Ve_1.x, _S181 * Ve_1.y, Ve_1.z);
    float3  _S183 = ((((_S182)) * make_float3(rnorm3df(((_S182)).x, ((_S182)).y, ((_S182)).z))));
    float3  _S184 = sampleGGXVNDF(_S183, 1.0f, U1_1, U2_1);
    float3  _S185 = make_float3 (_S180 * _S184.x, _S181 * _S184.y, _S184.z);
    float3  _S186 = ((((_S185)) * make_float3(rnorm3df(((_S185)).x, ((_S185)).y, ((_S185)).z))));
    return _S186;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
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
    return make_float3 (dot_0(v_1, _S190), dot_0(v_1, n_3), dot_0(v_1, _S191));
}

__device__ __forceinline__ float3  sampleMaterialHalfVector(float3  v_2, float3  n_i_1, float alpha_1, AnisotropicFrame frame_0, uint * random_state_1)
{
    Random _S192 = pcg(*random_state_1);
    Random _S193 = pcg(_S192.state);
    *random_state_1 = _S193.state;
    bool _S194 = (frame_0.alphas.x) > 0.0f;
    if(_S194)
    {
        float3  _S195 = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        float3  _S196 = sampleAnisotropicVNDF(_S195, frame_0.alphas, _S192.value, _S193.value);
        return make_float3 (_S196.x) * frame_0.tangent + make_float3 (_S196.y) * cross_0(n_i_1, frame_0.tangent) + make_float3 (_S196.z) * n_i_1;
    }
    float3  _S197 = worldToTangent(v_2, n_i_1);
    float3  _S198 = sampleGGXVNDF(float3 {_S197.x, _S197.z, _S197.y}, alpha_1, _S192.value, _S193.value);
    float3  _S199 = float3 {_S198.x, _S198.z, _S198.y};
    float3  _S200 = tangentToWorld(_S199, n_i_1);
    return _S200;
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
    float _S201 = dot_0(n_4, i_1);
    float _S202 = 1.0f - eta_0 * eta_0 * (1.0f - _S201 * _S201);
    if(_S202 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_1 - make_float3 (eta_0 * _S201 + (F32_sqrt((_S202)))) * n_4;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S203 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S204 = eta_i_0 / eta_o_0 * _S203;
    bool _S205 = _S204 < 1.0f;
    float kr_0;
    if(_S205)
    {
        float _S206 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S204 * _S204))))));
        float _S207 = eta_o_0 * cos_theta_0;
        float _S208 = eta_i_0 * _S206;
        float _S209 = (_S207 - _S208) / (_S207 + _S208);
        float _S210 = eta_i_0 * cos_theta_0;
        float _S211 = eta_o_0 * _S206;
        float _S212 = (_S210 - _S211) / (_S210 + _S211);
        float _S213 = (_S209 * _S209 + _S212 * _S212) / 2.0f;
        kr_0 = _S213;
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
    float _S214 = (F32_sqrt((0.05000000074505806f)));
    float _S215 = clamp_0((F32_sqrt(((F32_max((mu_0), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
    float _S216 = (clamp_0((F32_sqrt(((F32_max((r_0), (0.0f)))))), _S214, 1.0f) - _S214) / (1.0f - _S214) * 23.0f;
    uint _S217 = (U32_min((uint(_S215)), (22U)));
    uint _S218 = (U32_min((uint(_S216)), (22U)));
    float _S219 = _S215 - float(_S217);
    float _S220 = _S216 - float(_S218);
    uint _S221 = _S217 * 24U + _S218;
    uint _S222 = _S221 + 24U;
    float _S223 = SHEEN_ALBEDO_0[_S221] + (SHEEN_ALBEDO_0[_S222] - SHEEN_ALBEDO_0[_S221]) * _S219;
    uint _S224 = _S221 + 1U;
    float _S225 = SHEEN_ALBEDO_0[_S224] + (SHEEN_ALBEDO_0[_S222 + 1U] - SHEEN_ALBEDO_0[_S224]) * _S219;
    return (F32_exp((_S223 + (_S225 - _S223) * _S220)));
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

__device__ float anisotropicG1(float3  w_1, float2  alphas_2)
{
    float _S226 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S226 / (_S226 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S226)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S227 = alphas_3.x;
    float _S228 = h_0.x / _S227;
    float _S229 = alphas_3.y;
    float _S230 = h_0.y / _S229;
    float _S231 = h_0.z;
    float _S232 = _S228 * _S228 + _S230 * _S230 + _S231 * _S231;
    return 1.0f / (F32_max((3.14159274101257324f * _S227 * _S229 * _S232 * _S232), (1.17549435082228751e-38f)));
}

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_0, float3  refracted_1, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_0, float3  sheen_0, float3  view_0, float3  tangent_1, float2  alphas_4, float visible_0)
{
    BSDFLobes _S233;
    (&_S233)->v_dot_h = v_dot_h_0;
    (&_S233)->n_dot_h = n_dot_h_0;
    (&_S233)->refracted = refracted_1;
    (&_S233)->F = F_0;
    (&_S233)->F_greyscale = F_greyscale_0;
    (&_S233)->reflect_weight = reflect_weight_0;
    (&_S233)->diffuse_weight = diffuse_weight_0;
    (&_S233)->refract_weight = refract_weight_0;
    (&_S233)->p_diffuse = p_diffuse_0;
    (&_S233)->p_reflect = p_reflect_0;
    (&_S233)->p_refract = p_refract_0;
    (&_S233)->translucent_share = translucent_share_0;
    (&_S233)->sheen = sheen_0;
    (&_S233)->view = view_0;
    (&_S233)->tangent = tangent_1;
    (&_S233)->alphas = alphas_4;
    (&_S233)->visible = visible_0;
    return _S233;
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_0, float3  v_3, float3  n_i_2, float3  ggx_n_0, BSDFMaterial material_1, float eta_i_1, float eta_o_1, AnisotropicFrame frame_1)
{
    float _S234 = dot_0(ggx_n_0, v_3);
    float _S235 = dot_0(n_i_2, ggx_n_0);
    float _S236 = eta_i_1 / eta_o_1;
    float3  _S237 = refract_0(in_dir_0, ggx_n_0, _S236);
    float3  _S238 = ((((_S237)) * make_float3(rnorm3df(((_S237)).x, ((_S237)).y, ((_S237)).z))));
    float _S239 = (F32_min(((F32_sqrt((material_1.specular_level))) * (F32_abs((eta_i_1 - eta_o_1))) / (eta_i_1 + eta_o_1)), (0.9999847412109375f)));
    float _S240 = _S239 * _S239;
    float _S241 = (1.0f + _S239) / (1.0f - _S239);
    float _S242 = (F32_abs((_S234)));
    bool _S243 = eta_i_1 > eta_o_1;
    float sheen_component_0;
    if(_S243)
    {
        sheen_component_0 = _S241;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float visible_1;
    if(_S243)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S241;
    }
    float _S244 = fresnel(_S242, sheen_component_0, visible_1);
    bool _S245 = (eta_i_1 * eta_i_1 * (1.0f - _S234 * _S234)) >= (eta_o_1 * eta_o_1);
    float3  _S246;
    if(_S245)
    {
        _S246 = make_float3 (1.0f);
    }
    else
    {
        float3  _S247 = material_1.specular_tint * make_float3 (_S240);
        _S246 = _S247 + (make_float3 (1.0f) - _S247) * make_float3 (_S244 - _S240) / make_float3 (1.0f - _S240);
    }
    float3  _S248 = make_float3 (1.0f);
    float3  _S249 = make_float3 (0.0f);
    float _S250 = rgb_to_greyscale(material_1.sheen);
    bool _S251 = _S250 > 0.0f;
    float3  scale_0;
    float3  sheen_1;
    float3  view_1;
    if(_S251)
    {
        float _S252 = sheenAlbedo(dot_0(n_i_2, v_3), material_1.sheen_roughness);
        float _S253 = (F32_min((_S252), (1.0f)));
        float3  _S254 = make_float3 (1.0f) - material_1.sheen * make_float3 (_S253);
        float _S255 = rgb_to_greyscale(material_1.sheen);
        float _S256 = _S255 * _S253;
        float3  _S257 = material_1.sheen / make_float3 ((F32_max((_S252), (1.0f))));
        scale_0 = _S254;
        sheen_component_0 = _S256;
        sheen_1 = _S257;
        view_1 = v_3;
    }
    else
    {
        scale_0 = _S248;
        sheen_component_0 = 0.0f;
        sheen_1 = _S249;
        view_1 = _S249;
    }
    float3  _S258 = mix_0(_S246, material_1.albedo, material_1.metallic);
    float3  F_1 = _S258 * scale_0;
    float _S259 = rgb_to_greyscale(F_1);
    float _S260 = 1.0f - material_1.metallic;
    float3  _S261 = make_float3 (1.0f) - _S246;
    float3  _S262 = make_float3 ((1.0f - material_1.transmission) * _S260) * _S261 * scale_0;
    float3  _S263 = make_float3 (material_1.transmission * _S260) * _S261 * scale_0;
    float _S264 = (F32_max((_S259), (0.0f)));
    float _S265 = rgb_to_greyscale(_S262);
    float _S266 = (F32_max((_S265), (0.0f)));
    float _S267 = rgb_to_greyscale(_S263);
    float _S268 = sign_0(length_0(_S238));
    float _S269 = (F32_max((_S267 * _S268), (0.0f)));
    float _S270 = _S264 + _S266 + _S269 + sheen_component_0;
    float _S271 = 1.0f / (F32_max((_S270), (0.0000152587890625f)));
    float _S272 = (_S266 + sheen_component_0) * _S271;
    float _S273 = _S264 * _S271;
    float _S274 = _S269 * _S271;
    bool _S275 = (frame_1.alphas.x) > 0.0f;
    if(_S275)
    {
        float3  _S276 = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        float _S277 = anisotropicG1(_S276, frame_1.alphas);
        float3  _S278 = anisotropicLocal(ggx_n_0, frame_1.tangent, n_i_2);
        float _S279 = anisotropicD(_S278, frame_1.alphas);
        float _S280 = _S277 * _S279;
        visible_1 = _S280;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S234, _S235, _S238, F_1, _S259, 1.0f, _S262, _S263, _S272, _S273, _S274, 0.0f, sheen_1, view_1, frame_1.tangent, frame_1.alphas, visible_1);
}

__device__ float translucentShare(BSDFMaterial material_2)
{
    float _S281 = rgb_to_greyscale(material_2.translucent);
    float _S282 = rgb_to_greyscale(material_2.albedo);
    float _S283 = _S281 / (_S282 + _S281);
    bool _S284 = _S281 > 0.0f;
    float _S285 = _slang_select(_S284, _S283,0.0f);
    return _S285;
}

__device__ float smithG1(float alpha_2, float n_dot_x_0)
{
    float _S286 = alpha_2 * alpha_2;
    float _S287 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S286 + (1.0f - _S286) * n_dot_x_0 * n_dot_x_0))));
    bool _S288 = alpha_2 > 0.0f;
    float _S289 = _slang_select(_S288, _S287,1.0f);
    return _S289;
}

__device__ float trowbridgeReitz(float alpha_3, float n_dot_h_1)
{
    float _S290 = alpha_3 * alpha_3;
    float _S291 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S290 * n_dot_h_1 * n_dot_h_1;
    return _S290 / (F32_max((3.14159274101257324f * _S291 * _S291), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, BSDFLobes lobes_0, float eta_i_2, float eta_o_2, uint lobe_1)
{
    bool _S292 = lobe_1 == 0U;
    if(_S292)
    {
        float _S293 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        float _S294 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
        float _S295 = 1.0f - lobes_0.translucent_share;
        bool _S296 = n_i_dot_l_0 < 0.0f;
        float _S297 = _slang_select(_S296, lobes_0.translucent_share,_S295);
        float _S298 = _S294 * _S297;
        bool _S299 = (lobes_0.translucent_share) > 0.0f;
        float _S300 = _slang_select(_S299, _S298,_S293);
        bool _S301 = n_i_dot_v_0 > 0.0f;
        float _S302 = _slang_select(_S301, _S300,0.0f);
        return _S302;
    }
    float _S303 = smithG1(alpha_4, n_i_dot_v_0);
    float _S304 = _S303 * lobes_0.v_dot_h;
    float _S305 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    float _S306 = _S304 * _S305 / n_i_dot_v_0;
    bool _S307 = alpha_4 > 0.0f;
    bool _S308;
    if(_S307)
    {
        _S308 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S308 = false;
    }
    if(_S308)
    {
        _S308 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S308 = false;
    }
    if(_S308)
    {
        _S308 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S308 = false;
    }
    float _S309 = _slang_select(_S308, _S306,0.0f);
    bool _S310 = (lobes_0.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S310)
    {
        float _S311 = lobes_0.visible * lobes_0.v_dot_h / n_i_dot_v_0;
        bool _S312 = (lobes_0.v_dot_h) > 0.0f;
        if(_S312)
        {
            _S308 = (lobes_0.n_dot_h) > 0.0f;
        }
        else
        {
            _S308 = false;
        }
        if(_S308)
        {
            _S308 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S308 = false;
        }
        float _S313 = _slang_select(_S308, _S311,0.0f);
        pdf_h_0 = _S313;
    }
    else
    {
        pdf_h_0 = _S309;
    }
    bool _S314 = lobe_1 == 1U;
    if(_S314)
    {
        float _S315 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        float _S316 = lobes_0.p_refract * pdf_h_0 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S315 * _S315);
        bool _S317 = eta_i_2 != eta_o_2;
        if(_S317)
        {
            _S308 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S308 = false;
        }
        float _S318 = _slang_select(_S308, _S316,0.0f);
        return _S318;
    }
    float _S319 = lobes_0.p_reflect * pdf_h_0 / (4.0f * lobes_0.v_dot_h);
    bool _S320 = pdf_h_0 > 0.0f;
    float _S321 = _slang_select(_S320, _S319,0.0f);
    return _S321;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_0, uint random_state_2, bool refracted_2, uint lobe_2, float pdf_1)
{
    SampleBSDF _S322;
    (&_S322)->unit_direction = unit_direction_1;
    (&_S322)->throughput = throughput_0;
    (&_S322)->random_state = random_state_2;
    (&_S322)->refracted = refracted_2;
    (&_S322)->lobe = lobe_2;
    (&_S322)->pdf = pdf_1;
    return _S322;
}

__device__ float sheenBRDF(float3  l_0, float3  v_4, float3  n_5, float r_1)
{
    float _S323 = 1.0f / (F32_max((r_1), (0.05000000074505806f)));
    float3  _S324 = l_0 + v_4;
    float3  _S325 = ((((_S324)) * make_float3(rnorm3df(((_S324)).x, ((_S324)).y, ((_S324)).z))));
    float _S326 = dot_0(n_5, _S325);
    float _S327 = (F32_max((dot_0(n_5, l_0)), (0.0f)));
    float _S328 = (F32_max((dot_0(n_5, v_4)), (0.0f)));
    return (2.0f + _S323) * (F32_pow(((F32_max((1.0f - _S326 * _S326), (0.0f)))), (0.5f * _S323))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S327 + _S328 - _S327 * _S328)), (0.0000152587890625f)));
}

__device__ __forceinline__ float3  lobeThroughput(float3  l_1, float3  n_i_3, float alpha_5, BSDFMaterial material_3, BSDFLobes lobes_1, uint lobe_3)
{
    bool _S329 = lobe_3 == 0U;
    if(_S329)
    {
        bool _S330 = (dot_0(n_i_3, l_1)) < 0.0f;
        float3  _S331 = _slang_select(_S330, material_3.translucent,material_3.albedo);
        float _S332 = 1.0f - lobes_1.translucent_share;
        float _S333 = _slang_select(_S330, lobes_1.translucent_share,_S332);
        float3  _S334 = _S331 / make_float3 (_S333);
        bool _S335 = (lobes_1.translucent_share) > 0.0f;
        float3  _S336 = _slang_select(_S335, _S334,material_3.albedo);
        float _S337 = rgb_to_greyscale(material_3.sheen);
        bool _S338 = _S337 > 0.0f;
        bool _S339;
        if(_S338)
        {
            _S339 = !_S330;
        }
        else
        {
            _S339 = false;
        }
        if(_S339)
        {
            float3  _S340 = lobes_1.diffuse_weight * _S336;
            float3  _S341 = lobes_1.sheen * make_float3 (3.14159274101257324f);
            float _S342 = sheenBRDF(l_1, lobes_1.view, n_i_3, material_3.sheen_roughness);
            float3  _S343 = _S341 * make_float3 (_S342);
            float _S344 = _slang_select(_S335, _S332,1.0f);
            return (_S340 + _S343 / make_float3 (_S344)) / make_float3 (lobes_1.p_diffuse);
        }
        return lobes_1.diffuse_weight * _S336 / make_float3 (lobes_1.p_diffuse);
    }
    bool _S345 = lobe_3 == 1U;
    float G1_l_0;
    if(_S345)
    {
        float _S346 = - dot_0(n_i_3, l_1);
        float _S347 = smithG1(alpha_5, (F32_max((_S346), (0.0f))));
        bool _S348 = (lobes_1.alphas.x) > 0.0f;
        if(_S348)
        {
            float3  _S349 = negate_0(n_i_3);
            float3  _S350 = anisotropicLocal(l_1, lobes_1.tangent, _S349);
            float _S351 = anisotropicG1(_S350, lobes_1.alphas);
            G1_l_0 = _S351;
        }
        else
        {
            G1_l_0 = _S347;
        }
        return lobes_1.refract_weight * make_float3 (G1_l_0) * material_3.albedo / make_float3 (lobes_1.p_refract);
    }
    float _S352 = dot_0(n_i_3, l_1);
    float _S353 = smithG1(alpha_5, (F32_max((_S352), (0.0f))));
    bool _S354 = (lobes_1.alphas.x) > 0.0f;
    if(_S354)
    {
        float3  _S355 = anisotropicLocal(l_1, lobes_1.tangent, n_i_3);
        float _S356 = anisotropicG1(_S355, lobes_1.alphas);
        G1_l_0 = _S356;
    }
    else
    {
        G1_l_0 = _S353;
    }
    return make_float3 (lobes_1.reflect_weight * G1_l_0) * lobes_1.F / make_float3 (lobes_1.p_reflect);
}

__device__ __forceinline__ SampleBSDF connectBSDF(float3  in_dir_1, float3  out_dir_0, float3  n_6, BSDFMaterial material_4, float eta_i_3, float eta_o_3, uint lobe_4, uint random_init_0)
{
    uint random_state_3 = random_init_0;
    float3  _S357 = negate_0(in_dir_1);
    float _S358 = dot_0(n_6, _S357);
    float _S359 = sign_0(_S358);
    float3  _S360 = n_6 * make_float3 (_S359);
    float _S361 = material_4.roughness;
    float _S362 = _S361 * _S361;
    AnisotropicFrame _S363 = anisotropicFrame(material_4, _S360);
    float3  _S364 = _S357 + out_dir_0;
    float3  _S365 = ((((_S364)) * make_float3(rnorm3df(((_S364)).x, ((_S364)).y, ((_S364)).z))));
    bool _S366 = lobe_4 == 0U;
    float3  ggx_n_1;
    if(_S366)
    {
        float3  _S367 = sampleMaterialHalfVector(_S357, _S360, _S362, _S363, &random_state_3);
        ggx_n_1 = _S367;
    }
    else
    {
        bool _S368 = lobe_4 == 1U;
        if(_S368)
        {
            float3  _S369 = negate_0(make_float3 (eta_i_3) * _S357 + make_float3 (eta_o_3) * out_dir_0);
            float3  _S370 = ((((_S369)) * make_float3(rnorm3df(((_S369)).x, ((_S369)).y, ((_S369)).z))));
            float _S371 = sign_0(dot_0(_S369, _S360));
            float3  _S372 = _S370 * make_float3 (_S371);
            ggx_n_1 = _S372;
        }
        else
        {
            ggx_n_1 = _S365;
        }
    }
    BSDFLobes _S373 = bsdfLobes(in_dir_1, _S357, _S360, ggx_n_1, material_4, eta_i_3, eta_o_3, _S363);
    BSDFLobes lobes_2 = _S373;
    float _S374 = translucentShare(material_4);
    (&lobes_2)->translucent_share = _S374;
    float _S375 = lobeDensity(dot_0(_S360, out_dir_0), dot_0(out_dir_0, ggx_n_1), (F32_abs((_S358))), _S362, lobes_2, eta_i_3, eta_o_3, lobe_4);
    bool _S376 = !(_S375 > 0.0f);
    if(_S376)
    {
        float3  _S377 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S377, _S377, 0U, false, 0U, 0.0f);
    }
    float3  _S378 = lobeThroughput(out_dir_0, _S360, _S362, material_4, lobes_2, lobe_4);
    return SampleBSDF_x24init_0(out_dir_0, _S378, random_state_3, lobe_4 == 1U, lobe_4, _S375);
}

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_2, float3  dir_5, float3  n_7, BSDFMaterial material_5, float eta_i_4, float eta_o_4, bool refracted_3, float pdf_2, bool power_0, uint random_state_4)
{
    float3  _S379 = make_float3 (0.0f);
    uint lobe_5 = 0U;
    float3  f_0 = _S379;
    for(;;)
    {
        if(lobe_5 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S380 = lobe_5 == 0U;
        if(_S380)
        {
        }
        bool _S381;
        if(_S380)
        {
            float _S382 = rgb_to_greyscale(material_5.translucent);
            _S381 = _S382 > 0.0f;
        }
        else
        {
            _S381 = false;
        }
        bool _S383;
        if(_S381)
        {
            float _S384 = dot_0(n_7, dir_5);
            float3  _S385 = negate_0(in_dir_2);
            _S383 = ((_S384 * dot_0(n_7, _S385)) < 0.0f) == refracted_3;
        }
        else
        {
            _S383 = (lobe_5 == 1U) == refracted_3;
        }
        float3  f_1;
        if(_S383)
        {
            SampleBSDF _S386 = connectBSDF(in_dir_2, dir_5, n_7, material_5, eta_i_4, eta_o_4, lobe_5, random_state_4);
            bool _S387 = (_S386.pdf) > 0.0f;
            if(_S387)
            {
                if(power_0)
                {
                    float _S388 = _S386.pdf / pdf_2;
                    float3  f_2 = f_0 + _S386.throughput * make_float3 (_S386.pdf) / make_float3 (pdf_2 * (1.0f + _S388 * _S388));
                    f_1 = f_2;
                }
                else
                {
                    float3  f_3 = f_0 + _S386.throughput * make_float3 (_S386.pdf) / make_float3 (_S386.pdf + pdf_2);
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
    bool _S389 = wrongSide_0(is_inside_2, false, dir_6, side_n_1);
    float3  _S390 = neeBSDF(in_dir_3, dir_6, surface_1.smooth_n, surface_1.material, eta_1.x, eta_1.y, _S389, pdf_3, false, random_state_5);
    return _S390;
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
    SkySample _S391;
    (&_S391)->dir = dir_7;
    (&_S391)->radiance = radiance_0;
    (&_S391)->color = color_0;
    (&_S391)->random_state = random_state_6;
    return _S391;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float3  side_n_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0)
{
    uint2  _S392 = (fcptEnvironmentCdfSize());
    uint2  _S393 = make_uint2 (1U, 0U);
    uint2  _S394 = _S392 - _S393;
    Random _S395 = pcg(init_random_state_0);
    Random _S396 = pcg(_S395.state);
    Random _S397 = pcg(_S396.state);
    Random _S398 = pcg(_S397.state);
    uint _S399 = _S394.x;
    uint _S400 = searchCDF_0(make_uint2 (_S399, 0U), make_uint2 (0U, 1U), _S394.y, _S395.value);
    uint _S401 = searchCDF_0(make_uint2 (0U, _S400), _S393, _S399, _S396.value);
    float2  _S402 = make_float2 ((float)_S394.x, (float)_S394.y);
    float2  _S403 = (make_float2 (float(_S401), float(_S400)) + make_float2 (_S397.value, _S398.value)) / _S402 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S404 = _S403.y;
    float _S405 = (F32_sin((_S404)));
    float _S406 = _S403.x;
    float3  _S407 = make_float3 (_S405 * (F32_cos((_S406))), (F32_cos((_S404))), _S405 * (F32_sin((_S406))));
    float _S408 = environmentPdf_0(_S407);
    float3  _S409 = skyBSDF(ray_0->unit_direction, _S407, *surface_2, side_n_2, eta_2, is_inside_3, _S408, lobe_state_0);
    bool _S410 = !(_S408 > 0.0f);
    bool _S411;
    if(_S410)
    {
        _S411 = true;
    }
    else
    {
        _S411 = all_0(_S409 == make_float3 (0.0f));
    }
    if(_S411)
    {
        float3  _S412 = make_float3 (0.0f);
        return SkySample_x24init_0(_S407, _S412, _S412, _S398.state);
    }
    float3  _S413 = skyRadiance_0(ray_0->origin, surface_2, side_n_2, is_inside_3, _S407);
    return SkySample_x24init_0(_S407, _S413, _S409 * _S413, _S398.state);
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
    TreeSample _S414;
    (&_S414)->dir = dir_8;
    (&_S414)->radiance = radiance_1;
    (&_S414)->density = density_0;
    (&_S414)->random_state = random_state_7;
    return _S414;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_3, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S415 = importance(first_1, p_3, normal_3);
    float _S416 = importance(second_1, p_3, normal_3);
    float2  _S417 = make_float2 (_S415, _S416);
    bool _S418 = _S415 == 0.0f;
    bool _S419;
    if(_S418)
    {
        _S419 = _S416 == 0.0f;
    }
    else
    {
        _S419 = false;
    }
    if(_S419)
    {
        return 2U;
    }
    float _S420 = _S415 + _S416;
    bool _S421 = _S416 > 0.0f;
    if(_S421)
    {
        _S419 = (*pick_0 * _S420) >= _S415;
    }
    else
    {
        _S419 = false;
    }
    uint _S422 = uint(_S419);
    float _S423 = (F32_min(((*pick_0 * _S420 - float(_S422) * _S415) / _slang_vector_get_element(_S417, _S422)), (0.99999994039535522f)));
    *pick_0 = _S423;
    float _S424 = *probability_3 * (_slang_vector_get_element(_S417, _S422) / _S420);
    *probability_3 = _S424;
    return _S422;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_4, float u1_0, float u2_0)
{
    float3  _S425 = center_1 - p_4;
    float _S426 = radius_1 * radius_1 / dot_0(_S425, _S425);
    float _S427 = u1_0 * _S426 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S426), (0.0f)))))));
    float _S428 = 2.0f * u1_0;
    bool _S429 = _S426 >= 1.0f;
    float _S430 = _slang_select(_S429, _S428,_S427);
    float _S431 = (F32_sqrt(((F32_max((_S430 * (2.0f - _S430)), (0.0f))))));
    float _S432 = 6.28318548202514648f * u2_0;
    float3  _S433 = make_float3 (_S431 * (F32_cos((_S432))), 1.0f - _S430, _S431 * (F32_sin((_S432))));
    float3  _S434 = ((((_S425)) * make_float3(rnorm3df(((_S425)).x, ((_S425)).y, ((_S425)).z))));
    float3  _S435 = tangentToWorld(_S433, _S434);
    return _S435;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S436 = center_2 - ray_1->origin;
    float _S437 = dot_0(_S436, ray_1->unit_direction);
    float _S438 = dot_0(_S436, _S436) - _S437 * _S437;
    float _S439 = radius_3 * radius_3;
    bool _S440 = _S438 > _S439;
    if(_S440)
    {
        return 4.294967296e+09f;
    }
    float _S441 = (F32_sqrt((_S439 - _S438)));
    float _S442 = _S437 - _S441;
    float _S443 = _S437 + _S441;
    bool _S444 = _S442 > 0.0000152587890625f;
    bool _S445;
    if(_S444)
    {
        _S445 = _S442 < max_len_0;
    }
    else
    {
        _S445 = false;
    }
    if(_S445)
    {
        return _S442;
    }
    bool _S446 = _S443 > 0.0000152587890625f;
    if(_S446)
    {
        _S445 = _S443 < max_len_0;
    }
    else
    {
        _S445 = false;
    }
    if(_S445)
    {
        return _S443;
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
    FKHit _S447;
    (&_S447)->uv = uv_0;
    (&_S447)->instance_index = instance_index_0;
    (&_S447)->triangle_index = triangle_index_0;
    (&_S447)->is_point_light = is_point_light_0;
    (&_S447)->distance = distance_0;
    return _S447;
}

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_2, float3  end_0)
{
    float _S448 = sign_0(dot_0(light_n_0, start_2 - end_0));
    return light_n_0 * make_float3 (_S448 * light_offset_0);
}

static __device__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_1)
{
    Random _S449 = pcg(init_random_state_1);
    Random _S450 = pcg(_S449.state);
    Random _S451 = pcg(_S450.state);
    float3  _S452 = make_float3 (0.0f);
    TreeSample _S453 = TreeSample_x24init_0(_S452, _S452, 0.0f, _S451.state);
    TreeSample sample_0 = _S453;
    float3  _S454 = _slang_select(sided_0, _S452,smooth_n_2);
    float3  start_3 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S449.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S455 = (fcptLightNode((n_8)));
        if((_S455.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S456 = (fcptLightSecond((n_8)));
        uint _S457 = n_8 + 1U;
        LightNode _S458 = (fcptLightBounds((_S457)));
        LightNode _S459 = (fcptLightBounds((_S456)));
        uint _S460 = pickChild(_S458, _S459, origin_4, _S454, &pick_1, &probability_4);
        bool _S461 = _S460 > 1U;
        if(_S461)
        {
            return sample_0;
        }
        bool _S462 = _S460 == 1U;
        uint _S463 = _slang_select(_S462, _S456,_S457);
        n_8 = _S463;
    }
    bool _S464 = n_8 == 0U;
    bool _S465;
    if(_S464)
    {
        LightNode _S466 = (fcptLightBounds((0U)));
        float _S467 = importance(_S466, origin_4, _S454);
        _S465 = !(_S467 > 0.0f);
    }
    else
    {
        _S465 = false;
    }
    if(_S465)
    {
        return sample_0;
    }
    uint4  _S468 = (fcptLightNode((n_8)));
    bool _S469 = (_S468.x) == 2U;
    float3  start_4;
    float3  lift_n_0;
    float3  shadow_1;
    if(_S469)
    {
        FKLight _S470 = (fcptLight((_S468.y)));
        if(sided_0)
        {
            float _S471 = sign_0(dot_0(geometry_n_1, _S470.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S471);
            float3  _S472 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            start_4 = _S472;
            lift_n_0 = lift_n_1;
        }
        else
        {
            start_4 = start_3;
            lift_n_0 = smooth_n_2;
        }
        bool _S473 = (_S470.variance) == 0.0f;
        if(_S473)
        {
            float3  _S474 = _S470.position - start_4;
            float3  _S475 = ((((_S474)) * make_float3(rnorm3df(((_S474)).x, ((_S474)).y, ((_S474)).z))));
            (&sample_0)->dir = _S475;
            float3  _S476 = _S470.color * make_float3 (_S470.intensity) / make_float3 (dot_0(_S474, _S474) * probability_4);
            (&sample_0)->radiance = _S476;
            shadow_1 = _S474;
        }
        else
        {
            float3  _S477 = sampleSphere(_S470.position, _S470.variance, start_4, _S450.value, _S451.value);
            (&sample_0)->dir = _S477;
            float _S478 = sphereDensity(_S470.position, _S470.variance, start_4);
            float _S479 = probability_4 * _S478;
            (&sample_0)->density = _S479;
            float3  _S480 = pointLightRadiance(_S470.color, _S470.intensity, _S470.variance);
            float3  _S481 = _S480 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S481;
            FKRay _S482 = Ray_x24init_0(start_4, (&sample_0)->dir);
            float _S483 = raySphere_0(_S470.position, _S470.variance, &_S482, 4.294967296e+09f);
            float3  _S484 = (&sample_0)->dir * make_float3 (_S483);
            shadow_1 = _S484;
        }
    }
    else
    {
        uint _S485 = _S468.y;
        uint _S486 = (fcptTriangleOffset((_S485)));
        uint _S487 = _S486 + _S468.z;
        Matrix<float, 3, 3>  _S488 = (fcptWorldTriangle((_S485), (_S487)));
        float _S489 = (F32_sqrt((_S450.value)));
        float2  _S490 = make_float2 (_S489 * (1.0f - _S451.value), _S489 * _S451.value);
        float3  _S491 = mul_0(make_float3 (1.0f - _S489, _S490.x, _S490.y), _S488);
        if(sided_0)
        {
            float _S492 = sign_0(dot_0(geometry_n_1, _S491 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S492);
            float3  _S493 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            start_4 = _S493;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S494 = !((dot_0(smooth_n_2, _S491 - start_3)) > 0.0f);
            if(_S494)
            {
                return sample_0;
            }
            start_4 = start_3;
            lift_n_0 = smooth_n_2;
        }
        FKSurface _S495 = (fcptSurfaceAt((Hit_x24init_0(_S490, _S485, _S487, 0U, 0.0f)), (_S491), (_S451.state)));
        (&sample_0)->random_state = _S495.random_state;
        float3  _S496 = _S491 - start_4;
        float3  _S497 = ((((_S496)) * make_float3(rnorm3df(((_S496)).x, ((_S496)).y, ((_S496)).z))));
        (&sample_0)->dir = _S497;
        float _S498 = solidAngle(probability_4, cross_0(_S488.rows[int(1)] - _S488.rows[int(0)], _S488.rows[int(2)] - _S488.rows[int(0)]), _S496);
        (&sample_0)->density = _S498;
        float _S499 = sign_0(dot_0(- (&sample_0)->dir, _S495.smooth_n));
        float3  _S500 = _S495.material.emissive * make_float3 ((F32_max((_S499), (0.0f))));
        float3  _S501 = _slang_select(_S495.skip, _S452,_S500);
        float3  _S502 = _S501 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S502;
        float3  _S503 = shadowLift(_S495.smooth_n, _S495.geometry_offset, start_4, _S491);
        float3  _S504 = _S491 + _S503 - start_4;
        shadow_1 = _S504;
    }
    float3  _S505 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_1, _S451.state);
    float3  _S506 = (&sample_0)->radiance * _S505;
    bool _S507 = all_0(_S505 == _S452);
    float3  _S508 = _slang_select(_S507, _S452,_S506);
    (&sample_0)->radiance = _S508;
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
    float _S509 = 1.0f / (1.0f + b_0 / a_4 * (b_0 / a_4));
    bool _S510 = b_0 > 0.0f;
    float _S511 = _slang_select(_S510, _S509,1.0f);
    return _S511;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_0, float3  light_point_1)
{
    bool _S512 = vertex_0->none;
    if(_S512)
    {
        return 1.0f;
    }
    uint _S513 = (fcptLightSlot((*hit_0)));
    float _S514 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S513, light_point_1);
    float _S515 = powerHeuristic(vertex_0->pdf, _S514);
    return _S515;
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
    Shift _S516;
    (&_S516)->f = f_4;
    (&_S516)->jac = jac_0;
    return _S516;
}

static __device__ uint extractBits_0(uint e_1, uint offset_0, uint count_1)
{
    return (e_1 >> offset_0) & ((1U << count_1) - 1U);
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_5)
{
    NEEVertex _S517;
    (&_S517)->none = none_0;
    (&_S517)->pdf = pdf_4;
    (&_S517)->origin = origin_5;
    (&_S517)->smooth_n = smooth_n_3;
    (&_S517)->start = start_5;
    return _S517;
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
    Vertex _S518;
    (&_S518)->rough = rough_0;
    (&_S518)->lobe = lobe_7;
    (&_S518)->pdf = pdf_5;
    (&_S518)->cos = cos_0;
    (&_S518)->inside = inside_0;
    return _S518;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S519 = hash(index_0);
    uint _S520 = hash(seed_0 ^ _S519);
    return _S520;
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
    float3  _S521 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_1));
    float3  _S522 = scatter_0 * _S521 / make_float3 (sigma_1);
    float3  _S523 = _slang_select(scatters_0, _S522,_S521);
    return _S523;
}

static __device__ uint arrivalLobe_0(uint b_1, uint prev_lobe_0)
{
    bool _S524 = b_1 > 0U;
    uint _S525 = _slang_select(_S524, prev_lobe_0,3U);
    return _S525;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_8, bool surface_3, float length_2, float width_0)
{
    ShadowContext _S526;
    (&_S526)->extinction_behind = extinction_behind_0;
    (&_S526)->extinction_front = extinction_front_0;
    (&_S526)->fillings = fillings_0;
    (&_S526)->side = side_0;
    (&_S526)->depth = depth_1;
    (&_S526)->lobe = lobe_8;
    (&_S526)->surface = surface_3;
    (&_S526)->length = length_2;
    (&_S526)->width = width_0;
    return _S526;
}

static __device__ bool scatterSampled_0(bool replay_0, uint b_2, uint stop_0, bool varying_0)
{
    bool _S527 = !replay_0;
    bool _S528;
    if(_S527)
    {
        _S528 = true;
    }
    else
    {
        bool _S529 = b_2 == stop_0;
        if(_S529)
        {
            _S528 = !varying_0;
        }
        else
        {
            _S528 = false;
        }
    }
    return _S528;
}

__device__ float3  safeDivide(float3  a_5, float3  b_3)
{
    float3  _S530 = a_5 / b_3;
    float3  _S531 = make_float3 (0.0f);
    bool3  _S532 = b_3 == _S531;
    float3  _S533 = _slang_select(_S532, _S531,_S530);
    return _S533;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S534 = (1U << count_2) - 1U;
    return (e_2 & (~(_S534 << offset_1))) | ((newbits_0 & _S534) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_1, float3  f_5)
{
    Reservoir candidate_0 = r_2;
    uint _S535 = insertBits_0(r_2.path, end_1, 0U, 5U);
    uint _S536 = insertBits_0(_S535, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S536;
    (&candidate_0)->f = f_5;
    return candidate_0;
}

__device__ void offer(Selection * sel_0, Reservoir candidate_1, float3  weight_0)
{
    float _S537 = rgb_to_greyscale(weight_0);
    bool _S538 = _S537 > 0.0f;
    bool _S539;
    if(_S538)
    {
        _S539 = _S537 < 3.00000000549775576e+38f;
    }
    else
    {
        _S539 = false;
    }
    bool _S540 = !_S539;
    if(_S540)
    {
        return;
    }
    bool _S541 = sel_0->sums;
    if(_S541)
    {
        float3  _S542 = sel_0->color + weight_0;
        sel_0->color = _S542;
        return;
    }
    float _S543 = sel_0->w_sum + _S537;
    sel_0->w_sum = _S543;
    float3  _S544 = sel_0->color + weight_0;
    sel_0->color = _S544;
    Random _S545 = pcg(sel_0->random_state);
    sel_0->random_state = _S545.state;
    bool _S546 = (_S545.value * sel_0->w_sum) <= _S537;
    if(_S546)
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
    Random _S547 = pcg(random_state_8);
    Random _S548 = pcg(_S547.state);
    float _S549 = 1.0f - 2.0f * _S547.value;
    float _S550 = (F32_sqrt(((F32_max((1.0f - _S549 * _S549), (0.0f))))));
    float _S551 = 6.28318548202514648f * _S548.value;
    return make_float3 (_S550 * (F32_cos((_S551))), _S550 * (F32_sin((_S551))), _S549);
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2)
{
    BSDFMaterial _S552;
    (&_S552)->albedo = albedo_0;
    (&_S552)->emissive = emissive_0;
    (&_S552)->roughness = roughness_0;
    (&_S552)->metallic = metallic_0;
    (&_S552)->transmission = transmission_0;
    (&_S552)->ior = ior_0;
    (&_S552)->absorption = absorption_0;
    (&_S552)->specular_tint = specular_tint_0;
    (&_S552)->specular_level = specular_level_0;
    (&_S552)->translucent = translucent_0;
    (&_S552)->sheen = sheen_2;
    (&_S552)->sheen_roughness = sheen_roughness_0;
    (&_S552)->anisotropy = anisotropy_0;
    (&_S552)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S552)->tangent = tangent_2;
    return _S552;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1)
{
    FKMedium _S553;
    (&_S553)->scatter = scatter_1;
    (&_S553)->extinction = extinction_1;
    return _S553;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_6, bool skip_0, uint random_state_9, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0)
{
    FKSurface _S554;
    (&_S554)->smooth_n = smooth_n_4;
    (&_S554)->geometry_n = geometry_n_2;
    (&_S554)->geometry_offset = geometry_offset_2;
    (&_S554)->material = *material_6;
    (&_S554)->skip = skip_0;
    (&_S554)->random_state = random_state_9;
    (&_S554)->coverage = coverage_0;
    (&_S554)->encloses = encloses_0;
    (&_S554)->volume = *volume_0;
    (&_S554)->fills = fills_0;
    return _S554;
}

static __device__ FKSurface emitting_0(FKSurface * surface_4, bool top_0)
{
    FKSurface lower_0 = *surface_4;
    float3  _S555 = (&surface_4->material)->emissive;
    float3  _S556 = make_float3 (0.0f);
    bool _S557 = !top_0;
    float3  _S558 = _slang_select(_S557, _S556,_S555);
    (&(&lower_0)->material)->emissive = _S558;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_5, float u_2)
{
    float _S559 = surface_5->coverage;
    bool _S560 = u_2 < _S559;
    if(_S560)
    {
        return *surface_5;
    }
    float3  _S561 = make_float3 (0.0f);
    float3  _S562 = make_float3 (1.0f);
    BSDFMaterial _S563 = Material_x24init_0(_S561, _S561, 0.0f, 0.0f, 0.0f, 0.0f, _S561, _S562, 1.0f, _S561, _S561, 0.5f, 0.0f, 0.0f, _S561);
    BSDFMaterial material_7 = _S563;
    (&material_7)->albedo = _S562;
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
    bool _S564 = transmission_1 > 0.0f;
    bool _S565;
    if(_S564)
    {
        _S565 = true;
    }
    else
    {
        _S565 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S566;
    if(_S565)
    {
        _S566 = 1.0f;
    }
    else
    {
        _S566 = -1.0f;
    }
    return _S566;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_6, float3  dir_9)
{
    float3  _S567 = surface_6->geometry_n;
    float _S568 = facingSign((&surface_6->material)->transmission, surface_6->geometry_n, dir_9);
    FKSurface faced_0 = *surface_6;
    float3  _S569 = surface_6->smooth_n * make_float3 (_S568);
    (&faced_0)->smooth_n = _S569;
    float3  _S570 = _S567 * make_float3 (_S568);
    (&faced_0)->geometry_n = _S570;
    return faced_0;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_9)
{
    return (dot_0(dir_10, n_9)) > 0.0f;
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
    float3  _S571 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_2) * log_0(_S571));
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
    bool _S572;
    if(open_0)
    {
        _S572 = prev_rough_0;
    }
    else
    {
        _S572 = false;
    }
    if(_S572)
    {
        _S572 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S572 = false;
    }
    return _S572;
}

static __device__ float2  vertexEta_0(BSDFMaterial * material_8, float n_dot_v_0)
{
    bool _S573 = n_dot_v_0 < 0.0f;
    float _S574 = material_8->ior;
    float _S575 = _slang_select(_S573, _S574,1.0f);
    float _S576 = _slang_select(_S573, 1.0f,_S574);
    return make_float2 (_S575, _S576);
}

__device__ bool samplesLights(BSDFMaterial material_9)
{
    bool _S577 = (material_9.roughness) > 0.0f;
    bool _S578;
    if(_S577)
    {
        _S578 = true;
    }
    else
    {
        bool _S579 = (material_9.metallic) < 1.0f;
        if(_S579)
        {
            _S578 = (material_9.transmission) < 1.0f;
        }
        else
        {
            _S578 = false;
        }
    }
    return _S578;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_10)
{
    float _S580 = rgb_to_greyscale(material_10->translucent);
    return _S580 > 0.0f;
}

__device__ float3  sideNormal(FKSurface surface_7, float3  in_dir_4)
{
    bool _S581 = !((surface_7.material.transmission) > 0.0f);
    bool _S582;
    if(_S581)
    {
        BSDFMaterial _S583 = surface_7.material;
        bool _S584 = isTranslucent_0(&_S583);
        _S582 = !_S584;
    }
    else
    {
        _S582 = false;
    }
    if(_S582)
    {
        _S582 = (dot_0(surface_7.smooth_n, - in_dir_4)) > 0.0f;
    }
    else
    {
        _S582 = false;
    }
    float3  _S585 = _slang_select(_S582, surface_7.smooth_n,surface_7.geometry_n);
    return _S585;
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
    MediumSides _S586;
    (&_S586)->behind = *behind_0;
    (&_S586)->front = *front_0;
    (&_S586)->fillings = fillings_1;
    (&_S586)->face = face_1;
    return _S586;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_11)
{
    float3  _S587 = surface_8->geometry_n;
    MediumSides _S588 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S588;
    bool _S589 = surface_8->encloses;
    if(_S589)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S590 = (dot_0(dir_11, _S587)) > 0.0f;
        if(_S590)
        {
            float3  _S591 = make_float3 (0.0f);
            FKMedium _S592 = Medium_x24init_0(_S591, _S591);
            (&sides_0)->front = _S592;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  side_n_3, float3  extinction_2, uint filling_1, float3  dir_12, uint depth_2, uint lobe_9, float length_3, float width_1)
{
    FKSurface faced_1 = *surface_9;
    float3  _S593 = surface_9->geometry_n;
    float3  _S594 = - surface_9->geometry_n;
    float3  _S595 = _slang_select(turned_0, _S594,_S593);
    (&faced_1)->geometry_n = _S595;
    FKMedium _S596 = Medium_x24init_0(make_float3 (0.0f), extinction_2);
    FKSurface _S597 = faced_1;
    FKMedium _S598 = _S596;
    MediumSides _S599 = mediumSides_0(&_S597, &_S598, filling_1, dir_12);
    ShadowContext _S600 = ShadowContext_x24init_0(_S599.behind.extinction, _S599.front.extinction, _S599.fillings, side_n_3, depth_2, lobe_9, true, length_3, width_1);
    ShadowContext context_2;
    if(turned_0)
    {
        uint2  _S601 = _S599.fillings;
        ShadowContext _S602 = ShadowContext_x24init_0(_S599.front.extinction, _S599.behind.extinction, uint2 {_S601.y, _S601.x}, side_n_3, depth_2, lobe_9, true, length_3, width_1);
        context_2 = _S602;
    }
    else
    {
        context_2 = _S600;
    }
    return context_2;
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_5, float3  out_dir_1, float3  n_10, float3  g_n_0, BSDFMaterial material_11, float eta_i_5, float eta_o_5, uint random_state_10)
{
    float3  _S603 = negate_0(in_dir_5);
    bool _S604 = (dot_0(g_n_0, _S603) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S604)
    {
        SampleBSDF _S605 = connectBSDF(in_dir_5, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 0U, random_state_10);
        SampleBSDF _S606 = connectBSDF(in_dir_5, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 2U, random_state_10);
        return _S605.throughput * make_float3 (_S605.pdf) + _S606.throughput * make_float3 (_S606.pdf);
    }
    SampleBSDF _S607 = connectBSDF(in_dir_5, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 1U, random_state_10);
    return _S607.throughput * make_float3 (_S607.pdf);
}

__device__ float3  translucentCorrection(float3  in_dir_6, float3  out_dir_2, float3  n_11, float3  g_n_1, BSDFMaterial material_12, float eta_i_6, float eta_o_6, uint random_state_11)
{
    float _S608 = dot_0(n_11, out_dir_2);
    float3  _S609 = negate_0(in_dir_6);
    bool _S610 = (_S608 * dot_0(n_11, _S609)) < 0.0f;
    SampleBSDF _S611 = connectBSDF(in_dir_6, out_dir_2, n_11, material_12, eta_i_6, eta_o_6, 0U, random_state_11);
    float3  _S612 = negate_0(in_dir_6);
    bool _S613 = (dot_0(g_n_1, _S612) * dot_0(g_n_1, out_dir_2)) > 0.0f;
    float3  _S614 = make_float3 (0.0f);
    float3  _S615 = _S611.throughput * make_float3 (_S611.pdf);
    float _S616 = _slang_select(_S613, -1.0f,1.0f);
    float3  _S617 = _S615 * make_float3 (_S616);
    float3  _S618 = _slang_select(_S610, _S617,_S614);
    return _S618;
}

__device__ float3  translucentBSDF(float3  in_dir_7, float3  out_dir_3, float3  n_12, float3  g_n_2, BSDFMaterial material_13, float eta_i_7, float eta_o_7, uint random_state_12)
{
    float3  _S619 = BSDF(in_dir_7, out_dir_3, n_12, g_n_2, material_13, eta_i_7, eta_o_7, random_state_12);
    float3  _S620 = translucentCorrection(in_dir_7, out_dir_3, n_12, g_n_2, material_13, eta_i_7, eta_o_7, random_state_12);
    return _S619 + _S620;
}

static __device__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_0, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_14, float eta_i_8, float eta_o_8, bool competing_0, uint random_state_13)
{
    bool _S621 = !competing_0;
    bool _S622;
    if(_S621)
    {
        _S622 = true;
    }
    else
    {
        _S622 = (light_0->density) == 0.0f;
    }
    if(_S622)
    {
        bool _S623 = isTranslucent_0(material_14);
        if(_S623)
        {
            float3  _S624 = translucentBSDF(in_dir_8, light_0->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_8, eta_o_8, random_state_13);
            return _S624 * light_0->radiance;
        }
        float3  _S625 = BSDF(in_dir_8, light_0->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_8, eta_o_8, random_state_13);
        return _S625 * light_0->radiance;
    }
    float3  _S626 = light_0->dir;
    bool _S627 = (dot_0(geometry_n_4, - in_dir_8) * dot_0(geometry_n_4, light_0->dir)) <= 0.0f;
    float3  _S628 = neeBSDF(in_dir_8, _S626, smooth_n_5, *material_14, eta_i_8, eta_o_8, _S627, light_0->density, true, random_state_13);
    return _S628 * light_0->radiance * make_float3 (light_0->density);
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S629 = (F32_sqrt((random_1_0)));
    float _S630 = 6.28318548202514648f * random_2_0;
    float _S631 = _S629 * (F32_cos((_S630)));
    float _S632 = _S629 * (F32_sin((_S630)));
    float _S633 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S631 * _S631 - _S632 * _S632))))));
    return make_float3 (_S631, _S633, _S632);
}

static __device__ float3  reflect_0(float3  i_8, float3  n_13)
{
    return i_8 - make_float3 (2.0f * dot_0(n_13, i_8)) * n_13;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_9, float3  n_14, BSDFMaterial material_15, float eta_i_9, float eta_o_9, uint random_init_1, float2  screen_space_0)
{
    uint random_state_14 = random_init_1;
    float3  _S634 = negate_0(in_dir_9);
    float _S635 = dot_0(n_14, _S634);
    float _S636 = sign_0(_S635);
    float3  n_i_4 = n_14 * make_float3 (_S636);
    float _S637 = (F32_abs((_S635)));
    float _S638 = material_15.roughness;
    float _S639 = _S638 * _S638;
    AnisotropicFrame _S640 = anisotropicFrame(material_15, n_i_4);
    float3  _S641 = sampleMaterialHalfVector(_S634, n_i_4, _S639, _S640, &random_state_14);
    BSDFLobes _S642 = bsdfLobes(in_dir_9, _S634, n_i_4, _S641, material_15, eta_i_9, eta_o_9, _S640);
    BSDFLobes lobes_3 = _S642;
    float _S643 = translucentShare(material_15);
    (&lobes_3)->translucent_share = _S643;
    float3  _S644 = make_float3 (1.0f);
    SampleBSDF _S645 = SampleBSDF_x24init_0(_S644, _S644, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S645;
    Random _S646 = pcg(random_state_14);
    random_state_14 = _S646.state;
    bool _S647 = (_S646.value) < ((&lobes_3)->p_diffuse);
    if(_S647)
    {
        Random _S648 = pcg(random_state_14);
        Random _S649 = pcg(_S648.state);
        (&sample_1)->random_state = _S649.state;
        float3  _S650 = sampleCosWeightedHemisphere(_S648.value, _S649.value);
        bool _S651 = (_S646.value) < ((&lobes_3)->p_diffuse * (&lobes_3)->translucent_share);
        float _S652 = _S650.y;
        float _S653 = - _S652;
        float _S654 = _slang_select(_S651, _S653,_S652);
        float3  _S655 = tangentToWorld(make_float3 (_S650.x, _S654, _S650.z), n_i_4);
        (&sample_1)->unit_direction = _S655;
        float3  _S656 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S639, material_15, lobes_3, 0U);
        (&sample_1)->throughput = _S656;
        float _S657 = lobeDensity(_S654, 0.0f, _S637, _S639, lobes_3, eta_i_9, eta_o_9, 0U);
        (&sample_1)->pdf = _S657;
        (&sample_1)->refracted = _S651;
        return sample_1;
    }
    bool _S658 = (_S646.value) < ((&lobes_3)->p_diffuse + (&lobes_3)->p_refract);
    if(_S658)
    {
        (&sample_1)->unit_direction = (&lobes_3)->refracted;
        float _S659 = lobeDensity(0.0f, dot_0((&sample_1)->unit_direction, _S641), _S637, _S639, lobes_3, eta_i_9, eta_o_9, 1U);
        (&sample_1)->pdf = _S659;
        float3  _S660 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S639, material_15, lobes_3, 1U);
        (&sample_1)->throughput = _S660;
        (&sample_1)->random_state = random_state_14;
        (&sample_1)->refracted = true;
        (&sample_1)->lobe = 1U;
        return sample_1;
    }
    float3  _S661 = reflect_0(in_dir_9, _S641);
    float3  _S662 = ((((_S661)) * make_float3(rnorm3df(((_S661)).x, ((_S661)).y, ((_S661)).z))));
    (&sample_1)->unit_direction = _S662;
    float3  _S663 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S639, material_15, lobes_3, 2U);
    (&sample_1)->throughput = _S663;
    (&sample_1)->random_state = random_state_14;
    (&sample_1)->lobe = 2U;
    float _S664 = lobeDensity(0.0f, 0.0f, _S637, _S639, lobes_3, eta_i_9, eta_o_9, 2U);
    (&sample_1)->pdf = _S664;
    return sample_1;
}

__device__ bool withinInverseFootprint(float pdf_6, bool diffuse_0, float prev_cos_0, float distance_4, float threshold_1)
{
    bool _S665 = pdf_6 > 0.0f;
    bool _S666;
    if(_S665)
    {
        if(diffuse_0)
        {
            _S666 = true;
        }
        else
        {
            _S666 = (pdf_6 * prev_cos_0 / (distance_4 * distance_4) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S666 = false;
    }
    return _S666;
}

__device__ bool roughLobe(float pdf_7, bool diffuse_1, float roughness_1)
{
    bool _S667 = pdf_7 > 0.0f;
    bool _S668;
    if(_S667)
    {
        if(diffuse_1)
        {
            _S668 = true;
        }
        else
        {
            _S668 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S668 = false;
    }
    return _S668;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S669 = layers_0 > 1U;
    bool _S670;
    if(_S669)
    {
        _S670 = refracting_0 != passed_0;
    }
    else
    {
        _S670 = false;
    }
    return _S670;
}

static __device__ float widened_0(float spread_0, float pdf_8, bool delta_0)
{
    float _S671 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_8))))), (3.14159274101257324f)));
    bool _S672 = !delta_0;
    float _S673 = _slang_select(_S672, _S671,0.0f);
    return spread_0 + _S673;
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
    bool is_inside_5;
    bool turned_1;
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
    int _S674;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_3;
    float sky_pdf_1;
    float width_4;
    uint b_5;
    float spread_3;
    Shift arrived_end_0;
    float3  _S675 = make_float3 (0.0f);
    Shift _S676 = Shift_x24init_0(_S675, 0.0f);
    uint _S677 = r_3->path;
    uint _S678 = extractBits_0(r_3->path, 0U, 5U);
    uint _S679 = extractBits_0(_S677, 5U, 5U);
    uint _S680 = extractBits_0(_S677, 10U, 2U);
    uint _S681 = extractBits_0(_S677, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S682 = _S681 >= 3U;
        uint _S683 = _slang_select(_S682, 1U,0U);
        uint _S684 = _S678 + _S683;
        uint _S685 = (fcptMaxBounces());
        passes_0 = _S684 > _S685;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S676;
    }
    uint _S686 = _S679 - 1U;
    bool _S687 = _S681 == 3U;
    uint _S688 = _slang_select(_S687, 1U,0U);
    uint _S689 = _S678 + _S688;
    bool _S690 = _S680 == 0U;
    uint _S691 = _slang_select(_S690, _S689,_S686);
    FKHit _S692 = (fcptReservoirHit((*r_3)));
    float3  _S693 = dom_0->x0;
    float3  _S694 = dom_0->x1 - dom_0->x0;
    float3  _S695 = ((((_S694)) * make_float3(rnorm3df(((_S694)).x, ((_S694)).y, ((_S694)).z))));
    FKRay _S696 = Ray_x24init_0(dom_0->x1, _S695);
    FKRay ray_2 = _S696;
    FKHit hit_1 = dom_0->hit;
    float3  scatter_in_0 = _S675;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S675;
    float3  extinction_in_0 = _S675;
    uint filling_2 = 4294967295U;
    float _S697 = dom_0->spread;
    float _S698 = dom_0->width;
    float _S699 = length_0(_S694);
    NEEVertex _S700 = NEEVertex_x24init_0(true, 0.0f, _S675, _S675, _S675);
    NEEVertex nee_vertex_0 = _S700;
    Vertex _S701 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S701;
    Reservoir _S702 = (Reservoir{});
    Reservoir chain_0 = _S702;
    uint _S703 = r_3->seed;
    (&chain_0)->seed = r_3->seed;
    (&ray_2)->origin = _S693;
    (&hit_1)->distance = _S699;
    FKMedium _S704 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_1)->distance), (&filling_2)));
    scatter_in_0 = _S704.scatter;
    extinction_in_0 = _S704.extinction;
    Reservoir _S705 = chain_0;
    uint _S706 = filling_2;
    for(;;)
    {
        bool _S707 = _S706 != 4294967295U;
        float _S708 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        float _S709 = (fcptMajorant((_S706)));
        float _S710 = _slang_select(_S707, _S709,_S708);
        if(replay_1)
        {
            passes_0 = 4294967295U == _S691;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            passes_0 = _S680 == 1U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            passes_0 = _S710 > 0.0f;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            ended_0 = _S676;
            sky_pdf_0 = 0.0f;
            spread_1 = _S697;
            width_2 = _S698;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_4 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S711 = (&prev_0)->rough;
        if(_S711)
        {
            passes_0 = !(_S710 > 0.0f);
        }
        else
        {
            passes_0 = false;
        }
        (&prev_0)->rough = passes_0;
        uint _S712 = stream(_S703, 384U);
        uint tracking_0 = _S712;
        weight_1 = throughput_3;
        glowed_0 = _S675;
        b_4 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        spread_1 = _S697;
        width_2 = _S698;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_1)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S674 = int(1);
                break;
            }
            uint _S713 = b_4 + 320U;
            bool _S714 = b_4 == 4294967295U;
            uint _S715 = _slang_select(_S714, 384U,_S713);
            uint _S716 = stream(_S703, _S715);
            Random _S717 = pcg(_S716);
            float _S718 = freeFlight_0(_S717.value, _S710);
            if(_S707)
            {
                float3  _S719 = (&ray_2)->origin;
                float3  _S720 = (&ray_2)->unit_direction;
                float _S721 = (&hit_1)->distance;
                uint _S722 = _slang_select(_S714, 0U,b_4);
                uint _S723 = (&prev_0)->lobe;
                uint _S724 = _slang_select(_S714, 3U,_S723);
                float _S725 = (fcptTrackMedium((_S706), (_S719), (_S720), (_S721), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S722), (_S724)));
                threshold_2 = _S725;
            }
            else
            {
                threshold_2 = _S718;
            }
            bool _S726 = !(threshold_2 < ((&hit_1)->distance));
            if(_S726)
            {
                _S674 = int(1);
                break;
            }
            if(_S707)
            {
                passes_0 = !replay_1;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                float3  _S727 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S728 = sel_1->glow + _S727;
                sel_1->glow = _S728;
            }
            else
            {
            }
            glowed_0 = _S675;
            uint b_6 = b_4 + 1U;
            float3  _S729 = (&ray_2)->origin + make_float3 (threshold_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S729;
            float3  _S730 = flightWeight_0(scatter_in_0, extinction_in_0, _S710, threshold_2, true);
            float3  _S731 = weight_1;
            float3  _S732 = _slang_select(_S707, _S731,_S730);
            float3  throughput_4 = throughput_2 * _S732;
            uint _S733 = stream(_S703, b_6 + 320U);
            tracking_0 = _S733;
            weight_1 = throughput_3;
            float width_5 = width_2 + spread_1 * threshold_2;
            float _S734 = spread_1 + 3.14159274101257324f;
            uint _S735 = stream(_S703, b_6 + 64U);
            uint2  _S736 = make_uint2 (_S706);
            uint _S737 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            ShadowContext _S738 = ShadowContext_x24init_0(extinction_in_0, extinction_in_0, _S736, (&ray_2)->unit_direction, b_6, _S737, false, threshold_2, width_5);
            TreeSample _S739 = sampleLightTree_0((&ray_2)->origin, (&ray_2)->unit_direction, (&ray_2)->unit_direction, 0.0f, true, _S735, &_S738);
            bool _S740 = scatterSampled_0(replay_1, b_6, _S691, _S707);
            uint _S741 = (fcptMaxBounces());
            bool _S742 = b_6 < _S741;
            if(_S742)
            {
                is_inside_5 = (_S739.density) > 0.0f;
            }
            else
            {
                is_inside_5 = false;
            }
            float _S743 = _slang_select(is_inside_5, 0.07957746833562851f,0.0f);
            float3  _S744 = throughput_4 * _S739.radiance;
            float _S745 = powerHeuristic(_S739.density, _S743);
            float3  _S746 = _S744 * make_float3 (0.07957746833562851f * _S745);
            float3  _S747 = _slang_select(_S740, _S746,_S675);
            if(replay_1)
            {
                turned_1 = b_6 == _S691;
            }
            else
            {
                turned_1 = false;
            }
            if(turned_1)
            {
                bool _S748 = _S680 == 2U;
                if(_S748)
                {
                    float _S749 = rgb_to_greyscale(_S747);
                    passes_0 = _S749 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S750 = Shift_x24init_0(_S747, 1.0f);
                    _S674 = int(0);
                    ended_0 = _S750;
                    threshold_2 = _S734;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                _S674 = int(0);
                ended_0 = _S676;
                threshold_2 = _S734;
                geometry_density_2 = width_5;
                chain_throughput_0 = throughput_4;
                layer_0 = b_6;
                break;
            }
            bool _S751 = !replay_1;
            if(_S751)
            {
                Reservoir candidate_2 = _S705;
                uint _S752 = extractBits_0(_S705.path, 10U, 2U);
                bool _S753 = _S752 == 1U;
                if(_S753)
                {
                    float3  _S754 = safeDivide(_S747, _S675);
                    (&candidate_2)->radiance = _S754;
                }
                else
                {
                    uint _S755 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                    uint _S756 = insertBits_0(_S755, 2U, 10U, 2U);
                    (&candidate_2)->path = _S756;
                }
                Reservoir _S757 = withEnd(candidate_2, 0U, b_6, _S747);
                offer(sel_1, _S757, _S747 * make_float3 (scale_1) / make_float3 (density_2));
                float _S758 = survivalProbability(throughput_4, density_2);
                uint _S759 = stream(_S703, b_6 + 128U);
                Random _S760 = pcg(_S759);
                bool _S761 = _S758 < (_S760.value);
                if(_S761)
                {
                    scatter_2 = true;
                }
                else
                {
                    uint _S762 = (fcptMaxBounces());
                    scatter_2 = b_6 >= _S762;
                }
                if(scatter_2)
                {
                    _S674 = int(0);
                    ended_0 = _S676;
                    threshold_2 = _S734;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                float _S763 = density_2 * _S758;
                density_2 = _S763;
            }
            else
            {
            }
            NEEVertex _S764 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_2)->origin, _S675, (&ray_2)->origin);
            nee_vertex_0 = _S764;
            uint _S765 = stream(_S703, b_6);
            float3  _S766 = isotropic_0(_S765);
            (&ray_2)->unit_direction = _S766;
            Vertex _S767 = scatteredVertex_0(false);
            prev_0 = _S767;
            float _S768 = (&prev_0)->pdf;
            FKHit _S769 = (fcptTraverseInstanceBVH((ray_2), (true), (4.294967296e+09f), (false)));
            hit_1 = _S769;
            b_4 = b_6;
            throughput_2 = throughput_4;
            spread_1 = _S734;
            width_2 = width_5;
            sky_pdf_0 = _S768;
        }
        if(_S674 != int(1))
        {
            spread_1 = threshold_2;
            width_2 = geometry_density_2;
            throughput_2 = chain_throughput_0;
            b_4 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S676;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    Reservoir _S770 = chain_0;
    NEEVertex _S771 = nee_vertex_0;
    Vertex _S772 = prev_0;
    FKHit _S773 = hit_1;
    uint _S774 = filling_2;
    float3  _S775 = scatter_in_0;
    float3  _S776 = extinction_in_0;
    float3  _S777 = weight_1;
    float3  _S778 = glowed_0;
    for(;;)
    {
        bool _S779 = (_S773.instance_index) == 4294967295U;
        if(_S779)
        {
            bool _S780 = !_S771.none;
            float _S781 = _slang_select(_S780, sky_pdf_0,0.0f);
            float _S782 = escapeWeight_0(_S781, (&ray_2)->unit_direction);
            float3  _S783 = environment_0((&ray_2)->unit_direction, b_4, _S772.lobe);
            float3  _S784 = throughput_2 * _S783;
            if(replay_1)
            {
                bool _S785 = b_4 == _S691;
                if(_S785)
                {
                    passes_0 = _S680 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S786 = Shift_x24init_0(_S784 * make_float3 (_S782) / make_float3 (r_3->jac), density_2 / r_3->jac);
                    ended_0 = _S786;
                    passes_0 = true;
                    break;
                }
                if(_S690)
                {
                    passes_0 = _S687;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_4 == _S678;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S772.rough;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S787 = Shift_x24init_0(_S784 * make_float3 (_S782), 1.0f);
                    ended_0 = _S787;
                    passes_0 = true;
                    break;
                }
                ended_0 = _S676;
                passes_0 = true;
                break;
            }
            Reservoir candidate_3 = _S770;
            uint _S788 = extractBits_0(_S770.path, 10U, 2U);
            bool _S789 = _S788 == 1U;
            if(_S789)
            {
                uint _S790 = extractBits_0(_S770.path, 5U, 5U);
                bool _S791 = _S790 == b_4;
                float _S792 = _slang_select(_S791, 1.0f,_S782);
                float3  _S793 = safeDivide(_S784 * make_float3 (_S792), _S675);
                (&candidate_3)->radiance = _S793;
            }
            else
            {
                if(_S772.rough)
                {
                    uint _S794 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                    uint _S795 = insertBits_0(_S794, 3U, 10U, 2U);
                    uint _S796 = insertBits_0(_S795, _S772.lobe, 15U, 2U);
                    uint _S797 = _slang_select(_S772.inside, 1U,0U);
                    uint _S798 = insertBits_0(_S796, _S797, 20U, 1U);
                    (&candidate_3)->path = _S798;
                    (&candidate_3)->jac = _S772.pdf;
                    (&candidate_3)->dir = (&ray_2)->unit_direction;
                }
                else
                {
                }
            }
            float3  _S799 = _S784 * make_float3 (_S782);
            Reservoir _S800 = withEnd(candidate_3, 3U, b_4, _S799);
            offer(sel_1, _S800, _S799 * make_float3 (scale_1) / make_float3 (density_2));
            ended_0 = _S676;
            passes_0 = true;
            break;
        }
        float3  _S801 = (&ray_2)->origin + make_float3 (_S773.distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S801;
        bool _S802 = _S774 != 4294967295U;
        if(_S802)
        {
            bool _S803 = !replay_1;
            if(_S803)
            {
                float3  _S804 = throughput_2 * _S778 / make_float3 (density_2);
                float3  _S805 = sel_1->glow + _S804;
                sel_1->glow = _S805;
            }
            else
            {
            }
            float3  _S806 = throughput_2 * _S777;
            throughput_2 = _S806;
        }
        else
        {
            float3  _S807 = flightWeight_0(_S775, _S776, (_S775.x + _S775.y + _S775.z) / 3.0f, _S773.distance, false);
            float3  _S808 = throughput_2 * _S807;
            throughput_2 = _S808;
        }
        float _S809 = width_2 + spread_1 * _S773.distance;
        ended_0 = _S676;
        width_2 = _S809;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    uint _S810 = b_4 + 1U;
    b_4 = _S810;
    layer_0 = 0U;
    passes_0 = false;
    is_inside_5 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    chain_throughput_0 = _S675;
    float3  reconnection_0 = _S675;
    for(;;)
    {
        bool _S811 = ((&hit_1)->is_point_light) == 1U;
        FKMedium _S812 = Medium_x24init_0(_S675, _S675);
        BSDFMaterial _S813 = Material_x24init_0(_S675, _S675, 0.0f, 0.0f, 0.0f, 0.0f, _S675, throughput_3, 1.0f, _S675, _S675, 0.5f, 0.0f, 0.0f, _S675);
        FKMedium _S814 = _S812;
        FKSurface _S815 = Surface_x24init_0(_S675, _S675, 0.0f, &_S813, false, 0U, 1.0f, false, &_S814, 4294967295U);
        bool _S816 = !_S811;
        bool is_inside_6;
        float3  front_n_0;
        float3  throughput_5;
        FKSurface surface_10;
        if(_S816)
        {
            uint _S817 = stream(_S703, b_4);
            uint _S818 = arrivalLobe_0(b_4, (&prev_0)->lobe);
            FKSurface _S819 = (fcptSurfaceAtPath((hit_1), ((&ray_2)->origin), (_S817), (width_2), (layer_0), (b_4), (_S818), ((&ray_2)->unit_direction)));
            bool _S820 = !passes_0;
            FKSurface _S821 = _S819;
            FKSurface _S822 = emitting_0(&_S821, _S820);
            uint _S823 = stream(_S703, b_4 + 256U);
            Random _S824 = pcg(_S823);
            FKSurface _S825 = _S822;
            FKSurface _S826 = uncovered_0(&_S825, _S824.value);
            float _S827 = facingSign(_S826.material.transmission, _S826.geometry_n, (&ray_2)->unit_direction);
            bool _S828 = _S827 < 0.0f;
            FKSurface _S829 = _S826;
            FKSurface _S830 = facingRay_0(&_S829, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S831 = arrivesBehind_0((&ray_2)->unit_direction, _S830.geometry_n);
                scatter_2 = _S831;
            }
            else
            {
                scatter_2 = is_inside_5;
            }
            if(scatter_2)
            {
                float3  _S832 = beerLambert((&hit_1)->distance, _S830.material.absorption);
                float3  _S833 = throughput_2 * _S832;
                front_n_0 = _S833;
            }
            else
            {
                front_n_0 = throughput_2;
            }
            bool _S834 = !_S830.skip;
            float geometry_density_3 = geometryDensity(_S830.geometry_n, (&ray_2)->unit_direction, (&hit_1)->distance);
            bool _S835 = b_4 == _S810;
            if(_S835)
            {
                float _S836 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S836;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            bool _S837 = scatter_2;
            float3  _S838 = front_n_0;
            float _S839 = geometry_density_2;
            scatter_2 = _S834;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S839;
            surface_10 = _S830;
            front_n_0 = _S826.smooth_n;
            throughput_5 = _S838;
            turned_1 = _S828;
            is_inside_6 = _S837;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_10 = _S815;
            front_n_0 = _S675;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S840 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S841 = surface_10;
        FKSurface _S842 = surface_10;
        float _S843 = dot_0(surface_10.smooth_n, - (&ray_2)->unit_direction);
        BSDFMaterial _S844 = _S841.material;
        float2  _S845 = vertexEta_0(&_S844, _S843);
        bool _S846;
        if(scatter_2)
        {
            bool _S847 = samplesLights(_S841.material);
            _S846 = _S847;
        }
        else
        {
            _S846 = false;
        }
        bool _S848;
        if(passes_0)
        {
            _S848 = true;
        }
        else
        {
            _S848 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S848)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S846;
        }
        float3  _S849 = sideNormal(surface_10, (&ray_2)->unit_direction);
        float _S850 = sign_0(dot_0(- (&ray_2)->unit_direction, front_n_0));
        float3  _S851 = _S841.material.emissive * make_float3 ((F32_max((_S850), (0.0f))));
        float3  emission_0;
        if(_S811)
        {
            float3  _S852 = (fcptCalculatePointLightContrib(((&hit_1)->instance_index)));
            emission_0 = _S852;
        }
        else
        {
            emission_0 = _S851;
        }
        float _S853 = rgb_to_greyscale(emission_0);
        bool _S854 = _S853 > 0.0f;
        float3  emission_1;
        if(_S854)
        {
            NEEVertex _S855 = nee_vertex_0;
            FKHit _S856 = hit_1;
            float _S857 = emissionWeight_0(&_S855, &_S856, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S857);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S858;
        if(replay_1)
        {
            _S858 = _S680 == 1U;
        }
        else
        {
            _S858 = false;
        }
        bool _S859;
        if(_S858)
        {
            _S859 = b_4 > _S679;
        }
        else
        {
            _S859 = false;
        }
        bool _S860;
        if(_S859)
        {
            _S860 = b_4 == _S678;
        }
        else
        {
            _S860 = false;
        }
        bool _S861;
        if(_S860)
        {
            bool _S862 = _S681 == 1U;
            if(_S862)
            {
                _S861 = true;
            }
            else
            {
                _S861 = _S681 == 2U;
            }
        }
        else
        {
            _S861 = false;
        }
        if(_S861)
        {
            bool _S863 = _S811 != (_S681 == 2U);
            if(_S863)
            {
                return _S676;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_3->jac), density_2 / r_3->jac);
        }
        uint _S864 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S865 = _S864 == 1U;
        Reservoir here_0 = chain_0;
        uint _S866 = insertBits_0(0U, b_4, 5U, 5U);
        uint _S867 = insertBits_0(_S866, 1U, 10U, 2U);
        uint _S868 = insertBits_0(_S867, (&prev_0)->lobe, 15U, 2U);
        bool _S869 = (&prev_0)->inside;
        uint _S870 = _slang_select(_S869, 1U,0U);
        uint _S871 = insertBits_0(_S868, _S870, 20U, 1U);
        (&here_0)->path = _S871;
        float _S872 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S872;
        fcptWithReservoirHit((&here_0), (&hit_1));
        bool _S873;
        if(replay_1)
        {
            _S873 = _S680 == 1U;
        }
        else
        {
            _S873 = false;
        }
        bool _S874;
        if(_S873)
        {
            _S874 = b_4 == _S679;
        }
        else
        {
            _S874 = false;
        }
        bool _S875;
        bool wrong_side_0;
        bool refracted_4;
        bool _S876;
        bool _S877;
        float3  throughput_6;
        float density_4;
        if(_S874)
        {
            bool _S878 = ((&hit_1)->instance_index) != (_S692.instance_index);
            if(_S878)
            {
                _S875 = true;
            }
            else
            {
                _S875 = ((&hit_1)->triangle_index) != (_S692.triangle_index);
            }
            if(_S875)
            {
                wrong_side_0 = true;
            }
            else
            {
                wrong_side_0 = !_S840;
            }
            if(wrong_side_0)
            {
                return _S676;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            bool _S879 = _S679 == _S678;
            if(_S879)
            {
                refracted_4 = _S681 == 1U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            if(_S879)
            {
                _S876 = _S681 == 0U;
            }
            else
            {
                _S876 = false;
            }
            if(_S876)
            {
                BSDFMaterial _S880 = _S841.material;
                bool _S881 = isTranslucent_0(&_S880);
                uint _S882 = stream(_S703, b_4 + 64U);
                uint _S883 = arrivalLobe_0(b_4, (&prev_0)->lobe);
                FKSurface _S884 = surface_10;
                ShadowContext _S885 = shadowContext_0(&_S884, turned_1, _S849, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_4, _S883, (&hit_1)->distance, width_2);
                ShadowContext _S886 = _S885;
                TreeSample _S887 = sampleLightTree_0((&ray_2)->origin, _S842.smooth_n, surface_10.geometry_n, surface_10.geometry_offset, _S881, _S882, &_S886);
                bool _S888 = !nee_0;
                if(_S888)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S889 = rgb_to_greyscale(_S887.radiance);
                    passes_0 = !(_S889 > 0.0f);
                }
                if(passes_0)
                {
                    return _S676;
                }
                float _S890 = _S845.x;
                float _S891 = _S845.y;
                uint _S892 = (fcptMaxBounces());
                bool _S893 = b_4 < _S892;
                TreeSample _S894 = _S887;
                BSDFMaterial _S895 = _S841.material;
                float3  _S896 = lightBSDF_0((&ray_2)->unit_direction, &_S894, _S842.smooth_n, _S849, &_S895, _S890, _S891, _S893, surface_10.random_state);
                return Shift_x24init_0(throughput_7 * _S896 / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            if(_S879)
            {
                _S877 = _S681 == 4U;
            }
            else
            {
                _S877 = false;
            }
            if(_S877)
            {
                bool _S897 = !nee_0;
                if(_S897)
                {
                    return _S676;
                }
                float _S898 = environmentPdf_0(r_3->dir);
                float3  _S899 = skyBSDF((&ray_2)->unit_direction, r_3->dir, surface_10, _S849, _S845, is_inside_6, _S898, surface_10.random_state);
                return Shift_x24init_0(throughput_7 * _S899 * r_3->radiance / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            uint _S900 = extractBits_0(_S677, 19U, 1U);
            bool _S901 = nee_0 != (_S900 == 1U);
            if(_S901)
            {
                return _S676;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                _S875 = b_4 == _S691;
            }
            else
            {
                _S875 = false;
            }
            if(_S875)
            {
                bool _S902 = !scatter_2;
                if(_S902)
                {
                    wrong_side_0 = true;
                }
                else
                {
                    bool _S903 = _S680 != 1U;
                    if(_S903)
                    {
                        wrong_side_0 = _S680 != 3U;
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
                bool _S904 = _S680 == 2U;
                if(_S904)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S840;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S681 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    uint _S905 = stream(_S703, b_4 + 448U);
                    FKRay _S906 = ray_2;
                    FKSurface _S907 = surface_10;
                    SkySample _S908 = sampleSky_0(&_S906, &_S907, _S849, _S845, is_inside_6, _S905, surface_10.random_state);
                    return Shift_x24init_0(throughput_5 * _S908.color, 1.0f);
                }
                if(_S904)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S840;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    BSDFMaterial _S909 = _S841.material;
                    bool _S910 = isTranslucent_0(&_S909);
                    uint _S911 = stream(_S703, b_4 + 64U);
                    uint _S912 = arrivalLobe_0(b_4, (&prev_0)->lobe);
                    FKSurface _S913 = surface_10;
                    ShadowContext _S914 = shadowContext_0(&_S913, turned_1, _S849, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_4, _S912, (&hit_1)->distance, width_2);
                    ShadowContext _S915 = _S914;
                    TreeSample _S916 = sampleLightTree_0((&ray_2)->origin, _S842.smooth_n, surface_10.geometry_n, surface_10.geometry_offset, _S910, _S911, &_S915);
                    float _S917 = rgb_to_greyscale(_S916.radiance);
                    bool _S918 = !(_S917 > 0.0f);
                    if(_S918)
                    {
                        return _S676;
                    }
                    float _S919 = _S845.x;
                    float _S920 = _S845.y;
                    uint _S921 = (fcptMaxBounces());
                    bool _S922 = b_4 < _S921;
                    TreeSample _S923 = _S916;
                    BSDFMaterial _S924 = _S841.material;
                    float3  _S925 = lightBSDF_0((&ray_2)->unit_direction, &_S923, _S842.smooth_n, _S849, &_S924, _S919, _S920, _S922, surface_10.random_state);
                    return Shift_x24init_0(throughput_5 * _S925, 1.0f);
                }
                if(_S690)
                {
                    passes_0 = _S681 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S811;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S690)
                {
                    passes_0 = _S681 == 1U;
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
                    passes_0 = !_S840;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S676;
            }
            else
            {
                bool _S926 = !replay_1;
                if(_S926)
                {
                    refracted_4 = scatter_2;
                }
                else
                {
                    refracted_4 = false;
                }
                if(refracted_4)
                {
                    bool _S927 = b_4 > 0U;
                    if(_S927)
                    {
                        Reservoir candidate_4 = chain_0;
                        if(_S865)
                        {
                            float3  _S928 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_4)->radiance = _S928;
                        }
                        else
                        {
                            if(_S840)
                            {
                                candidate_4 = here_0;
                            }
                        }
                        float3  _S929 = throughput_5 * emission_1;
                        Reservoir _S930 = withEnd(candidate_4, 1U, b_4, _S929);
                        offer(sel_1, _S930, _S929 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S931 = throughput_5 * emission_1;
                        float3  _S932 = sel_1->glow + _S931;
                        sel_1->glow = _S932;
                    }
                    if(nee_0)
                    {
                        BSDFMaterial _S933 = _S841.material;
                        bool _S934 = isTranslucent_0(&_S933);
                        uint _S935 = stream(_S703, b_4 + 64U);
                        uint _S936 = arrivalLobe_0(b_4, (&prev_0)->lobe);
                        FKSurface _S937 = surface_10;
                        ShadowContext _S938 = shadowContext_0(&_S937, turned_1, _S849, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_4, _S936, (&hit_1)->distance, width_2);
                        ShadowContext _S939 = _S938;
                        TreeSample _S940 = sampleLightTree_0((&ray_2)->origin, _S842.smooth_n, surface_10.geometry_n, surface_10.geometry_offset, _S934, _S935, &_S939);
                        float _S941 = _S845.x;
                        float _S942 = _S845.y;
                        uint _S943 = (fcptMaxBounces());
                        bool _S944 = b_4 < _S943;
                        TreeSample _S945 = _S940;
                        BSDFMaterial _S946 = _S841.material;
                        float3  _S947 = lightBSDF_0((&ray_2)->unit_direction, &_S945, _S842.smooth_n, _S849, &_S946, _S941, _S942, _S944, surface_10.random_state);
                        float3  _S948 = throughput_5 * _S947;
                        Reservoir candidate_5 = chain_0;
                        if(_S865)
                        {
                            float3  _S949 = safeDivide(_S948, chain_throughput_0);
                            (&candidate_5)->radiance = _S949;
                        }
                        else
                        {
                            if(_S840)
                            {
                                candidate_5 = here_0;
                                uint _S950 = insertBits_0((&candidate_5)->path, 1U, 19U, 1U);
                                (&candidate_5)->path = _S950;
                                (&candidate_5)->dir = _S940.dir;
                                (&candidate_5)->radiance = _S940.radiance;
                            }
                            else
                            {
                                uint _S951 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S952 = insertBits_0(_S951, 2U, 10U, 2U);
                                (&candidate_5)->path = _S952;
                            }
                        }
                        Reservoir _S953 = withEnd(candidate_5, 0U, b_4, _S948);
                        offer(sel_1, _S953, _S948 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        bool _S954 = environmentMapped_0();
                        _S876 = _S954;
                    }
                    else
                    {
                        _S876 = false;
                    }
                    if(_S876)
                    {
                        uint _S955 = (fcptMaxBounces());
                        _S877 = b_4 < _S955;
                    }
                    else
                    {
                        _S877 = false;
                    }
                    if(_S877)
                    {
                        uint _S956 = stream(_S703, b_4 + 448U);
                        FKRay _S957 = ray_2;
                        FKSurface _S958 = surface_10;
                        SkySample _S959 = sampleSky_0(&_S957, &_S958, _S849, _S845, is_inside_6, _S956, surface_10.random_state);
                        float3  _S960 = throughput_5 * _S959.color;
                        Reservoir candidate_6 = chain_0;
                        if(_S865)
                        {
                            float3  _S961 = safeDivide(_S960, chain_throughput_0);
                            (&candidate_6)->radiance = _S961;
                        }
                        else
                        {
                            if(_S840)
                            {
                                candidate_6 = here_0;
                                uint _S962 = insertBits_0((&candidate_6)->path, 1U, 19U, 1U);
                                (&candidate_6)->path = _S962;
                                (&candidate_6)->dir = _S959.dir;
                                (&candidate_6)->radiance = _S959.radiance;
                            }
                            else
                            {
                                uint _S963 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S964 = insertBits_0(_S963, 2U, 10U, 2U);
                                (&candidate_6)->path = _S964;
                            }
                        }
                        Reservoir _S965 = withEnd(candidate_6, 4U, b_4, _S960);
                        offer(sel_1, _S965, _S960 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S966;
        bool _S967;
        bool _S968;
        bool _S969;
        bool _S970;
        bool _S971;
        bool _S972;
        bool _S973;
        bool _S974;
        bool _S975;
        bool _S976;
        bool _S977;
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
                _S875 = b_4 == _S691;
            }
            else
            {
                _S875 = false;
            }
            uint _S978 = extractBits_0(_S677, 15U, 2U);
            uint _S979 = extractBits_0(_S677, 17U, 2U);
            uint _S980 = _slang_select(_S874, _S979,_S978);
            float3  _S981 = r_3->dir;
            bool refracted_5 = _S980 == 1U;
            SampleBSDF _S982 = SampleBSDF_x24init_0(_S675, _S675, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_10 = _S982;
            float3  reconnection_1;
            if(_S875)
            {
                uint _S983 = extractBits_0(_S677, 20U, 1U);
                bool _S984 = is_inside_6 != (_S983 == 1U);
                if(_S984)
                {
                    return _S676;
                }
                bool _S985 = _S680 == 1U;
                if(_S985)
                {
                    float3  _S986 = (fcptHitPosition((_S692)));
                    throughput_8 = _S986;
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
                    BSDFMaterial _S987 = _S841.material;
                    bool _S988 = isTranslucent_0(&_S987);
                    if(_S988)
                    {
                        wrong_side_0 = _S980 == 0U;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        float3  _S989 = throughput_8 - (&ray_2)->origin;
                        float3  _S990 = _slang_select(_S985, _S989,_S981);
                        refracted_4 = (dot_0(_S842.smooth_n, _S990) * _S843) < 0.0f;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                }
                if(_S985)
                {
                    float3  _S991 = (&ray_2)->origin;
                    FKSurface _S992 = surface_10;
                    float3  _S993 = - _S842.smooth_n;
                    bool _S994 = is_inside_6 != refracted_4;
                    float3  _S995 = _slang_select(_S994, _S993,_S842.smooth_n);
                    float3  _S996 = throughput_8 - (_S991 + make_float3 (_S992.geometry_offset) * _S995);
                    float3  _S997 = ((((_S996)) * make_float3(rnorm3df(((_S996)).x, ((_S996)).y, ((_S996)).z))));
                    reconnection_1 = _S997;
                }
                else
                {
                    reconnection_1 = _S981;
                }
                bool _S998 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, _S849);
                if(_S998)
                {
                    return _S676;
                }
                float3  _S999 = throughput_8;
                throughput_8 = reconnection_1;
                b_7 = _S980;
                wrong_side_0 = false;
                reconnection_1 = _S999;
            }
            else
            {
                bool _S1000 = !_S874;
                if(_S1000)
                {
                    float _S1001 = _S845.x;
                    float _S1002 = _S845.y;
                    float2  _S1003 = make_float2 (0.0f);
                    SampleBSDF _S1004 = sampleBSDF((&ray_2)->unit_direction, _S842.smooth_n, _S841.material, _S1001, _S1002, surface_10.random_state, _S1003);
                    SampleBSDF bsdf_sampled_0 = _S1004;
                    bool wrong_side_1 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, _S849);
                    if(wrong_side_1)
                    {
                        wrong_side_0 = (_S841.material.transmission) > 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        SampleBSDF _S1005 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_10.geometry_n, _S841.material, _S1001, _S1002, (&bsdf_sampled_0)->random_state, _S1003);
                        (&bsdf_sampled_0)->unit_direction = _S1005.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1005.refracted;
                        (&bsdf_sampled_0)->throughput = _S1005.throughput;
                    }
                    else
                    {
                        if(wrong_side_1)
                        {
                            float3  _S1006 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_10.geometry_n)) * surface_10.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1006;
                        }
                    }
                    uint _S1007 = (&bsdf_sampled_0)->lobe;
                    float3  _S1008 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1009 = (&bsdf_sampled_0)->refracted;
                    lobe_10 = bsdf_sampled_0;
                    float _S1010 = (&bsdf_sampled_0)->pdf;
                    float _S1011 = _slang_select(wrong_side_1, 0.0f,_S1010);
                    (&lobe_10)->pdf = _S1011;
                    throughput_8 = _S1008;
                    b_7 = _S1007;
                    wrong_side_0 = wrong_side_1;
                    refracted_4 = _S1009;
                }
                else
                {
                    throughput_8 = _S981;
                    b_7 = _S980;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(_S875)
            {
                _S876 = true;
            }
            else
            {
                _S876 = _S874;
            }
            if(_S876)
            {
                SampleBSDF _S1012 = connectBSDF((&ray_2)->unit_direction, throughput_8, _S842.smooth_n, _S841.material, _S845.x, _S845.y, b_7, surface_10.random_state);
                lobe_10 = _S1012;
            }
            bool _S1013 = b_7 != 0U;
            if(_S1013)
            {
                bool _S1014 = (_S841.material.roughness) == 0.0f;
                if(_S1014)
                {
                    _S877 = true;
                }
                else
                {
                    bool _S1015 = b_7 == 1U;
                    if(_S1015)
                    {
                        _S877 = (_S845.x) == (_S845.y);
                    }
                    else
                    {
                        _S877 = false;
                    }
                }
            }
            else
            {
                _S877 = false;
            }
            BSDFMaterial _S1016 = _S841.material;
            bool _S1017 = isTranslucent_0(&_S1016);
            if(_S1017)
            {
                _S966 = b_7 == 0U;
            }
            else
            {
                _S966 = false;
            }
            if(_S966)
            {
                _S967 = (dot_0(throughput_8, surface_10.geometry_n)) < 0.0f;
            }
            else
            {
                _S967 = false;
            }
            if(nee_0)
            {
                _S968 = !_S877;
            }
            else
            {
                _S968 = false;
            }
            if(_S968)
            {
                _S969 = !wrong_side_0;
            }
            else
            {
                _S969 = false;
            }
            if(_S969)
            {
                float _S1018 = (&lobe_10)->pdf;
                float3  _S1019 = (&ray_2)->origin;
                BSDFMaterial _S1020 = _S841.material;
                bool _S1021 = isTranslucent_0(&_S1020);
                float3  _S1022 = _slang_select(_S1021, _S675,_S842.smooth_n);
                float3  _S1023 = (&ray_2)->origin;
                FKSurface _S1024 = surface_10;
                float3  _S1025 = - _S842.smooth_n;
                float3  _S1026 = _slang_select(_S967, _S1025,_S842.smooth_n);
                NEEVertex _S1027 = NEEVertex_x24init_0(false, _S1018, _S1019, _S1022, _S1023 + make_float3 (_S1024.geometry_offset) * _S1026);
                nee_vertex_0 = _S1027;
            }
            else
            {
                bool _S1028 = b_7 != 1U;
                if(_S1028)
                {
                    _S970 = true;
                }
                else
                {
                    _S970 = (_S845.x) != (_S845.y);
                }
                if(_S970)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1029 = b_7 == 0U;
            bool _S1030 = withinInverseFootprint((&lobe_10)->pdf, _S1029, (&prev_0)->cos, (&hit_1)->distance, threshold_2);
            FKSurface _S1031 = surface_10;
            bool _S1032 = (dot_0(throughput_8, _S842.smooth_n) * dot_0(throughput_8, surface_10.geometry_n)) < 0.0f;
            bool _S1033 = !_S1032;
            if(_S1033)
            {
                bool _S1034 = roughLobe((&lobe_10)->pdf, _S1029, _S841.material.roughness);
                _S970 = _S1034;
            }
            else
            {
                _S970 = false;
            }
            if(_S874)
            {
                bool _S1035 = !_S1030;
                if(_S1035)
                {
                    return _S676;
                }
                bool _S1036 = _S681 != 1U;
                if(_S1036)
                {
                    _S971 = _S681 != 2U;
                }
                else
                {
                    _S971 = false;
                }
                if(_S971)
                {
                    float _S1037 = (&lobe_10)->pdf;
                    float _S1038 = _slang_select(nee_0, _S1037,0.0f);
                    float _S1039 = escapeWeight_0(_S1038, _S981);
                    bool _S1040 = _S679 == _S678;
                    if(_S1040)
                    {
                        passes_0 = _S687;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1041 = _slang_select(passes_0, _S1039,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_10)->throughput * make_float3 ((&lobe_10)->pdf)) * r_3->radiance * make_float3 (_S1041) / make_float3 (r_3->jac), density_4 * (&lobe_10)->pdf / r_3->jac);
                }
                float3  _S1042 = throughput_6 * make_float3 ((&lobe_10)->pdf);
                float _S1043 = density_4 * (&lobe_10)->pdf;
                throughput_9 = _S1042;
                density_6 = _S1043;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1044 = (fcptLayers((hit_1)));
            bool _S1045 = b_7 == 1U;
            bool _S1046 = passesLayer_0(_S1044, _S1045, passes_0);
            if(_S875)
            {
                _S971 = _S1046;
            }
            else
            {
                _S971 = false;
            }
            if(_S971)
            {
                return _S676;
            }
            if(replay_1)
            {
                _S972 = b_4 <= _S691;
            }
            else
            {
                _S972 = false;
            }
            if(_S972)
            {
                _S973 = _S840;
            }
            else
            {
                _S973 = false;
            }
            if(_S973)
            {
                _S974 = _S1030;
            }
            else
            {
                _S974 = false;
            }
            if(_S974)
            {
                _S975 = true;
            }
            else
            {
                if(_S875)
                {
                    _S975 = !_S970;
                }
                else
                {
                    _S975 = false;
                }
            }
            if(_S975)
            {
                return _S676;
            }
            if(_S875)
            {
                float3  _S1047 = throughput_9 * ((&lobe_10)->throughput * make_float3 ((&lobe_10)->pdf));
                float _S1048 = (&lobe_10)->pdf;
                throughput_10 = _S1047;
                sky_pdf_2 = _S1048;
            }
            else
            {
                float3  _S1049 = throughput_9 * max_0((&lobe_10)->throughput, _S675);
                throughput_10 = _S1049;
                sky_pdf_2 = density_6;
            }
            bool _S1050 = !replay_1;
            if(_S1050)
            {
                _S976 = !_S865;
            }
            else
            {
                _S976 = false;
            }
            if(_S976)
            {
                _S977 = _S840;
            }
            else
            {
                _S977 = false;
            }
            bool _S1051;
            if(_S977)
            {
                _S1051 = _S1030;
            }
            else
            {
                _S1051 = false;
            }
            float3  chain_throughput_1;
            if(_S1051)
            {
                chain_0 = here_0;
                uint _S1052 = insertBits_0((&chain_0)->path, b_7, 17U, 2U);
                uint _S1053 = _slang_select(nee_0, 1U,0U);
                uint _S1054 = insertBits_0(_S1052, _S1053, 19U, 1U);
                (&chain_0)->path = _S1054;
                float _S1055 = (&chain_0)->jac * (&lobe_10)->pdf;
                (&chain_0)->jac = _S1055;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            Vertex _S1056 = Vertex_x24init_0(_S970, b_7, (&lobe_10)->pdf, (F32_abs((dot_0(_S1031.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1056;
            float _S1057 = (&lobe_10)->pdf;
            bool _S1058;
            if(_S1045)
            {
                _S1058 = (_S845.x) == (_S845.y);
            }
            else
            {
                _S1058 = false;
            }
            float _S1059 = _slang_select(_S1058, sky_pdf_0,_S1057);
            float _S1060 = widened_0(spread_1, (&lobe_10)->pdf, _S877);
            bool _S1061;
            if(refracted_4)
            {
                _S1061 = !_S967;
            }
            else
            {
                _S1061 = false;
            }
            bool is_inside_7;
            if(_S1061)
            {
                bool _S1062 = !is_inside_6;
                is_inside_7 = _S1062;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            bool _S1063 = !_S1046;
            if(_S1063)
            {
                FKSurface faced_2 = surface_10;
                float3  _S1064 = - _S1031.geometry_n;
                float3  _S1065 = _slang_select(turned_1, _S1064,_S1031.geometry_n);
                (&faced_2)->geometry_n = _S1065;
                FKMedium _S1066 = Medium_x24init_0(scatter_in_0, extinction_in_0);
                FKSurface _S1067 = faced_2;
                FKMedium _S1068 = _S1066;
                MediumSides _S1069 = mediumSides_0(&_S1067, &_S1068, filling_2, (&ray_2)->unit_direction);
                bool _S1070 = leavesInFront_0((&faced_2)->geometry_n, throughput_8, _S849, _S1031.geometry_n);
                float3  _S1071 = _slang_select(_S1070, _S1069.front.scatter,_S1069.behind.scatter);
                scatter_in_0 = _S1071;
                float3  _S1072 = _slang_select(_S1070, _S1069.front.extinction,_S1069.behind.extinction);
                extinction_in_0 = _S1072;
                uint _S1073 = _S1069.fillings.x;
                uint _S1074 = _S1069.fillings.y;
                uint _S1075 = _slang_select(_S1070, _S1074,_S1073);
                filling_2 = _S1075;
            }
            (&ray_2)->unit_direction = throughput_8;
            if(_S1063)
            {
                FKSurface _S1076 = surface_10;
                float3  _S1077 = - _S842.smooth_n;
                bool _S1078 = is_inside_7 != _S967;
                float3  _S1079 = _slang_select(_S1078, _S1077,_S842.smooth_n);
                float3  _S1080 = (&ray_2)->origin + make_float3 (_S1076.geometry_offset) * _S1079;
                (&ray_2)->origin = _S1080;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1046;
            sky_pdf_2 = _S1059;
            spread_4 = _S1060;
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
            is_inside_5 = is_inside_6;
        }
        bool _S1081 = !replay_1;
        float density_7;
        if(_S1081)
        {
            if(_S811)
            {
                float3  _S1082 = throughput_9 * emission_1;
                Reservoir candidate_7 = chain_0;
                uint _S1083 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1084 = _S1083 == 1U;
                if(_S1084)
                {
                    float3  _S1085 = safeDivide(_S1082, chain_throughput_0);
                    (&candidate_7)->radiance = _S1085;
                }
                Reservoir _S1086 = withEnd(candidate_7, 2U, b_4, _S1082);
                offer(sel_1, _S1086, _S1082 * make_float3 (scale_1) / make_float3 (density_6));
            }
            if(_S811)
            {
                _S875 = true;
            }
            else
            {
                _S875 = scatter_2;
            }
            if(_S875)
            {
                float _S1087 = survivalProbability(throughput_9, density_6);
                density_7 = _S1087;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1088 = stream(_S703, b_4 + 128U);
            Random _S1089 = pcg(_S1088);
            bool _S1090 = density_7 < (_S1089.value);
            if(_S1090)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1091 = (fcptMaxBounces());
                wrong_side_0 = b_4 >= _S1091;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1092 = density_6 * density_7;
            density_7 = _S1092;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1093 = layer_0 ^ 1U;
        uint _S1094 = _slang_select(passes_0, _S1093,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_1)->distance = 0.0f;
            b_7 = b_4;
            throughput_2 = throughput_9;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_1 = spread_4;
            uint _S1095 = b_7 + 1U;
            b_4 = _S1095;
            layer_0 = _S1094;
            continue;
        }
        FKRay _S1096 = ray_2;
        float _S1097 = distance_5(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            _S875 = b_4 == _S691;
        }
        else
        {
            _S875 = false;
        }
        if(_S875)
        {
            wrong_side_0 = _S680 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1098 = _slang_select(wrong_side_0, _S1097,4.294967296e+09f);
        FKHit _S1099 = (fcptTraverseInstanceBVH((_S1096), (_S816), (_S1098), (true)));
        hit_1 = _S1099;
        if(replay_1)
        {
            refracted_4 = b_4 == _S691;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            _S876 = _S680 == 1U;
        }
        else
        {
            _S876 = false;
        }
        if(_S876)
        {
            _S877 = ((&hit_1)->instance_index) == (_S692.instance_index);
        }
        else
        {
            _S877 = false;
        }
        if(_S877)
        {
            _S966 = ((&hit_1)->triangle_index) == (_S692.triangle_index);
        }
        else
        {
            _S966 = false;
        }
        if(_S966)
        {
            (&hit_1)->uv = _S692.uv;
            float _S1100 = distance_5(reconnection_0, (&ray_2)->origin);
            (&hit_1)->distance = _S1100;
        }
        if(replay_1)
        {
            _S967 = b_4 == _S691;
        }
        else
        {
            _S967 = false;
        }
        if(_S967)
        {
            _S968 = _S680 == 3U;
        }
        else
        {
            _S968 = false;
        }
        if(_S968)
        {
            _S969 = ((&hit_1)->instance_index) != 4294967295U;
        }
        else
        {
            _S969 = false;
        }
        if(_S969)
        {
            return _S676;
        }
        Reservoir _S1101 = chain_0;
        uint _S1102 = filling_2;
        for(;;)
        {
            bool _S1103 = _S1102 != 4294967295U;
            float _S1104 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            float _S1105 = (fcptMajorant((_S1102)));
            float _S1106 = _slang_select(_S1103, _S1105,_S1104);
            if(replay_1)
            {
                _S970 = b_4 == _S691;
            }
            else
            {
                _S970 = false;
            }
            if(_S970)
            {
                _S971 = _S680 == 1U;
            }
            else
            {
                _S971 = false;
            }
            if(_S971)
            {
                _S972 = _S1106 > 0.0f;
            }
            else
            {
                _S972 = false;
            }
            if(_S972)
            {
                ended_0 = _S676;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_3 = width_2;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_7 = b_4;
                _S973 = true;
                break;
            }
            bool _S1107 = (&prev_0)->rough;
            if(_S1107)
            {
                _S973 = !(_S1106 > 0.0f);
            }
            else
            {
                _S973 = false;
            }
            (&prev_0)->rough = _S973;
            uint _S1108 = b_4 + 320U;
            bool _S1109 = b_4 == 4294967295U;
            uint _S1110 = _slang_select(_S1109, 384U,_S1108);
            uint _S1111 = stream(_S703, _S1110);
            uint tracking_1 = _S1111;
            weight_1 = throughput_3;
            glowed_0 = _S675;
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
                    _S674 = int(2);
                    break;
                }
                uint _S1112 = b_7 + 320U;
                bool _S1113 = b_7 == 4294967295U;
                uint _S1114 = _slang_select(_S1113, 384U,_S1112);
                uint _S1115 = stream(_S703, _S1114);
                Random _S1116 = pcg(_S1115);
                float _S1117 = freeFlight_0(_S1116.value, _S1106);
                if(_S1103)
                {
                    float3  _S1118 = (&ray_2)->origin;
                    float3  _S1119 = (&ray_2)->unit_direction;
                    float _S1120 = (&hit_1)->distance;
                    uint _S1121 = _slang_select(_S1113, 0U,b_7);
                    uint _S1122 = (&prev_0)->lobe;
                    uint _S1123 = _slang_select(_S1113, 3U,_S1122);
                    float _S1124 = (fcptTrackMedium((_S1102), (_S1118), (_S1119), (_S1120), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S1121), (_S1123)));
                    spread_3 = _S1124;
                }
                else
                {
                    spread_3 = _S1117;
                }
                bool _S1125 = !(spread_3 < ((&hit_1)->distance));
                if(_S1125)
                {
                    _S674 = int(2);
                    break;
                }
                if(_S1103)
                {
                    _S974 = _S1081;
                }
                else
                {
                    _S974 = false;
                }
                if(_S974)
                {
                    float3  _S1126 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1127 = sel_1->glow + _S1126;
                    sel_1->glow = _S1127;
                }
                else
                {
                }
                glowed_0 = _S675;
                uint b_8 = b_7 + 1U;
                float3  _S1128 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1128;
                float3  _S1129 = flightWeight_0(scatter_in_0, extinction_in_0, _S1106, spread_3, true);
                float3  _S1130 = weight_1;
                float3  _S1131 = _slang_select(_S1103, _S1130,_S1129);
                float3  throughput_11 = throughput_10 * _S1131;
                uint _S1132 = stream(_S703, b_8 + 320U);
                tracking_1 = _S1132;
                weight_1 = throughput_3;
                float width_6 = width_3 + spread_2 * spread_3;
                float _S1133 = spread_2 + 3.14159274101257324f;
                uint _S1134 = stream(_S703, b_8 + 64U);
                uint2  _S1135 = make_uint2 (_S1102);
                uint _S1136 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                ShadowContext _S1137 = ShadowContext_x24init_0(extinction_in_0, extinction_in_0, _S1135, (&ray_2)->unit_direction, b_8, _S1136, false, spread_3, width_6);
                TreeSample _S1138 = sampleLightTree_0((&ray_2)->origin, (&ray_2)->unit_direction, (&ray_2)->unit_direction, 0.0f, true, _S1134, &_S1137);
                bool _S1139 = scatterSampled_0(replay_1, b_8, _S691, _S1103);
                uint _S1140 = (fcptMaxBounces());
                bool _S1141 = b_8 < _S1140;
                if(_S1141)
                {
                    _S975 = (_S1138.density) > 0.0f;
                }
                else
                {
                    _S975 = false;
                }
                float _S1142 = _slang_select(_S975, 0.07957746833562851f,0.0f);
                float3  _S1143 = throughput_11 * _S1138.radiance;
                float _S1144 = powerHeuristic(_S1138.density, _S1142);
                float3  _S1145 = _S1143 * make_float3 (0.07957746833562851f * _S1144);
                float3  _S1146 = _slang_select(_S1139, _S1145,_S675);
                if(replay_1)
                {
                    _S976 = b_8 == _S691;
                }
                else
                {
                    _S976 = false;
                }
                if(_S976)
                {
                    bool _S1147 = _S680 == 2U;
                    if(_S1147)
                    {
                        float _S1148 = rgb_to_greyscale(_S1146);
                        _S977 = _S1148 > 0.0f;
                    }
                    else
                    {
                        _S977 = false;
                    }
                    if(_S977)
                    {
                        Shift _S1149 = Shift_x24init_0(_S1146, 1.0f);
                        _S674 = int(1);
                        ended_0 = _S1149;
                        spread_3 = _S1133;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_5 = b_8;
                        break;
                    }
                    _S674 = int(1);
                    ended_0 = _S676;
                    spread_3 = _S1133;
                    width_4 = width_6;
                    throughput_8 = throughput_11;
                    b_5 = b_8;
                    break;
                }
                if(_S1081)
                {
                    Reservoir candidate_8 = _S1101;
                    uint _S1150 = extractBits_0(_S1101.path, 10U, 2U);
                    bool _S1151 = _S1150 == 1U;
                    if(_S1151)
                    {
                        float3  _S1152 = safeDivide(_S1146, chain_throughput_0);
                        (&candidate_8)->radiance = _S1152;
                    }
                    else
                    {
                        uint _S1153 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                        uint _S1154 = insertBits_0(_S1153, 2U, 10U, 2U);
                        (&candidate_8)->path = _S1154;
                    }
                    Reservoir _S1155 = withEnd(candidate_8, 0U, b_8, _S1146);
                    offer(sel_1, _S1155, _S1146 * make_float3 (scale_1) / make_float3 (density_3));
                    float _S1156 = survivalProbability(throughput_11, density_3);
                    uint _S1157 = stream(_S703, b_8 + 128U);
                    Random _S1158 = pcg(_S1157);
                    bool _S1159 = _S1156 < (_S1158.value);
                    if(_S1159)
                    {
                        _S977 = true;
                    }
                    else
                    {
                        uint _S1160 = (fcptMaxBounces());
                        _S977 = b_8 >= _S1160;
                    }
                    if(_S977)
                    {
                        _S674 = int(1);
                        ended_0 = _S676;
                        spread_3 = _S1133;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_5 = b_8;
                        break;
                    }
                    float _S1161 = density_3 * _S1156;
                    density_3 = _S1161;
                }
                else
                {
                }
                NEEVertex _S1162 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_2)->origin, _S675, (&ray_2)->origin);
                nee_vertex_0 = _S1162;
                uint _S1163 = stream(_S703, b_8);
                float3  _S1164 = isotropic_0(_S1163);
                (&ray_2)->unit_direction = _S1164;
                Vertex _S1165 = scatteredVertex_0(is_inside_5);
                prev_0 = _S1165;
                float _S1166 = (&prev_0)->pdf;
                FKHit _S1167 = (fcptTraverseInstanceBVH((ray_2), (true), (4.294967296e+09f), (false)));
                hit_1 = _S1167;
                b_7 = b_8;
                throughput_10 = throughput_11;
                spread_2 = _S1133;
                width_3 = width_6;
                sky_pdf_1 = _S1166;
            }
            if(_S674 != int(2))
            {
                spread_2 = spread_3;
                width_3 = width_4;
                throughput_10 = throughput_8;
                b_7 = b_5;
                _S973 = true;
                break;
            }
            ended_0 = _S676;
            _S973 = false;
            break;
        }
        if(_S973)
        {
            return ended_0;
        }
        Reservoir _S1168 = chain_0;
        NEEVertex _S1169 = nee_vertex_0;
        Vertex _S1170 = prev_0;
        FKHit _S1171 = hit_1;
        uint _S1172 = filling_2;
        float3  _S1173 = scatter_in_0;
        float3  _S1174 = extinction_in_0;
        float3  _S1175 = weight_1;
        float3  _S1176 = glowed_0;
        for(;;)
        {
            bool _S1177 = (_S1171.instance_index) == 4294967295U;
            if(_S1177)
            {
                bool _S1178 = !_S1169.none;
                float _S1179 = _slang_select(_S1178, sky_pdf_1,0.0f);
                float _S1180 = escapeWeight_0(_S1179, (&ray_2)->unit_direction);
                float3  _S1181 = environment_0((&ray_2)->unit_direction, b_7, _S1170.lobe);
                float3  _S1182 = throughput_10 * _S1181;
                if(replay_1)
                {
                    bool _S1183 = b_7 == _S691;
                    if(_S1183)
                    {
                        _S974 = _S680 == 3U;
                    }
                    else
                    {
                        _S974 = false;
                    }
                    if(_S974)
                    {
                        Shift _S1184 = Shift_x24init_0(_S1182 * make_float3 (_S1180) / make_float3 (r_3->jac), density_3 / r_3->jac);
                        arrived_end_0 = _S1184;
                        width_4 = width_3;
                        throughput_8 = throughput_10;
                        _S974 = true;
                        break;
                    }
                    if(_S690)
                    {
                        _S975 = _S687;
                    }
                    else
                    {
                        _S975 = false;
                    }
                    if(_S975)
                    {
                        _S976 = b_7 == _S678;
                    }
                    else
                    {
                        _S976 = false;
                    }
                    if(_S976)
                    {
                        _S977 = !_S1170.rough;
                    }
                    else
                    {
                        _S977 = false;
                    }
                    if(_S977)
                    {
                        Shift _S1185 = Shift_x24init_0(_S1182 * make_float3 (_S1180), 1.0f);
                        arrived_end_0 = _S1185;
                        width_4 = width_3;
                        throughput_8 = throughput_10;
                        _S974 = true;
                        break;
                    }
                    arrived_end_0 = _S676;
                    width_4 = width_3;
                    throughput_8 = throughput_10;
                    _S974 = true;
                    break;
                }
                Reservoir candidate_9 = _S1168;
                uint _S1186 = extractBits_0(_S1168.path, 10U, 2U);
                bool _S1187 = _S1186 == 1U;
                if(_S1187)
                {
                    uint _S1188 = extractBits_0(_S1168.path, 5U, 5U);
                    bool _S1189 = _S1188 == b_7;
                    float _S1190 = _slang_select(_S1189, 1.0f,_S1180);
                    float3  _S1191 = safeDivide(_S1182 * make_float3 (_S1190), chain_throughput_0);
                    (&candidate_9)->radiance = _S1191;
                }
                else
                {
                    if(_S1170.rough)
                    {
                        uint _S1192 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                        uint _S1193 = insertBits_0(_S1192, 3U, 10U, 2U);
                        uint _S1194 = insertBits_0(_S1193, _S1170.lobe, 15U, 2U);
                        uint _S1195 = _slang_select(_S1170.inside, 1U,0U);
                        uint _S1196 = insertBits_0(_S1194, _S1195, 20U, 1U);
                        (&candidate_9)->path = _S1196;
                        (&candidate_9)->jac = _S1170.pdf;
                        (&candidate_9)->dir = (&ray_2)->unit_direction;
                    }
                    else
                    {
                    }
                }
                float3  _S1197 = _S1182 * make_float3 (_S1180);
                Reservoir _S1198 = withEnd(candidate_9, 3U, b_7, _S1197);
                offer(sel_1, _S1198, _S1197 * make_float3 (scale_1) / make_float3 (density_3));
                arrived_end_0 = _S676;
                width_4 = width_3;
                throughput_8 = throughput_10;
                _S974 = true;
                break;
            }
            float3  _S1199 = (&ray_2)->origin + make_float3 (_S1171.distance) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1199;
            bool _S1200 = _S1172 != 4294967295U;
            if(_S1200)
            {
                if(_S1081)
                {
                    float3  _S1201 = throughput_10 * _S1176 / make_float3 (density_3);
                    float3  _S1202 = sel_1->glow + _S1201;
                    sel_1->glow = _S1202;
                }
                else
                {
                }
                float3  _S1203 = throughput_10 * _S1175;
                throughput_8 = _S1203;
            }
            else
            {
                float3  _S1204 = flightWeight_0(_S1173, _S1174, (_S1173.x + _S1173.y + _S1173.z) / 3.0f, _S1171.distance, false);
                float3  _S1205 = throughput_10 * _S1204;
                throughput_8 = _S1205;
            }
            float _S1206 = width_3 + spread_2 * _S1171.distance;
            arrived_end_0 = _S676;
            width_4 = _S1206;
            _S974 = false;
            break;
        }
        if(_S974)
        {
            return arrived_end_0;
        }
        width_2 = width_4;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1095 = b_7 + 1U;
        b_4 = _S1095;
        layer_0 = _S1094;
    }
    return _S676;
}

static __device__ Shift shift_0(Domain * dom_1, Reservoir * r_4)
{
    Selection _S1207 = (Selection{});
    Selection sel_2 = _S1207;
    bool _S1208 = (r_4->w) <= 0.0f;
    if(_S1208)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1209 = walk_0(dom_1, r_4, true, 0.0f, &sel_2);
    return _S1209;
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
    Random _S1210 = pcg(state_3);
    Random _S1211 = pcg(_S1210.state);
    float _S1212 = 6.28318548202514648f * _S1210.value;
    float _S1213 = (F32_sqrt((-2.0f * clamp_0((F32_log((_S1211.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1211.state, _S1213 * (F32_cos((_S1212))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1214;
    (&_S1214)->state = state_4;
    (&_S1214)->value = value_2;
    return _S1214;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1215 = normal_distribution(state_5);
    Random _S1216 = normal_distribution(_S1215.state);
    Random _S1217 = normal_distribution(_S1216.state);
    float3  _S1218 = make_float3 (_S1215.value, _S1216.value, _S1217.value);
    float3  _S1219 = ((((_S1218)) * make_float3(rnorm3df(((_S1218)).x, ((_S1218)).y, ((_S1218)).z))));
    return RandomSphere_x24init_0(_S1217.state, _S1219);
}

struct RandomHemisphere
{
    uint state;
    float3  value;
};

static __device__ RandomHemisphere RandomHemisphere_x24init_0(uint state_6, float3  value_3)
{
    RandomHemisphere _S1220;
    (&_S1220)->state = state_6;
    (&_S1220)->value = value_3;
    return _S1220;
}

__device__ RandomHemisphere random_hemisphere(uint state_7, float3  normal_4)
{
    RandomSphere _S1221 = random_sphere(state_7);
    bool _S1222 = (dot_0(_S1221.value, normal_4)) > 0.0f;
    if(_S1222)
    {
        return RandomHemisphere_x24init_0(_S1221.state, _S1221.value);
    }
    else
    {
        float3  _S1223 = negate_0(_S1221.value);
        return RandomHemisphere_x24init_0(_S1221.state, _S1223);
    }
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_15)
{
    float3  _S1224 = p1_0 - p0_0;
    float3  _S1225 = p2_0 - p0_0;
    float2  _S1226 = uv1_0 - uv0_0;
    float2  _S1227 = uv2_0 - uv0_0;
    float _S1228 = _S1226.x;
    float _S1229 = _S1227.y;
    float _S1230 = _S1226.y;
    float _S1231 = _S1227.x;
    float _S1232 = _S1228 * _S1229 - _S1230 * _S1231;
    float _S1233 = 1.0f / _S1232;
    float3  t_1 = (_S1224 * make_float3 (_S1229) - _S1225 * make_float3 (_S1230)) * make_float3 (_S1233);
    float3  _S1234 = (_S1225 * make_float3 (_S1228) - _S1224 * make_float3 (_S1231)) * make_float3 (_S1233);
    float3  _S1235 = t_1 - n_15 * make_float3 (dot_0(n_15, t_1));
    float3  t_2 = ((((_S1235)) * make_float3(rnorm3df(((_S1235)).x, ((_S1235)).y, ((_S1235)).z))));
    bool _S1236 = (dot_0(cross_0(n_15, t_2), _S1234)) > 0.0f;
    float3  t_3;
    if(_S1236)
    {
        float3  _S1237 = negate_0(t_2);
        t_3 = _S1237;
    }
    else
    {
        t_3 = t_2;
    }
    float3  _S1238 = cross_0(n_15, t_3);
    return makeMatrix<float, 3, 3> (t_3, _S1238, n_15);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1239 = t1_0 - t0_0;
    float3  _S1240 = t2_2 - t0_0;
    float3  _S1241 = t2_2 - t1_0;
    float _S1242 = (F32_min((length_0(_S1239)), ((F32_min((length_0(_S1240)), (length_0(_S1241)))))));
    float3  _S1243 = make_float3 (distance_5(position_0, t0_0), distance_5(position_0, t1_0), distance_5(position_0, t2_2));
    float3  _S1244 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1245 = dot_0(geometry_n_5, _S1244);
    float3  _S1246 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1247 = dot_0(geometry_n_5, _S1246);
    float3  _S1248 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1249 = acos_0(abs_0(make_float3 (_S1245, _S1247, dot_0(geometry_n_5, _S1248))));
    float3  _S1250 = clamp_1(tan_0(_S1249), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_0(dot_0(_S1243 * _S1250, uvw_0), 0.0f, _S1242 * 0.125f);
}

__device__ float3  sampleHalfVector(float3  v_6, float3  n_i_5, float alpha_6, uint * random_state_15)
{
    float3  _S1251 = sampleMaterialHalfVector(v_6, n_i_5, alpha_6, AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f)), random_state_15);
    return _S1251;
}

__device__ float3  straightThrough(float3  dir_14, float3  n_16, BSDFMaterial material_16)
{
    float3  _S1252 = negate_0(dir_14);
    float _S1253 = sign_0(dot_0(n_16, _S1252));
    float3  _S1254 = n_16 * make_float3 (_S1253);
    AnisotropicFrame _S1255 = anisotropicFrame(material_16, _S1254);
    bool _S1256 = (_S1255.alphas.x) > 0.0f;
    if(_S1256)
    {
        float _S1257 = material_16.transmission * (1.0f - material_16.metallic);
        float3  _S1258 = negate_0(_S1254);
        float3  _S1259 = anisotropicLocal(dir_14, _S1255.tangent, _S1258);
        float _S1260 = anisotropicG1(_S1259, _S1255.alphas);
        return make_float3 (_S1257 * _S1260) * material_16.albedo;
    }
    float _S1261 = material_16.transmission * (1.0f - material_16.metallic);
    float _S1262 = material_16.roughness;
    float _S1263 = smithG1(_S1262 * _S1262, (F32_abs((dot_0(n_16, dir_14)))));
    return make_float3 (_S1261 * _S1263) * material_16.albedo;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_17, BSDFMaterial material_17, float coverage_1)
{
    float3  _S1264;
    if((material_17.ior) == 1.0f)
    {
        float3  _S1265 = straightThrough(toward_1, n_17, material_17);
        _S1264 = _S1265;
    }
    else
    {
        _S1264 = make_float3 (0.0f);
    }
    return _S1264 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_5, Shift shifted_0, float mis_0)
{
    Reservoir candidate_10 = r_5;
    float3  _S1266 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_10)->f = _S1266;
    float _S1267 = r_5.jac * shifted_0.jac;
    (&candidate_10)->jac = _S1267;
    offer(sel_3, candidate_10, make_float3 (mis_0) * shifted_0.f * make_float3 (r_5.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_6 = sel_4.r;
    float _S1268 = rgb_to_greyscale((&r_6)->f);
    float _S1269 = sel_4.w_sum / _S1268;
    bool _S1270 = _S1268 > 0.0f;
    float _S1271 = _slang_select(_S1270, _S1269,0.0f);
    (&r_6)->w = _S1271;
    (&r_6)->c = c_1;
    return r_6;
}

static __device__ float interpolate_0(float a_6, float b_9, float t_4)
{
    return a_6 + (b_9 - a_6) * t_4;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S1272 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S1272;
}

__device__ float2  temporalWeights(float c_2, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S1273 = c_2 * p_c_0;
    float _S1274 = c_t_0 * p_t_0;
    return make_float2 (_S1273 / (_S1273 + c_t_0 * g_previous_0), _S1274 / (_S1274 + c_2 * g_current_0));
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
    Domain _S1275 = dom_2;
    Reservoir _S1276 = r_7;
    Shift _S1277 = walk_0(&_S1275, &_S1276, replay_2, scale_2, sel_5);
    return _S1277;
}

__device__ Shift shift_hook(Domain dom_3, Reservoir r_8)
{
    Domain _S1278 = dom_3;
    Reservoir _S1279 = r_8;
    Shift _S1280 = shift_0(&_S1278, &_S1279);
    return _S1280;
}

#undef Matrix
