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

__device__ static const FixedArray<float, 243>  SPECTRAL_PRIMARIES_0 = { {
    0.028201999142766f, 9.99999997475242708e-07f, 0.97179698944091797f, 0.02820000052452087f, 0.0f, 0.97180002927780151f, 0.02819300070405006f, 0.0f, 0.97180700302124023f, 0.0281750001013279f, 0.0f, 0.9718250036239624f, 0.02813299931585789f, 0.0f, 0.97186702489852905f, 0.02804199978709221f, 0.0f, 0.9719579815864563f, 0.02786399982869625f, 0.0f, 0.97213602066040039f, 0.0275299996137619f, 0.0f, 0.9724699854850769f, 0.02692800015211105f, 0.0f, 0.97307199239730835f, 0.02592499926686287f, 0.0f, 0.97407501935958862f, 0.02444599941372871f, 0.0f, 0.97555398941040039f, 0.02258899994194508f, 0.0f, 0.97741097211837769f, 0.02068600058555603f, 0.0f, 0.97931402921676636f, 0.01939599961042404f, 0.0f, 0.98060399293899536f, 0.01972600072622299f, 0.0f, 0.9802740216255188f, 0.02305700071156025f, 0.0f, 0.97694301605224609f, 0.0282990001142025f, 0.00548999989405274f, 0.96621102094650269f, 0.02276800014078617f, 0.04560500010848045f, 0.93162697553634644f, 0.0118180001154542f, 0.11352799832820892f, 0.87465399503707886f, 0.00192399998195469f, 0.20037899911403656f, 0.79769700765609741f, 0.0f, 0.29692500829696655f, 0.70307499170303345f, 0.0f, 0.40064999461174011f, 0.5993499755859375f, 0.0f, 0.50742298364639282f, 0.49257698655128479f, 0.0f, 0.61289197206497192f, 0.38710799813270569f, 0.0f, 0.71311402320861816f, 0.28688600659370422f, 0.0f, 0.8042140007019043f, 0.1957859992980957f, 0.0f, 0.88220900297164917f, 0.11779099702835083f, 0.0f, 0.94313102960586548f, 0.05686900019645691f, 0.0f, 0.98336499929428101f, 0.01663500070571899f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.99855601787567139f, 0.00144400005228817f, 0.0f, 0.97892600297927856f, 0.02107400074601173f, 0.03028500080108643f, 0.92923498153686523f, 0.04047999903559685f, 0.10447199642658234f, 0.84615302085876465f, 0.04937500134110451f, 0.21104000508785248f, 0.73897498846054077f, 0.04998499900102615f, 0.33820000290870667f, 0.61719298362731934f, 0.04460699856281281f, 0.47420701384544373f, 0.49019300937652588f, 0.03559999912977219f, 0.60847699642181396f, 0.3664110004901886f, 0.02511199936270714f, 0.73185497522354126f, 0.25317299365997314f, 0.01497200038284063f, 0.83687901496887207f, 0.15642799437046051f, 0.00669299997389317f, 0.91802400350570679f, 0.08053100109100342f, 0.00144499994348735f, 0.97194302082061768f, 0.02805699966847897f, 0.0f, 0.99879997968673706f, 0.00120000005699694f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999797344207764f, 9.99999997475242708e-07f, 9.99999997475242708e-07f, 0.99999797344207764f, 9.99999997475242708e-07f, 9.99999997475242708e-07f, 0.99999701976776123f, 9.99999997475242708e-07f, 1.99999999495048542e-06f, 0.99999499320983887f, 1.99999999495048542e-06f, 3.00000010611256585e-06f, 0.99999302625656128f, 1.99999999495048542e-06f, 4.99999987368937582e-06f, 0.99998897314071655f, 3.99999998990097083e-06f, 7.00000009601353668e-06f, 0.9999840259552002f, 6.00000021222513169e-06f, 0.00000999999974738f, 0.99997901916503906f, 0.0000079999999798f, 0.00001299999985349f, 0.99997401237487793f, 0.00000999999974738f, 0.0000159999999596f, 0.99997299909591675f, 0.00001200000042445f, 0.00001499999962107f, 0.99996697902679443f, 0.00001499999962107f, 0.00001800000063668f, 0.9999690055847168f, 0.00001499999962107f, 0.0000159999999596f, 0.9999619722366333f, 0.00001700000029814f, 0.00002099999983329f
} };
__device__ float upsample(float3  rgb_0, float wavelength_0)
{
    float _S331 = clamp_1((wavelength_0 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S332 = (U32_min((uint(_S331)), (79U)));
    uint _S333 = 3U * _S332;
    float3  _S334 = make_float3 (SPECTRAL_PRIMARIES_0[_S333], SPECTRAL_PRIMARIES_0[_S333 + 1U], SPECTRAL_PRIMARIES_0[_S333 + 2U]);
    float3  _S335 = make_float3 (SPECTRAL_PRIMARIES_0[_S333 + 3U], SPECTRAL_PRIMARIES_0[_S333 + 4U], SPECTRAL_PRIMARIES_0[_S333 + 5U]);
    return dot_0(rgb_0, _S334 + (_S335 - _S334) * make_float3 (_S331 - float(_S332)));
}

__device__ BSDFMaterial atWavelength(BSDFMaterial material_0, float wavelength_1)
{
    BSDFMaterial at_0 = material_0;
    float _S336 = upsample(material_0.albedo, wavelength_1);
    float3  _S337 = make_float3 (_S336);
    (&at_0)->albedo = _S337;
    float _S338 = upsample(material_0.emissive, wavelength_1);
    float3  _S339 = make_float3 (_S338);
    (&at_0)->emissive = _S339;
    float _S340 = upsample(material_0.absorption, wavelength_1);
    float3  _S341 = make_float3 (_S340);
    (&at_0)->absorption = _S341;
    float _S342 = upsample(material_0.specular_tint, wavelength_1);
    float3  _S343 = make_float3 (_S342);
    (&at_0)->specular_tint = _S343;
    float _S344 = upsample(material_0.translucent, wavelength_1);
    float3  _S345 = make_float3 (_S344);
    (&at_0)->translucent = _S345;
    float _S346 = upsample(material_0.sheen, wavelength_1);
    float3  _S347 = make_float3 (_S346);
    (&at_0)->sheen = _S347;
    float _S348 = upsample(material_0.coat_tint, wavelength_1);
    float3  _S349 = make_float3 (_S348);
    (&at_0)->coat_tint = _S349;
    return at_0;
}

__device__ BSDFMaterial pathMaterial(BSDFMaterial material_1, float wavelength_2)
{
    BSDFMaterial _S350;
    if(wavelength_2 > 0.0f)
    {
        BSDFMaterial _S351 = atWavelength(material_1, wavelength_2);
        _S350 = _S351;
    }
    else
    {
        _S350 = material_1;
    }
    return _S350;
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    float _S352;
    if(e_1 > 0.0f)
    {
        _S352 = 1.0f;
    }
    else
    {
        if(e_1 < 0.0f)
        {
            _S352 = -1.0f;
        }
        else
        {
            _S352 = 0.0f;
        }
    }
    return _S352;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S353;
    (&_S353)->tangent = tangent_0;
    (&_S353)->alphas = alphas_0;
    return _S353;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S354 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S354)
    {
        float3  _S355 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S355;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S356 = cross_0(n_1, a_2);
    float3  _S357 = ((((_S356)) * make_float3(rnorm3df(((_S356)).x, ((_S356)).y, ((_S356)).z))));
    float3  _S358 = cross_0(n_1, _S357);
    return make_float3 (v_0.x) * _S357 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S358;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_2, float3  n_i_0)
{
    float _S359 = material_2.roughness;
    float _S360 = _S359 * _S359;
    bool _S361 = (material_2.anisotropy) == 0.0f;
    bool _S362;
    if(_S361)
    {
        _S362 = true;
    }
    else
    {
        _S362 = !(_S360 > 0.0f);
    }
    if(_S362)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S363 = material_2.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_2.tangent));
    float3  _S364 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S365 = (dot_0(_S363, _S363)) > 0.0f;
    float3  _S366 = _slang_select(_S365, _S363,_S364);
    float3  _S367 = ((((_S366)) * make_float3(rnorm3df(((_S366)).x, ((_S366)).y, ((_S366)).z))));
    float _S368 = 6.28318548202514648f * material_2.anisotropic_rotation;
    float _S369 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_2.anisotropy))))));
    float _S370 = 1.0f / _S369;
    bool _S371 = (material_2.anisotropy) < 0.0f;
    float _S372 = _slang_select(_S371, _S370,_S369);
    return AnisotropicFrame_x24init_0(_S367 * make_float3 ((F32_cos((_S368)))) + cross_0(n_i_0, _S367) * make_float3 ((F32_sin((_S368)))), make_float2 (_S360 / _S372, _S360 * _S372));
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S373;
    (&_S373)->on = on_0;
    (&_S373)->albedo = albedo_0;
    return _S373;
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
    SheenProfile _S374 = SheenProfile_x24init_0(false, 0.0f);
    float _S375 = rgb_to_greyscale(material_3.sheen);
    bool _S376 = _S375 > 0.0f;
    SheenProfile profile_0;
    if(_S376)
    {
        float _S377 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S378 = (U32_min((uint(_S377)), (22U)));
        float _S379 = (F32_sqrt((0.05000000074505806f)));
        float _S380 = (F32_sqrt((0.00999999977648258f)));
        bool _S381 = (material_3.velvet) > 0.0f;
        float _S382 = _slang_select(_S381, _S380,_S379);
        float _S383 = (clamp_1((F32_sqrt(((F32_max((material_3.sheen_roughness), (0.0f)))))), _S382, 1.0f) - _S382) / (1.0f - _S382) * 23.0f;
        uint _S384 = (U32_min((uint(_S383)), (22U)));
        uint _S385 = _S378 * 24U + _S384;
        float _S386 = _S377 - float(_S378);
        float _S387 = _S383 - float(_S384);
        if(_S381)
        {
            uint _S388 = _S385 + 24U;
            float _S389 = VELVET_ALBEDO_0[_S385] + (VELVET_ALBEDO_0[_S388] - VELVET_ALBEDO_0[_S385]) * _S386;
            uint _S390 = _S385 + 1U;
            float _S391 = VELVET_ALBEDO_0[_S390] + (VELVET_ALBEDO_0[_S388 + 1U] - VELVET_ALBEDO_0[_S390]) * _S386;
            SheenProfile _S392 = SheenProfile_x24init_0(true, _S389 + (_S391 - _S389) * _S387);
            profile_0 = _S392;
        }
        else
        {
            uint _S393 = _S385 + 24U;
            float _S394 = SHEEN_ALBEDO_0[_S385] + (SHEEN_ALBEDO_0[_S393] - SHEEN_ALBEDO_0[_S385]) * _S386;
            uint _S395 = _S385 + 1U;
            float _S396 = SHEEN_ALBEDO_0[_S395] + (SHEEN_ALBEDO_0[_S393 + 1U] - SHEEN_ALBEDO_0[_S395]) * _S386;
            SheenProfile _S397 = SheenProfile_x24init_0(true, (F32_exp((_S394 + (_S396 - _S394) * _S387))));
            profile_0 = _S397;
        }
    }
    else
    {
        profile_0 = _S374;
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
    CoatFrame _S398;
    (&_S398)->normal = normal_3;
    (&_S398)->alpha = alpha_0;
    (&_S398)->ior = ior_0;
    return _S398;
}

__device__ __forceinline__ CoatFrame coatFrame(BSDFMaterial material_4, float3  n_2)
{
    CoatFrame _S399 = CoatFrame_x24init_0(make_float3 (0.0f), 0.0f, 0.0f);
    bool _S400 = (material_4.coat) > 0.0f;
    CoatFrame frame_0;
    if(_S400)
    {
        float3  _S401 = material_4.coat_normal;
        bool _S402 = (dot_0(_S401, _S401)) > 0.0f;
        float3  _S403 = material_4.coat_normal;
        float3  _S404 = ((((_S403)) * make_float3(rnorm3df(((_S403)).x, ((_S403)).y, ((_S403)).z))));
        float3  _S405 = _slang_select(_S402, _S404,n_2);
        float _S406 = sign_0(dot_0(_S405, n_2));
        float _S407 = material_4.coat_roughness;
        CoatFrame _S408 = CoatFrame_x24init_0(_S405 * make_float3 (_S406), _S407 * _S407, (F32_max((material_4.coat_ior), (1.00999999046325684f))));
        frame_0 = _S408;
    }
    else
    {
        frame_0 = _S399;
    }
    return frame_0;
}

__device__ __forceinline__ float3  coatSeries(CoatFrame coat_frame_0, BSDFMaterial material_5)
{
    float3  _S409 = make_float3 (0.0f);
    bool _S410 = (coat_frame_0.ior) > 0.0f;
    float3  series_0;
    if(_S410)
    {
        float _S411 = coat_frame_0.ior * coat_frame_0.ior;
        float _S412 = _S411 * _S411;
        float _S413 = coat_frame_0.ior - 1.0f;
        float _S414 = coat_frame_0.ior + 1.0f;
        float _S415 = _S411 - 1.0f;
        float _S416 = _S411 + 1.0f;
        float _S417 = _S412 - 1.0f;
        float _S418 = _S416 * _S417;
        float _S419 = 0.5f + _S413 * (3.0f * coat_frame_0.ior + 1.0f) / (6.0f * _S414 * _S414) + _S411 * _S415 * _S415 / (_S416 * _S416 * _S416) * (F32_log((_S413 / _S414))) - 2.0f * _S411 * coat_frame_0.ior * (_S411 + 2.0f * coat_frame_0.ior - 1.0f) / _S418 + 8.0f * _S412 * (_S412 + 1.0f) / (_S418 * _S417) * (F32_log((coat_frame_0.ior)));
        float _S420 = 1.0f - (1.0f - _S419) / _S411;
        float3  _S421 = material_5.coat_tint;
        float3  _S422 = _S421 * _S421 * make_float3 (1.0f - _S420) / (make_float3 (1.0f) - material_5.albedo * make_float3 (_S420));
        series_0 = _S422;
    }
    else
    {
        series_0 = _S409;
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
    float _S423 = dot_0(n_3, i_6);
    float _S424 = 1.0f - eta_0 * eta_0 * (1.0f - _S423 * _S423);
    if(_S424 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_6 - make_float3 (eta_0 * _S423 + (F32_sqrt((_S424)))) * n_3;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S425 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S426 = eta_i_0 / eta_o_0 * _S425;
    bool _S427 = _S426 < 1.0f;
    float kr_0;
    if(_S427)
    {
        float _S428 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S426 * _S426))))));
        bool _S429 = eta_i_0 == eta_o_0;
        float _S430 = _slang_select(_S429, cos_theta_0,_S428);
        float _S431 = eta_o_0 * cos_theta_0;
        float _S432 = eta_i_0 * _S430;
        float _S433 = (_S431 - _S432) / (_S431 + _S432);
        float _S434 = eta_i_0 * cos_theta_0;
        float _S435 = eta_o_0 * _S430;
        float _S436 = (_S434 - _S435) / (_S434 + _S435);
        float _S437 = (_S433 * _S433 + _S436 * _S436) / 2.0f;
        kr_0 = _S437;
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
    float _S438 = alpha_1 * alpha_1;
    float _S439 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S438 + (1.0f - _S438) * n_dot_x_0 * n_dot_x_0))));
    bool _S440 = alpha_1 > 0.0f;
    float _S441 = _slang_select(_S440, _S439,1.0f);
    return _S441;
}

__device__ __forceinline__ float coatFresnel(float3  in_dir_0, float3  v_2, float3  coat_h_0, CoatFrame coat_frame_1, float eta_i_1, bool behind_0)
{
    float _S442 = dot_0(coat_frame_1.normal, reflect_0(in_dir_0, coat_h_0));
    float _S443 = (F32_abs((dot_0(v_2, coat_h_0))));
    float _S444 = eta_i_1 / coat_frame_1.ior * (F32_sqrt(((F32_max((1.0f - _S443 * _S443), (0.0f))))));
    float _S445 = (F32_sqrt(((F32_max((1.0f - _S444 * _S444), (0.0f))))));
    float _S446 = _slang_select(behind_0, _S445,_S443);
    float _S447 = _slang_select(behind_0, coat_frame_1.ior,1.0f);
    float _S448 = _slang_select(behind_0, 1.0f,coat_frame_1.ior);
    float _S449 = fresnel(_S446, _S447, _S448);
    float _S450 = smithG1(coat_frame_1.alpha, _S442);
    float _S451 = _S449 * _S450;
    bool _S452 = _S442 > 0.0f;
    float _S453 = _slang_select(_S452, _S451,0.0f);
    return _S453;
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

static __device__ Weights Weights_x24init_0(float v_dot_h_0, float3  refracted_1, float3  F_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float p_sheen_velvet_0, float p_toon_0, float3  sheen_0, float3  toon_0, float3  coat_0, float p_coat_0)
{
    Weights _S454;
    (&_S454)->v_dot_h = v_dot_h_0;
    (&_S454)->refracted = refracted_1;
    (&_S454)->F = F_0;
    (&_S454)->reflect_weight = reflect_weight_0;
    (&_S454)->diffuse_weight = diffuse_weight_0;
    (&_S454)->refract_weight = refract_weight_0;
    (&_S454)->p_diffuse = p_diffuse_0;
    (&_S454)->p_reflect = p_reflect_0;
    (&_S454)->p_refract = p_refract_0;
    (&_S454)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S454)->p_toon = p_toon_0;
    (&_S454)->sheen = sheen_0;
    (&_S454)->toon = toon_0;
    (&_S454)->coat = coat_0;
    (&_S454)->p_coat = p_coat_0;
    return _S454;
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
    float _S455 = (F32_min(((F32_sqrt((material_6.specular_level))) * (F32_abs((eta_i_2 - eta_o_1))) / (eta_i_2 + eta_o_1)), (0.9999847412109375f)));
    float _S456 = _S455 * _S455;
    float _S457 = (1.0f + _S455) / (1.0f - _S455);
    float3  _S458 = make_float3 (1.0f);
    float3  _S459 = make_float3 (0.0f);
    float sheen_component_0;
    float3  sheen_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S460 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S461 = make_float3 (1.0f) - material_6.sheen * make_float3 (_S460);
        float _S462 = rgb_to_greyscale(material_6.sheen);
        float _S463 = _S462 * _S460;
        float3  _S464 = material_6.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S463;
        sheen_1 = _S464;
        scale_1 = _S461;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S459;
        scale_1 = _S458;
    }
    float _S465 = (F32_abs((material_6.toon.x)));
    bool _S466 = _S465 > 0.0f;
    float toon_component_0;
    float3  toon_1;
    if(_S466)
    {
        float _S467 = (F32_min((_S465), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S467);
        float _S468 = rgb_to_greyscale(material_6.albedo);
        float _S469 = _S467 * _S468;
        float3  _S470 = make_float3 (_S467) * material_6.albedo;
        toon_component_0 = _S469;
        toon_1 = _S470;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S459;
    }
    bool _S471 = (material_6.metallic) > 0.0f;
    float3  rebounce_0;
    if(_S471)
    {
        float _S472 = frame_1.alphas.x;
        float _S473 = (F32_sqrt(((F32_min((_S472), (frame_1.alphas.y))))));
        bool _S474 = _S472 > 0.0f;
        float _S475 = _slang_select(_S474, _S473,material_6.roughness);
        float _S476 = _S475 * _S475;
        float _S477 = (F32_pow((_S476), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S476) / (1.0f + 1.28094995021820068f * _S476);
        bool _S478 = _S476 > 0.0f;
        float _S479 = _slang_select(_S478, _S477,0.0f);
        float _S480 = clamp_1(dot_0(n_i_2, v_3), 0.0f, 1.0f);
        float _S481 = _S476 * _S475;
        float _S482 = (F32_min((1.00064504146575928f - _S475 * (0.00375499995425344f + _S480 * (-0.04133399948477745f + _S480 * (-0.90938502550125122f + _S480 * 0.35275399684906006f))) - _S476 * (0.27602800726890564f + _S480 * (1.27023398876190186f + _S480 * 0.04740000143647194f)) - _S481 * (0.31452900171279907f - _S480 * 0.34830701351165771f) + _S481 * _S475 * 0.27229699492454529f), (1.0f)));
        float3  _S483 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_6.albedo * make_float3 (_S479)), make_float3 (1.0f / (F32_max((_S482), (0.0000152587890625f)))));
        rebounce_0 = _S483;
    }
    else
    {
        rebounce_0 = _S458;
    }
    float _S484 = dot_0(h_0, v_3);
    float _S485 = eta_i_2 / eta_o_1;
    float3  _S486 = refract_0(in_dir_1, h_0, _S485);
    float3  _S487 = ((((_S486)) * make_float3(rnorm3df(((_S486)).x, ((_S486)).y, ((_S486)).z))));
    float _S488 = (F32_abs((_S484)));
    bool _S489 = eta_i_2 > eta_o_1;
    float _S490;
    if(_S489)
    {
        _S490 = _S457;
    }
    else
    {
        _S490 = 1.0f;
    }
    float _S491;
    if(_S489)
    {
        _S491 = 1.0f;
    }
    else
    {
        _S491 = _S457;
    }
    float _S492 = fresnel(_S488, _S490, _S491);
    float _S493 = eta_i_2 * eta_i_2;
    float _S494 = eta_o_1 * eta_o_1;
    bool _S495 = (_S493 * (1.0f - _S484 * _S484)) >= _S494;
    float3  _S496;
    if(_S495)
    {
        _S496 = _S458;
    }
    else
    {
        float3  _S497 = material_6.specular_tint * make_float3 (_S456);
        _S496 = _S497 + (make_float3 (1.0f) - _S497) * make_float3 (_S492 - _S456) / make_float3 (1.0f - _S456);
    }
    bool _S498 = (dot_0(coat_h_1, coat_h_1)) > 0.0f;
    float3  coat_1;
    float3  up_0;
    float3  through_0;
    if(_S498)
    {
        float _S499 = coatFresnel(in_dir_1, v_3, coat_h_1, coat_frame_2, eta_i_2, _S489);
        float _S500 = material_6.coat * _S499;
        float3  _S501 = material_6.coat_tint;
        float3  _S502 = _S501 * _S501;
        float3  _S503 = _slang_select(_S489, _S502,_S458);
        float3  _S504 = make_float3 (_S500) * _S503;
        float _S505 = 1.0f - _S499;
        bool _S506 = !_S489;
        float3  _S507 = _slang_select(_S506, coat_series_0,_S458);
        float3  _S508 = mix_0(_S458, make_float3 (_S505) * _S507, material_6.coat);
        float3  _S509 = mix_0(_S458, make_float3 (_S505) * material_6.coat_tint, material_6.coat);
        coat_1 = _S504;
        up_0 = _S508;
        through_0 = _S509;
    }
    else
    {
        coat_1 = _S459;
        up_0 = _S458;
        through_0 = _S458;
    }
    float3  _S510 = scale_1 * coat_1;
    float _S511 = rgb_to_greyscale(_S510);
    float3  _S512 = material_6.albedo * rebounce_0;
    float3  _S513 = mix_0(_S496, _S512, material_6.metallic);
    float3  F_1 = _S513 * scale_1 * up_0;
    float _S514 = rgb_to_greyscale(F_1);
    float _S515 = 1.0f - material_6.metallic;
    float _S516 = (1.0f - material_6.transmission) * _S515;
    float3  _S517 = make_float3 (1.0f) - _S496;
    float3  _S518 = make_float3 (_S516) * _S517 * scale_1 * up_0;
    float _S519 = material_6.transmission * _S515;
    float3  _S520 = make_float3 (_S519) * _S517 * scale_1 * through_0;
    float _S521 = (F32_max((_S514), (0.0f)));
    float _S522 = rgb_to_greyscale(_S518);
    float _S523 = (F32_max((_S522), (0.0f)));
    float _S524 = rgb_to_greyscale(_S520);
    float _S525 = sign_0(length_0(_S487));
    float _S526 = (F32_max((_S524 * _S525), (0.0f)));
    float _S527 = _S521 + _S523 + _S526 + toon_component_0 + _S511;
    float _S528 = (F32_min((sheen_component_0), (1.0f)));
    bool _S529 = sheen_component_0 > 0.0f;
    bool _S530;
    if(_S529)
    {
        _S530 = !(_S527 > 0.0f);
    }
    else
    {
        _S530 = false;
    }
    float _S531 = _slang_select(_S530, 1.0f,_S528);
    float _S532 = (1.0f - _S531) / (F32_max((_S527), (0.0000152587890625f)));
    float _S533 = _S523 * _S532;
    float _S534 = _S521 * _S532;
    float _S535 = _S526 * _S532;
    Weights _S536 = Weights_x24init_0(_S484, _S487, F_1, 1.0f, _S518, _S520, _S533, _S534, _S535, _S531, toon_component_0 * _S532, sheen_1, toon_1, _S510, _S511 * _S532);
    bool _S537 = any_1(ggx_n_0 != h_0);
    Weights leaving_0;
    if(_S537)
    {
        float _S538 = dot_0(ggx_n_0, v_3);
        float _S539 = eta_i_2 / eta_o_1;
        float3  _S540 = refract_0(in_dir_1, ggx_n_0, _S539);
        float3  _S541 = ((((_S540)) * make_float3(rnorm3df(((_S540)).x, ((_S540)).y, ((_S540)).z))));
        float _S542 = (F32_abs((_S538)));
        if(_S489)
        {
            _S490 = _S457;
        }
        else
        {
            _S490 = 1.0f;
        }
        if(_S489)
        {
            _S491 = 1.0f;
        }
        else
        {
            _S491 = _S457;
        }
        float _S543 = fresnel(_S542, _S490, _S491);
        bool _S544 = (_S493 * (1.0f - _S538 * _S538)) >= _S494;
        if(_S544)
        {
            _S496 = _S458;
        }
        else
        {
            float3  _S545 = material_6.specular_tint * make_float3 (_S456);
            _S496 = _S545 + (make_float3 (1.0f) - _S545) * make_float3 (_S543 - _S456) / make_float3 (1.0f - _S456);
        }
        if(_S498)
        {
            float _S546 = coatFresnel(in_dir_1, v_3, coat_h_1, coat_frame_2, eta_i_2, _S489);
            float _S547 = material_6.coat * _S546;
            float3  _S548 = material_6.coat_tint;
            float3  _S549 = _S548 * _S548;
            float3  _S550 = _slang_select(_S489, _S549,_S458);
            float3  _S551 = make_float3 (_S547) * _S550;
            float _S552 = 1.0f - _S546;
            bool _S553 = !_S489;
            float3  _S554 = _slang_select(_S553, coat_series_0,_S458);
            float3  _S555 = mix_0(_S458, make_float3 (_S552) * _S554, material_6.coat);
            float3  _S556 = mix_0(_S458, make_float3 (_S552) * material_6.coat_tint, material_6.coat);
            coat_1 = _S551;
            up_0 = _S555;
            through_0 = _S556;
        }
        else
        {
            coat_1 = _S459;
            up_0 = _S458;
            through_0 = _S458;
        }
        float3  _S557 = scale_1 * coat_1;
        float _S558 = rgb_to_greyscale(_S557);
        float3  _S559 = mix_0(_S496, _S512, material_6.metallic);
        float3  F_2 = _S559 * scale_1 * up_0;
        float _S560 = rgb_to_greyscale(F_2);
        float3  _S561 = make_float3 (1.0f) - _S496;
        float3  _S562 = make_float3 (_S516) * _S561 * scale_1 * up_0;
        float3  _S563 = make_float3 (_S519) * _S561 * scale_1 * through_0;
        float _S564 = (F32_max((_S560), (0.0f)));
        float _S565 = rgb_to_greyscale(_S562);
        float _S566 = (F32_max((_S565), (0.0f)));
        float _S567 = rgb_to_greyscale(_S563);
        float _S568 = sign_0(length_0(_S541));
        float _S569 = (F32_max((_S567 * _S568), (0.0f)));
        float _S570 = _S564 + _S566 + _S569 + toon_component_0 + _S558;
        if(_S529)
        {
            _S530 = !(_S570 > 0.0f);
        }
        else
        {
            _S530 = false;
        }
        float _S571 = _slang_select(_S530, 1.0f,_S528);
        float _S572 = (1.0f - _S571) / (F32_max((_S570), (0.0000152587890625f)));
        float _S573 = _S566 * _S572;
        float _S574 = _S564 * _S572;
        float _S575 = _S569 * _S572;
        Weights _S576 = Weights_x24init_0(_S538, _S541, F_2, 1.0f, _S562, _S563, _S573, _S574, _S575, _S571, toon_component_0 * _S572, sheen_1, toon_1, _S557, _S558 * _S572);
        leaving_0 = _S576;
    }
    else
    {
        leaving_0 = _S536;
    }
    bool _S577 = any_1(coat_n_0 != coat_h_1);
    Weights coated_0;
    if(_S577)
    {
        float _S578 = eta_i_2 / eta_o_1;
        float3  _S579 = refract_0(in_dir_1, h_0, _S578);
        float3  _S580 = ((((_S579)) * make_float3(rnorm3df(((_S579)).x, ((_S579)).y, ((_S579)).z))));
        if(_S489)
        {
            sheen_component_0 = _S457;
        }
        else
        {
            sheen_component_0 = 1.0f;
        }
        if(_S489)
        {
            _S490 = 1.0f;
        }
        else
        {
            _S490 = _S457;
        }
        float _S581 = fresnel(_S488, sheen_component_0, _S490);
        if(_S495)
        {
            rebounce_0 = _S458;
        }
        else
        {
            float3  _S582 = material_6.specular_tint * make_float3 (_S456);
            rebounce_0 = _S582 + (make_float3 (1.0f) - _S582) * make_float3 (_S581 - _S456) / make_float3 (1.0f - _S456);
        }
        bool _S583 = (dot_0(coat_n_0, coat_n_0)) > 0.0f;
        if(_S583)
        {
            float _S584 = coatFresnel(in_dir_1, v_3, coat_n_0, coat_frame_2, eta_i_2, _S489);
            float _S585 = material_6.coat * _S584;
            float3  _S586 = material_6.coat_tint;
            float3  _S587 = _S586 * _S586;
            float3  _S588 = _slang_select(_S489, _S587,_S458);
            float3  _S589 = make_float3 (_S585) * _S588;
            float _S590 = 1.0f - _S584;
            bool _S591 = !_S489;
            float3  _S592 = _slang_select(_S591, coat_series_0,_S458);
            float3  _S593 = mix_0(_S458, make_float3 (_S590) * _S592, material_6.coat);
            float3  _S594 = mix_0(_S458, make_float3 (_S590) * material_6.coat_tint, material_6.coat);
            coat_1 = _S589;
            up_0 = _S593;
            through_0 = _S594;
        }
        else
        {
            coat_1 = _S459;
            up_0 = _S458;
            through_0 = _S458;
        }
        float3  _S595 = scale_1 * coat_1;
        float _S596 = rgb_to_greyscale(_S595);
        float3  _S597 = mix_0(rebounce_0, _S512, material_6.metallic);
        float3  F_3 = _S597 * scale_1 * up_0;
        float _S598 = rgb_to_greyscale(F_3);
        float3  _S599 = make_float3 (1.0f) - rebounce_0;
        float3  _S600 = make_float3 (_S516) * _S599 * scale_1 * up_0;
        float3  _S601 = make_float3 (_S519) * _S599 * scale_1 * through_0;
        float _S602 = (F32_max((_S598), (0.0f)));
        float _S603 = rgb_to_greyscale(_S600);
        float _S604 = (F32_max((_S603), (0.0f)));
        float _S605 = rgb_to_greyscale(_S601);
        float _S606 = sign_0(length_0(_S580));
        float _S607 = (F32_max((_S605 * _S606), (0.0f)));
        float _S608 = _S602 + _S604 + _S607 + toon_component_0 + _S596;
        if(_S529)
        {
            _S530 = !(_S608 > 0.0f);
        }
        else
        {
            _S530 = false;
        }
        float _S609 = _slang_select(_S530, 1.0f,_S528);
        float _S610 = (1.0f - _S609) / (F32_max((_S608), (0.0000152587890625f)));
        float _S611 = _S604 * _S610;
        float _S612 = _S602 * _S610;
        float _S613 = _S607 * _S610;
        Weights _S614 = Weights_x24init_0(_S484, _S580, F_3, 1.0f, _S600, _S601, _S611, _S612, _S613, _S609, toon_component_0 * _S610, sheen_1, toon_1, _S595, _S596 * _S610);
        coated_0 = _S614;
    }
    else
    {
        coated_0 = _S536;
    }
    return Weights_x24init_0(leaving_0.v_dot_h, leaving_0.refracted, leaving_0.F, leaving_0.reflect_weight, _S536.diffuse_weight, leaving_0.refract_weight, _S536.p_diffuse, leaving_0.p_reflect, leaving_0.p_refract, _S536.p_sheen_velvet, _S536.p_toon, sheen_1, toon_1, coated_0.coat, coated_0.p_coat);
}

__device__ float translucentShare(BSDFMaterial material_7)
{
    float _S615 = rgb_to_greyscale(material_7.translucent);
    float _S616 = rgb_to_greyscale(material_7.albedo);
    float _S617 = _S615 / (_S616 + _S615);
    bool _S618 = _S615 > 0.0f;
    float _S619 = _slang_select(_S618, _S617,0.0f);
    return _S619;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float n_i_dot_v_0, BSDFMaterial material_8, Weights w_0)
{
    float _S620 = translucentShare(material_8);
    float _S621 = w_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S622 = w_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S623 = 1.0f - _S620;
    bool _S624 = n_i_dot_l_0 < 0.0f;
    float _S625 = _slang_select(_S624, _S620,_S623);
    float _S626 = _S622 * _S625;
    bool _S627 = _S620 > 0.0f;
    float _S628 = _slang_select(_S627, _S626,_S621);
    bool _S629 = n_i_dot_v_0 > 0.0f;
    float _S630 = _slang_select(_S629, _S628,0.0f);
    return _S630;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_3, BSDFMaterial material_9, Weights w_1)
{
    float _S631 = translucentShare(material_9);
    bool _S632 = (dot_0(n_i_3, l_0)) < 0.0f;
    float3  _S633 = _slang_select(_S632, material_9.translucent,material_9.albedo);
    float _S634 = 1.0f - _S631;
    float _S635 = _slang_select(_S632, _S631,_S634);
    float3  _S636 = _S633 / make_float3 (_S635);
    bool _S637 = _S631 > 0.0f;
    float3  _S638 = _slang_select(_S637, _S636,material_9.albedo);
    return w_1.diffuse_weight * _S638 / make_float3 (w_1.p_diffuse);
}

__device__ float trowbridgeReitz(float alpha_2, float n_dot_h_0)
{
    float _S639 = alpha_2 * alpha_2;
    float _S640 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S639 * n_dot_h_0 * n_dot_h_0;
    return _S639 / (F32_max((3.14159274101257324f * _S640 * _S640), (1.17549435082228751e-38f)));
}

__device__ float3  anisotropicLocal(float3  w_2, float3  t_12, float3  n_5)
{
    return make_float3 (dot_0(w_2, t_12), dot_0(w_2, cross_0(n_5, t_12)), dot_0(w_2, n_5));
}

__device__ float anisotropicG1(float3  w_3, float2  alphas_1)
{
    float _S641 = (F32_max((w_3.z), (0.0f)));
    return 2.0f * _S641 / (_S641 + length_0(make_float3 (alphas_1.x * w_3.x, alphas_1.y * w_3.y, _S641)));
}

__device__ float anisotropicD(float3  h_1, float2  alphas_2)
{
    float _S642 = alphas_2.x;
    float _S643 = h_1.x / _S642;
    float _S644 = alphas_2.y;
    float _S645 = h_1.y / _S644;
    float _S646 = h_1.z;
    float _S647 = _S643 * _S643 + _S645 * _S645 + _S646 * _S646;
    return 1.0f / (F32_max((3.14159274101257324f * _S642 * _S644 * _S647 * _S647), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float3  v_4, float3  h_2, float3  n_i_4, float n_i_dot_v_1, float alpha_3, AnisotropicFrame frame_2, float v_dot_h_1)
{
    float _S648 = dot_0(n_i_4, h_2);
    float _S649 = smithG1(alpha_3, n_i_dot_v_1);
    float _S650 = _S649 * v_dot_h_1;
    float _S651 = trowbridgeReitz(alpha_3, _S648);
    float _S652 = _S650 * _S651 / n_i_dot_v_1;
    bool _S653 = alpha_3 > 0.0f;
    bool _S654;
    if(_S653)
    {
        _S654 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S654 = false;
    }
    if(_S654)
    {
        _S654 = _S648 > 0.0f;
    }
    else
    {
        _S654 = false;
    }
    if(_S654)
    {
        _S654 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S654 = false;
    }
    float _S655 = _slang_select(_S654, _S652,0.0f);
    bool _S656 = (frame_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S656)
    {
        float3  _S657 = anisotropicLocal(v_4, frame_2.tangent, n_i_4);
        float _S658 = anisotropicG1(_S657, frame_2.alphas);
        float3  _S659 = anisotropicLocal(h_2, frame_2.tangent, n_i_4);
        float _S660 = anisotropicD(_S659, frame_2.alphas);
        float _S661 = _S658 * _S660;
        float _S662 = _S661 * v_dot_h_1 / n_i_dot_v_1;
        bool _S663 = v_dot_h_1 > 0.0f;
        if(_S663)
        {
            _S654 = _S648 > 0.0f;
        }
        else
        {
            _S654 = false;
        }
        if(_S654)
        {
            _S654 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S654 = false;
        }
        float _S664 = _slang_select(_S654, _S662,0.0f);
        pdf_h_0 = _S664;
    }
    else
    {
        pdf_h_0 = _S655;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float l_dot_h_0, float pdf_h_1, Weights w_4, float eta_i_3, float eta_o_2)
{
    float _S665 = eta_i_3 * w_4.v_dot_h + eta_o_2 * l_dot_h_0;
    float _S666 = w_4.p_refract * pdf_h_1 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S665 * _S665);
    bool _S667 = eta_i_3 != eta_o_2;
    bool _S668;
    if(_S667)
    {
        _S668 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S668 = false;
    }
    float _S669 = _slang_select(_S668, _S666,0.0f);
    return _S669;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_5, float alpha_4, AnisotropicFrame frame_3, BSDFMaterial material_10, Weights w_5)
{
    float _S670 = - dot_0(n_i_5, l_1);
    float _S671 = smithG1(alpha_4, (F32_max((_S670), (0.0f))));
    bool _S672 = (frame_3.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S672)
    {
        float3  _S673 = negate_0(n_i_5);
        float3  _S674 = anisotropicLocal(l_1, frame_3.tangent, _S673);
        float _S675 = anisotropicG1(_S674, frame_3.alphas);
        G1_l_0 = _S675;
    }
    else
    {
        G1_l_0 = _S671;
    }
    bool _S676 = (material_10.ior) == 1.0f;
    float _S677 = _slang_select(_S676, 1.0f,G1_l_0);
    return w_5.refract_weight * make_float3 (_S677) * material_10.albedo / make_float3 (w_5.p_refract);
}

__device__ __forceinline__ float reflectPDF(float pdf_h_2, Weights w_6)
{
    float _S678 = w_6.p_reflect * pdf_h_2 / (4.0f * w_6.v_dot_h);
    bool _S679 = pdf_h_2 > 0.0f;
    float _S680 = _slang_select(_S679, _S678,0.0f);
    return _S680;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_2, float3  n_i_6, float alpha_5, AnisotropicFrame frame_4, Weights w_7)
{
    float _S681 = dot_0(n_i_6, l_2);
    float _S682 = smithG1(alpha_5, (F32_max((_S681), (0.0f))));
    bool _S683 = (frame_4.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S683)
    {
        float3  _S684 = anisotropicLocal(l_2, frame_4.tangent, n_i_6);
        float _S685 = anisotropicG1(_S684, frame_4.alphas);
        G1_l_1 = _S685;
    }
    else
    {
        G1_l_1 = _S682;
    }
    return make_float3 (w_7.reflect_weight * G1_l_1) * w_7.F / make_float3 (w_7.p_reflect);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_1, float n_i_dot_v_2, Weights w_8)
{
    float _S686 = w_8.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S687 = n_i_dot_l_1 > 0.0f;
    bool _S688;
    if(_S687)
    {
        _S688 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S688 = false;
    }
    float _S689 = _slang_select(_S688, _S686,0.0f);
    return _S689;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_3, float3  v_5, float3  n_i_7, BSDFMaterial material_11, Weights w_9)
{
    float3  _S690 = l_3 + v_5;
    float3  _S691 = ((((_S690)) * make_float3(rnorm3df(((_S690)).x, ((_S690)).y, ((_S690)).z))));
    float _S692 = dot_0(n_i_7, _S691);
    float _S693 = (F32_max((dot_0(n_i_7, l_3)), (0.0f)));
    float _S694 = (F32_max((dot_0(n_i_7, v_5)), (0.0f)));
    float _S695 = 1.0f / (F32_max((material_11.sheen_roughness), (0.05000000074505806f)));
    float _S696 = 1.0f - _S692 * _S692;
    float _S697 = (2.0f + _S695) * (F32_pow(((F32_max((_S696), (0.0f)))), (0.5f * _S695))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S693 + _S694 - _S693 * _S694)), (0.0000152587890625f)));
    bool _S698 = (material_11.velvet) > 0.0f;
    float f_1;
    if(_S698)
    {
        float _S699 = (F32_max((material_11.sheen_roughness), (0.00999999977648258f)));
        float _S700 = _S699 * _S699;
        float _S701 = (F32_max((_S696), (0.0000152587890625f)));
        float _S702 = (F32_exp((- _S692 * _S692 / (_S701 * _S700)))) / (3.14159274101257324f * _S700 * _S701 * _S701) * (F32_min((1.0f), (2.0f * _S692 * (F32_min((_S693), (_S694))) / (F32_max(((F32_abs((dot_0(_S691, v_5))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S693 * _S694), (0.0000152587890625f)));
        f_1 = _S702;
    }
    else
    {
        f_1 = _S697;
    }
    return w_9.sheen * make_float3 (f_1 * _S693 * 2.0f * 3.14159274101257324f / w_9.p_sheen_velvet);
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
    float _S703;
    if(t_13 < a_3)
    {
        _S703 = 1.0f;
    }
    else
    {
        _S703 = (F32_max((1.0f - (t_13 - a_3) / (F32_max((s_0), (0.0000152587890625f)))), (0.0f)));
    }
    return _S703;
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
        float _S704 = (F32_sin(((F32_min((t_14), (a_4))))));
        integral_0 = _S704 * _S704 / 2.0f;
    }
    bool _S705 = t_14 > a_4;
    bool _S706;
    if(_S705)
    {
        _S706 = s_1 > 0.0f;
    }
    else
    {
        _S706 = false;
    }
    if(_S706)
    {
        float _S707;
        if(glossy_0)
        {
            float _S708 = (F32_cos((a_4)));
            float _S709 = (F32_cos((t_14)));
            _S707 = (1.0f + a_4 / s_1) * (_S708 - _S709) - ((F32_sin((t_14))) - t_14 * _S709 - ((F32_sin((a_4))) - a_4 * _S708)) / s_1;
        }
        else
        {
            float _S710 = 2.0f * a_4;
            float _S711 = (F32_cos((_S710)));
            float _S712 = 2.0f * t_14;
            float _S713 = (F32_cos((_S712)));
            _S707 = (1.0f + a_4 / s_1) * (_S711 - _S713) / 4.0f - ((F32_sin((_S712))) / 8.0f - t_14 * _S713 / 4.0f - ((F32_sin((_S710))) / 8.0f - a_4 * _S711 / 4.0f)) / s_1;
        }
        float integral_1 = integral_0 + _S707;
        integral_0 = integral_1;
    }
    return integral_0;
}

static __device__ ToonProfile ToonProfile_x24init_0(bool glossy_1, float a_5, float s_2, float b_1, float norm_0, float view_0, float3  axis_0)
{
    ToonProfile _S714;
    (&_S714)->glossy = glossy_1;
    (&_S714)->a = a_5;
    (&_S714)->s = s_2;
    (&_S714)->b = b_1;
    (&_S714)->norm = norm_0;
    (&_S714)->view = view_0;
    (&_S714)->axis = axis_0;
    return _S714;
}

__device__ __forceinline__ ToonProfile toonProfile(float3  v_6, float3  n_i_8, BSDFMaterial material_12)
{
    float _S715 = material_12.toon.x;
    bool _S716 = _S715 < 0.0f;
    float _S717 = clamp_1(material_12.toon.y / _S715, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S718 = clamp_1(material_12.toon.z / _S715, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S719 = (F32_min((_S717 + _S718), (1.57079637050628662f)));
    float _S720 = dot_0(n_i_8, v_6);
    float _S721 = toonP((F32_acos(((F32_min((_S720), (1.0f)))))), _S717, _S718);
    float3  _S722;
    if(_S716)
    {
        float3  _S723 = make_float3 (2.0f * _S720) * n_i_8 - v_6;
        float3  _S724 = ((((_S723)) * make_float3(rnorm3df(((_S723)).x, ((_S723)).y, ((_S723)).z))));
        _S722 = _S724;
    }
    else
    {
        _S722 = n_i_8;
    }
    float _S725 = toonIntegral(_S719, _S717, _S718, _S716);
    return ToonProfile_x24init_0(_S716, _S717, _S718, _S719, 6.28318548202514648f * _S725, _S721, _S722);
}

__device__ __forceinline__ float toonPDF(float3  l_4, float3  n_i_9, ToonProfile profile_1, Weights w_10)
{
    float _S726 = dot_0(n_i_9, l_4);
    float _S727 = dot_0(l_4, profile_1.axis);
    float _S728 = _slang_select(profile_1.glossy, _S727,_S726);
    float _S729 = (F32_acos((clamp_1(_S728, -1.0f, 1.0f))));
    float _S730 = toonP(_S729, profile_1.a, profile_1.s);
    float _S731 = w_10.p_toon * _S730;
    float _S732 = _slang_select(profile_1.glossy, 1.0f,_S726);
    float _S733 = _S731 * _S732 / profile_1.norm;
    bool _S734;
    if(profile_1.glossy)
    {
        _S734 = true;
    }
    else
    {
        _S734 = _S726 > 0.0f;
    }
    float _S735 = _slang_select(_S734, _S733,0.0f);
    return _S735;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_5, float3  n_i_10, ToonProfile profile_2, Weights w_11)
{
    float _S736 = (F32_max((dot_0(n_i_10, l_5)), (0.0f)));
    float _S737 = _slang_select(profile_2.glossy, _S736,profile_2.view);
    return w_11.toon * make_float3 (_S737) / make_float3 (w_11.p_toon);
}

__device__ __forceinline__ float coatPDF(float3  v_7, float3  coat_h_2, CoatFrame coat_frame_3, Weights w_12)
{
    float _S738 = dot_0(coat_frame_3.normal, v_7);
    float _S739 = smithG1(coat_frame_3.alpha, _S738);
    float _S740 = trowbridgeReitz(coat_frame_3.alpha, dot_0(coat_frame_3.normal, coat_h_2));
    float _S741 = _S739 * _S740 / (4.0f * _S738);
    bool _S742 = (coat_frame_3.alpha) > 0.0f;
    float _S743 = _slang_select(_S742, _S741,0.0f);
    return w_12.p_coat * _S743;
}

__device__ __forceinline__ float3  coatBSDF(Weights w_13)
{
    return w_13.coat / make_float3 (w_13.p_coat);
}

__device__ __forceinline__ void BSDF(float3  in_dir_2, float3  out_dir_0, float3  n_6, BSDFMaterial material_13, float eta_i_4, float eta_o_3, bool refracted_2, Facets facets_0, FixedArray<float3 , 6>  * throughputs_0, FixedArray<float, 6>  * pdfs_0)
{
    float3  _S744 = negate_0(in_dir_2);
    float _S745 = dot_0(n_6, _S744);
    float _S746 = sign_0(_S745);
    float3  _S747 = n_6 * make_float3 (_S746);
    float _S748 = dot_0(_S747, out_dir_0);
    float _S749 = material_13.roughness;
    float _S750 = _S749 * _S749;
    AnisotropicFrame _S751 = anisotropicFrame(material_13, _S747);
    SheenProfile _S752 = sheenProfile(_S744, _S747, material_13);
    CoatFrame _S753 = coatFrame(material_13, _S747);
    float3  _S754 = coatSeries(_S753, material_13);
    float _S755 = rgb_to_greyscale(material_13.translucent);
    bool _S756 = _S755 > 0.0f;
    bool _S757 = (dot_0(n_6, out_dir_0) * _S745) < 0.0f;
    bool _S758 = (F32_abs((material_13.toon.x))) > 0.0f;
    float3  _S759 = facets_0.coat_h;
    bool _S760 = (dot_0(_S759, _S759)) > 0.0f;
    bool _S761;
    if(_S756)
    {
        _S761 = _S757;
    }
    else
    {
        _S761 = false;
    }
    bool _S762 = _S761 == refracted_2;
    bool _S763 = !refracted_2;
    if(_S763)
    {
        _S761 = _S758;
    }
    else
    {
        _S761 = false;
    }
    bool _S764;
    if(_S763)
    {
        _S764 = _S760;
    }
    else
    {
        _S764 = false;
    }
    float3  _S765 = negate_0(make_float3 (eta_i_4) * _S744 + make_float3 (eta_o_3) * out_dir_0);
    float3  _S766 = ((((_S765)) * make_float3(rnorm3df(((_S765)).x, ((_S765)).y, ((_S765)).z))));
    float3  _S767 = _S744 + out_dir_0;
    float3  _S768 = ((((_S767)) * make_float3(rnorm3df(((_S767)).x, ((_S767)).y, ((_S767)).z))));
    float _S769 = sign_0(dot_0(_S766, _S747));
    float3  _S770 = _S766 * make_float3 (_S769);
    float3  _S771 = _slang_select(refracted_2, _S770,_S768);
    float3  _S772 = make_float3 (0.0f);
    float3  _S773 = ((((_S767)) * make_float3(rnorm3df(((_S767)).x, ((_S767)).y, ((_S767)).z))));
    float3  _S774 = _slang_select(_S764, _S773,_S772);
    Weights _S775 = lobeWeights(in_dir_2, _S744, _S747, facets_0.h, facets_0.coat_h, _S771, _S774, _S751, _S752, _S753, _S754, material_13, eta_i_4, eta_o_3);
    float _S776 = (F32_abs((_S745)));
    float _S777 = diffusePDF(_S748, _S776, material_13, _S775);
    float _S778 = _slang_select(_S762, _S777,0.0f);
    (*pdfs_0)[int(0)] = _S778;
    float3  _S779 = diffuseBSDF(out_dir_0, _S747, material_13, _S775);
    float3  _S780 = _slang_select(_S762, _S779,_S772);
    (*throughputs_0)[int(0)] = _S780;
    float _S781 = vndfPDF(_S744, _S771, _S747, _S776, _S750, _S751, _S775.v_dot_h);
    float _S782 = refractPDF(dot_0(out_dir_0, _S771), _S781, _S775, eta_i_4, eta_o_3);
    float _S783 = _slang_select(refracted_2, _S782,0.0f);
    (*pdfs_0)[int(1)] = _S783;
    float3  _S784 = refractBSDF(out_dir_0, _S747, _S750, _S751, material_13, _S775);
    float3  _S785 = _slang_select(refracted_2, _S784,_S772);
    (*throughputs_0)[int(1)] = _S785;
    float _S786 = reflectPDF(_S781, _S775);
    float _S787 = _slang_select(_S763, _S786,0.0f);
    (*pdfs_0)[int(2)] = _S787;
    float3  _S788 = reflectBSDF(out_dir_0, _S747, _S750, _S751, _S775);
    float3  _S789 = _slang_select(_S763, _S788,_S772);
    (*throughputs_0)[int(2)] = _S789;
    float _S790 = sheenVelvetPDF(_S748, _S776, _S775);
    float _S791 = _slang_select(_S763, _S790,0.0f);
    (*pdfs_0)[int(3)] = _S791;
    float3  _S792 = sheenVelvetBSDF(out_dir_0, _S744, _S747, material_13, _S775);
    float3  _S793 = _slang_select(_S763, _S792,_S772);
    (*throughputs_0)[int(3)] = _S793;
    ToonProfile _S794 = toonProfile(_S744, _S747, material_13);
    float _S795 = toonPDF(out_dir_0, _S747, _S794, _S775);
    float _S796 = _slang_select(_S761, _S795,0.0f);
    (*pdfs_0)[int(4)] = _S796;
    float3  _S797 = toonBSDF(out_dir_0, _S747, _S794, _S775);
    float3  _S798 = _slang_select(_S761, _S797,_S772);
    (*throughputs_0)[int(4)] = _S798;
    float _S799 = coatPDF(_S744, _S774, _S753, _S775);
    float _S800 = _slang_select(_S764, _S799,0.0f);
    (*pdfs_0)[int(5)] = _S800;
    float3  _S801 = coatBSDF(_S775);
    float3  _S802 = _slang_select(_S764, _S801,_S772);
    (*throughputs_0)[int(5)] = _S802;
    return;
}

static __device__ __forceinline__ float3  skyLobes_0(float3  in_dir_3, float3  dir_3, FKSurface * surface_1, BSDFMaterial * material_14, float2  eta_1, bool is_inside_2, Facets * facets_1, float pdf_0, FixedArray<float3 , 6>  * terms_0, FixedArray<float, 6>  * pdfs_1)
{
    bool _S803 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    BSDF(in_dir_3, dir_3, surface_1->smooth_n, *material_14, eta_1.x, eta_1.y, _S803, *facets_1, terms_0, pdfs_1);
    float3  _S804 = make_float3 (0.0f);
    uint i_9 = 0U;
    float3  f_2 = _S804;
    for(;;)
    {
        if(i_9 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S805 = ((*pdfs_1)[i_9]) > 0.0f;
        if(_S805)
        {
            float3  _S806 = (*terms_0)[i_9] * make_float3 ((*pdfs_1)[i_9]) / make_float3 ((*pdfs_1)[i_9] + pdf_0);
            (*terms_0)[i_9] = _S806;
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
    SkySample _S807;
    (&_S807)->dir = dir_4;
    (&_S807)->radiance = radiance_0;
    (&_S807)->color = color_0;
    (&_S807)->random_state = random_state_2;
    return _S807;
}

static __device__ __noinline__ float3  skyColor_0(float3  dir_5, FixedArray<float3 , 6>  * terms_1, FixedArray<float, 6>  * pdfs_2, uint depth_0)
{
    float3  _S808 = make_float3 (0.0f);
    bool shaded_0 = false;
    float3  world_0 = _S808;
    uint i_11 = 0U;
    float3  color_1 = _S808;
    for(;;)
    {
        if(i_11 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S809 = ((*pdfs_2)[i_11]) > 0.0f;
        if(_S809)
        {
            bool _S810 = (fcptWorldReadsPath());
            bool _S811;
            if(_S810)
            {
                _S811 = true;
            }
            else
            {
                _S811 = !shaded_0;
            }
            bool shaded_1;
            float3  world_1;
            if(_S811)
            {
                uint _S812;
                if(i_11 == 3U)
                {
                    _S812 = 4U;
                }
                else
                {
                    if(i_11 == 4U)
                    {
                        _S812 = 6U;
                    }
                    else
                    {
                        if(i_11 == 5U)
                        {
                            _S812 = 5U;
                        }
                        else
                        {
                            _S812 = i_11;
                        }
                    }
                }
                float3  _S813 = (fcptEnvMapSample((dir_5), (depth_0), (_S812)));
                world_1 = _S813;
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
    uint2  _S814 = (fcptEnvironmentCdfSize());
    uint2  _S815 = make_uint2 (1U, 0U);
    uint2  _S816 = _S814 - _S815;
    Random _S817 = draw(init_random_state_0, 6U);
    Random _S818 = draw(init_random_state_0, 2147483654U);
    Random _S819 = draw(init_random_state_0, 7U);
    Random _S820 = draw(init_random_state_0, 2147483655U);
    uint _S821 = _S816.x;
    uint _S822 = searchCDF_0(make_uint2 (_S821, 0U), make_uint2 (0U, 1U), _S816.y, _S817.value);
    uint _S823 = searchCDF_0(make_uint2 (0U, _S822), _S815, _S821, _S818.value);
    float2  _S824 = make_float2 ((float)_S816.x, (float)_S816.y);
    float2  _S825 = (make_float2 (float(_S823), float(_S822)) + make_float2 (_S819.value, _S820.value)) / _S824 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S826 = _S825.y;
    float _S827 = (F32_sin((_S826)));
    float _S828 = _S825.x;
    float3  _S829 = make_float3 (- _S827 * (F32_cos((_S828))), _S827 * (F32_sin((_S828))), (F32_cos((_S826))));
    float _S830 = environmentPdf_0(_S829);
    BSDFMaterial _S831 = pathMaterial(surface_2->material, wavelength_3);
    BSDFMaterial _S832 = _S831;
    FixedArray<float3 , 6>  terms_2;
    FixedArray<float, 6>  pdfs_3;
    float3  _S833 = skyLobes_0(ray_0->unit_direction, _S829, surface_2, &_S832, eta_2, is_inside_3, facets_2, _S830, &terms_2, &pdfs_3);
    bool _S834 = !(_S830 > 0.0f);
    bool _S835;
    if(_S834)
    {
        _S835 = true;
    }
    else
    {
        _S835 = all_1(_S833 == make_float3 (0.0f));
    }
    if(_S835)
    {
        float3  _S836 = make_float3 (0.0f);
        return SkySample_x24init_0(_S829, _S836, _S836, _S820.state);
    }
    bool _S837 = (fcptWorldReadsPath());
    float3  seen_0;
    if(_S837)
    {
        uint _S838 = context_2->depth + 1U;
        FixedArray<float3 , 6>  _S839 = terms_2;
        FixedArray<float, 6>  _S840 = pdfs_3;
        float3  _S841 = skyColor_0(_S829, &_S839, &_S840, _S838);
        seen_0 = _S841;
    }
    else
    {
        seen_0 = _S833;
    }
    float3  _S842 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S829, context_2, _S820.state);
    return SkySample_x24init_0(_S829, _S842, seen_0 * _S842, _S820.state);
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
    SampleBSDF _S843 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_4), (light_1->dir)));
    float3  _S844 = _S843.throughput * make_float3 (_S843.pdf);
    float _S845 = light_1->density;
    float _S846 = 1.0f + _S843.pdf * _S843.pdf / (light_1->density * light_1->density);
    bool _S847;
    if(competing_0)
    {
        _S847 = _S845 > 0.0f;
    }
    else
    {
        _S847 = false;
    }
    float _S848 = _slang_select(_S847, _S846,1.0f);
    return _S844 / make_float3 (_S848) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_3)
{
    TreeSample _S849;
    (&_S849)->dir = dir_6;
    (&_S849)->radiance = radiance_1;
    (&_S849)->density = density_0;
    (&_S849)->random_state = random_state_3;
    return _S849;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_4, float * pick_0, float * probability_3)
{
    float _S850 = importance(first_1, p_12, normal_4);
    float _S851 = importance(second_1, p_12, normal_4);
    float2  _S852 = make_float2 (_S850, _S851);
    bool _S853 = _S850 == 0.0f;
    bool _S854;
    if(_S853)
    {
        _S854 = _S851 == 0.0f;
    }
    else
    {
        _S854 = false;
    }
    if(_S854)
    {
        return 2U;
    }
    float _S855 = _S850 + _S851;
    bool _S856 = _S851 > 0.0f;
    if(_S856)
    {
        _S854 = (*pick_0 * _S855) >= _S850;
    }
    else
    {
        _S854 = false;
    }
    uint _S857 = uint(_S854);
    float _S858 = (F32_min(((*pick_0 * _S855 - float(_S857) * _S850) / _slang_vector_get_element(_S852, _S857)), (0.99999994039535522f)));
    *pick_0 = _S858;
    float _S859 = *probability_3 * (_slang_vector_get_element(_S852, _S857) / _S855);
    *probability_3 = _S859;
    return _S857;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S860 = center_1 - p_13;
    float _S861 = radius_1 * radius_1 / dot_0(_S860, _S860);
    float _S862 = u1_0 * _S861 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S861), (0.0f)))))));
    float _S863 = 2.0f * u1_0;
    bool _S864 = _S861 >= 1.0f;
    float _S865 = _slang_select(_S864, _S863,_S862);
    float _S866 = (F32_sqrt(((F32_max((_S865 * (2.0f - _S865)), (0.0f))))));
    float _S867 = 6.28318548202514648f * u2_0;
    float3  _S868 = make_float3 (_S866 * (F32_cos((_S867))), 1.0f - _S865, _S866 * (F32_sin((_S867))));
    float3  _S869 = ((((_S860)) * make_float3(rnorm3df(((_S860)).x, ((_S860)).y, ((_S860)).z))));
    float3  _S870 = tangentToWorld(_S868, _S869);
    return _S870;
}

__device__ float3  pointLightRadiance(float3  color_3, float intensity_0, float radius_2)
{
    return color_3 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S871 = center_2 - ray_1->origin;
    float _S872 = dot_0(_S871, ray_1->unit_direction);
    float _S873 = dot_0(_S871, _S871) - _S872 * _S872;
    float _S874 = radius_3 * radius_3;
    bool _S875 = _S873 > _S874;
    if(_S875)
    {
        return 4.294967296e+09f;
    }
    float _S876 = (F32_sqrt((_S874 - _S873)));
    float _S877 = _S872 - _S876;
    float _S878 = _S872 + _S876;
    bool _S879 = _S877 > 0.0000152587890625f;
    bool _S880;
    if(_S879)
    {
        _S880 = _S877 < max_len_0;
    }
    else
    {
        _S880 = false;
    }
    if(_S880)
    {
        return _S877;
    }
    bool _S881 = _S878 > 0.0000152587890625f;
    if(_S881)
    {
        _S880 = _S878 < max_len_0;
    }
    else
    {
        _S880 = false;
    }
    if(_S880)
    {
        return _S878;
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
    Random _S882 = draw(init_random_state_1, 4U);
    Random _S883 = draw(init_random_state_1, 5U);
    Random _S884 = draw(init_random_state_1, 2147483653U);
    float3  _S885 = make_float3 (0.0f);
    TreeSample _S886 = TreeSample_x24init_0(_S885, _S885, 0.0f, _S884.state);
    TreeSample sample_0 = _S886;
    float3  _S887 = _slang_select(sided_0, _S885,smooth_n_2);
    float3  _S888 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S882.value;
    float probability_4 = 1.0f;
    uint n_7 = 0U;
    for(;;)
    {
        uint4  _S889 = (fcptLightNode((n_7)));
        if((_S889.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S890 = (fcptLightSecond((n_7)));
        uint _S891 = n_7 + 1U;
        LightNode _S892 = (fcptLightBounds((_S891)));
        LightNode _S893 = (fcptLightBounds((_S890)));
        uint _S894 = pickChild(_S892, _S893, origin_4, _S887, &pick_1, &probability_4);
        bool _S895 = _S894 > 1U;
        if(_S895)
        {
            return sample_0;
        }
        bool _S896 = _S894 == 1U;
        uint _S897 = _slang_select(_S896, _S890,_S891);
        n_7 = _S897;
    }
    bool _S898 = n_7 == 0U;
    bool _S899;
    if(_S898)
    {
        LightNode _S900 = (fcptLightBounds((0U)));
        float _S901 = importance(_S900, origin_4, _S887);
        _S899 = !(_S901 > 0.0f);
    }
    else
    {
        _S899 = false;
    }
    if(_S899)
    {
        return sample_0;
    }
    uint4  _S902 = (fcptLightNode((n_7)));
    FKHit _S903 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S904 = (_S902.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S904)
    {
        FKLight _S905 = (fcptLight((_S902.y)));
        if(sided_0)
        {
            float _S906 = sign_0(dot_0(geometry_n_1, _S905.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S906);
            float3  _S907 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S907;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S888;
            lift_n_0 = smooth_n_2;
        }
        bool _S908 = (_S905.variance) == 0.0f;
        if(_S908)
        {
            float3  _S909 = _S905.position - emitter_point_0;
            float3  _S910 = ((((_S909)) * make_float3(rnorm3df(((_S909)).x, ((_S909)).y, ((_S909)).z))));
            (&sample_0)->dir = _S910;
            float3  _S911 = _S905.color * make_float3 (_S905.intensity) / make_float3 (dot_0(_S909, _S909) * probability_4);
            (&sample_0)->radiance = _S911;
            shadow_1 = _S909;
        }
        else
        {
            float3  _S912 = sampleSphere(_S905.position, _S905.variance, emitter_point_0, _S883.value, _S884.value);
            (&sample_0)->dir = _S912;
            float _S913 = sphereDensity(_S905.position, _S905.variance, emitter_point_0);
            float _S914 = probability_4 * _S913;
            (&sample_0)->density = _S914;
            float3  _S915 = pointLightRadiance(_S905.color, _S905.intensity, _S905.variance);
            float3  _S916 = _S915 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S916;
            FKRay _S917 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S918 = raySphere_0(_S905.position, _S905.variance, &_S917, 4.294967296e+09f);
            float3  _S919 = (&sample_0)->dir * make_float3 (_S918);
            shadow_1 = _S919;
        }
        emitter_0 = _S903;
        emitter_point_0 = _S885;
    }
    else
    {
        uint _S920 = _S902.y;
        uint _S921 = (fcptTriangleOffset((_S920)));
        uint _S922 = _S921 + _S902.z;
        Matrix<float, 3, 3>  _S923 = (fcptWorldTriangle((_S920), (_S922)));
        float _S924 = (F32_sqrt((_S883.value)));
        float2  _S925 = make_float2 (_S924 * (1.0f - _S884.value), _S924 * _S884.value);
        float3  _S926 = mul_0(make_float3 (1.0f - _S924, _S925.x, _S925.y), _S923);
        if(sided_0)
        {
            float _S927 = sign_0(dot_0(geometry_n_1, _S926 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S927);
            float3  _S928 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S928;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S929 = !((dot_0(smooth_n_2, _S926 - origin_4)) > 0.0f);
            if(_S929)
            {
                return sample_0;
            }
            emitter_point_0 = _S888;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S925, _S920, _S922, 0U, 0.0f);
        float3  _S930 = _S926 - emitter_point_0;
        float3  _S931 = ((((_S930)) * make_float3(rnorm3df(((_S930)).x, ((_S930)).y, ((_S930)).z))));
        (&sample_0)->dir = _S931;
        float _S932 = solidAngle(probability_4, cross_0(_S923.rows[int(1)] - _S923.rows[int(0)], _S923.rows[int(2)] - _S923.rows[int(0)]), _S930);
        (&sample_0)->density = _S932;
        bool _S933 = (fcptShadowFirst());
        bool _S934 = !_S933;
        if(_S934)
        {
            FKSurface _S935 = (fcptLightSurfaceAt((emitter_1), (_S926), (_S884.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S926 - origin_4))));
            (&sample_0)->random_state = _S935.random_state;
            float3  _S936 = _slang_select(_S935.skip, _S885,_S935.material.emissive);
            float3  _S937 = _S936 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S937;
        }
        shadow_1 = _S930;
        emitter_0 = emitter_1;
        emitter_point_0 = _S926;
    }
    FKHit _S938 = emitter_0;
    float3  _S939 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S884.state, &_S938);
    bool _S940 = (fcptShadowFirst());
    if(_S940)
    {
        _S899 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S899 = false;
    }
    if(_S899)
    {
        _S899 = !all_1(_S939 == _S885);
    }
    else
    {
        _S899 = false;
    }
    if(_S899)
    {
        FKSurface _S941 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S884.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S941.random_state;
        float3  _S942 = _slang_select(_S941.skip, _S885,_S941.material.emissive);
        float3  _S943 = _S942 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S943;
    }
    float3  _S944 = (&sample_0)->radiance * _S939;
    bool _S945 = all_1(_S939 == _S885);
    float3  _S946 = _slang_select(_S945, _S885,_S944);
    (&sample_0)->radiance = _S946;
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
    float _S947 = 1.0f / (1.0f + b_2 / a_6 * (b_2 / a_6));
    bool _S948 = b_2 > 0.0f;
    float _S949 = _slang_select(_S948, _S947,1.0f);
    return _S949;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S950 = vertex_0->none;
    if(_S950)
    {
        return 1.0f;
    }
    uint _S951 = (fcptLightSlot((*hit_1)));
    float _S952 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S951, light_point_1);
    float _S953 = powerHeuristic(vertex_0->pdf, _S952);
    return _S953;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_1, uint lobe_0)
{
    uint2  _S954 = (fcptEnvironmentMapSize());
    bool _S955 = (_S954.x) > 1U;
    bool _S956;
    if(_S955)
    {
        uint2  _S957 = (fcptEnvironmentMapSize());
        _S956 = (_S957.y) > 1U;
    }
    else
    {
        _S956 = false;
    }
    if(_S956)
    {
        float3  _S958 = (fcptEnvMapSample((dir_7), (depth_1), (lobe_0)));
        return _S958;
    }
    float3  _S959 = (fcptAmbient());
    return _S959;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S960 = (fcptEnvironmentCdfSize());
    bool _S961 = (_S960.x) > 1U;
    bool _S962;
    if(_S961)
    {
        uint2  _S963 = (fcptEnvironmentCdfSize());
        _S962 = (_S963.y) > 1U;
    }
    else
    {
        _S962 = false;
    }
    bool _S964 = !_S962;
    if(_S964)
    {
        return false;
    }
    uint2  _S965 = (fcptEnvironmentMapSize());
    bool _S966 = (_S965.x) > 1U;
    if(_S966)
    {
        uint2  _S967 = (fcptEnvironmentMapSize());
        _S962 = (_S967.y) > 1U;
    }
    else
    {
        _S962 = false;
    }
    return _S962;
}

static __device__ float escapeWeight_0(float pdf_1, float3  dir_8)
{
    bool _S968 = pdf_1 <= 0.0f;
    bool _S969;
    if(_S968)
    {
        _S969 = true;
    }
    else
    {
        bool _S970 = environmentMapped_0();
        _S969 = !_S970;
    }
    if(_S969)
    {
        return 1.0f;
    }
    float _S971 = environmentPdf_0(dir_8);
    return pdf_1 / (pdf_1 + _S971);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S972 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S973 = make_int2 ((int)_S972.x, (int)_S972.y);
    uint _S974 = previousSeed_0(_S973);
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
            uint _S975 = previousSeed_0(_S973 + make_int2 (x_16, y_5));
            bool _S976 = _S975 == _S974;
            uint _S977 = _slang_select(_S976, 1U,0U);
            uint count_3 = count_2 + _S977;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S978 = float(count_2 - 1U) / 288.0f;
    bool _S979 = _S974 != 0U;
    float _S980 = _slang_select(_S979, _S978,0.0f);
    fcptStoreDuplication((_S973), (make_uint4 ((F32_asuint((_S980))), 0U, 0U, 0U)));
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
    float _S981 = rgb_to_greyscale(abs_0(f_4));
    return _S981;
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
    float _S982 = resamplingTarget(weight_0);
    bool _S983 = _S982 > 0.0f;
    bool _S984;
    if(_S983)
    {
        _S984 = _S982 < 3.00000000549775576e+38f;
    }
    else
    {
        _S984 = false;
    }
    bool _S985 = !_S984;
    if(_S985)
    {
        return;
    }
    bool _S986 = sel_2->sums;
    if(_S986)
    {
        float3  _S987 = sel_2->color + weight_0;
        sel_2->color = _S987;
        return;
    }
    float _S988 = sel_2->w_sum + _S982;
    sel_2->w_sum = _S988;
    float3  _S989 = sel_2->color + weight_0;
    sel_2->color = _S989;
    Random _S990 = pcg(sel_2->random_state);
    sel_2->random_state = _S990.state;
    bool _S991 = (_S990.value * sel_2->w_sum) <= _S982;
    if(_S991)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S992 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S992;
    float _S993 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S993;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S994 = resamplingTarget((&r_4)->f);
    float _S995 = sel_4.w_sum / _S994;
    bool _S996 = _S994 > 0.0f;
    float _S997 = _slang_select(_S996, _S995,0.0f);
    (&r_4)->w = _S997;
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
    uint2  _S998 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S999 = make_int2 ((int)_S998.x, (int)_S998.y);
    float3  _S1000 = make_float3 (0.0f);
    FKHit _S1001 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S1002 = Domain_x24init_0(_S1000, _S1000, &_S1001, 0.0f, 0.0f);
    Domain dom_4 = _S1002;
    bool _S1003 = (fcptCurrentDomain((_S999), (&dom_4)));
    bool _S1004 = !_S1003;
    if(_S1004)
    {
        Reservoir _S1005 = (Reservoir{});
        fcptStoreReservoirPrevious((_S999), (_S1005), ((&dom_4)->hit));
        return;
    }
    Reservoir _S1006 = (fcptLoadReservoirTemporal((_S999)));
    uint t_15 = 0U;
    float count_4 = 0.0f;
    float c_sum_0 = _S1006.c;
    for(;;)
    {
        uint _S1007 = (fcptRestirNeighbours());
        if(t_15 < _S1007)
        {
        }
        else
        {
            break;
        }
        int2  _S1008 = partner_0(_S999, t_15);
        Domain neighbor_0 = _S1002;
        bool _S1009 = (fcptCurrentDomain((_S1008), (&neighbor_0)));
        if(_S1009)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S1010 = (fcptReservoirTemporal((_S1008), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S1010.w)));
            count_4 = count_5;
            c_sum_0 = c_sum_1;
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    float _S1011 = _S1006.c / (F32_max((count_4), (1.0f)));
    float _S1012 = resamplingTarget(_S1006.f);
    bool _S1013 = count_4 == 0.0f;
    float _S1014 = _slang_select(_S1013, 1.0f,0.0f);
    Selection _S1015 = (Selection{});
    Selection sel_5 = _S1015;
    uint _S1016 = (fcptFrame());
    uint _S1017 = hash(_S1016);
    uint _S1018 = global_invocation_id_2.x;
    uint2  _S1019 = (fcptRenderSize());
    uint _S1020 = stream(_S1017, _S1018 + _S1019.x * global_invocation_id_2.y);
    uint _S1021 = stream(_S1020, 195U);
    (&sel_5)->random_state = _S1021;
    t_15 = 0U;
    float canonical_mis_0 = _S1014;
    for(;;)
    {
        uint _S1022 = (fcptRestirNeighbours());
        if(t_15 < _S1022)
        {
        }
        else
        {
            break;
        }
        int2  _S1023 = partner_0(_S999, t_15);
        Domain neighbor_dom_0 = _S1002;
        bool _S1024 = (fcptCurrentDomain((_S1023), (&neighbor_dom_0)));
        if(_S1024)
        {
            Reservoir _S1025 = (fcptLoadReservoirTemporal((_S1023)));
            uint4  _S1026 = (fcptShiftData((_S1023), (t_15)));
            float4  _S1027 = asfloat_0(_S1026);
            uint4  _S1028 = (fcptShiftData((_S999), (t_15)));
            float4  _S1029 = asfloat_0(_S1028);
            float _S1030 = (_S1025.c + _S1011) / c_sum_0;
            bool _S1031 = _S1012 > 0.0f;
            float canonical_mis_1;
            if(_S1031)
            {
                float _S1032 = _S1030 * _S1011 * _S1012;
                float _S1033 = _S1011 * _S1012;
                float _S1034 = resamplingTarget(float3 {_S1029.x, _S1029.y, _S1029.z});
                float canonical_mis_2 = canonical_mis_0 + _S1032 / (_S1033 + _S1025.c * _S1034);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S1035 = resamplingTarget(_S1025.f);
            float3  _S1036 = float3 {_S1027.x, _S1027.y, _S1027.z};
            Shift _S1037 = Shift_x24init_0(_S1036, _S1027.w);
            float _S1038 = _S1030 * _S1025.c * _S1035;
            float _S1039 = _S1025.c * _S1035;
            float _S1040 = resamplingTarget(_S1036);
            offerShifted(&sel_5, _S1025, _S1037, _S1038 / (_S1039 + _S1011 * _S1040));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_17 = t_15 + 1U;
        t_15 = t_17;
    }
    offerShifted(&sel_5, _S1006, Shift_x24init_0(_S1006.f, 1.0f), canonical_mis_0);
    Reservoir _S1041 = finalize(sel_5, c_sum_0);
    fcptStoreReservoirPrevious((_S999), (_S1041), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S999), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S999), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S1042 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S1043 = _S1042 != 4294967295U;
    if(_S1043)
    {
        uint2  _S1044 = make_uint2 (_S1042, _S1042 >> 14U) & make_uint2 (16383U);
        int2  _S1045 = make_int2 ((int)_S1044.x, (int)_S1044.y);
        ShiftJob _S1046 = (ShiftJob{});
        ShiftJob shift_job_0 = _S1046;
        Shift _S1047 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S1048 = _S1042 >> 28U;
        bool _S1049 = spatialJob_0(_S1045, _S1048, &shift_job_0, true);
        Shift shifted_1;
        if(_S1049)
        {
            Domain _S1050 = (&shift_job_0)->dom;
            Reservoir _S1051 = (&shift_job_0)->r;
            Shift _S1052 = passShift_0(&_S1050, &_S1051);
            shifted_1 = _S1052;
        }
        else
        {
            shifted_1 = _S1047;
        }
        fcptStoreShiftData((_S1045), (_S1048), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S1053 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S1054 = make_int2 ((int)_S1053.x, (int)_S1053.y);
    FixedArray<uint, 3>  _S1055;
    spatialBins_0(_S1054, &_S1055);
    FixedArray<uint, 3>  _S1056 = _S1055;
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
        bool _S1057 = (_S1056[t_18]) == 40U;
        if(_S1057)
        {
            fcptStoreShiftData((_S1054), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S1058 = _S1056;
    queueShifts_0(_S1054, &_S1058, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S1059 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S1060 = make_int2 ((int)_S1059.x, (int)_S1059.y);
    FixedArray<uint, 3>  _S1061;
    spatialBins_0(_S1060, &_S1061);
    FixedArray<uint, 3>  _S1062 = _S1061;
    countShifts_0(&_S1062, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S1063 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S1064 = _S1063 != 4294967295U;
    if(_S1064)
    {
        uint2  _S1065 = make_uint2 (_S1063, _S1063 >> 14U) & make_uint2 (16383U);
        int2  _S1066 = make_int2 ((int)_S1065.x, (int)_S1065.y);
        int2  _S1067 = (fcptLoadTemporalNeighbor((_S1066)));
        uint _S1068 = _S1063 >> 28U;
        Shift _S1069 = temporalShiftAt_0(_S1066, _S1067, _S1068);
        fcptStoreTemporalShift((_S1066), (_S1068), (make_uint4 (asuint_1(_S1069.f).x, asuint_1(_S1069.f).y, asuint_1(_S1069.f).z, (F32_asuint((_S1069.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S1070 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S1071 = make_int2 ((int)_S1070.x, (int)_S1070.y);
    FixedArray<uint, 3>  _S1072;
    temporalBins_0(_S1071, &_S1072);
    FixedArray<uint, 3>  _S1073 = _S1072;
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
        bool _S1074 = (_S1073[t_20]) == 40U;
        if(_S1074)
        {
            fcptStoreTemporalShift((_S1071), (t_20), (make_uint4 (0U)));
        }
        uint t_21 = t_20 + 1U;
        t_20 = t_21;
    }
    FixedArray<uint, 3>  _S1075 = _S1073;
    queueShifts_0(_S1071, &_S1075, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S1076 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S1077 = make_int2 ((int)_S1076.x, (int)_S1076.y);
    bool _S1078 = (fcptSceneUnchanged());
    bool _S1079 = !_S1078;
    bool _S1080;
    if(_S1079)
    {
        uint2  _S1081 = (fcptRenderSize());
        int2  _S1082 = make_int2 ((int)_S1081.x, (int)_S1081.y);
        _S1080 = all_0(_S1077 < _S1082);
    }
    else
    {
        _S1080 = false;
    }
    if(_S1080)
    {
        Reservoir _S1083 = (fcptLoadReservoirInitial((_S1077)));
        int2  _S1084 = sampleNeighbor_0(_S1077, _S1083.seed);
        fcptStoreTemporalNeighbor((_S1077), (_S1084));
    }
    FixedArray<uint, 3>  _S1085;
    temporalBins_0(_S1077, &_S1085);
    FixedArray<uint, 3>  _S1086 = _S1085;
    countShifts_0(&_S1086, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_7, float b_3, float t_22)
{
    return a_7 + (b_3 - a_7) * t_22;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S1087 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S1088 = make_int2 ((int)_S1087.x, (int)_S1087.y);
    float3  _S1089 = make_float3 (0.0f);
    FKHit _S1090 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S1091 = Domain_x24init_0(_S1089, _S1089, &_S1090, 0.0f, 0.0f);
    Domain dom_5 = _S1091;
    bool _S1092 = (fcptCurrentDomain((_S1088), (&dom_5)));
    bool _S1093 = !_S1092;
    if(_S1093)
    {
        Reservoir _S1094 = (Reservoir{});
        fcptStoreReservoirTemporal((_S1088), (_S1094), ((&dom_5)->hit));
        return;
    }
    Reservoir _S1095 = (fcptLoadReservoirInitial((_S1088)));
    bool _S1096 = (fcptTemporalQueued());
    bool _S1097 = (fcptSceneUnchanged());
    bool _S1098;
    if(_S1097)
    {
        _S1098 = true;
    }
    else
    {
        _S1098 = !_S1096;
    }
    int2  _S1099;
    if(_S1098)
    {
        int2  _S1100 = sampleNeighbor_0(_S1088, _S1095.seed);
        _S1099 = _S1100;
    }
    else
    {
        int2  _S1101 = (fcptLoadTemporalNeighbor((_S1088)));
        _S1099 = _S1101;
    }
    bool _S1102 = (_S1099.x) >= int(0);
    Reservoir r_5;
    if(_S1102)
    {
        Reservoir _S1103 = (fcptLoadReservoirPrevious((_S1099)));
        uint4  _S1104 = (fcptDuplication((_S1099)));
        float _S1105 = (U32_asfloat((_S1104.x)));
        uint _S1106 = (fcptRestirDecorrelation());
        bool _S1107 = _S1106 == 1U;
        float _S1108 = _slang_select(_S1107, _S1105,0.0f);
        float _S1109 = interpolate_0(20.0f, 1.0f, (F32_pow((_S1108), (0.10000000149011612f))));
        float _S1110 = (F32_min((_S1103.c), (_S1109)));
        bool _S1111 = (fcptSceneUnchanged());
        float4  _S1112 = make_float4 (_S1103.f.x, _S1103.f.y, _S1103.f.z, 1.0f);
        bool _S1113 = !_S1111;
        if(_S1113)
        {
            _S1098 = _S1096;
        }
        else
        {
            _S1098 = false;
        }
        float4  to_current_0;
        if(_S1098)
        {
            uint4  _S1114 = (fcptTemporalShift((_S1088), (0U)));
            float4  _S1115 = asfloat_0(_S1114);
            to_current_0 = _S1115;
        }
        else
        {
            if(_S1113)
            {
                Shift _S1116 = temporalShiftAt_0(_S1088, _S1099, 0U);
                float4  _S1117 = make_float4 (_S1116.f.x, _S1116.f.y, _S1116.f.z, _S1116.jac);
                to_current_0 = _S1117;
            }
            else
            {
                to_current_0 = _S1112;
            }
        }
        Domain own_1 = _S1091;
        if(_S1111)
        {
            _S1098 = true;
        }
        else
        {
            bool _S1118 = (fcptPreviousScenes());
            bool _S1119 = !_S1118;
            if(_S1119)
            {
                _S1098 = (_S1095.w) > 0.0f;
            }
            else
            {
                _S1098 = false;
            }
            if(_S1098)
            {
                bool _S1120 = (fcptStoredDomainInitial((_S1088), (_S1095.seed), (&own_1)));
                _S1098 = _S1120;
            }
            else
            {
                _S1098 = false;
            }
            if(_S1098)
            {
                Domain _S1121 = (fcptPreviousDomain((_S1099), (_S1095.seed)));
                Domain _S1122 = _S1121;
                Domain _S1123 = own_1;
                bool _S1124 = sameDomain_0(&_S1122, &_S1123);
                _S1098 = _S1124;
            }
            else
            {
                _S1098 = false;
            }
        }
        float4  _S1125 = make_float4 (_S1095.f.x, _S1095.f.y, _S1095.f.z, 1.0f);
        bool _S1126 = !_S1098;
        if(_S1126)
        {
            _S1098 = _S1096;
        }
        else
        {
            _S1098 = false;
        }
        float4  to_previous_0;
        if(_S1098)
        {
            uint4  _S1127 = (fcptTemporalShift((_S1088), (1U)));
            float4  _S1128 = asfloat_0(_S1127);
            to_previous_0 = _S1128;
        }
        else
        {
            if(_S1126)
            {
                Shift _S1129 = temporalShiftAt_0(_S1088, _S1099, 1U);
                float4  _S1130 = make_float4 (_S1129.f.x, _S1129.f.y, _S1129.f.z, _S1129.jac);
                to_previous_0 = _S1130;
            }
            else
            {
                to_previous_0 = _S1125;
            }
        }
        float _S1131 = resamplingTarget(_S1095.f);
        float _S1132 = resamplingTarget(_S1103.f);
        Selection _S1133 = (Selection{});
        Selection sel_6 = _S1133;
        uint _S1134 = (fcptFrame());
        uint _S1135 = hash(_S1134);
        uint _S1136 = global_invocation_id_7.x;
        uint2  _S1137 = (fcptRenderSize());
        uint _S1138 = stream(_S1135, _S1136 + _S1137.x * global_invocation_id_7.y);
        uint _S1139 = stream(_S1138, 194U);
        (&sel_6)->random_state = _S1139;
        float _S1140 = _S1095.c * _S1131;
        float4  _S1141 = to_previous_0;
        float _S1142 = resamplingTarget(float3 {_S1141.x, _S1141.y, _S1141.z});
        float _S1143 = _S1140 / (_S1140 + _S1110 * _S1142);
        float _S1144 = _S1110 * _S1132;
        float4  _S1145 = to_current_0;
        float3  _S1146 = float3 {_S1145.x, _S1145.y, _S1145.z};
        float _S1147 = resamplingTarget(_S1146);
        float _S1148 = _S1144 / (_S1144 + _S1095.c * _S1147);
        float2  _S1149 = make_float2 (_S1143, _S1148);
        offerShifted(&sel_6, _S1095, Shift_x24init_0(_S1095.f, 1.0f), _S1143);
        offerShifted(&sel_6, _S1103, Shift_x24init_0(_S1146, to_current_0.w), _S1148);
        Reservoir _S1150 = finalize(sel_6, _S1095.c + _S1110);
        r_5 = _S1150;
    }
    else
    {
        r_5 = _S1095;
    }
    fcptStoreReservoirTemporal((_S1088), (r_5), ((&dom_5)->hit));
    return;
}

__device__ uint noiseOrigin(uint2  p_14, uint k_1)
{
    uint _S1151 = ((p_14.x) >> 11U) | (((p_14.y) >> 11U) << 4U);
    uint2  _S1152 = noiseOffset(8192U + (k_1 >> 10U) + (_S1151 << 20U));
    uint2  _S1153 = (p_14 + _S1152) & make_uint2 (2047U);
    return ((_S1153.x) | ((_S1153.y) << 11U)) | ((k_1 & 1023U) << 22U);
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1154 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1154 << offset_1))) | ((newbits_0 & _S1154) << offset_1);
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S1155 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S1156 = make_int2 ((int)_S1155.x, (int)_S1155.y);
    float3  _S1157 = make_float3 (0.0f);
    float2  _S1158 = make_float2 (0.0f);
    FKHit _S1159 = Hit_x24init_0(_S1158, 0U, 0U, 0U, 0.0f);
    Domain _S1160 = Domain_x24init_0(_S1157, _S1157, &_S1159, 0.0f, 0.0f);
    Domain dom_6 = _S1160;
    bool _S1161 = (fcptCurrentDomain((_S1156), (&dom_6)));
    bool _S1162 = !_S1161;
    if(_S1162)
    {
        Reservoir _S1163 = (Reservoir{});
        fcptStoreReservoirInitial((_S1156), (_S1163), ((&dom_6)->hit));
        return;
    }
    uint _S1164 = (fcptFrame());
    uint _S1165 = hash(_S1164);
    uint _S1166 = global_invocation_id_8.x;
    uint2  _S1167 = (fcptRenderSize());
    uint _S1168 = global_invocation_id_8.y;
    uint _S1169 = stream(_S1165, _S1166 + _S1167.x * _S1168);
    uint2  _S1170 = (fcptRenderSize());
    uint _S1171 = stream(_S1166 + _S1170.x * _S1168, 512U);
    Selection _S1172 = (Selection{});
    Selection initial_0 = _S1172;
    uint _S1173 = stream(_S1169, 193U);
    (&initial_0)->random_state = _S1173;
    bool _S1174 = (fcptRestirUsed());
    bool _S1175 = !_S1174;
    (&initial_0)->sums = _S1175;
    uint _S1176 = stream(_S1169, 0U);
    (&(&initial_0)->r)->seed = _S1176;
    FKHit _S1177 = Hit_x24init_0(_S1158, 4294967295U, 0U, 0U, 0.0f);
    uint _S1178 = (fcptSamples());
    float _S1179 = 1.0f / float(_S1178);
    FKHit hit_2 = _S1177;
    uint i_18 = 0U;
    float3  seen_1 = _S1157;
    for(;;)
    {
        uint _S1180 = (fcptSamples());
        if(i_18 < _S1180)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1181 = (Reservoir{});
        Reservoir r_6 = _S1181;
        uint _S1182 = (fcptFrame());
        uint _S1183 = (fcptSamples());
        uint _S1184 = _S1182 * _S1183 + i_18;
        uint _S1185 = noiseOrigin(_S1155, _S1184);
        (&r_6)->seed = _S1185;
        uint _S1186 = insertBits_0(0U, 1U, 24U, 1U);
        uint _S1187 = insertBits_0(_S1186, (_S1171 + _S1184 * 2654435769U) >> 25U, 25U, 7U);
        (&r_6)->path = _S1187;
        Domain path_0 = _S1160;
        bool _S1188 = (fcptStoredDomainInitial((_S1156), ((&r_6)->seed), (&path_0)));
        bool _S1189 = !_S1188;
        if(_S1189)
        {
            float3  _S1190 = (fcptMissed((_S1156), (path_0), (_S1179)));
            float3  seen_2 = seen_1 + _S1190;
            seen_1 = seen_2;
            uint i_19 = i_18 + 1U;
            i_18 = i_19;
            continue;
        }
        Domain _S1191 = path_0;
        Reservoir _S1192 = r_6;
        Shift _S1193 = passWalk_0(&_S1191, &_S1192, false, _S1179, &initial_0);
        bool _S1194 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1194)
        {
            FKHit _S1195 = (&path_0)->hit;
            hit_3 = _S1195;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_19 = i_18 + 1U;
        i_18 = i_19;
    }
    uint _S1196 = (fcptSamples());
    float3  seen_3 = seen_1 + (&initial_0)->glow / make_float3 (float(_S1196));
    if((&initial_0)->sums)
    {
        seen_1 = seen_3 + (&initial_0)->color;
    }
    else
    {
        seen_1 = seen_3;
    }
    fcptAddColor((_S1156), (make_float4 (seen_1.x, seen_1.y, seen_1.z, 1.0f)));
    Reservoir _S1197 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S1156), (_S1197), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_2, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1198;
    (&_S1198)->none = none_0;
    (&_S1198)->pdf = pdf_2;
    (&_S1198)->origin = origin_5;
    (&_S1198)->smooth_n = smooth_n_3;
    (&_S1198)->start = start_6;
    return _S1198;
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
    Vertex _S1199;
    (&_S1199)->rough = rough_0;
    (&_S1199)->lobe = lobe_1;
    (&_S1199)->pdf = pdf_3;
    (&_S1199)->cos = cos_0;
    (&_S1199)->inside = inside_0;
    return _S1199;
}

__device__ uint noiseAddress(uint origin_6, uint bounce_0)
{
    uint2  _S1200 = make_uint2 (origin_6 & 2047U, (origin_6 >> 11U) & 2047U);
    uint2  _S1201 = noiseOffset(64U + bounce_0 * 17U);
    uint2  _S1202 = (_S1200 + _S1201) & make_uint2 (2047U);
    return ((_S1202.x) | ((_S1202.y) << 11U)) | ((origin_6 >> 22U) << 22U);
}

__device__ float3  pathColor(float3  f_5, float3  weight_1, float wavelength_4)
{
    float3  _S1203;
    if(wavelength_4 > 0.0f)
    {
        float _S1204 = upsample(f_5, wavelength_4);
        _S1203 = weight_1 * make_float3 (_S1204);
    }
    else
    {
        _S1203 = f_5;
    }
    return _S1203;
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

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float distance_2, bool scatters_0)
{
    float3  _S1205 = exp_0(- scatter_0 * make_float3 (distance_2));
    float3  _S1206 = make_float3 (3.0f) * exp_0(- extinction_0 * make_float3 (distance_2));
    float3  _S1207 = _S1206 / make_float3 (_S1205.x + _S1205.y + _S1205.z);
    float3  _S1208 = scatter_0 * _S1206 / make_float3 (dot_0(scatter_0, _S1205));
    float3  _S1209 = _slang_select(scatters_0, _S1208,_S1207);
    return _S1209;
}

static __device__ uint arrivalLobe_0(uint b_4, uint prev_lobe_0)
{
    bool _S1210 = b_4 > 0U;
    uint _S1211 = _slang_select(_S1210, prev_lobe_0,3U);
    return _S1211;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_2, uint lobe_2, bool surface_4, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1212;
    (&_S1212)->extinction_behind = extinction_behind_0;
    (&_S1212)->extinction_front = extinction_front_0;
    (&_S1212)->fillings = fillings_0;
    (&_S1212)->side = side_0;
    (&_S1212)->depth = depth_2;
    (&_S1212)->lobe = lobe_2;
    (&_S1212)->surface = surface_4;
    (&_S1212)->length = length_2;
    (&_S1212)->width = width_1;
    (&_S1212)->own = *own_2;
    (&_S1212)->fiber = fiber_0;
    return _S1212;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1213 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1213)
    {
        return 0.07957746833562851f;
    }
    float _S1214 = g_0 * g_0;
    return (1.0f - _S1214) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1214 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_8, float3  b_5)
{
    float3  _S1215 = a_8 / b_5;
    float3  _S1216 = make_float3 (0.0f);
    bool3  _S1217 = b_5 == _S1216;
    float3  _S1218 = _slang_select(_S1217, _S1216,_S1215);
    return _S1218;
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_6)
{
    Reservoir candidate_2 = r_7;
    uint _S1219 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1220 = insertBits_0(_S1219, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1220;
    (&candidate_2)->f = f_6;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_4)
{
    Random _S1221 = draw(random_state_4, 11U);
    Random _S1222 = draw(random_state_4, 2147483659U);
    float _S1223 = 1.0f - 2.0f * _S1221.value;
    float _S1224 = (F32_sqrt(((F32_max((1.0f - _S1223 * _S1223), (0.0f))))));
    float _S1225 = 6.28318548202514648f * _S1222.value;
    return make_float3 (_S1224 * (F32_cos((_S1225))), _S1224 * (F32_sin((_S1225))), _S1223);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_5, float * pdf_4)
{
    bool _S1226 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1226)
    {
        *pdf_4 = 0.07957746833562851f;
        float3  _S1227 = isotropic_0(random_state_5);
        return _S1227;
    }
    Random _S1228 = draw(random_state_5, 11U);
    Random _S1229 = draw(random_state_5, 2147483659U);
    float _S1230 = g_1 * g_1;
    float _S1231 = 2.0f * g_1;
    float _S1232 = (1.0f - _S1230) / (1.0f - g_1 + _S1231 * _S1228.value);
    float _S1233 = clamp_1((1.0f + _S1230 - _S1232 * _S1232) / _S1231, -1.0f, 1.0f);
    float _S1234 = (F32_sqrt(((F32_max((1.0f - _S1233 * _S1233), (0.0f))))));
    float _S1235 = 6.28318548202514648f * _S1229.value;
    float _S1236 = phaseHG_0(g_1, _S1233);
    *pdf_4 = _S1236;
    float3  _S1237 = tangentToWorld(make_float3 (_S1234 * (F32_cos((_S1235))), _S1233, _S1234 * (F32_sin((_S1235)))), dir_9);
    float3  _S1238 = ((((_S1237)) * make_float3(rnorm3df(((_S1237)).x, ((_S1237)).y, ((_S1237)).z))));
    return _S1238;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_1, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_1, float velvet_0, float3  toon_2, float dispersion_0, float coat_2, float coat_roughness_0, float coat_ior_0, float3  coat_tint_0, float3  coat_normal_0)
{
    BSDFMaterial _S1239;
    (&_S1239)->albedo = albedo_1;
    (&_S1239)->emissive = emissive_0;
    (&_S1239)->roughness = roughness_0;
    (&_S1239)->metallic = metallic_0;
    (&_S1239)->transmission = transmission_0;
    (&_S1239)->ior = ior_1;
    (&_S1239)->absorption = absorption_0;
    (&_S1239)->specular_tint = specular_tint_0;
    (&_S1239)->specular_level = specular_level_0;
    (&_S1239)->translucent = translucent_0;
    (&_S1239)->sheen = sheen_2;
    (&_S1239)->sheen_roughness = sheen_roughness_0;
    (&_S1239)->anisotropy = anisotropy_0;
    (&_S1239)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1239)->tangent = tangent_1;
    (&_S1239)->velvet = velvet_0;
    (&_S1239)->toon = toon_2;
    (&_S1239)->dispersion = dispersion_0;
    (&_S1239)->coat = coat_2;
    (&_S1239)->coat_roughness = coat_roughness_0;
    (&_S1239)->coat_ior = coat_ior_0;
    (&_S1239)->coat_tint = coat_tint_0;
    (&_S1239)->coat_normal = coat_normal_0;
    return _S1239;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1240;
    (&_S1240)->scatter = scatter_1;
    (&_S1240)->extinction = extinction_1;
    (&_S1240)->g = g_2;
    return _S1240;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_15, bool skip_0, uint random_state_6, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1241;
    (&_S1241)->smooth_n = smooth_n_4;
    (&_S1241)->geometry_n = geometry_n_2;
    (&_S1241)->geometry_offset = geometry_offset_2;
    (&_S1241)->material = *material_15;
    (&_S1241)->skip = skip_0;
    (&_S1241)->random_state = random_state_6;
    (&_S1241)->coverage = coverage_0;
    (&_S1241)->encloses = encloses_0;
    (&_S1241)->volume = *volume_0;
    (&_S1241)->fills = fills_0;
    (&_S1241)->hair = hair_0;
    return _S1241;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S1242 = (&surface_5->material)->emissive;
    float3  _S1243 = make_float3 (0.0f);
    bool _S1244 = !top_0;
    float3  _S1245 = _slang_select(_S1244, _S1243,_S1242);
    (&(&lower_0)->material)->emissive = _S1245;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_1)
{
    float _S1246 = surface_6->coverage;
    bool _S1247 = u_1 < _S1246;
    if(_S1247)
    {
        return *surface_6;
    }
    float3  _S1248 = make_float3 (0.0f);
    float3  _S1249 = make_float3 (1.0f);
    BSDFMaterial _S1250 = Material_x24init_0(_S1248, _S1248, 0.0f, 0.0f, 0.0f, 0.0f, _S1248, _S1249, 1.0f, _S1248, _S1248, 0.5f, 0.0f, 0.0f, _S1248, 0.0f, _S1248, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, _S1249, _S1248);
    BSDFMaterial material_16 = _S1250;
    (&material_16)->albedo = _S1249;
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
    bool _S1251 = transmission_1 > 0.0f;
    bool _S1252;
    if(_S1251)
    {
        _S1252 = true;
    }
    else
    {
        _S1252 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1253;
    if(_S1252)
    {
        _S1253 = 1.0f;
    }
    else
    {
        _S1253 = -1.0f;
    }
    return _S1253;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_8)
{
    return (dot_0(dir_10, n_8)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_11)
{
    float3  _S1254 = surface_7->geometry_n;
    float _S1255 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_11);
    FKSurface faced_0 = *surface_7;
    float3  _S1256 = surface_7->smooth_n * make_float3 (_S1255);
    (&faced_0)->smooth_n = _S1256;
    float3  _S1257 = _S1254 * make_float3 (_S1255);
    (&faced_0)->geometry_n = _S1257;
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
    float3  _S1258 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1258));
}

__device__ bool dispersive(BSDFMaterial material_17)
{
    bool _S1259 = (material_17.dispersion) > 0.0f;
    bool _S1260;
    if(_S1259)
    {
        _S1260 = (material_17.ior) != 1.0f;
    }
    else
    {
        _S1260 = false;
    }
    return _S1260;
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
        uint _S1261 = (low_1 + high_1 + 1U) / 2U;
        bool _S1262 = (WAVELENGTH_CDF_0[_S1261]) <= u_2;
        if(_S1262)
        {
            low_1 = _S1261;
        }
        else
        {
            uint _S1263 = _S1261 - 1U;
            high_1 = _S1263;
        }
    }
    uint _S1264 = low_1;
    float _S1265 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_2 - WAVELENGTH_CDF_0[_S1264]) / _S1265), _S1265 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_5)
{
    float _S1266 = clamp_1((wavelength_5 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1267 = (U32_min((uint(_S1266)), (79U)));
    uint _S1268 = 3U * _S1267;
    float3  _S1269 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1268], WAVELENGTH_WEIGHTS_0[_S1268 + 1U], WAVELENGTH_WEIGHTS_0[_S1268 + 2U]);
    float3  _S1270 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1268 + 3U], WAVELENGTH_WEIGHTS_0[_S1268 + 4U], WAVELENGTH_WEIGHTS_0[_S1268 + 5U]);
    return _S1269 + (_S1270 - _S1269) * make_float3 (_S1266 - float(_S1267));
}

__device__ float dispersedIor(float ior_2, float dispersion_1, float wavelength_6)
{
    float _S1271 = (ior_2 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1272 = _S1271 * (1.0f / (wavelength_6 * wavelength_6) - 2.89662933349609375f);
    bool _S1273 = dispersion_1 > 0.0f;
    float _S1274 = _slang_select(_S1273, _S1272,0.0f);
    return ior_2 + _S1274;
}

__device__ float2  vertexEta(BSDFMaterial material_18, float n_dot_v_0)
{
    bool _S1275 = n_dot_v_0 < 0.0f;
    float _S1276 = _slang_select(_S1275, material_18.ior,1.0f);
    float _S1277 = _slang_select(_S1275, 1.0f,material_18.ior);
    return make_float2 (_S1276, _S1277);
}

__device__ float2  wavelengthEta(BSDFMaterial material_19, float n_dot_v_1, float wavelength_7)
{
    BSDFMaterial refractive_0 = material_19;
    float _S1278 = dispersedIor(material_19.ior, material_19.dispersion, wavelength_7);
    bool _S1279 = wavelength_7 > 0.0f;
    float _S1280 = _slang_select(_S1279, _S1278,material_19.ior);
    (&refractive_0)->ior = _S1280;
    float2  _S1281 = vertexEta(refractive_0, n_dot_v_1);
    return _S1281;
}

static __device__ float unshared_0(float x_25)
{
    return x_25;
}

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_6, float U1_0, float U2_0)
{
    float3  _S1282 = make_float3 (alpha_6 * Ve_0.x, alpha_6 * Ve_0.y, Ve_0.z);
    float3  _S1283 = ((((_S1282)) * make_float3(rnorm3df(((_S1282)).x, ((_S1282)).y, ((_S1282)).z))));
    float _S1284 = _S1283.x;
    float _S1285 = _S1283.y;
    float _S1286 = _S1284 * _S1284 + _S1285 * _S1285;
    float3  _S1287;
    if(_S1286 > 0.0f)
    {
        float3  _S1288 = make_float3 (- _S1285, _S1284, 0.0f);
        float _S1289 = (rsqrtf((_S1286)));
        _S1287 = _S1288 * make_float3 (_S1289);
    }
    else
    {
        _S1287 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S1290 = cross_0(_S1283, _S1287);
    float _S1291 = (F32_sqrt((U1_0)));
    float _S1292 = 6.28318548202514648f * U2_0;
    float _S1293 = _S1291 * (F32_cos((_S1292)));
    float t2_0 = _S1291 * (F32_sin((_S1292)));
    float _S1294 = 0.5f * (1.0f + _S1283.z);
    float t2_1 = (1.0f - _S1294) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S1293 * _S1293)))))) + _S1294 * t2_0;
    float3  _S1295 = make_float3 (_S1293) * _S1287 + make_float3 (t2_1) * _S1290;
    float _S1296 = unshared_0(_S1293);
    float _S1297 = unshared_0(_S1293);
    float3  _S1298 = _S1295 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S1296 * _S1297 - t2_1 * t2_1))))))) * _S1283;
    float3  _S1299 = make_float3 (alpha_6 * _S1298.x, alpha_6 * _S1298.y, (F32_max((0.0f), (_S1298.z))));
    float3  _S1300 = ((((_S1299)) * make_float3(rnorm3df(((_S1299)).x, ((_S1299)).y, ((_S1299)).z))));
    return _S1300;
}

__device__ float3  worldToTangent(float3  v_8, float3  n_9)
{
    float3  a_9 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S1301 = (F32_abs((dot_0(n_9, a_9)))) > 0.9999847412109375f;
    float3  a_10;
    if(_S1301)
    {
        float3  _S1302 = make_float3 (1.0f, 0.0f, 0.0f);
        a_10 = _S1302;
    }
    else
    {
        a_10 = a_9;
    }
    float3  _S1303 = cross_0(n_9, a_10);
    float3  _S1304 = ((((_S1303)) * make_float3(rnorm3df(((_S1303)).x, ((_S1303)).y, ((_S1303)).z))));
    float3  _S1305 = cross_0(n_9, _S1304);
    return make_float3 (dot_0(v_8, _S1304), dot_0(v_8, n_9), dot_0(v_8, _S1305));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_9, float3  n_i_11, float alpha_7, AnisotropicFrame frame_5, uint * random_state_7, uint first_2)
{
    Random _S1306 = draw(*random_state_7, first_2);
    Random _S1307 = draw(*random_state_7, first_2 | 2147483648U);
    *random_state_7 = _S1307.state;
    float _S1308 = frame_5.alphas.x;
    bool _S1309 = _S1308 > 0.0f;
    if(_S1309)
    {
        float3  _S1310 = anisotropicLocal(v_9, frame_5.tangent, n_i_11);
        float _S1311 = frame_5.alphas.y;
        float3  _S1312 = make_float3 (_S1308 * _S1310.x, _S1311 * _S1310.y, _S1310.z);
        float3  _S1313 = ((((_S1312)) * make_float3(rnorm3df(((_S1312)).x, ((_S1312)).y, ((_S1312)).z))));
        float3  _S1314 = sampleGGXVNDF(_S1313, 1.0f, _S1306.value, _S1307.value);
        float3  _S1315 = make_float3 (_S1308 * _S1314.x, _S1311 * _S1314.y, _S1314.z);
        float3  _S1316 = ((((_S1315)) * make_float3(rnorm3df(((_S1315)).x, ((_S1315)).y, ((_S1315)).z))));
        return make_float3 (_S1316.x) * frame_5.tangent + make_float3 (_S1316.y) * cross_0(n_i_11, frame_5.tangent) + make_float3 (_S1316.z) * n_i_11;
    }
    float3  _S1317 = worldToTangent(v_9, n_i_11);
    float3  _S1318 = sampleGGXVNDF(float3 {_S1317.x, _S1317.z, _S1317.y}, alpha_7, _S1306.value, _S1307.value);
    float3  _S1319 = float3 {_S1318.x, _S1318.z, _S1318.y};
    float3  _S1320 = tangentToWorld(_S1319, n_i_11);
    return _S1320;
}

__device__ __forceinline__ float3  coatHalf(float3  v_10, CoatFrame coat_frame_4, uint random_state_8)
{
    bool _S1321 = !((dot_0(coat_frame_4.normal, v_10)) > 0.0f);
    if(_S1321)
    {
        return make_float3 (0.0f);
    }
    uint state_2 = random_state_8;
    float3  _S1322 = sampleHalfVector(v_10, coat_frame_4.normal, coat_frame_4.alpha, AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f)), &state_2, 1U);
    return _S1322;
}

static __device__ Facets Facets_x24init_0(float3  h_3, float3  coat_h_3)
{
    Facets _S1323;
    (&_S1323)->h = h_3;
    (&_S1323)->coat_h = coat_h_3;
    return _S1323;
}

__device__ Facets drawFacets(float3  in_dir_5, float3  n_10, BSDFMaterial material_20, uint random_state_9)
{
    float3  _S1324 = negate_0(in_dir_5);
    float _S1325 = sign_0(dot_0(n_10, _S1324));
    float3  _S1326 = n_10 * make_float3 (_S1325);
    uint state_3 = random_state_9;
    float _S1327 = material_20.roughness;
    float _S1328 = _S1327 * _S1327;
    AnisotropicFrame _S1329 = anisotropicFrame(material_20, _S1326);
    float3  _S1330 = sampleHalfVector(_S1324, _S1326, _S1328, _S1329, &state_3, 0U);
    CoatFrame _S1331 = coatFrame(material_20, _S1326);
    float3  _S1332 = coatHalf(_S1324, _S1331, random_state_9);
    return Facets_x24init_0(_S1330, _S1332);
}

__device__ bool neeDecision(BSDFMaterial material_21, float n_dot_v_2, float eta_i_5, float eta_o_4)
{
    float _S1333 = fresnel((F32_abs((n_dot_v_2))), eta_i_5, eta_o_4);
    float3  _S1334 = mix_0(make_float3 (_S1333), material_21.albedo, material_21.metallic);
    float _S1335 = rgb_to_greyscale(_S1334);
    float _S1336 = (F32_max(((1.0f - _S1335) * (1.0f - material_21.metallic) * (1.0f - material_21.transmission)), (0.0f)));
    bool _S1337 = _S1336 > 0.03999999910593033f;
    bool _S1338;
    if(_S1337)
    {
        _S1338 = true;
    }
    else
    {
        _S1338 = (material_21.roughness) > 0.20000000298023224f;
    }
    return _S1338;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_22)
{
    float _S1339 = rgb_to_greyscale(material_22->translucent);
    return _S1339 > 0.0f;
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
    MediumSides _S1340;
    (&_S1340)->behind = *behind_1;
    (&_S1340)->front = *front_0;
    (&_S1340)->fillings = fillings_1;
    (&_S1340)->face = face_1;
    return _S1340;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1341 = surface_8->geometry_n;
    MediumSides _S1342 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S1342;
    bool _S1343 = surface_8->encloses;
    if(_S1343)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S1344 = (dot_0(dir_12, _S1341)) > 0.0f;
        if(_S1344)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_3, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1345 = surface_9->geometry_n;
    ShadowContext _S1346 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1347 = surface_9->encloses;
    ShadowContext context_4;
    if(_S1347)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S1348 = - _S1345;
        float3  _S1349 = _slang_select(turned_0, _S1348,_S1345);
        (&faced_1)->geometry_n = _S1349;
        FKMedium _S1350 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1351 = faced_1;
        FKMedium _S1352 = _S1350;
        MediumSides _S1353 = mediumSides_0(&_S1351, &_S1352, filling_1, dir_13, outside_1);
        ShadowContext _S1354 = ShadowContext_x24init_0(_S1353.behind.extinction, _S1353.front.extinction, _S1353.fillings, _S1345, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1355 = _S1353.fillings;
            ShadowContext _S1356 = ShadowContext_x24init_0(_S1353.front.extinction, _S1353.behind.extinction, uint2 {_S1355.y, _S1355.x}, _S1345, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1356;
        }
        else
        {
            context_4 = _S1354;
        }
    }
    else
    {
        context_4 = _S1346;
    }
    return context_4;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_6, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_3, BSDFMaterial * material_23, float eta_i_6, float eta_o_5, bool competing_1, Facets * facets_3)
{
    float3  _S1357 = light_2->dir;
    bool _S1358 = (dot_0(geometry_n_3, - in_dir_6) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 6>  throughputs_1;
    FixedArray<float, 6>  pdfs_4;
    BSDF(in_dir_6, _S1357, smooth_n_5, *material_23, eta_i_6, eta_o_5, _S1358, *facets_3, &throughputs_1, &pdfs_4);
    bool _S1359;
    if(competing_1)
    {
        _S1359 = (light_2->density) != 0.0f;
    }
    else
    {
        _S1359 = false;
    }
    float3  _S1360 = make_float3 (0.0f);
    uint i_23 = 0U;
    float3  f_7 = _S1360;
    for(;;)
    {
        if(i_23 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S1361 = (pdfs_4[i_23]) > 0.0f;
        if(_S1361)
        {
            float3  f_8;
            if(_S1359)
            {
                float _S1362 = light_2->density;
                float _S1363 = pdfs_4[i_23] / light_2->density;
                float3  f_9 = f_7 + throughputs_1[i_23] * make_float3 (pdfs_4[i_23]) / make_float3 (_S1362 * (1.0f + _S1363 * _S1363));
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
    if(_S1359)
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
    FKSurface _S1364 = surface_10;
    BSDFMaterial _S1365 = material_24;
    Facets _S1366 = facets_4;
    FixedArray<float3 , 6>  terms_3;
    FixedArray<float, 6>  pdfs_5;
    float3  _S1367 = skyLobes_0(in_dir_7, dir_14, &_S1364, &_S1365, eta_3, is_inside_4, &_S1366, pdf_5, &terms_3, &pdfs_5);
    return _S1367;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_10, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S1368;
    (&_S1368)->unit_direction = unit_direction_1;
    (&_S1368)->throughput = throughput_1;
    (&_S1368)->random_state = random_state_10;
    (&_S1368)->refracted = refracted_3;
    (&_S1368)->lobe = lobe_4;
    (&_S1368)->pdf = pdf_6;
    return _S1368;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  v_11, float3  n_i_12, float n_i_dot_v_3, BSDFMaterial material_25, Weights w_14, uint random_state_11)
{
    float3  _S1369 = make_float3 (1.0f);
    SampleBSDF _S1370 = SampleBSDF_x24init_0(_S1369, _S1369, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1370;
    Random _S1371 = draw(random_state_11, 3U);
    Random _S1372 = draw(random_state_11, 2147483651U);
    (&sample_1)->random_state = _S1372.state;
    float _S1373 = _S1371.value;
    float _S1374 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1373 * _S1373))))));
    float _S1375 = 6.28318548202514648f * _S1372.value;
    float3  _S1376 = tangentToWorld(make_float3 (_S1374 * (F32_cos((_S1375))), _S1371.value, _S1374 * (F32_sin((_S1375)))), n_i_12);
    (&sample_1)->unit_direction = _S1376;
    (&sample_1)->lobe = 4U;
    float3  _S1377 = sheenVelvetBSDF((&sample_1)->unit_direction, v_11, n_i_12, material_25, w_14);
    (&sample_1)->throughput = _S1377;
    float _S1378 = sheenVelvetPDF(_S1371.value, n_i_dot_v_3, w_14);
    (&sample_1)->pdf = _S1378;
    return sample_1;
}

__device__ __forceinline__ SampleBSDF coatSample(float3  in_dir_8, float3  v_12, float3  coat_h_4, CoatFrame coat_frame_5, Weights w_15, uint random_state_12)
{
    float3  _S1379 = make_float3 (1.0f);
    SampleBSDF _S1380 = SampleBSDF_x24init_0(_S1379, _S1379, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1380;
    float3  _S1381 = reflect_0(in_dir_8, coat_h_4);
    float3  _S1382 = ((((_S1381)) * make_float3(rnorm3df(((_S1381)).x, ((_S1381)).y, ((_S1381)).z))));
    (&sample_2)->unit_direction = _S1382;
    (&sample_2)->random_state = random_state_12;
    (&sample_2)->lobe = 5U;
    float3  _S1383 = coatBSDF(w_15);
    (&sample_2)->throughput = _S1383;
    float _S1384 = coatPDF(v_12, coat_h_4, coat_frame_5, w_15);
    (&sample_2)->pdf = _S1384;
    return sample_2;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1385 = (F32_sqrt((random_1_0)));
    float _S1386 = 6.28318548202514648f * random_2_0;
    float _S1387 = _S1385 * (F32_cos((_S1386)));
    float _S1388 = _S1385 * (F32_sin((_S1386)));
    float _S1389 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1387 * _S1387 - _S1388 * _S1388))))));
    return make_float3 (_S1387, _S1389, _S1388);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_13, float n_i_dot_v_4, BSDFMaterial material_26, Weights w_16, uint random_state_13)
{
    float3  _S1390 = make_float3 (1.0f);
    SampleBSDF _S1391 = SampleBSDF_x24init_0(_S1390, _S1390, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1391;
    Random _S1392 = draw(random_state_13, 3U);
    Random _S1393 = draw(random_state_13, 2147483651U);
    (&sample_3)->random_state = _S1393.state;
    float3  _S1394 = sampleCosWeightedHemisphere(_S1392.value, _S1393.value);
    float _S1395 = translucentShare(material_26);
    bool _S1396 = u_3 < (w_16.p_diffuse * _S1395);
    float _S1397 = _S1394.y;
    float _S1398 = - _S1397;
    float _S1399 = _slang_select(_S1396, _S1398,_S1397);
    float3  _S1400 = tangentToWorld(make_float3 (_S1394.x, _S1399, _S1394.z), n_i_13);
    (&sample_3)->unit_direction = _S1400;
    (&sample_3)->refracted = _S1396;
    (&sample_3)->lobe = 0U;
    float3  _S1401 = diffuseBSDF((&sample_3)->unit_direction, n_i_13, material_26, w_16);
    (&sample_3)->throughput = _S1401;
    float _S1402 = diffusePDF(_S1399, n_i_dot_v_4, material_26, w_16);
    (&sample_3)->pdf = _S1402;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_14, ToonProfile profile_3, Weights w_17, uint random_state_14)
{
    float3  _S1403 = make_float3 (1.0f);
    SampleBSDF _S1404 = SampleBSDF_x24init_0(_S1403, _S1403, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1404;
    Random _S1405 = draw(random_state_14, 3U);
    Random _S1406 = draw(random_state_14, 2147483651U);
    (&sample_4)->random_state = _S1406.state;
    float _S1407 = _S1405.value * profile_3.norm / 6.28318548202514648f;
    float t_23;
    if(profile_3.glossy)
    {
        t_23 = (F32_acos((clamp_1(1.0f - _S1407, -1.0f, 1.0f))));
    }
    else
    {
        t_23 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1407)))), (1.0f))))));
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
        float _S1408 = toonP(t_23, profile_3.a, profile_3.s);
        float _S1409 = _S1408 * (F32_sin((t_23)));
        float _S1410;
        if(profile_3.glossy)
        {
            _S1410 = 1.0f;
        }
        else
        {
            _S1410 = (F32_cos((t_23)));
        }
        float _S1411 = _S1409 * _S1410;
        float _S1412 = toonIntegral(t_23, profile_3.a, profile_3.s, profile_3.glossy);
        float _S1413 = (_S1412 - _S1407) / _S1411;
        bool _S1414 = _S1411 > 0.0f;
        float _S1415 = _slang_select(_S1414, _S1413,0.0f);
        float _S1416 = clamp_1(t_23 - _S1415, 0.0f, profile_3.b);
        int k_3 = k_2 + int(1);
        t_23 = _S1416;
        k_2 = k_3;
    }
    float _S1417 = 6.28318548202514648f * _S1406.value;
    float _S1418 = (F32_sin((t_23)));
    float3  _S1419 = tangentToWorld(make_float3 (_S1418 * (F32_cos((_S1417))), (F32_cos((t_23))), _S1418 * (F32_sin((_S1417)))), profile_3.axis);
    (&sample_4)->unit_direction = _S1419;
    bool _S1420 = (dot_0(n_i_14, (&sample_4)->unit_direction)) < 0.0f;
    (&sample_4)->refracted = _S1420;
    (&sample_4)->lobe = 6U;
    float3  _S1421 = toonBSDF((&sample_4)->unit_direction, n_i_14, profile_3, w_17);
    (&sample_4)->throughput = _S1421;
    float _S1422 = toonPDF((&sample_4)->unit_direction, n_i_14, profile_3, w_17);
    (&sample_4)->pdf = _S1422;
    return sample_4;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_1, float3  n_i_15, float alpha_8, AnisotropicFrame frame_6, BSDFMaterial material_27, Weights w_18, float pdf_h_3, float eta_i_7, float eta_o_6, uint random_state_15)
{
    float3  _S1423 = make_float3 (1.0f);
    SampleBSDF _S1424 = SampleBSDF_x24init_0(_S1423, _S1423, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1424;
    (&sample_5)->unit_direction = w_18.refracted;
    (&sample_5)->random_state = random_state_15;
    (&sample_5)->refracted = true;
    (&sample_5)->lobe = 1U;
    float3  _S1425 = refractBSDF((&sample_5)->unit_direction, n_i_15, alpha_8, frame_6, material_27, w_18);
    (&sample_5)->throughput = _S1425;
    float _S1426 = refractPDF(dot_0((&sample_5)->unit_direction, ggx_n_1), pdf_h_3, w_18, eta_i_7, eta_o_6);
    (&sample_5)->pdf = _S1426;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_2, float3  n_i_16, float alpha_9, AnisotropicFrame frame_7, Weights w_19, float pdf_h_4, uint random_state_16)
{
    float3  _S1427 = make_float3 (1.0f);
    SampleBSDF _S1428 = SampleBSDF_x24init_0(_S1427, _S1427, 0U, false, 0U, 0.0f);
    SampleBSDF sample_6 = _S1428;
    float3  _S1429 = reflect_0(in_dir_9, ggx_n_2);
    float3  _S1430 = ((((_S1429)) * make_float3(rnorm3df(((_S1429)).x, ((_S1429)).y, ((_S1429)).z))));
    (&sample_6)->unit_direction = _S1430;
    (&sample_6)->random_state = random_state_16;
    (&sample_6)->lobe = 2U;
    float3  _S1431 = reflectBSDF((&sample_6)->unit_direction, n_i_16, alpha_9, frame_7, w_19);
    (&sample_6)->throughput = _S1431;
    float _S1432 = reflectPDF(pdf_h_4, w_19);
    (&sample_6)->pdf = _S1432;
    return sample_6;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_11, BSDFMaterial material_28, float eta_i_8, float eta_o_7, Facets facets_5, uint random_init_0, float2  screen_space_0)
{
    float3  _S1433 = negate_0(in_dir_10);
    float _S1434 = dot_0(n_11, _S1433);
    float _S1435 = sign_0(_S1434);
    float3  n_i_17 = n_11 * make_float3 (_S1435);
    float _S1436 = (F32_abs((_S1434)));
    float _S1437 = material_28.roughness;
    float _S1438 = _S1437 * _S1437;
    AnisotropicFrame _S1439 = anisotropicFrame(material_28, n_i_17);
    SheenProfile _S1440 = sheenProfile(_S1433, n_i_17, material_28);
    CoatFrame _S1441 = coatFrame(material_28, n_i_17);
    float3  _S1442 = coatSeries(_S1441, material_28);
    Weights _S1443 = lobeWeights(in_dir_10, _S1433, n_i_17, facets_5.h, facets_5.coat_h, facets_5.h, facets_5.coat_h, _S1439, _S1440, _S1441, _S1442, material_28, eta_i_8, eta_o_7);
    Random _S1444 = draw(random_init_0, 2U);
    bool _S1445 = (_S1444.value) < (_S1443.p_sheen_velvet);
    if(_S1445)
    {
        SampleBSDF _S1446 = sheenVelvetSample(_S1433, n_i_17, _S1436, material_28, _S1443, _S1444.state);
        return _S1446;
    }
    float _S1447 = _S1444.value - _S1443.p_sheen_velvet;
    bool _S1448 = _S1447 < (_S1443.p_coat);
    if(_S1448)
    {
        SampleBSDF _S1449 = coatSample(in_dir_10, _S1433, facets_5.coat_h, _S1441, _S1443, _S1444.state);
        return _S1449;
    }
    float _S1450 = _S1447 - _S1443.p_coat;
    bool _S1451 = _S1450 < (_S1443.p_diffuse);
    if(_S1451)
    {
        SampleBSDF _S1452 = diffuseSample(_S1450, n_i_17, _S1436, material_28, _S1443, _S1444.state);
        return _S1452;
    }
    bool _S1453 = _S1450 < (_S1443.p_diffuse + _S1443.p_toon);
    if(_S1453)
    {
        ToonProfile _S1454 = toonProfile(_S1433, n_i_17, material_28);
        SampleBSDF _S1455 = toonSample(n_i_17, _S1454, _S1443, _S1444.state);
        return _S1455;
    }
    float _S1456 = vndfPDF(_S1433, facets_5.h, n_i_17, _S1436, _S1438, _S1439, _S1443.v_dot_h);
    bool _S1457 = (_S1450 - _S1443.p_toon) < (_S1443.p_diffuse + _S1443.p_refract);
    if(_S1457)
    {
        SampleBSDF _S1458 = refractSample(facets_5.h, n_i_17, _S1438, _S1439, material_28, _S1443, _S1456, eta_i_8, eta_o_7, _S1444.state);
        return _S1458;
    }
    SampleBSDF _S1459 = reflectSample(in_dir_10, facets_5.h, n_i_17, _S1438, _S1439, _S1443, _S1456, _S1444.state);
    return _S1459;
}

__device__ __forceinline__ float3  reflectedHalf(float3  in_dir_11, float3  out_dir_1)
{
    float3  _S1460 = negate_0(in_dir_11);
    float3  _S1461 = _S1460 + out_dir_1;
    float3  _S1462 = ((((_S1461)) * make_float3(rnorm3df(((_S1461)).x, ((_S1461)).y, ((_S1461)).z))));
    return _S1462;
}

__device__ __forceinline__ float3  refractedHalf(float3  in_dir_12, float3  out_dir_2, float3  n_12, float eta_i_9, float eta_o_8)
{
    float3  _S1463 = negate_0(in_dir_12);
    float3  _S1464 = negate_0(make_float3 (eta_i_9) * _S1463 + make_float3 (eta_o_8) * out_dir_2);
    float3  _S1465 = ((((_S1464)) * make_float3(rnorm3df(((_S1464)).x, ((_S1464)).y, ((_S1464)).z))));
    float _S1466 = sign_0(dot_0(n_12, _S1463));
    float _S1467 = sign_0(dot_0(_S1464, n_12 * make_float3 (_S1466)));
    return _S1465 * make_float3 (_S1467);
}

static __device__ bool boundsVolume_0(FKSurface * surface_11)
{
    return surface_11->encloses;
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_8, bool replay_1, float scale_3, Selection * sel_7)
{
    bool turned_1;
    bool is_inside_5;
    bool viewed_0;
    bool _S1468;
    bool _S1469;
    bool _S1470;
    uint b_6;
    uint layer_0;
    float3  throughput_2;
    float3  spectral_weight_0;
    float density_2;
    float spread_1;
    float width_3;
    float sky_pdf_0;
    float wavelength_8;
    float threshold_0;
    TreeSample light_3;
    int _S1471;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_4;
    float sky_pdf_1;
    uint b_7;
    float spread_3;
    float width_5;
    float3  _S1472 = make_float3 (0.0f);
    Shift _S1473 = Shift_x24init_0(_S1472, 0.0f);
    uint _S1474 = r_8->path;
    uint _S1475 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1476 = extractBits_0(_S1474, 5U, 5U);
    uint _S1477 = extractBits_0(_S1474, 10U, 2U);
    uint _S1478 = extractBits_0(_S1474, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S1479 = _S1478 >= 3U;
        uint _S1480 = _slang_select(_S1479, 1U,0U);
        uint _S1481 = _S1475 + _S1480;
        uint _S1482 = (fcptMaxBounces());
        passes_0 = _S1481 > _S1482;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1473;
    }
    uint _S1483 = _S1476 - 1U;
    bool _S1484 = _S1478 == 3U;
    uint _S1485 = _slang_select(_S1484, 1U,0U);
    uint _S1486 = _S1475 + _S1485;
    bool _S1487 = _S1477 == 0U;
    uint _S1488 = _slang_select(_S1487, _S1486,_S1483);
    FKHit _S1489 = (fcptReservoirHit((*r_8)));
    float3  _S1490 = dom_7->x0;
    float3  _S1491 = dom_7->x1 - dom_7->x0;
    float3  _S1492 = ((((_S1491)) * make_float3(rnorm3df(((_S1491)).x, ((_S1491)).y, ((_S1491)).z))));
    FKRay _S1493 = Ray_x24init_0(dom_7->x1, _S1492);
    FKRay ray_2 = _S1493;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1472;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_2 = throughput_3;
    float3  glowed_0 = _S1472;
    float3  extinction_in_0 = _S1472;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1494 = dom_7->spread;
    float _S1495 = dom_7->width;
    float _S1496 = length_0(_S1491);
    NEEVertex _S1497 = NEEVertex_x24init_0(true, 0.0f, _S1472, _S1472, _S1472);
    NEEVertex nee_vertex_0 = _S1497;
    Vertex _S1498 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1498;
    Reservoir _S1499 = (Reservoir{});
    Reservoir chain_0 = _S1499;
    uint _S1500 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    uint _S1501 = extractBits_0(_S1474, 24U, 8U);
    uint _S1502 = insertBits_0(0U, _S1501, 24U, 8U);
    (&chain_0)->path = _S1502;
    (&ray_2)->origin = _S1490;
    (&hit_4)->distance = _S1496;
    FKMedium _S1503 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1504 = filling_2;
    bool _S1505 = (fcptVaryingUsed());
    uint _S1506 = _slang_select(_S1505, _S1504,4294967295U);
    filling_2 = _S1506;
    scatter_in_0 = _S1503.scatter;
    extinction_in_0 = _S1503.extinction;
    g_in_0 = _S1503.g;
    Reservoir _S1507 = chain_0;
    uint _S1508 = filling_2;
    for(;;)
    {
        bool _S1509 = (fcptVaryingUsed());
        if(_S1509)
        {
            passes_0 = _S1508 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1510 = (fcptMajorant((_S1508)));
            turned_1 = _S1510 > 0.0f;
        }
        else
        {
            turned_1 = any_1(scatter_in_0 > make_float3 (0.0f));
        }
        if(replay_1)
        {
            is_inside_5 = 4294967295U == _S1488;
        }
        else
        {
            is_inside_5 = false;
        }
        if(is_inside_5)
        {
            is_inside_5 = _S1477 == 1U;
        }
        else
        {
            is_inside_5 = false;
        }
        if(is_inside_5)
        {
            is_inside_5 = turned_1;
        }
        else
        {
            is_inside_5 = false;
        }
        if(is_inside_5)
        {
            ended_0 = _S1473;
            sky_pdf_0 = 0.0f;
            spread_1 = _S1494;
            width_3 = _S1495;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_6 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1511 = (&prev_0)->rough;
        if(_S1511)
        {
            is_inside_5 = !turned_1;
        }
        else
        {
            is_inside_5 = false;
        }
        (&prev_0)->rough = is_inside_5;
        uint _S1512 = stream(_S1500, 384U);
        uint tracking_0 = _S1512;
        weight_2 = throughput_3;
        glowed_0 = _S1472;
        b_6 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        spread_1 = _S1494;
        width_3 = _S1495;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1471 = int(1);
                break;
            }
            float _S1513 = (&hit_4)->distance;
            if(passes_0)
            {
                float3  _S1514 = (&ray_2)->origin;
                float3  _S1515 = (&ray_2)->unit_direction;
                float _S1516 = (&hit_4)->distance;
                bool _S1517 = b_6 == 4294967295U;
                uint _S1518 = _slang_select(_S1517, 0U,b_6);
                uint _S1519 = (&prev_0)->lobe;
                uint _S1520 = _slang_select(_S1517, 3U,_S1519);
                float _S1521 = (fcptTrackMedium((_S1508), (_S1514), (_S1515), (_S1516), (&tracking_0), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1518), (_S1520), (_S1517)));
                wavelength_8 = _S1521;
            }
            else
            {
                if(turned_1)
                {
                    uint _S1522 = noiseAddress(_S1500, b_6);
                    Random _S1523 = draw(_S1522, 10U);
                    float _S1524 = 3.0f * _S1523.value;
                    uint _S1525 = (U32_min((uint(_S1524)), (2U)));
                    float _S1526 = - (F32_log((1.0f - (_S1524 - float(_S1525))))) / *_slang_vector_get_element_ptr(&scatter_in_0, _S1525);
                    wavelength_8 = _S1526;
                }
                else
                {
                    wavelength_8 = _S1513;
                }
            }
            bool _S1527 = !(wavelength_8 < ((&hit_4)->distance));
            if(_S1527)
            {
                _S1471 = int(1);
                break;
            }
            if(passes_0)
            {
                is_inside_5 = !replay_1;
            }
            else
            {
                is_inside_5 = false;
            }
            if(is_inside_5)
            {
                float3  _S1528 = pathColor(throughput_2 * glowed_0, throughput_3, 0.0f);
                float3  _S1529 = _S1528 / make_float3 (density_2);
                float3  _S1530 = sel_7->glow + _S1529;
                sel_7->glow = _S1530;
            }
            else
            {
            }
            glowed_0 = _S1472;
            uint b_8 = b_6 + 1U;
            float3  _S1531 = (&ray_2)->origin + make_float3 (wavelength_8) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1531;
            float3  _S1532 = flightWeight_0(scatter_in_0, extinction_in_0, wavelength_8, true);
            float3  _S1533 = weight_2;
            float _S1534 = upsample(weight_2, 0.0f);
            float3  _S1535 = make_float3 (_S1534);
            float3  _S1536 = _slang_select(false, _S1535,_S1533);
            float3  _S1537 = _slang_select(passes_0, _S1536,_S1532);
            float3  throughput_4 = throughput_2 * _S1537;
            uint _S1538 = stream(_S1500, b_8 + 320U);
            tracking_0 = _S1538;
            weight_2 = throughput_3;
            float width_6 = width_3 + spread_1 * wavelength_8;
            float _S1539 = spread_1 + 3.14159274101257324f;
            bool _S1540 = !replay_1;
            if(_S1540)
            {
                viewed_0 = true;
            }
            else
            {
                bool _S1541 = b_8 == _S1488;
                if(_S1541)
                {
                    viewed_0 = !passes_0;
                }
                else
                {
                    viewed_0 = false;
                }
            }
            TreeSample _S1542 = TreeSample_x24init_0(_S1472, _S1472, 0.0f, 0U);
            if(viewed_0)
            {
                float3  _S1543 = (&ray_2)->origin;
                float3  _S1544 = (&ray_2)->unit_direction;
                float3  _S1545 = (&ray_2)->unit_direction;
                uint _S1546 = noiseAddress(_S1500, b_8);
                float3  _S1547 = extinction_in_0;
                float3  _S1548 = extinction_in_0;
                uint2  _S1549 = make_uint2 (_S1508);
                float3  _S1550 = (&ray_2)->unit_direction;
                uint _S1551 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                FKHit _S1552 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1553 = _S1552;
                ShadowContext _S1554 = ShadowContext_x24init_0(_S1547, _S1548, _S1549, _S1550, b_8, _S1551, false, wavelength_8, width_6, &_S1553, false);
                ShadowContext _S1555 = _S1554;
                TreeSample _S1556 = sampleLightTree_0(_S1543, _S1544, _S1545, 0.0f, true, _S1546, &_S1555);
                light_3 = _S1556;
            }
            else
            {
                light_3 = _S1542;
            }
            float _S1557 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1558 = (fcptMaxBounces());
            bool _S1559 = b_8 < _S1558;
            if(_S1559)
            {
                _S1468 = (light_3.density) > 0.0f;
            }
            else
            {
                _S1468 = false;
            }
            float _S1560 = _slang_select(_S1468, _S1557,0.0f);
            float3  _S1561 = throughput_4 * light_3.radiance;
            float _S1562 = powerHeuristic(light_3.density, _S1560);
            float3  _S1563 = pathColor(_S1561 * make_float3 (_S1557 * _S1562), throughput_3, 0.0f);
            float3  _S1564 = _slang_select(viewed_0, _S1563,_S1472);
            if(replay_1)
            {
                _S1469 = b_8 == _S1488;
            }
            else
            {
                _S1469 = false;
            }
            if(_S1469)
            {
                bool _S1565 = _S1477 == 2U;
                if(_S1565)
                {
                    float _S1566 = resamplingTarget(_S1564);
                    passes_0 = _S1566 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1567 = Shift_x24init_0(_S1564, 1.0f);
                    _S1471 = int(0);
                    ended_0 = _S1567;
                    wavelength_8 = _S1539;
                    threshold_0 = width_6;
                    spectral_weight_0 = throughput_4;
                    layer_0 = b_8;
                    break;
                }
                _S1471 = int(0);
                ended_0 = _S1473;
                wavelength_8 = _S1539;
                threshold_0 = width_6;
                spectral_weight_0 = throughput_4;
                layer_0 = b_8;
                break;
            }
            if(_S1540)
            {
                Reservoir candidate_3 = _S1507;
                uint _S1568 = extractBits_0(_S1507.path, 24U, 8U);
                uint _S1569 = insertBits_0(0U, _S1568, 24U, 8U);
                uint _S1570 = extractBits_0(_S1507.path, 10U, 2U);
                bool _S1571 = _S1570 == 1U;
                if(_S1571)
                {
                    float3  _S1572 = safeDivide(_S1564, _S1472);
                    (&candidate_3)->radiance = _S1572;
                }
                else
                {
                    uint _S1573 = insertBits_0(_S1569, b_8 + 1U, 5U, 5U);
                    uint _S1574 = insertBits_0(_S1573, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1574;
                }
                Reservoir _S1575 = withEnd(candidate_3, 0U, b_8, _S1564);
                offer(sel_7, _S1575, _S1564 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1576 = survivalProbability(abs_0(throughput_4), density_2);
                uint _S1577 = (fcptMaxBounces());
                bool _S1578 = b_8 >= _S1577;
                if(_S1578)
                {
                    _S1470 = true;
                }
                else
                {
                    bool _S1579 = _S1576 < 1.0f;
                    if(_S1579)
                    {
                        uint _S1580 = noiseAddress(_S1500, b_8);
                        Random _S1581 = draw(_S1580, 8U);
                        _S1470 = _S1576 < (_S1581.value);
                    }
                    else
                    {
                        _S1470 = false;
                    }
                }
                if(_S1470)
                {
                    _S1471 = int(0);
                    ended_0 = _S1473;
                    wavelength_8 = _S1539;
                    threshold_0 = width_6;
                    spectral_weight_0 = throughput_4;
                    layer_0 = b_8;
                    break;
                }
                float _S1582 = density_2 * _S1576;
                density_2 = _S1582;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1583 = noiseAddress(_S1500, b_8);
            float3  _S1584 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1583, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1584;
            NEEVertex _S1585 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1472, (&ray_2)->origin);
            nee_vertex_0 = _S1585;
            Vertex _S1586 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_0 = _S1586;
            float _S1587 = (&prev_0)->pdf;
            FKRay _S1588 = ray_2;
            FKHit _S1589 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1590 = (fcptTraverseInstanceBVH((_S1588), (true), (4.294967296e+09f), (false), (_S1589), (false)));
            hit_4 = _S1590;
            b_6 = b_8;
            throughput_2 = throughput_4;
            spread_1 = _S1539;
            width_3 = width_6;
            sky_pdf_0 = _S1587;
        }
        if(_S1471 != int(1))
        {
            spread_1 = wavelength_8;
            width_3 = threshold_0;
            throughput_2 = spectral_weight_0;
            b_6 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1473;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1591 = b_6 == 4294967295U;
    bool _S1592 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1592)
    {
        bool _S1593 = !(&nee_vertex_0)->none;
        float _S1594 = _slang_select(_S1593, sky_pdf_0,0.0f);
        float _S1595 = escapeWeight_0(_S1594, (&ray_2)->unit_direction);
        float3  _S1596 = environment_0((&ray_2)->unit_direction, b_6, (&prev_0)->lobe);
        float3  _S1597 = pathColor(throughput_2 * _S1596, throughput_3, 0.0f);
        if(replay_1)
        {
            bool _S1598 = b_6 == _S1488;
            if(_S1598)
            {
                passes_0 = _S1477 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1597 * make_float3 (_S1595) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1487)
            {
                passes_0 = _S1484;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_6 == _S1475;
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
                return Shift_x24init_0(_S1597 * make_float3 (_S1595), 1.0f);
            }
            return _S1473;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1599 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1600 = _S1599 == 1U;
        if(_S1600)
        {
            uint _S1601 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1602 = _S1601 == b_6;
            float _S1603 = _slang_select(_S1602, 1.0f,_S1595);
            float3  _S1604 = safeDivide(_S1597 * make_float3 (_S1603), _S1472);
            (&candidate_4)->radiance = _S1604;
        }
        else
        {
            bool _S1605 = (&prev_0)->rough;
            if(_S1605)
            {
                uint _S1606 = insertBits_0(_S1502, b_6 + 1U, 5U, 5U);
                uint _S1607 = insertBits_0(_S1606, 3U, 10U, 2U);
                uint _S1608 = insertBits_0(_S1607, (&prev_0)->lobe, 15U, 3U);
                bool _S1609 = (&prev_0)->inside;
                uint _S1610 = _slang_select(_S1609, 1U,0U);
                uint _S1611 = insertBits_0(_S1608, _S1610, 22U, 1U);
                (&candidate_4)->path = _S1611;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1612 = _S1597 * make_float3 (_S1595);
        Reservoir _S1613 = withEnd(candidate_4, 3U, b_6, _S1612);
        offer(sel_7, _S1613, _S1612 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1473;
    }
    float3  _S1614 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1614;
    bool _S1615 = (fcptVaryingUsed());
    if(_S1615)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1616 = !replay_1;
        if(_S1616)
        {
            float3  _S1617 = pathColor(throughput_2 * glowed_0, throughput_3, 0.0f);
            float3  _S1618 = _S1617 / make_float3 (density_2);
            float3  _S1619 = sel_7->glow + _S1618;
            sel_7->glow = _S1619;
        }
        float3  _S1620 = throughput_2 * weight_2;
        throughput_2 = _S1620;
    }
    else
    {
        float3  _S1621 = flightWeight_0(scatter_in_0, extinction_in_0, (&hit_4)->distance, false);
        float3  _S1622 = throughput_2 * _S1621;
        throughput_2 = _S1622;
    }
    float _S1623 = width_3 + spread_1 * (&hit_4)->distance;
    uint _S1624 = b_6 + 1U;
    b_6 = _S1624;
    layer_0 = 0U;
    width_3 = _S1623;
    passes_0 = false;
    wavelength_8 = 0.0f;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    spectral_weight_0 = throughput_3;
    float3  chain_throughput_0 = _S1472;
    float3  reconnection_0 = _S1472;
    viewed_0 = _S1591;
    for(;;)
    {
        bool _S1625 = ((&hit_4)->is_point_light) == 1U;
        if(replay_1)
        {
            _S1468 = _S1477 == 1U;
        }
        else
        {
            _S1468 = false;
        }
        if(_S1468)
        {
            _S1469 = b_6 == _S1476;
        }
        else
        {
            _S1469 = false;
        }
        if(_S1469)
        {
            bool _S1626 = ((&hit_4)->instance_index) != (_S1489.instance_index);
            if(_S1626)
            {
                _S1470 = true;
            }
            else
            {
                _S1470 = ((&hit_4)->triangle_index) != (_S1489.triangle_index);
            }
        }
        else
        {
            _S1470 = false;
        }
        if(_S1470)
        {
            return _S1473;
        }
        FKMedium _S1627 = Medium_x24init_0(_S1472, _S1472, 0.0f);
        BSDFMaterial _S1628 = Material_x24init_0(_S1472, _S1472, 0.0f, 0.0f, 0.0f, 0.0f, _S1472, throughput_3, 1.0f, _S1472, _S1472, 0.5f, 0.0f, 0.0f, _S1472, 0.0f, _S1472, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, throughput_3, _S1472);
        FKMedium _S1629 = _S1627;
        FKSurface _S1630 = Surface_x24init_0(_S1472, _S1472, 0.0f, &_S1628, false, 0U, 1.0f, false, &_S1629, 4294967295U, _S1472);
        bool _S1631 = !_S1625;
        bool scatter_2;
        bool is_inside_6;
        float3  throughput_5;
        float geometry_density_0;
        FKSurface surface_12;
        if(_S1631)
        {
            uint _S1632 = noiseAddress(_S1500, b_6);
            uint _S1633 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKSurface _S1634 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1632), (width_3), (layer_0), (b_6), (_S1633), ((&ray_2)->unit_direction)));
            bool _S1635 = !passes_0;
            FKSurface _S1636 = _S1634;
            FKSurface _S1637 = emitting_0(&_S1636, _S1635);
            uint _S1638 = noiseAddress(_S1500, b_6);
            Random _S1639 = draw(_S1638, 9U);
            FKSurface _S1640 = _S1637;
            FKSurface _S1641 = uncovered_0(&_S1640, _S1639.value);
            float _S1642 = facingSign(_S1641.material.transmission, _S1641.geometry_n, (&ray_2)->unit_direction);
            bool _S1643 = _S1642 < 0.0f;
            bool _S1644 = (_S1641.material.transmission) > 0.0f;
            if(_S1644)
            {
                bool _S1645 = arrivesBehind_0((&ray_2)->unit_direction, _S1641.geometry_n);
                scatter_2 = _S1645;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1646 = _S1641;
            FKSurface _S1647 = facingRay_0(&_S1646, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1648 = arrivesBehind_0((&ray_2)->unit_direction, _S1647.geometry_n);
                is_inside_6 = _S1648;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float _S1649 = (&hit_4)->distance;
                float _S1650 = upsample(_S1647.material.absorption, wavelength_8);
                float3  _S1651 = make_float3 (_S1650);
                bool _S1652 = wavelength_8 > 0.0f;
                float3  _S1653 = _slang_select(_S1652, _S1651,_S1647.material.absorption);
                float3  _S1654 = beerLambert(_S1649, _S1653);
                float3  _S1655 = throughput_2 * _S1654;
                throughput_5 = _S1655;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1656 = !_S1647.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S1647.geometry_n, (&ray_2)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1657 = b_6 == _S1624;
            if(_S1657)
            {
                float _S1658 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1658;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S1659 = geometry_density_0;
            scatter_2 = _S1656;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1659;
            surface_12 = _S1647;
            turned_1 = _S1643;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_12 = _S1630;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S1660;
        if(scatter_2)
        {
            _S1660 = (&prev_0)->rough;
        }
        else
        {
            _S1660 = false;
        }
        bool _S1661;
        if(_S1660)
        {
            _S1661 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1661 = false;
        }
        FKSurface _S1662 = surface_12;
        float _S1663 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        bool _S1664 = (fcptDispersionUsed());
        bool _S1665;
        if(_S1664)
        {
            _S1665 = wavelength_8 == 0.0f;
        }
        else
        {
            _S1665 = false;
        }
        bool _S1666;
        if(_S1665)
        {
            _S1666 = scatter_2;
        }
        else
        {
            _S1666 = false;
        }
        bool _S1667;
        if(_S1666)
        {
            bool _S1668 = dispersive(surface_12.material);
            _S1667 = _S1668;
        }
        else
        {
            _S1667 = false;
        }
        float3  throughput_6;
        if(_S1667)
        {
            uint _S1669 = stream(_S1500, 512U);
            Random _S1670 = pcg(_S1669);
            uint _S1671 = extractBits_0(_S1474, 25U, 7U);
            float _S1672 = (float(_S1671) + _S1670.value) / 128.0f;
            uint _S1673 = extractBits_0(_S1474, 24U, 1U);
            bool _S1674 = _S1673 == 1U;
            float _S1675 = _slang_select(_S1674, _S1672,_S1670.value);
            float2  _S1676 = sampleWavelength(_S1675);
            float wavelength_9 = _S1676.x;
            float3  _S1677 = wavelengthWeights(wavelength_9);
            float3  _S1678 = _S1677 / make_float3 (_S1676.y);
            float _S1679 = upsample(throughput_5, wavelength_9);
            float3  _S1680 = make_float3 (_S1679);
            float _S1681 = upsample(scatter_in_0, wavelength_9);
            float3  _S1682 = make_float3 (_S1681);
            scatter_in_0 = _S1682;
            float _S1683 = upsample(extinction_in_0, wavelength_9);
            float3  _S1684 = make_float3 (_S1683);
            extinction_in_0 = _S1684;
            wavelength_8 = wavelength_9;
            throughput_6 = _S1680;
            spectral_weight_0 = _S1678;
        }
        else
        {
            throughput_6 = throughput_5;
        }
        BSDFMaterial _S1685 = pathMaterial(surface_12.material, wavelength_8);
        float2  _S1686 = wavelengthEta(_S1685, _S1663, wavelength_8);
        FKSurface _S1687 = surface_12;
        Facets _S1688 = drawFacets((&ray_2)->unit_direction, _S1662.smooth_n, _S1685, surface_12.random_state);
        bool _S1689;
        if(scatter_2)
        {
            uint _S1690 = (fcptMaxBounces());
            bool _S1691 = b_6 >= _S1690;
            if(_S1691)
            {
                _S1689 = true;
            }
            else
            {
                bool _S1692 = neeDecision(_S1685, _S1663, _S1686.x, _S1686.y);
                _S1689 = _S1692;
            }
        }
        else
        {
            _S1689 = false;
        }
        bool _S1693;
        if(passes_0)
        {
            _S1693 = true;
        }
        else
        {
            _S1693 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1693)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1689;
        }
        bool _S1694 = (fcptHairUsed());
        bool _S1695;
        if(_S1694)
        {
            float3  _S1696 = surface_12.hair;
            _S1695 = (dot_0(_S1696, _S1696)) > 0.0f;
        }
        else
        {
            _S1695 = false;
        }
        bool _S1697;
        if(_S1695)
        {
            _S1697 = true;
        }
        else
        {
            BSDFMaterial _S1698 = _S1685;
            bool _S1699 = isTranslucent_0(&_S1698);
            _S1697 = _S1699;
        }
        bool _S1700;
        if(_S1697)
        {
            _S1700 = true;
        }
        else
        {
            bool _S1701 = (_S1685.transmission) > 0.0f;
            if(_S1701)
            {
                uint _S1702 = (fcptLayers((hit_4)));
                _S1700 = _S1702 == 1U;
            }
            else
            {
                _S1700 = false;
            }
        }
        float3  emission_0;
        if(_S1625)
        {
            float3  _S1703 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1703;
        }
        else
        {
            emission_0 = _S1685.emissive;
        }
        bool _S1704 = !replay_1;
        bool _S1705;
        if(_S1704)
        {
            _S1705 = true;
        }
        else
        {
            _S1705 = b_6 >= _S1488;
        }
        bool _S1706;
        if(_S1705)
        {
            float _S1707 = rgb_to_greyscale(emission_0);
            _S1706 = _S1707 > 0.0f;
        }
        else
        {
            _S1706 = false;
        }
        float3  emission_1;
        if(_S1706)
        {
            NEEVertex _S1708 = nee_vertex_0;
            FKHit _S1709 = hit_4;
            float _S1710 = emissionWeight_0(&_S1708, &_S1709, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1710);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1711;
        if(replay_1)
        {
            _S1711 = _S1477 == 1U;
        }
        else
        {
            _S1711 = false;
        }
        bool _S1712;
        if(_S1711)
        {
            _S1712 = b_6 > _S1476;
        }
        else
        {
            _S1712 = false;
        }
        bool _S1713;
        if(_S1712)
        {
            _S1713 = b_6 == _S1475;
        }
        else
        {
            _S1713 = false;
        }
        bool _S1714;
        if(_S1713)
        {
            bool _S1715 = _S1478 == 1U;
            if(_S1715)
            {
                _S1714 = true;
            }
            else
            {
                _S1714 = _S1478 == 2U;
            }
        }
        else
        {
            _S1714 = false;
        }
        if(_S1714)
        {
            bool _S1716 = _S1625 != (_S1478 == 2U);
            if(_S1716)
            {
                return _S1473;
            }
            float3  _S1717 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_8);
            return Shift_x24init_0(_S1717 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1718 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1719 = _S1718 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1720 = insertBits_0(_S1502, b_6, 5U, 5U);
        uint _S1721 = insertBits_0(_S1720, 1U, 10U, 2U);
        uint _S1722 = insertBits_0(_S1721, (&prev_0)->lobe, 15U, 3U);
        bool _S1723 = (&prev_0)->inside;
        uint _S1724 = _slang_select(_S1723, 1U,0U);
        uint _S1725 = insertBits_0(_S1722, _S1724, 22U, 1U);
        (&here_0)->path = _S1725;
        uint _S1726 = (&here_0)->path;
        bool _S1727 = wavelength_8 > 0.0f;
        uint _S1728 = _slang_select(_S1727, 1U,0U);
        uint _S1729 = insertBits_0(_S1726, _S1728, 23U, 1U);
        (&here_0)->path = _S1729;
        float _S1730 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S1730;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1731;
        if(replay_1)
        {
            _S1731 = _S1477 == 1U;
        }
        else
        {
            _S1731 = false;
        }
        bool _S1732;
        if(_S1731)
        {
            _S1732 = b_6 == _S1476;
        }
        else
        {
            _S1732 = false;
        }
        bool _S1733 = b_6 == _S1488;
        bool _S1734;
        if(_S1733)
        {
            bool _S1735 = !scatter_2;
            if(_S1735)
            {
                _S1734 = true;
            }
            else
            {
                bool _S1736 = _S1477 != 1U;
                if(_S1736)
                {
                    _S1734 = _S1477 != 3U;
                }
                else
                {
                    _S1734 = false;
                }
            }
        }
        else
        {
            _S1734 = false;
        }
        bool _S1737;
        if(_S1734)
        {
            _S1737 = _S1477 == 2U;
        }
        else
        {
            _S1737 = false;
        }
        bool _S1738;
        if(_S1737)
        {
            _S1738 = !_S1661;
        }
        else
        {
            _S1738 = false;
        }
        bool _S1739;
        if(_S1738)
        {
            _S1739 = _S1478 != 4U;
        }
        else
        {
            _S1739 = false;
        }
        bool _S1740 = _S1476 == _S1475;
        bool _S1741;
        if(_S1740)
        {
            _S1741 = _S1478 == 0U;
        }
        else
        {
            _S1741 = false;
        }
        bool _S1742;
        if(_S1741)
        {
            _S1742 = ((&hit_4)->instance_index) == (_S1489.instance_index);
        }
        else
        {
            _S1742 = false;
        }
        bool _S1743;
        if(_S1742)
        {
            _S1743 = ((&hit_4)->triangle_index) == (_S1489.triangle_index);
        }
        else
        {
            _S1743 = false;
        }
        bool _S1744;
        if(_S1743)
        {
            _S1744 = _S1661;
        }
        else
        {
            _S1744 = false;
        }
        bool _S1745 = _slang_select(_S1732, _S1744,_S1739);
        bool _S1746;
        if(nee_0)
        {
            _S1746 = _slang_select(replay_1, _S1745,scatter_2);
        }
        else
        {
            _S1746 = false;
        }
        TreeSample _S1747 = TreeSample_x24init_0(_S1472, _S1472, 0.0f, 0U);
        uint2  _S1748 = make_uint2 (0U);
        float2  _S1749 = make_float2 (0.0f);
        FKHit _S1750 = Hit_x24init_0(_S1749, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1751 = _S1750;
        ShadowContext _S1752 = ShadowContext_x24init_0(_S1472, _S1472, _S1748, _S1472, 0U, 0U, false, 0.0f, 0.0f, &_S1751, false);
        bool _S1753;
        if(nee_0)
        {
            _S1753 = _S1705;
        }
        else
        {
            _S1753 = false;
        }
        ShadowContext context_5;
        if(_S1753)
        {
            uint _S1754 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKMedium _S1755 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1756 = surface_12;
            FKHit _S1757 = hit_4;
            FKMedium _S1758 = _S1755;
            ShadowContext _S1759 = shadowContext_0(&_S1756, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_6, _S1754, (&hit_4)->distance, width_3, &_S1757, _S1695, &_S1758);
            context_5 = _S1759;
        }
        else
        {
            context_5 = _S1752;
        }
        float3  throughput_7;
        float3  lit_0;
        if(_S1746)
        {
            float3  _S1760 = (&ray_2)->origin;
            if(_S1695)
            {
                throughput_7 = _S1472;
            }
            else
            {
                throughput_7 = _S1662.smooth_n;
            }
            FKSurface _S1761 = surface_12;
            uint _S1762 = noiseAddress(_S1500, b_6);
            ShadowContext _S1763 = context_5;
            TreeSample _S1764 = sampleLightTree_0(_S1760, throughput_7, surface_12.geometry_n, surface_12.geometry_offset, _S1700, _S1762, &_S1763);
            bool _S1765 = any_1((_S1764.radiance) != _S1472);
            if(_S1765)
            {
                if(_S1695)
                {
                    uint _S1766 = (fcptMaxBounces());
                    bool _S1767 = b_6 < _S1766;
                    FKSurface _S1768 = surface_12;
                    TreeSample _S1769 = _S1764;
                    float3  _S1770 = hairLight_0(&_S1768, (&ray_2)->unit_direction, &_S1769, _S1767);
                    lit_0 = _S1770;
                }
                else
                {
                    float _S1771 = _S1686.x;
                    float _S1772 = _S1686.y;
                    uint _S1773 = (fcptMaxBounces());
                    bool _S1774 = b_6 < _S1773;
                    TreeSample _S1775 = _S1764;
                    BSDFMaterial _S1776 = _S1685;
                    Facets _S1777 = _S1688;
                    float3  _S1778 = lightBSDF_0((&ray_2)->unit_direction, &_S1775, _S1662.smooth_n, _S1761.geometry_n, &_S1776, _S1771, _S1772, _S1774, &_S1777);
                    lit_0 = _S1778;
                }
            }
            else
            {
                lit_0 = _S1472;
            }
            light_3 = _S1764;
        }
        else
        {
            light_3 = _S1747;
            lit_0 = _S1472;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1779;
        bool _S1780;
        float density_4;
        if(_S1732)
        {
            bool _S1781 = !_S1661;
            if(_S1781)
            {
                return _S1473;
            }
            uint _S1782 = extractBits_0(_S1474, 23U, 1U);
            bool _S1783 = _S1727 != (_S1782 == 1U);
            if(_S1783)
            {
                return _S1473;
            }
            float3  throughput_8 = throughput_6 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S1740)
            {
                viewed_1 = _S1478 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                float3  _S1784 = pathColor(throughput_8 * emission_1, spectral_weight_0, wavelength_8);
                return Shift_x24init_0(_S1784 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1740)
            {
                refracted_4 = _S1478 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1785 = !nee_0;
                if(_S1785)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1786 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1786 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1473;
                }
                float3  _S1787 = pathColor(throughput_8 * lit_0, spectral_weight_0, wavelength_8);
                return Shift_x24init_0(_S1787 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1740)
            {
                wrong_side_0 = _S1478 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1788 = !nee_0;
                if(_S1788)
                {
                    return _S1473;
                }
                bool _S1789 = (fcptWorldReadsPath());
                if(_S1789)
                {
                    float3  _S1790 = r_8->dir;
                    float _S1791 = environmentPdf_0(r_8->dir);
                    FKSurface _S1792 = surface_12;
                    BSDFMaterial _S1793 = _S1685;
                    Facets _S1794 = _S1688;
                    FixedArray<float3 , 6>  terms_4;
                    FixedArray<float, 6>  pdfs_6;
                    float3  _S1795 = skyLobes_0((&ray_2)->unit_direction, _S1790, &_S1792, &_S1793, _S1686, is_inside_6, &_S1794, _S1791, &terms_4, &pdfs_6);
                    uint _S1796 = b_6 + 1U;
                    FixedArray<float3 , 6>  _S1797 = terms_4;
                    FixedArray<float, 6>  _S1798 = pdfs_6;
                    float3  _S1799 = skyColor_0(_S1790, &_S1797, &_S1798, _S1796);
                    float3  _S1800 = pathColor(throughput_8 * (_S1799 * r_8->radiance), spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S1800 / make_float3 (r_8->jac), density_5 / r_8->jac);
                }
                float _S1801 = environmentPdf_0(r_8->dir);
                float3  _S1802 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_12, _S1685, _S1686, is_inside_6, _S1688, _S1801);
                float3  _S1803 = pathColor(throughput_8 * _S1802 * r_8->radiance, spectral_weight_0, wavelength_8);
                return Shift_x24init_0(_S1803 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1804 = extractBits_0(_S1474, 21U, 1U);
            bool _S1805 = nee_0 != (_S1804 == 1U);
            if(_S1805)
            {
                return _S1473;
            }
            throughput_7 = throughput_8;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S1733;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1806 = !scatter_2;
                if(_S1806)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1807 = _S1477 != 1U;
                    if(_S1807)
                    {
                        refracted_4 = _S1477 != 3U;
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
                bool _S1808 = _S1477 == 2U;
                if(_S1808)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1661;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1478 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1695)
                    {
                        return _S1473;
                    }
                    uint _S1809 = noiseAddress(_S1500, b_6);
                    FKRay _S1810 = ray_2;
                    FKSurface _S1811 = surface_12;
                    Facets _S1812 = _S1688;
                    ShadowContext _S1813 = context_5;
                    SkySample _S1814 = sampleSky_0(&_S1810, &_S1811, wavelength_8, _S1686, is_inside_6, _S1809, &_S1812, &_S1813);
                    float3  _S1815 = pathColor(throughput_6 * _S1814.color, spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S1815, 1.0f);
                }
                if(_S1808)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1661;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1816 = rgb_to_greyscale(light_3.radiance);
                    bool _S1817 = !(_S1816 > 0.0f);
                    if(_S1817)
                    {
                        return _S1473;
                    }
                    float3  _S1818 = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S1818, 1.0f);
                }
                if(_S1487)
                {
                    passes_0 = _S1478 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1625;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1819 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S1819, 1.0f);
                }
                if(_S1487)
                {
                    passes_0 = _S1478 == 1U;
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
                    passes_0 = !_S1661;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1820 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S1820, 1.0f);
                }
                return _S1473;
            }
            else
            {
                if(_S1704)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1821 = b_6 > 0U;
                    if(_S1821)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1719)
                        {
                            float3  _S1822 = safeDivide(throughput_6 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1822;
                        }
                        else
                        {
                            if(_S1661)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1823 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_8);
                        Reservoir _S1824 = withEnd(candidate_5, 1U, b_6, _S1823);
                        offer(sel_7, _S1824, _S1823 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1825 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_8);
                        float3  _S1826 = sel_7->glow + _S1825;
                        sel_7->glow = _S1826;
                    }
                    if(nee_0)
                    {
                        float3  _S1827 = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_8);
                        Reservoir candidate_6 = chain_0;
                        if(_S1719)
                        {
                            float3  _S1828 = safeDivide(_S1827, chain_throughput_0);
                            (&candidate_6)->radiance = _S1828;
                        }
                        else
                        {
                            if(_S1661)
                            {
                                candidate_6 = here_0;
                                uint _S1829 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1829;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1830 = insertBits_0(_S1502, b_6 + 1U, 5U, 5U);
                                uint _S1831 = insertBits_0(_S1830, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1831;
                            }
                        }
                        Reservoir _S1832 = withEnd(candidate_6, 0U, b_6, _S1827);
                        offer(sel_7, _S1832, _S1827 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1695)
                        {
                            _S1779 = false;
                        }
                        else
                        {
                            bool _S1833 = environmentMapped_0();
                            _S1779 = _S1833;
                        }
                    }
                    else
                    {
                        _S1779 = false;
                    }
                    if(_S1779)
                    {
                        uint _S1834 = (fcptMaxBounces());
                        _S1780 = b_6 < _S1834;
                    }
                    else
                    {
                        _S1780 = false;
                    }
                    if(_S1780)
                    {
                        uint _S1835 = noiseAddress(_S1500, b_6);
                        FKRay _S1836 = ray_2;
                        FKSurface _S1837 = surface_12;
                        Facets _S1838 = _S1688;
                        ShadowContext _S1839 = context_5;
                        SkySample _S1840 = sampleSky_0(&_S1836, &_S1837, wavelength_8, _S1686, is_inside_6, _S1835, &_S1838, &_S1839);
                        float3  _S1841 = pathColor(throughput_6 * _S1840.color, spectral_weight_0, wavelength_8);
                        Reservoir candidate_7 = chain_0;
                        if(_S1719)
                        {
                            float3  _S1842 = safeDivide(_S1841, chain_throughput_0);
                            (&candidate_7)->radiance = _S1842;
                        }
                        else
                        {
                            if(_S1661)
                            {
                                candidate_7 = here_0;
                                uint _S1843 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1843;
                                (&candidate_7)->dir = _S1840.dir;
                                (&candidate_7)->radiance = _S1840.radiance;
                            }
                            else
                            {
                                uint _S1844 = insertBits_0(_S1502, b_6 + 1U, 5U, 5U);
                                uint _S1845 = insertBits_0(_S1844, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1845;
                            }
                        }
                        Reservoir _S1846 = withEnd(candidate_7, 4U, b_6, _S1841);
                        offer(sel_7, _S1846, _S1841 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_7 = throughput_6;
            density_4 = density_2;
        }
        bool _S1847;
        bool _S1848;
        bool _S1849;
        bool straight_0;
        bool _S1850;
        bool _S1851;
        bool _S1852;
        bool _S1853;
        bool _S1854;
        bool _S1855;
        bool _S1856;
        bool _S1857;
        bool _S1858;
        bool _S1859;
        bool _S1860;
        bool _S1861;
        bool _S1862;
        bool _S1863;
        uint b_9;
        float3  throughput_9;
        float3  throughput_10;
        float3  throughput_11;
        float density_6;
        float sky_pdf_2;
        float spread_4;
        if(scatter_2)
        {
            if(replay_1)
            {
                viewed_1 = _S1733;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1864 = extractBits_0(_S1474, 15U, 3U);
            uint _S1865 = extractBits_0(_S1474, 18U, 3U);
            uint _S1866 = _slang_select(_S1732, _S1865,_S1864);
            float3  _S1867 = r_8->dir;
            bool refracted_5 = _S1866 == 1U;
            SampleBSDF _S1868 = SampleBSDF_x24init_0(_S1472, _S1472, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1868;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1869 = extractBits_0(_S1474, 22U, 1U);
                bool _S1870 = is_inside_6 != (_S1869 == 1U);
                if(_S1870)
                {
                    return _S1473;
                }
                bool _S1871 = _S1477 == 1U;
                if(_S1871)
                {
                    float3  _S1872 = (fcptHitPosition((_S1489)));
                    throughput_9 = _S1872;
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
                    BSDFMaterial _S1873 = _S1685;
                    bool _S1874 = isTranslucent_0(&_S1873);
                    if(_S1874)
                    {
                        refracted_4 = _S1866 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1875 = throughput_9 - (&ray_2)->origin;
                        float3  _S1876 = _slang_select(_S1871, _S1875,_S1867);
                        wrong_side_0 = (dot_0(_S1662.smooth_n, _S1876) * _S1663) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1871)
                {
                    float3  _S1877 = (&ray_2)->origin;
                    FKSurface _S1878 = surface_12;
                    float3  _S1879 = - _S1662.smooth_n;
                    bool _S1880 = is_inside_6 != refracted_4;
                    float3  _S1881 = _slang_select(_S1880, _S1879,_S1662.smooth_n);
                    float3  _S1882 = throughput_9 - (_S1877 + make_float3 (_S1878.geometry_offset) * _S1881);
                    float3  _S1883 = ((((_S1882)) * make_float3(rnorm3df(((_S1882)).x, ((_S1882)).y, ((_S1882)).z))));
                    reconnection_1 = _S1883;
                }
                else
                {
                    reconnection_1 = _S1867;
                }
                if(_S1695)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1884 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1884;
                }
                if(wrong_side_0)
                {
                    return _S1473;
                }
                float3  _S1885 = throughput_9;
                throughput_9 = reconnection_1;
                b_9 = _S1866;
                wrong_side_0 = false;
                reconnection_1 = _S1885;
            }
            else
            {
                bool _S1886 = !_S1732;
                if(_S1886)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1887;
                    if(_S1695)
                    {
                        SampleBSDF _S1888 = (fcptSampleHair((surface_12.hair), (_S1685.albedo), (_S1685.specular_tint), ((&ray_2)->unit_direction), (_S1687.random_state)));
                        _S1887 = _S1888;
                    }
                    else
                    {
                        SampleBSDF _S1889 = sampleBSDF((&ray_2)->unit_direction, _S1662.smooth_n, _S1685, _S1686.x, _S1686.y, _S1688, _S1687.random_state, _S1749);
                        _S1887 = _S1889;
                    }
                    bsdf_sampled_0 = _S1887;
                    if(_S1695)
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
                            return _S1473;
                        }
                        break;
                    }
                    if(_S1695)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1890 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1890;
                    }
                    if(wrong_side_0)
                    {
                        _S1779 = (_S1685.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1779 = false;
                    }
                    if(_S1779)
                    {
                        float _S1891 = _S1686.x;
                        float _S1892 = _S1686.y;
                        Facets _S1893 = drawFacets((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1685, (&bsdf_sampled_0)->random_state);
                        SampleBSDF _S1894 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1685, _S1891, _S1892, _S1893, (&bsdf_sampled_0)->random_state, _S1749);
                        (&bsdf_sampled_0)->unit_direction = _S1894.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1894.refracted;
                        (&bsdf_sampled_0)->throughput = _S1894.throughput;
                        (&bsdf_sampled_0)->lobe = _S1894.lobe;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1895 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1895;
                        }
                    }
                    uint _S1896 = (&bsdf_sampled_0)->lobe;
                    float3  _S1897 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1898 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1899 = (&bsdf_sampled_0)->pdf;
                    float _S1900 = _slang_select(wrong_side_0, 0.0f,_S1899);
                    (&lobe_5)->pdf = _S1900;
                    throughput_9 = _S1897;
                    b_9 = _S1896;
                    refracted_4 = _S1898;
                }
                else
                {
                    throughput_9 = _S1867;
                    b_9 = _S1866;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1779 = true;
            }
            else
            {
                _S1779 = _S1732;
            }
            if(_S1779)
            {
                if(_S1695)
                {
                    SampleBSDF _S1901 = (fcptConnectHair((surface_12.hair), (_S1685.albedo), (_S1685.specular_tint), ((&ray_2)->unit_direction), (throughput_9)));
                    lobe_5 = _S1901;
                }
                else
                {
                    float3  _S1902 = (&ray_2)->unit_direction;
                    float3  _S1903 = negate_0(_S1902);
                    float _S1904 = sign_0(_S1663);
                    float3  _S1905 = _S1662.smooth_n * make_float3 (_S1904);
                    float _S1906 = dot_0(_S1905, throughput_9);
                    float _S1907 = _S1685.roughness;
                    float _S1908 = _S1907 * _S1907;
                    AnisotropicFrame _S1909 = anisotropicFrame(_S1685, _S1905);
                    SheenProfile _S1910 = sheenProfile(_S1903, _S1905, _S1685);
                    CoatFrame _S1911 = coatFrame(_S1685, _S1905);
                    float3  _S1912 = coatSeries(_S1911, _S1685);
                    float3  _S1913 = reflectedHalf(_S1902, throughput_9);
                    bool _S1914 = b_9 == 1U;
                    if(_S1914)
                    {
                        float3  _S1915 = refractedHalf(_S1902, throughput_9, _S1662.smooth_n, _S1686.x, _S1686.y);
                        throughput_10 = _S1915;
                    }
                    else
                    {
                        throughput_10 = _S1913;
                    }
                    float3  _S1916 = reflectedHalf(_S1902, throughput_9);
                    float3  _S1917 = _S1688.coat_h;
                    bool _S1918 = (dot_0(_S1917, _S1917)) > 0.0f;
                    float3  _S1919 = _slang_select(_S1918, _S1916,_S1472);
                    float _S1920 = _S1686.x;
                    float _S1921 = _S1686.y;
                    Weights _S1922 = lobeWeights(_S1902, _S1903, _S1905, _S1688.h, _S1688.coat_h, throughput_10, _S1919, _S1909, _S1910, _S1911, _S1912, _S1685, _S1920, _S1921);
                    float _S1923 = (F32_abs((_S1663)));
                    float _S1924 = vndfPDF(_S1903, throughput_10, _S1905, _S1923, _S1908, _S1909, _S1922.v_dot_h);
                    switch(b_9)
                    {
                    case 0U:
                        {
                            float _S1925 = diffusePDF(_S1906, _S1923, _S1685, _S1922);
                            float3  _S1926 = diffuseBSDF(throughput_9, _S1905, _S1685, _S1922);
                            density_6 = _S1925;
                            throughput_11 = _S1926;
                            break;
                        }
                    case 1U:
                        {
                            float _S1927 = refractPDF(dot_0(throughput_9, throughput_10), _S1924, _S1922, _S1920, _S1921);
                            float3  _S1928 = refractBSDF(throughput_9, _S1905, _S1908, _S1909, _S1685, _S1922);
                            density_6 = _S1927;
                            throughput_11 = _S1928;
                            break;
                        }
                    case 4U:
                        {
                            float _S1929 = sheenVelvetPDF(_S1906, _S1923, _S1922);
                            float3  _S1930 = sheenVelvetBSDF(throughput_9, _S1903, _S1905, _S1685, _S1922);
                            density_6 = _S1929;
                            throughput_11 = _S1930;
                            break;
                        }
                    case 5U:
                        {
                            float _S1931 = coatPDF(_S1903, _S1919, _S1911, _S1922);
                            float3  _S1932 = coatBSDF(_S1922);
                            density_6 = _S1931;
                            throughput_11 = _S1932;
                            break;
                        }
                    case 6U:
                        {
                            ToonProfile _S1933 = toonProfile(_S1903, _S1905, _S1685);
                            float _S1934 = toonPDF(throughput_9, _S1905, _S1933, _S1922);
                            float3  _S1935 = toonBSDF(throughput_9, _S1905, _S1933, _S1922);
                            density_6 = _S1934;
                            throughput_11 = _S1935;
                            break;
                        }
                    default:
                        {
                            float _S1936 = reflectPDF(_S1924, _S1922);
                            float3  _S1937 = reflectBSDF(throughput_9, _S1905, _S1908, _S1909, _S1922);
                            density_6 = _S1936;
                            throughput_11 = _S1937;
                            break;
                        }
                    }
                    bool _S1938 = density_6 > 0.0f;
                    if(_S1938)
                    {
                        SampleBSDF _S1939 = SampleBSDF_x24init_0(throughput_9, throughput_11, _S1687.random_state, _S1914, b_9, density_6);
                        lobe_5 = _S1939;
                    }
                }
            }
            bool _S1940 = b_9 == 0U;
            if(_S1940)
            {
                _S1780 = true;
            }
            else
            {
                _S1780 = b_9 == 4U;
            }
            if(_S1780)
            {
                _S1847 = true;
            }
            else
            {
                _S1847 = b_9 == 6U;
            }
            bool _S1941 = b_9 == 5U;
            float _S1942 = _slang_select(_S1941, _S1685.coat_roughness,_S1685.roughness);
            if(_S1695)
            {
                _S1848 = false;
            }
            else
            {
                bool _S1943 = !_S1847;
                if(_S1943)
                {
                    bool _S1944 = _S1942 == 0.0f;
                    if(_S1944)
                    {
                        _S1848 = true;
                    }
                    else
                    {
                        bool _S1945 = b_9 == 1U;
                        if(_S1945)
                        {
                            _S1848 = (_S1686.x) == (_S1686.y);
                        }
                        else
                        {
                            _S1848 = false;
                        }
                    }
                }
                else
                {
                    _S1848 = false;
                }
            }
            bool _S1946 = !_S1695;
            if(_S1946)
            {
                _S1849 = b_9 == 1U;
            }
            else
            {
                _S1849 = false;
            }
            if(_S1849)
            {
                straight_0 = (_S1685.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1850 = _S1946;
            }
            else
            {
                _S1850 = false;
            }
            if(_S1850)
            {
                _S1851 = b_9 == 1U;
            }
            else
            {
                _S1851 = false;
            }
            if(_S1851)
            {
                _S1852 = (_S1686.x) == (_S1686.y);
            }
            else
            {
                _S1852 = false;
            }
            BSDFMaterial _S1947 = _S1685;
            bool _S1948 = isTranslucent_0(&_S1947);
            if(_S1948)
            {
                _S1853 = _S1940;
            }
            else
            {
                _S1853 = false;
            }
            if(_S1853)
            {
                _S1854 = (dot_0(throughput_9, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1854 = false;
            }
            if(nee_0)
            {
                _S1855 = !_S1848;
            }
            else
            {
                _S1855 = false;
            }
            if(_S1855)
            {
                _S1856 = !wrong_side_0;
            }
            else
            {
                _S1856 = false;
            }
            if(_S1856)
            {
                float _S1949 = (&lobe_5)->pdf;
                float3  _S1950 = (&ray_2)->origin;
                float3  _S1951 = _slang_select(_S1700, _S1472,_S1662.smooth_n);
                float3  _S1952 = (&ray_2)->origin;
                FKSurface _S1953 = surface_12;
                float3  _S1954 = - _S1662.smooth_n;
                float3  _S1955 = _slang_select(_S1854, _S1954,_S1662.smooth_n);
                NEEVertex _S1956 = NEEVertex_x24init_0(false, _S1949, _S1950, _S1951, _S1952 + make_float3 (_S1953.geometry_offset) * _S1955);
                nee_vertex_0 = _S1956;
            }
            else
            {
                if(_S1695)
                {
                    _S1857 = true;
                }
                else
                {
                    bool _S1957 = b_9 != 1U;
                    if(_S1957)
                    {
                        _S1857 = true;
                    }
                    else
                    {
                        _S1857 = (_S1686.x) != (_S1686.y);
                    }
                }
                if(_S1857)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1958 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1958)
            {
                if(_S1847)
                {
                    _S1857 = true;
                }
                else
                {
                    _S1857 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1857 = false;
            }
            bool _S1959 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1959)
            {
                if(_S1847)
                {
                    _S1858 = true;
                }
                else
                {
                    _S1858 = _S1942 >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1858 = false;
            }
            if(_S1732)
            {
                bool _S1960 = !_S1857;
                if(_S1960)
                {
                    return _S1473;
                }
                bool _S1961 = _S1478 != 1U;
                if(_S1961)
                {
                    _S1859 = _S1478 != 2U;
                }
                else
                {
                    _S1859 = false;
                }
                if(_S1859)
                {
                    float _S1962 = (&lobe_5)->pdf;
                    float _S1963 = _slang_select(nee_0, _S1962,0.0f);
                    float _S1964 = escapeWeight_0(_S1963, _S1867);
                    if(_S1740)
                    {
                        passes_0 = _S1484;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1965 = _slang_select(passes_0, _S1964,1.0f);
                    return Shift_x24init_0(throughput_7 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1965) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1966 = throughput_7 * make_float3 ((&lobe_5)->pdf);
                float _S1967 = density_4 * (&lobe_5)->pdf;
                throughput_10 = _S1966;
                density_6 = _S1967;
            }
            else
            {
                throughput_10 = throughput_7;
                density_6 = density_4;
            }
            uint _S1968 = (fcptLayers((hit_4)));
            bool _S1969 = _S1968 > 1U;
            if(_S1969)
            {
                _S1859 = (b_9 == 1U) != passes_0;
            }
            else
            {
                _S1859 = false;
            }
            if(viewed_1)
            {
                _S1860 = _S1859;
            }
            else
            {
                _S1860 = false;
            }
            if(_S1860)
            {
                return _S1473;
            }
            if(replay_1)
            {
                _S1861 = b_6 <= _S1488;
            }
            else
            {
                _S1861 = false;
            }
            if(_S1861)
            {
                _S1862 = _S1661;
            }
            else
            {
                _S1862 = false;
            }
            if(_S1862)
            {
                _S1863 = _S1857;
            }
            else
            {
                _S1863 = false;
            }
            bool _S1970;
            if(_S1863)
            {
                _S1970 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1970 = !_S1858;
                }
                else
                {
                    _S1970 = false;
                }
            }
            if(_S1970)
            {
                return _S1473;
            }
            if(viewed_1)
            {
                float3  _S1971 = throughput_10 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1972 = (&lobe_5)->pdf;
                throughput_11 = _S1971;
                sky_pdf_2 = _S1972;
            }
            else
            {
                float3  _S1973 = throughput_10 * max_0((&lobe_5)->throughput, _S1472);
                throughput_11 = _S1973;
                sky_pdf_2 = density_6;
            }
            bool _S1974;
            if(_S1704)
            {
                _S1974 = !_S1719;
            }
            else
            {
                _S1974 = false;
            }
            bool _S1975;
            if(_S1974)
            {
                _S1975 = _S1661;
            }
            else
            {
                _S1975 = false;
            }
            bool _S1976;
            if(_S1975)
            {
                _S1976 = _S1857;
            }
            else
            {
                _S1976 = false;
            }
            float3  chain_throughput_1;
            if(_S1976)
            {
                chain_0 = here_0;
                uint _S1977 = insertBits_0((&chain_0)->path, b_9, 18U, 3U);
                uint _S1978 = _slang_select(nee_0, 1U,0U);
                uint _S1979 = insertBits_0(_S1977, _S1978, 21U, 1U);
                (&chain_0)->path = _S1979;
                float _S1980 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1980;
                (&chain_0)->dir = throughput_9;
                chain_throughput_1 = throughput_11;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1981 = surface_12;
            Vertex _S1982 = Vertex_x24init_0(_S1858, b_9, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_9)))), is_inside_6);
            prev_0 = _S1982;
            float _S1983 = (&lobe_5)->pdf;
            bool _S1984 = b_9 == 1U;
            bool _S1985;
            if(_S1984)
            {
                _S1985 = (_S1686.x) == (_S1686.y);
            }
            else
            {
                _S1985 = false;
            }
            float sky_pdf_3 = _slang_select(_S1985, sky_pdf_0,_S1983);
            float _S1986 = _slang_select(_S1695, 0.0f,sky_pdf_3);
            float _S1987 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1988 = !_S1848;
            float _S1989 = _slang_select(_S1988, _S1987,0.0f);
            float _S1990 = spread_1 + _S1989;
            bool _S1991;
            if(refracted_4)
            {
                _S1991 = !_S1854;
            }
            else
            {
                _S1991 = false;
            }
            bool is_inside_7;
            if(_S1991)
            {
                bool _S1992 = !is_inside_6;
                is_inside_7 = _S1992;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1993 = surface_12;
            bool _S1994 = boundsVolume_0(&_S1993);
            bool _S1995;
            if(_S1994)
            {
                _S1995 = !_S1859;
            }
            else
            {
                _S1995 = false;
            }
            if(_S1995)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1996 = - _S1981.geometry_n;
                float3  _S1997 = _slang_select(turned_1, _S1996,_S1981.geometry_n);
                (&faced_2)->geometry_n = _S1997;
                FKMedium _S1998 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1999 = (fcptOutsideMedium((hit_4)));
                FKSurface _S2000 = faced_2;
                FKMedium _S2001 = _S1998;
                FKMedium _S2002 = _S1999;
                MediumSides _S2003 = mediumSides_0(&_S2000, &_S2001, filling_2, (&ray_2)->unit_direction, &_S2002);
                bool _S2004 = ((dot_0(throughput_9, _S1981.geometry_n)) > 0.0f) == ((dot_0(_S1981.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S2005 = _slang_select(_S2004, _S2003.front.scatter,_S2003.behind.scatter);
                scatter_in_0 = _S2005;
                float3  _S2006 = scatter_in_0;
                float _S2007 = upsample(scatter_in_0, wavelength_8);
                float3  _S2008 = make_float3 (_S2007);
                float3  _S2009 = _slang_select(_S1727, _S2008,_S2006);
                scatter_in_0 = _S2009;
                float3  _S2010 = _slang_select(_S2004, _S2003.front.extinction,_S2003.behind.extinction);
                extinction_in_0 = _S2010;
                float3  _S2011 = extinction_in_0;
                float _S2012 = upsample(extinction_in_0, wavelength_8);
                float3  _S2013 = make_float3 (_S2012);
                float3  _S2014 = _slang_select(_S1727, _S2013,_S2011);
                extinction_in_0 = _S2014;
                float _S2015 = _slang_select(_S2004, _S2003.front.g,_S2003.behind.g);
                g_in_0 = _S2015;
                uint _S2016 = _S2003.fillings.x;
                uint _S2017 = _S2003.fillings.y;
                uint _S2018 = _slang_select(_S2004, _S2017,_S2016);
                bool _S2019 = (fcptVaryingUsed());
                uint _S2020 = _slang_select(_S2019, _S2018,4294967295U);
                filling_2 = _S2020;
            }
            (&ray_2)->unit_direction = throughput_9;
            bool _S2021 = !_S1859;
            if(_S2021)
            {
                FKSurface _S2022 = surface_12;
                float _S2023 = _slang_select(straight_0, 0.0f,_S2022.geometry_offset);
                float3  _S2024 = - _S1662.smooth_n;
                bool _S2025 = is_inside_7 != _S1854;
                float3  _S2026 = _slang_select(_S2025, _S2024,_S1662.smooth_n);
                float3  _S2027 = (&ray_2)->origin + make_float3 (_S2023) * _S2026;
                (&ray_2)->origin = _S2027;
            }
            throughput_10 = throughput_11;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1859;
            viewed_1 = _S1852;
            sky_pdf_2 = _S1986;
            spread_4 = _S1990;
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
        if(_S1704)
        {
            if(_S1625)
            {
                float3  _S2028 = pathColor(throughput_10 * emission_1, spectral_weight_0, wavelength_8);
                Reservoir candidate_8 = chain_0;
                uint _S2029 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S2030 = _S2029 == 1U;
                if(_S2030)
                {
                    float3  _S2031 = safeDivide(_S2028, chain_throughput_0);
                    (&candidate_8)->radiance = _S2031;
                }
                Reservoir _S2032 = withEnd(candidate_8, 2U, b_6, _S2028);
                offer(sel_7, _S2032, _S2028 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1625)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S2033 = survivalProbability(abs_0(throughput_10), density_6);
                density_7 = _S2033;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S2034 = (fcptMaxBounces());
            bool _S2035 = b_6 >= _S2034;
            if(_S2035)
            {
                wrong_side_0 = true;
            }
            else
            {
                bool _S2036 = density_7 < 1.0f;
                if(_S2036)
                {
                    uint _S2037 = noiseAddress(_S1500, b_6);
                    Random _S2038 = draw(_S2037, 8U);
                    wrong_side_0 = density_7 < (_S2038.value);
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
            float _S2039 = density_6 * density_7;
            density_7 = _S2039;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S2040 = layer_0 ^ 1U;
        uint _S2041 = _slang_select(passes_0, _S2040,0U);
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
            uint _S2042 = b_9 + 1U;
            b_6 = _S2042;
            layer_0 = _S2041;
            continue;
        }
        FKRay _S2043 = ray_2;
        float _S2044 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S1733;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1477 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S2045 = _slang_select(wrong_side_0, _S2044,4.294967296e+09f);
        bool _S2046 = !_S1695;
        if(straight_0)
        {
            _S1779 = true;
        }
        else
        {
            _S1779 = _S1695;
        }
        FKHit _S2047;
        if(_S1779)
        {
            _S2047 = hit_4;
        }
        else
        {
            _S2047 = _S1750;
        }
        FKHit _S2048 = (fcptTraverseInstanceBVH((_S2043), (_S1631), (_S2045), (_S2046), (_S2047), (viewed_1)));
        hit_4 = _S2048;
        if(replay_1)
        {
            _S1780 = _S1733;
        }
        else
        {
            _S1780 = false;
        }
        if(_S1780)
        {
            _S1847 = _S1477 == 1U;
        }
        else
        {
            _S1847 = false;
        }
        if(_S1847)
        {
            _S1848 = ((&hit_4)->instance_index) == (_S1489.instance_index);
        }
        else
        {
            _S1848 = false;
        }
        if(_S1848)
        {
            _S1849 = ((&hit_4)->triangle_index) == (_S1489.triangle_index);
        }
        else
        {
            _S1849 = false;
        }
        if(_S1849)
        {
            (&hit_4)->uv = _S1489.uv;
            float _S2049 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S2049;
        }
        if(replay_1)
        {
            _S1850 = _S1733;
        }
        else
        {
            _S1850 = false;
        }
        if(_S1850)
        {
            _S1851 = _S1477 == 3U;
        }
        else
        {
            _S1851 = false;
        }
        if(_S1851)
        {
            _S1852 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1852 = false;
        }
        if(_S1852)
        {
            return _S1473;
        }
        Reservoir _S2050 = chain_0;
        uint _S2051 = filling_2;
        for(;;)
        {
            bool _S2052 = (fcptVaryingUsed());
            if(_S2052)
            {
                _S1853 = _S2051 != 4294967295U;
            }
            else
            {
                _S1853 = false;
            }
            if(_S1853)
            {
                float _S2053 = (fcptMajorant((_S2051)));
                _S1854 = _S2053 > 0.0f;
            }
            else
            {
                _S1854 = any_1(scatter_in_0 > make_float3 (0.0f));
            }
            if(replay_1)
            {
                _S1855 = _S1733;
            }
            else
            {
                _S1855 = false;
            }
            if(_S1855)
            {
                _S1856 = _S1477 == 1U;
            }
            else
            {
                _S1856 = false;
            }
            if(_S1856)
            {
                _S1857 = _S1854;
            }
            else
            {
                _S1857 = false;
            }
            if(_S1857)
            {
                ended_0 = _S1473;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_4 = width_3;
                density_3 = density_7;
                throughput_11 = throughput_10;
                b_9 = b_6;
                _S1858 = true;
                break;
            }
            bool _S2054 = (&prev_0)->rough;
            if(_S2054)
            {
                _S1858 = !_S1854;
            }
            else
            {
                _S1858 = false;
            }
            (&prev_0)->rough = _S1858;
            uint _S2055 = b_6 + 320U;
            bool _S2056 = b_6 == 4294967295U;
            uint _S2057 = _slang_select(_S2056, 384U,_S2055);
            uint _S2058 = stream(_S1500, _S2057);
            uint tracking_1 = _S2058;
            weight_2 = throughput_3;
            glowed_0 = _S1472;
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
                    _S1471 = int(2);
                    break;
                }
                float _S2059 = (&hit_4)->distance;
                if(_S1853)
                {
                    float3  _S2060 = (&ray_2)->origin;
                    float3  _S2061 = (&ray_2)->unit_direction;
                    float _S2062 = (&hit_4)->distance;
                    bool _S2063 = b_9 == 4294967295U;
                    uint _S2064 = _slang_select(_S2063, 0U,b_9);
                    uint _S2065 = (&prev_0)->lobe;
                    uint _S2066 = _slang_select(_S2063, 3U,_S2065);
                    float _S2067 = (fcptTrackMedium((_S2051), (_S2060), (_S2061), (_S2062), (&tracking_1), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S2064), (_S2066), (_S2063)));
                    spread_3 = _S2067;
                }
                else
                {
                    if(_S1854)
                    {
                        uint _S2068 = noiseAddress(_S1500, b_9);
                        Random _S2069 = draw(_S2068, 10U);
                        float _S2070 = 3.0f * _S2069.value;
                        uint _S2071 = (U32_min((uint(_S2070)), (2U)));
                        float _S2072 = - (F32_log((1.0f - (_S2070 - float(_S2071))))) / *_slang_vector_get_element_ptr(&scatter_in_0, _S2071);
                        spread_3 = _S2072;
                    }
                    else
                    {
                        spread_3 = _S2059;
                    }
                }
                bool _S2073 = !(spread_3 < ((&hit_4)->distance));
                if(_S2073)
                {
                    _S1471 = int(2);
                    break;
                }
                if(_S1853)
                {
                    _S1859 = _S1704;
                }
                else
                {
                    _S1859 = false;
                }
                if(_S1859)
                {
                    float3  _S2074 = pathColor(throughput_11 * glowed_0, spectral_weight_0, wavelength_8);
                    float3  _S2075 = _S2074 / make_float3 (density_3);
                    float3  _S2076 = sel_7->glow + _S2075;
                    sel_7->glow = _S2076;
                }
                else
                {
                }
                glowed_0 = _S1472;
                uint b_10 = b_9 + 1U;
                float3  _S2077 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S2077;
                float3  _S2078 = flightWeight_0(scatter_in_0, extinction_in_0, spread_3, true);
                float3  _S2079 = weight_2;
                float _S2080 = upsample(weight_2, wavelength_8);
                float3  _S2081 = make_float3 (_S2080);
                float3  _S2082 = _slang_select(_S1727, _S2081,_S2079);
                float3  _S2083 = _slang_select(_S1853, _S2082,_S2078);
                float3  throughput_12 = throughput_11 * _S2083;
                uint _S2084 = stream(_S1500, b_10 + 320U);
                tracking_1 = _S2084;
                weight_2 = throughput_3;
                float width_7 = width_4 + spread_2 * spread_3;
                float _S2085 = spread_2 + 3.14159274101257324f;
                if(_S1704)
                {
                    _S1860 = true;
                }
                else
                {
                    bool _S2086 = b_10 == _S1488;
                    if(_S2086)
                    {
                        _S1860 = !_S1853;
                    }
                    else
                    {
                        _S1860 = false;
                    }
                }
                TreeSample light_4;
                if(_S1860)
                {
                    float3  _S2087 = (&ray_2)->origin;
                    float3  _S2088 = (&ray_2)->unit_direction;
                    float3  _S2089 = (&ray_2)->unit_direction;
                    uint _S2090 = noiseAddress(_S1500, b_10);
                    float3  _S2091 = extinction_in_0;
                    float3  _S2092 = extinction_in_0;
                    uint2  _S2093 = make_uint2 (_S2051);
                    float3  _S2094 = (&ray_2)->unit_direction;
                    uint _S2095 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                    FKHit _S2096 = _S1750;
                    ShadowContext _S2097 = ShadowContext_x24init_0(_S2091, _S2092, _S2093, _S2094, b_10, _S2095, false, spread_3, width_7, &_S2096, false);
                    ShadowContext _S2098 = _S2097;
                    TreeSample _S2099 = sampleLightTree_0(_S2087, _S2088, _S2089, 0.0f, true, _S2090, &_S2098);
                    light_4 = _S2099;
                }
                else
                {
                    light_4 = _S1747;
                }
                float _S2100 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S2101 = (fcptMaxBounces());
                bool _S2102 = b_10 < _S2101;
                if(_S2102)
                {
                    _S1861 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1861 = false;
                }
                float _S2103 = _slang_select(_S1861, _S2100,0.0f);
                float3  _S2104 = throughput_12 * light_4.radiance;
                float _S2105 = powerHeuristic(light_4.density, _S2103);
                float3  _S2106 = pathColor(_S2104 * make_float3 (_S2100 * _S2105), spectral_weight_0, wavelength_8);
                float3  _S2107 = _slang_select(_S1860, _S2106,_S1472);
                if(replay_1)
                {
                    _S1862 = b_10 == _S1488;
                }
                else
                {
                    _S1862 = false;
                }
                if(_S1862)
                {
                    bool _S2108 = _S1477 == 2U;
                    if(_S2108)
                    {
                        float _S2109 = resamplingTarget(_S2107);
                        _S1863 = _S2109 > 0.0f;
                    }
                    else
                    {
                        _S1863 = false;
                    }
                    if(_S1863)
                    {
                        Shift _S2110 = Shift_x24init_0(_S2107, 1.0f);
                        _S1471 = int(1);
                        ended_0 = _S2110;
                        spread_3 = _S2085;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_7 = b_10;
                        break;
                    }
                    _S1471 = int(1);
                    ended_0 = _S1473;
                    spread_3 = _S2085;
                    width_5 = width_7;
                    throughput_9 = throughput_12;
                    b_7 = b_10;
                    break;
                }
                if(_S1704)
                {
                    Reservoir candidate_9 = _S2050;
                    uint _S2111 = extractBits_0(_S2050.path, 24U, 8U);
                    uint _S2112 = insertBits_0(0U, _S2111, 24U, 8U);
                    uint _S2113 = extractBits_0(_S2050.path, 10U, 2U);
                    bool _S2114 = _S2113 == 1U;
                    if(_S2114)
                    {
                        float3  _S2115 = safeDivide(_S2107, chain_throughput_0);
                        (&candidate_9)->radiance = _S2115;
                    }
                    else
                    {
                        uint _S2116 = insertBits_0(_S2112, b_10 + 1U, 5U, 5U);
                        uint _S2117 = insertBits_0(_S2116, 2U, 10U, 2U);
                        (&candidate_9)->path = _S2117;
                    }
                    Reservoir _S2118 = withEnd(candidate_9, 0U, b_10, _S2107);
                    offer(sel_7, _S2118, _S2107 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S2119 = survivalProbability(abs_0(throughput_12), density_3);
                    uint _S2120 = (fcptMaxBounces());
                    bool _S2121 = b_10 >= _S2120;
                    if(_S2121)
                    {
                        _S1863 = true;
                    }
                    else
                    {
                        bool _S2122 = _S2119 < 1.0f;
                        if(_S2122)
                        {
                            uint _S2123 = noiseAddress(_S1500, b_10);
                            Random _S2124 = draw(_S2123, 8U);
                            _S1863 = _S2119 < (_S2124.value);
                        }
                        else
                        {
                            _S1863 = false;
                        }
                    }
                    if(_S1863)
                    {
                        _S1471 = int(1);
                        ended_0 = _S1473;
                        spread_3 = _S2085;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_7 = b_10;
                        break;
                    }
                    float _S2125 = density_3 * _S2119;
                    density_3 = _S2125;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S2126 = noiseAddress(_S1500, b_10);
                float3  _S2127 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S2126, &phase_pdf_1);
                (&ray_2)->unit_direction = _S2127;
                NEEVertex _S2128 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1472, (&ray_2)->origin);
                nee_vertex_0 = _S2128;
                Vertex _S2129 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
                prev_0 = _S2129;
                float _S2130 = (&prev_0)->pdf;
                FKRay _S2131 = ray_2;
                FKHit _S2132 = (fcptTraverseInstanceBVH((_S2131), (true), (4.294967296e+09f), (false), (_S1750), (false)));
                hit_4 = _S2132;
                b_9 = b_10;
                throughput_11 = throughput_12;
                spread_2 = _S2085;
                width_4 = width_7;
                sky_pdf_1 = _S2130;
            }
            if(_S1471 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_11 = throughput_9;
                b_9 = b_7;
                _S1858 = true;
                break;
            }
            ended_0 = _S1473;
            _S1858 = false;
            break;
        }
        if(_S1858)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1859 = b_9 == b_6;
        }
        else
        {
            _S1859 = false;
        }
        bool _S2133 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S2133)
        {
            bool _S2134 = !(&nee_vertex_0)->none;
            float _S2135 = _slang_select(_S2134, sky_pdf_1,0.0f);
            float _S2136 = escapeWeight_0(_S2135, (&ray_2)->unit_direction);
            float3  _S2137 = environment_0((&ray_2)->unit_direction, b_9, (&prev_0)->lobe);
            float3  _S2138 = pathColor(throughput_11 * _S2137, spectral_weight_0, wavelength_8);
            if(replay_1)
            {
                bool _S2139 = b_9 == _S1488;
                if(_S2139)
                {
                    passes_0 = _S1477 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S2138 * make_float3 (_S2136) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1487)
                {
                    passes_0 = _S1484;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_9 == _S1475;
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
                    return Shift_x24init_0(_S2138 * make_float3 (_S2136), 1.0f);
                }
                return _S1473;
            }
            Reservoir candidate_10 = chain_0;
            uint _S2140 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S2141 = _S2140 == 1U;
            if(_S2141)
            {
                uint _S2142 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S2143 = _S2142 == b_9;
                float _S2144 = _slang_select(_S2143, 1.0f,_S2136);
                float3  _S2145 = safeDivide(_S2138 * make_float3 (_S2144), chain_throughput_0);
                (&candidate_10)->radiance = _S2145;
            }
            else
            {
                bool _S2146 = (&prev_0)->rough;
                if(_S2146)
                {
                    uint _S2147 = insertBits_0(_S1502, b_9 + 1U, 5U, 5U);
                    uint _S2148 = insertBits_0(_S2147, 3U, 10U, 2U);
                    uint _S2149 = insertBits_0(_S2148, (&prev_0)->lobe, 15U, 3U);
                    bool _S2150 = (&prev_0)->inside;
                    uint _S2151 = _slang_select(_S2150, 1U,0U);
                    uint _S2152 = insertBits_0(_S2149, _S2151, 22U, 1U);
                    (&candidate_10)->path = _S2152;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S2153 = _S2138 * make_float3 (_S2136);
            Reservoir _S2154 = withEnd(candidate_10, 3U, b_9, _S2153);
            offer(sel_7, _S2154, _S2153 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S2155 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S2155;
        bool _S2156 = (fcptVaryingUsed());
        if(_S2156)
        {
            _S1860 = filling_2 != 4294967295U;
        }
        else
        {
            _S1860 = false;
        }
        if(_S1860)
        {
            if(_S1704)
            {
                float3  _S2157 = pathColor(throughput_11 * glowed_0, spectral_weight_0, wavelength_8);
                float3  _S2158 = _S2157 / make_float3 (density_3);
                float3  _S2159 = sel_7->glow + _S2158;
                sel_7->glow = _S2159;
            }
            float3  _S2160 = throughput_11 * weight_2;
            throughput_9 = _S2160;
        }
        else
        {
            float3  _S2161 = flightWeight_0(scatter_in_0, extinction_in_0, (&hit_4)->distance, false);
            float3  _S2162 = throughput_11 * _S2161;
            throughput_9 = _S2162;
        }
        float _S2163 = width_4 + spread_2 * (&hit_4)->distance;
        viewed_0 = _S1859;
        width_3 = _S2163;
        throughput_2 = throughput_9;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S2042 = b_9 + 1U;
        b_6 = _S2042;
        layer_0 = _S2041;
    }
    return _S1473;
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
    Random _S2164 = pcg(state_4);
    Random _S2165 = pcg(_S2164.state);
    float _S2166 = 6.28318548202514648f * _S2164.value;
    float _S2167 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S2165.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S2165.state, _S2167 * (F32_cos((_S2166))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S2168;
    (&_S2168)->state = state_5;
    (&_S2168)->value = value_2;
    return _S2168;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S2169 = normal_distribution(state_6);
    Random _S2170 = normal_distribution(_S2169.state);
    Random _S2171 = normal_distribution(_S2170.state);
    float3  _S2172 = make_float3 (_S2169.value, _S2170.value, _S2171.value);
    float3  _S2173 = ((((_S2172)) * make_float3(rnorm3df(((_S2172)).x, ((_S2172)).y, ((_S2172)).z))));
    return RandomSphere_x24init_0(_S2171.state, _S2173);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_13)
{
    float3  _S2174 = p1_0 - p0_0;
    float3  _S2175 = p2_0 - p0_0;
    float2  _S2176 = uv1_0 - uv0_0;
    float2  _S2177 = uv2_0 - uv0_0;
    float _S2178 = _S2176.x;
    float _S2179 = _S2177.y;
    float _S2180 = _S2176.y;
    float _S2181 = _S2177.x;
    float _S2182 = _S2178 * _S2179 - _S2180 * _S2181;
    float _S2183 = 1.0f / _S2182;
    float3  t_24 = (_S2174 * make_float3 (_S2179) - _S2175 * make_float3 (_S2180)) * make_float3 (_S2183);
    float3  _S2184 = (_S2175 * make_float3 (_S2178) - _S2174 * make_float3 (_S2181)) * make_float3 (_S2183);
    float3  _S2185 = t_24 - n_13 * make_float3 (dot_0(n_13, t_24));
    float3  _S2186 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_13);
    bool _S2187 = (dot_0(_S2185, _S2185)) > 0.0f;
    float3  _S2188 = _slang_select(_S2187, _S2185,_S2186);
    float3  _S2189 = ((((_S2188)) * make_float3(rnorm3df(((_S2188)).x, ((_S2188)).y, ((_S2188)).z))));
    bool _S2190 = (dot_0(cross_0(n_13, _S2189), _S2184)) > 0.0f;
    float3  t_25;
    if(_S2190)
    {
        float3  _S2191 = negate_0(_S2189);
        t_25 = _S2191;
    }
    else
    {
        t_25 = _S2189;
    }
    float3  _S2192 = cross_0(n_13, t_25);
    return makeMatrix<float, 3, 3> (t_25, _S2192, n_13);
}

__device__ float3  tangentToWorldNormalMap(float3  v_13, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_13, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_0)
{
    float3  _S2193 = t1_0 - t0_0;
    float3  _S2194 = t2_2 - t0_0;
    float3  _S2195 = t2_2 - t1_0;
    float _S2196 = (F32_min((length_0(_S2193)), ((F32_min((length_0(_S2194)), (length_0(_S2195)))))));
    float3  _S2197 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S2198 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S2199 = dot_0(geometry_n_4, _S2198);
    float3  _S2200 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S2201 = dot_0(geometry_n_4, _S2200);
    float3  _S2202 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S2203 = acos_0(abs_0(make_float3 (_S2199, _S2201, dot_0(geometry_n_4, _S2202))));
    float3  _S2204 = clamp_2(tan_0(_S2203), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S2197 * _S2204, uvw_0), 0.0f, _S2196 * 0.125f);
}

__device__ float3  straightThrough(BSDFMaterial material_29)
{
    return make_float3 (material_29.transmission * (1.0f - material_29.metallic)) * material_29.albedo;
}

__device__ float hairRow(float3  in_dir_13, float3  t_26, float3  out_dir_3, uint p_15, float w_20, float alpha_10, uint nt_0)
{
    uint _S2205 = p_15 % 4U;
    float _S2206 = w_20 * HAIR_WIDTHS_0[_S2205];
    float _S2207 = (F32_asin((clamp_1(dot_0(out_dir_3, t_26), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_13, t_26), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S2205] * alpha_10;
    return ((F32_asinh((_S2207 / _S2206))) / (F32_asinh((3.14159274101257324f / _S2206))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_14, float3  t_27, float3  out_dir_4, uint np_0)
{
    float3  _S2208 = worldToTangent(out_dir_4, t_27);
    float3  _S2209 = worldToTangent(in_dir_14, t_27);
    return (F32_frac((((F32_atan2((_S2208.z), (_S2208.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S2209.z), (1.17549435082228751e-38f - _S2209.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_15, float3  t_28, uint p_16, float row_0, float column_0, float w_21, float alpha_11, uint nt_1, uint np_1)
{
    float3  _S2210 = worldToTangent(in_dir_15, t_28);
    uint _S2211 = p_16 % 4U;
    float _S2212 = w_21 * HAIR_WIDTHS_0[_S2211];
    float _S2213 = (F32_asin((clamp_1(dot_0(in_dir_15, t_28), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S2211] * alpha_11 + _S2212 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S2212))))));
    float _S2214 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S2210.z), (1.17549435082228751e-38f - _S2210.x)));
    float _S2215 = (F32_cos((_S2213)));
    float3  _S2216 = tangentToWorld(make_float3 (_S2215 * (F32_cos((_S2214))), (F32_sin((_S2213))), _S2215 * (F32_sin((_S2214)))), t_28);
    return _S2216;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_14, BSDFMaterial material_30, float coverage_1)
{
    float3  through_2;
    if((material_30.ior) == 1.0f)
    {
        float3  _S2217 = straightThrough(material_30);
        through_2 = _S2217;
    }
    else
    {
        through_2 = make_float3 (0.0f);
    }
    CoatFrame _S2218 = coatFrame(material_30, n_14);
    bool _S2219 = (_S2218.ior) > 0.0f;
    if(_S2219)
    {
        float _S2220 = fresnel((F32_abs((dot_0(_S2218.normal, toward_1)))), 1.0f, _S2218.ior);
        float3  _S2221 = mix_0(make_float3 (1.0f), make_float3 (1.0f - _S2220) * material_30.coat_tint, material_30.coat);
        float3  through_3 = through_2 * _S2221;
        through_2 = through_3;
    }
    return through_2 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_8, Reservoir r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    Domain _S2222 = dom_8;
    Reservoir _S2223 = r_9;
    Shift _S2224 = walk_0(&_S2222, &_S2223, replay_2, scale_4, sel_8);
    return _S2224;
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

__device__ uint noiseWhite(uint x_29, uint y_8, uint t_29, uint size_0)
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
        uint _S2225;
        if(i_27 < 2U)
        {
            _S2225 = x_29;
        }
        else
        {
            _S2225 = (x_29 + size_0 / 2U) & (size_0 - 1U);
        }
        uint l_6 = _S2225;
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
            uint _S2226 = hash(((r_10 ^ (t_29 << 16U)) ^ (k_4 << 28U)) ^ ((i_27 & 1U) << 31U));
            uint _S2227 = l_6 ^ (_S2226 & (size_0 - 1U));
            uint k_5 = k_4 + 1U;
            l_6 = r_10;
            r_10 = _S2227;
            k_4 = k_5;
        }
        uint _S2228 = l_6 + r_10 * size_0;
        uint _S2229 = size_0 * size_0;
        uint _S2230;
        if(_S2229 >= 65536U)
        {
            uint _S2231 = _S2228 / (_S2229 / 65536U);
            _S2230 = _S2231;
        }
        else
        {
            uint _S2232 = 65536U / _S2229;
            _S2230 = _S2228 * _S2232;
        }
        ranks_0[i_27] = _S2230;
        uint i_28 = i_27 + 1U;
        i_27 = i_28;
    }
    bool _S2233 = (ranks_0[int(0)]) == 65535U;
    bool _S2234;
    if(_S2233)
    {
        _S2234 = (ranks_0[int(1)]) == 65535U;
    }
    else
    {
        _S2234 = false;
    }
    bool _S2235 = (ranks_0[int(2)]) == 65535U;
    bool _S2236;
    if(_S2235)
    {
        _S2236 = (ranks_0[int(3)]) == 65535U;
    }
    else
    {
        _S2236 = false;
    }
    if(_S2234)
    {
        _S2234 = (ranks_0[int(3)]) != 65535U;
    }
    else
    {
        _S2234 = false;
    }
    if(_S2234)
    {
        _S2234 = true;
    }
    else
    {
        if(_S2236)
        {
            _S2234 = (ranks_0[int(1)]) != 65535U;
        }
        else
        {
            _S2234 = false;
        }
    }
    uint _S2237 = ranks_0[int(0)];
    if(_S2234)
    {
        i_27 = ranks_0[int(3)];
    }
    else
    {
        i_27 = ranks_0[int(1)];
    }
    return _S2237 | (i_27 << 16U);
}

__device__ uint3  noiseBlock(uint sweep_0, uint colour_0, uint block_0, uint size_1)
{
    uint _S2238 = hash(sweep_0 * 7919U + 1U);
    uint _S2239 = size_1 / 16U;
    uint _S2240 = block_0 % _S2239;
    uint _S2241 = block_0 / _S2239;
    uint _S2242 = _S2241 % _S2239;
    uint _S2243 = block_0 / (_S2239 * _S2239);
    uint3  _S2244 = make_uint3 (_S2240, _S2242, _S2243);
    uint3  _S2245 = make_uint3 (colour_0 & 1U, (colour_0 >> 1U) & 1U, colour_0 >> 2U);
    return _S2244 * make_uint3 (16U) + _S2245 * make_uint3 (8U) + make_uint3 (_S2238 & 7U, (_S2238 >> 3U) & 7U, (_S2238 >> 6U) & 7U);
}

#undef Matrix
