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
        FKHit _S495 = Hit_x24init_0(_S490, _S485, _S487, 0U, 0.0f);
        float3  _S496 = _S491 - start_4;
        float3  _S497 = ((((_S496)) * make_float3(rnorm3df(((_S496)).x, ((_S496)).y, ((_S496)).z))));
        FKSurface _S498 = (fcptLightSurfaceAt((_S495), (_S491), (_S451.state), (_S497), (context_1->depth), (length_0(_S491 - origin_4))));
        (&sample_0)->random_state = _S498.random_state;
        float3  _S499 = ((((_S496)) * make_float3(rnorm3df(((_S496)).x, ((_S496)).y, ((_S496)).z))));
        (&sample_0)->dir = _S499;
        float _S500 = solidAngle(probability_4, cross_0(_S488.rows[int(1)] - _S488.rows[int(0)], _S488.rows[int(2)] - _S488.rows[int(0)]), _S496);
        (&sample_0)->density = _S500;
        float _S501 = sign_0(dot_0(- (&sample_0)->dir, _S498.smooth_n));
        float3  _S502 = _S498.material.emissive * make_float3 ((F32_max((_S501), (0.0f))));
        float3  _S503 = _slang_select(_S498.skip, _S452,_S502);
        float3  _S504 = _S503 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S504;
        float3  _S505 = shadowLift(_S498.smooth_n, _S498.geometry_offset, start_4, _S491);
        float3  _S506 = _S491 + _S505 - start_4;
        shadow_1 = _S506;
    }
    float3  _S507 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_1, _S451.state);
    float3  _S508 = (&sample_0)->radiance * _S507;
    bool _S509 = all_0(_S507 == _S452);
    float3  _S510 = _slang_select(_S509, _S452,_S508);
    (&sample_0)->radiance = _S510;
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
    float _S511 = 1.0f / (1.0f + b_0 / a_4 * (b_0 / a_4));
    bool _S512 = b_0 > 0.0f;
    float _S513 = _slang_select(_S512, _S511,1.0f);
    return _S513;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_0, float3  light_point_1)
{
    bool _S514 = vertex_0->none;
    if(_S514)
    {
        return 1.0f;
    }
    uint _S515 = (fcptLightSlot((*hit_0)));
    float _S516 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S515, light_point_1);
    float _S517 = powerHeuristic(vertex_0->pdf, _S516);
    return _S517;
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
    Shift _S518;
    (&_S518)->f = f_4;
    (&_S518)->jac = jac_0;
    return _S518;
}

static __device__ uint extractBits_0(uint e_1, uint offset_0, uint count_1)
{
    return (e_1 >> offset_0) & ((1U << count_1) - 1U);
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_5)
{
    NEEVertex _S519;
    (&_S519)->none = none_0;
    (&_S519)->pdf = pdf_4;
    (&_S519)->origin = origin_5;
    (&_S519)->smooth_n = smooth_n_3;
    (&_S519)->start = start_5;
    return _S519;
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
    Vertex _S520;
    (&_S520)->rough = rough_0;
    (&_S520)->lobe = lobe_7;
    (&_S520)->pdf = pdf_5;
    (&_S520)->cos = cos_0;
    (&_S520)->inside = inside_0;
    return _S520;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S521 = hash(index_0);
    uint _S522 = hash(seed_0 ^ _S521);
    return _S522;
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
    float3  _S523 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_1));
    float3  _S524 = scatter_0 * _S523 / make_float3 (sigma_1);
    float3  _S525 = _slang_select(scatters_0, _S524,_S523);
    return _S525;
}

static __device__ uint arrivalLobe_0(uint b_1, uint prev_lobe_0)
{
    bool _S526 = b_1 > 0U;
    uint _S527 = _slang_select(_S526, prev_lobe_0,3U);
    return _S527;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_8, bool surface_3, float length_2, float width_0)
{
    ShadowContext _S528;
    (&_S528)->extinction_behind = extinction_behind_0;
    (&_S528)->extinction_front = extinction_front_0;
    (&_S528)->fillings = fillings_0;
    (&_S528)->side = side_0;
    (&_S528)->depth = depth_1;
    (&_S528)->lobe = lobe_8;
    (&_S528)->surface = surface_3;
    (&_S528)->length = length_2;
    (&_S528)->width = width_0;
    return _S528;
}

static __device__ bool scatterSampled_0(bool replay_0, uint b_2, uint stop_0, bool varying_0)
{
    bool _S529 = !replay_0;
    bool _S530;
    if(_S529)
    {
        _S530 = true;
    }
    else
    {
        bool _S531 = b_2 == stop_0;
        if(_S531)
        {
            _S530 = !varying_0;
        }
        else
        {
            _S530 = false;
        }
    }
    return _S530;
}

__device__ float3  safeDivide(float3  a_5, float3  b_3)
{
    float3  _S532 = a_5 / b_3;
    float3  _S533 = make_float3 (0.0f);
    bool3  _S534 = b_3 == _S533;
    float3  _S535 = _slang_select(_S534, _S533,_S532);
    return _S535;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S536 = (1U << count_2) - 1U;
    return (e_2 & (~(_S536 << offset_1))) | ((newbits_0 & _S536) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_1, float3  f_5)
{
    Reservoir candidate_0 = r_2;
    uint _S537 = insertBits_0(r_2.path, end_1, 0U, 5U);
    uint _S538 = insertBits_0(_S537, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S538;
    (&candidate_0)->f = f_5;
    return candidate_0;
}

__device__ void offer(Selection * sel_0, Reservoir candidate_1, float3  weight_0)
{
    float _S539 = rgb_to_greyscale(weight_0);
    bool _S540 = _S539 > 0.0f;
    bool _S541;
    if(_S540)
    {
        _S541 = _S539 < 3.00000000549775576e+38f;
    }
    else
    {
        _S541 = false;
    }
    bool _S542 = !_S541;
    if(_S542)
    {
        return;
    }
    bool _S543 = sel_0->sums;
    if(_S543)
    {
        float3  _S544 = sel_0->color + weight_0;
        sel_0->color = _S544;
        return;
    }
    float _S545 = sel_0->w_sum + _S539;
    sel_0->w_sum = _S545;
    float3  _S546 = sel_0->color + weight_0;
    sel_0->color = _S546;
    Random _S547 = pcg(sel_0->random_state);
    sel_0->random_state = _S547.state;
    bool _S548 = (_S547.value * sel_0->w_sum) <= _S539;
    if(_S548)
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
    Random _S549 = pcg(random_state_8);
    Random _S550 = pcg(_S549.state);
    float _S551 = 1.0f - 2.0f * _S549.value;
    float _S552 = (F32_sqrt(((F32_max((1.0f - _S551 * _S551), (0.0f))))));
    float _S553 = 6.28318548202514648f * _S550.value;
    return make_float3 (_S552 * (F32_cos((_S553))), _S552 * (F32_sin((_S553))), _S551);
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2)
{
    BSDFMaterial _S554;
    (&_S554)->albedo = albedo_0;
    (&_S554)->emissive = emissive_0;
    (&_S554)->roughness = roughness_0;
    (&_S554)->metallic = metallic_0;
    (&_S554)->transmission = transmission_0;
    (&_S554)->ior = ior_0;
    (&_S554)->absorption = absorption_0;
    (&_S554)->specular_tint = specular_tint_0;
    (&_S554)->specular_level = specular_level_0;
    (&_S554)->translucent = translucent_0;
    (&_S554)->sheen = sheen_2;
    (&_S554)->sheen_roughness = sheen_roughness_0;
    (&_S554)->anisotropy = anisotropy_0;
    (&_S554)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S554)->tangent = tangent_2;
    return _S554;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1)
{
    FKMedium _S555;
    (&_S555)->scatter = scatter_1;
    (&_S555)->extinction = extinction_1;
    return _S555;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_6, bool skip_0, uint random_state_9, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0)
{
    FKSurface _S556;
    (&_S556)->smooth_n = smooth_n_4;
    (&_S556)->geometry_n = geometry_n_2;
    (&_S556)->geometry_offset = geometry_offset_2;
    (&_S556)->material = *material_6;
    (&_S556)->skip = skip_0;
    (&_S556)->random_state = random_state_9;
    (&_S556)->coverage = coverage_0;
    (&_S556)->encloses = encloses_0;
    (&_S556)->volume = *volume_0;
    (&_S556)->fills = fills_0;
    return _S556;
}

static __device__ FKSurface emitting_0(FKSurface * surface_4, bool top_0)
{
    FKSurface lower_0 = *surface_4;
    float3  _S557 = (&surface_4->material)->emissive;
    float3  _S558 = make_float3 (0.0f);
    bool _S559 = !top_0;
    float3  _S560 = _slang_select(_S559, _S558,_S557);
    (&(&lower_0)->material)->emissive = _S560;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_5, float u_2)
{
    float _S561 = surface_5->coverage;
    bool _S562 = u_2 < _S561;
    if(_S562)
    {
        return *surface_5;
    }
    float3  _S563 = make_float3 (0.0f);
    float3  _S564 = make_float3 (1.0f);
    BSDFMaterial _S565 = Material_x24init_0(_S563, _S563, 0.0f, 0.0f, 0.0f, 0.0f, _S563, _S564, 1.0f, _S563, _S563, 0.5f, 0.0f, 0.0f, _S563);
    BSDFMaterial material_7 = _S565;
    (&material_7)->albedo = _S564;
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
    bool _S566 = transmission_1 > 0.0f;
    bool _S567;
    if(_S566)
    {
        _S567 = true;
    }
    else
    {
        _S567 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S568;
    if(_S567)
    {
        _S568 = 1.0f;
    }
    else
    {
        _S568 = -1.0f;
    }
    return _S568;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_6, float3  dir_9)
{
    float3  _S569 = surface_6->geometry_n;
    float _S570 = facingSign((&surface_6->material)->transmission, surface_6->geometry_n, dir_9);
    FKSurface faced_0 = *surface_6;
    float3  _S571 = surface_6->smooth_n * make_float3 (_S570);
    (&faced_0)->smooth_n = _S571;
    float3  _S572 = _S569 * make_float3 (_S570);
    (&faced_0)->geometry_n = _S572;
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
    float3  _S573 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_2) * log_0(_S573));
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
    bool _S574;
    if(open_0)
    {
        _S574 = prev_rough_0;
    }
    else
    {
        _S574 = false;
    }
    if(_S574)
    {
        _S574 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S574 = false;
    }
    return _S574;
}

static __device__ float2  vertexEta_0(BSDFMaterial * material_8, float n_dot_v_0)
{
    bool _S575 = n_dot_v_0 < 0.0f;
    float _S576 = material_8->ior;
    float _S577 = _slang_select(_S575, _S576,1.0f);
    float _S578 = _slang_select(_S575, 1.0f,_S576);
    return make_float2 (_S577, _S578);
}

__device__ bool samplesLights(BSDFMaterial material_9)
{
    bool _S579 = (material_9.roughness) > 0.0f;
    bool _S580;
    if(_S579)
    {
        _S580 = true;
    }
    else
    {
        bool _S581 = (material_9.metallic) < 1.0f;
        if(_S581)
        {
            _S580 = (material_9.transmission) < 1.0f;
        }
        else
        {
            _S580 = false;
        }
    }
    return _S580;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_10)
{
    float _S582 = rgb_to_greyscale(material_10->translucent);
    return _S582 > 0.0f;
}

__device__ float3  sideNormal(FKSurface surface_7, float3  in_dir_4)
{
    bool _S583 = !((surface_7.material.transmission) > 0.0f);
    bool _S584;
    if(_S583)
    {
        BSDFMaterial _S585 = surface_7.material;
        bool _S586 = isTranslucent_0(&_S585);
        _S584 = !_S586;
    }
    else
    {
        _S584 = false;
    }
    if(_S584)
    {
        _S584 = (dot_0(surface_7.smooth_n, - in_dir_4)) > 0.0f;
    }
    else
    {
        _S584 = false;
    }
    float3  _S587 = _slang_select(_S584, surface_7.smooth_n,surface_7.geometry_n);
    return _S587;
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
    MediumSides _S588;
    (&_S588)->behind = *behind_0;
    (&_S588)->front = *front_0;
    (&_S588)->fillings = fillings_1;
    (&_S588)->face = face_1;
    return _S588;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_11)
{
    float3  _S589 = surface_8->geometry_n;
    MediumSides _S590 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S590;
    bool _S591 = surface_8->encloses;
    if(_S591)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S592 = (dot_0(dir_11, _S589)) > 0.0f;
        if(_S592)
        {
            float3  _S593 = make_float3 (0.0f);
            FKMedium _S594 = Medium_x24init_0(_S593, _S593);
            (&sides_0)->front = _S594;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  side_n_3, float3  extinction_2, uint filling_1, float3  dir_12, uint depth_2, uint lobe_9, float length_3, float width_1)
{
    FKSurface faced_1 = *surface_9;
    float3  _S595 = surface_9->geometry_n;
    float3  _S596 = - surface_9->geometry_n;
    float3  _S597 = _slang_select(turned_0, _S596,_S595);
    (&faced_1)->geometry_n = _S597;
    FKMedium _S598 = Medium_x24init_0(make_float3 (0.0f), extinction_2);
    FKSurface _S599 = faced_1;
    FKMedium _S600 = _S598;
    MediumSides _S601 = mediumSides_0(&_S599, &_S600, filling_1, dir_12);
    ShadowContext _S602 = ShadowContext_x24init_0(_S601.behind.extinction, _S601.front.extinction, _S601.fillings, side_n_3, depth_2, lobe_9, true, length_3, width_1);
    ShadowContext context_2;
    if(turned_0)
    {
        uint2  _S603 = _S601.fillings;
        ShadowContext _S604 = ShadowContext_x24init_0(_S601.front.extinction, _S601.behind.extinction, uint2 {_S603.y, _S603.x}, side_n_3, depth_2, lobe_9, true, length_3, width_1);
        context_2 = _S604;
    }
    else
    {
        context_2 = _S602;
    }
    return context_2;
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_5, float3  out_dir_1, float3  n_10, float3  g_n_0, BSDFMaterial material_11, float eta_i_5, float eta_o_5, uint random_state_10)
{
    float3  _S605 = negate_0(in_dir_5);
    bool _S606 = (dot_0(g_n_0, _S605) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S606)
    {
        SampleBSDF _S607 = connectBSDF(in_dir_5, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 0U, random_state_10);
        SampleBSDF _S608 = connectBSDF(in_dir_5, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 2U, random_state_10);
        return _S607.throughput * make_float3 (_S607.pdf) + _S608.throughput * make_float3 (_S608.pdf);
    }
    SampleBSDF _S609 = connectBSDF(in_dir_5, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 1U, random_state_10);
    return _S609.throughput * make_float3 (_S609.pdf);
}

__device__ float3  translucentCorrection(float3  in_dir_6, float3  out_dir_2, float3  n_11, float3  g_n_1, BSDFMaterial material_12, float eta_i_6, float eta_o_6, uint random_state_11)
{
    float _S610 = dot_0(n_11, out_dir_2);
    float3  _S611 = negate_0(in_dir_6);
    bool _S612 = (_S610 * dot_0(n_11, _S611)) < 0.0f;
    SampleBSDF _S613 = connectBSDF(in_dir_6, out_dir_2, n_11, material_12, eta_i_6, eta_o_6, 0U, random_state_11);
    float3  _S614 = negate_0(in_dir_6);
    bool _S615 = (dot_0(g_n_1, _S614) * dot_0(g_n_1, out_dir_2)) > 0.0f;
    float3  _S616 = make_float3 (0.0f);
    float3  _S617 = _S613.throughput * make_float3 (_S613.pdf);
    float _S618 = _slang_select(_S615, -1.0f,1.0f);
    float3  _S619 = _S617 * make_float3 (_S618);
    float3  _S620 = _slang_select(_S612, _S619,_S616);
    return _S620;
}

__device__ float3  translucentBSDF(float3  in_dir_7, float3  out_dir_3, float3  n_12, float3  g_n_2, BSDFMaterial material_13, float eta_i_7, float eta_o_7, uint random_state_12)
{
    float3  _S621 = BSDF(in_dir_7, out_dir_3, n_12, g_n_2, material_13, eta_i_7, eta_o_7, random_state_12);
    float3  _S622 = translucentCorrection(in_dir_7, out_dir_3, n_12, g_n_2, material_13, eta_i_7, eta_o_7, random_state_12);
    return _S621 + _S622;
}

static __device__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_0, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_14, float eta_i_8, float eta_o_8, bool competing_0, uint random_state_13)
{
    bool _S623 = !competing_0;
    bool _S624;
    if(_S623)
    {
        _S624 = true;
    }
    else
    {
        _S624 = (light_0->density) == 0.0f;
    }
    if(_S624)
    {
        bool _S625 = isTranslucent_0(material_14);
        if(_S625)
        {
            float3  _S626 = translucentBSDF(in_dir_8, light_0->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_8, eta_o_8, random_state_13);
            return _S626 * light_0->radiance;
        }
        float3  _S627 = BSDF(in_dir_8, light_0->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_8, eta_o_8, random_state_13);
        return _S627 * light_0->radiance;
    }
    float3  _S628 = light_0->dir;
    bool _S629 = (dot_0(geometry_n_4, - in_dir_8) * dot_0(geometry_n_4, light_0->dir)) <= 0.0f;
    float3  _S630 = neeBSDF(in_dir_8, _S628, smooth_n_5, *material_14, eta_i_8, eta_o_8, _S629, light_0->density, true, random_state_13);
    return _S630 * light_0->radiance * make_float3 (light_0->density);
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S631 = (F32_sqrt((random_1_0)));
    float _S632 = 6.28318548202514648f * random_2_0;
    float _S633 = _S631 * (F32_cos((_S632)));
    float _S634 = _S631 * (F32_sin((_S632)));
    float _S635 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S633 * _S633 - _S634 * _S634))))));
    return make_float3 (_S633, _S635, _S634);
}

static __device__ float3  reflect_0(float3  i_8, float3  n_13)
{
    return i_8 - make_float3 (2.0f * dot_0(n_13, i_8)) * n_13;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_9, float3  n_14, BSDFMaterial material_15, float eta_i_9, float eta_o_9, uint random_init_1, float2  screen_space_0)
{
    uint random_state_14 = random_init_1;
    float3  _S636 = negate_0(in_dir_9);
    float _S637 = dot_0(n_14, _S636);
    float _S638 = sign_0(_S637);
    float3  n_i_4 = n_14 * make_float3 (_S638);
    float _S639 = (F32_abs((_S637)));
    float _S640 = material_15.roughness;
    float _S641 = _S640 * _S640;
    AnisotropicFrame _S642 = anisotropicFrame(material_15, n_i_4);
    float3  _S643 = sampleMaterialHalfVector(_S636, n_i_4, _S641, _S642, &random_state_14);
    BSDFLobes _S644 = bsdfLobes(in_dir_9, _S636, n_i_4, _S643, material_15, eta_i_9, eta_o_9, _S642);
    BSDFLobes lobes_3 = _S644;
    float _S645 = translucentShare(material_15);
    (&lobes_3)->translucent_share = _S645;
    float3  _S646 = make_float3 (1.0f);
    SampleBSDF _S647 = SampleBSDF_x24init_0(_S646, _S646, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S647;
    Random _S648 = pcg(random_state_14);
    random_state_14 = _S648.state;
    bool _S649 = (_S648.value) < ((&lobes_3)->p_diffuse);
    if(_S649)
    {
        Random _S650 = pcg(random_state_14);
        Random _S651 = pcg(_S650.state);
        (&sample_1)->random_state = _S651.state;
        float3  _S652 = sampleCosWeightedHemisphere(_S650.value, _S651.value);
        bool _S653 = (_S648.value) < ((&lobes_3)->p_diffuse * (&lobes_3)->translucent_share);
        float _S654 = _S652.y;
        float _S655 = - _S654;
        float _S656 = _slang_select(_S653, _S655,_S654);
        float3  _S657 = tangentToWorld(make_float3 (_S652.x, _S656, _S652.z), n_i_4);
        (&sample_1)->unit_direction = _S657;
        float3  _S658 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S641, material_15, lobes_3, 0U);
        (&sample_1)->throughput = _S658;
        float _S659 = lobeDensity(_S656, 0.0f, _S639, _S641, lobes_3, eta_i_9, eta_o_9, 0U);
        (&sample_1)->pdf = _S659;
        (&sample_1)->refracted = _S653;
        return sample_1;
    }
    bool _S660 = (_S648.value) < ((&lobes_3)->p_diffuse + (&lobes_3)->p_refract);
    if(_S660)
    {
        (&sample_1)->unit_direction = (&lobes_3)->refracted;
        float _S661 = lobeDensity(0.0f, dot_0((&sample_1)->unit_direction, _S643), _S639, _S641, lobes_3, eta_i_9, eta_o_9, 1U);
        (&sample_1)->pdf = _S661;
        float3  _S662 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S641, material_15, lobes_3, 1U);
        (&sample_1)->throughput = _S662;
        (&sample_1)->random_state = random_state_14;
        (&sample_1)->refracted = true;
        (&sample_1)->lobe = 1U;
        return sample_1;
    }
    float3  _S663 = reflect_0(in_dir_9, _S643);
    float3  _S664 = ((((_S663)) * make_float3(rnorm3df(((_S663)).x, ((_S663)).y, ((_S663)).z))));
    (&sample_1)->unit_direction = _S664;
    float3  _S665 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S641, material_15, lobes_3, 2U);
    (&sample_1)->throughput = _S665;
    (&sample_1)->random_state = random_state_14;
    (&sample_1)->lobe = 2U;
    float _S666 = lobeDensity(0.0f, 0.0f, _S639, _S641, lobes_3, eta_i_9, eta_o_9, 2U);
    (&sample_1)->pdf = _S666;
    return sample_1;
}

__device__ bool withinInverseFootprint(float pdf_6, bool diffuse_0, float prev_cos_0, float distance_4, float threshold_1)
{
    bool _S667 = pdf_6 > 0.0f;
    bool _S668;
    if(_S667)
    {
        if(diffuse_0)
        {
            _S668 = true;
        }
        else
        {
            _S668 = (pdf_6 * prev_cos_0 / (distance_4 * distance_4) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S668 = false;
    }
    return _S668;
}

__device__ bool roughLobe(float pdf_7, bool diffuse_1, float roughness_1)
{
    bool _S669 = pdf_7 > 0.0f;
    bool _S670;
    if(_S669)
    {
        if(diffuse_1)
        {
            _S670 = true;
        }
        else
        {
            _S670 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S670 = false;
    }
    return _S670;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S671 = layers_0 > 1U;
    bool _S672;
    if(_S671)
    {
        _S672 = refracting_0 != passed_0;
    }
    else
    {
        _S672 = false;
    }
    return _S672;
}

static __device__ float widened_0(float spread_0, float pdf_8, bool delta_0)
{
    float _S673 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_8))))), (3.14159274101257324f)));
    bool _S674 = !delta_0;
    float _S675 = _slang_select(_S674, _S673,0.0f);
    return spread_0 + _S675;
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
    int _S676;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_3;
    float sky_pdf_1;
    float width_4;
    uint b_5;
    float spread_3;
    Shift arrived_end_0;
    float3  _S677 = make_float3 (0.0f);
    Shift _S678 = Shift_x24init_0(_S677, 0.0f);
    uint _S679 = r_3->path;
    uint _S680 = extractBits_0(r_3->path, 0U, 5U);
    uint _S681 = extractBits_0(_S679, 5U, 5U);
    uint _S682 = extractBits_0(_S679, 10U, 2U);
    uint _S683 = extractBits_0(_S679, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S684 = _S683 >= 3U;
        uint _S685 = _slang_select(_S684, 1U,0U);
        uint _S686 = _S680 + _S685;
        uint _S687 = (fcptMaxBounces());
        passes_0 = _S686 > _S687;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S678;
    }
    uint _S688 = _S681 - 1U;
    bool _S689 = _S683 == 3U;
    uint _S690 = _slang_select(_S689, 1U,0U);
    uint _S691 = _S680 + _S690;
    bool _S692 = _S682 == 0U;
    uint _S693 = _slang_select(_S692, _S691,_S688);
    FKHit _S694 = (fcptReservoirHit((*r_3)));
    float3  _S695 = dom_0->x0;
    float3  _S696 = dom_0->x1 - dom_0->x0;
    float3  _S697 = ((((_S696)) * make_float3(rnorm3df(((_S696)).x, ((_S696)).y, ((_S696)).z))));
    FKRay _S698 = Ray_x24init_0(dom_0->x1, _S697);
    FKRay ray_2 = _S698;
    FKHit hit_1 = dom_0->hit;
    float3  scatter_in_0 = _S677;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S677;
    float3  extinction_in_0 = _S677;
    uint filling_2 = 4294967295U;
    float _S699 = dom_0->spread;
    float _S700 = dom_0->width;
    float _S701 = length_0(_S696);
    NEEVertex _S702 = NEEVertex_x24init_0(true, 0.0f, _S677, _S677, _S677);
    NEEVertex nee_vertex_0 = _S702;
    Vertex _S703 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S703;
    Reservoir _S704 = (Reservoir{});
    Reservoir chain_0 = _S704;
    uint _S705 = r_3->seed;
    (&chain_0)->seed = r_3->seed;
    (&ray_2)->origin = _S695;
    (&hit_1)->distance = _S701;
    FKMedium _S706 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_1)->distance), (&filling_2)));
    scatter_in_0 = _S706.scatter;
    extinction_in_0 = _S706.extinction;
    Reservoir _S707 = chain_0;
    uint _S708 = filling_2;
    for(;;)
    {
        bool _S709 = _S708 != 4294967295U;
        float _S710 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        float _S711 = (fcptMajorant((_S708)));
        float _S712 = _slang_select(_S709, _S711,_S710);
        if(replay_1)
        {
            passes_0 = 4294967295U == _S693;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            passes_0 = _S682 == 1U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            passes_0 = _S712 > 0.0f;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            ended_0 = _S678;
            sky_pdf_0 = 0.0f;
            spread_1 = _S699;
            width_2 = _S700;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_4 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S713 = (&prev_0)->rough;
        if(_S713)
        {
            passes_0 = !(_S712 > 0.0f);
        }
        else
        {
            passes_0 = false;
        }
        (&prev_0)->rough = passes_0;
        uint _S714 = stream(_S705, 384U);
        uint tracking_0 = _S714;
        weight_1 = throughput_3;
        glowed_0 = _S677;
        b_4 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        spread_1 = _S699;
        width_2 = _S700;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_1)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S676 = int(1);
                break;
            }
            uint _S715 = b_4 + 320U;
            bool _S716 = b_4 == 4294967295U;
            uint _S717 = _slang_select(_S716, 384U,_S715);
            uint _S718 = stream(_S705, _S717);
            Random _S719 = pcg(_S718);
            float _S720 = freeFlight_0(_S719.value, _S712);
            if(_S709)
            {
                float3  _S721 = (&ray_2)->origin;
                float3  _S722 = (&ray_2)->unit_direction;
                float _S723 = (&hit_1)->distance;
                uint _S724 = _slang_select(_S716, 0U,b_4);
                uint _S725 = (&prev_0)->lobe;
                uint _S726 = _slang_select(_S716, 3U,_S725);
                float _S727 = (fcptTrackMedium((_S708), (_S721), (_S722), (_S723), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S724), (_S726)));
                threshold_2 = _S727;
            }
            else
            {
                threshold_2 = _S720;
            }
            bool _S728 = !(threshold_2 < ((&hit_1)->distance));
            if(_S728)
            {
                _S676 = int(1);
                break;
            }
            if(_S709)
            {
                passes_0 = !replay_1;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                float3  _S729 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S730 = sel_1->glow + _S729;
                sel_1->glow = _S730;
            }
            else
            {
            }
            glowed_0 = _S677;
            uint b_6 = b_4 + 1U;
            float3  _S731 = (&ray_2)->origin + make_float3 (threshold_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S731;
            float3  _S732 = flightWeight_0(scatter_in_0, extinction_in_0, _S712, threshold_2, true);
            float3  _S733 = weight_1;
            float3  _S734 = _slang_select(_S709, _S733,_S732);
            float3  throughput_4 = throughput_2 * _S734;
            uint _S735 = stream(_S705, b_6 + 320U);
            tracking_0 = _S735;
            weight_1 = throughput_3;
            float width_5 = width_2 + spread_1 * threshold_2;
            float _S736 = spread_1 + 3.14159274101257324f;
            uint _S737 = stream(_S705, b_6 + 64U);
            uint2  _S738 = make_uint2 (_S708);
            uint _S739 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            ShadowContext _S740 = ShadowContext_x24init_0(extinction_in_0, extinction_in_0, _S738, (&ray_2)->unit_direction, b_6, _S739, false, threshold_2, width_5);
            TreeSample _S741 = sampleLightTree_0((&ray_2)->origin, (&ray_2)->unit_direction, (&ray_2)->unit_direction, 0.0f, true, _S737, &_S740);
            bool _S742 = scatterSampled_0(replay_1, b_6, _S693, _S709);
            uint _S743 = (fcptMaxBounces());
            bool _S744 = b_6 < _S743;
            if(_S744)
            {
                is_inside_5 = (_S741.density) > 0.0f;
            }
            else
            {
                is_inside_5 = false;
            }
            float _S745 = _slang_select(is_inside_5, 0.07957746833562851f,0.0f);
            float3  _S746 = throughput_4 * _S741.radiance;
            float _S747 = powerHeuristic(_S741.density, _S745);
            float3  _S748 = _S746 * make_float3 (0.07957746833562851f * _S747);
            float3  _S749 = _slang_select(_S742, _S748,_S677);
            if(replay_1)
            {
                turned_1 = b_6 == _S693;
            }
            else
            {
                turned_1 = false;
            }
            if(turned_1)
            {
                bool _S750 = _S682 == 2U;
                if(_S750)
                {
                    float _S751 = rgb_to_greyscale(_S749);
                    passes_0 = _S751 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S752 = Shift_x24init_0(_S749, 1.0f);
                    _S676 = int(0);
                    ended_0 = _S752;
                    threshold_2 = _S736;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                _S676 = int(0);
                ended_0 = _S678;
                threshold_2 = _S736;
                geometry_density_2 = width_5;
                chain_throughput_0 = throughput_4;
                layer_0 = b_6;
                break;
            }
            bool _S753 = !replay_1;
            if(_S753)
            {
                Reservoir candidate_2 = _S707;
                uint _S754 = extractBits_0(_S707.path, 10U, 2U);
                bool _S755 = _S754 == 1U;
                if(_S755)
                {
                    float3  _S756 = safeDivide(_S749, _S677);
                    (&candidate_2)->radiance = _S756;
                }
                else
                {
                    uint _S757 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                    uint _S758 = insertBits_0(_S757, 2U, 10U, 2U);
                    (&candidate_2)->path = _S758;
                }
                Reservoir _S759 = withEnd(candidate_2, 0U, b_6, _S749);
                offer(sel_1, _S759, _S749 * make_float3 (scale_1) / make_float3 (density_2));
                float _S760 = survivalProbability(throughput_4, density_2);
                uint _S761 = stream(_S705, b_6 + 128U);
                Random _S762 = pcg(_S761);
                bool _S763 = _S760 < (_S762.value);
                if(_S763)
                {
                    scatter_2 = true;
                }
                else
                {
                    uint _S764 = (fcptMaxBounces());
                    scatter_2 = b_6 >= _S764;
                }
                if(scatter_2)
                {
                    _S676 = int(0);
                    ended_0 = _S678;
                    threshold_2 = _S736;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                float _S765 = density_2 * _S760;
                density_2 = _S765;
            }
            else
            {
            }
            NEEVertex _S766 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_2)->origin, _S677, (&ray_2)->origin);
            nee_vertex_0 = _S766;
            uint _S767 = stream(_S705, b_6);
            float3  _S768 = isotropic_0(_S767);
            (&ray_2)->unit_direction = _S768;
            Vertex _S769 = scatteredVertex_0(false);
            prev_0 = _S769;
            float _S770 = (&prev_0)->pdf;
            FKHit _S771 = (fcptTraverseInstanceBVH((ray_2), (true), (4.294967296e+09f), (false)));
            hit_1 = _S771;
            b_4 = b_6;
            throughput_2 = throughput_4;
            spread_1 = _S736;
            width_2 = width_5;
            sky_pdf_0 = _S770;
        }
        if(_S676 != int(1))
        {
            spread_1 = threshold_2;
            width_2 = geometry_density_2;
            throughput_2 = chain_throughput_0;
            b_4 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S678;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    Reservoir _S772 = chain_0;
    NEEVertex _S773 = nee_vertex_0;
    Vertex _S774 = prev_0;
    FKHit _S775 = hit_1;
    uint _S776 = filling_2;
    float3  _S777 = scatter_in_0;
    float3  _S778 = extinction_in_0;
    float3  _S779 = weight_1;
    float3  _S780 = glowed_0;
    for(;;)
    {
        bool _S781 = (_S775.instance_index) == 4294967295U;
        if(_S781)
        {
            bool _S782 = !_S773.none;
            float _S783 = _slang_select(_S782, sky_pdf_0,0.0f);
            float _S784 = escapeWeight_0(_S783, (&ray_2)->unit_direction);
            float3  _S785 = environment_0((&ray_2)->unit_direction, b_4, _S774.lobe);
            float3  _S786 = throughput_2 * _S785;
            if(replay_1)
            {
                bool _S787 = b_4 == _S693;
                if(_S787)
                {
                    passes_0 = _S682 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S788 = Shift_x24init_0(_S786 * make_float3 (_S784) / make_float3 (r_3->jac), density_2 / r_3->jac);
                    ended_0 = _S788;
                    passes_0 = true;
                    break;
                }
                if(_S692)
                {
                    passes_0 = _S689;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_4 == _S680;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S774.rough;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S789 = Shift_x24init_0(_S786 * make_float3 (_S784), 1.0f);
                    ended_0 = _S789;
                    passes_0 = true;
                    break;
                }
                ended_0 = _S678;
                passes_0 = true;
                break;
            }
            Reservoir candidate_3 = _S772;
            uint _S790 = extractBits_0(_S772.path, 10U, 2U);
            bool _S791 = _S790 == 1U;
            if(_S791)
            {
                uint _S792 = extractBits_0(_S772.path, 5U, 5U);
                bool _S793 = _S792 == b_4;
                float _S794 = _slang_select(_S793, 1.0f,_S784);
                float3  _S795 = safeDivide(_S786 * make_float3 (_S794), _S677);
                (&candidate_3)->radiance = _S795;
            }
            else
            {
                if(_S774.rough)
                {
                    uint _S796 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                    uint _S797 = insertBits_0(_S796, 3U, 10U, 2U);
                    uint _S798 = insertBits_0(_S797, _S774.lobe, 15U, 2U);
                    uint _S799 = _slang_select(_S774.inside, 1U,0U);
                    uint _S800 = insertBits_0(_S798, _S799, 20U, 1U);
                    (&candidate_3)->path = _S800;
                    (&candidate_3)->jac = _S774.pdf;
                    (&candidate_3)->dir = (&ray_2)->unit_direction;
                }
                else
                {
                }
            }
            float3  _S801 = _S786 * make_float3 (_S784);
            Reservoir _S802 = withEnd(candidate_3, 3U, b_4, _S801);
            offer(sel_1, _S802, _S801 * make_float3 (scale_1) / make_float3 (density_2));
            ended_0 = _S678;
            passes_0 = true;
            break;
        }
        float3  _S803 = (&ray_2)->origin + make_float3 (_S775.distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S803;
        bool _S804 = _S776 != 4294967295U;
        if(_S804)
        {
            bool _S805 = !replay_1;
            if(_S805)
            {
                float3  _S806 = throughput_2 * _S780 / make_float3 (density_2);
                float3  _S807 = sel_1->glow + _S806;
                sel_1->glow = _S807;
            }
            else
            {
            }
            float3  _S808 = throughput_2 * _S779;
            throughput_2 = _S808;
        }
        else
        {
            float3  _S809 = flightWeight_0(_S777, _S778, (_S777.x + _S777.y + _S777.z) / 3.0f, _S775.distance, false);
            float3  _S810 = throughput_2 * _S809;
            throughput_2 = _S810;
        }
        float _S811 = width_2 + spread_1 * _S775.distance;
        ended_0 = _S678;
        width_2 = _S811;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    uint _S812 = b_4 + 1U;
    b_4 = _S812;
    layer_0 = 0U;
    passes_0 = false;
    is_inside_5 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    chain_throughput_0 = _S677;
    float3  reconnection_0 = _S677;
    for(;;)
    {
        bool _S813 = ((&hit_1)->is_point_light) == 1U;
        FKMedium _S814 = Medium_x24init_0(_S677, _S677);
        BSDFMaterial _S815 = Material_x24init_0(_S677, _S677, 0.0f, 0.0f, 0.0f, 0.0f, _S677, throughput_3, 1.0f, _S677, _S677, 0.5f, 0.0f, 0.0f, _S677);
        FKMedium _S816 = _S814;
        FKSurface _S817 = Surface_x24init_0(_S677, _S677, 0.0f, &_S815, false, 0U, 1.0f, false, &_S816, 4294967295U);
        bool _S818 = !_S813;
        bool is_inside_6;
        float3  front_n_0;
        float3  throughput_5;
        FKSurface surface_10;
        if(_S818)
        {
            uint _S819 = stream(_S705, b_4);
            uint _S820 = arrivalLobe_0(b_4, (&prev_0)->lobe);
            FKSurface _S821 = (fcptSurfaceAtPath((hit_1), ((&ray_2)->origin), (_S819), (width_2), (layer_0), (b_4), (_S820), ((&ray_2)->unit_direction)));
            bool _S822 = !passes_0;
            FKSurface _S823 = _S821;
            FKSurface _S824 = emitting_0(&_S823, _S822);
            uint _S825 = stream(_S705, b_4 + 256U);
            Random _S826 = pcg(_S825);
            FKSurface _S827 = _S824;
            FKSurface _S828 = uncovered_0(&_S827, _S826.value);
            float _S829 = facingSign(_S828.material.transmission, _S828.geometry_n, (&ray_2)->unit_direction);
            bool _S830 = _S829 < 0.0f;
            FKSurface _S831 = _S828;
            FKSurface _S832 = facingRay_0(&_S831, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S833 = arrivesBehind_0((&ray_2)->unit_direction, _S832.geometry_n);
                scatter_2 = _S833;
            }
            else
            {
                scatter_2 = is_inside_5;
            }
            if(scatter_2)
            {
                float3  _S834 = beerLambert((&hit_1)->distance, _S832.material.absorption);
                float3  _S835 = throughput_2 * _S834;
                front_n_0 = _S835;
            }
            else
            {
                front_n_0 = throughput_2;
            }
            bool _S836 = !_S832.skip;
            float geometry_density_3 = geometryDensity(_S832.geometry_n, (&ray_2)->unit_direction, (&hit_1)->distance);
            bool _S837 = b_4 == _S812;
            if(_S837)
            {
                float _S838 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S838;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            bool _S839 = scatter_2;
            float3  _S840 = front_n_0;
            float _S841 = geometry_density_2;
            scatter_2 = _S836;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S841;
            surface_10 = _S832;
            front_n_0 = _S828.smooth_n;
            throughput_5 = _S840;
            turned_1 = _S830;
            is_inside_6 = _S839;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_10 = _S817;
            front_n_0 = _S677;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S842 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S843 = surface_10;
        FKSurface _S844 = surface_10;
        float _S845 = dot_0(surface_10.smooth_n, - (&ray_2)->unit_direction);
        BSDFMaterial _S846 = _S843.material;
        float2  _S847 = vertexEta_0(&_S846, _S845);
        bool _S848;
        if(scatter_2)
        {
            bool _S849 = samplesLights(_S843.material);
            _S848 = _S849;
        }
        else
        {
            _S848 = false;
        }
        bool _S850;
        if(passes_0)
        {
            _S850 = true;
        }
        else
        {
            _S850 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S850)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S848;
        }
        float3  _S851 = sideNormal(surface_10, (&ray_2)->unit_direction);
        float _S852 = sign_0(dot_0(- (&ray_2)->unit_direction, front_n_0));
        float3  _S853 = _S843.material.emissive * make_float3 ((F32_max((_S852), (0.0f))));
        float3  emission_0;
        if(_S813)
        {
            float3  _S854 = (fcptCalculatePointLightContrib(((&hit_1)->instance_index)));
            emission_0 = _S854;
        }
        else
        {
            emission_0 = _S853;
        }
        float _S855 = rgb_to_greyscale(emission_0);
        bool _S856 = _S855 > 0.0f;
        float3  emission_1;
        if(_S856)
        {
            NEEVertex _S857 = nee_vertex_0;
            FKHit _S858 = hit_1;
            float _S859 = emissionWeight_0(&_S857, &_S858, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S859);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S860;
        if(replay_1)
        {
            _S860 = _S682 == 1U;
        }
        else
        {
            _S860 = false;
        }
        bool _S861;
        if(_S860)
        {
            _S861 = b_4 > _S681;
        }
        else
        {
            _S861 = false;
        }
        bool _S862;
        if(_S861)
        {
            _S862 = b_4 == _S680;
        }
        else
        {
            _S862 = false;
        }
        bool _S863;
        if(_S862)
        {
            bool _S864 = _S683 == 1U;
            if(_S864)
            {
                _S863 = true;
            }
            else
            {
                _S863 = _S683 == 2U;
            }
        }
        else
        {
            _S863 = false;
        }
        if(_S863)
        {
            bool _S865 = _S813 != (_S683 == 2U);
            if(_S865)
            {
                return _S678;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_3->jac), density_2 / r_3->jac);
        }
        uint _S866 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S867 = _S866 == 1U;
        Reservoir here_0 = chain_0;
        uint _S868 = insertBits_0(0U, b_4, 5U, 5U);
        uint _S869 = insertBits_0(_S868, 1U, 10U, 2U);
        uint _S870 = insertBits_0(_S869, (&prev_0)->lobe, 15U, 2U);
        bool _S871 = (&prev_0)->inside;
        uint _S872 = _slang_select(_S871, 1U,0U);
        uint _S873 = insertBits_0(_S870, _S872, 20U, 1U);
        (&here_0)->path = _S873;
        float _S874 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S874;
        fcptWithReservoirHit((&here_0), (&hit_1));
        bool _S875;
        if(replay_1)
        {
            _S875 = _S682 == 1U;
        }
        else
        {
            _S875 = false;
        }
        bool _S876;
        if(_S875)
        {
            _S876 = b_4 == _S681;
        }
        else
        {
            _S876 = false;
        }
        bool _S877;
        bool wrong_side_0;
        bool refracted_4;
        bool _S878;
        bool _S879;
        float3  throughput_6;
        float density_4;
        if(_S876)
        {
            bool _S880 = ((&hit_1)->instance_index) != (_S694.instance_index);
            if(_S880)
            {
                _S877 = true;
            }
            else
            {
                _S877 = ((&hit_1)->triangle_index) != (_S694.triangle_index);
            }
            if(_S877)
            {
                wrong_side_0 = true;
            }
            else
            {
                wrong_side_0 = !_S842;
            }
            if(wrong_side_0)
            {
                return _S678;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            bool _S881 = _S681 == _S680;
            if(_S881)
            {
                refracted_4 = _S683 == 1U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            if(_S881)
            {
                _S878 = _S683 == 0U;
            }
            else
            {
                _S878 = false;
            }
            if(_S878)
            {
                BSDFMaterial _S882 = _S843.material;
                bool _S883 = isTranslucent_0(&_S882);
                uint _S884 = stream(_S705, b_4 + 64U);
                uint _S885 = arrivalLobe_0(b_4, (&prev_0)->lobe);
                FKSurface _S886 = surface_10;
                ShadowContext _S887 = shadowContext_0(&_S886, turned_1, _S851, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_4, _S885, (&hit_1)->distance, width_2);
                ShadowContext _S888 = _S887;
                TreeSample _S889 = sampleLightTree_0((&ray_2)->origin, _S844.smooth_n, surface_10.geometry_n, surface_10.geometry_offset, _S883, _S884, &_S888);
                bool _S890 = !nee_0;
                if(_S890)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S891 = rgb_to_greyscale(_S889.radiance);
                    passes_0 = !(_S891 > 0.0f);
                }
                if(passes_0)
                {
                    return _S678;
                }
                float _S892 = _S847.x;
                float _S893 = _S847.y;
                uint _S894 = (fcptMaxBounces());
                bool _S895 = b_4 < _S894;
                TreeSample _S896 = _S889;
                BSDFMaterial _S897 = _S843.material;
                float3  _S898 = lightBSDF_0((&ray_2)->unit_direction, &_S896, _S844.smooth_n, _S851, &_S897, _S892, _S893, _S895, surface_10.random_state);
                return Shift_x24init_0(throughput_7 * _S898 / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            if(_S881)
            {
                _S879 = _S683 == 4U;
            }
            else
            {
                _S879 = false;
            }
            if(_S879)
            {
                bool _S899 = !nee_0;
                if(_S899)
                {
                    return _S678;
                }
                float _S900 = environmentPdf_0(r_3->dir);
                float3  _S901 = skyBSDF((&ray_2)->unit_direction, r_3->dir, surface_10, _S851, _S847, is_inside_6, _S900, surface_10.random_state);
                return Shift_x24init_0(throughput_7 * _S901 * r_3->radiance / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            uint _S902 = extractBits_0(_S679, 19U, 1U);
            bool _S903 = nee_0 != (_S902 == 1U);
            if(_S903)
            {
                return _S678;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                _S877 = b_4 == _S693;
            }
            else
            {
                _S877 = false;
            }
            if(_S877)
            {
                bool _S904 = !scatter_2;
                if(_S904)
                {
                    wrong_side_0 = true;
                }
                else
                {
                    bool _S905 = _S682 != 1U;
                    if(_S905)
                    {
                        wrong_side_0 = _S682 != 3U;
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
                bool _S906 = _S682 == 2U;
                if(_S906)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S842;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S683 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    uint _S907 = stream(_S705, b_4 + 448U);
                    FKRay _S908 = ray_2;
                    FKSurface _S909 = surface_10;
                    SkySample _S910 = sampleSky_0(&_S908, &_S909, _S851, _S847, is_inside_6, _S907, surface_10.random_state);
                    return Shift_x24init_0(throughput_5 * _S910.color, 1.0f);
                }
                if(_S906)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S842;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    BSDFMaterial _S911 = _S843.material;
                    bool _S912 = isTranslucent_0(&_S911);
                    uint _S913 = stream(_S705, b_4 + 64U);
                    uint _S914 = arrivalLobe_0(b_4, (&prev_0)->lobe);
                    FKSurface _S915 = surface_10;
                    ShadowContext _S916 = shadowContext_0(&_S915, turned_1, _S851, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_4, _S914, (&hit_1)->distance, width_2);
                    ShadowContext _S917 = _S916;
                    TreeSample _S918 = sampleLightTree_0((&ray_2)->origin, _S844.smooth_n, surface_10.geometry_n, surface_10.geometry_offset, _S912, _S913, &_S917);
                    float _S919 = rgb_to_greyscale(_S918.radiance);
                    bool _S920 = !(_S919 > 0.0f);
                    if(_S920)
                    {
                        return _S678;
                    }
                    float _S921 = _S847.x;
                    float _S922 = _S847.y;
                    uint _S923 = (fcptMaxBounces());
                    bool _S924 = b_4 < _S923;
                    TreeSample _S925 = _S918;
                    BSDFMaterial _S926 = _S843.material;
                    float3  _S927 = lightBSDF_0((&ray_2)->unit_direction, &_S925, _S844.smooth_n, _S851, &_S926, _S921, _S922, _S924, surface_10.random_state);
                    return Shift_x24init_0(throughput_5 * _S927, 1.0f);
                }
                if(_S692)
                {
                    passes_0 = _S683 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S813;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S692)
                {
                    passes_0 = _S683 == 1U;
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
                    passes_0 = !_S842;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S678;
            }
            else
            {
                bool _S928 = !replay_1;
                if(_S928)
                {
                    refracted_4 = scatter_2;
                }
                else
                {
                    refracted_4 = false;
                }
                if(refracted_4)
                {
                    bool _S929 = b_4 > 0U;
                    if(_S929)
                    {
                        Reservoir candidate_4 = chain_0;
                        if(_S867)
                        {
                            float3  _S930 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_4)->radiance = _S930;
                        }
                        else
                        {
                            if(_S842)
                            {
                                candidate_4 = here_0;
                            }
                        }
                        float3  _S931 = throughput_5 * emission_1;
                        Reservoir _S932 = withEnd(candidate_4, 1U, b_4, _S931);
                        offer(sel_1, _S932, _S931 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S933 = throughput_5 * emission_1;
                        float3  _S934 = sel_1->glow + _S933;
                        sel_1->glow = _S934;
                    }
                    if(nee_0)
                    {
                        BSDFMaterial _S935 = _S843.material;
                        bool _S936 = isTranslucent_0(&_S935);
                        uint _S937 = stream(_S705, b_4 + 64U);
                        uint _S938 = arrivalLobe_0(b_4, (&prev_0)->lobe);
                        FKSurface _S939 = surface_10;
                        ShadowContext _S940 = shadowContext_0(&_S939, turned_1, _S851, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_4, _S938, (&hit_1)->distance, width_2);
                        ShadowContext _S941 = _S940;
                        TreeSample _S942 = sampleLightTree_0((&ray_2)->origin, _S844.smooth_n, surface_10.geometry_n, surface_10.geometry_offset, _S936, _S937, &_S941);
                        float _S943 = _S847.x;
                        float _S944 = _S847.y;
                        uint _S945 = (fcptMaxBounces());
                        bool _S946 = b_4 < _S945;
                        TreeSample _S947 = _S942;
                        BSDFMaterial _S948 = _S843.material;
                        float3  _S949 = lightBSDF_0((&ray_2)->unit_direction, &_S947, _S844.smooth_n, _S851, &_S948, _S943, _S944, _S946, surface_10.random_state);
                        float3  _S950 = throughput_5 * _S949;
                        Reservoir candidate_5 = chain_0;
                        if(_S867)
                        {
                            float3  _S951 = safeDivide(_S950, chain_throughput_0);
                            (&candidate_5)->radiance = _S951;
                        }
                        else
                        {
                            if(_S842)
                            {
                                candidate_5 = here_0;
                                uint _S952 = insertBits_0((&candidate_5)->path, 1U, 19U, 1U);
                                (&candidate_5)->path = _S952;
                                (&candidate_5)->dir = _S942.dir;
                                (&candidate_5)->radiance = _S942.radiance;
                            }
                            else
                            {
                                uint _S953 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S954 = insertBits_0(_S953, 2U, 10U, 2U);
                                (&candidate_5)->path = _S954;
                            }
                        }
                        Reservoir _S955 = withEnd(candidate_5, 0U, b_4, _S950);
                        offer(sel_1, _S955, _S950 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        bool _S956 = environmentMapped_0();
                        _S878 = _S956;
                    }
                    else
                    {
                        _S878 = false;
                    }
                    if(_S878)
                    {
                        uint _S957 = (fcptMaxBounces());
                        _S879 = b_4 < _S957;
                    }
                    else
                    {
                        _S879 = false;
                    }
                    if(_S879)
                    {
                        uint _S958 = stream(_S705, b_4 + 448U);
                        FKRay _S959 = ray_2;
                        FKSurface _S960 = surface_10;
                        SkySample _S961 = sampleSky_0(&_S959, &_S960, _S851, _S847, is_inside_6, _S958, surface_10.random_state);
                        float3  _S962 = throughput_5 * _S961.color;
                        Reservoir candidate_6 = chain_0;
                        if(_S867)
                        {
                            float3  _S963 = safeDivide(_S962, chain_throughput_0);
                            (&candidate_6)->radiance = _S963;
                        }
                        else
                        {
                            if(_S842)
                            {
                                candidate_6 = here_0;
                                uint _S964 = insertBits_0((&candidate_6)->path, 1U, 19U, 1U);
                                (&candidate_6)->path = _S964;
                                (&candidate_6)->dir = _S961.dir;
                                (&candidate_6)->radiance = _S961.radiance;
                            }
                            else
                            {
                                uint _S965 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S966 = insertBits_0(_S965, 2U, 10U, 2U);
                                (&candidate_6)->path = _S966;
                            }
                        }
                        Reservoir _S967 = withEnd(candidate_6, 4U, b_4, _S962);
                        offer(sel_1, _S967, _S962 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
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
        bool _S978;
        bool _S979;
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
                _S877 = b_4 == _S693;
            }
            else
            {
                _S877 = false;
            }
            uint _S980 = extractBits_0(_S679, 15U, 2U);
            uint _S981 = extractBits_0(_S679, 17U, 2U);
            uint _S982 = _slang_select(_S876, _S981,_S980);
            float3  _S983 = r_3->dir;
            bool refracted_5 = _S982 == 1U;
            SampleBSDF _S984 = SampleBSDF_x24init_0(_S677, _S677, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_10 = _S984;
            float3  reconnection_1;
            if(_S877)
            {
                uint _S985 = extractBits_0(_S679, 20U, 1U);
                bool _S986 = is_inside_6 != (_S985 == 1U);
                if(_S986)
                {
                    return _S678;
                }
                bool _S987 = _S682 == 1U;
                if(_S987)
                {
                    float3  _S988 = (fcptHitPosition((_S694)));
                    throughput_8 = _S988;
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
                    BSDFMaterial _S989 = _S843.material;
                    bool _S990 = isTranslucent_0(&_S989);
                    if(_S990)
                    {
                        wrong_side_0 = _S982 == 0U;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        float3  _S991 = throughput_8 - (&ray_2)->origin;
                        float3  _S992 = _slang_select(_S987, _S991,_S983);
                        refracted_4 = (dot_0(_S844.smooth_n, _S992) * _S845) < 0.0f;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                }
                if(_S987)
                {
                    float3  _S993 = (&ray_2)->origin;
                    FKSurface _S994 = surface_10;
                    float3  _S995 = - _S844.smooth_n;
                    bool _S996 = is_inside_6 != refracted_4;
                    float3  _S997 = _slang_select(_S996, _S995,_S844.smooth_n);
                    float3  _S998 = throughput_8 - (_S993 + make_float3 (_S994.geometry_offset) * _S997);
                    float3  _S999 = ((((_S998)) * make_float3(rnorm3df(((_S998)).x, ((_S998)).y, ((_S998)).z))));
                    reconnection_1 = _S999;
                }
                else
                {
                    reconnection_1 = _S983;
                }
                bool _S1000 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, _S851);
                if(_S1000)
                {
                    return _S678;
                }
                float3  _S1001 = throughput_8;
                throughput_8 = reconnection_1;
                b_7 = _S982;
                wrong_side_0 = false;
                reconnection_1 = _S1001;
            }
            else
            {
                bool _S1002 = !_S876;
                if(_S1002)
                {
                    float _S1003 = _S847.x;
                    float _S1004 = _S847.y;
                    float2  _S1005 = make_float2 (0.0f);
                    SampleBSDF _S1006 = sampleBSDF((&ray_2)->unit_direction, _S844.smooth_n, _S843.material, _S1003, _S1004, surface_10.random_state, _S1005);
                    SampleBSDF bsdf_sampled_0 = _S1006;
                    bool wrong_side_1 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, _S851);
                    if(wrong_side_1)
                    {
                        wrong_side_0 = (_S843.material.transmission) > 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        SampleBSDF _S1007 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_10.geometry_n, _S843.material, _S1003, _S1004, (&bsdf_sampled_0)->random_state, _S1005);
                        (&bsdf_sampled_0)->unit_direction = _S1007.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1007.refracted;
                        (&bsdf_sampled_0)->throughput = _S1007.throughput;
                    }
                    else
                    {
                        if(wrong_side_1)
                        {
                            float3  _S1008 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_10.geometry_n)) * surface_10.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1008;
                        }
                    }
                    uint _S1009 = (&bsdf_sampled_0)->lobe;
                    float3  _S1010 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1011 = (&bsdf_sampled_0)->refracted;
                    lobe_10 = bsdf_sampled_0;
                    float _S1012 = (&bsdf_sampled_0)->pdf;
                    float _S1013 = _slang_select(wrong_side_1, 0.0f,_S1012);
                    (&lobe_10)->pdf = _S1013;
                    throughput_8 = _S1010;
                    b_7 = _S1009;
                    wrong_side_0 = wrong_side_1;
                    refracted_4 = _S1011;
                }
                else
                {
                    throughput_8 = _S983;
                    b_7 = _S982;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(_S877)
            {
                _S878 = true;
            }
            else
            {
                _S878 = _S876;
            }
            if(_S878)
            {
                SampleBSDF _S1014 = connectBSDF((&ray_2)->unit_direction, throughput_8, _S844.smooth_n, _S843.material, _S847.x, _S847.y, b_7, surface_10.random_state);
                lobe_10 = _S1014;
            }
            bool _S1015 = b_7 != 0U;
            if(_S1015)
            {
                bool _S1016 = (_S843.material.roughness) == 0.0f;
                if(_S1016)
                {
                    _S879 = true;
                }
                else
                {
                    bool _S1017 = b_7 == 1U;
                    if(_S1017)
                    {
                        _S879 = (_S847.x) == (_S847.y);
                    }
                    else
                    {
                        _S879 = false;
                    }
                }
            }
            else
            {
                _S879 = false;
            }
            BSDFMaterial _S1018 = _S843.material;
            bool _S1019 = isTranslucent_0(&_S1018);
            if(_S1019)
            {
                _S968 = b_7 == 0U;
            }
            else
            {
                _S968 = false;
            }
            if(_S968)
            {
                _S969 = (dot_0(throughput_8, surface_10.geometry_n)) < 0.0f;
            }
            else
            {
                _S969 = false;
            }
            if(nee_0)
            {
                _S970 = !_S879;
            }
            else
            {
                _S970 = false;
            }
            if(_S970)
            {
                _S971 = !wrong_side_0;
            }
            else
            {
                _S971 = false;
            }
            if(_S971)
            {
                float _S1020 = (&lobe_10)->pdf;
                float3  _S1021 = (&ray_2)->origin;
                BSDFMaterial _S1022 = _S843.material;
                bool _S1023 = isTranslucent_0(&_S1022);
                float3  _S1024 = _slang_select(_S1023, _S677,_S844.smooth_n);
                float3  _S1025 = (&ray_2)->origin;
                FKSurface _S1026 = surface_10;
                float3  _S1027 = - _S844.smooth_n;
                float3  _S1028 = _slang_select(_S969, _S1027,_S844.smooth_n);
                NEEVertex _S1029 = NEEVertex_x24init_0(false, _S1020, _S1021, _S1024, _S1025 + make_float3 (_S1026.geometry_offset) * _S1028);
                nee_vertex_0 = _S1029;
            }
            else
            {
                bool _S1030 = b_7 != 1U;
                if(_S1030)
                {
                    _S972 = true;
                }
                else
                {
                    _S972 = (_S847.x) != (_S847.y);
                }
                if(_S972)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1031 = b_7 == 0U;
            bool _S1032 = withinInverseFootprint((&lobe_10)->pdf, _S1031, (&prev_0)->cos, (&hit_1)->distance, threshold_2);
            FKSurface _S1033 = surface_10;
            bool _S1034 = (dot_0(throughput_8, _S844.smooth_n) * dot_0(throughput_8, surface_10.geometry_n)) < 0.0f;
            bool _S1035 = !_S1034;
            if(_S1035)
            {
                bool _S1036 = roughLobe((&lobe_10)->pdf, _S1031, _S843.material.roughness);
                _S972 = _S1036;
            }
            else
            {
                _S972 = false;
            }
            if(_S876)
            {
                bool _S1037 = !_S1032;
                if(_S1037)
                {
                    return _S678;
                }
                bool _S1038 = _S683 != 1U;
                if(_S1038)
                {
                    _S973 = _S683 != 2U;
                }
                else
                {
                    _S973 = false;
                }
                if(_S973)
                {
                    float _S1039 = (&lobe_10)->pdf;
                    float _S1040 = _slang_select(nee_0, _S1039,0.0f);
                    float _S1041 = escapeWeight_0(_S1040, _S983);
                    bool _S1042 = _S681 == _S680;
                    if(_S1042)
                    {
                        passes_0 = _S689;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1043 = _slang_select(passes_0, _S1041,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_10)->throughput * make_float3 ((&lobe_10)->pdf)) * r_3->radiance * make_float3 (_S1043) / make_float3 (r_3->jac), density_4 * (&lobe_10)->pdf / r_3->jac);
                }
                float3  _S1044 = throughput_6 * make_float3 ((&lobe_10)->pdf);
                float _S1045 = density_4 * (&lobe_10)->pdf;
                throughput_9 = _S1044;
                density_6 = _S1045;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1046 = (fcptLayers((hit_1)));
            bool _S1047 = b_7 == 1U;
            bool _S1048 = passesLayer_0(_S1046, _S1047, passes_0);
            if(_S877)
            {
                _S973 = _S1048;
            }
            else
            {
                _S973 = false;
            }
            if(_S973)
            {
                return _S678;
            }
            if(replay_1)
            {
                _S974 = b_4 <= _S693;
            }
            else
            {
                _S974 = false;
            }
            if(_S974)
            {
                _S975 = _S842;
            }
            else
            {
                _S975 = false;
            }
            if(_S975)
            {
                _S976 = _S1032;
            }
            else
            {
                _S976 = false;
            }
            if(_S976)
            {
                _S977 = true;
            }
            else
            {
                if(_S877)
                {
                    _S977 = !_S972;
                }
                else
                {
                    _S977 = false;
                }
            }
            if(_S977)
            {
                return _S678;
            }
            if(_S877)
            {
                float3  _S1049 = throughput_9 * ((&lobe_10)->throughput * make_float3 ((&lobe_10)->pdf));
                float _S1050 = (&lobe_10)->pdf;
                throughput_10 = _S1049;
                sky_pdf_2 = _S1050;
            }
            else
            {
                float3  _S1051 = throughput_9 * max_0((&lobe_10)->throughput, _S677);
                throughput_10 = _S1051;
                sky_pdf_2 = density_6;
            }
            bool _S1052 = !replay_1;
            if(_S1052)
            {
                _S978 = !_S867;
            }
            else
            {
                _S978 = false;
            }
            if(_S978)
            {
                _S979 = _S842;
            }
            else
            {
                _S979 = false;
            }
            bool _S1053;
            if(_S979)
            {
                _S1053 = _S1032;
            }
            else
            {
                _S1053 = false;
            }
            float3  chain_throughput_1;
            if(_S1053)
            {
                chain_0 = here_0;
                uint _S1054 = insertBits_0((&chain_0)->path, b_7, 17U, 2U);
                uint _S1055 = _slang_select(nee_0, 1U,0U);
                uint _S1056 = insertBits_0(_S1054, _S1055, 19U, 1U);
                (&chain_0)->path = _S1056;
                float _S1057 = (&chain_0)->jac * (&lobe_10)->pdf;
                (&chain_0)->jac = _S1057;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            Vertex _S1058 = Vertex_x24init_0(_S972, b_7, (&lobe_10)->pdf, (F32_abs((dot_0(_S1033.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1058;
            float _S1059 = (&lobe_10)->pdf;
            bool _S1060;
            if(_S1047)
            {
                _S1060 = (_S847.x) == (_S847.y);
            }
            else
            {
                _S1060 = false;
            }
            float _S1061 = _slang_select(_S1060, sky_pdf_0,_S1059);
            float _S1062 = widened_0(spread_1, (&lobe_10)->pdf, _S879);
            bool _S1063;
            if(refracted_4)
            {
                _S1063 = !_S969;
            }
            else
            {
                _S1063 = false;
            }
            bool is_inside_7;
            if(_S1063)
            {
                bool _S1064 = !is_inside_6;
                is_inside_7 = _S1064;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            bool _S1065 = !_S1048;
            if(_S1065)
            {
                FKSurface faced_2 = surface_10;
                float3  _S1066 = - _S1033.geometry_n;
                float3  _S1067 = _slang_select(turned_1, _S1066,_S1033.geometry_n);
                (&faced_2)->geometry_n = _S1067;
                FKMedium _S1068 = Medium_x24init_0(scatter_in_0, extinction_in_0);
                FKSurface _S1069 = faced_2;
                FKMedium _S1070 = _S1068;
                MediumSides _S1071 = mediumSides_0(&_S1069, &_S1070, filling_2, (&ray_2)->unit_direction);
                bool _S1072 = leavesInFront_0((&faced_2)->geometry_n, throughput_8, _S851, _S1033.geometry_n);
                float3  _S1073 = _slang_select(_S1072, _S1071.front.scatter,_S1071.behind.scatter);
                scatter_in_0 = _S1073;
                float3  _S1074 = _slang_select(_S1072, _S1071.front.extinction,_S1071.behind.extinction);
                extinction_in_0 = _S1074;
                uint _S1075 = _S1071.fillings.x;
                uint _S1076 = _S1071.fillings.y;
                uint _S1077 = _slang_select(_S1072, _S1076,_S1075);
                filling_2 = _S1077;
            }
            (&ray_2)->unit_direction = throughput_8;
            if(_S1065)
            {
                FKSurface _S1078 = surface_10;
                float3  _S1079 = - _S844.smooth_n;
                bool _S1080 = is_inside_7 != _S969;
                float3  _S1081 = _slang_select(_S1080, _S1079,_S844.smooth_n);
                float3  _S1082 = (&ray_2)->origin + make_float3 (_S1078.geometry_offset) * _S1081;
                (&ray_2)->origin = _S1082;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1048;
            sky_pdf_2 = _S1061;
            spread_4 = _S1062;
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
        bool _S1083 = !replay_1;
        float density_7;
        if(_S1083)
        {
            if(_S813)
            {
                float3  _S1084 = throughput_9 * emission_1;
                Reservoir candidate_7 = chain_0;
                uint _S1085 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1086 = _S1085 == 1U;
                if(_S1086)
                {
                    float3  _S1087 = safeDivide(_S1084, chain_throughput_0);
                    (&candidate_7)->radiance = _S1087;
                }
                Reservoir _S1088 = withEnd(candidate_7, 2U, b_4, _S1084);
                offer(sel_1, _S1088, _S1084 * make_float3 (scale_1) / make_float3 (density_6));
            }
            if(_S813)
            {
                _S877 = true;
            }
            else
            {
                _S877 = scatter_2;
            }
            if(_S877)
            {
                float _S1089 = survivalProbability(throughput_9, density_6);
                density_7 = _S1089;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1090 = stream(_S705, b_4 + 128U);
            Random _S1091 = pcg(_S1090);
            bool _S1092 = density_7 < (_S1091.value);
            if(_S1092)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1093 = (fcptMaxBounces());
                wrong_side_0 = b_4 >= _S1093;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1094 = density_6 * density_7;
            density_7 = _S1094;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1095 = layer_0 ^ 1U;
        uint _S1096 = _slang_select(passes_0, _S1095,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_1)->distance = 0.0f;
            b_7 = b_4;
            throughput_2 = throughput_9;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_1 = spread_4;
            uint _S1097 = b_7 + 1U;
            b_4 = _S1097;
            layer_0 = _S1096;
            continue;
        }
        FKRay _S1098 = ray_2;
        float _S1099 = distance_5(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            _S877 = b_4 == _S693;
        }
        else
        {
            _S877 = false;
        }
        if(_S877)
        {
            wrong_side_0 = _S682 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1100 = _slang_select(wrong_side_0, _S1099,4.294967296e+09f);
        FKHit _S1101 = (fcptTraverseInstanceBVH((_S1098), (_S818), (_S1100), (true)));
        hit_1 = _S1101;
        if(replay_1)
        {
            refracted_4 = b_4 == _S693;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            _S878 = _S682 == 1U;
        }
        else
        {
            _S878 = false;
        }
        if(_S878)
        {
            _S879 = ((&hit_1)->instance_index) == (_S694.instance_index);
        }
        else
        {
            _S879 = false;
        }
        if(_S879)
        {
            _S968 = ((&hit_1)->triangle_index) == (_S694.triangle_index);
        }
        else
        {
            _S968 = false;
        }
        if(_S968)
        {
            (&hit_1)->uv = _S694.uv;
            float _S1102 = distance_5(reconnection_0, (&ray_2)->origin);
            (&hit_1)->distance = _S1102;
        }
        if(replay_1)
        {
            _S969 = b_4 == _S693;
        }
        else
        {
            _S969 = false;
        }
        if(_S969)
        {
            _S970 = _S682 == 3U;
        }
        else
        {
            _S970 = false;
        }
        if(_S970)
        {
            _S971 = ((&hit_1)->instance_index) != 4294967295U;
        }
        else
        {
            _S971 = false;
        }
        if(_S971)
        {
            return _S678;
        }
        Reservoir _S1103 = chain_0;
        uint _S1104 = filling_2;
        for(;;)
        {
            bool _S1105 = _S1104 != 4294967295U;
            float _S1106 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            float _S1107 = (fcptMajorant((_S1104)));
            float _S1108 = _slang_select(_S1105, _S1107,_S1106);
            if(replay_1)
            {
                _S972 = b_4 == _S693;
            }
            else
            {
                _S972 = false;
            }
            if(_S972)
            {
                _S973 = _S682 == 1U;
            }
            else
            {
                _S973 = false;
            }
            if(_S973)
            {
                _S974 = _S1108 > 0.0f;
            }
            else
            {
                _S974 = false;
            }
            if(_S974)
            {
                ended_0 = _S678;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_3 = width_2;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_7 = b_4;
                _S975 = true;
                break;
            }
            bool _S1109 = (&prev_0)->rough;
            if(_S1109)
            {
                _S975 = !(_S1108 > 0.0f);
            }
            else
            {
                _S975 = false;
            }
            (&prev_0)->rough = _S975;
            uint _S1110 = b_4 + 320U;
            bool _S1111 = b_4 == 4294967295U;
            uint _S1112 = _slang_select(_S1111, 384U,_S1110);
            uint _S1113 = stream(_S705, _S1112);
            uint tracking_1 = _S1113;
            weight_1 = throughput_3;
            glowed_0 = _S677;
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
                    _S676 = int(2);
                    break;
                }
                uint _S1114 = b_7 + 320U;
                bool _S1115 = b_7 == 4294967295U;
                uint _S1116 = _slang_select(_S1115, 384U,_S1114);
                uint _S1117 = stream(_S705, _S1116);
                Random _S1118 = pcg(_S1117);
                float _S1119 = freeFlight_0(_S1118.value, _S1108);
                if(_S1105)
                {
                    float3  _S1120 = (&ray_2)->origin;
                    float3  _S1121 = (&ray_2)->unit_direction;
                    float _S1122 = (&hit_1)->distance;
                    uint _S1123 = _slang_select(_S1115, 0U,b_7);
                    uint _S1124 = (&prev_0)->lobe;
                    uint _S1125 = _slang_select(_S1115, 3U,_S1124);
                    float _S1126 = (fcptTrackMedium((_S1104), (_S1120), (_S1121), (_S1122), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S1123), (_S1125)));
                    spread_3 = _S1126;
                }
                else
                {
                    spread_3 = _S1119;
                }
                bool _S1127 = !(spread_3 < ((&hit_1)->distance));
                if(_S1127)
                {
                    _S676 = int(2);
                    break;
                }
                if(_S1105)
                {
                    _S976 = _S1083;
                }
                else
                {
                    _S976 = false;
                }
                if(_S976)
                {
                    float3  _S1128 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1129 = sel_1->glow + _S1128;
                    sel_1->glow = _S1129;
                }
                else
                {
                }
                glowed_0 = _S677;
                uint b_8 = b_7 + 1U;
                float3  _S1130 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1130;
                float3  _S1131 = flightWeight_0(scatter_in_0, extinction_in_0, _S1108, spread_3, true);
                float3  _S1132 = weight_1;
                float3  _S1133 = _slang_select(_S1105, _S1132,_S1131);
                float3  throughput_11 = throughput_10 * _S1133;
                uint _S1134 = stream(_S705, b_8 + 320U);
                tracking_1 = _S1134;
                weight_1 = throughput_3;
                float width_6 = width_3 + spread_2 * spread_3;
                float _S1135 = spread_2 + 3.14159274101257324f;
                uint _S1136 = stream(_S705, b_8 + 64U);
                uint2  _S1137 = make_uint2 (_S1104);
                uint _S1138 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                ShadowContext _S1139 = ShadowContext_x24init_0(extinction_in_0, extinction_in_0, _S1137, (&ray_2)->unit_direction, b_8, _S1138, false, spread_3, width_6);
                TreeSample _S1140 = sampleLightTree_0((&ray_2)->origin, (&ray_2)->unit_direction, (&ray_2)->unit_direction, 0.0f, true, _S1136, &_S1139);
                bool _S1141 = scatterSampled_0(replay_1, b_8, _S693, _S1105);
                uint _S1142 = (fcptMaxBounces());
                bool _S1143 = b_8 < _S1142;
                if(_S1143)
                {
                    _S977 = (_S1140.density) > 0.0f;
                }
                else
                {
                    _S977 = false;
                }
                float _S1144 = _slang_select(_S977, 0.07957746833562851f,0.0f);
                float3  _S1145 = throughput_11 * _S1140.radiance;
                float _S1146 = powerHeuristic(_S1140.density, _S1144);
                float3  _S1147 = _S1145 * make_float3 (0.07957746833562851f * _S1146);
                float3  _S1148 = _slang_select(_S1141, _S1147,_S677);
                if(replay_1)
                {
                    _S978 = b_8 == _S693;
                }
                else
                {
                    _S978 = false;
                }
                if(_S978)
                {
                    bool _S1149 = _S682 == 2U;
                    if(_S1149)
                    {
                        float _S1150 = rgb_to_greyscale(_S1148);
                        _S979 = _S1150 > 0.0f;
                    }
                    else
                    {
                        _S979 = false;
                    }
                    if(_S979)
                    {
                        Shift _S1151 = Shift_x24init_0(_S1148, 1.0f);
                        _S676 = int(1);
                        ended_0 = _S1151;
                        spread_3 = _S1135;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_5 = b_8;
                        break;
                    }
                    _S676 = int(1);
                    ended_0 = _S678;
                    spread_3 = _S1135;
                    width_4 = width_6;
                    throughput_8 = throughput_11;
                    b_5 = b_8;
                    break;
                }
                if(_S1083)
                {
                    Reservoir candidate_8 = _S1103;
                    uint _S1152 = extractBits_0(_S1103.path, 10U, 2U);
                    bool _S1153 = _S1152 == 1U;
                    if(_S1153)
                    {
                        float3  _S1154 = safeDivide(_S1148, chain_throughput_0);
                        (&candidate_8)->radiance = _S1154;
                    }
                    else
                    {
                        uint _S1155 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                        uint _S1156 = insertBits_0(_S1155, 2U, 10U, 2U);
                        (&candidate_8)->path = _S1156;
                    }
                    Reservoir _S1157 = withEnd(candidate_8, 0U, b_8, _S1148);
                    offer(sel_1, _S1157, _S1148 * make_float3 (scale_1) / make_float3 (density_3));
                    float _S1158 = survivalProbability(throughput_11, density_3);
                    uint _S1159 = stream(_S705, b_8 + 128U);
                    Random _S1160 = pcg(_S1159);
                    bool _S1161 = _S1158 < (_S1160.value);
                    if(_S1161)
                    {
                        _S979 = true;
                    }
                    else
                    {
                        uint _S1162 = (fcptMaxBounces());
                        _S979 = b_8 >= _S1162;
                    }
                    if(_S979)
                    {
                        _S676 = int(1);
                        ended_0 = _S678;
                        spread_3 = _S1135;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_5 = b_8;
                        break;
                    }
                    float _S1163 = density_3 * _S1158;
                    density_3 = _S1163;
                }
                else
                {
                }
                NEEVertex _S1164 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_2)->origin, _S677, (&ray_2)->origin);
                nee_vertex_0 = _S1164;
                uint _S1165 = stream(_S705, b_8);
                float3  _S1166 = isotropic_0(_S1165);
                (&ray_2)->unit_direction = _S1166;
                Vertex _S1167 = scatteredVertex_0(is_inside_5);
                prev_0 = _S1167;
                float _S1168 = (&prev_0)->pdf;
                FKHit _S1169 = (fcptTraverseInstanceBVH((ray_2), (true), (4.294967296e+09f), (false)));
                hit_1 = _S1169;
                b_7 = b_8;
                throughput_10 = throughput_11;
                spread_2 = _S1135;
                width_3 = width_6;
                sky_pdf_1 = _S1168;
            }
            if(_S676 != int(2))
            {
                spread_2 = spread_3;
                width_3 = width_4;
                throughput_10 = throughput_8;
                b_7 = b_5;
                _S975 = true;
                break;
            }
            ended_0 = _S678;
            _S975 = false;
            break;
        }
        if(_S975)
        {
            return ended_0;
        }
        Reservoir _S1170 = chain_0;
        NEEVertex _S1171 = nee_vertex_0;
        Vertex _S1172 = prev_0;
        FKHit _S1173 = hit_1;
        uint _S1174 = filling_2;
        float3  _S1175 = scatter_in_0;
        float3  _S1176 = extinction_in_0;
        float3  _S1177 = weight_1;
        float3  _S1178 = glowed_0;
        for(;;)
        {
            bool _S1179 = (_S1173.instance_index) == 4294967295U;
            if(_S1179)
            {
                bool _S1180 = !_S1171.none;
                float _S1181 = _slang_select(_S1180, sky_pdf_1,0.0f);
                float _S1182 = escapeWeight_0(_S1181, (&ray_2)->unit_direction);
                float3  _S1183 = environment_0((&ray_2)->unit_direction, b_7, _S1172.lobe);
                float3  _S1184 = throughput_10 * _S1183;
                if(replay_1)
                {
                    bool _S1185 = b_7 == _S693;
                    if(_S1185)
                    {
                        _S976 = _S682 == 3U;
                    }
                    else
                    {
                        _S976 = false;
                    }
                    if(_S976)
                    {
                        Shift _S1186 = Shift_x24init_0(_S1184 * make_float3 (_S1182) / make_float3 (r_3->jac), density_3 / r_3->jac);
                        arrived_end_0 = _S1186;
                        width_4 = width_3;
                        throughput_8 = throughput_10;
                        _S976 = true;
                        break;
                    }
                    if(_S692)
                    {
                        _S977 = _S689;
                    }
                    else
                    {
                        _S977 = false;
                    }
                    if(_S977)
                    {
                        _S978 = b_7 == _S680;
                    }
                    else
                    {
                        _S978 = false;
                    }
                    if(_S978)
                    {
                        _S979 = !_S1172.rough;
                    }
                    else
                    {
                        _S979 = false;
                    }
                    if(_S979)
                    {
                        Shift _S1187 = Shift_x24init_0(_S1184 * make_float3 (_S1182), 1.0f);
                        arrived_end_0 = _S1187;
                        width_4 = width_3;
                        throughput_8 = throughput_10;
                        _S976 = true;
                        break;
                    }
                    arrived_end_0 = _S678;
                    width_4 = width_3;
                    throughput_8 = throughput_10;
                    _S976 = true;
                    break;
                }
                Reservoir candidate_9 = _S1170;
                uint _S1188 = extractBits_0(_S1170.path, 10U, 2U);
                bool _S1189 = _S1188 == 1U;
                if(_S1189)
                {
                    uint _S1190 = extractBits_0(_S1170.path, 5U, 5U);
                    bool _S1191 = _S1190 == b_7;
                    float _S1192 = _slang_select(_S1191, 1.0f,_S1182);
                    float3  _S1193 = safeDivide(_S1184 * make_float3 (_S1192), chain_throughput_0);
                    (&candidate_9)->radiance = _S1193;
                }
                else
                {
                    if(_S1172.rough)
                    {
                        uint _S1194 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                        uint _S1195 = insertBits_0(_S1194, 3U, 10U, 2U);
                        uint _S1196 = insertBits_0(_S1195, _S1172.lobe, 15U, 2U);
                        uint _S1197 = _slang_select(_S1172.inside, 1U,0U);
                        uint _S1198 = insertBits_0(_S1196, _S1197, 20U, 1U);
                        (&candidate_9)->path = _S1198;
                        (&candidate_9)->jac = _S1172.pdf;
                        (&candidate_9)->dir = (&ray_2)->unit_direction;
                    }
                    else
                    {
                    }
                }
                float3  _S1199 = _S1184 * make_float3 (_S1182);
                Reservoir _S1200 = withEnd(candidate_9, 3U, b_7, _S1199);
                offer(sel_1, _S1200, _S1199 * make_float3 (scale_1) / make_float3 (density_3));
                arrived_end_0 = _S678;
                width_4 = width_3;
                throughput_8 = throughput_10;
                _S976 = true;
                break;
            }
            float3  _S1201 = (&ray_2)->origin + make_float3 (_S1173.distance) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1201;
            bool _S1202 = _S1174 != 4294967295U;
            if(_S1202)
            {
                if(_S1083)
                {
                    float3  _S1203 = throughput_10 * _S1178 / make_float3 (density_3);
                    float3  _S1204 = sel_1->glow + _S1203;
                    sel_1->glow = _S1204;
                }
                else
                {
                }
                float3  _S1205 = throughput_10 * _S1177;
                throughput_8 = _S1205;
            }
            else
            {
                float3  _S1206 = flightWeight_0(_S1175, _S1176, (_S1175.x + _S1175.y + _S1175.z) / 3.0f, _S1173.distance, false);
                float3  _S1207 = throughput_10 * _S1206;
                throughput_8 = _S1207;
            }
            float _S1208 = width_3 + spread_2 * _S1173.distance;
            arrived_end_0 = _S678;
            width_4 = _S1208;
            _S976 = false;
            break;
        }
        if(_S976)
        {
            return arrived_end_0;
        }
        width_2 = width_4;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1097 = b_7 + 1U;
        b_4 = _S1097;
        layer_0 = _S1096;
    }
    return _S678;
}

static __device__ Shift shift_0(Domain * dom_1, Reservoir * r_4)
{
    Selection _S1209 = (Selection{});
    Selection sel_2 = _S1209;
    bool _S1210 = (r_4->w) <= 0.0f;
    if(_S1210)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1211 = walk_0(dom_1, r_4, true, 0.0f, &sel_2);
    return _S1211;
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
    Random _S1212 = pcg(state_3);
    Random _S1213 = pcg(_S1212.state);
    float _S1214 = 6.28318548202514648f * _S1212.value;
    float _S1215 = (F32_sqrt((-2.0f * clamp_0((F32_log((_S1213.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1213.state, _S1215 * (F32_cos((_S1214))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1216;
    (&_S1216)->state = state_4;
    (&_S1216)->value = value_2;
    return _S1216;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1217 = normal_distribution(state_5);
    Random _S1218 = normal_distribution(_S1217.state);
    Random _S1219 = normal_distribution(_S1218.state);
    float3  _S1220 = make_float3 (_S1217.value, _S1218.value, _S1219.value);
    float3  _S1221 = ((((_S1220)) * make_float3(rnorm3df(((_S1220)).x, ((_S1220)).y, ((_S1220)).z))));
    return RandomSphere_x24init_0(_S1219.state, _S1221);
}

struct RandomHemisphere
{
    uint state;
    float3  value;
};

static __device__ RandomHemisphere RandomHemisphere_x24init_0(uint state_6, float3  value_3)
{
    RandomHemisphere _S1222;
    (&_S1222)->state = state_6;
    (&_S1222)->value = value_3;
    return _S1222;
}

__device__ RandomHemisphere random_hemisphere(uint state_7, float3  normal_4)
{
    RandomSphere _S1223 = random_sphere(state_7);
    bool _S1224 = (dot_0(_S1223.value, normal_4)) > 0.0f;
    if(_S1224)
    {
        return RandomHemisphere_x24init_0(_S1223.state, _S1223.value);
    }
    else
    {
        float3  _S1225 = negate_0(_S1223.value);
        return RandomHemisphere_x24init_0(_S1223.state, _S1225);
    }
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_15)
{
    float3  _S1226 = p1_0 - p0_0;
    float3  _S1227 = p2_0 - p0_0;
    float2  _S1228 = uv1_0 - uv0_0;
    float2  _S1229 = uv2_0 - uv0_0;
    float _S1230 = _S1228.x;
    float _S1231 = _S1229.y;
    float _S1232 = _S1228.y;
    float _S1233 = _S1229.x;
    float _S1234 = _S1230 * _S1231 - _S1232 * _S1233;
    float _S1235 = 1.0f / _S1234;
    float3  t_1 = (_S1226 * make_float3 (_S1231) - _S1227 * make_float3 (_S1232)) * make_float3 (_S1235);
    float3  _S1236 = (_S1227 * make_float3 (_S1230) - _S1226 * make_float3 (_S1233)) * make_float3 (_S1235);
    float3  _S1237 = t_1 - n_15 * make_float3 (dot_0(n_15, t_1));
    float3  t_2 = ((((_S1237)) * make_float3(rnorm3df(((_S1237)).x, ((_S1237)).y, ((_S1237)).z))));
    bool _S1238 = (dot_0(cross_0(n_15, t_2), _S1236)) > 0.0f;
    float3  t_3;
    if(_S1238)
    {
        float3  _S1239 = negate_0(t_2);
        t_3 = _S1239;
    }
    else
    {
        t_3 = t_2;
    }
    float3  _S1240 = cross_0(n_15, t_3);
    return makeMatrix<float, 3, 3> (t_3, _S1240, n_15);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1241 = t1_0 - t0_0;
    float3  _S1242 = t2_2 - t0_0;
    float3  _S1243 = t2_2 - t1_0;
    float _S1244 = (F32_min((length_0(_S1241)), ((F32_min((length_0(_S1242)), (length_0(_S1243)))))));
    float3  _S1245 = make_float3 (distance_5(position_0, t0_0), distance_5(position_0, t1_0), distance_5(position_0, t2_2));
    float3  _S1246 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1247 = dot_0(geometry_n_5, _S1246);
    float3  _S1248 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1249 = dot_0(geometry_n_5, _S1248);
    float3  _S1250 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1251 = acos_0(abs_0(make_float3 (_S1247, _S1249, dot_0(geometry_n_5, _S1250))));
    float3  _S1252 = clamp_1(tan_0(_S1251), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_0(dot_0(_S1245 * _S1252, uvw_0), 0.0f, _S1244 * 0.125f);
}

__device__ float3  sampleHalfVector(float3  v_6, float3  n_i_5, float alpha_6, uint * random_state_15)
{
    float3  _S1253 = sampleMaterialHalfVector(v_6, n_i_5, alpha_6, AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f)), random_state_15);
    return _S1253;
}

__device__ float3  straightThrough(float3  dir_14, float3  n_16, BSDFMaterial material_16)
{
    float3  _S1254 = negate_0(dir_14);
    float _S1255 = sign_0(dot_0(n_16, _S1254));
    float3  _S1256 = n_16 * make_float3 (_S1255);
    AnisotropicFrame _S1257 = anisotropicFrame(material_16, _S1256);
    bool _S1258 = (_S1257.alphas.x) > 0.0f;
    if(_S1258)
    {
        float _S1259 = material_16.transmission * (1.0f - material_16.metallic);
        float3  _S1260 = negate_0(_S1256);
        float3  _S1261 = anisotropicLocal(dir_14, _S1257.tangent, _S1260);
        float _S1262 = anisotropicG1(_S1261, _S1257.alphas);
        return make_float3 (_S1259 * _S1262) * material_16.albedo;
    }
    float _S1263 = material_16.transmission * (1.0f - material_16.metallic);
    float _S1264 = material_16.roughness;
    float _S1265 = smithG1(_S1264 * _S1264, (F32_abs((dot_0(n_16, dir_14)))));
    return make_float3 (_S1263 * _S1265) * material_16.albedo;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_17, BSDFMaterial material_17, float coverage_1)
{
    float3  _S1266;
    if((material_17.ior) == 1.0f)
    {
        float3  _S1267 = straightThrough(toward_1, n_17, material_17);
        _S1266 = _S1267;
    }
    else
    {
        _S1266 = make_float3 (0.0f);
    }
    return _S1266 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_5, Shift shifted_0, float mis_0)
{
    Reservoir candidate_10 = r_5;
    float3  _S1268 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_10)->f = _S1268;
    float _S1269 = r_5.jac * shifted_0.jac;
    (&candidate_10)->jac = _S1269;
    offer(sel_3, candidate_10, make_float3 (mis_0) * shifted_0.f * make_float3 (r_5.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_6 = sel_4.r;
    float _S1270 = rgb_to_greyscale((&r_6)->f);
    float _S1271 = sel_4.w_sum / _S1270;
    bool _S1272 = _S1270 > 0.0f;
    float _S1273 = _slang_select(_S1272, _S1271,0.0f);
    (&r_6)->w = _S1273;
    (&r_6)->c = c_1;
    return r_6;
}

static __device__ float interpolate_0(float a_6, float b_9, float t_4)
{
    return a_6 + (b_9 - a_6) * t_4;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S1274 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S1274;
}

__device__ float2  temporalWeights(float c_2, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S1275 = c_2 * p_c_0;
    float _S1276 = c_t_0 * p_t_0;
    return make_float2 (_S1275 / (_S1275 + c_t_0 * g_previous_0), _S1276 / (_S1276 + c_2 * g_current_0));
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
    Domain _S1277 = dom_2;
    Reservoir _S1278 = r_7;
    Shift _S1279 = walk_0(&_S1277, &_S1278, replay_2, scale_2, sel_5);
    return _S1279;
}

__device__ Shift shift_hook(Domain dom_3, Reservoir r_8)
{
    Domain _S1280 = dom_3;
    Reservoir _S1281 = r_8;
    Shift _S1282 = shift_0(&_S1280, &_S1281);
    return _S1282;
}

#undef Matrix
