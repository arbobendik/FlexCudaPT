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

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
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
    float3  _S331 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S332 = ((((_S331)) * make_float3(rnorm3df(((_S331)).x, ((_S331)).y, ((_S331)).z))));
    float _S333 = _S332.x;
    float _S334 = _S332.y;
    float _S335 = _S333 * _S333 + _S334 * _S334;
    float3  _S336;
    if(_S335 > 0.0f)
    {
        float3  _S337 = make_float3 (- _S334, _S333, 0.0f);
        float _S338 = (rsqrtf((_S335)));
        _S336 = _S337 * make_float3 (_S338);
    }
    else
    {
        _S336 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S339 = cross_0(_S332, _S336);
    float _S340 = (F32_sqrt((U1_0)));
    float _S341 = 6.28318548202514648f * U2_0;
    float _S342 = _S340 * (F32_cos((_S341)));
    float t2_0 = _S340 * (F32_sin((_S341)));
    float _S343 = 0.5f * (1.0f + _S332.z);
    float t2_1 = (1.0f - _S343) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S342 * _S342)))))) + _S343 * t2_0;
    float3  _S344 = make_float3 (_S342) * _S336 + make_float3 (t2_1) * _S339;
    float _S345 = unshared_0(_S342);
    float _S346 = unshared_0(_S342);
    float3  _S347 = _S344 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S345 * _S346 - t2_1 * t2_1))))))) * _S332;
    float3  _S348 = make_float3 (alpha_0 * _S347.x, alpha_0 * _S347.y, (F32_max((0.0f), (_S347.z))));
    float3  _S349 = ((((_S348)) * make_float3(rnorm3df(((_S348)).x, ((_S348)).y, ((_S348)).z))));
    return _S349;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S350 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S350)
    {
        float3  _S351 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S351;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S352 = cross_0(n_3, a_4);
    float3  _S353 = ((((_S352)) * make_float3(rnorm3df(((_S352)).x, ((_S352)).y, ((_S352)).z))));
    float3  _S354 = cross_0(n_3, _S353);
    return make_float3 (dot_0(v_1, _S353), dot_0(v_1, n_3), dot_0(v_1, _S354));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_2, float3  n_i_1, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S355 = pcg(*random_state_2);
    Random _S356 = pcg(_S355.state);
    *random_state_2 = _S356.state;
    float _S357 = frame_0.alphas.x;
    bool _S358 = _S357 > 0.0f;
    if(_S358)
    {
        float3  _S359 = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        float _S360 = frame_0.alphas.y;
        float3  _S361 = make_float3 (_S357 * _S359.x, _S360 * _S359.y, _S359.z);
        float3  _S362 = ((((_S361)) * make_float3(rnorm3df(((_S361)).x, ((_S361)).y, ((_S361)).z))));
        float3  _S363 = sampleGGXVNDF(_S362, 1.0f, _S355.value, _S356.value);
        float3  _S364 = make_float3 (_S357 * _S363.x, _S360 * _S363.y, _S363.z);
        float3  _S365 = ((((_S364)) * make_float3(rnorm3df(((_S364)).x, ((_S364)).y, ((_S364)).z))));
        return make_float3 (_S365.x) * frame_0.tangent + make_float3 (_S365.y) * cross_0(n_i_1, frame_0.tangent) + make_float3 (_S365.z) * n_i_1;
    }
    float3  _S366 = worldToTangent(v_2, n_i_1);
    float3  _S367 = sampleGGXVNDF(float3 {_S366.x, _S366.z, _S366.y}, alpha_1, _S355.value, _S356.value);
    float3  _S368 = float3 {_S367.x, _S367.z, _S367.y};
    float3  _S369 = tangentToWorld(_S368, n_i_1);
    return _S369;
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

static __device__ float3  refract_0(float3  i_5, float3  n_4, float eta_0)
{
    float _S370 = dot_0(n_4, i_5);
    float _S371 = 1.0f - eta_0 * eta_0 * (1.0f - _S370 * _S370);
    if(_S371 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S370 + (F32_sqrt((_S371)))) * n_4;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S372 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S373 = eta_i_0 / eta_o_0 * _S372;
    bool _S374 = _S373 < 1.0f;
    float kr_0;
    if(_S374)
    {
        float _S375 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S373 * _S373))))));
        float _S376 = eta_o_0 * cos_theta_0;
        float _S377 = eta_i_0 * _S375;
        float _S378 = (_S376 - _S377) / (_S376 + _S377);
        float _S379 = eta_i_0 * cos_theta_0;
        float _S380 = eta_o_0 * _S375;
        float _S381 = (_S379 - _S380) / (_S379 + _S380);
        float _S382 = (_S378 * _S378 + _S381 * _S381) / 2.0f;
        kr_0 = _S382;
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
__device__ static const FixedArray<float, 576>  VELVET_ALBEDO_0 = { {
    1.00383996963500977f, 1.00428998470306396f, 1.00356996059417725f, 1.00303995609283447f, 1.00261998176574707f, 1.00229001045227051f, 1.00198996067047119f, 1.00171005725860596f, 1.00144004821777344f, 1.00120997428894043f, 1.00102996826171875f, 1.00092005729675293f, 1.00088000297546387f, 1.0009000301361084f, 1.00095999240875244f, 1.00106000900268555f, 1.00115001201629639f, 1.00124001502990723f, 1.001289963722229f, 1.0013200044631958f, 1.00133001804351807f, 1.00133001804351807f, 1.0013200044631958f, 1.00129997730255127f, 0.99086397886276245f, 0.9934689998626709f, 0.99439799785614014f, 0.99513500928878784f, 0.99574202299118042f, 0.9962649941444397f, 0.99671798944473267f, 0.99709898233413696f, 0.997406005859375f, 0.99764800071716309f, 0.99783498048782349f, 0.99798601865768433f, 0.99811899662017822f, 0.99825501441955566f, 0.99840497970581055f, 0.99857097864151001f, 0.99874699115753174f, 0.99892902374267578f, 0.9990919828414917f, 0.99923902750015259f, 0.99936902523040771f, 0.99948000907897949f, 0.99957501888275146f, 0.99965798854827881f, 0.94088798761367798f, 0.95128101110458374f, 0.95866602659225464f, 0.96450901031494141f, 0.96921002864837646f, 0.973052978515625f, 0.97623497247695923f, 0.97890102863311768f, 0.98115700483322144f, 0.98308497667312622f, 0.98474901914596558f, 0.98619699478149414f, 0.98746699094772339f, 0.98858797550201416f, 0.98958402872085571f, 0.99047297239303589f, 0.99127000570297241f, 0.99198299646377563f, 0.99262100458145142f, 0.99318897724151611f, 0.99372398853302002f, 0.99426800012588501f, 0.99475300312042236f, 0.99514400959014893f, 0.86131101846694946f, 0.88463401794433594f, 0.90212702751159668f, 0.91595500707626343f, 0.92708200216293335f, 0.93617302179336548f, 0.94370102882385254f, 0.95000702142715454f, 0.95534700155258179f, 0.9599120020866394f, 0.96384698152542114f, 0.96726799011230469f, 0.97026199102401733f, 0.97289901971817017f, 0.97523599863052368f, 0.97731602191925049f, 0.97917401790618896f, 0.98083901405334473f, 0.98233497142791748f, 0.98368102312088013f, 0.98489302396774292f, 0.98598498106002808f, 0.98697298765182495f, 0.98787301778793335f, 0.75306302309036255f, 0.79328000545501709f, 0.82418698072433472f, 0.84881901741027832f, 0.86874997615814209f, 0.88506197929382324f, 0.89858502149581909f, 0.9099239706993103f, 0.91952997446060181f, 0.9277459979057312f, 0.93483197689056396f, 0.94099199771881104f, 0.9463840126991272f, 0.95113497972488403f, 0.95534402132034302f, 0.95908999443054199f, 0.9624369740486145f, 0.96543699502944946f, 0.96813201904296875f, 0.97055697441101074f, 0.97274202108383179f, 0.97471201419830322f, 0.97649002075195312f, 0.97809398174285889f, 0.62183499336242676f, 0.68052101135253906f, 0.72705197334289551f, 0.76452702283859253f, 0.79505598545074463f, 0.82021200656890869f, 0.84120297431945801f, 0.85885602235794067f, 0.87384098768234253f, 0.88667500019073486f, 0.89775800704956055f, 0.90739899873733521f, 0.91584599018096924f, 0.92329102754592896f, 0.929889976978302f, 0.93576502799987793f, 0.94101500511169434f, 0.94572198390960693f, 0.94994997978210449f, 0.95375597476959229f, 0.95718497037887573f, 0.9602770209312439f, 0.96306699514389038f, 0.96558600664138794f, 0.47742500901222229f, 0.5522189736366272f, 0.61415499448776245f, 0.66520899534225464f, 0.70744901895523071f, 0.74262100458145142f, 0.77213901281356812f, 0.7971159815788269f, 0.81841897964477539f, 0.83673000335693359f, 0.85258400440216064f, 0.86640900373458862f, 0.87854301929473877f, 0.88924998044967651f, 0.89874798059463501f, 0.90721100568771362f, 0.91477799415588379f, 0.92156499624252319f, 0.92766499519348145f, 0.93315702676773071f, 0.9381060004234314f, 0.94257098436355591f, 0.94660097360610962f, 0.95023900270462036f, 0.33539599180221558f, 0.41908100247383118f, 0.49247598648071289f, 0.55531197786331177f, 0.60879099369049072f, 0.65415602922439575f, 0.69274699687957764f, 0.72571200132369995f, 0.75402498245239258f, 0.77849102020263672f, 0.79976201057434082f, 0.81836599111557007f, 0.83474302291870117f, 0.84922301769256592f, 0.86208897829055786f, 0.87356698513031006f, 0.88384199142456055f, 0.89306402206420898f, 0.90135800838470459f, 0.9088289737701416f, 0.91556602716445923f, 0.92164498567581177f, 0.92713397741317749f, 0.93208998441696167f, 0.21194499731063843f, 0.29365798830986023f, 0.37110498547554016f, 0.44143900275230408f, 0.5036969780921936f, 0.55801302194595337f, 0.60521197319030762f, 0.64614301919937134f, 0.68169897794723511f, 0.71268302202224731f, 0.73979401588439941f, 0.76362699270248413f, 0.78467601537704468f, 0.80335497856140137f, 0.82000100612640381f, 0.83488202095031738f, 0.8482239842414856f, 0.86021500825881958f, 0.87101101875305176f, 0.88074499368667603f, 0.88952797651290894f, 0.89745801687240601f, 0.90461999177932739f, 0.91109001636505127f, 0.11949499696493149f, 0.18745699524879456f, 0.25997200608253479f, 0.33120998740196228f, 0.39773499965667725f, 0.45832300186157227f, 0.51248997449874878f, 0.56048798561096191f, 0.6028980016708374f, 0.64032697677612305f, 0.67339599132537842f, 0.70268499851226807f, 0.72870397567749023f, 0.75189602375030518f, 0.77263599634170532f, 0.7912449836730957f, 0.80796998739242554f, 0.82303100824356079f, 0.8366129994392395f, 0.84887397289276123f, 0.85994899272918701f, 0.86995697021484375f, 0.87900298833847046f, 0.88717901706695557f, 0.05942929908633232f, 0.10839699953794479f, 0.16785700619220734f, 0.23236599564552307f, 0.29767501354217529f, 0.36022999882698059f, 0.41842898726463318f, 0.47170799970626831f, 0.5198180079460144f, 0.56301301717758179f, 0.60171198844909668f, 0.63635998964309692f, 0.66739702224731445f, 0.69524997472763062f, 0.720287024974823f, 0.74283498525619507f, 0.76317602396011353f, 0.78155702352523804f, 0.79817098379135132f, 0.81319701671600342f, 0.8267899751663208f, 0.83908802270889282f, 0.85021400451660156f, 0.86027902364730835f, 0.02584660053253174f, 0.05619670078158379f, 0.09917669743299484f, 0.15162299573421478f, 0.20941600203514099f, 0.26902499794960022f, 0.32757499814033508f, 0.38318398594856262f, 0.43501600623130798f, 0.48271399736404419f, 0.52620798349380493f, 0.56570100784301758f, 0.60149699449539185f, 0.63392102718353271f, 0.66328197717666626f, 0.68988502025604248f, 0.7139970064163208f, 0.7358660101890564f, 0.75570398569107056f, 0.77369099855422974f, 0.78999698162078857f, 0.80477499961853027f, 0.81816202402114868f, 0.83028298616409302f, 0.00968609005212784f, 0.02591750025749207f, 0.05318830162286758f, 0.09121809899806976f, 0.13777700066566467f, 0.18976299464702606f, 0.244159996509552f, 0.29880800843238831f, 0.35169300436973572f, 0.40180501341819763f, 0.44872200489044189f, 0.49213200807571411f, 0.53206497430801392f, 0.5686650276184082f, 0.60214298963546753f, 0.63272500038146973f, 0.66062301397323608f, 0.68605399131774902f, 0.70922297239303589f, 0.73031198978424072f, 0.74948400259017944f, 0.76689702272415161f, 0.78270000219345093f, 0.79702901840209961f, 0.00303822988644242f, 0.01048239972442389f, 0.02568300068378448f, 0.05025380104780197f, 0.08408640325069427f, 0.12561400234699249f, 0.17249999940395355f, 0.22232000529766083f, 0.27309399843215942f, 0.32321798801422119f, 0.37149098515510559f, 0.4173240065574646f, 0.4603630006313324f, 0.50043797492980957f, 0.53755801916122437f, 0.57181298732757568f, 0.60333001613616943f, 0.63226902484893799f, 0.65877401828765869f, 0.68301999568939209f, 0.70514601469039917f, 0.7253040075302124f, 0.74363899230957031f, 0.76029098033905029f, 0.00076204299693927f, 0.00361976004205644f, 0.0110037000849843f, 0.02512970007956028f, 0.04727460071444511f, 0.07745999842882156f, 0.11460299789905548f, 0.1569570004940033f, 0.20258499681949615f, 0.24971699714660645f, 0.29707801342010498f, 0.34340900182723999f, 0.38799500465393066f, 0.43043500185012817f, 0.47039699554443359f, 0.50777101516723633f, 0.54253697395324707f, 0.57473397254943848f, 0.60444700717926025f, 0.63179397583007812f, 0.65686798095703125f, 0.67979699373245239f, 0.70071202516555786f, 0.71974599361419678f, 0.00014345299859997f, 0.00102306995540857f, 0.00407376000657678f, 0.01122699957340956f, 0.02423799969255924f, 0.04415180161595345f, 0.07109060138463974f, 0.10433399677276611f, 0.14259399473667145f, 0.184347003698349f, 0.2281080037355423f, 0.27265200018882751f, 0.31696400046348572f, 0.36016398668289185f, 0.40178799629211426f, 0.44139501452445984f, 0.47875601053237915f, 0.51375597715377808f, 0.54635101556777954f, 0.57658302783966064f, 0.60447400808334351f, 0.63009101152420044f, 0.65352898836135864f, 0.67488902807235718f, 0.00001858420000644f, 0.0002227969962405f, 0.00124967005103827f, 0.00435766018927097f, 0.01113030035048723f, 0.0229835007339716f, 0.04079980030655861f, 0.06477940082550049f, 0.09447769820690155f, 0.12897300720214844f, 0.16708999872207642f, 0.20760199427604675f, 0.24936899542808533f, 0.29154899716377258f, 0.3332040011882782f, 0.37377101182937622f, 0.41274300217628479f, 0.44977998733520508f, 0.4846780002117157f, 0.51733100414276123f, 0.54769200086593628f, 0.57572799921035767f, 0.6014779806137085f, 0.62501102685928345f, 1.46482000218384201e-06f, 0.00003429050047998f, 0.0002985020109918f, 0.00140504003502429f, 0.00443577999249101f, 0.01069260016083717f, 0.02133879996836185f, 0.0371410995721817f, 0.05836030095815659f, 0.08476380258798599f, 0.11572299897670746f, 0.1503559947013855f, 0.18766500055789948f, 0.22665500640869141f, 0.26647698879241943f, 0.30632400512695312f, 0.34550899267196655f, 0.38344401121139526f, 0.41970700025558472f, 0.45401400327682495f, 0.48618701100349426f, 0.51614201068878174f, 0.54384201765060425f, 0.56930899620056152f, 5.83937982412408019e-08f, 3.2765999549155822e-06f, 0.00005055400106357f, 0.00035111699253321f, 0.00145683996379375f, 0.00427943980321288f, 0.0098936902359128f, 0.01927389949560165f, 0.03310279920697212f, 0.05168719962239265f, 0.07495570182800293f, 0.10250899940729141f, 0.13370099663734436f, 0.1677280068397522f, 0.20372100174427032f, 0.24084299802780151f, 0.27840098738670349f, 0.31564199924468994f, 0.35190799832344055f, 0.38674798607826233f, 0.41985601186752319f, 0.45104199647903442f, 0.48021000623703003f, 0.50734001398086548f, 8.73966010672688753e-10f, 1.57741993689342053e-07f, 5.21975016454234719e-06f, 0.00006079579907237f, 0.00036219600588083f, 0.00138045998755842f, 0.00386844994500279f, 0.00871635042130947f, 0.01675550080835819f, 0.02860799990594387f, 0.04461279883980751f, 0.06480839848518372f, 0.08895269781351089f, 0.11656700074672699f, 0.1470009982585907f, 0.17950700223445892f, 0.21331800520420074f, 0.24785000085830688f, 0.28237700462341309f, 0.31631898880004883f, 0.34923198819160461f, 0.38083100318908691f, 0.41094100475311279f, 0.43946701288223267f, 2.8866399288257627e-12f, 2.63671995348602195e-09f, 2.51094007808205788e-07f, 5.97520011069718748e-06f, 0.00005859580051037f, 0.0003192939911969f, 0.00116373994387686f, 0.00319523992948234f, 0.00714873988181353f, 0.0137449000030756f, 0.0235638003796339f, 0.03696820139884949f, 0.05407309904694557f, 0.0747511014342308f, 0.09866459667682648f, 0.12531900405883789f, 0.15412400662899017f, 0.18446199595928192f, 0.21573600172996521f, 0.24741099774837494f, 0.27903899550437927f, 0.310263991355896f, 0.34082499146461487f, 0.37054198980331421f, 6.94488983838260476e-16f, 7.04290011727115584e-12f, 3.21448001550095341e-09f, 2.20180993437679717e-07f, 4.50593006462440826e-06f, 0.00004154839916737f, 0.00022262999846134f, 0.00081575999502093f, 0.00227530999109149f, 0.00519366981461644f, 0.01020010001957417f, 0.0178545992821455f, 0.02856850065290928f, 0.04256030172109604f, 0.05984469875693321f, 0.08025020360946655f, 0.10345599800348282f, 0.12904399633407593f, 0.15654699504375458f, 0.1854960024356842f, 0.21545499563217163f, 0.24603499472141266f, 0.27690801024436951f, 0.3078019917011261f, 5.46278023199234311e-22f, 3.43167987041791307e-16f, 2.29294990113093622e-12f, 9.57796952860689998e-10f, 6.87986982939037262e-08f, 1.5533599935224629e-06f, 0.00001600819996384f, 0.00009555240103509f, 0.00038631301140413f, 0.00117554003372788f, 0.00289549003355205f, 0.00607588002458215f, 0.01126710046082735f, 0.01896269991993904f, 0.02954130060970783f, 0.04323289915919304f, 0.06011129915714264f, 0.0801049992442131f, 0.10301999747753143f, 0.12857000529766083f, 0.15640300512313843f, 0.18612800538539886f, 0.21734000742435455f, 0.24963200092315674f, 0.0f, 0.0f, 3.09890004335006815e-24f, 2.21276004416278673e-18f, 2.67358004631774657e-14f, 2.24439997836833882e-11f, 3.13075010360819306e-09f, 1.26480998119404831e-07f, 2.12951999856159091e-06f, 0.00001907769910758f, 0.00010753999958979f, 0.00042892698547803f, 0.00131604995112866f, 0.00330013991333544f, 0.00707077002152801f, 0.01337909977883101f, 0.02291939966380596f, 0.03622379899024963f, 0.05359359830617905f, 0.07507230341434479f, 0.10045900195837021f, 0.12935000658035278f, 0.16119599342346191f, 0.19536399841308594f
} };
static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

__device__ float anisotropicG1(float3  w_1, float2  alphas_1)
{
    float _S383 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S383 / (_S383 + length_0(make_float3 (alphas_1.x * w_1.x, alphas_1.y * w_1.y, _S383)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S384 = alphas_2.x;
    float _S385 = h_0.x / _S384;
    float _S386 = alphas_2.y;
    float _S387 = h_0.y / _S386;
    float _S388 = h_0.z;
    float _S389 = _S385 * _S385 + _S387 * _S387 + _S388 * _S388;
    return 1.0f / (F32_max((3.14159274101257324f * _S384 * _S386 * _S389 * _S389), (1.17549435082228751e-38f)));
}

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_0, float3  refracted_1, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_0, float3  sheen_0, float p_sheen_velvet_0, float3  view_0, float3  tangent_1, float2  alphas_3, float visible_0, float p_toon_0, float3  toon_0, float toon_a_0, float toon_s_0, float toon_b_0, bool toon_glossy_0, float toon_norm_0, float toon_view_0, float3  toon_axis_0)
{
    BSDFLobes _S390;
    (&_S390)->v_dot_h = v_dot_h_0;
    (&_S390)->n_dot_h = n_dot_h_0;
    (&_S390)->refracted = refracted_1;
    (&_S390)->F = F_0;
    (&_S390)->F_greyscale = F_greyscale_0;
    (&_S390)->reflect_weight = reflect_weight_0;
    (&_S390)->diffuse_weight = diffuse_weight_0;
    (&_S390)->refract_weight = refract_weight_0;
    (&_S390)->p_diffuse = p_diffuse_0;
    (&_S390)->p_reflect = p_reflect_0;
    (&_S390)->p_refract = p_refract_0;
    (&_S390)->translucent_share = translucent_share_0;
    (&_S390)->sheen = sheen_0;
    (&_S390)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S390)->view = view_0;
    (&_S390)->tangent = tangent_1;
    (&_S390)->alphas = alphas_3;
    (&_S390)->visible = visible_0;
    (&_S390)->p_toon = p_toon_0;
    (&_S390)->toon = toon_0;
    (&_S390)->toon_a = toon_a_0;
    (&_S390)->toon_s = toon_s_0;
    (&_S390)->toon_b = toon_b_0;
    (&_S390)->toon_glossy = toon_glossy_0;
    (&_S390)->toon_norm = toon_norm_0;
    (&_S390)->toon_view = toon_view_0;
    (&_S390)->toon_axis = toon_axis_0;
    return _S390;
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_0, float3  v_3, float3  n_i_2, float3  ggx_n_0, BSDFMaterial material_1, float eta_i_1, float eta_o_1, AnisotropicFrame frame_1)
{
    float _S391 = dot_0(ggx_n_0, v_3);
    float _S392 = dot_0(n_i_2, ggx_n_0);
    float _S393 = eta_i_1 / eta_o_1;
    float3  _S394 = refract_0(in_dir_0, ggx_n_0, _S393);
    float3  _S395 = ((((_S394)) * make_float3(rnorm3df(((_S394)).x, ((_S394)).y, ((_S394)).z))));
    float _S396 = (F32_min(((F32_sqrt((material_1.specular_level))) * (F32_abs((eta_i_1 - eta_o_1))) / (eta_i_1 + eta_o_1)), (0.9999847412109375f)));
    float _S397 = _S396 * _S396;
    float _S398 = (1.0f + _S396) / (1.0f - _S396);
    float _S399 = (F32_abs((_S391)));
    bool _S400 = eta_i_1 > eta_o_1;
    float sheen_component_0;
    if(_S400)
    {
        sheen_component_0 = _S398;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float toon_component_0;
    if(_S400)
    {
        toon_component_0 = 1.0f;
    }
    else
    {
        toon_component_0 = _S398;
    }
    float _S401 = fresnel(_S399, sheen_component_0, toon_component_0);
    bool _S402 = (eta_i_1 * eta_i_1 * (1.0f - _S391 * _S391)) >= (eta_o_1 * eta_o_1);
    float3  _S403;
    if(_S402)
    {
        _S403 = make_float3 (1.0f);
    }
    else
    {
        float3  _S404 = material_1.specular_tint * make_float3 (_S397);
        _S403 = _S404 + (make_float3 (1.0f) - _S404) * make_float3 (_S401 - _S397) / make_float3 (1.0f - _S397);
    }
    float3  _S405 = make_float3 (1.0f);
    float3  _S406 = make_float3 (0.0f);
    float _S407 = rgb_to_greyscale(material_1.sheen);
    bool _S408 = _S407 > 0.0f;
    float3  sheen_1;
    float3  view_1;
    float3  scale_1;
    if(_S408)
    {
        float _S409 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_2, v_3)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S410 = (U32_min((uint(_S409)), (22U)));
        float least_0 = (F32_sqrt((0.05000000074505806f)));
        float _S411 = (F32_sqrt((0.10000000149011612f)));
        bool _S412 = (material_1.velvet) > 0.0f;
        float _S413 = _slang_select(_S412, _S411,least_0);
        float _S414 = (clamp_1((F32_sqrt(((F32_max((material_1.sheen_roughness), (0.0f)))))), _S413, 1.0f) - _S413) / (1.0f - _S413) * 23.0f;
        uint _S415 = (U32_min((uint(_S414)), (22U)));
        uint _S416 = _S410 * 24U + _S415;
        float _S417 = _S409 - float(_S410);
        float _S418 = _S414 - float(_S415);
        uint _S419 = _S416 + 24U;
        float a_5 = SHEEN_ALBEDO_0[_S416] + (SHEEN_ALBEDO_0[_S419] - SHEEN_ALBEDO_0[_S416]) * _S417;
        uint _S420 = _S416 + 1U;
        uint _S421 = _S419 + 1U;
        float b_1 = SHEEN_ALBEDO_0[_S420] + (SHEEN_ALBEDO_0[_S421] - SHEEN_ALBEDO_0[_S420]) * _S417;
        float _S422 = (F32_exp((a_5 + (b_1 - a_5) * _S418)));
        if(_S412)
        {
            float a_6 = VELVET_ALBEDO_0[_S416] + (VELVET_ALBEDO_0[_S419] - VELVET_ALBEDO_0[_S416]) * _S417;
            float b_2 = VELVET_ALBEDO_0[_S420] + (VELVET_ALBEDO_0[_S421] - VELVET_ALBEDO_0[_S420]) * _S417;
            float _S423 = a_6 + (b_2 - a_6) * _S418;
            sheen_component_0 = _S423;
        }
        else
        {
            sheen_component_0 = _S422;
        }
        float _S424 = (F32_min((sheen_component_0), (1.0f)));
        float3  _S425 = make_float3 (1.0f) - material_1.sheen * make_float3 (_S424);
        float _S426 = rgb_to_greyscale(material_1.sheen);
        float _S427 = _S426 * _S424;
        float3  _S428 = material_1.sheen / make_float3 ((F32_max((sheen_component_0), (1.0f))));
        sheen_component_0 = _S427;
        sheen_1 = _S428;
        view_1 = v_3;
        scale_1 = _S425;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S406;
        view_1 = _S406;
        scale_1 = _S405;
    }
    float _S429 = material_1.toon.x;
    bool _S430 = _S429 < 0.0f;
    float _S431 = (F32_abs((_S429)));
    bool _S432 = _S431 > 0.0f;
    float toon_a_1;
    float toon_s_1;
    float toon_b_1;
    float toon_norm_1;
    float toon_view_1;
    float3  toon_1;
    float3  toon_axis_1;
    bool _S433;
    if(_S432)
    {
        float _S434 = (F32_min((_S431), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S434);
        float _S435 = rgb_to_greyscale(material_1.albedo);
        float _S436 = _S434 * _S435;
        float3  _S437 = make_float3 (_S434) * material_1.albedo;
        float toon_a_2 = clamp_1(material_1.toon.y / _S429, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_2 = clamp_1(material_1.toon.z / _S429, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S438 = (F32_min((toon_a_2 + toon_s_2), (1.57079637050628662f)));
        if(_S430)
        {
            toon_component_0 = 1.0f - (F32_cos(((F32_min((_S438), (toon_a_2))))));
        }
        else
        {
            float _S439 = (F32_sin(((F32_min((_S438), (toon_a_2))))));
            toon_component_0 = _S439 * _S439 / 2.0f;
        }
        bool _S440 = _S438 > toon_a_2;
        if(_S440)
        {
            _S433 = toon_s_2 > 0.0f;
        }
        else
        {
            _S433 = false;
        }
        if(_S433)
        {
            if(_S430)
            {
                float _S441 = (F32_cos((toon_a_2)));
                float _S442 = (F32_cos((_S438)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S441 - _S442) - ((F32_sin((_S438))) - _S438 * _S442 - ((F32_sin((toon_a_2))) - toon_a_2 * _S441)) / toon_s_2;
            }
            else
            {
                float _S443 = 2.0f * toon_a_2;
                float _S444 = (F32_cos((_S443)));
                float _S445 = 2.0f * _S438;
                float _S446 = (F32_cos((_S445)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S444 - _S446) / 4.0f - ((F32_sin((_S445))) / 8.0f - _S438 * _S446 / 4.0f - ((F32_sin((_S443))) / 8.0f - toon_a_2 * _S444 / 4.0f)) / toon_s_2;
            }
            float integral_0 = toon_component_0 + toon_a_1;
            toon_component_0 = integral_0;
        }
        float _S447 = 6.28318548202514648f * toon_component_0;
        float _S448 = dot_0(n_i_2, v_3);
        float _S449 = (F32_acos(((F32_min((_S448), (1.0f))))));
        if(_S449 < toon_a_2)
        {
            toon_component_0 = 1.0f;
        }
        else
        {
            toon_component_0 = (F32_max((1.0f - (_S449 - toon_a_2) / (F32_max((toon_s_2), (0.0000152587890625f)))), (0.0f)));
        }
        if(_S430)
        {
            float3  _S450 = make_float3 (2.0f * _S448) * n_i_2 - v_3;
            float3  _S451 = ((((_S450)) * make_float3(rnorm3df(((_S450)).x, ((_S450)).y, ((_S450)).z))));
            scale_1 = _S451;
        }
        else
        {
            scale_1 = n_i_2;
        }
        float _S452 = toon_component_0;
        toon_component_0 = _S436;
        toon_1 = _S437;
        toon_a_1 = toon_a_2;
        toon_s_1 = toon_s_2;
        toon_b_1 = _S438;
        toon_norm_1 = _S447;
        toon_view_1 = _S452;
        toon_axis_1 = scale_1;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S406;
        toon_a_1 = 0.0f;
        toon_s_1 = 0.0f;
        toon_b_1 = 0.0f;
        toon_norm_1 = 1.0f;
        toon_view_1 = 0.0f;
        toon_axis_1 = n_i_2;
    }
    float3  _S453 = mix_0(_S403, material_1.albedo, material_1.metallic);
    float3  F_1 = _S453 * scale_1;
    float _S454 = rgb_to_greyscale(F_1);
    float _S455 = 1.0f - material_1.metallic;
    float3  _S456 = make_float3 (1.0f) - _S403;
    float3  _S457 = make_float3 ((1.0f - material_1.transmission) * _S455) * _S456 * scale_1;
    float3  _S458 = make_float3 (material_1.transmission * _S455) * _S456 * scale_1;
    float _S459 = (F32_max((_S454), (0.0f)));
    float _S460 = rgb_to_greyscale(_S457);
    float _S461 = (F32_max((_S460), (0.0f)));
    float _S462 = rgb_to_greyscale(_S458);
    float _S463 = sign_0(length_0(_S395));
    float _S464 = (F32_max((_S462 * _S463), (0.0f)));
    float _S465 = _S459 + _S461 + _S464 + toon_component_0;
    float _S466 = (F32_min((sheen_component_0), (1.0f)));
    bool _S467 = sheen_component_0 > 0.0f;
    if(_S467)
    {
        _S433 = !(_S465 > 0.0f);
    }
    else
    {
        _S433 = false;
    }
    float _S468 = _slang_select(_S433, 1.0f,_S466);
    float _S469 = (1.0f - _S468) / (F32_max((_S465), (0.0000152587890625f)));
    float _S470 = _S461 * _S469;
    float _S471 = _S459 * _S469;
    float _S472 = _S464 * _S469;
    bool _S473 = (frame_1.alphas.x) > 0.0f;
    float visible_1;
    if(_S473)
    {
        float3  _S474 = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        float _S475 = anisotropicG1(_S474, frame_1.alphas);
        float3  _S476 = anisotropicLocal(ggx_n_0, frame_1.tangent, n_i_2);
        float _S477 = anisotropicD(_S476, frame_1.alphas);
        float _S478 = _S475 * _S477;
        visible_1 = _S478;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S391, _S392, _S395, F_1, _S454, 1.0f, _S457, _S458, _S470, _S471, _S472, 0.0f, sheen_1, _S468, view_1, frame_1.tangent, frame_1.alphas, visible_1, toon_component_0 * _S469, toon_1, toon_a_1, toon_s_1, toon_b_1, _S430, toon_norm_1, toon_view_1, toon_axis_1);
}

__device__ float translucentShare(BSDFMaterial material_2)
{
    float _S479 = rgb_to_greyscale(material_2.translucent);
    float _S480 = rgb_to_greyscale(material_2.albedo);
    float _S481 = _S479 / (_S480 + _S479);
    bool _S482 = _S479 > 0.0f;
    float _S483 = _slang_select(_S482, _S481,0.0f);
    return _S483;
}

__device__ float smithG1(float alpha_2, float n_dot_x_0)
{
    float _S484 = alpha_2 * alpha_2;
    float _S485 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S484 + (1.0f - _S484) * n_dot_x_0 * n_dot_x_0))));
    bool _S486 = alpha_2 > 0.0f;
    float _S487 = _slang_select(_S486, _S485,1.0f);
    return _S487;
}

__device__ float trowbridgeReitz(float alpha_3, float n_dot_h_1)
{
    float _S488 = alpha_3 * alpha_3;
    float _S489 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S488 * n_dot_h_1 * n_dot_h_1;
    return _S488 / (F32_max((3.14159274101257324f * _S489 * _S489), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, BSDFLobes lobes_0, float eta_i_2, float eta_o_2, uint lobe_0)
{
    bool _S490 = lobe_0 == 0U;
    if(_S490)
    {
        float _S491 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        float _S492 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
        float _S493 = 1.0f - lobes_0.translucent_share;
        bool _S494 = n_i_dot_l_0 < 0.0f;
        float _S495 = _slang_select(_S494, lobes_0.translucent_share,_S493);
        float _S496 = _S492 * _S495;
        bool _S497 = (lobes_0.translucent_share) > 0.0f;
        float _S498 = _slang_select(_S497, _S496,_S491);
        bool _S499 = n_i_dot_v_0 > 0.0f;
        float _S500 = _slang_select(_S499, _S498,0.0f);
        return _S500;
    }
    bool _S501 = lobe_0 == 4U;
    bool _S502;
    if(_S501)
    {
        float _S503 = lobes_0.p_sheen_velvet * 0.5f * 0.31830987334251404f;
        bool _S504 = n_i_dot_l_0 > 0.0f;
        if(_S504)
        {
            _S502 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S502 = false;
        }
        float _S505 = _slang_select(_S502, _S503,0.0f);
        return _S505;
    }
    bool _S506 = lobe_0 == 6U;
    float pdf_h_0;
    if(_S506)
    {
        float _S507 = _slang_select(lobes_0.toon_glossy, l_dot_h_0,n_i_dot_l_0);
        float _S508 = (F32_acos((clamp_1(_S507, -1.0f, 1.0f))));
        if(_S508 < (lobes_0.toon_a))
        {
            pdf_h_0 = 1.0f;
        }
        else
        {
            pdf_h_0 = (F32_max((1.0f - (_S508 - lobes_0.toon_a) / (F32_max((lobes_0.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float _S509 = lobes_0.p_toon * pdf_h_0;
        float _S510 = _slang_select(lobes_0.toon_glossy, 1.0f,n_i_dot_l_0);
        float _S511 = _S509 * _S510 / lobes_0.toon_norm;
        if(lobes_0.toon_glossy)
        {
            _S502 = true;
        }
        else
        {
            _S502 = n_i_dot_l_0 > 0.0f;
        }
        float _S512 = _slang_select(_S502, _S511,0.0f);
        return _S512;
    }
    float _S513 = smithG1(alpha_4, n_i_dot_v_0);
    float _S514 = _S513 * lobes_0.v_dot_h;
    float _S515 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    float _S516 = _S514 * _S515 / n_i_dot_v_0;
    bool _S517 = alpha_4 > 0.0f;
    if(_S517)
    {
        _S502 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S502 = false;
    }
    if(_S502)
    {
        _S502 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S502 = false;
    }
    if(_S502)
    {
        _S502 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S502 = false;
    }
    float _S518 = _slang_select(_S502, _S516,0.0f);
    bool _S519 = (lobes_0.alphas.x) > 0.0f;
    if(_S519)
    {
        float _S520 = lobes_0.visible * lobes_0.v_dot_h / n_i_dot_v_0;
        bool _S521 = (lobes_0.v_dot_h) > 0.0f;
        if(_S521)
        {
            _S502 = (lobes_0.n_dot_h) > 0.0f;
        }
        else
        {
            _S502 = false;
        }
        if(_S502)
        {
            _S502 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S502 = false;
        }
        float _S522 = _slang_select(_S502, _S520,0.0f);
        pdf_h_0 = _S522;
    }
    else
    {
        pdf_h_0 = _S518;
    }
    bool _S523 = lobe_0 == 1U;
    if(_S523)
    {
        float _S524 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        float _S525 = lobes_0.p_refract * pdf_h_0 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S524 * _S524);
        bool _S526 = eta_i_2 != eta_o_2;
        if(_S526)
        {
            _S502 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S502 = false;
        }
        float _S527 = _slang_select(_S502, _S525,0.0f);
        return _S527;
    }
    float _S528 = lobes_0.p_reflect * pdf_h_0 / (4.0f * lobes_0.v_dot_h);
    bool _S529 = pdf_h_0 > 0.0f;
    float _S530 = _slang_select(_S529, _S528,0.0f);
    return _S530;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_0, uint random_state_3, bool refracted_2, uint lobe_1, float pdf_0)
{
    SampleBSDF _S531;
    (&_S531)->unit_direction = unit_direction_1;
    (&_S531)->throughput = throughput_0;
    (&_S531)->random_state = random_state_3;
    (&_S531)->refracted = refracted_2;
    (&_S531)->lobe = lobe_1;
    (&_S531)->pdf = pdf_0;
    return _S531;
}

__device__ __forceinline__ float3  lobeThroughput(float3  l_0, float3  n_i_3, float alpha_5, BSDFMaterial material_3, BSDFLobes lobes_1, uint lobe_2)
{
    bool _S532 = lobe_2 == 0U;
    if(_S532)
    {
        bool _S533 = (dot_0(n_i_3, l_0)) < 0.0f;
        float3  _S534 = _slang_select(_S533, material_3.translucent,material_3.albedo);
        float _S535 = 1.0f - lobes_1.translucent_share;
        float _S536 = _slang_select(_S533, lobes_1.translucent_share,_S535);
        float3  _S537 = _S534 / make_float3 (_S536);
        bool _S538 = (lobes_1.translucent_share) > 0.0f;
        float3  _S539 = _slang_select(_S538, _S537,material_3.albedo);
        return lobes_1.diffuse_weight * _S539 / make_float3 (lobes_1.p_diffuse);
    }
    bool _S540 = lobe_2 == 4U;
    float f_1;
    if(_S540)
    {
        float3  _S541 = l_0 + lobes_1.view;
        float3  _S542 = ((((_S541)) * make_float3(rnorm3df(((_S541)).x, ((_S541)).y, ((_S541)).z))));
        float _S543 = dot_0(n_i_3, _S542);
        float _S544 = (F32_max((dot_0(n_i_3, l_0)), (0.0f)));
        float _S545 = (F32_max((dot_0(n_i_3, lobes_1.view)), (0.0f)));
        float _S546 = 1.0f / (F32_max((material_3.sheen_roughness), (0.05000000074505806f)));
        float _S547 = 1.0f - _S543 * _S543;
        float _S548 = (2.0f + _S546) * (F32_pow(((F32_max((_S547), (0.0f)))), (0.5f * _S546))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S544 + _S545 - _S544 * _S545)), (0.0000152587890625f)));
        bool _S549 = (material_3.velvet) > 0.0f;
        if(_S549)
        {
            float _S550 = (F32_max((material_3.sheen_roughness), (0.00999999977648258f)));
            float _S551 = _S550 * _S550;
            float _S552 = (F32_max((_S547), (0.0000152587890625f)));
            float _S553 = (F32_exp((- _S543 * _S543 / (_S552 * _S551)))) / (3.14159274101257324f * _S551 * _S552 * _S552) * (F32_min((1.0f), (2.0f * _S543 * (F32_min((_S544), (_S545))) / (F32_max(((F32_abs((dot_0(_S542, lobes_1.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S544 * _S545), (0.0000152587890625f)));
            f_1 = _S553;
        }
        else
        {
            f_1 = _S548;
        }
        return lobes_1.sheen * make_float3 (f_1 * _S544 * 2.0f * 3.14159274101257324f / lobes_1.p_sheen_velvet);
    }
    bool _S554 = lobe_2 == 6U;
    if(_S554)
    {
        float _S555 = (F32_max((dot_0(n_i_3, l_0)), (0.0f)));
        float _S556 = _slang_select(lobes_1.toon_glossy, _S555,lobes_1.toon_view);
        return lobes_1.toon * make_float3 (_S556) / make_float3 (lobes_1.p_toon);
    }
    bool _S557 = lobe_2 == 1U;
    if(_S557)
    {
        float _S558 = - dot_0(n_i_3, l_0);
        float _S559 = smithG1(alpha_5, (F32_max((_S558), (0.0f))));
        bool _S560 = (lobes_1.alphas.x) > 0.0f;
        if(_S560)
        {
            float3  _S561 = negate_0(n_i_3);
            float3  _S562 = anisotropicLocal(l_0, lobes_1.tangent, _S561);
            float _S563 = anisotropicG1(_S562, lobes_1.alphas);
            f_1 = _S563;
        }
        else
        {
            f_1 = _S559;
        }
        return lobes_1.refract_weight * make_float3 (f_1) * material_3.albedo / make_float3 (lobes_1.p_refract);
    }
    float _S564 = dot_0(n_i_3, l_0);
    float _S565 = smithG1(alpha_5, (F32_max((_S564), (0.0f))));
    bool _S566 = (lobes_1.alphas.x) > 0.0f;
    if(_S566)
    {
        float3  _S567 = anisotropicLocal(l_0, lobes_1.tangent, n_i_3);
        float _S568 = anisotropicG1(_S567, lobes_1.alphas);
        f_1 = _S568;
    }
    else
    {
        f_1 = _S565;
    }
    return make_float3 (lobes_1.reflect_weight * f_1) * lobes_1.F / make_float3 (lobes_1.p_reflect);
}

__device__ __forceinline__ SampleBSDF connectBSDF(float3  in_dir_1, float3  out_dir_0, float3  n_5, BSDFMaterial material_4, float eta_i_3, float eta_o_3, uint lobe_3, uint random_init_0)
{
    uint random_state_4 = random_init_0;
    float3  _S569 = negate_0(in_dir_1);
    float _S570 = dot_0(n_5, _S569);
    float _S571 = sign_0(_S570);
    float3  _S572 = n_5 * make_float3 (_S571);
    float _S573 = material_4.roughness;
    float _S574 = _S573 * _S573;
    AnisotropicFrame _S575 = anisotropicFrame(material_4, _S572);
    float3  _S576 = _S569 + out_dir_0;
    float3  _S577 = ((((_S576)) * make_float3(rnorm3df(((_S576)).x, ((_S576)).y, ((_S576)).z))));
    bool _S578 = lobe_3 == 0U;
    float3  ggx_n_1;
    if(_S578)
    {
        float3  _S579 = sampleHalfVector(_S569, _S572, _S574, _S575, &random_state_4);
        ggx_n_1 = _S579;
    }
    else
    {
        ggx_n_1 = _S577;
    }
    bool _S580 = lobe_3 == 1U;
    if(_S580)
    {
        float3  _S581 = negate_0(make_float3 (eta_i_3) * _S569 + make_float3 (eta_o_3) * out_dir_0);
        float3  _S582 = ((((_S581)) * make_float3(rnorm3df(((_S581)).x, ((_S581)).y, ((_S581)).z))));
        float _S583 = sign_0(dot_0(_S581, _S572));
        float3  _S584 = _S582 * make_float3 (_S583);
        ggx_n_1 = _S584;
    }
    bool _S585 = lobe_3 == 2U;
    if(_S585)
    {
        float3  _S586 = ((((_S576)) * make_float3(rnorm3df(((_S576)).x, ((_S576)).y, ((_S576)).z))));
        ggx_n_1 = _S586;
    }
    bool _S587 = lobe_3 == 4U;
    if(_S587)
    {
        float3  _S588 = ((((_S576)) * make_float3(rnorm3df(((_S576)).x, ((_S576)).y, ((_S576)).z))));
        ggx_n_1 = _S588;
    }
    bool _S589 = lobe_3 == 6U;
    if(_S589)
    {
        float3  _S590 = sampleHalfVector(_S569, _S572, _S574, _S575, &random_state_4);
        ggx_n_1 = _S590;
    }
    BSDFLobes _S591 = bsdfLobes(in_dir_1, _S569, _S572, ggx_n_1, material_4, eta_i_3, eta_o_3, _S575);
    BSDFLobes lobes_2 = _S591;
    float _S592 = translucentShare(material_4);
    (&lobes_2)->translucent_share = _S592;
    float _S593 = dot_0(out_dir_0, ggx_n_1);
    float _S594 = dot_0(out_dir_0, (&lobes_2)->toon_axis);
    float _S595 = _slang_select(_S589, _S594,_S593);
    float _S596 = lobeDensity(dot_0(_S572, out_dir_0), _S595, (F32_abs((_S570))), _S574, lobes_2, eta_i_3, eta_o_3, lobe_3);
    bool _S597 = !(_S596 > 0.0f);
    if(_S597)
    {
        float3  _S598 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S598, _S598, 0U, false, 0U, 0.0f);
    }
    float3  _S599 = lobeThroughput(out_dir_0, _S572, _S574, material_4, lobes_2, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S599, random_state_4, _S580, lobe_3, _S596);
}

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_2, float3  dir_3, float3  n_6, BSDFMaterial material_5, float eta_i_4, float eta_o_4, bool refracted_3, float pdf_1, bool power_0, uint random_state_5)
{
    float3  _S600 = make_float3 (0.0f);
    uint _S601;
    if((F32_abs((material_5.toon.x))) > 0.0f)
    {
        _S601 = 5U;
    }
    else
    {
        _S601 = 4U;
    }
    uint i_6 = 0U;
    float3  f_2 = _S600;
    for(;;)
    {
        if(i_6 < _S601)
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
        if(_S603)
        {
        }
        bool _S604;
        if(_S603)
        {
            float _S605 = rgb_to_greyscale(material_5.translucent);
            _S604 = _S605 > 0.0f;
        }
        else
        {
            _S604 = false;
        }
        bool _S606;
        if(_S604)
        {
            float _S607 = dot_0(n_6, dir_3);
            float3  _S608 = negate_0(in_dir_2);
            _S606 = ((_S607 * dot_0(n_6, _S608)) < 0.0f) == refracted_3;
        }
        else
        {
            _S606 = (_S602 == 1U) == refracted_3;
        }
        float3  f_3;
        if(_S606)
        {
            SampleBSDF _S609 = connectBSDF(in_dir_2, dir_3, n_6, material_5, eta_i_4, eta_o_4, _S602, random_state_5);
            bool _S610 = (_S609.pdf) > 0.0f;
            if(_S610)
            {
                if(power_0)
                {
                    float _S611 = _S609.pdf / pdf_1;
                    float3  f_4 = f_2 + _S609.throughput * make_float3 (_S609.pdf) / make_float3 (pdf_1 * (1.0f + _S611 * _S611));
                    f_3 = f_4;
                }
                else
                {
                    float3  f_5 = f_2 + _S609.throughput * make_float3 (_S609.pdf) / make_float3 (_S609.pdf + pdf_1);
                    f_3 = f_5;
                }
            }
            else
            {
                f_3 = f_2;
            }
        }
        else
        {
            f_3 = f_2;
        }
        uint i_7 = i_6 + 1U;
        i_6 = i_7;
        f_2 = f_3;
    }
    return f_2;
}

__device__ float3  skyBSDF(float3  in_dir_3, float3  dir_4, FKSurface surface_1, float2  eta_1, bool is_inside_2, float pdf_2, uint random_state_6)
{
    bool _S612 = wrongSide_0(is_inside_2, false, dir_4, surface_1.geometry_n);
    float3  _S613 = neeBSDF(in_dir_3, dir_4, surface_1.smooth_n, surface_1.material, eta_1.x, eta_1.y, _S612, pdf_2, false, random_state_6);
    return _S613;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S614;
    (&_S614)->dir = dir_5;
    (&_S614)->radiance = radiance_0;
    (&_S614)->color = color_0;
    (&_S614)->random_state = random_state_7;
    return _S614;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S615 = (fcptEnvironmentCdfSize());
    uint2  _S616 = make_uint2 (1U, 0U);
    uint2  _S617 = _S615 - _S616;
    Random _S618 = pcg(init_random_state_0);
    Random _S619 = pcg(_S618.state);
    Random _S620 = pcg(_S619.state);
    Random _S621 = pcg(_S620.state);
    uint _S622 = _S617.x;
    uint _S623 = searchCDF_0(make_uint2 (_S622, 0U), make_uint2 (0U, 1U), _S617.y, _S618.value);
    uint _S624 = searchCDF_0(make_uint2 (0U, _S623), _S616, _S622, _S619.value);
    float2  _S625 = make_float2 ((float)_S617.x, (float)_S617.y);
    float2  _S626 = (make_float2 (float(_S624), float(_S623)) + make_float2 (_S620.value, _S621.value)) / _S625 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S627 = _S626.y;
    float _S628 = (F32_sin((_S627)));
    float _S629 = _S626.x;
    float3  _S630 = make_float3 (- _S628 * (F32_cos((_S629))), _S628 * (F32_sin((_S629))), (F32_cos((_S627))));
    float _S631 = environmentPdf_0(_S630);
    float3  _S632 = skyBSDF(ray_0->unit_direction, _S630, *surface_2, eta_2, is_inside_3, _S631, lobe_state_0);
    bool _S633 = !(_S631 > 0.0f);
    bool _S634;
    if(_S633)
    {
        _S634 = true;
    }
    else
    {
        _S634 = all_1(_S632 == make_float3 (0.0f));
    }
    if(_S634)
    {
        float3  _S635 = make_float3 (0.0f);
        return SkySample_x24init_0(_S630, _S635, _S635, _S621.state);
    }
    float3  _S636 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S630, context_2, _S621.state);
    return SkySample_x24init_0(_S630, _S636, _S632 * _S636, _S621.state);
}

struct TreeSample
{
    float3  dir;
    float3  radiance;
    float density;
    uint random_state;
};

static __device__ float3  hairLight_0(FKSurface * surface_3, float3  in_dir_4, TreeSample * light_1, bool competing_0)
{
    SampleBSDF _S637 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_4), (light_1->dir)));
    float3  _S638 = _S637.throughput * make_float3 (_S637.pdf);
    float _S639 = light_1->density;
    float _S640 = 1.0f + _S637.pdf * _S637.pdf / (light_1->density * light_1->density);
    bool _S641;
    if(competing_0)
    {
        _S641 = _S639 > 0.0f;
    }
    else
    {
        _S641 = false;
    }
    float _S642 = _slang_select(_S641, _S640,1.0f);
    return _S638 / make_float3 (_S642) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S643;
    (&_S643)->dir = dir_6;
    (&_S643)->radiance = radiance_1;
    (&_S643)->density = density_0;
    (&_S643)->random_state = random_state_8;
    return _S643;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S644 = importance(first_1, p_12, normal_3);
    float _S645 = importance(second_1, p_12, normal_3);
    float2  _S646 = make_float2 (_S644, _S645);
    bool _S647 = _S644 == 0.0f;
    bool _S648;
    if(_S647)
    {
        _S648 = _S645 == 0.0f;
    }
    else
    {
        _S648 = false;
    }
    if(_S648)
    {
        return 2U;
    }
    float _S649 = _S644 + _S645;
    bool _S650 = _S645 > 0.0f;
    if(_S650)
    {
        _S648 = (*pick_0 * _S649) >= _S644;
    }
    else
    {
        _S648 = false;
    }
    uint _S651 = uint(_S648);
    float _S652 = (F32_min(((*pick_0 * _S649 - float(_S651) * _S644) / _slang_vector_get_element(_S646, _S651)), (0.99999994039535522f)));
    *pick_0 = _S652;
    float _S653 = *probability_3 * (_slang_vector_get_element(_S646, _S651) / _S649);
    *probability_3 = _S653;
    return _S651;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S654 = center_1 - p_13;
    float _S655 = radius_1 * radius_1 / dot_0(_S654, _S654);
    float _S656 = u1_0 * _S655 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S655), (0.0f)))))));
    float _S657 = 2.0f * u1_0;
    bool _S658 = _S655 >= 1.0f;
    float _S659 = _slang_select(_S658, _S657,_S656);
    float _S660 = (F32_sqrt(((F32_max((_S659 * (2.0f - _S659)), (0.0f))))));
    float _S661 = 6.28318548202514648f * u2_0;
    float3  _S662 = make_float3 (_S660 * (F32_cos((_S661))), 1.0f - _S659, _S660 * (F32_sin((_S661))));
    float3  _S663 = ((((_S654)) * make_float3(rnorm3df(((_S654)).x, ((_S654)).y, ((_S654)).z))));
    float3  _S664 = tangentToWorld(_S662, _S663);
    return _S664;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S665 = center_2 - ray_1->origin;
    float _S666 = dot_0(_S665, ray_1->unit_direction);
    float _S667 = dot_0(_S665, _S665) - _S666 * _S666;
    float _S668 = radius_3 * radius_3;
    bool _S669 = _S667 > _S668;
    if(_S669)
    {
        return 4.294967296e+09f;
    }
    float _S670 = (F32_sqrt((_S668 - _S667)));
    float _S671 = _S666 - _S670;
    float _S672 = _S666 + _S670;
    bool _S673 = _S671 > 0.0000152587890625f;
    bool _S674;
    if(_S673)
    {
        _S674 = _S671 < max_len_0;
    }
    else
    {
        _S674 = false;
    }
    if(_S674)
    {
        return _S671;
    }
    bool _S675 = _S672 > 0.0000152587890625f;
    if(_S675)
    {
        _S674 = _S672 < max_len_0;
    }
    else
    {
        _S674 = false;
    }
    if(_S674)
    {
        return _S672;
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
        int i_8 = int(0);
        float sum_0 = 0.0f;
        for(;;)
        {
            if(i_8 < int(3))
            {
            }
            else
            {
                break;
            }
            float sum_1 = sum_0 + _slang_vector_get_element(left_1, i_8) * _slang_vector_get_element(right_1.rows[i_8], j_1);
            i_8 = i_8 + int(1);
            sum_0 = sum_1;
        }
        *_slang_vector_get_element_ptr(&result_5, j_1) = sum_0;
        j_1 = j_1 + int(1);
    }
    return result_5;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S676 = pcg(init_random_state_1);
    Random _S677 = pcg(_S676.state);
    Random _S678 = pcg(_S677.state);
    float3  _S679 = make_float3 (0.0f);
    TreeSample _S680 = TreeSample_x24init_0(_S679, _S679, 0.0f, _S678.state);
    TreeSample sample_0 = _S680;
    float3  _S681 = _slang_select(sided_0, _S679,smooth_n_2);
    float3  _S682 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S676.value;
    float probability_4 = 1.0f;
    uint n_7 = 0U;
    for(;;)
    {
        uint4  _S683 = (fcptLightNode((n_7)));
        if((_S683.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S684 = (fcptLightSecond((n_7)));
        uint _S685 = n_7 + 1U;
        LightNode _S686 = (fcptLightBounds((_S685)));
        LightNode _S687 = (fcptLightBounds((_S684)));
        uint _S688 = pickChild(_S686, _S687, origin_4, _S681, &pick_1, &probability_4);
        bool _S689 = _S688 > 1U;
        if(_S689)
        {
            return sample_0;
        }
        bool _S690 = _S688 == 1U;
        uint _S691 = _slang_select(_S690, _S684,_S685);
        n_7 = _S691;
    }
    bool _S692 = n_7 == 0U;
    bool _S693;
    if(_S692)
    {
        LightNode _S694 = (fcptLightBounds((0U)));
        float _S695 = importance(_S694, origin_4, _S681);
        _S693 = !(_S695 > 0.0f);
    }
    else
    {
        _S693 = false;
    }
    if(_S693)
    {
        return sample_0;
    }
    uint4  _S696 = (fcptLightNode((n_7)));
    FKHit _S697 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S698 = (_S696.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S698)
    {
        FKLight _S699 = (fcptLight((_S696.y)));
        if(sided_0)
        {
            float _S700 = sign_0(dot_0(geometry_n_1, _S699.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S700);
            float3  _S701 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S701;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S682;
            lift_n_0 = smooth_n_2;
        }
        bool _S702 = (_S699.variance) == 0.0f;
        if(_S702)
        {
            float3  _S703 = _S699.position - emitter_point_0;
            float3  _S704 = ((((_S703)) * make_float3(rnorm3df(((_S703)).x, ((_S703)).y, ((_S703)).z))));
            (&sample_0)->dir = _S704;
            float3  _S705 = _S699.color * make_float3 (_S699.intensity) / make_float3 (dot_0(_S703, _S703) * probability_4);
            (&sample_0)->radiance = _S705;
            shadow_1 = _S703;
        }
        else
        {
            float3  _S706 = sampleSphere(_S699.position, _S699.variance, emitter_point_0, _S677.value, _S678.value);
            (&sample_0)->dir = _S706;
            float _S707 = sphereDensity(_S699.position, _S699.variance, emitter_point_0);
            float _S708 = probability_4 * _S707;
            (&sample_0)->density = _S708;
            float3  _S709 = pointLightRadiance(_S699.color, _S699.intensity, _S699.variance);
            float3  _S710 = _S709 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S710;
            FKRay _S711 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S712 = raySphere_0(_S699.position, _S699.variance, &_S711, 4.294967296e+09f);
            float3  _S713 = (&sample_0)->dir * make_float3 (_S712);
            shadow_1 = _S713;
        }
        emitter_0 = _S697;
        emitter_point_0 = _S679;
    }
    else
    {
        uint _S714 = _S696.y;
        uint _S715 = (fcptTriangleOffset((_S714)));
        uint _S716 = _S715 + _S696.z;
        Matrix<float, 3, 3>  _S717 = (fcptWorldTriangle((_S714), (_S716)));
        float _S718 = (F32_sqrt((_S677.value)));
        float2  _S719 = make_float2 (_S718 * (1.0f - _S678.value), _S718 * _S678.value);
        float3  _S720 = mul_0(make_float3 (1.0f - _S718, _S719.x, _S719.y), _S717);
        if(sided_0)
        {
            float _S721 = sign_0(dot_0(geometry_n_1, _S720 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S721);
            float3  _S722 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S722;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S723 = !((dot_0(smooth_n_2, _S720 - origin_4)) > 0.0f);
            if(_S723)
            {
                return sample_0;
            }
            emitter_point_0 = _S682;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S719, _S714, _S716, 0U, 0.0f);
        float3  _S724 = _S720 - emitter_point_0;
        float3  _S725 = ((((_S724)) * make_float3(rnorm3df(((_S724)).x, ((_S724)).y, ((_S724)).z))));
        (&sample_0)->dir = _S725;
        float _S726 = solidAngle(probability_4, cross_0(_S717.rows[int(1)] - _S717.rows[int(0)], _S717.rows[int(2)] - _S717.rows[int(0)]), _S724);
        (&sample_0)->density = _S726;
        bool _S727 = (fcptShadowFirst());
        bool _S728 = !_S727;
        if(_S728)
        {
            FKSurface _S729 = (fcptLightSurfaceAt((emitter_1), (_S720), (_S678.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S720 - origin_4))));
            (&sample_0)->random_state = _S729.random_state;
            float3  _S730 = _slang_select(_S729.skip, _S679,_S729.material.emissive);
            float3  _S731 = _S730 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S731;
        }
        shadow_1 = _S724;
        emitter_0 = emitter_1;
        emitter_point_0 = _S720;
    }
    FKHit _S732 = emitter_0;
    float3  _S733 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S678.state, &_S732);
    bool _S734 = (fcptShadowFirst());
    if(_S734)
    {
        _S693 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S693 = false;
    }
    if(_S693)
    {
        _S693 = !all_1(_S733 == _S679);
    }
    else
    {
        _S693 = false;
    }
    if(_S693)
    {
        FKSurface _S735 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S678.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S735.random_state;
        float3  _S736 = _slang_select(_S735.skip, _S679,_S735.material.emissive);
        float3  _S737 = _S736 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S737;
    }
    float3  _S738 = (&sample_0)->radiance * _S733;
    bool _S739 = all_1(_S733 == _S679);
    float3  _S740 = _slang_select(_S739, _S679,_S738);
    (&sample_0)->radiance = _S740;
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

__device__ float powerHeuristic(float a_7, float b_3)
{
    float _S741 = 1.0f / (1.0f + b_3 / a_7 * (b_3 / a_7));
    bool _S742 = b_3 > 0.0f;
    float _S743 = _slang_select(_S742, _S741,1.0f);
    return _S743;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S744 = vertex_0->none;
    if(_S744)
    {
        return 1.0f;
    }
    uint _S745 = (fcptLightSlot((*hit_1)));
    float _S746 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S745, light_point_1);
    float _S747 = powerHeuristic(vertex_0->pdf, _S746);
    return _S747;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_4)
{
    uint2  _S748 = (fcptEnvironmentMapSize());
    bool _S749 = (_S748.x) > 1U;
    bool _S750;
    if(_S749)
    {
        uint2  _S751 = (fcptEnvironmentMapSize());
        _S750 = (_S751.y) > 1U;
    }
    else
    {
        _S750 = false;
    }
    if(_S750)
    {
        float3  _S752 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_4)));
        return _S752;
    }
    float3  _S753 = (fcptAmbient());
    return _S753;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S754 = (fcptEnvironmentCdfSize());
    bool _S755 = (_S754.x) > 1U;
    bool _S756;
    if(_S755)
    {
        uint2  _S757 = (fcptEnvironmentCdfSize());
        _S756 = (_S757.y) > 1U;
    }
    else
    {
        _S756 = false;
    }
    bool _S758 = !_S756;
    if(_S758)
    {
        return false;
    }
    uint2  _S759 = (fcptEnvironmentMapSize());
    bool _S760 = (_S759.x) > 1U;
    if(_S760)
    {
        uint2  _S761 = (fcptEnvironmentMapSize());
        _S756 = (_S761.y) > 1U;
    }
    else
    {
        _S756 = false;
    }
    return _S756;
}

static __device__ float escapeWeight_0(float pdf_3, float3  dir_8)
{
    bool _S762 = pdf_3 <= 0.0f;
    bool _S763;
    if(_S762)
    {
        _S763 = true;
    }
    else
    {
        bool _S764 = environmentMapped_0();
        _S763 = !_S764;
    }
    if(_S763)
    {
        return 1.0f;
    }
    float _S765 = environmentPdf_0(dir_8);
    return pdf_3 / (pdf_3 + _S765);
}

static __device__ float3  min_1(float3  x_15, float3  y_4)
{
    float3  result_6;
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
        *_slang_vector_get_element_ptr(&result_6, i_9) = (F32_min((_slang_vector_get_element(x_15, i_9)), (_slang_vector_get_element(y_4, i_9))));
        i_9 = i_9 + int(1);
    }
    return result_6;
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S766 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S767 = make_int2 ((int)_S766.x, (int)_S766.y);
    uint _S768 = previousSeed_0(_S767);
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
            uint _S769 = previousSeed_0(_S767 + make_int2 (x_16, y_5));
            bool _S770 = _S769 == _S768;
            uint _S771 = _slang_select(_S770, 1U,0U);
            uint count_3 = count_2 + _S771;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S772 = float(count_2 - 1U) / 288.0f;
    bool _S773 = _S768 != 0U;
    float _S774 = _slang_select(_S773, _S772,0.0f);
    fcptStoreDuplication((_S767), (make_uint4 ((F32_asuint((_S774))), 0U, 0U, 0U)));
    return;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S775 = hash(index_0);
    uint _S776 = hash(seed_3 ^ _S775);
    return _S776;
}

static __device__ float4  asfloat_0(uint4  x_18)
{
    float4  result_7;
    int i_10 = int(0);
    for(;;)
    {
        if(i_10 < int(4))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_7, i_10) = (U32_asfloat((_slang_vector_get_element(x_18, i_10))));
        i_10 = i_10 + int(1);
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
    float _S777 = rgb_to_greyscale(weight_0);
    bool _S778 = _S777 > 0.0f;
    bool _S779;
    if(_S778)
    {
        _S779 = _S777 < 3.00000000549775576e+38f;
    }
    else
    {
        _S779 = false;
    }
    bool _S780 = !_S779;
    if(_S780)
    {
        return;
    }
    bool _S781 = sel_2->sums;
    if(_S781)
    {
        float3  _S782 = sel_2->color + weight_0;
        sel_2->color = _S782;
        return;
    }
    float _S783 = sel_2->w_sum + _S777;
    sel_2->w_sum = _S783;
    float3  _S784 = sel_2->color + weight_0;
    sel_2->color = _S784;
    Random _S785 = pcg(sel_2->random_state);
    sel_2->random_state = _S785.state;
    bool _S786 = (_S785.value * sel_2->w_sum) <= _S777;
    if(_S786)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S787 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S787;
    float _S788 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S788;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S789 = rgb_to_greyscale((&r_4)->f);
    float _S790 = sel_4.w_sum / _S789;
    bool _S791 = _S789 > 0.0f;
    float _S792 = _slang_select(_S791, _S790,0.0f);
    (&r_4)->w = _S792;
    (&r_4)->c = c_1;
    return r_4;
}

static __device__ uint2  asuint_0(float2  x_19)
{
    uint2  result_8;
    int i_11 = int(0);
    for(;;)
    {
        if(i_11 < int(2))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_8, i_11) = (F32_asuint((_slang_vector_get_element(x_19, i_11))));
        i_11 = i_11 + int(1);
    }
    return result_8;
}

static __device__ void restir_spatial_0(uint3  global_invocation_id_2)
{
    uint2  _S793 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S794 = make_int2 ((int)_S793.x, (int)_S793.y);
    float3  _S795 = make_float3 (0.0f);
    FKHit _S796 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S797 = Domain_x24init_0(_S795, _S795, &_S796, 0.0f, 0.0f);
    Domain dom_4 = _S797;
    bool _S798 = (fcptCurrentDomain((_S794), (&dom_4)));
    bool _S799 = !_S798;
    if(_S799)
    {
        Reservoir _S800 = (Reservoir{});
        fcptStoreReservoirPrevious((_S794), (_S800), ((&dom_4)->hit));
        return;
    }
    Reservoir _S801 = (fcptLoadReservoirTemporal((_S794)));
    uint t_13 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S801.c;
    for(;;)
    {
        uint _S802 = (fcptRestirNeighbours());
        if(t_13 < _S802)
        {
        }
        else
        {
            break;
        }
        int2  _S803 = partner_0(_S794, t_13);
        Domain neighbor_0 = _S797;
        bool _S804 = (fcptCurrentDomain((_S803), (&neighbor_0)));
        if(_S804)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S805 = (fcptReservoirTemporal((_S803), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S805.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_14 = t_13 + 1U;
        t_13 = t_14;
    }
    float _S806 = _S801.c / (F32_max((count_4), (1.0f)));
    float _S807 = rgb_to_greyscale(_S801.f);
    bool _S808 = count_4 == 0.0f;
    float _S809 = _slang_select(_S808, 1.0f,0.0f);
    Selection _S810 = (Selection{});
    Selection sel_5 = _S810;
    uint _S811 = (fcptFrame());
    uint _S812 = hash(_S811);
    uint _S813 = global_invocation_id_2.x;
    uint2  _S814 = (fcptRenderSize());
    uint _S815 = stream(_S812, _S813 + _S814.x * global_invocation_id_2.y);
    uint _S816 = stream(_S815, 195U);
    (&sel_5)->random_state = _S816;
    t_13 = 0U;
    float canonical_mis_0 = _S809;
    for(;;)
    {
        uint _S817 = (fcptRestirNeighbours());
        if(t_13 < _S817)
        {
        }
        else
        {
            break;
        }
        int2  _S818 = partner_0(_S794, t_13);
        Domain neighbor_dom_0 = _S797;
        bool _S819 = (fcptCurrentDomain((_S818), (&neighbor_dom_0)));
        if(_S819)
        {
            Reservoir _S820 = (fcptLoadReservoirTemporal((_S818)));
            uint4  _S821 = (fcptShiftData((_S818), (t_13)));
            float4  _S822 = asfloat_0(_S821);
            uint4  _S823 = (fcptShiftData((_S794), (t_13)));
            float4  _S824 = asfloat_0(_S823);
            float _S825 = pairShare(_S820.c, _S806, c_sum_1);
            bool _S826 = _S807 > 0.0f;
            float canonical_mis_1;
            if(_S826)
            {
                float _S827 = rgb_to_greyscale(float3 {_S824.x, _S824.y, _S824.z});
                float _S828 = canonicalWeight(_S825, _S806, _S807, _S820.c, _S827);
                float canonical_mis_2 = canonical_mis_0 + _S828;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S829 = float3 {_S822.x, _S822.y, _S822.z};
            Shift _S830 = Shift_x24init_0(_S829, _S822.w);
            float _S831 = rgb_to_greyscale(_S820.f);
            float _S832 = rgb_to_greyscale(_S829);
            float _S833 = neighborWeight(_S825, _S820.c, _S831, _S806, _S832);
            offerShifted(&sel_5, _S820, _S830, _S833);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_15 = t_13 + 1U;
        t_13 = t_15;
    }
    offerShifted(&sel_5, _S801, Shift_x24init_0(_S801.f, 1.0f), canonical_mis_0);
    Reservoir _S834 = finalize(sel_5, c_sum_1);
    fcptStoreReservoirPrevious((_S794), (_S834), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S794), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S794), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
    return;
}

static __device__ uint3  asuint_1(float3  x_20)
{
    uint3  result_9;
    int i_12 = int(0);
    for(;;)
    {
        if(i_12 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_9, i_12) = (F32_asuint((_slang_vector_get_element(x_20, i_12))));
        i_12 = i_12 + int(1);
    }
    return result_9;
}

static __device__ void restir_shift_0(uint3  workgroup_id_1, uint local_invocation_index_4)
{
    uint _S835 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S836 = _S835 != 4294967295U;
    if(_S836)
    {
        uint2  _S837 = make_uint2 (_S835, _S835 >> 14U) & make_uint2 (16383U);
        int2  _S838 = make_int2 ((int)_S837.x, (int)_S837.y);
        ShiftJob _S839 = (ShiftJob{});
        ShiftJob shift_job_0 = _S839;
        Shift _S840 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S841 = _S835 >> 28U;
        bool _S842 = spatialJob_0(_S838, _S841, &shift_job_0, true);
        Shift shifted_1;
        if(_S842)
        {
            Domain _S843 = (&shift_job_0)->dom;
            Reservoir _S844 = (&shift_job_0)->r;
            Shift _S845 = passShift_0(&_S843, &_S844);
            shifted_1 = _S845;
        }
        else
        {
            shifted_1 = _S840;
        }
        fcptStoreShiftData((_S838), (_S841), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S846 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S847 = make_int2 ((int)_S846.x, (int)_S846.y);
    FixedArray<uint, 3>  _S848;
    spatialBins_0(_S847, &_S848);
    FixedArray<uint, 3>  _S849 = _S848;
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
        bool _S850 = (_S849[t_16]) == 40U;
        if(_S850)
        {
            fcptStoreShiftData((_S847), (t_16), (make_uint4 (0U)));
        }
        uint t_17 = t_16 + 1U;
        t_16 = t_17;
    }
    FixedArray<uint, 3>  _S851 = _S849;
    queueShifts_0(_S847, &_S851, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S852 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S853 = make_int2 ((int)_S852.x, (int)_S852.y);
    FixedArray<uint, 3>  _S854;
    spatialBins_0(_S853, &_S854);
    FixedArray<uint, 3>  _S855 = _S854;
    countShifts_0(&_S855, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S856 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S857 = _S856 != 4294967295U;
    if(_S857)
    {
        uint2  _S858 = make_uint2 (_S856, _S856 >> 14U) & make_uint2 (16383U);
        int2  _S859 = make_int2 ((int)_S858.x, (int)_S858.y);
        int2  _S860 = (fcptLoadTemporalNeighbor((_S859)));
        uint _S861 = _S856 >> 28U;
        Shift _S862 = temporalShiftAt_0(_S859, _S860, _S861);
        fcptStoreTemporalShift((_S859), (_S861), (make_uint4 (asuint_1(_S862.f).x, asuint_1(_S862.f).y, asuint_1(_S862.f).z, (F32_asuint((_S862.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S863 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S864 = make_int2 ((int)_S863.x, (int)_S863.y);
    FixedArray<uint, 3>  _S865;
    temporalBins_0(_S864, &_S865);
    FixedArray<uint, 3>  _S866 = _S865;
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
        bool _S867 = (_S866[t_18]) == 40U;
        if(_S867)
        {
            fcptStoreTemporalShift((_S864), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S868 = _S866;
    queueShifts_0(_S864, &_S868, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S869 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S870 = make_int2 ((int)_S869.x, (int)_S869.y);
    bool _S871 = (fcptSceneUnchanged());
    bool _S872 = !_S871;
    bool _S873;
    if(_S872)
    {
        uint2  _S874 = (fcptRenderSize());
        int2  _S875 = make_int2 ((int)_S874.x, (int)_S874.y);
        _S873 = all_0(_S870 < _S875);
    }
    else
    {
        _S873 = false;
    }
    if(_S873)
    {
        Reservoir _S876 = (fcptLoadReservoirInitial((_S870)));
        int2  _S877 = sampleNeighbor_0(_S870, _S876.seed);
        fcptStoreTemporalNeighbor((_S870), (_S877));
    }
    FixedArray<uint, 3>  _S878;
    temporalBins_0(_S870, &_S878);
    FixedArray<uint, 3>  _S879 = _S878;
    countShifts_0(&_S879, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_8, float b_4, float t_20)
{
    return a_8 + (b_4 - a_8) * t_20;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S880 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S880;
}

__device__ float2  temporalWeights(float c_2, float p_c_1, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S881 = c_2 * p_c_1;
    float _S882 = c_t_0 * p_t_0;
    return make_float2 (_S881 / (_S881 + c_t_0 * g_previous_0), _S882 / (_S882 + c_2 * g_current_0));
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S883 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S884 = make_int2 ((int)_S883.x, (int)_S883.y);
    float3  _S885 = make_float3 (0.0f);
    FKHit _S886 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S887 = Domain_x24init_0(_S885, _S885, &_S886, 0.0f, 0.0f);
    Domain dom_5 = _S887;
    bool _S888 = (fcptCurrentDomain((_S884), (&dom_5)));
    bool _S889 = !_S888;
    if(_S889)
    {
        Reservoir _S890 = (Reservoir{});
        fcptStoreReservoirTemporal((_S884), (_S890), ((&dom_5)->hit));
        return;
    }
    Reservoir _S891 = (fcptLoadReservoirInitial((_S884)));
    bool _S892 = (fcptTemporalQueued());
    bool _S893 = (fcptSceneUnchanged());
    bool _S894;
    if(_S893)
    {
        _S894 = true;
    }
    else
    {
        _S894 = !_S892;
    }
    int2  _S895;
    if(_S894)
    {
        int2  _S896 = sampleNeighbor_0(_S884, _S891.seed);
        _S895 = _S896;
    }
    else
    {
        int2  _S897 = (fcptLoadTemporalNeighbor((_S884)));
        _S895 = _S897;
    }
    bool _S898 = (_S895.x) >= int(0);
    Reservoir r_5;
    if(_S898)
    {
        Reservoir _S899 = (fcptLoadReservoirPrevious((_S895)));
        uint4  _S900 = (fcptDuplication((_S895)));
        float _S901 = (U32_asfloat((_S900.x)));
        uint _S902 = (fcptRestirDecorrelation());
        bool _S903 = _S902 == 1U;
        float _S904 = _slang_select(_S903, _S901,0.0f);
        float _S905 = confidenceCap(_S904);
        float _S906 = (F32_min((_S899.c), (_S905)));
        bool _S907 = (fcptSceneUnchanged());
        float4  _S908 = make_float4 (_S899.f.x, _S899.f.y, _S899.f.z, 1.0f);
        bool _S909 = !_S907;
        if(_S909)
        {
            _S894 = _S892;
        }
        else
        {
            _S894 = false;
        }
        float4  to_current_0;
        if(_S894)
        {
            uint4  _S910 = (fcptTemporalShift((_S884), (0U)));
            float4  _S911 = asfloat_0(_S910);
            to_current_0 = _S911;
        }
        else
        {
            if(_S909)
            {
                Shift _S912 = temporalShiftAt_0(_S884, _S895, 0U);
                float4  _S913 = make_float4 (_S912.f.x, _S912.f.y, _S912.f.z, _S912.jac);
                to_current_0 = _S913;
            }
            else
            {
                to_current_0 = _S908;
            }
        }
        Domain own_1 = _S887;
        if(_S907)
        {
            _S894 = true;
        }
        else
        {
            bool _S914 = (fcptPreviousScenes());
            bool _S915 = !_S914;
            if(_S915)
            {
                _S894 = (_S891.w) > 0.0f;
            }
            else
            {
                _S894 = false;
            }
            if(_S894)
            {
                bool _S916 = (fcptStoredDomainInitial((_S884), (_S891.seed), (&own_1)));
                _S894 = _S916;
            }
            else
            {
                _S894 = false;
            }
            if(_S894)
            {
                Domain _S917 = (fcptPreviousDomain((_S895), (_S891.seed)));
                Domain _S918 = _S917;
                Domain _S919 = own_1;
                bool _S920 = sameDomain_0(&_S918, &_S919);
                _S894 = _S920;
            }
            else
            {
                _S894 = false;
            }
        }
        float4  _S921 = make_float4 (_S891.f.x, _S891.f.y, _S891.f.z, 1.0f);
        bool _S922 = !_S894;
        if(_S922)
        {
            _S894 = _S892;
        }
        else
        {
            _S894 = false;
        }
        float4  to_previous_0;
        if(_S894)
        {
            uint4  _S923 = (fcptTemporalShift((_S884), (1U)));
            float4  _S924 = asfloat_0(_S923);
            to_previous_0 = _S924;
        }
        else
        {
            if(_S922)
            {
                Shift _S925 = temporalShiftAt_0(_S884, _S895, 1U);
                float4  _S926 = make_float4 (_S925.f.x, _S925.f.y, _S925.f.z, _S925.jac);
                to_previous_0 = _S926;
            }
            else
            {
                to_previous_0 = _S921;
            }
        }
        float _S927 = rgb_to_greyscale(_S891.f);
        float _S928 = rgb_to_greyscale(_S899.f);
        Selection _S929 = (Selection{});
        Selection sel_6 = _S929;
        uint _S930 = (fcptFrame());
        uint _S931 = hash(_S930);
        uint _S932 = global_invocation_id_7.x;
        uint2  _S933 = (fcptRenderSize());
        uint _S934 = stream(_S931, _S932 + _S933.x * global_invocation_id_7.y);
        uint _S935 = stream(_S934, 194U);
        (&sel_6)->random_state = _S935;
        float4  _S936 = to_previous_0;
        float _S937 = rgb_to_greyscale(float3 {_S936.x, _S936.y, _S936.z});
        float4  _S938 = to_current_0;
        float3  _S939 = float3 {_S938.x, _S938.y, _S938.z};
        float _S940 = rgb_to_greyscale(_S939);
        float2  _S941 = temporalWeights(_S891.c, _S927, _S906, _S928, _S937, _S940);
        offerShifted(&sel_6, _S891, Shift_x24init_0(_S891.f, 1.0f), _S941.x);
        offerShifted(&sel_6, _S899, Shift_x24init_0(_S939, to_current_0.w), _S941.y);
        Reservoir _S942 = finalize(sel_6, _S891.c + _S906);
        r_5 = _S942;
    }
    else
    {
        r_5 = _S891;
    }
    fcptStoreReservoirTemporal((_S884), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S943 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S944 = make_int2 ((int)_S943.x, (int)_S943.y);
    float3  _S945 = make_float3 (0.0f);
    float2  _S946 = make_float2 (0.0f);
    FKHit _S947 = Hit_x24init_0(_S946, 0U, 0U, 0U, 0.0f);
    Domain _S948 = Domain_x24init_0(_S945, _S945, &_S947, 0.0f, 0.0f);
    Domain dom_6 = _S948;
    bool _S949 = (fcptCurrentDomain((_S944), (&dom_6)));
    bool _S950 = !_S949;
    if(_S950)
    {
        Reservoir _S951 = (Reservoir{});
        fcptStoreReservoirInitial((_S944), (_S951), ((&dom_6)->hit));
        return;
    }
    uint _S952 = (fcptFrame());
    uint _S953 = hash(_S952);
    uint _S954 = global_invocation_id_8.x;
    uint2  _S955 = (fcptRenderSize());
    uint _S956 = stream(_S953, _S954 + _S955.x * global_invocation_id_8.y);
    Selection _S957 = (Selection{});
    Selection initial_0 = _S957;
    uint _S958 = stream(_S956, 193U);
    (&initial_0)->random_state = _S958;
    bool _S959 = (fcptRestirUsed());
    bool _S960 = !_S959;
    (&initial_0)->sums = _S960;
    uint _S961 = stream(_S956, 0U);
    (&(&initial_0)->r)->seed = _S961;
    FKHit _S962 = Hit_x24init_0(_S946, 4294967295U, 0U, 0U, 0.0f);
    uint _S963 = (fcptSamples());
    float _S964 = 1.0f / float(_S963);
    FKHit hit_2 = _S962;
    uint i_13 = 0U;
    float3  seen_0 = _S945;
    for(;;)
    {
        uint _S965 = (fcptSamples());
        if(i_13 < _S965)
        {
        }
        else
        {
            break;
        }
        Reservoir _S966 = (Reservoir{});
        Reservoir r_6 = _S966;
        uint _S967 = stream(_S956, i_13);
        (&r_6)->seed = _S967;
        Domain path_0 = _S948;
        bool _S968 = (fcptStoredDomainInitial((_S944), ((&r_6)->seed), (&path_0)));
        bool _S969 = !_S968;
        if(_S969)
        {
            float3  _S970 = (fcptMissed((_S944), (path_0), (_S964)));
            float3  seen_1 = seen_0 + _S970;
            seen_0 = seen_1;
            uint i_14 = i_13 + 1U;
            i_13 = i_14;
            continue;
        }
        Domain _S971 = path_0;
        Reservoir _S972 = r_6;
        Shift _S973 = passWalk_0(&_S971, &_S972, false, _S964, &initial_0);
        bool _S974 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S974)
        {
            FKHit _S975 = (&path_0)->hit;
            hit_3 = _S975;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_14 = i_13 + 1U;
        i_13 = i_14;
    }
    uint _S976 = (fcptSamples());
    float3  seen_2 = seen_0 + (&initial_0)->glow / make_float3 (float(_S976));
    if((&initial_0)->sums)
    {
        seen_0 = seen_2 + (&initial_0)->color;
    }
    else
    {
        seen_0 = seen_2;
    }
    fcptAddColor((_S944), (make_float4 (seen_0.x, seen_0.y, seen_0.z, 1.0f)));
    Reservoir _S977 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S944), (_S977), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S978;
    (&_S978)->none = none_0;
    (&_S978)->pdf = pdf_4;
    (&_S978)->origin = origin_5;
    (&_S978)->smooth_n = smooth_n_3;
    (&_S978)->start = start_6;
    return _S978;
}

struct Vertex
{
    bool rough;
    uint lobe;
    float pdf;
    float cos;
    bool inside;
};

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_5, float pdf_5, float cos_0, bool inside_0)
{
    Vertex _S979;
    (&_S979)->rough = rough_0;
    (&_S979)->lobe = lobe_5;
    (&_S979)->pdf = pdf_5;
    (&_S979)->cos = cos_0;
    (&_S979)->inside = inside_0;
    return _S979;
}

static __device__ float freeFlight_0(float u_1, float sigma_0)
{
    return - (F32_log((1.0f - u_1))) / sigma_0;
}

static __device__ float3  exp_0(float3  x_21)
{
    float3  result_10;
    int i_15 = int(0);
    for(;;)
    {
        if(i_15 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_10, i_15) = (F32_exp((_slang_vector_get_element(x_21, i_15))));
        i_15 = i_15 + int(1);
    }
    return result_10;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_1, float distance_2, bool scatters_0)
{
    float3  _S980 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_2));
    float3  _S981 = scatter_0 * _S980 / make_float3 (sigma_1);
    float3  _S982 = _slang_select(scatters_0, _S981,_S980);
    return _S982;
}

static __device__ bool scatterSampled_0(bool replay_1, uint b_5, uint stop_0, bool varying_0)
{
    bool _S983 = !replay_1;
    bool _S984;
    if(_S983)
    {
        _S984 = true;
    }
    else
    {
        bool _S985 = b_5 == stop_0;
        if(_S985)
        {
            _S984 = !varying_0;
        }
        else
        {
            _S984 = false;
        }
    }
    return _S984;
}

static __device__ uint arrivalLobe_0(uint b_6, uint prev_lobe_0)
{
    bool _S986 = b_6 > 0U;
    uint _S987 = _slang_select(_S986, prev_lobe_0,3U);
    return _S987;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_6, bool surface_4, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S988;
    (&_S988)->extinction_behind = extinction_behind_0;
    (&_S988)->extinction_front = extinction_front_0;
    (&_S988)->fillings = fillings_0;
    (&_S988)->side = side_0;
    (&_S988)->depth = depth_1;
    (&_S988)->lobe = lobe_6;
    (&_S988)->surface = surface_4;
    (&_S988)->length = length_2;
    (&_S988)->width = width_1;
    (&_S988)->own = *own_2;
    (&_S988)->fiber = fiber_0;
    return _S988;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S989 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S989)
    {
        return 0.07957746833562851f;
    }
    float _S990 = g_0 * g_0;
    return (1.0f - _S990) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S990 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_9, float3  b_7)
{
    float3  _S991 = a_9 / b_7;
    float3  _S992 = make_float3 (0.0f);
    bool3  _S993 = b_7 == _S992;
    float3  _S994 = _slang_select(_S993, _S992,_S991);
    return _S994;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S995 = (1U << count_6) - 1U;
    return (e_2 & (~(_S995 << offset_1))) | ((newbits_0 & _S995) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_6)
{
    Reservoir candidate_2 = r_7;
    uint _S996 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S997 = insertBits_0(_S996, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S997;
    (&candidate_2)->f = f_6;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_1, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S998 = pcg(random_state_9);
    Random _S999 = pcg(_S998.state);
    float _S1000 = 1.0f - 2.0f * _S998.value;
    float _S1001 = (F32_sqrt(((F32_max((1.0f - _S1000 * _S1000), (0.0f))))));
    float _S1002 = 6.28318548202514648f * _S999.value;
    return make_float3 (_S1001 * (F32_cos((_S1002))), _S1001 * (F32_sin((_S1002))), _S1000);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_10, float * pdf_6)
{
    bool _S1003 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1003)
    {
        *pdf_6 = 0.07957746833562851f;
        float3  _S1004 = isotropic_0(random_state_10);
        return _S1004;
    }
    Random _S1005 = pcg(random_state_10);
    Random _S1006 = pcg(_S1005.state);
    float _S1007 = g_1 * g_1;
    float _S1008 = 2.0f * g_1;
    float _S1009 = (1.0f - _S1007) / (1.0f - g_1 + _S1008 * _S1005.value);
    float _S1010 = clamp_1((1.0f + _S1007 - _S1009 * _S1009) / _S1008, -1.0f, 1.0f);
    float _S1011 = (F32_sqrt(((F32_max((1.0f - _S1010 * _S1010), (0.0f))))));
    float _S1012 = 6.28318548202514648f * _S1006.value;
    float _S1013 = phaseHG_0(g_1, _S1010);
    *pdf_6 = _S1013;
    float3  _S1014 = tangentToWorld(make_float3 (_S1011 * (F32_cos((_S1012))), _S1010, _S1011 * (F32_sin((_S1012)))), dir_9);
    float3  _S1015 = ((((_S1014)) * make_float3(rnorm3df(((_S1014)).x, ((_S1014)).y, ((_S1014)).z))));
    return _S1015;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_2)
{
    BSDFMaterial _S1016;
    (&_S1016)->albedo = albedo_0;
    (&_S1016)->emissive = emissive_0;
    (&_S1016)->roughness = roughness_0;
    (&_S1016)->metallic = metallic_0;
    (&_S1016)->transmission = transmission_0;
    (&_S1016)->ior = ior_0;
    (&_S1016)->absorption = absorption_0;
    (&_S1016)->specular_tint = specular_tint_0;
    (&_S1016)->specular_level = specular_level_0;
    (&_S1016)->translucent = translucent_0;
    (&_S1016)->sheen = sheen_2;
    (&_S1016)->sheen_roughness = sheen_roughness_0;
    (&_S1016)->anisotropy = anisotropy_0;
    (&_S1016)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1016)->tangent = tangent_2;
    (&_S1016)->velvet = velvet_0;
    (&_S1016)->toon = toon_2;
    return _S1016;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1017;
    (&_S1017)->scatter = scatter_1;
    (&_S1017)->extinction = extinction_1;
    (&_S1017)->g = g_2;
    return _S1017;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_6, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1018;
    (&_S1018)->smooth_n = smooth_n_4;
    (&_S1018)->geometry_n = geometry_n_2;
    (&_S1018)->geometry_offset = geometry_offset_2;
    (&_S1018)->material = *material_6;
    (&_S1018)->skip = skip_0;
    (&_S1018)->random_state = random_state_11;
    (&_S1018)->coverage = coverage_0;
    (&_S1018)->encloses = encloses_0;
    (&_S1018)->volume = *volume_0;
    (&_S1018)->fills = fills_0;
    (&_S1018)->hair = hair_0;
    return _S1018;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S1019 = (&surface_5->material)->emissive;
    float3  _S1020 = make_float3 (0.0f);
    bool _S1021 = !top_0;
    float3  _S1022 = _slang_select(_S1021, _S1020,_S1019);
    (&(&lower_0)->material)->emissive = _S1022;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_2)
{
    float _S1023 = surface_6->coverage;
    bool _S1024 = u_2 < _S1023;
    if(_S1024)
    {
        return *surface_6;
    }
    float3  _S1025 = make_float3 (0.0f);
    float3  _S1026 = make_float3 (1.0f);
    BSDFMaterial _S1027 = Material_x24init_0(_S1025, _S1025, 0.0f, 0.0f, 0.0f, 0.0f, _S1025, _S1026, 1.0f, _S1025, _S1025, 0.5f, 0.0f, 0.0f, _S1025, 0.0f, _S1025);
    BSDFMaterial material_7 = _S1027;
    (&material_7)->albedo = _S1026;
    (&material_7)->emissive = (&surface_6->material)->emissive;
    (&material_7)->transmission = 1.0f;
    (&material_7)->ior = 1.0f;
    (&material_7)->absorption = (&surface_6->material)->absorption;
    FKSurface through_0 = *surface_6;
    (&through_0)->material = material_7;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S1028 = transmission_1 > 0.0f;
    bool _S1029;
    if(_S1028)
    {
        _S1029 = true;
    }
    else
    {
        _S1029 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1030;
    if(_S1029)
    {
        _S1030 = 1.0f;
    }
    else
    {
        _S1030 = -1.0f;
    }
    return _S1030;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_8)
{
    return (dot_0(dir_10, n_8)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_11)
{
    float3  _S1031 = surface_7->geometry_n;
    float _S1032 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_11);
    FKSurface faced_0 = *surface_7;
    float3  _S1033 = surface_7->smooth_n * make_float3 (_S1032);
    (&faced_0)->smooth_n = _S1033;
    float3  _S1034 = _S1031 * make_float3 (_S1032);
    (&faced_0)->geometry_n = _S1034;
    return faced_0;
}

static __device__ float3  max_0(float3  x_22, float3  y_7)
{
    float3  result_11;
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
        *_slang_vector_get_element_ptr(&result_11, i_16) = (F32_max((_slang_vector_get_element(x_22, i_16)), (_slang_vector_get_element(y_7, i_16))));
        i_16 = i_16 + int(1);
    }
    return result_11;
}

static __device__ float3  log_0(float3  x_23)
{
    float3  result_12;
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
        *_slang_vector_get_element_ptr(&result_12, i_17) = (F32_log((_slang_vector_get_element(x_23, i_17))));
        i_17 = i_17 + int(1);
    }
    return result_12;
}

__device__ float3  beerLambert(float distance_3, float3  absorption_1)
{
    float3  _S1035 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1035));
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
    bool _S1036;
    if(open_0)
    {
        _S1036 = prev_rough_0;
    }
    else
    {
        _S1036 = false;
    }
    if(_S1036)
    {
        _S1036 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S1036 = false;
    }
    return _S1036;
}

__device__ float2  vertexEta(BSDFMaterial material_8, float n_dot_v_0)
{
    bool _S1037 = n_dot_v_0 < 0.0f;
    float _S1038 = _slang_select(_S1037, material_8.ior,1.0f);
    float _S1039 = _slang_select(_S1037, 1.0f,material_8.ior);
    return make_float2 (_S1038, _S1039);
}

__device__ bool neeDecision(BSDFMaterial material_9, float n_dot_v_1, float eta_i_5, float eta_o_5)
{
    float _S1040 = fresnel((F32_abs((n_dot_v_1))), eta_i_5, eta_o_5);
    float3  _S1041 = mix_0(make_float3 (_S1040), material_9.albedo, material_9.metallic);
    float _S1042 = rgb_to_greyscale(_S1041);
    float _S1043 = (F32_max(((1.0f - _S1042) * (1.0f - material_9.metallic) * (1.0f - material_9.transmission)), (0.0f)));
    bool _S1044 = _S1043 > 0.03999999910593033f;
    bool _S1045;
    if(_S1044)
    {
        _S1045 = true;
    }
    else
    {
        _S1045 = (material_9.roughness) > 0.20000000298023224f;
    }
    return _S1045;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_10)
{
    float _S1046 = rgb_to_greyscale(material_10->translucent);
    return _S1046 > 0.0f;
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
    MediumSides _S1047;
    (&_S1047)->behind = *behind_0;
    (&_S1047)->front = *front_0;
    (&_S1047)->fillings = fillings_1;
    (&_S1047)->face = face_1;
    return _S1047;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1048 = surface_8->geometry_n;
    MediumSides _S1049 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S1049;
    bool _S1050 = surface_8->encloses;
    if(_S1050)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S1051 = (dot_0(dir_12, _S1048)) > 0.0f;
        if(_S1051)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_7, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1052 = surface_9->geometry_n;
    ShadowContext _S1053 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_2, lobe_7, true, length_3, width_2, own_3, fiber_1);
    bool _S1054 = surface_9->encloses;
    ShadowContext context_4;
    if(_S1054)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S1055 = - _S1052;
        float3  _S1056 = _slang_select(turned_0, _S1055,_S1052);
        (&faced_1)->geometry_n = _S1056;
        FKMedium _S1057 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1058 = faced_1;
        FKMedium _S1059 = _S1057;
        MediumSides _S1060 = mediumSides_0(&_S1058, &_S1059, filling_1, dir_13, outside_1);
        ShadowContext _S1061 = ShadowContext_x24init_0(_S1060.behind.extinction, _S1060.front.extinction, _S1060.fillings, _S1052, depth_2, lobe_7, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1062 = _S1060.fillings;
            ShadowContext _S1063 = ShadowContext_x24init_0(_S1060.front.extinction, _S1060.behind.extinction, uint2 {_S1062.y, _S1062.x}, _S1052, depth_2, lobe_7, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1063;
        }
        else
        {
            context_4 = _S1061;
        }
    }
    else
    {
        context_4 = _S1053;
    }
    return context_4;
}

static __device__ bool any_1(bool3  x_24)
{
    bool result_13 = false;
    int i_18 = int(0);
    for(;;)
    {
        if(i_18 < int(3))
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
            result_13 = (bool((_slang_vector_get_element(x_24, i_18))));
        }
        i_18 = i_18 + int(1);
    }
    return result_13;
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_5, float3  out_dir_1, float3  n_9, float3  g_n_0, BSDFMaterial material_11, float eta_i_6, float eta_o_6, uint random_state_12)
{
    float3  _S1064 = negate_0(in_dir_5);
    bool _S1065 = (dot_0(g_n_0, _S1064) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S1065)
    {
        SampleBSDF _S1066 = connectBSDF(in_dir_5, out_dir_1, n_9, material_11, eta_i_6, eta_o_6, 0U, random_state_12);
        SampleBSDF _S1067 = connectBSDF(in_dir_5, out_dir_1, n_9, material_11, eta_i_6, eta_o_6, 2U, random_state_12);
        SampleBSDF _S1068 = connectBSDF(in_dir_5, out_dir_1, n_9, material_11, eta_i_6, eta_o_6, 4U, random_state_12);
        bool _S1069 = (F32_abs((material_11.toon.x))) > 0.0f;
        if(_S1069)
        {
            SampleBSDF _S1070 = connectBSDF(in_dir_5, out_dir_1, n_9, material_11, eta_i_6, eta_o_6, 6U, random_state_12);
            return _S1066.throughput * make_float3 (_S1066.pdf) + _S1067.throughput * make_float3 (_S1067.pdf) + _S1068.throughput * make_float3 (_S1068.pdf) + _S1070.throughput * make_float3 (_S1070.pdf);
        }
        return _S1066.throughput * make_float3 (_S1066.pdf) + _S1067.throughput * make_float3 (_S1067.pdf) + _S1068.throughput * make_float3 (_S1068.pdf);
    }
    SampleBSDF _S1071 = connectBSDF(in_dir_5, out_dir_1, n_9, material_11, eta_i_6, eta_o_6, 1U, random_state_12);
    return _S1071.throughput * make_float3 (_S1071.pdf);
}

__device__ float3  translucentCorrection(float3  in_dir_6, float3  out_dir_2, float3  n_10, float3  g_n_1, BSDFMaterial material_12, float eta_i_7, float eta_o_7, uint random_state_13)
{
    float _S1072 = dot_0(n_10, out_dir_2);
    float3  _S1073 = negate_0(in_dir_6);
    bool _S1074 = (_S1072 * dot_0(n_10, _S1073)) < 0.0f;
    SampleBSDF _S1075 = connectBSDF(in_dir_6, out_dir_2, n_10, material_12, eta_i_7, eta_o_7, 0U, random_state_13);
    float3  _S1076 = negate_0(in_dir_6);
    bool _S1077 = (dot_0(g_n_1, _S1076) * dot_0(g_n_1, out_dir_2)) > 0.0f;
    float3  _S1078 = make_float3 (0.0f);
    float3  _S1079 = _S1075.throughput * make_float3 (_S1075.pdf);
    float _S1080 = _slang_select(_S1077, -1.0f,1.0f);
    float3  _S1081 = _S1079 * make_float3 (_S1080);
    float3  _S1082 = _slang_select(_S1074, _S1081,_S1078);
    return _S1082;
}

__device__ float3  translucentBSDF(float3  in_dir_7, float3  out_dir_3, float3  n_11, float3  g_n_2, BSDFMaterial material_13, float eta_i_8, float eta_o_8, uint random_state_14)
{
    float3  _S1083 = BSDF(in_dir_7, out_dir_3, n_11, g_n_2, material_13, eta_i_8, eta_o_8, random_state_14);
    float3  _S1084 = translucentCorrection(in_dir_7, out_dir_3, n_11, g_n_2, material_13, eta_i_8, eta_o_8, random_state_14);
    return _S1083 + _S1084;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_14, float eta_i_9, float eta_o_9, bool competing_1, uint random_state_15)
{
    bool _S1085 = !competing_1;
    bool _S1086;
    if(_S1085)
    {
        _S1086 = true;
    }
    else
    {
        _S1086 = (light_2->density) == 0.0f;
    }
    if(_S1086)
    {
        bool _S1087 = isTranslucent_0(material_14);
        if(_S1087)
        {
            float3  _S1088 = translucentBSDF(in_dir_8, light_2->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_9, eta_o_9, random_state_15);
            return _S1088 * light_2->radiance;
        }
        float3  _S1089 = BSDF(in_dir_8, light_2->dir, smooth_n_5, geometry_n_4, *material_14, eta_i_9, eta_o_9, random_state_15);
        return _S1089 * light_2->radiance;
    }
    float3  _S1090 = light_2->dir;
    bool _S1091 = (dot_0(geometry_n_4, - in_dir_8) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    float3  _S1092 = neeBSDF(in_dir_8, _S1090, smooth_n_5, *material_14, eta_i_9, eta_o_9, _S1091, light_2->density, true, random_state_15);
    return _S1092 * light_2->radiance * make_float3 (light_2->density);
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1093 = (F32_sqrt((random_1_0)));
    float _S1094 = 6.28318548202514648f * random_2_0;
    float _S1095 = _S1093 * (F32_cos((_S1094)));
    float _S1096 = _S1093 * (F32_sin((_S1094)));
    float _S1097 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1095 * _S1095 - _S1096 * _S1096))))));
    return make_float3 (_S1095, _S1097, _S1096);
}

static __device__ float3  reflect_0(float3  i_19, float3  n_12)
{
    return i_19 - make_float3 (2.0f * dot_0(n_12, i_19)) * n_12;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_9, float3  n_13, BSDFMaterial material_15, float eta_i_10, float eta_o_10, uint random_init_1, float2  screen_space_0)
{
    uint random_state_16 = random_init_1;
    float3  _S1098 = negate_0(in_dir_9);
    float _S1099 = dot_0(n_13, _S1098);
    float _S1100 = sign_0(_S1099);
    float3  n_i_4 = n_13 * make_float3 (_S1100);
    float _S1101 = (F32_abs((_S1099)));
    float _S1102 = material_15.roughness;
    float _S1103 = _S1102 * _S1102;
    AnisotropicFrame _S1104 = anisotropicFrame(material_15, n_i_4);
    float3  _S1105 = sampleHalfVector(_S1098, n_i_4, _S1103, _S1104, &random_state_16);
    BSDFLobes _S1106 = bsdfLobes(in_dir_9, _S1098, n_i_4, _S1105, material_15, eta_i_10, eta_o_10, _S1104);
    BSDFLobes lobes_3 = _S1106;
    float _S1107 = translucentShare(material_15);
    (&lobes_3)->translucent_share = _S1107;
    float3  _S1108 = make_float3 (1.0f);
    SampleBSDF _S1109 = SampleBSDF_x24init_0(_S1108, _S1108, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1109;
    Random _S1110 = pcg(random_state_16);
    random_state_16 = _S1110.state;
    bool _S1111 = (_S1110.value) < ((&lobes_3)->p_sheen_velvet);
    if(_S1111)
    {
        Random _S1112 = pcg(random_state_16);
        Random _S1113 = pcg(_S1112.state);
        (&sample_1)->random_state = _S1113.state;
        float _S1114 = _S1112.value;
        float _S1115 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1114 * _S1114))))));
        float _S1116 = 6.28318548202514648f * _S1113.value;
        float3  _S1117 = tangentToWorld(make_float3 (_S1115 * (F32_cos((_S1116))), _S1112.value, _S1115 * (F32_sin((_S1116)))), n_i_4);
        (&sample_1)->unit_direction = _S1117;
        float3  _S1118 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1103, material_15, lobes_3, 4U);
        (&sample_1)->throughput = _S1118;
        float _S1119 = lobeDensity(_S1112.value, 0.0f, _S1101, _S1103, lobes_3, eta_i_10, eta_o_10, 4U);
        (&sample_1)->pdf = _S1119;
        (&sample_1)->lobe = 4U;
        return sample_1;
    }
    float _S1120 = _S1110.value - (&lobes_3)->p_sheen_velvet;
    bool _S1121 = _S1120 < ((&lobes_3)->p_diffuse);
    if(_S1121)
    {
        Random _S1122 = pcg(random_state_16);
        Random _S1123 = pcg(_S1122.state);
        (&sample_1)->random_state = _S1123.state;
        float3  _S1124 = sampleCosWeightedHemisphere(_S1122.value, _S1123.value);
        bool _S1125 = _S1120 < ((&lobes_3)->p_diffuse * (&lobes_3)->translucent_share);
        float _S1126 = _S1124.y;
        float _S1127 = - _S1126;
        float _S1128 = _slang_select(_S1125, _S1127,_S1126);
        float3  _S1129 = tangentToWorld(make_float3 (_S1124.x, _S1128, _S1124.z), n_i_4);
        (&sample_1)->unit_direction = _S1129;
        float3  _S1130 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1103, material_15, lobes_3, 0U);
        (&sample_1)->throughput = _S1130;
        float _S1131 = lobeDensity(_S1128, 0.0f, _S1101, _S1103, lobes_3, eta_i_10, eta_o_10, 0U);
        (&sample_1)->pdf = _S1131;
        (&sample_1)->refracted = _S1125;
        return sample_1;
    }
    bool _S1132 = _S1120 < ((&lobes_3)->p_diffuse + (&lobes_3)->p_toon);
    if(_S1132)
    {
        Random _S1133 = pcg(random_state_16);
        Random _S1134 = pcg(_S1133.state);
        (&sample_1)->random_state = _S1134.state;
        float _S1135 = (&lobes_3)->toon_a;
        float _S1136 = (&lobes_3)->toon_s;
        bool _S1137 = (&lobes_3)->toon_glossy;
        float _S1138 = _S1133.value * (&lobes_3)->toon_norm / 6.28318548202514648f;
        float t_21;
        if(_S1137)
        {
            t_21 = (F32_acos((clamp_1(1.0f - _S1138, -1.0f, 1.0f))));
        }
        else
        {
            t_21 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1138)))), (1.0f))))));
        }
        if(t_21 < _S1135)
        {
        }
        else
        {
            t_21 = (_S1135 + (&lobes_3)->toon_b) / 2.0f;
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
            float _S1139;
            if(t_21 < _S1135)
            {
                _S1139 = 1.0f;
            }
            else
            {
                _S1139 = (F32_max((1.0f - (t_21 - _S1135) / (F32_max((_S1136), (0.0000152587890625f)))), (0.0f)));
            }
            float integral_1;
            if(_S1137)
            {
                integral_1 = 1.0f - (F32_cos(((F32_min((t_21), (_S1135))))));
            }
            else
            {
                float _S1140 = (F32_sin(((F32_min((t_21), (_S1135))))));
                integral_1 = _S1140 * _S1140 / 2.0f;
            }
            bool _S1141 = t_21 > _S1135;
            bool _S1142;
            if(_S1141)
            {
                _S1142 = _S1136 > 0.0f;
            }
            else
            {
                _S1142 = false;
            }
            float integral_2;
            if(_S1142)
            {
                if(_S1137)
                {
                    float _S1143 = (F32_cos((_S1135)));
                    float _S1144 = (F32_cos((t_21)));
                    integral_2 = (1.0f + _S1135 / _S1136) * (_S1143 - _S1144) - ((F32_sin((t_21))) - t_21 * _S1144 - ((F32_sin((_S1135))) - _S1135 * _S1143)) / _S1136;
                }
                else
                {
                    float _S1145 = 2.0f * _S1135;
                    float _S1146 = (F32_cos((_S1145)));
                    float _S1147 = 2.0f * t_21;
                    float _S1148 = (F32_cos((_S1147)));
                    integral_2 = (1.0f + _S1135 / _S1136) * (_S1146 - _S1148) / 4.0f - ((F32_sin((_S1147))) / 8.0f - t_21 * _S1148 / 4.0f - ((F32_sin((_S1145))) / 8.0f - _S1135 * _S1146 / 4.0f)) / _S1136;
                }
                float integral_3 = integral_1 + integral_2;
                integral_2 = integral_3;
            }
            else
            {
                integral_2 = integral_1;
            }
            float _S1149 = _S1139 * (F32_sin((t_21)));
            float _S1150;
            if(_S1137)
            {
                _S1150 = 1.0f;
            }
            else
            {
                _S1150 = (F32_cos((t_21)));
            }
            float _S1151 = _S1149 * _S1150;
            float _S1152 = (integral_2 - _S1138) / _S1151;
            bool _S1153 = _S1151 > 0.0f;
            float _S1154 = _slang_select(_S1153, _S1152,0.0f);
            float _S1155 = clamp_1(t_21 - _S1154, 0.0f, (&lobes_3)->toon_b);
            int k_1 = k_0 + int(1);
            t_21 = _S1155;
            k_0 = k_1;
        }
        float _S1156 = 6.28318548202514648f * _S1134.value;
        float _S1157 = (F32_sin((t_21)));
        float3  _S1158 = tangentToWorld(make_float3 (_S1157 * (F32_cos((_S1156))), (F32_cos((t_21))), _S1157 * (F32_sin((_S1156)))), (&lobes_3)->toon_axis);
        (&sample_1)->unit_direction = _S1158;
        float3  _S1159 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1103, material_15, lobes_3, 6U);
        (&sample_1)->throughput = _S1159;
        float _S1160 = lobeDensity(dot_0(n_i_4, (&sample_1)->unit_direction), dot_0((&sample_1)->unit_direction, (&lobes_3)->toon_axis), _S1101, _S1103, lobes_3, eta_i_10, eta_o_10, 6U);
        (&sample_1)->pdf = _S1160;
        bool _S1161 = (dot_0(n_i_4, (&sample_1)->unit_direction)) < 0.0f;
        (&sample_1)->refracted = _S1161;
        (&sample_1)->lobe = 6U;
        return sample_1;
    }
    float _S1162 = _S1120 - (&lobes_3)->p_toon;
    bool _S1163 = _S1162 < ((&lobes_3)->p_diffuse + (&lobes_3)->p_refract);
    if(_S1163)
    {
        (&sample_1)->unit_direction = (&lobes_3)->refracted;
        float _S1164 = lobeDensity(0.0f, dot_0((&sample_1)->unit_direction, _S1105), _S1101, _S1103, lobes_3, eta_i_10, eta_o_10, 1U);
        (&sample_1)->pdf = _S1164;
        float3  _S1165 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1103, material_15, lobes_3, 1U);
        (&sample_1)->throughput = _S1165;
        (&sample_1)->random_state = random_state_16;
        (&sample_1)->refracted = true;
        (&sample_1)->lobe = 1U;
        return sample_1;
    }
    float3  _S1166 = reflect_0(in_dir_9, _S1105);
    float3  _S1167 = ((((_S1166)) * make_float3(rnorm3df(((_S1166)).x, ((_S1166)).y, ((_S1166)).z))));
    (&sample_1)->unit_direction = _S1167;
    float3  _S1168 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1103, material_15, lobes_3, 2U);
    (&sample_1)->throughput = _S1168;
    (&sample_1)->random_state = random_state_16;
    (&sample_1)->lobe = 2U;
    float _S1169 = lobeDensity(0.0f, 0.0f, _S1101, _S1103, lobes_3, eta_i_10, eta_o_10, 2U);
    (&sample_1)->pdf = _S1169;
    return sample_1;
}

__device__ bool withinInverseFootprint(float pdf_7, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1170 = pdf_7 > 0.0f;
    bool _S1171;
    if(_S1170)
    {
        if(diffuse_0)
        {
            _S1171 = true;
        }
        else
        {
            _S1171 = (pdf_7 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1171 = false;
    }
    return _S1171;
}

__device__ bool roughLobe(float pdf_8, bool diffuse_1, float roughness_1)
{
    bool _S1172 = pdf_8 > 0.0f;
    bool _S1173;
    if(_S1172)
    {
        if(diffuse_1)
        {
            _S1173 = true;
        }
        else
        {
            _S1173 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1173 = false;
    }
    return _S1173;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1174 = layers_0 > 1U;
    bool _S1175;
    if(_S1174)
    {
        _S1175 = refracting_0 != passed_0;
    }
    else
    {
        _S1175 = false;
    }
    return _S1175;
}

static __device__ float widened_0(float spread_1, float pdf_9, bool delta_0)
{
    float _S1176 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_9))))), (3.14159274101257324f)));
    bool _S1177 = !delta_0;
    float _S1178 = _slang_select(_S1177, _S1176,0.0f);
    return spread_1 + _S1178;
}

static __device__ bool boundsVolume_0(FKSurface * surface_10)
{
    return surface_10->encloses;
}

static __device__ bool leavesInFront_0(float3  face_2, float3  dir_14, float3  g_3)
{
    return ((dot_0(dir_14, g_3)) > 0.0f) == ((dot_0(g_3, face_2)) > 0.0f);
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_8, bool replay_2, float scale_3, Selection * sel_7)
{
    float spread_2;
    bool turned_1;
    bool is_inside_5;
    bool viewed_0;
    bool scatter_2;
    float density_2;
    float threshold_2;
    float width_3;
    float sky_pdf_0;
    float geometry_density_2;
    uint b_8;
    uint layer_0;
    float3  throughput_2;
    float3  chain_throughput_0;
    TreeSample light_3;
    int _S1179;
    Shift ended_0;
    float density_3;
    float spread_3;
    float width_4;
    float sky_pdf_1;
    float spread_4;
    float width_5;
    uint b_9;
    float3  _S1180 = make_float3 (0.0f);
    Shift _S1181 = Shift_x24init_0(_S1180, 0.0f);
    uint _S1182 = r_8->path;
    uint _S1183 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1184 = extractBits_0(_S1182, 5U, 5U);
    uint _S1185 = extractBits_0(_S1182, 10U, 2U);
    uint _S1186 = extractBits_0(_S1182, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1187 = _S1186 >= 3U;
        uint _S1188 = _slang_select(_S1187, 1U,0U);
        uint _S1189 = _S1183 + _S1188;
        uint _S1190 = (fcptMaxBounces());
        passes_0 = _S1189 > _S1190;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1181;
    }
    uint _S1191 = _S1184 - 1U;
    bool _S1192 = _S1186 == 3U;
    uint _S1193 = _slang_select(_S1192, 1U,0U);
    uint _S1194 = _S1183 + _S1193;
    bool _S1195 = _S1185 == 0U;
    uint _S1196 = _slang_select(_S1195, _S1194,_S1191);
    FKHit _S1197 = (fcptReservoirHit((*r_8)));
    float3  _S1198 = dom_7->x0;
    float3  _S1199 = dom_7->x1 - dom_7->x0;
    float3  _S1200 = ((((_S1199)) * make_float3(rnorm3df(((_S1199)).x, ((_S1199)).y, ((_S1199)).z))));
    FKRay _S1201 = Ray_x24init_0(dom_7->x1, _S1200);
    FKRay ray_2 = _S1201;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1180;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1180;
    float3  extinction_in_0 = _S1180;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1202 = dom_7->spread;
    float _S1203 = dom_7->width;
    float _S1204 = length_0(_S1199);
    NEEVertex _S1205 = NEEVertex_x24init_0(true, 0.0f, _S1180, _S1180, _S1180);
    NEEVertex nee_vertex_0 = _S1205;
    Vertex _S1206 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1206;
    Reservoir _S1207 = (Reservoir{});
    Reservoir chain_0 = _S1207;
    uint _S1208 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1198;
    (&hit_4)->distance = _S1204;
    FKMedium _S1209 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1210 = filling_2;
    bool _S1211 = (fcptVaryingUsed());
    uint _S1212 = _slang_select(_S1211, _S1210,4294967295U);
    filling_2 = _S1212;
    scatter_in_0 = _S1209.scatter;
    extinction_in_0 = _S1209.extinction;
    g_in_0 = _S1209.g;
    Reservoir _S1213 = chain_0;
    uint _S1214 = filling_2;
    for(;;)
    {
        bool _S1215 = (fcptVaryingUsed());
        if(_S1215)
        {
            passes_0 = _S1214 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1216 = (fcptMajorant((_S1214)));
            spread_2 = _S1216;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1196;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1185 == 1U;
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
            ended_0 = _S1181;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1202;
            width_3 = _S1203;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_8 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1217 = (&prev_0)->rough;
        if(_S1217)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1218 = stream(_S1208, 384U);
        uint tracking_0 = _S1218;
        weight_1 = throughput_3;
        glowed_0 = _S1180;
        b_8 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_2 = _S1202;
        width_3 = _S1203;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1179 = int(1);
                break;
            }
            uint _S1219 = b_8 + 320U;
            bool _S1220 = b_8 == 4294967295U;
            uint _S1221 = _slang_select(_S1220, 384U,_S1219);
            uint _S1222 = stream(_S1208, _S1221);
            Random _S1223 = pcg(_S1222);
            float _S1224 = freeFlight_0(_S1223.value, spread_2);
            if(passes_0)
            {
                float3  _S1225 = (&ray_2)->origin;
                float3  _S1226 = (&ray_2)->unit_direction;
                float _S1227 = (&hit_4)->distance;
                uint _S1228 = _slang_select(_S1220, 0U,b_8);
                uint _S1229 = (&prev_0)->lobe;
                uint _S1230 = _slang_select(_S1220, 3U,_S1229);
                float _S1231 = (fcptTrackMedium((_S1214), (_S1225), (_S1226), (_S1227), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1228), (_S1230), (_S1220)));
                geometry_density_2 = _S1231;
            }
            else
            {
                geometry_density_2 = _S1224;
            }
            bool _S1232 = !(geometry_density_2 < ((&hit_4)->distance));
            if(_S1232)
            {
                _S1179 = int(1);
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
                float3  _S1233 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1234 = sel_7->glow + _S1233;
                sel_7->glow = _S1234;
            }
            else
            {
            }
            glowed_0 = _S1180;
            uint b_10 = b_8 + 1U;
            float3  _S1235 = (&ray_2)->origin + make_float3 (geometry_density_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1235;
            float3  _S1236 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, geometry_density_2, true);
            float3  _S1237 = weight_1;
            float3  _S1238 = _slang_select(passes_0, _S1237,_S1236);
            float3  throughput_4 = throughput_2 * _S1238;
            uint _S1239 = stream(_S1208, b_10 + 320U);
            tracking_0 = _S1239;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_2 * geometry_density_2;
            float _S1240 = threshold_2 + 3.14159274101257324f;
            bool _S1241 = scatterSampled_0(replay_2, b_10, _S1196, passes_0);
            TreeSample _S1242 = TreeSample_x24init_0(_S1180, _S1180, 0.0f, 0U);
            if(_S1241)
            {
                float3  _S1243 = (&ray_2)->origin;
                float3  _S1244 = (&ray_2)->unit_direction;
                float3  _S1245 = (&ray_2)->unit_direction;
                uint _S1246 = stream(_S1208, b_10 + 64U);
                float3  _S1247 = extinction_in_0;
                float3  _S1248 = extinction_in_0;
                uint2  _S1249 = make_uint2 (_S1214);
                float3  _S1250 = (&ray_2)->unit_direction;
                uint _S1251 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                FKHit _S1252 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1253 = _S1252;
                ShadowContext _S1254 = ShadowContext_x24init_0(_S1247, _S1248, _S1249, _S1250, b_10, _S1251, false, geometry_density_2, width_6, &_S1253, false);
                ShadowContext _S1255 = _S1254;
                TreeSample _S1256 = sampleLightTree_0(_S1243, _S1244, _S1245, 0.0f, true, _S1246, &_S1255);
                light_3 = _S1256;
            }
            else
            {
                light_3 = _S1242;
            }
            float _S1257 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1258 = (fcptMaxBounces());
            bool _S1259 = b_10 < _S1258;
            if(_S1259)
            {
                is_inside_5 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_5 = false;
            }
            float _S1260 = _slang_select(is_inside_5, _S1257,0.0f);
            float3  _S1261 = throughput_4 * light_3.radiance;
            float _S1262 = powerHeuristic(light_3.density, _S1260);
            float3  _S1263 = _S1261 * make_float3 (_S1257 * _S1262);
            float3  _S1264 = _slang_select(_S1241, _S1263,_S1180);
            if(replay_2)
            {
                viewed_0 = b_10 == _S1196;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1265 = _S1185 == 2U;
                if(_S1265)
                {
                    float _S1266 = rgb_to_greyscale(_S1264);
                    passes_0 = _S1266 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1267 = Shift_x24init_0(_S1264, 1.0f);
                    _S1179 = int(0);
                    ended_0 = _S1267;
                    spread_2 = _S1240;
                    geometry_density_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_10;
                    break;
                }
                _S1179 = int(0);
                ended_0 = _S1181;
                spread_2 = _S1240;
                geometry_density_2 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_10;
                break;
            }
            bool _S1268 = !replay_2;
            if(_S1268)
            {
                Reservoir candidate_3 = _S1213;
                uint _S1269 = extractBits_0(_S1213.path, 10U, 2U);
                bool _S1270 = _S1269 == 1U;
                if(_S1270)
                {
                    float3  _S1271 = safeDivide(_S1264, _S1180);
                    (&candidate_3)->radiance = _S1271;
                }
                else
                {
                    uint _S1272 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                    uint _S1273 = insertBits_0(_S1272, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1273;
                }
                Reservoir _S1274 = withEnd(candidate_3, 0U, b_10, _S1264);
                offer(sel_7, _S1274, _S1264 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1275 = survivalProbability(throughput_4, density_2);
                uint _S1276 = stream(_S1208, b_10 + 128U);
                Random _S1277 = pcg(_S1276);
                bool _S1278 = _S1275 < (_S1277.value);
                if(_S1278)
                {
                    scatter_2 = true;
                }
                else
                {
                    uint _S1279 = (fcptMaxBounces());
                    scatter_2 = b_10 >= _S1279;
                }
                if(scatter_2)
                {
                    _S1179 = int(0);
                    ended_0 = _S1181;
                    spread_2 = _S1240;
                    geometry_density_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_10;
                    break;
                }
                float _S1280 = density_2 * _S1275;
                density_2 = _S1280;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1281 = stream(_S1208, b_10);
            float3  _S1282 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1281, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1282;
            NEEVertex _S1283 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1180, (&ray_2)->origin);
            nee_vertex_0 = _S1283;
            Vertex _S1284 = scatteredVertex_0(false);
            prev_0 = _S1284;
            float _S1285 = (&prev_0)->pdf;
            FKRay _S1286 = ray_2;
            FKHit _S1287 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1288 = (fcptTraverseInstanceBVH((_S1286), (true), (4.294967296e+09f), (false), (_S1287), (false)));
            hit_4 = _S1288;
            b_8 = b_10;
            throughput_2 = throughput_4;
            threshold_2 = _S1240;
            width_3 = width_6;
            sky_pdf_0 = _S1285;
        }
        if(_S1179 != int(1))
        {
            width_3 = geometry_density_2;
            throughput_2 = chain_throughput_0;
            b_8 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1181;
        spread_2 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1289 = b_8 == 4294967295U;
    bool _S1290 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1290)
    {
        bool _S1291 = !(&nee_vertex_0)->none;
        float _S1292 = _slang_select(_S1291, sky_pdf_0,0.0f);
        float _S1293 = escapeWeight_0(_S1292, (&ray_2)->unit_direction);
        float3  _S1294 = environment_0((&ray_2)->unit_direction, b_8, (&prev_0)->lobe);
        float3  _S1295 = throughput_2 * _S1294;
        if(replay_2)
        {
            bool _S1296 = b_8 == _S1196;
            if(_S1296)
            {
                passes_0 = _S1185 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1295 * make_float3 (_S1293) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1195)
            {
                passes_0 = _S1192;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_8 == _S1183;
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
                return Shift_x24init_0(_S1295 * make_float3 (_S1293), 1.0f);
            }
            return _S1181;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1297 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1298 = _S1297 == 1U;
        if(_S1298)
        {
            uint _S1299 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1300 = _S1299 == b_8;
            float _S1301 = _slang_select(_S1300, 1.0f,_S1293);
            float3  _S1302 = safeDivide(_S1295 * make_float3 (_S1301), _S1180);
            (&candidate_4)->radiance = _S1302;
        }
        else
        {
            bool _S1303 = (&prev_0)->rough;
            if(_S1303)
            {
                uint _S1304 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                uint _S1305 = insertBits_0(_S1304, 3U, 10U, 2U);
                uint _S1306 = insertBits_0(_S1305, (&prev_0)->lobe, 15U, 3U);
                bool _S1307 = (&prev_0)->inside;
                uint _S1308 = _slang_select(_S1307, 1U,0U);
                uint _S1309 = insertBits_0(_S1306, _S1308, 22U, 1U);
                (&candidate_4)->path = _S1309;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1310 = _S1295 * make_float3 (_S1293);
        Reservoir _S1311 = withEnd(candidate_4, 3U, b_8, _S1310);
        offer(sel_7, _S1311, _S1310 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1181;
    }
    float3  _S1312 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1312;
    bool _S1313 = (fcptVaryingUsed());
    if(_S1313)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1314 = !replay_2;
        if(_S1314)
        {
            float3  _S1315 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1316 = sel_7->glow + _S1315;
            sel_7->glow = _S1316;
        }
        float3  _S1317 = throughput_2 * weight_1;
        throughput_2 = _S1317;
    }
    else
    {
        float3  _S1318 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1319 = throughput_2 * _S1318;
        throughput_2 = _S1319;
    }
    float _S1320 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1321 = b_8 + 1U;
    b_8 = _S1321;
    layer_0 = 0U;
    width_3 = _S1320;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S1180;
    float3  reconnection_0 = _S1180;
    viewed_0 = _S1289;
    for(;;)
    {
        bool _S1322 = ((&hit_4)->is_point_light) == 1U;
        FKMedium _S1323 = Medium_x24init_0(_S1180, _S1180, 0.0f);
        BSDFMaterial _S1324 = Material_x24init_0(_S1180, _S1180, 0.0f, 0.0f, 0.0f, 0.0f, _S1180, throughput_3, 1.0f, _S1180, _S1180, 0.5f, 0.0f, 0.0f, _S1180, 0.0f, _S1180);
        FKMedium _S1325 = _S1323;
        FKSurface _S1326 = Surface_x24init_0(_S1180, _S1180, 0.0f, &_S1324, false, 0U, 1.0f, false, &_S1325, 4294967295U, _S1180);
        bool _S1327 = !_S1322;
        bool is_inside_6;
        float3  throughput_5;
        FKSurface surface_11;
        if(_S1327)
        {
            uint _S1328 = stream(_S1208, b_8);
            uint _S1329 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKSurface _S1330 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1328), (width_3), (layer_0), (b_8), (_S1329), ((&ray_2)->unit_direction)));
            bool _S1331 = !passes_0;
            FKSurface _S1332 = _S1330;
            FKSurface _S1333 = emitting_0(&_S1332, _S1331);
            uint _S1334 = stream(_S1208, b_8 + 256U);
            Random _S1335 = pcg(_S1334);
            FKSurface _S1336 = _S1333;
            FKSurface _S1337 = uncovered_0(&_S1336, _S1335.value);
            float _S1338 = facingSign(_S1337.material.transmission, _S1337.geometry_n, (&ray_2)->unit_direction);
            bool _S1339 = _S1338 < 0.0f;
            bool _S1340 = (_S1337.material.transmission) > 0.0f;
            if(_S1340)
            {
                bool _S1341 = arrivesBehind_0((&ray_2)->unit_direction, _S1337.geometry_n);
                scatter_2 = _S1341;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1342 = _S1337;
            FKSurface _S1343 = facingRay_0(&_S1342, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1344 = arrivesBehind_0((&ray_2)->unit_direction, _S1343.geometry_n);
                is_inside_6 = _S1344;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S1345 = beerLambert((&hit_4)->distance, _S1343.material.absorption);
                float3  _S1346 = throughput_2 * _S1345;
                throughput_5 = _S1346;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1347 = !_S1343.skip;
            float geometry_density_3 = geometryDensity(_S1343.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1348 = b_8 == _S1321;
            if(_S1348)
            {
                float _S1349 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1349;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1350 = geometry_density_2;
            scatter_2 = _S1347;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1350;
            surface_11 = _S1343;
            turned_1 = _S1339;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_11 = _S1326;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S1351 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1352 = surface_11;
        FKSurface _S1353 = surface_11;
        float _S1354 = dot_0(surface_11.smooth_n, - (&ray_2)->unit_direction);
        float2  _S1355 = vertexEta(_S1352.material, _S1354);
        bool _S1356;
        if(scatter_2)
        {
            bool _S1357 = neeDecision(_S1352.material, _S1354, _S1355.x, _S1355.y);
            _S1356 = _S1357;
        }
        else
        {
            _S1356 = false;
        }
        bool _S1358;
        if(passes_0)
        {
            _S1358 = true;
        }
        else
        {
            _S1358 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1358)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1356;
        }
        bool _S1359 = (fcptHairUsed());
        bool _S1360;
        if(_S1359)
        {
            float3  _S1361 = surface_11.hair;
            _S1360 = (dot_0(_S1361, _S1361)) > 0.0f;
        }
        else
        {
            _S1360 = false;
        }
        bool _S1362;
        if(_S1360)
        {
            _S1362 = true;
        }
        else
        {
            BSDFMaterial _S1363 = _S1352.material;
            bool _S1364 = isTranslucent_0(&_S1363);
            _S1362 = _S1364;
        }
        bool _S1365;
        if(_S1362)
        {
            _S1365 = true;
        }
        else
        {
            bool _S1366 = (_S1352.material.transmission) > 0.0f;
            if(_S1366)
            {
                uint _S1367 = (fcptLayers((hit_4)));
                _S1365 = _S1367 == 1U;
            }
            else
            {
                _S1365 = false;
            }
        }
        float3  emission_0;
        if(_S1322)
        {
            float3  _S1368 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1368;
        }
        else
        {
            emission_0 = _S1352.material.emissive;
        }
        float _S1369 = rgb_to_greyscale(emission_0);
        bool _S1370 = _S1369 > 0.0f;
        float3  emission_1;
        if(_S1370)
        {
            NEEVertex _S1371 = nee_vertex_0;
            FKHit _S1372 = hit_4;
            float _S1373 = emissionWeight_0(&_S1371, &_S1372, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1373);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1374;
        if(replay_2)
        {
            _S1374 = _S1185 == 1U;
        }
        else
        {
            _S1374 = false;
        }
        bool _S1375;
        if(_S1374)
        {
            _S1375 = b_8 > _S1184;
        }
        else
        {
            _S1375 = false;
        }
        bool _S1376;
        if(_S1375)
        {
            _S1376 = b_8 == _S1183;
        }
        else
        {
            _S1376 = false;
        }
        bool _S1377;
        if(_S1376)
        {
            bool _S1378 = _S1186 == 1U;
            if(_S1378)
            {
                _S1377 = true;
            }
            else
            {
                _S1377 = _S1186 == 2U;
            }
        }
        else
        {
            _S1377 = false;
        }
        if(_S1377)
        {
            bool _S1379 = _S1322 != (_S1186 == 2U);
            if(_S1379)
            {
                return _S1181;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1380 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1381 = _S1380 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1382 = insertBits_0(0U, b_8, 5U, 5U);
        uint _S1383 = insertBits_0(_S1382, 1U, 10U, 2U);
        uint _S1384 = insertBits_0(_S1383, (&prev_0)->lobe, 15U, 3U);
        bool _S1385 = (&prev_0)->inside;
        uint _S1386 = _slang_select(_S1385, 1U,0U);
        uint _S1387 = insertBits_0(_S1384, _S1386, 22U, 1U);
        (&here_0)->path = _S1387;
        float _S1388 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1388;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1389;
        if(replay_2)
        {
            _S1389 = _S1185 == 1U;
        }
        else
        {
            _S1389 = false;
        }
        bool _S1390;
        if(_S1389)
        {
            _S1390 = b_8 == _S1184;
        }
        else
        {
            _S1390 = false;
        }
        bool _S1391 = b_8 == _S1196;
        bool _S1392;
        if(_S1391)
        {
            bool _S1393 = !scatter_2;
            if(_S1393)
            {
                _S1392 = true;
            }
            else
            {
                bool _S1394 = _S1185 != 1U;
                if(_S1394)
                {
                    _S1392 = _S1185 != 3U;
                }
                else
                {
                    _S1392 = false;
                }
            }
        }
        else
        {
            _S1392 = false;
        }
        bool _S1395;
        if(_S1392)
        {
            _S1395 = _S1185 == 2U;
        }
        else
        {
            _S1395 = false;
        }
        bool _S1396;
        if(_S1395)
        {
            _S1396 = !_S1351;
        }
        else
        {
            _S1396 = false;
        }
        bool _S1397;
        if(_S1396)
        {
            _S1397 = _S1186 != 4U;
        }
        else
        {
            _S1397 = false;
        }
        bool _S1398 = _S1184 == _S1183;
        bool _S1399;
        if(_S1398)
        {
            _S1399 = _S1186 == 0U;
        }
        else
        {
            _S1399 = false;
        }
        bool _S1400;
        if(_S1399)
        {
            _S1400 = ((&hit_4)->instance_index) == (_S1197.instance_index);
        }
        else
        {
            _S1400 = false;
        }
        bool _S1401;
        if(_S1400)
        {
            _S1401 = ((&hit_4)->triangle_index) == (_S1197.triangle_index);
        }
        else
        {
            _S1401 = false;
        }
        bool _S1402;
        if(_S1401)
        {
            _S1402 = _S1351;
        }
        else
        {
            _S1402 = false;
        }
        bool _S1403 = _slang_select(_S1390, _S1402,_S1397);
        bool _S1404;
        if(nee_0)
        {
            _S1404 = _slang_select(replay_2, _S1403,scatter_2);
        }
        else
        {
            _S1404 = false;
        }
        TreeSample _S1405 = TreeSample_x24init_0(_S1180, _S1180, 0.0f, 0U);
        uint2  _S1406 = make_uint2 (0U);
        float2  _S1407 = make_float2 (0.0f);
        FKHit _S1408 = Hit_x24init_0(_S1407, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1409 = _S1408;
        ShadowContext _S1410 = ShadowContext_x24init_0(_S1180, _S1180, _S1406, _S1180, 0U, 0U, false, 0.0f, 0.0f, &_S1409, false);
        ShadowContext context_5;
        if(nee_0)
        {
            uint _S1411 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKMedium _S1412 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1413 = surface_11;
            FKHit _S1414 = hit_4;
            FKMedium _S1415 = _S1412;
            ShadowContext _S1416 = shadowContext_0(&_S1413, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_8, _S1411, (&hit_4)->distance, width_3, &_S1414, _S1360, &_S1415);
            context_5 = _S1416;
        }
        else
        {
            context_5 = _S1410;
        }
        float3  throughput_6;
        float3  lit_0;
        if(_S1404)
        {
            float3  _S1417 = (&ray_2)->origin;
            if(_S1360)
            {
                throughput_6 = _S1180;
            }
            else
            {
                throughput_6 = _S1353.smooth_n;
            }
            FKSurface _S1418 = surface_11;
            uint _S1419 = stream(_S1208, b_8 + 64U);
            ShadowContext _S1420 = context_5;
            TreeSample _S1421 = sampleLightTree_0(_S1417, throughput_6, surface_11.geometry_n, surface_11.geometry_offset, _S1365, _S1419, &_S1420);
            bool _S1422 = any_1((_S1421.radiance) != _S1180);
            if(_S1422)
            {
                if(_S1360)
                {
                    uint _S1423 = (fcptMaxBounces());
                    bool _S1424 = b_8 < _S1423;
                    FKSurface _S1425 = surface_11;
                    TreeSample _S1426 = _S1421;
                    float3  _S1427 = hairLight_0(&_S1425, (&ray_2)->unit_direction, &_S1426, _S1424);
                    lit_0 = _S1427;
                }
                else
                {
                    float _S1428 = _S1355.x;
                    float _S1429 = _S1355.y;
                    uint _S1430 = (fcptMaxBounces());
                    bool _S1431 = b_8 < _S1430;
                    TreeSample _S1432 = _S1421;
                    BSDFMaterial _S1433 = _S1352.material;
                    float3  _S1434 = lightBSDF_0((&ray_2)->unit_direction, &_S1432, _S1353.smooth_n, _S1418.geometry_n, &_S1433, _S1428, _S1429, _S1431, surface_11.random_state);
                    lit_0 = _S1434;
                }
            }
            else
            {
                lit_0 = _S1180;
            }
            light_3 = _S1421;
        }
        else
        {
            light_3 = _S1405;
            lit_0 = _S1180;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1435;
        bool _S1436;
        float density_4;
        if(_S1390)
        {
            bool _S1437 = ((&hit_4)->instance_index) != (_S1197.instance_index);
            if(_S1437)
            {
                viewed_1 = true;
            }
            else
            {
                viewed_1 = ((&hit_4)->triangle_index) != (_S1197.triangle_index);
            }
            if(viewed_1)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = !_S1351;
            }
            if(refracted_4)
            {
                return _S1181;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1398)
            {
                wrong_side_0 = _S1186 == 1U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1398)
            {
                _S1435 = _S1186 == 0U;
            }
            else
            {
                _S1435 = false;
            }
            if(_S1435)
            {
                bool _S1438 = !nee_0;
                if(_S1438)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1439 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1439 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1181;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1398)
            {
                _S1436 = _S1186 == 4U;
            }
            else
            {
                _S1436 = false;
            }
            if(_S1436)
            {
                bool _S1440 = !nee_0;
                if(_S1440)
                {
                    return _S1181;
                }
                float _S1441 = environmentPdf_0(r_8->dir);
                float3  _S1442 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_11, _S1355, is_inside_6, _S1441, surface_11.random_state);
                return Shift_x24init_0(throughput_7 * _S1442 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1443 = extractBits_0(_S1182, 21U, 1U);
            bool _S1444 = nee_0 != (_S1443 == 1U);
            if(_S1444)
            {
                return _S1181;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1391;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1445 = !scatter_2;
                if(_S1445)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1446 = _S1185 != 1U;
                    if(_S1446)
                    {
                        refracted_4 = _S1185 != 3U;
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
                bool _S1447 = _S1185 == 2U;
                if(_S1447)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1351;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1186 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1360)
                    {
                        return _S1181;
                    }
                    uint _S1448 = stream(_S1208, b_8 + 448U);
                    FKRay _S1449 = ray_2;
                    FKSurface _S1450 = surface_11;
                    ShadowContext _S1451 = context_5;
                    SkySample _S1452 = sampleSky_0(&_S1449, &_S1450, _S1355, is_inside_6, _S1448, surface_11.random_state, &_S1451);
                    return Shift_x24init_0(throughput_5 * _S1452.color, 1.0f);
                }
                if(_S1447)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1351;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1453 = rgb_to_greyscale(light_3.radiance);
                    bool _S1454 = !(_S1453 > 0.0f);
                    if(_S1454)
                    {
                        return _S1181;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S1195)
                {
                    passes_0 = _S1186 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1322;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S1195)
                {
                    passes_0 = _S1186 == 1U;
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
                    passes_0 = !_S1351;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S1181;
            }
            else
            {
                bool _S1455 = !replay_2;
                if(_S1455)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1456 = b_8 > 0U;
                    if(_S1456)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1381)
                        {
                            float3  _S1457 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1457;
                        }
                        else
                        {
                            if(_S1351)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1458 = throughput_5 * emission_1;
                        Reservoir _S1459 = withEnd(candidate_5, 1U, b_8, _S1458);
                        offer(sel_7, _S1459, _S1458 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1460 = throughput_5 * emission_1;
                        float3  _S1461 = sel_7->glow + _S1460;
                        sel_7->glow = _S1461;
                    }
                    if(nee_0)
                    {
                        float3  _S1462 = throughput_5 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1381)
                        {
                            float3  _S1463 = safeDivide(_S1462, chain_throughput_0);
                            (&candidate_6)->radiance = _S1463;
                        }
                        else
                        {
                            if(_S1351)
                            {
                                candidate_6 = here_0;
                                uint _S1464 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1464;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1465 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                                uint _S1466 = insertBits_0(_S1465, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1466;
                            }
                        }
                        Reservoir _S1467 = withEnd(candidate_6, 0U, b_8, _S1462);
                        offer(sel_7, _S1467, _S1462 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1360)
                        {
                            _S1435 = false;
                        }
                        else
                        {
                            bool _S1468 = environmentMapped_0();
                            _S1435 = _S1468;
                        }
                    }
                    else
                    {
                        _S1435 = false;
                    }
                    if(_S1435)
                    {
                        uint _S1469 = (fcptMaxBounces());
                        _S1436 = b_8 < _S1469;
                    }
                    else
                    {
                        _S1436 = false;
                    }
                    if(_S1436)
                    {
                        uint _S1470 = stream(_S1208, b_8 + 448U);
                        FKRay _S1471 = ray_2;
                        FKSurface _S1472 = surface_11;
                        ShadowContext _S1473 = context_5;
                        SkySample _S1474 = sampleSky_0(&_S1471, &_S1472, _S1355, is_inside_6, _S1470, surface_11.random_state, &_S1473);
                        float3  _S1475 = throughput_5 * _S1474.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1381)
                        {
                            float3  _S1476 = safeDivide(_S1475, chain_throughput_0);
                            (&candidate_7)->radiance = _S1476;
                        }
                        else
                        {
                            if(_S1351)
                            {
                                candidate_7 = here_0;
                                uint _S1477 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1477;
                                (&candidate_7)->dir = _S1474.dir;
                                (&candidate_7)->radiance = _S1474.radiance;
                            }
                            else
                            {
                                uint _S1478 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                                uint _S1479 = insertBits_0(_S1478, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1479;
                            }
                        }
                        Reservoir _S1480 = withEnd(candidate_7, 4U, b_8, _S1475);
                        offer(sel_7, _S1480, _S1475 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1481;
        bool _S1482;
        bool _S1483;
        bool straight_0;
        bool _S1484;
        bool _S1485;
        bool _S1486;
        bool _S1487;
        bool _S1488;
        bool _S1489;
        bool _S1490;
        bool _S1491;
        bool _S1492;
        bool _S1493;
        bool _S1494;
        bool _S1495;
        float density_6;
        float sky_pdf_2;
        float spread_5;
        uint b_11;
        float3  throughput_8;
        float3  throughput_9;
        float3  throughput_10;
        if(scatter_2)
        {
            if(replay_2)
            {
                viewed_1 = _S1391;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1496 = extractBits_0(_S1182, 15U, 3U);
            uint _S1497 = extractBits_0(_S1182, 18U, 3U);
            uint _S1498 = _slang_select(_S1390, _S1497,_S1496);
            float3  _S1499 = r_8->dir;
            bool refracted_5 = _S1498 == 1U;
            SampleBSDF _S1500 = SampleBSDF_x24init_0(_S1180, _S1180, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_8 = _S1500;
            float3  reconnection_1;
            SampleBSDF _S1501;
            if(viewed_1)
            {
                uint _S1502 = extractBits_0(_S1182, 22U, 1U);
                bool _S1503 = is_inside_6 != (_S1502 == 1U);
                if(_S1503)
                {
                    return _S1181;
                }
                bool _S1504 = _S1185 == 1U;
                if(_S1504)
                {
                    float3  _S1505 = (fcptHitPosition((_S1197)));
                    throughput_8 = _S1505;
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
                    BSDFMaterial _S1506 = _S1352.material;
                    bool _S1507 = isTranslucent_0(&_S1506);
                    if(_S1507)
                    {
                        refracted_4 = _S1498 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1508 = throughput_8 - (&ray_2)->origin;
                        float3  _S1509 = _slang_select(_S1504, _S1508,_S1499);
                        wrong_side_0 = (dot_0(_S1353.smooth_n, _S1509) * _S1354) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1504)
                {
                    float3  _S1510 = (&ray_2)->origin;
                    FKSurface _S1511 = surface_11;
                    float3  _S1512 = - _S1353.smooth_n;
                    bool _S1513 = is_inside_6 != refracted_4;
                    float3  _S1514 = _slang_select(_S1513, _S1512,_S1353.smooth_n);
                    float3  _S1515 = throughput_8 - (_S1510 + make_float3 (_S1511.geometry_offset) * _S1514);
                    float3  _S1516 = ((((_S1515)) * make_float3(rnorm3df(((_S1515)).x, ((_S1515)).y, ((_S1515)).z))));
                    reconnection_1 = _S1516;
                }
                else
                {
                    reconnection_1 = _S1499;
                }
                if(_S1360)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1517 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_11.geometry_n);
                    wrong_side_0 = _S1517;
                }
                if(wrong_side_0)
                {
                    return _S1181;
                }
                float3  _S1518 = throughput_8;
                throughput_8 = reconnection_1;
                b_11 = _S1498;
                wrong_side_0 = false;
                reconnection_1 = _S1518;
            }
            else
            {
                bool _S1519 = !_S1390;
                if(_S1519)
                {
                    SampleBSDF bsdf_sampled_0;
                    if(_S1360)
                    {
                        SampleBSDF _S1520 = (fcptSampleHair((surface_11.hair), (_S1352.material.albedo), (_S1352.material.specular_tint), ((&ray_2)->unit_direction), (surface_11.random_state)));
                        _S1501 = _S1520;
                    }
                    else
                    {
                        SampleBSDF _S1521 = sampleBSDF((&ray_2)->unit_direction, _S1353.smooth_n, _S1352.material, _S1355.x, _S1355.y, surface_11.random_state, _S1407);
                        _S1501 = _S1521;
                    }
                    bsdf_sampled_0 = _S1501;
                    if(_S1360)
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
                            return _S1181;
                        }
                        break;
                    }
                    if(_S1360)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1522 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_11.geometry_n);
                        wrong_side_0 = _S1522;
                    }
                    if(wrong_side_0)
                    {
                        _S1435 = (_S1352.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1435 = false;
                    }
                    if(_S1435)
                    {
                        SampleBSDF _S1523 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n, _S1352.material, _S1355.x, _S1355.y, (&bsdf_sampled_0)->random_state, _S1407);
                        (&bsdf_sampled_0)->unit_direction = _S1523.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1523.refracted;
                        (&bsdf_sampled_0)->throughput = _S1523.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1524 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n)) * surface_11.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1524;
                        }
                    }
                    uint _S1525 = (&bsdf_sampled_0)->lobe;
                    float3  _S1526 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1527 = (&bsdf_sampled_0)->refracted;
                    lobe_8 = bsdf_sampled_0;
                    float _S1528 = (&bsdf_sampled_0)->pdf;
                    float _S1529 = _slang_select(wrong_side_0, 0.0f,_S1528);
                    (&lobe_8)->pdf = _S1529;
                    throughput_8 = _S1526;
                    b_11 = _S1525;
                    refracted_4 = _S1527;
                }
                else
                {
                    throughput_8 = _S1499;
                    b_11 = _S1498;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1435 = true;
            }
            else
            {
                _S1435 = _S1390;
            }
            if(_S1435)
            {
                if(_S1360)
                {
                    SampleBSDF _S1530 = (fcptConnectHair((surface_11.hair), (_S1352.material.albedo), (_S1352.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    _S1501 = _S1530;
                }
                else
                {
                    SampleBSDF _S1531 = connectBSDF((&ray_2)->unit_direction, throughput_8, _S1353.smooth_n, _S1352.material, _S1355.x, _S1355.y, b_11, surface_11.random_state);
                    _S1501 = _S1531;
                }
                lobe_8 = _S1501;
            }
            bool _S1532 = b_11 == 0U;
            if(_S1532)
            {
                _S1436 = true;
            }
            else
            {
                _S1436 = b_11 == 4U;
            }
            if(_S1436)
            {
                _S1481 = true;
            }
            else
            {
                _S1481 = b_11 == 6U;
            }
            if(_S1360)
            {
                _S1482 = false;
            }
            else
            {
                bool _S1533 = !_S1481;
                if(_S1533)
                {
                    bool _S1534 = (_S1352.material.roughness) == 0.0f;
                    if(_S1534)
                    {
                        _S1482 = true;
                    }
                    else
                    {
                        bool _S1535 = b_11 == 1U;
                        if(_S1535)
                        {
                            _S1482 = (_S1355.x) == (_S1355.y);
                        }
                        else
                        {
                            _S1482 = false;
                        }
                    }
                }
                else
                {
                    _S1482 = false;
                }
            }
            bool _S1536 = !_S1360;
            if(_S1536)
            {
                _S1483 = b_11 == 1U;
            }
            else
            {
                _S1483 = false;
            }
            if(_S1483)
            {
                straight_0 = (_S1352.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1484 = _S1536;
            }
            else
            {
                _S1484 = false;
            }
            if(_S1484)
            {
                _S1485 = b_11 == 1U;
            }
            else
            {
                _S1485 = false;
            }
            if(_S1485)
            {
                _S1486 = (_S1355.x) == (_S1355.y);
            }
            else
            {
                _S1486 = false;
            }
            BSDFMaterial _S1537 = _S1352.material;
            bool _S1538 = isTranslucent_0(&_S1537);
            if(_S1538)
            {
                _S1487 = _S1532;
            }
            else
            {
                _S1487 = false;
            }
            if(_S1487)
            {
                _S1488 = (dot_0(throughput_8, surface_11.geometry_n)) < 0.0f;
            }
            else
            {
                _S1488 = false;
            }
            if(nee_0)
            {
                _S1489 = !_S1482;
            }
            else
            {
                _S1489 = false;
            }
            if(_S1489)
            {
                _S1490 = !wrong_side_0;
            }
            else
            {
                _S1490 = false;
            }
            if(_S1490)
            {
                float _S1539 = (&lobe_8)->pdf;
                float3  _S1540 = (&ray_2)->origin;
                float3  _S1541 = _slang_select(_S1365, _S1180,_S1353.smooth_n);
                float3  _S1542 = (&ray_2)->origin;
                FKSurface _S1543 = surface_11;
                float3  _S1544 = - _S1353.smooth_n;
                float3  _S1545 = _slang_select(_S1488, _S1544,_S1353.smooth_n);
                NEEVertex _S1546 = NEEVertex_x24init_0(false, _S1539, _S1540, _S1541, _S1542 + make_float3 (_S1543.geometry_offset) * _S1545);
                nee_vertex_0 = _S1546;
            }
            else
            {
                if(_S1360)
                {
                    _S1491 = true;
                }
                else
                {
                    bool _S1547 = b_11 != 1U;
                    if(_S1547)
                    {
                        _S1491 = true;
                    }
                    else
                    {
                        _S1491 = (_S1355.x) != (_S1355.y);
                    }
                }
                if(_S1491)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1548 = withinInverseFootprint((&lobe_8)->pdf, _S1481, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1549 = roughLobe((&lobe_8)->pdf, _S1481, _S1352.material.roughness);
            if(_S1390)
            {
                bool _S1550 = !_S1548;
                if(_S1550)
                {
                    return _S1181;
                }
                bool _S1551 = _S1186 != 1U;
                if(_S1551)
                {
                    _S1491 = _S1186 != 2U;
                }
                else
                {
                    _S1491 = false;
                }
                if(_S1491)
                {
                    float _S1552 = (&lobe_8)->pdf;
                    float _S1553 = _slang_select(nee_0, _S1552,0.0f);
                    float _S1554 = escapeWeight_0(_S1553, _S1499);
                    if(_S1398)
                    {
                        passes_0 = _S1192;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1555 = _slang_select(passes_0, _S1554,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_8)->throughput * make_float3 ((&lobe_8)->pdf)) * r_8->radiance * make_float3 (_S1555) / make_float3 (r_8->jac), density_4 * (&lobe_8)->pdf / r_8->jac);
                }
                float3  _S1556 = throughput_6 * make_float3 ((&lobe_8)->pdf);
                float _S1557 = density_4 * (&lobe_8)->pdf;
                throughput_9 = _S1556;
                density_6 = _S1557;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1558 = (fcptLayers((hit_4)));
            bool _S1559 = b_11 == 1U;
            bool _S1560 = passesLayer_0(_S1558, _S1559, passes_0);
            if(viewed_1)
            {
                _S1491 = _S1560;
            }
            else
            {
                _S1491 = false;
            }
            if(_S1491)
            {
                return _S1181;
            }
            if(replay_2)
            {
                _S1492 = b_8 <= _S1196;
            }
            else
            {
                _S1492 = false;
            }
            if(_S1492)
            {
                _S1493 = _S1351;
            }
            else
            {
                _S1493 = false;
            }
            if(_S1493)
            {
                _S1494 = _S1548;
            }
            else
            {
                _S1494 = false;
            }
            if(_S1494)
            {
                _S1495 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1495 = !_S1549;
                }
                else
                {
                    _S1495 = false;
                }
            }
            if(_S1495)
            {
                return _S1181;
            }
            if(viewed_1)
            {
                float3  _S1561 = throughput_9 * ((&lobe_8)->throughput * make_float3 ((&lobe_8)->pdf));
                float _S1562 = (&lobe_8)->pdf;
                throughput_10 = _S1561;
                sky_pdf_2 = _S1562;
            }
            else
            {
                float3  _S1563 = throughput_9 * max_0((&lobe_8)->throughput, _S1180);
                throughput_10 = _S1563;
                sky_pdf_2 = density_6;
            }
            bool _S1564 = !replay_2;
            bool _S1565;
            if(_S1564)
            {
                _S1565 = !_S1381;
            }
            else
            {
                _S1565 = false;
            }
            bool _S1566;
            if(_S1565)
            {
                _S1566 = _S1351;
            }
            else
            {
                _S1566 = false;
            }
            bool _S1567;
            if(_S1566)
            {
                _S1567 = _S1548;
            }
            else
            {
                _S1567 = false;
            }
            float3  chain_throughput_1;
            if(_S1567)
            {
                chain_0 = here_0;
                uint _S1568 = insertBits_0((&chain_0)->path, b_11, 18U, 3U);
                uint _S1569 = _slang_select(nee_0, 1U,0U);
                uint _S1570 = insertBits_0(_S1568, _S1569, 21U, 1U);
                (&chain_0)->path = _S1570;
                float _S1571 = (&chain_0)->jac * (&lobe_8)->pdf;
                (&chain_0)->jac = _S1571;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1572 = surface_11;
            Vertex _S1573 = Vertex_x24init_0(_S1549, b_11, (&lobe_8)->pdf, (F32_abs((dot_0(surface_11.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1573;
            float _S1574 = (&lobe_8)->pdf;
            bool _S1575;
            if(_S1559)
            {
                _S1575 = (_S1355.x) == (_S1355.y);
            }
            else
            {
                _S1575 = false;
            }
            float sky_pdf_3 = _slang_select(_S1575, sky_pdf_0,_S1574);
            float _S1576 = _slang_select(_S1360, 0.0f,sky_pdf_3);
            float _S1577 = widened_0(spread_2, (&lobe_8)->pdf, _S1482);
            bool _S1578;
            if(refracted_4)
            {
                _S1578 = !_S1488;
            }
            else
            {
                _S1578 = false;
            }
            bool is_inside_7;
            if(_S1578)
            {
                bool _S1579 = !is_inside_6;
                is_inside_7 = _S1579;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1580 = surface_11;
            bool _S1581 = boundsVolume_0(&_S1580);
            bool _S1582;
            if(_S1581)
            {
                _S1582 = !_S1560;
            }
            else
            {
                _S1582 = false;
            }
            if(_S1582)
            {
                FKSurface faced_2 = surface_11;
                float3  _S1583 = - _S1572.geometry_n;
                float3  _S1584 = _slang_select(turned_1, _S1583,_S1572.geometry_n);
                (&faced_2)->geometry_n = _S1584;
                FKMedium _S1585 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1586 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1587 = faced_2;
                FKMedium _S1588 = _S1585;
                FKMedium _S1589 = _S1586;
                MediumSides _S1590 = mediumSides_0(&_S1587, &_S1588, filling_2, (&ray_2)->unit_direction, &_S1589);
                bool _S1591 = leavesInFront_0((&faced_2)->geometry_n, throughput_8, _S1572.geometry_n);
                float3  _S1592 = _slang_select(_S1591, _S1590.front.scatter,_S1590.behind.scatter);
                scatter_in_0 = _S1592;
                float3  _S1593 = _slang_select(_S1591, _S1590.front.extinction,_S1590.behind.extinction);
                extinction_in_0 = _S1593;
                float _S1594 = _slang_select(_S1591, _S1590.front.g,_S1590.behind.g);
                g_in_0 = _S1594;
                uint _S1595 = _S1590.fillings.x;
                uint _S1596 = _S1590.fillings.y;
                uint _S1597 = _slang_select(_S1591, _S1596,_S1595);
                bool _S1598 = (fcptVaryingUsed());
                uint _S1599 = _slang_select(_S1598, _S1597,4294967295U);
                filling_2 = _S1599;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1600 = !_S1560;
            if(_S1600)
            {
                FKSurface _S1601 = surface_11;
                float _S1602 = _slang_select(straight_0, 0.0f,_S1601.geometry_offset);
                float3  _S1603 = - _S1353.smooth_n;
                bool _S1604 = is_inside_7 != _S1488;
                float3  _S1605 = _slang_select(_S1604, _S1603,_S1353.smooth_n);
                float3  _S1606 = (&ray_2)->origin + make_float3 (_S1602) * _S1605;
                (&ray_2)->origin = _S1606;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1560;
            viewed_1 = _S1486;
            sky_pdf_2 = _S1576;
            spread_5 = _S1577;
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
            spread_5 = spread_2;
            straight_0 = false;
            is_inside_5 = is_inside_6;
        }
        bool _S1607 = !replay_2;
        float density_7;
        if(_S1607)
        {
            if(_S1322)
            {
                float3  _S1608 = throughput_9 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1609 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1610 = _S1609 == 1U;
                if(_S1610)
                {
                    float3  _S1611 = safeDivide(_S1608, chain_throughput_0);
                    (&candidate_8)->radiance = _S1611;
                }
                Reservoir _S1612 = withEnd(candidate_8, 2U, b_8, _S1608);
                offer(sel_7, _S1612, _S1608 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1322)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1613 = survivalProbability(throughput_9, density_6);
                density_7 = _S1613;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1614 = stream(_S1208, b_8 + 128U);
            Random _S1615 = pcg(_S1614);
            bool _S1616 = density_7 < (_S1615.value);
            if(_S1616)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1617 = (fcptMaxBounces());
                wrong_side_0 = b_8 >= _S1617;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1618 = density_6 * density_7;
            density_7 = _S1618;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1619 = layer_0 ^ 1U;
        uint _S1620 = _slang_select(passes_0, _S1619,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_4)->distance = 0.0f;
            b_11 = b_8;
            viewed_0 = viewed_1;
            throughput_2 = throughput_9;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_2 = spread_5;
            uint _S1621 = b_11 + 1U;
            b_8 = _S1621;
            layer_0 = _S1620;
            continue;
        }
        FKRay _S1622 = ray_2;
        float _S1623 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1391;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1185 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1624 = _slang_select(wrong_side_0, _S1623,4.294967296e+09f);
        bool _S1625 = !_S1360;
        if(straight_0)
        {
            _S1435 = true;
        }
        else
        {
            _S1435 = _S1360;
        }
        FKHit _S1626;
        if(_S1435)
        {
            _S1626 = hit_4;
        }
        else
        {
            _S1626 = _S1408;
        }
        FKHit _S1627 = (fcptTraverseInstanceBVH((_S1622), (_S1327), (_S1624), (_S1625), (_S1626), (viewed_1)));
        hit_4 = _S1627;
        if(replay_2)
        {
            _S1436 = _S1391;
        }
        else
        {
            _S1436 = false;
        }
        if(_S1436)
        {
            _S1481 = _S1185 == 1U;
        }
        else
        {
            _S1481 = false;
        }
        if(_S1481)
        {
            _S1482 = ((&hit_4)->instance_index) == (_S1197.instance_index);
        }
        else
        {
            _S1482 = false;
        }
        if(_S1482)
        {
            _S1483 = ((&hit_4)->triangle_index) == (_S1197.triangle_index);
        }
        else
        {
            _S1483 = false;
        }
        if(_S1483)
        {
            (&hit_4)->uv = _S1197.uv;
            float _S1628 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1628;
        }
        if(replay_2)
        {
            _S1484 = _S1391;
        }
        else
        {
            _S1484 = false;
        }
        if(_S1484)
        {
            _S1485 = _S1185 == 3U;
        }
        else
        {
            _S1485 = false;
        }
        if(_S1485)
        {
            _S1486 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1486 = false;
        }
        if(_S1486)
        {
            return _S1181;
        }
        Reservoir _S1629 = chain_0;
        uint _S1630 = filling_2;
        for(;;)
        {
            bool _S1631 = (fcptVaryingUsed());
            if(_S1631)
            {
                _S1487 = _S1630 != 4294967295U;
            }
            else
            {
                _S1487 = false;
            }
            float _S1632;
            if(_S1487)
            {
                float _S1633 = (fcptMajorant((_S1630)));
                _S1632 = _S1633;
            }
            else
            {
                _S1632 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1488 = _S1391;
            }
            else
            {
                _S1488 = false;
            }
            if(_S1488)
            {
                _S1489 = _S1185 == 1U;
            }
            else
            {
                _S1489 = false;
            }
            if(_S1489)
            {
                _S1490 = _S1632 > 0.0f;
            }
            else
            {
                _S1490 = false;
            }
            if(_S1490)
            {
                ended_0 = _S1181;
                sky_pdf_1 = sky_pdf_2;
                spread_3 = spread_5;
                width_4 = width_3;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_11 = b_8;
                _S1491 = true;
                break;
            }
            bool _S1634 = (&prev_0)->rough;
            if(_S1634)
            {
                _S1491 = !(_S1632 > 0.0f);
            }
            else
            {
                _S1491 = false;
            }
            (&prev_0)->rough = _S1491;
            uint _S1635 = b_8 + 320U;
            bool _S1636 = b_8 == 4294967295U;
            uint _S1637 = _slang_select(_S1636, 384U,_S1635);
            uint _S1638 = stream(_S1208, _S1637);
            uint tracking_1 = _S1638;
            weight_1 = throughput_3;
            glowed_0 = _S1180;
            b_11 = b_8;
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
                    _S1179 = int(2);
                    break;
                }
                uint _S1639 = b_11 + 320U;
                bool _S1640 = b_11 == 4294967295U;
                uint _S1641 = _slang_select(_S1640, 384U,_S1639);
                uint _S1642 = stream(_S1208, _S1641);
                Random _S1643 = pcg(_S1642);
                float _S1644 = freeFlight_0(_S1643.value, _S1632);
                if(_S1487)
                {
                    float3  _S1645 = (&ray_2)->origin;
                    float3  _S1646 = (&ray_2)->unit_direction;
                    float _S1647 = (&hit_4)->distance;
                    uint _S1648 = _slang_select(_S1640, 0U,b_11);
                    uint _S1649 = (&prev_0)->lobe;
                    uint _S1650 = _slang_select(_S1640, 3U,_S1649);
                    float _S1651 = (fcptTrackMedium((_S1630), (_S1645), (_S1646), (_S1647), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1648), (_S1650), (_S1640)));
                    spread_4 = _S1651;
                }
                else
                {
                    spread_4 = _S1644;
                }
                bool _S1652 = !(spread_4 < ((&hit_4)->distance));
                if(_S1652)
                {
                    _S1179 = int(2);
                    break;
                }
                if(_S1487)
                {
                    _S1492 = _S1607;
                }
                else
                {
                    _S1492 = false;
                }
                if(_S1492)
                {
                    float3  _S1653 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1654 = sel_7->glow + _S1653;
                    sel_7->glow = _S1654;
                }
                else
                {
                }
                glowed_0 = _S1180;
                uint b_12 = b_11 + 1U;
                float3  _S1655 = (&ray_2)->origin + make_float3 (spread_4) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1655;
                float3  _S1656 = flightWeight_0(scatter_in_0, extinction_in_0, _S1632, spread_4, true);
                float3  _S1657 = weight_1;
                float3  _S1658 = _slang_select(_S1487, _S1657,_S1656);
                float3  throughput_11 = throughput_10 * _S1658;
                uint _S1659 = stream(_S1208, b_12 + 320U);
                tracking_1 = _S1659;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_3 * spread_4;
                float _S1660 = spread_3 + 3.14159274101257324f;
                bool _S1661 = scatterSampled_0(replay_2, b_12, _S1196, _S1487);
                TreeSample light_4;
                if(_S1661)
                {
                    float3  _S1662 = (&ray_2)->origin;
                    float3  _S1663 = (&ray_2)->unit_direction;
                    float3  _S1664 = (&ray_2)->unit_direction;
                    uint _S1665 = stream(_S1208, b_12 + 64U);
                    float3  _S1666 = extinction_in_0;
                    float3  _S1667 = extinction_in_0;
                    uint2  _S1668 = make_uint2 (_S1630);
                    float3  _S1669 = (&ray_2)->unit_direction;
                    uint _S1670 = arrivalLobe_0(b_12, (&prev_0)->lobe);
                    FKHit _S1671 = _S1408;
                    ShadowContext _S1672 = ShadowContext_x24init_0(_S1666, _S1667, _S1668, _S1669, b_12, _S1670, false, spread_4, width_7, &_S1671, false);
                    ShadowContext _S1673 = _S1672;
                    TreeSample _S1674 = sampleLightTree_0(_S1662, _S1663, _S1664, 0.0f, true, _S1665, &_S1673);
                    light_4 = _S1674;
                }
                else
                {
                    light_4 = _S1405;
                }
                float _S1675 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1676 = (fcptMaxBounces());
                bool _S1677 = b_12 < _S1676;
                if(_S1677)
                {
                    _S1493 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1493 = false;
                }
                float _S1678 = _slang_select(_S1493, _S1675,0.0f);
                float3  _S1679 = throughput_11 * light_4.radiance;
                float _S1680 = powerHeuristic(light_4.density, _S1678);
                float3  _S1681 = _S1679 * make_float3 (_S1675 * _S1680);
                float3  _S1682 = _slang_select(_S1661, _S1681,_S1180);
                if(replay_2)
                {
                    _S1494 = b_12 == _S1196;
                }
                else
                {
                    _S1494 = false;
                }
                if(_S1494)
                {
                    bool _S1683 = _S1185 == 2U;
                    if(_S1683)
                    {
                        float _S1684 = rgb_to_greyscale(_S1682);
                        _S1495 = _S1684 > 0.0f;
                    }
                    else
                    {
                        _S1495 = false;
                    }
                    if(_S1495)
                    {
                        Shift _S1685 = Shift_x24init_0(_S1682, 1.0f);
                        _S1179 = int(1);
                        ended_0 = _S1685;
                        spread_4 = _S1660;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_9 = b_12;
                        break;
                    }
                    _S1179 = int(1);
                    ended_0 = _S1181;
                    spread_4 = _S1660;
                    width_5 = width_7;
                    throughput_8 = throughput_11;
                    b_9 = b_12;
                    break;
                }
                if(_S1607)
                {
                    Reservoir candidate_9 = _S1629;
                    uint _S1686 = extractBits_0(_S1629.path, 10U, 2U);
                    bool _S1687 = _S1686 == 1U;
                    if(_S1687)
                    {
                        float3  _S1688 = safeDivide(_S1682, chain_throughput_0);
                        (&candidate_9)->radiance = _S1688;
                    }
                    else
                    {
                        uint _S1689 = insertBits_0(0U, b_12 + 1U, 5U, 5U);
                        uint _S1690 = insertBits_0(_S1689, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1690;
                    }
                    Reservoir _S1691 = withEnd(candidate_9, 0U, b_12, _S1682);
                    offer(sel_7, _S1691, _S1682 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1692 = survivalProbability(throughput_11, density_3);
                    uint _S1693 = stream(_S1208, b_12 + 128U);
                    Random _S1694 = pcg(_S1693);
                    bool _S1695 = _S1692 < (_S1694.value);
                    if(_S1695)
                    {
                        _S1495 = true;
                    }
                    else
                    {
                        uint _S1696 = (fcptMaxBounces());
                        _S1495 = b_12 >= _S1696;
                    }
                    if(_S1495)
                    {
                        _S1179 = int(1);
                        ended_0 = _S1181;
                        spread_4 = _S1660;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_9 = b_12;
                        break;
                    }
                    float _S1697 = density_3 * _S1692;
                    density_3 = _S1697;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1698 = stream(_S1208, b_12);
                float3  _S1699 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1698, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1699;
                NEEVertex _S1700 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1180, (&ray_2)->origin);
                nee_vertex_0 = _S1700;
                Vertex _S1701 = scatteredVertex_0(is_inside_5);
                prev_0 = _S1701;
                float _S1702 = (&prev_0)->pdf;
                FKRay _S1703 = ray_2;
                FKHit _S1704 = (fcptTraverseInstanceBVH((_S1703), (true), (4.294967296e+09f), (false), (_S1408), (false)));
                hit_4 = _S1704;
                b_11 = b_12;
                throughput_10 = throughput_11;
                spread_3 = _S1660;
                width_4 = width_7;
                sky_pdf_1 = _S1702;
            }
            if(_S1179 != int(2))
            {
                spread_3 = spread_4;
                width_4 = width_5;
                throughput_10 = throughput_8;
                b_11 = b_9;
                _S1491 = true;
                break;
            }
            ended_0 = _S1181;
            _S1491 = false;
            break;
        }
        if(_S1491)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1492 = b_11 == b_8;
        }
        else
        {
            _S1492 = false;
        }
        bool _S1705 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1705)
        {
            bool _S1706 = !(&nee_vertex_0)->none;
            float _S1707 = _slang_select(_S1706, sky_pdf_1,0.0f);
            float _S1708 = escapeWeight_0(_S1707, (&ray_2)->unit_direction);
            float3  _S1709 = environment_0((&ray_2)->unit_direction, b_11, (&prev_0)->lobe);
            float3  _S1710 = throughput_10 * _S1709;
            if(replay_2)
            {
                bool _S1711 = b_11 == _S1196;
                if(_S1711)
                {
                    passes_0 = _S1185 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1710 * make_float3 (_S1708) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1195)
                {
                    passes_0 = _S1192;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_11 == _S1183;
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
                    return Shift_x24init_0(_S1710 * make_float3 (_S1708), 1.0f);
                }
                return _S1181;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1712 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1713 = _S1712 == 1U;
            if(_S1713)
            {
                uint _S1714 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1715 = _S1714 == b_11;
                float _S1716 = _slang_select(_S1715, 1.0f,_S1708);
                float3  _S1717 = safeDivide(_S1710 * make_float3 (_S1716), chain_throughput_0);
                (&candidate_10)->radiance = _S1717;
            }
            else
            {
                bool _S1718 = (&prev_0)->rough;
                if(_S1718)
                {
                    uint _S1719 = insertBits_0(0U, b_11 + 1U, 5U, 5U);
                    uint _S1720 = insertBits_0(_S1719, 3U, 10U, 2U);
                    uint _S1721 = insertBits_0(_S1720, (&prev_0)->lobe, 15U, 3U);
                    bool _S1722 = (&prev_0)->inside;
                    uint _S1723 = _slang_select(_S1722, 1U,0U);
                    uint _S1724 = insertBits_0(_S1721, _S1723, 22U, 1U);
                    (&candidate_10)->path = _S1724;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1725 = _S1710 * make_float3 (_S1708);
            Reservoir _S1726 = withEnd(candidate_10, 3U, b_11, _S1725);
            offer(sel_7, _S1726, _S1725 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1727 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1727;
        bool _S1728 = (fcptVaryingUsed());
        if(_S1728)
        {
            _S1493 = filling_2 != 4294967295U;
        }
        else
        {
            _S1493 = false;
        }
        if(_S1493)
        {
            if(_S1607)
            {
                float3  _S1729 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1730 = sel_7->glow + _S1729;
                sel_7->glow = _S1730;
            }
            float3  _S1731 = throughput_10 * weight_1;
            throughput_8 = _S1731;
        }
        else
        {
            float3  _S1732 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1733 = throughput_10 * _S1732;
            throughput_8 = _S1733;
        }
        float _S1734 = width_4 + spread_3 * (&hit_4)->distance;
        viewed_0 = _S1492;
        width_3 = _S1734;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_3;
        uint _S1621 = b_11 + 1U;
        b_8 = _S1621;
        layer_0 = _S1620;
    }
    return _S1181;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_9)
{
    Selection _S1735 = (Selection{});
    Selection sel_8 = _S1735;
    bool _S1736 = (r_9->w) <= 0.0f;
    if(_S1736)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1737 = walk_0(dom_8, r_9, true, 0.0f, &sel_8);
    return _S1737;
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
        *_slang_vector_get_element_ptr(&result_14, i_20) = (F32_tan((_slang_vector_get_element(x_26, i_20))));
        i_20 = i_20 + int(1);
    }
    return result_14;
}

static __device__ float3  acos_0(float3  x_27)
{
    float3  result_15;
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
        *_slang_vector_get_element_ptr(&result_15, i_21) = (F32_acos((_slang_vector_get_element(x_27, i_21))));
        i_21 = i_21 + int(1);
    }
    return result_15;
}

static __device__ float3  abs_0(float3  x_28)
{
    float3  result_16;
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
        *_slang_vector_get_element_ptr(&result_16, i_22) = (F32_abs((_slang_vector_get_element(x_28, i_22))));
        i_22 = i_22 + int(1);
    }
    return result_16;
}

__device__ Random normal_distribution(uint state_3)
{
    Random _S1738 = pcg(state_3);
    Random _S1739 = pcg(_S1738.state);
    float _S1740 = 6.28318548202514648f * _S1738.value;
    float _S1741 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1739.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1739.state, _S1741 * (F32_cos((_S1740))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1742;
    (&_S1742)->state = state_4;
    (&_S1742)->value = value_2;
    return _S1742;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1743 = normal_distribution(state_5);
    Random _S1744 = normal_distribution(_S1743.state);
    Random _S1745 = normal_distribution(_S1744.state);
    float3  _S1746 = make_float3 (_S1743.value, _S1744.value, _S1745.value);
    float3  _S1747 = ((((_S1746)) * make_float3(rnorm3df(((_S1746)).x, ((_S1746)).y, ((_S1746)).z))));
    return RandomSphere_x24init_0(_S1745.state, _S1747);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_14)
{
    float3  _S1748 = p1_0 - p0_0;
    float3  _S1749 = p2_0 - p0_0;
    float2  _S1750 = uv1_0 - uv0_0;
    float2  _S1751 = uv2_0 - uv0_0;
    float _S1752 = _S1750.x;
    float _S1753 = _S1751.y;
    float _S1754 = _S1750.y;
    float _S1755 = _S1751.x;
    float _S1756 = _S1752 * _S1753 - _S1754 * _S1755;
    float _S1757 = 1.0f / _S1756;
    float3  t_22 = (_S1748 * make_float3 (_S1753) - _S1749 * make_float3 (_S1754)) * make_float3 (_S1757);
    float3  _S1758 = (_S1749 * make_float3 (_S1752) - _S1748 * make_float3 (_S1755)) * make_float3 (_S1757);
    float3  _S1759 = t_22 - n_14 * make_float3 (dot_0(n_14, t_22));
    float3  t_23 = ((((_S1759)) * make_float3(rnorm3df(((_S1759)).x, ((_S1759)).y, ((_S1759)).z))));
    bool _S1760 = (dot_0(cross_0(n_14, t_23), _S1758)) > 0.0f;
    float3  t_24;
    if(_S1760)
    {
        float3  _S1761 = negate_0(t_23);
        t_24 = _S1761;
    }
    else
    {
        t_24 = t_23;
    }
    float3  _S1762 = cross_0(n_14, t_24);
    return makeMatrix<float, 3, 3> (t_24, _S1762, n_14);
}

__device__ float3  tangentToWorldNormalMap(float3  v_4, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_4, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1763 = t1_0 - t0_0;
    float3  _S1764 = t2_2 - t0_0;
    float3  _S1765 = t2_2 - t1_0;
    float _S1766 = (F32_min((length_0(_S1763)), ((F32_min((length_0(_S1764)), (length_0(_S1765)))))));
    float3  _S1767 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1768 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1769 = dot_0(geometry_n_5, _S1768);
    float3  _S1770 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1771 = dot_0(geometry_n_5, _S1770);
    float3  _S1772 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1773 = acos_0(abs_0(make_float3 (_S1769, _S1771, dot_0(geometry_n_5, _S1772))));
    float3  _S1774 = clamp_2(tan_0(_S1773), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1767 * _S1774, uvw_0), 0.0f, _S1766 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_15, float3  n_15, BSDFMaterial material_16)
{
    float3  _S1775 = negate_0(dir_15);
    float _S1776 = sign_0(dot_0(n_15, _S1775));
    float3  _S1777 = n_15 * make_float3 (_S1776);
    AnisotropicFrame _S1778 = anisotropicFrame(material_16, _S1777);
    bool _S1779 = (_S1778.alphas.x) > 0.0f;
    if(_S1779)
    {
        float _S1780 = material_16.transmission * (1.0f - material_16.metallic);
        float3  _S1781 = negate_0(_S1777);
        float3  _S1782 = anisotropicLocal(dir_15, _S1778.tangent, _S1781);
        float _S1783 = anisotropicG1(_S1782, _S1778.alphas);
        return make_float3 (_S1780 * _S1783) * material_16.albedo;
    }
    float _S1784 = material_16.transmission * (1.0f - material_16.metallic);
    float _S1785 = material_16.roughness;
    float _S1786 = smithG1(_S1785 * _S1785, (F32_abs((dot_0(n_15, dir_15)))));
    return make_float3 (_S1784 * _S1786) * material_16.albedo;
}

__device__ float hairRow(float3  in_dir_10, float3  t_25, float3  out_dir_4, uint p_14, float w_2, float alpha_6, uint nt_0)
{
    uint _S1787 = p_14 % 4U;
    float _S1788 = w_2 * HAIR_WIDTHS_0[_S1787];
    float _S1789 = (F32_asin((clamp_1(dot_0(out_dir_4, t_25), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_10, t_25), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1787] * alpha_6;
    return ((F32_asinh((_S1789 / _S1788))) / (F32_asinh((3.14159274101257324f / _S1788))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_11, float3  t_26, float3  out_dir_5, uint np_0)
{
    float3  _S1790 = worldToTangent(out_dir_5, t_26);
    float3  _S1791 = worldToTangent(in_dir_11, t_26);
    return (F32_frac((((F32_atan2((_S1790.z), (_S1790.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1791.z), (1.17549435082228751e-38f - _S1791.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_12, float3  t_27, uint p_15, float row_0, float column_0, float w_3, float alpha_7, uint nt_1, uint np_1)
{
    float3  _S1792 = worldToTangent(in_dir_12, t_27);
    uint _S1793 = p_15 % 4U;
    float _S1794 = w_3 * HAIR_WIDTHS_0[_S1793];
    float _S1795 = (F32_asin((clamp_1(dot_0(in_dir_12, t_27), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1793] * alpha_7 + _S1794 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1794))))));
    float _S1796 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1792.z), (1.17549435082228751e-38f - _S1792.x)));
    float _S1797 = (F32_cos((_S1795)));
    float3  _S1798 = tangentToWorld(make_float3 (_S1797 * (F32_cos((_S1796))), (F32_sin((_S1795))), _S1797 * (F32_sin((_S1796)))), t_27);
    return _S1798;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_16, BSDFMaterial material_17, float coverage_1)
{
    float3  _S1799;
    if((material_17.ior) == 1.0f)
    {
        float3  _S1800 = straightThrough(toward_1, n_16, material_17);
        _S1799 = _S1800;
    }
    else
    {
        _S1799 = make_float3 (0.0f);
    }
    return _S1799 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_4, Selection * sel_9)
{
    Domain _S1801 = dom_9;
    Reservoir _S1802 = r_10;
    Shift _S1803 = walk_0(&_S1801, &_S1802, replay_3, scale_4, sel_9);
    return _S1803;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_11)
{
    Domain _S1804 = dom_10;
    Reservoir _S1805 = r_11;
    Shift _S1806 = shift_0(&_S1804, &_S1805);
    return _S1806;
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
