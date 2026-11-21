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

struct SkyWorld_0
{
    float3  dir_2;
    uint depth_0;
};

static __device__ float3  SkyWorld_seen_0(SkyWorld_0 * this_0, uint lobe_0)
{
    float3  _S200 = (fcptEnvMapSample((this_0->dir_2), (this_0->depth_0), (lobe_0)));
    return _S200;
}

struct MaterialTerms
{
    float f0;
    float eta_level;
    float translucent_share;
    float toon_scale;
    float toon_component;
    float3  toon;
    float toon_a;
    float toon_s;
    float toon_b;
    bool toon_glossy;
    float toon_norm;
};

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

struct ViewTerms
{
    float3  v;
    float3  n_i;
    AnisotropicFrame frame;
    float3  scale;
    float sheen_component;
    float3  sheen;
    float3  view;
    float3  rebounce;
    float toon_view;
    float3  toon_axis;
};

static __device__ float3  negate_0(float3  x_9)
{
    return - x_9;
}

static __device__ float sign_0(float e_1)
{
    float _S201;
    if(e_1 > 0.0f)
    {
        _S201 = 1.0f;
    }
    else
    {
        if(e_1 < 0.0f)
        {
            _S201 = -1.0f;
        }
        else
        {
            _S201 = 0.0f;
        }
    }
    return _S201;
}

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

struct HalfTerms
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

static __device__ HalfTerms HalfTerms_x24init_0(float v_dot_h_0, float n_dot_h_0, float3  refracted_1, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_0, float3  sheen_0, float p_sheen_velvet_0, float3  view_0, float3  tangent_0, float2  alphas_0, float visible_0, float p_toon_0, float3  toon_0, float toon_a_0, float toon_s_0, float toon_b_0, bool toon_glossy_0, float toon_norm_0, float toon_view_0, float3  toon_axis_0)
{
    HalfTerms _S202;
    (&_S202)->v_dot_h = v_dot_h_0;
    (&_S202)->n_dot_h = n_dot_h_0;
    (&_S202)->refracted = refracted_1;
    (&_S202)->F = F_0;
    (&_S202)->F_greyscale = F_greyscale_0;
    (&_S202)->reflect_weight = reflect_weight_0;
    (&_S202)->diffuse_weight = diffuse_weight_0;
    (&_S202)->refract_weight = refract_weight_0;
    (&_S202)->p_diffuse = p_diffuse_0;
    (&_S202)->p_reflect = p_reflect_0;
    (&_S202)->p_refract = p_refract_0;
    (&_S202)->translucent_share = translucent_share_0;
    (&_S202)->sheen = sheen_0;
    (&_S202)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S202)->view = view_0;
    (&_S202)->tangent = tangent_0;
    (&_S202)->alphas = alphas_0;
    (&_S202)->visible = visible_0;
    (&_S202)->p_toon = p_toon_0;
    (&_S202)->toon = toon_0;
    (&_S202)->toon_a = toon_a_0;
    (&_S202)->toon_s = toon_s_0;
    (&_S202)->toon_b = toon_b_0;
    (&_S202)->toon_glossy = toon_glossy_0;
    (&_S202)->toon_norm = toon_norm_0;
    (&_S202)->toon_view = toon_view_0;
    (&_S202)->toon_axis = toon_axis_0;
    return _S202;
}

struct Random
{
    uint state;
    float value;
};

static __device__ float random_0(uint * state_0)
{
    uint _S203 = hash(*state_0);
    *state_0 = _S203;
    return float((*state_0) >> int(8)) * 5.9604644775390625e-08f;
}

static __device__ Random Random_x24init_0(uint state_1, float value_0)
{
    Random _S204;
    (&_S204)->state = state_1;
    (&_S204)->value = value_0;
    return _S204;
}

__device__ Random pcg(uint state_2)
{
    uint _S205 = state_2;
    float value_1 = random_0(&_S205);
    return Random_x24init_0(_S205, value_1);
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S206 = left_0.y;
    float _S207 = right_0.z;
    float _S208 = left_0.z;
    float _S209 = right_0.y;
    float _S210 = right_0.x;
    float _S211 = left_0.x;
    return make_float3 (_S206 * _S207 - _S208 * _S209, _S208 * _S210 - _S211 * _S207, _S211 * _S209 - _S206 * _S210);
}

__device__ float3  anisotropicLocal(float3  w_0, float3  t_12, float3  n_0)
{
    return make_float3 (dot_0(w_0, t_12), dot_0(w_0, cross_0(n_0, t_12)), dot_0(w_0, n_0));
}

static __device__ float unshared_0(float x_10)
{
    return x_10;
}

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_0, float U1_0, float U2_0)
{
    float3  _S212 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S213 = ((((_S212)) * make_float3(rnorm3df(((_S212)).x, ((_S212)).y, ((_S212)).z))));
    float _S214 = _S213.x;
    float _S215 = _S213.y;
    float _S216 = _S214 * _S214 + _S215 * _S215;
    float3  _S217;
    if(_S216 > 0.0f)
    {
        float3  _S218 = make_float3 (- _S215, _S214, 0.0f);
        float _S219 = (rsqrtf((_S216)));
        _S217 = _S218 * make_float3 (_S219);
    }
    else
    {
        _S217 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S220 = cross_0(_S213, _S217);
    float _S221 = (F32_sqrt((U1_0)));
    float _S222 = 6.28318548202514648f * U2_0;
    float _S223 = _S221 * (F32_cos((_S222)));
    float t2_0 = _S221 * (F32_sin((_S222)));
    float _S224 = 0.5f * (1.0f + _S213.z);
    float t2_1 = (1.0f - _S224) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S223 * _S223)))))) + _S224 * t2_0;
    float3  _S225 = make_float3 (_S223) * _S217 + make_float3 (t2_1) * _S220;
    float _S226 = unshared_0(_S223);
    float _S227 = unshared_0(_S223);
    float3  _S228 = _S225 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S226 * _S227 - t2_1 * t2_1))))))) * _S213;
    float3  _S229 = make_float3 (alpha_0 * _S228.x, alpha_0 * _S228.y, (F32_max((0.0f), (_S228.z))));
    float3  _S230 = ((((_S229)) * make_float3(rnorm3df(((_S229)).x, ((_S229)).y, ((_S229)).z))));
    return _S230;
}

__device__ float3  worldToTangent(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S231 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S231)
    {
        float3  _S232 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S232;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S233 = cross_0(n_1, a_2);
    float3  _S234 = ((((_S233)) * make_float3(rnorm3df(((_S233)).x, ((_S233)).y, ((_S233)).z))));
    float3  _S235 = cross_0(n_1, _S234);
    return make_float3 (dot_0(v_0, _S234), dot_0(v_0, n_1), dot_0(v_0, _S235));
}

__device__ float3  tangentToWorld(float3  v_1, float3  n_2)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S236 = (F32_abs((dot_0(n_2, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S236)
    {
        float3  _S237 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S237;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S238 = cross_0(n_2, a_4);
    float3  _S239 = ((((_S238)) * make_float3(rnorm3df(((_S238)).x, ((_S238)).y, ((_S238)).z))));
    float3  _S240 = cross_0(n_2, _S239);
    return make_float3 (v_1.x) * _S239 + make_float3 (v_1.y) * n_2 + make_float3 (v_1.z) * _S240;
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_2, float3  n_i_0, float alpha_1, AnisotropicFrame frame_0, uint * random_state_1)
{
    Random _S241 = pcg(*random_state_1);
    Random _S242 = pcg(_S241.state);
    *random_state_1 = _S242.state;
    float _S243 = frame_0.alphas.x;
    bool _S244 = _S243 > 0.0f;
    if(_S244)
    {
        float3  _S245 = anisotropicLocal(v_2, frame_0.tangent, n_i_0);
        float _S246 = frame_0.alphas.y;
        float3  _S247 = make_float3 (_S243 * _S245.x, _S246 * _S245.y, _S245.z);
        float3  _S248 = ((((_S247)) * make_float3(rnorm3df(((_S247)).x, ((_S247)).y, ((_S247)).z))));
        float3  _S249 = sampleGGXVNDF(_S248, 1.0f, _S241.value, _S242.value);
        float3  _S250 = make_float3 (_S243 * _S249.x, _S246 * _S249.y, _S249.z);
        float3  _S251 = ((((_S250)) * make_float3(rnorm3df(((_S250)).x, ((_S250)).y, ((_S250)).z))));
        return make_float3 (_S251.x) * frame_0.tangent + make_float3 (_S251.y) * cross_0(n_i_0, frame_0.tangent) + make_float3 (_S251.z) * n_i_0;
    }
    float3  _S252 = worldToTangent(v_2, n_i_0);
    float3  _S253 = sampleGGXVNDF(float3 {_S252.x, _S252.z, _S252.y}, alpha_1, _S241.value, _S242.value);
    float3  _S254 = float3 {_S253.x, _S253.z, _S253.y};
    float3  _S255 = tangentToWorld(_S254, n_i_0);
    return _S255;
}

static __device__ float3  refract_0(float3  i_4, float3  n_3, float eta_0)
{
    float _S256 = dot_0(n_3, i_4);
    float _S257 = 1.0f - eta_0 * eta_0 * (1.0f - _S256 * _S256);
    if(_S257 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_4 - make_float3 (eta_0 * _S256 + (F32_sqrt((_S257)))) * n_3;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S258 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S259 = eta_i_0 / eta_o_0 * _S258;
    bool _S260 = _S259 < 1.0f;
    float kr_0;
    if(_S260)
    {
        float _S261 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S259 * _S259))))));
        float _S262 = eta_o_0 * cos_theta_0;
        float _S263 = eta_i_0 * _S261;
        float _S264 = (_S262 - _S263) / (_S262 + _S263);
        float _S265 = eta_i_0 * cos_theta_0;
        float _S266 = eta_o_0 * _S261;
        float _S267 = (_S265 - _S266) / (_S265 + _S266);
        float _S268 = (_S264 * _S264 + _S267 * _S267) / 2.0f;
        kr_0 = _S268;
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

__device__ float anisotropicG1(float3  w_1, float2  alphas_1)
{
    float _S269 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S269 / (_S269 + length_0(make_float3 (alphas_1.x * w_1.x, alphas_1.y * w_1.y, _S269)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S270 = alphas_2.x;
    float _S271 = h_0.x / _S270;
    float _S272 = alphas_2.y;
    float _S273 = h_0.y / _S272;
    float _S274 = h_0.z;
    float _S275 = _S271 * _S271 + _S273 * _S273 + _S274 * _S274;
    return 1.0f / (F32_max((3.14159274101257324f * _S270 * _S272 * _S275 * _S275), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ HalfTerms precomputeHalf(float3  in_dir_0, float3  ggx_n_0, BSDFMaterial material_0, float eta_i_1, float eta_o_1, MaterialTerms terms_0, ViewTerms view_terms_0)
{
    float _S276 = dot_0(ggx_n_0, view_terms_0.v);
    float _S277 = dot_0(view_terms_0.n_i, ggx_n_0);
    float _S278 = eta_i_1 / eta_o_1;
    float3  _S279 = refract_0(in_dir_0, ggx_n_0, _S278);
    float3  _S280 = ((((_S279)) * make_float3(rnorm3df(((_S279)).x, ((_S279)).y, ((_S279)).z))));
    float _S281 = (F32_abs((_S276)));
    bool _S282 = eta_i_1 > eta_o_1;
    float visible_1;
    if(_S282)
    {
        visible_1 = terms_0.eta_level;
    }
    else
    {
        visible_1 = 1.0f;
    }
    float _S283;
    if(_S282)
    {
        _S283 = 1.0f;
    }
    else
    {
        _S283 = terms_0.eta_level;
    }
    float _S284 = fresnel(_S281, visible_1, _S283);
    bool _S285 = (eta_i_1 * eta_i_1 * (1.0f - _S276 * _S276)) >= (eta_o_1 * eta_o_1);
    float3  _S286;
    if(_S285)
    {
        _S286 = make_float3 (1.0f);
    }
    else
    {
        float3  _S287 = material_0.specular_tint * make_float3 (terms_0.f0);
        _S286 = _S287 + (make_float3 (1.0f) - _S287) * make_float3 (_S284 - terms_0.f0) / make_float3 (1.0f - terms_0.f0);
    }
    float3  _S288 = mix_0(_S286, material_0.albedo * view_terms_0.rebounce, material_0.metallic);
    float3  F_1 = _S288 * view_terms_0.scale;
    float _S289 = rgb_to_greyscale(F_1);
    float _S290 = 1.0f - material_0.metallic;
    float3  _S291 = make_float3 (1.0f) - _S286;
    float3  _S292 = make_float3 ((1.0f - material_0.transmission) * _S290) * _S291 * view_terms_0.scale;
    float3  _S293 = make_float3 (material_0.transmission * _S290) * _S291 * view_terms_0.scale;
    float _S294 = (F32_max((_S289), (0.0f)));
    float _S295 = rgb_to_greyscale(_S292);
    float _S296 = (F32_max((_S295), (0.0f)));
    float _S297 = rgb_to_greyscale(_S293);
    float _S298 = sign_0(length_0(_S280));
    float _S299 = (F32_max((_S297 * _S298), (0.0f)));
    float _S300 = _S294 + _S296 + _S299 + terms_0.toon_component;
    float _S301 = (F32_min((view_terms_0.sheen_component), (1.0f)));
    bool _S302 = (view_terms_0.sheen_component) > 0.0f;
    bool _S303;
    if(_S302)
    {
        _S303 = !(_S300 > 0.0f);
    }
    else
    {
        _S303 = false;
    }
    float _S304 = _slang_select(_S303, 1.0f,_S301);
    float _S305 = (1.0f - _S304) / (F32_max((_S300), (0.0000152587890625f)));
    float _S306 = _S296 * _S305;
    float _S307 = _S294 * _S305;
    float _S308 = _S299 * _S305;
    bool _S309 = (view_terms_0.frame.alphas.x) > 0.0f;
    if(_S309)
    {
        float3  _S310 = anisotropicLocal(view_terms_0.v, view_terms_0.frame.tangent, view_terms_0.n_i);
        float _S311 = anisotropicG1(_S310, view_terms_0.frame.alphas);
        float3  _S312 = anisotropicLocal(ggx_n_0, view_terms_0.frame.tangent, view_terms_0.n_i);
        float _S313 = anisotropicD(_S312, view_terms_0.frame.alphas);
        float _S314 = _S311 * _S313;
        visible_1 = _S314;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return HalfTerms_x24init_0(_S276, _S277, _S280, F_1, _S289, 1.0f, _S292, _S293, _S306, _S307, _S308, terms_0.translucent_share, view_terms_0.sheen, _S304, view_terms_0.view, view_terms_0.frame.tangent, view_terms_0.frame.alphas, visible_1, terms_0.toon_component * _S305, terms_0.toon, terms_0.toon_a, terms_0.toon_s, terms_0.toon_b, terms_0.toon_glossy, terms_0.toon_norm, view_terms_0.toon_view, view_terms_0.toon_axis);
}

__device__ __forceinline__ HalfTerms sampledHalf(float3  in_dir_1, float3  n_4, BSDFMaterial material_1, float eta_i_2, float eta_o_2, uint random_state_2, MaterialTerms terms_1, ViewTerms view_terms_1)
{
    uint state_3 = random_state_2;
    float3  _S315 = negate_0(in_dir_1);
    float _S316 = sign_0(dot_0(n_4, _S315));
    float _S317 = material_1.roughness;
    float3  _S318 = sampleHalfVector(_S315, n_4 * make_float3 (_S316), _S317 * _S317, view_terms_1.frame, &state_3);
    HalfTerms _S319 = precomputeHalf(in_dir_1, _S318, material_1, eta_i_2, eta_o_2, terms_1, view_terms_1);
    return _S319;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_2, HalfTerms lobes_0, float eta_i_3, float eta_o_3)
{
    float _S320 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S321 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S322 = 1.0f - lobes_0.translucent_share;
    bool _S323 = n_i_dot_l_0 < 0.0f;
    float _S324 = _slang_select(_S323, lobes_0.translucent_share,_S322);
    float _S325 = _S321 * _S324;
    bool _S326 = (lobes_0.translucent_share) > 0.0f;
    float _S327 = _slang_select(_S326, _S325,_S320);
    bool _S328 = n_i_dot_v_0 > 0.0f;
    float _S329 = _slang_select(_S328, _S327,0.0f);
    return _S329;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_1, float alpha_3, BSDFMaterial material_2, HalfTerms lobes_1)
{
    bool _S330 = (dot_0(n_i_1, l_0)) < 0.0f;
    float3  _S331 = _slang_select(_S330, material_2.translucent,material_2.albedo);
    float _S332 = 1.0f - lobes_1.translucent_share;
    float _S333 = _slang_select(_S330, lobes_1.translucent_share,_S332);
    float3  _S334 = _S331 / make_float3 (_S333);
    bool _S335 = (lobes_1.translucent_share) > 0.0f;
    float3  _S336 = _slang_select(_S335, _S334,material_2.albedo);
    return lobes_1.diffuse_weight * _S336 / make_float3 (lobes_1.p_diffuse);
}

__device__ __forceinline__ float3  misWeighted(float3  throughput_0, float lobe_pdf_0, float pdf_0, bool power_0)
{
    if(power_0)
    {
        float _S337 = lobe_pdf_0 / pdf_0;
        return throughput_0 * make_float3 (lobe_pdf_0) / make_float3 (pdf_0 * (1.0f + _S337 * _S337));
    }
    return throughput_0 * make_float3 (lobe_pdf_0) / make_float3 (lobe_pdf_0 + pdf_0);
}

__device__ __forceinline__ HalfTerms refractedHalf(float3  in_dir_2, float3  out_dir_0, float3  n_5, BSDFMaterial material_3, float eta_i_4, float eta_o_4, MaterialTerms terms_2, ViewTerms view_terms_2, float * l_dot_h_1)
{
    float3  _S338 = negate_0(in_dir_2);
    float3  _S339 = negate_0(make_float3 (eta_i_4) * _S338 + make_float3 (eta_o_4) * out_dir_0);
    float3  _S340 = ((((_S339)) * make_float3(rnorm3df(((_S339)).x, ((_S339)).y, ((_S339)).z))));
    float _S341 = sign_0(dot_0(n_5, _S338));
    float _S342 = sign_0(dot_0(_S339, n_5 * make_float3 (_S341)));
    float3  _S343 = _S340 * make_float3 (_S342);
    float _S344 = dot_0(out_dir_0, _S343);
    *l_dot_h_1 = _S344;
    HalfTerms _S345 = precomputeHalf(in_dir_2, _S343, material_3, eta_i_4, eta_o_4, terms_2, view_terms_2);
    return _S345;
}

__device__ float smithG1(float alpha_4, float n_dot_x_0)
{
    float _S346 = alpha_4 * alpha_4;
    float _S347 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S346 + (1.0f - _S346) * n_dot_x_0 * n_dot_x_0))));
    bool _S348 = alpha_4 > 0.0f;
    float _S349 = _slang_select(_S348, _S347,1.0f);
    return _S349;
}

__device__ float trowbridgeReitz(float alpha_5, float n_dot_h_1)
{
    float _S350 = alpha_5 * alpha_5;
    float _S351 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S350 * n_dot_h_1 * n_dot_h_1;
    return _S350 / (F32_max((3.14159274101257324f * _S351 * _S351), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, HalfTerms lobes_2)
{
    float _S352 = smithG1(alpha_6, n_i_dot_v_1);
    float _S353 = _S352 * lobes_2.v_dot_h;
    float _S354 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S355 = _S353 * _S354 / n_i_dot_v_1;
    bool _S356 = alpha_6 > 0.0f;
    bool _S357;
    if(_S356)
    {
        _S357 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S357 = false;
    }
    if(_S357)
    {
        _S357 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S357 = false;
    }
    if(_S357)
    {
        _S357 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S357 = false;
    }
    float _S358 = _slang_select(_S357, _S355,0.0f);
    bool _S359 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S359)
    {
        float _S360 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S361 = (lobes_2.v_dot_h) > 0.0f;
        if(_S361)
        {
            _S357 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S357 = false;
        }
        if(_S357)
        {
            _S357 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S357 = false;
        }
        float _S362 = _slang_select(_S357, _S360,0.0f);
        pdf_h_0 = _S362;
    }
    else
    {
        pdf_h_0 = _S358;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_2, float n_i_dot_v_2, float alpha_7, HalfTerms lobes_3, float eta_i_5, float eta_o_5)
{
    float _S363 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S364 = eta_i_5 * lobes_3.v_dot_h + eta_o_5 * l_dot_h_2;
    float _S365 = lobes_3.p_refract * _S363 * eta_o_5 * eta_o_5 * (F32_abs((l_dot_h_2))) / (_S364 * _S364);
    bool _S366 = eta_i_5 != eta_o_5;
    bool _S367;
    if(_S366)
    {
        _S367 = l_dot_h_2 < 0.0f;
    }
    else
    {
        _S367 = false;
    }
    float _S368 = _slang_select(_S367, _S365,0.0f);
    return _S368;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_2, float alpha_8, BSDFMaterial material_4, HalfTerms lobes_4)
{
    float _S369 = - dot_0(n_i_2, l_1);
    float _S370 = smithG1(alpha_8, (F32_max((_S369), (0.0f))));
    bool _S371 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S371)
    {
        float3  _S372 = negate_0(n_i_2);
        float3  _S373 = anisotropicLocal(l_1, lobes_4.tangent, _S372);
        float _S374 = anisotropicG1(_S373, lobes_4.alphas);
        G1_l_0 = _S374;
    }
    else
    {
        G1_l_0 = _S370;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_4.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ HalfTerms reflectedHalf(float3  in_dir_3, float3  out_dir_1, BSDFMaterial material_5, float eta_i_6, float eta_o_6, MaterialTerms terms_3, ViewTerms view_terms_3)
{
    float3  _S375 = negate_0(in_dir_3);
    float3  _S376 = _S375 + out_dir_1;
    float3  _S377 = ((((_S376)) * make_float3(rnorm3df(((_S376)).x, ((_S376)).y, ((_S376)).z))));
    HalfTerms _S378 = precomputeHalf(in_dir_3, _S377, material_5, eta_i_6, eta_o_6, terms_3, view_terms_3);
    return _S378;
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_2, float l_dot_h_3, float n_i_dot_v_3, float alpha_9, HalfTerms lobes_5, float eta_i_7, float eta_o_7)
{
    float _S379 = vndfPDF(n_i_dot_v_3, alpha_9, lobes_5);
    float _S380 = lobes_5.p_reflect * _S379 / (4.0f * lobes_5.v_dot_h);
    bool _S381 = _S379 > 0.0f;
    float _S382 = _slang_select(_S381, _S380,0.0f);
    return _S382;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_2, float3  n_i_3, float alpha_10, BSDFMaterial material_6, HalfTerms lobes_6)
{
    float _S383 = dot_0(n_i_3, l_2);
    float _S384 = smithG1(alpha_10, (F32_max((_S383), (0.0f))));
    bool _S385 = (lobes_6.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S385)
    {
        float3  _S386 = anisotropicLocal(l_2, lobes_6.tangent, n_i_3);
        float _S387 = anisotropicG1(_S386, lobes_6.alphas);
        G1_l_1 = _S387;
    }
    else
    {
        G1_l_1 = _S384;
    }
    return make_float3 (lobes_6.reflect_weight * G1_l_1) * lobes_6.F / make_float3 (lobes_6.p_reflect);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_3, float l_dot_h_4, float n_i_dot_v_4, float alpha_11, HalfTerms lobes_7, float eta_i_8, float eta_o_8)
{
    float _S388 = lobes_7.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S389 = n_i_dot_l_3 > 0.0f;
    bool _S390;
    if(_S389)
    {
        _S390 = n_i_dot_v_4 > 0.0f;
    }
    else
    {
        _S390 = false;
    }
    float _S391 = _slang_select(_S390, _S388,0.0f);
    return _S391;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_3, float3  n_i_4, float alpha_12, BSDFMaterial material_7, HalfTerms lobes_8)
{
    float3  _S392 = l_3 + lobes_8.view;
    float3  _S393 = ((((_S392)) * make_float3(rnorm3df(((_S392)).x, ((_S392)).y, ((_S392)).z))));
    float _S394 = dot_0(n_i_4, _S393);
    float _S395 = (F32_max((dot_0(n_i_4, l_3)), (0.0f)));
    float _S396 = (F32_max((dot_0(n_i_4, lobes_8.view)), (0.0f)));
    float _S397 = 1.0f / (F32_max((material_7.sheen_roughness), (0.05000000074505806f)));
    float _S398 = 1.0f - _S394 * _S394;
    float _S399 = (2.0f + _S397) * (F32_pow(((F32_max((_S398), (0.0f)))), (0.5f * _S397))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S395 + _S396 - _S395 * _S396)), (0.0000152587890625f)));
    bool _S400 = (material_7.velvet) > 0.0f;
    float f_1;
    if(_S400)
    {
        float _S401 = (F32_max((material_7.sheen_roughness), (0.00999999977648258f)));
        float _S402 = _S401 * _S401;
        float _S403 = (F32_max((_S398), (0.0000152587890625f)));
        float _S404 = (F32_exp((- _S394 * _S394 / (_S403 * _S402)))) / (3.14159274101257324f * _S402 * _S403 * _S403) * (F32_min((1.0f), (2.0f * _S394 * (F32_min((_S395), (_S396))) / (F32_max(((F32_abs((dot_0(_S393, lobes_8.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S395 * _S396), (0.0000152587890625f)));
        f_1 = _S404;
    }
    else
    {
        f_1 = _S399;
    }
    return lobes_8.sheen * make_float3 (f_1 * _S395 * 2.0f * 3.14159274101257324f / lobes_8.p_sheen_velvet);
}

static __device__ float clamp_1(float x_11, float minBound_1, float maxBound_1)
{
    return (F32_min(((F32_max((x_11), (minBound_1)))), (maxBound_1)));
}

__device__ __forceinline__ float toonPDF(float n_i_dot_l_4, float l_dot_h_5, float n_i_dot_v_5, float alpha_13, HalfTerms lobes_9, float eta_i_9, float eta_o_9)
{
    float _S405 = _slang_select(lobes_9.toon_glossy, l_dot_h_5,n_i_dot_l_4);
    float _S406 = (F32_acos((clamp_1(_S405, -1.0f, 1.0f))));
    float _S407;
    if(_S406 < (lobes_9.toon_a))
    {
        _S407 = 1.0f;
    }
    else
    {
        _S407 = (F32_max((1.0f - (_S406 - lobes_9.toon_a) / (F32_max((lobes_9.toon_s), (0.0000152587890625f)))), (0.0f)));
    }
    float _S408 = lobes_9.p_toon * _S407;
    float _S409 = _slang_select(lobes_9.toon_glossy, 1.0f,n_i_dot_l_4);
    float _S410 = _S408 * _S409 / lobes_9.toon_norm;
    bool _S411;
    if(lobes_9.toon_glossy)
    {
        _S411 = true;
    }
    else
    {
        _S411 = n_i_dot_l_4 > 0.0f;
    }
    float _S412 = _slang_select(_S411, _S410,0.0f);
    return _S412;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_4, float3  n_i_5, float alpha_14, BSDFMaterial material_8, HalfTerms lobes_10)
{
    float _S413 = (F32_max((dot_0(n_i_5, l_4)), (0.0f)));
    float _S414 = _slang_select(lobes_10.toon_glossy, _S413,lobes_10.toon_view);
    return lobes_10.toon * make_float3 (_S414) / make_float3 (lobes_10.p_toon);
}

static __device__ float3  neeLobes_0(float3  in_dir_4, float3  dir_3, float3  n_6, BSDFMaterial * material_9, float eta_i_10, float eta_o_10, bool refracted_2, float pdf_1, bool power_1, uint random_state_3, MaterialTerms * terms_4, ViewTerms * view_terms_4, SkyWorld_0 * world_0)
{
    float3  _S415 = negate_0(in_dir_4);
    float _S416 = dot_0(n_6, _S415);
    float _S417 = sign_0(_S416);
    float3  _S418 = n_6 * make_float3 (_S417);
    float _S419 = dot_0(_S418, dir_3);
    float _S420 = material_9->roughness * material_9->roughness;
    float3  f_2 = make_float3 (0.0f);
    float _S421 = rgb_to_greyscale(material_9->translucent);
    bool _S422 = _S421 > 0.0f;
    bool _S423;
    if(_S422)
    {
        float _S424 = dot_0(n_6, dir_3);
        float3  _S425 = negate_0(in_dir_4);
        _S423 = ((_S424 * dot_0(n_6, _S425)) < 0.0f) == refracted_2;
    }
    else
    {
        _S423 = !refracted_2;
    }
    bool _S426 = !refracted_2;
    bool _S427;
    if(_S426)
    {
        _S427 = (F32_abs((material_9->toon.x))) > 0.0f;
    }
    else
    {
        _S427 = false;
    }
    HalfTerms _S428 = HalfTerms_x24init_0(0.0f, 0.0f, f_2, f_2, 0.0f, 0.0f, f_2, f_2, 0.0f, 0.0f, 0.0f, 0.0f, f_2, 0.0f, f_2, f_2, make_float2 (0.0f), 0.0f, 0.0f, f_2, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, f_2);
    bool _S429;
    if(_S423)
    {
        _S429 = true;
    }
    else
    {
        _S429 = _S427;
    }
    HalfTerms sampled_0;
    if(_S429)
    {
        HalfTerms _S430 = sampledHalf(in_dir_4, n_6, *material_9, eta_i_10, eta_o_10, random_state_3, *terms_4, *view_terms_4);
        sampled_0 = _S430;
    }
    else
    {
        sampled_0 = _S428;
    }
    float3  f_3;
    if(_S423)
    {
        float _S431 = diffusePDF(_S419, 0.0f, (F32_abs((_S416))), _S420, sampled_0, eta_i_10, eta_o_10);
        bool _S432 = _S431 > 0.0f;
        if(_S432)
        {
            float3  _S433 = diffuseBSDF(dir_3, _S418, _S420, *material_9, sampled_0);
            float3  _S434 = misWeighted(_S433, _S431, pdf_1, power_1);
            float3  _S435 = SkyWorld_seen_0(world_0, 0U);
            float3  _S436 = _S434 * _S435;
            f_3 = _S436;
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
    if(refracted_2)
    {
        float l_dot_h_6 = 0.0f;
        HalfTerms _S437 = refractedHalf(in_dir_4, dir_3, n_6, *material_9, eta_i_10, eta_o_10, *terms_4, *view_terms_4, &l_dot_h_6);
        float _S438 = refractPDF(_S419, l_dot_h_6, (F32_abs((_S416))), _S420, _S437, eta_i_10, eta_o_10);
        bool _S439 = _S438 > 0.0f;
        if(_S439)
        {
            float3  _S440 = refractBSDF(dir_3, _S418, _S420, *material_9, _S437);
            float3  _S441 = misWeighted(_S440, _S438, pdf_1, power_1);
            float3  _S442 = SkyWorld_seen_0(world_0, 1U);
            float3  f_4 = f_3 + _S441 * _S442;
            f_3 = f_4;
        }
    }
    else
    {
        HalfTerms _S443 = reflectedHalf(in_dir_4, dir_3, *material_9, eta_i_10, eta_o_10, *terms_4, *view_terms_4);
        float _S444 = (F32_abs((_S416)));
        float _S445 = reflectPDF(_S419, 0.0f, _S444, _S420, _S443, eta_i_10, eta_o_10);
        bool _S446 = _S445 > 0.0f;
        if(_S446)
        {
            float3  _S447 = reflectBSDF(dir_3, _S418, _S420, *material_9, _S443);
            float3  _S448 = misWeighted(_S447, _S445, pdf_1, power_1);
            float3  _S449 = SkyWorld_seen_0(world_0, 2U);
            float3  f_5 = f_3 + _S448 * _S449;
            f_3 = f_5;
        }
        float _S450 = sheenVelvetPDF(_S419, 0.0f, _S444, _S420, _S443, eta_i_10, eta_o_10);
        bool _S451 = _S450 > 0.0f;
        if(_S451)
        {
            float3  _S452 = sheenVelvetBSDF(dir_3, _S418, _S420, *material_9, _S443);
            float3  _S453 = misWeighted(_S452, _S450, pdf_1, power_1);
            float3  _S454 = SkyWorld_seen_0(world_0, 4U);
            float3  f_6 = f_3 + _S453 * _S454;
            f_3 = f_6;
        }
    }
    if(_S427)
    {
        float _S455 = toonPDF(_S419, dot_0(dir_3, sampled_0.toon_axis), (F32_abs((_S416))), _S420, sampled_0, eta_i_10, eta_o_10);
        bool _S456 = _S455 > 0.0f;
        if(_S456)
        {
            float3  _S457 = toonBSDF(dir_3, _S418, _S420, *material_9, sampled_0);
            float3  _S458 = misWeighted(_S457, _S455, pdf_1, power_1);
            float3  _S459 = SkyWorld_seen_0(world_0, 6U);
            float3  f_7 = f_3 + _S458 * _S459;
            f_3 = f_7;
        }
    }
    return f_3;
}

static __device__ SkyWorld_0 SkyWorld_x24init_0(float3  dir_4, uint depth_1)
{
    SkyWorld_0 _S460;
    (&_S460)->dir_2 = dir_4;
    (&_S460)->depth_0 = depth_1;
    return _S460;
}

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

static __device__ float3  lightTransmittance_0(float3  origin_2, float3  smooth_n_0, float geometry_offset_0, float3  light_dir_0, ShadowContext * context_1, uint random_state_4, FKHit * light_0)
{
    float3  _S461 = ((((light_dir_0)) * make_float3(rnorm3df(((light_dir_0)).x, ((light_dir_0)).y, ((light_dir_0)).z))));
    bool _S462 = (dot_0(smooth_n_0, _S461)) < 0.0f;
    if(_S462)
    {
        return make_float3 (0.0f);
    }
    float3  _S463 = make_float3 (geometry_offset_0) * smooth_n_0;
    float3  _S464 = origin_2 + _S463;
    FKRay _S465 = Ray_x24init_0(_S464, _S461);
    bool _S466 = (dot_0(context_1->side, light_dir_0 + _S463)) > 0.0f;
    float _S467 = shadowLength(light_dir_0);
    float3  _S468 = context_1->extinction_behind;
    float3  _S469 = context_1->extinction_front;
    float3  _S470 = _slang_select(_S466, _S469,_S468);
    uint _S471 = context_1->fillings.x;
    uint _S472 = context_1->fillings.y;
    uint _S473 = _slang_select(_S466, _S472,_S471);
    uint _S474 = context_1->depth;
    uint _S475 = context_1->lobe;
    bool _S476 = context_1->surface;
    bool _S477;
    if(_S476)
    {
        _S477 = !context_1->fiber;
    }
    else
    {
        _S477 = false;
    }
    float _S478 = context_1->length;
    float _S479 = context_1->width;
    FKHit _S480;
    if(context_1->fiber)
    {
        _S480 = context_1->own;
    }
    else
    {
        _S480 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    }
    float3  _S481 = (fcptShadowTransmittanceIn((_S465), (_S467), (_S470), (_S473), (random_state_4), (_S474), (_S475), (_S477), (_S478), (_S479), (_S480), (*light_0)));
    return _S481;
}

__device__ float sine(float c_0)
{
    return (F32_sqrt(((F32_max((1.0f - c_0 * c_0), (0.0f))))));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S482 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S483 = cos_a_0 > cos_b_0;
    float _S484 = _slang_select(_S483, 1.0f,_S482);
    return _S484;
}

__device__ float sinSubClamped(float sin_a_1, float cos_a_1, float sin_b_1, float cos_b_1)
{
    float _S485 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    bool _S486 = cos_a_1 > cos_b_1;
    float _S487 = _slang_select(_S486, 0.0f,_S485);
    return _S487;
}

__device__ float importance(LightNode node_0, float3  p_9, float3  normal_0)
{
    float3  _S488 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S489 = node_0.high - node_0.low;
    float3  _S490 = p_9 - _S488;
    float3  _S491 = ((((_S490)) * make_float3(rnorm3df(((_S490)).x, ((_S490)).y, ((_S490)).z))));
    float _S492 = dot_0(_S490, _S490);
    float _S493 = dot_0(_S489, _S489) / 4.0f;
    float _S494 = (F32_abs((dot_0(node_0.w, _S491))));
    float _S495 = sine(node_0.cos_theta_o);
    float _S496 = (F32_sqrt(((F32_max((1.0f - _S493 / _S492), (0.0f))))));
    bool _S497 = _S492 < _S493;
    float _S498 = _slang_select(_S497, -1.0f,_S496);
    float _S499 = sine(_S498);
    float _S500 = sine(_S494);
    float _S501 = cosSubClamped(_S500, _S494, _S495, node_0.cos_theta_o);
    float _S502 = sine(_S494);
    float _S503 = sinSubClamped(_S502, _S494, _S495, node_0.cos_theta_o);
    float _S504 = cosSubClamped(_S503, _S501, _S499, _S498);
    bool _S505 = _S504 <= 0.0f;
    if(_S505)
    {
        return 0.0f;
    }
    float _S506 = - dot_0(_S491, normal_0);
    float _S507 = node_0.phi * _S504 / (F32_max((_S492), (length_0(_S489) / 2.0f)));
    float _S508 = sine(_S506);
    float _S509 = cosSubClamped(_S508, _S506, _S499, _S498);
    bool _S510 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S511 = _slang_select(_S510, 1.0f,_S509);
    return (F32_max((_S507 * _S511), (0.0f)));
}

__device__ __forceinline__ float childShare(LightNode first_0, LightNode second_0, float3  p_10, float3  normal_1, uint child_0)
{
    float _S512 = importance(first_0, p_10, normal_1);
    float _S513 = importance(second_0, p_10, normal_1);
    float2  _S514 = make_float2 (_S512, _S513);
    float _S515 = _slang_vector_get_element(_S514, child_0) / (_S512 + _S513);
    bool _S516 = _slang_vector_get_element(_S514, child_0) > 0.0f;
    float _S517 = _slang_select(_S516, _S515,0.0f);
    return _S517;
}

__device__ float sphereDensity(float3  center_0, float radius_0, float3  p_11)
{
    float3  _S518 = center_0 - p_11;
    float _S519 = radius_0 * radius_0 / dot_0(_S518, _S518);
    bool _S520 = _S519 >= 1.0f;
    if(_S520)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S519)))) / (6.28318548202514648f * _S519);
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_0))));
}

static __device__ float lightPdf_0(float3  origin_3, float3  smooth_n_1, float3  start_5, uint j_0, float3  light_point_0)
{
    bool _S521 = j_0 == 4294967295U;
    if(_S521)
    {
        return 0.0f;
    }
    uint4  _S522 = (fcptLightTrail((j_0)));
    uint2  _S523 = uint2 {_S522.x, _S522.y};
    uint n_7 = 0U;
    uint2  trail_0 = _S523;
    float probability_1 = 1.0f;
    for(;;)
    {
        uint4  _S524 = (fcptLightNode((n_7)));
        if((_S524.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S525 = (fcptLightSecond((n_7)));
        uint _S526 = n_7 + 1U;
        LightNode _S527 = (fcptLightBounds((_S526)));
        LightNode _S528 = (fcptLightBounds((_S525)));
        uint _S529 = trail_0.x;
        uint _S530 = _S529 & 1U;
        float _S531 = childShare(_S527, _S528, origin_3, smooth_n_1, _S530);
        float probability_2 = probability_1 * _S531;
        bool _S532 = _S530 == 1U;
        uint _S533 = _slang_select(_S532, _S525,_S526);
        uint _S534 = trail_0.y;
        uint2  _S535 = make_uint2 ((_S529 >> 1U) | (_S534 << 31U), _S534 >> 1U);
        n_7 = _S533;
        trail_0 = _S535;
        probability_1 = probability_2;
    }
    bool _S536 = (fcptSlotLeaf((n_7), (j_0)));
    bool _S537 = !_S536;
    bool _S538;
    if(_S537)
    {
        _S538 = true;
    }
    else
    {
        LightNode _S539 = (fcptLightBounds((n_7)));
        float _S540 = importance(_S539, origin_3, smooth_n_1);
        _S538 = !(_S540 > 0.0f);
    }
    if(_S538)
    {
        _S538 = true;
    }
    else
    {
        bool _S541 = (dot_0(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S541)
        {
            _S538 = !((dot_0(smooth_n_1, light_point_0 - origin_3)) > 0.0f);
        }
        else
        {
            _S538 = false;
        }
    }
    if(_S538)
    {
        return 0.0f;
    }
    uint4  _S542 = (fcptLightNode((n_7)));
    bool _S543 = (_S542.x) == 2U;
    if(_S543)
    {
        uint _S544 = _S542.y;
        FKLight _S545 = (fcptLight((_S544)));
        FKLight _S546 = (fcptLight((_S544)));
        float _S547 = sphereDensity(_S545.position, _S546.variance, start_5);
        return probability_1 * _S547;
    }
    uint _S548 = _S542.y;
    uint _S549 = (fcptTriangleOffset((_S548)));
    Matrix<float, 3, 3>  _S550 = (fcptWorldTriangle((_S548), (_S549 + _S542.z)));
    float _S551 = solidAngle(probability_1, cross_0(_S550.rows[int(1)] - _S550.rows[int(0)], _S550.rows[int(2)] - _S550.rows[int(0)]), light_point_0 - start_5);
    return _S551;
}

struct SkySample
{
    float3  dir;
    float3  radiance;
    float3  color;
    uint random_state;
};

static __device__ uint2  min_0(uint2  x_12, uint2  y_2)
{
    uint2  result_4;
    int i_5 = int(0);
    for(;;)
    {
        if(i_5 < int(2))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_4, i_5) = (U32_min((_slang_vector_get_element(x_12, i_5)), (_slang_vector_get_element(y_2, i_5))));
        i_5 = i_5 + int(1);
    }
    return result_4;
}

static __device__ float dot_1(float2  x_13, float2  y_3)
{
    return x_13.x * y_3.x + x_13.y * y_3.y;
}

static __device__ float length_1(float2  x_14)
{
    return (F32_sqrt((dot_1(x_14, x_14))));
}

static __device__ float environmentPdf_0(float3  dir_5)
{
    uint2  _S552 = (fcptEnvironmentCdfSize());
    uint2  _S553 = _S552 - make_uint2 (1U, 0U);
    float2  _S554 = make_float2 ((F32_atan2((- dir_5.y), (dir_5.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_1(dir_5.z, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S555 = make_float2 ((float)_S553.x, (float)_S553.y);
    float2  _S556 = _S554 * _S555;
    uint2  _S557 = make_uint2 ((uint)_S556.x, (uint)_S556.y);
    uint2  _S558 = min_0(_S557, _S553 - make_uint2 (1U));
    float4  _S559 = (fcptEnvironmentCdf((_S558)));
    float _S560 = _S559.y;
    uint _S561 = _S553.x;
    float4  _S562 = (fcptEnvironmentCdf((make_uint2 (_S561, _S558.y))));
    float _S563 = _S560 * _S562.y;
    return _S563 * float(_S561 * _S553.y) / (19.73921012878417969f * length_1(float2 {dir_5.x, dir_5.y}));
}

__device__ float translucentShare(BSDFMaterial material_10)
{
    float _S564 = rgb_to_greyscale(material_10.translucent);
    float _S565 = rgb_to_greyscale(material_10.albedo);
    float _S566 = _S564 / (_S565 + _S564);
    bool _S567 = _S564 > 0.0f;
    float _S568 = _slang_select(_S567, _S566,0.0f);
    return _S568;
}

static __device__ MaterialTerms MaterialTerms_x24init_0(float f0_0, float eta_level_0, float translucent_share_1, float toon_scale_0, float toon_component_0, float3  toon_1, float toon_a_1, float toon_s_1, float toon_b_1, bool toon_glossy_1, float toon_norm_1)
{
    MaterialTerms _S569;
    (&_S569)->f0 = f0_0;
    (&_S569)->eta_level = eta_level_0;
    (&_S569)->translucent_share = translucent_share_1;
    (&_S569)->toon_scale = toon_scale_0;
    (&_S569)->toon_component = toon_component_0;
    (&_S569)->toon = toon_1;
    (&_S569)->toon_a = toon_a_1;
    (&_S569)->toon_s = toon_s_1;
    (&_S569)->toon_b = toon_b_1;
    (&_S569)->toon_glossy = toon_glossy_1;
    (&_S569)->toon_norm = toon_norm_1;
    return _S569;
}

__device__ __forceinline__ MaterialTerms precomputeMaterial(BSDFMaterial material_11, float eta_i_11, float eta_o_11)
{
    float _S570 = (F32_min(((F32_sqrt((material_11.specular_level))) * (F32_abs((eta_i_11 - eta_o_11))) / (eta_i_11 + eta_o_11)), (0.9999847412109375f)));
    float _S571 = _S570 * _S570;
    float _S572 = (1.0f + _S570) / (1.0f - _S570);
    float3  _S573 = make_float3 (0.0f);
    float _S574 = material_11.toon.x;
    bool _S575 = _S574 < 0.0f;
    float _S576 = (F32_abs((_S574)));
    bool _S577 = _S576 > 0.0f;
    float toon_scale_1;
    float toon_component_1;
    float toon_a_2;
    float toon_s_2;
    float toon_b_2;
    float toon_norm_2;
    float3  toon_2;
    if(_S577)
    {
        float _S578 = (F32_min((_S576), (1.0f)));
        float _S579 = 1.0f - _S578;
        float _S580 = rgb_to_greyscale(material_11.albedo);
        float _S581 = _S578 * _S580;
        float3  _S582 = make_float3 (_S578) * material_11.albedo;
        float toon_a_3 = clamp_1(material_11.toon.y / _S574, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_3 = clamp_1(material_11.toon.z / _S574, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S583 = (F32_min((toon_a_3 + toon_s_3), (1.57079637050628662f)));
        if(_S575)
        {
            toon_scale_1 = 1.0f - (F32_cos(((F32_min((_S583), (toon_a_3))))));
        }
        else
        {
            float _S584 = (F32_sin(((F32_min((_S583), (toon_a_3))))));
            toon_scale_1 = _S584 * _S584 / 2.0f;
        }
        bool _S585 = _S583 > toon_a_3;
        bool _S586;
        if(_S585)
        {
            _S586 = toon_s_3 > 0.0f;
        }
        else
        {
            _S586 = false;
        }
        if(_S586)
        {
            if(_S575)
            {
                float _S587 = (F32_cos((toon_a_3)));
                float _S588 = (F32_cos((_S583)));
                toon_component_1 = (1.0f + toon_a_3 / toon_s_3) * (_S587 - _S588) - ((F32_sin((_S583))) - _S583 * _S588 - ((F32_sin((toon_a_3))) - toon_a_3 * _S587)) / toon_s_3;
            }
            else
            {
                float _S589 = 2.0f * toon_a_3;
                float _S590 = (F32_cos((_S589)));
                float _S591 = 2.0f * _S583;
                float _S592 = (F32_cos((_S591)));
                toon_component_1 = (1.0f + toon_a_3 / toon_s_3) * (_S590 - _S592) / 4.0f - ((F32_sin((_S591))) / 8.0f - _S583 * _S592 / 4.0f - ((F32_sin((_S589))) / 8.0f - toon_a_3 * _S590 / 4.0f)) / toon_s_3;
            }
            float integral_0 = toon_scale_1 + toon_component_1;
            toon_scale_1 = integral_0;
        }
        float _S593 = 6.28318548202514648f * toon_scale_1;
        toon_scale_1 = _S579;
        toon_component_1 = _S581;
        toon_2 = _S582;
        toon_a_2 = toon_a_3;
        toon_s_2 = toon_s_3;
        toon_b_2 = _S583;
        toon_norm_2 = _S593;
    }
    else
    {
        toon_scale_1 = 1.0f;
        toon_component_1 = 0.0f;
        toon_2 = _S573;
        toon_a_2 = 0.0f;
        toon_s_2 = 0.0f;
        toon_b_2 = 0.0f;
        toon_norm_2 = 1.0f;
    }
    float _S594 = translucentShare(material_11);
    return MaterialTerms_x24init_0(_S571, _S572, _S594, toon_scale_1, toon_component_1, toon_2, toon_a_2, toon_s_2, toon_b_2, _S575, toon_norm_2);
}

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_1, float2  alphas_3)
{
    AnisotropicFrame _S595;
    (&_S595)->tangent = tangent_1;
    (&_S595)->alphas = alphas_3;
    return _S595;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_12, float3  n_i_6)
{
    float _S596 = material_12.roughness;
    float _S597 = _S596 * _S596;
    bool _S598 = (material_12.anisotropy) == 0.0f;
    bool _S599;
    if(_S598)
    {
        _S599 = true;
    }
    else
    {
        _S599 = !(_S597 > 0.0f);
    }
    if(_S599)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S600 = material_12.tangent - n_i_6 * make_float3 (dot_0(n_i_6, material_12.tangent));
    float3  _S601 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_6);
    bool _S602 = (dot_0(_S600, _S600)) > 0.0f;
    float3  _S603 = _slang_select(_S602, _S600,_S601);
    float3  _S604 = ((((_S603)) * make_float3(rnorm3df(((_S603)).x, ((_S603)).y, ((_S603)).z))));
    float _S605 = 6.28318548202514648f * material_12.anisotropic_rotation;
    float _S606 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_12.anisotropy))))));
    float _S607 = 1.0f / _S606;
    bool _S608 = (material_12.anisotropy) < 0.0f;
    float _S609 = _slang_select(_S608, _S607,_S606);
    return AnisotropicFrame_x24init_0(_S604 * make_float3 ((F32_cos((_S605)))) + cross_0(n_i_6, _S604) * make_float3 ((F32_sin((_S605)))), make_float2 (_S597 / _S609, _S597 * _S609));
}

__device__ static const FixedArray<float, 576>  SHEEN_ALBEDO_0 = { {
    0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f
} };
__device__ static const FixedArray<float, 576>  VELVET_ALBEDO_0 = { {
    1.00383996963500977f, 1.00428998470306396f, 1.00356996059417725f, 1.00303995609283447f, 1.00261998176574707f, 1.00229001045227051f, 1.00198996067047119f, 1.00171005725860596f, 1.00144004821777344f, 1.00120997428894043f, 1.00102996826171875f, 1.00092005729675293f, 1.00088000297546387f, 1.0009000301361084f, 1.00095999240875244f, 1.00106000900268555f, 1.00115001201629639f, 1.00124001502990723f, 1.001289963722229f, 1.0013200044631958f, 1.00133001804351807f, 1.00133001804351807f, 1.0013200044631958f, 1.00129997730255127f, 0.99086397886276245f, 0.9934689998626709f, 0.99439799785614014f, 0.99513500928878784f, 0.99574202299118042f, 0.9962649941444397f, 0.99671798944473267f, 0.99709898233413696f, 0.997406005859375f, 0.99764800071716309f, 0.99783498048782349f, 0.99798601865768433f, 0.99811899662017822f, 0.99825501441955566f, 0.99840497970581055f, 0.99857097864151001f, 0.99874699115753174f, 0.99892902374267578f, 0.9990919828414917f, 0.99923902750015259f, 0.99936902523040771f, 0.99948000907897949f, 0.99957501888275146f, 0.99965798854827881f, 0.94088798761367798f, 0.95128101110458374f, 0.95866602659225464f, 0.96450901031494141f, 0.96921002864837646f, 0.973052978515625f, 0.97623497247695923f, 0.97890102863311768f, 0.98115700483322144f, 0.98308497667312622f, 0.98474901914596558f, 0.98619699478149414f, 0.98746699094772339f, 0.98858797550201416f, 0.98958402872085571f, 0.99047297239303589f, 0.99127000570297241f, 0.99198299646377563f, 0.99262100458145142f, 0.99318897724151611f, 0.99372398853302002f, 0.99426800012588501f, 0.99475300312042236f, 0.99514400959014893f, 0.86131101846694946f, 0.88463401794433594f, 0.90212702751159668f, 0.91595500707626343f, 0.92708200216293335f, 0.93617302179336548f, 0.94370102882385254f, 0.95000702142715454f, 0.95534700155258179f, 0.9599120020866394f, 0.96384698152542114f, 0.96726799011230469f, 0.97026199102401733f, 0.97289901971817017f, 0.97523599863052368f, 0.97731602191925049f, 0.97917401790618896f, 0.98083901405334473f, 0.98233497142791748f, 0.98368102312088013f, 0.98489302396774292f, 0.98598498106002808f, 0.98697298765182495f, 0.98787301778793335f, 0.75306302309036255f, 0.79328000545501709f, 0.82418698072433472f, 0.84881901741027832f, 0.86874997615814209f, 0.88506197929382324f, 0.89858502149581909f, 0.9099239706993103f, 0.91952997446060181f, 0.9277459979057312f, 0.93483197689056396f, 0.94099199771881104f, 0.9463840126991272f, 0.95113497972488403f, 0.95534402132034302f, 0.95908999443054199f, 0.9624369740486145f, 0.96543699502944946f, 0.96813201904296875f, 0.97055697441101074f, 0.97274202108383179f, 0.97471201419830322f, 0.97649002075195312f, 0.97809398174285889f, 0.62183499336242676f, 0.68052101135253906f, 0.72705197334289551f, 0.76452702283859253f, 0.79505598545074463f, 0.82021200656890869f, 0.84120297431945801f, 0.85885602235794067f, 0.87384098768234253f, 0.88667500019073486f, 0.89775800704956055f, 0.90739899873733521f, 0.91584599018096924f, 0.92329102754592896f, 0.929889976978302f, 0.93576502799987793f, 0.94101500511169434f, 0.94572198390960693f, 0.94994997978210449f, 0.95375597476959229f, 0.95718497037887573f, 0.9602770209312439f, 0.96306699514389038f, 0.96558600664138794f, 0.47742500901222229f, 0.5522189736366272f, 0.61415499448776245f, 0.66520899534225464f, 0.70744901895523071f, 0.74262100458145142f, 0.77213901281356812f, 0.7971159815788269f, 0.81841897964477539f, 0.83673000335693359f, 0.85258400440216064f, 0.86640900373458862f, 0.87854301929473877f, 0.88924998044967651f, 0.89874798059463501f, 0.90721100568771362f, 0.91477799415588379f, 0.92156499624252319f, 0.92766499519348145f, 0.93315702676773071f, 0.9381060004234314f, 0.94257098436355591f, 0.94660097360610962f, 0.95023900270462036f, 0.33539599180221558f, 0.41908100247383118f, 0.49247598648071289f, 0.55531197786331177f, 0.60879099369049072f, 0.65415602922439575f, 0.69274699687957764f, 0.72571200132369995f, 0.75402498245239258f, 0.77849102020263672f, 0.79976201057434082f, 0.81836599111557007f, 0.83474302291870117f, 0.84922301769256592f, 0.86208897829055786f, 0.87356698513031006f, 0.88384199142456055f, 0.89306402206420898f, 0.90135800838470459f, 0.9088289737701416f, 0.91556602716445923f, 0.92164498567581177f, 0.92713397741317749f, 0.93208998441696167f, 0.21194499731063843f, 0.29365798830986023f, 0.37110498547554016f, 0.44143900275230408f, 0.5036969780921936f, 0.55801302194595337f, 0.60521197319030762f, 0.64614301919937134f, 0.68169897794723511f, 0.71268302202224731f, 0.73979401588439941f, 0.76362699270248413f, 0.78467601537704468f, 0.80335497856140137f, 0.82000100612640381f, 0.83488202095031738f, 0.8482239842414856f, 0.86021500825881958f, 0.87101101875305176f, 0.88074499368667603f, 0.88952797651290894f, 0.89745801687240601f, 0.90461999177932739f, 0.91109001636505127f, 0.11949499696493149f, 0.18745699524879456f, 0.25997200608253479f, 0.33120998740196228f, 0.39773499965667725f, 0.45832300186157227f, 0.51248997449874878f, 0.56048798561096191f, 0.6028980016708374f, 0.64032697677612305f, 0.67339599132537842f, 0.70268499851226807f, 0.72870397567749023f, 0.75189602375030518f, 0.77263599634170532f, 0.7912449836730957f, 0.80796998739242554f, 0.82303100824356079f, 0.8366129994392395f, 0.84887397289276123f, 0.85994899272918701f, 0.86995697021484375f, 0.87900298833847046f, 0.88717901706695557f, 0.05942929908633232f, 0.10839699953794479f, 0.16785700619220734f, 0.23236599564552307f, 0.29767501354217529f, 0.36022999882698059f, 0.41842898726463318f, 0.47170799970626831f, 0.5198180079460144f, 0.56301301717758179f, 0.60171198844909668f, 0.63635998964309692f, 0.66739702224731445f, 0.69524997472763062f, 0.720287024974823f, 0.74283498525619507f, 0.76317602396011353f, 0.78155702352523804f, 0.79817098379135132f, 0.81319701671600342f, 0.8267899751663208f, 0.83908802270889282f, 0.85021400451660156f, 0.86027902364730835f, 0.02584660053253174f, 0.05619670078158379f, 0.09917669743299484f, 0.15162299573421478f, 0.20941600203514099f, 0.26902499794960022f, 0.32757499814033508f, 0.38318398594856262f, 0.43501600623130798f, 0.48271399736404419f, 0.52620798349380493f, 0.56570100784301758f, 0.60149699449539185f, 0.63392102718353271f, 0.66328197717666626f, 0.68988502025604248f, 0.7139970064163208f, 0.7358660101890564f, 0.75570398569107056f, 0.77369099855422974f, 0.78999698162078857f, 0.80477499961853027f, 0.81816202402114868f, 0.83028298616409302f, 0.00968609005212784f, 0.02591750025749207f, 0.05318830162286758f, 0.09121809899806976f, 0.13777700066566467f, 0.18976299464702606f, 0.244159996509552f, 0.29880800843238831f, 0.35169300436973572f, 0.40180501341819763f, 0.44872200489044189f, 0.49213200807571411f, 0.53206497430801392f, 0.5686650276184082f, 0.60214298963546753f, 0.63272500038146973f, 0.66062301397323608f, 0.68605399131774902f, 0.70922297239303589f, 0.73031198978424072f, 0.74948400259017944f, 0.76689702272415161f, 0.78270000219345093f, 0.79702901840209961f, 0.00303822988644242f, 0.01048239972442389f, 0.02568300068378448f, 0.05025380104780197f, 0.08408640325069427f, 0.12561400234699249f, 0.17249999940395355f, 0.22232000529766083f, 0.27309399843215942f, 0.32321798801422119f, 0.37149098515510559f, 0.4173240065574646f, 0.4603630006313324f, 0.50043797492980957f, 0.53755801916122437f, 0.57181298732757568f, 0.60333001613616943f, 0.63226902484893799f, 0.65877401828765869f, 0.68301999568939209f, 0.70514601469039917f, 0.7253040075302124f, 0.74363899230957031f, 0.76029098033905029f, 0.00076204299693927f, 0.00361976004205644f, 0.0110037000849843f, 0.02512970007956028f, 0.04727460071444511f, 0.07745999842882156f, 0.11460299789905548f, 0.1569570004940033f, 0.20258499681949615f, 0.24971699714660645f, 0.29707801342010498f, 0.34340900182723999f, 0.38799500465393066f, 0.43043500185012817f, 0.47039699554443359f, 0.50777101516723633f, 0.54253697395324707f, 0.57473397254943848f, 0.60444700717926025f, 0.63179397583007812f, 0.65686798095703125f, 0.67979699373245239f, 0.70071202516555786f, 0.71974599361419678f, 0.00014345299859997f, 0.00102306995540857f, 0.00407376000657678f, 0.01122699957340956f, 0.02423799969255924f, 0.04415180161595345f, 0.07109060138463974f, 0.10433399677276611f, 0.14259399473667145f, 0.184347003698349f, 0.2281080037355423f, 0.27265200018882751f, 0.31696400046348572f, 0.36016398668289185f, 0.40178799629211426f, 0.44139501452445984f, 0.47875601053237915f, 0.51375597715377808f, 0.54635101556777954f, 0.57658302783966064f, 0.60447400808334351f, 0.63009101152420044f, 0.65352898836135864f, 0.67488902807235718f, 0.00001858420000644f, 0.0002227969962405f, 0.00124967005103827f, 0.00435766018927097f, 0.01113030035048723f, 0.0229835007339716f, 0.04079980030655861f, 0.06477940082550049f, 0.09447769820690155f, 0.12897300720214844f, 0.16708999872207642f, 0.20760199427604675f, 0.24936899542808533f, 0.29154899716377258f, 0.3332040011882782f, 0.37377101182937622f, 0.41274300217628479f, 0.44977998733520508f, 0.4846780002117157f, 0.51733100414276123f, 0.54769200086593628f, 0.57572799921035767f, 0.6014779806137085f, 0.62501102685928345f, 1.46482000218384201e-06f, 0.00003429050047998f, 0.0002985020109918f, 0.00140504003502429f, 0.00443577999249101f, 0.01069260016083717f, 0.02133879996836185f, 0.0371410995721817f, 0.05836030095815659f, 0.08476380258798599f, 0.11572299897670746f, 0.1503559947013855f, 0.18766500055789948f, 0.22665500640869141f, 0.26647698879241943f, 0.30632400512695312f, 0.34550899267196655f, 0.38344401121139526f, 0.41970700025558472f, 0.45401400327682495f, 0.48618701100349426f, 0.51614201068878174f, 0.54384201765060425f, 0.56930899620056152f, 5.83937982412408019e-08f, 3.2765999549155822e-06f, 0.00005055400106357f, 0.00035111699253321f, 0.00145683996379375f, 0.00427943980321288f, 0.0098936902359128f, 0.01927389949560165f, 0.03310279920697212f, 0.05168719962239265f, 0.07495570182800293f, 0.10250899940729141f, 0.13370099663734436f, 0.1677280068397522f, 0.20372100174427032f, 0.24084299802780151f, 0.27840098738670349f, 0.31564199924468994f, 0.35190799832344055f, 0.38674798607826233f, 0.41985601186752319f, 0.45104199647903442f, 0.48021000623703003f, 0.50734001398086548f, 8.73966010672688753e-10f, 1.57741993689342053e-07f, 5.21975016454234719e-06f, 0.00006079579907237f, 0.00036219600588083f, 0.00138045998755842f, 0.00386844994500279f, 0.00871635042130947f, 0.01675550080835819f, 0.02860799990594387f, 0.04461279883980751f, 0.06480839848518372f, 0.08895269781351089f, 0.11656700074672699f, 0.1470009982585907f, 0.17950700223445892f, 0.21331800520420074f, 0.24785000085830688f, 0.28237700462341309f, 0.31631898880004883f, 0.34923198819160461f, 0.38083100318908691f, 0.41094100475311279f, 0.43946701288223267f, 2.8866399288257627e-12f, 2.63671995348602195e-09f, 2.51094007808205788e-07f, 5.97520011069718748e-06f, 0.00005859580051037f, 0.0003192939911969f, 0.00116373994387686f, 0.00319523992948234f, 0.00714873988181353f, 0.0137449000030756f, 0.0235638003796339f, 0.03696820139884949f, 0.05407309904694557f, 0.0747511014342308f, 0.09866459667682648f, 0.12531900405883789f, 0.15412400662899017f, 0.18446199595928192f, 0.21573600172996521f, 0.24741099774837494f, 0.27903899550437927f, 0.310263991355896f, 0.34082499146461487f, 0.37054198980331421f, 6.94488983838260476e-16f, 7.04290011727115584e-12f, 3.21448001550095341e-09f, 2.20180993437679717e-07f, 4.50593006462440826e-06f, 0.00004154839916737f, 0.00022262999846134f, 0.00081575999502093f, 0.00227530999109149f, 0.00519366981461644f, 0.01020010001957417f, 0.0178545992821455f, 0.02856850065290928f, 0.04256030172109604f, 0.05984469875693321f, 0.08025020360946655f, 0.10345599800348282f, 0.12904399633407593f, 0.15654699504375458f, 0.1854960024356842f, 0.21545499563217163f, 0.24603499472141266f, 0.27690801024436951f, 0.3078019917011261f, 5.46278023199234311e-22f, 3.43167987041791307e-16f, 2.29294990113093622e-12f, 9.57796952860689998e-10f, 6.87986982939037262e-08f, 1.5533599935224629e-06f, 0.00001600819996384f, 0.00009555240103509f, 0.00038631301140413f, 0.00117554003372788f, 0.00289549003355205f, 0.00607588002458215f, 0.01126710046082735f, 0.01896269991993904f, 0.02954130060970783f, 0.04323289915919304f, 0.06011129915714264f, 0.0801049992442131f, 0.10301999747753143f, 0.12857000529766083f, 0.15640300512313843f, 0.18612800538539886f, 0.21734000742435455f, 0.24963200092315674f, 0.0f, 0.0f, 3.09890004335006815e-24f, 2.21276004416278673e-18f, 2.67358004631774657e-14f, 2.24439997836833882e-11f, 3.13075010360819306e-09f, 1.26480998119404831e-07f, 2.12951999856159091e-06f, 0.00001907769910758f, 0.00010753999958979f, 0.00042892698547803f, 0.00131604995112866f, 0.00330013991333544f, 0.00707077002152801f, 0.01337909977883101f, 0.02291939966380596f, 0.03622379899024963f, 0.05359359830617905f, 0.07507230341434479f, 0.10045900195837021f, 0.12935000658035278f, 0.16119599342346191f, 0.19536399841308594f
} };
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

static __device__ ViewTerms ViewTerms_x24init_0(float3  v_3, float3  n_i_7, AnisotropicFrame * frame_1, float3  scale_1, float sheen_component_0, float3  sheen_1, float3  view_1, float3  rebounce_0, float toon_view_1, float3  toon_axis_1)
{
    ViewTerms _S610;
    (&_S610)->v = v_3;
    (&_S610)->n_i = n_i_7;
    (&_S610)->frame = *frame_1;
    (&_S610)->scale = scale_1;
    (&_S610)->sheen_component = sheen_component_0;
    (&_S610)->sheen = sheen_1;
    (&_S610)->view = view_1;
    (&_S610)->rebounce = rebounce_0;
    (&_S610)->toon_view = toon_view_1;
    (&_S610)->toon_axis = toon_axis_1;
    return _S610;
}

__device__ __forceinline__ ViewTerms precomputeView(float3  in_dir_5, float3  n_8, BSDFMaterial material_13, MaterialTerms terms_5)
{
    float3  _S611 = negate_0(in_dir_5);
    float _S612 = sign_0(dot_0(n_8, _S611));
    float3  _S613 = n_8 * make_float3 (_S612);
    AnisotropicFrame _S614 = anisotropicFrame(material_13, _S613);
    float3  _S615 = make_float3 (1.0f);
    float3  _S616 = make_float3 (0.0f);
    float _S617 = rgb_to_greyscale(material_13.sheen);
    bool _S618 = _S617 > 0.0f;
    float sheen_component_1;
    float3  sheen_2;
    float3  view_2;
    float3  scale_2;
    if(_S618)
    {
        float _S619 = clamp_1((F32_sqrt(((F32_max((dot_0(_S613, _S611)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S620 = (U32_min((uint(_S619)), (22U)));
        float least_0 = (F32_sqrt((0.05000000074505806f)));
        float _S621 = (F32_sqrt((0.10000000149011612f)));
        bool _S622 = (material_13.velvet) > 0.0f;
        float _S623 = _slang_select(_S622, _S621,least_0);
        float _S624 = (clamp_1((F32_sqrt(((F32_max((material_13.sheen_roughness), (0.0f)))))), _S623, 1.0f) - _S623) / (1.0f - _S623) * 23.0f;
        uint _S625 = (U32_min((uint(_S624)), (22U)));
        uint _S626 = _S620 * 24U + _S625;
        float _S627 = _S619 - float(_S620);
        float _S628 = _S624 - float(_S625);
        uint _S629 = _S626 + 24U;
        float a_5 = SHEEN_ALBEDO_0[_S626] + (SHEEN_ALBEDO_0[_S629] - SHEEN_ALBEDO_0[_S626]) * _S627;
        uint _S630 = _S626 + 1U;
        uint _S631 = _S629 + 1U;
        float b_1 = SHEEN_ALBEDO_0[_S630] + (SHEEN_ALBEDO_0[_S631] - SHEEN_ALBEDO_0[_S630]) * _S627;
        float _S632 = (F32_exp((a_5 + (b_1 - a_5) * _S628)));
        if(_S622)
        {
            float a_6 = VELVET_ALBEDO_0[_S626] + (VELVET_ALBEDO_0[_S629] - VELVET_ALBEDO_0[_S626]) * _S627;
            float b_2 = VELVET_ALBEDO_0[_S630] + (VELVET_ALBEDO_0[_S631] - VELVET_ALBEDO_0[_S630]) * _S627;
            float _S633 = a_6 + (b_2 - a_6) * _S628;
            sheen_component_1 = _S633;
        }
        else
        {
            sheen_component_1 = _S632;
        }
        float _S634 = (F32_min((sheen_component_1), (1.0f)));
        float3  _S635 = make_float3 (1.0f) - material_13.sheen * make_float3 (_S634);
        float _S636 = rgb_to_greyscale(material_13.sheen);
        float _S637 = _S636 * _S634;
        float3  _S638 = material_13.sheen / make_float3 ((F32_max((sheen_component_1), (1.0f))));
        sheen_component_1 = _S637;
        sheen_2 = _S638;
        view_2 = _S611;
        scale_2 = _S635;
    }
    else
    {
        sheen_component_1 = 0.0f;
        sheen_2 = _S616;
        view_2 = _S616;
        scale_2 = _S615;
    }
    float3  scale_3 = scale_2 * make_float3 (terms_5.toon_scale);
    bool _S639 = (F32_abs((material_13.toon.x))) > 0.0f;
    float toon_view_2;
    float3  toon_axis_2;
    if(_S639)
    {
        float _S640 = dot_0(_S613, _S611);
        float _S641 = (F32_acos(((F32_min((_S640), (1.0f))))));
        if(_S641 < (terms_5.toon_a))
        {
            toon_view_2 = 1.0f;
        }
        else
        {
            toon_view_2 = (F32_max((1.0f - (_S641 - terms_5.toon_a) / (F32_max((terms_5.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        if(terms_5.toon_glossy)
        {
            float3  _S642 = make_float3 (2.0f * _S640) * _S613 - _S611;
            float3  _S643 = ((((_S642)) * make_float3(rnorm3df(((_S642)).x, ((_S642)).y, ((_S642)).z))));
            scale_2 = _S643;
        }
        else
        {
            scale_2 = _S613;
        }
        toon_axis_2 = scale_2;
    }
    else
    {
        toon_view_2 = 0.0f;
        toon_axis_2 = _S613;
    }
    float _S644 = _S614.alphas.x;
    float _S645 = (F32_sqrt(((F32_min((_S644), (_S614.alphas.y))))));
    bool _S646 = _S644 > 0.0f;
    float _S647 = _slang_select(_S646, _S645,material_13.roughness);
    float _S648 = _S647 * _S647;
    float _S649 = (F32_pow((_S648), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S648) / (1.0f + 1.28094995021820068f * _S648);
    bool _S650 = _S648 > 0.0f;
    float _S651 = _slang_select(_S650, _S649,0.0f);
    float _S652 = clamp_1(dot_0(_S613, _S611), 0.0f, 1.0f);
    float _S653 = _S648 * _S647;
    float _S654 = (F32_min((1.00064504146575928f - _S647 * (0.00375499995425344f + _S652 * (-0.04133399948477745f + _S652 * (-0.90938502550125122f + _S652 * 0.35275399684906006f))) - _S648 * (0.27602800726890564f + _S652 * (1.27023398876190186f + _S652 * 0.04740000143647194f)) - _S653 * (0.31452900171279907f - _S652 * 0.34830701351165771f) + _S653 * _S647 * 0.27229699492454529f), (1.0f)));
    float3  _S655 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_13.albedo * make_float3 (_S651)), make_float3 (1.0f / (F32_max((_S654), (0.0000152587890625f)))));
    AnisotropicFrame _S656 = _S614;
    ViewTerms _S657 = ViewTerms_x24init_0(_S611, _S613, &_S656, scale_3, sheen_component_1, sheen_2, view_2, _S655, toon_view_2, toon_axis_2);
    return _S657;
}

static __device__ float3  Unseen_seen_0(uint lobe_1)
{
    return make_float3 (1.0f);
}

static __device__ float3  neeLobes_1(float3  in_dir_6, float3  dir_6, float3  n_9, BSDFMaterial * material_14, float eta_i_12, float eta_o_12, bool refracted_3, float pdf_2, bool power_2, uint random_state_5, MaterialTerms * terms_6, ViewTerms * view_terms_5)
{
    float3  _S658 = negate_0(in_dir_6);
    float _S659 = dot_0(n_9, _S658);
    float _S660 = sign_0(_S659);
    float3  _S661 = n_9 * make_float3 (_S660);
    float _S662 = dot_0(_S661, dir_6);
    float _S663 = material_14->roughness * material_14->roughness;
    float3  f_8 = make_float3 (0.0f);
    float _S664 = rgb_to_greyscale(material_14->translucent);
    bool _S665 = _S664 > 0.0f;
    bool _S666;
    if(_S665)
    {
        float _S667 = dot_0(n_9, dir_6);
        float3  _S668 = negate_0(in_dir_6);
        _S666 = ((_S667 * dot_0(n_9, _S668)) < 0.0f) == refracted_3;
    }
    else
    {
        _S666 = !refracted_3;
    }
    bool _S669 = !refracted_3;
    bool _S670;
    if(_S669)
    {
        _S670 = (F32_abs((material_14->toon.x))) > 0.0f;
    }
    else
    {
        _S670 = false;
    }
    HalfTerms _S671 = HalfTerms_x24init_0(0.0f, 0.0f, f_8, f_8, 0.0f, 0.0f, f_8, f_8, 0.0f, 0.0f, 0.0f, 0.0f, f_8, 0.0f, f_8, f_8, make_float2 (0.0f), 0.0f, 0.0f, f_8, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, f_8);
    bool _S672;
    if(_S666)
    {
        _S672 = true;
    }
    else
    {
        _S672 = _S670;
    }
    HalfTerms sampled_1;
    if(_S672)
    {
        HalfTerms _S673 = sampledHalf(in_dir_6, n_9, *material_14, eta_i_12, eta_o_12, random_state_5, *terms_6, *view_terms_5);
        sampled_1 = _S673;
    }
    else
    {
        sampled_1 = _S671;
    }
    float3  f_9;
    if(_S666)
    {
        float _S674 = diffusePDF(_S662, 0.0f, (F32_abs((_S659))), _S663, sampled_1, eta_i_12, eta_o_12);
        bool _S675 = _S674 > 0.0f;
        if(_S675)
        {
            float3  _S676 = diffuseBSDF(dir_6, _S661, _S663, *material_14, sampled_1);
            float3  _S677 = misWeighted(_S676, _S674, pdf_2, power_2);
            float3  _S678 = Unseen_seen_0(0U);
            float3  _S679 = _S677 * _S678;
            f_9 = _S679;
        }
        else
        {
            f_9 = f_8;
        }
    }
    else
    {
        f_9 = f_8;
    }
    if(refracted_3)
    {
        float l_dot_h_7 = 0.0f;
        HalfTerms _S680 = refractedHalf(in_dir_6, dir_6, n_9, *material_14, eta_i_12, eta_o_12, *terms_6, *view_terms_5, &l_dot_h_7);
        float _S681 = refractPDF(_S662, l_dot_h_7, (F32_abs((_S659))), _S663, _S680, eta_i_12, eta_o_12);
        bool _S682 = _S681 > 0.0f;
        if(_S682)
        {
            float3  _S683 = refractBSDF(dir_6, _S661, _S663, *material_14, _S680);
            float3  _S684 = misWeighted(_S683, _S681, pdf_2, power_2);
            float3  _S685 = Unseen_seen_0(1U);
            float3  f_10 = f_9 + _S684 * _S685;
            f_9 = f_10;
        }
    }
    else
    {
        HalfTerms _S686 = reflectedHalf(in_dir_6, dir_6, *material_14, eta_i_12, eta_o_12, *terms_6, *view_terms_5);
        float _S687 = (F32_abs((_S659)));
        float _S688 = reflectPDF(_S662, 0.0f, _S687, _S663, _S686, eta_i_12, eta_o_12);
        bool _S689 = _S688 > 0.0f;
        if(_S689)
        {
            float3  _S690 = reflectBSDF(dir_6, _S661, _S663, *material_14, _S686);
            float3  _S691 = misWeighted(_S690, _S688, pdf_2, power_2);
            float3  _S692 = Unseen_seen_0(2U);
            float3  f_11 = f_9 + _S691 * _S692;
            f_9 = f_11;
        }
        float _S693 = sheenVelvetPDF(_S662, 0.0f, _S687, _S663, _S686, eta_i_12, eta_o_12);
        bool _S694 = _S693 > 0.0f;
        if(_S694)
        {
            float3  _S695 = sheenVelvetBSDF(dir_6, _S661, _S663, *material_14, _S686);
            float3  _S696 = misWeighted(_S695, _S693, pdf_2, power_2);
            float3  _S697 = Unseen_seen_0(4U);
            float3  f_12 = f_9 + _S696 * _S697;
            f_9 = f_12;
        }
    }
    if(_S670)
    {
        float _S698 = toonPDF(_S662, dot_0(dir_6, sampled_1.toon_axis), (F32_abs((_S659))), _S663, sampled_1, eta_i_12, eta_o_12);
        bool _S699 = _S698 > 0.0f;
        if(_S699)
        {
            float3  _S700 = toonBSDF(dir_6, _S661, _S663, *material_14, sampled_1);
            float3  _S701 = misWeighted(_S700, _S698, pdf_2, power_2);
            float3  _S702 = Unseen_seen_0(6U);
            float3  f_13 = f_9 + _S701 * _S702;
            f_9 = f_13;
        }
    }
    return f_9;
}

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_7, float3  dir_7, float3  n_10, BSDFMaterial material_15, float eta_i_13, float eta_o_13, bool refracted_4, float pdf_3, bool power_3, uint random_state_6, MaterialTerms terms_7, ViewTerms view_terms_6)
{
    BSDFMaterial _S703 = material_15;
    MaterialTerms _S704 = terms_7;
    ViewTerms _S705 = view_terms_6;
    float3  _S706 = neeLobes_1(in_dir_7, dir_7, n_10, &_S703, eta_i_13, eta_o_13, refracted_4, pdf_3, power_3, random_state_6, &_S704, &_S705);
    return _S706;
}

__device__ float3  skyBSDF(float3  in_dir_8, float3  dir_8, FKSurface surface_1, float2  eta_1, bool is_inside_2, float pdf_4, uint random_state_7)
{
    bool _S707 = wrongSide_0(is_inside_2, false, dir_8, surface_1.geometry_n);
    float _S708 = eta_1.x;
    float _S709 = eta_1.y;
    MaterialTerms _S710 = precomputeMaterial(surface_1.material, _S708, _S709);
    ViewTerms _S711 = precomputeView(in_dir_8, surface_1.smooth_n, surface_1.material, _S710);
    float3  _S712 = neeBSDF(in_dir_8, dir_8, surface_1.smooth_n, surface_1.material, _S708, _S709, _S707, pdf_4, false, random_state_7, _S710, _S711);
    return _S712;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_9, float3  radiance_0, float3  color_0, uint random_state_8)
{
    SkySample _S713;
    (&_S713)->dir = dir_9;
    (&_S713)->radiance = radiance_0;
    (&_S713)->color = color_0;
    (&_S713)->random_state = random_state_8;
    return _S713;
}

static __device__ __noinline__ float3  skyColor_0(float3  in_dir_9, float3  dir_10, FKSurface * surface_2, float2  eta_2, bool is_inside_3, float pdf_5, uint random_state_9, uint depth_2)
{
    bool _S714 = wrongSide_0(is_inside_3, false, dir_10, surface_2->geometry_n);
    float3  _S715 = surface_2->smooth_n;
    BSDFMaterial _S716 = surface_2->material;
    float _S717 = eta_2.x;
    float _S718 = eta_2.y;
    MaterialTerms _S719 = precomputeMaterial(surface_2->material, _S717, _S718);
    ViewTerms _S720 = precomputeView(in_dir_9, _S715, _S716, _S719);
    SkyWorld_0 _S721 = SkyWorld_x24init_0(dir_10, depth_2);
    MaterialTerms _S722 = _S719;
    ViewTerms _S723 = _S720;
    SkyWorld_0 _S724 = _S721;
    float3  _S725 = neeLobes_0(in_dir_9, dir_10, _S715, &surface_2->material, _S717, _S718, _S714, pdf_5, false, random_state_9, &_S722, &_S723, &_S724);
    return _S725;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S726 = (fcptEnvironmentCdfSize());
    uint2  _S727 = make_uint2 (1U, 0U);
    uint2  _S728 = _S726 - _S727;
    Random _S729 = pcg(init_random_state_0);
    Random _S730 = pcg(_S729.state);
    Random _S731 = pcg(_S730.state);
    Random _S732 = pcg(_S731.state);
    uint _S733 = _S728.x;
    uint _S734 = searchCDF_0(make_uint2 (_S733, 0U), make_uint2 (0U, 1U), _S728.y, _S729.value);
    uint _S735 = searchCDF_0(make_uint2 (0U, _S734), _S727, _S733, _S730.value);
    float2  _S736 = make_float2 ((float)_S728.x, (float)_S728.y);
    float2  _S737 = (make_float2 (float(_S735), float(_S734)) + make_float2 (_S731.value, _S732.value)) / _S736 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S738 = _S737.y;
    float _S739 = (F32_sin((_S738)));
    float _S740 = _S737.x;
    float3  _S741 = make_float3 (- _S739 * (F32_cos((_S740))), _S739 * (F32_sin((_S740))), (F32_cos((_S738))));
    float _S742 = environmentPdf_0(_S741);
    float3  _S743 = ray_0->unit_direction;
    float3  _S744 = skyBSDF(ray_0->unit_direction, _S741, *surface_3, eta_3, is_inside_4, _S742, lobe_state_0);
    bool _S745 = !(_S742 > 0.0f);
    bool _S746;
    if(_S745)
    {
        _S746 = true;
    }
    else
    {
        _S746 = all_1(_S744 == make_float3 (0.0f));
    }
    if(_S746)
    {
        float3  _S747 = make_float3 (0.0f);
        return SkySample_x24init_0(_S741, _S747, _S747, _S732.state);
    }
    bool _S748 = (fcptWorldReadsPath());
    float3  seen_0;
    if(_S748)
    {
        float3  _S749 = skyColor_0(_S743, _S741, surface_3, eta_3, is_inside_4, _S742, lobe_state_0, context_2->depth + 1U);
        seen_0 = _S749;
    }
    else
    {
        seen_0 = _S744;
    }
    float3  _S750 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S741, context_2, _S732.state);
    return SkySample_x24init_0(_S741, _S750, seen_0 * _S750, _S732.state);
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

static __device__ float3  hairLight_0(FKSurface * surface_4, float3  in_dir_10, TreeSample * light_1, bool competing_0)
{
    SampleBSDF _S751 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_10), (light_1->dir)));
    float3  _S752 = _S751.throughput * make_float3 (_S751.pdf);
    float _S753 = light_1->density;
    float _S754 = 1.0f + _S751.pdf * _S751.pdf / (light_1->density * light_1->density);
    bool _S755;
    if(competing_0)
    {
        _S755 = _S753 > 0.0f;
    }
    else
    {
        _S755 = false;
    }
    float _S756 = _slang_select(_S755, _S754,1.0f);
    return _S752 / make_float3 (_S756) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_11, float3  radiance_1, float density_0, uint random_state_10)
{
    TreeSample _S757;
    (&_S757)->dir = dir_11;
    (&_S757)->radiance = radiance_1;
    (&_S757)->density = density_0;
    (&_S757)->random_state = random_state_10;
    return _S757;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S758 = importance(first_1, p_12, normal_3);
    float _S759 = importance(second_1, p_12, normal_3);
    float2  _S760 = make_float2 (_S758, _S759);
    bool _S761 = _S758 == 0.0f;
    bool _S762;
    if(_S761)
    {
        _S762 = _S759 == 0.0f;
    }
    else
    {
        _S762 = false;
    }
    if(_S762)
    {
        return 2U;
    }
    float _S763 = _S758 + _S759;
    bool _S764 = _S759 > 0.0f;
    if(_S764)
    {
        _S762 = (*pick_0 * _S763) >= _S758;
    }
    else
    {
        _S762 = false;
    }
    uint _S765 = uint(_S762);
    float _S766 = (F32_min(((*pick_0 * _S763 - float(_S765) * _S758) / _slang_vector_get_element(_S760, _S765)), (0.99999994039535522f)));
    *pick_0 = _S766;
    float _S767 = *probability_3 * (_slang_vector_get_element(_S760, _S765) / _S763);
    *probability_3 = _S767;
    return _S765;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S768 = center_1 - p_13;
    float _S769 = radius_1 * radius_1 / dot_0(_S768, _S768);
    float _S770 = u1_0 * _S769 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S769), (0.0f)))))));
    float _S771 = 2.0f * u1_0;
    bool _S772 = _S769 >= 1.0f;
    float _S773 = _slang_select(_S772, _S771,_S770);
    float _S774 = (F32_sqrt(((F32_max((_S773 * (2.0f - _S773)), (0.0f))))));
    float _S775 = 6.28318548202514648f * u2_0;
    float3  _S776 = make_float3 (_S774 * (F32_cos((_S775))), 1.0f - _S773, _S774 * (F32_sin((_S775))));
    float3  _S777 = ((((_S768)) * make_float3(rnorm3df(((_S768)).x, ((_S768)).y, ((_S768)).z))));
    float3  _S778 = tangentToWorld(_S776, _S777);
    return _S778;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S779 = center_2 - ray_1->origin;
    float _S780 = dot_0(_S779, ray_1->unit_direction);
    float _S781 = dot_0(_S779, _S779) - _S780 * _S780;
    float _S782 = radius_3 * radius_3;
    bool _S783 = _S781 > _S782;
    if(_S783)
    {
        return 4.294967296e+09f;
    }
    float _S784 = (F32_sqrt((_S782 - _S781)));
    float _S785 = _S780 - _S784;
    float _S786 = _S780 + _S784;
    bool _S787 = _S785 > 0.0000152587890625f;
    bool _S788;
    if(_S787)
    {
        _S788 = _S785 < max_len_0;
    }
    else
    {
        _S788 = false;
    }
    if(_S788)
    {
        return _S785;
    }
    bool _S789 = _S786 > 0.0000152587890625f;
    if(_S789)
    {
        _S788 = _S786 < max_len_0;
    }
    else
    {
        _S788 = false;
    }
    if(_S788)
    {
        return _S786;
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
        int i_7 = int(0);
        float sum_0 = 0.0f;
        for(;;)
        {
            if(i_7 < int(3))
            {
            }
            else
            {
                break;
            }
            float sum_1 = sum_0 + _slang_vector_get_element(left_1, i_7) * _slang_vector_get_element(right_1.rows[i_7], j_1);
            i_7 = i_7 + int(1);
            sum_0 = sum_1;
        }
        *_slang_vector_get_element_ptr(&result_6, j_1) = sum_0;
        j_1 = j_1 + int(1);
    }
    return result_6;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S790 = pcg(init_random_state_1);
    Random _S791 = pcg(_S790.state);
    Random _S792 = pcg(_S791.state);
    float3  _S793 = make_float3 (0.0f);
    TreeSample _S794 = TreeSample_x24init_0(_S793, _S793, 0.0f, _S792.state);
    TreeSample sample_0 = _S794;
    float3  _S795 = _slang_select(sided_0, _S793,smooth_n_2);
    float3  _S796 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S790.value;
    float probability_4 = 1.0f;
    uint n_11 = 0U;
    for(;;)
    {
        uint4  _S797 = (fcptLightNode((n_11)));
        if((_S797.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S798 = (fcptLightSecond((n_11)));
        uint _S799 = n_11 + 1U;
        LightNode _S800 = (fcptLightBounds((_S799)));
        LightNode _S801 = (fcptLightBounds((_S798)));
        uint _S802 = pickChild(_S800, _S801, origin_4, _S795, &pick_1, &probability_4);
        bool _S803 = _S802 > 1U;
        if(_S803)
        {
            return sample_0;
        }
        bool _S804 = _S802 == 1U;
        uint _S805 = _slang_select(_S804, _S798,_S799);
        n_11 = _S805;
    }
    bool _S806 = n_11 == 0U;
    bool _S807;
    if(_S806)
    {
        LightNode _S808 = (fcptLightBounds((0U)));
        float _S809 = importance(_S808, origin_4, _S795);
        _S807 = !(_S809 > 0.0f);
    }
    else
    {
        _S807 = false;
    }
    if(_S807)
    {
        return sample_0;
    }
    uint4  _S810 = (fcptLightNode((n_11)));
    FKHit _S811 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S812 = (_S810.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S812)
    {
        FKLight _S813 = (fcptLight((_S810.y)));
        if(sided_0)
        {
            float _S814 = sign_0(dot_0(geometry_n_1, _S813.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S814);
            float3  _S815 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S815;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S796;
            lift_n_0 = smooth_n_2;
        }
        bool _S816 = (_S813.variance) == 0.0f;
        if(_S816)
        {
            float3  _S817 = _S813.position - emitter_point_0;
            float3  _S818 = ((((_S817)) * make_float3(rnorm3df(((_S817)).x, ((_S817)).y, ((_S817)).z))));
            (&sample_0)->dir = _S818;
            float3  _S819 = _S813.color * make_float3 (_S813.intensity) / make_float3 (dot_0(_S817, _S817) * probability_4);
            (&sample_0)->radiance = _S819;
            shadow_1 = _S817;
        }
        else
        {
            float3  _S820 = sampleSphere(_S813.position, _S813.variance, emitter_point_0, _S791.value, _S792.value);
            (&sample_0)->dir = _S820;
            float _S821 = sphereDensity(_S813.position, _S813.variance, emitter_point_0);
            float _S822 = probability_4 * _S821;
            (&sample_0)->density = _S822;
            float3  _S823 = pointLightRadiance(_S813.color, _S813.intensity, _S813.variance);
            float3  _S824 = _S823 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S824;
            FKRay _S825 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S826 = raySphere_0(_S813.position, _S813.variance, &_S825, 4.294967296e+09f);
            float3  _S827 = (&sample_0)->dir * make_float3 (_S826);
            shadow_1 = _S827;
        }
        emitter_0 = _S811;
        emitter_point_0 = _S793;
    }
    else
    {
        uint _S828 = _S810.y;
        uint _S829 = (fcptTriangleOffset((_S828)));
        uint _S830 = _S829 + _S810.z;
        Matrix<float, 3, 3>  _S831 = (fcptWorldTriangle((_S828), (_S830)));
        float _S832 = (F32_sqrt((_S791.value)));
        float2  _S833 = make_float2 (_S832 * (1.0f - _S792.value), _S832 * _S792.value);
        float3  _S834 = mul_0(make_float3 (1.0f - _S832, _S833.x, _S833.y), _S831);
        if(sided_0)
        {
            float _S835 = sign_0(dot_0(geometry_n_1, _S834 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S835);
            float3  _S836 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S836;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S837 = !((dot_0(smooth_n_2, _S834 - origin_4)) > 0.0f);
            if(_S837)
            {
                return sample_0;
            }
            emitter_point_0 = _S796;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S833, _S828, _S830, 0U, 0.0f);
        float3  _S838 = _S834 - emitter_point_0;
        float3  _S839 = ((((_S838)) * make_float3(rnorm3df(((_S838)).x, ((_S838)).y, ((_S838)).z))));
        (&sample_0)->dir = _S839;
        float _S840 = solidAngle(probability_4, cross_0(_S831.rows[int(1)] - _S831.rows[int(0)], _S831.rows[int(2)] - _S831.rows[int(0)]), _S838);
        (&sample_0)->density = _S840;
        bool _S841 = (fcptShadowFirst());
        bool _S842 = !_S841;
        if(_S842)
        {
            FKSurface _S843 = (fcptLightSurfaceAt((emitter_1), (_S834), (_S792.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S834 - origin_4))));
            (&sample_0)->random_state = _S843.random_state;
            float3  _S844 = _slang_select(_S843.skip, _S793,_S843.material.emissive);
            float3  _S845 = _S844 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S845;
        }
        shadow_1 = _S838;
        emitter_0 = emitter_1;
        emitter_point_0 = _S834;
    }
    FKHit _S846 = emitter_0;
    float3  _S847 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S792.state, &_S846);
    bool _S848 = (fcptShadowFirst());
    if(_S848)
    {
        _S807 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S807 = false;
    }
    if(_S807)
    {
        _S807 = !all_1(_S847 == _S793);
    }
    else
    {
        _S807 = false;
    }
    if(_S807)
    {
        FKSurface _S849 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S792.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S849.random_state;
        float3  _S850 = _slang_select(_S849.skip, _S793,_S849.material.emissive);
        float3  _S851 = _S850 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S851;
    }
    float3  _S852 = (&sample_0)->radiance * _S847;
    bool _S853 = all_1(_S847 == _S793);
    float3  _S854 = _slang_select(_S853, _S793,_S852);
    (&sample_0)->radiance = _S854;
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
    float _S855 = 1.0f / (1.0f + b_3 / a_7 * (b_3 / a_7));
    bool _S856 = b_3 > 0.0f;
    float _S857 = _slang_select(_S856, _S855,1.0f);
    return _S857;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S858 = vertex_0->none;
    if(_S858)
    {
        return 1.0f;
    }
    uint _S859 = (fcptLightSlot((*hit_1)));
    float _S860 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S859, light_point_1);
    float _S861 = powerHeuristic(vertex_0->pdf, _S860);
    return _S861;
}

static __device__ float3  environment_0(float3  dir_12, uint depth_3, uint lobe_2)
{
    uint2  _S862 = (fcptEnvironmentMapSize());
    bool _S863 = (_S862.x) > 1U;
    bool _S864;
    if(_S863)
    {
        uint2  _S865 = (fcptEnvironmentMapSize());
        _S864 = (_S865.y) > 1U;
    }
    else
    {
        _S864 = false;
    }
    if(_S864)
    {
        float3  _S866 = (fcptEnvMapSample((dir_12), (depth_3), (lobe_2)));
        return _S866;
    }
    float3  _S867 = (fcptAmbient());
    return _S867;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S868 = (fcptEnvironmentCdfSize());
    bool _S869 = (_S868.x) > 1U;
    bool _S870;
    if(_S869)
    {
        uint2  _S871 = (fcptEnvironmentCdfSize());
        _S870 = (_S871.y) > 1U;
    }
    else
    {
        _S870 = false;
    }
    bool _S872 = !_S870;
    if(_S872)
    {
        return false;
    }
    uint2  _S873 = (fcptEnvironmentMapSize());
    bool _S874 = (_S873.x) > 1U;
    if(_S874)
    {
        uint2  _S875 = (fcptEnvironmentMapSize());
        _S870 = (_S875.y) > 1U;
    }
    else
    {
        _S870 = false;
    }
    return _S870;
}

static __device__ float escapeWeight_0(float pdf_6, float3  dir_13)
{
    bool _S876 = pdf_6 <= 0.0f;
    bool _S877;
    if(_S876)
    {
        _S877 = true;
    }
    else
    {
        bool _S878 = environmentMapped_0();
        _S877 = !_S878;
    }
    if(_S877)
    {
        return 1.0f;
    }
    float _S879 = environmentPdf_0(dir_13);
    return pdf_6 / (pdf_6 + _S879);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S880 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S881 = make_int2 ((int)_S880.x, (int)_S880.y);
    uint _S882 = previousSeed_0(_S881);
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
            uint _S883 = previousSeed_0(_S881 + make_int2 (x_16, y_5));
            bool _S884 = _S883 == _S882;
            uint _S885 = _slang_select(_S884, 1U,0U);
            uint count_3 = count_2 + _S885;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S886 = float(count_2 - 1U) / 288.0f;
    bool _S887 = _S882 != 0U;
    float _S888 = _slang_select(_S887, _S886,0.0f);
    fcptStoreDuplication((_S881), (make_uint4 ((F32_asuint((_S888))), 0U, 0U, 0U)));
    return;
}

static __device__ float3  abs_0(float3  x_18)
{
    float3  result_7;
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
        *_slang_vector_get_element_ptr(&result_7, i_8) = (F32_abs((_slang_vector_get_element(x_18, i_8))));
        i_8 = i_8 + int(1);
    }
    return result_7;
}

__device__ float resamplingTarget(float3  f_14)
{
    float _S889 = rgb_to_greyscale(abs_0(f_14));
    return _S889;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S890 = hash(index_0);
    uint _S891 = hash(seed_3 ^ _S890);
    return _S891;
}

static __device__ float4  asfloat_0(uint4  x_19)
{
    float4  result_8;
    int i_9 = int(0);
    for(;;)
    {
        if(i_9 < int(4))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_8, i_9) = (U32_asfloat((_slang_vector_get_element(x_19, i_9))));
        i_9 = i_9 + int(1);
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
    float _S892 = resamplingTarget(weight_0);
    bool _S893 = _S892 > 0.0f;
    bool _S894;
    if(_S893)
    {
        _S894 = _S892 < 3.00000000549775576e+38f;
    }
    else
    {
        _S894 = false;
    }
    bool _S895 = !_S894;
    if(_S895)
    {
        return;
    }
    bool _S896 = sel_2->sums;
    if(_S896)
    {
        float3  _S897 = sel_2->color + weight_0;
        sel_2->color = _S897;
        return;
    }
    float _S898 = sel_2->w_sum + _S892;
    sel_2->w_sum = _S898;
    float3  _S899 = sel_2->color + weight_0;
    sel_2->color = _S899;
    Random _S900 = pcg(sel_2->random_state);
    sel_2->random_state = _S900.state;
    bool _S901 = (_S900.value * sel_2->w_sum) <= _S892;
    if(_S901)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S902 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S902;
    float _S903 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S903;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S904 = resamplingTarget((&r_4)->f);
    float _S905 = sel_4.w_sum / _S904;
    bool _S906 = _S904 > 0.0f;
    float _S907 = _slang_select(_S906, _S905,0.0f);
    (&r_4)->w = _S907;
    (&r_4)->c = c_1;
    return r_4;
}

static __device__ uint2  asuint_0(float2  x_20)
{
    uint2  result_9;
    int i_10 = int(0);
    for(;;)
    {
        if(i_10 < int(2))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_9, i_10) = (F32_asuint((_slang_vector_get_element(x_20, i_10))));
        i_10 = i_10 + int(1);
    }
    return result_9;
}

static __device__ void restir_spatial_0(uint3  global_invocation_id_2)
{
    uint2  _S908 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S909 = make_int2 ((int)_S908.x, (int)_S908.y);
    float3  _S910 = make_float3 (0.0f);
    FKHit _S911 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S912 = Domain_x24init_0(_S910, _S910, &_S911, 0.0f, 0.0f);
    Domain dom_4 = _S912;
    bool _S913 = (fcptCurrentDomain((_S909), (&dom_4)));
    bool _S914 = !_S913;
    if(_S914)
    {
        Reservoir _S915 = (Reservoir{});
        fcptStoreReservoirPrevious((_S909), (_S915), ((&dom_4)->hit));
        return;
    }
    Reservoir _S916 = (fcptLoadReservoirTemporal((_S909)));
    uint t_13 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S916.c;
    for(;;)
    {
        uint _S917 = (fcptRestirNeighbours());
        if(t_13 < _S917)
        {
        }
        else
        {
            break;
        }
        int2  _S918 = partner_0(_S909, t_13);
        Domain neighbor_0 = _S912;
        bool _S919 = (fcptCurrentDomain((_S918), (&neighbor_0)));
        if(_S919)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S920 = (fcptReservoirTemporal((_S918), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S920.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_14 = t_13 + 1U;
        t_13 = t_14;
    }
    float _S921 = _S916.c / (F32_max((count_4), (1.0f)));
    float _S922 = resamplingTarget(_S916.f);
    bool _S923 = count_4 == 0.0f;
    float _S924 = _slang_select(_S923, 1.0f,0.0f);
    Selection _S925 = (Selection{});
    Selection sel_5 = _S925;
    uint _S926 = (fcptFrame());
    uint _S927 = hash(_S926);
    uint _S928 = global_invocation_id_2.x;
    uint2  _S929 = (fcptRenderSize());
    uint _S930 = stream(_S927, _S928 + _S929.x * global_invocation_id_2.y);
    uint _S931 = stream(_S930, 195U);
    (&sel_5)->random_state = _S931;
    t_13 = 0U;
    float canonical_mis_0 = _S924;
    for(;;)
    {
        uint _S932 = (fcptRestirNeighbours());
        if(t_13 < _S932)
        {
        }
        else
        {
            break;
        }
        int2  _S933 = partner_0(_S909, t_13);
        Domain neighbor_dom_0 = _S912;
        bool _S934 = (fcptCurrentDomain((_S933), (&neighbor_dom_0)));
        if(_S934)
        {
            Reservoir _S935 = (fcptLoadReservoirTemporal((_S933)));
            uint4  _S936 = (fcptShiftData((_S933), (t_13)));
            float4  _S937 = asfloat_0(_S936);
            uint4  _S938 = (fcptShiftData((_S909), (t_13)));
            float4  _S939 = asfloat_0(_S938);
            float _S940 = pairShare(_S935.c, _S921, c_sum_1);
            bool _S941 = _S922 > 0.0f;
            float canonical_mis_1;
            if(_S941)
            {
                float _S942 = resamplingTarget(float3 {_S939.x, _S939.y, _S939.z});
                float _S943 = canonicalWeight(_S940, _S921, _S922, _S935.c, _S942);
                float canonical_mis_2 = canonical_mis_0 + _S943;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S944 = float3 {_S937.x, _S937.y, _S937.z};
            Shift _S945 = Shift_x24init_0(_S944, _S937.w);
            float _S946 = resamplingTarget(_S935.f);
            float _S947 = resamplingTarget(_S944);
            float _S948 = neighborWeight(_S940, _S935.c, _S946, _S921, _S947);
            offerShifted(&sel_5, _S935, _S945, _S948);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_15 = t_13 + 1U;
        t_13 = t_15;
    }
    offerShifted(&sel_5, _S916, Shift_x24init_0(_S916.f, 1.0f), canonical_mis_0);
    Reservoir _S949 = finalize(sel_5, c_sum_1);
    fcptStoreReservoirPrevious((_S909), (_S949), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S909), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S909), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
    return;
}

static __device__ uint3  asuint_1(float3  x_21)
{
    uint3  result_10;
    int i_11 = int(0);
    for(;;)
    {
        if(i_11 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_10, i_11) = (F32_asuint((_slang_vector_get_element(x_21, i_11))));
        i_11 = i_11 + int(1);
    }
    return result_10;
}

static __device__ void restir_shift_0(uint3  workgroup_id_1, uint local_invocation_index_4)
{
    uint _S950 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S951 = _S950 != 4294967295U;
    if(_S951)
    {
        uint2  _S952 = make_uint2 (_S950, _S950 >> 14U) & make_uint2 (16383U);
        int2  _S953 = make_int2 ((int)_S952.x, (int)_S952.y);
        ShiftJob _S954 = (ShiftJob{});
        ShiftJob shift_job_0 = _S954;
        Shift _S955 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S956 = _S950 >> 28U;
        bool _S957 = spatialJob_0(_S953, _S956, &shift_job_0, true);
        Shift shifted_1;
        if(_S957)
        {
            Domain _S958 = (&shift_job_0)->dom;
            Reservoir _S959 = (&shift_job_0)->r;
            Shift _S960 = passShift_0(&_S958, &_S959);
            shifted_1 = _S960;
        }
        else
        {
            shifted_1 = _S955;
        }
        fcptStoreShiftData((_S953), (_S956), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S961 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S962 = make_int2 ((int)_S961.x, (int)_S961.y);
    FixedArray<uint, 3>  _S963;
    spatialBins_0(_S962, &_S963);
    FixedArray<uint, 3>  _S964 = _S963;
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
        bool _S965 = (_S964[t_16]) == 40U;
        if(_S965)
        {
            fcptStoreShiftData((_S962), (t_16), (make_uint4 (0U)));
        }
        uint t_17 = t_16 + 1U;
        t_16 = t_17;
    }
    FixedArray<uint, 3>  _S966 = _S964;
    queueShifts_0(_S962, &_S966, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S967 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S968 = make_int2 ((int)_S967.x, (int)_S967.y);
    FixedArray<uint, 3>  _S969;
    spatialBins_0(_S968, &_S969);
    FixedArray<uint, 3>  _S970 = _S969;
    countShifts_0(&_S970, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S971 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S972 = _S971 != 4294967295U;
    if(_S972)
    {
        uint2  _S973 = make_uint2 (_S971, _S971 >> 14U) & make_uint2 (16383U);
        int2  _S974 = make_int2 ((int)_S973.x, (int)_S973.y);
        int2  _S975 = (fcptLoadTemporalNeighbor((_S974)));
        uint _S976 = _S971 >> 28U;
        Shift _S977 = temporalShiftAt_0(_S974, _S975, _S976);
        fcptStoreTemporalShift((_S974), (_S976), (make_uint4 (asuint_1(_S977.f).x, asuint_1(_S977.f).y, asuint_1(_S977.f).z, (F32_asuint((_S977.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S978 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S979 = make_int2 ((int)_S978.x, (int)_S978.y);
    FixedArray<uint, 3>  _S980;
    temporalBins_0(_S979, &_S980);
    FixedArray<uint, 3>  _S981 = _S980;
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
        bool _S982 = (_S981[t_18]) == 40U;
        if(_S982)
        {
            fcptStoreTemporalShift((_S979), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S983 = _S981;
    queueShifts_0(_S979, &_S983, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S984 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S985 = make_int2 ((int)_S984.x, (int)_S984.y);
    bool _S986 = (fcptSceneUnchanged());
    bool _S987 = !_S986;
    bool _S988;
    if(_S987)
    {
        uint2  _S989 = (fcptRenderSize());
        int2  _S990 = make_int2 ((int)_S989.x, (int)_S989.y);
        _S988 = all_0(_S985 < _S990);
    }
    else
    {
        _S988 = false;
    }
    if(_S988)
    {
        Reservoir _S991 = (fcptLoadReservoirInitial((_S985)));
        int2  _S992 = sampleNeighbor_0(_S985, _S991.seed);
        fcptStoreTemporalNeighbor((_S985), (_S992));
    }
    FixedArray<uint, 3>  _S993;
    temporalBins_0(_S985, &_S993);
    FixedArray<uint, 3>  _S994 = _S993;
    countShifts_0(&_S994, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_8, float b_4, float t_20)
{
    return a_8 + (b_4 - a_8) * t_20;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S995 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S995;
}

__device__ float2  temporalWeights(float c_2, float p_c_1, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S996 = c_2 * p_c_1;
    float _S997 = c_t_0 * p_t_0;
    return make_float2 (_S996 / (_S996 + c_t_0 * g_previous_0), _S997 / (_S997 + c_2 * g_current_0));
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S998 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S999 = make_int2 ((int)_S998.x, (int)_S998.y);
    float3  _S1000 = make_float3 (0.0f);
    FKHit _S1001 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S1002 = Domain_x24init_0(_S1000, _S1000, &_S1001, 0.0f, 0.0f);
    Domain dom_5 = _S1002;
    bool _S1003 = (fcptCurrentDomain((_S999), (&dom_5)));
    bool _S1004 = !_S1003;
    if(_S1004)
    {
        Reservoir _S1005 = (Reservoir{});
        fcptStoreReservoirTemporal((_S999), (_S1005), ((&dom_5)->hit));
        return;
    }
    Reservoir _S1006 = (fcptLoadReservoirInitial((_S999)));
    bool _S1007 = (fcptTemporalQueued());
    bool _S1008 = (fcptSceneUnchanged());
    bool _S1009;
    if(_S1008)
    {
        _S1009 = true;
    }
    else
    {
        _S1009 = !_S1007;
    }
    int2  _S1010;
    if(_S1009)
    {
        int2  _S1011 = sampleNeighbor_0(_S999, _S1006.seed);
        _S1010 = _S1011;
    }
    else
    {
        int2  _S1012 = (fcptLoadTemporalNeighbor((_S999)));
        _S1010 = _S1012;
    }
    bool _S1013 = (_S1010.x) >= int(0);
    Reservoir r_5;
    if(_S1013)
    {
        Reservoir _S1014 = (fcptLoadReservoirPrevious((_S1010)));
        uint4  _S1015 = (fcptDuplication((_S1010)));
        float _S1016 = (U32_asfloat((_S1015.x)));
        uint _S1017 = (fcptRestirDecorrelation());
        bool _S1018 = _S1017 == 1U;
        float _S1019 = _slang_select(_S1018, _S1016,0.0f);
        float _S1020 = confidenceCap(_S1019);
        float _S1021 = (F32_min((_S1014.c), (_S1020)));
        bool _S1022 = (fcptSceneUnchanged());
        float4  _S1023 = make_float4 (_S1014.f.x, _S1014.f.y, _S1014.f.z, 1.0f);
        bool _S1024 = !_S1022;
        if(_S1024)
        {
            _S1009 = _S1007;
        }
        else
        {
            _S1009 = false;
        }
        float4  to_current_0;
        if(_S1009)
        {
            uint4  _S1025 = (fcptTemporalShift((_S999), (0U)));
            float4  _S1026 = asfloat_0(_S1025);
            to_current_0 = _S1026;
        }
        else
        {
            if(_S1024)
            {
                Shift _S1027 = temporalShiftAt_0(_S999, _S1010, 0U);
                float4  _S1028 = make_float4 (_S1027.f.x, _S1027.f.y, _S1027.f.z, _S1027.jac);
                to_current_0 = _S1028;
            }
            else
            {
                to_current_0 = _S1023;
            }
        }
        Domain own_1 = _S1002;
        if(_S1022)
        {
            _S1009 = true;
        }
        else
        {
            bool _S1029 = (fcptPreviousScenes());
            bool _S1030 = !_S1029;
            if(_S1030)
            {
                _S1009 = (_S1006.w) > 0.0f;
            }
            else
            {
                _S1009 = false;
            }
            if(_S1009)
            {
                bool _S1031 = (fcptStoredDomainInitial((_S999), (_S1006.seed), (&own_1)));
                _S1009 = _S1031;
            }
            else
            {
                _S1009 = false;
            }
            if(_S1009)
            {
                Domain _S1032 = (fcptPreviousDomain((_S1010), (_S1006.seed)));
                Domain _S1033 = _S1032;
                Domain _S1034 = own_1;
                bool _S1035 = sameDomain_0(&_S1033, &_S1034);
                _S1009 = _S1035;
            }
            else
            {
                _S1009 = false;
            }
        }
        float4  _S1036 = make_float4 (_S1006.f.x, _S1006.f.y, _S1006.f.z, 1.0f);
        bool _S1037 = !_S1009;
        if(_S1037)
        {
            _S1009 = _S1007;
        }
        else
        {
            _S1009 = false;
        }
        float4  to_previous_0;
        if(_S1009)
        {
            uint4  _S1038 = (fcptTemporalShift((_S999), (1U)));
            float4  _S1039 = asfloat_0(_S1038);
            to_previous_0 = _S1039;
        }
        else
        {
            if(_S1037)
            {
                Shift _S1040 = temporalShiftAt_0(_S999, _S1010, 1U);
                float4  _S1041 = make_float4 (_S1040.f.x, _S1040.f.y, _S1040.f.z, _S1040.jac);
                to_previous_0 = _S1041;
            }
            else
            {
                to_previous_0 = _S1036;
            }
        }
        float _S1042 = resamplingTarget(_S1006.f);
        float _S1043 = resamplingTarget(_S1014.f);
        Selection _S1044 = (Selection{});
        Selection sel_6 = _S1044;
        uint _S1045 = (fcptFrame());
        uint _S1046 = hash(_S1045);
        uint _S1047 = global_invocation_id_7.x;
        uint2  _S1048 = (fcptRenderSize());
        uint _S1049 = stream(_S1046, _S1047 + _S1048.x * global_invocation_id_7.y);
        uint _S1050 = stream(_S1049, 194U);
        (&sel_6)->random_state = _S1050;
        float4  _S1051 = to_previous_0;
        float _S1052 = resamplingTarget(float3 {_S1051.x, _S1051.y, _S1051.z});
        float4  _S1053 = to_current_0;
        float3  _S1054 = float3 {_S1053.x, _S1053.y, _S1053.z};
        float _S1055 = resamplingTarget(_S1054);
        float2  _S1056 = temporalWeights(_S1006.c, _S1042, _S1021, _S1043, _S1052, _S1055);
        offerShifted(&sel_6, _S1006, Shift_x24init_0(_S1006.f, 1.0f), _S1056.x);
        offerShifted(&sel_6, _S1014, Shift_x24init_0(_S1054, to_current_0.w), _S1056.y);
        Reservoir _S1057 = finalize(sel_6, _S1006.c + _S1021);
        r_5 = _S1057;
    }
    else
    {
        r_5 = _S1006;
    }
    fcptStoreReservoirTemporal((_S999), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1058 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1058 << offset_1))) | ((newbits_0 & _S1058) << offset_1);
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S1059 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S1060 = make_int2 ((int)_S1059.x, (int)_S1059.y);
    float3  _S1061 = make_float3 (0.0f);
    float2  _S1062 = make_float2 (0.0f);
    FKHit _S1063 = Hit_x24init_0(_S1062, 0U, 0U, 0U, 0.0f);
    Domain _S1064 = Domain_x24init_0(_S1061, _S1061, &_S1063, 0.0f, 0.0f);
    Domain dom_6 = _S1064;
    bool _S1065 = (fcptCurrentDomain((_S1060), (&dom_6)));
    bool _S1066 = !_S1065;
    if(_S1066)
    {
        Reservoir _S1067 = (Reservoir{});
        fcptStoreReservoirInitial((_S1060), (_S1067), ((&dom_6)->hit));
        return;
    }
    uint _S1068 = (fcptFrame());
    uint _S1069 = hash(_S1068);
    uint _S1070 = global_invocation_id_8.x;
    uint2  _S1071 = (fcptRenderSize());
    uint _S1072 = global_invocation_id_8.y;
    uint _S1073 = stream(_S1069, _S1070 + _S1071.x * _S1072);
    uint2  _S1074 = (fcptRenderSize());
    uint _S1075 = stream(_S1070 + _S1074.x * _S1072, 512U);
    Selection _S1076 = (Selection{});
    Selection initial_0 = _S1076;
    uint _S1077 = stream(_S1073, 193U);
    (&initial_0)->random_state = _S1077;
    bool _S1078 = (fcptRestirUsed());
    bool _S1079 = !_S1078;
    (&initial_0)->sums = _S1079;
    uint _S1080 = stream(_S1073, 0U);
    (&(&initial_0)->r)->seed = _S1080;
    FKHit _S1081 = Hit_x24init_0(_S1062, 4294967295U, 0U, 0U, 0.0f);
    uint _S1082 = (fcptSamples());
    float _S1083 = 1.0f / float(_S1082);
    FKHit hit_2 = _S1081;
    uint i_12 = 0U;
    float3  seen_1 = _S1061;
    for(;;)
    {
        uint _S1084 = (fcptSamples());
        if(i_12 < _S1084)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1085 = (Reservoir{});
        Reservoir r_6 = _S1085;
        uint _S1086 = stream(_S1073, i_12);
        (&r_6)->seed = _S1086;
        uint _S1087 = (fcptFrame());
        uint _S1088 = (fcptSamples());
        uint _S1089 = _S1087 * _S1088 + i_12;
        uint _S1090 = insertBits_0(0U, 1U, 24U, 1U);
        uint _S1091 = insertBits_0(_S1090, (_S1075 + _S1089 * 2654435769U) >> 25U, 25U, 7U);
        (&r_6)->path = _S1091;
        Domain path_0 = _S1064;
        bool _S1092 = (fcptStoredDomainInitial((_S1060), ((&r_6)->seed), (&path_0)));
        bool _S1093 = !_S1092;
        if(_S1093)
        {
            float3  _S1094 = (fcptMissed((_S1060), (path_0), (_S1083)));
            float3  seen_2 = seen_1 + _S1094;
            seen_1 = seen_2;
            uint i_13 = i_12 + 1U;
            i_12 = i_13;
            continue;
        }
        Domain _S1095 = path_0;
        Reservoir _S1096 = r_6;
        Shift _S1097 = passWalk_0(&_S1095, &_S1096, false, _S1083, &initial_0);
        bool _S1098 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1098)
        {
            FKHit _S1099 = (&path_0)->hit;
            hit_3 = _S1099;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_13 = i_12 + 1U;
        i_12 = i_13;
    }
    uint _S1100 = (fcptSamples());
    float3  seen_3 = seen_1 + (&initial_0)->glow / make_float3 (float(_S1100));
    if((&initial_0)->sums)
    {
        seen_1 = seen_3 + (&initial_0)->color;
    }
    else
    {
        seen_1 = seen_3;
    }
    fcptAddColor((_S1060), (make_float4 (seen_1.x, seen_1.y, seen_1.z, 1.0f)));
    Reservoir _S1101 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S1060), (_S1101), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_7, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1102;
    (&_S1102)->none = none_0;
    (&_S1102)->pdf = pdf_7;
    (&_S1102)->origin = origin_5;
    (&_S1102)->smooth_n = smooth_n_3;
    (&_S1102)->start = start_6;
    return _S1102;
}

struct Vertex
{
    bool rough;
    uint lobe;
    float pdf;
    float cos;
    bool inside;
};

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_3, float pdf_8, float cos_0, bool inside_0)
{
    Vertex _S1103;
    (&_S1103)->rough = rough_0;
    (&_S1103)->lobe = lobe_3;
    (&_S1103)->pdf = pdf_8;
    (&_S1103)->cos = cos_0;
    (&_S1103)->inside = inside_0;
    return _S1103;
}

static __device__ float freeFlight_0(float u_1, float sigma_0)
{
    return - (F32_log((1.0f - u_1))) / sigma_0;
}

__device__ float upsample(float3  rgb_1, float wavelength_0)
{
    float _S1104 = dot_0(make_float3 (-0.08011700212955475f, 1.08901798725128174f, -0.00889899954199791f), rgb_1);
    float _S1105 = dot_0(make_float3 (0.12177000194787979f, -1.22903203964233398f, 1.10724997520446777f), rgb_1);
    float _S1106 = dot_0(make_float3 (1.17252397537231445f, -1.21603405475616455f, 0.04350199922919273f), rgb_1);
    float3  _S1107 = make_float3 (_S1104, _S1105, _S1106);
    float _S1108 = (wavelength_0 - 0.44999998807907104f) / 0.02999999932944775f;
    float _S1109 = (wavelength_0 - 0.63999998569488525f) / 0.03999999910593033f;
    return _S1104 + _S1105 * (F32_exp((-0.5f * _S1108 * _S1108))) + _S1106 * (F32_exp((-0.5f * _S1109 * _S1109)));
}

__device__ float3  pathColor(float3  f_15, float3  weight_1, float wavelength_1)
{
    float3  _S1110;
    if(wavelength_1 > 0.0f)
    {
        float _S1111 = upsample(f_15, wavelength_1);
        _S1110 = weight_1 * make_float3 (_S1111);
    }
    else
    {
        _S1110 = f_15;
    }
    return _S1110;
}

static __device__ float3  exp_0(float3  x_22)
{
    float3  result_11;
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
        *_slang_vector_get_element_ptr(&result_11, i_14) = (F32_exp((_slang_vector_get_element(x_22, i_14))));
        i_14 = i_14 + int(1);
    }
    return result_11;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_1, float distance_2, bool scatters_0)
{
    float3  _S1112 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_2));
    float3  _S1113 = scatter_0 * _S1112 / make_float3 (sigma_1);
    float3  _S1114 = _slang_select(scatters_0, _S1113,_S1112);
    return _S1114;
}

static __device__ bool scatterSampled_0(bool replay_1, uint b_5, uint stop_0, bool varying_0)
{
    bool _S1115 = !replay_1;
    bool _S1116;
    if(_S1115)
    {
        _S1116 = true;
    }
    else
    {
        bool _S1117 = b_5 == stop_0;
        if(_S1117)
        {
            _S1116 = !varying_0;
        }
        else
        {
            _S1116 = false;
        }
    }
    return _S1116;
}

static __device__ uint arrivalLobe_0(uint b_6, uint prev_lobe_0)
{
    bool _S1118 = b_6 > 0U;
    uint _S1119 = _slang_select(_S1118, prev_lobe_0,3U);
    return _S1119;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_4, uint lobe_4, bool surface_5, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1120;
    (&_S1120)->extinction_behind = extinction_behind_0;
    (&_S1120)->extinction_front = extinction_front_0;
    (&_S1120)->fillings = fillings_0;
    (&_S1120)->side = side_0;
    (&_S1120)->depth = depth_4;
    (&_S1120)->lobe = lobe_4;
    (&_S1120)->surface = surface_5;
    (&_S1120)->length = length_2;
    (&_S1120)->width = width_1;
    (&_S1120)->own = *own_2;
    (&_S1120)->fiber = fiber_0;
    return _S1120;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1121 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1121)
    {
        return 0.07957746833562851f;
    }
    float _S1122 = g_0 * g_0;
    return (1.0f - _S1122) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1122 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_9, float3  b_7)
{
    float3  _S1123 = a_9 / b_7;
    float3  _S1124 = make_float3 (0.0f);
    bool3  _S1125 = b_7 == _S1124;
    float3  _S1126 = _slang_select(_S1125, _S1124,_S1123);
    return _S1126;
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_16)
{
    Reservoir candidate_2 = r_7;
    uint _S1127 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1128 = insertBits_0(_S1127, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1128;
    (&candidate_2)->f = f_16;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_1, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_11)
{
    Random _S1129 = pcg(random_state_11);
    Random _S1130 = pcg(_S1129.state);
    float _S1131 = 1.0f - 2.0f * _S1129.value;
    float _S1132 = (F32_sqrt(((F32_max((1.0f - _S1131 * _S1131), (0.0f))))));
    float _S1133 = 6.28318548202514648f * _S1130.value;
    return make_float3 (_S1132 * (F32_cos((_S1133))), _S1132 * (F32_sin((_S1133))), _S1131);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_14, uint random_state_12, float * pdf_9)
{
    bool _S1134 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1134)
    {
        *pdf_9 = 0.07957746833562851f;
        float3  _S1135 = isotropic_0(random_state_12);
        return _S1135;
    }
    Random _S1136 = pcg(random_state_12);
    Random _S1137 = pcg(_S1136.state);
    float _S1138 = g_1 * g_1;
    float _S1139 = 2.0f * g_1;
    float _S1140 = (1.0f - _S1138) / (1.0f - g_1 + _S1139 * _S1136.value);
    float _S1141 = clamp_1((1.0f + _S1138 - _S1140 * _S1140) / _S1139, -1.0f, 1.0f);
    float _S1142 = (F32_sqrt(((F32_max((1.0f - _S1141 * _S1141), (0.0f))))));
    float _S1143 = 6.28318548202514648f * _S1137.value;
    float _S1144 = phaseHG_0(g_1, _S1141);
    *pdf_9 = _S1144;
    float3  _S1145 = tangentToWorld(make_float3 (_S1142 * (F32_cos((_S1143))), _S1141, _S1142 * (F32_sin((_S1143)))), dir_14);
    float3  _S1146 = ((((_S1145)) * make_float3(rnorm3df(((_S1145)).x, ((_S1145)).y, ((_S1145)).z))));
    return _S1146;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_5)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_3, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_3, float dispersion_0)
{
    BSDFMaterial _S1147;
    (&_S1147)->albedo = albedo_0;
    (&_S1147)->emissive = emissive_0;
    (&_S1147)->roughness = roughness_0;
    (&_S1147)->metallic = metallic_0;
    (&_S1147)->transmission = transmission_0;
    (&_S1147)->ior = ior_0;
    (&_S1147)->absorption = absorption_0;
    (&_S1147)->specular_tint = specular_tint_0;
    (&_S1147)->specular_level = specular_level_0;
    (&_S1147)->translucent = translucent_0;
    (&_S1147)->sheen = sheen_3;
    (&_S1147)->sheen_roughness = sheen_roughness_0;
    (&_S1147)->anisotropy = anisotropy_0;
    (&_S1147)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1147)->tangent = tangent_2;
    (&_S1147)->velvet = velvet_0;
    (&_S1147)->toon = toon_3;
    (&_S1147)->dispersion = dispersion_0;
    return _S1147;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1148;
    (&_S1148)->scatter = scatter_1;
    (&_S1148)->extinction = extinction_1;
    (&_S1148)->g = g_2;
    return _S1148;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_16, bool skip_0, uint random_state_13, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1149;
    (&_S1149)->smooth_n = smooth_n_4;
    (&_S1149)->geometry_n = geometry_n_2;
    (&_S1149)->geometry_offset = geometry_offset_2;
    (&_S1149)->material = *material_16;
    (&_S1149)->skip = skip_0;
    (&_S1149)->random_state = random_state_13;
    (&_S1149)->coverage = coverage_0;
    (&_S1149)->encloses = encloses_0;
    (&_S1149)->volume = *volume_0;
    (&_S1149)->fills = fills_0;
    (&_S1149)->hair = hair_0;
    return _S1149;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S1150 = (&surface_6->material)->emissive;
    float3  _S1151 = make_float3 (0.0f);
    bool _S1152 = !top_0;
    float3  _S1153 = _slang_select(_S1152, _S1151,_S1150);
    (&(&lower_0)->material)->emissive = _S1153;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_2)
{
    float _S1154 = surface_7->coverage;
    bool _S1155 = u_2 < _S1154;
    if(_S1155)
    {
        return *surface_7;
    }
    float3  _S1156 = make_float3 (0.0f);
    float3  _S1157 = make_float3 (1.0f);
    BSDFMaterial _S1158 = Material_x24init_0(_S1156, _S1156, 0.0f, 0.0f, 0.0f, 0.0f, _S1156, _S1157, 1.0f, _S1156, _S1156, 0.5f, 0.0f, 0.0f, _S1156, 0.0f, _S1156, 0.0f);
    BSDFMaterial material_17 = _S1158;
    (&material_17)->albedo = _S1157;
    (&material_17)->emissive = (&surface_7->material)->emissive;
    (&material_17)->transmission = 1.0f;
    (&material_17)->ior = 1.0f;
    (&material_17)->absorption = (&surface_7->material)->absorption;
    FKSurface through_0 = *surface_7;
    (&through_0)->material = material_17;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S1159 = transmission_1 > 0.0f;
    bool _S1160;
    if(_S1159)
    {
        _S1160 = true;
    }
    else
    {
        _S1160 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1161;
    if(_S1160)
    {
        _S1161 = 1.0f;
    }
    else
    {
        _S1161 = -1.0f;
    }
    return _S1161;
}

static __device__ bool arrivesBehind_0(float3  dir_15, float3  n_12)
{
    return (dot_0(dir_15, n_12)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_16)
{
    float3  _S1162 = surface_8->geometry_n;
    float _S1163 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_16);
    FKSurface faced_0 = *surface_8;
    float3  _S1164 = surface_8->smooth_n * make_float3 (_S1163);
    (&faced_0)->smooth_n = _S1164;
    float3  _S1165 = _S1162 * make_float3 (_S1163);
    (&faced_0)->geometry_n = _S1165;
    return faced_0;
}

static __device__ float3  max_0(float3  x_23, float3  y_7)
{
    float3  result_12;
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
        *_slang_vector_get_element_ptr(&result_12, i_15) = (F32_max((_slang_vector_get_element(x_23, i_15)), (_slang_vector_get_element(y_7, i_15))));
        i_15 = i_15 + int(1);
    }
    return result_12;
}

static __device__ float3  log_0(float3  x_24)
{
    float3  result_13;
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
        *_slang_vector_get_element_ptr(&result_13, i_16) = (F32_log((_slang_vector_get_element(x_24, i_16))));
        i_16 = i_16 + int(1);
    }
    return result_13;
}

__device__ float3  beerLambert(float distance_3, float3  absorption_1)
{
    float3  _S1166 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1166));
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
    bool _S1167;
    if(open_0)
    {
        _S1167 = prev_rough_0;
    }
    else
    {
        _S1167 = false;
    }
    if(_S1167)
    {
        _S1167 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S1167 = false;
    }
    return _S1167;
}

__device__ bool dispersive(BSDFMaterial material_18)
{
    bool _S1168 = (material_18.dispersion) > 0.0f;
    bool _S1169;
    if(_S1168)
    {
        _S1169 = (material_18.ior) != 1.0f;
    }
    else
    {
        _S1169 = false;
    }
    return _S1169;
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
        uint _S1170 = (low_1 + high_1 + 1U) / 2U;
        bool _S1171 = (WAVELENGTH_CDF_0[_S1170]) <= u_3;
        if(_S1171)
        {
            low_1 = _S1170;
        }
        else
        {
            uint _S1172 = _S1170 - 1U;
            high_1 = _S1172;
        }
    }
    uint _S1173 = low_1;
    float _S1174 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_3 - WAVELENGTH_CDF_0[_S1173]) / _S1174), _S1174 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_2)
{
    float _S1175 = clamp_1((wavelength_2 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1176 = (U32_min((uint(_S1175)), (79U)));
    uint _S1177 = 3U * _S1176;
    float3  _S1178 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1177], WAVELENGTH_WEIGHTS_0[_S1177 + 1U], WAVELENGTH_WEIGHTS_0[_S1177 + 2U]);
    float3  _S1179 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1177 + 3U], WAVELENGTH_WEIGHTS_0[_S1177 + 4U], WAVELENGTH_WEIGHTS_0[_S1177 + 5U]);
    return _S1178 + (_S1179 - _S1178) * make_float3 (_S1175 - float(_S1176));
}

__device__ BSDFMaterial atWavelength(BSDFMaterial material_19, float wavelength_3)
{
    BSDFMaterial at_0 = material_19;
    float _S1180 = upsample(material_19.albedo, wavelength_3);
    float3  _S1181 = make_float3 (_S1180);
    (&at_0)->albedo = _S1181;
    float _S1182 = upsample(material_19.emissive, wavelength_3);
    float3  _S1183 = make_float3 (_S1182);
    (&at_0)->emissive = _S1183;
    float _S1184 = upsample(material_19.absorption, wavelength_3);
    float3  _S1185 = make_float3 (_S1184);
    (&at_0)->absorption = _S1185;
    float _S1186 = upsample(material_19.specular_tint, wavelength_3);
    float3  _S1187 = make_float3 (_S1186);
    (&at_0)->specular_tint = _S1187;
    float _S1188 = upsample(material_19.translucent, wavelength_3);
    float3  _S1189 = make_float3 (_S1188);
    (&at_0)->translucent = _S1189;
    float _S1190 = upsample(material_19.sheen, wavelength_3);
    float3  _S1191 = make_float3 (_S1190);
    (&at_0)->sheen = _S1191;
    return at_0;
}

__device__ float dispersedIor(float ior_1, float dispersion_1, float wavelength_4)
{
    float _S1192 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1193 = _S1192 * (1.0f / (wavelength_4 * wavelength_4) - 2.89662933349609375f);
    bool _S1194 = dispersion_1 > 0.0f;
    float _S1195 = _slang_select(_S1194, _S1193,0.0f);
    return ior_1 + _S1195;
}

__device__ float2  vertexEta(BSDFMaterial material_20, float n_dot_v_0)
{
    bool _S1196 = n_dot_v_0 < 0.0f;
    float _S1197 = _slang_select(_S1196, material_20.ior,1.0f);
    float _S1198 = _slang_select(_S1196, 1.0f,material_20.ior);
    return make_float2 (_S1197, _S1198);
}

__device__ float2  wavelengthEta(BSDFMaterial material_21, float n_dot_v_1, float wavelength_5)
{
    BSDFMaterial refractive_0 = material_21;
    float _S1199 = dispersedIor(material_21.ior, material_21.dispersion, wavelength_5);
    bool _S1200 = wavelength_5 > 0.0f;
    float _S1201 = _slang_select(_S1200, _S1199,material_21.ior);
    (&refractive_0)->ior = _S1201;
    float2  _S1202 = vertexEta(refractive_0, n_dot_v_1);
    return _S1202;
}

__device__ bool neeDecision(BSDFMaterial material_22, float n_dot_v_2, float eta_i_14, float eta_o_14)
{
    float _S1203 = fresnel((F32_abs((n_dot_v_2))), eta_i_14, eta_o_14);
    float3  _S1204 = mix_0(make_float3 (_S1203), material_22.albedo, material_22.metallic);
    float _S1205 = rgb_to_greyscale(_S1204);
    float _S1206 = (F32_max(((1.0f - _S1205) * (1.0f - material_22.metallic) * (1.0f - material_22.transmission)), (0.0f)));
    bool _S1207 = _S1206 > 0.03999999910593033f;
    bool _S1208;
    if(_S1207)
    {
        _S1208 = true;
    }
    else
    {
        _S1208 = (material_22.roughness) > 0.20000000298023224f;
    }
    return _S1208;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_23)
{
    float _S1209 = rgb_to_greyscale(material_23->translucent);
    return _S1209 > 0.0f;
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
    MediumSides _S1210;
    (&_S1210)->behind = *behind_0;
    (&_S1210)->front = *front_0;
    (&_S1210)->fillings = fillings_1;
    (&_S1210)->face = face_1;
    return _S1210;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_17, FKMedium * outside_0)
{
    float3  _S1211 = surface_9->geometry_n;
    MediumSides _S1212 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S1212;
    bool _S1213 = surface_9->encloses;
    if(_S1213)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S1214 = (dot_0(dir_17, _S1211)) > 0.0f;
        if(_S1214)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_18, uint depth_5, uint lobe_5, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1215 = surface_10->geometry_n;
    ShadowContext _S1216 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_5, lobe_5, true, length_3, width_2, own_3, fiber_1);
    bool _S1217 = surface_10->encloses;
    ShadowContext context_4;
    if(_S1217)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S1218 = - _S1215;
        float3  _S1219 = _slang_select(turned_0, _S1218,_S1215);
        (&faced_1)->geometry_n = _S1219;
        FKMedium _S1220 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1221 = faced_1;
        FKMedium _S1222 = _S1220;
        MediumSides _S1223 = mediumSides_0(&_S1221, &_S1222, filling_1, dir_18, outside_1);
        ShadowContext _S1224 = ShadowContext_x24init_0(_S1223.behind.extinction, _S1223.front.extinction, _S1223.fillings, _S1215, depth_5, lobe_5, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1225 = _S1223.fillings;
            ShadowContext _S1226 = ShadowContext_x24init_0(_S1223.front.extinction, _S1223.behind.extinction, uint2 {_S1225.y, _S1225.x}, _S1215, depth_5, lobe_5, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1226;
        }
        else
        {
            context_4 = _S1224;
        }
    }
    else
    {
        context_4 = _S1216;
    }
    return context_4;
}

static __device__ bool any_1(bool3  x_25)
{
    bool result_14 = false;
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
        if(result_14)
        {
            result_14 = true;
        }
        else
        {
            result_14 = (bool((_slang_vector_get_element(x_25, i_17))));
        }
        i_17 = i_17 + int(1);
    }
    return result_14;
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_11, float3  out_dir_2, float3  n_13, float3  g_n_0, BSDFMaterial material_24, float eta_i_15, float eta_o_15, uint random_state_14, MaterialTerms terms_8, ViewTerms view_terms_7)
{
    float3  _S1227 = negate_0(in_dir_11);
    float _S1228 = dot_0(n_13, _S1227);
    float _S1229 = sign_0(_S1228);
    float3  _S1230 = n_13 * make_float3 (_S1229);
    float _S1231 = dot_0(_S1230, out_dir_2);
    float _S1232 = material_24.roughness;
    float _S1233 = _S1232 * _S1232;
    bool _S1234 = !((dot_0(g_n_0, _S1227) * dot_0(g_n_0, out_dir_2)) > 0.0f);
    float3  f_17;
    if(_S1234)
    {
        float l_dot_h_8 = 0.0f;
        HalfTerms _S1235 = refractedHalf(in_dir_11, out_dir_2, n_13, material_24, eta_i_15, eta_o_15, terms_8, view_terms_7, &l_dot_h_8);
        float _S1236 = refractPDF(_S1231, l_dot_h_8, (F32_abs((_S1228))), _S1233, _S1235, eta_i_15, eta_o_15);
        if(_S1236 > 0.0f)
        {
            float3  _S1237 = refractBSDF(out_dir_2, _S1230, _S1233, material_24, _S1235);
            f_17 = _S1237 * make_float3 (_S1236);
        }
        else
        {
            f_17 = make_float3 (0.0f);
        }
        return f_17;
    }
    HalfTerms _S1238 = sampledHalf(in_dir_11, n_13, material_24, eta_i_15, eta_o_15, random_state_14, terms_8, view_terms_7);
    HalfTerms _S1239 = reflectedHalf(in_dir_11, out_dir_2, material_24, eta_i_15, eta_o_15, terms_8, view_terms_7);
    float _S1240 = (F32_abs((_S1228)));
    float _S1241 = diffusePDF(_S1231, 0.0f, _S1240, _S1233, _S1238, eta_i_15, eta_o_15);
    float _S1242 = reflectPDF(_S1231, 0.0f, _S1240, _S1233, _S1239, eta_i_15, eta_o_15);
    float _S1243 = sheenVelvetPDF(_S1231, 0.0f, _S1240, _S1233, _S1239, eta_i_15, eta_o_15);
    if(_S1241 > 0.0f)
    {
        float3  _S1244 = diffuseBSDF(out_dir_2, _S1230, _S1233, material_24, _S1238);
        f_17 = _S1244 * make_float3 (_S1241);
    }
    else
    {
        f_17 = make_float3 (0.0f);
    }
    float3  _S1245;
    if(_S1242 > 0.0f)
    {
        float3  _S1246 = reflectBSDF(out_dir_2, _S1230, _S1233, material_24, _S1239);
        _S1245 = _S1246 * make_float3 (_S1242);
    }
    else
    {
        _S1245 = make_float3 (0.0f);
    }
    float3  _S1247;
    if(_S1243 > 0.0f)
    {
        float3  _S1248 = sheenVelvetBSDF(out_dir_2, _S1230, _S1233, material_24, _S1239);
        _S1247 = _S1248 * make_float3 (_S1243);
    }
    else
    {
        _S1247 = make_float3 (0.0f);
    }
    float3  f_18 = f_17 + _S1245 + _S1247;
    bool _S1249 = (F32_abs((material_24.toon.x))) > 0.0f;
    if(_S1249)
    {
        float _S1250 = toonPDF(_S1231, dot_0(out_dir_2, _S1238.toon_axis), _S1240, _S1233, _S1238, eta_i_15, eta_o_15);
        if(_S1250 > 0.0f)
        {
            float3  _S1251 = toonBSDF(out_dir_2, _S1230, _S1233, material_24, _S1238);
            f_17 = _S1251 * make_float3 (_S1250);
        }
        else
        {
            f_17 = make_float3 (0.0f);
        }
        float3  _S1252 = f_18 + f_17;
        f_17 = _S1252;
    }
    else
    {
        f_17 = f_18;
    }
    return f_17;
}

__device__ float3  translucentCorrection(float3  in_dir_12, float3  out_dir_3, float3  n_14, float3  g_n_1, BSDFMaterial material_25, float eta_i_16, float eta_o_16, uint random_state_15, MaterialTerms terms_9, ViewTerms view_terms_8)
{
    float _S1253 = dot_0(n_14, out_dir_3);
    float3  _S1254 = negate_0(in_dir_12);
    bool _S1255 = (_S1253 * dot_0(n_14, _S1254)) < 0.0f;
    float3  _S1256 = negate_0(in_dir_12);
    float _S1257 = dot_0(n_14, _S1256);
    float _S1258 = sign_0(_S1257);
    float3  _S1259 = n_14 * make_float3 (_S1258);
    float _S1260 = material_25.roughness;
    float _S1261 = _S1260 * _S1260;
    HalfTerms _S1262 = sampledHalf(in_dir_12, n_14, material_25, eta_i_16, eta_o_16, random_state_15, terms_9, view_terms_8);
    float _S1263 = diffusePDF(dot_0(_S1259, out_dir_3), 0.0f, (F32_abs((_S1257))), _S1261, _S1262, eta_i_16, eta_o_16);
    float3  _S1264;
    if(_S1263 > 0.0f)
    {
        float3  _S1265 = diffuseBSDF(out_dir_3, _S1259, _S1261, material_25, _S1262);
        _S1264 = _S1265 * make_float3 (_S1263);
    }
    else
    {
        _S1264 = make_float3 (0.0f);
    }
    float3  _S1266 = negate_0(in_dir_12);
    bool _S1267 = (dot_0(g_n_1, _S1266) * dot_0(g_n_1, out_dir_3)) > 0.0f;
    float3  _S1268 = make_float3 (0.0f);
    float _S1269 = _slang_select(_S1267, -1.0f,1.0f);
    float3  _S1270 = _S1264 * make_float3 (_S1269);
    float3  _S1271 = _slang_select(_S1255, _S1270,_S1268);
    return _S1271;
}

__device__ float3  translucentBSDF(float3  in_dir_13, float3  out_dir_4, float3  n_15, float3  g_n_2, BSDFMaterial material_26, float eta_i_17, float eta_o_17, uint random_state_16)
{
    MaterialTerms _S1272 = precomputeMaterial(material_26, eta_i_17, eta_o_17);
    ViewTerms _S1273 = precomputeView(in_dir_13, n_15, material_26, _S1272);
    float3  _S1274 = BSDF(in_dir_13, out_dir_4, n_15, g_n_2, material_26, eta_i_17, eta_o_17, random_state_16, _S1272, _S1273);
    float3  _S1275 = translucentCorrection(in_dir_13, out_dir_4, n_15, g_n_2, material_26, eta_i_17, eta_o_17, random_state_16, _S1272, _S1273);
    return _S1274 + _S1275;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_14, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_27, float eta_i_18, float eta_o_18, bool competing_1, uint random_state_17)
{
    bool _S1276 = !competing_1;
    bool _S1277;
    if(_S1276)
    {
        _S1277 = true;
    }
    else
    {
        _S1277 = (light_2->density) == 0.0f;
    }
    if(_S1277)
    {
        bool _S1278 = isTranslucent_0(material_27);
        _S1277 = _S1278;
    }
    else
    {
        _S1277 = false;
    }
    if(_S1277)
    {
        float3  _S1279 = translucentBSDF(in_dir_14, light_2->dir, smooth_n_5, geometry_n_4, *material_27, eta_i_18, eta_o_18, random_state_17);
        return _S1279 * light_2->radiance;
    }
    MaterialTerms _S1280 = precomputeMaterial(*material_27, eta_i_18, eta_o_18);
    ViewTerms _S1281 = precomputeView(in_dir_14, smooth_n_5, *material_27, _S1280);
    if(_S1276)
    {
        _S1277 = true;
    }
    else
    {
        _S1277 = (light_2->density) == 0.0f;
    }
    if(_S1277)
    {
        float3  _S1282 = BSDF(in_dir_14, light_2->dir, smooth_n_5, geometry_n_4, *material_27, eta_i_18, eta_o_18, random_state_17, _S1280, _S1281);
        return _S1282 * light_2->radiance;
    }
    float3  _S1283 = light_2->dir;
    bool _S1284 = (dot_0(geometry_n_4, - in_dir_14) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    float3  _S1285 = neeBSDF(in_dir_14, _S1283, smooth_n_5, *material_27, eta_i_18, eta_o_18, _S1284, light_2->density, true, random_state_17, _S1280, _S1281);
    return _S1285 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_2, uint random_state_18, bool refracted_5, uint lobe_6, float pdf_10)
{
    SampleBSDF _S1286;
    (&_S1286)->unit_direction = unit_direction_1;
    (&_S1286)->throughput = throughput_2;
    (&_S1286)->random_state = random_state_18;
    (&_S1286)->refracted = refracted_5;
    (&_S1286)->lobe = lobe_6;
    (&_S1286)->pdf = pdf_10;
    return _S1286;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_8, float n_i_dot_v_6, float alpha_15, BSDFMaterial material_28, HalfTerms lobes_11, float eta_i_19, float eta_o_19, uint random_state_19)
{
    float3  _S1287 = make_float3 (1.0f);
    SampleBSDF _S1288 = SampleBSDF_x24init_0(_S1287, _S1287, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1288;
    Random _S1289 = pcg(random_state_19);
    Random _S1290 = pcg(_S1289.state);
    (&sample_1)->random_state = _S1290.state;
    float _S1291 = _S1289.value;
    float _S1292 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1291 * _S1291))))));
    float _S1293 = 6.28318548202514648f * _S1290.value;
    float3  _S1294 = tangentToWorld(make_float3 (_S1292 * (F32_cos((_S1293))), _S1289.value, _S1292 * (F32_sin((_S1293)))), n_i_8);
    (&sample_1)->unit_direction = _S1294;
    (&sample_1)->lobe = 4U;
    float3  _S1295 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_8, alpha_15, material_28, lobes_11);
    (&sample_1)->throughput = _S1295;
    float _S1296 = sheenVelvetPDF(_S1289.value, 0.0f, n_i_dot_v_6, alpha_15, lobes_11, eta_i_19, eta_o_19);
    (&sample_1)->pdf = _S1296;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1297 = (F32_sqrt((random_1_0)));
    float _S1298 = 6.28318548202514648f * random_2_0;
    float _S1299 = _S1297 * (F32_cos((_S1298)));
    float _S1300 = _S1297 * (F32_sin((_S1298)));
    float _S1301 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1299 * _S1299 - _S1300 * _S1300))))));
    return make_float3 (_S1299, _S1301, _S1300);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_4, float3  n_i_9, float n_i_dot_v_7, float alpha_16, BSDFMaterial material_29, HalfTerms lobes_12, float eta_i_20, float eta_o_20, uint random_state_20)
{
    float3  _S1302 = make_float3 (1.0f);
    SampleBSDF _S1303 = SampleBSDF_x24init_0(_S1302, _S1302, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1303;
    Random _S1304 = pcg(random_state_20);
    Random _S1305 = pcg(_S1304.state);
    (&sample_2)->random_state = _S1305.state;
    float3  _S1306 = sampleCosWeightedHemisphere(_S1304.value, _S1305.value);
    bool _S1307 = u_4 < (lobes_12.p_diffuse * lobes_12.translucent_share);
    float _S1308 = _S1306.y;
    float _S1309 = - _S1308;
    float _S1310 = _slang_select(_S1307, _S1309,_S1308);
    float3  _S1311 = tangentToWorld(make_float3 (_S1306.x, _S1310, _S1306.z), n_i_9);
    (&sample_2)->unit_direction = _S1311;
    (&sample_2)->refracted = _S1307;
    (&sample_2)->lobe = 0U;
    float3  _S1312 = diffuseBSDF((&sample_2)->unit_direction, n_i_9, alpha_16, material_29, lobes_12);
    (&sample_2)->throughput = _S1312;
    float _S1313 = diffusePDF(_S1310, 0.0f, n_i_dot_v_7, alpha_16, lobes_12, eta_i_20, eta_o_20);
    (&sample_2)->pdf = _S1313;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_10, float n_i_dot_v_8, float alpha_17, BSDFMaterial material_30, HalfTerms lobes_13, float eta_i_21, float eta_o_21, uint random_state_21)
{
    float3  _S1314 = make_float3 (1.0f);
    SampleBSDF _S1315 = SampleBSDF_x24init_0(_S1314, _S1314, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1315;
    Random _S1316 = pcg(random_state_21);
    Random _S1317 = pcg(_S1316.state);
    (&sample_3)->random_state = _S1317.state;
    float _S1318 = _S1316.value * lobes_13.toon_norm / 6.28318548202514648f;
    float t_21;
    if(lobes_13.toon_glossy)
    {
        t_21 = (F32_acos((clamp_1(1.0f - _S1318, -1.0f, 1.0f))));
    }
    else
    {
        t_21 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1318)))), (1.0f))))));
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
        float _S1319;
        if(t_21 < (lobes_13.toon_a))
        {
            _S1319 = 1.0f;
        }
        else
        {
            _S1319 = (F32_max((1.0f - (t_21 - lobes_13.toon_a) / (F32_max((lobes_13.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float integral_1;
        if(lobes_13.toon_glossy)
        {
            integral_1 = 1.0f - (F32_cos(((F32_min((t_21), (lobes_13.toon_a))))));
        }
        else
        {
            float _S1320 = (F32_sin(((F32_min((t_21), (lobes_13.toon_a))))));
            integral_1 = _S1320 * _S1320 / 2.0f;
        }
        bool _S1321 = t_21 > (lobes_13.toon_a);
        bool _S1322;
        if(_S1321)
        {
            _S1322 = (lobes_13.toon_s) > 0.0f;
        }
        else
        {
            _S1322 = false;
        }
        float integral_2;
        if(_S1322)
        {
            if(lobes_13.toon_glossy)
            {
                float _S1323 = (F32_cos((lobes_13.toon_a)));
                float _S1324 = (F32_cos((t_21)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1323 - _S1324) - ((F32_sin((t_21))) - t_21 * _S1324 - ((F32_sin((lobes_13.toon_a))) - lobes_13.toon_a * _S1323)) / lobes_13.toon_s;
            }
            else
            {
                float _S1325 = 2.0f * lobes_13.toon_a;
                float _S1326 = (F32_cos((_S1325)));
                float _S1327 = 2.0f * t_21;
                float _S1328 = (F32_cos((_S1327)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1326 - _S1328) / 4.0f - ((F32_sin((_S1327))) / 8.0f - t_21 * _S1328 / 4.0f - ((F32_sin((_S1325))) / 8.0f - lobes_13.toon_a * _S1326 / 4.0f)) / lobes_13.toon_s;
            }
            float integral_3 = integral_1 + integral_2;
            integral_2 = integral_3;
        }
        else
        {
            integral_2 = integral_1;
        }
        float _S1329 = _S1319 * (F32_sin((t_21)));
        float _S1330;
        if(lobes_13.toon_glossy)
        {
            _S1330 = 1.0f;
        }
        else
        {
            _S1330 = (F32_cos((t_21)));
        }
        float _S1331 = _S1329 * _S1330;
        float _S1332 = (integral_2 - _S1318) / _S1331;
        bool _S1333 = _S1331 > 0.0f;
        float _S1334 = _slang_select(_S1333, _S1332,0.0f);
        float _S1335 = clamp_1(t_21 - _S1334, 0.0f, lobes_13.toon_b);
        int k_1 = k_0 + int(1);
        t_21 = _S1335;
        k_0 = k_1;
    }
    float _S1336 = 6.28318548202514648f * _S1317.value;
    float _S1337 = (F32_sin((t_21)));
    float3  _S1338 = tangentToWorld(make_float3 (_S1337 * (F32_cos((_S1336))), (F32_cos((t_21))), _S1337 * (F32_sin((_S1336)))), lobes_13.toon_axis);
    (&sample_3)->unit_direction = _S1338;
    bool _S1339 = (dot_0(n_i_10, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1339;
    (&sample_3)->lobe = 6U;
    float3  _S1340 = toonBSDF((&sample_3)->unit_direction, n_i_10, alpha_17, material_30, lobes_13);
    (&sample_3)->throughput = _S1340;
    float _S1341 = toonPDF(dot_0(n_i_10, (&sample_3)->unit_direction), dot_0((&sample_3)->unit_direction, lobes_13.toon_axis), n_i_dot_v_8, alpha_17, lobes_13, eta_i_21, eta_o_21);
    (&sample_3)->pdf = _S1341;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_1, float3  n_i_11, float n_i_dot_v_9, float alpha_18, BSDFMaterial material_31, HalfTerms lobes_14, float eta_i_22, float eta_o_22, uint random_state_22)
{
    float3  _S1342 = make_float3 (1.0f);
    SampleBSDF _S1343 = SampleBSDF_x24init_0(_S1342, _S1342, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1343;
    (&sample_4)->unit_direction = lobes_14.refracted;
    (&sample_4)->random_state = random_state_22;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1344 = refractBSDF((&sample_4)->unit_direction, n_i_11, alpha_18, material_31, lobes_14);
    (&sample_4)->throughput = _S1344;
    float _S1345 = refractPDF(0.0f, dot_0((&sample_4)->unit_direction, ggx_n_1), n_i_dot_v_9, alpha_18, lobes_14, eta_i_22, eta_o_22);
    (&sample_4)->pdf = _S1345;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_18, float3  n_16)
{
    return i_18 - make_float3 (2.0f * dot_0(n_16, i_18)) * n_16;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_15, float3  ggx_n_2, float3  n_i_12, float n_i_dot_v_10, float alpha_19, BSDFMaterial material_32, HalfTerms lobes_15, float eta_i_23, float eta_o_23, uint random_state_23)
{
    float3  _S1346 = make_float3 (1.0f);
    SampleBSDF _S1347 = SampleBSDF_x24init_0(_S1346, _S1346, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1347;
    float3  _S1348 = reflect_0(in_dir_15, ggx_n_2);
    float3  _S1349 = ((((_S1348)) * make_float3(rnorm3df(((_S1348)).x, ((_S1348)).y, ((_S1348)).z))));
    (&sample_5)->unit_direction = _S1349;
    (&sample_5)->random_state = random_state_23;
    (&sample_5)->lobe = 2U;
    float3  _S1350 = reflectBSDF((&sample_5)->unit_direction, n_i_12, alpha_19, material_32, lobes_15);
    (&sample_5)->throughput = _S1350;
    float _S1351 = reflectPDF(0.0f, 0.0f, n_i_dot_v_10, alpha_19, lobes_15, eta_i_23, eta_o_23);
    (&sample_5)->pdf = _S1351;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_16, float3  n_17, BSDFMaterial material_33, float eta_i_24, float eta_o_24, uint random_init_0, float2  screen_space_0, MaterialTerms terms_10, ViewTerms view_terms_9)
{
    uint random_state_24 = random_init_0;
    float3  _S1352 = negate_0(in_dir_16);
    float _S1353 = dot_0(n_17, _S1352);
    float _S1354 = sign_0(_S1353);
    float3  n_i_13 = n_17 * make_float3 (_S1354);
    float _S1355 = (F32_abs((_S1353)));
    float _S1356 = material_33.roughness;
    float _S1357 = _S1356 * _S1356;
    float3  _S1358 = sampleHalfVector(_S1352, n_i_13, _S1357, view_terms_9.frame, &random_state_24);
    HalfTerms _S1359 = precomputeHalf(in_dir_16, _S1358, material_33, eta_i_24, eta_o_24, terms_10, view_terms_9);
    Random _S1360 = pcg(random_state_24);
    random_state_24 = _S1360.state;
    bool _S1361 = (_S1360.value) < (_S1359.p_sheen_velvet);
    if(_S1361)
    {
        SampleBSDF _S1362 = sheenVelvetSample(n_i_13, _S1355, _S1357, material_33, _S1359, eta_i_24, eta_o_24, random_state_24);
        return _S1362;
    }
    float _S1363 = _S1360.value - _S1359.p_sheen_velvet;
    bool _S1364 = _S1363 < (_S1359.p_diffuse);
    if(_S1364)
    {
        SampleBSDF _S1365 = diffuseSample(_S1363, n_i_13, _S1355, _S1357, material_33, _S1359, eta_i_24, eta_o_24, random_state_24);
        return _S1365;
    }
    bool _S1366 = _S1363 < (_S1359.p_diffuse + _S1359.p_toon);
    if(_S1366)
    {
        SampleBSDF _S1367 = toonSample(n_i_13, _S1355, _S1357, material_33, _S1359, eta_i_24, eta_o_24, random_state_24);
        return _S1367;
    }
    bool _S1368 = (_S1363 - _S1359.p_toon) < (_S1359.p_diffuse + _S1359.p_refract);
    if(_S1368)
    {
        SampleBSDF _S1369 = refractSample(_S1358, n_i_13, _S1355, _S1357, material_33, _S1359, eta_i_24, eta_o_24, random_state_24);
        return _S1369;
    }
    SampleBSDF _S1370 = reflectSample(in_dir_16, _S1358, n_i_13, _S1355, _S1357, material_33, _S1359, eta_i_24, eta_o_24, random_state_24);
    return _S1370;
}

__device__ bool withinInverseFootprint(float pdf_11, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1371 = pdf_11 > 0.0f;
    bool _S1372;
    if(_S1371)
    {
        if(diffuse_0)
        {
            _S1372 = true;
        }
        else
        {
            _S1372 = (pdf_11 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1372 = false;
    }
    return _S1372;
}

__device__ bool roughLobe(float pdf_12, bool diffuse_1, float roughness_1)
{
    bool _S1373 = pdf_12 > 0.0f;
    bool _S1374;
    if(_S1373)
    {
        if(diffuse_1)
        {
            _S1374 = true;
        }
        else
        {
            _S1374 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1374 = false;
    }
    return _S1374;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1375 = layers_0 > 1U;
    bool _S1376;
    if(_S1375)
    {
        _S1376 = refracting_0 != passed_0;
    }
    else
    {
        _S1376 = false;
    }
    return _S1376;
}

static __device__ float widened_0(float spread_1, float pdf_13, bool delta_0)
{
    float _S1377 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_13))))), (3.14159274101257324f)));
    bool _S1378 = !delta_0;
    float _S1379 = _slang_select(_S1378, _S1377,0.0f);
    return spread_1 + _S1379;
}

static __device__ bool boundsVolume_0(FKSurface * surface_11)
{
    return surface_11->encloses;
}

static __device__ bool leavesInFront_0(float3  face_2, float3  dir_19, float3  g_3)
{
    return ((dot_0(dir_19, g_3)) > 0.0f) == ((dot_0(g_3, face_2)) > 0.0f);
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_8, bool replay_2, float scale_4, Selection * sel_7)
{
    float spread_2;
    bool turned_1;
    bool is_inside_6;
    bool viewed_0;
    bool _S1380;
    float density_2;
    float wavelength_6;
    float width_3;
    float sky_pdf_0;
    float threshold_2;
    uint b_8;
    uint layer_0;
    float3  throughput_3;
    float3  spectral_weight_0;
    TreeSample light_3;
    int _S1381;
    Shift ended_0;
    float density_3;
    float spread_3;
    float width_4;
    float sky_pdf_1;
    float spread_4;
    float width_5;
    uint b_9;
    float3  _S1382 = make_float3 (0.0f);
    Shift _S1383 = Shift_x24init_0(_S1382, 0.0f);
    uint _S1384 = r_8->path;
    uint _S1385 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1386 = extractBits_0(_S1384, 5U, 5U);
    uint _S1387 = extractBits_0(_S1384, 10U, 2U);
    uint _S1388 = extractBits_0(_S1384, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1389 = _S1388 >= 3U;
        uint _S1390 = _slang_select(_S1389, 1U,0U);
        uint _S1391 = _S1385 + _S1390;
        uint _S1392 = (fcptMaxBounces());
        passes_0 = _S1391 > _S1392;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1383;
    }
    uint _S1393 = _S1386 - 1U;
    bool _S1394 = _S1388 == 3U;
    uint _S1395 = _slang_select(_S1394, 1U,0U);
    uint _S1396 = _S1385 + _S1395;
    bool _S1397 = _S1387 == 0U;
    uint _S1398 = _slang_select(_S1397, _S1396,_S1393);
    FKHit _S1399 = (fcptReservoirHit((*r_8)));
    float3  _S1400 = dom_7->x0;
    float3  _S1401 = dom_7->x1 - dom_7->x0;
    float3  _S1402 = ((((_S1401)) * make_float3(rnorm3df(((_S1401)).x, ((_S1401)).y, ((_S1401)).z))));
    FKRay _S1403 = Ray_x24init_0(dom_7->x1, _S1402);
    FKRay ray_2 = _S1403;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1382;
    float3  throughput_4 = make_float3 (1.0f);
    float3  weight_2 = throughput_4;
    float3  glowed_0 = _S1382;
    float3  extinction_in_0 = _S1382;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1404 = dom_7->spread;
    float _S1405 = dom_7->width;
    float _S1406 = length_0(_S1401);
    NEEVertex _S1407 = NEEVertex_x24init_0(true, 0.0f, _S1382, _S1382, _S1382);
    NEEVertex nee_vertex_0 = _S1407;
    Vertex _S1408 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1408;
    Reservoir _S1409 = (Reservoir{});
    Reservoir chain_0 = _S1409;
    uint _S1410 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    uint _S1411 = extractBits_0(_S1384, 24U, 8U);
    uint _S1412 = insertBits_0(0U, _S1411, 24U, 8U);
    (&chain_0)->path = _S1412;
    (&ray_2)->origin = _S1400;
    (&hit_4)->distance = _S1406;
    FKMedium _S1413 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1414 = filling_2;
    bool _S1415 = (fcptVaryingUsed());
    uint _S1416 = _slang_select(_S1415, _S1414,4294967295U);
    filling_2 = _S1416;
    scatter_in_0 = _S1413.scatter;
    extinction_in_0 = _S1413.extinction;
    g_in_0 = _S1413.g;
    Reservoir _S1417 = chain_0;
    uint _S1418 = filling_2;
    for(;;)
    {
        bool _S1419 = (fcptVaryingUsed());
        if(_S1419)
        {
            passes_0 = _S1418 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1420 = (fcptMajorant((_S1418)));
            spread_2 = _S1420;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1398;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1387 == 1U;
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
            ended_0 = _S1383;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1404;
            width_3 = _S1405;
            density_2 = 1.0f;
            throughput_3 = throughput_4;
            b_8 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1421 = (&prev_0)->rough;
        if(_S1421)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1422 = stream(_S1410, 384U);
        uint tracking_0 = _S1422;
        weight_2 = throughput_4;
        glowed_0 = _S1382;
        b_8 = 4294967295U;
        throughput_3 = throughput_4;
        density_2 = 1.0f;
        wavelength_6 = _S1404;
        width_3 = _S1405;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1381 = int(1);
                break;
            }
            uint _S1423 = b_8 + 320U;
            bool _S1424 = b_8 == 4294967295U;
            uint _S1425 = _slang_select(_S1424, 384U,_S1423);
            uint _S1426 = stream(_S1410, _S1425);
            Random _S1427 = pcg(_S1426);
            float _S1428 = freeFlight_0(_S1427.value, spread_2);
            if(passes_0)
            {
                float3  _S1429 = (&ray_2)->origin;
                float3  _S1430 = (&ray_2)->unit_direction;
                float _S1431 = (&hit_4)->distance;
                uint _S1432 = _slang_select(_S1424, 0U,b_8);
                uint _S1433 = (&prev_0)->lobe;
                uint _S1434 = _slang_select(_S1424, 3U,_S1433);
                float _S1435 = (fcptTrackMedium((_S1418), (_S1429), (_S1430), (_S1431), (&tracking_0), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1432), (_S1434), (_S1424)));
                threshold_2 = _S1435;
            }
            else
            {
                threshold_2 = _S1428;
            }
            bool _S1436 = !(threshold_2 < ((&hit_4)->distance));
            if(_S1436)
            {
                _S1381 = int(1);
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
                float3  _S1437 = pathColor(throughput_3 * glowed_0, throughput_4, 0.0f);
                float3  _S1438 = _S1437 / make_float3 (density_2);
                float3  _S1439 = sel_7->glow + _S1438;
                sel_7->glow = _S1439;
            }
            else
            {
            }
            glowed_0 = _S1382;
            uint b_10 = b_8 + 1U;
            float3  _S1440 = (&ray_2)->origin + make_float3 (threshold_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1440;
            float3  _S1441 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, threshold_2, true);
            float3  _S1442 = weight_2;
            float _S1443 = upsample(weight_2, 0.0f);
            float3  _S1444 = make_float3 (_S1443);
            float3  _S1445 = _slang_select(false, _S1444,_S1442);
            float3  _S1446 = _slang_select(passes_0, _S1445,_S1441);
            float3  throughput_5 = throughput_3 * _S1446;
            uint _S1447 = stream(_S1410, b_10 + 320U);
            tracking_0 = _S1447;
            weight_2 = throughput_4;
            float width_6 = width_3 + wavelength_6 * threshold_2;
            float _S1448 = wavelength_6 + 3.14159274101257324f;
            bool _S1449 = scatterSampled_0(replay_2, b_10, _S1398, passes_0);
            TreeSample _S1450 = TreeSample_x24init_0(_S1382, _S1382, 0.0f, 0U);
            if(_S1449)
            {
                float3  _S1451 = (&ray_2)->origin;
                float3  _S1452 = (&ray_2)->unit_direction;
                float3  _S1453 = (&ray_2)->unit_direction;
                uint _S1454 = stream(_S1410, b_10 + 64U);
                float3  _S1455 = extinction_in_0;
                float3  _S1456 = extinction_in_0;
                uint2  _S1457 = make_uint2 (_S1418);
                float3  _S1458 = (&ray_2)->unit_direction;
                uint _S1459 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                FKHit _S1460 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1461 = _S1460;
                ShadowContext _S1462 = ShadowContext_x24init_0(_S1455, _S1456, _S1457, _S1458, b_10, _S1459, false, threshold_2, width_6, &_S1461, false);
                ShadowContext _S1463 = _S1462;
                TreeSample _S1464 = sampleLightTree_0(_S1451, _S1452, _S1453, 0.0f, true, _S1454, &_S1463);
                light_3 = _S1464;
            }
            else
            {
                light_3 = _S1450;
            }
            float _S1465 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1466 = (fcptMaxBounces());
            bool _S1467 = b_10 < _S1466;
            if(_S1467)
            {
                is_inside_6 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_6 = false;
            }
            float _S1468 = _slang_select(is_inside_6, _S1465,0.0f);
            float3  _S1469 = throughput_5 * light_3.radiance;
            float _S1470 = powerHeuristic(light_3.density, _S1468);
            float3  _S1471 = pathColor(_S1469 * make_float3 (_S1465 * _S1470), throughput_4, 0.0f);
            float3  _S1472 = _slang_select(_S1449, _S1471,_S1382);
            if(replay_2)
            {
                viewed_0 = b_10 == _S1398;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1473 = _S1387 == 2U;
                if(_S1473)
                {
                    float _S1474 = resamplingTarget(_S1472);
                    passes_0 = _S1474 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1475 = Shift_x24init_0(_S1472, 1.0f);
                    _S1381 = int(0);
                    ended_0 = _S1475;
                    spread_2 = _S1448;
                    threshold_2 = width_6;
                    spectral_weight_0 = throughput_5;
                    layer_0 = b_10;
                    break;
                }
                _S1381 = int(0);
                ended_0 = _S1383;
                spread_2 = _S1448;
                threshold_2 = width_6;
                spectral_weight_0 = throughput_5;
                layer_0 = b_10;
                break;
            }
            bool _S1476 = !replay_2;
            if(_S1476)
            {
                Reservoir candidate_3 = _S1417;
                uint _S1477 = extractBits_0(_S1417.path, 24U, 8U);
                uint _S1478 = insertBits_0(0U, _S1477, 24U, 8U);
                uint _S1479 = extractBits_0(_S1417.path, 10U, 2U);
                bool _S1480 = _S1479 == 1U;
                if(_S1480)
                {
                    float3  _S1481 = safeDivide(_S1472, _S1382);
                    (&candidate_3)->radiance = _S1481;
                }
                else
                {
                    uint _S1482 = insertBits_0(_S1478, b_10 + 1U, 5U, 5U);
                    uint _S1483 = insertBits_0(_S1482, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1483;
                }
                Reservoir _S1484 = withEnd(candidate_3, 0U, b_10, _S1472);
                offer(sel_7, _S1484, _S1472 * make_float3 (scale_4) / make_float3 (density_2));
                float _S1485 = survivalProbability(abs_0(throughput_5), density_2);
                uint _S1486 = stream(_S1410, b_10 + 128U);
                Random _S1487 = pcg(_S1486);
                bool _S1488 = _S1485 < (_S1487.value);
                if(_S1488)
                {
                    _S1380 = true;
                }
                else
                {
                    uint _S1489 = (fcptMaxBounces());
                    _S1380 = b_10 >= _S1489;
                }
                if(_S1380)
                {
                    _S1381 = int(0);
                    ended_0 = _S1383;
                    spread_2 = _S1448;
                    threshold_2 = width_6;
                    spectral_weight_0 = throughput_5;
                    layer_0 = b_10;
                    break;
                }
                float _S1490 = density_2 * _S1485;
                density_2 = _S1490;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1491 = stream(_S1410, b_10);
            float3  _S1492 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1491, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1492;
            NEEVertex _S1493 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1382, (&ray_2)->origin);
            nee_vertex_0 = _S1493;
            Vertex _S1494 = scatteredVertex_0(false);
            prev_0 = _S1494;
            float _S1495 = (&prev_0)->pdf;
            FKRay _S1496 = ray_2;
            FKHit _S1497 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1498 = (fcptTraverseInstanceBVH((_S1496), (true), (4.294967296e+09f), (false), (_S1497), (false)));
            hit_4 = _S1498;
            b_8 = b_10;
            throughput_3 = throughput_5;
            wavelength_6 = _S1448;
            width_3 = width_6;
            sky_pdf_0 = _S1495;
        }
        if(_S1381 != int(1))
        {
            width_3 = threshold_2;
            throughput_3 = spectral_weight_0;
            b_8 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1383;
        spread_2 = wavelength_6;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1499 = b_8 == 4294967295U;
    bool _S1500 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1500)
    {
        bool _S1501 = !(&nee_vertex_0)->none;
        float _S1502 = _slang_select(_S1501, sky_pdf_0,0.0f);
        float _S1503 = escapeWeight_0(_S1502, (&ray_2)->unit_direction);
        float3  _S1504 = environment_0((&ray_2)->unit_direction, b_8, (&prev_0)->lobe);
        float3  _S1505 = pathColor(throughput_3 * _S1504, throughput_4, 0.0f);
        if(replay_2)
        {
            bool _S1506 = b_8 == _S1398;
            if(_S1506)
            {
                passes_0 = _S1387 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1505 * make_float3 (_S1503) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1397)
            {
                passes_0 = _S1394;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_8 == _S1385;
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
                return Shift_x24init_0(_S1505 * make_float3 (_S1503), 1.0f);
            }
            return _S1383;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1507 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1508 = _S1507 == 1U;
        if(_S1508)
        {
            uint _S1509 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1510 = _S1509 == b_8;
            float _S1511 = _slang_select(_S1510, 1.0f,_S1503);
            float3  _S1512 = safeDivide(_S1505 * make_float3 (_S1511), _S1382);
            (&candidate_4)->radiance = _S1512;
        }
        else
        {
            bool _S1513 = (&prev_0)->rough;
            if(_S1513)
            {
                uint _S1514 = insertBits_0(_S1412, b_8 + 1U, 5U, 5U);
                uint _S1515 = insertBits_0(_S1514, 3U, 10U, 2U);
                uint _S1516 = insertBits_0(_S1515, (&prev_0)->lobe, 15U, 3U);
                bool _S1517 = (&prev_0)->inside;
                uint _S1518 = _slang_select(_S1517, 1U,0U);
                uint _S1519 = insertBits_0(_S1516, _S1518, 22U, 1U);
                (&candidate_4)->path = _S1519;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1520 = _S1505 * make_float3 (_S1503);
        Reservoir _S1521 = withEnd(candidate_4, 3U, b_8, _S1520);
        offer(sel_7, _S1521, _S1520 * make_float3 (scale_4) / make_float3 (density_2));
        return _S1383;
    }
    float3  _S1522 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1522;
    bool _S1523 = (fcptVaryingUsed());
    if(_S1523)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1524 = !replay_2;
        if(_S1524)
        {
            float3  _S1525 = pathColor(throughput_3 * glowed_0, throughput_4, 0.0f);
            float3  _S1526 = _S1525 / make_float3 (density_2);
            float3  _S1527 = sel_7->glow + _S1526;
            sel_7->glow = _S1527;
        }
        float3  _S1528 = throughput_3 * weight_2;
        throughput_3 = _S1528;
    }
    else
    {
        float3  _S1529 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1530 = throughput_3 * _S1529;
        throughput_3 = _S1530;
    }
    float _S1531 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1532 = b_8 + 1U;
    b_8 = _S1532;
    layer_0 = 0U;
    width_3 = _S1531;
    passes_0 = false;
    wavelength_6 = 0.0f;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_6 = false;
    spectral_weight_0 = throughput_4;
    float3  chain_throughput_0 = _S1382;
    float3  reconnection_0 = _S1382;
    viewed_0 = _S1499;
    for(;;)
    {
        bool _S1533 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1380 = _S1387 == 1U;
        }
        else
        {
            _S1380 = false;
        }
        bool _S1534;
        if(_S1380)
        {
            _S1534 = b_8 == _S1386;
        }
        else
        {
            _S1534 = false;
        }
        bool _S1535;
        if(_S1534)
        {
            bool _S1536 = ((&hit_4)->instance_index) != (_S1399.instance_index);
            if(_S1536)
            {
                _S1535 = true;
            }
            else
            {
                _S1535 = ((&hit_4)->triangle_index) != (_S1399.triangle_index);
            }
        }
        else
        {
            _S1535 = false;
        }
        if(_S1535)
        {
            return _S1383;
        }
        FKMedium _S1537 = Medium_x24init_0(_S1382, _S1382, 0.0f);
        BSDFMaterial _S1538 = Material_x24init_0(_S1382, _S1382, 0.0f, 0.0f, 0.0f, 0.0f, _S1382, throughput_4, 1.0f, _S1382, _S1382, 0.5f, 0.0f, 0.0f, _S1382, 0.0f, _S1382, 0.0f);
        FKMedium _S1539 = _S1537;
        FKSurface _S1540 = Surface_x24init_0(_S1382, _S1382, 0.0f, &_S1538, false, 0U, 1.0f, false, &_S1539, 4294967295U, _S1382);
        bool _S1541 = !_S1533;
        bool scatter_2;
        bool is_inside_7;
        float geometry_density_2;
        float3  throughput_6;
        FKSurface surface_12;
        if(_S1541)
        {
            uint _S1542 = stream(_S1410, b_8);
            uint _S1543 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKSurface _S1544 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1542), (width_3), (layer_0), (b_8), (_S1543), ((&ray_2)->unit_direction)));
            bool _S1545 = !passes_0;
            FKSurface _S1546 = _S1544;
            FKSurface _S1547 = emitting_0(&_S1546, _S1545);
            uint _S1548 = stream(_S1410, b_8 + 256U);
            Random _S1549 = pcg(_S1548);
            FKSurface _S1550 = _S1547;
            FKSurface _S1551 = uncovered_0(&_S1550, _S1549.value);
            float _S1552 = facingSign(_S1551.material.transmission, _S1551.geometry_n, (&ray_2)->unit_direction);
            bool _S1553 = _S1552 < 0.0f;
            bool _S1554 = (_S1551.material.transmission) > 0.0f;
            if(_S1554)
            {
                bool _S1555 = arrivesBehind_0((&ray_2)->unit_direction, _S1551.geometry_n);
                scatter_2 = _S1555;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1556 = _S1551;
            FKSurface _S1557 = facingRay_0(&_S1556, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1558 = arrivesBehind_0((&ray_2)->unit_direction, _S1557.geometry_n);
                is_inside_7 = _S1558;
            }
            else
            {
                is_inside_7 = scatter_2;
            }
            if(is_inside_7)
            {
                float _S1559 = (&hit_4)->distance;
                float _S1560 = upsample(_S1557.material.absorption, wavelength_6);
                float3  _S1561 = make_float3 (_S1560);
                bool _S1562 = wavelength_6 > 0.0f;
                float3  _S1563 = _slang_select(_S1562, _S1561,_S1557.material.absorption);
                float3  _S1564 = beerLambert(_S1559, _S1563);
                float3  _S1565 = throughput_3 * _S1564;
                throughput_6 = _S1565;
            }
            else
            {
                throughput_6 = throughput_3;
            }
            bool _S1566 = !_S1557.skip;
            float geometry_density_3 = geometryDensity(_S1557.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1567 = b_8 == _S1532;
            if(_S1567)
            {
                float _S1568 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1568;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1569 = geometry_density_2;
            scatter_2 = _S1566;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1569;
            surface_12 = _S1557;
            turned_1 = _S1553;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_12 = _S1540;
            throughput_6 = throughput_3;
            is_inside_7 = is_inside_6;
        }
        bool _S1570 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1571 = surface_12;
        float _S1572 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        bool _S1573 = (fcptDispersionUsed());
        bool _S1574;
        if(_S1573)
        {
            _S1574 = wavelength_6 == 0.0f;
        }
        else
        {
            _S1574 = false;
        }
        bool _S1575;
        if(_S1574)
        {
            _S1575 = scatter_2;
        }
        else
        {
            _S1575 = false;
        }
        bool _S1576;
        if(_S1575)
        {
            bool _S1577 = dispersive(surface_12.material);
            _S1576 = _S1577;
        }
        else
        {
            _S1576 = false;
        }
        float3  throughput_7;
        if(_S1576)
        {
            uint _S1578 = stream(_S1410, 512U);
            Random _S1579 = pcg(_S1578);
            uint _S1580 = extractBits_0(_S1384, 25U, 7U);
            float _S1581 = (float(_S1580) + _S1579.value) / 128.0f;
            uint _S1582 = extractBits_0(_S1384, 24U, 1U);
            bool _S1583 = _S1582 == 1U;
            float _S1584 = _slang_select(_S1583, _S1581,_S1579.value);
            float2  _S1585 = sampleWavelength(_S1584);
            float wavelength_7 = _S1585.x;
            float3  _S1586 = wavelengthWeights(wavelength_7);
            float3  _S1587 = _S1586 / make_float3 (_S1585.y);
            float _S1588 = upsample(throughput_6, wavelength_7);
            float3  _S1589 = make_float3 (_S1588);
            float _S1590 = upsample(scatter_in_0, wavelength_7);
            float3  _S1591 = make_float3 (_S1590);
            scatter_in_0 = _S1591;
            float _S1592 = upsample(extinction_in_0, wavelength_7);
            float3  _S1593 = make_float3 (_S1592);
            extinction_in_0 = _S1593;
            wavelength_6 = wavelength_7;
            throughput_7 = _S1589;
            spectral_weight_0 = _S1587;
        }
        else
        {
            throughput_7 = throughput_6;
        }
        bool _S1594 = wavelength_6 > 0.0f;
        BSDFMaterial _S1595;
        if(_S1594)
        {
            BSDFMaterial _S1596 = atWavelength(surface_12.material, wavelength_6);
            _S1595 = _S1596;
        }
        else
        {
            _S1595 = surface_12.material;
        }
        float2  _S1597 = wavelengthEta(_S1595, _S1572, wavelength_6);
        bool _S1598;
        if(scatter_2)
        {
            bool _S1599 = neeDecision(_S1595, _S1572, _S1597.x, _S1597.y);
            _S1598 = _S1599;
        }
        else
        {
            _S1598 = false;
        }
        bool _S1600;
        if(passes_0)
        {
            _S1600 = true;
        }
        else
        {
            _S1600 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1600)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1598;
        }
        bool _S1601 = (fcptHairUsed());
        bool _S1602;
        if(_S1601)
        {
            float3  _S1603 = surface_12.hair;
            _S1602 = (dot_0(_S1603, _S1603)) > 0.0f;
        }
        else
        {
            _S1602 = false;
        }
        bool _S1604;
        if(_S1602)
        {
            _S1604 = true;
        }
        else
        {
            BSDFMaterial _S1605 = _S1595;
            bool _S1606 = isTranslucent_0(&_S1605);
            _S1604 = _S1606;
        }
        bool _S1607;
        if(_S1604)
        {
            _S1607 = true;
        }
        else
        {
            bool _S1608 = (_S1595.transmission) > 0.0f;
            if(_S1608)
            {
                uint _S1609 = (fcptLayers((hit_4)));
                _S1607 = _S1609 == 1U;
            }
            else
            {
                _S1607 = false;
            }
        }
        BSDFMaterial _S1610 = _S1595;
        float3  emission_0;
        if(_S1533)
        {
            float3  _S1611 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1611;
        }
        else
        {
            emission_0 = _S1610.emissive;
        }
        float _S1612 = rgb_to_greyscale(emission_0);
        bool _S1613 = _S1612 > 0.0f;
        float3  emission_1;
        if(_S1613)
        {
            NEEVertex _S1614 = nee_vertex_0;
            FKHit _S1615 = hit_4;
            float _S1616 = emissionWeight_0(&_S1614, &_S1615, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1616);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1617;
        if(replay_2)
        {
            _S1617 = _S1387 == 1U;
        }
        else
        {
            _S1617 = false;
        }
        bool _S1618;
        if(_S1617)
        {
            _S1618 = b_8 > _S1386;
        }
        else
        {
            _S1618 = false;
        }
        bool _S1619;
        if(_S1618)
        {
            _S1619 = b_8 == _S1385;
        }
        else
        {
            _S1619 = false;
        }
        bool _S1620;
        if(_S1619)
        {
            bool _S1621 = _S1388 == 1U;
            if(_S1621)
            {
                _S1620 = true;
            }
            else
            {
                _S1620 = _S1388 == 2U;
            }
        }
        else
        {
            _S1620 = false;
        }
        if(_S1620)
        {
            bool _S1622 = _S1533 != (_S1388 == 2U);
            if(_S1622)
            {
                return _S1383;
            }
            float3  _S1623 = pathColor(throughput_7 * emission_1, spectral_weight_0, wavelength_6);
            return Shift_x24init_0(_S1623 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1624 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1625 = _S1624 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1626 = insertBits_0(_S1412, b_8, 5U, 5U);
        uint _S1627 = insertBits_0(_S1626, 1U, 10U, 2U);
        uint _S1628 = insertBits_0(_S1627, (&prev_0)->lobe, 15U, 3U);
        bool _S1629 = (&prev_0)->inside;
        uint _S1630 = _slang_select(_S1629, 1U,0U);
        uint _S1631 = insertBits_0(_S1628, _S1630, 22U, 1U);
        (&here_0)->path = _S1631;
        uint _S1632 = (&here_0)->path;
        uint _S1633 = _slang_select(_S1594, 1U,0U);
        uint _S1634 = insertBits_0(_S1632, _S1633, 23U, 1U);
        (&here_0)->path = _S1634;
        float _S1635 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1635;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1636;
        if(replay_2)
        {
            _S1636 = _S1387 == 1U;
        }
        else
        {
            _S1636 = false;
        }
        bool _S1637;
        if(_S1636)
        {
            _S1637 = b_8 == _S1386;
        }
        else
        {
            _S1637 = false;
        }
        bool _S1638 = b_8 == _S1398;
        bool _S1639;
        if(_S1638)
        {
            bool _S1640 = !scatter_2;
            if(_S1640)
            {
                _S1639 = true;
            }
            else
            {
                bool _S1641 = _S1387 != 1U;
                if(_S1641)
                {
                    _S1639 = _S1387 != 3U;
                }
                else
                {
                    _S1639 = false;
                }
            }
        }
        else
        {
            _S1639 = false;
        }
        bool _S1642;
        if(_S1639)
        {
            _S1642 = _S1387 == 2U;
        }
        else
        {
            _S1642 = false;
        }
        bool _S1643;
        if(_S1642)
        {
            _S1643 = !_S1570;
        }
        else
        {
            _S1643 = false;
        }
        bool _S1644;
        if(_S1643)
        {
            _S1644 = _S1388 != 4U;
        }
        else
        {
            _S1644 = false;
        }
        bool _S1645 = _S1386 == _S1385;
        bool _S1646;
        if(_S1645)
        {
            _S1646 = _S1388 == 0U;
        }
        else
        {
            _S1646 = false;
        }
        bool _S1647;
        if(_S1646)
        {
            _S1647 = ((&hit_4)->instance_index) == (_S1399.instance_index);
        }
        else
        {
            _S1647 = false;
        }
        bool _S1648;
        if(_S1647)
        {
            _S1648 = ((&hit_4)->triangle_index) == (_S1399.triangle_index);
        }
        else
        {
            _S1648 = false;
        }
        bool _S1649;
        if(_S1648)
        {
            _S1649 = _S1570;
        }
        else
        {
            _S1649 = false;
        }
        bool _S1650 = _slang_select(_S1637, _S1649,_S1644);
        bool _S1651;
        if(nee_0)
        {
            _S1651 = _slang_select(replay_2, _S1650,scatter_2);
        }
        else
        {
            _S1651 = false;
        }
        TreeSample _S1652 = TreeSample_x24init_0(_S1382, _S1382, 0.0f, 0U);
        uint2  _S1653 = make_uint2 (0U);
        float2  _S1654 = make_float2 (0.0f);
        FKHit _S1655 = Hit_x24init_0(_S1654, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1656 = _S1655;
        ShadowContext _S1657 = ShadowContext_x24init_0(_S1382, _S1382, _S1653, _S1382, 0U, 0U, false, 0.0f, 0.0f, &_S1656, false);
        ShadowContext context_5;
        if(nee_0)
        {
            uint _S1658 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKMedium _S1659 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1660 = surface_12;
            FKHit _S1661 = hit_4;
            FKMedium _S1662 = _S1659;
            ShadowContext _S1663 = shadowContext_0(&_S1660, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_8, _S1658, (&hit_4)->distance, width_3, &_S1661, _S1602, &_S1662);
            context_5 = _S1663;
        }
        else
        {
            context_5 = _S1657;
        }
        float3  throughput_8;
        float3  lit_0;
        if(_S1651)
        {
            float3  _S1664 = (&ray_2)->origin;
            if(_S1602)
            {
                throughput_8 = _S1382;
            }
            else
            {
                throughput_8 = _S1571.smooth_n;
            }
            FKSurface _S1665 = surface_12;
            uint _S1666 = stream(_S1410, b_8 + 64U);
            ShadowContext _S1667 = context_5;
            TreeSample _S1668 = sampleLightTree_0(_S1664, throughput_8, surface_12.geometry_n, surface_12.geometry_offset, _S1607, _S1666, &_S1667);
            bool _S1669 = any_1((_S1668.radiance) != _S1382);
            if(_S1669)
            {
                if(_S1602)
                {
                    uint _S1670 = (fcptMaxBounces());
                    bool _S1671 = b_8 < _S1670;
                    FKSurface _S1672 = surface_12;
                    TreeSample _S1673 = _S1668;
                    float3  _S1674 = hairLight_0(&_S1672, (&ray_2)->unit_direction, &_S1673, _S1671);
                    lit_0 = _S1674;
                }
                else
                {
                    float _S1675 = _S1597.x;
                    float _S1676 = _S1597.y;
                    uint _S1677 = (fcptMaxBounces());
                    bool _S1678 = b_8 < _S1677;
                    TreeSample _S1679 = _S1668;
                    BSDFMaterial _S1680 = _S1595;
                    float3  _S1681 = lightBSDF_0((&ray_2)->unit_direction, &_S1679, _S1571.smooth_n, _S1665.geometry_n, &_S1680, _S1675, _S1676, _S1678, surface_12.random_state);
                    lit_0 = _S1681;
                }
            }
            else
            {
                lit_0 = _S1382;
            }
            light_3 = _S1668;
        }
        else
        {
            light_3 = _S1652;
            lit_0 = _S1382;
        }
        bool viewed_1;
        bool refracted_6;
        bool wrong_side_0;
        bool _S1682;
        bool _S1683;
        float density_4;
        if(_S1637)
        {
            bool _S1684 = !_S1570;
            if(_S1684)
            {
                return _S1383;
            }
            uint _S1685 = extractBits_0(_S1384, 23U, 1U);
            bool _S1686 = _S1594 != (_S1685 == 1U);
            if(_S1686)
            {
                return _S1383;
            }
            float3  throughput_9 = throughput_7 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1645)
            {
                viewed_1 = _S1388 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                float3  _S1687 = pathColor(throughput_9 * emission_1, spectral_weight_0, wavelength_6);
                return Shift_x24init_0(_S1687 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1645)
            {
                refracted_6 = _S1388 == 0U;
            }
            else
            {
                refracted_6 = false;
            }
            if(refracted_6)
            {
                bool _S1688 = !nee_0;
                if(_S1688)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1689 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1689 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1383;
                }
                float3  _S1690 = pathColor(throughput_9 * lit_0, spectral_weight_0, wavelength_6);
                return Shift_x24init_0(_S1690 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1645)
            {
                wrong_side_0 = _S1388 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1691 = !nee_0;
                if(_S1691)
                {
                    return _S1383;
                }
                bool _S1692 = (fcptWorldReadsPath());
                if(_S1692)
                {
                    float _S1693 = environmentPdf_0(r_8->dir);
                    uint _S1694 = b_8 + 1U;
                    FKSurface _S1695 = surface_12;
                    float3  _S1696 = skyColor_0((&ray_2)->unit_direction, r_8->dir, &_S1695, _S1597, is_inside_7, _S1693, surface_12.random_state, _S1694);
                    float3  _S1697 = pathColor(throughput_9 * (_S1696 * r_8->radiance), spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1697 / make_float3 (r_8->jac), density_5 / r_8->jac);
                }
                float _S1698 = environmentPdf_0(r_8->dir);
                float3  _S1699 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_12, _S1597, is_inside_7, _S1698, surface_12.random_state);
                float3  _S1700 = pathColor(throughput_9 * _S1699 * r_8->radiance, spectral_weight_0, wavelength_6);
                return Shift_x24init_0(_S1700 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1701 = extractBits_0(_S1384, 21U, 1U);
            bool _S1702 = nee_0 != (_S1701 == 1U);
            if(_S1702)
            {
                return _S1383;
            }
            throughput_8 = throughput_9;
            density_4 = density_5;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1638;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1703 = !scatter_2;
                if(_S1703)
                {
                    refracted_6 = true;
                }
                else
                {
                    bool _S1704 = _S1387 != 1U;
                    if(_S1704)
                    {
                        refracted_6 = _S1387 != 3U;
                    }
                    else
                    {
                        refracted_6 = false;
                    }
                }
            }
            else
            {
                refracted_6 = false;
            }
            if(refracted_6)
            {
                bool _S1705 = _S1387 == 2U;
                if(_S1705)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1570;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1388 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1602)
                    {
                        return _S1383;
                    }
                    uint _S1706 = stream(_S1410, b_8 + 448U);
                    FKRay _S1707 = ray_2;
                    FKSurface _S1708 = surface_12;
                    ShadowContext _S1709 = context_5;
                    SkySample _S1710 = sampleSky_0(&_S1707, &_S1708, _S1597, is_inside_7, _S1706, surface_12.random_state, &_S1709);
                    float3  _S1711 = pathColor(throughput_7 * _S1710.color, spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1711, 1.0f);
                }
                if(_S1705)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1570;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1712 = rgb_to_greyscale(light_3.radiance);
                    bool _S1713 = !(_S1712 > 0.0f);
                    if(_S1713)
                    {
                        return _S1383;
                    }
                    float3  _S1714 = pathColor(throughput_7 * lit_0, spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1714, 1.0f);
                }
                if(_S1397)
                {
                    passes_0 = _S1388 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1533;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1715 = pathColor(throughput_7 * emission_1, spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1715, 1.0f);
                }
                if(_S1397)
                {
                    passes_0 = _S1388 == 1U;
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
                    passes_0 = !_S1570;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1716 = pathColor(throughput_7 * emission_1, spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1716, 1.0f);
                }
                return _S1383;
            }
            else
            {
                bool _S1717 = !replay_2;
                if(_S1717)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1718 = b_8 > 0U;
                    if(_S1718)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1625)
                        {
                            float3  _S1719 = safeDivide(throughput_7 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1719;
                        }
                        else
                        {
                            if(_S1570)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1720 = pathColor(throughput_7 * emission_1, spectral_weight_0, wavelength_6);
                        Reservoir _S1721 = withEnd(candidate_5, 1U, b_8, _S1720);
                        offer(sel_7, _S1721, _S1720 * make_float3 (scale_4) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1722 = pathColor(throughput_7 * emission_1, spectral_weight_0, wavelength_6);
                        float3  _S1723 = sel_7->glow + _S1722;
                        sel_7->glow = _S1723;
                    }
                    if(nee_0)
                    {
                        float3  _S1724 = pathColor(throughput_7 * lit_0, spectral_weight_0, wavelength_6);
                        Reservoir candidate_6 = chain_0;
                        if(_S1625)
                        {
                            float3  _S1725 = safeDivide(_S1724, chain_throughput_0);
                            (&candidate_6)->radiance = _S1725;
                        }
                        else
                        {
                            if(_S1570)
                            {
                                candidate_6 = here_0;
                                uint _S1726 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1726;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1727 = insertBits_0(_S1412, b_8 + 1U, 5U, 5U);
                                uint _S1728 = insertBits_0(_S1727, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1728;
                            }
                        }
                        Reservoir _S1729 = withEnd(candidate_6, 0U, b_8, _S1724);
                        offer(sel_7, _S1729, _S1724 * make_float3 (scale_4) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1602)
                        {
                            _S1682 = false;
                        }
                        else
                        {
                            bool _S1730 = environmentMapped_0();
                            _S1682 = _S1730;
                        }
                    }
                    else
                    {
                        _S1682 = false;
                    }
                    if(_S1682)
                    {
                        uint _S1731 = (fcptMaxBounces());
                        _S1683 = b_8 < _S1731;
                    }
                    else
                    {
                        _S1683 = false;
                    }
                    if(_S1683)
                    {
                        uint _S1732 = stream(_S1410, b_8 + 448U);
                        FKRay _S1733 = ray_2;
                        FKSurface _S1734 = surface_12;
                        ShadowContext _S1735 = context_5;
                        SkySample _S1736 = sampleSky_0(&_S1733, &_S1734, _S1597, is_inside_7, _S1732, surface_12.random_state, &_S1735);
                        float3  _S1737 = pathColor(throughput_7 * _S1736.color, spectral_weight_0, wavelength_6);
                        Reservoir candidate_7 = chain_0;
                        if(_S1625)
                        {
                            float3  _S1738 = safeDivide(_S1737, chain_throughput_0);
                            (&candidate_7)->radiance = _S1738;
                        }
                        else
                        {
                            if(_S1570)
                            {
                                candidate_7 = here_0;
                                uint _S1739 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1739;
                                (&candidate_7)->dir = _S1736.dir;
                                (&candidate_7)->radiance = _S1736.radiance;
                            }
                            else
                            {
                                uint _S1740 = insertBits_0(_S1412, b_8 + 1U, 5U, 5U);
                                uint _S1741 = insertBits_0(_S1740, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1741;
                            }
                        }
                        Reservoir _S1742 = withEnd(candidate_7, 4U, b_8, _S1737);
                        offer(sel_7, _S1742, _S1737 * make_float3 (scale_4) / make_float3 (density_2));
                    }
                }
            }
            throughput_8 = throughput_7;
            density_4 = density_2;
        }
        bool _S1743;
        bool _S1744;
        bool _S1745;
        bool straight_0;
        bool _S1746;
        bool _S1747;
        bool _S1748;
        bool _S1749;
        bool _S1750;
        bool _S1751;
        bool _S1752;
        bool _S1753;
        bool _S1754;
        bool _S1755;
        bool _S1756;
        bool _S1757;
        float density_6;
        float sky_pdf_2;
        float spread_5;
        uint b_11;
        float3  throughput_10;
        float3  throughput_11;
        float3  throughput_12;
        if(scatter_2)
        {
            MaterialTerms _S1758 = MaterialTerms_x24init_0(0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S1382, 0.0f, 0.0f, 0.0f, false, 0.0f);
            AnisotropicFrame _S1759 = AnisotropicFrame_x24init_0(_S1382, _S1654);
            ViewTerms _S1760 = ViewTerms_x24init_0(_S1382, _S1382, &_S1759, _S1382, 0.0f, _S1382, _S1382, _S1382, 0.0f, _S1382);
            bool _S1761 = !_S1602;
            MaterialTerms terms_11;
            ViewTerms view_terms_10;
            if(_S1761)
            {
                MaterialTerms terms_12 = precomputeMaterial(_S1595, _S1597.x, _S1597.y);
                ViewTerms _S1762 = precomputeView((&ray_2)->unit_direction, _S1571.smooth_n, _S1595, terms_12);
                terms_11 = terms_12;
                view_terms_10 = _S1762;
            }
            else
            {
                terms_11 = _S1758;
                view_terms_10 = _S1760;
            }
            if(replay_2)
            {
                viewed_1 = _S1638;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1763 = extractBits_0(_S1384, 15U, 3U);
            uint _S1764 = extractBits_0(_S1384, 18U, 3U);
            uint _S1765 = _slang_select(_S1637, _S1764,_S1763);
            float3  _S1766 = r_8->dir;
            bool refracted_7 = _S1765 == 1U;
            SampleBSDF _S1767 = SampleBSDF_x24init_0(_S1382, _S1382, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_7 = _S1767;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1768 = extractBits_0(_S1384, 22U, 1U);
                bool _S1769 = is_inside_7 != (_S1768 == 1U);
                if(_S1769)
                {
                    return _S1383;
                }
                bool _S1770 = _S1387 == 1U;
                if(_S1770)
                {
                    float3  _S1771 = (fcptHitPosition((_S1399)));
                    throughput_10 = _S1771;
                }
                else
                {
                    throughput_10 = reconnection_0;
                }
                if(refracted_7)
                {
                    refracted_6 = true;
                }
                else
                {
                    BSDFMaterial _S1772 = _S1595;
                    bool _S1773 = isTranslucent_0(&_S1772);
                    if(_S1773)
                    {
                        refracted_6 = _S1765 == 0U;
                    }
                    else
                    {
                        refracted_6 = false;
                    }
                    if(refracted_6)
                    {
                        float3  _S1774 = throughput_10 - (&ray_2)->origin;
                        float3  _S1775 = _slang_select(_S1770, _S1774,_S1766);
                        wrong_side_0 = (dot_0(_S1571.smooth_n, _S1775) * _S1572) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_6 = wrong_side_0;
                }
                if(_S1770)
                {
                    float3  _S1776 = (&ray_2)->origin;
                    FKSurface _S1777 = surface_12;
                    float3  _S1778 = - _S1571.smooth_n;
                    bool _S1779 = is_inside_7 != refracted_6;
                    float3  _S1780 = _slang_select(_S1779, _S1778,_S1571.smooth_n);
                    float3  _S1781 = throughput_10 - (_S1776 + make_float3 (_S1777.geometry_offset) * _S1780);
                    float3  _S1782 = ((((_S1781)) * make_float3(rnorm3df(((_S1781)).x, ((_S1781)).y, ((_S1781)).z))));
                    reconnection_1 = _S1782;
                }
                else
                {
                    reconnection_1 = _S1766;
                }
                if(_S1602)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1783 = wrongSide_0(is_inside_7, refracted_6, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1783;
                }
                if(wrong_side_0)
                {
                    return _S1383;
                }
                float3  _S1784 = throughput_10;
                throughput_10 = reconnection_1;
                b_11 = _S1765;
                wrong_side_0 = false;
                reconnection_1 = _S1784;
            }
            else
            {
                bool _S1785 = !_S1637;
                if(_S1785)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1786;
                    if(_S1602)
                    {
                        SampleBSDF _S1787 = (fcptSampleHair((surface_12.hair), (_S1595.albedo), (_S1595.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1786 = _S1787;
                    }
                    else
                    {
                        SampleBSDF _S1788 = sampleBSDF((&ray_2)->unit_direction, _S1571.smooth_n, _S1595, _S1597.x, _S1597.y, surface_12.random_state, _S1654, terms_11, view_terms_10);
                        _S1786 = _S1788;
                    }
                    bsdf_sampled_0 = _S1786;
                    if(_S1602)
                    {
                        refracted_6 = !(((&bsdf_sampled_0)->pdf) > 0.0f);
                    }
                    else
                    {
                        refracted_6 = false;
                    }
                    if(refracted_6)
                    {
                        if(replay_2)
                        {
                            return _S1383;
                        }
                        break;
                    }
                    if(_S1602)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1789 = wrongSide_0(is_inside_7, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1789;
                    }
                    if(wrong_side_0)
                    {
                        _S1682 = (_S1595.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1682 = false;
                    }
                    if(_S1682)
                    {
                        float _S1790 = _S1597.x;
                        float _S1791 = _S1597.y;
                        ViewTerms _S1792 = precomputeView((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1595, terms_11);
                        SampleBSDF _S1793 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1595, _S1790, _S1791, (&bsdf_sampled_0)->random_state, _S1654, terms_11, _S1792);
                        (&bsdf_sampled_0)->unit_direction = _S1793.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1793.refracted;
                        (&bsdf_sampled_0)->throughput = _S1793.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1794 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1794;
                        }
                    }
                    uint _S1795 = (&bsdf_sampled_0)->lobe;
                    float3  _S1796 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1797 = (&bsdf_sampled_0)->refracted;
                    lobe_7 = bsdf_sampled_0;
                    float _S1798 = (&bsdf_sampled_0)->pdf;
                    float _S1799 = _slang_select(wrong_side_0, 0.0f,_S1798);
                    (&lobe_7)->pdf = _S1799;
                    throughput_10 = _S1796;
                    b_11 = _S1795;
                    refracted_6 = _S1797;
                }
                else
                {
                    throughput_10 = _S1766;
                    b_11 = _S1765;
                    wrong_side_0 = false;
                    refracted_6 = refracted_7;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1682 = true;
            }
            else
            {
                _S1682 = _S1637;
            }
            if(_S1682)
            {
                if(_S1602)
                {
                    SampleBSDF _S1800 = (fcptConnectHair((surface_12.hair), (_S1595.albedo), (_S1595.specular_tint), ((&ray_2)->unit_direction), (throughput_10)));
                    lobe_7 = _S1800;
                }
                else
                {
                    float3  _S1801 = (&ray_2)->unit_direction;
                    float _S1802 = sign_0(_S1572);
                    float3  _S1803 = _S1571.smooth_n * make_float3 (_S1802);
                    float _S1804 = dot_0(_S1803, throughput_10);
                    float _S1805 = _S1595.roughness;
                    float _S1806 = _S1805 * _S1805;
                    switch(b_11)
                    {
                    case 0U:
                        {
                            float _S1807 = _S1597.x;
                            float _S1808 = _S1597.y;
                            HalfTerms _S1809 = sampledHalf(_S1801, _S1571.smooth_n, _S1595, _S1807, _S1808, surface_12.random_state, terms_11, view_terms_10);
                            float _S1810 = diffusePDF(_S1804, 0.0f, (F32_abs((_S1572))), _S1806, _S1809, _S1807, _S1808);
                            float3  _S1811 = diffuseBSDF(throughput_10, _S1803, _S1806, _S1595, _S1809);
                            density_6 = _S1810;
                            throughput_11 = _S1811;
                            break;
                        }
                    case 1U:
                        {
                            float l_dot_h_9 = 0.0f;
                            float _S1812 = _S1597.x;
                            float _S1813 = _S1597.y;
                            HalfTerms _S1814 = refractedHalf(_S1801, throughput_10, _S1571.smooth_n, _S1595, _S1812, _S1813, terms_11, view_terms_10, &l_dot_h_9);
                            float _S1815 = refractPDF(_S1804, l_dot_h_9, (F32_abs((_S1572))), _S1806, _S1814, _S1812, _S1813);
                            float3  _S1816 = refractBSDF(throughput_10, _S1803, _S1806, _S1595, _S1814);
                            density_6 = _S1815;
                            throughput_11 = _S1816;
                            break;
                        }
                    case 4U:
                        {
                            float _S1817 = _S1597.x;
                            float _S1818 = _S1597.y;
                            HalfTerms _S1819 = reflectedHalf(_S1801, throughput_10, _S1595, _S1817, _S1818, terms_11, view_terms_10);
                            float _S1820 = sheenVelvetPDF(_S1804, 0.0f, (F32_abs((_S1572))), _S1806, _S1819, _S1817, _S1818);
                            float3  _S1821 = sheenVelvetBSDF(throughput_10, _S1803, _S1806, _S1595, _S1819);
                            density_6 = _S1820;
                            throughput_11 = _S1821;
                            break;
                        }
                    case 6U:
                        {
                            float _S1822 = _S1597.x;
                            float _S1823 = _S1597.y;
                            HalfTerms _S1824 = sampledHalf(_S1801, _S1571.smooth_n, _S1595, _S1822, _S1823, surface_12.random_state, terms_11, view_terms_10);
                            float _S1825 = toonPDF(_S1804, dot_0(throughput_10, _S1824.toon_axis), (F32_abs((_S1572))), _S1806, _S1824, _S1822, _S1823);
                            float3  _S1826 = toonBSDF(throughput_10, _S1803, _S1806, _S1595, _S1824);
                            density_6 = _S1825;
                            throughput_11 = _S1826;
                            break;
                        }
                    default:
                        {
                            float _S1827 = _S1597.x;
                            float _S1828 = _S1597.y;
                            HalfTerms _S1829 = reflectedHalf(_S1801, throughput_10, _S1595, _S1827, _S1828, terms_11, view_terms_10);
                            float _S1830 = reflectPDF(_S1804, 0.0f, (F32_abs((_S1572))), _S1806, _S1829, _S1827, _S1828);
                            float3  _S1831 = reflectBSDF(throughput_10, _S1803, _S1806, _S1595, _S1829);
                            density_6 = _S1830;
                            throughput_11 = _S1831;
                            break;
                        }
                    }
                    bool _S1832 = density_6 > 0.0f;
                    if(_S1832)
                    {
                        SampleBSDF _S1833 = SampleBSDF_x24init_0(throughput_10, throughput_11, surface_12.random_state, b_11 == 1U, b_11, density_6);
                        lobe_7 = _S1833;
                    }
                }
            }
            bool _S1834 = b_11 == 0U;
            if(_S1834)
            {
                _S1683 = true;
            }
            else
            {
                _S1683 = b_11 == 4U;
            }
            if(_S1683)
            {
                _S1743 = true;
            }
            else
            {
                _S1743 = b_11 == 6U;
            }
            if(_S1602)
            {
                _S1744 = false;
            }
            else
            {
                bool _S1835 = !_S1743;
                if(_S1835)
                {
                    bool _S1836 = (_S1595.roughness) == 0.0f;
                    if(_S1836)
                    {
                        _S1744 = true;
                    }
                    else
                    {
                        bool _S1837 = b_11 == 1U;
                        if(_S1837)
                        {
                            _S1744 = (_S1597.x) == (_S1597.y);
                        }
                        else
                        {
                            _S1744 = false;
                        }
                    }
                }
                else
                {
                    _S1744 = false;
                }
            }
            if(_S1761)
            {
                _S1745 = b_11 == 1U;
            }
            else
            {
                _S1745 = false;
            }
            if(_S1745)
            {
                straight_0 = (_S1595.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1746 = _S1761;
            }
            else
            {
                _S1746 = false;
            }
            if(_S1746)
            {
                _S1747 = b_11 == 1U;
            }
            else
            {
                _S1747 = false;
            }
            if(_S1747)
            {
                _S1748 = (_S1597.x) == (_S1597.y);
            }
            else
            {
                _S1748 = false;
            }
            BSDFMaterial _S1838 = _S1595;
            bool _S1839 = isTranslucent_0(&_S1838);
            if(_S1839)
            {
                _S1749 = _S1834;
            }
            else
            {
                _S1749 = false;
            }
            if(_S1749)
            {
                _S1750 = (dot_0(throughput_10, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1750 = false;
            }
            if(nee_0)
            {
                _S1751 = !_S1744;
            }
            else
            {
                _S1751 = false;
            }
            if(_S1751)
            {
                _S1752 = !wrong_side_0;
            }
            else
            {
                _S1752 = false;
            }
            if(_S1752)
            {
                float _S1840 = (&lobe_7)->pdf;
                float3  _S1841 = (&ray_2)->origin;
                float3  _S1842 = _slang_select(_S1607, _S1382,_S1571.smooth_n);
                float3  _S1843 = (&ray_2)->origin;
                FKSurface _S1844 = surface_12;
                float3  _S1845 = - _S1571.smooth_n;
                float3  _S1846 = _slang_select(_S1750, _S1845,_S1571.smooth_n);
                NEEVertex _S1847 = NEEVertex_x24init_0(false, _S1840, _S1841, _S1842, _S1843 + make_float3 (_S1844.geometry_offset) * _S1846);
                nee_vertex_0 = _S1847;
            }
            else
            {
                if(_S1602)
                {
                    _S1753 = true;
                }
                else
                {
                    bool _S1848 = b_11 != 1U;
                    if(_S1848)
                    {
                        _S1753 = true;
                    }
                    else
                    {
                        _S1753 = (_S1597.x) != (_S1597.y);
                    }
                }
                if(_S1753)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1849 = withinInverseFootprint((&lobe_7)->pdf, _S1743, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1850 = roughLobe((&lobe_7)->pdf, _S1743, _S1595.roughness);
            if(_S1637)
            {
                bool _S1851 = !_S1849;
                if(_S1851)
                {
                    return _S1383;
                }
                bool _S1852 = _S1388 != 1U;
                if(_S1852)
                {
                    _S1753 = _S1388 != 2U;
                }
                else
                {
                    _S1753 = false;
                }
                if(_S1753)
                {
                    float _S1853 = (&lobe_7)->pdf;
                    float _S1854 = _slang_select(nee_0, _S1853,0.0f);
                    float _S1855 = escapeWeight_0(_S1854, _S1766);
                    if(_S1645)
                    {
                        passes_0 = _S1394;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1856 = _slang_select(passes_0, _S1855,1.0f);
                    return Shift_x24init_0(throughput_8 * ((&lobe_7)->throughput * make_float3 ((&lobe_7)->pdf)) * r_8->radiance * make_float3 (_S1856) / make_float3 (r_8->jac), density_4 * (&lobe_7)->pdf / r_8->jac);
                }
                float3  _S1857 = throughput_8 * make_float3 ((&lobe_7)->pdf);
                float _S1858 = density_4 * (&lobe_7)->pdf;
                throughput_11 = _S1857;
                density_6 = _S1858;
            }
            else
            {
                throughput_11 = throughput_8;
                density_6 = density_4;
            }
            uint _S1859 = (fcptLayers((hit_4)));
            bool _S1860 = b_11 == 1U;
            bool _S1861 = passesLayer_0(_S1859, _S1860, passes_0);
            if(viewed_1)
            {
                _S1753 = _S1861;
            }
            else
            {
                _S1753 = false;
            }
            if(_S1753)
            {
                return _S1383;
            }
            if(replay_2)
            {
                _S1754 = b_8 <= _S1398;
            }
            else
            {
                _S1754 = false;
            }
            if(_S1754)
            {
                _S1755 = _S1570;
            }
            else
            {
                _S1755 = false;
            }
            if(_S1755)
            {
                _S1756 = _S1849;
            }
            else
            {
                _S1756 = false;
            }
            if(_S1756)
            {
                _S1757 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1757 = !_S1850;
                }
                else
                {
                    _S1757 = false;
                }
            }
            if(_S1757)
            {
                return _S1383;
            }
            if(viewed_1)
            {
                float3  _S1862 = throughput_11 * ((&lobe_7)->throughput * make_float3 ((&lobe_7)->pdf));
                float _S1863 = (&lobe_7)->pdf;
                throughput_12 = _S1862;
                sky_pdf_2 = _S1863;
            }
            else
            {
                float3  _S1864 = throughput_11 * max_0((&lobe_7)->throughput, _S1382);
                throughput_12 = _S1864;
                sky_pdf_2 = density_6;
            }
            bool _S1865 = !replay_2;
            bool _S1866;
            if(_S1865)
            {
                _S1866 = !_S1625;
            }
            else
            {
                _S1866 = false;
            }
            bool _S1867;
            if(_S1866)
            {
                _S1867 = _S1570;
            }
            else
            {
                _S1867 = false;
            }
            bool _S1868;
            if(_S1867)
            {
                _S1868 = _S1849;
            }
            else
            {
                _S1868 = false;
            }
            float3  chain_throughput_1;
            if(_S1868)
            {
                chain_0 = here_0;
                uint _S1869 = insertBits_0((&chain_0)->path, b_11, 18U, 3U);
                uint _S1870 = _slang_select(nee_0, 1U,0U);
                uint _S1871 = insertBits_0(_S1869, _S1870, 21U, 1U);
                (&chain_0)->path = _S1871;
                float _S1872 = (&chain_0)->jac * (&lobe_7)->pdf;
                (&chain_0)->jac = _S1872;
                (&chain_0)->dir = throughput_10;
                chain_throughput_1 = throughput_12;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1873 = surface_12;
            Vertex _S1874 = Vertex_x24init_0(_S1850, b_11, (&lobe_7)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_10)))), is_inside_7);
            prev_0 = _S1874;
            float _S1875 = (&lobe_7)->pdf;
            bool _S1876;
            if(_S1860)
            {
                _S1876 = (_S1597.x) == (_S1597.y);
            }
            else
            {
                _S1876 = false;
            }
            float sky_pdf_3 = _slang_select(_S1876, sky_pdf_0,_S1875);
            float _S1877 = _slang_select(_S1602, 0.0f,sky_pdf_3);
            float _S1878 = widened_0(spread_2, (&lobe_7)->pdf, _S1744);
            bool _S1879;
            if(refracted_6)
            {
                _S1879 = !_S1750;
            }
            else
            {
                _S1879 = false;
            }
            bool is_inside_8;
            if(_S1879)
            {
                bool _S1880 = !is_inside_7;
                is_inside_8 = _S1880;
            }
            else
            {
                is_inside_8 = is_inside_7;
            }
            FKSurface _S1881 = surface_12;
            bool _S1882 = boundsVolume_0(&_S1881);
            bool _S1883;
            if(_S1882)
            {
                _S1883 = !_S1861;
            }
            else
            {
                _S1883 = false;
            }
            if(_S1883)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1884 = - _S1873.geometry_n;
                float3  _S1885 = _slang_select(turned_1, _S1884,_S1873.geometry_n);
                (&faced_2)->geometry_n = _S1885;
                FKMedium _S1886 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1887 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1888 = faced_2;
                FKMedium _S1889 = _S1886;
                FKMedium _S1890 = _S1887;
                MediumSides _S1891 = mediumSides_0(&_S1888, &_S1889, filling_2, (&ray_2)->unit_direction, &_S1890);
                bool _S1892 = leavesInFront_0((&faced_2)->geometry_n, throughput_10, _S1873.geometry_n);
                float3  _S1893 = _slang_select(_S1892, _S1891.front.scatter,_S1891.behind.scatter);
                scatter_in_0 = _S1893;
                float3  _S1894 = scatter_in_0;
                float _S1895 = upsample(scatter_in_0, wavelength_6);
                float3  _S1896 = make_float3 (_S1895);
                float3  _S1897 = _slang_select(_S1594, _S1896,_S1894);
                scatter_in_0 = _S1897;
                float3  _S1898 = _slang_select(_S1892, _S1891.front.extinction,_S1891.behind.extinction);
                extinction_in_0 = _S1898;
                float3  _S1899 = extinction_in_0;
                float _S1900 = upsample(extinction_in_0, wavelength_6);
                float3  _S1901 = make_float3 (_S1900);
                float3  _S1902 = _slang_select(_S1594, _S1901,_S1899);
                extinction_in_0 = _S1902;
                float _S1903 = _slang_select(_S1892, _S1891.front.g,_S1891.behind.g);
                g_in_0 = _S1903;
                uint _S1904 = _S1891.fillings.x;
                uint _S1905 = _S1891.fillings.y;
                uint _S1906 = _slang_select(_S1892, _S1905,_S1904);
                bool _S1907 = (fcptVaryingUsed());
                uint _S1908 = _slang_select(_S1907, _S1906,4294967295U);
                filling_2 = _S1908;
            }
            (&ray_2)->unit_direction = throughput_10;
            bool _S1909 = !_S1861;
            if(_S1909)
            {
                FKSurface _S1910 = surface_12;
                float _S1911 = _slang_select(straight_0, 0.0f,_S1910.geometry_offset);
                float3  _S1912 = - _S1571.smooth_n;
                bool _S1913 = is_inside_8 != _S1750;
                float3  _S1914 = _slang_select(_S1913, _S1912,_S1571.smooth_n);
                float3  _S1915 = (&ray_2)->origin + make_float3 (_S1911) * _S1914;
                (&ray_2)->origin = _S1915;
            }
            throughput_11 = throughput_12;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1861;
            viewed_1 = _S1748;
            sky_pdf_2 = _S1877;
            spread_5 = _S1878;
            reconnection_0 = reconnection_1;
            is_inside_6 = is_inside_8;
        }
        else
        {
            (&prev_0)->rough = false;
            (&prev_0)->pdf = 0.0f;
            throughput_11 = throughput_8;
            density_6 = density_4;
            passes_0 = false;
            viewed_1 = viewed_0;
            sky_pdf_2 = 0.0f;
            spread_5 = spread_2;
            straight_0 = false;
            is_inside_6 = is_inside_7;
        }
        bool _S1916 = !replay_2;
        float density_7;
        if(_S1916)
        {
            if(_S1533)
            {
                float3  _S1917 = pathColor(throughput_11 * emission_1, spectral_weight_0, wavelength_6);
                Reservoir candidate_8 = chain_0;
                uint _S1918 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1919 = _S1918 == 1U;
                if(_S1919)
                {
                    float3  _S1920 = safeDivide(_S1917, chain_throughput_0);
                    (&candidate_8)->radiance = _S1920;
                }
                Reservoir _S1921 = withEnd(candidate_8, 2U, b_8, _S1917);
                offer(sel_7, _S1921, _S1917 * make_float3 (scale_4) / make_float3 (density_6));
            }
            if(_S1533)
            {
                refracted_6 = true;
            }
            else
            {
                refracted_6 = scatter_2;
            }
            if(refracted_6)
            {
                float _S1922 = survivalProbability(abs_0(throughput_11), density_6);
                density_7 = _S1922;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1923 = stream(_S1410, b_8 + 128U);
            Random _S1924 = pcg(_S1923);
            bool _S1925 = density_7 < (_S1924.value);
            if(_S1925)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1926 = (fcptMaxBounces());
                wrong_side_0 = b_8 >= _S1926;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1927 = density_6 * density_7;
            density_7 = _S1927;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1928 = layer_0 ^ 1U;
        uint _S1929 = _slang_select(passes_0, _S1928,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_4)->distance = 0.0f;
            b_11 = b_8;
            viewed_0 = viewed_1;
            throughput_3 = throughput_11;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_2 = spread_5;
            uint _S1930 = b_11 + 1U;
            b_8 = _S1930;
            layer_0 = _S1929;
            continue;
        }
        FKRay _S1931 = ray_2;
        float _S1932 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_6 = _S1638;
        }
        else
        {
            refracted_6 = false;
        }
        if(refracted_6)
        {
            wrong_side_0 = _S1387 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1933 = _slang_select(wrong_side_0, _S1932,4.294967296e+09f);
        bool _S1934 = !_S1602;
        if(straight_0)
        {
            _S1682 = true;
        }
        else
        {
            _S1682 = _S1602;
        }
        FKHit _S1935;
        if(_S1682)
        {
            _S1935 = hit_4;
        }
        else
        {
            _S1935 = _S1655;
        }
        FKHit _S1936 = (fcptTraverseInstanceBVH((_S1931), (_S1541), (_S1933), (_S1934), (_S1935), (viewed_1)));
        hit_4 = _S1936;
        if(replay_2)
        {
            _S1683 = _S1638;
        }
        else
        {
            _S1683 = false;
        }
        if(_S1683)
        {
            _S1743 = _S1387 == 1U;
        }
        else
        {
            _S1743 = false;
        }
        if(_S1743)
        {
            _S1744 = ((&hit_4)->instance_index) == (_S1399.instance_index);
        }
        else
        {
            _S1744 = false;
        }
        if(_S1744)
        {
            _S1745 = ((&hit_4)->triangle_index) == (_S1399.triangle_index);
        }
        else
        {
            _S1745 = false;
        }
        if(_S1745)
        {
            (&hit_4)->uv = _S1399.uv;
            float _S1937 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1937;
        }
        if(replay_2)
        {
            _S1746 = _S1638;
        }
        else
        {
            _S1746 = false;
        }
        if(_S1746)
        {
            _S1747 = _S1387 == 3U;
        }
        else
        {
            _S1747 = false;
        }
        if(_S1747)
        {
            _S1748 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1748 = false;
        }
        if(_S1748)
        {
            return _S1383;
        }
        Reservoir _S1938 = chain_0;
        uint _S1939 = filling_2;
        for(;;)
        {
            bool _S1940 = (fcptVaryingUsed());
            if(_S1940)
            {
                _S1749 = _S1939 != 4294967295U;
            }
            else
            {
                _S1749 = false;
            }
            float _S1941;
            if(_S1749)
            {
                float _S1942 = (fcptMajorant((_S1939)));
                _S1941 = _S1942;
            }
            else
            {
                _S1941 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1750 = _S1638;
            }
            else
            {
                _S1750 = false;
            }
            if(_S1750)
            {
                _S1751 = _S1387 == 1U;
            }
            else
            {
                _S1751 = false;
            }
            if(_S1751)
            {
                _S1752 = _S1941 > 0.0f;
            }
            else
            {
                _S1752 = false;
            }
            if(_S1752)
            {
                ended_0 = _S1383;
                sky_pdf_1 = sky_pdf_2;
                spread_3 = spread_5;
                width_4 = width_3;
                density_3 = density_7;
                throughput_12 = throughput_11;
                b_11 = b_8;
                _S1753 = true;
                break;
            }
            bool _S1943 = (&prev_0)->rough;
            if(_S1943)
            {
                _S1753 = !(_S1941 > 0.0f);
            }
            else
            {
                _S1753 = false;
            }
            (&prev_0)->rough = _S1753;
            uint _S1944 = b_8 + 320U;
            bool _S1945 = b_8 == 4294967295U;
            uint _S1946 = _slang_select(_S1945, 384U,_S1944);
            uint _S1947 = stream(_S1410, _S1946);
            uint tracking_1 = _S1947;
            weight_2 = throughput_4;
            glowed_0 = _S1382;
            b_11 = b_8;
            throughput_12 = throughput_11;
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
                    _S1381 = int(2);
                    break;
                }
                uint _S1948 = b_11 + 320U;
                bool _S1949 = b_11 == 4294967295U;
                uint _S1950 = _slang_select(_S1949, 384U,_S1948);
                uint _S1951 = stream(_S1410, _S1950);
                Random _S1952 = pcg(_S1951);
                float _S1953 = freeFlight_0(_S1952.value, _S1941);
                if(_S1749)
                {
                    float3  _S1954 = (&ray_2)->origin;
                    float3  _S1955 = (&ray_2)->unit_direction;
                    float _S1956 = (&hit_4)->distance;
                    uint _S1957 = _slang_select(_S1949, 0U,b_11);
                    uint _S1958 = (&prev_0)->lobe;
                    uint _S1959 = _slang_select(_S1949, 3U,_S1958);
                    float _S1960 = (fcptTrackMedium((_S1939), (_S1954), (_S1955), (_S1956), (&tracking_1), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1957), (_S1959), (_S1949)));
                    spread_4 = _S1960;
                }
                else
                {
                    spread_4 = _S1953;
                }
                bool _S1961 = !(spread_4 < ((&hit_4)->distance));
                if(_S1961)
                {
                    _S1381 = int(2);
                    break;
                }
                if(_S1749)
                {
                    _S1754 = _S1916;
                }
                else
                {
                    _S1754 = false;
                }
                if(_S1754)
                {
                    float3  _S1962 = pathColor(throughput_12 * glowed_0, spectral_weight_0, wavelength_6);
                    float3  _S1963 = _S1962 / make_float3 (density_3);
                    float3  _S1964 = sel_7->glow + _S1963;
                    sel_7->glow = _S1964;
                }
                else
                {
                }
                glowed_0 = _S1382;
                uint b_12 = b_11 + 1U;
                float3  _S1965 = (&ray_2)->origin + make_float3 (spread_4) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1965;
                float3  _S1966 = flightWeight_0(scatter_in_0, extinction_in_0, _S1941, spread_4, true);
                float3  _S1967 = weight_2;
                float _S1968 = upsample(weight_2, wavelength_6);
                float3  _S1969 = make_float3 (_S1968);
                float3  _S1970 = _slang_select(_S1594, _S1969,_S1967);
                float3  _S1971 = _slang_select(_S1749, _S1970,_S1966);
                float3  throughput_13 = throughput_12 * _S1971;
                uint _S1972 = stream(_S1410, b_12 + 320U);
                tracking_1 = _S1972;
                weight_2 = throughput_4;
                float width_7 = width_4 + spread_3 * spread_4;
                float _S1973 = spread_3 + 3.14159274101257324f;
                bool _S1974 = scatterSampled_0(replay_2, b_12, _S1398, _S1749);
                TreeSample light_4;
                if(_S1974)
                {
                    float3  _S1975 = (&ray_2)->origin;
                    float3  _S1976 = (&ray_2)->unit_direction;
                    float3  _S1977 = (&ray_2)->unit_direction;
                    uint _S1978 = stream(_S1410, b_12 + 64U);
                    float3  _S1979 = extinction_in_0;
                    float3  _S1980 = extinction_in_0;
                    uint2  _S1981 = make_uint2 (_S1939);
                    float3  _S1982 = (&ray_2)->unit_direction;
                    uint _S1983 = arrivalLobe_0(b_12, (&prev_0)->lobe);
                    FKHit _S1984 = _S1655;
                    ShadowContext _S1985 = ShadowContext_x24init_0(_S1979, _S1980, _S1981, _S1982, b_12, _S1983, false, spread_4, width_7, &_S1984, false);
                    ShadowContext _S1986 = _S1985;
                    TreeSample _S1987 = sampleLightTree_0(_S1975, _S1976, _S1977, 0.0f, true, _S1978, &_S1986);
                    light_4 = _S1987;
                }
                else
                {
                    light_4 = _S1652;
                }
                float _S1988 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1989 = (fcptMaxBounces());
                bool _S1990 = b_12 < _S1989;
                if(_S1990)
                {
                    _S1755 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1755 = false;
                }
                float _S1991 = _slang_select(_S1755, _S1988,0.0f);
                float3  _S1992 = throughput_13 * light_4.radiance;
                float _S1993 = powerHeuristic(light_4.density, _S1991);
                float3  _S1994 = pathColor(_S1992 * make_float3 (_S1988 * _S1993), spectral_weight_0, wavelength_6);
                float3  _S1995 = _slang_select(_S1974, _S1994,_S1382);
                if(replay_2)
                {
                    _S1756 = b_12 == _S1398;
                }
                else
                {
                    _S1756 = false;
                }
                if(_S1756)
                {
                    bool _S1996 = _S1387 == 2U;
                    if(_S1996)
                    {
                        float _S1997 = resamplingTarget(_S1995);
                        _S1757 = _S1997 > 0.0f;
                    }
                    else
                    {
                        _S1757 = false;
                    }
                    if(_S1757)
                    {
                        Shift _S1998 = Shift_x24init_0(_S1995, 1.0f);
                        _S1381 = int(1);
                        ended_0 = _S1998;
                        spread_4 = _S1973;
                        width_5 = width_7;
                        throughput_10 = throughput_13;
                        b_9 = b_12;
                        break;
                    }
                    _S1381 = int(1);
                    ended_0 = _S1383;
                    spread_4 = _S1973;
                    width_5 = width_7;
                    throughput_10 = throughput_13;
                    b_9 = b_12;
                    break;
                }
                if(_S1916)
                {
                    Reservoir candidate_9 = _S1938;
                    uint _S1999 = extractBits_0(_S1938.path, 24U, 8U);
                    uint _S2000 = insertBits_0(0U, _S1999, 24U, 8U);
                    uint _S2001 = extractBits_0(_S1938.path, 10U, 2U);
                    bool _S2002 = _S2001 == 1U;
                    if(_S2002)
                    {
                        float3  _S2003 = safeDivide(_S1995, chain_throughput_0);
                        (&candidate_9)->radiance = _S2003;
                    }
                    else
                    {
                        uint _S2004 = insertBits_0(_S2000, b_12 + 1U, 5U, 5U);
                        uint _S2005 = insertBits_0(_S2004, 2U, 10U, 2U);
                        (&candidate_9)->path = _S2005;
                    }
                    Reservoir _S2006 = withEnd(candidate_9, 0U, b_12, _S1995);
                    offer(sel_7, _S2006, _S1995 * make_float3 (scale_4) / make_float3 (density_3));
                    float _S2007 = survivalProbability(abs_0(throughput_13), density_3);
                    uint _S2008 = stream(_S1410, b_12 + 128U);
                    Random _S2009 = pcg(_S2008);
                    bool _S2010 = _S2007 < (_S2009.value);
                    if(_S2010)
                    {
                        _S1757 = true;
                    }
                    else
                    {
                        uint _S2011 = (fcptMaxBounces());
                        _S1757 = b_12 >= _S2011;
                    }
                    if(_S1757)
                    {
                        _S1381 = int(1);
                        ended_0 = _S1383;
                        spread_4 = _S1973;
                        width_5 = width_7;
                        throughput_10 = throughput_13;
                        b_9 = b_12;
                        break;
                    }
                    float _S2012 = density_3 * _S2007;
                    density_3 = _S2012;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S2013 = stream(_S1410, b_12);
                float3  _S2014 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S2013, &phase_pdf_1);
                (&ray_2)->unit_direction = _S2014;
                NEEVertex _S2015 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1382, (&ray_2)->origin);
                nee_vertex_0 = _S2015;
                Vertex _S2016 = scatteredVertex_0(is_inside_6);
                prev_0 = _S2016;
                float _S2017 = (&prev_0)->pdf;
                FKRay _S2018 = ray_2;
                FKHit _S2019 = (fcptTraverseInstanceBVH((_S2018), (true), (4.294967296e+09f), (false), (_S1655), (false)));
                hit_4 = _S2019;
                b_11 = b_12;
                throughput_12 = throughput_13;
                spread_3 = _S1973;
                width_4 = width_7;
                sky_pdf_1 = _S2017;
            }
            if(_S1381 != int(2))
            {
                spread_3 = spread_4;
                width_4 = width_5;
                throughput_12 = throughput_10;
                b_11 = b_9;
                _S1753 = true;
                break;
            }
            ended_0 = _S1383;
            _S1753 = false;
            break;
        }
        if(_S1753)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1754 = b_11 == b_8;
        }
        else
        {
            _S1754 = false;
        }
        bool _S2020 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S2020)
        {
            bool _S2021 = !(&nee_vertex_0)->none;
            float _S2022 = _slang_select(_S2021, sky_pdf_1,0.0f);
            float _S2023 = escapeWeight_0(_S2022, (&ray_2)->unit_direction);
            float3  _S2024 = environment_0((&ray_2)->unit_direction, b_11, (&prev_0)->lobe);
            float3  _S2025 = pathColor(throughput_12 * _S2024, spectral_weight_0, wavelength_6);
            if(replay_2)
            {
                bool _S2026 = b_11 == _S1398;
                if(_S2026)
                {
                    passes_0 = _S1387 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S2025 * make_float3 (_S2023) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1397)
                {
                    passes_0 = _S1394;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_11 == _S1385;
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
                    return Shift_x24init_0(_S2025 * make_float3 (_S2023), 1.0f);
                }
                return _S1383;
            }
            Reservoir candidate_10 = chain_0;
            uint _S2027 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S2028 = _S2027 == 1U;
            if(_S2028)
            {
                uint _S2029 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S2030 = _S2029 == b_11;
                float _S2031 = _slang_select(_S2030, 1.0f,_S2023);
                float3  _S2032 = safeDivide(_S2025 * make_float3 (_S2031), chain_throughput_0);
                (&candidate_10)->radiance = _S2032;
            }
            else
            {
                bool _S2033 = (&prev_0)->rough;
                if(_S2033)
                {
                    uint _S2034 = insertBits_0(_S1412, b_11 + 1U, 5U, 5U);
                    uint _S2035 = insertBits_0(_S2034, 3U, 10U, 2U);
                    uint _S2036 = insertBits_0(_S2035, (&prev_0)->lobe, 15U, 3U);
                    bool _S2037 = (&prev_0)->inside;
                    uint _S2038 = _slang_select(_S2037, 1U,0U);
                    uint _S2039 = insertBits_0(_S2036, _S2038, 22U, 1U);
                    (&candidate_10)->path = _S2039;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S2040 = _S2025 * make_float3 (_S2023);
            Reservoir _S2041 = withEnd(candidate_10, 3U, b_11, _S2040);
            offer(sel_7, _S2041, _S2040 * make_float3 (scale_4) / make_float3 (density_3));
            break;
        }
        float3  _S2042 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S2042;
        bool _S2043 = (fcptVaryingUsed());
        if(_S2043)
        {
            _S1755 = filling_2 != 4294967295U;
        }
        else
        {
            _S1755 = false;
        }
        if(_S1755)
        {
            if(_S1916)
            {
                float3  _S2044 = pathColor(throughput_12 * glowed_0, spectral_weight_0, wavelength_6);
                float3  _S2045 = _S2044 / make_float3 (density_3);
                float3  _S2046 = sel_7->glow + _S2045;
                sel_7->glow = _S2046;
            }
            float3  _S2047 = throughput_12 * weight_2;
            throughput_10 = _S2047;
        }
        else
        {
            float3  _S2048 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S2049 = throughput_12 * _S2048;
            throughput_10 = _S2049;
        }
        float _S2050 = width_4 + spread_3 * (&hit_4)->distance;
        viewed_0 = _S1754;
        width_3 = _S2050;
        throughput_3 = throughput_10;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_3;
        uint _S1930 = b_11 + 1U;
        b_8 = _S1930;
        layer_0 = _S1929;
    }
    return _S1383;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_9)
{
    Selection _S2051 = (Selection{});
    Selection sel_8 = _S2051;
    bool _S2052 = (r_9->w) <= 0.0f;
    if(_S2052)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S2053 = walk_0(dom_8, r_9, true, 0.0f, &sel_8);
    return _S2053;
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
        *_slang_vector_get_element_ptr(&result_15, i_19) = (F32_tan((_slang_vector_get_element(x_27, i_19))));
        i_19 = i_19 + int(1);
    }
    return result_15;
}

static __device__ float3  acos_0(float3  x_28)
{
    float3  result_16;
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
        *_slang_vector_get_element_ptr(&result_16, i_20) = (F32_acos((_slang_vector_get_element(x_28, i_20))));
        i_20 = i_20 + int(1);
    }
    return result_16;
}

__device__ Random normal_distribution(uint state_4)
{
    Random _S2054 = pcg(state_4);
    Random _S2055 = pcg(_S2054.state);
    float _S2056 = 6.28318548202514648f * _S2054.value;
    float _S2057 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S2055.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S2055.state, _S2057 * (F32_cos((_S2056))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S2058;
    (&_S2058)->state = state_5;
    (&_S2058)->value = value_2;
    return _S2058;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S2059 = normal_distribution(state_6);
    Random _S2060 = normal_distribution(_S2059.state);
    Random _S2061 = normal_distribution(_S2060.state);
    float3  _S2062 = make_float3 (_S2059.value, _S2060.value, _S2061.value);
    float3  _S2063 = ((((_S2062)) * make_float3(rnorm3df(((_S2062)).x, ((_S2062)).y, ((_S2062)).z))));
    return RandomSphere_x24init_0(_S2061.state, _S2063);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_18)
{
    float3  _S2064 = p1_0 - p0_0;
    float3  _S2065 = p2_0 - p0_0;
    float2  _S2066 = uv1_0 - uv0_0;
    float2  _S2067 = uv2_0 - uv0_0;
    float _S2068 = _S2066.x;
    float _S2069 = _S2067.y;
    float _S2070 = _S2066.y;
    float _S2071 = _S2067.x;
    float _S2072 = _S2068 * _S2069 - _S2070 * _S2071;
    float _S2073 = 1.0f / _S2072;
    float3  t_22 = (_S2064 * make_float3 (_S2069) - _S2065 * make_float3 (_S2070)) * make_float3 (_S2073);
    float3  _S2074 = (_S2065 * make_float3 (_S2068) - _S2064 * make_float3 (_S2071)) * make_float3 (_S2073);
    float3  _S2075 = t_22 - n_18 * make_float3 (dot_0(n_18, t_22));
    float3  t_23 = ((((_S2075)) * make_float3(rnorm3df(((_S2075)).x, ((_S2075)).y, ((_S2075)).z))));
    bool _S2076 = (dot_0(cross_0(n_18, t_23), _S2074)) > 0.0f;
    float3  t_24;
    if(_S2076)
    {
        float3  _S2077 = negate_0(t_23);
        t_24 = _S2077;
    }
    else
    {
        t_24 = t_23;
    }
    float3  _S2078 = cross_0(n_18, t_24);
    return makeMatrix<float, 3, 3> (t_24, _S2078, n_18);
}

__device__ float3  tangentToWorldNormalMap(float3  v_4, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_4, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S2079 = t1_0 - t0_0;
    float3  _S2080 = t2_2 - t0_0;
    float3  _S2081 = t2_2 - t1_0;
    float _S2082 = (F32_min((length_0(_S2079)), ((F32_min((length_0(_S2080)), (length_0(_S2081)))))));
    float3  _S2083 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S2084 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S2085 = dot_0(geometry_n_5, _S2084);
    float3  _S2086 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S2087 = dot_0(geometry_n_5, _S2086);
    float3  _S2088 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S2089 = acos_0(abs_0(make_float3 (_S2085, _S2087, dot_0(geometry_n_5, _S2088))));
    float3  _S2090 = clamp_2(tan_0(_S2089), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S2083 * _S2090, uvw_0), 0.0f, _S2082 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_20, float3  n_19, BSDFMaterial material_34)
{
    float3  _S2091 = negate_0(dir_20);
    float _S2092 = sign_0(dot_0(n_19, _S2091));
    float3  _S2093 = n_19 * make_float3 (_S2092);
    AnisotropicFrame _S2094 = anisotropicFrame(material_34, _S2093);
    bool _S2095 = (_S2094.alphas.x) > 0.0f;
    if(_S2095)
    {
        float _S2096 = material_34.transmission * (1.0f - material_34.metallic);
        float3  _S2097 = negate_0(_S2093);
        float3  _S2098 = anisotropicLocal(dir_20, _S2094.tangent, _S2097);
        float _S2099 = anisotropicG1(_S2098, _S2094.alphas);
        return make_float3 (_S2096 * _S2099) * material_34.albedo;
    }
    float _S2100 = material_34.transmission * (1.0f - material_34.metallic);
    float _S2101 = material_34.roughness;
    float _S2102 = smithG1(_S2101 * _S2101, (F32_abs((dot_0(n_19, dir_20)))));
    return make_float3 (_S2100 * _S2102) * material_34.albedo;
}

__device__ float hairRow(float3  in_dir_17, float3  t_25, float3  out_dir_5, uint p_14, float w_2, float alpha_20, uint nt_0)
{
    uint _S2103 = p_14 % 4U;
    float _S2104 = w_2 * HAIR_WIDTHS_0[_S2103];
    float _S2105 = (F32_asin((clamp_1(dot_0(out_dir_5, t_25), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_17, t_25), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S2103] * alpha_20;
    return ((F32_asinh((_S2105 / _S2104))) / (F32_asinh((3.14159274101257324f / _S2104))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_18, float3  t_26, float3  out_dir_6, uint np_0)
{
    float3  _S2106 = worldToTangent(out_dir_6, t_26);
    float3  _S2107 = worldToTangent(in_dir_18, t_26);
    return (F32_frac((((F32_atan2((_S2106.z), (_S2106.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S2107.z), (1.17549435082228751e-38f - _S2107.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_19, float3  t_27, uint p_15, float row_0, float column_0, float w_3, float alpha_21, uint nt_1, uint np_1)
{
    float3  _S2108 = worldToTangent(in_dir_19, t_27);
    uint _S2109 = p_15 % 4U;
    float _S2110 = w_3 * HAIR_WIDTHS_0[_S2109];
    float _S2111 = (F32_asin((clamp_1(dot_0(in_dir_19, t_27), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S2109] * alpha_21 + _S2110 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S2110))))));
    float _S2112 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S2108.z), (1.17549435082228751e-38f - _S2108.x)));
    float _S2113 = (F32_cos((_S2111)));
    float3  _S2114 = tangentToWorld(make_float3 (_S2113 * (F32_cos((_S2112))), (F32_sin((_S2111))), _S2113 * (F32_sin((_S2112)))), t_27);
    return _S2114;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_20, BSDFMaterial material_35, float coverage_1)
{
    float3  _S2115;
    if((material_35.ior) == 1.0f)
    {
        float3  _S2116 = straightThrough(toward_1, n_20, material_35);
        _S2115 = _S2116;
    }
    else
    {
        _S2115 = make_float3 (0.0f);
    }
    return _S2115 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_5, Selection * sel_9)
{
    Domain _S2117 = dom_9;
    Reservoir _S2118 = r_10;
    Shift _S2119 = walk_0(&_S2117, &_S2118, replay_3, scale_5, sel_9);
    return _S2119;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_11)
{
    Domain _S2120 = dom_10;
    Reservoir _S2121 = r_11;
    Shift _S2122 = shift_0(&_S2120, &_S2121);
    return _S2122;
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
