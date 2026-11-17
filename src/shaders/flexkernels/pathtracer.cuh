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
    Shift _S110;
    (&_S110)->f = f_0;
    (&_S110)->jac = jac_0;
    return _S110;
}

static __device__ Shift passWalk_0(Domain * dom_0, Reservoir * r_1, bool replay_0, float scale_0, Selection * sel_0)
{
    Shift _S111 = (fcptWalk((*dom_0), (*r_1), (replay_0), (scale_0), (sel_0)));
    return _S111;
}

static __device__ Shift passShift_0(Domain * dom_1, Reservoir * r_2)
{
    Selection _S112 = (Selection{});
    Selection sel_1 = _S112;
    bool _S113 = (r_2->w) <= 0.0f;
    if(_S113)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S114 = passWalk_0(dom_1, r_2, true, 0.0f, &sel_1);
    return _S114;
}

static __device__ bool previousValid_0(int2  q_2)
{
    bool _S115 = all_0(q_2 >= make_int2 (int(0)));
    bool _S116;
    if(_S115)
    {
        uint2  _S117 = (fcptRenderSize());
        int2  _S118 = make_int2 ((int)_S117.x, (int)_S117.y);
        _S116 = all_0(q_2 < _S118);
    }
    else
    {
        _S116 = false;
    }
    if(_S116)
    {
        uint4  _S119 = (fcptReservoirPrevious((q_2), (0U)));
        _S116 = (U32_asfloat((_S119.w))) > 0.0f;
    }
    else
    {
        _S116 = false;
    }
    return _S116;
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

static __device__ int2  temporalNeighbor_0(int2  p_6, Domain * dom_2, uint seed_1)
{
    bool _S120 = previousValid_0(p_6);
    bool _S121;
    if(_S120)
    {
        Domain _S122 = (fcptPreviousDomain((p_6), (seed_1)));
        Domain _S123 = _S122;
        bool _S124 = sameDomain_0(&_S123, dom_2);
        _S121 = _S124;
    }
    else
    {
        _S121 = false;
    }
    if(_S121)
    {
        return p_6;
    }
    uint _S125 = (&dom_2->hit)->instance_index;
    bool _S126 = ((&dom_2->hit)->instance_index) == 4294967295U;
    if(_S126)
    {
        return make_int2 (int(-1));
    }
    float3  _S127 = dom_2->x1;
    float2  _S128 = (fcptPixelOf((dom_2->x1), (true)));
    float2  _S129 = floor_0(_S128);
    int2  _S130 = make_int2 ((int)_S129.x, (int)_S129.y);
    bool _S131 = previousValid_0(_S130);
    bool _S132 = !_S131;
    if(_S132)
    {
        return make_int2 (int(-1));
    }
    uint4  _S133 = (fcptReservoirPrevious((_S130), (0U)));
    Domain _S134 = (fcptPreviousDomain((_S130), (_S133.x)));
    bool _S135 = (_S134.hit.instance_index) == _S125;
    if(_S135)
    {
        float _S136 = distance_1(_S134.x1, _S127);
        float _S137 = (&dom_2->hit)->distance * 8.0f;
        uint2  _S138 = (fcptRenderSize());
        _S121 = _S136 <= (_S137 / float(_S138.x));
    }
    else
    {
        _S121 = false;
    }
    if(_S121)
    {
        return _S130;
    }
    int2  _S139 = p_6 + _S130;
    float2  _S140 = make_float2 ((float)_S139.x, (float)_S139.y);
    float2  _S141 = _S140 + make_float2 (1.0f);
    float2  _S142 = (fcptPixelOf((_S134.x1), (false)));
    float2  _S143 = floor_0(_S141 - _S142);
    int2  _S144 = make_int2 ((int)_S143.x, (int)_S143.y);
    int2  _S145 = make_int2 (int(-1));
    bool _S146 = previousValid_0(_S144);
    int2  _S147 = _slang_select(_S146, _S144,_S145);
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
        Shift _S155 = passShift_0(&_S153, &_S154);
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
    float3  _S178 = (fcptEnvMapSample((dir_1), (0U), (3U)));
    float3  _S179 = context_0->extinction_behind;
    float3  _S180 = context_0->extinction_front;
    float3  _S181 = _slang_select(_S177, _S180,_S179);
    uint _S182 = context_0->fillings.x;
    uint _S183 = context_0->fillings.y;
    uint _S184 = _slang_select(_S177, _S183,_S182);
    uint _S185 = context_0->depth;
    uint _S186 = context_0->lobe;
    bool _S187 = context_0->surface;
    bool _S188;
    if(_S187)
    {
        _S188 = !context_0->fiber;
    }
    else
    {
        _S188 = false;
    }
    float _S189 = context_0->length;
    float _S190 = context_0->width;
    FKHit _S191 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    float3  _S192 = (fcptShadowTransmittanceIn((_S176), (4.294967296e+09f), (_S181), (_S184), (random_state_0), (_S185), (_S186), (_S188), (_S189), (_S190), (_S191), (_S191)));
    return _S178 * _S192;
}

static __device__ uint searchCDF_0(uint2  start_4, uint2  step_0, uint count_1, float u_0)
{
    uint _S193 = count_1 - 1U;
    uint low_0 = 0U;
    uint high_0 = _S193;
    for(;;)
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        uint _S194 = (low_0 + high_0) / 2U;
        float4  _S195 = (fcptEnvironmentCdf((start_4 + step_0 * make_uint2 (_S194))));
        bool _S196 = (_S195.x) > u_0;
        if(_S196)
        {
            high_0 = _S194;
        }
        else
        {
            uint _S197 = _S194 + 1U;
            low_0 = _S197;
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
    float3  _S198 = ((((light_dir_0)) * make_float3(rnorm3df(((light_dir_0)).x, ((light_dir_0)).y, ((light_dir_0)).z))));
    bool _S199 = (dot_0(smooth_n_0, _S198)) < 0.0f;
    if(_S199)
    {
        return make_float3 (0.0f);
    }
    float3  _S200 = make_float3 (geometry_offset_0) * smooth_n_0;
    float3  _S201 = origin_2 + _S200;
    FKRay _S202 = Ray_x24init_0(_S201, _S198);
    bool _S203 = (dot_0(context_1->side, light_dir_0 + _S200)) > 0.0f;
    float _S204 = shadowLength(light_dir_0);
    float3  _S205 = context_1->extinction_behind;
    float3  _S206 = context_1->extinction_front;
    float3  _S207 = _slang_select(_S203, _S206,_S205);
    uint _S208 = context_1->fillings.x;
    uint _S209 = context_1->fillings.y;
    uint _S210 = _slang_select(_S203, _S209,_S208);
    uint _S211 = context_1->depth;
    uint _S212 = context_1->lobe;
    bool _S213 = context_1->surface;
    bool _S214;
    if(_S213)
    {
        _S214 = !context_1->fiber;
    }
    else
    {
        _S214 = false;
    }
    float _S215 = context_1->length;
    float _S216 = context_1->width;
    FKHit _S217;
    if(context_1->fiber)
    {
        _S217 = context_1->own;
    }
    else
    {
        _S217 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    }
    float3  _S218 = (fcptShadowTransmittanceIn((_S202), (_S204), (_S207), (_S210), (random_state_1), (_S211), (_S212), (_S214), (_S215), (_S216), (_S217), (*light_0)));
    return _S218;
}

__device__ float sine(float c_0)
{
    return (F32_sqrt(((F32_max((1.0f - c_0 * c_0), (0.0f))))));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S219 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S220 = cos_a_0 > cos_b_0;
    float _S221 = _slang_select(_S220, 1.0f,_S219);
    return _S221;
}

__device__ float sinSubClamped(float sin_a_1, float cos_a_1, float sin_b_1, float cos_b_1)
{
    float _S222 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    bool _S223 = cos_a_1 > cos_b_1;
    float _S224 = _slang_select(_S223, 0.0f,_S222);
    return _S224;
}

__device__ float importance(LightNode node_0, float3  p_9, float3  normal_0)
{
    float3  _S225 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S226 = node_0.high - node_0.low;
    float3  _S227 = p_9 - _S225;
    float3  _S228 = ((((_S227)) * make_float3(rnorm3df(((_S227)).x, ((_S227)).y, ((_S227)).z))));
    float _S229 = dot_0(_S227, _S227);
    float _S230 = dot_0(_S226, _S226) / 4.0f;
    float _S231 = (F32_abs((dot_0(node_0.w, _S228))));
    float _S232 = sine(node_0.cos_theta_o);
    float _S233 = (F32_sqrt(((F32_max((1.0f - _S230 / _S229), (0.0f))))));
    bool _S234 = _S229 < _S230;
    float _S235 = _slang_select(_S234, -1.0f,_S233);
    float _S236 = sine(_S235);
    float _S237 = sine(_S231);
    float _S238 = cosSubClamped(_S237, _S231, _S232, node_0.cos_theta_o);
    float _S239 = sine(_S231);
    float _S240 = sinSubClamped(_S239, _S231, _S232, node_0.cos_theta_o);
    float _S241 = cosSubClamped(_S240, _S238, _S236, _S235);
    bool _S242 = _S241 <= 0.0f;
    if(_S242)
    {
        return 0.0f;
    }
    float _S243 = - dot_0(_S228, normal_0);
    float _S244 = node_0.phi * _S241 / (F32_max((_S229), (length_0(_S226) / 2.0f)));
    float _S245 = sine(_S243);
    float _S246 = cosSubClamped(_S245, _S243, _S236, _S235);
    bool _S247 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S248 = _slang_select(_S247, 1.0f,_S246);
    return (F32_max((_S244 * _S248), (0.0f)));
}

__device__ __forceinline__ float childShare(LightNode first_0, LightNode second_0, float3  p_10, float3  normal_1, uint child_0)
{
    float _S249 = importance(first_0, p_10, normal_1);
    float _S250 = importance(second_0, p_10, normal_1);
    float2  _S251 = make_float2 (_S249, _S250);
    float _S252 = _slang_vector_get_element(_S251, child_0) / (_S249 + _S250);
    bool _S253 = _slang_vector_get_element(_S251, child_0) > 0.0f;
    float _S254 = _slang_select(_S253, _S252,0.0f);
    return _S254;
}

__device__ float sphereDensity(float3  center_0, float radius_0, float3  p_11)
{
    float3  _S255 = center_0 - p_11;
    float _S256 = radius_0 * radius_0 / dot_0(_S255, _S255);
    bool _S257 = _S256 >= 1.0f;
    if(_S257)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S256)))) / (6.28318548202514648f * _S256);
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S258 = left_0.y;
    float _S259 = right_0.z;
    float _S260 = left_0.z;
    float _S261 = right_0.y;
    float _S262 = right_0.x;
    float _S263 = left_0.x;
    return make_float3 (_S258 * _S259 - _S260 * _S261, _S260 * _S262 - _S263 * _S259, _S263 * _S261 - _S258 * _S262);
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_0))));
}

static __device__ float lightPdf_0(float3  origin_3, float3  smooth_n_1, float3  start_5, uint j_0, float3  light_point_0)
{
    bool _S264 = j_0 == 4294967295U;
    if(_S264)
    {
        return 0.0f;
    }
    uint4  _S265 = (fcptLightTrail((j_0)));
    uint2  _S266 = uint2 {_S265.x, _S265.y};
    uint n_0 = 0U;
    uint2  trail_0 = _S266;
    float probability_1 = 1.0f;
    for(;;)
    {
        uint4  _S267 = (fcptLightNode((n_0)));
        if((_S267.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S268 = (fcptLightSecond((n_0)));
        uint _S269 = n_0 + 1U;
        LightNode _S270 = (fcptLightBounds((_S269)));
        LightNode _S271 = (fcptLightBounds((_S268)));
        uint _S272 = trail_0.x;
        uint _S273 = _S272 & 1U;
        float _S274 = childShare(_S270, _S271, origin_3, smooth_n_1, _S273);
        float probability_2 = probability_1 * _S274;
        bool _S275 = _S273 == 1U;
        uint _S276 = _slang_select(_S275, _S268,_S269);
        uint _S277 = trail_0.y;
        uint2  _S278 = make_uint2 ((_S272 >> 1U) | (_S277 << 31U), _S277 >> 1U);
        n_0 = _S276;
        trail_0 = _S278;
        probability_1 = probability_2;
    }
    bool _S279 = (fcptSlotLeaf((n_0), (j_0)));
    bool _S280 = !_S279;
    bool _S281;
    if(_S280)
    {
        _S281 = true;
    }
    else
    {
        LightNode _S282 = (fcptLightBounds((n_0)));
        float _S283 = importance(_S282, origin_3, smooth_n_1);
        _S281 = !(_S283 > 0.0f);
    }
    if(_S281)
    {
        _S281 = true;
    }
    else
    {
        bool _S284 = (dot_0(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S284)
        {
            _S281 = !((dot_0(smooth_n_1, light_point_0 - origin_3)) > 0.0f);
        }
        else
        {
            _S281 = false;
        }
    }
    if(_S281)
    {
        return 0.0f;
    }
    uint4  _S285 = (fcptLightNode((n_0)));
    bool _S286 = (_S285.x) == 2U;
    if(_S286)
    {
        uint _S287 = _S285.y;
        FKLight _S288 = (fcptLight((_S287)));
        FKLight _S289 = (fcptLight((_S287)));
        float _S290 = sphereDensity(_S288.position, _S289.variance, start_5);
        return probability_1 * _S290;
    }
    uint _S291 = _S285.y;
    uint _S292 = (fcptTriangleOffset((_S291)));
    Matrix<float, 3, 3>  _S293 = (fcptWorldTriangle((_S291), (_S292 + _S285.z)));
    float _S294 = solidAngle(probability_1, cross_0(_S293.rows[int(1)] - _S293.rows[int(0)], _S293.rows[int(2)] - _S293.rows[int(0)]), light_point_0 - start_5);
    return _S294;
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
    uint _S295 = hash(*state_0);
    *state_0 = _S295;
    return float((*state_0) >> int(8)) * 5.9604644775390625e-08f;
}

static __device__ Random Random_x24init_0(uint state_1, float value_0)
{
    Random _S296;
    (&_S296)->state = state_1;
    (&_S296)->value = value_0;
    return _S296;
}

__device__ Random pcg(uint state_2)
{
    uint _S297 = state_2;
    float value_1 = random_0(&_S297);
    return Random_x24init_0(_S297, value_1);
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
    uint2  _S298 = (fcptEnvironmentCdfSize());
    uint2  _S299 = _S298 - make_uint2 (1U, 0U);
    float2  _S300 = make_float2 ((F32_atan2((- dir_2.y), (dir_2.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_1(dir_2.z, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S301 = make_float2 ((float)_S299.x, (float)_S299.y);
    float2  _S302 = _S300 * _S301;
    uint2  _S303 = make_uint2 ((uint)_S302.x, (uint)_S302.y);
    uint2  _S304 = min_0(_S303, _S299 - make_uint2 (1U));
    float4  _S305 = (fcptEnvironmentCdf((_S304)));
    float _S306 = _S305.y;
    uint _S307 = _S299.x;
    float4  _S308 = (fcptEnvironmentCdf((make_uint2 (_S307, _S304.y))));
    float _S309 = _S306 * _S308.y;
    return _S309 * float(_S307 * _S299.y) / (19.73921012878417969f * length_1(float2 {dir_2.x, dir_2.y}));
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    float _S310;
    if(e_1 > 0.0f)
    {
        _S310 = 1.0f;
    }
    else
    {
        if(e_1 < 0.0f)
        {
            _S310 = -1.0f;
        }
        else
        {
            _S310 = 0.0f;
        }
    }
    return _S310;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S311;
    (&_S311)->tangent = tangent_0;
    (&_S311)->alphas = alphas_0;
    return _S311;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S312 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S312)
    {
        float3  _S313 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S313;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S314 = cross_0(n_1, a_2);
    float3  _S315 = ((((_S314)) * make_float3(rnorm3df(((_S314)).x, ((_S314)).y, ((_S314)).z))));
    float3  _S316 = cross_0(n_1, _S315);
    return make_float3 (v_0.x) * _S315 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S316;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_0, float3  n_i_0)
{
    float _S317 = material_0.roughness;
    float _S318 = _S317 * _S317;
    bool _S319 = (material_0.anisotropy) == 0.0f;
    bool _S320;
    if(_S319)
    {
        _S320 = true;
    }
    else
    {
        _S320 = !(_S318 > 0.0f);
    }
    if(_S320)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S321 = material_0.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_0.tangent));
    float3  _S322 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S323 = (dot_0(_S321, _S321)) > 0.0f;
    float3  _S324 = _slang_select(_S323, _S321,_S322);
    float3  _S325 = ((((_S324)) * make_float3(rnorm3df(((_S324)).x, ((_S324)).y, ((_S324)).z))));
    float _S326 = 6.28318548202514648f * material_0.anisotropic_rotation;
    float _S327 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_0.anisotropy))))));
    float _S328 = 1.0f / _S327;
    bool _S329 = (material_0.anisotropy) < 0.0f;
    float _S330 = _slang_select(_S329, _S328,_S327);
    return AnisotropicFrame_x24init_0(_S325 * make_float3 ((F32_cos((_S326)))) + cross_0(n_i_0, _S325) * make_float3 ((F32_sin((_S326)))), make_float2 (_S318 / _S330, _S318 * _S330));
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S331;
    (&_S331)->on = on_0;
    (&_S331)->albedo = albedo_0;
    return _S331;
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
__device__ __forceinline__ SheenProfile sheenProfile(float3  v_1, float3  n_i_1, BSDFMaterial material_1)
{
    SheenProfile _S332 = SheenProfile_x24init_0(false, 0.0f);
    float _S333 = rgb_to_greyscale(material_1.sheen);
    bool _S334 = _S333 > 0.0f;
    SheenProfile profile_0;
    if(_S334)
    {
        float _S335 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S336 = (U32_min((uint(_S335)), (22U)));
        float _S337 = (F32_sqrt((0.05000000074505806f)));
        float _S338 = (F32_sqrt((0.10000000149011612f)));
        bool _S339 = (material_1.velvet) > 0.0f;
        float _S340 = _slang_select(_S339, _S338,_S337);
        float _S341 = (clamp_1((F32_sqrt(((F32_max((material_1.sheen_roughness), (0.0f)))))), _S340, 1.0f) - _S340) / (1.0f - _S340) * 23.0f;
        uint _S342 = (U32_min((uint(_S341)), (22U)));
        uint _S343 = _S336 * 24U + _S342;
        float _S344 = _S335 - float(_S336);
        float _S345 = _S341 - float(_S342);
        if(_S339)
        {
            uint _S346 = _S343 + 24U;
            float _S347 = VELVET_ALBEDO_0[_S343] + (VELVET_ALBEDO_0[_S346] - VELVET_ALBEDO_0[_S343]) * _S344;
            uint _S348 = _S343 + 1U;
            float _S349 = VELVET_ALBEDO_0[_S348] + (VELVET_ALBEDO_0[_S346 + 1U] - VELVET_ALBEDO_0[_S348]) * _S344;
            SheenProfile _S350 = SheenProfile_x24init_0(true, _S347 + (_S349 - _S347) * _S345);
            profile_0 = _S350;
        }
        else
        {
            uint _S351 = _S343 + 24U;
            float _S352 = SHEEN_ALBEDO_0[_S343] + (SHEEN_ALBEDO_0[_S351] - SHEEN_ALBEDO_0[_S343]) * _S344;
            uint _S353 = _S343 + 1U;
            float _S354 = SHEEN_ALBEDO_0[_S353] + (SHEEN_ALBEDO_0[_S351 + 1U] - SHEEN_ALBEDO_0[_S353]) * _S344;
            SheenProfile _S355 = SheenProfile_x24init_0(true, (F32_exp((_S352 + (_S354 - _S352) * _S345))));
            profile_0 = _S355;
        }
    }
    else
    {
        profile_0 = _S332;
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
    BSDFLobes _S356;
    (&_S356)->v_dot_h = v_dot_h_0;
    (&_S356)->n_dot_h = n_dot_h_0;
    (&_S356)->refracted = refracted_1;
    (&_S356)->F = F_0;
    (&_S356)->F_greyscale = F_greyscale_0;
    (&_S356)->reflect_weight = reflect_weight_0;
    (&_S356)->diffuse_weight = diffuse_weight_0;
    (&_S356)->refract_weight = refract_weight_0;
    (&_S356)->p_diffuse = p_diffuse_0;
    (&_S356)->p_reflect = p_reflect_0;
    (&_S356)->p_refract = p_refract_0;
    (&_S356)->translucent_share = translucent_share_0;
    (&_S356)->sheen = sheen_0;
    (&_S356)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S356)->view = view_0;
    (&_S356)->tangent = tangent_1;
    (&_S356)->alphas = alphas_1;
    (&_S356)->visible = visible_0;
    (&_S356)->p_toon = p_toon_0;
    (&_S356)->toon = toon_0;
    (&_S356)->toon_a = toon_a_0;
    (&_S356)->toon_s = toon_s_0;
    (&_S356)->toon_b = toon_b_0;
    (&_S356)->toon_glossy = toon_glossy_0;
    (&_S356)->toon_norm = toon_norm_0;
    (&_S356)->toon_view = toon_view_0;
    (&_S356)->toon_axis = toon_axis_0;
    return _S356;
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
    float3  _S357 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S358 = ((((_S357)) * make_float3(rnorm3df(((_S357)).x, ((_S357)).y, ((_S357)).z))));
    float _S359 = _S358.x;
    float _S360 = _S358.y;
    float _S361 = _S359 * _S359 + _S360 * _S360;
    float3  _S362;
    if(_S361 > 0.0f)
    {
        float3  _S363 = make_float3 (- _S360, _S359, 0.0f);
        float _S364 = (rsqrtf((_S361)));
        _S362 = _S363 * make_float3 (_S364);
    }
    else
    {
        _S362 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S365 = cross_0(_S358, _S362);
    float _S366 = (F32_sqrt((U1_0)));
    float _S367 = 6.28318548202514648f * U2_0;
    float _S368 = _S366 * (F32_cos((_S367)));
    float t2_0 = _S366 * (F32_sin((_S367)));
    float _S369 = 0.5f * (1.0f + _S358.z);
    float t2_1 = (1.0f - _S369) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S368 * _S368)))))) + _S369 * t2_0;
    float3  _S370 = make_float3 (_S368) * _S362 + make_float3 (t2_1) * _S365;
    float _S371 = unshared_0(_S368);
    float _S372 = unshared_0(_S368);
    float3  _S373 = _S370 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S371 * _S372 - t2_1 * t2_1))))))) * _S358;
    float3  _S374 = make_float3 (alpha_0 * _S373.x, alpha_0 * _S373.y, (F32_max((0.0f), (_S373.z))));
    float3  _S375 = ((((_S374)) * make_float3(rnorm3df(((_S374)).x, ((_S374)).y, ((_S374)).z))));
    return _S375;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S376 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S376)
    {
        float3  _S377 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S377;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S378 = cross_0(n_3, a_4);
    float3  _S379 = ((((_S378)) * make_float3(rnorm3df(((_S378)).x, ((_S378)).y, ((_S378)).z))));
    float3  _S380 = cross_0(n_3, _S379);
    return make_float3 (dot_0(v_2, _S379), dot_0(v_2, n_3), dot_0(v_2, _S380));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S381 = pcg(*random_state_2);
    Random _S382 = pcg(_S381.state);
    *random_state_2 = _S382.state;
    float _S383 = frame_0.alphas.x;
    bool _S384 = _S383 > 0.0f;
    if(_S384)
    {
        float3  _S385 = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        float _S386 = frame_0.alphas.y;
        float3  _S387 = make_float3 (_S383 * _S385.x, _S386 * _S385.y, _S385.z);
        float3  _S388 = ((((_S387)) * make_float3(rnorm3df(((_S387)).x, ((_S387)).y, ((_S387)).z))));
        float3  _S389 = sampleGGXVNDF(_S388, 1.0f, _S381.value, _S382.value);
        float3  _S390 = make_float3 (_S383 * _S389.x, _S386 * _S389.y, _S389.z);
        float3  _S391 = ((((_S390)) * make_float3(rnorm3df(((_S390)).x, ((_S390)).y, ((_S390)).z))));
        return make_float3 (_S391.x) * frame_0.tangent + make_float3 (_S391.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S391.z) * n_i_2;
    }
    float3  _S392 = worldToTangent(v_3, n_i_2);
    float3  _S393 = sampleGGXVNDF(float3 {_S392.x, _S392.z, _S392.y}, alpha_1, _S381.value, _S382.value);
    float3  _S394 = float3 {_S393.x, _S393.z, _S393.y};
    float3  _S395 = tangentToWorld(_S394, n_i_2);
    return _S395;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_4, BSDFMaterial material_2, uint random_state_3, AnisotropicFrame frame_1)
{
    uint state_3 = random_state_3;
    float3  _S396 = negate_0(in_dir_0);
    float _S397 = sign_0(dot_0(n_4, _S396));
    float _S398 = material_2.roughness;
    float3  _S399 = sampleHalfVector(_S396, n_4 * make_float3 (_S397), _S398 * _S398, frame_1, &state_3);
    return _S399;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_5, float eta_i_0, float eta_o_0)
{
    float3  _S400 = negate_0(in_dir_1);
    float3  _S401 = negate_0(make_float3 (eta_i_0) * _S400 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S402 = ((((_S401)) * make_float3(rnorm3df(((_S401)).x, ((_S401)).y, ((_S401)).z))));
    float _S403 = sign_0(dot_0(n_5, _S400));
    float _S404 = sign_0(dot_0(_S401, n_5 * make_float3 (_S403)));
    return _S402 * make_float3 (_S404);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S405 = negate_0(in_dir_2);
    float3  _S406 = _S405 + out_dir_1;
    float3  _S407 = ((((_S406)) * make_float3(rnorm3df(((_S406)).x, ((_S406)).y, ((_S406)).z))));
    return _S407;
}

static __device__ float3  refract_0(float3  i_5, float3  n_6, float eta_0)
{
    float _S408 = dot_0(n_6, i_5);
    float _S409 = 1.0f - eta_0 * eta_0 * (1.0f - _S408 * _S408);
    if(_S409 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S408 + (F32_sqrt((_S409)))) * n_6;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S410 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S411 = eta_i_1 / eta_o_1 * _S410;
    bool _S412 = _S411 < 1.0f;
    float kr_0;
    if(_S412)
    {
        float _S413 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S411 * _S411))))));
        float _S414 = eta_o_1 * cos_theta_0;
        float _S415 = eta_i_1 * _S413;
        float _S416 = (_S414 - _S415) / (_S414 + _S415);
        float _S417 = eta_i_1 * cos_theta_0;
        float _S418 = eta_o_1 * _S413;
        float _S419 = (_S417 - _S418) / (_S417 + _S418);
        float _S420 = (_S416 * _S416 + _S419 * _S419) / 2.0f;
        kr_0 = _S420;
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
    float _S421 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S421 / (_S421 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S421)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S422 = alphas_3.x;
    float _S423 = h_0.x / _S422;
    float _S424 = alphas_3.y;
    float _S425 = h_0.y / _S424;
    float _S426 = h_0.z;
    float _S427 = _S423 * _S423 + _S425 * _S425 + _S426 * _S426;
    return 1.0f / (F32_max((3.14159274101257324f * _S422 * _S424 * _S427 * _S427), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_4, float3  n_i_3, float3  ggx_n_0, BSDFMaterial material_3, float eta_i_2, float eta_o_2, AnisotropicFrame frame_2, SheenProfile sheen_profile_0)
{
    float _S428 = dot_0(ggx_n_0, v_4);
    float _S429 = dot_0(n_i_3, ggx_n_0);
    float _S430 = eta_i_2 / eta_o_2;
    float3  _S431 = refract_0(in_dir_3, ggx_n_0, _S430);
    float3  _S432 = ((((_S431)) * make_float3(rnorm3df(((_S431)).x, ((_S431)).y, ((_S431)).z))));
    float _S433 = (F32_min(((F32_sqrt((material_3.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S434 = _S433 * _S433;
    float _S435 = (1.0f + _S433) / (1.0f - _S433);
    float _S436 = (F32_abs((_S428)));
    bool _S437 = eta_i_2 > eta_o_2;
    float sheen_component_0;
    if(_S437)
    {
        sheen_component_0 = _S435;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float toon_component_0;
    if(_S437)
    {
        toon_component_0 = 1.0f;
    }
    else
    {
        toon_component_0 = _S435;
    }
    float _S438 = fresnel(_S436, sheen_component_0, toon_component_0);
    bool _S439 = (eta_i_2 * eta_i_2 * (1.0f - _S428 * _S428)) >= (eta_o_2 * eta_o_2);
    float3  _S440;
    if(_S439)
    {
        _S440 = make_float3 (1.0f);
    }
    else
    {
        float3  _S441 = material_3.specular_tint * make_float3 (_S434);
        _S440 = _S441 + (make_float3 (1.0f) - _S441) * make_float3 (_S438 - _S434) / make_float3 (1.0f - _S434);
    }
    float3  _S442 = make_float3 (1.0f);
    float3  _S443 = make_float3 (0.0f);
    float3  sheen_1;
    float3  view_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S444 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S445 = make_float3 (1.0f) - material_3.sheen * make_float3 (_S444);
        float _S446 = rgb_to_greyscale(material_3.sheen);
        float _S447 = _S446 * _S444;
        float3  _S448 = material_3.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S447;
        sheen_1 = _S448;
        view_1 = v_4;
        scale_1 = _S445;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S443;
        view_1 = _S443;
        scale_1 = _S442;
    }
    float _S449 = material_3.toon.x;
    bool _S450 = _S449 < 0.0f;
    float _S451 = (F32_abs((_S449)));
    bool _S452 = _S451 > 0.0f;
    float toon_a_1;
    float toon_s_1;
    float toon_b_1;
    float toon_norm_1;
    float toon_view_1;
    float3  toon_1;
    float3  toon_axis_1;
    bool _S453;
    if(_S452)
    {
        float _S454 = (F32_min((_S451), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S454);
        float _S455 = rgb_to_greyscale(material_3.albedo);
        float _S456 = _S454 * _S455;
        float3  _S457 = make_float3 (_S454) * material_3.albedo;
        float toon_a_2 = clamp_1(material_3.toon.y / _S449, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_2 = clamp_1(material_3.toon.z / _S449, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S458 = (F32_min((toon_a_2 + toon_s_2), (1.57079637050628662f)));
        if(_S450)
        {
            toon_component_0 = 1.0f - (F32_cos(((F32_min((_S458), (toon_a_2))))));
        }
        else
        {
            float _S459 = (F32_sin(((F32_min((_S458), (toon_a_2))))));
            toon_component_0 = _S459 * _S459 / 2.0f;
        }
        bool _S460 = _S458 > toon_a_2;
        if(_S460)
        {
            _S453 = toon_s_2 > 0.0f;
        }
        else
        {
            _S453 = false;
        }
        if(_S453)
        {
            if(_S450)
            {
                float _S461 = (F32_cos((toon_a_2)));
                float _S462 = (F32_cos((_S458)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S461 - _S462) - ((F32_sin((_S458))) - _S458 * _S462 - ((F32_sin((toon_a_2))) - toon_a_2 * _S461)) / toon_s_2;
            }
            else
            {
                float _S463 = 2.0f * toon_a_2;
                float _S464 = (F32_cos((_S463)));
                float _S465 = 2.0f * _S458;
                float _S466 = (F32_cos((_S465)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S464 - _S466) / 4.0f - ((F32_sin((_S465))) / 8.0f - _S458 * _S466 / 4.0f - ((F32_sin((_S463))) / 8.0f - toon_a_2 * _S464 / 4.0f)) / toon_s_2;
            }
            float integral_0 = toon_component_0 + toon_a_1;
            toon_component_0 = integral_0;
        }
        float _S467 = 6.28318548202514648f * toon_component_0;
        float _S468 = dot_0(n_i_3, v_4);
        float _S469 = (F32_acos(((F32_min((_S468), (1.0f))))));
        if(_S469 < toon_a_2)
        {
            toon_component_0 = 1.0f;
        }
        else
        {
            toon_component_0 = (F32_max((1.0f - (_S469 - toon_a_2) / (F32_max((toon_s_2), (0.0000152587890625f)))), (0.0f)));
        }
        if(_S450)
        {
            float3  _S470 = make_float3 (2.0f * _S468) * n_i_3 - v_4;
            float3  _S471 = ((((_S470)) * make_float3(rnorm3df(((_S470)).x, ((_S470)).y, ((_S470)).z))));
            scale_1 = _S471;
        }
        else
        {
            scale_1 = n_i_3;
        }
        float _S472 = toon_component_0;
        toon_component_0 = _S456;
        toon_1 = _S457;
        toon_a_1 = toon_a_2;
        toon_s_1 = toon_s_2;
        toon_b_1 = _S458;
        toon_norm_1 = _S467;
        toon_view_1 = _S472;
        toon_axis_1 = scale_1;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S443;
        toon_a_1 = 0.0f;
        toon_s_1 = 0.0f;
        toon_b_1 = 0.0f;
        toon_norm_1 = 1.0f;
        toon_view_1 = 0.0f;
        toon_axis_1 = n_i_3;
    }
    float3  _S473 = mix_0(_S440, material_3.albedo, material_3.metallic);
    float3  F_1 = _S473 * scale_1;
    float _S474 = rgb_to_greyscale(F_1);
    float _S475 = 1.0f - material_3.metallic;
    float3  _S476 = make_float3 (1.0f) - _S440;
    float3  _S477 = make_float3 ((1.0f - material_3.transmission) * _S475) * _S476 * scale_1;
    float3  _S478 = make_float3 (material_3.transmission * _S475) * _S476 * scale_1;
    float _S479 = (F32_max((_S474), (0.0f)));
    float _S480 = rgb_to_greyscale(_S477);
    float _S481 = (F32_max((_S480), (0.0f)));
    float _S482 = rgb_to_greyscale(_S478);
    float _S483 = sign_0(length_0(_S432));
    float _S484 = (F32_max((_S482 * _S483), (0.0f)));
    float _S485 = _S479 + _S481 + _S484 + toon_component_0;
    float _S486 = (F32_min((sheen_component_0), (1.0f)));
    bool _S487 = sheen_component_0 > 0.0f;
    if(_S487)
    {
        _S453 = !(_S485 > 0.0f);
    }
    else
    {
        _S453 = false;
    }
    float _S488 = _slang_select(_S453, 1.0f,_S486);
    float _S489 = (1.0f - _S488) / (F32_max((_S485), (0.0000152587890625f)));
    float _S490 = _S481 * _S489;
    float _S491 = _S479 * _S489;
    float _S492 = _S484 * _S489;
    bool _S493 = (frame_2.alphas.x) > 0.0f;
    float visible_1;
    if(_S493)
    {
        float3  _S494 = anisotropicLocal(v_4, frame_2.tangent, n_i_3);
        float _S495 = anisotropicG1(_S494, frame_2.alphas);
        float3  _S496 = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        float _S497 = anisotropicD(_S496, frame_2.alphas);
        float _S498 = _S495 * _S497;
        visible_1 = _S498;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S428, _S429, _S432, F_1, _S474, 1.0f, _S477, _S478, _S490, _S491, _S492, 0.0f, sheen_1, _S488, view_1, frame_2.tangent, frame_2.alphas, visible_1, toon_component_0 * _S489, toon_1, toon_a_1, toon_s_1, toon_b_1, _S450, toon_norm_1, toon_view_1, toon_axis_1);
}

__device__ float translucentShare(BSDFMaterial material_4)
{
    float _S499 = rgb_to_greyscale(material_4.translucent);
    float _S500 = rgb_to_greyscale(material_4.albedo);
    float _S501 = _S499 / (_S500 + _S499);
    bool _S502 = _S499 > 0.0f;
    float _S503 = _slang_select(_S502, _S501,0.0f);
    return _S503;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_2, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S504 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S505 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S506 = 1.0f - lobes_0.translucent_share;
    bool _S507 = n_i_dot_l_0 < 0.0f;
    float _S508 = _slang_select(_S507, lobes_0.translucent_share,_S506);
    float _S509 = _S505 * _S508;
    bool _S510 = (lobes_0.translucent_share) > 0.0f;
    float _S511 = _slang_select(_S510, _S509,_S504);
    bool _S512 = n_i_dot_v_0 > 0.0f;
    float _S513 = _slang_select(_S512, _S511,0.0f);
    return _S513;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_4, float alpha_3, BSDFMaterial material_5, BSDFLobes lobes_1)
{
    bool _S514 = (dot_0(n_i_4, l_0)) < 0.0f;
    float3  _S515 = _slang_select(_S514, material_5.translucent,material_5.albedo);
    float _S516 = 1.0f - lobes_1.translucent_share;
    float _S517 = _slang_select(_S514, lobes_1.translucent_share,_S516);
    float3  _S518 = _S515 / make_float3 (_S517);
    bool _S519 = (lobes_1.translucent_share) > 0.0f;
    float3  _S520 = _slang_select(_S519, _S518,material_5.albedo);
    return lobes_1.diffuse_weight * _S520 / make_float3 (lobes_1.p_diffuse);
}

__device__ float smithG1(float alpha_4, float n_dot_x_0)
{
    float _S521 = alpha_4 * alpha_4;
    float _S522 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S521 + (1.0f - _S521) * n_dot_x_0 * n_dot_x_0))));
    bool _S523 = alpha_4 > 0.0f;
    float _S524 = _slang_select(_S523, _S522,1.0f);
    return _S524;
}

__device__ float trowbridgeReitz(float alpha_5, float n_dot_h_1)
{
    float _S525 = alpha_5 * alpha_5;
    float _S526 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S525 * n_dot_h_1 * n_dot_h_1;
    return _S525 / (F32_max((3.14159274101257324f * _S526 * _S526), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S527 = smithG1(alpha_6, n_i_dot_v_1);
    float _S528 = _S527 * lobes_2.v_dot_h;
    float _S529 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S530 = _S528 * _S529 / n_i_dot_v_1;
    bool _S531 = alpha_6 > 0.0f;
    bool _S532;
    if(_S531)
    {
        _S532 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S532 = false;
    }
    if(_S532)
    {
        _S532 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S532 = false;
    }
    if(_S532)
    {
        _S532 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S532 = false;
    }
    float _S533 = _slang_select(_S532, _S530,0.0f);
    bool _S534 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S534)
    {
        float _S535 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S536 = (lobes_2.v_dot_h) > 0.0f;
        if(_S536)
        {
            _S532 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S532 = false;
        }
        if(_S532)
        {
            _S532 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S532 = false;
        }
        float _S537 = _slang_select(_S532, _S535,0.0f);
        pdf_h_0 = _S537;
    }
    else
    {
        pdf_h_0 = _S533;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S538 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S539 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S540 = lobes_3.p_refract * _S538 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S539 * _S539);
    bool _S541 = eta_i_4 != eta_o_4;
    bool _S542;
    if(_S541)
    {
        _S542 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S542 = false;
    }
    float _S543 = _slang_select(_S542, _S540,0.0f);
    return _S543;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_5, float alpha_8, BSDFMaterial material_6, BSDFLobes lobes_4)
{
    float _S544 = - dot_0(n_i_5, l_1);
    float _S545 = smithG1(alpha_8, (F32_max((_S544), (0.0f))));
    bool _S546 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S546)
    {
        float3  _S547 = negate_0(n_i_5);
        float3  _S548 = anisotropicLocal(l_1, lobes_4.tangent, _S547);
        float _S549 = anisotropicG1(_S548, lobes_4.alphas);
        G1_l_0 = _S549;
    }
    else
    {
        G1_l_0 = _S545;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_6.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S550 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S551 = n_i_dot_l_2 > 0.0f;
    bool _S552;
    if(_S551)
    {
        _S552 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S552 = false;
    }
    float _S553 = _slang_select(_S552, _S550,0.0f);
    return _S553;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_6, float alpha_10, BSDFMaterial material_7, BSDFLobes lobes_6)
{
    float3  _S554 = l_2 + lobes_6.view;
    float3  _S555 = ((((_S554)) * make_float3(rnorm3df(((_S554)).x, ((_S554)).y, ((_S554)).z))));
    float _S556 = dot_0(n_i_6, _S555);
    float _S557 = (F32_max((dot_0(n_i_6, l_2)), (0.0f)));
    float _S558 = (F32_max((dot_0(n_i_6, lobes_6.view)), (0.0f)));
    float _S559 = 1.0f / (F32_max((material_7.sheen_roughness), (0.05000000074505806f)));
    float _S560 = 1.0f - _S556 * _S556;
    float _S561 = (2.0f + _S559) * (F32_pow(((F32_max((_S560), (0.0f)))), (0.5f * _S559))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S557 + _S558 - _S557 * _S558)), (0.0000152587890625f)));
    bool _S562 = (material_7.velvet) > 0.0f;
    float f_1;
    if(_S562)
    {
        float _S563 = (F32_max((material_7.sheen_roughness), (0.00999999977648258f)));
        float _S564 = _S563 * _S563;
        float _S565 = (F32_max((_S560), (0.0000152587890625f)));
        float _S566 = (F32_exp((- _S556 * _S556 / (_S565 * _S564)))) / (3.14159274101257324f * _S564 * _S565 * _S565) * (F32_min((1.0f), (2.0f * _S556 * (F32_min((_S557), (_S558))) / (F32_max(((F32_abs((dot_0(_S555, lobes_6.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S557 * _S558), (0.0000152587890625f)));
        f_1 = _S566;
    }
    else
    {
        f_1 = _S561;
    }
    return lobes_6.sheen * make_float3 (f_1 * _S557 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float toonPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, BSDFLobes lobes_7, float eta_i_6, float eta_o_6)
{
    float _S567 = _slang_select(lobes_7.toon_glossy, l_dot_h_3,n_i_dot_l_3);
    float _S568 = (F32_acos((clamp_1(_S567, -1.0f, 1.0f))));
    float _S569;
    if(_S568 < (lobes_7.toon_a))
    {
        _S569 = 1.0f;
    }
    else
    {
        _S569 = (F32_max((1.0f - (_S568 - lobes_7.toon_a) / (F32_max((lobes_7.toon_s), (0.0000152587890625f)))), (0.0f)));
    }
    float _S570 = lobes_7.p_toon * _S569;
    float _S571 = _slang_select(lobes_7.toon_glossy, 1.0f,n_i_dot_l_3);
    float _S572 = _S570 * _S571 / lobes_7.toon_norm;
    bool _S573;
    if(lobes_7.toon_glossy)
    {
        _S573 = true;
    }
    else
    {
        _S573 = n_i_dot_l_3 > 0.0f;
    }
    float _S574 = _slang_select(_S573, _S572,0.0f);
    return _S574;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_3, float3  n_i_7, float alpha_12, BSDFMaterial material_8, BSDFLobes lobes_8)
{
    float _S575 = (F32_max((dot_0(n_i_7, l_3)), (0.0f)));
    float _S576 = _slang_select(lobes_8.toon_glossy, _S575,lobes_8.toon_view);
    return lobes_8.toon * make_float3 (_S576) / make_float3 (lobes_8.p_toon);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_4, float l_dot_h_4, float n_i_dot_v_5, float alpha_13, BSDFLobes lobes_9, float eta_i_7, float eta_o_7)
{
    float _S577 = vndfPDF(n_i_dot_v_5, alpha_13, lobes_9);
    float _S578 = lobes_9.p_reflect * _S577 / (4.0f * lobes_9.v_dot_h);
    bool _S579 = _S577 > 0.0f;
    float _S580 = _slang_select(_S579, _S578,0.0f);
    return _S580;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_4, float3  n_i_8, float alpha_14, BSDFMaterial material_9, BSDFLobes lobes_10)
{
    float _S581 = dot_0(n_i_8, l_4);
    float _S582 = smithG1(alpha_14, (F32_max((_S581), (0.0f))));
    bool _S583 = (lobes_10.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S583)
    {
        float3  _S584 = anisotropicLocal(l_4, lobes_10.tangent, n_i_8);
        float _S585 = anisotropicG1(_S584, lobes_10.alphas);
        G1_l_1 = _S585;
    }
    else
    {
        G1_l_1 = _S582;
    }
    return make_float3 (lobes_10.reflect_weight * G1_l_1) * lobes_10.F / make_float3 (lobes_10.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_10, float eta_i_8, float eta_o_8, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S586 = negate_0(in_dir_4);
    float _S587 = dot_0(n_7, _S586);
    float _S588 = sign_0(_S587);
    float3  _S589 = n_7 * make_float3 (_S588);
    AnisotropicFrame _S590 = anisotropicFrame(material_10, _S589);
    float _S591 = dot_0(_S589, out_dir_2);
    float _S592 = material_10.roughness;
    float _S593 = _S592 * _S592;
    SheenProfile _S594 = sheenProfile(_S586, _S589, material_10);
    float _S595 = rgb_to_greyscale(material_10.translucent);
    bool _S596 = _S595 > 0.0f;
    bool _S597 = (dot_0(n_7, out_dir_2) * _S587) < 0.0f;
    uint _S598;
    if((F32_abs((material_10.toon.x))) > 0.0f)
    {
        _S598 = 5U;
    }
    else
    {
        _S598 = 4U;
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
        float3  _S599 = make_float3 (0.0f);
        (*throughputs_0)[i_6] = _S599;
        (*pdfs_0)[i_6] = 0.0f;
        uint i_7 = i_6 + 1U;
        i_6 = i_7;
    }
    float3  _S600 = make_float3 (0.0f);
    BSDFLobes _S601 = BSDFLobes_x24init_0(0.0f, 0.0f, _S600, _S600, 0.0f, 0.0f, _S600, _S600, 0.0f, 0.0f, 0.0f, 0.0f, _S600, 0.0f, _S600, _S600, make_float2 (0.0f), 0.0f, 0.0f, _S600, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S600);
    BSDFLobes lobe_terms_0 = _S601;
    uint half_of_0 = 4294967295U;
    float3  ggx_n_2 = _S600;
    i_6 = 0U;
    for(;;)
    {
        if(i_6 < _S598)
        {
        }
        else
        {
            break;
        }
        uint _S602;
        if(i_6 == 3U)
        {
            _S602 = 4U;
        }
        else
        {
            if(i_6 == 4U)
            {
                _S602 = 6U;
            }
            else
            {
                _S602 = i_6;
            }
        }
        bool _S603 = _S602 == 0U;
        bool _S604;
        if(_S603)
        {
            _S604 = _S596;
        }
        else
        {
            _S604 = false;
        }
        bool _S605;
        if(_S604)
        {
            _S605 = _S597;
        }
        else
        {
            _S605 = _S602 == 1U;
        }
        bool _S606 = _S605 != refracted_2;
        if(_S606)
        {
            ggx_n_1 = ggx_n_2;
            uint i_8 = i_6 + 1U;
            ggx_n_2 = ggx_n_1;
            i_6 = i_8;
            continue;
        }
        uint _S607;
        if(_S602 == 6U)
        {
            _S607 = 0U;
        }
        else
        {
            if(_S602 == 4U)
            {
                _S607 = 2U;
            }
            else
            {
                _S607 = _S602;
            }
        }
        bool _S608 = _S607 != half_of_0;
        uint half_of_1;
        if(_S608)
        {
            bool _S609 = _S607 == 0U;
            if(_S609)
            {
                float3  _S610 = sampledHalf(in_dir_4, n_7, material_10, random_state_4, _S590);
                ggx_n_1 = _S610;
            }
            else
            {
                bool _S611 = _S607 == 1U;
                if(_S611)
                {
                    float3  _S612 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_8, eta_o_8);
                    ggx_n_1 = _S612;
                }
                else
                {
                    float3  _S613 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S613;
                }
            }
            float3  _S614 = negate_0(in_dir_4);
            BSDFLobes _S615 = bsdfLobes(in_dir_4, _S614, _S589, ggx_n_1, material_10, eta_i_8, eta_o_8, _S590, _S594);
            lobe_terms_0 = _S615;
            float _S616 = translucentShare(material_10);
            (&lobe_terms_0)->translucent_share = _S616;
            half_of_1 = _S607;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S602)
        {
        case 0U:
            {
                float _S617 = diffusePDF(_S591, 0.0f, (F32_abs((_S587))), _S593, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(0)] = _S617;
                float3  _S618 = diffuseBSDF(out_dir_2, _S589, _S593, material_10, lobe_terms_0);
                (*throughputs_0)[int(0)] = _S618;
                break;
            }
        case 1U:
            {
                float _S619 = refractPDF(_S591, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S587))), _S593, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(1)] = _S619;
                float3  _S620 = refractBSDF(out_dir_2, _S589, _S593, material_10, lobe_terms_0);
                (*throughputs_0)[int(1)] = _S620;
                break;
            }
        case 4U:
            {
                float _S621 = sheenVelvetPDF(_S591, 0.0f, (F32_abs((_S587))), _S593, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(3)] = _S621;
                float3  _S622 = sheenVelvetBSDF(out_dir_2, _S589, _S593, material_10, lobe_terms_0);
                (*throughputs_0)[int(3)] = _S622;
                break;
            }
        case 6U:
            {
                float _S623 = toonPDF(_S591, dot_0(out_dir_2, (&lobe_terms_0)->toon_axis), (F32_abs((_S587))), _S593, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(4)] = _S623;
                float3  _S624 = toonBSDF(out_dir_2, _S589, _S593, material_10, lobe_terms_0);
                (*throughputs_0)[int(4)] = _S624;
                break;
            }
        default:
            {
                float _S625 = reflectPDF(_S591, 0.0f, (F32_abs((_S587))), _S593, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(2)] = _S625;
                float3  _S626 = reflectBSDF(out_dir_2, _S589, _S593, material_10, lobe_terms_0);
                (*throughputs_0)[int(2)] = _S626;
                break;
            }
        }
        half_of_0 = half_of_1;
        uint i_8 = i_6 + 1U;
        ggx_n_2 = ggx_n_1;
        i_6 = i_8;
    }
    i_6 = 0U;
    ggx_n_1 = _S600;
    for(;;)
    {
        if(i_6 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S627 = ((*pdfs_0)[i_6]) > 0.0f;
        if(_S627)
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
    bool _S628 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    float3  _S629 = BSDF(in_dir_5, dir_3, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S628, random_state_5, terms_0, pdfs_1);
    float3  _S630 = make_float3 (0.0f);
    uint i_10 = 0U;
    float3  f_3 = _S630;
    for(;;)
    {
        if(i_10 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S631 = ((*pdfs_1)[i_10]) > 0.0f;
        if(_S631)
        {
            float3  _S632 = (*terms_0)[i_10] * make_float3 ((*pdfs_1)[i_10]) / make_float3 ((*pdfs_1)[i_10] + pdf_0);
            (*terms_0)[i_10] = _S632;
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
    FKSurface _S633 = surface_2;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S634 = skyLobes_0(in_dir_6, dir_4, &_S633, eta_2, is_inside_3, pdf_1, random_state_6, &terms_1, &pdfs_2);
    return _S634;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S635;
    (&_S635)->dir = dir_5;
    (&_S635)->radiance = radiance_0;
    (&_S635)->color = color_0;
    (&_S635)->random_state = random_state_7;
    return _S635;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S636 = (fcptEnvironmentCdfSize());
    uint2  _S637 = make_uint2 (1U, 0U);
    uint2  _S638 = _S636 - _S637;
    Random _S639 = pcg(init_random_state_0);
    Random _S640 = pcg(_S639.state);
    Random _S641 = pcg(_S640.state);
    Random _S642 = pcg(_S641.state);
    uint _S643 = _S638.x;
    uint _S644 = searchCDF_0(make_uint2 (_S643, 0U), make_uint2 (0U, 1U), _S638.y, _S639.value);
    uint _S645 = searchCDF_0(make_uint2 (0U, _S644), _S637, _S643, _S640.value);
    float2  _S646 = make_float2 ((float)_S638.x, (float)_S638.y);
    float2  _S647 = (make_float2 (float(_S645), float(_S644)) + make_float2 (_S641.value, _S642.value)) / _S646 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S648 = _S647.y;
    float _S649 = (F32_sin((_S648)));
    float _S650 = _S647.x;
    float3  _S651 = make_float3 (- _S649 * (F32_cos((_S650))), _S649 * (F32_sin((_S650))), (F32_cos((_S648))));
    float _S652 = environmentPdf_0(_S651);
    float3  _S653 = skyBSDF(ray_0->unit_direction, _S651, *surface_3, eta_3, is_inside_4, _S652, lobe_state_0);
    bool _S654 = !(_S652 > 0.0f);
    bool _S655;
    if(_S654)
    {
        _S655 = true;
    }
    else
    {
        _S655 = all_1(_S653 == make_float3 (0.0f));
    }
    if(_S655)
    {
        float3  _S656 = make_float3 (0.0f);
        return SkySample_x24init_0(_S651, _S656, _S656, _S642.state);
    }
    float3  _S657 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S651, context_2, _S642.state);
    return SkySample_x24init_0(_S651, _S657, _S653 * _S657, _S642.state);
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
    SampleBSDF _S658 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S659 = _S658.throughput * make_float3 (_S658.pdf);
    float _S660 = light_1->density;
    float _S661 = 1.0f + _S658.pdf * _S658.pdf / (light_1->density * light_1->density);
    bool _S662;
    if(competing_0)
    {
        _S662 = _S660 > 0.0f;
    }
    else
    {
        _S662 = false;
    }
    float _S663 = _slang_select(_S662, _S661,1.0f);
    return _S659 / make_float3 (_S663) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S664;
    (&_S664)->dir = dir_6;
    (&_S664)->radiance = radiance_1;
    (&_S664)->density = density_0;
    (&_S664)->random_state = random_state_8;
    return _S664;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S665 = importance(first_1, p_12, normal_3);
    float _S666 = importance(second_1, p_12, normal_3);
    float2  _S667 = make_float2 (_S665, _S666);
    bool _S668 = _S665 == 0.0f;
    bool _S669;
    if(_S668)
    {
        _S669 = _S666 == 0.0f;
    }
    else
    {
        _S669 = false;
    }
    if(_S669)
    {
        return 2U;
    }
    float _S670 = _S665 + _S666;
    bool _S671 = _S666 > 0.0f;
    if(_S671)
    {
        _S669 = (*pick_0 * _S670) >= _S665;
    }
    else
    {
        _S669 = false;
    }
    uint _S672 = uint(_S669);
    float _S673 = (F32_min(((*pick_0 * _S670 - float(_S672) * _S665) / _slang_vector_get_element(_S667, _S672)), (0.99999994039535522f)));
    *pick_0 = _S673;
    float _S674 = *probability_3 * (_slang_vector_get_element(_S667, _S672) / _S670);
    *probability_3 = _S674;
    return _S672;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S675 = center_1 - p_13;
    float _S676 = radius_1 * radius_1 / dot_0(_S675, _S675);
    float _S677 = u1_0 * _S676 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S676), (0.0f)))))));
    float _S678 = 2.0f * u1_0;
    bool _S679 = _S676 >= 1.0f;
    float _S680 = _slang_select(_S679, _S678,_S677);
    float _S681 = (F32_sqrt(((F32_max((_S680 * (2.0f - _S680)), (0.0f))))));
    float _S682 = 6.28318548202514648f * u2_0;
    float3  _S683 = make_float3 (_S681 * (F32_cos((_S682))), 1.0f - _S680, _S681 * (F32_sin((_S682))));
    float3  _S684 = ((((_S675)) * make_float3(rnorm3df(((_S675)).x, ((_S675)).y, ((_S675)).z))));
    float3  _S685 = tangentToWorld(_S683, _S684);
    return _S685;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S686 = center_2 - ray_1->origin;
    float _S687 = dot_0(_S686, ray_1->unit_direction);
    float _S688 = dot_0(_S686, _S686) - _S687 * _S687;
    float _S689 = radius_3 * radius_3;
    bool _S690 = _S688 > _S689;
    if(_S690)
    {
        return 4.294967296e+09f;
    }
    float _S691 = (F32_sqrt((_S689 - _S688)));
    float _S692 = _S687 - _S691;
    float _S693 = _S687 + _S691;
    bool _S694 = _S692 > 0.0000152587890625f;
    bool _S695;
    if(_S694)
    {
        _S695 = _S692 < max_len_0;
    }
    else
    {
        _S695 = false;
    }
    if(_S695)
    {
        return _S692;
    }
    bool _S696 = _S693 > 0.0000152587890625f;
    if(_S696)
    {
        _S695 = _S693 < max_len_0;
    }
    else
    {
        _S695 = false;
    }
    if(_S695)
    {
        return _S693;
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
    Random _S697 = pcg(init_random_state_1);
    Random _S698 = pcg(_S697.state);
    Random _S699 = pcg(_S698.state);
    float3  _S700 = make_float3 (0.0f);
    TreeSample _S701 = TreeSample_x24init_0(_S700, _S700, 0.0f, _S699.state);
    TreeSample sample_0 = _S701;
    float3  _S702 = _slang_select(sided_0, _S700,smooth_n_2);
    float3  _S703 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S697.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S704 = (fcptLightNode((n_8)));
        if((_S704.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S705 = (fcptLightSecond((n_8)));
        uint _S706 = n_8 + 1U;
        LightNode _S707 = (fcptLightBounds((_S706)));
        LightNode _S708 = (fcptLightBounds((_S705)));
        uint _S709 = pickChild(_S707, _S708, origin_4, _S702, &pick_1, &probability_4);
        bool _S710 = _S709 > 1U;
        if(_S710)
        {
            return sample_0;
        }
        bool _S711 = _S709 == 1U;
        uint _S712 = _slang_select(_S711, _S705,_S706);
        n_8 = _S712;
    }
    bool _S713 = n_8 == 0U;
    bool _S714;
    if(_S713)
    {
        LightNode _S715 = (fcptLightBounds((0U)));
        float _S716 = importance(_S715, origin_4, _S702);
        _S714 = !(_S716 > 0.0f);
    }
    else
    {
        _S714 = false;
    }
    if(_S714)
    {
        return sample_0;
    }
    uint4  _S717 = (fcptLightNode((n_8)));
    FKHit _S718 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S719 = (_S717.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S719)
    {
        FKLight _S720 = (fcptLight((_S717.y)));
        if(sided_0)
        {
            float _S721 = sign_0(dot_0(geometry_n_1, _S720.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S721);
            float3  _S722 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S722;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S703;
            lift_n_0 = smooth_n_2;
        }
        bool _S723 = (_S720.variance) == 0.0f;
        if(_S723)
        {
            float3  _S724 = _S720.position - emitter_point_0;
            float3  _S725 = ((((_S724)) * make_float3(rnorm3df(((_S724)).x, ((_S724)).y, ((_S724)).z))));
            (&sample_0)->dir = _S725;
            float3  _S726 = _S720.color * make_float3 (_S720.intensity) / make_float3 (dot_0(_S724, _S724) * probability_4);
            (&sample_0)->radiance = _S726;
            shadow_1 = _S724;
        }
        else
        {
            float3  _S727 = sampleSphere(_S720.position, _S720.variance, emitter_point_0, _S698.value, _S699.value);
            (&sample_0)->dir = _S727;
            float _S728 = sphereDensity(_S720.position, _S720.variance, emitter_point_0);
            float _S729 = probability_4 * _S728;
            (&sample_0)->density = _S729;
            float3  _S730 = pointLightRadiance(_S720.color, _S720.intensity, _S720.variance);
            float3  _S731 = _S730 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S731;
            FKRay _S732 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S733 = raySphere_0(_S720.position, _S720.variance, &_S732, 4.294967296e+09f);
            float3  _S734 = (&sample_0)->dir * make_float3 (_S733);
            shadow_1 = _S734;
        }
        emitter_0 = _S718;
        emitter_point_0 = _S700;
    }
    else
    {
        uint _S735 = _S717.y;
        uint _S736 = (fcptTriangleOffset((_S735)));
        uint _S737 = _S736 + _S717.z;
        Matrix<float, 3, 3>  _S738 = (fcptWorldTriangle((_S735), (_S737)));
        float _S739 = (F32_sqrt((_S698.value)));
        float2  _S740 = make_float2 (_S739 * (1.0f - _S699.value), _S739 * _S699.value);
        float3  _S741 = mul_0(make_float3 (1.0f - _S739, _S740.x, _S740.y), _S738);
        if(sided_0)
        {
            float _S742 = sign_0(dot_0(geometry_n_1, _S741 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S742);
            float3  _S743 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S743;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S744 = !((dot_0(smooth_n_2, _S741 - origin_4)) > 0.0f);
            if(_S744)
            {
                return sample_0;
            }
            emitter_point_0 = _S703;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S740, _S735, _S737, 0U, 0.0f);
        float3  _S745 = _S741 - emitter_point_0;
        float3  _S746 = ((((_S745)) * make_float3(rnorm3df(((_S745)).x, ((_S745)).y, ((_S745)).z))));
        (&sample_0)->dir = _S746;
        float _S747 = solidAngle(probability_4, cross_0(_S738.rows[int(1)] - _S738.rows[int(0)], _S738.rows[int(2)] - _S738.rows[int(0)]), _S745);
        (&sample_0)->density = _S747;
        bool _S748 = (fcptShadowFirst());
        bool _S749 = !_S748;
        if(_S749)
        {
            FKSurface _S750 = (fcptLightSurfaceAt((emitter_1), (_S741), (_S699.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S741 - origin_4))));
            (&sample_0)->random_state = _S750.random_state;
            float3  _S751 = _slang_select(_S750.skip, _S700,_S750.material.emissive);
            float3  _S752 = _S751 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S752;
        }
        shadow_1 = _S745;
        emitter_0 = emitter_1;
        emitter_point_0 = _S741;
    }
    FKHit _S753 = emitter_0;
    float3  _S754 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S699.state, &_S753);
    bool _S755 = (fcptShadowFirst());
    if(_S755)
    {
        _S714 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S714 = false;
    }
    if(_S714)
    {
        _S714 = !all_1(_S754 == _S700);
    }
    else
    {
        _S714 = false;
    }
    if(_S714)
    {
        FKSurface _S756 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S699.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S756.random_state;
        float3  _S757 = _slang_select(_S756.skip, _S700,_S756.material.emissive);
        float3  _S758 = _S757 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S758;
    }
    float3  _S759 = (&sample_0)->radiance * _S754;
    bool _S760 = all_1(_S754 == _S700);
    float3  _S761 = _slang_select(_S760, _S700,_S759);
    (&sample_0)->radiance = _S761;
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
    float _S762 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    bool _S763 = b_1 > 0.0f;
    float _S764 = _slang_select(_S763, _S762,1.0f);
    return _S764;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S765 = vertex_0->none;
    if(_S765)
    {
        return 1.0f;
    }
    uint _S766 = (fcptLightSlot((*hit_1)));
    float _S767 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S766, light_point_1);
    float _S768 = powerHeuristic(vertex_0->pdf, _S767);
    return _S768;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_0)
{
    uint2  _S769 = (fcptEnvironmentMapSize());
    bool _S770 = (_S769.x) > 1U;
    bool _S771;
    if(_S770)
    {
        uint2  _S772 = (fcptEnvironmentMapSize());
        _S771 = (_S772.y) > 1U;
    }
    else
    {
        _S771 = false;
    }
    if(_S771)
    {
        float3  _S773 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_0)));
        return _S773;
    }
    float3  _S774 = (fcptAmbient());
    return _S774;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S775 = (fcptEnvironmentCdfSize());
    bool _S776 = (_S775.x) > 1U;
    bool _S777;
    if(_S776)
    {
        uint2  _S778 = (fcptEnvironmentCdfSize());
        _S777 = (_S778.y) > 1U;
    }
    else
    {
        _S777 = false;
    }
    bool _S779 = !_S777;
    if(_S779)
    {
        return false;
    }
    uint2  _S780 = (fcptEnvironmentMapSize());
    bool _S781 = (_S780.x) > 1U;
    if(_S781)
    {
        uint2  _S782 = (fcptEnvironmentMapSize());
        _S777 = (_S782.y) > 1U;
    }
    else
    {
        _S777 = false;
    }
    return _S777;
}

static __device__ float escapeWeight_0(float pdf_2, float3  dir_8)
{
    bool _S783 = pdf_2 <= 0.0f;
    bool _S784;
    if(_S783)
    {
        _S784 = true;
    }
    else
    {
        bool _S785 = environmentMapped_0();
        _S784 = !_S785;
    }
    if(_S784)
    {
        return 1.0f;
    }
    float _S786 = environmentPdf_0(dir_8);
    return pdf_2 / (pdf_2 + _S786);
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
    uint2  _S787 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S788 = make_int2 ((int)_S787.x, (int)_S787.y);
    uint _S789 = previousSeed_0(_S788);
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
            uint _S790 = previousSeed_0(_S788 + make_int2 (x_16, y_5));
            bool _S791 = _S790 == _S789;
            uint _S792 = _slang_select(_S791, 1U,0U);
            uint count_3 = count_2 + _S792;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S793 = float(count_2 - 1U) / 288.0f;
    bool _S794 = _S789 != 0U;
    float _S795 = _slang_select(_S794, _S793,0.0f);
    fcptStoreDuplication((_S788), (make_uint4 ((F32_asuint((_S795))), 0U, 0U, 0U)));
    return;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S796 = hash(index_0);
    uint _S797 = hash(seed_3 ^ _S796);
    return _S797;
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

__device__ float neighborWeight(float share_1, float c_n_2, float p_n_0, float c_pair_2, float g_here_0)
{
    return share_1 * c_n_2 * p_n_0 / (c_n_2 * p_n_0 + c_pair_2 * g_here_0);
}

__device__ void offer(Selection * sel_2, Reservoir candidate_0, float3  weight_0)
{
    float _S798 = rgb_to_greyscale(weight_0);
    bool _S799 = _S798 > 0.0f;
    bool _S800;
    if(_S799)
    {
        _S800 = _S798 < 3.00000000549775576e+38f;
    }
    else
    {
        _S800 = false;
    }
    bool _S801 = !_S800;
    if(_S801)
    {
        return;
    }
    bool _S802 = sel_2->sums;
    if(_S802)
    {
        float3  _S803 = sel_2->color + weight_0;
        sel_2->color = _S803;
        return;
    }
    float _S804 = sel_2->w_sum + _S798;
    sel_2->w_sum = _S804;
    float3  _S805 = sel_2->color + weight_0;
    sel_2->color = _S805;
    Random _S806 = pcg(sel_2->random_state);
    sel_2->random_state = _S806.state;
    bool _S807 = (_S806.value * sel_2->w_sum) <= _S798;
    if(_S807)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S808 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S808;
    float _S809 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S809;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S810 = rgb_to_greyscale((&r_4)->f);
    float _S811 = sel_4.w_sum / _S810;
    bool _S812 = _S810 > 0.0f;
    float _S813 = _slang_select(_S812, _S811,0.0f);
    (&r_4)->w = _S813;
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
    uint2  _S814 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S815 = make_int2 ((int)_S814.x, (int)_S814.y);
    float3  _S816 = make_float3 (0.0f);
    FKHit _S817 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S818 = Domain_x24init_0(_S816, _S816, &_S817, 0.0f, 0.0f);
    Domain dom_4 = _S818;
    bool _S819 = (fcptCurrentDomain((_S815), (&dom_4)));
    bool _S820 = !_S819;
    if(_S820)
    {
        Reservoir _S821 = (Reservoir{});
        fcptStoreReservoirPrevious((_S815), (_S821), ((&dom_4)->hit));
        return;
    }
    Reservoir _S822 = (fcptLoadReservoirTemporal((_S815)));
    uint t_13 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S822.c;
    for(;;)
    {
        uint _S823 = (fcptRestirNeighbours());
        if(t_13 < _S823)
        {
        }
        else
        {
            break;
        }
        int2  _S824 = partner_0(_S815, t_13);
        Domain neighbor_0 = _S818;
        bool _S825 = (fcptCurrentDomain((_S824), (&neighbor_0)));
        if(_S825)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S826 = (fcptReservoirTemporal((_S824), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S826.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_14 = t_13 + 1U;
        t_13 = t_14;
    }
    float _S827 = _S822.c / (F32_max((count_4), (1.0f)));
    float _S828 = rgb_to_greyscale(_S822.f);
    bool _S829 = count_4 == 0.0f;
    float _S830 = _slang_select(_S829, 1.0f,0.0f);
    Selection _S831 = (Selection{});
    Selection sel_5 = _S831;
    uint _S832 = (fcptFrame());
    uint _S833 = hash(_S832);
    uint _S834 = global_invocation_id_2.x;
    uint2  _S835 = (fcptRenderSize());
    uint _S836 = stream(_S833, _S834 + _S835.x * global_invocation_id_2.y);
    uint _S837 = stream(_S836, 195U);
    (&sel_5)->random_state = _S837;
    t_13 = 0U;
    float canonical_mis_0 = _S830;
    for(;;)
    {
        uint _S838 = (fcptRestirNeighbours());
        if(t_13 < _S838)
        {
        }
        else
        {
            break;
        }
        int2  _S839 = partner_0(_S815, t_13);
        Domain neighbor_dom_0 = _S818;
        bool _S840 = (fcptCurrentDomain((_S839), (&neighbor_dom_0)));
        if(_S840)
        {
            Reservoir _S841 = (fcptLoadReservoirTemporal((_S839)));
            uint4  _S842 = (fcptShiftData((_S839), (t_13)));
            float4  _S843 = asfloat_0(_S842);
            uint4  _S844 = (fcptShiftData((_S815), (t_13)));
            float4  _S845 = asfloat_0(_S844);
            float _S846 = pairShare(_S841.c, _S827, c_sum_1);
            bool _S847 = _S828 > 0.0f;
            float canonical_mis_1;
            if(_S847)
            {
                float _S848 = rgb_to_greyscale(float3 {_S845.x, _S845.y, _S845.z});
                float _S849 = canonicalWeight(_S846, _S827, _S828, _S841.c, _S848);
                float canonical_mis_2 = canonical_mis_0 + _S849;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S850 = float3 {_S843.x, _S843.y, _S843.z};
            Shift _S851 = Shift_x24init_0(_S850, _S843.w);
            float _S852 = rgb_to_greyscale(_S841.f);
            float _S853 = rgb_to_greyscale(_S850);
            float _S854 = neighborWeight(_S846, _S841.c, _S852, _S827, _S853);
            offerShifted(&sel_5, _S841, _S851, _S854);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_15 = t_13 + 1U;
        t_13 = t_15;
    }
    offerShifted(&sel_5, _S822, Shift_x24init_0(_S822.f, 1.0f), canonical_mis_0);
    Reservoir _S855 = finalize(sel_5, c_sum_1);
    fcptStoreReservoirPrevious((_S815), (_S855), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S815), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S815), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S856 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S857 = _S856 != 4294967295U;
    if(_S857)
    {
        uint2  _S858 = make_uint2 (_S856, _S856 >> 14U) & make_uint2 (16383U);
        int2  _S859 = make_int2 ((int)_S858.x, (int)_S858.y);
        ShiftJob _S860 = (ShiftJob{});
        ShiftJob shift_job_0 = _S860;
        Shift _S861 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S862 = _S856 >> 28U;
        bool _S863 = spatialJob_0(_S859, _S862, &shift_job_0, true);
        Shift shifted_1;
        if(_S863)
        {
            Domain _S864 = (&shift_job_0)->dom;
            Reservoir _S865 = (&shift_job_0)->r;
            Shift _S866 = passShift_0(&_S864, &_S865);
            shifted_1 = _S866;
        }
        else
        {
            shifted_1 = _S861;
        }
        fcptStoreShiftData((_S859), (_S862), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S867 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S868 = make_int2 ((int)_S867.x, (int)_S867.y);
    FixedArray<uint, 3>  _S869;
    spatialBins_0(_S868, &_S869);
    FixedArray<uint, 3>  _S870 = _S869;
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
        bool _S871 = (_S870[t_16]) == 40U;
        if(_S871)
        {
            fcptStoreShiftData((_S868), (t_16), (make_uint4 (0U)));
        }
        uint t_17 = t_16 + 1U;
        t_16 = t_17;
    }
    FixedArray<uint, 3>  _S872 = _S870;
    queueShifts_0(_S868, &_S872, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S873 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S874 = make_int2 ((int)_S873.x, (int)_S873.y);
    FixedArray<uint, 3>  _S875;
    spatialBins_0(_S874, &_S875);
    FixedArray<uint, 3>  _S876 = _S875;
    countShifts_0(&_S876, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S877 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S878 = _S877 != 4294967295U;
    if(_S878)
    {
        uint2  _S879 = make_uint2 (_S877, _S877 >> 14U) & make_uint2 (16383U);
        int2  _S880 = make_int2 ((int)_S879.x, (int)_S879.y);
        int2  _S881 = (fcptLoadTemporalNeighbor((_S880)));
        uint _S882 = _S877 >> 28U;
        Shift _S883 = temporalShiftAt_0(_S880, _S881, _S882);
        fcptStoreTemporalShift((_S880), (_S882), (make_uint4 (asuint_1(_S883.f).x, asuint_1(_S883.f).y, asuint_1(_S883.f).z, (F32_asuint((_S883.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S884 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S885 = make_int2 ((int)_S884.x, (int)_S884.y);
    FixedArray<uint, 3>  _S886;
    temporalBins_0(_S885, &_S886);
    FixedArray<uint, 3>  _S887 = _S886;
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
        bool _S888 = (_S887[t_18]) == 40U;
        if(_S888)
        {
            fcptStoreTemporalShift((_S885), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S889 = _S887;
    queueShifts_0(_S885, &_S889, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S890 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S891 = make_int2 ((int)_S890.x, (int)_S890.y);
    bool _S892 = (fcptSceneUnchanged());
    bool _S893 = !_S892;
    bool _S894;
    if(_S893)
    {
        uint2  _S895 = (fcptRenderSize());
        int2  _S896 = make_int2 ((int)_S895.x, (int)_S895.y);
        _S894 = all_0(_S891 < _S896);
    }
    else
    {
        _S894 = false;
    }
    if(_S894)
    {
        Reservoir _S897 = (fcptLoadReservoirInitial((_S891)));
        int2  _S898 = sampleNeighbor_0(_S891, _S897.seed);
        fcptStoreTemporalNeighbor((_S891), (_S898));
    }
    FixedArray<uint, 3>  _S899;
    temporalBins_0(_S891, &_S899);
    FixedArray<uint, 3>  _S900 = _S899;
    countShifts_0(&_S900, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_6, float b_2, float t_20)
{
    return a_6 + (b_2 - a_6) * t_20;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S901 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S901;
}

__device__ float2  temporalWeights(float c_2, float p_c_1, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S902 = c_2 * p_c_1;
    float _S903 = c_t_0 * p_t_0;
    return make_float2 (_S902 / (_S902 + c_t_0 * g_previous_0), _S903 / (_S903 + c_2 * g_current_0));
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S904 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S905 = make_int2 ((int)_S904.x, (int)_S904.y);
    float3  _S906 = make_float3 (0.0f);
    FKHit _S907 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S908 = Domain_x24init_0(_S906, _S906, &_S907, 0.0f, 0.0f);
    Domain dom_5 = _S908;
    bool _S909 = (fcptCurrentDomain((_S905), (&dom_5)));
    bool _S910 = !_S909;
    if(_S910)
    {
        Reservoir _S911 = (Reservoir{});
        fcptStoreReservoirTemporal((_S905), (_S911), ((&dom_5)->hit));
        return;
    }
    Reservoir _S912 = (fcptLoadReservoirInitial((_S905)));
    bool _S913 = (fcptTemporalQueued());
    bool _S914 = (fcptSceneUnchanged());
    bool _S915;
    if(_S914)
    {
        _S915 = true;
    }
    else
    {
        _S915 = !_S913;
    }
    int2  _S916;
    if(_S915)
    {
        int2  _S917 = sampleNeighbor_0(_S905, _S912.seed);
        _S916 = _S917;
    }
    else
    {
        int2  _S918 = (fcptLoadTemporalNeighbor((_S905)));
        _S916 = _S918;
    }
    bool _S919 = (_S916.x) >= int(0);
    Reservoir r_5;
    if(_S919)
    {
        Reservoir _S920 = (fcptLoadReservoirPrevious((_S916)));
        uint4  _S921 = (fcptDuplication((_S916)));
        float _S922 = (U32_asfloat((_S921.x)));
        uint _S923 = (fcptRestirDecorrelation());
        bool _S924 = _S923 == 1U;
        float _S925 = _slang_select(_S924, _S922,0.0f);
        float _S926 = confidenceCap(_S925);
        float _S927 = (F32_min((_S920.c), (_S926)));
        bool _S928 = (fcptSceneUnchanged());
        float4  _S929 = make_float4 (_S920.f.x, _S920.f.y, _S920.f.z, 1.0f);
        bool _S930 = !_S928;
        if(_S930)
        {
            _S915 = _S913;
        }
        else
        {
            _S915 = false;
        }
        float4  to_current_0;
        if(_S915)
        {
            uint4  _S931 = (fcptTemporalShift((_S905), (0U)));
            float4  _S932 = asfloat_0(_S931);
            to_current_0 = _S932;
        }
        else
        {
            if(_S930)
            {
                Shift _S933 = temporalShiftAt_0(_S905, _S916, 0U);
                float4  _S934 = make_float4 (_S933.f.x, _S933.f.y, _S933.f.z, _S933.jac);
                to_current_0 = _S934;
            }
            else
            {
                to_current_0 = _S929;
            }
        }
        Domain own_1 = _S908;
        if(_S928)
        {
            _S915 = true;
        }
        else
        {
            bool _S935 = (fcptPreviousScenes());
            bool _S936 = !_S935;
            if(_S936)
            {
                _S915 = (_S912.w) > 0.0f;
            }
            else
            {
                _S915 = false;
            }
            if(_S915)
            {
                bool _S937 = (fcptStoredDomainInitial((_S905), (_S912.seed), (&own_1)));
                _S915 = _S937;
            }
            else
            {
                _S915 = false;
            }
            if(_S915)
            {
                Domain _S938 = (fcptPreviousDomain((_S916), (_S912.seed)));
                Domain _S939 = _S938;
                Domain _S940 = own_1;
                bool _S941 = sameDomain_0(&_S939, &_S940);
                _S915 = _S941;
            }
            else
            {
                _S915 = false;
            }
        }
        float4  _S942 = make_float4 (_S912.f.x, _S912.f.y, _S912.f.z, 1.0f);
        bool _S943 = !_S915;
        if(_S943)
        {
            _S915 = _S913;
        }
        else
        {
            _S915 = false;
        }
        float4  to_previous_0;
        if(_S915)
        {
            uint4  _S944 = (fcptTemporalShift((_S905), (1U)));
            float4  _S945 = asfloat_0(_S944);
            to_previous_0 = _S945;
        }
        else
        {
            if(_S943)
            {
                Shift _S946 = temporalShiftAt_0(_S905, _S916, 1U);
                float4  _S947 = make_float4 (_S946.f.x, _S946.f.y, _S946.f.z, _S946.jac);
                to_previous_0 = _S947;
            }
            else
            {
                to_previous_0 = _S942;
            }
        }
        float _S948 = rgb_to_greyscale(_S912.f);
        float _S949 = rgb_to_greyscale(_S920.f);
        Selection _S950 = (Selection{});
        Selection sel_6 = _S950;
        uint _S951 = (fcptFrame());
        uint _S952 = hash(_S951);
        uint _S953 = global_invocation_id_7.x;
        uint2  _S954 = (fcptRenderSize());
        uint _S955 = stream(_S952, _S953 + _S954.x * global_invocation_id_7.y);
        uint _S956 = stream(_S955, 194U);
        (&sel_6)->random_state = _S956;
        float4  _S957 = to_previous_0;
        float _S958 = rgb_to_greyscale(float3 {_S957.x, _S957.y, _S957.z});
        float4  _S959 = to_current_0;
        float3  _S960 = float3 {_S959.x, _S959.y, _S959.z};
        float _S961 = rgb_to_greyscale(_S960);
        float2  _S962 = temporalWeights(_S912.c, _S948, _S927, _S949, _S958, _S961);
        offerShifted(&sel_6, _S912, Shift_x24init_0(_S912.f, 1.0f), _S962.x);
        offerShifted(&sel_6, _S920, Shift_x24init_0(_S960, to_current_0.w), _S962.y);
        Reservoir _S963 = finalize(sel_6, _S912.c + _S927);
        r_5 = _S963;
    }
    else
    {
        r_5 = _S912;
    }
    fcptStoreReservoirTemporal((_S905), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S964 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S965 = make_int2 ((int)_S964.x, (int)_S964.y);
    float3  _S966 = make_float3 (0.0f);
    float2  _S967 = make_float2 (0.0f);
    FKHit _S968 = Hit_x24init_0(_S967, 0U, 0U, 0U, 0.0f);
    Domain _S969 = Domain_x24init_0(_S966, _S966, &_S968, 0.0f, 0.0f);
    Domain dom_6 = _S969;
    bool _S970 = (fcptCurrentDomain((_S965), (&dom_6)));
    bool _S971 = !_S970;
    if(_S971)
    {
        Reservoir _S972 = (Reservoir{});
        fcptStoreReservoirInitial((_S965), (_S972), ((&dom_6)->hit));
        return;
    }
    uint _S973 = (fcptFrame());
    uint _S974 = hash(_S973);
    uint _S975 = global_invocation_id_8.x;
    uint2  _S976 = (fcptRenderSize());
    uint _S977 = stream(_S974, _S975 + _S976.x * global_invocation_id_8.y);
    Selection _S978 = (Selection{});
    Selection initial_0 = _S978;
    uint _S979 = stream(_S977, 193U);
    (&initial_0)->random_state = _S979;
    bool _S980 = (fcptRestirUsed());
    bool _S981 = !_S980;
    (&initial_0)->sums = _S981;
    uint _S982 = stream(_S977, 0U);
    (&(&initial_0)->r)->seed = _S982;
    FKHit _S983 = Hit_x24init_0(_S967, 4294967295U, 0U, 0U, 0.0f);
    uint _S984 = (fcptSamples());
    float _S985 = 1.0f / float(_S984);
    FKHit hit_2 = _S983;
    uint i_17 = 0U;
    float3  seen_0 = _S966;
    for(;;)
    {
        uint _S986 = (fcptSamples());
        if(i_17 < _S986)
        {
        }
        else
        {
            break;
        }
        Reservoir _S987 = (Reservoir{});
        Reservoir r_6 = _S987;
        uint _S988 = stream(_S977, i_17);
        (&r_6)->seed = _S988;
        Domain path_0 = _S969;
        bool _S989 = (fcptStoredDomainInitial((_S965), ((&r_6)->seed), (&path_0)));
        bool _S990 = !_S989;
        if(_S990)
        {
            float3  _S991 = (fcptMissed((_S965), (path_0), (_S985)));
            float3  seen_1 = seen_0 + _S991;
            seen_0 = seen_1;
            uint i_18 = i_17 + 1U;
            i_17 = i_18;
            continue;
        }
        Domain _S992 = path_0;
        Reservoir _S993 = r_6;
        Shift _S994 = passWalk_0(&_S992, &_S993, false, _S985, &initial_0);
        bool _S995 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S995)
        {
            FKHit _S996 = (&path_0)->hit;
            hit_3 = _S996;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_18 = i_17 + 1U;
        i_17 = i_18;
    }
    uint _S997 = (fcptSamples());
    float3  seen_2 = seen_0 + (&initial_0)->glow / make_float3 (float(_S997));
    if((&initial_0)->sums)
    {
        seen_0 = seen_2 + (&initial_0)->color;
    }
    else
    {
        seen_0 = seen_2;
    }
    fcptAddColor((_S965), (make_float4 (seen_0.x, seen_0.y, seen_0.z, 1.0f)));
    Reservoir _S998 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S965), (_S998), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_3, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S999;
    (&_S999)->none = none_0;
    (&_S999)->pdf = pdf_3;
    (&_S999)->origin = origin_5;
    (&_S999)->smooth_n = smooth_n_3;
    (&_S999)->start = start_6;
    return _S999;
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
    Vertex _S1000;
    (&_S1000)->rough = rough_0;
    (&_S1000)->lobe = lobe_1;
    (&_S1000)->pdf = pdf_4;
    (&_S1000)->cos = cos_0;
    (&_S1000)->inside = inside_0;
    return _S1000;
}

static __device__ float freeFlight_0(float u_1, float sigma_0)
{
    return - (F32_log((1.0f - u_1))) / sigma_0;
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

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_1, float distance_2, bool scatters_0)
{
    float3  _S1001 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_2));
    float3  _S1002 = scatter_0 * _S1001 / make_float3 (sigma_1);
    float3  _S1003 = _slang_select(scatters_0, _S1002,_S1001);
    return _S1003;
}

static __device__ bool scatterSampled_0(bool replay_1, uint b_3, uint stop_0, bool varying_0)
{
    bool _S1004 = !replay_1;
    bool _S1005;
    if(_S1004)
    {
        _S1005 = true;
    }
    else
    {
        bool _S1006 = b_3 == stop_0;
        if(_S1006)
        {
            _S1005 = !varying_0;
        }
        else
        {
            _S1005 = false;
        }
    }
    return _S1005;
}

static __device__ uint arrivalLobe_0(uint b_4, uint prev_lobe_0)
{
    bool _S1007 = b_4 > 0U;
    uint _S1008 = _slang_select(_S1007, prev_lobe_0,3U);
    return _S1008;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_5, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1009;
    (&_S1009)->extinction_behind = extinction_behind_0;
    (&_S1009)->extinction_front = extinction_front_0;
    (&_S1009)->fillings = fillings_0;
    (&_S1009)->side = side_0;
    (&_S1009)->depth = depth_1;
    (&_S1009)->lobe = lobe_2;
    (&_S1009)->surface = surface_5;
    (&_S1009)->length = length_2;
    (&_S1009)->width = width_1;
    (&_S1009)->own = *own_2;
    (&_S1009)->fiber = fiber_0;
    return _S1009;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1010 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1010)
    {
        return 0.07957746833562851f;
    }
    float _S1011 = g_0 * g_0;
    return (1.0f - _S1011) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1011 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_7, float3  b_5)
{
    float3  _S1012 = a_7 / b_5;
    float3  _S1013 = make_float3 (0.0f);
    bool3  _S1014 = b_5 == _S1013;
    float3  _S1015 = _slang_select(_S1014, _S1013,_S1012);
    return _S1015;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1016 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1016 << offset_1))) | ((newbits_0 & _S1016) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_2 = r_7;
    uint _S1017 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1018 = insertBits_0(_S1017, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1018;
    (&candidate_2)->f = f_5;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S1019 = pcg(random_state_9);
    Random _S1020 = pcg(_S1019.state);
    float _S1021 = 1.0f - 2.0f * _S1019.value;
    float _S1022 = (F32_sqrt(((F32_max((1.0f - _S1021 * _S1021), (0.0f))))));
    float _S1023 = 6.28318548202514648f * _S1020.value;
    return make_float3 (_S1022 * (F32_cos((_S1023))), _S1022 * (F32_sin((_S1023))), _S1021);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_10, float * pdf_5)
{
    bool _S1024 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1024)
    {
        *pdf_5 = 0.07957746833562851f;
        float3  _S1025 = isotropic_0(random_state_10);
        return _S1025;
    }
    Random _S1026 = pcg(random_state_10);
    Random _S1027 = pcg(_S1026.state);
    float _S1028 = g_1 * g_1;
    float _S1029 = 2.0f * g_1;
    float _S1030 = (1.0f - _S1028) / (1.0f - g_1 + _S1029 * _S1026.value);
    float _S1031 = clamp_1((1.0f + _S1028 - _S1030 * _S1030) / _S1029, -1.0f, 1.0f);
    float _S1032 = (F32_sqrt(((F32_max((1.0f - _S1031 * _S1031), (0.0f))))));
    float _S1033 = 6.28318548202514648f * _S1027.value;
    float _S1034 = phaseHG_0(g_1, _S1031);
    *pdf_5 = _S1034;
    float3  _S1035 = tangentToWorld(make_float3 (_S1032 * (F32_cos((_S1033))), _S1031, _S1032 * (F32_sin((_S1033)))), dir_9);
    float3  _S1036 = ((((_S1035)) * make_float3(rnorm3df(((_S1035)).x, ((_S1035)).y, ((_S1035)).z))));
    return _S1036;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_5)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_2)
{
    BSDFMaterial _S1037;
    (&_S1037)->albedo = albedo_1;
    (&_S1037)->emissive = emissive_0;
    (&_S1037)->roughness = roughness_0;
    (&_S1037)->metallic = metallic_0;
    (&_S1037)->transmission = transmission_0;
    (&_S1037)->ior = ior_0;
    (&_S1037)->absorption = absorption_0;
    (&_S1037)->specular_tint = specular_tint_0;
    (&_S1037)->specular_level = specular_level_0;
    (&_S1037)->translucent = translucent_0;
    (&_S1037)->sheen = sheen_2;
    (&_S1037)->sheen_roughness = sheen_roughness_0;
    (&_S1037)->anisotropy = anisotropy_0;
    (&_S1037)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1037)->tangent = tangent_2;
    (&_S1037)->velvet = velvet_0;
    (&_S1037)->toon = toon_2;
    return _S1037;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1038;
    (&_S1038)->scatter = scatter_1;
    (&_S1038)->extinction = extinction_1;
    (&_S1038)->g = g_2;
    return _S1038;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_11, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1039;
    (&_S1039)->smooth_n = smooth_n_4;
    (&_S1039)->geometry_n = geometry_n_2;
    (&_S1039)->geometry_offset = geometry_offset_2;
    (&_S1039)->material = *material_11;
    (&_S1039)->skip = skip_0;
    (&_S1039)->random_state = random_state_11;
    (&_S1039)->coverage = coverage_0;
    (&_S1039)->encloses = encloses_0;
    (&_S1039)->volume = *volume_0;
    (&_S1039)->fills = fills_0;
    (&_S1039)->hair = hair_0;
    return _S1039;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S1040 = (&surface_6->material)->emissive;
    float3  _S1041 = make_float3 (0.0f);
    bool _S1042 = !top_0;
    float3  _S1043 = _slang_select(_S1042, _S1041,_S1040);
    (&(&lower_0)->material)->emissive = _S1043;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_2)
{
    float _S1044 = surface_7->coverage;
    bool _S1045 = u_2 < _S1044;
    if(_S1045)
    {
        return *surface_7;
    }
    float3  _S1046 = make_float3 (0.0f);
    float3  _S1047 = make_float3 (1.0f);
    BSDFMaterial _S1048 = Material_x24init_0(_S1046, _S1046, 0.0f, 0.0f, 0.0f, 0.0f, _S1046, _S1047, 1.0f, _S1046, _S1046, 0.5f, 0.0f, 0.0f, _S1046, 0.0f, _S1046);
    BSDFMaterial material_12 = _S1048;
    (&material_12)->albedo = _S1047;
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
    bool _S1049 = transmission_1 > 0.0f;
    bool _S1050;
    if(_S1049)
    {
        _S1050 = true;
    }
    else
    {
        _S1050 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1051;
    if(_S1050)
    {
        _S1051 = 1.0f;
    }
    else
    {
        _S1051 = -1.0f;
    }
    return _S1051;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_9)
{
    return (dot_0(dir_10, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_11)
{
    float3  _S1052 = surface_8->geometry_n;
    float _S1053 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_11);
    FKSurface faced_0 = *surface_8;
    float3  _S1054 = surface_8->smooth_n * make_float3 (_S1053);
    (&faced_0)->smooth_n = _S1054;
    float3  _S1055 = _S1052 * make_float3 (_S1053);
    (&faced_0)->geometry_n = _S1055;
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
    float3  _S1056 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1056));
}

__device__ float geometryDensity(float3  geometry_n_3, float3  direction_1, float distance_4)
{
    return (F32_abs((dot_0(geometry_n_3, direction_1)))) / (distance_4 * distance_4);
}

__device__ float footprintThreshold(float geometry_density_0)
{
    return 0.00251327408477664f / geometry_density_0;
}

__device__ bool withinFootprint(bool open_0, bool prev_rough_0, float prev_pdf_0, float geometry_density_1, float threshold_0)
{
    bool _S1057;
    if(open_0)
    {
        _S1057 = prev_rough_0;
    }
    else
    {
        _S1057 = false;
    }
    if(_S1057)
    {
        _S1057 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S1057 = false;
    }
    return _S1057;
}

__device__ float2  vertexEta(BSDFMaterial material_13, float n_dot_v_0)
{
    bool _S1058 = n_dot_v_0 < 0.0f;
    float _S1059 = _slang_select(_S1058, material_13.ior,1.0f);
    float _S1060 = _slang_select(_S1058, 1.0f,material_13.ior);
    return make_float2 (_S1059, _S1060);
}

__device__ bool neeDecision(BSDFMaterial material_14, float n_dot_v_1, float eta_i_9, float eta_o_9)
{
    float _S1061 = fresnel((F32_abs((n_dot_v_1))), eta_i_9, eta_o_9);
    float3  _S1062 = mix_0(make_float3 (_S1061), material_14.albedo, material_14.metallic);
    float _S1063 = rgb_to_greyscale(_S1062);
    float _S1064 = (F32_max(((1.0f - _S1063) * (1.0f - material_14.metallic) * (1.0f - material_14.transmission)), (0.0f)));
    bool _S1065 = _S1064 > 0.03999999910593033f;
    bool _S1066;
    if(_S1065)
    {
        _S1066 = true;
    }
    else
    {
        _S1066 = (material_14.roughness) > 0.20000000298023224f;
    }
    return _S1066;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_15)
{
    float _S1067 = rgb_to_greyscale(material_15->translucent);
    return _S1067 > 0.0f;
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
    MediumSides _S1068;
    (&_S1068)->behind = *behind_0;
    (&_S1068)->front = *front_0;
    (&_S1068)->fillings = fillings_1;
    (&_S1068)->face = face_1;
    return _S1068;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1069 = surface_9->geometry_n;
    MediumSides _S1070 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S1070;
    bool _S1071 = surface_9->encloses;
    if(_S1071)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S1072 = (dot_0(dir_12, _S1069)) > 0.0f;
        if(_S1072)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1073 = surface_10->geometry_n;
    ShadowContext _S1074 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1075 = surface_10->encloses;
    ShadowContext context_4;
    if(_S1075)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S1076 = - _S1073;
        float3  _S1077 = _slang_select(turned_0, _S1076,_S1073);
        (&faced_1)->geometry_n = _S1077;
        FKMedium _S1078 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1079 = faced_1;
        FKMedium _S1080 = _S1078;
        MediumSides _S1081 = mediumSides_0(&_S1079, &_S1080, filling_1, dir_13, outside_1);
        ShadowContext _S1082 = ShadowContext_x24init_0(_S1081.behind.extinction, _S1081.front.extinction, _S1081.fillings, _S1073, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1083 = _S1081.fillings;
            ShadowContext _S1084 = ShadowContext_x24init_0(_S1081.front.extinction, _S1081.behind.extinction, uint2 {_S1083.y, _S1083.x}, _S1073, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1084;
        }
        else
        {
            context_4 = _S1082;
        }
    }
    else
    {
        context_4 = _S1074;
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

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_16, float eta_i_10, float eta_o_10, bool competing_1, uint random_state_12)
{
    float3  _S1085 = light_2->dir;
    bool _S1086 = (dot_0(geometry_n_4, - in_dir_8) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_3;
    float3  _S1087 = BSDF(in_dir_8, _S1085, smooth_n_5, *material_16, eta_i_10, eta_o_10, _S1086, random_state_12, &throughputs_1, &pdfs_3);
    bool _S1088 = !competing_1;
    bool _S1089;
    if(_S1088)
    {
        _S1089 = true;
    }
    else
    {
        _S1089 = (light_2->density) == 0.0f;
    }
    if(_S1089)
    {
        return _S1087 * light_2->radiance;
    }
    float3  _S1090 = make_float3 (0.0f);
    uint i_23 = 0U;
    float3  weighted_0 = _S1090;
    for(;;)
    {
        if(i_23 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1091 = (pdfs_3[i_23]) > 0.0f;
        if(_S1091)
        {
            float _S1092 = light_2->density;
            float _S1093 = pdfs_3[i_23] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_23] * make_float3 (pdfs_3[i_23]) / make_float3 (_S1092 * (1.0f + _S1093 * _S1093));
            weighted_0 = weighted_1;
        }
        uint i_24 = i_23 + 1U;
        i_23 = i_24;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_13, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S1094;
    (&_S1094)->unit_direction = unit_direction_1;
    (&_S1094)->throughput = throughput_1;
    (&_S1094)->random_state = random_state_13;
    (&_S1094)->refracted = refracted_3;
    (&_S1094)->lobe = lobe_4;
    (&_S1094)->pdf = pdf_6;
    return _S1094;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_9, float n_i_dot_v_6, float alpha_15, BSDFMaterial material_17, BSDFLobes lobes_11, float eta_i_11, float eta_o_11, uint random_state_14)
{
    float3  _S1095 = make_float3 (1.0f);
    SampleBSDF _S1096 = SampleBSDF_x24init_0(_S1095, _S1095, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1096;
    Random _S1097 = pcg(random_state_14);
    Random _S1098 = pcg(_S1097.state);
    (&sample_1)->random_state = _S1098.state;
    float _S1099 = _S1097.value;
    float _S1100 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1099 * _S1099))))));
    float _S1101 = 6.28318548202514648f * _S1098.value;
    float3  _S1102 = tangentToWorld(make_float3 (_S1100 * (F32_cos((_S1101))), _S1097.value, _S1100 * (F32_sin((_S1101)))), n_i_9);
    (&sample_1)->unit_direction = _S1102;
    (&sample_1)->lobe = 4U;
    float3  _S1103 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_9, alpha_15, material_17, lobes_11);
    (&sample_1)->throughput = _S1103;
    float _S1104 = sheenVelvetPDF(_S1097.value, 0.0f, n_i_dot_v_6, alpha_15, lobes_11, eta_i_11, eta_o_11);
    (&sample_1)->pdf = _S1104;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1105 = (F32_sqrt((random_1_0)));
    float _S1106 = 6.28318548202514648f * random_2_0;
    float _S1107 = _S1105 * (F32_cos((_S1106)));
    float _S1108 = _S1105 * (F32_sin((_S1106)));
    float _S1109 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1107 * _S1107 - _S1108 * _S1108))))));
    return make_float3 (_S1107, _S1109, _S1108);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_10, float n_i_dot_v_7, float alpha_16, BSDFMaterial material_18, BSDFLobes lobes_12, float eta_i_12, float eta_o_12, uint random_state_15)
{
    float3  _S1110 = make_float3 (1.0f);
    SampleBSDF _S1111 = SampleBSDF_x24init_0(_S1110, _S1110, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1111;
    Random _S1112 = pcg(random_state_15);
    Random _S1113 = pcg(_S1112.state);
    (&sample_2)->random_state = _S1113.state;
    float3  _S1114 = sampleCosWeightedHemisphere(_S1112.value, _S1113.value);
    bool _S1115 = u_3 < (lobes_12.p_diffuse * lobes_12.translucent_share);
    float _S1116 = _S1114.y;
    float _S1117 = - _S1116;
    float _S1118 = _slang_select(_S1115, _S1117,_S1116);
    float3  _S1119 = tangentToWorld(make_float3 (_S1114.x, _S1118, _S1114.z), n_i_10);
    (&sample_2)->unit_direction = _S1119;
    (&sample_2)->refracted = _S1115;
    (&sample_2)->lobe = 0U;
    float3  _S1120 = diffuseBSDF((&sample_2)->unit_direction, n_i_10, alpha_16, material_18, lobes_12);
    (&sample_2)->throughput = _S1120;
    float _S1121 = diffusePDF(_S1118, 0.0f, n_i_dot_v_7, alpha_16, lobes_12, eta_i_12, eta_o_12);
    (&sample_2)->pdf = _S1121;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_11, float n_i_dot_v_8, float alpha_17, BSDFMaterial material_19, BSDFLobes lobes_13, float eta_i_13, float eta_o_13, uint random_state_16)
{
    float3  _S1122 = make_float3 (1.0f);
    SampleBSDF _S1123 = SampleBSDF_x24init_0(_S1122, _S1122, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1123;
    Random _S1124 = pcg(random_state_16);
    Random _S1125 = pcg(_S1124.state);
    (&sample_3)->random_state = _S1125.state;
    float _S1126 = _S1124.value * lobes_13.toon_norm / 6.28318548202514648f;
    float t_21;
    if(lobes_13.toon_glossy)
    {
        t_21 = (F32_acos((clamp_1(1.0f - _S1126, -1.0f, 1.0f))));
    }
    else
    {
        t_21 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1126)))), (1.0f))))));
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
        float _S1127;
        if(t_21 < (lobes_13.toon_a))
        {
            _S1127 = 1.0f;
        }
        else
        {
            _S1127 = (F32_max((1.0f - (t_21 - lobes_13.toon_a) / (F32_max((lobes_13.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float integral_1;
        if(lobes_13.toon_glossy)
        {
            integral_1 = 1.0f - (F32_cos(((F32_min((t_21), (lobes_13.toon_a))))));
        }
        else
        {
            float _S1128 = (F32_sin(((F32_min((t_21), (lobes_13.toon_a))))));
            integral_1 = _S1128 * _S1128 / 2.0f;
        }
        bool _S1129 = t_21 > (lobes_13.toon_a);
        bool _S1130;
        if(_S1129)
        {
            _S1130 = (lobes_13.toon_s) > 0.0f;
        }
        else
        {
            _S1130 = false;
        }
        float integral_2;
        if(_S1130)
        {
            if(lobes_13.toon_glossy)
            {
                float _S1131 = (F32_cos((lobes_13.toon_a)));
                float _S1132 = (F32_cos((t_21)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1131 - _S1132) - ((F32_sin((t_21))) - t_21 * _S1132 - ((F32_sin((lobes_13.toon_a))) - lobes_13.toon_a * _S1131)) / lobes_13.toon_s;
            }
            else
            {
                float _S1133 = 2.0f * lobes_13.toon_a;
                float _S1134 = (F32_cos((_S1133)));
                float _S1135 = 2.0f * t_21;
                float _S1136 = (F32_cos((_S1135)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1134 - _S1136) / 4.0f - ((F32_sin((_S1135))) / 8.0f - t_21 * _S1136 / 4.0f - ((F32_sin((_S1133))) / 8.0f - lobes_13.toon_a * _S1134 / 4.0f)) / lobes_13.toon_s;
            }
            float integral_3 = integral_1 + integral_2;
            integral_2 = integral_3;
        }
        else
        {
            integral_2 = integral_1;
        }
        float _S1137 = _S1127 * (F32_sin((t_21)));
        float _S1138;
        if(lobes_13.toon_glossy)
        {
            _S1138 = 1.0f;
        }
        else
        {
            _S1138 = (F32_cos((t_21)));
        }
        float _S1139 = _S1137 * _S1138;
        float _S1140 = (integral_2 - _S1126) / _S1139;
        bool _S1141 = _S1139 > 0.0f;
        float _S1142 = _slang_select(_S1141, _S1140,0.0f);
        float _S1143 = clamp_1(t_21 - _S1142, 0.0f, lobes_13.toon_b);
        int k_1 = k_0 + int(1);
        t_21 = _S1143;
        k_0 = k_1;
    }
    float _S1144 = 6.28318548202514648f * _S1125.value;
    float _S1145 = (F32_sin((t_21)));
    float3  _S1146 = tangentToWorld(make_float3 (_S1145 * (F32_cos((_S1144))), (F32_cos((t_21))), _S1145 * (F32_sin((_S1144)))), lobes_13.toon_axis);
    (&sample_3)->unit_direction = _S1146;
    bool _S1147 = (dot_0(n_i_11, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1147;
    (&sample_3)->lobe = 6U;
    float3  _S1148 = toonBSDF((&sample_3)->unit_direction, n_i_11, alpha_17, material_19, lobes_13);
    (&sample_3)->throughput = _S1148;
    float _S1149 = toonPDF(dot_0(n_i_11, (&sample_3)->unit_direction), dot_0((&sample_3)->unit_direction, lobes_13.toon_axis), n_i_dot_v_8, alpha_17, lobes_13, eta_i_13, eta_o_13);
    (&sample_3)->pdf = _S1149;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_12, float n_i_dot_v_9, float alpha_18, BSDFMaterial material_20, BSDFLobes lobes_14, float eta_i_14, float eta_o_14, uint random_state_17)
{
    float3  _S1150 = make_float3 (1.0f);
    SampleBSDF _S1151 = SampleBSDF_x24init_0(_S1150, _S1150, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1151;
    (&sample_4)->unit_direction = lobes_14.refracted;
    (&sample_4)->random_state = random_state_17;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1152 = refractBSDF((&sample_4)->unit_direction, n_i_12, alpha_18, material_20, lobes_14);
    (&sample_4)->throughput = _S1152;
    float _S1153 = refractPDF(0.0f, dot_0((&sample_4)->unit_direction, ggx_n_3), n_i_dot_v_9, alpha_18, lobes_14, eta_i_14, eta_o_14);
    (&sample_4)->pdf = _S1153;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_25, float3  n_10)
{
    return i_25 - make_float3 (2.0f * dot_0(n_10, i_25)) * n_10;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_13, float n_i_dot_v_10, float alpha_19, BSDFMaterial material_21, BSDFLobes lobes_15, float eta_i_15, float eta_o_15, uint random_state_18)
{
    float3  _S1154 = make_float3 (1.0f);
    SampleBSDF _S1155 = SampleBSDF_x24init_0(_S1154, _S1154, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1155;
    float3  _S1156 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S1157 = ((((_S1156)) * make_float3(rnorm3df(((_S1156)).x, ((_S1156)).y, ((_S1156)).z))));
    (&sample_5)->unit_direction = _S1157;
    (&sample_5)->random_state = random_state_18;
    (&sample_5)->lobe = 2U;
    float3  _S1158 = reflectBSDF((&sample_5)->unit_direction, n_i_13, alpha_19, material_21, lobes_15);
    (&sample_5)->throughput = _S1158;
    float _S1159 = reflectPDF(0.0f, 0.0f, n_i_dot_v_10, alpha_19, lobes_15, eta_i_15, eta_o_15);
    (&sample_5)->pdf = _S1159;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_11, BSDFMaterial material_22, float eta_i_16, float eta_o_16, uint random_init_0, float2  screen_space_0)
{
    uint random_state_19 = random_init_0;
    float3  _S1160 = negate_0(in_dir_10);
    float _S1161 = dot_0(n_11, _S1160);
    float _S1162 = sign_0(_S1161);
    float3  n_i_14 = n_11 * make_float3 (_S1162);
    float _S1163 = (F32_abs((_S1161)));
    float _S1164 = material_22.roughness;
    float _S1165 = _S1164 * _S1164;
    AnisotropicFrame _S1166 = anisotropicFrame(material_22, n_i_14);
    SheenProfile _S1167 = sheenProfile(_S1160, n_i_14, material_22);
    float3  _S1168 = sampleHalfVector(_S1160, n_i_14, _S1165, _S1166, &random_state_19);
    BSDFLobes _S1169 = bsdfLobes(in_dir_10, _S1160, n_i_14, _S1168, material_22, eta_i_16, eta_o_16, _S1166, _S1167);
    BSDFLobes lobes_16 = _S1169;
    float _S1170 = translucentShare(material_22);
    (&lobes_16)->translucent_share = _S1170;
    Random _S1171 = pcg(random_state_19);
    random_state_19 = _S1171.state;
    bool _S1172 = (_S1171.value) < ((&lobes_16)->p_sheen_velvet);
    if(_S1172)
    {
        SampleBSDF _S1173 = sheenVelvetSample(n_i_14, _S1163, _S1165, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1173;
    }
    float _S1174 = _S1171.value - (&lobes_16)->p_sheen_velvet;
    bool _S1175 = _S1174 < ((&lobes_16)->p_diffuse);
    if(_S1175)
    {
        SampleBSDF _S1176 = diffuseSample(_S1174, n_i_14, _S1163, _S1165, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1176;
    }
    bool _S1177 = _S1174 < ((&lobes_16)->p_diffuse + (&lobes_16)->p_toon);
    if(_S1177)
    {
        SampleBSDF _S1178 = toonSample(n_i_14, _S1163, _S1165, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1178;
    }
    float _S1179 = (&lobes_16)->p_toon;
    bool _S1180 = (_S1174 - _S1179) < ((&lobes_16)->p_diffuse + (&lobes_16)->p_refract);
    if(_S1180)
    {
        SampleBSDF _S1181 = refractSample(_S1168, n_i_14, _S1163, _S1165, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1181;
    }
    SampleBSDF _S1182 = reflectSample(in_dir_10, _S1168, n_i_14, _S1163, _S1165, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
    return _S1182;
}

__device__ bool withinInverseFootprint(float pdf_7, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1183 = pdf_7 > 0.0f;
    bool _S1184;
    if(_S1183)
    {
        if(diffuse_0)
        {
            _S1184 = true;
        }
        else
        {
            _S1184 = (pdf_7 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1184 = false;
    }
    return _S1184;
}

__device__ bool roughLobe(float pdf_8, bool diffuse_1, float roughness_1)
{
    bool _S1185 = pdf_8 > 0.0f;
    bool _S1186;
    if(_S1185)
    {
        if(diffuse_1)
        {
            _S1186 = true;
        }
        else
        {
            _S1186 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1186 = false;
    }
    return _S1186;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1187 = layers_0 > 1U;
    bool _S1188;
    if(_S1187)
    {
        _S1188 = refracting_0 != passed_0;
    }
    else
    {
        _S1188 = false;
    }
    return _S1188;
}

static __device__ float widened_0(float spread_1, float pdf_9, bool delta_0)
{
    float _S1189 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_9))))), (3.14159274101257324f)));
    bool _S1190 = !delta_0;
    float _S1191 = _slang_select(_S1190, _S1189,0.0f);
    return spread_1 + _S1191;
}

static __device__ bool boundsVolume_0(FKSurface * surface_11)
{
    return surface_11->encloses;
}

static __device__ bool leavesInFront_0(float3  face_2, float3  dir_14, float3  g_3)
{
    return ((dot_0(dir_14, g_3)) > 0.0f) == ((dot_0(g_3, face_2)) > 0.0f);
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_8, bool replay_2, float scale_3, Selection * sel_7)
{
    float spread_2;
    bool turned_1;
    bool is_inside_6;
    bool viewed_0;
    bool _S1192;
    float density_2;
    float threshold_2;
    float width_3;
    float sky_pdf_0;
    float geometry_density_2;
    uint b_6;
    uint layer_0;
    float3  throughput_2;
    float3  chain_throughput_0;
    TreeSample light_3;
    int _S1193;
    Shift ended_0;
    float density_3;
    float spread_3;
    float width_4;
    float sky_pdf_1;
    float spread_4;
    float width_5;
    uint b_7;
    float3  _S1194 = make_float3 (0.0f);
    Shift _S1195 = Shift_x24init_0(_S1194, 0.0f);
    uint _S1196 = r_8->path;
    uint _S1197 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1198 = extractBits_0(_S1196, 5U, 5U);
    uint _S1199 = extractBits_0(_S1196, 10U, 2U);
    uint _S1200 = extractBits_0(_S1196, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1201 = _S1200 >= 3U;
        uint _S1202 = _slang_select(_S1201, 1U,0U);
        uint _S1203 = _S1197 + _S1202;
        uint _S1204 = (fcptMaxBounces());
        passes_0 = _S1203 > _S1204;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1195;
    }
    uint _S1205 = _S1198 - 1U;
    bool _S1206 = _S1200 == 3U;
    uint _S1207 = _slang_select(_S1206, 1U,0U);
    uint _S1208 = _S1197 + _S1207;
    bool _S1209 = _S1199 == 0U;
    uint _S1210 = _slang_select(_S1209, _S1208,_S1205);
    FKHit _S1211 = (fcptReservoirHit((*r_8)));
    float3  _S1212 = dom_7->x0;
    float3  _S1213 = dom_7->x1 - dom_7->x0;
    float3  _S1214 = ((((_S1213)) * make_float3(rnorm3df(((_S1213)).x, ((_S1213)).y, ((_S1213)).z))));
    FKRay _S1215 = Ray_x24init_0(dom_7->x1, _S1214);
    FKRay ray_2 = _S1215;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1194;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1194;
    float3  extinction_in_0 = _S1194;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1216 = dom_7->spread;
    float _S1217 = dom_7->width;
    float _S1218 = length_0(_S1213);
    NEEVertex _S1219 = NEEVertex_x24init_0(true, 0.0f, _S1194, _S1194, _S1194);
    NEEVertex nee_vertex_0 = _S1219;
    Vertex _S1220 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1220;
    Reservoir _S1221 = (Reservoir{});
    Reservoir chain_0 = _S1221;
    uint _S1222 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1212;
    (&hit_4)->distance = _S1218;
    FKMedium _S1223 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1224 = filling_2;
    bool _S1225 = (fcptVaryingUsed());
    uint _S1226 = _slang_select(_S1225, _S1224,4294967295U);
    filling_2 = _S1226;
    scatter_in_0 = _S1223.scatter;
    extinction_in_0 = _S1223.extinction;
    g_in_0 = _S1223.g;
    Reservoir _S1227 = chain_0;
    uint _S1228 = filling_2;
    for(;;)
    {
        bool _S1229 = (fcptVaryingUsed());
        if(_S1229)
        {
            passes_0 = _S1228 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1230 = (fcptMajorant((_S1228)));
            spread_2 = _S1230;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1210;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1199 == 1U;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = spread_2 > 0.0f;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            ended_0 = _S1195;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1216;
            width_3 = _S1217;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_6 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1231 = (&prev_0)->rough;
        if(_S1231)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1232 = stream(_S1222, 384U);
        uint tracking_0 = _S1232;
        weight_1 = throughput_3;
        glowed_0 = _S1194;
        b_6 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_2 = _S1216;
        width_3 = _S1217;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1193 = int(1);
                break;
            }
            uint _S1233 = b_6 + 320U;
            bool _S1234 = b_6 == 4294967295U;
            uint _S1235 = _slang_select(_S1234, 384U,_S1233);
            uint _S1236 = stream(_S1222, _S1235);
            Random _S1237 = pcg(_S1236);
            float _S1238 = freeFlight_0(_S1237.value, spread_2);
            if(passes_0)
            {
                float3  _S1239 = (&ray_2)->origin;
                float3  _S1240 = (&ray_2)->unit_direction;
                float _S1241 = (&hit_4)->distance;
                uint _S1242 = _slang_select(_S1234, 0U,b_6);
                uint _S1243 = (&prev_0)->lobe;
                uint _S1244 = _slang_select(_S1234, 3U,_S1243);
                float _S1245 = (fcptTrackMedium((_S1228), (_S1239), (_S1240), (_S1241), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1242), (_S1244), (_S1234)));
                geometry_density_2 = _S1245;
            }
            else
            {
                geometry_density_2 = _S1238;
            }
            bool _S1246 = !(geometry_density_2 < ((&hit_4)->distance));
            if(_S1246)
            {
                _S1193 = int(1);
                break;
            }
            if(passes_0)
            {
                turned_1 = !replay_2;
            }
            else
            {
                turned_1 = false;
            }
            if(turned_1)
            {
                float3  _S1247 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1248 = sel_7->glow + _S1247;
                sel_7->glow = _S1248;
            }
            else
            {
            }
            glowed_0 = _S1194;
            uint b_8 = b_6 + 1U;
            float3  _S1249 = (&ray_2)->origin + make_float3 (geometry_density_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1249;
            float3  _S1250 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, geometry_density_2, true);
            float3  _S1251 = weight_1;
            float3  _S1252 = _slang_select(passes_0, _S1251,_S1250);
            float3  throughput_4 = throughput_2 * _S1252;
            uint _S1253 = stream(_S1222, b_8 + 320U);
            tracking_0 = _S1253;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_2 * geometry_density_2;
            float _S1254 = threshold_2 + 3.14159274101257324f;
            bool _S1255 = scatterSampled_0(replay_2, b_8, _S1210, passes_0);
            TreeSample _S1256 = TreeSample_x24init_0(_S1194, _S1194, 0.0f, 0U);
            if(_S1255)
            {
                float3  _S1257 = (&ray_2)->origin;
                float3  _S1258 = (&ray_2)->unit_direction;
                float3  _S1259 = (&ray_2)->unit_direction;
                uint _S1260 = stream(_S1222, b_8 + 64U);
                float3  _S1261 = extinction_in_0;
                float3  _S1262 = extinction_in_0;
                uint2  _S1263 = make_uint2 (_S1228);
                float3  _S1264 = (&ray_2)->unit_direction;
                uint _S1265 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                FKHit _S1266 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1267 = _S1266;
                ShadowContext _S1268 = ShadowContext_x24init_0(_S1261, _S1262, _S1263, _S1264, b_8, _S1265, false, geometry_density_2, width_6, &_S1267, false);
                ShadowContext _S1269 = _S1268;
                TreeSample _S1270 = sampleLightTree_0(_S1257, _S1258, _S1259, 0.0f, true, _S1260, &_S1269);
                light_3 = _S1270;
            }
            else
            {
                light_3 = _S1256;
            }
            float _S1271 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1272 = (fcptMaxBounces());
            bool _S1273 = b_8 < _S1272;
            if(_S1273)
            {
                is_inside_6 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_6 = false;
            }
            float _S1274 = _slang_select(is_inside_6, _S1271,0.0f);
            float3  _S1275 = throughput_4 * light_3.radiance;
            float _S1276 = powerHeuristic(light_3.density, _S1274);
            float3  _S1277 = _S1275 * make_float3 (_S1271 * _S1276);
            float3  _S1278 = _slang_select(_S1255, _S1277,_S1194);
            if(replay_2)
            {
                viewed_0 = b_8 == _S1210;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1279 = _S1199 == 2U;
                if(_S1279)
                {
                    float _S1280 = rgb_to_greyscale(_S1278);
                    passes_0 = _S1280 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1281 = Shift_x24init_0(_S1278, 1.0f);
                    _S1193 = int(0);
                    ended_0 = _S1281;
                    spread_2 = _S1254;
                    geometry_density_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_8;
                    break;
                }
                _S1193 = int(0);
                ended_0 = _S1195;
                spread_2 = _S1254;
                geometry_density_2 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_8;
                break;
            }
            bool _S1282 = !replay_2;
            if(_S1282)
            {
                Reservoir candidate_3 = _S1227;
                uint _S1283 = extractBits_0(_S1227.path, 10U, 2U);
                bool _S1284 = _S1283 == 1U;
                if(_S1284)
                {
                    float3  _S1285 = safeDivide(_S1278, _S1194);
                    (&candidate_3)->radiance = _S1285;
                }
                else
                {
                    uint _S1286 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                    uint _S1287 = insertBits_0(_S1286, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1287;
                }
                Reservoir _S1288 = withEnd(candidate_3, 0U, b_8, _S1278);
                offer(sel_7, _S1288, _S1278 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1289 = survivalProbability(throughput_4, density_2);
                uint _S1290 = stream(_S1222, b_8 + 128U);
                Random _S1291 = pcg(_S1290);
                bool _S1292 = _S1289 < (_S1291.value);
                if(_S1292)
                {
                    _S1192 = true;
                }
                else
                {
                    uint _S1293 = (fcptMaxBounces());
                    _S1192 = b_8 >= _S1293;
                }
                if(_S1192)
                {
                    _S1193 = int(0);
                    ended_0 = _S1195;
                    spread_2 = _S1254;
                    geometry_density_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_8;
                    break;
                }
                float _S1294 = density_2 * _S1289;
                density_2 = _S1294;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1295 = stream(_S1222, b_8);
            float3  _S1296 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1295, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1296;
            NEEVertex _S1297 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1194, (&ray_2)->origin);
            nee_vertex_0 = _S1297;
            Vertex _S1298 = scatteredVertex_0(false);
            prev_0 = _S1298;
            float _S1299 = (&prev_0)->pdf;
            FKRay _S1300 = ray_2;
            FKHit _S1301 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1302 = (fcptTraverseInstanceBVH((_S1300), (true), (4.294967296e+09f), (false), (_S1301), (false)));
            hit_4 = _S1302;
            b_6 = b_8;
            throughput_2 = throughput_4;
            threshold_2 = _S1254;
            width_3 = width_6;
            sky_pdf_0 = _S1299;
        }
        if(_S1193 != int(1))
        {
            width_3 = geometry_density_2;
            throughput_2 = chain_throughput_0;
            b_6 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1195;
        spread_2 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1303 = b_6 == 4294967295U;
    bool _S1304 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1304)
    {
        bool _S1305 = !(&nee_vertex_0)->none;
        float _S1306 = _slang_select(_S1305, sky_pdf_0,0.0f);
        float _S1307 = escapeWeight_0(_S1306, (&ray_2)->unit_direction);
        float3  _S1308 = environment_0((&ray_2)->unit_direction, b_6, (&prev_0)->lobe);
        float3  _S1309 = throughput_2 * _S1308;
        if(replay_2)
        {
            bool _S1310 = b_6 == _S1210;
            if(_S1310)
            {
                passes_0 = _S1199 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1309 * make_float3 (_S1307) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1209)
            {
                passes_0 = _S1206;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_6 == _S1197;
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
                return Shift_x24init_0(_S1309 * make_float3 (_S1307), 1.0f);
            }
            return _S1195;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1311 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1312 = _S1311 == 1U;
        if(_S1312)
        {
            uint _S1313 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1314 = _S1313 == b_6;
            float _S1315 = _slang_select(_S1314, 1.0f,_S1307);
            float3  _S1316 = safeDivide(_S1309 * make_float3 (_S1315), _S1194);
            (&candidate_4)->radiance = _S1316;
        }
        else
        {
            bool _S1317 = (&prev_0)->rough;
            if(_S1317)
            {
                uint _S1318 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                uint _S1319 = insertBits_0(_S1318, 3U, 10U, 2U);
                uint _S1320 = insertBits_0(_S1319, (&prev_0)->lobe, 15U, 3U);
                bool _S1321 = (&prev_0)->inside;
                uint _S1322 = _slang_select(_S1321, 1U,0U);
                uint _S1323 = insertBits_0(_S1320, _S1322, 22U, 1U);
                (&candidate_4)->path = _S1323;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1324 = _S1309 * make_float3 (_S1307);
        Reservoir _S1325 = withEnd(candidate_4, 3U, b_6, _S1324);
        offer(sel_7, _S1325, _S1324 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1195;
    }
    float3  _S1326 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1326;
    bool _S1327 = (fcptVaryingUsed());
    if(_S1327)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1328 = !replay_2;
        if(_S1328)
        {
            float3  _S1329 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1330 = sel_7->glow + _S1329;
            sel_7->glow = _S1330;
        }
        float3  _S1331 = throughput_2 * weight_1;
        throughput_2 = _S1331;
    }
    else
    {
        float3  _S1332 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1333 = throughput_2 * _S1332;
        throughput_2 = _S1333;
    }
    float _S1334 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1335 = b_6 + 1U;
    b_6 = _S1335;
    layer_0 = 0U;
    width_3 = _S1334;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_6 = false;
    chain_throughput_0 = _S1194;
    float3  reconnection_0 = _S1194;
    viewed_0 = _S1303;
    for(;;)
    {
        bool _S1336 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1192 = _S1199 == 1U;
        }
        else
        {
            _S1192 = false;
        }
        bool _S1337;
        if(_S1192)
        {
            _S1337 = b_6 == _S1198;
        }
        else
        {
            _S1337 = false;
        }
        bool _S1338;
        if(_S1337)
        {
            bool _S1339 = ((&hit_4)->instance_index) != (_S1211.instance_index);
            if(_S1339)
            {
                _S1338 = true;
            }
            else
            {
                _S1338 = ((&hit_4)->triangle_index) != (_S1211.triangle_index);
            }
        }
        else
        {
            _S1338 = false;
        }
        if(_S1338)
        {
            return _S1195;
        }
        FKMedium _S1340 = Medium_x24init_0(_S1194, _S1194, 0.0f);
        BSDFMaterial _S1341 = Material_x24init_0(_S1194, _S1194, 0.0f, 0.0f, 0.0f, 0.0f, _S1194, throughput_3, 1.0f, _S1194, _S1194, 0.5f, 0.0f, 0.0f, _S1194, 0.0f, _S1194);
        FKMedium _S1342 = _S1340;
        FKSurface _S1343 = Surface_x24init_0(_S1194, _S1194, 0.0f, &_S1341, false, 0U, 1.0f, false, &_S1342, 4294967295U, _S1194);
        bool _S1344 = !_S1336;
        bool scatter_2;
        bool is_inside_7;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S1344)
        {
            uint _S1345 = stream(_S1222, b_6);
            uint _S1346 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKSurface _S1347 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1345), (width_3), (layer_0), (b_6), (_S1346), ((&ray_2)->unit_direction)));
            bool _S1348 = !passes_0;
            FKSurface _S1349 = _S1347;
            FKSurface _S1350 = emitting_0(&_S1349, _S1348);
            uint _S1351 = stream(_S1222, b_6 + 256U);
            Random _S1352 = pcg(_S1351);
            FKSurface _S1353 = _S1350;
            FKSurface _S1354 = uncovered_0(&_S1353, _S1352.value);
            float _S1355 = facingSign(_S1354.material.transmission, _S1354.geometry_n, (&ray_2)->unit_direction);
            bool _S1356 = _S1355 < 0.0f;
            bool _S1357 = (_S1354.material.transmission) > 0.0f;
            if(_S1357)
            {
                bool _S1358 = arrivesBehind_0((&ray_2)->unit_direction, _S1354.geometry_n);
                scatter_2 = _S1358;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1359 = _S1354;
            FKSurface _S1360 = facingRay_0(&_S1359, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1361 = arrivesBehind_0((&ray_2)->unit_direction, _S1360.geometry_n);
                is_inside_7 = _S1361;
            }
            else
            {
                is_inside_7 = scatter_2;
            }
            if(is_inside_7)
            {
                float3  _S1362 = beerLambert((&hit_4)->distance, _S1360.material.absorption);
                float3  _S1363 = throughput_2 * _S1362;
                throughput_5 = _S1363;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1364 = !_S1360.skip;
            float geometry_density_3 = geometryDensity(_S1360.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1365 = b_6 == _S1335;
            if(_S1365)
            {
                float _S1366 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1366;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1367 = geometry_density_2;
            scatter_2 = _S1364;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1367;
            surface_12 = _S1360;
            turned_1 = _S1356;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_12 = _S1343;
            throughput_5 = throughput_2;
            is_inside_7 = is_inside_6;
        }
        bool _S1368 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1369 = surface_12;
        FKSurface _S1370 = surface_12;
        float _S1371 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        float2  _S1372 = vertexEta(_S1369.material, _S1371);
        bool _S1373;
        if(scatter_2)
        {
            bool _S1374 = neeDecision(_S1369.material, _S1371, _S1372.x, _S1372.y);
            _S1373 = _S1374;
        }
        else
        {
            _S1373 = false;
        }
        bool _S1375;
        if(passes_0)
        {
            _S1375 = true;
        }
        else
        {
            _S1375 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1375)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1373;
        }
        bool _S1376 = (fcptHairUsed());
        bool _S1377;
        if(_S1376)
        {
            float3  _S1378 = surface_12.hair;
            _S1377 = (dot_0(_S1378, _S1378)) > 0.0f;
        }
        else
        {
            _S1377 = false;
        }
        bool _S1379;
        if(_S1377)
        {
            _S1379 = true;
        }
        else
        {
            BSDFMaterial _S1380 = _S1369.material;
            bool _S1381 = isTranslucent_0(&_S1380);
            _S1379 = _S1381;
        }
        bool _S1382;
        if(_S1379)
        {
            _S1382 = true;
        }
        else
        {
            bool _S1383 = (_S1369.material.transmission) > 0.0f;
            if(_S1383)
            {
                uint _S1384 = (fcptLayers((hit_4)));
                _S1382 = _S1384 == 1U;
            }
            else
            {
                _S1382 = false;
            }
        }
        float3  emission_0;
        if(_S1336)
        {
            float3  _S1385 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1385;
        }
        else
        {
            emission_0 = _S1369.material.emissive;
        }
        bool _S1386 = !replay_2;
        bool _S1387;
        if(_S1386)
        {
            _S1387 = true;
        }
        else
        {
            _S1387 = b_6 >= _S1210;
        }
        bool _S1388;
        if(_S1387)
        {
            float _S1389 = rgb_to_greyscale(emission_0);
            _S1388 = _S1389 > 0.0f;
        }
        else
        {
            _S1388 = false;
        }
        float3  emission_1;
        if(_S1388)
        {
            NEEVertex _S1390 = nee_vertex_0;
            FKHit _S1391 = hit_4;
            float _S1392 = emissionWeight_0(&_S1390, &_S1391, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1392);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1393;
        if(replay_2)
        {
            _S1393 = _S1199 == 1U;
        }
        else
        {
            _S1393 = false;
        }
        bool _S1394;
        if(_S1393)
        {
            _S1394 = b_6 > _S1198;
        }
        else
        {
            _S1394 = false;
        }
        bool _S1395;
        if(_S1394)
        {
            _S1395 = b_6 == _S1197;
        }
        else
        {
            _S1395 = false;
        }
        bool _S1396;
        if(_S1395)
        {
            bool _S1397 = _S1200 == 1U;
            if(_S1397)
            {
                _S1396 = true;
            }
            else
            {
                _S1396 = _S1200 == 2U;
            }
        }
        else
        {
            _S1396 = false;
        }
        if(_S1396)
        {
            bool _S1398 = _S1336 != (_S1200 == 2U);
            if(_S1398)
            {
                return _S1195;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1399 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1400 = _S1399 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1401 = insertBits_0(0U, b_6, 5U, 5U);
        uint _S1402 = insertBits_0(_S1401, 1U, 10U, 2U);
        uint _S1403 = insertBits_0(_S1402, (&prev_0)->lobe, 15U, 3U);
        bool _S1404 = (&prev_0)->inside;
        uint _S1405 = _slang_select(_S1404, 1U,0U);
        uint _S1406 = insertBits_0(_S1403, _S1405, 22U, 1U);
        (&here_0)->path = _S1406;
        float _S1407 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1407;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1408;
        if(replay_2)
        {
            _S1408 = _S1199 == 1U;
        }
        else
        {
            _S1408 = false;
        }
        bool _S1409;
        if(_S1408)
        {
            _S1409 = b_6 == _S1198;
        }
        else
        {
            _S1409 = false;
        }
        bool _S1410 = b_6 == _S1210;
        bool _S1411;
        if(_S1410)
        {
            bool _S1412 = !scatter_2;
            if(_S1412)
            {
                _S1411 = true;
            }
            else
            {
                bool _S1413 = _S1199 != 1U;
                if(_S1413)
                {
                    _S1411 = _S1199 != 3U;
                }
                else
                {
                    _S1411 = false;
                }
            }
        }
        else
        {
            _S1411 = false;
        }
        bool _S1414;
        if(_S1411)
        {
            _S1414 = _S1199 == 2U;
        }
        else
        {
            _S1414 = false;
        }
        bool _S1415;
        if(_S1414)
        {
            _S1415 = !_S1368;
        }
        else
        {
            _S1415 = false;
        }
        bool _S1416;
        if(_S1415)
        {
            _S1416 = _S1200 != 4U;
        }
        else
        {
            _S1416 = false;
        }
        bool _S1417 = _S1198 == _S1197;
        bool _S1418;
        if(_S1417)
        {
            _S1418 = _S1200 == 0U;
        }
        else
        {
            _S1418 = false;
        }
        bool _S1419;
        if(_S1418)
        {
            _S1419 = ((&hit_4)->instance_index) == (_S1211.instance_index);
        }
        else
        {
            _S1419 = false;
        }
        bool _S1420;
        if(_S1419)
        {
            _S1420 = ((&hit_4)->triangle_index) == (_S1211.triangle_index);
        }
        else
        {
            _S1420 = false;
        }
        bool _S1421;
        if(_S1420)
        {
            _S1421 = _S1368;
        }
        else
        {
            _S1421 = false;
        }
        bool _S1422 = _slang_select(_S1409, _S1421,_S1416);
        bool _S1423;
        if(nee_0)
        {
            _S1423 = _slang_select(replay_2, _S1422,scatter_2);
        }
        else
        {
            _S1423 = false;
        }
        TreeSample _S1424 = TreeSample_x24init_0(_S1194, _S1194, 0.0f, 0U);
        uint2  _S1425 = make_uint2 (0U);
        float2  _S1426 = make_float2 (0.0f);
        FKHit _S1427 = Hit_x24init_0(_S1426, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1428 = _S1427;
        ShadowContext _S1429 = ShadowContext_x24init_0(_S1194, _S1194, _S1425, _S1194, 0U, 0U, false, 0.0f, 0.0f, &_S1428, false);
        bool _S1430;
        if(nee_0)
        {
            _S1430 = _S1387;
        }
        else
        {
            _S1430 = false;
        }
        ShadowContext context_5;
        if(_S1430)
        {
            uint _S1431 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKMedium _S1432 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1433 = surface_12;
            FKHit _S1434 = hit_4;
            FKMedium _S1435 = _S1432;
            ShadowContext _S1436 = shadowContext_0(&_S1433, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_6, _S1431, (&hit_4)->distance, width_3, &_S1434, _S1377, &_S1435);
            context_5 = _S1436;
        }
        else
        {
            context_5 = _S1429;
        }
        float3  throughput_6;
        float3  lit_0;
        if(_S1423)
        {
            float3  _S1437 = (&ray_2)->origin;
            if(_S1377)
            {
                throughput_6 = _S1194;
            }
            else
            {
                throughput_6 = _S1370.smooth_n;
            }
            FKSurface _S1438 = surface_12;
            uint _S1439 = stream(_S1222, b_6 + 64U);
            ShadowContext _S1440 = context_5;
            TreeSample _S1441 = sampleLightTree_0(_S1437, throughput_6, surface_12.geometry_n, surface_12.geometry_offset, _S1382, _S1439, &_S1440);
            bool _S1442 = any_1((_S1441.radiance) != _S1194);
            if(_S1442)
            {
                if(_S1377)
                {
                    uint _S1443 = (fcptMaxBounces());
                    bool _S1444 = b_6 < _S1443;
                    FKSurface _S1445 = surface_12;
                    TreeSample _S1446 = _S1441;
                    float3  _S1447 = hairLight_0(&_S1445, (&ray_2)->unit_direction, &_S1446, _S1444);
                    lit_0 = _S1447;
                }
                else
                {
                    float _S1448 = _S1372.x;
                    float _S1449 = _S1372.y;
                    uint _S1450 = (fcptMaxBounces());
                    bool _S1451 = b_6 < _S1450;
                    TreeSample _S1452 = _S1441;
                    BSDFMaterial _S1453 = _S1369.material;
                    float3  _S1454 = lightBSDF_0((&ray_2)->unit_direction, &_S1452, _S1370.smooth_n, _S1438.geometry_n, &_S1453, _S1448, _S1449, _S1451, surface_12.random_state);
                    lit_0 = _S1454;
                }
            }
            else
            {
                lit_0 = _S1194;
            }
            light_3 = _S1441;
        }
        else
        {
            light_3 = _S1424;
            lit_0 = _S1194;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1455;
        bool _S1456;
        float density_4;
        if(_S1409)
        {
            bool _S1457 = !_S1368;
            if(_S1457)
            {
                return _S1195;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1417)
            {
                viewed_1 = _S1200 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1417)
            {
                refracted_4 = _S1200 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1458 = !nee_0;
                if(_S1458)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1459 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1459 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1195;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1417)
            {
                wrong_side_0 = _S1200 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1460 = !nee_0;
                if(_S1460)
                {
                    return _S1195;
                }
                float _S1461 = environmentPdf_0(r_8->dir);
                float3  _S1462 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_12, _S1372, is_inside_7, _S1461, surface_12.random_state);
                return Shift_x24init_0(throughput_7 * _S1462 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1463 = extractBits_0(_S1196, 21U, 1U);
            bool _S1464 = nee_0 != (_S1463 == 1U);
            if(_S1464)
            {
                return _S1195;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1410;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1465 = !scatter_2;
                if(_S1465)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1466 = _S1199 != 1U;
                    if(_S1466)
                    {
                        refracted_4 = _S1199 != 3U;
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
                bool _S1467 = _S1199 == 2U;
                if(_S1467)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1368;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1200 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1377)
                    {
                        return _S1195;
                    }
                    uint _S1468 = stream(_S1222, b_6 + 448U);
                    FKRay _S1469 = ray_2;
                    FKSurface _S1470 = surface_12;
                    ShadowContext _S1471 = context_5;
                    SkySample _S1472 = sampleSky_0(&_S1469, &_S1470, _S1372, is_inside_7, _S1468, surface_12.random_state, &_S1471);
                    return Shift_x24init_0(throughput_5 * _S1472.color, 1.0f);
                }
                if(_S1467)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1368;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1473 = rgb_to_greyscale(light_3.radiance);
                    bool _S1474 = !(_S1473 > 0.0f);
                    if(_S1474)
                    {
                        return _S1195;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S1209)
                {
                    passes_0 = _S1200 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1336;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S1209)
                {
                    passes_0 = _S1200 == 1U;
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
                    passes_0 = !_S1368;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S1195;
            }
            else
            {
                if(_S1386)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1475 = b_6 > 0U;
                    if(_S1475)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1400)
                        {
                            float3  _S1476 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1476;
                        }
                        else
                        {
                            if(_S1368)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1477 = throughput_5 * emission_1;
                        Reservoir _S1478 = withEnd(candidate_5, 1U, b_6, _S1477);
                        offer(sel_7, _S1478, _S1477 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1479 = throughput_5 * emission_1;
                        float3  _S1480 = sel_7->glow + _S1479;
                        sel_7->glow = _S1480;
                    }
                    if(nee_0)
                    {
                        float3  _S1481 = throughput_5 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1400)
                        {
                            float3  _S1482 = safeDivide(_S1481, chain_throughput_0);
                            (&candidate_6)->radiance = _S1482;
                        }
                        else
                        {
                            if(_S1368)
                            {
                                candidate_6 = here_0;
                                uint _S1483 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1483;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1484 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                                uint _S1485 = insertBits_0(_S1484, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1485;
                            }
                        }
                        Reservoir _S1486 = withEnd(candidate_6, 0U, b_6, _S1481);
                        offer(sel_7, _S1486, _S1481 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1377)
                        {
                            _S1455 = false;
                        }
                        else
                        {
                            bool _S1487 = environmentMapped_0();
                            _S1455 = _S1487;
                        }
                    }
                    else
                    {
                        _S1455 = false;
                    }
                    if(_S1455)
                    {
                        uint _S1488 = (fcptMaxBounces());
                        _S1456 = b_6 < _S1488;
                    }
                    else
                    {
                        _S1456 = false;
                    }
                    if(_S1456)
                    {
                        uint _S1489 = stream(_S1222, b_6 + 448U);
                        FKRay _S1490 = ray_2;
                        FKSurface _S1491 = surface_12;
                        ShadowContext _S1492 = context_5;
                        SkySample _S1493 = sampleSky_0(&_S1490, &_S1491, _S1372, is_inside_7, _S1489, surface_12.random_state, &_S1492);
                        float3  _S1494 = throughput_5 * _S1493.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1400)
                        {
                            float3  _S1495 = safeDivide(_S1494, chain_throughput_0);
                            (&candidate_7)->radiance = _S1495;
                        }
                        else
                        {
                            if(_S1368)
                            {
                                candidate_7 = here_0;
                                uint _S1496 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1496;
                                (&candidate_7)->dir = _S1493.dir;
                                (&candidate_7)->radiance = _S1493.radiance;
                            }
                            else
                            {
                                uint _S1497 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                                uint _S1498 = insertBits_0(_S1497, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1498;
                            }
                        }
                        Reservoir _S1499 = withEnd(candidate_7, 4U, b_6, _S1494);
                        offer(sel_7, _S1499, _S1494 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1500;
        bool _S1501;
        bool _S1502;
        bool straight_0;
        bool _S1503;
        bool _S1504;
        bool _S1505;
        bool _S1506;
        bool _S1507;
        bool _S1508;
        bool _S1509;
        bool _S1510;
        bool _S1511;
        bool _S1512;
        bool _S1513;
        bool _S1514;
        float density_6;
        float sky_pdf_2;
        float spread_5;
        uint b_9;
        float3  throughput_8;
        float3  throughput_9;
        float3  throughput_10;
        if(scatter_2)
        {
            if(replay_2)
            {
                viewed_1 = _S1410;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1515 = extractBits_0(_S1196, 15U, 3U);
            uint _S1516 = extractBits_0(_S1196, 18U, 3U);
            uint _S1517 = _slang_select(_S1409, _S1516,_S1515);
            float3  _S1518 = r_8->dir;
            bool refracted_5 = _S1517 == 1U;
            SampleBSDF _S1519 = SampleBSDF_x24init_0(_S1194, _S1194, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1519;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1520 = extractBits_0(_S1196, 22U, 1U);
                bool _S1521 = is_inside_7 != (_S1520 == 1U);
                if(_S1521)
                {
                    return _S1195;
                }
                bool _S1522 = _S1199 == 1U;
                if(_S1522)
                {
                    float3  _S1523 = (fcptHitPosition((_S1211)));
                    throughput_8 = _S1523;
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
                    BSDFMaterial _S1524 = _S1369.material;
                    bool _S1525 = isTranslucent_0(&_S1524);
                    if(_S1525)
                    {
                        refracted_4 = _S1517 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1526 = throughput_8 - (&ray_2)->origin;
                        float3  _S1527 = _slang_select(_S1522, _S1526,_S1518);
                        wrong_side_0 = (dot_0(_S1370.smooth_n, _S1527) * _S1371) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1522)
                {
                    float3  _S1528 = (&ray_2)->origin;
                    FKSurface _S1529 = surface_12;
                    float3  _S1530 = - _S1370.smooth_n;
                    bool _S1531 = is_inside_7 != refracted_4;
                    float3  _S1532 = _slang_select(_S1531, _S1530,_S1370.smooth_n);
                    float3  _S1533 = throughput_8 - (_S1528 + make_float3 (_S1529.geometry_offset) * _S1532);
                    float3  _S1534 = ((((_S1533)) * make_float3(rnorm3df(((_S1533)).x, ((_S1533)).y, ((_S1533)).z))));
                    reconnection_1 = _S1534;
                }
                else
                {
                    reconnection_1 = _S1518;
                }
                if(_S1377)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1535 = wrongSide_0(is_inside_7, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1535;
                }
                if(wrong_side_0)
                {
                    return _S1195;
                }
                float3  _S1536 = throughput_8;
                throughput_8 = reconnection_1;
                b_9 = _S1517;
                wrong_side_0 = false;
                reconnection_1 = _S1536;
            }
            else
            {
                bool _S1537 = !_S1409;
                if(_S1537)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1538;
                    if(_S1377)
                    {
                        SampleBSDF _S1539 = (fcptSampleHair((surface_12.hair), (_S1369.material.albedo), (_S1369.material.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1538 = _S1539;
                    }
                    else
                    {
                        SampleBSDF _S1540 = sampleBSDF((&ray_2)->unit_direction, _S1370.smooth_n, _S1369.material, _S1372.x, _S1372.y, surface_12.random_state, _S1426);
                        _S1538 = _S1540;
                    }
                    bsdf_sampled_0 = _S1538;
                    if(_S1377)
                    {
                        refracted_4 = !(((&bsdf_sampled_0)->pdf) > 0.0f);
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        if(replay_2)
                        {
                            return _S1195;
                        }
                        break;
                    }
                    if(_S1377)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1541 = wrongSide_0(is_inside_7, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1541;
                    }
                    if(wrong_side_0)
                    {
                        _S1455 = (_S1369.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1455 = false;
                    }
                    if(_S1455)
                    {
                        SampleBSDF _S1542 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1369.material, _S1372.x, _S1372.y, (&bsdf_sampled_0)->random_state, _S1426);
                        (&bsdf_sampled_0)->unit_direction = _S1542.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1542.refracted;
                        (&bsdf_sampled_0)->throughput = _S1542.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1543 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1543;
                        }
                    }
                    uint _S1544 = (&bsdf_sampled_0)->lobe;
                    float3  _S1545 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1546 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1547 = (&bsdf_sampled_0)->pdf;
                    float _S1548 = _slang_select(wrong_side_0, 0.0f,_S1547);
                    (&lobe_5)->pdf = _S1548;
                    throughput_8 = _S1545;
                    b_9 = _S1544;
                    refracted_4 = _S1546;
                }
                else
                {
                    throughput_8 = _S1518;
                    b_9 = _S1517;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1455 = true;
            }
            else
            {
                _S1455 = _S1409;
            }
            float3  chain_throughput_1;
            if(_S1455)
            {
                if(_S1377)
                {
                    SampleBSDF _S1549 = (fcptConnectHair((surface_12.hair), (_S1369.material.albedo), (_S1369.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    lobe_5 = _S1549;
                }
                else
                {
                    float3  _S1550 = (&ray_2)->unit_direction;
                    float _S1551 = sign_0(_S1371);
                    float3  _S1552 = _S1370.smooth_n * make_float3 (_S1551);
                    float _S1553 = dot_0(_S1552, throughput_8);
                    float _S1554 = _S1369.material.roughness;
                    float _S1555 = _S1554 * _S1554;
                    AnisotropicFrame _S1556 = anisotropicFrame(_S1369.material, _S1552);
                    float3  _S1557 = negate_0(_S1550);
                    SheenProfile _S1558 = sheenProfile(_S1557, _S1552, _S1369.material);
                    float3  _S1559 = reflectedHalf(_S1550, throughput_8);
                    bool _S1560 = b_9 == 1U;
                    if(_S1560)
                    {
                        float3  _S1561 = refractedHalf(_S1550, throughput_8, _S1370.smooth_n, _S1372.x, _S1372.y);
                        throughput_9 = _S1561;
                    }
                    else
                    {
                        throughput_9 = _S1559;
                    }
                    bool _S1562 = b_9 == 0U;
                    if(_S1562)
                    {
                        _S1456 = true;
                    }
                    else
                    {
                        _S1456 = b_9 == 6U;
                    }
                    if(_S1456)
                    {
                        float3  _S1563 = sampledHalf(_S1550, _S1370.smooth_n, _S1369.material, surface_12.random_state, _S1556);
                        throughput_10 = _S1563;
                    }
                    else
                    {
                        throughput_10 = throughput_9;
                    }
                    float3  _S1564 = negate_0(_S1550);
                    float _S1565 = _S1372.x;
                    float _S1566 = _S1372.y;
                    BSDFLobes _S1567 = bsdfLobes(_S1550, _S1564, _S1552, throughput_10, _S1369.material, _S1565, _S1566, _S1556, _S1558);
                    BSDFLobes lobe_terms_1 = _S1567;
                    float _S1568 = translucentShare(_S1369.material);
                    (&lobe_terms_1)->translucent_share = _S1568;
                    switch(b_9)
                    {
                    case 0U:
                        {
                            float _S1569 = diffusePDF(_S1553, 0.0f, (F32_abs((_S1371))), _S1555, lobe_terms_1, _S1565, _S1566);
                            float3  _S1570 = diffuseBSDF(throughput_8, _S1552, _S1555, _S1369.material, lobe_terms_1);
                            density_6 = _S1569;
                            chain_throughput_1 = _S1570;
                            break;
                        }
                    case 1U:
                        {
                            float _S1571 = refractPDF(_S1553, dot_0(throughput_8, throughput_10), (F32_abs((_S1371))), _S1555, lobe_terms_1, _S1565, _S1566);
                            float3  _S1572 = refractBSDF(throughput_8, _S1552, _S1555, _S1369.material, lobe_terms_1);
                            density_6 = _S1571;
                            chain_throughput_1 = _S1572;
                            break;
                        }
                    case 4U:
                        {
                            float _S1573 = sheenVelvetPDF(_S1553, 0.0f, (F32_abs((_S1371))), _S1555, lobe_terms_1, _S1565, _S1566);
                            float3  _S1574 = sheenVelvetBSDF(throughput_8, _S1552, _S1555, _S1369.material, lobe_terms_1);
                            density_6 = _S1573;
                            chain_throughput_1 = _S1574;
                            break;
                        }
                    case 6U:
                        {
                            float _S1575 = toonPDF(_S1553, dot_0(throughput_8, (&lobe_terms_1)->toon_axis), (F32_abs((_S1371))), _S1555, lobe_terms_1, _S1565, _S1566);
                            float3  _S1576 = toonBSDF(throughput_8, _S1552, _S1555, _S1369.material, lobe_terms_1);
                            density_6 = _S1575;
                            chain_throughput_1 = _S1576;
                            break;
                        }
                    default:
                        {
                            float _S1577 = reflectPDF(_S1553, 0.0f, (F32_abs((_S1371))), _S1555, lobe_terms_1, _S1565, _S1566);
                            float3  _S1578 = reflectBSDF(throughput_8, _S1552, _S1555, _S1369.material, lobe_terms_1);
                            density_6 = _S1577;
                            chain_throughput_1 = _S1578;
                            break;
                        }
                    }
                    bool _S1579 = density_6 > 0.0f;
                    if(_S1579)
                    {
                        SampleBSDF _S1580 = SampleBSDF_x24init_0(throughput_8, chain_throughput_1, surface_12.random_state, _S1560, b_9, density_6);
                        lobe_5 = _S1580;
                    }
                }
            }
            bool _S1581 = b_9 == 0U;
            if(_S1581)
            {
                _S1456 = true;
            }
            else
            {
                _S1456 = b_9 == 4U;
            }
            if(_S1456)
            {
                _S1500 = true;
            }
            else
            {
                _S1500 = b_9 == 6U;
            }
            if(_S1377)
            {
                _S1501 = false;
            }
            else
            {
                bool _S1582 = !_S1500;
                if(_S1582)
                {
                    bool _S1583 = (_S1369.material.roughness) == 0.0f;
                    if(_S1583)
                    {
                        _S1501 = true;
                    }
                    else
                    {
                        bool _S1584 = b_9 == 1U;
                        if(_S1584)
                        {
                            _S1501 = (_S1372.x) == (_S1372.y);
                        }
                        else
                        {
                            _S1501 = false;
                        }
                    }
                }
                else
                {
                    _S1501 = false;
                }
            }
            bool _S1585 = !_S1377;
            if(_S1585)
            {
                _S1502 = b_9 == 1U;
            }
            else
            {
                _S1502 = false;
            }
            if(_S1502)
            {
                straight_0 = (_S1369.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1503 = _S1585;
            }
            else
            {
                _S1503 = false;
            }
            if(_S1503)
            {
                _S1504 = b_9 == 1U;
            }
            else
            {
                _S1504 = false;
            }
            if(_S1504)
            {
                _S1505 = (_S1372.x) == (_S1372.y);
            }
            else
            {
                _S1505 = false;
            }
            BSDFMaterial _S1586 = _S1369.material;
            bool _S1587 = isTranslucent_0(&_S1586);
            if(_S1587)
            {
                _S1506 = _S1581;
            }
            else
            {
                _S1506 = false;
            }
            if(_S1506)
            {
                _S1507 = (dot_0(throughput_8, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1507 = false;
            }
            if(nee_0)
            {
                _S1508 = !_S1501;
            }
            else
            {
                _S1508 = false;
            }
            if(_S1508)
            {
                _S1509 = !wrong_side_0;
            }
            else
            {
                _S1509 = false;
            }
            if(_S1509)
            {
                float _S1588 = (&lobe_5)->pdf;
                float3  _S1589 = (&ray_2)->origin;
                float3  _S1590 = _slang_select(_S1382, _S1194,_S1370.smooth_n);
                float3  _S1591 = (&ray_2)->origin;
                FKSurface _S1592 = surface_12;
                float3  _S1593 = - _S1370.smooth_n;
                float3  _S1594 = _slang_select(_S1507, _S1593,_S1370.smooth_n);
                NEEVertex _S1595 = NEEVertex_x24init_0(false, _S1588, _S1589, _S1590, _S1591 + make_float3 (_S1592.geometry_offset) * _S1594);
                nee_vertex_0 = _S1595;
            }
            else
            {
                if(_S1377)
                {
                    _S1510 = true;
                }
                else
                {
                    bool _S1596 = b_9 != 1U;
                    if(_S1596)
                    {
                        _S1510 = true;
                    }
                    else
                    {
                        _S1510 = (_S1372.x) != (_S1372.y);
                    }
                }
                if(_S1510)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1597 = withinInverseFootprint((&lobe_5)->pdf, _S1500, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1598 = roughLobe((&lobe_5)->pdf, _S1500, _S1369.material.roughness);
            if(_S1409)
            {
                bool _S1599 = !_S1597;
                if(_S1599)
                {
                    return _S1195;
                }
                bool _S1600 = _S1200 != 1U;
                if(_S1600)
                {
                    _S1510 = _S1200 != 2U;
                }
                else
                {
                    _S1510 = false;
                }
                if(_S1510)
                {
                    float _S1601 = (&lobe_5)->pdf;
                    float _S1602 = _slang_select(nee_0, _S1601,0.0f);
                    float _S1603 = escapeWeight_0(_S1602, _S1518);
                    if(_S1417)
                    {
                        passes_0 = _S1206;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1604 = _slang_select(passes_0, _S1603,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1604) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1605 = throughput_6 * make_float3 ((&lobe_5)->pdf);
                float _S1606 = density_4 * (&lobe_5)->pdf;
                throughput_9 = _S1605;
                density_6 = _S1606;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1607 = (fcptLayers((hit_4)));
            bool _S1608 = b_9 == 1U;
            bool _S1609 = passesLayer_0(_S1607, _S1608, passes_0);
            if(viewed_1)
            {
                _S1510 = _S1609;
            }
            else
            {
                _S1510 = false;
            }
            if(_S1510)
            {
                return _S1195;
            }
            if(replay_2)
            {
                _S1511 = b_6 <= _S1210;
            }
            else
            {
                _S1511 = false;
            }
            if(_S1511)
            {
                _S1512 = _S1368;
            }
            else
            {
                _S1512 = false;
            }
            if(_S1512)
            {
                _S1513 = _S1597;
            }
            else
            {
                _S1513 = false;
            }
            if(_S1513)
            {
                _S1514 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1514 = !_S1598;
                }
                else
                {
                    _S1514 = false;
                }
            }
            if(_S1514)
            {
                return _S1195;
            }
            if(viewed_1)
            {
                float3  _S1610 = throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1611 = (&lobe_5)->pdf;
                throughput_10 = _S1610;
                sky_pdf_2 = _S1611;
            }
            else
            {
                float3  _S1612 = throughput_9 * max_0((&lobe_5)->throughput, _S1194);
                throughput_10 = _S1612;
                sky_pdf_2 = density_6;
            }
            bool _S1613;
            if(_S1386)
            {
                _S1613 = !_S1400;
            }
            else
            {
                _S1613 = false;
            }
            bool _S1614;
            if(_S1613)
            {
                _S1614 = _S1368;
            }
            else
            {
                _S1614 = false;
            }
            bool _S1615;
            if(_S1614)
            {
                _S1615 = _S1597;
            }
            else
            {
                _S1615 = false;
            }
            if(_S1615)
            {
                chain_0 = here_0;
                uint _S1616 = insertBits_0((&chain_0)->path, b_9, 18U, 3U);
                uint _S1617 = _slang_select(nee_0, 1U,0U);
                uint _S1618 = insertBits_0(_S1616, _S1617, 21U, 1U);
                (&chain_0)->path = _S1618;
                float _S1619 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1619;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1620 = surface_12;
            Vertex _S1621 = Vertex_x24init_0(_S1598, b_9, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_8)))), is_inside_7);
            prev_0 = _S1621;
            float _S1622 = (&lobe_5)->pdf;
            bool _S1623;
            if(_S1608)
            {
                _S1623 = (_S1372.x) == (_S1372.y);
            }
            else
            {
                _S1623 = false;
            }
            float sky_pdf_3 = _slang_select(_S1623, sky_pdf_0,_S1622);
            float _S1624 = _slang_select(_S1377, 0.0f,sky_pdf_3);
            float _S1625 = widened_0(spread_2, (&lobe_5)->pdf, _S1501);
            bool _S1626;
            if(refracted_4)
            {
                _S1626 = !_S1507;
            }
            else
            {
                _S1626 = false;
            }
            bool is_inside_8;
            if(_S1626)
            {
                bool _S1627 = !is_inside_7;
                is_inside_8 = _S1627;
            }
            else
            {
                is_inside_8 = is_inside_7;
            }
            FKSurface _S1628 = surface_12;
            bool _S1629 = boundsVolume_0(&_S1628);
            bool _S1630;
            if(_S1629)
            {
                _S1630 = !_S1609;
            }
            else
            {
                _S1630 = false;
            }
            if(_S1630)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1631 = - _S1620.geometry_n;
                float3  _S1632 = _slang_select(turned_1, _S1631,_S1620.geometry_n);
                (&faced_2)->geometry_n = _S1632;
                FKMedium _S1633 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1634 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1635 = faced_2;
                FKMedium _S1636 = _S1633;
                FKMedium _S1637 = _S1634;
                MediumSides _S1638 = mediumSides_0(&_S1635, &_S1636, filling_2, (&ray_2)->unit_direction, &_S1637);
                bool _S1639 = leavesInFront_0((&faced_2)->geometry_n, throughput_8, _S1620.geometry_n);
                float3  _S1640 = _slang_select(_S1639, _S1638.front.scatter,_S1638.behind.scatter);
                scatter_in_0 = _S1640;
                float3  _S1641 = _slang_select(_S1639, _S1638.front.extinction,_S1638.behind.extinction);
                extinction_in_0 = _S1641;
                float _S1642 = _slang_select(_S1639, _S1638.front.g,_S1638.behind.g);
                g_in_0 = _S1642;
                uint _S1643 = _S1638.fillings.x;
                uint _S1644 = _S1638.fillings.y;
                uint _S1645 = _slang_select(_S1639, _S1644,_S1643);
                bool _S1646 = (fcptVaryingUsed());
                uint _S1647 = _slang_select(_S1646, _S1645,4294967295U);
                filling_2 = _S1647;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1648 = !_S1609;
            if(_S1648)
            {
                FKSurface _S1649 = surface_12;
                float _S1650 = _slang_select(straight_0, 0.0f,_S1649.geometry_offset);
                float3  _S1651 = - _S1370.smooth_n;
                bool _S1652 = is_inside_8 != _S1507;
                float3  _S1653 = _slang_select(_S1652, _S1651,_S1370.smooth_n);
                float3  _S1654 = (&ray_2)->origin + make_float3 (_S1650) * _S1653;
                (&ray_2)->origin = _S1654;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1609;
            viewed_1 = _S1505;
            sky_pdf_2 = _S1624;
            spread_5 = _S1625;
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
            spread_5 = spread_2;
            straight_0 = false;
            is_inside_6 = is_inside_7;
        }
        float density_7;
        if(_S1386)
        {
            if(_S1336)
            {
                float3  _S1655 = throughput_9 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1656 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1657 = _S1656 == 1U;
                if(_S1657)
                {
                    float3  _S1658 = safeDivide(_S1655, chain_throughput_0);
                    (&candidate_8)->radiance = _S1658;
                }
                Reservoir _S1659 = withEnd(candidate_8, 2U, b_6, _S1655);
                offer(sel_7, _S1659, _S1655 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1336)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1660 = survivalProbability(throughput_9, density_6);
                density_7 = _S1660;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1661 = stream(_S1222, b_6 + 128U);
            Random _S1662 = pcg(_S1661);
            bool _S1663 = density_7 < (_S1662.value);
            if(_S1663)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1664 = (fcptMaxBounces());
                wrong_side_0 = b_6 >= _S1664;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1665 = density_6 * density_7;
            density_7 = _S1665;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1666 = layer_0 ^ 1U;
        uint _S1667 = _slang_select(passes_0, _S1666,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_4)->distance = 0.0f;
            b_9 = b_6;
            viewed_0 = viewed_1;
            throughput_2 = throughput_9;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_2 = spread_5;
            uint _S1668 = b_9 + 1U;
            b_6 = _S1668;
            layer_0 = _S1667;
            continue;
        }
        FKRay _S1669 = ray_2;
        float _S1670 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1410;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1199 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1671 = _slang_select(wrong_side_0, _S1670,4.294967296e+09f);
        bool _S1672 = !_S1377;
        if(straight_0)
        {
            _S1455 = true;
        }
        else
        {
            _S1455 = _S1377;
        }
        FKHit _S1673;
        if(_S1455)
        {
            _S1673 = hit_4;
        }
        else
        {
            _S1673 = _S1427;
        }
        FKHit _S1674 = (fcptTraverseInstanceBVH((_S1669), (_S1344), (_S1671), (_S1672), (_S1673), (viewed_1)));
        hit_4 = _S1674;
        if(replay_2)
        {
            _S1456 = _S1410;
        }
        else
        {
            _S1456 = false;
        }
        if(_S1456)
        {
            _S1500 = _S1199 == 1U;
        }
        else
        {
            _S1500 = false;
        }
        if(_S1500)
        {
            _S1501 = ((&hit_4)->instance_index) == (_S1211.instance_index);
        }
        else
        {
            _S1501 = false;
        }
        if(_S1501)
        {
            _S1502 = ((&hit_4)->triangle_index) == (_S1211.triangle_index);
        }
        else
        {
            _S1502 = false;
        }
        if(_S1502)
        {
            (&hit_4)->uv = _S1211.uv;
            float _S1675 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1675;
        }
        if(replay_2)
        {
            _S1503 = _S1410;
        }
        else
        {
            _S1503 = false;
        }
        if(_S1503)
        {
            _S1504 = _S1199 == 3U;
        }
        else
        {
            _S1504 = false;
        }
        if(_S1504)
        {
            _S1505 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1505 = false;
        }
        if(_S1505)
        {
            return _S1195;
        }
        Reservoir _S1676 = chain_0;
        uint _S1677 = filling_2;
        for(;;)
        {
            bool _S1678 = (fcptVaryingUsed());
            if(_S1678)
            {
                _S1506 = _S1677 != 4294967295U;
            }
            else
            {
                _S1506 = false;
            }
            float _S1679;
            if(_S1506)
            {
                float _S1680 = (fcptMajorant((_S1677)));
                _S1679 = _S1680;
            }
            else
            {
                _S1679 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1507 = _S1410;
            }
            else
            {
                _S1507 = false;
            }
            if(_S1507)
            {
                _S1508 = _S1199 == 1U;
            }
            else
            {
                _S1508 = false;
            }
            if(_S1508)
            {
                _S1509 = _S1679 > 0.0f;
            }
            else
            {
                _S1509 = false;
            }
            if(_S1509)
            {
                ended_0 = _S1195;
                sky_pdf_1 = sky_pdf_2;
                spread_3 = spread_5;
                width_4 = width_3;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_9 = b_6;
                _S1510 = true;
                break;
            }
            bool _S1681 = (&prev_0)->rough;
            if(_S1681)
            {
                _S1510 = !(_S1679 > 0.0f);
            }
            else
            {
                _S1510 = false;
            }
            (&prev_0)->rough = _S1510;
            uint _S1682 = b_6 + 320U;
            bool _S1683 = b_6 == 4294967295U;
            uint _S1684 = _slang_select(_S1683, 384U,_S1682);
            uint _S1685 = stream(_S1222, _S1684);
            uint tracking_1 = _S1685;
            weight_1 = throughput_3;
            glowed_0 = _S1194;
            b_9 = b_6;
            throughput_10 = throughput_9;
            density_3 = density_7;
            spread_3 = spread_5;
            width_4 = width_3;
            sky_pdf_1 = sky_pdf_2;
            for(;;)
            {
                if(((&hit_4)->instance_index) != 4294967295U)
                {
                }
                else
                {
                    _S1193 = int(2);
                    break;
                }
                uint _S1686 = b_9 + 320U;
                bool _S1687 = b_9 == 4294967295U;
                uint _S1688 = _slang_select(_S1687, 384U,_S1686);
                uint _S1689 = stream(_S1222, _S1688);
                Random _S1690 = pcg(_S1689);
                float _S1691 = freeFlight_0(_S1690.value, _S1679);
                if(_S1506)
                {
                    float3  _S1692 = (&ray_2)->origin;
                    float3  _S1693 = (&ray_2)->unit_direction;
                    float _S1694 = (&hit_4)->distance;
                    uint _S1695 = _slang_select(_S1687, 0U,b_9);
                    uint _S1696 = (&prev_0)->lobe;
                    uint _S1697 = _slang_select(_S1687, 3U,_S1696);
                    float _S1698 = (fcptTrackMedium((_S1677), (_S1692), (_S1693), (_S1694), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1695), (_S1697), (_S1687)));
                    spread_4 = _S1698;
                }
                else
                {
                    spread_4 = _S1691;
                }
                bool _S1699 = !(spread_4 < ((&hit_4)->distance));
                if(_S1699)
                {
                    _S1193 = int(2);
                    break;
                }
                if(_S1506)
                {
                    _S1511 = _S1386;
                }
                else
                {
                    _S1511 = false;
                }
                if(_S1511)
                {
                    float3  _S1700 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1701 = sel_7->glow + _S1700;
                    sel_7->glow = _S1701;
                }
                else
                {
                }
                glowed_0 = _S1194;
                uint b_10 = b_9 + 1U;
                float3  _S1702 = (&ray_2)->origin + make_float3 (spread_4) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1702;
                float3  _S1703 = flightWeight_0(scatter_in_0, extinction_in_0, _S1679, spread_4, true);
                float3  _S1704 = weight_1;
                float3  _S1705 = _slang_select(_S1506, _S1704,_S1703);
                float3  throughput_11 = throughput_10 * _S1705;
                uint _S1706 = stream(_S1222, b_10 + 320U);
                tracking_1 = _S1706;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_3 * spread_4;
                float _S1707 = spread_3 + 3.14159274101257324f;
                bool _S1708 = scatterSampled_0(replay_2, b_10, _S1210, _S1506);
                TreeSample light_4;
                if(_S1708)
                {
                    float3  _S1709 = (&ray_2)->origin;
                    float3  _S1710 = (&ray_2)->unit_direction;
                    float3  _S1711 = (&ray_2)->unit_direction;
                    uint _S1712 = stream(_S1222, b_10 + 64U);
                    float3  _S1713 = extinction_in_0;
                    float3  _S1714 = extinction_in_0;
                    uint2  _S1715 = make_uint2 (_S1677);
                    float3  _S1716 = (&ray_2)->unit_direction;
                    uint _S1717 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                    FKHit _S1718 = _S1427;
                    ShadowContext _S1719 = ShadowContext_x24init_0(_S1713, _S1714, _S1715, _S1716, b_10, _S1717, false, spread_4, width_7, &_S1718, false);
                    ShadowContext _S1720 = _S1719;
                    TreeSample _S1721 = sampleLightTree_0(_S1709, _S1710, _S1711, 0.0f, true, _S1712, &_S1720);
                    light_4 = _S1721;
                }
                else
                {
                    light_4 = _S1424;
                }
                float _S1722 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1723 = (fcptMaxBounces());
                bool _S1724 = b_10 < _S1723;
                if(_S1724)
                {
                    _S1512 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1512 = false;
                }
                float _S1725 = _slang_select(_S1512, _S1722,0.0f);
                float3  _S1726 = throughput_11 * light_4.radiance;
                float _S1727 = powerHeuristic(light_4.density, _S1725);
                float3  _S1728 = _S1726 * make_float3 (_S1722 * _S1727);
                float3  _S1729 = _slang_select(_S1708, _S1728,_S1194);
                if(replay_2)
                {
                    _S1513 = b_10 == _S1210;
                }
                else
                {
                    _S1513 = false;
                }
                if(_S1513)
                {
                    bool _S1730 = _S1199 == 2U;
                    if(_S1730)
                    {
                        float _S1731 = rgb_to_greyscale(_S1729);
                        _S1514 = _S1731 > 0.0f;
                    }
                    else
                    {
                        _S1514 = false;
                    }
                    if(_S1514)
                    {
                        Shift _S1732 = Shift_x24init_0(_S1729, 1.0f);
                        _S1193 = int(1);
                        ended_0 = _S1732;
                        spread_4 = _S1707;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_7 = b_10;
                        break;
                    }
                    _S1193 = int(1);
                    ended_0 = _S1195;
                    spread_4 = _S1707;
                    width_5 = width_7;
                    throughput_8 = throughput_11;
                    b_7 = b_10;
                    break;
                }
                if(_S1386)
                {
                    Reservoir candidate_9 = _S1676;
                    uint _S1733 = extractBits_0(_S1676.path, 10U, 2U);
                    bool _S1734 = _S1733 == 1U;
                    if(_S1734)
                    {
                        float3  _S1735 = safeDivide(_S1729, chain_throughput_0);
                        (&candidate_9)->radiance = _S1735;
                    }
                    else
                    {
                        uint _S1736 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                        uint _S1737 = insertBits_0(_S1736, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1737;
                    }
                    Reservoir _S1738 = withEnd(candidate_9, 0U, b_10, _S1729);
                    offer(sel_7, _S1738, _S1729 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1739 = survivalProbability(throughput_11, density_3);
                    uint _S1740 = stream(_S1222, b_10 + 128U);
                    Random _S1741 = pcg(_S1740);
                    bool _S1742 = _S1739 < (_S1741.value);
                    if(_S1742)
                    {
                        _S1514 = true;
                    }
                    else
                    {
                        uint _S1743 = (fcptMaxBounces());
                        _S1514 = b_10 >= _S1743;
                    }
                    if(_S1514)
                    {
                        _S1193 = int(1);
                        ended_0 = _S1195;
                        spread_4 = _S1707;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_7 = b_10;
                        break;
                    }
                    float _S1744 = density_3 * _S1739;
                    density_3 = _S1744;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1745 = stream(_S1222, b_10);
                float3  _S1746 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1745, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1746;
                NEEVertex _S1747 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1194, (&ray_2)->origin);
                nee_vertex_0 = _S1747;
                Vertex _S1748 = scatteredVertex_0(is_inside_6);
                prev_0 = _S1748;
                float _S1749 = (&prev_0)->pdf;
                FKRay _S1750 = ray_2;
                FKHit _S1751 = (fcptTraverseInstanceBVH((_S1750), (true), (4.294967296e+09f), (false), (_S1427), (false)));
                hit_4 = _S1751;
                b_9 = b_10;
                throughput_10 = throughput_11;
                spread_3 = _S1707;
                width_4 = width_7;
                sky_pdf_1 = _S1749;
            }
            if(_S1193 != int(2))
            {
                spread_3 = spread_4;
                width_4 = width_5;
                throughput_10 = throughput_8;
                b_9 = b_7;
                _S1510 = true;
                break;
            }
            ended_0 = _S1195;
            _S1510 = false;
            break;
        }
        if(_S1510)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1511 = b_9 == b_6;
        }
        else
        {
            _S1511 = false;
        }
        bool _S1752 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1752)
        {
            bool _S1753 = !(&nee_vertex_0)->none;
            float _S1754 = _slang_select(_S1753, sky_pdf_1,0.0f);
            float _S1755 = escapeWeight_0(_S1754, (&ray_2)->unit_direction);
            float3  _S1756 = environment_0((&ray_2)->unit_direction, b_9, (&prev_0)->lobe);
            float3  _S1757 = throughput_10 * _S1756;
            if(replay_2)
            {
                bool _S1758 = b_9 == _S1210;
                if(_S1758)
                {
                    passes_0 = _S1199 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1757 * make_float3 (_S1755) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1209)
                {
                    passes_0 = _S1206;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_9 == _S1197;
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
                    return Shift_x24init_0(_S1757 * make_float3 (_S1755), 1.0f);
                }
                return _S1195;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1759 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1760 = _S1759 == 1U;
            if(_S1760)
            {
                uint _S1761 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1762 = _S1761 == b_9;
                float _S1763 = _slang_select(_S1762, 1.0f,_S1755);
                float3  _S1764 = safeDivide(_S1757 * make_float3 (_S1763), chain_throughput_0);
                (&candidate_10)->radiance = _S1764;
            }
            else
            {
                bool _S1765 = (&prev_0)->rough;
                if(_S1765)
                {
                    uint _S1766 = insertBits_0(0U, b_9 + 1U, 5U, 5U);
                    uint _S1767 = insertBits_0(_S1766, 3U, 10U, 2U);
                    uint _S1768 = insertBits_0(_S1767, (&prev_0)->lobe, 15U, 3U);
                    bool _S1769 = (&prev_0)->inside;
                    uint _S1770 = _slang_select(_S1769, 1U,0U);
                    uint _S1771 = insertBits_0(_S1768, _S1770, 22U, 1U);
                    (&candidate_10)->path = _S1771;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1772 = _S1757 * make_float3 (_S1755);
            Reservoir _S1773 = withEnd(candidate_10, 3U, b_9, _S1772);
            offer(sel_7, _S1773, _S1772 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1774 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1774;
        bool _S1775 = (fcptVaryingUsed());
        if(_S1775)
        {
            _S1512 = filling_2 != 4294967295U;
        }
        else
        {
            _S1512 = false;
        }
        if(_S1512)
        {
            if(_S1386)
            {
                float3  _S1776 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1777 = sel_7->glow + _S1776;
                sel_7->glow = _S1777;
            }
            float3  _S1778 = throughput_10 * weight_1;
            throughput_8 = _S1778;
        }
        else
        {
            float3  _S1779 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1780 = throughput_10 * _S1779;
            throughput_8 = _S1780;
        }
        float _S1781 = width_4 + spread_3 * (&hit_4)->distance;
        viewed_0 = _S1511;
        width_3 = _S1781;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_3;
        uint _S1668 = b_9 + 1U;
        b_6 = _S1668;
        layer_0 = _S1667;
    }
    return _S1195;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_9)
{
    Selection _S1782 = (Selection{});
    Selection sel_8 = _S1782;
    bool _S1783 = (r_9->w) <= 0.0f;
    if(_S1783)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1784 = walk_0(dom_8, r_9, true, 0.0f, &sel_8);
    return _S1784;
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

__device__ Random normal_distribution(uint state_4)
{
    Random _S1785 = pcg(state_4);
    Random _S1786 = pcg(_S1785.state);
    float _S1787 = 6.28318548202514648f * _S1785.value;
    float _S1788 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1786.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1786.state, _S1788 * (F32_cos((_S1787))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S1789;
    (&_S1789)->state = state_5;
    (&_S1789)->value = value_2;
    return _S1789;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S1790 = normal_distribution(state_6);
    Random _S1791 = normal_distribution(_S1790.state);
    Random _S1792 = normal_distribution(_S1791.state);
    float3  _S1793 = make_float3 (_S1790.value, _S1791.value, _S1792.value);
    float3  _S1794 = ((((_S1793)) * make_float3(rnorm3df(((_S1793)).x, ((_S1793)).y, ((_S1793)).z))));
    return RandomSphere_x24init_0(_S1792.state, _S1794);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_12)
{
    float3  _S1795 = p1_0 - p0_0;
    float3  _S1796 = p2_0 - p0_0;
    float2  _S1797 = uv1_0 - uv0_0;
    float2  _S1798 = uv2_0 - uv0_0;
    float _S1799 = _S1797.x;
    float _S1800 = _S1798.y;
    float _S1801 = _S1797.y;
    float _S1802 = _S1798.x;
    float _S1803 = _S1799 * _S1800 - _S1801 * _S1802;
    float _S1804 = 1.0f / _S1803;
    float3  t_22 = (_S1795 * make_float3 (_S1800) - _S1796 * make_float3 (_S1801)) * make_float3 (_S1804);
    float3  _S1805 = (_S1796 * make_float3 (_S1799) - _S1795 * make_float3 (_S1802)) * make_float3 (_S1804);
    float3  _S1806 = t_22 - n_12 * make_float3 (dot_0(n_12, t_22));
    float3  t_23 = ((((_S1806)) * make_float3(rnorm3df(((_S1806)).x, ((_S1806)).y, ((_S1806)).z))));
    bool _S1807 = (dot_0(cross_0(n_12, t_23), _S1805)) > 0.0f;
    float3  t_24;
    if(_S1807)
    {
        float3  _S1808 = negate_0(t_23);
        t_24 = _S1808;
    }
    else
    {
        t_24 = t_23;
    }
    float3  _S1809 = cross_0(n_12, t_24);
    return makeMatrix<float, 3, 3> (t_24, _S1809, n_12);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1810 = t1_0 - t0_0;
    float3  _S1811 = t2_2 - t0_0;
    float3  _S1812 = t2_2 - t1_0;
    float _S1813 = (F32_min((length_0(_S1810)), ((F32_min((length_0(_S1811)), (length_0(_S1812)))))));
    float3  _S1814 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1815 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1816 = dot_0(geometry_n_5, _S1815);
    float3  _S1817 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1818 = dot_0(geometry_n_5, _S1817);
    float3  _S1819 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1820 = acos_0(abs_0(make_float3 (_S1816, _S1818, dot_0(geometry_n_5, _S1819))));
    float3  _S1821 = clamp_2(tan_0(_S1820), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1814 * _S1821, uvw_0), 0.0f, _S1813 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_15, float3  n_13, BSDFMaterial material_23)
{
    float3  _S1822 = negate_0(dir_15);
    float _S1823 = sign_0(dot_0(n_13, _S1822));
    float3  _S1824 = n_13 * make_float3 (_S1823);
    AnisotropicFrame _S1825 = anisotropicFrame(material_23, _S1824);
    bool _S1826 = (_S1825.alphas.x) > 0.0f;
    if(_S1826)
    {
        float _S1827 = material_23.transmission * (1.0f - material_23.metallic);
        float3  _S1828 = negate_0(_S1824);
        float3  _S1829 = anisotropicLocal(dir_15, _S1825.tangent, _S1828);
        float _S1830 = anisotropicG1(_S1829, _S1825.alphas);
        return make_float3 (_S1827 * _S1830) * material_23.albedo;
    }
    float _S1831 = material_23.transmission * (1.0f - material_23.metallic);
    float _S1832 = material_23.roughness;
    float _S1833 = smithG1(_S1832 * _S1832, (F32_abs((dot_0(n_13, dir_15)))));
    return make_float3 (_S1831 * _S1833) * material_23.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_25, float3  out_dir_3, uint p_14, float w_2, float alpha_20, uint nt_0)
{
    uint _S1834 = p_14 % 4U;
    float _S1835 = w_2 * HAIR_WIDTHS_0[_S1834];
    float _S1836 = (F32_asin((clamp_1(dot_0(out_dir_3, t_25), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_25), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1834] * alpha_20;
    return ((F32_asinh((_S1836 / _S1835))) / (F32_asinh((3.14159274101257324f / _S1835))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_26, float3  out_dir_4, uint np_0)
{
    float3  _S1837 = worldToTangent(out_dir_4, t_26);
    float3  _S1838 = worldToTangent(in_dir_12, t_26);
    return (F32_frac((((F32_atan2((_S1837.z), (_S1837.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1838.z), (1.17549435082228751e-38f - _S1838.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_27, uint p_15, float row_0, float column_0, float w_3, float alpha_21, uint nt_1, uint np_1)
{
    float3  _S1839 = worldToTangent(in_dir_13, t_27);
    uint _S1840 = p_15 % 4U;
    float _S1841 = w_3 * HAIR_WIDTHS_0[_S1840];
    float _S1842 = (F32_asin((clamp_1(dot_0(in_dir_13, t_27), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1840] * alpha_21 + _S1841 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1841))))));
    float _S1843 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1839.z), (1.17549435082228751e-38f - _S1839.x)));
    float _S1844 = (F32_cos((_S1842)));
    float3  _S1845 = tangentToWorld(make_float3 (_S1844 * (F32_cos((_S1843))), (F32_sin((_S1842))), _S1844 * (F32_sin((_S1843)))), t_27);
    return _S1845;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_14, BSDFMaterial material_24, float coverage_1)
{
    float3  _S1846;
    if((material_24.ior) == 1.0f)
    {
        float3  _S1847 = straightThrough(toward_1, n_14, material_24);
        _S1846 = _S1847;
    }
    else
    {
        _S1846 = make_float3 (0.0f);
    }
    return _S1846 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_4, Selection * sel_9)
{
    Domain _S1848 = dom_9;
    Reservoir _S1849 = r_10;
    Shift _S1850 = walk_0(&_S1848, &_S1849, replay_3, scale_4, sel_9);
    return _S1850;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_11)
{
    Domain _S1851 = dom_10;
    Reservoir _S1852 = r_11;
    Shift _S1853 = shift_0(&_S1851, &_S1852);
    return _S1853;
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
