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

struct Random
{
    uint state;
    float value;
};

static __device__ Random Random_x24init_0(uint state_0, float value_0)
{
    Random _S296;
    (&_S296)->state = state_0;
    (&_S296)->value = value_0;
    return _S296;
}

__device__ Random pcg(uint state_1)
{
    uint _S297 = hash(state_1);
    float value_1 = float(_S297 >> int(8)) * 5.9604644775390625e-08f;
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

__device__ float upsample(float3  rgb_0, float wavelength_0)
{
    float _S310 = dot_0(make_float3 (-0.08011700212955475f, 1.08901798725128174f, -0.00889899954199791f), rgb_0);
    float _S311 = dot_0(make_float3 (0.12177000194787979f, -1.22903203964233398f, 1.10724997520446777f), rgb_0);
    float _S312 = dot_0(make_float3 (1.17252397537231445f, -1.21603405475616455f, 0.04350199922919273f), rgb_0);
    float3  _S313 = make_float3 (_S310, _S311, _S312);
    float _S314 = (wavelength_0 - 0.44999998807907104f) / 0.02999999932944775f;
    float _S315 = (wavelength_0 - 0.63999998569488525f) / 0.03999999910593033f;
    return _S310 + _S311 * (F32_exp((-0.5f * _S314 * _S314))) + _S312 * (F32_exp((-0.5f * _S315 * _S315)));
}

__device__ BSDFMaterial atWavelength(BSDFMaterial material_0, float wavelength_1)
{
    BSDFMaterial at_0 = material_0;
    float _S316 = upsample(material_0.albedo, wavelength_1);
    float3  _S317 = make_float3 (_S316);
    (&at_0)->albedo = _S317;
    float _S318 = upsample(material_0.emissive, wavelength_1);
    float3  _S319 = make_float3 (_S318);
    (&at_0)->emissive = _S319;
    float _S320 = upsample(material_0.absorption, wavelength_1);
    float3  _S321 = make_float3 (_S320);
    (&at_0)->absorption = _S321;
    float _S322 = upsample(material_0.specular_tint, wavelength_1);
    float3  _S323 = make_float3 (_S322);
    (&at_0)->specular_tint = _S323;
    float _S324 = upsample(material_0.translucent, wavelength_1);
    float3  _S325 = make_float3 (_S324);
    (&at_0)->translucent = _S325;
    float _S326 = upsample(material_0.sheen, wavelength_1);
    float3  _S327 = make_float3 (_S326);
    (&at_0)->sheen = _S327;
    return at_0;
}

__device__ BSDFMaterial pathMaterial(BSDFMaterial material_1, float wavelength_2)
{
    BSDFMaterial _S328;
    if(wavelength_2 > 0.0f)
    {
        BSDFMaterial _S329 = atWavelength(material_1, wavelength_2);
        _S328 = _S329;
    }
    else
    {
        _S328 = material_1;
    }
    return _S328;
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    float _S330;
    if(e_1 > 0.0f)
    {
        _S330 = 1.0f;
    }
    else
    {
        if(e_1 < 0.0f)
        {
            _S330 = -1.0f;
        }
        else
        {
            _S330 = 0.0f;
        }
    }
    return _S330;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S331;
    (&_S331)->tangent = tangent_0;
    (&_S331)->alphas = alphas_0;
    return _S331;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S332 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S332)
    {
        float3  _S333 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S333;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S334 = cross_0(n_1, a_2);
    float3  _S335 = ((((_S334)) * make_float3(rnorm3df(((_S334)).x, ((_S334)).y, ((_S334)).z))));
    float3  _S336 = cross_0(n_1, _S335);
    return make_float3 (v_0.x) * _S335 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S336;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_2, float3  n_i_0)
{
    float _S337 = material_2.roughness;
    float _S338 = _S337 * _S337;
    bool _S339 = (material_2.anisotropy) == 0.0f;
    bool _S340;
    if(_S339)
    {
        _S340 = true;
    }
    else
    {
        _S340 = !(_S338 > 0.0f);
    }
    if(_S340)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S341 = material_2.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_2.tangent));
    float3  _S342 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S343 = (dot_0(_S341, _S341)) > 0.0f;
    float3  _S344 = _slang_select(_S343, _S341,_S342);
    float3  _S345 = ((((_S344)) * make_float3(rnorm3df(((_S344)).x, ((_S344)).y, ((_S344)).z))));
    float _S346 = 6.28318548202514648f * material_2.anisotropic_rotation;
    float _S347 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_2.anisotropy))))));
    float _S348 = 1.0f / _S347;
    bool _S349 = (material_2.anisotropy) < 0.0f;
    float _S350 = _slang_select(_S349, _S348,_S347);
    return AnisotropicFrame_x24init_0(_S345 * make_float3 ((F32_cos((_S346)))) + cross_0(n_i_0, _S345) * make_float3 ((F32_sin((_S346)))), make_float2 (_S338 / _S350, _S338 * _S350));
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S351;
    (&_S351)->on = on_0;
    (&_S351)->albedo = albedo_0;
    return _S351;
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
    SheenProfile _S352 = SheenProfile_x24init_0(false, 0.0f);
    float _S353 = rgb_to_greyscale(material_3.sheen);
    bool _S354 = _S353 > 0.0f;
    SheenProfile profile_0;
    if(_S354)
    {
        float _S355 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S356 = (U32_min((uint(_S355)), (22U)));
        float _S357 = (F32_sqrt((0.05000000074505806f)));
        float _S358 = (F32_sqrt((0.10000000149011612f)));
        bool _S359 = (material_3.velvet) > 0.0f;
        float _S360 = _slang_select(_S359, _S358,_S357);
        float _S361 = (clamp_1((F32_sqrt(((F32_max((material_3.sheen_roughness), (0.0f)))))), _S360, 1.0f) - _S360) / (1.0f - _S360) * 23.0f;
        uint _S362 = (U32_min((uint(_S361)), (22U)));
        uint _S363 = _S356 * 24U + _S362;
        float _S364 = _S355 - float(_S356);
        float _S365 = _S361 - float(_S362);
        if(_S359)
        {
            uint _S366 = _S363 + 24U;
            float _S367 = VELVET_ALBEDO_0[_S363] + (VELVET_ALBEDO_0[_S366] - VELVET_ALBEDO_0[_S363]) * _S364;
            uint _S368 = _S363 + 1U;
            float _S369 = VELVET_ALBEDO_0[_S368] + (VELVET_ALBEDO_0[_S366 + 1U] - VELVET_ALBEDO_0[_S368]) * _S364;
            SheenProfile _S370 = SheenProfile_x24init_0(true, _S367 + (_S369 - _S367) * _S365);
            profile_0 = _S370;
        }
        else
        {
            uint _S371 = _S363 + 24U;
            float _S372 = SHEEN_ALBEDO_0[_S363] + (SHEEN_ALBEDO_0[_S371] - SHEEN_ALBEDO_0[_S363]) * _S364;
            uint _S373 = _S363 + 1U;
            float _S374 = SHEEN_ALBEDO_0[_S373] + (SHEEN_ALBEDO_0[_S371 + 1U] - SHEEN_ALBEDO_0[_S373]) * _S364;
            SheenProfile _S375 = SheenProfile_x24init_0(true, (F32_exp((_S372 + (_S374 - _S372) * _S365))));
            profile_0 = _S375;
        }
    }
    else
    {
        profile_0 = _S352;
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
    Weights _S376;
    (&_S376)->v_dot_h = v_dot_h_0;
    (&_S376)->refracted = refracted_1;
    (&_S376)->F = F_0;
    (&_S376)->reflect_weight = reflect_weight_0;
    (&_S376)->diffuse_weight = diffuse_weight_0;
    (&_S376)->refract_weight = refract_weight_0;
    (&_S376)->p_diffuse = p_diffuse_0;
    (&_S376)->p_reflect = p_reflect_0;
    (&_S376)->p_refract = p_refract_0;
    (&_S376)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S376)->p_toon = p_toon_0;
    (&_S376)->sheen = sheen_0;
    (&_S376)->toon = toon_0;
    return _S376;
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
    float3  _S377 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S378 = ((((_S377)) * make_float3(rnorm3df(((_S377)).x, ((_S377)).y, ((_S377)).z))));
    float _S379 = _S378.x;
    float _S380 = _S378.y;
    float _S381 = _S379 * _S379 + _S380 * _S380;
    float3  _S382;
    if(_S381 > 0.0f)
    {
        float3  _S383 = make_float3 (- _S380, _S379, 0.0f);
        float _S384 = (rsqrtf((_S381)));
        _S382 = _S383 * make_float3 (_S384);
    }
    else
    {
        _S382 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S385 = cross_0(_S378, _S382);
    float _S386 = (F32_sqrt((U1_0)));
    float _S387 = 6.28318548202514648f * U2_0;
    float _S388 = _S386 * (F32_cos((_S387)));
    float t2_0 = _S386 * (F32_sin((_S387)));
    float _S389 = 0.5f * (1.0f + _S378.z);
    float t2_1 = (1.0f - _S389) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S388 * _S388)))))) + _S389 * t2_0;
    float3  _S390 = make_float3 (_S388) * _S382 + make_float3 (t2_1) * _S385;
    float _S391 = unshared_0(_S388);
    float _S392 = unshared_0(_S388);
    float3  _S393 = _S390 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S391 * _S392 - t2_1 * t2_1))))))) * _S378;
    float3  _S394 = make_float3 (alpha_0 * _S393.x, alpha_0 * _S393.y, (F32_max((0.0f), (_S393.z))));
    float3  _S395 = ((((_S394)) * make_float3(rnorm3df(((_S394)).x, ((_S394)).y, ((_S394)).z))));
    return _S395;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S396 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S396)
    {
        float3  _S397 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S397;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S398 = cross_0(n_3, a_4);
    float3  _S399 = ((((_S398)) * make_float3(rnorm3df(((_S398)).x, ((_S398)).y, ((_S398)).z))));
    float3  _S400 = cross_0(n_3, _S399);
    return make_float3 (dot_0(v_2, _S399), dot_0(v_2, n_3), dot_0(v_2, _S400));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S401 = pcg(*random_state_2);
    Random _S402 = pcg(_S401.state);
    *random_state_2 = _S402.state;
    float _S403 = frame_0.alphas.x;
    bool _S404 = _S403 > 0.0f;
    if(_S404)
    {
        float3  _S405 = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        float _S406 = frame_0.alphas.y;
        float3  _S407 = make_float3 (_S403 * _S405.x, _S406 * _S405.y, _S405.z);
        float3  _S408 = ((((_S407)) * make_float3(rnorm3df(((_S407)).x, ((_S407)).y, ((_S407)).z))));
        float3  _S409 = sampleGGXVNDF(_S408, 1.0f, _S401.value, _S402.value);
        float3  _S410 = make_float3 (_S403 * _S409.x, _S406 * _S409.y, _S409.z);
        float3  _S411 = ((((_S410)) * make_float3(rnorm3df(((_S410)).x, ((_S410)).y, ((_S410)).z))));
        return make_float3 (_S411.x) * frame_0.tangent + make_float3 (_S411.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S411.z) * n_i_2;
    }
    float3  _S412 = worldToTangent(v_3, n_i_2);
    float3  _S413 = sampleGGXVNDF(float3 {_S412.x, _S412.z, _S412.y}, alpha_1, _S401.value, _S402.value);
    float3  _S414 = float3 {_S413.x, _S413.z, _S413.y};
    float3  _S415 = tangentToWorld(_S414, n_i_2);
    return _S415;
}

__device__ __forceinline__ float3  sampledHalf(float3  v_4, float3  n_i_3, float alpha_2, AnisotropicFrame frame_1, uint random_state_3)
{
    uint state_2 = random_state_3;
    float3  _S416 = sampleHalfVector(v_4, n_i_3, alpha_2, frame_1, &state_2);
    return _S416;
}

__device__ __forceinline__ float3  refractedHalf(float3  in_dir_0, float3  out_dir_0, float3  n_4, float eta_i_0, float eta_o_0)
{
    float3  _S417 = negate_0(in_dir_0);
    float3  _S418 = negate_0(make_float3 (eta_i_0) * _S417 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S419 = ((((_S418)) * make_float3(rnorm3df(((_S418)).x, ((_S418)).y, ((_S418)).z))));
    float _S420 = sign_0(dot_0(n_4, _S417));
    float _S421 = sign_0(dot_0(_S418, n_4 * make_float3 (_S420)));
    return _S419 * make_float3 (_S421);
}

__device__ __forceinline__ float3  reflectedHalf(float3  in_dir_1, float3  out_dir_1)
{
    float3  _S422 = negate_0(in_dir_1);
    float3  _S423 = _S422 + out_dir_1;
    float3  _S424 = ((((_S423)) * make_float3(rnorm3df(((_S423)).x, ((_S423)).y, ((_S423)).z))));
    return _S424;
}

static __device__ float3  refract_0(float3  i_5, float3  n_5, float eta_0)
{
    float _S425 = dot_0(n_5, i_5);
    float _S426 = 1.0f - eta_0 * eta_0 * (1.0f - _S425 * _S425);
    if(_S426 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S425 + (F32_sqrt((_S426)))) * n_5;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S427 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S428 = eta_i_1 / eta_o_1 * _S427;
    bool _S429 = _S428 < 1.0f;
    float kr_0;
    if(_S429)
    {
        float _S430 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S428 * _S428))))));
        float _S431 = eta_o_1 * cos_theta_0;
        float _S432 = eta_i_1 * _S430;
        float _S433 = (_S431 - _S432) / (_S431 + _S432);
        float _S434 = eta_i_1 * cos_theta_0;
        float _S435 = eta_o_1 * _S430;
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
    float _S438 = dot_0(ggx_n_0, v_5);
    float _S439 = eta_i_2 / eta_o_2;
    float3  _S440 = refract_0(in_dir_2, ggx_n_0, _S439);
    float3  _S441 = ((((_S440)) * make_float3(rnorm3df(((_S440)).x, ((_S440)).y, ((_S440)).z))));
    float _S442 = (F32_min(((F32_sqrt((material_4.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S443 = _S442 * _S442;
    float _S444 = (1.0f + _S442) / (1.0f - _S442);
    float _S445 = (F32_abs((_S438)));
    bool _S446 = eta_i_2 > eta_o_2;
    float sheen_component_0;
    if(_S446)
    {
        sheen_component_0 = _S444;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float toon_component_0;
    if(_S446)
    {
        toon_component_0 = 1.0f;
    }
    else
    {
        toon_component_0 = _S444;
    }
    float _S447 = fresnel(_S445, sheen_component_0, toon_component_0);
    bool _S448 = (eta_i_2 * eta_i_2 * (1.0f - _S438 * _S438)) >= (eta_o_2 * eta_o_2);
    float3  _S449;
    if(_S448)
    {
        _S449 = make_float3 (1.0f);
    }
    else
    {
        float3  _S450 = material_4.specular_tint * make_float3 (_S443);
        _S449 = _S450 + (make_float3 (1.0f) - _S450) * make_float3 (_S447 - _S443) / make_float3 (1.0f - _S443);
    }
    float3  _S451 = make_float3 (1.0f);
    float3  _S452 = make_float3 (0.0f);
    float3  sheen_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S453 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S454 = make_float3 (1.0f) - material_4.sheen * make_float3 (_S453);
        float _S455 = rgb_to_greyscale(material_4.sheen);
        float _S456 = _S455 * _S453;
        float3  _S457 = material_4.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S456;
        sheen_1 = _S457;
        scale_1 = _S454;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S452;
        scale_1 = _S451;
    }
    float _S458 = (F32_abs((material_4.toon.x)));
    bool _S459 = _S458 > 0.0f;
    float3  toon_1;
    if(_S459)
    {
        float _S460 = (F32_min((_S458), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S460);
        float _S461 = rgb_to_greyscale(material_4.albedo);
        float _S462 = _S460 * _S461;
        float3  _S463 = make_float3 (_S460) * material_4.albedo;
        toon_component_0 = _S462;
        toon_1 = _S463;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S452;
    }
    bool _S464 = (material_4.metallic) > 0.0f;
    float3  rebounce_0;
    if(_S464)
    {
        float _S465 = frame_2.alphas.x;
        float _S466 = (F32_sqrt(((F32_min((_S465), (frame_2.alphas.y))))));
        bool _S467 = _S465 > 0.0f;
        float _S468 = _slang_select(_S467, _S466,material_4.roughness);
        float _S469 = _S468 * _S468;
        float _S470 = (F32_pow((_S469), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S469) / (1.0f + 1.28094995021820068f * _S469);
        bool _S471 = _S469 > 0.0f;
        float _S472 = _slang_select(_S471, _S470,0.0f);
        float _S473 = clamp_1(dot_0(n_i_4, v_5), 0.0f, 1.0f);
        float _S474 = _S469 * _S468;
        float _S475 = (F32_min((1.00064504146575928f - _S468 * (0.00375499995425344f + _S473 * (-0.04133399948477745f + _S473 * (-0.90938502550125122f + _S473 * 0.35275399684906006f))) - _S469 * (0.27602800726890564f + _S473 * (1.27023398876190186f + _S473 * 0.04740000143647194f)) - _S474 * (0.31452900171279907f - _S473 * 0.34830701351165771f) + _S474 * _S468 * 0.27229699492454529f), (1.0f)));
        float3  _S476 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_4.albedo * make_float3 (_S472)), make_float3 (1.0f / (F32_max((_S475), (0.0000152587890625f)))));
        rebounce_0 = _S476;
    }
    else
    {
        rebounce_0 = _S451;
    }
    float3  _S477 = mix_0(_S449, material_4.albedo * rebounce_0, material_4.metallic);
    float3  F_1 = _S477 * scale_1;
    float _S478 = rgb_to_greyscale(F_1);
    float _S479 = 1.0f - material_4.metallic;
    float3  _S480 = make_float3 (1.0f) - _S449;
    float3  _S481 = make_float3 ((1.0f - material_4.transmission) * _S479) * _S480 * scale_1;
    float3  _S482 = make_float3 (material_4.transmission * _S479) * _S480 * scale_1;
    float _S483 = (F32_max((_S478), (0.0f)));
    float _S484 = rgb_to_greyscale(_S481);
    float _S485 = (F32_max((_S484), (0.0f)));
    float _S486 = rgb_to_greyscale(_S482);
    float _S487 = sign_0(length_0(_S441));
    float _S488 = (F32_max((_S486 * _S487), (0.0f)));
    float _S489 = _S483 + _S485 + _S488 + toon_component_0;
    float _S490 = (F32_min((sheen_component_0), (1.0f)));
    bool _S491 = sheen_component_0 > 0.0f;
    bool _S492;
    if(_S491)
    {
        _S492 = !(_S489 > 0.0f);
    }
    else
    {
        _S492 = false;
    }
    float _S493 = _slang_select(_S492, 1.0f,_S490);
    float _S494 = (1.0f - _S493) / (F32_max((_S489), (0.0000152587890625f)));
    float _S495 = _S485 * _S494;
    float _S496 = _S483 * _S494;
    float _S497 = _S488 * _S494;
    return Weights_x24init_0(_S438, _S441, F_1, 1.0f, _S481, _S482, _S495, _S496, _S497, _S493, toon_component_0 * _S494, sheen_1, toon_1);
}

__device__ float translucentShare(BSDFMaterial material_5)
{
    float _S498 = rgb_to_greyscale(material_5.translucent);
    float _S499 = rgb_to_greyscale(material_5.albedo);
    float _S500 = _S498 / (_S499 + _S498);
    bool _S501 = _S498 > 0.0f;
    float _S502 = _slang_select(_S501, _S500,0.0f);
    return _S502;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float n_i_dot_v_0, BSDFMaterial material_6, Weights w_1)
{
    float _S503 = translucentShare(material_6);
    float _S504 = w_1.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S505 = w_1.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S506 = 1.0f - _S503;
    bool _S507 = n_i_dot_l_0 < 0.0f;
    float _S508 = _slang_select(_S507, _S503,_S506);
    float _S509 = _S505 * _S508;
    bool _S510 = _S503 > 0.0f;
    float _S511 = _slang_select(_S510, _S509,_S504);
    bool _S512 = n_i_dot_v_0 > 0.0f;
    float _S513 = _slang_select(_S512, _S511,0.0f);
    return _S513;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_5, BSDFMaterial material_7, Weights w_2)
{
    float _S514 = translucentShare(material_7);
    bool _S515 = (dot_0(n_i_5, l_0)) < 0.0f;
    float3  _S516 = _slang_select(_S515, material_7.translucent,material_7.albedo);
    float _S517 = 1.0f - _S514;
    float _S518 = _slang_select(_S515, _S514,_S517);
    float3  _S519 = _S516 / make_float3 (_S518);
    bool _S520 = _S514 > 0.0f;
    float3  _S521 = _slang_select(_S520, _S519,material_7.albedo);
    return w_2.diffuse_weight * _S521 / make_float3 (w_2.p_diffuse);
}

__device__ float smithG1(float alpha_3, float n_dot_x_0)
{
    float _S522 = alpha_3 * alpha_3;
    float _S523 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S522 + (1.0f - _S522) * n_dot_x_0 * n_dot_x_0))));
    bool _S524 = alpha_3 > 0.0f;
    float _S525 = _slang_select(_S524, _S523,1.0f);
    return _S525;
}

__device__ float trowbridgeReitz(float alpha_4, float n_dot_h_0)
{
    float _S526 = alpha_4 * alpha_4;
    float _S527 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S526 * n_dot_h_0 * n_dot_h_0;
    return _S526 / (F32_max((3.14159274101257324f * _S527 * _S527), (1.17549435082228751e-38f)));
}

__device__ float anisotropicG1(float3  w_3, float2  alphas_1)
{
    float _S528 = (F32_max((w_3.z), (0.0f)));
    return 2.0f * _S528 / (_S528 + length_0(make_float3 (alphas_1.x * w_3.x, alphas_1.y * w_3.y, _S528)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S529 = alphas_2.x;
    float _S530 = h_0.x / _S529;
    float _S531 = alphas_2.y;
    float _S532 = h_0.y / _S531;
    float _S533 = h_0.z;
    float _S534 = _S530 * _S530 + _S532 * _S532 + _S533 * _S533;
    return 1.0f / (F32_max((3.14159274101257324f * _S529 * _S531 * _S534 * _S534), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float3  v_6, float3  h_1, float3  n_i_6, float n_i_dot_v_1, float alpha_5, AnisotropicFrame frame_3, float v_dot_h_1)
{
    float _S535 = dot_0(n_i_6, h_1);
    float _S536 = smithG1(alpha_5, n_i_dot_v_1);
    float _S537 = _S536 * v_dot_h_1;
    float _S538 = trowbridgeReitz(alpha_5, _S535);
    float _S539 = _S537 * _S538 / n_i_dot_v_1;
    bool _S540 = alpha_5 > 0.0f;
    bool _S541;
    if(_S540)
    {
        _S541 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S541 = false;
    }
    if(_S541)
    {
        _S541 = _S535 > 0.0f;
    }
    else
    {
        _S541 = false;
    }
    if(_S541)
    {
        _S541 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S541 = false;
    }
    float _S542 = _slang_select(_S541, _S539,0.0f);
    bool _S543 = (frame_3.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S543)
    {
        float3  _S544 = anisotropicLocal(v_6, frame_3.tangent, n_i_6);
        float _S545 = anisotropicG1(_S544, frame_3.alphas);
        float3  _S546 = anisotropicLocal(h_1, frame_3.tangent, n_i_6);
        float _S547 = anisotropicD(_S546, frame_3.alphas);
        float _S548 = _S545 * _S547;
        float _S549 = _S548 * v_dot_h_1 / n_i_dot_v_1;
        bool _S550 = v_dot_h_1 > 0.0f;
        if(_S550)
        {
            _S541 = _S535 > 0.0f;
        }
        else
        {
            _S541 = false;
        }
        if(_S541)
        {
            _S541 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S541 = false;
        }
        float _S551 = _slang_select(_S541, _S549,0.0f);
        pdf_h_0 = _S551;
    }
    else
    {
        pdf_h_0 = _S542;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float l_dot_h_0, float pdf_h_1, Weights w_4, float eta_i_3, float eta_o_3)
{
    float _S552 = eta_i_3 * w_4.v_dot_h + eta_o_3 * l_dot_h_0;
    float _S553 = w_4.p_refract * pdf_h_1 * eta_o_3 * eta_o_3 * (F32_abs((l_dot_h_0))) / (_S552 * _S552);
    bool _S554 = eta_i_3 != eta_o_3;
    bool _S555;
    if(_S554)
    {
        _S555 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S555 = false;
    }
    float _S556 = _slang_select(_S555, _S553,0.0f);
    return _S556;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_7, float alpha_6, AnisotropicFrame frame_4, BSDFMaterial material_8, Weights w_5)
{
    float _S557 = - dot_0(n_i_7, l_1);
    float _S558 = smithG1(alpha_6, (F32_max((_S557), (0.0f))));
    bool _S559 = (frame_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S559)
    {
        float3  _S560 = negate_0(n_i_7);
        float3  _S561 = anisotropicLocal(l_1, frame_4.tangent, _S560);
        float _S562 = anisotropicG1(_S561, frame_4.alphas);
        G1_l_0 = _S562;
    }
    else
    {
        G1_l_0 = _S558;
    }
    return w_5.refract_weight * make_float3 (G1_l_0) * material_8.albedo / make_float3 (w_5.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_1, float n_i_dot_v_2, Weights w_6)
{
    float _S563 = w_6.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S564 = n_i_dot_l_1 > 0.0f;
    bool _S565;
    if(_S564)
    {
        _S565 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S565 = false;
    }
    float _S566 = _slang_select(_S565, _S563,0.0f);
    return _S566;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  v_7, float3  n_i_8, BSDFMaterial material_9, Weights w_7)
{
    float3  _S567 = l_2 + v_7;
    float3  _S568 = ((((_S567)) * make_float3(rnorm3df(((_S567)).x, ((_S567)).y, ((_S567)).z))));
    float _S569 = dot_0(n_i_8, _S568);
    float _S570 = (F32_max((dot_0(n_i_8, l_2)), (0.0f)));
    float _S571 = (F32_max((dot_0(n_i_8, v_7)), (0.0f)));
    float _S572 = 1.0f / (F32_max((material_9.sheen_roughness), (0.05000000074505806f)));
    float _S573 = 1.0f - _S569 * _S569;
    float _S574 = (2.0f + _S572) * (F32_pow(((F32_max((_S573), (0.0f)))), (0.5f * _S572))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S570 + _S571 - _S570 * _S571)), (0.0000152587890625f)));
    bool _S575 = (material_9.velvet) > 0.0f;
    float f_1;
    if(_S575)
    {
        float _S576 = (F32_max((material_9.sheen_roughness), (0.00999999977648258f)));
        float _S577 = _S576 * _S576;
        float _S578 = (F32_max((_S573), (0.0000152587890625f)));
        float _S579 = (F32_exp((- _S569 * _S569 / (_S578 * _S577)))) / (3.14159274101257324f * _S577 * _S578 * _S578) * (F32_min((1.0f), (2.0f * _S569 * (F32_min((_S570), (_S571))) / (F32_max(((F32_abs((dot_0(_S568, v_7))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S570 * _S571), (0.0000152587890625f)));
        f_1 = _S579;
    }
    else
    {
        f_1 = _S574;
    }
    return w_7.sheen * make_float3 (f_1 * _S570 * 2.0f * 3.14159274101257324f / w_7.p_sheen_velvet);
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
    float _S580;
    if(t_13 < a_5)
    {
        _S580 = 1.0f;
    }
    else
    {
        _S580 = (F32_max((1.0f - (t_13 - a_5) / (F32_max((s_0), (0.0000152587890625f)))), (0.0f)));
    }
    return _S580;
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
        float _S581 = (F32_sin(((F32_min((t_14), (a_6))))));
        integral_0 = _S581 * _S581 / 2.0f;
    }
    bool _S582 = t_14 > a_6;
    bool _S583;
    if(_S582)
    {
        _S583 = s_1 > 0.0f;
    }
    else
    {
        _S583 = false;
    }
    if(_S583)
    {
        float _S584;
        if(glossy_0)
        {
            float _S585 = (F32_cos((a_6)));
            float _S586 = (F32_cos((t_14)));
            _S584 = (1.0f + a_6 / s_1) * (_S585 - _S586) - ((F32_sin((t_14))) - t_14 * _S586 - ((F32_sin((a_6))) - a_6 * _S585)) / s_1;
        }
        else
        {
            float _S587 = 2.0f * a_6;
            float _S588 = (F32_cos((_S587)));
            float _S589 = 2.0f * t_14;
            float _S590 = (F32_cos((_S589)));
            _S584 = (1.0f + a_6 / s_1) * (_S588 - _S590) / 4.0f - ((F32_sin((_S589))) / 8.0f - t_14 * _S590 / 4.0f - ((F32_sin((_S587))) / 8.0f - a_6 * _S588 / 4.0f)) / s_1;
        }
        float integral_1 = integral_0 + _S584;
        integral_0 = integral_1;
    }
    return integral_0;
}

static __device__ ToonProfile ToonProfile_x24init_0(bool glossy_1, float a_7, float s_2, float b_1, float norm_0, float view_0, float3  axis_0)
{
    ToonProfile _S591;
    (&_S591)->glossy = glossy_1;
    (&_S591)->a = a_7;
    (&_S591)->s = s_2;
    (&_S591)->b = b_1;
    (&_S591)->norm = norm_0;
    (&_S591)->view = view_0;
    (&_S591)->axis = axis_0;
    return _S591;
}

__device__ __forceinline__ ToonProfile toonProfile(float3  v_8, float3  n_i_9, BSDFMaterial material_10)
{
    float _S592 = material_10.toon.x;
    bool _S593 = _S592 < 0.0f;
    float _S594 = clamp_1(material_10.toon.y / _S592, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S595 = clamp_1(material_10.toon.z / _S592, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S596 = (F32_min((_S594 + _S595), (1.57079637050628662f)));
    float _S597 = dot_0(n_i_9, v_8);
    float _S598 = toonP((F32_acos(((F32_min((_S597), (1.0f)))))), _S594, _S595);
    float3  _S599;
    if(_S593)
    {
        float3  _S600 = make_float3 (2.0f * _S597) * n_i_9 - v_8;
        float3  _S601 = ((((_S600)) * make_float3(rnorm3df(((_S600)).x, ((_S600)).y, ((_S600)).z))));
        _S599 = _S601;
    }
    else
    {
        _S599 = n_i_9;
    }
    float _S602 = toonIntegral(_S596, _S594, _S595, _S593);
    return ToonProfile_x24init_0(_S593, _S594, _S595, _S596, 6.28318548202514648f * _S602, _S598, _S599);
}

__device__ __forceinline__ float toonPDF(float3  l_3, float3  n_i_10, ToonProfile profile_1, Weights w_8)
{
    float _S603 = dot_0(n_i_10, l_3);
    float _S604 = dot_0(l_3, profile_1.axis);
    float _S605 = _slang_select(profile_1.glossy, _S604,_S603);
    float _S606 = (F32_acos((clamp_1(_S605, -1.0f, 1.0f))));
    float _S607 = toonP(_S606, profile_1.a, profile_1.s);
    float _S608 = w_8.p_toon * _S607;
    float _S609 = _slang_select(profile_1.glossy, 1.0f,_S603);
    float _S610 = _S608 * _S609 / profile_1.norm;
    bool _S611;
    if(profile_1.glossy)
    {
        _S611 = true;
    }
    else
    {
        _S611 = _S603 > 0.0f;
    }
    float _S612 = _slang_select(_S611, _S610,0.0f);
    return _S612;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_4, float3  n_i_11, ToonProfile profile_2, Weights w_9)
{
    float _S613 = (F32_max((dot_0(n_i_11, l_4)), (0.0f)));
    float _S614 = _slang_select(profile_2.glossy, _S613,profile_2.view);
    return w_9.toon * make_float3 (_S614) / make_float3 (w_9.p_toon);
}

__device__ __forceinline__ float reflectPDF(float pdf_h_2, Weights w_10)
{
    float _S615 = w_10.p_reflect * pdf_h_2 / (4.0f * w_10.v_dot_h);
    bool _S616 = pdf_h_2 > 0.0f;
    float _S617 = _slang_select(_S616, _S615,0.0f);
    return _S617;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_5, float3  n_i_12, float alpha_7, AnisotropicFrame frame_5, Weights w_11)
{
    float _S618 = dot_0(n_i_12, l_5);
    float _S619 = smithG1(alpha_7, (F32_max((_S618), (0.0f))));
    bool _S620 = (frame_5.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S620)
    {
        float3  _S621 = anisotropicLocal(l_5, frame_5.tangent, n_i_12);
        float _S622 = anisotropicG1(_S621, frame_5.alphas);
        G1_l_1 = _S622;
    }
    else
    {
        G1_l_1 = _S619;
    }
    return make_float3 (w_11.reflect_weight * G1_l_1) * w_11.F / make_float3 (w_11.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_3, float3  out_dir_2, float3  n_6, BSDFMaterial material_11, float eta_i_4, float eta_o_4, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S623 = negate_0(in_dir_3);
    float _S624 = dot_0(n_6, _S623);
    float _S625 = sign_0(_S624);
    float3  _S626 = n_6 * make_float3 (_S625);
    float _S627 = dot_0(_S626, out_dir_2);
    float _S628 = material_11.roughness;
    float _S629 = _S628 * _S628;
    AnisotropicFrame _S630 = anisotropicFrame(material_11, _S626);
    SheenProfile _S631 = sheenProfile(_S623, _S626, material_11);
    float _S632 = rgb_to_greyscale(material_11.translucent);
    bool _S633 = _S632 > 0.0f;
    bool _S634 = (dot_0(n_6, out_dir_2) * _S624) < 0.0f;
    bool _S635 = (F32_abs((material_11.toon.x))) > 0.0f;
    uint _S636;
    if(_S635)
    {
        _S636 = 5U;
    }
    else
    {
        _S636 = 4U;
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
        float3  _S637 = make_float3 (0.0f);
        (*throughputs_0)[i_7] = _S637;
        (*pdfs_0)[i_7] = 0.0f;
        uint i_8 = i_7 + 1U;
        i_7 = i_8;
    }
    float3  _S638 = make_float3 (0.0f);
    Weights _S639 = Weights_x24init_0(0.0f, _S638, _S638, 0.0f, _S638, _S638, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S638, _S638);
    uint half_of_0 = 4294967295U;
    Weights w_12 = _S639;
    float3  ggx_n_2 = _S638;
    i_7 = 0U;
    for(;;)
    {
        if(i_7 < _S636)
        {
        }
        else
        {
            break;
        }
        uint _S640;
        if(i_7 == 3U)
        {
            _S640 = 4U;
        }
        else
        {
            if(i_7 == 4U)
            {
                _S640 = 6U;
            }
            else
            {
                _S640 = i_7;
            }
        }
        bool _S641 = _S640 == 0U;
        bool _S642;
        if(_S641)
        {
            _S642 = _S633;
        }
        else
        {
            _S642 = false;
        }
        bool _S643;
        if(_S642)
        {
            _S643 = _S634;
        }
        else
        {
            _S643 = _S640 == 1U;
        }
        bool _S644 = _S643 != refracted_2;
        if(_S644)
        {
            ggx_n_1 = ggx_n_2;
            uint i_9 = i_7 + 1U;
            ggx_n_2 = ggx_n_1;
            i_7 = i_9;
            continue;
        }
        uint _S645;
        if(_S640 == 6U)
        {
            _S645 = 0U;
        }
        else
        {
            if(_S640 == 4U)
            {
                _S645 = 2U;
            }
            else
            {
                _S645 = _S640;
            }
        }
        bool _S646 = _S645 != half_of_0;
        uint half_of_1;
        Weights w_13;
        if(_S646)
        {
            bool _S647 = _S645 == 0U;
            if(_S647)
            {
                float3  _S648 = sampledHalf(_S623, _S626, _S629, _S630, random_state_4);
                ggx_n_1 = _S648;
            }
            else
            {
                bool _S649 = _S645 == 1U;
                if(_S649)
                {
                    float3  _S650 = refractedHalf(in_dir_3, out_dir_2, n_6, eta_i_4, eta_o_4);
                    ggx_n_1 = _S650;
                }
                else
                {
                    float3  _S651 = reflectedHalf(in_dir_3, out_dir_2);
                    ggx_n_1 = _S651;
                }
            }
            Weights _S652 = lobeWeights(in_dir_3, _S623, _S626, ggx_n_1, _S630, _S631, material_11, eta_i_4, eta_o_4);
            w_13 = _S652;
            half_of_1 = _S645;
        }
        else
        {
            w_13 = w_12;
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S640)
        {
        case 0U:
            {
                float _S653 = diffusePDF(_S627, (F32_abs((_S624))), material_11, w_13);
                (*pdfs_0)[int(0)] = _S653;
                float3  _S654 = diffuseBSDF(out_dir_2, _S626, material_11, w_13);
                (*throughputs_0)[int(0)] = _S654;
                break;
            }
        case 1U:
            {
                float _S655 = dot_0(out_dir_2, ggx_n_1);
                float _S656 = vndfPDF(_S623, ggx_n_1, _S626, (F32_abs((_S624))), _S629, _S630, w_13.v_dot_h);
                float _S657 = refractPDF(_S655, _S656, w_13, eta_i_4, eta_o_4);
                (*pdfs_0)[int(1)] = _S657;
                float3  _S658 = refractBSDF(out_dir_2, _S626, _S629, _S630, material_11, w_13);
                (*throughputs_0)[int(1)] = _S658;
                break;
            }
        case 4U:
            {
                float _S659 = sheenVelvetPDF(_S627, (F32_abs((_S624))), w_13);
                (*pdfs_0)[int(3)] = _S659;
                float3  _S660 = sheenVelvetBSDF(out_dir_2, _S623, _S626, material_11, w_13);
                (*throughputs_0)[int(3)] = _S660;
                break;
            }
        case 6U:
            {
                ToonProfile _S661 = toonProfile(_S623, _S626, material_11);
                float _S662 = toonPDF(out_dir_2, _S626, _S661, w_13);
                (*pdfs_0)[int(4)] = _S662;
                float3  _S663 = toonBSDF(out_dir_2, _S626, _S661, w_13);
                (*throughputs_0)[int(4)] = _S663;
                break;
            }
        default:
            {
                float _S664 = vndfPDF(_S623, ggx_n_1, _S626, (F32_abs((_S624))), _S629, _S630, w_13.v_dot_h);
                float _S665 = reflectPDF(_S664, w_13);
                (*pdfs_0)[int(2)] = _S665;
                float3  _S666 = reflectBSDF(out_dir_2, _S626, _S629, _S630, w_13);
                (*throughputs_0)[int(2)] = _S666;
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
    ggx_n_1 = _S638;
    for(;;)
    {
        if(i_7 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S667 = ((*pdfs_0)[i_7]) > 0.0f;
        if(_S667)
        {
            float3  f_2 = ggx_n_1 + (*throughputs_0)[i_7] * make_float3 ((*pdfs_0)[i_7]);
            ggx_n_1 = f_2;
        }
        uint i_10 = i_7 + 1U;
        i_7 = i_10;
    }
    return ggx_n_1;
}

static __device__ __forceinline__ float3  skyLobes_0(float3  in_dir_4, float3  dir_3, FKSurface * surface_1, BSDFMaterial * material_12, float2  eta_1, bool is_inside_2, float pdf_0, uint random_state_5, FixedArray<float3 , 5>  * terms_0, FixedArray<float, 5>  * pdfs_1)
{
    bool _S668 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    float3  _S669 = BSDF(in_dir_4, dir_3, surface_1->smooth_n, *material_12, eta_1.x, eta_1.y, _S668, random_state_5, terms_0, pdfs_1);
    float3  _S670 = make_float3 (0.0f);
    uint i_11 = 0U;
    float3  f_3 = _S670;
    for(;;)
    {
        if(i_11 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S671 = ((*pdfs_1)[i_11]) > 0.0f;
        if(_S671)
        {
            float3  _S672 = (*terms_0)[i_11] * make_float3 ((*pdfs_1)[i_11]) / make_float3 ((*pdfs_1)[i_11] + pdf_0);
            (*terms_0)[i_11] = _S672;
            float3  f_4 = f_3 + (*terms_0)[i_11];
            f_3 = f_4;
        }
        uint i_12 = i_11 + 1U;
        i_11 = i_12;
    }
    return f_3;
}

__device__ float3  skyBSDF(float3  in_dir_5, float3  dir_4, FKSurface surface_2, BSDFMaterial material_13, float2  eta_2, bool is_inside_3, float pdf_1, uint random_state_6)
{
    FKSurface _S673 = surface_2;
    BSDFMaterial _S674 = material_13;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S675 = skyLobes_0(in_dir_5, dir_4, &_S673, &_S674, eta_2, is_inside_3, pdf_1, random_state_6, &terms_1, &pdfs_2);
    return _S675;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S676;
    (&_S676)->dir = dir_5;
    (&_S676)->radiance = radiance_0;
    (&_S676)->color = color_0;
    (&_S676)->random_state = random_state_7;
    return _S676;
}

static __device__ __noinline__ float3  skyColor_0(float3  in_dir_6, float3  dir_6, FKSurface * surface_3, float wavelength_3, float2  eta_3, bool is_inside_4, float pdf_2, uint random_state_8, uint depth_0)
{
    BSDFMaterial _S677 = pathMaterial(surface_3->material, wavelength_3);
    BSDFMaterial _S678 = _S677;
    FixedArray<float3 , 5>  terms_2;
    FixedArray<float, 5>  pdfs_3;
    float3  _S679 = skyLobes_0(in_dir_6, dir_6, surface_3, &_S678, eta_3, is_inside_4, pdf_2, random_state_8, &terms_2, &pdfs_3);
    float3  _S680 = make_float3 (0.0f);
    bool shaded_0 = false;
    float3  world_0 = _S680;
    uint i_13 = 0U;
    float3  color_1 = _S680;
    for(;;)
    {
        if(i_13 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S681 = (pdfs_3[i_13]) > 0.0f;
        if(_S681)
        {
            bool _S682 = (fcptWorldReadsPath());
            bool _S683;
            if(_S682)
            {
                _S683 = true;
            }
            else
            {
                _S683 = !shaded_0;
            }
            bool shaded_1;
            float3  world_1;
            if(_S683)
            {
                uint _S684;
                if(i_13 == 3U)
                {
                    _S684 = 4U;
                }
                else
                {
                    if(i_13 == 4U)
                    {
                        _S684 = 6U;
                    }
                    else
                    {
                        _S684 = i_13;
                    }
                }
                float3  _S685 = (fcptEnvMapSample((dir_6), (depth_0), (_S684)));
                world_1 = _S685;
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
    uint2  _S686 = (fcptEnvironmentCdfSize());
    uint2  _S687 = make_uint2 (1U, 0U);
    uint2  _S688 = _S686 - _S687;
    Random _S689 = pcg(init_random_state_0);
    Random _S690 = pcg(_S689.state);
    Random _S691 = pcg(_S690.state);
    Random _S692 = pcg(_S691.state);
    uint _S693 = _S688.x;
    uint _S694 = searchCDF_0(make_uint2 (_S693, 0U), make_uint2 (0U, 1U), _S688.y, _S689.value);
    uint _S695 = searchCDF_0(make_uint2 (0U, _S694), _S687, _S693, _S690.value);
    float2  _S696 = make_float2 ((float)_S688.x, (float)_S688.y);
    float2  _S697 = (make_float2 (float(_S695), float(_S694)) + make_float2 (_S691.value, _S692.value)) / _S696 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S698 = _S697.y;
    float _S699 = (F32_sin((_S698)));
    float _S700 = _S697.x;
    float3  _S701 = make_float3 (- _S699 * (F32_cos((_S700))), _S699 * (F32_sin((_S700))), (F32_cos((_S698))));
    float _S702 = environmentPdf_0(_S701);
    BSDFMaterial _S703 = pathMaterial(surface_4->material, wavelength_4);
    float3  _S704 = ray_0->unit_direction;
    float3  _S705 = skyBSDF(ray_0->unit_direction, _S701, *surface_4, _S703, eta_4, is_inside_5, _S702, lobe_state_0);
    bool _S706 = !(_S702 > 0.0f);
    bool _S707;
    if(_S706)
    {
        _S707 = true;
    }
    else
    {
        _S707 = all_1(_S705 == make_float3 (0.0f));
    }
    if(_S707)
    {
        float3  _S708 = make_float3 (0.0f);
        return SkySample_x24init_0(_S701, _S708, _S708, _S692.state);
    }
    bool _S709 = (fcptWorldReadsPath());
    float3  seen_0;
    if(_S709)
    {
        float3  _S710 = skyColor_0(_S704, _S701, surface_4, wavelength_4, eta_4, is_inside_5, _S702, lobe_state_0, context_2->depth + 1U);
        seen_0 = _S710;
    }
    else
    {
        seen_0 = _S705;
    }
    float3  _S711 = skyRadiance_0(ray_0->origin, surface_4, is_inside_5, _S701, context_2, _S692.state);
    return SkySample_x24init_0(_S701, _S711, seen_0 * _S711, _S692.state);
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
    SampleBSDF _S712 = (fcptConnectHair((surface_5->hair), ((&surface_5->material)->albedo), ((&surface_5->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S713 = _S712.throughput * make_float3 (_S712.pdf);
    float _S714 = light_1->density;
    float _S715 = 1.0f + _S712.pdf * _S712.pdf / (light_1->density * light_1->density);
    bool _S716;
    if(competing_0)
    {
        _S716 = _S714 > 0.0f;
    }
    else
    {
        _S716 = false;
    }
    float _S717 = _slang_select(_S716, _S715,1.0f);
    return _S713 / make_float3 (_S717) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_7, float3  radiance_1, float density_0, uint random_state_9)
{
    TreeSample _S718;
    (&_S718)->dir = dir_7;
    (&_S718)->radiance = radiance_1;
    (&_S718)->density = density_0;
    (&_S718)->random_state = random_state_9;
    return _S718;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S719 = importance(first_1, p_12, normal_3);
    float _S720 = importance(second_1, p_12, normal_3);
    float2  _S721 = make_float2 (_S719, _S720);
    bool _S722 = _S719 == 0.0f;
    bool _S723;
    if(_S722)
    {
        _S723 = _S720 == 0.0f;
    }
    else
    {
        _S723 = false;
    }
    if(_S723)
    {
        return 2U;
    }
    float _S724 = _S719 + _S720;
    bool _S725 = _S720 > 0.0f;
    if(_S725)
    {
        _S723 = (*pick_0 * _S724) >= _S719;
    }
    else
    {
        _S723 = false;
    }
    uint _S726 = uint(_S723);
    float _S727 = (F32_min(((*pick_0 * _S724 - float(_S726) * _S719) / _slang_vector_get_element(_S721, _S726)), (0.99999994039535522f)));
    *pick_0 = _S727;
    float _S728 = *probability_3 * (_slang_vector_get_element(_S721, _S726) / _S724);
    *probability_3 = _S728;
    return _S726;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S729 = center_1 - p_13;
    float _S730 = radius_1 * radius_1 / dot_0(_S729, _S729);
    float _S731 = u1_0 * _S730 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S730), (0.0f)))))));
    float _S732 = 2.0f * u1_0;
    bool _S733 = _S730 >= 1.0f;
    float _S734 = _slang_select(_S733, _S732,_S731);
    float _S735 = (F32_sqrt(((F32_max((_S734 * (2.0f - _S734)), (0.0f))))));
    float _S736 = 6.28318548202514648f * u2_0;
    float3  _S737 = make_float3 (_S735 * (F32_cos((_S736))), 1.0f - _S734, _S735 * (F32_sin((_S736))));
    float3  _S738 = ((((_S729)) * make_float3(rnorm3df(((_S729)).x, ((_S729)).y, ((_S729)).z))));
    float3  _S739 = tangentToWorld(_S737, _S738);
    return _S739;
}

__device__ float3  pointLightRadiance(float3  color_3, float intensity_0, float radius_2)
{
    return color_3 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S740 = center_2 - ray_1->origin;
    float _S741 = dot_0(_S740, ray_1->unit_direction);
    float _S742 = dot_0(_S740, _S740) - _S741 * _S741;
    float _S743 = radius_3 * radius_3;
    bool _S744 = _S742 > _S743;
    if(_S744)
    {
        return 4.294967296e+09f;
    }
    float _S745 = (F32_sqrt((_S743 - _S742)));
    float _S746 = _S741 - _S745;
    float _S747 = _S741 + _S745;
    bool _S748 = _S746 > 0.0000152587890625f;
    bool _S749;
    if(_S748)
    {
        _S749 = _S746 < max_len_0;
    }
    else
    {
        _S749 = false;
    }
    if(_S749)
    {
        return _S746;
    }
    bool _S750 = _S747 > 0.0000152587890625f;
    if(_S750)
    {
        _S749 = _S747 < max_len_0;
    }
    else
    {
        _S749 = false;
    }
    if(_S749)
    {
        return _S747;
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
    Random _S751 = pcg(init_random_state_1);
    Random _S752 = pcg(_S751.state);
    Random _S753 = pcg(_S752.state);
    float3  _S754 = make_float3 (0.0f);
    TreeSample _S755 = TreeSample_x24init_0(_S754, _S754, 0.0f, _S753.state);
    TreeSample sample_0 = _S755;
    float3  _S756 = _slang_select(sided_0, _S754,smooth_n_2);
    float3  _S757 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S751.value;
    float probability_4 = 1.0f;
    uint n_7 = 0U;
    for(;;)
    {
        uint4  _S758 = (fcptLightNode((n_7)));
        if((_S758.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S759 = (fcptLightSecond((n_7)));
        uint _S760 = n_7 + 1U;
        LightNode _S761 = (fcptLightBounds((_S760)));
        LightNode _S762 = (fcptLightBounds((_S759)));
        uint _S763 = pickChild(_S761, _S762, origin_4, _S756, &pick_1, &probability_4);
        bool _S764 = _S763 > 1U;
        if(_S764)
        {
            return sample_0;
        }
        bool _S765 = _S763 == 1U;
        uint _S766 = _slang_select(_S765, _S759,_S760);
        n_7 = _S766;
    }
    bool _S767 = n_7 == 0U;
    bool _S768;
    if(_S767)
    {
        LightNode _S769 = (fcptLightBounds((0U)));
        float _S770 = importance(_S769, origin_4, _S756);
        _S768 = !(_S770 > 0.0f);
    }
    else
    {
        _S768 = false;
    }
    if(_S768)
    {
        return sample_0;
    }
    uint4  _S771 = (fcptLightNode((n_7)));
    FKHit _S772 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S773 = (_S771.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S773)
    {
        FKLight _S774 = (fcptLight((_S771.y)));
        if(sided_0)
        {
            float _S775 = sign_0(dot_0(geometry_n_1, _S774.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S775);
            float3  _S776 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S776;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S757;
            lift_n_0 = smooth_n_2;
        }
        bool _S777 = (_S774.variance) == 0.0f;
        if(_S777)
        {
            float3  _S778 = _S774.position - emitter_point_0;
            float3  _S779 = ((((_S778)) * make_float3(rnorm3df(((_S778)).x, ((_S778)).y, ((_S778)).z))));
            (&sample_0)->dir = _S779;
            float3  _S780 = _S774.color * make_float3 (_S774.intensity) / make_float3 (dot_0(_S778, _S778) * probability_4);
            (&sample_0)->radiance = _S780;
            shadow_1 = _S778;
        }
        else
        {
            float3  _S781 = sampleSphere(_S774.position, _S774.variance, emitter_point_0, _S752.value, _S753.value);
            (&sample_0)->dir = _S781;
            float _S782 = sphereDensity(_S774.position, _S774.variance, emitter_point_0);
            float _S783 = probability_4 * _S782;
            (&sample_0)->density = _S783;
            float3  _S784 = pointLightRadiance(_S774.color, _S774.intensity, _S774.variance);
            float3  _S785 = _S784 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S785;
            FKRay _S786 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S787 = raySphere_0(_S774.position, _S774.variance, &_S786, 4.294967296e+09f);
            float3  _S788 = (&sample_0)->dir * make_float3 (_S787);
            shadow_1 = _S788;
        }
        emitter_0 = _S772;
        emitter_point_0 = _S754;
    }
    else
    {
        uint _S789 = _S771.y;
        uint _S790 = (fcptTriangleOffset((_S789)));
        uint _S791 = _S790 + _S771.z;
        Matrix<float, 3, 3>  _S792 = (fcptWorldTriangle((_S789), (_S791)));
        float _S793 = (F32_sqrt((_S752.value)));
        float2  _S794 = make_float2 (_S793 * (1.0f - _S753.value), _S793 * _S753.value);
        float3  _S795 = mul_0(make_float3 (1.0f - _S793, _S794.x, _S794.y), _S792);
        if(sided_0)
        {
            float _S796 = sign_0(dot_0(geometry_n_1, _S795 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S796);
            float3  _S797 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S797;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S798 = !((dot_0(smooth_n_2, _S795 - origin_4)) > 0.0f);
            if(_S798)
            {
                return sample_0;
            }
            emitter_point_0 = _S757;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S794, _S789, _S791, 0U, 0.0f);
        float3  _S799 = _S795 - emitter_point_0;
        float3  _S800 = ((((_S799)) * make_float3(rnorm3df(((_S799)).x, ((_S799)).y, ((_S799)).z))));
        (&sample_0)->dir = _S800;
        float _S801 = solidAngle(probability_4, cross_0(_S792.rows[int(1)] - _S792.rows[int(0)], _S792.rows[int(2)] - _S792.rows[int(0)]), _S799);
        (&sample_0)->density = _S801;
        bool _S802 = (fcptShadowFirst());
        bool _S803 = !_S802;
        if(_S803)
        {
            FKSurface _S804 = (fcptLightSurfaceAt((emitter_1), (_S795), (_S753.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S795 - origin_4))));
            (&sample_0)->random_state = _S804.random_state;
            float3  _S805 = _slang_select(_S804.skip, _S754,_S804.material.emissive);
            float3  _S806 = _S805 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S806;
        }
        shadow_1 = _S799;
        emitter_0 = emitter_1;
        emitter_point_0 = _S795;
    }
    FKHit _S807 = emitter_0;
    float3  _S808 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S753.state, &_S807);
    bool _S809 = (fcptShadowFirst());
    if(_S809)
    {
        _S768 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S768 = false;
    }
    if(_S768)
    {
        _S768 = !all_1(_S808 == _S754);
    }
    else
    {
        _S768 = false;
    }
    if(_S768)
    {
        FKSurface _S810 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S753.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S810.random_state;
        float3  _S811 = _slang_select(_S810.skip, _S754,_S810.material.emissive);
        float3  _S812 = _S811 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S812;
    }
    float3  _S813 = (&sample_0)->radiance * _S808;
    bool _S814 = all_1(_S808 == _S754);
    float3  _S815 = _slang_select(_S814, _S754,_S813);
    (&sample_0)->radiance = _S815;
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
    float _S816 = 1.0f / (1.0f + b_2 / a_8 * (b_2 / a_8));
    bool _S817 = b_2 > 0.0f;
    float _S818 = _slang_select(_S817, _S816,1.0f);
    return _S818;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S819 = vertex_0->none;
    if(_S819)
    {
        return 1.0f;
    }
    uint _S820 = (fcptLightSlot((*hit_1)));
    float _S821 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S820, light_point_1);
    float _S822 = powerHeuristic(vertex_0->pdf, _S821);
    return _S822;
}

static __device__ float3  environment_0(float3  dir_8, uint depth_1, uint lobe_0)
{
    uint2  _S823 = (fcptEnvironmentMapSize());
    bool _S824 = (_S823.x) > 1U;
    bool _S825;
    if(_S824)
    {
        uint2  _S826 = (fcptEnvironmentMapSize());
        _S825 = (_S826.y) > 1U;
    }
    else
    {
        _S825 = false;
    }
    if(_S825)
    {
        float3  _S827 = (fcptEnvMapSample((dir_8), (depth_1), (lobe_0)));
        return _S827;
    }
    float3  _S828 = (fcptAmbient());
    return _S828;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S829 = (fcptEnvironmentCdfSize());
    bool _S830 = (_S829.x) > 1U;
    bool _S831;
    if(_S830)
    {
        uint2  _S832 = (fcptEnvironmentCdfSize());
        _S831 = (_S832.y) > 1U;
    }
    else
    {
        _S831 = false;
    }
    bool _S833 = !_S831;
    if(_S833)
    {
        return false;
    }
    uint2  _S834 = (fcptEnvironmentMapSize());
    bool _S835 = (_S834.x) > 1U;
    if(_S835)
    {
        uint2  _S836 = (fcptEnvironmentMapSize());
        _S831 = (_S836.y) > 1U;
    }
    else
    {
        _S831 = false;
    }
    return _S831;
}

static __device__ float escapeWeight_0(float pdf_3, float3  dir_9)
{
    bool _S837 = pdf_3 <= 0.0f;
    bool _S838;
    if(_S837)
    {
        _S838 = true;
    }
    else
    {
        bool _S839 = environmentMapped_0();
        _S838 = !_S839;
    }
    if(_S838)
    {
        return 1.0f;
    }
    float _S840 = environmentPdf_0(dir_9);
    return pdf_3 / (pdf_3 + _S840);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S841 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S842 = make_int2 ((int)_S841.x, (int)_S841.y);
    uint _S843 = previousSeed_0(_S842);
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
            uint _S844 = previousSeed_0(_S842 + make_int2 (x_16, y_5));
            bool _S845 = _S844 == _S843;
            uint _S846 = _slang_select(_S845, 1U,0U);
            uint count_3 = count_2 + _S846;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S847 = float(count_2 - 1U) / 288.0f;
    bool _S848 = _S843 != 0U;
    float _S849 = _slang_select(_S848, _S847,0.0f);
    fcptStoreDuplication((_S842), (make_uint4 ((F32_asuint((_S849))), 0U, 0U, 0U)));
    return;
}

static __device__ float3  abs_0(float3  x_18)
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
        *_slang_vector_get_element_ptr(&result_7, i_16) = (F32_abs((_slang_vector_get_element(x_18, i_16))));
        i_16 = i_16 + int(1);
    }
    return result_7;
}

__device__ float resamplingTarget(float3  f_5)
{
    float _S850 = rgb_to_greyscale(abs_0(f_5));
    return _S850;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S851 = hash(index_0);
    uint _S852 = hash(seed_3 ^ _S851);
    return _S852;
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

__device__ void offer(Selection * sel_2, Reservoir candidate_0, float3  weight_0)
{
    float _S853 = resamplingTarget(weight_0);
    bool _S854 = _S853 > 0.0f;
    bool _S855;
    if(_S854)
    {
        _S855 = _S853 < 3.00000000549775576e+38f;
    }
    else
    {
        _S855 = false;
    }
    bool _S856 = !_S855;
    if(_S856)
    {
        return;
    }
    bool _S857 = sel_2->sums;
    if(_S857)
    {
        float3  _S858 = sel_2->color + weight_0;
        sel_2->color = _S858;
        return;
    }
    float _S859 = sel_2->w_sum + _S853;
    sel_2->w_sum = _S859;
    float3  _S860 = sel_2->color + weight_0;
    sel_2->color = _S860;
    Random _S861 = pcg(sel_2->random_state);
    sel_2->random_state = _S861.state;
    bool _S862 = (_S861.value * sel_2->w_sum) <= _S853;
    if(_S862)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S863 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S863;
    float _S864 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S864;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S865 = resamplingTarget((&r_4)->f);
    float _S866 = sel_4.w_sum / _S865;
    bool _S867 = _S865 > 0.0f;
    float _S868 = _slang_select(_S867, _S866,0.0f);
    (&r_4)->w = _S868;
    (&r_4)->c = c_1;
    return r_4;
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
    uint2  _S869 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S870 = make_int2 ((int)_S869.x, (int)_S869.y);
    float3  _S871 = make_float3 (0.0f);
    FKHit _S872 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S873 = Domain_x24init_0(_S871, _S871, &_S872, 0.0f, 0.0f);
    Domain dom_4 = _S873;
    bool _S874 = (fcptCurrentDomain((_S870), (&dom_4)));
    bool _S875 = !_S874;
    if(_S875)
    {
        Reservoir _S876 = (Reservoir{});
        fcptStoreReservoirPrevious((_S870), (_S876), ((&dom_4)->hit));
        return;
    }
    Reservoir _S877 = (fcptLoadReservoirTemporal((_S870)));
    uint t_15 = 0U;
    float count_4 = 0.0f;
    float c_sum_0 = _S877.c;
    for(;;)
    {
        uint _S878 = (fcptRestirNeighbours());
        if(t_15 < _S878)
        {
        }
        else
        {
            break;
        }
        int2  _S879 = partner_0(_S870, t_15);
        Domain neighbor_0 = _S873;
        bool _S880 = (fcptCurrentDomain((_S879), (&neighbor_0)));
        if(_S880)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S881 = (fcptReservoirTemporal((_S879), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S881.w)));
            count_4 = count_5;
            c_sum_0 = c_sum_1;
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    float _S882 = _S877.c / (F32_max((count_4), (1.0f)));
    float _S883 = resamplingTarget(_S877.f);
    bool _S884 = count_4 == 0.0f;
    float _S885 = _slang_select(_S884, 1.0f,0.0f);
    Selection _S886 = (Selection{});
    Selection sel_5 = _S886;
    uint _S887 = (fcptFrame());
    uint _S888 = hash(_S887);
    uint _S889 = global_invocation_id_2.x;
    uint2  _S890 = (fcptRenderSize());
    uint _S891 = stream(_S888, _S889 + _S890.x * global_invocation_id_2.y);
    uint _S892 = stream(_S891, 195U);
    (&sel_5)->random_state = _S892;
    t_15 = 0U;
    float canonical_mis_0 = _S885;
    for(;;)
    {
        uint _S893 = (fcptRestirNeighbours());
        if(t_15 < _S893)
        {
        }
        else
        {
            break;
        }
        int2  _S894 = partner_0(_S870, t_15);
        Domain neighbor_dom_0 = _S873;
        bool _S895 = (fcptCurrentDomain((_S894), (&neighbor_dom_0)));
        if(_S895)
        {
            Reservoir _S896 = (fcptLoadReservoirTemporal((_S894)));
            uint4  _S897 = (fcptShiftData((_S894), (t_15)));
            float4  _S898 = asfloat_0(_S897);
            uint4  _S899 = (fcptShiftData((_S870), (t_15)));
            float4  _S900 = asfloat_0(_S899);
            float _S901 = (_S896.c + _S882) / c_sum_0;
            bool _S902 = _S883 > 0.0f;
            float canonical_mis_1;
            if(_S902)
            {
                float _S903 = _S901 * _S882 * _S883;
                float _S904 = _S882 * _S883;
                float _S905 = resamplingTarget(float3 {_S900.x, _S900.y, _S900.z});
                float canonical_mis_2 = canonical_mis_0 + _S903 / (_S904 + _S896.c * _S905);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S906 = resamplingTarget(_S896.f);
            float3  _S907 = float3 {_S898.x, _S898.y, _S898.z};
            Shift _S908 = Shift_x24init_0(_S907, _S898.w);
            float _S909 = _S901 * _S896.c * _S906;
            float _S910 = _S896.c * _S906;
            float _S911 = resamplingTarget(_S907);
            offerShifted(&sel_5, _S896, _S908, _S909 / (_S910 + _S882 * _S911));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_17 = t_15 + 1U;
        t_15 = t_17;
    }
    offerShifted(&sel_5, _S877, Shift_x24init_0(_S877.f, 1.0f), canonical_mis_0);
    Reservoir _S912 = finalize(sel_5, c_sum_0);
    fcptStoreReservoirPrevious((_S870), (_S912), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S870), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S870), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S913 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S914 = _S913 != 4294967295U;
    if(_S914)
    {
        uint2  _S915 = make_uint2 (_S913, _S913 >> 14U) & make_uint2 (16383U);
        int2  _S916 = make_int2 ((int)_S915.x, (int)_S915.y);
        ShiftJob _S917 = (ShiftJob{});
        ShiftJob shift_job_0 = _S917;
        Shift _S918 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S919 = _S913 >> 28U;
        bool _S920 = spatialJob_0(_S916, _S919, &shift_job_0, true);
        Shift shifted_1;
        if(_S920)
        {
            Domain _S921 = (&shift_job_0)->dom;
            Reservoir _S922 = (&shift_job_0)->r;
            Shift _S923 = passShift_0(&_S921, &_S922);
            shifted_1 = _S923;
        }
        else
        {
            shifted_1 = _S918;
        }
        fcptStoreShiftData((_S916), (_S919), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S924 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S925 = make_int2 ((int)_S924.x, (int)_S924.y);
    FixedArray<uint, 3>  _S926;
    spatialBins_0(_S925, &_S926);
    FixedArray<uint, 3>  _S927 = _S926;
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
        bool _S928 = (_S927[t_18]) == 40U;
        if(_S928)
        {
            fcptStoreShiftData((_S925), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S929 = _S927;
    queueShifts_0(_S925, &_S929, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S930 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S931 = make_int2 ((int)_S930.x, (int)_S930.y);
    FixedArray<uint, 3>  _S932;
    spatialBins_0(_S931, &_S932);
    FixedArray<uint, 3>  _S933 = _S932;
    countShifts_0(&_S933, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S934 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S935 = _S934 != 4294967295U;
    if(_S935)
    {
        uint2  _S936 = make_uint2 (_S934, _S934 >> 14U) & make_uint2 (16383U);
        int2  _S937 = make_int2 ((int)_S936.x, (int)_S936.y);
        int2  _S938 = (fcptLoadTemporalNeighbor((_S937)));
        uint _S939 = _S934 >> 28U;
        Shift _S940 = temporalShiftAt_0(_S937, _S938, _S939);
        fcptStoreTemporalShift((_S937), (_S939), (make_uint4 (asuint_1(_S940.f).x, asuint_1(_S940.f).y, asuint_1(_S940.f).z, (F32_asuint((_S940.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S941 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S942 = make_int2 ((int)_S941.x, (int)_S941.y);
    FixedArray<uint, 3>  _S943;
    temporalBins_0(_S942, &_S943);
    FixedArray<uint, 3>  _S944 = _S943;
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
        bool _S945 = (_S944[t_20]) == 40U;
        if(_S945)
        {
            fcptStoreTemporalShift((_S942), (t_20), (make_uint4 (0U)));
        }
        uint t_21 = t_20 + 1U;
        t_20 = t_21;
    }
    FixedArray<uint, 3>  _S946 = _S944;
    queueShifts_0(_S942, &_S946, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S947 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S948 = make_int2 ((int)_S947.x, (int)_S947.y);
    bool _S949 = (fcptSceneUnchanged());
    bool _S950 = !_S949;
    bool _S951;
    if(_S950)
    {
        uint2  _S952 = (fcptRenderSize());
        int2  _S953 = make_int2 ((int)_S952.x, (int)_S952.y);
        _S951 = all_0(_S948 < _S953);
    }
    else
    {
        _S951 = false;
    }
    if(_S951)
    {
        Reservoir _S954 = (fcptLoadReservoirInitial((_S948)));
        int2  _S955 = sampleNeighbor_0(_S948, _S954.seed);
        fcptStoreTemporalNeighbor((_S948), (_S955));
    }
    FixedArray<uint, 3>  _S956;
    temporalBins_0(_S948, &_S956);
    FixedArray<uint, 3>  _S957 = _S956;
    countShifts_0(&_S957, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_9, float b_3, float t_22)
{
    return a_9 + (b_3 - a_9) * t_22;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S958 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S959 = make_int2 ((int)_S958.x, (int)_S958.y);
    float3  _S960 = make_float3 (0.0f);
    FKHit _S961 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S962 = Domain_x24init_0(_S960, _S960, &_S961, 0.0f, 0.0f);
    Domain dom_5 = _S962;
    bool _S963 = (fcptCurrentDomain((_S959), (&dom_5)));
    bool _S964 = !_S963;
    if(_S964)
    {
        Reservoir _S965 = (Reservoir{});
        fcptStoreReservoirTemporal((_S959), (_S965), ((&dom_5)->hit));
        return;
    }
    Reservoir _S966 = (fcptLoadReservoirInitial((_S959)));
    bool _S967 = (fcptTemporalQueued());
    bool _S968 = (fcptSceneUnchanged());
    bool _S969;
    if(_S968)
    {
        _S969 = true;
    }
    else
    {
        _S969 = !_S967;
    }
    int2  _S970;
    if(_S969)
    {
        int2  _S971 = sampleNeighbor_0(_S959, _S966.seed);
        _S970 = _S971;
    }
    else
    {
        int2  _S972 = (fcptLoadTemporalNeighbor((_S959)));
        _S970 = _S972;
    }
    bool _S973 = (_S970.x) >= int(0);
    Reservoir r_5;
    if(_S973)
    {
        Reservoir _S974 = (fcptLoadReservoirPrevious((_S970)));
        uint4  _S975 = (fcptDuplication((_S970)));
        float _S976 = (U32_asfloat((_S975.x)));
        uint _S977 = (fcptRestirDecorrelation());
        bool _S978 = _S977 == 1U;
        float _S979 = _slang_select(_S978, _S976,0.0f);
        float _S980 = interpolate_0(20.0f, 1.0f, (F32_pow((_S979), (0.10000000149011612f))));
        float _S981 = (F32_min((_S974.c), (_S980)));
        bool _S982 = (fcptSceneUnchanged());
        float4  _S983 = make_float4 (_S974.f.x, _S974.f.y, _S974.f.z, 1.0f);
        bool _S984 = !_S982;
        if(_S984)
        {
            _S969 = _S967;
        }
        else
        {
            _S969 = false;
        }
        float4  to_current_0;
        if(_S969)
        {
            uint4  _S985 = (fcptTemporalShift((_S959), (0U)));
            float4  _S986 = asfloat_0(_S985);
            to_current_0 = _S986;
        }
        else
        {
            if(_S984)
            {
                Shift _S987 = temporalShiftAt_0(_S959, _S970, 0U);
                float4  _S988 = make_float4 (_S987.f.x, _S987.f.y, _S987.f.z, _S987.jac);
                to_current_0 = _S988;
            }
            else
            {
                to_current_0 = _S983;
            }
        }
        Domain own_1 = _S962;
        if(_S982)
        {
            _S969 = true;
        }
        else
        {
            bool _S989 = (fcptPreviousScenes());
            bool _S990 = !_S989;
            if(_S990)
            {
                _S969 = (_S966.w) > 0.0f;
            }
            else
            {
                _S969 = false;
            }
            if(_S969)
            {
                bool _S991 = (fcptStoredDomainInitial((_S959), (_S966.seed), (&own_1)));
                _S969 = _S991;
            }
            else
            {
                _S969 = false;
            }
            if(_S969)
            {
                Domain _S992 = (fcptPreviousDomain((_S970), (_S966.seed)));
                Domain _S993 = _S992;
                Domain _S994 = own_1;
                bool _S995 = sameDomain_0(&_S993, &_S994);
                _S969 = _S995;
            }
            else
            {
                _S969 = false;
            }
        }
        float4  _S996 = make_float4 (_S966.f.x, _S966.f.y, _S966.f.z, 1.0f);
        bool _S997 = !_S969;
        if(_S997)
        {
            _S969 = _S967;
        }
        else
        {
            _S969 = false;
        }
        float4  to_previous_0;
        if(_S969)
        {
            uint4  _S998 = (fcptTemporalShift((_S959), (1U)));
            float4  _S999 = asfloat_0(_S998);
            to_previous_0 = _S999;
        }
        else
        {
            if(_S997)
            {
                Shift _S1000 = temporalShiftAt_0(_S959, _S970, 1U);
                float4  _S1001 = make_float4 (_S1000.f.x, _S1000.f.y, _S1000.f.z, _S1000.jac);
                to_previous_0 = _S1001;
            }
            else
            {
                to_previous_0 = _S996;
            }
        }
        float _S1002 = resamplingTarget(_S966.f);
        float _S1003 = resamplingTarget(_S974.f);
        Selection _S1004 = (Selection{});
        Selection sel_6 = _S1004;
        uint _S1005 = (fcptFrame());
        uint _S1006 = hash(_S1005);
        uint _S1007 = global_invocation_id_7.x;
        uint2  _S1008 = (fcptRenderSize());
        uint _S1009 = stream(_S1006, _S1007 + _S1008.x * global_invocation_id_7.y);
        uint _S1010 = stream(_S1009, 194U);
        (&sel_6)->random_state = _S1010;
        float _S1011 = _S966.c * _S1002;
        float4  _S1012 = to_previous_0;
        float _S1013 = resamplingTarget(float3 {_S1012.x, _S1012.y, _S1012.z});
        float _S1014 = _S1011 / (_S1011 + _S981 * _S1013);
        float _S1015 = _S981 * _S1003;
        float4  _S1016 = to_current_0;
        float3  _S1017 = float3 {_S1016.x, _S1016.y, _S1016.z};
        float _S1018 = resamplingTarget(_S1017);
        float _S1019 = _S1015 / (_S1015 + _S966.c * _S1018);
        float2  _S1020 = make_float2 (_S1014, _S1019);
        offerShifted(&sel_6, _S966, Shift_x24init_0(_S966.f, 1.0f), _S1014);
        offerShifted(&sel_6, _S974, Shift_x24init_0(_S1017, to_current_0.w), _S1019);
        Reservoir _S1021 = finalize(sel_6, _S966.c + _S981);
        r_5 = _S1021;
    }
    else
    {
        r_5 = _S966;
    }
    fcptStoreReservoirTemporal((_S959), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1022 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1022 << offset_1))) | ((newbits_0 & _S1022) << offset_1);
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S1023 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S1024 = make_int2 ((int)_S1023.x, (int)_S1023.y);
    float3  _S1025 = make_float3 (0.0f);
    float2  _S1026 = make_float2 (0.0f);
    FKHit _S1027 = Hit_x24init_0(_S1026, 0U, 0U, 0U, 0.0f);
    Domain _S1028 = Domain_x24init_0(_S1025, _S1025, &_S1027, 0.0f, 0.0f);
    Domain dom_6 = _S1028;
    bool _S1029 = (fcptCurrentDomain((_S1024), (&dom_6)));
    bool _S1030 = !_S1029;
    if(_S1030)
    {
        Reservoir _S1031 = (Reservoir{});
        fcptStoreReservoirInitial((_S1024), (_S1031), ((&dom_6)->hit));
        return;
    }
    uint _S1032 = (fcptFrame());
    uint _S1033 = hash(_S1032);
    uint _S1034 = global_invocation_id_8.x;
    uint2  _S1035 = (fcptRenderSize());
    uint _S1036 = global_invocation_id_8.y;
    uint _S1037 = stream(_S1033, _S1034 + _S1035.x * _S1036);
    uint2  _S1038 = (fcptRenderSize());
    uint _S1039 = stream(_S1034 + _S1038.x * _S1036, 512U);
    Selection _S1040 = (Selection{});
    Selection initial_0 = _S1040;
    uint _S1041 = stream(_S1037, 193U);
    (&initial_0)->random_state = _S1041;
    bool _S1042 = (fcptRestirUsed());
    bool _S1043 = !_S1042;
    (&initial_0)->sums = _S1043;
    uint _S1044 = stream(_S1037, 0U);
    (&(&initial_0)->r)->seed = _S1044;
    FKHit _S1045 = Hit_x24init_0(_S1026, 4294967295U, 0U, 0U, 0.0f);
    uint _S1046 = (fcptSamples());
    float _S1047 = 1.0f / float(_S1046);
    FKHit hit_2 = _S1045;
    uint i_20 = 0U;
    float3  seen_1 = _S1025;
    for(;;)
    {
        uint _S1048 = (fcptSamples());
        if(i_20 < _S1048)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1049 = (Reservoir{});
        Reservoir r_6 = _S1049;
        uint _S1050 = stream(_S1037, i_20);
        (&r_6)->seed = _S1050;
        uint _S1051 = (fcptFrame());
        uint _S1052 = (fcptSamples());
        uint _S1053 = _S1051 * _S1052 + i_20;
        uint _S1054 = insertBits_0(0U, 1U, 24U, 1U);
        uint _S1055 = insertBits_0(_S1054, (_S1039 + _S1053 * 2654435769U) >> 25U, 25U, 7U);
        (&r_6)->path = _S1055;
        Domain path_0 = _S1028;
        bool _S1056 = (fcptStoredDomainInitial((_S1024), ((&r_6)->seed), (&path_0)));
        bool _S1057 = !_S1056;
        if(_S1057)
        {
            float3  _S1058 = (fcptMissed((_S1024), (path_0), (_S1047)));
            float3  seen_2 = seen_1 + _S1058;
            seen_1 = seen_2;
            uint i_21 = i_20 + 1U;
            i_20 = i_21;
            continue;
        }
        Domain _S1059 = path_0;
        Reservoir _S1060 = r_6;
        Shift _S1061 = passWalk_0(&_S1059, &_S1060, false, _S1047, &initial_0);
        bool _S1062 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1062)
        {
            FKHit _S1063 = (&path_0)->hit;
            hit_3 = _S1063;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_21 = i_20 + 1U;
        i_20 = i_21;
    }
    uint _S1064 = (fcptSamples());
    float3  seen_3 = seen_1 + (&initial_0)->glow / make_float3 (float(_S1064));
    if((&initial_0)->sums)
    {
        seen_1 = seen_3 + (&initial_0)->color;
    }
    else
    {
        seen_1 = seen_3;
    }
    fcptAddColor((_S1024), (make_float4 (seen_1.x, seen_1.y, seen_1.z, 1.0f)));
    Reservoir _S1065 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S1024), (_S1065), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1066;
    (&_S1066)->none = none_0;
    (&_S1066)->pdf = pdf_4;
    (&_S1066)->origin = origin_5;
    (&_S1066)->smooth_n = smooth_n_3;
    (&_S1066)->start = start_6;
    return _S1066;
}

struct Vertex
{
    bool rough;
    uint lobe;
    float pdf;
    float cos;
    bool inside;
};

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_1, float pdf_5, float cos_0, bool inside_0)
{
    Vertex _S1067;
    (&_S1067)->rough = rough_0;
    (&_S1067)->lobe = lobe_1;
    (&_S1067)->pdf = pdf_5;
    (&_S1067)->cos = cos_0;
    (&_S1067)->inside = inside_0;
    return _S1067;
}

__device__ float3  pathColor(float3  f_6, float3  weight_1, float wavelength_5)
{
    float3  _S1068;
    if(wavelength_5 > 0.0f)
    {
        float _S1069 = upsample(f_6, wavelength_5);
        _S1068 = weight_1 * make_float3 (_S1069);
    }
    else
    {
        _S1068 = f_6;
    }
    return _S1068;
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
    float3  _S1070 = exp_0((make_float3 (sigma_0) - extinction_0) * make_float3 (distance_2));
    float3  _S1071 = scatter_0 * _S1070 / make_float3 (sigma_0);
    float3  _S1072 = _slang_select(scatters_0, _S1071,_S1070);
    return _S1072;
}

static __device__ uint arrivalLobe_0(uint b_4, uint prev_lobe_0)
{
    bool _S1073 = b_4 > 0U;
    uint _S1074 = _slang_select(_S1073, prev_lobe_0,3U);
    return _S1074;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_2, uint lobe_2, bool surface_6, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1075;
    (&_S1075)->extinction_behind = extinction_behind_0;
    (&_S1075)->extinction_front = extinction_front_0;
    (&_S1075)->fillings = fillings_0;
    (&_S1075)->side = side_0;
    (&_S1075)->depth = depth_2;
    (&_S1075)->lobe = lobe_2;
    (&_S1075)->surface = surface_6;
    (&_S1075)->length = length_2;
    (&_S1075)->width = width_1;
    (&_S1075)->own = *own_2;
    (&_S1075)->fiber = fiber_0;
    return _S1075;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1076 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1076)
    {
        return 0.07957746833562851f;
    }
    float _S1077 = g_0 * g_0;
    return (1.0f - _S1077) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1077 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_10, float3  b_5)
{
    float3  _S1078 = a_10 / b_5;
    float3  _S1079 = make_float3 (0.0f);
    bool3  _S1080 = b_5 == _S1079;
    float3  _S1081 = _slang_select(_S1080, _S1079,_S1078);
    return _S1081;
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_7)
{
    Reservoir candidate_2 = r_7;
    uint _S1082 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1083 = insertBits_0(_S1082, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1083;
    (&candidate_2)->f = f_7;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_10)
{
    Random _S1084 = pcg(random_state_10);
    Random _S1085 = pcg(_S1084.state);
    float _S1086 = 1.0f - 2.0f * _S1084.value;
    float _S1087 = (F32_sqrt(((F32_max((1.0f - _S1086 * _S1086), (0.0f))))));
    float _S1088 = 6.28318548202514648f * _S1085.value;
    return make_float3 (_S1087 * (F32_cos((_S1088))), _S1087 * (F32_sin((_S1088))), _S1086);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_10, uint random_state_11, float * pdf_6)
{
    bool _S1089 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1089)
    {
        *pdf_6 = 0.07957746833562851f;
        float3  _S1090 = isotropic_0(random_state_11);
        return _S1090;
    }
    Random _S1091 = pcg(random_state_11);
    Random _S1092 = pcg(_S1091.state);
    float _S1093 = g_1 * g_1;
    float _S1094 = 2.0f * g_1;
    float _S1095 = (1.0f - _S1093) / (1.0f - g_1 + _S1094 * _S1091.value);
    float _S1096 = clamp_1((1.0f + _S1093 - _S1095 * _S1095) / _S1094, -1.0f, 1.0f);
    float _S1097 = (F32_sqrt(((F32_max((1.0f - _S1096 * _S1096), (0.0f))))));
    float _S1098 = 6.28318548202514648f * _S1092.value;
    float _S1099 = phaseHG_0(g_1, _S1096);
    *pdf_6 = _S1099;
    float3  _S1100 = tangentToWorld(make_float3 (_S1097 * (F32_cos((_S1098))), _S1096, _S1097 * (F32_sin((_S1098)))), dir_10);
    float3  _S1101 = ((((_S1100)) * make_float3(rnorm3df(((_S1100)).x, ((_S1100)).y, ((_S1100)).z))));
    return _S1101;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_1, float velvet_0, float3  toon_2, float dispersion_0)
{
    BSDFMaterial _S1102;
    (&_S1102)->albedo = albedo_1;
    (&_S1102)->emissive = emissive_0;
    (&_S1102)->roughness = roughness_0;
    (&_S1102)->metallic = metallic_0;
    (&_S1102)->transmission = transmission_0;
    (&_S1102)->ior = ior_0;
    (&_S1102)->absorption = absorption_0;
    (&_S1102)->specular_tint = specular_tint_0;
    (&_S1102)->specular_level = specular_level_0;
    (&_S1102)->translucent = translucent_0;
    (&_S1102)->sheen = sheen_2;
    (&_S1102)->sheen_roughness = sheen_roughness_0;
    (&_S1102)->anisotropy = anisotropy_0;
    (&_S1102)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1102)->tangent = tangent_1;
    (&_S1102)->velvet = velvet_0;
    (&_S1102)->toon = toon_2;
    (&_S1102)->dispersion = dispersion_0;
    return _S1102;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1103;
    (&_S1103)->scatter = scatter_1;
    (&_S1103)->extinction = extinction_1;
    (&_S1103)->g = g_2;
    return _S1103;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_14, bool skip_0, uint random_state_12, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1104;
    (&_S1104)->smooth_n = smooth_n_4;
    (&_S1104)->geometry_n = geometry_n_2;
    (&_S1104)->geometry_offset = geometry_offset_2;
    (&_S1104)->material = *material_14;
    (&_S1104)->skip = skip_0;
    (&_S1104)->random_state = random_state_12;
    (&_S1104)->coverage = coverage_0;
    (&_S1104)->encloses = encloses_0;
    (&_S1104)->volume = *volume_0;
    (&_S1104)->fills = fills_0;
    (&_S1104)->hair = hair_0;
    return _S1104;
}

static __device__ FKSurface emitting_0(FKSurface * surface_7, bool top_0)
{
    FKSurface lower_0 = *surface_7;
    float3  _S1105 = (&surface_7->material)->emissive;
    float3  _S1106 = make_float3 (0.0f);
    bool _S1107 = !top_0;
    float3  _S1108 = _slang_select(_S1107, _S1106,_S1105);
    (&(&lower_0)->material)->emissive = _S1108;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_8, float u_1)
{
    float _S1109 = surface_8->coverage;
    bool _S1110 = u_1 < _S1109;
    if(_S1110)
    {
        return *surface_8;
    }
    float3  _S1111 = make_float3 (0.0f);
    float3  _S1112 = make_float3 (1.0f);
    BSDFMaterial _S1113 = Material_x24init_0(_S1111, _S1111, 0.0f, 0.0f, 0.0f, 0.0f, _S1111, _S1112, 1.0f, _S1111, _S1111, 0.5f, 0.0f, 0.0f, _S1111, 0.0f, _S1111, 0.0f);
    BSDFMaterial material_15 = _S1113;
    (&material_15)->albedo = _S1112;
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
    bool _S1114 = transmission_1 > 0.0f;
    bool _S1115;
    if(_S1114)
    {
        _S1115 = true;
    }
    else
    {
        _S1115 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1116;
    if(_S1115)
    {
        _S1116 = 1.0f;
    }
    else
    {
        _S1116 = -1.0f;
    }
    return _S1116;
}

static __device__ bool arrivesBehind_0(float3  dir_11, float3  n_8)
{
    return (dot_0(dir_11, n_8)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_9, float3  dir_12)
{
    float3  _S1117 = surface_9->geometry_n;
    float _S1118 = facingSign((&surface_9->material)->transmission, surface_9->geometry_n, dir_12);
    FKSurface faced_0 = *surface_9;
    float3  _S1119 = surface_9->smooth_n * make_float3 (_S1118);
    (&faced_0)->smooth_n = _S1119;
    float3  _S1120 = _S1117 * make_float3 (_S1118);
    (&faced_0)->geometry_n = _S1120;
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
    float3  _S1121 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1121));
}

__device__ bool dispersive(BSDFMaterial material_16)
{
    bool _S1122 = (material_16.dispersion) > 0.0f;
    bool _S1123;
    if(_S1122)
    {
        _S1123 = (material_16.ior) != 1.0f;
    }
    else
    {
        _S1123 = false;
    }
    return _S1123;
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
        uint _S1124 = (low_1 + high_1 + 1U) / 2U;
        bool _S1125 = (WAVELENGTH_CDF_0[_S1124]) <= u_2;
        if(_S1125)
        {
            low_1 = _S1124;
        }
        else
        {
            uint _S1126 = _S1124 - 1U;
            high_1 = _S1126;
        }
    }
    uint _S1127 = low_1;
    float _S1128 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_2 - WAVELENGTH_CDF_0[_S1127]) / _S1128), _S1128 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_6)
{
    float _S1129 = clamp_1((wavelength_6 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1130 = (U32_min((uint(_S1129)), (79U)));
    uint _S1131 = 3U * _S1130;
    float3  _S1132 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1131], WAVELENGTH_WEIGHTS_0[_S1131 + 1U], WAVELENGTH_WEIGHTS_0[_S1131 + 2U]);
    float3  _S1133 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1131 + 3U], WAVELENGTH_WEIGHTS_0[_S1131 + 4U], WAVELENGTH_WEIGHTS_0[_S1131 + 5U]);
    return _S1132 + (_S1133 - _S1132) * make_float3 (_S1129 - float(_S1130));
}

__device__ float dispersedIor(float ior_1, float dispersion_1, float wavelength_7)
{
    float _S1134 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1135 = _S1134 * (1.0f / (wavelength_7 * wavelength_7) - 2.89662933349609375f);
    bool _S1136 = dispersion_1 > 0.0f;
    float _S1137 = _slang_select(_S1136, _S1135,0.0f);
    return ior_1 + _S1137;
}

__device__ float2  vertexEta(BSDFMaterial material_17, float n_dot_v_0)
{
    bool _S1138 = n_dot_v_0 < 0.0f;
    float _S1139 = _slang_select(_S1138, material_17.ior,1.0f);
    float _S1140 = _slang_select(_S1138, 1.0f,material_17.ior);
    return make_float2 (_S1139, _S1140);
}

__device__ float2  wavelengthEta(BSDFMaterial material_18, float n_dot_v_1, float wavelength_8)
{
    BSDFMaterial refractive_0 = material_18;
    float _S1141 = dispersedIor(material_18.ior, material_18.dispersion, wavelength_8);
    bool _S1142 = wavelength_8 > 0.0f;
    float _S1143 = _slang_select(_S1142, _S1141,material_18.ior);
    (&refractive_0)->ior = _S1143;
    float2  _S1144 = vertexEta(refractive_0, n_dot_v_1);
    return _S1144;
}

__device__ bool neeDecision(BSDFMaterial material_19, float n_dot_v_2, float eta_i_5, float eta_o_5)
{
    float _S1145 = fresnel((F32_abs((n_dot_v_2))), eta_i_5, eta_o_5);
    float3  _S1146 = mix_0(make_float3 (_S1145), material_19.albedo, material_19.metallic);
    float _S1147 = rgb_to_greyscale(_S1146);
    float _S1148 = (F32_max(((1.0f - _S1147) * (1.0f - material_19.metallic) * (1.0f - material_19.transmission)), (0.0f)));
    bool _S1149 = _S1148 > 0.03999999910593033f;
    bool _S1150;
    if(_S1149)
    {
        _S1150 = true;
    }
    else
    {
        _S1150 = (material_19.roughness) > 0.20000000298023224f;
    }
    return _S1150;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_20)
{
    float _S1151 = rgb_to_greyscale(material_20->translucent);
    return _S1151 > 0.0f;
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
    MediumSides _S1152;
    (&_S1152)->behind = *behind_0;
    (&_S1152)->front = *front_0;
    (&_S1152)->fillings = fillings_1;
    (&_S1152)->face = face_1;
    return _S1152;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_10, FKMedium * medium_0, uint filling_0, float3  dir_13, FKMedium * outside_0)
{
    float3  _S1153 = surface_10->geometry_n;
    MediumSides _S1154 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_10->geometry_n);
    MediumSides sides_0 = _S1154;
    bool _S1155 = surface_10->encloses;
    if(_S1155)
    {
        (&sides_0)->behind = surface_10->volume;
        *&((&(&sides_0)->fillings)->x) = surface_10->fills;
        bool _S1156 = (dot_0(dir_13, _S1153)) > 0.0f;
        if(_S1156)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_11, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_14, uint depth_3, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1157 = surface_11->geometry_n;
    ShadowContext _S1158 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_11->geometry_n, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1159 = surface_11->encloses;
    ShadowContext context_4;
    if(_S1159)
    {
        FKSurface faced_1 = *surface_11;
        float3  _S1160 = - _S1157;
        float3  _S1161 = _slang_select(turned_0, _S1160,_S1157);
        (&faced_1)->geometry_n = _S1161;
        FKMedium _S1162 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1163 = faced_1;
        FKMedium _S1164 = _S1162;
        MediumSides _S1165 = mediumSides_0(&_S1163, &_S1164, filling_1, dir_14, outside_1);
        ShadowContext _S1166 = ShadowContext_x24init_0(_S1165.behind.extinction, _S1165.front.extinction, _S1165.fillings, _S1157, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1167 = _S1165.fillings;
            ShadowContext _S1168 = ShadowContext_x24init_0(_S1165.front.extinction, _S1165.behind.extinction, uint2 {_S1167.y, _S1167.x}, _S1157, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1168;
        }
        else
        {
            context_4 = _S1166;
        }
    }
    else
    {
        context_4 = _S1158;
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
    float3  _S1169 = light_2->dir;
    bool _S1170 = (dot_0(geometry_n_3, - in_dir_8) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_4;
    float3  _S1171 = BSDF(in_dir_8, _S1169, smooth_n_5, *material_21, eta_i_6, eta_o_6, _S1170, random_state_13, &throughputs_1, &pdfs_4);
    bool _S1172 = !competing_1;
    bool _S1173;
    if(_S1172)
    {
        _S1173 = true;
    }
    else
    {
        _S1173 = (light_2->density) == 0.0f;
    }
    if(_S1173)
    {
        return _S1171 * light_2->radiance;
    }
    float3  _S1174 = make_float3 (0.0f);
    uint i_26 = 0U;
    float3  weighted_0 = _S1174;
    for(;;)
    {
        if(i_26 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1175 = (pdfs_4[i_26]) > 0.0f;
        if(_S1175)
        {
            float _S1176 = light_2->density;
            float _S1177 = pdfs_4[i_26] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_26] * make_float3 (pdfs_4[i_26]) / make_float3 (_S1176 * (1.0f + _S1177 * _S1177));
            weighted_0 = weighted_1;
        }
        uint i_27 = i_26 + 1U;
        i_26 = i_27;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_14, bool refracted_3, uint lobe_4, float pdf_7)
{
    SampleBSDF _S1178;
    (&_S1178)->unit_direction = unit_direction_1;
    (&_S1178)->throughput = throughput_1;
    (&_S1178)->random_state = random_state_14;
    (&_S1178)->refracted = refracted_3;
    (&_S1178)->lobe = lobe_4;
    (&_S1178)->pdf = pdf_7;
    return _S1178;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  v_9, float3  n_i_13, float n_i_dot_v_3, BSDFMaterial material_22, Weights w_14, uint random_state_15)
{
    float3  _S1179 = make_float3 (1.0f);
    SampleBSDF _S1180 = SampleBSDF_x24init_0(_S1179, _S1179, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1180;
    Random _S1181 = pcg(random_state_15);
    Random _S1182 = pcg(_S1181.state);
    (&sample_1)->random_state = _S1182.state;
    float _S1183 = _S1181.value;
    float _S1184 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1183 * _S1183))))));
    float _S1185 = 6.28318548202514648f * _S1182.value;
    float3  _S1186 = tangentToWorld(make_float3 (_S1184 * (F32_cos((_S1185))), _S1181.value, _S1184 * (F32_sin((_S1185)))), n_i_13);
    (&sample_1)->unit_direction = _S1186;
    (&sample_1)->lobe = 4U;
    float3  _S1187 = sheenVelvetBSDF((&sample_1)->unit_direction, v_9, n_i_13, material_22, w_14);
    (&sample_1)->throughput = _S1187;
    float _S1188 = sheenVelvetPDF(_S1181.value, n_i_dot_v_3, w_14);
    (&sample_1)->pdf = _S1188;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1189 = (F32_sqrt((random_1_0)));
    float _S1190 = 6.28318548202514648f * random_2_0;
    float _S1191 = _S1189 * (F32_cos((_S1190)));
    float _S1192 = _S1189 * (F32_sin((_S1190)));
    float _S1193 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1191 * _S1191 - _S1192 * _S1192))))));
    return make_float3 (_S1191, _S1193, _S1192);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_14, float n_i_dot_v_4, BSDFMaterial material_23, Weights w_15, uint random_state_16)
{
    float3  _S1194 = make_float3 (1.0f);
    SampleBSDF _S1195 = SampleBSDF_x24init_0(_S1194, _S1194, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1195;
    Random _S1196 = pcg(random_state_16);
    Random _S1197 = pcg(_S1196.state);
    (&sample_2)->random_state = _S1197.state;
    float3  _S1198 = sampleCosWeightedHemisphere(_S1196.value, _S1197.value);
    float _S1199 = translucentShare(material_23);
    bool _S1200 = u_3 < (w_15.p_diffuse * _S1199);
    float _S1201 = _S1198.y;
    float _S1202 = - _S1201;
    float _S1203 = _slang_select(_S1200, _S1202,_S1201);
    float3  _S1204 = tangentToWorld(make_float3 (_S1198.x, _S1203, _S1198.z), n_i_14);
    (&sample_2)->unit_direction = _S1204;
    (&sample_2)->refracted = _S1200;
    (&sample_2)->lobe = 0U;
    float3  _S1205 = diffuseBSDF((&sample_2)->unit_direction, n_i_14, material_23, w_15);
    (&sample_2)->throughput = _S1205;
    float _S1206 = diffusePDF(_S1203, n_i_dot_v_4, material_23, w_15);
    (&sample_2)->pdf = _S1206;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_15, ToonProfile profile_3, Weights w_16, uint random_state_17)
{
    float3  _S1207 = make_float3 (1.0f);
    SampleBSDF _S1208 = SampleBSDF_x24init_0(_S1207, _S1207, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1208;
    Random _S1209 = pcg(random_state_17);
    Random _S1210 = pcg(_S1209.state);
    (&sample_3)->random_state = _S1210.state;
    float _S1211 = _S1209.value * profile_3.norm / 6.28318548202514648f;
    float t_23;
    if(profile_3.glossy)
    {
        t_23 = (F32_acos((clamp_1(1.0f - _S1211, -1.0f, 1.0f))));
    }
    else
    {
        t_23 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1211)))), (1.0f))))));
    }
    if(t_23 < (profile_3.a))
    {
    }
    else
    {
        t_23 = (profile_3.a + profile_3.b) / 2.0f;
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
        float _S1212 = toonP(t_23, profile_3.a, profile_3.s);
        float _S1213 = _S1212 * (F32_sin((t_23)));
        float _S1214;
        if(profile_3.glossy)
        {
            _S1214 = 1.0f;
        }
        else
        {
            _S1214 = (F32_cos((t_23)));
        }
        float _S1215 = _S1213 * _S1214;
        float _S1216 = toonIntegral(t_23, profile_3.a, profile_3.s, profile_3.glossy);
        float _S1217 = (_S1216 - _S1211) / _S1215;
        bool _S1218 = _S1215 > 0.0f;
        float _S1219 = _slang_select(_S1218, _S1217,0.0f);
        float _S1220 = clamp_1(t_23 - _S1219, 0.0f, profile_3.b);
        int k_1 = k_0 + int(1);
        t_23 = _S1220;
        k_0 = k_1;
    }
    float _S1221 = 6.28318548202514648f * _S1210.value;
    float _S1222 = (F32_sin((t_23)));
    float3  _S1223 = tangentToWorld(make_float3 (_S1222 * (F32_cos((_S1221))), (F32_cos((t_23))), _S1222 * (F32_sin((_S1221)))), profile_3.axis);
    (&sample_3)->unit_direction = _S1223;
    bool _S1224 = (dot_0(n_i_15, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1224;
    (&sample_3)->lobe = 6U;
    float3  _S1225 = toonBSDF((&sample_3)->unit_direction, n_i_15, profile_3, w_16);
    (&sample_3)->throughput = _S1225;
    float _S1226 = toonPDF((&sample_3)->unit_direction, n_i_15, profile_3, w_16);
    (&sample_3)->pdf = _S1226;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_16, float alpha_8, AnisotropicFrame frame_6, BSDFMaterial material_24, Weights w_17, float pdf_h_3, float eta_i_7, float eta_o_7, uint random_state_18)
{
    float3  _S1227 = make_float3 (1.0f);
    SampleBSDF _S1228 = SampleBSDF_x24init_0(_S1227, _S1227, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1228;
    (&sample_4)->unit_direction = w_17.refracted;
    (&sample_4)->random_state = random_state_18;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1229 = refractBSDF((&sample_4)->unit_direction, n_i_16, alpha_8, frame_6, material_24, w_17);
    (&sample_4)->throughput = _S1229;
    float _S1230 = refractPDF(dot_0((&sample_4)->unit_direction, ggx_n_3), pdf_h_3, w_17, eta_i_7, eta_o_7);
    (&sample_4)->pdf = _S1230;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_28, float3  n_9)
{
    return i_28 - make_float3 (2.0f * dot_0(n_9, i_28)) * n_9;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_17, float alpha_9, AnisotropicFrame frame_7, Weights w_18, float pdf_h_4, uint random_state_19)
{
    float3  _S1231 = make_float3 (1.0f);
    SampleBSDF _S1232 = SampleBSDF_x24init_0(_S1231, _S1231, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1232;
    float3  _S1233 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S1234 = ((((_S1233)) * make_float3(rnorm3df(((_S1233)).x, ((_S1233)).y, ((_S1233)).z))));
    (&sample_5)->unit_direction = _S1234;
    (&sample_5)->random_state = random_state_19;
    (&sample_5)->lobe = 2U;
    float3  _S1235 = reflectBSDF((&sample_5)->unit_direction, n_i_17, alpha_9, frame_7, w_18);
    (&sample_5)->throughput = _S1235;
    float _S1236 = reflectPDF(pdf_h_4, w_18);
    (&sample_5)->pdf = _S1236;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_10, BSDFMaterial material_25, float eta_i_8, float eta_o_8, uint random_init_0, float2  screen_space_0)
{
    uint random_state_20 = random_init_0;
    float3  _S1237 = negate_0(in_dir_10);
    float _S1238 = dot_0(n_10, _S1237);
    float _S1239 = sign_0(_S1238);
    float3  n_i_18 = n_10 * make_float3 (_S1239);
    float _S1240 = (F32_abs((_S1238)));
    float _S1241 = material_25.roughness;
    float _S1242 = _S1241 * _S1241;
    AnisotropicFrame _S1243 = anisotropicFrame(material_25, n_i_18);
    SheenProfile _S1244 = sheenProfile(_S1237, n_i_18, material_25);
    float3  _S1245 = sampleHalfVector(_S1237, n_i_18, _S1242, _S1243, &random_state_20);
    Weights _S1246 = lobeWeights(in_dir_10, _S1237, n_i_18, _S1245, _S1243, _S1244, material_25, eta_i_8, eta_o_8);
    Random _S1247 = pcg(random_state_20);
    random_state_20 = _S1247.state;
    bool _S1248 = (_S1247.value) < (_S1246.p_sheen_velvet);
    if(_S1248)
    {
        SampleBSDF _S1249 = sheenVelvetSample(_S1237, n_i_18, _S1240, material_25, _S1246, random_state_20);
        return _S1249;
    }
    float _S1250 = _S1247.value - _S1246.p_sheen_velvet;
    bool _S1251 = _S1250 < (_S1246.p_diffuse);
    if(_S1251)
    {
        SampleBSDF _S1252 = diffuseSample(_S1250, n_i_18, _S1240, material_25, _S1246, random_state_20);
        return _S1252;
    }
    bool _S1253 = _S1250 < (_S1246.p_diffuse + _S1246.p_toon);
    if(_S1253)
    {
        ToonProfile _S1254 = toonProfile(_S1237, n_i_18, material_25);
        SampleBSDF _S1255 = toonSample(n_i_18, _S1254, _S1246, random_state_20);
        return _S1255;
    }
    float _S1256 = vndfPDF(_S1237, _S1245, n_i_18, _S1240, _S1242, _S1243, _S1246.v_dot_h);
    bool _S1257 = (_S1250 - _S1246.p_toon) < (_S1246.p_diffuse + _S1246.p_refract);
    if(_S1257)
    {
        SampleBSDF _S1258 = refractSample(_S1245, n_i_18, _S1242, _S1243, material_25, _S1246, _S1256, eta_i_8, eta_o_8, random_state_20);
        return _S1258;
    }
    SampleBSDF _S1259 = reflectSample(in_dir_10, _S1245, n_i_18, _S1242, _S1243, _S1246, _S1256, random_state_20);
    return _S1259;
}

static __device__ bool boundsVolume_0(FKSurface * surface_12)
{
    return surface_12->encloses;
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_8, bool replay_1, float scale_3, Selection * sel_7)
{
    float spread_1;
    bool turned_1;
    bool is_inside_6;
    bool viewed_0;
    bool _S1260;
    bool _S1261;
    float density_2;
    float wavelength_9;
    float width_3;
    float sky_pdf_0;
    float threshold_0;
    uint b_6;
    uint layer_0;
    float3  throughput_2;
    float3  spectral_weight_0;
    TreeSample light_3;
    int _S1262;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_4;
    float sky_pdf_1;
    float spread_3;
    float width_5;
    uint b_7;
    float3  _S1263 = make_float3 (0.0f);
    Shift _S1264 = Shift_x24init_0(_S1263, 0.0f);
    uint _S1265 = r_8->path;
    uint _S1266 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1267 = extractBits_0(_S1265, 5U, 5U);
    uint _S1268 = extractBits_0(_S1265, 10U, 2U);
    uint _S1269 = extractBits_0(_S1265, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S1270 = _S1269 >= 3U;
        uint _S1271 = _slang_select(_S1270, 1U,0U);
        uint _S1272 = _S1266 + _S1271;
        uint _S1273 = (fcptMaxBounces());
        passes_0 = _S1272 > _S1273;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1264;
    }
    uint _S1274 = _S1267 - 1U;
    bool _S1275 = _S1269 == 3U;
    uint _S1276 = _slang_select(_S1275, 1U,0U);
    uint _S1277 = _S1266 + _S1276;
    bool _S1278 = _S1268 == 0U;
    uint _S1279 = _slang_select(_S1278, _S1277,_S1274);
    FKHit _S1280 = (fcptReservoirHit((*r_8)));
    float3  _S1281 = dom_7->x0;
    float3  _S1282 = dom_7->x1 - dom_7->x0;
    float3  _S1283 = ((((_S1282)) * make_float3(rnorm3df(((_S1282)).x, ((_S1282)).y, ((_S1282)).z))));
    FKRay _S1284 = Ray_x24init_0(dom_7->x1, _S1283);
    FKRay ray_2 = _S1284;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1263;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_2 = throughput_3;
    float3  glowed_0 = _S1263;
    float3  extinction_in_0 = _S1263;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1285 = dom_7->spread;
    float _S1286 = dom_7->width;
    float _S1287 = length_0(_S1282);
    NEEVertex _S1288 = NEEVertex_x24init_0(true, 0.0f, _S1263, _S1263, _S1263);
    NEEVertex nee_vertex_0 = _S1288;
    Vertex _S1289 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1289;
    Reservoir _S1290 = (Reservoir{});
    Reservoir chain_0 = _S1290;
    uint _S1291 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    uint _S1292 = extractBits_0(_S1265, 24U, 8U);
    uint _S1293 = insertBits_0(0U, _S1292, 24U, 8U);
    (&chain_0)->path = _S1293;
    (&ray_2)->origin = _S1281;
    (&hit_4)->distance = _S1287;
    FKMedium _S1294 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1295 = filling_2;
    bool _S1296 = (fcptVaryingUsed());
    uint _S1297 = _slang_select(_S1296, _S1295,4294967295U);
    filling_2 = _S1297;
    scatter_in_0 = _S1294.scatter;
    extinction_in_0 = _S1294.extinction;
    g_in_0 = _S1294.g;
    Reservoir _S1298 = chain_0;
    uint _S1299 = filling_2;
    for(;;)
    {
        bool _S1300 = (fcptVaryingUsed());
        if(_S1300)
        {
            passes_0 = _S1299 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1301 = (fcptMajorant((_S1299)));
            spread_1 = _S1301;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S1279;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1268 == 1U;
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
            ended_0 = _S1264;
            sky_pdf_0 = 0.0f;
            spread_1 = _S1285;
            width_3 = _S1286;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_6 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1302 = (&prev_0)->rough;
        if(_S1302)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1303 = stream(_S1291, 384U);
        uint tracking_0 = _S1303;
        weight_2 = throughput_3;
        glowed_0 = _S1263;
        b_6 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        wavelength_9 = _S1285;
        width_3 = _S1286;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1262 = int(1);
                break;
            }
            uint _S1304 = b_6 + 320U;
            bool _S1305 = b_6 == 4294967295U;
            uint _S1306 = _slang_select(_S1305, 384U,_S1304);
            uint _S1307 = stream(_S1291, _S1306);
            Random _S1308 = pcg(_S1307);
            float _S1309 = - (F32_log((1.0f - _S1308.value))) / spread_1;
            if(passes_0)
            {
                float3  _S1310 = (&ray_2)->origin;
                float3  _S1311 = (&ray_2)->unit_direction;
                float _S1312 = (&hit_4)->distance;
                uint _S1313 = _slang_select(_S1305, 0U,b_6);
                uint _S1314 = (&prev_0)->lobe;
                uint _S1315 = _slang_select(_S1305, 3U,_S1314);
                float _S1316 = (fcptTrackMedium((_S1299), (_S1310), (_S1311), (_S1312), (&tracking_0), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1313), (_S1315), (_S1305)));
                threshold_0 = _S1316;
            }
            else
            {
                threshold_0 = _S1309;
            }
            bool _S1317 = !(threshold_0 < ((&hit_4)->distance));
            if(_S1317)
            {
                _S1262 = int(1);
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
                float3  _S1318 = pathColor(throughput_2 * glowed_0, throughput_3, 0.0f);
                float3  _S1319 = _S1318 / make_float3 (density_2);
                float3  _S1320 = sel_7->glow + _S1319;
                sel_7->glow = _S1320;
            }
            else
            {
            }
            glowed_0 = _S1263;
            uint b_8 = b_6 + 1U;
            float3  _S1321 = (&ray_2)->origin + make_float3 (threshold_0) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1321;
            float3  _S1322 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, threshold_0, true);
            float3  _S1323 = weight_2;
            float _S1324 = upsample(weight_2, 0.0f);
            float3  _S1325 = make_float3 (_S1324);
            float3  _S1326 = _slang_select(false, _S1325,_S1323);
            float3  _S1327 = _slang_select(passes_0, _S1326,_S1322);
            float3  throughput_4 = throughput_2 * _S1327;
            uint _S1328 = stream(_S1291, b_8 + 320U);
            tracking_0 = _S1328;
            weight_2 = throughput_3;
            float width_6 = width_3 + wavelength_9 * threshold_0;
            float _S1329 = wavelength_9 + 3.14159274101257324f;
            bool _S1330 = !replay_1;
            if(_S1330)
            {
                is_inside_6 = true;
            }
            else
            {
                bool _S1331 = b_8 == _S1279;
                if(_S1331)
                {
                    is_inside_6 = !passes_0;
                }
                else
                {
                    is_inside_6 = false;
                }
            }
            TreeSample _S1332 = TreeSample_x24init_0(_S1263, _S1263, 0.0f, 0U);
            if(is_inside_6)
            {
                float3  _S1333 = (&ray_2)->origin;
                float3  _S1334 = (&ray_2)->unit_direction;
                float3  _S1335 = (&ray_2)->unit_direction;
                uint _S1336 = stream(_S1291, b_8 + 64U);
                float3  _S1337 = extinction_in_0;
                float3  _S1338 = extinction_in_0;
                uint2  _S1339 = make_uint2 (_S1299);
                float3  _S1340 = (&ray_2)->unit_direction;
                uint _S1341 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                FKHit _S1342 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1343 = _S1342;
                ShadowContext _S1344 = ShadowContext_x24init_0(_S1337, _S1338, _S1339, _S1340, b_8, _S1341, false, threshold_0, width_6, &_S1343, false);
                ShadowContext _S1345 = _S1344;
                TreeSample _S1346 = sampleLightTree_0(_S1333, _S1334, _S1335, 0.0f, true, _S1336, &_S1345);
                light_3 = _S1346;
            }
            else
            {
                light_3 = _S1332;
            }
            float _S1347 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1348 = (fcptMaxBounces());
            bool _S1349 = b_8 < _S1348;
            if(_S1349)
            {
                viewed_0 = (light_3.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S1350 = _slang_select(viewed_0, _S1347,0.0f);
            float3  _S1351 = throughput_4 * light_3.radiance;
            float _S1352 = powerHeuristic(light_3.density, _S1350);
            float3  _S1353 = pathColor(_S1351 * make_float3 (_S1347 * _S1352), throughput_3, 0.0f);
            float3  _S1354 = _slang_select(is_inside_6, _S1353,_S1263);
            if(replay_1)
            {
                _S1260 = b_8 == _S1279;
            }
            else
            {
                _S1260 = false;
            }
            if(_S1260)
            {
                bool _S1355 = _S1268 == 2U;
                if(_S1355)
                {
                    float _S1356 = resamplingTarget(_S1354);
                    passes_0 = _S1356 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1357 = Shift_x24init_0(_S1354, 1.0f);
                    _S1262 = int(0);
                    ended_0 = _S1357;
                    spread_1 = _S1329;
                    threshold_0 = width_6;
                    spectral_weight_0 = throughput_4;
                    layer_0 = b_8;
                    break;
                }
                _S1262 = int(0);
                ended_0 = _S1264;
                spread_1 = _S1329;
                threshold_0 = width_6;
                spectral_weight_0 = throughput_4;
                layer_0 = b_8;
                break;
            }
            if(_S1330)
            {
                Reservoir candidate_3 = _S1298;
                uint _S1358 = extractBits_0(_S1298.path, 24U, 8U);
                uint _S1359 = insertBits_0(0U, _S1358, 24U, 8U);
                uint _S1360 = extractBits_0(_S1298.path, 10U, 2U);
                bool _S1361 = _S1360 == 1U;
                if(_S1361)
                {
                    float3  _S1362 = safeDivide(_S1354, _S1263);
                    (&candidate_3)->radiance = _S1362;
                }
                else
                {
                    uint _S1363 = insertBits_0(_S1359, b_8 + 1U, 5U, 5U);
                    uint _S1364 = insertBits_0(_S1363, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1364;
                }
                Reservoir _S1365 = withEnd(candidate_3, 0U, b_8, _S1354);
                offer(sel_7, _S1365, _S1354 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1366 = survivalProbability(abs_0(throughput_4), density_2);
                uint _S1367 = stream(_S1291, b_8 + 128U);
                Random _S1368 = pcg(_S1367);
                bool _S1369 = _S1366 < (_S1368.value);
                if(_S1369)
                {
                    _S1261 = true;
                }
                else
                {
                    uint _S1370 = (fcptMaxBounces());
                    _S1261 = b_8 >= _S1370;
                }
                if(_S1261)
                {
                    _S1262 = int(0);
                    ended_0 = _S1264;
                    spread_1 = _S1329;
                    threshold_0 = width_6;
                    spectral_weight_0 = throughput_4;
                    layer_0 = b_8;
                    break;
                }
                float _S1371 = density_2 * _S1366;
                density_2 = _S1371;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1372 = stream(_S1291, b_8);
            float3  _S1373 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1372, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1373;
            NEEVertex _S1374 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1263, (&ray_2)->origin);
            nee_vertex_0 = _S1374;
            Vertex _S1375 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_0 = _S1375;
            float _S1376 = (&prev_0)->pdf;
            FKRay _S1377 = ray_2;
            FKHit _S1378 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1379 = (fcptTraverseInstanceBVH((_S1377), (true), (4.294967296e+09f), (false), (_S1378), (false)));
            hit_4 = _S1379;
            b_6 = b_8;
            throughput_2 = throughput_4;
            wavelength_9 = _S1329;
            width_3 = width_6;
            sky_pdf_0 = _S1376;
        }
        if(_S1262 != int(1))
        {
            width_3 = threshold_0;
            throughput_2 = spectral_weight_0;
            b_6 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1264;
        spread_1 = wavelength_9;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1380 = b_6 == 4294967295U;
    bool _S1381 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1381)
    {
        bool _S1382 = !(&nee_vertex_0)->none;
        float _S1383 = _slang_select(_S1382, sky_pdf_0,0.0f);
        float _S1384 = escapeWeight_0(_S1383, (&ray_2)->unit_direction);
        float3  _S1385 = environment_0((&ray_2)->unit_direction, b_6, (&prev_0)->lobe);
        float3  _S1386 = pathColor(throughput_2 * _S1385, throughput_3, 0.0f);
        if(replay_1)
        {
            bool _S1387 = b_6 == _S1279;
            if(_S1387)
            {
                passes_0 = _S1268 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1386 * make_float3 (_S1384) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1278)
            {
                passes_0 = _S1275;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_6 == _S1266;
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
                return Shift_x24init_0(_S1386 * make_float3 (_S1384), 1.0f);
            }
            return _S1264;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1388 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1389 = _S1388 == 1U;
        if(_S1389)
        {
            uint _S1390 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1391 = _S1390 == b_6;
            float _S1392 = _slang_select(_S1391, 1.0f,_S1384);
            float3  _S1393 = safeDivide(_S1386 * make_float3 (_S1392), _S1263);
            (&candidate_4)->radiance = _S1393;
        }
        else
        {
            bool _S1394 = (&prev_0)->rough;
            if(_S1394)
            {
                uint _S1395 = insertBits_0(_S1293, b_6 + 1U, 5U, 5U);
                uint _S1396 = insertBits_0(_S1395, 3U, 10U, 2U);
                uint _S1397 = insertBits_0(_S1396, (&prev_0)->lobe, 15U, 3U);
                bool _S1398 = (&prev_0)->inside;
                uint _S1399 = _slang_select(_S1398, 1U,0U);
                uint _S1400 = insertBits_0(_S1397, _S1399, 22U, 1U);
                (&candidate_4)->path = _S1400;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1401 = _S1386 * make_float3 (_S1384);
        Reservoir _S1402 = withEnd(candidate_4, 3U, b_6, _S1401);
        offer(sel_7, _S1402, _S1401 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1264;
    }
    float3  _S1403 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1403;
    bool _S1404 = (fcptVaryingUsed());
    if(_S1404)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1405 = !replay_1;
        if(_S1405)
        {
            float3  _S1406 = pathColor(throughput_2 * glowed_0, throughput_3, 0.0f);
            float3  _S1407 = _S1406 / make_float3 (density_2);
            float3  _S1408 = sel_7->glow + _S1407;
            sel_7->glow = _S1408;
        }
        float3  _S1409 = throughput_2 * weight_2;
        throughput_2 = _S1409;
    }
    else
    {
        float3  _S1410 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1411 = throughput_2 * _S1410;
        throughput_2 = _S1411;
    }
    float _S1412 = width_3 + spread_1 * (&hit_4)->distance;
    uint _S1413 = b_6 + 1U;
    b_6 = _S1413;
    layer_0 = 0U;
    width_3 = _S1412;
    passes_0 = false;
    wavelength_9 = 0.0f;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_6 = false;
    spectral_weight_0 = throughput_3;
    float3  chain_throughput_0 = _S1263;
    float3  reconnection_0 = _S1263;
    viewed_0 = _S1380;
    for(;;)
    {
        bool _S1414 = ((&hit_4)->is_point_light) == 1U;
        if(replay_1)
        {
            _S1260 = _S1268 == 1U;
        }
        else
        {
            _S1260 = false;
        }
        if(_S1260)
        {
            _S1261 = b_6 == _S1267;
        }
        else
        {
            _S1261 = false;
        }
        bool _S1415;
        if(_S1261)
        {
            bool _S1416 = ((&hit_4)->instance_index) != (_S1280.instance_index);
            if(_S1416)
            {
                _S1415 = true;
            }
            else
            {
                _S1415 = ((&hit_4)->triangle_index) != (_S1280.triangle_index);
            }
        }
        else
        {
            _S1415 = false;
        }
        if(_S1415)
        {
            return _S1264;
        }
        FKMedium _S1417 = Medium_x24init_0(_S1263, _S1263, 0.0f);
        BSDFMaterial _S1418 = Material_x24init_0(_S1263, _S1263, 0.0f, 0.0f, 0.0f, 0.0f, _S1263, throughput_3, 1.0f, _S1263, _S1263, 0.5f, 0.0f, 0.0f, _S1263, 0.0f, _S1263, 0.0f);
        FKMedium _S1419 = _S1417;
        FKSurface _S1420 = Surface_x24init_0(_S1263, _S1263, 0.0f, &_S1418, false, 0U, 1.0f, false, &_S1419, 4294967295U, _S1263);
        bool _S1421 = !_S1414;
        bool scatter_2;
        bool is_inside_7;
        float geometry_density_0;
        float3  throughput_5;
        FKSurface surface_13;
        if(_S1421)
        {
            uint _S1422 = stream(_S1291, b_6);
            uint _S1423 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKSurface _S1424 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1422), (width_3), (layer_0), (b_6), (_S1423), ((&ray_2)->unit_direction)));
            bool _S1425 = !passes_0;
            FKSurface _S1426 = _S1424;
            FKSurface _S1427 = emitting_0(&_S1426, _S1425);
            uint _S1428 = stream(_S1291, b_6 + 256U);
            Random _S1429 = pcg(_S1428);
            FKSurface _S1430 = _S1427;
            FKSurface _S1431 = uncovered_0(&_S1430, _S1429.value);
            float _S1432 = facingSign(_S1431.material.transmission, _S1431.geometry_n, (&ray_2)->unit_direction);
            bool _S1433 = _S1432 < 0.0f;
            bool _S1434 = (_S1431.material.transmission) > 0.0f;
            if(_S1434)
            {
                bool _S1435 = arrivesBehind_0((&ray_2)->unit_direction, _S1431.geometry_n);
                scatter_2 = _S1435;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1436 = _S1431;
            FKSurface _S1437 = facingRay_0(&_S1436, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1438 = arrivesBehind_0((&ray_2)->unit_direction, _S1437.geometry_n);
                is_inside_7 = _S1438;
            }
            else
            {
                is_inside_7 = scatter_2;
            }
            if(is_inside_7)
            {
                float _S1439 = (&hit_4)->distance;
                float _S1440 = upsample(_S1437.material.absorption, wavelength_9);
                float3  _S1441 = make_float3 (_S1440);
                bool _S1442 = wavelength_9 > 0.0f;
                float3  _S1443 = _slang_select(_S1442, _S1441,_S1437.material.absorption);
                float3  _S1444 = beerLambert(_S1439, _S1443);
                float3  _S1445 = throughput_2 * _S1444;
                throughput_5 = _S1445;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1446 = !_S1437.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S1437.geometry_n, (&ray_2)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1447 = b_6 == _S1413;
            if(_S1447)
            {
                float _S1448 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1448;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S1449 = geometry_density_0;
            scatter_2 = _S1446;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1449;
            surface_13 = _S1437;
            turned_1 = _S1433;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_13 = _S1420;
            throughput_5 = throughput_2;
            is_inside_7 = is_inside_6;
        }
        bool _S1450;
        if(scatter_2)
        {
            _S1450 = (&prev_0)->rough;
        }
        else
        {
            _S1450 = false;
        }
        bool _S1451;
        if(_S1450)
        {
            _S1451 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1451 = false;
        }
        FKSurface _S1452 = surface_13;
        float _S1453 = dot_0(surface_13.smooth_n, - (&ray_2)->unit_direction);
        bool _S1454 = (fcptDispersionUsed());
        bool _S1455;
        if(_S1454)
        {
            _S1455 = wavelength_9 == 0.0f;
        }
        else
        {
            _S1455 = false;
        }
        bool _S1456;
        if(_S1455)
        {
            _S1456 = scatter_2;
        }
        else
        {
            _S1456 = false;
        }
        bool _S1457;
        if(_S1456)
        {
            bool _S1458 = dispersive(surface_13.material);
            _S1457 = _S1458;
        }
        else
        {
            _S1457 = false;
        }
        float3  throughput_6;
        if(_S1457)
        {
            uint _S1459 = stream(_S1291, 512U);
            Random _S1460 = pcg(_S1459);
            uint _S1461 = extractBits_0(_S1265, 25U, 7U);
            float _S1462 = (float(_S1461) + _S1460.value) / 128.0f;
            uint _S1463 = extractBits_0(_S1265, 24U, 1U);
            bool _S1464 = _S1463 == 1U;
            float _S1465 = _slang_select(_S1464, _S1462,_S1460.value);
            float2  _S1466 = sampleWavelength(_S1465);
            float wavelength_10 = _S1466.x;
            float3  _S1467 = wavelengthWeights(wavelength_10);
            float3  _S1468 = _S1467 / make_float3 (_S1466.y);
            float _S1469 = upsample(throughput_5, wavelength_10);
            float3  _S1470 = make_float3 (_S1469);
            float _S1471 = upsample(scatter_in_0, wavelength_10);
            float3  _S1472 = make_float3 (_S1471);
            scatter_in_0 = _S1472;
            float _S1473 = upsample(extinction_in_0, wavelength_10);
            float3  _S1474 = make_float3 (_S1473);
            extinction_in_0 = _S1474;
            wavelength_9 = wavelength_10;
            throughput_6 = _S1470;
            spectral_weight_0 = _S1468;
        }
        else
        {
            throughput_6 = throughput_5;
        }
        BSDFMaterial _S1475 = pathMaterial(surface_13.material, wavelength_9);
        float2  _S1476 = wavelengthEta(_S1475, _S1453, wavelength_9);
        bool _S1477;
        if(scatter_2)
        {
            bool _S1478 = neeDecision(_S1475, _S1453, _S1476.x, _S1476.y);
            _S1477 = _S1478;
        }
        else
        {
            _S1477 = false;
        }
        bool _S1479;
        if(passes_0)
        {
            _S1479 = true;
        }
        else
        {
            _S1479 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1479)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1477;
        }
        bool _S1480 = (fcptHairUsed());
        bool _S1481;
        if(_S1480)
        {
            float3  _S1482 = surface_13.hair;
            _S1481 = (dot_0(_S1482, _S1482)) > 0.0f;
        }
        else
        {
            _S1481 = false;
        }
        bool _S1483;
        if(_S1481)
        {
            _S1483 = true;
        }
        else
        {
            BSDFMaterial _S1484 = _S1475;
            bool _S1485 = isTranslucent_0(&_S1484);
            _S1483 = _S1485;
        }
        bool _S1486;
        if(_S1483)
        {
            _S1486 = true;
        }
        else
        {
            bool _S1487 = (_S1475.transmission) > 0.0f;
            if(_S1487)
            {
                uint _S1488 = (fcptLayers((hit_4)));
                _S1486 = _S1488 == 1U;
            }
            else
            {
                _S1486 = false;
            }
        }
        float3  emission_0;
        if(_S1414)
        {
            float3  _S1489 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1489;
        }
        else
        {
            emission_0 = _S1475.emissive;
        }
        bool _S1490 = !replay_1;
        bool _S1491;
        if(_S1490)
        {
            _S1491 = true;
        }
        else
        {
            _S1491 = b_6 >= _S1279;
        }
        bool _S1492;
        if(_S1491)
        {
            float _S1493 = rgb_to_greyscale(emission_0);
            _S1492 = _S1493 > 0.0f;
        }
        else
        {
            _S1492 = false;
        }
        float3  emission_1;
        if(_S1492)
        {
            NEEVertex _S1494 = nee_vertex_0;
            FKHit _S1495 = hit_4;
            float _S1496 = emissionWeight_0(&_S1494, &_S1495, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1496);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1497;
        if(replay_1)
        {
            _S1497 = _S1268 == 1U;
        }
        else
        {
            _S1497 = false;
        }
        bool _S1498;
        if(_S1497)
        {
            _S1498 = b_6 > _S1267;
        }
        else
        {
            _S1498 = false;
        }
        bool _S1499;
        if(_S1498)
        {
            _S1499 = b_6 == _S1266;
        }
        else
        {
            _S1499 = false;
        }
        bool _S1500;
        if(_S1499)
        {
            bool _S1501 = _S1269 == 1U;
            if(_S1501)
            {
                _S1500 = true;
            }
            else
            {
                _S1500 = _S1269 == 2U;
            }
        }
        else
        {
            _S1500 = false;
        }
        if(_S1500)
        {
            bool _S1502 = _S1414 != (_S1269 == 2U);
            if(_S1502)
            {
                return _S1264;
            }
            float3  _S1503 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_9);
            return Shift_x24init_0(_S1503 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1504 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1505 = _S1504 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1506 = insertBits_0(_S1293, b_6, 5U, 5U);
        uint _S1507 = insertBits_0(_S1506, 1U, 10U, 2U);
        uint _S1508 = insertBits_0(_S1507, (&prev_0)->lobe, 15U, 3U);
        bool _S1509 = (&prev_0)->inside;
        uint _S1510 = _slang_select(_S1509, 1U,0U);
        uint _S1511 = insertBits_0(_S1508, _S1510, 22U, 1U);
        (&here_0)->path = _S1511;
        uint _S1512 = (&here_0)->path;
        bool _S1513 = wavelength_9 > 0.0f;
        uint _S1514 = _slang_select(_S1513, 1U,0U);
        uint _S1515 = insertBits_0(_S1512, _S1514, 23U, 1U);
        (&here_0)->path = _S1515;
        float _S1516 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S1516;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1517;
        if(replay_1)
        {
            _S1517 = _S1268 == 1U;
        }
        else
        {
            _S1517 = false;
        }
        bool _S1518;
        if(_S1517)
        {
            _S1518 = b_6 == _S1267;
        }
        else
        {
            _S1518 = false;
        }
        bool _S1519 = b_6 == _S1279;
        bool _S1520;
        if(_S1519)
        {
            bool _S1521 = !scatter_2;
            if(_S1521)
            {
                _S1520 = true;
            }
            else
            {
                bool _S1522 = _S1268 != 1U;
                if(_S1522)
                {
                    _S1520 = _S1268 != 3U;
                }
                else
                {
                    _S1520 = false;
                }
            }
        }
        else
        {
            _S1520 = false;
        }
        bool _S1523;
        if(_S1520)
        {
            _S1523 = _S1268 == 2U;
        }
        else
        {
            _S1523 = false;
        }
        bool _S1524;
        if(_S1523)
        {
            _S1524 = !_S1451;
        }
        else
        {
            _S1524 = false;
        }
        bool _S1525;
        if(_S1524)
        {
            _S1525 = _S1269 != 4U;
        }
        else
        {
            _S1525 = false;
        }
        bool _S1526 = _S1267 == _S1266;
        bool _S1527;
        if(_S1526)
        {
            _S1527 = _S1269 == 0U;
        }
        else
        {
            _S1527 = false;
        }
        bool _S1528;
        if(_S1527)
        {
            _S1528 = ((&hit_4)->instance_index) == (_S1280.instance_index);
        }
        else
        {
            _S1528 = false;
        }
        bool _S1529;
        if(_S1528)
        {
            _S1529 = ((&hit_4)->triangle_index) == (_S1280.triangle_index);
        }
        else
        {
            _S1529 = false;
        }
        bool _S1530;
        if(_S1529)
        {
            _S1530 = _S1451;
        }
        else
        {
            _S1530 = false;
        }
        bool _S1531 = _slang_select(_S1518, _S1530,_S1525);
        bool _S1532;
        if(nee_0)
        {
            _S1532 = _slang_select(replay_1, _S1531,scatter_2);
        }
        else
        {
            _S1532 = false;
        }
        TreeSample _S1533 = TreeSample_x24init_0(_S1263, _S1263, 0.0f, 0U);
        uint2  _S1534 = make_uint2 (0U);
        float2  _S1535 = make_float2 (0.0f);
        FKHit _S1536 = Hit_x24init_0(_S1535, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1537 = _S1536;
        ShadowContext _S1538 = ShadowContext_x24init_0(_S1263, _S1263, _S1534, _S1263, 0U, 0U, false, 0.0f, 0.0f, &_S1537, false);
        bool _S1539;
        if(nee_0)
        {
            _S1539 = _S1491;
        }
        else
        {
            _S1539 = false;
        }
        ShadowContext context_5;
        if(_S1539)
        {
            uint _S1540 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKMedium _S1541 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1542 = surface_13;
            FKHit _S1543 = hit_4;
            FKMedium _S1544 = _S1541;
            ShadowContext _S1545 = shadowContext_0(&_S1542, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_6, _S1540, (&hit_4)->distance, width_3, &_S1543, _S1481, &_S1544);
            context_5 = _S1545;
        }
        else
        {
            context_5 = _S1538;
        }
        float3  throughput_7;
        float3  lit_0;
        if(_S1532)
        {
            float3  _S1546 = (&ray_2)->origin;
            if(_S1481)
            {
                throughput_7 = _S1263;
            }
            else
            {
                throughput_7 = _S1452.smooth_n;
            }
            FKSurface _S1547 = surface_13;
            uint _S1548 = stream(_S1291, b_6 + 64U);
            ShadowContext _S1549 = context_5;
            TreeSample _S1550 = sampleLightTree_0(_S1546, throughput_7, surface_13.geometry_n, surface_13.geometry_offset, _S1486, _S1548, &_S1549);
            bool _S1551 = any_1((_S1550.radiance) != _S1263);
            if(_S1551)
            {
                if(_S1481)
                {
                    uint _S1552 = (fcptMaxBounces());
                    bool _S1553 = b_6 < _S1552;
                    FKSurface _S1554 = surface_13;
                    TreeSample _S1555 = _S1550;
                    float3  _S1556 = hairLight_0(&_S1554, (&ray_2)->unit_direction, &_S1555, _S1553);
                    lit_0 = _S1556;
                }
                else
                {
                    float _S1557 = _S1476.x;
                    float _S1558 = _S1476.y;
                    uint _S1559 = (fcptMaxBounces());
                    bool _S1560 = b_6 < _S1559;
                    TreeSample _S1561 = _S1550;
                    BSDFMaterial _S1562 = _S1475;
                    float3  _S1563 = lightBSDF_0((&ray_2)->unit_direction, &_S1561, _S1452.smooth_n, _S1547.geometry_n, &_S1562, _S1557, _S1558, _S1560, surface_13.random_state);
                    lit_0 = _S1563;
                }
            }
            else
            {
                lit_0 = _S1263;
            }
            light_3 = _S1550;
        }
        else
        {
            light_3 = _S1533;
            lit_0 = _S1263;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1564;
        bool _S1565;
        float density_4;
        if(_S1518)
        {
            bool _S1566 = !_S1451;
            if(_S1566)
            {
                return _S1264;
            }
            uint _S1567 = extractBits_0(_S1265, 23U, 1U);
            bool _S1568 = _S1513 != (_S1567 == 1U);
            if(_S1568)
            {
                return _S1264;
            }
            float3  throughput_8 = throughput_6 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S1526)
            {
                viewed_1 = _S1269 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                float3  _S1569 = pathColor(throughput_8 * emission_1, spectral_weight_0, wavelength_9);
                return Shift_x24init_0(_S1569 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1526)
            {
                refracted_4 = _S1269 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1570 = !nee_0;
                if(_S1570)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1571 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1571 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1264;
                }
                float3  _S1572 = pathColor(throughput_8 * lit_0, spectral_weight_0, wavelength_9);
                return Shift_x24init_0(_S1572 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1526)
            {
                wrong_side_0 = _S1269 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1573 = !nee_0;
                if(_S1573)
                {
                    return _S1264;
                }
                bool _S1574 = (fcptWorldReadsPath());
                if(_S1574)
                {
                    float _S1575 = environmentPdf_0(r_8->dir);
                    uint _S1576 = b_6 + 1U;
                    FKSurface _S1577 = surface_13;
                    float3  _S1578 = skyColor_0((&ray_2)->unit_direction, r_8->dir, &_S1577, wavelength_9, _S1476, is_inside_7, _S1575, surface_13.random_state, _S1576);
                    float3  _S1579 = pathColor(throughput_8 * (_S1578 * r_8->radiance), spectral_weight_0, wavelength_9);
                    return Shift_x24init_0(_S1579 / make_float3 (r_8->jac), density_5 / r_8->jac);
                }
                float _S1580 = environmentPdf_0(r_8->dir);
                float3  _S1581 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_13, _S1475, _S1476, is_inside_7, _S1580, surface_13.random_state);
                float3  _S1582 = pathColor(throughput_8 * _S1581 * r_8->radiance, spectral_weight_0, wavelength_9);
                return Shift_x24init_0(_S1582 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1583 = extractBits_0(_S1265, 21U, 1U);
            bool _S1584 = nee_0 != (_S1583 == 1U);
            if(_S1584)
            {
                return _S1264;
            }
            throughput_7 = throughput_8;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S1519;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1585 = !scatter_2;
                if(_S1585)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1586 = _S1268 != 1U;
                    if(_S1586)
                    {
                        refracted_4 = _S1268 != 3U;
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
                bool _S1587 = _S1268 == 2U;
                if(_S1587)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1451;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1269 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1481)
                    {
                        return _S1264;
                    }
                    uint _S1588 = stream(_S1291, b_6 + 448U);
                    FKRay _S1589 = ray_2;
                    FKSurface _S1590 = surface_13;
                    ShadowContext _S1591 = context_5;
                    SkySample _S1592 = sampleSky_0(&_S1589, &_S1590, wavelength_9, _S1476, is_inside_7, _S1588, surface_13.random_state, &_S1591);
                    float3  _S1593 = pathColor(throughput_6 * _S1592.color, spectral_weight_0, wavelength_9);
                    return Shift_x24init_0(_S1593, 1.0f);
                }
                if(_S1587)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1451;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1594 = rgb_to_greyscale(light_3.radiance);
                    bool _S1595 = !(_S1594 > 0.0f);
                    if(_S1595)
                    {
                        return _S1264;
                    }
                    float3  _S1596 = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_9);
                    return Shift_x24init_0(_S1596, 1.0f);
                }
                if(_S1278)
                {
                    passes_0 = _S1269 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1414;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1597 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_9);
                    return Shift_x24init_0(_S1597, 1.0f);
                }
                if(_S1278)
                {
                    passes_0 = _S1269 == 1U;
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
                    passes_0 = !_S1451;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1598 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_9);
                    return Shift_x24init_0(_S1598, 1.0f);
                }
                return _S1264;
            }
            else
            {
                if(_S1490)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1599 = b_6 > 0U;
                    if(_S1599)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1505)
                        {
                            float3  _S1600 = safeDivide(throughput_6 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1600;
                        }
                        else
                        {
                            if(_S1451)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1601 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_9);
                        Reservoir _S1602 = withEnd(candidate_5, 1U, b_6, _S1601);
                        offer(sel_7, _S1602, _S1601 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1603 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_9);
                        float3  _S1604 = sel_7->glow + _S1603;
                        sel_7->glow = _S1604;
                    }
                    if(nee_0)
                    {
                        float3  _S1605 = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_9);
                        Reservoir candidate_6 = chain_0;
                        if(_S1505)
                        {
                            float3  _S1606 = safeDivide(_S1605, chain_throughput_0);
                            (&candidate_6)->radiance = _S1606;
                        }
                        else
                        {
                            if(_S1451)
                            {
                                candidate_6 = here_0;
                                uint _S1607 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1607;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1608 = insertBits_0(_S1293, b_6 + 1U, 5U, 5U);
                                uint _S1609 = insertBits_0(_S1608, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1609;
                            }
                        }
                        Reservoir _S1610 = withEnd(candidate_6, 0U, b_6, _S1605);
                        offer(sel_7, _S1610, _S1605 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1481)
                        {
                            _S1564 = false;
                        }
                        else
                        {
                            bool _S1611 = environmentMapped_0();
                            _S1564 = _S1611;
                        }
                    }
                    else
                    {
                        _S1564 = false;
                    }
                    if(_S1564)
                    {
                        uint _S1612 = (fcptMaxBounces());
                        _S1565 = b_6 < _S1612;
                    }
                    else
                    {
                        _S1565 = false;
                    }
                    if(_S1565)
                    {
                        uint _S1613 = stream(_S1291, b_6 + 448U);
                        FKRay _S1614 = ray_2;
                        FKSurface _S1615 = surface_13;
                        ShadowContext _S1616 = context_5;
                        SkySample _S1617 = sampleSky_0(&_S1614, &_S1615, wavelength_9, _S1476, is_inside_7, _S1613, surface_13.random_state, &_S1616);
                        float3  _S1618 = pathColor(throughput_6 * _S1617.color, spectral_weight_0, wavelength_9);
                        Reservoir candidate_7 = chain_0;
                        if(_S1505)
                        {
                            float3  _S1619 = safeDivide(_S1618, chain_throughput_0);
                            (&candidate_7)->radiance = _S1619;
                        }
                        else
                        {
                            if(_S1451)
                            {
                                candidate_7 = here_0;
                                uint _S1620 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1620;
                                (&candidate_7)->dir = _S1617.dir;
                                (&candidate_7)->radiance = _S1617.radiance;
                            }
                            else
                            {
                                uint _S1621 = insertBits_0(_S1293, b_6 + 1U, 5U, 5U);
                                uint _S1622 = insertBits_0(_S1621, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1622;
                            }
                        }
                        Reservoir _S1623 = withEnd(candidate_7, 4U, b_6, _S1618);
                        offer(sel_7, _S1623, _S1618 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_7 = throughput_6;
            density_4 = density_2;
        }
        bool _S1624;
        bool _S1625;
        bool _S1626;
        bool straight_0;
        bool _S1627;
        bool _S1628;
        bool _S1629;
        bool _S1630;
        bool _S1631;
        bool _S1632;
        bool _S1633;
        bool _S1634;
        bool _S1635;
        bool _S1636;
        bool _S1637;
        bool _S1638;
        bool _S1639;
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
                viewed_1 = _S1519;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1640 = extractBits_0(_S1265, 15U, 3U);
            uint _S1641 = extractBits_0(_S1265, 18U, 3U);
            uint _S1642 = _slang_select(_S1518, _S1641,_S1640);
            float3  _S1643 = r_8->dir;
            bool refracted_5 = _S1642 == 1U;
            SampleBSDF _S1644 = SampleBSDF_x24init_0(_S1263, _S1263, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1644;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1645 = extractBits_0(_S1265, 22U, 1U);
                bool _S1646 = is_inside_7 != (_S1645 == 1U);
                if(_S1646)
                {
                    return _S1264;
                }
                bool _S1647 = _S1268 == 1U;
                if(_S1647)
                {
                    float3  _S1648 = (fcptHitPosition((_S1280)));
                    throughput_9 = _S1648;
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
                    BSDFMaterial _S1649 = _S1475;
                    bool _S1650 = isTranslucent_0(&_S1649);
                    if(_S1650)
                    {
                        refracted_4 = _S1642 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1651 = throughput_9 - (&ray_2)->origin;
                        float3  _S1652 = _slang_select(_S1647, _S1651,_S1643);
                        wrong_side_0 = (dot_0(_S1452.smooth_n, _S1652) * _S1453) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1647)
                {
                    float3  _S1653 = (&ray_2)->origin;
                    FKSurface _S1654 = surface_13;
                    float3  _S1655 = - _S1452.smooth_n;
                    bool _S1656 = is_inside_7 != refracted_4;
                    float3  _S1657 = _slang_select(_S1656, _S1655,_S1452.smooth_n);
                    float3  _S1658 = throughput_9 - (_S1653 + make_float3 (_S1654.geometry_offset) * _S1657);
                    float3  _S1659 = ((((_S1658)) * make_float3(rnorm3df(((_S1658)).x, ((_S1658)).y, ((_S1658)).z))));
                    reconnection_1 = _S1659;
                }
                else
                {
                    reconnection_1 = _S1643;
                }
                if(_S1481)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1660 = wrongSide_0(is_inside_7, refracted_4, reconnection_1, surface_13.geometry_n);
                    wrong_side_0 = _S1660;
                }
                if(wrong_side_0)
                {
                    return _S1264;
                }
                float3  _S1661 = throughput_9;
                throughput_9 = reconnection_1;
                b_9 = _S1642;
                wrong_side_0 = false;
                reconnection_1 = _S1661;
            }
            else
            {
                bool _S1662 = !_S1518;
                if(_S1662)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1663;
                    if(_S1481)
                    {
                        SampleBSDF _S1664 = (fcptSampleHair((surface_13.hair), (_S1475.albedo), (_S1475.specular_tint), ((&ray_2)->unit_direction), (surface_13.random_state)));
                        _S1663 = _S1664;
                    }
                    else
                    {
                        SampleBSDF _S1665 = sampleBSDF((&ray_2)->unit_direction, _S1452.smooth_n, _S1475, _S1476.x, _S1476.y, surface_13.random_state, _S1535);
                        _S1663 = _S1665;
                    }
                    bsdf_sampled_0 = _S1663;
                    if(_S1481)
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
                            return _S1264;
                        }
                        break;
                    }
                    if(_S1481)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1666 = wrongSide_0(is_inside_7, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_13.geometry_n);
                        wrong_side_0 = _S1666;
                    }
                    if(wrong_side_0)
                    {
                        _S1564 = (_S1475.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1564 = false;
                    }
                    if(_S1564)
                    {
                        SampleBSDF _S1667 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_13.geometry_n, _S1475, _S1476.x, _S1476.y, (&bsdf_sampled_0)->random_state, _S1535);
                        (&bsdf_sampled_0)->unit_direction = _S1667.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1667.refracted;
                        (&bsdf_sampled_0)->throughput = _S1667.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1668 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_13.geometry_n)) * surface_13.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1668;
                        }
                    }
                    uint _S1669 = (&bsdf_sampled_0)->lobe;
                    float3  _S1670 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1671 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1672 = (&bsdf_sampled_0)->pdf;
                    float _S1673 = _slang_select(wrong_side_0, 0.0f,_S1672);
                    (&lobe_5)->pdf = _S1673;
                    throughput_9 = _S1670;
                    b_9 = _S1669;
                    refracted_4 = _S1671;
                }
                else
                {
                    throughput_9 = _S1643;
                    b_9 = _S1642;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1564 = true;
            }
            else
            {
                _S1564 = _S1518;
            }
            float3  chain_throughput_1;
            if(_S1564)
            {
                if(_S1481)
                {
                    SampleBSDF _S1674 = (fcptConnectHair((surface_13.hair), (_S1475.albedo), (_S1475.specular_tint), ((&ray_2)->unit_direction), (throughput_9)));
                    lobe_5 = _S1674;
                }
                else
                {
                    float3  _S1675 = (&ray_2)->unit_direction;
                    float3  _S1676 = negate_0(_S1675);
                    float _S1677 = sign_0(_S1453);
                    float3  _S1678 = _S1452.smooth_n * make_float3 (_S1677);
                    float _S1679 = dot_0(_S1678, throughput_9);
                    float _S1680 = _S1475.roughness;
                    float _S1681 = _S1680 * _S1680;
                    AnisotropicFrame _S1682 = anisotropicFrame(_S1475, _S1678);
                    SheenProfile _S1683 = sheenProfile(_S1676, _S1678, _S1475);
                    float3  _S1684 = reflectedHalf(_S1675, throughput_9);
                    bool _S1685 = b_9 == 1U;
                    if(_S1685)
                    {
                        float3  _S1686 = refractedHalf(_S1675, throughput_9, _S1452.smooth_n, _S1476.x, _S1476.y);
                        throughput_10 = _S1686;
                    }
                    else
                    {
                        throughput_10 = _S1684;
                    }
                    bool _S1687 = b_9 == 0U;
                    if(_S1687)
                    {
                        _S1565 = true;
                    }
                    else
                    {
                        _S1565 = b_9 == 6U;
                    }
                    if(_S1565)
                    {
                        float3  _S1688 = sampledHalf(_S1676, _S1678, _S1681, _S1682, surface_13.random_state);
                        throughput_11 = _S1688;
                    }
                    else
                    {
                        throughput_11 = throughput_10;
                    }
                    float _S1689 = _S1476.x;
                    float _S1690 = _S1476.y;
                    Weights _S1691 = lobeWeights(_S1675, _S1676, _S1678, throughput_11, _S1682, _S1683, _S1475, _S1689, _S1690);
                    float _S1692 = (F32_abs((_S1453)));
                    float _S1693 = vndfPDF(_S1676, throughput_11, _S1678, _S1692, _S1681, _S1682, _S1691.v_dot_h);
                    switch(b_9)
                    {
                    case 0U:
                        {
                            float _S1694 = diffusePDF(_S1679, _S1692, _S1475, _S1691);
                            float3  _S1695 = diffuseBSDF(throughput_9, _S1678, _S1475, _S1691);
                            density_6 = _S1694;
                            chain_throughput_1 = _S1695;
                            break;
                        }
                    case 1U:
                        {
                            float _S1696 = refractPDF(dot_0(throughput_9, throughput_11), _S1693, _S1691, _S1689, _S1690);
                            float3  _S1697 = refractBSDF(throughput_9, _S1678, _S1681, _S1682, _S1475, _S1691);
                            density_6 = _S1696;
                            chain_throughput_1 = _S1697;
                            break;
                        }
                    case 4U:
                        {
                            float _S1698 = sheenVelvetPDF(_S1679, _S1692, _S1691);
                            float3  _S1699 = sheenVelvetBSDF(throughput_9, _S1676, _S1678, _S1475, _S1691);
                            density_6 = _S1698;
                            chain_throughput_1 = _S1699;
                            break;
                        }
                    case 6U:
                        {
                            ToonProfile _S1700 = toonProfile(_S1676, _S1678, _S1475);
                            float _S1701 = toonPDF(throughput_9, _S1678, _S1700, _S1691);
                            float3  _S1702 = toonBSDF(throughput_9, _S1678, _S1700, _S1691);
                            density_6 = _S1701;
                            chain_throughput_1 = _S1702;
                            break;
                        }
                    default:
                        {
                            float _S1703 = reflectPDF(_S1693, _S1691);
                            float3  _S1704 = reflectBSDF(throughput_9, _S1678, _S1681, _S1682, _S1691);
                            density_6 = _S1703;
                            chain_throughput_1 = _S1704;
                            break;
                        }
                    }
                    bool _S1705 = density_6 > 0.0f;
                    if(_S1705)
                    {
                        SampleBSDF _S1706 = SampleBSDF_x24init_0(throughput_9, chain_throughput_1, surface_13.random_state, _S1685, b_9, density_6);
                        lobe_5 = _S1706;
                    }
                }
            }
            bool _S1707 = b_9 == 0U;
            if(_S1707)
            {
                _S1565 = true;
            }
            else
            {
                _S1565 = b_9 == 4U;
            }
            if(_S1565)
            {
                _S1624 = true;
            }
            else
            {
                _S1624 = b_9 == 6U;
            }
            if(_S1481)
            {
                _S1625 = false;
            }
            else
            {
                bool _S1708 = !_S1624;
                if(_S1708)
                {
                    bool _S1709 = (_S1475.roughness) == 0.0f;
                    if(_S1709)
                    {
                        _S1625 = true;
                    }
                    else
                    {
                        bool _S1710 = b_9 == 1U;
                        if(_S1710)
                        {
                            _S1625 = (_S1476.x) == (_S1476.y);
                        }
                        else
                        {
                            _S1625 = false;
                        }
                    }
                }
                else
                {
                    _S1625 = false;
                }
            }
            bool _S1711 = !_S1481;
            if(_S1711)
            {
                _S1626 = b_9 == 1U;
            }
            else
            {
                _S1626 = false;
            }
            if(_S1626)
            {
                straight_0 = (_S1475.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1627 = _S1711;
            }
            else
            {
                _S1627 = false;
            }
            if(_S1627)
            {
                _S1628 = b_9 == 1U;
            }
            else
            {
                _S1628 = false;
            }
            if(_S1628)
            {
                _S1629 = (_S1476.x) == (_S1476.y);
            }
            else
            {
                _S1629 = false;
            }
            BSDFMaterial _S1712 = _S1475;
            bool _S1713 = isTranslucent_0(&_S1712);
            if(_S1713)
            {
                _S1630 = _S1707;
            }
            else
            {
                _S1630 = false;
            }
            if(_S1630)
            {
                _S1631 = (dot_0(throughput_9, surface_13.geometry_n)) < 0.0f;
            }
            else
            {
                _S1631 = false;
            }
            if(nee_0)
            {
                _S1632 = !_S1625;
            }
            else
            {
                _S1632 = false;
            }
            if(_S1632)
            {
                _S1633 = !wrong_side_0;
            }
            else
            {
                _S1633 = false;
            }
            if(_S1633)
            {
                float _S1714 = (&lobe_5)->pdf;
                float3  _S1715 = (&ray_2)->origin;
                float3  _S1716 = _slang_select(_S1486, _S1263,_S1452.smooth_n);
                float3  _S1717 = (&ray_2)->origin;
                FKSurface _S1718 = surface_13;
                float3  _S1719 = - _S1452.smooth_n;
                float3  _S1720 = _slang_select(_S1631, _S1719,_S1452.smooth_n);
                NEEVertex _S1721 = NEEVertex_x24init_0(false, _S1714, _S1715, _S1716, _S1717 + make_float3 (_S1718.geometry_offset) * _S1720);
                nee_vertex_0 = _S1721;
            }
            else
            {
                if(_S1481)
                {
                    _S1634 = true;
                }
                else
                {
                    bool _S1722 = b_9 != 1U;
                    if(_S1722)
                    {
                        _S1634 = true;
                    }
                    else
                    {
                        _S1634 = (_S1476.x) != (_S1476.y);
                    }
                }
                if(_S1634)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1723 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1723)
            {
                if(_S1624)
                {
                    _S1634 = true;
                }
                else
                {
                    _S1634 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1634 = false;
            }
            bool _S1724 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1724)
            {
                if(_S1624)
                {
                    _S1635 = true;
                }
                else
                {
                    _S1635 = (_S1475.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1635 = false;
            }
            if(_S1518)
            {
                bool _S1725 = !_S1634;
                if(_S1725)
                {
                    return _S1264;
                }
                bool _S1726 = _S1269 != 1U;
                if(_S1726)
                {
                    _S1636 = _S1269 != 2U;
                }
                else
                {
                    _S1636 = false;
                }
                if(_S1636)
                {
                    float _S1727 = (&lobe_5)->pdf;
                    float _S1728 = _slang_select(nee_0, _S1727,0.0f);
                    float _S1729 = escapeWeight_0(_S1728, _S1643);
                    if(_S1526)
                    {
                        passes_0 = _S1275;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1730 = _slang_select(passes_0, _S1729,1.0f);
                    return Shift_x24init_0(throughput_7 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1730) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1731 = throughput_7 * make_float3 ((&lobe_5)->pdf);
                float _S1732 = density_4 * (&lobe_5)->pdf;
                throughput_10 = _S1731;
                density_6 = _S1732;
            }
            else
            {
                throughput_10 = throughput_7;
                density_6 = density_4;
            }
            uint _S1733 = (fcptLayers((hit_4)));
            bool _S1734 = _S1733 > 1U;
            if(_S1734)
            {
                _S1636 = (b_9 == 1U) != passes_0;
            }
            else
            {
                _S1636 = false;
            }
            if(viewed_1)
            {
                _S1637 = _S1636;
            }
            else
            {
                _S1637 = false;
            }
            if(_S1637)
            {
                return _S1264;
            }
            if(replay_1)
            {
                _S1638 = b_6 <= _S1279;
            }
            else
            {
                _S1638 = false;
            }
            if(_S1638)
            {
                _S1639 = _S1451;
            }
            else
            {
                _S1639 = false;
            }
            bool _S1735;
            if(_S1639)
            {
                _S1735 = _S1634;
            }
            else
            {
                _S1735 = false;
            }
            bool _S1736;
            if(_S1735)
            {
                _S1736 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1736 = !_S1635;
                }
                else
                {
                    _S1736 = false;
                }
            }
            if(_S1736)
            {
                return _S1264;
            }
            if(viewed_1)
            {
                float3  _S1737 = throughput_10 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1738 = (&lobe_5)->pdf;
                throughput_11 = _S1737;
                sky_pdf_2 = _S1738;
            }
            else
            {
                float3  _S1739 = throughput_10 * max_0((&lobe_5)->throughput, _S1263);
                throughput_11 = _S1739;
                sky_pdf_2 = density_6;
            }
            bool _S1740;
            if(_S1490)
            {
                _S1740 = !_S1505;
            }
            else
            {
                _S1740 = false;
            }
            bool _S1741;
            if(_S1740)
            {
                _S1741 = _S1451;
            }
            else
            {
                _S1741 = false;
            }
            bool _S1742;
            if(_S1741)
            {
                _S1742 = _S1634;
            }
            else
            {
                _S1742 = false;
            }
            if(_S1742)
            {
                chain_0 = here_0;
                uint _S1743 = insertBits_0((&chain_0)->path, b_9, 18U, 3U);
                uint _S1744 = _slang_select(nee_0, 1U,0U);
                uint _S1745 = insertBits_0(_S1743, _S1744, 21U, 1U);
                (&chain_0)->path = _S1745;
                float _S1746 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1746;
                (&chain_0)->dir = throughput_9;
                chain_throughput_1 = throughput_11;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1747 = surface_13;
            Vertex _S1748 = Vertex_x24init_0(_S1635, b_9, (&lobe_5)->pdf, (F32_abs((dot_0(surface_13.geometry_n, throughput_9)))), is_inside_7);
            prev_0 = _S1748;
            float _S1749 = (&lobe_5)->pdf;
            bool _S1750 = b_9 == 1U;
            bool _S1751;
            if(_S1750)
            {
                _S1751 = (_S1476.x) == (_S1476.y);
            }
            else
            {
                _S1751 = false;
            }
            float sky_pdf_3 = _slang_select(_S1751, sky_pdf_0,_S1749);
            float _S1752 = _slang_select(_S1481, 0.0f,sky_pdf_3);
            float _S1753 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1754 = !_S1625;
            float _S1755 = _slang_select(_S1754, _S1753,0.0f);
            float _S1756 = spread_1 + _S1755;
            bool _S1757;
            if(refracted_4)
            {
                _S1757 = !_S1631;
            }
            else
            {
                _S1757 = false;
            }
            bool is_inside_8;
            if(_S1757)
            {
                bool _S1758 = !is_inside_7;
                is_inside_8 = _S1758;
            }
            else
            {
                is_inside_8 = is_inside_7;
            }
            FKSurface _S1759 = surface_13;
            bool _S1760 = boundsVolume_0(&_S1759);
            bool _S1761;
            if(_S1760)
            {
                _S1761 = !_S1636;
            }
            else
            {
                _S1761 = false;
            }
            if(_S1761)
            {
                FKSurface faced_2 = surface_13;
                float3  _S1762 = - _S1747.geometry_n;
                float3  _S1763 = _slang_select(turned_1, _S1762,_S1747.geometry_n);
                (&faced_2)->geometry_n = _S1763;
                FKMedium _S1764 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1765 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1766 = faced_2;
                FKMedium _S1767 = _S1764;
                FKMedium _S1768 = _S1765;
                MediumSides _S1769 = mediumSides_0(&_S1766, &_S1767, filling_2, (&ray_2)->unit_direction, &_S1768);
                bool _S1770 = ((dot_0(throughput_9, _S1747.geometry_n)) > 0.0f) == ((dot_0(_S1747.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1771 = _slang_select(_S1770, _S1769.front.scatter,_S1769.behind.scatter);
                scatter_in_0 = _S1771;
                float3  _S1772 = scatter_in_0;
                float _S1773 = upsample(scatter_in_0, wavelength_9);
                float3  _S1774 = make_float3 (_S1773);
                float3  _S1775 = _slang_select(_S1513, _S1774,_S1772);
                scatter_in_0 = _S1775;
                float3  _S1776 = _slang_select(_S1770, _S1769.front.extinction,_S1769.behind.extinction);
                extinction_in_0 = _S1776;
                float3  _S1777 = extinction_in_0;
                float _S1778 = upsample(extinction_in_0, wavelength_9);
                float3  _S1779 = make_float3 (_S1778);
                float3  _S1780 = _slang_select(_S1513, _S1779,_S1777);
                extinction_in_0 = _S1780;
                float _S1781 = _slang_select(_S1770, _S1769.front.g,_S1769.behind.g);
                g_in_0 = _S1781;
                uint _S1782 = _S1769.fillings.x;
                uint _S1783 = _S1769.fillings.y;
                uint _S1784 = _slang_select(_S1770, _S1783,_S1782);
                bool _S1785 = (fcptVaryingUsed());
                uint _S1786 = _slang_select(_S1785, _S1784,4294967295U);
                filling_2 = _S1786;
            }
            (&ray_2)->unit_direction = throughput_9;
            bool _S1787 = !_S1636;
            if(_S1787)
            {
                FKSurface _S1788 = surface_13;
                float _S1789 = _slang_select(straight_0, 0.0f,_S1788.geometry_offset);
                float3  _S1790 = - _S1452.smooth_n;
                bool _S1791 = is_inside_8 != _S1631;
                float3  _S1792 = _slang_select(_S1791, _S1790,_S1452.smooth_n);
                float3  _S1793 = (&ray_2)->origin + make_float3 (_S1789) * _S1792;
                (&ray_2)->origin = _S1793;
            }
            throughput_10 = throughput_11;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1636;
            viewed_1 = _S1629;
            sky_pdf_2 = _S1752;
            spread_4 = _S1756;
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
            spread_4 = spread_1;
            straight_0 = false;
            is_inside_6 = is_inside_7;
        }
        float density_7;
        if(_S1490)
        {
            if(_S1414)
            {
                float3  _S1794 = pathColor(throughput_10 * emission_1, spectral_weight_0, wavelength_9);
                Reservoir candidate_8 = chain_0;
                uint _S1795 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1796 = _S1795 == 1U;
                if(_S1796)
                {
                    float3  _S1797 = safeDivide(_S1794, chain_throughput_0);
                    (&candidate_8)->radiance = _S1797;
                }
                Reservoir _S1798 = withEnd(candidate_8, 2U, b_6, _S1794);
                offer(sel_7, _S1798, _S1794 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1414)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1799 = survivalProbability(abs_0(throughput_10), density_6);
                density_7 = _S1799;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1800 = stream(_S1291, b_6 + 128U);
            Random _S1801 = pcg(_S1800);
            bool _S1802 = density_7 < (_S1801.value);
            if(_S1802)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1803 = (fcptMaxBounces());
                wrong_side_0 = b_6 >= _S1803;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1804 = density_6 * density_7;
            density_7 = _S1804;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1805 = layer_0 ^ 1U;
        uint _S1806 = _slang_select(passes_0, _S1805,0U);
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
            uint _S1807 = b_9 + 1U;
            b_6 = _S1807;
            layer_0 = _S1806;
            continue;
        }
        FKRay _S1808 = ray_2;
        float _S1809 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S1519;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1268 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1810 = _slang_select(wrong_side_0, _S1809,4.294967296e+09f);
        bool _S1811 = !_S1481;
        if(straight_0)
        {
            _S1564 = true;
        }
        else
        {
            _S1564 = _S1481;
        }
        FKHit _S1812;
        if(_S1564)
        {
            _S1812 = hit_4;
        }
        else
        {
            _S1812 = _S1536;
        }
        FKHit _S1813 = (fcptTraverseInstanceBVH((_S1808), (_S1421), (_S1810), (_S1811), (_S1812), (viewed_1)));
        hit_4 = _S1813;
        if(replay_1)
        {
            _S1565 = _S1519;
        }
        else
        {
            _S1565 = false;
        }
        if(_S1565)
        {
            _S1624 = _S1268 == 1U;
        }
        else
        {
            _S1624 = false;
        }
        if(_S1624)
        {
            _S1625 = ((&hit_4)->instance_index) == (_S1280.instance_index);
        }
        else
        {
            _S1625 = false;
        }
        if(_S1625)
        {
            _S1626 = ((&hit_4)->triangle_index) == (_S1280.triangle_index);
        }
        else
        {
            _S1626 = false;
        }
        if(_S1626)
        {
            (&hit_4)->uv = _S1280.uv;
            float _S1814 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1814;
        }
        if(replay_1)
        {
            _S1627 = _S1519;
        }
        else
        {
            _S1627 = false;
        }
        if(_S1627)
        {
            _S1628 = _S1268 == 3U;
        }
        else
        {
            _S1628 = false;
        }
        if(_S1628)
        {
            _S1629 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1629 = false;
        }
        if(_S1629)
        {
            return _S1264;
        }
        Reservoir _S1815 = chain_0;
        uint _S1816 = filling_2;
        for(;;)
        {
            bool _S1817 = (fcptVaryingUsed());
            if(_S1817)
            {
                _S1630 = _S1816 != 4294967295U;
            }
            else
            {
                _S1630 = false;
            }
            float _S1818;
            if(_S1630)
            {
                float _S1819 = (fcptMajorant((_S1816)));
                _S1818 = _S1819;
            }
            else
            {
                _S1818 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1631 = _S1519;
            }
            else
            {
                _S1631 = false;
            }
            if(_S1631)
            {
                _S1632 = _S1268 == 1U;
            }
            else
            {
                _S1632 = false;
            }
            if(_S1632)
            {
                _S1633 = _S1818 > 0.0f;
            }
            else
            {
                _S1633 = false;
            }
            if(_S1633)
            {
                ended_0 = _S1264;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_4 = width_3;
                density_3 = density_7;
                throughput_11 = throughput_10;
                b_9 = b_6;
                _S1634 = true;
                break;
            }
            bool _S1820 = (&prev_0)->rough;
            if(_S1820)
            {
                _S1634 = !(_S1818 > 0.0f);
            }
            else
            {
                _S1634 = false;
            }
            (&prev_0)->rough = _S1634;
            uint _S1821 = b_6 + 320U;
            bool _S1822 = b_6 == 4294967295U;
            uint _S1823 = _slang_select(_S1822, 384U,_S1821);
            uint _S1824 = stream(_S1291, _S1823);
            uint tracking_1 = _S1824;
            weight_2 = throughput_3;
            glowed_0 = _S1263;
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
                    _S1262 = int(2);
                    break;
                }
                uint _S1825 = b_9 + 320U;
                bool _S1826 = b_9 == 4294967295U;
                uint _S1827 = _slang_select(_S1826, 384U,_S1825);
                uint _S1828 = stream(_S1291, _S1827);
                Random _S1829 = pcg(_S1828);
                float _S1830 = - (F32_log((1.0f - _S1829.value))) / _S1818;
                if(_S1630)
                {
                    float3  _S1831 = (&ray_2)->origin;
                    float3  _S1832 = (&ray_2)->unit_direction;
                    float _S1833 = (&hit_4)->distance;
                    uint _S1834 = _slang_select(_S1826, 0U,b_9);
                    uint _S1835 = (&prev_0)->lobe;
                    uint _S1836 = _slang_select(_S1826, 3U,_S1835);
                    float _S1837 = (fcptTrackMedium((_S1816), (_S1831), (_S1832), (_S1833), (&tracking_1), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1834), (_S1836), (_S1826)));
                    spread_3 = _S1837;
                }
                else
                {
                    spread_3 = _S1830;
                }
                bool _S1838 = !(spread_3 < ((&hit_4)->distance));
                if(_S1838)
                {
                    _S1262 = int(2);
                    break;
                }
                if(_S1630)
                {
                    _S1635 = _S1490;
                }
                else
                {
                    _S1635 = false;
                }
                if(_S1635)
                {
                    float3  _S1839 = pathColor(throughput_11 * glowed_0, spectral_weight_0, wavelength_9);
                    float3  _S1840 = _S1839 / make_float3 (density_3);
                    float3  _S1841 = sel_7->glow + _S1840;
                    sel_7->glow = _S1841;
                }
                else
                {
                }
                glowed_0 = _S1263;
                uint b_10 = b_9 + 1U;
                float3  _S1842 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1842;
                float3  _S1843 = flightWeight_0(scatter_in_0, extinction_in_0, _S1818, spread_3, true);
                float3  _S1844 = weight_2;
                float _S1845 = upsample(weight_2, wavelength_9);
                float3  _S1846 = make_float3 (_S1845);
                float3  _S1847 = _slang_select(_S1513, _S1846,_S1844);
                float3  _S1848 = _slang_select(_S1630, _S1847,_S1843);
                float3  throughput_12 = throughput_11 * _S1848;
                uint _S1849 = stream(_S1291, b_10 + 320U);
                tracking_1 = _S1849;
                weight_2 = throughput_3;
                float width_7 = width_4 + spread_2 * spread_3;
                float _S1850 = spread_2 + 3.14159274101257324f;
                if(_S1490)
                {
                    _S1636 = true;
                }
                else
                {
                    bool _S1851 = b_10 == _S1279;
                    if(_S1851)
                    {
                        _S1636 = !_S1630;
                    }
                    else
                    {
                        _S1636 = false;
                    }
                }
                TreeSample light_4;
                if(_S1636)
                {
                    float3  _S1852 = (&ray_2)->origin;
                    float3  _S1853 = (&ray_2)->unit_direction;
                    float3  _S1854 = (&ray_2)->unit_direction;
                    uint _S1855 = stream(_S1291, b_10 + 64U);
                    float3  _S1856 = extinction_in_0;
                    float3  _S1857 = extinction_in_0;
                    uint2  _S1858 = make_uint2 (_S1816);
                    float3  _S1859 = (&ray_2)->unit_direction;
                    uint _S1860 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                    FKHit _S1861 = _S1536;
                    ShadowContext _S1862 = ShadowContext_x24init_0(_S1856, _S1857, _S1858, _S1859, b_10, _S1860, false, spread_3, width_7, &_S1861, false);
                    ShadowContext _S1863 = _S1862;
                    TreeSample _S1864 = sampleLightTree_0(_S1852, _S1853, _S1854, 0.0f, true, _S1855, &_S1863);
                    light_4 = _S1864;
                }
                else
                {
                    light_4 = _S1533;
                }
                float _S1865 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1866 = (fcptMaxBounces());
                bool _S1867 = b_10 < _S1866;
                if(_S1867)
                {
                    _S1637 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1637 = false;
                }
                float _S1868 = _slang_select(_S1637, _S1865,0.0f);
                float3  _S1869 = throughput_12 * light_4.radiance;
                float _S1870 = powerHeuristic(light_4.density, _S1868);
                float3  _S1871 = pathColor(_S1869 * make_float3 (_S1865 * _S1870), spectral_weight_0, wavelength_9);
                float3  _S1872 = _slang_select(_S1636, _S1871,_S1263);
                if(replay_1)
                {
                    _S1638 = b_10 == _S1279;
                }
                else
                {
                    _S1638 = false;
                }
                if(_S1638)
                {
                    bool _S1873 = _S1268 == 2U;
                    if(_S1873)
                    {
                        float _S1874 = resamplingTarget(_S1872);
                        _S1639 = _S1874 > 0.0f;
                    }
                    else
                    {
                        _S1639 = false;
                    }
                    if(_S1639)
                    {
                        Shift _S1875 = Shift_x24init_0(_S1872, 1.0f);
                        _S1262 = int(1);
                        ended_0 = _S1875;
                        spread_3 = _S1850;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_7 = b_10;
                        break;
                    }
                    _S1262 = int(1);
                    ended_0 = _S1264;
                    spread_3 = _S1850;
                    width_5 = width_7;
                    throughput_9 = throughput_12;
                    b_7 = b_10;
                    break;
                }
                if(_S1490)
                {
                    Reservoir candidate_9 = _S1815;
                    uint _S1876 = extractBits_0(_S1815.path, 24U, 8U);
                    uint _S1877 = insertBits_0(0U, _S1876, 24U, 8U);
                    uint _S1878 = extractBits_0(_S1815.path, 10U, 2U);
                    bool _S1879 = _S1878 == 1U;
                    if(_S1879)
                    {
                        float3  _S1880 = safeDivide(_S1872, chain_throughput_0);
                        (&candidate_9)->radiance = _S1880;
                    }
                    else
                    {
                        uint _S1881 = insertBits_0(_S1877, b_10 + 1U, 5U, 5U);
                        uint _S1882 = insertBits_0(_S1881, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1882;
                    }
                    Reservoir _S1883 = withEnd(candidate_9, 0U, b_10, _S1872);
                    offer(sel_7, _S1883, _S1872 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1884 = survivalProbability(abs_0(throughput_12), density_3);
                    uint _S1885 = stream(_S1291, b_10 + 128U);
                    Random _S1886 = pcg(_S1885);
                    bool _S1887 = _S1884 < (_S1886.value);
                    if(_S1887)
                    {
                        _S1639 = true;
                    }
                    else
                    {
                        uint _S1888 = (fcptMaxBounces());
                        _S1639 = b_10 >= _S1888;
                    }
                    if(_S1639)
                    {
                        _S1262 = int(1);
                        ended_0 = _S1264;
                        spread_3 = _S1850;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_7 = b_10;
                        break;
                    }
                    float _S1889 = density_3 * _S1884;
                    density_3 = _S1889;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1890 = stream(_S1291, b_10);
                float3  _S1891 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1890, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1891;
                NEEVertex _S1892 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1263, (&ray_2)->origin);
                nee_vertex_0 = _S1892;
                Vertex _S1893 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_6);
                prev_0 = _S1893;
                float _S1894 = (&prev_0)->pdf;
                FKRay _S1895 = ray_2;
                FKHit _S1896 = (fcptTraverseInstanceBVH((_S1895), (true), (4.294967296e+09f), (false), (_S1536), (false)));
                hit_4 = _S1896;
                b_9 = b_10;
                throughput_11 = throughput_12;
                spread_2 = _S1850;
                width_4 = width_7;
                sky_pdf_1 = _S1894;
            }
            if(_S1262 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_11 = throughput_9;
                b_9 = b_7;
                _S1634 = true;
                break;
            }
            ended_0 = _S1264;
            _S1634 = false;
            break;
        }
        if(_S1634)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1635 = b_9 == b_6;
        }
        else
        {
            _S1635 = false;
        }
        bool _S1897 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1897)
        {
            bool _S1898 = !(&nee_vertex_0)->none;
            float _S1899 = _slang_select(_S1898, sky_pdf_1,0.0f);
            float _S1900 = escapeWeight_0(_S1899, (&ray_2)->unit_direction);
            float3  _S1901 = environment_0((&ray_2)->unit_direction, b_9, (&prev_0)->lobe);
            float3  _S1902 = pathColor(throughput_11 * _S1901, spectral_weight_0, wavelength_9);
            if(replay_1)
            {
                bool _S1903 = b_9 == _S1279;
                if(_S1903)
                {
                    passes_0 = _S1268 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1902 * make_float3 (_S1900) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1278)
                {
                    passes_0 = _S1275;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_9 == _S1266;
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
                    return Shift_x24init_0(_S1902 * make_float3 (_S1900), 1.0f);
                }
                return _S1264;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1904 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1905 = _S1904 == 1U;
            if(_S1905)
            {
                uint _S1906 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1907 = _S1906 == b_9;
                float _S1908 = _slang_select(_S1907, 1.0f,_S1900);
                float3  _S1909 = safeDivide(_S1902 * make_float3 (_S1908), chain_throughput_0);
                (&candidate_10)->radiance = _S1909;
            }
            else
            {
                bool _S1910 = (&prev_0)->rough;
                if(_S1910)
                {
                    uint _S1911 = insertBits_0(_S1293, b_9 + 1U, 5U, 5U);
                    uint _S1912 = insertBits_0(_S1911, 3U, 10U, 2U);
                    uint _S1913 = insertBits_0(_S1912, (&prev_0)->lobe, 15U, 3U);
                    bool _S1914 = (&prev_0)->inside;
                    uint _S1915 = _slang_select(_S1914, 1U,0U);
                    uint _S1916 = insertBits_0(_S1913, _S1915, 22U, 1U);
                    (&candidate_10)->path = _S1916;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1917 = _S1902 * make_float3 (_S1900);
            Reservoir _S1918 = withEnd(candidate_10, 3U, b_9, _S1917);
            offer(sel_7, _S1918, _S1917 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1919 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1919;
        bool _S1920 = (fcptVaryingUsed());
        if(_S1920)
        {
            _S1636 = filling_2 != 4294967295U;
        }
        else
        {
            _S1636 = false;
        }
        if(_S1636)
        {
            if(_S1490)
            {
                float3  _S1921 = pathColor(throughput_11 * glowed_0, spectral_weight_0, wavelength_9);
                float3  _S1922 = _S1921 / make_float3 (density_3);
                float3  _S1923 = sel_7->glow + _S1922;
                sel_7->glow = _S1923;
            }
            float3  _S1924 = throughput_11 * weight_2;
            throughput_9 = _S1924;
        }
        else
        {
            float3  _S1925 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1926 = throughput_11 * _S1925;
            throughput_9 = _S1926;
        }
        float _S1927 = width_4 + spread_2 * (&hit_4)->distance;
        viewed_0 = _S1635;
        width_3 = _S1927;
        throughput_2 = throughput_9;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1807 = b_9 + 1U;
        b_6 = _S1807;
        layer_0 = _S1806;
    }
    return _S1264;
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
    Random _S1928 = pcg(state_3);
    Random _S1929 = pcg(_S1928.state);
    float _S1930 = 6.28318548202514648f * _S1928.value;
    float _S1931 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1929.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1929.state, _S1931 * (F32_cos((_S1930))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1932;
    (&_S1932)->state = state_4;
    (&_S1932)->value = value_2;
    return _S1932;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1933 = normal_distribution(state_5);
    Random _S1934 = normal_distribution(_S1933.state);
    Random _S1935 = normal_distribution(_S1934.state);
    float3  _S1936 = make_float3 (_S1933.value, _S1934.value, _S1935.value);
    float3  _S1937 = ((((_S1936)) * make_float3(rnorm3df(((_S1936)).x, ((_S1936)).y, ((_S1936)).z))));
    return RandomSphere_x24init_0(_S1935.state, _S1937);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_11)
{
    float3  _S1938 = p1_0 - p0_0;
    float3  _S1939 = p2_0 - p0_0;
    float2  _S1940 = uv1_0 - uv0_0;
    float2  _S1941 = uv2_0 - uv0_0;
    float _S1942 = _S1940.x;
    float _S1943 = _S1941.y;
    float _S1944 = _S1940.y;
    float _S1945 = _S1941.x;
    float _S1946 = _S1942 * _S1943 - _S1944 * _S1945;
    float _S1947 = 1.0f / _S1946;
    float3  t_24 = (_S1938 * make_float3 (_S1943) - _S1939 * make_float3 (_S1944)) * make_float3 (_S1947);
    float3  _S1948 = (_S1939 * make_float3 (_S1942) - _S1938 * make_float3 (_S1945)) * make_float3 (_S1947);
    float3  _S1949 = t_24 - n_11 * make_float3 (dot_0(n_11, t_24));
    float3  t_25 = ((((_S1949)) * make_float3(rnorm3df(((_S1949)).x, ((_S1949)).y, ((_S1949)).z))));
    bool _S1950 = (dot_0(cross_0(n_11, t_25), _S1948)) > 0.0f;
    float3  t_26;
    if(_S1950)
    {
        float3  _S1951 = negate_0(t_25);
        t_26 = _S1951;
    }
    else
    {
        t_26 = t_25;
    }
    float3  _S1952 = cross_0(n_11, t_26);
    return makeMatrix<float, 3, 3> (t_26, _S1952, n_11);
}

__device__ float3  tangentToWorldNormalMap(float3  v_10, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_10, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_0)
{
    float3  _S1953 = t1_0 - t0_0;
    float3  _S1954 = t2_2 - t0_0;
    float3  _S1955 = t2_2 - t1_0;
    float _S1956 = (F32_min((length_0(_S1953)), ((F32_min((length_0(_S1954)), (length_0(_S1955)))))));
    float3  _S1957 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1958 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1959 = dot_0(geometry_n_4, _S1958);
    float3  _S1960 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1961 = dot_0(geometry_n_4, _S1960);
    float3  _S1962 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1963 = acos_0(abs_0(make_float3 (_S1959, _S1961, dot_0(geometry_n_4, _S1962))));
    float3  _S1964 = clamp_2(tan_0(_S1963), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1957 * _S1964, uvw_0), 0.0f, _S1956 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_15, float3  n_12, BSDFMaterial material_26)
{
    float3  _S1965 = negate_0(dir_15);
    float _S1966 = sign_0(dot_0(n_12, _S1965));
    float3  _S1967 = n_12 * make_float3 (_S1966);
    AnisotropicFrame _S1968 = anisotropicFrame(material_26, _S1967);
    bool _S1969 = (_S1968.alphas.x) > 0.0f;
    if(_S1969)
    {
        float _S1970 = material_26.transmission * (1.0f - material_26.metallic);
        float3  _S1971 = negate_0(_S1967);
        float3  _S1972 = anisotropicLocal(dir_15, _S1968.tangent, _S1971);
        float _S1973 = anisotropicG1(_S1972, _S1968.alphas);
        return make_float3 (_S1970 * _S1973) * material_26.albedo;
    }
    float _S1974 = material_26.transmission * (1.0f - material_26.metallic);
    float _S1975 = material_26.roughness;
    float _S1976 = smithG1(_S1975 * _S1975, (F32_abs((dot_0(n_12, dir_15)))));
    return make_float3 (_S1974 * _S1976) * material_26.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_27, float3  out_dir_3, uint p_14, float w_19, float alpha_10, uint nt_0)
{
    uint _S1977 = p_14 % 4U;
    float _S1978 = w_19 * HAIR_WIDTHS_0[_S1977];
    float _S1979 = (F32_asin((clamp_1(dot_0(out_dir_3, t_27), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_27), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1977] * alpha_10;
    return ((F32_asinh((_S1979 / _S1978))) / (F32_asinh((3.14159274101257324f / _S1978))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_28, float3  out_dir_4, uint np_0)
{
    float3  _S1980 = worldToTangent(out_dir_4, t_28);
    float3  _S1981 = worldToTangent(in_dir_12, t_28);
    return (F32_frac((((F32_atan2((_S1980.z), (_S1980.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1981.z), (1.17549435082228751e-38f - _S1981.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_29, uint p_15, float row_0, float column_0, float w_20, float alpha_11, uint nt_1, uint np_1)
{
    float3  _S1982 = worldToTangent(in_dir_13, t_29);
    uint _S1983 = p_15 % 4U;
    float _S1984 = w_20 * HAIR_WIDTHS_0[_S1983];
    float _S1985 = (F32_asin((clamp_1(dot_0(in_dir_13, t_29), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1983] * alpha_11 + _S1984 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1984))))));
    float _S1986 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1982.z), (1.17549435082228751e-38f - _S1982.x)));
    float _S1987 = (F32_cos((_S1985)));
    float3  _S1988 = tangentToWorld(make_float3 (_S1987 * (F32_cos((_S1986))), (F32_sin((_S1985))), _S1987 * (F32_sin((_S1986)))), t_29);
    return _S1988;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_13, BSDFMaterial material_27, float coverage_1)
{
    float3  _S1989;
    if((material_27.ior) == 1.0f)
    {
        float3  _S1990 = straightThrough(toward_1, n_13, material_27);
        _S1989 = _S1990;
    }
    else
    {
        _S1989 = make_float3 (0.0f);
    }
    return _S1989 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_8, Reservoir r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    Domain _S1991 = dom_8;
    Reservoir _S1992 = r_9;
    Shift _S1993 = walk_0(&_S1991, &_S1992, replay_2, scale_4, sel_8);
    return _S1993;
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
