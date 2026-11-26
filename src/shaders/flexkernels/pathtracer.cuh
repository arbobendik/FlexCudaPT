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

__device__ float importance(LightNode node_0, float3  p_9, float3  normal_0)
{
    float3  _S224 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S225 = node_0.high - node_0.low;
    float3  _S226 = p_9 - _S224;
    float3  _S227 = ((((_S226)) * make_float3(rnorm3df(((_S226)).x, ((_S226)).y, ((_S226)).z))));
    float _S228 = dot_0(_S226, _S226);
    float _S229 = dot_0(_S225, _S225) / 4.0f;
    float _S230 = (F32_abs((dot_0(node_0.w, _S227))));
    float _S231 = sine(node_0.cos_theta_o);
    float _S232 = (F32_sqrt(((F32_max((1.0f - _S229 / _S228), (0.0f))))));
    bool _S233 = _S228 < _S229;
    float _S234 = _slang_select(_S233, -1.0f,_S232);
    float _S235 = sine(_S234);
    float _S236 = sine(_S230);
    float _S237 = cosSubClamped(_S236, _S230, _S231, node_0.cos_theta_o);
    float _S238 = sine(_S230);
    float _S239 = _S238 * node_0.cos_theta_o - _S230 * _S231;
    bool _S240 = _S230 > (node_0.cos_theta_o);
    float _S241 = _slang_select(_S240, 0.0f,_S239);
    float _S242 = cosSubClamped(_S241, _S237, _S235, _S234);
    bool _S243 = _S242 <= 0.0f;
    if(_S243)
    {
        return 0.0f;
    }
    float _S244 = - dot_0(_S227, normal_0);
    float _S245 = node_0.phi * _S242 / (F32_max((_S228), (length_0(_S225) / 2.0f)));
    float _S246 = sine(_S244);
    float _S247 = cosSubClamped(_S246, _S244, _S235, _S234);
    bool _S248 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S249 = _slang_select(_S248, 1.0f,_S247);
    return (F32_max((_S245 * _S249), (0.0f)));
}

__device__ __forceinline__ float childShare(LightNode first_0, LightNode second_0, float3  p_10, float3  normal_1, uint child_0)
{
    float _S250 = importance(first_0, p_10, normal_1);
    float _S251 = importance(second_0, p_10, normal_1);
    float2  _S252 = make_float2 (_S250, _S251);
    float _S253 = _slang_vector_get_element(_S252, child_0) / (_S250 + _S251);
    bool _S254 = _slang_vector_get_element(_S252, child_0) > 0.0f;
    float _S255 = _slang_select(_S254, _S253,0.0f);
    return _S255;
}

__device__ float sphereDensity(float3  center_0, float radius_0, float3  p_11)
{
    float3  _S256 = center_0 - p_11;
    float _S257 = radius_0 * radius_0 / dot_0(_S256, _S256);
    bool _S258 = _S257 >= 1.0f;
    if(_S258)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S257)))) / (6.28318548202514648f * _S257);
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S259 = left_0.y;
    float _S260 = right_0.z;
    float _S261 = left_0.z;
    float _S262 = right_0.y;
    float _S263 = right_0.x;
    float _S264 = left_0.x;
    return make_float3 (_S259 * _S260 - _S261 * _S262, _S261 * _S263 - _S264 * _S260, _S264 * _S262 - _S259 * _S263);
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_0))));
}

static __device__ float lightPdf_0(float3  origin_3, float3  smooth_n_1, float3  start_5, uint j_0, float3  light_point_0)
{
    bool _S265 = j_0 == 4294967295U;
    if(_S265)
    {
        return 0.0f;
    }
    uint4  _S266 = (fcptLightTrail((j_0)));
    uint2  _S267 = uint2 {_S266.x, _S266.y};
    uint n_0 = 0U;
    uint2  trail_0 = _S267;
    float probability_1 = 1.0f;
    for(;;)
    {
        uint4  _S268 = (fcptLightNode((n_0)));
        if((_S268.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S269 = (fcptLightSecond((n_0)));
        uint _S270 = n_0 + 1U;
        LightNode _S271 = (fcptLightBounds((_S270)));
        LightNode _S272 = (fcptLightBounds((_S269)));
        uint _S273 = trail_0.x;
        uint _S274 = _S273 & 1U;
        float _S275 = childShare(_S271, _S272, origin_3, smooth_n_1, _S274);
        float probability_2 = probability_1 * _S275;
        bool _S276 = _S274 == 1U;
        uint _S277 = _slang_select(_S276, _S269,_S270);
        uint _S278 = trail_0.y;
        uint2  _S279 = make_uint2 ((_S273 >> 1U) | (_S278 << 31U), _S278 >> 1U);
        n_0 = _S277;
        trail_0 = _S279;
        probability_1 = probability_2;
    }
    bool _S280 = (fcptSlotLeaf((n_0), (j_0)));
    bool _S281 = !_S280;
    bool _S282;
    if(_S281)
    {
        _S282 = true;
    }
    else
    {
        LightNode _S283 = (fcptLightBounds((n_0)));
        float _S284 = importance(_S283, origin_3, smooth_n_1);
        _S282 = !(_S284 > 0.0f);
    }
    if(_S282)
    {
        _S282 = true;
    }
    else
    {
        bool _S285 = (dot_0(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S285)
        {
            _S282 = !((dot_0(smooth_n_1, light_point_0 - origin_3)) > 0.0f);
        }
        else
        {
            _S282 = false;
        }
    }
    if(_S282)
    {
        return 0.0f;
    }
    uint4  _S286 = (fcptLightNode((n_0)));
    bool _S287 = (_S286.x) == 2U;
    if(_S287)
    {
        uint _S288 = _S286.y;
        FKLight _S289 = (fcptLight((_S288)));
        FKLight _S290 = (fcptLight((_S288)));
        float _S291 = sphereDensity(_S289.position, _S290.variance, start_5);
        return probability_1 * _S291;
    }
    uint _S292 = _S286.y;
    uint _S293 = (fcptTriangleOffset((_S292)));
    Matrix<float, 3, 3>  _S294 = (fcptWorldTriangle((_S292), (_S293 + _S286.z)));
    float _S295 = solidAngle(probability_1, cross_0(_S294.rows[int(1)] - _S294.rows[int(0)], _S294.rows[int(2)] - _S294.rows[int(0)]), light_point_0 - start_5);
    return _S295;
}

struct SkySample
{
    float3  dir;
    float3  radiance;
    float3  color;
    uint random_state;
};

struct Facets
{
    float3  h;
    float3  coat_h;
};

struct Random
{
    uint state;
    float value;
};

__device__ uint2  noiseOffset(uint k_0)
{
    uint2  _S296 = make_uint2 (k_0 * 3242174889U, k_0 * 2447445414U) >> make_uint2 (16U);
    uint _S297 = (fkBlueNoiseSize());
    return (_S296 * make_uint2 (_S297)) >> make_uint2 (16U);
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S298 = hash(index_0);
    uint _S299 = hash(seed_3 ^ _S298);
    return _S299;
}

static __device__ Random Random_x24init_0(uint state_0, float value_0)
{
    Random _S300;
    (&_S300)->state = state_0;
    (&_S300)->value = value_0;
    return _S300;
}

__device__ Random pcg(uint state_1)
{
    uint _S301 = hash(state_1);
    float value_1 = float(_S301 >> int(8)) * 5.9604644775390625e-08f;
    return Random_x24init_0(_S301, value_1);
}

__device__ __noinline__ Random draw(uint address_0, uint variable_0)
{
    uint _S302 = address_0 >> 22U;
    uint _S303 = _S302 / 32U;
    uint2  _S304 = make_uint2 (address_0 & 2047U, (address_0 >> 11U) & 2047U);
    uint _S305 = variable_0 & 2147483647U;
    uint2  _S306 = noiseOffset(_S305);
    uint2  _S307 = _S304 + _S306;
    uint2  _S308 = noiseOffset(4096U + _S303);
    uint2  _S309 = _S307 + _S308;
    uint _S310 = (fkBlueNoiseSize());
    uint2  _S311 = _S309 & make_uint2 (_S310 - 1U);
    uint _S312 = (fkBlueNoise((_S311.x), (_S311.y), ((_S302 + ((_S303 * 2654435769U) >> 27U)) % 32U)));
    bool _S313 = (variable_0 & 2147483648U) != 0U;
    uint _S314 = stream(address_0, _S305);
    Random _S315 = pcg(_S314);
    float _S316;
    if(_S312 == 4294967295U)
    {
        if(_S313)
        {
            Random _S317 = pcg(_S315.state);
            _S316 = _S317.value;
        }
        else
        {
            _S316 = _S315.value;
        }
    }
    else
    {
        uint _S318;
        if(_S313)
        {
            _S318 = _S312 >> 16U;
        }
        else
        {
            _S318 = _S312 & 65535U;
        }
        _S316 = (float(_S318) + 0.5f) / 6.5536e+04f;
    }
    return Random_x24init_0(address_0, _S316);
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
    uint2  _S319 = (fcptEnvironmentCdfSize());
    uint2  _S320 = _S319 - make_uint2 (1U, 0U);
    float2  _S321 = make_float2 ((F32_atan2((- dir_2.y), (dir_2.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_1(dir_2.z, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S322 = make_float2 ((float)_S320.x, (float)_S320.y);
    float2  _S323 = _S321 * _S322;
    uint2  _S324 = make_uint2 ((uint)_S323.x, (uint)_S323.y);
    uint2  _S325 = min_0(_S324, _S320 - make_uint2 (1U));
    float4  _S326 = (fcptEnvironmentCdf((_S325)));
    float _S327 = _S326.y;
    uint _S328 = _S320.x;
    float4  _S329 = (fcptEnvironmentCdf((make_uint2 (_S328, _S325.y))));
    float _S330 = _S327 * _S329.y;
    return _S330 * float(_S328 * _S320.y) / (19.73921012878417969f * length_1(float2 {dir_2.x, dir_2.y}));
}

__device__ float upsample(float3  rgb_0, float wavelength_0)
{
    float _S331 = dot_0(make_float3 (-0.08011700212955475f, 1.08901798725128174f, -0.00889899954199791f), rgb_0);
    float _S332 = dot_0(make_float3 (0.12177000194787979f, -1.22903203964233398f, 1.10724997520446777f), rgb_0);
    float _S333 = dot_0(make_float3 (1.17252397537231445f, -1.21603405475616455f, 0.04350199922919273f), rgb_0);
    float3  _S334 = make_float3 (_S331, _S332, _S333);
    float _S335 = (wavelength_0 - 0.44999998807907104f) / 0.02999999932944775f;
    float _S336 = (wavelength_0 - 0.63999998569488525f) / 0.03999999910593033f;
    return _S331 + _S332 * (F32_exp((-0.5f * _S335 * _S335))) + _S333 * (F32_exp((-0.5f * _S336 * _S336)));
}

__device__ BSDFMaterial atWavelength(BSDFMaterial material_0, float wavelength_1)
{
    BSDFMaterial at_0 = material_0;
    float _S337 = upsample(material_0.albedo, wavelength_1);
    float3  _S338 = make_float3 (_S337);
    (&at_0)->albedo = _S338;
    float _S339 = upsample(material_0.emissive, wavelength_1);
    float3  _S340 = make_float3 (_S339);
    (&at_0)->emissive = _S340;
    float _S341 = upsample(material_0.absorption, wavelength_1);
    float3  _S342 = make_float3 (_S341);
    (&at_0)->absorption = _S342;
    float _S343 = upsample(material_0.specular_tint, wavelength_1);
    float3  _S344 = make_float3 (_S343);
    (&at_0)->specular_tint = _S344;
    float _S345 = upsample(material_0.translucent, wavelength_1);
    float3  _S346 = make_float3 (_S345);
    (&at_0)->translucent = _S346;
    float _S347 = upsample(material_0.sheen, wavelength_1);
    float3  _S348 = make_float3 (_S347);
    (&at_0)->sheen = _S348;
    float _S349 = upsample(material_0.coat_tint, wavelength_1);
    float3  _S350 = make_float3 (_S349);
    (&at_0)->coat_tint = _S350;
    return at_0;
}

__device__ BSDFMaterial pathMaterial(BSDFMaterial material_1, float wavelength_2)
{
    BSDFMaterial _S351;
    if(wavelength_2 > 0.0f)
    {
        BSDFMaterial _S352 = atWavelength(material_1, wavelength_2);
        _S351 = _S352;
    }
    else
    {
        _S351 = material_1;
    }
    return _S351;
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    float _S353;
    if(e_1 > 0.0f)
    {
        _S353 = 1.0f;
    }
    else
    {
        if(e_1 < 0.0f)
        {
            _S353 = -1.0f;
        }
        else
        {
            _S353 = 0.0f;
        }
    }
    return _S353;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S354;
    (&_S354)->tangent = tangent_0;
    (&_S354)->alphas = alphas_0;
    return _S354;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S355 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S355)
    {
        float3  _S356 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S356;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S357 = cross_0(n_1, a_2);
    float3  _S358 = ((((_S357)) * make_float3(rnorm3df(((_S357)).x, ((_S357)).y, ((_S357)).z))));
    float3  _S359 = cross_0(n_1, _S358);
    return make_float3 (v_0.x) * _S358 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S359;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_2, float3  n_i_0)
{
    float _S360 = material_2.roughness;
    float _S361 = _S360 * _S360;
    bool _S362 = (material_2.anisotropy) == 0.0f;
    bool _S363;
    if(_S362)
    {
        _S363 = true;
    }
    else
    {
        _S363 = !(_S361 > 0.0f);
    }
    if(_S363)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S364 = material_2.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_2.tangent));
    float3  _S365 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S366 = (dot_0(_S364, _S364)) > 0.0f;
    float3  _S367 = _slang_select(_S366, _S364,_S365);
    float3  _S368 = ((((_S367)) * make_float3(rnorm3df(((_S367)).x, ((_S367)).y, ((_S367)).z))));
    float _S369 = 6.28318548202514648f * material_2.anisotropic_rotation;
    float _S370 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_2.anisotropy))))));
    float _S371 = 1.0f / _S370;
    bool _S372 = (material_2.anisotropy) < 0.0f;
    float _S373 = _slang_select(_S372, _S371,_S370);
    return AnisotropicFrame_x24init_0(_S368 * make_float3 ((F32_cos((_S369)))) + cross_0(n_i_0, _S368) * make_float3 ((F32_sin((_S369)))), make_float2 (_S361 / _S373, _S361 * _S373));
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S374;
    (&_S374)->on = on_0;
    (&_S374)->albedo = albedo_0;
    return _S374;
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
__device__ __forceinline__ SheenProfile sheenProfile(float3  v_1, float3  n_i_1, BSDFMaterial material_3)
{
    SheenProfile _S375 = SheenProfile_x24init_0(false, 0.0f);
    float _S376 = rgb_to_greyscale(material_3.sheen);
    bool _S377 = _S376 > 0.0f;
    SheenProfile profile_0;
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
            SheenProfile _S393 = SheenProfile_x24init_0(true, _S390 + (_S392 - _S390) * _S388);
            profile_0 = _S393;
        }
        else
        {
            uint _S394 = _S386 + 24U;
            float _S395 = SHEEN_ALBEDO_0[_S386] + (SHEEN_ALBEDO_0[_S394] - SHEEN_ALBEDO_0[_S386]) * _S387;
            uint _S396 = _S386 + 1U;
            float _S397 = SHEEN_ALBEDO_0[_S396] + (SHEEN_ALBEDO_0[_S394 + 1U] - SHEEN_ALBEDO_0[_S396]) * _S387;
            SheenProfile _S398 = SheenProfile_x24init_0(true, (F32_exp((_S395 + (_S397 - _S395) * _S388))));
            profile_0 = _S398;
        }
    }
    else
    {
        profile_0 = _S375;
    }
    return profile_0;
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
    CoatFrame _S400 = CoatFrame_x24init_0(make_float3 (0.0f), 0.0f, 0.0f);
    bool _S401 = (material_4.coat) > 0.0f;
    CoatFrame frame_0;
    if(_S401)
    {
        float3  _S402 = material_4.coat_normal;
        bool _S403 = (dot_0(_S402, _S402)) > 0.0f;
        float3  _S404 = material_4.coat_normal;
        float3  _S405 = ((((_S404)) * make_float3(rnorm3df(((_S404)).x, ((_S404)).y, ((_S404)).z))));
        float3  _S406 = _slang_select(_S403, _S405,n_2);
        float _S407 = sign_0(dot_0(_S406, n_2));
        float _S408 = material_4.coat_roughness;
        CoatFrame _S409 = CoatFrame_x24init_0(_S406 * make_float3 (_S407), _S408 * _S408, (F32_max((material_4.coat_ior), (1.00999999046325684f))));
        frame_0 = _S409;
    }
    else
    {
        frame_0 = _S400;
    }
    return frame_0;
}

__device__ __forceinline__ float3  coatSeries(CoatFrame coat_frame_0, BSDFMaterial material_5)
{
    float3  _S410 = make_float3 (0.0f);
    bool _S411 = (coat_frame_0.ior) > 0.0f;
    float3  series_0;
    if(_S411)
    {
        float _S412 = coat_frame_0.ior * coat_frame_0.ior;
        float _S413 = _S412 * _S412;
        float _S414 = coat_frame_0.ior - 1.0f;
        float _S415 = coat_frame_0.ior + 1.0f;
        float _S416 = _S412 - 1.0f;
        float _S417 = _S412 + 1.0f;
        float _S418 = _S413 - 1.0f;
        float _S419 = _S417 * _S418;
        float _S420 = 0.5f + _S414 * (3.0f * coat_frame_0.ior + 1.0f) / (6.0f * _S415 * _S415) + _S412 * _S416 * _S416 / (_S417 * _S417 * _S417) * (F32_log((_S414 / _S415))) - 2.0f * _S412 * coat_frame_0.ior * (_S412 + 2.0f * coat_frame_0.ior - 1.0f) / _S419 + 8.0f * _S413 * (_S413 + 1.0f) / (_S419 * _S418) * (F32_log((coat_frame_0.ior)));
        float _S421 = 1.0f - (1.0f - _S420) / _S412;
        float3  _S422 = material_5.coat_tint;
        float3  _S423 = _S422 * _S422 * make_float3 (1.0f - _S421) / (make_float3 (1.0f) - material_5.albedo * make_float3 (_S421));
        series_0 = _S423;
    }
    else
    {
        series_0 = _S410;
    }
    return series_0;
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
    float3  coat;
    float p_coat;
};

static __device__ float3  min_1(float3  x_14, float3  y_4)
{
    float3  result_5;
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
        *_slang_vector_get_element_ptr(&result_5, i_5) = (F32_min((_slang_vector_get_element(x_14, i_5)), (_slang_vector_get_element(y_4, i_5))));
        i_5 = i_5 + int(1);
    }
    return result_5;
}

static __device__ float3  refract_0(float3  i_6, float3  n_3, float eta_0)
{
    float _S424 = dot_0(n_3, i_6);
    float _S425 = 1.0f - eta_0 * eta_0 * (1.0f - _S424 * _S424);
    if(_S425 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_6 - make_float3 (eta_0 * _S424 + (F32_sqrt((_S425)))) * n_3;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S426 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S427 = eta_i_0 / eta_o_0 * _S426;
    bool _S428 = _S427 < 1.0f;
    float kr_0;
    if(_S428)
    {
        float _S429 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S427 * _S427))))));
        bool _S430 = eta_i_0 == eta_o_0;
        float _S431 = _slang_select(_S430, cos_theta_0,_S429);
        float _S432 = eta_o_0 * cos_theta_0;
        float _S433 = eta_i_0 * _S431;
        float _S434 = (_S432 - _S433) / (_S432 + _S433);
        float _S435 = eta_i_0 * cos_theta_0;
        float _S436 = eta_o_0 * _S431;
        float _S437 = (_S435 - _S436) / (_S435 + _S436);
        float _S438 = (_S434 * _S434 + _S437 * _S437) / 2.0f;
        kr_0 = _S438;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

static __device__ float3  reflect_0(float3  i_7, float3  n_4)
{
    return i_7 - make_float3 (2.0f * dot_0(n_4, i_7)) * n_4;
}

__device__ float smithG1(float alpha_1, float n_dot_x_0)
{
    float _S439 = alpha_1 * alpha_1;
    float _S440 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S439 + (1.0f - _S439) * n_dot_x_0 * n_dot_x_0))));
    bool _S441 = alpha_1 > 0.0f;
    float _S442 = _slang_select(_S441, _S440,1.0f);
    return _S442;
}

__device__ __forceinline__ float coatFresnel(float3  in_dir_0, float3  v_2, float3  coat_h_0, CoatFrame coat_frame_1, float eta_i_1, bool behind_0)
{
    float _S443 = dot_0(coat_frame_1.normal, reflect_0(in_dir_0, coat_h_0));
    float _S444 = (F32_abs((dot_0(v_2, coat_h_0))));
    float _S445 = eta_i_1 / coat_frame_1.ior * (F32_sqrt(((F32_max((1.0f - _S444 * _S444), (0.0f))))));
    float _S446 = (F32_sqrt(((F32_max((1.0f - _S445 * _S445), (0.0f))))));
    float _S447 = _slang_select(behind_0, _S446,_S444);
    float _S448 = _slang_select(behind_0, coat_frame_1.ior,1.0f);
    float _S449 = _slang_select(behind_0, 1.0f,coat_frame_1.ior);
    float _S450 = fresnel(_S447, _S448, _S449);
    float _S451 = smithG1(coat_frame_1.alpha, _S443);
    float _S452 = _S450 * _S451;
    bool _S453 = _S443 > 0.0f;
    float _S454 = _slang_select(_S453, _S452,0.0f);
    return _S454;
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

static __device__ Weights Weights_x24init_0(float v_dot_h_0, float3  refracted_1, float3  F_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float p_sheen_velvet_0, float p_toon_0, float3  sheen_0, float3  toon_0, float3  coat_0, float p_coat_0)
{
    Weights _S455;
    (&_S455)->v_dot_h = v_dot_h_0;
    (&_S455)->refracted = refracted_1;
    (&_S455)->F = F_0;
    (&_S455)->reflect_weight = reflect_weight_0;
    (&_S455)->diffuse_weight = diffuse_weight_0;
    (&_S455)->refract_weight = refract_weight_0;
    (&_S455)->p_diffuse = p_diffuse_0;
    (&_S455)->p_reflect = p_reflect_0;
    (&_S455)->p_refract = p_refract_0;
    (&_S455)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S455)->p_toon = p_toon_0;
    (&_S455)->sheen = sheen_0;
    (&_S455)->toon = toon_0;
    (&_S455)->coat = coat_0;
    (&_S455)->p_coat = p_coat_0;
    return _S455;
}

static __device__ bool any_1(bool3  x_15)
{
    bool result_6 = false;
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
        if(result_6)
        {
            result_6 = true;
        }
        else
        {
            result_6 = (bool((_slang_vector_get_element(x_15, i_8))));
        }
        i_8 = i_8 + int(1);
    }
    return result_6;
}

__device__ __forceinline__ Weights lobeWeights(float3  in_dir_1, float3  v_3, float3  n_i_2, float3  h_0, float3  coat_h_1, float3  ggx_n_0, float3  coat_n_0, AnisotropicFrame frame_1, SheenProfile sheen_profile_0, CoatFrame coat_frame_2, float3  coat_series_0, BSDFMaterial material_6, float eta_i_2, float eta_o_1)
{
    float _S456 = (F32_min(((F32_sqrt((material_6.specular_level))) * (F32_abs((eta_i_2 - eta_o_1))) / (eta_i_2 + eta_o_1)), (0.9999847412109375f)));
    float _S457 = _S456 * _S456;
    float _S458 = (1.0f + _S456) / (1.0f - _S456);
    float3  _S459 = make_float3 (1.0f);
    float3  _S460 = make_float3 (0.0f);
    float sheen_component_0;
    float3  sheen_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S461 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S462 = make_float3 (1.0f) - material_6.sheen * make_float3 (_S461);
        float _S463 = rgb_to_greyscale(material_6.sheen);
        float _S464 = _S463 * _S461;
        float3  _S465 = material_6.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S464;
        sheen_1 = _S465;
        scale_1 = _S462;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S460;
        scale_1 = _S459;
    }
    float _S466 = (F32_abs((material_6.toon.x)));
    bool _S467 = _S466 > 0.0f;
    float toon_component_0;
    float3  toon_1;
    if(_S467)
    {
        float _S468 = (F32_min((_S466), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S468);
        float _S469 = rgb_to_greyscale(material_6.albedo);
        float _S470 = _S468 * _S469;
        float3  _S471 = make_float3 (_S468) * material_6.albedo;
        toon_component_0 = _S470;
        toon_1 = _S471;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S460;
    }
    bool _S472 = (material_6.metallic) > 0.0f;
    float3  rebounce_0;
    if(_S472)
    {
        float _S473 = frame_1.alphas.x;
        float _S474 = (F32_sqrt(((F32_min((_S473), (frame_1.alphas.y))))));
        bool _S475 = _S473 > 0.0f;
        float _S476 = _slang_select(_S475, _S474,material_6.roughness);
        float _S477 = _S476 * _S476;
        float _S478 = (F32_pow((_S477), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S477) / (1.0f + 1.28094995021820068f * _S477);
        bool _S479 = _S477 > 0.0f;
        float _S480 = _slang_select(_S479, _S478,0.0f);
        float _S481 = clamp_1(dot_0(n_i_2, v_3), 0.0f, 1.0f);
        float _S482 = _S477 * _S476;
        float _S483 = (F32_min((1.00064504146575928f - _S476 * (0.00375499995425344f + _S481 * (-0.04133399948477745f + _S481 * (-0.90938502550125122f + _S481 * 0.35275399684906006f))) - _S477 * (0.27602800726890564f + _S481 * (1.27023398876190186f + _S481 * 0.04740000143647194f)) - _S482 * (0.31452900171279907f - _S481 * 0.34830701351165771f) + _S482 * _S476 * 0.27229699492454529f), (1.0f)));
        float3  _S484 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_6.albedo * make_float3 (_S480)), make_float3 (1.0f / (F32_max((_S483), (0.0000152587890625f)))));
        rebounce_0 = _S484;
    }
    else
    {
        rebounce_0 = _S459;
    }
    float _S485 = dot_0(h_0, v_3);
    float _S486 = eta_i_2 / eta_o_1;
    float3  _S487 = refract_0(in_dir_1, h_0, _S486);
    float3  _S488 = ((((_S487)) * make_float3(rnorm3df(((_S487)).x, ((_S487)).y, ((_S487)).z))));
    float _S489 = (F32_abs((_S485)));
    bool _S490 = eta_i_2 > eta_o_1;
    float _S491;
    if(_S490)
    {
        _S491 = _S458;
    }
    else
    {
        _S491 = 1.0f;
    }
    float _S492;
    if(_S490)
    {
        _S492 = 1.0f;
    }
    else
    {
        _S492 = _S458;
    }
    float _S493 = fresnel(_S489, _S491, _S492);
    float _S494 = eta_i_2 * eta_i_2;
    float _S495 = eta_o_1 * eta_o_1;
    bool _S496 = (_S494 * (1.0f - _S485 * _S485)) >= _S495;
    float3  _S497;
    if(_S496)
    {
        _S497 = _S459;
    }
    else
    {
        float3  _S498 = material_6.specular_tint * make_float3 (_S457);
        _S497 = _S498 + (make_float3 (1.0f) - _S498) * make_float3 (_S493 - _S457) / make_float3 (1.0f - _S457);
    }
    bool _S499 = (dot_0(coat_h_1, coat_h_1)) > 0.0f;
    float3  coat_1;
    float3  up_0;
    float3  through_0;
    if(_S499)
    {
        float _S500 = coatFresnel(in_dir_1, v_3, coat_h_1, coat_frame_2, eta_i_2, _S490);
        float _S501 = material_6.coat * _S500;
        float3  _S502 = material_6.coat_tint;
        float3  _S503 = _S502 * _S502;
        float3  _S504 = _slang_select(_S490, _S503,_S459);
        float3  _S505 = make_float3 (_S501) * _S504;
        float _S506 = 1.0f - _S500;
        bool _S507 = !_S490;
        float3  _S508 = _slang_select(_S507, coat_series_0,_S459);
        float3  _S509 = mix_0(_S459, make_float3 (_S506) * _S508, material_6.coat);
        float3  _S510 = mix_0(_S459, make_float3 (_S506) * material_6.coat_tint, material_6.coat);
        coat_1 = _S505;
        up_0 = _S509;
        through_0 = _S510;
    }
    else
    {
        coat_1 = _S460;
        up_0 = _S459;
        through_0 = _S459;
    }
    float3  _S511 = scale_1 * coat_1;
    float _S512 = rgb_to_greyscale(_S511);
    float3  _S513 = material_6.albedo * rebounce_0;
    float3  _S514 = mix_0(_S497, _S513, material_6.metallic);
    float3  F_1 = _S514 * scale_1 * up_0;
    float _S515 = rgb_to_greyscale(F_1);
    float _S516 = 1.0f - material_6.metallic;
    float _S517 = (1.0f - material_6.transmission) * _S516;
    float3  _S518 = make_float3 (1.0f) - _S497;
    float3  _S519 = make_float3 (_S517) * _S518 * scale_1 * up_0;
    float _S520 = material_6.transmission * _S516;
    float3  _S521 = make_float3 (_S520) * _S518 * scale_1 * through_0;
    float _S522 = (F32_max((_S515), (0.0f)));
    float _S523 = rgb_to_greyscale(_S519);
    float _S524 = (F32_max((_S523), (0.0f)));
    float _S525 = rgb_to_greyscale(_S521);
    float _S526 = sign_0(length_0(_S488));
    float _S527 = (F32_max((_S525 * _S526), (0.0f)));
    float _S528 = _S522 + _S524 + _S527 + toon_component_0 + _S512;
    float _S529 = (F32_min((sheen_component_0), (1.0f)));
    bool _S530 = sheen_component_0 > 0.0f;
    bool _S531;
    if(_S530)
    {
        _S531 = !(_S528 > 0.0f);
    }
    else
    {
        _S531 = false;
    }
    float _S532 = _slang_select(_S531, 1.0f,_S529);
    float _S533 = (1.0f - _S532) / (F32_max((_S528), (0.0000152587890625f)));
    float _S534 = _S524 * _S533;
    float _S535 = _S522 * _S533;
    float _S536 = _S527 * _S533;
    Weights _S537 = Weights_x24init_0(_S485, _S488, F_1, 1.0f, _S519, _S521, _S534, _S535, _S536, _S532, toon_component_0 * _S533, sheen_1, toon_1, _S511, _S512 * _S533);
    bool _S538 = any_1(ggx_n_0 != h_0);
    Weights leaving_0;
    if(_S538)
    {
        float _S539 = dot_0(ggx_n_0, v_3);
        float _S540 = eta_i_2 / eta_o_1;
        float3  _S541 = refract_0(in_dir_1, ggx_n_0, _S540);
        float3  _S542 = ((((_S541)) * make_float3(rnorm3df(((_S541)).x, ((_S541)).y, ((_S541)).z))));
        float _S543 = (F32_abs((_S539)));
        if(_S490)
        {
            _S491 = _S458;
        }
        else
        {
            _S491 = 1.0f;
        }
        if(_S490)
        {
            _S492 = 1.0f;
        }
        else
        {
            _S492 = _S458;
        }
        float _S544 = fresnel(_S543, _S491, _S492);
        bool _S545 = (_S494 * (1.0f - _S539 * _S539)) >= _S495;
        if(_S545)
        {
            _S497 = _S459;
        }
        else
        {
            float3  _S546 = material_6.specular_tint * make_float3 (_S457);
            _S497 = _S546 + (make_float3 (1.0f) - _S546) * make_float3 (_S544 - _S457) / make_float3 (1.0f - _S457);
        }
        if(_S499)
        {
            float _S547 = coatFresnel(in_dir_1, v_3, coat_h_1, coat_frame_2, eta_i_2, _S490);
            float _S548 = material_6.coat * _S547;
            float3  _S549 = material_6.coat_tint;
            float3  _S550 = _S549 * _S549;
            float3  _S551 = _slang_select(_S490, _S550,_S459);
            float3  _S552 = make_float3 (_S548) * _S551;
            float _S553 = 1.0f - _S547;
            bool _S554 = !_S490;
            float3  _S555 = _slang_select(_S554, coat_series_0,_S459);
            float3  _S556 = mix_0(_S459, make_float3 (_S553) * _S555, material_6.coat);
            float3  _S557 = mix_0(_S459, make_float3 (_S553) * material_6.coat_tint, material_6.coat);
            coat_1 = _S552;
            up_0 = _S556;
            through_0 = _S557;
        }
        else
        {
            coat_1 = _S460;
            up_0 = _S459;
            through_0 = _S459;
        }
        float3  _S558 = scale_1 * coat_1;
        float _S559 = rgb_to_greyscale(_S558);
        float3  _S560 = mix_0(_S497, _S513, material_6.metallic);
        float3  F_2 = _S560 * scale_1 * up_0;
        float _S561 = rgb_to_greyscale(F_2);
        float3  _S562 = make_float3 (1.0f) - _S497;
        float3  _S563 = make_float3 (_S517) * _S562 * scale_1 * up_0;
        float3  _S564 = make_float3 (_S520) * _S562 * scale_1 * through_0;
        float _S565 = (F32_max((_S561), (0.0f)));
        float _S566 = rgb_to_greyscale(_S563);
        float _S567 = (F32_max((_S566), (0.0f)));
        float _S568 = rgb_to_greyscale(_S564);
        float _S569 = sign_0(length_0(_S542));
        float _S570 = (F32_max((_S568 * _S569), (0.0f)));
        float _S571 = _S565 + _S567 + _S570 + toon_component_0 + _S559;
        if(_S530)
        {
            _S531 = !(_S571 > 0.0f);
        }
        else
        {
            _S531 = false;
        }
        float _S572 = _slang_select(_S531, 1.0f,_S529);
        float _S573 = (1.0f - _S572) / (F32_max((_S571), (0.0000152587890625f)));
        float _S574 = _S567 * _S573;
        float _S575 = _S565 * _S573;
        float _S576 = _S570 * _S573;
        Weights _S577 = Weights_x24init_0(_S539, _S542, F_2, 1.0f, _S563, _S564, _S574, _S575, _S576, _S572, toon_component_0 * _S573, sheen_1, toon_1, _S558, _S559 * _S573);
        leaving_0 = _S577;
    }
    else
    {
        leaving_0 = _S537;
    }
    bool _S578 = any_1(coat_n_0 != coat_h_1);
    Weights coated_0;
    if(_S578)
    {
        float _S579 = eta_i_2 / eta_o_1;
        float3  _S580 = refract_0(in_dir_1, h_0, _S579);
        float3  _S581 = ((((_S580)) * make_float3(rnorm3df(((_S580)).x, ((_S580)).y, ((_S580)).z))));
        if(_S490)
        {
            sheen_component_0 = _S458;
        }
        else
        {
            sheen_component_0 = 1.0f;
        }
        if(_S490)
        {
            _S491 = 1.0f;
        }
        else
        {
            _S491 = _S458;
        }
        float _S582 = fresnel(_S489, sheen_component_0, _S491);
        if(_S496)
        {
            rebounce_0 = _S459;
        }
        else
        {
            float3  _S583 = material_6.specular_tint * make_float3 (_S457);
            rebounce_0 = _S583 + (make_float3 (1.0f) - _S583) * make_float3 (_S582 - _S457) / make_float3 (1.0f - _S457);
        }
        bool _S584 = (dot_0(coat_n_0, coat_n_0)) > 0.0f;
        if(_S584)
        {
            float _S585 = coatFresnel(in_dir_1, v_3, coat_n_0, coat_frame_2, eta_i_2, _S490);
            float _S586 = material_6.coat * _S585;
            float3  _S587 = material_6.coat_tint;
            float3  _S588 = _S587 * _S587;
            float3  _S589 = _slang_select(_S490, _S588,_S459);
            float3  _S590 = make_float3 (_S586) * _S589;
            float _S591 = 1.0f - _S585;
            bool _S592 = !_S490;
            float3  _S593 = _slang_select(_S592, coat_series_0,_S459);
            float3  _S594 = mix_0(_S459, make_float3 (_S591) * _S593, material_6.coat);
            float3  _S595 = mix_0(_S459, make_float3 (_S591) * material_6.coat_tint, material_6.coat);
            coat_1 = _S590;
            up_0 = _S594;
            through_0 = _S595;
        }
        else
        {
            coat_1 = _S460;
            up_0 = _S459;
            through_0 = _S459;
        }
        float3  _S596 = scale_1 * coat_1;
        float _S597 = rgb_to_greyscale(_S596);
        float3  _S598 = mix_0(rebounce_0, _S513, material_6.metallic);
        float3  F_3 = _S598 * scale_1 * up_0;
        float _S599 = rgb_to_greyscale(F_3);
        float3  _S600 = make_float3 (1.0f) - rebounce_0;
        float3  _S601 = make_float3 (_S517) * _S600 * scale_1 * up_0;
        float3  _S602 = make_float3 (_S520) * _S600 * scale_1 * through_0;
        float _S603 = (F32_max((_S599), (0.0f)));
        float _S604 = rgb_to_greyscale(_S601);
        float _S605 = (F32_max((_S604), (0.0f)));
        float _S606 = rgb_to_greyscale(_S602);
        float _S607 = sign_0(length_0(_S581));
        float _S608 = (F32_max((_S606 * _S607), (0.0f)));
        float _S609 = _S603 + _S605 + _S608 + toon_component_0 + _S597;
        if(_S530)
        {
            _S531 = !(_S609 > 0.0f);
        }
        else
        {
            _S531 = false;
        }
        float _S610 = _slang_select(_S531, 1.0f,_S529);
        float _S611 = (1.0f - _S610) / (F32_max((_S609), (0.0000152587890625f)));
        float _S612 = _S605 * _S611;
        float _S613 = _S603 * _S611;
        float _S614 = _S608 * _S611;
        Weights _S615 = Weights_x24init_0(_S485, _S581, F_3, 1.0f, _S601, _S602, _S612, _S613, _S614, _S610, toon_component_0 * _S611, sheen_1, toon_1, _S596, _S597 * _S611);
        coated_0 = _S615;
    }
    else
    {
        coated_0 = _S537;
    }
    return Weights_x24init_0(leaving_0.v_dot_h, leaving_0.refracted, leaving_0.F, leaving_0.reflect_weight, _S537.diffuse_weight, leaving_0.refract_weight, _S537.p_diffuse, leaving_0.p_reflect, leaving_0.p_refract, _S537.p_sheen_velvet, _S537.p_toon, sheen_1, toon_1, coated_0.coat, coated_0.p_coat);
}

__device__ float translucentShare(BSDFMaterial material_7)
{
    float _S616 = rgb_to_greyscale(material_7.translucent);
    float _S617 = rgb_to_greyscale(material_7.albedo);
    float _S618 = _S616 / (_S617 + _S616);
    bool _S619 = _S616 > 0.0f;
    float _S620 = _slang_select(_S619, _S618,0.0f);
    return _S620;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float n_i_dot_v_0, BSDFMaterial material_8, Weights w_0)
{
    float _S621 = translucentShare(material_8);
    float _S622 = w_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S623 = w_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S624 = 1.0f - _S621;
    bool _S625 = n_i_dot_l_0 < 0.0f;
    float _S626 = _slang_select(_S625, _S621,_S624);
    float _S627 = _S623 * _S626;
    bool _S628 = _S621 > 0.0f;
    float _S629 = _slang_select(_S628, _S627,_S622);
    bool _S630 = n_i_dot_v_0 > 0.0f;
    float _S631 = _slang_select(_S630, _S629,0.0f);
    return _S631;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_3, BSDFMaterial material_9, Weights w_1)
{
    float _S632 = translucentShare(material_9);
    bool _S633 = (dot_0(n_i_3, l_0)) < 0.0f;
    float3  _S634 = _slang_select(_S633, material_9.translucent,material_9.albedo);
    float _S635 = 1.0f - _S632;
    float _S636 = _slang_select(_S633, _S632,_S635);
    float3  _S637 = _S634 / make_float3 (_S636);
    bool _S638 = _S632 > 0.0f;
    float3  _S639 = _slang_select(_S638, _S637,material_9.albedo);
    return w_1.diffuse_weight * _S639 / make_float3 (w_1.p_diffuse);
}

__device__ float trowbridgeReitz(float alpha_2, float n_dot_h_0)
{
    float _S640 = alpha_2 * alpha_2;
    float _S641 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S640 * n_dot_h_0 * n_dot_h_0;
    return _S640 / (F32_max((3.14159274101257324f * _S641 * _S641), (1.17549435082228751e-38f)));
}

__device__ float3  anisotropicLocal(float3  w_2, float3  t_12, float3  n_5)
{
    return make_float3 (dot_0(w_2, t_12), dot_0(w_2, cross_0(n_5, t_12)), dot_0(w_2, n_5));
}

__device__ float anisotropicG1(float3  w_3, float2  alphas_1)
{
    float _S642 = (F32_max((w_3.z), (0.0f)));
    return 2.0f * _S642 / (_S642 + length_0(make_float3 (alphas_1.x * w_3.x, alphas_1.y * w_3.y, _S642)));
}

__device__ float anisotropicD(float3  h_1, float2  alphas_2)
{
    float _S643 = alphas_2.x;
    float _S644 = h_1.x / _S643;
    float _S645 = alphas_2.y;
    float _S646 = h_1.y / _S645;
    float _S647 = h_1.z;
    float _S648 = _S644 * _S644 + _S646 * _S646 + _S647 * _S647;
    return 1.0f / (F32_max((3.14159274101257324f * _S643 * _S645 * _S648 * _S648), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float3  v_4, float3  h_2, float3  n_i_4, float n_i_dot_v_1, float alpha_3, AnisotropicFrame frame_2, float v_dot_h_1)
{
    float _S649 = dot_0(n_i_4, h_2);
    float _S650 = smithG1(alpha_3, n_i_dot_v_1);
    float _S651 = _S650 * v_dot_h_1;
    float _S652 = trowbridgeReitz(alpha_3, _S649);
    float _S653 = _S651 * _S652 / n_i_dot_v_1;
    bool _S654 = alpha_3 > 0.0f;
    bool _S655;
    if(_S654)
    {
        _S655 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S655 = false;
    }
    if(_S655)
    {
        _S655 = _S649 > 0.0f;
    }
    else
    {
        _S655 = false;
    }
    if(_S655)
    {
        _S655 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S655 = false;
    }
    float _S656 = _slang_select(_S655, _S653,0.0f);
    bool _S657 = (frame_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S657)
    {
        float3  _S658 = anisotropicLocal(v_4, frame_2.tangent, n_i_4);
        float _S659 = anisotropicG1(_S658, frame_2.alphas);
        float3  _S660 = anisotropicLocal(h_2, frame_2.tangent, n_i_4);
        float _S661 = anisotropicD(_S660, frame_2.alphas);
        float _S662 = _S659 * _S661;
        float _S663 = _S662 * v_dot_h_1 / n_i_dot_v_1;
        bool _S664 = v_dot_h_1 > 0.0f;
        if(_S664)
        {
            _S655 = _S649 > 0.0f;
        }
        else
        {
            _S655 = false;
        }
        if(_S655)
        {
            _S655 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S655 = false;
        }
        float _S665 = _slang_select(_S655, _S663,0.0f);
        pdf_h_0 = _S665;
    }
    else
    {
        pdf_h_0 = _S656;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float l_dot_h_0, float pdf_h_1, Weights w_4, float eta_i_3, float eta_o_2)
{
    float _S666 = eta_i_3 * w_4.v_dot_h + eta_o_2 * l_dot_h_0;
    float _S667 = w_4.p_refract * pdf_h_1 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S666 * _S666);
    bool _S668 = eta_i_3 != eta_o_2;
    bool _S669;
    if(_S668)
    {
        _S669 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S669 = false;
    }
    float _S670 = _slang_select(_S669, _S667,0.0f);
    return _S670;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_5, float alpha_4, AnisotropicFrame frame_3, BSDFMaterial material_10, Weights w_5)
{
    float _S671 = - dot_0(n_i_5, l_1);
    float _S672 = smithG1(alpha_4, (F32_max((_S671), (0.0f))));
    bool _S673 = (frame_3.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S673)
    {
        float3  _S674 = negate_0(n_i_5);
        float3  _S675 = anisotropicLocal(l_1, frame_3.tangent, _S674);
        float _S676 = anisotropicG1(_S675, frame_3.alphas);
        G1_l_0 = _S676;
    }
    else
    {
        G1_l_0 = _S672;
    }
    return w_5.refract_weight * make_float3 (G1_l_0) * material_10.albedo / make_float3 (w_5.p_refract);
}

__device__ __forceinline__ float reflectPDF(float pdf_h_2, Weights w_6)
{
    float _S677 = w_6.p_reflect * pdf_h_2 / (4.0f * w_6.v_dot_h);
    bool _S678 = pdf_h_2 > 0.0f;
    float _S679 = _slang_select(_S678, _S677,0.0f);
    return _S679;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_2, float3  n_i_6, float alpha_5, AnisotropicFrame frame_4, Weights w_7)
{
    float _S680 = dot_0(n_i_6, l_2);
    float _S681 = smithG1(alpha_5, (F32_max((_S680), (0.0f))));
    bool _S682 = (frame_4.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S682)
    {
        float3  _S683 = anisotropicLocal(l_2, frame_4.tangent, n_i_6);
        float _S684 = anisotropicG1(_S683, frame_4.alphas);
        G1_l_1 = _S684;
    }
    else
    {
        G1_l_1 = _S681;
    }
    return make_float3 (w_7.reflect_weight * G1_l_1) * w_7.F / make_float3 (w_7.p_reflect);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_1, float n_i_dot_v_2, Weights w_8)
{
    float _S685 = w_8.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S686 = n_i_dot_l_1 > 0.0f;
    bool _S687;
    if(_S686)
    {
        _S687 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S687 = false;
    }
    float _S688 = _slang_select(_S687, _S685,0.0f);
    return _S688;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_3, float3  v_5, float3  n_i_7, BSDFMaterial material_11, Weights w_9)
{
    float3  _S689 = l_3 + v_5;
    float3  _S690 = ((((_S689)) * make_float3(rnorm3df(((_S689)).x, ((_S689)).y, ((_S689)).z))));
    float _S691 = dot_0(n_i_7, _S690);
    float _S692 = (F32_max((dot_0(n_i_7, l_3)), (0.0f)));
    float _S693 = (F32_max((dot_0(n_i_7, v_5)), (0.0f)));
    float _S694 = 1.0f / (F32_max((material_11.sheen_roughness), (0.05000000074505806f)));
    float _S695 = 1.0f - _S691 * _S691;
    float _S696 = (2.0f + _S694) * (F32_pow(((F32_max((_S695), (0.0f)))), (0.5f * _S694))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S692 + _S693 - _S692 * _S693)), (0.0000152587890625f)));
    bool _S697 = (material_11.velvet) > 0.0f;
    float f_1;
    if(_S697)
    {
        float _S698 = (F32_max((material_11.sheen_roughness), (0.00999999977648258f)));
        float _S699 = _S698 * _S698;
        float _S700 = (F32_max((_S695), (0.0000152587890625f)));
        float _S701 = (F32_exp((- _S691 * _S691 / (_S700 * _S699)))) / (3.14159274101257324f * _S699 * _S700 * _S700) * (F32_min((1.0f), (2.0f * _S691 * (F32_min((_S692), (_S693))) / (F32_max(((F32_abs((dot_0(_S690, v_5))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S692 * _S693), (0.0000152587890625f)));
        f_1 = _S701;
    }
    else
    {
        f_1 = _S696;
    }
    return w_9.sheen * make_float3 (f_1 * _S692 * 2.0f * 3.14159274101257324f / w_9.p_sheen_velvet);
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

__device__ __forceinline__ float toonP(float t_13, float a_3, float s_0)
{
    float _S702;
    if(t_13 < a_3)
    {
        _S702 = 1.0f;
    }
    else
    {
        _S702 = (F32_max((1.0f - (t_13 - a_3) / (F32_max((s_0), (0.0000152587890625f)))), (0.0f)));
    }
    return _S702;
}

__device__ __forceinline__ float toonIntegral(float t_14, float a_4, float s_1, bool glossy_0)
{
    float integral_0;
    if(glossy_0)
    {
        integral_0 = 1.0f - (F32_cos(((F32_min((t_14), (a_4))))));
    }
    else
    {
        float _S703 = (F32_sin(((F32_min((t_14), (a_4))))));
        integral_0 = _S703 * _S703 / 2.0f;
    }
    bool _S704 = t_14 > a_4;
    bool _S705;
    if(_S704)
    {
        _S705 = s_1 > 0.0f;
    }
    else
    {
        _S705 = false;
    }
    if(_S705)
    {
        float _S706;
        if(glossy_0)
        {
            float _S707 = (F32_cos((a_4)));
            float _S708 = (F32_cos((t_14)));
            _S706 = (1.0f + a_4 / s_1) * (_S707 - _S708) - ((F32_sin((t_14))) - t_14 * _S708 - ((F32_sin((a_4))) - a_4 * _S707)) / s_1;
        }
        else
        {
            float _S709 = 2.0f * a_4;
            float _S710 = (F32_cos((_S709)));
            float _S711 = 2.0f * t_14;
            float _S712 = (F32_cos((_S711)));
            _S706 = (1.0f + a_4 / s_1) * (_S710 - _S712) / 4.0f - ((F32_sin((_S711))) / 8.0f - t_14 * _S712 / 4.0f - ((F32_sin((_S709))) / 8.0f - a_4 * _S710 / 4.0f)) / s_1;
        }
        float integral_1 = integral_0 + _S706;
        integral_0 = integral_1;
    }
    return integral_0;
}

static __device__ ToonProfile ToonProfile_x24init_0(bool glossy_1, float a_5, float s_2, float b_1, float norm_0, float view_0, float3  axis_0)
{
    ToonProfile _S713;
    (&_S713)->glossy = glossy_1;
    (&_S713)->a = a_5;
    (&_S713)->s = s_2;
    (&_S713)->b = b_1;
    (&_S713)->norm = norm_0;
    (&_S713)->view = view_0;
    (&_S713)->axis = axis_0;
    return _S713;
}

__device__ __forceinline__ ToonProfile toonProfile(float3  v_6, float3  n_i_8, BSDFMaterial material_12)
{
    float _S714 = material_12.toon.x;
    bool _S715 = _S714 < 0.0f;
    float _S716 = clamp_1(material_12.toon.y / _S714, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S717 = clamp_1(material_12.toon.z / _S714, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S718 = (F32_min((_S716 + _S717), (1.57079637050628662f)));
    float _S719 = dot_0(n_i_8, v_6);
    float _S720 = toonP((F32_acos(((F32_min((_S719), (1.0f)))))), _S716, _S717);
    float3  _S721;
    if(_S715)
    {
        float3  _S722 = make_float3 (2.0f * _S719) * n_i_8 - v_6;
        float3  _S723 = ((((_S722)) * make_float3(rnorm3df(((_S722)).x, ((_S722)).y, ((_S722)).z))));
        _S721 = _S723;
    }
    else
    {
        _S721 = n_i_8;
    }
    float _S724 = toonIntegral(_S718, _S716, _S717, _S715);
    return ToonProfile_x24init_0(_S715, _S716, _S717, _S718, 6.28318548202514648f * _S724, _S720, _S721);
}

__device__ __forceinline__ float toonPDF(float3  l_4, float3  n_i_9, ToonProfile profile_1, Weights w_10)
{
    float _S725 = dot_0(n_i_9, l_4);
    float _S726 = dot_0(l_4, profile_1.axis);
    float _S727 = _slang_select(profile_1.glossy, _S726,_S725);
    float _S728 = (F32_acos((clamp_1(_S727, -1.0f, 1.0f))));
    float _S729 = toonP(_S728, profile_1.a, profile_1.s);
    float _S730 = w_10.p_toon * _S729;
    float _S731 = _slang_select(profile_1.glossy, 1.0f,_S725);
    float _S732 = _S730 * _S731 / profile_1.norm;
    bool _S733;
    if(profile_1.glossy)
    {
        _S733 = true;
    }
    else
    {
        _S733 = _S725 > 0.0f;
    }
    float _S734 = _slang_select(_S733, _S732,0.0f);
    return _S734;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_5, float3  n_i_10, ToonProfile profile_2, Weights w_11)
{
    float _S735 = (F32_max((dot_0(n_i_10, l_5)), (0.0f)));
    float _S736 = _slang_select(profile_2.glossy, _S735,profile_2.view);
    return w_11.toon * make_float3 (_S736) / make_float3 (w_11.p_toon);
}

__device__ __forceinline__ float coatPDF(float3  v_7, float3  coat_h_2, CoatFrame coat_frame_3, Weights w_12)
{
    float _S737 = dot_0(coat_frame_3.normal, v_7);
    float _S738 = smithG1(coat_frame_3.alpha, _S737);
    float _S739 = trowbridgeReitz(coat_frame_3.alpha, dot_0(coat_frame_3.normal, coat_h_2));
    float _S740 = _S738 * _S739 / (4.0f * _S737);
    bool _S741 = (coat_frame_3.alpha) > 0.0f;
    float _S742 = _slang_select(_S741, _S740,0.0f);
    return w_12.p_coat * _S742;
}

__device__ __forceinline__ float3  coatBSDF(Weights w_13)
{
    return w_13.coat / make_float3 (w_13.p_coat);
}

__device__ __forceinline__ void BSDF(float3  in_dir_2, float3  out_dir_0, float3  n_6, BSDFMaterial material_13, float eta_i_4, float eta_o_3, bool refracted_2, Facets facets_0, FixedArray<float3 , 6>  * throughputs_0, FixedArray<float, 6>  * pdfs_0)
{
    float3  _S743 = negate_0(in_dir_2);
    float _S744 = dot_0(n_6, _S743);
    float _S745 = sign_0(_S744);
    float3  _S746 = n_6 * make_float3 (_S745);
    float _S747 = dot_0(_S746, out_dir_0);
    float _S748 = material_13.roughness;
    float _S749 = _S748 * _S748;
    AnisotropicFrame _S750 = anisotropicFrame(material_13, _S746);
    SheenProfile _S751 = sheenProfile(_S743, _S746, material_13);
    CoatFrame _S752 = coatFrame(material_13, _S746);
    float3  _S753 = coatSeries(_S752, material_13);
    float _S754 = rgb_to_greyscale(material_13.translucent);
    bool _S755 = _S754 > 0.0f;
    bool _S756 = (dot_0(n_6, out_dir_0) * _S744) < 0.0f;
    bool _S757 = (F32_abs((material_13.toon.x))) > 0.0f;
    float3  _S758 = facets_0.coat_h;
    bool _S759 = (dot_0(_S758, _S758)) > 0.0f;
    bool _S760;
    if(_S755)
    {
        _S760 = _S756;
    }
    else
    {
        _S760 = false;
    }
    bool _S761 = _S760 == refracted_2;
    bool _S762 = !refracted_2;
    if(_S762)
    {
        _S760 = _S757;
    }
    else
    {
        _S760 = false;
    }
    bool _S763;
    if(_S762)
    {
        _S763 = _S759;
    }
    else
    {
        _S763 = false;
    }
    float3  _S764 = negate_0(make_float3 (eta_i_4) * _S743 + make_float3 (eta_o_3) * out_dir_0);
    float3  _S765 = ((((_S764)) * make_float3(rnorm3df(((_S764)).x, ((_S764)).y, ((_S764)).z))));
    float3  _S766 = _S743 + out_dir_0;
    float3  _S767 = ((((_S766)) * make_float3(rnorm3df(((_S766)).x, ((_S766)).y, ((_S766)).z))));
    float _S768 = sign_0(dot_0(_S765, _S746));
    float3  _S769 = _S765 * make_float3 (_S768);
    float3  _S770 = _slang_select(refracted_2, _S769,_S767);
    float3  _S771 = make_float3 (0.0f);
    float3  _S772 = ((((_S766)) * make_float3(rnorm3df(((_S766)).x, ((_S766)).y, ((_S766)).z))));
    float3  _S773 = _slang_select(_S763, _S772,_S771);
    Weights _S774 = lobeWeights(in_dir_2, _S743, _S746, facets_0.h, facets_0.coat_h, _S770, _S773, _S750, _S751, _S752, _S753, material_13, eta_i_4, eta_o_3);
    float _S775 = (F32_abs((_S744)));
    float _S776 = diffusePDF(_S747, _S775, material_13, _S774);
    float _S777 = _slang_select(_S761, _S776,0.0f);
    (*pdfs_0)[int(0)] = _S777;
    float3  _S778 = diffuseBSDF(out_dir_0, _S746, material_13, _S774);
    float3  _S779 = _slang_select(_S761, _S778,_S771);
    (*throughputs_0)[int(0)] = _S779;
    float _S780 = vndfPDF(_S743, _S770, _S746, _S775, _S749, _S750, _S774.v_dot_h);
    float _S781 = refractPDF(dot_0(out_dir_0, _S770), _S780, _S774, eta_i_4, eta_o_3);
    float _S782 = _slang_select(refracted_2, _S781,0.0f);
    (*pdfs_0)[int(1)] = _S782;
    float3  _S783 = refractBSDF(out_dir_0, _S746, _S749, _S750, material_13, _S774);
    float3  _S784 = _slang_select(refracted_2, _S783,_S771);
    (*throughputs_0)[int(1)] = _S784;
    float _S785 = reflectPDF(_S780, _S774);
    float _S786 = _slang_select(_S762, _S785,0.0f);
    (*pdfs_0)[int(2)] = _S786;
    float3  _S787 = reflectBSDF(out_dir_0, _S746, _S749, _S750, _S774);
    float3  _S788 = _slang_select(_S762, _S787,_S771);
    (*throughputs_0)[int(2)] = _S788;
    float _S789 = sheenVelvetPDF(_S747, _S775, _S774);
    float _S790 = _slang_select(_S762, _S789,0.0f);
    (*pdfs_0)[int(3)] = _S790;
    float3  _S791 = sheenVelvetBSDF(out_dir_0, _S743, _S746, material_13, _S774);
    float3  _S792 = _slang_select(_S762, _S791,_S771);
    (*throughputs_0)[int(3)] = _S792;
    ToonProfile _S793 = toonProfile(_S743, _S746, material_13);
    float _S794 = toonPDF(out_dir_0, _S746, _S793, _S774);
    float _S795 = _slang_select(_S760, _S794,0.0f);
    (*pdfs_0)[int(4)] = _S795;
    float3  _S796 = toonBSDF(out_dir_0, _S746, _S793, _S774);
    float3  _S797 = _slang_select(_S760, _S796,_S771);
    (*throughputs_0)[int(4)] = _S797;
    float _S798 = coatPDF(_S743, _S773, _S752, _S774);
    float _S799 = _slang_select(_S763, _S798,0.0f);
    (*pdfs_0)[int(5)] = _S799;
    float3  _S800 = coatBSDF(_S774);
    float3  _S801 = _slang_select(_S763, _S800,_S771);
    (*throughputs_0)[int(5)] = _S801;
    return;
}

static __device__ __forceinline__ float3  skyLobes_0(float3  in_dir_3, float3  dir_3, FKSurface * surface_1, BSDFMaterial * material_14, float2  eta_1, bool is_inside_2, Facets * facets_1, float pdf_0, FixedArray<float3 , 6>  * terms_0, FixedArray<float, 6>  * pdfs_1)
{
    bool _S802 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    BSDF(in_dir_3, dir_3, surface_1->smooth_n, *material_14, eta_1.x, eta_1.y, _S802, *facets_1, terms_0, pdfs_1);
    float3  _S803 = make_float3 (0.0f);
    uint i_9 = 0U;
    float3  f_2 = _S803;
    for(;;)
    {
        if(i_9 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S804 = ((*pdfs_1)[i_9]) > 0.0f;
        if(_S804)
        {
            float3  _S805 = (*terms_0)[i_9] * make_float3 ((*pdfs_1)[i_9]) / make_float3 ((*pdfs_1)[i_9] + pdf_0);
            (*terms_0)[i_9] = _S805;
            float3  f_3 = f_2 + (*terms_0)[i_9];
            f_2 = f_3;
        }
        uint i_10 = i_9 + 1U;
        i_9 = i_10;
    }
    return f_2;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_4, float3  radiance_0, float3  color_0, uint random_state_2)
{
    SkySample _S806;
    (&_S806)->dir = dir_4;
    (&_S806)->radiance = radiance_0;
    (&_S806)->color = color_0;
    (&_S806)->random_state = random_state_2;
    return _S806;
}

static __device__ __noinline__ float3  skyColor_0(float3  dir_5, FixedArray<float3 , 6>  * terms_1, FixedArray<float, 6>  * pdfs_2, uint depth_0)
{
    float3  _S807 = make_float3 (0.0f);
    bool shaded_0 = false;
    float3  world_0 = _S807;
    uint i_11 = 0U;
    float3  color_1 = _S807;
    for(;;)
    {
        if(i_11 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S808 = ((*pdfs_2)[i_11]) > 0.0f;
        if(_S808)
        {
            bool _S809 = (fcptWorldReadsPath());
            bool _S810;
            if(_S809)
            {
                _S810 = true;
            }
            else
            {
                _S810 = !shaded_0;
            }
            bool shaded_1;
            float3  world_1;
            if(_S810)
            {
                uint _S811;
                if(i_11 == 3U)
                {
                    _S811 = 4U;
                }
                else
                {
                    if(i_11 == 4U)
                    {
                        _S811 = 6U;
                    }
                    else
                    {
                        if(i_11 == 5U)
                        {
                            _S811 = 5U;
                        }
                        else
                        {
                            _S811 = i_11;
                        }
                    }
                }
                float3  _S812 = (fcptEnvMapSample((dir_5), (depth_0), (_S811)));
                world_1 = _S812;
                shaded_1 = true;
            }
            else
            {
                world_1 = world_0;
                shaded_1 = shaded_0;
            }
            float3  color_2 = color_1 + (*terms_1)[i_11] * world_1;
            shaded_0 = shaded_1;
            world_0 = world_1;
            color_1 = color_2;
        }
        uint i_12 = i_11 + 1U;
        i_11 = i_12;
    }
    return color_1;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float wavelength_3, float2  eta_2, bool is_inside_3, uint init_random_state_0, Facets * facets_2, ShadowContext * context_2)
{
    uint2  _S813 = (fcptEnvironmentCdfSize());
    uint2  _S814 = make_uint2 (1U, 0U);
    uint2  _S815 = _S813 - _S814;
    Random _S816 = draw(init_random_state_0, 6U);
    Random _S817 = draw(init_random_state_0, 2147483654U);
    Random _S818 = draw(init_random_state_0, 7U);
    Random _S819 = draw(init_random_state_0, 2147483655U);
    uint _S820 = _S815.x;
    uint _S821 = searchCDF_0(make_uint2 (_S820, 0U), make_uint2 (0U, 1U), _S815.y, _S816.value);
    uint _S822 = searchCDF_0(make_uint2 (0U, _S821), _S814, _S820, _S817.value);
    float2  _S823 = make_float2 ((float)_S815.x, (float)_S815.y);
    float2  _S824 = (make_float2 (float(_S822), float(_S821)) + make_float2 (_S818.value, _S819.value)) / _S823 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S825 = _S824.y;
    float _S826 = (F32_sin((_S825)));
    float _S827 = _S824.x;
    float3  _S828 = make_float3 (- _S826 * (F32_cos((_S827))), _S826 * (F32_sin((_S827))), (F32_cos((_S825))));
    float _S829 = environmentPdf_0(_S828);
    BSDFMaterial _S830 = pathMaterial(surface_2->material, wavelength_3);
    BSDFMaterial _S831 = _S830;
    FixedArray<float3 , 6>  terms_2;
    FixedArray<float, 6>  pdfs_3;
    float3  _S832 = skyLobes_0(ray_0->unit_direction, _S828, surface_2, &_S831, eta_2, is_inside_3, facets_2, _S829, &terms_2, &pdfs_3);
    bool _S833 = !(_S829 > 0.0f);
    bool _S834;
    if(_S833)
    {
        _S834 = true;
    }
    else
    {
        _S834 = all_1(_S832 == make_float3 (0.0f));
    }
    if(_S834)
    {
        float3  _S835 = make_float3 (0.0f);
        return SkySample_x24init_0(_S828, _S835, _S835, _S819.state);
    }
    bool _S836 = (fcptWorldReadsPath());
    float3  seen_0;
    if(_S836)
    {
        uint _S837 = context_2->depth + 1U;
        FixedArray<float3 , 6>  _S838 = terms_2;
        FixedArray<float, 6>  _S839 = pdfs_3;
        float3  _S840 = skyColor_0(_S828, &_S838, &_S839, _S837);
        seen_0 = _S840;
    }
    else
    {
        seen_0 = _S832;
    }
    float3  _S841 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S828, context_2, _S819.state);
    return SkySample_x24init_0(_S828, _S841, seen_0 * _S841, _S819.state);
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

static __device__ float3  hairLight_0(FKSurface * surface_3, float3  in_dir_4, TreeSample * light_1, bool competing_0)
{
    SampleBSDF _S842 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_4), (light_1->dir)));
    float3  _S843 = _S842.throughput * make_float3 (_S842.pdf);
    float _S844 = light_1->density;
    float _S845 = 1.0f + _S842.pdf * _S842.pdf / (light_1->density * light_1->density);
    bool _S846;
    if(competing_0)
    {
        _S846 = _S844 > 0.0f;
    }
    else
    {
        _S846 = false;
    }
    float _S847 = _slang_select(_S846, _S845,1.0f);
    return _S843 / make_float3 (_S847) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_3)
{
    TreeSample _S848;
    (&_S848)->dir = dir_6;
    (&_S848)->radiance = radiance_1;
    (&_S848)->density = density_0;
    (&_S848)->random_state = random_state_3;
    return _S848;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_4, float * pick_0, float * probability_3)
{
    float _S849 = importance(first_1, p_12, normal_4);
    float _S850 = importance(second_1, p_12, normal_4);
    float2  _S851 = make_float2 (_S849, _S850);
    bool _S852 = _S849 == 0.0f;
    bool _S853;
    if(_S852)
    {
        _S853 = _S850 == 0.0f;
    }
    else
    {
        _S853 = false;
    }
    if(_S853)
    {
        return 2U;
    }
    float _S854 = _S849 + _S850;
    bool _S855 = _S850 > 0.0f;
    if(_S855)
    {
        _S853 = (*pick_0 * _S854) >= _S849;
    }
    else
    {
        _S853 = false;
    }
    uint _S856 = uint(_S853);
    float _S857 = (F32_min(((*pick_0 * _S854 - float(_S856) * _S849) / _slang_vector_get_element(_S851, _S856)), (0.99999994039535522f)));
    *pick_0 = _S857;
    float _S858 = *probability_3 * (_slang_vector_get_element(_S851, _S856) / _S854);
    *probability_3 = _S858;
    return _S856;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S859 = center_1 - p_13;
    float _S860 = radius_1 * radius_1 / dot_0(_S859, _S859);
    float _S861 = u1_0 * _S860 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S860), (0.0f)))))));
    float _S862 = 2.0f * u1_0;
    bool _S863 = _S860 >= 1.0f;
    float _S864 = _slang_select(_S863, _S862,_S861);
    float _S865 = (F32_sqrt(((F32_max((_S864 * (2.0f - _S864)), (0.0f))))));
    float _S866 = 6.28318548202514648f * u2_0;
    float3  _S867 = make_float3 (_S865 * (F32_cos((_S866))), 1.0f - _S864, _S865 * (F32_sin((_S866))));
    float3  _S868 = ((((_S859)) * make_float3(rnorm3df(((_S859)).x, ((_S859)).y, ((_S859)).z))));
    float3  _S869 = tangentToWorld(_S867, _S868);
    return _S869;
}

__device__ float3  pointLightRadiance(float3  color_3, float intensity_0, float radius_2)
{
    return color_3 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S870 = center_2 - ray_1->origin;
    float _S871 = dot_0(_S870, ray_1->unit_direction);
    float _S872 = dot_0(_S870, _S870) - _S871 * _S871;
    float _S873 = radius_3 * radius_3;
    bool _S874 = _S872 > _S873;
    if(_S874)
    {
        return 4.294967296e+09f;
    }
    float _S875 = (F32_sqrt((_S873 - _S872)));
    float _S876 = _S871 - _S875;
    float _S877 = _S871 + _S875;
    bool _S878 = _S876 > 0.0000152587890625f;
    bool _S879;
    if(_S878)
    {
        _S879 = _S876 < max_len_0;
    }
    else
    {
        _S879 = false;
    }
    if(_S879)
    {
        return _S876;
    }
    bool _S880 = _S877 > 0.0000152587890625f;
    if(_S880)
    {
        _S879 = _S877 < max_len_0;
    }
    else
    {
        _S879 = false;
    }
    if(_S879)
    {
        return _S877;
    }
    return 4.294967296e+09f;
}

static __device__ float3  mul_0(float3  left_1, Matrix<float, 3, 3>  right_1)
{
    float3  result_7;
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
        int i_13 = int(0);
        float sum_0 = 0.0f;
        for(;;)
        {
            if(i_13 < int(3))
            {
            }
            else
            {
                break;
            }
            float sum_1 = sum_0 + _slang_vector_get_element(left_1, i_13) * _slang_vector_get_element(right_1.rows[i_13], j_1);
            i_13 = i_13 + int(1);
            sum_0 = sum_1;
        }
        *_slang_vector_get_element_ptr(&result_7, j_1) = sum_0;
        j_1 = j_1 + int(1);
    }
    return result_7;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S881 = draw(init_random_state_1, 4U);
    Random _S882 = draw(init_random_state_1, 5U);
    Random _S883 = draw(init_random_state_1, 2147483653U);
    float3  _S884 = make_float3 (0.0f);
    TreeSample _S885 = TreeSample_x24init_0(_S884, _S884, 0.0f, _S883.state);
    TreeSample sample_0 = _S885;
    float3  _S886 = _slang_select(sided_0, _S884,smooth_n_2);
    float3  _S887 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S881.value;
    float probability_4 = 1.0f;
    uint n_7 = 0U;
    for(;;)
    {
        uint4  _S888 = (fcptLightNode((n_7)));
        if((_S888.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S889 = (fcptLightSecond((n_7)));
        uint _S890 = n_7 + 1U;
        LightNode _S891 = (fcptLightBounds((_S890)));
        LightNode _S892 = (fcptLightBounds((_S889)));
        uint _S893 = pickChild(_S891, _S892, origin_4, _S886, &pick_1, &probability_4);
        bool _S894 = _S893 > 1U;
        if(_S894)
        {
            return sample_0;
        }
        bool _S895 = _S893 == 1U;
        uint _S896 = _slang_select(_S895, _S889,_S890);
        n_7 = _S896;
    }
    bool _S897 = n_7 == 0U;
    bool _S898;
    if(_S897)
    {
        LightNode _S899 = (fcptLightBounds((0U)));
        float _S900 = importance(_S899, origin_4, _S886);
        _S898 = !(_S900 > 0.0f);
    }
    else
    {
        _S898 = false;
    }
    if(_S898)
    {
        return sample_0;
    }
    uint4  _S901 = (fcptLightNode((n_7)));
    FKHit _S902 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S903 = (_S901.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S903)
    {
        FKLight _S904 = (fcptLight((_S901.y)));
        if(sided_0)
        {
            float _S905 = sign_0(dot_0(geometry_n_1, _S904.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S905);
            float3  _S906 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S906;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S887;
            lift_n_0 = smooth_n_2;
        }
        bool _S907 = (_S904.variance) == 0.0f;
        if(_S907)
        {
            float3  _S908 = _S904.position - emitter_point_0;
            float3  _S909 = ((((_S908)) * make_float3(rnorm3df(((_S908)).x, ((_S908)).y, ((_S908)).z))));
            (&sample_0)->dir = _S909;
            float3  _S910 = _S904.color * make_float3 (_S904.intensity) / make_float3 (dot_0(_S908, _S908) * probability_4);
            (&sample_0)->radiance = _S910;
            shadow_1 = _S908;
        }
        else
        {
            float3  _S911 = sampleSphere(_S904.position, _S904.variance, emitter_point_0, _S882.value, _S883.value);
            (&sample_0)->dir = _S911;
            float _S912 = sphereDensity(_S904.position, _S904.variance, emitter_point_0);
            float _S913 = probability_4 * _S912;
            (&sample_0)->density = _S913;
            float3  _S914 = pointLightRadiance(_S904.color, _S904.intensity, _S904.variance);
            float3  _S915 = _S914 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S915;
            FKRay _S916 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S917 = raySphere_0(_S904.position, _S904.variance, &_S916, 4.294967296e+09f);
            float3  _S918 = (&sample_0)->dir * make_float3 (_S917);
            shadow_1 = _S918;
        }
        emitter_0 = _S902;
        emitter_point_0 = _S884;
    }
    else
    {
        uint _S919 = _S901.y;
        uint _S920 = (fcptTriangleOffset((_S919)));
        uint _S921 = _S920 + _S901.z;
        Matrix<float, 3, 3>  _S922 = (fcptWorldTriangle((_S919), (_S921)));
        float _S923 = (F32_sqrt((_S882.value)));
        float2  _S924 = make_float2 (_S923 * (1.0f - _S883.value), _S923 * _S883.value);
        float3  _S925 = mul_0(make_float3 (1.0f - _S923, _S924.x, _S924.y), _S922);
        if(sided_0)
        {
            float _S926 = sign_0(dot_0(geometry_n_1, _S925 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S926);
            float3  _S927 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S927;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S928 = !((dot_0(smooth_n_2, _S925 - origin_4)) > 0.0f);
            if(_S928)
            {
                return sample_0;
            }
            emitter_point_0 = _S887;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S924, _S919, _S921, 0U, 0.0f);
        float3  _S929 = _S925 - emitter_point_0;
        float3  _S930 = ((((_S929)) * make_float3(rnorm3df(((_S929)).x, ((_S929)).y, ((_S929)).z))));
        (&sample_0)->dir = _S930;
        float _S931 = solidAngle(probability_4, cross_0(_S922.rows[int(1)] - _S922.rows[int(0)], _S922.rows[int(2)] - _S922.rows[int(0)]), _S929);
        (&sample_0)->density = _S931;
        bool _S932 = (fcptShadowFirst());
        bool _S933 = !_S932;
        if(_S933)
        {
            FKSurface _S934 = (fcptLightSurfaceAt((emitter_1), (_S925), (_S883.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S925 - origin_4))));
            (&sample_0)->random_state = _S934.random_state;
            float3  _S935 = _slang_select(_S934.skip, _S884,_S934.material.emissive);
            float3  _S936 = _S935 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S936;
        }
        shadow_1 = _S929;
        emitter_0 = emitter_1;
        emitter_point_0 = _S925;
    }
    FKHit _S937 = emitter_0;
    float3  _S938 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S883.state, &_S937);
    bool _S939 = (fcptShadowFirst());
    if(_S939)
    {
        _S898 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S898 = false;
    }
    if(_S898)
    {
        _S898 = !all_1(_S938 == _S884);
    }
    else
    {
        _S898 = false;
    }
    if(_S898)
    {
        FKSurface _S940 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S883.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S940.random_state;
        float3  _S941 = _slang_select(_S940.skip, _S884,_S940.material.emissive);
        float3  _S942 = _S941 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S942;
    }
    float3  _S943 = (&sample_0)->radiance * _S938;
    bool _S944 = all_1(_S938 == _S884);
    float3  _S945 = _slang_select(_S944, _S884,_S943);
    (&sample_0)->radiance = _S945;
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

__device__ float powerHeuristic(float a_6, float b_2)
{
    float _S946 = 1.0f / (1.0f + b_2 / a_6 * (b_2 / a_6));
    bool _S947 = b_2 > 0.0f;
    float _S948 = _slang_select(_S947, _S946,1.0f);
    return _S948;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S949 = vertex_0->none;
    if(_S949)
    {
        return 1.0f;
    }
    uint _S950 = (fcptLightSlot((*hit_1)));
    float _S951 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S950, light_point_1);
    float _S952 = powerHeuristic(vertex_0->pdf, _S951);
    return _S952;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_1, uint lobe_0)
{
    uint2  _S953 = (fcptEnvironmentMapSize());
    bool _S954 = (_S953.x) > 1U;
    bool _S955;
    if(_S954)
    {
        uint2  _S956 = (fcptEnvironmentMapSize());
        _S955 = (_S956.y) > 1U;
    }
    else
    {
        _S955 = false;
    }
    if(_S955)
    {
        float3  _S957 = (fcptEnvMapSample((dir_7), (depth_1), (lobe_0)));
        return _S957;
    }
    float3  _S958 = (fcptAmbient());
    return _S958;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S959 = (fcptEnvironmentCdfSize());
    bool _S960 = (_S959.x) > 1U;
    bool _S961;
    if(_S960)
    {
        uint2  _S962 = (fcptEnvironmentCdfSize());
        _S961 = (_S962.y) > 1U;
    }
    else
    {
        _S961 = false;
    }
    bool _S963 = !_S961;
    if(_S963)
    {
        return false;
    }
    uint2  _S964 = (fcptEnvironmentMapSize());
    bool _S965 = (_S964.x) > 1U;
    if(_S965)
    {
        uint2  _S966 = (fcptEnvironmentMapSize());
        _S961 = (_S966.y) > 1U;
    }
    else
    {
        _S961 = false;
    }
    return _S961;
}

static __device__ float escapeWeight_0(float pdf_1, float3  dir_8)
{
    bool _S967 = pdf_1 <= 0.0f;
    bool _S968;
    if(_S967)
    {
        _S968 = true;
    }
    else
    {
        bool _S969 = environmentMapped_0();
        _S968 = !_S969;
    }
    if(_S968)
    {
        return 1.0f;
    }
    float _S970 = environmentPdf_0(dir_8);
    return pdf_1 / (pdf_1 + _S970);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S971 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S972 = make_int2 ((int)_S971.x, (int)_S971.y);
    uint _S973 = previousSeed_0(_S972);
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
            uint _S974 = previousSeed_0(_S972 + make_int2 (x_16, y_5));
            bool _S975 = _S974 == _S973;
            uint _S976 = _slang_select(_S975, 1U,0U);
            uint count_3 = count_2 + _S976;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S977 = float(count_2 - 1U) / 288.0f;
    bool _S978 = _S973 != 0U;
    float _S979 = _slang_select(_S978, _S977,0.0f);
    fcptStoreDuplication((_S972), (make_uint4 ((F32_asuint((_S979))), 0U, 0U, 0U)));
    return;
}

static __device__ float3  abs_0(float3  x_18)
{
    float3  result_8;
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
        *_slang_vector_get_element_ptr(&result_8, i_14) = (F32_abs((_slang_vector_get_element(x_18, i_14))));
        i_14 = i_14 + int(1);
    }
    return result_8;
}

__device__ float resamplingTarget(float3  f_4)
{
    float _S980 = rgb_to_greyscale(abs_0(f_4));
    return _S980;
}

static __device__ float4  asfloat_0(uint4  x_19)
{
    float4  result_9;
    int i_15 = int(0);
    for(;;)
    {
        if(i_15 < int(4))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_9, i_15) = (U32_asfloat((_slang_vector_get_element(x_19, i_15))));
        i_15 = i_15 + int(1);
    }
    return result_9;
}

__device__ void offer(Selection * sel_2, Reservoir candidate_0, float3  weight_0)
{
    float _S981 = resamplingTarget(weight_0);
    bool _S982 = _S981 > 0.0f;
    bool _S983;
    if(_S982)
    {
        _S983 = _S981 < 3.00000000549775576e+38f;
    }
    else
    {
        _S983 = false;
    }
    bool _S984 = !_S983;
    if(_S984)
    {
        return;
    }
    bool _S985 = sel_2->sums;
    if(_S985)
    {
        float3  _S986 = sel_2->color + weight_0;
        sel_2->color = _S986;
        return;
    }
    float _S987 = sel_2->w_sum + _S981;
    sel_2->w_sum = _S987;
    float3  _S988 = sel_2->color + weight_0;
    sel_2->color = _S988;
    Random _S989 = pcg(sel_2->random_state);
    sel_2->random_state = _S989.state;
    bool _S990 = (_S989.value * sel_2->w_sum) <= _S981;
    if(_S990)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S991 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S991;
    float _S992 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S992;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S993 = resamplingTarget((&r_4)->f);
    float _S994 = sel_4.w_sum / _S993;
    bool _S995 = _S993 > 0.0f;
    float _S996 = _slang_select(_S995, _S994,0.0f);
    (&r_4)->w = _S996;
    (&r_4)->c = c_1;
    return r_4;
}

static __device__ uint2  asuint_0(float2  x_20)
{
    uint2  result_10;
    int i_16 = int(0);
    for(;;)
    {
        if(i_16 < int(2))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_10, i_16) = (F32_asuint((_slang_vector_get_element(x_20, i_16))));
        i_16 = i_16 + int(1);
    }
    return result_10;
}

static __device__ void restir_spatial_0(uint3  global_invocation_id_2)
{
    uint2  _S997 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S998 = make_int2 ((int)_S997.x, (int)_S997.y);
    float3  _S999 = make_float3 (0.0f);
    FKHit _S1000 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S1001 = Domain_x24init_0(_S999, _S999, &_S1000, 0.0f, 0.0f);
    Domain dom_4 = _S1001;
    bool _S1002 = (fcptCurrentDomain((_S998), (&dom_4)));
    bool _S1003 = !_S1002;
    if(_S1003)
    {
        Reservoir _S1004 = (Reservoir{});
        fcptStoreReservoirPrevious((_S998), (_S1004), ((&dom_4)->hit));
        return;
    }
    Reservoir _S1005 = (fcptLoadReservoirTemporal((_S998)));
    uint t_15 = 0U;
    float count_4 = 0.0f;
    float c_sum_0 = _S1005.c;
    for(;;)
    {
        uint _S1006 = (fcptRestirNeighbours());
        if(t_15 < _S1006)
        {
        }
        else
        {
            break;
        }
        int2  _S1007 = partner_0(_S998, t_15);
        Domain neighbor_0 = _S1001;
        bool _S1008 = (fcptCurrentDomain((_S1007), (&neighbor_0)));
        if(_S1008)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S1009 = (fcptReservoirTemporal((_S1007), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S1009.w)));
            count_4 = count_5;
            c_sum_0 = c_sum_1;
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    float _S1010 = _S1005.c / (F32_max((count_4), (1.0f)));
    float _S1011 = resamplingTarget(_S1005.f);
    bool _S1012 = count_4 == 0.0f;
    float _S1013 = _slang_select(_S1012, 1.0f,0.0f);
    Selection _S1014 = (Selection{});
    Selection sel_5 = _S1014;
    uint _S1015 = (fcptFrame());
    uint _S1016 = hash(_S1015);
    uint _S1017 = global_invocation_id_2.x;
    uint2  _S1018 = (fcptRenderSize());
    uint _S1019 = stream(_S1016, _S1017 + _S1018.x * global_invocation_id_2.y);
    uint _S1020 = stream(_S1019, 195U);
    (&sel_5)->random_state = _S1020;
    t_15 = 0U;
    float canonical_mis_0 = _S1013;
    for(;;)
    {
        uint _S1021 = (fcptRestirNeighbours());
        if(t_15 < _S1021)
        {
        }
        else
        {
            break;
        }
        int2  _S1022 = partner_0(_S998, t_15);
        Domain neighbor_dom_0 = _S1001;
        bool _S1023 = (fcptCurrentDomain((_S1022), (&neighbor_dom_0)));
        if(_S1023)
        {
            Reservoir _S1024 = (fcptLoadReservoirTemporal((_S1022)));
            uint4  _S1025 = (fcptShiftData((_S1022), (t_15)));
            float4  _S1026 = asfloat_0(_S1025);
            uint4  _S1027 = (fcptShiftData((_S998), (t_15)));
            float4  _S1028 = asfloat_0(_S1027);
            float _S1029 = (_S1024.c + _S1010) / c_sum_0;
            bool _S1030 = _S1011 > 0.0f;
            float canonical_mis_1;
            if(_S1030)
            {
                float _S1031 = _S1029 * _S1010 * _S1011;
                float _S1032 = _S1010 * _S1011;
                float _S1033 = resamplingTarget(float3 {_S1028.x, _S1028.y, _S1028.z});
                float canonical_mis_2 = canonical_mis_0 + _S1031 / (_S1032 + _S1024.c * _S1033);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S1034 = resamplingTarget(_S1024.f);
            float3  _S1035 = float3 {_S1026.x, _S1026.y, _S1026.z};
            Shift _S1036 = Shift_x24init_0(_S1035, _S1026.w);
            float _S1037 = _S1029 * _S1024.c * _S1034;
            float _S1038 = _S1024.c * _S1034;
            float _S1039 = resamplingTarget(_S1035);
            offerShifted(&sel_5, _S1024, _S1036, _S1037 / (_S1038 + _S1010 * _S1039));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_17 = t_15 + 1U;
        t_15 = t_17;
    }
    offerShifted(&sel_5, _S1005, Shift_x24init_0(_S1005.f, 1.0f), canonical_mis_0);
    Reservoir _S1040 = finalize(sel_5, c_sum_0);
    fcptStoreReservoirPrevious((_S998), (_S1040), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S998), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S998), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
    return;
}

static __device__ uint3  asuint_1(float3  x_21)
{
    uint3  result_11;
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
        *_slang_vector_get_element_ptr(&result_11, i_17) = (F32_asuint((_slang_vector_get_element(x_21, i_17))));
        i_17 = i_17 + int(1);
    }
    return result_11;
}

static __device__ void restir_shift_0(uint3  workgroup_id_1, uint local_invocation_index_4)
{
    uint _S1041 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S1042 = _S1041 != 4294967295U;
    if(_S1042)
    {
        uint2  _S1043 = make_uint2 (_S1041, _S1041 >> 14U) & make_uint2 (16383U);
        int2  _S1044 = make_int2 ((int)_S1043.x, (int)_S1043.y);
        ShiftJob _S1045 = (ShiftJob{});
        ShiftJob shift_job_0 = _S1045;
        Shift _S1046 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S1047 = _S1041 >> 28U;
        bool _S1048 = spatialJob_0(_S1044, _S1047, &shift_job_0, true);
        Shift shifted_1;
        if(_S1048)
        {
            Domain _S1049 = (&shift_job_0)->dom;
            Reservoir _S1050 = (&shift_job_0)->r;
            Shift _S1051 = passShift_0(&_S1049, &_S1050);
            shifted_1 = _S1051;
        }
        else
        {
            shifted_1 = _S1046;
        }
        fcptStoreShiftData((_S1044), (_S1047), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S1052 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S1053 = make_int2 ((int)_S1052.x, (int)_S1052.y);
    FixedArray<uint, 3>  _S1054;
    spatialBins_0(_S1053, &_S1054);
    FixedArray<uint, 3>  _S1055 = _S1054;
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
        bool _S1056 = (_S1055[t_18]) == 40U;
        if(_S1056)
        {
            fcptStoreShiftData((_S1053), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S1057 = _S1055;
    queueShifts_0(_S1053, &_S1057, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S1058 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S1059 = make_int2 ((int)_S1058.x, (int)_S1058.y);
    FixedArray<uint, 3>  _S1060;
    spatialBins_0(_S1059, &_S1060);
    FixedArray<uint, 3>  _S1061 = _S1060;
    countShifts_0(&_S1061, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S1062 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S1063 = _S1062 != 4294967295U;
    if(_S1063)
    {
        uint2  _S1064 = make_uint2 (_S1062, _S1062 >> 14U) & make_uint2 (16383U);
        int2  _S1065 = make_int2 ((int)_S1064.x, (int)_S1064.y);
        int2  _S1066 = (fcptLoadTemporalNeighbor((_S1065)));
        uint _S1067 = _S1062 >> 28U;
        Shift _S1068 = temporalShiftAt_0(_S1065, _S1066, _S1067);
        fcptStoreTemporalShift((_S1065), (_S1067), (make_uint4 (asuint_1(_S1068.f).x, asuint_1(_S1068.f).y, asuint_1(_S1068.f).z, (F32_asuint((_S1068.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S1069 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S1070 = make_int2 ((int)_S1069.x, (int)_S1069.y);
    FixedArray<uint, 3>  _S1071;
    temporalBins_0(_S1070, &_S1071);
    FixedArray<uint, 3>  _S1072 = _S1071;
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
        bool _S1073 = (_S1072[t_20]) == 40U;
        if(_S1073)
        {
            fcptStoreTemporalShift((_S1070), (t_20), (make_uint4 (0U)));
        }
        uint t_21 = t_20 + 1U;
        t_20 = t_21;
    }
    FixedArray<uint, 3>  _S1074 = _S1072;
    queueShifts_0(_S1070, &_S1074, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S1075 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S1076 = make_int2 ((int)_S1075.x, (int)_S1075.y);
    bool _S1077 = (fcptSceneUnchanged());
    bool _S1078 = !_S1077;
    bool _S1079;
    if(_S1078)
    {
        uint2  _S1080 = (fcptRenderSize());
        int2  _S1081 = make_int2 ((int)_S1080.x, (int)_S1080.y);
        _S1079 = all_0(_S1076 < _S1081);
    }
    else
    {
        _S1079 = false;
    }
    if(_S1079)
    {
        Reservoir _S1082 = (fcptLoadReservoirInitial((_S1076)));
        int2  _S1083 = sampleNeighbor_0(_S1076, _S1082.seed);
        fcptStoreTemporalNeighbor((_S1076), (_S1083));
    }
    FixedArray<uint, 3>  _S1084;
    temporalBins_0(_S1076, &_S1084);
    FixedArray<uint, 3>  _S1085 = _S1084;
    countShifts_0(&_S1085, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_7, float b_3, float t_22)
{
    return a_7 + (b_3 - a_7) * t_22;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S1086 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S1087 = make_int2 ((int)_S1086.x, (int)_S1086.y);
    float3  _S1088 = make_float3 (0.0f);
    FKHit _S1089 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S1090 = Domain_x24init_0(_S1088, _S1088, &_S1089, 0.0f, 0.0f);
    Domain dom_5 = _S1090;
    bool _S1091 = (fcptCurrentDomain((_S1087), (&dom_5)));
    bool _S1092 = !_S1091;
    if(_S1092)
    {
        Reservoir _S1093 = (Reservoir{});
        fcptStoreReservoirTemporal((_S1087), (_S1093), ((&dom_5)->hit));
        return;
    }
    Reservoir _S1094 = (fcptLoadReservoirInitial((_S1087)));
    bool _S1095 = (fcptTemporalQueued());
    bool _S1096 = (fcptSceneUnchanged());
    bool _S1097;
    if(_S1096)
    {
        _S1097 = true;
    }
    else
    {
        _S1097 = !_S1095;
    }
    int2  _S1098;
    if(_S1097)
    {
        int2  _S1099 = sampleNeighbor_0(_S1087, _S1094.seed);
        _S1098 = _S1099;
    }
    else
    {
        int2  _S1100 = (fcptLoadTemporalNeighbor((_S1087)));
        _S1098 = _S1100;
    }
    bool _S1101 = (_S1098.x) >= int(0);
    Reservoir r_5;
    if(_S1101)
    {
        Reservoir _S1102 = (fcptLoadReservoirPrevious((_S1098)));
        uint4  _S1103 = (fcptDuplication((_S1098)));
        float _S1104 = (U32_asfloat((_S1103.x)));
        uint _S1105 = (fcptRestirDecorrelation());
        bool _S1106 = _S1105 == 1U;
        float _S1107 = _slang_select(_S1106, _S1104,0.0f);
        float _S1108 = interpolate_0(20.0f, 1.0f, (F32_pow((_S1107), (0.10000000149011612f))));
        float _S1109 = (F32_min((_S1102.c), (_S1108)));
        bool _S1110 = (fcptSceneUnchanged());
        float4  _S1111 = make_float4 (_S1102.f.x, _S1102.f.y, _S1102.f.z, 1.0f);
        bool _S1112 = !_S1110;
        if(_S1112)
        {
            _S1097 = _S1095;
        }
        else
        {
            _S1097 = false;
        }
        float4  to_current_0;
        if(_S1097)
        {
            uint4  _S1113 = (fcptTemporalShift((_S1087), (0U)));
            float4  _S1114 = asfloat_0(_S1113);
            to_current_0 = _S1114;
        }
        else
        {
            if(_S1112)
            {
                Shift _S1115 = temporalShiftAt_0(_S1087, _S1098, 0U);
                float4  _S1116 = make_float4 (_S1115.f.x, _S1115.f.y, _S1115.f.z, _S1115.jac);
                to_current_0 = _S1116;
            }
            else
            {
                to_current_0 = _S1111;
            }
        }
        Domain own_1 = _S1090;
        if(_S1110)
        {
            _S1097 = true;
        }
        else
        {
            bool _S1117 = (fcptPreviousScenes());
            bool _S1118 = !_S1117;
            if(_S1118)
            {
                _S1097 = (_S1094.w) > 0.0f;
            }
            else
            {
                _S1097 = false;
            }
            if(_S1097)
            {
                bool _S1119 = (fcptStoredDomainInitial((_S1087), (_S1094.seed), (&own_1)));
                _S1097 = _S1119;
            }
            else
            {
                _S1097 = false;
            }
            if(_S1097)
            {
                Domain _S1120 = (fcptPreviousDomain((_S1098), (_S1094.seed)));
                Domain _S1121 = _S1120;
                Domain _S1122 = own_1;
                bool _S1123 = sameDomain_0(&_S1121, &_S1122);
                _S1097 = _S1123;
            }
            else
            {
                _S1097 = false;
            }
        }
        float4  _S1124 = make_float4 (_S1094.f.x, _S1094.f.y, _S1094.f.z, 1.0f);
        bool _S1125 = !_S1097;
        if(_S1125)
        {
            _S1097 = _S1095;
        }
        else
        {
            _S1097 = false;
        }
        float4  to_previous_0;
        if(_S1097)
        {
            uint4  _S1126 = (fcptTemporalShift((_S1087), (1U)));
            float4  _S1127 = asfloat_0(_S1126);
            to_previous_0 = _S1127;
        }
        else
        {
            if(_S1125)
            {
                Shift _S1128 = temporalShiftAt_0(_S1087, _S1098, 1U);
                float4  _S1129 = make_float4 (_S1128.f.x, _S1128.f.y, _S1128.f.z, _S1128.jac);
                to_previous_0 = _S1129;
            }
            else
            {
                to_previous_0 = _S1124;
            }
        }
        float _S1130 = resamplingTarget(_S1094.f);
        float _S1131 = resamplingTarget(_S1102.f);
        Selection _S1132 = (Selection{});
        Selection sel_6 = _S1132;
        uint _S1133 = (fcptFrame());
        uint _S1134 = hash(_S1133);
        uint _S1135 = global_invocation_id_7.x;
        uint2  _S1136 = (fcptRenderSize());
        uint _S1137 = stream(_S1134, _S1135 + _S1136.x * global_invocation_id_7.y);
        uint _S1138 = stream(_S1137, 194U);
        (&sel_6)->random_state = _S1138;
        float _S1139 = _S1094.c * _S1130;
        float4  _S1140 = to_previous_0;
        float _S1141 = resamplingTarget(float3 {_S1140.x, _S1140.y, _S1140.z});
        float _S1142 = _S1139 / (_S1139 + _S1109 * _S1141);
        float _S1143 = _S1109 * _S1131;
        float4  _S1144 = to_current_0;
        float3  _S1145 = float3 {_S1144.x, _S1144.y, _S1144.z};
        float _S1146 = resamplingTarget(_S1145);
        float _S1147 = _S1143 / (_S1143 + _S1094.c * _S1146);
        float2  _S1148 = make_float2 (_S1142, _S1147);
        offerShifted(&sel_6, _S1094, Shift_x24init_0(_S1094.f, 1.0f), _S1142);
        offerShifted(&sel_6, _S1102, Shift_x24init_0(_S1145, to_current_0.w), _S1147);
        Reservoir _S1149 = finalize(sel_6, _S1094.c + _S1109);
        r_5 = _S1149;
    }
    else
    {
        r_5 = _S1094;
    }
    fcptStoreReservoirTemporal((_S1087), (r_5), ((&dom_5)->hit));
    return;
}

__device__ uint noiseOrigin(uint2  p_14, uint k_1)
{
    uint _S1150 = ((p_14.x) >> 11U) | (((p_14.y) >> 11U) << 4U);
    uint2  _S1151 = noiseOffset(8192U + (k_1 >> 10U) + (_S1150 << 20U));
    uint2  _S1152 = (p_14 + _S1151) & make_uint2 (2047U);
    return ((_S1152.x) | ((_S1152.y) << 11U)) | ((k_1 & 1023U) << 22U);
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1153 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1153 << offset_1))) | ((newbits_0 & _S1153) << offset_1);
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S1154 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S1155 = make_int2 ((int)_S1154.x, (int)_S1154.y);
    float3  _S1156 = make_float3 (0.0f);
    float2  _S1157 = make_float2 (0.0f);
    FKHit _S1158 = Hit_x24init_0(_S1157, 0U, 0U, 0U, 0.0f);
    Domain _S1159 = Domain_x24init_0(_S1156, _S1156, &_S1158, 0.0f, 0.0f);
    Domain dom_6 = _S1159;
    bool _S1160 = (fcptCurrentDomain((_S1155), (&dom_6)));
    bool _S1161 = !_S1160;
    if(_S1161)
    {
        Reservoir _S1162 = (Reservoir{});
        fcptStoreReservoirInitial((_S1155), (_S1162), ((&dom_6)->hit));
        return;
    }
    uint _S1163 = (fcptFrame());
    uint _S1164 = hash(_S1163);
    uint _S1165 = global_invocation_id_8.x;
    uint2  _S1166 = (fcptRenderSize());
    uint _S1167 = global_invocation_id_8.y;
    uint _S1168 = stream(_S1164, _S1165 + _S1166.x * _S1167);
    uint2  _S1169 = (fcptRenderSize());
    uint _S1170 = stream(_S1165 + _S1169.x * _S1167, 512U);
    Selection _S1171 = (Selection{});
    Selection initial_0 = _S1171;
    uint _S1172 = stream(_S1168, 193U);
    (&initial_0)->random_state = _S1172;
    bool _S1173 = (fcptRestirUsed());
    bool _S1174 = !_S1173;
    (&initial_0)->sums = _S1174;
    uint _S1175 = stream(_S1168, 0U);
    (&(&initial_0)->r)->seed = _S1175;
    FKHit _S1176 = Hit_x24init_0(_S1157, 4294967295U, 0U, 0U, 0.0f);
    uint _S1177 = (fcptSamples());
    float _S1178 = 1.0f / float(_S1177);
    FKHit hit_2 = _S1176;
    uint i_18 = 0U;
    float3  seen_1 = _S1156;
    for(;;)
    {
        uint _S1179 = (fcptSamples());
        if(i_18 < _S1179)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1180 = (Reservoir{});
        Reservoir r_6 = _S1180;
        uint _S1181 = (fcptFrame());
        uint _S1182 = (fcptSamples());
        uint _S1183 = _S1181 * _S1182 + i_18;
        uint _S1184 = noiseOrigin(_S1154, _S1183);
        (&r_6)->seed = _S1184;
        uint _S1185 = insertBits_0(0U, 1U, 24U, 1U);
        uint _S1186 = insertBits_0(_S1185, (_S1170 + _S1183 * 2654435769U) >> 25U, 25U, 7U);
        (&r_6)->path = _S1186;
        Domain path_0 = _S1159;
        bool _S1187 = (fcptStoredDomainInitial((_S1155), ((&r_6)->seed), (&path_0)));
        bool _S1188 = !_S1187;
        if(_S1188)
        {
            float3  _S1189 = (fcptMissed((_S1155), (path_0), (_S1178)));
            float3  seen_2 = seen_1 + _S1189;
            seen_1 = seen_2;
            uint i_19 = i_18 + 1U;
            i_18 = i_19;
            continue;
        }
        Domain _S1190 = path_0;
        Reservoir _S1191 = r_6;
        Shift _S1192 = passWalk_0(&_S1190, &_S1191, false, _S1178, &initial_0);
        bool _S1193 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1193)
        {
            FKHit _S1194 = (&path_0)->hit;
            hit_3 = _S1194;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_19 = i_18 + 1U;
        i_18 = i_19;
    }
    uint _S1195 = (fcptSamples());
    float3  seen_3 = seen_1 + (&initial_0)->glow / make_float3 (float(_S1195));
    if((&initial_0)->sums)
    {
        seen_1 = seen_3 + (&initial_0)->color;
    }
    else
    {
        seen_1 = seen_3;
    }
    fcptAddColor((_S1155), (make_float4 (seen_1.x, seen_1.y, seen_1.z, 1.0f)));
    Reservoir _S1196 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S1155), (_S1196), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_2, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1197;
    (&_S1197)->none = none_0;
    (&_S1197)->pdf = pdf_2;
    (&_S1197)->origin = origin_5;
    (&_S1197)->smooth_n = smooth_n_3;
    (&_S1197)->start = start_6;
    return _S1197;
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
    Vertex _S1198;
    (&_S1198)->rough = rough_0;
    (&_S1198)->lobe = lobe_1;
    (&_S1198)->pdf = pdf_3;
    (&_S1198)->cos = cos_0;
    (&_S1198)->inside = inside_0;
    return _S1198;
}

__device__ uint noiseAddress(uint origin_6, uint bounce_0)
{
    uint2  _S1199 = make_uint2 (origin_6 & 2047U, (origin_6 >> 11U) & 2047U);
    uint2  _S1200 = noiseOffset(64U + bounce_0 * 17U);
    uint2  _S1201 = (_S1199 + _S1200) & make_uint2 (2047U);
    return ((_S1201.x) | ((_S1201.y) << 11U)) | ((origin_6 >> 22U) << 22U);
}

__device__ float3  pathColor(float3  f_5, float3  weight_1, float wavelength_4)
{
    float3  _S1202;
    if(wavelength_4 > 0.0f)
    {
        float _S1203 = upsample(f_5, wavelength_4);
        _S1202 = weight_1 * make_float3 (_S1203);
    }
    else
    {
        _S1202 = f_5;
    }
    return _S1202;
}

static __device__ float3  exp_0(float3  x_22)
{
    float3  result_12;
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
        *_slang_vector_get_element_ptr(&result_12, i_20) = (F32_exp((_slang_vector_get_element(x_22, i_20))));
        i_20 = i_20 + int(1);
    }
    return result_12;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_0, float distance_2, bool scatters_0)
{
    float3  _S1204 = exp_0((make_float3 (sigma_0) - extinction_0) * make_float3 (distance_2));
    float3  _S1205 = scatter_0 * _S1204 / make_float3 (sigma_0);
    float3  _S1206 = _slang_select(scatters_0, _S1205,_S1204);
    return _S1206;
}

static __device__ uint arrivalLobe_0(uint b_4, uint prev_lobe_0)
{
    bool _S1207 = b_4 > 0U;
    uint _S1208 = _slang_select(_S1207, prev_lobe_0,3U);
    return _S1208;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_2, uint lobe_2, bool surface_4, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1209;
    (&_S1209)->extinction_behind = extinction_behind_0;
    (&_S1209)->extinction_front = extinction_front_0;
    (&_S1209)->fillings = fillings_0;
    (&_S1209)->side = side_0;
    (&_S1209)->depth = depth_2;
    (&_S1209)->lobe = lobe_2;
    (&_S1209)->surface = surface_4;
    (&_S1209)->length = length_2;
    (&_S1209)->width = width_1;
    (&_S1209)->own = *own_2;
    (&_S1209)->fiber = fiber_0;
    return _S1209;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1210 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1210)
    {
        return 0.07957746833562851f;
    }
    float _S1211 = g_0 * g_0;
    return (1.0f - _S1211) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1211 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_8, float3  b_5)
{
    float3  _S1212 = a_8 / b_5;
    float3  _S1213 = make_float3 (0.0f);
    bool3  _S1214 = b_5 == _S1213;
    float3  _S1215 = _slang_select(_S1214, _S1213,_S1212);
    return _S1215;
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_6)
{
    Reservoir candidate_2 = r_7;
    uint _S1216 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1217 = insertBits_0(_S1216, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1217;
    (&candidate_2)->f = f_6;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_4)
{
    Random _S1218 = draw(random_state_4, 11U);
    Random _S1219 = draw(random_state_4, 2147483659U);
    float _S1220 = 1.0f - 2.0f * _S1218.value;
    float _S1221 = (F32_sqrt(((F32_max((1.0f - _S1220 * _S1220), (0.0f))))));
    float _S1222 = 6.28318548202514648f * _S1219.value;
    return make_float3 (_S1221 * (F32_cos((_S1222))), _S1221 * (F32_sin((_S1222))), _S1220);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_5, float * pdf_4)
{
    bool _S1223 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1223)
    {
        *pdf_4 = 0.07957746833562851f;
        float3  _S1224 = isotropic_0(random_state_5);
        return _S1224;
    }
    Random _S1225 = draw(random_state_5, 11U);
    Random _S1226 = draw(random_state_5, 2147483659U);
    float _S1227 = g_1 * g_1;
    float _S1228 = 2.0f * g_1;
    float _S1229 = (1.0f - _S1227) / (1.0f - g_1 + _S1228 * _S1225.value);
    float _S1230 = clamp_1((1.0f + _S1227 - _S1229 * _S1229) / _S1228, -1.0f, 1.0f);
    float _S1231 = (F32_sqrt(((F32_max((1.0f - _S1230 * _S1230), (0.0f))))));
    float _S1232 = 6.28318548202514648f * _S1226.value;
    float _S1233 = phaseHG_0(g_1, _S1230);
    *pdf_4 = _S1233;
    float3  _S1234 = tangentToWorld(make_float3 (_S1231 * (F32_cos((_S1232))), _S1230, _S1231 * (F32_sin((_S1232)))), dir_9);
    float3  _S1235 = ((((_S1234)) * make_float3(rnorm3df(((_S1234)).x, ((_S1234)).y, ((_S1234)).z))));
    return _S1235;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_1, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_1, float velvet_0, float3  toon_2, float dispersion_0, float coat_2, float coat_roughness_0, float coat_ior_0, float3  coat_tint_0, float3  coat_normal_0)
{
    BSDFMaterial _S1236;
    (&_S1236)->albedo = albedo_1;
    (&_S1236)->emissive = emissive_0;
    (&_S1236)->roughness = roughness_0;
    (&_S1236)->metallic = metallic_0;
    (&_S1236)->transmission = transmission_0;
    (&_S1236)->ior = ior_1;
    (&_S1236)->absorption = absorption_0;
    (&_S1236)->specular_tint = specular_tint_0;
    (&_S1236)->specular_level = specular_level_0;
    (&_S1236)->translucent = translucent_0;
    (&_S1236)->sheen = sheen_2;
    (&_S1236)->sheen_roughness = sheen_roughness_0;
    (&_S1236)->anisotropy = anisotropy_0;
    (&_S1236)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1236)->tangent = tangent_1;
    (&_S1236)->velvet = velvet_0;
    (&_S1236)->toon = toon_2;
    (&_S1236)->dispersion = dispersion_0;
    (&_S1236)->coat = coat_2;
    (&_S1236)->coat_roughness = coat_roughness_0;
    (&_S1236)->coat_ior = coat_ior_0;
    (&_S1236)->coat_tint = coat_tint_0;
    (&_S1236)->coat_normal = coat_normal_0;
    return _S1236;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1237;
    (&_S1237)->scatter = scatter_1;
    (&_S1237)->extinction = extinction_1;
    (&_S1237)->g = g_2;
    return _S1237;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_15, bool skip_0, uint random_state_6, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1238;
    (&_S1238)->smooth_n = smooth_n_4;
    (&_S1238)->geometry_n = geometry_n_2;
    (&_S1238)->geometry_offset = geometry_offset_2;
    (&_S1238)->material = *material_15;
    (&_S1238)->skip = skip_0;
    (&_S1238)->random_state = random_state_6;
    (&_S1238)->coverage = coverage_0;
    (&_S1238)->encloses = encloses_0;
    (&_S1238)->volume = *volume_0;
    (&_S1238)->fills = fills_0;
    (&_S1238)->hair = hair_0;
    return _S1238;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S1239 = (&surface_5->material)->emissive;
    float3  _S1240 = make_float3 (0.0f);
    bool _S1241 = !top_0;
    float3  _S1242 = _slang_select(_S1241, _S1240,_S1239);
    (&(&lower_0)->material)->emissive = _S1242;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_1)
{
    float _S1243 = surface_6->coverage;
    bool _S1244 = u_1 < _S1243;
    if(_S1244)
    {
        return *surface_6;
    }
    float3  _S1245 = make_float3 (0.0f);
    float3  _S1246 = make_float3 (1.0f);
    BSDFMaterial _S1247 = Material_x24init_0(_S1245, _S1245, 0.0f, 0.0f, 0.0f, 0.0f, _S1245, _S1246, 1.0f, _S1245, _S1245, 0.5f, 0.0f, 0.0f, _S1245, 0.0f, _S1245, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, _S1246, _S1245);
    BSDFMaterial material_16 = _S1247;
    (&material_16)->albedo = _S1246;
    (&material_16)->emissive = (&surface_6->material)->emissive;
    (&material_16)->transmission = 1.0f;
    (&material_16)->ior = 1.0f;
    (&material_16)->absorption = (&surface_6->material)->absorption;
    FKSurface through_1 = *surface_6;
    (&through_1)->material = material_16;
    return through_1;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S1248 = transmission_1 > 0.0f;
    bool _S1249;
    if(_S1248)
    {
        _S1249 = true;
    }
    else
    {
        _S1249 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1250;
    if(_S1249)
    {
        _S1250 = 1.0f;
    }
    else
    {
        _S1250 = -1.0f;
    }
    return _S1250;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_8)
{
    return (dot_0(dir_10, n_8)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_11)
{
    float3  _S1251 = surface_7->geometry_n;
    float _S1252 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_11);
    FKSurface faced_0 = *surface_7;
    float3  _S1253 = surface_7->smooth_n * make_float3 (_S1252);
    (&faced_0)->smooth_n = _S1253;
    float3  _S1254 = _S1251 * make_float3 (_S1252);
    (&faced_0)->geometry_n = _S1254;
    return faced_0;
}

static __device__ float3  max_0(float3  x_23, float3  y_7)
{
    float3  result_13;
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
        *_slang_vector_get_element_ptr(&result_13, i_21) = (F32_max((_slang_vector_get_element(x_23, i_21)), (_slang_vector_get_element(y_7, i_21))));
        i_21 = i_21 + int(1);
    }
    return result_13;
}

static __device__ float3  log_0(float3  x_24)
{
    float3  result_14;
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
        *_slang_vector_get_element_ptr(&result_14, i_22) = (F32_log((_slang_vector_get_element(x_24, i_22))));
        i_22 = i_22 + int(1);
    }
    return result_14;
}

__device__ float3  beerLambert(float distance_3, float3  absorption_1)
{
    float3  _S1255 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1255));
}

__device__ bool dispersive(BSDFMaterial material_17)
{
    bool _S1256 = (material_17.dispersion) > 0.0f;
    bool _S1257;
    if(_S1256)
    {
        _S1257 = (material_17.ior) != 1.0f;
    }
    else
    {
        _S1257 = false;
    }
    return _S1257;
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
        uint _S1258 = (low_1 + high_1 + 1U) / 2U;
        bool _S1259 = (WAVELENGTH_CDF_0[_S1258]) <= u_2;
        if(_S1259)
        {
            low_1 = _S1258;
        }
        else
        {
            uint _S1260 = _S1258 - 1U;
            high_1 = _S1260;
        }
    }
    uint _S1261 = low_1;
    float _S1262 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_2 - WAVELENGTH_CDF_0[_S1261]) / _S1262), _S1262 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_5)
{
    float _S1263 = clamp_1((wavelength_5 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1264 = (U32_min((uint(_S1263)), (79U)));
    uint _S1265 = 3U * _S1264;
    float3  _S1266 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1265], WAVELENGTH_WEIGHTS_0[_S1265 + 1U], WAVELENGTH_WEIGHTS_0[_S1265 + 2U]);
    float3  _S1267 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1265 + 3U], WAVELENGTH_WEIGHTS_0[_S1265 + 4U], WAVELENGTH_WEIGHTS_0[_S1265 + 5U]);
    return _S1266 + (_S1267 - _S1266) * make_float3 (_S1263 - float(_S1264));
}

__device__ float dispersedIor(float ior_2, float dispersion_1, float wavelength_6)
{
    float _S1268 = (ior_2 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1269 = _S1268 * (1.0f / (wavelength_6 * wavelength_6) - 2.89662933349609375f);
    bool _S1270 = dispersion_1 > 0.0f;
    float _S1271 = _slang_select(_S1270, _S1269,0.0f);
    return ior_2 + _S1271;
}

__device__ float2  vertexEta(BSDFMaterial material_18, float n_dot_v_0)
{
    bool _S1272 = n_dot_v_0 < 0.0f;
    float _S1273 = _slang_select(_S1272, material_18.ior,1.0f);
    float _S1274 = _slang_select(_S1272, 1.0f,material_18.ior);
    return make_float2 (_S1273, _S1274);
}

__device__ float2  wavelengthEta(BSDFMaterial material_19, float n_dot_v_1, float wavelength_7)
{
    BSDFMaterial refractive_0 = material_19;
    float _S1275 = dispersedIor(material_19.ior, material_19.dispersion, wavelength_7);
    bool _S1276 = wavelength_7 > 0.0f;
    float _S1277 = _slang_select(_S1276, _S1275,material_19.ior);
    (&refractive_0)->ior = _S1277;
    float2  _S1278 = vertexEta(refractive_0, n_dot_v_1);
    return _S1278;
}

static __device__ float unshared_0(float x_25)
{
    return x_25;
}

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_6, float U1_0, float U2_0)
{
    float3  _S1279 = make_float3 (alpha_6 * Ve_0.x, alpha_6 * Ve_0.y, Ve_0.z);
    float3  _S1280 = ((((_S1279)) * make_float3(rnorm3df(((_S1279)).x, ((_S1279)).y, ((_S1279)).z))));
    float _S1281 = _S1280.x;
    float _S1282 = _S1280.y;
    float _S1283 = _S1281 * _S1281 + _S1282 * _S1282;
    float3  _S1284;
    if(_S1283 > 0.0f)
    {
        float3  _S1285 = make_float3 (- _S1282, _S1281, 0.0f);
        float _S1286 = (rsqrtf((_S1283)));
        _S1284 = _S1285 * make_float3 (_S1286);
    }
    else
    {
        _S1284 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S1287 = cross_0(_S1280, _S1284);
    float _S1288 = (F32_sqrt((U1_0)));
    float _S1289 = 6.28318548202514648f * U2_0;
    float _S1290 = _S1288 * (F32_cos((_S1289)));
    float t2_0 = _S1288 * (F32_sin((_S1289)));
    float _S1291 = 0.5f * (1.0f + _S1280.z);
    float t2_1 = (1.0f - _S1291) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S1290 * _S1290)))))) + _S1291 * t2_0;
    float3  _S1292 = make_float3 (_S1290) * _S1284 + make_float3 (t2_1) * _S1287;
    float _S1293 = unshared_0(_S1290);
    float _S1294 = unshared_0(_S1290);
    float3  _S1295 = _S1292 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S1293 * _S1294 - t2_1 * t2_1))))))) * _S1280;
    float3  _S1296 = make_float3 (alpha_6 * _S1295.x, alpha_6 * _S1295.y, (F32_max((0.0f), (_S1295.z))));
    float3  _S1297 = ((((_S1296)) * make_float3(rnorm3df(((_S1296)).x, ((_S1296)).y, ((_S1296)).z))));
    return _S1297;
}

__device__ float3  worldToTangent(float3  v_8, float3  n_9)
{
    float3  a_9 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S1298 = (F32_abs((dot_0(n_9, a_9)))) > 0.9999847412109375f;
    float3  a_10;
    if(_S1298)
    {
        float3  _S1299 = make_float3 (1.0f, 0.0f, 0.0f);
        a_10 = _S1299;
    }
    else
    {
        a_10 = a_9;
    }
    float3  _S1300 = cross_0(n_9, a_10);
    float3  _S1301 = ((((_S1300)) * make_float3(rnorm3df(((_S1300)).x, ((_S1300)).y, ((_S1300)).z))));
    float3  _S1302 = cross_0(n_9, _S1301);
    return make_float3 (dot_0(v_8, _S1301), dot_0(v_8, n_9), dot_0(v_8, _S1302));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_9, float3  n_i_11, float alpha_7, AnisotropicFrame frame_5, uint * random_state_7, uint first_2)
{
    Random _S1303 = draw(*random_state_7, first_2);
    Random _S1304 = draw(*random_state_7, first_2 | 2147483648U);
    *random_state_7 = _S1304.state;
    float _S1305 = frame_5.alphas.x;
    bool _S1306 = _S1305 > 0.0f;
    if(_S1306)
    {
        float3  _S1307 = anisotropicLocal(v_9, frame_5.tangent, n_i_11);
        float _S1308 = frame_5.alphas.y;
        float3  _S1309 = make_float3 (_S1305 * _S1307.x, _S1308 * _S1307.y, _S1307.z);
        float3  _S1310 = ((((_S1309)) * make_float3(rnorm3df(((_S1309)).x, ((_S1309)).y, ((_S1309)).z))));
        float3  _S1311 = sampleGGXVNDF(_S1310, 1.0f, _S1303.value, _S1304.value);
        float3  _S1312 = make_float3 (_S1305 * _S1311.x, _S1308 * _S1311.y, _S1311.z);
        float3  _S1313 = ((((_S1312)) * make_float3(rnorm3df(((_S1312)).x, ((_S1312)).y, ((_S1312)).z))));
        return make_float3 (_S1313.x) * frame_5.tangent + make_float3 (_S1313.y) * cross_0(n_i_11, frame_5.tangent) + make_float3 (_S1313.z) * n_i_11;
    }
    float3  _S1314 = worldToTangent(v_9, n_i_11);
    float3  _S1315 = sampleGGXVNDF(float3 {_S1314.x, _S1314.z, _S1314.y}, alpha_7, _S1303.value, _S1304.value);
    float3  _S1316 = float3 {_S1315.x, _S1315.z, _S1315.y};
    float3  _S1317 = tangentToWorld(_S1316, n_i_11);
    return _S1317;
}

__device__ __forceinline__ float3  coatHalf(float3  v_10, CoatFrame coat_frame_4, uint random_state_8)
{
    bool _S1318 = !((dot_0(coat_frame_4.normal, v_10)) > 0.0f);
    if(_S1318)
    {
        return make_float3 (0.0f);
    }
    uint state_2 = random_state_8;
    float3  _S1319 = sampleHalfVector(v_10, coat_frame_4.normal, coat_frame_4.alpha, AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f)), &state_2, 1U);
    return _S1319;
}

static __device__ Facets Facets_x24init_0(float3  h_3, float3  coat_h_3)
{
    Facets _S1320;
    (&_S1320)->h = h_3;
    (&_S1320)->coat_h = coat_h_3;
    return _S1320;
}

__device__ Facets drawFacets(float3  in_dir_5, float3  n_10, BSDFMaterial material_20, uint random_state_9)
{
    float3  _S1321 = negate_0(in_dir_5);
    float _S1322 = sign_0(dot_0(n_10, _S1321));
    float3  _S1323 = n_10 * make_float3 (_S1322);
    uint state_3 = random_state_9;
    float _S1324 = material_20.roughness;
    float _S1325 = _S1324 * _S1324;
    AnisotropicFrame _S1326 = anisotropicFrame(material_20, _S1323);
    float3  _S1327 = sampleHalfVector(_S1321, _S1323, _S1325, _S1326, &state_3, 0U);
    CoatFrame _S1328 = coatFrame(material_20, _S1323);
    float3  _S1329 = coatHalf(_S1321, _S1328, random_state_9);
    return Facets_x24init_0(_S1327, _S1329);
}

__device__ bool neeDecision(BSDFMaterial material_21, float n_dot_v_2, float eta_i_5, float eta_o_4)
{
    float _S1330 = fresnel((F32_abs((n_dot_v_2))), eta_i_5, eta_o_4);
    float3  _S1331 = mix_0(make_float3 (_S1330), material_21.albedo, material_21.metallic);
    float _S1332 = rgb_to_greyscale(_S1331);
    float _S1333 = (F32_max(((1.0f - _S1332) * (1.0f - material_21.metallic) * (1.0f - material_21.transmission)), (0.0f)));
    bool _S1334 = _S1333 > 0.03999999910593033f;
    bool _S1335;
    if(_S1334)
    {
        _S1335 = true;
    }
    else
    {
        _S1335 = (material_21.roughness) > 0.20000000298023224f;
    }
    return _S1335;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_22)
{
    float _S1336 = rgb_to_greyscale(material_22->translucent);
    return _S1336 > 0.0f;
}

struct MediumSides
{
    FKMedium behind;
    FKMedium front;
    uint2  fillings;
    float3  face;
};

static __device__ MediumSides MediumSides_x24init_0(FKMedium * behind_1, FKMedium * front_0, uint2  fillings_1, float3  face_1)
{
    MediumSides _S1337;
    (&_S1337)->behind = *behind_1;
    (&_S1337)->front = *front_0;
    (&_S1337)->fillings = fillings_1;
    (&_S1337)->face = face_1;
    return _S1337;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1338 = surface_8->geometry_n;
    MediumSides _S1339 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S1339;
    bool _S1340 = surface_8->encloses;
    if(_S1340)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S1341 = (dot_0(dir_12, _S1338)) > 0.0f;
        if(_S1341)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_3, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1342 = surface_9->geometry_n;
    ShadowContext _S1343 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1344 = surface_9->encloses;
    ShadowContext context_4;
    if(_S1344)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S1345 = - _S1342;
        float3  _S1346 = _slang_select(turned_0, _S1345,_S1342);
        (&faced_1)->geometry_n = _S1346;
        FKMedium _S1347 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1348 = faced_1;
        FKMedium _S1349 = _S1347;
        MediumSides _S1350 = mediumSides_0(&_S1348, &_S1349, filling_1, dir_13, outside_1);
        ShadowContext _S1351 = ShadowContext_x24init_0(_S1350.behind.extinction, _S1350.front.extinction, _S1350.fillings, _S1342, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1352 = _S1350.fillings;
            ShadowContext _S1353 = ShadowContext_x24init_0(_S1350.front.extinction, _S1350.behind.extinction, uint2 {_S1352.y, _S1352.x}, _S1342, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1353;
        }
        else
        {
            context_4 = _S1351;
        }
    }
    else
    {
        context_4 = _S1343;
    }
    return context_4;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_6, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_3, BSDFMaterial * material_23, float eta_i_6, float eta_o_5, bool competing_1, Facets * facets_3)
{
    float3  _S1354 = light_2->dir;
    bool _S1355 = (dot_0(geometry_n_3, - in_dir_6) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 6>  throughputs_1;
    FixedArray<float, 6>  pdfs_4;
    BSDF(in_dir_6, _S1354, smooth_n_5, *material_23, eta_i_6, eta_o_5, _S1355, *facets_3, &throughputs_1, &pdfs_4);
    bool _S1356;
    if(competing_1)
    {
        _S1356 = (light_2->density) != 0.0f;
    }
    else
    {
        _S1356 = false;
    }
    float3  _S1357 = make_float3 (0.0f);
    uint i_23 = 0U;
    float3  f_7 = _S1357;
    for(;;)
    {
        if(i_23 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S1358 = (pdfs_4[i_23]) > 0.0f;
        if(_S1358)
        {
            float3  f_8;
            if(_S1356)
            {
                float _S1359 = light_2->density;
                float _S1360 = pdfs_4[i_23] / light_2->density;
                float3  f_9 = f_7 + throughputs_1[i_23] * make_float3 (pdfs_4[i_23]) / make_float3 (_S1359 * (1.0f + _S1360 * _S1360));
                f_8 = f_9;
            }
            else
            {
                float3  f_10 = f_7 + throughputs_1[i_23] * make_float3 (pdfs_4[i_23]);
                f_8 = f_10;
            }
            f_7 = f_8;
        }
        uint i_24 = i_23 + 1U;
        i_23 = i_24;
    }
    if(_S1356)
    {
        f_7 = f_7 * light_2->radiance * make_float3 (light_2->density);
    }
    else
    {
        f_7 = f_7 * light_2->radiance;
    }
    return f_7;
}

__device__ float3  skyBSDF(float3  in_dir_7, float3  dir_14, FKSurface surface_10, BSDFMaterial material_24, float2  eta_3, bool is_inside_4, Facets facets_4, float pdf_5)
{
    FKSurface _S1361 = surface_10;
    BSDFMaterial _S1362 = material_24;
    Facets _S1363 = facets_4;
    FixedArray<float3 , 6>  terms_3;
    FixedArray<float, 6>  pdfs_5;
    float3  _S1364 = skyLobes_0(in_dir_7, dir_14, &_S1361, &_S1362, eta_3, is_inside_4, &_S1363, pdf_5, &terms_3, &pdfs_5);
    return _S1364;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_10, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S1365;
    (&_S1365)->unit_direction = unit_direction_1;
    (&_S1365)->throughput = throughput_1;
    (&_S1365)->random_state = random_state_10;
    (&_S1365)->refracted = refracted_3;
    (&_S1365)->lobe = lobe_4;
    (&_S1365)->pdf = pdf_6;
    return _S1365;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  v_11, float3  n_i_12, float n_i_dot_v_3, BSDFMaterial material_25, Weights w_14, uint random_state_11)
{
    float3  _S1366 = make_float3 (1.0f);
    SampleBSDF _S1367 = SampleBSDF_x24init_0(_S1366, _S1366, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1367;
    Random _S1368 = draw(random_state_11, 3U);
    Random _S1369 = draw(random_state_11, 2147483651U);
    (&sample_1)->random_state = _S1369.state;
    float _S1370 = _S1368.value;
    float _S1371 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1370 * _S1370))))));
    float _S1372 = 6.28318548202514648f * _S1369.value;
    float3  _S1373 = tangentToWorld(make_float3 (_S1371 * (F32_cos((_S1372))), _S1368.value, _S1371 * (F32_sin((_S1372)))), n_i_12);
    (&sample_1)->unit_direction = _S1373;
    (&sample_1)->lobe = 4U;
    float3  _S1374 = sheenVelvetBSDF((&sample_1)->unit_direction, v_11, n_i_12, material_25, w_14);
    (&sample_1)->throughput = _S1374;
    float _S1375 = sheenVelvetPDF(_S1368.value, n_i_dot_v_3, w_14);
    (&sample_1)->pdf = _S1375;
    return sample_1;
}

__device__ __forceinline__ SampleBSDF coatSample(float3  in_dir_8, float3  v_12, float3  coat_h_4, CoatFrame coat_frame_5, Weights w_15, uint random_state_12)
{
    float3  _S1376 = make_float3 (1.0f);
    SampleBSDF _S1377 = SampleBSDF_x24init_0(_S1376, _S1376, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1377;
    float3  _S1378 = reflect_0(in_dir_8, coat_h_4);
    float3  _S1379 = ((((_S1378)) * make_float3(rnorm3df(((_S1378)).x, ((_S1378)).y, ((_S1378)).z))));
    (&sample_2)->unit_direction = _S1379;
    (&sample_2)->random_state = random_state_12;
    (&sample_2)->lobe = 5U;
    float3  _S1380 = coatBSDF(w_15);
    (&sample_2)->throughput = _S1380;
    float _S1381 = coatPDF(v_12, coat_h_4, coat_frame_5, w_15);
    (&sample_2)->pdf = _S1381;
    return sample_2;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1382 = (F32_sqrt((random_1_0)));
    float _S1383 = 6.28318548202514648f * random_2_0;
    float _S1384 = _S1382 * (F32_cos((_S1383)));
    float _S1385 = _S1382 * (F32_sin((_S1383)));
    float _S1386 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1384 * _S1384 - _S1385 * _S1385))))));
    return make_float3 (_S1384, _S1386, _S1385);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_13, float n_i_dot_v_4, BSDFMaterial material_26, Weights w_16, uint random_state_13)
{
    float3  _S1387 = make_float3 (1.0f);
    SampleBSDF _S1388 = SampleBSDF_x24init_0(_S1387, _S1387, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1388;
    Random _S1389 = draw(random_state_13, 3U);
    Random _S1390 = draw(random_state_13, 2147483651U);
    (&sample_3)->random_state = _S1390.state;
    float3  _S1391 = sampleCosWeightedHemisphere(_S1389.value, _S1390.value);
    float _S1392 = translucentShare(material_26);
    bool _S1393 = u_3 < (w_16.p_diffuse * _S1392);
    float _S1394 = _S1391.y;
    float _S1395 = - _S1394;
    float _S1396 = _slang_select(_S1393, _S1395,_S1394);
    float3  _S1397 = tangentToWorld(make_float3 (_S1391.x, _S1396, _S1391.z), n_i_13);
    (&sample_3)->unit_direction = _S1397;
    (&sample_3)->refracted = _S1393;
    (&sample_3)->lobe = 0U;
    float3  _S1398 = diffuseBSDF((&sample_3)->unit_direction, n_i_13, material_26, w_16);
    (&sample_3)->throughput = _S1398;
    float _S1399 = diffusePDF(_S1396, n_i_dot_v_4, material_26, w_16);
    (&sample_3)->pdf = _S1399;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_14, ToonProfile profile_3, Weights w_17, uint random_state_14)
{
    float3  _S1400 = make_float3 (1.0f);
    SampleBSDF _S1401 = SampleBSDF_x24init_0(_S1400, _S1400, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1401;
    Random _S1402 = draw(random_state_14, 3U);
    Random _S1403 = draw(random_state_14, 2147483651U);
    (&sample_4)->random_state = _S1403.state;
    float _S1404 = _S1402.value * profile_3.norm / 6.28318548202514648f;
    float t_23;
    if(profile_3.glossy)
    {
        t_23 = (F32_acos((clamp_1(1.0f - _S1404, -1.0f, 1.0f))));
    }
    else
    {
        t_23 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1404)))), (1.0f))))));
    }
    if(t_23 < (profile_3.a))
    {
    }
    else
    {
        t_23 = (profile_3.a + profile_3.b) / 2.0f;
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
        float _S1405 = toonP(t_23, profile_3.a, profile_3.s);
        float _S1406 = _S1405 * (F32_sin((t_23)));
        float _S1407;
        if(profile_3.glossy)
        {
            _S1407 = 1.0f;
        }
        else
        {
            _S1407 = (F32_cos((t_23)));
        }
        float _S1408 = _S1406 * _S1407;
        float _S1409 = toonIntegral(t_23, profile_3.a, profile_3.s, profile_3.glossy);
        float _S1410 = (_S1409 - _S1404) / _S1408;
        bool _S1411 = _S1408 > 0.0f;
        float _S1412 = _slang_select(_S1411, _S1410,0.0f);
        float _S1413 = clamp_1(t_23 - _S1412, 0.0f, profile_3.b);
        int k_3 = k_2 + int(1);
        t_23 = _S1413;
        k_2 = k_3;
    }
    float _S1414 = 6.28318548202514648f * _S1403.value;
    float _S1415 = (F32_sin((t_23)));
    float3  _S1416 = tangentToWorld(make_float3 (_S1415 * (F32_cos((_S1414))), (F32_cos((t_23))), _S1415 * (F32_sin((_S1414)))), profile_3.axis);
    (&sample_4)->unit_direction = _S1416;
    bool _S1417 = (dot_0(n_i_14, (&sample_4)->unit_direction)) < 0.0f;
    (&sample_4)->refracted = _S1417;
    (&sample_4)->lobe = 6U;
    float3  _S1418 = toonBSDF((&sample_4)->unit_direction, n_i_14, profile_3, w_17);
    (&sample_4)->throughput = _S1418;
    float _S1419 = toonPDF((&sample_4)->unit_direction, n_i_14, profile_3, w_17);
    (&sample_4)->pdf = _S1419;
    return sample_4;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_1, float3  n_i_15, float alpha_8, AnisotropicFrame frame_6, BSDFMaterial material_27, Weights w_18, float pdf_h_3, float eta_i_7, float eta_o_6, uint random_state_15)
{
    float3  _S1420 = make_float3 (1.0f);
    SampleBSDF _S1421 = SampleBSDF_x24init_0(_S1420, _S1420, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1421;
    (&sample_5)->unit_direction = w_18.refracted;
    (&sample_5)->random_state = random_state_15;
    (&sample_5)->refracted = true;
    (&sample_5)->lobe = 1U;
    float3  _S1422 = refractBSDF((&sample_5)->unit_direction, n_i_15, alpha_8, frame_6, material_27, w_18);
    (&sample_5)->throughput = _S1422;
    float _S1423 = refractPDF(dot_0((&sample_5)->unit_direction, ggx_n_1), pdf_h_3, w_18, eta_i_7, eta_o_6);
    (&sample_5)->pdf = _S1423;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_2, float3  n_i_16, float alpha_9, AnisotropicFrame frame_7, Weights w_19, float pdf_h_4, uint random_state_16)
{
    float3  _S1424 = make_float3 (1.0f);
    SampleBSDF _S1425 = SampleBSDF_x24init_0(_S1424, _S1424, 0U, false, 0U, 0.0f);
    SampleBSDF sample_6 = _S1425;
    float3  _S1426 = reflect_0(in_dir_9, ggx_n_2);
    float3  _S1427 = ((((_S1426)) * make_float3(rnorm3df(((_S1426)).x, ((_S1426)).y, ((_S1426)).z))));
    (&sample_6)->unit_direction = _S1427;
    (&sample_6)->random_state = random_state_16;
    (&sample_6)->lobe = 2U;
    float3  _S1428 = reflectBSDF((&sample_6)->unit_direction, n_i_16, alpha_9, frame_7, w_19);
    (&sample_6)->throughput = _S1428;
    float _S1429 = reflectPDF(pdf_h_4, w_19);
    (&sample_6)->pdf = _S1429;
    return sample_6;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_11, BSDFMaterial material_28, float eta_i_8, float eta_o_7, Facets facets_5, uint random_init_0, float2  screen_space_0)
{
    float3  _S1430 = negate_0(in_dir_10);
    float _S1431 = dot_0(n_11, _S1430);
    float _S1432 = sign_0(_S1431);
    float3  n_i_17 = n_11 * make_float3 (_S1432);
    float _S1433 = (F32_abs((_S1431)));
    float _S1434 = material_28.roughness;
    float _S1435 = _S1434 * _S1434;
    AnisotropicFrame _S1436 = anisotropicFrame(material_28, n_i_17);
    SheenProfile _S1437 = sheenProfile(_S1430, n_i_17, material_28);
    CoatFrame _S1438 = coatFrame(material_28, n_i_17);
    float3  _S1439 = coatSeries(_S1438, material_28);
    Weights _S1440 = lobeWeights(in_dir_10, _S1430, n_i_17, facets_5.h, facets_5.coat_h, facets_5.h, facets_5.coat_h, _S1436, _S1437, _S1438, _S1439, material_28, eta_i_8, eta_o_7);
    Random _S1441 = draw(random_init_0, 2U);
    bool _S1442 = (_S1441.value) < (_S1440.p_sheen_velvet);
    if(_S1442)
    {
        SampleBSDF _S1443 = sheenVelvetSample(_S1430, n_i_17, _S1433, material_28, _S1440, _S1441.state);
        return _S1443;
    }
    float _S1444 = _S1441.value - _S1440.p_sheen_velvet;
    bool _S1445 = _S1444 < (_S1440.p_coat);
    if(_S1445)
    {
        SampleBSDF _S1446 = coatSample(in_dir_10, _S1430, facets_5.coat_h, _S1438, _S1440, _S1441.state);
        return _S1446;
    }
    float _S1447 = _S1444 - _S1440.p_coat;
    bool _S1448 = _S1447 < (_S1440.p_diffuse);
    if(_S1448)
    {
        SampleBSDF _S1449 = diffuseSample(_S1447, n_i_17, _S1433, material_28, _S1440, _S1441.state);
        return _S1449;
    }
    bool _S1450 = _S1447 < (_S1440.p_diffuse + _S1440.p_toon);
    if(_S1450)
    {
        ToonProfile _S1451 = toonProfile(_S1430, n_i_17, material_28);
        SampleBSDF _S1452 = toonSample(n_i_17, _S1451, _S1440, _S1441.state);
        return _S1452;
    }
    float _S1453 = vndfPDF(_S1430, facets_5.h, n_i_17, _S1433, _S1435, _S1436, _S1440.v_dot_h);
    bool _S1454 = (_S1447 - _S1440.p_toon) < (_S1440.p_diffuse + _S1440.p_refract);
    if(_S1454)
    {
        SampleBSDF _S1455 = refractSample(facets_5.h, n_i_17, _S1435, _S1436, material_28, _S1440, _S1453, eta_i_8, eta_o_7, _S1441.state);
        return _S1455;
    }
    SampleBSDF _S1456 = reflectSample(in_dir_10, facets_5.h, n_i_17, _S1435, _S1436, _S1440, _S1453, _S1441.state);
    return _S1456;
}

__device__ __forceinline__ float3  reflectedHalf(float3  in_dir_11, float3  out_dir_1)
{
    float3  _S1457 = negate_0(in_dir_11);
    float3  _S1458 = _S1457 + out_dir_1;
    float3  _S1459 = ((((_S1458)) * make_float3(rnorm3df(((_S1458)).x, ((_S1458)).y, ((_S1458)).z))));
    return _S1459;
}

__device__ __forceinline__ float3  refractedHalf(float3  in_dir_12, float3  out_dir_2, float3  n_12, float eta_i_9, float eta_o_8)
{
    float3  _S1460 = negate_0(in_dir_12);
    float3  _S1461 = negate_0(make_float3 (eta_i_9) * _S1460 + make_float3 (eta_o_8) * out_dir_2);
    float3  _S1462 = ((((_S1461)) * make_float3(rnorm3df(((_S1461)).x, ((_S1461)).y, ((_S1461)).z))));
    float _S1463 = sign_0(dot_0(n_12, _S1460));
    float _S1464 = sign_0(dot_0(_S1461, n_12 * make_float3 (_S1463)));
    return _S1462 * make_float3 (_S1464);
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
    bool _S1465;
    bool _S1466;
    float density_2;
    float wavelength_8;
    float width_3;
    float sky_pdf_0;
    float threshold_0;
    uint b_6;
    uint layer_0;
    float3  throughput_2;
    float3  spectral_weight_0;
    TreeSample light_3;
    int _S1467;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_4;
    float sky_pdf_1;
    float spread_3;
    float width_5;
    uint b_7;
    float3  _S1468 = make_float3 (0.0f);
    Shift _S1469 = Shift_x24init_0(_S1468, 0.0f);
    uint _S1470 = r_8->path;
    uint _S1471 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1472 = extractBits_0(_S1470, 5U, 5U);
    uint _S1473 = extractBits_0(_S1470, 10U, 2U);
    uint _S1474 = extractBits_0(_S1470, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S1475 = _S1474 >= 3U;
        uint _S1476 = _slang_select(_S1475, 1U,0U);
        uint _S1477 = _S1471 + _S1476;
        uint _S1478 = (fcptMaxBounces());
        passes_0 = _S1477 > _S1478;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1469;
    }
    uint _S1479 = _S1472 - 1U;
    bool _S1480 = _S1474 == 3U;
    uint _S1481 = _slang_select(_S1480, 1U,0U);
    uint _S1482 = _S1471 + _S1481;
    bool _S1483 = _S1473 == 0U;
    uint _S1484 = _slang_select(_S1483, _S1482,_S1479);
    FKHit _S1485 = (fcptReservoirHit((*r_8)));
    float3  _S1486 = dom_7->x0;
    float3  _S1487 = dom_7->x1 - dom_7->x0;
    float3  _S1488 = ((((_S1487)) * make_float3(rnorm3df(((_S1487)).x, ((_S1487)).y, ((_S1487)).z))));
    FKRay _S1489 = Ray_x24init_0(dom_7->x1, _S1488);
    FKRay ray_2 = _S1489;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1468;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_2 = throughput_3;
    float3  glowed_0 = _S1468;
    float3  extinction_in_0 = _S1468;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1490 = dom_7->spread;
    float _S1491 = dom_7->width;
    float _S1492 = length_0(_S1487);
    NEEVertex _S1493 = NEEVertex_x24init_0(true, 0.0f, _S1468, _S1468, _S1468);
    NEEVertex nee_vertex_0 = _S1493;
    Vertex _S1494 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1494;
    Reservoir _S1495 = (Reservoir{});
    Reservoir chain_0 = _S1495;
    uint _S1496 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    uint _S1497 = extractBits_0(_S1470, 24U, 8U);
    uint _S1498 = insertBits_0(0U, _S1497, 24U, 8U);
    (&chain_0)->path = _S1498;
    (&ray_2)->origin = _S1486;
    (&hit_4)->distance = _S1492;
    FKMedium _S1499 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1500 = filling_2;
    bool _S1501 = (fcptVaryingUsed());
    uint _S1502 = _slang_select(_S1501, _S1500,4294967295U);
    filling_2 = _S1502;
    scatter_in_0 = _S1499.scatter;
    extinction_in_0 = _S1499.extinction;
    g_in_0 = _S1499.g;
    Reservoir _S1503 = chain_0;
    uint _S1504 = filling_2;
    for(;;)
    {
        bool _S1505 = (fcptVaryingUsed());
        if(_S1505)
        {
            passes_0 = _S1504 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1506 = (fcptMajorant((_S1504)));
            spread_1 = _S1506;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S1484;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1473 == 1U;
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
            ended_0 = _S1469;
            sky_pdf_0 = 0.0f;
            spread_1 = _S1490;
            width_3 = _S1491;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_6 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1507 = (&prev_0)->rough;
        if(_S1507)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1508 = stream(_S1496, 384U);
        uint tracking_0 = _S1508;
        weight_2 = throughput_3;
        glowed_0 = _S1468;
        b_6 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        wavelength_8 = _S1490;
        width_3 = _S1491;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1467 = int(1);
                break;
            }
            float _S1509 = (&hit_4)->distance;
            if(passes_0)
            {
                float3  _S1510 = (&ray_2)->origin;
                float3  _S1511 = (&ray_2)->unit_direction;
                float _S1512 = (&hit_4)->distance;
                bool _S1513 = b_6 == 4294967295U;
                uint _S1514 = _slang_select(_S1513, 0U,b_6);
                uint _S1515 = (&prev_0)->lobe;
                uint _S1516 = _slang_select(_S1513, 3U,_S1515);
                float _S1517 = (fcptTrackMedium((_S1504), (_S1510), (_S1511), (_S1512), (&tracking_0), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1514), (_S1516), (_S1513)));
                threshold_0 = _S1517;
            }
            else
            {
                bool _S1518 = spread_1 > 0.0f;
                if(_S1518)
                {
                    uint _S1519 = noiseAddress(_S1496, b_6);
                    Random _S1520 = draw(_S1519, 10U);
                    float _S1521 = - (F32_log((1.0f - _S1520.value))) / spread_1;
                    threshold_0 = _S1521;
                }
                else
                {
                    threshold_0 = _S1509;
                }
            }
            bool _S1522 = !(threshold_0 < ((&hit_4)->distance));
            if(_S1522)
            {
                _S1467 = int(1);
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
                float3  _S1523 = pathColor(throughput_2 * glowed_0, throughput_3, 0.0f);
                float3  _S1524 = _S1523 / make_float3 (density_2);
                float3  _S1525 = sel_7->glow + _S1524;
                sel_7->glow = _S1525;
            }
            else
            {
            }
            glowed_0 = _S1468;
            uint b_8 = b_6 + 1U;
            float3  _S1526 = (&ray_2)->origin + make_float3 (threshold_0) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1526;
            float3  _S1527 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, threshold_0, true);
            float3  _S1528 = weight_2;
            float _S1529 = upsample(weight_2, 0.0f);
            float3  _S1530 = make_float3 (_S1529);
            float3  _S1531 = _slang_select(false, _S1530,_S1528);
            float3  _S1532 = _slang_select(passes_0, _S1531,_S1527);
            float3  throughput_4 = throughput_2 * _S1532;
            uint _S1533 = stream(_S1496, b_8 + 320U);
            tracking_0 = _S1533;
            weight_2 = throughput_3;
            float width_6 = width_3 + wavelength_8 * threshold_0;
            float _S1534 = wavelength_8 + 3.14159274101257324f;
            bool _S1535 = !replay_1;
            if(_S1535)
            {
                is_inside_5 = true;
            }
            else
            {
                bool _S1536 = b_8 == _S1484;
                if(_S1536)
                {
                    is_inside_5 = !passes_0;
                }
                else
                {
                    is_inside_5 = false;
                }
            }
            TreeSample _S1537 = TreeSample_x24init_0(_S1468, _S1468, 0.0f, 0U);
            if(is_inside_5)
            {
                float3  _S1538 = (&ray_2)->origin;
                float3  _S1539 = (&ray_2)->unit_direction;
                float3  _S1540 = (&ray_2)->unit_direction;
                uint _S1541 = noiseAddress(_S1496, b_8);
                float3  _S1542 = extinction_in_0;
                float3  _S1543 = extinction_in_0;
                uint2  _S1544 = make_uint2 (_S1504);
                float3  _S1545 = (&ray_2)->unit_direction;
                uint _S1546 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                FKHit _S1547 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1548 = _S1547;
                ShadowContext _S1549 = ShadowContext_x24init_0(_S1542, _S1543, _S1544, _S1545, b_8, _S1546, false, threshold_0, width_6, &_S1548, false);
                ShadowContext _S1550 = _S1549;
                TreeSample _S1551 = sampleLightTree_0(_S1538, _S1539, _S1540, 0.0f, true, _S1541, &_S1550);
                light_3 = _S1551;
            }
            else
            {
                light_3 = _S1537;
            }
            float _S1552 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1553 = (fcptMaxBounces());
            bool _S1554 = b_8 < _S1553;
            if(_S1554)
            {
                viewed_0 = (light_3.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S1555 = _slang_select(viewed_0, _S1552,0.0f);
            float3  _S1556 = throughput_4 * light_3.radiance;
            float _S1557 = powerHeuristic(light_3.density, _S1555);
            float3  _S1558 = pathColor(_S1556 * make_float3 (_S1552 * _S1557), throughput_3, 0.0f);
            float3  _S1559 = _slang_select(is_inside_5, _S1558,_S1468);
            if(replay_1)
            {
                _S1465 = b_8 == _S1484;
            }
            else
            {
                _S1465 = false;
            }
            if(_S1465)
            {
                bool _S1560 = _S1473 == 2U;
                if(_S1560)
                {
                    float _S1561 = resamplingTarget(_S1559);
                    passes_0 = _S1561 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1562 = Shift_x24init_0(_S1559, 1.0f);
                    _S1467 = int(0);
                    ended_0 = _S1562;
                    spread_1 = _S1534;
                    threshold_0 = width_6;
                    spectral_weight_0 = throughput_4;
                    layer_0 = b_8;
                    break;
                }
                _S1467 = int(0);
                ended_0 = _S1469;
                spread_1 = _S1534;
                threshold_0 = width_6;
                spectral_weight_0 = throughput_4;
                layer_0 = b_8;
                break;
            }
            if(_S1535)
            {
                Reservoir candidate_3 = _S1503;
                uint _S1563 = extractBits_0(_S1503.path, 24U, 8U);
                uint _S1564 = insertBits_0(0U, _S1563, 24U, 8U);
                uint _S1565 = extractBits_0(_S1503.path, 10U, 2U);
                bool _S1566 = _S1565 == 1U;
                if(_S1566)
                {
                    float3  _S1567 = safeDivide(_S1559, _S1468);
                    (&candidate_3)->radiance = _S1567;
                }
                else
                {
                    uint _S1568 = insertBits_0(_S1564, b_8 + 1U, 5U, 5U);
                    uint _S1569 = insertBits_0(_S1568, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1569;
                }
                Reservoir _S1570 = withEnd(candidate_3, 0U, b_8, _S1559);
                offer(sel_7, _S1570, _S1559 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1571 = survivalProbability(abs_0(throughput_4), density_2);
                uint _S1572 = (fcptMaxBounces());
                bool _S1573 = b_8 >= _S1572;
                if(_S1573)
                {
                    _S1466 = true;
                }
                else
                {
                    bool _S1574 = _S1571 < 1.0f;
                    if(_S1574)
                    {
                        uint _S1575 = noiseAddress(_S1496, b_8);
                        Random _S1576 = draw(_S1575, 8U);
                        _S1466 = _S1571 < (_S1576.value);
                    }
                    else
                    {
                        _S1466 = false;
                    }
                }
                if(_S1466)
                {
                    _S1467 = int(0);
                    ended_0 = _S1469;
                    spread_1 = _S1534;
                    threshold_0 = width_6;
                    spectral_weight_0 = throughput_4;
                    layer_0 = b_8;
                    break;
                }
                float _S1577 = density_2 * _S1571;
                density_2 = _S1577;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1578 = noiseAddress(_S1496, b_8);
            float3  _S1579 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1578, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1579;
            NEEVertex _S1580 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1468, (&ray_2)->origin);
            nee_vertex_0 = _S1580;
            Vertex _S1581 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_0 = _S1581;
            float _S1582 = (&prev_0)->pdf;
            FKRay _S1583 = ray_2;
            FKHit _S1584 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1585 = (fcptTraverseInstanceBVH((_S1583), (true), (4.294967296e+09f), (false), (_S1584), (false)));
            hit_4 = _S1585;
            b_6 = b_8;
            throughput_2 = throughput_4;
            wavelength_8 = _S1534;
            width_3 = width_6;
            sky_pdf_0 = _S1582;
        }
        if(_S1467 != int(1))
        {
            width_3 = threshold_0;
            throughput_2 = spectral_weight_0;
            b_6 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1469;
        spread_1 = wavelength_8;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1586 = b_6 == 4294967295U;
    bool _S1587 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1587)
    {
        bool _S1588 = !(&nee_vertex_0)->none;
        float _S1589 = _slang_select(_S1588, sky_pdf_0,0.0f);
        float _S1590 = escapeWeight_0(_S1589, (&ray_2)->unit_direction);
        float3  _S1591 = environment_0((&ray_2)->unit_direction, b_6, (&prev_0)->lobe);
        float3  _S1592 = pathColor(throughput_2 * _S1591, throughput_3, 0.0f);
        if(replay_1)
        {
            bool _S1593 = b_6 == _S1484;
            if(_S1593)
            {
                passes_0 = _S1473 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1592 * make_float3 (_S1590) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1483)
            {
                passes_0 = _S1480;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_6 == _S1471;
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
                return Shift_x24init_0(_S1592 * make_float3 (_S1590), 1.0f);
            }
            return _S1469;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1594 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1595 = _S1594 == 1U;
        if(_S1595)
        {
            uint _S1596 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1597 = _S1596 == b_6;
            float _S1598 = _slang_select(_S1597, 1.0f,_S1590);
            float3  _S1599 = safeDivide(_S1592 * make_float3 (_S1598), _S1468);
            (&candidate_4)->radiance = _S1599;
        }
        else
        {
            bool _S1600 = (&prev_0)->rough;
            if(_S1600)
            {
                uint _S1601 = insertBits_0(_S1498, b_6 + 1U, 5U, 5U);
                uint _S1602 = insertBits_0(_S1601, 3U, 10U, 2U);
                uint _S1603 = insertBits_0(_S1602, (&prev_0)->lobe, 15U, 3U);
                bool _S1604 = (&prev_0)->inside;
                uint _S1605 = _slang_select(_S1604, 1U,0U);
                uint _S1606 = insertBits_0(_S1603, _S1605, 22U, 1U);
                (&candidate_4)->path = _S1606;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1607 = _S1592 * make_float3 (_S1590);
        Reservoir _S1608 = withEnd(candidate_4, 3U, b_6, _S1607);
        offer(sel_7, _S1608, _S1607 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1469;
    }
    float3  _S1609 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1609;
    bool _S1610 = (fcptVaryingUsed());
    if(_S1610)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1611 = !replay_1;
        if(_S1611)
        {
            float3  _S1612 = pathColor(throughput_2 * glowed_0, throughput_3, 0.0f);
            float3  _S1613 = _S1612 / make_float3 (density_2);
            float3  _S1614 = sel_7->glow + _S1613;
            sel_7->glow = _S1614;
        }
        float3  _S1615 = throughput_2 * weight_2;
        throughput_2 = _S1615;
    }
    else
    {
        float3  _S1616 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1617 = throughput_2 * _S1616;
        throughput_2 = _S1617;
    }
    float _S1618 = width_3 + spread_1 * (&hit_4)->distance;
    uint _S1619 = b_6 + 1U;
    b_6 = _S1619;
    layer_0 = 0U;
    width_3 = _S1618;
    passes_0 = false;
    wavelength_8 = 0.0f;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    spectral_weight_0 = throughput_3;
    float3  chain_throughput_0 = _S1468;
    float3  reconnection_0 = _S1468;
    viewed_0 = _S1586;
    for(;;)
    {
        bool _S1620 = ((&hit_4)->is_point_light) == 1U;
        if(replay_1)
        {
            _S1465 = _S1473 == 1U;
        }
        else
        {
            _S1465 = false;
        }
        if(_S1465)
        {
            _S1466 = b_6 == _S1472;
        }
        else
        {
            _S1466 = false;
        }
        bool _S1621;
        if(_S1466)
        {
            bool _S1622 = ((&hit_4)->instance_index) != (_S1485.instance_index);
            if(_S1622)
            {
                _S1621 = true;
            }
            else
            {
                _S1621 = ((&hit_4)->triangle_index) != (_S1485.triangle_index);
            }
        }
        else
        {
            _S1621 = false;
        }
        if(_S1621)
        {
            return _S1469;
        }
        FKMedium _S1623 = Medium_x24init_0(_S1468, _S1468, 0.0f);
        BSDFMaterial _S1624 = Material_x24init_0(_S1468, _S1468, 0.0f, 0.0f, 0.0f, 0.0f, _S1468, throughput_3, 1.0f, _S1468, _S1468, 0.5f, 0.0f, 0.0f, _S1468, 0.0f, _S1468, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, throughput_3, _S1468);
        FKMedium _S1625 = _S1623;
        FKSurface _S1626 = Surface_x24init_0(_S1468, _S1468, 0.0f, &_S1624, false, 0U, 1.0f, false, &_S1625, 4294967295U, _S1468);
        bool _S1627 = !_S1620;
        bool scatter_2;
        bool is_inside_6;
        float geometry_density_0;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S1627)
        {
            uint _S1628 = noiseAddress(_S1496, b_6);
            uint _S1629 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKSurface _S1630 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1628), (width_3), (layer_0), (b_6), (_S1629), ((&ray_2)->unit_direction)));
            bool _S1631 = !passes_0;
            FKSurface _S1632 = _S1630;
            FKSurface _S1633 = emitting_0(&_S1632, _S1631);
            uint _S1634 = noiseAddress(_S1496, b_6);
            Random _S1635 = draw(_S1634, 9U);
            FKSurface _S1636 = _S1633;
            FKSurface _S1637 = uncovered_0(&_S1636, _S1635.value);
            float _S1638 = facingSign(_S1637.material.transmission, _S1637.geometry_n, (&ray_2)->unit_direction);
            bool _S1639 = _S1638 < 0.0f;
            bool _S1640 = (_S1637.material.transmission) > 0.0f;
            if(_S1640)
            {
                bool _S1641 = arrivesBehind_0((&ray_2)->unit_direction, _S1637.geometry_n);
                scatter_2 = _S1641;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1642 = _S1637;
            FKSurface _S1643 = facingRay_0(&_S1642, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1644 = arrivesBehind_0((&ray_2)->unit_direction, _S1643.geometry_n);
                is_inside_6 = _S1644;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float _S1645 = (&hit_4)->distance;
                float _S1646 = upsample(_S1643.material.absorption, wavelength_8);
                float3  _S1647 = make_float3 (_S1646);
                bool _S1648 = wavelength_8 > 0.0f;
                float3  _S1649 = _slang_select(_S1648, _S1647,_S1643.material.absorption);
                float3  _S1650 = beerLambert(_S1645, _S1649);
                float3  _S1651 = throughput_2 * _S1650;
                throughput_5 = _S1651;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1652 = !_S1643.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S1643.geometry_n, (&ray_2)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1653 = b_6 == _S1619;
            if(_S1653)
            {
                float _S1654 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1654;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S1655 = geometry_density_0;
            scatter_2 = _S1652;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1655;
            surface_12 = _S1643;
            turned_1 = _S1639;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_12 = _S1626;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S1656;
        if(scatter_2)
        {
            _S1656 = (&prev_0)->rough;
        }
        else
        {
            _S1656 = false;
        }
        bool _S1657;
        if(_S1656)
        {
            _S1657 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1657 = false;
        }
        FKSurface _S1658 = surface_12;
        float _S1659 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        bool _S1660 = (fcptDispersionUsed());
        bool _S1661;
        if(_S1660)
        {
            _S1661 = wavelength_8 == 0.0f;
        }
        else
        {
            _S1661 = false;
        }
        bool _S1662;
        if(_S1661)
        {
            _S1662 = scatter_2;
        }
        else
        {
            _S1662 = false;
        }
        bool _S1663;
        if(_S1662)
        {
            bool _S1664 = dispersive(surface_12.material);
            _S1663 = _S1664;
        }
        else
        {
            _S1663 = false;
        }
        float3  throughput_6;
        if(_S1663)
        {
            uint _S1665 = stream(_S1496, 512U);
            Random _S1666 = pcg(_S1665);
            uint _S1667 = extractBits_0(_S1470, 25U, 7U);
            float _S1668 = (float(_S1667) + _S1666.value) / 128.0f;
            uint _S1669 = extractBits_0(_S1470, 24U, 1U);
            bool _S1670 = _S1669 == 1U;
            float _S1671 = _slang_select(_S1670, _S1668,_S1666.value);
            float2  _S1672 = sampleWavelength(_S1671);
            float wavelength_9 = _S1672.x;
            float3  _S1673 = wavelengthWeights(wavelength_9);
            float3  _S1674 = _S1673 / make_float3 (_S1672.y);
            float _S1675 = upsample(throughput_5, wavelength_9);
            float3  _S1676 = make_float3 (_S1675);
            float _S1677 = upsample(scatter_in_0, wavelength_9);
            float3  _S1678 = make_float3 (_S1677);
            scatter_in_0 = _S1678;
            float _S1679 = upsample(extinction_in_0, wavelength_9);
            float3  _S1680 = make_float3 (_S1679);
            extinction_in_0 = _S1680;
            wavelength_8 = wavelength_9;
            throughput_6 = _S1676;
            spectral_weight_0 = _S1674;
        }
        else
        {
            throughput_6 = throughput_5;
        }
        BSDFMaterial _S1681 = pathMaterial(surface_12.material, wavelength_8);
        float2  _S1682 = wavelengthEta(_S1681, _S1659, wavelength_8);
        FKSurface _S1683 = surface_12;
        Facets _S1684 = drawFacets((&ray_2)->unit_direction, _S1658.smooth_n, _S1681, surface_12.random_state);
        bool _S1685;
        if(scatter_2)
        {
            bool _S1686 = neeDecision(_S1681, _S1659, _S1682.x, _S1682.y);
            _S1685 = _S1686;
        }
        else
        {
            _S1685 = false;
        }
        bool _S1687;
        if(passes_0)
        {
            _S1687 = true;
        }
        else
        {
            _S1687 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1687)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1685;
        }
        bool _S1688 = (fcptHairUsed());
        bool _S1689;
        if(_S1688)
        {
            float3  _S1690 = surface_12.hair;
            _S1689 = (dot_0(_S1690, _S1690)) > 0.0f;
        }
        else
        {
            _S1689 = false;
        }
        bool _S1691;
        if(_S1689)
        {
            _S1691 = true;
        }
        else
        {
            BSDFMaterial _S1692 = _S1681;
            bool _S1693 = isTranslucent_0(&_S1692);
            _S1691 = _S1693;
        }
        bool _S1694;
        if(_S1691)
        {
            _S1694 = true;
        }
        else
        {
            bool _S1695 = (_S1681.transmission) > 0.0f;
            if(_S1695)
            {
                uint _S1696 = (fcptLayers((hit_4)));
                _S1694 = _S1696 == 1U;
            }
            else
            {
                _S1694 = false;
            }
        }
        float3  emission_0;
        if(_S1620)
        {
            float3  _S1697 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1697;
        }
        else
        {
            emission_0 = _S1681.emissive;
        }
        bool _S1698 = !replay_1;
        bool _S1699;
        if(_S1698)
        {
            _S1699 = true;
        }
        else
        {
            _S1699 = b_6 >= _S1484;
        }
        bool _S1700;
        if(_S1699)
        {
            float _S1701 = rgb_to_greyscale(emission_0);
            _S1700 = _S1701 > 0.0f;
        }
        else
        {
            _S1700 = false;
        }
        float3  emission_1;
        if(_S1700)
        {
            NEEVertex _S1702 = nee_vertex_0;
            FKHit _S1703 = hit_4;
            float _S1704 = emissionWeight_0(&_S1702, &_S1703, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1704);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1705;
        if(replay_1)
        {
            _S1705 = _S1473 == 1U;
        }
        else
        {
            _S1705 = false;
        }
        bool _S1706;
        if(_S1705)
        {
            _S1706 = b_6 > _S1472;
        }
        else
        {
            _S1706 = false;
        }
        bool _S1707;
        if(_S1706)
        {
            _S1707 = b_6 == _S1471;
        }
        else
        {
            _S1707 = false;
        }
        bool _S1708;
        if(_S1707)
        {
            bool _S1709 = _S1474 == 1U;
            if(_S1709)
            {
                _S1708 = true;
            }
            else
            {
                _S1708 = _S1474 == 2U;
            }
        }
        else
        {
            _S1708 = false;
        }
        if(_S1708)
        {
            bool _S1710 = _S1620 != (_S1474 == 2U);
            if(_S1710)
            {
                return _S1469;
            }
            float3  _S1711 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_8);
            return Shift_x24init_0(_S1711 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1712 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1713 = _S1712 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1714 = insertBits_0(_S1498, b_6, 5U, 5U);
        uint _S1715 = insertBits_0(_S1714, 1U, 10U, 2U);
        uint _S1716 = insertBits_0(_S1715, (&prev_0)->lobe, 15U, 3U);
        bool _S1717 = (&prev_0)->inside;
        uint _S1718 = _slang_select(_S1717, 1U,0U);
        uint _S1719 = insertBits_0(_S1716, _S1718, 22U, 1U);
        (&here_0)->path = _S1719;
        uint _S1720 = (&here_0)->path;
        bool _S1721 = wavelength_8 > 0.0f;
        uint _S1722 = _slang_select(_S1721, 1U,0U);
        uint _S1723 = insertBits_0(_S1720, _S1722, 23U, 1U);
        (&here_0)->path = _S1723;
        float _S1724 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S1724;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1725;
        if(replay_1)
        {
            _S1725 = _S1473 == 1U;
        }
        else
        {
            _S1725 = false;
        }
        bool _S1726;
        if(_S1725)
        {
            _S1726 = b_6 == _S1472;
        }
        else
        {
            _S1726 = false;
        }
        bool _S1727 = b_6 == _S1484;
        bool _S1728;
        if(_S1727)
        {
            bool _S1729 = !scatter_2;
            if(_S1729)
            {
                _S1728 = true;
            }
            else
            {
                bool _S1730 = _S1473 != 1U;
                if(_S1730)
                {
                    _S1728 = _S1473 != 3U;
                }
                else
                {
                    _S1728 = false;
                }
            }
        }
        else
        {
            _S1728 = false;
        }
        bool _S1731;
        if(_S1728)
        {
            _S1731 = _S1473 == 2U;
        }
        else
        {
            _S1731 = false;
        }
        bool _S1732;
        if(_S1731)
        {
            _S1732 = !_S1657;
        }
        else
        {
            _S1732 = false;
        }
        bool _S1733;
        if(_S1732)
        {
            _S1733 = _S1474 != 4U;
        }
        else
        {
            _S1733 = false;
        }
        bool _S1734 = _S1472 == _S1471;
        bool _S1735;
        if(_S1734)
        {
            _S1735 = _S1474 == 0U;
        }
        else
        {
            _S1735 = false;
        }
        bool _S1736;
        if(_S1735)
        {
            _S1736 = ((&hit_4)->instance_index) == (_S1485.instance_index);
        }
        else
        {
            _S1736 = false;
        }
        bool _S1737;
        if(_S1736)
        {
            _S1737 = ((&hit_4)->triangle_index) == (_S1485.triangle_index);
        }
        else
        {
            _S1737 = false;
        }
        bool _S1738;
        if(_S1737)
        {
            _S1738 = _S1657;
        }
        else
        {
            _S1738 = false;
        }
        bool _S1739 = _slang_select(_S1726, _S1738,_S1733);
        bool _S1740;
        if(nee_0)
        {
            _S1740 = _slang_select(replay_1, _S1739,scatter_2);
        }
        else
        {
            _S1740 = false;
        }
        TreeSample _S1741 = TreeSample_x24init_0(_S1468, _S1468, 0.0f, 0U);
        uint2  _S1742 = make_uint2 (0U);
        float2  _S1743 = make_float2 (0.0f);
        FKHit _S1744 = Hit_x24init_0(_S1743, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1745 = _S1744;
        ShadowContext _S1746 = ShadowContext_x24init_0(_S1468, _S1468, _S1742, _S1468, 0U, 0U, false, 0.0f, 0.0f, &_S1745, false);
        bool _S1747;
        if(nee_0)
        {
            _S1747 = _S1699;
        }
        else
        {
            _S1747 = false;
        }
        ShadowContext context_5;
        if(_S1747)
        {
            uint _S1748 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKMedium _S1749 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1750 = surface_12;
            FKHit _S1751 = hit_4;
            FKMedium _S1752 = _S1749;
            ShadowContext _S1753 = shadowContext_0(&_S1750, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_6, _S1748, (&hit_4)->distance, width_3, &_S1751, _S1689, &_S1752);
            context_5 = _S1753;
        }
        else
        {
            context_5 = _S1746;
        }
        float3  throughput_7;
        float3  lit_0;
        if(_S1740)
        {
            float3  _S1754 = (&ray_2)->origin;
            if(_S1689)
            {
                throughput_7 = _S1468;
            }
            else
            {
                throughput_7 = _S1658.smooth_n;
            }
            FKSurface _S1755 = surface_12;
            uint _S1756 = noiseAddress(_S1496, b_6);
            ShadowContext _S1757 = context_5;
            TreeSample _S1758 = sampleLightTree_0(_S1754, throughput_7, surface_12.geometry_n, surface_12.geometry_offset, _S1694, _S1756, &_S1757);
            bool _S1759 = any_1((_S1758.radiance) != _S1468);
            if(_S1759)
            {
                if(_S1689)
                {
                    uint _S1760 = (fcptMaxBounces());
                    bool _S1761 = b_6 < _S1760;
                    FKSurface _S1762 = surface_12;
                    TreeSample _S1763 = _S1758;
                    float3  _S1764 = hairLight_0(&_S1762, (&ray_2)->unit_direction, &_S1763, _S1761);
                    lit_0 = _S1764;
                }
                else
                {
                    float _S1765 = _S1682.x;
                    float _S1766 = _S1682.y;
                    uint _S1767 = (fcptMaxBounces());
                    bool _S1768 = b_6 < _S1767;
                    TreeSample _S1769 = _S1758;
                    BSDFMaterial _S1770 = _S1681;
                    Facets _S1771 = _S1684;
                    float3  _S1772 = lightBSDF_0((&ray_2)->unit_direction, &_S1769, _S1658.smooth_n, _S1755.geometry_n, &_S1770, _S1765, _S1766, _S1768, &_S1771);
                    lit_0 = _S1772;
                }
            }
            else
            {
                lit_0 = _S1468;
            }
            light_3 = _S1758;
        }
        else
        {
            light_3 = _S1741;
            lit_0 = _S1468;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1773;
        bool _S1774;
        float density_4;
        if(_S1726)
        {
            bool _S1775 = !_S1657;
            if(_S1775)
            {
                return _S1469;
            }
            uint _S1776 = extractBits_0(_S1470, 23U, 1U);
            bool _S1777 = _S1721 != (_S1776 == 1U);
            if(_S1777)
            {
                return _S1469;
            }
            float3  throughput_8 = throughput_6 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S1734)
            {
                viewed_1 = _S1474 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                float3  _S1778 = pathColor(throughput_8 * emission_1, spectral_weight_0, wavelength_8);
                return Shift_x24init_0(_S1778 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1734)
            {
                refracted_4 = _S1474 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1779 = !nee_0;
                if(_S1779)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1780 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1780 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1469;
                }
                float3  _S1781 = pathColor(throughput_8 * lit_0, spectral_weight_0, wavelength_8);
                return Shift_x24init_0(_S1781 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1734)
            {
                wrong_side_0 = _S1474 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1782 = !nee_0;
                if(_S1782)
                {
                    return _S1469;
                }
                bool _S1783 = (fcptWorldReadsPath());
                if(_S1783)
                {
                    float3  _S1784 = r_8->dir;
                    float _S1785 = environmentPdf_0(r_8->dir);
                    FKSurface _S1786 = surface_12;
                    BSDFMaterial _S1787 = _S1681;
                    Facets _S1788 = _S1684;
                    FixedArray<float3 , 6>  terms_4;
                    FixedArray<float, 6>  pdfs_6;
                    float3  _S1789 = skyLobes_0((&ray_2)->unit_direction, _S1784, &_S1786, &_S1787, _S1682, is_inside_6, &_S1788, _S1785, &terms_4, &pdfs_6);
                    uint _S1790 = b_6 + 1U;
                    FixedArray<float3 , 6>  _S1791 = terms_4;
                    FixedArray<float, 6>  _S1792 = pdfs_6;
                    float3  _S1793 = skyColor_0(_S1784, &_S1791, &_S1792, _S1790);
                    float3  _S1794 = pathColor(throughput_8 * (_S1793 * r_8->radiance), spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S1794 / make_float3 (r_8->jac), density_5 / r_8->jac);
                }
                float _S1795 = environmentPdf_0(r_8->dir);
                float3  _S1796 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_12, _S1681, _S1682, is_inside_6, _S1684, _S1795);
                float3  _S1797 = pathColor(throughput_8 * _S1796 * r_8->radiance, spectral_weight_0, wavelength_8);
                return Shift_x24init_0(_S1797 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1798 = extractBits_0(_S1470, 21U, 1U);
            bool _S1799 = nee_0 != (_S1798 == 1U);
            if(_S1799)
            {
                return _S1469;
            }
            throughput_7 = throughput_8;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S1727;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1800 = !scatter_2;
                if(_S1800)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1801 = _S1473 != 1U;
                    if(_S1801)
                    {
                        refracted_4 = _S1473 != 3U;
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
                bool _S1802 = _S1473 == 2U;
                if(_S1802)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1657;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1474 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1689)
                    {
                        return _S1469;
                    }
                    uint _S1803 = noiseAddress(_S1496, b_6);
                    FKRay _S1804 = ray_2;
                    FKSurface _S1805 = surface_12;
                    Facets _S1806 = _S1684;
                    ShadowContext _S1807 = context_5;
                    SkySample _S1808 = sampleSky_0(&_S1804, &_S1805, wavelength_8, _S1682, is_inside_6, _S1803, &_S1806, &_S1807);
                    float3  _S1809 = pathColor(throughput_6 * _S1808.color, spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S1809, 1.0f);
                }
                if(_S1802)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1657;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1810 = rgb_to_greyscale(light_3.radiance);
                    bool _S1811 = !(_S1810 > 0.0f);
                    if(_S1811)
                    {
                        return _S1469;
                    }
                    float3  _S1812 = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S1812, 1.0f);
                }
                if(_S1483)
                {
                    passes_0 = _S1474 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1620;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1813 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S1813, 1.0f);
                }
                if(_S1483)
                {
                    passes_0 = _S1474 == 1U;
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
                    passes_0 = !_S1657;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1814 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S1814, 1.0f);
                }
                return _S1469;
            }
            else
            {
                if(_S1698)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1815 = b_6 > 0U;
                    if(_S1815)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1713)
                        {
                            float3  _S1816 = safeDivide(throughput_6 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1816;
                        }
                        else
                        {
                            if(_S1657)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1817 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_8);
                        Reservoir _S1818 = withEnd(candidate_5, 1U, b_6, _S1817);
                        offer(sel_7, _S1818, _S1817 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1819 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_8);
                        float3  _S1820 = sel_7->glow + _S1819;
                        sel_7->glow = _S1820;
                    }
                    if(nee_0)
                    {
                        float3  _S1821 = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_8);
                        Reservoir candidate_6 = chain_0;
                        if(_S1713)
                        {
                            float3  _S1822 = safeDivide(_S1821, chain_throughput_0);
                            (&candidate_6)->radiance = _S1822;
                        }
                        else
                        {
                            if(_S1657)
                            {
                                candidate_6 = here_0;
                                uint _S1823 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1823;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1824 = insertBits_0(_S1498, b_6 + 1U, 5U, 5U);
                                uint _S1825 = insertBits_0(_S1824, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1825;
                            }
                        }
                        Reservoir _S1826 = withEnd(candidate_6, 0U, b_6, _S1821);
                        offer(sel_7, _S1826, _S1821 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1689)
                        {
                            _S1773 = false;
                        }
                        else
                        {
                            bool _S1827 = environmentMapped_0();
                            _S1773 = _S1827;
                        }
                    }
                    else
                    {
                        _S1773 = false;
                    }
                    if(_S1773)
                    {
                        uint _S1828 = (fcptMaxBounces());
                        _S1774 = b_6 < _S1828;
                    }
                    else
                    {
                        _S1774 = false;
                    }
                    if(_S1774)
                    {
                        uint _S1829 = noiseAddress(_S1496, b_6);
                        FKRay _S1830 = ray_2;
                        FKSurface _S1831 = surface_12;
                        Facets _S1832 = _S1684;
                        ShadowContext _S1833 = context_5;
                        SkySample _S1834 = sampleSky_0(&_S1830, &_S1831, wavelength_8, _S1682, is_inside_6, _S1829, &_S1832, &_S1833);
                        float3  _S1835 = pathColor(throughput_6 * _S1834.color, spectral_weight_0, wavelength_8);
                        Reservoir candidate_7 = chain_0;
                        if(_S1713)
                        {
                            float3  _S1836 = safeDivide(_S1835, chain_throughput_0);
                            (&candidate_7)->radiance = _S1836;
                        }
                        else
                        {
                            if(_S1657)
                            {
                                candidate_7 = here_0;
                                uint _S1837 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1837;
                                (&candidate_7)->dir = _S1834.dir;
                                (&candidate_7)->radiance = _S1834.radiance;
                            }
                            else
                            {
                                uint _S1838 = insertBits_0(_S1498, b_6 + 1U, 5U, 5U);
                                uint _S1839 = insertBits_0(_S1838, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1839;
                            }
                        }
                        Reservoir _S1840 = withEnd(candidate_7, 4U, b_6, _S1835);
                        offer(sel_7, _S1840, _S1835 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_7 = throughput_6;
            density_4 = density_2;
        }
        bool _S1841;
        bool _S1842;
        bool _S1843;
        bool straight_0;
        bool _S1844;
        bool _S1845;
        bool _S1846;
        bool _S1847;
        bool _S1848;
        bool _S1849;
        bool _S1850;
        bool _S1851;
        bool _S1852;
        bool _S1853;
        bool _S1854;
        bool _S1855;
        bool _S1856;
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
                viewed_1 = _S1727;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1857 = extractBits_0(_S1470, 15U, 3U);
            uint _S1858 = extractBits_0(_S1470, 18U, 3U);
            uint _S1859 = _slang_select(_S1726, _S1858,_S1857);
            float3  _S1860 = r_8->dir;
            bool refracted_5 = _S1859 == 1U;
            SampleBSDF _S1861 = SampleBSDF_x24init_0(_S1468, _S1468, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1861;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1862 = extractBits_0(_S1470, 22U, 1U);
                bool _S1863 = is_inside_6 != (_S1862 == 1U);
                if(_S1863)
                {
                    return _S1469;
                }
                bool _S1864 = _S1473 == 1U;
                if(_S1864)
                {
                    float3  _S1865 = (fcptHitPosition((_S1485)));
                    throughput_9 = _S1865;
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
                    BSDFMaterial _S1866 = _S1681;
                    bool _S1867 = isTranslucent_0(&_S1866);
                    if(_S1867)
                    {
                        refracted_4 = _S1859 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1868 = throughput_9 - (&ray_2)->origin;
                        float3  _S1869 = _slang_select(_S1864, _S1868,_S1860);
                        wrong_side_0 = (dot_0(_S1658.smooth_n, _S1869) * _S1659) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1864)
                {
                    float3  _S1870 = (&ray_2)->origin;
                    FKSurface _S1871 = surface_12;
                    float3  _S1872 = - _S1658.smooth_n;
                    bool _S1873 = is_inside_6 != refracted_4;
                    float3  _S1874 = _slang_select(_S1873, _S1872,_S1658.smooth_n);
                    float3  _S1875 = throughput_9 - (_S1870 + make_float3 (_S1871.geometry_offset) * _S1874);
                    float3  _S1876 = ((((_S1875)) * make_float3(rnorm3df(((_S1875)).x, ((_S1875)).y, ((_S1875)).z))));
                    reconnection_1 = _S1876;
                }
                else
                {
                    reconnection_1 = _S1860;
                }
                if(_S1689)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1877 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1877;
                }
                if(wrong_side_0)
                {
                    return _S1469;
                }
                float3  _S1878 = throughput_9;
                throughput_9 = reconnection_1;
                b_9 = _S1859;
                wrong_side_0 = false;
                reconnection_1 = _S1878;
            }
            else
            {
                bool _S1879 = !_S1726;
                if(_S1879)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1880;
                    if(_S1689)
                    {
                        SampleBSDF _S1881 = (fcptSampleHair((surface_12.hair), (_S1681.albedo), (_S1681.specular_tint), ((&ray_2)->unit_direction), (_S1683.random_state)));
                        _S1880 = _S1881;
                    }
                    else
                    {
                        SampleBSDF _S1882 = sampleBSDF((&ray_2)->unit_direction, _S1658.smooth_n, _S1681, _S1682.x, _S1682.y, _S1684, _S1683.random_state, _S1743);
                        _S1880 = _S1882;
                    }
                    bsdf_sampled_0 = _S1880;
                    if(_S1689)
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
                            return _S1469;
                        }
                        break;
                    }
                    if(_S1689)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1883 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1883;
                    }
                    if(wrong_side_0)
                    {
                        _S1773 = (_S1681.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1773 = false;
                    }
                    if(_S1773)
                    {
                        float _S1884 = _S1682.x;
                        float _S1885 = _S1682.y;
                        Facets _S1886 = drawFacets((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1681, (&bsdf_sampled_0)->random_state);
                        SampleBSDF _S1887 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1681, _S1884, _S1885, _S1886, (&bsdf_sampled_0)->random_state, _S1743);
                        (&bsdf_sampled_0)->unit_direction = _S1887.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1887.refracted;
                        (&bsdf_sampled_0)->throughput = _S1887.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1888 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1888;
                        }
                    }
                    uint _S1889 = (&bsdf_sampled_0)->lobe;
                    float3  _S1890 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1891 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1892 = (&bsdf_sampled_0)->pdf;
                    float _S1893 = _slang_select(wrong_side_0, 0.0f,_S1892);
                    (&lobe_5)->pdf = _S1893;
                    throughput_9 = _S1890;
                    b_9 = _S1889;
                    refracted_4 = _S1891;
                }
                else
                {
                    throughput_9 = _S1860;
                    b_9 = _S1859;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1773 = true;
            }
            else
            {
                _S1773 = _S1726;
            }
            if(_S1773)
            {
                if(_S1689)
                {
                    SampleBSDF _S1894 = (fcptConnectHair((surface_12.hair), (_S1681.albedo), (_S1681.specular_tint), ((&ray_2)->unit_direction), (throughput_9)));
                    lobe_5 = _S1894;
                }
                else
                {
                    float3  _S1895 = (&ray_2)->unit_direction;
                    float3  _S1896 = negate_0(_S1895);
                    float _S1897 = sign_0(_S1659);
                    float3  _S1898 = _S1658.smooth_n * make_float3 (_S1897);
                    float _S1899 = dot_0(_S1898, throughput_9);
                    float _S1900 = _S1681.roughness;
                    float _S1901 = _S1900 * _S1900;
                    AnisotropicFrame _S1902 = anisotropicFrame(_S1681, _S1898);
                    SheenProfile _S1903 = sheenProfile(_S1896, _S1898, _S1681);
                    CoatFrame _S1904 = coatFrame(_S1681, _S1898);
                    float3  _S1905 = coatSeries(_S1904, _S1681);
                    float3  _S1906 = reflectedHalf(_S1895, throughput_9);
                    bool _S1907 = b_9 == 1U;
                    if(_S1907)
                    {
                        float3  _S1908 = refractedHalf(_S1895, throughput_9, _S1658.smooth_n, _S1682.x, _S1682.y);
                        throughput_10 = _S1908;
                    }
                    else
                    {
                        throughput_10 = _S1906;
                    }
                    float3  _S1909 = reflectedHalf(_S1895, throughput_9);
                    float3  _S1910 = _S1684.coat_h;
                    bool _S1911 = (dot_0(_S1910, _S1910)) > 0.0f;
                    float3  _S1912 = _slang_select(_S1911, _S1909,_S1468);
                    float _S1913 = _S1682.x;
                    float _S1914 = _S1682.y;
                    Weights _S1915 = lobeWeights(_S1895, _S1896, _S1898, _S1684.h, _S1684.coat_h, throughput_10, _S1912, _S1902, _S1903, _S1904, _S1905, _S1681, _S1913, _S1914);
                    float _S1916 = (F32_abs((_S1659)));
                    float _S1917 = vndfPDF(_S1896, throughput_10, _S1898, _S1916, _S1901, _S1902, _S1915.v_dot_h);
                    switch(b_9)
                    {
                    case 0U:
                        {
                            float _S1918 = diffusePDF(_S1899, _S1916, _S1681, _S1915);
                            float3  _S1919 = diffuseBSDF(throughput_9, _S1898, _S1681, _S1915);
                            density_6 = _S1918;
                            throughput_11 = _S1919;
                            break;
                        }
                    case 1U:
                        {
                            float _S1920 = refractPDF(dot_0(throughput_9, throughput_10), _S1917, _S1915, _S1913, _S1914);
                            float3  _S1921 = refractBSDF(throughput_9, _S1898, _S1901, _S1902, _S1681, _S1915);
                            density_6 = _S1920;
                            throughput_11 = _S1921;
                            break;
                        }
                    case 4U:
                        {
                            float _S1922 = sheenVelvetPDF(_S1899, _S1916, _S1915);
                            float3  _S1923 = sheenVelvetBSDF(throughput_9, _S1896, _S1898, _S1681, _S1915);
                            density_6 = _S1922;
                            throughput_11 = _S1923;
                            break;
                        }
                    case 5U:
                        {
                            float _S1924 = coatPDF(_S1896, _S1912, _S1904, _S1915);
                            float3  _S1925 = coatBSDF(_S1915);
                            density_6 = _S1924;
                            throughput_11 = _S1925;
                            break;
                        }
                    case 6U:
                        {
                            ToonProfile _S1926 = toonProfile(_S1896, _S1898, _S1681);
                            float _S1927 = toonPDF(throughput_9, _S1898, _S1926, _S1915);
                            float3  _S1928 = toonBSDF(throughput_9, _S1898, _S1926, _S1915);
                            density_6 = _S1927;
                            throughput_11 = _S1928;
                            break;
                        }
                    default:
                        {
                            float _S1929 = reflectPDF(_S1917, _S1915);
                            float3  _S1930 = reflectBSDF(throughput_9, _S1898, _S1901, _S1902, _S1915);
                            density_6 = _S1929;
                            throughput_11 = _S1930;
                            break;
                        }
                    }
                    bool _S1931 = density_6 > 0.0f;
                    if(_S1931)
                    {
                        SampleBSDF _S1932 = SampleBSDF_x24init_0(throughput_9, throughput_11, _S1683.random_state, _S1907, b_9, density_6);
                        lobe_5 = _S1932;
                    }
                }
            }
            bool _S1933 = b_9 == 0U;
            if(_S1933)
            {
                _S1774 = true;
            }
            else
            {
                _S1774 = b_9 == 4U;
            }
            if(_S1774)
            {
                _S1841 = true;
            }
            else
            {
                _S1841 = b_9 == 6U;
            }
            bool _S1934 = b_9 == 5U;
            float _S1935 = _slang_select(_S1934, _S1681.coat_roughness,_S1681.roughness);
            if(_S1689)
            {
                _S1842 = false;
            }
            else
            {
                bool _S1936 = !_S1841;
                if(_S1936)
                {
                    bool _S1937 = _S1935 == 0.0f;
                    if(_S1937)
                    {
                        _S1842 = true;
                    }
                    else
                    {
                        bool _S1938 = b_9 == 1U;
                        if(_S1938)
                        {
                            _S1842 = (_S1682.x) == (_S1682.y);
                        }
                        else
                        {
                            _S1842 = false;
                        }
                    }
                }
                else
                {
                    _S1842 = false;
                }
            }
            bool _S1939 = !_S1689;
            if(_S1939)
            {
                _S1843 = b_9 == 1U;
            }
            else
            {
                _S1843 = false;
            }
            if(_S1843)
            {
                straight_0 = (_S1681.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1844 = _S1939;
            }
            else
            {
                _S1844 = false;
            }
            if(_S1844)
            {
                _S1845 = b_9 == 1U;
            }
            else
            {
                _S1845 = false;
            }
            if(_S1845)
            {
                _S1846 = (_S1682.x) == (_S1682.y);
            }
            else
            {
                _S1846 = false;
            }
            BSDFMaterial _S1940 = _S1681;
            bool _S1941 = isTranslucent_0(&_S1940);
            if(_S1941)
            {
                _S1847 = _S1933;
            }
            else
            {
                _S1847 = false;
            }
            if(_S1847)
            {
                _S1848 = (dot_0(throughput_9, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1848 = false;
            }
            if(nee_0)
            {
                _S1849 = !_S1842;
            }
            else
            {
                _S1849 = false;
            }
            if(_S1849)
            {
                _S1850 = !wrong_side_0;
            }
            else
            {
                _S1850 = false;
            }
            if(_S1850)
            {
                float _S1942 = (&lobe_5)->pdf;
                float3  _S1943 = (&ray_2)->origin;
                float3  _S1944 = _slang_select(_S1694, _S1468,_S1658.smooth_n);
                float3  _S1945 = (&ray_2)->origin;
                FKSurface _S1946 = surface_12;
                float3  _S1947 = - _S1658.smooth_n;
                float3  _S1948 = _slang_select(_S1848, _S1947,_S1658.smooth_n);
                NEEVertex _S1949 = NEEVertex_x24init_0(false, _S1942, _S1943, _S1944, _S1945 + make_float3 (_S1946.geometry_offset) * _S1948);
                nee_vertex_0 = _S1949;
            }
            else
            {
                if(_S1689)
                {
                    _S1851 = true;
                }
                else
                {
                    bool _S1950 = b_9 != 1U;
                    if(_S1950)
                    {
                        _S1851 = true;
                    }
                    else
                    {
                        _S1851 = (_S1682.x) != (_S1682.y);
                    }
                }
                if(_S1851)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1951 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1951)
            {
                if(_S1841)
                {
                    _S1851 = true;
                }
                else
                {
                    _S1851 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1851 = false;
            }
            bool _S1952 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1952)
            {
                if(_S1841)
                {
                    _S1852 = true;
                }
                else
                {
                    _S1852 = _S1935 >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1852 = false;
            }
            if(_S1726)
            {
                bool _S1953 = !_S1851;
                if(_S1953)
                {
                    return _S1469;
                }
                bool _S1954 = _S1474 != 1U;
                if(_S1954)
                {
                    _S1853 = _S1474 != 2U;
                }
                else
                {
                    _S1853 = false;
                }
                if(_S1853)
                {
                    float _S1955 = (&lobe_5)->pdf;
                    float _S1956 = _slang_select(nee_0, _S1955,0.0f);
                    float _S1957 = escapeWeight_0(_S1956, _S1860);
                    if(_S1734)
                    {
                        passes_0 = _S1480;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1958 = _slang_select(passes_0, _S1957,1.0f);
                    return Shift_x24init_0(throughput_7 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1958) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1959 = throughput_7 * make_float3 ((&lobe_5)->pdf);
                float _S1960 = density_4 * (&lobe_5)->pdf;
                throughput_10 = _S1959;
                density_6 = _S1960;
            }
            else
            {
                throughput_10 = throughput_7;
                density_6 = density_4;
            }
            uint _S1961 = (fcptLayers((hit_4)));
            bool _S1962 = _S1961 > 1U;
            if(_S1962)
            {
                _S1853 = (b_9 == 1U) != passes_0;
            }
            else
            {
                _S1853 = false;
            }
            if(viewed_1)
            {
                _S1854 = _S1853;
            }
            else
            {
                _S1854 = false;
            }
            if(_S1854)
            {
                return _S1469;
            }
            if(replay_1)
            {
                _S1855 = b_6 <= _S1484;
            }
            else
            {
                _S1855 = false;
            }
            if(_S1855)
            {
                _S1856 = _S1657;
            }
            else
            {
                _S1856 = false;
            }
            bool _S1963;
            if(_S1856)
            {
                _S1963 = _S1851;
            }
            else
            {
                _S1963 = false;
            }
            bool _S1964;
            if(_S1963)
            {
                _S1964 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1964 = !_S1852;
                }
                else
                {
                    _S1964 = false;
                }
            }
            if(_S1964)
            {
                return _S1469;
            }
            if(viewed_1)
            {
                float3  _S1965 = throughput_10 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1966 = (&lobe_5)->pdf;
                throughput_11 = _S1965;
                sky_pdf_2 = _S1966;
            }
            else
            {
                float3  _S1967 = throughput_10 * max_0((&lobe_5)->throughput, _S1468);
                throughput_11 = _S1967;
                sky_pdf_2 = density_6;
            }
            bool _S1968;
            if(_S1698)
            {
                _S1968 = !_S1713;
            }
            else
            {
                _S1968 = false;
            }
            bool _S1969;
            if(_S1968)
            {
                _S1969 = _S1657;
            }
            else
            {
                _S1969 = false;
            }
            bool _S1970;
            if(_S1969)
            {
                _S1970 = _S1851;
            }
            else
            {
                _S1970 = false;
            }
            float3  chain_throughput_1;
            if(_S1970)
            {
                chain_0 = here_0;
                uint _S1971 = insertBits_0((&chain_0)->path, b_9, 18U, 3U);
                uint _S1972 = _slang_select(nee_0, 1U,0U);
                uint _S1973 = insertBits_0(_S1971, _S1972, 21U, 1U);
                (&chain_0)->path = _S1973;
                float _S1974 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1974;
                (&chain_0)->dir = throughput_9;
                chain_throughput_1 = throughput_11;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1975 = surface_12;
            Vertex _S1976 = Vertex_x24init_0(_S1852, b_9, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_9)))), is_inside_6);
            prev_0 = _S1976;
            float _S1977 = (&lobe_5)->pdf;
            bool _S1978 = b_9 == 1U;
            bool _S1979;
            if(_S1978)
            {
                _S1979 = (_S1682.x) == (_S1682.y);
            }
            else
            {
                _S1979 = false;
            }
            float sky_pdf_3 = _slang_select(_S1979, sky_pdf_0,_S1977);
            float _S1980 = _slang_select(_S1689, 0.0f,sky_pdf_3);
            float _S1981 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1982 = !_S1842;
            float _S1983 = _slang_select(_S1982, _S1981,0.0f);
            float _S1984 = spread_1 + _S1983;
            bool _S1985;
            if(refracted_4)
            {
                _S1985 = !_S1848;
            }
            else
            {
                _S1985 = false;
            }
            bool is_inside_7;
            if(_S1985)
            {
                bool _S1986 = !is_inside_6;
                is_inside_7 = _S1986;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1987 = surface_12;
            bool _S1988 = boundsVolume_0(&_S1987);
            bool _S1989;
            if(_S1988)
            {
                _S1989 = !_S1853;
            }
            else
            {
                _S1989 = false;
            }
            if(_S1989)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1990 = - _S1975.geometry_n;
                float3  _S1991 = _slang_select(turned_1, _S1990,_S1975.geometry_n);
                (&faced_2)->geometry_n = _S1991;
                FKMedium _S1992 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1993 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1994 = faced_2;
                FKMedium _S1995 = _S1992;
                FKMedium _S1996 = _S1993;
                MediumSides _S1997 = mediumSides_0(&_S1994, &_S1995, filling_2, (&ray_2)->unit_direction, &_S1996);
                bool _S1998 = ((dot_0(throughput_9, _S1975.geometry_n)) > 0.0f) == ((dot_0(_S1975.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1999 = _slang_select(_S1998, _S1997.front.scatter,_S1997.behind.scatter);
                scatter_in_0 = _S1999;
                float3  _S2000 = scatter_in_0;
                float _S2001 = upsample(scatter_in_0, wavelength_8);
                float3  _S2002 = make_float3 (_S2001);
                float3  _S2003 = _slang_select(_S1721, _S2002,_S2000);
                scatter_in_0 = _S2003;
                float3  _S2004 = _slang_select(_S1998, _S1997.front.extinction,_S1997.behind.extinction);
                extinction_in_0 = _S2004;
                float3  _S2005 = extinction_in_0;
                float _S2006 = upsample(extinction_in_0, wavelength_8);
                float3  _S2007 = make_float3 (_S2006);
                float3  _S2008 = _slang_select(_S1721, _S2007,_S2005);
                extinction_in_0 = _S2008;
                float _S2009 = _slang_select(_S1998, _S1997.front.g,_S1997.behind.g);
                g_in_0 = _S2009;
                uint _S2010 = _S1997.fillings.x;
                uint _S2011 = _S1997.fillings.y;
                uint _S2012 = _slang_select(_S1998, _S2011,_S2010);
                bool _S2013 = (fcptVaryingUsed());
                uint _S2014 = _slang_select(_S2013, _S2012,4294967295U);
                filling_2 = _S2014;
            }
            (&ray_2)->unit_direction = throughput_9;
            bool _S2015 = !_S1853;
            if(_S2015)
            {
                FKSurface _S2016 = surface_12;
                float _S2017 = _slang_select(straight_0, 0.0f,_S2016.geometry_offset);
                float3  _S2018 = - _S1658.smooth_n;
                bool _S2019 = is_inside_7 != _S1848;
                float3  _S2020 = _slang_select(_S2019, _S2018,_S1658.smooth_n);
                float3  _S2021 = (&ray_2)->origin + make_float3 (_S2017) * _S2020;
                (&ray_2)->origin = _S2021;
            }
            throughput_10 = throughput_11;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1853;
            viewed_1 = _S1846;
            sky_pdf_2 = _S1980;
            spread_4 = _S1984;
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
        if(_S1698)
        {
            if(_S1620)
            {
                float3  _S2022 = pathColor(throughput_10 * emission_1, spectral_weight_0, wavelength_8);
                Reservoir candidate_8 = chain_0;
                uint _S2023 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S2024 = _S2023 == 1U;
                if(_S2024)
                {
                    float3  _S2025 = safeDivide(_S2022, chain_throughput_0);
                    (&candidate_8)->radiance = _S2025;
                }
                Reservoir _S2026 = withEnd(candidate_8, 2U, b_6, _S2022);
                offer(sel_7, _S2026, _S2022 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1620)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S2027 = survivalProbability(abs_0(throughput_10), density_6);
                density_7 = _S2027;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S2028 = (fcptMaxBounces());
            bool _S2029 = b_6 >= _S2028;
            if(_S2029)
            {
                wrong_side_0 = true;
            }
            else
            {
                bool _S2030 = density_7 < 1.0f;
                if(_S2030)
                {
                    uint _S2031 = noiseAddress(_S1496, b_6);
                    Random _S2032 = draw(_S2031, 8U);
                    wrong_side_0 = density_7 < (_S2032.value);
                }
                else
                {
                    wrong_side_0 = false;
                }
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S2033 = density_6 * density_7;
            density_7 = _S2033;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S2034 = layer_0 ^ 1U;
        uint _S2035 = _slang_select(passes_0, _S2034,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_4)->distance = 0.0f;
            b_9 = b_6;
            viewed_0 = viewed_1;
            throughput_2 = throughput_10;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_1 = spread_4;
            uint _S2036 = b_9 + 1U;
            b_6 = _S2036;
            layer_0 = _S2035;
            continue;
        }
        FKRay _S2037 = ray_2;
        float _S2038 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S1727;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1473 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S2039 = _slang_select(wrong_side_0, _S2038,4.294967296e+09f);
        bool _S2040 = !_S1689;
        if(straight_0)
        {
            _S1773 = true;
        }
        else
        {
            _S1773 = _S1689;
        }
        FKHit _S2041;
        if(_S1773)
        {
            _S2041 = hit_4;
        }
        else
        {
            _S2041 = _S1744;
        }
        FKHit _S2042 = (fcptTraverseInstanceBVH((_S2037), (_S1627), (_S2039), (_S2040), (_S2041), (viewed_1)));
        hit_4 = _S2042;
        if(replay_1)
        {
            _S1774 = _S1727;
        }
        else
        {
            _S1774 = false;
        }
        if(_S1774)
        {
            _S1841 = _S1473 == 1U;
        }
        else
        {
            _S1841 = false;
        }
        if(_S1841)
        {
            _S1842 = ((&hit_4)->instance_index) == (_S1485.instance_index);
        }
        else
        {
            _S1842 = false;
        }
        if(_S1842)
        {
            _S1843 = ((&hit_4)->triangle_index) == (_S1485.triangle_index);
        }
        else
        {
            _S1843 = false;
        }
        if(_S1843)
        {
            (&hit_4)->uv = _S1485.uv;
            float _S2043 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S2043;
        }
        if(replay_1)
        {
            _S1844 = _S1727;
        }
        else
        {
            _S1844 = false;
        }
        if(_S1844)
        {
            _S1845 = _S1473 == 3U;
        }
        else
        {
            _S1845 = false;
        }
        if(_S1845)
        {
            _S1846 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1846 = false;
        }
        if(_S1846)
        {
            return _S1469;
        }
        Reservoir _S2044 = chain_0;
        uint _S2045 = filling_2;
        for(;;)
        {
            bool _S2046 = (fcptVaryingUsed());
            if(_S2046)
            {
                _S1847 = _S2045 != 4294967295U;
            }
            else
            {
                _S1847 = false;
            }
            float _S2047;
            if(_S1847)
            {
                float _S2048 = (fcptMajorant((_S2045)));
                _S2047 = _S2048;
            }
            else
            {
                _S2047 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1848 = _S1727;
            }
            else
            {
                _S1848 = false;
            }
            if(_S1848)
            {
                _S1849 = _S1473 == 1U;
            }
            else
            {
                _S1849 = false;
            }
            if(_S1849)
            {
                _S1850 = _S2047 > 0.0f;
            }
            else
            {
                _S1850 = false;
            }
            if(_S1850)
            {
                ended_0 = _S1469;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_4 = width_3;
                density_3 = density_7;
                throughput_11 = throughput_10;
                b_9 = b_6;
                _S1851 = true;
                break;
            }
            bool _S2049 = (&prev_0)->rough;
            if(_S2049)
            {
                _S1851 = !(_S2047 > 0.0f);
            }
            else
            {
                _S1851 = false;
            }
            (&prev_0)->rough = _S1851;
            uint _S2050 = b_6 + 320U;
            bool _S2051 = b_6 == 4294967295U;
            uint _S2052 = _slang_select(_S2051, 384U,_S2050);
            uint _S2053 = stream(_S1496, _S2052);
            uint tracking_1 = _S2053;
            weight_2 = throughput_3;
            glowed_0 = _S1468;
            b_9 = b_6;
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
                    _S1467 = int(2);
                    break;
                }
                float _S2054 = (&hit_4)->distance;
                if(_S1847)
                {
                    float3  _S2055 = (&ray_2)->origin;
                    float3  _S2056 = (&ray_2)->unit_direction;
                    float _S2057 = (&hit_4)->distance;
                    bool _S2058 = b_9 == 4294967295U;
                    uint _S2059 = _slang_select(_S2058, 0U,b_9);
                    uint _S2060 = (&prev_0)->lobe;
                    uint _S2061 = _slang_select(_S2058, 3U,_S2060);
                    float _S2062 = (fcptTrackMedium((_S2045), (_S2055), (_S2056), (_S2057), (&tracking_1), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S2059), (_S2061), (_S2058)));
                    spread_3 = _S2062;
                }
                else
                {
                    bool _S2063 = _S2047 > 0.0f;
                    if(_S2063)
                    {
                        uint _S2064 = noiseAddress(_S1496, b_9);
                        Random _S2065 = draw(_S2064, 10U);
                        float _S2066 = - (F32_log((1.0f - _S2065.value))) / _S2047;
                        spread_3 = _S2066;
                    }
                    else
                    {
                        spread_3 = _S2054;
                    }
                }
                bool _S2067 = !(spread_3 < ((&hit_4)->distance));
                if(_S2067)
                {
                    _S1467 = int(2);
                    break;
                }
                if(_S1847)
                {
                    _S1852 = _S1698;
                }
                else
                {
                    _S1852 = false;
                }
                if(_S1852)
                {
                    float3  _S2068 = pathColor(throughput_11 * glowed_0, spectral_weight_0, wavelength_8);
                    float3  _S2069 = _S2068 / make_float3 (density_3);
                    float3  _S2070 = sel_7->glow + _S2069;
                    sel_7->glow = _S2070;
                }
                else
                {
                }
                glowed_0 = _S1468;
                uint b_10 = b_9 + 1U;
                float3  _S2071 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S2071;
                float3  _S2072 = flightWeight_0(scatter_in_0, extinction_in_0, _S2047, spread_3, true);
                float3  _S2073 = weight_2;
                float _S2074 = upsample(weight_2, wavelength_8);
                float3  _S2075 = make_float3 (_S2074);
                float3  _S2076 = _slang_select(_S1721, _S2075,_S2073);
                float3  _S2077 = _slang_select(_S1847, _S2076,_S2072);
                float3  throughput_12 = throughput_11 * _S2077;
                uint _S2078 = stream(_S1496, b_10 + 320U);
                tracking_1 = _S2078;
                weight_2 = throughput_3;
                float width_7 = width_4 + spread_2 * spread_3;
                float _S2079 = spread_2 + 3.14159274101257324f;
                if(_S1698)
                {
                    _S1853 = true;
                }
                else
                {
                    bool _S2080 = b_10 == _S1484;
                    if(_S2080)
                    {
                        _S1853 = !_S1847;
                    }
                    else
                    {
                        _S1853 = false;
                    }
                }
                TreeSample light_4;
                if(_S1853)
                {
                    float3  _S2081 = (&ray_2)->origin;
                    float3  _S2082 = (&ray_2)->unit_direction;
                    float3  _S2083 = (&ray_2)->unit_direction;
                    uint _S2084 = noiseAddress(_S1496, b_10);
                    float3  _S2085 = extinction_in_0;
                    float3  _S2086 = extinction_in_0;
                    uint2  _S2087 = make_uint2 (_S2045);
                    float3  _S2088 = (&ray_2)->unit_direction;
                    uint _S2089 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                    FKHit _S2090 = _S1744;
                    ShadowContext _S2091 = ShadowContext_x24init_0(_S2085, _S2086, _S2087, _S2088, b_10, _S2089, false, spread_3, width_7, &_S2090, false);
                    ShadowContext _S2092 = _S2091;
                    TreeSample _S2093 = sampleLightTree_0(_S2081, _S2082, _S2083, 0.0f, true, _S2084, &_S2092);
                    light_4 = _S2093;
                }
                else
                {
                    light_4 = _S1741;
                }
                float _S2094 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S2095 = (fcptMaxBounces());
                bool _S2096 = b_10 < _S2095;
                if(_S2096)
                {
                    _S1854 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1854 = false;
                }
                float _S2097 = _slang_select(_S1854, _S2094,0.0f);
                float3  _S2098 = throughput_12 * light_4.radiance;
                float _S2099 = powerHeuristic(light_4.density, _S2097);
                float3  _S2100 = pathColor(_S2098 * make_float3 (_S2094 * _S2099), spectral_weight_0, wavelength_8);
                float3  _S2101 = _slang_select(_S1853, _S2100,_S1468);
                if(replay_1)
                {
                    _S1855 = b_10 == _S1484;
                }
                else
                {
                    _S1855 = false;
                }
                if(_S1855)
                {
                    bool _S2102 = _S1473 == 2U;
                    if(_S2102)
                    {
                        float _S2103 = resamplingTarget(_S2101);
                        _S1856 = _S2103 > 0.0f;
                    }
                    else
                    {
                        _S1856 = false;
                    }
                    if(_S1856)
                    {
                        Shift _S2104 = Shift_x24init_0(_S2101, 1.0f);
                        _S1467 = int(1);
                        ended_0 = _S2104;
                        spread_3 = _S2079;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_7 = b_10;
                        break;
                    }
                    _S1467 = int(1);
                    ended_0 = _S1469;
                    spread_3 = _S2079;
                    width_5 = width_7;
                    throughput_9 = throughput_12;
                    b_7 = b_10;
                    break;
                }
                if(_S1698)
                {
                    Reservoir candidate_9 = _S2044;
                    uint _S2105 = extractBits_0(_S2044.path, 24U, 8U);
                    uint _S2106 = insertBits_0(0U, _S2105, 24U, 8U);
                    uint _S2107 = extractBits_0(_S2044.path, 10U, 2U);
                    bool _S2108 = _S2107 == 1U;
                    if(_S2108)
                    {
                        float3  _S2109 = safeDivide(_S2101, chain_throughput_0);
                        (&candidate_9)->radiance = _S2109;
                    }
                    else
                    {
                        uint _S2110 = insertBits_0(_S2106, b_10 + 1U, 5U, 5U);
                        uint _S2111 = insertBits_0(_S2110, 2U, 10U, 2U);
                        (&candidate_9)->path = _S2111;
                    }
                    Reservoir _S2112 = withEnd(candidate_9, 0U, b_10, _S2101);
                    offer(sel_7, _S2112, _S2101 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S2113 = survivalProbability(abs_0(throughput_12), density_3);
                    uint _S2114 = (fcptMaxBounces());
                    bool _S2115 = b_10 >= _S2114;
                    if(_S2115)
                    {
                        _S1856 = true;
                    }
                    else
                    {
                        bool _S2116 = _S2113 < 1.0f;
                        if(_S2116)
                        {
                            uint _S2117 = noiseAddress(_S1496, b_10);
                            Random _S2118 = draw(_S2117, 8U);
                            _S1856 = _S2113 < (_S2118.value);
                        }
                        else
                        {
                            _S1856 = false;
                        }
                    }
                    if(_S1856)
                    {
                        _S1467 = int(1);
                        ended_0 = _S1469;
                        spread_3 = _S2079;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_7 = b_10;
                        break;
                    }
                    float _S2119 = density_3 * _S2113;
                    density_3 = _S2119;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S2120 = noiseAddress(_S1496, b_10);
                float3  _S2121 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S2120, &phase_pdf_1);
                (&ray_2)->unit_direction = _S2121;
                NEEVertex _S2122 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1468, (&ray_2)->origin);
                nee_vertex_0 = _S2122;
                Vertex _S2123 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
                prev_0 = _S2123;
                float _S2124 = (&prev_0)->pdf;
                FKRay _S2125 = ray_2;
                FKHit _S2126 = (fcptTraverseInstanceBVH((_S2125), (true), (4.294967296e+09f), (false), (_S1744), (false)));
                hit_4 = _S2126;
                b_9 = b_10;
                throughput_11 = throughput_12;
                spread_2 = _S2079;
                width_4 = width_7;
                sky_pdf_1 = _S2124;
            }
            if(_S1467 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_11 = throughput_9;
                b_9 = b_7;
                _S1851 = true;
                break;
            }
            ended_0 = _S1469;
            _S1851 = false;
            break;
        }
        if(_S1851)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1852 = b_9 == b_6;
        }
        else
        {
            _S1852 = false;
        }
        bool _S2127 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S2127)
        {
            bool _S2128 = !(&nee_vertex_0)->none;
            float _S2129 = _slang_select(_S2128, sky_pdf_1,0.0f);
            float _S2130 = escapeWeight_0(_S2129, (&ray_2)->unit_direction);
            float3  _S2131 = environment_0((&ray_2)->unit_direction, b_9, (&prev_0)->lobe);
            float3  _S2132 = pathColor(throughput_11 * _S2131, spectral_weight_0, wavelength_8);
            if(replay_1)
            {
                bool _S2133 = b_9 == _S1484;
                if(_S2133)
                {
                    passes_0 = _S1473 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S2132 * make_float3 (_S2130) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1483)
                {
                    passes_0 = _S1480;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_9 == _S1471;
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
                    return Shift_x24init_0(_S2132 * make_float3 (_S2130), 1.0f);
                }
                return _S1469;
            }
            Reservoir candidate_10 = chain_0;
            uint _S2134 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S2135 = _S2134 == 1U;
            if(_S2135)
            {
                uint _S2136 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S2137 = _S2136 == b_9;
                float _S2138 = _slang_select(_S2137, 1.0f,_S2130);
                float3  _S2139 = safeDivide(_S2132 * make_float3 (_S2138), chain_throughput_0);
                (&candidate_10)->radiance = _S2139;
            }
            else
            {
                bool _S2140 = (&prev_0)->rough;
                if(_S2140)
                {
                    uint _S2141 = insertBits_0(_S1498, b_9 + 1U, 5U, 5U);
                    uint _S2142 = insertBits_0(_S2141, 3U, 10U, 2U);
                    uint _S2143 = insertBits_0(_S2142, (&prev_0)->lobe, 15U, 3U);
                    bool _S2144 = (&prev_0)->inside;
                    uint _S2145 = _slang_select(_S2144, 1U,0U);
                    uint _S2146 = insertBits_0(_S2143, _S2145, 22U, 1U);
                    (&candidate_10)->path = _S2146;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S2147 = _S2132 * make_float3 (_S2130);
            Reservoir _S2148 = withEnd(candidate_10, 3U, b_9, _S2147);
            offer(sel_7, _S2148, _S2147 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S2149 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S2149;
        bool _S2150 = (fcptVaryingUsed());
        if(_S2150)
        {
            _S1853 = filling_2 != 4294967295U;
        }
        else
        {
            _S1853 = false;
        }
        if(_S1853)
        {
            if(_S1698)
            {
                float3  _S2151 = pathColor(throughput_11 * glowed_0, spectral_weight_0, wavelength_8);
                float3  _S2152 = _S2151 / make_float3 (density_3);
                float3  _S2153 = sel_7->glow + _S2152;
                sel_7->glow = _S2153;
            }
            float3  _S2154 = throughput_11 * weight_2;
            throughput_9 = _S2154;
        }
        else
        {
            float3  _S2155 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S2156 = throughput_11 * _S2155;
            throughput_9 = _S2156;
        }
        float _S2157 = width_4 + spread_2 * (&hit_4)->distance;
        viewed_0 = _S1852;
        width_3 = _S2157;
        throughput_2 = throughput_9;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S2036 = b_9 + 1U;
        b_6 = _S2036;
        layer_0 = _S2035;
    }
    return _S1469;
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
        *_slang_vector_get_element_ptr(&result_15, i_25) = (F32_tan((_slang_vector_get_element(x_27, i_25))));
        i_25 = i_25 + int(1);
    }
    return result_15;
}

static __device__ float3  acos_0(float3  x_28)
{
    float3  result_16;
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
        *_slang_vector_get_element_ptr(&result_16, i_26) = (F32_acos((_slang_vector_get_element(x_28, i_26))));
        i_26 = i_26 + int(1);
    }
    return result_16;
}

__device__ Random normal_distribution(uint state_4)
{
    Random _S2158 = pcg(state_4);
    Random _S2159 = pcg(_S2158.state);
    float _S2160 = 6.28318548202514648f * _S2158.value;
    float _S2161 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S2159.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S2159.state, _S2161 * (F32_cos((_S2160))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S2162;
    (&_S2162)->state = state_5;
    (&_S2162)->value = value_2;
    return _S2162;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S2163 = normal_distribution(state_6);
    Random _S2164 = normal_distribution(_S2163.state);
    Random _S2165 = normal_distribution(_S2164.state);
    float3  _S2166 = make_float3 (_S2163.value, _S2164.value, _S2165.value);
    float3  _S2167 = ((((_S2166)) * make_float3(rnorm3df(((_S2166)).x, ((_S2166)).y, ((_S2166)).z))));
    return RandomSphere_x24init_0(_S2165.state, _S2167);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_13)
{
    float3  _S2168 = p1_0 - p0_0;
    float3  _S2169 = p2_0 - p0_0;
    float2  _S2170 = uv1_0 - uv0_0;
    float2  _S2171 = uv2_0 - uv0_0;
    float _S2172 = _S2170.x;
    float _S2173 = _S2171.y;
    float _S2174 = _S2170.y;
    float _S2175 = _S2171.x;
    float _S2176 = _S2172 * _S2173 - _S2174 * _S2175;
    float _S2177 = 1.0f / _S2176;
    float3  t_24 = (_S2168 * make_float3 (_S2173) - _S2169 * make_float3 (_S2174)) * make_float3 (_S2177);
    float3  _S2178 = (_S2169 * make_float3 (_S2172) - _S2168 * make_float3 (_S2175)) * make_float3 (_S2177);
    float3  _S2179 = t_24 - n_13 * make_float3 (dot_0(n_13, t_24));
    float3  t_25 = ((((_S2179)) * make_float3(rnorm3df(((_S2179)).x, ((_S2179)).y, ((_S2179)).z))));
    bool _S2180 = (dot_0(cross_0(n_13, t_25), _S2178)) > 0.0f;
    float3  t_26;
    if(_S2180)
    {
        float3  _S2181 = negate_0(t_25);
        t_26 = _S2181;
    }
    else
    {
        t_26 = t_25;
    }
    float3  _S2182 = cross_0(n_13, t_26);
    return makeMatrix<float, 3, 3> (t_26, _S2182, n_13);
}

__device__ float3  tangentToWorldNormalMap(float3  v_13, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_13, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_0)
{
    float3  _S2183 = t1_0 - t0_0;
    float3  _S2184 = t2_2 - t0_0;
    float3  _S2185 = t2_2 - t1_0;
    float _S2186 = (F32_min((length_0(_S2183)), ((F32_min((length_0(_S2184)), (length_0(_S2185)))))));
    float3  _S2187 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S2188 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S2189 = dot_0(geometry_n_4, _S2188);
    float3  _S2190 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S2191 = dot_0(geometry_n_4, _S2190);
    float3  _S2192 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S2193 = acos_0(abs_0(make_float3 (_S2189, _S2191, dot_0(geometry_n_4, _S2192))));
    float3  _S2194 = clamp_2(tan_0(_S2193), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S2187 * _S2194, uvw_0), 0.0f, _S2186 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_15, float3  n_14, BSDFMaterial material_29)
{
    float3  _S2195 = negate_0(dir_15);
    float _S2196 = sign_0(dot_0(n_14, _S2195));
    float3  _S2197 = n_14 * make_float3 (_S2196);
    AnisotropicFrame _S2198 = anisotropicFrame(material_29, _S2197);
    bool _S2199 = (_S2198.alphas.x) > 0.0f;
    if(_S2199)
    {
        float _S2200 = material_29.transmission * (1.0f - material_29.metallic);
        float3  _S2201 = negate_0(_S2197);
        float3  _S2202 = anisotropicLocal(dir_15, _S2198.tangent, _S2201);
        float _S2203 = anisotropicG1(_S2202, _S2198.alphas);
        return make_float3 (_S2200 * _S2203) * material_29.albedo;
    }
    float _S2204 = material_29.transmission * (1.0f - material_29.metallic);
    float _S2205 = material_29.roughness;
    float _S2206 = smithG1(_S2205 * _S2205, (F32_abs((dot_0(n_14, dir_15)))));
    return make_float3 (_S2204 * _S2206) * material_29.albedo;
}

__device__ float hairRow(float3  in_dir_13, float3  t_27, float3  out_dir_3, uint p_15, float w_20, float alpha_10, uint nt_0)
{
    uint _S2207 = p_15 % 4U;
    float _S2208 = w_20 * HAIR_WIDTHS_0[_S2207];
    float _S2209 = (F32_asin((clamp_1(dot_0(out_dir_3, t_27), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_13, t_27), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S2207] * alpha_10;
    return ((F32_asinh((_S2209 / _S2208))) / (F32_asinh((3.14159274101257324f / _S2208))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_14, float3  t_28, float3  out_dir_4, uint np_0)
{
    float3  _S2210 = worldToTangent(out_dir_4, t_28);
    float3  _S2211 = worldToTangent(in_dir_14, t_28);
    return (F32_frac((((F32_atan2((_S2210.z), (_S2210.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S2211.z), (1.17549435082228751e-38f - _S2211.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_15, float3  t_29, uint p_16, float row_0, float column_0, float w_21, float alpha_11, uint nt_1, uint np_1)
{
    float3  _S2212 = worldToTangent(in_dir_15, t_29);
    uint _S2213 = p_16 % 4U;
    float _S2214 = w_21 * HAIR_WIDTHS_0[_S2213];
    float _S2215 = (F32_asin((clamp_1(dot_0(in_dir_15, t_29), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S2213] * alpha_11 + _S2214 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S2214))))));
    float _S2216 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S2212.z), (1.17549435082228751e-38f - _S2212.x)));
    float _S2217 = (F32_cos((_S2215)));
    float3  _S2218 = tangentToWorld(make_float3 (_S2217 * (F32_cos((_S2216))), (F32_sin((_S2215))), _S2217 * (F32_sin((_S2216)))), t_29);
    return _S2218;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_15, BSDFMaterial material_30, float coverage_1)
{
    float3  through_2;
    if((material_30.ior) == 1.0f)
    {
        float3  _S2219 = straightThrough(toward_1, n_15, material_30);
        through_2 = _S2219;
    }
    else
    {
        through_2 = make_float3 (0.0f);
    }
    CoatFrame _S2220 = coatFrame(material_30, n_15);
    bool _S2221 = (_S2220.ior) > 0.0f;
    if(_S2221)
    {
        float _S2222 = fresnel((F32_abs((dot_0(_S2220.normal, toward_1)))), 1.0f, _S2220.ior);
        float3  _S2223 = mix_0(make_float3 (1.0f), make_float3 (1.0f - _S2222) * material_30.coat_tint, material_30.coat);
        float3  through_3 = through_2 * _S2223;
        through_2 = through_3;
    }
    return through_2 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_8, Reservoir r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    Domain _S2224 = dom_8;
    Reservoir _S2225 = r_9;
    Shift _S2226 = walk_0(&_S2224, &_S2225, replay_2, scale_4, sel_8);
    return _S2226;
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
    uint i_27 = 0U;
    for(;;)
    {
        if(i_27 < 4U)
        {
        }
        else
        {
            break;
        }
        uint _S2227;
        if(i_27 < 2U)
        {
            _S2227 = x_29;
        }
        else
        {
            _S2227 = (x_29 + size_0 / 2U) & (size_0 - 1U);
        }
        uint l_6 = _S2227;
        uint r_10 = y_8;
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
            uint _S2228 = hash(((r_10 ^ (t_30 << 16U)) ^ (k_4 << 28U)) ^ ((i_27 & 1U) << 31U));
            uint _S2229 = l_6 ^ (_S2228 & (size_0 - 1U));
            uint k_5 = k_4 + 1U;
            l_6 = r_10;
            r_10 = _S2229;
            k_4 = k_5;
        }
        uint _S2230 = l_6 + r_10 * size_0;
        uint _S2231 = size_0 * size_0;
        uint _S2232;
        if(_S2231 >= 65536U)
        {
            uint _S2233 = _S2230 / (_S2231 / 65536U);
            _S2232 = _S2233;
        }
        else
        {
            uint _S2234 = 65536U / _S2231;
            _S2232 = _S2230 * _S2234;
        }
        ranks_0[i_27] = _S2232;
        uint i_28 = i_27 + 1U;
        i_27 = i_28;
    }
    bool _S2235 = (ranks_0[int(0)]) == 65535U;
    bool _S2236;
    if(_S2235)
    {
        _S2236 = (ranks_0[int(1)]) == 65535U;
    }
    else
    {
        _S2236 = false;
    }
    bool _S2237 = (ranks_0[int(2)]) == 65535U;
    bool _S2238;
    if(_S2237)
    {
        _S2238 = (ranks_0[int(3)]) == 65535U;
    }
    else
    {
        _S2238 = false;
    }
    if(_S2236)
    {
        _S2236 = (ranks_0[int(3)]) != 65535U;
    }
    else
    {
        _S2236 = false;
    }
    if(_S2236)
    {
        _S2236 = true;
    }
    else
    {
        if(_S2238)
        {
            _S2236 = (ranks_0[int(1)]) != 65535U;
        }
        else
        {
            _S2236 = false;
        }
    }
    uint _S2239 = ranks_0[int(0)];
    if(_S2236)
    {
        i_27 = ranks_0[int(3)];
    }
    else
    {
        i_27 = ranks_0[int(1)];
    }
    return _S2239 | (i_27 << 16U);
}

__device__ uint3  noiseBlock(uint sweep_0, uint colour_0, uint block_0, uint size_1)
{
    uint _S2240 = hash(sweep_0 * 7919U + 1U);
    uint _S2241 = size_1 / 16U;
    uint _S2242 = block_0 % _S2241;
    uint _S2243 = block_0 / _S2241;
    uint _S2244 = _S2243 % _S2241;
    uint _S2245 = block_0 / (_S2241 * _S2241);
    uint3  _S2246 = make_uint3 (_S2242, _S2244, _S2245);
    uint3  _S2247 = make_uint3 (colour_0 & 1U, (colour_0 >> 1U) & 1U, colour_0 >> 2U);
    return _S2246 * make_uint3 (16U) + _S2247 * make_uint3 (8U) + make_uint3 (_S2240 & 7U, (_S2240 >> 3U) & 7U, (_S2240 >> 6U) & 7U);
}

#undef Matrix
