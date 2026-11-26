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
    float _S426 = dot_0(n_3, i_6);
    float _S427 = 1.0f - eta_0 * eta_0 * (1.0f - _S426 * _S426);
    if(_S427 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_6 - make_float3 (eta_0 * _S426 + (F32_sqrt((_S427)))) * n_3;
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
    float _S458 = (F32_min(((F32_sqrt((material_6.specular_level))) * (F32_abs((eta_i_2 - eta_o_1))) / (eta_i_2 + eta_o_1)), (0.9999847412109375f)));
    float _S459 = _S458 * _S458;
    float _S460 = (1.0f + _S458) / (1.0f - _S458);
    float3  _S461 = make_float3 (1.0f);
    float3  _S462 = make_float3 (0.0f);
    float sheen_component_0;
    float3  sheen_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S463 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S464 = make_float3 (1.0f) - material_6.sheen * make_float3 (_S463);
        float _S465 = rgb_to_greyscale(material_6.sheen);
        float _S466 = _S465 * _S463;
        float3  _S467 = material_6.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S466;
        sheen_1 = _S467;
        scale_1 = _S464;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S462;
        scale_1 = _S461;
    }
    float _S468 = (F32_abs((material_6.toon.x)));
    bool _S469 = _S468 > 0.0f;
    float toon_component_0;
    float3  toon_1;
    if(_S469)
    {
        float _S470 = (F32_min((_S468), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S470);
        float _S471 = rgb_to_greyscale(material_6.albedo);
        float _S472 = _S470 * _S471;
        float3  _S473 = make_float3 (_S470) * material_6.albedo;
        toon_component_0 = _S472;
        toon_1 = _S473;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S462;
    }
    bool _S474 = (material_6.metallic) > 0.0f;
    float3  rebounce_0;
    if(_S474)
    {
        float _S475 = frame_1.alphas.x;
        float _S476 = (F32_sqrt(((F32_min((_S475), (frame_1.alphas.y))))));
        bool _S477 = _S475 > 0.0f;
        float _S478 = _slang_select(_S477, _S476,material_6.roughness);
        float _S479 = _S478 * _S478;
        float _S480 = (F32_pow((_S479), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S479) / (1.0f + 1.28094995021820068f * _S479);
        bool _S481 = _S479 > 0.0f;
        float _S482 = _slang_select(_S481, _S480,0.0f);
        float _S483 = clamp_1(dot_0(n_i_2, v_3), 0.0f, 1.0f);
        float _S484 = _S479 * _S478;
        float _S485 = (F32_min((1.00064504146575928f - _S478 * (0.00375499995425344f + _S483 * (-0.04133399948477745f + _S483 * (-0.90938502550125122f + _S483 * 0.35275399684906006f))) - _S479 * (0.27602800726890564f + _S483 * (1.27023398876190186f + _S483 * 0.04740000143647194f)) - _S484 * (0.31452900171279907f - _S483 * 0.34830701351165771f) + _S484 * _S478 * 0.27229699492454529f), (1.0f)));
        float3  _S486 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_6.albedo * make_float3 (_S482)), make_float3 (1.0f / (F32_max((_S485), (0.0000152587890625f)))));
        rebounce_0 = _S486;
    }
    else
    {
        rebounce_0 = _S461;
    }
    float _S487 = dot_0(h_0, v_3);
    float _S488 = eta_i_2 / eta_o_1;
    float3  _S489 = refract_0(in_dir_1, h_0, _S488);
    float3  _S490 = ((((_S489)) * make_float3(rnorm3df(((_S489)).x, ((_S489)).y, ((_S489)).z))));
    float _S491 = (F32_abs((_S487)));
    bool _S492 = eta_i_2 > eta_o_1;
    float _S493;
    if(_S492)
    {
        _S493 = _S460;
    }
    else
    {
        _S493 = 1.0f;
    }
    float _S494;
    if(_S492)
    {
        _S494 = 1.0f;
    }
    else
    {
        _S494 = _S460;
    }
    float _S495 = fresnel(_S491, _S493, _S494);
    float _S496 = eta_i_2 * eta_i_2;
    float _S497 = eta_o_1 * eta_o_1;
    bool _S498 = (_S496 * (1.0f - _S487 * _S487)) >= _S497;
    float3  _S499;
    if(_S498)
    {
        _S499 = _S461;
    }
    else
    {
        float3  _S500 = material_6.specular_tint * make_float3 (_S459);
        _S499 = _S500 + (make_float3 (1.0f) - _S500) * make_float3 (_S495 - _S459) / make_float3 (1.0f - _S459);
    }
    bool _S501 = (dot_0(coat_h_1, coat_h_1)) > 0.0f;
    float3  coat_1;
    float3  up_0;
    float3  through_0;
    if(_S501)
    {
        float _S502 = coatFresnel(in_dir_1, v_3, coat_h_1, coat_frame_2, eta_i_2, _S492);
        float _S503 = material_6.coat * _S502;
        float3  _S504 = material_6.coat_tint;
        float3  _S505 = _S504 * _S504;
        float3  _S506 = _slang_select(_S492, _S505,_S461);
        float3  _S507 = make_float3 (_S503) * _S506;
        float _S508 = 1.0f - _S502;
        bool _S509 = !_S492;
        float3  _S510 = _slang_select(_S509, coat_series_0,_S461);
        float3  _S511 = mix_0(_S461, make_float3 (_S508) * _S510, material_6.coat);
        float3  _S512 = mix_0(_S461, make_float3 (_S508) * material_6.coat_tint, material_6.coat);
        coat_1 = _S507;
        up_0 = _S511;
        through_0 = _S512;
    }
    else
    {
        coat_1 = _S462;
        up_0 = _S461;
        through_0 = _S461;
    }
    float3  _S513 = scale_1 * coat_1;
    float _S514 = rgb_to_greyscale(_S513);
    float3  _S515 = material_6.albedo * rebounce_0;
    float3  _S516 = mix_0(_S499, _S515, material_6.metallic);
    float3  F_1 = _S516 * scale_1 * up_0;
    float _S517 = rgb_to_greyscale(F_1);
    float _S518 = 1.0f - material_6.metallic;
    float _S519 = (1.0f - material_6.transmission) * _S518;
    float3  _S520 = make_float3 (1.0f) - _S499;
    float3  _S521 = make_float3 (_S519) * _S520 * scale_1 * up_0;
    float _S522 = material_6.transmission * _S518;
    float3  _S523 = make_float3 (_S522) * _S520 * scale_1 * through_0;
    float _S524 = (F32_max((_S517), (0.0f)));
    float _S525 = rgb_to_greyscale(_S521);
    float _S526 = (F32_max((_S525), (0.0f)));
    float _S527 = rgb_to_greyscale(_S523);
    float _S528 = sign_0(length_0(_S490));
    float _S529 = (F32_max((_S527 * _S528), (0.0f)));
    float _S530 = _S524 + _S526 + _S529 + toon_component_0 + _S514;
    float _S531 = (F32_min((sheen_component_0), (1.0f)));
    bool _S532 = sheen_component_0 > 0.0f;
    bool _S533;
    if(_S532)
    {
        _S533 = !(_S530 > 0.0f);
    }
    else
    {
        _S533 = false;
    }
    float _S534 = _slang_select(_S533, 1.0f,_S531);
    float _S535 = (1.0f - _S534) / (F32_max((_S530), (0.0000152587890625f)));
    float _S536 = _S526 * _S535;
    float _S537 = _S524 * _S535;
    float _S538 = _S529 * _S535;
    Weights _S539 = Weights_x24init_0(_S487, _S490, F_1, 1.0f, _S521, _S523, _S536, _S537, _S538, _S534, toon_component_0 * _S535, sheen_1, toon_1, _S513, _S514 * _S535);
    bool _S540 = any_1(ggx_n_0 != h_0);
    Weights leaving_0;
    if(_S540)
    {
        float _S541 = dot_0(ggx_n_0, v_3);
        float _S542 = eta_i_2 / eta_o_1;
        float3  _S543 = refract_0(in_dir_1, ggx_n_0, _S542);
        float3  _S544 = ((((_S543)) * make_float3(rnorm3df(((_S543)).x, ((_S543)).y, ((_S543)).z))));
        float _S545 = (F32_abs((_S541)));
        if(_S492)
        {
            _S493 = _S460;
        }
        else
        {
            _S493 = 1.0f;
        }
        if(_S492)
        {
            _S494 = 1.0f;
        }
        else
        {
            _S494 = _S460;
        }
        float _S546 = fresnel(_S545, _S493, _S494);
        bool _S547 = (_S496 * (1.0f - _S541 * _S541)) >= _S497;
        if(_S547)
        {
            _S499 = _S461;
        }
        else
        {
            float3  _S548 = material_6.specular_tint * make_float3 (_S459);
            _S499 = _S548 + (make_float3 (1.0f) - _S548) * make_float3 (_S546 - _S459) / make_float3 (1.0f - _S459);
        }
        if(_S501)
        {
            float _S549 = coatFresnel(in_dir_1, v_3, coat_h_1, coat_frame_2, eta_i_2, _S492);
            float _S550 = material_6.coat * _S549;
            float3  _S551 = material_6.coat_tint;
            float3  _S552 = _S551 * _S551;
            float3  _S553 = _slang_select(_S492, _S552,_S461);
            float3  _S554 = make_float3 (_S550) * _S553;
            float _S555 = 1.0f - _S549;
            bool _S556 = !_S492;
            float3  _S557 = _slang_select(_S556, coat_series_0,_S461);
            float3  _S558 = mix_0(_S461, make_float3 (_S555) * _S557, material_6.coat);
            float3  _S559 = mix_0(_S461, make_float3 (_S555) * material_6.coat_tint, material_6.coat);
            coat_1 = _S554;
            up_0 = _S558;
            through_0 = _S559;
        }
        else
        {
            coat_1 = _S462;
            up_0 = _S461;
            through_0 = _S461;
        }
        float3  _S560 = scale_1 * coat_1;
        float _S561 = rgb_to_greyscale(_S560);
        float3  _S562 = mix_0(_S499, _S515, material_6.metallic);
        float3  F_2 = _S562 * scale_1 * up_0;
        float _S563 = rgb_to_greyscale(F_2);
        float3  _S564 = make_float3 (1.0f) - _S499;
        float3  _S565 = make_float3 (_S519) * _S564 * scale_1 * up_0;
        float3  _S566 = make_float3 (_S522) * _S564 * scale_1 * through_0;
        float _S567 = (F32_max((_S563), (0.0f)));
        float _S568 = rgb_to_greyscale(_S565);
        float _S569 = (F32_max((_S568), (0.0f)));
        float _S570 = rgb_to_greyscale(_S566);
        float _S571 = sign_0(length_0(_S544));
        float _S572 = (F32_max((_S570 * _S571), (0.0f)));
        float _S573 = _S567 + _S569 + _S572 + toon_component_0 + _S561;
        if(_S532)
        {
            _S533 = !(_S573 > 0.0f);
        }
        else
        {
            _S533 = false;
        }
        float _S574 = _slang_select(_S533, 1.0f,_S531);
        float _S575 = (1.0f - _S574) / (F32_max((_S573), (0.0000152587890625f)));
        float _S576 = _S569 * _S575;
        float _S577 = _S567 * _S575;
        float _S578 = _S572 * _S575;
        Weights _S579 = Weights_x24init_0(_S541, _S544, F_2, 1.0f, _S565, _S566, _S576, _S577, _S578, _S574, toon_component_0 * _S575, sheen_1, toon_1, _S560, _S561 * _S575);
        leaving_0 = _S579;
    }
    else
    {
        leaving_0 = _S539;
    }
    bool _S580 = any_1(coat_n_0 != coat_h_1);
    Weights coated_0;
    if(_S580)
    {
        float _S581 = eta_i_2 / eta_o_1;
        float3  _S582 = refract_0(in_dir_1, h_0, _S581);
        float3  _S583 = ((((_S582)) * make_float3(rnorm3df(((_S582)).x, ((_S582)).y, ((_S582)).z))));
        if(_S492)
        {
            sheen_component_0 = _S460;
        }
        else
        {
            sheen_component_0 = 1.0f;
        }
        if(_S492)
        {
            _S493 = 1.0f;
        }
        else
        {
            _S493 = _S460;
        }
        float _S584 = fresnel(_S491, sheen_component_0, _S493);
        if(_S498)
        {
            rebounce_0 = _S461;
        }
        else
        {
            float3  _S585 = material_6.specular_tint * make_float3 (_S459);
            rebounce_0 = _S585 + (make_float3 (1.0f) - _S585) * make_float3 (_S584 - _S459) / make_float3 (1.0f - _S459);
        }
        bool _S586 = (dot_0(coat_n_0, coat_n_0)) > 0.0f;
        if(_S586)
        {
            float _S587 = coatFresnel(in_dir_1, v_3, coat_n_0, coat_frame_2, eta_i_2, _S492);
            float _S588 = material_6.coat * _S587;
            float3  _S589 = material_6.coat_tint;
            float3  _S590 = _S589 * _S589;
            float3  _S591 = _slang_select(_S492, _S590,_S461);
            float3  _S592 = make_float3 (_S588) * _S591;
            float _S593 = 1.0f - _S587;
            bool _S594 = !_S492;
            float3  _S595 = _slang_select(_S594, coat_series_0,_S461);
            float3  _S596 = mix_0(_S461, make_float3 (_S593) * _S595, material_6.coat);
            float3  _S597 = mix_0(_S461, make_float3 (_S593) * material_6.coat_tint, material_6.coat);
            coat_1 = _S592;
            up_0 = _S596;
            through_0 = _S597;
        }
        else
        {
            coat_1 = _S462;
            up_0 = _S461;
            through_0 = _S461;
        }
        float3  _S598 = scale_1 * coat_1;
        float _S599 = rgb_to_greyscale(_S598);
        float3  _S600 = mix_0(rebounce_0, _S515, material_6.metallic);
        float3  F_3 = _S600 * scale_1 * up_0;
        float _S601 = rgb_to_greyscale(F_3);
        float3  _S602 = make_float3 (1.0f) - rebounce_0;
        float3  _S603 = make_float3 (_S519) * _S602 * scale_1 * up_0;
        float3  _S604 = make_float3 (_S522) * _S602 * scale_1 * through_0;
        float _S605 = (F32_max((_S601), (0.0f)));
        float _S606 = rgb_to_greyscale(_S603);
        float _S607 = (F32_max((_S606), (0.0f)));
        float _S608 = rgb_to_greyscale(_S604);
        float _S609 = sign_0(length_0(_S583));
        float _S610 = (F32_max((_S608 * _S609), (0.0f)));
        float _S611 = _S605 + _S607 + _S610 + toon_component_0 + _S599;
        if(_S532)
        {
            _S533 = !(_S611 > 0.0f);
        }
        else
        {
            _S533 = false;
        }
        float _S612 = _slang_select(_S533, 1.0f,_S531);
        float _S613 = (1.0f - _S612) / (F32_max((_S611), (0.0000152587890625f)));
        float _S614 = _S607 * _S613;
        float _S615 = _S605 * _S613;
        float _S616 = _S610 * _S613;
        Weights _S617 = Weights_x24init_0(_S487, _S583, F_3, 1.0f, _S603, _S604, _S614, _S615, _S616, _S612, toon_component_0 * _S613, sheen_1, toon_1, _S598, _S599 * _S613);
        coated_0 = _S617;
    }
    else
    {
        coated_0 = _S539;
    }
    return Weights_x24init_0(leaving_0.v_dot_h, leaving_0.refracted, leaving_0.F, leaving_0.reflect_weight, _S539.diffuse_weight, leaving_0.refract_weight, _S539.p_diffuse, leaving_0.p_reflect, leaving_0.p_refract, _S539.p_sheen_velvet, _S539.p_toon, sheen_1, toon_1, coated_0.coat, coated_0.p_coat);
}

__device__ float translucentShare(BSDFMaterial material_7)
{
    float _S618 = rgb_to_greyscale(material_7.translucent);
    float _S619 = rgb_to_greyscale(material_7.albedo);
    float _S620 = _S618 / (_S619 + _S618);
    bool _S621 = _S618 > 0.0f;
    float _S622 = _slang_select(_S621, _S620,0.0f);
    return _S622;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float n_i_dot_v_0, BSDFMaterial material_8, Weights w_0)
{
    float _S623 = translucentShare(material_8);
    float _S624 = w_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S625 = w_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S626 = 1.0f - _S623;
    bool _S627 = n_i_dot_l_0 < 0.0f;
    float _S628 = _slang_select(_S627, _S623,_S626);
    float _S629 = _S625 * _S628;
    bool _S630 = _S623 > 0.0f;
    float _S631 = _slang_select(_S630, _S629,_S624);
    bool _S632 = n_i_dot_v_0 > 0.0f;
    float _S633 = _slang_select(_S632, _S631,0.0f);
    return _S633;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_3, BSDFMaterial material_9, Weights w_1)
{
    float _S634 = translucentShare(material_9);
    bool _S635 = (dot_0(n_i_3, l_0)) < 0.0f;
    float3  _S636 = _slang_select(_S635, material_9.translucent,material_9.albedo);
    float _S637 = 1.0f - _S634;
    float _S638 = _slang_select(_S635, _S634,_S637);
    float3  _S639 = _S636 / make_float3 (_S638);
    bool _S640 = _S634 > 0.0f;
    float3  _S641 = _slang_select(_S640, _S639,material_9.albedo);
    return w_1.diffuse_weight * _S641 / make_float3 (w_1.p_diffuse);
}

__device__ float trowbridgeReitz(float alpha_2, float n_dot_h_0)
{
    float _S642 = alpha_2 * alpha_2;
    float _S643 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S642 * n_dot_h_0 * n_dot_h_0;
    return _S642 / (F32_max((3.14159274101257324f * _S643 * _S643), (1.17549435082228751e-38f)));
}

__device__ float3  anisotropicLocal(float3  w_2, float3  t_12, float3  n_5)
{
    return make_float3 (dot_0(w_2, t_12), dot_0(w_2, cross_0(n_5, t_12)), dot_0(w_2, n_5));
}

__device__ float anisotropicG1(float3  w_3, float2  alphas_1)
{
    float _S644 = (F32_max((w_3.z), (0.0f)));
    return 2.0f * _S644 / (_S644 + length_0(make_float3 (alphas_1.x * w_3.x, alphas_1.y * w_3.y, _S644)));
}

__device__ float anisotropicD(float3  h_1, float2  alphas_2)
{
    float _S645 = alphas_2.x;
    float _S646 = h_1.x / _S645;
    float _S647 = alphas_2.y;
    float _S648 = h_1.y / _S647;
    float _S649 = h_1.z;
    float _S650 = _S646 * _S646 + _S648 * _S648 + _S649 * _S649;
    return 1.0f / (F32_max((3.14159274101257324f * _S645 * _S647 * _S650 * _S650), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float3  v_4, float3  h_2, float3  n_i_4, float n_i_dot_v_1, float alpha_3, AnisotropicFrame frame_2, float v_dot_h_1)
{
    float _S651 = dot_0(n_i_4, h_2);
    float _S652 = smithG1(alpha_3, n_i_dot_v_1);
    float _S653 = _S652 * v_dot_h_1;
    float _S654 = trowbridgeReitz(alpha_3, _S651);
    float _S655 = _S653 * _S654 / n_i_dot_v_1;
    bool _S656 = alpha_3 > 0.0f;
    bool _S657;
    if(_S656)
    {
        _S657 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S657 = false;
    }
    if(_S657)
    {
        _S657 = _S651 > 0.0f;
    }
    else
    {
        _S657 = false;
    }
    if(_S657)
    {
        _S657 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S657 = false;
    }
    float _S658 = _slang_select(_S657, _S655,0.0f);
    bool _S659 = (frame_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S659)
    {
        float3  _S660 = anisotropicLocal(v_4, frame_2.tangent, n_i_4);
        float _S661 = anisotropicG1(_S660, frame_2.alphas);
        float3  _S662 = anisotropicLocal(h_2, frame_2.tangent, n_i_4);
        float _S663 = anisotropicD(_S662, frame_2.alphas);
        float _S664 = _S661 * _S663;
        float _S665 = _S664 * v_dot_h_1 / n_i_dot_v_1;
        bool _S666 = v_dot_h_1 > 0.0f;
        if(_S666)
        {
            _S657 = _S651 > 0.0f;
        }
        else
        {
            _S657 = false;
        }
        if(_S657)
        {
            _S657 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S657 = false;
        }
        float _S667 = _slang_select(_S657, _S665,0.0f);
        pdf_h_0 = _S667;
    }
    else
    {
        pdf_h_0 = _S658;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float l_dot_h_0, float pdf_h_1, Weights w_4, float eta_i_3, float eta_o_2)
{
    float _S668 = eta_i_3 * w_4.v_dot_h + eta_o_2 * l_dot_h_0;
    float _S669 = w_4.p_refract * pdf_h_1 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S668 * _S668);
    bool _S670 = eta_i_3 != eta_o_2;
    bool _S671;
    if(_S670)
    {
        _S671 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S671 = false;
    }
    float _S672 = _slang_select(_S671, _S669,0.0f);
    return _S672;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_5, float alpha_4, AnisotropicFrame frame_3, BSDFMaterial material_10, Weights w_5)
{
    float _S673 = - dot_0(n_i_5, l_1);
    float _S674 = smithG1(alpha_4, (F32_max((_S673), (0.0f))));
    bool _S675 = (frame_3.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S675)
    {
        float3  _S676 = negate_0(n_i_5);
        float3  _S677 = anisotropicLocal(l_1, frame_3.tangent, _S676);
        float _S678 = anisotropicG1(_S677, frame_3.alphas);
        G1_l_0 = _S678;
    }
    else
    {
        G1_l_0 = _S674;
    }
    return w_5.refract_weight * make_float3 (G1_l_0) * material_10.albedo / make_float3 (w_5.p_refract);
}

__device__ __forceinline__ float reflectPDF(float pdf_h_2, Weights w_6)
{
    float _S679 = w_6.p_reflect * pdf_h_2 / (4.0f * w_6.v_dot_h);
    bool _S680 = pdf_h_2 > 0.0f;
    float _S681 = _slang_select(_S680, _S679,0.0f);
    return _S681;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_2, float3  n_i_6, float alpha_5, AnisotropicFrame frame_4, Weights w_7)
{
    float _S682 = dot_0(n_i_6, l_2);
    float _S683 = smithG1(alpha_5, (F32_max((_S682), (0.0f))));
    bool _S684 = (frame_4.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S684)
    {
        float3  _S685 = anisotropicLocal(l_2, frame_4.tangent, n_i_6);
        float _S686 = anisotropicG1(_S685, frame_4.alphas);
        G1_l_1 = _S686;
    }
    else
    {
        G1_l_1 = _S683;
    }
    return make_float3 (w_7.reflect_weight * G1_l_1) * w_7.F / make_float3 (w_7.p_reflect);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_1, float n_i_dot_v_2, Weights w_8)
{
    float _S687 = w_8.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S688 = n_i_dot_l_1 > 0.0f;
    bool _S689;
    if(_S688)
    {
        _S689 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S689 = false;
    }
    float _S690 = _slang_select(_S689, _S687,0.0f);
    return _S690;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_3, float3  v_5, float3  n_i_7, BSDFMaterial material_11, Weights w_9)
{
    float3  _S691 = l_3 + v_5;
    float3  _S692 = ((((_S691)) * make_float3(rnorm3df(((_S691)).x, ((_S691)).y, ((_S691)).z))));
    float _S693 = dot_0(n_i_7, _S692);
    float _S694 = (F32_max((dot_0(n_i_7, l_3)), (0.0f)));
    float _S695 = (F32_max((dot_0(n_i_7, v_5)), (0.0f)));
    float _S696 = 1.0f / (F32_max((material_11.sheen_roughness), (0.05000000074505806f)));
    float _S697 = 1.0f - _S693 * _S693;
    float _S698 = (2.0f + _S696) * (F32_pow(((F32_max((_S697), (0.0f)))), (0.5f * _S696))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S694 + _S695 - _S694 * _S695)), (0.0000152587890625f)));
    bool _S699 = (material_11.velvet) > 0.0f;
    float f_1;
    if(_S699)
    {
        float _S700 = (F32_max((material_11.sheen_roughness), (0.00999999977648258f)));
        float _S701 = _S700 * _S700;
        float _S702 = (F32_max((_S697), (0.0000152587890625f)));
        float _S703 = (F32_exp((- _S693 * _S693 / (_S702 * _S701)))) / (3.14159274101257324f * _S701 * _S702 * _S702) * (F32_min((1.0f), (2.0f * _S693 * (F32_min((_S694), (_S695))) / (F32_max(((F32_abs((dot_0(_S692, v_5))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S694 * _S695), (0.0000152587890625f)));
        f_1 = _S703;
    }
    else
    {
        f_1 = _S698;
    }
    return w_9.sheen * make_float3 (f_1 * _S694 * 2.0f * 3.14159274101257324f / w_9.p_sheen_velvet);
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
    float _S704;
    if(t_13 < a_3)
    {
        _S704 = 1.0f;
    }
    else
    {
        _S704 = (F32_max((1.0f - (t_13 - a_3) / (F32_max((s_0), (0.0000152587890625f)))), (0.0f)));
    }
    return _S704;
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
        float _S705 = (F32_sin(((F32_min((t_14), (a_4))))));
        integral_0 = _S705 * _S705 / 2.0f;
    }
    bool _S706 = t_14 > a_4;
    bool _S707;
    if(_S706)
    {
        _S707 = s_1 > 0.0f;
    }
    else
    {
        _S707 = false;
    }
    if(_S707)
    {
        float _S708;
        if(glossy_0)
        {
            float _S709 = (F32_cos((a_4)));
            float _S710 = (F32_cos((t_14)));
            _S708 = (1.0f + a_4 / s_1) * (_S709 - _S710) - ((F32_sin((t_14))) - t_14 * _S710 - ((F32_sin((a_4))) - a_4 * _S709)) / s_1;
        }
        else
        {
            float _S711 = 2.0f * a_4;
            float _S712 = (F32_cos((_S711)));
            float _S713 = 2.0f * t_14;
            float _S714 = (F32_cos((_S713)));
            _S708 = (1.0f + a_4 / s_1) * (_S712 - _S714) / 4.0f - ((F32_sin((_S713))) / 8.0f - t_14 * _S714 / 4.0f - ((F32_sin((_S711))) / 8.0f - a_4 * _S712 / 4.0f)) / s_1;
        }
        float integral_1 = integral_0 + _S708;
        integral_0 = integral_1;
    }
    return integral_0;
}

static __device__ ToonProfile ToonProfile_x24init_0(bool glossy_1, float a_5, float s_2, float b_1, float norm_0, float view_0, float3  axis_0)
{
    ToonProfile _S715;
    (&_S715)->glossy = glossy_1;
    (&_S715)->a = a_5;
    (&_S715)->s = s_2;
    (&_S715)->b = b_1;
    (&_S715)->norm = norm_0;
    (&_S715)->view = view_0;
    (&_S715)->axis = axis_0;
    return _S715;
}

__device__ __forceinline__ ToonProfile toonProfile(float3  v_6, float3  n_i_8, BSDFMaterial material_12)
{
    float _S716 = material_12.toon.x;
    bool _S717 = _S716 < 0.0f;
    float _S718 = clamp_1(material_12.toon.y / _S716, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S719 = clamp_1(material_12.toon.z / _S716, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S720 = (F32_min((_S718 + _S719), (1.57079637050628662f)));
    float _S721 = dot_0(n_i_8, v_6);
    float _S722 = toonP((F32_acos(((F32_min((_S721), (1.0f)))))), _S718, _S719);
    float3  _S723;
    if(_S717)
    {
        float3  _S724 = make_float3 (2.0f * _S721) * n_i_8 - v_6;
        float3  _S725 = ((((_S724)) * make_float3(rnorm3df(((_S724)).x, ((_S724)).y, ((_S724)).z))));
        _S723 = _S725;
    }
    else
    {
        _S723 = n_i_8;
    }
    float _S726 = toonIntegral(_S720, _S718, _S719, _S717);
    return ToonProfile_x24init_0(_S717, _S718, _S719, _S720, 6.28318548202514648f * _S726, _S722, _S723);
}

__device__ __forceinline__ float toonPDF(float3  l_4, float3  n_i_9, ToonProfile profile_1, Weights w_10)
{
    float _S727 = dot_0(n_i_9, l_4);
    float _S728 = dot_0(l_4, profile_1.axis);
    float _S729 = _slang_select(profile_1.glossy, _S728,_S727);
    float _S730 = (F32_acos((clamp_1(_S729, -1.0f, 1.0f))));
    float _S731 = toonP(_S730, profile_1.a, profile_1.s);
    float _S732 = w_10.p_toon * _S731;
    float _S733 = _slang_select(profile_1.glossy, 1.0f,_S727);
    float _S734 = _S732 * _S733 / profile_1.norm;
    bool _S735;
    if(profile_1.glossy)
    {
        _S735 = true;
    }
    else
    {
        _S735 = _S727 > 0.0f;
    }
    float _S736 = _slang_select(_S735, _S734,0.0f);
    return _S736;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_5, float3  n_i_10, ToonProfile profile_2, Weights w_11)
{
    float _S737 = (F32_max((dot_0(n_i_10, l_5)), (0.0f)));
    float _S738 = _slang_select(profile_2.glossy, _S737,profile_2.view);
    return w_11.toon * make_float3 (_S738) / make_float3 (w_11.p_toon);
}

__device__ __forceinline__ float coatPDF(float3  v_7, float3  coat_h_2, CoatFrame coat_frame_3, Weights w_12)
{
    float _S739 = dot_0(coat_frame_3.normal, v_7);
    float _S740 = smithG1(coat_frame_3.alpha, _S739);
    float _S741 = trowbridgeReitz(coat_frame_3.alpha, dot_0(coat_frame_3.normal, coat_h_2));
    float _S742 = _S740 * _S741 / (4.0f * _S739);
    bool _S743 = (coat_frame_3.alpha) > 0.0f;
    float _S744 = _slang_select(_S743, _S742,0.0f);
    return w_12.p_coat * _S744;
}

__device__ __forceinline__ float3  coatBSDF(Weights w_13)
{
    return w_13.coat / make_float3 (w_13.p_coat);
}

__device__ __forceinline__ void BSDF(float3  in_dir_2, float3  out_dir_0, float3  n_6, BSDFMaterial material_13, float eta_i_4, float eta_o_3, bool refracted_2, Facets facets_0, FixedArray<float3 , 6>  * throughputs_0, FixedArray<float, 6>  * pdfs_0)
{
    float3  _S745 = negate_0(in_dir_2);
    float _S746 = dot_0(n_6, _S745);
    float _S747 = sign_0(_S746);
    float3  _S748 = n_6 * make_float3 (_S747);
    float _S749 = dot_0(_S748, out_dir_0);
    float _S750 = material_13.roughness;
    float _S751 = _S750 * _S750;
    AnisotropicFrame _S752 = anisotropicFrame(material_13, _S748);
    SheenProfile _S753 = sheenProfile(_S745, _S748, material_13);
    CoatFrame _S754 = coatFrame(material_13, _S748);
    float3  _S755 = coatSeries(_S754, material_13);
    float _S756 = rgb_to_greyscale(material_13.translucent);
    bool _S757 = _S756 > 0.0f;
    bool _S758 = (dot_0(n_6, out_dir_0) * _S746) < 0.0f;
    bool _S759 = (F32_abs((material_13.toon.x))) > 0.0f;
    float3  _S760 = facets_0.coat_h;
    bool _S761 = (dot_0(_S760, _S760)) > 0.0f;
    bool _S762;
    if(_S757)
    {
        _S762 = _S758;
    }
    else
    {
        _S762 = false;
    }
    bool _S763 = _S762 == refracted_2;
    bool _S764 = !refracted_2;
    if(_S764)
    {
        _S762 = _S759;
    }
    else
    {
        _S762 = false;
    }
    bool _S765;
    if(_S764)
    {
        _S765 = _S761;
    }
    else
    {
        _S765 = false;
    }
    float3  _S766 = negate_0(make_float3 (eta_i_4) * _S745 + make_float3 (eta_o_3) * out_dir_0);
    float3  _S767 = ((((_S766)) * make_float3(rnorm3df(((_S766)).x, ((_S766)).y, ((_S766)).z))));
    float3  _S768 = _S745 + out_dir_0;
    float3  _S769 = ((((_S768)) * make_float3(rnorm3df(((_S768)).x, ((_S768)).y, ((_S768)).z))));
    float _S770 = sign_0(dot_0(_S767, _S748));
    float3  _S771 = _S767 * make_float3 (_S770);
    float3  _S772 = _slang_select(refracted_2, _S771,_S769);
    float3  _S773 = make_float3 (0.0f);
    float3  _S774 = ((((_S768)) * make_float3(rnorm3df(((_S768)).x, ((_S768)).y, ((_S768)).z))));
    float3  _S775 = _slang_select(_S765, _S774,_S773);
    Weights _S776 = lobeWeights(in_dir_2, _S745, _S748, facets_0.h, facets_0.coat_h, _S772, _S775, _S752, _S753, _S754, _S755, material_13, eta_i_4, eta_o_3);
    float _S777 = (F32_abs((_S746)));
    float _S778 = diffusePDF(_S749, _S777, material_13, _S776);
    float _S779 = _slang_select(_S763, _S778,0.0f);
    (*pdfs_0)[int(0)] = _S779;
    float3  _S780 = diffuseBSDF(out_dir_0, _S748, material_13, _S776);
    float3  _S781 = _slang_select(_S763, _S780,_S773);
    (*throughputs_0)[int(0)] = _S781;
    float _S782 = vndfPDF(_S745, _S772, _S748, _S777, _S751, _S752, _S776.v_dot_h);
    float _S783 = refractPDF(dot_0(out_dir_0, _S772), _S782, _S776, eta_i_4, eta_o_3);
    float _S784 = _slang_select(refracted_2, _S783,0.0f);
    (*pdfs_0)[int(1)] = _S784;
    float3  _S785 = refractBSDF(out_dir_0, _S748, _S751, _S752, material_13, _S776);
    float3  _S786 = _slang_select(refracted_2, _S785,_S773);
    (*throughputs_0)[int(1)] = _S786;
    float _S787 = reflectPDF(_S782, _S776);
    float _S788 = _slang_select(_S764, _S787,0.0f);
    (*pdfs_0)[int(2)] = _S788;
    float3  _S789 = reflectBSDF(out_dir_0, _S748, _S751, _S752, _S776);
    float3  _S790 = _slang_select(_S764, _S789,_S773);
    (*throughputs_0)[int(2)] = _S790;
    float _S791 = sheenVelvetPDF(_S749, _S777, _S776);
    float _S792 = _slang_select(_S764, _S791,0.0f);
    (*pdfs_0)[int(3)] = _S792;
    float3  _S793 = sheenVelvetBSDF(out_dir_0, _S745, _S748, material_13, _S776);
    float3  _S794 = _slang_select(_S764, _S793,_S773);
    (*throughputs_0)[int(3)] = _S794;
    ToonProfile _S795 = toonProfile(_S745, _S748, material_13);
    float _S796 = toonPDF(out_dir_0, _S748, _S795, _S776);
    float _S797 = _slang_select(_S762, _S796,0.0f);
    (*pdfs_0)[int(4)] = _S797;
    float3  _S798 = toonBSDF(out_dir_0, _S748, _S795, _S776);
    float3  _S799 = _slang_select(_S762, _S798,_S773);
    (*throughputs_0)[int(4)] = _S799;
    float _S800 = coatPDF(_S745, _S775, _S754, _S776);
    float _S801 = _slang_select(_S765, _S800,0.0f);
    (*pdfs_0)[int(5)] = _S801;
    float3  _S802 = coatBSDF(_S776);
    float3  _S803 = _slang_select(_S765, _S802,_S773);
    (*throughputs_0)[int(5)] = _S803;
    return;
}

static __device__ __forceinline__ float3  skyLobes_0(float3  in_dir_3, float3  dir_3, FKSurface * surface_1, BSDFMaterial * material_14, float2  eta_1, bool is_inside_2, Facets * facets_1, float pdf_0, FixedArray<float3 , 6>  * terms_0, FixedArray<float, 6>  * pdfs_1)
{
    bool _S804 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    BSDF(in_dir_3, dir_3, surface_1->smooth_n, *material_14, eta_1.x, eta_1.y, _S804, *facets_1, terms_0, pdfs_1);
    float3  _S805 = make_float3 (0.0f);
    uint i_9 = 0U;
    float3  f_2 = _S805;
    for(;;)
    {
        if(i_9 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S806 = ((*pdfs_1)[i_9]) > 0.0f;
        if(_S806)
        {
            float3  _S807 = (*terms_0)[i_9] * make_float3 ((*pdfs_1)[i_9]) / make_float3 ((*pdfs_1)[i_9] + pdf_0);
            (*terms_0)[i_9] = _S807;
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
    SkySample _S808;
    (&_S808)->dir = dir_4;
    (&_S808)->radiance = radiance_0;
    (&_S808)->color = color_0;
    (&_S808)->random_state = random_state_2;
    return _S808;
}

static __device__ __noinline__ float3  skyColor_0(float3  dir_5, FixedArray<float3 , 6>  * terms_1, FixedArray<float, 6>  * pdfs_2, uint depth_0)
{
    float3  _S809 = make_float3 (0.0f);
    bool shaded_0 = false;
    float3  world_0 = _S809;
    uint i_11 = 0U;
    float3  color_1 = _S809;
    for(;;)
    {
        if(i_11 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S810 = ((*pdfs_2)[i_11]) > 0.0f;
        if(_S810)
        {
            bool _S811 = (fcptWorldReadsPath());
            bool _S812;
            if(_S811)
            {
                _S812 = true;
            }
            else
            {
                _S812 = !shaded_0;
            }
            bool shaded_1;
            float3  world_1;
            if(_S812)
            {
                uint _S813;
                if(i_11 == 3U)
                {
                    _S813 = 4U;
                }
                else
                {
                    if(i_11 == 4U)
                    {
                        _S813 = 6U;
                    }
                    else
                    {
                        if(i_11 == 5U)
                        {
                            _S813 = 5U;
                        }
                        else
                        {
                            _S813 = i_11;
                        }
                    }
                }
                float3  _S814 = (fcptEnvMapSample((dir_5), (depth_0), (_S813)));
                world_1 = _S814;
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
    uint2  _S815 = (fcptEnvironmentCdfSize());
    uint2  _S816 = make_uint2 (1U, 0U);
    uint2  _S817 = _S815 - _S816;
    Random _S818 = draw(init_random_state_0, 6U);
    Random _S819 = draw(init_random_state_0, 2147483654U);
    Random _S820 = draw(init_random_state_0, 7U);
    Random _S821 = draw(init_random_state_0, 2147483655U);
    uint _S822 = _S817.x;
    uint _S823 = searchCDF_0(make_uint2 (_S822, 0U), make_uint2 (0U, 1U), _S817.y, _S818.value);
    uint _S824 = searchCDF_0(make_uint2 (0U, _S823), _S816, _S822, _S819.value);
    float2  _S825 = make_float2 ((float)_S817.x, (float)_S817.y);
    float2  _S826 = (make_float2 (float(_S824), float(_S823)) + make_float2 (_S820.value, _S821.value)) / _S825 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S827 = _S826.y;
    float _S828 = (F32_sin((_S827)));
    float _S829 = _S826.x;
    float3  _S830 = make_float3 (- _S828 * (F32_cos((_S829))), _S828 * (F32_sin((_S829))), (F32_cos((_S827))));
    float _S831 = environmentPdf_0(_S830);
    BSDFMaterial _S832 = pathMaterial(surface_2->material, wavelength_3);
    BSDFMaterial _S833 = _S832;
    FixedArray<float3 , 6>  terms_2;
    FixedArray<float, 6>  pdfs_3;
    float3  _S834 = skyLobes_0(ray_0->unit_direction, _S830, surface_2, &_S833, eta_2, is_inside_3, facets_2, _S831, &terms_2, &pdfs_3);
    bool _S835 = !(_S831 > 0.0f);
    bool _S836;
    if(_S835)
    {
        _S836 = true;
    }
    else
    {
        _S836 = all_1(_S834 == make_float3 (0.0f));
    }
    if(_S836)
    {
        float3  _S837 = make_float3 (0.0f);
        return SkySample_x24init_0(_S830, _S837, _S837, _S821.state);
    }
    bool _S838 = (fcptWorldReadsPath());
    float3  seen_0;
    if(_S838)
    {
        uint _S839 = context_2->depth + 1U;
        FixedArray<float3 , 6>  _S840 = terms_2;
        FixedArray<float, 6>  _S841 = pdfs_3;
        float3  _S842 = skyColor_0(_S830, &_S840, &_S841, _S839);
        seen_0 = _S842;
    }
    else
    {
        seen_0 = _S834;
    }
    float3  _S843 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S830, context_2, _S821.state);
    return SkySample_x24init_0(_S830, _S843, seen_0 * _S843, _S821.state);
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
    SampleBSDF _S844 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_4), (light_1->dir)));
    float3  _S845 = _S844.throughput * make_float3 (_S844.pdf);
    float _S846 = light_1->density;
    float _S847 = 1.0f + _S844.pdf * _S844.pdf / (light_1->density * light_1->density);
    bool _S848;
    if(competing_0)
    {
        _S848 = _S846 > 0.0f;
    }
    else
    {
        _S848 = false;
    }
    float _S849 = _slang_select(_S848, _S847,1.0f);
    return _S845 / make_float3 (_S849) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_3)
{
    TreeSample _S850;
    (&_S850)->dir = dir_6;
    (&_S850)->radiance = radiance_1;
    (&_S850)->density = density_0;
    (&_S850)->random_state = random_state_3;
    return _S850;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_4, float * pick_0, float * probability_3)
{
    float _S851 = importance(first_1, p_12, normal_4);
    float _S852 = importance(second_1, p_12, normal_4);
    float2  _S853 = make_float2 (_S851, _S852);
    bool _S854 = _S851 == 0.0f;
    bool _S855;
    if(_S854)
    {
        _S855 = _S852 == 0.0f;
    }
    else
    {
        _S855 = false;
    }
    if(_S855)
    {
        return 2U;
    }
    float _S856 = _S851 + _S852;
    bool _S857 = _S852 > 0.0f;
    if(_S857)
    {
        _S855 = (*pick_0 * _S856) >= _S851;
    }
    else
    {
        _S855 = false;
    }
    uint _S858 = uint(_S855);
    float _S859 = (F32_min(((*pick_0 * _S856 - float(_S858) * _S851) / _slang_vector_get_element(_S853, _S858)), (0.99999994039535522f)));
    *pick_0 = _S859;
    float _S860 = *probability_3 * (_slang_vector_get_element(_S853, _S858) / _S856);
    *probability_3 = _S860;
    return _S858;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S861 = center_1 - p_13;
    float _S862 = radius_1 * radius_1 / dot_0(_S861, _S861);
    float _S863 = u1_0 * _S862 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S862), (0.0f)))))));
    float _S864 = 2.0f * u1_0;
    bool _S865 = _S862 >= 1.0f;
    float _S866 = _slang_select(_S865, _S864,_S863);
    float _S867 = (F32_sqrt(((F32_max((_S866 * (2.0f - _S866)), (0.0f))))));
    float _S868 = 6.28318548202514648f * u2_0;
    float3  _S869 = make_float3 (_S867 * (F32_cos((_S868))), 1.0f - _S866, _S867 * (F32_sin((_S868))));
    float3  _S870 = ((((_S861)) * make_float3(rnorm3df(((_S861)).x, ((_S861)).y, ((_S861)).z))));
    float3  _S871 = tangentToWorld(_S869, _S870);
    return _S871;
}

__device__ float3  pointLightRadiance(float3  color_3, float intensity_0, float radius_2)
{
    return color_3 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S872 = center_2 - ray_1->origin;
    float _S873 = dot_0(_S872, ray_1->unit_direction);
    float _S874 = dot_0(_S872, _S872) - _S873 * _S873;
    float _S875 = radius_3 * radius_3;
    bool _S876 = _S874 > _S875;
    if(_S876)
    {
        return 4.294967296e+09f;
    }
    float _S877 = (F32_sqrt((_S875 - _S874)));
    float _S878 = _S873 - _S877;
    float _S879 = _S873 + _S877;
    bool _S880 = _S878 > 0.0000152587890625f;
    bool _S881;
    if(_S880)
    {
        _S881 = _S878 < max_len_0;
    }
    else
    {
        _S881 = false;
    }
    if(_S881)
    {
        return _S878;
    }
    bool _S882 = _S879 > 0.0000152587890625f;
    if(_S882)
    {
        _S881 = _S879 < max_len_0;
    }
    else
    {
        _S881 = false;
    }
    if(_S881)
    {
        return _S879;
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
    Random _S883 = draw(init_random_state_1, 4U);
    Random _S884 = draw(init_random_state_1, 5U);
    Random _S885 = draw(init_random_state_1, 2147483653U);
    float3  _S886 = make_float3 (0.0f);
    TreeSample _S887 = TreeSample_x24init_0(_S886, _S886, 0.0f, _S885.state);
    TreeSample sample_0 = _S887;
    float3  _S888 = _slang_select(sided_0, _S886,smooth_n_2);
    float3  _S889 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S883.value;
    float probability_4 = 1.0f;
    uint n_7 = 0U;
    for(;;)
    {
        uint4  _S890 = (fcptLightNode((n_7)));
        if((_S890.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S891 = (fcptLightSecond((n_7)));
        uint _S892 = n_7 + 1U;
        LightNode _S893 = (fcptLightBounds((_S892)));
        LightNode _S894 = (fcptLightBounds((_S891)));
        uint _S895 = pickChild(_S893, _S894, origin_4, _S888, &pick_1, &probability_4);
        bool _S896 = _S895 > 1U;
        if(_S896)
        {
            return sample_0;
        }
        bool _S897 = _S895 == 1U;
        uint _S898 = _slang_select(_S897, _S891,_S892);
        n_7 = _S898;
    }
    bool _S899 = n_7 == 0U;
    bool _S900;
    if(_S899)
    {
        LightNode _S901 = (fcptLightBounds((0U)));
        float _S902 = importance(_S901, origin_4, _S888);
        _S900 = !(_S902 > 0.0f);
    }
    else
    {
        _S900 = false;
    }
    if(_S900)
    {
        return sample_0;
    }
    uint4  _S903 = (fcptLightNode((n_7)));
    FKHit _S904 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S905 = (_S903.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S905)
    {
        FKLight _S906 = (fcptLight((_S903.y)));
        if(sided_0)
        {
            float _S907 = sign_0(dot_0(geometry_n_1, _S906.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S907);
            float3  _S908 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S908;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S889;
            lift_n_0 = smooth_n_2;
        }
        bool _S909 = (_S906.variance) == 0.0f;
        if(_S909)
        {
            float3  _S910 = _S906.position - emitter_point_0;
            float3  _S911 = ((((_S910)) * make_float3(rnorm3df(((_S910)).x, ((_S910)).y, ((_S910)).z))));
            (&sample_0)->dir = _S911;
            float3  _S912 = _S906.color * make_float3 (_S906.intensity) / make_float3 (dot_0(_S910, _S910) * probability_4);
            (&sample_0)->radiance = _S912;
            shadow_1 = _S910;
        }
        else
        {
            float3  _S913 = sampleSphere(_S906.position, _S906.variance, emitter_point_0, _S884.value, _S885.value);
            (&sample_0)->dir = _S913;
            float _S914 = sphereDensity(_S906.position, _S906.variance, emitter_point_0);
            float _S915 = probability_4 * _S914;
            (&sample_0)->density = _S915;
            float3  _S916 = pointLightRadiance(_S906.color, _S906.intensity, _S906.variance);
            float3  _S917 = _S916 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S917;
            FKRay _S918 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S919 = raySphere_0(_S906.position, _S906.variance, &_S918, 4.294967296e+09f);
            float3  _S920 = (&sample_0)->dir * make_float3 (_S919);
            shadow_1 = _S920;
        }
        emitter_0 = _S904;
        emitter_point_0 = _S886;
    }
    else
    {
        uint _S921 = _S903.y;
        uint _S922 = (fcptTriangleOffset((_S921)));
        uint _S923 = _S922 + _S903.z;
        Matrix<float, 3, 3>  _S924 = (fcptWorldTriangle((_S921), (_S923)));
        float _S925 = (F32_sqrt((_S884.value)));
        float2  _S926 = make_float2 (_S925 * (1.0f - _S885.value), _S925 * _S885.value);
        float3  _S927 = mul_0(make_float3 (1.0f - _S925, _S926.x, _S926.y), _S924);
        if(sided_0)
        {
            float _S928 = sign_0(dot_0(geometry_n_1, _S927 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S928);
            float3  _S929 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S929;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S930 = !((dot_0(smooth_n_2, _S927 - origin_4)) > 0.0f);
            if(_S930)
            {
                return sample_0;
            }
            emitter_point_0 = _S889;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S926, _S921, _S923, 0U, 0.0f);
        float3  _S931 = _S927 - emitter_point_0;
        float3  _S932 = ((((_S931)) * make_float3(rnorm3df(((_S931)).x, ((_S931)).y, ((_S931)).z))));
        (&sample_0)->dir = _S932;
        float _S933 = solidAngle(probability_4, cross_0(_S924.rows[int(1)] - _S924.rows[int(0)], _S924.rows[int(2)] - _S924.rows[int(0)]), _S931);
        (&sample_0)->density = _S933;
        bool _S934 = (fcptShadowFirst());
        bool _S935 = !_S934;
        if(_S935)
        {
            FKSurface _S936 = (fcptLightSurfaceAt((emitter_1), (_S927), (_S885.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S927 - origin_4))));
            (&sample_0)->random_state = _S936.random_state;
            float3  _S937 = _slang_select(_S936.skip, _S886,_S936.material.emissive);
            float3  _S938 = _S937 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S938;
        }
        shadow_1 = _S931;
        emitter_0 = emitter_1;
        emitter_point_0 = _S927;
    }
    FKHit _S939 = emitter_0;
    float3  _S940 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S885.state, &_S939);
    bool _S941 = (fcptShadowFirst());
    if(_S941)
    {
        _S900 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S900 = false;
    }
    if(_S900)
    {
        _S900 = !all_1(_S940 == _S886);
    }
    else
    {
        _S900 = false;
    }
    if(_S900)
    {
        FKSurface _S942 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S885.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S942.random_state;
        float3  _S943 = _slang_select(_S942.skip, _S886,_S942.material.emissive);
        float3  _S944 = _S943 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S944;
    }
    float3  _S945 = (&sample_0)->radiance * _S940;
    bool _S946 = all_1(_S940 == _S886);
    float3  _S947 = _slang_select(_S946, _S886,_S945);
    (&sample_0)->radiance = _S947;
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
    float _S948 = 1.0f / (1.0f + b_2 / a_6 * (b_2 / a_6));
    bool _S949 = b_2 > 0.0f;
    float _S950 = _slang_select(_S949, _S948,1.0f);
    return _S950;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S951 = vertex_0->none;
    if(_S951)
    {
        return 1.0f;
    }
    uint _S952 = (fcptLightSlot((*hit_1)));
    float _S953 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S952, light_point_1);
    float _S954 = powerHeuristic(vertex_0->pdf, _S953);
    return _S954;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_1, uint lobe_0)
{
    uint2  _S955 = (fcptEnvironmentMapSize());
    bool _S956 = (_S955.x) > 1U;
    bool _S957;
    if(_S956)
    {
        uint2  _S958 = (fcptEnvironmentMapSize());
        _S957 = (_S958.y) > 1U;
    }
    else
    {
        _S957 = false;
    }
    if(_S957)
    {
        float3  _S959 = (fcptEnvMapSample((dir_7), (depth_1), (lobe_0)));
        return _S959;
    }
    float3  _S960 = (fcptAmbient());
    return _S960;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S961 = (fcptEnvironmentCdfSize());
    bool _S962 = (_S961.x) > 1U;
    bool _S963;
    if(_S962)
    {
        uint2  _S964 = (fcptEnvironmentCdfSize());
        _S963 = (_S964.y) > 1U;
    }
    else
    {
        _S963 = false;
    }
    bool _S965 = !_S963;
    if(_S965)
    {
        return false;
    }
    uint2  _S966 = (fcptEnvironmentMapSize());
    bool _S967 = (_S966.x) > 1U;
    if(_S967)
    {
        uint2  _S968 = (fcptEnvironmentMapSize());
        _S963 = (_S968.y) > 1U;
    }
    else
    {
        _S963 = false;
    }
    return _S963;
}

static __device__ float escapeWeight_0(float pdf_1, float3  dir_8)
{
    bool _S969 = pdf_1 <= 0.0f;
    bool _S970;
    if(_S969)
    {
        _S970 = true;
    }
    else
    {
        bool _S971 = environmentMapped_0();
        _S970 = !_S971;
    }
    if(_S970)
    {
        return 1.0f;
    }
    float _S972 = environmentPdf_0(dir_8);
    return pdf_1 / (pdf_1 + _S972);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S973 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S974 = make_int2 ((int)_S973.x, (int)_S973.y);
    uint _S975 = previousSeed_0(_S974);
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
            uint _S976 = previousSeed_0(_S974 + make_int2 (x_16, y_5));
            bool _S977 = _S976 == _S975;
            uint _S978 = _slang_select(_S977, 1U,0U);
            uint count_3 = count_2 + _S978;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S979 = float(count_2 - 1U) / 288.0f;
    bool _S980 = _S975 != 0U;
    float _S981 = _slang_select(_S980, _S979,0.0f);
    fcptStoreDuplication((_S974), (make_uint4 ((F32_asuint((_S981))), 0U, 0U, 0U)));
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
    float _S982 = rgb_to_greyscale(abs_0(f_4));
    return _S982;
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
    float _S983 = resamplingTarget(weight_0);
    bool _S984 = _S983 > 0.0f;
    bool _S985;
    if(_S984)
    {
        _S985 = _S983 < 3.00000000549775576e+38f;
    }
    else
    {
        _S985 = false;
    }
    bool _S986 = !_S985;
    if(_S986)
    {
        return;
    }
    bool _S987 = sel_2->sums;
    if(_S987)
    {
        float3  _S988 = sel_2->color + weight_0;
        sel_2->color = _S988;
        return;
    }
    float _S989 = sel_2->w_sum + _S983;
    sel_2->w_sum = _S989;
    float3  _S990 = sel_2->color + weight_0;
    sel_2->color = _S990;
    Random _S991 = pcg(sel_2->random_state);
    sel_2->random_state = _S991.state;
    bool _S992 = (_S991.value * sel_2->w_sum) <= _S983;
    if(_S992)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S993 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S993;
    float _S994 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S994;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S995 = resamplingTarget((&r_4)->f);
    float _S996 = sel_4.w_sum / _S995;
    bool _S997 = _S995 > 0.0f;
    float _S998 = _slang_select(_S997, _S996,0.0f);
    (&r_4)->w = _S998;
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
    uint2  _S999 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S1000 = make_int2 ((int)_S999.x, (int)_S999.y);
    float3  _S1001 = make_float3 (0.0f);
    FKHit _S1002 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S1003 = Domain_x24init_0(_S1001, _S1001, &_S1002, 0.0f, 0.0f);
    Domain dom_4 = _S1003;
    bool _S1004 = (fcptCurrentDomain((_S1000), (&dom_4)));
    bool _S1005 = !_S1004;
    if(_S1005)
    {
        Reservoir _S1006 = (Reservoir{});
        fcptStoreReservoirPrevious((_S1000), (_S1006), ((&dom_4)->hit));
        return;
    }
    Reservoir _S1007 = (fcptLoadReservoirTemporal((_S1000)));
    uint t_15 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S1007.c;
    for(;;)
    {
        uint _S1008 = (fcptRestirNeighbours());
        if(t_15 < _S1008)
        {
        }
        else
        {
            break;
        }
        int2  _S1009 = partner_0(_S1000, t_15);
        Domain neighbor_0 = _S1003;
        bool _S1010 = (fcptCurrentDomain((_S1009), (&neighbor_0)));
        if(_S1010)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S1011 = (fcptReservoirTemporal((_S1009), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S1011.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    float _S1012 = _S1007.c / (F32_max((count_4), (1.0f)));
    float _S1013 = resamplingTarget(_S1007.f);
    bool _S1014 = count_4 == 0.0f;
    float _S1015 = _slang_select(_S1014, 1.0f,0.0f);
    Selection _S1016 = (Selection{});
    Selection sel_5 = _S1016;
    uint _S1017 = (fcptFrame());
    uint _S1018 = hash(_S1017);
    uint _S1019 = global_invocation_id_2.x;
    uint2  _S1020 = (fcptRenderSize());
    uint _S1021 = stream(_S1018, _S1019 + _S1020.x * global_invocation_id_2.y);
    uint _S1022 = stream(_S1021, 195U);
    (&sel_5)->random_state = _S1022;
    t_15 = 0U;
    float canonical_mis_0 = _S1015;
    for(;;)
    {
        uint _S1023 = (fcptRestirNeighbours());
        if(t_15 < _S1023)
        {
        }
        else
        {
            break;
        }
        int2  _S1024 = partner_0(_S1000, t_15);
        Domain neighbor_dom_0 = _S1003;
        bool _S1025 = (fcptCurrentDomain((_S1024), (&neighbor_dom_0)));
        if(_S1025)
        {
            Reservoir _S1026 = (fcptLoadReservoirTemporal((_S1024)));
            uint4  _S1027 = (fcptShiftData((_S1024), (t_15)));
            float4  _S1028 = asfloat_0(_S1027);
            uint4  _S1029 = (fcptShiftData((_S1000), (t_15)));
            float4  _S1030 = asfloat_0(_S1029);
            float _S1031 = pairShare(_S1026.c, _S1012, c_sum_1);
            bool _S1032 = _S1013 > 0.0f;
            float canonical_mis_1;
            if(_S1032)
            {
                float _S1033 = resamplingTarget(float3 {_S1030.x, _S1030.y, _S1030.z});
                float _S1034 = canonicalWeight(_S1031, _S1012, _S1013, _S1026.c, _S1033);
                float canonical_mis_2 = canonical_mis_0 + _S1034;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S1035 = float3 {_S1028.x, _S1028.y, _S1028.z};
            Shift _S1036 = Shift_x24init_0(_S1035, _S1028.w);
            float _S1037 = resamplingTarget(_S1026.f);
            float _S1038 = resamplingTarget(_S1035);
            float _S1039 = neighborWeight(_S1031, _S1026.c, _S1037, _S1012, _S1038);
            offerShifted(&sel_5, _S1026, _S1036, _S1039);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_17 = t_15 + 1U;
        t_15 = t_17;
    }
    offerShifted(&sel_5, _S1007, Shift_x24init_0(_S1007.f, 1.0f), canonical_mis_0);
    Reservoir _S1040 = finalize(sel_5, c_sum_1);
    fcptStoreReservoirPrevious((_S1000), (_S1040), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S1000), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S1000), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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

__device__ float confidenceCap(float duplicated_0)
{
    float _S1086 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S1086;
}

__device__ float2  temporalWeights(float c_2, float p_c_1, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S1087 = c_2 * p_c_1;
    float _S1088 = c_t_0 * p_t_0;
    return make_float2 (_S1087 / (_S1087 + c_t_0 * g_previous_0), _S1088 / (_S1088 + c_2 * g_current_0));
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S1089 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S1090 = make_int2 ((int)_S1089.x, (int)_S1089.y);
    float3  _S1091 = make_float3 (0.0f);
    FKHit _S1092 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S1093 = Domain_x24init_0(_S1091, _S1091, &_S1092, 0.0f, 0.0f);
    Domain dom_5 = _S1093;
    bool _S1094 = (fcptCurrentDomain((_S1090), (&dom_5)));
    bool _S1095 = !_S1094;
    if(_S1095)
    {
        Reservoir _S1096 = (Reservoir{});
        fcptStoreReservoirTemporal((_S1090), (_S1096), ((&dom_5)->hit));
        return;
    }
    Reservoir _S1097 = (fcptLoadReservoirInitial((_S1090)));
    bool _S1098 = (fcptTemporalQueued());
    bool _S1099 = (fcptSceneUnchanged());
    bool _S1100;
    if(_S1099)
    {
        _S1100 = true;
    }
    else
    {
        _S1100 = !_S1098;
    }
    int2  _S1101;
    if(_S1100)
    {
        int2  _S1102 = sampleNeighbor_0(_S1090, _S1097.seed);
        _S1101 = _S1102;
    }
    else
    {
        int2  _S1103 = (fcptLoadTemporalNeighbor((_S1090)));
        _S1101 = _S1103;
    }
    bool _S1104 = (_S1101.x) >= int(0);
    Reservoir r_5;
    if(_S1104)
    {
        Reservoir _S1105 = (fcptLoadReservoirPrevious((_S1101)));
        uint4  _S1106 = (fcptDuplication((_S1101)));
        float _S1107 = (U32_asfloat((_S1106.x)));
        uint _S1108 = (fcptRestirDecorrelation());
        bool _S1109 = _S1108 == 1U;
        float _S1110 = _slang_select(_S1109, _S1107,0.0f);
        float _S1111 = confidenceCap(_S1110);
        float _S1112 = (F32_min((_S1105.c), (_S1111)));
        bool _S1113 = (fcptSceneUnchanged());
        float4  _S1114 = make_float4 (_S1105.f.x, _S1105.f.y, _S1105.f.z, 1.0f);
        bool _S1115 = !_S1113;
        if(_S1115)
        {
            _S1100 = _S1098;
        }
        else
        {
            _S1100 = false;
        }
        float4  to_current_0;
        if(_S1100)
        {
            uint4  _S1116 = (fcptTemporalShift((_S1090), (0U)));
            float4  _S1117 = asfloat_0(_S1116);
            to_current_0 = _S1117;
        }
        else
        {
            if(_S1115)
            {
                Shift _S1118 = temporalShiftAt_0(_S1090, _S1101, 0U);
                float4  _S1119 = make_float4 (_S1118.f.x, _S1118.f.y, _S1118.f.z, _S1118.jac);
                to_current_0 = _S1119;
            }
            else
            {
                to_current_0 = _S1114;
            }
        }
        Domain own_1 = _S1093;
        if(_S1113)
        {
            _S1100 = true;
        }
        else
        {
            bool _S1120 = (fcptPreviousScenes());
            bool _S1121 = !_S1120;
            if(_S1121)
            {
                _S1100 = (_S1097.w) > 0.0f;
            }
            else
            {
                _S1100 = false;
            }
            if(_S1100)
            {
                bool _S1122 = (fcptStoredDomainInitial((_S1090), (_S1097.seed), (&own_1)));
                _S1100 = _S1122;
            }
            else
            {
                _S1100 = false;
            }
            if(_S1100)
            {
                Domain _S1123 = (fcptPreviousDomain((_S1101), (_S1097.seed)));
                Domain _S1124 = _S1123;
                Domain _S1125 = own_1;
                bool _S1126 = sameDomain_0(&_S1124, &_S1125);
                _S1100 = _S1126;
            }
            else
            {
                _S1100 = false;
            }
        }
        float4  _S1127 = make_float4 (_S1097.f.x, _S1097.f.y, _S1097.f.z, 1.0f);
        bool _S1128 = !_S1100;
        if(_S1128)
        {
            _S1100 = _S1098;
        }
        else
        {
            _S1100 = false;
        }
        float4  to_previous_0;
        if(_S1100)
        {
            uint4  _S1129 = (fcptTemporalShift((_S1090), (1U)));
            float4  _S1130 = asfloat_0(_S1129);
            to_previous_0 = _S1130;
        }
        else
        {
            if(_S1128)
            {
                Shift _S1131 = temporalShiftAt_0(_S1090, _S1101, 1U);
                float4  _S1132 = make_float4 (_S1131.f.x, _S1131.f.y, _S1131.f.z, _S1131.jac);
                to_previous_0 = _S1132;
            }
            else
            {
                to_previous_0 = _S1127;
            }
        }
        float _S1133 = resamplingTarget(_S1097.f);
        float _S1134 = resamplingTarget(_S1105.f);
        Selection _S1135 = (Selection{});
        Selection sel_6 = _S1135;
        uint _S1136 = (fcptFrame());
        uint _S1137 = hash(_S1136);
        uint _S1138 = global_invocation_id_7.x;
        uint2  _S1139 = (fcptRenderSize());
        uint _S1140 = stream(_S1137, _S1138 + _S1139.x * global_invocation_id_7.y);
        uint _S1141 = stream(_S1140, 194U);
        (&sel_6)->random_state = _S1141;
        float4  _S1142 = to_previous_0;
        float _S1143 = resamplingTarget(float3 {_S1142.x, _S1142.y, _S1142.z});
        float4  _S1144 = to_current_0;
        float3  _S1145 = float3 {_S1144.x, _S1144.y, _S1144.z};
        float _S1146 = resamplingTarget(_S1145);
        float2  _S1147 = temporalWeights(_S1097.c, _S1133, _S1112, _S1134, _S1143, _S1146);
        offerShifted(&sel_6, _S1097, Shift_x24init_0(_S1097.f, 1.0f), _S1147.x);
        offerShifted(&sel_6, _S1105, Shift_x24init_0(_S1145, to_current_0.w), _S1147.y);
        Reservoir _S1148 = finalize(sel_6, _S1097.c + _S1112);
        r_5 = _S1148;
    }
    else
    {
        r_5 = _S1097;
    }
    fcptStoreReservoirTemporal((_S1090), (r_5), ((&dom_5)->hit));
    return;
}

__device__ uint noiseOrigin(uint2  p_14, uint k_1)
{
    uint _S1149 = ((p_14.x) >> 11U) | (((p_14.y) >> 11U) << 4U);
    uint2  _S1150 = noiseOffset(8192U + (k_1 >> 10U) + (_S1149 << 20U));
    uint2  _S1151 = (p_14 + _S1150) & make_uint2 (2047U);
    return ((_S1151.x) | ((_S1151.y) << 11U)) | ((k_1 & 1023U) << 22U);
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1152 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1152 << offset_1))) | ((newbits_0 & _S1152) << offset_1);
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S1153 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S1154 = make_int2 ((int)_S1153.x, (int)_S1153.y);
    float3  _S1155 = make_float3 (0.0f);
    float2  _S1156 = make_float2 (0.0f);
    FKHit _S1157 = Hit_x24init_0(_S1156, 0U, 0U, 0U, 0.0f);
    Domain _S1158 = Domain_x24init_0(_S1155, _S1155, &_S1157, 0.0f, 0.0f);
    Domain dom_6 = _S1158;
    bool _S1159 = (fcptCurrentDomain((_S1154), (&dom_6)));
    bool _S1160 = !_S1159;
    if(_S1160)
    {
        Reservoir _S1161 = (Reservoir{});
        fcptStoreReservoirInitial((_S1154), (_S1161), ((&dom_6)->hit));
        return;
    }
    uint _S1162 = (fcptFrame());
    uint _S1163 = hash(_S1162);
    uint _S1164 = global_invocation_id_8.x;
    uint2  _S1165 = (fcptRenderSize());
    uint _S1166 = global_invocation_id_8.y;
    uint _S1167 = stream(_S1163, _S1164 + _S1165.x * _S1166);
    uint2  _S1168 = (fcptRenderSize());
    uint _S1169 = stream(_S1164 + _S1168.x * _S1166, 512U);
    Selection _S1170 = (Selection{});
    Selection initial_0 = _S1170;
    uint _S1171 = stream(_S1167, 193U);
    (&initial_0)->random_state = _S1171;
    bool _S1172 = (fcptRestirUsed());
    bool _S1173 = !_S1172;
    (&initial_0)->sums = _S1173;
    uint _S1174 = stream(_S1167, 0U);
    (&(&initial_0)->r)->seed = _S1174;
    FKHit _S1175 = Hit_x24init_0(_S1156, 4294967295U, 0U, 0U, 0.0f);
    uint _S1176 = (fcptSamples());
    float _S1177 = 1.0f / float(_S1176);
    FKHit hit_2 = _S1175;
    uint i_18 = 0U;
    float3  seen_1 = _S1155;
    for(;;)
    {
        uint _S1178 = (fcptSamples());
        if(i_18 < _S1178)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1179 = (Reservoir{});
        Reservoir r_6 = _S1179;
        uint _S1180 = (fcptFrame());
        uint _S1181 = (fcptSamples());
        uint _S1182 = _S1180 * _S1181 + i_18;
        uint _S1183 = noiseOrigin(_S1153, _S1182);
        (&r_6)->seed = _S1183;
        uint _S1184 = insertBits_0(0U, 1U, 24U, 1U);
        uint _S1185 = insertBits_0(_S1184, (_S1169 + _S1182 * 2654435769U) >> 25U, 25U, 7U);
        (&r_6)->path = _S1185;
        Domain path_0 = _S1158;
        bool _S1186 = (fcptStoredDomainInitial((_S1154), ((&r_6)->seed), (&path_0)));
        bool _S1187 = !_S1186;
        if(_S1187)
        {
            float3  _S1188 = (fcptMissed((_S1154), (path_0), (_S1177)));
            float3  seen_2 = seen_1 + _S1188;
            seen_1 = seen_2;
            uint i_19 = i_18 + 1U;
            i_18 = i_19;
            continue;
        }
        Domain _S1189 = path_0;
        Reservoir _S1190 = r_6;
        Shift _S1191 = passWalk_0(&_S1189, &_S1190, false, _S1177, &initial_0);
        bool _S1192 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1192)
        {
            FKHit _S1193 = (&path_0)->hit;
            hit_3 = _S1193;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_19 = i_18 + 1U;
        i_18 = i_19;
    }
    uint _S1194 = (fcptSamples());
    float3  seen_3 = seen_1 + (&initial_0)->glow / make_float3 (float(_S1194));
    if((&initial_0)->sums)
    {
        seen_1 = seen_3 + (&initial_0)->color;
    }
    else
    {
        seen_1 = seen_3;
    }
    fcptAddColor((_S1154), (make_float4 (seen_1.x, seen_1.y, seen_1.z, 1.0f)));
    Reservoir _S1195 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S1154), (_S1195), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_2, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1196;
    (&_S1196)->none = none_0;
    (&_S1196)->pdf = pdf_2;
    (&_S1196)->origin = origin_5;
    (&_S1196)->smooth_n = smooth_n_3;
    (&_S1196)->start = start_6;
    return _S1196;
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
    Vertex _S1197;
    (&_S1197)->rough = rough_0;
    (&_S1197)->lobe = lobe_1;
    (&_S1197)->pdf = pdf_3;
    (&_S1197)->cos = cos_0;
    (&_S1197)->inside = inside_0;
    return _S1197;
}

__device__ uint noiseAddress(uint origin_6, uint bounce_0)
{
    uint2  _S1198 = make_uint2 (origin_6 & 2047U, (origin_6 >> 11U) & 2047U);
    uint2  _S1199 = noiseOffset(64U + bounce_0 * 17U);
    uint2  _S1200 = (_S1198 + _S1199) & make_uint2 (2047U);
    return ((_S1200.x) | ((_S1200.y) << 11U)) | ((origin_6 >> 22U) << 22U);
}

static __device__ float freeFlight_0(float u_1, float sigma_0)
{
    return - (F32_log((1.0f - u_1))) / sigma_0;
}

__device__ float3  pathColor(float3  f_5, float3  weight_1, float wavelength_4)
{
    float3  _S1201;
    if(wavelength_4 > 0.0f)
    {
        float _S1202 = upsample(f_5, wavelength_4);
        _S1201 = weight_1 * make_float3 (_S1202);
    }
    else
    {
        _S1201 = f_5;
    }
    return _S1201;
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

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_1, float distance_2, bool scatters_0)
{
    float3  _S1203 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_2));
    float3  _S1204 = scatter_0 * _S1203 / make_float3 (sigma_1);
    float3  _S1205 = _slang_select(scatters_0, _S1204,_S1203);
    return _S1205;
}

static __device__ bool scatterSampled_0(bool replay_1, uint b_4, uint stop_0, bool varying_0)
{
    bool _S1206 = !replay_1;
    bool _S1207;
    if(_S1206)
    {
        _S1207 = true;
    }
    else
    {
        bool _S1208 = b_4 == stop_0;
        if(_S1208)
        {
            _S1207 = !varying_0;
        }
        else
        {
            _S1207 = false;
        }
    }
    return _S1207;
}

static __device__ uint arrivalLobe_0(uint b_5, uint prev_lobe_0)
{
    bool _S1209 = b_5 > 0U;
    uint _S1210 = _slang_select(_S1209, prev_lobe_0,3U);
    return _S1210;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_2, uint lobe_2, bool surface_4, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1211;
    (&_S1211)->extinction_behind = extinction_behind_0;
    (&_S1211)->extinction_front = extinction_front_0;
    (&_S1211)->fillings = fillings_0;
    (&_S1211)->side = side_0;
    (&_S1211)->depth = depth_2;
    (&_S1211)->lobe = lobe_2;
    (&_S1211)->surface = surface_4;
    (&_S1211)->length = length_2;
    (&_S1211)->width = width_1;
    (&_S1211)->own = *own_2;
    (&_S1211)->fiber = fiber_0;
    return _S1211;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1212 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1212)
    {
        return 0.07957746833562851f;
    }
    float _S1213 = g_0 * g_0;
    return (1.0f - _S1213) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1213 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_8, float3  b_6)
{
    float3  _S1214 = a_8 / b_6;
    float3  _S1215 = make_float3 (0.0f);
    bool3  _S1216 = b_6 == _S1215;
    float3  _S1217 = _slang_select(_S1216, _S1215,_S1214);
    return _S1217;
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_6)
{
    Reservoir candidate_2 = r_7;
    uint _S1218 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1219 = insertBits_0(_S1218, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1219;
    (&candidate_2)->f = f_6;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_4)
{
    Random _S1220 = draw(random_state_4, 11U);
    Random _S1221 = draw(random_state_4, 2147483659U);
    float _S1222 = 1.0f - 2.0f * _S1220.value;
    float _S1223 = (F32_sqrt(((F32_max((1.0f - _S1222 * _S1222), (0.0f))))));
    float _S1224 = 6.28318548202514648f * _S1221.value;
    return make_float3 (_S1223 * (F32_cos((_S1224))), _S1223 * (F32_sin((_S1224))), _S1222);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_5, float * pdf_4)
{
    bool _S1225 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1225)
    {
        *pdf_4 = 0.07957746833562851f;
        float3  _S1226 = isotropic_0(random_state_5);
        return _S1226;
    }
    Random _S1227 = draw(random_state_5, 11U);
    Random _S1228 = draw(random_state_5, 2147483659U);
    float _S1229 = g_1 * g_1;
    float _S1230 = 2.0f * g_1;
    float _S1231 = (1.0f - _S1229) / (1.0f - g_1 + _S1230 * _S1227.value);
    float _S1232 = clamp_1((1.0f + _S1229 - _S1231 * _S1231) / _S1230, -1.0f, 1.0f);
    float _S1233 = (F32_sqrt(((F32_max((1.0f - _S1232 * _S1232), (0.0f))))));
    float _S1234 = 6.28318548202514648f * _S1228.value;
    float _S1235 = phaseHG_0(g_1, _S1232);
    *pdf_4 = _S1235;
    float3  _S1236 = tangentToWorld(make_float3 (_S1233 * (F32_cos((_S1234))), _S1232, _S1233 * (F32_sin((_S1234)))), dir_9);
    float3  _S1237 = ((((_S1236)) * make_float3(rnorm3df(((_S1236)).x, ((_S1236)).y, ((_S1236)).z))));
    return _S1237;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_1, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_1, float velvet_0, float3  toon_2, float dispersion_0, float coat_2, float coat_roughness_0, float coat_ior_0, float3  coat_tint_0, float3  coat_normal_0)
{
    BSDFMaterial _S1238;
    (&_S1238)->albedo = albedo_1;
    (&_S1238)->emissive = emissive_0;
    (&_S1238)->roughness = roughness_0;
    (&_S1238)->metallic = metallic_0;
    (&_S1238)->transmission = transmission_0;
    (&_S1238)->ior = ior_1;
    (&_S1238)->absorption = absorption_0;
    (&_S1238)->specular_tint = specular_tint_0;
    (&_S1238)->specular_level = specular_level_0;
    (&_S1238)->translucent = translucent_0;
    (&_S1238)->sheen = sheen_2;
    (&_S1238)->sheen_roughness = sheen_roughness_0;
    (&_S1238)->anisotropy = anisotropy_0;
    (&_S1238)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1238)->tangent = tangent_1;
    (&_S1238)->velvet = velvet_0;
    (&_S1238)->toon = toon_2;
    (&_S1238)->dispersion = dispersion_0;
    (&_S1238)->coat = coat_2;
    (&_S1238)->coat_roughness = coat_roughness_0;
    (&_S1238)->coat_ior = coat_ior_0;
    (&_S1238)->coat_tint = coat_tint_0;
    (&_S1238)->coat_normal = coat_normal_0;
    return _S1238;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1239;
    (&_S1239)->scatter = scatter_1;
    (&_S1239)->extinction = extinction_1;
    (&_S1239)->g = g_2;
    return _S1239;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_15, bool skip_0, uint random_state_6, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1240;
    (&_S1240)->smooth_n = smooth_n_4;
    (&_S1240)->geometry_n = geometry_n_2;
    (&_S1240)->geometry_offset = geometry_offset_2;
    (&_S1240)->material = *material_15;
    (&_S1240)->skip = skip_0;
    (&_S1240)->random_state = random_state_6;
    (&_S1240)->coverage = coverage_0;
    (&_S1240)->encloses = encloses_0;
    (&_S1240)->volume = *volume_0;
    (&_S1240)->fills = fills_0;
    (&_S1240)->hair = hair_0;
    return _S1240;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S1241 = (&surface_5->material)->emissive;
    float3  _S1242 = make_float3 (0.0f);
    bool _S1243 = !top_0;
    float3  _S1244 = _slang_select(_S1243, _S1242,_S1241);
    (&(&lower_0)->material)->emissive = _S1244;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_2)
{
    float _S1245 = surface_6->coverage;
    bool _S1246 = u_2 < _S1245;
    if(_S1246)
    {
        return *surface_6;
    }
    float3  _S1247 = make_float3 (0.0f);
    float3  _S1248 = make_float3 (1.0f);
    BSDFMaterial _S1249 = Material_x24init_0(_S1247, _S1247, 0.0f, 0.0f, 0.0f, 0.0f, _S1247, _S1248, 1.0f, _S1247, _S1247, 0.5f, 0.0f, 0.0f, _S1247, 0.0f, _S1247, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, _S1248, _S1247);
    BSDFMaterial material_16 = _S1249;
    (&material_16)->albedo = _S1248;
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
    bool _S1250 = transmission_1 > 0.0f;
    bool _S1251;
    if(_S1250)
    {
        _S1251 = true;
    }
    else
    {
        _S1251 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1252;
    if(_S1251)
    {
        _S1252 = 1.0f;
    }
    else
    {
        _S1252 = -1.0f;
    }
    return _S1252;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_8)
{
    return (dot_0(dir_10, n_8)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_11)
{
    float3  _S1253 = surface_7->geometry_n;
    float _S1254 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_11);
    FKSurface faced_0 = *surface_7;
    float3  _S1255 = surface_7->smooth_n * make_float3 (_S1254);
    (&faced_0)->smooth_n = _S1255;
    float3  _S1256 = _S1253 * make_float3 (_S1254);
    (&faced_0)->geometry_n = _S1256;
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
    float3  _S1257 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1257));
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
    bool _S1258;
    if(open_0)
    {
        _S1258 = prev_rough_0;
    }
    else
    {
        _S1258 = false;
    }
    if(_S1258)
    {
        _S1258 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S1258 = false;
    }
    return _S1258;
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
        uint _S1261 = (low_1 + high_1 + 1U) / 2U;
        bool _S1262 = (WAVELENGTH_CDF_0[_S1261]) <= u_3;
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
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_3 - WAVELENGTH_CDF_0[_S1264]) / _S1265), _S1265 / 0.00499999988824129f);
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
    uint state_3 = random_state_8;
    float3  _S1322 = sampleHalfVector(v_10, coat_frame_4.normal, coat_frame_4.alpha, AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f)), &state_3, 1U);
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
    uint state_4 = random_state_9;
    float _S1327 = material_20.roughness;
    float _S1328 = _S1327 * _S1327;
    AnisotropicFrame _S1329 = anisotropicFrame(material_20, _S1326);
    float3  _S1330 = sampleHalfVector(_S1324, _S1326, _S1328, _S1329, &state_4, 0U);
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

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_6, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_23, float eta_i_6, float eta_o_5, bool competing_1, Facets * facets_3)
{
    float3  _S1357 = light_2->dir;
    bool _S1358 = (dot_0(geometry_n_4, - in_dir_6) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
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

__device__ float3  skyBSDF(float3  in_dir_7, float3  dir_14, FKSurface surface_10, BSDFMaterial material_24, float2  eta_3, bool is_inside_5, Facets facets_4, float pdf_5)
{
    FKSurface _S1364 = surface_10;
    BSDFMaterial _S1365 = material_24;
    Facets _S1366 = facets_4;
    FixedArray<float3 , 6>  terms_3;
    FixedArray<float, 6>  pdfs_5;
    float3  _S1367 = skyLobes_0(in_dir_7, dir_14, &_S1364, &_S1365, eta_3, is_inside_5, &_S1366, pdf_5, &terms_3, &pdfs_5);
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

__device__ __forceinline__ SampleBSDF diffuseSample(float u_4, float3  n_i_13, float n_i_dot_v_4, BSDFMaterial material_26, Weights w_16, uint random_state_13)
{
    float3  _S1390 = make_float3 (1.0f);
    SampleBSDF _S1391 = SampleBSDF_x24init_0(_S1390, _S1390, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1391;
    Random _S1392 = draw(random_state_13, 3U);
    Random _S1393 = draw(random_state_13, 2147483651U);
    (&sample_3)->random_state = _S1393.state;
    float3  _S1394 = sampleCosWeightedHemisphere(_S1392.value, _S1393.value);
    float _S1395 = translucentShare(material_26);
    bool _S1396 = u_4 < (w_16.p_diffuse * _S1395);
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

__device__ bool withinInverseFootprint(float pdf_7, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1468 = pdf_7 > 0.0f;
    bool _S1469;
    if(_S1468)
    {
        if(diffuse_0)
        {
            _S1469 = true;
        }
        else
        {
            _S1469 = (pdf_7 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1469 = false;
    }
    return _S1469;
}

__device__ bool roughLobe(float pdf_8, bool diffuse_1, float roughness_1)
{
    bool _S1470 = pdf_8 > 0.0f;
    bool _S1471;
    if(_S1470)
    {
        if(diffuse_1)
        {
            _S1471 = true;
        }
        else
        {
            _S1471 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1471 = false;
    }
    return _S1471;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1472 = layers_0 > 1U;
    bool _S1473;
    if(_S1472)
    {
        _S1473 = refracting_0 != passed_0;
    }
    else
    {
        _S1473 = false;
    }
    return _S1473;
}

static __device__ float widened_0(float spread_1, float pdf_9, bool delta_0)
{
    float _S1474 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_9))))), (3.14159274101257324f)));
    bool _S1475 = !delta_0;
    float _S1476 = _slang_select(_S1475, _S1474,0.0f);
    return spread_1 + _S1476;
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
    bool _S1477;
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
    int _S1478;
    Shift ended_0;
    float density_3;
    float spread_3;
    float width_4;
    float sky_pdf_1;
    float spread_4;
    float width_5;
    uint b_8;
    float3  _S1479 = make_float3 (0.0f);
    Shift _S1480 = Shift_x24init_0(_S1479, 0.0f);
    uint _S1481 = r_8->path;
    uint _S1482 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1483 = extractBits_0(_S1481, 5U, 5U);
    uint _S1484 = extractBits_0(_S1481, 10U, 2U);
    uint _S1485 = extractBits_0(_S1481, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1486 = _S1485 >= 3U;
        uint _S1487 = _slang_select(_S1486, 1U,0U);
        uint _S1488 = _S1482 + _S1487;
        uint _S1489 = (fcptMaxBounces());
        passes_0 = _S1488 > _S1489;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1480;
    }
    uint _S1490 = _S1483 - 1U;
    bool _S1491 = _S1485 == 3U;
    uint _S1492 = _slang_select(_S1491, 1U,0U);
    uint _S1493 = _S1482 + _S1492;
    bool _S1494 = _S1484 == 0U;
    uint _S1495 = _slang_select(_S1494, _S1493,_S1490);
    FKHit _S1496 = (fcptReservoirHit((*r_8)));
    float3  _S1497 = dom_7->x0;
    float3  _S1498 = dom_7->x1 - dom_7->x0;
    float3  _S1499 = ((((_S1498)) * make_float3(rnorm3df(((_S1498)).x, ((_S1498)).y, ((_S1498)).z))));
    FKRay _S1500 = Ray_x24init_0(dom_7->x1, _S1499);
    FKRay ray_2 = _S1500;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1479;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_2 = throughput_3;
    float3  glowed_0 = _S1479;
    float3  extinction_in_0 = _S1479;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1501 = dom_7->spread;
    float _S1502 = dom_7->width;
    float _S1503 = length_0(_S1498);
    NEEVertex _S1504 = NEEVertex_x24init_0(true, 0.0f, _S1479, _S1479, _S1479);
    NEEVertex nee_vertex_0 = _S1504;
    Vertex _S1505 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1505;
    Reservoir _S1506 = (Reservoir{});
    Reservoir chain_0 = _S1506;
    uint _S1507 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    uint _S1508 = extractBits_0(_S1481, 24U, 8U);
    uint _S1509 = insertBits_0(0U, _S1508, 24U, 8U);
    (&chain_0)->path = _S1509;
    (&ray_2)->origin = _S1497;
    (&hit_4)->distance = _S1503;
    FKMedium _S1510 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1511 = filling_2;
    bool _S1512 = (fcptVaryingUsed());
    uint _S1513 = _slang_select(_S1512, _S1511,4294967295U);
    filling_2 = _S1513;
    scatter_in_0 = _S1510.scatter;
    extinction_in_0 = _S1510.extinction;
    g_in_0 = _S1510.g;
    Reservoir _S1514 = chain_0;
    uint _S1515 = filling_2;
    for(;;)
    {
        bool _S1516 = (fcptVaryingUsed());
        if(_S1516)
        {
            passes_0 = _S1515 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1517 = (fcptMajorant((_S1515)));
            spread_2 = _S1517;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1495;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1484 == 1U;
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
            ended_0 = _S1480;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1501;
            width_3 = _S1502;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_7 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1518 = (&prev_0)->rough;
        if(_S1518)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1519 = stream(_S1507, 384U);
        uint tracking_0 = _S1519;
        weight_2 = throughput_3;
        glowed_0 = _S1479;
        b_7 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        wavelength_8 = _S1501;
        width_3 = _S1502;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1478 = int(1);
                break;
            }
            uint _S1520 = noiseAddress(_S1507, b_7);
            Random _S1521 = draw(_S1520, 10U);
            float _S1522 = freeFlight_0(_S1521.value, spread_2);
            if(passes_0)
            {
                float3  _S1523 = (&ray_2)->origin;
                float3  _S1524 = (&ray_2)->unit_direction;
                float _S1525 = (&hit_4)->distance;
                bool _S1526 = b_7 == 4294967295U;
                uint _S1527 = _slang_select(_S1526, 0U,b_7);
                uint _S1528 = (&prev_0)->lobe;
                uint _S1529 = _slang_select(_S1526, 3U,_S1528);
                float _S1530 = (fcptTrackMedium((_S1515), (_S1523), (_S1524), (_S1525), (&tracking_0), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1527), (_S1529), (_S1526)));
                threshold_2 = _S1530;
            }
            else
            {
                threshold_2 = _S1522;
            }
            bool _S1531 = !(threshold_2 < ((&hit_4)->distance));
            if(_S1531)
            {
                _S1478 = int(1);
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
                float3  _S1532 = pathColor(throughput_2 * glowed_0, throughput_3, 0.0f);
                float3  _S1533 = _S1532 / make_float3 (density_2);
                float3  _S1534 = sel_7->glow + _S1533;
                sel_7->glow = _S1534;
            }
            else
            {
            }
            glowed_0 = _S1479;
            uint b_9 = b_7 + 1U;
            float3  _S1535 = (&ray_2)->origin + make_float3 (threshold_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1535;
            float3  _S1536 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, threshold_2, true);
            float3  _S1537 = weight_2;
            float _S1538 = upsample(weight_2, 0.0f);
            float3  _S1539 = make_float3 (_S1538);
            float3  _S1540 = _slang_select(false, _S1539,_S1537);
            float3  _S1541 = _slang_select(passes_0, _S1540,_S1536);
            float3  throughput_4 = throughput_2 * _S1541;
            uint _S1542 = stream(_S1507, b_9 + 320U);
            tracking_0 = _S1542;
            weight_2 = throughput_3;
            float width_6 = width_3 + wavelength_8 * threshold_2;
            float _S1543 = wavelength_8 + 3.14159274101257324f;
            bool _S1544 = scatterSampled_0(replay_2, b_9, _S1495, passes_0);
            TreeSample _S1545 = TreeSample_x24init_0(_S1479, _S1479, 0.0f, 0U);
            if(_S1544)
            {
                float3  _S1546 = (&ray_2)->origin;
                float3  _S1547 = (&ray_2)->unit_direction;
                float3  _S1548 = (&ray_2)->unit_direction;
                uint _S1549 = noiseAddress(_S1507, b_9);
                float3  _S1550 = extinction_in_0;
                float3  _S1551 = extinction_in_0;
                uint2  _S1552 = make_uint2 (_S1515);
                float3  _S1553 = (&ray_2)->unit_direction;
                uint _S1554 = arrivalLobe_0(b_9, (&prev_0)->lobe);
                FKHit _S1555 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1556 = _S1555;
                ShadowContext _S1557 = ShadowContext_x24init_0(_S1550, _S1551, _S1552, _S1553, b_9, _S1554, false, threshold_2, width_6, &_S1556, false);
                ShadowContext _S1558 = _S1557;
                TreeSample _S1559 = sampleLightTree_0(_S1546, _S1547, _S1548, 0.0f, true, _S1549, &_S1558);
                light_3 = _S1559;
            }
            else
            {
                light_3 = _S1545;
            }
            float _S1560 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1561 = (fcptMaxBounces());
            bool _S1562 = b_9 < _S1561;
            if(_S1562)
            {
                is_inside_6 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_6 = false;
            }
            float _S1563 = _slang_select(is_inside_6, _S1560,0.0f);
            float3  _S1564 = throughput_4 * light_3.radiance;
            float _S1565 = powerHeuristic(light_3.density, _S1563);
            float3  _S1566 = pathColor(_S1564 * make_float3 (_S1560 * _S1565), throughput_3, 0.0f);
            float3  _S1567 = _slang_select(_S1544, _S1566,_S1479);
            if(replay_2)
            {
                viewed_0 = b_9 == _S1495;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1568 = _S1484 == 2U;
                if(_S1568)
                {
                    float _S1569 = resamplingTarget(_S1567);
                    passes_0 = _S1569 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1570 = Shift_x24init_0(_S1567, 1.0f);
                    _S1478 = int(0);
                    ended_0 = _S1570;
                    spread_2 = _S1543;
                    threshold_2 = width_6;
                    spectral_weight_0 = throughput_4;
                    layer_0 = b_9;
                    break;
                }
                _S1478 = int(0);
                ended_0 = _S1480;
                spread_2 = _S1543;
                threshold_2 = width_6;
                spectral_weight_0 = throughput_4;
                layer_0 = b_9;
                break;
            }
            bool _S1571 = !replay_2;
            if(_S1571)
            {
                Reservoir candidate_3 = _S1514;
                uint _S1572 = extractBits_0(_S1514.path, 24U, 8U);
                uint _S1573 = insertBits_0(0U, _S1572, 24U, 8U);
                uint _S1574 = extractBits_0(_S1514.path, 10U, 2U);
                bool _S1575 = _S1574 == 1U;
                if(_S1575)
                {
                    float3  _S1576 = safeDivide(_S1567, _S1479);
                    (&candidate_3)->radiance = _S1576;
                }
                else
                {
                    uint _S1577 = insertBits_0(_S1573, b_9 + 1U, 5U, 5U);
                    uint _S1578 = insertBits_0(_S1577, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1578;
                }
                Reservoir _S1579 = withEnd(candidate_3, 0U, b_9, _S1567);
                offer(sel_7, _S1579, _S1567 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1580 = survivalProbability(abs_0(throughput_4), density_2);
                uint _S1581 = noiseAddress(_S1507, b_9);
                Random _S1582 = draw(_S1581, 8U);
                bool _S1583 = _S1580 < (_S1582.value);
                if(_S1583)
                {
                    _S1477 = true;
                }
                else
                {
                    uint _S1584 = (fcptMaxBounces());
                    _S1477 = b_9 >= _S1584;
                }
                if(_S1477)
                {
                    _S1478 = int(0);
                    ended_0 = _S1480;
                    spread_2 = _S1543;
                    threshold_2 = width_6;
                    spectral_weight_0 = throughput_4;
                    layer_0 = b_9;
                    break;
                }
                float _S1585 = density_2 * _S1580;
                density_2 = _S1585;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1586 = noiseAddress(_S1507, b_9);
            float3  _S1587 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1586, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1587;
            NEEVertex _S1588 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1479, (&ray_2)->origin);
            nee_vertex_0 = _S1588;
            Vertex _S1589 = scatteredVertex_0(false);
            prev_0 = _S1589;
            float _S1590 = (&prev_0)->pdf;
            FKRay _S1591 = ray_2;
            FKHit _S1592 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1593 = (fcptTraverseInstanceBVH((_S1591), (true), (4.294967296e+09f), (false), (_S1592), (false)));
            hit_4 = _S1593;
            b_7 = b_9;
            throughput_2 = throughput_4;
            wavelength_8 = _S1543;
            width_3 = width_6;
            sky_pdf_0 = _S1590;
        }
        if(_S1478 != int(1))
        {
            width_3 = threshold_2;
            throughput_2 = spectral_weight_0;
            b_7 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1480;
        spread_2 = wavelength_8;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1594 = b_7 == 4294967295U;
    bool _S1595 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1595)
    {
        bool _S1596 = !(&nee_vertex_0)->none;
        float _S1597 = _slang_select(_S1596, sky_pdf_0,0.0f);
        float _S1598 = escapeWeight_0(_S1597, (&ray_2)->unit_direction);
        float3  _S1599 = environment_0((&ray_2)->unit_direction, b_7, (&prev_0)->lobe);
        float3  _S1600 = pathColor(throughput_2 * _S1599, throughput_3, 0.0f);
        if(replay_2)
        {
            bool _S1601 = b_7 == _S1495;
            if(_S1601)
            {
                passes_0 = _S1484 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1600 * make_float3 (_S1598) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1494)
            {
                passes_0 = _S1491;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_7 == _S1482;
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
                return Shift_x24init_0(_S1600 * make_float3 (_S1598), 1.0f);
            }
            return _S1480;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1602 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1603 = _S1602 == 1U;
        if(_S1603)
        {
            uint _S1604 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1605 = _S1604 == b_7;
            float _S1606 = _slang_select(_S1605, 1.0f,_S1598);
            float3  _S1607 = safeDivide(_S1600 * make_float3 (_S1606), _S1479);
            (&candidate_4)->radiance = _S1607;
        }
        else
        {
            bool _S1608 = (&prev_0)->rough;
            if(_S1608)
            {
                uint _S1609 = insertBits_0(_S1509, b_7 + 1U, 5U, 5U);
                uint _S1610 = insertBits_0(_S1609, 3U, 10U, 2U);
                uint _S1611 = insertBits_0(_S1610, (&prev_0)->lobe, 15U, 3U);
                bool _S1612 = (&prev_0)->inside;
                uint _S1613 = _slang_select(_S1612, 1U,0U);
                uint _S1614 = insertBits_0(_S1611, _S1613, 22U, 1U);
                (&candidate_4)->path = _S1614;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1615 = _S1600 * make_float3 (_S1598);
        Reservoir _S1616 = withEnd(candidate_4, 3U, b_7, _S1615);
        offer(sel_7, _S1616, _S1615 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1480;
    }
    float3  _S1617 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1617;
    bool _S1618 = (fcptVaryingUsed());
    if(_S1618)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1619 = !replay_2;
        if(_S1619)
        {
            float3  _S1620 = pathColor(throughput_2 * glowed_0, throughput_3, 0.0f);
            float3  _S1621 = _S1620 / make_float3 (density_2);
            float3  _S1622 = sel_7->glow + _S1621;
            sel_7->glow = _S1622;
        }
        float3  _S1623 = throughput_2 * weight_2;
        throughput_2 = _S1623;
    }
    else
    {
        float3  _S1624 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1625 = throughput_2 * _S1624;
        throughput_2 = _S1625;
    }
    float _S1626 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1627 = b_7 + 1U;
    b_7 = _S1627;
    layer_0 = 0U;
    width_3 = _S1626;
    passes_0 = false;
    wavelength_8 = 0.0f;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_6 = false;
    spectral_weight_0 = throughput_3;
    float3  chain_throughput_0 = _S1479;
    float3  reconnection_0 = _S1479;
    viewed_0 = _S1594;
    for(;;)
    {
        bool _S1628 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1477 = _S1484 == 1U;
        }
        else
        {
            _S1477 = false;
        }
        bool _S1629;
        if(_S1477)
        {
            _S1629 = b_7 == _S1483;
        }
        else
        {
            _S1629 = false;
        }
        bool _S1630;
        if(_S1629)
        {
            bool _S1631 = ((&hit_4)->instance_index) != (_S1496.instance_index);
            if(_S1631)
            {
                _S1630 = true;
            }
            else
            {
                _S1630 = ((&hit_4)->triangle_index) != (_S1496.triangle_index);
            }
        }
        else
        {
            _S1630 = false;
        }
        if(_S1630)
        {
            return _S1480;
        }
        FKMedium _S1632 = Medium_x24init_0(_S1479, _S1479, 0.0f);
        BSDFMaterial _S1633 = Material_x24init_0(_S1479, _S1479, 0.0f, 0.0f, 0.0f, 0.0f, _S1479, throughput_3, 1.0f, _S1479, _S1479, 0.5f, 0.0f, 0.0f, _S1479, 0.0f, _S1479, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, throughput_3, _S1479);
        FKMedium _S1634 = _S1632;
        FKSurface _S1635 = Surface_x24init_0(_S1479, _S1479, 0.0f, &_S1633, false, 0U, 1.0f, false, &_S1634, 4294967295U, _S1479);
        bool _S1636 = !_S1628;
        bool scatter_2;
        bool is_inside_7;
        float geometry_density_2;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S1636)
        {
            uint _S1637 = noiseAddress(_S1507, b_7);
            uint _S1638 = arrivalLobe_0(b_7, (&prev_0)->lobe);
            FKSurface _S1639 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1637), (width_3), (layer_0), (b_7), (_S1638), ((&ray_2)->unit_direction)));
            bool _S1640 = !passes_0;
            FKSurface _S1641 = _S1639;
            FKSurface _S1642 = emitting_0(&_S1641, _S1640);
            uint _S1643 = noiseAddress(_S1507, b_7);
            Random _S1644 = draw(_S1643, 9U);
            FKSurface _S1645 = _S1642;
            FKSurface _S1646 = uncovered_0(&_S1645, _S1644.value);
            float _S1647 = facingSign(_S1646.material.transmission, _S1646.geometry_n, (&ray_2)->unit_direction);
            bool _S1648 = _S1647 < 0.0f;
            bool _S1649 = (_S1646.material.transmission) > 0.0f;
            if(_S1649)
            {
                bool _S1650 = arrivesBehind_0((&ray_2)->unit_direction, _S1646.geometry_n);
                scatter_2 = _S1650;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1651 = _S1646;
            FKSurface _S1652 = facingRay_0(&_S1651, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1653 = arrivesBehind_0((&ray_2)->unit_direction, _S1652.geometry_n);
                is_inside_7 = _S1653;
            }
            else
            {
                is_inside_7 = scatter_2;
            }
            if(is_inside_7)
            {
                float _S1654 = (&hit_4)->distance;
                float _S1655 = upsample(_S1652.material.absorption, wavelength_8);
                float3  _S1656 = make_float3 (_S1655);
                bool _S1657 = wavelength_8 > 0.0f;
                float3  _S1658 = _slang_select(_S1657, _S1656,_S1652.material.absorption);
                float3  _S1659 = beerLambert(_S1654, _S1658);
                float3  _S1660 = throughput_2 * _S1659;
                throughput_5 = _S1660;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1661 = !_S1652.skip;
            float geometry_density_3 = geometryDensity(_S1652.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1662 = b_7 == _S1627;
            if(_S1662)
            {
                float _S1663 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1663;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1664 = geometry_density_2;
            scatter_2 = _S1661;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1664;
            surface_12 = _S1652;
            turned_1 = _S1648;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_12 = _S1635;
            throughput_5 = throughput_2;
            is_inside_7 = is_inside_6;
        }
        bool _S1665 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1666 = surface_12;
        float _S1667 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        bool _S1668 = (fcptDispersionUsed());
        bool _S1669;
        if(_S1668)
        {
            _S1669 = wavelength_8 == 0.0f;
        }
        else
        {
            _S1669 = false;
        }
        bool _S1670;
        if(_S1669)
        {
            _S1670 = scatter_2;
        }
        else
        {
            _S1670 = false;
        }
        bool _S1671;
        if(_S1670)
        {
            bool _S1672 = dispersive(surface_12.material);
            _S1671 = _S1672;
        }
        else
        {
            _S1671 = false;
        }
        float3  throughput_6;
        if(_S1671)
        {
            uint _S1673 = stream(_S1507, 512U);
            Random _S1674 = pcg(_S1673);
            uint _S1675 = extractBits_0(_S1481, 25U, 7U);
            float _S1676 = (float(_S1675) + _S1674.value) / 128.0f;
            uint _S1677 = extractBits_0(_S1481, 24U, 1U);
            bool _S1678 = _S1677 == 1U;
            float _S1679 = _slang_select(_S1678, _S1676,_S1674.value);
            float2  _S1680 = sampleWavelength(_S1679);
            float wavelength_9 = _S1680.x;
            float3  _S1681 = wavelengthWeights(wavelength_9);
            float3  _S1682 = _S1681 / make_float3 (_S1680.y);
            float _S1683 = upsample(throughput_5, wavelength_9);
            float3  _S1684 = make_float3 (_S1683);
            float _S1685 = upsample(scatter_in_0, wavelength_9);
            float3  _S1686 = make_float3 (_S1685);
            scatter_in_0 = _S1686;
            float _S1687 = upsample(extinction_in_0, wavelength_9);
            float3  _S1688 = make_float3 (_S1687);
            extinction_in_0 = _S1688;
            wavelength_8 = wavelength_9;
            throughput_6 = _S1684;
            spectral_weight_0 = _S1682;
        }
        else
        {
            throughput_6 = throughput_5;
        }
        BSDFMaterial _S1689 = pathMaterial(surface_12.material, wavelength_8);
        float2  _S1690 = wavelengthEta(_S1689, _S1667, wavelength_8);
        FKSurface _S1691 = surface_12;
        Facets _S1692 = drawFacets((&ray_2)->unit_direction, _S1666.smooth_n, _S1689, surface_12.random_state);
        bool _S1693;
        if(scatter_2)
        {
            bool _S1694 = neeDecision(_S1689, _S1667, _S1690.x, _S1690.y);
            _S1693 = _S1694;
        }
        else
        {
            _S1693 = false;
        }
        bool _S1695;
        if(passes_0)
        {
            _S1695 = true;
        }
        else
        {
            _S1695 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1695)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1693;
        }
        bool _S1696 = (fcptHairUsed());
        bool _S1697;
        if(_S1696)
        {
            float3  _S1698 = surface_12.hair;
            _S1697 = (dot_0(_S1698, _S1698)) > 0.0f;
        }
        else
        {
            _S1697 = false;
        }
        bool _S1699;
        if(_S1697)
        {
            _S1699 = true;
        }
        else
        {
            BSDFMaterial _S1700 = _S1689;
            bool _S1701 = isTranslucent_0(&_S1700);
            _S1699 = _S1701;
        }
        bool _S1702;
        if(_S1699)
        {
            _S1702 = true;
        }
        else
        {
            bool _S1703 = (_S1689.transmission) > 0.0f;
            if(_S1703)
            {
                uint _S1704 = (fcptLayers((hit_4)));
                _S1702 = _S1704 == 1U;
            }
            else
            {
                _S1702 = false;
            }
        }
        float3  emission_0;
        if(_S1628)
        {
            float3  _S1705 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1705;
        }
        else
        {
            emission_0 = _S1689.emissive;
        }
        bool _S1706 = !replay_2;
        bool _S1707;
        if(_S1706)
        {
            _S1707 = true;
        }
        else
        {
            _S1707 = b_7 >= _S1495;
        }
        bool _S1708;
        if(_S1707)
        {
            float _S1709 = rgb_to_greyscale(emission_0);
            _S1708 = _S1709 > 0.0f;
        }
        else
        {
            _S1708 = false;
        }
        float3  emission_1;
        if(_S1708)
        {
            NEEVertex _S1710 = nee_vertex_0;
            FKHit _S1711 = hit_4;
            float _S1712 = emissionWeight_0(&_S1710, &_S1711, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1712);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1713;
        if(replay_2)
        {
            _S1713 = _S1484 == 1U;
        }
        else
        {
            _S1713 = false;
        }
        bool _S1714;
        if(_S1713)
        {
            _S1714 = b_7 > _S1483;
        }
        else
        {
            _S1714 = false;
        }
        bool _S1715;
        if(_S1714)
        {
            _S1715 = b_7 == _S1482;
        }
        else
        {
            _S1715 = false;
        }
        bool _S1716;
        if(_S1715)
        {
            bool _S1717 = _S1485 == 1U;
            if(_S1717)
            {
                _S1716 = true;
            }
            else
            {
                _S1716 = _S1485 == 2U;
            }
        }
        else
        {
            _S1716 = false;
        }
        if(_S1716)
        {
            bool _S1718 = _S1628 != (_S1485 == 2U);
            if(_S1718)
            {
                return _S1480;
            }
            float3  _S1719 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_8);
            return Shift_x24init_0(_S1719 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1720 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1721 = _S1720 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1722 = insertBits_0(_S1509, b_7, 5U, 5U);
        uint _S1723 = insertBits_0(_S1722, 1U, 10U, 2U);
        uint _S1724 = insertBits_0(_S1723, (&prev_0)->lobe, 15U, 3U);
        bool _S1725 = (&prev_0)->inside;
        uint _S1726 = _slang_select(_S1725, 1U,0U);
        uint _S1727 = insertBits_0(_S1724, _S1726, 22U, 1U);
        (&here_0)->path = _S1727;
        uint _S1728 = (&here_0)->path;
        bool _S1729 = wavelength_8 > 0.0f;
        uint _S1730 = _slang_select(_S1729, 1U,0U);
        uint _S1731 = insertBits_0(_S1728, _S1730, 23U, 1U);
        (&here_0)->path = _S1731;
        float _S1732 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1732;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1733;
        if(replay_2)
        {
            _S1733 = _S1484 == 1U;
        }
        else
        {
            _S1733 = false;
        }
        bool _S1734;
        if(_S1733)
        {
            _S1734 = b_7 == _S1483;
        }
        else
        {
            _S1734 = false;
        }
        bool _S1735 = b_7 == _S1495;
        bool _S1736;
        if(_S1735)
        {
            bool _S1737 = !scatter_2;
            if(_S1737)
            {
                _S1736 = true;
            }
            else
            {
                bool _S1738 = _S1484 != 1U;
                if(_S1738)
                {
                    _S1736 = _S1484 != 3U;
                }
                else
                {
                    _S1736 = false;
                }
            }
        }
        else
        {
            _S1736 = false;
        }
        bool _S1739;
        if(_S1736)
        {
            _S1739 = _S1484 == 2U;
        }
        else
        {
            _S1739 = false;
        }
        bool _S1740;
        if(_S1739)
        {
            _S1740 = !_S1665;
        }
        else
        {
            _S1740 = false;
        }
        bool _S1741;
        if(_S1740)
        {
            _S1741 = _S1485 != 4U;
        }
        else
        {
            _S1741 = false;
        }
        bool _S1742 = _S1483 == _S1482;
        bool _S1743;
        if(_S1742)
        {
            _S1743 = _S1485 == 0U;
        }
        else
        {
            _S1743 = false;
        }
        bool _S1744;
        if(_S1743)
        {
            _S1744 = ((&hit_4)->instance_index) == (_S1496.instance_index);
        }
        else
        {
            _S1744 = false;
        }
        bool _S1745;
        if(_S1744)
        {
            _S1745 = ((&hit_4)->triangle_index) == (_S1496.triangle_index);
        }
        else
        {
            _S1745 = false;
        }
        bool _S1746;
        if(_S1745)
        {
            _S1746 = _S1665;
        }
        else
        {
            _S1746 = false;
        }
        bool _S1747 = _slang_select(_S1734, _S1746,_S1741);
        bool _S1748;
        if(nee_0)
        {
            _S1748 = _slang_select(replay_2, _S1747,scatter_2);
        }
        else
        {
            _S1748 = false;
        }
        TreeSample _S1749 = TreeSample_x24init_0(_S1479, _S1479, 0.0f, 0U);
        uint2  _S1750 = make_uint2 (0U);
        float2  _S1751 = make_float2 (0.0f);
        FKHit _S1752 = Hit_x24init_0(_S1751, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1753 = _S1752;
        ShadowContext _S1754 = ShadowContext_x24init_0(_S1479, _S1479, _S1750, _S1479, 0U, 0U, false, 0.0f, 0.0f, &_S1753, false);
        bool _S1755;
        if(nee_0)
        {
            _S1755 = _S1707;
        }
        else
        {
            _S1755 = false;
        }
        ShadowContext context_5;
        if(_S1755)
        {
            uint _S1756 = arrivalLobe_0(b_7, (&prev_0)->lobe);
            FKMedium _S1757 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1758 = surface_12;
            FKHit _S1759 = hit_4;
            FKMedium _S1760 = _S1757;
            ShadowContext _S1761 = shadowContext_0(&_S1758, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_7, _S1756, (&hit_4)->distance, width_3, &_S1759, _S1697, &_S1760);
            context_5 = _S1761;
        }
        else
        {
            context_5 = _S1754;
        }
        float3  throughput_7;
        float3  lit_0;
        if(_S1748)
        {
            float3  _S1762 = (&ray_2)->origin;
            if(_S1697)
            {
                throughput_7 = _S1479;
            }
            else
            {
                throughput_7 = _S1666.smooth_n;
            }
            FKSurface _S1763 = surface_12;
            uint _S1764 = noiseAddress(_S1507, b_7);
            ShadowContext _S1765 = context_5;
            TreeSample _S1766 = sampleLightTree_0(_S1762, throughput_7, surface_12.geometry_n, surface_12.geometry_offset, _S1702, _S1764, &_S1765);
            bool _S1767 = any_1((_S1766.radiance) != _S1479);
            if(_S1767)
            {
                if(_S1697)
                {
                    uint _S1768 = (fcptMaxBounces());
                    bool _S1769 = b_7 < _S1768;
                    FKSurface _S1770 = surface_12;
                    TreeSample _S1771 = _S1766;
                    float3  _S1772 = hairLight_0(&_S1770, (&ray_2)->unit_direction, &_S1771, _S1769);
                    lit_0 = _S1772;
                }
                else
                {
                    float _S1773 = _S1690.x;
                    float _S1774 = _S1690.y;
                    uint _S1775 = (fcptMaxBounces());
                    bool _S1776 = b_7 < _S1775;
                    TreeSample _S1777 = _S1766;
                    BSDFMaterial _S1778 = _S1689;
                    Facets _S1779 = _S1692;
                    float3  _S1780 = lightBSDF_0((&ray_2)->unit_direction, &_S1777, _S1666.smooth_n, _S1763.geometry_n, &_S1778, _S1773, _S1774, _S1776, &_S1779);
                    lit_0 = _S1780;
                }
            }
            else
            {
                lit_0 = _S1479;
            }
            light_3 = _S1766;
        }
        else
        {
            light_3 = _S1749;
            lit_0 = _S1479;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1781;
        bool _S1782;
        float density_4;
        if(_S1734)
        {
            bool _S1783 = !_S1665;
            if(_S1783)
            {
                return _S1480;
            }
            uint _S1784 = extractBits_0(_S1481, 23U, 1U);
            bool _S1785 = _S1729 != (_S1784 == 1U);
            if(_S1785)
            {
                return _S1480;
            }
            float3  throughput_8 = throughput_6 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1742)
            {
                viewed_1 = _S1485 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                float3  _S1786 = pathColor(throughput_8 * emission_1, spectral_weight_0, wavelength_8);
                return Shift_x24init_0(_S1786 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1742)
            {
                refracted_4 = _S1485 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1787 = !nee_0;
                if(_S1787)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1788 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1788 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1480;
                }
                float3  _S1789 = pathColor(throughput_8 * lit_0, spectral_weight_0, wavelength_8);
                return Shift_x24init_0(_S1789 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1742)
            {
                wrong_side_0 = _S1485 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1790 = !nee_0;
                if(_S1790)
                {
                    return _S1480;
                }
                bool _S1791 = (fcptWorldReadsPath());
                if(_S1791)
                {
                    float3  _S1792 = r_8->dir;
                    float _S1793 = environmentPdf_0(r_8->dir);
                    FKSurface _S1794 = surface_12;
                    BSDFMaterial _S1795 = _S1689;
                    Facets _S1796 = _S1692;
                    FixedArray<float3 , 6>  terms_4;
                    FixedArray<float, 6>  pdfs_6;
                    float3  _S1797 = skyLobes_0((&ray_2)->unit_direction, _S1792, &_S1794, &_S1795, _S1690, is_inside_7, &_S1796, _S1793, &terms_4, &pdfs_6);
                    uint _S1798 = b_7 + 1U;
                    FixedArray<float3 , 6>  _S1799 = terms_4;
                    FixedArray<float, 6>  _S1800 = pdfs_6;
                    float3  _S1801 = skyColor_0(_S1792, &_S1799, &_S1800, _S1798);
                    float3  _S1802 = pathColor(throughput_8 * (_S1801 * r_8->radiance), spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S1802 / make_float3 (r_8->jac), density_5 / r_8->jac);
                }
                float _S1803 = environmentPdf_0(r_8->dir);
                float3  _S1804 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_12, _S1689, _S1690, is_inside_7, _S1692, _S1803);
                float3  _S1805 = pathColor(throughput_8 * _S1804 * r_8->radiance, spectral_weight_0, wavelength_8);
                return Shift_x24init_0(_S1805 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1806 = extractBits_0(_S1481, 21U, 1U);
            bool _S1807 = nee_0 != (_S1806 == 1U);
            if(_S1807)
            {
                return _S1480;
            }
            throughput_7 = throughput_8;
            density_4 = density_5;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1735;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1808 = !scatter_2;
                if(_S1808)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1809 = _S1484 != 1U;
                    if(_S1809)
                    {
                        refracted_4 = _S1484 != 3U;
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
                bool _S1810 = _S1484 == 2U;
                if(_S1810)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1665;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1485 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1697)
                    {
                        return _S1480;
                    }
                    uint _S1811 = noiseAddress(_S1507, b_7);
                    FKRay _S1812 = ray_2;
                    FKSurface _S1813 = surface_12;
                    Facets _S1814 = _S1692;
                    ShadowContext _S1815 = context_5;
                    SkySample _S1816 = sampleSky_0(&_S1812, &_S1813, wavelength_8, _S1690, is_inside_7, _S1811, &_S1814, &_S1815);
                    float3  _S1817 = pathColor(throughput_6 * _S1816.color, spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S1817, 1.0f);
                }
                if(_S1810)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1665;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1818 = rgb_to_greyscale(light_3.radiance);
                    bool _S1819 = !(_S1818 > 0.0f);
                    if(_S1819)
                    {
                        return _S1480;
                    }
                    float3  _S1820 = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S1820, 1.0f);
                }
                if(_S1494)
                {
                    passes_0 = _S1485 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1628;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1821 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S1821, 1.0f);
                }
                if(_S1494)
                {
                    passes_0 = _S1485 == 1U;
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
                    passes_0 = !_S1665;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1822 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S1822, 1.0f);
                }
                return _S1480;
            }
            else
            {
                if(_S1706)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1823 = b_7 > 0U;
                    if(_S1823)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1721)
                        {
                            float3  _S1824 = safeDivide(throughput_6 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1824;
                        }
                        else
                        {
                            if(_S1665)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1825 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_8);
                        Reservoir _S1826 = withEnd(candidate_5, 1U, b_7, _S1825);
                        offer(sel_7, _S1826, _S1825 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1827 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_8);
                        float3  _S1828 = sel_7->glow + _S1827;
                        sel_7->glow = _S1828;
                    }
                    if(nee_0)
                    {
                        float3  _S1829 = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_8);
                        Reservoir candidate_6 = chain_0;
                        if(_S1721)
                        {
                            float3  _S1830 = safeDivide(_S1829, chain_throughput_0);
                            (&candidate_6)->radiance = _S1830;
                        }
                        else
                        {
                            if(_S1665)
                            {
                                candidate_6 = here_0;
                                uint _S1831 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1831;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1832 = insertBits_0(_S1509, b_7 + 1U, 5U, 5U);
                                uint _S1833 = insertBits_0(_S1832, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1833;
                            }
                        }
                        Reservoir _S1834 = withEnd(candidate_6, 0U, b_7, _S1829);
                        offer(sel_7, _S1834, _S1829 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1697)
                        {
                            _S1781 = false;
                        }
                        else
                        {
                            bool _S1835 = environmentMapped_0();
                            _S1781 = _S1835;
                        }
                    }
                    else
                    {
                        _S1781 = false;
                    }
                    if(_S1781)
                    {
                        uint _S1836 = (fcptMaxBounces());
                        _S1782 = b_7 < _S1836;
                    }
                    else
                    {
                        _S1782 = false;
                    }
                    if(_S1782)
                    {
                        uint _S1837 = noiseAddress(_S1507, b_7);
                        FKRay _S1838 = ray_2;
                        FKSurface _S1839 = surface_12;
                        Facets _S1840 = _S1692;
                        ShadowContext _S1841 = context_5;
                        SkySample _S1842 = sampleSky_0(&_S1838, &_S1839, wavelength_8, _S1690, is_inside_7, _S1837, &_S1840, &_S1841);
                        float3  _S1843 = pathColor(throughput_6 * _S1842.color, spectral_weight_0, wavelength_8);
                        Reservoir candidate_7 = chain_0;
                        if(_S1721)
                        {
                            float3  _S1844 = safeDivide(_S1843, chain_throughput_0);
                            (&candidate_7)->radiance = _S1844;
                        }
                        else
                        {
                            if(_S1665)
                            {
                                candidate_7 = here_0;
                                uint _S1845 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1845;
                                (&candidate_7)->dir = _S1842.dir;
                                (&candidate_7)->radiance = _S1842.radiance;
                            }
                            else
                            {
                                uint _S1846 = insertBits_0(_S1509, b_7 + 1U, 5U, 5U);
                                uint _S1847 = insertBits_0(_S1846, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1847;
                            }
                        }
                        Reservoir _S1848 = withEnd(candidate_7, 4U, b_7, _S1843);
                        offer(sel_7, _S1848, _S1843 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_7 = throughput_6;
            density_4 = density_2;
        }
        bool _S1849;
        bool _S1850;
        bool _S1851;
        bool straight_0;
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
                viewed_1 = _S1735;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1864 = extractBits_0(_S1481, 15U, 3U);
            uint _S1865 = extractBits_0(_S1481, 18U, 3U);
            uint _S1866 = _slang_select(_S1734, _S1865,_S1864);
            float3  _S1867 = r_8->dir;
            bool refracted_5 = _S1866 == 1U;
            SampleBSDF _S1868 = SampleBSDF_x24init_0(_S1479, _S1479, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1868;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1869 = extractBits_0(_S1481, 22U, 1U);
                bool _S1870 = is_inside_7 != (_S1869 == 1U);
                if(_S1870)
                {
                    return _S1480;
                }
                bool _S1871 = _S1484 == 1U;
                if(_S1871)
                {
                    float3  _S1872 = (fcptHitPosition((_S1496)));
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
                    BSDFMaterial _S1873 = _S1689;
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
                        wrong_side_0 = (dot_0(_S1666.smooth_n, _S1876) * _S1667) < 0.0f;
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
                    float3  _S1879 = - _S1666.smooth_n;
                    bool _S1880 = is_inside_7 != refracted_4;
                    float3  _S1881 = _slang_select(_S1880, _S1879,_S1666.smooth_n);
                    float3  _S1882 = throughput_9 - (_S1877 + make_float3 (_S1878.geometry_offset) * _S1881);
                    float3  _S1883 = ((((_S1882)) * make_float3(rnorm3df(((_S1882)).x, ((_S1882)).y, ((_S1882)).z))));
                    reconnection_1 = _S1883;
                }
                else
                {
                    reconnection_1 = _S1867;
                }
                if(_S1697)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1884 = wrongSide_0(is_inside_7, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1884;
                }
                if(wrong_side_0)
                {
                    return _S1480;
                }
                float3  _S1885 = throughput_9;
                throughput_9 = reconnection_1;
                b_10 = _S1866;
                wrong_side_0 = false;
                reconnection_1 = _S1885;
            }
            else
            {
                bool _S1886 = !_S1734;
                if(_S1886)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1887;
                    if(_S1697)
                    {
                        SampleBSDF _S1888 = (fcptSampleHair((surface_12.hair), (_S1689.albedo), (_S1689.specular_tint), ((&ray_2)->unit_direction), (_S1691.random_state)));
                        _S1887 = _S1888;
                    }
                    else
                    {
                        SampleBSDF _S1889 = sampleBSDF((&ray_2)->unit_direction, _S1666.smooth_n, _S1689, _S1690.x, _S1690.y, _S1692, _S1691.random_state, _S1751);
                        _S1887 = _S1889;
                    }
                    bsdf_sampled_0 = _S1887;
                    if(_S1697)
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
                            return _S1480;
                        }
                        break;
                    }
                    if(_S1697)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1890 = wrongSide_0(is_inside_7, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1890;
                    }
                    if(wrong_side_0)
                    {
                        _S1781 = (_S1689.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1781 = false;
                    }
                    if(_S1781)
                    {
                        float _S1891 = _S1690.x;
                        float _S1892 = _S1690.y;
                        Facets _S1893 = drawFacets((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1689, (&bsdf_sampled_0)->random_state);
                        SampleBSDF _S1894 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1689, _S1891, _S1892, _S1893, (&bsdf_sampled_0)->random_state, _S1751);
                        (&bsdf_sampled_0)->unit_direction = _S1894.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1894.refracted;
                        (&bsdf_sampled_0)->throughput = _S1894.throughput;
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
                    b_10 = _S1896;
                    refracted_4 = _S1898;
                }
                else
                {
                    throughput_9 = _S1867;
                    b_10 = _S1866;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1781 = true;
            }
            else
            {
                _S1781 = _S1734;
            }
            if(_S1781)
            {
                if(_S1697)
                {
                    SampleBSDF _S1901 = (fcptConnectHair((surface_12.hair), (_S1689.albedo), (_S1689.specular_tint), ((&ray_2)->unit_direction), (throughput_9)));
                    lobe_5 = _S1901;
                }
                else
                {
                    float3  _S1902 = (&ray_2)->unit_direction;
                    float3  _S1903 = negate_0(_S1902);
                    float _S1904 = sign_0(_S1667);
                    float3  _S1905 = _S1666.smooth_n * make_float3 (_S1904);
                    float _S1906 = dot_0(_S1905, throughput_9);
                    float _S1907 = _S1689.roughness;
                    float _S1908 = _S1907 * _S1907;
                    AnisotropicFrame _S1909 = anisotropicFrame(_S1689, _S1905);
                    SheenProfile _S1910 = sheenProfile(_S1903, _S1905, _S1689);
                    CoatFrame _S1911 = coatFrame(_S1689, _S1905);
                    float3  _S1912 = coatSeries(_S1911, _S1689);
                    float3  _S1913 = reflectedHalf(_S1902, throughput_9);
                    bool _S1914 = b_10 == 1U;
                    if(_S1914)
                    {
                        float3  _S1915 = refractedHalf(_S1902, throughput_9, _S1666.smooth_n, _S1690.x, _S1690.y);
                        throughput_10 = _S1915;
                    }
                    else
                    {
                        throughput_10 = _S1913;
                    }
                    float3  _S1916 = reflectedHalf(_S1902, throughput_9);
                    float3  _S1917 = _S1692.coat_h;
                    bool _S1918 = (dot_0(_S1917, _S1917)) > 0.0f;
                    float3  _S1919 = _slang_select(_S1918, _S1916,_S1479);
                    float _S1920 = _S1690.x;
                    float _S1921 = _S1690.y;
                    Weights _S1922 = lobeWeights(_S1902, _S1903, _S1905, _S1692.h, _S1692.coat_h, throughput_10, _S1919, _S1909, _S1910, _S1911, _S1912, _S1689, _S1920, _S1921);
                    float _S1923 = (F32_abs((_S1667)));
                    float _S1924 = vndfPDF(_S1903, throughput_10, _S1905, _S1923, _S1908, _S1909, _S1922.v_dot_h);
                    switch(b_10)
                    {
                    case 0U:
                        {
                            float _S1925 = diffusePDF(_S1906, _S1923, _S1689, _S1922);
                            float3  _S1926 = diffuseBSDF(throughput_9, _S1905, _S1689, _S1922);
                            density_6 = _S1925;
                            throughput_11 = _S1926;
                            break;
                        }
                    case 1U:
                        {
                            float _S1927 = refractPDF(dot_0(throughput_9, throughput_10), _S1924, _S1922, _S1920, _S1921);
                            float3  _S1928 = refractBSDF(throughput_9, _S1905, _S1908, _S1909, _S1689, _S1922);
                            density_6 = _S1927;
                            throughput_11 = _S1928;
                            break;
                        }
                    case 4U:
                        {
                            float _S1929 = sheenVelvetPDF(_S1906, _S1923, _S1922);
                            float3  _S1930 = sheenVelvetBSDF(throughput_9, _S1903, _S1905, _S1689, _S1922);
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
                            ToonProfile _S1933 = toonProfile(_S1903, _S1905, _S1689);
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
                        SampleBSDF _S1939 = SampleBSDF_x24init_0(throughput_9, throughput_11, _S1691.random_state, _S1914, b_10, density_6);
                        lobe_5 = _S1939;
                    }
                }
            }
            bool _S1940 = b_10 == 0U;
            if(_S1940)
            {
                _S1782 = true;
            }
            else
            {
                _S1782 = b_10 == 4U;
            }
            if(_S1782)
            {
                _S1849 = true;
            }
            else
            {
                _S1849 = b_10 == 6U;
            }
            bool _S1941 = b_10 == 5U;
            float _S1942 = _slang_select(_S1941, _S1689.coat_roughness,_S1689.roughness);
            if(_S1697)
            {
                _S1850 = false;
            }
            else
            {
                bool _S1943 = !_S1849;
                if(_S1943)
                {
                    bool _S1944 = _S1942 == 0.0f;
                    if(_S1944)
                    {
                        _S1850 = true;
                    }
                    else
                    {
                        bool _S1945 = b_10 == 1U;
                        if(_S1945)
                        {
                            _S1850 = (_S1690.x) == (_S1690.y);
                        }
                        else
                        {
                            _S1850 = false;
                        }
                    }
                }
                else
                {
                    _S1850 = false;
                }
            }
            bool _S1946 = !_S1697;
            if(_S1946)
            {
                _S1851 = b_10 == 1U;
            }
            else
            {
                _S1851 = false;
            }
            if(_S1851)
            {
                straight_0 = (_S1689.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1852 = _S1946;
            }
            else
            {
                _S1852 = false;
            }
            if(_S1852)
            {
                _S1853 = b_10 == 1U;
            }
            else
            {
                _S1853 = false;
            }
            if(_S1853)
            {
                _S1854 = (_S1690.x) == (_S1690.y);
            }
            else
            {
                _S1854 = false;
            }
            BSDFMaterial _S1947 = _S1689;
            bool _S1948 = isTranslucent_0(&_S1947);
            if(_S1948)
            {
                _S1855 = _S1940;
            }
            else
            {
                _S1855 = false;
            }
            if(_S1855)
            {
                _S1856 = (dot_0(throughput_9, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1856 = false;
            }
            if(nee_0)
            {
                _S1857 = !_S1850;
            }
            else
            {
                _S1857 = false;
            }
            if(_S1857)
            {
                _S1858 = !wrong_side_0;
            }
            else
            {
                _S1858 = false;
            }
            if(_S1858)
            {
                float _S1949 = (&lobe_5)->pdf;
                float3  _S1950 = (&ray_2)->origin;
                float3  _S1951 = _slang_select(_S1702, _S1479,_S1666.smooth_n);
                float3  _S1952 = (&ray_2)->origin;
                FKSurface _S1953 = surface_12;
                float3  _S1954 = - _S1666.smooth_n;
                float3  _S1955 = _slang_select(_S1856, _S1954,_S1666.smooth_n);
                NEEVertex _S1956 = NEEVertex_x24init_0(false, _S1949, _S1950, _S1951, _S1952 + make_float3 (_S1953.geometry_offset) * _S1955);
                nee_vertex_0 = _S1956;
            }
            else
            {
                if(_S1697)
                {
                    _S1859 = true;
                }
                else
                {
                    bool _S1957 = b_10 != 1U;
                    if(_S1957)
                    {
                        _S1859 = true;
                    }
                    else
                    {
                        _S1859 = (_S1690.x) != (_S1690.y);
                    }
                }
                if(_S1859)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1958 = withinInverseFootprint((&lobe_5)->pdf, _S1849, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1959 = roughLobe((&lobe_5)->pdf, _S1849, _S1942);
            if(_S1734)
            {
                bool _S1960 = !_S1958;
                if(_S1960)
                {
                    return _S1480;
                }
                bool _S1961 = _S1485 != 1U;
                if(_S1961)
                {
                    _S1859 = _S1485 != 2U;
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
                    if(_S1742)
                    {
                        passes_0 = _S1491;
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
            bool _S1969 = b_10 == 1U;
            bool _S1970 = passesLayer_0(_S1968, _S1969, passes_0);
            if(viewed_1)
            {
                _S1859 = _S1970;
            }
            else
            {
                _S1859 = false;
            }
            if(_S1859)
            {
                return _S1480;
            }
            if(replay_2)
            {
                _S1860 = b_7 <= _S1495;
            }
            else
            {
                _S1860 = false;
            }
            if(_S1860)
            {
                _S1861 = _S1665;
            }
            else
            {
                _S1861 = false;
            }
            if(_S1861)
            {
                _S1862 = _S1958;
            }
            else
            {
                _S1862 = false;
            }
            if(_S1862)
            {
                _S1863 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1863 = !_S1959;
                }
                else
                {
                    _S1863 = false;
                }
            }
            if(_S1863)
            {
                return _S1480;
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
                float3  _S1973 = throughput_10 * max_0((&lobe_5)->throughput, _S1479);
                throughput_11 = _S1973;
                sky_pdf_2 = density_6;
            }
            bool _S1974;
            if(_S1706)
            {
                _S1974 = !_S1721;
            }
            else
            {
                _S1974 = false;
            }
            bool _S1975;
            if(_S1974)
            {
                _S1975 = _S1665;
            }
            else
            {
                _S1975 = false;
            }
            bool _S1976;
            if(_S1975)
            {
                _S1976 = _S1958;
            }
            else
            {
                _S1976 = false;
            }
            float3  chain_throughput_1;
            if(_S1976)
            {
                chain_0 = here_0;
                uint _S1977 = insertBits_0((&chain_0)->path, b_10, 18U, 3U);
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
            Vertex _S1982 = Vertex_x24init_0(_S1959, b_10, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_9)))), is_inside_7);
            prev_0 = _S1982;
            float _S1983 = (&lobe_5)->pdf;
            bool _S1984;
            if(_S1969)
            {
                _S1984 = (_S1690.x) == (_S1690.y);
            }
            else
            {
                _S1984 = false;
            }
            float sky_pdf_3 = _slang_select(_S1984, sky_pdf_0,_S1983);
            float _S1985 = _slang_select(_S1697, 0.0f,sky_pdf_3);
            float _S1986 = widened_0(spread_2, (&lobe_5)->pdf, _S1850);
            bool _S1987;
            if(refracted_4)
            {
                _S1987 = !_S1856;
            }
            else
            {
                _S1987 = false;
            }
            bool is_inside_8;
            if(_S1987)
            {
                bool _S1988 = !is_inside_7;
                is_inside_8 = _S1988;
            }
            else
            {
                is_inside_8 = is_inside_7;
            }
            FKSurface _S1989 = surface_12;
            bool _S1990 = boundsVolume_0(&_S1989);
            bool _S1991;
            if(_S1990)
            {
                _S1991 = !_S1970;
            }
            else
            {
                _S1991 = false;
            }
            if(_S1991)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1992 = - _S1981.geometry_n;
                float3  _S1993 = _slang_select(turned_1, _S1992,_S1981.geometry_n);
                (&faced_2)->geometry_n = _S1993;
                FKMedium _S1994 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1995 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1996 = faced_2;
                FKMedium _S1997 = _S1994;
                FKMedium _S1998 = _S1995;
                MediumSides _S1999 = mediumSides_0(&_S1996, &_S1997, filling_2, (&ray_2)->unit_direction, &_S1998);
                bool _S2000 = leavesInFront_0((&faced_2)->geometry_n, throughput_9, _S1981.geometry_n);
                float3  _S2001 = _slang_select(_S2000, _S1999.front.scatter,_S1999.behind.scatter);
                scatter_in_0 = _S2001;
                float3  _S2002 = scatter_in_0;
                float _S2003 = upsample(scatter_in_0, wavelength_8);
                float3  _S2004 = make_float3 (_S2003);
                float3  _S2005 = _slang_select(_S1729, _S2004,_S2002);
                scatter_in_0 = _S2005;
                float3  _S2006 = _slang_select(_S2000, _S1999.front.extinction,_S1999.behind.extinction);
                extinction_in_0 = _S2006;
                float3  _S2007 = extinction_in_0;
                float _S2008 = upsample(extinction_in_0, wavelength_8);
                float3  _S2009 = make_float3 (_S2008);
                float3  _S2010 = _slang_select(_S1729, _S2009,_S2007);
                extinction_in_0 = _S2010;
                float _S2011 = _slang_select(_S2000, _S1999.front.g,_S1999.behind.g);
                g_in_0 = _S2011;
                uint _S2012 = _S1999.fillings.x;
                uint _S2013 = _S1999.fillings.y;
                uint _S2014 = _slang_select(_S2000, _S2013,_S2012);
                bool _S2015 = (fcptVaryingUsed());
                uint _S2016 = _slang_select(_S2015, _S2014,4294967295U);
                filling_2 = _S2016;
            }
            (&ray_2)->unit_direction = throughput_9;
            bool _S2017 = !_S1970;
            if(_S2017)
            {
                FKSurface _S2018 = surface_12;
                float _S2019 = _slang_select(straight_0, 0.0f,_S2018.geometry_offset);
                float3  _S2020 = - _S1666.smooth_n;
                bool _S2021 = is_inside_8 != _S1856;
                float3  _S2022 = _slang_select(_S2021, _S2020,_S1666.smooth_n);
                float3  _S2023 = (&ray_2)->origin + make_float3 (_S2019) * _S2022;
                (&ray_2)->origin = _S2023;
            }
            throughput_10 = throughput_11;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1970;
            viewed_1 = _S1854;
            sky_pdf_2 = _S1985;
            spread_5 = _S1986;
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
        if(_S1706)
        {
            if(_S1628)
            {
                float3  _S2024 = pathColor(throughput_10 * emission_1, spectral_weight_0, wavelength_8);
                Reservoir candidate_8 = chain_0;
                uint _S2025 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S2026 = _S2025 == 1U;
                if(_S2026)
                {
                    float3  _S2027 = safeDivide(_S2024, chain_throughput_0);
                    (&candidate_8)->radiance = _S2027;
                }
                Reservoir _S2028 = withEnd(candidate_8, 2U, b_7, _S2024);
                offer(sel_7, _S2028, _S2024 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1628)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S2029 = survivalProbability(abs_0(throughput_10), density_6);
                density_7 = _S2029;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S2030 = noiseAddress(_S1507, b_7);
            Random _S2031 = draw(_S2030, 8U);
            bool _S2032 = density_7 < (_S2031.value);
            if(_S2032)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S2033 = (fcptMaxBounces());
                wrong_side_0 = b_7 >= _S2033;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S2034 = density_6 * density_7;
            density_7 = _S2034;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S2035 = layer_0 ^ 1U;
        uint _S2036 = _slang_select(passes_0, _S2035,0U);
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
            uint _S2037 = b_10 + 1U;
            b_7 = _S2037;
            layer_0 = _S2036;
            continue;
        }
        FKRay _S2038 = ray_2;
        float _S2039 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1735;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1484 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S2040 = _slang_select(wrong_side_0, _S2039,4.294967296e+09f);
        bool _S2041 = !_S1697;
        if(straight_0)
        {
            _S1781 = true;
        }
        else
        {
            _S1781 = _S1697;
        }
        FKHit _S2042;
        if(_S1781)
        {
            _S2042 = hit_4;
        }
        else
        {
            _S2042 = _S1752;
        }
        FKHit _S2043 = (fcptTraverseInstanceBVH((_S2038), (_S1636), (_S2040), (_S2041), (_S2042), (viewed_1)));
        hit_4 = _S2043;
        if(replay_2)
        {
            _S1782 = _S1735;
        }
        else
        {
            _S1782 = false;
        }
        if(_S1782)
        {
            _S1849 = _S1484 == 1U;
        }
        else
        {
            _S1849 = false;
        }
        if(_S1849)
        {
            _S1850 = ((&hit_4)->instance_index) == (_S1496.instance_index);
        }
        else
        {
            _S1850 = false;
        }
        if(_S1850)
        {
            _S1851 = ((&hit_4)->triangle_index) == (_S1496.triangle_index);
        }
        else
        {
            _S1851 = false;
        }
        if(_S1851)
        {
            (&hit_4)->uv = _S1496.uv;
            float _S2044 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S2044;
        }
        if(replay_2)
        {
            _S1852 = _S1735;
        }
        else
        {
            _S1852 = false;
        }
        if(_S1852)
        {
            _S1853 = _S1484 == 3U;
        }
        else
        {
            _S1853 = false;
        }
        if(_S1853)
        {
            _S1854 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1854 = false;
        }
        if(_S1854)
        {
            return _S1480;
        }
        Reservoir _S2045 = chain_0;
        uint _S2046 = filling_2;
        for(;;)
        {
            bool _S2047 = (fcptVaryingUsed());
            if(_S2047)
            {
                _S1855 = _S2046 != 4294967295U;
            }
            else
            {
                _S1855 = false;
            }
            float _S2048;
            if(_S1855)
            {
                float _S2049 = (fcptMajorant((_S2046)));
                _S2048 = _S2049;
            }
            else
            {
                _S2048 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1856 = _S1735;
            }
            else
            {
                _S1856 = false;
            }
            if(_S1856)
            {
                _S1857 = _S1484 == 1U;
            }
            else
            {
                _S1857 = false;
            }
            if(_S1857)
            {
                _S1858 = _S2048 > 0.0f;
            }
            else
            {
                _S1858 = false;
            }
            if(_S1858)
            {
                ended_0 = _S1480;
                sky_pdf_1 = sky_pdf_2;
                spread_3 = spread_5;
                width_4 = width_3;
                density_3 = density_7;
                throughput_11 = throughput_10;
                b_10 = b_7;
                _S1859 = true;
                break;
            }
            bool _S2050 = (&prev_0)->rough;
            if(_S2050)
            {
                _S1859 = !(_S2048 > 0.0f);
            }
            else
            {
                _S1859 = false;
            }
            (&prev_0)->rough = _S1859;
            uint _S2051 = b_7 + 320U;
            bool _S2052 = b_7 == 4294967295U;
            uint _S2053 = _slang_select(_S2052, 384U,_S2051);
            uint _S2054 = stream(_S1507, _S2053);
            uint tracking_1 = _S2054;
            weight_2 = throughput_3;
            glowed_0 = _S1479;
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
                    _S1478 = int(2);
                    break;
                }
                uint _S2055 = noiseAddress(_S1507, b_10);
                Random _S2056 = draw(_S2055, 10U);
                float _S2057 = freeFlight_0(_S2056.value, _S2048);
                if(_S1855)
                {
                    float3  _S2058 = (&ray_2)->origin;
                    float3  _S2059 = (&ray_2)->unit_direction;
                    float _S2060 = (&hit_4)->distance;
                    bool _S2061 = b_10 == 4294967295U;
                    uint _S2062 = _slang_select(_S2061, 0U,b_10);
                    uint _S2063 = (&prev_0)->lobe;
                    uint _S2064 = _slang_select(_S2061, 3U,_S2063);
                    float _S2065 = (fcptTrackMedium((_S2046), (_S2058), (_S2059), (_S2060), (&tracking_1), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S2062), (_S2064), (_S2061)));
                    spread_4 = _S2065;
                }
                else
                {
                    spread_4 = _S2057;
                }
                bool _S2066 = !(spread_4 < ((&hit_4)->distance));
                if(_S2066)
                {
                    _S1478 = int(2);
                    break;
                }
                if(_S1855)
                {
                    _S1860 = _S1706;
                }
                else
                {
                    _S1860 = false;
                }
                if(_S1860)
                {
                    float3  _S2067 = pathColor(throughput_11 * glowed_0, spectral_weight_0, wavelength_8);
                    float3  _S2068 = _S2067 / make_float3 (density_3);
                    float3  _S2069 = sel_7->glow + _S2068;
                    sel_7->glow = _S2069;
                }
                else
                {
                }
                glowed_0 = _S1479;
                uint b_11 = b_10 + 1U;
                float3  _S2070 = (&ray_2)->origin + make_float3 (spread_4) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S2070;
                float3  _S2071 = flightWeight_0(scatter_in_0, extinction_in_0, _S2048, spread_4, true);
                float3  _S2072 = weight_2;
                float _S2073 = upsample(weight_2, wavelength_8);
                float3  _S2074 = make_float3 (_S2073);
                float3  _S2075 = _slang_select(_S1729, _S2074,_S2072);
                float3  _S2076 = _slang_select(_S1855, _S2075,_S2071);
                float3  throughput_12 = throughput_11 * _S2076;
                uint _S2077 = stream(_S1507, b_11 + 320U);
                tracking_1 = _S2077;
                weight_2 = throughput_3;
                float width_7 = width_4 + spread_3 * spread_4;
                float _S2078 = spread_3 + 3.14159274101257324f;
                bool _S2079 = scatterSampled_0(replay_2, b_11, _S1495, _S1855);
                TreeSample light_4;
                if(_S2079)
                {
                    float3  _S2080 = (&ray_2)->origin;
                    float3  _S2081 = (&ray_2)->unit_direction;
                    float3  _S2082 = (&ray_2)->unit_direction;
                    uint _S2083 = noiseAddress(_S1507, b_11);
                    float3  _S2084 = extinction_in_0;
                    float3  _S2085 = extinction_in_0;
                    uint2  _S2086 = make_uint2 (_S2046);
                    float3  _S2087 = (&ray_2)->unit_direction;
                    uint _S2088 = arrivalLobe_0(b_11, (&prev_0)->lobe);
                    FKHit _S2089 = _S1752;
                    ShadowContext _S2090 = ShadowContext_x24init_0(_S2084, _S2085, _S2086, _S2087, b_11, _S2088, false, spread_4, width_7, &_S2089, false);
                    ShadowContext _S2091 = _S2090;
                    TreeSample _S2092 = sampleLightTree_0(_S2080, _S2081, _S2082, 0.0f, true, _S2083, &_S2091);
                    light_4 = _S2092;
                }
                else
                {
                    light_4 = _S1749;
                }
                float _S2093 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S2094 = (fcptMaxBounces());
                bool _S2095 = b_11 < _S2094;
                if(_S2095)
                {
                    _S1861 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1861 = false;
                }
                float _S2096 = _slang_select(_S1861, _S2093,0.0f);
                float3  _S2097 = throughput_12 * light_4.radiance;
                float _S2098 = powerHeuristic(light_4.density, _S2096);
                float3  _S2099 = pathColor(_S2097 * make_float3 (_S2093 * _S2098), spectral_weight_0, wavelength_8);
                float3  _S2100 = _slang_select(_S2079, _S2099,_S1479);
                if(replay_2)
                {
                    _S1862 = b_11 == _S1495;
                }
                else
                {
                    _S1862 = false;
                }
                if(_S1862)
                {
                    bool _S2101 = _S1484 == 2U;
                    if(_S2101)
                    {
                        float _S2102 = resamplingTarget(_S2100);
                        _S1863 = _S2102 > 0.0f;
                    }
                    else
                    {
                        _S1863 = false;
                    }
                    if(_S1863)
                    {
                        Shift _S2103 = Shift_x24init_0(_S2100, 1.0f);
                        _S1478 = int(1);
                        ended_0 = _S2103;
                        spread_4 = _S2078;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_8 = b_11;
                        break;
                    }
                    _S1478 = int(1);
                    ended_0 = _S1480;
                    spread_4 = _S2078;
                    width_5 = width_7;
                    throughput_9 = throughput_12;
                    b_8 = b_11;
                    break;
                }
                if(_S1706)
                {
                    Reservoir candidate_9 = _S2045;
                    uint _S2104 = extractBits_0(_S2045.path, 24U, 8U);
                    uint _S2105 = insertBits_0(0U, _S2104, 24U, 8U);
                    uint _S2106 = extractBits_0(_S2045.path, 10U, 2U);
                    bool _S2107 = _S2106 == 1U;
                    if(_S2107)
                    {
                        float3  _S2108 = safeDivide(_S2100, chain_throughput_0);
                        (&candidate_9)->radiance = _S2108;
                    }
                    else
                    {
                        uint _S2109 = insertBits_0(_S2105, b_11 + 1U, 5U, 5U);
                        uint _S2110 = insertBits_0(_S2109, 2U, 10U, 2U);
                        (&candidate_9)->path = _S2110;
                    }
                    Reservoir _S2111 = withEnd(candidate_9, 0U, b_11, _S2100);
                    offer(sel_7, _S2111, _S2100 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S2112 = survivalProbability(abs_0(throughput_12), density_3);
                    uint _S2113 = noiseAddress(_S1507, b_11);
                    Random _S2114 = draw(_S2113, 8U);
                    bool _S2115 = _S2112 < (_S2114.value);
                    if(_S2115)
                    {
                        _S1863 = true;
                    }
                    else
                    {
                        uint _S2116 = (fcptMaxBounces());
                        _S1863 = b_11 >= _S2116;
                    }
                    if(_S1863)
                    {
                        _S1478 = int(1);
                        ended_0 = _S1480;
                        spread_4 = _S2078;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_8 = b_11;
                        break;
                    }
                    float _S2117 = density_3 * _S2112;
                    density_3 = _S2117;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S2118 = noiseAddress(_S1507, b_11);
                float3  _S2119 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S2118, &phase_pdf_1);
                (&ray_2)->unit_direction = _S2119;
                NEEVertex _S2120 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1479, (&ray_2)->origin);
                nee_vertex_0 = _S2120;
                Vertex _S2121 = scatteredVertex_0(is_inside_6);
                prev_0 = _S2121;
                float _S2122 = (&prev_0)->pdf;
                FKRay _S2123 = ray_2;
                FKHit _S2124 = (fcptTraverseInstanceBVH((_S2123), (true), (4.294967296e+09f), (false), (_S1752), (false)));
                hit_4 = _S2124;
                b_10 = b_11;
                throughput_11 = throughput_12;
                spread_3 = _S2078;
                width_4 = width_7;
                sky_pdf_1 = _S2122;
            }
            if(_S1478 != int(2))
            {
                spread_3 = spread_4;
                width_4 = width_5;
                throughput_11 = throughput_9;
                b_10 = b_8;
                _S1859 = true;
                break;
            }
            ended_0 = _S1480;
            _S1859 = false;
            break;
        }
        if(_S1859)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1860 = b_10 == b_7;
        }
        else
        {
            _S1860 = false;
        }
        bool _S2125 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S2125)
        {
            bool _S2126 = !(&nee_vertex_0)->none;
            float _S2127 = _slang_select(_S2126, sky_pdf_1,0.0f);
            float _S2128 = escapeWeight_0(_S2127, (&ray_2)->unit_direction);
            float3  _S2129 = environment_0((&ray_2)->unit_direction, b_10, (&prev_0)->lobe);
            float3  _S2130 = pathColor(throughput_11 * _S2129, spectral_weight_0, wavelength_8);
            if(replay_2)
            {
                bool _S2131 = b_10 == _S1495;
                if(_S2131)
                {
                    passes_0 = _S1484 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S2130 * make_float3 (_S2128) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1494)
                {
                    passes_0 = _S1491;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_10 == _S1482;
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
                    return Shift_x24init_0(_S2130 * make_float3 (_S2128), 1.0f);
                }
                return _S1480;
            }
            Reservoir candidate_10 = chain_0;
            uint _S2132 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S2133 = _S2132 == 1U;
            if(_S2133)
            {
                uint _S2134 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S2135 = _S2134 == b_10;
                float _S2136 = _slang_select(_S2135, 1.0f,_S2128);
                float3  _S2137 = safeDivide(_S2130 * make_float3 (_S2136), chain_throughput_0);
                (&candidate_10)->radiance = _S2137;
            }
            else
            {
                bool _S2138 = (&prev_0)->rough;
                if(_S2138)
                {
                    uint _S2139 = insertBits_0(_S1509, b_10 + 1U, 5U, 5U);
                    uint _S2140 = insertBits_0(_S2139, 3U, 10U, 2U);
                    uint _S2141 = insertBits_0(_S2140, (&prev_0)->lobe, 15U, 3U);
                    bool _S2142 = (&prev_0)->inside;
                    uint _S2143 = _slang_select(_S2142, 1U,0U);
                    uint _S2144 = insertBits_0(_S2141, _S2143, 22U, 1U);
                    (&candidate_10)->path = _S2144;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S2145 = _S2130 * make_float3 (_S2128);
            Reservoir _S2146 = withEnd(candidate_10, 3U, b_10, _S2145);
            offer(sel_7, _S2146, _S2145 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S2147 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S2147;
        bool _S2148 = (fcptVaryingUsed());
        if(_S2148)
        {
            _S1861 = filling_2 != 4294967295U;
        }
        else
        {
            _S1861 = false;
        }
        if(_S1861)
        {
            if(_S1706)
            {
                float3  _S2149 = pathColor(throughput_11 * glowed_0, spectral_weight_0, wavelength_8);
                float3  _S2150 = _S2149 / make_float3 (density_3);
                float3  _S2151 = sel_7->glow + _S2150;
                sel_7->glow = _S2151;
            }
            float3  _S2152 = throughput_11 * weight_2;
            throughput_9 = _S2152;
        }
        else
        {
            float3  _S2153 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S2154 = throughput_11 * _S2153;
            throughput_9 = _S2154;
        }
        float _S2155 = width_4 + spread_3 * (&hit_4)->distance;
        viewed_0 = _S1860;
        width_3 = _S2155;
        throughput_2 = throughput_9;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_3;
        uint _S2037 = b_10 + 1U;
        b_7 = _S2037;
        layer_0 = _S2036;
    }
    return _S1480;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_9)
{
    Selection _S2156 = (Selection{});
    Selection sel_8 = _S2156;
    bool _S2157 = (r_9->w) <= 0.0f;
    if(_S2157)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S2158 = walk_0(dom_8, r_9, true, 0.0f, &sel_8);
    return _S2158;
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
    Random _S2159 = pcg(state_5);
    Random _S2160 = pcg(_S2159.state);
    float _S2161 = 6.28318548202514648f * _S2159.value;
    float _S2162 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S2160.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S2160.state, _S2162 * (F32_cos((_S2161))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_6, float3  value_2)
{
    RandomSphere _S2163;
    (&_S2163)->state = state_6;
    (&_S2163)->value = value_2;
    return _S2163;
}

__device__ RandomSphere random_sphere(uint state_7)
{
    Random _S2164 = normal_distribution(state_7);
    Random _S2165 = normal_distribution(_S2164.state);
    Random _S2166 = normal_distribution(_S2165.state);
    float3  _S2167 = make_float3 (_S2164.value, _S2165.value, _S2166.value);
    float3  _S2168 = ((((_S2167)) * make_float3(rnorm3df(((_S2167)).x, ((_S2167)).y, ((_S2167)).z))));
    return RandomSphere_x24init_0(_S2166.state, _S2168);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_13)
{
    float3  _S2169 = p1_0 - p0_0;
    float3  _S2170 = p2_0 - p0_0;
    float2  _S2171 = uv1_0 - uv0_0;
    float2  _S2172 = uv2_0 - uv0_0;
    float _S2173 = _S2171.x;
    float _S2174 = _S2172.y;
    float _S2175 = _S2171.y;
    float _S2176 = _S2172.x;
    float _S2177 = _S2173 * _S2174 - _S2175 * _S2176;
    float _S2178 = 1.0f / _S2177;
    float3  t_24 = (_S2169 * make_float3 (_S2174) - _S2170 * make_float3 (_S2175)) * make_float3 (_S2178);
    float3  _S2179 = (_S2170 * make_float3 (_S2173) - _S2169 * make_float3 (_S2176)) * make_float3 (_S2178);
    float3  _S2180 = t_24 - n_13 * make_float3 (dot_0(n_13, t_24));
    float3  t_25 = ((((_S2180)) * make_float3(rnorm3df(((_S2180)).x, ((_S2180)).y, ((_S2180)).z))));
    bool _S2181 = (dot_0(cross_0(n_13, t_25), _S2179)) > 0.0f;
    float3  t_26;
    if(_S2181)
    {
        float3  _S2182 = negate_0(t_25);
        t_26 = _S2182;
    }
    else
    {
        t_26 = t_25;
    }
    float3  _S2183 = cross_0(n_13, t_26);
    return makeMatrix<float, 3, 3> (t_26, _S2183, n_13);
}

__device__ float3  tangentToWorldNormalMap(float3  v_13, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_13, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S2184 = t1_0 - t0_0;
    float3  _S2185 = t2_2 - t0_0;
    float3  _S2186 = t2_2 - t1_0;
    float _S2187 = (F32_min((length_0(_S2184)), ((F32_min((length_0(_S2185)), (length_0(_S2186)))))));
    float3  _S2188 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S2189 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S2190 = dot_0(geometry_n_5, _S2189);
    float3  _S2191 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S2192 = dot_0(geometry_n_5, _S2191);
    float3  _S2193 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S2194 = acos_0(abs_0(make_float3 (_S2190, _S2192, dot_0(geometry_n_5, _S2193))));
    float3  _S2195 = clamp_2(tan_0(_S2194), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S2188 * _S2195, uvw_0), 0.0f, _S2187 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_16, float3  n_14, BSDFMaterial material_29)
{
    float3  _S2196 = negate_0(dir_16);
    float _S2197 = sign_0(dot_0(n_14, _S2196));
    float3  _S2198 = n_14 * make_float3 (_S2197);
    AnisotropicFrame _S2199 = anisotropicFrame(material_29, _S2198);
    bool _S2200 = (_S2199.alphas.x) > 0.0f;
    if(_S2200)
    {
        float _S2201 = material_29.transmission * (1.0f - material_29.metallic);
        float3  _S2202 = negate_0(_S2198);
        float3  _S2203 = anisotropicLocal(dir_16, _S2199.tangent, _S2202);
        float _S2204 = anisotropicG1(_S2203, _S2199.alphas);
        return make_float3 (_S2201 * _S2204) * material_29.albedo;
    }
    float _S2205 = material_29.transmission * (1.0f - material_29.metallic);
    float _S2206 = material_29.roughness;
    float _S2207 = smithG1(_S2206 * _S2206, (F32_abs((dot_0(n_14, dir_16)))));
    return make_float3 (_S2205 * _S2207) * material_29.albedo;
}

__device__ float hairRow(float3  in_dir_13, float3  t_27, float3  out_dir_3, uint p_15, float w_20, float alpha_10, uint nt_0)
{
    uint _S2208 = p_15 % 4U;
    float _S2209 = w_20 * HAIR_WIDTHS_0[_S2208];
    float _S2210 = (F32_asin((clamp_1(dot_0(out_dir_3, t_27), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_13, t_27), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S2208] * alpha_10;
    return ((F32_asinh((_S2210 / _S2209))) / (F32_asinh((3.14159274101257324f / _S2209))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_14, float3  t_28, float3  out_dir_4, uint np_0)
{
    float3  _S2211 = worldToTangent(out_dir_4, t_28);
    float3  _S2212 = worldToTangent(in_dir_14, t_28);
    return (F32_frac((((F32_atan2((_S2211.z), (_S2211.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S2212.z), (1.17549435082228751e-38f - _S2212.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_15, float3  t_29, uint p_16, float row_0, float column_0, float w_21, float alpha_11, uint nt_1, uint np_1)
{
    float3  _S2213 = worldToTangent(in_dir_15, t_29);
    uint _S2214 = p_16 % 4U;
    float _S2215 = w_21 * HAIR_WIDTHS_0[_S2214];
    float _S2216 = (F32_asin((clamp_1(dot_0(in_dir_15, t_29), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S2214] * alpha_11 + _S2215 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S2215))))));
    float _S2217 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S2213.z), (1.17549435082228751e-38f - _S2213.x)));
    float _S2218 = (F32_cos((_S2216)));
    float3  _S2219 = tangentToWorld(make_float3 (_S2218 * (F32_cos((_S2217))), (F32_sin((_S2216))), _S2218 * (F32_sin((_S2217)))), t_29);
    return _S2219;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_15, BSDFMaterial material_30, float coverage_1)
{
    float3  through_2;
    if((material_30.ior) == 1.0f)
    {
        float3  _S2220 = straightThrough(toward_1, n_15, material_30);
        through_2 = _S2220;
    }
    else
    {
        through_2 = make_float3 (0.0f);
    }
    CoatFrame _S2221 = coatFrame(material_30, n_15);
    bool _S2222 = (_S2221.ior) > 0.0f;
    if(_S2222)
    {
        float _S2223 = fresnel((F32_abs((dot_0(_S2221.normal, toward_1)))), 1.0f, _S2221.ior);
        float3  _S2224 = mix_0(make_float3 (1.0f), make_float3 (1.0f - _S2223) * material_30.coat_tint, material_30.coat);
        float3  through_3 = through_2 * _S2224;
        through_2 = through_3;
    }
    return through_2 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_4, Selection * sel_9)
{
    Domain _S2225 = dom_9;
    Reservoir _S2226 = r_10;
    Shift _S2227 = walk_0(&_S2225, &_S2226, replay_3, scale_4, sel_9);
    return _S2227;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_11)
{
    Domain _S2228 = dom_10;
    Reservoir _S2229 = r_11;
    Shift _S2230 = shift_0(&_S2228, &_S2229);
    return _S2230;
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
        uint _S2231;
        if(i_27 < 2U)
        {
            _S2231 = x_29;
        }
        else
        {
            _S2231 = (x_29 + size_0 / 2U) & (size_0 - 1U);
        }
        uint l_6 = _S2231;
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
            uint _S2232 = hash(((r_12 ^ (t_30 << 16U)) ^ (k_4 << 28U)) ^ ((i_27 & 1U) << 31U));
            uint _S2233 = l_6 ^ (_S2232 & (size_0 - 1U));
            uint k_5 = k_4 + 1U;
            l_6 = r_12;
            r_12 = _S2233;
            k_4 = k_5;
        }
        uint _S2234 = l_6 + r_12 * size_0;
        uint _S2235 = size_0 * size_0;
        uint _S2236;
        if(_S2235 >= 65536U)
        {
            uint _S2237 = _S2234 / (_S2235 / 65536U);
            _S2236 = _S2237;
        }
        else
        {
            uint _S2238 = 65536U / _S2235;
            _S2236 = _S2234 * _S2238;
        }
        ranks_0[i_27] = _S2236;
        uint i_28 = i_27 + 1U;
        i_27 = i_28;
    }
    bool _S2239 = (ranks_0[int(0)]) == 65535U;
    bool _S2240;
    if(_S2239)
    {
        _S2240 = (ranks_0[int(1)]) == 65535U;
    }
    else
    {
        _S2240 = false;
    }
    bool _S2241 = (ranks_0[int(2)]) == 65535U;
    bool _S2242;
    if(_S2241)
    {
        _S2242 = (ranks_0[int(3)]) == 65535U;
    }
    else
    {
        _S2242 = false;
    }
    if(_S2240)
    {
        _S2240 = (ranks_0[int(3)]) != 65535U;
    }
    else
    {
        _S2240 = false;
    }
    if(_S2240)
    {
        _S2240 = true;
    }
    else
    {
        if(_S2242)
        {
            _S2240 = (ranks_0[int(1)]) != 65535U;
        }
        else
        {
            _S2240 = false;
        }
    }
    uint _S2243 = ranks_0[int(0)];
    if(_S2240)
    {
        i_27 = ranks_0[int(3)];
    }
    else
    {
        i_27 = ranks_0[int(1)];
    }
    return _S2243 | (i_27 << 16U);
}

__device__ uint3  noiseBlock(uint sweep_0, uint colour_0, uint block_0, uint size_1)
{
    uint _S2244 = hash(sweep_0 * 7919U + 1U);
    uint _S2245 = size_1 / 16U;
    uint _S2246 = block_0 % _S2245;
    uint _S2247 = block_0 / _S2245;
    uint _S2248 = _S2247 % _S2245;
    uint _S2249 = block_0 / (_S2245 * _S2245);
    uint3  _S2250 = make_uint3 (_S2246, _S2248, _S2249);
    uint3  _S2251 = make_uint3 (colour_0 & 1U, (colour_0 >> 1U) & 1U, colour_0 >> 2U);
    return _S2250 * make_uint3 (16U) + _S2251 * make_uint3 (8U) + make_uint3 (_S2244 & 7U, (_S2244 >> 3U) & 7U, (_S2244 >> 6U) & 7U);
}

#undef Matrix
