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
        bool _S41 = (fcptStoredDomainInitial((_S35), ((&job_0->r)->seed), (&job_0->dom)));
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

static __device__ uint queuedShift_0(uint3  workgroup_id_0, uint local_invocation_index_0)
{
    uint _S60 = workgroup_id_0.y * 65535U + workgroup_id_0.x;
    uint bin_0 = 0U;
    uint group_0 = _S60;
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
        uint _S61 = (fcptQueuedShifts((3U + bin_0)));
        uint _S62 = (_S61 + 63U) / 64U;
        bool _S63 = group_0 < _S62;
        if(_S63)
        {
            uint _S64 = group_0 * 64U + local_invocation_index_0;
            bool _S65 = _S64 < _S61;
            if(_S65)
            {
                uint _S66 = (fcptQueuedShifts((83U + start_0 + _S64)));
                return _S66;
            }
            return 4294967295U;
        }
        uint group_1 = group_0 - _S62;
        uint start_1 = start_0 + _S61;
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
        uint _S67 = (*bins_1)[t_4];
        bool _S68 = ((*bins_1)[t_4]) < 40U;
        if(_S68)
        {
            bin_2 = 0U;
            start_2 = 0U;
            for(;;)
            {
                if(bin_2 < _S67)
                {
                }
                else
                {
                    break;
                }
                uint _S69 = (fcptQueueCountLoad((bin_2)));
                uint start_3 = start_2 + _S69;
                uint bin_3 = bin_2 + 1U;
                bin_2 = bin_3;
                start_2 = start_3;
            }
            uint _S70 = (fcptQueueCursorAdd((_S67), (1U)));
            fcptQueueJobStore((start_2 + _S70), ((uint(p_3.x) | (uint(p_3.y) << 14U)) | (t_4 << 28U)));
        }
        uint t_5 = t_4 + 1U;
        t_4 = t_5;
    }
    bool _S71 = all_0(uint2 {global_invocation_id_0.x, global_invocation_id_0.y} == make_uint2 (0U));
    if(_S71)
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
            uint _S72 = (fcptQueueCountLoad((bin_2)));
            uint groups_0 = start_2 + (_S72 + 63U) / 64U;
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
    FKHit _S73;
    (&_S73)->uv = uv_0;
    (&_S73)->instance_index = instance_index_0;
    (&_S73)->triangle_index = triangle_index_0;
    (&_S73)->is_point_light = is_point_light_0;
    (&_S73)->distance = distance_0;
    return _S73;
}

static __device__ Domain Domain_x24init_0(float3  x0_0, float3  x1_0, FKHit * hit_0, float width_0, float spread_0)
{
    Domain _S74;
    (&_S74)->x0 = x0_0;
    (&_S74)->x1 = x1_0;
    (&_S74)->hit = *hit_0;
    (&_S74)->width = width_0;
    (&_S74)->spread = spread_0;
    return _S74;
}

static __device__ bool previousValid_0(int2  q_1)
{
    bool _S75 = all_0(q_1 >= make_int2 (int(0)));
    bool _S76;
    if(_S75)
    {
        uint2  _S77 = (fcptRenderSize());
        int2  _S78 = make_int2 ((int)_S77.x, (int)_S77.y);
        _S76 = all_0(q_1 < _S78);
    }
    else
    {
        _S76 = false;
    }
    if(_S76)
    {
        uint4  _S79 = (fcptReservoirPrevious((q_1), (0U)));
        _S76 = (U32_asfloat((_S79.w))) > 0.0f;
    }
    else
    {
        _S76 = false;
    }
    return _S76;
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
    bool _S80 = all_1((a_0->x0) == (b_0->x0));
    bool _S81;
    if(_S80)
    {
        _S81 = ((&a_0->hit)->instance_index) == ((&b_0->hit)->instance_index);
    }
    else
    {
        _S81 = false;
    }
    if(_S81)
    {
        _S81 = ((&a_0->hit)->triangle_index) == ((&b_0->hit)->triangle_index);
    }
    else
    {
        _S81 = false;
    }
    if(_S81)
    {
        _S81 = all_0(((&a_0->hit)->uv) == ((&b_0->hit)->uv));
    }
    else
    {
        _S81 = false;
    }
    return _S81;
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

static __device__ int2  temporalNeighbor_0(int2  p_4, Domain * dom_0, uint seed_1)
{
    bool _S82 = previousValid_0(p_4);
    bool _S83;
    if(_S82)
    {
        Domain _S84 = (fcptPreviousDomain((p_4), (seed_1)));
        Domain _S85 = _S84;
        bool _S86 = sameDomain_0(&_S85, dom_0);
        _S83 = _S86;
    }
    else
    {
        _S83 = false;
    }
    if(_S83)
    {
        return p_4;
    }
    uint _S87 = (&dom_0->hit)->instance_index;
    bool _S88 = ((&dom_0->hit)->instance_index) == 4294967295U;
    if(_S88)
    {
        return make_int2 (int(-1));
    }
    float3  _S89 = dom_0->x1;
    float2  _S90 = (fcptPixelOf((dom_0->x1), (true)));
    float2  _S91 = floor_0(_S90);
    int2  _S92 = make_int2 ((int)_S91.x, (int)_S91.y);
    bool _S93 = previousValid_0(_S92);
    bool _S94 = !_S93;
    if(_S94)
    {
        return make_int2 (int(-1));
    }
    uint4  _S95 = (fcptReservoirPrevious((_S92), (0U)));
    Domain _S96 = (fcptPreviousDomain((_S92), (_S95.x)));
    bool _S97 = (_S96.hit.instance_index) == _S87;
    if(_S97)
    {
        float _S98 = distance_1(_S96.x1, _S89);
        float _S99 = (&dom_0->hit)->distance * 8.0f;
        uint2  _S100 = (fcptRenderSize());
        _S83 = _S98 <= (_S99 / float(_S100.x));
    }
    else
    {
        _S83 = false;
    }
    if(_S83)
    {
        return _S92;
    }
    int2  _S101 = p_4 + _S92;
    float2  _S102 = make_float2 ((float)_S101.x, (float)_S101.y);
    float2  _S103 = _S102 + make_float2 (1.0f);
    float2  _S104 = (fcptPixelOf((_S96.x1), (false)));
    float2  _S105 = floor_0(_S103 - _S104);
    int2  _S106 = make_int2 ((int)_S105.x, (int)_S105.y);
    int2  _S107 = make_int2 (int(-1));
    bool _S108 = previousValid_0(_S106);
    int2  _S109 = _slang_select(_S108, _S106,_S107);
    return _S109;
}

static __device__ bool temporalIdentity_0(uint t_6, Domain * source_0, Domain * target_1)
{
    bool _S110 = sameDomain_0(source_0, target_1);
    bool _S111;
    if(_S110)
    {
        bool _S112 = (fcptSceneUnchanged());
        if(_S112)
        {
            _S111 = true;
        }
        else
        {
            bool _S113 = t_6 == 1U;
            if(_S113)
            {
                bool _S114 = (fcptPreviousScenes());
                _S111 = !_S114;
            }
            else
            {
                _S111 = false;
            }
        }
    }
    else
    {
        _S111 = false;
    }
    return _S111;
}

static __device__ bool temporalJob_0(int2  p_5, uint t_7, ShiftJob * job_2, bool target_2)
{
    Reservoir _S115 = (fcptLoadReservoirInitial((p_5)));
    float3  _S116 = make_float3 (0.0f);
    FKHit _S117 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S118 = Domain_x24init_0(_S116, _S116, &_S117, 0.0f, 0.0f);
    Domain dom_1 = _S118;
    bool _S119 = t_7 > 1U;
    bool _S120;
    if(_S119)
    {
        _S120 = true;
    }
    else
    {
        bool _S121 = (fcptStoredDomainInitial((p_5), (_S115.seed), (&dom_1)));
        _S120 = !_S121;
    }
    if(_S120)
    {
        return false;
    }
    Domain _S122 = dom_1;
    int2  _S123 = temporalNeighbor_0(p_5, &_S122, _S115.seed);
    bool _S124 = (_S123.x) < int(0);
    if(_S124)
    {
        return false;
    }
    bool _S125 = t_7 == 0U;
    if(_S125)
    {
        Reservoir _S126 = (fcptLoadReservoirPrevious((_S123)));
        job_2->r = _S126;
        bool _S127 = !target_2;
        if(_S127)
        {
            bool _S128 = (fcptSceneUnchanged());
            _S120 = !_S128;
        }
        else
        {
            _S120 = false;
        }
        if(_S120)
        {
            return ((&job_2->r)->w) > 0.0f;
        }
        bool _S129 = ((&job_2->r)->w) > 0.0f;
        if(_S129)
        {
            bool _S130 = (fcptStoredDomainInitial((p_5), ((&job_2->r)->seed), (&job_2->dom)));
            _S120 = _S130;
        }
        else
        {
            _S120 = false;
        }
        if(_S120)
        {
            Domain _S131 = (fcptPreviousDomain((_S123), ((&job_2->r)->seed)));
            Domain _S132 = _S131;
            Domain _S133 = job_2->dom;
            bool _S134 = temporalIdentity_0(0U, &_S132, &_S133);
            _S120 = !_S134;
        }
        else
        {
            _S120 = false;
        }
        return _S120;
    }
    job_2->r = _S115;
    bool _S135 = !target_2;
    if(_S135)
    {
        bool _S136 = (fcptSceneUnchanged());
        _S120 = !_S136;
    }
    else
    {
        _S120 = false;
    }
    if(_S120)
    {
        bool _S137 = (fcptPreviousScenes());
        _S120 = _S137;
    }
    else
    {
        _S120 = false;
    }
    if(_S120)
    {
        return ((&job_2->r)->w) > 0.0f;
    }
    Domain _S138 = (fcptPreviousDomain((_S123), (_S115.seed)));
    job_2->dom = _S138;
    bool _S139 = ((&job_2->r)->w) > 0.0f;
    if(_S139)
    {
        Domain _S140 = job_2->dom;
        Domain _S141 = dom_1;
        bool _S142 = temporalIdentity_0(1U, &_S140, &_S141);
        _S120 = !_S142;
    }
    else
    {
        _S120 = false;
    }
    return _S120;
}

static __device__ void temporalBins_0(int2  p_6, FixedArray<uint, 3>  * _S143)
{
    FixedArray<uint, 3>  _S144 = { {
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
        ShiftJob _S145 = (ShiftJob{});
        ShiftJob job_3 = _S145;
        bool _S146 = temporalJob_0(p_6, t_8, &job_3, false);
        if(_S146)
        {
            Reservoir _S147 = (&job_3)->r;
            uint _S148 = shiftBin_0(&_S147);
            bins_2[t_8] = _S148;
        }
        uint t_9 = t_8 + 1U;
        t_8 = t_9;
    }
    *_S143 = bins_2;
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
        uint _S149 = (*bins_3)[t_10];
        bool _S150 = ((*bins_3)[t_10]) < 40U;
        if(_S150)
        {
            uint _S151 = (fcptQueueCountAdd((_S149), (1U)));
        }
        uint t_11 = t_10 + 1U;
        t_10 = t_11;
    }
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

static __device__ Shift passWalk_0(Domain * dom_2, Reservoir * r_1, bool replay_0, float scale_0, Selection * sel_0)
{
    Shift _S152 = (fcptWalk((*dom_2), (*r_1), (replay_0), (scale_0), (sel_0)));
    return _S152;
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
    FKRay _S153;
    (&_S153)->origin = origin_0;
    (&_S153)->unit_direction = unit_direction_0;
    return _S153;
}

static __device__ float3  skyRadiance_0(float3  origin_1, FKSurface * surface_0, bool is_inside_1, float3  dir_1, ShadowContext * context_0, uint random_state_0)
{
    bool _S154 = wrongSide_0(is_inside_1, false, dir_1, surface_0->geometry_n);
    bool _S155 = is_inside_1 != _S154;
    float _S156 = surface_0->geometry_offset;
    float3  _S157 = surface_0->smooth_n;
    float3  _S158 = - surface_0->smooth_n;
    float3  _S159 = _slang_select(_S155, _S158,_S157);
    FKRay _S160 = Ray_x24init_0(origin_1 + make_float3 (_S156) * _S159, dir_1);
    bool _S161 = (dot_0(context_0->side, dir_1)) > 0.0f;
    float3  _S162 = (fcptEnvMapSample((dir_1), (0U), (3U)));
    float3  _S163 = context_0->extinction_behind;
    float3  _S164 = context_0->extinction_front;
    float3  _S165 = _slang_select(_S161, _S164,_S163);
    uint _S166 = context_0->fillings.x;
    uint _S167 = context_0->fillings.y;
    uint _S168 = _slang_select(_S161, _S167,_S166);
    uint _S169 = context_0->depth;
    uint _S170 = context_0->lobe;
    bool _S171 = context_0->surface;
    bool _S172;
    if(_S171)
    {
        _S172 = !context_0->fiber;
    }
    else
    {
        _S172 = false;
    }
    float _S173 = context_0->length;
    float _S174 = context_0->width;
    FKHit _S175 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    float3  _S176 = (fcptShadowTransmittanceIn((_S160), (4.294967296e+09f), (_S165), (_S168), (random_state_0), (_S169), (_S170), (_S172), (_S173), (_S174), (_S175), (_S175)));
    return _S162 * _S176;
}

static __device__ uint searchCDF_0(uint2  start_4, uint2  step_0, uint count_1, float u_0)
{
    uint _S177 = count_1 - 1U;
    uint low_0 = 0U;
    uint high_0 = _S177;
    for(;;)
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        uint _S178 = (low_0 + high_0) / 2U;
        float4  _S179 = (fcptEnvironmentCdf((start_4 + step_0 * make_uint2 (_S178))));
        bool _S180 = (_S179.x) > u_0;
        if(_S180)
        {
            high_0 = _S178;
        }
        else
        {
            uint _S181 = _S178 + 1U;
            low_0 = _S181;
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
    float3  _S182 = ((((light_dir_0)) * make_float3(rnorm3df(((light_dir_0)).x, ((light_dir_0)).y, ((light_dir_0)).z))));
    bool _S183 = (dot_0(smooth_n_0, _S182)) < 0.0f;
    if(_S183)
    {
        return make_float3 (0.0f);
    }
    float3  _S184 = make_float3 (geometry_offset_0) * smooth_n_0;
    float3  _S185 = origin_2 + _S184;
    FKRay _S186 = Ray_x24init_0(_S185, _S182);
    bool _S187 = (dot_0(context_1->side, light_dir_0 + _S184)) > 0.0f;
    float _S188 = shadowLength(light_dir_0);
    float3  _S189 = context_1->extinction_behind;
    float3  _S190 = context_1->extinction_front;
    float3  _S191 = _slang_select(_S187, _S190,_S189);
    uint _S192 = context_1->fillings.x;
    uint _S193 = context_1->fillings.y;
    uint _S194 = _slang_select(_S187, _S193,_S192);
    uint _S195 = context_1->depth;
    uint _S196 = context_1->lobe;
    bool _S197 = context_1->surface;
    bool _S198;
    if(_S197)
    {
        _S198 = !context_1->fiber;
    }
    else
    {
        _S198 = false;
    }
    float _S199 = context_1->length;
    float _S200 = context_1->width;
    FKHit _S201;
    if(context_1->fiber)
    {
        _S201 = context_1->own;
    }
    else
    {
        _S201 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    }
    float3  _S202 = (fcptShadowTransmittanceIn((_S186), (_S188), (_S191), (_S194), (random_state_1), (_S195), (_S196), (_S198), (_S199), (_S200), (_S201), (*light_0)));
    return _S202;
}

__device__ float sine(float c_0)
{
    return (F32_sqrt(((F32_max((1.0f - c_0 * c_0), (0.0f))))));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S203 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S204 = cos_a_0 > cos_b_0;
    float _S205 = _slang_select(_S204, 1.0f,_S203);
    return _S205;
}

__device__ float sinSubClamped(float sin_a_1, float cos_a_1, float sin_b_1, float cos_b_1)
{
    float _S206 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    bool _S207 = cos_a_1 > cos_b_1;
    float _S208 = _slang_select(_S207, 0.0f,_S206);
    return _S208;
}

__device__ float importance(LightNode node_0, float3  p_7, float3  normal_0)
{
    float3  _S209 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S210 = node_0.high - node_0.low;
    float3  _S211 = p_7 - _S209;
    float3  _S212 = ((((_S211)) * make_float3(rnorm3df(((_S211)).x, ((_S211)).y, ((_S211)).z))));
    float _S213 = dot_0(_S211, _S211);
    float _S214 = dot_0(_S210, _S210) / 4.0f;
    float _S215 = (F32_abs((dot_0(node_0.w, _S212))));
    float _S216 = sine(node_0.cos_theta_o);
    float _S217 = (F32_sqrt(((F32_max((1.0f - _S214 / _S213), (0.0f))))));
    bool _S218 = _S213 < _S214;
    float _S219 = _slang_select(_S218, -1.0f,_S217);
    float _S220 = sine(_S219);
    float _S221 = sine(_S215);
    float _S222 = cosSubClamped(_S221, _S215, _S216, node_0.cos_theta_o);
    float _S223 = sine(_S215);
    float _S224 = sinSubClamped(_S223, _S215, _S216, node_0.cos_theta_o);
    float _S225 = cosSubClamped(_S224, _S222, _S220, _S219);
    bool _S226 = _S225 <= 0.0f;
    if(_S226)
    {
        return 0.0f;
    }
    float _S227 = - dot_0(_S212, normal_0);
    float _S228 = node_0.phi * _S225 / (F32_max((_S213), (length_0(_S210) / 2.0f)));
    float _S229 = sine(_S227);
    float _S230 = cosSubClamped(_S229, _S227, _S220, _S219);
    bool _S231 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S232 = _slang_select(_S231, 1.0f,_S230);
    return (F32_max((_S228 * _S232), (0.0f)));
}

__device__ __forceinline__ float childShare(LightNode first_0, LightNode second_0, float3  p_8, float3  normal_1, uint child_0)
{
    float _S233 = importance(first_0, p_8, normal_1);
    float _S234 = importance(second_0, p_8, normal_1);
    float2  _S235 = make_float2 (_S233, _S234);
    float _S236 = _slang_vector_get_element(_S235, child_0) / (_S233 + _S234);
    bool _S237 = _slang_vector_get_element(_S235, child_0) > 0.0f;
    float _S238 = _slang_select(_S237, _S236,0.0f);
    return _S238;
}

__device__ float sphereDensity(float3  center_0, float radius_0, float3  p_9)
{
    float3  _S239 = center_0 - p_9;
    float _S240 = radius_0 * radius_0 / dot_0(_S239, _S239);
    bool _S241 = _S240 >= 1.0f;
    if(_S241)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S240)))) / (6.28318548202514648f * _S240);
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S242 = left_0.y;
    float _S243 = right_0.z;
    float _S244 = left_0.z;
    float _S245 = right_0.y;
    float _S246 = right_0.x;
    float _S247 = left_0.x;
    return make_float3 (_S242 * _S243 - _S244 * _S245, _S244 * _S246 - _S247 * _S243, _S247 * _S245 - _S242 * _S246);
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_0))));
}

static __device__ float lightPdf_0(float3  origin_3, float3  smooth_n_1, float3  start_5, uint j_0, float3  light_point_0)
{
    bool _S248 = j_0 == 4294967295U;
    if(_S248)
    {
        return 0.0f;
    }
    uint4  _S249 = (fcptLightTrail((j_0)));
    uint2  _S250 = uint2 {_S249.x, _S249.y};
    uint n_0 = 0U;
    uint2  trail_0 = _S250;
    float probability_1 = 1.0f;
    for(;;)
    {
        uint4  _S251 = (fcptLightNode((n_0)));
        if((_S251.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S252 = (fcptLightSecond((n_0)));
        uint _S253 = n_0 + 1U;
        LightNode _S254 = (fcptLightBounds((_S253)));
        LightNode _S255 = (fcptLightBounds((_S252)));
        uint _S256 = trail_0.x;
        uint _S257 = _S256 & 1U;
        float _S258 = childShare(_S254, _S255, origin_3, smooth_n_1, _S257);
        float probability_2 = probability_1 * _S258;
        bool _S259 = _S257 == 1U;
        uint _S260 = _slang_select(_S259, _S252,_S253);
        uint _S261 = trail_0.y;
        uint2  _S262 = make_uint2 ((_S256 >> 1U) | (_S261 << 31U), _S261 >> 1U);
        n_0 = _S260;
        trail_0 = _S262;
        probability_1 = probability_2;
    }
    bool _S263 = (fcptSlotLeaf((n_0), (j_0)));
    bool _S264 = !_S263;
    bool _S265;
    if(_S264)
    {
        _S265 = true;
    }
    else
    {
        LightNode _S266 = (fcptLightBounds((n_0)));
        float _S267 = importance(_S266, origin_3, smooth_n_1);
        _S265 = !(_S267 > 0.0f);
    }
    if(_S265)
    {
        _S265 = true;
    }
    else
    {
        bool _S268 = (dot_0(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S268)
        {
            _S265 = !((dot_0(smooth_n_1, light_point_0 - origin_3)) > 0.0f);
        }
        else
        {
            _S265 = false;
        }
    }
    if(_S265)
    {
        return 0.0f;
    }
    uint4  _S269 = (fcptLightNode((n_0)));
    bool _S270 = (_S269.x) == 2U;
    if(_S270)
    {
        uint _S271 = _S269.y;
        FKLight _S272 = (fcptLight((_S271)));
        FKLight _S273 = (fcptLight((_S271)));
        float _S274 = sphereDensity(_S272.position, _S273.variance, start_5);
        return probability_1 * _S274;
    }
    uint _S275 = _S269.y;
    uint _S276 = (fcptTriangleOffset((_S275)));
    Matrix<float, 3, 3>  _S277 = (fcptWorldTriangle((_S275), (_S276 + _S269.z)));
    float _S278 = solidAngle(probability_1, cross_0(_S277.rows[int(1)] - _S277.rows[int(0)], _S277.rows[int(2)] - _S277.rows[int(0)]), light_point_0 - start_5);
    return _S278;
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

static __device__ float random_0(uint * state_0)
{
    uint _S279 = hash(*state_0);
    *state_0 = _S279;
    return float((*state_0) >> int(8)) * 5.9604644775390625e-08f;
}

static __device__ Random Random_x24init_0(uint state_1, float value_0)
{
    Random _S280;
    (&_S280)->state = state_1;
    (&_S280)->value = value_0;
    return _S280;
}

__device__ Random pcg(uint state_2)
{
    uint _S281 = state_2;
    float value_1 = random_0(&_S281);
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
    float _S294;
    if(e_1 > 0.0f)
    {
        _S294 = 1.0f;
    }
    else
    {
        if(e_1 < 0.0f)
        {
            _S294 = -1.0f;
        }
        else
        {
            _S294 = 0.0f;
        }
    }
    return _S294;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S295;
    (&_S295)->tangent = tangent_0;
    (&_S295)->alphas = alphas_0;
    return _S295;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S296 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S296)
    {
        float3  _S297 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S297;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S298 = cross_0(n_1, a_2);
    float3  _S299 = ((((_S298)) * make_float3(rnorm3df(((_S298)).x, ((_S298)).y, ((_S298)).z))));
    float3  _S300 = cross_0(n_1, _S299);
    return make_float3 (v_0.x) * _S299 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S300;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_0, float3  n_i_0)
{
    float _S301 = material_0.roughness;
    float _S302 = _S301 * _S301;
    bool _S303 = (material_0.anisotropy) == 0.0f;
    bool _S304;
    if(_S303)
    {
        _S304 = true;
    }
    else
    {
        _S304 = !(_S302 > 0.0f);
    }
    if(_S304)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S305 = material_0.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_0.tangent));
    float3  _S306 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S307 = (dot_0(_S305, _S305)) > 0.0f;
    float3  _S308 = _slang_select(_S307, _S305,_S306);
    float3  _S309 = ((((_S308)) * make_float3(rnorm3df(((_S308)).x, ((_S308)).y, ((_S308)).z))));
    float _S310 = 6.28318548202514648f * material_0.anisotropic_rotation;
    float _S311 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_0.anisotropy))))));
    float _S312 = 1.0f / _S311;
    bool _S313 = (material_0.anisotropy) < 0.0f;
    float _S314 = _slang_select(_S313, _S312,_S311);
    return AnisotropicFrame_x24init_0(_S309 * make_float3 ((F32_cos((_S310)))) + cross_0(n_i_0, _S309) * make_float3 ((F32_sin((_S310)))), make_float2 (_S302 / _S314, _S302 * _S314));
}

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

__device__ static const FixedArray<float, 576>  VELVET_ALBEDO_0 = { {
    1.00383996963500977f, 1.00428998470306396f, 1.00356996059417725f, 1.00303995609283447f, 1.00261998176574707f, 1.00229001045227051f, 1.00198996067047119f, 1.00171005725860596f, 1.00144004821777344f, 1.00120997428894043f, 1.00102996826171875f, 1.00092005729675293f, 1.00088000297546387f, 1.0009000301361084f, 1.00095999240875244f, 1.00106000900268555f, 1.00115001201629639f, 1.00124001502990723f, 1.001289963722229f, 1.0013200044631958f, 1.00133001804351807f, 1.00133001804351807f, 1.0013200044631958f, 1.00129997730255127f, 0.99086397886276245f, 0.9934689998626709f, 0.99439799785614014f, 0.99513500928878784f, 0.99574202299118042f, 0.9962649941444397f, 0.99671798944473267f, 0.99709898233413696f, 0.997406005859375f, 0.99764800071716309f, 0.99783498048782349f, 0.99798601865768433f, 0.99811899662017822f, 0.99825501441955566f, 0.99840497970581055f, 0.99857097864151001f, 0.99874699115753174f, 0.99892902374267578f, 0.9990919828414917f, 0.99923902750015259f, 0.99936902523040771f, 0.99948000907897949f, 0.99957501888275146f, 0.99965798854827881f, 0.94088798761367798f, 0.95128101110458374f, 0.95866602659225464f, 0.96450901031494141f, 0.96921002864837646f, 0.973052978515625f, 0.97623497247695923f, 0.97890102863311768f, 0.98115700483322144f, 0.98308497667312622f, 0.98474901914596558f, 0.98619699478149414f, 0.98746699094772339f, 0.98858797550201416f, 0.98958402872085571f, 0.99047297239303589f, 0.99127000570297241f, 0.99198299646377563f, 0.99262100458145142f, 0.99318897724151611f, 0.99372398853302002f, 0.99426800012588501f, 0.99475300312042236f, 0.99514400959014893f, 0.86131101846694946f, 0.88463401794433594f, 0.90212702751159668f, 0.91595500707626343f, 0.92708200216293335f, 0.93617302179336548f, 0.94370102882385254f, 0.95000702142715454f, 0.95534700155258179f, 0.9599120020866394f, 0.96384698152542114f, 0.96726799011230469f, 0.97026199102401733f, 0.97289901971817017f, 0.97523599863052368f, 0.97731602191925049f, 0.97917401790618896f, 0.98083901405334473f, 0.98233497142791748f, 0.98368102312088013f, 0.98489302396774292f, 0.98598498106002808f, 0.98697298765182495f, 0.98787301778793335f, 0.75306302309036255f, 0.79328000545501709f, 0.82418698072433472f, 0.84881901741027832f, 0.86874997615814209f, 0.88506197929382324f, 0.89858502149581909f, 0.9099239706993103f, 0.91952997446060181f, 0.9277459979057312f, 0.93483197689056396f, 0.94099199771881104f, 0.9463840126991272f, 0.95113497972488403f, 0.95534402132034302f, 0.95908999443054199f, 0.9624369740486145f, 0.96543699502944946f, 0.96813201904296875f, 0.97055697441101074f, 0.97274202108383179f, 0.97471201419830322f, 0.97649002075195312f, 0.97809398174285889f, 0.62183499336242676f, 0.68052101135253906f, 0.72705197334289551f, 0.76452702283859253f, 0.79505598545074463f, 0.82021200656890869f, 0.84120297431945801f, 0.85885602235794067f, 0.87384098768234253f, 0.88667500019073486f, 0.89775800704956055f, 0.90739899873733521f, 0.91584599018096924f, 0.92329102754592896f, 0.929889976978302f, 0.93576502799987793f, 0.94101500511169434f, 0.94572198390960693f, 0.94994997978210449f, 0.95375597476959229f, 0.95718497037887573f, 0.9602770209312439f, 0.96306699514389038f, 0.96558600664138794f, 0.47742500901222229f, 0.5522189736366272f, 0.61415499448776245f, 0.66520899534225464f, 0.70744901895523071f, 0.74262100458145142f, 0.77213901281356812f, 0.7971159815788269f, 0.81841897964477539f, 0.83673000335693359f, 0.85258400440216064f, 0.86640900373458862f, 0.87854301929473877f, 0.88924998044967651f, 0.89874798059463501f, 0.90721100568771362f, 0.91477799415588379f, 0.92156499624252319f, 0.92766499519348145f, 0.93315702676773071f, 0.9381060004234314f, 0.94257098436355591f, 0.94660097360610962f, 0.95023900270462036f, 0.33539599180221558f, 0.41908100247383118f, 0.49247598648071289f, 0.55531197786331177f, 0.60879099369049072f, 0.65415602922439575f, 0.69274699687957764f, 0.72571200132369995f, 0.75402498245239258f, 0.77849102020263672f, 0.79976201057434082f, 0.81836599111557007f, 0.83474302291870117f, 0.84922301769256592f, 0.86208897829055786f, 0.87356698513031006f, 0.88384199142456055f, 0.89306402206420898f, 0.90135800838470459f, 0.9088289737701416f, 0.91556602716445923f, 0.92164498567581177f, 0.92713397741317749f, 0.93208998441696167f, 0.21194499731063843f, 0.29365798830986023f, 0.37110498547554016f, 0.44143900275230408f, 0.5036969780921936f, 0.55801302194595337f, 0.60521197319030762f, 0.64614301919937134f, 0.68169897794723511f, 0.71268302202224731f, 0.73979401588439941f, 0.76362699270248413f, 0.78467601537704468f, 0.80335497856140137f, 0.82000100612640381f, 0.83488202095031738f, 0.8482239842414856f, 0.86021500825881958f, 0.87101101875305176f, 0.88074499368667603f, 0.88952797651290894f, 0.89745801687240601f, 0.90461999177932739f, 0.91109001636505127f, 0.11949499696493149f, 0.18745699524879456f, 0.25997200608253479f, 0.33120998740196228f, 0.39773499965667725f, 0.45832300186157227f, 0.51248997449874878f, 0.56048798561096191f, 0.6028980016708374f, 0.64032697677612305f, 0.67339599132537842f, 0.70268499851226807f, 0.72870397567749023f, 0.75189602375030518f, 0.77263599634170532f, 0.7912449836730957f, 0.80796998739242554f, 0.82303100824356079f, 0.8366129994392395f, 0.84887397289276123f, 0.85994899272918701f, 0.86995697021484375f, 0.87900298833847046f, 0.88717901706695557f, 0.05942929908633232f, 0.10839699953794479f, 0.16785700619220734f, 0.23236599564552307f, 0.29767501354217529f, 0.36022999882698059f, 0.41842898726463318f, 0.47170799970626831f, 0.5198180079460144f, 0.56301301717758179f, 0.60171198844909668f, 0.63635998964309692f, 0.66739702224731445f, 0.69524997472763062f, 0.720287024974823f, 0.74283498525619507f, 0.76317602396011353f, 0.78155702352523804f, 0.79817098379135132f, 0.81319701671600342f, 0.8267899751663208f, 0.83908802270889282f, 0.85021400451660156f, 0.86027902364730835f, 0.02584660053253174f, 0.05619670078158379f, 0.09917669743299484f, 0.15162299573421478f, 0.20941600203514099f, 0.26902499794960022f, 0.32757499814033508f, 0.38318398594856262f, 0.43501600623130798f, 0.48271399736404419f, 0.52620798349380493f, 0.56570100784301758f, 0.60149699449539185f, 0.63392102718353271f, 0.66328197717666626f, 0.68988502025604248f, 0.7139970064163208f, 0.7358660101890564f, 0.75570398569107056f, 0.77369099855422974f, 0.78999698162078857f, 0.80477499961853027f, 0.81816202402114868f, 0.83028298616409302f, 0.00968609005212784f, 0.02591750025749207f, 0.05318830162286758f, 0.09121809899806976f, 0.13777700066566467f, 0.18976299464702606f, 0.244159996509552f, 0.29880800843238831f, 0.35169300436973572f, 0.40180501341819763f, 0.44872200489044189f, 0.49213200807571411f, 0.53206497430801392f, 0.5686650276184082f, 0.60214298963546753f, 0.63272500038146973f, 0.66062301397323608f, 0.68605399131774902f, 0.70922297239303589f, 0.73031198978424072f, 0.74948400259017944f, 0.76689702272415161f, 0.78270000219345093f, 0.79702901840209961f, 0.00303822988644242f, 0.01048239972442389f, 0.02568300068378448f, 0.05025380104780197f, 0.08408640325069427f, 0.12561400234699249f, 0.17249999940395355f, 0.22232000529766083f, 0.27309399843215942f, 0.32321798801422119f, 0.37149098515510559f, 0.4173240065574646f, 0.4603630006313324f, 0.50043797492980957f, 0.53755801916122437f, 0.57181298732757568f, 0.60333001613616943f, 0.63226902484893799f, 0.65877401828765869f, 0.68301999568939209f, 0.70514601469039917f, 0.7253040075302124f, 0.74363899230957031f, 0.76029098033905029f, 0.00076204299693927f, 0.00361976004205644f, 0.0110037000849843f, 0.02512970007956028f, 0.04727460071444511f, 0.07745999842882156f, 0.11460299789905548f, 0.1569570004940033f, 0.20258499681949615f, 0.24971699714660645f, 0.29707801342010498f, 0.34340900182723999f, 0.38799500465393066f, 0.43043500185012817f, 0.47039699554443359f, 0.50777101516723633f, 0.54253697395324707f, 0.57473397254943848f, 0.60444700717926025f, 0.63179397583007812f, 0.65686798095703125f, 0.67979699373245239f, 0.70071202516555786f, 0.71974599361419678f, 0.00014345299859997f, 0.00102306995540857f, 0.00407376000657678f, 0.01122699957340956f, 0.02423799969255924f, 0.04415180161595345f, 0.07109060138463974f, 0.10433399677276611f, 0.14259399473667145f, 0.184347003698349f, 0.2281080037355423f, 0.27265200018882751f, 0.31696400046348572f, 0.36016398668289185f, 0.40178799629211426f, 0.44139501452445984f, 0.47875601053237915f, 0.51375597715377808f, 0.54635101556777954f, 0.57658302783966064f, 0.60447400808334351f, 0.63009101152420044f, 0.65352898836135864f, 0.67488902807235718f, 0.00001858420000644f, 0.0002227969962405f, 0.00124967005103827f, 0.00435766018927097f, 0.01113030035048723f, 0.0229835007339716f, 0.04079980030655861f, 0.06477940082550049f, 0.09447769820690155f, 0.12897300720214844f, 0.16708999872207642f, 0.20760199427604675f, 0.24936899542808533f, 0.29154899716377258f, 0.3332040011882782f, 0.37377101182937622f, 0.41274300217628479f, 0.44977998733520508f, 0.4846780002117157f, 0.51733100414276123f, 0.54769200086593628f, 0.57572799921035767f, 0.6014779806137085f, 0.62501102685928345f, 1.46482000218384201e-06f, 0.00003429050047998f, 0.0002985020109918f, 0.00140504003502429f, 0.00443577999249101f, 0.01069260016083717f, 0.02133879996836185f, 0.0371410995721817f, 0.05836030095815659f, 0.08476380258798599f, 0.11572299897670746f, 0.1503559947013855f, 0.18766500055789948f, 0.22665500640869141f, 0.26647698879241943f, 0.30632400512695312f, 0.34550899267196655f, 0.38344401121139526f, 0.41970700025558472f, 0.45401400327682495f, 0.48618701100349426f, 0.51614201068878174f, 0.54384201765060425f, 0.56930899620056152f, 5.83937982412408019e-08f, 3.2765999549155822e-06f, 0.00005055400106357f, 0.00035111699253321f, 0.00145683996379375f, 0.00427943980321288f, 0.0098936902359128f, 0.01927389949560165f, 0.03310279920697212f, 0.05168719962239265f, 0.07495570182800293f, 0.10250899940729141f, 0.13370099663734436f, 0.1677280068397522f, 0.20372100174427032f, 0.24084299802780151f, 0.27840098738670349f, 0.31564199924468994f, 0.35190799832344055f, 0.38674798607826233f, 0.41985601186752319f, 0.45104199647903442f, 0.48021000623703003f, 0.50734001398086548f, 8.73966010672688753e-10f, 1.57741993689342053e-07f, 5.21975016454234719e-06f, 0.00006079579907237f, 0.00036219600588083f, 0.00138045998755842f, 0.00386844994500279f, 0.00871635042130947f, 0.01675550080835819f, 0.02860799990594387f, 0.04461279883980751f, 0.06480839848518372f, 0.08895269781351089f, 0.11656700074672699f, 0.1470009982585907f, 0.17950700223445892f, 0.21331800520420074f, 0.24785000085830688f, 0.28237700462341309f, 0.31631898880004883f, 0.34923198819160461f, 0.38083100318908691f, 0.41094100475311279f, 0.43946701288223267f, 2.8866399288257627e-12f, 2.63671995348602195e-09f, 2.51094007808205788e-07f, 5.97520011069718748e-06f, 0.00005859580051037f, 0.0003192939911969f, 0.00116373994387686f, 0.00319523992948234f, 0.00714873988181353f, 0.0137449000030756f, 0.0235638003796339f, 0.03696820139884949f, 0.05407309904694557f, 0.0747511014342308f, 0.09866459667682648f, 0.12531900405883789f, 0.15412400662899017f, 0.18446199595928192f, 0.21573600172996521f, 0.24741099774837494f, 0.27903899550437927f, 0.310263991355896f, 0.34082499146461487f, 0.37054198980331421f, 6.94488983838260476e-16f, 7.04290011727115584e-12f, 3.21448001550095341e-09f, 2.20180993437679717e-07f, 4.50593006462440826e-06f, 0.00004154839916737f, 0.00022262999846134f, 0.00081575999502093f, 0.00227530999109149f, 0.00519366981461644f, 0.01020010001957417f, 0.0178545992821455f, 0.02856850065290928f, 0.04256030172109604f, 0.05984469875693321f, 0.08025020360946655f, 0.10345599800348282f, 0.12904399633407593f, 0.15654699504375458f, 0.1854960024356842f, 0.21545499563217163f, 0.24603499472141266f, 0.27690801024436951f, 0.3078019917011261f, 5.46278023199234311e-22f, 3.43167987041791307e-16f, 2.29294990113093622e-12f, 9.57796952860689998e-10f, 6.87986982939037262e-08f, 1.5533599935224629e-06f, 0.00001600819996384f, 0.00009555240103509f, 0.00038631301140413f, 0.00117554003372788f, 0.00289549003355205f, 0.00607588002458215f, 0.01126710046082735f, 0.01896269991993904f, 0.02954130060970783f, 0.04323289915919304f, 0.06011129915714264f, 0.0801049992442131f, 0.10301999747753143f, 0.12857000529766083f, 0.15640300512313843f, 0.18612800538539886f, 0.21734000742435455f, 0.24963200092315674f, 0.0f, 0.0f, 3.09890004335006815e-24f, 2.21276004416278673e-18f, 2.67358004631774657e-14f, 2.24439997836833882e-11f, 3.13075010360819306e-09f, 1.26480998119404831e-07f, 2.12951999856159091e-06f, 0.00001907769910758f, 0.00010753999958979f, 0.00042892698547803f, 0.00131604995112866f, 0.00330013991333544f, 0.00707077002152801f, 0.01337909977883101f, 0.02291939966380596f, 0.03622379899024963f, 0.05359359830617905f, 0.07507230341434479f, 0.10045900195837021f, 0.12935000658035278f, 0.16119599342346191f, 0.19536399841308594f
} };
__device__ static const FixedArray<float, 576>  SHEEN_ALBEDO_0 = { {
    0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f
} };
__device__ float sheenAlbedo(float3  v_1, float3  n_i_1, BSDFMaterial material_1)
{
    float _S315 = rgb_to_greyscale(material_1.sheen);
    bool _S316 = _S315 > 0.0f;
    float albedo_0;
    if(_S316)
    {
        float _S317 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S318 = (U32_min((uint(_S317)), (22U)));
        float _S319 = (F32_sqrt((0.05000000074505806f)));
        float _S320 = (F32_sqrt((0.10000000149011612f)));
        bool _S321 = (material_1.velvet) > 0.0f;
        float _S322 = _slang_select(_S321, _S320,_S319);
        float _S323 = (clamp_1((F32_sqrt(((F32_max((material_1.sheen_roughness), (0.0f)))))), _S322, 1.0f) - _S322) / (1.0f - _S322) * 23.0f;
        uint _S324 = (U32_min((uint(_S323)), (22U)));
        uint _S325 = _S318 * 24U + _S324;
        float _S326 = _S317 - float(_S318);
        float _S327 = _S323 - float(_S324);
        if(_S321)
        {
            uint _S328 = _S325 + 24U;
            float _S329 = VELVET_ALBEDO_0[_S325] + (VELVET_ALBEDO_0[_S328] - VELVET_ALBEDO_0[_S325]) * _S326;
            uint _S330 = _S325 + 1U;
            float _S331 = VELVET_ALBEDO_0[_S330] + (VELVET_ALBEDO_0[_S328 + 1U] - VELVET_ALBEDO_0[_S330]) * _S326;
            float _S332 = _S329 + (_S331 - _S329) * _S327;
            albedo_0 = _S332;
        }
        else
        {
            uint _S333 = _S325 + 24U;
            float _S334 = SHEEN_ALBEDO_0[_S325] + (SHEEN_ALBEDO_0[_S333] - SHEEN_ALBEDO_0[_S325]) * _S326;
            uint _S335 = _S325 + 1U;
            float _S336 = SHEEN_ALBEDO_0[_S335] + (SHEEN_ALBEDO_0[_S333 + 1U] - SHEEN_ALBEDO_0[_S335]) * _S326;
            float _S337 = (F32_exp((_S334 + (_S336 - _S334) * _S327)));
            albedo_0 = _S337;
        }
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
    BSDFLobes _S338;
    (&_S338)->v_dot_h = v_dot_h_0;
    (&_S338)->n_dot_h = n_dot_h_0;
    (&_S338)->refracted = refracted_1;
    (&_S338)->F = F_0;
    (&_S338)->F_greyscale = F_greyscale_0;
    (&_S338)->reflect_weight = reflect_weight_0;
    (&_S338)->diffuse_weight = diffuse_weight_0;
    (&_S338)->refract_weight = refract_weight_0;
    (&_S338)->p_diffuse = p_diffuse_0;
    (&_S338)->p_reflect = p_reflect_0;
    (&_S338)->p_refract = p_refract_0;
    (&_S338)->translucent_share = translucent_share_0;
    (&_S338)->sheen = sheen_0;
    (&_S338)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S338)->view = view_0;
    (&_S338)->tangent = tangent_1;
    (&_S338)->alphas = alphas_1;
    (&_S338)->visible = visible_0;
    (&_S338)->p_toon = p_toon_0;
    (&_S338)->toon = toon_0;
    (&_S338)->toon_a = toon_a_0;
    (&_S338)->toon_s = toon_s_0;
    (&_S338)->toon_b = toon_b_0;
    (&_S338)->toon_glossy = toon_glossy_0;
    (&_S338)->toon_norm = toon_norm_0;
    (&_S338)->toon_view = toon_view_0;
    (&_S338)->toon_axis = toon_axis_0;
    return _S338;
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
    float3  _S339 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S340 = ((((_S339)) * make_float3(rnorm3df(((_S339)).x, ((_S339)).y, ((_S339)).z))));
    float _S341 = _S340.x;
    float _S342 = _S340.y;
    float _S343 = _S341 * _S341 + _S342 * _S342;
    float3  _S344;
    if(_S343 > 0.0f)
    {
        float3  _S345 = make_float3 (- _S342, _S341, 0.0f);
        float _S346 = (rsqrtf((_S343)));
        _S344 = _S345 * make_float3 (_S346);
    }
    else
    {
        _S344 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S347 = cross_0(_S340, _S344);
    float _S348 = (F32_sqrt((U1_0)));
    float _S349 = 6.28318548202514648f * U2_0;
    float _S350 = _S348 * (F32_cos((_S349)));
    float t2_0 = _S348 * (F32_sin((_S349)));
    float _S351 = 0.5f * (1.0f + _S340.z);
    float t2_1 = (1.0f - _S351) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S350 * _S350)))))) + _S351 * t2_0;
    float3  _S352 = make_float3 (_S350) * _S344 + make_float3 (t2_1) * _S347;
    float _S353 = unshared_0(_S350);
    float _S354 = unshared_0(_S350);
    float3  _S355 = _S352 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S353 * _S354 - t2_1 * t2_1))))))) * _S340;
    float3  _S356 = make_float3 (alpha_0 * _S355.x, alpha_0 * _S355.y, (F32_max((0.0f), (_S355.z))));
    float3  _S357 = ((((_S356)) * make_float3(rnorm3df(((_S356)).x, ((_S356)).y, ((_S356)).z))));
    return _S357;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S358 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S358)
    {
        float3  _S359 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S359;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S360 = cross_0(n_3, a_4);
    float3  _S361 = ((((_S360)) * make_float3(rnorm3df(((_S360)).x, ((_S360)).y, ((_S360)).z))));
    float3  _S362 = cross_0(n_3, _S361);
    return make_float3 (dot_0(v_2, _S361), dot_0(v_2, n_3), dot_0(v_2, _S362));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S363 = pcg(*random_state_2);
    Random _S364 = pcg(_S363.state);
    *random_state_2 = _S364.state;
    float _S365 = frame_0.alphas.x;
    bool _S366 = _S365 > 0.0f;
    if(_S366)
    {
        float3  _S367 = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        float _S368 = frame_0.alphas.y;
        float3  _S369 = make_float3 (_S365 * _S367.x, _S368 * _S367.y, _S367.z);
        float3  _S370 = ((((_S369)) * make_float3(rnorm3df(((_S369)).x, ((_S369)).y, ((_S369)).z))));
        float3  _S371 = sampleGGXVNDF(_S370, 1.0f, _S363.value, _S364.value);
        float3  _S372 = make_float3 (_S365 * _S371.x, _S368 * _S371.y, _S371.z);
        float3  _S373 = ((((_S372)) * make_float3(rnorm3df(((_S372)).x, ((_S372)).y, ((_S372)).z))));
        return make_float3 (_S373.x) * frame_0.tangent + make_float3 (_S373.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S373.z) * n_i_2;
    }
    float3  _S374 = worldToTangent(v_3, n_i_2);
    float3  _S375 = sampleGGXVNDF(float3 {_S374.x, _S374.z, _S374.y}, alpha_1, _S363.value, _S364.value);
    float3  _S376 = float3 {_S375.x, _S375.z, _S375.y};
    float3  _S377 = tangentToWorld(_S376, n_i_2);
    return _S377;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_4, BSDFMaterial material_2, uint random_state_3, AnisotropicFrame frame_1)
{
    uint state_3 = random_state_3;
    float3  _S378 = negate_0(in_dir_0);
    float _S379 = sign_0(dot_0(n_4, _S378));
    float _S380 = material_2.roughness;
    float3  _S381 = sampleHalfVector(_S378, n_4 * make_float3 (_S379), _S380 * _S380, frame_1, &state_3);
    return _S381;
}

static __device__ float3  refract_0(float3  i_5, float3  n_5, float eta_0)
{
    float _S382 = dot_0(n_5, i_5);
    float _S383 = 1.0f - eta_0 * eta_0 * (1.0f - _S382 * _S382);
    if(_S383 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S382 + (F32_sqrt((_S383)))) * n_5;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S384 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S385 = eta_i_0 / eta_o_0 * _S384;
    bool _S386 = _S385 < 1.0f;
    float kr_0;
    if(_S386)
    {
        float _S387 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S385 * _S385))))));
        float _S388 = eta_o_0 * cos_theta_0;
        float _S389 = eta_i_0 * _S387;
        float _S390 = (_S388 - _S389) / (_S388 + _S389);
        float _S391 = eta_i_0 * cos_theta_0;
        float _S392 = eta_o_0 * _S387;
        float _S393 = (_S391 - _S392) / (_S391 + _S392);
        float _S394 = (_S390 * _S390 + _S393 * _S393) / 2.0f;
        kr_0 = _S394;
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
    float _S395 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S395 / (_S395 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S395)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S396 = alphas_3.x;
    float _S397 = h_0.x / _S396;
    float _S398 = alphas_3.y;
    float _S399 = h_0.y / _S398;
    float _S400 = h_0.z;
    float _S401 = _S397 * _S397 + _S399 * _S399 + _S400 * _S400;
    return 1.0f / (F32_max((3.14159274101257324f * _S396 * _S398 * _S401 * _S401), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_1, float3  v_4, float3  n_i_3, float3  ggx_n_0, BSDFMaterial material_3, float eta_i_1, float eta_o_1, AnisotropicFrame frame_2, float sheen_albedo_0)
{
    float _S402 = dot_0(ggx_n_0, v_4);
    float _S403 = dot_0(n_i_3, ggx_n_0);
    float _S404 = eta_i_1 / eta_o_1;
    float3  _S405 = refract_0(in_dir_1, ggx_n_0, _S404);
    float3  _S406 = ((((_S405)) * make_float3(rnorm3df(((_S405)).x, ((_S405)).y, ((_S405)).z))));
    float _S407 = (F32_min(((F32_sqrt((material_3.specular_level))) * (F32_abs((eta_i_1 - eta_o_1))) / (eta_i_1 + eta_o_1)), (0.9999847412109375f)));
    float _S408 = _S407 * _S407;
    float _S409 = (1.0f + _S407) / (1.0f - _S407);
    float _S410 = (F32_abs((_S402)));
    bool _S411 = eta_i_1 > eta_o_1;
    float sheen_component_0;
    if(_S411)
    {
        sheen_component_0 = _S409;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float toon_component_0;
    if(_S411)
    {
        toon_component_0 = 1.0f;
    }
    else
    {
        toon_component_0 = _S409;
    }
    float _S412 = fresnel(_S410, sheen_component_0, toon_component_0);
    bool _S413 = (eta_i_1 * eta_i_1 * (1.0f - _S402 * _S402)) >= (eta_o_1 * eta_o_1);
    float3  _S414;
    if(_S413)
    {
        _S414 = make_float3 (1.0f);
    }
    else
    {
        float3  _S415 = material_3.specular_tint * make_float3 (_S408);
        _S414 = _S415 + (make_float3 (1.0f) - _S415) * make_float3 (_S412 - _S408) / make_float3 (1.0f - _S408);
    }
    float3  _S416 = make_float3 (1.0f);
    float3  _S417 = make_float3 (0.0f);
    float _S418 = rgb_to_greyscale(material_3.sheen);
    bool _S419 = _S418 > 0.0f;
    float3  sheen_1;
    float3  view_1;
    float3  scale_1;
    if(_S419)
    {
        float _S420 = (F32_min((sheen_albedo_0), (1.0f)));
        float3  _S421 = make_float3 (1.0f) - material_3.sheen * make_float3 (_S420);
        float _S422 = rgb_to_greyscale(material_3.sheen);
        float _S423 = _S422 * _S420;
        float3  _S424 = material_3.sheen / make_float3 ((F32_max((sheen_albedo_0), (1.0f))));
        sheen_component_0 = _S423;
        sheen_1 = _S424;
        view_1 = v_4;
        scale_1 = _S421;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S417;
        view_1 = _S417;
        scale_1 = _S416;
    }
    float _S425 = material_3.toon.x;
    bool _S426 = _S425 < 0.0f;
    float _S427 = (F32_abs((_S425)));
    bool _S428 = _S427 > 0.0f;
    float toon_a_1;
    float toon_s_1;
    float toon_b_1;
    float toon_norm_1;
    float toon_view_1;
    float3  toon_1;
    float3  toon_axis_1;
    bool _S429;
    if(_S428)
    {
        float _S430 = (F32_min((_S427), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S430);
        float _S431 = rgb_to_greyscale(material_3.albedo);
        float _S432 = _S430 * _S431;
        float3  _S433 = make_float3 (_S430) * material_3.albedo;
        float toon_a_2 = clamp_1(material_3.toon.y / _S425, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_2 = clamp_1(material_3.toon.z / _S425, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S434 = (F32_min((toon_a_2 + toon_s_2), (1.57079637050628662f)));
        if(_S426)
        {
            toon_component_0 = 1.0f - (F32_cos(((F32_min((_S434), (toon_a_2))))));
        }
        else
        {
            float _S435 = (F32_sin(((F32_min((_S434), (toon_a_2))))));
            toon_component_0 = _S435 * _S435 / 2.0f;
        }
        bool _S436 = _S434 > toon_a_2;
        if(_S436)
        {
            _S429 = toon_s_2 > 0.0f;
        }
        else
        {
            _S429 = false;
        }
        if(_S429)
        {
            if(_S426)
            {
                float _S437 = (F32_cos((toon_a_2)));
                float _S438 = (F32_cos((_S434)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S437 - _S438) - ((F32_sin((_S434))) - _S434 * _S438 - ((F32_sin((toon_a_2))) - toon_a_2 * _S437)) / toon_s_2;
            }
            else
            {
                float _S439 = 2.0f * toon_a_2;
                float _S440 = (F32_cos((_S439)));
                float _S441 = 2.0f * _S434;
                float _S442 = (F32_cos((_S441)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S440 - _S442) / 4.0f - ((F32_sin((_S441))) / 8.0f - _S434 * _S442 / 4.0f - ((F32_sin((_S439))) / 8.0f - toon_a_2 * _S440 / 4.0f)) / toon_s_2;
            }
            float integral_0 = toon_component_0 + toon_a_1;
            toon_component_0 = integral_0;
        }
        float _S443 = 6.28318548202514648f * toon_component_0;
        float _S444 = dot_0(n_i_3, v_4);
        float _S445 = (F32_acos(((F32_min((_S444), (1.0f))))));
        if(_S445 < toon_a_2)
        {
            toon_component_0 = 1.0f;
        }
        else
        {
            toon_component_0 = (F32_max((1.0f - (_S445 - toon_a_2) / (F32_max((toon_s_2), (0.0000152587890625f)))), (0.0f)));
        }
        if(_S426)
        {
            float3  _S446 = make_float3 (2.0f * _S444) * n_i_3 - v_4;
            float3  _S447 = ((((_S446)) * make_float3(rnorm3df(((_S446)).x, ((_S446)).y, ((_S446)).z))));
            scale_1 = _S447;
        }
        else
        {
            scale_1 = n_i_3;
        }
        float _S448 = toon_component_0;
        toon_component_0 = _S432;
        toon_1 = _S433;
        toon_a_1 = toon_a_2;
        toon_s_1 = toon_s_2;
        toon_b_1 = _S434;
        toon_norm_1 = _S443;
        toon_view_1 = _S448;
        toon_axis_1 = scale_1;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S417;
        toon_a_1 = 0.0f;
        toon_s_1 = 0.0f;
        toon_b_1 = 0.0f;
        toon_norm_1 = 1.0f;
        toon_view_1 = 0.0f;
        toon_axis_1 = n_i_3;
    }
    float3  _S449 = mix_0(_S414, material_3.albedo, material_3.metallic);
    float3  F_1 = _S449 * scale_1;
    float _S450 = rgb_to_greyscale(F_1);
    float _S451 = 1.0f - material_3.metallic;
    float3  _S452 = make_float3 (1.0f) - _S414;
    float3  _S453 = make_float3 ((1.0f - material_3.transmission) * _S451) * _S452 * scale_1;
    float3  _S454 = make_float3 (material_3.transmission * _S451) * _S452 * scale_1;
    float _S455 = (F32_max((_S450), (0.0f)));
    float _S456 = rgb_to_greyscale(_S453);
    float _S457 = (F32_max((_S456), (0.0f)));
    float _S458 = rgb_to_greyscale(_S454);
    float _S459 = sign_0(length_0(_S406));
    float _S460 = (F32_max((_S458 * _S459), (0.0f)));
    float _S461 = _S455 + _S457 + _S460 + toon_component_0;
    float _S462 = (F32_min((sheen_component_0), (1.0f)));
    bool _S463 = sheen_component_0 > 0.0f;
    if(_S463)
    {
        _S429 = !(_S461 > 0.0f);
    }
    else
    {
        _S429 = false;
    }
    float _S464 = _slang_select(_S429, 1.0f,_S462);
    float _S465 = (1.0f - _S464) / (F32_max((_S461), (0.0000152587890625f)));
    float _S466 = _S457 * _S465;
    float _S467 = _S455 * _S465;
    float _S468 = _S460 * _S465;
    bool _S469 = (frame_2.alphas.x) > 0.0f;
    float visible_1;
    if(_S469)
    {
        float3  _S470 = anisotropicLocal(v_4, frame_2.tangent, n_i_3);
        float _S471 = anisotropicG1(_S470, frame_2.alphas);
        float3  _S472 = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        float _S473 = anisotropicD(_S472, frame_2.alphas);
        float _S474 = _S471 * _S473;
        visible_1 = _S474;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S402, _S403, _S406, F_1, _S450, 1.0f, _S453, _S454, _S466, _S467, _S468, 0.0f, sheen_1, _S464, view_1, frame_2.tangent, frame_2.alphas, visible_1, toon_component_0 * _S465, toon_1, toon_a_1, toon_s_1, toon_b_1, _S426, toon_norm_1, toon_view_1, toon_axis_1);
}

__device__ float translucentShare(BSDFMaterial material_4)
{
    float _S475 = rgb_to_greyscale(material_4.translucent);
    float _S476 = rgb_to_greyscale(material_4.albedo);
    float _S477 = _S475 / (_S476 + _S475);
    bool _S478 = _S475 > 0.0f;
    float _S479 = _slang_select(_S478, _S477,0.0f);
    return _S479;
}

__device__ float3  refractedHalf(float3  in_dir_2, float3  out_dir_0, float3  n_6, float eta_i_2, float eta_o_2)
{
    float3  _S480 = negate_0(in_dir_2);
    float3  _S481 = negate_0(make_float3 (eta_i_2) * _S480 + make_float3 (eta_o_2) * out_dir_0);
    float3  _S482 = ((((_S481)) * make_float3(rnorm3df(((_S481)).x, ((_S481)).y, ((_S481)).z))));
    float _S483 = sign_0(dot_0(n_6, _S480));
    float _S484 = sign_0(dot_0(_S481, n_6 * make_float3 (_S483)));
    return _S482 * make_float3 (_S484);
}

__device__ float3  reflectedHalf(float3  in_dir_3, float3  out_dir_1)
{
    float3  _S485 = negate_0(in_dir_3);
    float3  _S486 = _S485 + out_dir_1;
    float3  _S487 = ((((_S486)) * make_float3(rnorm3df(((_S486)).x, ((_S486)).y, ((_S486)).z))));
    return _S487;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_2, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S488 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S489 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S490 = 1.0f - lobes_0.translucent_share;
    bool _S491 = n_i_dot_l_0 < 0.0f;
    float _S492 = _slang_select(_S491, lobes_0.translucent_share,_S490);
    float _S493 = _S489 * _S492;
    bool _S494 = (lobes_0.translucent_share) > 0.0f;
    float _S495 = _slang_select(_S494, _S493,_S488);
    bool _S496 = n_i_dot_v_0 > 0.0f;
    float _S497 = _slang_select(_S496, _S495,0.0f);
    return _S497;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_4, float alpha_3, BSDFMaterial material_5, BSDFLobes lobes_1)
{
    bool _S498 = (dot_0(n_i_4, l_0)) < 0.0f;
    float3  _S499 = _slang_select(_S498, material_5.translucent,material_5.albedo);
    float _S500 = 1.0f - lobes_1.translucent_share;
    float _S501 = _slang_select(_S498, lobes_1.translucent_share,_S500);
    float3  _S502 = _S499 / make_float3 (_S501);
    bool _S503 = (lobes_1.translucent_share) > 0.0f;
    float3  _S504 = _slang_select(_S503, _S502,material_5.albedo);
    return lobes_1.diffuse_weight * _S504 / make_float3 (lobes_1.p_diffuse);
}

__device__ float smithG1(float alpha_4, float n_dot_x_0)
{
    float _S505 = alpha_4 * alpha_4;
    float _S506 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S505 + (1.0f - _S505) * n_dot_x_0 * n_dot_x_0))));
    bool _S507 = alpha_4 > 0.0f;
    float _S508 = _slang_select(_S507, _S506,1.0f);
    return _S508;
}

__device__ float trowbridgeReitz(float alpha_5, float n_dot_h_1)
{
    float _S509 = alpha_5 * alpha_5;
    float _S510 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S509 * n_dot_h_1 * n_dot_h_1;
    return _S509 / (F32_max((3.14159274101257324f * _S510 * _S510), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S511 = smithG1(alpha_6, n_i_dot_v_1);
    float _S512 = _S511 * lobes_2.v_dot_h;
    float _S513 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S514 = _S512 * _S513 / n_i_dot_v_1;
    bool _S515 = alpha_6 > 0.0f;
    bool _S516;
    if(_S515)
    {
        _S516 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S516 = false;
    }
    if(_S516)
    {
        _S516 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S516 = false;
    }
    if(_S516)
    {
        _S516 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S516 = false;
    }
    float _S517 = _slang_select(_S516, _S514,0.0f);
    bool _S518 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S518)
    {
        float _S519 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S520 = (lobes_2.v_dot_h) > 0.0f;
        if(_S520)
        {
            _S516 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S516 = false;
        }
        if(_S516)
        {
            _S516 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S516 = false;
        }
        float _S521 = _slang_select(_S516, _S519,0.0f);
        pdf_h_0 = _S521;
    }
    else
    {
        pdf_h_0 = _S517;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S522 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S523 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S524 = lobes_3.p_refract * _S522 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S523 * _S523);
    bool _S525 = eta_i_4 != eta_o_4;
    bool _S526;
    if(_S525)
    {
        _S526 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S526 = false;
    }
    float _S527 = _slang_select(_S526, _S524,0.0f);
    return _S527;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_5, float alpha_8, BSDFMaterial material_6, BSDFLobes lobes_4)
{
    float _S528 = - dot_0(n_i_5, l_1);
    float _S529 = smithG1(alpha_8, (F32_max((_S528), (0.0f))));
    bool _S530 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S530)
    {
        float3  _S531 = negate_0(n_i_5);
        float3  _S532 = anisotropicLocal(l_1, lobes_4.tangent, _S531);
        float _S533 = anisotropicG1(_S532, lobes_4.alphas);
        G1_l_0 = _S533;
    }
    else
    {
        G1_l_0 = _S529;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_6.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S534 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S535 = n_i_dot_l_2 > 0.0f;
    bool _S536;
    if(_S535)
    {
        _S536 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S536 = false;
    }
    float _S537 = _slang_select(_S536, _S534,0.0f);
    return _S537;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_6, float alpha_10, BSDFMaterial material_7, BSDFLobes lobes_6)
{
    float3  _S538 = l_2 + lobes_6.view;
    float3  _S539 = ((((_S538)) * make_float3(rnorm3df(((_S538)).x, ((_S538)).y, ((_S538)).z))));
    float _S540 = dot_0(n_i_6, _S539);
    float _S541 = (F32_max((dot_0(n_i_6, l_2)), (0.0f)));
    float _S542 = (F32_max((dot_0(n_i_6, lobes_6.view)), (0.0f)));
    float _S543 = 1.0f / (F32_max((material_7.sheen_roughness), (0.05000000074505806f)));
    float _S544 = 1.0f - _S540 * _S540;
    float _S545 = (2.0f + _S543) * (F32_pow(((F32_max((_S544), (0.0f)))), (0.5f * _S543))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S541 + _S542 - _S541 * _S542)), (0.0000152587890625f)));
    bool _S546 = (material_7.velvet) > 0.0f;
    float f_0;
    if(_S546)
    {
        float _S547 = (F32_max((material_7.sheen_roughness), (0.00999999977648258f)));
        float _S548 = _S547 * _S547;
        float _S549 = (F32_max((_S544), (0.0000152587890625f)));
        float _S550 = (F32_exp((- _S540 * _S540 / (_S549 * _S548)))) / (3.14159274101257324f * _S548 * _S549 * _S549) * (F32_min((1.0f), (2.0f * _S540 * (F32_min((_S541), (_S542))) / (F32_max(((F32_abs((dot_0(_S539, lobes_6.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S541 * _S542), (0.0000152587890625f)));
        f_0 = _S550;
    }
    else
    {
        f_0 = _S545;
    }
    return lobes_6.sheen * make_float3 (f_0 * _S541 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float toonPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, BSDFLobes lobes_7, float eta_i_6, float eta_o_6)
{
    float _S551 = _slang_select(lobes_7.toon_glossy, l_dot_h_3,n_i_dot_l_3);
    float _S552 = (F32_acos((clamp_1(_S551, -1.0f, 1.0f))));
    float _S553;
    if(_S552 < (lobes_7.toon_a))
    {
        _S553 = 1.0f;
    }
    else
    {
        _S553 = (F32_max((1.0f - (_S552 - lobes_7.toon_a) / (F32_max((lobes_7.toon_s), (0.0000152587890625f)))), (0.0f)));
    }
    float _S554 = lobes_7.p_toon * _S553;
    float _S555 = _slang_select(lobes_7.toon_glossy, 1.0f,n_i_dot_l_3);
    float _S556 = _S554 * _S555 / lobes_7.toon_norm;
    bool _S557;
    if(lobes_7.toon_glossy)
    {
        _S557 = true;
    }
    else
    {
        _S557 = n_i_dot_l_3 > 0.0f;
    }
    float _S558 = _slang_select(_S557, _S556,0.0f);
    return _S558;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_3, float3  n_i_7, float alpha_12, BSDFMaterial material_8, BSDFLobes lobes_8)
{
    float _S559 = (F32_max((dot_0(n_i_7, l_3)), (0.0f)));
    float _S560 = _slang_select(lobes_8.toon_glossy, _S559,lobes_8.toon_view);
    return lobes_8.toon * make_float3 (_S560) / make_float3 (lobes_8.p_toon);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_4, float l_dot_h_4, float n_i_dot_v_5, float alpha_13, BSDFLobes lobes_9, float eta_i_7, float eta_o_7)
{
    float _S561 = vndfPDF(n_i_dot_v_5, alpha_13, lobes_9);
    float _S562 = lobes_9.p_reflect * _S561 / (4.0f * lobes_9.v_dot_h);
    bool _S563 = _S561 > 0.0f;
    float _S564 = _slang_select(_S563, _S562,0.0f);
    return _S564;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_4, float3  n_i_8, float alpha_14, BSDFMaterial material_9, BSDFLobes lobes_10)
{
    float _S565 = dot_0(n_i_8, l_4);
    float _S566 = smithG1(alpha_14, (F32_max((_S565), (0.0f))));
    bool _S567 = (lobes_10.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S567)
    {
        float3  _S568 = anisotropicLocal(l_4, lobes_10.tangent, n_i_8);
        float _S569 = anisotropicG1(_S568, lobes_10.alphas);
        G1_l_1 = _S569;
    }
    else
    {
        G1_l_1 = _S566;
    }
    return make_float3 (lobes_10.reflect_weight * G1_l_1) * lobes_10.F / make_float3 (lobes_10.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_10, float eta_i_8, float eta_o_8, bool refracted_2, uint random_state_4, uint mask_0, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  _S570 = negate_0(in_dir_4);
    float _S571 = dot_0(n_7, _S570);
    float _S572 = sign_0(_S571);
    float3  _S573 = n_7 * make_float3 (_S572);
    AnisotropicFrame _S574 = anisotropicFrame(material_10, _S573);
    float _S575 = dot_0(_S573, out_dir_2);
    float _S576 = material_10.roughness;
    float _S577 = _S576 * _S576;
    float _S578 = sheenAlbedo(_S570, _S573, material_10);
    float _S579 = rgb_to_greyscale(material_10.translucent);
    bool _S580 = _S579 > 0.0f;
    bool _S581 = (dot_0(n_7, out_dir_2) * _S571) < 0.0f;
    uint _S582;
    if((F32_abs((material_10.toon.x))) > 0.0f)
    {
        _S582 = 5U;
    }
    else
    {
        _S582 = 4U;
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
        float3  _S583 = make_float3 (0.0f);
        (*throughputs_0)[i_6] = _S583;
        (*pdfs_0)[i_6] = 0.0f;
        uint i_7 = i_6 + 1U;
        i_6 = i_7;
    }
    float3  _S584 = make_float3 (0.0f);
    BSDFLobes _S585 = BSDFLobes_x24init_0(0.0f, 0.0f, _S584, _S584, 0.0f, 0.0f, _S584, _S584, 0.0f, 0.0f, 0.0f, 0.0f, _S584, 0.0f, _S584, _S584, make_float2 (0.0f), 0.0f, 0.0f, _S584, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S584);
    BSDFLobes sampled_terms_0 = _S585;
    bool _S586 = (mask_0 & 49U) != 0U;
    bool _S587;
    if(_S586)
    {
        if(_S580)
        {
            _S587 = _S581;
        }
        else
        {
            _S587 = false;
        }
        bool _S588 = _S587 == refracted_2;
        if(_S588)
        {
            _S587 = true;
        }
        else
        {
            bool _S589 = !refracted_2;
            if(_S589)
            {
                _S587 = _S582 > 4U;
            }
            else
            {
                _S587 = false;
            }
        }
    }
    else
    {
        _S587 = false;
    }
    if(_S587)
    {
        float3  sampled_n_0 = sampledHalf(in_dir_4, n_7, material_10, random_state_4, _S574);
        float3  _S590 = negate_0(in_dir_4);
        BSDFLobes _S591 = bsdfLobes(in_dir_4, _S590, _S573, sampled_n_0, material_10, eta_i_8, eta_o_8, _S574, _S578);
        sampled_terms_0 = _S591;
        float _S592 = translucentShare(material_10);
        (&sampled_terms_0)->translucent_share = _S592;
    }
    float3  f_1;
    if(refracted_2)
    {
        float3  _S593 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_8, eta_o_8);
        f_1 = _S593;
    }
    else
    {
        float3  _S594 = reflectedHalf(in_dir_4, out_dir_2);
        f_1 = _S594;
    }
    BSDFLobes lobe_terms_0 = _S585;
    bool _S595 = (mask_0 & 14U) != 0U;
    if(_S595)
    {
        float3  _S596 = negate_0(in_dir_4);
        BSDFLobes _S597 = bsdfLobes(in_dir_4, _S596, _S573, f_1, material_10, eta_i_8, eta_o_8, _S574, _S578);
        lobe_terms_0 = _S597;
        float _S598 = translucentShare(material_10);
        (&lobe_terms_0)->translucent_share = _S598;
    }
    i_6 = 0U;
    for(;;)
    {
        if(i_6 < _S582)
        {
        }
        else
        {
            break;
        }
        uint _S599;
        if(i_6 == 3U)
        {
            _S599 = 4U;
        }
        else
        {
            if(i_6 == 4U)
            {
                _S599 = 6U;
            }
            else
            {
                _S599 = i_6;
            }
        }
        bool _S600 = (mask_0 & (1U << i_6)) == 0U;
        if(_S600)
        {
            _S587 = true;
        }
        else
        {
            bool _S601 = _S599 == 0U;
            if(_S601)
            {
                _S587 = _S580;
            }
            else
            {
                _S587 = false;
            }
            bool _S602;
            if(_S587)
            {
                _S602 = _S581;
            }
            else
            {
                _S602 = _S599 == 1U;
            }
            _S587 = _S602 != refracted_2;
        }
        if(_S587)
        {
            uint i_8 = i_6 + 1U;
            i_6 = i_8;
            continue;
        }
        switch(_S599)
        {
        case 0U:
            {
                float _S603 = diffusePDF(_S575, 0.0f, (F32_abs((_S571))), _S577, sampled_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(0)] = _S603;
                float3  _S604 = diffuseBSDF(out_dir_2, _S573, _S577, material_10, sampled_terms_0);
                (*throughputs_0)[int(0)] = _S604;
                break;
            }
        case 1U:
            {
                float _S605 = refractPDF(_S575, dot_0(out_dir_2, f_1), (F32_abs((_S571))), _S577, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(1)] = _S605;
                float3  _S606 = refractBSDF(out_dir_2, _S573, _S577, material_10, lobe_terms_0);
                (*throughputs_0)[int(1)] = _S606;
                break;
            }
        case 4U:
            {
                float _S607 = sheenVelvetPDF(_S575, 0.0f, (F32_abs((_S571))), _S577, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(3)] = _S607;
                float3  _S608 = sheenVelvetBSDF(out_dir_2, _S573, _S577, material_10, lobe_terms_0);
                (*throughputs_0)[int(3)] = _S608;
                break;
            }
        case 6U:
            {
                float _S609 = toonPDF(_S575, dot_0(out_dir_2, (&sampled_terms_0)->toon_axis), (F32_abs((_S571))), _S577, sampled_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(4)] = _S609;
                float3  _S610 = toonBSDF(out_dir_2, _S573, _S577, material_10, sampled_terms_0);
                (*throughputs_0)[int(4)] = _S610;
                break;
            }
        default:
            {
                float _S611 = reflectPDF(_S575, 0.0f, (F32_abs((_S571))), _S577, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(2)] = _S611;
                float3  _S612 = reflectBSDF(out_dir_2, _S573, _S577, material_10, lobe_terms_0);
                (*throughputs_0)[int(2)] = _S612;
                break;
            }
        }
        uint i_8 = i_6 + 1U;
        i_6 = i_8;
    }
    i_6 = 0U;
    f_1 = _S584;
    for(;;)
    {
        if(i_6 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S613 = ((*pdfs_0)[i_6]) > 0.0f;
        if(_S613)
        {
            float3  f_2 = f_1 + (*throughputs_0)[i_6] * make_float3 ((*pdfs_0)[i_6]);
            f_1 = f_2;
        }
        uint i_9 = i_6 + 1U;
        i_6 = i_9;
    }
    return f_1;
}

__device__ float3  skyBSDF(float3  in_dir_5, float3  dir_3, FKSurface surface_1, float2  eta_1, bool is_inside_2, float pdf_0, uint random_state_5)
{
    float _S614 = eta_1.x;
    float _S615 = eta_1.y;
    bool _S616 = wrongSide_0(is_inside_2, false, dir_3, surface_1.geometry_n);
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_1;
    float3  _S617 = BSDF(in_dir_5, dir_3, surface_1.smooth_n, surface_1.material, _S614, _S615, _S616, random_state_5, 4294967295U, &throughputs_1, &pdfs_1);
    float3  _S618 = make_float3 (0.0f);
    uint i_10 = 0U;
    float3  f_3 = _S618;
    for(;;)
    {
        if(i_10 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S619 = (pdfs_1[i_10]) > 0.0f;
        if(_S619)
        {
            float3  f_4 = f_3 + throughputs_1[i_10] * make_float3 (pdfs_1[i_10]) / make_float3 (pdfs_1[i_10] + pdf_0);
            f_3 = f_4;
        }
        uint i_11 = i_10 + 1U;
        i_10 = i_11;
    }
    return f_3;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_4, float3  radiance_0, float3  color_0, uint random_state_6)
{
    SkySample _S620;
    (&_S620)->dir = dir_4;
    (&_S620)->radiance = radiance_0;
    (&_S620)->color = color_0;
    (&_S620)->random_state = random_state_6;
    return _S620;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S621 = (fcptEnvironmentCdfSize());
    uint2  _S622 = make_uint2 (1U, 0U);
    uint2  _S623 = _S621 - _S622;
    Random _S624 = pcg(init_random_state_0);
    Random _S625 = pcg(_S624.state);
    Random _S626 = pcg(_S625.state);
    Random _S627 = pcg(_S626.state);
    uint _S628 = _S623.x;
    uint _S629 = searchCDF_0(make_uint2 (_S628, 0U), make_uint2 (0U, 1U), _S623.y, _S624.value);
    uint _S630 = searchCDF_0(make_uint2 (0U, _S629), _S622, _S628, _S625.value);
    float2  _S631 = make_float2 ((float)_S623.x, (float)_S623.y);
    float2  _S632 = (make_float2 (float(_S630), float(_S629)) + make_float2 (_S626.value, _S627.value)) / _S631 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S633 = _S632.y;
    float _S634 = (F32_sin((_S633)));
    float _S635 = _S632.x;
    float3  _S636 = make_float3 (- _S634 * (F32_cos((_S635))), _S634 * (F32_sin((_S635))), (F32_cos((_S633))));
    float _S637 = environmentPdf_0(_S636);
    float3  _S638 = skyBSDF(ray_0->unit_direction, _S636, *surface_2, eta_2, is_inside_3, _S637, lobe_state_0);
    bool _S639 = !(_S637 > 0.0f);
    bool _S640;
    if(_S639)
    {
        _S640 = true;
    }
    else
    {
        _S640 = all_1(_S638 == make_float3 (0.0f));
    }
    if(_S640)
    {
        float3  _S641 = make_float3 (0.0f);
        return SkySample_x24init_0(_S636, _S641, _S641, _S627.state);
    }
    float3  _S642 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S636, context_2, _S627.state);
    return SkySample_x24init_0(_S636, _S642, _S638 * _S642, _S627.state);
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
    SampleBSDF _S643 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_6), (light_1->dir)));
    float3  _S644 = _S643.throughput * make_float3 (_S643.pdf);
    float _S645 = light_1->density;
    float _S646 = 1.0f + _S643.pdf * _S643.pdf / (light_1->density * light_1->density);
    bool _S647;
    if(competing_0)
    {
        _S647 = _S645 > 0.0f;
    }
    else
    {
        _S647 = false;
    }
    float _S648 = _slang_select(_S647, _S646,1.0f);
    return _S644 / make_float3 (_S648) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_5, float3  radiance_1, float density_0, uint random_state_7)
{
    TreeSample _S649;
    (&_S649)->dir = dir_5;
    (&_S649)->radiance = radiance_1;
    (&_S649)->density = density_0;
    (&_S649)->random_state = random_state_7;
    return _S649;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_10, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S650 = importance(first_1, p_10, normal_3);
    float _S651 = importance(second_1, p_10, normal_3);
    float2  _S652 = make_float2 (_S650, _S651);
    bool _S653 = _S650 == 0.0f;
    bool _S654;
    if(_S653)
    {
        _S654 = _S651 == 0.0f;
    }
    else
    {
        _S654 = false;
    }
    if(_S654)
    {
        return 2U;
    }
    float _S655 = _S650 + _S651;
    bool _S656 = _S651 > 0.0f;
    if(_S656)
    {
        _S654 = (*pick_0 * _S655) >= _S650;
    }
    else
    {
        _S654 = false;
    }
    uint _S657 = uint(_S654);
    float _S658 = (F32_min(((*pick_0 * _S655 - float(_S657) * _S650) / _slang_vector_get_element(_S652, _S657)), (0.99999994039535522f)));
    *pick_0 = _S658;
    float _S659 = *probability_3 * (_slang_vector_get_element(_S652, _S657) / _S655);
    *probability_3 = _S659;
    return _S657;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_11, float u1_0, float u2_0)
{
    float3  _S660 = center_1 - p_11;
    float _S661 = radius_1 * radius_1 / dot_0(_S660, _S660);
    float _S662 = u1_0 * _S661 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S661), (0.0f)))))));
    float _S663 = 2.0f * u1_0;
    bool _S664 = _S661 >= 1.0f;
    float _S665 = _slang_select(_S664, _S663,_S662);
    float _S666 = (F32_sqrt(((F32_max((_S665 * (2.0f - _S665)), (0.0f))))));
    float _S667 = 6.28318548202514648f * u2_0;
    float3  _S668 = make_float3 (_S666 * (F32_cos((_S667))), 1.0f - _S665, _S666 * (F32_sin((_S667))));
    float3  _S669 = ((((_S660)) * make_float3(rnorm3df(((_S660)).x, ((_S660)).y, ((_S660)).z))));
    float3  _S670 = tangentToWorld(_S668, _S669);
    return _S670;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S671 = center_2 - ray_1->origin;
    float _S672 = dot_0(_S671, ray_1->unit_direction);
    float _S673 = dot_0(_S671, _S671) - _S672 * _S672;
    float _S674 = radius_3 * radius_3;
    bool _S675 = _S673 > _S674;
    if(_S675)
    {
        return 4.294967296e+09f;
    }
    float _S676 = (F32_sqrt((_S674 - _S673)));
    float _S677 = _S672 - _S676;
    float _S678 = _S672 + _S676;
    bool _S679 = _S677 > 0.0000152587890625f;
    bool _S680;
    if(_S679)
    {
        _S680 = _S677 < max_len_0;
    }
    else
    {
        _S680 = false;
    }
    if(_S680)
    {
        return _S677;
    }
    bool _S681 = _S678 > 0.0000152587890625f;
    if(_S681)
    {
        _S680 = _S678 < max_len_0;
    }
    else
    {
        _S680 = false;
    }
    if(_S680)
    {
        return _S678;
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
    Random _S682 = pcg(init_random_state_1);
    Random _S683 = pcg(_S682.state);
    Random _S684 = pcg(_S683.state);
    float3  _S685 = make_float3 (0.0f);
    TreeSample _S686 = TreeSample_x24init_0(_S685, _S685, 0.0f, _S684.state);
    TreeSample sample_0 = _S686;
    float3  _S687 = _slang_select(sided_0, _S685,smooth_n_2);
    float3  _S688 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S682.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S689 = (fcptLightNode((n_8)));
        if((_S689.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S690 = (fcptLightSecond((n_8)));
        uint _S691 = n_8 + 1U;
        LightNode _S692 = (fcptLightBounds((_S691)));
        LightNode _S693 = (fcptLightBounds((_S690)));
        uint _S694 = pickChild(_S692, _S693, origin_4, _S687, &pick_1, &probability_4);
        bool _S695 = _S694 > 1U;
        if(_S695)
        {
            return sample_0;
        }
        bool _S696 = _S694 == 1U;
        uint _S697 = _slang_select(_S696, _S690,_S691);
        n_8 = _S697;
    }
    bool _S698 = n_8 == 0U;
    bool _S699;
    if(_S698)
    {
        LightNode _S700 = (fcptLightBounds((0U)));
        float _S701 = importance(_S700, origin_4, _S687);
        _S699 = !(_S701 > 0.0f);
    }
    else
    {
        _S699 = false;
    }
    if(_S699)
    {
        return sample_0;
    }
    uint4  _S702 = (fcptLightNode((n_8)));
    FKHit _S703 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S704 = (_S702.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S704)
    {
        FKLight _S705 = (fcptLight((_S702.y)));
        if(sided_0)
        {
            float _S706 = sign_0(dot_0(geometry_n_1, _S705.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S706);
            float3  _S707 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S707;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S688;
            lift_n_0 = smooth_n_2;
        }
        bool _S708 = (_S705.variance) == 0.0f;
        if(_S708)
        {
            float3  _S709 = _S705.position - emitter_point_0;
            float3  _S710 = ((((_S709)) * make_float3(rnorm3df(((_S709)).x, ((_S709)).y, ((_S709)).z))));
            (&sample_0)->dir = _S710;
            float3  _S711 = _S705.color * make_float3 (_S705.intensity) / make_float3 (dot_0(_S709, _S709) * probability_4);
            (&sample_0)->radiance = _S711;
            shadow_1 = _S709;
        }
        else
        {
            float3  _S712 = sampleSphere(_S705.position, _S705.variance, emitter_point_0, _S683.value, _S684.value);
            (&sample_0)->dir = _S712;
            float _S713 = sphereDensity(_S705.position, _S705.variance, emitter_point_0);
            float _S714 = probability_4 * _S713;
            (&sample_0)->density = _S714;
            float3  _S715 = pointLightRadiance(_S705.color, _S705.intensity, _S705.variance);
            float3  _S716 = _S715 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S716;
            FKRay _S717 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S718 = raySphere_0(_S705.position, _S705.variance, &_S717, 4.294967296e+09f);
            float3  _S719 = (&sample_0)->dir * make_float3 (_S718);
            shadow_1 = _S719;
        }
        emitter_0 = _S703;
        emitter_point_0 = _S685;
    }
    else
    {
        uint _S720 = _S702.y;
        uint _S721 = (fcptTriangleOffset((_S720)));
        uint _S722 = _S721 + _S702.z;
        Matrix<float, 3, 3>  _S723 = (fcptWorldTriangle((_S720), (_S722)));
        float _S724 = (F32_sqrt((_S683.value)));
        float2  _S725 = make_float2 (_S724 * (1.0f - _S684.value), _S724 * _S684.value);
        float3  _S726 = mul_0(make_float3 (1.0f - _S724, _S725.x, _S725.y), _S723);
        if(sided_0)
        {
            float _S727 = sign_0(dot_0(geometry_n_1, _S726 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S727);
            float3  _S728 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S728;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S729 = !((dot_0(smooth_n_2, _S726 - origin_4)) > 0.0f);
            if(_S729)
            {
                return sample_0;
            }
            emitter_point_0 = _S688;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S725, _S720, _S722, 0U, 0.0f);
        float3  _S730 = _S726 - emitter_point_0;
        float3  _S731 = ((((_S730)) * make_float3(rnorm3df(((_S730)).x, ((_S730)).y, ((_S730)).z))));
        (&sample_0)->dir = _S731;
        float _S732 = solidAngle(probability_4, cross_0(_S723.rows[int(1)] - _S723.rows[int(0)], _S723.rows[int(2)] - _S723.rows[int(0)]), _S730);
        (&sample_0)->density = _S732;
        bool _S733 = (fcptShadowFirst());
        bool _S734 = !_S733;
        if(_S734)
        {
            FKSurface _S735 = (fcptLightSurfaceAt((emitter_1), (_S726), (_S684.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S726 - origin_4))));
            (&sample_0)->random_state = _S735.random_state;
            float3  _S736 = _slang_select(_S735.skip, _S685,_S735.material.emissive);
            float3  _S737 = _S736 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S737;
        }
        shadow_1 = _S730;
        emitter_0 = emitter_1;
        emitter_point_0 = _S726;
    }
    FKHit _S738 = emitter_0;
    float3  _S739 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S684.state, &_S738);
    bool _S740 = (fcptShadowFirst());
    if(_S740)
    {
        _S699 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S699 = false;
    }
    if(_S699)
    {
        _S699 = !all_1(_S739 == _S685);
    }
    else
    {
        _S699 = false;
    }
    if(_S699)
    {
        FKSurface _S741 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S684.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S741.random_state;
        float3  _S742 = _slang_select(_S741.skip, _S685,_S741.material.emissive);
        float3  _S743 = _S742 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S743;
    }
    float3  _S744 = (&sample_0)->radiance * _S739;
    bool _S745 = all_1(_S739 == _S685);
    float3  _S746 = _slang_select(_S745, _S685,_S744);
    (&sample_0)->radiance = _S746;
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
    float _S747 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    bool _S748 = b_1 > 0.0f;
    float _S749 = _slang_select(_S748, _S747,1.0f);
    return _S749;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S750 = vertex_0->none;
    if(_S750)
    {
        return 1.0f;
    }
    uint _S751 = (fcptLightSlot((*hit_1)));
    float _S752 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S751, light_point_1);
    float _S753 = powerHeuristic(vertex_0->pdf, _S752);
    return _S753;
}

static __device__ float3  environment_0(float3  dir_6, uint depth_0, uint lobe_0)
{
    uint2  _S754 = (fcptEnvironmentMapSize());
    bool _S755 = (_S754.x) > 1U;
    bool _S756;
    if(_S755)
    {
        uint2  _S757 = (fcptEnvironmentMapSize());
        _S756 = (_S757.y) > 1U;
    }
    else
    {
        _S756 = false;
    }
    if(_S756)
    {
        float3  _S758 = (fcptEnvMapSample((dir_6), (depth_0), (lobe_0)));
        return _S758;
    }
    float3  _S759 = (fcptAmbient());
    return _S759;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S760 = (fcptEnvironmentCdfSize());
    bool _S761 = (_S760.x) > 1U;
    bool _S762;
    if(_S761)
    {
        uint2  _S763 = (fcptEnvironmentCdfSize());
        _S762 = (_S763.y) > 1U;
    }
    else
    {
        _S762 = false;
    }
    bool _S764 = !_S762;
    if(_S764)
    {
        return false;
    }
    uint2  _S765 = (fcptEnvironmentMapSize());
    bool _S766 = (_S765.x) > 1U;
    if(_S766)
    {
        uint2  _S767 = (fcptEnvironmentMapSize());
        _S762 = (_S767.y) > 1U;
    }
    else
    {
        _S762 = false;
    }
    return _S762;
}

static __device__ float escapeWeight_0(float pdf_1, float3  dir_7)
{
    bool _S768 = pdf_1 <= 0.0f;
    bool _S769;
    if(_S768)
    {
        _S769 = true;
    }
    else
    {
        bool _S770 = environmentMapped_0();
        _S769 = !_S770;
    }
    if(_S769)
    {
        return 1.0f;
    }
    float _S771 = environmentPdf_0(dir_7);
    return pdf_1 / (pdf_1 + _S771);
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
    uint2  _S772 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S773 = make_int2 ((int)_S772.x, (int)_S772.y);
    uint _S774 = previousSeed_0(_S773);
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
            uint _S775 = previousSeed_0(_S773 + make_int2 (x_16, y_5));
            bool _S776 = _S775 == _S774;
            uint _S777 = _slang_select(_S776, 1U,0U);
            uint count_3 = count_2 + _S777;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S778 = float(count_2 - 1U) / 288.0f;
    bool _S779 = _S774 != 0U;
    float _S780 = _slang_select(_S779, _S778,0.0f);
    fcptStoreDuplication((_S773), (make_uint4 ((F32_asuint((_S780))), 0U, 0U, 0U)));
    return;
}

__device__ uint stream(uint seed_2, uint index_0)
{
    uint _S781 = hash(index_0);
    uint _S782 = hash(seed_2 ^ _S781);
    return _S782;
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

__device__ float pairShare(float c_n_0, float c_pair_0, float c_sum_0)
{
    return (c_n_0 + c_pair_0) / c_sum_0;
}

__device__ float canonicalWeight(float share_0, float c_pair_1, float p_c_0, float c_n_1, float g_there_0)
{
    return share_0 * c_pair_1 * p_c_0 / (c_pair_1 * p_c_0 + c_n_1 * g_there_0);
}

static __device__ Shift Shift_x24init_0(float3  f_5, float jac_0)
{
    Shift _S783;
    (&_S783)->f = f_5;
    (&_S783)->jac = jac_0;
    return _S783;
}

__device__ float neighborWeight(float share_1, float c_n_2, float p_n_0, float c_pair_2, float g_here_0)
{
    return share_1 * c_n_2 * p_n_0 / (c_n_2 * p_n_0 + c_pair_2 * g_here_0);
}

__device__ void offer(Selection * sel_1, Reservoir candidate_0, float3  weight_0)
{
    float _S784 = rgb_to_greyscale(weight_0);
    bool _S785 = _S784 > 0.0f;
    bool _S786;
    if(_S785)
    {
        _S786 = _S784 < 3.00000000549775576e+38f;
    }
    else
    {
        _S786 = false;
    }
    bool _S787 = !_S786;
    if(_S787)
    {
        return;
    }
    bool _S788 = sel_1->sums;
    if(_S788)
    {
        float3  _S789 = sel_1->color + weight_0;
        sel_1->color = _S789;
        return;
    }
    float _S790 = sel_1->w_sum + _S784;
    sel_1->w_sum = _S790;
    float3  _S791 = sel_1->color + weight_0;
    sel_1->color = _S791;
    Random _S792 = pcg(sel_1->random_state);
    sel_1->random_state = _S792.state;
    bool _S793 = (_S792.value * sel_1->w_sum) <= _S784;
    if(_S793)
    {
        sel_1->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_2, Reservoir r_2, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_2;
    float3  _S794 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S794;
    float _S795 = r_2.jac * shifted_0.jac;
    (&candidate_1)->jac = _S795;
    offer(sel_2, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_2.w));
    return;
}

__device__ Reservoir finalize(Selection sel_3, float c_1)
{
    Reservoir r_3 = sel_3.r;
    float _S796 = rgb_to_greyscale((&r_3)->f);
    float _S797 = sel_3.w_sum / _S796;
    bool _S798 = _S796 > 0.0f;
    float _S799 = _slang_select(_S798, _S797,0.0f);
    (&r_3)->w = _S799;
    (&r_3)->c = c_1;
    return r_3;
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
    uint2  _S800 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S801 = make_int2 ((int)_S800.x, (int)_S800.y);
    float3  _S802 = make_float3 (0.0f);
    FKHit _S803 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S804 = Domain_x24init_0(_S802, _S802, &_S803, 0.0f, 0.0f);
    Domain dom_3 = _S804;
    bool _S805 = (fcptCurrentDomain((_S801), (&dom_3)));
    bool _S806 = !_S805;
    if(_S806)
    {
        Reservoir _S807 = (Reservoir{});
        fcptStoreReservoirPrevious((_S801), (_S807), ((&dom_3)->hit));
        return;
    }
    Reservoir _S808 = (fcptLoadReservoirTemporal((_S801)));
    uint t_13 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S808.c;
    for(;;)
    {
        uint _S809 = (fcptRestirNeighbours());
        if(t_13 < _S809)
        {
        }
        else
        {
            break;
        }
        int2  _S810 = partner_0(_S801, t_13);
        Domain neighbor_0 = _S804;
        bool _S811 = (fcptCurrentDomain((_S810), (&neighbor_0)));
        if(_S811)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S812 = (fcptReservoirTemporal((_S810), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S812.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_14 = t_13 + 1U;
        t_13 = t_14;
    }
    float _S813 = _S808.c / (F32_max((count_4), (1.0f)));
    float _S814 = rgb_to_greyscale(_S808.f);
    bool _S815 = count_4 == 0.0f;
    float _S816 = _slang_select(_S815, 1.0f,0.0f);
    Selection _S817 = (Selection{});
    Selection sel_4 = _S817;
    uint _S818 = (fcptFrame());
    uint _S819 = hash(_S818);
    uint _S820 = global_invocation_id_2.x;
    uint2  _S821 = (fcptRenderSize());
    uint _S822 = stream(_S819, _S820 + _S821.x * global_invocation_id_2.y);
    uint _S823 = stream(_S822, 195U);
    (&sel_4)->random_state = _S823;
    t_13 = 0U;
    float canonical_mis_0 = _S816;
    for(;;)
    {
        uint _S824 = (fcptRestirNeighbours());
        if(t_13 < _S824)
        {
        }
        else
        {
            break;
        }
        int2  _S825 = partner_0(_S801, t_13);
        Domain neighbor_dom_0 = _S804;
        bool _S826 = (fcptCurrentDomain((_S825), (&neighbor_dom_0)));
        if(_S826)
        {
            Reservoir _S827 = (fcptLoadReservoirTemporal((_S825)));
            uint4  _S828 = (fcptShiftData((_S825), (t_13)));
            float4  _S829 = asfloat_0(_S828);
            uint4  _S830 = (fcptShiftData((_S801), (t_13)));
            float4  _S831 = asfloat_0(_S830);
            float _S832 = pairShare(_S827.c, _S813, c_sum_1);
            bool _S833 = _S814 > 0.0f;
            float canonical_mis_1;
            if(_S833)
            {
                float _S834 = rgb_to_greyscale(float3 {_S831.x, _S831.y, _S831.z});
                float _S835 = canonicalWeight(_S832, _S813, _S814, _S827.c, _S834);
                float canonical_mis_2 = canonical_mis_0 + _S835;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S836 = float3 {_S829.x, _S829.y, _S829.z};
            Shift _S837 = Shift_x24init_0(_S836, _S829.w);
            float _S838 = rgb_to_greyscale(_S827.f);
            float _S839 = rgb_to_greyscale(_S836);
            float _S840 = neighborWeight(_S832, _S827.c, _S838, _S813, _S839);
            offerShifted(&sel_4, _S827, _S837, _S840);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_15 = t_13 + 1U;
        t_13 = t_15;
    }
    offerShifted(&sel_4, _S808, Shift_x24init_0(_S808.f, 1.0f), canonical_mis_0);
    Reservoir _S841 = finalize(sel_4, c_sum_1);
    fcptStoreReservoirPrevious((_S801), (_S841), ((&dom_3)->hit));
    fcptStorePreviousLayer((_S801), (5U), (make_uint4 (asuint_0((&(&dom_3)->hit)->uv).x, asuint_0((&(&dom_3)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S801), (make_float4 ((&sel_4)->color.x, (&sel_4)->color.y, (&sel_4)->color.z, 0.0f)));
    return;
}

static __device__ Shift shift_0(Domain * dom_4, Reservoir * r_4)
{
    Selection _S842 = (Selection{});
    Selection sel_5 = _S842;
    bool _S843 = (r_4->w) <= 0.0f;
    if(_S843)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S844 = passWalk_0(dom_4, r_4, true, 0.0f, &sel_5);
    return _S844;
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
    uint _S845 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S846 = _S845 != 4294967295U;
    if(_S846)
    {
        uint2  _S847 = make_uint2 (_S845, _S845 >> 14U) & make_uint2 (16383U);
        int2  _S848 = make_int2 ((int)_S847.x, (int)_S847.y);
        ShiftJob _S849 = (ShiftJob{});
        ShiftJob shift_job_0 = _S849;
        Shift _S850 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S851 = _S845 >> 28U;
        bool _S852 = spatialJob_0(_S848, _S851, &shift_job_0, true);
        Shift shifted_1;
        if(_S852)
        {
            Domain _S853 = (&shift_job_0)->dom;
            Reservoir _S854 = (&shift_job_0)->r;
            Shift _S855 = shift_0(&_S853, &_S854);
            shifted_1 = _S855;
        }
        else
        {
            shifted_1 = _S850;
        }
        fcptStoreShiftData((_S848), (_S851), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S856 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S857 = make_int2 ((int)_S856.x, (int)_S856.y);
    FixedArray<uint, 3>  _S858;
    spatialBins_0(_S857, &_S858);
    FixedArray<uint, 3>  _S859 = _S858;
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
        bool _S860 = (_S859[t_16]) == 40U;
        if(_S860)
        {
            fcptStoreShiftData((_S857), (t_16), (make_uint4 (0U)));
        }
        uint t_17 = t_16 + 1U;
        t_16 = t_17;
    }
    FixedArray<uint, 3>  _S861 = _S859;
    queueShifts_0(_S857, &_S861, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S862 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S863 = make_int2 ((int)_S862.x, (int)_S862.y);
    FixedArray<uint, 3>  _S864;
    spatialBins_0(_S863, &_S864);
    FixedArray<uint, 3>  _S865 = _S864;
    countShifts_0(&_S865, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S866 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S867 = _S866 != 4294967295U;
    if(_S867)
    {
        uint2  _S868 = make_uint2 (_S866, _S866 >> 14U) & make_uint2 (16383U);
        int2  _S869 = make_int2 ((int)_S868.x, (int)_S868.y);
        ShiftJob _S870 = (ShiftJob{});
        ShiftJob shift_job_1 = _S870;
        Shift _S871 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S872 = _S866 >> 28U;
        bool _S873 = temporalJob_0(_S869, _S872, &shift_job_1, true);
        Shift shifted_2;
        if(_S873)
        {
            if(_S872 == 1U)
            {
                Shift _S874 = (fcptShiftPrevious(((&shift_job_1)->dom), ((&shift_job_1)->r)));
                shifted_2 = _S874;
            }
            else
            {
                Domain _S875 = (&shift_job_1)->dom;
                Reservoir _S876 = (&shift_job_1)->r;
                Shift _S877 = shift_0(&_S875, &_S876);
                shifted_2 = _S877;
            }
        }
        else
        {
            shifted_2 = _S871;
        }
        fcptStoreShiftData((_S869), (_S872), (make_uint4 (asuint_1(shifted_2.f).x, asuint_1(shifted_2.f).y, asuint_1(shifted_2.f).z, (F32_asuint((shifted_2.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S878 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S879 = make_int2 ((int)_S878.x, (int)_S878.y);
    FixedArray<uint, 3>  _S880;
    temporalBins_0(_S879, &_S880);
    FixedArray<uint, 3>  _S881 = _S880;
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
        bool _S882 = (_S881[t_18]) == 40U;
        if(_S882)
        {
            fcptStoreShiftData((_S879), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S883 = _S881;
    queueShifts_0(_S879, &_S883, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S884 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S885 = make_int2 ((int)_S884.x, (int)_S884.y);
    FixedArray<uint, 3>  _S886;
    temporalBins_0(_S885, &_S886);
    FixedArray<uint, 3>  _S887 = _S886;
    countShifts_0(&_S887, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_6, float b_2, float t_20)
{
    return a_6 + (b_2 - a_6) * t_20;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S888 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S888;
}

__device__ float2  temporalWeights(float c_2, float p_c_1, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S889 = c_2 * p_c_1;
    float _S890 = c_t_0 * p_t_0;
    return make_float2 (_S889 / (_S889 + c_t_0 * g_previous_0), _S890 / (_S890 + c_2 * g_current_0));
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S891 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S892 = make_int2 ((int)_S891.x, (int)_S891.y);
    float3  _S893 = make_float3 (0.0f);
    FKHit _S894 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S895 = Domain_x24init_0(_S893, _S893, &_S894, 0.0f, 0.0f);
    Domain dom_5 = _S895;
    bool _S896 = (fcptCurrentDomain((_S892), (&dom_5)));
    bool _S897 = !_S896;
    if(_S897)
    {
        Reservoir _S898 = (Reservoir{});
        fcptStoreReservoirTemporal((_S892), (_S898), ((&dom_5)->hit));
        return;
    }
    Reservoir _S899 = (fcptLoadReservoirInitial((_S892)));
    Domain stored_0 = _S895;
    int2  _S900 = make_int2 (int(-1));
    bool _S901 = (fcptStoredDomainInitial((_S892), (_S899.seed), (&stored_0)));
    int2  q_2;
    if(_S901)
    {
        Domain _S902 = stored_0;
        int2  _S903 = temporalNeighbor_0(_S892, &_S902, _S899.seed);
        q_2 = _S903;
    }
    else
    {
        q_2 = _S900;
    }
    bool _S904 = (q_2.x) >= int(0);
    Reservoir r_5;
    if(_S904)
    {
        Reservoir _S905 = (fcptLoadReservoirPrevious((q_2)));
        uint4  _S906 = (fcptDuplication((q_2)));
        float _S907 = (U32_asfloat((_S906.x)));
        uint _S908 = (fcptRestirDecorrelation());
        bool _S909 = _S908 == 1U;
        float _S910 = _slang_select(_S909, _S907,0.0f);
        float _S911 = confidenceCap(_S910);
        float _S912 = (F32_min((_S905.c), (_S911)));
        Domain target_3 = _S895;
        bool _S913 = (_S905.w) > 0.0f;
        bool _S914;
        if(_S913)
        {
            bool _S915 = (fcptStoredDomainInitial((_S892), (_S905.seed), (&target_3)));
            _S914 = _S915;
        }
        else
        {
            _S914 = false;
        }
        if(_S914)
        {
            Domain _S916 = (fcptPreviousDomain((q_2), (_S905.seed)));
            Domain _S917 = _S916;
            Domain _S918 = target_3;
            bool _S919 = temporalIdentity_0(0U, &_S917, &_S918);
            _S914 = _S919;
        }
        else
        {
            _S914 = false;
        }
        float4  _S920;
        if(_S914)
        {
            _S920 = make_float4 (_S905.f.x, _S905.f.y, _S905.f.z, 1.0f);
        }
        else
        {
            uint4  _S921 = (fcptShiftData((_S892), (0U)));
            _S920 = asfloat_0(_S921);
        }
        bool _S922 = (_S899.w) > 0.0f;
        if(_S922)
        {
            Domain _S923 = (fcptPreviousDomain((q_2), (_S899.seed)));
            Domain _S924 = _S923;
            Domain _S925 = stored_0;
            bool _S926 = temporalIdentity_0(1U, &_S924, &_S925);
            _S914 = _S926;
        }
        else
        {
            _S914 = false;
        }
        float4  _S927;
        if(_S914)
        {
            _S927 = make_float4 (_S899.f.x, _S899.f.y, _S899.f.z, 1.0f);
        }
        else
        {
            uint4  _S928 = (fcptShiftData((_S892), (1U)));
            _S927 = asfloat_0(_S928);
        }
        float _S929 = rgb_to_greyscale(_S899.f);
        float _S930 = rgb_to_greyscale(_S905.f);
        Selection _S931 = (Selection{});
        Selection sel_6 = _S931;
        uint _S932 = (fcptFrame());
        uint _S933 = hash(_S932);
        uint _S934 = global_invocation_id_7.x;
        uint2  _S935 = (fcptRenderSize());
        uint _S936 = stream(_S933, _S934 + _S935.x * global_invocation_id_7.y);
        uint _S937 = stream(_S936, 194U);
        (&sel_6)->random_state = _S937;
        float4  _S938 = _S927;
        float _S939 = rgb_to_greyscale(float3 {_S938.x, _S938.y, _S938.z});
        float4  _S940 = _S920;
        float3  _S941 = float3 {_S940.x, _S940.y, _S940.z};
        float _S942 = rgb_to_greyscale(_S941);
        float2  _S943 = temporalWeights(_S899.c, _S929, _S912, _S930, _S939, _S942);
        offerShifted(&sel_6, _S899, Shift_x24init_0(_S899.f, 1.0f), _S943.x);
        offerShifted(&sel_6, _S905, Shift_x24init_0(_S941, _S920.w), _S943.y);
        Reservoir _S944 = finalize(sel_6, _S899.c + _S912);
        r_5 = _S944;
    }
    else
    {
        r_5 = _S899;
    }
    fcptStoreReservoirTemporal((_S892), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S945 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S946 = make_int2 ((int)_S945.x, (int)_S945.y);
    float3  _S947 = make_float3 (0.0f);
    float2  _S948 = make_float2 (0.0f);
    FKHit _S949 = Hit_x24init_0(_S948, 0U, 0U, 0U, 0.0f);
    Domain _S950 = Domain_x24init_0(_S947, _S947, &_S949, 0.0f, 0.0f);
    Domain dom_6 = _S950;
    bool _S951 = (fcptCurrentDomain((_S946), (&dom_6)));
    bool _S952 = !_S951;
    if(_S952)
    {
        Reservoir _S953 = (Reservoir{});
        fcptStoreReservoirInitial((_S946), (_S953), ((&dom_6)->hit));
        return;
    }
    uint _S954 = (fcptFrame());
    uint _S955 = hash(_S954);
    uint _S956 = global_invocation_id_8.x;
    uint2  _S957 = (fcptRenderSize());
    uint _S958 = stream(_S955, _S956 + _S957.x * global_invocation_id_8.y);
    Selection _S959 = (Selection{});
    Selection initial_0 = _S959;
    uint _S960 = stream(_S958, 193U);
    (&initial_0)->random_state = _S960;
    bool _S961 = (fcptRestirUsed());
    bool _S962 = !_S961;
    (&initial_0)->sums = _S962;
    uint _S963 = stream(_S958, 0U);
    (&(&initial_0)->r)->seed = _S963;
    FKHit _S964 = Hit_x24init_0(_S948, 4294967295U, 0U, 0U, 0.0f);
    uint _S965 = (fcptSamples());
    float _S966 = 1.0f / float(_S965);
    FKHit hit_2 = _S964;
    uint i_17 = 0U;
    for(;;)
    {
        uint _S967 = (fcptSamples());
        if(i_17 < _S967)
        {
        }
        else
        {
            break;
        }
        Reservoir _S968 = (Reservoir{});
        Reservoir r_6 = _S968;
        uint _S969 = stream(_S958, i_17);
        (&r_6)->seed = _S969;
        Domain path_0 = _S950;
        bool _S970 = (fcptStoredDomainInitial((_S946), ((&r_6)->seed), (&path_0)));
        bool _S971 = !_S970;
        if(_S971)
        {
            fcptMissed((_S946), (path_0), (_S966));
            uint i_18 = i_17 + 1U;
            i_17 = i_18;
            continue;
        }
        Domain _S972 = path_0;
        Reservoir _S973 = r_6;
        Shift _S974 = passWalk_0(&_S972, &_S973, false, _S966, &initial_0);
        bool _S975 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S975)
        {
            FKHit _S976 = (&path_0)->hit;
            hit_3 = _S976;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_18 = i_17 + 1U;
        i_17 = i_18;
    }
    float3  _S977 = (&initial_0)->glow;
    float3  _S978 = (&initial_0)->color;
    bool _S979 = (&initial_0)->sums;
    float3  _S980 = _slang_select(_S979, _S978,_S947);
    fcptAddColor((_S946), (make_float4 ((_S977 + _S980).x, (_S977 + _S980).y, (_S977 + _S980).z, 1.0f)));
    Reservoir _S981 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S946), (_S981), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_2, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S982;
    (&_S982)->none = none_0;
    (&_S982)->pdf = pdf_2;
    (&_S982)->origin = origin_5;
    (&_S982)->smooth_n = smooth_n_3;
    (&_S982)->start = start_6;
    return _S982;
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
    Vertex _S983;
    (&_S983)->rough = rough_0;
    (&_S983)->lobe = lobe_1;
    (&_S983)->pdf = pdf_3;
    (&_S983)->cos = cos_0;
    (&_S983)->inside = inside_0;
    return _S983;
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
    float3  _S984 = exp_0((make_float3 (sigma_0) - extinction_0) * make_float3 (distance_2));
    float3  _S985 = scatter_0 * _S984 / make_float3 (sigma_0);
    float3  _S986 = _slang_select(scatters_0, _S985,_S984);
    return _S986;
}

static __device__ uint arrivalLobe_0(uint b_3, uint prev_lobe_0)
{
    bool _S987 = b_3 > 0U;
    uint _S988 = _slang_select(_S987, prev_lobe_0,3U);
    return _S988;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_4, float length_2, float width_1, FKHit * own_0, bool fiber_0)
{
    ShadowContext _S989;
    (&_S989)->extinction_behind = extinction_behind_0;
    (&_S989)->extinction_front = extinction_front_0;
    (&_S989)->fillings = fillings_0;
    (&_S989)->side = side_0;
    (&_S989)->depth = depth_1;
    (&_S989)->lobe = lobe_2;
    (&_S989)->surface = surface_4;
    (&_S989)->length = length_2;
    (&_S989)->width = width_1;
    (&_S989)->own = *own_0;
    (&_S989)->fiber = fiber_0;
    return _S989;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S990 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S990)
    {
        return 0.07957746833562851f;
    }
    float _S991 = g_0 * g_0;
    return (1.0f - _S991) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S991 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_7, float3  b_4)
{
    float3  _S992 = a_7 / b_4;
    float3  _S993 = make_float3 (0.0f);
    bool3  _S994 = b_4 == _S993;
    float3  _S995 = _slang_select(_S994, _S993,_S992);
    return _S995;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S996 = (1U << count_6) - 1U;
    return (e_2 & (~(_S996 << offset_1))) | ((newbits_0 & _S996) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_6)
{
    Reservoir candidate_2 = r_7;
    uint _S997 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S998 = insertBits_0(_S997, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S998;
    (&candidate_2)->f = f_6;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    float3  _S999 = throughput_0 / make_float3 (density_1);
    return clamp_1((F32_max((_S999.x), ((F32_max((_S999.y), (_S999.z)))))), 0.0f, 1.0f);
}

static __device__ float3  isotropic_0(uint random_state_8)
{
    Random _S1000 = pcg(random_state_8);
    Random _S1001 = pcg(_S1000.state);
    float _S1002 = 1.0f - 2.0f * _S1000.value;
    float _S1003 = (F32_sqrt(((F32_max((1.0f - _S1002 * _S1002), (0.0f))))));
    float _S1004 = 6.28318548202514648f * _S1001.value;
    return make_float3 (_S1003 * (F32_cos((_S1004))), _S1003 * (F32_sin((_S1004))), _S1002);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_8, uint random_state_9, float * pdf_4)
{
    bool _S1005 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1005)
    {
        *pdf_4 = 0.07957746833562851f;
        float3  _S1006 = isotropic_0(random_state_9);
        return _S1006;
    }
    Random _S1007 = pcg(random_state_9);
    Random _S1008 = pcg(_S1007.state);
    float _S1009 = g_1 * g_1;
    float _S1010 = 2.0f * g_1;
    float _S1011 = (1.0f - _S1009) / (1.0f - g_1 + _S1010 * _S1007.value);
    float _S1012 = clamp_1((1.0f + _S1009 - _S1011 * _S1011) / _S1010, -1.0f, 1.0f);
    float _S1013 = (F32_sqrt(((F32_max((1.0f - _S1012 * _S1012), (0.0f))))));
    float _S1014 = 6.28318548202514648f * _S1008.value;
    float _S1015 = phaseHG_0(g_1, _S1012);
    *pdf_4 = _S1015;
    float3  _S1016 = tangentToWorld(make_float3 (_S1013 * (F32_cos((_S1014))), _S1012, _S1013 * (F32_sin((_S1014)))), dir_8);
    float3  _S1017 = ((((_S1016)) * make_float3(rnorm3df(((_S1016)).x, ((_S1016)).y, ((_S1016)).z))));
    return _S1017;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_2)
{
    BSDFMaterial _S1018;
    (&_S1018)->albedo = albedo_1;
    (&_S1018)->emissive = emissive_0;
    (&_S1018)->roughness = roughness_0;
    (&_S1018)->metallic = metallic_0;
    (&_S1018)->transmission = transmission_0;
    (&_S1018)->ior = ior_0;
    (&_S1018)->absorption = absorption_0;
    (&_S1018)->specular_tint = specular_tint_0;
    (&_S1018)->specular_level = specular_level_0;
    (&_S1018)->translucent = translucent_0;
    (&_S1018)->sheen = sheen_2;
    (&_S1018)->sheen_roughness = sheen_roughness_0;
    (&_S1018)->anisotropy = anisotropy_0;
    (&_S1018)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1018)->tangent = tangent_2;
    (&_S1018)->velvet = velvet_0;
    (&_S1018)->toon = toon_2;
    return _S1018;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1019;
    (&_S1019)->scatter = scatter_1;
    (&_S1019)->extinction = extinction_1;
    (&_S1019)->g = g_2;
    return _S1019;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_11, bool skip_0, uint random_state_10, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1020;
    (&_S1020)->smooth_n = smooth_n_4;
    (&_S1020)->geometry_n = geometry_n_2;
    (&_S1020)->geometry_offset = geometry_offset_2;
    (&_S1020)->material = *material_11;
    (&_S1020)->skip = skip_0;
    (&_S1020)->random_state = random_state_10;
    (&_S1020)->coverage = coverage_0;
    (&_S1020)->encloses = encloses_0;
    (&_S1020)->volume = *volume_0;
    (&_S1020)->fills = fills_0;
    (&_S1020)->hair = hair_0;
    return _S1020;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_5, float u_1)
{
    float _S1021 = surface_5->coverage;
    bool _S1022 = u_1 < _S1021;
    if(_S1022)
    {
        return *surface_5;
    }
    float3  _S1023 = make_float3 (0.0f);
    float3  _S1024 = make_float3 (1.0f);
    BSDFMaterial _S1025 = Material_x24init_0(_S1023, _S1023, 0.0f, 0.0f, 0.0f, 0.0f, _S1023, _S1024, 1.0f, _S1023, _S1023, 0.5f, 0.0f, 0.0f, _S1023, 0.0f, _S1023);
    BSDFMaterial material_12 = _S1025;
    (&material_12)->albedo = _S1024;
    (&material_12)->emissive = (&surface_5->material)->emissive;
    (&material_12)->transmission = 1.0f;
    (&material_12)->ior = 1.0f;
    (&material_12)->absorption = (&surface_5->material)->absorption;
    FKSurface through_0 = *surface_5;
    (&through_0)->material = material_12;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S1026 = transmission_1 > 0.0f;
    bool _S1027;
    if(_S1026)
    {
        _S1027 = true;
    }
    else
    {
        _S1027 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1028;
    if(_S1027)
    {
        _S1028 = 1.0f;
    }
    else
    {
        _S1028 = -1.0f;
    }
    return _S1028;
}

static __device__ bool arrivesBehind_0(float3  dir_9, float3  n_9)
{
    return (dot_0(dir_9, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_6, float3  dir_10)
{
    float3  _S1029 = surface_6->geometry_n;
    float _S1030 = facingSign((&surface_6->material)->transmission, surface_6->geometry_n, dir_10);
    FKSurface faced_0 = *surface_6;
    float3  _S1031 = surface_6->smooth_n * make_float3 (_S1030);
    (&faced_0)->smooth_n = _S1031;
    float3  _S1032 = _S1029 * make_float3 (_S1030);
    (&faced_0)->geometry_n = _S1032;
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
    float3  _S1033 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1033));
}

__device__ float2  vertexEta(BSDFMaterial material_13, float n_dot_v_0)
{
    bool _S1034 = n_dot_v_0 < 0.0f;
    float _S1035 = _slang_select(_S1034, material_13.ior,1.0f);
    float _S1036 = _slang_select(_S1034, 1.0f,material_13.ior);
    return make_float2 (_S1035, _S1036);
}

__device__ bool neeDecision(BSDFMaterial material_14, float n_dot_v_1, float eta_i_9, float eta_o_9)
{
    float _S1037 = fresnel((F32_abs((n_dot_v_1))), eta_i_9, eta_o_9);
    float3  _S1038 = mix_0(make_float3 (_S1037), material_14.albedo, material_14.metallic);
    float _S1039 = rgb_to_greyscale(_S1038);
    float _S1040 = (F32_max(((1.0f - _S1039) * (1.0f - material_14.metallic) * (1.0f - material_14.transmission)), (0.0f)));
    bool _S1041 = _S1040 > 0.03999999910593033f;
    bool _S1042;
    if(_S1041)
    {
        _S1042 = true;
    }
    else
    {
        _S1042 = (material_14.roughness) > 0.20000000298023224f;
    }
    return _S1042;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_15)
{
    float _S1043 = rgb_to_greyscale(material_15->translucent);
    bool _S1044 = _S1043 > 0.0f;
    return _S1044;
}

struct MediumSides
{
    FKMedium behind;
    FKMedium front;
    uint2  fillings;
};

static __device__ MediumSides MediumSides_x24init_0(FKMedium * behind_0, FKMedium * front_0, uint2  fillings_1)
{
    MediumSides _S1045;
    (&_S1045)->behind = *behind_0;
    (&_S1045)->front = *front_0;
    (&_S1045)->fillings = fillings_1;
    return _S1045;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_7, FKMedium * medium_0, uint filling_0, float3  dir_11, FKMedium * outside_0)
{
    MediumSides _S1046 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0));
    MediumSides sides_0 = _S1046;
    bool _S1047 = surface_7->encloses;
    if(_S1047)
    {
        (&sides_0)->behind = surface_7->volume;
        *&((&(&sides_0)->fillings)->x) = surface_7->fills;
        bool _S1048 = (dot_0(dir_11, surface_7->geometry_n)) > 0.0f;
        if(_S1048)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_8, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_12, uint depth_2, uint lobe_3, float length_3, float width_2, FKHit * own_1, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1049 = surface_8->geometry_n;
    ShadowContext _S1050 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_8->geometry_n, depth_2, lobe_3, true, length_3, width_2, own_1, fiber_1);
    bool _S1051 = surface_8->encloses;
    ShadowContext context_4;
    if(_S1051)
    {
        FKSurface faced_1 = *surface_8;
        float3  _S1052 = - _S1049;
        float3  _S1053 = _slang_select(turned_0, _S1052,_S1049);
        (&faced_1)->geometry_n = _S1053;
        FKMedium _S1054 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1055 = faced_1;
        FKMedium _S1056 = _S1054;
        MediumSides _S1057 = mediumSides_0(&_S1055, &_S1056, filling_1, dir_12, outside_1);
        ShadowContext _S1058 = ShadowContext_x24init_0(_S1057.behind.extinction, _S1057.front.extinction, _S1057.fillings, _S1049, depth_2, lobe_3, true, length_3, width_2, own_1, fiber_1);
        if(turned_0)
        {
            uint2  _S1059 = _S1057.fillings;
            ShadowContext _S1060 = ShadowContext_x24init_0(_S1057.front.extinction, _S1057.behind.extinction, uint2 {_S1059.y, _S1059.x}, _S1049, depth_2, lobe_3, true, length_3, width_2, own_1, fiber_1);
            context_4 = _S1060;
        }
        else
        {
            context_4 = _S1058;
        }
    }
    else
    {
        context_4 = _S1050;
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

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_11, bool refracted_3, uint lobe_4, float pdf_5)
{
    SampleBSDF _S1061;
    (&_S1061)->unit_direction = unit_direction_1;
    (&_S1061)->throughput = throughput_1;
    (&_S1061)->random_state = random_state_11;
    (&_S1061)->refracted = refracted_3;
    (&_S1061)->lobe = lobe_4;
    (&_S1061)->pdf = pdf_5;
    return _S1061;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_9, float n_i_dot_v_6, float alpha_15, BSDFMaterial material_16, BSDFLobes lobes_11, float eta_i_10, float eta_o_10, uint random_state_12)
{
    float3  _S1062 = make_float3 (1.0f);
    SampleBSDF _S1063 = SampleBSDF_x24init_0(_S1062, _S1062, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1063;
    Random _S1064 = pcg(random_state_12);
    Random _S1065 = pcg(_S1064.state);
    (&sample_1)->random_state = _S1065.state;
    float _S1066 = _S1064.value;
    float _S1067 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1066 * _S1066))))));
    float _S1068 = 6.28318548202514648f * _S1065.value;
    float3  _S1069 = tangentToWorld(make_float3 (_S1067 * (F32_cos((_S1068))), _S1064.value, _S1067 * (F32_sin((_S1068)))), n_i_9);
    (&sample_1)->unit_direction = _S1069;
    (&sample_1)->lobe = 4U;
    float3  _S1070 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_9, alpha_15, material_16, lobes_11);
    (&sample_1)->throughput = _S1070;
    float _S1071 = sheenVelvetPDF(_S1064.value, 0.0f, n_i_dot_v_6, alpha_15, lobes_11, eta_i_10, eta_o_10);
    (&sample_1)->pdf = _S1071;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1072 = (F32_sqrt((random_1_0)));
    float _S1073 = 6.28318548202514648f * random_2_0;
    float _S1074 = _S1072 * (F32_cos((_S1073)));
    float _S1075 = _S1072 * (F32_sin((_S1073)));
    float _S1076 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1074 * _S1074 - _S1075 * _S1075))))));
    return make_float3 (_S1074, _S1076, _S1075);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_2, float3  n_i_10, float n_i_dot_v_7, float alpha_16, BSDFMaterial material_17, BSDFLobes lobes_12, float eta_i_11, float eta_o_11, uint random_state_13)
{
    float3  _S1077 = make_float3 (1.0f);
    SampleBSDF _S1078 = SampleBSDF_x24init_0(_S1077, _S1077, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1078;
    Random _S1079 = pcg(random_state_13);
    Random _S1080 = pcg(_S1079.state);
    (&sample_2)->random_state = _S1080.state;
    float3  _S1081 = sampleCosWeightedHemisphere(_S1079.value, _S1080.value);
    bool _S1082 = u_2 < (lobes_12.p_diffuse * lobes_12.translucent_share);
    float _S1083 = _S1081.y;
    float _S1084 = - _S1083;
    float _S1085 = _slang_select(_S1082, _S1084,_S1083);
    float3  _S1086 = tangentToWorld(make_float3 (_S1081.x, _S1085, _S1081.z), n_i_10);
    (&sample_2)->unit_direction = _S1086;
    (&sample_2)->refracted = _S1082;
    (&sample_2)->lobe = 0U;
    float3  _S1087 = diffuseBSDF((&sample_2)->unit_direction, n_i_10, alpha_16, material_17, lobes_12);
    (&sample_2)->throughput = _S1087;
    float _S1088 = diffusePDF(_S1085, 0.0f, n_i_dot_v_7, alpha_16, lobes_12, eta_i_11, eta_o_11);
    (&sample_2)->pdf = _S1088;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_11, float n_i_dot_v_8, float alpha_17, BSDFMaterial material_18, BSDFLobes lobes_13, float eta_i_12, float eta_o_12, uint random_state_14)
{
    float3  _S1089 = make_float3 (1.0f);
    SampleBSDF _S1090 = SampleBSDF_x24init_0(_S1089, _S1089, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1090;
    Random _S1091 = pcg(random_state_14);
    Random _S1092 = pcg(_S1091.state);
    (&sample_3)->random_state = _S1092.state;
    float _S1093 = _S1091.value * lobes_13.toon_norm / 6.28318548202514648f;
    float t_21;
    if(lobes_13.toon_glossy)
    {
        t_21 = (F32_acos((clamp_1(1.0f - _S1093, -1.0f, 1.0f))));
    }
    else
    {
        t_21 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1093)))), (1.0f))))));
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
        float _S1094;
        if(t_21 < (lobes_13.toon_a))
        {
            _S1094 = 1.0f;
        }
        else
        {
            _S1094 = (F32_max((1.0f - (t_21 - lobes_13.toon_a) / (F32_max((lobes_13.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float integral_1;
        if(lobes_13.toon_glossy)
        {
            integral_1 = 1.0f - (F32_cos(((F32_min((t_21), (lobes_13.toon_a))))));
        }
        else
        {
            float _S1095 = (F32_sin(((F32_min((t_21), (lobes_13.toon_a))))));
            integral_1 = _S1095 * _S1095 / 2.0f;
        }
        bool _S1096 = t_21 > (lobes_13.toon_a);
        bool _S1097;
        if(_S1096)
        {
            _S1097 = (lobes_13.toon_s) > 0.0f;
        }
        else
        {
            _S1097 = false;
        }
        float integral_2;
        if(_S1097)
        {
            if(lobes_13.toon_glossy)
            {
                float _S1098 = (F32_cos((lobes_13.toon_a)));
                float _S1099 = (F32_cos((t_21)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1098 - _S1099) - ((F32_sin((t_21))) - t_21 * _S1099 - ((F32_sin((lobes_13.toon_a))) - lobes_13.toon_a * _S1098)) / lobes_13.toon_s;
            }
            else
            {
                float _S1100 = 2.0f * lobes_13.toon_a;
                float _S1101 = (F32_cos((_S1100)));
                float _S1102 = 2.0f * t_21;
                float _S1103 = (F32_cos((_S1102)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1101 - _S1103) / 4.0f - ((F32_sin((_S1102))) / 8.0f - t_21 * _S1103 / 4.0f - ((F32_sin((_S1100))) / 8.0f - lobes_13.toon_a * _S1101 / 4.0f)) / lobes_13.toon_s;
            }
            float integral_3 = integral_1 + integral_2;
            integral_2 = integral_3;
        }
        else
        {
            integral_2 = integral_1;
        }
        float _S1104 = _S1094 * (F32_sin((t_21)));
        float _S1105;
        if(lobes_13.toon_glossy)
        {
            _S1105 = 1.0f;
        }
        else
        {
            _S1105 = (F32_cos((t_21)));
        }
        float _S1106 = _S1104 * _S1105;
        float _S1107 = (integral_2 - _S1093) / _S1106;
        bool _S1108 = _S1106 > 0.0f;
        float _S1109 = _slang_select(_S1108, _S1107,0.0f);
        float _S1110 = clamp_1(t_21 - _S1109, 0.0f, lobes_13.toon_b);
        int k_1 = k_0 + int(1);
        t_21 = _S1110;
        k_0 = k_1;
    }
    float _S1111 = 6.28318548202514648f * _S1092.value;
    float _S1112 = (F32_sin((t_21)));
    float3  _S1113 = tangentToWorld(make_float3 (_S1112 * (F32_cos((_S1111))), (F32_cos((t_21))), _S1112 * (F32_sin((_S1111)))), lobes_13.toon_axis);
    (&sample_3)->unit_direction = _S1113;
    bool _S1114 = (dot_0(n_i_11, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1114;
    (&sample_3)->lobe = 6U;
    float3  _S1115 = toonBSDF((&sample_3)->unit_direction, n_i_11, alpha_17, material_18, lobes_13);
    (&sample_3)->throughput = _S1115;
    float _S1116 = toonPDF(dot_0(n_i_11, (&sample_3)->unit_direction), dot_0((&sample_3)->unit_direction, lobes_13.toon_axis), n_i_dot_v_8, alpha_17, lobes_13, eta_i_12, eta_o_12);
    (&sample_3)->pdf = _S1116;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_1, float3  n_i_12, float n_i_dot_v_9, float alpha_18, BSDFMaterial material_19, BSDFLobes lobes_14, float eta_i_13, float eta_o_13, uint random_state_15)
{
    float3  _S1117 = make_float3 (1.0f);
    SampleBSDF _S1118 = SampleBSDF_x24init_0(_S1117, _S1117, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1118;
    (&sample_4)->unit_direction = lobes_14.refracted;
    (&sample_4)->random_state = random_state_15;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1119 = refractBSDF((&sample_4)->unit_direction, n_i_12, alpha_18, material_19, lobes_14);
    (&sample_4)->throughput = _S1119;
    float _S1120 = refractPDF(0.0f, dot_0((&sample_4)->unit_direction, ggx_n_1), n_i_dot_v_9, alpha_18, lobes_14, eta_i_13, eta_o_13);
    (&sample_4)->pdf = _S1120;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_23, float3  n_10)
{
    return i_23 - make_float3 (2.0f * dot_0(n_10, i_23)) * n_10;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_7, float3  ggx_n_2, float3  n_i_13, float n_i_dot_v_10, float alpha_19, BSDFMaterial material_20, BSDFLobes lobes_15, float eta_i_14, float eta_o_14, uint random_state_16)
{
    float3  _S1121 = make_float3 (1.0f);
    SampleBSDF _S1122 = SampleBSDF_x24init_0(_S1121, _S1121, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1122;
    float3  _S1123 = reflect_0(in_dir_7, ggx_n_2);
    float3  _S1124 = ((((_S1123)) * make_float3(rnorm3df(((_S1123)).x, ((_S1123)).y, ((_S1123)).z))));
    (&sample_5)->unit_direction = _S1124;
    (&sample_5)->random_state = random_state_16;
    (&sample_5)->lobe = 2U;
    float3  _S1125 = reflectBSDF((&sample_5)->unit_direction, n_i_13, alpha_19, material_20, lobes_15);
    (&sample_5)->throughput = _S1125;
    float _S1126 = reflectPDF(0.0f, 0.0f, n_i_dot_v_10, alpha_19, lobes_15, eta_i_14, eta_o_14);
    (&sample_5)->pdf = _S1126;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_8, float3  n_11, BSDFMaterial material_21, float eta_i_15, float eta_o_15, uint random_init_0)
{
    uint random_state_17 = random_init_0;
    float3  _S1127 = negate_0(in_dir_8);
    float _S1128 = dot_0(n_11, _S1127);
    float _S1129 = sign_0(_S1128);
    float3  n_i_14 = n_11 * make_float3 (_S1129);
    float _S1130 = (F32_abs((_S1128)));
    float _S1131 = material_21.roughness;
    float _S1132 = _S1131 * _S1131;
    AnisotropicFrame _S1133 = anisotropicFrame(material_21, n_i_14);
    float _S1134 = sheenAlbedo(_S1127, n_i_14, material_21);
    float3  _S1135 = sampleHalfVector(_S1127, n_i_14, _S1132, _S1133, &random_state_17);
    BSDFLobes _S1136 = bsdfLobes(in_dir_8, _S1127, n_i_14, _S1135, material_21, eta_i_15, eta_o_15, _S1133, _S1134);
    BSDFLobes lobes_16 = _S1136;
    float _S1137 = translucentShare(material_21);
    (&lobes_16)->translucent_share = _S1137;
    Random _S1138 = pcg(random_state_17);
    random_state_17 = _S1138.state;
    bool _S1139 = (_S1138.value) < ((&lobes_16)->p_sheen_velvet);
    if(_S1139)
    {
        SampleBSDF _S1140 = sheenVelvetSample(n_i_14, _S1130, _S1132, material_21, lobes_16, eta_i_15, eta_o_15, random_state_17);
        return _S1140;
    }
    float _S1141 = _S1138.value - (&lobes_16)->p_sheen_velvet;
    bool _S1142 = _S1141 < ((&lobes_16)->p_diffuse);
    if(_S1142)
    {
        SampleBSDF _S1143 = diffuseSample(_S1141, n_i_14, _S1130, _S1132, material_21, lobes_16, eta_i_15, eta_o_15, random_state_17);
        return _S1143;
    }
    bool _S1144 = _S1141 < ((&lobes_16)->p_diffuse + (&lobes_16)->p_toon);
    if(_S1144)
    {
        SampleBSDF _S1145 = toonSample(n_i_14, _S1130, _S1132, material_21, lobes_16, eta_i_15, eta_o_15, random_state_17);
        return _S1145;
    }
    float _S1146 = (&lobes_16)->p_toon;
    bool _S1147 = (_S1141 - _S1146) < ((&lobes_16)->p_diffuse + (&lobes_16)->p_refract);
    if(_S1147)
    {
        SampleBSDF _S1148 = refractSample(_S1135, n_i_14, _S1130, _S1132, material_21, lobes_16, eta_i_15, eta_o_15, random_state_17);
        return _S1148;
    }
    SampleBSDF _S1149 = reflectSample(in_dir_8, _S1135, n_i_14, _S1130, _S1132, material_21, lobes_16, eta_i_15, eta_o_15, random_state_17);
    return _S1149;
}

static __device__ bool boundsVolume_0(FKSurface * surface_9)
{
    return surface_9->encloses;
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_8, bool replay_1, float scale_3, Selection * sel_7)
{
    float spread_1;
    bool turned_1;
    bool is_inside_4;
    bool viewed_0;
    bool _S1150;
    bool _S1151;
    float density_2;
    float threshold_0;
    float width_3;
    float sky_pdf_0;
    float geometry_density_0;
    uint b_5;
    uint layer_0;
    float3  throughput_2;
    float3  chain_throughput_0;
    TreeSample light_2;
    int _S1152;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_4;
    float sky_pdf_1;
    float spread_3;
    float width_5;
    float3  _S1153 = make_float3 (0.0f);
    Shift _S1154 = Shift_x24init_0(_S1153, 0.0f);
    uint _S1155 = r_8->path;
    uint _S1156 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1157 = extractBits_0(_S1155, 5U, 5U);
    uint _S1158 = extractBits_0(_S1155, 10U, 2U);
    uint _S1159 = extractBits_0(_S1155, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S1160 = _S1159 >= 3U;
        uint _S1161 = _slang_select(_S1160, 1U,0U);
        uint _S1162 = _S1156 + _S1161;
        uint _S1163 = (fcptMaxBounces());
        passes_0 = _S1162 > _S1163;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1154;
    }
    uint _S1164 = _S1157 - 1U;
    bool _S1165 = _S1159 == 3U;
    uint _S1166 = _slang_select(_S1165, 1U,0U);
    uint _S1167 = _S1156 + _S1166;
    bool _S1168 = _S1158 == 0U;
    uint _S1169 = _slang_select(_S1168, _S1167,_S1164);
    FKHit _S1170 = (fcptReservoirHit((*r_8)));
    float3  _S1171 = dom_7->x0;
    float3  _S1172 = dom_7->x1 - dom_7->x0;
    float3  _S1173 = ((((_S1172)) * make_float3(rnorm3df(((_S1172)).x, ((_S1172)).y, ((_S1172)).z))));
    FKRay _S1174 = Ray_x24init_0(dom_7->x1, _S1173);
    FKRay ray_2 = _S1174;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1153;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1153;
    float3  extinction_in_0 = _S1153;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1175 = dom_7->spread;
    float _S1176 = dom_7->width;
    float _S1177 = length_0(_S1172);
    NEEVertex _S1178 = NEEVertex_x24init_0(true, 0.0f, _S1153, _S1153, _S1153);
    NEEVertex nee_vertex_0 = _S1178;
    Vertex _S1179 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1179;
    Reservoir _S1180 = (Reservoir{});
    Reservoir chain_0 = _S1180;
    uint _S1181 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1171;
    (&hit_4)->distance = _S1177;
    FKMedium _S1182 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1183 = filling_2;
    bool _S1184 = (fcptVaryingUsed());
    uint _S1185 = _slang_select(_S1184, _S1183,4294967295U);
    filling_2 = _S1185;
    scatter_in_0 = _S1182.scatter;
    extinction_in_0 = _S1182.extinction;
    g_in_0 = _S1182.g;
    Reservoir _S1186 = chain_0;
    uint _S1187 = filling_2;
    for(;;)
    {
        bool _S1188 = (fcptVaryingUsed());
        if(_S1188)
        {
            passes_0 = _S1187 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1189 = (fcptMajorant((_S1187)));
            spread_1 = _S1189;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S1169;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1158 == 1U;
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
            ended_0 = _S1154;
            sky_pdf_0 = 0.0f;
            spread_1 = _S1175;
            width_3 = _S1176;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_5 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1190 = (&prev_0)->rough;
        if(_S1190)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1191 = stream(_S1181, 384U);
        uint tracking_0 = _S1191;
        weight_1 = throughput_3;
        glowed_0 = _S1153;
        b_5 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_0 = _S1175;
        width_3 = _S1176;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1152 = int(1);
                break;
            }
            uint _S1192 = b_5 + 320U;
            bool _S1193 = b_5 == 4294967295U;
            uint _S1194 = _slang_select(_S1193, 384U,_S1192);
            uint _S1195 = stream(_S1181, _S1194);
            Random _S1196 = pcg(_S1195);
            float _S1197 = - (F32_log((1.0f - _S1196.value))) / spread_1;
            if(passes_0)
            {
                float3  _S1198 = (&ray_2)->origin;
                float3  _S1199 = (&ray_2)->unit_direction;
                float _S1200 = (&hit_4)->distance;
                uint _S1201 = _slang_select(_S1193, 0U,b_5);
                uint _S1202 = (&prev_0)->lobe;
                uint _S1203 = _slang_select(_S1193, 3U,_S1202);
                float _S1204 = (fcptTrackMedium((_S1187), (_S1198), (_S1199), (_S1200), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1201), (_S1203), (_S1193)));
                geometry_density_0 = _S1204;
            }
            else
            {
                geometry_density_0 = _S1197;
            }
            bool _S1205 = !(geometry_density_0 < ((&hit_4)->distance));
            if(_S1205)
            {
                _S1152 = int(1);
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
                float3  _S1206 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1207 = sel_7->glow + _S1206;
                sel_7->glow = _S1207;
            }
            else
            {
            }
            glowed_0 = _S1153;
            uint b_6 = b_5 + 1U;
            float3  _S1208 = (&ray_2)->origin + make_float3 (geometry_density_0) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1208;
            float3  _S1209 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, geometry_density_0, true);
            float3  _S1210 = weight_1;
            float3  _S1211 = _slang_select(passes_0, _S1210,_S1209);
            float3  throughput_4 = throughput_2 * _S1211;
            uint _S1212 = stream(_S1181, b_6 + 320U);
            tracking_0 = _S1212;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_0 * geometry_density_0;
            float _S1213 = threshold_0 + 3.14159274101257324f;
            bool _S1214 = !replay_1;
            if(_S1214)
            {
                is_inside_4 = true;
            }
            else
            {
                bool _S1215 = b_6 == _S1169;
                if(_S1215)
                {
                    is_inside_4 = !passes_0;
                }
                else
                {
                    is_inside_4 = false;
                }
            }
            TreeSample _S1216 = TreeSample_x24init_0(_S1153, _S1153, 0.0f, 0U);
            if(is_inside_4)
            {
                float3  _S1217 = (&ray_2)->origin;
                float3  _S1218 = (&ray_2)->unit_direction;
                float3  _S1219 = (&ray_2)->unit_direction;
                uint _S1220 = stream(_S1181, b_6 + 64U);
                float3  _S1221 = extinction_in_0;
                float3  _S1222 = extinction_in_0;
                uint2  _S1223 = make_uint2 (_S1187);
                float3  _S1224 = (&ray_2)->unit_direction;
                uint _S1225 = arrivalLobe_0(b_6, (&prev_0)->lobe);
                FKHit _S1226 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1227 = _S1226;
                ShadowContext _S1228 = ShadowContext_x24init_0(_S1221, _S1222, _S1223, _S1224, b_6, _S1225, false, geometry_density_0, width_6, &_S1227, false);
                ShadowContext _S1229 = _S1228;
                TreeSample _S1230 = sampleLightTree_0(_S1217, _S1218, _S1219, 0.0f, true, _S1220, &_S1229);
                light_2 = _S1230;
            }
            else
            {
                light_2 = _S1216;
            }
            float _S1231 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_2.dir));
            uint _S1232 = (fcptMaxBounces());
            bool _S1233 = b_6 < _S1232;
            if(_S1233)
            {
                viewed_0 = (light_2.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S1234 = _slang_select(viewed_0, _S1231,0.0f);
            float3  _S1235 = throughput_4 * light_2.radiance;
            float _S1236 = powerHeuristic(light_2.density, _S1234);
            float3  _S1237 = _S1235 * make_float3 (_S1231 * _S1236);
            float3  _S1238 = _slang_select(is_inside_4, _S1237,_S1153);
            if(replay_1)
            {
                _S1150 = b_6 == _S1169;
            }
            else
            {
                _S1150 = false;
            }
            if(_S1150)
            {
                bool _S1239 = _S1158 == 2U;
                if(_S1239)
                {
                    float _S1240 = rgb_to_greyscale(_S1238);
                    passes_0 = _S1240 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1241 = Shift_x24init_0(_S1238, 1.0f);
                    _S1152 = int(0);
                    ended_0 = _S1241;
                    spread_1 = _S1213;
                    geometry_density_0 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                _S1152 = int(0);
                ended_0 = _S1154;
                spread_1 = _S1213;
                geometry_density_0 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_6;
                break;
            }
            if(_S1214)
            {
                Reservoir candidate_3 = _S1186;
                uint _S1242 = extractBits_0(_S1186.path, 10U, 2U);
                bool _S1243 = _S1242 == 1U;
                if(_S1243)
                {
                    float3  _S1244 = safeDivide(_S1238, _S1153);
                    (&candidate_3)->radiance = _S1244;
                }
                else
                {
                    uint _S1245 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                    uint _S1246 = insertBits_0(_S1245, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1246;
                }
                Reservoir _S1247 = withEnd(candidate_3, 0U, b_6, _S1238);
                offer(sel_7, _S1247, _S1238 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1248 = survivalProbability(throughput_4, density_2);
                uint _S1249 = stream(_S1181, b_6 + 128U);
                Random _S1250 = pcg(_S1249);
                bool _S1251 = _S1248 < (_S1250.value);
                if(_S1251)
                {
                    _S1151 = true;
                }
                else
                {
                    uint _S1252 = (fcptMaxBounces());
                    _S1151 = b_6 >= _S1252;
                }
                if(_S1151)
                {
                    _S1152 = int(0);
                    ended_0 = _S1154;
                    spread_1 = _S1213;
                    geometry_density_0 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_6;
                    break;
                }
                float _S1253 = density_2 * _S1248;
                density_2 = _S1253;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1254 = stream(_S1181, b_6);
            float3  _S1255 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1254, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1255;
            NEEVertex _S1256 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1153, (&ray_2)->origin);
            nee_vertex_0 = _S1256;
            Vertex _S1257 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_0 = _S1257;
            float _S1258 = (&prev_0)->pdf;
            FKRay _S1259 = ray_2;
            FKHit _S1260 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1261 = (fcptTraverseInstanceBVH((_S1259), (true), (4.294967296e+09f), (false), (_S1260), (false)));
            hit_4 = _S1261;
            b_5 = b_6;
            throughput_2 = throughput_4;
            threshold_0 = _S1213;
            width_3 = width_6;
            sky_pdf_0 = _S1258;
        }
        if(_S1152 != int(1))
        {
            width_3 = geometry_density_0;
            throughput_2 = chain_throughput_0;
            b_5 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1154;
        spread_1 = threshold_0;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1262 = b_5 == 4294967295U;
    bool _S1263 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1263)
    {
        bool _S1264 = !(&nee_vertex_0)->none;
        float _S1265 = _slang_select(_S1264, sky_pdf_0,0.0f);
        float _S1266 = escapeWeight_0(_S1265, (&ray_2)->unit_direction);
        float3  _S1267 = environment_0((&ray_2)->unit_direction, b_5, (&prev_0)->lobe);
        float3  _S1268 = throughput_2 * _S1267;
        if(replay_1)
        {
            bool _S1269 = b_5 == _S1169;
            if(_S1269)
            {
                passes_0 = _S1158 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1268 * make_float3 (_S1266) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1168)
            {
                passes_0 = _S1165;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_5 == _S1156;
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
                return Shift_x24init_0(_S1268 * make_float3 (_S1266), 1.0f);
            }
            return _S1154;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1270 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1271 = _S1270 == 1U;
        if(_S1271)
        {
            uint _S1272 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1273 = _S1272 == b_5;
            float _S1274 = _slang_select(_S1273, 1.0f,_S1266);
            float3  _S1275 = safeDivide(_S1268 * make_float3 (_S1274), _S1153);
            (&candidate_4)->radiance = _S1275;
        }
        else
        {
            bool _S1276 = (&prev_0)->rough;
            if(_S1276)
            {
                uint _S1277 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                uint _S1278 = insertBits_0(_S1277, 3U, 10U, 2U);
                uint _S1279 = insertBits_0(_S1278, (&prev_0)->lobe, 15U, 3U);
                bool _S1280 = (&prev_0)->inside;
                uint _S1281 = _slang_select(_S1280, 1U,0U);
                uint _S1282 = insertBits_0(_S1279, _S1281, 22U, 1U);
                (&candidate_4)->path = _S1282;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1283 = _S1268 * make_float3 (_S1266);
        Reservoir _S1284 = withEnd(candidate_4, 3U, b_5, _S1283);
        offer(sel_7, _S1284, _S1283 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1154;
    }
    float3  _S1285 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1285;
    bool _S1286 = (fcptVaryingUsed());
    if(_S1286)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1287 = !replay_1;
        if(_S1287)
        {
            float3  _S1288 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1289 = sel_7->glow + _S1288;
            sel_7->glow = _S1289;
        }
        float3  _S1290 = throughput_2 * weight_1;
        throughput_2 = _S1290;
    }
    else
    {
        float3  _S1291 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1292 = throughput_2 * _S1291;
        throughput_2 = _S1292;
    }
    float _S1293 = width_3 + spread_1 * (&hit_4)->distance;
    uint _S1294 = b_5 + 1U;
    b_5 = _S1294;
    layer_0 = 0U;
    width_3 = _S1293;
    passes_0 = false;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_4 = false;
    chain_throughput_0 = _S1153;
    float3  reconnection_0 = _S1153;
    viewed_0 = _S1262;
    for(;;)
    {
        bool _S1295 = ((&hit_4)->is_point_light) == 1U;
        if(replay_1)
        {
            _S1150 = _S1158 == 1U;
        }
        else
        {
            _S1150 = false;
        }
        if(_S1150)
        {
            _S1151 = b_5 == _S1157;
        }
        else
        {
            _S1151 = false;
        }
        bool _S1296;
        if(_S1151)
        {
            bool _S1297 = ((&hit_4)->instance_index) != (_S1170.instance_index);
            if(_S1297)
            {
                _S1296 = true;
            }
            else
            {
                _S1296 = ((&hit_4)->triangle_index) != (_S1170.triangle_index);
            }
        }
        else
        {
            _S1296 = false;
        }
        if(_S1296)
        {
            return _S1154;
        }
        FKMedium _S1298 = Medium_x24init_0(_S1153, _S1153, 0.0f);
        BSDFMaterial _S1299 = Material_x24init_0(_S1153, _S1153, 0.0f, 0.0f, 0.0f, 0.0f, _S1153, throughput_3, 1.0f, _S1153, _S1153, 0.5f, 0.0f, 0.0f, _S1153, 0.0f, _S1153);
        FKMedium _S1300 = _S1298;
        FKSurface _S1301 = Surface_x24init_0(_S1153, _S1153, 0.0f, &_S1299, false, 0U, 1.0f, false, &_S1300, 4294967295U, _S1153);
        FKSurface surface_10 = _S1301;
        bool _S1302 = !_S1295;
        bool scatter_2;
        bool is_inside_5;
        float3  throughput_5;
        if(_S1302)
        {
            uint _S1303 = stream(_S1181, b_5);
            uint _S1304 = arrivalLobe_0(b_5, (&prev_0)->lobe);
            FKSurface _S1305 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1303), (width_3), (layer_0), (b_5), (_S1304), ((&ray_2)->unit_direction)));
            surface_10 = _S1305;
            float3  _S1306 = (&(&surface_10)->material)->emissive;
            float3  _S1307 = _slang_select(passes_0, _S1153,_S1306);
            (&(&surface_10)->material)->emissive = _S1307;
            uint _S1308 = stream(_S1181, b_5 + 256U);
            Random _S1309 = pcg(_S1308);
            FKSurface _S1310 = surface_10;
            FKSurface _S1311 = uncovered_0(&_S1310, _S1309.value);
            surface_10 = _S1311;
            float _S1312 = facingSign((&(&surface_10)->material)->transmission, (&surface_10)->geometry_n, (&ray_2)->unit_direction);
            bool _S1313 = _S1312 < 0.0f;
            bool _S1314 = ((&(&surface_10)->material)->transmission) > 0.0f;
            if(_S1314)
            {
                bool _S1315 = arrivesBehind_0((&ray_2)->unit_direction, (&surface_10)->geometry_n);
                scatter_2 = _S1315;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1316 = surface_10;
            FKSurface _S1317 = facingRay_0(&_S1316, (&ray_2)->unit_direction);
            surface_10 = _S1317;
            if(passes_0)
            {
                bool _S1318 = arrivesBehind_0((&ray_2)->unit_direction, (&surface_10)->geometry_n);
                is_inside_5 = _S1318;
            }
            else
            {
                is_inside_5 = scatter_2;
            }
            if(is_inside_5)
            {
                float3  _S1319 = beerLambert((&hit_4)->distance, (&(&surface_10)->material)->absorption);
                float3  _S1320 = throughput_2 * _S1319;
                throughput_5 = _S1320;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1321 = !(&surface_10)->skip;
            float geometry_density_1 = (F32_abs((dot_0((&surface_10)->geometry_n, (&ray_2)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1322 = b_5 == _S1294;
            if(_S1322)
            {
                float _S1323 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1323;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S1324 = geometry_density_0;
            scatter_2 = _S1321;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1324;
            turned_1 = _S1313;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            throughput_5 = throughput_2;
            is_inside_5 = is_inside_4;
        }
        bool _S1325;
        if(scatter_2)
        {
            _S1325 = (&prev_0)->rough;
        }
        else
        {
            _S1325 = false;
        }
        bool _S1326;
        if(_S1325)
        {
            _S1326 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1326 = false;
        }
        BSDFMaterial _S1327 = (&surface_10)->material;
        float _S1328 = dot_0((&surface_10)->smooth_n, - (&ray_2)->unit_direction);
        float2  _S1329 = vertexEta(_S1327, _S1328);
        bool _S1330;
        if(scatter_2)
        {
            bool _S1331 = neeDecision(_S1327, _S1328, _S1329.x, _S1329.y);
            _S1330 = _S1331;
        }
        else
        {
            _S1330 = false;
        }
        bool _S1332;
        if(passes_0)
        {
            _S1332 = true;
        }
        else
        {
            _S1332 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1332)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1330;
        }
        bool _S1333 = (fcptHairUsed());
        bool _S1334;
        if(_S1333)
        {
            _S1334 = (dot_0((&surface_10)->hair, (&surface_10)->hair)) > 0.0f;
        }
        else
        {
            _S1334 = false;
        }
        bool _S1335;
        if(_S1334)
        {
            _S1335 = true;
        }
        else
        {
            BSDFMaterial _S1336 = _S1327;
            bool _S1337 = isTranslucent_0(&_S1336);
            _S1335 = _S1337;
        }
        bool _S1338;
        if(_S1335)
        {
            _S1338 = true;
        }
        else
        {
            bool _S1339 = (_S1327.transmission) > 0.0f;
            if(_S1339)
            {
                uint _S1340 = (fcptLayers((hit_4)));
                _S1338 = _S1340 == 1U;
            }
            else
            {
                _S1338 = false;
            }
        }
        float3  emission_0;
        if(_S1295)
        {
            float3  _S1341 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1341;
        }
        else
        {
            emission_0 = _S1327.emissive;
        }
        bool _S1342 = !replay_1;
        bool _S1343;
        if(_S1342)
        {
            _S1343 = true;
        }
        else
        {
            _S1343 = b_5 >= _S1169;
        }
        bool _S1344;
        if(_S1343)
        {
            float _S1345 = rgb_to_greyscale(emission_0);
            _S1344 = _S1345 > 0.0f;
        }
        else
        {
            _S1344 = false;
        }
        float3  emission_1;
        if(_S1344)
        {
            NEEVertex _S1346 = nee_vertex_0;
            FKHit _S1347 = hit_4;
            float _S1348 = emissionWeight_0(&_S1346, &_S1347, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1348);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1349;
        if(replay_1)
        {
            _S1349 = _S1158 == 1U;
        }
        else
        {
            _S1349 = false;
        }
        bool _S1350;
        if(_S1349)
        {
            _S1350 = b_5 > _S1157;
        }
        else
        {
            _S1350 = false;
        }
        bool _S1351;
        if(_S1350)
        {
            _S1351 = b_5 == _S1156;
        }
        else
        {
            _S1351 = false;
        }
        bool _S1352;
        if(_S1351)
        {
            bool _S1353 = _S1159 == 1U;
            if(_S1353)
            {
                _S1352 = true;
            }
            else
            {
                _S1352 = _S1159 == 2U;
            }
        }
        else
        {
            _S1352 = false;
        }
        if(_S1352)
        {
            bool _S1354 = _S1295 != (_S1159 == 2U);
            if(_S1354)
            {
                return _S1154;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1355 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1356 = _S1355 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1357 = insertBits_0(0U, b_5, 5U, 5U);
        uint _S1358 = insertBits_0(_S1357, 1U, 10U, 2U);
        uint _S1359 = insertBits_0(_S1358, (&prev_0)->lobe, 15U, 3U);
        bool _S1360 = (&prev_0)->inside;
        uint _S1361 = _slang_select(_S1360, 1U,0U);
        uint _S1362 = insertBits_0(_S1359, _S1361, 22U, 1U);
        (&here_0)->path = _S1362;
        float _S1363 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S1363;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1364;
        if(replay_1)
        {
            _S1364 = _S1158 == 1U;
        }
        else
        {
            _S1364 = false;
        }
        bool _S1365;
        if(_S1364)
        {
            _S1365 = b_5 == _S1157;
        }
        else
        {
            _S1365 = false;
        }
        bool _S1366 = b_5 == _S1169;
        bool _S1367;
        if(_S1366)
        {
            bool _S1368 = !scatter_2;
            if(_S1368)
            {
                _S1367 = true;
            }
            else
            {
                bool _S1369 = _S1158 != 1U;
                if(_S1369)
                {
                    _S1367 = _S1158 != 3U;
                }
                else
                {
                    _S1367 = false;
                }
            }
        }
        else
        {
            _S1367 = false;
        }
        bool _S1370;
        if(_S1367)
        {
            _S1370 = _S1158 == 2U;
        }
        else
        {
            _S1370 = false;
        }
        bool _S1371;
        if(_S1370)
        {
            _S1371 = !_S1326;
        }
        else
        {
            _S1371 = false;
        }
        bool _S1372;
        if(_S1371)
        {
            _S1372 = _S1159 != 4U;
        }
        else
        {
            _S1372 = false;
        }
        bool _S1373 = _S1157 == _S1156;
        bool _S1374;
        if(_S1373)
        {
            _S1374 = _S1159 == 0U;
        }
        else
        {
            _S1374 = false;
        }
        bool _S1375;
        if(_S1374)
        {
            _S1375 = ((&hit_4)->instance_index) == (_S1170.instance_index);
        }
        else
        {
            _S1375 = false;
        }
        bool _S1376;
        if(_S1375)
        {
            _S1376 = ((&hit_4)->triangle_index) == (_S1170.triangle_index);
        }
        else
        {
            _S1376 = false;
        }
        bool _S1377;
        if(_S1376)
        {
            _S1377 = _S1326;
        }
        else
        {
            _S1377 = false;
        }
        bool _S1378 = _slang_select(_S1365, _S1377,_S1372);
        bool _S1379;
        if(nee_0)
        {
            _S1379 = _slang_select(replay_1, _S1378,scatter_2);
        }
        else
        {
            _S1379 = false;
        }
        TreeSample _S1380 = TreeSample_x24init_0(_S1153, _S1153, 0.0f, 0U);
        uint2  _S1381 = make_uint2 (0U);
        FKHit _S1382 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1383 = _S1382;
        ShadowContext _S1384 = ShadowContext_x24init_0(_S1153, _S1153, _S1381, _S1153, 0U, 0U, false, 0.0f, 0.0f, &_S1383, false);
        bool _S1385;
        if(nee_0)
        {
            _S1385 = _S1343;
        }
        else
        {
            _S1385 = false;
        }
        ShadowContext context_5;
        if(_S1385)
        {
            uint _S1386 = arrivalLobe_0(b_5, (&prev_0)->lobe);
            FKMedium _S1387 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1388 = surface_10;
            FKHit _S1389 = hit_4;
            FKMedium _S1390 = _S1387;
            ShadowContext _S1391 = shadowContext_0(&_S1388, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_5, _S1386, (&hit_4)->distance, width_3, &_S1389, _S1334, &_S1390);
            context_5 = _S1391;
        }
        else
        {
            context_5 = _S1384;
        }
        bool viewed_1;
        uint b_7;
        float3  throughput_6;
        float3  lit_0;
        if(_S1379)
        {
            float3  _S1392 = (&ray_2)->origin;
            if(_S1334)
            {
                throughput_6 = _S1153;
            }
            else
            {
                throughput_6 = (&surface_10)->smooth_n;
            }
            uint _S1393 = stream(_S1181, b_5 + 64U);
            ShadowContext _S1394 = context_5;
            TreeSample _S1395 = sampleLightTree_0(_S1392, throughput_6, (&surface_10)->geometry_n, (&surface_10)->geometry_offset, _S1338, _S1393, &_S1394);
            bool _S1396 = any_1((_S1395.radiance) != _S1153);
            if(_S1396)
            {
                if(_S1334)
                {
                    uint _S1397 = (fcptMaxBounces());
                    bool _S1398 = b_5 < _S1397;
                    FKSurface _S1399 = surface_10;
                    TreeSample _S1400 = _S1395;
                    float3  _S1401 = hairLight_0(&_S1399, (&ray_2)->unit_direction, &_S1400, _S1398);
                    lit_0 = _S1401;
                }
                else
                {
                    FixedArray<float3 , 5>  throughputs_2;
                    FixedArray<float, 5>  pdfs_2;
                    float3  _S1402 = BSDF((&ray_2)->unit_direction, _S1395.dir, (&surface_10)->smooth_n, _S1327, _S1329.x, _S1329.y, (dot_0((&surface_10)->geometry_n, - (&ray_2)->unit_direction) * dot_0((&surface_10)->geometry_n, _S1395.dir)) <= 0.0f, (&surface_10)->random_state, 4294967295U, &throughputs_2, &pdfs_2);
                    uint _S1403 = (fcptMaxBounces());
                    bool _S1404 = !(b_5 < _S1403);
                    if(_S1404)
                    {
                        viewed_1 = true;
                    }
                    else
                    {
                        viewed_1 = (_S1395.density) == 0.0f;
                    }
                    if(viewed_1)
                    {
                        float3  _S1405 = _S1402 * _S1395.radiance;
                        lit_0 = _S1405;
                    }
                    else
                    {
                        b_7 = 0U;
                        lit_0 = _S1153;
                        for(;;)
                        {
                            if(b_7 < 5U)
                            {
                            }
                            else
                            {
                                break;
                            }
                            bool _S1406 = (pdfs_2[b_7]) > 0.0f;
                            if(_S1406)
                            {
                                float _S1407 = pdfs_2[b_7] / _S1395.density;
                                float3  lit_1 = lit_0 + throughputs_2[b_7] * make_float3 (pdfs_2[b_7]) / make_float3 (_S1395.density * (1.0f + _S1407 * _S1407));
                                lit_0 = lit_1;
                            }
                            uint i_24 = b_7 + 1U;
                            b_7 = i_24;
                        }
                        float3  _S1408 = lit_0 * _S1395.radiance * make_float3 (_S1395.density);
                        lit_0 = _S1408;
                    }
                }
            }
            else
            {
                lit_0 = _S1153;
            }
            light_2 = _S1395;
        }
        else
        {
            light_2 = _S1380;
            lit_0 = _S1153;
        }
        bool refracted_4;
        bool wrong_side_0;
        bool _S1409;
        bool _S1410;
        float density_4;
        if(_S1365)
        {
            bool _S1411 = !_S1326;
            if(_S1411)
            {
                return _S1154;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S1373)
            {
                viewed_1 = _S1159 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1373)
            {
                refracted_4 = _S1159 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1412 = !nee_0;
                if(_S1412)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1413 = rgb_to_greyscale(light_2.radiance);
                    passes_0 = !(_S1413 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1154;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1373)
            {
                wrong_side_0 = _S1159 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1414 = !nee_0;
                if(_S1414)
                {
                    return _S1154;
                }
                float _S1415 = environmentPdf_0(r_8->dir);
                float3  _S1416 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_10, _S1329, is_inside_5, _S1415, (&surface_10)->random_state);
                return Shift_x24init_0(throughput_7 * _S1416 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1417 = extractBits_0(_S1155, 21U, 1U);
            bool _S1418 = nee_0 != (_S1417 == 1U);
            if(_S1418)
            {
                return _S1154;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S1366;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1419 = !scatter_2;
                if(_S1419)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1420 = _S1158 != 1U;
                    if(_S1420)
                    {
                        refracted_4 = _S1158 != 3U;
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
                bool _S1421 = _S1158 == 2U;
                if(_S1421)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1326;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1159 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1334)
                    {
                        return _S1154;
                    }
                    uint _S1422 = stream(_S1181, b_5 + 448U);
                    FKRay _S1423 = ray_2;
                    FKSurface _S1424 = surface_10;
                    ShadowContext _S1425 = context_5;
                    SkySample _S1426 = sampleSky_0(&_S1423, &_S1424, _S1329, is_inside_5, _S1422, (&surface_10)->random_state, &_S1425);
                    return Shift_x24init_0(throughput_5 * _S1426.color, 1.0f);
                }
                if(_S1421)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1326;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1427 = rgb_to_greyscale(light_2.radiance);
                    bool _S1428 = !(_S1427 > 0.0f);
                    if(_S1428)
                    {
                        return _S1154;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S1168)
                {
                    passes_0 = _S1159 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1295;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S1168)
                {
                    passes_0 = _S1159 == 1U;
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
                    passes_0 = !_S1326;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S1154;
            }
            else
            {
                if(_S1342)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1429 = b_5 > 0U;
                    if(_S1429)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1356)
                        {
                            float3  _S1430 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1430;
                        }
                        else
                        {
                            if(_S1326)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1431 = throughput_5 * emission_1;
                        Reservoir _S1432 = withEnd(candidate_5, 1U, b_5, _S1431);
                        offer(sel_7, _S1432, _S1431 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1433 = throughput_5 * emission_1;
                        float3  _S1434 = sel_7->glow + _S1433;
                        sel_7->glow = _S1434;
                    }
                    if(nee_0)
                    {
                        float3  _S1435 = throughput_5 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1356)
                        {
                            float3  _S1436 = safeDivide(_S1435, chain_throughput_0);
                            (&candidate_6)->radiance = _S1436;
                        }
                        else
                        {
                            if(_S1326)
                            {
                                candidate_6 = here_0;
                                uint _S1437 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1437;
                                (&candidate_6)->dir = light_2.dir;
                                (&candidate_6)->radiance = light_2.radiance;
                            }
                            else
                            {
                                uint _S1438 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                                uint _S1439 = insertBits_0(_S1438, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1439;
                            }
                        }
                        Reservoir _S1440 = withEnd(candidate_6, 0U, b_5, _S1435);
                        offer(sel_7, _S1440, _S1435 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1334)
                        {
                            _S1409 = false;
                        }
                        else
                        {
                            bool _S1441 = environmentMapped_0();
                            _S1409 = _S1441;
                        }
                    }
                    else
                    {
                        _S1409 = false;
                    }
                    if(_S1409)
                    {
                        uint _S1442 = (fcptMaxBounces());
                        _S1410 = b_5 < _S1442;
                    }
                    else
                    {
                        _S1410 = false;
                    }
                    if(_S1410)
                    {
                        uint _S1443 = stream(_S1181, b_5 + 448U);
                        FKRay _S1444 = ray_2;
                        FKSurface _S1445 = surface_10;
                        ShadowContext _S1446 = context_5;
                        SkySample _S1447 = sampleSky_0(&_S1444, &_S1445, _S1329, is_inside_5, _S1443, (&surface_10)->random_state, &_S1446);
                        float3  _S1448 = throughput_5 * _S1447.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1356)
                        {
                            float3  _S1449 = safeDivide(_S1448, chain_throughput_0);
                            (&candidate_7)->radiance = _S1449;
                        }
                        else
                        {
                            if(_S1326)
                            {
                                candidate_7 = here_0;
                                uint _S1450 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1450;
                                (&candidate_7)->dir = _S1447.dir;
                                (&candidate_7)->radiance = _S1447.radiance;
                            }
                            else
                            {
                                uint _S1451 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                                uint _S1452 = insertBits_0(_S1451, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1452;
                            }
                        }
                        Reservoir _S1453 = withEnd(candidate_7, 4U, b_5, _S1448);
                        offer(sel_7, _S1453, _S1448 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1454;
        bool _S1455;
        bool _S1456;
        bool straight_0;
        bool _S1457;
        bool _S1458;
        bool _S1459;
        bool _S1460;
        bool _S1461;
        bool _S1462;
        bool _S1463;
        bool _S1464;
        bool _S1465;
        bool _S1466;
        bool _S1467;
        bool _S1468;
        bool _S1469;
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
                viewed_1 = _S1366;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1470 = extractBits_0(_S1155, 15U, 3U);
            uint _S1471 = extractBits_0(_S1155, 18U, 3U);
            uint _S1472 = _slang_select(_S1365, _S1471,_S1470);
            float3  _S1473 = r_8->dir;
            bool refracted_5 = _S1472 == 1U;
            SampleBSDF _S1474 = SampleBSDF_x24init_0(_S1153, _S1153, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1474;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1475 = extractBits_0(_S1155, 22U, 1U);
                bool _S1476 = is_inside_5 != (_S1475 == 1U);
                if(_S1476)
                {
                    return _S1154;
                }
                bool _S1477 = _S1158 == 1U;
                if(_S1477)
                {
                    float3  _S1478 = (fcptHitPosition((_S1170)));
                    throughput_8 = _S1478;
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
                    BSDFMaterial _S1479 = _S1327;
                    bool _S1480 = isTranslucent_0(&_S1479);
                    if(_S1480)
                    {
                        refracted_4 = _S1472 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1481 = (&surface_10)->smooth_n;
                        float3  _S1482 = throughput_8 - (&ray_2)->origin;
                        float3  _S1483 = _slang_select(_S1477, _S1482,_S1473);
                        wrong_side_0 = (dot_0(_S1481, _S1483) * _S1328) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1477)
                {
                    float3  _S1484 = (&ray_2)->origin;
                    float _S1485 = (&surface_10)->geometry_offset;
                    float3  _S1486 = (&surface_10)->smooth_n;
                    float3  _S1487 = - (&surface_10)->smooth_n;
                    bool _S1488 = is_inside_5 != refracted_4;
                    float3  _S1489 = _slang_select(_S1488, _S1487,_S1486);
                    float3  _S1490 = throughput_8 - (_S1484 + make_float3 (_S1485) * _S1489);
                    float3  _S1491 = ((((_S1490)) * make_float3(rnorm3df(((_S1490)).x, ((_S1490)).y, ((_S1490)).z))));
                    reconnection_1 = _S1491;
                }
                else
                {
                    reconnection_1 = _S1473;
                }
                if(_S1334)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1492 = wrongSide_0(is_inside_5, refracted_4, reconnection_1, (&surface_10)->geometry_n);
                    wrong_side_0 = _S1492;
                }
                if(wrong_side_0)
                {
                    return _S1154;
                }
                float3  _S1493 = throughput_8;
                throughput_8 = reconnection_1;
                b_7 = _S1472;
                wrong_side_0 = false;
                reconnection_1 = _S1493;
            }
            else
            {
                bool _S1494 = !_S1365;
                if(_S1494)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1495;
                    if(_S1334)
                    {
                        SampleBSDF _S1496 = (fcptSampleHair(((&surface_10)->hair), (_S1327.albedo), (_S1327.specular_tint), ((&ray_2)->unit_direction), ((&surface_10)->random_state)));
                        _S1495 = _S1496;
                    }
                    else
                    {
                        SampleBSDF _S1497 = sampleBSDF((&ray_2)->unit_direction, (&surface_10)->smooth_n, _S1327, _S1329.x, _S1329.y, (&surface_10)->random_state);
                        _S1495 = _S1497;
                    }
                    bsdf_sampled_0 = _S1495;
                    if(_S1334)
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
                            return _S1154;
                        }
                        break;
                    }
                    if(_S1334)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1498 = wrongSide_0(is_inside_5, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, (&surface_10)->geometry_n);
                        wrong_side_0 = _S1498;
                    }
                    if(wrong_side_0)
                    {
                        _S1409 = (_S1327.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1409 = false;
                    }
                    if(_S1409)
                    {
                        SampleBSDF _S1499 = sampleBSDF((&bsdf_sampled_0)->unit_direction, (&surface_10)->geometry_n, _S1327, _S1329.x, _S1329.y, (&bsdf_sampled_0)->random_state);
                        (&bsdf_sampled_0)->unit_direction = _S1499.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1499.refracted;
                        (&bsdf_sampled_0)->throughput = _S1499.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1500 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, (&surface_10)->geometry_n)) * (&surface_10)->geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1500;
                        }
                    }
                    uint _S1501 = (&bsdf_sampled_0)->lobe;
                    float3  _S1502 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1503 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1504 = (&bsdf_sampled_0)->pdf;
                    float _S1505 = _slang_select(wrong_side_0, 0.0f,_S1504);
                    (&lobe_5)->pdf = _S1505;
                    throughput_8 = _S1502;
                    b_7 = _S1501;
                    refracted_4 = _S1503;
                }
                else
                {
                    throughput_8 = _S1473;
                    b_7 = _S1472;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1409 = true;
            }
            else
            {
                _S1409 = _S1365;
            }
            if(_S1409)
            {
                if(_S1334)
                {
                    SampleBSDF _S1506 = (fcptConnectHair(((&surface_10)->hair), (_S1327.albedo), (_S1327.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    lobe_5 = _S1506;
                }
                else
                {
                    if(b_7 == 4U)
                    {
                        b_8 = 3U;
                    }
                    else
                    {
                        if(b_7 == 6U)
                        {
                            b_8 = 4U;
                        }
                        else
                        {
                            b_8 = b_7;
                        }
                    }
                    float _S1507 = _S1329.x;
                    float _S1508 = _S1329.y;
                    bool _S1509 = wrongSide_0(is_inside_5, false, throughput_8, (&surface_10)->geometry_n);
                    FixedArray<float3 , 5>  throughputs_3;
                    FixedArray<float, 5>  pdfs_3;
                    float3  _S1510 = BSDF((&ray_2)->unit_direction, throughput_8, (&surface_10)->smooth_n, _S1327, _S1507, _S1508, _S1509, (&surface_10)->random_state, 1U << b_8, &throughputs_3, &pdfs_3);
                    bool _S1511 = (pdfs_3[b_8]) > 0.0f;
                    if(_S1511)
                    {
                        SampleBSDF _S1512 = SampleBSDF_x24init_0(throughput_8, throughputs_3[b_8], (&surface_10)->random_state, b_7 == 1U, b_7, pdfs_3[b_8]);
                        lobe_5 = _S1512;
                    }
                }
            }
            bool _S1513 = b_7 == 0U;
            if(_S1513)
            {
                _S1410 = true;
            }
            else
            {
                _S1410 = b_7 == 4U;
            }
            if(_S1410)
            {
                _S1454 = true;
            }
            else
            {
                _S1454 = b_7 == 6U;
            }
            if(_S1334)
            {
                _S1455 = false;
            }
            else
            {
                bool _S1514 = !_S1454;
                if(_S1514)
                {
                    bool _S1515 = (_S1327.roughness) == 0.0f;
                    if(_S1515)
                    {
                        _S1455 = true;
                    }
                    else
                    {
                        bool _S1516 = b_7 == 1U;
                        if(_S1516)
                        {
                            _S1455 = (_S1329.x) == (_S1329.y);
                        }
                        else
                        {
                            _S1455 = false;
                        }
                    }
                }
                else
                {
                    _S1455 = false;
                }
            }
            bool _S1517 = !_S1334;
            if(_S1517)
            {
                _S1456 = b_7 == 1U;
            }
            else
            {
                _S1456 = false;
            }
            if(_S1456)
            {
                straight_0 = (_S1327.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1457 = _S1517;
            }
            else
            {
                _S1457 = false;
            }
            if(_S1457)
            {
                _S1458 = b_7 == 1U;
            }
            else
            {
                _S1458 = false;
            }
            if(_S1458)
            {
                _S1459 = (_S1329.x) == (_S1329.y);
            }
            else
            {
                _S1459 = false;
            }
            BSDFMaterial _S1518 = _S1327;
            bool _S1519 = isTranslucent_0(&_S1518);
            if(_S1519)
            {
                _S1460 = _S1513;
            }
            else
            {
                _S1460 = false;
            }
            if(_S1460)
            {
                _S1461 = (dot_0(throughput_8, (&surface_10)->geometry_n)) < 0.0f;
            }
            else
            {
                _S1461 = false;
            }
            if(nee_0)
            {
                _S1462 = !_S1455;
            }
            else
            {
                _S1462 = false;
            }
            if(_S1462)
            {
                _S1463 = !wrong_side_0;
            }
            else
            {
                _S1463 = false;
            }
            if(_S1463)
            {
                float _S1520 = (&lobe_5)->pdf;
                float3  _S1521 = (&ray_2)->origin;
                float3  _S1522 = (&surface_10)->smooth_n;
                float3  _S1523 = _slang_select(_S1338, _S1153,_S1522);
                float3  _S1524 = (&ray_2)->origin;
                float _S1525 = (&surface_10)->geometry_offset;
                float3  _S1526 = (&surface_10)->smooth_n;
                float3  _S1527 = - (&surface_10)->smooth_n;
                float3  _S1528 = _slang_select(_S1461, _S1527,_S1526);
                NEEVertex _S1529 = NEEVertex_x24init_0(false, _S1520, _S1521, _S1523, _S1524 + make_float3 (_S1525) * _S1528);
                nee_vertex_0 = _S1529;
            }
            else
            {
                if(_S1334)
                {
                    _S1464 = true;
                }
                else
                {
                    bool _S1530 = b_7 != 1U;
                    if(_S1530)
                    {
                        _S1464 = true;
                    }
                    else
                    {
                        _S1464 = (_S1329.x) != (_S1329.y);
                    }
                }
                if(_S1464)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1531 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1531)
            {
                if(_S1454)
                {
                    _S1464 = true;
                }
                else
                {
                    _S1464 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1464 = false;
            }
            bool _S1532 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1532)
            {
                if(_S1454)
                {
                    _S1465 = true;
                }
                else
                {
                    _S1465 = (_S1327.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1465 = false;
            }
            if(_S1365)
            {
                bool _S1533 = !_S1464;
                if(_S1533)
                {
                    return _S1154;
                }
                bool _S1534 = _S1159 != 1U;
                if(_S1534)
                {
                    _S1466 = _S1159 != 2U;
                }
                else
                {
                    _S1466 = false;
                }
                if(_S1466)
                {
                    float _S1535 = (&lobe_5)->pdf;
                    float _S1536 = _slang_select(nee_0, _S1535,0.0f);
                    float _S1537 = escapeWeight_0(_S1536, _S1473);
                    if(_S1373)
                    {
                        passes_0 = _S1165;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1538 = _slang_select(passes_0, _S1537,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1538) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1539 = throughput_6 * make_float3 ((&lobe_5)->pdf);
                float _S1540 = density_4 * (&lobe_5)->pdf;
                throughput_9 = _S1539;
                density_6 = _S1540;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1541 = (fcptLayers((hit_4)));
            bool _S1542 = _S1541 > 1U;
            if(_S1542)
            {
                _S1466 = (b_7 == 1U) != passes_0;
            }
            else
            {
                _S1466 = false;
            }
            if(viewed_1)
            {
                _S1467 = _S1466;
            }
            else
            {
                _S1467 = false;
            }
            if(_S1467)
            {
                return _S1154;
            }
            if(replay_1)
            {
                _S1468 = b_5 <= _S1169;
            }
            else
            {
                _S1468 = false;
            }
            if(_S1468)
            {
                _S1469 = _S1326;
            }
            else
            {
                _S1469 = false;
            }
            bool _S1543;
            if(_S1469)
            {
                _S1543 = _S1464;
            }
            else
            {
                _S1543 = false;
            }
            bool _S1544;
            if(_S1543)
            {
                _S1544 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1544 = !_S1465;
                }
                else
                {
                    _S1544 = false;
                }
            }
            if(_S1544)
            {
                return _S1154;
            }
            if(viewed_1)
            {
                float3  _S1545 = throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1546 = (&lobe_5)->pdf;
                throughput_10 = _S1545;
                sky_pdf_2 = _S1546;
            }
            else
            {
                float3  _S1547 = throughput_9 * max_0((&lobe_5)->throughput, _S1153);
                throughput_10 = _S1547;
                sky_pdf_2 = density_6;
            }
            bool _S1548;
            if(_S1342)
            {
                _S1548 = !_S1356;
            }
            else
            {
                _S1548 = false;
            }
            bool _S1549;
            if(_S1548)
            {
                _S1549 = _S1326;
            }
            else
            {
                _S1549 = false;
            }
            bool _S1550;
            if(_S1549)
            {
                _S1550 = _S1464;
            }
            else
            {
                _S1550 = false;
            }
            float3  chain_throughput_1;
            if(_S1550)
            {
                chain_0 = here_0;
                uint _S1551 = insertBits_0((&chain_0)->path, b_7, 18U, 3U);
                uint _S1552 = _slang_select(nee_0, 1U,0U);
                uint _S1553 = insertBits_0(_S1551, _S1552, 21U, 1U);
                (&chain_0)->path = _S1553;
                float _S1554 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1554;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            Vertex _S1555 = Vertex_x24init_0(_S1465, b_7, (&lobe_5)->pdf, (F32_abs((dot_0((&surface_10)->geometry_n, throughput_8)))), is_inside_5);
            prev_0 = _S1555;
            float _S1556 = (&lobe_5)->pdf;
            bool _S1557 = b_7 == 1U;
            bool _S1558;
            if(_S1557)
            {
                _S1558 = (_S1329.x) == (_S1329.y);
            }
            else
            {
                _S1558 = false;
            }
            float sky_pdf_3 = _slang_select(_S1558, sky_pdf_0,_S1556);
            float _S1559 = _slang_select(_S1334, 0.0f,sky_pdf_3);
            float _S1560 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1561 = !_S1455;
            float _S1562 = _slang_select(_S1561, _S1560,0.0f);
            float _S1563 = spread_1 + _S1562;
            bool _S1564;
            if(refracted_4)
            {
                _S1564 = !_S1461;
            }
            else
            {
                _S1564 = false;
            }
            bool is_inside_6;
            if(_S1564)
            {
                bool _S1565 = !is_inside_5;
                is_inside_6 = _S1565;
            }
            else
            {
                is_inside_6 = is_inside_5;
            }
            FKSurface _S1566 = surface_10;
            bool _S1567 = boundsVolume_0(&_S1566);
            bool _S1568;
            if(_S1567)
            {
                _S1568 = !_S1466;
            }
            else
            {
                _S1568 = false;
            }
            if(_S1568)
            {
                FKSurface faced_2 = surface_10;
                float3  _S1569 = (&surface_10)->geometry_n;
                float3  _S1570 = - (&surface_10)->geometry_n;
                float3  _S1571 = _slang_select(turned_1, _S1570,_S1569);
                (&faced_2)->geometry_n = _S1571;
                FKMedium _S1572 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1573 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1574 = faced_2;
                FKMedium _S1575 = _S1572;
                FKMedium _S1576 = _S1573;
                MediumSides _S1577 = mediumSides_0(&_S1574, &_S1575, filling_2, (&ray_2)->unit_direction, &_S1576);
                bool _S1578 = ((dot_0(throughput_8, (&surface_10)->geometry_n)) > 0.0f) == ((dot_0((&surface_10)->geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1579 = _slang_select(_S1578, _S1577.front.scatter,_S1577.behind.scatter);
                scatter_in_0 = _S1579;
                float3  _S1580 = _slang_select(_S1578, _S1577.front.extinction,_S1577.behind.extinction);
                extinction_in_0 = _S1580;
                float _S1581 = _slang_select(_S1578, _S1577.front.g,_S1577.behind.g);
                g_in_0 = _S1581;
                uint _S1582 = _S1577.fillings.x;
                uint _S1583 = _S1577.fillings.y;
                uint _S1584 = _slang_select(_S1578, _S1583,_S1582);
                bool _S1585 = (fcptVaryingUsed());
                uint _S1586 = _slang_select(_S1585, _S1584,4294967295U);
                filling_2 = _S1586;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1587 = !_S1466;
            if(_S1587)
            {
                float _S1588 = (&surface_10)->geometry_offset;
                float _S1589 = _slang_select(straight_0, 0.0f,_S1588);
                float3  _S1590 = (&surface_10)->smooth_n;
                float3  _S1591 = - (&surface_10)->smooth_n;
                bool _S1592 = is_inside_6 != _S1461;
                float3  _S1593 = _slang_select(_S1592, _S1591,_S1590);
                float3  _S1594 = (&ray_2)->origin + make_float3 (_S1589) * _S1593;
                (&ray_2)->origin = _S1594;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1466;
            viewed_1 = _S1459;
            sky_pdf_2 = _S1559;
            spread_4 = _S1563;
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
            spread_4 = spread_1;
            straight_0 = false;
            is_inside_4 = is_inside_5;
        }
        float density_7;
        if(_S1342)
        {
            if(_S1295)
            {
                float3  _S1595 = throughput_9 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1596 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1597 = _S1596 == 1U;
                if(_S1597)
                {
                    float3  _S1598 = safeDivide(_S1595, chain_throughput_0);
                    (&candidate_8)->radiance = _S1598;
                }
                Reservoir _S1599 = withEnd(candidate_8, 2U, b_5, _S1595);
                offer(sel_7, _S1599, _S1595 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1295)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1600 = survivalProbability(throughput_9, density_6);
                density_7 = _S1600;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1601 = stream(_S1181, b_5 + 128U);
            Random _S1602 = pcg(_S1601);
            bool _S1603 = density_7 < (_S1602.value);
            if(_S1603)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1604 = (fcptMaxBounces());
                wrong_side_0 = b_5 >= _S1604;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1605 = density_6 * density_7;
            density_7 = _S1605;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1606 = layer_0 ^ 1U;
        uint _S1607 = _slang_select(passes_0, _S1606,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_4)->distance = 0.0f;
            b_7 = b_5;
            viewed_0 = viewed_1;
            throughput_2 = throughput_9;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_1 = spread_4;
            uint _S1608 = b_7 + 1U;
            b_5 = _S1608;
            layer_0 = _S1607;
            continue;
        }
        FKRay _S1609 = ray_2;
        float _S1610 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S1366;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1158 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1611 = _slang_select(wrong_side_0, _S1610,4.294967296e+09f);
        bool _S1612 = !_S1334;
        if(straight_0)
        {
            _S1409 = true;
        }
        else
        {
            _S1409 = _S1334;
        }
        FKHit _S1613;
        if(_S1409)
        {
            _S1613 = hit_4;
        }
        else
        {
            _S1613 = _S1382;
        }
        FKHit _S1614 = (fcptTraverseInstanceBVH((_S1609), (_S1302), (_S1611), (_S1612), (_S1613), (viewed_1)));
        hit_4 = _S1614;
        if(replay_1)
        {
            _S1410 = _S1366;
        }
        else
        {
            _S1410 = false;
        }
        if(_S1410)
        {
            _S1454 = _S1158 == 1U;
        }
        else
        {
            _S1454 = false;
        }
        if(_S1454)
        {
            _S1455 = ((&hit_4)->instance_index) == (_S1170.instance_index);
        }
        else
        {
            _S1455 = false;
        }
        if(_S1455)
        {
            _S1456 = ((&hit_4)->triangle_index) == (_S1170.triangle_index);
        }
        else
        {
            _S1456 = false;
        }
        if(_S1456)
        {
            (&hit_4)->uv = _S1170.uv;
            float _S1615 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1615;
        }
        if(replay_1)
        {
            _S1457 = _S1366;
        }
        else
        {
            _S1457 = false;
        }
        if(_S1457)
        {
            _S1458 = _S1158 == 3U;
        }
        else
        {
            _S1458 = false;
        }
        if(_S1458)
        {
            _S1459 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1459 = false;
        }
        if(_S1459)
        {
            return _S1154;
        }
        Reservoir _S1616 = chain_0;
        uint _S1617 = filling_2;
        for(;;)
        {
            bool _S1618 = (fcptVaryingUsed());
            if(_S1618)
            {
                _S1460 = _S1617 != 4294967295U;
            }
            else
            {
                _S1460 = false;
            }
            float _S1619;
            if(_S1460)
            {
                float _S1620 = (fcptMajorant((_S1617)));
                _S1619 = _S1620;
            }
            else
            {
                _S1619 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1461 = _S1366;
            }
            else
            {
                _S1461 = false;
            }
            if(_S1461)
            {
                _S1462 = _S1158 == 1U;
            }
            else
            {
                _S1462 = false;
            }
            if(_S1462)
            {
                _S1463 = _S1619 > 0.0f;
            }
            else
            {
                _S1463 = false;
            }
            if(_S1463)
            {
                ended_0 = _S1154;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_4 = width_3;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_7 = b_5;
                _S1464 = true;
                break;
            }
            bool _S1621 = (&prev_0)->rough;
            if(_S1621)
            {
                _S1464 = !(_S1619 > 0.0f);
            }
            else
            {
                _S1464 = false;
            }
            (&prev_0)->rough = _S1464;
            uint _S1622 = b_5 + 320U;
            bool _S1623 = b_5 == 4294967295U;
            uint _S1624 = _slang_select(_S1623, 384U,_S1622);
            uint _S1625 = stream(_S1181, _S1624);
            uint tracking_1 = _S1625;
            weight_1 = throughput_3;
            glowed_0 = _S1153;
            b_7 = b_5;
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
                    _S1152 = int(2);
                    break;
                }
                uint _S1626 = b_7 + 320U;
                bool _S1627 = b_7 == 4294967295U;
                uint _S1628 = _slang_select(_S1627, 384U,_S1626);
                uint _S1629 = stream(_S1181, _S1628);
                Random _S1630 = pcg(_S1629);
                float _S1631 = - (F32_log((1.0f - _S1630.value))) / _S1619;
                if(_S1460)
                {
                    float3  _S1632 = (&ray_2)->origin;
                    float3  _S1633 = (&ray_2)->unit_direction;
                    float _S1634 = (&hit_4)->distance;
                    uint _S1635 = _slang_select(_S1627, 0U,b_7);
                    uint _S1636 = (&prev_0)->lobe;
                    uint _S1637 = _slang_select(_S1627, 3U,_S1636);
                    float _S1638 = (fcptTrackMedium((_S1617), (_S1632), (_S1633), (_S1634), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1635), (_S1637), (_S1627)));
                    spread_3 = _S1638;
                }
                else
                {
                    spread_3 = _S1631;
                }
                bool _S1639 = !(spread_3 < ((&hit_4)->distance));
                if(_S1639)
                {
                    _S1152 = int(2);
                    break;
                }
                if(_S1460)
                {
                    _S1465 = _S1342;
                }
                else
                {
                    _S1465 = false;
                }
                if(_S1465)
                {
                    float3  _S1640 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1641 = sel_7->glow + _S1640;
                    sel_7->glow = _S1641;
                }
                else
                {
                }
                glowed_0 = _S1153;
                uint b_9 = b_7 + 1U;
                float3  _S1642 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1642;
                float3  _S1643 = flightWeight_0(scatter_in_0, extinction_in_0, _S1619, spread_3, true);
                float3  _S1644 = weight_1;
                float3  _S1645 = _slang_select(_S1460, _S1644,_S1643);
                float3  throughput_11 = throughput_10 * _S1645;
                uint _S1646 = stream(_S1181, b_9 + 320U);
                tracking_1 = _S1646;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_2 * spread_3;
                float _S1647 = spread_2 + 3.14159274101257324f;
                if(_S1342)
                {
                    _S1466 = true;
                }
                else
                {
                    bool _S1648 = b_9 == _S1169;
                    if(_S1648)
                    {
                        _S1466 = !_S1460;
                    }
                    else
                    {
                        _S1466 = false;
                    }
                }
                TreeSample light_3;
                if(_S1466)
                {
                    float3  _S1649 = (&ray_2)->origin;
                    float3  _S1650 = (&ray_2)->unit_direction;
                    float3  _S1651 = (&ray_2)->unit_direction;
                    uint _S1652 = stream(_S1181, b_9 + 64U);
                    float3  _S1653 = extinction_in_0;
                    float3  _S1654 = extinction_in_0;
                    uint2  _S1655 = make_uint2 (_S1617);
                    float3  _S1656 = (&ray_2)->unit_direction;
                    uint _S1657 = arrivalLobe_0(b_9, (&prev_0)->lobe);
                    FKHit _S1658 = _S1382;
                    ShadowContext _S1659 = ShadowContext_x24init_0(_S1653, _S1654, _S1655, _S1656, b_9, _S1657, false, spread_3, width_7, &_S1658, false);
                    ShadowContext _S1660 = _S1659;
                    TreeSample _S1661 = sampleLightTree_0(_S1649, _S1650, _S1651, 0.0f, true, _S1652, &_S1660);
                    light_3 = _S1661;
                }
                else
                {
                    light_3 = _S1380;
                }
                float _S1662 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
                uint _S1663 = (fcptMaxBounces());
                bool _S1664 = b_9 < _S1663;
                if(_S1664)
                {
                    _S1467 = (light_3.density) > 0.0f;
                }
                else
                {
                    _S1467 = false;
                }
                float _S1665 = _slang_select(_S1467, _S1662,0.0f);
                float3  _S1666 = throughput_11 * light_3.radiance;
                float _S1667 = powerHeuristic(light_3.density, _S1665);
                float3  _S1668 = _S1666 * make_float3 (_S1662 * _S1667);
                float3  _S1669 = _slang_select(_S1466, _S1668,_S1153);
                if(replay_1)
                {
                    _S1468 = b_9 == _S1169;
                }
                else
                {
                    _S1468 = false;
                }
                if(_S1468)
                {
                    bool _S1670 = _S1158 == 2U;
                    if(_S1670)
                    {
                        float _S1671 = rgb_to_greyscale(_S1669);
                        _S1469 = _S1671 > 0.0f;
                    }
                    else
                    {
                        _S1469 = false;
                    }
                    if(_S1469)
                    {
                        Shift _S1672 = Shift_x24init_0(_S1669, 1.0f);
                        _S1152 = int(1);
                        ended_0 = _S1672;
                        spread_3 = _S1647;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_8 = b_9;
                        break;
                    }
                    _S1152 = int(1);
                    ended_0 = _S1154;
                    spread_3 = _S1647;
                    width_5 = width_7;
                    throughput_8 = throughput_11;
                    b_8 = b_9;
                    break;
                }
                if(_S1342)
                {
                    Reservoir candidate_9 = _S1616;
                    uint _S1673 = extractBits_0(_S1616.path, 10U, 2U);
                    bool _S1674 = _S1673 == 1U;
                    if(_S1674)
                    {
                        float3  _S1675 = safeDivide(_S1669, chain_throughput_0);
                        (&candidate_9)->radiance = _S1675;
                    }
                    else
                    {
                        uint _S1676 = insertBits_0(0U, b_9 + 1U, 5U, 5U);
                        uint _S1677 = insertBits_0(_S1676, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1677;
                    }
                    Reservoir _S1678 = withEnd(candidate_9, 0U, b_9, _S1669);
                    offer(sel_7, _S1678, _S1669 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1679 = survivalProbability(throughput_11, density_3);
                    uint _S1680 = stream(_S1181, b_9 + 128U);
                    Random _S1681 = pcg(_S1680);
                    bool _S1682 = _S1679 < (_S1681.value);
                    if(_S1682)
                    {
                        _S1469 = true;
                    }
                    else
                    {
                        uint _S1683 = (fcptMaxBounces());
                        _S1469 = b_9 >= _S1683;
                    }
                    if(_S1469)
                    {
                        _S1152 = int(1);
                        ended_0 = _S1154;
                        spread_3 = _S1647;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_8 = b_9;
                        break;
                    }
                    float _S1684 = density_3 * _S1679;
                    density_3 = _S1684;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1685 = stream(_S1181, b_9);
                float3  _S1686 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1685, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1686;
                NEEVertex _S1687 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1153, (&ray_2)->origin);
                nee_vertex_0 = _S1687;
                Vertex _S1688 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
                prev_0 = _S1688;
                float _S1689 = (&prev_0)->pdf;
                FKRay _S1690 = ray_2;
                FKHit _S1691 = (fcptTraverseInstanceBVH((_S1690), (true), (4.294967296e+09f), (false), (_S1382), (false)));
                hit_4 = _S1691;
                b_7 = b_9;
                throughput_10 = throughput_11;
                spread_2 = _S1647;
                width_4 = width_7;
                sky_pdf_1 = _S1689;
            }
            if(_S1152 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_10 = throughput_8;
                b_7 = b_8;
                _S1464 = true;
                break;
            }
            ended_0 = _S1154;
            _S1464 = false;
            break;
        }
        if(_S1464)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1465 = b_7 == b_5;
        }
        else
        {
            _S1465 = false;
        }
        bool _S1692 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1692)
        {
            bool _S1693 = !(&nee_vertex_0)->none;
            float _S1694 = _slang_select(_S1693, sky_pdf_1,0.0f);
            float _S1695 = escapeWeight_0(_S1694, (&ray_2)->unit_direction);
            float3  _S1696 = environment_0((&ray_2)->unit_direction, b_7, (&prev_0)->lobe);
            float3  _S1697 = throughput_10 * _S1696;
            if(replay_1)
            {
                bool _S1698 = b_7 == _S1169;
                if(_S1698)
                {
                    passes_0 = _S1158 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1697 * make_float3 (_S1695) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1168)
                {
                    passes_0 = _S1165;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_7 == _S1156;
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
                    return Shift_x24init_0(_S1697 * make_float3 (_S1695), 1.0f);
                }
                return _S1154;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1699 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1700 = _S1699 == 1U;
            if(_S1700)
            {
                uint _S1701 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1702 = _S1701 == b_7;
                float _S1703 = _slang_select(_S1702, 1.0f,_S1695);
                float3  _S1704 = safeDivide(_S1697 * make_float3 (_S1703), chain_throughput_0);
                (&candidate_10)->radiance = _S1704;
            }
            else
            {
                bool _S1705 = (&prev_0)->rough;
                if(_S1705)
                {
                    uint _S1706 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                    uint _S1707 = insertBits_0(_S1706, 3U, 10U, 2U);
                    uint _S1708 = insertBits_0(_S1707, (&prev_0)->lobe, 15U, 3U);
                    bool _S1709 = (&prev_0)->inside;
                    uint _S1710 = _slang_select(_S1709, 1U,0U);
                    uint _S1711 = insertBits_0(_S1708, _S1710, 22U, 1U);
                    (&candidate_10)->path = _S1711;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1712 = _S1697 * make_float3 (_S1695);
            Reservoir _S1713 = withEnd(candidate_10, 3U, b_7, _S1712);
            offer(sel_7, _S1713, _S1712 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1714 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1714;
        bool _S1715 = (fcptVaryingUsed());
        if(_S1715)
        {
            _S1466 = filling_2 != 4294967295U;
        }
        else
        {
            _S1466 = false;
        }
        if(_S1466)
        {
            if(_S1342)
            {
                float3  _S1716 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1717 = sel_7->glow + _S1716;
                sel_7->glow = _S1717;
            }
            float3  _S1718 = throughput_10 * weight_1;
            throughput_8 = _S1718;
        }
        else
        {
            float3  _S1719 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1720 = throughput_10 * _S1719;
            throughput_8 = _S1720;
        }
        float _S1721 = width_4 + spread_2 * (&hit_4)->distance;
        viewed_0 = _S1465;
        width_3 = _S1721;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1608 = b_7 + 1U;
        b_5 = _S1608;
        layer_0 = _S1607;
    }
    return _S1154;
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
    int i_25 = int(0);
    for(;;)
    {
        if(i_25 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_14, i_25) = (F32_tan((_slang_vector_get_element(x_26, i_25))));
        i_25 = i_25 + int(1);
    }
    return result_14;
}

static __device__ float3  acos_0(float3  x_27)
{
    float3  result_15;
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
        *_slang_vector_get_element_ptr(&result_15, i_26) = (F32_acos((_slang_vector_get_element(x_27, i_26))));
        i_26 = i_26 + int(1);
    }
    return result_15;
}

static __device__ float3  abs_0(float3  x_28)
{
    float3  result_16;
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
        *_slang_vector_get_element_ptr(&result_16, i_27) = (F32_abs((_slang_vector_get_element(x_28, i_27))));
        i_27 = i_27 + int(1);
    }
    return result_16;
}

__device__ Random normal_distribution(uint state_4)
{
    Random _S1722 = pcg(state_4);
    Random _S1723 = pcg(_S1722.state);
    float _S1724 = 6.28318548202514648f * _S1722.value;
    float _S1725 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1723.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1723.state, _S1725 * (F32_cos((_S1724))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S1726;
    (&_S1726)->state = state_5;
    (&_S1726)->value = value_2;
    return _S1726;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S1727 = normal_distribution(state_6);
    Random _S1728 = normal_distribution(_S1727.state);
    Random _S1729 = normal_distribution(_S1728.state);
    float3  _S1730 = make_float3 (_S1727.value, _S1728.value, _S1729.value);
    float3  _S1731 = ((((_S1730)) * make_float3(rnorm3df(((_S1730)).x, ((_S1730)).y, ((_S1730)).z))));
    return RandomSphere_x24init_0(_S1729.state, _S1731);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_12)
{
    float3  _S1732 = p1_0 - p0_0;
    float3  _S1733 = p2_0 - p0_0;
    float2  _S1734 = uv1_0 - uv0_0;
    float2  _S1735 = uv2_0 - uv0_0;
    float _S1736 = _S1734.x;
    float _S1737 = _S1735.y;
    float _S1738 = _S1734.y;
    float _S1739 = _S1735.x;
    float _S1740 = _S1736 * _S1737 - _S1738 * _S1739;
    float _S1741 = 1.0f / _S1740;
    float3  t_22 = (_S1732 * make_float3 (_S1737) - _S1733 * make_float3 (_S1738)) * make_float3 (_S1741);
    float3  _S1742 = (_S1733 * make_float3 (_S1736) - _S1732 * make_float3 (_S1739)) * make_float3 (_S1741);
    float3  _S1743 = t_22 - n_12 * make_float3 (dot_0(n_12, t_22));
    float3  t_23 = ((((_S1743)) * make_float3(rnorm3df(((_S1743)).x, ((_S1743)).y, ((_S1743)).z))));
    bool _S1744 = (dot_0(cross_0(n_12, t_23), _S1742)) > 0.0f;
    float3  t_24;
    if(_S1744)
    {
        float3  _S1745 = negate_0(t_23);
        t_24 = _S1745;
    }
    else
    {
        t_24 = t_23;
    }
    float3  _S1746 = cross_0(n_12, t_24);
    return makeMatrix<float, 3, 3> (t_24, _S1746, n_12);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_3, float3  uvw_0, float3  position_0)
{
    float3  _S1747 = t1_0 - t0_0;
    float3  _S1748 = t2_2 - t0_0;
    float3  _S1749 = t2_2 - t1_0;
    float _S1750 = (F32_min((length_0(_S1747)), ((F32_min((length_0(_S1748)), (length_0(_S1749)))))));
    float3  _S1751 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1752 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1753 = dot_0(geometry_n_3, _S1752);
    float3  _S1754 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1755 = dot_0(geometry_n_3, _S1754);
    float3  _S1756 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1757 = acos_0(abs_0(make_float3 (_S1753, _S1755, dot_0(geometry_n_3, _S1756))));
    float3  _S1758 = clamp_2(tan_0(_S1757), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1751 * _S1758, uvw_0), 0.0f, _S1750 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_13, float3  n_13, BSDFMaterial material_22)
{
    float3  _S1759 = negate_0(dir_13);
    float _S1760 = sign_0(dot_0(n_13, _S1759));
    float3  _S1761 = n_13 * make_float3 (_S1760);
    AnisotropicFrame _S1762 = anisotropicFrame(material_22, _S1761);
    bool _S1763 = (_S1762.alphas.x) > 0.0f;
    if(_S1763)
    {
        float _S1764 = material_22.transmission * (1.0f - material_22.metallic);
        float3  _S1765 = negate_0(_S1761);
        float3  _S1766 = anisotropicLocal(dir_13, _S1762.tangent, _S1765);
        float _S1767 = anisotropicG1(_S1766, _S1762.alphas);
        return make_float3 (_S1764 * _S1767) * material_22.albedo;
    }
    float _S1768 = material_22.transmission * (1.0f - material_22.metallic);
    float _S1769 = material_22.roughness;
    float _S1770 = smithG1(_S1769 * _S1769, (F32_abs((dot_0(n_13, dir_13)))));
    return make_float3 (_S1768 * _S1770) * material_22.albedo;
}

__device__ float hairRow(float3  in_dir_9, float3  t_25, float3  out_dir_3, uint p_12, float w_2, float alpha_20, uint nt_0)
{
    uint _S1771 = p_12 % 4U;
    float _S1772 = w_2 * HAIR_WIDTHS_0[_S1771];
    float _S1773 = (F32_asin((clamp_1(dot_0(out_dir_3, t_25), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_9, t_25), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1771] * alpha_20;
    return ((F32_asinh((_S1773 / _S1772))) / (F32_asinh((3.14159274101257324f / _S1772))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_10, float3  t_26, float3  out_dir_4, uint np_0)
{
    float3  _S1774 = worldToTangent(out_dir_4, t_26);
    float3  _S1775 = worldToTangent(in_dir_10, t_26);
    return (F32_frac((((F32_atan2((_S1774.z), (_S1774.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1775.z), (1.17549435082228751e-38f - _S1775.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_11, float3  t_27, uint p_13, float row_0, float column_0, float w_3, float alpha_21, uint nt_1, uint np_1)
{
    float3  _S1776 = worldToTangent(in_dir_11, t_27);
    uint _S1777 = p_13 % 4U;
    float _S1778 = w_3 * HAIR_WIDTHS_0[_S1777];
    float _S1779 = (F32_asin((clamp_1(dot_0(in_dir_11, t_27), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1777] * alpha_21 + _S1778 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1778))))));
    float _S1780 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1776.z), (1.17549435082228751e-38f - _S1776.x)));
    float _S1781 = (F32_cos((_S1779)));
    float3  _S1782 = tangentToWorld(make_float3 (_S1781 * (F32_cos((_S1780))), (F32_sin((_S1779))), _S1781 * (F32_sin((_S1780)))), t_27);
    return _S1782;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_14, BSDFMaterial material_23, float coverage_1)
{
    float3  _S1783;
    if((material_23.ior) == 1.0f)
    {
        float3  _S1784 = straightThrough(toward_1, n_14, material_23);
        _S1783 = _S1784;
    }
    else
    {
        _S1783 = make_float3 (0.0f);
    }
    return _S1783 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_8, Reservoir r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    Domain _S1785 = dom_8;
    Reservoir _S1786 = r_9;
    Shift _S1787 = walk_0(&_S1785, &_S1786, replay_2, scale_4, sel_8);
    return _S1787;
}

__device__ Shift shift_hook(Domain dom_9, Reservoir r_10)
{
    Domain _S1788 = dom_9;
    Reservoir _S1789 = r_10;
    Shift _S1790 = shift_0(&_S1788, &_S1789);
    return _S1790;
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
