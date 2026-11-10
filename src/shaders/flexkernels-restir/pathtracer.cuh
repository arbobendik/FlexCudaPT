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
    uint2  _S111 = (fcptEnvironmentMapSize());
    bool _S112 = (_S111.x) > 1U;
    bool _S113;
    if(_S112)
    {
        uint2  _S114 = (fcptEnvironmentMapSize());
        _S113 = (_S114.y) > 1U;
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
    uint2  _S115 = (fcptEnvironmentCdfSize());
    uint2  _S116 = _S115 - make_uint2 (1U, 0U);
    float2  _S117 = make_float2 ((F32_atan2((- dir_3.z), (- dir_3.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_0(dir_3.y, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S118 = make_float2 ((float)_S116.x, (float)_S116.y);
    float2  _S119 = _S117 * _S118;
    uint2  _S120 = make_uint2 ((uint)_S119.x, (uint)_S119.y);
    uint2  _S121 = min_0(_S120, _S116 - make_uint2 (1U));
    float4  _S122 = (fcptEnvironmentCdf((_S121)));
    float _S123 = _S122.y;
    uint _S124 = _S116.x;
    float4  _S125 = (fcptEnvironmentCdf((make_uint2 (_S124, _S121.y))));
    float _S126 = _S123 * _S125.y;
    return _S126 * float(_S124 * _S116.y) / (19.73921012878417969f * length_1(float2 {dir_3.x, dir_3.z}));
}

static __device__ float escapeWeight_0(float pdf_0, float3  dir_4)
{
    bool _S127 = pdf_0 <= 0.0f;
    bool _S128;
    if(_S127)
    {
        _S128 = true;
    }
    else
    {
        bool _S129 = environmentMapped_0();
        _S128 = !_S129;
    }
    if(_S128)
    {
        return 1.0f;
    }
    float _S130 = environmentPdf_0(dir_4);
    return pdf_0 / (pdf_0 + _S130);
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
    uint _S131 = x_6 * 747796405U + 2891336453U;
    uint _S132 = ((_S131 >> ((_S131 >> 28U) + 4U)) ^ _S131) * 277803737U;
    return (_S132 >> 22U) ^ _S132;
}

static __device__ float random_0(uint * state_0)
{
    uint _S133 = hash(*state_0);
    *state_0 = _S133;
    return float((*state_0) >> int(8)) * 5.9604644775390625e-08f;
}

static __device__ Random Random_x24init_0(uint state_1, float value_0)
{
    Random _S134;
    (&_S134)->state = state_1;
    (&_S134)->value = value_0;
    return _S134;
}

__device__ Random pcg(uint state_2)
{
    uint _S135 = state_2;
    float value_1 = random_0(&_S135);
    return Random_x24init_0(_S135, value_1);
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
    float _S136;
    if(e_0 > 0.0f)
    {
        _S136 = 1.0f;
    }
    else
    {
        if(e_0 < 0.0f)
        {
            _S136 = -1.0f;
        }
        else
        {
            _S136 = 0.0f;
        }
    }
    return _S136;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S137;
    (&_S137)->tangent = tangent_0;
    (&_S137)->alphas = alphas_0;
    return _S137;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_0 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S138 = (F32_abs((dot_0(n_1, a_0)))) > 0.9999847412109375f;
    float3  a_1;
    if(_S138)
    {
        float3  _S139 = make_float3 (1.0f, 0.0f, 0.0f);
        a_1 = _S139;
    }
    else
    {
        a_1 = a_0;
    }
    float3  _S140 = cross_0(n_1, a_1);
    float3  _S141 = ((((_S140)) * make_float3(rnorm3df(((_S140)).x, ((_S140)).y, ((_S140)).z))));
    float3  _S142 = cross_0(n_1, _S141);
    return make_float3 (v_0.x) * _S141 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S142;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_0, float3  n_i_0)
{
    float _S143 = material_0.roughness;
    float _S144 = _S143 * _S143;
    bool _S145 = (material_0.anisotropy) == 0.0f;
    bool _S146;
    if(_S145)
    {
        _S146 = true;
    }
    else
    {
        _S146 = !(_S144 > 0.0f);
    }
    if(_S146)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S147 = material_0.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_0.tangent));
    float3  _S148 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S149 = (dot_0(_S147, _S147)) > 0.0f;
    float3  _S150 = _slang_select(_S149, _S147,_S148);
    float3  _S151 = ((((_S150)) * make_float3(rnorm3df(((_S150)).x, ((_S150)).y, ((_S150)).z))));
    float _S152 = 6.28318548202514648f * material_0.anisotropic_rotation;
    float _S153 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_0.anisotropy))))));
    float _S154 = 1.0f / _S153;
    bool _S155 = (material_0.anisotropy) < 0.0f;
    float _S156 = _slang_select(_S155, _S154,_S153);
    return AnisotropicFrame_x24init_0(_S151 * make_float3 ((F32_cos((_S152)))) + cross_0(n_i_0, _S151) * make_float3 ((F32_sin((_S152)))), make_float2 (_S144 / _S156, _S144 * _S156));
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
    float3  _S157 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S158 = ((((_S157)) * make_float3(rnorm3df(((_S157)).x, ((_S157)).y, ((_S157)).z))));
    float _S159 = _S158.x;
    float _S160 = _S158.y;
    float _S161 = _S159 * _S159 + _S160 * _S160;
    float3  _S162;
    if(_S161 > 0.0f)
    {
        float3  _S163 = make_float3 (- _S160, _S159, 0.0f);
        float _S164 = (rsqrtf((_S161)));
        _S162 = _S163 * make_float3 (_S164);
    }
    else
    {
        _S162 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S165 = cross_0(_S158, _S162);
    float _S166 = (F32_sqrt((U1_0)));
    float _S167 = 6.28318548202514648f * U2_0;
    float _S168 = _S166 * (F32_cos((_S167)));
    float t2_0 = _S166 * (F32_sin((_S167)));
    float _S169 = 0.5f * (1.0f + _S158.z);
    float t2_1 = (1.0f - _S169) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S168 * _S168)))))) + _S169 * t2_0;
    float3  _S170 = make_float3 (_S168) * _S162 + make_float3 (t2_1) * _S165;
    float _S171 = unshared_0(_S168);
    float _S172 = unshared_0(_S168);
    float3  _S173 = _S170 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S171 * _S172 - t2_1 * t2_1))))))) * _S158;
    float3  _S174 = make_float3 (alpha_0 * _S173.x, alpha_0 * _S173.y, (F32_max((0.0f), (_S173.z))));
    float3  _S175 = ((((_S174)) * make_float3(rnorm3df(((_S174)).x, ((_S174)).y, ((_S174)).z))));
    return _S175;
}

__device__ float3  sampleAnisotropicVNDF(float3  Ve_1, float2  alphas_1, float U1_1, float U2_1)
{
    float _S176 = alphas_1.x;
    float _S177 = alphas_1.y;
    float3  _S178 = make_float3 (_S176 * Ve_1.x, _S177 * Ve_1.y, Ve_1.z);
    float3  _S179 = ((((_S178)) * make_float3(rnorm3df(((_S178)).x, ((_S178)).y, ((_S178)).z))));
    float3  _S180 = sampleGGXVNDF(_S179, 1.0f, U1_1, U2_1);
    float3  _S181 = make_float3 (_S176 * _S180.x, _S177 * _S180.y, _S180.z);
    float3  _S182 = ((((_S181)) * make_float3(rnorm3df(((_S181)).x, ((_S181)).y, ((_S181)).z))));
    return _S182;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
{
    float3  a_2 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S183 = (F32_abs((dot_0(n_3, a_2)))) > 0.9999847412109375f;
    float3  a_3;
    if(_S183)
    {
        float3  _S184 = make_float3 (1.0f, 0.0f, 0.0f);
        a_3 = _S184;
    }
    else
    {
        a_3 = a_2;
    }
    float3  _S185 = cross_0(n_3, a_3);
    float3  _S186 = ((((_S185)) * make_float3(rnorm3df(((_S185)).x, ((_S185)).y, ((_S185)).z))));
    float3  _S187 = cross_0(n_3, _S186);
    return make_float3 (dot_0(v_1, _S186), dot_0(v_1, n_3), dot_0(v_1, _S187));
}

__device__ __forceinline__ float3  sampleMaterialHalfVector(float3  v_2, float3  n_i_1, float alpha_1, AnisotropicFrame frame_0, uint * random_state_1)
{
    Random _S188 = pcg(*random_state_1);
    Random _S189 = pcg(_S188.state);
    *random_state_1 = _S189.state;
    bool _S190 = (frame_0.alphas.x) > 0.0f;
    if(_S190)
    {
        float3  _S191 = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        float3  _S192 = sampleAnisotropicVNDF(_S191, frame_0.alphas, _S188.value, _S189.value);
        return make_float3 (_S192.x) * frame_0.tangent + make_float3 (_S192.y) * cross_0(n_i_1, frame_0.tangent) + make_float3 (_S192.z) * n_i_1;
    }
    float3  _S193 = worldToTangent(v_2, n_i_1);
    float3  _S194 = sampleGGXVNDF(float3 {_S193.x, _S193.z, _S193.y}, alpha_1, _S188.value, _S189.value);
    float3  _S195 = float3 {_S194.x, _S194.z, _S194.y};
    float3  _S196 = tangentToWorld(_S195, n_i_1);
    return _S196;
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
    float _S197 = dot_0(n_4, i_1);
    float _S198 = 1.0f - eta_0 * eta_0 * (1.0f - _S197 * _S197);
    if(_S198 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_1 - make_float3 (eta_0 * _S197 + (F32_sqrt((_S198)))) * n_4;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S199 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S200 = eta_i_0 / eta_o_0 * _S199;
    bool _S201 = _S200 < 1.0f;
    float kr_0;
    if(_S201)
    {
        float _S202 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S200 * _S200))))));
        float _S203 = eta_o_0 * cos_theta_0;
        float _S204 = eta_i_0 * _S202;
        float _S205 = (_S203 - _S204) / (_S203 + _S204);
        float _S206 = eta_i_0 * cos_theta_0;
        float _S207 = eta_o_0 * _S202;
        float _S208 = (_S206 - _S207) / (_S206 + _S207);
        float _S209 = (_S205 * _S205 + _S208 * _S208) / 2.0f;
        kr_0 = _S209;
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
    float _S210 = (F32_sqrt((0.05000000074505806f)));
    float _S211 = clamp_0((F32_sqrt(((F32_max((mu_0), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
    float _S212 = (clamp_0((F32_sqrt(((F32_max((r_0), (0.0f)))))), _S210, 1.0f) - _S210) / (1.0f - _S210) * 23.0f;
    uint _S213 = (U32_min((uint(_S211)), (22U)));
    uint _S214 = (U32_min((uint(_S212)), (22U)));
    float _S215 = _S211 - float(_S213);
    float _S216 = _S212 - float(_S214);
    uint _S217 = _S213 * 24U + _S214;
    uint _S218 = _S217 + 24U;
    float _S219 = SHEEN_ALBEDO_0[_S217] + (SHEEN_ALBEDO_0[_S218] - SHEEN_ALBEDO_0[_S217]) * _S215;
    uint _S220 = _S217 + 1U;
    float _S221 = SHEEN_ALBEDO_0[_S220] + (SHEEN_ALBEDO_0[_S218 + 1U] - SHEEN_ALBEDO_0[_S220]) * _S215;
    return (F32_exp((_S219 + (_S221 - _S219) * _S216)));
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

__device__ float anisotropicG1(float3  w_1, float2  alphas_2)
{
    float _S222 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S222 / (_S222 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S222)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S223 = alphas_3.x;
    float _S224 = h_0.x / _S223;
    float _S225 = alphas_3.y;
    float _S226 = h_0.y / _S225;
    float _S227 = h_0.z;
    float _S228 = _S224 * _S224 + _S226 * _S226 + _S227 * _S227;
    return 1.0f / (F32_max((3.14159274101257324f * _S223 * _S225 * _S228 * _S228), (1.17549435082228751e-38f)));
}

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_0, float3  refracted_1, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_0, float3  sheen_0, float3  view_0, float3  tangent_1, float2  alphas_4, float visible_0)
{
    BSDFLobes _S229;
    (&_S229)->v_dot_h = v_dot_h_0;
    (&_S229)->n_dot_h = n_dot_h_0;
    (&_S229)->refracted = refracted_1;
    (&_S229)->F = F_0;
    (&_S229)->F_greyscale = F_greyscale_0;
    (&_S229)->reflect_weight = reflect_weight_0;
    (&_S229)->diffuse_weight = diffuse_weight_0;
    (&_S229)->refract_weight = refract_weight_0;
    (&_S229)->p_diffuse = p_diffuse_0;
    (&_S229)->p_reflect = p_reflect_0;
    (&_S229)->p_refract = p_refract_0;
    (&_S229)->translucent_share = translucent_share_0;
    (&_S229)->sheen = sheen_0;
    (&_S229)->view = view_0;
    (&_S229)->tangent = tangent_1;
    (&_S229)->alphas = alphas_4;
    (&_S229)->visible = visible_0;
    return _S229;
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_0, float3  v_3, float3  n_i_2, float3  ggx_n_0, BSDFMaterial material_1, float eta_i_1, float eta_o_1, AnisotropicFrame frame_1)
{
    float _S230 = dot_0(ggx_n_0, v_3);
    float _S231 = dot_0(n_i_2, ggx_n_0);
    float _S232 = eta_i_1 / eta_o_1;
    float3  _S233 = refract_0(in_dir_0, ggx_n_0, _S232);
    float3  _S234 = ((((_S233)) * make_float3(rnorm3df(((_S233)).x, ((_S233)).y, ((_S233)).z))));
    float _S235 = (F32_min(((F32_sqrt((material_1.specular_level))) * (F32_abs((eta_i_1 - eta_o_1))) / (eta_i_1 + eta_o_1)), (0.9999847412109375f)));
    float _S236 = _S235 * _S235;
    float _S237 = (1.0f + _S235) / (1.0f - _S235);
    float _S238 = (F32_abs((_S230)));
    bool _S239 = eta_i_1 > eta_o_1;
    float sheen_component_0;
    if(_S239)
    {
        sheen_component_0 = _S237;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float visible_1;
    if(_S239)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S237;
    }
    float _S240 = fresnel(_S238, sheen_component_0, visible_1);
    bool _S241 = (eta_i_1 * eta_i_1 * (1.0f - _S230 * _S230)) >= (eta_o_1 * eta_o_1);
    float3  _S242;
    if(_S241)
    {
        _S242 = make_float3 (1.0f);
    }
    else
    {
        float3  _S243 = material_1.specular_tint * make_float3 (_S236);
        _S242 = _S243 + (make_float3 (1.0f) - _S243) * make_float3 (_S240 - _S236) / make_float3 (1.0f - _S236);
    }
    float3  _S244 = make_float3 (1.0f);
    float3  _S245 = make_float3 (0.0f);
    float _S246 = rgb_to_greyscale(material_1.sheen);
    bool _S247 = _S246 > 0.0f;
    float3  scale_0;
    float3  sheen_1;
    float3  view_1;
    if(_S247)
    {
        float _S248 = sheenAlbedo(dot_0(n_i_2, v_3), material_1.sheen_roughness);
        float _S249 = (F32_min((_S248), (1.0f)));
        float3  _S250 = make_float3 (1.0f) - material_1.sheen * make_float3 (_S249);
        float _S251 = rgb_to_greyscale(material_1.sheen);
        float _S252 = _S251 * _S249;
        float3  _S253 = material_1.sheen / make_float3 ((F32_max((_S248), (1.0f))));
        scale_0 = _S250;
        sheen_component_0 = _S252;
        sheen_1 = _S253;
        view_1 = v_3;
    }
    else
    {
        scale_0 = _S244;
        sheen_component_0 = 0.0f;
        sheen_1 = _S245;
        view_1 = _S245;
    }
    float3  _S254 = mix_0(_S242, material_1.albedo, material_1.metallic);
    float3  F_1 = _S254 * scale_0;
    float _S255 = rgb_to_greyscale(F_1);
    float _S256 = 1.0f - material_1.metallic;
    float3  _S257 = make_float3 (1.0f) - _S242;
    float3  _S258 = make_float3 ((1.0f - material_1.transmission) * _S256) * _S257 * scale_0;
    float3  _S259 = make_float3 (material_1.transmission * _S256) * _S257 * scale_0;
    float _S260 = (F32_max((_S255), (0.0f)));
    float _S261 = rgb_to_greyscale(_S258);
    float _S262 = (F32_max((_S261), (0.0f)));
    float _S263 = rgb_to_greyscale(_S259);
    float _S264 = sign_0(length_0(_S234));
    float _S265 = (F32_max((_S263 * _S264), (0.0f)));
    float _S266 = _S260 + _S262 + _S265 + sheen_component_0;
    float _S267 = 1.0f / (F32_max((_S266), (0.0000152587890625f)));
    float _S268 = (_S262 + sheen_component_0) * _S267;
    float _S269 = _S260 * _S267;
    float _S270 = _S265 * _S267;
    bool _S271 = (frame_1.alphas.x) > 0.0f;
    if(_S271)
    {
        float3  _S272 = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        float _S273 = anisotropicG1(_S272, frame_1.alphas);
        float3  _S274 = anisotropicLocal(ggx_n_0, frame_1.tangent, n_i_2);
        float _S275 = anisotropicD(_S274, frame_1.alphas);
        float _S276 = _S273 * _S275;
        visible_1 = _S276;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S230, _S231, _S234, F_1, _S255, 1.0f, _S258, _S259, _S268, _S269, _S270, 0.0f, sheen_1, view_1, frame_1.tangent, frame_1.alphas, visible_1);
}

__device__ float translucentShare(BSDFMaterial material_2)
{
    float _S277 = rgb_to_greyscale(material_2.translucent);
    float _S278 = rgb_to_greyscale(material_2.albedo);
    float _S279 = _S277 / (_S278 + _S277);
    bool _S280 = _S277 > 0.0f;
    float _S281 = _slang_select(_S280, _S279,0.0f);
    return _S281;
}

__device__ float smithG1(float alpha_2, float n_dot_x_0)
{
    float _S282 = alpha_2 * alpha_2;
    float _S283 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S282 + (1.0f - _S282) * n_dot_x_0 * n_dot_x_0))));
    bool _S284 = alpha_2 > 0.0f;
    float _S285 = _slang_select(_S284, _S283,1.0f);
    return _S285;
}

__device__ float trowbridgeReitz(float alpha_3, float n_dot_h_1)
{
    float _S286 = alpha_3 * alpha_3;
    float _S287 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S286 * n_dot_h_1 * n_dot_h_1;
    return _S286 / (F32_max((3.14159274101257324f * _S287 * _S287), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, BSDFLobes lobes_0, float eta_i_2, float eta_o_2, uint lobe_1)
{
    bool _S288 = lobe_1 == 0U;
    if(_S288)
    {
        float _S289 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        float _S290 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
        float _S291 = 1.0f - lobes_0.translucent_share;
        bool _S292 = n_i_dot_l_0 < 0.0f;
        float _S293 = _slang_select(_S292, lobes_0.translucent_share,_S291);
        float _S294 = _S290 * _S293;
        bool _S295 = (lobes_0.translucent_share) > 0.0f;
        float _S296 = _slang_select(_S295, _S294,_S289);
        bool _S297 = n_i_dot_v_0 > 0.0f;
        float _S298 = _slang_select(_S297, _S296,0.0f);
        return _S298;
    }
    float _S299 = smithG1(alpha_4, n_i_dot_v_0);
    float _S300 = _S299 * lobes_0.v_dot_h;
    float _S301 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    float _S302 = _S300 * _S301 / n_i_dot_v_0;
    bool _S303 = alpha_4 > 0.0f;
    bool _S304;
    if(_S303)
    {
        _S304 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S304 = false;
    }
    if(_S304)
    {
        _S304 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S304 = false;
    }
    if(_S304)
    {
        _S304 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S304 = false;
    }
    float _S305 = _slang_select(_S304, _S302,0.0f);
    bool _S306 = (lobes_0.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S306)
    {
        float _S307 = lobes_0.visible * lobes_0.v_dot_h / n_i_dot_v_0;
        bool _S308 = (lobes_0.v_dot_h) > 0.0f;
        if(_S308)
        {
            _S304 = (lobes_0.n_dot_h) > 0.0f;
        }
        else
        {
            _S304 = false;
        }
        if(_S304)
        {
            _S304 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S304 = false;
        }
        float _S309 = _slang_select(_S304, _S307,0.0f);
        pdf_h_0 = _S309;
    }
    else
    {
        pdf_h_0 = _S305;
    }
    bool _S310 = lobe_1 == 1U;
    if(_S310)
    {
        float _S311 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        float _S312 = lobes_0.p_refract * pdf_h_0 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S311 * _S311);
        bool _S313 = eta_i_2 != eta_o_2;
        if(_S313)
        {
            _S304 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S304 = false;
        }
        float _S314 = _slang_select(_S304, _S312,0.0f);
        return _S314;
    }
    float _S315 = lobes_0.p_reflect * pdf_h_0 / (4.0f * lobes_0.v_dot_h);
    bool _S316 = pdf_h_0 > 0.0f;
    float _S317 = _slang_select(_S316, _S315,0.0f);
    return _S317;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_0, uint random_state_2, bool refracted_2, uint lobe_2, float pdf_1)
{
    SampleBSDF _S318;
    (&_S318)->unit_direction = unit_direction_1;
    (&_S318)->throughput = throughput_0;
    (&_S318)->random_state = random_state_2;
    (&_S318)->refracted = refracted_2;
    (&_S318)->lobe = lobe_2;
    (&_S318)->pdf = pdf_1;
    return _S318;
}

__device__ float sheenBRDF(float3  l_0, float3  v_4, float3  n_5, float r_1)
{
    float _S319 = 1.0f / (F32_max((r_1), (0.05000000074505806f)));
    float3  _S320 = l_0 + v_4;
    float3  _S321 = ((((_S320)) * make_float3(rnorm3df(((_S320)).x, ((_S320)).y, ((_S320)).z))));
    float _S322 = dot_0(n_5, _S321);
    float _S323 = (F32_max((dot_0(n_5, l_0)), (0.0f)));
    float _S324 = (F32_max((dot_0(n_5, v_4)), (0.0f)));
    return (2.0f + _S319) * (F32_pow(((F32_max((1.0f - _S322 * _S322), (0.0f)))), (0.5f * _S319))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S323 + _S324 - _S323 * _S324)), (0.0000152587890625f)));
}

__device__ __forceinline__ float3  lobeThroughput(float3  l_1, float3  n_i_3, float alpha_5, BSDFMaterial material_3, BSDFLobes lobes_1, uint lobe_3)
{
    bool _S325 = lobe_3 == 0U;
    if(_S325)
    {
        bool _S326 = (dot_0(n_i_3, l_1)) < 0.0f;
        float3  _S327 = _slang_select(_S326, material_3.translucent,material_3.albedo);
        float _S328 = 1.0f - lobes_1.translucent_share;
        float _S329 = _slang_select(_S326, lobes_1.translucent_share,_S328);
        float3  _S330 = _S327 / make_float3 (_S329);
        bool _S331 = (lobes_1.translucent_share) > 0.0f;
        float3  _S332 = _slang_select(_S331, _S330,material_3.albedo);
        float _S333 = rgb_to_greyscale(material_3.sheen);
        bool _S334 = _S333 > 0.0f;
        bool _S335;
        if(_S334)
        {
            _S335 = !_S326;
        }
        else
        {
            _S335 = false;
        }
        if(_S335)
        {
            float3  _S336 = lobes_1.diffuse_weight * _S332;
            float3  _S337 = lobes_1.sheen * make_float3 (3.14159274101257324f);
            float _S338 = sheenBRDF(l_1, lobes_1.view, n_i_3, material_3.sheen_roughness);
            float3  _S339 = _S337 * make_float3 (_S338);
            float _S340 = _slang_select(_S331, _S328,1.0f);
            return (_S336 + _S339 / make_float3 (_S340)) / make_float3 (lobes_1.p_diffuse);
        }
        return lobes_1.diffuse_weight * _S332 / make_float3 (lobes_1.p_diffuse);
    }
    bool _S341 = lobe_3 == 1U;
    float G1_l_0;
    if(_S341)
    {
        float _S342 = - dot_0(n_i_3, l_1);
        float _S343 = smithG1(alpha_5, (F32_max((_S342), (0.0f))));
        bool _S344 = (lobes_1.alphas.x) > 0.0f;
        if(_S344)
        {
            float3  _S345 = negate_0(n_i_3);
            float3  _S346 = anisotropicLocal(l_1, lobes_1.tangent, _S345);
            float _S347 = anisotropicG1(_S346, lobes_1.alphas);
            G1_l_0 = _S347;
        }
        else
        {
            G1_l_0 = _S343;
        }
        return lobes_1.refract_weight * make_float3 (G1_l_0) * material_3.albedo / make_float3 (lobes_1.p_refract);
    }
    float _S348 = dot_0(n_i_3, l_1);
    float _S349 = smithG1(alpha_5, (F32_max((_S348), (0.0f))));
    bool _S350 = (lobes_1.alphas.x) > 0.0f;
    if(_S350)
    {
        float3  _S351 = anisotropicLocal(l_1, lobes_1.tangent, n_i_3);
        float _S352 = anisotropicG1(_S351, lobes_1.alphas);
        G1_l_0 = _S352;
    }
    else
    {
        G1_l_0 = _S349;
    }
    return make_float3 (lobes_1.reflect_weight * G1_l_0) * lobes_1.F / make_float3 (lobes_1.p_reflect);
}

__device__ __forceinline__ SampleBSDF connectBSDF(float3  in_dir_1, float3  out_dir_0, float3  n_6, BSDFMaterial material_4, float eta_i_3, float eta_o_3, uint lobe_4, uint random_init_0)
{
    uint random_state_3 = random_init_0;
    float3  _S353 = negate_0(in_dir_1);
    float _S354 = dot_0(n_6, _S353);
    float _S355 = sign_0(_S354);
    float3  _S356 = n_6 * make_float3 (_S355);
    float _S357 = material_4.roughness;
    float _S358 = _S357 * _S357;
    AnisotropicFrame _S359 = anisotropicFrame(material_4, _S356);
    float3  _S360 = _S353 + out_dir_0;
    float3  _S361 = ((((_S360)) * make_float3(rnorm3df(((_S360)).x, ((_S360)).y, ((_S360)).z))));
    bool _S362 = lobe_4 == 0U;
    float3  ggx_n_1;
    if(_S362)
    {
        float3  _S363 = sampleMaterialHalfVector(_S353, _S356, _S358, _S359, &random_state_3);
        ggx_n_1 = _S363;
    }
    else
    {
        bool _S364 = lobe_4 == 1U;
        if(_S364)
        {
            float3  _S365 = negate_0(make_float3 (eta_i_3) * _S353 + make_float3 (eta_o_3) * out_dir_0);
            float3  _S366 = ((((_S365)) * make_float3(rnorm3df(((_S365)).x, ((_S365)).y, ((_S365)).z))));
            float _S367 = sign_0(dot_0(_S365, _S356));
            float3  _S368 = _S366 * make_float3 (_S367);
            ggx_n_1 = _S368;
        }
        else
        {
            ggx_n_1 = _S361;
        }
    }
    BSDFLobes _S369 = bsdfLobes(in_dir_1, _S353, _S356, ggx_n_1, material_4, eta_i_3, eta_o_3, _S359);
    BSDFLobes lobes_2 = _S369;
    float _S370 = translucentShare(material_4);
    (&lobes_2)->translucent_share = _S370;
    float _S371 = lobeDensity(dot_0(_S356, out_dir_0), dot_0(out_dir_0, ggx_n_1), (F32_abs((_S354))), _S358, lobes_2, eta_i_3, eta_o_3, lobe_4);
    bool _S372 = !(_S371 > 0.0f);
    if(_S372)
    {
        float3  _S373 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S373, _S373, 0U, false, 0U, 0.0f);
    }
    float3  _S374 = lobeThroughput(out_dir_0, _S356, _S358, material_4, lobes_2, lobe_4);
    return SampleBSDF_x24init_0(out_dir_0, _S374, random_state_3, lobe_4 == 1U, lobe_4, _S371);
}

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_2, float3  dir_5, float3  n_7, BSDFMaterial material_5, float eta_i_4, float eta_o_4, bool refracted_3, float pdf_2, bool power_0, uint random_state_4)
{
    float3  _S375 = make_float3 (0.0f);
    uint lobe_5 = 0U;
    float3  f_0 = _S375;
    for(;;)
    {
        if(lobe_5 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S376 = lobe_5 == 0U;
        if(_S376)
        {
        }
        bool _S377;
        if(_S376)
        {
            float _S378 = rgb_to_greyscale(material_5.translucent);
            _S377 = _S378 > 0.0f;
        }
        else
        {
            _S377 = false;
        }
        bool _S379;
        if(_S377)
        {
            float _S380 = dot_0(n_7, dir_5);
            float3  _S381 = negate_0(in_dir_2);
            _S379 = ((_S380 * dot_0(n_7, _S381)) < 0.0f) == refracted_3;
        }
        else
        {
            _S379 = (lobe_5 == 1U) == refracted_3;
        }
        float3  f_1;
        if(_S379)
        {
            SampleBSDF _S382 = connectBSDF(in_dir_2, dir_5, n_7, material_5, eta_i_4, eta_o_4, lobe_5, random_state_4);
            bool _S383 = (_S382.pdf) > 0.0f;
            if(_S383)
            {
                if(power_0)
                {
                    float _S384 = _S382.pdf / pdf_2;
                    float3  f_2 = f_0 + _S382.throughput * make_float3 (_S382.pdf) / make_float3 (pdf_2 * (1.0f + _S384 * _S384));
                    f_1 = f_2;
                }
                else
                {
                    float3  f_3 = f_0 + _S382.throughput * make_float3 (_S382.pdf) / make_float3 (_S382.pdf + pdf_2);
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
    bool _S385 = wrongSide_0(is_inside_2, false, dir_6, side_n_1);
    float3  _S386 = neeBSDF(in_dir_3, dir_6, surface_1.smooth_n, surface_1.material, eta_1.x, eta_1.y, _S385, pdf_3, false, random_state_5);
    return _S386;
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
    SkySample _S387;
    (&_S387)->dir = dir_7;
    (&_S387)->radiance = radiance_0;
    (&_S387)->color = color_0;
    (&_S387)->random_state = random_state_6;
    return _S387;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float3  side_n_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0)
{
    uint2  _S388 = (fcptEnvironmentCdfSize());
    uint2  _S389 = make_uint2 (1U, 0U);
    uint2  _S390 = _S388 - _S389;
    Random _S391 = pcg(init_random_state_0);
    Random _S392 = pcg(_S391.state);
    Random _S393 = pcg(_S392.state);
    Random _S394 = pcg(_S393.state);
    uint _S395 = _S390.x;
    uint _S396 = searchCDF_0(make_uint2 (_S395, 0U), make_uint2 (0U, 1U), _S390.y, _S391.value);
    uint _S397 = searchCDF_0(make_uint2 (0U, _S396), _S389, _S395, _S392.value);
    float2  _S398 = make_float2 ((float)_S390.x, (float)_S390.y);
    float2  _S399 = (make_float2 (float(_S397), float(_S396)) + make_float2 (_S393.value, _S394.value)) / _S398 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S400 = _S399.y;
    float _S401 = (F32_sin((_S400)));
    float _S402 = _S399.x;
    float3  _S403 = make_float3 (_S401 * (F32_cos((_S402))), (F32_cos((_S400))), _S401 * (F32_sin((_S402))));
    float _S404 = environmentPdf_0(_S403);
    float3  _S405 = skyBSDF(ray_0->unit_direction, _S403, *surface_2, side_n_2, eta_2, is_inside_3, _S404, lobe_state_0);
    bool _S406 = !(_S404 > 0.0f);
    bool _S407;
    if(_S406)
    {
        _S407 = true;
    }
    else
    {
        _S407 = all_0(_S405 == make_float3 (0.0f));
    }
    if(_S407)
    {
        float3  _S408 = make_float3 (0.0f);
        return SkySample_x24init_0(_S403, _S408, _S408, _S394.state);
    }
    float3  _S409 = skyRadiance_0(ray_0->origin, surface_2, side_n_2, is_inside_3, _S403);
    return SkySample_x24init_0(_S403, _S409, _S405 * _S409, _S394.state);
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
    TreeSample _S410;
    (&_S410)->dir = dir_8;
    (&_S410)->radiance = radiance_1;
    (&_S410)->density = density_0;
    (&_S410)->random_state = random_state_7;
    return _S410;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_3, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S411 = importance(first_1, p_3, normal_3);
    float _S412 = importance(second_1, p_3, normal_3);
    float2  _S413 = make_float2 (_S411, _S412);
    bool _S414 = _S411 == 0.0f;
    bool _S415;
    if(_S414)
    {
        _S415 = _S412 == 0.0f;
    }
    else
    {
        _S415 = false;
    }
    if(_S415)
    {
        return 2U;
    }
    float _S416 = _S411 + _S412;
    bool _S417 = _S412 > 0.0f;
    if(_S417)
    {
        _S415 = (*pick_0 * _S416) >= _S411;
    }
    else
    {
        _S415 = false;
    }
    uint _S418 = uint(_S415);
    float _S419 = (F32_min(((*pick_0 * _S416 - float(_S418) * _S411) / _slang_vector_get_element(_S413, _S418)), (0.99999994039535522f)));
    *pick_0 = _S419;
    float _S420 = *probability_3 * (_slang_vector_get_element(_S413, _S418) / _S416);
    *probability_3 = _S420;
    return _S418;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_4, float u1_0, float u2_0)
{
    float3  _S421 = center_1 - p_4;
    float _S422 = radius_1 * radius_1 / dot_0(_S421, _S421);
    float _S423 = u1_0 * _S422 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S422), (0.0f)))))));
    float _S424 = 2.0f * u1_0;
    bool _S425 = _S422 >= 1.0f;
    float _S426 = _slang_select(_S425, _S424,_S423);
    float _S427 = (F32_sqrt(((F32_max((_S426 * (2.0f - _S426)), (0.0f))))));
    float _S428 = 6.28318548202514648f * u2_0;
    float3  _S429 = make_float3 (_S427 * (F32_cos((_S428))), 1.0f - _S426, _S427 * (F32_sin((_S428))));
    float3  _S430 = ((((_S421)) * make_float3(rnorm3df(((_S421)).x, ((_S421)).y, ((_S421)).z))));
    float3  _S431 = tangentToWorld(_S429, _S430);
    return _S431;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S432 = center_2 - ray_1->origin;
    float _S433 = dot_0(_S432, ray_1->unit_direction);
    float _S434 = dot_0(_S432, _S432) - _S433 * _S433;
    float _S435 = radius_3 * radius_3;
    bool _S436 = _S434 > _S435;
    if(_S436)
    {
        return 4.294967296e+09f;
    }
    float _S437 = (F32_sqrt((_S435 - _S434)));
    float _S438 = _S433 - _S437;
    float _S439 = _S433 + _S437;
    bool _S440 = _S438 > 0.0000152587890625f;
    bool _S441;
    if(_S440)
    {
        _S441 = _S438 < max_len_0;
    }
    else
    {
        _S441 = false;
    }
    if(_S441)
    {
        return _S438;
    }
    bool _S442 = _S439 > 0.0000152587890625f;
    if(_S442)
    {
        _S441 = _S439 < max_len_0;
    }
    else
    {
        _S441 = false;
    }
    if(_S441)
    {
        return _S439;
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
    FKHit _S443;
    (&_S443)->uv = uv_0;
    (&_S443)->instance_index = instance_index_0;
    (&_S443)->triangle_index = triangle_index_0;
    (&_S443)->is_point_light = is_point_light_0;
    (&_S443)->distance = distance_0;
    return _S443;
}

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_2, float3  end_0)
{
    float _S444 = sign_0(dot_0(light_n_0, start_2 - end_0));
    return light_n_0 * make_float3 (_S444 * light_offset_0);
}

static __device__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_1)
{
    Random _S445 = pcg(init_random_state_1);
    Random _S446 = pcg(_S445.state);
    Random _S447 = pcg(_S446.state);
    float3  _S448 = make_float3 (0.0f);
    TreeSample _S449 = TreeSample_x24init_0(_S448, _S448, 0.0f, _S447.state);
    TreeSample sample_0 = _S449;
    float3  _S450 = _slang_select(sided_0, _S448,smooth_n_2);
    float3  start_3 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S445.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S451 = (fcptLightNode((n_8)));
        if((_S451.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S452 = (fcptLightSecond((n_8)));
        uint _S453 = n_8 + 1U;
        LightNode _S454 = (fcptLightBounds((_S453)));
        LightNode _S455 = (fcptLightBounds((_S452)));
        uint _S456 = pickChild(_S454, _S455, origin_4, _S450, &pick_1, &probability_4);
        bool _S457 = _S456 > 1U;
        if(_S457)
        {
            return sample_0;
        }
        bool _S458 = _S456 == 1U;
        uint _S459 = _slang_select(_S458, _S452,_S453);
        n_8 = _S459;
    }
    bool _S460 = n_8 == 0U;
    bool _S461;
    if(_S460)
    {
        LightNode _S462 = (fcptLightBounds((0U)));
        float _S463 = importance(_S462, origin_4, _S450);
        _S461 = !(_S463 > 0.0f);
    }
    else
    {
        _S461 = false;
    }
    if(_S461)
    {
        return sample_0;
    }
    uint4  _S464 = (fcptLightNode((n_8)));
    bool _S465 = (_S464.x) == 2U;
    float3  start_4;
    float3  lift_n_0;
    float3  shadow_1;
    if(_S465)
    {
        FKLight _S466 = (fcptLight((_S464.y)));
        if(sided_0)
        {
            float _S467 = sign_0(dot_0(geometry_n_1, _S466.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S467);
            float3  _S468 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            start_4 = _S468;
            lift_n_0 = lift_n_1;
        }
        else
        {
            start_4 = start_3;
            lift_n_0 = smooth_n_2;
        }
        bool _S469 = (_S466.variance) == 0.0f;
        if(_S469)
        {
            float3  _S470 = _S466.position - start_4;
            float3  _S471 = ((((_S470)) * make_float3(rnorm3df(((_S470)).x, ((_S470)).y, ((_S470)).z))));
            (&sample_0)->dir = _S471;
            float3  _S472 = _S466.color * make_float3 (_S466.intensity) / make_float3 (dot_0(_S470, _S470) * probability_4);
            (&sample_0)->radiance = _S472;
            shadow_1 = _S470;
        }
        else
        {
            float3  _S473 = sampleSphere(_S466.position, _S466.variance, start_4, _S446.value, _S447.value);
            (&sample_0)->dir = _S473;
            float _S474 = sphereDensity(_S466.position, _S466.variance, start_4);
            float _S475 = probability_4 * _S474;
            (&sample_0)->density = _S475;
            float3  _S476 = pointLightRadiance(_S466.color, _S466.intensity, _S466.variance);
            float3  _S477 = _S476 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S477;
            FKRay _S478 = Ray_x24init_0(start_4, (&sample_0)->dir);
            float _S479 = raySphere_0(_S466.position, _S466.variance, &_S478, 4.294967296e+09f);
            float3  _S480 = (&sample_0)->dir * make_float3 (_S479);
            shadow_1 = _S480;
        }
    }
    else
    {
        uint _S481 = _S464.y;
        uint _S482 = (fcptTriangleOffset((_S481)));
        uint _S483 = _S482 + _S464.z;
        Matrix<float, 3, 3>  _S484 = (fcptWorldTriangle((_S481), (_S483)));
        float _S485 = (F32_sqrt((_S446.value)));
        float2  _S486 = make_float2 (_S485 * (1.0f - _S447.value), _S485 * _S447.value);
        float3  _S487 = mul_0(make_float3 (1.0f - _S485, _S486.x, _S486.y), _S484);
        if(sided_0)
        {
            float _S488 = sign_0(dot_0(geometry_n_1, _S487 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S488);
            float3  _S489 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            start_4 = _S489;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S490 = !((dot_0(smooth_n_2, _S487 - start_3)) > 0.0f);
            if(_S490)
            {
                return sample_0;
            }
            start_4 = start_3;
            lift_n_0 = smooth_n_2;
        }
        FKSurface _S491 = (fcptSurfaceAt((Hit_x24init_0(_S486, _S481, _S483, 0U, 0.0f)), (_S487), (_S447.state)));
        (&sample_0)->random_state = _S491.random_state;
        float3  _S492 = _S487 - start_4;
        float3  _S493 = ((((_S492)) * make_float3(rnorm3df(((_S492)).x, ((_S492)).y, ((_S492)).z))));
        (&sample_0)->dir = _S493;
        float _S494 = solidAngle(probability_4, cross_0(_S484.rows[int(1)] - _S484.rows[int(0)], _S484.rows[int(2)] - _S484.rows[int(0)]), _S492);
        (&sample_0)->density = _S494;
        float _S495 = sign_0(dot_0(- (&sample_0)->dir, _S491.smooth_n));
        float3  _S496 = _S491.material.emissive * make_float3 ((F32_max((_S495), (0.0f))));
        float3  _S497 = _slang_select(_S491.skip, _S448,_S496);
        float3  _S498 = _S497 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S498;
        float3  _S499 = shadowLift(_S491.smooth_n, _S491.geometry_offset, start_4, _S487);
        float3  _S500 = _S487 + _S499 - start_4;
        shadow_1 = _S500;
    }
    float3  _S501 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_1, _S447.state);
    float3  _S502 = (&sample_0)->radiance * _S501;
    bool _S503 = all_0(_S501 == _S448);
    float3  _S504 = _slang_select(_S503, _S448,_S502);
    (&sample_0)->radiance = _S504;
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
    float _S505 = 1.0f / (1.0f + b_0 / a_4 * (b_0 / a_4));
    bool _S506 = b_0 > 0.0f;
    float _S507 = _slang_select(_S506, _S505,1.0f);
    return _S507;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_0, float3  light_point_1)
{
    bool _S508 = vertex_0->none;
    if(_S508)
    {
        return 1.0f;
    }
    uint _S509 = (fcptLightSlot((*hit_0)));
    float _S510 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S509, light_point_1);
    float _S511 = powerHeuristic(vertex_0->pdf, _S510);
    return _S511;
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
    Shift _S512;
    (&_S512)->f = f_4;
    (&_S512)->jac = jac_0;
    return _S512;
}

static __device__ uint extractBits_0(uint e_1, uint offset_0, uint count_1)
{
    return (e_1 >> offset_0) & ((1U << count_1) - 1U);
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_5)
{
    NEEVertex _S513;
    (&_S513)->none = none_0;
    (&_S513)->pdf = pdf_4;
    (&_S513)->origin = origin_5;
    (&_S513)->smooth_n = smooth_n_3;
    (&_S513)->start = start_5;
    return _S513;
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
    Vertex _S514;
    (&_S514)->rough = rough_0;
    (&_S514)->lobe = lobe_7;
    (&_S514)->pdf = pdf_5;
    (&_S514)->cos = cos_0;
    (&_S514)->inside = inside_0;
    return _S514;
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S515 = hash(index_0);
    uint _S516 = hash(seed_0 ^ _S515);
    return _S516;
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
    float3  _S517 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_1));
    float3  _S518 = scatter_0 * _S517 / make_float3 (sigma_1);
    float3  _S519 = _slang_select(scatters_0, _S518,_S517);
    return _S519;
}

static __device__ uint arrivalLobe_0(uint b_1, uint prev_lobe_0)
{
    bool _S520 = b_1 > 0U;
    uint _S521 = _slang_select(_S520, prev_lobe_0,3U);
    return _S521;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_8, bool surface_3, float length_2, float width_0)
{
    ShadowContext _S522;
    (&_S522)->extinction_behind = extinction_behind_0;
    (&_S522)->extinction_front = extinction_front_0;
    (&_S522)->fillings = fillings_0;
    (&_S522)->side = side_0;
    (&_S522)->depth = depth_1;
    (&_S522)->lobe = lobe_8;
    (&_S522)->surface = surface_3;
    (&_S522)->length = length_2;
    (&_S522)->width = width_0;
    return _S522;
}

static __device__ bool scatterSampled_0(bool replay_0, uint b_2, uint stop_0, bool varying_0)
{
    bool _S523 = !replay_0;
    bool _S524;
    if(_S523)
    {
        _S524 = true;
    }
    else
    {
        bool _S525 = b_2 == stop_0;
        if(_S525)
        {
            _S524 = !varying_0;
        }
        else
        {
            _S524 = false;
        }
    }
    return _S524;
}

__device__ float3  safeDivide(float3  a_5, float3  b_3)
{
    float3  _S526 = a_5 / b_3;
    float3  _S527 = make_float3 (0.0f);
    bool3  _S528 = b_3 == _S527;
    float3  _S529 = _slang_select(_S528, _S527,_S526);
    return _S529;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S530 = (1U << count_2) - 1U;
    return (e_2 & (~(_S530 << offset_1))) | ((newbits_0 & _S530) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_1, float3  f_5)
{
    Reservoir candidate_0 = r_2;
    uint _S531 = insertBits_0(r_2.path, end_1, 0U, 5U);
    uint _S532 = insertBits_0(_S531, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S532;
    (&candidate_0)->f = f_5;
    return candidate_0;
}

__device__ void offer(Selection * sel_0, Reservoir candidate_1, float3  weight_0)
{
    float _S533 = rgb_to_greyscale(weight_0);
    bool _S534 = _S533 > 0.0f;
    bool _S535;
    if(_S534)
    {
        _S535 = _S533 < 3.00000000549775576e+38f;
    }
    else
    {
        _S535 = false;
    }
    bool _S536 = !_S535;
    if(_S536)
    {
        return;
    }
    bool _S537 = sel_0->sums;
    if(_S537)
    {
        float3  _S538 = sel_0->color + weight_0;
        sel_0->color = _S538;
        return;
    }
    float _S539 = sel_0->w_sum + _S533;
    sel_0->w_sum = _S539;
    float3  _S540 = sel_0->color + weight_0;
    sel_0->color = _S540;
    Random _S541 = pcg(sel_0->random_state);
    sel_0->random_state = _S541.state;
    bool _S542 = (_S541.value * sel_0->w_sum) <= _S533;
    if(_S542)
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
    Random _S543 = pcg(random_state_8);
    Random _S544 = pcg(_S543.state);
    float _S545 = 1.0f - 2.0f * _S543.value;
    float _S546 = (F32_sqrt(((F32_max((1.0f - _S545 * _S545), (0.0f))))));
    float _S547 = 6.28318548202514648f * _S544.value;
    return make_float3 (_S546 * (F32_cos((_S547))), _S546 * (F32_sin((_S547))), _S545);
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2)
{
    BSDFMaterial _S548;
    (&_S548)->albedo = albedo_0;
    (&_S548)->emissive = emissive_0;
    (&_S548)->roughness = roughness_0;
    (&_S548)->metallic = metallic_0;
    (&_S548)->transmission = transmission_0;
    (&_S548)->ior = ior_0;
    (&_S548)->absorption = absorption_0;
    (&_S548)->specular_tint = specular_tint_0;
    (&_S548)->specular_level = specular_level_0;
    (&_S548)->translucent = translucent_0;
    (&_S548)->sheen = sheen_2;
    (&_S548)->sheen_roughness = sheen_roughness_0;
    (&_S548)->anisotropy = anisotropy_0;
    (&_S548)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S548)->tangent = tangent_2;
    return _S548;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1)
{
    FKMedium _S549;
    (&_S549)->scatter = scatter_1;
    (&_S549)->extinction = extinction_1;
    return _S549;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_6, bool skip_0, uint random_state_9, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0)
{
    FKSurface _S550;
    (&_S550)->smooth_n = smooth_n_4;
    (&_S550)->geometry_n = geometry_n_2;
    (&_S550)->geometry_offset = geometry_offset_2;
    (&_S550)->material = *material_6;
    (&_S550)->skip = skip_0;
    (&_S550)->random_state = random_state_9;
    (&_S550)->coverage = coverage_0;
    (&_S550)->encloses = encloses_0;
    (&_S550)->volume = *volume_0;
    (&_S550)->fills = fills_0;
    return _S550;
}

static __device__ FKSurface emitting_0(FKSurface * surface_4, bool top_0)
{
    FKSurface lower_0 = *surface_4;
    float3  _S551 = (&surface_4->material)->emissive;
    float3  _S552 = make_float3 (0.0f);
    bool _S553 = !top_0;
    float3  _S554 = _slang_select(_S553, _S552,_S551);
    (&(&lower_0)->material)->emissive = _S554;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_5, float u_2)
{
    float _S555 = surface_5->coverage;
    bool _S556 = u_2 < _S555;
    if(_S556)
    {
        return *surface_5;
    }
    float3  _S557 = make_float3 (0.0f);
    float3  _S558 = make_float3 (1.0f);
    BSDFMaterial _S559 = Material_x24init_0(_S557, _S557, 0.0f, 0.0f, 0.0f, 0.0f, _S557, _S558, 1.0f, _S557, _S557, 0.5f, 0.0f, 0.0f, _S557);
    BSDFMaterial material_7 = _S559;
    (&material_7)->albedo = _S558;
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
    bool _S560 = transmission_1 > 0.0f;
    bool _S561;
    if(_S560)
    {
        _S561 = true;
    }
    else
    {
        _S561 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S562;
    if(_S561)
    {
        _S562 = 1.0f;
    }
    else
    {
        _S562 = -1.0f;
    }
    return _S562;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_6, float3  dir_9)
{
    float3  _S563 = surface_6->geometry_n;
    float _S564 = facingSign((&surface_6->material)->transmission, surface_6->geometry_n, dir_9);
    FKSurface faced_0 = *surface_6;
    float3  _S565 = surface_6->smooth_n * make_float3 (_S564);
    (&faced_0)->smooth_n = _S565;
    float3  _S566 = _S563 * make_float3 (_S564);
    (&faced_0)->geometry_n = _S566;
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
    float3  _S567 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_2) * log_0(_S567));
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
    bool _S568;
    if(open_0)
    {
        _S568 = prev_rough_0;
    }
    else
    {
        _S568 = false;
    }
    if(_S568)
    {
        _S568 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S568 = false;
    }
    return _S568;
}

static __device__ float2  vertexEta_0(BSDFMaterial * material_8, float n_dot_v_0)
{
    bool _S569 = n_dot_v_0 < 0.0f;
    float _S570 = material_8->ior;
    float _S571 = _slang_select(_S569, _S570,1.0f);
    float _S572 = _slang_select(_S569, 1.0f,_S570);
    return make_float2 (_S571, _S572);
}

__device__ bool samplesLights(BSDFMaterial material_9)
{
    bool _S573 = (material_9.roughness) > 0.0f;
    bool _S574;
    if(_S573)
    {
        _S574 = true;
    }
    else
    {
        bool _S575 = (material_9.metallic) < 1.0f;
        if(_S575)
        {
            _S574 = (material_9.transmission) < 1.0f;
        }
        else
        {
            _S574 = false;
        }
    }
    return _S574;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_10)
{
    float _S576 = rgb_to_greyscale(material_10->translucent);
    return _S576 > 0.0f;
}

__device__ float3  sideNormal(FKSurface surface_7, float3  in_dir_4)
{
    bool _S577 = !((surface_7.material.transmission) > 0.0f);
    bool _S578;
    if(_S577)
    {
        BSDFMaterial _S579 = surface_7.material;
        bool _S580 = isTranslucent_0(&_S579);
        _S578 = !_S580;
    }
    else
    {
        _S578 = false;
    }
    if(_S578)
    {
        _S578 = (dot_0(surface_7.smooth_n, - in_dir_4)) > 0.0f;
    }
    else
    {
        _S578 = false;
    }
    float3  _S581 = _slang_select(_S578, surface_7.smooth_n,surface_7.geometry_n);
    return _S581;
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
    MediumSides _S582;
    (&_S582)->behind = *behind_0;
    (&_S582)->front = *front_0;
    (&_S582)->fillings = fillings_1;
    (&_S582)->face = face_1;
    return _S582;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_11)
{
    float3  _S583 = surface_8->geometry_n;
    MediumSides _S584 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S584;
    bool _S585 = surface_8->encloses;
    if(_S585)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S586 = (dot_0(dir_11, _S583)) > 0.0f;
        if(_S586)
        {
            float3  _S587 = make_float3 (0.0f);
            FKMedium _S588 = Medium_x24init_0(_S587, _S587);
            (&sides_0)->front = _S588;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  side_n_3, float3  extinction_2, uint filling_1, float3  dir_12, uint depth_2, uint lobe_9, float length_3, float width_1)
{
    FKSurface faced_1 = *surface_9;
    float3  _S589 = surface_9->geometry_n;
    float3  _S590 = - surface_9->geometry_n;
    float3  _S591 = _slang_select(turned_0, _S590,_S589);
    (&faced_1)->geometry_n = _S591;
    FKMedium _S592 = Medium_x24init_0(make_float3 (0.0f), extinction_2);
    FKSurface _S593 = faced_1;
    FKMedium _S594 = _S592;
    MediumSides _S595 = mediumSides_0(&_S593, &_S594, filling_1, dir_12);
    ShadowContext _S596 = ShadowContext_x24init_0(_S595.behind.extinction, _S595.front.extinction, _S595.fillings, side_n_3, depth_2, lobe_9, true, length_3, width_1);
    ShadowContext context_2;
    if(turned_0)
    {
        uint2  _S597 = _S595.fillings;
        ShadowContext _S598 = ShadowContext_x24init_0(_S595.front.extinction, _S595.behind.extinction, uint2 {_S597.y, _S597.x}, side_n_3, depth_2, lobe_9, true, length_3, width_1);
        context_2 = _S598;
    }
    else
    {
        context_2 = _S596;
    }
    return context_2;
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_5, float3  out_dir_1, float3  n_10, float3  g_n_0, BSDFMaterial material_11, float eta_i_5, float eta_o_5, uint random_state_10)
{
    float3  _S599 = negate_0(in_dir_5);
    bool _S600 = (dot_0(g_n_0, _S599) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S600)
    {
        SampleBSDF _S601 = connectBSDF(in_dir_5, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 0U, random_state_10);
        SampleBSDF _S602 = connectBSDF(in_dir_5, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 2U, random_state_10);
        return _S601.throughput * make_float3 (_S601.pdf) + _S602.throughput * make_float3 (_S602.pdf);
    }
    SampleBSDF _S603 = connectBSDF(in_dir_5, out_dir_1, n_10, material_11, eta_i_5, eta_o_5, 1U, random_state_10);
    return _S603.throughput * make_float3 (_S603.pdf);
}

__device__ float3  translucentCorrection(float3  in_dir_6, float3  out_dir_2, float3  n_11, float3  g_n_1, BSDFMaterial material_12, float eta_i_6, float eta_o_6, uint random_state_11)
{
    float _S604 = dot_0(n_11, out_dir_2);
    float3  _S605 = negate_0(in_dir_6);
    bool _S606 = (_S604 * dot_0(n_11, _S605)) < 0.0f;
    SampleBSDF _S607 = connectBSDF(in_dir_6, out_dir_2, n_11, material_12, eta_i_6, eta_o_6, 0U, random_state_11);
    float3  _S608 = negate_0(in_dir_6);
    bool _S609 = (dot_0(g_n_1, _S608) * dot_0(g_n_1, out_dir_2)) > 0.0f;
    float3  _S610 = make_float3 (0.0f);
    float3  _S611 = _S607.throughput * make_float3 (_S607.pdf);
    float _S612 = _slang_select(_S609, -1.0f,1.0f);
    float3  _S613 = _S611 * make_float3 (_S612);
    float3  _S614 = _slang_select(_S606, _S613,_S610);
    return _S614;
}

__device__ float3  translucentBSDF(float3  in_dir_7, float3  out_dir_3, float3  n_12, float3  g_n_2, BSDFMaterial material_13, float eta_i_7, float eta_o_7, uint random_state_12)
{
    float3  _S615 = BSDF(in_dir_7, out_dir_3, n_12, g_n_2, material_13, eta_i_7, eta_o_7, random_state_12);
    float3  _S616 = translucentCorrection(in_dir_7, out_dir_3, n_12, g_n_2, material_13, eta_i_7, eta_o_7, random_state_12);
    return _S615 + _S616;
}

static __device__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_0, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_14, float eta_i_8, float eta_o_8, bool competing_0, uint random_state_13)
{
    bool _S617 = !competing_0;
    bool _S618;
    if(_S617)
    {
        _S618 = true;
    }
    else
    {
        _S618 = (light_0->density) == 0.0f;
    }
    if(_S618)
    {
        bool _S619 = isTranslucent_0(material_14);
        if(_S619)
        {
            float3  _S620 = translucentBSDF(in_dir_8, light_0->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_8, eta_o_8, random_state_13);
            return _S620 * light_0->radiance;
        }
        float3  _S621 = BSDF(in_dir_8, light_0->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_8, eta_o_8, random_state_13);
        return _S621 * light_0->radiance;
    }
    float3  _S622 = light_0->dir;
    bool _S623 = (dot_0(geometry_n_4, - in_dir_8) * dot_0(geometry_n_4, light_0->dir)) <= 0.0f;
    float3  _S624 = neeBSDF(in_dir_8, _S622, smooth_n_5, *material_14, eta_i_8, eta_o_8, _S623, light_0->density, true, random_state_13);
    return _S624 * light_0->radiance * make_float3 (light_0->density);
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S625 = (F32_sqrt((random_1_0)));
    float _S626 = 6.28318548202514648f * random_2_0;
    float _S627 = _S625 * (F32_cos((_S626)));
    float _S628 = _S625 * (F32_sin((_S626)));
    float _S629 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S627 * _S627 - _S628 * _S628))))));
    return make_float3 (_S627, _S629, _S628);
}

static __device__ float3  reflect_0(float3  i_8, float3  n_13)
{
    return i_8 - make_float3 (2.0f * dot_0(n_13, i_8)) * n_13;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_9, float3  n_14, BSDFMaterial material_15, float eta_i_9, float eta_o_9, uint random_init_1, float2  screen_space_0)
{
    uint random_state_14 = random_init_1;
    float3  _S630 = negate_0(in_dir_9);
    float _S631 = dot_0(n_14, _S630);
    float _S632 = sign_0(_S631);
    float3  n_i_4 = n_14 * make_float3 (_S632);
    float _S633 = (F32_abs((_S631)));
    float _S634 = material_15.roughness;
    float _S635 = _S634 * _S634;
    AnisotropicFrame _S636 = anisotropicFrame(material_15, n_i_4);
    float3  _S637 = sampleMaterialHalfVector(_S630, n_i_4, _S635, _S636, &random_state_14);
    BSDFLobes _S638 = bsdfLobes(in_dir_9, _S630, n_i_4, _S637, material_15, eta_i_9, eta_o_9, _S636);
    BSDFLobes lobes_3 = _S638;
    float _S639 = translucentShare(material_15);
    (&lobes_3)->translucent_share = _S639;
    float3  _S640 = make_float3 (1.0f);
    SampleBSDF _S641 = SampleBSDF_x24init_0(_S640, _S640, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S641;
    Random _S642 = pcg(random_state_14);
    random_state_14 = _S642.state;
    bool _S643 = (_S642.value) < ((&lobes_3)->p_diffuse);
    if(_S643)
    {
        Random _S644 = pcg(random_state_14);
        Random _S645 = pcg(_S644.state);
        (&sample_1)->random_state = _S645.state;
        float3  _S646 = sampleCosWeightedHemisphere(_S644.value, _S645.value);
        bool _S647 = (_S642.value) < ((&lobes_3)->p_diffuse * (&lobes_3)->translucent_share);
        float _S648 = _S646.y;
        float _S649 = - _S648;
        float _S650 = _slang_select(_S647, _S649,_S648);
        float3  _S651 = tangentToWorld(make_float3 (_S646.x, _S650, _S646.z), n_i_4);
        (&sample_1)->unit_direction = _S651;
        float3  _S652 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S635, material_15, lobes_3, 0U);
        (&sample_1)->throughput = _S652;
        float _S653 = lobeDensity(_S650, 0.0f, _S633, _S635, lobes_3, eta_i_9, eta_o_9, 0U);
        (&sample_1)->pdf = _S653;
        (&sample_1)->refracted = _S647;
        return sample_1;
    }
    bool _S654 = (_S642.value) < ((&lobes_3)->p_diffuse + (&lobes_3)->p_refract);
    if(_S654)
    {
        (&sample_1)->unit_direction = (&lobes_3)->refracted;
        float _S655 = lobeDensity(0.0f, dot_0((&sample_1)->unit_direction, _S637), _S633, _S635, lobes_3, eta_i_9, eta_o_9, 1U);
        (&sample_1)->pdf = _S655;
        float3  _S656 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S635, material_15, lobes_3, 1U);
        (&sample_1)->throughput = _S656;
        (&sample_1)->random_state = random_state_14;
        (&sample_1)->refracted = true;
        (&sample_1)->lobe = 1U;
        return sample_1;
    }
    float3  _S657 = reflect_0(in_dir_9, _S637);
    float3  _S658 = ((((_S657)) * make_float3(rnorm3df(((_S657)).x, ((_S657)).y, ((_S657)).z))));
    (&sample_1)->unit_direction = _S658;
    float3  _S659 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S635, material_15, lobes_3, 2U);
    (&sample_1)->throughput = _S659;
    (&sample_1)->random_state = random_state_14;
    (&sample_1)->lobe = 2U;
    float _S660 = lobeDensity(0.0f, 0.0f, _S633, _S635, lobes_3, eta_i_9, eta_o_9, 2U);
    (&sample_1)->pdf = _S660;
    return sample_1;
}

__device__ bool withinInverseFootprint(float pdf_6, bool diffuse_0, float prev_cos_0, float distance_4, float threshold_1)
{
    bool _S661 = pdf_6 > 0.0f;
    bool _S662;
    if(_S661)
    {
        if(diffuse_0)
        {
            _S662 = true;
        }
        else
        {
            _S662 = (pdf_6 * prev_cos_0 / (distance_4 * distance_4) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S662 = false;
    }
    return _S662;
}

__device__ bool roughLobe(float pdf_7, bool diffuse_1, float roughness_1)
{
    bool _S663 = pdf_7 > 0.0f;
    bool _S664;
    if(_S663)
    {
        if(diffuse_1)
        {
            _S664 = true;
        }
        else
        {
            _S664 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S664 = false;
    }
    return _S664;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S665 = layers_0 > 1U;
    bool _S666;
    if(_S665)
    {
        _S666 = refracting_0 != passed_0;
    }
    else
    {
        _S666 = false;
    }
    return _S666;
}

static __device__ float widened_0(float spread_0, float pdf_8, bool delta_0)
{
    float _S667 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_8))))), (3.14159274101257324f)));
    bool _S668 = !delta_0;
    float _S669 = _slang_select(_S668, _S667,0.0f);
    return spread_0 + _S669;
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
    int _S670;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_3;
    float sky_pdf_1;
    float width_4;
    uint b_5;
    float spread_3;
    Shift arrived_end_0;
    float3  _S671 = make_float3 (0.0f);
    Shift _S672 = Shift_x24init_0(_S671, 0.0f);
    uint _S673 = r_3->path;
    uint _S674 = extractBits_0(r_3->path, 0U, 5U);
    uint _S675 = extractBits_0(_S673, 5U, 5U);
    uint _S676 = extractBits_0(_S673, 10U, 2U);
    uint _S677 = extractBits_0(_S673, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S678 = _S677 >= 3U;
        uint _S679 = _slang_select(_S678, 1U,0U);
        uint _S680 = _S674 + _S679;
        uint _S681 = (fcptMaxBounces());
        passes_0 = _S680 > _S681;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S672;
    }
    uint _S682 = _S675 - 1U;
    bool _S683 = _S677 == 3U;
    uint _S684 = _slang_select(_S683, 1U,0U);
    uint _S685 = _S674 + _S684;
    bool _S686 = _S676 == 0U;
    uint _S687 = _slang_select(_S686, _S685,_S682);
    FKHit _S688 = (fcptReservoirHit((*r_3)));
    float3  _S689 = dom_0->x0;
    float3  _S690 = dom_0->x1 - dom_0->x0;
    float3  _S691 = ((((_S690)) * make_float3(rnorm3df(((_S690)).x, ((_S690)).y, ((_S690)).z))));
    FKRay _S692 = Ray_x24init_0(dom_0->x1, _S691);
    FKRay ray_2 = _S692;
    FKHit hit_1 = dom_0->hit;
    float3  scatter_in_0 = _S671;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S671;
    float3  extinction_in_0 = _S671;
    uint filling_2 = 4294967295U;
    float _S693 = dom_0->spread;
    float _S694 = dom_0->width;
    float _S695 = length_0(_S690);
    NEEVertex _S696 = NEEVertex_x24init_0(true, 0.0f, _S671, _S671, _S671);
    NEEVertex nee_vertex_0 = _S696;
    Vertex _S697 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S697;
    Reservoir _S698 = (Reservoir{});
    Reservoir chain_0 = _S698;
    uint _S699 = r_3->seed;
    (&chain_0)->seed = r_3->seed;
    (&ray_2)->origin = _S689;
    (&hit_1)->distance = _S695;
    FKMedium _S700 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_1)->distance), (&filling_2)));
    scatter_in_0 = _S700.scatter;
    extinction_in_0 = _S700.extinction;
    Reservoir _S701 = chain_0;
    uint _S702 = filling_2;
    for(;;)
    {
        bool _S703 = _S702 != 4294967295U;
        float _S704 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        float _S705 = (fcptMajorant((_S702)));
        float _S706 = _slang_select(_S703, _S705,_S704);
        if(replay_1)
        {
            passes_0 = 4294967295U == _S687;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            passes_0 = _S676 == 1U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            passes_0 = _S706 > 0.0f;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            ended_0 = _S672;
            sky_pdf_0 = 0.0f;
            spread_1 = _S693;
            width_2 = _S694;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_4 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S707 = (&prev_0)->rough;
        if(_S707)
        {
            passes_0 = !(_S706 > 0.0f);
        }
        else
        {
            passes_0 = false;
        }
        (&prev_0)->rough = passes_0;
        uint _S708 = stream(_S699, 384U);
        uint tracking_0 = _S708;
        weight_1 = throughput_3;
        glowed_0 = _S671;
        b_4 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        spread_1 = _S693;
        width_2 = _S694;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_1)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S670 = int(1);
                break;
            }
            uint _S709 = b_4 + 320U;
            bool _S710 = b_4 == 4294967295U;
            uint _S711 = _slang_select(_S710, 384U,_S709);
            uint _S712 = stream(_S699, _S711);
            Random _S713 = pcg(_S712);
            float _S714 = freeFlight_0(_S713.value, _S706);
            if(_S703)
            {
                float3  _S715 = (&ray_2)->origin;
                float3  _S716 = (&ray_2)->unit_direction;
                float _S717 = (&hit_1)->distance;
                uint _S718 = _slang_select(_S710, 0U,b_4);
                uint _S719 = (&prev_0)->lobe;
                uint _S720 = _slang_select(_S710, 3U,_S719);
                float _S721 = (fcptTrackMedium((_S702), (_S715), (_S716), (_S717), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S718), (_S720)));
                threshold_2 = _S721;
            }
            else
            {
                threshold_2 = _S714;
            }
            bool _S722 = !(threshold_2 < ((&hit_1)->distance));
            if(_S722)
            {
                _S670 = int(1);
                break;
            }
            if(_S703)
            {
                passes_0 = !replay_1;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                float3  _S723 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S724 = sel_1->glow + _S723;
                sel_1->glow = _S724;
            }
            else
            {
            }
            glowed_0 = _S671;
            uint b_6 = b_4 + 1U;
            float3  _S725 = (&ray_2)->origin + make_float3 (threshold_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S725;
            float3  _S726 = flightWeight_0(scatter_in_0, extinction_in_0, _S706, threshold_2, true);
            float3  _S727 = weight_1;
            float3  _S728 = _slang_select(_S703, _S727,_S726);
            float3  throughput_4 = throughput_2 * _S728;
            uint _S729 = stream(_S699, b_6 + 320U);
            tracking_0 = _S729;
            weight_1 = throughput_3;
            float width_5 = width_2 + spread_1 * threshold_2;
            float _S730 = spread_1 + 3.14159274101257324f;
            uint _S731 = stream(_S699, b_6 + 64U);
            uint2  _S732 = make_uint2 (_S702);
            uint _S733 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            ShadowContext _S734 = ShadowContext_x24init_0(extinction_in_0, extinction_in_0, _S732, (&ray_2)->unit_direction, b_6, _S733, false, threshold_2, width_5);
            TreeSample _S735 = sampleLightTree_0((&ray_2)->origin, (&ray_2)->unit_direction, (&ray_2)->unit_direction, 0.0f, true, _S731, &_S734);
            bool _S736 = scatterSampled_0(replay_1, b_6, _S687, _S703);
            uint _S737 = (fcptMaxBounces());
            bool _S738 = b_6 < _S737;
            if(_S738)
            {
                is_inside_5 = (_S735.density) > 0.0f;
            }
            else
            {
                is_inside_5 = false;
            }
            float _S739 = _slang_select(is_inside_5, 0.07957746833562851f,0.0f);
            float3  _S740 = throughput_4 * _S735.radiance;
            float _S741 = powerHeuristic(_S735.density, _S739);
            float3  _S742 = _S740 * make_float3 (0.07957746833562851f * _S741);
            float3  _S743 = _slang_select(_S736, _S742,_S671);
            if(replay_1)
            {
                turned_1 = b_6 == _S687;
            }
            else
            {
                turned_1 = false;
            }
            if(turned_1)
            {
                bool _S744 = _S676 == 2U;
                if(_S744)
                {
                    float _S745 = rgb_to_greyscale(_S743);
                    passes_0 = _S745 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S746 = Shift_x24init_0(_S743, 1.0f);
                    _S670 = int(0);
                    ended_0 = _S746;
                    threshold_2 = _S730;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                _S670 = int(0);
                ended_0 = _S672;
                threshold_2 = _S730;
                geometry_density_2 = width_5;
                chain_throughput_0 = throughput_4;
                layer_0 = b_6;
                break;
            }
            bool _S747 = !replay_1;
            if(_S747)
            {
                Reservoir candidate_2 = _S701;
                uint _S748 = extractBits_0(_S701.path, 10U, 2U);
                bool _S749 = _S748 == 1U;
                if(_S749)
                {
                    float3  _S750 = safeDivide(_S743, _S671);
                    (&candidate_2)->radiance = _S750;
                }
                else
                {
                    uint _S751 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                    uint _S752 = insertBits_0(_S751, 2U, 10U, 2U);
                    (&candidate_2)->path = _S752;
                }
                Reservoir _S753 = withEnd(candidate_2, 0U, b_6, _S743);
                offer(sel_1, _S753, _S743 * make_float3 (scale_1) / make_float3 (density_2));
                float _S754 = survivalProbability(throughput_4, density_2);
                uint _S755 = stream(_S699, b_6 + 128U);
                Random _S756 = pcg(_S755);
                bool _S757 = _S754 < (_S756.value);
                if(_S757)
                {
                    scatter_2 = true;
                }
                else
                {
                    uint _S758 = (fcptMaxBounces());
                    scatter_2 = b_6 >= _S758;
                }
                if(scatter_2)
                {
                    _S670 = int(0);
                    ended_0 = _S672;
                    threshold_2 = _S730;
                    geometry_density_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                float _S759 = density_2 * _S754;
                density_2 = _S759;
            }
            else
            {
            }
            NEEVertex _S760 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_2)->origin, _S671, (&ray_2)->origin);
            nee_vertex_0 = _S760;
            uint _S761 = stream(_S699, b_6);
            float3  _S762 = isotropic_0(_S761);
            (&ray_2)->unit_direction = _S762;
            Vertex _S763 = scatteredVertex_0(false);
            prev_0 = _S763;
            float _S764 = (&prev_0)->pdf;
            FKHit _S765 = (fcptTraverseInstanceBVH((ray_2), (true), (4.294967296e+09f), (false)));
            hit_1 = _S765;
            b_4 = b_6;
            throughput_2 = throughput_4;
            spread_1 = _S730;
            width_2 = width_5;
            sky_pdf_0 = _S764;
        }
        if(_S670 != int(1))
        {
            spread_1 = threshold_2;
            width_2 = geometry_density_2;
            throughput_2 = chain_throughput_0;
            b_4 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S672;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    Reservoir _S766 = chain_0;
    NEEVertex _S767 = nee_vertex_0;
    Vertex _S768 = prev_0;
    FKHit _S769 = hit_1;
    uint _S770 = filling_2;
    float3  _S771 = scatter_in_0;
    float3  _S772 = extinction_in_0;
    float3  _S773 = weight_1;
    float3  _S774 = glowed_0;
    for(;;)
    {
        bool _S775 = (_S769.instance_index) == 4294967295U;
        if(_S775)
        {
            bool _S776 = !_S767.none;
            float _S777 = _slang_select(_S776, sky_pdf_0,0.0f);
            float _S778 = escapeWeight_0(_S777, (&ray_2)->unit_direction);
            float3  _S779 = environment_0((&ray_2)->unit_direction, b_4, _S768.lobe);
            float3  _S780 = throughput_2 * _S779;
            if(replay_1)
            {
                bool _S781 = b_4 == _S687;
                if(_S781)
                {
                    passes_0 = _S676 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S782 = Shift_x24init_0(_S780 * make_float3 (_S778) / make_float3 (r_3->jac), density_2 / r_3->jac);
                    ended_0 = _S782;
                    passes_0 = true;
                    break;
                }
                if(_S686)
                {
                    passes_0 = _S683;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_4 == _S674;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S768.rough;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S783 = Shift_x24init_0(_S780 * make_float3 (_S778), 1.0f);
                    ended_0 = _S783;
                    passes_0 = true;
                    break;
                }
                ended_0 = _S672;
                passes_0 = true;
                break;
            }
            Reservoir candidate_3 = _S766;
            uint _S784 = extractBits_0(_S766.path, 10U, 2U);
            bool _S785 = _S784 == 1U;
            if(_S785)
            {
                uint _S786 = extractBits_0(_S766.path, 5U, 5U);
                bool _S787 = _S786 == b_4;
                float _S788 = _slang_select(_S787, 1.0f,_S778);
                float3  _S789 = safeDivide(_S780 * make_float3 (_S788), _S671);
                (&candidate_3)->radiance = _S789;
            }
            else
            {
                if(_S768.rough)
                {
                    uint _S790 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                    uint _S791 = insertBits_0(_S790, 3U, 10U, 2U);
                    uint _S792 = insertBits_0(_S791, _S768.lobe, 15U, 2U);
                    uint _S793 = _slang_select(_S768.inside, 1U,0U);
                    uint _S794 = insertBits_0(_S792, _S793, 20U, 1U);
                    (&candidate_3)->path = _S794;
                    (&candidate_3)->jac = _S768.pdf;
                    (&candidate_3)->dir = (&ray_2)->unit_direction;
                }
                else
                {
                }
            }
            float3  _S795 = _S780 * make_float3 (_S778);
            Reservoir _S796 = withEnd(candidate_3, 3U, b_4, _S795);
            offer(sel_1, _S796, _S795 * make_float3 (scale_1) / make_float3 (density_2));
            ended_0 = _S672;
            passes_0 = true;
            break;
        }
        float3  _S797 = (&ray_2)->origin + make_float3 (_S769.distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S797;
        bool _S798 = _S770 != 4294967295U;
        if(_S798)
        {
            bool _S799 = !replay_1;
            if(_S799)
            {
                float3  _S800 = throughput_2 * _S774 / make_float3 (density_2);
                float3  _S801 = sel_1->glow + _S800;
                sel_1->glow = _S801;
            }
            else
            {
            }
            float3  _S802 = throughput_2 * _S773;
            throughput_2 = _S802;
        }
        else
        {
            float3  _S803 = flightWeight_0(_S771, _S772, (_S771.x + _S771.y + _S771.z) / 3.0f, _S769.distance, false);
            float3  _S804 = throughput_2 * _S803;
            throughput_2 = _S804;
        }
        float _S805 = width_2 + spread_1 * _S769.distance;
        ended_0 = _S672;
        width_2 = _S805;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    uint _S806 = b_4 + 1U;
    b_4 = _S806;
    layer_0 = 0U;
    passes_0 = false;
    is_inside_5 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    chain_throughput_0 = _S671;
    float3  reconnection_0 = _S671;
    for(;;)
    {
        bool _S807 = ((&hit_1)->is_point_light) == 1U;
        FKMedium _S808 = Medium_x24init_0(_S671, _S671);
        BSDFMaterial _S809 = Material_x24init_0(_S671, _S671, 0.0f, 0.0f, 0.0f, 0.0f, _S671, throughput_3, 1.0f, _S671, _S671, 0.5f, 0.0f, 0.0f, _S671);
        FKMedium _S810 = _S808;
        FKSurface _S811 = Surface_x24init_0(_S671, _S671, 0.0f, &_S809, false, 0U, 1.0f, false, &_S810, 4294967295U);
        bool _S812 = !_S807;
        bool is_inside_6;
        float3  front_n_0;
        float3  throughput_5;
        FKSurface surface_10;
        if(_S812)
        {
            uint _S813 = stream(_S699, b_4);
            uint _S814 = arrivalLobe_0(b_4, (&prev_0)->lobe);
            FKSurface _S815 = (fcptSurfaceAtPath((hit_1), ((&ray_2)->origin), (_S813), (width_2), (layer_0), (b_4), (_S814)));
            bool _S816 = !passes_0;
            FKSurface _S817 = _S815;
            FKSurface _S818 = emitting_0(&_S817, _S816);
            uint _S819 = stream(_S699, b_4 + 256U);
            Random _S820 = pcg(_S819);
            FKSurface _S821 = _S818;
            FKSurface _S822 = uncovered_0(&_S821, _S820.value);
            float _S823 = facingSign(_S822.material.transmission, _S822.geometry_n, (&ray_2)->unit_direction);
            bool _S824 = _S823 < 0.0f;
            FKSurface _S825 = _S822;
            FKSurface _S826 = facingRay_0(&_S825, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S827 = arrivesBehind_0((&ray_2)->unit_direction, _S826.geometry_n);
                scatter_2 = _S827;
            }
            else
            {
                scatter_2 = is_inside_5;
            }
            if(scatter_2)
            {
                float3  _S828 = beerLambert((&hit_1)->distance, _S826.material.absorption);
                float3  _S829 = throughput_2 * _S828;
                front_n_0 = _S829;
            }
            else
            {
                front_n_0 = throughput_2;
            }
            bool _S830 = !_S826.skip;
            float geometry_density_3 = geometryDensity(_S826.geometry_n, (&ray_2)->unit_direction, (&hit_1)->distance);
            bool _S831 = b_4 == _S806;
            if(_S831)
            {
                float _S832 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S832;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            bool _S833 = scatter_2;
            float3  _S834 = front_n_0;
            float _S835 = geometry_density_2;
            scatter_2 = _S830;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S835;
            surface_10 = _S826;
            front_n_0 = _S822.smooth_n;
            throughput_5 = _S834;
            turned_1 = _S824;
            is_inside_6 = _S833;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_10 = _S811;
            front_n_0 = _S671;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S836 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S837 = surface_10;
        FKSurface _S838 = surface_10;
        float _S839 = dot_0(surface_10.smooth_n, - (&ray_2)->unit_direction);
        BSDFMaterial _S840 = _S837.material;
        float2  _S841 = vertexEta_0(&_S840, _S839);
        bool _S842;
        if(scatter_2)
        {
            bool _S843 = samplesLights(_S837.material);
            _S842 = _S843;
        }
        else
        {
            _S842 = false;
        }
        bool _S844;
        if(passes_0)
        {
            _S844 = true;
        }
        else
        {
            _S844 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S844)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S842;
        }
        float3  _S845 = sideNormal(surface_10, (&ray_2)->unit_direction);
        float _S846 = sign_0(dot_0(- (&ray_2)->unit_direction, front_n_0));
        float3  _S847 = _S837.material.emissive * make_float3 ((F32_max((_S846), (0.0f))));
        float3  emission_0;
        if(_S807)
        {
            float3  _S848 = (fcptCalculatePointLightContrib(((&hit_1)->instance_index)));
            emission_0 = _S848;
        }
        else
        {
            emission_0 = _S847;
        }
        float _S849 = rgb_to_greyscale(emission_0);
        bool _S850 = _S849 > 0.0f;
        float3  emission_1;
        if(_S850)
        {
            NEEVertex _S851 = nee_vertex_0;
            FKHit _S852 = hit_1;
            float _S853 = emissionWeight_0(&_S851, &_S852, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S853);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S854;
        if(replay_1)
        {
            _S854 = _S676 == 1U;
        }
        else
        {
            _S854 = false;
        }
        bool _S855;
        if(_S854)
        {
            _S855 = b_4 > _S675;
        }
        else
        {
            _S855 = false;
        }
        bool _S856;
        if(_S855)
        {
            _S856 = b_4 == _S674;
        }
        else
        {
            _S856 = false;
        }
        bool _S857;
        if(_S856)
        {
            bool _S858 = _S677 == 1U;
            if(_S858)
            {
                _S857 = true;
            }
            else
            {
                _S857 = _S677 == 2U;
            }
        }
        else
        {
            _S857 = false;
        }
        if(_S857)
        {
            bool _S859 = _S807 != (_S677 == 2U);
            if(_S859)
            {
                return _S672;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_3->jac), density_2 / r_3->jac);
        }
        uint _S860 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S861 = _S860 == 1U;
        Reservoir here_0 = chain_0;
        uint _S862 = insertBits_0(0U, b_4, 5U, 5U);
        uint _S863 = insertBits_0(_S862, 1U, 10U, 2U);
        uint _S864 = insertBits_0(_S863, (&prev_0)->lobe, 15U, 2U);
        bool _S865 = (&prev_0)->inside;
        uint _S866 = _slang_select(_S865, 1U,0U);
        uint _S867 = insertBits_0(_S864, _S866, 20U, 1U);
        (&here_0)->path = _S867;
        float _S868 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S868;
        fcptWithReservoirHit((&here_0), (&hit_1));
        bool _S869;
        if(replay_1)
        {
            _S869 = _S676 == 1U;
        }
        else
        {
            _S869 = false;
        }
        bool _S870;
        if(_S869)
        {
            _S870 = b_4 == _S675;
        }
        else
        {
            _S870 = false;
        }
        bool _S871;
        bool wrong_side_0;
        bool refracted_4;
        bool _S872;
        bool _S873;
        float3  throughput_6;
        float density_4;
        if(_S870)
        {
            bool _S874 = ((&hit_1)->instance_index) != (_S688.instance_index);
            if(_S874)
            {
                _S871 = true;
            }
            else
            {
                _S871 = ((&hit_1)->triangle_index) != (_S688.triangle_index);
            }
            if(_S871)
            {
                wrong_side_0 = true;
            }
            else
            {
                wrong_side_0 = !_S836;
            }
            if(wrong_side_0)
            {
                return _S672;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            bool _S875 = _S675 == _S674;
            if(_S875)
            {
                refracted_4 = _S677 == 1U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            if(_S875)
            {
                _S872 = _S677 == 0U;
            }
            else
            {
                _S872 = false;
            }
            if(_S872)
            {
                BSDFMaterial _S876 = _S837.material;
                bool _S877 = isTranslucent_0(&_S876);
                uint _S878 = stream(_S699, b_4 + 64U);
                uint _S879 = arrivalLobe_0(b_4, (&prev_0)->lobe);
                FKSurface _S880 = surface_10;
                ShadowContext _S881 = shadowContext_0(&_S880, turned_1, _S845, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_4, _S879, (&hit_1)->distance, width_2);
                ShadowContext _S882 = _S881;
                TreeSample _S883 = sampleLightTree_0((&ray_2)->origin, _S838.smooth_n, surface_10.geometry_n, surface_10.geometry_offset, _S877, _S878, &_S882);
                bool _S884 = !nee_0;
                if(_S884)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S885 = rgb_to_greyscale(_S883.radiance);
                    passes_0 = !(_S885 > 0.0f);
                }
                if(passes_0)
                {
                    return _S672;
                }
                float _S886 = _S841.x;
                float _S887 = _S841.y;
                uint _S888 = (fcptMaxBounces());
                bool _S889 = b_4 < _S888;
                TreeSample _S890 = _S883;
                BSDFMaterial _S891 = _S837.material;
                float3  _S892 = lightBSDF_0((&ray_2)->unit_direction, &_S890, _S838.smooth_n, _S845, &_S891, _S886, _S887, _S889, surface_10.random_state);
                return Shift_x24init_0(throughput_7 * _S892 / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            if(_S875)
            {
                _S873 = _S677 == 4U;
            }
            else
            {
                _S873 = false;
            }
            if(_S873)
            {
                bool _S893 = !nee_0;
                if(_S893)
                {
                    return _S672;
                }
                float _S894 = environmentPdf_0(r_3->dir);
                float3  _S895 = skyBSDF((&ray_2)->unit_direction, r_3->dir, surface_10, _S845, _S841, is_inside_6, _S894, surface_10.random_state);
                return Shift_x24init_0(throughput_7 * _S895 * r_3->radiance / make_float3 (r_3->jac), density_5 / r_3->jac);
            }
            uint _S896 = extractBits_0(_S673, 19U, 1U);
            bool _S897 = nee_0 != (_S896 == 1U);
            if(_S897)
            {
                return _S672;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                _S871 = b_4 == _S687;
            }
            else
            {
                _S871 = false;
            }
            if(_S871)
            {
                bool _S898 = !scatter_2;
                if(_S898)
                {
                    wrong_side_0 = true;
                }
                else
                {
                    bool _S899 = _S676 != 1U;
                    if(_S899)
                    {
                        wrong_side_0 = _S676 != 3U;
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
                bool _S900 = _S676 == 2U;
                if(_S900)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S836;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S677 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    uint _S901 = stream(_S699, b_4 + 448U);
                    FKRay _S902 = ray_2;
                    FKSurface _S903 = surface_10;
                    SkySample _S904 = sampleSky_0(&_S902, &_S903, _S845, _S841, is_inside_6, _S901, surface_10.random_state);
                    return Shift_x24init_0(throughput_5 * _S904.color, 1.0f);
                }
                if(_S900)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S836;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    BSDFMaterial _S905 = _S837.material;
                    bool _S906 = isTranslucent_0(&_S905);
                    uint _S907 = stream(_S699, b_4 + 64U);
                    uint _S908 = arrivalLobe_0(b_4, (&prev_0)->lobe);
                    FKSurface _S909 = surface_10;
                    ShadowContext _S910 = shadowContext_0(&_S909, turned_1, _S845, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_4, _S908, (&hit_1)->distance, width_2);
                    ShadowContext _S911 = _S910;
                    TreeSample _S912 = sampleLightTree_0((&ray_2)->origin, _S838.smooth_n, surface_10.geometry_n, surface_10.geometry_offset, _S906, _S907, &_S911);
                    float _S913 = rgb_to_greyscale(_S912.radiance);
                    bool _S914 = !(_S913 > 0.0f);
                    if(_S914)
                    {
                        return _S672;
                    }
                    float _S915 = _S841.x;
                    float _S916 = _S841.y;
                    uint _S917 = (fcptMaxBounces());
                    bool _S918 = b_4 < _S917;
                    TreeSample _S919 = _S912;
                    BSDFMaterial _S920 = _S837.material;
                    float3  _S921 = lightBSDF_0((&ray_2)->unit_direction, &_S919, _S838.smooth_n, _S845, &_S920, _S915, _S916, _S918, surface_10.random_state);
                    return Shift_x24init_0(throughput_5 * _S921, 1.0f);
                }
                if(_S686)
                {
                    passes_0 = _S677 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S807;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S686)
                {
                    passes_0 = _S677 == 1U;
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
                    passes_0 = !_S836;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S672;
            }
            else
            {
                bool _S922 = !replay_1;
                if(_S922)
                {
                    refracted_4 = scatter_2;
                }
                else
                {
                    refracted_4 = false;
                }
                if(refracted_4)
                {
                    bool _S923 = b_4 > 0U;
                    if(_S923)
                    {
                        Reservoir candidate_4 = chain_0;
                        if(_S861)
                        {
                            float3  _S924 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_4)->radiance = _S924;
                        }
                        else
                        {
                            if(_S836)
                            {
                                candidate_4 = here_0;
                            }
                        }
                        float3  _S925 = throughput_5 * emission_1;
                        Reservoir _S926 = withEnd(candidate_4, 1U, b_4, _S925);
                        offer(sel_1, _S926, _S925 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S927 = throughput_5 * emission_1;
                        float3  _S928 = sel_1->glow + _S927;
                        sel_1->glow = _S928;
                    }
                    if(nee_0)
                    {
                        BSDFMaterial _S929 = _S837.material;
                        bool _S930 = isTranslucent_0(&_S929);
                        uint _S931 = stream(_S699, b_4 + 64U);
                        uint _S932 = arrivalLobe_0(b_4, (&prev_0)->lobe);
                        FKSurface _S933 = surface_10;
                        ShadowContext _S934 = shadowContext_0(&_S933, turned_1, _S845, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_4, _S932, (&hit_1)->distance, width_2);
                        ShadowContext _S935 = _S934;
                        TreeSample _S936 = sampleLightTree_0((&ray_2)->origin, _S838.smooth_n, surface_10.geometry_n, surface_10.geometry_offset, _S930, _S931, &_S935);
                        float _S937 = _S841.x;
                        float _S938 = _S841.y;
                        uint _S939 = (fcptMaxBounces());
                        bool _S940 = b_4 < _S939;
                        TreeSample _S941 = _S936;
                        BSDFMaterial _S942 = _S837.material;
                        float3  _S943 = lightBSDF_0((&ray_2)->unit_direction, &_S941, _S838.smooth_n, _S845, &_S942, _S937, _S938, _S940, surface_10.random_state);
                        float3  _S944 = throughput_5 * _S943;
                        Reservoir candidate_5 = chain_0;
                        if(_S861)
                        {
                            float3  _S945 = safeDivide(_S944, chain_throughput_0);
                            (&candidate_5)->radiance = _S945;
                        }
                        else
                        {
                            if(_S836)
                            {
                                candidate_5 = here_0;
                                uint _S946 = insertBits_0((&candidate_5)->path, 1U, 19U, 1U);
                                (&candidate_5)->path = _S946;
                                (&candidate_5)->dir = _S936.dir;
                                (&candidate_5)->radiance = _S936.radiance;
                            }
                            else
                            {
                                uint _S947 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S948 = insertBits_0(_S947, 2U, 10U, 2U);
                                (&candidate_5)->path = _S948;
                            }
                        }
                        Reservoir _S949 = withEnd(candidate_5, 0U, b_4, _S944);
                        offer(sel_1, _S949, _S944 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        bool _S950 = environmentMapped_0();
                        _S872 = _S950;
                    }
                    else
                    {
                        _S872 = false;
                    }
                    if(_S872)
                    {
                        uint _S951 = (fcptMaxBounces());
                        _S873 = b_4 < _S951;
                    }
                    else
                    {
                        _S873 = false;
                    }
                    if(_S873)
                    {
                        uint _S952 = stream(_S699, b_4 + 448U);
                        FKRay _S953 = ray_2;
                        FKSurface _S954 = surface_10;
                        SkySample _S955 = sampleSky_0(&_S953, &_S954, _S845, _S841, is_inside_6, _S952, surface_10.random_state);
                        float3  _S956 = throughput_5 * _S955.color;
                        Reservoir candidate_6 = chain_0;
                        if(_S861)
                        {
                            float3  _S957 = safeDivide(_S956, chain_throughput_0);
                            (&candidate_6)->radiance = _S957;
                        }
                        else
                        {
                            if(_S836)
                            {
                                candidate_6 = here_0;
                                uint _S958 = insertBits_0((&candidate_6)->path, 1U, 19U, 1U);
                                (&candidate_6)->path = _S958;
                                (&candidate_6)->dir = _S955.dir;
                                (&candidate_6)->radiance = _S955.radiance;
                            }
                            else
                            {
                                uint _S959 = insertBits_0(0U, b_4 + 1U, 5U, 5U);
                                uint _S960 = insertBits_0(_S959, 2U, 10U, 2U);
                                (&candidate_6)->path = _S960;
                            }
                        }
                        Reservoir _S961 = withEnd(candidate_6, 4U, b_4, _S956);
                        offer(sel_1, _S961, _S956 * make_float3 (scale_1) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S962;
        bool _S963;
        bool _S964;
        bool _S965;
        bool _S966;
        bool _S967;
        bool _S968;
        bool _S969;
        bool _S970;
        bool _S971;
        bool _S972;
        bool _S973;
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
                _S871 = b_4 == _S687;
            }
            else
            {
                _S871 = false;
            }
            uint _S974 = extractBits_0(_S673, 15U, 2U);
            uint _S975 = extractBits_0(_S673, 17U, 2U);
            uint _S976 = _slang_select(_S870, _S975,_S974);
            float3  _S977 = r_3->dir;
            bool refracted_5 = _S976 == 1U;
            SampleBSDF _S978 = SampleBSDF_x24init_0(_S671, _S671, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_10 = _S978;
            float3  reconnection_1;
            if(_S871)
            {
                uint _S979 = extractBits_0(_S673, 20U, 1U);
                bool _S980 = is_inside_6 != (_S979 == 1U);
                if(_S980)
                {
                    return _S672;
                }
                bool _S981 = _S676 == 1U;
                if(_S981)
                {
                    float3  _S982 = (fcptHitPosition((_S688)));
                    throughput_8 = _S982;
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
                    BSDFMaterial _S983 = _S837.material;
                    bool _S984 = isTranslucent_0(&_S983);
                    if(_S984)
                    {
                        wrong_side_0 = _S976 == 0U;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        float3  _S985 = throughput_8 - (&ray_2)->origin;
                        float3  _S986 = _slang_select(_S981, _S985,_S977);
                        refracted_4 = (dot_0(_S838.smooth_n, _S986) * _S839) < 0.0f;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                }
                if(_S981)
                {
                    float3  _S987 = (&ray_2)->origin;
                    FKSurface _S988 = surface_10;
                    float3  _S989 = - _S838.smooth_n;
                    bool _S990 = is_inside_6 != refracted_4;
                    float3  _S991 = _slang_select(_S990, _S989,_S838.smooth_n);
                    float3  _S992 = throughput_8 - (_S987 + make_float3 (_S988.geometry_offset) * _S991);
                    float3  _S993 = ((((_S992)) * make_float3(rnorm3df(((_S992)).x, ((_S992)).y, ((_S992)).z))));
                    reconnection_1 = _S993;
                }
                else
                {
                    reconnection_1 = _S977;
                }
                bool _S994 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, _S845);
                if(_S994)
                {
                    return _S672;
                }
                float3  _S995 = throughput_8;
                throughput_8 = reconnection_1;
                b_7 = _S976;
                wrong_side_0 = false;
                reconnection_1 = _S995;
            }
            else
            {
                bool _S996 = !_S870;
                if(_S996)
                {
                    float _S997 = _S841.x;
                    float _S998 = _S841.y;
                    float2  _S999 = make_float2 (0.0f);
                    SampleBSDF _S1000 = sampleBSDF((&ray_2)->unit_direction, _S838.smooth_n, _S837.material, _S997, _S998, surface_10.random_state, _S999);
                    SampleBSDF bsdf_sampled_0 = _S1000;
                    bool wrong_side_1 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, _S845);
                    if(wrong_side_1)
                    {
                        wrong_side_0 = (_S837.material.transmission) > 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    if(wrong_side_0)
                    {
                        SampleBSDF _S1001 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_10.geometry_n, _S837.material, _S997, _S998, (&bsdf_sampled_0)->random_state, _S999);
                        (&bsdf_sampled_0)->unit_direction = _S1001.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1001.refracted;
                        (&bsdf_sampled_0)->throughput = _S1001.throughput;
                    }
                    else
                    {
                        if(wrong_side_1)
                        {
                            float3  _S1002 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_10.geometry_n)) * surface_10.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1002;
                        }
                    }
                    uint _S1003 = (&bsdf_sampled_0)->lobe;
                    float3  _S1004 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1005 = (&bsdf_sampled_0)->refracted;
                    lobe_10 = bsdf_sampled_0;
                    float _S1006 = (&bsdf_sampled_0)->pdf;
                    float _S1007 = _slang_select(wrong_side_1, 0.0f,_S1006);
                    (&lobe_10)->pdf = _S1007;
                    throughput_8 = _S1004;
                    b_7 = _S1003;
                    wrong_side_0 = wrong_side_1;
                    refracted_4 = _S1005;
                }
                else
                {
                    throughput_8 = _S977;
                    b_7 = _S976;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(_S871)
            {
                _S872 = true;
            }
            else
            {
                _S872 = _S870;
            }
            if(_S872)
            {
                SampleBSDF _S1008 = connectBSDF((&ray_2)->unit_direction, throughput_8, _S838.smooth_n, _S837.material, _S841.x, _S841.y, b_7, surface_10.random_state);
                lobe_10 = _S1008;
            }
            bool _S1009 = b_7 != 0U;
            if(_S1009)
            {
                bool _S1010 = (_S837.material.roughness) == 0.0f;
                if(_S1010)
                {
                    _S873 = true;
                }
                else
                {
                    bool _S1011 = b_7 == 1U;
                    if(_S1011)
                    {
                        _S873 = (_S841.x) == (_S841.y);
                    }
                    else
                    {
                        _S873 = false;
                    }
                }
            }
            else
            {
                _S873 = false;
            }
            BSDFMaterial _S1012 = _S837.material;
            bool _S1013 = isTranslucent_0(&_S1012);
            if(_S1013)
            {
                _S962 = b_7 == 0U;
            }
            else
            {
                _S962 = false;
            }
            if(_S962)
            {
                _S963 = (dot_0(throughput_8, surface_10.geometry_n)) < 0.0f;
            }
            else
            {
                _S963 = false;
            }
            if(nee_0)
            {
                _S964 = !_S873;
            }
            else
            {
                _S964 = false;
            }
            if(_S964)
            {
                _S965 = !wrong_side_0;
            }
            else
            {
                _S965 = false;
            }
            if(_S965)
            {
                float _S1014 = (&lobe_10)->pdf;
                float3  _S1015 = (&ray_2)->origin;
                BSDFMaterial _S1016 = _S837.material;
                bool _S1017 = isTranslucent_0(&_S1016);
                float3  _S1018 = _slang_select(_S1017, _S671,_S838.smooth_n);
                float3  _S1019 = (&ray_2)->origin;
                FKSurface _S1020 = surface_10;
                float3  _S1021 = - _S838.smooth_n;
                float3  _S1022 = _slang_select(_S963, _S1021,_S838.smooth_n);
                NEEVertex _S1023 = NEEVertex_x24init_0(false, _S1014, _S1015, _S1018, _S1019 + make_float3 (_S1020.geometry_offset) * _S1022);
                nee_vertex_0 = _S1023;
            }
            else
            {
                bool _S1024 = b_7 != 1U;
                if(_S1024)
                {
                    _S966 = true;
                }
                else
                {
                    _S966 = (_S841.x) != (_S841.y);
                }
                if(_S966)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1025 = b_7 == 0U;
            bool _S1026 = withinInverseFootprint((&lobe_10)->pdf, _S1025, (&prev_0)->cos, (&hit_1)->distance, threshold_2);
            FKSurface _S1027 = surface_10;
            bool _S1028 = (dot_0(throughput_8, _S838.smooth_n) * dot_0(throughput_8, surface_10.geometry_n)) < 0.0f;
            bool _S1029 = !_S1028;
            if(_S1029)
            {
                bool _S1030 = roughLobe((&lobe_10)->pdf, _S1025, _S837.material.roughness);
                _S966 = _S1030;
            }
            else
            {
                _S966 = false;
            }
            if(_S870)
            {
                bool _S1031 = !_S1026;
                if(_S1031)
                {
                    return _S672;
                }
                bool _S1032 = _S677 != 1U;
                if(_S1032)
                {
                    _S967 = _S677 != 2U;
                }
                else
                {
                    _S967 = false;
                }
                if(_S967)
                {
                    float _S1033 = (&lobe_10)->pdf;
                    float _S1034 = _slang_select(nee_0, _S1033,0.0f);
                    float _S1035 = escapeWeight_0(_S1034, _S977);
                    bool _S1036 = _S675 == _S674;
                    if(_S1036)
                    {
                        passes_0 = _S683;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1037 = _slang_select(passes_0, _S1035,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_10)->throughput * make_float3 ((&lobe_10)->pdf)) * r_3->radiance * make_float3 (_S1037) / make_float3 (r_3->jac), density_4 * (&lobe_10)->pdf / r_3->jac);
                }
                float3  _S1038 = throughput_6 * make_float3 ((&lobe_10)->pdf);
                float _S1039 = density_4 * (&lobe_10)->pdf;
                throughput_9 = _S1038;
                density_6 = _S1039;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1040 = (fcptLayers((hit_1)));
            bool _S1041 = b_7 == 1U;
            bool _S1042 = passesLayer_0(_S1040, _S1041, passes_0);
            if(_S871)
            {
                _S967 = _S1042;
            }
            else
            {
                _S967 = false;
            }
            if(_S967)
            {
                return _S672;
            }
            if(replay_1)
            {
                _S968 = b_4 <= _S687;
            }
            else
            {
                _S968 = false;
            }
            if(_S968)
            {
                _S969 = _S836;
            }
            else
            {
                _S969 = false;
            }
            if(_S969)
            {
                _S970 = _S1026;
            }
            else
            {
                _S970 = false;
            }
            if(_S970)
            {
                _S971 = true;
            }
            else
            {
                if(_S871)
                {
                    _S971 = !_S966;
                }
                else
                {
                    _S971 = false;
                }
            }
            if(_S971)
            {
                return _S672;
            }
            if(_S871)
            {
                float3  _S1043 = throughput_9 * ((&lobe_10)->throughput * make_float3 ((&lobe_10)->pdf));
                float _S1044 = (&lobe_10)->pdf;
                throughput_10 = _S1043;
                sky_pdf_2 = _S1044;
            }
            else
            {
                float3  _S1045 = throughput_9 * max_0((&lobe_10)->throughput, _S671);
                throughput_10 = _S1045;
                sky_pdf_2 = density_6;
            }
            bool _S1046 = !replay_1;
            if(_S1046)
            {
                _S972 = !_S861;
            }
            else
            {
                _S972 = false;
            }
            if(_S972)
            {
                _S973 = _S836;
            }
            else
            {
                _S973 = false;
            }
            bool _S1047;
            if(_S973)
            {
                _S1047 = _S1026;
            }
            else
            {
                _S1047 = false;
            }
            float3  chain_throughput_1;
            if(_S1047)
            {
                chain_0 = here_0;
                uint _S1048 = insertBits_0((&chain_0)->path, b_7, 17U, 2U);
                uint _S1049 = _slang_select(nee_0, 1U,0U);
                uint _S1050 = insertBits_0(_S1048, _S1049, 19U, 1U);
                (&chain_0)->path = _S1050;
                float _S1051 = (&chain_0)->jac * (&lobe_10)->pdf;
                (&chain_0)->jac = _S1051;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            Vertex _S1052 = Vertex_x24init_0(_S966, b_7, (&lobe_10)->pdf, (F32_abs((dot_0(_S1027.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1052;
            float _S1053 = (&lobe_10)->pdf;
            bool _S1054;
            if(_S1041)
            {
                _S1054 = (_S841.x) == (_S841.y);
            }
            else
            {
                _S1054 = false;
            }
            float _S1055 = _slang_select(_S1054, sky_pdf_0,_S1053);
            float _S1056 = widened_0(spread_1, (&lobe_10)->pdf, _S873);
            bool _S1057;
            if(refracted_4)
            {
                _S1057 = !_S963;
            }
            else
            {
                _S1057 = false;
            }
            bool is_inside_7;
            if(_S1057)
            {
                bool _S1058 = !is_inside_6;
                is_inside_7 = _S1058;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            bool _S1059 = !_S1042;
            if(_S1059)
            {
                FKSurface faced_2 = surface_10;
                float3  _S1060 = - _S1027.geometry_n;
                float3  _S1061 = _slang_select(turned_1, _S1060,_S1027.geometry_n);
                (&faced_2)->geometry_n = _S1061;
                FKMedium _S1062 = Medium_x24init_0(scatter_in_0, extinction_in_0);
                FKSurface _S1063 = faced_2;
                FKMedium _S1064 = _S1062;
                MediumSides _S1065 = mediumSides_0(&_S1063, &_S1064, filling_2, (&ray_2)->unit_direction);
                bool _S1066 = leavesInFront_0((&faced_2)->geometry_n, throughput_8, _S845, _S1027.geometry_n);
                float3  _S1067 = _slang_select(_S1066, _S1065.front.scatter,_S1065.behind.scatter);
                scatter_in_0 = _S1067;
                float3  _S1068 = _slang_select(_S1066, _S1065.front.extinction,_S1065.behind.extinction);
                extinction_in_0 = _S1068;
                uint _S1069 = _S1065.fillings.x;
                uint _S1070 = _S1065.fillings.y;
                uint _S1071 = _slang_select(_S1066, _S1070,_S1069);
                filling_2 = _S1071;
            }
            (&ray_2)->unit_direction = throughput_8;
            if(_S1059)
            {
                FKSurface _S1072 = surface_10;
                float3  _S1073 = - _S838.smooth_n;
                bool _S1074 = is_inside_7 != _S963;
                float3  _S1075 = _slang_select(_S1074, _S1073,_S838.smooth_n);
                float3  _S1076 = (&ray_2)->origin + make_float3 (_S1072.geometry_offset) * _S1075;
                (&ray_2)->origin = _S1076;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1042;
            sky_pdf_2 = _S1055;
            spread_4 = _S1056;
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
        bool _S1077 = !replay_1;
        float density_7;
        if(_S1077)
        {
            if(_S807)
            {
                float3  _S1078 = throughput_9 * emission_1;
                Reservoir candidate_7 = chain_0;
                uint _S1079 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1080 = _S1079 == 1U;
                if(_S1080)
                {
                    float3  _S1081 = safeDivide(_S1078, chain_throughput_0);
                    (&candidate_7)->radiance = _S1081;
                }
                Reservoir _S1082 = withEnd(candidate_7, 2U, b_4, _S1078);
                offer(sel_1, _S1082, _S1078 * make_float3 (scale_1) / make_float3 (density_6));
            }
            if(_S807)
            {
                _S871 = true;
            }
            else
            {
                _S871 = scatter_2;
            }
            if(_S871)
            {
                float _S1083 = survivalProbability(throughput_9, density_6);
                density_7 = _S1083;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1084 = stream(_S699, b_4 + 128U);
            Random _S1085 = pcg(_S1084);
            bool _S1086 = density_7 < (_S1085.value);
            if(_S1086)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1087 = (fcptMaxBounces());
                wrong_side_0 = b_4 >= _S1087;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1088 = density_6 * density_7;
            density_7 = _S1088;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1089 = layer_0 ^ 1U;
        uint _S1090 = _slang_select(passes_0, _S1089,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_1)->distance = 0.0f;
            b_7 = b_4;
            throughput_2 = throughput_9;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_1 = spread_4;
            uint _S1091 = b_7 + 1U;
            b_4 = _S1091;
            layer_0 = _S1090;
            continue;
        }
        FKRay _S1092 = ray_2;
        float _S1093 = distance_5(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            _S871 = b_4 == _S687;
        }
        else
        {
            _S871 = false;
        }
        if(_S871)
        {
            wrong_side_0 = _S676 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1094 = _slang_select(wrong_side_0, _S1093,4.294967296e+09f);
        FKHit _S1095 = (fcptTraverseInstanceBVH((_S1092), (_S812), (_S1094), (true)));
        hit_1 = _S1095;
        if(replay_1)
        {
            refracted_4 = b_4 == _S687;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            _S872 = _S676 == 1U;
        }
        else
        {
            _S872 = false;
        }
        if(_S872)
        {
            _S873 = ((&hit_1)->instance_index) == (_S688.instance_index);
        }
        else
        {
            _S873 = false;
        }
        if(_S873)
        {
            _S962 = ((&hit_1)->triangle_index) == (_S688.triangle_index);
        }
        else
        {
            _S962 = false;
        }
        if(_S962)
        {
            (&hit_1)->uv = _S688.uv;
            float _S1096 = distance_5(reconnection_0, (&ray_2)->origin);
            (&hit_1)->distance = _S1096;
        }
        if(replay_1)
        {
            _S963 = b_4 == _S687;
        }
        else
        {
            _S963 = false;
        }
        if(_S963)
        {
            _S964 = _S676 == 3U;
        }
        else
        {
            _S964 = false;
        }
        if(_S964)
        {
            _S965 = ((&hit_1)->instance_index) != 4294967295U;
        }
        else
        {
            _S965 = false;
        }
        if(_S965)
        {
            return _S672;
        }
        Reservoir _S1097 = chain_0;
        uint _S1098 = filling_2;
        for(;;)
        {
            bool _S1099 = _S1098 != 4294967295U;
            float _S1100 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            float _S1101 = (fcptMajorant((_S1098)));
            float _S1102 = _slang_select(_S1099, _S1101,_S1100);
            if(replay_1)
            {
                _S966 = b_4 == _S687;
            }
            else
            {
                _S966 = false;
            }
            if(_S966)
            {
                _S967 = _S676 == 1U;
            }
            else
            {
                _S967 = false;
            }
            if(_S967)
            {
                _S968 = _S1102 > 0.0f;
            }
            else
            {
                _S968 = false;
            }
            if(_S968)
            {
                ended_0 = _S672;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_3 = width_2;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_7 = b_4;
                _S969 = true;
                break;
            }
            bool _S1103 = (&prev_0)->rough;
            if(_S1103)
            {
                _S969 = !(_S1102 > 0.0f);
            }
            else
            {
                _S969 = false;
            }
            (&prev_0)->rough = _S969;
            uint _S1104 = b_4 + 320U;
            bool _S1105 = b_4 == 4294967295U;
            uint _S1106 = _slang_select(_S1105, 384U,_S1104);
            uint _S1107 = stream(_S699, _S1106);
            uint tracking_1 = _S1107;
            weight_1 = throughput_3;
            glowed_0 = _S671;
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
                    _S670 = int(2);
                    break;
                }
                uint _S1108 = b_7 + 320U;
                bool _S1109 = b_7 == 4294967295U;
                uint _S1110 = _slang_select(_S1109, 384U,_S1108);
                uint _S1111 = stream(_S699, _S1110);
                Random _S1112 = pcg(_S1111);
                float _S1113 = freeFlight_0(_S1112.value, _S1102);
                if(_S1099)
                {
                    float3  _S1114 = (&ray_2)->origin;
                    float3  _S1115 = (&ray_2)->unit_direction;
                    float _S1116 = (&hit_1)->distance;
                    uint _S1117 = _slang_select(_S1109, 0U,b_7);
                    uint _S1118 = (&prev_0)->lobe;
                    uint _S1119 = _slang_select(_S1109, 3U,_S1118);
                    float _S1120 = (fcptTrackMedium((_S1098), (_S1114), (_S1115), (_S1116), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (_S1117), (_S1119)));
                    spread_3 = _S1120;
                }
                else
                {
                    spread_3 = _S1113;
                }
                bool _S1121 = !(spread_3 < ((&hit_1)->distance));
                if(_S1121)
                {
                    _S670 = int(2);
                    break;
                }
                if(_S1099)
                {
                    _S970 = _S1077;
                }
                else
                {
                    _S970 = false;
                }
                if(_S970)
                {
                    float3  _S1122 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1123 = sel_1->glow + _S1122;
                    sel_1->glow = _S1123;
                }
                else
                {
                }
                glowed_0 = _S671;
                uint b_8 = b_7 + 1U;
                float3  _S1124 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1124;
                float3  _S1125 = flightWeight_0(scatter_in_0, extinction_in_0, _S1102, spread_3, true);
                float3  _S1126 = weight_1;
                float3  _S1127 = _slang_select(_S1099, _S1126,_S1125);
                float3  throughput_11 = throughput_10 * _S1127;
                uint _S1128 = stream(_S699, b_8 + 320U);
                tracking_1 = _S1128;
                weight_1 = throughput_3;
                float width_6 = width_3 + spread_2 * spread_3;
                float _S1129 = spread_2 + 3.14159274101257324f;
                uint _S1130 = stream(_S699, b_8 + 64U);
                uint2  _S1131 = make_uint2 (_S1098);
                uint _S1132 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                ShadowContext _S1133 = ShadowContext_x24init_0(extinction_in_0, extinction_in_0, _S1131, (&ray_2)->unit_direction, b_8, _S1132, false, spread_3, width_6);
                TreeSample _S1134 = sampleLightTree_0((&ray_2)->origin, (&ray_2)->unit_direction, (&ray_2)->unit_direction, 0.0f, true, _S1130, &_S1133);
                bool _S1135 = scatterSampled_0(replay_1, b_8, _S687, _S1099);
                uint _S1136 = (fcptMaxBounces());
                bool _S1137 = b_8 < _S1136;
                if(_S1137)
                {
                    _S971 = (_S1134.density) > 0.0f;
                }
                else
                {
                    _S971 = false;
                }
                float _S1138 = _slang_select(_S971, 0.07957746833562851f,0.0f);
                float3  _S1139 = throughput_11 * _S1134.radiance;
                float _S1140 = powerHeuristic(_S1134.density, _S1138);
                float3  _S1141 = _S1139 * make_float3 (0.07957746833562851f * _S1140);
                float3  _S1142 = _slang_select(_S1135, _S1141,_S671);
                if(replay_1)
                {
                    _S972 = b_8 == _S687;
                }
                else
                {
                    _S972 = false;
                }
                if(_S972)
                {
                    bool _S1143 = _S676 == 2U;
                    if(_S1143)
                    {
                        float _S1144 = rgb_to_greyscale(_S1142);
                        _S973 = _S1144 > 0.0f;
                    }
                    else
                    {
                        _S973 = false;
                    }
                    if(_S973)
                    {
                        Shift _S1145 = Shift_x24init_0(_S1142, 1.0f);
                        _S670 = int(1);
                        ended_0 = _S1145;
                        spread_3 = _S1129;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_5 = b_8;
                        break;
                    }
                    _S670 = int(1);
                    ended_0 = _S672;
                    spread_3 = _S1129;
                    width_4 = width_6;
                    throughput_8 = throughput_11;
                    b_5 = b_8;
                    break;
                }
                if(_S1077)
                {
                    Reservoir candidate_8 = _S1097;
                    uint _S1146 = extractBits_0(_S1097.path, 10U, 2U);
                    bool _S1147 = _S1146 == 1U;
                    if(_S1147)
                    {
                        float3  _S1148 = safeDivide(_S1142, chain_throughput_0);
                        (&candidate_8)->radiance = _S1148;
                    }
                    else
                    {
                        uint _S1149 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                        uint _S1150 = insertBits_0(_S1149, 2U, 10U, 2U);
                        (&candidate_8)->path = _S1150;
                    }
                    Reservoir _S1151 = withEnd(candidate_8, 0U, b_8, _S1142);
                    offer(sel_1, _S1151, _S1142 * make_float3 (scale_1) / make_float3 (density_3));
                    float _S1152 = survivalProbability(throughput_11, density_3);
                    uint _S1153 = stream(_S699, b_8 + 128U);
                    Random _S1154 = pcg(_S1153);
                    bool _S1155 = _S1152 < (_S1154.value);
                    if(_S1155)
                    {
                        _S973 = true;
                    }
                    else
                    {
                        uint _S1156 = (fcptMaxBounces());
                        _S973 = b_8 >= _S1156;
                    }
                    if(_S973)
                    {
                        _S670 = int(1);
                        ended_0 = _S672;
                        spread_3 = _S1129;
                        width_4 = width_6;
                        throughput_8 = throughput_11;
                        b_5 = b_8;
                        break;
                    }
                    float _S1157 = density_3 * _S1152;
                    density_3 = _S1157;
                }
                else
                {
                }
                NEEVertex _S1158 = NEEVertex_x24init_0(false, 0.07957746833562851f, (&ray_2)->origin, _S671, (&ray_2)->origin);
                nee_vertex_0 = _S1158;
                uint _S1159 = stream(_S699, b_8);
                float3  _S1160 = isotropic_0(_S1159);
                (&ray_2)->unit_direction = _S1160;
                Vertex _S1161 = scatteredVertex_0(is_inside_5);
                prev_0 = _S1161;
                float _S1162 = (&prev_0)->pdf;
                FKHit _S1163 = (fcptTraverseInstanceBVH((ray_2), (true), (4.294967296e+09f), (false)));
                hit_1 = _S1163;
                b_7 = b_8;
                throughput_10 = throughput_11;
                spread_2 = _S1129;
                width_3 = width_6;
                sky_pdf_1 = _S1162;
            }
            if(_S670 != int(2))
            {
                spread_2 = spread_3;
                width_3 = width_4;
                throughput_10 = throughput_8;
                b_7 = b_5;
                _S969 = true;
                break;
            }
            ended_0 = _S672;
            _S969 = false;
            break;
        }
        if(_S969)
        {
            return ended_0;
        }
        Reservoir _S1164 = chain_0;
        NEEVertex _S1165 = nee_vertex_0;
        Vertex _S1166 = prev_0;
        FKHit _S1167 = hit_1;
        uint _S1168 = filling_2;
        float3  _S1169 = scatter_in_0;
        float3  _S1170 = extinction_in_0;
        float3  _S1171 = weight_1;
        float3  _S1172 = glowed_0;
        for(;;)
        {
            bool _S1173 = (_S1167.instance_index) == 4294967295U;
            if(_S1173)
            {
                bool _S1174 = !_S1165.none;
                float _S1175 = _slang_select(_S1174, sky_pdf_1,0.0f);
                float _S1176 = escapeWeight_0(_S1175, (&ray_2)->unit_direction);
                float3  _S1177 = environment_0((&ray_2)->unit_direction, b_7, _S1166.lobe);
                float3  _S1178 = throughput_10 * _S1177;
                if(replay_1)
                {
                    bool _S1179 = b_7 == _S687;
                    if(_S1179)
                    {
                        _S970 = _S676 == 3U;
                    }
                    else
                    {
                        _S970 = false;
                    }
                    if(_S970)
                    {
                        Shift _S1180 = Shift_x24init_0(_S1178 * make_float3 (_S1176) / make_float3 (r_3->jac), density_3 / r_3->jac);
                        arrived_end_0 = _S1180;
                        width_4 = width_3;
                        throughput_8 = throughput_10;
                        _S970 = true;
                        break;
                    }
                    if(_S686)
                    {
                        _S971 = _S683;
                    }
                    else
                    {
                        _S971 = false;
                    }
                    if(_S971)
                    {
                        _S972 = b_7 == _S674;
                    }
                    else
                    {
                        _S972 = false;
                    }
                    if(_S972)
                    {
                        _S973 = !_S1166.rough;
                    }
                    else
                    {
                        _S973 = false;
                    }
                    if(_S973)
                    {
                        Shift _S1181 = Shift_x24init_0(_S1178 * make_float3 (_S1176), 1.0f);
                        arrived_end_0 = _S1181;
                        width_4 = width_3;
                        throughput_8 = throughput_10;
                        _S970 = true;
                        break;
                    }
                    arrived_end_0 = _S672;
                    width_4 = width_3;
                    throughput_8 = throughput_10;
                    _S970 = true;
                    break;
                }
                Reservoir candidate_9 = _S1164;
                uint _S1182 = extractBits_0(_S1164.path, 10U, 2U);
                bool _S1183 = _S1182 == 1U;
                if(_S1183)
                {
                    uint _S1184 = extractBits_0(_S1164.path, 5U, 5U);
                    bool _S1185 = _S1184 == b_7;
                    float _S1186 = _slang_select(_S1185, 1.0f,_S1176);
                    float3  _S1187 = safeDivide(_S1178 * make_float3 (_S1186), chain_throughput_0);
                    (&candidate_9)->radiance = _S1187;
                }
                else
                {
                    if(_S1166.rough)
                    {
                        uint _S1188 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                        uint _S1189 = insertBits_0(_S1188, 3U, 10U, 2U);
                        uint _S1190 = insertBits_0(_S1189, _S1166.lobe, 15U, 2U);
                        uint _S1191 = _slang_select(_S1166.inside, 1U,0U);
                        uint _S1192 = insertBits_0(_S1190, _S1191, 20U, 1U);
                        (&candidate_9)->path = _S1192;
                        (&candidate_9)->jac = _S1166.pdf;
                        (&candidate_9)->dir = (&ray_2)->unit_direction;
                    }
                    else
                    {
                    }
                }
                float3  _S1193 = _S1178 * make_float3 (_S1176);
                Reservoir _S1194 = withEnd(candidate_9, 3U, b_7, _S1193);
                offer(sel_1, _S1194, _S1193 * make_float3 (scale_1) / make_float3 (density_3));
                arrived_end_0 = _S672;
                width_4 = width_3;
                throughput_8 = throughput_10;
                _S970 = true;
                break;
            }
            float3  _S1195 = (&ray_2)->origin + make_float3 (_S1167.distance) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1195;
            bool _S1196 = _S1168 != 4294967295U;
            if(_S1196)
            {
                if(_S1077)
                {
                    float3  _S1197 = throughput_10 * _S1172 / make_float3 (density_3);
                    float3  _S1198 = sel_1->glow + _S1197;
                    sel_1->glow = _S1198;
                }
                else
                {
                }
                float3  _S1199 = throughput_10 * _S1171;
                throughput_8 = _S1199;
            }
            else
            {
                float3  _S1200 = flightWeight_0(_S1169, _S1170, (_S1169.x + _S1169.y + _S1169.z) / 3.0f, _S1167.distance, false);
                float3  _S1201 = throughput_10 * _S1200;
                throughput_8 = _S1201;
            }
            float _S1202 = width_3 + spread_2 * _S1167.distance;
            arrived_end_0 = _S672;
            width_4 = _S1202;
            _S970 = false;
            break;
        }
        if(_S970)
        {
            return arrived_end_0;
        }
        width_2 = width_4;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1091 = b_7 + 1U;
        b_4 = _S1091;
        layer_0 = _S1090;
    }
    return _S672;
}

static __device__ Shift shift_0(Domain * dom_1, Reservoir * r_4)
{
    Selection _S1203 = (Selection{});
    Selection sel_2 = _S1203;
    bool _S1204 = (r_4->w) <= 0.0f;
    if(_S1204)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1205 = walk_0(dom_1, r_4, true, 0.0f, &sel_2);
    return _S1205;
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
    Random _S1206 = pcg(state_3);
    Random _S1207 = pcg(_S1206.state);
    float _S1208 = 6.28318548202514648f * _S1206.value;
    float _S1209 = (F32_sqrt((-2.0f * clamp_0((F32_log((_S1207.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1207.state, _S1209 * (F32_cos((_S1208))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1210;
    (&_S1210)->state = state_4;
    (&_S1210)->value = value_2;
    return _S1210;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1211 = normal_distribution(state_5);
    Random _S1212 = normal_distribution(_S1211.state);
    Random _S1213 = normal_distribution(_S1212.state);
    float3  _S1214 = make_float3 (_S1211.value, _S1212.value, _S1213.value);
    float3  _S1215 = ((((_S1214)) * make_float3(rnorm3df(((_S1214)).x, ((_S1214)).y, ((_S1214)).z))));
    return RandomSphere_x24init_0(_S1213.state, _S1215);
}

struct RandomHemisphere
{
    uint state;
    float3  value;
};

static __device__ RandomHemisphere RandomHemisphere_x24init_0(uint state_6, float3  value_3)
{
    RandomHemisphere _S1216;
    (&_S1216)->state = state_6;
    (&_S1216)->value = value_3;
    return _S1216;
}

__device__ RandomHemisphere random_hemisphere(uint state_7, float3  normal_4)
{
    RandomSphere _S1217 = random_sphere(state_7);
    bool _S1218 = (dot_0(_S1217.value, normal_4)) > 0.0f;
    if(_S1218)
    {
        return RandomHemisphere_x24init_0(_S1217.state, _S1217.value);
    }
    else
    {
        float3  _S1219 = negate_0(_S1217.value);
        return RandomHemisphere_x24init_0(_S1217.state, _S1219);
    }
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_15)
{
    float3  _S1220 = p1_0 - p0_0;
    float3  _S1221 = p2_0 - p0_0;
    float2  _S1222 = uv1_0 - uv0_0;
    float2  _S1223 = uv2_0 - uv0_0;
    float _S1224 = _S1222.x;
    float _S1225 = _S1223.y;
    float _S1226 = _S1222.y;
    float _S1227 = _S1223.x;
    float _S1228 = _S1224 * _S1225 - _S1226 * _S1227;
    float _S1229 = 1.0f / _S1228;
    float3  t_1 = (_S1220 * make_float3 (_S1225) - _S1221 * make_float3 (_S1226)) * make_float3 (_S1229);
    float3  _S1230 = (_S1221 * make_float3 (_S1224) - _S1220 * make_float3 (_S1227)) * make_float3 (_S1229);
    float3  _S1231 = t_1 - n_15 * make_float3 (dot_0(n_15, t_1));
    float3  t_2 = ((((_S1231)) * make_float3(rnorm3df(((_S1231)).x, ((_S1231)).y, ((_S1231)).z))));
    bool _S1232 = (dot_0(cross_0(n_15, t_2), _S1230)) > 0.0f;
    float3  t_3;
    if(_S1232)
    {
        float3  _S1233 = negate_0(t_2);
        t_3 = _S1233;
    }
    else
    {
        t_3 = t_2;
    }
    float3  _S1234 = cross_0(n_15, t_3);
    return makeMatrix<float, 3, 3> (t_3, _S1234, n_15);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1235 = t1_0 - t0_0;
    float3  _S1236 = t2_2 - t0_0;
    float3  _S1237 = t2_2 - t1_0;
    float _S1238 = (F32_min((length_0(_S1235)), ((F32_min((length_0(_S1236)), (length_0(_S1237)))))));
    float3  _S1239 = make_float3 (distance_5(position_0, t0_0), distance_5(position_0, t1_0), distance_5(position_0, t2_2));
    float3  _S1240 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1241 = dot_0(geometry_n_5, _S1240);
    float3  _S1242 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1243 = dot_0(geometry_n_5, _S1242);
    float3  _S1244 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1245 = acos_0(abs_0(make_float3 (_S1241, _S1243, dot_0(geometry_n_5, _S1244))));
    float3  _S1246 = clamp_1(tan_0(_S1245), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_0(dot_0(_S1239 * _S1246, uvw_0), 0.0f, _S1238 * 0.125f);
}

__device__ float3  sampleHalfVector(float3  v_6, float3  n_i_5, float alpha_6, uint * random_state_15)
{
    float3  _S1247 = sampleMaterialHalfVector(v_6, n_i_5, alpha_6, AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f)), random_state_15);
    return _S1247;
}

__device__ float3  straightThrough(float3  dir_14, float3  n_16, BSDFMaterial material_16)
{
    float3  _S1248 = negate_0(dir_14);
    float _S1249 = sign_0(dot_0(n_16, _S1248));
    float3  _S1250 = n_16 * make_float3 (_S1249);
    AnisotropicFrame _S1251 = anisotropicFrame(material_16, _S1250);
    bool _S1252 = (_S1251.alphas.x) > 0.0f;
    if(_S1252)
    {
        float _S1253 = material_16.transmission * (1.0f - material_16.metallic);
        float3  _S1254 = negate_0(_S1250);
        float3  _S1255 = anisotropicLocal(dir_14, _S1251.tangent, _S1254);
        float _S1256 = anisotropicG1(_S1255, _S1251.alphas);
        return make_float3 (_S1253 * _S1256) * material_16.albedo;
    }
    float _S1257 = material_16.transmission * (1.0f - material_16.metallic);
    float _S1258 = material_16.roughness;
    float _S1259 = smithG1(_S1258 * _S1258, (F32_abs((dot_0(n_16, dir_14)))));
    return make_float3 (_S1257 * _S1259) * material_16.albedo;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_17, BSDFMaterial material_17, float coverage_1)
{
    float3  _S1260;
    if((material_17.ior) == 1.0f)
    {
        float3  _S1261 = straightThrough(toward_1, n_17, material_17);
        _S1260 = _S1261;
    }
    else
    {
        _S1260 = make_float3 (0.0f);
    }
    return _S1260 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_5, Shift shifted_0, float mis_0)
{
    Reservoir candidate_10 = r_5;
    float3  _S1262 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_10)->f = _S1262;
    float _S1263 = r_5.jac * shifted_0.jac;
    (&candidate_10)->jac = _S1263;
    offer(sel_3, candidate_10, make_float3 (mis_0) * shifted_0.f * make_float3 (r_5.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_6 = sel_4.r;
    float _S1264 = rgb_to_greyscale((&r_6)->f);
    float _S1265 = sel_4.w_sum / _S1264;
    bool _S1266 = _S1264 > 0.0f;
    float _S1267 = _slang_select(_S1266, _S1265,0.0f);
    (&r_6)->w = _S1267;
    (&r_6)->c = c_1;
    return r_6;
}

static __device__ float interpolate_0(float a_6, float b_9, float t_4)
{
    return a_6 + (b_9 - a_6) * t_4;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S1268 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S1268;
}

__device__ float2  temporalWeights(float c_2, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S1269 = c_2 * p_c_0;
    float _S1270 = c_t_0 * p_t_0;
    return make_float2 (_S1269 / (_S1269 + c_t_0 * g_previous_0), _S1270 / (_S1270 + c_2 * g_current_0));
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
    Domain _S1271 = dom_2;
    Reservoir _S1272 = r_7;
    Shift _S1273 = walk_0(&_S1271, &_S1272, replay_2, scale_2, sel_5);
    return _S1273;
}

__device__ Shift shift_hook(Domain dom_3, Reservoir r_8)
{
    Domain _S1274 = dom_3;
    Reservoir _S1275 = r_8;
    Shift _S1276 = shift_0(&_S1274, &_S1275);
    return _S1276;
}

#undef Matrix
