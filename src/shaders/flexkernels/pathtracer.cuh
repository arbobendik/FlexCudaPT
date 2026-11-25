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

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S376;
    (&_S376)->on = on_0;
    (&_S376)->albedo = albedo_0;
    return _S376;
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
    SheenProfile _S377 = SheenProfile_x24init_0(false, 0.0f);
    float _S378 = rgb_to_greyscale(material_3.sheen);
    bool _S379 = _S378 > 0.0f;
    SheenProfile profile_0;
    if(_S379)
    {
        float _S380 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S381 = (U32_min((uint(_S380)), (22U)));
        float _S382 = (F32_sqrt((0.05000000074505806f)));
        float _S383 = (F32_sqrt((0.10000000149011612f)));
        bool _S384 = (material_3.velvet) > 0.0f;
        float _S385 = _slang_select(_S384, _S383,_S382);
        float _S386 = (clamp_1((F32_sqrt(((F32_max((material_3.sheen_roughness), (0.0f)))))), _S385, 1.0f) - _S385) / (1.0f - _S385) * 23.0f;
        uint _S387 = (U32_min((uint(_S386)), (22U)));
        uint _S388 = _S381 * 24U + _S387;
        float _S389 = _S380 - float(_S381);
        float _S390 = _S386 - float(_S387);
        if(_S384)
        {
            uint _S391 = _S388 + 24U;
            float _S392 = VELVET_ALBEDO_0[_S388] + (VELVET_ALBEDO_0[_S391] - VELVET_ALBEDO_0[_S388]) * _S389;
            uint _S393 = _S388 + 1U;
            float _S394 = VELVET_ALBEDO_0[_S393] + (VELVET_ALBEDO_0[_S391 + 1U] - VELVET_ALBEDO_0[_S393]) * _S389;
            SheenProfile _S395 = SheenProfile_x24init_0(true, _S392 + (_S394 - _S392) * _S390);
            profile_0 = _S395;
        }
        else
        {
            uint _S396 = _S388 + 24U;
            float _S397 = SHEEN_ALBEDO_0[_S388] + (SHEEN_ALBEDO_0[_S396] - SHEEN_ALBEDO_0[_S388]) * _S389;
            uint _S398 = _S388 + 1U;
            float _S399 = SHEEN_ALBEDO_0[_S398] + (SHEEN_ALBEDO_0[_S396 + 1U] - SHEEN_ALBEDO_0[_S398]) * _S389;
            SheenProfile _S400 = SheenProfile_x24init_0(true, (F32_exp((_S397 + (_S399 - _S397) * _S390))));
            profile_0 = _S400;
        }
    }
    else
    {
        profile_0 = _S377;
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
    CoatFrame _S401;
    (&_S401)->normal = normal_3;
    (&_S401)->alpha = alpha_0;
    (&_S401)->ior = ior_0;
    return _S401;
}

__device__ __forceinline__ CoatFrame coatFrame(BSDFMaterial material_4, float3  n_2)
{
    CoatFrame _S402 = CoatFrame_x24init_0(make_float3 (0.0f), 0.0f, 0.0f);
    bool _S403 = (material_4.coat) > 0.0f;
    CoatFrame frame_0;
    if(_S403)
    {
        float3  _S404 = material_4.coat_normal;
        bool _S405 = (dot_0(_S404, _S404)) > 0.0f;
        float3  _S406 = material_4.coat_normal;
        float3  _S407 = ((((_S406)) * make_float3(rnorm3df(((_S406)).x, ((_S406)).y, ((_S406)).z))));
        float3  _S408 = _slang_select(_S405, _S407,n_2);
        float _S409 = sign_0(dot_0(_S408, n_2));
        float _S410 = material_4.coat_roughness;
        CoatFrame _S411 = CoatFrame_x24init_0(_S408 * make_float3 (_S409), _S410 * _S410, (F32_max((material_4.coat_ior), (1.00999999046325684f))));
        frame_0 = _S411;
    }
    else
    {
        frame_0 = _S402;
    }
    return frame_0;
}

__device__ __forceinline__ float3  coatSeries(CoatFrame coat_frame_0, BSDFMaterial material_5)
{
    float3  _S412 = make_float3 (0.0f);
    bool _S413 = (coat_frame_0.ior) > 0.0f;
    float3  series_0;
    if(_S413)
    {
        float _S414 = coat_frame_0.ior * coat_frame_0.ior;
        float _S415 = _S414 * _S414;
        float _S416 = coat_frame_0.ior - 1.0f;
        float _S417 = coat_frame_0.ior + 1.0f;
        float _S418 = _S414 - 1.0f;
        float _S419 = _S414 + 1.0f;
        float _S420 = _S415 - 1.0f;
        float _S421 = _S419 * _S420;
        float _S422 = 0.5f + _S416 * (3.0f * coat_frame_0.ior + 1.0f) / (6.0f * _S417 * _S417) + _S414 * _S418 * _S418 / (_S419 * _S419 * _S419) * (F32_log((_S416 / _S417))) - 2.0f * _S414 * coat_frame_0.ior * (_S414 + 2.0f * coat_frame_0.ior - 1.0f) / _S421 + 8.0f * _S415 * (_S415 + 1.0f) / (_S421 * _S420) * (F32_log((coat_frame_0.ior)));
        float _S423 = 1.0f - (1.0f - _S422) / _S414;
        float3  _S424 = material_5.coat_tint;
        float3  _S425 = _S424 * _S424 * make_float3 (1.0f - _S423) / (make_float3 (1.0f) - material_5.albedo * make_float3 (_S423));
        series_0 = _S425;
    }
    else
    {
        series_0 = _S412;
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

static __device__ float3  refract_0(float3  i_5, float3  n_3, float eta_0)
{
    float _S426 = dot_0(n_3, i_5);
    float _S427 = 1.0f - eta_0 * eta_0 * (1.0f - _S426 * _S426);
    if(_S427 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S426 + (F32_sqrt((_S427)))) * n_3;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S428 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S429 = eta_i_0 / eta_o_0 * _S428;
    bool _S430 = _S429 < 1.0f;
    float kr_0;
    if(_S430)
    {
        float _S431 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S429 * _S429))))));
        bool _S432 = eta_i_0 == eta_o_0;
        float _S433 = _slang_select(_S432, cos_theta_0,_S431);
        float _S434 = eta_o_0 * cos_theta_0;
        float _S435 = eta_i_0 * _S433;
        float _S436 = (_S434 - _S435) / (_S434 + _S435);
        float _S437 = eta_i_0 * cos_theta_0;
        float _S438 = eta_o_0 * _S433;
        float _S439 = (_S437 - _S438) / (_S437 + _S438);
        float _S440 = (_S436 * _S436 + _S439 * _S439) / 2.0f;
        kr_0 = _S440;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

static __device__ float3  min_1(float3  x_14, float3  y_4)
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
        *_slang_vector_get_element_ptr(&result_5, i_6) = (F32_min((_slang_vector_get_element(x_14, i_6)), (_slang_vector_get_element(y_4, i_6))));
        i_6 = i_6 + int(1);
    }
    return result_5;
}

static __device__ float3  reflect_0(float3  i_7, float3  n_4)
{
    return i_7 - make_float3 (2.0f * dot_0(n_4, i_7)) * n_4;
}

__device__ float smithG1(float alpha_1, float n_dot_x_0)
{
    float _S441 = alpha_1 * alpha_1;
    float _S442 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S441 + (1.0f - _S441) * n_dot_x_0 * n_dot_x_0))));
    bool _S443 = alpha_1 > 0.0f;
    float _S444 = _slang_select(_S443, _S442,1.0f);
    return _S444;
}

__device__ __forceinline__ float coatFresnel(float3  in_dir_0, float3  v_2, float3  coat_h_0, CoatFrame coat_frame_1, float eta_i_1, bool behind_0)
{
    float _S445 = dot_0(coat_frame_1.normal, reflect_0(in_dir_0, coat_h_0));
    float _S446 = (F32_abs((dot_0(v_2, coat_h_0))));
    float _S447 = eta_i_1 / coat_frame_1.ior * (F32_sqrt(((F32_max((1.0f - _S446 * _S446), (0.0f))))));
    float _S448 = (F32_sqrt(((F32_max((1.0f - _S447 * _S447), (0.0f))))));
    float _S449 = _slang_select(behind_0, _S448,_S446);
    float _S450 = _slang_select(behind_0, coat_frame_1.ior,1.0f);
    float _S451 = _slang_select(behind_0, 1.0f,coat_frame_1.ior);
    float _S452 = fresnel(_S449, _S450, _S451);
    float _S453 = smithG1(coat_frame_1.alpha, _S445);
    float _S454 = _S452 * _S453;
    bool _S455 = _S445 > 0.0f;
    float _S456 = _slang_select(_S455, _S454,0.0f);
    return _S456;
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

static __device__ Weights Weights_x24init_0(float v_dot_h_0, float3  refracted_1, float3  F_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float p_sheen_velvet_0, float p_toon_0, float3  sheen_0, float3  toon_0, float3  coat_0, float p_coat_0)
{
    Weights _S457;
    (&_S457)->v_dot_h = v_dot_h_0;
    (&_S457)->refracted = refracted_1;
    (&_S457)->F = F_0;
    (&_S457)->reflect_weight = reflect_weight_0;
    (&_S457)->diffuse_weight = diffuse_weight_0;
    (&_S457)->refract_weight = refract_weight_0;
    (&_S457)->p_diffuse = p_diffuse_0;
    (&_S457)->p_reflect = p_reflect_0;
    (&_S457)->p_refract = p_refract_0;
    (&_S457)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S457)->p_toon = p_toon_0;
    (&_S457)->sheen = sheen_0;
    (&_S457)->toon = toon_0;
    (&_S457)->coat = coat_0;
    (&_S457)->p_coat = p_coat_0;
    return _S457;
}

__device__ __forceinline__ Weights lobeWeights(float3  in_dir_1, float3  v_3, float3  n_i_2, float3  ggx_n_0, float3  coat_h_1, AnisotropicFrame frame_1, SheenProfile sheen_profile_0, CoatFrame coat_frame_2, float3  coat_series_0, BSDFMaterial material_6, float eta_i_2, float eta_o_1)
{
    float _S458 = dot_0(ggx_n_0, v_3);
    float _S459 = eta_i_2 / eta_o_1;
    float3  _S460 = refract_0(in_dir_1, ggx_n_0, _S459);
    float3  _S461 = ((((_S460)) * make_float3(rnorm3df(((_S460)).x, ((_S460)).y, ((_S460)).z))));
    float _S462 = (F32_min(((F32_sqrt((material_6.specular_level))) * (F32_abs((eta_i_2 - eta_o_1))) / (eta_i_2 + eta_o_1)), (0.9999847412109375f)));
    float _S463 = _S462 * _S462;
    float _S464 = (1.0f + _S462) / (1.0f - _S462);
    float _S465 = (F32_abs((_S458)));
    bool _S466 = eta_i_2 > eta_o_1;
    float sheen_component_0;
    if(_S466)
    {
        sheen_component_0 = _S464;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float toon_component_0;
    if(_S466)
    {
        toon_component_0 = 1.0f;
    }
    else
    {
        toon_component_0 = _S464;
    }
    float _S467 = fresnel(_S465, sheen_component_0, toon_component_0);
    bool _S468 = (eta_i_2 * eta_i_2 * (1.0f - _S458 * _S458)) >= (eta_o_1 * eta_o_1);
    float3  _S469;
    if(_S468)
    {
        _S469 = make_float3 (1.0f);
    }
    else
    {
        float3  _S470 = material_6.specular_tint * make_float3 (_S463);
        _S469 = _S470 + (make_float3 (1.0f) - _S470) * make_float3 (_S467 - _S463) / make_float3 (1.0f - _S463);
    }
    float3  _S471 = make_float3 (1.0f);
    float3  _S472 = make_float3 (0.0f);
    float3  sheen_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S473 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S474 = make_float3 (1.0f) - material_6.sheen * make_float3 (_S473);
        float _S475 = rgb_to_greyscale(material_6.sheen);
        float _S476 = _S475 * _S473;
        float3  _S477 = material_6.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S476;
        sheen_1 = _S477;
        scale_1 = _S474;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S472;
        scale_1 = _S471;
    }
    float _S478 = (F32_abs((material_6.toon.x)));
    bool _S479 = _S478 > 0.0f;
    float3  toon_1;
    if(_S479)
    {
        float _S480 = (F32_min((_S478), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S480);
        float _S481 = rgb_to_greyscale(material_6.albedo);
        float _S482 = _S480 * _S481;
        float3  _S483 = make_float3 (_S480) * material_6.albedo;
        toon_component_0 = _S482;
        toon_1 = _S483;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S472;
    }
    bool _S484 = (material_6.metallic) > 0.0f;
    float3  rebounce_0;
    if(_S484)
    {
        float _S485 = frame_1.alphas.x;
        float _S486 = (F32_sqrt(((F32_min((_S485), (frame_1.alphas.y))))));
        bool _S487 = _S485 > 0.0f;
        float _S488 = _slang_select(_S487, _S486,material_6.roughness);
        float _S489 = _S488 * _S488;
        float _S490 = (F32_pow((_S489), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S489) / (1.0f + 1.28094995021820068f * _S489);
        bool _S491 = _S489 > 0.0f;
        float _S492 = _slang_select(_S491, _S490,0.0f);
        float _S493 = clamp_1(dot_0(n_i_2, v_3), 0.0f, 1.0f);
        float _S494 = _S489 * _S488;
        float _S495 = (F32_min((1.00064504146575928f - _S488 * (0.00375499995425344f + _S493 * (-0.04133399948477745f + _S493 * (-0.90938502550125122f + _S493 * 0.35275399684906006f))) - _S489 * (0.27602800726890564f + _S493 * (1.27023398876190186f + _S493 * 0.04740000143647194f)) - _S494 * (0.31452900171279907f - _S493 * 0.34830701351165771f) + _S494 * _S488 * 0.27229699492454529f), (1.0f)));
        float3  _S496 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_6.albedo * make_float3 (_S492)), make_float3 (1.0f / (F32_max((_S495), (0.0000152587890625f)))));
        rebounce_0 = _S496;
    }
    else
    {
        rebounce_0 = _S471;
    }
    bool _S497 = (dot_0(coat_h_1, coat_h_1)) > 0.0f;
    float3  coat_1;
    float3  up_0;
    float3  through_0;
    if(_S497)
    {
        float _S498 = coatFresnel(in_dir_1, v_3, coat_h_1, coat_frame_2, eta_i_2, _S466);
        float _S499 = material_6.coat * _S498;
        float3  _S500 = material_6.coat_tint;
        float3  _S501 = _S500 * _S500;
        float3  _S502 = _slang_select(_S466, _S501,_S471);
        float3  _S503 = make_float3 (_S499) * _S502;
        float _S504 = 1.0f - _S498;
        bool _S505 = !_S466;
        float3  _S506 = _slang_select(_S505, coat_series_0,_S471);
        float3  _S507 = mix_0(_S471, make_float3 (_S504) * _S506, material_6.coat);
        float3  _S508 = mix_0(_S471, make_float3 (_S504) * material_6.coat_tint, material_6.coat);
        coat_1 = _S503;
        up_0 = _S507;
        through_0 = _S508;
    }
    else
    {
        coat_1 = _S472;
        up_0 = _S471;
        through_0 = _S471;
    }
    float3  _S509 = scale_1 * coat_1;
    float _S510 = rgb_to_greyscale(_S509);
    float3  _S511 = mix_0(_S469, material_6.albedo * rebounce_0, material_6.metallic);
    float3  F_1 = _S511 * scale_1 * up_0;
    float _S512 = rgb_to_greyscale(F_1);
    float _S513 = 1.0f - material_6.metallic;
    float3  _S514 = make_float3 (1.0f) - _S469;
    float3  _S515 = make_float3 ((1.0f - material_6.transmission) * _S513) * _S514 * scale_1 * up_0;
    float3  _S516 = make_float3 (material_6.transmission * _S513) * _S514 * scale_1 * through_0;
    float _S517 = (F32_max((_S512), (0.0f)));
    float _S518 = rgb_to_greyscale(_S515);
    float _S519 = (F32_max((_S518), (0.0f)));
    float _S520 = rgb_to_greyscale(_S516);
    float _S521 = sign_0(length_0(_S461));
    float _S522 = (F32_max((_S520 * _S521), (0.0f)));
    float _S523 = _S517 + _S519 + _S522 + toon_component_0 + _S510;
    float _S524 = (F32_min((sheen_component_0), (1.0f)));
    bool _S525 = sheen_component_0 > 0.0f;
    bool _S526;
    if(_S525)
    {
        _S526 = !(_S523 > 0.0f);
    }
    else
    {
        _S526 = false;
    }
    float _S527 = _slang_select(_S526, 1.0f,_S524);
    float _S528 = (1.0f - _S527) / (F32_max((_S523), (0.0000152587890625f)));
    float _S529 = _S519 * _S528;
    float _S530 = _S517 * _S528;
    float _S531 = _S522 * _S528;
    return Weights_x24init_0(_S458, _S461, F_1, 1.0f, _S515, _S516, _S529, _S530, _S531, _S527, toon_component_0 * _S528, sheen_1, toon_1, _S509, _S510 * _S528);
}

__device__ float translucentShare(BSDFMaterial material_7)
{
    float _S532 = rgb_to_greyscale(material_7.translucent);
    float _S533 = rgb_to_greyscale(material_7.albedo);
    float _S534 = _S532 / (_S533 + _S532);
    bool _S535 = _S532 > 0.0f;
    float _S536 = _slang_select(_S535, _S534,0.0f);
    return _S536;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float n_i_dot_v_0, BSDFMaterial material_8, Weights w_0)
{
    float _S537 = translucentShare(material_8);
    float _S538 = w_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S539 = w_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S540 = 1.0f - _S537;
    bool _S541 = n_i_dot_l_0 < 0.0f;
    float _S542 = _slang_select(_S541, _S537,_S540);
    float _S543 = _S539 * _S542;
    bool _S544 = _S537 > 0.0f;
    float _S545 = _slang_select(_S544, _S543,_S538);
    bool _S546 = n_i_dot_v_0 > 0.0f;
    float _S547 = _slang_select(_S546, _S545,0.0f);
    return _S547;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_3, BSDFMaterial material_9, Weights w_1)
{
    float _S548 = translucentShare(material_9);
    bool _S549 = (dot_0(n_i_3, l_0)) < 0.0f;
    float3  _S550 = _slang_select(_S549, material_9.translucent,material_9.albedo);
    float _S551 = 1.0f - _S548;
    float _S552 = _slang_select(_S549, _S548,_S551);
    float3  _S553 = _S550 / make_float3 (_S552);
    bool _S554 = _S548 > 0.0f;
    float3  _S555 = _slang_select(_S554, _S553,material_9.albedo);
    return w_1.diffuse_weight * _S555 / make_float3 (w_1.p_diffuse);
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

__device__ __forceinline__ float toonP(float t_12, float a_3, float s_0)
{
    float _S556;
    if(t_12 < a_3)
    {
        _S556 = 1.0f;
    }
    else
    {
        _S556 = (F32_max((1.0f - (t_12 - a_3) / (F32_max((s_0), (0.0000152587890625f)))), (0.0f)));
    }
    return _S556;
}

__device__ __forceinline__ float toonIntegral(float t_13, float a_4, float s_1, bool glossy_0)
{
    float integral_0;
    if(glossy_0)
    {
        integral_0 = 1.0f - (F32_cos(((F32_min((t_13), (a_4))))));
    }
    else
    {
        float _S557 = (F32_sin(((F32_min((t_13), (a_4))))));
        integral_0 = _S557 * _S557 / 2.0f;
    }
    bool _S558 = t_13 > a_4;
    bool _S559;
    if(_S558)
    {
        _S559 = s_1 > 0.0f;
    }
    else
    {
        _S559 = false;
    }
    if(_S559)
    {
        float _S560;
        if(glossy_0)
        {
            float _S561 = (F32_cos((a_4)));
            float _S562 = (F32_cos((t_13)));
            _S560 = (1.0f + a_4 / s_1) * (_S561 - _S562) - ((F32_sin((t_13))) - t_13 * _S562 - ((F32_sin((a_4))) - a_4 * _S561)) / s_1;
        }
        else
        {
            float _S563 = 2.0f * a_4;
            float _S564 = (F32_cos((_S563)));
            float _S565 = 2.0f * t_13;
            float _S566 = (F32_cos((_S565)));
            _S560 = (1.0f + a_4 / s_1) * (_S564 - _S566) / 4.0f - ((F32_sin((_S565))) / 8.0f - t_13 * _S566 / 4.0f - ((F32_sin((_S563))) / 8.0f - a_4 * _S564 / 4.0f)) / s_1;
        }
        float integral_1 = integral_0 + _S560;
        integral_0 = integral_1;
    }
    return integral_0;
}

static __device__ ToonProfile ToonProfile_x24init_0(bool glossy_1, float a_5, float s_2, float b_1, float norm_0, float view_0, float3  axis_0)
{
    ToonProfile _S567;
    (&_S567)->glossy = glossy_1;
    (&_S567)->a = a_5;
    (&_S567)->s = s_2;
    (&_S567)->b = b_1;
    (&_S567)->norm = norm_0;
    (&_S567)->view = view_0;
    (&_S567)->axis = axis_0;
    return _S567;
}

__device__ __forceinline__ ToonProfile toonProfile(float3  v_4, float3  n_i_4, BSDFMaterial material_10)
{
    float _S568 = material_10.toon.x;
    bool _S569 = _S568 < 0.0f;
    float _S570 = clamp_1(material_10.toon.y / _S568, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S571 = clamp_1(material_10.toon.z / _S568, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S572 = (F32_min((_S570 + _S571), (1.57079637050628662f)));
    float _S573 = dot_0(n_i_4, v_4);
    float _S574 = toonP((F32_acos(((F32_min((_S573), (1.0f)))))), _S570, _S571);
    float3  _S575;
    if(_S569)
    {
        float3  _S576 = make_float3 (2.0f * _S573) * n_i_4 - v_4;
        float3  _S577 = ((((_S576)) * make_float3(rnorm3df(((_S576)).x, ((_S576)).y, ((_S576)).z))));
        _S575 = _S577;
    }
    else
    {
        _S575 = n_i_4;
    }
    float _S578 = toonIntegral(_S572, _S570, _S571, _S569);
    return ToonProfile_x24init_0(_S569, _S570, _S571, _S572, 6.28318548202514648f * _S578, _S574, _S575);
}

__device__ __forceinline__ float toonPDF(float3  l_1, float3  n_i_5, ToonProfile profile_1, Weights w_2)
{
    float _S579 = dot_0(n_i_5, l_1);
    float _S580 = dot_0(l_1, profile_1.axis);
    float _S581 = _slang_select(profile_1.glossy, _S580,_S579);
    float _S582 = (F32_acos((clamp_1(_S581, -1.0f, 1.0f))));
    float _S583 = toonP(_S582, profile_1.a, profile_1.s);
    float _S584 = w_2.p_toon * _S583;
    float _S585 = _slang_select(profile_1.glossy, 1.0f,_S579);
    float _S586 = _S584 * _S585 / profile_1.norm;
    bool _S587;
    if(profile_1.glossy)
    {
        _S587 = true;
    }
    else
    {
        _S587 = _S579 > 0.0f;
    }
    float _S588 = _slang_select(_S587, _S586,0.0f);
    return _S588;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_2, float3  n_i_6, ToonProfile profile_2, Weights w_3)
{
    float _S589 = (F32_max((dot_0(n_i_6, l_2)), (0.0f)));
    float _S590 = _slang_select(profile_2.glossy, _S589,profile_2.view);
    return w_3.toon * make_float3 (_S590) / make_float3 (w_3.p_toon);
}

__device__ float trowbridgeReitz(float alpha_2, float n_dot_h_0)
{
    float _S591 = alpha_2 * alpha_2;
    float _S592 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S591 * n_dot_h_0 * n_dot_h_0;
    return _S591 / (F32_max((3.14159274101257324f * _S592 * _S592), (1.17549435082228751e-38f)));
}

__device__ float3  anisotropicLocal(float3  w_4, float3  t_14, float3  n_5)
{
    return make_float3 (dot_0(w_4, t_14), dot_0(w_4, cross_0(n_5, t_14)), dot_0(w_4, n_5));
}

__device__ float anisotropicG1(float3  w_5, float2  alphas_1)
{
    float _S593 = (F32_max((w_5.z), (0.0f)));
    return 2.0f * _S593 / (_S593 + length_0(make_float3 (alphas_1.x * w_5.x, alphas_1.y * w_5.y, _S593)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S594 = alphas_2.x;
    float _S595 = h_0.x / _S594;
    float _S596 = alphas_2.y;
    float _S597 = h_0.y / _S596;
    float _S598 = h_0.z;
    float _S599 = _S595 * _S595 + _S597 * _S597 + _S598 * _S598;
    return 1.0f / (F32_max((3.14159274101257324f * _S594 * _S596 * _S599 * _S599), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float3  v_5, float3  h_1, float3  n_i_7, float n_i_dot_v_1, float alpha_3, AnisotropicFrame frame_2, float v_dot_h_1)
{
    float _S600 = dot_0(n_i_7, h_1);
    float _S601 = smithG1(alpha_3, n_i_dot_v_1);
    float _S602 = _S601 * v_dot_h_1;
    float _S603 = trowbridgeReitz(alpha_3, _S600);
    float _S604 = _S602 * _S603 / n_i_dot_v_1;
    bool _S605 = alpha_3 > 0.0f;
    bool _S606;
    if(_S605)
    {
        _S606 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S606 = false;
    }
    if(_S606)
    {
        _S606 = _S600 > 0.0f;
    }
    else
    {
        _S606 = false;
    }
    if(_S606)
    {
        _S606 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S606 = false;
    }
    float _S607 = _slang_select(_S606, _S604,0.0f);
    bool _S608 = (frame_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S608)
    {
        float3  _S609 = anisotropicLocal(v_5, frame_2.tangent, n_i_7);
        float _S610 = anisotropicG1(_S609, frame_2.alphas);
        float3  _S611 = anisotropicLocal(h_1, frame_2.tangent, n_i_7);
        float _S612 = anisotropicD(_S611, frame_2.alphas);
        float _S613 = _S610 * _S612;
        float _S614 = _S613 * v_dot_h_1 / n_i_dot_v_1;
        bool _S615 = v_dot_h_1 > 0.0f;
        if(_S615)
        {
            _S606 = _S600 > 0.0f;
        }
        else
        {
            _S606 = false;
        }
        if(_S606)
        {
            _S606 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S606 = false;
        }
        float _S616 = _slang_select(_S606, _S614,0.0f);
        pdf_h_0 = _S616;
    }
    else
    {
        pdf_h_0 = _S607;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float l_dot_h_0, float pdf_h_1, Weights w_6, float eta_i_3, float eta_o_2)
{
    float _S617 = eta_i_3 * w_6.v_dot_h + eta_o_2 * l_dot_h_0;
    float _S618 = w_6.p_refract * pdf_h_1 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S617 * _S617);
    bool _S619 = eta_i_3 != eta_o_2;
    bool _S620;
    if(_S619)
    {
        _S620 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S620 = false;
    }
    float _S621 = _slang_select(_S620, _S618,0.0f);
    return _S621;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_3, float3  n_i_8, float alpha_4, AnisotropicFrame frame_3, BSDFMaterial material_11, Weights w_7)
{
    float _S622 = - dot_0(n_i_8, l_3);
    float _S623 = smithG1(alpha_4, (F32_max((_S622), (0.0f))));
    bool _S624 = (frame_3.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S624)
    {
        float3  _S625 = negate_0(n_i_8);
        float3  _S626 = anisotropicLocal(l_3, frame_3.tangent, _S625);
        float _S627 = anisotropicG1(_S626, frame_3.alphas);
        G1_l_0 = _S627;
    }
    else
    {
        G1_l_0 = _S623;
    }
    return w_7.refract_weight * make_float3 (G1_l_0) * material_11.albedo / make_float3 (w_7.p_refract);
}

__device__ __forceinline__ float reflectPDF(float pdf_h_2, Weights w_8)
{
    float _S628 = w_8.p_reflect * pdf_h_2 / (4.0f * w_8.v_dot_h);
    bool _S629 = pdf_h_2 > 0.0f;
    float _S630 = _slang_select(_S629, _S628,0.0f);
    return _S630;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_4, float3  n_i_9, float alpha_5, AnisotropicFrame frame_4, Weights w_9)
{
    float _S631 = dot_0(n_i_9, l_4);
    float _S632 = smithG1(alpha_5, (F32_max((_S631), (0.0f))));
    bool _S633 = (frame_4.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S633)
    {
        float3  _S634 = anisotropicLocal(l_4, frame_4.tangent, n_i_9);
        float _S635 = anisotropicG1(_S634, frame_4.alphas);
        G1_l_1 = _S635;
    }
    else
    {
        G1_l_1 = _S632;
    }
    return make_float3 (w_9.reflect_weight * G1_l_1) * w_9.F / make_float3 (w_9.p_reflect);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_1, float n_i_dot_v_2, Weights w_10)
{
    float _S636 = w_10.p_sheen_velvet * 0.5f * 0.31830987334251404f;
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

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_5, float3  v_6, float3  n_i_10, BSDFMaterial material_12, Weights w_11)
{
    float3  _S640 = l_5 + v_6;
    float3  _S641 = ((((_S640)) * make_float3(rnorm3df(((_S640)).x, ((_S640)).y, ((_S640)).z))));
    float _S642 = dot_0(n_i_10, _S641);
    float _S643 = (F32_max((dot_0(n_i_10, l_5)), (0.0f)));
    float _S644 = (F32_max((dot_0(n_i_10, v_6)), (0.0f)));
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
        float _S652 = (F32_exp((- _S642 * _S642 / (_S651 * _S650)))) / (3.14159274101257324f * _S650 * _S651 * _S651) * (F32_min((1.0f), (2.0f * _S642 * (F32_min((_S643), (_S644))) / (F32_max(((F32_abs((dot_0(_S641, v_6))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S643 * _S644), (0.0000152587890625f)));
        f_1 = _S652;
    }
    else
    {
        f_1 = _S647;
    }
    return w_11.sheen * make_float3 (f_1 * _S643 * 2.0f * 3.14159274101257324f / w_11.p_sheen_velvet);
}

__device__ __forceinline__ float coatPDF(float3  v_7, float3  coat_h_2, CoatFrame coat_frame_3, Weights w_12)
{
    float _S653 = dot_0(coat_frame_3.normal, v_7);
    float _S654 = smithG1(coat_frame_3.alpha, _S653);
    float _S655 = trowbridgeReitz(coat_frame_3.alpha, dot_0(coat_frame_3.normal, coat_h_2));
    float _S656 = _S654 * _S655 / (4.0f * _S653);
    bool _S657 = (coat_frame_3.alpha) > 0.0f;
    float _S658 = _slang_select(_S657, _S656,0.0f);
    return w_12.p_coat * _S658;
}

__device__ __forceinline__ float3  coatBSDF(Weights w_13)
{
    return w_13.coat / make_float3 (w_13.p_coat);
}

__device__ __forceinline__ void BSDF(float3  in_dir_2, float3  out_dir_0, float3  n_6, BSDFMaterial material_13, float eta_i_4, float eta_o_3, bool refracted_2, uint random_state_2, FixedArray<float3 , 6>  * throughputs_0, FixedArray<float, 6>  * pdfs_0)
{
    float3  _S659 = negate_0(in_dir_2);
    float _S660 = dot_0(n_6, _S659);
    float _S661 = sign_0(_S660);
    float3  _S662 = n_6 * make_float3 (_S661);
    float _S663 = dot_0(_S662, out_dir_0);
    float _S664 = material_13.roughness;
    float _S665 = _S664 * _S664;
    AnisotropicFrame _S666 = anisotropicFrame(material_13, _S662);
    SheenProfile _S667 = sheenProfile(_S659, _S662, material_13);
    CoatFrame _S668 = coatFrame(material_13, _S662);
    float3  _S669 = coatSeries(_S668, material_13);
    float _S670 = rgb_to_greyscale(material_13.translucent);
    bool _S671 = _S670 > 0.0f;
    bool _S672 = (dot_0(n_6, out_dir_0) * _S660) < 0.0f;
    bool _S673 = (F32_abs((material_13.toon.x))) > 0.0f;
    bool _S674 = (_S668.ior) > 0.0f;
    float3  _S675 = make_float3 (0.0f);
    (*throughputs_0)[int(0)] = _S675;
    (*throughputs_0)[int(1)] = _S675;
    (*throughputs_0)[int(2)] = _S675;
    (*throughputs_0)[int(3)] = _S675;
    (*throughputs_0)[int(4)] = _S675;
    (*throughputs_0)[int(5)] = _S675;
    (*pdfs_0)[int(0)] = 0.0f;
    (*pdfs_0)[int(1)] = 0.0f;
    (*pdfs_0)[int(2)] = 0.0f;
    (*pdfs_0)[int(3)] = 0.0f;
    (*pdfs_0)[int(4)] = 0.0f;
    (*pdfs_0)[int(5)] = 0.0f;
    bool _S676;
    if(_S671)
    {
        _S676 = _S672;
    }
    else
    {
        _S676 = false;
    }
    bool _S677 = _S676 == refracted_2;
    bool _S678 = !refracted_2;
    if(_S678)
    {
        _S676 = _S673;
    }
    else
    {
        _S676 = false;
    }
    bool _S679;
    if(_S678)
    {
        _S679 = _S674;
    }
    else
    {
        _S679 = false;
    }
    float3  _S680 = negate_0(make_float3 (eta_i_4) * _S659 + make_float3 (eta_o_3) * out_dir_0);
    float3  _S681 = ((((_S680)) * make_float3(rnorm3df(((_S680)).x, ((_S680)).y, ((_S680)).z))));
    float3  _S682 = _S659 + out_dir_0;
    float3  _S683 = ((((_S682)) * make_float3(rnorm3df(((_S682)).x, ((_S682)).y, ((_S682)).z))));
    float _S684 = sign_0(dot_0(_S681, _S662));
    float3  _S685 = _S681 * make_float3 (_S684);
    float3  _S686 = _slang_select(refracted_2, _S685,_S683);
    float3  _S687 = _slang_select(_S674, _S686,_S675);
    Weights _S688 = lobeWeights(in_dir_2, _S659, _S662, _S686, _S687, _S666, _S667, _S668, _S669, material_13, eta_i_4, eta_o_3);
    if(_S677)
    {
        float _S689 = diffusePDF(_S663, (F32_abs((_S660))), material_13, _S688);
        (*pdfs_0)[int(0)] = _S689;
        float3  _S690 = diffuseBSDF(out_dir_0, _S662, material_13, _S688);
        (*throughputs_0)[int(0)] = _S690;
    }
    if(_S676)
    {
        ToonProfile _S691 = toonProfile(_S659, _S662, material_13);
        float _S692 = toonPDF(out_dir_0, _S662, _S691, _S688);
        (*pdfs_0)[int(4)] = _S692;
        float3  _S693 = toonBSDF(out_dir_0, _S662, _S691, _S688);
        (*throughputs_0)[int(4)] = _S693;
    }
    if(refracted_2)
    {
        float _S694 = dot_0(out_dir_0, _S686);
        float _S695 = vndfPDF(_S659, _S686, _S662, (F32_abs((_S660))), _S665, _S666, _S688.v_dot_h);
        float _S696 = refractPDF(_S694, _S695, _S688, eta_i_4, eta_o_3);
        (*pdfs_0)[int(1)] = _S696;
        float3  _S697 = refractBSDF(out_dir_0, _S662, _S665, _S666, material_13, _S688);
        (*throughputs_0)[int(1)] = _S697;
    }
    if(_S678)
    {
        float _S698 = (F32_abs((_S660)));
        float _S699 = vndfPDF(_S659, _S686, _S662, _S698, _S665, _S666, _S688.v_dot_h);
        float _S700 = reflectPDF(_S699, _S688);
        (*pdfs_0)[int(2)] = _S700;
        float3  _S701 = reflectBSDF(out_dir_0, _S662, _S665, _S666, _S688);
        (*throughputs_0)[int(2)] = _S701;
        float _S702 = sheenVelvetPDF(_S663, _S698, _S688);
        (*pdfs_0)[int(3)] = _S702;
        float3  _S703 = sheenVelvetBSDF(out_dir_0, _S659, _S662, material_13, _S688);
        (*throughputs_0)[int(3)] = _S703;
    }
    if(_S679)
    {
        float _S704 = coatPDF(_S659, _S687, _S668, _S688);
        (*pdfs_0)[int(5)] = _S704;
        float3  _S705 = coatBSDF(_S688);
        (*throughputs_0)[int(5)] = _S705;
    }
    return;
}

static __device__ __forceinline__ float3  skyLobes_0(float3  in_dir_3, float3  dir_3, FKSurface * surface_1, BSDFMaterial * material_14, float2  eta_1, bool is_inside_2, float pdf_0, uint random_state_3, FixedArray<float3 , 6>  * terms_0, FixedArray<float, 6>  * pdfs_1)
{
    bool _S706 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    BSDF(in_dir_3, dir_3, surface_1->smooth_n, *material_14, eta_1.x, eta_1.y, _S706, random_state_3, terms_0, pdfs_1);
    float3  _S707 = make_float3 (0.0f);
    uint i_8 = 0U;
    float3  f_2 = _S707;
    for(;;)
    {
        if(i_8 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S708 = ((*pdfs_1)[i_8]) > 0.0f;
        if(_S708)
        {
            float3  _S709 = (*terms_0)[i_8] * make_float3 ((*pdfs_1)[i_8]) / make_float3 ((*pdfs_1)[i_8] + pdf_0);
            (*terms_0)[i_8] = _S709;
            float3  f_3 = f_2 + (*terms_0)[i_8];
            f_2 = f_3;
        }
        uint i_9 = i_8 + 1U;
        i_8 = i_9;
    }
    return f_2;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_4, float3  radiance_0, float3  color_0, uint random_state_4)
{
    SkySample _S710;
    (&_S710)->dir = dir_4;
    (&_S710)->radiance = radiance_0;
    (&_S710)->color = color_0;
    (&_S710)->random_state = random_state_4;
    return _S710;
}

static __device__ __noinline__ float3  skyColor_0(float3  dir_5, FixedArray<float3 , 6>  * terms_1, FixedArray<float, 6>  * pdfs_2, uint depth_0)
{
    float3  _S711 = make_float3 (0.0f);
    bool shaded_0 = false;
    float3  world_0 = _S711;
    uint i_10 = 0U;
    float3  color_1 = _S711;
    for(;;)
    {
        if(i_10 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S712 = ((*pdfs_2)[i_10]) > 0.0f;
        if(_S712)
        {
            bool _S713 = (fcptWorldReadsPath());
            bool _S714;
            if(_S713)
            {
                _S714 = true;
            }
            else
            {
                _S714 = !shaded_0;
            }
            bool shaded_1;
            float3  world_1;
            if(_S714)
            {
                uint _S715;
                if(i_10 == 3U)
                {
                    _S715 = 4U;
                }
                else
                {
                    if(i_10 == 4U)
                    {
                        _S715 = 6U;
                    }
                    else
                    {
                        if(i_10 == 5U)
                        {
                            _S715 = 5U;
                        }
                        else
                        {
                            _S715 = i_10;
                        }
                    }
                }
                float3  _S716 = (fcptEnvMapSample((dir_5), (depth_0), (_S715)));
                world_1 = _S716;
                shaded_1 = true;
            }
            else
            {
                world_1 = world_0;
                shaded_1 = shaded_0;
            }
            float3  color_2 = color_1 + (*terms_1)[i_10] * world_1;
            shaded_0 = shaded_1;
            world_0 = world_1;
            color_1 = color_2;
        }
        uint i_11 = i_10 + 1U;
        i_10 = i_11;
    }
    return color_1;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float wavelength_3, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S717 = (fcptEnvironmentCdfSize());
    uint2  _S718 = make_uint2 (1U, 0U);
    uint2  _S719 = _S717 - _S718;
    Random _S720 = draw(init_random_state_0, 6U);
    Random _S721 = draw(init_random_state_0, 2147483654U);
    Random _S722 = draw(init_random_state_0, 7U);
    Random _S723 = draw(init_random_state_0, 2147483655U);
    uint _S724 = _S719.x;
    uint _S725 = searchCDF_0(make_uint2 (_S724, 0U), make_uint2 (0U, 1U), _S719.y, _S720.value);
    uint _S726 = searchCDF_0(make_uint2 (0U, _S725), _S718, _S724, _S721.value);
    float2  _S727 = make_float2 ((float)_S719.x, (float)_S719.y);
    float2  _S728 = (make_float2 (float(_S726), float(_S725)) + make_float2 (_S722.value, _S723.value)) / _S727 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S729 = _S728.y;
    float _S730 = (F32_sin((_S729)));
    float _S731 = _S728.x;
    float3  _S732 = make_float3 (- _S730 * (F32_cos((_S731))), _S730 * (F32_sin((_S731))), (F32_cos((_S729))));
    float _S733 = environmentPdf_0(_S732);
    BSDFMaterial _S734 = pathMaterial(surface_2->material, wavelength_3);
    BSDFMaterial _S735 = _S734;
    FixedArray<float3 , 6>  terms_2;
    FixedArray<float, 6>  pdfs_3;
    float3  _S736 = skyLobes_0(ray_0->unit_direction, _S732, surface_2, &_S735, eta_2, is_inside_3, _S733, lobe_state_0, &terms_2, &pdfs_3);
    bool _S737 = !(_S733 > 0.0f);
    bool _S738;
    if(_S737)
    {
        _S738 = true;
    }
    else
    {
        _S738 = all_1(_S736 == make_float3 (0.0f));
    }
    if(_S738)
    {
        float3  _S739 = make_float3 (0.0f);
        return SkySample_x24init_0(_S732, _S739, _S739, _S723.state);
    }
    bool _S740 = (fcptWorldReadsPath());
    float3  seen_0;
    if(_S740)
    {
        uint _S741 = context_2->depth + 1U;
        FixedArray<float3 , 6>  _S742 = terms_2;
        FixedArray<float, 6>  _S743 = pdfs_3;
        float3  _S744 = skyColor_0(_S732, &_S742, &_S743, _S741);
        seen_0 = _S744;
    }
    else
    {
        seen_0 = _S736;
    }
    float3  _S745 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S732, context_2, _S723.state);
    return SkySample_x24init_0(_S732, _S745, seen_0 * _S745, _S723.state);
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
    SampleBSDF _S746 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_4), (light_1->dir)));
    float3  _S747 = _S746.throughput * make_float3 (_S746.pdf);
    float _S748 = light_1->density;
    float _S749 = 1.0f + _S746.pdf * _S746.pdf / (light_1->density * light_1->density);
    bool _S750;
    if(competing_0)
    {
        _S750 = _S748 > 0.0f;
    }
    else
    {
        _S750 = false;
    }
    float _S751 = _slang_select(_S750, _S749,1.0f);
    return _S747 / make_float3 (_S751) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_5)
{
    TreeSample _S752;
    (&_S752)->dir = dir_6;
    (&_S752)->radiance = radiance_1;
    (&_S752)->density = density_0;
    (&_S752)->random_state = random_state_5;
    return _S752;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_4, float * pick_0, float * probability_3)
{
    float _S753 = importance(first_1, p_12, normal_4);
    float _S754 = importance(second_1, p_12, normal_4);
    float2  _S755 = make_float2 (_S753, _S754);
    bool _S756 = _S753 == 0.0f;
    bool _S757;
    if(_S756)
    {
        _S757 = _S754 == 0.0f;
    }
    else
    {
        _S757 = false;
    }
    if(_S757)
    {
        return 2U;
    }
    float _S758 = _S753 + _S754;
    bool _S759 = _S754 > 0.0f;
    if(_S759)
    {
        _S757 = (*pick_0 * _S758) >= _S753;
    }
    else
    {
        _S757 = false;
    }
    uint _S760 = uint(_S757);
    float _S761 = (F32_min(((*pick_0 * _S758 - float(_S760) * _S753) / _slang_vector_get_element(_S755, _S760)), (0.99999994039535522f)));
    *pick_0 = _S761;
    float _S762 = *probability_3 * (_slang_vector_get_element(_S755, _S760) / _S758);
    *probability_3 = _S762;
    return _S760;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S763 = center_1 - p_13;
    float _S764 = radius_1 * radius_1 / dot_0(_S763, _S763);
    float _S765 = u1_0 * _S764 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S764), (0.0f)))))));
    float _S766 = 2.0f * u1_0;
    bool _S767 = _S764 >= 1.0f;
    float _S768 = _slang_select(_S767, _S766,_S765);
    float _S769 = (F32_sqrt(((F32_max((_S768 * (2.0f - _S768)), (0.0f))))));
    float _S770 = 6.28318548202514648f * u2_0;
    float3  _S771 = make_float3 (_S769 * (F32_cos((_S770))), 1.0f - _S768, _S769 * (F32_sin((_S770))));
    float3  _S772 = ((((_S763)) * make_float3(rnorm3df(((_S763)).x, ((_S763)).y, ((_S763)).z))));
    float3  _S773 = tangentToWorld(_S771, _S772);
    return _S773;
}

__device__ float3  pointLightRadiance(float3  color_3, float intensity_0, float radius_2)
{
    return color_3 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S774 = center_2 - ray_1->origin;
    float _S775 = dot_0(_S774, ray_1->unit_direction);
    float _S776 = dot_0(_S774, _S774) - _S775 * _S775;
    float _S777 = radius_3 * radius_3;
    bool _S778 = _S776 > _S777;
    if(_S778)
    {
        return 4.294967296e+09f;
    }
    float _S779 = (F32_sqrt((_S777 - _S776)));
    float _S780 = _S775 - _S779;
    float _S781 = _S775 + _S779;
    bool _S782 = _S780 > 0.0000152587890625f;
    bool _S783;
    if(_S782)
    {
        _S783 = _S780 < max_len_0;
    }
    else
    {
        _S783 = false;
    }
    if(_S783)
    {
        return _S780;
    }
    bool _S784 = _S781 > 0.0000152587890625f;
    if(_S784)
    {
        _S783 = _S781 < max_len_0;
    }
    else
    {
        _S783 = false;
    }
    if(_S783)
    {
        return _S781;
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
        *_slang_vector_get_element_ptr(&result_6, j_1) = sum_0;
        j_1 = j_1 + int(1);
    }
    return result_6;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S785 = draw(init_random_state_1, 4U);
    Random _S786 = draw(init_random_state_1, 5U);
    Random _S787 = draw(init_random_state_1, 2147483653U);
    float3  _S788 = make_float3 (0.0f);
    TreeSample _S789 = TreeSample_x24init_0(_S788, _S788, 0.0f, _S787.state);
    TreeSample sample_0 = _S789;
    float3  _S790 = _slang_select(sided_0, _S788,smooth_n_2);
    float3  _S791 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S785.value;
    float probability_4 = 1.0f;
    uint n_7 = 0U;
    for(;;)
    {
        uint4  _S792 = (fcptLightNode((n_7)));
        if((_S792.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S793 = (fcptLightSecond((n_7)));
        uint _S794 = n_7 + 1U;
        LightNode _S795 = (fcptLightBounds((_S794)));
        LightNode _S796 = (fcptLightBounds((_S793)));
        uint _S797 = pickChild(_S795, _S796, origin_4, _S790, &pick_1, &probability_4);
        bool _S798 = _S797 > 1U;
        if(_S798)
        {
            return sample_0;
        }
        bool _S799 = _S797 == 1U;
        uint _S800 = _slang_select(_S799, _S793,_S794);
        n_7 = _S800;
    }
    bool _S801 = n_7 == 0U;
    bool _S802;
    if(_S801)
    {
        LightNode _S803 = (fcptLightBounds((0U)));
        float _S804 = importance(_S803, origin_4, _S790);
        _S802 = !(_S804 > 0.0f);
    }
    else
    {
        _S802 = false;
    }
    if(_S802)
    {
        return sample_0;
    }
    uint4  _S805 = (fcptLightNode((n_7)));
    FKHit _S806 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S807 = (_S805.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S807)
    {
        FKLight _S808 = (fcptLight((_S805.y)));
        if(sided_0)
        {
            float _S809 = sign_0(dot_0(geometry_n_1, _S808.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S809);
            float3  _S810 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S810;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S791;
            lift_n_0 = smooth_n_2;
        }
        bool _S811 = (_S808.variance) == 0.0f;
        if(_S811)
        {
            float3  _S812 = _S808.position - emitter_point_0;
            float3  _S813 = ((((_S812)) * make_float3(rnorm3df(((_S812)).x, ((_S812)).y, ((_S812)).z))));
            (&sample_0)->dir = _S813;
            float3  _S814 = _S808.color * make_float3 (_S808.intensity) / make_float3 (dot_0(_S812, _S812) * probability_4);
            (&sample_0)->radiance = _S814;
            shadow_1 = _S812;
        }
        else
        {
            float3  _S815 = sampleSphere(_S808.position, _S808.variance, emitter_point_0, _S786.value, _S787.value);
            (&sample_0)->dir = _S815;
            float _S816 = sphereDensity(_S808.position, _S808.variance, emitter_point_0);
            float _S817 = probability_4 * _S816;
            (&sample_0)->density = _S817;
            float3  _S818 = pointLightRadiance(_S808.color, _S808.intensity, _S808.variance);
            float3  _S819 = _S818 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S819;
            FKRay _S820 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S821 = raySphere_0(_S808.position, _S808.variance, &_S820, 4.294967296e+09f);
            float3  _S822 = (&sample_0)->dir * make_float3 (_S821);
            shadow_1 = _S822;
        }
        emitter_0 = _S806;
        emitter_point_0 = _S788;
    }
    else
    {
        uint _S823 = _S805.y;
        uint _S824 = (fcptTriangleOffset((_S823)));
        uint _S825 = _S824 + _S805.z;
        Matrix<float, 3, 3>  _S826 = (fcptWorldTriangle((_S823), (_S825)));
        float _S827 = (F32_sqrt((_S786.value)));
        float2  _S828 = make_float2 (_S827 * (1.0f - _S787.value), _S827 * _S787.value);
        float3  _S829 = mul_0(make_float3 (1.0f - _S827, _S828.x, _S828.y), _S826);
        if(sided_0)
        {
            float _S830 = sign_0(dot_0(geometry_n_1, _S829 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S830);
            float3  _S831 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S831;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S832 = !((dot_0(smooth_n_2, _S829 - origin_4)) > 0.0f);
            if(_S832)
            {
                return sample_0;
            }
            emitter_point_0 = _S791;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S828, _S823, _S825, 0U, 0.0f);
        float3  _S833 = _S829 - emitter_point_0;
        float3  _S834 = ((((_S833)) * make_float3(rnorm3df(((_S833)).x, ((_S833)).y, ((_S833)).z))));
        (&sample_0)->dir = _S834;
        float _S835 = solidAngle(probability_4, cross_0(_S826.rows[int(1)] - _S826.rows[int(0)], _S826.rows[int(2)] - _S826.rows[int(0)]), _S833);
        (&sample_0)->density = _S835;
        bool _S836 = (fcptShadowFirst());
        bool _S837 = !_S836;
        if(_S837)
        {
            FKSurface _S838 = (fcptLightSurfaceAt((emitter_1), (_S829), (_S787.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S829 - origin_4))));
            (&sample_0)->random_state = _S838.random_state;
            float3  _S839 = _slang_select(_S838.skip, _S788,_S838.material.emissive);
            float3  _S840 = _S839 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S840;
        }
        shadow_1 = _S833;
        emitter_0 = emitter_1;
        emitter_point_0 = _S829;
    }
    FKHit _S841 = emitter_0;
    float3  _S842 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S787.state, &_S841);
    bool _S843 = (fcptShadowFirst());
    if(_S843)
    {
        _S802 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S802 = false;
    }
    if(_S802)
    {
        _S802 = !all_1(_S842 == _S788);
    }
    else
    {
        _S802 = false;
    }
    if(_S802)
    {
        FKSurface _S844 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S787.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S844.random_state;
        float3  _S845 = _slang_select(_S844.skip, _S788,_S844.material.emissive);
        float3  _S846 = _S845 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S846;
    }
    float3  _S847 = (&sample_0)->radiance * _S842;
    bool _S848 = all_1(_S842 == _S788);
    float3  _S849 = _slang_select(_S848, _S788,_S847);
    (&sample_0)->radiance = _S849;
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
    float _S850 = 1.0f / (1.0f + b_2 / a_6 * (b_2 / a_6));
    bool _S851 = b_2 > 0.0f;
    float _S852 = _slang_select(_S851, _S850,1.0f);
    return _S852;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S853 = vertex_0->none;
    if(_S853)
    {
        return 1.0f;
    }
    uint _S854 = (fcptLightSlot((*hit_1)));
    float _S855 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S854, light_point_1);
    float _S856 = powerHeuristic(vertex_0->pdf, _S855);
    return _S856;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_1, uint lobe_0)
{
    uint2  _S857 = (fcptEnvironmentMapSize());
    bool _S858 = (_S857.x) > 1U;
    bool _S859;
    if(_S858)
    {
        uint2  _S860 = (fcptEnvironmentMapSize());
        _S859 = (_S860.y) > 1U;
    }
    else
    {
        _S859 = false;
    }
    if(_S859)
    {
        float3  _S861 = (fcptEnvMapSample((dir_7), (depth_1), (lobe_0)));
        return _S861;
    }
    float3  _S862 = (fcptAmbient());
    return _S862;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S863 = (fcptEnvironmentCdfSize());
    bool _S864 = (_S863.x) > 1U;
    bool _S865;
    if(_S864)
    {
        uint2  _S866 = (fcptEnvironmentCdfSize());
        _S865 = (_S866.y) > 1U;
    }
    else
    {
        _S865 = false;
    }
    bool _S867 = !_S865;
    if(_S867)
    {
        return false;
    }
    uint2  _S868 = (fcptEnvironmentMapSize());
    bool _S869 = (_S868.x) > 1U;
    if(_S869)
    {
        uint2  _S870 = (fcptEnvironmentMapSize());
        _S865 = (_S870.y) > 1U;
    }
    else
    {
        _S865 = false;
    }
    return _S865;
}

static __device__ float escapeWeight_0(float pdf_1, float3  dir_8)
{
    bool _S871 = pdf_1 <= 0.0f;
    bool _S872;
    if(_S871)
    {
        _S872 = true;
    }
    else
    {
        bool _S873 = environmentMapped_0();
        _S872 = !_S873;
    }
    if(_S872)
    {
        return 1.0f;
    }
    float _S874 = environmentPdf_0(dir_8);
    return pdf_1 / (pdf_1 + _S874);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S875 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S876 = make_int2 ((int)_S875.x, (int)_S875.y);
    uint _S877 = previousSeed_0(_S876);
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
        int x_15 = int(-8);
        for(;;)
        {
            if(x_15 <= int(8))
            {
            }
            else
            {
                break;
            }
            uint _S878 = previousSeed_0(_S876 + make_int2 (x_15, y_5));
            bool _S879 = _S878 == _S877;
            uint _S880 = _slang_select(_S879, 1U,0U);
            uint count_3 = count_2 + _S880;
            int x_16 = x_15 + int(1);
            x_15 = x_16;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S881 = float(count_2 - 1U) / 288.0f;
    bool _S882 = _S877 != 0U;
    float _S883 = _slang_select(_S882, _S881,0.0f);
    fcptStoreDuplication((_S876), (make_uint4 ((F32_asuint((_S883))), 0U, 0U, 0U)));
    return;
}

static __device__ float3  abs_0(float3  x_17)
{
    float3  result_7;
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
        *_slang_vector_get_element_ptr(&result_7, i_13) = (F32_abs((_slang_vector_get_element(x_17, i_13))));
        i_13 = i_13 + int(1);
    }
    return result_7;
}

__device__ float resamplingTarget(float3  f_4)
{
    float _S884 = rgb_to_greyscale(abs_0(f_4));
    return _S884;
}

static __device__ float4  asfloat_0(uint4  x_18)
{
    float4  result_8;
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
        *_slang_vector_get_element_ptr(&result_8, i_14) = (U32_asfloat((_slang_vector_get_element(x_18, i_14))));
        i_14 = i_14 + int(1);
    }
    return result_8;
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
    float _S885 = resamplingTarget(weight_0);
    bool _S886 = _S885 > 0.0f;
    bool _S887;
    if(_S886)
    {
        _S887 = _S885 < 3.00000000549775576e+38f;
    }
    else
    {
        _S887 = false;
    }
    bool _S888 = !_S887;
    if(_S888)
    {
        return;
    }
    bool _S889 = sel_2->sums;
    if(_S889)
    {
        float3  _S890 = sel_2->color + weight_0;
        sel_2->color = _S890;
        return;
    }
    float _S891 = sel_2->w_sum + _S885;
    sel_2->w_sum = _S891;
    float3  _S892 = sel_2->color + weight_0;
    sel_2->color = _S892;
    Random _S893 = pcg(sel_2->random_state);
    sel_2->random_state = _S893.state;
    bool _S894 = (_S893.value * sel_2->w_sum) <= _S885;
    if(_S894)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S895 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S895;
    float _S896 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S896;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S897 = resamplingTarget((&r_4)->f);
    float _S898 = sel_4.w_sum / _S897;
    bool _S899 = _S897 > 0.0f;
    float _S900 = _slang_select(_S899, _S898,0.0f);
    (&r_4)->w = _S900;
    (&r_4)->c = c_1;
    return r_4;
}

static __device__ uint2  asuint_0(float2  x_19)
{
    uint2  result_9;
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
        *_slang_vector_get_element_ptr(&result_9, i_15) = (F32_asuint((_slang_vector_get_element(x_19, i_15))));
        i_15 = i_15 + int(1);
    }
    return result_9;
}

static __device__ void restir_spatial_0(uint3  global_invocation_id_2)
{
    uint2  _S901 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S902 = make_int2 ((int)_S901.x, (int)_S901.y);
    float3  _S903 = make_float3 (0.0f);
    FKHit _S904 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S905 = Domain_x24init_0(_S903, _S903, &_S904, 0.0f, 0.0f);
    Domain dom_4 = _S905;
    bool _S906 = (fcptCurrentDomain((_S902), (&dom_4)));
    bool _S907 = !_S906;
    if(_S907)
    {
        Reservoir _S908 = (Reservoir{});
        fcptStoreReservoirPrevious((_S902), (_S908), ((&dom_4)->hit));
        return;
    }
    Reservoir _S909 = (fcptLoadReservoirTemporal((_S902)));
    uint t_15 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S909.c;
    for(;;)
    {
        uint _S910 = (fcptRestirNeighbours());
        if(t_15 < _S910)
        {
        }
        else
        {
            break;
        }
        int2  _S911 = partner_0(_S902, t_15);
        Domain neighbor_0 = _S905;
        bool _S912 = (fcptCurrentDomain((_S911), (&neighbor_0)));
        if(_S912)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S913 = (fcptReservoirTemporal((_S911), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S913.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    float _S914 = _S909.c / (F32_max((count_4), (1.0f)));
    float _S915 = resamplingTarget(_S909.f);
    bool _S916 = count_4 == 0.0f;
    float _S917 = _slang_select(_S916, 1.0f,0.0f);
    Selection _S918 = (Selection{});
    Selection sel_5 = _S918;
    uint _S919 = (fcptFrame());
    uint _S920 = hash(_S919);
    uint _S921 = global_invocation_id_2.x;
    uint2  _S922 = (fcptRenderSize());
    uint _S923 = stream(_S920, _S921 + _S922.x * global_invocation_id_2.y);
    uint _S924 = stream(_S923, 195U);
    (&sel_5)->random_state = _S924;
    t_15 = 0U;
    float canonical_mis_0 = _S917;
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
        int2  _S926 = partner_0(_S902, t_15);
        Domain neighbor_dom_0 = _S905;
        bool _S927 = (fcptCurrentDomain((_S926), (&neighbor_dom_0)));
        if(_S927)
        {
            Reservoir _S928 = (fcptLoadReservoirTemporal((_S926)));
            uint4  _S929 = (fcptShiftData((_S926), (t_15)));
            float4  _S930 = asfloat_0(_S929);
            uint4  _S931 = (fcptShiftData((_S902), (t_15)));
            float4  _S932 = asfloat_0(_S931);
            float _S933 = pairShare(_S928.c, _S914, c_sum_1);
            bool _S934 = _S915 > 0.0f;
            float canonical_mis_1;
            if(_S934)
            {
                float _S935 = resamplingTarget(float3 {_S932.x, _S932.y, _S932.z});
                float _S936 = canonicalWeight(_S933, _S914, _S915, _S928.c, _S935);
                float canonical_mis_2 = canonical_mis_0 + _S936;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S937 = float3 {_S930.x, _S930.y, _S930.z};
            Shift _S938 = Shift_x24init_0(_S937, _S930.w);
            float _S939 = resamplingTarget(_S928.f);
            float _S940 = resamplingTarget(_S937);
            float _S941 = neighborWeight(_S933, _S928.c, _S939, _S914, _S940);
            offerShifted(&sel_5, _S928, _S938, _S941);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_17 = t_15 + 1U;
        t_15 = t_17;
    }
    offerShifted(&sel_5, _S909, Shift_x24init_0(_S909.f, 1.0f), canonical_mis_0);
    Reservoir _S942 = finalize(sel_5, c_sum_1);
    fcptStoreReservoirPrevious((_S902), (_S942), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S902), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S902), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
    return;
}

static __device__ uint3  asuint_1(float3  x_20)
{
    uint3  result_10;
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
        *_slang_vector_get_element_ptr(&result_10, i_16) = (F32_asuint((_slang_vector_get_element(x_20, i_16))));
        i_16 = i_16 + int(1);
    }
    return result_10;
}

static __device__ void restir_shift_0(uint3  workgroup_id_1, uint local_invocation_index_4)
{
    uint _S943 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S944 = _S943 != 4294967295U;
    if(_S944)
    {
        uint2  _S945 = make_uint2 (_S943, _S943 >> 14U) & make_uint2 (16383U);
        int2  _S946 = make_int2 ((int)_S945.x, (int)_S945.y);
        ShiftJob _S947 = (ShiftJob{});
        ShiftJob shift_job_0 = _S947;
        Shift _S948 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S949 = _S943 >> 28U;
        bool _S950 = spatialJob_0(_S946, _S949, &shift_job_0, true);
        Shift shifted_1;
        if(_S950)
        {
            Domain _S951 = (&shift_job_0)->dom;
            Reservoir _S952 = (&shift_job_0)->r;
            Shift _S953 = passShift_0(&_S951, &_S952);
            shifted_1 = _S953;
        }
        else
        {
            shifted_1 = _S948;
        }
        fcptStoreShiftData((_S946), (_S949), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S954 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S955 = make_int2 ((int)_S954.x, (int)_S954.y);
    FixedArray<uint, 3>  _S956;
    spatialBins_0(_S955, &_S956);
    FixedArray<uint, 3>  _S957 = _S956;
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
        bool _S958 = (_S957[t_18]) == 40U;
        if(_S958)
        {
            fcptStoreShiftData((_S955), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S959 = _S957;
    queueShifts_0(_S955, &_S959, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S960 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S961 = make_int2 ((int)_S960.x, (int)_S960.y);
    FixedArray<uint, 3>  _S962;
    spatialBins_0(_S961, &_S962);
    FixedArray<uint, 3>  _S963 = _S962;
    countShifts_0(&_S963, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S964 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S965 = _S964 != 4294967295U;
    if(_S965)
    {
        uint2  _S966 = make_uint2 (_S964, _S964 >> 14U) & make_uint2 (16383U);
        int2  _S967 = make_int2 ((int)_S966.x, (int)_S966.y);
        int2  _S968 = (fcptLoadTemporalNeighbor((_S967)));
        uint _S969 = _S964 >> 28U;
        Shift _S970 = temporalShiftAt_0(_S967, _S968, _S969);
        fcptStoreTemporalShift((_S967), (_S969), (make_uint4 (asuint_1(_S970.f).x, asuint_1(_S970.f).y, asuint_1(_S970.f).z, (F32_asuint((_S970.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S971 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S972 = make_int2 ((int)_S971.x, (int)_S971.y);
    FixedArray<uint, 3>  _S973;
    temporalBins_0(_S972, &_S973);
    FixedArray<uint, 3>  _S974 = _S973;
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
        bool _S975 = (_S974[t_20]) == 40U;
        if(_S975)
        {
            fcptStoreTemporalShift((_S972), (t_20), (make_uint4 (0U)));
        }
        uint t_21 = t_20 + 1U;
        t_20 = t_21;
    }
    FixedArray<uint, 3>  _S976 = _S974;
    queueShifts_0(_S972, &_S976, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S977 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S978 = make_int2 ((int)_S977.x, (int)_S977.y);
    bool _S979 = (fcptSceneUnchanged());
    bool _S980 = !_S979;
    bool _S981;
    if(_S980)
    {
        uint2  _S982 = (fcptRenderSize());
        int2  _S983 = make_int2 ((int)_S982.x, (int)_S982.y);
        _S981 = all_0(_S978 < _S983);
    }
    else
    {
        _S981 = false;
    }
    if(_S981)
    {
        Reservoir _S984 = (fcptLoadReservoirInitial((_S978)));
        int2  _S985 = sampleNeighbor_0(_S978, _S984.seed);
        fcptStoreTemporalNeighbor((_S978), (_S985));
    }
    FixedArray<uint, 3>  _S986;
    temporalBins_0(_S978, &_S986);
    FixedArray<uint, 3>  _S987 = _S986;
    countShifts_0(&_S987, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_7, float b_3, float t_22)
{
    return a_7 + (b_3 - a_7) * t_22;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S988 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S988;
}

__device__ float2  temporalWeights(float c_2, float p_c_1, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S989 = c_2 * p_c_1;
    float _S990 = c_t_0 * p_t_0;
    return make_float2 (_S989 / (_S989 + c_t_0 * g_previous_0), _S990 / (_S990 + c_2 * g_current_0));
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S991 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S992 = make_int2 ((int)_S991.x, (int)_S991.y);
    float3  _S993 = make_float3 (0.0f);
    FKHit _S994 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S995 = Domain_x24init_0(_S993, _S993, &_S994, 0.0f, 0.0f);
    Domain dom_5 = _S995;
    bool _S996 = (fcptCurrentDomain((_S992), (&dom_5)));
    bool _S997 = !_S996;
    if(_S997)
    {
        Reservoir _S998 = (Reservoir{});
        fcptStoreReservoirTemporal((_S992), (_S998), ((&dom_5)->hit));
        return;
    }
    Reservoir _S999 = (fcptLoadReservoirInitial((_S992)));
    bool _S1000 = (fcptTemporalQueued());
    bool _S1001 = (fcptSceneUnchanged());
    bool _S1002;
    if(_S1001)
    {
        _S1002 = true;
    }
    else
    {
        _S1002 = !_S1000;
    }
    int2  _S1003;
    if(_S1002)
    {
        int2  _S1004 = sampleNeighbor_0(_S992, _S999.seed);
        _S1003 = _S1004;
    }
    else
    {
        int2  _S1005 = (fcptLoadTemporalNeighbor((_S992)));
        _S1003 = _S1005;
    }
    bool _S1006 = (_S1003.x) >= int(0);
    Reservoir r_5;
    if(_S1006)
    {
        Reservoir _S1007 = (fcptLoadReservoirPrevious((_S1003)));
        uint4  _S1008 = (fcptDuplication((_S1003)));
        float _S1009 = (U32_asfloat((_S1008.x)));
        uint _S1010 = (fcptRestirDecorrelation());
        bool _S1011 = _S1010 == 1U;
        float _S1012 = _slang_select(_S1011, _S1009,0.0f);
        float _S1013 = confidenceCap(_S1012);
        float _S1014 = (F32_min((_S1007.c), (_S1013)));
        bool _S1015 = (fcptSceneUnchanged());
        float4  _S1016 = make_float4 (_S1007.f.x, _S1007.f.y, _S1007.f.z, 1.0f);
        bool _S1017 = !_S1015;
        if(_S1017)
        {
            _S1002 = _S1000;
        }
        else
        {
            _S1002 = false;
        }
        float4  to_current_0;
        if(_S1002)
        {
            uint4  _S1018 = (fcptTemporalShift((_S992), (0U)));
            float4  _S1019 = asfloat_0(_S1018);
            to_current_0 = _S1019;
        }
        else
        {
            if(_S1017)
            {
                Shift _S1020 = temporalShiftAt_0(_S992, _S1003, 0U);
                float4  _S1021 = make_float4 (_S1020.f.x, _S1020.f.y, _S1020.f.z, _S1020.jac);
                to_current_0 = _S1021;
            }
            else
            {
                to_current_0 = _S1016;
            }
        }
        Domain own_1 = _S995;
        if(_S1015)
        {
            _S1002 = true;
        }
        else
        {
            bool _S1022 = (fcptPreviousScenes());
            bool _S1023 = !_S1022;
            if(_S1023)
            {
                _S1002 = (_S999.w) > 0.0f;
            }
            else
            {
                _S1002 = false;
            }
            if(_S1002)
            {
                bool _S1024 = (fcptStoredDomainInitial((_S992), (_S999.seed), (&own_1)));
                _S1002 = _S1024;
            }
            else
            {
                _S1002 = false;
            }
            if(_S1002)
            {
                Domain _S1025 = (fcptPreviousDomain((_S1003), (_S999.seed)));
                Domain _S1026 = _S1025;
                Domain _S1027 = own_1;
                bool _S1028 = sameDomain_0(&_S1026, &_S1027);
                _S1002 = _S1028;
            }
            else
            {
                _S1002 = false;
            }
        }
        float4  _S1029 = make_float4 (_S999.f.x, _S999.f.y, _S999.f.z, 1.0f);
        bool _S1030 = !_S1002;
        if(_S1030)
        {
            _S1002 = _S1000;
        }
        else
        {
            _S1002 = false;
        }
        float4  to_previous_0;
        if(_S1002)
        {
            uint4  _S1031 = (fcptTemporalShift((_S992), (1U)));
            float4  _S1032 = asfloat_0(_S1031);
            to_previous_0 = _S1032;
        }
        else
        {
            if(_S1030)
            {
                Shift _S1033 = temporalShiftAt_0(_S992, _S1003, 1U);
                float4  _S1034 = make_float4 (_S1033.f.x, _S1033.f.y, _S1033.f.z, _S1033.jac);
                to_previous_0 = _S1034;
            }
            else
            {
                to_previous_0 = _S1029;
            }
        }
        float _S1035 = resamplingTarget(_S999.f);
        float _S1036 = resamplingTarget(_S1007.f);
        Selection _S1037 = (Selection{});
        Selection sel_6 = _S1037;
        uint _S1038 = (fcptFrame());
        uint _S1039 = hash(_S1038);
        uint _S1040 = global_invocation_id_7.x;
        uint2  _S1041 = (fcptRenderSize());
        uint _S1042 = stream(_S1039, _S1040 + _S1041.x * global_invocation_id_7.y);
        uint _S1043 = stream(_S1042, 194U);
        (&sel_6)->random_state = _S1043;
        float4  _S1044 = to_previous_0;
        float _S1045 = resamplingTarget(float3 {_S1044.x, _S1044.y, _S1044.z});
        float4  _S1046 = to_current_0;
        float3  _S1047 = float3 {_S1046.x, _S1046.y, _S1046.z};
        float _S1048 = resamplingTarget(_S1047);
        float2  _S1049 = temporalWeights(_S999.c, _S1035, _S1014, _S1036, _S1045, _S1048);
        offerShifted(&sel_6, _S999, Shift_x24init_0(_S999.f, 1.0f), _S1049.x);
        offerShifted(&sel_6, _S1007, Shift_x24init_0(_S1047, to_current_0.w), _S1049.y);
        Reservoir _S1050 = finalize(sel_6, _S999.c + _S1014);
        r_5 = _S1050;
    }
    else
    {
        r_5 = _S999;
    }
    fcptStoreReservoirTemporal((_S992), (r_5), ((&dom_5)->hit));
    return;
}

__device__ uint noiseOrigin(uint2  p_14, uint k_1)
{
    uint _S1051 = ((p_14.x) >> 11U) | (((p_14.y) >> 11U) << 4U);
    uint2  _S1052 = noiseOffset(8192U + (k_1 >> 10U) + (_S1051 << 20U));
    uint2  _S1053 = (p_14 + _S1052) & make_uint2 (2047U);
    return ((_S1053.x) | ((_S1053.y) << 11U)) | ((k_1 & 1023U) << 22U);
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1054 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1054 << offset_1))) | ((newbits_0 & _S1054) << offset_1);
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S1055 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S1056 = make_int2 ((int)_S1055.x, (int)_S1055.y);
    float3  _S1057 = make_float3 (0.0f);
    float2  _S1058 = make_float2 (0.0f);
    FKHit _S1059 = Hit_x24init_0(_S1058, 0U, 0U, 0U, 0.0f);
    Domain _S1060 = Domain_x24init_0(_S1057, _S1057, &_S1059, 0.0f, 0.0f);
    Domain dom_6 = _S1060;
    bool _S1061 = (fcptCurrentDomain((_S1056), (&dom_6)));
    bool _S1062 = !_S1061;
    if(_S1062)
    {
        Reservoir _S1063 = (Reservoir{});
        fcptStoreReservoirInitial((_S1056), (_S1063), ((&dom_6)->hit));
        return;
    }
    uint _S1064 = (fcptFrame());
    uint _S1065 = hash(_S1064);
    uint _S1066 = global_invocation_id_8.x;
    uint2  _S1067 = (fcptRenderSize());
    uint _S1068 = global_invocation_id_8.y;
    uint _S1069 = stream(_S1065, _S1066 + _S1067.x * _S1068);
    uint2  _S1070 = (fcptRenderSize());
    uint _S1071 = stream(_S1066 + _S1070.x * _S1068, 512U);
    Selection _S1072 = (Selection{});
    Selection initial_0 = _S1072;
    uint _S1073 = stream(_S1069, 193U);
    (&initial_0)->random_state = _S1073;
    bool _S1074 = (fcptRestirUsed());
    bool _S1075 = !_S1074;
    (&initial_0)->sums = _S1075;
    uint _S1076 = stream(_S1069, 0U);
    (&(&initial_0)->r)->seed = _S1076;
    FKHit _S1077 = Hit_x24init_0(_S1058, 4294967295U, 0U, 0U, 0.0f);
    uint _S1078 = (fcptSamples());
    float _S1079 = 1.0f / float(_S1078);
    FKHit hit_2 = _S1077;
    uint i_17 = 0U;
    float3  seen_1 = _S1057;
    for(;;)
    {
        uint _S1080 = (fcptSamples());
        if(i_17 < _S1080)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1081 = (Reservoir{});
        Reservoir r_6 = _S1081;
        uint _S1082 = (fcptFrame());
        uint _S1083 = (fcptSamples());
        uint _S1084 = _S1082 * _S1083 + i_17;
        uint _S1085 = noiseOrigin(_S1055, _S1084);
        (&r_6)->seed = _S1085;
        uint _S1086 = insertBits_0(0U, 1U, 24U, 1U);
        uint _S1087 = insertBits_0(_S1086, (_S1071 + _S1084 * 2654435769U) >> 25U, 25U, 7U);
        (&r_6)->path = _S1087;
        Domain path_0 = _S1060;
        bool _S1088 = (fcptStoredDomainInitial((_S1056), ((&r_6)->seed), (&path_0)));
        bool _S1089 = !_S1088;
        if(_S1089)
        {
            float3  _S1090 = (fcptMissed((_S1056), (path_0), (_S1079)));
            float3  seen_2 = seen_1 + _S1090;
            seen_1 = seen_2;
            uint i_18 = i_17 + 1U;
            i_17 = i_18;
            continue;
        }
        Domain _S1091 = path_0;
        Reservoir _S1092 = r_6;
        Shift _S1093 = passWalk_0(&_S1091, &_S1092, false, _S1079, &initial_0);
        bool _S1094 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1094)
        {
            FKHit _S1095 = (&path_0)->hit;
            hit_3 = _S1095;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_18 = i_17 + 1U;
        i_17 = i_18;
    }
    uint _S1096 = (fcptSamples());
    float3  seen_3 = seen_1 + (&initial_0)->glow / make_float3 (float(_S1096));
    if((&initial_0)->sums)
    {
        seen_1 = seen_3 + (&initial_0)->color;
    }
    else
    {
        seen_1 = seen_3;
    }
    fcptAddColor((_S1056), (make_float4 (seen_1.x, seen_1.y, seen_1.z, 1.0f)));
    Reservoir _S1097 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S1056), (_S1097), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_2, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1098;
    (&_S1098)->none = none_0;
    (&_S1098)->pdf = pdf_2;
    (&_S1098)->origin = origin_5;
    (&_S1098)->smooth_n = smooth_n_3;
    (&_S1098)->start = start_6;
    return _S1098;
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
    Vertex _S1099;
    (&_S1099)->rough = rough_0;
    (&_S1099)->lobe = lobe_1;
    (&_S1099)->pdf = pdf_3;
    (&_S1099)->cos = cos_0;
    (&_S1099)->inside = inside_0;
    return _S1099;
}

__device__ uint noiseAddress(uint origin_6, uint bounce_0)
{
    uint2  _S1100 = make_uint2 (origin_6 & 2047U, (origin_6 >> 11U) & 2047U);
    uint2  _S1101 = noiseOffset(64U + bounce_0 * 17U);
    uint2  _S1102 = (_S1100 + _S1101) & make_uint2 (2047U);
    return ((_S1102.x) | ((_S1102.y) << 11U)) | ((origin_6 >> 22U) << 22U);
}

static __device__ float freeFlight_0(float u_1, float sigma_0)
{
    return - (F32_log((1.0f - u_1))) / sigma_0;
}

__device__ float3  pathColor(float3  f_5, float3  weight_1, float wavelength_4)
{
    float3  _S1103;
    if(wavelength_4 > 0.0f)
    {
        float _S1104 = upsample(f_5, wavelength_4);
        _S1103 = weight_1 * make_float3 (_S1104);
    }
    else
    {
        _S1103 = f_5;
    }
    return _S1103;
}

static __device__ float3  exp_0(float3  x_21)
{
    float3  result_11;
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
        *_slang_vector_get_element_ptr(&result_11, i_19) = (F32_exp((_slang_vector_get_element(x_21, i_19))));
        i_19 = i_19 + int(1);
    }
    return result_11;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_1, float distance_2, bool scatters_0)
{
    float3  _S1105 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_2));
    float3  _S1106 = scatter_0 * _S1105 / make_float3 (sigma_1);
    float3  _S1107 = _slang_select(scatters_0, _S1106,_S1105);
    return _S1107;
}

static __device__ bool scatterSampled_0(bool replay_1, uint b_4, uint stop_0, bool varying_0)
{
    bool _S1108 = !replay_1;
    bool _S1109;
    if(_S1108)
    {
        _S1109 = true;
    }
    else
    {
        bool _S1110 = b_4 == stop_0;
        if(_S1110)
        {
            _S1109 = !varying_0;
        }
        else
        {
            _S1109 = false;
        }
    }
    return _S1109;
}

static __device__ uint arrivalLobe_0(uint b_5, uint prev_lobe_0)
{
    bool _S1111 = b_5 > 0U;
    uint _S1112 = _slang_select(_S1111, prev_lobe_0,3U);
    return _S1112;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_2, uint lobe_2, bool surface_4, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1113;
    (&_S1113)->extinction_behind = extinction_behind_0;
    (&_S1113)->extinction_front = extinction_front_0;
    (&_S1113)->fillings = fillings_0;
    (&_S1113)->side = side_0;
    (&_S1113)->depth = depth_2;
    (&_S1113)->lobe = lobe_2;
    (&_S1113)->surface = surface_4;
    (&_S1113)->length = length_2;
    (&_S1113)->width = width_1;
    (&_S1113)->own = *own_2;
    (&_S1113)->fiber = fiber_0;
    return _S1113;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1114 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1114)
    {
        return 0.07957746833562851f;
    }
    float _S1115 = g_0 * g_0;
    return (1.0f - _S1115) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1115 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_8, float3  b_6)
{
    float3  _S1116 = a_8 / b_6;
    float3  _S1117 = make_float3 (0.0f);
    bool3  _S1118 = b_6 == _S1117;
    float3  _S1119 = _slang_select(_S1118, _S1117,_S1116);
    return _S1119;
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_6)
{
    Reservoir candidate_2 = r_7;
    uint _S1120 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1121 = insertBits_0(_S1120, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1121;
    (&candidate_2)->f = f_6;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_6)
{
    Random _S1122 = draw(random_state_6, 11U);
    Random _S1123 = draw(random_state_6, 2147483659U);
    float _S1124 = 1.0f - 2.0f * _S1122.value;
    float _S1125 = (F32_sqrt(((F32_max((1.0f - _S1124 * _S1124), (0.0f))))));
    float _S1126 = 6.28318548202514648f * _S1123.value;
    return make_float3 (_S1125 * (F32_cos((_S1126))), _S1125 * (F32_sin((_S1126))), _S1124);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_7, float * pdf_4)
{
    bool _S1127 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1127)
    {
        *pdf_4 = 0.07957746833562851f;
        float3  _S1128 = isotropic_0(random_state_7);
        return _S1128;
    }
    Random _S1129 = draw(random_state_7, 11U);
    Random _S1130 = draw(random_state_7, 2147483659U);
    float _S1131 = g_1 * g_1;
    float _S1132 = 2.0f * g_1;
    float _S1133 = (1.0f - _S1131) / (1.0f - g_1 + _S1132 * _S1129.value);
    float _S1134 = clamp_1((1.0f + _S1131 - _S1133 * _S1133) / _S1132, -1.0f, 1.0f);
    float _S1135 = (F32_sqrt(((F32_max((1.0f - _S1134 * _S1134), (0.0f))))));
    float _S1136 = 6.28318548202514648f * _S1130.value;
    float _S1137 = phaseHG_0(g_1, _S1134);
    *pdf_4 = _S1137;
    float3  _S1138 = tangentToWorld(make_float3 (_S1135 * (F32_cos((_S1136))), _S1134, _S1135 * (F32_sin((_S1136)))), dir_9);
    float3  _S1139 = ((((_S1138)) * make_float3(rnorm3df(((_S1138)).x, ((_S1138)).y, ((_S1138)).z))));
    return _S1139;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_1, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_1, float velvet_0, float3  toon_2, float dispersion_0, float coat_2, float coat_roughness_0, float coat_ior_0, float3  coat_tint_0, float3  coat_normal_0)
{
    BSDFMaterial _S1140;
    (&_S1140)->albedo = albedo_1;
    (&_S1140)->emissive = emissive_0;
    (&_S1140)->roughness = roughness_0;
    (&_S1140)->metallic = metallic_0;
    (&_S1140)->transmission = transmission_0;
    (&_S1140)->ior = ior_1;
    (&_S1140)->absorption = absorption_0;
    (&_S1140)->specular_tint = specular_tint_0;
    (&_S1140)->specular_level = specular_level_0;
    (&_S1140)->translucent = translucent_0;
    (&_S1140)->sheen = sheen_2;
    (&_S1140)->sheen_roughness = sheen_roughness_0;
    (&_S1140)->anisotropy = anisotropy_0;
    (&_S1140)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1140)->tangent = tangent_1;
    (&_S1140)->velvet = velvet_0;
    (&_S1140)->toon = toon_2;
    (&_S1140)->dispersion = dispersion_0;
    (&_S1140)->coat = coat_2;
    (&_S1140)->coat_roughness = coat_roughness_0;
    (&_S1140)->coat_ior = coat_ior_0;
    (&_S1140)->coat_tint = coat_tint_0;
    (&_S1140)->coat_normal = coat_normal_0;
    return _S1140;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1141;
    (&_S1141)->scatter = scatter_1;
    (&_S1141)->extinction = extinction_1;
    (&_S1141)->g = g_2;
    return _S1141;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_15, bool skip_0, uint random_state_8, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1142;
    (&_S1142)->smooth_n = smooth_n_4;
    (&_S1142)->geometry_n = geometry_n_2;
    (&_S1142)->geometry_offset = geometry_offset_2;
    (&_S1142)->material = *material_15;
    (&_S1142)->skip = skip_0;
    (&_S1142)->random_state = random_state_8;
    (&_S1142)->coverage = coverage_0;
    (&_S1142)->encloses = encloses_0;
    (&_S1142)->volume = *volume_0;
    (&_S1142)->fills = fills_0;
    (&_S1142)->hair = hair_0;
    return _S1142;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S1143 = (&surface_5->material)->emissive;
    float3  _S1144 = make_float3 (0.0f);
    bool _S1145 = !top_0;
    float3  _S1146 = _slang_select(_S1145, _S1144,_S1143);
    (&(&lower_0)->material)->emissive = _S1146;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_2)
{
    float _S1147 = surface_6->coverage;
    bool _S1148 = u_2 < _S1147;
    if(_S1148)
    {
        return *surface_6;
    }
    float3  _S1149 = make_float3 (0.0f);
    float3  _S1150 = make_float3 (1.0f);
    BSDFMaterial _S1151 = Material_x24init_0(_S1149, _S1149, 0.0f, 0.0f, 0.0f, 0.0f, _S1149, _S1150, 1.0f, _S1149, _S1149, 0.5f, 0.0f, 0.0f, _S1149, 0.0f, _S1149, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, _S1150, _S1149);
    BSDFMaterial material_16 = _S1151;
    (&material_16)->albedo = _S1150;
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
    bool _S1152 = transmission_1 > 0.0f;
    bool _S1153;
    if(_S1152)
    {
        _S1153 = true;
    }
    else
    {
        _S1153 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1154;
    if(_S1153)
    {
        _S1154 = 1.0f;
    }
    else
    {
        _S1154 = -1.0f;
    }
    return _S1154;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_8)
{
    return (dot_0(dir_10, n_8)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_11)
{
    float3  _S1155 = surface_7->geometry_n;
    float _S1156 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_11);
    FKSurface faced_0 = *surface_7;
    float3  _S1157 = surface_7->smooth_n * make_float3 (_S1156);
    (&faced_0)->smooth_n = _S1157;
    float3  _S1158 = _S1155 * make_float3 (_S1156);
    (&faced_0)->geometry_n = _S1158;
    return faced_0;
}

static __device__ float3  max_0(float3  x_22, float3  y_7)
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
        *_slang_vector_get_element_ptr(&result_12, i_20) = (F32_max((_slang_vector_get_element(x_22, i_20)), (_slang_vector_get_element(y_7, i_20))));
        i_20 = i_20 + int(1);
    }
    return result_12;
}

static __device__ float3  log_0(float3  x_23)
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
        *_slang_vector_get_element_ptr(&result_13, i_21) = (F32_log((_slang_vector_get_element(x_23, i_21))));
        i_21 = i_21 + int(1);
    }
    return result_13;
}

__device__ float3  beerLambert(float distance_3, float3  absorption_1)
{
    float3  _S1159 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1159));
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
    bool _S1160;
    if(open_0)
    {
        _S1160 = prev_rough_0;
    }
    else
    {
        _S1160 = false;
    }
    if(_S1160)
    {
        _S1160 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S1160 = false;
    }
    return _S1160;
}

__device__ bool dispersive(BSDFMaterial material_17)
{
    bool _S1161 = (material_17.dispersion) > 0.0f;
    bool _S1162;
    if(_S1161)
    {
        _S1162 = (material_17.ior) != 1.0f;
    }
    else
    {
        _S1162 = false;
    }
    return _S1162;
}

__device__ static const FixedArray<float, 81>  WAVELENGTH_CDF_0 = { {
    0.0f, 0.00006510900129797f, 0.00018772999465f, 0.00045414001215249f, 0.00105610000900924f, 0.00218509999103844f, 0.00430169980973005f, 0.00824129953980446f, 0.01521500013768673f, 0.02649199962615967f, 0.04202799871563911f, 0.06183499842882156f, 0.08581099659204483f, 0.11225000023841858f, 0.1395999938249588f, 0.16642999649047852f, 0.19130000472068787f, 0.21376000344753265f, 0.23378999531269073f, 0.25200000405311584f, 0.26912999153137207f, 0.28512999415397644f, 0.3002299964427948f, 0.31536000967025757f, 0.33153998851776123f, 0.34944000840187073f, 0.36937999725341797f, 0.39127999544143677f, 0.41528999805450439f, 0.4412899911403656f, 0.46840000152587891f, 0.49524000287055969f, 0.52063000202178955f, 0.54398000240325928f, 0.56476002931594849f, 0.58348000049591064f, 0.60238999128341675f, 0.62285000085830688f, 0.64474999904632568f, 0.66809999942779541f, 0.69291001558303833f, 0.71846002340316772f, 0.74393999576568604f, 0.76951998472213745f, 0.79534000158309937f, 0.82078999280929565f, 0.8454899787902832f, 0.86935001611709595f, 0.89191997051239014f, 0.91228997707366943f, 0.92987000942230225f, 0.94483000040054321f, 0.95753002166748047f, 0.96790999174118042f, 0.97605997323989868f, 0.98237001895904541f, 0.98721998929977417f, 0.9908599853515625f, 0.99356001615524292f, 0.99550998210906982f, 0.9969099760055542f, 0.99787998199462891f, 0.99852001667022705f, 0.99895000457763672f, 0.99924999475479126f, 0.99948000907897949f, 0.99963998794555664f, 0.99975001811981201f, 0.99983000755310059f, 0.99988001585006714f, 0.99990999698638916f, 0.99993997812271118f, 0.99996000528335571f, 0.99997997283935547f, 0.99998998641967773f, 0.99998998641967773f, 0.99998998641967773f, 1.0f, 1.0f, 1.0f, 1.0f
} };
__device__ float2  sampleWavelength(float u_3)
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
        uint _S1163 = (low_1 + high_1 + 1U) / 2U;
        bool _S1164 = (WAVELENGTH_CDF_0[_S1163]) <= u_3;
        if(_S1164)
        {
            low_1 = _S1163;
        }
        else
        {
            uint _S1165 = _S1163 - 1U;
            high_1 = _S1165;
        }
    }
    uint _S1166 = low_1;
    float _S1167 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_3 - WAVELENGTH_CDF_0[_S1166]) / _S1167), _S1167 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_5)
{
    float _S1168 = clamp_1((wavelength_5 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1169 = (U32_min((uint(_S1168)), (79U)));
    uint _S1170 = 3U * _S1169;
    float3  _S1171 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1170], WAVELENGTH_WEIGHTS_0[_S1170 + 1U], WAVELENGTH_WEIGHTS_0[_S1170 + 2U]);
    float3  _S1172 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1170 + 3U], WAVELENGTH_WEIGHTS_0[_S1170 + 4U], WAVELENGTH_WEIGHTS_0[_S1170 + 5U]);
    return _S1171 + (_S1172 - _S1171) * make_float3 (_S1168 - float(_S1169));
}

__device__ float dispersedIor(float ior_2, float dispersion_1, float wavelength_6)
{
    float _S1173 = (ior_2 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1174 = _S1173 * (1.0f / (wavelength_6 * wavelength_6) - 2.89662933349609375f);
    bool _S1175 = dispersion_1 > 0.0f;
    float _S1176 = _slang_select(_S1175, _S1174,0.0f);
    return ior_2 + _S1176;
}

__device__ float2  vertexEta(BSDFMaterial material_18, float n_dot_v_0)
{
    bool _S1177 = n_dot_v_0 < 0.0f;
    float _S1178 = _slang_select(_S1177, material_18.ior,1.0f);
    float _S1179 = _slang_select(_S1177, 1.0f,material_18.ior);
    return make_float2 (_S1178, _S1179);
}

__device__ float2  wavelengthEta(BSDFMaterial material_19, float n_dot_v_1, float wavelength_7)
{
    BSDFMaterial refractive_0 = material_19;
    float _S1180 = dispersedIor(material_19.ior, material_19.dispersion, wavelength_7);
    bool _S1181 = wavelength_7 > 0.0f;
    float _S1182 = _slang_select(_S1181, _S1180,material_19.ior);
    (&refractive_0)->ior = _S1182;
    float2  _S1183 = vertexEta(refractive_0, n_dot_v_1);
    return _S1183;
}

__device__ bool neeDecision(BSDFMaterial material_20, float n_dot_v_2, float eta_i_5, float eta_o_4)
{
    float _S1184 = fresnel((F32_abs((n_dot_v_2))), eta_i_5, eta_o_4);
    float3  _S1185 = mix_0(make_float3 (_S1184), material_20.albedo, material_20.metallic);
    float _S1186 = rgb_to_greyscale(_S1185);
    float _S1187 = (F32_max(((1.0f - _S1186) * (1.0f - material_20.metallic) * (1.0f - material_20.transmission)), (0.0f)));
    bool _S1188 = _S1187 > 0.03999999910593033f;
    bool _S1189;
    if(_S1188)
    {
        _S1189 = true;
    }
    else
    {
        _S1189 = (material_20.roughness) > 0.20000000298023224f;
    }
    return _S1189;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_21)
{
    float _S1190 = rgb_to_greyscale(material_21->translucent);
    return _S1190 > 0.0f;
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
    MediumSides _S1191;
    (&_S1191)->behind = *behind_1;
    (&_S1191)->front = *front_0;
    (&_S1191)->fillings = fillings_1;
    (&_S1191)->face = face_1;
    return _S1191;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1192 = surface_8->geometry_n;
    MediumSides _S1193 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S1193;
    bool _S1194 = surface_8->encloses;
    if(_S1194)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S1195 = (dot_0(dir_12, _S1192)) > 0.0f;
        if(_S1195)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_3, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1196 = surface_9->geometry_n;
    ShadowContext _S1197 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1198 = surface_9->encloses;
    ShadowContext context_4;
    if(_S1198)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S1199 = - _S1196;
        float3  _S1200 = _slang_select(turned_0, _S1199,_S1196);
        (&faced_1)->geometry_n = _S1200;
        FKMedium _S1201 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1202 = faced_1;
        FKMedium _S1203 = _S1201;
        MediumSides _S1204 = mediumSides_0(&_S1202, &_S1203, filling_1, dir_13, outside_1);
        ShadowContext _S1205 = ShadowContext_x24init_0(_S1204.behind.extinction, _S1204.front.extinction, _S1204.fillings, _S1196, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1206 = _S1204.fillings;
            ShadowContext _S1207 = ShadowContext_x24init_0(_S1204.front.extinction, _S1204.behind.extinction, uint2 {_S1206.y, _S1206.x}, _S1196, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1207;
        }
        else
        {
            context_4 = _S1205;
        }
    }
    else
    {
        context_4 = _S1197;
    }
    return context_4;
}

static __device__ bool any_1(bool3  x_24)
{
    bool result_14 = false;
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
        if(result_14)
        {
            result_14 = true;
        }
        else
        {
            result_14 = (bool((_slang_vector_get_element(x_24, i_22))));
        }
        i_22 = i_22 + int(1);
    }
    return result_14;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_5, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_22, float eta_i_6, float eta_o_5, bool competing_1, uint random_state_9)
{
    float3  _S1208 = light_2->dir;
    bool _S1209 = (dot_0(geometry_n_4, - in_dir_5) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 6>  throughputs_1;
    FixedArray<float, 6>  pdfs_4;
    BSDF(in_dir_5, _S1208, smooth_n_5, *material_22, eta_i_6, eta_o_5, _S1209, random_state_9, &throughputs_1, &pdfs_4);
    bool _S1210;
    if(competing_1)
    {
        _S1210 = (light_2->density) != 0.0f;
    }
    else
    {
        _S1210 = false;
    }
    float3  _S1211 = make_float3 (0.0f);
    uint i_23 = 0U;
    float3  f_7 = _S1211;
    for(;;)
    {
        if(i_23 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S1212 = (pdfs_4[i_23]) > 0.0f;
        if(_S1212)
        {
            float3  f_8;
            if(_S1210)
            {
                float _S1213 = light_2->density;
                float _S1214 = pdfs_4[i_23] / light_2->density;
                float3  f_9 = f_7 + throughputs_1[i_23] * make_float3 (pdfs_4[i_23]) / make_float3 (_S1213 * (1.0f + _S1214 * _S1214));
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
    if(_S1210)
    {
        f_7 = f_7 * light_2->radiance * make_float3 (light_2->density);
    }
    else
    {
        f_7 = f_7 * light_2->radiance;
    }
    return f_7;
}

__device__ float3  skyBSDF(float3  in_dir_6, float3  dir_14, FKSurface surface_10, BSDFMaterial material_23, float2  eta_3, bool is_inside_5, float pdf_5, uint random_state_10)
{
    FKSurface _S1215 = surface_10;
    BSDFMaterial _S1216 = material_23;
    FixedArray<float3 , 6>  terms_3;
    FixedArray<float, 6>  pdfs_5;
    float3  _S1217 = skyLobes_0(in_dir_6, dir_14, &_S1215, &_S1216, eta_3, is_inside_5, pdf_5, random_state_10, &terms_3, &pdfs_5);
    return _S1217;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_11, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S1218;
    (&_S1218)->unit_direction = unit_direction_1;
    (&_S1218)->throughput = throughput_1;
    (&_S1218)->random_state = random_state_11;
    (&_S1218)->refracted = refracted_3;
    (&_S1218)->lobe = lobe_4;
    (&_S1218)->pdf = pdf_6;
    return _S1218;
}

static __device__ float unshared_0(float x_25)
{
    return x_25;
}

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_6, float U1_0, float U2_0)
{
    float3  _S1219 = make_float3 (alpha_6 * Ve_0.x, alpha_6 * Ve_0.y, Ve_0.z);
    float3  _S1220 = ((((_S1219)) * make_float3(rnorm3df(((_S1219)).x, ((_S1219)).y, ((_S1219)).z))));
    float _S1221 = _S1220.x;
    float _S1222 = _S1220.y;
    float _S1223 = _S1221 * _S1221 + _S1222 * _S1222;
    float3  _S1224;
    if(_S1223 > 0.0f)
    {
        float3  _S1225 = make_float3 (- _S1222, _S1221, 0.0f);
        float _S1226 = (rsqrtf((_S1223)));
        _S1224 = _S1225 * make_float3 (_S1226);
    }
    else
    {
        _S1224 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S1227 = cross_0(_S1220, _S1224);
    float _S1228 = (F32_sqrt((U1_0)));
    float _S1229 = 6.28318548202514648f * U2_0;
    float _S1230 = _S1228 * (F32_cos((_S1229)));
    float t2_0 = _S1228 * (F32_sin((_S1229)));
    float _S1231 = 0.5f * (1.0f + _S1220.z);
    float t2_1 = (1.0f - _S1231) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S1230 * _S1230)))))) + _S1231 * t2_0;
    float3  _S1232 = make_float3 (_S1230) * _S1224 + make_float3 (t2_1) * _S1227;
    float _S1233 = unshared_0(_S1230);
    float _S1234 = unshared_0(_S1230);
    float3  _S1235 = _S1232 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S1233 * _S1234 - t2_1 * t2_1))))))) * _S1220;
    float3  _S1236 = make_float3 (alpha_6 * _S1235.x, alpha_6 * _S1235.y, (F32_max((0.0f), (_S1235.z))));
    float3  _S1237 = ((((_S1236)) * make_float3(rnorm3df(((_S1236)).x, ((_S1236)).y, ((_S1236)).z))));
    return _S1237;
}

__device__ float3  worldToTangent(float3  v_8, float3  n_9)
{
    float3  a_9 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S1238 = (F32_abs((dot_0(n_9, a_9)))) > 0.9999847412109375f;
    float3  a_10;
    if(_S1238)
    {
        float3  _S1239 = make_float3 (1.0f, 0.0f, 0.0f);
        a_10 = _S1239;
    }
    else
    {
        a_10 = a_9;
    }
    float3  _S1240 = cross_0(n_9, a_10);
    float3  _S1241 = ((((_S1240)) * make_float3(rnorm3df(((_S1240)).x, ((_S1240)).y, ((_S1240)).z))));
    float3  _S1242 = cross_0(n_9, _S1241);
    return make_float3 (dot_0(v_8, _S1241), dot_0(v_8, n_9), dot_0(v_8, _S1242));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_9, float3  n_i_11, float alpha_7, AnisotropicFrame frame_5, uint * random_state_12, uint first_2)
{
    Random _S1243 = draw(*random_state_12, first_2);
    Random _S1244 = draw(*random_state_12, first_2 | 2147483648U);
    *random_state_12 = _S1244.state;
    float _S1245 = frame_5.alphas.x;
    bool _S1246 = _S1245 > 0.0f;
    if(_S1246)
    {
        float3  _S1247 = anisotropicLocal(v_9, frame_5.tangent, n_i_11);
        float _S1248 = frame_5.alphas.y;
        float3  _S1249 = make_float3 (_S1245 * _S1247.x, _S1248 * _S1247.y, _S1247.z);
        float3  _S1250 = ((((_S1249)) * make_float3(rnorm3df(((_S1249)).x, ((_S1249)).y, ((_S1249)).z))));
        float3  _S1251 = sampleGGXVNDF(_S1250, 1.0f, _S1243.value, _S1244.value);
        float3  _S1252 = make_float3 (_S1245 * _S1251.x, _S1248 * _S1251.y, _S1251.z);
        float3  _S1253 = ((((_S1252)) * make_float3(rnorm3df(((_S1252)).x, ((_S1252)).y, ((_S1252)).z))));
        return make_float3 (_S1253.x) * frame_5.tangent + make_float3 (_S1253.y) * cross_0(n_i_11, frame_5.tangent) + make_float3 (_S1253.z) * n_i_11;
    }
    float3  _S1254 = worldToTangent(v_9, n_i_11);
    float3  _S1255 = sampleGGXVNDF(float3 {_S1254.x, _S1254.z, _S1254.y}, alpha_7, _S1243.value, _S1244.value);
    float3  _S1256 = float3 {_S1255.x, _S1255.z, _S1255.y};
    float3  _S1257 = tangentToWorld(_S1256, n_i_11);
    return _S1257;
}

__device__ __forceinline__ float3  coatHalf(float3  v_10, CoatFrame coat_frame_4, uint random_state_13)
{
    bool _S1258 = !((dot_0(coat_frame_4.normal, v_10)) > 0.0f);
    if(_S1258)
    {
        return make_float3 (0.0f);
    }
    uint state_3 = random_state_13;
    float3  _S1259 = sampleHalfVector(v_10, coat_frame_4.normal, coat_frame_4.alpha, AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f)), &state_3, 1U);
    return _S1259;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  v_11, float3  n_i_12, float n_i_dot_v_3, BSDFMaterial material_24, Weights w_14, uint random_state_14)
{
    float3  _S1260 = make_float3 (1.0f);
    SampleBSDF _S1261 = SampleBSDF_x24init_0(_S1260, _S1260, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1261;
    Random _S1262 = draw(random_state_14, 3U);
    Random _S1263 = draw(random_state_14, 2147483651U);
    (&sample_1)->random_state = _S1263.state;
    float _S1264 = _S1262.value;
    float _S1265 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1264 * _S1264))))));
    float _S1266 = 6.28318548202514648f * _S1263.value;
    float3  _S1267 = tangentToWorld(make_float3 (_S1265 * (F32_cos((_S1266))), _S1262.value, _S1265 * (F32_sin((_S1266)))), n_i_12);
    (&sample_1)->unit_direction = _S1267;
    (&sample_1)->lobe = 4U;
    float3  _S1268 = sheenVelvetBSDF((&sample_1)->unit_direction, v_11, n_i_12, material_24, w_14);
    (&sample_1)->throughput = _S1268;
    float _S1269 = sheenVelvetPDF(_S1262.value, n_i_dot_v_3, w_14);
    (&sample_1)->pdf = _S1269;
    return sample_1;
}

__device__ __forceinline__ SampleBSDF coatSample(float3  in_dir_7, float3  v_12, float3  coat_h_3, CoatFrame coat_frame_5, Weights w_15, uint random_state_15)
{
    float3  _S1270 = make_float3 (1.0f);
    SampleBSDF _S1271 = SampleBSDF_x24init_0(_S1270, _S1270, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1271;
    float3  _S1272 = reflect_0(in_dir_7, coat_h_3);
    float3  _S1273 = ((((_S1272)) * make_float3(rnorm3df(((_S1272)).x, ((_S1272)).y, ((_S1272)).z))));
    (&sample_2)->unit_direction = _S1273;
    (&sample_2)->random_state = random_state_15;
    (&sample_2)->lobe = 5U;
    float3  _S1274 = coatBSDF(w_15);
    (&sample_2)->throughput = _S1274;
    float _S1275 = coatPDF(v_12, coat_h_3, coat_frame_5, w_15);
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

__device__ __forceinline__ SampleBSDF diffuseSample(float u_4, float3  n_i_13, float n_i_dot_v_4, BSDFMaterial material_25, Weights w_16, uint random_state_16)
{
    float3  _S1281 = make_float3 (1.0f);
    SampleBSDF _S1282 = SampleBSDF_x24init_0(_S1281, _S1281, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1282;
    Random _S1283 = draw(random_state_16, 3U);
    Random _S1284 = draw(random_state_16, 2147483651U);
    (&sample_3)->random_state = _S1284.state;
    float3  _S1285 = sampleCosWeightedHemisphere(_S1283.value, _S1284.value);
    float _S1286 = translucentShare(material_25);
    bool _S1287 = u_4 < (w_16.p_diffuse * _S1286);
    float _S1288 = _S1285.y;
    float _S1289 = - _S1288;
    float _S1290 = _slang_select(_S1287, _S1289,_S1288);
    float3  _S1291 = tangentToWorld(make_float3 (_S1285.x, _S1290, _S1285.z), n_i_13);
    (&sample_3)->unit_direction = _S1291;
    (&sample_3)->refracted = _S1287;
    (&sample_3)->lobe = 0U;
    float3  _S1292 = diffuseBSDF((&sample_3)->unit_direction, n_i_13, material_25, w_16);
    (&sample_3)->throughput = _S1292;
    float _S1293 = diffusePDF(_S1290, n_i_dot_v_4, material_25, w_16);
    (&sample_3)->pdf = _S1293;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_14, ToonProfile profile_3, Weights w_17, uint random_state_17)
{
    float3  _S1294 = make_float3 (1.0f);
    SampleBSDF _S1295 = SampleBSDF_x24init_0(_S1294, _S1294, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1295;
    Random _S1296 = draw(random_state_17, 3U);
    Random _S1297 = draw(random_state_17, 2147483651U);
    (&sample_4)->random_state = _S1297.state;
    float _S1298 = _S1296.value * profile_3.norm / 6.28318548202514648f;
    float t_23;
    if(profile_3.glossy)
    {
        t_23 = (F32_acos((clamp_1(1.0f - _S1298, -1.0f, 1.0f))));
    }
    else
    {
        t_23 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1298)))), (1.0f))))));
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
        float _S1299 = toonP(t_23, profile_3.a, profile_3.s);
        float _S1300 = _S1299 * (F32_sin((t_23)));
        float _S1301;
        if(profile_3.glossy)
        {
            _S1301 = 1.0f;
        }
        else
        {
            _S1301 = (F32_cos((t_23)));
        }
        float _S1302 = _S1300 * _S1301;
        float _S1303 = toonIntegral(t_23, profile_3.a, profile_3.s, profile_3.glossy);
        float _S1304 = (_S1303 - _S1298) / _S1302;
        bool _S1305 = _S1302 > 0.0f;
        float _S1306 = _slang_select(_S1305, _S1304,0.0f);
        float _S1307 = clamp_1(t_23 - _S1306, 0.0f, profile_3.b);
        int k_3 = k_2 + int(1);
        t_23 = _S1307;
        k_2 = k_3;
    }
    float _S1308 = 6.28318548202514648f * _S1297.value;
    float _S1309 = (F32_sin((t_23)));
    float3  _S1310 = tangentToWorld(make_float3 (_S1309 * (F32_cos((_S1308))), (F32_cos((t_23))), _S1309 * (F32_sin((_S1308)))), profile_3.axis);
    (&sample_4)->unit_direction = _S1310;
    bool _S1311 = (dot_0(n_i_14, (&sample_4)->unit_direction)) < 0.0f;
    (&sample_4)->refracted = _S1311;
    (&sample_4)->lobe = 6U;
    float3  _S1312 = toonBSDF((&sample_4)->unit_direction, n_i_14, profile_3, w_17);
    (&sample_4)->throughput = _S1312;
    float _S1313 = toonPDF((&sample_4)->unit_direction, n_i_14, profile_3, w_17);
    (&sample_4)->pdf = _S1313;
    return sample_4;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_1, float3  n_i_15, float alpha_8, AnisotropicFrame frame_6, BSDFMaterial material_26, Weights w_18, float pdf_h_3, float eta_i_7, float eta_o_6, uint random_state_18)
{
    float3  _S1314 = make_float3 (1.0f);
    SampleBSDF _S1315 = SampleBSDF_x24init_0(_S1314, _S1314, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1315;
    (&sample_5)->unit_direction = w_18.refracted;
    (&sample_5)->random_state = random_state_18;
    (&sample_5)->refracted = true;
    (&sample_5)->lobe = 1U;
    float3  _S1316 = refractBSDF((&sample_5)->unit_direction, n_i_15, alpha_8, frame_6, material_26, w_18);
    (&sample_5)->throughput = _S1316;
    float _S1317 = refractPDF(dot_0((&sample_5)->unit_direction, ggx_n_1), pdf_h_3, w_18, eta_i_7, eta_o_6);
    (&sample_5)->pdf = _S1317;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_8, float3  ggx_n_2, float3  n_i_16, float alpha_9, AnisotropicFrame frame_7, Weights w_19, float pdf_h_4, uint random_state_19)
{
    float3  _S1318 = make_float3 (1.0f);
    SampleBSDF _S1319 = SampleBSDF_x24init_0(_S1318, _S1318, 0U, false, 0U, 0.0f);
    SampleBSDF sample_6 = _S1319;
    float3  _S1320 = reflect_0(in_dir_8, ggx_n_2);
    float3  _S1321 = ((((_S1320)) * make_float3(rnorm3df(((_S1320)).x, ((_S1320)).y, ((_S1320)).z))));
    (&sample_6)->unit_direction = _S1321;
    (&sample_6)->random_state = random_state_19;
    (&sample_6)->lobe = 2U;
    float3  _S1322 = reflectBSDF((&sample_6)->unit_direction, n_i_16, alpha_9, frame_7, w_19);
    (&sample_6)->throughput = _S1322;
    float _S1323 = reflectPDF(pdf_h_4, w_19);
    (&sample_6)->pdf = _S1323;
    return sample_6;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_9, float3  n_10, BSDFMaterial material_27, float eta_i_8, float eta_o_7, uint random_init_0, float2  screen_space_0)
{
    uint random_state_20 = random_init_0;
    float3  _S1324 = negate_0(in_dir_9);
    float _S1325 = dot_0(n_10, _S1324);
    float _S1326 = sign_0(_S1325);
    float3  n_i_17 = n_10 * make_float3 (_S1326);
    float _S1327 = (F32_abs((_S1325)));
    float _S1328 = material_27.roughness;
    float _S1329 = _S1328 * _S1328;
    AnisotropicFrame _S1330 = anisotropicFrame(material_27, n_i_17);
    SheenProfile _S1331 = sheenProfile(_S1324, n_i_17, material_27);
    CoatFrame _S1332 = coatFrame(material_27, n_i_17);
    float3  _S1333 = coatSeries(_S1332, material_27);
    float3  _S1334 = sampleHalfVector(_S1324, n_i_17, _S1329, _S1330, &random_state_20, 0U);
    float3  _S1335 = coatHalf(_S1324, _S1332, random_init_0);
    Weights _S1336 = lobeWeights(in_dir_9, _S1324, n_i_17, _S1334, _S1335, _S1330, _S1331, _S1332, _S1333, material_27, eta_i_8, eta_o_7);
    Random _S1337 = draw(random_state_20, 2U);
    random_state_20 = _S1337.state;
    bool _S1338 = (_S1337.value) < (_S1336.p_sheen_velvet);
    if(_S1338)
    {
        SampleBSDF _S1339 = sheenVelvetSample(_S1324, n_i_17, _S1327, material_27, _S1336, random_state_20);
        return _S1339;
    }
    float _S1340 = _S1337.value - _S1336.p_sheen_velvet;
    bool _S1341 = _S1340 < (_S1336.p_coat);
    if(_S1341)
    {
        SampleBSDF _S1342 = coatSample(in_dir_9, _S1324, _S1335, _S1332, _S1336, random_state_20);
        return _S1342;
    }
    float _S1343 = _S1340 - _S1336.p_coat;
    bool _S1344 = _S1343 < (_S1336.p_diffuse);
    if(_S1344)
    {
        SampleBSDF _S1345 = diffuseSample(_S1343, n_i_17, _S1327, material_27, _S1336, random_state_20);
        return _S1345;
    }
    bool _S1346 = _S1343 < (_S1336.p_diffuse + _S1336.p_toon);
    if(_S1346)
    {
        ToonProfile _S1347 = toonProfile(_S1324, n_i_17, material_27);
        SampleBSDF _S1348 = toonSample(n_i_17, _S1347, _S1336, random_state_20);
        return _S1348;
    }
    float _S1349 = vndfPDF(_S1324, _S1334, n_i_17, _S1327, _S1329, _S1330, _S1336.v_dot_h);
    bool _S1350 = (_S1343 - _S1336.p_toon) < (_S1336.p_diffuse + _S1336.p_refract);
    if(_S1350)
    {
        SampleBSDF _S1351 = refractSample(_S1334, n_i_17, _S1329, _S1330, material_27, _S1336, _S1349, eta_i_8, eta_o_7, random_state_20);
        return _S1351;
    }
    SampleBSDF _S1352 = reflectSample(in_dir_9, _S1334, n_i_17, _S1329, _S1330, _S1336, _S1349, random_state_20);
    return _S1352;
}

__device__ __forceinline__ float3  reflectedHalf(float3  in_dir_10, float3  out_dir_1)
{
    float3  _S1353 = negate_0(in_dir_10);
    float3  _S1354 = _S1353 + out_dir_1;
    float3  _S1355 = ((((_S1354)) * make_float3(rnorm3df(((_S1354)).x, ((_S1354)).y, ((_S1354)).z))));
    return _S1355;
}

__device__ __forceinline__ float3  refractedHalf(float3  in_dir_11, float3  out_dir_2, float3  n_11, float eta_i_9, float eta_o_8)
{
    float3  _S1356 = negate_0(in_dir_11);
    float3  _S1357 = negate_0(make_float3 (eta_i_9) * _S1356 + make_float3 (eta_o_8) * out_dir_2);
    float3  _S1358 = ((((_S1357)) * make_float3(rnorm3df(((_S1357)).x, ((_S1357)).y, ((_S1357)).z))));
    float _S1359 = sign_0(dot_0(n_11, _S1356));
    float _S1360 = sign_0(dot_0(_S1357, n_11 * make_float3 (_S1359)));
    return _S1358 * make_float3 (_S1360);
}

__device__ __forceinline__ float3  sampledHalf(float3  v_13, float3  n_i_18, float alpha_10, AnisotropicFrame frame_8, uint random_state_21)
{
    uint state_4 = random_state_21;
    float3  _S1361 = sampleHalfVector(v_13, n_i_18, alpha_10, frame_8, &state_4, 0U);
    return _S1361;
}

__device__ bool withinInverseFootprint(float pdf_7, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1362 = pdf_7 > 0.0f;
    bool _S1363;
    if(_S1362)
    {
        if(diffuse_0)
        {
            _S1363 = true;
        }
        else
        {
            _S1363 = (pdf_7 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1363 = false;
    }
    return _S1363;
}

__device__ bool roughLobe(float pdf_8, bool diffuse_1, float roughness_1)
{
    bool _S1364 = pdf_8 > 0.0f;
    bool _S1365;
    if(_S1364)
    {
        if(diffuse_1)
        {
            _S1365 = true;
        }
        else
        {
            _S1365 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1365 = false;
    }
    return _S1365;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1366 = layers_0 > 1U;
    bool _S1367;
    if(_S1366)
    {
        _S1367 = refracting_0 != passed_0;
    }
    else
    {
        _S1367 = false;
    }
    return _S1367;
}

static __device__ float widened_0(float spread_1, float pdf_9, bool delta_0)
{
    float _S1368 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_9))))), (3.14159274101257324f)));
    bool _S1369 = !delta_0;
    float _S1370 = _slang_select(_S1369, _S1368,0.0f);
    return spread_1 + _S1370;
}

static __device__ bool boundsVolume_0(FKSurface * surface_11)
{
    return surface_11->encloses;
}

static __device__ bool leavesInFront_0(float3  face_2, float3  dir_15, float3  g_3)
{
    return ((dot_0(dir_15, g_3)) > 0.0f) == ((dot_0(g_3, face_2)) > 0.0f);
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_8, bool replay_2, float scale_3, Selection * sel_7)
{
    float spread_2;
    bool turned_1;
    bool is_inside_6;
    bool viewed_0;
    bool _S1371;
    float density_2;
    float wavelength_8;
    float width_3;
    float sky_pdf_0;
    float threshold_2;
    uint b_7;
    uint layer_0;
    float3  throughput_2;
    float3  spectral_weight_0;
    TreeSample light_3;
    int _S1372;
    Shift ended_0;
    float density_3;
    float spread_3;
    float width_4;
    float sky_pdf_1;
    float spread_4;
    float width_5;
    uint b_8;
    float3  _S1373 = make_float3 (0.0f);
    Shift _S1374 = Shift_x24init_0(_S1373, 0.0f);
    uint _S1375 = r_8->path;
    uint _S1376 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1377 = extractBits_0(_S1375, 5U, 5U);
    uint _S1378 = extractBits_0(_S1375, 10U, 2U);
    uint _S1379 = extractBits_0(_S1375, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1380 = _S1379 >= 3U;
        uint _S1381 = _slang_select(_S1380, 1U,0U);
        uint _S1382 = _S1376 + _S1381;
        uint _S1383 = (fcptMaxBounces());
        passes_0 = _S1382 > _S1383;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1374;
    }
    uint _S1384 = _S1377 - 1U;
    bool _S1385 = _S1379 == 3U;
    uint _S1386 = _slang_select(_S1385, 1U,0U);
    uint _S1387 = _S1376 + _S1386;
    bool _S1388 = _S1378 == 0U;
    uint _S1389 = _slang_select(_S1388, _S1387,_S1384);
    FKHit _S1390 = (fcptReservoirHit((*r_8)));
    float3  _S1391 = dom_7->x0;
    float3  _S1392 = dom_7->x1 - dom_7->x0;
    float3  _S1393 = ((((_S1392)) * make_float3(rnorm3df(((_S1392)).x, ((_S1392)).y, ((_S1392)).z))));
    FKRay _S1394 = Ray_x24init_0(dom_7->x1, _S1393);
    FKRay ray_2 = _S1394;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1373;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_2 = throughput_3;
    float3  glowed_0 = _S1373;
    float3  extinction_in_0 = _S1373;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1395 = dom_7->spread;
    float _S1396 = dom_7->width;
    float _S1397 = length_0(_S1392);
    NEEVertex _S1398 = NEEVertex_x24init_0(true, 0.0f, _S1373, _S1373, _S1373);
    NEEVertex nee_vertex_0 = _S1398;
    Vertex _S1399 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1399;
    Reservoir _S1400 = (Reservoir{});
    Reservoir chain_0 = _S1400;
    uint _S1401 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    uint _S1402 = extractBits_0(_S1375, 24U, 8U);
    uint _S1403 = insertBits_0(0U, _S1402, 24U, 8U);
    (&chain_0)->path = _S1403;
    (&ray_2)->origin = _S1391;
    (&hit_4)->distance = _S1397;
    FKMedium _S1404 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1405 = filling_2;
    bool _S1406 = (fcptVaryingUsed());
    uint _S1407 = _slang_select(_S1406, _S1405,4294967295U);
    filling_2 = _S1407;
    scatter_in_0 = _S1404.scatter;
    extinction_in_0 = _S1404.extinction;
    g_in_0 = _S1404.g;
    Reservoir _S1408 = chain_0;
    uint _S1409 = filling_2;
    for(;;)
    {
        bool _S1410 = (fcptVaryingUsed());
        if(_S1410)
        {
            passes_0 = _S1409 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1411 = (fcptMajorant((_S1409)));
            spread_2 = _S1411;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1389;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1378 == 1U;
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
            ended_0 = _S1374;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1395;
            width_3 = _S1396;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_7 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1412 = (&prev_0)->rough;
        if(_S1412)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1413 = stream(_S1401, 384U);
        uint tracking_0 = _S1413;
        weight_2 = throughput_3;
        glowed_0 = _S1373;
        b_7 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        wavelength_8 = _S1395;
        width_3 = _S1396;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1372 = int(1);
                break;
            }
            uint _S1414 = noiseAddress(_S1401, b_7);
            Random _S1415 = draw(_S1414, 10U);
            float _S1416 = freeFlight_0(_S1415.value, spread_2);
            if(passes_0)
            {
                float3  _S1417 = (&ray_2)->origin;
                float3  _S1418 = (&ray_2)->unit_direction;
                float _S1419 = (&hit_4)->distance;
                bool _S1420 = b_7 == 4294967295U;
                uint _S1421 = _slang_select(_S1420, 0U,b_7);
                uint _S1422 = (&prev_0)->lobe;
                uint _S1423 = _slang_select(_S1420, 3U,_S1422);
                float _S1424 = (fcptTrackMedium((_S1409), (_S1417), (_S1418), (_S1419), (&tracking_0), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1421), (_S1423), (_S1420)));
                threshold_2 = _S1424;
            }
            else
            {
                threshold_2 = _S1416;
            }
            bool _S1425 = !(threshold_2 < ((&hit_4)->distance));
            if(_S1425)
            {
                _S1372 = int(1);
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
                float3  _S1426 = pathColor(throughput_2 * glowed_0, throughput_3, 0.0f);
                float3  _S1427 = _S1426 / make_float3 (density_2);
                float3  _S1428 = sel_7->glow + _S1427;
                sel_7->glow = _S1428;
            }
            else
            {
            }
            glowed_0 = _S1373;
            uint b_9 = b_7 + 1U;
            float3  _S1429 = (&ray_2)->origin + make_float3 (threshold_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1429;
            float3  _S1430 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, threshold_2, true);
            float3  _S1431 = weight_2;
            float _S1432 = upsample(weight_2, 0.0f);
            float3  _S1433 = make_float3 (_S1432);
            float3  _S1434 = _slang_select(false, _S1433,_S1431);
            float3  _S1435 = _slang_select(passes_0, _S1434,_S1430);
            float3  throughput_4 = throughput_2 * _S1435;
            uint _S1436 = stream(_S1401, b_9 + 320U);
            tracking_0 = _S1436;
            weight_2 = throughput_3;
            float width_6 = width_3 + wavelength_8 * threshold_2;
            float _S1437 = wavelength_8 + 3.14159274101257324f;
            bool _S1438 = scatterSampled_0(replay_2, b_9, _S1389, passes_0);
            TreeSample _S1439 = TreeSample_x24init_0(_S1373, _S1373, 0.0f, 0U);
            if(_S1438)
            {
                float3  _S1440 = (&ray_2)->origin;
                float3  _S1441 = (&ray_2)->unit_direction;
                float3  _S1442 = (&ray_2)->unit_direction;
                uint _S1443 = noiseAddress(_S1401, b_9);
                float3  _S1444 = extinction_in_0;
                float3  _S1445 = extinction_in_0;
                uint2  _S1446 = make_uint2 (_S1409);
                float3  _S1447 = (&ray_2)->unit_direction;
                uint _S1448 = arrivalLobe_0(b_9, (&prev_0)->lobe);
                FKHit _S1449 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1450 = _S1449;
                ShadowContext _S1451 = ShadowContext_x24init_0(_S1444, _S1445, _S1446, _S1447, b_9, _S1448, false, threshold_2, width_6, &_S1450, false);
                ShadowContext _S1452 = _S1451;
                TreeSample _S1453 = sampleLightTree_0(_S1440, _S1441, _S1442, 0.0f, true, _S1443, &_S1452);
                light_3 = _S1453;
            }
            else
            {
                light_3 = _S1439;
            }
            float _S1454 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1455 = (fcptMaxBounces());
            bool _S1456 = b_9 < _S1455;
            if(_S1456)
            {
                is_inside_6 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_6 = false;
            }
            float _S1457 = _slang_select(is_inside_6, _S1454,0.0f);
            float3  _S1458 = throughput_4 * light_3.radiance;
            float _S1459 = powerHeuristic(light_3.density, _S1457);
            float3  _S1460 = pathColor(_S1458 * make_float3 (_S1454 * _S1459), throughput_3, 0.0f);
            float3  _S1461 = _slang_select(_S1438, _S1460,_S1373);
            if(replay_2)
            {
                viewed_0 = b_9 == _S1389;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1462 = _S1378 == 2U;
                if(_S1462)
                {
                    float _S1463 = resamplingTarget(_S1461);
                    passes_0 = _S1463 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1464 = Shift_x24init_0(_S1461, 1.0f);
                    _S1372 = int(0);
                    ended_0 = _S1464;
                    spread_2 = _S1437;
                    threshold_2 = width_6;
                    spectral_weight_0 = throughput_4;
                    layer_0 = b_9;
                    break;
                }
                _S1372 = int(0);
                ended_0 = _S1374;
                spread_2 = _S1437;
                threshold_2 = width_6;
                spectral_weight_0 = throughput_4;
                layer_0 = b_9;
                break;
            }
            bool _S1465 = !replay_2;
            if(_S1465)
            {
                Reservoir candidate_3 = _S1408;
                uint _S1466 = extractBits_0(_S1408.path, 24U, 8U);
                uint _S1467 = insertBits_0(0U, _S1466, 24U, 8U);
                uint _S1468 = extractBits_0(_S1408.path, 10U, 2U);
                bool _S1469 = _S1468 == 1U;
                if(_S1469)
                {
                    float3  _S1470 = safeDivide(_S1461, _S1373);
                    (&candidate_3)->radiance = _S1470;
                }
                else
                {
                    uint _S1471 = insertBits_0(_S1467, b_9 + 1U, 5U, 5U);
                    uint _S1472 = insertBits_0(_S1471, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1472;
                }
                Reservoir _S1473 = withEnd(candidate_3, 0U, b_9, _S1461);
                offer(sel_7, _S1473, _S1461 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1474 = survivalProbability(abs_0(throughput_4), density_2);
                uint _S1475 = noiseAddress(_S1401, b_9);
                Random _S1476 = draw(_S1475, 8U);
                bool _S1477 = _S1474 < (_S1476.value);
                if(_S1477)
                {
                    _S1371 = true;
                }
                else
                {
                    uint _S1478 = (fcptMaxBounces());
                    _S1371 = b_9 >= _S1478;
                }
                if(_S1371)
                {
                    _S1372 = int(0);
                    ended_0 = _S1374;
                    spread_2 = _S1437;
                    threshold_2 = width_6;
                    spectral_weight_0 = throughput_4;
                    layer_0 = b_9;
                    break;
                }
                float _S1479 = density_2 * _S1474;
                density_2 = _S1479;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1480 = noiseAddress(_S1401, b_9);
            float3  _S1481 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1480, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1481;
            NEEVertex _S1482 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1373, (&ray_2)->origin);
            nee_vertex_0 = _S1482;
            Vertex _S1483 = scatteredVertex_0(false);
            prev_0 = _S1483;
            float _S1484 = (&prev_0)->pdf;
            FKRay _S1485 = ray_2;
            FKHit _S1486 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1487 = (fcptTraverseInstanceBVH((_S1485), (true), (4.294967296e+09f), (false), (_S1486), (false)));
            hit_4 = _S1487;
            b_7 = b_9;
            throughput_2 = throughput_4;
            wavelength_8 = _S1437;
            width_3 = width_6;
            sky_pdf_0 = _S1484;
        }
        if(_S1372 != int(1))
        {
            width_3 = threshold_2;
            throughput_2 = spectral_weight_0;
            b_7 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1374;
        spread_2 = wavelength_8;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1488 = b_7 == 4294967295U;
    bool _S1489 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1489)
    {
        bool _S1490 = !(&nee_vertex_0)->none;
        float _S1491 = _slang_select(_S1490, sky_pdf_0,0.0f);
        float _S1492 = escapeWeight_0(_S1491, (&ray_2)->unit_direction);
        float3  _S1493 = environment_0((&ray_2)->unit_direction, b_7, (&prev_0)->lobe);
        float3  _S1494 = pathColor(throughput_2 * _S1493, throughput_3, 0.0f);
        if(replay_2)
        {
            bool _S1495 = b_7 == _S1389;
            if(_S1495)
            {
                passes_0 = _S1378 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1494 * make_float3 (_S1492) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1388)
            {
                passes_0 = _S1385;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_7 == _S1376;
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
                return Shift_x24init_0(_S1494 * make_float3 (_S1492), 1.0f);
            }
            return _S1374;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1496 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1497 = _S1496 == 1U;
        if(_S1497)
        {
            uint _S1498 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1499 = _S1498 == b_7;
            float _S1500 = _slang_select(_S1499, 1.0f,_S1492);
            float3  _S1501 = safeDivide(_S1494 * make_float3 (_S1500), _S1373);
            (&candidate_4)->radiance = _S1501;
        }
        else
        {
            bool _S1502 = (&prev_0)->rough;
            if(_S1502)
            {
                uint _S1503 = insertBits_0(_S1403, b_7 + 1U, 5U, 5U);
                uint _S1504 = insertBits_0(_S1503, 3U, 10U, 2U);
                uint _S1505 = insertBits_0(_S1504, (&prev_0)->lobe, 15U, 3U);
                bool _S1506 = (&prev_0)->inside;
                uint _S1507 = _slang_select(_S1506, 1U,0U);
                uint _S1508 = insertBits_0(_S1505, _S1507, 22U, 1U);
                (&candidate_4)->path = _S1508;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1509 = _S1494 * make_float3 (_S1492);
        Reservoir _S1510 = withEnd(candidate_4, 3U, b_7, _S1509);
        offer(sel_7, _S1510, _S1509 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1374;
    }
    float3  _S1511 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1511;
    bool _S1512 = (fcptVaryingUsed());
    if(_S1512)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1513 = !replay_2;
        if(_S1513)
        {
            float3  _S1514 = pathColor(throughput_2 * glowed_0, throughput_3, 0.0f);
            float3  _S1515 = _S1514 / make_float3 (density_2);
            float3  _S1516 = sel_7->glow + _S1515;
            sel_7->glow = _S1516;
        }
        float3  _S1517 = throughput_2 * weight_2;
        throughput_2 = _S1517;
    }
    else
    {
        float3  _S1518 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1519 = throughput_2 * _S1518;
        throughput_2 = _S1519;
    }
    float _S1520 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1521 = b_7 + 1U;
    b_7 = _S1521;
    layer_0 = 0U;
    width_3 = _S1520;
    passes_0 = false;
    wavelength_8 = 0.0f;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_6 = false;
    spectral_weight_0 = throughput_3;
    float3  chain_throughput_0 = _S1373;
    float3  reconnection_0 = _S1373;
    viewed_0 = _S1488;
    for(;;)
    {
        bool _S1522 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1371 = _S1378 == 1U;
        }
        else
        {
            _S1371 = false;
        }
        bool _S1523;
        if(_S1371)
        {
            _S1523 = b_7 == _S1377;
        }
        else
        {
            _S1523 = false;
        }
        bool _S1524;
        if(_S1523)
        {
            bool _S1525 = ((&hit_4)->instance_index) != (_S1390.instance_index);
            if(_S1525)
            {
                _S1524 = true;
            }
            else
            {
                _S1524 = ((&hit_4)->triangle_index) != (_S1390.triangle_index);
            }
        }
        else
        {
            _S1524 = false;
        }
        if(_S1524)
        {
            return _S1374;
        }
        FKMedium _S1526 = Medium_x24init_0(_S1373, _S1373, 0.0f);
        BSDFMaterial _S1527 = Material_x24init_0(_S1373, _S1373, 0.0f, 0.0f, 0.0f, 0.0f, _S1373, throughput_3, 1.0f, _S1373, _S1373, 0.5f, 0.0f, 0.0f, _S1373, 0.0f, _S1373, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, throughput_3, _S1373);
        FKMedium _S1528 = _S1526;
        FKSurface _S1529 = Surface_x24init_0(_S1373, _S1373, 0.0f, &_S1527, false, 0U, 1.0f, false, &_S1528, 4294967295U, _S1373);
        bool _S1530 = !_S1522;
        bool scatter_2;
        bool is_inside_7;
        float geometry_density_2;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S1530)
        {
            uint _S1531 = noiseAddress(_S1401, b_7);
            uint _S1532 = arrivalLobe_0(b_7, (&prev_0)->lobe);
            FKSurface _S1533 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1531), (width_3), (layer_0), (b_7), (_S1532), ((&ray_2)->unit_direction)));
            bool _S1534 = !passes_0;
            FKSurface _S1535 = _S1533;
            FKSurface _S1536 = emitting_0(&_S1535, _S1534);
            uint _S1537 = noiseAddress(_S1401, b_7);
            Random _S1538 = draw(_S1537, 9U);
            FKSurface _S1539 = _S1536;
            FKSurface _S1540 = uncovered_0(&_S1539, _S1538.value);
            float _S1541 = facingSign(_S1540.material.transmission, _S1540.geometry_n, (&ray_2)->unit_direction);
            bool _S1542 = _S1541 < 0.0f;
            bool _S1543 = (_S1540.material.transmission) > 0.0f;
            if(_S1543)
            {
                bool _S1544 = arrivesBehind_0((&ray_2)->unit_direction, _S1540.geometry_n);
                scatter_2 = _S1544;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1545 = _S1540;
            FKSurface _S1546 = facingRay_0(&_S1545, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1547 = arrivesBehind_0((&ray_2)->unit_direction, _S1546.geometry_n);
                is_inside_7 = _S1547;
            }
            else
            {
                is_inside_7 = scatter_2;
            }
            if(is_inside_7)
            {
                float _S1548 = (&hit_4)->distance;
                float _S1549 = upsample(_S1546.material.absorption, wavelength_8);
                float3  _S1550 = make_float3 (_S1549);
                bool _S1551 = wavelength_8 > 0.0f;
                float3  _S1552 = _slang_select(_S1551, _S1550,_S1546.material.absorption);
                float3  _S1553 = beerLambert(_S1548, _S1552);
                float3  _S1554 = throughput_2 * _S1553;
                throughput_5 = _S1554;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1555 = !_S1546.skip;
            float geometry_density_3 = geometryDensity(_S1546.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1556 = b_7 == _S1521;
            if(_S1556)
            {
                float _S1557 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1557;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1558 = geometry_density_2;
            scatter_2 = _S1555;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1558;
            surface_12 = _S1546;
            turned_1 = _S1542;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_12 = _S1529;
            throughput_5 = throughput_2;
            is_inside_7 = is_inside_6;
        }
        bool _S1559 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1560 = surface_12;
        float _S1561 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        bool _S1562 = (fcptDispersionUsed());
        bool _S1563;
        if(_S1562)
        {
            _S1563 = wavelength_8 == 0.0f;
        }
        else
        {
            _S1563 = false;
        }
        bool _S1564;
        if(_S1563)
        {
            _S1564 = scatter_2;
        }
        else
        {
            _S1564 = false;
        }
        bool _S1565;
        if(_S1564)
        {
            bool _S1566 = dispersive(surface_12.material);
            _S1565 = _S1566;
        }
        else
        {
            _S1565 = false;
        }
        float3  throughput_6;
        if(_S1565)
        {
            uint _S1567 = stream(_S1401, 512U);
            Random _S1568 = pcg(_S1567);
            uint _S1569 = extractBits_0(_S1375, 25U, 7U);
            float _S1570 = (float(_S1569) + _S1568.value) / 128.0f;
            uint _S1571 = extractBits_0(_S1375, 24U, 1U);
            bool _S1572 = _S1571 == 1U;
            float _S1573 = _slang_select(_S1572, _S1570,_S1568.value);
            float2  _S1574 = sampleWavelength(_S1573);
            float wavelength_9 = _S1574.x;
            float3  _S1575 = wavelengthWeights(wavelength_9);
            float3  _S1576 = _S1575 / make_float3 (_S1574.y);
            float _S1577 = upsample(throughput_5, wavelength_9);
            float3  _S1578 = make_float3 (_S1577);
            float _S1579 = upsample(scatter_in_0, wavelength_9);
            float3  _S1580 = make_float3 (_S1579);
            scatter_in_0 = _S1580;
            float _S1581 = upsample(extinction_in_0, wavelength_9);
            float3  _S1582 = make_float3 (_S1581);
            extinction_in_0 = _S1582;
            wavelength_8 = wavelength_9;
            throughput_6 = _S1578;
            spectral_weight_0 = _S1576;
        }
        else
        {
            throughput_6 = throughput_5;
        }
        BSDFMaterial _S1583 = pathMaterial(surface_12.material, wavelength_8);
        float2  _S1584 = wavelengthEta(_S1583, _S1561, wavelength_8);
        bool _S1585;
        if(scatter_2)
        {
            bool _S1586 = neeDecision(_S1583, _S1561, _S1584.x, _S1584.y);
            _S1585 = _S1586;
        }
        else
        {
            _S1585 = false;
        }
        bool _S1587;
        if(passes_0)
        {
            _S1587 = true;
        }
        else
        {
            _S1587 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1587)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1585;
        }
        bool _S1588 = (fcptHairUsed());
        bool _S1589;
        if(_S1588)
        {
            float3  _S1590 = surface_12.hair;
            _S1589 = (dot_0(_S1590, _S1590)) > 0.0f;
        }
        else
        {
            _S1589 = false;
        }
        bool _S1591;
        if(_S1589)
        {
            _S1591 = true;
        }
        else
        {
            BSDFMaterial _S1592 = _S1583;
            bool _S1593 = isTranslucent_0(&_S1592);
            _S1591 = _S1593;
        }
        bool _S1594;
        if(_S1591)
        {
            _S1594 = true;
        }
        else
        {
            bool _S1595 = (_S1583.transmission) > 0.0f;
            if(_S1595)
            {
                uint _S1596 = (fcptLayers((hit_4)));
                _S1594 = _S1596 == 1U;
            }
            else
            {
                _S1594 = false;
            }
        }
        float3  emission_0;
        if(_S1522)
        {
            float3  _S1597 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1597;
        }
        else
        {
            emission_0 = _S1583.emissive;
        }
        bool _S1598 = !replay_2;
        bool _S1599;
        if(_S1598)
        {
            _S1599 = true;
        }
        else
        {
            _S1599 = b_7 >= _S1389;
        }
        bool _S1600;
        if(_S1599)
        {
            float _S1601 = rgb_to_greyscale(emission_0);
            _S1600 = _S1601 > 0.0f;
        }
        else
        {
            _S1600 = false;
        }
        float3  emission_1;
        if(_S1600)
        {
            NEEVertex _S1602 = nee_vertex_0;
            FKHit _S1603 = hit_4;
            float _S1604 = emissionWeight_0(&_S1602, &_S1603, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1604);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1605;
        if(replay_2)
        {
            _S1605 = _S1378 == 1U;
        }
        else
        {
            _S1605 = false;
        }
        bool _S1606;
        if(_S1605)
        {
            _S1606 = b_7 > _S1377;
        }
        else
        {
            _S1606 = false;
        }
        bool _S1607;
        if(_S1606)
        {
            _S1607 = b_7 == _S1376;
        }
        else
        {
            _S1607 = false;
        }
        bool _S1608;
        if(_S1607)
        {
            bool _S1609 = _S1379 == 1U;
            if(_S1609)
            {
                _S1608 = true;
            }
            else
            {
                _S1608 = _S1379 == 2U;
            }
        }
        else
        {
            _S1608 = false;
        }
        if(_S1608)
        {
            bool _S1610 = _S1522 != (_S1379 == 2U);
            if(_S1610)
            {
                return _S1374;
            }
            float3  _S1611 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_8);
            return Shift_x24init_0(_S1611 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1612 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1613 = _S1612 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1614 = insertBits_0(_S1403, b_7, 5U, 5U);
        uint _S1615 = insertBits_0(_S1614, 1U, 10U, 2U);
        uint _S1616 = insertBits_0(_S1615, (&prev_0)->lobe, 15U, 3U);
        bool _S1617 = (&prev_0)->inside;
        uint _S1618 = _slang_select(_S1617, 1U,0U);
        uint _S1619 = insertBits_0(_S1616, _S1618, 22U, 1U);
        (&here_0)->path = _S1619;
        uint _S1620 = (&here_0)->path;
        bool _S1621 = wavelength_8 > 0.0f;
        uint _S1622 = _slang_select(_S1621, 1U,0U);
        uint _S1623 = insertBits_0(_S1620, _S1622, 23U, 1U);
        (&here_0)->path = _S1623;
        float _S1624 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1624;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1625;
        if(replay_2)
        {
            _S1625 = _S1378 == 1U;
        }
        else
        {
            _S1625 = false;
        }
        bool _S1626;
        if(_S1625)
        {
            _S1626 = b_7 == _S1377;
        }
        else
        {
            _S1626 = false;
        }
        bool _S1627 = b_7 == _S1389;
        bool _S1628;
        if(_S1627)
        {
            bool _S1629 = !scatter_2;
            if(_S1629)
            {
                _S1628 = true;
            }
            else
            {
                bool _S1630 = _S1378 != 1U;
                if(_S1630)
                {
                    _S1628 = _S1378 != 3U;
                }
                else
                {
                    _S1628 = false;
                }
            }
        }
        else
        {
            _S1628 = false;
        }
        bool _S1631;
        if(_S1628)
        {
            _S1631 = _S1378 == 2U;
        }
        else
        {
            _S1631 = false;
        }
        bool _S1632;
        if(_S1631)
        {
            _S1632 = !_S1559;
        }
        else
        {
            _S1632 = false;
        }
        bool _S1633;
        if(_S1632)
        {
            _S1633 = _S1379 != 4U;
        }
        else
        {
            _S1633 = false;
        }
        bool _S1634 = _S1377 == _S1376;
        bool _S1635;
        if(_S1634)
        {
            _S1635 = _S1379 == 0U;
        }
        else
        {
            _S1635 = false;
        }
        bool _S1636;
        if(_S1635)
        {
            _S1636 = ((&hit_4)->instance_index) == (_S1390.instance_index);
        }
        else
        {
            _S1636 = false;
        }
        bool _S1637;
        if(_S1636)
        {
            _S1637 = ((&hit_4)->triangle_index) == (_S1390.triangle_index);
        }
        else
        {
            _S1637 = false;
        }
        bool _S1638;
        if(_S1637)
        {
            _S1638 = _S1559;
        }
        else
        {
            _S1638 = false;
        }
        bool _S1639 = _slang_select(_S1626, _S1638,_S1633);
        bool _S1640;
        if(nee_0)
        {
            _S1640 = _slang_select(replay_2, _S1639,scatter_2);
        }
        else
        {
            _S1640 = false;
        }
        TreeSample _S1641 = TreeSample_x24init_0(_S1373, _S1373, 0.0f, 0U);
        uint2  _S1642 = make_uint2 (0U);
        float2  _S1643 = make_float2 (0.0f);
        FKHit _S1644 = Hit_x24init_0(_S1643, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1645 = _S1644;
        ShadowContext _S1646 = ShadowContext_x24init_0(_S1373, _S1373, _S1642, _S1373, 0U, 0U, false, 0.0f, 0.0f, &_S1645, false);
        bool _S1647;
        if(nee_0)
        {
            _S1647 = _S1599;
        }
        else
        {
            _S1647 = false;
        }
        ShadowContext context_5;
        if(_S1647)
        {
            uint _S1648 = arrivalLobe_0(b_7, (&prev_0)->lobe);
            FKMedium _S1649 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1650 = surface_12;
            FKHit _S1651 = hit_4;
            FKMedium _S1652 = _S1649;
            ShadowContext _S1653 = shadowContext_0(&_S1650, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_7, _S1648, (&hit_4)->distance, width_3, &_S1651, _S1589, &_S1652);
            context_5 = _S1653;
        }
        else
        {
            context_5 = _S1646;
        }
        float3  throughput_7;
        float3  lit_0;
        if(_S1640)
        {
            float3  _S1654 = (&ray_2)->origin;
            if(_S1589)
            {
                throughput_7 = _S1373;
            }
            else
            {
                throughput_7 = _S1560.smooth_n;
            }
            FKSurface _S1655 = surface_12;
            uint _S1656 = noiseAddress(_S1401, b_7);
            ShadowContext _S1657 = context_5;
            TreeSample _S1658 = sampleLightTree_0(_S1654, throughput_7, surface_12.geometry_n, surface_12.geometry_offset, _S1594, _S1656, &_S1657);
            bool _S1659 = any_1((_S1658.radiance) != _S1373);
            if(_S1659)
            {
                if(_S1589)
                {
                    uint _S1660 = (fcptMaxBounces());
                    bool _S1661 = b_7 < _S1660;
                    FKSurface _S1662 = surface_12;
                    TreeSample _S1663 = _S1658;
                    float3  _S1664 = hairLight_0(&_S1662, (&ray_2)->unit_direction, &_S1663, _S1661);
                    lit_0 = _S1664;
                }
                else
                {
                    float _S1665 = _S1584.x;
                    float _S1666 = _S1584.y;
                    uint _S1667 = (fcptMaxBounces());
                    bool _S1668 = b_7 < _S1667;
                    TreeSample _S1669 = _S1658;
                    BSDFMaterial _S1670 = _S1583;
                    float3  _S1671 = lightBSDF_0((&ray_2)->unit_direction, &_S1669, _S1560.smooth_n, _S1655.geometry_n, &_S1670, _S1665, _S1666, _S1668, surface_12.random_state);
                    lit_0 = _S1671;
                }
            }
            else
            {
                lit_0 = _S1373;
            }
            light_3 = _S1658;
        }
        else
        {
            light_3 = _S1641;
            lit_0 = _S1373;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1672;
        bool _S1673;
        float density_4;
        if(_S1626)
        {
            bool _S1674 = !_S1559;
            if(_S1674)
            {
                return _S1374;
            }
            uint _S1675 = extractBits_0(_S1375, 23U, 1U);
            bool _S1676 = _S1621 != (_S1675 == 1U);
            if(_S1676)
            {
                return _S1374;
            }
            float3  throughput_8 = throughput_6 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1634)
            {
                viewed_1 = _S1379 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                float3  _S1677 = pathColor(throughput_8 * emission_1, spectral_weight_0, wavelength_8);
                return Shift_x24init_0(_S1677 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1634)
            {
                refracted_4 = _S1379 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1678 = !nee_0;
                if(_S1678)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1679 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1679 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1374;
                }
                float3  _S1680 = pathColor(throughput_8 * lit_0, spectral_weight_0, wavelength_8);
                return Shift_x24init_0(_S1680 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1634)
            {
                wrong_side_0 = _S1379 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1681 = !nee_0;
                if(_S1681)
                {
                    return _S1374;
                }
                bool _S1682 = (fcptWorldReadsPath());
                if(_S1682)
                {
                    float3  _S1683 = r_8->dir;
                    float _S1684 = environmentPdf_0(r_8->dir);
                    FKSurface _S1685 = surface_12;
                    BSDFMaterial _S1686 = _S1583;
                    FixedArray<float3 , 6>  terms_4;
                    FixedArray<float, 6>  pdfs_6;
                    float3  _S1687 = skyLobes_0((&ray_2)->unit_direction, _S1683, &_S1685, &_S1686, _S1584, is_inside_7, _S1684, surface_12.random_state, &terms_4, &pdfs_6);
                    uint _S1688 = b_7 + 1U;
                    FixedArray<float3 , 6>  _S1689 = terms_4;
                    FixedArray<float, 6>  _S1690 = pdfs_6;
                    float3  _S1691 = skyColor_0(_S1683, &_S1689, &_S1690, _S1688);
                    float3  _S1692 = pathColor(throughput_8 * (_S1691 * r_8->radiance), spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S1692 / make_float3 (r_8->jac), density_5 / r_8->jac);
                }
                float _S1693 = environmentPdf_0(r_8->dir);
                float3  _S1694 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_12, _S1583, _S1584, is_inside_7, _S1693, surface_12.random_state);
                float3  _S1695 = pathColor(throughput_8 * _S1694 * r_8->radiance, spectral_weight_0, wavelength_8);
                return Shift_x24init_0(_S1695 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1696 = extractBits_0(_S1375, 21U, 1U);
            bool _S1697 = nee_0 != (_S1696 == 1U);
            if(_S1697)
            {
                return _S1374;
            }
            throughput_7 = throughput_8;
            density_4 = density_5;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1627;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1698 = !scatter_2;
                if(_S1698)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1699 = _S1378 != 1U;
                    if(_S1699)
                    {
                        refracted_4 = _S1378 != 3U;
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
                bool _S1700 = _S1378 == 2U;
                if(_S1700)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1559;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1379 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1589)
                    {
                        return _S1374;
                    }
                    uint _S1701 = noiseAddress(_S1401, b_7);
                    FKRay _S1702 = ray_2;
                    FKSurface _S1703 = surface_12;
                    ShadowContext _S1704 = context_5;
                    SkySample _S1705 = sampleSky_0(&_S1702, &_S1703, wavelength_8, _S1584, is_inside_7, _S1701, surface_12.random_state, &_S1704);
                    float3  _S1706 = pathColor(throughput_6 * _S1705.color, spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S1706, 1.0f);
                }
                if(_S1700)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1559;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1707 = rgb_to_greyscale(light_3.radiance);
                    bool _S1708 = !(_S1707 > 0.0f);
                    if(_S1708)
                    {
                        return _S1374;
                    }
                    float3  _S1709 = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S1709, 1.0f);
                }
                if(_S1388)
                {
                    passes_0 = _S1379 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1522;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1710 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S1710, 1.0f);
                }
                if(_S1388)
                {
                    passes_0 = _S1379 == 1U;
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
                    passes_0 = !_S1559;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1711 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S1711, 1.0f);
                }
                return _S1374;
            }
            else
            {
                if(_S1598)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1712 = b_7 > 0U;
                    if(_S1712)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1613)
                        {
                            float3  _S1713 = safeDivide(throughput_6 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1713;
                        }
                        else
                        {
                            if(_S1559)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1714 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_8);
                        Reservoir _S1715 = withEnd(candidate_5, 1U, b_7, _S1714);
                        offer(sel_7, _S1715, _S1714 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1716 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_8);
                        float3  _S1717 = sel_7->glow + _S1716;
                        sel_7->glow = _S1717;
                    }
                    if(nee_0)
                    {
                        float3  _S1718 = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_8);
                        Reservoir candidate_6 = chain_0;
                        if(_S1613)
                        {
                            float3  _S1719 = safeDivide(_S1718, chain_throughput_0);
                            (&candidate_6)->radiance = _S1719;
                        }
                        else
                        {
                            if(_S1559)
                            {
                                candidate_6 = here_0;
                                uint _S1720 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1720;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1721 = insertBits_0(_S1403, b_7 + 1U, 5U, 5U);
                                uint _S1722 = insertBits_0(_S1721, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1722;
                            }
                        }
                        Reservoir _S1723 = withEnd(candidate_6, 0U, b_7, _S1718);
                        offer(sel_7, _S1723, _S1718 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1589)
                        {
                            _S1672 = false;
                        }
                        else
                        {
                            bool _S1724 = environmentMapped_0();
                            _S1672 = _S1724;
                        }
                    }
                    else
                    {
                        _S1672 = false;
                    }
                    if(_S1672)
                    {
                        uint _S1725 = (fcptMaxBounces());
                        _S1673 = b_7 < _S1725;
                    }
                    else
                    {
                        _S1673 = false;
                    }
                    if(_S1673)
                    {
                        uint _S1726 = noiseAddress(_S1401, b_7);
                        FKRay _S1727 = ray_2;
                        FKSurface _S1728 = surface_12;
                        ShadowContext _S1729 = context_5;
                        SkySample _S1730 = sampleSky_0(&_S1727, &_S1728, wavelength_8, _S1584, is_inside_7, _S1726, surface_12.random_state, &_S1729);
                        float3  _S1731 = pathColor(throughput_6 * _S1730.color, spectral_weight_0, wavelength_8);
                        Reservoir candidate_7 = chain_0;
                        if(_S1613)
                        {
                            float3  _S1732 = safeDivide(_S1731, chain_throughput_0);
                            (&candidate_7)->radiance = _S1732;
                        }
                        else
                        {
                            if(_S1559)
                            {
                                candidate_7 = here_0;
                                uint _S1733 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1733;
                                (&candidate_7)->dir = _S1730.dir;
                                (&candidate_7)->radiance = _S1730.radiance;
                            }
                            else
                            {
                                uint _S1734 = insertBits_0(_S1403, b_7 + 1U, 5U, 5U);
                                uint _S1735 = insertBits_0(_S1734, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1735;
                            }
                        }
                        Reservoir _S1736 = withEnd(candidate_7, 4U, b_7, _S1731);
                        offer(sel_7, _S1736, _S1731 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_7 = throughput_6;
            density_4 = density_2;
        }
        bool _S1737;
        bool _S1738;
        bool _S1739;
        bool straight_0;
        bool _S1740;
        bool _S1741;
        bool _S1742;
        bool _S1743;
        bool _S1744;
        bool _S1745;
        bool _S1746;
        bool _S1747;
        bool _S1748;
        bool _S1749;
        bool _S1750;
        bool _S1751;
        float density_6;
        float sky_pdf_2;
        float spread_5;
        uint b_10;
        float3  throughput_9;
        float3  throughput_10;
        float3  throughput_11;
        if(scatter_2)
        {
            if(replay_2)
            {
                viewed_1 = _S1627;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1752 = extractBits_0(_S1375, 15U, 3U);
            uint _S1753 = extractBits_0(_S1375, 18U, 3U);
            uint _S1754 = _slang_select(_S1626, _S1753,_S1752);
            float3  _S1755 = r_8->dir;
            bool refracted_5 = _S1754 == 1U;
            SampleBSDF _S1756 = SampleBSDF_x24init_0(_S1373, _S1373, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1756;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1757 = extractBits_0(_S1375, 22U, 1U);
                bool _S1758 = is_inside_7 != (_S1757 == 1U);
                if(_S1758)
                {
                    return _S1374;
                }
                bool _S1759 = _S1378 == 1U;
                if(_S1759)
                {
                    float3  _S1760 = (fcptHitPosition((_S1390)));
                    throughput_9 = _S1760;
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
                    BSDFMaterial _S1761 = _S1583;
                    bool _S1762 = isTranslucent_0(&_S1761);
                    if(_S1762)
                    {
                        refracted_4 = _S1754 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1763 = throughput_9 - (&ray_2)->origin;
                        float3  _S1764 = _slang_select(_S1759, _S1763,_S1755);
                        wrong_side_0 = (dot_0(_S1560.smooth_n, _S1764) * _S1561) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1759)
                {
                    float3  _S1765 = (&ray_2)->origin;
                    FKSurface _S1766 = surface_12;
                    float3  _S1767 = - _S1560.smooth_n;
                    bool _S1768 = is_inside_7 != refracted_4;
                    float3  _S1769 = _slang_select(_S1768, _S1767,_S1560.smooth_n);
                    float3  _S1770 = throughput_9 - (_S1765 + make_float3 (_S1766.geometry_offset) * _S1769);
                    float3  _S1771 = ((((_S1770)) * make_float3(rnorm3df(((_S1770)).x, ((_S1770)).y, ((_S1770)).z))));
                    reconnection_1 = _S1771;
                }
                else
                {
                    reconnection_1 = _S1755;
                }
                if(_S1589)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1772 = wrongSide_0(is_inside_7, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1772;
                }
                if(wrong_side_0)
                {
                    return _S1374;
                }
                float3  _S1773 = throughput_9;
                throughput_9 = reconnection_1;
                b_10 = _S1754;
                wrong_side_0 = false;
                reconnection_1 = _S1773;
            }
            else
            {
                bool _S1774 = !_S1626;
                if(_S1774)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1775;
                    if(_S1589)
                    {
                        SampleBSDF _S1776 = (fcptSampleHair((surface_12.hair), (_S1583.albedo), (_S1583.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1775 = _S1776;
                    }
                    else
                    {
                        SampleBSDF _S1777 = sampleBSDF((&ray_2)->unit_direction, _S1560.smooth_n, _S1583, _S1584.x, _S1584.y, surface_12.random_state, _S1643);
                        _S1775 = _S1777;
                    }
                    bsdf_sampled_0 = _S1775;
                    if(_S1589)
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
                            return _S1374;
                        }
                        break;
                    }
                    if(_S1589)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1778 = wrongSide_0(is_inside_7, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1778;
                    }
                    if(wrong_side_0)
                    {
                        _S1672 = (_S1583.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1672 = false;
                    }
                    if(_S1672)
                    {
                        SampleBSDF _S1779 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1583, _S1584.x, _S1584.y, (&bsdf_sampled_0)->random_state, _S1643);
                        (&bsdf_sampled_0)->unit_direction = _S1779.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1779.refracted;
                        (&bsdf_sampled_0)->throughput = _S1779.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1780 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1780;
                        }
                    }
                    uint _S1781 = (&bsdf_sampled_0)->lobe;
                    float3  _S1782 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1783 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1784 = (&bsdf_sampled_0)->pdf;
                    float _S1785 = _slang_select(wrong_side_0, 0.0f,_S1784);
                    (&lobe_5)->pdf = _S1785;
                    throughput_9 = _S1782;
                    b_10 = _S1781;
                    refracted_4 = _S1783;
                }
                else
                {
                    throughput_9 = _S1755;
                    b_10 = _S1754;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1672 = true;
            }
            else
            {
                _S1672 = _S1626;
            }
            float3  chain_throughput_1;
            if(_S1672)
            {
                if(_S1589)
                {
                    SampleBSDF _S1786 = (fcptConnectHair((surface_12.hair), (_S1583.albedo), (_S1583.specular_tint), ((&ray_2)->unit_direction), (throughput_9)));
                    lobe_5 = _S1786;
                }
                else
                {
                    float3  _S1787 = (&ray_2)->unit_direction;
                    float3  _S1788 = negate_0(_S1787);
                    float _S1789 = sign_0(_S1561);
                    float3  _S1790 = _S1560.smooth_n * make_float3 (_S1789);
                    float _S1791 = dot_0(_S1790, throughput_9);
                    float _S1792 = _S1583.roughness;
                    float _S1793 = _S1792 * _S1792;
                    AnisotropicFrame _S1794 = anisotropicFrame(_S1583, _S1790);
                    SheenProfile _S1795 = sheenProfile(_S1788, _S1790, _S1583);
                    CoatFrame _S1796 = coatFrame(_S1583, _S1790);
                    float3  _S1797 = coatSeries(_S1796, _S1583);
                    float3  _S1798 = reflectedHalf(_S1787, throughput_9);
                    bool _S1799 = b_10 == 1U;
                    if(_S1799)
                    {
                        float3  _S1800 = refractedHalf(_S1787, throughput_9, _S1560.smooth_n, _S1584.x, _S1584.y);
                        throughput_10 = _S1800;
                    }
                    else
                    {
                        throughput_10 = _S1798;
                    }
                    FKSurface _S1801 = surface_12;
                    float3  _S1802 = coatHalf(_S1788, _S1796, surface_12.random_state);
                    bool _S1803 = b_10 == 5U;
                    float3  _S1804 = _slang_select(_S1803, throughput_10,_S1802);
                    bool _S1805 = b_10 == 0U;
                    if(_S1805)
                    {
                        _S1673 = true;
                    }
                    else
                    {
                        _S1673 = b_10 == 6U;
                    }
                    if(_S1673)
                    {
                        _S1737 = true;
                    }
                    else
                    {
                        _S1737 = _S1803;
                    }
                    if(_S1737)
                    {
                        float3  _S1806 = sampledHalf(_S1788, _S1790, _S1793, _S1794, _S1801.random_state);
                        throughput_11 = _S1806;
                    }
                    else
                    {
                        throughput_11 = throughput_10;
                    }
                    float _S1807 = _S1584.x;
                    float _S1808 = _S1584.y;
                    Weights _S1809 = lobeWeights(_S1787, _S1788, _S1790, throughput_11, _S1804, _S1794, _S1795, _S1796, _S1797, _S1583, _S1807, _S1808);
                    float _S1810 = (F32_abs((_S1561)));
                    float _S1811 = vndfPDF(_S1788, throughput_11, _S1790, _S1810, _S1793, _S1794, _S1809.v_dot_h);
                    switch(b_10)
                    {
                    case 0U:
                        {
                            float _S1812 = diffusePDF(_S1791, _S1810, _S1583, _S1809);
                            float3  _S1813 = diffuseBSDF(throughput_9, _S1790, _S1583, _S1809);
                            density_6 = _S1812;
                            chain_throughput_1 = _S1813;
                            break;
                        }
                    case 1U:
                        {
                            float _S1814 = refractPDF(dot_0(throughput_9, throughput_11), _S1811, _S1809, _S1807, _S1808);
                            float3  _S1815 = refractBSDF(throughput_9, _S1790, _S1793, _S1794, _S1583, _S1809);
                            density_6 = _S1814;
                            chain_throughput_1 = _S1815;
                            break;
                        }
                    case 4U:
                        {
                            float _S1816 = sheenVelvetPDF(_S1791, _S1810, _S1809);
                            float3  _S1817 = sheenVelvetBSDF(throughput_9, _S1788, _S1790, _S1583, _S1809);
                            density_6 = _S1816;
                            chain_throughput_1 = _S1817;
                            break;
                        }
                    case 5U:
                        {
                            float _S1818 = coatPDF(_S1788, _S1804, _S1796, _S1809);
                            float3  _S1819 = coatBSDF(_S1809);
                            density_6 = _S1818;
                            chain_throughput_1 = _S1819;
                            break;
                        }
                    case 6U:
                        {
                            ToonProfile _S1820 = toonProfile(_S1788, _S1790, _S1583);
                            float _S1821 = toonPDF(throughput_9, _S1790, _S1820, _S1809);
                            float3  _S1822 = toonBSDF(throughput_9, _S1790, _S1820, _S1809);
                            density_6 = _S1821;
                            chain_throughput_1 = _S1822;
                            break;
                        }
                    default:
                        {
                            float _S1823 = reflectPDF(_S1811, _S1809);
                            float3  _S1824 = reflectBSDF(throughput_9, _S1790, _S1793, _S1794, _S1809);
                            density_6 = _S1823;
                            chain_throughput_1 = _S1824;
                            break;
                        }
                    }
                    bool _S1825 = density_6 > 0.0f;
                    if(_S1825)
                    {
                        SampleBSDF _S1826 = SampleBSDF_x24init_0(throughput_9, chain_throughput_1, _S1801.random_state, _S1799, b_10, density_6);
                        lobe_5 = _S1826;
                    }
                }
            }
            bool _S1827 = b_10 == 0U;
            if(_S1827)
            {
                _S1673 = true;
            }
            else
            {
                _S1673 = b_10 == 4U;
            }
            if(_S1673)
            {
                _S1737 = true;
            }
            else
            {
                _S1737 = b_10 == 6U;
            }
            bool _S1828 = b_10 == 5U;
            float _S1829 = _slang_select(_S1828, _S1583.coat_roughness,_S1583.roughness);
            if(_S1589)
            {
                _S1738 = false;
            }
            else
            {
                bool _S1830 = !_S1737;
                if(_S1830)
                {
                    bool _S1831 = _S1829 == 0.0f;
                    if(_S1831)
                    {
                        _S1738 = true;
                    }
                    else
                    {
                        bool _S1832 = b_10 == 1U;
                        if(_S1832)
                        {
                            _S1738 = (_S1584.x) == (_S1584.y);
                        }
                        else
                        {
                            _S1738 = false;
                        }
                    }
                }
                else
                {
                    _S1738 = false;
                }
            }
            bool _S1833 = !_S1589;
            if(_S1833)
            {
                _S1739 = b_10 == 1U;
            }
            else
            {
                _S1739 = false;
            }
            if(_S1739)
            {
                straight_0 = (_S1583.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1740 = _S1833;
            }
            else
            {
                _S1740 = false;
            }
            if(_S1740)
            {
                _S1741 = b_10 == 1U;
            }
            else
            {
                _S1741 = false;
            }
            if(_S1741)
            {
                _S1742 = (_S1584.x) == (_S1584.y);
            }
            else
            {
                _S1742 = false;
            }
            BSDFMaterial _S1834 = _S1583;
            bool _S1835 = isTranslucent_0(&_S1834);
            if(_S1835)
            {
                _S1743 = _S1827;
            }
            else
            {
                _S1743 = false;
            }
            if(_S1743)
            {
                _S1744 = (dot_0(throughput_9, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1744 = false;
            }
            if(nee_0)
            {
                _S1745 = !_S1738;
            }
            else
            {
                _S1745 = false;
            }
            if(_S1745)
            {
                _S1746 = !wrong_side_0;
            }
            else
            {
                _S1746 = false;
            }
            if(_S1746)
            {
                float _S1836 = (&lobe_5)->pdf;
                float3  _S1837 = (&ray_2)->origin;
                float3  _S1838 = _slang_select(_S1594, _S1373,_S1560.smooth_n);
                float3  _S1839 = (&ray_2)->origin;
                FKSurface _S1840 = surface_12;
                float3  _S1841 = - _S1560.smooth_n;
                float3  _S1842 = _slang_select(_S1744, _S1841,_S1560.smooth_n);
                NEEVertex _S1843 = NEEVertex_x24init_0(false, _S1836, _S1837, _S1838, _S1839 + make_float3 (_S1840.geometry_offset) * _S1842);
                nee_vertex_0 = _S1843;
            }
            else
            {
                if(_S1589)
                {
                    _S1747 = true;
                }
                else
                {
                    bool _S1844 = b_10 != 1U;
                    if(_S1844)
                    {
                        _S1747 = true;
                    }
                    else
                    {
                        _S1747 = (_S1584.x) != (_S1584.y);
                    }
                }
                if(_S1747)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1845 = withinInverseFootprint((&lobe_5)->pdf, _S1737, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1846 = roughLobe((&lobe_5)->pdf, _S1737, _S1829);
            if(_S1626)
            {
                bool _S1847 = !_S1845;
                if(_S1847)
                {
                    return _S1374;
                }
                bool _S1848 = _S1379 != 1U;
                if(_S1848)
                {
                    _S1747 = _S1379 != 2U;
                }
                else
                {
                    _S1747 = false;
                }
                if(_S1747)
                {
                    float _S1849 = (&lobe_5)->pdf;
                    float _S1850 = _slang_select(nee_0, _S1849,0.0f);
                    float _S1851 = escapeWeight_0(_S1850, _S1755);
                    if(_S1634)
                    {
                        passes_0 = _S1385;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1852 = _slang_select(passes_0, _S1851,1.0f);
                    return Shift_x24init_0(throughput_7 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1852) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1853 = throughput_7 * make_float3 ((&lobe_5)->pdf);
                float _S1854 = density_4 * (&lobe_5)->pdf;
                throughput_10 = _S1853;
                density_6 = _S1854;
            }
            else
            {
                throughput_10 = throughput_7;
                density_6 = density_4;
            }
            uint _S1855 = (fcptLayers((hit_4)));
            bool _S1856 = b_10 == 1U;
            bool _S1857 = passesLayer_0(_S1855, _S1856, passes_0);
            if(viewed_1)
            {
                _S1747 = _S1857;
            }
            else
            {
                _S1747 = false;
            }
            if(_S1747)
            {
                return _S1374;
            }
            if(replay_2)
            {
                _S1748 = b_7 <= _S1389;
            }
            else
            {
                _S1748 = false;
            }
            if(_S1748)
            {
                _S1749 = _S1559;
            }
            else
            {
                _S1749 = false;
            }
            if(_S1749)
            {
                _S1750 = _S1845;
            }
            else
            {
                _S1750 = false;
            }
            if(_S1750)
            {
                _S1751 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1751 = !_S1846;
                }
                else
                {
                    _S1751 = false;
                }
            }
            if(_S1751)
            {
                return _S1374;
            }
            if(viewed_1)
            {
                float3  _S1858 = throughput_10 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1859 = (&lobe_5)->pdf;
                throughput_11 = _S1858;
                sky_pdf_2 = _S1859;
            }
            else
            {
                float3  _S1860 = throughput_10 * max_0((&lobe_5)->throughput, _S1373);
                throughput_11 = _S1860;
                sky_pdf_2 = density_6;
            }
            bool _S1861;
            if(_S1598)
            {
                _S1861 = !_S1613;
            }
            else
            {
                _S1861 = false;
            }
            bool _S1862;
            if(_S1861)
            {
                _S1862 = _S1559;
            }
            else
            {
                _S1862 = false;
            }
            bool _S1863;
            if(_S1862)
            {
                _S1863 = _S1845;
            }
            else
            {
                _S1863 = false;
            }
            if(_S1863)
            {
                chain_0 = here_0;
                uint _S1864 = insertBits_0((&chain_0)->path, b_10, 18U, 3U);
                uint _S1865 = _slang_select(nee_0, 1U,0U);
                uint _S1866 = insertBits_0(_S1864, _S1865, 21U, 1U);
                (&chain_0)->path = _S1866;
                float _S1867 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1867;
                (&chain_0)->dir = throughput_9;
                chain_throughput_1 = throughput_11;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1868 = surface_12;
            Vertex _S1869 = Vertex_x24init_0(_S1846, b_10, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_9)))), is_inside_7);
            prev_0 = _S1869;
            float _S1870 = (&lobe_5)->pdf;
            bool _S1871;
            if(_S1856)
            {
                _S1871 = (_S1584.x) == (_S1584.y);
            }
            else
            {
                _S1871 = false;
            }
            float sky_pdf_3 = _slang_select(_S1871, sky_pdf_0,_S1870);
            float _S1872 = _slang_select(_S1589, 0.0f,sky_pdf_3);
            float _S1873 = widened_0(spread_2, (&lobe_5)->pdf, _S1738);
            bool _S1874;
            if(refracted_4)
            {
                _S1874 = !_S1744;
            }
            else
            {
                _S1874 = false;
            }
            bool is_inside_8;
            if(_S1874)
            {
                bool _S1875 = !is_inside_7;
                is_inside_8 = _S1875;
            }
            else
            {
                is_inside_8 = is_inside_7;
            }
            FKSurface _S1876 = surface_12;
            bool _S1877 = boundsVolume_0(&_S1876);
            bool _S1878;
            if(_S1877)
            {
                _S1878 = !_S1857;
            }
            else
            {
                _S1878 = false;
            }
            if(_S1878)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1879 = - _S1868.geometry_n;
                float3  _S1880 = _slang_select(turned_1, _S1879,_S1868.geometry_n);
                (&faced_2)->geometry_n = _S1880;
                FKMedium _S1881 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1882 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1883 = faced_2;
                FKMedium _S1884 = _S1881;
                FKMedium _S1885 = _S1882;
                MediumSides _S1886 = mediumSides_0(&_S1883, &_S1884, filling_2, (&ray_2)->unit_direction, &_S1885);
                bool _S1887 = leavesInFront_0((&faced_2)->geometry_n, throughput_9, _S1868.geometry_n);
                float3  _S1888 = _slang_select(_S1887, _S1886.front.scatter,_S1886.behind.scatter);
                scatter_in_0 = _S1888;
                float3  _S1889 = scatter_in_0;
                float _S1890 = upsample(scatter_in_0, wavelength_8);
                float3  _S1891 = make_float3 (_S1890);
                float3  _S1892 = _slang_select(_S1621, _S1891,_S1889);
                scatter_in_0 = _S1892;
                float3  _S1893 = _slang_select(_S1887, _S1886.front.extinction,_S1886.behind.extinction);
                extinction_in_0 = _S1893;
                float3  _S1894 = extinction_in_0;
                float _S1895 = upsample(extinction_in_0, wavelength_8);
                float3  _S1896 = make_float3 (_S1895);
                float3  _S1897 = _slang_select(_S1621, _S1896,_S1894);
                extinction_in_0 = _S1897;
                float _S1898 = _slang_select(_S1887, _S1886.front.g,_S1886.behind.g);
                g_in_0 = _S1898;
                uint _S1899 = _S1886.fillings.x;
                uint _S1900 = _S1886.fillings.y;
                uint _S1901 = _slang_select(_S1887, _S1900,_S1899);
                bool _S1902 = (fcptVaryingUsed());
                uint _S1903 = _slang_select(_S1902, _S1901,4294967295U);
                filling_2 = _S1903;
            }
            (&ray_2)->unit_direction = throughput_9;
            bool _S1904 = !_S1857;
            if(_S1904)
            {
                FKSurface _S1905 = surface_12;
                float _S1906 = _slang_select(straight_0, 0.0f,_S1905.geometry_offset);
                float3  _S1907 = - _S1560.smooth_n;
                bool _S1908 = is_inside_8 != _S1744;
                float3  _S1909 = _slang_select(_S1908, _S1907,_S1560.smooth_n);
                float3  _S1910 = (&ray_2)->origin + make_float3 (_S1906) * _S1909;
                (&ray_2)->origin = _S1910;
            }
            throughput_10 = throughput_11;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1857;
            viewed_1 = _S1742;
            sky_pdf_2 = _S1872;
            spread_5 = _S1873;
            reconnection_0 = reconnection_1;
            is_inside_6 = is_inside_8;
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
            spread_5 = spread_2;
            straight_0 = false;
            is_inside_6 = is_inside_7;
        }
        float density_7;
        if(_S1598)
        {
            if(_S1522)
            {
                float3  _S1911 = pathColor(throughput_10 * emission_1, spectral_weight_0, wavelength_8);
                Reservoir candidate_8 = chain_0;
                uint _S1912 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1913 = _S1912 == 1U;
                if(_S1913)
                {
                    float3  _S1914 = safeDivide(_S1911, chain_throughput_0);
                    (&candidate_8)->radiance = _S1914;
                }
                Reservoir _S1915 = withEnd(candidate_8, 2U, b_7, _S1911);
                offer(sel_7, _S1915, _S1911 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1522)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1916 = survivalProbability(abs_0(throughput_10), density_6);
                density_7 = _S1916;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1917 = noiseAddress(_S1401, b_7);
            Random _S1918 = draw(_S1917, 8U);
            bool _S1919 = density_7 < (_S1918.value);
            if(_S1919)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1920 = (fcptMaxBounces());
                wrong_side_0 = b_7 >= _S1920;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1921 = density_6 * density_7;
            density_7 = _S1921;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1922 = layer_0 ^ 1U;
        uint _S1923 = _slang_select(passes_0, _S1922,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_4)->distance = 0.0f;
            b_10 = b_7;
            viewed_0 = viewed_1;
            throughput_2 = throughput_10;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_2 = spread_5;
            uint _S1924 = b_10 + 1U;
            b_7 = _S1924;
            layer_0 = _S1923;
            continue;
        }
        FKRay _S1925 = ray_2;
        float _S1926 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1627;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1378 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1927 = _slang_select(wrong_side_0, _S1926,4.294967296e+09f);
        bool _S1928 = !_S1589;
        if(straight_0)
        {
            _S1672 = true;
        }
        else
        {
            _S1672 = _S1589;
        }
        FKHit _S1929;
        if(_S1672)
        {
            _S1929 = hit_4;
        }
        else
        {
            _S1929 = _S1644;
        }
        FKHit _S1930 = (fcptTraverseInstanceBVH((_S1925), (_S1530), (_S1927), (_S1928), (_S1929), (viewed_1)));
        hit_4 = _S1930;
        if(replay_2)
        {
            _S1673 = _S1627;
        }
        else
        {
            _S1673 = false;
        }
        if(_S1673)
        {
            _S1737 = _S1378 == 1U;
        }
        else
        {
            _S1737 = false;
        }
        if(_S1737)
        {
            _S1738 = ((&hit_4)->instance_index) == (_S1390.instance_index);
        }
        else
        {
            _S1738 = false;
        }
        if(_S1738)
        {
            _S1739 = ((&hit_4)->triangle_index) == (_S1390.triangle_index);
        }
        else
        {
            _S1739 = false;
        }
        if(_S1739)
        {
            (&hit_4)->uv = _S1390.uv;
            float _S1931 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1931;
        }
        if(replay_2)
        {
            _S1740 = _S1627;
        }
        else
        {
            _S1740 = false;
        }
        if(_S1740)
        {
            _S1741 = _S1378 == 3U;
        }
        else
        {
            _S1741 = false;
        }
        if(_S1741)
        {
            _S1742 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1742 = false;
        }
        if(_S1742)
        {
            return _S1374;
        }
        Reservoir _S1932 = chain_0;
        uint _S1933 = filling_2;
        for(;;)
        {
            bool _S1934 = (fcptVaryingUsed());
            if(_S1934)
            {
                _S1743 = _S1933 != 4294967295U;
            }
            else
            {
                _S1743 = false;
            }
            float _S1935;
            if(_S1743)
            {
                float _S1936 = (fcptMajorant((_S1933)));
                _S1935 = _S1936;
            }
            else
            {
                _S1935 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1744 = _S1627;
            }
            else
            {
                _S1744 = false;
            }
            if(_S1744)
            {
                _S1745 = _S1378 == 1U;
            }
            else
            {
                _S1745 = false;
            }
            if(_S1745)
            {
                _S1746 = _S1935 > 0.0f;
            }
            else
            {
                _S1746 = false;
            }
            if(_S1746)
            {
                ended_0 = _S1374;
                sky_pdf_1 = sky_pdf_2;
                spread_3 = spread_5;
                width_4 = width_3;
                density_3 = density_7;
                throughput_11 = throughput_10;
                b_10 = b_7;
                _S1747 = true;
                break;
            }
            bool _S1937 = (&prev_0)->rough;
            if(_S1937)
            {
                _S1747 = !(_S1935 > 0.0f);
            }
            else
            {
                _S1747 = false;
            }
            (&prev_0)->rough = _S1747;
            uint _S1938 = b_7 + 320U;
            bool _S1939 = b_7 == 4294967295U;
            uint _S1940 = _slang_select(_S1939, 384U,_S1938);
            uint _S1941 = stream(_S1401, _S1940);
            uint tracking_1 = _S1941;
            weight_2 = throughput_3;
            glowed_0 = _S1373;
            b_10 = b_7;
            throughput_11 = throughput_10;
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
                    _S1372 = int(2);
                    break;
                }
                uint _S1942 = noiseAddress(_S1401, b_10);
                Random _S1943 = draw(_S1942, 10U);
                float _S1944 = freeFlight_0(_S1943.value, _S1935);
                if(_S1743)
                {
                    float3  _S1945 = (&ray_2)->origin;
                    float3  _S1946 = (&ray_2)->unit_direction;
                    float _S1947 = (&hit_4)->distance;
                    bool _S1948 = b_10 == 4294967295U;
                    uint _S1949 = _slang_select(_S1948, 0U,b_10);
                    uint _S1950 = (&prev_0)->lobe;
                    uint _S1951 = _slang_select(_S1948, 3U,_S1950);
                    float _S1952 = (fcptTrackMedium((_S1933), (_S1945), (_S1946), (_S1947), (&tracking_1), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1949), (_S1951), (_S1948)));
                    spread_4 = _S1952;
                }
                else
                {
                    spread_4 = _S1944;
                }
                bool _S1953 = !(spread_4 < ((&hit_4)->distance));
                if(_S1953)
                {
                    _S1372 = int(2);
                    break;
                }
                if(_S1743)
                {
                    _S1748 = _S1598;
                }
                else
                {
                    _S1748 = false;
                }
                if(_S1748)
                {
                    float3  _S1954 = pathColor(throughput_11 * glowed_0, spectral_weight_0, wavelength_8);
                    float3  _S1955 = _S1954 / make_float3 (density_3);
                    float3  _S1956 = sel_7->glow + _S1955;
                    sel_7->glow = _S1956;
                }
                else
                {
                }
                glowed_0 = _S1373;
                uint b_11 = b_10 + 1U;
                float3  _S1957 = (&ray_2)->origin + make_float3 (spread_4) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1957;
                float3  _S1958 = flightWeight_0(scatter_in_0, extinction_in_0, _S1935, spread_4, true);
                float3  _S1959 = weight_2;
                float _S1960 = upsample(weight_2, wavelength_8);
                float3  _S1961 = make_float3 (_S1960);
                float3  _S1962 = _slang_select(_S1621, _S1961,_S1959);
                float3  _S1963 = _slang_select(_S1743, _S1962,_S1958);
                float3  throughput_12 = throughput_11 * _S1963;
                uint _S1964 = stream(_S1401, b_11 + 320U);
                tracking_1 = _S1964;
                weight_2 = throughput_3;
                float width_7 = width_4 + spread_3 * spread_4;
                float _S1965 = spread_3 + 3.14159274101257324f;
                bool _S1966 = scatterSampled_0(replay_2, b_11, _S1389, _S1743);
                TreeSample light_4;
                if(_S1966)
                {
                    float3  _S1967 = (&ray_2)->origin;
                    float3  _S1968 = (&ray_2)->unit_direction;
                    float3  _S1969 = (&ray_2)->unit_direction;
                    uint _S1970 = noiseAddress(_S1401, b_11);
                    float3  _S1971 = extinction_in_0;
                    float3  _S1972 = extinction_in_0;
                    uint2  _S1973 = make_uint2 (_S1933);
                    float3  _S1974 = (&ray_2)->unit_direction;
                    uint _S1975 = arrivalLobe_0(b_11, (&prev_0)->lobe);
                    FKHit _S1976 = _S1644;
                    ShadowContext _S1977 = ShadowContext_x24init_0(_S1971, _S1972, _S1973, _S1974, b_11, _S1975, false, spread_4, width_7, &_S1976, false);
                    ShadowContext _S1978 = _S1977;
                    TreeSample _S1979 = sampleLightTree_0(_S1967, _S1968, _S1969, 0.0f, true, _S1970, &_S1978);
                    light_4 = _S1979;
                }
                else
                {
                    light_4 = _S1641;
                }
                float _S1980 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1981 = (fcptMaxBounces());
                bool _S1982 = b_11 < _S1981;
                if(_S1982)
                {
                    _S1749 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1749 = false;
                }
                float _S1983 = _slang_select(_S1749, _S1980,0.0f);
                float3  _S1984 = throughput_12 * light_4.radiance;
                float _S1985 = powerHeuristic(light_4.density, _S1983);
                float3  _S1986 = pathColor(_S1984 * make_float3 (_S1980 * _S1985), spectral_weight_0, wavelength_8);
                float3  _S1987 = _slang_select(_S1966, _S1986,_S1373);
                if(replay_2)
                {
                    _S1750 = b_11 == _S1389;
                }
                else
                {
                    _S1750 = false;
                }
                if(_S1750)
                {
                    bool _S1988 = _S1378 == 2U;
                    if(_S1988)
                    {
                        float _S1989 = resamplingTarget(_S1987);
                        _S1751 = _S1989 > 0.0f;
                    }
                    else
                    {
                        _S1751 = false;
                    }
                    if(_S1751)
                    {
                        Shift _S1990 = Shift_x24init_0(_S1987, 1.0f);
                        _S1372 = int(1);
                        ended_0 = _S1990;
                        spread_4 = _S1965;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_8 = b_11;
                        break;
                    }
                    _S1372 = int(1);
                    ended_0 = _S1374;
                    spread_4 = _S1965;
                    width_5 = width_7;
                    throughput_9 = throughput_12;
                    b_8 = b_11;
                    break;
                }
                if(_S1598)
                {
                    Reservoir candidate_9 = _S1932;
                    uint _S1991 = extractBits_0(_S1932.path, 24U, 8U);
                    uint _S1992 = insertBits_0(0U, _S1991, 24U, 8U);
                    uint _S1993 = extractBits_0(_S1932.path, 10U, 2U);
                    bool _S1994 = _S1993 == 1U;
                    if(_S1994)
                    {
                        float3  _S1995 = safeDivide(_S1987, chain_throughput_0);
                        (&candidate_9)->radiance = _S1995;
                    }
                    else
                    {
                        uint _S1996 = insertBits_0(_S1992, b_11 + 1U, 5U, 5U);
                        uint _S1997 = insertBits_0(_S1996, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1997;
                    }
                    Reservoir _S1998 = withEnd(candidate_9, 0U, b_11, _S1987);
                    offer(sel_7, _S1998, _S1987 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1999 = survivalProbability(abs_0(throughput_12), density_3);
                    uint _S2000 = noiseAddress(_S1401, b_11);
                    Random _S2001 = draw(_S2000, 8U);
                    bool _S2002 = _S1999 < (_S2001.value);
                    if(_S2002)
                    {
                        _S1751 = true;
                    }
                    else
                    {
                        uint _S2003 = (fcptMaxBounces());
                        _S1751 = b_11 >= _S2003;
                    }
                    if(_S1751)
                    {
                        _S1372 = int(1);
                        ended_0 = _S1374;
                        spread_4 = _S1965;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_8 = b_11;
                        break;
                    }
                    float _S2004 = density_3 * _S1999;
                    density_3 = _S2004;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S2005 = noiseAddress(_S1401, b_11);
                float3  _S2006 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S2005, &phase_pdf_1);
                (&ray_2)->unit_direction = _S2006;
                NEEVertex _S2007 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1373, (&ray_2)->origin);
                nee_vertex_0 = _S2007;
                Vertex _S2008 = scatteredVertex_0(is_inside_6);
                prev_0 = _S2008;
                float _S2009 = (&prev_0)->pdf;
                FKRay _S2010 = ray_2;
                FKHit _S2011 = (fcptTraverseInstanceBVH((_S2010), (true), (4.294967296e+09f), (false), (_S1644), (false)));
                hit_4 = _S2011;
                b_10 = b_11;
                throughput_11 = throughput_12;
                spread_3 = _S1965;
                width_4 = width_7;
                sky_pdf_1 = _S2009;
            }
            if(_S1372 != int(2))
            {
                spread_3 = spread_4;
                width_4 = width_5;
                throughput_11 = throughput_9;
                b_10 = b_8;
                _S1747 = true;
                break;
            }
            ended_0 = _S1374;
            _S1747 = false;
            break;
        }
        if(_S1747)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1748 = b_10 == b_7;
        }
        else
        {
            _S1748 = false;
        }
        bool _S2012 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S2012)
        {
            bool _S2013 = !(&nee_vertex_0)->none;
            float _S2014 = _slang_select(_S2013, sky_pdf_1,0.0f);
            float _S2015 = escapeWeight_0(_S2014, (&ray_2)->unit_direction);
            float3  _S2016 = environment_0((&ray_2)->unit_direction, b_10, (&prev_0)->lobe);
            float3  _S2017 = pathColor(throughput_11 * _S2016, spectral_weight_0, wavelength_8);
            if(replay_2)
            {
                bool _S2018 = b_10 == _S1389;
                if(_S2018)
                {
                    passes_0 = _S1378 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S2017 * make_float3 (_S2015) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1388)
                {
                    passes_0 = _S1385;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_10 == _S1376;
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
                    return Shift_x24init_0(_S2017 * make_float3 (_S2015), 1.0f);
                }
                return _S1374;
            }
            Reservoir candidate_10 = chain_0;
            uint _S2019 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S2020 = _S2019 == 1U;
            if(_S2020)
            {
                uint _S2021 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S2022 = _S2021 == b_10;
                float _S2023 = _slang_select(_S2022, 1.0f,_S2015);
                float3  _S2024 = safeDivide(_S2017 * make_float3 (_S2023), chain_throughput_0);
                (&candidate_10)->radiance = _S2024;
            }
            else
            {
                bool _S2025 = (&prev_0)->rough;
                if(_S2025)
                {
                    uint _S2026 = insertBits_0(_S1403, b_10 + 1U, 5U, 5U);
                    uint _S2027 = insertBits_0(_S2026, 3U, 10U, 2U);
                    uint _S2028 = insertBits_0(_S2027, (&prev_0)->lobe, 15U, 3U);
                    bool _S2029 = (&prev_0)->inside;
                    uint _S2030 = _slang_select(_S2029, 1U,0U);
                    uint _S2031 = insertBits_0(_S2028, _S2030, 22U, 1U);
                    (&candidate_10)->path = _S2031;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S2032 = _S2017 * make_float3 (_S2015);
            Reservoir _S2033 = withEnd(candidate_10, 3U, b_10, _S2032);
            offer(sel_7, _S2033, _S2032 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S2034 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S2034;
        bool _S2035 = (fcptVaryingUsed());
        if(_S2035)
        {
            _S1749 = filling_2 != 4294967295U;
        }
        else
        {
            _S1749 = false;
        }
        if(_S1749)
        {
            if(_S1598)
            {
                float3  _S2036 = pathColor(throughput_11 * glowed_0, spectral_weight_0, wavelength_8);
                float3  _S2037 = _S2036 / make_float3 (density_3);
                float3  _S2038 = sel_7->glow + _S2037;
                sel_7->glow = _S2038;
            }
            float3  _S2039 = throughput_11 * weight_2;
            throughput_9 = _S2039;
        }
        else
        {
            float3  _S2040 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S2041 = throughput_11 * _S2040;
            throughput_9 = _S2041;
        }
        float _S2042 = width_4 + spread_3 * (&hit_4)->distance;
        viewed_0 = _S1748;
        width_3 = _S2042;
        throughput_2 = throughput_9;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_3;
        uint _S1924 = b_10 + 1U;
        b_7 = _S1924;
        layer_0 = _S1923;
    }
    return _S1374;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_9)
{
    Selection _S2043 = (Selection{});
    Selection sel_8 = _S2043;
    bool _S2044 = (r_9->w) <= 0.0f;
    if(_S2044)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S2045 = walk_0(dom_8, r_9, true, 0.0f, &sel_8);
    return _S2045;
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

__device__ Random normal_distribution(uint state_5)
{
    Random _S2046 = pcg(state_5);
    Random _S2047 = pcg(_S2046.state);
    float _S2048 = 6.28318548202514648f * _S2046.value;
    float _S2049 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S2047.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S2047.state, _S2049 * (F32_cos((_S2048))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_6, float3  value_2)
{
    RandomSphere _S2050;
    (&_S2050)->state = state_6;
    (&_S2050)->value = value_2;
    return _S2050;
}

__device__ RandomSphere random_sphere(uint state_7)
{
    Random _S2051 = normal_distribution(state_7);
    Random _S2052 = normal_distribution(_S2051.state);
    Random _S2053 = normal_distribution(_S2052.state);
    float3  _S2054 = make_float3 (_S2051.value, _S2052.value, _S2053.value);
    float3  _S2055 = ((((_S2054)) * make_float3(rnorm3df(((_S2054)).x, ((_S2054)).y, ((_S2054)).z))));
    return RandomSphere_x24init_0(_S2053.state, _S2055);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_12)
{
    float3  _S2056 = p1_0 - p0_0;
    float3  _S2057 = p2_0 - p0_0;
    float2  _S2058 = uv1_0 - uv0_0;
    float2  _S2059 = uv2_0 - uv0_0;
    float _S2060 = _S2058.x;
    float _S2061 = _S2059.y;
    float _S2062 = _S2058.y;
    float _S2063 = _S2059.x;
    float _S2064 = _S2060 * _S2061 - _S2062 * _S2063;
    float _S2065 = 1.0f / _S2064;
    float3  t_24 = (_S2056 * make_float3 (_S2061) - _S2057 * make_float3 (_S2062)) * make_float3 (_S2065);
    float3  _S2066 = (_S2057 * make_float3 (_S2060) - _S2056 * make_float3 (_S2063)) * make_float3 (_S2065);
    float3  _S2067 = t_24 - n_12 * make_float3 (dot_0(n_12, t_24));
    float3  t_25 = ((((_S2067)) * make_float3(rnorm3df(((_S2067)).x, ((_S2067)).y, ((_S2067)).z))));
    bool _S2068 = (dot_0(cross_0(n_12, t_25), _S2066)) > 0.0f;
    float3  t_26;
    if(_S2068)
    {
        float3  _S2069 = negate_0(t_25);
        t_26 = _S2069;
    }
    else
    {
        t_26 = t_25;
    }
    float3  _S2070 = cross_0(n_12, t_26);
    return makeMatrix<float, 3, 3> (t_26, _S2070, n_12);
}

__device__ float3  tangentToWorldNormalMap(float3  v_14, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_14, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S2071 = t1_0 - t0_0;
    float3  _S2072 = t2_2 - t0_0;
    float3  _S2073 = t2_2 - t1_0;
    float _S2074 = (F32_min((length_0(_S2071)), ((F32_min((length_0(_S2072)), (length_0(_S2073)))))));
    float3  _S2075 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S2076 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S2077 = dot_0(geometry_n_5, _S2076);
    float3  _S2078 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S2079 = dot_0(geometry_n_5, _S2078);
    float3  _S2080 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S2081 = acos_0(abs_0(make_float3 (_S2077, _S2079, dot_0(geometry_n_5, _S2080))));
    float3  _S2082 = clamp_2(tan_0(_S2081), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S2075 * _S2082, uvw_0), 0.0f, _S2074 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_16, float3  n_13, BSDFMaterial material_28)
{
    float3  _S2083 = negate_0(dir_16);
    float _S2084 = sign_0(dot_0(n_13, _S2083));
    float3  _S2085 = n_13 * make_float3 (_S2084);
    AnisotropicFrame _S2086 = anisotropicFrame(material_28, _S2085);
    bool _S2087 = (_S2086.alphas.x) > 0.0f;
    if(_S2087)
    {
        float _S2088 = material_28.transmission * (1.0f - material_28.metallic);
        float3  _S2089 = negate_0(_S2085);
        float3  _S2090 = anisotropicLocal(dir_16, _S2086.tangent, _S2089);
        float _S2091 = anisotropicG1(_S2090, _S2086.alphas);
        return make_float3 (_S2088 * _S2091) * material_28.albedo;
    }
    float _S2092 = material_28.transmission * (1.0f - material_28.metallic);
    float _S2093 = material_28.roughness;
    float _S2094 = smithG1(_S2093 * _S2093, (F32_abs((dot_0(n_13, dir_16)))));
    return make_float3 (_S2092 * _S2094) * material_28.albedo;
}

__device__ float hairRow(float3  in_dir_12, float3  t_27, float3  out_dir_3, uint p_15, float w_20, float alpha_11, uint nt_0)
{
    uint _S2095 = p_15 % 4U;
    float _S2096 = w_20 * HAIR_WIDTHS_0[_S2095];
    float _S2097 = (F32_asin((clamp_1(dot_0(out_dir_3, t_27), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_12, t_27), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S2095] * alpha_11;
    return ((F32_asinh((_S2097 / _S2096))) / (F32_asinh((3.14159274101257324f / _S2096))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_13, float3  t_28, float3  out_dir_4, uint np_0)
{
    float3  _S2098 = worldToTangent(out_dir_4, t_28);
    float3  _S2099 = worldToTangent(in_dir_13, t_28);
    return (F32_frac((((F32_atan2((_S2098.z), (_S2098.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S2099.z), (1.17549435082228751e-38f - _S2099.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_14, float3  t_29, uint p_16, float row_0, float column_0, float w_21, float alpha_12, uint nt_1, uint np_1)
{
    float3  _S2100 = worldToTangent(in_dir_14, t_29);
    uint _S2101 = p_16 % 4U;
    float _S2102 = w_21 * HAIR_WIDTHS_0[_S2101];
    float _S2103 = (F32_asin((clamp_1(dot_0(in_dir_14, t_29), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S2101] * alpha_12 + _S2102 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S2102))))));
    float _S2104 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S2100.z), (1.17549435082228751e-38f - _S2100.x)));
    float _S2105 = (F32_cos((_S2103)));
    float3  _S2106 = tangentToWorld(make_float3 (_S2105 * (F32_cos((_S2104))), (F32_sin((_S2103))), _S2105 * (F32_sin((_S2104)))), t_29);
    return _S2106;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_14, BSDFMaterial material_29, float coverage_1)
{
    float3  through_2;
    if((material_29.ior) == 1.0f)
    {
        float3  _S2107 = straightThrough(toward_1, n_14, material_29);
        through_2 = _S2107;
    }
    else
    {
        through_2 = make_float3 (0.0f);
    }
    CoatFrame _S2108 = coatFrame(material_29, n_14);
    bool _S2109 = (_S2108.ior) > 0.0f;
    if(_S2109)
    {
        float _S2110 = fresnel((F32_abs((dot_0(_S2108.normal, toward_1)))), 1.0f, _S2108.ior);
        float3  _S2111 = mix_0(make_float3 (1.0f), make_float3 (1.0f - _S2110) * material_29.coat_tint, material_29.coat);
        float3  through_3 = through_2 * _S2111;
        through_2 = through_3;
    }
    return through_2 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_4, Selection * sel_9)
{
    Domain _S2112 = dom_9;
    Reservoir _S2113 = r_10;
    Shift _S2114 = walk_0(&_S2112, &_S2113, replay_3, scale_4, sel_9);
    return _S2114;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_11)
{
    Domain _S2115 = dom_10;
    Reservoir _S2116 = r_11;
    Shift _S2117 = shift_0(&_S2115, &_S2116);
    return _S2117;
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
        uint _S2118;
        if(i_27 < 2U)
        {
            _S2118 = x_29;
        }
        else
        {
            _S2118 = (x_29 + size_0 / 2U) & (size_0 - 1U);
        }
        uint l_6 = _S2118;
        uint r_12 = y_8;
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
            uint _S2119 = hash(((r_12 ^ (t_30 << 16U)) ^ (k_4 << 28U)) ^ ((i_27 & 1U) << 31U));
            uint _S2120 = l_6 ^ (_S2119 & (size_0 - 1U));
            uint k_5 = k_4 + 1U;
            l_6 = r_12;
            r_12 = _S2120;
            k_4 = k_5;
        }
        uint _S2121 = l_6 + r_12 * size_0;
        uint _S2122 = size_0 * size_0;
        uint _S2123;
        if(_S2122 >= 65536U)
        {
            uint _S2124 = _S2121 / (_S2122 / 65536U);
            _S2123 = _S2124;
        }
        else
        {
            uint _S2125 = 65536U / _S2122;
            _S2123 = _S2121 * _S2125;
        }
        ranks_0[i_27] = _S2123;
        uint i_28 = i_27 + 1U;
        i_27 = i_28;
    }
    bool _S2126 = (ranks_0[int(0)]) == 65535U;
    bool _S2127;
    if(_S2126)
    {
        _S2127 = (ranks_0[int(1)]) == 65535U;
    }
    else
    {
        _S2127 = false;
    }
    bool _S2128 = (ranks_0[int(2)]) == 65535U;
    bool _S2129;
    if(_S2128)
    {
        _S2129 = (ranks_0[int(3)]) == 65535U;
    }
    else
    {
        _S2129 = false;
    }
    if(_S2127)
    {
        _S2127 = (ranks_0[int(3)]) != 65535U;
    }
    else
    {
        _S2127 = false;
    }
    if(_S2127)
    {
        _S2127 = true;
    }
    else
    {
        if(_S2129)
        {
            _S2127 = (ranks_0[int(1)]) != 65535U;
        }
        else
        {
            _S2127 = false;
        }
    }
    uint _S2130 = ranks_0[int(0)];
    if(_S2127)
    {
        i_27 = ranks_0[int(3)];
    }
    else
    {
        i_27 = ranks_0[int(1)];
    }
    return _S2130 | (i_27 << 16U);
}

__device__ uint3  noiseBlock(uint sweep_0, uint colour_0, uint block_0, uint size_1)
{
    uint _S2131 = hash(sweep_0 * 7919U + 1U);
    uint _S2132 = size_1 / 16U;
    uint _S2133 = block_0 % _S2132;
    uint _S2134 = block_0 / _S2132;
    uint _S2135 = _S2134 % _S2132;
    uint _S2136 = block_0 / (_S2132 * _S2132);
    uint3  _S2137 = make_uint3 (_S2133, _S2135, _S2136);
    uint3  _S2138 = make_uint3 (colour_0 & 1U, (colour_0 >> 1U) & 1U, colour_0 >> 2U);
    return _S2137 * make_uint3 (16U) + _S2138 * make_uint3 (8U) + make_uint3 (_S2131 & 7U, (_S2131 >> 3U) & 7U, (_S2131 >> 6U) & 7U);
}

#undef Matrix
