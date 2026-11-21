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
        int2  _S157 = make_int2 (int(-1));
        bool _S158 = previousValid_0(p_8);
        int2  _S159 = _slang_select(_S158, p_8,_S157);
        return _S159;
    }
    float3  _S160 = make_float3 (0.0f);
    FKHit _S161 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S162 = Domain_x24init_0(_S160, _S160, &_S161, 0.0f, 0.0f);
    Domain dom_3 = _S162;
    uint2  _S163 = (fcptRenderSize());
    int2  _S164 = make_int2 ((int)_S163.x, (int)_S163.y);
    bool _S165 = any_0(p_8 >= _S164);
    bool _S166;
    if(_S165)
    {
        _S166 = true;
    }
    else
    {
        bool _S167 = (fcptStoredDomainInitial((p_8), (seed_2), (&dom_3)));
        _S166 = !_S167;
    }
    if(_S166)
    {
        return make_int2 (int(-1));
    }
    Domain _S168 = dom_3;
    int2  _S169 = temporalNeighbor_0(p_8, &_S168, seed_2);
    return _S169;
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
    FKRay _S170;
    (&_S170)->origin = origin_0;
    (&_S170)->unit_direction = unit_direction_0;
    return _S170;
}

static __device__ float3  skyRadiance_0(float3  origin_1, FKSurface * surface_0, bool is_inside_1, float3  dir_1, ShadowContext * context_0, uint random_state_0)
{
    bool _S171 = wrongSide_0(is_inside_1, false, dir_1, surface_0->geometry_n);
    bool _S172 = is_inside_1 != _S171;
    float _S173 = surface_0->geometry_offset;
    float3  _S174 = surface_0->smooth_n;
    float3  _S175 = - surface_0->smooth_n;
    float3  _S176 = _slang_select(_S172, _S175,_S174);
    FKRay _S177 = Ray_x24init_0(origin_1 + make_float3 (_S173) * _S176, dir_1);
    bool _S178 = (dot_0(context_0->side, dir_1)) > 0.0f;
    bool _S179 = (fcptWorldReadsPath());
    float3  _S180;
    if(_S179)
    {
        _S180 = make_float3 (1.0f);
    }
    else
    {
        float3  _S181 = (fcptEnvMapSample((dir_1), (0U), (3U)));
        _S180 = _S181;
    }
    float3  _S182 = context_0->extinction_behind;
    float3  _S183 = context_0->extinction_front;
    float3  _S184 = _slang_select(_S178, _S183,_S182);
    uint _S185 = context_0->fillings.x;
    uint _S186 = context_0->fillings.y;
    uint _S187 = _slang_select(_S178, _S186,_S185);
    uint _S188 = context_0->depth;
    uint _S189 = context_0->lobe;
    bool _S190 = context_0->surface;
    bool _S191;
    if(_S190)
    {
        _S191 = !context_0->fiber;
    }
    else
    {
        _S191 = false;
    }
    float _S192 = context_0->length;
    float _S193 = context_0->width;
    FKHit _S194 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    float3  _S195 = (fcptShadowTransmittanceIn((_S177), (4.294967296e+09f), (_S184), (_S187), (random_state_0), (_S188), (_S189), (_S191), (_S192), (_S193), (_S194), (_S194)));
    return _S180 * _S195;
}

static __device__ uint searchCDF_0(uint2  start_4, uint2  step_0, uint count_1, float u_0)
{
    uint _S196 = count_1 - 1U;
    uint low_0 = 0U;
    uint high_0 = _S196;
    for(;;)
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        uint _S197 = (low_0 + high_0) / 2U;
        float4  _S198 = (fcptEnvironmentCdf((start_4 + step_0 * make_uint2 (_S197))));
        bool _S199 = (_S198.x) > u_0;
        if(_S199)
        {
            high_0 = _S197;
        }
        else
        {
            uint _S200 = _S197 + 1U;
            low_0 = _S200;
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
    float3  _S201 = ((((light_dir_0)) * make_float3(rnorm3df(((light_dir_0)).x, ((light_dir_0)).y, ((light_dir_0)).z))));
    bool _S202 = (dot_0(smooth_n_0, _S201)) < 0.0f;
    if(_S202)
    {
        return make_float3 (0.0f);
    }
    float3  _S203 = make_float3 (geometry_offset_0) * smooth_n_0;
    float3  _S204 = origin_2 + _S203;
    FKRay _S205 = Ray_x24init_0(_S204, _S201);
    bool _S206 = (dot_0(context_1->side, light_dir_0 + _S203)) > 0.0f;
    float _S207 = shadowLength(light_dir_0);
    float3  _S208 = context_1->extinction_behind;
    float3  _S209 = context_1->extinction_front;
    float3  _S210 = _slang_select(_S206, _S209,_S208);
    uint _S211 = context_1->fillings.x;
    uint _S212 = context_1->fillings.y;
    uint _S213 = _slang_select(_S206, _S212,_S211);
    uint _S214 = context_1->depth;
    uint _S215 = context_1->lobe;
    bool _S216 = context_1->surface;
    bool _S217;
    if(_S216)
    {
        _S217 = !context_1->fiber;
    }
    else
    {
        _S217 = false;
    }
    float _S218 = context_1->length;
    float _S219 = context_1->width;
    FKHit _S220;
    if(context_1->fiber)
    {
        _S220 = context_1->own;
    }
    else
    {
        _S220 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    }
    float3  _S221 = (fcptShadowTransmittanceIn((_S205), (_S207), (_S210), (_S213), (random_state_1), (_S214), (_S215), (_S217), (_S218), (_S219), (_S220), (*light_0)));
    return _S221;
}

__device__ float sine(float c_0)
{
    return (F32_sqrt(((F32_max((1.0f - c_0 * c_0), (0.0f))))));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S222 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S223 = cos_a_0 > cos_b_0;
    float _S224 = _slang_select(_S223, 1.0f,_S222);
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
    float _S240 = _S239 * node_0.cos_theta_o - _S231 * _S232;
    bool _S241 = _S231 > (node_0.cos_theta_o);
    float _S242 = _slang_select(_S241, 0.0f,_S240);
    float _S243 = cosSubClamped(_S242, _S238, _S236, _S235);
    bool _S244 = _S243 <= 0.0f;
    if(_S244)
    {
        return 0.0f;
    }
    float _S245 = - dot_0(_S228, normal_0);
    float _S246 = node_0.phi * _S243 / (F32_max((_S229), (length_0(_S226) / 2.0f)));
    float _S247 = sine(_S245);
    float _S248 = cosSubClamped(_S247, _S245, _S236, _S235);
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
        FKLight _S289 = (fcptLight((_S287.y)));
        float _S290 = sphereDensity(_S289.position, _S289.variance, start_5);
        return probability_1 * _S290;
    }
    uint _S291 = _S287.y;
    uint _S292 = (fcptTriangleOffset((_S291)));
    Matrix<float, 3, 3>  _S293 = (fcptWorldTriangle((_S291), (_S292 + _S287.z)));
    float _S294 = solidAngle(probability_1, cross_0(_S293.rows[int(1)] - _S293.rows[int(0)], _S293.rows[int(2)] - _S293.rows[int(0)]), light_point_0 - start_5);
    return _S294;
}

static __device__ float3  environment_0(float3  dir_2, uint depth_0, uint lobe_0)
{
    uint2  _S295 = (fcptEnvironmentMapSize());
    bool _S296 = all_0(_S295 > make_uint2 (1U));
    if(_S296)
    {
        float3  _S297 = (fcptEnvMapSample((dir_2), (depth_0), (lobe_0)));
        return _S297;
    }
    float3  _S298 = (fcptAmbient());
    return _S298;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S299 = (fcptEnvironmentCdfSize());
    bool _S300 = !all_0(_S299 > make_uint2 (1U));
    if(_S300)
    {
        return false;
    }
    uint2  _S301 = (fcptEnvironmentMapSize());
    return all_0(_S301 > make_uint2 (1U));
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

static __device__ float environmentPdf_0(float3  dir_3)
{
    uint2  _S302 = (fcptEnvironmentCdfSize());
    uint2  _S303 = _S302 - make_uint2 (1U, 0U);
    float2  _S304 = make_float2 ((F32_atan2((- dir_3.y), (dir_3.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_1(dir_3.z, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S305 = make_float2 ((float)_S303.x, (float)_S303.y);
    float2  _S306 = _S304 * _S305;
    uint2  _S307 = make_uint2 ((uint)_S306.x, (uint)_S306.y);
    uint2  _S308 = min_0(_S307, _S303 - make_uint2 (1U));
    float4  _S309 = (fcptEnvironmentCdf((_S308)));
    float _S310 = _S309.y;
    uint _S311 = _S303.x;
    float4  _S312 = (fcptEnvironmentCdf((make_uint2 (_S311, _S308.y))));
    float _S313 = _S310 * _S312.y;
    return _S313 * float(_S311 * _S303.y) / (19.73921012878417969f * length_1(float2 {dir_3.x, dir_3.y}));
}

static __device__ float escapeWeight_0(float pdf_0, float3  dir_4)
{
    bool _S314 = pdf_0 <= 0.0f;
    bool _S315;
    if(_S314)
    {
        _S315 = true;
    }
    else
    {
        bool _S316 = environmentMapped_0();
        _S315 = !_S316;
    }
    if(_S315)
    {
        return 1.0f;
    }
    float _S317 = environmentPdf_0(dir_4);
    return pdf_0 / (pdf_0 + _S317);
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
    Random _S318;
    (&_S318)->state = state_0;
    (&_S318)->value = value_0;
    return _S318;
}

__device__ Random pcg(uint state_1)
{
    uint _S319 = hash(state_1);
    float value_1 = float(_S319 >> int(8)) * 5.9604644775390625e-08f;
    return Random_x24init_0(_S319, value_1);
}

__device__ static const FixedArray<float, 243>  SPECTRAL_PRIMARIES_0 = { {
    0.028201999142766f, 9.99999997475242708e-07f, 0.97179698944091797f, 0.02820000052452087f, 0.0f, 0.97180002927780151f, 0.02819300070405006f, 0.0f, 0.97180700302124023f, 0.0281750001013279f, 0.0f, 0.9718250036239624f, 0.02813299931585789f, 0.0f, 0.97186702489852905f, 0.02804199978709221f, 0.0f, 0.9719579815864563f, 0.02786399982869625f, 0.0f, 0.97213602066040039f, 0.0275299996137619f, 0.0f, 0.9724699854850769f, 0.02692800015211105f, 0.0f, 0.97307199239730835f, 0.02592499926686287f, 0.0f, 0.97407501935958862f, 0.02444599941372871f, 0.0f, 0.97555398941040039f, 0.02258899994194508f, 0.0f, 0.97741097211837769f, 0.02068600058555603f, 0.0f, 0.97931402921676636f, 0.01939599961042404f, 0.0f, 0.98060399293899536f, 0.01972600072622299f, 0.0f, 0.9802740216255188f, 0.02305700071156025f, 0.0f, 0.97694301605224609f, 0.0282990001142025f, 0.00548999989405274f, 0.96621102094650269f, 0.02276800014078617f, 0.04560500010848045f, 0.93162697553634644f, 0.0118180001154542f, 0.11352799832820892f, 0.87465399503707886f, 0.00192399998195469f, 0.20037899911403656f, 0.79769700765609741f, 0.0f, 0.29692500829696655f, 0.70307499170303345f, 0.0f, 0.40064999461174011f, 0.5993499755859375f, 0.0f, 0.50742298364639282f, 0.49257698655128479f, 0.0f, 0.61289197206497192f, 0.38710799813270569f, 0.0f, 0.71311402320861816f, 0.28688600659370422f, 0.0f, 0.8042140007019043f, 0.1957859992980957f, 0.0f, 0.88220900297164917f, 0.11779099702835083f, 0.0f, 0.94313102960586548f, 0.05686900019645691f, 0.0f, 0.98336499929428101f, 0.01663500070571899f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.99855601787567139f, 0.00144400005228817f, 0.0f, 0.97892600297927856f, 0.02107400074601173f, 0.03028500080108643f, 0.92923498153686523f, 0.04047999903559685f, 0.10447199642658234f, 0.84615302085876465f, 0.04937500134110451f, 0.21104000508785248f, 0.73897498846054077f, 0.04998499900102615f, 0.33820000290870667f, 0.61719298362731934f, 0.04460699856281281f, 0.47420701384544373f, 0.49019300937652588f, 0.03559999912977219f, 0.60847699642181396f, 0.3664110004901886f, 0.02511199936270714f, 0.73185497522354126f, 0.25317299365997314f, 0.01497200038284063f, 0.83687901496887207f, 0.15642799437046051f, 0.00669299997389317f, 0.91802400350570679f, 0.08053100109100342f, 0.00144499994348735f, 0.97194302082061768f, 0.02805699966847897f, 0.0f, 0.99879997968673706f, 0.00120000005699694f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999797344207764f, 9.99999997475242708e-07f, 9.99999997475242708e-07f, 0.99999797344207764f, 9.99999997475242708e-07f, 9.99999997475242708e-07f, 0.99999701976776123f, 9.99999997475242708e-07f, 1.99999999495048542e-06f, 0.99999499320983887f, 1.99999999495048542e-06f, 3.00000010611256585e-06f, 0.99999302625656128f, 1.99999999495048542e-06f, 4.99999987368937582e-06f, 0.99998897314071655f, 3.99999998990097083e-06f, 7.00000009601353668e-06f, 0.9999840259552002f, 6.00000021222513169e-06f, 0.00000999999974738f, 0.99997901916503906f, 0.0000079999999798f, 0.00001299999985349f, 0.99997401237487793f, 0.00000999999974738f, 0.0000159999999596f, 0.99997299909591675f, 0.00001200000042445f, 0.00001499999962107f, 0.99996697902679443f, 0.00001499999962107f, 0.00001800000063668f, 0.9999690055847168f, 0.00001499999962107f, 0.0000159999999596f, 0.9999619722366333f, 0.00001700000029814f, 0.00002099999983329f
} };
__device__ float upsample(float3  rgb_0, float wavelength_0)
{
    float _S320 = clamp_1((wavelength_0 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S321 = (U32_min((uint(_S320)), (79U)));
    uint _S322 = 3U * _S321;
    float3  _S323 = make_float3 (SPECTRAL_PRIMARIES_0[_S322], SPECTRAL_PRIMARIES_0[_S322 + 1U], SPECTRAL_PRIMARIES_0[_S322 + 2U]);
    float3  _S324 = make_float3 (SPECTRAL_PRIMARIES_0[_S322 + 3U], SPECTRAL_PRIMARIES_0[_S322 + 4U], SPECTRAL_PRIMARIES_0[_S322 + 5U]);
    return dot_0(rgb_0, _S323 + (_S324 - _S323) * make_float3 (_S320 - float(_S321)));
}

__device__ BSDFMaterial atWavelength(BSDFMaterial material_0, float wavelength_1)
{
    BSDFMaterial at_0 = material_0;
    float _S325 = upsample(material_0.albedo, wavelength_1);
    float3  _S326 = make_float3 (_S325);
    (&at_0)->albedo = _S326;
    float _S327 = upsample(material_0.emissive, wavelength_1);
    float3  _S328 = make_float3 (_S327);
    (&at_0)->emissive = _S328;
    float _S329 = upsample(material_0.absorption, wavelength_1);
    float3  _S330 = make_float3 (_S329);
    (&at_0)->absorption = _S330;
    float _S331 = upsample(material_0.specular_tint, wavelength_1);
    float3  _S332 = make_float3 (_S331);
    (&at_0)->specular_tint = _S332;
    float _S333 = upsample(material_0.translucent, wavelength_1);
    float3  _S334 = make_float3 (_S333);
    (&at_0)->translucent = _S334;
    float _S335 = upsample(material_0.sheen, wavelength_1);
    float3  _S336 = make_float3 (_S335);
    (&at_0)->sheen = _S336;
    return at_0;
}

__device__ BSDFMaterial pathMaterial(BSDFMaterial material_1, float wavelength_2)
{
    BSDFMaterial _S337;
    if(wavelength_2 > 0.0f)
    {
        BSDFMaterial _S338 = atWavelength(material_1, wavelength_2);
        _S337 = _S338;
    }
    else
    {
        _S337 = material_1;
    }
    return _S337;
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    bool _S339 = e_1 < 0.0f;
    float _S340 = _slang_select(_S339, -1.0f,0.0f);
    bool _S341 = e_1 > 0.0f;
    float _S342 = _slang_select(_S341, 1.0f,_S340);
    return _S342;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S343;
    (&_S343)->tangent = tangent_0;
    (&_S343)->alphas = alphas_0;
    return _S343;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S344 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S344)
    {
        float3  _S345 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S345;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S346 = cross_0(n_1, a_2);
    float3  _S347 = ((((_S346)) * make_float3(rnorm3df(((_S346)).x, ((_S346)).y, ((_S346)).z))));
    float3  _S348 = cross_0(n_1, _S347);
    return make_float3 (v_0.x) * _S347 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S348;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_2, float3  n_i_0)
{
    float _S349 = material_2.roughness;
    float _S350 = _S349 * _S349;
    bool _S351 = (material_2.anisotropy) == 0.0f;
    bool _S352;
    if(_S351)
    {
        _S352 = true;
    }
    else
    {
        _S352 = !(_S350 > 0.0f);
    }
    if(_S352)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S353 = material_2.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_2.tangent));
    float3  _S354 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S355 = (dot_0(_S353, _S353)) > 0.0f;
    float3  _S356 = _slang_select(_S355, _S353,_S354);
    float3  _S357 = ((((_S356)) * make_float3(rnorm3df(((_S356)).x, ((_S356)).y, ((_S356)).z))));
    float _S358 = 6.28318548202514648f * material_2.anisotropic_rotation;
    float _S359 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_2.anisotropy))))));
    float _S360 = 1.0f / _S359;
    bool _S361 = (material_2.anisotropy) < 0.0f;
    float _S362 = _slang_select(_S361, _S360,_S359);
    return AnisotropicFrame_x24init_0(_S357 * make_float3 ((F32_cos((_S358)))) + cross_0(n_i_0, _S357) * make_float3 ((F32_sin((_S358)))), make_float2 (_S350 / _S362, _S350 * _S362));
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S363;
    (&_S363)->on = on_0;
    (&_S363)->albedo = albedo_0;
    return _S363;
}

__device__ float rgb_to_greyscale(float3  rgb_1)
{
    return dot_0(rgb_1, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

__device__ static const FixedArray<float, 576>  VELVET_ALBEDO_0 = { {
    1.03603994846343994f, 1.04969000816345215f, 1.02470004558563232f, 1.01461005210876465f, 1.00961005687713623f, 1.00680005550384521f, 1.0050499439239502f, 1.00390005111694336f, 1.00312995910644531f, 1.00258004665374756f, 1.00213003158569336f, 1.0017399787902832f, 1.00138998031616211f, 1.00112998485565186f, 1.00097000598907471f, 1.00092995166778564f, 1.00098001956939697f, 1.00108003616333008f, 1.0011899471282959f, 1.00127995014190674f, 1.0013200044631958f, 1.00134003162384033f, 1.00133001804351807f, 1.00130999088287354f, 0.90734100341796875f, 0.98275798559188843f, 0.98386698961257935f, 0.98714500665664673f, 0.98988902568817139f, 0.99194902181625366f, 0.99348098039627075f, 0.99463999271392822f, 0.99551397562026978f, 0.99620199203491211f, 0.99678301811218262f, 0.99725902080535889f, 0.99762099981307983f, 0.99788099527359009f, 0.99806898832321167f, 0.99822998046875f, 0.9984009861946106f, 0.99860197305679321f, 0.99882900714874268f, 0.99905097484588623f, 0.99924802780151367f, 0.99941599369049072f, 0.99955397844314575f, 0.99966597557067871f, 0.47049999237060547f, 0.72047901153564453f, 0.82541298866271973f, 0.88024801015853882f, 0.91317099332809448f, 0.93422400951385498f, 0.94845300912857056f, 0.9585450291633606f, 0.96597200632095337f, 0.97161900997161865f, 0.97599798440933228f, 0.97946298122406006f, 0.98225301504135132f, 0.98453700542449951f, 0.98643702268600464f, 0.98803901672363281f, 0.98940402269363403f, 0.99057799577713013f, 0.99159497022628784f, 0.9924740195274353f, 0.99323201179504395f, 0.99394601583480835f, 0.9946179986000061f, 0.99514299631118774f, 0.10339099913835526f, 0.37652701139450073f, 0.58990597724914551f, 0.7168310284614563f, 0.79374098777770996f, 0.8438420295715332f, 0.87787497043609619f, 0.90189200639724731f, 0.919514000415802f, 0.93284100294113159f, 0.94317400455474854f, 0.95135498046875f, 0.95794999599456787f, 0.9633520245552063f, 0.96783697605133057f, 0.97160798311233521f, 0.97481298446655273f, 0.97755998373031616f, 0.97992998361587524f, 0.98198497295379639f, 0.98377299308776855f, 0.98532998561859131f, 0.98668897151947021f, 0.98788100481033325f, 0.00549574987962842f, 0.12130799889564514f, 0.33038300275802612f, 0.50957399606704712f, 0.63582301139831543f, 0.72130399942398071f, 0.78063100576400757f, 0.82337701320648193f, 0.85500001907348633f, 0.87895798683166504f, 0.89755398035049438f, 0.91228801012039185f, 0.92417001724243164f, 0.93390399217605591f, 0.94199001789093018f, 0.94878798723220825f, 0.95456397533416748f, 0.95951497554779053f, 0.96378600597381592f, 0.96749001741409302f, 0.97071200609207153f, 0.97352099418640137f, 0.97597402334213257f, 0.97811698913574219f, 0.00006616840255447f, 0.01978570036590099f, 0.13480900228023529f, 0.30441498756408691f, 0.4568449854850769f, 0.57461702823638916f, 0.66137099266052246f, 0.72547799348831177f, 0.77361601591110229f, 0.81061500310897827f, 0.83951497077941895f, 0.86248302459716797f, 0.88104599714279175f, 0.89627498388290405f, 0.90893799066543579f, 0.91959297657012939f, 0.92865198850631714f, 0.93641901016235352f, 0.94312202930450439f, 0.94893598556518555f, 0.95399397611618042f, 0.95840400457382202f, 0.96225601434707642f, 0.96562099456787109f, 6.08604011631541653e-08f, 0.00167625001631677f, 0.03686590120196342f, 0.14405199885368347f, 0.28643798828125f, 0.41852200031280518f, 0.5268089771270752f, 0.61179697513580322f, 0.67761099338531494f, 0.72897201776504517f, 0.76956802606582642f, 0.80211901664733887f, 0.82861298322677612f, 0.85041999816894531f, 0.86859399080276489f, 0.88391202688217163f, 0.89695101976394653f, 0.90814197063446045f, 0.91780698299407959f, 0.9261929988861084f, 0.933493971824646f, 0.93986201286315918f, 0.94542300701141357f, 0.95028501749038696f, 1.25722999719246609e-12f, 0.00005344190140022f, 0.00689807021990418f, 0.05298750102519989f, 0.15135200321674347f, 0.27379500865936279f, 0.38978201150894165f, 0.48924699425697327f, 0.57068902254104614f, 0.6363450288772583f, 0.68930798768997192f, 0.73230600357055664f, 0.7675589919090271f, 0.79679697751998901f, 0.82128000259399414f, 0.84197902679443359f, 0.85963702201843262f, 0.87481701374053955f, 0.88794499635696411f, 0.89934700727462769f, 0.90928000211715698f, 0.91794902086257935f, 0.92552399635314941f, 0.93214702606201172f, 1.32430000482605838e-19f, 4.34398998550022952e-07f, 0.00078319699969143f, 0.01505979988723993f, 0.06700140237808228f, 0.15685500204563141f, 0.26414799690246582f, 0.36752399802207947f, 0.45892399549484253f, 0.53633898496627808f, 0.60086798667907715f, 0.65432101488113403f, 0.69876497983932495f, 0.73594701290130615f, 0.76730400323867798f, 0.79397499561309814f, 0.8168100118637085f, 0.83649301528930664f, 0.85354900360107422f, 0.86838698387145996f, 0.88132798671722412f, 0.89263200759887695f, 0.90251702070236206f, 0.91116297245025635f, 1.21214998864702984e-29f, 5.61858004566317959e-10f, 0.00004580340100802f, 0.00315008009783924f, 0.02455909922719002f, 0.07877019792795181f, 0.16104799509048462f, 0.25635600090026855f, 0.34949898719787598f, 0.43382999300956726f, 0.50729697942733765f, 0.57010501623153687f, 0.62341398000717163f, 0.66865599155426025f, 0.70718997716903687f, 0.74018502235412598f, 0.76862901449203491f, 0.79324597120285034f, 0.8146439790725708f, 0.83329999446868896f, 0.84960097074508667f, 0.86386102437973022f, 0.87634098529815674f, 0.88726699352264404f, 1.17709071003284634e-43f, 6.58941014274917747e-14f, 1.12094994619837962e-06f, 0.00044787500519305f, 0.00728174997493625f, 0.03418119996786118f, 0.08846849948167801f, 0.16411800682544708f, 0.24980400502681732f, 0.33453500270843506f, 0.41271701455116272f, 0.48244500160217285f, 0.54331201314926147f, 0.59608602523803711f, 0.64167797565460205f, 0.68114197254180908f, 0.71539402008056641f, 0.7452319860458374f, 0.77129900455474854f, 0.79410398006439209f, 0.81407999992370605f, 0.83158797025680542f, 0.846934974193573f, 0.86038398742675781f, 0.0f, 3.5722200588590534e-19f, 8.93677043478646738e-09f, 0.00003873859895975f, 0.00167270004749298f, 0.01264849957078695f, 0.04320650175213814f, 0.09630840271711349f, 0.16610400378704071f, 0.24392600357532501f, 0.32165700197219849f, 0.394569993019104f, 0.46081000566482544f, 0.51976299285888672f, 0.57175701856613159f, 0.61742901802062988f, 0.65750598907470703f, 0.69269400835037231f, 0.72362500429153442f, 0.75082802772521973f, 0.77473902702331543f, 0.79575198888778687f, 0.81420797109603882f, 0.83040601015090942f, 0.0f, 3.95292991891679393e-26f, 1.71184993263961971e-11f, 1.77651998001238098e-06f, 0.0002783710078802f, 0.00388711993582547f, 0.01858510076999664f, 0.05124599859118462f, 0.10246899724006653f, 0.16709500551223755f, 0.23837999999523163f, 0.31022000312805176f, 0.37857699394226074f, 0.44168499112129211f, 0.4988040030002594f, 0.54993897676467896f, 0.59550100564956665f, 0.63594001531600952f, 0.67177599668502808f, 0.70349597930908203f, 0.73152798414230347f, 0.75625097751617432f, 0.77802300453186035f, 0.79716801643371582f, 0.0f, 3.2483199352805935e-35f, 5.40527002565222188e-15f, 3.64182994871953269e-08f, 0.00003074659980484f, 0.00094859098317102f, 0.00691073015332222f, 0.02452139928936958f, 0.05809320136904716f, 0.10707399994134903f, 0.16711099445819855f, 0.23287899792194366f, 0.29971298575401306f, 0.36412099003791809f, 0.42443698644638062f, 0.47984799742698669f, 0.53011900186538696f, 0.57539498805999756f, 0.61597698926925659f, 0.65218400955200195f, 0.6844019889831543f, 0.71295899152755737f, 0.73819798231124878f, 0.7604449987411499f, 0.0f, 0.0f, 1.7447100275121598e-19f, 2.68698008287771017e-10f, 2.01520992959558498e-06f, 0.00017266000213567f, 0.00214895000681281f, 0.01039279997348785f, 0.03002390079200268f, 0.06362999975681305f, 0.11018999665975571f, 0.16611799597740173f, 0.22714599967002869f, 0.2896830141544342f, 0.35065999627113342f, 0.40850698947906494f, 0.46232399344444275f, 0.51169002056121826f, 0.55654400587081909f, 0.59701400995254517f, 0.63333100080490112f, 0.66571998596191406f, 0.69448697566986084f, 0.71991300582885742f, 0.0f, 0.0f, 3.08185990824019565e-25f, 5.37352009676722586e-13f, 6.76860025805581245e-08f, 0.00002156710070267f, 0.00053187098819762f, 0.00379640003666282f, 0.01394980028271675f, 0.03477099910378456f, 0.06777119636535645f, 0.11182600259780884f, 0.16402900218963623f, 0.22092700004577637f, 0.27971801161766052f, 0.33767500519752502f, 0.3932889997959137f, 0.44556498527526855f, 0.493927001953125f, 0.53815799951553345f, 0.57827800512313843f, 0.61434602737426758f, 0.64652997255325317f, 0.67506802082061768f, 0.0f, 0.0f, 1.27565998769738086e-32f, 1.98236004320260421e-16f, 9.54645029693779179e-10f, 1.650769945626962e-06f, 0.00009778440289665f, 0.00114505004603416f, 0.00568277994170785f, 0.01722680032253265f, 0.03851649910211563f, 0.0704336017370224f, 0.11193899810314178f, 0.16071000695228577f, 0.21397699415683746f, 0.2693760097026825f, 0.32457900047302246f, 0.37806499004364014f, 0.42872300744056702f, 0.4758630096912384f, 0.51915699243545532f, 0.55846899747848511f, 0.59376901388168335f, 0.62519502639770508f, 0.0f, 0.0f, 3.7106383335321156e-42f, 7.81385018096993734e-21f, 4.26179013954253172e-12f, 6.59224994592477742e-08f, 0.00001210350001202f, 0.00026765500660986f, 0.00194808002561331f, 0.00754345022141933f, 0.01991299912333488f, 0.04105570167303085f, 0.0715148001909256f, 0.11042399704456329f, 0.15595099329948425f, 0.20584699511528015f, 0.25806799530982971f, 0.31055599451065063f, 0.36178100109100342f, 0.41049200296401978f, 0.45592901110649109f, 0.49765899777412415f, 0.53551197052001953f, 0.56948697566986084f, 0.0f, 0.0f, 0.0f, 1.4501699354155858e-26f, 3.9408500097373126e-15f, 1.07906994450956972e-09f, 8.70304006639344152e-07f, 0.0000440725016233f, 0.0005269440007396f, 0.00279516004957259f, 0.00910075008869171f, 0.02173379994928837f, 0.04219720140099525f, 0.07087449729442596f, 0.10709299892187119f, 0.14939899742603302f, 0.19591200351715088f, 0.24481700360774994f, 0.29424700140953064f, 0.34261700510978699f, 0.38869300484657288f, 0.43174698948860168f, 0.47139298915863037f, 0.50751799345016479f, 0.0f, 0.0f, 0.0f, 3.37722993781223165e-34f, 3.80885988849822355e-19f, 4.90656994200922014e-12f, 2.86603007992880521e-08f, 4.38328015661682002e-06f, 0.00010134100011783f, 0.00081476598279551f, 0.00349242007359862f, 0.01008209958672523f, 0.02243220061063766f, 0.04172819852828979f, 0.06827779859304428f, 0.10154099762439728f, 0.14030000567436218f, 0.18292999267578125f, 0.22785000503063202f, 0.27340999245643616f, 0.31820300221443176f, 0.36118099093437195f, 0.40175101161003113f, 0.43962100148200989f, 0.0f, 0.0f, 0.0f, 9.8090892502737195e-45f, 1.13511000171572082e-24f, 3.09601003078345365e-15f, 2.82900008974351636e-10f, 2.00208006617685896e-07f, 0.00001151220021711f, 0.00016400900494773f, 0.00102415005676448f, 0.00382522004656494f, 0.01021770015358925f, 0.02173330076038837f, 0.03936100006103516f, 0.06336659938097f, 0.09330789744853973f, 0.12818600237369537f, 0.16668100655078888f, 0.20739200711250305f, 0.24903899431228638f, 0.29063498973846436f, 0.33134400844573975f, 0.37064099311828613f, 0.0f, 0.0f, 0.0f, 0.0f, 8.14998004479130106e-33f, 6.36954985683458947e-20f, 3.45817992297714483e-13f, 2.37365993527305363e-09f, 5.25424979969102424e-07f, 0.00001739979961712f, 0.00018874299712479f, 0.00102673994842917f, 0.00357491988688707f, 0.00922095961868763f, 0.01929700002074242f, 0.03473329916596413f, 0.05588230118155479f, 0.08250939846038818f, 0.1139099970459938f, 0.14910100400447845f, 0.18701300024986267f, 0.22664099931716919f, 0.26713100075721741f, 0.3078019917011261f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 7.3832999238063224e-28f, 4.4141699295504271e-18f, 1.48473995684877957e-12f, 3.29401994569877843e-09f, 4.59630996374471579e-07f, 0.00001273939960811f, 0.00013086199760437f, 0.00071139499777928f, 0.00253174011595547f, 0.00673073995858431f, 0.01454710029065609f, 0.02702569961547852f, 0.04481859877705574f, 0.06811539828777313f, 0.09668000042438507f, 0.12994599342346191f, 0.1671299934387207f, 0.2073339968919754f, 0.24963200092315674f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 3.35172992357784324e-37f, 1.16603995591046571e-24f, 3.39939997419364372e-17f, 1.64230001126197678e-12f, 1.9398800343850553e-09f, 2.402420022917795e-07f, 7.1422400651499629e-06f, 0.00008337580220541f, 0.0005176099948585f, 0.00207298994064331f, 0.00607771007344127f, 0.01419879961758852f, 0.0280108992010355f, 0.04858930036425591f, 0.07628270238637924f, 0.11069700121879578f, 0.15084299445152283f, 0.19536399841308594f
} };
__device__ static const FixedArray<float, 576>  SHEEN_ALBEDO_0 = { {
    0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f
} };
__device__ __forceinline__ SheenProfile sheenProfile(float3  v_1, float3  n_i_1, BSDFMaterial material_3)
{
    SheenProfile _S364 = SheenProfile_x24init_0(false, 0.0f);
    float _S365 = rgb_to_greyscale(material_3.sheen);
    bool _S366 = _S365 > 0.0f;
    SheenProfile profile_0;
    if(_S366)
    {
        float _S367 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S368 = (U32_min((uint(_S367)), (22U)));
        float _S369 = (F32_sqrt((0.05000000074505806f)));
        float _S370 = (F32_sqrt((0.00999999977648258f)));
        bool _S371 = (material_3.velvet) > 0.0f;
        float _S372 = _slang_select(_S371, _S370,_S369);
        float _S373 = (clamp_1((F32_sqrt(((F32_max((material_3.sheen_roughness), (0.0f)))))), _S372, 1.0f) - _S372) / (1.0f - _S372) * 23.0f;
        uint _S374 = (U32_min((uint(_S373)), (22U)));
        uint _S375 = _S368 * 24U + _S374;
        float _S376 = _S367 - float(_S368);
        float _S377 = _S373 - float(_S374);
        if(_S371)
        {
            uint _S378 = _S375 + 24U;
            float _S379 = VELVET_ALBEDO_0[_S375] + (VELVET_ALBEDO_0[_S378] - VELVET_ALBEDO_0[_S375]) * _S376;
            uint _S380 = _S375 + 1U;
            float _S381 = VELVET_ALBEDO_0[_S380] + (VELVET_ALBEDO_0[_S378 + 1U] - VELVET_ALBEDO_0[_S380]) * _S376;
            SheenProfile _S382 = SheenProfile_x24init_0(true, _S379 + (_S381 - _S379) * _S377);
            profile_0 = _S382;
        }
        else
        {
            uint _S383 = _S375 + 24U;
            float _S384 = SHEEN_ALBEDO_0[_S375] + (SHEEN_ALBEDO_0[_S383] - SHEEN_ALBEDO_0[_S375]) * _S376;
            uint _S385 = _S375 + 1U;
            float _S386 = SHEEN_ALBEDO_0[_S385] + (SHEEN_ALBEDO_0[_S383 + 1U] - SHEEN_ALBEDO_0[_S385]) * _S376;
            SheenProfile _S387 = SheenProfile_x24init_0(true, (F32_exp((_S384 + (_S386 - _S384) * _S377))));
            profile_0 = _S387;
        }
    }
    else
    {
        profile_0 = _S364;
    }
    return profile_0;
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
    float3  toon;
};

static __device__ Weights Weights_x24init_0(float v_dot_h_0, float3  refracted_1, float3  F_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float p_sheen_velvet_0, float p_toon_0, float3  sheen_0, float3  toon_0)
{
    Weights _S388;
    (&_S388)->v_dot_h = v_dot_h_0;
    (&_S388)->refracted = refracted_1;
    (&_S388)->F = F_0;
    (&_S388)->reflect_weight = reflect_weight_0;
    (&_S388)->diffuse_weight = diffuse_weight_0;
    (&_S388)->refract_weight = refract_weight_0;
    (&_S388)->p_diffuse = p_diffuse_0;
    (&_S388)->p_reflect = p_reflect_0;
    (&_S388)->p_refract = p_refract_0;
    (&_S388)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S388)->p_toon = p_toon_0;
    (&_S388)->sheen = sheen_0;
    (&_S388)->toon = toon_0;
    return _S388;
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
    float3  _S389 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S390 = ((((_S389)) * make_float3(rnorm3df(((_S389)).x, ((_S389)).y, ((_S389)).z))));
    float _S391 = _S390.x;
    float _S392 = _S390.y;
    float _S393 = _S391 * _S391 + _S392 * _S392;
    float3  _S394 = make_float3 (1.0f, 0.0f, 0.0f);
    float3  _S395 = make_float3 (- _S392, _S391, 0.0f);
    float _S396 = (rsqrtf((_S393)));
    float3  _S397 = _S395 * make_float3 (_S396);
    bool _S398 = _S393 > 0.0f;
    float3  _S399 = _slang_select(_S398, _S397,_S394);
    float3  _S400 = cross_0(_S390, _S399);
    float _S401 = (F32_sqrt((U1_0)));
    float _S402 = 6.28318548202514648f * U2_0;
    float _S403 = _S401 * (F32_cos((_S402)));
    float t2_0 = _S401 * (F32_sin((_S402)));
    float _S404 = 0.5f * (1.0f + _S390.z);
    float t2_1 = (1.0f - _S404) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S403 * _S403)))))) + _S404 * t2_0;
    float3  _S405 = make_float3 (_S403) * _S399 + make_float3 (t2_1) * _S400;
    float _S406 = unshared_0(_S403);
    float _S407 = unshared_0(_S403);
    float3  _S408 = _S405 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S406 * _S407 - t2_1 * t2_1))))))) * _S390;
    float3  _S409 = make_float3 (alpha_0 * _S408.x, alpha_0 * _S408.y, (F32_max((0.0f), (_S408.z))));
    float3  _S410 = ((((_S409)) * make_float3(rnorm3df(((_S409)).x, ((_S409)).y, ((_S409)).z))));
    return _S410;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S411 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S411)
    {
        float3  _S412 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S412;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S413 = cross_0(n_3, a_4);
    float3  _S414 = ((((_S413)) * make_float3(rnorm3df(((_S413)).x, ((_S413)).y, ((_S413)).z))));
    float3  _S415 = cross_0(n_3, _S414);
    return make_float3 (dot_0(v_2, _S414), dot_0(v_2, n_3), dot_0(v_2, _S415));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S416 = pcg(*random_state_2);
    Random _S417 = pcg(_S416.state);
    *random_state_2 = _S417.state;
    float _S418 = frame_0.alphas.x;
    bool _S419 = _S418 > 0.0f;
    if(_S419)
    {
        float3  _S420 = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        float _S421 = frame_0.alphas.y;
        float3  _S422 = make_float3 (_S418 * _S420.x, _S421 * _S420.y, _S420.z);
        float3  _S423 = ((((_S422)) * make_float3(rnorm3df(((_S422)).x, ((_S422)).y, ((_S422)).z))));
        float3  _S424 = sampleGGXVNDF(_S423, 1.0f, _S416.value, _S417.value);
        float3  _S425 = make_float3 (_S418 * _S424.x, _S421 * _S424.y, _S424.z);
        float3  _S426 = ((((_S425)) * make_float3(rnorm3df(((_S425)).x, ((_S425)).y, ((_S425)).z))));
        return make_float3 (_S426.x) * frame_0.tangent + make_float3 (_S426.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S426.z) * n_i_2;
    }
    float3  _S427 = worldToTangent(v_3, n_i_2);
    float3  _S428 = sampleGGXVNDF(float3 {_S427.x, _S427.z, _S427.y}, alpha_1, _S416.value, _S417.value);
    float3  _S429 = float3 {_S428.x, _S428.z, _S428.y};
    float3  _S430 = tangentToWorld(_S429, n_i_2);
    return _S430;
}

__device__ __forceinline__ float3  sampledHalf(float3  v_4, float3  n_i_3, float alpha_2, AnisotropicFrame frame_1, uint random_state_3)
{
    uint state_2 = random_state_3;
    float3  _S431 = sampleHalfVector(v_4, n_i_3, alpha_2, frame_1, &state_2);
    return _S431;
}

__device__ __forceinline__ float3  refractedHalf(float3  in_dir_0, float3  out_dir_0, float3  n_4, float eta_i_0, float eta_o_0)
{
    float3  _S432 = negate_0(in_dir_0);
    float3  _S433 = negate_0(make_float3 (eta_i_0) * _S432 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S434 = ((((_S433)) * make_float3(rnorm3df(((_S433)).x, ((_S433)).y, ((_S433)).z))));
    float _S435 = sign_0(dot_0(n_4, _S432));
    float _S436 = sign_0(dot_0(_S433, n_4 * make_float3 (_S435)));
    return _S434 * make_float3 (_S436);
}

__device__ __forceinline__ float3  reflectedHalf(float3  in_dir_1, float3  out_dir_1)
{
    float3  _S437 = negate_0(in_dir_1);
    float3  _S438 = _S437 + out_dir_1;
    float3  _S439 = ((((_S438)) * make_float3(rnorm3df(((_S438)).x, ((_S438)).y, ((_S438)).z))));
    return _S439;
}

static __device__ float3  refract_0(float3  i_5, float3  n_5, float eta_0)
{
    float _S440 = dot_0(n_5, i_5);
    float _S441 = 1.0f - eta_0 * eta_0 * (1.0f - _S440 * _S440);
    if(_S441 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S440 + (F32_sqrt((_S441)))) * n_5;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S442 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S443 = eta_i_1 / eta_o_1 * _S442;
    bool _S444 = _S443 < 1.0f;
    float kr_0;
    if(_S444)
    {
        float _S445 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S443 * _S443))))));
        bool _S446 = eta_i_1 == eta_o_1;
        float _S447 = _slang_select(_S446, cos_theta_0,_S445);
        float _S448 = eta_o_1 * cos_theta_0;
        float _S449 = eta_i_1 * _S447;
        float _S450 = (_S448 - _S449) / (_S448 + _S449);
        float _S451 = eta_i_1 * cos_theta_0;
        float _S452 = eta_o_1 * _S447;
        float _S453 = (_S451 - _S452) / (_S451 + _S452);
        float _S454 = (_S450 * _S450 + _S453 * _S453) / 2.0f;
        kr_0 = _S454;
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

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

__device__ __forceinline__ Weights lobeWeights(float3  in_dir_2, float3  v_5, float3  n_i_4, float3  ggx_n_0, AnisotropicFrame frame_2, SheenProfile sheen_profile_0, BSDFMaterial material_4, float eta_i_2, float eta_o_2)
{
    float _S455 = dot_0(ggx_n_0, v_5);
    float _S456 = eta_i_2 / eta_o_2;
    float3  _S457 = refract_0(in_dir_2, ggx_n_0, _S456);
    float3  _S458 = ((((_S457)) * make_float3(rnorm3df(((_S457)).x, ((_S457)).y, ((_S457)).z))));
    float _S459 = (F32_min(((F32_sqrt((material_4.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S460 = _S459 * _S459;
    float _S461 = (1.0f + _S459) / (1.0f - _S459);
    float _S462 = (F32_abs((_S455)));
    bool _S463 = eta_i_2 > eta_o_2;
    float _S464 = _slang_select(_S463, _S461,1.0f);
    float _S465 = _slang_select(_S463, 1.0f,_S461);
    float _S466 = fresnel(_S462, _S464, _S465);
    bool _S467 = (eta_i_2 * eta_i_2 * (1.0f - _S455 * _S455)) >= (eta_o_2 * eta_o_2);
    float3  _S468 = material_4.specular_tint * make_float3 (_S460);
    float3  _S469 = _S468 + (make_float3 (1.0f) - _S468) * make_float3 (_S466 - _S460) / make_float3 (1.0f - _S460);
    float3  _S470 = make_float3 (1.0f);
    float3  _S471 = _slang_select(_S467, _S470,_S469);
    float3  _S472 = make_float3 (0.0f);
    float sheen_component_0;
    float3  sheen_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S473 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S474 = make_float3 (1.0f) - material_4.sheen * make_float3 (_S473);
        float _S475 = rgb_to_greyscale(material_4.sheen);
        float _S476 = _S475 * _S473;
        float3  _S477 = material_4.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S476;
        sheen_1 = _S477;
        scale_1 = _S474;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S472;
        scale_1 = _S470;
    }
    float _S478 = (F32_abs((material_4.toon.x)));
    bool _S479 = _S478 > 0.0f;
    float toon_component_0;
    float3  toon_1;
    if(_S479)
    {
        float _S480 = (F32_min((_S478), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S480);
        float _S481 = rgb_to_greyscale(material_4.albedo);
        float _S482 = _S480 * _S481;
        float3  _S483 = make_float3 (_S480) * material_4.albedo;
        toon_component_0 = _S482;
        toon_1 = _S483;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S472;
    }
    bool _S484 = (material_4.metallic) > 0.0f;
    float3  rebounce_0;
    if(_S484)
    {
        float _S485 = frame_2.alphas.x;
        float _S486 = (F32_sqrt(((F32_min((_S485), (frame_2.alphas.y))))));
        bool _S487 = _S485 > 0.0f;
        float _S488 = _slang_select(_S487, _S486,material_4.roughness);
        float _S489 = _S488 * _S488;
        float _S490 = (F32_pow((_S489), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S489) / (1.0f + 1.28094995021820068f * _S489);
        bool _S491 = _S489 > 0.0f;
        float _S492 = _slang_select(_S491, _S490,0.0f);
        float _S493 = clamp_1(dot_0(n_i_4, v_5), 0.0f, 1.0f);
        float _S494 = _S489 * _S488;
        float _S495 = (F32_min((1.00064504146575928f - _S488 * (0.00375499995425344f + _S493 * (-0.04133399948477745f + _S493 * (-0.90938502550125122f + _S493 * 0.35275399684906006f))) - _S489 * (0.27602800726890564f + _S493 * (1.27023398876190186f + _S493 * 0.04740000143647194f)) - _S494 * (0.31452900171279907f - _S493 * 0.34830701351165771f) + _S494 * _S488 * 0.27229699492454529f), (1.0f)));
        float3  _S496 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_4.albedo * make_float3 (_S492)), make_float3 (1.0f / (F32_max((_S495), (0.0000152587890625f)))));
        rebounce_0 = _S496;
    }
    else
    {
        rebounce_0 = _S470;
    }
    float3  _S497 = mix_0(_S471, material_4.albedo * rebounce_0, material_4.metallic);
    float3  F_1 = _S497 * scale_1;
    float _S498 = rgb_to_greyscale(F_1);
    float _S499 = 1.0f - material_4.metallic;
    float3  _S500 = make_float3 (1.0f) - _S471;
    float3  _S501 = make_float3 ((1.0f - material_4.transmission) * _S499) * _S500 * scale_1;
    float3  _S502 = make_float3 (material_4.transmission * _S499) * _S500 * scale_1;
    float _S503 = (F32_max((_S498), (0.0f)));
    float _S504 = rgb_to_greyscale(_S501);
    float _S505 = (F32_max((_S504), (0.0f)));
    float _S506 = rgb_to_greyscale(_S502);
    float _S507 = sign_0(length_0(_S458));
    float _S508 = (F32_max((_S506 * _S507), (0.0f)));
    float _S509 = _S503 + _S505 + _S508 + toon_component_0;
    float _S510 = (F32_min((sheen_component_0), (1.0f)));
    bool _S511 = sheen_component_0 > 0.0f;
    bool _S512;
    if(_S511)
    {
        _S512 = !(_S509 > 0.0f);
    }
    else
    {
        _S512 = false;
    }
    float _S513 = _slang_select(_S512, 1.0f,_S510);
    float _S514 = (1.0f - _S513) / (F32_max((_S509), (0.0000152587890625f)));
    float _S515 = _S505 * _S514;
    float _S516 = _S503 * _S514;
    float _S517 = _S508 * _S514;
    return Weights_x24init_0(_S455, _S458, F_1, 1.0f, _S501, _S502, _S515, _S516, _S517, _S513, toon_component_0 * _S514, sheen_1, toon_1);
}

__device__ float translucentShare(BSDFMaterial material_5)
{
    float _S518 = rgb_to_greyscale(material_5.translucent);
    float _S519 = rgb_to_greyscale(material_5.albedo);
    float _S520 = _S518 / (_S519 + _S518);
    bool _S521 = _S518 > 0.0f;
    float _S522 = _slang_select(_S521, _S520,0.0f);
    return _S522;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float n_i_dot_v_0, BSDFMaterial material_6, Weights w_1)
{
    float _S523 = translucentShare(material_6);
    float _S524 = w_1.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S525 = w_1.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S526 = 1.0f - _S523;
    bool _S527 = n_i_dot_l_0 < 0.0f;
    float _S528 = _slang_select(_S527, _S523,_S526);
    float _S529 = _S525 * _S528;
    bool _S530 = _S523 > 0.0f;
    float _S531 = _slang_select(_S530, _S529,_S524);
    bool _S532 = n_i_dot_v_0 > 0.0f;
    float _S533 = _slang_select(_S532, _S531,0.0f);
    return _S533;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_5, BSDFMaterial material_7, Weights w_2)
{
    float _S534 = translucentShare(material_7);
    bool _S535 = (dot_0(n_i_5, l_0)) < 0.0f;
    float3  _S536 = _slang_select(_S535, material_7.translucent,material_7.albedo);
    float _S537 = 1.0f - _S534;
    float _S538 = _slang_select(_S535, _S534,_S537);
    float3  _S539 = _S536 / make_float3 (_S538);
    bool _S540 = _S534 > 0.0f;
    float3  _S541 = _slang_select(_S540, _S539,material_7.albedo);
    return w_2.diffuse_weight * _S541 / make_float3 (w_2.p_diffuse);
}

__device__ float smithG1(float alpha_3, float n_dot_x_0)
{
    float _S542 = alpha_3 * alpha_3;
    float _S543 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S542 + (1.0f - _S542) * n_dot_x_0 * n_dot_x_0))));
    bool _S544 = alpha_3 > 0.0f;
    float _S545 = _slang_select(_S544, _S543,1.0f);
    return _S545;
}

__device__ float trowbridgeReitz(float alpha_4, float n_dot_h_0)
{
    float _S546 = alpha_4 * alpha_4;
    float _S547 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S546 * n_dot_h_0 * n_dot_h_0;
    return _S546 / (F32_max((3.14159274101257324f * _S547 * _S547), (1.17549435082228751e-38f)));
}

__device__ float anisotropicG1(float3  w_3, float2  alphas_1)
{
    float _S548 = (F32_max((w_3.z), (0.0f)));
    return 2.0f * _S548 / (_S548 + length_0(make_float3 (alphas_1.x * w_3.x, alphas_1.y * w_3.y, _S548)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S549 = alphas_2.x;
    float _S550 = h_0.x / _S549;
    float _S551 = alphas_2.y;
    float _S552 = h_0.y / _S551;
    float _S553 = h_0.z;
    float _S554 = _S550 * _S550 + _S552 * _S552 + _S553 * _S553;
    return 1.0f / (F32_max((3.14159274101257324f * _S549 * _S551 * _S554 * _S554), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float3  v_6, float3  h_1, float3  n_i_6, float n_i_dot_v_1, float alpha_5, AnisotropicFrame frame_3, float v_dot_h_1)
{
    float _S555 = dot_0(n_i_6, h_1);
    float _S556 = smithG1(alpha_5, n_i_dot_v_1);
    float _S557 = _S556 * v_dot_h_1;
    float _S558 = trowbridgeReitz(alpha_5, _S555);
    float _S559 = _S557 * _S558 / n_i_dot_v_1;
    bool _S560 = alpha_5 > 0.0f;
    bool _S561;
    if(_S560)
    {
        _S561 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S561 = false;
    }
    if(_S561)
    {
        _S561 = _S555 > 0.0f;
    }
    else
    {
        _S561 = false;
    }
    if(_S561)
    {
        _S561 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S561 = false;
    }
    float _S562 = _slang_select(_S561, _S559,0.0f);
    bool _S563 = (frame_3.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S563)
    {
        float3  _S564 = anisotropicLocal(v_6, frame_3.tangent, n_i_6);
        float _S565 = anisotropicG1(_S564, frame_3.alphas);
        float3  _S566 = anisotropicLocal(h_1, frame_3.tangent, n_i_6);
        float _S567 = anisotropicD(_S566, frame_3.alphas);
        float _S568 = _S565 * _S567;
        float _S569 = _S568 * v_dot_h_1 / n_i_dot_v_1;
        bool _S570 = v_dot_h_1 > 0.0f;
        if(_S570)
        {
            _S561 = _S555 > 0.0f;
        }
        else
        {
            _S561 = false;
        }
        if(_S561)
        {
            _S561 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S561 = false;
        }
        float _S571 = _slang_select(_S561, _S569,0.0f);
        pdf_h_0 = _S571;
    }
    else
    {
        pdf_h_0 = _S562;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float l_dot_h_0, float pdf_h_1, Weights w_4, float eta_i_3, float eta_o_3)
{
    float _S572 = eta_i_3 * w_4.v_dot_h + eta_o_3 * l_dot_h_0;
    float _S573 = w_4.p_refract * pdf_h_1 * eta_o_3 * eta_o_3 * (F32_abs((l_dot_h_0))) / (_S572 * _S572);
    bool _S574 = eta_i_3 != eta_o_3;
    bool _S575;
    if(_S574)
    {
        _S575 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S575 = false;
    }
    float _S576 = _slang_select(_S575, _S573,0.0f);
    return _S576;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_7, float alpha_6, AnisotropicFrame frame_4, BSDFMaterial material_8, Weights w_5)
{
    float _S577 = - dot_0(n_i_7, l_1);
    float _S578 = smithG1(alpha_6, (F32_max((_S577), (0.0f))));
    bool _S579 = (frame_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S579)
    {
        float3  _S580 = negate_0(n_i_7);
        float3  _S581 = anisotropicLocal(l_1, frame_4.tangent, _S580);
        float _S582 = anisotropicG1(_S581, frame_4.alphas);
        G1_l_0 = _S582;
    }
    else
    {
        G1_l_0 = _S578;
    }
    bool _S583 = (material_8.ior) == 1.0f;
    float _S584 = _slang_select(_S583, 1.0f,G1_l_0);
    return w_5.refract_weight * make_float3 (_S584) * material_8.albedo / make_float3 (w_5.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_1, float n_i_dot_v_2, Weights w_6)
{
    float _S585 = w_6.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S586 = n_i_dot_l_1 > 0.0f;
    bool _S587;
    if(_S586)
    {
        _S587 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S587 = false;
    }
    float _S588 = _slang_select(_S587, _S585,0.0f);
    return _S588;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  v_7, float3  n_i_8, BSDFMaterial material_9, Weights w_7)
{
    float3  _S589 = l_2 + v_7;
    float3  _S590 = ((((_S589)) * make_float3(rnorm3df(((_S589)).x, ((_S589)).y, ((_S589)).z))));
    float _S591 = dot_0(n_i_8, _S590);
    float _S592 = (F32_max((dot_0(n_i_8, l_2)), (0.0f)));
    float _S593 = (F32_max((dot_0(n_i_8, v_7)), (0.0f)));
    float _S594 = 1.0f / (F32_max((material_9.sheen_roughness), (0.05000000074505806f)));
    float _S595 = 1.0f - _S591 * _S591;
    float _S596 = (2.0f + _S594) * (F32_pow(((F32_max((_S595), (0.0f)))), (0.5f * _S594))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S592 + _S593 - _S592 * _S593)), (0.0000152587890625f)));
    bool _S597 = (material_9.velvet) > 0.0f;
    float f_1;
    if(_S597)
    {
        float _S598 = (F32_max((material_9.sheen_roughness), (0.00999999977648258f)));
        float _S599 = _S598 * _S598;
        float _S600 = (F32_max((_S595), (0.0000152587890625f)));
        float _S601 = (F32_exp((- _S591 * _S591 / (_S600 * _S599)))) / (3.14159274101257324f * _S599 * _S600 * _S600) * (F32_min((1.0f), (2.0f * _S591 * (F32_min((_S592), (_S593))) / (F32_max(((F32_abs((dot_0(_S590, v_7))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S592 * _S593), (0.0000152587890625f)));
        f_1 = _S601;
    }
    else
    {
        f_1 = _S596;
    }
    return w_7.sheen * make_float3 (f_1 * _S592 * 2.0f * 3.14159274101257324f / w_7.p_sheen_velvet);
}

struct ToonProfile
{
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
    float _S602 = (F32_max((1.0f - (t_13 - a_5) / (F32_max((s_0), (0.0000152587890625f)))), (0.0f)));
    bool _S603 = t_13 < a_5;
    float _S604 = _slang_select(_S603, 1.0f,_S602);
    return _S604;
}

__device__ __forceinline__ float toonIntegral(float t_14, float a_6, float s_1, bool glossy_0)
{
    float _S605 = (F32_min((t_14), (a_6)));
    float _S606 = (F32_sin((_S605)));
    float _S607 = _S606 * _S606 / 2.0f;
    float _S608 = 1.0f - (F32_cos((_S605)));
    float _S609 = _slang_select(glossy_0, _S608,_S607);
    bool _S610 = t_14 > a_6;
    bool _S611;
    if(_S610)
    {
        _S611 = s_1 > 0.0f;
    }
    else
    {
        _S611 = false;
    }
    float integral_0;
    if(_S611)
    {
        if(glossy_0)
        {
            float _S612 = (F32_cos((a_6)));
            float _S613 = (F32_cos((t_14)));
            integral_0 = (1.0f + a_6 / s_1) * (_S612 - _S613) - ((F32_sin((t_14))) - t_14 * _S613 - ((F32_sin((a_6))) - a_6 * _S612)) / s_1;
        }
        else
        {
            float _S614 = 2.0f * a_6;
            float _S615 = (F32_cos((_S614)));
            float _S616 = 2.0f * t_14;
            float _S617 = (F32_cos((_S616)));
            integral_0 = (1.0f + a_6 / s_1) * (_S615 - _S617) / 4.0f - ((F32_sin((_S616))) / 8.0f - t_14 * _S617 / 4.0f - ((F32_sin((_S614))) / 8.0f - a_6 * _S615 / 4.0f)) / s_1;
        }
        float integral_1 = _S609 + integral_0;
        integral_0 = integral_1;
    }
    else
    {
        integral_0 = _S609;
    }
    return integral_0;
}

static __device__ ToonProfile ToonProfile_x24init_0(bool glossy_1, float a_7, float s_2, float b_1, float norm_0, float view_0, float3  axis_0)
{
    ToonProfile _S618;
    (&_S618)->glossy = glossy_1;
    (&_S618)->a = a_7;
    (&_S618)->s = s_2;
    (&_S618)->b = b_1;
    (&_S618)->norm = norm_0;
    (&_S618)->view = view_0;
    (&_S618)->axis = axis_0;
    return _S618;
}

__device__ __forceinline__ ToonProfile toonProfile(float3  v_8, float3  n_i_9, BSDFMaterial material_10)
{
    float _S619 = material_10.toon.x;
    bool _S620 = _S619 < 0.0f;
    float _S621 = clamp_1(material_10.toon.y / _S619, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S622 = clamp_1(material_10.toon.z / _S619, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S623 = (F32_min((_S621 + _S622), (1.57079637050628662f)));
    float _S624 = dot_0(n_i_9, v_8);
    float _S625 = toonP((F32_acos(((F32_min((_S624), (1.0f)))))), _S621, _S622);
    float3  _S626 = make_float3 (2.0f * _S624) * n_i_9 - v_8;
    float3  _S627 = ((((_S626)) * make_float3(rnorm3df(((_S626)).x, ((_S626)).y, ((_S626)).z))));
    float3  _S628 = _slang_select(_S620, _S627,n_i_9);
    float _S629 = toonIntegral(_S623, _S621, _S622, _S620);
    return ToonProfile_x24init_0(_S620, _S621, _S622, _S623, 6.28318548202514648f * _S629, _S625, _S628);
}

__device__ __forceinline__ float toonPDF(float3  l_3, float3  n_i_10, ToonProfile profile_1, Weights w_8)
{
    float _S630 = dot_0(n_i_10, l_3);
    float _S631 = dot_0(l_3, profile_1.axis);
    float _S632 = _slang_select(profile_1.glossy, _S631,_S630);
    float _S633 = (F32_acos((clamp_1(_S632, -1.0f, 1.0f))));
    float _S634 = toonP(_S633, profile_1.a, profile_1.s);
    float _S635 = w_8.p_toon * _S634;
    float _S636 = _slang_select(profile_1.glossy, 1.0f,_S630);
    float _S637 = _S635 * _S636 / profile_1.norm;
    bool _S638;
    if(profile_1.glossy)
    {
        _S638 = true;
    }
    else
    {
        _S638 = _S630 > 0.0f;
    }
    float _S639 = _slang_select(_S638, _S637,0.0f);
    return _S639;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_4, float3  n_i_11, ToonProfile profile_2, Weights w_9)
{
    float _S640 = (F32_max((dot_0(n_i_11, l_4)), (0.0f)));
    float _S641 = _slang_select(profile_2.glossy, _S640,profile_2.view);
    return w_9.toon * make_float3 (_S641) / make_float3 (w_9.p_toon);
}

__device__ __forceinline__ float reflectPDF(float pdf_h_2, Weights w_10)
{
    float _S642 = w_10.p_reflect * pdf_h_2 / (4.0f * w_10.v_dot_h);
    bool _S643 = pdf_h_2 > 0.0f;
    float _S644 = _slang_select(_S643, _S642,0.0f);
    return _S644;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_5, float3  n_i_12, float alpha_7, AnisotropicFrame frame_5, Weights w_11)
{
    float _S645 = dot_0(n_i_12, l_5);
    float _S646 = smithG1(alpha_7, (F32_max((_S645), (0.0f))));
    bool _S647 = (frame_5.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S647)
    {
        float3  _S648 = anisotropicLocal(l_5, frame_5.tangent, n_i_12);
        float _S649 = anisotropicG1(_S648, frame_5.alphas);
        G1_l_1 = _S649;
    }
    else
    {
        G1_l_1 = _S646;
    }
    return make_float3 (w_11.reflect_weight * G1_l_1) * w_11.F / make_float3 (w_11.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_3, float3  out_dir_2, float3  n_6, BSDFMaterial material_11, float eta_i_4, float eta_o_4, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S650 = negate_0(in_dir_3);
    float _S651 = dot_0(n_6, _S650);
    float _S652 = sign_0(_S651);
    float3  _S653 = n_6 * make_float3 (_S652);
    float _S654 = dot_0(_S653, out_dir_2);
    float _S655 = material_11.roughness;
    float _S656 = _S655 * _S655;
    AnisotropicFrame _S657 = anisotropicFrame(material_11, _S653);
    SheenProfile _S658 = sheenProfile(_S650, _S653, material_11);
    float _S659 = rgb_to_greyscale(material_11.translucent);
    bool _S660 = _S659 > 0.0f;
    bool _S661 = (dot_0(n_6, out_dir_2) * _S651) < 0.0f;
    bool _S662 = (F32_abs((material_11.toon.x))) > 0.0f;
    uint _S663;
    if(_S662)
    {
        _S663 = 5U;
    }
    else
    {
        _S663 = 4U;
    }
    uint i_7 = 0U;
    for(;;)
    {
        if(i_7 < 5U)
        {
        }
        else
        {
            break;
        }
        float3  _S664 = make_float3 (0.0f);
        (*throughputs_0)[i_7] = _S664;
        (*pdfs_0)[i_7] = 0.0f;
        uint i_8 = i_7 + 1U;
        i_7 = i_8;
    }
    float3  _S665 = make_float3 (0.0f);
    Weights _S666 = Weights_x24init_0(0.0f, _S665, _S665, 0.0f, _S665, _S665, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S665, _S665);
    uint half_of_0 = 4294967295U;
    Weights w_12 = _S666;
    float3  ggx_n_2 = _S665;
    i_7 = 0U;
    for(;;)
    {
        if(i_7 < _S663)
        {
        }
        else
        {
            break;
        }
        uint _S667;
        if(i_7 == 3U)
        {
            _S667 = 4U;
        }
        else
        {
            if(i_7 == 4U)
            {
                _S667 = 6U;
            }
            else
            {
                _S667 = i_7;
            }
        }
        bool _S668 = _S667 == 0U;
        bool _S669;
        if(_S668)
        {
            _S669 = _S660;
        }
        else
        {
            _S669 = false;
        }
        bool _S670;
        if(_S669)
        {
            _S670 = _S661;
        }
        else
        {
            _S670 = _S667 == 1U;
        }
        bool _S671 = _S670 != refracted_2;
        if(_S671)
        {
            ggx_n_1 = ggx_n_2;
            uint i_9 = i_7 + 1U;
            ggx_n_2 = ggx_n_1;
            i_7 = i_9;
            continue;
        }
        uint _S672;
        if(_S667 == 6U)
        {
            _S672 = 0U;
        }
        else
        {
            if(_S667 == 4U)
            {
                _S672 = 2U;
            }
            else
            {
                _S672 = _S667;
            }
        }
        bool _S673 = _S672 != half_of_0;
        uint half_of_1;
        Weights w_13;
        if(_S673)
        {
            bool _S674 = _S672 == 0U;
            if(_S674)
            {
                float3  _S675 = sampledHalf(_S650, _S653, _S656, _S657, random_state_4);
                ggx_n_1 = _S675;
            }
            else
            {
                bool _S676 = _S672 == 1U;
                if(_S676)
                {
                    float3  _S677 = refractedHalf(in_dir_3, out_dir_2, n_6, eta_i_4, eta_o_4);
                    ggx_n_1 = _S677;
                }
                else
                {
                    float3  _S678 = reflectedHalf(in_dir_3, out_dir_2);
                    ggx_n_1 = _S678;
                }
            }
            Weights _S679 = lobeWeights(in_dir_3, _S650, _S653, ggx_n_1, _S657, _S658, material_11, eta_i_4, eta_o_4);
            w_13 = _S679;
            half_of_1 = _S672;
        }
        else
        {
            w_13 = w_12;
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S667)
        {
        case 0U:
            {
                float _S680 = diffusePDF(_S654, (F32_abs((_S651))), material_11, w_13);
                (*pdfs_0)[int(0)] = _S680;
                float3  _S681 = diffuseBSDF(out_dir_2, _S653, material_11, w_13);
                (*throughputs_0)[int(0)] = _S681;
                break;
            }
        case 1U:
            {
                float _S682 = dot_0(out_dir_2, ggx_n_1);
                float _S683 = vndfPDF(_S650, ggx_n_1, _S653, (F32_abs((_S651))), _S656, _S657, w_13.v_dot_h);
                float _S684 = refractPDF(_S682, _S683, w_13, eta_i_4, eta_o_4);
                (*pdfs_0)[int(1)] = _S684;
                float3  _S685 = refractBSDF(out_dir_2, _S653, _S656, _S657, material_11, w_13);
                (*throughputs_0)[int(1)] = _S685;
                break;
            }
        case 4U:
            {
                float _S686 = sheenVelvetPDF(_S654, (F32_abs((_S651))), w_13);
                (*pdfs_0)[int(3)] = _S686;
                float3  _S687 = sheenVelvetBSDF(out_dir_2, _S650, _S653, material_11, w_13);
                (*throughputs_0)[int(3)] = _S687;
                break;
            }
        case 6U:
            {
                ToonProfile _S688 = toonProfile(_S650, _S653, material_11);
                float _S689 = toonPDF(out_dir_2, _S653, _S688, w_13);
                (*pdfs_0)[int(4)] = _S689;
                float3  _S690 = toonBSDF(out_dir_2, _S653, _S688, w_13);
                (*throughputs_0)[int(4)] = _S690;
                break;
            }
        default:
            {
                float _S691 = vndfPDF(_S650, ggx_n_1, _S653, (F32_abs((_S651))), _S656, _S657, w_13.v_dot_h);
                float _S692 = reflectPDF(_S691, w_13);
                (*pdfs_0)[int(2)] = _S692;
                float3  _S693 = reflectBSDF(out_dir_2, _S653, _S656, _S657, w_13);
                (*throughputs_0)[int(2)] = _S693;
                break;
            }
        }
        half_of_0 = half_of_1;
        w_12 = w_13;
        uint i_9 = i_7 + 1U;
        ggx_n_2 = ggx_n_1;
        i_7 = i_9;
    }
    i_7 = 0U;
    ggx_n_1 = _S665;
    for(;;)
    {
        if(i_7 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S694 = ((*pdfs_0)[i_7]) > 0.0f;
        if(_S694)
        {
            float3  f_2 = ggx_n_1 + (*throughputs_0)[i_7] * make_float3 ((*pdfs_0)[i_7]);
            ggx_n_1 = f_2;
        }
        uint i_10 = i_7 + 1U;
        i_7 = i_10;
    }
    return ggx_n_1;
}

static __device__ __forceinline__ float3  skyLobes_0(float3  in_dir_4, float3  dir_5, FKSurface * surface_1, BSDFMaterial * material_12, float2  eta_1, bool is_inside_2, float pdf_1, uint random_state_5, FixedArray<float3 , 5>  * terms_0, FixedArray<float, 5>  * pdfs_1)
{
    bool _S695 = wrongSide_0(is_inside_2, false, dir_5, surface_1->geometry_n);
    float3  _S696 = BSDF(in_dir_4, dir_5, surface_1->smooth_n, *material_12, eta_1.x, eta_1.y, _S695, random_state_5, terms_0, pdfs_1);
    float3  _S697 = make_float3 (0.0f);
    uint i_11 = 0U;
    float3  f_3 = _S697;
    for(;;)
    {
        if(i_11 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S698 = ((*pdfs_1)[i_11]) > 0.0f;
        if(_S698)
        {
            float3  _S699 = (*terms_0)[i_11] * make_float3 ((*pdfs_1)[i_11]) / make_float3 ((*pdfs_1)[i_11] + pdf_1);
            (*terms_0)[i_11] = _S699;
            float3  f_4 = f_3 + (*terms_0)[i_11];
            f_3 = f_4;
        }
        uint i_12 = i_11 + 1U;
        i_11 = i_12;
    }
    return f_3;
}

__device__ float3  skyBSDF(float3  in_dir_5, float3  dir_6, FKSurface surface_2, BSDFMaterial material_13, float2  eta_2, bool is_inside_3, float pdf_2, uint random_state_6)
{
    FKSurface _S700 = surface_2;
    BSDFMaterial _S701 = material_13;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S702 = skyLobes_0(in_dir_5, dir_6, &_S700, &_S701, eta_2, is_inside_3, pdf_2, random_state_6, &terms_1, &pdfs_2);
    return _S702;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_7, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S703;
    (&_S703)->dir = dir_7;
    (&_S703)->radiance = radiance_0;
    (&_S703)->color = color_0;
    (&_S703)->random_state = random_state_7;
    return _S703;
}

static __device__ __noinline__ float3  skyColor_0(float3  in_dir_6, float3  dir_8, FKSurface * surface_3, float wavelength_3, float2  eta_3, bool is_inside_4, float pdf_3, uint random_state_8, uint depth_1)
{
    BSDFMaterial _S704 = pathMaterial(surface_3->material, wavelength_3);
    BSDFMaterial _S705 = _S704;
    FixedArray<float3 , 5>  terms_2;
    FixedArray<float, 5>  pdfs_3;
    float3  _S706 = skyLobes_0(in_dir_6, dir_8, surface_3, &_S705, eta_3, is_inside_4, pdf_3, random_state_8, &terms_2, &pdfs_3);
    float3  _S707 = make_float3 (0.0f);
    bool shaded_0 = false;
    float3  world_0 = _S707;
    uint i_13 = 0U;
    float3  color_1 = _S707;
    for(;;)
    {
        if(i_13 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S708 = (pdfs_3[i_13]) > 0.0f;
        if(_S708)
        {
            bool _S709 = (fcptWorldReadsPath());
            bool _S710;
            if(_S709)
            {
                _S710 = true;
            }
            else
            {
                _S710 = !shaded_0;
            }
            bool shaded_1;
            float3  world_1;
            if(_S710)
            {
                uint _S711;
                if(i_13 == 3U)
                {
                    _S711 = 4U;
                }
                else
                {
                    if(i_13 == 4U)
                    {
                        _S711 = 6U;
                    }
                    else
                    {
                        _S711 = i_13;
                    }
                }
                float3  _S712 = (fcptEnvMapSample((dir_8), (depth_1), (_S711)));
                world_1 = _S712;
                shaded_1 = true;
            }
            else
            {
                world_1 = world_0;
                shaded_1 = shaded_0;
            }
            float3  color_2 = color_1 + terms_2[i_13] * world_1;
            shaded_0 = shaded_1;
            world_0 = world_1;
            color_1 = color_2;
        }
        uint i_14 = i_13 + 1U;
        i_13 = i_14;
    }
    return color_1;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_4, float wavelength_4, float2  eta_4, bool is_inside_5, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S713 = (fcptEnvironmentCdfSize());
    uint2  _S714 = make_uint2 (1U, 0U);
    uint2  _S715 = _S713 - _S714;
    Random _S716 = pcg(init_random_state_0);
    Random _S717 = pcg(_S716.state);
    Random _S718 = pcg(_S717.state);
    Random _S719 = pcg(_S718.state);
    uint _S720 = _S715.x;
    uint _S721 = searchCDF_0(make_uint2 (_S720, 0U), make_uint2 (0U, 1U), _S715.y, _S716.value);
    uint _S722 = searchCDF_0(make_uint2 (0U, _S721), _S714, _S720, _S717.value);
    float2  _S723 = make_float2 ((float)_S715.x, (float)_S715.y);
    float2  _S724 = (make_float2 (float(_S722), float(_S721)) + make_float2 (_S718.value, _S719.value)) / _S723 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S725 = _S724.y;
    float _S726 = (F32_sin((_S725)));
    float _S727 = _S724.x;
    float3  _S728 = make_float3 (- _S726 * (F32_cos((_S727))), _S726 * (F32_sin((_S727))), (F32_cos((_S725))));
    float _S729 = environmentPdf_0(_S728);
    BSDFMaterial _S730 = pathMaterial(surface_4->material, wavelength_4);
    float3  _S731 = ray_0->unit_direction;
    float3  _S732 = skyBSDF(ray_0->unit_direction, _S728, *surface_4, _S730, eta_4, is_inside_5, _S729, lobe_state_0);
    bool _S733 = !(_S729 > 0.0f);
    bool _S734;
    if(_S733)
    {
        _S734 = true;
    }
    else
    {
        _S734 = all_1(_S732 == make_float3 (0.0f));
    }
    if(_S734)
    {
        float3  _S735 = make_float3 (0.0f);
        return SkySample_x24init_0(_S728, _S735, _S735, _S719.state);
    }
    bool _S736 = (fcptWorldReadsPath());
    float3  seen_0;
    if(_S736)
    {
        float3  _S737 = skyColor_0(_S731, _S728, surface_4, wavelength_4, eta_4, is_inside_5, _S729, lobe_state_0, context_2->depth + 1U);
        seen_0 = _S737;
    }
    else
    {
        seen_0 = _S732;
    }
    float3  _S738 = skyRadiance_0(ray_0->origin, surface_4, is_inside_5, _S728, context_2, _S719.state);
    return SkySample_x24init_0(_S728, _S738, seen_0 * _S738, _S719.state);
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

static __device__ float3  hairLight_0(FKSurface * surface_5, float3  in_dir_7, TreeSample * light_1, bool competing_0)
{
    SampleBSDF _S739 = (fcptConnectHair((surface_5->hair), ((&surface_5->material)->albedo), ((&surface_5->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S740 = _S739.throughput * make_float3 (_S739.pdf);
    float _S741 = light_1->density;
    float _S742 = 1.0f + _S739.pdf * _S739.pdf / (light_1->density * light_1->density);
    bool _S743;
    if(competing_0)
    {
        _S743 = _S741 > 0.0f;
    }
    else
    {
        _S743 = false;
    }
    float _S744 = _slang_select(_S743, _S742,1.0f);
    return _S740 / make_float3 (_S744) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_9, float3  radiance_1, float density_0, uint random_state_9)
{
    TreeSample _S745;
    (&_S745)->dir = dir_9;
    (&_S745)->radiance = radiance_1;
    (&_S745)->density = density_0;
    (&_S745)->random_state = random_state_9;
    return _S745;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S746 = importance(first_1, p_12, normal_3);
    float _S747 = importance(second_1, p_12, normal_3);
    float2  _S748 = make_float2 (_S746, _S747);
    bool _S749 = _S746 == 0.0f;
    bool _S750;
    if(_S749)
    {
        _S750 = _S747 == 0.0f;
    }
    else
    {
        _S750 = false;
    }
    if(_S750)
    {
        return 2U;
    }
    float _S751 = _S746 + _S747;
    bool _S752 = _S747 > 0.0f;
    if(_S752)
    {
        _S750 = (*pick_0 * _S751) >= _S746;
    }
    else
    {
        _S750 = false;
    }
    uint _S753 = uint(_S750);
    float _S754 = (F32_min(((*pick_0 * _S751 - float(_S753) * _S746) / _slang_vector_get_element(_S748, _S753)), (0.99999994039535522f)));
    *pick_0 = _S754;
    float _S755 = *probability_3 * (_slang_vector_get_element(_S748, _S753) / _S751);
    *probability_3 = _S755;
    return _S753;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S756 = center_1 - p_13;
    float _S757 = radius_1 * radius_1 / dot_0(_S756, _S756);
    float _S758 = u1_0 * _S757 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S757), (0.0f)))))));
    float _S759 = 2.0f * u1_0;
    bool _S760 = _S757 >= 1.0f;
    float _S761 = _slang_select(_S760, _S759,_S758);
    float _S762 = (F32_sqrt(((F32_max((_S761 * (2.0f - _S761)), (0.0f))))));
    float _S763 = 6.28318548202514648f * u2_0;
    float3  _S764 = make_float3 (_S762 * (F32_cos((_S763))), 1.0f - _S761, _S762 * (F32_sin((_S763))));
    float3  _S765 = ((((_S756)) * make_float3(rnorm3df(((_S756)).x, ((_S756)).y, ((_S756)).z))));
    float3  _S766 = tangentToWorld(_S764, _S765);
    return _S766;
}

__device__ float3  pointLightRadiance(float3  color_3, float intensity_0, float radius_2)
{
    return color_3 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S767 = center_2 - ray_1->origin;
    float _S768 = dot_0(_S767, ray_1->unit_direction);
    float _S769 = dot_0(_S767, _S767) - _S768 * _S768;
    float _S770 = radius_3 * radius_3;
    bool _S771 = _S769 > _S770;
    if(_S771)
    {
        return 4.294967296e+09f;
    }
    float _S772 = (F32_sqrt((_S770 - _S769)));
    float _S773 = _S768 - _S772;
    float _S774 = _S768 + _S772;
    bool _S775 = _S773 > 0.0000152587890625f;
    bool _S776;
    if(_S775)
    {
        _S776 = _S773 < max_len_0;
    }
    else
    {
        _S776 = false;
    }
    if(_S776)
    {
        return _S773;
    }
    bool _S777 = _S774 > 0.0000152587890625f;
    if(_S777)
    {
        _S776 = _S774 < max_len_0;
    }
    else
    {
        _S776 = false;
    }
    if(_S776)
    {
        return _S774;
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
        int i_15 = int(0);
        float sum_0 = 0.0f;
        for(;;)
        {
            if(i_15 < int(3))
            {
            }
            else
            {
                break;
            }
            float sum_1 = sum_0 + _slang_vector_get_element(left_1, i_15) * _slang_vector_get_element(right_1.rows[i_15], j_1);
            i_15 = i_15 + int(1);
            sum_0 = sum_1;
        }
        *_slang_vector_get_element_ptr(&result_6, j_1) = sum_0;
        j_1 = j_1 + int(1);
    }
    return result_6;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S778 = pcg(init_random_state_1);
    Random _S779 = pcg(_S778.state);
    Random _S780 = pcg(_S779.state);
    float3  _S781 = make_float3 (0.0f);
    TreeSample _S782 = TreeSample_x24init_0(_S781, _S781, 0.0f, _S780.state);
    TreeSample sample_0 = _S782;
    float3  _S783 = _slang_select(sided_0, _S781,smooth_n_2);
    float3  _S784 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S778.value;
    float probability_4 = 1.0f;
    uint n_7 = 0U;
    for(;;)
    {
        uint4  _S785 = (fcptLightNode((n_7)));
        if((_S785.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S786 = (fcptLightSecond((n_7)));
        uint _S787 = n_7 + 1U;
        LightNode _S788 = (fcptLightBounds((_S787)));
        LightNode _S789 = (fcptLightBounds((_S786)));
        uint _S790 = pickChild(_S788, _S789, origin_4, _S783, &pick_1, &probability_4);
        bool _S791 = _S790 > 1U;
        if(_S791)
        {
            return sample_0;
        }
        bool _S792 = _S790 == 1U;
        uint _S793 = _slang_select(_S792, _S786,_S787);
        n_7 = _S793;
    }
    bool _S794 = n_7 == 0U;
    bool _S795;
    if(_S794)
    {
        LightNode _S796 = (fcptLightBounds((0U)));
        float _S797 = importance(_S796, origin_4, _S783);
        _S795 = !(_S797 > 0.0f);
    }
    else
    {
        _S795 = false;
    }
    if(_S795)
    {
        return sample_0;
    }
    uint4  _S798 = (fcptLightNode((n_7)));
    FKHit _S799 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S800 = (_S798.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S800)
    {
        FKLight _S801 = (fcptLight((_S798.y)));
        if(sided_0)
        {
            float _S802 = sign_0(dot_0(geometry_n_1, _S801.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S802);
            float3  _S803 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S803;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S784;
            lift_n_0 = smooth_n_2;
        }
        bool _S804 = (_S801.variance) == 0.0f;
        if(_S804)
        {
            float3  _S805 = _S801.position - emitter_point_0;
            float3  _S806 = ((((_S805)) * make_float3(rnorm3df(((_S805)).x, ((_S805)).y, ((_S805)).z))));
            (&sample_0)->dir = _S806;
            float3  _S807 = _S801.color * make_float3 (_S801.intensity) / make_float3 (dot_0(_S805, _S805) * probability_4);
            (&sample_0)->radiance = _S807;
            shadow_1 = _S805;
        }
        else
        {
            float3  _S808 = sampleSphere(_S801.position, _S801.variance, emitter_point_0, _S779.value, _S780.value);
            (&sample_0)->dir = _S808;
            float _S809 = sphereDensity(_S801.position, _S801.variance, emitter_point_0);
            float _S810 = probability_4 * _S809;
            (&sample_0)->density = _S810;
            float3  _S811 = pointLightRadiance(_S801.color, _S801.intensity, _S801.variance);
            float3  _S812 = _S811 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S812;
            FKRay _S813 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S814 = raySphere_0(_S801.position, _S801.variance, &_S813, 4.294967296e+09f);
            float3  _S815 = (&sample_0)->dir * make_float3 (_S814);
            shadow_1 = _S815;
        }
        emitter_0 = _S799;
        emitter_point_0 = _S781;
    }
    else
    {
        uint _S816 = _S798.y;
        uint _S817 = (fcptTriangleOffset((_S816)));
        uint _S818 = _S817 + _S798.z;
        Matrix<float, 3, 3>  _S819 = (fcptWorldTriangle((_S816), (_S818)));
        float _S820 = (F32_sqrt((_S779.value)));
        float2  _S821 = make_float2 (_S820 * (1.0f - _S780.value), _S820 * _S780.value);
        float3  _S822 = mul_0(make_float3 (1.0f - _S820, _S821.x, _S821.y), _S819);
        if(sided_0)
        {
            float _S823 = sign_0(dot_0(geometry_n_1, _S822 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S823);
            float3  _S824 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S824;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S825 = !((dot_0(smooth_n_2, _S822 - origin_4)) > 0.0f);
            if(_S825)
            {
                return sample_0;
            }
            emitter_point_0 = _S784;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S821, _S816, _S818, 0U, 0.0f);
        float3  _S826 = _S822 - emitter_point_0;
        float3  _S827 = ((((_S826)) * make_float3(rnorm3df(((_S826)).x, ((_S826)).y, ((_S826)).z))));
        (&sample_0)->dir = _S827;
        float _S828 = solidAngle(probability_4, cross_0(_S819.rows[int(1)] - _S819.rows[int(0)], _S819.rows[int(2)] - _S819.rows[int(0)]), _S826);
        (&sample_0)->density = _S828;
        bool _S829 = (fcptShadowFirst());
        bool _S830 = !_S829;
        if(_S830)
        {
            FKSurface _S831 = (fcptLightSurfaceAt((emitter_1), (_S822), (_S780.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S822 - origin_4))));
            (&sample_0)->random_state = _S831.random_state;
            float3  _S832 = _slang_select(_S831.skip, _S781,_S831.material.emissive);
            float3  _S833 = _S832 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S833;
        }
        shadow_1 = _S826;
        emitter_0 = emitter_1;
        emitter_point_0 = _S822;
    }
    FKHit _S834 = emitter_0;
    float3  _S835 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S780.state, &_S834);
    bool _S836 = (fcptShadowFirst());
    if(_S836)
    {
        _S795 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S795 = false;
    }
    if(_S795)
    {
        _S795 = !all_1(_S835 == _S781);
    }
    else
    {
        _S795 = false;
    }
    if(_S795)
    {
        FKSurface _S837 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S780.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S837.random_state;
        float3  _S838 = _slang_select(_S837.skip, _S781,_S837.material.emissive);
        float3  _S839 = _S838 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S839;
    }
    float3  _S840 = (&sample_0)->radiance * _S835;
    bool _S841 = all_1(_S835 == _S781);
    float3  _S842 = _slang_select(_S841, _S781,_S840);
    (&sample_0)->radiance = _S842;
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
    float _S843 = 1.0f / (1.0f + b_2 / a_8 * (b_2 / a_8));
    bool _S844 = b_2 > 0.0f;
    float _S845 = _slang_select(_S844, _S843,1.0f);
    return _S845;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S846 = vertex_0->none;
    if(_S846)
    {
        return 1.0f;
    }
    uint _S847 = (fcptLightSlot((*hit_1)));
    float _S848 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S847, light_point_1);
    float _S849 = powerHeuristic(vertex_0->pdf, _S848);
    return _S849;
}

struct Vertex
{
    bool rough;
    uint lobe;
    float pdf;
    float cos;
    bool inside;
};

__device__ float3  pathColor(float3  f_5, float3  weight_0, float wavelength_5)
{
    float _S850 = upsample(f_5, wavelength_5);
    float3  _S851 = weight_0 * make_float3 (_S850);
    bool _S852 = wavelength_5 > 0.0f;
    float3  _S853 = _slang_select(_S852, _S851,f_5);
    return _S853;
}

__device__ float3  safeDivide(float3  a_9, float3  b_3)
{
    float3  _S854 = a_9 / b_3;
    float3  _S855 = make_float3 (0.0f);
    bool3  _S856 = b_3 == _S855;
    float3  _S857 = _slang_select(_S856, _S855,_S854);
    return _S857;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S858 = (1U << count_2) - 1U;
    return (e_2 & (~(_S858 << offset_1))) | ((newbits_0 & _S858) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_3, uint end_type_0, uint end_0, float3  f_6)
{
    Reservoir candidate_0 = r_3;
    uint _S859 = insertBits_0(r_3.path, end_0, 0U, 5U);
    uint _S860 = insertBits_0(_S859, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S860;
    (&candidate_0)->f = f_6;
    return candidate_0;
}

static __device__ float3  abs_0(float3  x_16)
{
    float3  result_7;
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
        *_slang_vector_get_element_ptr(&result_7, i_16) = (F32_abs((_slang_vector_get_element(x_16, i_16))));
        i_16 = i_16 + int(1);
    }
    return result_7;
}

__device__ float resamplingTarget(float3  f_7)
{
    float _S861 = rgb_to_greyscale(abs_0(f_7));
    return _S861;
}

__device__ void offer(Selection * sel_2, Reservoir candidate_1, float3  weight_1)
{
    float _S862 = resamplingTarget(weight_1);
    bool _S863 = _S862 > 0.0f;
    bool _S864;
    if(_S863)
    {
        _S864 = _S862 < 3.00000000549775576e+38f;
    }
    else
    {
        _S864 = false;
    }
    bool _S865 = !_S864;
    if(_S865)
    {
        return;
    }
    bool _S866 = sel_2->sums;
    if(_S866)
    {
        float3  _S867 = sel_2->color + weight_1;
        sel_2->color = _S867;
        return;
    }
    float _S868 = sel_2->w_sum + _S862;
    sel_2->w_sum = _S868;
    float3  _S869 = sel_2->color + weight_1;
    sel_2->color = _S869;
    Random _S870 = pcg(sel_2->random_state);
    sel_2->random_state = _S870.state;
    bool _S871 = (_S870.value * sel_2->w_sum) <= _S862;
    if(_S871)
    {
        sel_2->r = candidate_1;
    }
    return;
}

static __device__ Shift escape_0(Reservoir * r_4, bool replay_1, uint stop_0, uint rc_0, uint end_1, uint end_type_1, float scale_3, uint strata_0, Reservoir * chain_0, float3  chain_throughput_0, uint b_4, FKRay * ray_2, float3  throughput_0, float density_1, Vertex * prev_0, NEEVertex * nee_vertex_0, float sky_pdf_0, float3  spectral_weight_0, float wavelength_6, Selection * sel_3)
{
    Shift _S872 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
    bool _S873 = !nee_vertex_0->none;
    float _S874 = _slang_select(_S873, sky_pdf_0,0.0f);
    float3  _S875 = ray_2->unit_direction;
    float _S876 = escapeWeight_0(_S874, ray_2->unit_direction);
    uint _S877 = prev_0->lobe;
    float3  _S878 = environment_0(_S875, b_4, prev_0->lobe);
    float3  _S879 = pathColor(throughput_0 * _S878, spectral_weight_0, wavelength_6);
    if(replay_1)
    {
        bool _S880 = b_4 == stop_0;
        bool _S881;
        if(_S880)
        {
            _S881 = rc_0 == 3U;
        }
        else
        {
            _S881 = false;
        }
        if(_S881)
        {
            return Shift_x24init_0(_S879 * make_float3 (_S876) / make_float3 (r_4->jac), density_1 / r_4->jac);
        }
        bool _S882 = rc_0 == 0U;
        if(_S882)
        {
            _S881 = end_type_1 == 3U;
        }
        else
        {
            _S881 = false;
        }
        if(_S881)
        {
            _S881 = b_4 == end_1;
        }
        else
        {
            _S881 = false;
        }
        if(_S881)
        {
            _S881 = !prev_0->rough;
        }
        else
        {
            _S881 = false;
        }
        if(_S881)
        {
            return Shift_x24init_0(_S879 * make_float3 (_S876), 1.0f);
        }
        return _S872;
    }
    Reservoir candidate_2 = *chain_0;
    uint _S883 = chain_0->path;
    uint _S884 = extractBits_0(chain_0->path, 10U, 2U);
    bool _S885 = _S884 == 1U;
    if(_S885)
    {
        uint _S886 = extractBits_0(_S883, 5U, 5U);
        bool _S887 = _S886 == b_4;
        float _S888 = _slang_select(_S887, 1.0f,_S876);
        float3  _S889 = safeDivide(_S879 * make_float3 (_S888), chain_throughput_0);
        (&candidate_2)->radiance = _S889;
    }
    else
    {
        bool _S890 = prev_0->rough;
        if(_S890)
        {
            uint _S891 = insertBits_0(strata_0, b_4 + 1U, 5U, 5U);
            uint _S892 = insertBits_0(_S891, 3U, 10U, 2U);
            uint _S893 = insertBits_0(_S892, _S877, 15U, 3U);
            bool _S894 = prev_0->inside;
            uint _S895 = _slang_select(_S894, 1U,0U);
            uint _S896 = insertBits_0(_S893, _S895, 22U, 1U);
            (&candidate_2)->path = _S896;
            (&candidate_2)->jac = prev_0->pdf;
            (&candidate_2)->dir = _S875;
        }
    }
    float3  _S897 = _S879 * make_float3 (_S876);
    Reservoir _S898 = withEnd(candidate_2, 3U, b_4, _S897);
    offer(sel_3, _S898, _S897 * make_float3 (scale_3) / make_float3 (density_1));
    return _S872;
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S899 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S900 = make_int2 ((int)_S899.x, (int)_S899.y);
    uint _S901 = previousSeed_0(_S900);
    int y_5 = int(-8);
    uint count_3 = 0U;
    for(;;)
    {
        if(y_5 <= int(8))
        {
        }
        else
        {
            break;
        }
        int x_17 = int(-8);
        for(;;)
        {
            if(x_17 <= int(8))
            {
            }
            else
            {
                break;
            }
            uint _S902 = previousSeed_0(_S900 + make_int2 (x_17, y_5));
            bool _S903 = _S902 == _S901;
            uint _S904 = _slang_select(_S903, 1U,0U);
            uint count_4 = count_3 + _S904;
            int x_18 = x_17 + int(1);
            x_17 = x_18;
            count_3 = count_4;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S905 = float(count_3 - 1U) / 288.0f;
    bool _S906 = _S901 != 0U;
    float _S907 = _slang_select(_S906, _S905,0.0f);
    fcptStoreDuplication((_S900), (make_uint4 ((F32_asuint((_S907))), 0U, 0U, 0U)));
    return;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S908 = hash(index_0);
    uint _S909 = hash(seed_3 ^ _S908);
    return _S909;
}

static __device__ float4  asfloat_0(uint4  x_19)
{
    float4  result_8;
    int i_17 = int(0);
    for(;;)
    {
        if(i_17 < int(4))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_8, i_17) = (U32_asfloat((_slang_vector_get_element(x_19, i_17))));
        i_17 = i_17 + int(1);
    }
    return result_8;
}

__device__ void offerShifted(Selection * sel_4, Reservoir r_5, Shift shifted_0, float mis_0)
{
    Reservoir candidate_3 = r_5;
    float3  _S910 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_3)->f = _S910;
    float _S911 = r_5.jac * shifted_0.jac;
    (&candidate_3)->jac = _S911;
    offer(sel_4, candidate_3, make_float3 (mis_0) * shifted_0.f * make_float3 (r_5.w));
    return;
}

__device__ Reservoir finalize(Selection sel_5, float c_1)
{
    Reservoir r_6 = sel_5.r;
    float _S912 = resamplingTarget((&r_6)->f);
    float _S913 = sel_5.w_sum / _S912;
    bool _S914 = _S912 > 0.0f;
    float _S915 = _slang_select(_S914, _S913,0.0f);
    (&r_6)->w = _S915;
    (&r_6)->c = c_1;
    return r_6;
}

static __device__ uint2  asuint_0(float2  x_20)
{
    uint2  result_9;
    int i_18 = int(0);
    for(;;)
    {
        if(i_18 < int(2))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_9, i_18) = (F32_asuint((_slang_vector_get_element(x_20, i_18))));
        i_18 = i_18 + int(1);
    }
    return result_9;
}

static __device__ void restir_spatial_0(uint3  global_invocation_id_2)
{
    uint2  _S916 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S917 = make_int2 ((int)_S916.x, (int)_S916.y);
    float3  _S918 = make_float3 (0.0f);
    FKHit _S919 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S920 = Domain_x24init_0(_S918, _S918, &_S919, 0.0f, 0.0f);
    Domain dom_4 = _S920;
    bool _S921 = (fcptCurrentDomain((_S917), (&dom_4)));
    bool _S922 = !_S921;
    if(_S922)
    {
        Reservoir _S923 = (Reservoir{});
        fcptStoreReservoirPrevious((_S917), (_S923), ((&dom_4)->hit));
        return;
    }
    Reservoir _S924 = (fcptLoadReservoirTemporal((_S917)));
    uint t_15 = 0U;
    float count_5 = 0.0f;
    float c_sum_0 = _S924.c;
    for(;;)
    {
        uint _S925 = (fcptRestirNeighbours());
        if(t_15 < _S925)
        {
        }
        else
        {
            break;
        }
        int2  _S926 = partner_0(_S917, t_15);
        Domain neighbor_0 = _S920;
        bool _S927 = (fcptCurrentDomain((_S926), (&neighbor_0)));
        if(_S927)
        {
            float count_6 = count_5 + 1.0f;
            uint4  _S928 = (fcptReservoirTemporal((_S926), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S928.w)));
            count_5 = count_6;
            c_sum_0 = c_sum_1;
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    float _S929 = _S924.c / (F32_max((count_5), (1.0f)));
    float _S930 = resamplingTarget(_S924.f);
    bool _S931 = count_5 == 0.0f;
    float _S932 = _slang_select(_S931, 1.0f,0.0f);
    Selection _S933 = (Selection{});
    Selection sel_6 = _S933;
    uint _S934 = (fcptFrame());
    uint _S935 = hash(_S934);
    uint _S936 = global_invocation_id_2.x;
    uint2  _S937 = (fcptRenderSize());
    uint _S938 = stream(_S935, _S936 + _S937.x * global_invocation_id_2.y);
    uint _S939 = stream(_S938, 195U);
    (&sel_6)->random_state = _S939;
    t_15 = 0U;
    float canonical_mis_0 = _S932;
    for(;;)
    {
        uint _S940 = (fcptRestirNeighbours());
        if(t_15 < _S940)
        {
        }
        else
        {
            break;
        }
        int2  _S941 = partner_0(_S917, t_15);
        Domain neighbor_dom_0 = _S920;
        bool _S942 = (fcptCurrentDomain((_S941), (&neighbor_dom_0)));
        if(_S942)
        {
            Reservoir _S943 = (fcptLoadReservoirTemporal((_S941)));
            uint4  _S944 = (fcptShiftData((_S941), (t_15)));
            float4  _S945 = asfloat_0(_S944);
            uint4  _S946 = (fcptShiftData((_S917), (t_15)));
            float4  _S947 = asfloat_0(_S946);
            float _S948 = (_S943.c + _S929) / c_sum_0;
            bool _S949 = _S930 > 0.0f;
            float canonical_mis_1;
            if(_S949)
            {
                float _S950 = _S948 * _S929 * _S930;
                float _S951 = _S929 * _S930;
                float _S952 = resamplingTarget(float3 {_S947.x, _S947.y, _S947.z});
                float canonical_mis_2 = canonical_mis_0 + _S950 / (_S951 + _S943.c * _S952);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S953 = resamplingTarget(_S943.f);
            float3  _S954 = float3 {_S945.x, _S945.y, _S945.z};
            Shift _S955 = Shift_x24init_0(_S954, _S945.w);
            float _S956 = _S948 * _S943.c * _S953;
            float _S957 = _S943.c * _S953;
            float _S958 = resamplingTarget(_S954);
            offerShifted(&sel_6, _S943, _S955, _S956 / (_S957 + _S929 * _S958));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_17 = t_15 + 1U;
        t_15 = t_17;
    }
    offerShifted(&sel_6, _S924, Shift_x24init_0(_S924.f, 1.0f), canonical_mis_0);
    Reservoir _S959 = finalize(sel_6, c_sum_0);
    fcptStoreReservoirPrevious((_S917), (_S959), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S917), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S917), (make_float4 ((&sel_6)->color.x, (&sel_6)->color.y, (&sel_6)->color.z, 0.0f)));
    return;
}

static __device__ uint3  asuint_1(float3  x_21)
{
    uint3  result_10;
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
        *_slang_vector_get_element_ptr(&result_10, i_19) = (F32_asuint((_slang_vector_get_element(x_21, i_19))));
        i_19 = i_19 + int(1);
    }
    return result_10;
}

static __device__ void restir_shift_0(uint3  workgroup_id_1, uint local_invocation_index_4)
{
    uint _S960 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S961 = _S960 != 4294967295U;
    if(_S961)
    {
        uint2  _S962 = make_uint2 (_S960, _S960 >> 14U) & make_uint2 (16383U);
        int2  _S963 = make_int2 ((int)_S962.x, (int)_S962.y);
        ShiftJob _S964 = (ShiftJob{});
        ShiftJob shift_job_0 = _S964;
        Shift _S965 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S966 = _S960 >> 28U;
        bool _S967 = spatialJob_0(_S963, _S966, &shift_job_0, true);
        Shift shifted_1;
        if(_S967)
        {
            Domain _S968 = (&shift_job_0)->dom;
            Reservoir _S969 = (&shift_job_0)->r;
            Shift _S970 = passShift_0(&_S968, &_S969);
            shifted_1 = _S970;
        }
        else
        {
            shifted_1 = _S965;
        }
        fcptStoreShiftData((_S963), (_S966), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S971 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S972 = make_int2 ((int)_S971.x, (int)_S971.y);
    FixedArray<uint, 3>  _S973;
    spatialBins_0(_S972, &_S973);
    FixedArray<uint, 3>  _S974 = _S973;
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
        bool _S975 = (_S974[t_18]) == 40U;
        if(_S975)
        {
            fcptStoreShiftData((_S972), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S976 = _S974;
    queueShifts_0(_S972, &_S976, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S977 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S978 = make_int2 ((int)_S977.x, (int)_S977.y);
    FixedArray<uint, 3>  _S979;
    spatialBins_0(_S978, &_S979);
    FixedArray<uint, 3>  _S980 = _S979;
    countShifts_0(&_S980, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S981 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S982 = _S981 != 4294967295U;
    if(_S982)
    {
        uint2  _S983 = make_uint2 (_S981, _S981 >> 14U) & make_uint2 (16383U);
        int2  _S984 = make_int2 ((int)_S983.x, (int)_S983.y);
        int2  _S985 = (fcptLoadTemporalNeighbor((_S984)));
        uint _S986 = _S981 >> 28U;
        Shift _S987 = temporalShiftAt_0(_S984, _S985, _S986);
        fcptStoreTemporalShift((_S984), (_S986), (make_uint4 (asuint_1(_S987.f).x, asuint_1(_S987.f).y, asuint_1(_S987.f).z, (F32_asuint((_S987.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S988 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S989 = make_int2 ((int)_S988.x, (int)_S988.y);
    FixedArray<uint, 3>  _S990;
    temporalBins_0(_S989, &_S990);
    FixedArray<uint, 3>  _S991 = _S990;
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
        bool _S992 = (_S991[t_20]) == 40U;
        if(_S992)
        {
            fcptStoreTemporalShift((_S989), (t_20), (make_uint4 (0U)));
        }
        uint t_21 = t_20 + 1U;
        t_20 = t_21;
    }
    FixedArray<uint, 3>  _S993 = _S991;
    queueShifts_0(_S989, &_S993, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S994 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S995 = make_int2 ((int)_S994.x, (int)_S994.y);
    bool _S996 = (fcptSceneUnchanged());
    bool _S997 = !_S996;
    bool _S998;
    if(_S997)
    {
        uint2  _S999 = (fcptRenderSize());
        int2  _S1000 = make_int2 ((int)_S999.x, (int)_S999.y);
        _S998 = all_0(_S995 < _S1000);
    }
    else
    {
        _S998 = false;
    }
    if(_S998)
    {
        Reservoir _S1001 = (fcptLoadReservoirInitial((_S995)));
        int2  _S1002 = sampleNeighbor_0(_S995, _S1001.seed);
        fcptStoreTemporalNeighbor((_S995), (_S1002));
    }
    FixedArray<uint, 3>  _S1003;
    temporalBins_0(_S995, &_S1003);
    FixedArray<uint, 3>  _S1004 = _S1003;
    countShifts_0(&_S1004, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_10, float b_5, float t_22)
{
    return a_10 + (b_5 - a_10) * t_22;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S1005 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S1006 = make_int2 ((int)_S1005.x, (int)_S1005.y);
    float3  _S1007 = make_float3 (0.0f);
    FKHit _S1008 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S1009 = Domain_x24init_0(_S1007, _S1007, &_S1008, 0.0f, 0.0f);
    Domain dom_5 = _S1009;
    bool _S1010 = (fcptCurrentDomain((_S1006), (&dom_5)));
    bool _S1011 = !_S1010;
    if(_S1011)
    {
        Reservoir _S1012 = (Reservoir{});
        fcptStoreReservoirTemporal((_S1006), (_S1012), ((&dom_5)->hit));
        return;
    }
    Reservoir _S1013 = (fcptLoadReservoirInitial((_S1006)));
    bool _S1014 = (fcptTemporalQueued());
    bool _S1015 = (fcptSceneUnchanged());
    bool _S1016;
    if(_S1015)
    {
        _S1016 = true;
    }
    else
    {
        _S1016 = !_S1014;
    }
    int2  _S1017;
    if(_S1016)
    {
        int2  _S1018 = sampleNeighbor_0(_S1006, _S1013.seed);
        _S1017 = _S1018;
    }
    else
    {
        int2  _S1019 = (fcptLoadTemporalNeighbor((_S1006)));
        _S1017 = _S1019;
    }
    bool _S1020 = (_S1017.x) >= int(0);
    Reservoir r_7;
    if(_S1020)
    {
        Reservoir _S1021 = (fcptLoadReservoirPrevious((_S1017)));
        uint4  _S1022 = (fcptDuplication((_S1017)));
        float _S1023 = (U32_asfloat((_S1022.x)));
        uint _S1024 = (fcptRestirDecorrelation());
        bool _S1025 = _S1024 == 1U;
        float _S1026 = _slang_select(_S1025, _S1023,0.0f);
        float _S1027 = interpolate_0(20.0f, 1.0f, (F32_pow((_S1026), (0.10000000149011612f))));
        float _S1028 = (F32_min((_S1021.c), (_S1027)));
        bool _S1029 = (fcptSceneUnchanged());
        float4  _S1030 = make_float4 (_S1021.f.x, _S1021.f.y, _S1021.f.z, 1.0f);
        bool _S1031 = !_S1029;
        if(_S1031)
        {
            _S1016 = _S1014;
        }
        else
        {
            _S1016 = false;
        }
        float4  to_current_0;
        if(_S1016)
        {
            uint4  _S1032 = (fcptTemporalShift((_S1006), (0U)));
            float4  _S1033 = asfloat_0(_S1032);
            to_current_0 = _S1033;
        }
        else
        {
            if(_S1031)
            {
                Shift _S1034 = temporalShiftAt_0(_S1006, _S1017, 0U);
                float4  _S1035 = make_float4 (_S1034.f.x, _S1034.f.y, _S1034.f.z, _S1034.jac);
                to_current_0 = _S1035;
            }
            else
            {
                to_current_0 = _S1030;
            }
        }
        Domain own_1 = _S1009;
        if(_S1029)
        {
            _S1016 = true;
        }
        else
        {
            bool _S1036 = (fcptPreviousScenes());
            bool _S1037 = !_S1036;
            if(_S1037)
            {
                _S1016 = (_S1013.w) > 0.0f;
            }
            else
            {
                _S1016 = false;
            }
            if(_S1016)
            {
                bool _S1038 = (fcptStoredDomainInitial((_S1006), (_S1013.seed), (&own_1)));
                _S1016 = _S1038;
            }
            else
            {
                _S1016 = false;
            }
            if(_S1016)
            {
                Domain _S1039 = (fcptPreviousDomain((_S1017), (_S1013.seed)));
                Domain _S1040 = _S1039;
                Domain _S1041 = own_1;
                bool _S1042 = sameDomain_0(&_S1040, &_S1041);
                _S1016 = _S1042;
            }
            else
            {
                _S1016 = false;
            }
        }
        float4  _S1043 = make_float4 (_S1013.f.x, _S1013.f.y, _S1013.f.z, 1.0f);
        bool _S1044 = !_S1016;
        if(_S1044)
        {
            _S1016 = _S1014;
        }
        else
        {
            _S1016 = false;
        }
        float4  to_previous_0;
        if(_S1016)
        {
            uint4  _S1045 = (fcptTemporalShift((_S1006), (1U)));
            float4  _S1046 = asfloat_0(_S1045);
            to_previous_0 = _S1046;
        }
        else
        {
            if(_S1044)
            {
                Shift _S1047 = temporalShiftAt_0(_S1006, _S1017, 1U);
                float4  _S1048 = make_float4 (_S1047.f.x, _S1047.f.y, _S1047.f.z, _S1047.jac);
                to_previous_0 = _S1048;
            }
            else
            {
                to_previous_0 = _S1043;
            }
        }
        float _S1049 = resamplingTarget(_S1013.f);
        float _S1050 = resamplingTarget(_S1021.f);
        Selection _S1051 = (Selection{});
        Selection sel_7 = _S1051;
        uint _S1052 = (fcptFrame());
        uint _S1053 = hash(_S1052);
        uint _S1054 = global_invocation_id_7.x;
        uint2  _S1055 = (fcptRenderSize());
        uint _S1056 = stream(_S1053, _S1054 + _S1055.x * global_invocation_id_7.y);
        uint _S1057 = stream(_S1056, 194U);
        (&sel_7)->random_state = _S1057;
        float _S1058 = _S1013.c * _S1049;
        float4  _S1059 = to_previous_0;
        float _S1060 = resamplingTarget(float3 {_S1059.x, _S1059.y, _S1059.z});
        float _S1061 = _S1058 / (_S1058 + _S1028 * _S1060);
        float _S1062 = _S1028 * _S1050;
        float4  _S1063 = to_current_0;
        float3  _S1064 = float3 {_S1063.x, _S1063.y, _S1063.z};
        float _S1065 = resamplingTarget(_S1064);
        float _S1066 = _S1062 / (_S1062 + _S1013.c * _S1065);
        float2  _S1067 = make_float2 (_S1061, _S1066);
        offerShifted(&sel_7, _S1013, Shift_x24init_0(_S1013.f, 1.0f), _S1061);
        offerShifted(&sel_7, _S1021, Shift_x24init_0(_S1064, to_current_0.w), _S1066);
        Reservoir _S1068 = finalize(sel_7, _S1013.c + _S1028);
        r_7 = _S1068;
    }
    else
    {
        r_7 = _S1013;
    }
    fcptStoreReservoirTemporal((_S1006), (r_7), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S1069 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S1070 = make_int2 ((int)_S1069.x, (int)_S1069.y);
    float3  _S1071 = make_float3 (0.0f);
    float2  _S1072 = make_float2 (0.0f);
    FKHit _S1073 = Hit_x24init_0(_S1072, 0U, 0U, 0U, 0.0f);
    Domain _S1074 = Domain_x24init_0(_S1071, _S1071, &_S1073, 0.0f, 0.0f);
    Domain dom_6 = _S1074;
    bool _S1075 = (fcptCurrentDomain((_S1070), (&dom_6)));
    bool _S1076 = !_S1075;
    if(_S1076)
    {
        Reservoir _S1077 = (Reservoir{});
        fcptStoreReservoirInitial((_S1070), (_S1077), ((&dom_6)->hit));
        return;
    }
    uint _S1078 = (fcptFrame());
    uint _S1079 = hash(_S1078);
    uint _S1080 = global_invocation_id_8.x;
    uint2  _S1081 = (fcptRenderSize());
    uint _S1082 = global_invocation_id_8.y;
    uint _S1083 = stream(_S1079, _S1080 + _S1081.x * _S1082);
    uint2  _S1084 = (fcptRenderSize());
    uint _S1085 = stream(_S1080 + _S1084.x * _S1082, 512U);
    Selection _S1086 = (Selection{});
    Selection initial_0 = _S1086;
    uint _S1087 = stream(_S1083, 193U);
    (&initial_0)->random_state = _S1087;
    bool _S1088 = (fcptRestirUsed());
    bool _S1089 = !_S1088;
    (&initial_0)->sums = _S1089;
    uint _S1090 = stream(_S1083, 0U);
    (&(&initial_0)->r)->seed = _S1090;
    FKHit _S1091 = Hit_x24init_0(_S1072, 4294967295U, 0U, 0U, 0.0f);
    uint _S1092 = (fcptSamples());
    float _S1093 = 1.0f / float(_S1092);
    FKHit hit_2 = _S1091;
    uint i_20 = 0U;
    float3  seen_1 = _S1071;
    for(;;)
    {
        uint _S1094 = (fcptSamples());
        if(i_20 < _S1094)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1095 = (Reservoir{});
        Reservoir r_8 = _S1095;
        uint _S1096 = stream(_S1083, i_20);
        (&r_8)->seed = _S1096;
        uint _S1097 = (fcptFrame());
        uint _S1098 = (fcptSamples());
        uint _S1099 = _S1097 * _S1098 + i_20;
        uint _S1100 = insertBits_0(0U, 1U, 24U, 1U);
        uint _S1101 = insertBits_0(_S1100, (_S1085 + _S1099 * 2654435769U) >> 25U, 25U, 7U);
        (&r_8)->path = _S1101;
        Domain path_0 = _S1074;
        bool _S1102 = (fcptStoredDomainInitial((_S1070), ((&r_8)->seed), (&path_0)));
        bool _S1103 = !_S1102;
        if(_S1103)
        {
            float3  _S1104 = (fcptMissed((_S1070), (path_0), (_S1093)));
            float3  seen_2 = seen_1 + _S1104;
            seen_1 = seen_2;
            uint i_21 = i_20 + 1U;
            i_20 = i_21;
            continue;
        }
        Domain _S1105 = path_0;
        Reservoir _S1106 = r_8;
        Shift _S1107 = passWalk_0(&_S1105, &_S1106, false, _S1093, &initial_0);
        bool _S1108 = ((&(&initial_0)->r)->seed) == ((&r_8)->seed);
        FKHit hit_3;
        if(_S1108)
        {
            FKHit _S1109 = (&path_0)->hit;
            hit_3 = _S1109;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_21 = i_20 + 1U;
        i_20 = i_21;
    }
    uint _S1110 = (fcptSamples());
    float3  seen_3 = seen_1 + (&initial_0)->glow / make_float3 (float(_S1110));
    float3  _S1111 = seen_3 + (&initial_0)->color;
    bool _S1112 = (&initial_0)->sums;
    float3  _S1113 = _slang_select(_S1112, _S1111,seen_3);
    fcptAddColor((_S1070), (make_float4 (_S1113.x, _S1113.y, _S1113.z, 1.0f)));
    Reservoir _S1114 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S1070), (_S1114), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1115;
    (&_S1115)->none = none_0;
    (&_S1115)->pdf = pdf_4;
    (&_S1115)->origin = origin_5;
    (&_S1115)->smooth_n = smooth_n_3;
    (&_S1115)->start = start_6;
    return _S1115;
}

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_1, float pdf_5, float cos_0, bool inside_0)
{
    Vertex _S1116;
    (&_S1116)->rough = rough_0;
    (&_S1116)->lobe = lobe_1;
    (&_S1116)->pdf = pdf_5;
    (&_S1116)->cos = cos_0;
    (&_S1116)->inside = inside_0;
    return _S1116;
}

static __device__ float3  exp_0(float3  x_22)
{
    float3  result_11;
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
        *_slang_vector_get_element_ptr(&result_11, i_22) = (F32_exp((_slang_vector_get_element(x_22, i_22))));
        i_22 = i_22 + int(1);
    }
    return result_11;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_0, float distance_2, bool scatters_0)
{
    float3  _S1117 = exp_0((make_float3 (sigma_0) - extinction_0) * make_float3 (distance_2));
    float3  _S1118 = scatter_0 * _S1117 / make_float3 (sigma_0);
    float3  _S1119 = _slang_select(scatters_0, _S1118,_S1117);
    return _S1119;
}

static __device__ uint arrivalLobe_0(uint b_6, uint prev_lobe_0)
{
    bool _S1120 = b_6 > 0U;
    uint _S1121 = _slang_select(_S1120, prev_lobe_0,3U);
    return _S1121;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_2, uint lobe_2, bool surface_6, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1122;
    (&_S1122)->extinction_behind = extinction_behind_0;
    (&_S1122)->extinction_front = extinction_front_0;
    (&_S1122)->fillings = fillings_0;
    (&_S1122)->side = side_0;
    (&_S1122)->depth = depth_2;
    (&_S1122)->lobe = lobe_2;
    (&_S1122)->surface = surface_6;
    (&_S1122)->length = length_2;
    (&_S1122)->width = width_1;
    (&_S1122)->own = *own_2;
    (&_S1122)->fiber = fiber_0;
    return _S1122;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1123 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1123)
    {
        return 0.07957746833562851f;
    }
    float _S1124 = g_0 * g_0;
    return (1.0f - _S1124) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1124 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float survivalProbability(float3  throughput_1, float density_2)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_2), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_10)
{
    Random _S1125 = pcg(random_state_10);
    Random _S1126 = pcg(_S1125.state);
    float _S1127 = 1.0f - 2.0f * _S1125.value;
    float _S1128 = (F32_sqrt(((F32_max((1.0f - _S1127 * _S1127), (0.0f))))));
    float _S1129 = 6.28318548202514648f * _S1126.value;
    return make_float3 (_S1128 * (F32_cos((_S1129))), _S1128 * (F32_sin((_S1129))), _S1127);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_10, uint random_state_11, float * pdf_6)
{
    bool _S1130 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1130)
    {
        *pdf_6 = 0.07957746833562851f;
        float3  _S1131 = isotropic_0(random_state_11);
        return _S1131;
    }
    Random _S1132 = pcg(random_state_11);
    Random _S1133 = pcg(_S1132.state);
    float _S1134 = g_1 * g_1;
    float _S1135 = 2.0f * g_1;
    float _S1136 = (1.0f - _S1134) / (1.0f - g_1 + _S1135 * _S1132.value);
    float _S1137 = clamp_1((1.0f + _S1134 - _S1136 * _S1136) / _S1135, -1.0f, 1.0f);
    float _S1138 = (F32_sqrt(((F32_max((1.0f - _S1137 * _S1137), (0.0f))))));
    float _S1139 = 6.28318548202514648f * _S1133.value;
    float _S1140 = phaseHG_0(g_1, _S1137);
    *pdf_6 = _S1140;
    float3  _S1141 = tangentToWorld(make_float3 (_S1138 * (F32_cos((_S1139))), _S1137, _S1138 * (F32_sin((_S1139)))), dir_10);
    float3  _S1142 = ((((_S1141)) * make_float3(rnorm3df(((_S1141)).x, ((_S1141)).y, ((_S1141)).z))));
    return _S1142;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_1, float velvet_0, float3  toon_2, float dispersion_0)
{
    BSDFMaterial _S1143;
    (&_S1143)->albedo = albedo_1;
    (&_S1143)->emissive = emissive_0;
    (&_S1143)->roughness = roughness_0;
    (&_S1143)->metallic = metallic_0;
    (&_S1143)->transmission = transmission_0;
    (&_S1143)->ior = ior_0;
    (&_S1143)->absorption = absorption_0;
    (&_S1143)->specular_tint = specular_tint_0;
    (&_S1143)->specular_level = specular_level_0;
    (&_S1143)->translucent = translucent_0;
    (&_S1143)->sheen = sheen_2;
    (&_S1143)->sheen_roughness = sheen_roughness_0;
    (&_S1143)->anisotropy = anisotropy_0;
    (&_S1143)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1143)->tangent = tangent_1;
    (&_S1143)->velvet = velvet_0;
    (&_S1143)->toon = toon_2;
    (&_S1143)->dispersion = dispersion_0;
    return _S1143;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1144;
    (&_S1144)->scatter = scatter_1;
    (&_S1144)->extinction = extinction_1;
    (&_S1144)->g = g_2;
    return _S1144;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_14, bool skip_0, uint random_state_12, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1145;
    (&_S1145)->smooth_n = smooth_n_4;
    (&_S1145)->geometry_n = geometry_n_2;
    (&_S1145)->geometry_offset = geometry_offset_2;
    (&_S1145)->material = *material_14;
    (&_S1145)->skip = skip_0;
    (&_S1145)->random_state = random_state_12;
    (&_S1145)->coverage = coverage_0;
    (&_S1145)->encloses = encloses_0;
    (&_S1145)->volume = *volume_0;
    (&_S1145)->fills = fills_0;
    (&_S1145)->hair = hair_0;
    return _S1145;
}

static __device__ FKSurface emitting_0(FKSurface * surface_7, bool top_0)
{
    FKSurface lower_0 = *surface_7;
    float3  _S1146 = (&surface_7->material)->emissive;
    float3  _S1147 = make_float3 (0.0f);
    bool _S1148 = !top_0;
    float3  _S1149 = _slang_select(_S1148, _S1147,_S1146);
    (&(&lower_0)->material)->emissive = _S1149;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_8, float u_1)
{
    float _S1150 = surface_8->coverage;
    bool _S1151 = u_1 < _S1150;
    if(_S1151)
    {
        return *surface_8;
    }
    float3  _S1152 = make_float3 (0.0f);
    float3  _S1153 = make_float3 (1.0f);
    BSDFMaterial _S1154 = Material_x24init_0(_S1152, _S1152, 0.0f, 0.0f, 0.0f, 0.0f, _S1152, _S1153, 1.0f, _S1152, _S1152, 0.5f, 0.0f, 0.0f, _S1152, 0.0f, _S1152, 0.0f);
    BSDFMaterial material_15 = _S1154;
    (&material_15)->albedo = _S1153;
    (&material_15)->emissive = (&surface_8->material)->emissive;
    (&material_15)->transmission = 1.0f;
    (&material_15)->ior = 1.0f;
    (&material_15)->absorption = (&surface_8->material)->absorption;
    FKSurface through_0 = *surface_8;
    (&through_0)->material = material_15;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S1155 = transmission_1 > 0.0f;
    bool _S1156;
    if(_S1155)
    {
        _S1156 = true;
    }
    else
    {
        _S1156 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1157 = _slang_select(_S1156, 1.0f,-1.0f);
    return _S1157;
}

static __device__ bool arrivesBehind_0(float3  dir_11, float3  n_8)
{
    return (dot_0(dir_11, n_8)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_9, float3  dir_12)
{
    float3  _S1158 = surface_9->geometry_n;
    float _S1159 = facingSign((&surface_9->material)->transmission, surface_9->geometry_n, dir_12);
    FKSurface faced_0 = *surface_9;
    float3  _S1160 = surface_9->smooth_n * make_float3 (_S1159);
    (&faced_0)->smooth_n = _S1160;
    float3  _S1161 = _S1158 * make_float3 (_S1159);
    (&faced_0)->geometry_n = _S1161;
    return faced_0;
}

static __device__ float3  max_0(float3  x_23, float3  y_7)
{
    float3  result_12;
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
        *_slang_vector_get_element_ptr(&result_12, i_23) = (F32_max((_slang_vector_get_element(x_23, i_23)), (_slang_vector_get_element(y_7, i_23))));
        i_23 = i_23 + int(1);
    }
    return result_12;
}

static __device__ float3  log_0(float3  x_24)
{
    float3  result_13;
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
        *_slang_vector_get_element_ptr(&result_13, i_24) = (F32_log((_slang_vector_get_element(x_24, i_24))));
        i_24 = i_24 + int(1);
    }
    return result_13;
}

__device__ float3  beerLambert(float distance_3, float3  absorption_1)
{
    float3  _S1162 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1162));
}

__device__ bool dispersive(BSDFMaterial material_16)
{
    bool _S1163 = (material_16.dispersion) > 0.0f;
    bool _S1164;
    if(_S1163)
    {
        _S1164 = (material_16.ior) != 1.0f;
    }
    else
    {
        _S1164 = false;
    }
    return _S1164;
}

__device__ static const FixedArray<float, 81>  WAVELENGTH_CDF_0 = { {
    0.0f, 0.00006510900129797f, 0.00018772999465f, 0.00045414001215249f, 0.00105610000900924f, 0.00218509999103844f, 0.00430169980973005f, 0.00824129953980446f, 0.01521500013768673f, 0.02649199962615967f, 0.04202799871563911f, 0.06183499842882156f, 0.08581099659204483f, 0.11225000023841858f, 0.1395999938249588f, 0.16642999649047852f, 0.19130000472068787f, 0.21376000344753265f, 0.23378999531269073f, 0.25200000405311584f, 0.26912999153137207f, 0.28512999415397644f, 0.3002299964427948f, 0.31536000967025757f, 0.33153998851776123f, 0.34944000840187073f, 0.36937999725341797f, 0.39127999544143677f, 0.41528999805450439f, 0.4412899911403656f, 0.46840000152587891f, 0.49524000287055969f, 0.52063000202178955f, 0.54398000240325928f, 0.56476002931594849f, 0.58348000049591064f, 0.60238999128341675f, 0.62285000085830688f, 0.64474999904632568f, 0.66809999942779541f, 0.69291001558303833f, 0.71846002340316772f, 0.74393999576568604f, 0.76951998472213745f, 0.79534000158309937f, 0.82078999280929565f, 0.8454899787902832f, 0.86935001611709595f, 0.89191997051239014f, 0.91228997707366943f, 0.92987000942230225f, 0.94483000040054321f, 0.95753002166748047f, 0.96790999174118042f, 0.97605997323989868f, 0.98237001895904541f, 0.98721998929977417f, 0.9908599853515625f, 0.99356001615524292f, 0.99550998210906982f, 0.9969099760055542f, 0.99787998199462891f, 0.99852001667022705f, 0.99895000457763672f, 0.99924999475479126f, 0.99948000907897949f, 0.99963998794555664f, 0.99975001811981201f, 0.99983000755310059f, 0.99988001585006714f, 0.99990999698638916f, 0.99993997812271118f, 0.99996238946914673f, 0.99997591972351074f, 0.9999845027923584f, 0.99998998641967773f, 0.99999326467514038f, 0.99999552965164185f, 0.99999749660491943f, 0.99999898672103882f, 1.0f
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
        uint _S1165 = (low_1 + high_1 + 1U) / 2U;
        bool _S1166 = (WAVELENGTH_CDF_0[_S1165]) <= u_2;
        if(_S1166)
        {
            low_1 = _S1165;
        }
        else
        {
            uint _S1167 = _S1165 - 1U;
            high_1 = _S1167;
        }
    }
    uint _S1168 = low_1;
    float _S1169 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_2 - WAVELENGTH_CDF_0[_S1168]) / _S1169), _S1169 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_7)
{
    float _S1170 = clamp_1((wavelength_7 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1171 = (U32_min((uint(_S1170)), (79U)));
    uint _S1172 = 3U * _S1171;
    float3  _S1173 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1172], WAVELENGTH_WEIGHTS_0[_S1172 + 1U], WAVELENGTH_WEIGHTS_0[_S1172 + 2U]);
    float3  _S1174 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1172 + 3U], WAVELENGTH_WEIGHTS_0[_S1172 + 4U], WAVELENGTH_WEIGHTS_0[_S1172 + 5U]);
    return _S1173 + (_S1174 - _S1173) * make_float3 (_S1170 - float(_S1171));
}

__device__ float dispersedIor(float ior_1, float dispersion_1, float wavelength_8)
{
    float _S1175 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1176 = _S1175 * (1.0f / (wavelength_8 * wavelength_8) - 2.89662933349609375f);
    bool _S1177 = dispersion_1 > 0.0f;
    float _S1178 = _slang_select(_S1177, _S1176,0.0f);
    return ior_1 + _S1178;
}

__device__ float2  vertexEta(BSDFMaterial material_17, float n_dot_v_0)
{
    bool _S1179 = n_dot_v_0 < 0.0f;
    float _S1180 = _slang_select(_S1179, material_17.ior,1.0f);
    float _S1181 = _slang_select(_S1179, 1.0f,material_17.ior);
    return make_float2 (_S1180, _S1181);
}

__device__ float2  wavelengthEta(BSDFMaterial material_18, float n_dot_v_1, float wavelength_9)
{
    BSDFMaterial refractive_0 = material_18;
    float _S1182 = dispersedIor(material_18.ior, material_18.dispersion, wavelength_9);
    bool _S1183 = wavelength_9 > 0.0f;
    float _S1184 = _slang_select(_S1183, _S1182,material_18.ior);
    (&refractive_0)->ior = _S1184;
    float2  _S1185 = vertexEta(refractive_0, n_dot_v_1);
    return _S1185;
}

__device__ bool neeDecision(BSDFMaterial material_19, float n_dot_v_2, float eta_i_5, float eta_o_5)
{
    float _S1186 = fresnel((F32_abs((n_dot_v_2))), eta_i_5, eta_o_5);
    float3  _S1187 = mix_0(make_float3 (_S1186), material_19.albedo, material_19.metallic);
    float _S1188 = rgb_to_greyscale(_S1187);
    float _S1189 = (F32_max(((1.0f - _S1188) * (1.0f - material_19.metallic) * (1.0f - material_19.transmission)), (0.0f)));
    bool _S1190 = _S1189 > 0.03999999910593033f;
    bool _S1191;
    if(_S1190)
    {
        _S1191 = true;
    }
    else
    {
        _S1191 = (material_19.roughness) > 0.20000000298023224f;
    }
    return _S1191;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_20)
{
    float _S1192 = rgb_to_greyscale(material_20->translucent);
    return _S1192 > 0.0f;
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
    MediumSides _S1193;
    (&_S1193)->behind = *behind_0;
    (&_S1193)->front = *front_0;
    (&_S1193)->fillings = fillings_1;
    (&_S1193)->face = face_1;
    return _S1193;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_10, FKMedium * medium_0, uint filling_0, float3  dir_13, FKMedium * outside_0)
{
    float3  _S1194 = surface_10->geometry_n;
    MediumSides _S1195 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_10->geometry_n);
    MediumSides sides_0 = _S1195;
    bool _S1196 = surface_10->encloses;
    if(_S1196)
    {
        (&sides_0)->behind = surface_10->volume;
        *&((&(&sides_0)->fillings)->x) = surface_10->fills;
        bool _S1197 = (dot_0(dir_13, _S1194)) > 0.0f;
        if(_S1197)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_11, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_14, uint depth_3, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1198 = surface_11->geometry_n;
    ShadowContext _S1199 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_11->geometry_n, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1200 = surface_11->encloses;
    ShadowContext context_4;
    if(_S1200)
    {
        FKSurface faced_1 = *surface_11;
        float3  _S1201 = - _S1198;
        float3  _S1202 = _slang_select(turned_0, _S1201,_S1198);
        (&faced_1)->geometry_n = _S1202;
        FKMedium _S1203 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1204 = faced_1;
        FKMedium _S1205 = _S1203;
        MediumSides _S1206 = mediumSides_0(&_S1204, &_S1205, filling_1, dir_14, outside_1);
        ShadowContext _S1207 = ShadowContext_x24init_0(_S1206.behind.extinction, _S1206.front.extinction, _S1206.fillings, _S1198, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1208 = _S1206.fillings;
            ShadowContext _S1209 = ShadowContext_x24init_0(_S1206.front.extinction, _S1206.behind.extinction, uint2 {_S1208.y, _S1208.x}, _S1198, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1209;
        }
        else
        {
            context_4 = _S1207;
        }
    }
    else
    {
        context_4 = _S1199;
    }
    return context_4;
}

static __device__ bool any_1(bool3  x_25)
{
    bool result_14 = false;
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
        if(result_14)
        {
            result_14 = true;
        }
        else
        {
            result_14 = (bool((_slang_vector_get_element(x_25, i_25))));
        }
        i_25 = i_25 + int(1);
    }
    return result_14;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_3, BSDFMaterial * material_21, float eta_i_6, float eta_o_6, bool competing_1, uint random_state_13)
{
    float3  _S1210 = light_2->dir;
    bool _S1211 = (dot_0(geometry_n_3, - in_dir_8) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_4;
    float3  _S1212 = BSDF(in_dir_8, _S1210, smooth_n_5, *material_21, eta_i_6, eta_o_6, _S1211, random_state_13, &throughputs_1, &pdfs_4);
    bool _S1213 = !competing_1;
    bool _S1214;
    if(_S1213)
    {
        _S1214 = true;
    }
    else
    {
        _S1214 = (light_2->density) == 0.0f;
    }
    if(_S1214)
    {
        return _S1212 * light_2->radiance;
    }
    float3  _S1215 = make_float3 (0.0f);
    uint i_26 = 0U;
    float3  weighted_0 = _S1215;
    for(;;)
    {
        if(i_26 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1216 = (pdfs_4[i_26]) > 0.0f;
        if(_S1216)
        {
            float _S1217 = light_2->density;
            float _S1218 = pdfs_4[i_26] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_26] * make_float3 (pdfs_4[i_26]) / make_float3 (_S1217 * (1.0f + _S1218 * _S1218));
            weighted_0 = weighted_1;
        }
        uint i_27 = i_26 + 1U;
        i_26 = i_27;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_2, uint random_state_14, bool refracted_3, uint lobe_4, float pdf_7)
{
    SampleBSDF _S1219;
    (&_S1219)->unit_direction = unit_direction_1;
    (&_S1219)->throughput = throughput_2;
    (&_S1219)->random_state = random_state_14;
    (&_S1219)->refracted = refracted_3;
    (&_S1219)->lobe = lobe_4;
    (&_S1219)->pdf = pdf_7;
    return _S1219;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  v_9, float3  n_i_13, float n_i_dot_v_3, BSDFMaterial material_22, Weights w_14, uint random_state_15)
{
    float3  _S1220 = make_float3 (1.0f);
    SampleBSDF _S1221 = SampleBSDF_x24init_0(_S1220, _S1220, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1221;
    Random _S1222 = pcg(random_state_15);
    Random _S1223 = pcg(_S1222.state);
    (&sample_1)->random_state = _S1223.state;
    float _S1224 = _S1222.value;
    float _S1225 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1224 * _S1224))))));
    float _S1226 = 6.28318548202514648f * _S1223.value;
    float3  _S1227 = tangentToWorld(make_float3 (_S1225 * (F32_cos((_S1226))), _S1222.value, _S1225 * (F32_sin((_S1226)))), n_i_13);
    (&sample_1)->unit_direction = _S1227;
    (&sample_1)->lobe = 4U;
    float3  _S1228 = sheenVelvetBSDF((&sample_1)->unit_direction, v_9, n_i_13, material_22, w_14);
    (&sample_1)->throughput = _S1228;
    float _S1229 = sheenVelvetPDF(_S1222.value, n_i_dot_v_3, w_14);
    (&sample_1)->pdf = _S1229;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1230 = (F32_sqrt((random_1_0)));
    float _S1231 = 6.28318548202514648f * random_2_0;
    float _S1232 = _S1230 * (F32_cos((_S1231)));
    float _S1233 = _S1230 * (F32_sin((_S1231)));
    float _S1234 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1232 * _S1232 - _S1233 * _S1233))))));
    return make_float3 (_S1232, _S1234, _S1233);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_14, float n_i_dot_v_4, BSDFMaterial material_23, Weights w_15, uint random_state_16)
{
    float3  _S1235 = make_float3 (1.0f);
    SampleBSDF _S1236 = SampleBSDF_x24init_0(_S1235, _S1235, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1236;
    Random _S1237 = pcg(random_state_16);
    Random _S1238 = pcg(_S1237.state);
    (&sample_2)->random_state = _S1238.state;
    float3  _S1239 = sampleCosWeightedHemisphere(_S1237.value, _S1238.value);
    float _S1240 = translucentShare(material_23);
    bool _S1241 = u_3 < (w_15.p_diffuse * _S1240);
    float _S1242 = _S1239.y;
    float _S1243 = - _S1242;
    float _S1244 = _slang_select(_S1241, _S1243,_S1242);
    float3  _S1245 = tangentToWorld(make_float3 (_S1239.x, _S1244, _S1239.z), n_i_14);
    (&sample_2)->unit_direction = _S1245;
    (&sample_2)->refracted = _S1241;
    (&sample_2)->lobe = 0U;
    float3  _S1246 = diffuseBSDF((&sample_2)->unit_direction, n_i_14, material_23, w_15);
    (&sample_2)->throughput = _S1246;
    float _S1247 = diffusePDF(_S1244, n_i_dot_v_4, material_23, w_15);
    (&sample_2)->pdf = _S1247;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_15, ToonProfile profile_3, Weights w_16, uint random_state_17)
{
    float3  _S1248 = make_float3 (1.0f);
    Random _S1249 = pcg(random_state_17);
    Random _S1250 = pcg(_S1249.state);
    float _S1251 = _S1249.value * profile_3.norm / 6.28318548202514648f;
    float _S1252 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1251)))), (1.0f))))));
    float _S1253 = (F32_acos((clamp_1(1.0f - _S1251, -1.0f, 1.0f))));
    float _S1254 = _slang_select(profile_3.glossy, _S1253,_S1252);
    float _S1255 = (profile_3.a + profile_3.b) / 2.0f;
    bool _S1256 = _S1254 < (profile_3.a);
    float _S1257 = _slang_select(_S1256, _S1254,_S1255);
    float t_23 = _S1257;
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
        float _S1258 = toonP(t_23, profile_3.a, profile_3.s);
        float _S1259 = _S1258 * (F32_sin((t_23)));
        float _S1260 = (F32_cos((t_23)));
        float _S1261 = _slang_select(profile_3.glossy, 1.0f,_S1260);
        float _S1262 = _S1259 * _S1261;
        float _S1263 = toonIntegral(t_23, profile_3.a, profile_3.s, profile_3.glossy);
        float _S1264 = (_S1263 - _S1251) / _S1262;
        bool _S1265 = _S1262 > 0.0f;
        float _S1266 = _slang_select(_S1265, _S1264,0.0f);
        float _S1267 = clamp_1(t_23 - _S1266, 0.0f, profile_3.b);
        int k_1 = k_0 + int(1);
        t_23 = _S1267;
        k_0 = k_1;
    }
    float _S1268 = 6.28318548202514648f * _S1250.value;
    float _S1269 = (F32_sin((t_23)));
    float3  _S1270 = tangentToWorld(make_float3 (_S1269 * (F32_cos((_S1268))), (F32_cos((t_23))), _S1269 * (F32_sin((_S1268)))), profile_3.axis);
    float3  _S1271 = toonBSDF(_S1270, n_i_15, profile_3, w_16);
    bool _S1272 = (dot_0(n_i_15, _S1270)) < 0.0f;
    float _S1273 = toonPDF(_S1270, n_i_15, profile_3, w_16);
    return SampleBSDF_x24init_0(_S1270, _S1271, _S1250.state, _S1272, 6U, _S1273);
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_16, float alpha_8, AnisotropicFrame frame_6, BSDFMaterial material_24, Weights w_17, float pdf_h_3, float eta_i_7, float eta_o_7, uint random_state_18)
{
    float3  _S1274 = make_float3 (1.0f);
    SampleBSDF _S1275 = SampleBSDF_x24init_0(_S1274, _S1274, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1275;
    (&sample_3)->unit_direction = w_17.refracted;
    (&sample_3)->random_state = random_state_18;
    (&sample_3)->refracted = true;
    (&sample_3)->lobe = 1U;
    float3  _S1276 = refractBSDF((&sample_3)->unit_direction, n_i_16, alpha_8, frame_6, material_24, w_17);
    (&sample_3)->throughput = _S1276;
    float _S1277 = refractPDF(dot_0((&sample_3)->unit_direction, ggx_n_3), pdf_h_3, w_17, eta_i_7, eta_o_7);
    (&sample_3)->pdf = _S1277;
    return sample_3;
}

static __device__ float3  reflect_0(float3  i_28, float3  n_9)
{
    return i_28 - make_float3 (2.0f * dot_0(n_9, i_28)) * n_9;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_17, float alpha_9, AnisotropicFrame frame_7, Weights w_18, float pdf_h_4, uint random_state_19)
{
    float3  _S1278 = make_float3 (1.0f);
    SampleBSDF _S1279 = SampleBSDF_x24init_0(_S1278, _S1278, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1279;
    float3  _S1280 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S1281 = ((((_S1280)) * make_float3(rnorm3df(((_S1280)).x, ((_S1280)).y, ((_S1280)).z))));
    (&sample_4)->unit_direction = _S1281;
    (&sample_4)->random_state = random_state_19;
    (&sample_4)->lobe = 2U;
    float3  _S1282 = reflectBSDF((&sample_4)->unit_direction, n_i_17, alpha_9, frame_7, w_18);
    (&sample_4)->throughput = _S1282;
    float _S1283 = reflectPDF(pdf_h_4, w_18);
    (&sample_4)->pdf = _S1283;
    return sample_4;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_10, BSDFMaterial material_25, float eta_i_8, float eta_o_8, uint random_init_0, float2  screen_space_0)
{
    uint random_state_20 = random_init_0;
    float3  _S1284 = negate_0(in_dir_10);
    float _S1285 = dot_0(n_10, _S1284);
    float _S1286 = sign_0(_S1285);
    float3  n_i_18 = n_10 * make_float3 (_S1286);
    float _S1287 = (F32_abs((_S1285)));
    float _S1288 = material_25.roughness;
    float _S1289 = _S1288 * _S1288;
    AnisotropicFrame _S1290 = anisotropicFrame(material_25, n_i_18);
    SheenProfile _S1291 = sheenProfile(_S1284, n_i_18, material_25);
    float3  _S1292 = sampleHalfVector(_S1284, n_i_18, _S1289, _S1290, &random_state_20);
    Weights _S1293 = lobeWeights(in_dir_10, _S1284, n_i_18, _S1292, _S1290, _S1291, material_25, eta_i_8, eta_o_8);
    Random _S1294 = pcg(random_state_20);
    random_state_20 = _S1294.state;
    bool _S1295 = (_S1294.value) < (_S1293.p_sheen_velvet);
    if(_S1295)
    {
        SampleBSDF _S1296 = sheenVelvetSample(_S1284, n_i_18, _S1287, material_25, _S1293, random_state_20);
        return _S1296;
    }
    float _S1297 = _S1294.value - _S1293.p_sheen_velvet;
    bool _S1298 = _S1297 < (_S1293.p_diffuse);
    if(_S1298)
    {
        SampleBSDF _S1299 = diffuseSample(_S1297, n_i_18, _S1287, material_25, _S1293, random_state_20);
        return _S1299;
    }
    bool _S1300 = _S1297 < (_S1293.p_diffuse + _S1293.p_toon);
    if(_S1300)
    {
        ToonProfile _S1301 = toonProfile(_S1284, n_i_18, material_25);
        SampleBSDF _S1302 = toonSample(n_i_18, _S1301, _S1293, random_state_20);
        return _S1302;
    }
    float _S1303 = vndfPDF(_S1284, _S1292, n_i_18, _S1287, _S1289, _S1290, _S1293.v_dot_h);
    bool _S1304 = (_S1297 - _S1293.p_toon) < (_S1293.p_diffuse + _S1293.p_refract);
    if(_S1304)
    {
        SampleBSDF _S1305 = refractSample(_S1292, n_i_18, _S1289, _S1290, material_25, _S1293, _S1303, eta_i_8, eta_o_8, random_state_20);
        return _S1305;
    }
    SampleBSDF _S1306 = reflectSample(in_dir_10, _S1292, n_i_18, _S1289, _S1290, _S1293, _S1303, random_state_20);
    return _S1306;
}

static __device__ bool boundsVolume_0(FKSurface * surface_12)
{
    return surface_12->encloses;
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    float spread_1;
    bool turned_1;
    bool is_inside_6;
    bool viewed_0;
    bool _S1307;
    bool _S1308;
    float density_3;
    float wavelength_10;
    float width_3;
    float sky_pdf_1;
    float threshold_0;
    uint b_7;
    uint layer_0;
    float3  throughput_3;
    float3  spectral_weight_1;
    TreeSample light_3;
    int _S1309;
    Shift ended_0;
    float density_4;
    float spread_2;
    float width_4;
    float sky_pdf_2;
    float spread_3;
    float width_5;
    uint b_8;
    float3  _S1310 = make_float3 (0.0f);
    Shift _S1311 = Shift_x24init_0(_S1310, 0.0f);
    uint _S1312 = r_9->path;
    uint _S1313 = extractBits_0(r_9->path, 0U, 5U);
    uint _S1314 = extractBits_0(_S1312, 5U, 5U);
    uint _S1315 = extractBits_0(_S1312, 10U, 2U);
    uint _S1316 = extractBits_0(_S1312, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1317 = _S1316 >= 3U;
        uint _S1318 = _slang_select(_S1317, 1U,0U);
        uint _S1319 = _S1313 + _S1318;
        uint _S1320 = (fcptMaxBounces());
        passes_0 = _S1319 > _S1320;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1311;
    }
    uint _S1321 = _S1314 - 1U;
    bool _S1322 = _S1316 == 3U;
    uint _S1323 = _slang_select(_S1322, 1U,0U);
    uint _S1324 = _S1313 + _S1323;
    bool _S1325 = _S1315 == 0U;
    uint _S1326 = _slang_select(_S1325, _S1324,_S1321);
    FKHit _S1327 = (fcptReservoirHit((*r_9)));
    float3  _S1328 = dom_7->x0;
    float3  _S1329 = dom_7->x1 - dom_7->x0;
    float3  _S1330 = ((((_S1329)) * make_float3(rnorm3df(((_S1329)).x, ((_S1329)).y, ((_S1329)).z))));
    FKRay _S1331 = Ray_x24init_0(dom_7->x1, _S1330);
    FKRay ray_3 = _S1331;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1310;
    float3  throughput_4 = make_float3 (1.0f);
    float3  weight_2 = throughput_4;
    float3  glowed_0 = _S1310;
    float3  extinction_in_0 = _S1310;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1332 = dom_7->spread;
    float _S1333 = dom_7->width;
    float _S1334 = length_0(_S1329);
    NEEVertex _S1335 = NEEVertex_x24init_0(true, 0.0f, _S1310, _S1310, _S1310);
    NEEVertex nee_vertex_1 = _S1335;
    Vertex _S1336 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_1 = _S1336;
    Reservoir _S1337 = (Reservoir{});
    Reservoir chain_1 = _S1337;
    uint _S1338 = r_9->seed;
    (&chain_1)->seed = r_9->seed;
    uint _S1339 = extractBits_0(_S1312, 24U, 8U);
    uint _S1340 = insertBits_0(0U, _S1339, 24U, 8U);
    (&chain_1)->path = _S1340;
    (&ray_3)->origin = _S1328;
    (&hit_4)->distance = _S1334;
    FKMedium _S1341 = (fcptCameraMedium(((&ray_3)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1342 = filling_2;
    bool _S1343 = (fcptVaryingUsed());
    uint _S1344 = _slang_select(_S1343, _S1342,4294967295U);
    filling_2 = _S1344;
    scatter_in_0 = _S1341.scatter;
    extinction_in_0 = _S1341.extinction;
    g_in_0 = _S1341.g;
    Reservoir _S1345 = chain_1;
    uint _S1346 = filling_2;
    for(;;)
    {
        bool _S1347 = (fcptVaryingUsed());
        if(_S1347)
        {
            passes_0 = _S1346 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1348 = (fcptMajorant((_S1346)));
            spread_1 = _S1348;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1326;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1315 == 1U;
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
            ended_0 = _S1311;
            sky_pdf_1 = 0.0f;
            spread_1 = _S1332;
            width_3 = _S1333;
            density_3 = 1.0f;
            throughput_3 = throughput_4;
            b_7 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1349 = (&prev_1)->rough;
        if(_S1349)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_1)->rough = turned_1;
        uint _S1350 = stream(_S1338, 384U);
        uint tracking_0 = _S1350;
        weight_2 = throughput_4;
        glowed_0 = _S1310;
        b_7 = 4294967295U;
        throughput_3 = throughput_4;
        density_3 = 1.0f;
        wavelength_10 = _S1332;
        width_3 = _S1333;
        sky_pdf_1 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1309 = int(1);
                break;
            }
            uint _S1351 = b_7 + 320U;
            bool _S1352 = b_7 == 4294967295U;
            uint _S1353 = _slang_select(_S1352, 384U,_S1351);
            uint _S1354 = stream(_S1338, _S1353);
            Random _S1355 = pcg(_S1354);
            float _S1356 = - (F32_log((1.0f - _S1355.value))) / spread_1;
            if(passes_0)
            {
                float3  _S1357 = (&ray_3)->origin;
                float3  _S1358 = (&ray_3)->unit_direction;
                float _S1359 = (&hit_4)->distance;
                uint _S1360 = _slang_select(_S1352, 0U,b_7);
                uint _S1361 = (&prev_1)->lobe;
                uint _S1362 = _slang_select(_S1352, 3U,_S1361);
                float _S1363 = (fcptTrackMedium((_S1346), (_S1357), (_S1358), (_S1359), (&tracking_0), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1360), (_S1362), (_S1352)));
                threshold_0 = _S1363;
            }
            else
            {
                threshold_0 = _S1356;
            }
            bool _S1364 = !(threshold_0 < ((&hit_4)->distance));
            if(_S1364)
            {
                _S1309 = int(1);
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
                float3  _S1365 = pathColor(throughput_3 * glowed_0, throughput_4, 0.0f);
                float3  _S1366 = _S1365 / make_float3 (density_3);
                float3  _S1367 = sel_8->glow + _S1366;
                sel_8->glow = _S1367;
            }
            else
            {
            }
            glowed_0 = _S1310;
            uint b_9 = b_7 + 1U;
            float3  _S1368 = (&ray_3)->origin + make_float3 (threshold_0) * (&ray_3)->unit_direction;
            (&ray_3)->origin = _S1368;
            float3  _S1369 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, threshold_0, true);
            float3  _S1370 = weight_2;
            float _S1371 = upsample(weight_2, 0.0f);
            float3  _S1372 = make_float3 (_S1371);
            float3  _S1373 = _slang_select(false, _S1372,_S1370);
            float3  _S1374 = _slang_select(passes_0, _S1373,_S1369);
            float3  throughput_5 = throughput_3 * _S1374;
            uint _S1375 = stream(_S1338, b_9 + 320U);
            tracking_0 = _S1375;
            weight_2 = throughput_4;
            float width_6 = width_3 + wavelength_10 * threshold_0;
            float _S1376 = wavelength_10 + 3.14159274101257324f;
            bool _S1377 = !replay_2;
            if(_S1377)
            {
                is_inside_6 = true;
            }
            else
            {
                bool _S1378 = b_9 == _S1326;
                if(_S1378)
                {
                    is_inside_6 = !passes_0;
                }
                else
                {
                    is_inside_6 = false;
                }
            }
            TreeSample _S1379 = TreeSample_x24init_0(_S1310, _S1310, 0.0f, 0U);
            if(is_inside_6)
            {
                float3  _S1380 = (&ray_3)->origin;
                float3  _S1381 = (&ray_3)->unit_direction;
                float3  _S1382 = (&ray_3)->unit_direction;
                uint _S1383 = stream(_S1338, b_9 + 64U);
                float3  _S1384 = extinction_in_0;
                float3  _S1385 = extinction_in_0;
                uint2  _S1386 = make_uint2 (_S1346);
                float3  _S1387 = (&ray_3)->unit_direction;
                uint _S1388 = arrivalLobe_0(b_9, (&prev_1)->lobe);
                FKHit _S1389 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1390 = _S1389;
                ShadowContext _S1391 = ShadowContext_x24init_0(_S1384, _S1385, _S1386, _S1387, b_9, _S1388, false, threshold_0, width_6, &_S1390, false);
                ShadowContext _S1392 = _S1391;
                TreeSample _S1393 = sampleLightTree_0(_S1380, _S1381, _S1382, 0.0f, true, _S1383, &_S1392);
                light_3 = _S1393;
            }
            else
            {
                light_3 = _S1379;
            }
            float _S1394 = phaseHG_0(g_in_0, dot_0((&ray_3)->unit_direction, light_3.dir));
            uint _S1395 = (fcptMaxBounces());
            bool _S1396 = b_9 < _S1395;
            if(_S1396)
            {
                viewed_0 = (light_3.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S1397 = _slang_select(viewed_0, _S1394,0.0f);
            float3  _S1398 = throughput_5 * light_3.radiance;
            float _S1399 = powerHeuristic(light_3.density, _S1397);
            float3  _S1400 = pathColor(_S1398 * make_float3 (_S1394 * _S1399), throughput_4, 0.0f);
            float3  _S1401 = _slang_select(is_inside_6, _S1400,_S1310);
            if(replay_2)
            {
                _S1307 = b_9 == _S1326;
            }
            else
            {
                _S1307 = false;
            }
            if(_S1307)
            {
                bool _S1402 = _S1315 == 2U;
                if(_S1402)
                {
                    float _S1403 = resamplingTarget(_S1401);
                    passes_0 = _S1403 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1404 = Shift_x24init_0(_S1401, 1.0f);
                    _S1309 = int(0);
                    ended_0 = _S1404;
                    spread_1 = _S1376;
                    threshold_0 = width_6;
                    spectral_weight_1 = throughput_5;
                    layer_0 = b_9;
                    break;
                }
                _S1309 = int(0);
                ended_0 = _S1311;
                spread_1 = _S1376;
                threshold_0 = width_6;
                spectral_weight_1 = throughput_5;
                layer_0 = b_9;
                break;
            }
            if(_S1377)
            {
                Reservoir candidate_4 = _S1345;
                uint _S1405 = extractBits_0(_S1345.path, 24U, 8U);
                uint _S1406 = insertBits_0(0U, _S1405, 24U, 8U);
                uint _S1407 = extractBits_0(_S1345.path, 10U, 2U);
                bool _S1408 = _S1407 == 1U;
                if(_S1408)
                {
                    float3  _S1409 = safeDivide(_S1401, _S1310);
                    (&candidate_4)->radiance = _S1409;
                }
                else
                {
                    uint _S1410 = insertBits_0(_S1406, b_9 + 1U, 5U, 5U);
                    uint _S1411 = insertBits_0(_S1410, 2U, 10U, 2U);
                    (&candidate_4)->path = _S1411;
                }
                Reservoir _S1412 = withEnd(candidate_4, 0U, b_9, _S1401);
                offer(sel_8, _S1412, _S1401 * make_float3 (scale_4) / make_float3 (density_3));
                float _S1413 = survivalProbability(abs_0(throughput_5), density_3);
                uint _S1414 = stream(_S1338, b_9 + 128U);
                Random _S1415 = pcg(_S1414);
                bool _S1416 = _S1413 < (_S1415.value);
                if(_S1416)
                {
                    _S1308 = true;
                }
                else
                {
                    uint _S1417 = (fcptMaxBounces());
                    _S1308 = b_9 >= _S1417;
                }
                if(_S1308)
                {
                    _S1309 = int(0);
                    ended_0 = _S1311;
                    spread_1 = _S1376;
                    threshold_0 = width_6;
                    spectral_weight_1 = throughput_5;
                    layer_0 = b_9;
                    break;
                }
                float _S1418 = density_3 * _S1413;
                density_3 = _S1418;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1419 = stream(_S1338, b_9);
            float3  _S1420 = samplePhase_0(g_in_0, (&ray_3)->unit_direction, _S1419, &phase_pdf_0);
            (&ray_3)->unit_direction = _S1420;
            NEEVertex _S1421 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_3)->origin, _S1310, (&ray_3)->origin);
            nee_vertex_1 = _S1421;
            Vertex _S1422 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_1 = _S1422;
            float _S1423 = (&prev_1)->pdf;
            FKRay _S1424 = ray_3;
            FKHit _S1425 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1426 = (fcptTraverseInstanceBVH((_S1424), (true), (4.294967296e+09f), (false), (_S1425), (false)));
            hit_4 = _S1426;
            b_7 = b_9;
            throughput_3 = throughput_5;
            wavelength_10 = _S1376;
            width_3 = width_6;
            sky_pdf_1 = _S1423;
        }
        if(_S1309 != int(1))
        {
            width_3 = threshold_0;
            throughput_3 = spectral_weight_1;
            b_7 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1311;
        spread_1 = wavelength_10;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1427 = b_7 == 4294967295U;
    bool _S1428 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1428)
    {
        Reservoir _S1429 = chain_1;
        FKRay _S1430 = ray_3;
        Vertex _S1431 = prev_1;
        NEEVertex _S1432 = nee_vertex_1;
        Shift _S1433 = escape_0(r_9, replay_2, _S1326, _S1315, _S1313, _S1316, scale_4, _S1340, &_S1429, _S1310, b_7, &_S1430, throughput_3, density_3, &_S1431, &_S1432, sky_pdf_1, throughput_4, 0.0f, sel_8);
        return _S1433;
    }
    float3  _S1434 = (&ray_3)->origin + make_float3 ((&hit_4)->distance) * (&ray_3)->unit_direction;
    (&ray_3)->origin = _S1434;
    bool _S1435 = (fcptVaryingUsed());
    if(_S1435)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1436 = !replay_2;
        if(_S1436)
        {
            float3  _S1437 = pathColor(throughput_3 * glowed_0, throughput_4, 0.0f);
            float3  _S1438 = _S1437 / make_float3 (density_3);
            float3  _S1439 = sel_8->glow + _S1438;
            sel_8->glow = _S1439;
        }
        float3  _S1440 = throughput_3 * weight_2;
        throughput_3 = _S1440;
    }
    else
    {
        float3  _S1441 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1442 = throughput_3 * _S1441;
        throughput_3 = _S1442;
    }
    float _S1443 = width_3 + spread_1 * (&hit_4)->distance;
    uint _S1444 = b_7 + 1U;
    b_7 = _S1444;
    layer_0 = 0U;
    width_3 = _S1443;
    passes_0 = false;
    wavelength_10 = 0.0f;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_6 = false;
    spectral_weight_1 = throughput_4;
    float3  chain_throughput_1 = _S1310;
    float3  reconnection_0 = _S1310;
    viewed_0 = _S1427;
    for(;;)
    {
        bool _S1445 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1307 = _S1315 == 1U;
        }
        else
        {
            _S1307 = false;
        }
        if(_S1307)
        {
            _S1308 = b_7 == _S1314;
        }
        else
        {
            _S1308 = false;
        }
        bool _S1446;
        if(_S1308)
        {
            bool _S1447 = ((&hit_4)->instance_index) != (_S1327.instance_index);
            if(_S1447)
            {
                _S1446 = true;
            }
            else
            {
                _S1446 = ((&hit_4)->triangle_index) != (_S1327.triangle_index);
            }
        }
        else
        {
            _S1446 = false;
        }
        if(_S1446)
        {
            return _S1311;
        }
        FKMedium _S1448 = Medium_x24init_0(_S1310, _S1310, 0.0f);
        BSDFMaterial _S1449 = Material_x24init_0(_S1310, _S1310, 0.0f, 0.0f, 0.0f, 0.0f, _S1310, throughput_4, 1.0f, _S1310, _S1310, 0.5f, 0.0f, 0.0f, _S1310, 0.0f, _S1310, 0.0f);
        FKMedium _S1450 = _S1448;
        FKSurface _S1451 = Surface_x24init_0(_S1310, _S1310, 0.0f, &_S1449, false, 0U, 1.0f, false, &_S1450, 4294967295U, _S1310);
        bool _S1452 = !_S1445;
        bool scatter_2;
        bool is_inside_7;
        float geometry_density_0;
        float3  throughput_6;
        FKSurface surface_13;
        if(_S1452)
        {
            uint _S1453 = stream(_S1338, b_7);
            uint _S1454 = arrivalLobe_0(b_7, (&prev_1)->lobe);
            FKSurface _S1455 = (fcptSurfaceAtPath((hit_4), ((&ray_3)->origin), (_S1453), (width_3), (layer_0), (b_7), (_S1454), ((&ray_3)->unit_direction)));
            bool _S1456 = !passes_0;
            FKSurface _S1457 = _S1455;
            FKSurface _S1458 = emitting_0(&_S1457, _S1456);
            uint _S1459 = stream(_S1338, b_7 + 256U);
            Random _S1460 = pcg(_S1459);
            FKSurface _S1461 = _S1458;
            FKSurface _S1462 = uncovered_0(&_S1461, _S1460.value);
            float _S1463 = facingSign(_S1462.material.transmission, _S1462.geometry_n, (&ray_3)->unit_direction);
            bool _S1464 = _S1463 < 0.0f;
            bool _S1465 = (_S1462.material.transmission) > 0.0f;
            if(_S1465)
            {
                bool _S1466 = arrivesBehind_0((&ray_3)->unit_direction, _S1462.geometry_n);
                scatter_2 = _S1466;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1467 = _S1462;
            FKSurface _S1468 = facingRay_0(&_S1467, (&ray_3)->unit_direction);
            if(passes_0)
            {
                bool _S1469 = arrivesBehind_0((&ray_3)->unit_direction, _S1468.geometry_n);
                is_inside_7 = _S1469;
            }
            else
            {
                is_inside_7 = scatter_2;
            }
            if(is_inside_7)
            {
                float _S1470 = (&hit_4)->distance;
                float _S1471 = upsample(_S1468.material.absorption, wavelength_10);
                float3  _S1472 = make_float3 (_S1471);
                bool _S1473 = wavelength_10 > 0.0f;
                float3  _S1474 = _slang_select(_S1473, _S1472,_S1468.material.absorption);
                float3  _S1475 = beerLambert(_S1470, _S1474);
                float3  _S1476 = throughput_3 * _S1475;
                throughput_6 = _S1476;
            }
            else
            {
                throughput_6 = throughput_3;
            }
            bool _S1477 = !_S1468.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S1468.geometry_n, (&ray_3)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1478 = b_7 == _S1444;
            if(_S1478)
            {
                float _S1479 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1479;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S1480 = geometry_density_0;
            scatter_2 = _S1477;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1480;
            surface_13 = _S1468;
            turned_1 = _S1464;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_13 = _S1451;
            throughput_6 = throughput_3;
            is_inside_7 = is_inside_6;
        }
        bool _S1481;
        if(scatter_2)
        {
            _S1481 = (&prev_1)->rough;
        }
        else
        {
            _S1481 = false;
        }
        bool _S1482;
        if(_S1481)
        {
            _S1482 = ((&prev_1)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1482 = false;
        }
        FKSurface _S1483 = surface_13;
        float _S1484 = dot_0(surface_13.smooth_n, - (&ray_3)->unit_direction);
        bool _S1485 = (fcptDispersionUsed());
        bool _S1486;
        if(_S1485)
        {
            _S1486 = wavelength_10 == 0.0f;
        }
        else
        {
            _S1486 = false;
        }
        bool _S1487;
        if(_S1486)
        {
            _S1487 = scatter_2;
        }
        else
        {
            _S1487 = false;
        }
        bool _S1488;
        if(_S1487)
        {
            bool _S1489 = dispersive(surface_13.material);
            _S1488 = _S1489;
        }
        else
        {
            _S1488 = false;
        }
        float3  throughput_7;
        if(_S1488)
        {
            uint _S1490 = stream(_S1338, 512U);
            Random _S1491 = pcg(_S1490);
            uint _S1492 = extractBits_0(_S1312, 25U, 7U);
            float _S1493 = (float(_S1492) + _S1491.value) / 128.0f;
            uint _S1494 = extractBits_0(_S1312, 24U, 1U);
            bool _S1495 = _S1494 == 1U;
            float _S1496 = _slang_select(_S1495, _S1493,_S1491.value);
            float2  _S1497 = sampleWavelength(_S1496);
            float wavelength_11 = _S1497.x;
            float3  _S1498 = wavelengthWeights(wavelength_11);
            float3  _S1499 = _S1498 / make_float3 (_S1497.y);
            float _S1500 = upsample(throughput_6, wavelength_11);
            float3  _S1501 = make_float3 (_S1500);
            float _S1502 = upsample(scatter_in_0, wavelength_11);
            float3  _S1503 = make_float3 (_S1502);
            scatter_in_0 = _S1503;
            float _S1504 = upsample(extinction_in_0, wavelength_11);
            float3  _S1505 = make_float3 (_S1504);
            extinction_in_0 = _S1505;
            wavelength_10 = wavelength_11;
            throughput_7 = _S1501;
            spectral_weight_1 = _S1499;
        }
        else
        {
            throughput_7 = throughput_6;
        }
        BSDFMaterial _S1506 = pathMaterial(surface_13.material, wavelength_10);
        float2  _S1507 = wavelengthEta(_S1506, _S1484, wavelength_10);
        bool _S1508;
        if(scatter_2)
        {
            uint _S1509 = (fcptMaxBounces());
            bool _S1510 = b_7 >= _S1509;
            if(_S1510)
            {
                _S1508 = true;
            }
            else
            {
                bool _S1511 = neeDecision(_S1506, _S1484, _S1507.x, _S1507.y);
                _S1508 = _S1511;
            }
        }
        else
        {
            _S1508 = false;
        }
        bool _S1512;
        if(passes_0)
        {
            _S1512 = true;
        }
        else
        {
            _S1512 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1512)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1508;
        }
        bool _S1513 = (fcptHairUsed());
        bool _S1514;
        if(_S1513)
        {
            float3  _S1515 = surface_13.hair;
            _S1514 = (dot_0(_S1515, _S1515)) > 0.0f;
        }
        else
        {
            _S1514 = false;
        }
        bool _S1516;
        if(_S1514)
        {
            _S1516 = true;
        }
        else
        {
            BSDFMaterial _S1517 = _S1506;
            bool _S1518 = isTranslucent_0(&_S1517);
            _S1516 = _S1518;
        }
        bool _S1519;
        if(_S1516)
        {
            _S1519 = true;
        }
        else
        {
            bool _S1520 = (_S1506.transmission) > 0.0f;
            if(_S1520)
            {
                uint _S1521 = (fcptLayers((hit_4)));
                _S1519 = _S1521 == 1U;
            }
            else
            {
                _S1519 = false;
            }
        }
        float3  emission_0;
        if(_S1445)
        {
            float3  _S1522 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1522;
        }
        else
        {
            emission_0 = _S1506.emissive;
        }
        bool _S1523 = !replay_2;
        bool _S1524;
        if(_S1523)
        {
            _S1524 = true;
        }
        else
        {
            _S1524 = b_7 >= _S1326;
        }
        bool _S1525;
        if(_S1524)
        {
            float _S1526 = rgb_to_greyscale(emission_0);
            _S1525 = _S1526 > 0.0f;
        }
        else
        {
            _S1525 = false;
        }
        float3  emission_1;
        if(_S1525)
        {
            NEEVertex _S1527 = nee_vertex_1;
            FKHit _S1528 = hit_4;
            float _S1529 = emissionWeight_0(&_S1527, &_S1528, (&ray_3)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1529);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1530;
        if(replay_2)
        {
            _S1530 = _S1315 == 1U;
        }
        else
        {
            _S1530 = false;
        }
        bool _S1531;
        if(_S1530)
        {
            _S1531 = b_7 > _S1314;
        }
        else
        {
            _S1531 = false;
        }
        bool _S1532;
        if(_S1531)
        {
            _S1532 = b_7 == _S1313;
        }
        else
        {
            _S1532 = false;
        }
        bool _S1533;
        if(_S1532)
        {
            bool _S1534 = _S1316 == 1U;
            if(_S1534)
            {
                _S1533 = true;
            }
            else
            {
                _S1533 = _S1316 == 2U;
            }
        }
        else
        {
            _S1533 = false;
        }
        if(_S1533)
        {
            bool _S1535 = _S1445 != (_S1316 == 2U);
            if(_S1535)
            {
                return _S1311;
            }
            float3  _S1536 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_10);
            return Shift_x24init_0(_S1536 / make_float3 (r_9->jac), density_3 / r_9->jac);
        }
        uint _S1537 = extractBits_0((&chain_1)->path, 10U, 2U);
        bool _S1538 = _S1537 == 1U;
        Reservoir here_0 = chain_1;
        uint _S1539 = insertBits_0(_S1340, b_7, 5U, 5U);
        uint _S1540 = insertBits_0(_S1539, 1U, 10U, 2U);
        uint _S1541 = insertBits_0(_S1540, (&prev_1)->lobe, 15U, 3U);
        bool _S1542 = (&prev_1)->inside;
        uint _S1543 = _slang_select(_S1542, 1U,0U);
        uint _S1544 = insertBits_0(_S1541, _S1543, 22U, 1U);
        (&here_0)->path = _S1544;
        uint _S1545 = (&here_0)->path;
        bool _S1546 = wavelength_10 > 0.0f;
        uint _S1547 = _slang_select(_S1546, 1U,0U);
        uint _S1548 = insertBits_0(_S1545, _S1547, 23U, 1U);
        (&here_0)->path = _S1548;
        float _S1549 = (&prev_1)->pdf * geometry_density_0;
        (&here_0)->jac = _S1549;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1550;
        if(replay_2)
        {
            _S1550 = _S1315 == 1U;
        }
        else
        {
            _S1550 = false;
        }
        bool _S1551;
        if(_S1550)
        {
            _S1551 = b_7 == _S1314;
        }
        else
        {
            _S1551 = false;
        }
        bool _S1552 = b_7 == _S1326;
        bool _S1553;
        if(_S1552)
        {
            bool _S1554 = !scatter_2;
            if(_S1554)
            {
                _S1553 = true;
            }
            else
            {
                bool _S1555 = _S1315 != 1U;
                if(_S1555)
                {
                    _S1553 = _S1315 != 3U;
                }
                else
                {
                    _S1553 = false;
                }
            }
        }
        else
        {
            _S1553 = false;
        }
        bool _S1556;
        if(_S1553)
        {
            _S1556 = _S1315 == 2U;
        }
        else
        {
            _S1556 = false;
        }
        bool _S1557;
        if(_S1556)
        {
            _S1557 = !_S1482;
        }
        else
        {
            _S1557 = false;
        }
        bool _S1558;
        if(_S1557)
        {
            _S1558 = _S1316 != 4U;
        }
        else
        {
            _S1558 = false;
        }
        bool _S1559 = _S1314 == _S1313;
        bool _S1560;
        if(_S1559)
        {
            _S1560 = _S1316 == 0U;
        }
        else
        {
            _S1560 = false;
        }
        bool _S1561;
        if(_S1560)
        {
            _S1561 = ((&hit_4)->instance_index) == (_S1327.instance_index);
        }
        else
        {
            _S1561 = false;
        }
        bool _S1562;
        if(_S1561)
        {
            _S1562 = ((&hit_4)->triangle_index) == (_S1327.triangle_index);
        }
        else
        {
            _S1562 = false;
        }
        bool _S1563;
        if(_S1562)
        {
            _S1563 = _S1482;
        }
        else
        {
            _S1563 = false;
        }
        bool _S1564 = _slang_select(_S1551, _S1563,_S1558);
        bool _S1565;
        if(nee_0)
        {
            _S1565 = _slang_select(replay_2, _S1564,scatter_2);
        }
        else
        {
            _S1565 = false;
        }
        TreeSample _S1566 = TreeSample_x24init_0(_S1310, _S1310, 0.0f, 0U);
        uint2  _S1567 = make_uint2 (0U);
        float2  _S1568 = make_float2 (0.0f);
        FKHit _S1569 = Hit_x24init_0(_S1568, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1570 = _S1569;
        ShadowContext _S1571 = ShadowContext_x24init_0(_S1310, _S1310, _S1567, _S1310, 0U, 0U, false, 0.0f, 0.0f, &_S1570, false);
        bool _S1572;
        if(nee_0)
        {
            _S1572 = _S1524;
        }
        else
        {
            _S1572 = false;
        }
        ShadowContext context_5;
        if(_S1572)
        {
            uint _S1573 = arrivalLobe_0(b_7, (&prev_1)->lobe);
            FKMedium _S1574 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1575 = surface_13;
            FKHit _S1576 = hit_4;
            FKMedium _S1577 = _S1574;
            ShadowContext _S1578 = shadowContext_0(&_S1575, turned_1, extinction_in_0, filling_2, (&ray_3)->unit_direction, b_7, _S1573, (&hit_4)->distance, width_3, &_S1576, _S1514, &_S1577);
            context_5 = _S1578;
        }
        else
        {
            context_5 = _S1571;
        }
        float3  throughput_8;
        float3  lit_0;
        if(_S1565)
        {
            float3  _S1579 = (&ray_3)->origin;
            if(_S1514)
            {
                throughput_8 = _S1310;
            }
            else
            {
                throughput_8 = _S1483.smooth_n;
            }
            FKSurface _S1580 = surface_13;
            uint _S1581 = stream(_S1338, b_7 + 64U);
            ShadowContext _S1582 = context_5;
            TreeSample _S1583 = sampleLightTree_0(_S1579, throughput_8, surface_13.geometry_n, surface_13.geometry_offset, _S1519, _S1581, &_S1582);
            bool _S1584 = any_1((_S1583.radiance) != _S1310);
            if(_S1584)
            {
                if(_S1514)
                {
                    uint _S1585 = (fcptMaxBounces());
                    bool _S1586 = b_7 < _S1585;
                    FKSurface _S1587 = surface_13;
                    TreeSample _S1588 = _S1583;
                    float3  _S1589 = hairLight_0(&_S1587, (&ray_3)->unit_direction, &_S1588, _S1586);
                    lit_0 = _S1589;
                }
                else
                {
                    float _S1590 = _S1507.x;
                    float _S1591 = _S1507.y;
                    uint _S1592 = (fcptMaxBounces());
                    bool _S1593 = b_7 < _S1592;
                    TreeSample _S1594 = _S1583;
                    BSDFMaterial _S1595 = _S1506;
                    float3  _S1596 = lightBSDF_0((&ray_3)->unit_direction, &_S1594, _S1483.smooth_n, _S1580.geometry_n, &_S1595, _S1590, _S1591, _S1593, surface_13.random_state);
                    lit_0 = _S1596;
                }
            }
            else
            {
                lit_0 = _S1310;
            }
            light_3 = _S1583;
        }
        else
        {
            light_3 = _S1566;
            lit_0 = _S1310;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1597;
        bool _S1598;
        float density_5;
        if(_S1551)
        {
            bool _S1599 = !_S1482;
            if(_S1599)
            {
                return _S1311;
            }
            uint _S1600 = extractBits_0(_S1312, 23U, 1U);
            bool _S1601 = _S1546 != (_S1600 == 1U);
            if(_S1601)
            {
                return _S1311;
            }
            float3  throughput_9 = throughput_7 * make_float3 (geometry_density_0);
            float density_6 = density_3 * geometry_density_0;
            if(_S1559)
            {
                viewed_1 = _S1316 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                float3  _S1602 = pathColor(throughput_9 * emission_1, spectral_weight_1, wavelength_10);
                return Shift_x24init_0(_S1602 / make_float3 (r_9->jac), density_6 / r_9->jac);
            }
            if(_S1559)
            {
                refracted_4 = _S1316 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1603 = !nee_0;
                if(_S1603)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1604 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1604 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1311;
                }
                float3  _S1605 = pathColor(throughput_9 * lit_0, spectral_weight_1, wavelength_10);
                return Shift_x24init_0(_S1605 / make_float3 (r_9->jac), density_6 / r_9->jac);
            }
            if(_S1559)
            {
                wrong_side_0 = _S1316 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1606 = !nee_0;
                if(_S1606)
                {
                    return _S1311;
                }
                bool _S1607 = (fcptWorldReadsPath());
                if(_S1607)
                {
                    float _S1608 = environmentPdf_0(r_9->dir);
                    uint _S1609 = b_7 + 1U;
                    FKSurface _S1610 = surface_13;
                    float3  _S1611 = skyColor_0((&ray_3)->unit_direction, r_9->dir, &_S1610, wavelength_10, _S1507, is_inside_7, _S1608, surface_13.random_state, _S1609);
                    float3  _S1612 = pathColor(throughput_9 * (_S1611 * r_9->radiance), spectral_weight_1, wavelength_10);
                    return Shift_x24init_0(_S1612 / make_float3 (r_9->jac), density_6 / r_9->jac);
                }
                float _S1613 = environmentPdf_0(r_9->dir);
                float3  _S1614 = skyBSDF((&ray_3)->unit_direction, r_9->dir, surface_13, _S1506, _S1507, is_inside_7, _S1613, surface_13.random_state);
                float3  _S1615 = pathColor(throughput_9 * _S1614 * r_9->radiance, spectral_weight_1, wavelength_10);
                return Shift_x24init_0(_S1615 / make_float3 (r_9->jac), density_6 / r_9->jac);
            }
            uint _S1616 = extractBits_0(_S1312, 21U, 1U);
            bool _S1617 = nee_0 != (_S1616 == 1U);
            if(_S1617)
            {
                return _S1311;
            }
            throughput_8 = throughput_9;
            density_5 = density_6;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1552;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1618 = !scatter_2;
                if(_S1618)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1619 = _S1315 != 1U;
                    if(_S1619)
                    {
                        refracted_4 = _S1315 != 3U;
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
                bool _S1620 = _S1315 == 2U;
                if(_S1620)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1482;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1316 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1514)
                    {
                        return _S1311;
                    }
                    uint _S1621 = stream(_S1338, b_7 + 448U);
                    FKRay _S1622 = ray_3;
                    FKSurface _S1623 = surface_13;
                    ShadowContext _S1624 = context_5;
                    SkySample _S1625 = sampleSky_0(&_S1622, &_S1623, wavelength_10, _S1507, is_inside_7, _S1621, surface_13.random_state, &_S1624);
                    float3  _S1626 = pathColor(throughput_7 * _S1625.color, spectral_weight_1, wavelength_10);
                    return Shift_x24init_0(_S1626, 1.0f);
                }
                if(_S1620)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1482;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1627 = rgb_to_greyscale(light_3.radiance);
                    bool _S1628 = !(_S1627 > 0.0f);
                    if(_S1628)
                    {
                        return _S1311;
                    }
                    float3  _S1629 = pathColor(throughput_7 * lit_0, spectral_weight_1, wavelength_10);
                    return Shift_x24init_0(_S1629, 1.0f);
                }
                if(_S1325)
                {
                    passes_0 = _S1316 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1445;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1630 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_10);
                    return Shift_x24init_0(_S1630, 1.0f);
                }
                if(_S1325)
                {
                    passes_0 = _S1316 == 1U;
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
                    passes_0 = !_S1482;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1631 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_10);
                    return Shift_x24init_0(_S1631, 1.0f);
                }
                return _S1311;
            }
            else
            {
                if(_S1523)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1632 = b_7 > 0U;
                    if(_S1632)
                    {
                        Reservoir candidate_5 = chain_1;
                        if(_S1538)
                        {
                            float3  _S1633 = safeDivide(throughput_7 * emission_1, chain_throughput_1);
                            (&candidate_5)->radiance = _S1633;
                        }
                        else
                        {
                            if(_S1482)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1634 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_10);
                        Reservoir _S1635 = withEnd(candidate_5, 1U, b_7, _S1634);
                        offer(sel_8, _S1635, _S1634 * make_float3 (scale_4) / make_float3 (density_3));
                    }
                    else
                    {
                        float3  _S1636 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_10);
                        float3  _S1637 = sel_8->glow + _S1636;
                        sel_8->glow = _S1637;
                    }
                    if(nee_0)
                    {
                        float3  _S1638 = pathColor(throughput_7 * lit_0, spectral_weight_1, wavelength_10);
                        Reservoir candidate_6 = chain_1;
                        if(_S1538)
                        {
                            float3  _S1639 = safeDivide(_S1638, chain_throughput_1);
                            (&candidate_6)->radiance = _S1639;
                        }
                        else
                        {
                            if(_S1482)
                            {
                                candidate_6 = here_0;
                                uint _S1640 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1640;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1641 = insertBits_0(_S1340, b_7 + 1U, 5U, 5U);
                                uint _S1642 = insertBits_0(_S1641, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1642;
                            }
                        }
                        Reservoir _S1643 = withEnd(candidate_6, 0U, b_7, _S1638);
                        offer(sel_8, _S1643, _S1638 * make_float3 (scale_4) / make_float3 (density_3));
                    }
                    if(nee_0)
                    {
                        if(_S1514)
                        {
                            _S1597 = false;
                        }
                        else
                        {
                            bool _S1644 = environmentMapped_0();
                            _S1597 = _S1644;
                        }
                    }
                    else
                    {
                        _S1597 = false;
                    }
                    if(_S1597)
                    {
                        uint _S1645 = (fcptMaxBounces());
                        _S1598 = b_7 < _S1645;
                    }
                    else
                    {
                        _S1598 = false;
                    }
                    if(_S1598)
                    {
                        uint _S1646 = stream(_S1338, b_7 + 448U);
                        FKRay _S1647 = ray_3;
                        FKSurface _S1648 = surface_13;
                        ShadowContext _S1649 = context_5;
                        SkySample _S1650 = sampleSky_0(&_S1647, &_S1648, wavelength_10, _S1507, is_inside_7, _S1646, surface_13.random_state, &_S1649);
                        float3  _S1651 = pathColor(throughput_7 * _S1650.color, spectral_weight_1, wavelength_10);
                        Reservoir candidate_7 = chain_1;
                        if(_S1538)
                        {
                            float3  _S1652 = safeDivide(_S1651, chain_throughput_1);
                            (&candidate_7)->radiance = _S1652;
                        }
                        else
                        {
                            if(_S1482)
                            {
                                candidate_7 = here_0;
                                uint _S1653 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1653;
                                (&candidate_7)->dir = _S1650.dir;
                                (&candidate_7)->radiance = _S1650.radiance;
                            }
                            else
                            {
                                uint _S1654 = insertBits_0(_S1340, b_7 + 1U, 5U, 5U);
                                uint _S1655 = insertBits_0(_S1654, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1655;
                            }
                        }
                        Reservoir _S1656 = withEnd(candidate_7, 4U, b_7, _S1651);
                        offer(sel_8, _S1656, _S1651 * make_float3 (scale_4) / make_float3 (density_3));
                    }
                }
            }
            throughput_8 = throughput_7;
            density_5 = density_3;
        }
        bool _S1657;
        bool _S1658;
        bool _S1659;
        bool straight_0;
        bool _S1660;
        bool _S1661;
        bool _S1662;
        bool _S1663;
        bool _S1664;
        bool _S1665;
        bool _S1666;
        bool _S1667;
        bool _S1668;
        bool _S1669;
        bool _S1670;
        bool _S1671;
        bool _S1672;
        float density_7;
        float sky_pdf_3;
        float spread_4;
        uint b_10;
        float3  throughput_10;
        float3  throughput_11;
        float3  throughput_12;
        if(scatter_2)
        {
            if(replay_2)
            {
                viewed_1 = _S1552;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1673 = extractBits_0(_S1312, 15U, 3U);
            uint _S1674 = extractBits_0(_S1312, 18U, 3U);
            uint _S1675 = _slang_select(_S1551, _S1674,_S1673);
            float3  _S1676 = r_9->dir;
            bool refracted_5 = _S1675 == 1U;
            SampleBSDF _S1677 = SampleBSDF_x24init_0(_S1310, _S1310, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1677;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1678 = extractBits_0(_S1312, 22U, 1U);
                bool _S1679 = is_inside_7 != (_S1678 == 1U);
                if(_S1679)
                {
                    return _S1311;
                }
                bool _S1680 = _S1315 == 1U;
                if(_S1680)
                {
                    float3  _S1681 = (fcptHitPosition((_S1327)));
                    throughput_10 = _S1681;
                }
                else
                {
                    throughput_10 = reconnection_0;
                }
                if(refracted_5)
                {
                    refracted_4 = true;
                }
                else
                {
                    BSDFMaterial _S1682 = _S1506;
                    bool _S1683 = isTranslucent_0(&_S1682);
                    if(_S1683)
                    {
                        refracted_4 = _S1675 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1684 = throughput_10 - (&ray_3)->origin;
                        float3  _S1685 = _slang_select(_S1680, _S1684,_S1676);
                        wrong_side_0 = (dot_0(_S1483.smooth_n, _S1685) * _S1484) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1680)
                {
                    float3  _S1686 = (&ray_3)->origin;
                    FKSurface _S1687 = surface_13;
                    float3  _S1688 = - _S1483.smooth_n;
                    bool _S1689 = is_inside_7 != refracted_4;
                    float3  _S1690 = _slang_select(_S1689, _S1688,_S1483.smooth_n);
                    float3  _S1691 = throughput_10 - (_S1686 + make_float3 (_S1687.geometry_offset) * _S1690);
                    float3  _S1692 = ((((_S1691)) * make_float3(rnorm3df(((_S1691)).x, ((_S1691)).y, ((_S1691)).z))));
                    reconnection_1 = _S1692;
                }
                else
                {
                    reconnection_1 = _S1676;
                }
                if(_S1514)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1693 = wrongSide_0(is_inside_7, refracted_4, reconnection_1, surface_13.geometry_n);
                    wrong_side_0 = _S1693;
                }
                if(wrong_side_0)
                {
                    return _S1311;
                }
                float3  _S1694 = throughput_10;
                throughput_10 = reconnection_1;
                b_10 = _S1675;
                wrong_side_0 = false;
                reconnection_1 = _S1694;
            }
            else
            {
                bool _S1695 = !_S1551;
                if(_S1695)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1696;
                    if(_S1514)
                    {
                        SampleBSDF _S1697 = (fcptSampleHair((surface_13.hair), (_S1506.albedo), (_S1506.specular_tint), ((&ray_3)->unit_direction), (surface_13.random_state)));
                        _S1696 = _S1697;
                    }
                    else
                    {
                        SampleBSDF _S1698 = sampleBSDF((&ray_3)->unit_direction, _S1483.smooth_n, _S1506, _S1507.x, _S1507.y, surface_13.random_state, _S1568);
                        _S1696 = _S1698;
                    }
                    bsdf_sampled_0 = _S1696;
                    if(_S1514)
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
                            return _S1311;
                        }
                        break;
                    }
                    if(_S1514)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1699 = wrongSide_0(is_inside_7, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_13.geometry_n);
                        wrong_side_0 = _S1699;
                    }
                    if(wrong_side_0)
                    {
                        _S1597 = (_S1506.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1597 = false;
                    }
                    if(_S1597)
                    {
                        SampleBSDF _S1700 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_13.geometry_n, _S1506, _S1507.x, _S1507.y, (&bsdf_sampled_0)->random_state, _S1568);
                        (&bsdf_sampled_0)->unit_direction = _S1700.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1700.refracted;
                        (&bsdf_sampled_0)->throughput = _S1700.throughput;
                        (&bsdf_sampled_0)->lobe = _S1700.lobe;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1701 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_13.geometry_n)) * surface_13.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1701;
                        }
                    }
                    uint _S1702 = (&bsdf_sampled_0)->lobe;
                    float3  _S1703 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1704 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1705 = (&bsdf_sampled_0)->pdf;
                    float _S1706 = _slang_select(wrong_side_0, 0.0f,_S1705);
                    (&lobe_5)->pdf = _S1706;
                    throughput_10 = _S1703;
                    b_10 = _S1702;
                    refracted_4 = _S1704;
                }
                else
                {
                    throughput_10 = _S1676;
                    b_10 = _S1675;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1597 = true;
            }
            else
            {
                _S1597 = _S1551;
            }
            float3  chain_throughput_2;
            if(_S1597)
            {
                if(_S1514)
                {
                    SampleBSDF _S1707 = (fcptConnectHair((surface_13.hair), (_S1506.albedo), (_S1506.specular_tint), ((&ray_3)->unit_direction), (throughput_10)));
                    lobe_5 = _S1707;
                }
                else
                {
                    float3  _S1708 = (&ray_3)->unit_direction;
                    float3  _S1709 = negate_0(_S1708);
                    float _S1710 = sign_0(_S1484);
                    float3  _S1711 = _S1483.smooth_n * make_float3 (_S1710);
                    float _S1712 = dot_0(_S1711, throughput_10);
                    float _S1713 = _S1506.roughness;
                    float _S1714 = _S1713 * _S1713;
                    AnisotropicFrame _S1715 = anisotropicFrame(_S1506, _S1711);
                    SheenProfile _S1716 = sheenProfile(_S1709, _S1711, _S1506);
                    float3  _S1717 = reflectedHalf(_S1708, throughput_10);
                    bool _S1718 = b_10 == 1U;
                    if(_S1718)
                    {
                        float3  _S1719 = refractedHalf(_S1708, throughput_10, _S1483.smooth_n, _S1507.x, _S1507.y);
                        throughput_11 = _S1719;
                    }
                    else
                    {
                        throughput_11 = _S1717;
                    }
                    bool _S1720 = b_10 == 0U;
                    if(_S1720)
                    {
                        _S1598 = true;
                    }
                    else
                    {
                        _S1598 = b_10 == 6U;
                    }
                    if(_S1598)
                    {
                        float3  _S1721 = sampledHalf(_S1709, _S1711, _S1714, _S1715, surface_13.random_state);
                        throughput_12 = _S1721;
                    }
                    else
                    {
                        throughput_12 = throughput_11;
                    }
                    float _S1722 = _S1507.x;
                    float _S1723 = _S1507.y;
                    Weights _S1724 = lobeWeights(_S1708, _S1709, _S1711, throughput_12, _S1715, _S1716, _S1506, _S1722, _S1723);
                    float _S1725 = (F32_abs((_S1484)));
                    float _S1726 = vndfPDF(_S1709, throughput_12, _S1711, _S1725, _S1714, _S1715, _S1724.v_dot_h);
                    switch(b_10)
                    {
                    case 0U:
                        {
                            float _S1727 = diffusePDF(_S1712, _S1725, _S1506, _S1724);
                            float3  _S1728 = diffuseBSDF(throughput_10, _S1711, _S1506, _S1724);
                            density_7 = _S1727;
                            chain_throughput_2 = _S1728;
                            break;
                        }
                    case 1U:
                        {
                            float _S1729 = refractPDF(dot_0(throughput_10, throughput_12), _S1726, _S1724, _S1722, _S1723);
                            float3  _S1730 = refractBSDF(throughput_10, _S1711, _S1714, _S1715, _S1506, _S1724);
                            density_7 = _S1729;
                            chain_throughput_2 = _S1730;
                            break;
                        }
                    case 4U:
                        {
                            float _S1731 = sheenVelvetPDF(_S1712, _S1725, _S1724);
                            float3  _S1732 = sheenVelvetBSDF(throughput_10, _S1709, _S1711, _S1506, _S1724);
                            density_7 = _S1731;
                            chain_throughput_2 = _S1732;
                            break;
                        }
                    case 6U:
                        {
                            ToonProfile _S1733 = toonProfile(_S1709, _S1711, _S1506);
                            float _S1734 = toonPDF(throughput_10, _S1711, _S1733, _S1724);
                            float3  _S1735 = toonBSDF(throughput_10, _S1711, _S1733, _S1724);
                            density_7 = _S1734;
                            chain_throughput_2 = _S1735;
                            break;
                        }
                    default:
                        {
                            float _S1736 = reflectPDF(_S1726, _S1724);
                            float3  _S1737 = reflectBSDF(throughput_10, _S1711, _S1714, _S1715, _S1724);
                            density_7 = _S1736;
                            chain_throughput_2 = _S1737;
                            break;
                        }
                    }
                    bool _S1738 = density_7 > 0.0f;
                    if(_S1738)
                    {
                        SampleBSDF _S1739 = SampleBSDF_x24init_0(throughput_10, chain_throughput_2, surface_13.random_state, _S1718, b_10, density_7);
                        lobe_5 = _S1739;
                    }
                }
            }
            bool _S1740 = b_10 == 0U;
            if(_S1740)
            {
                _S1598 = true;
            }
            else
            {
                _S1598 = b_10 == 4U;
            }
            if(_S1598)
            {
                _S1657 = true;
            }
            else
            {
                _S1657 = b_10 == 6U;
            }
            if(_S1514)
            {
                _S1658 = false;
            }
            else
            {
                bool _S1741 = !_S1657;
                if(_S1741)
                {
                    bool _S1742 = (_S1506.roughness) == 0.0f;
                    if(_S1742)
                    {
                        _S1658 = true;
                    }
                    else
                    {
                        bool _S1743 = b_10 == 1U;
                        if(_S1743)
                        {
                            _S1658 = (_S1507.x) == (_S1507.y);
                        }
                        else
                        {
                            _S1658 = false;
                        }
                    }
                }
                else
                {
                    _S1658 = false;
                }
            }
            bool _S1744 = !_S1514;
            if(_S1744)
            {
                _S1659 = b_10 == 1U;
            }
            else
            {
                _S1659 = false;
            }
            if(_S1659)
            {
                straight_0 = (_S1506.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1660 = _S1744;
            }
            else
            {
                _S1660 = false;
            }
            if(_S1660)
            {
                _S1661 = b_10 == 1U;
            }
            else
            {
                _S1661 = false;
            }
            if(_S1661)
            {
                _S1662 = (_S1507.x) == (_S1507.y);
            }
            else
            {
                _S1662 = false;
            }
            BSDFMaterial _S1745 = _S1506;
            bool _S1746 = isTranslucent_0(&_S1745);
            if(_S1746)
            {
                _S1663 = _S1740;
            }
            else
            {
                _S1663 = false;
            }
            if(_S1663)
            {
                _S1664 = (dot_0(throughput_10, surface_13.geometry_n)) < 0.0f;
            }
            else
            {
                _S1664 = false;
            }
            if(nee_0)
            {
                _S1665 = !_S1658;
            }
            else
            {
                _S1665 = false;
            }
            if(_S1665)
            {
                _S1666 = !wrong_side_0;
            }
            else
            {
                _S1666 = false;
            }
            if(_S1666)
            {
                float _S1747 = (&lobe_5)->pdf;
                float3  _S1748 = (&ray_3)->origin;
                float3  _S1749 = _slang_select(_S1519, _S1310,_S1483.smooth_n);
                float3  _S1750 = (&ray_3)->origin;
                FKSurface _S1751 = surface_13;
                float3  _S1752 = - _S1483.smooth_n;
                float3  _S1753 = _slang_select(_S1664, _S1752,_S1483.smooth_n);
                NEEVertex _S1754 = NEEVertex_x24init_0(false, _S1747, _S1748, _S1749, _S1750 + make_float3 (_S1751.geometry_offset) * _S1753);
                nee_vertex_1 = _S1754;
            }
            else
            {
                if(_S1514)
                {
                    _S1667 = true;
                }
                else
                {
                    bool _S1755 = b_10 != 1U;
                    if(_S1755)
                    {
                        _S1667 = true;
                    }
                    else
                    {
                        _S1667 = (_S1507.x) != (_S1507.y);
                    }
                }
                if(_S1667)
                {
                    (&nee_vertex_1)->none = true;
                }
            }
            bool _S1756 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1756)
            {
                if(_S1657)
                {
                    _S1667 = true;
                }
                else
                {
                    _S1667 = ((&lobe_5)->pdf * (&prev_1)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1667 = false;
            }
            bool _S1757 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1757)
            {
                if(_S1657)
                {
                    _S1668 = true;
                }
                else
                {
                    _S1668 = (_S1506.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1668 = false;
            }
            if(_S1551)
            {
                bool _S1758 = !_S1667;
                if(_S1758)
                {
                    return _S1311;
                }
                bool _S1759 = _S1316 != 1U;
                if(_S1759)
                {
                    _S1669 = _S1316 != 2U;
                }
                else
                {
                    _S1669 = false;
                }
                if(_S1669)
                {
                    float _S1760 = (&lobe_5)->pdf;
                    float _S1761 = _slang_select(nee_0, _S1760,0.0f);
                    float _S1762 = escapeWeight_0(_S1761, _S1676);
                    if(_S1559)
                    {
                        passes_0 = _S1322;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1763 = _slang_select(passes_0, _S1762,1.0f);
                    return Shift_x24init_0(throughput_8 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_9->radiance * make_float3 (_S1763) / make_float3 (r_9->jac), density_5 * (&lobe_5)->pdf / r_9->jac);
                }
                float3  _S1764 = throughput_8 * make_float3 ((&lobe_5)->pdf);
                float _S1765 = density_5 * (&lobe_5)->pdf;
                throughput_11 = _S1764;
                density_7 = _S1765;
            }
            else
            {
                throughput_11 = throughput_8;
                density_7 = density_5;
            }
            uint _S1766 = (fcptLayers((hit_4)));
            bool _S1767 = _S1766 > 1U;
            if(_S1767)
            {
                _S1669 = (b_10 == 1U) != passes_0;
            }
            else
            {
                _S1669 = false;
            }
            if(viewed_1)
            {
                _S1670 = _S1669;
            }
            else
            {
                _S1670 = false;
            }
            if(_S1670)
            {
                return _S1311;
            }
            if(replay_2)
            {
                _S1671 = b_7 <= _S1326;
            }
            else
            {
                _S1671 = false;
            }
            if(_S1671)
            {
                _S1672 = _S1482;
            }
            else
            {
                _S1672 = false;
            }
            bool _S1768;
            if(_S1672)
            {
                _S1768 = _S1667;
            }
            else
            {
                _S1768 = false;
            }
            bool _S1769;
            if(_S1768)
            {
                _S1769 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1769 = !_S1668;
                }
                else
                {
                    _S1769 = false;
                }
            }
            if(_S1769)
            {
                return _S1311;
            }
            if(viewed_1)
            {
                float3  _S1770 = throughput_11 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1771 = (&lobe_5)->pdf;
                throughput_12 = _S1770;
                sky_pdf_3 = _S1771;
            }
            else
            {
                float3  _S1772 = throughput_11 * max_0((&lobe_5)->throughput, _S1310);
                throughput_12 = _S1772;
                sky_pdf_3 = density_7;
            }
            bool _S1773;
            if(_S1523)
            {
                _S1773 = !_S1538;
            }
            else
            {
                _S1773 = false;
            }
            bool _S1774;
            if(_S1773)
            {
                _S1774 = _S1482;
            }
            else
            {
                _S1774 = false;
            }
            bool _S1775;
            if(_S1774)
            {
                _S1775 = _S1667;
            }
            else
            {
                _S1775 = false;
            }
            if(_S1775)
            {
                chain_1 = here_0;
                uint _S1776 = insertBits_0((&chain_1)->path, b_10, 18U, 3U);
                uint _S1777 = _slang_select(nee_0, 1U,0U);
                uint _S1778 = insertBits_0(_S1776, _S1777, 21U, 1U);
                (&chain_1)->path = _S1778;
                float _S1779 = (&chain_1)->jac * (&lobe_5)->pdf;
                (&chain_1)->jac = _S1779;
                (&chain_1)->dir = throughput_10;
                chain_throughput_2 = throughput_12;
            }
            else
            {
                chain_throughput_2 = chain_throughput_1;
            }
            FKSurface _S1780 = surface_13;
            Vertex _S1781 = Vertex_x24init_0(_S1668, b_10, (&lobe_5)->pdf, (F32_abs((dot_0(surface_13.geometry_n, throughput_10)))), is_inside_7);
            prev_1 = _S1781;
            float _S1782 = (&lobe_5)->pdf;
            bool _S1783 = b_10 == 1U;
            bool _S1784;
            if(_S1783)
            {
                _S1784 = (_S1507.x) == (_S1507.y);
            }
            else
            {
                _S1784 = false;
            }
            float sky_pdf_4 = _slang_select(_S1784, sky_pdf_1,_S1782);
            float _S1785 = _slang_select(_S1514, 0.0f,sky_pdf_4);
            float _S1786 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1787 = !_S1658;
            float _S1788 = _slang_select(_S1787, _S1786,0.0f);
            float _S1789 = spread_1 + _S1788;
            bool _S1790;
            if(refracted_4)
            {
                _S1790 = !_S1664;
            }
            else
            {
                _S1790 = false;
            }
            bool is_inside_8;
            if(_S1790)
            {
                bool _S1791 = !is_inside_7;
                is_inside_8 = _S1791;
            }
            else
            {
                is_inside_8 = is_inside_7;
            }
            FKSurface _S1792 = surface_13;
            bool _S1793 = boundsVolume_0(&_S1792);
            bool _S1794;
            if(_S1793)
            {
                _S1794 = !_S1669;
            }
            else
            {
                _S1794 = false;
            }
            if(_S1794)
            {
                FKSurface faced_2 = surface_13;
                float3  _S1795 = - _S1780.geometry_n;
                float3  _S1796 = _slang_select(turned_1, _S1795,_S1780.geometry_n);
                (&faced_2)->geometry_n = _S1796;
                FKMedium _S1797 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1798 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1799 = faced_2;
                FKMedium _S1800 = _S1797;
                FKMedium _S1801 = _S1798;
                MediumSides _S1802 = mediumSides_0(&_S1799, &_S1800, filling_2, (&ray_3)->unit_direction, &_S1801);
                bool _S1803 = ((dot_0(throughput_10, _S1780.geometry_n)) > 0.0f) == ((dot_0(_S1780.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1804 = _slang_select(_S1803, _S1802.front.scatter,_S1802.behind.scatter);
                scatter_in_0 = _S1804;
                float3  _S1805 = scatter_in_0;
                float _S1806 = upsample(scatter_in_0, wavelength_10);
                float3  _S1807 = make_float3 (_S1806);
                float3  _S1808 = _slang_select(_S1546, _S1807,_S1805);
                scatter_in_0 = _S1808;
                float3  _S1809 = _slang_select(_S1803, _S1802.front.extinction,_S1802.behind.extinction);
                extinction_in_0 = _S1809;
                float3  _S1810 = extinction_in_0;
                float _S1811 = upsample(extinction_in_0, wavelength_10);
                float3  _S1812 = make_float3 (_S1811);
                float3  _S1813 = _slang_select(_S1546, _S1812,_S1810);
                extinction_in_0 = _S1813;
                float _S1814 = _slang_select(_S1803, _S1802.front.g,_S1802.behind.g);
                g_in_0 = _S1814;
                uint _S1815 = _S1802.fillings.x;
                uint _S1816 = _S1802.fillings.y;
                uint _S1817 = _slang_select(_S1803, _S1816,_S1815);
                bool _S1818 = (fcptVaryingUsed());
                uint _S1819 = _slang_select(_S1818, _S1817,4294967295U);
                filling_2 = _S1819;
            }
            (&ray_3)->unit_direction = throughput_10;
            bool _S1820 = !_S1669;
            if(_S1820)
            {
                FKSurface _S1821 = surface_13;
                float _S1822 = _slang_select(straight_0, 0.0f,_S1821.geometry_offset);
                float3  _S1823 = - _S1483.smooth_n;
                bool _S1824 = is_inside_8 != _S1664;
                float3  _S1825 = _slang_select(_S1824, _S1823,_S1483.smooth_n);
                float3  _S1826 = (&ray_3)->origin + make_float3 (_S1822) * _S1825;
                (&ray_3)->origin = _S1826;
            }
            throughput_11 = throughput_12;
            chain_throughput_1 = chain_throughput_2;
            density_7 = sky_pdf_3;
            passes_0 = _S1669;
            viewed_1 = _S1662;
            sky_pdf_3 = _S1785;
            spread_4 = _S1789;
            reconnection_0 = reconnection_1;
            is_inside_6 = is_inside_8;
        }
        else
        {
            (&prev_1)->rough = false;
            (&prev_1)->pdf = 0.0f;
            throughput_11 = throughput_8;
            density_7 = density_5;
            passes_0 = false;
            viewed_1 = viewed_0;
            sky_pdf_3 = 0.0f;
            spread_4 = spread_1;
            straight_0 = false;
            is_inside_6 = is_inside_7;
        }
        float density_8;
        if(_S1523)
        {
            if(_S1445)
            {
                float3  _S1827 = pathColor(throughput_11 * emission_1, spectral_weight_1, wavelength_10);
                Reservoir candidate_8 = chain_1;
                uint _S1828 = extractBits_0((&chain_1)->path, 10U, 2U);
                bool _S1829 = _S1828 == 1U;
                if(_S1829)
                {
                    float3  _S1830 = safeDivide(_S1827, chain_throughput_1);
                    (&candidate_8)->radiance = _S1830;
                }
                Reservoir _S1831 = withEnd(candidate_8, 2U, b_7, _S1827);
                offer(sel_8, _S1831, _S1827 * make_float3 (scale_4) / make_float3 (density_7));
            }
            if(_S1445)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1832 = survivalProbability(abs_0(throughput_11), density_7);
                density_8 = _S1832;
            }
            else
            {
                density_8 = 1.0f;
            }
            uint _S1833 = stream(_S1338, b_7 + 128U);
            Random _S1834 = pcg(_S1833);
            bool _S1835 = density_8 < (_S1834.value);
            if(_S1835)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1836 = (fcptMaxBounces());
                wrong_side_0 = b_7 >= _S1836;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1837 = density_7 * density_8;
            density_8 = _S1837;
        }
        else
        {
            density_8 = density_7;
        }
        uint _S1838 = layer_0 ^ 1U;
        uint _S1839 = _slang_select(passes_0, _S1838,0U);
        if(passes_0)
        {
            (&prev_1)->rough = false;
            (&hit_4)->distance = 0.0f;
            b_10 = b_7;
            viewed_0 = viewed_1;
            throughput_3 = throughput_11;
            density_3 = density_8;
            sky_pdf_1 = sky_pdf_3;
            spread_1 = spread_4;
            uint _S1840 = b_10 + 1U;
            b_7 = _S1840;
            layer_0 = _S1839;
            continue;
        }
        FKRay _S1841 = ray_3;
        float _S1842 = distance_1(reconnection_0, (&ray_3)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1552;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1315 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1843 = _slang_select(wrong_side_0, _S1842,4.294967296e+09f);
        bool _S1844 = !_S1514;
        if(straight_0)
        {
            _S1597 = true;
        }
        else
        {
            _S1597 = _S1514;
        }
        FKHit _S1845;
        if(_S1597)
        {
            _S1845 = hit_4;
        }
        else
        {
            _S1845 = _S1569;
        }
        FKHit _S1846 = (fcptTraverseInstanceBVH((_S1841), (_S1452), (_S1843), (_S1844), (_S1845), (viewed_1)));
        hit_4 = _S1846;
        if(replay_2)
        {
            _S1598 = _S1552;
        }
        else
        {
            _S1598 = false;
        }
        if(_S1598)
        {
            _S1657 = _S1315 == 1U;
        }
        else
        {
            _S1657 = false;
        }
        if(_S1657)
        {
            _S1658 = ((&hit_4)->instance_index) == (_S1327.instance_index);
        }
        else
        {
            _S1658 = false;
        }
        if(_S1658)
        {
            _S1659 = ((&hit_4)->triangle_index) == (_S1327.triangle_index);
        }
        else
        {
            _S1659 = false;
        }
        if(_S1659)
        {
            (&hit_4)->uv = _S1327.uv;
            float _S1847 = distance_1(reconnection_0, (&ray_3)->origin);
            (&hit_4)->distance = _S1847;
        }
        if(replay_2)
        {
            _S1660 = _S1552;
        }
        else
        {
            _S1660 = false;
        }
        if(_S1660)
        {
            _S1661 = _S1315 == 3U;
        }
        else
        {
            _S1661 = false;
        }
        if(_S1661)
        {
            _S1662 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1662 = false;
        }
        if(_S1662)
        {
            return _S1311;
        }
        Reservoir _S1848 = chain_1;
        uint _S1849 = filling_2;
        for(;;)
        {
            bool _S1850 = (fcptVaryingUsed());
            if(_S1850)
            {
                _S1663 = _S1849 != 4294967295U;
            }
            else
            {
                _S1663 = false;
            }
            float _S1851;
            if(_S1663)
            {
                float _S1852 = (fcptMajorant((_S1849)));
                _S1851 = _S1852;
            }
            else
            {
                _S1851 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1664 = _S1552;
            }
            else
            {
                _S1664 = false;
            }
            if(_S1664)
            {
                _S1665 = _S1315 == 1U;
            }
            else
            {
                _S1665 = false;
            }
            if(_S1665)
            {
                _S1666 = _S1851 > 0.0f;
            }
            else
            {
                _S1666 = false;
            }
            if(_S1666)
            {
                ended_0 = _S1311;
                sky_pdf_2 = sky_pdf_3;
                spread_2 = spread_4;
                width_4 = width_3;
                density_4 = density_8;
                throughput_12 = throughput_11;
                b_10 = b_7;
                _S1667 = true;
                break;
            }
            bool _S1853 = (&prev_1)->rough;
            if(_S1853)
            {
                _S1667 = !(_S1851 > 0.0f);
            }
            else
            {
                _S1667 = false;
            }
            (&prev_1)->rough = _S1667;
            uint _S1854 = b_7 + 320U;
            bool _S1855 = b_7 == 4294967295U;
            uint _S1856 = _slang_select(_S1855, 384U,_S1854);
            uint _S1857 = stream(_S1338, _S1856);
            uint tracking_1 = _S1857;
            weight_2 = throughput_4;
            glowed_0 = _S1310;
            b_10 = b_7;
            throughput_12 = throughput_11;
            density_4 = density_8;
            spread_2 = spread_4;
            width_4 = width_3;
            sky_pdf_2 = sky_pdf_3;
            for(;;)
            {
                if(((&hit_4)->instance_index) != 4294967295U)
                {
                }
                else
                {
                    _S1309 = int(2);
                    break;
                }
                uint _S1858 = b_10 + 320U;
                bool _S1859 = b_10 == 4294967295U;
                uint _S1860 = _slang_select(_S1859, 384U,_S1858);
                uint _S1861 = stream(_S1338, _S1860);
                Random _S1862 = pcg(_S1861);
                float _S1863 = - (F32_log((1.0f - _S1862.value))) / _S1851;
                if(_S1663)
                {
                    float3  _S1864 = (&ray_3)->origin;
                    float3  _S1865 = (&ray_3)->unit_direction;
                    float _S1866 = (&hit_4)->distance;
                    uint _S1867 = _slang_select(_S1859, 0U,b_10);
                    uint _S1868 = (&prev_1)->lobe;
                    uint _S1869 = _slang_select(_S1859, 3U,_S1868);
                    float _S1870 = (fcptTrackMedium((_S1849), (_S1864), (_S1865), (_S1866), (&tracking_1), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1867), (_S1869), (_S1859)));
                    spread_3 = _S1870;
                }
                else
                {
                    spread_3 = _S1863;
                }
                bool _S1871 = !(spread_3 < ((&hit_4)->distance));
                if(_S1871)
                {
                    _S1309 = int(2);
                    break;
                }
                if(_S1663)
                {
                    _S1668 = _S1523;
                }
                else
                {
                    _S1668 = false;
                }
                if(_S1668)
                {
                    float3  _S1872 = pathColor(throughput_12 * glowed_0, spectral_weight_1, wavelength_10);
                    float3  _S1873 = _S1872 / make_float3 (density_4);
                    float3  _S1874 = sel_8->glow + _S1873;
                    sel_8->glow = _S1874;
                }
                else
                {
                }
                glowed_0 = _S1310;
                uint b_11 = b_10 + 1U;
                float3  _S1875 = (&ray_3)->origin + make_float3 (spread_3) * (&ray_3)->unit_direction;
                (&ray_3)->origin = _S1875;
                float3  _S1876 = flightWeight_0(scatter_in_0, extinction_in_0, _S1851, spread_3, true);
                float3  _S1877 = weight_2;
                float _S1878 = upsample(weight_2, wavelength_10);
                float3  _S1879 = make_float3 (_S1878);
                float3  _S1880 = _slang_select(_S1546, _S1879,_S1877);
                float3  _S1881 = _slang_select(_S1663, _S1880,_S1876);
                float3  throughput_13 = throughput_12 * _S1881;
                uint _S1882 = stream(_S1338, b_11 + 320U);
                tracking_1 = _S1882;
                weight_2 = throughput_4;
                float width_7 = width_4 + spread_2 * spread_3;
                float _S1883 = spread_2 + 3.14159274101257324f;
                if(_S1523)
                {
                    _S1669 = true;
                }
                else
                {
                    bool _S1884 = b_11 == _S1326;
                    if(_S1884)
                    {
                        _S1669 = !_S1663;
                    }
                    else
                    {
                        _S1669 = false;
                    }
                }
                TreeSample light_4;
                if(_S1669)
                {
                    float3  _S1885 = (&ray_3)->origin;
                    float3  _S1886 = (&ray_3)->unit_direction;
                    float3  _S1887 = (&ray_3)->unit_direction;
                    uint _S1888 = stream(_S1338, b_11 + 64U);
                    float3  _S1889 = extinction_in_0;
                    float3  _S1890 = extinction_in_0;
                    uint2  _S1891 = make_uint2 (_S1849);
                    float3  _S1892 = (&ray_3)->unit_direction;
                    uint _S1893 = arrivalLobe_0(b_11, (&prev_1)->lobe);
                    FKHit _S1894 = _S1569;
                    ShadowContext _S1895 = ShadowContext_x24init_0(_S1889, _S1890, _S1891, _S1892, b_11, _S1893, false, spread_3, width_7, &_S1894, false);
                    ShadowContext _S1896 = _S1895;
                    TreeSample _S1897 = sampleLightTree_0(_S1885, _S1886, _S1887, 0.0f, true, _S1888, &_S1896);
                    light_4 = _S1897;
                }
                else
                {
                    light_4 = _S1566;
                }
                float _S1898 = phaseHG_0(g_in_0, dot_0((&ray_3)->unit_direction, light_4.dir));
                uint _S1899 = (fcptMaxBounces());
                bool _S1900 = b_11 < _S1899;
                if(_S1900)
                {
                    _S1670 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1670 = false;
                }
                float _S1901 = _slang_select(_S1670, _S1898,0.0f);
                float3  _S1902 = throughput_13 * light_4.radiance;
                float _S1903 = powerHeuristic(light_4.density, _S1901);
                float3  _S1904 = pathColor(_S1902 * make_float3 (_S1898 * _S1903), spectral_weight_1, wavelength_10);
                float3  _S1905 = _slang_select(_S1669, _S1904,_S1310);
                if(replay_2)
                {
                    _S1671 = b_11 == _S1326;
                }
                else
                {
                    _S1671 = false;
                }
                if(_S1671)
                {
                    bool _S1906 = _S1315 == 2U;
                    if(_S1906)
                    {
                        float _S1907 = resamplingTarget(_S1905);
                        _S1672 = _S1907 > 0.0f;
                    }
                    else
                    {
                        _S1672 = false;
                    }
                    if(_S1672)
                    {
                        Shift _S1908 = Shift_x24init_0(_S1905, 1.0f);
                        _S1309 = int(1);
                        ended_0 = _S1908;
                        spread_3 = _S1883;
                        width_5 = width_7;
                        throughput_10 = throughput_13;
                        b_8 = b_11;
                        break;
                    }
                    _S1309 = int(1);
                    ended_0 = _S1311;
                    spread_3 = _S1883;
                    width_5 = width_7;
                    throughput_10 = throughput_13;
                    b_8 = b_11;
                    break;
                }
                if(_S1523)
                {
                    Reservoir candidate_9 = _S1848;
                    uint _S1909 = extractBits_0(_S1848.path, 24U, 8U);
                    uint _S1910 = insertBits_0(0U, _S1909, 24U, 8U);
                    uint _S1911 = extractBits_0(_S1848.path, 10U, 2U);
                    bool _S1912 = _S1911 == 1U;
                    if(_S1912)
                    {
                        float3  _S1913 = safeDivide(_S1905, chain_throughput_1);
                        (&candidate_9)->radiance = _S1913;
                    }
                    else
                    {
                        uint _S1914 = insertBits_0(_S1910, b_11 + 1U, 5U, 5U);
                        uint _S1915 = insertBits_0(_S1914, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1915;
                    }
                    Reservoir _S1916 = withEnd(candidate_9, 0U, b_11, _S1905);
                    offer(sel_8, _S1916, _S1905 * make_float3 (scale_4) / make_float3 (density_4));
                    float _S1917 = survivalProbability(abs_0(throughput_13), density_4);
                    uint _S1918 = stream(_S1338, b_11 + 128U);
                    Random _S1919 = pcg(_S1918);
                    bool _S1920 = _S1917 < (_S1919.value);
                    if(_S1920)
                    {
                        _S1672 = true;
                    }
                    else
                    {
                        uint _S1921 = (fcptMaxBounces());
                        _S1672 = b_11 >= _S1921;
                    }
                    if(_S1672)
                    {
                        _S1309 = int(1);
                        ended_0 = _S1311;
                        spread_3 = _S1883;
                        width_5 = width_7;
                        throughput_10 = throughput_13;
                        b_8 = b_11;
                        break;
                    }
                    float _S1922 = density_4 * _S1917;
                    density_4 = _S1922;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1923 = stream(_S1338, b_11);
                float3  _S1924 = samplePhase_0(g_in_0, (&ray_3)->unit_direction, _S1923, &phase_pdf_1);
                (&ray_3)->unit_direction = _S1924;
                NEEVertex _S1925 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_3)->origin, _S1310, (&ray_3)->origin);
                nee_vertex_1 = _S1925;
                Vertex _S1926 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_6);
                prev_1 = _S1926;
                float _S1927 = (&prev_1)->pdf;
                FKRay _S1928 = ray_3;
                FKHit _S1929 = (fcptTraverseInstanceBVH((_S1928), (true), (4.294967296e+09f), (false), (_S1569), (false)));
                hit_4 = _S1929;
                b_10 = b_11;
                throughput_12 = throughput_13;
                spread_2 = _S1883;
                width_4 = width_7;
                sky_pdf_2 = _S1927;
            }
            if(_S1309 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_12 = throughput_10;
                b_10 = b_8;
                _S1667 = true;
                break;
            }
            ended_0 = _S1311;
            _S1667 = false;
            break;
        }
        if(_S1667)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1668 = b_10 == b_7;
        }
        else
        {
            _S1668 = false;
        }
        bool _S1930 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1930)
        {
            Reservoir _S1931 = chain_1;
            FKRay _S1932 = ray_3;
            Vertex _S1933 = prev_1;
            NEEVertex _S1934 = nee_vertex_1;
            Shift _S1935 = escape_0(r_9, replay_2, _S1326, _S1315, _S1313, _S1316, scale_4, _S1340, &_S1931, chain_throughput_1, b_10, &_S1932, throughput_12, density_4, &_S1933, &_S1934, sky_pdf_2, spectral_weight_1, wavelength_10, sel_8);
            return _S1935;
        }
        float3  _S1936 = (&ray_3)->origin + make_float3 ((&hit_4)->distance) * (&ray_3)->unit_direction;
        (&ray_3)->origin = _S1936;
        bool _S1937 = (fcptVaryingUsed());
        if(_S1937)
        {
            _S1669 = filling_2 != 4294967295U;
        }
        else
        {
            _S1669 = false;
        }
        if(_S1669)
        {
            if(_S1523)
            {
                float3  _S1938 = pathColor(throughput_12 * glowed_0, spectral_weight_1, wavelength_10);
                float3  _S1939 = _S1938 / make_float3 (density_4);
                float3  _S1940 = sel_8->glow + _S1939;
                sel_8->glow = _S1940;
            }
            float3  _S1941 = throughput_12 * weight_2;
            throughput_10 = _S1941;
        }
        else
        {
            float3  _S1942 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1943 = throughput_12 * _S1942;
            throughput_10 = _S1943;
        }
        float _S1944 = width_4 + spread_2 * (&hit_4)->distance;
        viewed_0 = _S1668;
        width_3 = _S1944;
        throughput_3 = throughput_10;
        density_3 = density_4;
        sky_pdf_1 = sky_pdf_2;
        spread_1 = spread_2;
        uint _S1840 = b_10 + 1U;
        b_7 = _S1840;
        layer_0 = _S1839;
    }
    return _S1311;
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
        *_slang_vector_get_element_ptr(&result_15, i_29) = (F32_tan((_slang_vector_get_element(x_27, i_29))));
        i_29 = i_29 + int(1);
    }
    return result_15;
}

static __device__ float3  acos_0(float3  x_28)
{
    float3  result_16;
    int i_30 = int(0);
    for(;;)
    {
        if(i_30 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_16, i_30) = (F32_acos((_slang_vector_get_element(x_28, i_30))));
        i_30 = i_30 + int(1);
    }
    return result_16;
}

__device__ Random normal_distribution(uint state_3)
{
    Random _S1945 = pcg(state_3);
    Random _S1946 = pcg(_S1945.state);
    float _S1947 = 6.28318548202514648f * _S1945.value;
    float _S1948 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1946.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1946.state, _S1948 * (F32_cos((_S1947))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1949;
    (&_S1949)->state = state_4;
    (&_S1949)->value = value_2;
    return _S1949;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1950 = normal_distribution(state_5);
    Random _S1951 = normal_distribution(_S1950.state);
    Random _S1952 = normal_distribution(_S1951.state);
    float3  _S1953 = make_float3 (_S1950.value, _S1951.value, _S1952.value);
    float3  _S1954 = ((((_S1953)) * make_float3(rnorm3df(((_S1953)).x, ((_S1953)).y, ((_S1953)).z))));
    return RandomSphere_x24init_0(_S1952.state, _S1954);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_11)
{
    float3  _S1955 = p1_0 - p0_0;
    float3  _S1956 = p2_0 - p0_0;
    float2  _S1957 = uv1_0 - uv0_0;
    float2  _S1958 = uv2_0 - uv0_0;
    float _S1959 = _S1957.x;
    float _S1960 = _S1958.y;
    float _S1961 = _S1957.y;
    float _S1962 = _S1958.x;
    float _S1963 = _S1959 * _S1960 - _S1961 * _S1962;
    float _S1964 = 1.0f / _S1963;
    float3  t_24 = (_S1955 * make_float3 (_S1960) - _S1956 * make_float3 (_S1961)) * make_float3 (_S1964);
    float3  _S1965 = (_S1956 * make_float3 (_S1959) - _S1955 * make_float3 (_S1962)) * make_float3 (_S1964);
    float3  _S1966 = t_24 - n_11 * make_float3 (dot_0(n_11, t_24));
    float3  _S1967 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_11);
    bool _S1968 = (dot_0(_S1966, _S1966)) > 0.0f;
    float3  _S1969 = _slang_select(_S1968, _S1966,_S1967);
    float3  _S1970 = ((((_S1969)) * make_float3(rnorm3df(((_S1969)).x, ((_S1969)).y, ((_S1969)).z))));
    bool _S1971 = (dot_0(cross_0(n_11, _S1970), _S1965)) > 0.0f;
    float3  t_25;
    if(_S1971)
    {
        float3  _S1972 = negate_0(_S1970);
        t_25 = _S1972;
    }
    else
    {
        t_25 = _S1970;
    }
    float3  _S1973 = cross_0(n_11, t_25);
    return makeMatrix<float, 3, 3> (t_25, _S1973, n_11);
}

__device__ float3  tangentToWorldNormalMap(float3  v_10, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_10, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_0)
{
    float3  _S1974 = t1_0 - t0_0;
    float3  _S1975 = t2_2 - t0_0;
    float3  _S1976 = t2_2 - t1_0;
    float _S1977 = (F32_min((length_0(_S1974)), ((F32_min((length_0(_S1975)), (length_0(_S1976)))))));
    float3  _S1978 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1979 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1980 = dot_0(geometry_n_4, _S1979);
    float3  _S1981 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1982 = dot_0(geometry_n_4, _S1981);
    float3  _S1983 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1984 = acos_0(abs_0(make_float3 (_S1980, _S1982, dot_0(geometry_n_4, _S1983))));
    float3  _S1985 = clamp_2(tan_0(_S1984), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1978 * _S1985, uvw_0), 0.0f, _S1977 * 0.125f);
}

__device__ float3  straightThrough(BSDFMaterial material_26)
{
    return make_float3 (material_26.transmission * (1.0f - material_26.metallic)) * material_26.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_26, float3  out_dir_3, uint p_14, float w_19, float alpha_10, uint nt_0)
{
    uint _S1986 = p_14 % 4U;
    float _S1987 = w_19 * HAIR_WIDTHS_0[_S1986];
    float _S1988 = (F32_asin((clamp_1(dot_0(out_dir_3, t_26), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_26), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1986] * alpha_10;
    return ((F32_asinh((_S1988 / _S1987))) / (F32_asinh((3.14159274101257324f / _S1987))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_27, float3  out_dir_4, uint np_0)
{
    float3  _S1989 = worldToTangent(out_dir_4, t_27);
    float3  _S1990 = worldToTangent(in_dir_12, t_27);
    return (F32_frac((((F32_atan2((_S1989.z), (_S1989.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1990.z), (1.17549435082228751e-38f - _S1990.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_28, uint p_15, float row_0, float column_0, float w_20, float alpha_11, uint nt_1, uint np_1)
{
    float3  _S1991 = worldToTangent(in_dir_13, t_28);
    uint _S1992 = p_15 % 4U;
    float _S1993 = w_20 * HAIR_WIDTHS_0[_S1992];
    float _S1994 = (F32_asin((clamp_1(dot_0(in_dir_13, t_28), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1992] * alpha_11 + _S1993 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1993))))));
    float _S1995 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1991.z), (1.17549435082228751e-38f - _S1991.x)));
    float _S1996 = (F32_cos((_S1994)));
    float3  _S1997 = tangentToWorld(make_float3 (_S1996 * (F32_cos((_S1995))), (F32_sin((_S1994))), _S1996 * (F32_sin((_S1995)))), t_28);
    return _S1997;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_12, BSDFMaterial material_27, float coverage_1)
{
    float3  _S1998;
    if((material_27.ior) == 1.0f)
    {
        float3  _S1999 = straightThrough(material_27);
        _S1998 = _S1999;
    }
    else
    {
        _S1998 = make_float3 (0.0f);
    }
    return _S1998 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_8, Reservoir r_10, bool replay_3, float scale_5, Selection * sel_9)
{
    Domain _S2000 = dom_8;
    Reservoir _S2001 = r_10;
    Shift _S2002 = walk_0(&_S2000, &_S2001, replay_3, scale_5, sel_9);
    return _S2002;
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
