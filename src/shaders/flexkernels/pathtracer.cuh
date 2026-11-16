#pragma once
#define Matrix SlangMatrix
#include "slang-cuda-prelude.h"

static __device__ bool all_0(bool2  x_0)
{
    bool result_0 = true;
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
        if(result_0)
        {
            result_0 = (bool((_slang_vector_get_element(x_0, i_0))));
        }
        else
        {
            result_0 = false;
        }
        i_0 = i_0 + int(1);
    }
    return result_0;
}

static __device__ uint previousSeed_0(int2  q_0)
{
    bool _S1 = all_0(q_0 >= make_int2 (int(0)));
    bool _S2;
    if(_S1)
    {
        uint2  _S3 = (fcptRenderSize());
        int2  _S4 = make_int2 ((int)_S3.x, (int)_S3.y);
        _S2 = all_0(q_0 < _S4);
    }
    else
    {
        _S2 = false;
    }
    uint seed_0;
    if(_S2)
    {
        uint4  _S5 = (fcptReservoirPrevious((q_0), (0U)));
        uint _S6 = _S5.x;
        bool _S7 = (U32_asfloat((_S5.z))) > 0.0f;
        uint _S8 = _slang_select(_S7, _S6,0U);
        seed_0 = _S8;
    }
    else
    {
        seed_0 = 0U;
    }
    return seed_0;
}

__device__ uint hash(uint x_1)
{
    uint _S9 = x_1 * 747796405U + 2891336453U;
    uint _S10 = ((_S9 >> ((_S9 >> 28U) + 4U)) ^ _S9) * 277803737U;
    return (_S10 >> 22U) ^ _S10;
}

static __device__ int2  partner_0(int2  p_0, uint t_0)
{
    FixedArray<int, 3>  sizes_0 = { {
        int(254), int(230), int(210)
    } };
    uint _S11 = (fcptFrame());
    uint _S12 = hash(_S11 * 3U + t_0);
    int2  _S13 = make_int2 (int(1));
    int2  _S14 = make_int2 (int(-1));
    bool2  _S15 = make_bool2 ((_S12 & 1U) != 0U, (_S12 & 2U) != 0U);
    int2  _S16 = _slang_select(_S15, _S14,_S13);
    bool _S17 = (_S12 & 4U) != 0U;
    int2  _S18 = make_int2 (int((_S12 >> 8U) & 255U), int((_S12 >> 16U) & 255U));
    int2  _S19 = int2 {p_0.y, p_0.x};
    int2  _S20 = _slang_select(_S17, _S19,p_0);
    int2  _S21 = _S20 % make_int2 (sizes_0[t_0]);
    int2  _S22 = make_int2 (sizes_0[t_0]) - _S21;
    bool2  _S23 = _S16 < make_int2 (int(0));
    int2  _S24 = _slang_select(_S23, _S22,_S21);
    int2  _S25 = (_S24 + _S18) % make_int2 (sizes_0[t_0]);
    int4  _S26 = (fcptPairing((_S25), (t_0)));
    int2  _S27 = int2 {_S26.x, _S26.y} * _S16;
    int2  _S28 = int2 {_S27.y, _S27.x};
    int2  _S29 = _slang_select(_S17, _S28,_S27);
    return p_0 + _S29;
}

struct Domain
{
    float3  x0;
    float3  x1;
    FKHit hit;
    float width;
    float spread;
};

struct ShiftJob
{
    Domain dom;
    Reservoir r;
};

static __device__ bool any_0(bool2  x_2)
{
    bool result_1 = false;
    int i_1 = int(0);
    for(;;)
    {
        if(i_1 < int(2))
        {
        }
        else
        {
            break;
        }
        if(result_1)
        {
            result_1 = true;
        }
        else
        {
            result_1 = (bool((_slang_vector_get_element(x_2, i_1))));
        }
        i_1 = i_1 + int(1);
    }
    return result_1;
}

static __device__ bool spatialJob_0(int2  p_1, uint t_1, ShiftJob * job_0, bool target_0)
{
    bool _S30 = t_1 > 2U;
    bool _S31;
    if(_S30)
    {
        _S31 = true;
    }
    else
    {
        uint2  _S32 = (fcptRenderSize());
        int2  _S33 = make_int2 ((int)_S32.x, (int)_S32.y);
        _S31 = any_0(p_1 >= _S33);
    }
    if(_S31)
    {
        return false;
    }
    Reservoir _S34 = (fcptLoadReservoirTemporal((p_1)));
    job_0->r = _S34;
    int2  _S35 = partner_0(p_1, t_1);
    bool _S36 = !target_0;
    if(_S36)
    {
        bool _S37 = ((&job_0->r)->w) > 0.0f;
        if(_S37)
        {
            _S31 = all_0(_S35 >= make_int2 (int(0)));
        }
        else
        {
            _S31 = false;
        }
        if(_S31)
        {
            uint2  _S38 = (fcptRenderSize());
            int2  _S39 = make_int2 ((int)_S38.x, (int)_S38.y);
            _S31 = all_0(_S35 < _S39);
        }
        else
        {
            _S31 = false;
        }
        return _S31;
    }
    bool _S40 = ((&job_0->r)->w) > 0.0f;
    if(_S40)
    {
        bool _S41 = (fcptStoredDomainTemporal((_S35), ((&job_0->r)->seed), (&job_0->dom)));
        _S31 = _S41;
    }
    else
    {
        _S31 = false;
    }
    return _S31;
}

static __device__ uint extractBits_0(uint e_0, uint offset_0, uint count_0)
{
    return (e_0 >> offset_0) & ((1U << count_0) - 1U);
}

static __device__ uint clamp_0(uint x_3, uint minBound_0, uint maxBound_0)
{
    return (U32_min(((U32_max((x_3), (minBound_0)))), (maxBound_0)));
}

static __device__ uint shiftBin_0(Reservoir * r_0)
{
    uint _S42 = r_0->path;
    uint _S43 = extractBits_0(r_0->path, 10U, 2U);
    bool _S44 = _S43 == 2U;
    bool _S45;
    if(_S44)
    {
        uint _S46 = extractBits_0(_S42, 12U, 3U);
        _S45 = _S46 == 4U;
    }
    else
    {
        _S45 = false;
    }
    uint _S47 = _slang_select(_S45, 4U,_S43);
    uint _S48 = extractBits_0(_S42, 5U, 5U);
    uint _S49 = extractBits_0(_S42, 0U, 5U);
    uint _S50 = _S49 + 1U;
    bool _S51 = _S43 == 0U;
    uint _S52 = _slang_select(_S51, _S50,_S48);
    return _S47 * 8U + clamp_0(_S52, 1U, 8U) - 1U;
}

static __device__ void spatialBins_0(int2  p_2, FixedArray<uint, 3>  * _S53)
{
    FixedArray<uint, 3>  _S54 = { {
        40U, 40U, 40U
    } };
    FixedArray<uint, 3>  bins_0;
    bins_0[int(0)] = 40U;
    bins_0[int(1)] = 40U;
    bins_0[int(2)] = 40U;
    uint t_2 = 0U;
    for(;;)
    {
        uint _S55 = (fcptRestirNeighbours());
        if(t_2 < _S55)
        {
        }
        else
        {
            break;
        }
        ShiftJob _S56 = (ShiftJob{});
        ShiftJob job_1 = _S56;
        bool _S57 = spatialJob_0(p_2, t_2, &job_1, false);
        if(_S57)
        {
            Reservoir _S58 = (&job_1)->r;
            uint _S59 = shiftBin_0(&_S58);
            bins_0[t_2] = _S59;
        }
        uint t_3 = t_2 + 1U;
        t_2 = t_3;
    }
    *_S53 = bins_0;
    return;
}

struct Selection
{
    Reservoir r;
    float w_sum;
    float3  color;
    uint random_state;
    float3  glow;
    bool sums;
};

static __device__ Shift Shift_x24init_0(float3  f_0, float jac_0)
{
    Shift _S60;
    (&_S60)->f = f_0;
    (&_S60)->jac = jac_0;
    return _S60;
}

static __device__ Shift passWalk_0(Domain * dom_0, Reservoir * r_1, bool replay_0, float scale_0, Selection * sel_0)
{
    Shift _S61 = (fcptWalk((*dom_0), (*r_1), (replay_0), (scale_0), (sel_0)));
    return _S61;
}

static __device__ Shift passShift_0(Domain * dom_1, Reservoir * r_2)
{
    Selection _S62 = (Selection{});
    Selection sel_1 = _S62;
    bool _S63 = (r_2->w) <= 0.0f;
    if(_S63)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S64 = passWalk_0(dom_1, r_2, true, 0.0f, &sel_1);
    return _S64;
}

static __device__ uint queuedShift_0(uint3  workgroup_id_0, uint local_invocation_index_0)
{
    uint _S65 = workgroup_id_0.y * 65535U + workgroup_id_0.x;
    uint bin_0 = 0U;
    uint group_0 = _S65;
    uint start_0 = 0U;
    for(;;)
    {
        if(bin_0 < 40U)
        {
        }
        else
        {
            break;
        }
        uint _S66 = (fcptQueuedShifts((3U + bin_0)));
        uint _S67 = (_S66 + 63U) / 64U;
        bool _S68 = group_0 < _S67;
        if(_S68)
        {
            uint _S69 = group_0 * 64U + local_invocation_index_0;
            bool _S70 = _S69 < _S66;
            if(_S70)
            {
                uint _S71 = (fcptQueuedShifts((83U + start_0 + _S69)));
                return _S71;
            }
            return 4294967295U;
        }
        uint group_1 = group_0 - _S67;
        uint start_1 = start_0 + _S66;
        uint bin_1 = bin_0 + 1U;
        bin_0 = bin_1;
        group_0 = group_1;
        start_0 = start_1;
    }
    return 4294967295U;
}

static __device__ void queueShifts_0(int2  p_3, FixedArray<uint, 3>  * bins_1, uint3  global_invocation_id_0, uint local_invocation_index_1)
{
    uint bin_2;
    uint start_2;
    uint t_4 = 0U;
    for(;;)
    {
        if(t_4 < 3U)
        {
        }
        else
        {
            break;
        }
        uint _S72 = (*bins_1)[t_4];
        bool _S73 = ((*bins_1)[t_4]) < 40U;
        if(_S73)
        {
            bin_2 = 0U;
            start_2 = 0U;
            for(;;)
            {
                if(bin_2 < _S72)
                {
                }
                else
                {
                    break;
                }
                uint _S74 = (fcptQueueCountLoad((bin_2)));
                uint start_3 = start_2 + _S74;
                uint bin_3 = bin_2 + 1U;
                bin_2 = bin_3;
                start_2 = start_3;
            }
            uint _S75 = (fcptQueueCursorAdd((_S72), (1U)));
            fcptQueueJobStore((start_2 + _S75), ((uint(p_3.x) | (uint(p_3.y) << 14U)) | (t_4 << 28U)));
        }
        uint t_5 = t_4 + 1U;
        t_4 = t_5;
    }
    bool _S76 = all_0(uint2 {global_invocation_id_0.x, global_invocation_id_0.y} == make_uint2 (0U));
    if(_S76)
    {
        bin_2 = 0U;
        start_2 = 0U;
        for(;;)
        {
            if(bin_2 < 40U)
            {
            }
            else
            {
                break;
            }
            uint _S77 = (fcptQueueCountLoad((bin_2)));
            uint groups_0 = start_2 + (_S77 + 63U) / 64U;
            uint bin_4 = bin_2 + 1U;
            bin_2 = bin_4;
            start_2 = groups_0;
        }
        fcptQueueDispatchStore(((U32_min((start_2), (65535U)))), ((start_2 + 65534U) / 65535U), (1U));
    }
    return;
}

static __device__ FKHit Hit_x24init_0(float2  uv_0, uint instance_index_0, uint triangle_index_0, uint is_point_light_0, float distance_0)
{
    FKHit _S78;
    (&_S78)->uv = uv_0;
    (&_S78)->instance_index = instance_index_0;
    (&_S78)->triangle_index = triangle_index_0;
    (&_S78)->is_point_light = is_point_light_0;
    (&_S78)->distance = distance_0;
    return _S78;
}

static __device__ Domain Domain_x24init_0(float3  x0_0, float3  x1_0, FKHit * hit_0, float width_0, float spread_0)
{
    Domain _S79;
    (&_S79)->x0 = x0_0;
    (&_S79)->x1 = x1_0;
    (&_S79)->hit = *hit_0;
    (&_S79)->width = width_0;
    (&_S79)->spread = spread_0;
    return _S79;
}

static __device__ bool previousValid_0(int2  q_1)
{
    bool _S80 = all_0(q_1 >= make_int2 (int(0)));
    bool _S81;
    if(_S80)
    {
        uint2  _S82 = (fcptRenderSize());
        int2  _S83 = make_int2 ((int)_S82.x, (int)_S82.y);
        _S81 = all_0(q_1 < _S83);
    }
    else
    {
        _S81 = false;
    }
    if(_S81)
    {
        uint4  _S84 = (fcptReservoirPrevious((q_1), (0U)));
        _S81 = (U32_asfloat((_S84.w))) > 0.0f;
    }
    else
    {
        _S81 = false;
    }
    return _S81;
}

static __device__ bool all_1(bool3  x_4)
{
    bool result_2 = true;
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
        if(result_2)
        {
            result_2 = (bool((_slang_vector_get_element(x_4, i_2))));
        }
        else
        {
            result_2 = false;
        }
        i_2 = i_2 + int(1);
    }
    return result_2;
}

static __device__ bool sameDomain_0(Domain * a_0, Domain * b_0)
{
    bool _S85 = all_1((a_0->x0) == (b_0->x0));
    bool _S86;
    if(_S85)
    {
        _S86 = ((&a_0->hit)->instance_index) == ((&b_0->hit)->instance_index);
    }
    else
    {
        _S86 = false;
    }
    if(_S86)
    {
        _S86 = ((&a_0->hit)->triangle_index) == ((&b_0->hit)->triangle_index);
    }
    else
    {
        _S86 = false;
    }
    if(_S86)
    {
        _S86 = all_0(((&a_0->hit)->uv) == ((&b_0->hit)->uv));
    }
    else
    {
        _S86 = false;
    }
    return _S86;
}

static __device__ float2  floor_0(float2  x_5)
{
    float2  result_3;
    int i_3 = int(0);
    for(;;)
    {
        if(i_3 < int(2))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_3, i_3) = (F32_floor((_slang_vector_get_element(x_5, i_3))));
        i_3 = i_3 + int(1);
    }
    return result_3;
}

static __device__ float dot_0(float3  x_6, float3  y_0)
{
    return x_6.x * y_0.x + x_6.y * y_0.y + x_6.z * y_0.z;
}

static __device__ float length_0(float3  x_7)
{
    return (F32_sqrt((dot_0(x_7, x_7))));
}

static __device__ float distance_1(float3  x_8, float3  y_1)
{
    return length_0(x_8 - y_1);
}

static __device__ int2  temporalNeighbor_0(int2  p_4, Domain * dom_2, uint seed_1)
{
    bool _S87 = previousValid_0(p_4);
    bool _S88;
    if(_S87)
    {
        Domain _S89 = (fcptPreviousDomain((p_4), (seed_1)));
        Domain _S90 = _S89;
        bool _S91 = sameDomain_0(&_S90, dom_2);
        _S88 = _S91;
    }
    else
    {
        _S88 = false;
    }
    if(_S88)
    {
        return p_4;
    }
    uint _S92 = (&dom_2->hit)->instance_index;
    bool _S93 = ((&dom_2->hit)->instance_index) == 4294967295U;
    if(_S93)
    {
        return make_int2 (int(-1));
    }
    float3  _S94 = dom_2->x1;
    float2  _S95 = (fcptPixelOf((dom_2->x1), (true)));
    float2  _S96 = floor_0(_S95);
    int2  _S97 = make_int2 ((int)_S96.x, (int)_S96.y);
    bool _S98 = previousValid_0(_S97);
    bool _S99 = !_S98;
    if(_S99)
    {
        return make_int2 (int(-1));
    }
    uint4  _S100 = (fcptReservoirPrevious((_S97), (0U)));
    Domain _S101 = (fcptPreviousDomain((_S97), (_S100.x)));
    bool _S102 = (_S101.hit.instance_index) == _S92;
    if(_S102)
    {
        float _S103 = distance_1(_S101.x1, _S94);
        float _S104 = (&dom_2->hit)->distance * 8.0f;
        uint2  _S105 = (fcptRenderSize());
        _S88 = _S103 <= (_S104 / float(_S105.x));
    }
    else
    {
        _S88 = false;
    }
    if(_S88)
    {
        return _S97;
    }
    int2  _S106 = p_4 + _S97;
    float2  _S107 = make_float2 ((float)_S106.x, (float)_S106.y);
    float2  _S108 = _S107 + make_float2 (1.0f);
    float2  _S109 = (fcptPixelOf((_S101.x1), (false)));
    float2  _S110 = floor_0(_S108 - _S109);
    int2  _S111 = make_int2 ((int)_S110.x, (int)_S110.y);
    int2  _S112 = make_int2 (int(-1));
    bool _S113 = previousValid_0(_S111);
    int2  _S114 = _slang_select(_S113, _S111,_S112);
    return _S114;
}

static __device__ bool temporalIdentity_0(uint t_6, Domain * source_0, Domain * target_1)
{
    bool _S115 = sameDomain_0(source_0, target_1);
    bool _S116;
    if(_S115)
    {
        bool _S117 = (fcptSceneUnchanged());
        if(_S117)
        {
            _S116 = true;
        }
        else
        {
            bool _S118 = t_6 == 1U;
            if(_S118)
            {
                bool _S119 = (fcptPreviousScenes());
                _S116 = !_S119;
            }
            else
            {
                _S116 = false;
            }
        }
    }
    else
    {
        _S116 = false;
    }
    return _S116;
}

static __device__ bool temporalJob_0(int2  p_5, uint t_7, ShiftJob * job_2, bool target_2)
{
    Reservoir _S120 = (fcptLoadReservoirInitial((p_5)));
    float3  _S121 = make_float3 (0.0f);
    FKHit _S122 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S123 = Domain_x24init_0(_S121, _S121, &_S122, 0.0f, 0.0f);
    Domain dom_3 = _S123;
    bool _S124 = t_7 > 1U;
    bool _S125;
    if(_S124)
    {
        _S125 = true;
    }
    else
    {
        bool _S126 = (fcptStoredDomainInitial((p_5), (_S120.seed), (&dom_3)));
        _S125 = !_S126;
    }
    if(_S125)
    {
        return false;
    }
    Domain _S127 = dom_3;
    int2  _S128 = temporalNeighbor_0(p_5, &_S127, _S120.seed);
    bool _S129 = (_S128.x) < int(0);
    if(_S129)
    {
        return false;
    }
    bool _S130 = t_7 == 0U;
    if(_S130)
    {
        Reservoir _S131 = (fcptLoadReservoirPrevious((_S128)));
        job_2->r = _S131;
        bool _S132 = !target_2;
        if(_S132)
        {
            bool _S133 = (fcptSceneUnchanged());
            _S125 = !_S133;
        }
        else
        {
            _S125 = false;
        }
        if(_S125)
        {
            return ((&job_2->r)->w) > 0.0f;
        }
        bool _S134 = ((&job_2->r)->w) > 0.0f;
        if(_S134)
        {
            bool _S135 = (fcptStoredDomainInitial((p_5), ((&job_2->r)->seed), (&job_2->dom)));
            _S125 = _S135;
        }
        else
        {
            _S125 = false;
        }
        if(_S125)
        {
            Domain _S136 = (fcptPreviousDomain((_S128), ((&job_2->r)->seed)));
            Domain _S137 = _S136;
            Domain _S138 = job_2->dom;
            bool _S139 = temporalIdentity_0(0U, &_S137, &_S138);
            _S125 = !_S139;
        }
        else
        {
            _S125 = false;
        }
        return _S125;
    }
    job_2->r = _S120;
    bool _S140 = !target_2;
    if(_S140)
    {
        bool _S141 = (fcptSceneUnchanged());
        _S125 = !_S141;
    }
    else
    {
        _S125 = false;
    }
    if(_S125)
    {
        bool _S142 = (fcptPreviousScenes());
        _S125 = _S142;
    }
    else
    {
        _S125 = false;
    }
    if(_S125)
    {
        return ((&job_2->r)->w) > 0.0f;
    }
    Domain _S143 = (fcptPreviousDomain((_S128), (_S120.seed)));
    job_2->dom = _S143;
    bool _S144 = ((&job_2->r)->w) > 0.0f;
    if(_S144)
    {
        Domain _S145 = job_2->dom;
        Domain _S146 = dom_3;
        bool _S147 = temporalIdentity_0(1U, &_S145, &_S146);
        _S125 = !_S147;
    }
    else
    {
        _S125 = false;
    }
    return _S125;
}

static __device__ void temporalBins_0(int2  p_6, FixedArray<uint, 3>  * _S148)
{
    FixedArray<uint, 3>  _S149 = { {
        40U, 40U, 40U
    } };
    FixedArray<uint, 3>  bins_2;
    bins_2[int(0)] = 40U;
    bins_2[int(1)] = 40U;
    bins_2[int(2)] = 40U;
    uint t_8 = 0U;
    for(;;)
    {
        if(t_8 < 2U)
        {
        }
        else
        {
            break;
        }
        ShiftJob _S150 = (ShiftJob{});
        ShiftJob job_3 = _S150;
        bool _S151 = temporalJob_0(p_6, t_8, &job_3, false);
        if(_S151)
        {
            Reservoir _S152 = (&job_3)->r;
            uint _S153 = shiftBin_0(&_S152);
            bins_2[t_8] = _S153;
        }
        uint t_9 = t_8 + 1U;
        t_8 = t_9;
    }
    *_S148 = bins_2;
    return;
}

static __device__ void countShifts_0(FixedArray<uint, 3>  * bins_3, uint local_invocation_index_2)
{
    uint t_10 = 0U;
    for(;;)
    {
        if(t_10 < 3U)
        {
        }
        else
        {
            break;
        }
        uint _S154 = (*bins_3)[t_10];
        bool _S155 = ((*bins_3)[t_10]) < 40U;
        if(_S155)
        {
            uint _S156 = (fcptQueueCountAdd((_S154), (1U)));
        }
        uint t_11 = t_10 + 1U;
        t_10 = t_11;
    }
    return;
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

static __device__ bool wrongSide_0(bool is_inside_0, bool refracted_0, float3  dir_0, float3  geometry_n_0)
{
    return (is_inside_0 == refracted_0) != ((dot_0(dir_0, geometry_n_0)) > 0.0f);
}

static __device__ FKRay Ray_x24init_0(float3  origin_0, float3  unit_direction_0)
{
    FKRay _S157;
    (&_S157)->origin = origin_0;
    (&_S157)->unit_direction = unit_direction_0;
    return _S157;
}

static __device__ float3  skyRadiance_0(float3  origin_1, FKSurface * surface_0, bool is_inside_1, float3  dir_1, ShadowContext * context_0, uint random_state_0)
{
    bool _S158 = wrongSide_0(is_inside_1, false, dir_1, surface_0->geometry_n);
    bool _S159 = is_inside_1 != _S158;
    float _S160 = surface_0->geometry_offset;
    float3  _S161 = surface_0->smooth_n;
    float3  _S162 = - surface_0->smooth_n;
    float3  _S163 = _slang_select(_S159, _S162,_S161);
    FKRay _S164 = Ray_x24init_0(origin_1 + make_float3 (_S160) * _S163, dir_1);
    bool _S165 = (dot_0(context_0->side, dir_1)) > 0.0f;
    float3  _S166 = (fcptEnvMapSample((dir_1), (0U), (3U)));
    float3  _S167 = context_0->extinction_behind;
    float3  _S168 = context_0->extinction_front;
    float3  _S169 = _slang_select(_S165, _S168,_S167);
    uint _S170 = context_0->fillings.x;
    uint _S171 = context_0->fillings.y;
    uint _S172 = _slang_select(_S165, _S171,_S170);
    uint _S173 = context_0->depth;
    uint _S174 = context_0->lobe;
    bool _S175 = context_0->surface;
    bool _S176;
    if(_S175)
    {
        _S176 = !context_0->fiber;
    }
    else
    {
        _S176 = false;
    }
    float _S177 = context_0->length;
    float _S178 = context_0->width;
    FKHit _S179 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    float3  _S180 = (fcptShadowTransmittanceIn((_S164), (4.294967296e+09f), (_S169), (_S172), (random_state_0), (_S173), (_S174), (_S176), (_S177), (_S178), (_S179), (_S179)));
    return _S166 * _S180;
}

static __device__ uint searchCDF_0(uint2  start_4, uint2  step_0, uint count_1, float u_0)
{
    uint _S181 = count_1 - 1U;
    uint low_0 = 0U;
    uint high_0 = _S181;
    for(;;)
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        uint _S182 = (low_0 + high_0) / 2U;
        float4  _S183 = (fcptEnvironmentCdf((start_4 + step_0 * make_uint2 (_S182))));
        bool _S184 = (_S183.x) > u_0;
        if(_S184)
        {
            high_0 = _S182;
        }
        else
        {
            uint _S185 = _S182 + 1U;
            low_0 = _S185;
        }
    }
    return low_0;
}

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

static __device__ float3  lightTransmittance_0(float3  origin_2, float3  smooth_n_0, float geometry_offset_0, float3  light_dir_0, ShadowContext * context_1, uint random_state_1, FKHit * light_0)
{
    float3  _S186 = ((((light_dir_0)) * make_float3(rnorm3df(((light_dir_0)).x, ((light_dir_0)).y, ((light_dir_0)).z))));
    bool _S187 = (dot_0(smooth_n_0, _S186)) < 0.0f;
    if(_S187)
    {
        return make_float3 (0.0f);
    }
    float3  _S188 = make_float3 (geometry_offset_0) * smooth_n_0;
    float3  _S189 = origin_2 + _S188;
    FKRay _S190 = Ray_x24init_0(_S189, _S186);
    bool _S191 = (dot_0(context_1->side, light_dir_0 + _S188)) > 0.0f;
    float _S192 = shadowLength(light_dir_0);
    float3  _S193 = context_1->extinction_behind;
    float3  _S194 = context_1->extinction_front;
    float3  _S195 = _slang_select(_S191, _S194,_S193);
    uint _S196 = context_1->fillings.x;
    uint _S197 = context_1->fillings.y;
    uint _S198 = _slang_select(_S191, _S197,_S196);
    uint _S199 = context_1->depth;
    uint _S200 = context_1->lobe;
    bool _S201 = context_1->surface;
    bool _S202;
    if(_S201)
    {
        _S202 = !context_1->fiber;
    }
    else
    {
        _S202 = false;
    }
    float _S203 = context_1->length;
    float _S204 = context_1->width;
    FKHit _S205;
    if(context_1->fiber)
    {
        _S205 = context_1->own;
    }
    else
    {
        _S205 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    }
    float3  _S206 = (fcptShadowTransmittanceIn((_S190), (_S192), (_S195), (_S198), (random_state_1), (_S199), (_S200), (_S202), (_S203), (_S204), (_S205), (*light_0)));
    return _S206;
}

__device__ float sine(float c_0)
{
    return (F32_sqrt(((F32_max((1.0f - c_0 * c_0), (0.0f))))));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S207 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S208 = cos_a_0 > cos_b_0;
    float _S209 = _slang_select(_S208, 1.0f,_S207);
    return _S209;
}

__device__ float importance(LightNode node_0, float3  p_7, float3  normal_0)
{
    float3  _S210 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S211 = node_0.high - node_0.low;
    float3  _S212 = p_7 - _S210;
    float3  _S213 = ((((_S212)) * make_float3(rnorm3df(((_S212)).x, ((_S212)).y, ((_S212)).z))));
    float _S214 = dot_0(_S212, _S212);
    float _S215 = dot_0(_S211, _S211) / 4.0f;
    float _S216 = (F32_abs((dot_0(node_0.w, _S213))));
    float _S217 = sine(node_0.cos_theta_o);
    float _S218 = (F32_sqrt(((F32_max((1.0f - _S215 / _S214), (0.0f))))));
    bool _S219 = _S214 < _S215;
    float _S220 = _slang_select(_S219, -1.0f,_S218);
    float _S221 = sine(_S220);
    float _S222 = sine(_S216);
    float _S223 = cosSubClamped(_S222, _S216, _S217, node_0.cos_theta_o);
    float _S224 = sine(_S216);
    float _S225 = _S224 * node_0.cos_theta_o - _S216 * _S217;
    bool _S226 = _S216 > (node_0.cos_theta_o);
    float _S227 = _slang_select(_S226, 0.0f,_S225);
    float _S228 = cosSubClamped(_S227, _S223, _S221, _S220);
    bool _S229 = _S228 <= 0.0f;
    if(_S229)
    {
        return 0.0f;
    }
    float _S230 = - dot_0(_S213, normal_0);
    float _S231 = node_0.phi * _S228 / (F32_max((_S214), (length_0(_S211) / 2.0f)));
    float _S232 = sine(_S230);
    float _S233 = cosSubClamped(_S232, _S230, _S221, _S220);
    bool _S234 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S235 = _slang_select(_S234, 1.0f,_S233);
    return (F32_max((_S231 * _S235), (0.0f)));
}

__device__ __forceinline__ float childShare(LightNode first_0, LightNode second_0, float3  p_8, float3  normal_1, uint child_0)
{
    float _S236 = importance(first_0, p_8, normal_1);
    float _S237 = importance(second_0, p_8, normal_1);
    float2  _S238 = make_float2 (_S236, _S237);
    float _S239 = _slang_vector_get_element(_S238, child_0) / (_S236 + _S237);
    bool _S240 = _slang_vector_get_element(_S238, child_0) > 0.0f;
    float _S241 = _slang_select(_S240, _S239,0.0f);
    return _S241;
}

__device__ float sphereDensity(float3  center_0, float radius_0, float3  p_9)
{
    float3  _S242 = center_0 - p_9;
    float _S243 = radius_0 * radius_0 / dot_0(_S242, _S242);
    bool _S244 = _S243 >= 1.0f;
    if(_S244)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S243)))) / (6.28318548202514648f * _S243);
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S245 = left_0.y;
    float _S246 = right_0.z;
    float _S247 = left_0.z;
    float _S248 = right_0.y;
    float _S249 = right_0.x;
    float _S250 = left_0.x;
    return make_float3 (_S245 * _S246 - _S247 * _S248, _S247 * _S249 - _S250 * _S246, _S250 * _S248 - _S245 * _S249);
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_0))));
}

static __device__ float lightPdf_0(float3  origin_3, float3  smooth_n_1, float3  start_5, uint j_0, float3  light_point_0)
{
    bool _S251 = j_0 == 4294967295U;
    if(_S251)
    {
        return 0.0f;
    }
    uint4  _S252 = (fcptLightTrail((j_0)));
    uint2  _S253 = uint2 {_S252.x, _S252.y};
    uint n_0 = 0U;
    uint2  trail_0 = _S253;
    float probability_1 = 1.0f;
    for(;;)
    {
        uint4  _S254 = (fcptLightNode((n_0)));
        if((_S254.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S255 = (fcptLightSecond((n_0)));
        uint _S256 = n_0 + 1U;
        LightNode _S257 = (fcptLightBounds((_S256)));
        LightNode _S258 = (fcptLightBounds((_S255)));
        uint _S259 = trail_0.x;
        uint _S260 = _S259 & 1U;
        float _S261 = childShare(_S257, _S258, origin_3, smooth_n_1, _S260);
        float probability_2 = probability_1 * _S261;
        bool _S262 = _S260 == 1U;
        uint _S263 = _slang_select(_S262, _S255,_S256);
        uint _S264 = trail_0.y;
        uint2  _S265 = make_uint2 ((_S259 >> 1U) | (_S264 << 31U), _S264 >> 1U);
        n_0 = _S263;
        trail_0 = _S265;
        probability_1 = probability_2;
    }
    bool _S266 = (fcptSlotLeaf((n_0), (j_0)));
    bool _S267 = !_S266;
    bool _S268;
    if(_S267)
    {
        _S268 = true;
    }
    else
    {
        LightNode _S269 = (fcptLightBounds((n_0)));
        float _S270 = importance(_S269, origin_3, smooth_n_1);
        _S268 = !(_S270 > 0.0f);
    }
    if(_S268)
    {
        _S268 = true;
    }
    else
    {
        bool _S271 = (dot_0(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S271)
        {
            _S268 = !((dot_0(smooth_n_1, light_point_0 - origin_3)) > 0.0f);
        }
        else
        {
            _S268 = false;
        }
    }
    if(_S268)
    {
        return 0.0f;
    }
    uint4  _S272 = (fcptLightNode((n_0)));
    bool _S273 = (_S272.x) == 2U;
    if(_S273)
    {
        FKLight _S274 = (fcptLight((_S272.y)));
        float _S275 = sphereDensity(_S274.position, _S274.variance, start_5);
        return probability_1 * _S275;
    }
    uint _S276 = _S272.y;
    uint _S277 = (fcptTriangleOffset((_S276)));
    Matrix<float, 3, 3>  _S278 = (fcptWorldTriangle((_S276), (_S277 + _S272.z)));
    float _S279 = solidAngle(probability_1, cross_0(_S278.rows[int(1)] - _S278.rows[int(0)], _S278.rows[int(2)] - _S278.rows[int(0)]), light_point_0 - start_5);
    return _S279;
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

static __device__ Random Random_x24init_0(uint state_0, float value_0)
{
    Random _S280;
    (&_S280)->state = state_0;
    (&_S280)->value = value_0;
    return _S280;
}

__device__ Random pcg(uint state_1)
{
    uint _S281 = hash(state_1);
    float value_1 = float(_S281 >> int(8)) * 5.9604644775390625e-08f;
    return Random_x24init_0(_S281, value_1);
}

static __device__ float clamp_1(float x_9, float minBound_1, float maxBound_1)
{
    return (F32_min(((F32_max((x_9), (minBound_1)))), (maxBound_1)));
}

static __device__ uint2  min_0(uint2  x_10, uint2  y_2)
{
    uint2  result_4;
    int i_4 = int(0);
    for(;;)
    {
        if(i_4 < int(2))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_4, i_4) = (U32_min((_slang_vector_get_element(x_10, i_4)), (_slang_vector_get_element(y_2, i_4))));
        i_4 = i_4 + int(1);
    }
    return result_4;
}

static __device__ float dot_1(float2  x_11, float2  y_3)
{
    return x_11.x * y_3.x + x_11.y * y_3.y;
}

static __device__ float length_1(float2  x_12)
{
    return (F32_sqrt((dot_1(x_12, x_12))));
}

static __device__ float environmentPdf_0(float3  dir_2)
{
    uint2  _S282 = (fcptEnvironmentCdfSize());
    uint2  _S283 = _S282 - make_uint2 (1U, 0U);
    float2  _S284 = make_float2 ((F32_atan2((- dir_2.y), (dir_2.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_1(dir_2.z, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S285 = make_float2 ((float)_S283.x, (float)_S283.y);
    float2  _S286 = _S284 * _S285;
    uint2  _S287 = make_uint2 ((uint)_S286.x, (uint)_S286.y);
    uint2  _S288 = min_0(_S287, _S283 - make_uint2 (1U));
    float4  _S289 = (fcptEnvironmentCdf((_S288)));
    float _S290 = _S289.y;
    uint _S291 = _S283.x;
    float4  _S292 = (fcptEnvironmentCdf((make_uint2 (_S291, _S288.y))));
    float _S293 = _S290 * _S292.y;
    return _S293 * float(_S291 * _S283.y) / (19.73921012878417969f * length_1(float2 {dir_2.x, dir_2.y}));
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    bool _S294 = e_1 < 0.0f;
    float _S295 = _slang_select(_S294, -1.0f,0.0f);
    bool _S296 = e_1 > 0.0f;
    float _S297 = _slang_select(_S296, 1.0f,_S295);
    return _S297;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S298;
    (&_S298)->tangent = tangent_0;
    (&_S298)->alphas = alphas_0;
    return _S298;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S299 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S299)
    {
        float3  _S300 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S300;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S301 = cross_0(n_1, a_2);
    float3  _S302 = ((((_S301)) * make_float3(rnorm3df(((_S301)).x, ((_S301)).y, ((_S301)).z))));
    float3  _S303 = cross_0(n_1, _S302);
    return make_float3 (v_0.x) * _S302 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S303;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_0, float3  n_i_0)
{
    float _S304 = material_0.roughness;
    float _S305 = _S304 * _S304;
    bool _S306 = (material_0.anisotropy) == 0.0f;
    bool _S307;
    if(_S306)
    {
        _S307 = true;
    }
    else
    {
        _S307 = !(_S305 > 0.0f);
    }
    if(_S307)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S308 = material_0.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_0.tangent));
    float3  _S309 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S310 = (dot_0(_S308, _S308)) > 0.0f;
    float3  _S311 = _slang_select(_S310, _S308,_S309);
    float3  _S312 = ((((_S311)) * make_float3(rnorm3df(((_S311)).x, ((_S311)).y, ((_S311)).z))));
    float _S313 = 6.28318548202514648f * material_0.anisotropic_rotation;
    float _S314 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_0.anisotropy))))));
    float _S315 = 1.0f / _S314;
    bool _S316 = (material_0.anisotropy) < 0.0f;
    float _S317 = _slang_select(_S316, _S315,_S314);
    return AnisotropicFrame_x24init_0(_S312 * make_float3 ((F32_cos((_S313)))) + cross_0(n_i_0, _S312) * make_float3 ((F32_sin((_S313)))), make_float2 (_S305 / _S317, _S305 * _S317));
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S318;
    (&_S318)->on = on_0;
    (&_S318)->albedo = albedo_0;
    return _S318;
}

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

__device__ static const FixedArray<float, 576>  VELVET_ALBEDO_0 = { {
    1.03603994846343994f, 1.04969000816345215f, 1.02470004558563232f, 1.01461005210876465f, 1.00961005687713623f, 1.00680005550384521f, 1.0050499439239502f, 1.00390005111694336f, 1.00312995910644531f, 1.00258004665374756f, 1.00213003158569336f, 1.0017399787902832f, 1.00138998031616211f, 1.00112998485565186f, 1.00097000598907471f, 1.00092995166778564f, 1.00098001956939697f, 1.00108003616333008f, 1.0011899471282959f, 1.00127995014190674f, 1.0013200044631958f, 1.00134003162384033f, 1.00133001804351807f, 1.00130999088287354f, 0.90734100341796875f, 0.98275798559188843f, 0.98386698961257935f, 0.98714500665664673f, 0.98988902568817139f, 0.99194902181625366f, 0.99348098039627075f, 0.99463999271392822f, 0.99551397562026978f, 0.99620199203491211f, 0.99678301811218262f, 0.99725902080535889f, 0.99762099981307983f, 0.99788099527359009f, 0.99806898832321167f, 0.99822998046875f, 0.9984009861946106f, 0.99860197305679321f, 0.99882900714874268f, 0.99905097484588623f, 0.99924802780151367f, 0.99941599369049072f, 0.99955397844314575f, 0.99966597557067871f, 0.47049999237060547f, 0.72047901153564453f, 0.82541298866271973f, 0.88024801015853882f, 0.91317099332809448f, 0.93422400951385498f, 0.94845300912857056f, 0.9585450291633606f, 0.96597200632095337f, 0.97161900997161865f, 0.97599798440933228f, 0.97946298122406006f, 0.98225301504135132f, 0.98453700542449951f, 0.98643702268600464f, 0.98803901672363281f, 0.98940402269363403f, 0.99057799577713013f, 0.99159497022628784f, 0.9924740195274353f, 0.99323201179504395f, 0.99394601583480835f, 0.9946179986000061f, 0.99514299631118774f, 0.10339099913835526f, 0.37652701139450073f, 0.58990597724914551f, 0.7168310284614563f, 0.79374098777770996f, 0.8438420295715332f, 0.87787497043609619f, 0.90189200639724731f, 0.919514000415802f, 0.93284100294113159f, 0.94317400455474854f, 0.95135498046875f, 0.95794999599456787f, 0.9633520245552063f, 0.96783697605133057f, 0.97160798311233521f, 0.97481298446655273f, 0.97755998373031616f, 0.97992998361587524f, 0.98198497295379639f, 0.98377299308776855f, 0.98532998561859131f, 0.98668897151947021f, 0.98788100481033325f, 0.00549574987962842f, 0.12130799889564514f, 0.33038300275802612f, 0.50957399606704712f, 0.63582301139831543f, 0.72130399942398071f, 0.78063100576400757f, 0.82337701320648193f, 0.85500001907348633f, 0.87895798683166504f, 0.89755398035049438f, 0.91228801012039185f, 0.92417001724243164f, 0.93390399217605591f, 0.94199001789093018f, 0.94878798723220825f, 0.95456397533416748f, 0.95951497554779053f, 0.96378600597381592f, 0.96749001741409302f, 0.97071200609207153f, 0.97352099418640137f, 0.97597402334213257f, 0.97811698913574219f, 0.00006616840255447f, 0.01978570036590099f, 0.13480900228023529f, 0.30441498756408691f, 0.4568449854850769f, 0.57461702823638916f, 0.66137099266052246f, 0.72547799348831177f, 0.77361601591110229f, 0.81061500310897827f, 0.83951497077941895f, 0.86248302459716797f, 0.88104599714279175f, 0.89627498388290405f, 0.90893799066543579f, 0.91959297657012939f, 0.92865198850631714f, 0.93641901016235352f, 0.94312202930450439f, 0.94893598556518555f, 0.95399397611618042f, 0.95840400457382202f, 0.96225601434707642f, 0.96562099456787109f, 6.08604011631541653e-08f, 0.00167625001631677f, 0.03686590120196342f, 0.14405199885368347f, 0.28643798828125f, 0.41852200031280518f, 0.5268089771270752f, 0.61179697513580322f, 0.67761099338531494f, 0.72897201776504517f, 0.76956802606582642f, 0.80211901664733887f, 0.82861298322677612f, 0.85041999816894531f, 0.86859399080276489f, 0.88391202688217163f, 0.89695101976394653f, 0.90814197063446045f, 0.91780698299407959f, 0.9261929988861084f, 0.933493971824646f, 0.93986201286315918f, 0.94542300701141357f, 0.95028501749038696f, 1.25722999719246609e-12f, 0.00005344190140022f, 0.00689807021990418f, 0.05298750102519989f, 0.15135200321674347f, 0.27379500865936279f, 0.38978201150894165f, 0.48924699425697327f, 0.57068902254104614f, 0.6363450288772583f, 0.68930798768997192f, 0.73230600357055664f, 0.7675589919090271f, 0.79679697751998901f, 0.82128000259399414f, 0.84197902679443359f, 0.85963702201843262f, 0.87481701374053955f, 0.88794499635696411f, 0.89934700727462769f, 0.90928000211715698f, 0.91794902086257935f, 0.92552399635314941f, 0.93214702606201172f, 1.32430000482605838e-19f, 4.34398998550022952e-07f, 0.00078319699969143f, 0.01505979988723993f, 0.06700140237808228f, 0.15685500204563141f, 0.26414799690246582f, 0.36752399802207947f, 0.45892399549484253f, 0.53633898496627808f, 0.60086798667907715f, 0.65432101488113403f, 0.69876497983932495f, 0.73594701290130615f, 0.76730400323867798f, 0.79397499561309814f, 0.8168100118637085f, 0.83649301528930664f, 0.85354900360107422f, 0.86838698387145996f, 0.88132798671722412f, 0.89263200759887695f, 0.90251702070236206f, 0.91116297245025635f, 1.21214998864702984e-29f, 5.61858004566317959e-10f, 0.00004580340100802f, 0.00315008009783924f, 0.02455909922719002f, 0.07877019792795181f, 0.16104799509048462f, 0.25635600090026855f, 0.34949898719787598f, 0.43382999300956726f, 0.50729697942733765f, 0.57010501623153687f, 0.62341398000717163f, 0.66865599155426025f, 0.70718997716903687f, 0.74018502235412598f, 0.76862901449203491f, 0.79324597120285034f, 0.8146439790725708f, 0.83329999446868896f, 0.84960097074508667f, 0.86386102437973022f, 0.87634098529815674f, 0.88726699352264404f, 1.17709071003284634e-43f, 6.58941014274917747e-14f, 1.12094994619837962e-06f, 0.00044787500519305f, 0.00728174997493625f, 0.03418119996786118f, 0.08846849948167801f, 0.16411800682544708f, 0.24980400502681732f, 0.33453500270843506f, 0.41271701455116272f, 0.48244500160217285f, 0.54331201314926147f, 0.59608602523803711f, 0.64167797565460205f, 0.68114197254180908f, 0.71539402008056641f, 0.7452319860458374f, 0.77129900455474854f, 0.79410398006439209f, 0.81407999992370605f, 0.83158797025680542f, 0.846934974193573f, 0.86038398742675781f, 0.0f, 3.5722200588590534e-19f, 8.93677043478646738e-09f, 0.00003873859895975f, 0.00167270004749298f, 0.01264849957078695f, 0.04320650175213814f, 0.09630840271711349f, 0.16610400378704071f, 0.24392600357532501f, 0.32165700197219849f, 0.394569993019104f, 0.46081000566482544f, 0.51976299285888672f, 0.57175701856613159f, 0.61742901802062988f, 0.65750598907470703f, 0.69269400835037231f, 0.72362500429153442f, 0.75082802772521973f, 0.77473902702331543f, 0.79575198888778687f, 0.81420797109603882f, 0.83040601015090942f, 0.0f, 3.95292991891679393e-26f, 1.71184993263961971e-11f, 1.77651998001238098e-06f, 0.0002783710078802f, 0.00388711993582547f, 0.01858510076999664f, 0.05124599859118462f, 0.10246899724006653f, 0.16709500551223755f, 0.23837999999523163f, 0.31022000312805176f, 0.37857699394226074f, 0.44168499112129211f, 0.4988040030002594f, 0.54993897676467896f, 0.59550100564956665f, 0.63594001531600952f, 0.67177599668502808f, 0.70349597930908203f, 0.73152798414230347f, 0.75625097751617432f, 0.77802300453186035f, 0.79716801643371582f, 0.0f, 3.2483199352805935e-35f, 5.40527002565222188e-15f, 3.64182994871953269e-08f, 0.00003074659980484f, 0.00094859098317102f, 0.00691073015332222f, 0.02452139928936958f, 0.05809320136904716f, 0.10707399994134903f, 0.16711099445819855f, 0.23287899792194366f, 0.29971298575401306f, 0.36412099003791809f, 0.42443698644638062f, 0.47984799742698669f, 0.53011900186538696f, 0.57539498805999756f, 0.61597698926925659f, 0.65218400955200195f, 0.6844019889831543f, 0.71295899152755737f, 0.73819798231124878f, 0.7604449987411499f, 0.0f, 0.0f, 1.7447100275121598e-19f, 2.68698008287771017e-10f, 2.01520992959558498e-06f, 0.00017266000213567f, 0.00214895000681281f, 0.01039279997348785f, 0.03002390079200268f, 0.06362999975681305f, 0.11018999665975571f, 0.16611799597740173f, 0.22714599967002869f, 0.2896830141544342f, 0.35065999627113342f, 0.40850698947906494f, 0.46232399344444275f, 0.51169002056121826f, 0.55654400587081909f, 0.59701400995254517f, 0.63333100080490112f, 0.66571998596191406f, 0.69448697566986084f, 0.71991300582885742f, 0.0f, 0.0f, 3.08185990824019565e-25f, 5.37352009676722586e-13f, 6.76860025805581245e-08f, 0.00002156710070267f, 0.00053187098819762f, 0.00379640003666282f, 0.01394980028271675f, 0.03477099910378456f, 0.06777119636535645f, 0.11182600259780884f, 0.16402900218963623f, 0.22092700004577637f, 0.27971801161766052f, 0.33767500519752502f, 0.3932889997959137f, 0.44556498527526855f, 0.493927001953125f, 0.53815799951553345f, 0.57827800512313843f, 0.61434602737426758f, 0.64652997255325317f, 0.67506802082061768f, 0.0f, 0.0f, 1.27565998769738086e-32f, 1.98236004320260421e-16f, 9.54645029693779179e-10f, 1.650769945626962e-06f, 0.00009778440289665f, 0.00114505004603416f, 0.00568277994170785f, 0.01722680032253265f, 0.03851649910211563f, 0.0704336017370224f, 0.11193899810314178f, 0.16071000695228577f, 0.21397699415683746f, 0.2693760097026825f, 0.32457900047302246f, 0.37806499004364014f, 0.42872300744056702f, 0.4758630096912384f, 0.51915699243545532f, 0.55846899747848511f, 0.59376901388168335f, 0.62519502639770508f, 0.0f, 0.0f, 3.7106383335321156e-42f, 7.81385018096993734e-21f, 4.26179013954253172e-12f, 6.59224994592477742e-08f, 0.00001210350001202f, 0.00026765500660986f, 0.00194808002561331f, 0.00754345022141933f, 0.01991299912333488f, 0.04105570167303085f, 0.0715148001909256f, 0.11042399704456329f, 0.15595099329948425f, 0.20584699511528015f, 0.25806799530982971f, 0.31055599451065063f, 0.36178100109100342f, 0.41049200296401978f, 0.45592901110649109f, 0.49765899777412415f, 0.53551197052001953f, 0.56948697566986084f, 0.0f, 0.0f, 0.0f, 1.4501699354155858e-26f, 3.9408500097373126e-15f, 1.07906994450956972e-09f, 8.70304006639344152e-07f, 0.0000440725016233f, 0.0005269440007396f, 0.00279516004957259f, 0.00910075008869171f, 0.02173379994928837f, 0.04219720140099525f, 0.07087449729442596f, 0.10709299892187119f, 0.14939899742603302f, 0.19591200351715088f, 0.24481700360774994f, 0.29424700140953064f, 0.34261700510978699f, 0.38869300484657288f, 0.43174698948860168f, 0.47139298915863037f, 0.50751799345016479f, 0.0f, 0.0f, 0.0f, 3.37722993781223165e-34f, 3.80885988849822355e-19f, 4.90656994200922014e-12f, 2.86603007992880521e-08f, 4.38328015661682002e-06f, 0.00010134100011783f, 0.00081476598279551f, 0.00349242007359862f, 0.01008209958672523f, 0.02243220061063766f, 0.04172819852828979f, 0.06827779859304428f, 0.10154099762439728f, 0.14030000567436218f, 0.18292999267578125f, 0.22785000503063202f, 0.27340999245643616f, 0.31820300221443176f, 0.36118099093437195f, 0.40175101161003113f, 0.43962100148200989f, 0.0f, 0.0f, 0.0f, 9.8090892502737195e-45f, 1.13511000171572082e-24f, 3.09601003078345365e-15f, 2.82900008974351636e-10f, 2.00208006617685896e-07f, 0.00001151220021711f, 0.00016400900494773f, 0.00102415005676448f, 0.00382522004656494f, 0.01021770015358925f, 0.02173330076038837f, 0.03936100006103516f, 0.06336659938097f, 0.09330789744853973f, 0.12818600237369537f, 0.16668100655078888f, 0.20739200711250305f, 0.24903899431228638f, 0.29063498973846436f, 0.33134400844573975f, 0.37064099311828613f, 0.0f, 0.0f, 0.0f, 0.0f, 8.14998004479130106e-33f, 6.36954985683458947e-20f, 3.45817992297714483e-13f, 2.37365993527305363e-09f, 5.25424979969102424e-07f, 0.00001739979961712f, 0.00018874299712479f, 0.00102673994842917f, 0.00357491988688707f, 0.00922095961868763f, 0.01929700002074242f, 0.03473329916596413f, 0.05588230118155479f, 0.08250939846038818f, 0.1139099970459938f, 0.14910100400447845f, 0.18701300024986267f, 0.22664099931716919f, 0.26713100075721741f, 0.3078019917011261f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 7.3832999238063224e-28f, 4.4141699295504271e-18f, 1.48473995684877957e-12f, 3.29401994569877843e-09f, 4.59630996374471579e-07f, 0.00001273939960811f, 0.00013086199760437f, 0.00071139499777928f, 0.00253174011595547f, 0.00673073995858431f, 0.01454710029065609f, 0.02702569961547852f, 0.04481859877705574f, 0.06811539828777313f, 0.09668000042438507f, 0.12994599342346191f, 0.1671299934387207f, 0.2073339968919754f, 0.24963200092315674f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 3.35172992357784324e-37f, 1.16603995591046571e-24f, 3.39939997419364372e-17f, 1.64230001126197678e-12f, 1.9398800343850553e-09f, 2.402420022917795e-07f, 7.1422400651499629e-06f, 0.00008337580220541f, 0.0005176099948585f, 0.00207298994064331f, 0.00607771007344127f, 0.01419879961758852f, 0.0280108992010355f, 0.04858930036425591f, 0.07628270238637924f, 0.11069700121879578f, 0.15084299445152283f, 0.19536399841308594f
} };
__device__ static const FixedArray<float, 576>  SHEEN_ALBEDO_0 = { {
    0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f
} };
__device__ __forceinline__ SheenProfile sheenProfile(float3  v_1, float3  n_i_1, BSDFMaterial material_1)
{
    SheenProfile _S319 = SheenProfile_x24init_0(false, 0.0f);
    float _S320 = rgb_to_greyscale(material_1.sheen);
    bool _S321 = _S320 > 0.0f;
    SheenProfile profile_0;
    if(_S321)
    {
        float _S322 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S323 = (U32_min((uint(_S322)), (22U)));
        float _S324 = (F32_sqrt((0.05000000074505806f)));
        float _S325 = (F32_sqrt((0.00999999977648258f)));
        bool _S326 = (material_1.velvet) > 0.0f;
        float _S327 = _slang_select(_S326, _S325,_S324);
        float _S328 = (clamp_1((F32_sqrt(((F32_max((material_1.sheen_roughness), (0.0f)))))), _S327, 1.0f) - _S327) / (1.0f - _S327) * 23.0f;
        uint _S329 = (U32_min((uint(_S328)), (22U)));
        uint _S330 = _S323 * 24U + _S329;
        float _S331 = _S322 - float(_S323);
        float _S332 = _S328 - float(_S329);
        if(_S326)
        {
            uint _S333 = _S330 + 24U;
            float _S334 = VELVET_ALBEDO_0[_S330] + (VELVET_ALBEDO_0[_S333] - VELVET_ALBEDO_0[_S330]) * _S331;
            uint _S335 = _S330 + 1U;
            float _S336 = VELVET_ALBEDO_0[_S335] + (VELVET_ALBEDO_0[_S333 + 1U] - VELVET_ALBEDO_0[_S335]) * _S331;
            SheenProfile _S337 = SheenProfile_x24init_0(true, _S334 + (_S336 - _S334) * _S332);
            profile_0 = _S337;
        }
        else
        {
            uint _S338 = _S330 + 24U;
            float _S339 = SHEEN_ALBEDO_0[_S330] + (SHEEN_ALBEDO_0[_S338] - SHEEN_ALBEDO_0[_S330]) * _S331;
            uint _S340 = _S330 + 1U;
            float _S341 = SHEEN_ALBEDO_0[_S340] + (SHEEN_ALBEDO_0[_S338 + 1U] - SHEEN_ALBEDO_0[_S340]) * _S331;
            SheenProfile _S342 = SheenProfile_x24init_0(true, (F32_exp((_S339 + (_S341 - _S339) * _S332))));
            profile_0 = _S342;
        }
    }
    else
    {
        profile_0 = _S319;
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
    float p_toon;
    float3  toon;
    float toon_a;
    float toon_s;
    float toon_b;
    bool toon_glossy;
    float toon_norm;
    float toon_view;
    float3  toon_axis;
};

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_0, float3  refracted_1, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_0, float3  sheen_0, float p_sheen_velvet_0, float3  view_0, float3  tangent_1, float2  alphas_1, float visible_0, float p_toon_0, float3  toon_0, float toon_a_0, float toon_s_0, float toon_b_0, bool toon_glossy_0, float toon_norm_0, float toon_view_0, float3  toon_axis_0)
{
    BSDFLobes _S343;
    (&_S343)->v_dot_h = v_dot_h_0;
    (&_S343)->n_dot_h = n_dot_h_0;
    (&_S343)->refracted = refracted_1;
    (&_S343)->F = F_0;
    (&_S343)->F_greyscale = F_greyscale_0;
    (&_S343)->reflect_weight = reflect_weight_0;
    (&_S343)->diffuse_weight = diffuse_weight_0;
    (&_S343)->refract_weight = refract_weight_0;
    (&_S343)->p_diffuse = p_diffuse_0;
    (&_S343)->p_reflect = p_reflect_0;
    (&_S343)->p_refract = p_refract_0;
    (&_S343)->translucent_share = translucent_share_0;
    (&_S343)->sheen = sheen_0;
    (&_S343)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S343)->view = view_0;
    (&_S343)->tangent = tangent_1;
    (&_S343)->alphas = alphas_1;
    (&_S343)->visible = visible_0;
    (&_S343)->p_toon = p_toon_0;
    (&_S343)->toon = toon_0;
    (&_S343)->toon_a = toon_a_0;
    (&_S343)->toon_s = toon_s_0;
    (&_S343)->toon_b = toon_b_0;
    (&_S343)->toon_glossy = toon_glossy_0;
    (&_S343)->toon_norm = toon_norm_0;
    (&_S343)->toon_view = toon_view_0;
    (&_S343)->toon_axis = toon_axis_0;
    return _S343;
}

__device__ float3  anisotropicLocal(float3  w_0, float3  t_12, float3  n_2)
{
    return make_float3 (dot_0(w_0, t_12), dot_0(w_0, cross_0(n_2, t_12)), dot_0(w_0, n_2));
}

static __device__ float unshared_0(float x_14)
{
    return x_14;
}

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_0, float U1_0, float U2_0)
{
    float3  _S344 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S345 = ((((_S344)) * make_float3(rnorm3df(((_S344)).x, ((_S344)).y, ((_S344)).z))));
    float _S346 = _S345.x;
    float _S347 = _S345.y;
    float _S348 = _S346 * _S346 + _S347 * _S347;
    float3  _S349 = make_float3 (1.0f, 0.0f, 0.0f);
    float3  _S350 = make_float3 (- _S347, _S346, 0.0f);
    float _S351 = (rsqrtf((_S348)));
    float3  _S352 = _S350 * make_float3 (_S351);
    bool _S353 = _S348 > 0.0f;
    float3  _S354 = _slang_select(_S353, _S352,_S349);
    float3  _S355 = cross_0(_S345, _S354);
    float _S356 = (F32_sqrt((U1_0)));
    float _S357 = 6.28318548202514648f * U2_0;
    float _S358 = _S356 * (F32_cos((_S357)));
    float t2_0 = _S356 * (F32_sin((_S357)));
    float _S359 = 0.5f * (1.0f + _S345.z);
    float t2_1 = (1.0f - _S359) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S358 * _S358)))))) + _S359 * t2_0;
    float3  _S360 = make_float3 (_S358) * _S354 + make_float3 (t2_1) * _S355;
    float _S361 = unshared_0(_S358);
    float _S362 = unshared_0(_S358);
    float3  _S363 = _S360 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S361 * _S362 - t2_1 * t2_1))))))) * _S345;
    float3  _S364 = make_float3 (alpha_0 * _S363.x, alpha_0 * _S363.y, (F32_max((0.0f), (_S363.z))));
    float3  _S365 = ((((_S364)) * make_float3(rnorm3df(((_S364)).x, ((_S364)).y, ((_S364)).z))));
    return _S365;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S366 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S366)
    {
        float3  _S367 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S367;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S368 = cross_0(n_3, a_4);
    float3  _S369 = ((((_S368)) * make_float3(rnorm3df(((_S368)).x, ((_S368)).y, ((_S368)).z))));
    float3  _S370 = cross_0(n_3, _S369);
    return make_float3 (dot_0(v_2, _S369), dot_0(v_2, n_3), dot_0(v_2, _S370));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S371 = pcg(*random_state_2);
    Random _S372 = pcg(_S371.state);
    *random_state_2 = _S372.state;
    float _S373 = frame_0.alphas.x;
    bool _S374 = _S373 > 0.0f;
    if(_S374)
    {
        float3  _S375 = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        float _S376 = frame_0.alphas.y;
        float3  _S377 = make_float3 (_S373 * _S375.x, _S376 * _S375.y, _S375.z);
        float3  _S378 = ((((_S377)) * make_float3(rnorm3df(((_S377)).x, ((_S377)).y, ((_S377)).z))));
        float3  _S379 = sampleGGXVNDF(_S378, 1.0f, _S371.value, _S372.value);
        float3  _S380 = make_float3 (_S373 * _S379.x, _S376 * _S379.y, _S379.z);
        float3  _S381 = ((((_S380)) * make_float3(rnorm3df(((_S380)).x, ((_S380)).y, ((_S380)).z))));
        return make_float3 (_S381.x) * frame_0.tangent + make_float3 (_S381.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S381.z) * n_i_2;
    }
    float3  _S382 = worldToTangent(v_3, n_i_2);
    float3  _S383 = sampleGGXVNDF(float3 {_S382.x, _S382.z, _S382.y}, alpha_1, _S371.value, _S372.value);
    float3  _S384 = float3 {_S383.x, _S383.z, _S383.y};
    float3  _S385 = tangentToWorld(_S384, n_i_2);
    return _S385;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_4, BSDFMaterial material_2, uint random_state_3, AnisotropicFrame frame_1)
{
    uint state_2 = random_state_3;
    float3  _S386 = negate_0(in_dir_0);
    float _S387 = sign_0(dot_0(n_4, _S386));
    float _S388 = material_2.roughness;
    float3  _S389 = sampleHalfVector(_S386, n_4 * make_float3 (_S387), _S388 * _S388, frame_1, &state_2);
    return _S389;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_5, float eta_i_0, float eta_o_0)
{
    float3  _S390 = negate_0(in_dir_1);
    float3  _S391 = negate_0(make_float3 (eta_i_0) * _S390 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S392 = ((((_S391)) * make_float3(rnorm3df(((_S391)).x, ((_S391)).y, ((_S391)).z))));
    float _S393 = sign_0(dot_0(n_5, _S390));
    float _S394 = sign_0(dot_0(_S391, n_5 * make_float3 (_S393)));
    return _S392 * make_float3 (_S394);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S395 = negate_0(in_dir_2);
    float3  _S396 = _S395 + out_dir_1;
    float3  _S397 = ((((_S396)) * make_float3(rnorm3df(((_S396)).x, ((_S396)).y, ((_S396)).z))));
    return _S397;
}

static __device__ float3  refract_0(float3  i_5, float3  n_6, float eta_0)
{
    float _S398 = dot_0(n_6, i_5);
    float _S399 = 1.0f - eta_0 * eta_0 * (1.0f - _S398 * _S398);
    if(_S399 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S398 + (F32_sqrt((_S399)))) * n_6;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S400 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S401 = eta_i_1 / eta_o_1 * _S400;
    bool _S402 = _S401 < 1.0f;
    float kr_0;
    if(_S402)
    {
        float _S403 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S401 * _S401))))));
        bool _S404 = eta_i_1 == eta_o_1;
        float _S405 = _slang_select(_S404, cos_theta_0,_S403);
        float _S406 = eta_o_1 * cos_theta_0;
        float _S407 = eta_i_1 * _S405;
        float _S408 = (_S406 - _S407) / (_S406 + _S407);
        float _S409 = eta_i_1 * cos_theta_0;
        float _S410 = eta_o_1 * _S405;
        float _S411 = (_S409 - _S410) / (_S409 + _S410);
        float _S412 = (_S408 * _S408 + _S411 * _S411) / 2.0f;
        kr_0 = _S412;
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
    float _S413 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S413 / (_S413 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S413)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S414 = alphas_3.x;
    float _S415 = h_0.x / _S414;
    float _S416 = alphas_3.y;
    float _S417 = h_0.y / _S416;
    float _S418 = h_0.z;
    float _S419 = _S415 * _S415 + _S417 * _S417 + _S418 * _S418;
    return 1.0f / (F32_max((3.14159274101257324f * _S414 * _S416 * _S419 * _S419), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_4, float3  n_i_3, float3  ggx_n_0, BSDFMaterial material_3, float eta_i_2, float eta_o_2, AnisotropicFrame frame_2, SheenProfile sheen_profile_0)
{
    float _S420 = dot_0(ggx_n_0, v_4);
    float _S421 = dot_0(n_i_3, ggx_n_0);
    float _S422 = eta_i_2 / eta_o_2;
    float3  _S423 = refract_0(in_dir_3, ggx_n_0, _S422);
    float3  _S424 = ((((_S423)) * make_float3(rnorm3df(((_S423)).x, ((_S423)).y, ((_S423)).z))));
    float _S425 = (F32_min(((F32_sqrt((material_3.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S426 = _S425 * _S425;
    float _S427 = (1.0f + _S425) / (1.0f - _S425);
    float _S428 = (F32_abs((_S420)));
    bool _S429 = eta_i_2 > eta_o_2;
    float _S430 = _slang_select(_S429, _S427,1.0f);
    float _S431 = _slang_select(_S429, 1.0f,_S427);
    float _S432 = fresnel(_S428, _S430, _S431);
    bool _S433 = (eta_i_2 * eta_i_2 * (1.0f - _S420 * _S420)) >= (eta_o_2 * eta_o_2);
    float3  _S434 = material_3.specular_tint * make_float3 (_S426);
    float3  _S435 = _S434 + (make_float3 (1.0f) - _S434) * make_float3 (_S432 - _S426) / make_float3 (1.0f - _S426);
    float3  _S436 = make_float3 (1.0f);
    float3  _S437 = _slang_select(_S433, _S436,_S435);
    float3  _S438 = make_float3 (0.0f);
    float sheen_component_0;
    float3  sheen_1;
    float3  view_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S439 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S440 = make_float3 (1.0f) - material_3.sheen * make_float3 (_S439);
        float _S441 = rgb_to_greyscale(material_3.sheen);
        float _S442 = _S441 * _S439;
        float3  _S443 = material_3.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S442;
        sheen_1 = _S443;
        view_1 = v_4;
        scale_1 = _S440;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S438;
        view_1 = _S438;
        scale_1 = _S436;
    }
    float _S444 = material_3.toon.x;
    bool _S445 = _S444 < 0.0f;
    float _S446 = (F32_abs((_S444)));
    bool _S447 = _S446 > 0.0f;
    float toon_component_0;
    float toon_a_1;
    float toon_s_1;
    float toon_b_1;
    float toon_norm_1;
    float toon_view_1;
    float3  toon_1;
    float3  toon_axis_1;
    bool _S448;
    if(_S447)
    {
        float _S449 = (F32_min((_S446), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S449);
        float _S450 = rgb_to_greyscale(material_3.albedo);
        float _S451 = _S449 * _S450;
        float3  _S452 = make_float3 (_S449) * material_3.albedo;
        float toon_a_2 = clamp_1(material_3.toon.y / _S444, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_2 = clamp_1(material_3.toon.z / _S444, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S453 = (F32_min((toon_a_2 + toon_s_2), (1.57079637050628662f)));
        if(_S445)
        {
            toon_component_0 = 1.0f - (F32_cos(((F32_min((_S453), (toon_a_2))))));
        }
        else
        {
            float _S454 = (F32_sin(((F32_min((_S453), (toon_a_2))))));
            toon_component_0 = _S454 * _S454 / 2.0f;
        }
        bool _S455 = _S453 > toon_a_2;
        if(_S455)
        {
            _S448 = toon_s_2 > 0.0f;
        }
        else
        {
            _S448 = false;
        }
        if(_S448)
        {
            if(_S445)
            {
                float _S456 = (F32_cos((toon_a_2)));
                float _S457 = (F32_cos((_S453)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S456 - _S457) - ((F32_sin((_S453))) - _S453 * _S457 - ((F32_sin((toon_a_2))) - toon_a_2 * _S456)) / toon_s_2;
            }
            else
            {
                float _S458 = 2.0f * toon_a_2;
                float _S459 = (F32_cos((_S458)));
                float _S460 = 2.0f * _S453;
                float _S461 = (F32_cos((_S460)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S459 - _S461) / 4.0f - ((F32_sin((_S460))) / 8.0f - _S453 * _S461 / 4.0f - ((F32_sin((_S458))) / 8.0f - toon_a_2 * _S459 / 4.0f)) / toon_s_2;
            }
            float integral_0 = toon_component_0 + toon_a_1;
            toon_component_0 = integral_0;
        }
        float _S462 = 6.28318548202514648f * toon_component_0;
        float _S463 = dot_0(n_i_3, v_4);
        float _S464 = (F32_acos(((F32_min((_S463), (1.0f))))));
        if(_S464 < toon_a_2)
        {
            toon_component_0 = 1.0f;
        }
        else
        {
            toon_component_0 = (F32_max((1.0f - (_S464 - toon_a_2) / (F32_max((toon_s_2), (0.0000152587890625f)))), (0.0f)));
        }
        if(_S445)
        {
            float3  _S465 = make_float3 (2.0f * _S463) * n_i_3 - v_4;
            float3  _S466 = ((((_S465)) * make_float3(rnorm3df(((_S465)).x, ((_S465)).y, ((_S465)).z))));
            scale_1 = _S466;
        }
        else
        {
            scale_1 = n_i_3;
        }
        float _S467 = toon_component_0;
        toon_component_0 = _S451;
        toon_1 = _S452;
        toon_a_1 = toon_a_2;
        toon_s_1 = toon_s_2;
        toon_b_1 = _S453;
        toon_norm_1 = _S462;
        toon_view_1 = _S467;
        toon_axis_1 = scale_1;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S438;
        toon_a_1 = 0.0f;
        toon_s_1 = 0.0f;
        toon_b_1 = 0.0f;
        toon_norm_1 = 1.0f;
        toon_view_1 = 0.0f;
        toon_axis_1 = n_i_3;
    }
    float3  _S468 = mix_0(_S437, material_3.albedo, material_3.metallic);
    float3  F_1 = _S468 * scale_1;
    float _S469 = rgb_to_greyscale(F_1);
    float _S470 = 1.0f - material_3.metallic;
    float3  _S471 = make_float3 (1.0f) - _S437;
    float3  _S472 = make_float3 ((1.0f - material_3.transmission) * _S470) * _S471 * scale_1;
    float3  _S473 = make_float3 (material_3.transmission * _S470) * _S471 * scale_1;
    float _S474 = (F32_max((_S469), (0.0f)));
    float _S475 = rgb_to_greyscale(_S472);
    float _S476 = (F32_max((_S475), (0.0f)));
    float _S477 = rgb_to_greyscale(_S473);
    float _S478 = sign_0(length_0(_S424));
    float _S479 = (F32_max((_S477 * _S478), (0.0f)));
    float _S480 = _S474 + _S476 + _S479 + toon_component_0;
    float _S481 = (F32_min((sheen_component_0), (1.0f)));
    bool _S482 = sheen_component_0 > 0.0f;
    if(_S482)
    {
        _S448 = !(_S480 > 0.0f);
    }
    else
    {
        _S448 = false;
    }
    float _S483 = _slang_select(_S448, 1.0f,_S481);
    float _S484 = (1.0f - _S483) / (F32_max((_S480), (0.0000152587890625f)));
    float _S485 = _S476 * _S484;
    float _S486 = _S474 * _S484;
    float _S487 = _S479 * _S484;
    bool _S488 = (frame_2.alphas.x) > 0.0f;
    float visible_1;
    if(_S488)
    {
        float3  _S489 = anisotropicLocal(v_4, frame_2.tangent, n_i_3);
        float _S490 = anisotropicG1(_S489, frame_2.alphas);
        float3  _S491 = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        float _S492 = anisotropicD(_S491, frame_2.alphas);
        float _S493 = _S490 * _S492;
        visible_1 = _S493;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S420, _S421, _S424, F_1, _S469, 1.0f, _S472, _S473, _S485, _S486, _S487, 0.0f, sheen_1, _S483, view_1, frame_2.tangent, frame_2.alphas, visible_1, toon_component_0 * _S484, toon_1, toon_a_1, toon_s_1, toon_b_1, _S445, toon_norm_1, toon_view_1, toon_axis_1);
}

__device__ float translucentShare(BSDFMaterial material_4)
{
    float _S494 = rgb_to_greyscale(material_4.translucent);
    float _S495 = rgb_to_greyscale(material_4.albedo);
    float _S496 = _S494 / (_S495 + _S494);
    bool _S497 = _S494 > 0.0f;
    float _S498 = _slang_select(_S497, _S496,0.0f);
    return _S498;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_2, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S499 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S500 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S501 = 1.0f - lobes_0.translucent_share;
    bool _S502 = n_i_dot_l_0 < 0.0f;
    float _S503 = _slang_select(_S502, lobes_0.translucent_share,_S501);
    float _S504 = _S500 * _S503;
    bool _S505 = (lobes_0.translucent_share) > 0.0f;
    float _S506 = _slang_select(_S505, _S504,_S499);
    bool _S507 = n_i_dot_v_0 > 0.0f;
    float _S508 = _slang_select(_S507, _S506,0.0f);
    return _S508;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_4, float alpha_3, BSDFMaterial material_5, BSDFLobes lobes_1)
{
    bool _S509 = (dot_0(n_i_4, l_0)) < 0.0f;
    float3  _S510 = _slang_select(_S509, material_5.translucent,material_5.albedo);
    float _S511 = 1.0f - lobes_1.translucent_share;
    float _S512 = _slang_select(_S509, lobes_1.translucent_share,_S511);
    float3  _S513 = _S510 / make_float3 (_S512);
    bool _S514 = (lobes_1.translucent_share) > 0.0f;
    float3  _S515 = _slang_select(_S514, _S513,material_5.albedo);
    return lobes_1.diffuse_weight * _S515 / make_float3 (lobes_1.p_diffuse);
}

__device__ float smithG1(float alpha_4, float n_dot_x_0)
{
    float _S516 = alpha_4 * alpha_4;
    float _S517 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S516 + (1.0f - _S516) * n_dot_x_0 * n_dot_x_0))));
    bool _S518 = alpha_4 > 0.0f;
    float _S519 = _slang_select(_S518, _S517,1.0f);
    return _S519;
}

__device__ float trowbridgeReitz(float alpha_5, float n_dot_h_1)
{
    float _S520 = alpha_5 * alpha_5;
    float _S521 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S520 * n_dot_h_1 * n_dot_h_1;
    return _S520 / (F32_max((3.14159274101257324f * _S521 * _S521), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S522 = smithG1(alpha_6, n_i_dot_v_1);
    float _S523 = _S522 * lobes_2.v_dot_h;
    float _S524 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S525 = _S523 * _S524 / n_i_dot_v_1;
    bool _S526 = alpha_6 > 0.0f;
    bool _S527;
    if(_S526)
    {
        _S527 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S527 = false;
    }
    if(_S527)
    {
        _S527 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S527 = false;
    }
    if(_S527)
    {
        _S527 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S527 = false;
    }
    float _S528 = _slang_select(_S527, _S525,0.0f);
    bool _S529 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S529)
    {
        float _S530 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S531 = (lobes_2.v_dot_h) > 0.0f;
        if(_S531)
        {
            _S527 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S527 = false;
        }
        if(_S527)
        {
            _S527 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S527 = false;
        }
        float _S532 = _slang_select(_S527, _S530,0.0f);
        pdf_h_0 = _S532;
    }
    else
    {
        pdf_h_0 = _S528;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S533 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S534 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S535 = lobes_3.p_refract * _S533 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S534 * _S534);
    bool _S536 = eta_i_4 != eta_o_4;
    bool _S537;
    if(_S536)
    {
        _S537 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S537 = false;
    }
    float _S538 = _slang_select(_S537, _S535,0.0f);
    return _S538;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_5, float alpha_8, BSDFMaterial material_6, BSDFLobes lobes_4)
{
    float _S539 = - dot_0(n_i_5, l_1);
    float _S540 = smithG1(alpha_8, (F32_max((_S539), (0.0f))));
    bool _S541 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S541)
    {
        float3  _S542 = negate_0(n_i_5);
        float3  _S543 = anisotropicLocal(l_1, lobes_4.tangent, _S542);
        float _S544 = anisotropicG1(_S543, lobes_4.alphas);
        G1_l_0 = _S544;
    }
    else
    {
        G1_l_0 = _S540;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_6.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S545 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S546 = n_i_dot_l_2 > 0.0f;
    bool _S547;
    if(_S546)
    {
        _S547 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S547 = false;
    }
    float _S548 = _slang_select(_S547, _S545,0.0f);
    return _S548;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_6, float alpha_10, BSDFMaterial material_7, BSDFLobes lobes_6)
{
    float3  _S549 = l_2 + lobes_6.view;
    float3  _S550 = ((((_S549)) * make_float3(rnorm3df(((_S549)).x, ((_S549)).y, ((_S549)).z))));
    float _S551 = dot_0(n_i_6, _S550);
    float _S552 = (F32_max((dot_0(n_i_6, l_2)), (0.0f)));
    float _S553 = (F32_max((dot_0(n_i_6, lobes_6.view)), (0.0f)));
    float _S554 = 1.0f / (F32_max((material_7.sheen_roughness), (0.05000000074505806f)));
    float _S555 = 1.0f - _S551 * _S551;
    float _S556 = (2.0f + _S554) * (F32_pow(((F32_max((_S555), (0.0f)))), (0.5f * _S554))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S552 + _S553 - _S552 * _S553)), (0.0000152587890625f)));
    bool _S557 = (material_7.velvet) > 0.0f;
    float f_1;
    if(_S557)
    {
        float _S558 = (F32_max((material_7.sheen_roughness), (0.00999999977648258f)));
        float _S559 = _S558 * _S558;
        float _S560 = (F32_max((_S555), (0.0000152587890625f)));
        float _S561 = (F32_exp((- _S551 * _S551 / (_S560 * _S559)))) / (3.14159274101257324f * _S559 * _S560 * _S560) * (F32_min((1.0f), (2.0f * _S551 * (F32_min((_S552), (_S553))) / (F32_max(((F32_abs((dot_0(_S550, lobes_6.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S552 * _S553), (0.0000152587890625f)));
        f_1 = _S561;
    }
    else
    {
        f_1 = _S556;
    }
    return lobes_6.sheen * make_float3 (f_1 * _S552 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float toonPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, BSDFLobes lobes_7, float eta_i_6, float eta_o_6)
{
    float _S562 = _slang_select(lobes_7.toon_glossy, l_dot_h_3,n_i_dot_l_3);
    float _S563 = (F32_acos((clamp_1(_S562, -1.0f, 1.0f))));
    float _S564;
    if(_S563 < (lobes_7.toon_a))
    {
        _S564 = 1.0f;
    }
    else
    {
        _S564 = (F32_max((1.0f - (_S563 - lobes_7.toon_a) / (F32_max((lobes_7.toon_s), (0.0000152587890625f)))), (0.0f)));
    }
    float _S565 = lobes_7.p_toon * _S564;
    float _S566 = _slang_select(lobes_7.toon_glossy, 1.0f,n_i_dot_l_3);
    float _S567 = _S565 * _S566 / lobes_7.toon_norm;
    bool _S568;
    if(lobes_7.toon_glossy)
    {
        _S568 = true;
    }
    else
    {
        _S568 = n_i_dot_l_3 > 0.0f;
    }
    float _S569 = _slang_select(_S568, _S567,0.0f);
    return _S569;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_3, float3  n_i_7, float alpha_12, BSDFMaterial material_8, BSDFLobes lobes_8)
{
    float _S570 = (F32_max((dot_0(n_i_7, l_3)), (0.0f)));
    float _S571 = _slang_select(lobes_8.toon_glossy, _S570,lobes_8.toon_view);
    return lobes_8.toon * make_float3 (_S571) / make_float3 (lobes_8.p_toon);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_4, float l_dot_h_4, float n_i_dot_v_5, float alpha_13, BSDFLobes lobes_9, float eta_i_7, float eta_o_7)
{
    float _S572 = vndfPDF(n_i_dot_v_5, alpha_13, lobes_9);
    float _S573 = lobes_9.p_reflect * _S572 / (4.0f * lobes_9.v_dot_h);
    bool _S574 = _S572 > 0.0f;
    float _S575 = _slang_select(_S574, _S573,0.0f);
    return _S575;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_4, float3  n_i_8, float alpha_14, BSDFMaterial material_9, BSDFLobes lobes_10)
{
    float _S576 = dot_0(n_i_8, l_4);
    float _S577 = smithG1(alpha_14, (F32_max((_S576), (0.0f))));
    bool _S578 = (lobes_10.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S578)
    {
        float3  _S579 = anisotropicLocal(l_4, lobes_10.tangent, n_i_8);
        float _S580 = anisotropicG1(_S579, lobes_10.alphas);
        G1_l_1 = _S580;
    }
    else
    {
        G1_l_1 = _S577;
    }
    return make_float3 (lobes_10.reflect_weight * G1_l_1) * lobes_10.F / make_float3 (lobes_10.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_10, float eta_i_8, float eta_o_8, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S581 = negate_0(in_dir_4);
    float _S582 = dot_0(n_7, _S581);
    float _S583 = sign_0(_S582);
    float3  _S584 = n_7 * make_float3 (_S583);
    AnisotropicFrame _S585 = anisotropicFrame(material_10, _S584);
    float _S586 = dot_0(_S584, out_dir_2);
    float _S587 = material_10.roughness;
    float _S588 = _S587 * _S587;
    SheenProfile _S589 = sheenProfile(_S581, _S584, material_10);
    float _S590 = rgb_to_greyscale(material_10.translucent);
    bool _S591 = _S590 > 0.0f;
    bool _S592 = (dot_0(n_7, out_dir_2) * _S582) < 0.0f;
    uint _S593;
    if((F32_abs((material_10.toon.x))) > 0.0f)
    {
        _S593 = 5U;
    }
    else
    {
        _S593 = 4U;
    }
    uint i_6 = 0U;
    for(;;)
    {
        if(i_6 < 5U)
        {
        }
        else
        {
            break;
        }
        float3  _S594 = make_float3 (0.0f);
        (*throughputs_0)[i_6] = _S594;
        (*pdfs_0)[i_6] = 0.0f;
        uint i_7 = i_6 + 1U;
        i_6 = i_7;
    }
    float3  _S595 = make_float3 (0.0f);
    BSDFLobes _S596 = BSDFLobes_x24init_0(0.0f, 0.0f, _S595, _S595, 0.0f, 0.0f, _S595, _S595, 0.0f, 0.0f, 0.0f, 0.0f, _S595, 0.0f, _S595, _S595, make_float2 (0.0f), 0.0f, 0.0f, _S595, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S595);
    BSDFLobes lobe_terms_0 = _S596;
    uint half_of_0 = 4294967295U;
    float3  ggx_n_2 = _S595;
    i_6 = 0U;
    for(;;)
    {
        if(i_6 < _S593)
        {
        }
        else
        {
            break;
        }
        uint _S597;
        if(i_6 == 3U)
        {
            _S597 = 4U;
        }
        else
        {
            if(i_6 == 4U)
            {
                _S597 = 6U;
            }
            else
            {
                _S597 = i_6;
            }
        }
        bool _S598 = _S597 == 0U;
        bool _S599;
        if(_S598)
        {
            _S599 = _S591;
        }
        else
        {
            _S599 = false;
        }
        bool _S600;
        if(_S599)
        {
            _S600 = _S592;
        }
        else
        {
            _S600 = _S597 == 1U;
        }
        bool _S601 = _S600 != refracted_2;
        if(_S601)
        {
            ggx_n_1 = ggx_n_2;
            uint i_8 = i_6 + 1U;
            ggx_n_2 = ggx_n_1;
            i_6 = i_8;
            continue;
        }
        uint _S602;
        if(_S597 == 6U)
        {
            _S602 = 0U;
        }
        else
        {
            if(_S597 == 4U)
            {
                _S602 = 2U;
            }
            else
            {
                _S602 = _S597;
            }
        }
        bool _S603 = _S602 != half_of_0;
        uint half_of_1;
        if(_S603)
        {
            bool _S604 = _S602 == 0U;
            if(_S604)
            {
                float3  _S605 = sampledHalf(in_dir_4, n_7, material_10, random_state_4, _S585);
                ggx_n_1 = _S605;
            }
            else
            {
                bool _S606 = _S602 == 1U;
                if(_S606)
                {
                    float3  _S607 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_8, eta_o_8);
                    ggx_n_1 = _S607;
                }
                else
                {
                    float3  _S608 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S608;
                }
            }
            float3  _S609 = negate_0(in_dir_4);
            BSDFLobes _S610 = bsdfLobes(in_dir_4, _S609, _S584, ggx_n_1, material_10, eta_i_8, eta_o_8, _S585, _S589);
            lobe_terms_0 = _S610;
            float _S611 = translucentShare(material_10);
            (&lobe_terms_0)->translucent_share = _S611;
            half_of_1 = _S602;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S597)
        {
        case 0U:
            {
                float _S612 = diffusePDF(_S586, 0.0f, (F32_abs((_S582))), _S588, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(0)] = _S612;
                float3  _S613 = diffuseBSDF(out_dir_2, _S584, _S588, material_10, lobe_terms_0);
                (*throughputs_0)[int(0)] = _S613;
                break;
            }
        case 1U:
            {
                float _S614 = refractPDF(_S586, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S582))), _S588, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(1)] = _S614;
                float3  _S615 = refractBSDF(out_dir_2, _S584, _S588, material_10, lobe_terms_0);
                (*throughputs_0)[int(1)] = _S615;
                break;
            }
        case 4U:
            {
                float _S616 = sheenVelvetPDF(_S586, 0.0f, (F32_abs((_S582))), _S588, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(3)] = _S616;
                float3  _S617 = sheenVelvetBSDF(out_dir_2, _S584, _S588, material_10, lobe_terms_0);
                (*throughputs_0)[int(3)] = _S617;
                break;
            }
        case 6U:
            {
                float _S618 = toonPDF(_S586, dot_0(out_dir_2, (&lobe_terms_0)->toon_axis), (F32_abs((_S582))), _S588, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(4)] = _S618;
                float3  _S619 = toonBSDF(out_dir_2, _S584, _S588, material_10, lobe_terms_0);
                (*throughputs_0)[int(4)] = _S619;
                break;
            }
        default:
            {
                float _S620 = reflectPDF(_S586, 0.0f, (F32_abs((_S582))), _S588, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(2)] = _S620;
                float3  _S621 = reflectBSDF(out_dir_2, _S584, _S588, material_10, lobe_terms_0);
                (*throughputs_0)[int(2)] = _S621;
                break;
            }
        }
        half_of_0 = half_of_1;
        uint i_8 = i_6 + 1U;
        ggx_n_2 = ggx_n_1;
        i_6 = i_8;
    }
    i_6 = 0U;
    ggx_n_1 = _S595;
    for(;;)
    {
        if(i_6 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S622 = ((*pdfs_0)[i_6]) > 0.0f;
        if(_S622)
        {
            float3  f_2 = ggx_n_1 + (*throughputs_0)[i_6] * make_float3 ((*pdfs_0)[i_6]);
            ggx_n_1 = f_2;
        }
        uint i_9 = i_6 + 1U;
        i_6 = i_9;
    }
    return ggx_n_1;
}

static __device__ __forceinline__ float3  skyLobes_0(float3  in_dir_5, float3  dir_3, FKSurface * surface_1, float2  eta_1, bool is_inside_2, float pdf_0, uint random_state_5, FixedArray<float3 , 5>  * terms_0, FixedArray<float, 5>  * pdfs_1)
{
    bool _S623 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    float3  _S624 = BSDF(in_dir_5, dir_3, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S623, random_state_5, terms_0, pdfs_1);
    float3  _S625 = make_float3 (0.0f);
    uint i_10 = 0U;
    float3  f_3 = _S625;
    for(;;)
    {
        if(i_10 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S626 = ((*pdfs_1)[i_10]) > 0.0f;
        if(_S626)
        {
            float3  _S627 = (*terms_0)[i_10] * make_float3 ((*pdfs_1)[i_10]) / make_float3 ((*pdfs_1)[i_10] + pdf_0);
            (*terms_0)[i_10] = _S627;
            float3  f_4 = f_3 + (*terms_0)[i_10];
            f_3 = f_4;
        }
        uint i_11 = i_10 + 1U;
        i_10 = i_11;
    }
    return f_3;
}

__device__ float3  skyBSDF(float3  in_dir_6, float3  dir_4, FKSurface surface_2, float2  eta_2, bool is_inside_3, float pdf_1, uint random_state_6)
{
    FKSurface _S628 = surface_2;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S629 = skyLobes_0(in_dir_6, dir_4, &_S628, eta_2, is_inside_3, pdf_1, random_state_6, &terms_1, &pdfs_2);
    return _S629;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S630;
    (&_S630)->dir = dir_5;
    (&_S630)->radiance = radiance_0;
    (&_S630)->color = color_0;
    (&_S630)->random_state = random_state_7;
    return _S630;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S631 = (fcptEnvironmentCdfSize());
    uint2  _S632 = make_uint2 (1U, 0U);
    uint2  _S633 = _S631 - _S632;
    Random _S634 = pcg(init_random_state_0);
    Random _S635 = pcg(_S634.state);
    Random _S636 = pcg(_S635.state);
    Random _S637 = pcg(_S636.state);
    uint _S638 = _S633.x;
    uint _S639 = searchCDF_0(make_uint2 (_S638, 0U), make_uint2 (0U, 1U), _S633.y, _S634.value);
    uint _S640 = searchCDF_0(make_uint2 (0U, _S639), _S632, _S638, _S635.value);
    float2  _S641 = make_float2 ((float)_S633.x, (float)_S633.y);
    float2  _S642 = (make_float2 (float(_S640), float(_S639)) + make_float2 (_S636.value, _S637.value)) / _S641 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S643 = _S642.y;
    float _S644 = (F32_sin((_S643)));
    float _S645 = _S642.x;
    float3  _S646 = make_float3 (- _S644 * (F32_cos((_S645))), _S644 * (F32_sin((_S645))), (F32_cos((_S643))));
    float _S647 = environmentPdf_0(_S646);
    float3  _S648 = skyBSDF(ray_0->unit_direction, _S646, *surface_3, eta_3, is_inside_4, _S647, lobe_state_0);
    bool _S649 = !(_S647 > 0.0f);
    bool _S650;
    if(_S649)
    {
        _S650 = true;
    }
    else
    {
        _S650 = all_1(_S648 == make_float3 (0.0f));
    }
    if(_S650)
    {
        float3  _S651 = make_float3 (0.0f);
        return SkySample_x24init_0(_S646, _S651, _S651, _S637.state);
    }
    float3  _S652 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S646, context_2, _S637.state);
    return SkySample_x24init_0(_S646, _S652, _S648 * _S652, _S637.state);
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
    SampleBSDF _S653 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S654 = _S653.throughput * make_float3 (_S653.pdf);
    float _S655 = light_1->density;
    float _S656 = 1.0f + _S653.pdf * _S653.pdf / (light_1->density * light_1->density);
    bool _S657;
    if(competing_0)
    {
        _S657 = _S655 > 0.0f;
    }
    else
    {
        _S657 = false;
    }
    float _S658 = _slang_select(_S657, _S656,1.0f);
    return _S654 / make_float3 (_S658) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S659;
    (&_S659)->dir = dir_6;
    (&_S659)->radiance = radiance_1;
    (&_S659)->density = density_0;
    (&_S659)->random_state = random_state_8;
    return _S659;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_10, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S660 = importance(first_1, p_10, normal_3);
    float _S661 = importance(second_1, p_10, normal_3);
    float2  _S662 = make_float2 (_S660, _S661);
    bool _S663 = _S660 == 0.0f;
    bool _S664;
    if(_S663)
    {
        _S664 = _S661 == 0.0f;
    }
    else
    {
        _S664 = false;
    }
    if(_S664)
    {
        return 2U;
    }
    float _S665 = _S660 + _S661;
    bool _S666 = _S661 > 0.0f;
    if(_S666)
    {
        _S664 = (*pick_0 * _S665) >= _S660;
    }
    else
    {
        _S664 = false;
    }
    uint _S667 = uint(_S664);
    float _S668 = (F32_min(((*pick_0 * _S665 - float(_S667) * _S660) / _slang_vector_get_element(_S662, _S667)), (0.99999994039535522f)));
    *pick_0 = _S668;
    float _S669 = *probability_3 * (_slang_vector_get_element(_S662, _S667) / _S665);
    *probability_3 = _S669;
    return _S667;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_11, float u1_0, float u2_0)
{
    float3  _S670 = center_1 - p_11;
    float _S671 = radius_1 * radius_1 / dot_0(_S670, _S670);
    float _S672 = u1_0 * _S671 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S671), (0.0f)))))));
    float _S673 = 2.0f * u1_0;
    bool _S674 = _S671 >= 1.0f;
    float _S675 = _slang_select(_S674, _S673,_S672);
    float _S676 = (F32_sqrt(((F32_max((_S675 * (2.0f - _S675)), (0.0f))))));
    float _S677 = 6.28318548202514648f * u2_0;
    float3  _S678 = make_float3 (_S676 * (F32_cos((_S677))), 1.0f - _S675, _S676 * (F32_sin((_S677))));
    float3  _S679 = ((((_S670)) * make_float3(rnorm3df(((_S670)).x, ((_S670)).y, ((_S670)).z))));
    float3  _S680 = tangentToWorld(_S678, _S679);
    return _S680;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S681 = center_2 - ray_1->origin;
    float _S682 = dot_0(_S681, ray_1->unit_direction);
    float _S683 = dot_0(_S681, _S681) - _S682 * _S682;
    float _S684 = radius_3 * radius_3;
    bool _S685 = _S683 > _S684;
    if(_S685)
    {
        return 4.294967296e+09f;
    }
    float _S686 = (F32_sqrt((_S684 - _S683)));
    float _S687 = _S682 - _S686;
    float _S688 = _S682 + _S686;
    bool _S689 = _S687 > 0.0000152587890625f;
    bool _S690;
    if(_S689)
    {
        _S690 = _S687 < max_len_0;
    }
    else
    {
        _S690 = false;
    }
    if(_S690)
    {
        return _S687;
    }
    bool _S691 = _S688 > 0.0000152587890625f;
    if(_S691)
    {
        _S690 = _S688 < max_len_0;
    }
    else
    {
        _S690 = false;
    }
    if(_S690)
    {
        return _S688;
    }
    return 4.294967296e+09f;
}

static __device__ float3  mul_0(float3  left_1, Matrix<float, 3, 3>  right_1)
{
    float3  result_5;
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
        int i_12 = int(0);
        float sum_0 = 0.0f;
        for(;;)
        {
            if(i_12 < int(3))
            {
            }
            else
            {
                break;
            }
            float sum_1 = sum_0 + _slang_vector_get_element(left_1, i_12) * _slang_vector_get_element(right_1.rows[i_12], j_1);
            i_12 = i_12 + int(1);
            sum_0 = sum_1;
        }
        *_slang_vector_get_element_ptr(&result_5, j_1) = sum_0;
        j_1 = j_1 + int(1);
    }
    return result_5;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S692 = pcg(init_random_state_1);
    Random _S693 = pcg(_S692.state);
    Random _S694 = pcg(_S693.state);
    float3  _S695 = make_float3 (0.0f);
    TreeSample _S696 = TreeSample_x24init_0(_S695, _S695, 0.0f, _S694.state);
    TreeSample sample_0 = _S696;
    float3  _S697 = _slang_select(sided_0, _S695,smooth_n_2);
    float3  _S698 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S692.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S699 = (fcptLightNode((n_8)));
        if((_S699.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S700 = (fcptLightSecond((n_8)));
        uint _S701 = n_8 + 1U;
        LightNode _S702 = (fcptLightBounds((_S701)));
        LightNode _S703 = (fcptLightBounds((_S700)));
        uint _S704 = pickChild(_S702, _S703, origin_4, _S697, &pick_1, &probability_4);
        bool _S705 = _S704 > 1U;
        if(_S705)
        {
            return sample_0;
        }
        bool _S706 = _S704 == 1U;
        uint _S707 = _slang_select(_S706, _S700,_S701);
        n_8 = _S707;
    }
    bool _S708 = n_8 == 0U;
    bool _S709;
    if(_S708)
    {
        LightNode _S710 = (fcptLightBounds((0U)));
        float _S711 = importance(_S710, origin_4, _S697);
        _S709 = !(_S711 > 0.0f);
    }
    else
    {
        _S709 = false;
    }
    if(_S709)
    {
        return sample_0;
    }
    uint4  _S712 = (fcptLightNode((n_8)));
    FKHit _S713 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S714 = (_S712.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S714)
    {
        FKLight _S715 = (fcptLight((_S712.y)));
        if(sided_0)
        {
            float _S716 = sign_0(dot_0(geometry_n_1, _S715.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S716);
            float3  _S717 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S717;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S698;
            lift_n_0 = smooth_n_2;
        }
        bool _S718 = (_S715.variance) == 0.0f;
        if(_S718)
        {
            float3  _S719 = _S715.position - emitter_point_0;
            float3  _S720 = ((((_S719)) * make_float3(rnorm3df(((_S719)).x, ((_S719)).y, ((_S719)).z))));
            (&sample_0)->dir = _S720;
            float3  _S721 = _S715.color * make_float3 (_S715.intensity) / make_float3 (dot_0(_S719, _S719) * probability_4);
            (&sample_0)->radiance = _S721;
            shadow_1 = _S719;
        }
        else
        {
            float3  _S722 = sampleSphere(_S715.position, _S715.variance, emitter_point_0, _S693.value, _S694.value);
            (&sample_0)->dir = _S722;
            float _S723 = sphereDensity(_S715.position, _S715.variance, emitter_point_0);
            float _S724 = probability_4 * _S723;
            (&sample_0)->density = _S724;
            float3  _S725 = pointLightRadiance(_S715.color, _S715.intensity, _S715.variance);
            float3  _S726 = _S725 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S726;
            FKRay _S727 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S728 = raySphere_0(_S715.position, _S715.variance, &_S727, 4.294967296e+09f);
            float3  _S729 = (&sample_0)->dir * make_float3 (_S728);
            shadow_1 = _S729;
        }
        emitter_0 = _S713;
        emitter_point_0 = _S695;
    }
    else
    {
        uint _S730 = _S712.y;
        uint _S731 = (fcptTriangleOffset((_S730)));
        uint _S732 = _S731 + _S712.z;
        Matrix<float, 3, 3>  _S733 = (fcptWorldTriangle((_S730), (_S732)));
        float _S734 = (F32_sqrt((_S693.value)));
        float2  _S735 = make_float2 (_S734 * (1.0f - _S694.value), _S734 * _S694.value);
        float3  _S736 = mul_0(make_float3 (1.0f - _S734, _S735.x, _S735.y), _S733);
        if(sided_0)
        {
            float _S737 = sign_0(dot_0(geometry_n_1, _S736 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S737);
            float3  _S738 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S738;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S739 = !((dot_0(smooth_n_2, _S736 - origin_4)) > 0.0f);
            if(_S739)
            {
                return sample_0;
            }
            emitter_point_0 = _S698;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S735, _S730, _S732, 0U, 0.0f);
        float3  _S740 = _S736 - emitter_point_0;
        float3  _S741 = ((((_S740)) * make_float3(rnorm3df(((_S740)).x, ((_S740)).y, ((_S740)).z))));
        (&sample_0)->dir = _S741;
        float _S742 = solidAngle(probability_4, cross_0(_S733.rows[int(1)] - _S733.rows[int(0)], _S733.rows[int(2)] - _S733.rows[int(0)]), _S740);
        (&sample_0)->density = _S742;
        bool _S743 = (fcptShadowFirst());
        bool _S744 = !_S743;
        if(_S744)
        {
            FKSurface _S745 = (fcptLightSurfaceAt((emitter_1), (_S736), (_S694.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S736 - origin_4))));
            (&sample_0)->random_state = _S745.random_state;
            float3  _S746 = _slang_select(_S745.skip, _S695,_S745.material.emissive);
            float3  _S747 = _S746 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S747;
        }
        shadow_1 = _S740;
        emitter_0 = emitter_1;
        emitter_point_0 = _S736;
    }
    FKHit _S748 = emitter_0;
    float3  _S749 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S694.state, &_S748);
    bool _S750 = (fcptShadowFirst());
    if(_S750)
    {
        _S709 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S709 = false;
    }
    if(_S709)
    {
        _S709 = !all_1(_S749 == _S695);
    }
    else
    {
        _S709 = false;
    }
    if(_S709)
    {
        FKSurface _S751 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S694.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S751.random_state;
        float3  _S752 = _slang_select(_S751.skip, _S695,_S751.material.emissive);
        float3  _S753 = _S752 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S753;
    }
    float3  _S754 = (&sample_0)->radiance * _S749;
    bool _S755 = all_1(_S749 == _S695);
    float3  _S756 = _slang_select(_S755, _S695,_S754);
    (&sample_0)->radiance = _S756;
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

__device__ float powerHeuristic(float a_5, float b_1)
{
    float _S757 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    bool _S758 = b_1 > 0.0f;
    float _S759 = _slang_select(_S758, _S757,1.0f);
    return _S759;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S760 = vertex_0->none;
    if(_S760)
    {
        return 1.0f;
    }
    uint _S761 = (fcptLightSlot((*hit_1)));
    float _S762 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S761, light_point_1);
    float _S763 = powerHeuristic(vertex_0->pdf, _S762);
    return _S763;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_0)
{
    uint2  _S764 = (fcptEnvironmentMapSize());
    bool _S765 = all_0(_S764 > make_uint2 (1U));
    if(_S765)
    {
        float3  _S766 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_0)));
        return _S766;
    }
    float3  _S767 = (fcptAmbient());
    return _S767;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S768 = (fcptEnvironmentCdfSize());
    bool _S769 = !all_0(_S768 > make_uint2 (1U));
    if(_S769)
    {
        return false;
    }
    uint2  _S770 = (fcptEnvironmentMapSize());
    return all_0(_S770 > make_uint2 (1U));
}

static __device__ float escapeWeight_0(float pdf_2, float3  dir_8)
{
    bool _S771 = pdf_2 <= 0.0f;
    bool _S772;
    if(_S771)
    {
        _S772 = true;
    }
    else
    {
        bool _S773 = environmentMapped_0();
        _S772 = !_S773;
    }
    if(_S772)
    {
        return 1.0f;
    }
    float _S774 = environmentPdf_0(dir_8);
    return pdf_2 / (pdf_2 + _S774);
}

static __device__ float3  min_1(float3  x_15, float3  y_4)
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
        *_slang_vector_get_element_ptr(&result_6, i_13) = (F32_min((_slang_vector_get_element(x_15, i_13)), (_slang_vector_get_element(y_4, i_13))));
        i_13 = i_13 + int(1);
    }
    return result_6;
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S775 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S776 = make_int2 ((int)_S775.x, (int)_S775.y);
    uint _S777 = previousSeed_0(_S776);
    int y_5 = int(-8);
    uint count_2 = 0U;
    for(;;)
    {
        if(y_5 <= int(8))
        {
        }
        else
        {
            break;
        }
        int x_16 = int(-8);
        for(;;)
        {
            if(x_16 <= int(8))
            {
            }
            else
            {
                break;
            }
            uint _S778 = previousSeed_0(_S776 + make_int2 (x_16, y_5));
            bool _S779 = _S778 == _S777;
            uint _S780 = _slang_select(_S779, 1U,0U);
            uint count_3 = count_2 + _S780;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S781 = float(count_2 - 1U) / 288.0f;
    bool _S782 = _S777 != 0U;
    float _S783 = _slang_select(_S782, _S781,0.0f);
    fcptStoreDuplication((_S776), (make_uint4 ((F32_asuint((_S783))), 0U, 0U, 0U)));
    return;
}

__device__ uint stream(uint seed_2, uint index_0)
{
    uint _S784 = hash(index_0);
    uint _S785 = hash(seed_2 ^ _S784);
    return _S785;
}

static __device__ float4  asfloat_0(uint4  x_18)
{
    float4  result_7;
    int i_14 = int(0);
    for(;;)
    {
        if(i_14 < int(4))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_7, i_14) = (U32_asfloat((_slang_vector_get_element(x_18, i_14))));
        i_14 = i_14 + int(1);
    }
    return result_7;
}

__device__ void offer(Selection * sel_2, Reservoir candidate_0, float3  weight_0)
{
    float _S786 = rgb_to_greyscale(weight_0);
    bool _S787 = _S786 > 0.0f;
    bool _S788;
    if(_S787)
    {
        _S788 = _S786 < 3.00000000549775576e+38f;
    }
    else
    {
        _S788 = false;
    }
    bool _S789 = !_S788;
    if(_S789)
    {
        return;
    }
    bool _S790 = sel_2->sums;
    if(_S790)
    {
        float3  _S791 = sel_2->color + weight_0;
        sel_2->color = _S791;
        return;
    }
    float _S792 = sel_2->w_sum + _S786;
    sel_2->w_sum = _S792;
    float3  _S793 = sel_2->color + weight_0;
    sel_2->color = _S793;
    Random _S794 = pcg(sel_2->random_state);
    sel_2->random_state = _S794.state;
    bool _S795 = (_S794.value * sel_2->w_sum) <= _S786;
    if(_S795)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S796 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S796;
    float _S797 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S797;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S798 = rgb_to_greyscale((&r_4)->f);
    float _S799 = sel_4.w_sum / _S798;
    bool _S800 = _S798 > 0.0f;
    float _S801 = _slang_select(_S800, _S799,0.0f);
    (&r_4)->w = _S801;
    (&r_4)->c = c_1;
    return r_4;
}

static __device__ uint2  asuint_0(float2  x_19)
{
    uint2  result_8;
    int i_15 = int(0);
    for(;;)
    {
        if(i_15 < int(2))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_8, i_15) = (F32_asuint((_slang_vector_get_element(x_19, i_15))));
        i_15 = i_15 + int(1);
    }
    return result_8;
}

static __device__ void restir_spatial_0(uint3  global_invocation_id_2)
{
    uint2  _S802 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S803 = make_int2 ((int)_S802.x, (int)_S802.y);
    float3  _S804 = make_float3 (0.0f);
    FKHit _S805 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S806 = Domain_x24init_0(_S804, _S804, &_S805, 0.0f, 0.0f);
    Domain dom_4 = _S806;
    bool _S807 = (fcptCurrentDomain((_S803), (&dom_4)));
    bool _S808 = !_S807;
    if(_S808)
    {
        Reservoir _S809 = (Reservoir{});
        fcptStoreReservoirPrevious((_S803), (_S809), ((&dom_4)->hit));
        return;
    }
    Reservoir _S810 = (fcptLoadReservoirTemporal((_S803)));
    uint t_13 = 0U;
    float count_4 = 0.0f;
    float c_sum_0 = _S810.c;
    for(;;)
    {
        uint _S811 = (fcptRestirNeighbours());
        if(t_13 < _S811)
        {
        }
        else
        {
            break;
        }
        int2  _S812 = partner_0(_S803, t_13);
        Domain neighbor_0 = _S806;
        bool _S813 = (fcptCurrentDomain((_S812), (&neighbor_0)));
        if(_S813)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S814 = (fcptReservoirTemporal((_S812), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S814.w)));
            count_4 = count_5;
            c_sum_0 = c_sum_1;
        }
        uint t_14 = t_13 + 1U;
        t_13 = t_14;
    }
    float _S815 = _S810.c / (F32_max((count_4), (1.0f)));
    float _S816 = rgb_to_greyscale(_S810.f);
    bool _S817 = count_4 == 0.0f;
    float _S818 = _slang_select(_S817, 1.0f,0.0f);
    Selection _S819 = (Selection{});
    Selection sel_5 = _S819;
    uint _S820 = (fcptFrame());
    uint _S821 = hash(_S820);
    uint _S822 = global_invocation_id_2.x;
    uint2  _S823 = (fcptRenderSize());
    uint _S824 = stream(_S821, _S822 + _S823.x * global_invocation_id_2.y);
    uint _S825 = stream(_S824, 195U);
    (&sel_5)->random_state = _S825;
    t_13 = 0U;
    float canonical_mis_0 = _S818;
    for(;;)
    {
        uint _S826 = (fcptRestirNeighbours());
        if(t_13 < _S826)
        {
        }
        else
        {
            break;
        }
        int2  _S827 = partner_0(_S803, t_13);
        Domain neighbor_dom_0 = _S806;
        bool _S828 = (fcptCurrentDomain((_S827), (&neighbor_dom_0)));
        if(_S828)
        {
            Reservoir _S829 = (fcptLoadReservoirTemporal((_S827)));
            uint4  _S830 = (fcptShiftData((_S827), (t_13)));
            float4  _S831 = asfloat_0(_S830);
            uint4  _S832 = (fcptShiftData((_S803), (t_13)));
            float4  _S833 = asfloat_0(_S832);
            float _S834 = (_S829.c + _S815) / c_sum_0;
            bool _S835 = _S816 > 0.0f;
            float canonical_mis_1;
            if(_S835)
            {
                float _S836 = _S834 * _S815 * _S816;
                float _S837 = _S815 * _S816;
                float _S838 = rgb_to_greyscale(float3 {_S833.x, _S833.y, _S833.z});
                float canonical_mis_2 = canonical_mis_0 + _S836 / (_S837 + _S829.c * _S838);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S839 = rgb_to_greyscale(_S829.f);
            float3  _S840 = float3 {_S831.x, _S831.y, _S831.z};
            Shift _S841 = Shift_x24init_0(_S840, _S831.w);
            float _S842 = _S834 * _S829.c * _S839;
            float _S843 = _S829.c * _S839;
            float _S844 = rgb_to_greyscale(_S840);
            offerShifted(&sel_5, _S829, _S841, _S842 / (_S843 + _S815 * _S844));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_15 = t_13 + 1U;
        t_13 = t_15;
    }
    offerShifted(&sel_5, _S810, Shift_x24init_0(_S810.f, 1.0f), canonical_mis_0);
    Reservoir _S845 = finalize(sel_5, c_sum_0);
    fcptStoreReservoirPrevious((_S803), (_S845), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S803), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S803), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
    return;
}

static __device__ uint3  asuint_1(float3  x_20)
{
    uint3  result_9;
    int i_16 = int(0);
    for(;;)
    {
        if(i_16 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_9, i_16) = (F32_asuint((_slang_vector_get_element(x_20, i_16))));
        i_16 = i_16 + int(1);
    }
    return result_9;
}

static __device__ void restir_shift_0(uint3  workgroup_id_1, uint local_invocation_index_4)
{
    uint _S846 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S847 = _S846 != 4294967295U;
    if(_S847)
    {
        uint2  _S848 = make_uint2 (_S846, _S846 >> 14U) & make_uint2 (16383U);
        int2  _S849 = make_int2 ((int)_S848.x, (int)_S848.y);
        ShiftJob _S850 = (ShiftJob{});
        ShiftJob shift_job_0 = _S850;
        Shift _S851 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S852 = _S846 >> 28U;
        bool _S853 = spatialJob_0(_S849, _S852, &shift_job_0, true);
        Shift shifted_1;
        if(_S853)
        {
            Domain _S854 = (&shift_job_0)->dom;
            Reservoir _S855 = (&shift_job_0)->r;
            Shift _S856 = passShift_0(&_S854, &_S855);
            shifted_1 = _S856;
        }
        else
        {
            shifted_1 = _S851;
        }
        fcptStoreShiftData((_S849), (_S852), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S857 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S858 = make_int2 ((int)_S857.x, (int)_S857.y);
    FixedArray<uint, 3>  _S859;
    spatialBins_0(_S858, &_S859);
    FixedArray<uint, 3>  _S860 = _S859;
    uint t_16 = 0U;
    for(;;)
    {
        if(t_16 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S861 = (_S860[t_16]) == 40U;
        if(_S861)
        {
            fcptStoreShiftData((_S858), (t_16), (make_uint4 (0U)));
        }
        uint t_17 = t_16 + 1U;
        t_16 = t_17;
    }
    FixedArray<uint, 3>  _S862 = _S860;
    queueShifts_0(_S858, &_S862, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S863 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S864 = make_int2 ((int)_S863.x, (int)_S863.y);
    FixedArray<uint, 3>  _S865;
    spatialBins_0(_S864, &_S865);
    FixedArray<uint, 3>  _S866 = _S865;
    countShifts_0(&_S866, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S867 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S868 = _S867 != 4294967295U;
    if(_S868)
    {
        uint2  _S869 = make_uint2 (_S867, _S867 >> 14U) & make_uint2 (16383U);
        int2  _S870 = make_int2 ((int)_S869.x, (int)_S869.y);
        ShiftJob _S871 = (ShiftJob{});
        ShiftJob shift_job_1 = _S871;
        Shift _S872 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S873 = _S867 >> 28U;
        bool _S874 = temporalJob_0(_S870, _S873, &shift_job_1, true);
        Shift shifted_2;
        if(_S874)
        {
            if(_S873 == 1U)
            {
                Shift _S875 = (fcptShiftPrevious(((&shift_job_1)->dom), ((&shift_job_1)->r)));
                shifted_2 = _S875;
            }
            else
            {
                Domain _S876 = (&shift_job_1)->dom;
                Reservoir _S877 = (&shift_job_1)->r;
                Shift _S878 = passShift_0(&_S876, &_S877);
                shifted_2 = _S878;
            }
        }
        else
        {
            shifted_2 = _S872;
        }
        fcptStoreTemporalShift((_S870), (_S873), (make_uint4 (asuint_1(shifted_2.f).x, asuint_1(shifted_2.f).y, asuint_1(shifted_2.f).z, (F32_asuint((shifted_2.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S879 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S880 = make_int2 ((int)_S879.x, (int)_S879.y);
    FixedArray<uint, 3>  _S881;
    temporalBins_0(_S880, &_S881);
    FixedArray<uint, 3>  _S882 = _S881;
    uint t_18 = 0U;
    for(;;)
    {
        if(t_18 < 2U)
        {
        }
        else
        {
            break;
        }
        bool _S883 = (_S882[t_18]) == 40U;
        if(_S883)
        {
            fcptStoreTemporalShift((_S880), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S884 = _S882;
    queueShifts_0(_S880, &_S884, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S885 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S886 = make_int2 ((int)_S885.x, (int)_S885.y);
    FixedArray<uint, 3>  _S887;
    temporalBins_0(_S886, &_S887);
    FixedArray<uint, 3>  _S888 = _S887;
    countShifts_0(&_S888, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_6, float b_2, float t_20)
{
    return a_6 + (b_2 - a_6) * t_20;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S889 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S890 = make_int2 ((int)_S889.x, (int)_S889.y);
    float3  _S891 = make_float3 (0.0f);
    FKHit _S892 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S893 = Domain_x24init_0(_S891, _S891, &_S892, 0.0f, 0.0f);
    Domain dom_5 = _S893;
    bool _S894 = (fcptCurrentDomain((_S890), (&dom_5)));
    bool _S895 = !_S894;
    if(_S895)
    {
        Reservoir _S896 = (Reservoir{});
        fcptStoreReservoirTemporal((_S890), (_S896), ((&dom_5)->hit));
        return;
    }
    Reservoir _S897 = (fcptLoadReservoirInitial((_S890)));
    Domain stored_0 = _S893;
    int2  _S898 = make_int2 (int(-1));
    bool _S899 = (fcptStoredDomainInitial((_S890), (_S897.seed), (&stored_0)));
    int2  q_2;
    if(_S899)
    {
        Domain _S900 = stored_0;
        int2  _S901 = temporalNeighbor_0(_S890, &_S900, _S897.seed);
        q_2 = _S901;
    }
    else
    {
        q_2 = _S898;
    }
    bool _S902 = (q_2.x) >= int(0);
    Reservoir r_5;
    if(_S902)
    {
        Reservoir _S903 = (fcptLoadReservoirPrevious((q_2)));
        uint4  _S904 = (fcptDuplication((q_2)));
        float _S905 = (U32_asfloat((_S904.x)));
        uint _S906 = (fcptRestirDecorrelation());
        bool _S907 = _S906 == 1U;
        float _S908 = _slang_select(_S907, _S905,0.0f);
        float _S909 = interpolate_0(20.0f, 1.0f, (F32_pow((_S908), (0.10000000149011612f))));
        float _S910 = (F32_min((_S903.c), (_S909)));
        Domain target_3 = _S893;
        bool _S911 = (_S903.w) > 0.0f;
        bool _S912;
        if(_S911)
        {
            bool _S913 = (fcptStoredDomainInitial((_S890), (_S903.seed), (&target_3)));
            _S912 = _S913;
        }
        else
        {
            _S912 = false;
        }
        if(_S912)
        {
            Domain _S914 = (fcptPreviousDomain((q_2), (_S903.seed)));
            Domain _S915 = _S914;
            Domain _S916 = target_3;
            bool _S917 = temporalIdentity_0(0U, &_S915, &_S916);
            _S912 = _S917;
        }
        else
        {
            _S912 = false;
        }
        float4  _S918;
        if(_S912)
        {
            _S918 = make_float4 (_S903.f.x, _S903.f.y, _S903.f.z, 1.0f);
        }
        else
        {
            uint4  _S919 = (fcptTemporalShift((_S890), (0U)));
            _S918 = asfloat_0(_S919);
        }
        bool _S920 = (_S897.w) > 0.0f;
        if(_S920)
        {
            Domain _S921 = (fcptPreviousDomain((q_2), (_S897.seed)));
            Domain _S922 = _S921;
            Domain _S923 = stored_0;
            bool _S924 = temporalIdentity_0(1U, &_S922, &_S923);
            _S912 = _S924;
        }
        else
        {
            _S912 = false;
        }
        float4  _S925;
        if(_S912)
        {
            _S925 = make_float4 (_S897.f.x, _S897.f.y, _S897.f.z, 1.0f);
        }
        else
        {
            uint4  _S926 = (fcptTemporalShift((_S890), (1U)));
            _S925 = asfloat_0(_S926);
        }
        float _S927 = rgb_to_greyscale(_S897.f);
        float _S928 = rgb_to_greyscale(_S903.f);
        Selection _S929 = (Selection{});
        Selection sel_6 = _S929;
        uint _S930 = (fcptFrame());
        uint _S931 = hash(_S930);
        uint _S932 = global_invocation_id_7.x;
        uint2  _S933 = (fcptRenderSize());
        uint _S934 = stream(_S931, _S932 + _S933.x * global_invocation_id_7.y);
        uint _S935 = stream(_S934, 194U);
        (&sel_6)->random_state = _S935;
        float _S936 = _S897.c * _S927;
        float4  _S937 = _S925;
        float _S938 = rgb_to_greyscale(float3 {_S937.x, _S937.y, _S937.z});
        float _S939 = _S936 / (_S936 + _S910 * _S938);
        float _S940 = _S910 * _S928;
        float4  _S941 = _S918;
        float3  _S942 = float3 {_S941.x, _S941.y, _S941.z};
        float _S943 = rgb_to_greyscale(_S942);
        float _S944 = _S940 / (_S940 + _S897.c * _S943);
        float2  _S945 = make_float2 (_S939, _S944);
        offerShifted(&sel_6, _S897, Shift_x24init_0(_S897.f, 1.0f), _S939);
        offerShifted(&sel_6, _S903, Shift_x24init_0(_S942, _S918.w), _S944);
        Reservoir _S946 = finalize(sel_6, _S897.c + _S910);
        r_5 = _S946;
    }
    else
    {
        r_5 = _S897;
    }
    fcptStoreReservoirTemporal((_S890), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S947 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S948 = make_int2 ((int)_S947.x, (int)_S947.y);
    float3  _S949 = make_float3 (0.0f);
    float2  _S950 = make_float2 (0.0f);
    FKHit _S951 = Hit_x24init_0(_S950, 0U, 0U, 0U, 0.0f);
    Domain _S952 = Domain_x24init_0(_S949, _S949, &_S951, 0.0f, 0.0f);
    Domain dom_6 = _S952;
    bool _S953 = (fcptCurrentDomain((_S948), (&dom_6)));
    bool _S954 = !_S953;
    if(_S954)
    {
        Reservoir _S955 = (Reservoir{});
        fcptStoreReservoirInitial((_S948), (_S955), ((&dom_6)->hit));
        return;
    }
    uint _S956 = (fcptFrame());
    uint _S957 = hash(_S956);
    uint _S958 = global_invocation_id_8.x;
    uint2  _S959 = (fcptRenderSize());
    uint _S960 = stream(_S957, _S958 + _S959.x * global_invocation_id_8.y);
    Selection _S961 = (Selection{});
    Selection initial_0 = _S961;
    uint _S962 = stream(_S960, 193U);
    (&initial_0)->random_state = _S962;
    bool _S963 = (fcptRestirUsed());
    bool _S964 = !_S963;
    (&initial_0)->sums = _S964;
    uint _S965 = stream(_S960, 0U);
    (&(&initial_0)->r)->seed = _S965;
    FKHit _S966 = Hit_x24init_0(_S950, 4294967295U, 0U, 0U, 0.0f);
    uint _S967 = (fcptSamples());
    float _S968 = 1.0f / float(_S967);
    FKHit hit_2 = _S966;
    uint i_17 = 0U;
    for(;;)
    {
        uint _S969 = (fcptSamples());
        if(i_17 < _S969)
        {
        }
        else
        {
            break;
        }
        Reservoir _S970 = (Reservoir{});
        Reservoir r_6 = _S970;
        uint _S971 = stream(_S960, i_17);
        (&r_6)->seed = _S971;
        Domain path_0 = _S952;
        bool _S972 = (fcptStoredDomainInitial((_S948), ((&r_6)->seed), (&path_0)));
        bool _S973 = !_S972;
        if(_S973)
        {
            fcptMissed((_S948), (path_0), (_S968));
            uint i_18 = i_17 + 1U;
            i_17 = i_18;
            continue;
        }
        Domain _S974 = path_0;
        Reservoir _S975 = r_6;
        Shift _S976 = passWalk_0(&_S974, &_S975, false, _S968, &initial_0);
        bool _S977 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S977)
        {
            FKHit _S978 = (&path_0)->hit;
            hit_3 = _S978;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_18 = i_17 + 1U;
        i_17 = i_18;
    }
    float3  _S979 = (&initial_0)->glow;
    float3  _S980 = (&initial_0)->color;
    bool _S981 = (&initial_0)->sums;
    float3  _S982 = _slang_select(_S981, _S980,_S949);
    fcptAddColor((_S948), (make_float4 ((_S979 + _S982).x, (_S979 + _S982).y, (_S979 + _S982).z, 1.0f)));
    Reservoir _S983 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S948), (_S983), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_3, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S984;
    (&_S984)->none = none_0;
    (&_S984)->pdf = pdf_3;
    (&_S984)->origin = origin_5;
    (&_S984)->smooth_n = smooth_n_3;
    (&_S984)->start = start_6;
    return _S984;
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
    Vertex _S985;
    (&_S985)->rough = rough_0;
    (&_S985)->lobe = lobe_1;
    (&_S985)->pdf = pdf_4;
    (&_S985)->cos = cos_0;
    (&_S985)->inside = inside_0;
    return _S985;
}

static __device__ float3  exp_0(float3  x_21)
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
        *_slang_vector_get_element_ptr(&result_10, i_19) = (F32_exp((_slang_vector_get_element(x_21, i_19))));
        i_19 = i_19 + int(1);
    }
    return result_10;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_0, float distance_2, bool scatters_0)
{
    float3  _S986 = exp_0((make_float3 (sigma_0) - extinction_0) * make_float3 (distance_2));
    float3  _S987 = scatter_0 * _S986 / make_float3 (sigma_0);
    float3  _S988 = _slang_select(scatters_0, _S987,_S986);
    return _S988;
}

static __device__ uint arrivalLobe_0(uint b_3, uint prev_lobe_0)
{
    bool _S989 = b_3 > 0U;
    uint _S990 = _slang_select(_S989, prev_lobe_0,3U);
    return _S990;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_5, float length_2, float width_1, FKHit * own_0, bool fiber_0)
{
    ShadowContext _S991;
    (&_S991)->extinction_behind = extinction_behind_0;
    (&_S991)->extinction_front = extinction_front_0;
    (&_S991)->fillings = fillings_0;
    (&_S991)->side = side_0;
    (&_S991)->depth = depth_1;
    (&_S991)->lobe = lobe_2;
    (&_S991)->surface = surface_5;
    (&_S991)->length = length_2;
    (&_S991)->width = width_1;
    (&_S991)->own = *own_0;
    (&_S991)->fiber = fiber_0;
    return _S991;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S992 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S992)
    {
        return 0.07957746833562851f;
    }
    float _S993 = g_0 * g_0;
    return (1.0f - _S993) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S993 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_7, float3  b_4)
{
    float3  _S994 = a_7 / b_4;
    float3  _S995 = make_float3 (0.0f);
    bool3  _S996 = b_4 == _S995;
    float3  _S997 = _slang_select(_S996, _S995,_S994);
    return _S997;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S998 = (1U << count_6) - 1U;
    return (e_2 & (~(_S998 << offset_1))) | ((newbits_0 & _S998) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_2 = r_7;
    uint _S999 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1000 = insertBits_0(_S999, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1000;
    (&candidate_2)->f = f_5;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S1001 = pcg(random_state_9);
    Random _S1002 = pcg(_S1001.state);
    float _S1003 = 1.0f - 2.0f * _S1001.value;
    float _S1004 = (F32_sqrt(((F32_max((1.0f - _S1003 * _S1003), (0.0f))))));
    float _S1005 = 6.28318548202514648f * _S1002.value;
    return make_float3 (_S1004 * (F32_cos((_S1005))), _S1004 * (F32_sin((_S1005))), _S1003);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_10, float * pdf_5)
{
    bool _S1006 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1006)
    {
        *pdf_5 = 0.07957746833562851f;
        float3  _S1007 = isotropic_0(random_state_10);
        return _S1007;
    }
    Random _S1008 = pcg(random_state_10);
    Random _S1009 = pcg(_S1008.state);
    float _S1010 = g_1 * g_1;
    float _S1011 = 2.0f * g_1;
    float _S1012 = (1.0f - _S1010) / (1.0f - g_1 + _S1011 * _S1008.value);
    float _S1013 = clamp_1((1.0f + _S1010 - _S1012 * _S1012) / _S1011, -1.0f, 1.0f);
    float _S1014 = (F32_sqrt(((F32_max((1.0f - _S1013 * _S1013), (0.0f))))));
    float _S1015 = 6.28318548202514648f * _S1009.value;
    float _S1016 = phaseHG_0(g_1, _S1013);
    *pdf_5 = _S1016;
    float3  _S1017 = tangentToWorld(make_float3 (_S1014 * (F32_cos((_S1015))), _S1013, _S1014 * (F32_sin((_S1015)))), dir_9);
    float3  _S1018 = ((((_S1017)) * make_float3(rnorm3df(((_S1017)).x, ((_S1017)).y, ((_S1017)).z))));
    return _S1018;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_2)
{
    BSDFMaterial _S1019;
    (&_S1019)->albedo = albedo_1;
    (&_S1019)->emissive = emissive_0;
    (&_S1019)->roughness = roughness_0;
    (&_S1019)->metallic = metallic_0;
    (&_S1019)->transmission = transmission_0;
    (&_S1019)->ior = ior_0;
    (&_S1019)->absorption = absorption_0;
    (&_S1019)->specular_tint = specular_tint_0;
    (&_S1019)->specular_level = specular_level_0;
    (&_S1019)->translucent = translucent_0;
    (&_S1019)->sheen = sheen_2;
    (&_S1019)->sheen_roughness = sheen_roughness_0;
    (&_S1019)->anisotropy = anisotropy_0;
    (&_S1019)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1019)->tangent = tangent_2;
    (&_S1019)->velvet = velvet_0;
    (&_S1019)->toon = toon_2;
    return _S1019;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1020;
    (&_S1020)->scatter = scatter_1;
    (&_S1020)->extinction = extinction_1;
    (&_S1020)->g = g_2;
    return _S1020;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_11, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1021;
    (&_S1021)->smooth_n = smooth_n_4;
    (&_S1021)->geometry_n = geometry_n_2;
    (&_S1021)->geometry_offset = geometry_offset_2;
    (&_S1021)->material = *material_11;
    (&_S1021)->skip = skip_0;
    (&_S1021)->random_state = random_state_11;
    (&_S1021)->coverage = coverage_0;
    (&_S1021)->encloses = encloses_0;
    (&_S1021)->volume = *volume_0;
    (&_S1021)->fills = fills_0;
    (&_S1021)->hair = hair_0;
    return _S1021;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S1022 = (&surface_6->material)->emissive;
    float3  _S1023 = make_float3 (0.0f);
    bool _S1024 = !top_0;
    float3  _S1025 = _slang_select(_S1024, _S1023,_S1022);
    (&(&lower_0)->material)->emissive = _S1025;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_1)
{
    float _S1026 = surface_7->coverage;
    bool _S1027 = u_1 < _S1026;
    if(_S1027)
    {
        return *surface_7;
    }
    float3  _S1028 = make_float3 (0.0f);
    float3  _S1029 = make_float3 (1.0f);
    BSDFMaterial _S1030 = Material_x24init_0(_S1028, _S1028, 0.0f, 0.0f, 0.0f, 0.0f, _S1028, _S1029, 1.0f, _S1028, _S1028, 0.5f, 0.0f, 0.0f, _S1028, 0.0f, _S1028);
    BSDFMaterial material_12 = _S1030;
    (&material_12)->albedo = _S1029;
    (&material_12)->emissive = (&surface_7->material)->emissive;
    (&material_12)->transmission = 1.0f;
    (&material_12)->ior = 1.0f;
    (&material_12)->absorption = (&surface_7->material)->absorption;
    FKSurface through_0 = *surface_7;
    (&through_0)->material = material_12;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S1031 = transmission_1 > 0.0f;
    bool _S1032;
    if(_S1031)
    {
        _S1032 = true;
    }
    else
    {
        _S1032 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1033 = _slang_select(_S1032, 1.0f,-1.0f);
    return _S1033;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_9)
{
    return (dot_0(dir_10, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_11)
{
    float3  _S1034 = surface_8->geometry_n;
    float _S1035 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_11);
    FKSurface faced_0 = *surface_8;
    float3  _S1036 = surface_8->smooth_n * make_float3 (_S1035);
    (&faced_0)->smooth_n = _S1036;
    float3  _S1037 = _S1034 * make_float3 (_S1035);
    (&faced_0)->geometry_n = _S1037;
    return faced_0;
}

static __device__ float3  max_0(float3  x_22, float3  y_7)
{
    float3  result_11;
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
        *_slang_vector_get_element_ptr(&result_11, i_20) = (F32_max((_slang_vector_get_element(x_22, i_20)), (_slang_vector_get_element(y_7, i_20))));
        i_20 = i_20 + int(1);
    }
    return result_11;
}

static __device__ float3  log_0(float3  x_23)
{
    float3  result_12;
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
        *_slang_vector_get_element_ptr(&result_12, i_21) = (F32_log((_slang_vector_get_element(x_23, i_21))));
        i_21 = i_21 + int(1);
    }
    return result_12;
}

__device__ float3  beerLambert(float distance_3, float3  absorption_1)
{
    float3  _S1038 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1038));
}

__device__ float2  vertexEta(BSDFMaterial material_13, float n_dot_v_0)
{
    bool _S1039 = n_dot_v_0 < 0.0f;
    float _S1040 = _slang_select(_S1039, material_13.ior,1.0f);
    float _S1041 = _slang_select(_S1039, 1.0f,material_13.ior);
    return make_float2 (_S1040, _S1041);
}

__device__ bool neeDecision(BSDFMaterial material_14, float n_dot_v_1, float eta_i_9, float eta_o_9)
{
    float _S1042 = fresnel((F32_abs((n_dot_v_1))), eta_i_9, eta_o_9);
    float3  _S1043 = mix_0(make_float3 (_S1042), material_14.albedo, material_14.metallic);
    float _S1044 = rgb_to_greyscale(_S1043);
    float _S1045 = (F32_max(((1.0f - _S1044) * (1.0f - material_14.metallic) * (1.0f - material_14.transmission)), (0.0f)));
    bool _S1046 = _S1045 > 0.03999999910593033f;
    bool _S1047;
    if(_S1046)
    {
        _S1047 = true;
    }
    else
    {
        _S1047 = (material_14.roughness) > 0.20000000298023224f;
    }
    return _S1047;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_15)
{
    float _S1048 = rgb_to_greyscale(material_15->translucent);
    return _S1048 > 0.0f;
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
    MediumSides _S1049;
    (&_S1049)->behind = *behind_0;
    (&_S1049)->front = *front_0;
    (&_S1049)->fillings = fillings_1;
    (&_S1049)->face = face_1;
    return _S1049;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1050 = surface_9->geometry_n;
    MediumSides _S1051 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S1051;
    bool _S1052 = surface_9->encloses;
    if(_S1052)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S1053 = (dot_0(dir_12, _S1050)) > 0.0f;
        if(_S1053)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_3, float length_3, float width_2, FKHit * own_1, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1054 = surface_10->geometry_n;
    ShadowContext _S1055 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_2, lobe_3, true, length_3, width_2, own_1, fiber_1);
    bool _S1056 = surface_10->encloses;
    ShadowContext context_4;
    if(_S1056)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S1057 = - _S1054;
        float3  _S1058 = _slang_select(turned_0, _S1057,_S1054);
        (&faced_1)->geometry_n = _S1058;
        FKMedium _S1059 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1060 = faced_1;
        FKMedium _S1061 = _S1059;
        MediumSides _S1062 = mediumSides_0(&_S1060, &_S1061, filling_1, dir_13, outside_1);
        ShadowContext _S1063 = ShadowContext_x24init_0(_S1062.behind.extinction, _S1062.front.extinction, _S1062.fillings, _S1054, depth_2, lobe_3, true, length_3, width_2, own_1, fiber_1);
        if(turned_0)
        {
            uint2  _S1064 = _S1062.fillings;
            ShadowContext _S1065 = ShadowContext_x24init_0(_S1062.front.extinction, _S1062.behind.extinction, uint2 {_S1064.y, _S1064.x}, _S1054, depth_2, lobe_3, true, length_3, width_2, own_1, fiber_1);
            context_4 = _S1065;
        }
        else
        {
            context_4 = _S1063;
        }
    }
    else
    {
        context_4 = _S1055;
    }
    return context_4;
}

static __device__ bool any_1(bool3  x_24)
{
    bool result_13 = false;
    int i_22 = int(0);
    for(;;)
    {
        if(i_22 < int(3))
        {
        }
        else
        {
            break;
        }
        if(result_13)
        {
            result_13 = true;
        }
        else
        {
            result_13 = (bool((_slang_vector_get_element(x_24, i_22))));
        }
        i_22 = i_22 + int(1);
    }
    return result_13;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_3, BSDFMaterial * material_16, float eta_i_10, float eta_o_10, bool competing_1, uint random_state_12)
{
    float3  _S1066 = light_2->dir;
    bool _S1067 = (dot_0(geometry_n_3, - in_dir_8) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_3;
    float3  _S1068 = BSDF(in_dir_8, _S1066, smooth_n_5, *material_16, eta_i_10, eta_o_10, _S1067, random_state_12, &throughputs_1, &pdfs_3);
    bool _S1069 = !competing_1;
    bool _S1070;
    if(_S1069)
    {
        _S1070 = true;
    }
    else
    {
        _S1070 = (light_2->density) == 0.0f;
    }
    if(_S1070)
    {
        return _S1068 * light_2->radiance;
    }
    float3  _S1071 = make_float3 (0.0f);
    uint i_23 = 0U;
    float3  weighted_0 = _S1071;
    for(;;)
    {
        if(i_23 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1072 = (pdfs_3[i_23]) > 0.0f;
        if(_S1072)
        {
            float _S1073 = light_2->density;
            float _S1074 = pdfs_3[i_23] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_23] * make_float3 (pdfs_3[i_23]) / make_float3 (_S1073 * (1.0f + _S1074 * _S1074));
            weighted_0 = weighted_1;
        }
        uint i_24 = i_23 + 1U;
        i_23 = i_24;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_13, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S1075;
    (&_S1075)->unit_direction = unit_direction_1;
    (&_S1075)->throughput = throughput_1;
    (&_S1075)->random_state = random_state_13;
    (&_S1075)->refracted = refracted_3;
    (&_S1075)->lobe = lobe_4;
    (&_S1075)->pdf = pdf_6;
    return _S1075;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_9, float n_i_dot_v_6, float alpha_15, BSDFMaterial material_17, BSDFLobes lobes_11, float eta_i_11, float eta_o_11, uint random_state_14)
{
    float3  _S1076 = make_float3 (1.0f);
    SampleBSDF _S1077 = SampleBSDF_x24init_0(_S1076, _S1076, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1077;
    Random _S1078 = pcg(random_state_14);
    Random _S1079 = pcg(_S1078.state);
    (&sample_1)->random_state = _S1079.state;
    float _S1080 = _S1078.value;
    float _S1081 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1080 * _S1080))))));
    float _S1082 = 6.28318548202514648f * _S1079.value;
    float3  _S1083 = tangentToWorld(make_float3 (_S1081 * (F32_cos((_S1082))), _S1078.value, _S1081 * (F32_sin((_S1082)))), n_i_9);
    (&sample_1)->unit_direction = _S1083;
    (&sample_1)->lobe = 4U;
    float3  _S1084 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_9, alpha_15, material_17, lobes_11);
    (&sample_1)->throughput = _S1084;
    float _S1085 = sheenVelvetPDF(_S1078.value, 0.0f, n_i_dot_v_6, alpha_15, lobes_11, eta_i_11, eta_o_11);
    (&sample_1)->pdf = _S1085;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1086 = (F32_sqrt((random_1_0)));
    float _S1087 = 6.28318548202514648f * random_2_0;
    float _S1088 = _S1086 * (F32_cos((_S1087)));
    float _S1089 = _S1086 * (F32_sin((_S1087)));
    float _S1090 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1088 * _S1088 - _S1089 * _S1089))))));
    return make_float3 (_S1088, _S1090, _S1089);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_2, float3  n_i_10, float n_i_dot_v_7, float alpha_16, BSDFMaterial material_18, BSDFLobes lobes_12, float eta_i_12, float eta_o_12, uint random_state_15)
{
    float3  _S1091 = make_float3 (1.0f);
    SampleBSDF _S1092 = SampleBSDF_x24init_0(_S1091, _S1091, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1092;
    Random _S1093 = pcg(random_state_15);
    Random _S1094 = pcg(_S1093.state);
    (&sample_2)->random_state = _S1094.state;
    float3  _S1095 = sampleCosWeightedHemisphere(_S1093.value, _S1094.value);
    bool _S1096 = u_2 < (lobes_12.p_diffuse * lobes_12.translucent_share);
    float _S1097 = _S1095.y;
    float _S1098 = - _S1097;
    float _S1099 = _slang_select(_S1096, _S1098,_S1097);
    float3  _S1100 = tangentToWorld(make_float3 (_S1095.x, _S1099, _S1095.z), n_i_10);
    (&sample_2)->unit_direction = _S1100;
    (&sample_2)->refracted = _S1096;
    (&sample_2)->lobe = 0U;
    float3  _S1101 = diffuseBSDF((&sample_2)->unit_direction, n_i_10, alpha_16, material_18, lobes_12);
    (&sample_2)->throughput = _S1101;
    float _S1102 = diffusePDF(_S1099, 0.0f, n_i_dot_v_7, alpha_16, lobes_12, eta_i_12, eta_o_12);
    (&sample_2)->pdf = _S1102;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_11, float n_i_dot_v_8, float alpha_17, BSDFMaterial material_19, BSDFLobes lobes_13, float eta_i_13, float eta_o_13, uint random_state_16)
{
    float3  _S1103 = make_float3 (1.0f);
    SampleBSDF _S1104 = SampleBSDF_x24init_0(_S1103, _S1103, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1104;
    Random _S1105 = pcg(random_state_16);
    Random _S1106 = pcg(_S1105.state);
    (&sample_3)->random_state = _S1106.state;
    float _S1107 = _S1105.value * lobes_13.toon_norm / 6.28318548202514648f;
    float t_21;
    if(lobes_13.toon_glossy)
    {
        t_21 = (F32_acos((clamp_1(1.0f - _S1107, -1.0f, 1.0f))));
    }
    else
    {
        t_21 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1107)))), (1.0f))))));
    }
    if(t_21 < (lobes_13.toon_a))
    {
    }
    else
    {
        t_21 = (lobes_13.toon_a + lobes_13.toon_b) / 2.0f;
    }
    int k_0 = int(0);
    for(;;)
    {
        if(k_0 < int(8))
        {
        }
        else
        {
            break;
        }
        float _S1108;
        if(t_21 < (lobes_13.toon_a))
        {
            _S1108 = 1.0f;
        }
        else
        {
            _S1108 = (F32_max((1.0f - (t_21 - lobes_13.toon_a) / (F32_max((lobes_13.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float integral_1;
        if(lobes_13.toon_glossy)
        {
            integral_1 = 1.0f - (F32_cos(((F32_min((t_21), (lobes_13.toon_a))))));
        }
        else
        {
            float _S1109 = (F32_sin(((F32_min((t_21), (lobes_13.toon_a))))));
            integral_1 = _S1109 * _S1109 / 2.0f;
        }
        bool _S1110 = t_21 > (lobes_13.toon_a);
        bool _S1111;
        if(_S1110)
        {
            _S1111 = (lobes_13.toon_s) > 0.0f;
        }
        else
        {
            _S1111 = false;
        }
        float integral_2;
        if(_S1111)
        {
            if(lobes_13.toon_glossy)
            {
                float _S1112 = (F32_cos((lobes_13.toon_a)));
                float _S1113 = (F32_cos((t_21)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1112 - _S1113) - ((F32_sin((t_21))) - t_21 * _S1113 - ((F32_sin((lobes_13.toon_a))) - lobes_13.toon_a * _S1112)) / lobes_13.toon_s;
            }
            else
            {
                float _S1114 = 2.0f * lobes_13.toon_a;
                float _S1115 = (F32_cos((_S1114)));
                float _S1116 = 2.0f * t_21;
                float _S1117 = (F32_cos((_S1116)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1115 - _S1117) / 4.0f - ((F32_sin((_S1116))) / 8.0f - t_21 * _S1117 / 4.0f - ((F32_sin((_S1114))) / 8.0f - lobes_13.toon_a * _S1115 / 4.0f)) / lobes_13.toon_s;
            }
            float integral_3 = integral_1 + integral_2;
            integral_2 = integral_3;
        }
        else
        {
            integral_2 = integral_1;
        }
        float _S1118 = _S1108 * (F32_sin((t_21)));
        float _S1119;
        if(lobes_13.toon_glossy)
        {
            _S1119 = 1.0f;
        }
        else
        {
            _S1119 = (F32_cos((t_21)));
        }
        float _S1120 = _S1118 * _S1119;
        float _S1121 = (integral_2 - _S1107) / _S1120;
        bool _S1122 = _S1120 > 0.0f;
        float _S1123 = _slang_select(_S1122, _S1121,0.0f);
        float _S1124 = clamp_1(t_21 - _S1123, 0.0f, lobes_13.toon_b);
        int k_1 = k_0 + int(1);
        t_21 = _S1124;
        k_0 = k_1;
    }
    float _S1125 = 6.28318548202514648f * _S1106.value;
    float _S1126 = (F32_sin((t_21)));
    float3  _S1127 = tangentToWorld(make_float3 (_S1126 * (F32_cos((_S1125))), (F32_cos((t_21))), _S1126 * (F32_sin((_S1125)))), lobes_13.toon_axis);
    (&sample_3)->unit_direction = _S1127;
    bool _S1128 = (dot_0(n_i_11, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1128;
    (&sample_3)->lobe = 6U;
    float3  _S1129 = toonBSDF((&sample_3)->unit_direction, n_i_11, alpha_17, material_19, lobes_13);
    (&sample_3)->throughput = _S1129;
    float _S1130 = toonPDF(dot_0(n_i_11, (&sample_3)->unit_direction), dot_0((&sample_3)->unit_direction, lobes_13.toon_axis), n_i_dot_v_8, alpha_17, lobes_13, eta_i_13, eta_o_13);
    (&sample_3)->pdf = _S1130;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_12, float n_i_dot_v_9, float alpha_18, BSDFMaterial material_20, BSDFLobes lobes_14, float eta_i_14, float eta_o_14, uint random_state_17)
{
    float3  _S1131 = make_float3 (1.0f);
    SampleBSDF _S1132 = SampleBSDF_x24init_0(_S1131, _S1131, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1132;
    (&sample_4)->unit_direction = lobes_14.refracted;
    (&sample_4)->random_state = random_state_17;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1133 = refractBSDF((&sample_4)->unit_direction, n_i_12, alpha_18, material_20, lobes_14);
    (&sample_4)->throughput = _S1133;
    float _S1134 = refractPDF(0.0f, dot_0((&sample_4)->unit_direction, ggx_n_3), n_i_dot_v_9, alpha_18, lobes_14, eta_i_14, eta_o_14);
    (&sample_4)->pdf = _S1134;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_25, float3  n_10)
{
    return i_25 - make_float3 (2.0f * dot_0(n_10, i_25)) * n_10;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_13, float n_i_dot_v_10, float alpha_19, BSDFMaterial material_21, BSDFLobes lobes_15, float eta_i_15, float eta_o_15, uint random_state_18)
{
    float3  _S1135 = make_float3 (1.0f);
    SampleBSDF _S1136 = SampleBSDF_x24init_0(_S1135, _S1135, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1136;
    float3  _S1137 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S1138 = ((((_S1137)) * make_float3(rnorm3df(((_S1137)).x, ((_S1137)).y, ((_S1137)).z))));
    (&sample_5)->unit_direction = _S1138;
    (&sample_5)->random_state = random_state_18;
    (&sample_5)->lobe = 2U;
    float3  _S1139 = reflectBSDF((&sample_5)->unit_direction, n_i_13, alpha_19, material_21, lobes_15);
    (&sample_5)->throughput = _S1139;
    float _S1140 = reflectPDF(0.0f, 0.0f, n_i_dot_v_10, alpha_19, lobes_15, eta_i_15, eta_o_15);
    (&sample_5)->pdf = _S1140;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_11, BSDFMaterial material_22, float eta_i_16, float eta_o_16, uint random_init_0, float2  screen_space_0)
{
    uint random_state_19 = random_init_0;
    float3  _S1141 = negate_0(in_dir_10);
    float _S1142 = dot_0(n_11, _S1141);
    float _S1143 = sign_0(_S1142);
    float3  n_i_14 = n_11 * make_float3 (_S1143);
    float _S1144 = (F32_abs((_S1142)));
    float _S1145 = material_22.roughness;
    float _S1146 = _S1145 * _S1145;
    AnisotropicFrame _S1147 = anisotropicFrame(material_22, n_i_14);
    SheenProfile _S1148 = sheenProfile(_S1141, n_i_14, material_22);
    float3  _S1149 = sampleHalfVector(_S1141, n_i_14, _S1146, _S1147, &random_state_19);
    BSDFLobes _S1150 = bsdfLobes(in_dir_10, _S1141, n_i_14, _S1149, material_22, eta_i_16, eta_o_16, _S1147, _S1148);
    BSDFLobes lobes_16 = _S1150;
    float _S1151 = translucentShare(material_22);
    (&lobes_16)->translucent_share = _S1151;
    Random _S1152 = pcg(random_state_19);
    random_state_19 = _S1152.state;
    bool _S1153 = (_S1152.value) < ((&lobes_16)->p_sheen_velvet);
    if(_S1153)
    {
        SampleBSDF _S1154 = sheenVelvetSample(n_i_14, _S1144, _S1146, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1154;
    }
    float _S1155 = _S1152.value - (&lobes_16)->p_sheen_velvet;
    bool _S1156 = _S1155 < ((&lobes_16)->p_diffuse);
    if(_S1156)
    {
        SampleBSDF _S1157 = diffuseSample(_S1155, n_i_14, _S1144, _S1146, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1157;
    }
    bool _S1158 = _S1155 < ((&lobes_16)->p_diffuse + (&lobes_16)->p_toon);
    if(_S1158)
    {
        SampleBSDF _S1159 = toonSample(n_i_14, _S1144, _S1146, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1159;
    }
    float _S1160 = (&lobes_16)->p_toon;
    bool _S1161 = (_S1155 - _S1160) < ((&lobes_16)->p_diffuse + (&lobes_16)->p_refract);
    if(_S1161)
    {
        SampleBSDF _S1162 = refractSample(_S1149, n_i_14, _S1144, _S1146, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1162;
    }
    SampleBSDF _S1163 = reflectSample(in_dir_10, _S1149, n_i_14, _S1144, _S1146, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
    return _S1163;
}

static __device__ bool boundsVolume_0(FKSurface * surface_11)
{
    return surface_11->encloses;
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_8, bool replay_1, float scale_3, Selection * sel_7)
{
    float spread_1;
    bool turned_1;
    bool is_inside_5;
    bool viewed_0;
    bool _S1164;
    bool _S1165;
    float density_2;
    float threshold_0;
    float width_3;
    float sky_pdf_0;
    float geometry_density_0;
    uint b_5;
    uint layer_0;
    float3  throughput_2;
    float3  chain_throughput_0;
    TreeSample light_3;
    int _S1166;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_4;
    float sky_pdf_1;
    float spread_3;
    float width_5;
    uint b_6;
    float3  _S1167 = make_float3 (0.0f);
    Shift _S1168 = Shift_x24init_0(_S1167, 0.0f);
    uint _S1169 = r_8->path;
    uint _S1170 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1171 = extractBits_0(_S1169, 5U, 5U);
    uint _S1172 = extractBits_0(_S1169, 10U, 2U);
    uint _S1173 = extractBits_0(_S1169, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S1174 = _S1173 >= 3U;
        uint _S1175 = _slang_select(_S1174, 1U,0U);
        uint _S1176 = _S1170 + _S1175;
        uint _S1177 = (fcptMaxBounces());
        passes_0 = _S1176 > _S1177;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1168;
    }
    uint _S1178 = _S1171 - 1U;
    bool _S1179 = _S1173 == 3U;
    uint _S1180 = _slang_select(_S1179, 1U,0U);
    uint _S1181 = _S1170 + _S1180;
    bool _S1182 = _S1172 == 0U;
    uint _S1183 = _slang_select(_S1182, _S1181,_S1178);
    FKHit _S1184 = (fcptReservoirHit((*r_8)));
    float3  _S1185 = dom_7->x0;
    float3  _S1186 = dom_7->x1 - dom_7->x0;
    float3  _S1187 = ((((_S1186)) * make_float3(rnorm3df(((_S1186)).x, ((_S1186)).y, ((_S1186)).z))));
    FKRay _S1188 = Ray_x24init_0(dom_7->x1, _S1187);
    FKRay ray_2 = _S1188;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1167;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1167;
    float3  extinction_in_0 = _S1167;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1189 = dom_7->spread;
    float _S1190 = dom_7->width;
    float _S1191 = length_0(_S1186);
    NEEVertex _S1192 = NEEVertex_x24init_0(true, 0.0f, _S1167, _S1167, _S1167);
    NEEVertex nee_vertex_0 = _S1192;
    Vertex _S1193 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1193;
    Reservoir _S1194 = (Reservoir{});
    Reservoir chain_0 = _S1194;
    uint _S1195 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1185;
    (&hit_4)->distance = _S1191;
    FKMedium _S1196 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1197 = filling_2;
    bool _S1198 = (fcptVaryingUsed());
    uint _S1199 = _slang_select(_S1198, _S1197,4294967295U);
    filling_2 = _S1199;
    scatter_in_0 = _S1196.scatter;
    extinction_in_0 = _S1196.extinction;
    g_in_0 = _S1196.g;
    Reservoir _S1200 = chain_0;
    uint _S1201 = filling_2;
    for(;;)
    {
        bool _S1202 = (fcptVaryingUsed());
        if(_S1202)
        {
            passes_0 = _S1201 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1203 = (fcptMajorant((_S1201)));
            spread_1 = _S1203;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S1183;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1172 == 1U;
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
            ended_0 = _S1168;
            sky_pdf_0 = 0.0f;
            spread_1 = _S1189;
            width_3 = _S1190;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_5 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1204 = (&prev_0)->rough;
        if(_S1204)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1205 = stream(_S1195, 384U);
        uint tracking_0 = _S1205;
        weight_1 = throughput_3;
        glowed_0 = _S1167;
        b_5 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_0 = _S1189;
        width_3 = _S1190;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1166 = int(1);
                break;
            }
            uint _S1206 = b_5 + 320U;
            bool _S1207 = b_5 == 4294967295U;
            uint _S1208 = _slang_select(_S1207, 384U,_S1206);
            uint _S1209 = stream(_S1195, _S1208);
            Random _S1210 = pcg(_S1209);
            float _S1211 = - (F32_log((1.0f - _S1210.value))) / spread_1;
            if(passes_0)
            {
                float3  _S1212 = (&ray_2)->origin;
                float3  _S1213 = (&ray_2)->unit_direction;
                float _S1214 = (&hit_4)->distance;
                uint _S1215 = _slang_select(_S1207, 0U,b_5);
                uint _S1216 = (&prev_0)->lobe;
                uint _S1217 = _slang_select(_S1207, 3U,_S1216);
                float _S1218 = (fcptTrackMedium((_S1201), (_S1212), (_S1213), (_S1214), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1215), (_S1217), (_S1207)));
                geometry_density_0 = _S1218;
            }
            else
            {
                geometry_density_0 = _S1211;
            }
            bool _S1219 = !(geometry_density_0 < ((&hit_4)->distance));
            if(_S1219)
            {
                _S1166 = int(1);
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
                float3  _S1220 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1221 = sel_7->glow + _S1220;
                sel_7->glow = _S1221;
            }
            else
            {
            }
            glowed_0 = _S1167;
            uint b_7 = b_5 + 1U;
            float3  _S1222 = (&ray_2)->origin + make_float3 (geometry_density_0) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1222;
            float3  _S1223 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, geometry_density_0, true);
            float3  _S1224 = weight_1;
            float3  _S1225 = _slang_select(passes_0, _S1224,_S1223);
            float3  throughput_4 = throughput_2 * _S1225;
            uint _S1226 = stream(_S1195, b_7 + 320U);
            tracking_0 = _S1226;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_0 * geometry_density_0;
            float _S1227 = threshold_0 + 3.14159274101257324f;
            bool _S1228 = !replay_1;
            if(_S1228)
            {
                is_inside_5 = true;
            }
            else
            {
                bool _S1229 = b_7 == _S1183;
                if(_S1229)
                {
                    is_inside_5 = !passes_0;
                }
                else
                {
                    is_inside_5 = false;
                }
            }
            TreeSample _S1230 = TreeSample_x24init_0(_S1167, _S1167, 0.0f, 0U);
            if(is_inside_5)
            {
                float3  _S1231 = (&ray_2)->origin;
                float3  _S1232 = (&ray_2)->unit_direction;
                float3  _S1233 = (&ray_2)->unit_direction;
                uint _S1234 = stream(_S1195, b_7 + 64U);
                float3  _S1235 = extinction_in_0;
                float3  _S1236 = extinction_in_0;
                uint2  _S1237 = make_uint2 (_S1201);
                float3  _S1238 = (&ray_2)->unit_direction;
                uint _S1239 = arrivalLobe_0(b_7, (&prev_0)->lobe);
                FKHit _S1240 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1241 = _S1240;
                ShadowContext _S1242 = ShadowContext_x24init_0(_S1235, _S1236, _S1237, _S1238, b_7, _S1239, false, geometry_density_0, width_6, &_S1241, false);
                ShadowContext _S1243 = _S1242;
                TreeSample _S1244 = sampleLightTree_0(_S1231, _S1232, _S1233, 0.0f, true, _S1234, &_S1243);
                light_3 = _S1244;
            }
            else
            {
                light_3 = _S1230;
            }
            float _S1245 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1246 = (fcptMaxBounces());
            bool _S1247 = b_7 < _S1246;
            if(_S1247)
            {
                viewed_0 = (light_3.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S1248 = _slang_select(viewed_0, _S1245,0.0f);
            float3  _S1249 = throughput_4 * light_3.radiance;
            float _S1250 = powerHeuristic(light_3.density, _S1248);
            float3  _S1251 = _S1249 * make_float3 (_S1245 * _S1250);
            float3  _S1252 = _slang_select(is_inside_5, _S1251,_S1167);
            if(replay_1)
            {
                _S1164 = b_7 == _S1183;
            }
            else
            {
                _S1164 = false;
            }
            if(_S1164)
            {
                bool _S1253 = _S1172 == 2U;
                if(_S1253)
                {
                    float _S1254 = rgb_to_greyscale(_S1252);
                    passes_0 = _S1254 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1255 = Shift_x24init_0(_S1252, 1.0f);
                    _S1166 = int(0);
                    ended_0 = _S1255;
                    spread_1 = _S1227;
                    geometry_density_0 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_7;
                    break;
                }
                _S1166 = int(0);
                ended_0 = _S1168;
                spread_1 = _S1227;
                geometry_density_0 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_7;
                break;
            }
            if(_S1228)
            {
                Reservoir candidate_3 = _S1200;
                uint _S1256 = extractBits_0(_S1200.path, 10U, 2U);
                bool _S1257 = _S1256 == 1U;
                if(_S1257)
                {
                    float3  _S1258 = safeDivide(_S1252, _S1167);
                    (&candidate_3)->radiance = _S1258;
                }
                else
                {
                    uint _S1259 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                    uint _S1260 = insertBits_0(_S1259, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1260;
                }
                Reservoir _S1261 = withEnd(candidate_3, 0U, b_7, _S1252);
                offer(sel_7, _S1261, _S1252 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1262 = survivalProbability(throughput_4, density_2);
                uint _S1263 = stream(_S1195, b_7 + 128U);
                Random _S1264 = pcg(_S1263);
                bool _S1265 = _S1262 < (_S1264.value);
                if(_S1265)
                {
                    _S1165 = true;
                }
                else
                {
                    uint _S1266 = (fcptMaxBounces());
                    _S1165 = b_7 >= _S1266;
                }
                if(_S1165)
                {
                    _S1166 = int(0);
                    ended_0 = _S1168;
                    spread_1 = _S1227;
                    geometry_density_0 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_7;
                    break;
                }
                float _S1267 = density_2 * _S1262;
                density_2 = _S1267;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1268 = stream(_S1195, b_7);
            float3  _S1269 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1268, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1269;
            NEEVertex _S1270 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1167, (&ray_2)->origin);
            nee_vertex_0 = _S1270;
            Vertex _S1271 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_0 = _S1271;
            float _S1272 = (&prev_0)->pdf;
            FKRay _S1273 = ray_2;
            FKHit _S1274 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1275 = (fcptTraverseInstanceBVH((_S1273), (true), (4.294967296e+09f), (false), (_S1274), (false)));
            hit_4 = _S1275;
            b_5 = b_7;
            throughput_2 = throughput_4;
            threshold_0 = _S1227;
            width_3 = width_6;
            sky_pdf_0 = _S1272;
        }
        if(_S1166 != int(1))
        {
            width_3 = geometry_density_0;
            throughput_2 = chain_throughput_0;
            b_5 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1168;
        spread_1 = threshold_0;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1276 = b_5 == 4294967295U;
    bool _S1277 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1277)
    {
        bool _S1278 = !(&nee_vertex_0)->none;
        float _S1279 = _slang_select(_S1278, sky_pdf_0,0.0f);
        float _S1280 = escapeWeight_0(_S1279, (&ray_2)->unit_direction);
        float3  _S1281 = environment_0((&ray_2)->unit_direction, b_5, (&prev_0)->lobe);
        float3  _S1282 = throughput_2 * _S1281;
        if(replay_1)
        {
            bool _S1283 = b_5 == _S1183;
            if(_S1283)
            {
                passes_0 = _S1172 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1282 * make_float3 (_S1280) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1182)
            {
                passes_0 = _S1179;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_5 == _S1170;
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
                return Shift_x24init_0(_S1282 * make_float3 (_S1280), 1.0f);
            }
            return _S1168;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1284 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1285 = _S1284 == 1U;
        if(_S1285)
        {
            uint _S1286 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1287 = _S1286 == b_5;
            float _S1288 = _slang_select(_S1287, 1.0f,_S1280);
            float3  _S1289 = safeDivide(_S1282 * make_float3 (_S1288), _S1167);
            (&candidate_4)->radiance = _S1289;
        }
        else
        {
            bool _S1290 = (&prev_0)->rough;
            if(_S1290)
            {
                uint _S1291 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                uint _S1292 = insertBits_0(_S1291, 3U, 10U, 2U);
                uint _S1293 = insertBits_0(_S1292, (&prev_0)->lobe, 15U, 3U);
                bool _S1294 = (&prev_0)->inside;
                uint _S1295 = _slang_select(_S1294, 1U,0U);
                uint _S1296 = insertBits_0(_S1293, _S1295, 22U, 1U);
                (&candidate_4)->path = _S1296;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1297 = _S1282 * make_float3 (_S1280);
        Reservoir _S1298 = withEnd(candidate_4, 3U, b_5, _S1297);
        offer(sel_7, _S1298, _S1297 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1168;
    }
    float3  _S1299 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1299;
    bool _S1300 = (fcptVaryingUsed());
    if(_S1300)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1301 = !replay_1;
        if(_S1301)
        {
            float3  _S1302 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1303 = sel_7->glow + _S1302;
            sel_7->glow = _S1303;
        }
        float3  _S1304 = throughput_2 * weight_1;
        throughput_2 = _S1304;
    }
    else
    {
        float3  _S1305 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1306 = throughput_2 * _S1305;
        throughput_2 = _S1306;
    }
    float _S1307 = width_3 + spread_1 * (&hit_4)->distance;
    uint _S1308 = b_5 + 1U;
    b_5 = _S1308;
    layer_0 = 0U;
    width_3 = _S1307;
    passes_0 = false;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S1167;
    float3  reconnection_0 = _S1167;
    viewed_0 = _S1276;
    for(;;)
    {
        bool _S1309 = ((&hit_4)->is_point_light) == 1U;
        if(replay_1)
        {
            _S1164 = _S1172 == 1U;
        }
        else
        {
            _S1164 = false;
        }
        if(_S1164)
        {
            _S1165 = b_5 == _S1171;
        }
        else
        {
            _S1165 = false;
        }
        bool _S1310;
        if(_S1165)
        {
            bool _S1311 = ((&hit_4)->instance_index) != (_S1184.instance_index);
            if(_S1311)
            {
                _S1310 = true;
            }
            else
            {
                _S1310 = ((&hit_4)->triangle_index) != (_S1184.triangle_index);
            }
        }
        else
        {
            _S1310 = false;
        }
        if(_S1310)
        {
            return _S1168;
        }
        FKMedium _S1312 = Medium_x24init_0(_S1167, _S1167, 0.0f);
        BSDFMaterial _S1313 = Material_x24init_0(_S1167, _S1167, 0.0f, 0.0f, 0.0f, 0.0f, _S1167, throughput_3, 1.0f, _S1167, _S1167, 0.5f, 0.0f, 0.0f, _S1167, 0.0f, _S1167);
        FKMedium _S1314 = _S1312;
        FKSurface _S1315 = Surface_x24init_0(_S1167, _S1167, 0.0f, &_S1313, false, 0U, 1.0f, false, &_S1314, 4294967295U, _S1167);
        bool _S1316 = !_S1309;
        bool scatter_2;
        bool is_inside_6;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S1316)
        {
            uint _S1317 = stream(_S1195, b_5);
            uint _S1318 = arrivalLobe_0(b_5, (&prev_0)->lobe);
            FKSurface _S1319 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1317), (width_3), (layer_0), (b_5), (_S1318), ((&ray_2)->unit_direction)));
            bool _S1320 = !passes_0;
            FKSurface _S1321 = _S1319;
            FKSurface _S1322 = emitting_0(&_S1321, _S1320);
            uint _S1323 = stream(_S1195, b_5 + 256U);
            Random _S1324 = pcg(_S1323);
            FKSurface _S1325 = _S1322;
            FKSurface _S1326 = uncovered_0(&_S1325, _S1324.value);
            float _S1327 = facingSign(_S1326.material.transmission, _S1326.geometry_n, (&ray_2)->unit_direction);
            bool _S1328 = _S1327 < 0.0f;
            bool _S1329 = (_S1326.material.transmission) > 0.0f;
            if(_S1329)
            {
                bool _S1330 = arrivesBehind_0((&ray_2)->unit_direction, _S1326.geometry_n);
                scatter_2 = _S1330;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1331 = _S1326;
            FKSurface _S1332 = facingRay_0(&_S1331, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1333 = arrivesBehind_0((&ray_2)->unit_direction, _S1332.geometry_n);
                is_inside_6 = _S1333;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S1334 = beerLambert((&hit_4)->distance, _S1332.material.absorption);
                float3  _S1335 = throughput_2 * _S1334;
                throughput_5 = _S1335;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1336 = !_S1332.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S1332.geometry_n, (&ray_2)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1337 = b_5 == _S1308;
            if(_S1337)
            {
                float _S1338 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1338;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S1339 = geometry_density_0;
            scatter_2 = _S1336;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1339;
            surface_12 = _S1332;
            turned_1 = _S1328;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_12 = _S1315;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S1340;
        if(scatter_2)
        {
            _S1340 = (&prev_0)->rough;
        }
        else
        {
            _S1340 = false;
        }
        bool _S1341;
        if(_S1340)
        {
            _S1341 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1341 = false;
        }
        FKSurface _S1342 = surface_12;
        FKSurface _S1343 = surface_12;
        float _S1344 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        float2  _S1345 = vertexEta(_S1342.material, _S1344);
        bool _S1346;
        if(scatter_2)
        {
            uint _S1347 = (fcptMaxBounces());
            bool _S1348 = b_5 >= _S1347;
            if(_S1348)
            {
                _S1346 = true;
            }
            else
            {
                bool _S1349 = neeDecision(_S1342.material, _S1344, _S1345.x, _S1345.y);
                _S1346 = _S1349;
            }
        }
        else
        {
            _S1346 = false;
        }
        bool _S1350;
        if(passes_0)
        {
            _S1350 = true;
        }
        else
        {
            _S1350 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1350)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1346;
        }
        bool _S1351 = (fcptHairUsed());
        bool _S1352;
        if(_S1351)
        {
            float3  _S1353 = surface_12.hair;
            _S1352 = (dot_0(_S1353, _S1353)) > 0.0f;
        }
        else
        {
            _S1352 = false;
        }
        bool _S1354;
        if(_S1352)
        {
            _S1354 = true;
        }
        else
        {
            BSDFMaterial _S1355 = _S1342.material;
            bool _S1356 = isTranslucent_0(&_S1355);
            _S1354 = _S1356;
        }
        bool _S1357;
        if(_S1354)
        {
            _S1357 = true;
        }
        else
        {
            bool _S1358 = (_S1342.material.transmission) > 0.0f;
            if(_S1358)
            {
                uint _S1359 = (fcptLayers((hit_4)));
                _S1357 = _S1359 == 1U;
            }
            else
            {
                _S1357 = false;
            }
        }
        float3  emission_0;
        if(_S1309)
        {
            float3  _S1360 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1360;
        }
        else
        {
            emission_0 = _S1342.material.emissive;
        }
        bool _S1361 = !replay_1;
        bool _S1362;
        if(_S1361)
        {
            _S1362 = true;
        }
        else
        {
            _S1362 = b_5 >= _S1183;
        }
        bool _S1363;
        if(_S1362)
        {
            float _S1364 = rgb_to_greyscale(emission_0);
            _S1363 = _S1364 > 0.0f;
        }
        else
        {
            _S1363 = false;
        }
        float3  emission_1;
        if(_S1363)
        {
            NEEVertex _S1365 = nee_vertex_0;
            FKHit _S1366 = hit_4;
            float _S1367 = emissionWeight_0(&_S1365, &_S1366, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1367);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1368;
        if(replay_1)
        {
            _S1368 = _S1172 == 1U;
        }
        else
        {
            _S1368 = false;
        }
        bool _S1369;
        if(_S1368)
        {
            _S1369 = b_5 > _S1171;
        }
        else
        {
            _S1369 = false;
        }
        bool _S1370;
        if(_S1369)
        {
            _S1370 = b_5 == _S1170;
        }
        else
        {
            _S1370 = false;
        }
        bool _S1371;
        if(_S1370)
        {
            bool _S1372 = _S1173 == 1U;
            if(_S1372)
            {
                _S1371 = true;
            }
            else
            {
                _S1371 = _S1173 == 2U;
            }
        }
        else
        {
            _S1371 = false;
        }
        if(_S1371)
        {
            bool _S1373 = _S1309 != (_S1173 == 2U);
            if(_S1373)
            {
                return _S1168;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1374 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1375 = _S1374 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1376 = insertBits_0(0U, b_5, 5U, 5U);
        uint _S1377 = insertBits_0(_S1376, 1U, 10U, 2U);
        uint _S1378 = insertBits_0(_S1377, (&prev_0)->lobe, 15U, 3U);
        bool _S1379 = (&prev_0)->inside;
        uint _S1380 = _slang_select(_S1379, 1U,0U);
        uint _S1381 = insertBits_0(_S1378, _S1380, 22U, 1U);
        (&here_0)->path = _S1381;
        float _S1382 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S1382;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1383;
        if(replay_1)
        {
            _S1383 = _S1172 == 1U;
        }
        else
        {
            _S1383 = false;
        }
        bool _S1384;
        if(_S1383)
        {
            _S1384 = b_5 == _S1171;
        }
        else
        {
            _S1384 = false;
        }
        bool _S1385 = b_5 == _S1183;
        bool _S1386;
        if(_S1385)
        {
            bool _S1387 = !scatter_2;
            if(_S1387)
            {
                _S1386 = true;
            }
            else
            {
                bool _S1388 = _S1172 != 1U;
                if(_S1388)
                {
                    _S1386 = _S1172 != 3U;
                }
                else
                {
                    _S1386 = false;
                }
            }
        }
        else
        {
            _S1386 = false;
        }
        bool _S1389;
        if(_S1386)
        {
            _S1389 = _S1172 == 2U;
        }
        else
        {
            _S1389 = false;
        }
        bool _S1390;
        if(_S1389)
        {
            _S1390 = !_S1341;
        }
        else
        {
            _S1390 = false;
        }
        bool _S1391;
        if(_S1390)
        {
            _S1391 = _S1173 != 4U;
        }
        else
        {
            _S1391 = false;
        }
        bool _S1392 = _S1171 == _S1170;
        bool _S1393;
        if(_S1392)
        {
            _S1393 = _S1173 == 0U;
        }
        else
        {
            _S1393 = false;
        }
        bool _S1394;
        if(_S1393)
        {
            _S1394 = ((&hit_4)->instance_index) == (_S1184.instance_index);
        }
        else
        {
            _S1394 = false;
        }
        bool _S1395;
        if(_S1394)
        {
            _S1395 = ((&hit_4)->triangle_index) == (_S1184.triangle_index);
        }
        else
        {
            _S1395 = false;
        }
        bool _S1396;
        if(_S1395)
        {
            _S1396 = _S1341;
        }
        else
        {
            _S1396 = false;
        }
        bool _S1397 = _slang_select(_S1384, _S1396,_S1391);
        bool _S1398;
        if(nee_0)
        {
            _S1398 = _slang_select(replay_1, _S1397,scatter_2);
        }
        else
        {
            _S1398 = false;
        }
        TreeSample _S1399 = TreeSample_x24init_0(_S1167, _S1167, 0.0f, 0U);
        uint2  _S1400 = make_uint2 (0U);
        float2  _S1401 = make_float2 (0.0f);
        FKHit _S1402 = Hit_x24init_0(_S1401, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1403 = _S1402;
        ShadowContext _S1404 = ShadowContext_x24init_0(_S1167, _S1167, _S1400, _S1167, 0U, 0U, false, 0.0f, 0.0f, &_S1403, false);
        bool _S1405;
        if(nee_0)
        {
            _S1405 = _S1362;
        }
        else
        {
            _S1405 = false;
        }
        ShadowContext context_5;
        if(_S1405)
        {
            uint _S1406 = arrivalLobe_0(b_5, (&prev_0)->lobe);
            FKMedium _S1407 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1408 = surface_12;
            FKHit _S1409 = hit_4;
            FKMedium _S1410 = _S1407;
            ShadowContext _S1411 = shadowContext_0(&_S1408, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_5, _S1406, (&hit_4)->distance, width_3, &_S1409, _S1352, &_S1410);
            context_5 = _S1411;
        }
        else
        {
            context_5 = _S1404;
        }
        float3  throughput_6;
        float3  lit_0;
        if(_S1398)
        {
            float3  _S1412 = (&ray_2)->origin;
            if(_S1352)
            {
                throughput_6 = _S1167;
            }
            else
            {
                throughput_6 = _S1343.smooth_n;
            }
            FKSurface _S1413 = surface_12;
            uint _S1414 = stream(_S1195, b_5 + 64U);
            ShadowContext _S1415 = context_5;
            TreeSample _S1416 = sampleLightTree_0(_S1412, throughput_6, surface_12.geometry_n, surface_12.geometry_offset, _S1357, _S1414, &_S1415);
            bool _S1417 = any_1((_S1416.radiance) != _S1167);
            if(_S1417)
            {
                if(_S1352)
                {
                    uint _S1418 = (fcptMaxBounces());
                    bool _S1419 = b_5 < _S1418;
                    FKSurface _S1420 = surface_12;
                    TreeSample _S1421 = _S1416;
                    float3  _S1422 = hairLight_0(&_S1420, (&ray_2)->unit_direction, &_S1421, _S1419);
                    lit_0 = _S1422;
                }
                else
                {
                    float _S1423 = _S1345.x;
                    float _S1424 = _S1345.y;
                    uint _S1425 = (fcptMaxBounces());
                    bool _S1426 = b_5 < _S1425;
                    TreeSample _S1427 = _S1416;
                    BSDFMaterial _S1428 = _S1342.material;
                    float3  _S1429 = lightBSDF_0((&ray_2)->unit_direction, &_S1427, _S1343.smooth_n, _S1413.geometry_n, &_S1428, _S1423, _S1424, _S1426, surface_12.random_state);
                    lit_0 = _S1429;
                }
            }
            else
            {
                lit_0 = _S1167;
            }
            light_3 = _S1416;
        }
        else
        {
            light_3 = _S1399;
            lit_0 = _S1167;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1430;
        bool _S1431;
        float density_4;
        if(_S1384)
        {
            bool _S1432 = !_S1341;
            if(_S1432)
            {
                return _S1168;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S1392)
            {
                viewed_1 = _S1173 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1392)
            {
                refracted_4 = _S1173 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1433 = !nee_0;
                if(_S1433)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1434 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1434 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1168;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1392)
            {
                wrong_side_0 = _S1173 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1435 = !nee_0;
                if(_S1435)
                {
                    return _S1168;
                }
                float _S1436 = environmentPdf_0(r_8->dir);
                float3  _S1437 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_12, _S1345, is_inside_6, _S1436, surface_12.random_state);
                return Shift_x24init_0(throughput_7 * _S1437 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1438 = extractBits_0(_S1169, 21U, 1U);
            bool _S1439 = nee_0 != (_S1438 == 1U);
            if(_S1439)
            {
                return _S1168;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S1385;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1440 = !scatter_2;
                if(_S1440)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1441 = _S1172 != 1U;
                    if(_S1441)
                    {
                        refracted_4 = _S1172 != 3U;
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
                bool _S1442 = _S1172 == 2U;
                if(_S1442)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1341;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1173 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1352)
                    {
                        return _S1168;
                    }
                    uint _S1443 = stream(_S1195, b_5 + 448U);
                    FKRay _S1444 = ray_2;
                    FKSurface _S1445 = surface_12;
                    ShadowContext _S1446 = context_5;
                    SkySample _S1447 = sampleSky_0(&_S1444, &_S1445, _S1345, is_inside_6, _S1443, surface_12.random_state, &_S1446);
                    return Shift_x24init_0(throughput_5 * _S1447.color, 1.0f);
                }
                if(_S1442)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1341;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1448 = rgb_to_greyscale(light_3.radiance);
                    bool _S1449 = !(_S1448 > 0.0f);
                    if(_S1449)
                    {
                        return _S1168;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S1182)
                {
                    passes_0 = _S1173 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1309;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S1182)
                {
                    passes_0 = _S1173 == 1U;
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
                    passes_0 = !_S1341;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S1168;
            }
            else
            {
                if(_S1361)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1450 = b_5 > 0U;
                    if(_S1450)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1375)
                        {
                            float3  _S1451 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1451;
                        }
                        else
                        {
                            if(_S1341)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1452 = throughput_5 * emission_1;
                        Reservoir _S1453 = withEnd(candidate_5, 1U, b_5, _S1452);
                        offer(sel_7, _S1453, _S1452 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1454 = throughput_5 * emission_1;
                        float3  _S1455 = sel_7->glow + _S1454;
                        sel_7->glow = _S1455;
                    }
                    if(nee_0)
                    {
                        float3  _S1456 = throughput_5 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1375)
                        {
                            float3  _S1457 = safeDivide(_S1456, chain_throughput_0);
                            (&candidate_6)->radiance = _S1457;
                        }
                        else
                        {
                            if(_S1341)
                            {
                                candidate_6 = here_0;
                                uint _S1458 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1458;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1459 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                                uint _S1460 = insertBits_0(_S1459, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1460;
                            }
                        }
                        Reservoir _S1461 = withEnd(candidate_6, 0U, b_5, _S1456);
                        offer(sel_7, _S1461, _S1456 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1352)
                        {
                            _S1430 = false;
                        }
                        else
                        {
                            bool _S1462 = environmentMapped_0();
                            _S1430 = _S1462;
                        }
                    }
                    else
                    {
                        _S1430 = false;
                    }
                    if(_S1430)
                    {
                        uint _S1463 = (fcptMaxBounces());
                        _S1431 = b_5 < _S1463;
                    }
                    else
                    {
                        _S1431 = false;
                    }
                    if(_S1431)
                    {
                        uint _S1464 = stream(_S1195, b_5 + 448U);
                        FKRay _S1465 = ray_2;
                        FKSurface _S1466 = surface_12;
                        ShadowContext _S1467 = context_5;
                        SkySample _S1468 = sampleSky_0(&_S1465, &_S1466, _S1345, is_inside_6, _S1464, surface_12.random_state, &_S1467);
                        float3  _S1469 = throughput_5 * _S1468.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1375)
                        {
                            float3  _S1470 = safeDivide(_S1469, chain_throughput_0);
                            (&candidate_7)->radiance = _S1470;
                        }
                        else
                        {
                            if(_S1341)
                            {
                                candidate_7 = here_0;
                                uint _S1471 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1471;
                                (&candidate_7)->dir = _S1468.dir;
                                (&candidate_7)->radiance = _S1468.radiance;
                            }
                            else
                            {
                                uint _S1472 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                                uint _S1473 = insertBits_0(_S1472, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1473;
                            }
                        }
                        Reservoir _S1474 = withEnd(candidate_7, 4U, b_5, _S1469);
                        offer(sel_7, _S1474, _S1469 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1475;
        bool _S1476;
        bool _S1477;
        bool straight_0;
        bool _S1478;
        bool _S1479;
        bool _S1480;
        bool _S1481;
        bool _S1482;
        bool _S1483;
        bool _S1484;
        bool _S1485;
        bool _S1486;
        bool _S1487;
        bool _S1488;
        bool _S1489;
        bool _S1490;
        float density_6;
        float sky_pdf_2;
        float spread_4;
        uint b_8;
        float3  throughput_8;
        float3  throughput_9;
        float3  throughput_10;
        if(scatter_2)
        {
            if(replay_1)
            {
                viewed_1 = _S1385;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1491 = extractBits_0(_S1169, 15U, 3U);
            uint _S1492 = extractBits_0(_S1169, 18U, 3U);
            uint _S1493 = _slang_select(_S1384, _S1492,_S1491);
            float3  _S1494 = r_8->dir;
            bool refracted_5 = _S1493 == 1U;
            SampleBSDF _S1495 = SampleBSDF_x24init_0(_S1167, _S1167, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1495;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1496 = extractBits_0(_S1169, 22U, 1U);
                bool _S1497 = is_inside_6 != (_S1496 == 1U);
                if(_S1497)
                {
                    return _S1168;
                }
                bool _S1498 = _S1172 == 1U;
                if(_S1498)
                {
                    float3  _S1499 = (fcptHitPosition((_S1184)));
                    throughput_8 = _S1499;
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
                    BSDFMaterial _S1500 = _S1342.material;
                    bool _S1501 = isTranslucent_0(&_S1500);
                    if(_S1501)
                    {
                        refracted_4 = _S1493 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1502 = throughput_8 - (&ray_2)->origin;
                        float3  _S1503 = _slang_select(_S1498, _S1502,_S1494);
                        wrong_side_0 = (dot_0(_S1343.smooth_n, _S1503) * _S1344) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1498)
                {
                    float3  _S1504 = (&ray_2)->origin;
                    FKSurface _S1505 = surface_12;
                    float3  _S1506 = - _S1343.smooth_n;
                    bool _S1507 = is_inside_6 != refracted_4;
                    float3  _S1508 = _slang_select(_S1507, _S1506,_S1343.smooth_n);
                    float3  _S1509 = throughput_8 - (_S1504 + make_float3 (_S1505.geometry_offset) * _S1508);
                    float3  _S1510 = ((((_S1509)) * make_float3(rnorm3df(((_S1509)).x, ((_S1509)).y, ((_S1509)).z))));
                    reconnection_1 = _S1510;
                }
                else
                {
                    reconnection_1 = _S1494;
                }
                if(_S1352)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1511 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1511;
                }
                if(wrong_side_0)
                {
                    return _S1168;
                }
                float3  _S1512 = throughput_8;
                throughput_8 = reconnection_1;
                b_8 = _S1493;
                wrong_side_0 = false;
                reconnection_1 = _S1512;
            }
            else
            {
                bool _S1513 = !_S1384;
                if(_S1513)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1514;
                    if(_S1352)
                    {
                        SampleBSDF _S1515 = (fcptSampleHair((surface_12.hair), (_S1342.material.albedo), (_S1342.material.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1514 = _S1515;
                    }
                    else
                    {
                        SampleBSDF _S1516 = sampleBSDF((&ray_2)->unit_direction, _S1343.smooth_n, _S1342.material, _S1345.x, _S1345.y, surface_12.random_state, _S1401);
                        _S1514 = _S1516;
                    }
                    bsdf_sampled_0 = _S1514;
                    if(_S1352)
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
                            return _S1168;
                        }
                        break;
                    }
                    if(_S1352)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1517 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1517;
                    }
                    if(wrong_side_0)
                    {
                        _S1430 = (_S1342.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1430 = false;
                    }
                    if(_S1430)
                    {
                        SampleBSDF _S1518 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1342.material, _S1345.x, _S1345.y, (&bsdf_sampled_0)->random_state, _S1401);
                        (&bsdf_sampled_0)->unit_direction = _S1518.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1518.refracted;
                        (&bsdf_sampled_0)->throughput = _S1518.throughput;
                        (&bsdf_sampled_0)->lobe = _S1518.lobe;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1519 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1519;
                        }
                    }
                    uint _S1520 = (&bsdf_sampled_0)->lobe;
                    float3  _S1521 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1522 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1523 = (&bsdf_sampled_0)->pdf;
                    float _S1524 = _slang_select(wrong_side_0, 0.0f,_S1523);
                    (&lobe_5)->pdf = _S1524;
                    throughput_8 = _S1521;
                    b_8 = _S1520;
                    refracted_4 = _S1522;
                }
                else
                {
                    throughput_8 = _S1494;
                    b_8 = _S1493;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1430 = true;
            }
            else
            {
                _S1430 = _S1384;
            }
            float3  chain_throughput_1;
            if(_S1430)
            {
                if(_S1352)
                {
                    SampleBSDF _S1525 = (fcptConnectHair((surface_12.hair), (_S1342.material.albedo), (_S1342.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    lobe_5 = _S1525;
                }
                else
                {
                    float3  _S1526 = (&ray_2)->unit_direction;
                    float _S1527 = sign_0(_S1344);
                    float3  _S1528 = _S1343.smooth_n * make_float3 (_S1527);
                    float _S1529 = dot_0(_S1528, throughput_8);
                    float _S1530 = _S1342.material.roughness;
                    float _S1531 = _S1530 * _S1530;
                    AnisotropicFrame _S1532 = anisotropicFrame(_S1342.material, _S1528);
                    float3  _S1533 = negate_0(_S1526);
                    SheenProfile _S1534 = sheenProfile(_S1533, _S1528, _S1342.material);
                    float3  _S1535 = reflectedHalf(_S1526, throughput_8);
                    bool _S1536 = b_8 == 1U;
                    if(_S1536)
                    {
                        float3  _S1537 = refractedHalf(_S1526, throughput_8, _S1343.smooth_n, _S1345.x, _S1345.y);
                        throughput_9 = _S1537;
                    }
                    else
                    {
                        throughput_9 = _S1535;
                    }
                    bool _S1538 = b_8 == 0U;
                    if(_S1538)
                    {
                        _S1431 = true;
                    }
                    else
                    {
                        _S1431 = b_8 == 6U;
                    }
                    if(_S1431)
                    {
                        float3  _S1539 = sampledHalf(_S1526, _S1343.smooth_n, _S1342.material, surface_12.random_state, _S1532);
                        throughput_10 = _S1539;
                    }
                    else
                    {
                        throughput_10 = throughput_9;
                    }
                    float3  _S1540 = negate_0(_S1526);
                    float _S1541 = _S1345.x;
                    float _S1542 = _S1345.y;
                    BSDFLobes _S1543 = bsdfLobes(_S1526, _S1540, _S1528, throughput_10, _S1342.material, _S1541, _S1542, _S1532, _S1534);
                    BSDFLobes lobe_terms_1 = _S1543;
                    float _S1544 = translucentShare(_S1342.material);
                    (&lobe_terms_1)->translucent_share = _S1544;
                    switch(b_8)
                    {
                    case 0U:
                        {
                            float _S1545 = diffusePDF(_S1529, 0.0f, (F32_abs((_S1344))), _S1531, lobe_terms_1, _S1541, _S1542);
                            float3  _S1546 = diffuseBSDF(throughput_8, _S1528, _S1531, _S1342.material, lobe_terms_1);
                            density_6 = _S1545;
                            chain_throughput_1 = _S1546;
                            break;
                        }
                    case 1U:
                        {
                            float _S1547 = refractPDF(_S1529, dot_0(throughput_8, throughput_10), (F32_abs((_S1344))), _S1531, lobe_terms_1, _S1541, _S1542);
                            float3  _S1548 = refractBSDF(throughput_8, _S1528, _S1531, _S1342.material, lobe_terms_1);
                            density_6 = _S1547;
                            chain_throughput_1 = _S1548;
                            break;
                        }
                    case 4U:
                        {
                            float _S1549 = sheenVelvetPDF(_S1529, 0.0f, (F32_abs((_S1344))), _S1531, lobe_terms_1, _S1541, _S1542);
                            float3  _S1550 = sheenVelvetBSDF(throughput_8, _S1528, _S1531, _S1342.material, lobe_terms_1);
                            density_6 = _S1549;
                            chain_throughput_1 = _S1550;
                            break;
                        }
                    case 6U:
                        {
                            float _S1551 = toonPDF(_S1529, dot_0(throughput_8, (&lobe_terms_1)->toon_axis), (F32_abs((_S1344))), _S1531, lobe_terms_1, _S1541, _S1542);
                            float3  _S1552 = toonBSDF(throughput_8, _S1528, _S1531, _S1342.material, lobe_terms_1);
                            density_6 = _S1551;
                            chain_throughput_1 = _S1552;
                            break;
                        }
                    default:
                        {
                            float _S1553 = reflectPDF(_S1529, 0.0f, (F32_abs((_S1344))), _S1531, lobe_terms_1, _S1541, _S1542);
                            float3  _S1554 = reflectBSDF(throughput_8, _S1528, _S1531, _S1342.material, lobe_terms_1);
                            density_6 = _S1553;
                            chain_throughput_1 = _S1554;
                            break;
                        }
                    }
                    bool _S1555 = density_6 > 0.0f;
                    if(_S1555)
                    {
                        SampleBSDF _S1556 = SampleBSDF_x24init_0(throughput_8, chain_throughput_1, surface_12.random_state, _S1536, b_8, density_6);
                        lobe_5 = _S1556;
                    }
                }
            }
            bool _S1557 = b_8 == 0U;
            if(_S1557)
            {
                _S1431 = true;
            }
            else
            {
                _S1431 = b_8 == 4U;
            }
            if(_S1431)
            {
                _S1475 = true;
            }
            else
            {
                _S1475 = b_8 == 6U;
            }
            if(_S1352)
            {
                _S1476 = false;
            }
            else
            {
                bool _S1558 = !_S1475;
                if(_S1558)
                {
                    bool _S1559 = (_S1342.material.roughness) == 0.0f;
                    if(_S1559)
                    {
                        _S1476 = true;
                    }
                    else
                    {
                        bool _S1560 = b_8 == 1U;
                        if(_S1560)
                        {
                            _S1476 = (_S1345.x) == (_S1345.y);
                        }
                        else
                        {
                            _S1476 = false;
                        }
                    }
                }
                else
                {
                    _S1476 = false;
                }
            }
            bool _S1561 = !_S1352;
            if(_S1561)
            {
                _S1477 = b_8 == 1U;
            }
            else
            {
                _S1477 = false;
            }
            if(_S1477)
            {
                straight_0 = (_S1342.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1478 = _S1561;
            }
            else
            {
                _S1478 = false;
            }
            if(_S1478)
            {
                _S1479 = b_8 == 1U;
            }
            else
            {
                _S1479 = false;
            }
            if(_S1479)
            {
                _S1480 = (_S1345.x) == (_S1345.y);
            }
            else
            {
                _S1480 = false;
            }
            BSDFMaterial _S1562 = _S1342.material;
            bool _S1563 = isTranslucent_0(&_S1562);
            if(_S1563)
            {
                _S1481 = _S1557;
            }
            else
            {
                _S1481 = false;
            }
            if(_S1481)
            {
                _S1482 = (dot_0(throughput_8, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1482 = false;
            }
            if(nee_0)
            {
                _S1483 = !_S1476;
            }
            else
            {
                _S1483 = false;
            }
            if(_S1483)
            {
                _S1484 = !wrong_side_0;
            }
            else
            {
                _S1484 = false;
            }
            if(_S1484)
            {
                float _S1564 = (&lobe_5)->pdf;
                float3  _S1565 = (&ray_2)->origin;
                float3  _S1566 = _slang_select(_S1357, _S1167,_S1343.smooth_n);
                float3  _S1567 = (&ray_2)->origin;
                FKSurface _S1568 = surface_12;
                float3  _S1569 = - _S1343.smooth_n;
                float3  _S1570 = _slang_select(_S1482, _S1569,_S1343.smooth_n);
                NEEVertex _S1571 = NEEVertex_x24init_0(false, _S1564, _S1565, _S1566, _S1567 + make_float3 (_S1568.geometry_offset) * _S1570);
                nee_vertex_0 = _S1571;
            }
            else
            {
                if(_S1352)
                {
                    _S1485 = true;
                }
                else
                {
                    bool _S1572 = b_8 != 1U;
                    if(_S1572)
                    {
                        _S1485 = true;
                    }
                    else
                    {
                        _S1485 = (_S1345.x) != (_S1345.y);
                    }
                }
                if(_S1485)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1573 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1573)
            {
                if(_S1475)
                {
                    _S1485 = true;
                }
                else
                {
                    _S1485 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1485 = false;
            }
            bool _S1574 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1574)
            {
                if(_S1475)
                {
                    _S1486 = true;
                }
                else
                {
                    _S1486 = (_S1342.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1486 = false;
            }
            if(_S1384)
            {
                bool _S1575 = !_S1485;
                if(_S1575)
                {
                    return _S1168;
                }
                bool _S1576 = _S1173 != 1U;
                if(_S1576)
                {
                    _S1487 = _S1173 != 2U;
                }
                else
                {
                    _S1487 = false;
                }
                if(_S1487)
                {
                    float _S1577 = (&lobe_5)->pdf;
                    float _S1578 = _slang_select(nee_0, _S1577,0.0f);
                    float _S1579 = escapeWeight_0(_S1578, _S1494);
                    if(_S1392)
                    {
                        passes_0 = _S1179;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1580 = _slang_select(passes_0, _S1579,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1580) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1581 = throughput_6 * make_float3 ((&lobe_5)->pdf);
                float _S1582 = density_4 * (&lobe_5)->pdf;
                throughput_9 = _S1581;
                density_6 = _S1582;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1583 = (fcptLayers((hit_4)));
            bool _S1584 = _S1583 > 1U;
            if(_S1584)
            {
                _S1487 = (b_8 == 1U) != passes_0;
            }
            else
            {
                _S1487 = false;
            }
            if(viewed_1)
            {
                _S1488 = _S1487;
            }
            else
            {
                _S1488 = false;
            }
            if(_S1488)
            {
                return _S1168;
            }
            if(replay_1)
            {
                _S1489 = b_5 <= _S1183;
            }
            else
            {
                _S1489 = false;
            }
            if(_S1489)
            {
                _S1490 = _S1341;
            }
            else
            {
                _S1490 = false;
            }
            bool _S1585;
            if(_S1490)
            {
                _S1585 = _S1485;
            }
            else
            {
                _S1585 = false;
            }
            bool _S1586;
            if(_S1585)
            {
                _S1586 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1586 = !_S1486;
                }
                else
                {
                    _S1586 = false;
                }
            }
            if(_S1586)
            {
                return _S1168;
            }
            if(viewed_1)
            {
                float3  _S1587 = throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1588 = (&lobe_5)->pdf;
                throughput_10 = _S1587;
                sky_pdf_2 = _S1588;
            }
            else
            {
                float3  _S1589 = throughput_9 * max_0((&lobe_5)->throughput, _S1167);
                throughput_10 = _S1589;
                sky_pdf_2 = density_6;
            }
            bool _S1590;
            if(_S1361)
            {
                _S1590 = !_S1375;
            }
            else
            {
                _S1590 = false;
            }
            bool _S1591;
            if(_S1590)
            {
                _S1591 = _S1341;
            }
            else
            {
                _S1591 = false;
            }
            bool _S1592;
            if(_S1591)
            {
                _S1592 = _S1485;
            }
            else
            {
                _S1592 = false;
            }
            if(_S1592)
            {
                chain_0 = here_0;
                uint _S1593 = insertBits_0((&chain_0)->path, b_8, 18U, 3U);
                uint _S1594 = _slang_select(nee_0, 1U,0U);
                uint _S1595 = insertBits_0(_S1593, _S1594, 21U, 1U);
                (&chain_0)->path = _S1595;
                float _S1596 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1596;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1597 = surface_12;
            Vertex _S1598 = Vertex_x24init_0(_S1486, b_8, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1598;
            float _S1599 = (&lobe_5)->pdf;
            bool _S1600 = b_8 == 1U;
            bool _S1601;
            if(_S1600)
            {
                _S1601 = (_S1345.x) == (_S1345.y);
            }
            else
            {
                _S1601 = false;
            }
            float sky_pdf_3 = _slang_select(_S1601, sky_pdf_0,_S1599);
            float _S1602 = _slang_select(_S1352, 0.0f,sky_pdf_3);
            float _S1603 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1604 = !_S1476;
            float _S1605 = _slang_select(_S1604, _S1603,0.0f);
            float _S1606 = spread_1 + _S1605;
            bool _S1607;
            if(refracted_4)
            {
                _S1607 = !_S1482;
            }
            else
            {
                _S1607 = false;
            }
            bool is_inside_7;
            if(_S1607)
            {
                bool _S1608 = !is_inside_6;
                is_inside_7 = _S1608;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1609 = surface_12;
            bool _S1610 = boundsVolume_0(&_S1609);
            bool _S1611;
            if(_S1610)
            {
                _S1611 = !_S1487;
            }
            else
            {
                _S1611 = false;
            }
            if(_S1611)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1612 = - _S1597.geometry_n;
                float3  _S1613 = _slang_select(turned_1, _S1612,_S1597.geometry_n);
                (&faced_2)->geometry_n = _S1613;
                FKMedium _S1614 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1615 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1616 = faced_2;
                FKMedium _S1617 = _S1614;
                FKMedium _S1618 = _S1615;
                MediumSides _S1619 = mediumSides_0(&_S1616, &_S1617, filling_2, (&ray_2)->unit_direction, &_S1618);
                bool _S1620 = ((dot_0(throughput_8, _S1597.geometry_n)) > 0.0f) == ((dot_0(_S1597.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1621 = _slang_select(_S1620, _S1619.front.scatter,_S1619.behind.scatter);
                scatter_in_0 = _S1621;
                float3  _S1622 = _slang_select(_S1620, _S1619.front.extinction,_S1619.behind.extinction);
                extinction_in_0 = _S1622;
                float _S1623 = _slang_select(_S1620, _S1619.front.g,_S1619.behind.g);
                g_in_0 = _S1623;
                uint _S1624 = _S1619.fillings.x;
                uint _S1625 = _S1619.fillings.y;
                uint _S1626 = _slang_select(_S1620, _S1625,_S1624);
                bool _S1627 = (fcptVaryingUsed());
                uint _S1628 = _slang_select(_S1627, _S1626,4294967295U);
                filling_2 = _S1628;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1629 = !_S1487;
            if(_S1629)
            {
                FKSurface _S1630 = surface_12;
                float _S1631 = _slang_select(straight_0, 0.0f,_S1630.geometry_offset);
                float3  _S1632 = - _S1343.smooth_n;
                bool _S1633 = is_inside_7 != _S1482;
                float3  _S1634 = _slang_select(_S1633, _S1632,_S1343.smooth_n);
                float3  _S1635 = (&ray_2)->origin + make_float3 (_S1631) * _S1634;
                (&ray_2)->origin = _S1635;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1487;
            viewed_1 = _S1480;
            sky_pdf_2 = _S1602;
            spread_4 = _S1606;
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
            spread_4 = spread_1;
            straight_0 = false;
            is_inside_5 = is_inside_6;
        }
        float density_7;
        if(_S1361)
        {
            if(_S1309)
            {
                float3  _S1636 = throughput_9 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1637 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1638 = _S1637 == 1U;
                if(_S1638)
                {
                    float3  _S1639 = safeDivide(_S1636, chain_throughput_0);
                    (&candidate_8)->radiance = _S1639;
                }
                Reservoir _S1640 = withEnd(candidate_8, 2U, b_5, _S1636);
                offer(sel_7, _S1640, _S1636 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1309)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1641 = survivalProbability(throughput_9, density_6);
                density_7 = _S1641;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1642 = stream(_S1195, b_5 + 128U);
            Random _S1643 = pcg(_S1642);
            bool _S1644 = density_7 < (_S1643.value);
            if(_S1644)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1645 = (fcptMaxBounces());
                wrong_side_0 = b_5 >= _S1645;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1646 = density_6 * density_7;
            density_7 = _S1646;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1647 = layer_0 ^ 1U;
        uint _S1648 = _slang_select(passes_0, _S1647,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_4)->distance = 0.0f;
            b_8 = b_5;
            viewed_0 = viewed_1;
            throughput_2 = throughput_9;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_1 = spread_4;
            uint _S1649 = b_8 + 1U;
            b_5 = _S1649;
            layer_0 = _S1648;
            continue;
        }
        FKRay _S1650 = ray_2;
        float _S1651 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S1385;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1172 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1652 = _slang_select(wrong_side_0, _S1651,4.294967296e+09f);
        bool _S1653 = !_S1352;
        if(straight_0)
        {
            _S1430 = true;
        }
        else
        {
            _S1430 = _S1352;
        }
        FKHit _S1654;
        if(_S1430)
        {
            _S1654 = hit_4;
        }
        else
        {
            _S1654 = _S1402;
        }
        FKHit _S1655 = (fcptTraverseInstanceBVH((_S1650), (_S1316), (_S1652), (_S1653), (_S1654), (viewed_1)));
        hit_4 = _S1655;
        if(replay_1)
        {
            _S1431 = _S1385;
        }
        else
        {
            _S1431 = false;
        }
        if(_S1431)
        {
            _S1475 = _S1172 == 1U;
        }
        else
        {
            _S1475 = false;
        }
        if(_S1475)
        {
            _S1476 = ((&hit_4)->instance_index) == (_S1184.instance_index);
        }
        else
        {
            _S1476 = false;
        }
        if(_S1476)
        {
            _S1477 = ((&hit_4)->triangle_index) == (_S1184.triangle_index);
        }
        else
        {
            _S1477 = false;
        }
        if(_S1477)
        {
            (&hit_4)->uv = _S1184.uv;
            float _S1656 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1656;
        }
        if(replay_1)
        {
            _S1478 = _S1385;
        }
        else
        {
            _S1478 = false;
        }
        if(_S1478)
        {
            _S1479 = _S1172 == 3U;
        }
        else
        {
            _S1479 = false;
        }
        if(_S1479)
        {
            _S1480 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1480 = false;
        }
        if(_S1480)
        {
            return _S1168;
        }
        Reservoir _S1657 = chain_0;
        uint _S1658 = filling_2;
        for(;;)
        {
            bool _S1659 = (fcptVaryingUsed());
            if(_S1659)
            {
                _S1481 = _S1658 != 4294967295U;
            }
            else
            {
                _S1481 = false;
            }
            float _S1660;
            if(_S1481)
            {
                float _S1661 = (fcptMajorant((_S1658)));
                _S1660 = _S1661;
            }
            else
            {
                _S1660 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1482 = _S1385;
            }
            else
            {
                _S1482 = false;
            }
            if(_S1482)
            {
                _S1483 = _S1172 == 1U;
            }
            else
            {
                _S1483 = false;
            }
            if(_S1483)
            {
                _S1484 = _S1660 > 0.0f;
            }
            else
            {
                _S1484 = false;
            }
            if(_S1484)
            {
                ended_0 = _S1168;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_4 = width_3;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_8 = b_5;
                _S1485 = true;
                break;
            }
            bool _S1662 = (&prev_0)->rough;
            if(_S1662)
            {
                _S1485 = !(_S1660 > 0.0f);
            }
            else
            {
                _S1485 = false;
            }
            (&prev_0)->rough = _S1485;
            uint _S1663 = b_5 + 320U;
            bool _S1664 = b_5 == 4294967295U;
            uint _S1665 = _slang_select(_S1664, 384U,_S1663);
            uint _S1666 = stream(_S1195, _S1665);
            uint tracking_1 = _S1666;
            weight_1 = throughput_3;
            glowed_0 = _S1167;
            b_8 = b_5;
            throughput_10 = throughput_9;
            density_3 = density_7;
            spread_2 = spread_4;
            width_4 = width_3;
            sky_pdf_1 = sky_pdf_2;
            for(;;)
            {
                if(((&hit_4)->instance_index) != 4294967295U)
                {
                }
                else
                {
                    _S1166 = int(2);
                    break;
                }
                uint _S1667 = b_8 + 320U;
                bool _S1668 = b_8 == 4294967295U;
                uint _S1669 = _slang_select(_S1668, 384U,_S1667);
                uint _S1670 = stream(_S1195, _S1669);
                Random _S1671 = pcg(_S1670);
                float _S1672 = - (F32_log((1.0f - _S1671.value))) / _S1660;
                if(_S1481)
                {
                    float3  _S1673 = (&ray_2)->origin;
                    float3  _S1674 = (&ray_2)->unit_direction;
                    float _S1675 = (&hit_4)->distance;
                    uint _S1676 = _slang_select(_S1668, 0U,b_8);
                    uint _S1677 = (&prev_0)->lobe;
                    uint _S1678 = _slang_select(_S1668, 3U,_S1677);
                    float _S1679 = (fcptTrackMedium((_S1658), (_S1673), (_S1674), (_S1675), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1676), (_S1678), (_S1668)));
                    spread_3 = _S1679;
                }
                else
                {
                    spread_3 = _S1672;
                }
                bool _S1680 = !(spread_3 < ((&hit_4)->distance));
                if(_S1680)
                {
                    _S1166 = int(2);
                    break;
                }
                if(_S1481)
                {
                    _S1486 = _S1361;
                }
                else
                {
                    _S1486 = false;
                }
                if(_S1486)
                {
                    float3  _S1681 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1682 = sel_7->glow + _S1681;
                    sel_7->glow = _S1682;
                }
                else
                {
                }
                glowed_0 = _S1167;
                uint b_9 = b_8 + 1U;
                float3  _S1683 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1683;
                float3  _S1684 = flightWeight_0(scatter_in_0, extinction_in_0, _S1660, spread_3, true);
                float3  _S1685 = weight_1;
                float3  _S1686 = _slang_select(_S1481, _S1685,_S1684);
                float3  throughput_11 = throughput_10 * _S1686;
                uint _S1687 = stream(_S1195, b_9 + 320U);
                tracking_1 = _S1687;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_2 * spread_3;
                float _S1688 = spread_2 + 3.14159274101257324f;
                if(_S1361)
                {
                    _S1487 = true;
                }
                else
                {
                    bool _S1689 = b_9 == _S1183;
                    if(_S1689)
                    {
                        _S1487 = !_S1481;
                    }
                    else
                    {
                        _S1487 = false;
                    }
                }
                TreeSample light_4;
                if(_S1487)
                {
                    float3  _S1690 = (&ray_2)->origin;
                    float3  _S1691 = (&ray_2)->unit_direction;
                    float3  _S1692 = (&ray_2)->unit_direction;
                    uint _S1693 = stream(_S1195, b_9 + 64U);
                    float3  _S1694 = extinction_in_0;
                    float3  _S1695 = extinction_in_0;
                    uint2  _S1696 = make_uint2 (_S1658);
                    float3  _S1697 = (&ray_2)->unit_direction;
                    uint _S1698 = arrivalLobe_0(b_9, (&prev_0)->lobe);
                    FKHit _S1699 = _S1402;
                    ShadowContext _S1700 = ShadowContext_x24init_0(_S1694, _S1695, _S1696, _S1697, b_9, _S1698, false, spread_3, width_7, &_S1699, false);
                    ShadowContext _S1701 = _S1700;
                    TreeSample _S1702 = sampleLightTree_0(_S1690, _S1691, _S1692, 0.0f, true, _S1693, &_S1701);
                    light_4 = _S1702;
                }
                else
                {
                    light_4 = _S1399;
                }
                float _S1703 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1704 = (fcptMaxBounces());
                bool _S1705 = b_9 < _S1704;
                if(_S1705)
                {
                    _S1488 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1488 = false;
                }
                float _S1706 = _slang_select(_S1488, _S1703,0.0f);
                float3  _S1707 = throughput_11 * light_4.radiance;
                float _S1708 = powerHeuristic(light_4.density, _S1706);
                float3  _S1709 = _S1707 * make_float3 (_S1703 * _S1708);
                float3  _S1710 = _slang_select(_S1487, _S1709,_S1167);
                if(replay_1)
                {
                    _S1489 = b_9 == _S1183;
                }
                else
                {
                    _S1489 = false;
                }
                if(_S1489)
                {
                    bool _S1711 = _S1172 == 2U;
                    if(_S1711)
                    {
                        float _S1712 = rgb_to_greyscale(_S1710);
                        _S1490 = _S1712 > 0.0f;
                    }
                    else
                    {
                        _S1490 = false;
                    }
                    if(_S1490)
                    {
                        Shift _S1713 = Shift_x24init_0(_S1710, 1.0f);
                        _S1166 = int(1);
                        ended_0 = _S1713;
                        spread_3 = _S1688;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_6 = b_9;
                        break;
                    }
                    _S1166 = int(1);
                    ended_0 = _S1168;
                    spread_3 = _S1688;
                    width_5 = width_7;
                    throughput_8 = throughput_11;
                    b_6 = b_9;
                    break;
                }
                if(_S1361)
                {
                    Reservoir candidate_9 = _S1657;
                    uint _S1714 = extractBits_0(_S1657.path, 10U, 2U);
                    bool _S1715 = _S1714 == 1U;
                    if(_S1715)
                    {
                        float3  _S1716 = safeDivide(_S1710, chain_throughput_0);
                        (&candidate_9)->radiance = _S1716;
                    }
                    else
                    {
                        uint _S1717 = insertBits_0(0U, b_9 + 1U, 5U, 5U);
                        uint _S1718 = insertBits_0(_S1717, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1718;
                    }
                    Reservoir _S1719 = withEnd(candidate_9, 0U, b_9, _S1710);
                    offer(sel_7, _S1719, _S1710 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1720 = survivalProbability(throughput_11, density_3);
                    uint _S1721 = stream(_S1195, b_9 + 128U);
                    Random _S1722 = pcg(_S1721);
                    bool _S1723 = _S1720 < (_S1722.value);
                    if(_S1723)
                    {
                        _S1490 = true;
                    }
                    else
                    {
                        uint _S1724 = (fcptMaxBounces());
                        _S1490 = b_9 >= _S1724;
                    }
                    if(_S1490)
                    {
                        _S1166 = int(1);
                        ended_0 = _S1168;
                        spread_3 = _S1688;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_6 = b_9;
                        break;
                    }
                    float _S1725 = density_3 * _S1720;
                    density_3 = _S1725;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1726 = stream(_S1195, b_9);
                float3  _S1727 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1726, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1727;
                NEEVertex _S1728 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1167, (&ray_2)->origin);
                nee_vertex_0 = _S1728;
                Vertex _S1729 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
                prev_0 = _S1729;
                float _S1730 = (&prev_0)->pdf;
                FKRay _S1731 = ray_2;
                FKHit _S1732 = (fcptTraverseInstanceBVH((_S1731), (true), (4.294967296e+09f), (false), (_S1402), (false)));
                hit_4 = _S1732;
                b_8 = b_9;
                throughput_10 = throughput_11;
                spread_2 = _S1688;
                width_4 = width_7;
                sky_pdf_1 = _S1730;
            }
            if(_S1166 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_10 = throughput_8;
                b_8 = b_6;
                _S1485 = true;
                break;
            }
            ended_0 = _S1168;
            _S1485 = false;
            break;
        }
        if(_S1485)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1486 = b_8 == b_5;
        }
        else
        {
            _S1486 = false;
        }
        bool _S1733 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1733)
        {
            bool _S1734 = !(&nee_vertex_0)->none;
            float _S1735 = _slang_select(_S1734, sky_pdf_1,0.0f);
            float _S1736 = escapeWeight_0(_S1735, (&ray_2)->unit_direction);
            float3  _S1737 = environment_0((&ray_2)->unit_direction, b_8, (&prev_0)->lobe);
            float3  _S1738 = throughput_10 * _S1737;
            if(replay_1)
            {
                bool _S1739 = b_8 == _S1183;
                if(_S1739)
                {
                    passes_0 = _S1172 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1738 * make_float3 (_S1736) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1182)
                {
                    passes_0 = _S1179;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_8 == _S1170;
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
                    return Shift_x24init_0(_S1738 * make_float3 (_S1736), 1.0f);
                }
                return _S1168;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1740 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1741 = _S1740 == 1U;
            if(_S1741)
            {
                uint _S1742 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1743 = _S1742 == b_8;
                float _S1744 = _slang_select(_S1743, 1.0f,_S1736);
                float3  _S1745 = safeDivide(_S1738 * make_float3 (_S1744), chain_throughput_0);
                (&candidate_10)->radiance = _S1745;
            }
            else
            {
                bool _S1746 = (&prev_0)->rough;
                if(_S1746)
                {
                    uint _S1747 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                    uint _S1748 = insertBits_0(_S1747, 3U, 10U, 2U);
                    uint _S1749 = insertBits_0(_S1748, (&prev_0)->lobe, 15U, 3U);
                    bool _S1750 = (&prev_0)->inside;
                    uint _S1751 = _slang_select(_S1750, 1U,0U);
                    uint _S1752 = insertBits_0(_S1749, _S1751, 22U, 1U);
                    (&candidate_10)->path = _S1752;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1753 = _S1738 * make_float3 (_S1736);
            Reservoir _S1754 = withEnd(candidate_10, 3U, b_8, _S1753);
            offer(sel_7, _S1754, _S1753 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1755 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1755;
        bool _S1756 = (fcptVaryingUsed());
        if(_S1756)
        {
            _S1487 = filling_2 != 4294967295U;
        }
        else
        {
            _S1487 = false;
        }
        if(_S1487)
        {
            if(_S1361)
            {
                float3  _S1757 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1758 = sel_7->glow + _S1757;
                sel_7->glow = _S1758;
            }
            float3  _S1759 = throughput_10 * weight_1;
            throughput_8 = _S1759;
        }
        else
        {
            float3  _S1760 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1761 = throughput_10 * _S1760;
            throughput_8 = _S1761;
        }
        float _S1762 = width_4 + spread_2 * (&hit_4)->distance;
        viewed_0 = _S1486;
        width_3 = _S1762;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1649 = b_8 + 1U;
        b_5 = _S1649;
        layer_0 = _S1648;
    }
    return _S1168;
}

__device__ static const FixedArray<float, 4>  HAIR_TILTS_0 = { {
    -2.0f, 1.0f, 4.0f, 0.0f
} };
__device__ static const FixedArray<float, 4>  HAIR_WIDTHS_0 = { {
    1.0f, 0.5f, 2.0f, 2.0f
} };
static __device__ float3  clamp_2(float3  x_25, float3  minBound_2, float3  maxBound_2)
{
    return min_1(max_0(x_25, minBound_2), maxBound_2);
}

static __device__ float3  tan_0(float3  x_26)
{
    float3  result_14;
    int i_26 = int(0);
    for(;;)
    {
        if(i_26 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_14, i_26) = (F32_tan((_slang_vector_get_element(x_26, i_26))));
        i_26 = i_26 + int(1);
    }
    return result_14;
}

static __device__ float3  acos_0(float3  x_27)
{
    float3  result_15;
    int i_27 = int(0);
    for(;;)
    {
        if(i_27 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_15, i_27) = (F32_acos((_slang_vector_get_element(x_27, i_27))));
        i_27 = i_27 + int(1);
    }
    return result_15;
}

static __device__ float3  abs_0(float3  x_28)
{
    float3  result_16;
    int i_28 = int(0);
    for(;;)
    {
        if(i_28 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_16, i_28) = (F32_abs((_slang_vector_get_element(x_28, i_28))));
        i_28 = i_28 + int(1);
    }
    return result_16;
}

__device__ Random normal_distribution(uint state_3)
{
    Random _S1763 = pcg(state_3);
    Random _S1764 = pcg(_S1763.state);
    float _S1765 = 6.28318548202514648f * _S1763.value;
    float _S1766 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1764.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1764.state, _S1766 * (F32_cos((_S1765))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1767;
    (&_S1767)->state = state_4;
    (&_S1767)->value = value_2;
    return _S1767;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1768 = normal_distribution(state_5);
    Random _S1769 = normal_distribution(_S1768.state);
    Random _S1770 = normal_distribution(_S1769.state);
    float3  _S1771 = make_float3 (_S1768.value, _S1769.value, _S1770.value);
    float3  _S1772 = ((((_S1771)) * make_float3(rnorm3df(((_S1771)).x, ((_S1771)).y, ((_S1771)).z))));
    return RandomSphere_x24init_0(_S1770.state, _S1772);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_12)
{
    float3  _S1773 = p1_0 - p0_0;
    float3  _S1774 = p2_0 - p0_0;
    float2  _S1775 = uv1_0 - uv0_0;
    float2  _S1776 = uv2_0 - uv0_0;
    float _S1777 = _S1775.x;
    float _S1778 = _S1776.y;
    float _S1779 = _S1775.y;
    float _S1780 = _S1776.x;
    float _S1781 = _S1777 * _S1778 - _S1779 * _S1780;
    float _S1782 = 1.0f / _S1781;
    float3  t_22 = (_S1773 * make_float3 (_S1778) - _S1774 * make_float3 (_S1779)) * make_float3 (_S1782);
    float3  _S1783 = (_S1774 * make_float3 (_S1777) - _S1773 * make_float3 (_S1780)) * make_float3 (_S1782);
    float3  _S1784 = t_22 - n_12 * make_float3 (dot_0(n_12, t_22));
    float3  _S1785 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_12);
    bool _S1786 = (dot_0(_S1784, _S1784)) > 0.0f;
    float3  _S1787 = _slang_select(_S1786, _S1784,_S1785);
    float3  _S1788 = ((((_S1787)) * make_float3(rnorm3df(((_S1787)).x, ((_S1787)).y, ((_S1787)).z))));
    bool _S1789 = (dot_0(cross_0(n_12, _S1788), _S1783)) > 0.0f;
    float3  t_23;
    if(_S1789)
    {
        float3  _S1790 = negate_0(_S1788);
        t_23 = _S1790;
    }
    else
    {
        t_23 = _S1788;
    }
    float3  _S1791 = cross_0(n_12, t_23);
    return makeMatrix<float, 3, 3> (t_23, _S1791, n_12);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_0)
{
    float3  _S1792 = t1_0 - t0_0;
    float3  _S1793 = t2_2 - t0_0;
    float3  _S1794 = t2_2 - t1_0;
    float _S1795 = (F32_min((length_0(_S1792)), ((F32_min((length_0(_S1793)), (length_0(_S1794)))))));
    float3  _S1796 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1797 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1798 = dot_0(geometry_n_4, _S1797);
    float3  _S1799 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1800 = dot_0(geometry_n_4, _S1799);
    float3  _S1801 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1802 = acos_0(abs_0(make_float3 (_S1798, _S1800, dot_0(geometry_n_4, _S1801))));
    float3  _S1803 = clamp_2(tan_0(_S1802), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1796 * _S1803, uvw_0), 0.0f, _S1795 * 0.125f);
}

__device__ float3  straightThrough(BSDFMaterial material_23)
{
    return make_float3 (material_23.transmission * (1.0f - material_23.metallic)) * material_23.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_24, float3  out_dir_3, uint p_12, float w_2, float alpha_20, uint nt_0)
{
    uint _S1804 = p_12 % 4U;
    float _S1805 = w_2 * HAIR_WIDTHS_0[_S1804];
    float _S1806 = (F32_asin((clamp_1(dot_0(out_dir_3, t_24), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_24), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1804] * alpha_20;
    return ((F32_asinh((_S1806 / _S1805))) / (F32_asinh((3.14159274101257324f / _S1805))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_25, float3  out_dir_4, uint np_0)
{
    float3  _S1807 = worldToTangent(out_dir_4, t_25);
    float3  _S1808 = worldToTangent(in_dir_12, t_25);
    return (F32_frac((((F32_atan2((_S1807.z), (_S1807.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1808.z), (1.17549435082228751e-38f - _S1808.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_26, uint p_13, float row_0, float column_0, float w_3, float alpha_21, uint nt_1, uint np_1)
{
    float3  _S1809 = worldToTangent(in_dir_13, t_26);
    uint _S1810 = p_13 % 4U;
    float _S1811 = w_3 * HAIR_WIDTHS_0[_S1810];
    float _S1812 = (F32_asin((clamp_1(dot_0(in_dir_13, t_26), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1810] * alpha_21 + _S1811 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1811))))));
    float _S1813 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1809.z), (1.17549435082228751e-38f - _S1809.x)));
    float _S1814 = (F32_cos((_S1812)));
    float3  _S1815 = tangentToWorld(make_float3 (_S1814 * (F32_cos((_S1813))), (F32_sin((_S1812))), _S1814 * (F32_sin((_S1813)))), t_26);
    return _S1815;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_13, BSDFMaterial material_24, float coverage_1)
{
    float3  _S1816;
    if((material_24.ior) == 1.0f)
    {
        float3  _S1817 = straightThrough(material_24);
        _S1816 = _S1817;
    }
    else
    {
        _S1816 = make_float3 (0.0f);
    }
    return _S1816 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_8, Reservoir r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    Domain _S1818 = dom_8;
    Reservoir _S1819 = r_9;
    Shift _S1820 = walk_0(&_S1818, &_S1819, replay_2, scale_4, sel_8);
    return _S1820;
}

__device__ void restir_initial_hook(uint3  global_invocation_id_9)
{
    restir_initial_0(global_invocation_id_9);
    return;
}

__device__ void restir_temporal_hook(uint3  global_invocation_id_10)
{
    restir_temporal_0(global_invocation_id_10);
    return;
}

__device__ void restir_temporal_count_hook(uint3  global_invocation_id_11, uint local_invocation_index_10)
{
    restir_temporal_count_0(global_invocation_id_11, local_invocation_index_10);
    return;
}

__device__ void restir_temporal_prepass_hook(uint3  global_invocation_id_12, uint local_invocation_index_11)
{
    restir_temporal_prepass_0(global_invocation_id_12, local_invocation_index_11);
    return;
}

__device__ void restir_temporal_shift_hook(uint3  workgroup_id_3, uint local_invocation_index_12)
{
    restir_temporal_shift_0(workgroup_id_3, local_invocation_index_12);
    return;
}

__device__ void restir_count_hook(uint3  global_invocation_id_13, uint local_invocation_index_13)
{
    restir_count_0(global_invocation_id_13, local_invocation_index_13);
    return;
}

__device__ void restir_prepass_hook(uint3  global_invocation_id_14, uint local_invocation_index_14)
{
    restir_prepass_0(global_invocation_id_14, local_invocation_index_14);
    return;
}

__device__ void restir_shift_hook(uint3  workgroup_id_4, uint local_invocation_index_15)
{
    restir_shift_0(workgroup_id_4, local_invocation_index_15);
    return;
}

__device__ void restir_spatial_hook(uint3  global_invocation_id_15)
{
    restir_spatial_0(global_invocation_id_15);
    return;
}

__device__ void restir_duplicates_hook(uint3  global_invocation_id_16, uint3  local_invocation_id_1, uint local_invocation_index_16)
{
    restir_duplicates_0(global_invocation_id_16, local_invocation_id_1, local_invocation_index_16);
    return;
}

#undef Matrix
