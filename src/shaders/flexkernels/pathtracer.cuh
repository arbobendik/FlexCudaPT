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
    bool _S75 = all_1((a_0->x0) == (b_0->x0));
    bool _S76;
    if(_S75)
    {
        _S76 = ((&a_0->hit)->instance_index) == ((&b_0->hit)->instance_index);
    }
    else
    {
        _S76 = false;
    }
    if(_S76)
    {
        _S76 = ((&a_0->hit)->triangle_index) == ((&b_0->hit)->triangle_index);
    }
    else
    {
        _S76 = false;
    }
    if(_S76)
    {
        _S76 = all_0(((&a_0->hit)->uv) == ((&b_0->hit)->uv));
    }
    else
    {
        _S76 = false;
    }
    return _S76;
}

static __device__ bool temporalJob_0(int2  p_4, int2  q_1, uint t_6, ShiftJob * job_2, bool target_1)
{
    bool _S77 = t_6 > 1U;
    bool _S78;
    if(_S77)
    {
        _S78 = true;
    }
    else
    {
        uint2  _S79 = (fcptRenderSize());
        int2  _S80 = make_int2 ((int)_S79.x, (int)_S79.y);
        _S78 = any_0(p_4 >= _S80);
    }
    if(_S78)
    {
        _S78 = true;
    }
    else
    {
        bool _S81 = (fcptSceneUnchanged());
        _S78 = _S81;
    }
    if(_S78)
    {
        _S78 = true;
    }
    else
    {
        _S78 = (q_1.x) < int(0);
    }
    if(_S78)
    {
        return false;
    }
    bool _S82 = t_6 == 0U;
    if(_S82)
    {
        Reservoir _S83 = (fcptLoadReservoirPrevious((q_1)));
        job_2->r = _S83;
        bool _S84 = ((&job_2->r)->w) > 0.0f;
        if(_S84)
        {
            bool _S85 = !target_1;
            if(_S85)
            {
                _S78 = true;
            }
            else
            {
                bool _S86 = (fcptStoredDomainInitial((p_4), ((&job_2->r)->seed), (&job_2->dom)));
                _S78 = _S86;
            }
        }
        else
        {
            _S78 = false;
        }
        return _S78;
    }
    Reservoir _S87 = (fcptLoadReservoirInitial((p_4)));
    job_2->r = _S87;
    bool _S88 = !target_1;
    if(_S88)
    {
        bool _S89 = (fcptPreviousScenes());
        _S78 = _S89;
    }
    else
    {
        _S78 = false;
    }
    if(_S78)
    {
        return ((&job_2->r)->w) > 0.0f;
    }
    Domain _S90 = (fcptPreviousDomain((q_1), ((&job_2->r)->seed)));
    job_2->dom = _S90;
    float3  _S91 = make_float3 (0.0f);
    FKHit _S92 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S93 = Domain_x24init_0(_S91, _S91, &_S92, 0.0f, 0.0f);
    Domain own_0 = _S93;
    bool _S94 = ((&job_2->r)->w) > 0.0f;
    if(_S94)
    {
        bool _S95 = (fcptPreviousScenes());
        if(_S95)
        {
            _S78 = true;
        }
        else
        {
            bool _S96 = (fcptStoredDomainInitial((p_4), ((&job_2->r)->seed), (&own_0)));
            if(_S96)
            {
                Domain _S97 = job_2->dom;
                Domain _S98 = own_0;
                bool _S99 = sameDomain_0(&_S97, &_S98);
                _S78 = _S99;
            }
            else
            {
                _S78 = false;
            }
            _S78 = !_S78;
        }
    }
    else
    {
        _S78 = false;
    }
    return _S78;
}

static __device__ void temporalBins_0(int2  p_5, FixedArray<uint, 3>  * _S100)
{
    FixedArray<uint, 3>  _S101 = { {
        40U, 40U, 40U
    } };
    FixedArray<uint, 3>  bins_2;
    bins_2[int(0)] = 40U;
    bins_2[int(1)] = 40U;
    bins_2[int(2)] = 40U;
    uint t_7 = 0U;
    for(;;)
    {
        if(t_7 < 2U)
        {
        }
        else
        {
            break;
        }
        ShiftJob _S102 = (ShiftJob{});
        ShiftJob job_3 = _S102;
        int2  _S103 = (fcptLoadTemporalNeighbor((p_5)));
        bool _S104 = temporalJob_0(p_5, _S103, t_7, &job_3, false);
        if(_S104)
        {
            Reservoir _S105 = (&job_3)->r;
            uint _S106 = shiftBin_0(&_S105);
            bins_2[t_7] = _S106;
        }
        uint t_8 = t_7 + 1U;
        t_7 = t_8;
    }
    *_S100 = bins_2;
    return;
}

static __device__ void countShifts_0(FixedArray<uint, 3>  * bins_3, uint local_invocation_index_2)
{
    uint t_9 = 0U;
    for(;;)
    {
        if(t_9 < 3U)
        {
        }
        else
        {
            break;
        }
        uint _S107 = (*bins_3)[t_9];
        bool _S108 = ((*bins_3)[t_9]) < 40U;
        if(_S108)
        {
            uint _S109 = (fcptQueueCountAdd((_S107), (1U)));
        }
        uint t_10 = t_9 + 1U;
        t_9 = t_10;
    }
    return;
}

static __device__ bool previousValid_0(int2  q_2)
{
    bool _S110 = all_0(q_2 >= make_int2 (int(0)));
    bool _S111;
    if(_S110)
    {
        uint2  _S112 = (fcptRenderSize());
        int2  _S113 = make_int2 ((int)_S112.x, (int)_S112.y);
        _S111 = all_0(q_2 < _S113);
    }
    else
    {
        _S111 = false;
    }
    if(_S111)
    {
        uint4  _S114 = (fcptReservoirPrevious((q_2), (0U)));
        _S111 = (U32_asfloat((_S114.w))) > 0.0f;
    }
    else
    {
        _S111 = false;
    }
    return _S111;
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

static __device__ int2  temporalNeighbor_0(int2  p_6, Domain * dom_0, uint seed_1)
{
    bool _S115 = previousValid_0(p_6);
    bool _S116;
    if(_S115)
    {
        Domain _S117 = (fcptPreviousDomain((p_6), (seed_1)));
        Domain _S118 = _S117;
        bool _S119 = sameDomain_0(&_S118, dom_0);
        _S116 = _S119;
    }
    else
    {
        _S116 = false;
    }
    if(_S116)
    {
        return p_6;
    }
    uint _S120 = (&dom_0->hit)->instance_index;
    bool _S121 = ((&dom_0->hit)->instance_index) == 4294967295U;
    if(_S121)
    {
        return make_int2 (int(-1));
    }
    float3  _S122 = dom_0->x1;
    float2  _S123 = (fcptPixelOf((dom_0->x1), (true)));
    float2  _S124 = floor_0(_S123);
    int2  _S125 = make_int2 ((int)_S124.x, (int)_S124.y);
    bool _S126 = previousValid_0(_S125);
    bool _S127 = !_S126;
    if(_S127)
    {
        return make_int2 (int(-1));
    }
    uint4  _S128 = (fcptReservoirPrevious((_S125), (0U)));
    Domain _S129 = (fcptPreviousDomain((_S125), (_S128.x)));
    bool _S130 = (_S129.hit.instance_index) == _S120;
    if(_S130)
    {
        float _S131 = distance_1(_S129.x1, _S122);
        float _S132 = (&dom_0->hit)->distance * 8.0f;
        uint2  _S133 = (fcptRenderSize());
        _S116 = _S131 <= (_S132 / float(_S133.x));
    }
    else
    {
        _S116 = false;
    }
    if(_S116)
    {
        return _S125;
    }
    int2  _S134 = p_6 + _S125;
    float2  _S135 = make_float2 ((float)_S134.x, (float)_S134.y);
    float2  _S136 = _S135 + make_float2 (1.0f);
    float2  _S137 = (fcptPixelOf((_S129.x1), (false)));
    float2  _S138 = floor_0(_S136 - _S137);
    int2  _S139 = make_int2 ((int)_S138.x, (int)_S138.y);
    int2  _S140 = make_int2 (int(-1));
    bool _S141 = previousValid_0(_S139);
    int2  _S142 = _slang_select(_S141, _S139,_S140);
    return _S142;
}

static __device__ Shift Shift_x24init_0(float3  f_0, float jac_0)
{
    Shift _S143;
    (&_S143)->f = f_0;
    (&_S143)->jac = jac_0;
    return _S143;
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

static __device__ Shift passWalk_0(Domain * dom_1, Reservoir * r_1, bool replay_0, float scale_0, Selection * sel_0)
{
    Shift _S144 = (fcptWalk((*dom_1), (*r_1), (replay_0), (scale_0), (sel_0)));
    return _S144;
}

static __device__ Shift shift_0(Domain * dom_2, Reservoir * r_2)
{
    Selection _S145 = (Selection{});
    Selection sel_1 = _S145;
    bool _S146 = (r_2->w) <= 0.0f;
    if(_S146)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S147 = passWalk_0(dom_2, r_2, true, 0.0f, &sel_1);
    return _S147;
}

static __device__ Shift temporalShiftAt_0(int2  p_7, int2  q_3, uint t_11)
{
    ShiftJob _S148 = (ShiftJob{});
    ShiftJob job_4 = _S148;
    bool _S149 = temporalJob_0(p_7, q_3, t_11, &job_4, true);
    bool _S150 = !_S149;
    if(_S150)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S151;
    if(t_11 == 1U)
    {
        Shift _S152 = (fcptShiftPrevious(((&job_4)->dom), ((&job_4)->r)));
        _S151 = _S152;
    }
    else
    {
        Domain _S153 = (&job_4)->dom;
        Reservoir _S154 = (&job_4)->r;
        Shift _S155 = shift_0(&_S153, &_S154);
        _S151 = _S155;
    }
    return _S151;
}

static __device__ int2  sampleNeighbor_0(int2  p_8, uint seed_2)
{
    bool _S156 = (fcptSceneUnchanged());
    if(_S156)
    {
        bool _S157 = previousValid_0(p_8);
        int2  _S158;
        if(_S157)
        {
            _S158 = p_8;
        }
        else
        {
            _S158 = make_int2 (int(-1));
        }
        return _S158;
    }
    float3  _S159 = make_float3 (0.0f);
    FKHit _S160 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S161 = Domain_x24init_0(_S159, _S159, &_S160, 0.0f, 0.0f);
    Domain dom_3 = _S161;
    uint2  _S162 = (fcptRenderSize());
    int2  _S163 = make_int2 ((int)_S162.x, (int)_S162.y);
    bool _S164 = any_0(p_8 >= _S163);
    bool _S165;
    if(_S164)
    {
        _S165 = true;
    }
    else
    {
        bool _S166 = (fcptStoredDomainInitial((p_8), (seed_2), (&dom_3)));
        _S165 = !_S166;
    }
    if(_S165)
    {
        return make_int2 (int(-1));
    }
    Domain _S167 = dom_3;
    int2  _S168 = temporalNeighbor_0(p_8, &_S167, seed_2);
    return _S168;
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
    FKRay _S169;
    (&_S169)->origin = origin_0;
    (&_S169)->unit_direction = unit_direction_0;
    return _S169;
}

static __device__ float3  skyRadiance_0(float3  origin_1, FKSurface * surface_0, bool is_inside_1, float3  dir_1, ShadowContext * context_0, uint random_state_0)
{
    bool _S170 = wrongSide_0(is_inside_1, false, dir_1, surface_0->geometry_n);
    bool _S171 = is_inside_1 != _S170;
    float _S172 = surface_0->geometry_offset;
    float3  _S173 = surface_0->smooth_n;
    float3  _S174 = - surface_0->smooth_n;
    float3  _S175 = _slang_select(_S171, _S174,_S173);
    FKRay _S176 = Ray_x24init_0(origin_1 + make_float3 (_S172) * _S175, dir_1);
    bool _S177 = (dot_0(context_0->side, dir_1)) > 0.0f;
    bool _S178 = (fcptWorldReadsPath());
    float3  _S179;
    if(_S178)
    {
        _S179 = make_float3 (1.0f);
    }
    else
    {
        float3  _S180 = (fcptEnvMapSample((dir_1), (0U), (3U)));
        _S179 = _S180;
    }
    float3  _S181 = context_0->extinction_behind;
    float3  _S182 = context_0->extinction_front;
    float3  _S183 = _slang_select(_S177, _S182,_S181);
    uint _S184 = context_0->fillings.x;
    uint _S185 = context_0->fillings.y;
    uint _S186 = _slang_select(_S177, _S185,_S184);
    uint _S187 = context_0->depth;
    uint _S188 = context_0->lobe;
    bool _S189 = context_0->surface;
    bool _S190;
    if(_S189)
    {
        _S190 = !context_0->fiber;
    }
    else
    {
        _S190 = false;
    }
    float _S191 = context_0->length;
    float _S192 = context_0->width;
    FKHit _S193 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    float3  _S194 = (fcptShadowTransmittanceIn((_S176), (4.294967296e+09f), (_S183), (_S186), (random_state_0), (_S187), (_S188), (_S190), (_S191), (_S192), (_S193), (_S193)));
    return _S179 * _S194;
}

static __device__ uint searchCDF_0(uint2  start_4, uint2  step_0, uint count_1, float u_0)
{
    uint _S195 = count_1 - 1U;
    uint low_0 = 0U;
    uint high_0 = _S195;
    for(;;)
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        uint _S196 = (low_0 + high_0) / 2U;
        float4  _S197 = (fcptEnvironmentCdf((start_4 + step_0 * make_uint2 (_S196))));
        bool _S198 = (_S197.x) > u_0;
        if(_S198)
        {
            high_0 = _S196;
        }
        else
        {
            uint _S199 = _S196 + 1U;
            low_0 = _S199;
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
    float3  _S200 = ((((light_dir_0)) * make_float3(rnorm3df(((light_dir_0)).x, ((light_dir_0)).y, ((light_dir_0)).z))));
    bool _S201 = (dot_0(smooth_n_0, _S200)) < 0.0f;
    if(_S201)
    {
        return make_float3 (0.0f);
    }
    float3  _S202 = make_float3 (geometry_offset_0) * smooth_n_0;
    float3  _S203 = origin_2 + _S202;
    FKRay _S204 = Ray_x24init_0(_S203, _S200);
    bool _S205 = (dot_0(context_1->side, light_dir_0 + _S202)) > 0.0f;
    float _S206 = shadowLength(light_dir_0);
    float3  _S207 = context_1->extinction_behind;
    float3  _S208 = context_1->extinction_front;
    float3  _S209 = _slang_select(_S205, _S208,_S207);
    uint _S210 = context_1->fillings.x;
    uint _S211 = context_1->fillings.y;
    uint _S212 = _slang_select(_S205, _S211,_S210);
    uint _S213 = context_1->depth;
    uint _S214 = context_1->lobe;
    bool _S215 = context_1->surface;
    bool _S216;
    if(_S215)
    {
        _S216 = !context_1->fiber;
    }
    else
    {
        _S216 = false;
    }
    float _S217 = context_1->length;
    float _S218 = context_1->width;
    FKHit _S219;
    if(context_1->fiber)
    {
        _S219 = context_1->own;
    }
    else
    {
        _S219 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    }
    float3  _S220 = (fcptShadowTransmittanceIn((_S204), (_S206), (_S209), (_S212), (random_state_1), (_S213), (_S214), (_S216), (_S217), (_S218), (_S219), (*light_0)));
    return _S220;
}

__device__ float sine(float c_0)
{
    return (F32_sqrt(((F32_max((1.0f - c_0 * c_0), (0.0f))))));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S221 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S222 = cos_a_0 > cos_b_0;
    float _S223 = _slang_select(_S222, 1.0f,_S221);
    return _S223;
}

__device__ float sinSubClamped(float sin_a_1, float cos_a_1, float sin_b_1, float cos_b_1)
{
    float _S224 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    bool _S225 = cos_a_1 > cos_b_1;
    float _S226 = _slang_select(_S225, 0.0f,_S224);
    return _S226;
}

__device__ float importance(LightNode node_0, float3  p_9, float3  normal_0)
{
    float3  _S227 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S228 = node_0.high - node_0.low;
    float3  _S229 = p_9 - _S227;
    float3  _S230 = ((((_S229)) * make_float3(rnorm3df(((_S229)).x, ((_S229)).y, ((_S229)).z))));
    float _S231 = dot_0(_S229, _S229);
    float _S232 = dot_0(_S228, _S228) / 4.0f;
    float _S233 = (F32_abs((dot_0(node_0.w, _S230))));
    float _S234 = sine(node_0.cos_theta_o);
    float _S235 = (F32_sqrt(((F32_max((1.0f - _S232 / _S231), (0.0f))))));
    bool _S236 = _S231 < _S232;
    float _S237 = _slang_select(_S236, -1.0f,_S235);
    float _S238 = sine(_S237);
    float _S239 = sine(_S233);
    float _S240 = cosSubClamped(_S239, _S233, _S234, node_0.cos_theta_o);
    float _S241 = sine(_S233);
    float _S242 = sinSubClamped(_S241, _S233, _S234, node_0.cos_theta_o);
    float _S243 = cosSubClamped(_S242, _S240, _S238, _S237);
    bool _S244 = _S243 <= 0.0f;
    if(_S244)
    {
        return 0.0f;
    }
    float _S245 = - dot_0(_S230, normal_0);
    float _S246 = node_0.phi * _S243 / (F32_max((_S231), (length_0(_S228) / 2.0f)));
    float _S247 = sine(_S245);
    float _S248 = cosSubClamped(_S247, _S245, _S238, _S237);
    bool _S249 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S250 = _slang_select(_S249, 1.0f,_S248);
    return (F32_max((_S246 * _S250), (0.0f)));
}

__device__ __forceinline__ float childShare(LightNode first_0, LightNode second_0, float3  p_10, float3  normal_1, uint child_0)
{
    float _S251 = importance(first_0, p_10, normal_1);
    float _S252 = importance(second_0, p_10, normal_1);
    float2  _S253 = make_float2 (_S251, _S252);
    float _S254 = _slang_vector_get_element(_S253, child_0) / (_S251 + _S252);
    bool _S255 = _slang_vector_get_element(_S253, child_0) > 0.0f;
    float _S256 = _slang_select(_S255, _S254,0.0f);
    return _S256;
}

__device__ float sphereDensity(float3  center_0, float radius_0, float3  p_11)
{
    float3  _S257 = center_0 - p_11;
    float _S258 = radius_0 * radius_0 / dot_0(_S257, _S257);
    bool _S259 = _S258 >= 1.0f;
    if(_S259)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S258)))) / (6.28318548202514648f * _S258);
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S260 = left_0.y;
    float _S261 = right_0.z;
    float _S262 = left_0.z;
    float _S263 = right_0.y;
    float _S264 = right_0.x;
    float _S265 = left_0.x;
    return make_float3 (_S260 * _S261 - _S262 * _S263, _S262 * _S264 - _S265 * _S261, _S265 * _S263 - _S260 * _S264);
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_0))));
}

static __device__ float lightPdf_0(float3  origin_3, float3  smooth_n_1, float3  start_5, uint j_0, float3  light_point_0)
{
    bool _S266 = j_0 == 4294967295U;
    if(_S266)
    {
        return 0.0f;
    }
    uint4  _S267 = (fcptLightTrail((j_0)));
    uint2  _S268 = uint2 {_S267.x, _S267.y};
    uint n_0 = 0U;
    uint2  trail_0 = _S268;
    float probability_1 = 1.0f;
    for(;;)
    {
        uint4  _S269 = (fcptLightNode((n_0)));
        if((_S269.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S270 = (fcptLightSecond((n_0)));
        uint _S271 = n_0 + 1U;
        LightNode _S272 = (fcptLightBounds((_S271)));
        LightNode _S273 = (fcptLightBounds((_S270)));
        uint _S274 = trail_0.x;
        uint _S275 = _S274 & 1U;
        float _S276 = childShare(_S272, _S273, origin_3, smooth_n_1, _S275);
        float probability_2 = probability_1 * _S276;
        bool _S277 = _S275 == 1U;
        uint _S278 = _slang_select(_S277, _S270,_S271);
        uint _S279 = trail_0.y;
        uint2  _S280 = make_uint2 ((_S274 >> 1U) | (_S279 << 31U), _S279 >> 1U);
        n_0 = _S278;
        trail_0 = _S280;
        probability_1 = probability_2;
    }
    bool _S281 = (fcptSlotLeaf((n_0), (j_0)));
    bool _S282 = !_S281;
    bool _S283;
    if(_S282)
    {
        _S283 = true;
    }
    else
    {
        LightNode _S284 = (fcptLightBounds((n_0)));
        float _S285 = importance(_S284, origin_3, smooth_n_1);
        _S283 = !(_S285 > 0.0f);
    }
    if(_S283)
    {
        _S283 = true;
    }
    else
    {
        bool _S286 = (dot_0(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S286)
        {
            _S283 = !((dot_0(smooth_n_1, light_point_0 - origin_3)) > 0.0f);
        }
        else
        {
            _S283 = false;
        }
    }
    if(_S283)
    {
        return 0.0f;
    }
    uint4  _S287 = (fcptLightNode((n_0)));
    bool _S288 = (_S287.x) == 2U;
    if(_S288)
    {
        uint _S289 = _S287.y;
        FKLight _S290 = (fcptLight((_S289)));
        FKLight _S291 = (fcptLight((_S289)));
        float _S292 = sphereDensity(_S290.position, _S291.variance, start_5);
        return probability_1 * _S292;
    }
    uint _S293 = _S287.y;
    uint _S294 = (fcptTriangleOffset((_S293)));
    Matrix<float, 3, 3>  _S295 = (fcptWorldTriangle((_S293), (_S294 + _S287.z)));
    float _S296 = solidAngle(probability_1, cross_0(_S295.rows[int(1)] - _S295.rows[int(0)], _S295.rows[int(2)] - _S295.rows[int(0)]), light_point_0 - start_5);
    return _S296;
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

__device__ uint2  noiseOffset(uint k_0)
{
    uint2  _S297 = make_uint2 (k_0 * 3242174889U, k_0 * 2447445414U) >> make_uint2 (16U);
    uint _S298 = (fkBlueNoiseSize());
    return (_S297 * make_uint2 (_S298)) >> make_uint2 (16U);
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S299 = hash(index_0);
    uint _S300 = hash(seed_3 ^ _S299);
    return _S300;
}

static __device__ float random_0(uint * state_0)
{
    uint _S301 = hash(*state_0);
    *state_0 = _S301;
    return float((*state_0) >> int(8)) * 5.9604644775390625e-08f;
}

static __device__ Random Random_x24init_0(uint state_1, float value_0)
{
    Random _S302;
    (&_S302)->state = state_1;
    (&_S302)->value = value_0;
    return _S302;
}

__device__ Random pcg(uint state_2)
{
    uint _S303 = state_2;
    float value_1 = random_0(&_S303);
    return Random_x24init_0(_S303, value_1);
}

__device__ __noinline__ Random draw(uint address_0, uint variable_0)
{
    uint _S304 = address_0 >> 22U;
    uint _S305 = _S304 / 32U;
    uint2  _S306 = make_uint2 (address_0 & 2047U, (address_0 >> 11U) & 2047U);
    uint _S307 = variable_0 & 2147483647U;
    uint2  _S308 = noiseOffset(_S307);
    uint2  _S309 = _S306 + _S308;
    uint2  _S310 = noiseOffset(4096U + _S305);
    uint2  _S311 = _S309 + _S310;
    uint _S312 = (fkBlueNoiseSize());
    uint2  _S313 = _S311 & make_uint2 (_S312 - 1U);
    uint _S314 = (fkBlueNoise((_S313.x), (_S313.y), ((_S304 + ((_S305 * 2654435769U) >> 27U)) % 32U)));
    bool _S315 = (variable_0 & 2147483648U) != 0U;
    uint _S316 = stream(address_0, _S307);
    Random _S317 = pcg(_S316);
    float _S318;
    if(_S314 == 4294967295U)
    {
        if(_S315)
        {
            Random _S319 = pcg(_S317.state);
            _S318 = _S319.value;
        }
        else
        {
            _S318 = _S317.value;
        }
    }
    else
    {
        uint _S320;
        if(_S315)
        {
            _S320 = _S314 >> 16U;
        }
        else
        {
            _S320 = _S314 & 65535U;
        }
        _S318 = (float(_S320) + 0.5f) / 6.5536e+04f;
    }
    return Random_x24init_0(address_0, _S318);
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
    uint2  _S321 = (fcptEnvironmentCdfSize());
    uint2  _S322 = _S321 - make_uint2 (1U, 0U);
    float2  _S323 = make_float2 ((F32_atan2((- dir_2.y), (dir_2.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_1(dir_2.z, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S324 = make_float2 ((float)_S322.x, (float)_S322.y);
    float2  _S325 = _S323 * _S324;
    uint2  _S326 = make_uint2 ((uint)_S325.x, (uint)_S325.y);
    uint2  _S327 = min_0(_S326, _S322 - make_uint2 (1U));
    float4  _S328 = (fcptEnvironmentCdf((_S327)));
    float _S329 = _S328.y;
    uint _S330 = _S322.x;
    float4  _S331 = (fcptEnvironmentCdf((make_uint2 (_S330, _S327.y))));
    float _S332 = _S329 * _S331.y;
    return _S332 * float(_S330 * _S322.y) / (19.73921012878417969f * length_1(float2 {dir_2.x, dir_2.y}));
}

__device__ float upsample(float3  rgb_0, float wavelength_0)
{
    float _S333 = dot_0(make_float3 (-0.08011700212955475f, 1.08901798725128174f, -0.00889899954199791f), rgb_0);
    float _S334 = dot_0(make_float3 (0.12177000194787979f, -1.22903203964233398f, 1.10724997520446777f), rgb_0);
    float _S335 = dot_0(make_float3 (1.17252397537231445f, -1.21603405475616455f, 0.04350199922919273f), rgb_0);
    float3  _S336 = make_float3 (_S333, _S334, _S335);
    float _S337 = (wavelength_0 - 0.44999998807907104f) / 0.02999999932944775f;
    float _S338 = (wavelength_0 - 0.63999998569488525f) / 0.03999999910593033f;
    return _S333 + _S334 * (F32_exp((-0.5f * _S337 * _S337))) + _S335 * (F32_exp((-0.5f * _S338 * _S338)));
}

__device__ BSDFMaterial atWavelength(BSDFMaterial material_0, float wavelength_1)
{
    BSDFMaterial at_0 = material_0;
    float _S339 = upsample(material_0.albedo, wavelength_1);
    float3  _S340 = make_float3 (_S339);
    (&at_0)->albedo = _S340;
    float _S341 = upsample(material_0.emissive, wavelength_1);
    float3  _S342 = make_float3 (_S341);
    (&at_0)->emissive = _S342;
    float _S343 = upsample(material_0.absorption, wavelength_1);
    float3  _S344 = make_float3 (_S343);
    (&at_0)->absorption = _S344;
    float _S345 = upsample(material_0.specular_tint, wavelength_1);
    float3  _S346 = make_float3 (_S345);
    (&at_0)->specular_tint = _S346;
    float _S347 = upsample(material_0.translucent, wavelength_1);
    float3  _S348 = make_float3 (_S347);
    (&at_0)->translucent = _S348;
    float _S349 = upsample(material_0.sheen, wavelength_1);
    float3  _S350 = make_float3 (_S349);
    (&at_0)->sheen = _S350;
    float _S351 = upsample(material_0.coat_tint, wavelength_1);
    float3  _S352 = make_float3 (_S351);
    (&at_0)->coat_tint = _S352;
    return at_0;
}

__device__ BSDFMaterial pathMaterial(BSDFMaterial material_1, float wavelength_2)
{
    BSDFMaterial _S353;
    if(wavelength_2 > 0.0f)
    {
        BSDFMaterial _S354 = atWavelength(material_1, wavelength_2);
        _S353 = _S354;
    }
    else
    {
        _S353 = material_1;
    }
    return _S353;
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    float _S355;
    if(e_1 > 0.0f)
    {
        _S355 = 1.0f;
    }
    else
    {
        if(e_1 < 0.0f)
        {
            _S355 = -1.0f;
        }
        else
        {
            _S355 = 0.0f;
        }
    }
    return _S355;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S356;
    (&_S356)->tangent = tangent_0;
    (&_S356)->alphas = alphas_0;
    return _S356;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S357 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S357)
    {
        float3  _S358 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S358;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S359 = cross_0(n_1, a_2);
    float3  _S360 = ((((_S359)) * make_float3(rnorm3df(((_S359)).x, ((_S359)).y, ((_S359)).z))));
    float3  _S361 = cross_0(n_1, _S360);
    return make_float3 (v_0.x) * _S360 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S361;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_2, float3  n_i_0)
{
    float _S362 = material_2.roughness;
    float _S363 = _S362 * _S362;
    bool _S364 = (material_2.anisotropy) == 0.0f;
    bool _S365;
    if(_S364)
    {
        _S365 = true;
    }
    else
    {
        _S365 = !(_S363 > 0.0f);
    }
    if(_S365)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S366 = material_2.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_2.tangent));
    float3  _S367 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S368 = (dot_0(_S366, _S366)) > 0.0f;
    float3  _S369 = _slang_select(_S368, _S366,_S367);
    float3  _S370 = ((((_S369)) * make_float3(rnorm3df(((_S369)).x, ((_S369)).y, ((_S369)).z))));
    float _S371 = 6.28318548202514648f * material_2.anisotropic_rotation;
    float _S372 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_2.anisotropy))))));
    float _S373 = 1.0f / _S372;
    bool _S374 = (material_2.anisotropy) < 0.0f;
    float _S375 = _slang_select(_S374, _S373,_S372);
    return AnisotropicFrame_x24init_0(_S370 * make_float3 ((F32_cos((_S371)))) + cross_0(n_i_0, _S370) * make_float3 ((F32_sin((_S371)))), make_float2 (_S363 / _S375, _S363 * _S375));
}

__device__ float rgb_to_greyscale(float3  rgb_1)
{
    return dot_0(rgb_1, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

__device__ static const FixedArray<float, 576>  VELVET_ALBEDO_0 = { {
    1.00383996963500977f, 1.00428998470306396f, 1.00356996059417725f, 1.00303995609283447f, 1.00261998176574707f, 1.00229001045227051f, 1.00198996067047119f, 1.00171005725860596f, 1.00144004821777344f, 1.00120997428894043f, 1.00102996826171875f, 1.00092005729675293f, 1.00088000297546387f, 1.0009000301361084f, 1.00095999240875244f, 1.00106000900268555f, 1.00115001201629639f, 1.00124001502990723f, 1.001289963722229f, 1.0013200044631958f, 1.00133001804351807f, 1.00133001804351807f, 1.0013200044631958f, 1.00129997730255127f, 0.99086397886276245f, 0.9934689998626709f, 0.99439799785614014f, 0.99513500928878784f, 0.99574202299118042f, 0.9962649941444397f, 0.99671798944473267f, 0.99709898233413696f, 0.997406005859375f, 0.99764800071716309f, 0.99783498048782349f, 0.99798601865768433f, 0.99811899662017822f, 0.99825501441955566f, 0.99840497970581055f, 0.99857097864151001f, 0.99874699115753174f, 0.99892902374267578f, 0.9990919828414917f, 0.99923902750015259f, 0.99936902523040771f, 0.99948000907897949f, 0.99957501888275146f, 0.99965798854827881f, 0.94088798761367798f, 0.95128101110458374f, 0.95866602659225464f, 0.96450901031494141f, 0.96921002864837646f, 0.973052978515625f, 0.97623497247695923f, 0.97890102863311768f, 0.98115700483322144f, 0.98308497667312622f, 0.98474901914596558f, 0.98619699478149414f, 0.98746699094772339f, 0.98858797550201416f, 0.98958402872085571f, 0.99047297239303589f, 0.99127000570297241f, 0.99198299646377563f, 0.99262100458145142f, 0.99318897724151611f, 0.99372398853302002f, 0.99426800012588501f, 0.99475300312042236f, 0.99514400959014893f, 0.86131101846694946f, 0.88463401794433594f, 0.90212702751159668f, 0.91595500707626343f, 0.92708200216293335f, 0.93617302179336548f, 0.94370102882385254f, 0.95000702142715454f, 0.95534700155258179f, 0.9599120020866394f, 0.96384698152542114f, 0.96726799011230469f, 0.97026199102401733f, 0.97289901971817017f, 0.97523599863052368f, 0.97731602191925049f, 0.97917401790618896f, 0.98083901405334473f, 0.98233497142791748f, 0.98368102312088013f, 0.98489302396774292f, 0.98598498106002808f, 0.98697298765182495f, 0.98787301778793335f, 0.75306302309036255f, 0.79328000545501709f, 0.82418698072433472f, 0.84881901741027832f, 0.86874997615814209f, 0.88506197929382324f, 0.89858502149581909f, 0.9099239706993103f, 0.91952997446060181f, 0.9277459979057312f, 0.93483197689056396f, 0.94099199771881104f, 0.9463840126991272f, 0.95113497972488403f, 0.95534402132034302f, 0.95908999443054199f, 0.9624369740486145f, 0.96543699502944946f, 0.96813201904296875f, 0.97055697441101074f, 0.97274202108383179f, 0.97471201419830322f, 0.97649002075195312f, 0.97809398174285889f, 0.62183499336242676f, 0.68052101135253906f, 0.72705197334289551f, 0.76452702283859253f, 0.79505598545074463f, 0.82021200656890869f, 0.84120297431945801f, 0.85885602235794067f, 0.87384098768234253f, 0.88667500019073486f, 0.89775800704956055f, 0.90739899873733521f, 0.91584599018096924f, 0.92329102754592896f, 0.929889976978302f, 0.93576502799987793f, 0.94101500511169434f, 0.94572198390960693f, 0.94994997978210449f, 0.95375597476959229f, 0.95718497037887573f, 0.9602770209312439f, 0.96306699514389038f, 0.96558600664138794f, 0.47742500901222229f, 0.5522189736366272f, 0.61415499448776245f, 0.66520899534225464f, 0.70744901895523071f, 0.74262100458145142f, 0.77213901281356812f, 0.7971159815788269f, 0.81841897964477539f, 0.83673000335693359f, 0.85258400440216064f, 0.86640900373458862f, 0.87854301929473877f, 0.88924998044967651f, 0.89874798059463501f, 0.90721100568771362f, 0.91477799415588379f, 0.92156499624252319f, 0.92766499519348145f, 0.93315702676773071f, 0.9381060004234314f, 0.94257098436355591f, 0.94660097360610962f, 0.95023900270462036f, 0.33539599180221558f, 0.41908100247383118f, 0.49247598648071289f, 0.55531197786331177f, 0.60879099369049072f, 0.65415602922439575f, 0.69274699687957764f, 0.72571200132369995f, 0.75402498245239258f, 0.77849102020263672f, 0.79976201057434082f, 0.81836599111557007f, 0.83474302291870117f, 0.84922301769256592f, 0.86208897829055786f, 0.87356698513031006f, 0.88384199142456055f, 0.89306402206420898f, 0.90135800838470459f, 0.9088289737701416f, 0.91556602716445923f, 0.92164498567581177f, 0.92713397741317749f, 0.93208998441696167f, 0.21194499731063843f, 0.29365798830986023f, 0.37110498547554016f, 0.44143900275230408f, 0.5036969780921936f, 0.55801302194595337f, 0.60521197319030762f, 0.64614301919937134f, 0.68169897794723511f, 0.71268302202224731f, 0.73979401588439941f, 0.76362699270248413f, 0.78467601537704468f, 0.80335497856140137f, 0.82000100612640381f, 0.83488202095031738f, 0.8482239842414856f, 0.86021500825881958f, 0.87101101875305176f, 0.88074499368667603f, 0.88952797651290894f, 0.89745801687240601f, 0.90461999177932739f, 0.91109001636505127f, 0.11949499696493149f, 0.18745699524879456f, 0.25997200608253479f, 0.33120998740196228f, 0.39773499965667725f, 0.45832300186157227f, 0.51248997449874878f, 0.56048798561096191f, 0.6028980016708374f, 0.64032697677612305f, 0.67339599132537842f, 0.70268499851226807f, 0.72870397567749023f, 0.75189602375030518f, 0.77263599634170532f, 0.7912449836730957f, 0.80796998739242554f, 0.82303100824356079f, 0.8366129994392395f, 0.84887397289276123f, 0.85994899272918701f, 0.86995697021484375f, 0.87900298833847046f, 0.88717901706695557f, 0.05942929908633232f, 0.10839699953794479f, 0.16785700619220734f, 0.23236599564552307f, 0.29767501354217529f, 0.36022999882698059f, 0.41842898726463318f, 0.47170799970626831f, 0.5198180079460144f, 0.56301301717758179f, 0.60171198844909668f, 0.63635998964309692f, 0.66739702224731445f, 0.69524997472763062f, 0.720287024974823f, 0.74283498525619507f, 0.76317602396011353f, 0.78155702352523804f, 0.79817098379135132f, 0.81319701671600342f, 0.8267899751663208f, 0.83908802270889282f, 0.85021400451660156f, 0.86027902364730835f, 0.02584660053253174f, 0.05619670078158379f, 0.09917669743299484f, 0.15162299573421478f, 0.20941600203514099f, 0.26902499794960022f, 0.32757499814033508f, 0.38318398594856262f, 0.43501600623130798f, 0.48271399736404419f, 0.52620798349380493f, 0.56570100784301758f, 0.60149699449539185f, 0.63392102718353271f, 0.66328197717666626f, 0.68988502025604248f, 0.7139970064163208f, 0.7358660101890564f, 0.75570398569107056f, 0.77369099855422974f, 0.78999698162078857f, 0.80477499961853027f, 0.81816202402114868f, 0.83028298616409302f, 0.00968609005212784f, 0.02591750025749207f, 0.05318830162286758f, 0.09121809899806976f, 0.13777700066566467f, 0.18976299464702606f, 0.244159996509552f, 0.29880800843238831f, 0.35169300436973572f, 0.40180501341819763f, 0.44872200489044189f, 0.49213200807571411f, 0.53206497430801392f, 0.5686650276184082f, 0.60214298963546753f, 0.63272500038146973f, 0.66062301397323608f, 0.68605399131774902f, 0.70922297239303589f, 0.73031198978424072f, 0.74948400259017944f, 0.76689702272415161f, 0.78270000219345093f, 0.79702901840209961f, 0.00303822988644242f, 0.01048239972442389f, 0.02568300068378448f, 0.05025380104780197f, 0.08408640325069427f, 0.12561400234699249f, 0.17249999940395355f, 0.22232000529766083f, 0.27309399843215942f, 0.32321798801422119f, 0.37149098515510559f, 0.4173240065574646f, 0.4603630006313324f, 0.50043797492980957f, 0.53755801916122437f, 0.57181298732757568f, 0.60333001613616943f, 0.63226902484893799f, 0.65877401828765869f, 0.68301999568939209f, 0.70514601469039917f, 0.7253040075302124f, 0.74363899230957031f, 0.76029098033905029f, 0.00076204299693927f, 0.00361976004205644f, 0.0110037000849843f, 0.02512970007956028f, 0.04727460071444511f, 0.07745999842882156f, 0.11460299789905548f, 0.1569570004940033f, 0.20258499681949615f, 0.24971699714660645f, 0.29707801342010498f, 0.34340900182723999f, 0.38799500465393066f, 0.43043500185012817f, 0.47039699554443359f, 0.50777101516723633f, 0.54253697395324707f, 0.57473397254943848f, 0.60444700717926025f, 0.63179397583007812f, 0.65686798095703125f, 0.67979699373245239f, 0.70071202516555786f, 0.71974599361419678f, 0.00014345299859997f, 0.00102306995540857f, 0.00407376000657678f, 0.01122699957340956f, 0.02423799969255924f, 0.04415180161595345f, 0.07109060138463974f, 0.10433399677276611f, 0.14259399473667145f, 0.184347003698349f, 0.2281080037355423f, 0.27265200018882751f, 0.31696400046348572f, 0.36016398668289185f, 0.40178799629211426f, 0.44139501452445984f, 0.47875601053237915f, 0.51375597715377808f, 0.54635101556777954f, 0.57658302783966064f, 0.60447400808334351f, 0.63009101152420044f, 0.65352898836135864f, 0.67488902807235718f, 0.00001858420000644f, 0.0002227969962405f, 0.00124967005103827f, 0.00435766018927097f, 0.01113030035048723f, 0.0229835007339716f, 0.04079980030655861f, 0.06477940082550049f, 0.09447769820690155f, 0.12897300720214844f, 0.16708999872207642f, 0.20760199427604675f, 0.24936899542808533f, 0.29154899716377258f, 0.3332040011882782f, 0.37377101182937622f, 0.41274300217628479f, 0.44977998733520508f, 0.4846780002117157f, 0.51733100414276123f, 0.54769200086593628f, 0.57572799921035767f, 0.6014779806137085f, 0.62501102685928345f, 1.46482000218384201e-06f, 0.00003429050047998f, 0.0002985020109918f, 0.00140504003502429f, 0.00443577999249101f, 0.01069260016083717f, 0.02133879996836185f, 0.0371410995721817f, 0.05836030095815659f, 0.08476380258798599f, 0.11572299897670746f, 0.1503559947013855f, 0.18766500055789948f, 0.22665500640869141f, 0.26647698879241943f, 0.30632400512695312f, 0.34550899267196655f, 0.38344401121139526f, 0.41970700025558472f, 0.45401400327682495f, 0.48618701100349426f, 0.51614201068878174f, 0.54384201765060425f, 0.56930899620056152f, 5.83937982412408019e-08f, 3.2765999549155822e-06f, 0.00005055400106357f, 0.00035111699253321f, 0.00145683996379375f, 0.00427943980321288f, 0.0098936902359128f, 0.01927389949560165f, 0.03310279920697212f, 0.05168719962239265f, 0.07495570182800293f, 0.10250899940729141f, 0.13370099663734436f, 0.1677280068397522f, 0.20372100174427032f, 0.24084299802780151f, 0.27840098738670349f, 0.31564199924468994f, 0.35190799832344055f, 0.38674798607826233f, 0.41985601186752319f, 0.45104199647903442f, 0.48021000623703003f, 0.50734001398086548f, 8.73966010672688753e-10f, 1.57741993689342053e-07f, 5.21975016454234719e-06f, 0.00006079579907237f, 0.00036219600588083f, 0.00138045998755842f, 0.00386844994500279f, 0.00871635042130947f, 0.01675550080835819f, 0.02860799990594387f, 0.04461279883980751f, 0.06480839848518372f, 0.08895269781351089f, 0.11656700074672699f, 0.1470009982585907f, 0.17950700223445892f, 0.21331800520420074f, 0.24785000085830688f, 0.28237700462341309f, 0.31631898880004883f, 0.34923198819160461f, 0.38083100318908691f, 0.41094100475311279f, 0.43946701288223267f, 2.8866399288257627e-12f, 2.63671995348602195e-09f, 2.51094007808205788e-07f, 5.97520011069718748e-06f, 0.00005859580051037f, 0.0003192939911969f, 0.00116373994387686f, 0.00319523992948234f, 0.00714873988181353f, 0.0137449000030756f, 0.0235638003796339f, 0.03696820139884949f, 0.05407309904694557f, 0.0747511014342308f, 0.09866459667682648f, 0.12531900405883789f, 0.15412400662899017f, 0.18446199595928192f, 0.21573600172996521f, 0.24741099774837494f, 0.27903899550437927f, 0.310263991355896f, 0.34082499146461487f, 0.37054198980331421f, 6.94488983838260476e-16f, 7.04290011727115584e-12f, 3.21448001550095341e-09f, 2.20180993437679717e-07f, 4.50593006462440826e-06f, 0.00004154839916737f, 0.00022262999846134f, 0.00081575999502093f, 0.00227530999109149f, 0.00519366981461644f, 0.01020010001957417f, 0.0178545992821455f, 0.02856850065290928f, 0.04256030172109604f, 0.05984469875693321f, 0.08025020360946655f, 0.10345599800348282f, 0.12904399633407593f, 0.15654699504375458f, 0.1854960024356842f, 0.21545499563217163f, 0.24603499472141266f, 0.27690801024436951f, 0.3078019917011261f, 5.46278023199234311e-22f, 3.43167987041791307e-16f, 2.29294990113093622e-12f, 9.57796952860689998e-10f, 6.87986982939037262e-08f, 1.5533599935224629e-06f, 0.00001600819996384f, 0.00009555240103509f, 0.00038631301140413f, 0.00117554003372788f, 0.00289549003355205f, 0.00607588002458215f, 0.01126710046082735f, 0.01896269991993904f, 0.02954130060970783f, 0.04323289915919304f, 0.06011129915714264f, 0.0801049992442131f, 0.10301999747753143f, 0.12857000529766083f, 0.15640300512313843f, 0.18612800538539886f, 0.21734000742435455f, 0.24963200092315674f, 0.0f, 0.0f, 3.09890004335006815e-24f, 2.21276004416278673e-18f, 2.67358004631774657e-14f, 2.24439997836833882e-11f, 3.13075010360819306e-09f, 1.26480998119404831e-07f, 2.12951999856159091e-06f, 0.00001907769910758f, 0.00010753999958979f, 0.00042892698547803f, 0.00131604995112866f, 0.00330013991333544f, 0.00707077002152801f, 0.01337909977883101f, 0.02291939966380596f, 0.03622379899024963f, 0.05359359830617905f, 0.07507230341434479f, 0.10045900195837021f, 0.12935000658035278f, 0.16119599342346191f, 0.19536399841308594f
} };
__device__ static const FixedArray<float, 576>  SHEEN_ALBEDO_0 = { {
    0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f
} };
__device__ float sheenAlbedo(float3  v_1, float3  n_i_1, BSDFMaterial material_3)
{
    float _S376 = rgb_to_greyscale(material_3.sheen);
    bool _S377 = _S376 > 0.0f;
    float albedo_0;
    if(_S377)
    {
        float _S378 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S379 = (U32_min((uint(_S378)), (22U)));
        float _S380 = (F32_sqrt((0.05000000074505806f)));
        float _S381 = (F32_sqrt((0.10000000149011612f)));
        bool _S382 = (material_3.velvet) > 0.0f;
        float _S383 = _slang_select(_S382, _S381,_S380);
        float _S384 = (clamp_1((F32_sqrt(((F32_max((material_3.sheen_roughness), (0.0f)))))), _S383, 1.0f) - _S383) / (1.0f - _S383) * 23.0f;
        uint _S385 = (U32_min((uint(_S384)), (22U)));
        uint _S386 = _S379 * 24U + _S385;
        float _S387 = _S378 - float(_S379);
        float _S388 = _S384 - float(_S385);
        if(_S382)
        {
            uint _S389 = _S386 + 24U;
            float _S390 = VELVET_ALBEDO_0[_S386] + (VELVET_ALBEDO_0[_S389] - VELVET_ALBEDO_0[_S386]) * _S387;
            uint _S391 = _S386 + 1U;
            float _S392 = VELVET_ALBEDO_0[_S391] + (VELVET_ALBEDO_0[_S389 + 1U] - VELVET_ALBEDO_0[_S391]) * _S387;
            float _S393 = _S390 + (_S392 - _S390) * _S388;
            albedo_0 = _S393;
        }
        else
        {
            uint _S394 = _S386 + 24U;
            float _S395 = SHEEN_ALBEDO_0[_S386] + (SHEEN_ALBEDO_0[_S394] - SHEEN_ALBEDO_0[_S386]) * _S387;
            uint _S396 = _S386 + 1U;
            float _S397 = SHEEN_ALBEDO_0[_S396] + (SHEEN_ALBEDO_0[_S394 + 1U] - SHEEN_ALBEDO_0[_S396]) * _S387;
            float _S398 = (F32_exp((_S395 + (_S397 - _S395) * _S388)));
            albedo_0 = _S398;
        }
    }
    else
    {
        albedo_0 = 0.0f;
    }
    return albedo_0;
}

struct CoatFrame
{
    float3  normal;
    float alpha;
    float ior;
};

static __device__ CoatFrame CoatFrame_x24init_0(float3  normal_3, float alpha_0, float ior_0)
{
    CoatFrame _S399;
    (&_S399)->normal = normal_3;
    (&_S399)->alpha = alpha_0;
    (&_S399)->ior = ior_0;
    return _S399;
}

__device__ __forceinline__ CoatFrame coatFrame(BSDFMaterial material_4, float3  n_2)
{
    float3  _S400 = material_4.coat_normal;
    bool _S401 = (dot_0(_S400, _S400)) > 0.0f;
    float3  _S402 = material_4.coat_normal;
    float3  _S403 = ((((_S402)) * make_float3(rnorm3df(((_S402)).x, ((_S402)).y, ((_S402)).z))));
    float3  _S404 = _slang_select(_S401, _S403,n_2);
    float _S405 = sign_0(dot_0(_S404, n_2));
    float _S406 = material_4.coat_roughness;
    return CoatFrame_x24init_0(_S404 * make_float3 (_S405), _S406 * _S406, (F32_max((material_4.coat_ior), (1.00999999046325684f))));
}

__device__ __forceinline__ float3  coatSeries(CoatFrame coat_frame_0, BSDFMaterial material_5)
{
    float _S407 = coat_frame_0.ior * coat_frame_0.ior;
    float _S408 = _S407 * _S407;
    float _S409 = coat_frame_0.ior - 1.0f;
    float _S410 = coat_frame_0.ior + 1.0f;
    float _S411 = _S407 - 1.0f;
    float _S412 = _S407 + 1.0f;
    float _S413 = _S408 - 1.0f;
    float _S414 = _S412 * _S413;
    float _S415 = 0.5f + _S409 * (3.0f * coat_frame_0.ior + 1.0f) / (6.0f * _S410 * _S410) + _S407 * _S411 * _S411 / (_S412 * _S412 * _S412) * (F32_log((_S409 / _S410))) - 2.0f * _S407 * coat_frame_0.ior * (_S407 + 2.0f * coat_frame_0.ior - 1.0f) / _S414 + 8.0f * _S408 * (_S408 + 1.0f) / (_S414 * _S413) * (F32_log((coat_frame_0.ior)));
    float _S416 = 1.0f - (1.0f - _S415) / _S407;
    float3  _S417 = material_5.coat_tint;
    return _S417 * _S417 * make_float3 (1.0f - _S416) / (make_float3 (1.0f) - material_5.albedo * make_float3 (_S416));
}

__device__ float3  anisotropicLocal(float3  w_0, float3  t_12, float3  n_3)
{
    return make_float3 (dot_0(w_0, t_12), dot_0(w_0, cross_0(n_3, t_12)), dot_0(w_0, n_3));
}

static __device__ float unshared_0(float x_14)
{
    return x_14;
}

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_1, float U1_0, float U2_0)
{
    float3  _S418 = make_float3 (alpha_1 * Ve_0.x, alpha_1 * Ve_0.y, Ve_0.z);
    float3  _S419 = ((((_S418)) * make_float3(rnorm3df(((_S418)).x, ((_S418)).y, ((_S418)).z))));
    float _S420 = _S419.x;
    float _S421 = _S419.y;
    float _S422 = _S420 * _S420 + _S421 * _S421;
    float3  _S423;
    if(_S422 > 0.0f)
    {
        float3  _S424 = make_float3 (- _S421, _S420, 0.0f);
        float _S425 = (rsqrtf((_S422)));
        _S423 = _S424 * make_float3 (_S425);
    }
    else
    {
        _S423 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S426 = cross_0(_S419, _S423);
    float _S427 = (F32_sqrt((U1_0)));
    float _S428 = 6.28318548202514648f * U2_0;
    float _S429 = _S427 * (F32_cos((_S428)));
    float t2_0 = _S427 * (F32_sin((_S428)));
    float _S430 = 0.5f * (1.0f + _S419.z);
    float t2_1 = (1.0f - _S430) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S429 * _S429)))))) + _S430 * t2_0;
    float3  _S431 = make_float3 (_S429) * _S423 + make_float3 (t2_1) * _S426;
    float _S432 = unshared_0(_S429);
    float _S433 = unshared_0(_S429);
    float3  _S434 = _S431 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S432 * _S433 - t2_1 * t2_1))))))) * _S419;
    float3  _S435 = make_float3 (alpha_1 * _S434.x, alpha_1 * _S434.y, (F32_max((0.0f), (_S434.z))));
    float3  _S436 = ((((_S435)) * make_float3(rnorm3df(((_S435)).x, ((_S435)).y, ((_S435)).z))));
    return _S436;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_4)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S437 = (F32_abs((dot_0(n_4, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S437)
    {
        float3  _S438 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S438;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S439 = cross_0(n_4, a_4);
    float3  _S440 = ((((_S439)) * make_float3(rnorm3df(((_S439)).x, ((_S439)).y, ((_S439)).z))));
    float3  _S441 = cross_0(n_4, _S440);
    return make_float3 (dot_0(v_2, _S440), dot_0(v_2, n_4), dot_0(v_2, _S441));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_2, AnisotropicFrame frame_0, uint * random_state_2, uint first_1)
{
    Random _S442 = draw(*random_state_2, first_1);
    Random _S443 = draw(*random_state_2, first_1 | 2147483648U);
    *random_state_2 = _S443.state;
    float _S444 = frame_0.alphas.x;
    bool _S445 = _S444 > 0.0f;
    if(_S445)
    {
        float3  _S446 = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        float _S447 = frame_0.alphas.y;
        float3  _S448 = make_float3 (_S444 * _S446.x, _S447 * _S446.y, _S446.z);
        float3  _S449 = ((((_S448)) * make_float3(rnorm3df(((_S448)).x, ((_S448)).y, ((_S448)).z))));
        float3  _S450 = sampleGGXVNDF(_S449, 1.0f, _S442.value, _S443.value);
        float3  _S451 = make_float3 (_S444 * _S450.x, _S447 * _S450.y, _S450.z);
        float3  _S452 = ((((_S451)) * make_float3(rnorm3df(((_S451)).x, ((_S451)).y, ((_S451)).z))));
        return make_float3 (_S452.x) * frame_0.tangent + make_float3 (_S452.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S452.z) * n_i_2;
    }
    float3  _S453 = worldToTangent(v_3, n_i_2);
    float3  _S454 = sampleGGXVNDF(float3 {_S453.x, _S453.z, _S453.y}, alpha_2, _S442.value, _S443.value);
    float3  _S455 = float3 {_S454.x, _S454.z, _S454.y};
    float3  _S456 = tangentToWorld(_S455, n_i_2);
    return _S456;
}

__device__ __forceinline__ float3  coatHalf(float3  v_4, CoatFrame coat_frame_1, BSDFMaterial material_6, uint random_state_3)
{
    bool _S457 = (material_6.coat) > 0.0f;
    bool _S458;
    if(_S457)
    {
        _S458 = (dot_0(coat_frame_1.normal, v_4)) > 0.0f;
    }
    else
    {
        _S458 = false;
    }
    bool _S459 = !_S458;
    if(_S459)
    {
        return make_float3 (0.0f);
    }
    uint state_3 = random_state_3;
    float3  _S460 = sampleHalfVector(v_4, coat_frame_1.normal, coat_frame_1.alpha, AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f)), &state_3, 1U);
    return _S460;
}

struct Weights
{
    float v_dot_h;
    float3  refracted;
    float3  F;
    float reflect_weight;
    float3  diffuse_weight;
    float3  refract_weight;
    float p_diffuse;
    float p_reflect;
    float p_refract;
    float p_sheen_velvet;
    float p_toon;
    float3  sheen;
    float3  coat;
    float p_coat;
};

static __device__ Weights Weights_x24init_0(float v_dot_h_0, float3  refracted_1, float3  F_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float p_sheen_velvet_0, float p_toon_0, float3  sheen_0, float3  coat_0, float p_coat_0)
{
    Weights _S461;
    (&_S461)->v_dot_h = v_dot_h_0;
    (&_S461)->refracted = refracted_1;
    (&_S461)->F = F_0;
    (&_S461)->reflect_weight = reflect_weight_0;
    (&_S461)->diffuse_weight = diffuse_weight_0;
    (&_S461)->refract_weight = refract_weight_0;
    (&_S461)->p_diffuse = p_diffuse_0;
    (&_S461)->p_reflect = p_reflect_0;
    (&_S461)->p_refract = p_refract_0;
    (&_S461)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S461)->p_toon = p_toon_0;
    (&_S461)->sheen = sheen_0;
    (&_S461)->coat = coat_0;
    (&_S461)->p_coat = p_coat_0;
    return _S461;
}

__device__ __forceinline__ float3  sampledHalf(float3  v_5, float3  n_i_3, float alpha_3, AnisotropicFrame frame_1, uint random_state_4)
{
    uint state_4 = random_state_4;
    float3  _S462 = sampleHalfVector(v_5, n_i_3, alpha_3, frame_1, &state_4, 0U);
    return _S462;
}

static __device__ float3  refract_0(float3  i_5, float3  n_5, float eta_0)
{
    float _S463 = dot_0(n_5, i_5);
    float _S464 = 1.0f - eta_0 * eta_0 * (1.0f - _S463 * _S463);
    if(_S464 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S463 + (F32_sqrt((_S464)))) * n_5;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S465 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S466 = eta_i_0 / eta_o_0 * _S465;
    bool _S467 = _S466 < 1.0f;
    float kr_0;
    if(_S467)
    {
        float _S468 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S466 * _S466))))));
        float _S469 = eta_o_0 * cos_theta_0;
        float _S470 = eta_i_0 * _S468;
        float _S471 = (_S469 - _S470) / (_S469 + _S470);
        float _S472 = eta_i_0 * cos_theta_0;
        float _S473 = eta_o_0 * _S468;
        float _S474 = (_S472 - _S473) / (_S472 + _S473);
        float _S475 = (_S471 * _S471 + _S474 * _S474) / 2.0f;
        kr_0 = _S475;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

static __device__ float3  min_1(float3  x_15, float3  y_4)
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
        *_slang_vector_get_element_ptr(&result_5, i_6) = (F32_min((_slang_vector_get_element(x_15, i_6)), (_slang_vector_get_element(y_4, i_6))));
        i_6 = i_6 + int(1);
    }
    return result_5;
}

static __device__ float3  reflect_0(float3  i_7, float3  n_6)
{
    return i_7 - make_float3 (2.0f * dot_0(n_6, i_7)) * n_6;
}

__device__ float smithG1(float alpha_4, float n_dot_x_0)
{
    float _S476 = alpha_4 * alpha_4;
    float _S477 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S476 + (1.0f - _S476) * n_dot_x_0 * n_dot_x_0))));
    bool _S478 = alpha_4 > 0.0f;
    float _S479 = _slang_select(_S478, _S477,1.0f);
    return _S479;
}

__device__ __forceinline__ float coatFresnel(float3  in_dir_0, float3  v_6, float3  coat_h_0, CoatFrame coat_frame_2, float eta_i_1, bool behind_0)
{
    float _S480 = dot_0(coat_frame_2.normal, reflect_0(in_dir_0, coat_h_0));
    float _S481 = (F32_abs((dot_0(v_6, coat_h_0))));
    float _S482 = eta_i_1 / coat_frame_2.ior * (F32_sqrt(((F32_max((1.0f - _S481 * _S481), (0.0f))))));
    float _S483 = (F32_sqrt(((F32_max((1.0f - _S482 * _S482), (0.0f))))));
    float _S484 = _slang_select(behind_0, _S483,_S481);
    float _S485 = _slang_select(behind_0, coat_frame_2.ior,1.0f);
    float _S486 = _slang_select(behind_0, 1.0f,coat_frame_2.ior);
    float _S487 = fresnel(_S484, _S485, _S486);
    float _S488 = smithG1(coat_frame_2.alpha, _S480);
    float _S489 = _S487 * _S488;
    bool _S490 = _S480 > 0.0f;
    float _S491 = _slang_select(_S490, _S489,0.0f);
    return _S491;
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

__device__ __forceinline__ Weights lobeWeights(float3  in_dir_1, float3  v_7, float3  n_i_4, float3  ggx_n_0, float3  coat_h_1, AnisotropicFrame frame_2, float sheen_albedo_0, CoatFrame coat_frame_3, float3  coat_series_0, BSDFMaterial material_7, float eta_i_2, float eta_o_1)
{
    float _S492 = dot_0(ggx_n_0, v_7);
    float _S493 = eta_i_2 / eta_o_1;
    float3  _S494 = refract_0(in_dir_1, ggx_n_0, _S493);
    float3  _S495 = ((((_S494)) * make_float3(rnorm3df(((_S494)).x, ((_S494)).y, ((_S494)).z))));
    float _S496 = (F32_min(((F32_sqrt((material_7.specular_level))) * (F32_abs((eta_i_2 - eta_o_1))) / (eta_i_2 + eta_o_1)), (0.9999847412109375f)));
    float _S497 = _S496 * _S496;
    float _S498 = (1.0f + _S496) / (1.0f - _S496);
    float _S499 = (F32_abs((_S492)));
    bool _S500 = eta_i_2 > eta_o_1;
    float sheen_component_0;
    if(_S500)
    {
        sheen_component_0 = _S498;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float toon_component_0;
    if(_S500)
    {
        toon_component_0 = 1.0f;
    }
    else
    {
        toon_component_0 = _S498;
    }
    float _S501 = fresnel(_S499, sheen_component_0, toon_component_0);
    bool _S502 = (eta_i_2 * eta_i_2 * (1.0f - _S492 * _S492)) >= (eta_o_1 * eta_o_1);
    float3  _S503;
    if(_S502)
    {
        _S503 = make_float3 (1.0f);
    }
    else
    {
        float3  _S504 = material_7.specular_tint * make_float3 (_S497);
        _S503 = _S504 + (make_float3 (1.0f) - _S504) * make_float3 (_S501 - _S497) / make_float3 (1.0f - _S497);
    }
    float3  _S505 = make_float3 (1.0f);
    float3  _S506 = make_float3 (0.0f);
    float _S507 = rgb_to_greyscale(material_7.sheen);
    bool _S508 = _S507 > 0.0f;
    float3  sheen_1;
    float3  scale_1;
    if(_S508)
    {
        float _S509 = (F32_min((sheen_albedo_0), (1.0f)));
        float3  _S510 = make_float3 (1.0f) - material_7.sheen * make_float3 (_S509);
        float _S511 = rgb_to_greyscale(material_7.sheen);
        float _S512 = _S511 * _S509;
        float3  _S513 = material_7.sheen / make_float3 ((F32_max((sheen_albedo_0), (1.0f))));
        sheen_component_0 = _S512;
        sheen_1 = _S513;
        scale_1 = _S510;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S506;
        scale_1 = _S505;
    }
    float _S514 = (F32_abs((material_7.toon.x)));
    bool _S515 = _S514 > 0.0f;
    if(_S515)
    {
        float _S516 = (F32_min((_S514), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S516);
        float _S517 = rgb_to_greyscale(material_7.albedo);
        float _S518 = _S516 * _S517;
        toon_component_0 = _S518;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
    }
    bool _S519 = (material_7.metallic) > 0.0f;
    float3  rebounce_0;
    if(_S519)
    {
        float _S520 = frame_2.alphas.x;
        float _S521 = (F32_sqrt(((F32_min((_S520), (frame_2.alphas.y))))));
        bool _S522 = _S520 > 0.0f;
        float _S523 = _slang_select(_S522, _S521,material_7.roughness);
        float _S524 = _S523 * _S523;
        float _S525 = (F32_pow((_S524), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S524) / (1.0f + 1.28094995021820068f * _S524);
        bool _S526 = _S524 > 0.0f;
        float _S527 = _slang_select(_S526, _S525,0.0f);
        float _S528 = clamp_1(dot_0(n_i_4, v_7), 0.0f, 1.0f);
        float _S529 = _S524 * _S523;
        float _S530 = (F32_min((1.00064504146575928f - _S523 * (0.00375499995425344f + _S528 * (-0.04133399948477745f + _S528 * (-0.90938502550125122f + _S528 * 0.35275399684906006f))) - _S524 * (0.27602800726890564f + _S528 * (1.27023398876190186f + _S528 * 0.04740000143647194f)) - _S529 * (0.31452900171279907f - _S528 * 0.34830701351165771f) + _S529 * _S523 * 0.27229699492454529f), (1.0f)));
        float3  _S531 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_7.albedo * make_float3 (_S527)), make_float3 (1.0f / (F32_max((_S530), (0.0000152587890625f)))));
        rebounce_0 = _S531;
    }
    else
    {
        rebounce_0 = _S505;
    }
    bool _S532 = (dot_0(coat_h_1, coat_h_1)) > 0.0f;
    float3  coat_1;
    float3  up_0;
    float3  through_0;
    if(_S532)
    {
        float _S533 = coatFresnel(in_dir_1, v_7, coat_h_1, coat_frame_3, eta_i_2, _S500);
        float _S534 = material_7.coat * _S533;
        float3  _S535 = material_7.coat_tint;
        float3  _S536 = _S535 * _S535;
        float3  _S537 = _slang_select(_S500, _S536,_S505);
        float3  _S538 = make_float3 (_S534) * _S537;
        float _S539 = 1.0f - _S533;
        bool _S540 = !_S500;
        float3  _S541 = _slang_select(_S540, coat_series_0,_S505);
        float3  _S542 = mix_0(_S505, make_float3 (_S539) * _S541, material_7.coat);
        float3  _S543 = mix_0(_S505, make_float3 (_S539) * material_7.coat_tint, material_7.coat);
        coat_1 = _S538;
        up_0 = _S542;
        through_0 = _S543;
    }
    else
    {
        coat_1 = _S506;
        up_0 = _S505;
        through_0 = _S505;
    }
    float3  _S544 = scale_1 * coat_1;
    float _S545 = rgb_to_greyscale(_S544);
    float3  _S546 = mix_0(_S503, material_7.albedo * rebounce_0, material_7.metallic);
    float3  F_1 = _S546 * scale_1 * up_0;
    float _S547 = rgb_to_greyscale(F_1);
    float _S548 = 1.0f - material_7.metallic;
    float3  _S549 = make_float3 (1.0f) - _S503;
    float3  _S550 = make_float3 ((1.0f - material_7.transmission) * _S548) * _S549 * scale_1 * up_0;
    float3  _S551 = make_float3 (material_7.transmission * _S548) * _S549 * scale_1 * through_0;
    float _S552 = (F32_max((_S547), (0.0f)));
    float _S553 = rgb_to_greyscale(_S550);
    float _S554 = (F32_max((_S553), (0.0f)));
    float _S555 = rgb_to_greyscale(_S551);
    float _S556 = sign_0(length_0(_S495));
    float _S557 = (F32_max((_S555 * _S556), (0.0f)));
    float _S558 = _S552 + _S554 + _S557 + toon_component_0 + _S545;
    float _S559 = (F32_min((sheen_component_0), (1.0f)));
    bool _S560 = sheen_component_0 > 0.0f;
    bool _S561;
    if(_S560)
    {
        _S561 = !(_S558 > 0.0f);
    }
    else
    {
        _S561 = false;
    }
    float _S562 = _slang_select(_S561, 1.0f,_S559);
    float _S563 = (1.0f - _S562) / (F32_max((_S558), (0.0000152587890625f)));
    float _S564 = _S554 * _S563;
    float _S565 = _S552 * _S563;
    float _S566 = _S557 * _S563;
    return Weights_x24init_0(_S492, _S495, F_1, 1.0f, _S550, _S551, _S564, _S565, _S566, _S562, toon_component_0 * _S563, sheen_1, _S544, _S545 * _S563);
}

__device__ __forceinline__ float3  refractedHalf(float3  in_dir_2, float3  out_dir_0, float3  n_7, float eta_i_3, float eta_o_2)
{
    float3  _S567 = negate_0(in_dir_2);
    float3  _S568 = negate_0(make_float3 (eta_i_3) * _S567 + make_float3 (eta_o_2) * out_dir_0);
    float3  _S569 = ((((_S568)) * make_float3(rnorm3df(((_S568)).x, ((_S568)).y, ((_S568)).z))));
    float _S570 = sign_0(dot_0(n_7, _S567));
    float _S571 = sign_0(dot_0(_S568, n_7 * make_float3 (_S570)));
    return _S569 * make_float3 (_S571);
}

__device__ __forceinline__ float3  reflectedHalf(float3  in_dir_3, float3  out_dir_1)
{
    float3  _S572 = negate_0(in_dir_3);
    float3  _S573 = _S572 + out_dir_1;
    float3  _S574 = ((((_S573)) * make_float3(rnorm3df(((_S573)).x, ((_S573)).y, ((_S573)).z))));
    return _S574;
}

__device__ float translucentShare(BSDFMaterial material_8)
{
    float _S575 = rgb_to_greyscale(material_8.translucent);
    float _S576 = rgb_to_greyscale(material_8.albedo);
    float _S577 = _S575 / (_S576 + _S575);
    bool _S578 = _S575 > 0.0f;
    float _S579 = _slang_select(_S578, _S577,0.0f);
    return _S579;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float n_i_dot_v_0, BSDFMaterial material_9, Weights w_1)
{
    float _S580 = translucentShare(material_9);
    float _S581 = w_1.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S582 = w_1.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S583 = 1.0f - _S580;
    bool _S584 = n_i_dot_l_0 < 0.0f;
    float _S585 = _slang_select(_S584, _S580,_S583);
    float _S586 = _S582 * _S585;
    bool _S587 = _S580 > 0.0f;
    float _S588 = _slang_select(_S587, _S586,_S581);
    bool _S589 = n_i_dot_v_0 > 0.0f;
    float _S590 = _slang_select(_S589, _S588,0.0f);
    return _S590;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_5, BSDFMaterial material_10, Weights w_2)
{
    float _S591 = translucentShare(material_10);
    bool _S592 = (dot_0(n_i_5, l_0)) < 0.0f;
    float3  _S593 = _slang_select(_S592, material_10.translucent,material_10.albedo);
    float _S594 = 1.0f - _S591;
    float _S595 = _slang_select(_S592, _S591,_S594);
    float3  _S596 = _S593 / make_float3 (_S595);
    bool _S597 = _S591 > 0.0f;
    float3  _S598 = _slang_select(_S597, _S596,material_10.albedo);
    return w_2.diffuse_weight * _S598 / make_float3 (w_2.p_diffuse);
}

__device__ float trowbridgeReitz(float alpha_5, float n_dot_h_0)
{
    float _S599 = alpha_5 * alpha_5;
    float _S600 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S599 * n_dot_h_0 * n_dot_h_0;
    return _S599 / (F32_max((3.14159274101257324f * _S600 * _S600), (1.17549435082228751e-38f)));
}

__device__ float anisotropicG1(float3  w_3, float2  alphas_1)
{
    float _S601 = (F32_max((w_3.z), (0.0f)));
    return 2.0f * _S601 / (_S601 + length_0(make_float3 (alphas_1.x * w_3.x, alphas_1.y * w_3.y, _S601)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S602 = alphas_2.x;
    float _S603 = h_0.x / _S602;
    float _S604 = alphas_2.y;
    float _S605 = h_0.y / _S604;
    float _S606 = h_0.z;
    float _S607 = _S603 * _S603 + _S605 * _S605 + _S606 * _S606;
    return 1.0f / (F32_max((3.14159274101257324f * _S602 * _S604 * _S607 * _S607), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float3  v_8, float3  h_1, float3  n_i_6, float n_i_dot_v_1, float alpha_6, AnisotropicFrame frame_3, float v_dot_h_1)
{
    float _S608 = dot_0(n_i_6, h_1);
    float _S609 = smithG1(alpha_6, n_i_dot_v_1);
    float _S610 = _S609 * v_dot_h_1;
    float _S611 = trowbridgeReitz(alpha_6, _S608);
    float _S612 = _S610 * _S611 / n_i_dot_v_1;
    bool _S613 = alpha_6 > 0.0f;
    bool _S614;
    if(_S613)
    {
        _S614 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S614 = false;
    }
    if(_S614)
    {
        _S614 = _S608 > 0.0f;
    }
    else
    {
        _S614 = false;
    }
    if(_S614)
    {
        _S614 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S614 = false;
    }
    float _S615 = _slang_select(_S614, _S612,0.0f);
    bool _S616 = (frame_3.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S616)
    {
        float3  _S617 = anisotropicLocal(v_8, frame_3.tangent, n_i_6);
        float _S618 = anisotropicG1(_S617, frame_3.alphas);
        float3  _S619 = anisotropicLocal(h_1, frame_3.tangent, n_i_6);
        float _S620 = anisotropicD(_S619, frame_3.alphas);
        float _S621 = _S618 * _S620;
        float _S622 = _S621 * v_dot_h_1 / n_i_dot_v_1;
        bool _S623 = v_dot_h_1 > 0.0f;
        if(_S623)
        {
            _S614 = _S608 > 0.0f;
        }
        else
        {
            _S614 = false;
        }
        if(_S614)
        {
            _S614 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S614 = false;
        }
        float _S624 = _slang_select(_S614, _S622,0.0f);
        pdf_h_0 = _S624;
    }
    else
    {
        pdf_h_0 = _S615;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float l_dot_h_0, float pdf_h_1, Weights w_4, float eta_i_4, float eta_o_3)
{
    float _S625 = eta_i_4 * w_4.v_dot_h + eta_o_3 * l_dot_h_0;
    float _S626 = w_4.p_refract * pdf_h_1 * eta_o_3 * eta_o_3 * (F32_abs((l_dot_h_0))) / (_S625 * _S625);
    bool _S627 = eta_i_4 != eta_o_3;
    bool _S628;
    if(_S627)
    {
        _S628 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S628 = false;
    }
    float _S629 = _slang_select(_S628, _S626,0.0f);
    return _S629;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_7, float alpha_7, AnisotropicFrame frame_4, BSDFMaterial material_11, Weights w_5)
{
    float _S630 = - dot_0(n_i_7, l_1);
    float _S631 = smithG1(alpha_7, (F32_max((_S630), (0.0f))));
    bool _S632 = (frame_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S632)
    {
        float3  _S633 = negate_0(n_i_7);
        float3  _S634 = anisotropicLocal(l_1, frame_4.tangent, _S633);
        float _S635 = anisotropicG1(_S634, frame_4.alphas);
        G1_l_0 = _S635;
    }
    else
    {
        G1_l_0 = _S631;
    }
    return w_5.refract_weight * make_float3 (G1_l_0) * material_11.albedo / make_float3 (w_5.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_1, float n_i_dot_v_2, Weights w_6)
{
    float _S636 = w_6.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S637 = n_i_dot_l_1 > 0.0f;
    bool _S638;
    if(_S637)
    {
        _S638 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S638 = false;
    }
    float _S639 = _slang_select(_S638, _S636,0.0f);
    return _S639;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  v_9, float3  n_i_8, BSDFMaterial material_12, Weights w_7)
{
    float3  _S640 = l_2 + v_9;
    float3  _S641 = ((((_S640)) * make_float3(rnorm3df(((_S640)).x, ((_S640)).y, ((_S640)).z))));
    float _S642 = dot_0(n_i_8, _S641);
    float _S643 = (F32_max((dot_0(n_i_8, l_2)), (0.0f)));
    float _S644 = (F32_max((dot_0(n_i_8, v_9)), (0.0f)));
    float _S645 = 1.0f / (F32_max((material_12.sheen_roughness), (0.05000000074505806f)));
    float _S646 = 1.0f - _S642 * _S642;
    float _S647 = (2.0f + _S645) * (F32_pow(((F32_max((_S646), (0.0f)))), (0.5f * _S645))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S643 + _S644 - _S643 * _S644)), (0.0000152587890625f)));
    bool _S648 = (material_12.velvet) > 0.0f;
    float f_1;
    if(_S648)
    {
        float _S649 = (F32_max((material_12.sheen_roughness), (0.00999999977648258f)));
        float _S650 = _S649 * _S649;
        float _S651 = (F32_max((_S646), (0.0000152587890625f)));
        float _S652 = (F32_exp((- _S642 * _S642 / (_S651 * _S650)))) / (3.14159274101257324f * _S650 * _S651 * _S651) * (F32_min((1.0f), (2.0f * _S642 * (F32_min((_S643), (_S644))) / (F32_max(((F32_abs((dot_0(_S641, v_9))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S643 * _S644), (0.0000152587890625f)));
        f_1 = _S652;
    }
    else
    {
        f_1 = _S647;
    }
    return w_7.sheen * make_float3 (f_1 * _S643 * 2.0f * 3.14159274101257324f / w_7.p_sheen_velvet);
}

__device__ __forceinline__ float coatPDF(float3  v_10, float3  coat_h_2, CoatFrame coat_frame_4, Weights w_8)
{
    float _S653 = dot_0(coat_frame_4.normal, v_10);
    float _S654 = smithG1(coat_frame_4.alpha, _S653);
    float _S655 = trowbridgeReitz(coat_frame_4.alpha, dot_0(coat_frame_4.normal, coat_h_2));
    float _S656 = _S654 * _S655 / (4.0f * _S653);
    bool _S657 = (coat_frame_4.alpha) > 0.0f;
    float _S658 = _slang_select(_S657, _S656,0.0f);
    return w_8.p_coat * _S658;
}

__device__ __forceinline__ float3  coatBSDF(Weights w_9)
{
    return w_9.coat / make_float3 (w_9.p_coat);
}

struct ToonProfile
{
    float3  toon;
    bool glossy;
    float a;
    float s;
    float b;
    float norm;
    float view;
    float3  axis;
};

__device__ __forceinline__ float toonP(float t_13, float a_5, float s_0)
{
    float _S659;
    if(t_13 < a_5)
    {
        _S659 = 1.0f;
    }
    else
    {
        _S659 = (F32_max((1.0f - (t_13 - a_5) / (F32_max((s_0), (0.0000152587890625f)))), (0.0f)));
    }
    return _S659;
}

__device__ __forceinline__ float toonIntegral(float t_14, float a_6, float s_1, bool glossy_0)
{
    float integral_0;
    if(glossy_0)
    {
        integral_0 = 1.0f - (F32_cos(((F32_min((t_14), (a_6))))));
    }
    else
    {
        float _S660 = (F32_sin(((F32_min((t_14), (a_6))))));
        integral_0 = _S660 * _S660 / 2.0f;
    }
    bool _S661 = t_14 > a_6;
    bool _S662;
    if(_S661)
    {
        _S662 = s_1 > 0.0f;
    }
    else
    {
        _S662 = false;
    }
    if(_S662)
    {
        float _S663;
        if(glossy_0)
        {
            float _S664 = (F32_cos((a_6)));
            float _S665 = (F32_cos((t_14)));
            _S663 = (1.0f + a_6 / s_1) * (_S664 - _S665) - ((F32_sin((t_14))) - t_14 * _S665 - ((F32_sin((a_6))) - a_6 * _S664)) / s_1;
        }
        else
        {
            float _S666 = 2.0f * a_6;
            float _S667 = (F32_cos((_S666)));
            float _S668 = 2.0f * t_14;
            float _S669 = (F32_cos((_S668)));
            _S663 = (1.0f + a_6 / s_1) * (_S667 - _S669) / 4.0f - ((F32_sin((_S668))) / 8.0f - t_14 * _S669 / 4.0f - ((F32_sin((_S666))) / 8.0f - a_6 * _S667 / 4.0f)) / s_1;
        }
        float integral_1 = integral_0 + _S663;
        integral_0 = integral_1;
    }
    return integral_0;
}

static __device__ ToonProfile ToonProfile_x24init_0(float3  toon_0, bool glossy_1, float a_7, float s_2, float b_1, float norm_0, float view_0, float3  axis_0)
{
    ToonProfile _S670;
    (&_S670)->toon = toon_0;
    (&_S670)->glossy = glossy_1;
    (&_S670)->a = a_7;
    (&_S670)->s = s_2;
    (&_S670)->b = b_1;
    (&_S670)->norm = norm_0;
    (&_S670)->view = view_0;
    (&_S670)->axis = axis_0;
    return _S670;
}

__device__ __forceinline__ ToonProfile toonProfile(float3  v_11, float3  n_i_9, BSDFMaterial material_13)
{
    float _S671 = material_13.toon.x;
    bool _S672 = _S671 < 0.0f;
    float _S673 = clamp_1(material_13.toon.y / _S671, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S674 = clamp_1(material_13.toon.z / _S671, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S675 = (F32_min((_S673 + _S674), (1.57079637050628662f)));
    float _S676 = dot_0(n_i_9, v_11);
    float _S677 = toonP((F32_acos(((F32_min((_S676), (1.0f)))))), _S673, _S674);
    float3  _S678;
    if(_S672)
    {
        float3  _S679 = make_float3 (2.0f * _S676) * n_i_9 - v_11;
        float3  _S680 = ((((_S679)) * make_float3(rnorm3df(((_S679)).x, ((_S679)).y, ((_S679)).z))));
        _S678 = _S680;
    }
    else
    {
        _S678 = n_i_9;
    }
    float3  _S681 = make_float3 ((F32_min(((F32_abs((_S671)))), (1.0f)))) * material_13.albedo;
    float _S682 = toonIntegral(_S675, _S673, _S674, _S672);
    return ToonProfile_x24init_0(_S681, _S672, _S673, _S674, _S675, 6.28318548202514648f * _S682, _S677, _S678);
}

__device__ __forceinline__ float toonPDF(float3  l_3, float3  n_i_10, ToonProfile profile_0, Weights w_10)
{
    float _S683 = dot_0(n_i_10, l_3);
    float _S684 = dot_0(l_3, profile_0.axis);
    float _S685 = _slang_select(profile_0.glossy, _S684,_S683);
    float _S686 = (F32_acos((clamp_1(_S685, -1.0f, 1.0f))));
    float _S687 = toonP(_S686, profile_0.a, profile_0.s);
    float _S688 = w_10.p_toon * _S687;
    float _S689 = _slang_select(profile_0.glossy, 1.0f,_S683);
    float _S690 = _S688 * _S689 / profile_0.norm;
    bool _S691;
    if(profile_0.glossy)
    {
        _S691 = true;
    }
    else
    {
        _S691 = _S683 > 0.0f;
    }
    float _S692 = _slang_select(_S691, _S690,0.0f);
    return _S692;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_4, float3  n_i_11, ToonProfile profile_1, Weights w_11)
{
    float _S693 = (F32_max((dot_0(n_i_11, l_4)), (0.0f)));
    float _S694 = _slang_select(profile_1.glossy, _S693,profile_1.view);
    return profile_1.toon * make_float3 (_S694) / make_float3 (w_11.p_toon);
}

__device__ __forceinline__ float reflectPDF(float pdf_h_2, Weights w_12)
{
    float _S695 = w_12.p_reflect * pdf_h_2 / (4.0f * w_12.v_dot_h);
    bool _S696 = pdf_h_2 > 0.0f;
    float _S697 = _slang_select(_S696, _S695,0.0f);
    return _S697;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_5, float3  n_i_12, float alpha_8, AnisotropicFrame frame_5, Weights w_13)
{
    float _S698 = dot_0(n_i_12, l_5);
    float _S699 = smithG1(alpha_8, (F32_max((_S698), (0.0f))));
    bool _S700 = (frame_5.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S700)
    {
        float3  _S701 = anisotropicLocal(l_5, frame_5.tangent, n_i_12);
        float _S702 = anisotropicG1(_S701, frame_5.alphas);
        G1_l_1 = _S702;
    }
    else
    {
        G1_l_1 = _S699;
    }
    return make_float3 (w_13.reflect_weight * G1_l_1) * w_13.F / make_float3 (w_13.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_8, BSDFMaterial material_14, float eta_i_5, float eta_o_4, bool refracted_2, uint random_state_5, uint mask_0, FixedArray<float3 , 6>  * throughputs_0, FixedArray<float, 6>  * pdfs_0)
{
    float3  _S703 = negate_0(in_dir_4);
    float _S704 = dot_0(n_8, _S703);
    float _S705 = sign_0(_S704);
    float3  _S706 = n_8 * make_float3 (_S705);
    float _S707 = dot_0(_S706, out_dir_2);
    float _S708 = material_14.roughness;
    float _S709 = _S708 * _S708;
    AnisotropicFrame _S710 = anisotropicFrame(material_14, _S706);
    float _S711 = sheenAlbedo(_S703, _S706, material_14);
    float3  _S712 = make_float3 (0.0f);
    CoatFrame _S713 = CoatFrame_x24init_0(_S712, 0.0f, 0.0f);
    bool _S714 = (material_14.coat) > 0.0f;
    CoatFrame coat_frame_5;
    float3  coat_series_1;
    if(_S714)
    {
        CoatFrame coat_frame_6 = coatFrame(material_14, _S706);
        float3  _S715 = coatSeries(coat_frame_6, material_14);
        coat_frame_5 = coat_frame_6;
        coat_series_1 = _S715;
    }
    else
    {
        coat_frame_5 = _S713;
        coat_series_1 = _S712;
    }
    float _S716 = rgb_to_greyscale(material_14.translucent);
    bool _S717 = _S716 > 0.0f;
    bool _S718 = (dot_0(n_8, out_dir_2) * _S704) < 0.0f;
    bool _S719 = (F32_abs((material_14.toon.x))) > 0.0f;
    uint _S720;
    if(_S714)
    {
        _S720 = 6U;
    }
    else
    {
        if(_S719)
        {
            _S720 = 5U;
        }
        else
        {
            _S720 = 4U;
        }
    }
    uint i_8 = 0U;
    for(;;)
    {
        if(i_8 < 6U)
        {
        }
        else
        {
            break;
        }
        (*throughputs_0)[i_8] = _S712;
        (*pdfs_0)[i_8] = 0.0f;
        uint i_9 = i_8 + 1U;
        i_8 = i_9;
    }
    float3  _S721 = coatHalf(_S703, coat_frame_5, material_14, random_state_5);
    Weights _S722 = Weights_x24init_0(0.0f, _S712, _S712, 0.0f, _S712, _S712, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S712, _S712, 0.0f);
    bool _S723 = (mask_0 & 49U) != 0U;
    bool _S724;
    if(_S723)
    {
        if(_S717)
        {
            _S724 = _S718;
        }
        else
        {
            _S724 = false;
        }
        bool _S725 = _S724 == refracted_2;
        if(_S725)
        {
            _S724 = true;
        }
        else
        {
            bool _S726 = !refracted_2;
            if(_S726)
            {
                _S724 = _S720 > 4U;
            }
            else
            {
                _S724 = false;
            }
        }
    }
    else
    {
        _S724 = false;
    }
    float3  sampled_n_0;
    Weights sampled_w_0;
    if(_S724)
    {
        float3  sampled_n_1 = sampledHalf(_S703, _S706, _S709, _S710, random_state_5);
        Weights _S727 = lobeWeights(in_dir_4, _S703, _S706, sampled_n_1, _S721, _S710, _S711, coat_frame_5, coat_series_1, material_14, eta_i_5, eta_o_4);
        sampled_w_0 = _S727;
        sampled_n_0 = sampled_n_1;
    }
    else
    {
        sampled_w_0 = _S722;
        sampled_n_0 = _S712;
    }
    float3  f_2;
    if(refracted_2)
    {
        float3  _S728 = refractedHalf(in_dir_4, out_dir_2, n_8, eta_i_5, eta_o_4);
        f_2 = _S728;
    }
    else
    {
        float3  _S729 = reflectedHalf(in_dir_4, out_dir_2);
        f_2 = _S729;
    }
    bool _S730 = (mask_0 & 14U) != 0U;
    Weights w_14;
    if(_S730)
    {
        Weights _S731 = lobeWeights(in_dir_4, _S703, _S706, f_2, _S721, _S710, _S711, coat_frame_5, coat_series_1, material_14, eta_i_5, eta_o_4);
        w_14 = _S731;
    }
    else
    {
        w_14 = _S722;
    }
    i_8 = 0U;
    for(;;)
    {
        if(i_8 < _S720)
        {
        }
        else
        {
            break;
        }
        uint _S732;
        if(i_8 == 3U)
        {
            _S732 = 4U;
        }
        else
        {
            if(i_8 == 4U)
            {
                _S732 = 6U;
            }
            else
            {
                if(i_8 == 5U)
                {
                    _S732 = 5U;
                }
                else
                {
                    _S732 = i_8;
                }
            }
        }
        bool _S733 = (mask_0 & (1U << i_8)) == 0U;
        bool _S734;
        if(_S733)
        {
            _S724 = true;
        }
        else
        {
            bool _S735 = _S732 == 0U;
            if(_S735)
            {
                _S724 = _S717;
            }
            else
            {
                _S724 = false;
            }
            if(_S724)
            {
                _S734 = _S718;
            }
            else
            {
                _S734 = _S732 == 1U;
            }
            _S724 = _S734 != refracted_2;
        }
        if(_S724)
        {
            _S734 = true;
        }
        else
        {
            bool _S736 = _S732 == 6U;
            if(_S736)
            {
                _S734 = !_S719;
            }
            else
            {
                _S734 = false;
            }
        }
        if(_S734)
        {
            uint i_10 = i_8 + 1U;
            i_8 = i_10;
            continue;
        }
        switch(_S732)
        {
        case 0U:
            {
                float _S737 = diffusePDF(_S707, (F32_abs((_S704))), material_14, sampled_w_0);
                (*pdfs_0)[int(0)] = _S737;
                float3  _S738 = diffuseBSDF(out_dir_2, _S706, material_14, sampled_w_0);
                (*throughputs_0)[int(0)] = _S738;
                break;
            }
        case 1U:
            {
                float _S739 = dot_0(out_dir_2, f_2);
                float _S740 = vndfPDF(_S703, f_2, _S706, (F32_abs((_S704))), _S709, _S710, w_14.v_dot_h);
                float _S741 = refractPDF(_S739, _S740, w_14, eta_i_5, eta_o_4);
                (*pdfs_0)[int(1)] = _S741;
                float3  _S742 = refractBSDF(out_dir_2, _S706, _S709, _S710, material_14, w_14);
                (*throughputs_0)[int(1)] = _S742;
                break;
            }
        case 4U:
            {
                float _S743 = sheenVelvetPDF(_S707, (F32_abs((_S704))), w_14);
                (*pdfs_0)[int(3)] = _S743;
                float3  _S744 = sheenVelvetBSDF(out_dir_2, _S703, _S706, material_14, w_14);
                (*throughputs_0)[int(3)] = _S744;
                break;
            }
        case 5U:
            {
                Weights _S745 = lobeWeights(in_dir_4, _S703, _S706, sampled_n_0, f_2, _S710, _S711, coat_frame_5, coat_series_1, material_14, eta_i_5, eta_o_4);
                float _S746 = coatPDF(_S703, f_2, coat_frame_5, _S745);
                (*pdfs_0)[int(5)] = _S746;
                float3  _S747 = coatBSDF(_S745);
                (*throughputs_0)[int(5)] = _S747;
                break;
            }
        case 6U:
            {
                ToonProfile _S748 = toonProfile(_S703, _S706, material_14);
                float _S749 = toonPDF(out_dir_2, _S706, _S748, sampled_w_0);
                (*pdfs_0)[int(4)] = _S749;
                float3  _S750 = toonBSDF(out_dir_2, _S706, _S748, sampled_w_0);
                (*throughputs_0)[int(4)] = _S750;
                break;
            }
        default:
            {
                float _S751 = vndfPDF(_S703, f_2, _S706, (F32_abs((_S704))), _S709, _S710, w_14.v_dot_h);
                float _S752 = reflectPDF(_S751, w_14);
                (*pdfs_0)[int(2)] = _S752;
                float3  _S753 = reflectBSDF(out_dir_2, _S706, _S709, _S710, w_14);
                (*throughputs_0)[int(2)] = _S753;
                break;
            }
        }
        uint i_10 = i_8 + 1U;
        i_8 = i_10;
    }
    i_8 = 0U;
    f_2 = _S712;
    for(;;)
    {
        if(i_8 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S754 = ((*pdfs_0)[i_8]) > 0.0f;
        if(_S754)
        {
            float3  f_3 = f_2 + (*throughputs_0)[i_8] * make_float3 ((*pdfs_0)[i_8]);
            f_2 = f_3;
        }
        uint i_11 = i_8 + 1U;
        i_8 = i_11;
    }
    return f_2;
}

static __device__ __noinline__ float3  skyColor_0(float3  in_dir_5, float3  dir_3, FKSurface * surface_1, float wavelength_3, float2  eta_1, bool is_inside_2, float pdf_0, uint random_state_6, uint depth_0)
{
    BSDFMaterial _S755 = pathMaterial(surface_1->material, wavelength_3);
    float _S756 = eta_1.x;
    float _S757 = eta_1.y;
    bool _S758 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    FixedArray<float3 , 6>  throughputs_1;
    FixedArray<float, 6>  pdfs_1;
    float3  _S759 = BSDF(in_dir_5, dir_3, surface_1->smooth_n, _S755, _S756, _S757, _S758, random_state_6, 4294967295U, &throughputs_1, &pdfs_1);
    float3  _S760 = make_float3 (0.0f);
    uint i_12 = 0U;
    float3  color_0 = _S760;
    for(;;)
    {
        if(i_12 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S761 = (pdfs_1[i_12]) > 0.0f;
        if(_S761)
        {
            float3  _S762 = throughputs_1[i_12] * make_float3 (pdfs_1[i_12]) / make_float3 (pdfs_1[i_12] + pdf_0);
            uint _S763;
            if(i_12 == 3U)
            {
                _S763 = 4U;
            }
            else
            {
                if(i_12 == 4U)
                {
                    _S763 = 6U;
                }
                else
                {
                    if(i_12 == 5U)
                    {
                        _S763 = 5U;
                    }
                    else
                    {
                        _S763 = i_12;
                    }
                }
            }
            float3  _S764 = (fcptEnvMapSample((dir_3), (depth_0), (_S763)));
            float3  color_1 = color_0 + _S762 * _S764;
            color_0 = color_1;
        }
        uint i_13 = i_12 + 1U;
        i_12 = i_13;
    }
    return color_0;
}

__device__ float3  skyBSDF(float3  in_dir_6, float3  dir_4, FKSurface surface_2, BSDFMaterial material_15, float2  eta_2, bool is_inside_3, float pdf_1, uint random_state_7)
{
    float _S765 = eta_2.x;
    float _S766 = eta_2.y;
    bool _S767 = wrongSide_0(is_inside_3, false, dir_4, surface_2.geometry_n);
    FixedArray<float3 , 6>  throughputs_2;
    FixedArray<float, 6>  pdfs_2;
    float3  _S768 = BSDF(in_dir_6, dir_4, surface_2.smooth_n, material_15, _S765, _S766, _S767, random_state_7, 4294967295U, &throughputs_2, &pdfs_2);
    float3  _S769 = make_float3 (0.0f);
    uint i_14 = 0U;
    float3  f_4 = _S769;
    for(;;)
    {
        if(i_14 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S770 = (pdfs_2[i_14]) > 0.0f;
        if(_S770)
        {
            float3  f_5 = f_4 + throughputs_2[i_14] * make_float3 (pdfs_2[i_14]) / make_float3 (pdfs_2[i_14] + pdf_1);
            f_4 = f_5;
        }
        uint i_15 = i_14 + 1U;
        i_14 = i_15;
    }
    return f_4;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_2, uint random_state_8)
{
    SkySample _S771;
    (&_S771)->dir = dir_5;
    (&_S771)->radiance = radiance_0;
    (&_S771)->color = color_2;
    (&_S771)->random_state = random_state_8;
    return _S771;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float wavelength_4, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S772 = (fcptEnvironmentCdfSize());
    uint2  _S773 = make_uint2 (1U, 0U);
    uint2  _S774 = _S772 - _S773;
    Random _S775 = draw(init_random_state_0, 6U);
    Random _S776 = draw(init_random_state_0, 2147483654U);
    Random _S777 = draw(init_random_state_0, 7U);
    Random _S778 = draw(init_random_state_0, 2147483655U);
    uint _S779 = _S774.x;
    uint _S780 = searchCDF_0(make_uint2 (_S779, 0U), make_uint2 (0U, 1U), _S774.y, _S775.value);
    uint _S781 = searchCDF_0(make_uint2 (0U, _S780), _S773, _S779, _S776.value);
    float2  _S782 = make_float2 ((float)_S774.x, (float)_S774.y);
    float2  _S783 = (make_float2 (float(_S781), float(_S780)) + make_float2 (_S777.value, _S778.value)) / _S782 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S784 = _S783.y;
    float _S785 = (F32_sin((_S784)));
    float _S786 = _S783.x;
    float3  _S787 = make_float3 (- _S785 * (F32_cos((_S786))), _S785 * (F32_sin((_S786))), (F32_cos((_S784))));
    float _S788 = environmentPdf_0(_S787);
    bool _S789 = (fcptWorldReadsPath());
    float3  _S790;
    if(_S789)
    {
        float3  _S791 = skyColor_0(ray_0->unit_direction, _S787, surface_3, wavelength_4, eta_3, is_inside_4, _S788, lobe_state_0, context_2->depth + 1U);
        _S790 = _S791;
    }
    else
    {
        BSDFMaterial _S792 = pathMaterial(surface_3->material, wavelength_4);
        float3  _S793 = skyBSDF(ray_0->unit_direction, _S787, *surface_3, _S792, eta_3, is_inside_4, _S788, lobe_state_0);
        _S790 = _S793;
    }
    bool _S794 = !(_S788 > 0.0f);
    bool _S795;
    if(_S794)
    {
        _S795 = true;
    }
    else
    {
        _S795 = all_1(_S790 == make_float3 (0.0f));
    }
    if(_S795)
    {
        float3  _S796 = make_float3 (0.0f);
        return SkySample_x24init_0(_S787, _S796, _S796, _S778.state);
    }
    float3  _S797 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S787, context_2, _S778.state);
    return SkySample_x24init_0(_S787, _S797, _S790 * _S797, _S778.state);
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
    SampleBSDF _S798 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S799 = _S798.throughput * make_float3 (_S798.pdf);
    float _S800 = light_1->density;
    float _S801 = 1.0f + _S798.pdf * _S798.pdf / (light_1->density * light_1->density);
    bool _S802;
    if(competing_0)
    {
        _S802 = _S800 > 0.0f;
    }
    else
    {
        _S802 = false;
    }
    float _S803 = _slang_select(_S802, _S801,1.0f);
    return _S799 / make_float3 (_S803) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_9)
{
    TreeSample _S804;
    (&_S804)->dir = dir_6;
    (&_S804)->radiance = radiance_1;
    (&_S804)->density = density_0;
    (&_S804)->random_state = random_state_9;
    return _S804;
}

__device__ uint pickChild(LightNode first_2, LightNode second_1, float3  p_12, float3  normal_4, float * pick_0, float * probability_3)
{
    float _S805 = importance(first_2, p_12, normal_4);
    float _S806 = importance(second_1, p_12, normal_4);
    float2  _S807 = make_float2 (_S805, _S806);
    bool _S808 = _S805 == 0.0f;
    bool _S809;
    if(_S808)
    {
        _S809 = _S806 == 0.0f;
    }
    else
    {
        _S809 = false;
    }
    if(_S809)
    {
        return 2U;
    }
    float _S810 = _S805 + _S806;
    bool _S811 = _S806 > 0.0f;
    if(_S811)
    {
        _S809 = (*pick_0 * _S810) >= _S805;
    }
    else
    {
        _S809 = false;
    }
    uint _S812 = uint(_S809);
    float _S813 = (F32_min(((*pick_0 * _S810 - float(_S812) * _S805) / _slang_vector_get_element(_S807, _S812)), (0.99999994039535522f)));
    *pick_0 = _S813;
    float _S814 = *probability_3 * (_slang_vector_get_element(_S807, _S812) / _S810);
    *probability_3 = _S814;
    return _S812;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S815 = center_1 - p_13;
    float _S816 = radius_1 * radius_1 / dot_0(_S815, _S815);
    float _S817 = u1_0 * _S816 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S816), (0.0f)))))));
    float _S818 = 2.0f * u1_0;
    bool _S819 = _S816 >= 1.0f;
    float _S820 = _slang_select(_S819, _S818,_S817);
    float _S821 = (F32_sqrt(((F32_max((_S820 * (2.0f - _S820)), (0.0f))))));
    float _S822 = 6.28318548202514648f * u2_0;
    float3  _S823 = make_float3 (_S821 * (F32_cos((_S822))), 1.0f - _S820, _S821 * (F32_sin((_S822))));
    float3  _S824 = ((((_S815)) * make_float3(rnorm3df(((_S815)).x, ((_S815)).y, ((_S815)).z))));
    float3  _S825 = tangentToWorld(_S823, _S824);
    return _S825;
}

__device__ float3  pointLightRadiance(float3  color_3, float intensity_0, float radius_2)
{
    return color_3 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S826 = center_2 - ray_1->origin;
    float _S827 = dot_0(_S826, ray_1->unit_direction);
    float _S828 = dot_0(_S826, _S826) - _S827 * _S827;
    float _S829 = radius_3 * radius_3;
    bool _S830 = _S828 > _S829;
    if(_S830)
    {
        return 4.294967296e+09f;
    }
    float _S831 = (F32_sqrt((_S829 - _S828)));
    float _S832 = _S827 - _S831;
    float _S833 = _S827 + _S831;
    bool _S834 = _S832 > 0.0000152587890625f;
    bool _S835;
    if(_S834)
    {
        _S835 = _S832 < max_len_0;
    }
    else
    {
        _S835 = false;
    }
    if(_S835)
    {
        return _S832;
    }
    bool _S836 = _S833 > 0.0000152587890625f;
    if(_S836)
    {
        _S835 = _S833 < max_len_0;
    }
    else
    {
        _S835 = false;
    }
    if(_S835)
    {
        return _S833;
    }
    return 4.294967296e+09f;
}

static __device__ float3  mul_0(float3  left_1, Matrix<float, 3, 3>  right_1)
{
    float3  result_6;
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
        int i_16 = int(0);
        float sum_0 = 0.0f;
        for(;;)
        {
            if(i_16 < int(3))
            {
            }
            else
            {
                break;
            }
            float sum_1 = sum_0 + _slang_vector_get_element(left_1, i_16) * _slang_vector_get_element(right_1.rows[i_16], j_1);
            i_16 = i_16 + int(1);
            sum_0 = sum_1;
        }
        *_slang_vector_get_element_ptr(&result_6, j_1) = sum_0;
        j_1 = j_1 + int(1);
    }
    return result_6;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S837 = draw(init_random_state_1, 4U);
    Random _S838 = draw(init_random_state_1, 5U);
    Random _S839 = draw(init_random_state_1, 2147483653U);
    float3  _S840 = make_float3 (0.0f);
    TreeSample _S841 = TreeSample_x24init_0(_S840, _S840, 0.0f, _S839.state);
    TreeSample sample_0 = _S841;
    float3  _S842 = _slang_select(sided_0, _S840,smooth_n_2);
    float3  _S843 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S837.value;
    float probability_4 = 1.0f;
    uint n_9 = 0U;
    for(;;)
    {
        uint4  _S844 = (fcptLightNode((n_9)));
        if((_S844.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S845 = (fcptLightSecond((n_9)));
        uint _S846 = n_9 + 1U;
        LightNode _S847 = (fcptLightBounds((_S846)));
        LightNode _S848 = (fcptLightBounds((_S845)));
        uint _S849 = pickChild(_S847, _S848, origin_4, _S842, &pick_1, &probability_4);
        bool _S850 = _S849 > 1U;
        if(_S850)
        {
            return sample_0;
        }
        bool _S851 = _S849 == 1U;
        uint _S852 = _slang_select(_S851, _S845,_S846);
        n_9 = _S852;
    }
    bool _S853 = n_9 == 0U;
    bool _S854;
    if(_S853)
    {
        LightNode _S855 = (fcptLightBounds((0U)));
        float _S856 = importance(_S855, origin_4, _S842);
        _S854 = !(_S856 > 0.0f);
    }
    else
    {
        _S854 = false;
    }
    if(_S854)
    {
        return sample_0;
    }
    uint4  _S857 = (fcptLightNode((n_9)));
    FKHit _S858 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S859 = (_S857.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S859)
    {
        FKLight _S860 = (fcptLight((_S857.y)));
        if(sided_0)
        {
            float _S861 = sign_0(dot_0(geometry_n_1, _S860.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S861);
            float3  _S862 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S862;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S843;
            lift_n_0 = smooth_n_2;
        }
        bool _S863 = (_S860.variance) == 0.0f;
        if(_S863)
        {
            float3  _S864 = _S860.position - emitter_point_0;
            float3  _S865 = ((((_S864)) * make_float3(rnorm3df(((_S864)).x, ((_S864)).y, ((_S864)).z))));
            (&sample_0)->dir = _S865;
            float3  _S866 = _S860.color * make_float3 (_S860.intensity) / make_float3 (dot_0(_S864, _S864) * probability_4);
            (&sample_0)->radiance = _S866;
            shadow_1 = _S864;
        }
        else
        {
            float3  _S867 = sampleSphere(_S860.position, _S860.variance, emitter_point_0, _S838.value, _S839.value);
            (&sample_0)->dir = _S867;
            float _S868 = sphereDensity(_S860.position, _S860.variance, emitter_point_0);
            float _S869 = probability_4 * _S868;
            (&sample_0)->density = _S869;
            float3  _S870 = pointLightRadiance(_S860.color, _S860.intensity, _S860.variance);
            float3  _S871 = _S870 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S871;
            FKRay _S872 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S873 = raySphere_0(_S860.position, _S860.variance, &_S872, 4.294967296e+09f);
            float3  _S874 = (&sample_0)->dir * make_float3 (_S873);
            shadow_1 = _S874;
        }
        emitter_0 = _S858;
        emitter_point_0 = _S840;
    }
    else
    {
        uint _S875 = _S857.y;
        uint _S876 = (fcptTriangleOffset((_S875)));
        uint _S877 = _S876 + _S857.z;
        Matrix<float, 3, 3>  _S878 = (fcptWorldTriangle((_S875), (_S877)));
        float _S879 = (F32_sqrt((_S838.value)));
        float2  _S880 = make_float2 (_S879 * (1.0f - _S839.value), _S879 * _S839.value);
        float3  _S881 = mul_0(make_float3 (1.0f - _S879, _S880.x, _S880.y), _S878);
        if(sided_0)
        {
            float _S882 = sign_0(dot_0(geometry_n_1, _S881 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S882);
            float3  _S883 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S883;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S884 = !((dot_0(smooth_n_2, _S881 - origin_4)) > 0.0f);
            if(_S884)
            {
                return sample_0;
            }
            emitter_point_0 = _S843;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S880, _S875, _S877, 0U, 0.0f);
        float3  _S885 = _S881 - emitter_point_0;
        float3  _S886 = ((((_S885)) * make_float3(rnorm3df(((_S885)).x, ((_S885)).y, ((_S885)).z))));
        (&sample_0)->dir = _S886;
        float _S887 = solidAngle(probability_4, cross_0(_S878.rows[int(1)] - _S878.rows[int(0)], _S878.rows[int(2)] - _S878.rows[int(0)]), _S885);
        (&sample_0)->density = _S887;
        bool _S888 = (fcptShadowFirst());
        bool _S889 = !_S888;
        if(_S889)
        {
            FKSurface _S890 = (fcptLightSurfaceAt((emitter_1), (_S881), (_S839.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S881 - origin_4))));
            (&sample_0)->random_state = _S890.random_state;
            float3  _S891 = _slang_select(_S890.skip, _S840,_S890.material.emissive);
            float3  _S892 = _S891 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S892;
        }
        shadow_1 = _S885;
        emitter_0 = emitter_1;
        emitter_point_0 = _S881;
    }
    FKHit _S893 = emitter_0;
    float3  _S894 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S839.state, &_S893);
    bool _S895 = (fcptShadowFirst());
    if(_S895)
    {
        _S854 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S854 = false;
    }
    if(_S854)
    {
        _S854 = !all_1(_S894 == _S840);
    }
    else
    {
        _S854 = false;
    }
    if(_S854)
    {
        FKSurface _S896 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S839.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S896.random_state;
        float3  _S897 = _slang_select(_S896.skip, _S840,_S896.material.emissive);
        float3  _S898 = _S897 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S898;
    }
    float3  _S899 = (&sample_0)->radiance * _S894;
    bool _S900 = all_1(_S894 == _S840);
    float3  _S901 = _slang_select(_S900, _S840,_S899);
    (&sample_0)->radiance = _S901;
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

__device__ float powerHeuristic(float a_8, float b_2)
{
    float _S902 = 1.0f / (1.0f + b_2 / a_8 * (b_2 / a_8));
    bool _S903 = b_2 > 0.0f;
    float _S904 = _slang_select(_S903, _S902,1.0f);
    return _S904;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S905 = vertex_0->none;
    if(_S905)
    {
        return 1.0f;
    }
    uint _S906 = (fcptLightSlot((*hit_1)));
    float _S907 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S906, light_point_1);
    float _S908 = powerHeuristic(vertex_0->pdf, _S907);
    return _S908;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_1, uint lobe_0)
{
    uint2  _S909 = (fcptEnvironmentMapSize());
    bool _S910 = (_S909.x) > 1U;
    bool _S911;
    if(_S910)
    {
        uint2  _S912 = (fcptEnvironmentMapSize());
        _S911 = (_S912.y) > 1U;
    }
    else
    {
        _S911 = false;
    }
    if(_S911)
    {
        float3  _S913 = (fcptEnvMapSample((dir_7), (depth_1), (lobe_0)));
        return _S913;
    }
    float3  _S914 = (fcptAmbient());
    return _S914;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S915 = (fcptEnvironmentCdfSize());
    bool _S916 = (_S915.x) > 1U;
    bool _S917;
    if(_S916)
    {
        uint2  _S918 = (fcptEnvironmentCdfSize());
        _S917 = (_S918.y) > 1U;
    }
    else
    {
        _S917 = false;
    }
    bool _S919 = !_S917;
    if(_S919)
    {
        return false;
    }
    uint2  _S920 = (fcptEnvironmentMapSize());
    bool _S921 = (_S920.x) > 1U;
    if(_S921)
    {
        uint2  _S922 = (fcptEnvironmentMapSize());
        _S917 = (_S922.y) > 1U;
    }
    else
    {
        _S917 = false;
    }
    return _S917;
}

static __device__ float escapeWeight_0(float pdf_2, float3  dir_8)
{
    bool _S923 = pdf_2 <= 0.0f;
    bool _S924;
    if(_S923)
    {
        _S924 = true;
    }
    else
    {
        bool _S925 = environmentMapped_0();
        _S924 = !_S925;
    }
    if(_S924)
    {
        return 1.0f;
    }
    float _S926 = environmentPdf_0(dir_8);
    return pdf_2 / (pdf_2 + _S926);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S927 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S928 = make_int2 ((int)_S927.x, (int)_S927.y);
    uint _S929 = previousSeed_0(_S928);
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
            uint _S930 = previousSeed_0(_S928 + make_int2 (x_16, y_5));
            bool _S931 = _S930 == _S929;
            uint _S932 = _slang_select(_S931, 1U,0U);
            uint count_3 = count_2 + _S932;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S933 = float(count_2 - 1U) / 288.0f;
    bool _S934 = _S929 != 0U;
    float _S935 = _slang_select(_S934, _S933,0.0f);
    fcptStoreDuplication((_S928), (make_uint4 ((F32_asuint((_S935))), 0U, 0U, 0U)));
    return;
}

static __device__ float3  abs_0(float3  x_18)
{
    float3  result_7;
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
        *_slang_vector_get_element_ptr(&result_7, i_17) = (F32_abs((_slang_vector_get_element(x_18, i_17))));
        i_17 = i_17 + int(1);
    }
    return result_7;
}

__device__ float resamplingTarget(float3  f_6)
{
    float _S936 = rgb_to_greyscale(abs_0(f_6));
    return _S936;
}

static __device__ float4  asfloat_0(uint4  x_19)
{
    float4  result_8;
    int i_18 = int(0);
    for(;;)
    {
        if(i_18 < int(4))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_8, i_18) = (U32_asfloat((_slang_vector_get_element(x_19, i_18))));
        i_18 = i_18 + int(1);
    }
    return result_8;
}

__device__ void offer(Selection * sel_2, Reservoir candidate_0, float3  weight_0)
{
    float _S937 = resamplingTarget(weight_0);
    bool _S938 = _S937 > 0.0f;
    bool _S939;
    if(_S938)
    {
        _S939 = _S937 < 3.00000000549775576e+38f;
    }
    else
    {
        _S939 = false;
    }
    bool _S940 = !_S939;
    if(_S940)
    {
        return;
    }
    bool _S941 = sel_2->sums;
    if(_S941)
    {
        float3  _S942 = sel_2->color + weight_0;
        sel_2->color = _S942;
        return;
    }
    float _S943 = sel_2->w_sum + _S937;
    sel_2->w_sum = _S943;
    float3  _S944 = sel_2->color + weight_0;
    sel_2->color = _S944;
    Random _S945 = pcg(sel_2->random_state);
    sel_2->random_state = _S945.state;
    bool _S946 = (_S945.value * sel_2->w_sum) <= _S937;
    if(_S946)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S947 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S947;
    float _S948 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S948;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S949 = resamplingTarget((&r_4)->f);
    float _S950 = sel_4.w_sum / _S949;
    bool _S951 = _S949 > 0.0f;
    float _S952 = _slang_select(_S951, _S950,0.0f);
    (&r_4)->w = _S952;
    (&r_4)->c = c_1;
    return r_4;
}

static __device__ uint2  asuint_0(float2  x_20)
{
    uint2  result_9;
    int i_19 = int(0);
    for(;;)
    {
        if(i_19 < int(2))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_9, i_19) = (F32_asuint((_slang_vector_get_element(x_20, i_19))));
        i_19 = i_19 + int(1);
    }
    return result_9;
}

static __device__ void restir_spatial_0(uint3  global_invocation_id_2)
{
    uint2  _S953 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S954 = make_int2 ((int)_S953.x, (int)_S953.y);
    float3  _S955 = make_float3 (0.0f);
    FKHit _S956 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S957 = Domain_x24init_0(_S955, _S955, &_S956, 0.0f, 0.0f);
    Domain dom_4 = _S957;
    bool _S958 = (fcptCurrentDomain((_S954), (&dom_4)));
    bool _S959 = !_S958;
    if(_S959)
    {
        Reservoir _S960 = (Reservoir{});
        fcptStoreReservoirPrevious((_S954), (_S960), ((&dom_4)->hit));
        return;
    }
    Reservoir _S961 = (fcptLoadReservoirTemporal((_S954)));
    uint t_15 = 0U;
    float count_4 = 0.0f;
    float c_sum_0 = _S961.c;
    for(;;)
    {
        uint _S962 = (fcptRestirNeighbours());
        if(t_15 < _S962)
        {
        }
        else
        {
            break;
        }
        int2  _S963 = partner_0(_S954, t_15);
        Domain neighbor_0 = _S957;
        bool _S964 = (fcptCurrentDomain((_S963), (&neighbor_0)));
        if(_S964)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S965 = (fcptReservoirTemporal((_S963), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S965.w)));
            count_4 = count_5;
            c_sum_0 = c_sum_1;
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    float _S966 = _S961.c / (F32_max((count_4), (1.0f)));
    float _S967 = resamplingTarget(_S961.f);
    bool _S968 = count_4 == 0.0f;
    float _S969 = _slang_select(_S968, 1.0f,0.0f);
    Selection _S970 = (Selection{});
    Selection sel_5 = _S970;
    uint _S971 = (fcptFrame());
    uint _S972 = hash(_S971);
    uint _S973 = global_invocation_id_2.x;
    uint2  _S974 = (fcptRenderSize());
    uint _S975 = stream(_S972, _S973 + _S974.x * global_invocation_id_2.y);
    uint _S976 = stream(_S975, 195U);
    (&sel_5)->random_state = _S976;
    t_15 = 0U;
    float canonical_mis_0 = _S969;
    for(;;)
    {
        uint _S977 = (fcptRestirNeighbours());
        if(t_15 < _S977)
        {
        }
        else
        {
            break;
        }
        int2  _S978 = partner_0(_S954, t_15);
        Domain neighbor_dom_0 = _S957;
        bool _S979 = (fcptCurrentDomain((_S978), (&neighbor_dom_0)));
        if(_S979)
        {
            Reservoir _S980 = (fcptLoadReservoirTemporal((_S978)));
            uint4  _S981 = (fcptShiftData((_S978), (t_15)));
            float4  _S982 = asfloat_0(_S981);
            uint4  _S983 = (fcptShiftData((_S954), (t_15)));
            float4  _S984 = asfloat_0(_S983);
            float _S985 = (_S980.c + _S966) / c_sum_0;
            bool _S986 = _S967 > 0.0f;
            float canonical_mis_1;
            if(_S986)
            {
                float _S987 = _S985 * _S966 * _S967;
                float _S988 = _S966 * _S967;
                float _S989 = resamplingTarget(float3 {_S984.x, _S984.y, _S984.z});
                float canonical_mis_2 = canonical_mis_0 + _S987 / (_S988 + _S980.c * _S989);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S990 = float3 {_S982.x, _S982.y, _S982.z};
            Shift _S991 = Shift_x24init_0(_S990, _S982.w);
            float _S992 = _S985 * _S980.c;
            float _S993 = resamplingTarget(_S980.f);
            float _S994 = _S992 * _S993;
            float _S995 = resamplingTarget(_S980.f);
            float _S996 = _S980.c * _S995;
            float _S997 = resamplingTarget(_S990);
            offerShifted(&sel_5, _S980, _S991, _S994 / (_S996 + _S966 * _S997));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_17 = t_15 + 1U;
        t_15 = t_17;
    }
    offerShifted(&sel_5, _S961, Shift_x24init_0(_S961.f, 1.0f), canonical_mis_0);
    Reservoir _S998 = finalize(sel_5, c_sum_0);
    fcptStoreReservoirPrevious((_S954), (_S998), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S954), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S954), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
    return;
}

static __device__ uint3  asuint_1(float3  x_21)
{
    uint3  result_10;
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
        *_slang_vector_get_element_ptr(&result_10, i_20) = (F32_asuint((_slang_vector_get_element(x_21, i_20))));
        i_20 = i_20 + int(1);
    }
    return result_10;
}

static __device__ void restir_shift_0(uint3  workgroup_id_1, uint local_invocation_index_4)
{
    uint _S999 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S1000 = _S999 != 4294967295U;
    if(_S1000)
    {
        uint2  _S1001 = make_uint2 (_S999, _S999 >> 14U) & make_uint2 (16383U);
        int2  _S1002 = make_int2 ((int)_S1001.x, (int)_S1001.y);
        ShiftJob _S1003 = (ShiftJob{});
        ShiftJob shift_job_0 = _S1003;
        Shift _S1004 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S1005 = _S999 >> 28U;
        bool _S1006 = spatialJob_0(_S1002, _S1005, &shift_job_0, true);
        Shift shifted_1;
        if(_S1006)
        {
            Domain _S1007 = (&shift_job_0)->dom;
            Reservoir _S1008 = (&shift_job_0)->r;
            Shift _S1009 = shift_0(&_S1007, &_S1008);
            shifted_1 = _S1009;
        }
        else
        {
            shifted_1 = _S1004;
        }
        fcptStoreShiftData((_S1002), (_S1005), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S1010 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S1011 = make_int2 ((int)_S1010.x, (int)_S1010.y);
    FixedArray<uint, 3>  _S1012;
    spatialBins_0(_S1011, &_S1012);
    FixedArray<uint, 3>  _S1013 = _S1012;
    uint t_18 = 0U;
    for(;;)
    {
        if(t_18 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S1014 = (_S1013[t_18]) == 40U;
        if(_S1014)
        {
            fcptStoreShiftData((_S1011), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S1015 = _S1013;
    queueShifts_0(_S1011, &_S1015, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S1016 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S1017 = make_int2 ((int)_S1016.x, (int)_S1016.y);
    FixedArray<uint, 3>  _S1018;
    spatialBins_0(_S1017, &_S1018);
    FixedArray<uint, 3>  _S1019 = _S1018;
    countShifts_0(&_S1019, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S1020 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S1021 = _S1020 != 4294967295U;
    if(_S1021)
    {
        uint2  _S1022 = make_uint2 (_S1020, _S1020 >> 14U) & make_uint2 (16383U);
        int2  _S1023 = make_int2 ((int)_S1022.x, (int)_S1022.y);
        int2  _S1024 = (fcptLoadTemporalNeighbor((_S1023)));
        uint _S1025 = _S1020 >> 28U;
        Shift _S1026 = temporalShiftAt_0(_S1023, _S1024, _S1025);
        fcptStoreShiftData((_S1023), (_S1025), (make_uint4 (asuint_1(_S1026.f).x, asuint_1(_S1026.f).y, asuint_1(_S1026.f).z, (F32_asuint((_S1026.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S1027 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S1028 = make_int2 ((int)_S1027.x, (int)_S1027.y);
    FixedArray<uint, 3>  _S1029;
    temporalBins_0(_S1028, &_S1029);
    FixedArray<uint, 3>  _S1030 = _S1029;
    uint t_20 = 0U;
    for(;;)
    {
        if(t_20 < 2U)
        {
        }
        else
        {
            break;
        }
        bool _S1031 = (_S1030[t_20]) == 40U;
        if(_S1031)
        {
            fcptStoreShiftData((_S1028), (t_20), (make_uint4 (0U)));
        }
        uint t_21 = t_20 + 1U;
        t_20 = t_21;
    }
    FixedArray<uint, 3>  _S1032 = _S1030;
    queueShifts_0(_S1028, &_S1032, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S1033 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S1034 = make_int2 ((int)_S1033.x, (int)_S1033.y);
    bool _S1035 = (fcptSceneUnchanged());
    bool _S1036 = !_S1035;
    bool _S1037;
    if(_S1036)
    {
        uint2  _S1038 = (fcptRenderSize());
        int2  _S1039 = make_int2 ((int)_S1038.x, (int)_S1038.y);
        _S1037 = all_0(_S1034 < _S1039);
    }
    else
    {
        _S1037 = false;
    }
    if(_S1037)
    {
        Reservoir _S1040 = (fcptLoadReservoirInitial((_S1034)));
        int2  _S1041 = sampleNeighbor_0(_S1034, _S1040.seed);
        fcptStoreTemporalNeighbor((_S1034), (_S1041));
    }
    FixedArray<uint, 3>  _S1042;
    temporalBins_0(_S1034, &_S1042);
    FixedArray<uint, 3>  _S1043 = _S1042;
    countShifts_0(&_S1043, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_9, float b_3, float t_22)
{
    return a_9 + (b_3 - a_9) * t_22;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S1044 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S1045 = make_int2 ((int)_S1044.x, (int)_S1044.y);
    float3  _S1046 = make_float3 (0.0f);
    FKHit _S1047 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S1048 = Domain_x24init_0(_S1046, _S1046, &_S1047, 0.0f, 0.0f);
    Domain dom_5 = _S1048;
    bool _S1049 = (fcptCurrentDomain((_S1045), (&dom_5)));
    bool _S1050 = !_S1049;
    if(_S1050)
    {
        Reservoir _S1051 = (Reservoir{});
        fcptStoreReservoirTemporal((_S1045), (_S1051), ((&dom_5)->hit));
        return;
    }
    Reservoir _S1052 = (fcptLoadReservoirInitial((_S1045)));
    bool _S1053 = (fcptTemporalQueued());
    bool _S1054 = (fcptSceneUnchanged());
    bool _S1055;
    if(_S1054)
    {
        _S1055 = true;
    }
    else
    {
        _S1055 = !_S1053;
    }
    int2  _S1056;
    if(_S1055)
    {
        int2  _S1057 = sampleNeighbor_0(_S1045, _S1052.seed);
        _S1056 = _S1057;
    }
    else
    {
        int2  _S1058 = (fcptLoadTemporalNeighbor((_S1045)));
        _S1056 = _S1058;
    }
    bool _S1059 = (_S1056.x) >= int(0);
    Reservoir r_5;
    if(_S1059)
    {
        Reservoir _S1060 = (fcptLoadReservoirPrevious((_S1056)));
        uint4  _S1061 = (fcptDuplication((_S1056)));
        float _S1062 = (U32_asfloat((_S1061.x)));
        uint _S1063 = (fcptRestirDecorrelation());
        bool _S1064 = _S1063 == 1U;
        float _S1065 = _slang_select(_S1064, _S1062,0.0f);
        float _S1066 = interpolate_0(20.0f, 1.0f, (F32_pow((_S1065), (0.10000000149011612f))));
        float _S1067 = (F32_min((_S1060.c), (_S1066)));
        bool _S1068 = (fcptSceneUnchanged());
        float4  _S1069 = make_float4 (_S1060.f.x, _S1060.f.y, _S1060.f.z, 1.0f);
        bool _S1070 = !_S1068;
        if(_S1070)
        {
            _S1055 = _S1053;
        }
        else
        {
            _S1055 = false;
        }
        float4  to_current_0;
        if(_S1055)
        {
            uint4  _S1071 = (fcptShiftData((_S1045), (0U)));
            float4  _S1072 = asfloat_0(_S1071);
            to_current_0 = _S1072;
        }
        else
        {
            if(_S1070)
            {
                Shift _S1073 = temporalShiftAt_0(_S1045, _S1056, 0U);
                float4  _S1074 = make_float4 (_S1073.f.x, _S1073.f.y, _S1073.f.z, _S1073.jac);
                to_current_0 = _S1074;
            }
            else
            {
                to_current_0 = _S1069;
            }
        }
        Domain own_1 = _S1048;
        if(_S1068)
        {
            _S1055 = true;
        }
        else
        {
            bool _S1075 = (fcptPreviousScenes());
            bool _S1076 = !_S1075;
            if(_S1076)
            {
                _S1055 = (_S1052.w) > 0.0f;
            }
            else
            {
                _S1055 = false;
            }
            if(_S1055)
            {
                bool _S1077 = (fcptStoredDomainInitial((_S1045), (_S1052.seed), (&own_1)));
                _S1055 = _S1077;
            }
            else
            {
                _S1055 = false;
            }
            if(_S1055)
            {
                Domain _S1078 = (fcptPreviousDomain((_S1056), (_S1052.seed)));
                Domain _S1079 = _S1078;
                Domain _S1080 = own_1;
                bool _S1081 = sameDomain_0(&_S1079, &_S1080);
                _S1055 = _S1081;
            }
            else
            {
                _S1055 = false;
            }
        }
        float4  _S1082 = make_float4 (_S1052.f.x, _S1052.f.y, _S1052.f.z, 1.0f);
        bool _S1083 = !_S1055;
        if(_S1083)
        {
            _S1055 = _S1053;
        }
        else
        {
            _S1055 = false;
        }
        float4  to_previous_0;
        if(_S1055)
        {
            uint4  _S1084 = (fcptShiftData((_S1045), (1U)));
            float4  _S1085 = asfloat_0(_S1084);
            to_previous_0 = _S1085;
        }
        else
        {
            if(_S1083)
            {
                Shift _S1086 = temporalShiftAt_0(_S1045, _S1056, 1U);
                float4  _S1087 = make_float4 (_S1086.f.x, _S1086.f.y, _S1086.f.z, _S1086.jac);
                to_previous_0 = _S1087;
            }
            else
            {
                to_previous_0 = _S1082;
            }
        }
        float _S1088 = resamplingTarget(_S1052.f);
        float _S1089 = resamplingTarget(_S1060.f);
        Selection _S1090 = (Selection{});
        Selection sel_6 = _S1090;
        uint _S1091 = (fcptFrame());
        uint _S1092 = hash(_S1091);
        uint _S1093 = global_invocation_id_7.x;
        uint2  _S1094 = (fcptRenderSize());
        uint _S1095 = stream(_S1092, _S1093 + _S1094.x * global_invocation_id_7.y);
        uint _S1096 = stream(_S1095, 194U);
        (&sel_6)->random_state = _S1096;
        float _S1097 = _S1052.c * _S1088;
        float4  _S1098 = to_previous_0;
        float _S1099 = resamplingTarget(float3 {_S1098.x, _S1098.y, _S1098.z});
        float _S1100 = _S1097 / (_S1097 + _S1067 * _S1099);
        float _S1101 = _S1067 * _S1089;
        float4  _S1102 = to_current_0;
        float3  _S1103 = float3 {_S1102.x, _S1102.y, _S1102.z};
        float _S1104 = resamplingTarget(_S1103);
        float _S1105 = _S1101 / (_S1101 + _S1052.c * _S1104);
        float2  _S1106 = make_float2 (_S1100, _S1105);
        offerShifted(&sel_6, _S1052, Shift_x24init_0(_S1052.f, 1.0f), _S1100);
        offerShifted(&sel_6, _S1060, Shift_x24init_0(_S1103, to_current_0.w), _S1105);
        Reservoir _S1107 = finalize(sel_6, _S1052.c + _S1067);
        r_5 = _S1107;
    }
    else
    {
        r_5 = _S1052;
    }
    fcptStoreReservoirTemporal((_S1045), (r_5), ((&dom_5)->hit));
    return;
}

__device__ uint noiseOrigin(uint2  p_14, uint k_1)
{
    uint _S1108 = ((p_14.x) >> 11U) | (((p_14.y) >> 11U) << 4U);
    uint2  _S1109 = noiseOffset(8192U + (k_1 >> 10U) + (_S1108 << 20U));
    uint2  _S1110 = (p_14 + _S1109) & make_uint2 (2047U);
    return ((_S1110.x) | ((_S1110.y) << 11U)) | ((k_1 & 1023U) << 22U);
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1111 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1111 << offset_1))) | ((newbits_0 & _S1111) << offset_1);
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S1112 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S1113 = make_int2 ((int)_S1112.x, (int)_S1112.y);
    float3  _S1114 = make_float3 (0.0f);
    float2  _S1115 = make_float2 (0.0f);
    FKHit _S1116 = Hit_x24init_0(_S1115, 0U, 0U, 0U, 0.0f);
    Domain _S1117 = Domain_x24init_0(_S1114, _S1114, &_S1116, 0.0f, 0.0f);
    Domain dom_6 = _S1117;
    bool _S1118 = (fcptCurrentDomain((_S1113), (&dom_6)));
    bool _S1119 = !_S1118;
    if(_S1119)
    {
        Reservoir _S1120 = (Reservoir{});
        fcptStoreReservoirInitial((_S1113), (_S1120), ((&dom_6)->hit));
        return;
    }
    uint _S1121 = (fcptFrame());
    uint _S1122 = hash(_S1121);
    uint _S1123 = global_invocation_id_8.x;
    uint2  _S1124 = (fcptRenderSize());
    uint _S1125 = global_invocation_id_8.y;
    uint _S1126 = stream(_S1122, _S1123 + _S1124.x * _S1125);
    uint2  _S1127 = (fcptRenderSize());
    uint _S1128 = stream(_S1123 + _S1127.x * _S1125, 512U);
    Selection _S1129 = (Selection{});
    Selection initial_0 = _S1129;
    uint _S1130 = stream(_S1126, 193U);
    (&initial_0)->random_state = _S1130;
    bool _S1131 = (fcptRestirUsed());
    bool _S1132 = !_S1131;
    (&initial_0)->sums = _S1132;
    uint _S1133 = stream(_S1126, 0U);
    (&(&initial_0)->r)->seed = _S1133;
    FKHit _S1134 = Hit_x24init_0(_S1115, 4294967295U, 0U, 0U, 0.0f);
    uint _S1135 = (fcptSamples());
    float _S1136 = 1.0f / float(_S1135);
    FKHit hit_2 = _S1134;
    uint i_21 = 0U;
    float3  seen_0 = _S1114;
    for(;;)
    {
        uint _S1137 = (fcptSamples());
        if(i_21 < _S1137)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1138 = (Reservoir{});
        Reservoir r_6 = _S1138;
        uint _S1139 = (fcptFrame());
        uint _S1140 = (fcptSamples());
        uint _S1141 = _S1139 * _S1140 + i_21;
        uint _S1142 = noiseOrigin(_S1112, _S1141);
        (&r_6)->seed = _S1142;
        uint _S1143 = insertBits_0(0U, 1U, 24U, 1U);
        uint _S1144 = insertBits_0(_S1143, (_S1128 + _S1141 * 2654435769U) >> 25U, 25U, 7U);
        (&r_6)->path = _S1144;
        Domain path_0 = _S1117;
        bool _S1145 = (fcptStoredDomainInitial((_S1113), ((&r_6)->seed), (&path_0)));
        bool _S1146 = !_S1145;
        if(_S1146)
        {
            float3  _S1147 = (fcptMissed((_S1113), (path_0), (_S1136)));
            float3  seen_1 = seen_0 + _S1147;
            seen_0 = seen_1;
            uint i_22 = i_21 + 1U;
            i_21 = i_22;
            continue;
        }
        Domain _S1148 = path_0;
        Reservoir _S1149 = r_6;
        Shift _S1150 = passWalk_0(&_S1148, &_S1149, false, _S1136, &initial_0);
        bool _S1151 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1151)
        {
            FKHit _S1152 = (&path_0)->hit;
            hit_3 = _S1152;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_22 = i_21 + 1U;
        i_21 = i_22;
    }
    uint _S1153 = (fcptSamples());
    float3  seen_2 = seen_0 + (&initial_0)->glow / make_float3 (float(_S1153));
    if((&initial_0)->sums)
    {
        seen_0 = seen_2 + (&initial_0)->color;
    }
    else
    {
        seen_0 = seen_2;
    }
    fcptAddColor((_S1113), (make_float4 (seen_0.x, seen_0.y, seen_0.z, 1.0f)));
    Reservoir _S1154 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S1113), (_S1154), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_3, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1155;
    (&_S1155)->none = none_0;
    (&_S1155)->pdf = pdf_3;
    (&_S1155)->origin = origin_5;
    (&_S1155)->smooth_n = smooth_n_3;
    (&_S1155)->start = start_6;
    return _S1155;
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
    Vertex _S1156;
    (&_S1156)->rough = rough_0;
    (&_S1156)->lobe = lobe_1;
    (&_S1156)->pdf = pdf_4;
    (&_S1156)->cos = cos_0;
    (&_S1156)->inside = inside_0;
    return _S1156;
}

__device__ uint noiseAddress(uint origin_6, uint bounce_0)
{
    uint2  _S1157 = make_uint2 (origin_6 & 2047U, (origin_6 >> 11U) & 2047U);
    uint2  _S1158 = noiseOffset(64U + bounce_0 * 17U);
    uint2  _S1159 = (_S1157 + _S1158) & make_uint2 (2047U);
    return ((_S1159.x) | ((_S1159.y) << 11U)) | ((origin_6 >> 22U) << 22U);
}

__device__ float3  pathColor(float3  f_7, float3  weight_1, float wavelength_5)
{
    float3  _S1160;
    if(wavelength_5 > 0.0f)
    {
        float _S1161 = upsample(f_7, wavelength_5);
        _S1160 = weight_1 * make_float3 (_S1161);
    }
    else
    {
        _S1160 = f_7;
    }
    return _S1160;
}

static __device__ float3  exp_0(float3  x_22)
{
    float3  result_11;
    int i_23 = int(0);
    for(;;)
    {
        if(i_23 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_11, i_23) = (F32_exp((_slang_vector_get_element(x_22, i_23))));
        i_23 = i_23 + int(1);
    }
    return result_11;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_0, float distance_2, bool scatters_0)
{
    float3  _S1162 = exp_0((make_float3 (sigma_0) - extinction_0) * make_float3 (distance_2));
    float3  _S1163 = scatter_0 * _S1162 / make_float3 (sigma_0);
    float3  _S1164 = _slang_select(scatters_0, _S1163,_S1162);
    return _S1164;
}

static __device__ uint arrivalLobe_0(uint b_4, uint prev_lobe_0)
{
    bool _S1165 = b_4 > 0U;
    uint _S1166 = _slang_select(_S1165, prev_lobe_0,3U);
    return _S1166;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_2, uint lobe_2, bool surface_5, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1167;
    (&_S1167)->extinction_behind = extinction_behind_0;
    (&_S1167)->extinction_front = extinction_front_0;
    (&_S1167)->fillings = fillings_0;
    (&_S1167)->side = side_0;
    (&_S1167)->depth = depth_2;
    (&_S1167)->lobe = lobe_2;
    (&_S1167)->surface = surface_5;
    (&_S1167)->length = length_2;
    (&_S1167)->width = width_1;
    (&_S1167)->own = *own_2;
    (&_S1167)->fiber = fiber_0;
    return _S1167;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1168 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1168)
    {
        return 0.07957746833562851f;
    }
    float _S1169 = g_0 * g_0;
    return (1.0f - _S1169) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1169 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_10, float3  b_5)
{
    float3  _S1170 = a_10 / b_5;
    float3  _S1171 = make_float3 (0.0f);
    bool3  _S1172 = b_5 == _S1171;
    float3  _S1173 = _slang_select(_S1172, _S1171,_S1170);
    return _S1173;
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_8)
{
    Reservoir candidate_2 = r_7;
    uint _S1174 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1175 = insertBits_0(_S1174, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1175;
    (&candidate_2)->f = f_8;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    float3  _S1176 = throughput_0 / make_float3 (density_1);
    return clamp_1((F32_max((_S1176.x), ((F32_max((_S1176.y), (_S1176.z)))))), 0.0f, 1.0f);
}

static __device__ float3  isotropic_0(uint random_state_10)
{
    Random _S1177 = draw(random_state_10, 11U);
    Random _S1178 = draw(random_state_10, 2147483659U);
    float _S1179 = 1.0f - 2.0f * _S1177.value;
    float _S1180 = (F32_sqrt(((F32_max((1.0f - _S1179 * _S1179), (0.0f))))));
    float _S1181 = 6.28318548202514648f * _S1178.value;
    return make_float3 (_S1180 * (F32_cos((_S1181))), _S1180 * (F32_sin((_S1181))), _S1179);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_11, float * pdf_5)
{
    bool _S1182 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1182)
    {
        *pdf_5 = 0.07957746833562851f;
        float3  _S1183 = isotropic_0(random_state_11);
        return _S1183;
    }
    Random _S1184 = draw(random_state_11, 11U);
    Random _S1185 = draw(random_state_11, 2147483659U);
    float _S1186 = g_1 * g_1;
    float _S1187 = 2.0f * g_1;
    float _S1188 = (1.0f - _S1186) / (1.0f - g_1 + _S1187 * _S1184.value);
    float _S1189 = clamp_1((1.0f + _S1186 - _S1188 * _S1188) / _S1187, -1.0f, 1.0f);
    float _S1190 = (F32_sqrt(((F32_max((1.0f - _S1189 * _S1189), (0.0f))))));
    float _S1191 = 6.28318548202514648f * _S1185.value;
    float _S1192 = phaseHG_0(g_1, _S1189);
    *pdf_5 = _S1192;
    float3  _S1193 = tangentToWorld(make_float3 (_S1190 * (F32_cos((_S1191))), _S1189, _S1190 * (F32_sin((_S1191)))), dir_9);
    float3  _S1194 = ((((_S1193)) * make_float3(rnorm3df(((_S1193)).x, ((_S1193)).y, ((_S1193)).z))));
    return _S1194;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_1, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_1, float velvet_0, float3  toon_1, float dispersion_0, float coat_2, float coat_roughness_0, float coat_ior_0, float3  coat_tint_0, float3  coat_normal_0)
{
    BSDFMaterial _S1195;
    (&_S1195)->albedo = albedo_1;
    (&_S1195)->emissive = emissive_0;
    (&_S1195)->roughness = roughness_0;
    (&_S1195)->metallic = metallic_0;
    (&_S1195)->transmission = transmission_0;
    (&_S1195)->ior = ior_1;
    (&_S1195)->absorption = absorption_0;
    (&_S1195)->specular_tint = specular_tint_0;
    (&_S1195)->specular_level = specular_level_0;
    (&_S1195)->translucent = translucent_0;
    (&_S1195)->sheen = sheen_2;
    (&_S1195)->sheen_roughness = sheen_roughness_0;
    (&_S1195)->anisotropy = anisotropy_0;
    (&_S1195)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1195)->tangent = tangent_1;
    (&_S1195)->velvet = velvet_0;
    (&_S1195)->toon = toon_1;
    (&_S1195)->dispersion = dispersion_0;
    (&_S1195)->coat = coat_2;
    (&_S1195)->coat_roughness = coat_roughness_0;
    (&_S1195)->coat_ior = coat_ior_0;
    (&_S1195)->coat_tint = coat_tint_0;
    (&_S1195)->coat_normal = coat_normal_0;
    return _S1195;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1196;
    (&_S1196)->scatter = scatter_1;
    (&_S1196)->extinction = extinction_1;
    (&_S1196)->g = g_2;
    return _S1196;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_16, bool skip_0, uint random_state_12, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1197;
    (&_S1197)->smooth_n = smooth_n_4;
    (&_S1197)->geometry_n = geometry_n_2;
    (&_S1197)->geometry_offset = geometry_offset_2;
    (&_S1197)->material = *material_16;
    (&_S1197)->skip = skip_0;
    (&_S1197)->random_state = random_state_12;
    (&_S1197)->coverage = coverage_0;
    (&_S1197)->encloses = encloses_0;
    (&_S1197)->volume = *volume_0;
    (&_S1197)->fills = fills_0;
    (&_S1197)->hair = hair_0;
    return _S1197;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_1)
{
    float _S1198 = surface_6->coverage;
    bool _S1199 = u_1 < _S1198;
    if(_S1199)
    {
        return *surface_6;
    }
    float3  _S1200 = make_float3 (0.0f);
    float3  _S1201 = make_float3 (1.0f);
    BSDFMaterial _S1202 = Material_x24init_0(_S1200, _S1200, 0.0f, 0.0f, 0.0f, 0.0f, _S1200, _S1201, 1.0f, _S1200, _S1200, 0.5f, 0.0f, 0.0f, _S1200, 0.0f, _S1200, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, _S1201, _S1200);
    BSDFMaterial material_17 = _S1202;
    (&material_17)->albedo = _S1201;
    (&material_17)->emissive = (&surface_6->material)->emissive;
    (&material_17)->transmission = 1.0f;
    (&material_17)->ior = 1.0f;
    (&material_17)->absorption = (&surface_6->material)->absorption;
    FKSurface through_1 = *surface_6;
    (&through_1)->material = material_17;
    return through_1;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S1203 = transmission_1 > 0.0f;
    bool _S1204;
    if(_S1203)
    {
        _S1204 = true;
    }
    else
    {
        _S1204 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1205;
    if(_S1204)
    {
        _S1205 = 1.0f;
    }
    else
    {
        _S1205 = -1.0f;
    }
    return _S1205;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_10)
{
    return (dot_0(dir_10, n_10)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_11)
{
    float3  _S1206 = surface_7->geometry_n;
    float _S1207 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_11);
    FKSurface faced_0 = *surface_7;
    float3  _S1208 = surface_7->smooth_n * make_float3 (_S1207);
    (&faced_0)->smooth_n = _S1208;
    float3  _S1209 = _S1206 * make_float3 (_S1207);
    (&faced_0)->geometry_n = _S1209;
    return faced_0;
}

static __device__ float3  max_0(float3  x_23, float3  y_7)
{
    float3  result_12;
    int i_24 = int(0);
    for(;;)
    {
        if(i_24 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_12, i_24) = (F32_max((_slang_vector_get_element(x_23, i_24)), (_slang_vector_get_element(y_7, i_24))));
        i_24 = i_24 + int(1);
    }
    return result_12;
}

static __device__ float3  log_0(float3  x_24)
{
    float3  result_13;
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
        *_slang_vector_get_element_ptr(&result_13, i_25) = (F32_log((_slang_vector_get_element(x_24, i_25))));
        i_25 = i_25 + int(1);
    }
    return result_13;
}

__device__ float3  beerLambert(float distance_3, float3  absorption_1)
{
    float3  _S1210 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1210));
}

__device__ bool dispersive(BSDFMaterial material_18)
{
    bool _S1211 = (material_18.dispersion) > 0.0f;
    bool _S1212;
    if(_S1211)
    {
        _S1212 = (material_18.ior) != 1.0f;
    }
    else
    {
        _S1212 = false;
    }
    return _S1212;
}

__device__ static const FixedArray<float, 81>  WAVELENGTH_CDF_0 = { {
    0.0f, 0.00006510900129797f, 0.00018772999465f, 0.00045414001215249f, 0.00105610000900924f, 0.00218509999103844f, 0.00430169980973005f, 0.00824129953980446f, 0.01521500013768673f, 0.02649199962615967f, 0.04202799871563911f, 0.06183499842882156f, 0.08581099659204483f, 0.11225000023841858f, 0.1395999938249588f, 0.16642999649047852f, 0.19130000472068787f, 0.21376000344753265f, 0.23378999531269073f, 0.25200000405311584f, 0.26912999153137207f, 0.28512999415397644f, 0.3002299964427948f, 0.31536000967025757f, 0.33153998851776123f, 0.34944000840187073f, 0.36937999725341797f, 0.39127999544143677f, 0.41528999805450439f, 0.4412899911403656f, 0.46840000152587891f, 0.49524000287055969f, 0.52063000202178955f, 0.54398000240325928f, 0.56476002931594849f, 0.58348000049591064f, 0.60238999128341675f, 0.62285000085830688f, 0.64474999904632568f, 0.66809999942779541f, 0.69291001558303833f, 0.71846002340316772f, 0.74393999576568604f, 0.76951998472213745f, 0.79534000158309937f, 0.82078999280929565f, 0.8454899787902832f, 0.86935001611709595f, 0.89191997051239014f, 0.91228997707366943f, 0.92987000942230225f, 0.94483000040054321f, 0.95753002166748047f, 0.96790999174118042f, 0.97605997323989868f, 0.98237001895904541f, 0.98721998929977417f, 0.9908599853515625f, 0.99356001615524292f, 0.99550998210906982f, 0.9969099760055542f, 0.99787998199462891f, 0.99852001667022705f, 0.99895000457763672f, 0.99924999475479126f, 0.99948000907897949f, 0.99963998794555664f, 0.99975001811981201f, 0.99983000755310059f, 0.99988001585006714f, 0.99990999698638916f, 0.99993997812271118f, 0.99996000528335571f, 0.99997997283935547f, 0.99998998641967773f, 0.99998998641967773f, 0.99998998641967773f, 1.0f, 1.0f, 1.0f, 1.0f
} };
__device__ float2  sampleWavelength(float u_2)
{
    uint low_1 = 0U;
    uint high_1 = 79U;
    for(;;)
    {
        if(low_1 < high_1)
        {
        }
        else
        {
            break;
        }
        uint _S1213 = (low_1 + high_1 + 1U) / 2U;
        bool _S1214 = (WAVELENGTH_CDF_0[_S1213]) <= u_2;
        if(_S1214)
        {
            low_1 = _S1213;
        }
        else
        {
            uint _S1215 = _S1213 - 1U;
            high_1 = _S1215;
        }
    }
    uint _S1216 = low_1;
    float _S1217 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_2 - WAVELENGTH_CDF_0[_S1216]) / _S1217), _S1217 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_6)
{
    float _S1218 = clamp_1((wavelength_6 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1219 = (U32_min((uint(_S1218)), (79U)));
    uint _S1220 = 3U * _S1219;
    float3  _S1221 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1220], WAVELENGTH_WEIGHTS_0[_S1220 + 1U], WAVELENGTH_WEIGHTS_0[_S1220 + 2U]);
    float3  _S1222 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1220 + 3U], WAVELENGTH_WEIGHTS_0[_S1220 + 4U], WAVELENGTH_WEIGHTS_0[_S1220 + 5U]);
    return _S1221 + (_S1222 - _S1221) * make_float3 (_S1218 - float(_S1219));
}

__device__ float dispersedIor(float ior_2, float dispersion_1, float wavelength_7)
{
    float _S1223 = (ior_2 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1224 = _S1223 * (1.0f / (wavelength_7 * wavelength_7) - 2.89662933349609375f);
    bool _S1225 = dispersion_1 > 0.0f;
    float _S1226 = _slang_select(_S1225, _S1224,0.0f);
    return ior_2 + _S1226;
}

__device__ float2  vertexEta(BSDFMaterial material_19, float n_dot_v_0)
{
    bool _S1227 = n_dot_v_0 < 0.0f;
    float _S1228 = _slang_select(_S1227, material_19.ior,1.0f);
    float _S1229 = _slang_select(_S1227, 1.0f,material_19.ior);
    return make_float2 (_S1228, _S1229);
}

__device__ float2  wavelengthEta(BSDFMaterial material_20, float n_dot_v_1, float wavelength_8)
{
    BSDFMaterial refractive_0 = material_20;
    float _S1230 = dispersedIor(material_20.ior, material_20.dispersion, wavelength_8);
    bool _S1231 = wavelength_8 > 0.0f;
    float _S1232 = _slang_select(_S1231, _S1230,material_20.ior);
    (&refractive_0)->ior = _S1232;
    float2  _S1233 = vertexEta(refractive_0, n_dot_v_1);
    return _S1233;
}

__device__ bool neeDecision(BSDFMaterial material_21, float n_dot_v_2, float eta_i_6, float eta_o_5)
{
    float _S1234 = fresnel((F32_abs((n_dot_v_2))), eta_i_6, eta_o_5);
    float3  _S1235 = mix_0(make_float3 (_S1234), material_21.albedo, material_21.metallic);
    float _S1236 = rgb_to_greyscale(_S1235);
    float _S1237 = (F32_max(((1.0f - _S1236) * (1.0f - material_21.metallic) * (1.0f - material_21.transmission)), (0.0f)));
    bool _S1238 = _S1237 > 0.03999999910593033f;
    bool _S1239;
    if(_S1238)
    {
        _S1239 = true;
    }
    else
    {
        _S1239 = (material_21.roughness) > 0.20000000298023224f;
    }
    return _S1239;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_22)
{
    float _S1240 = rgb_to_greyscale(material_22->translucent);
    bool _S1241 = _S1240 > 0.0f;
    return _S1241;
}

struct MediumSides
{
    FKMedium behind;
    FKMedium front;
    uint2  fillings;
};

static __device__ MediumSides MediumSides_x24init_0(FKMedium * behind_1, FKMedium * front_0, uint2  fillings_1)
{
    MediumSides _S1242;
    (&_S1242)->behind = *behind_1;
    (&_S1242)->front = *front_0;
    (&_S1242)->fillings = fillings_1;
    return _S1242;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    MediumSides _S1243 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0));
    MediumSides sides_0 = _S1243;
    bool _S1244 = surface_8->encloses;
    if(_S1244)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S1245 = (dot_0(dir_12, surface_8->geometry_n)) > 0.0f;
        if(_S1245)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_3, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1246 = surface_9->geometry_n;
    ShadowContext _S1247 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1248 = surface_9->encloses;
    ShadowContext context_4;
    if(_S1248)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S1249 = - _S1246;
        float3  _S1250 = _slang_select(turned_0, _S1249,_S1246);
        (&faced_1)->geometry_n = _S1250;
        FKMedium _S1251 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1252 = faced_1;
        FKMedium _S1253 = _S1251;
        MediumSides _S1254 = mediumSides_0(&_S1252, &_S1253, filling_1, dir_13, outside_1);
        ShadowContext _S1255 = ShadowContext_x24init_0(_S1254.behind.extinction, _S1254.front.extinction, _S1254.fillings, _S1246, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1256 = _S1254.fillings;
            ShadowContext _S1257 = ShadowContext_x24init_0(_S1254.front.extinction, _S1254.behind.extinction, uint2 {_S1256.y, _S1256.x}, _S1246, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1257;
        }
        else
        {
            context_4 = _S1255;
        }
    }
    else
    {
        context_4 = _S1247;
    }
    return context_4;
}

static __device__ bool any_1(bool3  x_25)
{
    bool result_14 = false;
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
        if(result_14)
        {
            result_14 = true;
        }
        else
        {
            result_14 = (bool((_slang_vector_get_element(x_25, i_26))));
        }
        i_26 = i_26 + int(1);
    }
    return result_14;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_13, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S1258;
    (&_S1258)->unit_direction = unit_direction_1;
    (&_S1258)->throughput = throughput_1;
    (&_S1258)->random_state = random_state_13;
    (&_S1258)->refracted = refracted_3;
    (&_S1258)->lobe = lobe_4;
    (&_S1258)->pdf = pdf_6;
    return _S1258;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  v_12, float3  n_i_13, float n_i_dot_v_3, BSDFMaterial material_23, Weights w_15, uint random_state_14)
{
    float3  _S1259 = make_float3 (1.0f);
    SampleBSDF _S1260 = SampleBSDF_x24init_0(_S1259, _S1259, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1260;
    Random _S1261 = draw(random_state_14, 3U);
    Random _S1262 = draw(random_state_14, 2147483651U);
    (&sample_1)->random_state = _S1262.state;
    float _S1263 = _S1261.value;
    float _S1264 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1263 * _S1263))))));
    float _S1265 = 6.28318548202514648f * _S1262.value;
    float3  _S1266 = tangentToWorld(make_float3 (_S1264 * (F32_cos((_S1265))), _S1261.value, _S1264 * (F32_sin((_S1265)))), n_i_13);
    (&sample_1)->unit_direction = _S1266;
    (&sample_1)->lobe = 4U;
    float3  _S1267 = sheenVelvetBSDF((&sample_1)->unit_direction, v_12, n_i_13, material_23, w_15);
    (&sample_1)->throughput = _S1267;
    float _S1268 = sheenVelvetPDF(_S1261.value, n_i_dot_v_3, w_15);
    (&sample_1)->pdf = _S1268;
    return sample_1;
}

__device__ __forceinline__ SampleBSDF coatSample(float3  in_dir_8, float3  coat_h_3, CoatFrame coat_frame_7, Weights w_16, uint random_state_15)
{
    float3  _S1269 = make_float3 (1.0f);
    SampleBSDF _S1270 = SampleBSDF_x24init_0(_S1269, _S1269, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1270;
    float3  _S1271 = reflect_0(in_dir_8, coat_h_3);
    float3  _S1272 = ((((_S1271)) * make_float3(rnorm3df(((_S1271)).x, ((_S1271)).y, ((_S1271)).z))));
    (&sample_2)->unit_direction = _S1272;
    (&sample_2)->random_state = random_state_15;
    (&sample_2)->lobe = 5U;
    float3  _S1273 = coatBSDF(w_16);
    (&sample_2)->throughput = _S1273;
    float3  _S1274 = negate_0(in_dir_8);
    float _S1275 = coatPDF(_S1274, coat_h_3, coat_frame_7, w_16);
    (&sample_2)->pdf = _S1275;
    return sample_2;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1276 = (F32_sqrt((random_1_0)));
    float _S1277 = 6.28318548202514648f * random_2_0;
    float _S1278 = _S1276 * (F32_cos((_S1277)));
    float _S1279 = _S1276 * (F32_sin((_S1277)));
    float _S1280 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1278 * _S1278 - _S1279 * _S1279))))));
    return make_float3 (_S1278, _S1280, _S1279);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_14, float n_i_dot_v_4, BSDFMaterial material_24, Weights w_17, uint random_state_16)
{
    float3  _S1281 = make_float3 (1.0f);
    SampleBSDF _S1282 = SampleBSDF_x24init_0(_S1281, _S1281, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1282;
    Random _S1283 = draw(random_state_16, 3U);
    Random _S1284 = draw(random_state_16, 2147483651U);
    (&sample_3)->random_state = _S1284.state;
    float3  _S1285 = sampleCosWeightedHemisphere(_S1283.value, _S1284.value);
    float _S1286 = translucentShare(material_24);
    bool _S1287 = u_3 < (w_17.p_diffuse * _S1286);
    float _S1288 = _S1285.y;
    float _S1289 = - _S1288;
    float _S1290 = _slang_select(_S1287, _S1289,_S1288);
    float3  _S1291 = tangentToWorld(make_float3 (_S1285.x, _S1290, _S1285.z), n_i_14);
    (&sample_3)->unit_direction = _S1291;
    (&sample_3)->refracted = _S1287;
    (&sample_3)->lobe = 0U;
    float3  _S1292 = diffuseBSDF((&sample_3)->unit_direction, n_i_14, material_24, w_17);
    (&sample_3)->throughput = _S1292;
    float _S1293 = diffusePDF(_S1290, n_i_dot_v_4, material_24, w_17);
    (&sample_3)->pdf = _S1293;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_15, ToonProfile profile_2, Weights w_18, uint random_state_17)
{
    float3  _S1294 = make_float3 (1.0f);
    SampleBSDF _S1295 = SampleBSDF_x24init_0(_S1294, _S1294, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1295;
    Random _S1296 = draw(random_state_17, 3U);
    Random _S1297 = draw(random_state_17, 2147483651U);
    (&sample_4)->random_state = _S1297.state;
    float _S1298 = _S1296.value * profile_2.norm / 6.28318548202514648f;
    float t_23;
    if(profile_2.glossy)
    {
        t_23 = (F32_acos((clamp_1(1.0f - _S1298, -1.0f, 1.0f))));
    }
    else
    {
        t_23 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1298)))), (1.0f))))));
    }
    if(t_23 < (profile_2.a))
    {
    }
    else
    {
        t_23 = (profile_2.a + profile_2.b) / 2.0f;
    }
    int k_2 = int(0);
    for(;;)
    {
        if(k_2 < int(8))
        {
        }
        else
        {
            break;
        }
        float _S1299 = toonP(t_23, profile_2.a, profile_2.s);
        float _S1300 = _S1299 * (F32_sin((t_23)));
        float _S1301;
        if(profile_2.glossy)
        {
            _S1301 = 1.0f;
        }
        else
        {
            _S1301 = (F32_cos((t_23)));
        }
        float _S1302 = _S1300 * _S1301;
        float _S1303 = toonIntegral(t_23, profile_2.a, profile_2.s, profile_2.glossy);
        float _S1304 = (_S1303 - _S1298) / _S1302;
        bool _S1305 = _S1302 > 0.0f;
        float _S1306 = _slang_select(_S1305, _S1304,0.0f);
        float _S1307 = clamp_1(t_23 - _S1306, 0.0f, profile_2.b);
        int k_3 = k_2 + int(1);
        t_23 = _S1307;
        k_2 = k_3;
    }
    float _S1308 = 6.28318548202514648f * _S1297.value;
    float _S1309 = (F32_sin((t_23)));
    float3  _S1310 = tangentToWorld(make_float3 (_S1309 * (F32_cos((_S1308))), (F32_cos((t_23))), _S1309 * (F32_sin((_S1308)))), profile_2.axis);
    (&sample_4)->unit_direction = _S1310;
    bool _S1311 = (dot_0(n_i_15, (&sample_4)->unit_direction)) < 0.0f;
    (&sample_4)->refracted = _S1311;
    (&sample_4)->lobe = 6U;
    float3  _S1312 = toonBSDF((&sample_4)->unit_direction, n_i_15, profile_2, w_18);
    (&sample_4)->throughput = _S1312;
    float _S1313 = toonPDF((&sample_4)->unit_direction, n_i_15, profile_2, w_18);
    (&sample_4)->pdf = _S1313;
    return sample_4;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_1, float3  n_i_16, float alpha_9, AnisotropicFrame frame_6, BSDFMaterial material_25, Weights w_19, float pdf_h_3, float eta_i_7, float eta_o_6, uint random_state_18)
{
    float3  _S1314 = make_float3 (1.0f);
    SampleBSDF _S1315 = SampleBSDF_x24init_0(_S1314, _S1314, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1315;
    (&sample_5)->unit_direction = w_19.refracted;
    (&sample_5)->random_state = random_state_18;
    (&sample_5)->refracted = true;
    (&sample_5)->lobe = 1U;
    float3  _S1316 = refractBSDF((&sample_5)->unit_direction, n_i_16, alpha_9, frame_6, material_25, w_19);
    (&sample_5)->throughput = _S1316;
    float _S1317 = refractPDF(dot_0((&sample_5)->unit_direction, ggx_n_1), pdf_h_3, w_19, eta_i_7, eta_o_6);
    (&sample_5)->pdf = _S1317;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_2, float3  n_i_17, float alpha_10, AnisotropicFrame frame_7, Weights w_20, float pdf_h_4, uint random_state_19)
{
    float3  _S1318 = make_float3 (1.0f);
    SampleBSDF _S1319 = SampleBSDF_x24init_0(_S1318, _S1318, 0U, false, 0U, 0.0f);
    SampleBSDF sample_6 = _S1319;
    float3  _S1320 = reflect_0(in_dir_9, ggx_n_2);
    float3  _S1321 = ((((_S1320)) * make_float3(rnorm3df(((_S1320)).x, ((_S1320)).y, ((_S1320)).z))));
    (&sample_6)->unit_direction = _S1321;
    (&sample_6)->random_state = random_state_19;
    (&sample_6)->lobe = 2U;
    float3  _S1322 = reflectBSDF((&sample_6)->unit_direction, n_i_17, alpha_10, frame_7, w_20);
    (&sample_6)->throughput = _S1322;
    float _S1323 = reflectPDF(pdf_h_4, w_20);
    (&sample_6)->pdf = _S1323;
    return sample_6;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_11, BSDFMaterial material_26, float eta_i_8, float eta_o_7, uint random_init_0)
{
    uint random_state_20 = random_init_0;
    float3  _S1324 = negate_0(in_dir_10);
    float _S1325 = dot_0(n_11, _S1324);
    float _S1326 = sign_0(_S1325);
    float3  n_i_18 = n_11 * make_float3 (_S1326);
    float _S1327 = (F32_abs((_S1325)));
    float _S1328 = material_26.roughness;
    float _S1329 = _S1328 * _S1328;
    AnisotropicFrame _S1330 = anisotropicFrame(material_26, n_i_18);
    float _S1331 = sheenAlbedo(_S1324, n_i_18, material_26);
    float3  _S1332 = make_float3 (0.0f);
    CoatFrame _S1333 = CoatFrame_x24init_0(_S1332, 0.0f, 0.0f);
    bool _S1334 = (material_26.coat) > 0.0f;
    CoatFrame coat_frame_8;
    float3  coat_series_2;
    if(_S1334)
    {
        CoatFrame coat_frame_9 = coatFrame(material_26, n_i_18);
        float3  _S1335 = coatSeries(coat_frame_9, material_26);
        coat_frame_8 = coat_frame_9;
        coat_series_2 = _S1335;
    }
    else
    {
        coat_frame_8 = _S1333;
        coat_series_2 = _S1332;
    }
    float3  _S1336 = sampleHalfVector(_S1324, n_i_18, _S1329, _S1330, &random_state_20, 0U);
    float3  _S1337 = coatHalf(_S1324, coat_frame_8, material_26, random_init_0);
    Weights _S1338 = lobeWeights(in_dir_10, _S1324, n_i_18, _S1336, _S1337, _S1330, _S1331, coat_frame_8, coat_series_2, material_26, eta_i_8, eta_o_7);
    Random _S1339 = draw(random_state_20, 2U);
    random_state_20 = _S1339.state;
    bool _S1340 = (_S1339.value) < (_S1338.p_sheen_velvet);
    if(_S1340)
    {
        SampleBSDF _S1341 = sheenVelvetSample(_S1324, n_i_18, _S1327, material_26, _S1338, random_state_20);
        return _S1341;
    }
    float _S1342 = _S1339.value - _S1338.p_sheen_velvet;
    bool _S1343 = _S1342 < (_S1338.p_coat);
    if(_S1343)
    {
        SampleBSDF _S1344 = coatSample(in_dir_10, _S1337, coat_frame_8, _S1338, random_state_20);
        return _S1344;
    }
    float _S1345 = _S1342 - _S1338.p_coat;
    bool _S1346 = _S1345 < (_S1338.p_diffuse);
    if(_S1346)
    {
        SampleBSDF _S1347 = diffuseSample(_S1345, n_i_18, _S1327, material_26, _S1338, random_state_20);
        return _S1347;
    }
    bool _S1348 = _S1345 < (_S1338.p_diffuse + _S1338.p_toon);
    if(_S1348)
    {
        ToonProfile _S1349 = toonProfile(_S1324, n_i_18, material_26);
        SampleBSDF _S1350 = toonSample(n_i_18, _S1349, _S1338, random_state_20);
        return _S1350;
    }
    float _S1351 = vndfPDF(_S1324, _S1336, n_i_18, _S1327, _S1329, _S1330, _S1338.v_dot_h);
    bool _S1352 = (_S1345 - _S1338.p_toon) < (_S1338.p_diffuse + _S1338.p_refract);
    if(_S1352)
    {
        SampleBSDF _S1353 = refractSample(_S1336, n_i_18, _S1329, _S1330, material_26, _S1338, _S1351, eta_i_8, eta_o_7, random_state_20);
        return _S1353;
    }
    SampleBSDF _S1354 = reflectSample(in_dir_10, _S1336, n_i_18, _S1329, _S1330, _S1338, _S1351, random_state_20);
    return _S1354;
}

static __device__ bool boundsVolume_0(FKSurface * surface_10)
{
    return surface_10->encloses;
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_8, bool replay_1, float scale_3, Selection * sel_7)
{
    float spread_1;
    bool turned_1;
    bool is_inside_5;
    bool viewed_0;
    bool _S1355;
    bool _S1356;
    float density_2;
    float wavelength_9;
    float width_3;
    float sky_pdf_0;
    float threshold_0;
    uint b_6;
    uint layer_0;
    float3  throughput_2;
    float3  spectral_weight_0;
    TreeSample light_2;
    int _S1357;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_4;
    float sky_pdf_1;
    float spread_3;
    float width_5;
    float3  _S1358 = make_float3 (0.0f);
    Shift _S1359 = Shift_x24init_0(_S1358, 0.0f);
    uint _S1360 = r_8->path;
    uint _S1361 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1362 = extractBits_0(_S1360, 5U, 5U);
    uint _S1363 = extractBits_0(_S1360, 10U, 2U);
    uint _S1364 = extractBits_0(_S1360, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S1365 = _S1364 >= 3U;
        uint _S1366 = _slang_select(_S1365, 1U,0U);
        uint _S1367 = _S1361 + _S1366;
        uint _S1368 = (fcptMaxBounces());
        passes_0 = _S1367 > _S1368;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1359;
    }
    uint _S1369 = _S1362 - 1U;
    bool _S1370 = _S1364 == 3U;
    uint _S1371 = _slang_select(_S1370, 1U,0U);
    uint _S1372 = _S1361 + _S1371;
    bool _S1373 = _S1363 == 0U;
    uint _S1374 = _slang_select(_S1373, _S1372,_S1369);
    FKHit _S1375 = (fcptReservoirHit((*r_8)));
    float3  _S1376 = dom_7->x0;
    float3  _S1377 = dom_7->x1 - dom_7->x0;
    float3  _S1378 = ((((_S1377)) * make_float3(rnorm3df(((_S1377)).x, ((_S1377)).y, ((_S1377)).z))));
    FKRay _S1379 = Ray_x24init_0(dom_7->x1, _S1378);
    FKRay ray_2 = _S1379;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1358;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_2 = throughput_3;
    float3  glowed_0 = _S1358;
    float3  extinction_in_0 = _S1358;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1380 = dom_7->spread;
    float _S1381 = dom_7->width;
    float _S1382 = length_0(_S1377);
    NEEVertex _S1383 = NEEVertex_x24init_0(true, 0.0f, _S1358, _S1358, _S1358);
    NEEVertex nee_vertex_0 = _S1383;
    Vertex _S1384 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1384;
    Reservoir _S1385 = (Reservoir{});
    Reservoir chain_0 = _S1385;
    uint _S1386 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    uint _S1387 = extractBits_0(_S1360, 24U, 8U);
    uint _S1388 = insertBits_0(0U, _S1387, 24U, 8U);
    (&chain_0)->path = _S1388;
    (&ray_2)->origin = _S1376;
    (&hit_4)->distance = _S1382;
    FKMedium _S1389 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1390 = filling_2;
    bool _S1391 = (fcptVaryingUsed());
    uint _S1392 = _slang_select(_S1391, _S1390,4294967295U);
    filling_2 = _S1392;
    scatter_in_0 = _S1389.scatter;
    extinction_in_0 = _S1389.extinction;
    g_in_0 = _S1389.g;
    Reservoir _S1393 = chain_0;
    uint _S1394 = filling_2;
    for(;;)
    {
        bool _S1395 = (fcptVaryingUsed());
        if(_S1395)
        {
            passes_0 = _S1394 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1396 = (fcptMajorant((_S1394)));
            spread_1 = _S1396;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S1374;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1363 == 1U;
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
            ended_0 = _S1359;
            sky_pdf_0 = 0.0f;
            spread_1 = _S1380;
            width_3 = _S1381;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_6 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1397 = (&prev_0)->rough;
        if(_S1397)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1398 = stream(_S1386, 384U);
        uint tracking_0 = _S1398;
        weight_2 = throughput_3;
        glowed_0 = _S1358;
        b_6 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        wavelength_9 = _S1380;
        width_3 = _S1381;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1357 = int(1);
                break;
            }
            uint _S1399 = noiseAddress(_S1386, b_6);
            Random _S1400 = draw(_S1399, 10U);
            float _S1401 = - (F32_log((1.0f - _S1400.value))) / spread_1;
            if(passes_0)
            {
                float3  _S1402 = (&ray_2)->origin;
                float3  _S1403 = (&ray_2)->unit_direction;
                float _S1404 = (&hit_4)->distance;
                bool _S1405 = b_6 == 4294967295U;
                uint _S1406 = _slang_select(_S1405, 0U,b_6);
                uint _S1407 = (&prev_0)->lobe;
                uint _S1408 = _slang_select(_S1405, 3U,_S1407);
                float _S1409 = (fcptTrackMedium((_S1394), (_S1402), (_S1403), (_S1404), (&tracking_0), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1406), (_S1408), (_S1405)));
                threshold_0 = _S1409;
            }
            else
            {
                threshold_0 = _S1401;
            }
            bool _S1410 = !(threshold_0 < ((&hit_4)->distance));
            if(_S1410)
            {
                _S1357 = int(1);
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
                float3  _S1411 = pathColor(throughput_2 * glowed_0, throughput_3, 0.0f);
                float3  _S1412 = _S1411 / make_float3 (density_2);
                float3  _S1413 = sel_7->glow + _S1412;
                sel_7->glow = _S1413;
            }
            else
            {
            }
            glowed_0 = _S1358;
            uint b_7 = b_6 + 1U;
            float3  _S1414 = (&ray_2)->origin + make_float3 (threshold_0) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1414;
            float3  _S1415 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, threshold_0, true);
            float3  _S1416 = weight_2;
            float _S1417 = upsample(weight_2, 0.0f);
            float3  _S1418 = make_float3 (_S1417);
            float3  _S1419 = _slang_select(false, _S1418,_S1416);
            float3  _S1420 = _slang_select(passes_0, _S1419,_S1415);
            float3  throughput_4 = throughput_2 * _S1420;
            uint _S1421 = stream(_S1386, b_7 + 320U);
            tracking_0 = _S1421;
            weight_2 = throughput_3;
            float width_6 = width_3 + wavelength_9 * threshold_0;
            float _S1422 = wavelength_9 + 3.14159274101257324f;
            bool _S1423 = !replay_1;
            if(_S1423)
            {
                is_inside_5 = true;
            }
            else
            {
                bool _S1424 = b_7 == _S1374;
                if(_S1424)
                {
                    is_inside_5 = !passes_0;
                }
                else
                {
                    is_inside_5 = false;
                }
            }
            TreeSample _S1425 = TreeSample_x24init_0(_S1358, _S1358, 0.0f, 0U);
            if(is_inside_5)
            {
                float3  _S1426 = (&ray_2)->origin;
                float3  _S1427 = (&ray_2)->unit_direction;
                float3  _S1428 = (&ray_2)->unit_direction;
                uint _S1429 = noiseAddress(_S1386, b_7);
                float3  _S1430 = extinction_in_0;
                float3  _S1431 = extinction_in_0;
                uint2  _S1432 = make_uint2 (_S1394);
                float3  _S1433 = (&ray_2)->unit_direction;
                uint _S1434 = arrivalLobe_0(b_7, (&prev_0)->lobe);
                FKHit _S1435 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1436 = _S1435;
                ShadowContext _S1437 = ShadowContext_x24init_0(_S1430, _S1431, _S1432, _S1433, b_7, _S1434, false, threshold_0, width_6, &_S1436, false);
                ShadowContext _S1438 = _S1437;
                TreeSample _S1439 = sampleLightTree_0(_S1426, _S1427, _S1428, 0.0f, true, _S1429, &_S1438);
                light_2 = _S1439;
            }
            else
            {
                light_2 = _S1425;
            }
            float _S1440 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_2.dir));
            uint _S1441 = (fcptMaxBounces());
            bool _S1442 = b_7 < _S1441;
            if(_S1442)
            {
                viewed_0 = (light_2.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S1443 = _slang_select(viewed_0, _S1440,0.0f);
            float3  _S1444 = throughput_4 * light_2.radiance;
            float _S1445 = powerHeuristic(light_2.density, _S1443);
            float3  _S1446 = pathColor(_S1444 * make_float3 (_S1440 * _S1445), throughput_3, 0.0f);
            float3  _S1447 = _slang_select(is_inside_5, _S1446,_S1358);
            if(replay_1)
            {
                _S1355 = b_7 == _S1374;
            }
            else
            {
                _S1355 = false;
            }
            if(_S1355)
            {
                bool _S1448 = _S1363 == 2U;
                if(_S1448)
                {
                    float _S1449 = resamplingTarget(_S1447);
                    passes_0 = _S1449 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1450 = Shift_x24init_0(_S1447, 1.0f);
                    _S1357 = int(0);
                    ended_0 = _S1450;
                    spread_1 = _S1422;
                    threshold_0 = width_6;
                    spectral_weight_0 = throughput_4;
                    layer_0 = b_7;
                    break;
                }
                _S1357 = int(0);
                ended_0 = _S1359;
                spread_1 = _S1422;
                threshold_0 = width_6;
                spectral_weight_0 = throughput_4;
                layer_0 = b_7;
                break;
            }
            if(_S1423)
            {
                Reservoir candidate_3 = _S1393;
                uint _S1451 = extractBits_0(_S1393.path, 24U, 8U);
                uint _S1452 = insertBits_0(0U, _S1451, 24U, 8U);
                uint _S1453 = extractBits_0(_S1393.path, 10U, 2U);
                bool _S1454 = _S1453 == 1U;
                if(_S1454)
                {
                    float3  _S1455 = safeDivide(_S1447, _S1358);
                    (&candidate_3)->radiance = _S1455;
                }
                else
                {
                    uint _S1456 = insertBits_0(_S1452, b_7 + 1U, 5U, 5U);
                    uint _S1457 = insertBits_0(_S1456, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1457;
                }
                Reservoir _S1458 = withEnd(candidate_3, 0U, b_7, _S1447);
                offer(sel_7, _S1458, _S1447 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1459 = survivalProbability(abs_0(throughput_4), density_2);
                uint _S1460 = noiseAddress(_S1386, b_7);
                Random _S1461 = draw(_S1460, 8U);
                bool _S1462 = _S1459 < (_S1461.value);
                if(_S1462)
                {
                    _S1356 = true;
                }
                else
                {
                    uint _S1463 = (fcptMaxBounces());
                    _S1356 = b_7 >= _S1463;
                }
                if(_S1356)
                {
                    _S1357 = int(0);
                    ended_0 = _S1359;
                    spread_1 = _S1422;
                    threshold_0 = width_6;
                    spectral_weight_0 = throughput_4;
                    layer_0 = b_7;
                    break;
                }
                float _S1464 = density_2 * _S1459;
                density_2 = _S1464;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1465 = noiseAddress(_S1386, b_7);
            float3  _S1466 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1465, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1466;
            NEEVertex _S1467 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1358, (&ray_2)->origin);
            nee_vertex_0 = _S1467;
            Vertex _S1468 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_0 = _S1468;
            float _S1469 = (&prev_0)->pdf;
            FKRay _S1470 = ray_2;
            FKHit _S1471 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1472 = (fcptTraverseInstanceBVH((_S1470), (true), (4.294967296e+09f), (false), (_S1471), (false)));
            hit_4 = _S1472;
            b_6 = b_7;
            throughput_2 = throughput_4;
            wavelength_9 = _S1422;
            width_3 = width_6;
            sky_pdf_0 = _S1469;
        }
        if(_S1357 != int(1))
        {
            width_3 = threshold_0;
            throughput_2 = spectral_weight_0;
            b_6 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1359;
        spread_1 = wavelength_9;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1473 = b_6 == 4294967295U;
    bool _S1474 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1474)
    {
        bool _S1475 = !(&nee_vertex_0)->none;
        float _S1476 = _slang_select(_S1475, sky_pdf_0,0.0f);
        float _S1477 = escapeWeight_0(_S1476, (&ray_2)->unit_direction);
        float3  _S1478 = environment_0((&ray_2)->unit_direction, b_6, (&prev_0)->lobe);
        float3  _S1479 = pathColor(throughput_2 * _S1478, throughput_3, 0.0f);
        if(replay_1)
        {
            bool _S1480 = b_6 == _S1374;
            if(_S1480)
            {
                passes_0 = _S1363 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1479 * make_float3 (_S1477) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1373)
            {
                passes_0 = _S1370;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_6 == _S1361;
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
                return Shift_x24init_0(_S1479 * make_float3 (_S1477), 1.0f);
            }
            return _S1359;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1481 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1482 = _S1481 == 1U;
        if(_S1482)
        {
            uint _S1483 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1484 = _S1483 == b_6;
            float _S1485 = _slang_select(_S1484, 1.0f,_S1477);
            float3  _S1486 = safeDivide(_S1479 * make_float3 (_S1485), _S1358);
            (&candidate_4)->radiance = _S1486;
        }
        else
        {
            bool _S1487 = (&prev_0)->rough;
            if(_S1487)
            {
                uint _S1488 = insertBits_0(_S1388, b_6 + 1U, 5U, 5U);
                uint _S1489 = insertBits_0(_S1488, 3U, 10U, 2U);
                uint _S1490 = insertBits_0(_S1489, (&prev_0)->lobe, 15U, 3U);
                bool _S1491 = (&prev_0)->inside;
                uint _S1492 = _slang_select(_S1491, 1U,0U);
                uint _S1493 = insertBits_0(_S1490, _S1492, 22U, 1U);
                (&candidate_4)->path = _S1493;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1494 = _S1479 * make_float3 (_S1477);
        Reservoir _S1495 = withEnd(candidate_4, 3U, b_6, _S1494);
        offer(sel_7, _S1495, _S1494 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1359;
    }
    float3  _S1496 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1496;
    bool _S1497 = (fcptVaryingUsed());
    if(_S1497)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1498 = !replay_1;
        if(_S1498)
        {
            float3  _S1499 = pathColor(throughput_2 * glowed_0, throughput_3, 0.0f);
            float3  _S1500 = _S1499 / make_float3 (density_2);
            float3  _S1501 = sel_7->glow + _S1500;
            sel_7->glow = _S1501;
        }
        float3  _S1502 = throughput_2 * weight_2;
        throughput_2 = _S1502;
    }
    else
    {
        float3  _S1503 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1504 = throughput_2 * _S1503;
        throughput_2 = _S1504;
    }
    float _S1505 = width_3 + spread_1 * (&hit_4)->distance;
    uint _S1506 = b_6 + 1U;
    b_6 = _S1506;
    layer_0 = 0U;
    width_3 = _S1505;
    passes_0 = false;
    wavelength_9 = 0.0f;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    spectral_weight_0 = throughput_3;
    float3  chain_throughput_0 = _S1358;
    float3  reconnection_0 = _S1358;
    viewed_0 = _S1473;
    for(;;)
    {
        bool _S1507 = ((&hit_4)->is_point_light) == 1U;
        if(replay_1)
        {
            _S1355 = _S1363 == 1U;
        }
        else
        {
            _S1355 = false;
        }
        if(_S1355)
        {
            _S1356 = b_6 == _S1362;
        }
        else
        {
            _S1356 = false;
        }
        bool _S1508;
        if(_S1356)
        {
            bool _S1509 = ((&hit_4)->instance_index) != (_S1375.instance_index);
            if(_S1509)
            {
                _S1508 = true;
            }
            else
            {
                _S1508 = ((&hit_4)->triangle_index) != (_S1375.triangle_index);
            }
        }
        else
        {
            _S1508 = false;
        }
        if(_S1508)
        {
            return _S1359;
        }
        FKMedium _S1510 = Medium_x24init_0(_S1358, _S1358, 0.0f);
        BSDFMaterial _S1511 = Material_x24init_0(_S1358, _S1358, 0.0f, 0.0f, 0.0f, 0.0f, _S1358, throughput_3, 1.0f, _S1358, _S1358, 0.5f, 0.0f, 0.0f, _S1358, 0.0f, _S1358, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, throughput_3, _S1358);
        FKMedium _S1512 = _S1510;
        FKSurface _S1513 = Surface_x24init_0(_S1358, _S1358, 0.0f, &_S1511, false, 0U, 1.0f, false, &_S1512, 4294967295U, _S1358);
        FKSurface surface_11 = _S1513;
        bool _S1514 = !_S1507;
        bool scatter_2;
        bool is_inside_6;
        float geometry_density_0;
        float3  throughput_5;
        if(_S1514)
        {
            uint _S1515 = noiseAddress(_S1386, b_6);
            uint _S1516 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKSurface _S1517 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1515), (width_3), (layer_0), (b_6), (_S1516), ((&ray_2)->unit_direction)));
            surface_11 = _S1517;
            float3  _S1518 = (&(&surface_11)->material)->emissive;
            float3  _S1519 = _slang_select(passes_0, _S1358,_S1518);
            (&(&surface_11)->material)->emissive = _S1519;
            uint _S1520 = noiseAddress(_S1386, b_6);
            Random _S1521 = draw(_S1520, 9U);
            FKSurface _S1522 = surface_11;
            FKSurface _S1523 = uncovered_0(&_S1522, _S1521.value);
            surface_11 = _S1523;
            float _S1524 = facingSign((&(&surface_11)->material)->transmission, (&surface_11)->geometry_n, (&ray_2)->unit_direction);
            bool _S1525 = _S1524 < 0.0f;
            bool _S1526 = ((&(&surface_11)->material)->transmission) > 0.0f;
            if(_S1526)
            {
                bool _S1527 = arrivesBehind_0((&ray_2)->unit_direction, (&surface_11)->geometry_n);
                scatter_2 = _S1527;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1528 = surface_11;
            FKSurface _S1529 = facingRay_0(&_S1528, (&ray_2)->unit_direction);
            surface_11 = _S1529;
            if(passes_0)
            {
                bool _S1530 = arrivesBehind_0((&ray_2)->unit_direction, (&surface_11)->geometry_n);
                is_inside_6 = _S1530;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float _S1531 = (&hit_4)->distance;
                float3  _S1532 = (&(&surface_11)->material)->absorption;
                float _S1533 = upsample((&(&surface_11)->material)->absorption, wavelength_9);
                float3  _S1534 = make_float3 (_S1533);
                bool _S1535 = wavelength_9 > 0.0f;
                float3  _S1536 = _slang_select(_S1535, _S1534,_S1532);
                float3  _S1537 = beerLambert(_S1531, _S1536);
                float3  _S1538 = throughput_2 * _S1537;
                throughput_5 = _S1538;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1539 = !(&surface_11)->skip;
            float geometry_density_1 = (F32_abs((dot_0((&surface_11)->geometry_n, (&ray_2)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1540 = b_6 == _S1506;
            if(_S1540)
            {
                float _S1541 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1541;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S1542 = geometry_density_0;
            scatter_2 = _S1539;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1542;
            turned_1 = _S1525;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S1543;
        if(scatter_2)
        {
            _S1543 = (&prev_0)->rough;
        }
        else
        {
            _S1543 = false;
        }
        bool _S1544;
        if(_S1543)
        {
            _S1544 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1544 = false;
        }
        float _S1545 = dot_0((&surface_11)->smooth_n, - (&ray_2)->unit_direction);
        bool _S1546 = (fcptDispersionUsed());
        bool _S1547;
        if(_S1546)
        {
            _S1547 = wavelength_9 == 0.0f;
        }
        else
        {
            _S1547 = false;
        }
        bool _S1548;
        if(_S1547)
        {
            _S1548 = scatter_2;
        }
        else
        {
            _S1548 = false;
        }
        bool _S1549;
        if(_S1548)
        {
            bool _S1550 = dispersive((&surface_11)->material);
            _S1549 = _S1550;
        }
        else
        {
            _S1549 = false;
        }
        float3  throughput_6;
        if(_S1549)
        {
            uint _S1551 = stream(_S1386, 512U);
            Random _S1552 = pcg(_S1551);
            uint _S1553 = extractBits_0(_S1360, 25U, 7U);
            float _S1554 = (float(_S1553) + _S1552.value) / 128.0f;
            uint _S1555 = extractBits_0(_S1360, 24U, 1U);
            bool _S1556 = _S1555 == 1U;
            float _S1557 = _slang_select(_S1556, _S1554,_S1552.value);
            float2  _S1558 = sampleWavelength(_S1557);
            float wavelength_10 = _S1558.x;
            float3  _S1559 = wavelengthWeights(wavelength_10);
            float3  _S1560 = _S1559 / make_float3 (_S1558.y);
            float _S1561 = upsample(throughput_5, wavelength_10);
            float3  _S1562 = make_float3 (_S1561);
            float _S1563 = upsample(scatter_in_0, wavelength_10);
            float3  _S1564 = make_float3 (_S1563);
            scatter_in_0 = _S1564;
            float _S1565 = upsample(extinction_in_0, wavelength_10);
            float3  _S1566 = make_float3 (_S1565);
            extinction_in_0 = _S1566;
            wavelength_9 = wavelength_10;
            throughput_6 = _S1562;
            spectral_weight_0 = _S1560;
        }
        else
        {
            throughput_6 = throughput_5;
        }
        BSDFMaterial _S1567 = pathMaterial((&surface_11)->material, wavelength_9);
        float2  _S1568 = wavelengthEta(_S1567, _S1545, wavelength_9);
        bool _S1569;
        if(scatter_2)
        {
            bool _S1570 = neeDecision(_S1567, _S1545, _S1568.x, _S1568.y);
            _S1569 = _S1570;
        }
        else
        {
            _S1569 = false;
        }
        bool _S1571;
        if(passes_0)
        {
            _S1571 = true;
        }
        else
        {
            _S1571 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1571)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1569;
        }
        bool _S1572 = (fcptHairUsed());
        bool _S1573;
        if(_S1572)
        {
            _S1573 = (dot_0((&surface_11)->hair, (&surface_11)->hair)) > 0.0f;
        }
        else
        {
            _S1573 = false;
        }
        bool _S1574;
        if(_S1573)
        {
            _S1574 = true;
        }
        else
        {
            BSDFMaterial _S1575 = _S1567;
            bool _S1576 = isTranslucent_0(&_S1575);
            _S1574 = _S1576;
        }
        bool _S1577;
        if(_S1574)
        {
            _S1577 = true;
        }
        else
        {
            bool _S1578 = (_S1567.transmission) > 0.0f;
            if(_S1578)
            {
                uint _S1579 = (fcptLayers((hit_4)));
                _S1577 = _S1579 == 1U;
            }
            else
            {
                _S1577 = false;
            }
        }
        float3  emission_0;
        if(_S1507)
        {
            float3  _S1580 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1580;
        }
        else
        {
            emission_0 = _S1567.emissive;
        }
        bool _S1581 = !replay_1;
        bool _S1582;
        if(_S1581)
        {
            _S1582 = true;
        }
        else
        {
            _S1582 = b_6 >= _S1374;
        }
        bool _S1583;
        if(_S1582)
        {
            float _S1584 = rgb_to_greyscale(emission_0);
            _S1583 = _S1584 > 0.0f;
        }
        else
        {
            _S1583 = false;
        }
        float3  emission_1;
        if(_S1583)
        {
            NEEVertex _S1585 = nee_vertex_0;
            FKHit _S1586 = hit_4;
            float _S1587 = emissionWeight_0(&_S1585, &_S1586, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1587);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1588;
        if(replay_1)
        {
            _S1588 = _S1363 == 1U;
        }
        else
        {
            _S1588 = false;
        }
        bool _S1589;
        if(_S1588)
        {
            _S1589 = b_6 > _S1362;
        }
        else
        {
            _S1589 = false;
        }
        bool _S1590;
        if(_S1589)
        {
            _S1590 = b_6 == _S1361;
        }
        else
        {
            _S1590 = false;
        }
        bool _S1591;
        if(_S1590)
        {
            bool _S1592 = _S1364 == 1U;
            if(_S1592)
            {
                _S1591 = true;
            }
            else
            {
                _S1591 = _S1364 == 2U;
            }
        }
        else
        {
            _S1591 = false;
        }
        if(_S1591)
        {
            bool _S1593 = _S1507 != (_S1364 == 2U);
            if(_S1593)
            {
                return _S1359;
            }
            float3  _S1594 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_9);
            return Shift_x24init_0(_S1594 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1595 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1596 = _S1595 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1597 = insertBits_0(_S1388, b_6, 5U, 5U);
        uint _S1598 = insertBits_0(_S1597, 1U, 10U, 2U);
        uint _S1599 = insertBits_0(_S1598, (&prev_0)->lobe, 15U, 3U);
        bool _S1600 = (&prev_0)->inside;
        uint _S1601 = _slang_select(_S1600, 1U,0U);
        uint _S1602 = insertBits_0(_S1599, _S1601, 22U, 1U);
        (&here_0)->path = _S1602;
        uint _S1603 = (&here_0)->path;
        bool _S1604 = wavelength_9 > 0.0f;
        uint _S1605 = _slang_select(_S1604, 1U,0U);
        uint _S1606 = insertBits_0(_S1603, _S1605, 23U, 1U);
        (&here_0)->path = _S1606;
        float _S1607 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S1607;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1608;
        if(replay_1)
        {
            _S1608 = _S1363 == 1U;
        }
        else
        {
            _S1608 = false;
        }
        bool _S1609;
        if(_S1608)
        {
            _S1609 = b_6 == _S1362;
        }
        else
        {
            _S1609 = false;
        }
        bool _S1610 = b_6 == _S1374;
        bool _S1611;
        if(_S1610)
        {
            bool _S1612 = !scatter_2;
            if(_S1612)
            {
                _S1611 = true;
            }
            else
            {
                bool _S1613 = _S1363 != 1U;
                if(_S1613)
                {
                    _S1611 = _S1363 != 3U;
                }
                else
                {
                    _S1611 = false;
                }
            }
        }
        else
        {
            _S1611 = false;
        }
        bool _S1614;
        if(_S1611)
        {
            _S1614 = _S1363 == 2U;
        }
        else
        {
            _S1614 = false;
        }
        bool _S1615;
        if(_S1614)
        {
            _S1615 = !_S1544;
        }
        else
        {
            _S1615 = false;
        }
        bool _S1616;
        if(_S1615)
        {
            _S1616 = _S1364 != 4U;
        }
        else
        {
            _S1616 = false;
        }
        bool _S1617 = _S1362 == _S1361;
        bool _S1618;
        if(_S1617)
        {
            _S1618 = _S1364 == 0U;
        }
        else
        {
            _S1618 = false;
        }
        bool _S1619;
        if(_S1618)
        {
            _S1619 = ((&hit_4)->instance_index) == (_S1375.instance_index);
        }
        else
        {
            _S1619 = false;
        }
        bool _S1620;
        if(_S1619)
        {
            _S1620 = ((&hit_4)->triangle_index) == (_S1375.triangle_index);
        }
        else
        {
            _S1620 = false;
        }
        bool _S1621;
        if(_S1620)
        {
            _S1621 = _S1544;
        }
        else
        {
            _S1621 = false;
        }
        bool _S1622 = _slang_select(_S1609, _S1621,_S1616);
        bool _S1623;
        if(nee_0)
        {
            _S1623 = _slang_select(replay_1, _S1622,scatter_2);
        }
        else
        {
            _S1623 = false;
        }
        TreeSample _S1624 = TreeSample_x24init_0(_S1358, _S1358, 0.0f, 0U);
        uint2  _S1625 = make_uint2 (0U);
        FKHit _S1626 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1627 = _S1626;
        ShadowContext _S1628 = ShadowContext_x24init_0(_S1358, _S1358, _S1625, _S1358, 0U, 0U, false, 0.0f, 0.0f, &_S1627, false);
        bool _S1629;
        if(nee_0)
        {
            _S1629 = _S1582;
        }
        else
        {
            _S1629 = false;
        }
        ShadowContext context_5;
        if(_S1629)
        {
            uint _S1630 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKMedium _S1631 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1632 = surface_11;
            FKHit _S1633 = hit_4;
            FKMedium _S1634 = _S1631;
            ShadowContext _S1635 = shadowContext_0(&_S1632, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_6, _S1630, (&hit_4)->distance, width_3, &_S1633, _S1573, &_S1634);
            context_5 = _S1635;
        }
        else
        {
            context_5 = _S1628;
        }
        bool viewed_1;
        uint b_8;
        float3  throughput_7;
        float3  lit_0;
        if(_S1623)
        {
            float3  _S1636 = (&ray_2)->origin;
            if(_S1573)
            {
                throughput_7 = _S1358;
            }
            else
            {
                throughput_7 = (&surface_11)->smooth_n;
            }
            uint _S1637 = noiseAddress(_S1386, b_6);
            ShadowContext _S1638 = context_5;
            TreeSample _S1639 = sampleLightTree_0(_S1636, throughput_7, (&surface_11)->geometry_n, (&surface_11)->geometry_offset, _S1577, _S1637, &_S1638);
            bool _S1640 = any_1((_S1639.radiance) != _S1358);
            if(_S1640)
            {
                if(_S1573)
                {
                    uint _S1641 = (fcptMaxBounces());
                    bool _S1642 = b_6 < _S1641;
                    FKSurface _S1643 = surface_11;
                    TreeSample _S1644 = _S1639;
                    float3  _S1645 = hairLight_0(&_S1643, (&ray_2)->unit_direction, &_S1644, _S1642);
                    lit_0 = _S1645;
                }
                else
                {
                    FixedArray<float3 , 6>  throughputs_3;
                    FixedArray<float, 6>  pdfs_3;
                    float3  _S1646 = BSDF((&ray_2)->unit_direction, _S1639.dir, (&surface_11)->smooth_n, _S1567, _S1568.x, _S1568.y, (dot_0((&surface_11)->geometry_n, - (&ray_2)->unit_direction) * dot_0((&surface_11)->geometry_n, _S1639.dir)) <= 0.0f, (&surface_11)->random_state, 4294967295U, &throughputs_3, &pdfs_3);
                    uint _S1647 = (fcptMaxBounces());
                    bool _S1648 = !(b_6 < _S1647);
                    if(_S1648)
                    {
                        viewed_1 = true;
                    }
                    else
                    {
                        viewed_1 = (_S1639.density) == 0.0f;
                    }
                    if(viewed_1)
                    {
                        float3  _S1649 = _S1646 * _S1639.radiance;
                        lit_0 = _S1649;
                    }
                    else
                    {
                        b_8 = 0U;
                        lit_0 = _S1358;
                        for(;;)
                        {
                            if(b_8 < 6U)
                            {
                            }
                            else
                            {
                                break;
                            }
                            bool _S1650 = (pdfs_3[b_8]) > 0.0f;
                            if(_S1650)
                            {
                                float _S1651 = pdfs_3[b_8] / _S1639.density;
                                float3  lit_1 = lit_0 + throughputs_3[b_8] * make_float3 (pdfs_3[b_8]) / make_float3 (_S1639.density * (1.0f + _S1651 * _S1651));
                                lit_0 = lit_1;
                            }
                            uint i_27 = b_8 + 1U;
                            b_8 = i_27;
                        }
                        float3  _S1652 = lit_0 * _S1639.radiance * make_float3 (_S1639.density);
                        lit_0 = _S1652;
                    }
                }
            }
            else
            {
                lit_0 = _S1358;
            }
            light_2 = _S1639;
        }
        else
        {
            light_2 = _S1624;
            lit_0 = _S1358;
        }
        bool refracted_4;
        bool wrong_side_0;
        bool _S1653;
        bool _S1654;
        float density_4;
        if(_S1609)
        {
            bool _S1655 = !_S1544;
            if(_S1655)
            {
                return _S1359;
            }
            uint _S1656 = extractBits_0(_S1360, 23U, 1U);
            bool _S1657 = _S1604 != (_S1656 == 1U);
            if(_S1657)
            {
                return _S1359;
            }
            float3  throughput_8 = throughput_6 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S1617)
            {
                viewed_1 = _S1364 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                float3  _S1658 = pathColor(throughput_8 * emission_1, spectral_weight_0, wavelength_9);
                return Shift_x24init_0(_S1658 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1617)
            {
                refracted_4 = _S1364 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1659 = !nee_0;
                if(_S1659)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1660 = rgb_to_greyscale(light_2.radiance);
                    passes_0 = !(_S1660 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1359;
                }
                float3  _S1661 = pathColor(throughput_8 * lit_0, spectral_weight_0, wavelength_9);
                return Shift_x24init_0(_S1661 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1617)
            {
                wrong_side_0 = _S1364 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1662 = !nee_0;
                if(_S1662)
                {
                    return _S1359;
                }
                float3  _S1663 = r_8->dir;
                float _S1664 = environmentPdf_0(r_8->dir);
                bool _S1665 = (fcptWorldReadsPath());
                if(_S1665)
                {
                    uint _S1666 = b_6 + 1U;
                    FKSurface _S1667 = surface_11;
                    float3  _S1668 = skyColor_0((&ray_2)->unit_direction, _S1663, &_S1667, wavelength_9, _S1568, is_inside_6, _S1664, (&surface_11)->random_state, _S1666);
                    throughput_2 = _S1668;
                }
                else
                {
                    float3  _S1669 = skyBSDF((&ray_2)->unit_direction, _S1663, surface_11, _S1567, _S1568, is_inside_6, _S1664, (&surface_11)->random_state);
                    throughput_2 = _S1669;
                }
                float3  _S1670 = pathColor(throughput_8 * throughput_2 * r_8->radiance, spectral_weight_0, wavelength_9);
                return Shift_x24init_0(_S1670 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1671 = extractBits_0(_S1360, 21U, 1U);
            bool _S1672 = nee_0 != (_S1671 == 1U);
            if(_S1672)
            {
                return _S1359;
            }
            throughput_7 = throughput_8;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S1610;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1673 = !scatter_2;
                if(_S1673)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1674 = _S1363 != 1U;
                    if(_S1674)
                    {
                        refracted_4 = _S1363 != 3U;
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
                bool _S1675 = _S1363 == 2U;
                if(_S1675)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1544;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1364 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1573)
                    {
                        return _S1359;
                    }
                    uint _S1676 = noiseAddress(_S1386, b_6);
                    FKRay _S1677 = ray_2;
                    FKSurface _S1678 = surface_11;
                    ShadowContext _S1679 = context_5;
                    SkySample _S1680 = sampleSky_0(&_S1677, &_S1678, wavelength_9, _S1568, is_inside_6, _S1676, (&surface_11)->random_state, &_S1679);
                    float3  _S1681 = pathColor(throughput_6 * _S1680.color, spectral_weight_0, wavelength_9);
                    return Shift_x24init_0(_S1681, 1.0f);
                }
                if(_S1675)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1544;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1682 = rgb_to_greyscale(light_2.radiance);
                    bool _S1683 = !(_S1682 > 0.0f);
                    if(_S1683)
                    {
                        return _S1359;
                    }
                    float3  _S1684 = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_9);
                    return Shift_x24init_0(_S1684, 1.0f);
                }
                if(_S1373)
                {
                    passes_0 = _S1364 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1507;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1685 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_9);
                    return Shift_x24init_0(_S1685, 1.0f);
                }
                if(_S1373)
                {
                    passes_0 = _S1364 == 1U;
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
                    passes_0 = !_S1544;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1686 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_9);
                    return Shift_x24init_0(_S1686, 1.0f);
                }
                return _S1359;
            }
            else
            {
                if(_S1581)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1687 = b_6 > 0U;
                    if(_S1687)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1596)
                        {
                            float3  _S1688 = safeDivide(throughput_6 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1688;
                        }
                        else
                        {
                            if(_S1544)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1689 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_9);
                        Reservoir _S1690 = withEnd(candidate_5, 1U, b_6, _S1689);
                        offer(sel_7, _S1690, _S1689 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1691 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_9);
                        float3  _S1692 = sel_7->glow + _S1691;
                        sel_7->glow = _S1692;
                    }
                    if(nee_0)
                    {
                        float3  _S1693 = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_9);
                        Reservoir candidate_6 = chain_0;
                        if(_S1596)
                        {
                            float3  _S1694 = safeDivide(_S1693, chain_throughput_0);
                            (&candidate_6)->radiance = _S1694;
                        }
                        else
                        {
                            if(_S1544)
                            {
                                candidate_6 = here_0;
                                uint _S1695 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1695;
                                (&candidate_6)->dir = light_2.dir;
                                (&candidate_6)->radiance = light_2.radiance;
                            }
                            else
                            {
                                uint _S1696 = insertBits_0(_S1388, b_6 + 1U, 5U, 5U);
                                uint _S1697 = insertBits_0(_S1696, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1697;
                            }
                        }
                        Reservoir _S1698 = withEnd(candidate_6, 0U, b_6, _S1693);
                        offer(sel_7, _S1698, _S1693 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1573)
                        {
                            _S1653 = false;
                        }
                        else
                        {
                            bool _S1699 = environmentMapped_0();
                            _S1653 = _S1699;
                        }
                    }
                    else
                    {
                        _S1653 = false;
                    }
                    if(_S1653)
                    {
                        uint _S1700 = (fcptMaxBounces());
                        _S1654 = b_6 < _S1700;
                    }
                    else
                    {
                        _S1654 = false;
                    }
                    if(_S1654)
                    {
                        uint _S1701 = noiseAddress(_S1386, b_6);
                        FKRay _S1702 = ray_2;
                        FKSurface _S1703 = surface_11;
                        ShadowContext _S1704 = context_5;
                        SkySample _S1705 = sampleSky_0(&_S1702, &_S1703, wavelength_9, _S1568, is_inside_6, _S1701, (&surface_11)->random_state, &_S1704);
                        float3  _S1706 = pathColor(throughput_6 * _S1705.color, spectral_weight_0, wavelength_9);
                        Reservoir candidate_7 = chain_0;
                        if(_S1596)
                        {
                            float3  _S1707 = safeDivide(_S1706, chain_throughput_0);
                            (&candidate_7)->radiance = _S1707;
                        }
                        else
                        {
                            if(_S1544)
                            {
                                candidate_7 = here_0;
                                uint _S1708 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1708;
                                (&candidate_7)->dir = _S1705.dir;
                                (&candidate_7)->radiance = _S1705.radiance;
                            }
                            else
                            {
                                uint _S1709 = insertBits_0(_S1388, b_6 + 1U, 5U, 5U);
                                uint _S1710 = insertBits_0(_S1709, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1710;
                            }
                        }
                        Reservoir _S1711 = withEnd(candidate_7, 4U, b_6, _S1706);
                        offer(sel_7, _S1711, _S1706 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_7 = throughput_6;
            density_4 = density_2;
        }
        bool _S1712;
        bool _S1713;
        bool _S1714;
        bool straight_0;
        bool _S1715;
        bool _S1716;
        bool _S1717;
        bool _S1718;
        bool _S1719;
        bool _S1720;
        bool _S1721;
        bool _S1722;
        bool _S1723;
        bool _S1724;
        bool _S1725;
        bool _S1726;
        bool _S1727;
        float density_6;
        float sky_pdf_2;
        float spread_4;
        uint b_9;
        float3  throughput_9;
        float3  throughput_10;
        float3  throughput_11;
        if(scatter_2)
        {
            if(replay_1)
            {
                viewed_1 = _S1610;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1728 = extractBits_0(_S1360, 15U, 3U);
            uint _S1729 = extractBits_0(_S1360, 18U, 3U);
            uint _S1730 = _slang_select(_S1609, _S1729,_S1728);
            float3  _S1731 = r_8->dir;
            bool refracted_5 = _S1730 == 1U;
            SampleBSDF _S1732 = SampleBSDF_x24init_0(_S1358, _S1358, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1732;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1733 = extractBits_0(_S1360, 22U, 1U);
                bool _S1734 = is_inside_6 != (_S1733 == 1U);
                if(_S1734)
                {
                    return _S1359;
                }
                bool _S1735 = _S1363 == 1U;
                if(_S1735)
                {
                    float3  _S1736 = (fcptHitPosition((_S1375)));
                    throughput_9 = _S1736;
                }
                else
                {
                    throughput_9 = reconnection_0;
                }
                if(refracted_5)
                {
                    refracted_4 = true;
                }
                else
                {
                    BSDFMaterial _S1737 = _S1567;
                    bool _S1738 = isTranslucent_0(&_S1737);
                    if(_S1738)
                    {
                        refracted_4 = _S1730 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1739 = (&surface_11)->smooth_n;
                        float3  _S1740 = throughput_9 - (&ray_2)->origin;
                        float3  _S1741 = _slang_select(_S1735, _S1740,_S1731);
                        wrong_side_0 = (dot_0(_S1739, _S1741) * _S1545) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1735)
                {
                    float3  _S1742 = (&ray_2)->origin;
                    float _S1743 = (&surface_11)->geometry_offset;
                    float3  _S1744 = (&surface_11)->smooth_n;
                    float3  _S1745 = - (&surface_11)->smooth_n;
                    bool _S1746 = is_inside_6 != refracted_4;
                    float3  _S1747 = _slang_select(_S1746, _S1745,_S1744);
                    float3  _S1748 = throughput_9 - (_S1742 + make_float3 (_S1743) * _S1747);
                    float3  _S1749 = ((((_S1748)) * make_float3(rnorm3df(((_S1748)).x, ((_S1748)).y, ((_S1748)).z))));
                    reconnection_1 = _S1749;
                }
                else
                {
                    reconnection_1 = _S1731;
                }
                if(_S1573)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1750 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, (&surface_11)->geometry_n);
                    wrong_side_0 = _S1750;
                }
                if(wrong_side_0)
                {
                    return _S1359;
                }
                float3  _S1751 = throughput_9;
                throughput_9 = reconnection_1;
                b_8 = _S1730;
                wrong_side_0 = false;
                reconnection_1 = _S1751;
            }
            else
            {
                bool _S1752 = !_S1609;
                if(_S1752)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1753;
                    if(_S1573)
                    {
                        SampleBSDF _S1754 = (fcptSampleHair(((&surface_11)->hair), (_S1567.albedo), (_S1567.specular_tint), ((&ray_2)->unit_direction), ((&surface_11)->random_state)));
                        _S1753 = _S1754;
                    }
                    else
                    {
                        SampleBSDF _S1755 = sampleBSDF((&ray_2)->unit_direction, (&surface_11)->smooth_n, _S1567, _S1568.x, _S1568.y, (&surface_11)->random_state);
                        _S1753 = _S1755;
                    }
                    bsdf_sampled_0 = _S1753;
                    if(_S1573)
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
                            return _S1359;
                        }
                        break;
                    }
                    if(_S1573)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1756 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, (&surface_11)->geometry_n);
                        wrong_side_0 = _S1756;
                    }
                    if(wrong_side_0)
                    {
                        _S1653 = (_S1567.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1653 = false;
                    }
                    if(_S1653)
                    {
                        SampleBSDF _S1757 = sampleBSDF((&bsdf_sampled_0)->unit_direction, (&surface_11)->geometry_n, _S1567, _S1568.x, _S1568.y, (&bsdf_sampled_0)->random_state);
                        (&bsdf_sampled_0)->unit_direction = _S1757.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1757.refracted;
                        (&bsdf_sampled_0)->throughput = _S1757.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1758 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, (&surface_11)->geometry_n)) * (&surface_11)->geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1758;
                        }
                    }
                    uint _S1759 = (&bsdf_sampled_0)->lobe;
                    float3  _S1760 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1761 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1762 = (&bsdf_sampled_0)->pdf;
                    float _S1763 = _slang_select(wrong_side_0, 0.0f,_S1762);
                    (&lobe_5)->pdf = _S1763;
                    throughput_9 = _S1760;
                    b_8 = _S1759;
                    refracted_4 = _S1761;
                }
                else
                {
                    throughput_9 = _S1731;
                    b_8 = _S1730;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1653 = true;
            }
            else
            {
                _S1653 = _S1609;
            }
            if(_S1653)
            {
                if(_S1573)
                {
                    SampleBSDF _S1764 = (fcptConnectHair(((&surface_11)->hair), (_S1567.albedo), (_S1567.specular_tint), ((&ray_2)->unit_direction), (throughput_9)));
                    lobe_5 = _S1764;
                }
                else
                {
                    if(b_8 == 4U)
                    {
                        b_9 = 3U;
                    }
                    else
                    {
                        if(b_8 == 6U)
                        {
                            b_9 = 4U;
                        }
                        else
                        {
                            b_9 = b_8;
                        }
                    }
                    float _S1765 = _S1568.x;
                    float _S1766 = _S1568.y;
                    bool _S1767 = wrongSide_0(is_inside_6, false, throughput_9, (&surface_11)->geometry_n);
                    FixedArray<float3 , 6>  throughputs_4;
                    FixedArray<float, 6>  pdfs_4;
                    float3  _S1768 = BSDF((&ray_2)->unit_direction, throughput_9, (&surface_11)->smooth_n, _S1567, _S1765, _S1766, _S1767, (&surface_11)->random_state, 1U << b_9, &throughputs_4, &pdfs_4);
                    bool _S1769 = (pdfs_4[b_9]) > 0.0f;
                    if(_S1769)
                    {
                        SampleBSDF _S1770 = SampleBSDF_x24init_0(throughput_9, throughputs_4[b_9], (&surface_11)->random_state, b_8 == 1U, b_8, pdfs_4[b_9]);
                        lobe_5 = _S1770;
                    }
                }
            }
            bool _S1771 = b_8 == 0U;
            if(_S1771)
            {
                _S1654 = true;
            }
            else
            {
                _S1654 = b_8 == 4U;
            }
            if(_S1654)
            {
                _S1712 = true;
            }
            else
            {
                _S1712 = b_8 == 6U;
            }
            bool _S1772 = b_8 == 5U;
            float _S1773 = _slang_select(_S1772, _S1567.coat_roughness,_S1567.roughness);
            if(_S1573)
            {
                _S1713 = false;
            }
            else
            {
                bool _S1774 = !_S1712;
                if(_S1774)
                {
                    bool _S1775 = _S1773 == 0.0f;
                    if(_S1775)
                    {
                        _S1713 = true;
                    }
                    else
                    {
                        bool _S1776 = b_8 == 1U;
                        if(_S1776)
                        {
                            _S1713 = (_S1568.x) == (_S1568.y);
                        }
                        else
                        {
                            _S1713 = false;
                        }
                    }
                }
                else
                {
                    _S1713 = false;
                }
            }
            bool _S1777 = !_S1573;
            if(_S1777)
            {
                _S1714 = b_8 == 1U;
            }
            else
            {
                _S1714 = false;
            }
            if(_S1714)
            {
                straight_0 = (_S1567.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1715 = _S1777;
            }
            else
            {
                _S1715 = false;
            }
            if(_S1715)
            {
                _S1716 = b_8 == 1U;
            }
            else
            {
                _S1716 = false;
            }
            if(_S1716)
            {
                _S1717 = (_S1568.x) == (_S1568.y);
            }
            else
            {
                _S1717 = false;
            }
            BSDFMaterial _S1778 = _S1567;
            bool _S1779 = isTranslucent_0(&_S1778);
            if(_S1779)
            {
                _S1718 = _S1771;
            }
            else
            {
                _S1718 = false;
            }
            if(_S1718)
            {
                _S1719 = (dot_0(throughput_9, (&surface_11)->geometry_n)) < 0.0f;
            }
            else
            {
                _S1719 = false;
            }
            if(nee_0)
            {
                _S1720 = !_S1713;
            }
            else
            {
                _S1720 = false;
            }
            if(_S1720)
            {
                _S1721 = !wrong_side_0;
            }
            else
            {
                _S1721 = false;
            }
            if(_S1721)
            {
                float _S1780 = (&lobe_5)->pdf;
                float3  _S1781 = (&ray_2)->origin;
                float3  _S1782 = (&surface_11)->smooth_n;
                float3  _S1783 = _slang_select(_S1577, _S1358,_S1782);
                float3  _S1784 = (&ray_2)->origin;
                float _S1785 = (&surface_11)->geometry_offset;
                float3  _S1786 = (&surface_11)->smooth_n;
                float3  _S1787 = - (&surface_11)->smooth_n;
                float3  _S1788 = _slang_select(_S1719, _S1787,_S1786);
                NEEVertex _S1789 = NEEVertex_x24init_0(false, _S1780, _S1781, _S1783, _S1784 + make_float3 (_S1785) * _S1788);
                nee_vertex_0 = _S1789;
            }
            else
            {
                if(_S1573)
                {
                    _S1722 = true;
                }
                else
                {
                    bool _S1790 = b_8 != 1U;
                    if(_S1790)
                    {
                        _S1722 = true;
                    }
                    else
                    {
                        _S1722 = (_S1568.x) != (_S1568.y);
                    }
                }
                if(_S1722)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1791 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1791)
            {
                if(_S1712)
                {
                    _S1722 = true;
                }
                else
                {
                    _S1722 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1722 = false;
            }
            bool _S1792 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1792)
            {
                if(_S1712)
                {
                    _S1723 = true;
                }
                else
                {
                    _S1723 = _S1773 >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1723 = false;
            }
            if(_S1609)
            {
                bool _S1793 = !_S1722;
                if(_S1793)
                {
                    return _S1359;
                }
                bool _S1794 = _S1364 != 1U;
                if(_S1794)
                {
                    _S1724 = _S1364 != 2U;
                }
                else
                {
                    _S1724 = false;
                }
                if(_S1724)
                {
                    float _S1795 = (&lobe_5)->pdf;
                    float _S1796 = _slang_select(nee_0, _S1795,0.0f);
                    float _S1797 = escapeWeight_0(_S1796, _S1731);
                    if(_S1617)
                    {
                        passes_0 = _S1370;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1798 = _slang_select(passes_0, _S1797,1.0f);
                    return Shift_x24init_0(throughput_7 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1798) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1799 = throughput_7 * make_float3 ((&lobe_5)->pdf);
                float _S1800 = density_4 * (&lobe_5)->pdf;
                throughput_10 = _S1799;
                density_6 = _S1800;
            }
            else
            {
                throughput_10 = throughput_7;
                density_6 = density_4;
            }
            uint _S1801 = (fcptLayers((hit_4)));
            bool _S1802 = _S1801 > 1U;
            if(_S1802)
            {
                _S1724 = (b_8 == 1U) != passes_0;
            }
            else
            {
                _S1724 = false;
            }
            if(viewed_1)
            {
                _S1725 = _S1724;
            }
            else
            {
                _S1725 = false;
            }
            if(_S1725)
            {
                return _S1359;
            }
            if(replay_1)
            {
                _S1726 = b_6 <= _S1374;
            }
            else
            {
                _S1726 = false;
            }
            if(_S1726)
            {
                _S1727 = _S1544;
            }
            else
            {
                _S1727 = false;
            }
            bool _S1803;
            if(_S1727)
            {
                _S1803 = _S1722;
            }
            else
            {
                _S1803 = false;
            }
            bool _S1804;
            if(_S1803)
            {
                _S1804 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1804 = !_S1723;
                }
                else
                {
                    _S1804 = false;
                }
            }
            if(_S1804)
            {
                return _S1359;
            }
            if(viewed_1)
            {
                float3  _S1805 = throughput_10 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1806 = (&lobe_5)->pdf;
                throughput_11 = _S1805;
                sky_pdf_2 = _S1806;
            }
            else
            {
                float3  _S1807 = throughput_10 * max_0((&lobe_5)->throughput, _S1358);
                throughput_11 = _S1807;
                sky_pdf_2 = density_6;
            }
            bool _S1808;
            if(_S1581)
            {
                _S1808 = !_S1596;
            }
            else
            {
                _S1808 = false;
            }
            bool _S1809;
            if(_S1808)
            {
                _S1809 = _S1544;
            }
            else
            {
                _S1809 = false;
            }
            bool _S1810;
            if(_S1809)
            {
                _S1810 = _S1722;
            }
            else
            {
                _S1810 = false;
            }
            float3  chain_throughput_1;
            if(_S1810)
            {
                chain_0 = here_0;
                uint _S1811 = insertBits_0((&chain_0)->path, b_8, 18U, 3U);
                uint _S1812 = _slang_select(nee_0, 1U,0U);
                uint _S1813 = insertBits_0(_S1811, _S1812, 21U, 1U);
                (&chain_0)->path = _S1813;
                float _S1814 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1814;
                (&chain_0)->dir = throughput_9;
                chain_throughput_1 = throughput_11;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            Vertex _S1815 = Vertex_x24init_0(_S1723, b_8, (&lobe_5)->pdf, (F32_abs((dot_0((&surface_11)->geometry_n, throughput_9)))), is_inside_6);
            prev_0 = _S1815;
            float _S1816 = (&lobe_5)->pdf;
            bool _S1817 = b_8 == 1U;
            bool _S1818;
            if(_S1817)
            {
                _S1818 = (_S1568.x) == (_S1568.y);
            }
            else
            {
                _S1818 = false;
            }
            float sky_pdf_3 = _slang_select(_S1818, sky_pdf_0,_S1816);
            float _S1819 = _slang_select(_S1573, 0.0f,sky_pdf_3);
            float _S1820 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1821 = !_S1713;
            float _S1822 = _slang_select(_S1821, _S1820,0.0f);
            float _S1823 = spread_1 + _S1822;
            bool _S1824;
            if(refracted_4)
            {
                _S1824 = !_S1719;
            }
            else
            {
                _S1824 = false;
            }
            bool is_inside_7;
            if(_S1824)
            {
                bool _S1825 = !is_inside_6;
                is_inside_7 = _S1825;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1826 = surface_11;
            bool _S1827 = boundsVolume_0(&_S1826);
            bool _S1828;
            if(_S1827)
            {
                _S1828 = !_S1724;
            }
            else
            {
                _S1828 = false;
            }
            if(_S1828)
            {
                FKSurface faced_2 = surface_11;
                float3  _S1829 = (&surface_11)->geometry_n;
                float3  _S1830 = - (&surface_11)->geometry_n;
                float3  _S1831 = _slang_select(turned_1, _S1830,_S1829);
                (&faced_2)->geometry_n = _S1831;
                FKMedium _S1832 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1833 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1834 = faced_2;
                FKMedium _S1835 = _S1832;
                FKMedium _S1836 = _S1833;
                MediumSides _S1837 = mediumSides_0(&_S1834, &_S1835, filling_2, (&ray_2)->unit_direction, &_S1836);
                bool _S1838 = ((dot_0(throughput_9, (&surface_11)->geometry_n)) > 0.0f) == ((dot_0((&surface_11)->geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1839 = _slang_select(_S1838, _S1837.front.scatter,_S1837.behind.scatter);
                scatter_in_0 = _S1839;
                float3  _S1840 = scatter_in_0;
                float _S1841 = upsample(scatter_in_0, wavelength_9);
                float3  _S1842 = make_float3 (_S1841);
                float3  _S1843 = _slang_select(_S1604, _S1842,_S1840);
                scatter_in_0 = _S1843;
                float3  _S1844 = _slang_select(_S1838, _S1837.front.extinction,_S1837.behind.extinction);
                extinction_in_0 = _S1844;
                float3  _S1845 = extinction_in_0;
                float _S1846 = upsample(extinction_in_0, wavelength_9);
                float3  _S1847 = make_float3 (_S1846);
                float3  _S1848 = _slang_select(_S1604, _S1847,_S1845);
                extinction_in_0 = _S1848;
                float _S1849 = _slang_select(_S1838, _S1837.front.g,_S1837.behind.g);
                g_in_0 = _S1849;
                uint _S1850 = _S1837.fillings.x;
                uint _S1851 = _S1837.fillings.y;
                uint _S1852 = _slang_select(_S1838, _S1851,_S1850);
                bool _S1853 = (fcptVaryingUsed());
                uint _S1854 = _slang_select(_S1853, _S1852,4294967295U);
                filling_2 = _S1854;
            }
            (&ray_2)->unit_direction = throughput_9;
            bool _S1855 = !_S1724;
            if(_S1855)
            {
                float _S1856 = (&surface_11)->geometry_offset;
                float _S1857 = _slang_select(straight_0, 0.0f,_S1856);
                float3  _S1858 = (&surface_11)->smooth_n;
                float3  _S1859 = - (&surface_11)->smooth_n;
                bool _S1860 = is_inside_7 != _S1719;
                float3  _S1861 = _slang_select(_S1860, _S1859,_S1858);
                float3  _S1862 = (&ray_2)->origin + make_float3 (_S1857) * _S1861;
                (&ray_2)->origin = _S1862;
            }
            throughput_10 = throughput_11;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1724;
            viewed_1 = _S1717;
            sky_pdf_2 = _S1819;
            spread_4 = _S1823;
            reconnection_0 = reconnection_1;
            is_inside_5 = is_inside_7;
        }
        else
        {
            (&prev_0)->rough = false;
            (&prev_0)->pdf = 0.0f;
            throughput_10 = throughput_7;
            density_6 = density_4;
            passes_0 = false;
            viewed_1 = viewed_0;
            sky_pdf_2 = 0.0f;
            spread_4 = spread_1;
            straight_0 = false;
            is_inside_5 = is_inside_6;
        }
        float density_7;
        if(_S1581)
        {
            if(_S1507)
            {
                float3  _S1863 = pathColor(throughput_10 * emission_1, spectral_weight_0, wavelength_9);
                Reservoir candidate_8 = chain_0;
                uint _S1864 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1865 = _S1864 == 1U;
                if(_S1865)
                {
                    float3  _S1866 = safeDivide(_S1863, chain_throughput_0);
                    (&candidate_8)->radiance = _S1866;
                }
                Reservoir _S1867 = withEnd(candidate_8, 2U, b_6, _S1863);
                offer(sel_7, _S1867, _S1863 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1507)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1868 = survivalProbability(abs_0(throughput_10), density_6);
                density_7 = _S1868;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1869 = noiseAddress(_S1386, b_6);
            Random _S1870 = draw(_S1869, 8U);
            bool _S1871 = density_7 < (_S1870.value);
            if(_S1871)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1872 = (fcptMaxBounces());
                wrong_side_0 = b_6 >= _S1872;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1873 = density_6 * density_7;
            density_7 = _S1873;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1874 = layer_0 ^ 1U;
        uint _S1875 = _slang_select(passes_0, _S1874,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_4)->distance = 0.0f;
            b_8 = b_6;
            viewed_0 = viewed_1;
            throughput_2 = throughput_10;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_1 = spread_4;
            uint _S1876 = b_8 + 1U;
            b_6 = _S1876;
            layer_0 = _S1875;
            continue;
        }
        FKRay _S1877 = ray_2;
        float _S1878 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S1610;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1363 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1879 = _slang_select(wrong_side_0, _S1878,4.294967296e+09f);
        bool _S1880 = !_S1573;
        if(straight_0)
        {
            _S1653 = true;
        }
        else
        {
            _S1653 = _S1573;
        }
        FKHit _S1881;
        if(_S1653)
        {
            _S1881 = hit_4;
        }
        else
        {
            _S1881 = _S1626;
        }
        FKHit _S1882 = (fcptTraverseInstanceBVH((_S1877), (_S1514), (_S1879), (_S1880), (_S1881), (viewed_1)));
        hit_4 = _S1882;
        if(replay_1)
        {
            _S1654 = _S1610;
        }
        else
        {
            _S1654 = false;
        }
        if(_S1654)
        {
            _S1712 = _S1363 == 1U;
        }
        else
        {
            _S1712 = false;
        }
        if(_S1712)
        {
            _S1713 = ((&hit_4)->instance_index) == (_S1375.instance_index);
        }
        else
        {
            _S1713 = false;
        }
        if(_S1713)
        {
            _S1714 = ((&hit_4)->triangle_index) == (_S1375.triangle_index);
        }
        else
        {
            _S1714 = false;
        }
        if(_S1714)
        {
            (&hit_4)->uv = _S1375.uv;
            float _S1883 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1883;
        }
        if(replay_1)
        {
            _S1715 = _S1610;
        }
        else
        {
            _S1715 = false;
        }
        if(_S1715)
        {
            _S1716 = _S1363 == 3U;
        }
        else
        {
            _S1716 = false;
        }
        if(_S1716)
        {
            _S1717 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1717 = false;
        }
        if(_S1717)
        {
            return _S1359;
        }
        Reservoir _S1884 = chain_0;
        uint _S1885 = filling_2;
        for(;;)
        {
            bool _S1886 = (fcptVaryingUsed());
            if(_S1886)
            {
                _S1718 = _S1885 != 4294967295U;
            }
            else
            {
                _S1718 = false;
            }
            float _S1887;
            if(_S1718)
            {
                float _S1888 = (fcptMajorant((_S1885)));
                _S1887 = _S1888;
            }
            else
            {
                _S1887 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1719 = _S1610;
            }
            else
            {
                _S1719 = false;
            }
            if(_S1719)
            {
                _S1720 = _S1363 == 1U;
            }
            else
            {
                _S1720 = false;
            }
            if(_S1720)
            {
                _S1721 = _S1887 > 0.0f;
            }
            else
            {
                _S1721 = false;
            }
            if(_S1721)
            {
                ended_0 = _S1359;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_4 = width_3;
                density_3 = density_7;
                throughput_11 = throughput_10;
                b_8 = b_6;
                _S1722 = true;
                break;
            }
            bool _S1889 = (&prev_0)->rough;
            if(_S1889)
            {
                _S1722 = !(_S1887 > 0.0f);
            }
            else
            {
                _S1722 = false;
            }
            (&prev_0)->rough = _S1722;
            uint _S1890 = b_6 + 320U;
            bool _S1891 = b_6 == 4294967295U;
            uint _S1892 = _slang_select(_S1891, 384U,_S1890);
            uint _S1893 = stream(_S1386, _S1892);
            uint tracking_1 = _S1893;
            weight_2 = throughput_3;
            glowed_0 = _S1358;
            b_8 = b_6;
            throughput_11 = throughput_10;
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
                    _S1357 = int(2);
                    break;
                }
                uint _S1894 = noiseAddress(_S1386, b_8);
                Random _S1895 = draw(_S1894, 10U);
                float _S1896 = - (F32_log((1.0f - _S1895.value))) / _S1887;
                if(_S1718)
                {
                    float3  _S1897 = (&ray_2)->origin;
                    float3  _S1898 = (&ray_2)->unit_direction;
                    float _S1899 = (&hit_4)->distance;
                    bool _S1900 = b_8 == 4294967295U;
                    uint _S1901 = _slang_select(_S1900, 0U,b_8);
                    uint _S1902 = (&prev_0)->lobe;
                    uint _S1903 = _slang_select(_S1900, 3U,_S1902);
                    float _S1904 = (fcptTrackMedium((_S1885), (_S1897), (_S1898), (_S1899), (&tracking_1), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1901), (_S1903), (_S1900)));
                    spread_3 = _S1904;
                }
                else
                {
                    spread_3 = _S1896;
                }
                bool _S1905 = !(spread_3 < ((&hit_4)->distance));
                if(_S1905)
                {
                    _S1357 = int(2);
                    break;
                }
                if(_S1718)
                {
                    _S1723 = _S1581;
                }
                else
                {
                    _S1723 = false;
                }
                if(_S1723)
                {
                    float3  _S1906 = pathColor(throughput_11 * glowed_0, spectral_weight_0, wavelength_9);
                    float3  _S1907 = _S1906 / make_float3 (density_3);
                    float3  _S1908 = sel_7->glow + _S1907;
                    sel_7->glow = _S1908;
                }
                else
                {
                }
                glowed_0 = _S1358;
                uint b_10 = b_8 + 1U;
                float3  _S1909 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1909;
                float3  _S1910 = flightWeight_0(scatter_in_0, extinction_in_0, _S1887, spread_3, true);
                float3  _S1911 = weight_2;
                float _S1912 = upsample(weight_2, wavelength_9);
                float3  _S1913 = make_float3 (_S1912);
                float3  _S1914 = _slang_select(_S1604, _S1913,_S1911);
                float3  _S1915 = _slang_select(_S1718, _S1914,_S1910);
                float3  throughput_12 = throughput_11 * _S1915;
                uint _S1916 = stream(_S1386, b_10 + 320U);
                tracking_1 = _S1916;
                weight_2 = throughput_3;
                float width_7 = width_4 + spread_2 * spread_3;
                float _S1917 = spread_2 + 3.14159274101257324f;
                if(_S1581)
                {
                    _S1724 = true;
                }
                else
                {
                    bool _S1918 = b_10 == _S1374;
                    if(_S1918)
                    {
                        _S1724 = !_S1718;
                    }
                    else
                    {
                        _S1724 = false;
                    }
                }
                TreeSample light_3;
                if(_S1724)
                {
                    float3  _S1919 = (&ray_2)->origin;
                    float3  _S1920 = (&ray_2)->unit_direction;
                    float3  _S1921 = (&ray_2)->unit_direction;
                    uint _S1922 = noiseAddress(_S1386, b_10);
                    float3  _S1923 = extinction_in_0;
                    float3  _S1924 = extinction_in_0;
                    uint2  _S1925 = make_uint2 (_S1885);
                    float3  _S1926 = (&ray_2)->unit_direction;
                    uint _S1927 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                    FKHit _S1928 = _S1626;
                    ShadowContext _S1929 = ShadowContext_x24init_0(_S1923, _S1924, _S1925, _S1926, b_10, _S1927, false, spread_3, width_7, &_S1928, false);
                    ShadowContext _S1930 = _S1929;
                    TreeSample _S1931 = sampleLightTree_0(_S1919, _S1920, _S1921, 0.0f, true, _S1922, &_S1930);
                    light_3 = _S1931;
                }
                else
                {
                    light_3 = _S1624;
                }
                float _S1932 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
                uint _S1933 = (fcptMaxBounces());
                bool _S1934 = b_10 < _S1933;
                if(_S1934)
                {
                    _S1725 = (light_3.density) > 0.0f;
                }
                else
                {
                    _S1725 = false;
                }
                float _S1935 = _slang_select(_S1725, _S1932,0.0f);
                float3  _S1936 = throughput_12 * light_3.radiance;
                float _S1937 = powerHeuristic(light_3.density, _S1935);
                float3  _S1938 = pathColor(_S1936 * make_float3 (_S1932 * _S1937), spectral_weight_0, wavelength_9);
                float3  _S1939 = _slang_select(_S1724, _S1938,_S1358);
                if(replay_1)
                {
                    _S1726 = b_10 == _S1374;
                }
                else
                {
                    _S1726 = false;
                }
                if(_S1726)
                {
                    bool _S1940 = _S1363 == 2U;
                    if(_S1940)
                    {
                        float _S1941 = resamplingTarget(_S1939);
                        _S1727 = _S1941 > 0.0f;
                    }
                    else
                    {
                        _S1727 = false;
                    }
                    if(_S1727)
                    {
                        Shift _S1942 = Shift_x24init_0(_S1939, 1.0f);
                        _S1357 = int(1);
                        ended_0 = _S1942;
                        spread_3 = _S1917;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_9 = b_10;
                        break;
                    }
                    _S1357 = int(1);
                    ended_0 = _S1359;
                    spread_3 = _S1917;
                    width_5 = width_7;
                    throughput_9 = throughput_12;
                    b_9 = b_10;
                    break;
                }
                if(_S1581)
                {
                    Reservoir candidate_9 = _S1884;
                    uint _S1943 = extractBits_0(_S1884.path, 24U, 8U);
                    uint _S1944 = insertBits_0(0U, _S1943, 24U, 8U);
                    uint _S1945 = extractBits_0(_S1884.path, 10U, 2U);
                    bool _S1946 = _S1945 == 1U;
                    if(_S1946)
                    {
                        float3  _S1947 = safeDivide(_S1939, chain_throughput_0);
                        (&candidate_9)->radiance = _S1947;
                    }
                    else
                    {
                        uint _S1948 = insertBits_0(_S1944, b_10 + 1U, 5U, 5U);
                        uint _S1949 = insertBits_0(_S1948, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1949;
                    }
                    Reservoir _S1950 = withEnd(candidate_9, 0U, b_10, _S1939);
                    offer(sel_7, _S1950, _S1939 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1951 = survivalProbability(abs_0(throughput_12), density_3);
                    uint _S1952 = noiseAddress(_S1386, b_10);
                    Random _S1953 = draw(_S1952, 8U);
                    bool _S1954 = _S1951 < (_S1953.value);
                    if(_S1954)
                    {
                        _S1727 = true;
                    }
                    else
                    {
                        uint _S1955 = (fcptMaxBounces());
                        _S1727 = b_10 >= _S1955;
                    }
                    if(_S1727)
                    {
                        _S1357 = int(1);
                        ended_0 = _S1359;
                        spread_3 = _S1917;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_9 = b_10;
                        break;
                    }
                    float _S1956 = density_3 * _S1951;
                    density_3 = _S1956;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1957 = noiseAddress(_S1386, b_10);
                float3  _S1958 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1957, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1958;
                NEEVertex _S1959 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1358, (&ray_2)->origin);
                nee_vertex_0 = _S1959;
                Vertex _S1960 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
                prev_0 = _S1960;
                float _S1961 = (&prev_0)->pdf;
                FKRay _S1962 = ray_2;
                FKHit _S1963 = (fcptTraverseInstanceBVH((_S1962), (true), (4.294967296e+09f), (false), (_S1626), (false)));
                hit_4 = _S1963;
                b_8 = b_10;
                throughput_11 = throughput_12;
                spread_2 = _S1917;
                width_4 = width_7;
                sky_pdf_1 = _S1961;
            }
            if(_S1357 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_11 = throughput_9;
                b_8 = b_9;
                _S1722 = true;
                break;
            }
            ended_0 = _S1359;
            _S1722 = false;
            break;
        }
        if(_S1722)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1723 = b_8 == b_6;
        }
        else
        {
            _S1723 = false;
        }
        bool _S1964 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1964)
        {
            bool _S1965 = !(&nee_vertex_0)->none;
            float _S1966 = _slang_select(_S1965, sky_pdf_1,0.0f);
            float _S1967 = escapeWeight_0(_S1966, (&ray_2)->unit_direction);
            float3  _S1968 = environment_0((&ray_2)->unit_direction, b_8, (&prev_0)->lobe);
            float3  _S1969 = pathColor(throughput_11 * _S1968, spectral_weight_0, wavelength_9);
            if(replay_1)
            {
                bool _S1970 = b_8 == _S1374;
                if(_S1970)
                {
                    passes_0 = _S1363 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1969 * make_float3 (_S1967) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1373)
                {
                    passes_0 = _S1370;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_8 == _S1361;
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
                    return Shift_x24init_0(_S1969 * make_float3 (_S1967), 1.0f);
                }
                return _S1359;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1971 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1972 = _S1971 == 1U;
            if(_S1972)
            {
                uint _S1973 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1974 = _S1973 == b_8;
                float _S1975 = _slang_select(_S1974, 1.0f,_S1967);
                float3  _S1976 = safeDivide(_S1969 * make_float3 (_S1975), chain_throughput_0);
                (&candidate_10)->radiance = _S1976;
            }
            else
            {
                bool _S1977 = (&prev_0)->rough;
                if(_S1977)
                {
                    uint _S1978 = insertBits_0(_S1388, b_8 + 1U, 5U, 5U);
                    uint _S1979 = insertBits_0(_S1978, 3U, 10U, 2U);
                    uint _S1980 = insertBits_0(_S1979, (&prev_0)->lobe, 15U, 3U);
                    bool _S1981 = (&prev_0)->inside;
                    uint _S1982 = _slang_select(_S1981, 1U,0U);
                    uint _S1983 = insertBits_0(_S1980, _S1982, 22U, 1U);
                    (&candidate_10)->path = _S1983;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1984 = _S1969 * make_float3 (_S1967);
            Reservoir _S1985 = withEnd(candidate_10, 3U, b_8, _S1984);
            offer(sel_7, _S1985, _S1984 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1986 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1986;
        bool _S1987 = (fcptVaryingUsed());
        if(_S1987)
        {
            _S1724 = filling_2 != 4294967295U;
        }
        else
        {
            _S1724 = false;
        }
        if(_S1724)
        {
            if(_S1581)
            {
                float3  _S1988 = pathColor(throughput_11 * glowed_0, spectral_weight_0, wavelength_9);
                float3  _S1989 = _S1988 / make_float3 (density_3);
                float3  _S1990 = sel_7->glow + _S1989;
                sel_7->glow = _S1990;
            }
            float3  _S1991 = throughput_11 * weight_2;
            throughput_9 = _S1991;
        }
        else
        {
            float3  _S1992 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1993 = throughput_11 * _S1992;
            throughput_9 = _S1993;
        }
        float _S1994 = width_4 + spread_2 * (&hit_4)->distance;
        viewed_0 = _S1723;
        width_3 = _S1994;
        throughput_2 = throughput_9;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1876 = b_8 + 1U;
        b_6 = _S1876;
        layer_0 = _S1875;
    }
    return _S1359;
}

__device__ static const FixedArray<float, 4>  HAIR_TILTS_0 = { {
    -2.0f, 1.0f, 4.0f, 0.0f
} };
__device__ static const FixedArray<float, 4>  HAIR_WIDTHS_0 = { {
    1.0f, 0.5f, 2.0f, 2.0f
} };
static __device__ float3  clamp_2(float3  x_26, float3  minBound_2, float3  maxBound_2)
{
    return min_1(max_0(x_26, minBound_2), maxBound_2);
}

static __device__ float3  tan_0(float3  x_27)
{
    float3  result_15;
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
        *_slang_vector_get_element_ptr(&result_15, i_28) = (F32_tan((_slang_vector_get_element(x_27, i_28))));
        i_28 = i_28 + int(1);
    }
    return result_15;
}

static __device__ float3  acos_0(float3  x_28)
{
    float3  result_16;
    int i_29 = int(0);
    for(;;)
    {
        if(i_29 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_16, i_29) = (F32_acos((_slang_vector_get_element(x_28, i_29))));
        i_29 = i_29 + int(1);
    }
    return result_16;
}

__device__ Random normal_distribution(uint state_5)
{
    Random _S1995 = pcg(state_5);
    Random _S1996 = pcg(_S1995.state);
    float _S1997 = 6.28318548202514648f * _S1995.value;
    float _S1998 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1996.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1996.state, _S1998 * (F32_cos((_S1997))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_6, float3  value_2)
{
    RandomSphere _S1999;
    (&_S1999)->state = state_6;
    (&_S1999)->value = value_2;
    return _S1999;
}

__device__ RandomSphere random_sphere(uint state_7)
{
    Random _S2000 = normal_distribution(state_7);
    Random _S2001 = normal_distribution(_S2000.state);
    Random _S2002 = normal_distribution(_S2001.state);
    float3  _S2003 = make_float3 (_S2000.value, _S2001.value, _S2002.value);
    float3  _S2004 = ((((_S2003)) * make_float3(rnorm3df(((_S2003)).x, ((_S2003)).y, ((_S2003)).z))));
    return RandomSphere_x24init_0(_S2002.state, _S2004);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_12)
{
    float3  _S2005 = p1_0 - p0_0;
    float3  _S2006 = p2_0 - p0_0;
    float2  _S2007 = uv1_0 - uv0_0;
    float2  _S2008 = uv2_0 - uv0_0;
    float _S2009 = _S2007.x;
    float _S2010 = _S2008.y;
    float _S2011 = _S2007.y;
    float _S2012 = _S2008.x;
    float _S2013 = _S2009 * _S2010 - _S2011 * _S2012;
    float _S2014 = 1.0f / _S2013;
    float3  t_24 = (_S2005 * make_float3 (_S2010) - _S2006 * make_float3 (_S2011)) * make_float3 (_S2014);
    float3  _S2015 = (_S2006 * make_float3 (_S2009) - _S2005 * make_float3 (_S2012)) * make_float3 (_S2014);
    float3  _S2016 = t_24 - n_12 * make_float3 (dot_0(n_12, t_24));
    float3  t_25 = ((((_S2016)) * make_float3(rnorm3df(((_S2016)).x, ((_S2016)).y, ((_S2016)).z))));
    bool _S2017 = (dot_0(cross_0(n_12, t_25), _S2015)) > 0.0f;
    float3  t_26;
    if(_S2017)
    {
        float3  _S2018 = negate_0(t_25);
        t_26 = _S2018;
    }
    else
    {
        t_26 = t_25;
    }
    float3  _S2019 = cross_0(n_12, t_26);
    return makeMatrix<float, 3, 3> (t_26, _S2019, n_12);
}

__device__ float3  tangentToWorldNormalMap(float3  v_13, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_13, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_3, float3  uvw_0, float3  position_0)
{
    float3  _S2020 = t1_0 - t0_0;
    float3  _S2021 = t2_2 - t0_0;
    float3  _S2022 = t2_2 - t1_0;
    float _S2023 = (F32_min((length_0(_S2020)), ((F32_min((length_0(_S2021)), (length_0(_S2022)))))));
    float3  _S2024 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S2025 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S2026 = dot_0(geometry_n_3, _S2025);
    float3  _S2027 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S2028 = dot_0(geometry_n_3, _S2027);
    float3  _S2029 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S2030 = acos_0(abs_0(make_float3 (_S2026, _S2028, dot_0(geometry_n_3, _S2029))));
    float3  _S2031 = clamp_2(tan_0(_S2030), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S2024 * _S2031, uvw_0), 0.0f, _S2023 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_14, float3  n_13, BSDFMaterial material_27)
{
    float3  _S2032 = negate_0(dir_14);
    float _S2033 = sign_0(dot_0(n_13, _S2032));
    float3  _S2034 = n_13 * make_float3 (_S2033);
    AnisotropicFrame _S2035 = anisotropicFrame(material_27, _S2034);
    bool _S2036 = (_S2035.alphas.x) > 0.0f;
    if(_S2036)
    {
        float _S2037 = material_27.transmission * (1.0f - material_27.metallic);
        float3  _S2038 = negate_0(_S2034);
        float3  _S2039 = anisotropicLocal(dir_14, _S2035.tangent, _S2038);
        float _S2040 = anisotropicG1(_S2039, _S2035.alphas);
        return make_float3 (_S2037 * _S2040) * material_27.albedo;
    }
    float _S2041 = material_27.transmission * (1.0f - material_27.metallic);
    float _S2042 = material_27.roughness;
    float _S2043 = smithG1(_S2042 * _S2042, (F32_abs((dot_0(n_13, dir_14)))));
    return make_float3 (_S2041 * _S2043) * material_27.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_27, float3  out_dir_3, uint p_15, float w_21, float alpha_11, uint nt_0)
{
    uint _S2044 = p_15 % 4U;
    float _S2045 = w_21 * HAIR_WIDTHS_0[_S2044];
    float _S2046 = (F32_asin((clamp_1(dot_0(out_dir_3, t_27), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_27), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S2044] * alpha_11;
    return ((F32_asinh((_S2046 / _S2045))) / (F32_asinh((3.14159274101257324f / _S2045))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_28, float3  out_dir_4, uint np_0)
{
    float3  _S2047 = worldToTangent(out_dir_4, t_28);
    float3  _S2048 = worldToTangent(in_dir_12, t_28);
    return (F32_frac((((F32_atan2((_S2047.z), (_S2047.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S2048.z), (1.17549435082228751e-38f - _S2048.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_29, uint p_16, float row_0, float column_0, float w_22, float alpha_12, uint nt_1, uint np_1)
{
    float3  _S2049 = worldToTangent(in_dir_13, t_29);
    uint _S2050 = p_16 % 4U;
    float _S2051 = w_22 * HAIR_WIDTHS_0[_S2050];
    float _S2052 = (F32_asin((clamp_1(dot_0(in_dir_13, t_29), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S2050] * alpha_12 + _S2051 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S2051))))));
    float _S2053 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S2049.z), (1.17549435082228751e-38f - _S2049.x)));
    float _S2054 = (F32_cos((_S2052)));
    float3  _S2055 = tangentToWorld(make_float3 (_S2054 * (F32_cos((_S2053))), (F32_sin((_S2052))), _S2054 * (F32_sin((_S2053)))), t_29);
    return _S2055;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_14, BSDFMaterial material_28, float coverage_1)
{
    float3  through_2;
    if((material_28.ior) == 1.0f)
    {
        float3  _S2056 = straightThrough(toward_1, n_14, material_28);
        through_2 = _S2056;
    }
    else
    {
        through_2 = make_float3 (0.0f);
    }
    bool _S2057 = (material_28.coat) > 0.0f;
    if(_S2057)
    {
        CoatFrame _S2058 = coatFrame(material_28, n_14);
        float _S2059 = fresnel((F32_abs((dot_0(_S2058.normal, toward_1)))), 1.0f, _S2058.ior);
        float3  _S2060 = mix_0(make_float3 (1.0f), make_float3 (1.0f - _S2059) * material_28.coat_tint, material_28.coat);
        float3  through_3 = through_2 * _S2060;
        through_2 = through_3;
    }
    return through_2 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_8, Reservoir r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    Domain _S2061 = dom_8;
    Reservoir _S2062 = r_9;
    Shift _S2063 = walk_0(&_S2061, &_S2062, replay_2, scale_4, sel_8);
    return _S2063;
}

__device__ Shift shift_hook(Domain dom_9, Reservoir r_10)
{
    Domain _S2064 = dom_9;
    Reservoir _S2065 = r_10;
    Shift _S2066 = shift_0(&_S2064, &_S2065);
    return _S2066;
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

__device__ uint noiseWhite(uint x_29, uint y_8, uint t_30, uint size_0)
{
    FixedArray<uint, 4>  ranks_0;
    uint i_30 = 0U;
    for(;;)
    {
        if(i_30 < 4U)
        {
        }
        else
        {
            break;
        }
        uint _S2067;
        if(i_30 < 2U)
        {
            _S2067 = x_29;
        }
        else
        {
            _S2067 = (x_29 + size_0 / 2U) & (size_0 - 1U);
        }
        uint l_6 = _S2067;
        uint r_11 = y_8;
        uint k_4 = 0U;
        for(;;)
        {
            if(k_4 < 4U)
            {
            }
            else
            {
                break;
            }
            uint _S2068 = hash(((r_11 ^ (t_30 << 16U)) ^ (k_4 << 28U)) ^ ((i_30 & 1U) << 31U));
            uint _S2069 = l_6 ^ (_S2068 & (size_0 - 1U));
            uint k_5 = k_4 + 1U;
            l_6 = r_11;
            r_11 = _S2069;
            k_4 = k_5;
        }
        uint _S2070 = l_6 + r_11 * size_0;
        uint _S2071 = size_0 * size_0;
        uint _S2072;
        if(_S2071 >= 65536U)
        {
            uint _S2073 = _S2070 / (_S2071 / 65536U);
            _S2072 = _S2073;
        }
        else
        {
            uint _S2074 = 65536U / _S2071;
            _S2072 = _S2070 * _S2074;
        }
        ranks_0[i_30] = _S2072;
        uint i_31 = i_30 + 1U;
        i_30 = i_31;
    }
    bool _S2075 = (ranks_0[int(0)]) == 65535U;
    bool _S2076;
    if(_S2075)
    {
        _S2076 = (ranks_0[int(1)]) == 65535U;
    }
    else
    {
        _S2076 = false;
    }
    bool _S2077 = (ranks_0[int(2)]) == 65535U;
    bool _S2078;
    if(_S2077)
    {
        _S2078 = (ranks_0[int(3)]) == 65535U;
    }
    else
    {
        _S2078 = false;
    }
    if(_S2076)
    {
        _S2076 = (ranks_0[int(3)]) != 65535U;
    }
    else
    {
        _S2076 = false;
    }
    if(_S2076)
    {
        _S2076 = true;
    }
    else
    {
        if(_S2078)
        {
            _S2076 = (ranks_0[int(1)]) != 65535U;
        }
        else
        {
            _S2076 = false;
        }
    }
    uint _S2079 = ranks_0[int(0)];
    if(_S2076)
    {
        i_30 = ranks_0[int(3)];
    }
    else
    {
        i_30 = ranks_0[int(1)];
    }
    return _S2079 | (i_30 << 16U);
}

#undef Matrix
