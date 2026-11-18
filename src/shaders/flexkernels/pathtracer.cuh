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

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
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
    BSDFLobes _S331;
    (&_S331)->v_dot_h = v_dot_h_0;
    (&_S331)->n_dot_h = n_dot_h_0;
    (&_S331)->refracted = refracted_1;
    (&_S331)->F = F_0;
    (&_S331)->F_greyscale = F_greyscale_0;
    (&_S331)->reflect_weight = reflect_weight_0;
    (&_S331)->diffuse_weight = diffuse_weight_0;
    (&_S331)->refract_weight = refract_weight_0;
    (&_S331)->p_diffuse = p_diffuse_0;
    (&_S331)->p_reflect = p_reflect_0;
    (&_S331)->p_refract = p_refract_0;
    (&_S331)->translucent_share = translucent_share_0;
    (&_S331)->sheen = sheen_0;
    (&_S331)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S331)->view = view_0;
    (&_S331)->tangent = tangent_1;
    (&_S331)->alphas = alphas_1;
    (&_S331)->visible = visible_0;
    (&_S331)->p_toon = p_toon_0;
    (&_S331)->toon = toon_0;
    (&_S331)->toon_a = toon_a_0;
    (&_S331)->toon_s = toon_s_0;
    (&_S331)->toon_b = toon_b_0;
    (&_S331)->toon_glossy = toon_glossy_0;
    (&_S331)->toon_norm = toon_norm_0;
    (&_S331)->toon_view = toon_view_0;
    (&_S331)->toon_axis = toon_axis_0;
    return _S331;
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
    float3  _S332 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S333 = ((((_S332)) * make_float3(rnorm3df(((_S332)).x, ((_S332)).y, ((_S332)).z))));
    float _S334 = _S333.x;
    float _S335 = _S333.y;
    float _S336 = _S334 * _S334 + _S335 * _S335;
    float3  _S337;
    if(_S336 > 0.0f)
    {
        float3  _S338 = make_float3 (- _S335, _S334, 0.0f);
        float _S339 = (rsqrtf((_S336)));
        _S337 = _S338 * make_float3 (_S339);
    }
    else
    {
        _S337 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S340 = cross_0(_S333, _S337);
    float _S341 = (F32_sqrt((U1_0)));
    float _S342 = 6.28318548202514648f * U2_0;
    float _S343 = _S341 * (F32_cos((_S342)));
    float t2_0 = _S341 * (F32_sin((_S342)));
    float _S344 = 0.5f * (1.0f + _S333.z);
    float t2_1 = (1.0f - _S344) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S343 * _S343)))))) + _S344 * t2_0;
    float3  _S345 = make_float3 (_S343) * _S337 + make_float3 (t2_1) * _S340;
    float _S346 = unshared_0(_S343);
    float _S347 = unshared_0(_S343);
    float3  _S348 = _S345 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S346 * _S347 - t2_1 * t2_1))))))) * _S333;
    float3  _S349 = make_float3 (alpha_0 * _S348.x, alpha_0 * _S348.y, (F32_max((0.0f), (_S348.z))));
    float3  _S350 = ((((_S349)) * make_float3(rnorm3df(((_S349)).x, ((_S349)).y, ((_S349)).z))));
    return _S350;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S351 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S351)
    {
        float3  _S352 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S352;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S353 = cross_0(n_3, a_4);
    float3  _S354 = ((((_S353)) * make_float3(rnorm3df(((_S353)).x, ((_S353)).y, ((_S353)).z))));
    float3  _S355 = cross_0(n_3, _S354);
    return make_float3 (dot_0(v_1, _S354), dot_0(v_1, n_3), dot_0(v_1, _S355));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_2, float3  n_i_1, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S356 = pcg(*random_state_2);
    Random _S357 = pcg(_S356.state);
    *random_state_2 = _S357.state;
    float _S358 = frame_0.alphas.x;
    bool _S359 = _S358 > 0.0f;
    if(_S359)
    {
        float3  _S360 = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        float _S361 = frame_0.alphas.y;
        float3  _S362 = make_float3 (_S358 * _S360.x, _S361 * _S360.y, _S360.z);
        float3  _S363 = ((((_S362)) * make_float3(rnorm3df(((_S362)).x, ((_S362)).y, ((_S362)).z))));
        float3  _S364 = sampleGGXVNDF(_S363, 1.0f, _S356.value, _S357.value);
        float3  _S365 = make_float3 (_S358 * _S364.x, _S361 * _S364.y, _S364.z);
        float3  _S366 = ((((_S365)) * make_float3(rnorm3df(((_S365)).x, ((_S365)).y, ((_S365)).z))));
        return make_float3 (_S366.x) * frame_0.tangent + make_float3 (_S366.y) * cross_0(n_i_1, frame_0.tangent) + make_float3 (_S366.z) * n_i_1;
    }
    float3  _S367 = worldToTangent(v_2, n_i_1);
    float3  _S368 = sampleGGXVNDF(float3 {_S367.x, _S367.z, _S367.y}, alpha_1, _S356.value, _S357.value);
    float3  _S369 = float3 {_S368.x, _S368.z, _S368.y};
    float3  _S370 = tangentToWorld(_S369, n_i_1);
    return _S370;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_4, BSDFMaterial material_1, uint random_state_3, AnisotropicFrame frame_1)
{
    uint state_3 = random_state_3;
    float3  _S371 = negate_0(in_dir_0);
    float _S372 = sign_0(dot_0(n_4, _S371));
    float _S373 = material_1.roughness;
    float3  _S374 = sampleHalfVector(_S371, n_4 * make_float3 (_S372), _S373 * _S373, frame_1, &state_3);
    return _S374;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_5, float eta_i_0, float eta_o_0)
{
    float3  _S375 = negate_0(in_dir_1);
    float3  _S376 = negate_0(make_float3 (eta_i_0) * _S375 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S377 = ((((_S376)) * make_float3(rnorm3df(((_S376)).x, ((_S376)).y, ((_S376)).z))));
    float _S378 = sign_0(dot_0(n_5, _S375));
    float _S379 = sign_0(dot_0(_S376, n_5 * make_float3 (_S378)));
    return _S377 * make_float3 (_S379);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S380 = negate_0(in_dir_2);
    float3  _S381 = _S380 + out_dir_1;
    float3  _S382 = ((((_S381)) * make_float3(rnorm3df(((_S381)).x, ((_S381)).y, ((_S381)).z))));
    return _S382;
}

static __device__ float3  refract_0(float3  i_5, float3  n_6, float eta_0)
{
    float _S383 = dot_0(n_6, i_5);
    float _S384 = 1.0f - eta_0 * eta_0 * (1.0f - _S383 * _S383);
    if(_S384 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S383 + (F32_sqrt((_S384)))) * n_6;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S385 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S386 = eta_i_1 / eta_o_1 * _S385;
    bool _S387 = _S386 < 1.0f;
    float kr_0;
    if(_S387)
    {
        float _S388 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S386 * _S386))))));
        float _S389 = eta_o_1 * cos_theta_0;
        float _S390 = eta_i_1 * _S388;
        float _S391 = (_S389 - _S390) / (_S389 + _S390);
        float _S392 = eta_i_1 * cos_theta_0;
        float _S393 = eta_o_1 * _S388;
        float _S394 = (_S392 - _S393) / (_S392 + _S393);
        float _S395 = (_S391 * _S391 + _S394 * _S394) / 2.0f;
        kr_0 = _S395;
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

__device__ float anisotropicG1(float3  w_1, float2  alphas_2)
{
    float _S396 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S396 / (_S396 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S396)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S397 = alphas_3.x;
    float _S398 = h_0.x / _S397;
    float _S399 = alphas_3.y;
    float _S400 = h_0.y / _S399;
    float _S401 = h_0.z;
    float _S402 = _S398 * _S398 + _S400 * _S400 + _S401 * _S401;
    return 1.0f / (F32_max((3.14159274101257324f * _S397 * _S399 * _S402 * _S402), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_3, float3  n_i_2, float3  ggx_n_0, BSDFMaterial material_2, float eta_i_2, float eta_o_2, AnisotropicFrame frame_2)
{
    float _S403 = dot_0(ggx_n_0, v_3);
    float _S404 = dot_0(n_i_2, ggx_n_0);
    float _S405 = eta_i_2 / eta_o_2;
    float3  _S406 = refract_0(in_dir_3, ggx_n_0, _S405);
    float3  _S407 = ((((_S406)) * make_float3(rnorm3df(((_S406)).x, ((_S406)).y, ((_S406)).z))));
    float _S408 = (F32_min(((F32_sqrt((material_2.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S409 = _S408 * _S408;
    float _S410 = (1.0f + _S408) / (1.0f - _S408);
    float _S411 = (F32_abs((_S403)));
    bool _S412 = eta_i_2 > eta_o_2;
    float sheen_component_0;
    if(_S412)
    {
        sheen_component_0 = _S410;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float toon_component_0;
    if(_S412)
    {
        toon_component_0 = 1.0f;
    }
    else
    {
        toon_component_0 = _S410;
    }
    float _S413 = fresnel(_S411, sheen_component_0, toon_component_0);
    bool _S414 = (eta_i_2 * eta_i_2 * (1.0f - _S403 * _S403)) >= (eta_o_2 * eta_o_2);
    float3  _S415;
    if(_S414)
    {
        _S415 = make_float3 (1.0f);
    }
    else
    {
        float3  _S416 = material_2.specular_tint * make_float3 (_S409);
        _S415 = _S416 + (make_float3 (1.0f) - _S416) * make_float3 (_S413 - _S409) / make_float3 (1.0f - _S409);
    }
    float3  _S417 = make_float3 (1.0f);
    float3  _S418 = make_float3 (0.0f);
    float _S419 = rgb_to_greyscale(material_2.sheen);
    bool _S420 = _S419 > 0.0f;
    float3  sheen_1;
    float3  view_1;
    float3  scale_1;
    if(_S420)
    {
        float _S421 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_2, v_3)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S422 = (U32_min((uint(_S421)), (22U)));
        float least_0 = (F32_sqrt((0.05000000074505806f)));
        float _S423 = (F32_sqrt((0.10000000149011612f)));
        bool _S424 = (material_2.velvet) > 0.0f;
        float _S425 = _slang_select(_S424, _S423,least_0);
        float _S426 = (clamp_1((F32_sqrt(((F32_max((material_2.sheen_roughness), (0.0f)))))), _S425, 1.0f) - _S425) / (1.0f - _S425) * 23.0f;
        uint _S427 = (U32_min((uint(_S426)), (22U)));
        uint _S428 = _S422 * 24U + _S427;
        float _S429 = _S421 - float(_S422);
        float _S430 = _S426 - float(_S427);
        uint _S431 = _S428 + 24U;
        float a_5 = SHEEN_ALBEDO_0[_S428] + (SHEEN_ALBEDO_0[_S431] - SHEEN_ALBEDO_0[_S428]) * _S429;
        uint _S432 = _S428 + 1U;
        uint _S433 = _S431 + 1U;
        float b_1 = SHEEN_ALBEDO_0[_S432] + (SHEEN_ALBEDO_0[_S433] - SHEEN_ALBEDO_0[_S432]) * _S429;
        float _S434 = (F32_exp((a_5 + (b_1 - a_5) * _S430)));
        if(_S424)
        {
            float a_6 = VELVET_ALBEDO_0[_S428] + (VELVET_ALBEDO_0[_S431] - VELVET_ALBEDO_0[_S428]) * _S429;
            float b_2 = VELVET_ALBEDO_0[_S432] + (VELVET_ALBEDO_0[_S433] - VELVET_ALBEDO_0[_S432]) * _S429;
            float _S435 = a_6 + (b_2 - a_6) * _S430;
            sheen_component_0 = _S435;
        }
        else
        {
            sheen_component_0 = _S434;
        }
        float _S436 = (F32_min((sheen_component_0), (1.0f)));
        float3  _S437 = make_float3 (1.0f) - material_2.sheen * make_float3 (_S436);
        float _S438 = rgb_to_greyscale(material_2.sheen);
        float _S439 = _S438 * _S436;
        float3  _S440 = material_2.sheen / make_float3 ((F32_max((sheen_component_0), (1.0f))));
        sheen_component_0 = _S439;
        sheen_1 = _S440;
        view_1 = v_3;
        scale_1 = _S437;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S418;
        view_1 = _S418;
        scale_1 = _S417;
    }
    float _S441 = material_2.toon.x;
    bool _S442 = _S441 < 0.0f;
    float _S443 = (F32_abs((_S441)));
    bool _S444 = _S443 > 0.0f;
    float toon_a_1;
    float toon_s_1;
    float toon_b_1;
    float toon_norm_1;
    float toon_view_1;
    float3  toon_1;
    float3  toon_axis_1;
    bool _S445;
    if(_S444)
    {
        float _S446 = (F32_min((_S443), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S446);
        float _S447 = rgb_to_greyscale(material_2.albedo);
        float _S448 = _S446 * _S447;
        float3  _S449 = make_float3 (_S446) * material_2.albedo;
        float toon_a_2 = clamp_1(material_2.toon.y / _S441, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_2 = clamp_1(material_2.toon.z / _S441, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S450 = (F32_min((toon_a_2 + toon_s_2), (1.57079637050628662f)));
        if(_S442)
        {
            toon_component_0 = 1.0f - (F32_cos(((F32_min((_S450), (toon_a_2))))));
        }
        else
        {
            float _S451 = (F32_sin(((F32_min((_S450), (toon_a_2))))));
            toon_component_0 = _S451 * _S451 / 2.0f;
        }
        bool _S452 = _S450 > toon_a_2;
        if(_S452)
        {
            _S445 = toon_s_2 > 0.0f;
        }
        else
        {
            _S445 = false;
        }
        if(_S445)
        {
            if(_S442)
            {
                float _S453 = (F32_cos((toon_a_2)));
                float _S454 = (F32_cos((_S450)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S453 - _S454) - ((F32_sin((_S450))) - _S450 * _S454 - ((F32_sin((toon_a_2))) - toon_a_2 * _S453)) / toon_s_2;
            }
            else
            {
                float _S455 = 2.0f * toon_a_2;
                float _S456 = (F32_cos((_S455)));
                float _S457 = 2.0f * _S450;
                float _S458 = (F32_cos((_S457)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S456 - _S458) / 4.0f - ((F32_sin((_S457))) / 8.0f - _S450 * _S458 / 4.0f - ((F32_sin((_S455))) / 8.0f - toon_a_2 * _S456 / 4.0f)) / toon_s_2;
            }
            float integral_0 = toon_component_0 + toon_a_1;
            toon_component_0 = integral_0;
        }
        float _S459 = 6.28318548202514648f * toon_component_0;
        float _S460 = dot_0(n_i_2, v_3);
        float _S461 = (F32_acos(((F32_min((_S460), (1.0f))))));
        if(_S461 < toon_a_2)
        {
            toon_component_0 = 1.0f;
        }
        else
        {
            toon_component_0 = (F32_max((1.0f - (_S461 - toon_a_2) / (F32_max((toon_s_2), (0.0000152587890625f)))), (0.0f)));
        }
        if(_S442)
        {
            float3  _S462 = make_float3 (2.0f * _S460) * n_i_2 - v_3;
            float3  _S463 = ((((_S462)) * make_float3(rnorm3df(((_S462)).x, ((_S462)).y, ((_S462)).z))));
            scale_1 = _S463;
        }
        else
        {
            scale_1 = n_i_2;
        }
        float _S464 = toon_component_0;
        toon_component_0 = _S448;
        toon_1 = _S449;
        toon_a_1 = toon_a_2;
        toon_s_1 = toon_s_2;
        toon_b_1 = _S450;
        toon_norm_1 = _S459;
        toon_view_1 = _S464;
        toon_axis_1 = scale_1;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S418;
        toon_a_1 = 0.0f;
        toon_s_1 = 0.0f;
        toon_b_1 = 0.0f;
        toon_norm_1 = 1.0f;
        toon_view_1 = 0.0f;
        toon_axis_1 = n_i_2;
    }
    float3  _S465 = mix_0(_S415, material_2.albedo, material_2.metallic);
    float3  F_1 = _S465 * scale_1;
    float _S466 = rgb_to_greyscale(F_1);
    float _S467 = 1.0f - material_2.metallic;
    float3  _S468 = make_float3 (1.0f) - _S415;
    float3  _S469 = make_float3 ((1.0f - material_2.transmission) * _S467) * _S468 * scale_1;
    float3  _S470 = make_float3 (material_2.transmission * _S467) * _S468 * scale_1;
    float _S471 = (F32_max((_S466), (0.0f)));
    float _S472 = rgb_to_greyscale(_S469);
    float _S473 = (F32_max((_S472), (0.0f)));
    float _S474 = rgb_to_greyscale(_S470);
    float _S475 = sign_0(length_0(_S407));
    float _S476 = (F32_max((_S474 * _S475), (0.0f)));
    float _S477 = _S471 + _S473 + _S476 + toon_component_0;
    float _S478 = (F32_min((sheen_component_0), (1.0f)));
    bool _S479 = sheen_component_0 > 0.0f;
    if(_S479)
    {
        _S445 = !(_S477 > 0.0f);
    }
    else
    {
        _S445 = false;
    }
    float _S480 = _slang_select(_S445, 1.0f,_S478);
    float _S481 = (1.0f - _S480) / (F32_max((_S477), (0.0000152587890625f)));
    float _S482 = _S473 * _S481;
    float _S483 = _S471 * _S481;
    float _S484 = _S476 * _S481;
    bool _S485 = (frame_2.alphas.x) > 0.0f;
    float visible_1;
    if(_S485)
    {
        float3  _S486 = anisotropicLocal(v_3, frame_2.tangent, n_i_2);
        float _S487 = anisotropicG1(_S486, frame_2.alphas);
        float3  _S488 = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_2);
        float _S489 = anisotropicD(_S488, frame_2.alphas);
        float _S490 = _S487 * _S489;
        visible_1 = _S490;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S403, _S404, _S407, F_1, _S466, 1.0f, _S469, _S470, _S482, _S483, _S484, 0.0f, sheen_1, _S480, view_1, frame_2.tangent, frame_2.alphas, visible_1, toon_component_0 * _S481, toon_1, toon_a_1, toon_s_1, toon_b_1, _S442, toon_norm_1, toon_view_1, toon_axis_1);
}

__device__ float translucentShare(BSDFMaterial material_3)
{
    float _S491 = rgb_to_greyscale(material_3.translucent);
    float _S492 = rgb_to_greyscale(material_3.albedo);
    float _S493 = _S491 / (_S492 + _S491);
    bool _S494 = _S491 > 0.0f;
    float _S495 = _slang_select(_S494, _S493,0.0f);
    return _S495;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_2, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S496 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S497 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S498 = 1.0f - lobes_0.translucent_share;
    bool _S499 = n_i_dot_l_0 < 0.0f;
    float _S500 = _slang_select(_S499, lobes_0.translucent_share,_S498);
    float _S501 = _S497 * _S500;
    bool _S502 = (lobes_0.translucent_share) > 0.0f;
    float _S503 = _slang_select(_S502, _S501,_S496);
    bool _S504 = n_i_dot_v_0 > 0.0f;
    float _S505 = _slang_select(_S504, _S503,0.0f);
    return _S505;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_3, float alpha_3, BSDFMaterial material_4, BSDFLobes lobes_1)
{
    bool _S506 = (dot_0(n_i_3, l_0)) < 0.0f;
    float3  _S507 = _slang_select(_S506, material_4.translucent,material_4.albedo);
    float _S508 = 1.0f - lobes_1.translucent_share;
    float _S509 = _slang_select(_S506, lobes_1.translucent_share,_S508);
    float3  _S510 = _S507 / make_float3 (_S509);
    bool _S511 = (lobes_1.translucent_share) > 0.0f;
    float3  _S512 = _slang_select(_S511, _S510,material_4.albedo);
    return lobes_1.diffuse_weight * _S512 / make_float3 (lobes_1.p_diffuse);
}

__device__ float smithG1(float alpha_4, float n_dot_x_0)
{
    float _S513 = alpha_4 * alpha_4;
    float _S514 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S513 + (1.0f - _S513) * n_dot_x_0 * n_dot_x_0))));
    bool _S515 = alpha_4 > 0.0f;
    float _S516 = _slang_select(_S515, _S514,1.0f);
    return _S516;
}

__device__ float trowbridgeReitz(float alpha_5, float n_dot_h_1)
{
    float _S517 = alpha_5 * alpha_5;
    float _S518 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S517 * n_dot_h_1 * n_dot_h_1;
    return _S517 / (F32_max((3.14159274101257324f * _S518 * _S518), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S519 = smithG1(alpha_6, n_i_dot_v_1);
    float _S520 = _S519 * lobes_2.v_dot_h;
    float _S521 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S522 = _S520 * _S521 / n_i_dot_v_1;
    bool _S523 = alpha_6 > 0.0f;
    bool _S524;
    if(_S523)
    {
        _S524 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S524 = false;
    }
    if(_S524)
    {
        _S524 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S524 = false;
    }
    if(_S524)
    {
        _S524 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S524 = false;
    }
    float _S525 = _slang_select(_S524, _S522,0.0f);
    bool _S526 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S526)
    {
        float _S527 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S528 = (lobes_2.v_dot_h) > 0.0f;
        if(_S528)
        {
            _S524 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S524 = false;
        }
        if(_S524)
        {
            _S524 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S524 = false;
        }
        float _S529 = _slang_select(_S524, _S527,0.0f);
        pdf_h_0 = _S529;
    }
    else
    {
        pdf_h_0 = _S525;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S530 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S531 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S532 = lobes_3.p_refract * _S530 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S531 * _S531);
    bool _S533 = eta_i_4 != eta_o_4;
    bool _S534;
    if(_S533)
    {
        _S534 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S534 = false;
    }
    float _S535 = _slang_select(_S534, _S532,0.0f);
    return _S535;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_4, float alpha_8, BSDFMaterial material_5, BSDFLobes lobes_4)
{
    float _S536 = - dot_0(n_i_4, l_1);
    float _S537 = smithG1(alpha_8, (F32_max((_S536), (0.0f))));
    bool _S538 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S538)
    {
        float3  _S539 = negate_0(n_i_4);
        float3  _S540 = anisotropicLocal(l_1, lobes_4.tangent, _S539);
        float _S541 = anisotropicG1(_S540, lobes_4.alphas);
        G1_l_0 = _S541;
    }
    else
    {
        G1_l_0 = _S537;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_5.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S542 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S543 = n_i_dot_l_2 > 0.0f;
    bool _S544;
    if(_S543)
    {
        _S544 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S544 = false;
    }
    float _S545 = _slang_select(_S544, _S542,0.0f);
    return _S545;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_5, float alpha_10, BSDFMaterial material_6, BSDFLobes lobes_6)
{
    float3  _S546 = l_2 + lobes_6.view;
    float3  _S547 = ((((_S546)) * make_float3(rnorm3df(((_S546)).x, ((_S546)).y, ((_S546)).z))));
    float _S548 = dot_0(n_i_5, _S547);
    float _S549 = (F32_max((dot_0(n_i_5, l_2)), (0.0f)));
    float _S550 = (F32_max((dot_0(n_i_5, lobes_6.view)), (0.0f)));
    float _S551 = 1.0f / (F32_max((material_6.sheen_roughness), (0.05000000074505806f)));
    float _S552 = 1.0f - _S548 * _S548;
    float _S553 = (2.0f + _S551) * (F32_pow(((F32_max((_S552), (0.0f)))), (0.5f * _S551))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S549 + _S550 - _S549 * _S550)), (0.0000152587890625f)));
    bool _S554 = (material_6.velvet) > 0.0f;
    float f_1;
    if(_S554)
    {
        float _S555 = (F32_max((material_6.sheen_roughness), (0.00999999977648258f)));
        float _S556 = _S555 * _S555;
        float _S557 = (F32_max((_S552), (0.0000152587890625f)));
        float _S558 = (F32_exp((- _S548 * _S548 / (_S557 * _S556)))) / (3.14159274101257324f * _S556 * _S557 * _S557) * (F32_min((1.0f), (2.0f * _S548 * (F32_min((_S549), (_S550))) / (F32_max(((F32_abs((dot_0(_S547, lobes_6.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S549 * _S550), (0.0000152587890625f)));
        f_1 = _S558;
    }
    else
    {
        f_1 = _S553;
    }
    return lobes_6.sheen * make_float3 (f_1 * _S549 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float toonPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, BSDFLobes lobes_7, float eta_i_6, float eta_o_6)
{
    float _S559 = _slang_select(lobes_7.toon_glossy, l_dot_h_3,n_i_dot_l_3);
    float _S560 = (F32_acos((clamp_1(_S559, -1.0f, 1.0f))));
    float _S561;
    if(_S560 < (lobes_7.toon_a))
    {
        _S561 = 1.0f;
    }
    else
    {
        _S561 = (F32_max((1.0f - (_S560 - lobes_7.toon_a) / (F32_max((lobes_7.toon_s), (0.0000152587890625f)))), (0.0f)));
    }
    float _S562 = lobes_7.p_toon * _S561;
    float _S563 = _slang_select(lobes_7.toon_glossy, 1.0f,n_i_dot_l_3);
    float _S564 = _S562 * _S563 / lobes_7.toon_norm;
    bool _S565;
    if(lobes_7.toon_glossy)
    {
        _S565 = true;
    }
    else
    {
        _S565 = n_i_dot_l_3 > 0.0f;
    }
    float _S566 = _slang_select(_S565, _S564,0.0f);
    return _S566;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_3, float3  n_i_6, float alpha_12, BSDFMaterial material_7, BSDFLobes lobes_8)
{
    float _S567 = (F32_max((dot_0(n_i_6, l_3)), (0.0f)));
    float _S568 = _slang_select(lobes_8.toon_glossy, _S567,lobes_8.toon_view);
    return lobes_8.toon * make_float3 (_S568) / make_float3 (lobes_8.p_toon);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_4, float l_dot_h_4, float n_i_dot_v_5, float alpha_13, BSDFLobes lobes_9, float eta_i_7, float eta_o_7)
{
    float _S569 = vndfPDF(n_i_dot_v_5, alpha_13, lobes_9);
    float _S570 = lobes_9.p_reflect * _S569 / (4.0f * lobes_9.v_dot_h);
    bool _S571 = _S569 > 0.0f;
    float _S572 = _slang_select(_S571, _S570,0.0f);
    return _S572;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_4, float3  n_i_7, float alpha_14, BSDFMaterial material_8, BSDFLobes lobes_10)
{
    float _S573 = dot_0(n_i_7, l_4);
    float _S574 = smithG1(alpha_14, (F32_max((_S573), (0.0f))));
    bool _S575 = (lobes_10.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S575)
    {
        float3  _S576 = anisotropicLocal(l_4, lobes_10.tangent, n_i_7);
        float _S577 = anisotropicG1(_S576, lobes_10.alphas);
        G1_l_1 = _S577;
    }
    else
    {
        G1_l_1 = _S574;
    }
    return make_float3 (lobes_10.reflect_weight * G1_l_1) * lobes_10.F / make_float3 (lobes_10.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_9, float eta_i_8, float eta_o_8, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S578 = negate_0(in_dir_4);
    float _S579 = dot_0(n_7, _S578);
    float _S580 = sign_0(_S579);
    float3  _S581 = n_7 * make_float3 (_S580);
    AnisotropicFrame _S582 = anisotropicFrame(material_9, _S581);
    float _S583 = dot_0(_S581, out_dir_2);
    float _S584 = material_9.roughness;
    float _S585 = _S584 * _S584;
    float _S586 = rgb_to_greyscale(material_9.translucent);
    bool _S587 = _S586 > 0.0f;
    bool _S588 = (dot_0(n_7, out_dir_2) * _S579) < 0.0f;
    uint _S589;
    if((F32_abs((material_9.toon.x))) > 0.0f)
    {
        _S589 = 5U;
    }
    else
    {
        _S589 = 4U;
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
        float3  _S590 = make_float3 (0.0f);
        (*throughputs_0)[i_6] = _S590;
        (*pdfs_0)[i_6] = 0.0f;
        uint i_7 = i_6 + 1U;
        i_6 = i_7;
    }
    float3  _S591 = make_float3 (0.0f);
    BSDFLobes _S592 = BSDFLobes_x24init_0(0.0f, 0.0f, _S591, _S591, 0.0f, 0.0f, _S591, _S591, 0.0f, 0.0f, 0.0f, 0.0f, _S591, 0.0f, _S591, _S591, make_float2 (0.0f), 0.0f, 0.0f, _S591, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S591);
    BSDFLobes lobe_terms_0 = _S592;
    uint half_of_0 = 4294967295U;
    float3  ggx_n_2 = _S591;
    i_6 = 0U;
    for(;;)
    {
        if(i_6 < _S589)
        {
        }
        else
        {
            break;
        }
        uint _S593;
        if(i_6 == 3U)
        {
            _S593 = 4U;
        }
        else
        {
            if(i_6 == 4U)
            {
                _S593 = 6U;
            }
            else
            {
                _S593 = i_6;
            }
        }
        bool _S594 = _S593 == 0U;
        bool _S595;
        if(_S594)
        {
            _S595 = _S587;
        }
        else
        {
            _S595 = false;
        }
        bool _S596;
        if(_S595)
        {
            _S596 = _S588;
        }
        else
        {
            _S596 = _S593 == 1U;
        }
        bool _S597 = _S596 != refracted_2;
        if(_S597)
        {
            ggx_n_1 = ggx_n_2;
            uint i_8 = i_6 + 1U;
            ggx_n_2 = ggx_n_1;
            i_6 = i_8;
            continue;
        }
        uint _S598;
        if(_S593 == 6U)
        {
            _S598 = 0U;
        }
        else
        {
            if(_S593 == 4U)
            {
                _S598 = 2U;
            }
            else
            {
                _S598 = _S593;
            }
        }
        bool _S599 = _S598 != half_of_0;
        uint half_of_1;
        if(_S599)
        {
            bool _S600 = _S598 == 0U;
            if(_S600)
            {
                float3  _S601 = sampledHalf(in_dir_4, n_7, material_9, random_state_4, _S582);
                ggx_n_1 = _S601;
            }
            else
            {
                bool _S602 = _S598 == 1U;
                if(_S602)
                {
                    float3  _S603 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_8, eta_o_8);
                    ggx_n_1 = _S603;
                }
                else
                {
                    float3  _S604 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S604;
                }
            }
            float3  _S605 = negate_0(in_dir_4);
            BSDFLobes _S606 = bsdfLobes(in_dir_4, _S605, _S581, ggx_n_1, material_9, eta_i_8, eta_o_8, _S582);
            lobe_terms_0 = _S606;
            float _S607 = translucentShare(material_9);
            (&lobe_terms_0)->translucent_share = _S607;
            half_of_1 = _S598;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S593)
        {
        case 0U:
            {
                float _S608 = diffusePDF(_S583, 0.0f, (F32_abs((_S579))), _S585, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(0)] = _S608;
                float3  _S609 = diffuseBSDF(out_dir_2, _S581, _S585, material_9, lobe_terms_0);
                (*throughputs_0)[int(0)] = _S609;
                break;
            }
        case 1U:
            {
                float _S610 = refractPDF(_S583, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S579))), _S585, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(1)] = _S610;
                float3  _S611 = refractBSDF(out_dir_2, _S581, _S585, material_9, lobe_terms_0);
                (*throughputs_0)[int(1)] = _S611;
                break;
            }
        case 4U:
            {
                float _S612 = sheenVelvetPDF(_S583, 0.0f, (F32_abs((_S579))), _S585, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(3)] = _S612;
                float3  _S613 = sheenVelvetBSDF(out_dir_2, _S581, _S585, material_9, lobe_terms_0);
                (*throughputs_0)[int(3)] = _S613;
                break;
            }
        case 6U:
            {
                float _S614 = toonPDF(_S583, dot_0(out_dir_2, (&lobe_terms_0)->toon_axis), (F32_abs((_S579))), _S585, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(4)] = _S614;
                float3  _S615 = toonBSDF(out_dir_2, _S581, _S585, material_9, lobe_terms_0);
                (*throughputs_0)[int(4)] = _S615;
                break;
            }
        default:
            {
                float _S616 = reflectPDF(_S583, 0.0f, (F32_abs((_S579))), _S585, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(2)] = _S616;
                float3  _S617 = reflectBSDF(out_dir_2, _S581, _S585, material_9, lobe_terms_0);
                (*throughputs_0)[int(2)] = _S617;
                break;
            }
        }
        half_of_0 = half_of_1;
        uint i_8 = i_6 + 1U;
        ggx_n_2 = ggx_n_1;
        i_6 = i_8;
    }
    i_6 = 0U;
    ggx_n_1 = _S591;
    for(;;)
    {
        if(i_6 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S618 = ((*pdfs_0)[i_6]) > 0.0f;
        if(_S618)
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
    bool _S619 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    float3  _S620 = BSDF(in_dir_5, dir_3, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S619, random_state_5, terms_0, pdfs_1);
    float3  _S621 = make_float3 (0.0f);
    uint i_10 = 0U;
    float3  f_3 = _S621;
    for(;;)
    {
        if(i_10 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S622 = ((*pdfs_1)[i_10]) > 0.0f;
        if(_S622)
        {
            float3  _S623 = (*terms_0)[i_10] * make_float3 ((*pdfs_1)[i_10]) / make_float3 ((*pdfs_1)[i_10] + pdf_0);
            (*terms_0)[i_10] = _S623;
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
    FKSurface _S624 = surface_2;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S625 = skyLobes_0(in_dir_6, dir_4, &_S624, eta_2, is_inside_3, pdf_1, random_state_6, &terms_1, &pdfs_2);
    return _S625;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S626;
    (&_S626)->dir = dir_5;
    (&_S626)->radiance = radiance_0;
    (&_S626)->color = color_0;
    (&_S626)->random_state = random_state_7;
    return _S626;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S627 = (fcptEnvironmentCdfSize());
    uint2  _S628 = make_uint2 (1U, 0U);
    uint2  _S629 = _S627 - _S628;
    Random _S630 = pcg(init_random_state_0);
    Random _S631 = pcg(_S630.state);
    Random _S632 = pcg(_S631.state);
    Random _S633 = pcg(_S632.state);
    uint _S634 = _S629.x;
    uint _S635 = searchCDF_0(make_uint2 (_S634, 0U), make_uint2 (0U, 1U), _S629.y, _S630.value);
    uint _S636 = searchCDF_0(make_uint2 (0U, _S635), _S628, _S634, _S631.value);
    float2  _S637 = make_float2 ((float)_S629.x, (float)_S629.y);
    float2  _S638 = (make_float2 (float(_S636), float(_S635)) + make_float2 (_S632.value, _S633.value)) / _S637 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S639 = _S638.y;
    float _S640 = (F32_sin((_S639)));
    float _S641 = _S638.x;
    float3  _S642 = make_float3 (- _S640 * (F32_cos((_S641))), _S640 * (F32_sin((_S641))), (F32_cos((_S639))));
    float _S643 = environmentPdf_0(_S642);
    float3  _S644 = skyBSDF(ray_0->unit_direction, _S642, *surface_3, eta_3, is_inside_4, _S643, lobe_state_0);
    bool _S645 = !(_S643 > 0.0f);
    bool _S646;
    if(_S645)
    {
        _S646 = true;
    }
    else
    {
        _S646 = all_1(_S644 == make_float3 (0.0f));
    }
    if(_S646)
    {
        float3  _S647 = make_float3 (0.0f);
        return SkySample_x24init_0(_S642, _S647, _S647, _S633.state);
    }
    float3  _S648 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S642, context_2, _S633.state);
    return SkySample_x24init_0(_S642, _S648, _S644 * _S648, _S633.state);
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
    SampleBSDF _S649 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S650 = _S649.throughput * make_float3 (_S649.pdf);
    float _S651 = light_1->density;
    float _S652 = 1.0f + _S649.pdf * _S649.pdf / (light_1->density * light_1->density);
    bool _S653;
    if(competing_0)
    {
        _S653 = _S651 > 0.0f;
    }
    else
    {
        _S653 = false;
    }
    float _S654 = _slang_select(_S653, _S652,1.0f);
    return _S650 / make_float3 (_S654) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S655;
    (&_S655)->dir = dir_6;
    (&_S655)->radiance = radiance_1;
    (&_S655)->density = density_0;
    (&_S655)->random_state = random_state_8;
    return _S655;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S656 = importance(first_1, p_12, normal_3);
    float _S657 = importance(second_1, p_12, normal_3);
    float2  _S658 = make_float2 (_S656, _S657);
    bool _S659 = _S656 == 0.0f;
    bool _S660;
    if(_S659)
    {
        _S660 = _S657 == 0.0f;
    }
    else
    {
        _S660 = false;
    }
    if(_S660)
    {
        return 2U;
    }
    float _S661 = _S656 + _S657;
    bool _S662 = _S657 > 0.0f;
    if(_S662)
    {
        _S660 = (*pick_0 * _S661) >= _S656;
    }
    else
    {
        _S660 = false;
    }
    uint _S663 = uint(_S660);
    float _S664 = (F32_min(((*pick_0 * _S661 - float(_S663) * _S656) / _slang_vector_get_element(_S658, _S663)), (0.99999994039535522f)));
    *pick_0 = _S664;
    float _S665 = *probability_3 * (_slang_vector_get_element(_S658, _S663) / _S661);
    *probability_3 = _S665;
    return _S663;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S666 = center_1 - p_13;
    float _S667 = radius_1 * radius_1 / dot_0(_S666, _S666);
    float _S668 = u1_0 * _S667 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S667), (0.0f)))))));
    float _S669 = 2.0f * u1_0;
    bool _S670 = _S667 >= 1.0f;
    float _S671 = _slang_select(_S670, _S669,_S668);
    float _S672 = (F32_sqrt(((F32_max((_S671 * (2.0f - _S671)), (0.0f))))));
    float _S673 = 6.28318548202514648f * u2_0;
    float3  _S674 = make_float3 (_S672 * (F32_cos((_S673))), 1.0f - _S671, _S672 * (F32_sin((_S673))));
    float3  _S675 = ((((_S666)) * make_float3(rnorm3df(((_S666)).x, ((_S666)).y, ((_S666)).z))));
    float3  _S676 = tangentToWorld(_S674, _S675);
    return _S676;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S677 = center_2 - ray_1->origin;
    float _S678 = dot_0(_S677, ray_1->unit_direction);
    float _S679 = dot_0(_S677, _S677) - _S678 * _S678;
    float _S680 = radius_3 * radius_3;
    bool _S681 = _S679 > _S680;
    if(_S681)
    {
        return 4.294967296e+09f;
    }
    float _S682 = (F32_sqrt((_S680 - _S679)));
    float _S683 = _S678 - _S682;
    float _S684 = _S678 + _S682;
    bool _S685 = _S683 > 0.0000152587890625f;
    bool _S686;
    if(_S685)
    {
        _S686 = _S683 < max_len_0;
    }
    else
    {
        _S686 = false;
    }
    if(_S686)
    {
        return _S683;
    }
    bool _S687 = _S684 > 0.0000152587890625f;
    if(_S687)
    {
        _S686 = _S684 < max_len_0;
    }
    else
    {
        _S686 = false;
    }
    if(_S686)
    {
        return _S684;
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
    Random _S688 = pcg(init_random_state_1);
    Random _S689 = pcg(_S688.state);
    Random _S690 = pcg(_S689.state);
    float3  _S691 = make_float3 (0.0f);
    TreeSample _S692 = TreeSample_x24init_0(_S691, _S691, 0.0f, _S690.state);
    TreeSample sample_0 = _S692;
    float3  _S693 = _slang_select(sided_0, _S691,smooth_n_2);
    float3  _S694 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S688.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S695 = (fcptLightNode((n_8)));
        if((_S695.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S696 = (fcptLightSecond((n_8)));
        uint _S697 = n_8 + 1U;
        LightNode _S698 = (fcptLightBounds((_S697)));
        LightNode _S699 = (fcptLightBounds((_S696)));
        uint _S700 = pickChild(_S698, _S699, origin_4, _S693, &pick_1, &probability_4);
        bool _S701 = _S700 > 1U;
        if(_S701)
        {
            return sample_0;
        }
        bool _S702 = _S700 == 1U;
        uint _S703 = _slang_select(_S702, _S696,_S697);
        n_8 = _S703;
    }
    bool _S704 = n_8 == 0U;
    bool _S705;
    if(_S704)
    {
        LightNode _S706 = (fcptLightBounds((0U)));
        float _S707 = importance(_S706, origin_4, _S693);
        _S705 = !(_S707 > 0.0f);
    }
    else
    {
        _S705 = false;
    }
    if(_S705)
    {
        return sample_0;
    }
    uint4  _S708 = (fcptLightNode((n_8)));
    FKHit _S709 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S710 = (_S708.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S710)
    {
        FKLight _S711 = (fcptLight((_S708.y)));
        if(sided_0)
        {
            float _S712 = sign_0(dot_0(geometry_n_1, _S711.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S712);
            float3  _S713 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S713;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S694;
            lift_n_0 = smooth_n_2;
        }
        bool _S714 = (_S711.variance) == 0.0f;
        if(_S714)
        {
            float3  _S715 = _S711.position - emitter_point_0;
            float3  _S716 = ((((_S715)) * make_float3(rnorm3df(((_S715)).x, ((_S715)).y, ((_S715)).z))));
            (&sample_0)->dir = _S716;
            float3  _S717 = _S711.color * make_float3 (_S711.intensity) / make_float3 (dot_0(_S715, _S715) * probability_4);
            (&sample_0)->radiance = _S717;
            shadow_1 = _S715;
        }
        else
        {
            float3  _S718 = sampleSphere(_S711.position, _S711.variance, emitter_point_0, _S689.value, _S690.value);
            (&sample_0)->dir = _S718;
            float _S719 = sphereDensity(_S711.position, _S711.variance, emitter_point_0);
            float _S720 = probability_4 * _S719;
            (&sample_0)->density = _S720;
            float3  _S721 = pointLightRadiance(_S711.color, _S711.intensity, _S711.variance);
            float3  _S722 = _S721 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S722;
            FKRay _S723 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S724 = raySphere_0(_S711.position, _S711.variance, &_S723, 4.294967296e+09f);
            float3  _S725 = (&sample_0)->dir * make_float3 (_S724);
            shadow_1 = _S725;
        }
        emitter_0 = _S709;
        emitter_point_0 = _S691;
    }
    else
    {
        uint _S726 = _S708.y;
        uint _S727 = (fcptTriangleOffset((_S726)));
        uint _S728 = _S727 + _S708.z;
        Matrix<float, 3, 3>  _S729 = (fcptWorldTriangle((_S726), (_S728)));
        float _S730 = (F32_sqrt((_S689.value)));
        float2  _S731 = make_float2 (_S730 * (1.0f - _S690.value), _S730 * _S690.value);
        float3  _S732 = mul_0(make_float3 (1.0f - _S730, _S731.x, _S731.y), _S729);
        if(sided_0)
        {
            float _S733 = sign_0(dot_0(geometry_n_1, _S732 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S733);
            float3  _S734 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S734;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S735 = !((dot_0(smooth_n_2, _S732 - origin_4)) > 0.0f);
            if(_S735)
            {
                return sample_0;
            }
            emitter_point_0 = _S694;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S731, _S726, _S728, 0U, 0.0f);
        float3  _S736 = _S732 - emitter_point_0;
        float3  _S737 = ((((_S736)) * make_float3(rnorm3df(((_S736)).x, ((_S736)).y, ((_S736)).z))));
        (&sample_0)->dir = _S737;
        float _S738 = solidAngle(probability_4, cross_0(_S729.rows[int(1)] - _S729.rows[int(0)], _S729.rows[int(2)] - _S729.rows[int(0)]), _S736);
        (&sample_0)->density = _S738;
        bool _S739 = (fcptShadowFirst());
        bool _S740 = !_S739;
        if(_S740)
        {
            FKSurface _S741 = (fcptLightSurfaceAt((emitter_1), (_S732), (_S690.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S732 - origin_4))));
            (&sample_0)->random_state = _S741.random_state;
            float3  _S742 = _slang_select(_S741.skip, _S691,_S741.material.emissive);
            float3  _S743 = _S742 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S743;
        }
        shadow_1 = _S736;
        emitter_0 = emitter_1;
        emitter_point_0 = _S732;
    }
    FKHit _S744 = emitter_0;
    float3  _S745 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S690.state, &_S744);
    bool _S746 = (fcptShadowFirst());
    if(_S746)
    {
        _S705 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S705 = false;
    }
    if(_S705)
    {
        _S705 = !all_1(_S745 == _S691);
    }
    else
    {
        _S705 = false;
    }
    if(_S705)
    {
        FKSurface _S747 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S690.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S747.random_state;
        float3  _S748 = _slang_select(_S747.skip, _S691,_S747.material.emissive);
        float3  _S749 = _S748 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S749;
    }
    float3  _S750 = (&sample_0)->radiance * _S745;
    bool _S751 = all_1(_S745 == _S691);
    float3  _S752 = _slang_select(_S751, _S691,_S750);
    (&sample_0)->radiance = _S752;
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
    float _S753 = 1.0f / (1.0f + b_3 / a_7 * (b_3 / a_7));
    bool _S754 = b_3 > 0.0f;
    float _S755 = _slang_select(_S754, _S753,1.0f);
    return _S755;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S756 = vertex_0->none;
    if(_S756)
    {
        return 1.0f;
    }
    uint _S757 = (fcptLightSlot((*hit_1)));
    float _S758 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S757, light_point_1);
    float _S759 = powerHeuristic(vertex_0->pdf, _S758);
    return _S759;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_0)
{
    uint2  _S760 = (fcptEnvironmentMapSize());
    bool _S761 = (_S760.x) > 1U;
    bool _S762;
    if(_S761)
    {
        uint2  _S763 = (fcptEnvironmentMapSize());
        _S762 = (_S763.y) > 1U;
    }
    else
    {
        _S762 = false;
    }
    if(_S762)
    {
        float3  _S764 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_0)));
        return _S764;
    }
    float3  _S765 = (fcptAmbient());
    return _S765;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S766 = (fcptEnvironmentCdfSize());
    bool _S767 = (_S766.x) > 1U;
    bool _S768;
    if(_S767)
    {
        uint2  _S769 = (fcptEnvironmentCdfSize());
        _S768 = (_S769.y) > 1U;
    }
    else
    {
        _S768 = false;
    }
    bool _S770 = !_S768;
    if(_S770)
    {
        return false;
    }
    uint2  _S771 = (fcptEnvironmentMapSize());
    bool _S772 = (_S771.x) > 1U;
    if(_S772)
    {
        uint2  _S773 = (fcptEnvironmentMapSize());
        _S768 = (_S773.y) > 1U;
    }
    else
    {
        _S768 = false;
    }
    return _S768;
}

static __device__ float escapeWeight_0(float pdf_2, float3  dir_8)
{
    bool _S774 = pdf_2 <= 0.0f;
    bool _S775;
    if(_S774)
    {
        _S775 = true;
    }
    else
    {
        bool _S776 = environmentMapped_0();
        _S775 = !_S776;
    }
    if(_S775)
    {
        return 1.0f;
    }
    float _S777 = environmentPdf_0(dir_8);
    return pdf_2 / (pdf_2 + _S777);
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
    uint2  _S778 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S779 = make_int2 ((int)_S778.x, (int)_S778.y);
    uint _S780 = previousSeed_0(_S779);
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
            uint _S781 = previousSeed_0(_S779 + make_int2 (x_16, y_5));
            bool _S782 = _S781 == _S780;
            uint _S783 = _slang_select(_S782, 1U,0U);
            uint count_3 = count_2 + _S783;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S784 = float(count_2 - 1U) / 288.0f;
    bool _S785 = _S780 != 0U;
    float _S786 = _slang_select(_S785, _S784,0.0f);
    fcptStoreDuplication((_S779), (make_uint4 ((F32_asuint((_S786))), 0U, 0U, 0U)));
    return;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S787 = hash(index_0);
    uint _S788 = hash(seed_3 ^ _S787);
    return _S788;
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
    float _S789 = rgb_to_greyscale(weight_0);
    bool _S790 = _S789 > 0.0f;
    bool _S791;
    if(_S790)
    {
        _S791 = _S789 < 3.00000000549775576e+38f;
    }
    else
    {
        _S791 = false;
    }
    bool _S792 = !_S791;
    if(_S792)
    {
        return;
    }
    bool _S793 = sel_2->sums;
    if(_S793)
    {
        float3  _S794 = sel_2->color + weight_0;
        sel_2->color = _S794;
        return;
    }
    float _S795 = sel_2->w_sum + _S789;
    sel_2->w_sum = _S795;
    float3  _S796 = sel_2->color + weight_0;
    sel_2->color = _S796;
    Random _S797 = pcg(sel_2->random_state);
    sel_2->random_state = _S797.state;
    bool _S798 = (_S797.value * sel_2->w_sum) <= _S789;
    if(_S798)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S799 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S799;
    float _S800 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S800;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S801 = rgb_to_greyscale((&r_4)->f);
    float _S802 = sel_4.w_sum / _S801;
    bool _S803 = _S801 > 0.0f;
    float _S804 = _slang_select(_S803, _S802,0.0f);
    (&r_4)->w = _S804;
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
    uint2  _S805 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S806 = make_int2 ((int)_S805.x, (int)_S805.y);
    float3  _S807 = make_float3 (0.0f);
    FKHit _S808 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S809 = Domain_x24init_0(_S807, _S807, &_S808, 0.0f, 0.0f);
    Domain dom_4 = _S809;
    bool _S810 = (fcptCurrentDomain((_S806), (&dom_4)));
    bool _S811 = !_S810;
    if(_S811)
    {
        Reservoir _S812 = (Reservoir{});
        fcptStoreReservoirPrevious((_S806), (_S812), ((&dom_4)->hit));
        return;
    }
    Reservoir _S813 = (fcptLoadReservoirTemporal((_S806)));
    uint t_13 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S813.c;
    for(;;)
    {
        uint _S814 = (fcptRestirNeighbours());
        if(t_13 < _S814)
        {
        }
        else
        {
            break;
        }
        int2  _S815 = partner_0(_S806, t_13);
        Domain neighbor_0 = _S809;
        bool _S816 = (fcptCurrentDomain((_S815), (&neighbor_0)));
        if(_S816)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S817 = (fcptReservoirTemporal((_S815), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S817.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_14 = t_13 + 1U;
        t_13 = t_14;
    }
    float _S818 = _S813.c / (F32_max((count_4), (1.0f)));
    float _S819 = rgb_to_greyscale(_S813.f);
    bool _S820 = count_4 == 0.0f;
    float _S821 = _slang_select(_S820, 1.0f,0.0f);
    Selection _S822 = (Selection{});
    Selection sel_5 = _S822;
    uint _S823 = (fcptFrame());
    uint _S824 = hash(_S823);
    uint _S825 = global_invocation_id_2.x;
    uint2  _S826 = (fcptRenderSize());
    uint _S827 = stream(_S824, _S825 + _S826.x * global_invocation_id_2.y);
    uint _S828 = stream(_S827, 195U);
    (&sel_5)->random_state = _S828;
    t_13 = 0U;
    float canonical_mis_0 = _S821;
    for(;;)
    {
        uint _S829 = (fcptRestirNeighbours());
        if(t_13 < _S829)
        {
        }
        else
        {
            break;
        }
        int2  _S830 = partner_0(_S806, t_13);
        Domain neighbor_dom_0 = _S809;
        bool _S831 = (fcptCurrentDomain((_S830), (&neighbor_dom_0)));
        if(_S831)
        {
            Reservoir _S832 = (fcptLoadReservoirTemporal((_S830)));
            uint4  _S833 = (fcptShiftData((_S830), (t_13)));
            float4  _S834 = asfloat_0(_S833);
            uint4  _S835 = (fcptShiftData((_S806), (t_13)));
            float4  _S836 = asfloat_0(_S835);
            float _S837 = pairShare(_S832.c, _S818, c_sum_1);
            bool _S838 = _S819 > 0.0f;
            float canonical_mis_1;
            if(_S838)
            {
                float _S839 = rgb_to_greyscale(float3 {_S836.x, _S836.y, _S836.z});
                float _S840 = canonicalWeight(_S837, _S818, _S819, _S832.c, _S839);
                float canonical_mis_2 = canonical_mis_0 + _S840;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S841 = float3 {_S834.x, _S834.y, _S834.z};
            Shift _S842 = Shift_x24init_0(_S841, _S834.w);
            float _S843 = rgb_to_greyscale(_S832.f);
            float _S844 = rgb_to_greyscale(_S841);
            float _S845 = neighborWeight(_S837, _S832.c, _S843, _S818, _S844);
            offerShifted(&sel_5, _S832, _S842, _S845);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_15 = t_13 + 1U;
        t_13 = t_15;
    }
    offerShifted(&sel_5, _S813, Shift_x24init_0(_S813.f, 1.0f), canonical_mis_0);
    Reservoir _S846 = finalize(sel_5, c_sum_1);
    fcptStoreReservoirPrevious((_S806), (_S846), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S806), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S806), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S847 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S848 = _S847 != 4294967295U;
    if(_S848)
    {
        uint2  _S849 = make_uint2 (_S847, _S847 >> 14U) & make_uint2 (16383U);
        int2  _S850 = make_int2 ((int)_S849.x, (int)_S849.y);
        ShiftJob _S851 = (ShiftJob{});
        ShiftJob shift_job_0 = _S851;
        Shift _S852 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S853 = _S847 >> 28U;
        bool _S854 = spatialJob_0(_S850, _S853, &shift_job_0, true);
        Shift shifted_1;
        if(_S854)
        {
            Domain _S855 = (&shift_job_0)->dom;
            Reservoir _S856 = (&shift_job_0)->r;
            Shift _S857 = passShift_0(&_S855, &_S856);
            shifted_1 = _S857;
        }
        else
        {
            shifted_1 = _S852;
        }
        fcptStoreShiftData((_S850), (_S853), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S858 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S859 = make_int2 ((int)_S858.x, (int)_S858.y);
    FixedArray<uint, 3>  _S860;
    spatialBins_0(_S859, &_S860);
    FixedArray<uint, 3>  _S861 = _S860;
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
        bool _S862 = (_S861[t_16]) == 40U;
        if(_S862)
        {
            fcptStoreShiftData((_S859), (t_16), (make_uint4 (0U)));
        }
        uint t_17 = t_16 + 1U;
        t_16 = t_17;
    }
    FixedArray<uint, 3>  _S863 = _S861;
    queueShifts_0(_S859, &_S863, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S864 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S865 = make_int2 ((int)_S864.x, (int)_S864.y);
    FixedArray<uint, 3>  _S866;
    spatialBins_0(_S865, &_S866);
    FixedArray<uint, 3>  _S867 = _S866;
    countShifts_0(&_S867, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S868 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S869 = _S868 != 4294967295U;
    if(_S869)
    {
        uint2  _S870 = make_uint2 (_S868, _S868 >> 14U) & make_uint2 (16383U);
        int2  _S871 = make_int2 ((int)_S870.x, (int)_S870.y);
        int2  _S872 = (fcptLoadTemporalNeighbor((_S871)));
        uint _S873 = _S868 >> 28U;
        Shift _S874 = temporalShiftAt_0(_S871, _S872, _S873);
        fcptStoreTemporalShift((_S871), (_S873), (make_uint4 (asuint_1(_S874.f).x, asuint_1(_S874.f).y, asuint_1(_S874.f).z, (F32_asuint((_S874.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S875 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S876 = make_int2 ((int)_S875.x, (int)_S875.y);
    FixedArray<uint, 3>  _S877;
    temporalBins_0(_S876, &_S877);
    FixedArray<uint, 3>  _S878 = _S877;
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
        bool _S879 = (_S878[t_18]) == 40U;
        if(_S879)
        {
            fcptStoreTemporalShift((_S876), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S880 = _S878;
    queueShifts_0(_S876, &_S880, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S881 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S882 = make_int2 ((int)_S881.x, (int)_S881.y);
    bool _S883 = (fcptSceneUnchanged());
    bool _S884 = !_S883;
    bool _S885;
    if(_S884)
    {
        uint2  _S886 = (fcptRenderSize());
        int2  _S887 = make_int2 ((int)_S886.x, (int)_S886.y);
        _S885 = all_0(_S882 < _S887);
    }
    else
    {
        _S885 = false;
    }
    if(_S885)
    {
        Reservoir _S888 = (fcptLoadReservoirInitial((_S882)));
        int2  _S889 = sampleNeighbor_0(_S882, _S888.seed);
        fcptStoreTemporalNeighbor((_S882), (_S889));
    }
    FixedArray<uint, 3>  _S890;
    temporalBins_0(_S882, &_S890);
    FixedArray<uint, 3>  _S891 = _S890;
    countShifts_0(&_S891, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_8, float b_4, float t_20)
{
    return a_8 + (b_4 - a_8) * t_20;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S892 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S892;
}

__device__ float2  temporalWeights(float c_2, float p_c_1, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S893 = c_2 * p_c_1;
    float _S894 = c_t_0 * p_t_0;
    return make_float2 (_S893 / (_S893 + c_t_0 * g_previous_0), _S894 / (_S894 + c_2 * g_current_0));
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S895 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S896 = make_int2 ((int)_S895.x, (int)_S895.y);
    float3  _S897 = make_float3 (0.0f);
    FKHit _S898 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S899 = Domain_x24init_0(_S897, _S897, &_S898, 0.0f, 0.0f);
    Domain dom_5 = _S899;
    bool _S900 = (fcptCurrentDomain((_S896), (&dom_5)));
    bool _S901 = !_S900;
    if(_S901)
    {
        Reservoir _S902 = (Reservoir{});
        fcptStoreReservoirTemporal((_S896), (_S902), ((&dom_5)->hit));
        return;
    }
    Reservoir _S903 = (fcptLoadReservoirInitial((_S896)));
    bool _S904 = (fcptTemporalQueued());
    bool _S905 = (fcptSceneUnchanged());
    bool _S906;
    if(_S905)
    {
        _S906 = true;
    }
    else
    {
        _S906 = !_S904;
    }
    int2  _S907;
    if(_S906)
    {
        int2  _S908 = sampleNeighbor_0(_S896, _S903.seed);
        _S907 = _S908;
    }
    else
    {
        int2  _S909 = (fcptLoadTemporalNeighbor((_S896)));
        _S907 = _S909;
    }
    bool _S910 = (_S907.x) >= int(0);
    Reservoir r_5;
    if(_S910)
    {
        Reservoir _S911 = (fcptLoadReservoirPrevious((_S907)));
        uint4  _S912 = (fcptDuplication((_S907)));
        float _S913 = (U32_asfloat((_S912.x)));
        uint _S914 = (fcptRestirDecorrelation());
        bool _S915 = _S914 == 1U;
        float _S916 = _slang_select(_S915, _S913,0.0f);
        float _S917 = confidenceCap(_S916);
        float _S918 = (F32_min((_S911.c), (_S917)));
        bool _S919 = (fcptSceneUnchanged());
        float4  _S920 = make_float4 (_S911.f.x, _S911.f.y, _S911.f.z, 1.0f);
        bool _S921 = !_S919;
        if(_S921)
        {
            _S906 = _S904;
        }
        else
        {
            _S906 = false;
        }
        float4  to_current_0;
        if(_S906)
        {
            uint4  _S922 = (fcptTemporalShift((_S896), (0U)));
            float4  _S923 = asfloat_0(_S922);
            to_current_0 = _S923;
        }
        else
        {
            if(_S921)
            {
                Shift _S924 = temporalShiftAt_0(_S896, _S907, 0U);
                float4  _S925 = make_float4 (_S924.f.x, _S924.f.y, _S924.f.z, _S924.jac);
                to_current_0 = _S925;
            }
            else
            {
                to_current_0 = _S920;
            }
        }
        Domain own_1 = _S899;
        if(_S919)
        {
            _S906 = true;
        }
        else
        {
            bool _S926 = (fcptPreviousScenes());
            bool _S927 = !_S926;
            if(_S927)
            {
                _S906 = (_S903.w) > 0.0f;
            }
            else
            {
                _S906 = false;
            }
            if(_S906)
            {
                bool _S928 = (fcptStoredDomainInitial((_S896), (_S903.seed), (&own_1)));
                _S906 = _S928;
            }
            else
            {
                _S906 = false;
            }
            if(_S906)
            {
                Domain _S929 = (fcptPreviousDomain((_S907), (_S903.seed)));
                Domain _S930 = _S929;
                Domain _S931 = own_1;
                bool _S932 = sameDomain_0(&_S930, &_S931);
                _S906 = _S932;
            }
            else
            {
                _S906 = false;
            }
        }
        float4  _S933 = make_float4 (_S903.f.x, _S903.f.y, _S903.f.z, 1.0f);
        bool _S934 = !_S906;
        if(_S934)
        {
            _S906 = _S904;
        }
        else
        {
            _S906 = false;
        }
        float4  to_previous_0;
        if(_S906)
        {
            uint4  _S935 = (fcptTemporalShift((_S896), (1U)));
            float4  _S936 = asfloat_0(_S935);
            to_previous_0 = _S936;
        }
        else
        {
            if(_S934)
            {
                Shift _S937 = temporalShiftAt_0(_S896, _S907, 1U);
                float4  _S938 = make_float4 (_S937.f.x, _S937.f.y, _S937.f.z, _S937.jac);
                to_previous_0 = _S938;
            }
            else
            {
                to_previous_0 = _S933;
            }
        }
        float _S939 = rgb_to_greyscale(_S903.f);
        float _S940 = rgb_to_greyscale(_S911.f);
        Selection _S941 = (Selection{});
        Selection sel_6 = _S941;
        uint _S942 = (fcptFrame());
        uint _S943 = hash(_S942);
        uint _S944 = global_invocation_id_7.x;
        uint2  _S945 = (fcptRenderSize());
        uint _S946 = stream(_S943, _S944 + _S945.x * global_invocation_id_7.y);
        uint _S947 = stream(_S946, 194U);
        (&sel_6)->random_state = _S947;
        float4  _S948 = to_previous_0;
        float _S949 = rgb_to_greyscale(float3 {_S948.x, _S948.y, _S948.z});
        float4  _S950 = to_current_0;
        float3  _S951 = float3 {_S950.x, _S950.y, _S950.z};
        float _S952 = rgb_to_greyscale(_S951);
        float2  _S953 = temporalWeights(_S903.c, _S939, _S918, _S940, _S949, _S952);
        offerShifted(&sel_6, _S903, Shift_x24init_0(_S903.f, 1.0f), _S953.x);
        offerShifted(&sel_6, _S911, Shift_x24init_0(_S951, to_current_0.w), _S953.y);
        Reservoir _S954 = finalize(sel_6, _S903.c + _S918);
        r_5 = _S954;
    }
    else
    {
        r_5 = _S903;
    }
    fcptStoreReservoirTemporal((_S896), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S955 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S956 = make_int2 ((int)_S955.x, (int)_S955.y);
    float3  _S957 = make_float3 (0.0f);
    float2  _S958 = make_float2 (0.0f);
    FKHit _S959 = Hit_x24init_0(_S958, 0U, 0U, 0U, 0.0f);
    Domain _S960 = Domain_x24init_0(_S957, _S957, &_S959, 0.0f, 0.0f);
    Domain dom_6 = _S960;
    bool _S961 = (fcptCurrentDomain((_S956), (&dom_6)));
    bool _S962 = !_S961;
    if(_S962)
    {
        Reservoir _S963 = (Reservoir{});
        fcptStoreReservoirInitial((_S956), (_S963), ((&dom_6)->hit));
        return;
    }
    uint _S964 = (fcptFrame());
    uint _S965 = hash(_S964);
    uint _S966 = global_invocation_id_8.x;
    uint2  _S967 = (fcptRenderSize());
    uint _S968 = stream(_S965, _S966 + _S967.x * global_invocation_id_8.y);
    Selection _S969 = (Selection{});
    Selection initial_0 = _S969;
    uint _S970 = stream(_S968, 193U);
    (&initial_0)->random_state = _S970;
    bool _S971 = (fcptRestirUsed());
    bool _S972 = !_S971;
    (&initial_0)->sums = _S972;
    uint _S973 = stream(_S968, 0U);
    (&(&initial_0)->r)->seed = _S973;
    FKHit _S974 = Hit_x24init_0(_S958, 4294967295U, 0U, 0U, 0.0f);
    uint _S975 = (fcptSamples());
    float _S976 = 1.0f / float(_S975);
    FKHit hit_2 = _S974;
    uint i_17 = 0U;
    for(;;)
    {
        uint _S977 = (fcptSamples());
        if(i_17 < _S977)
        {
        }
        else
        {
            break;
        }
        Reservoir _S978 = (Reservoir{});
        Reservoir r_6 = _S978;
        uint _S979 = stream(_S968, i_17);
        (&r_6)->seed = _S979;
        Domain path_0 = _S960;
        bool _S980 = (fcptStoredDomainInitial((_S956), ((&r_6)->seed), (&path_0)));
        bool _S981 = !_S980;
        if(_S981)
        {
            fcptMissed((_S956), (path_0), (_S976));
            uint i_18 = i_17 + 1U;
            i_17 = i_18;
            continue;
        }
        Domain _S982 = path_0;
        Reservoir _S983 = r_6;
        Shift _S984 = passWalk_0(&_S982, &_S983, false, _S976, &initial_0);
        bool _S985 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S985)
        {
            FKHit _S986 = (&path_0)->hit;
            hit_3 = _S986;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_18 = i_17 + 1U;
        i_17 = i_18;
    }
    float3  _S987 = (&initial_0)->glow;
    float3  _S988 = (&initial_0)->color;
    bool _S989 = (&initial_0)->sums;
    float3  _S990 = _slang_select(_S989, _S988,_S957);
    fcptAddColor((_S956), (make_float4 ((_S987 + _S990).x, (_S987 + _S990).y, (_S987 + _S990).z, 1.0f)));
    Reservoir _S991 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S956), (_S991), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_3, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S992;
    (&_S992)->none = none_0;
    (&_S992)->pdf = pdf_3;
    (&_S992)->origin = origin_5;
    (&_S992)->smooth_n = smooth_n_3;
    (&_S992)->start = start_6;
    return _S992;
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
    Vertex _S993;
    (&_S993)->rough = rough_0;
    (&_S993)->lobe = lobe_1;
    (&_S993)->pdf = pdf_4;
    (&_S993)->cos = cos_0;
    (&_S993)->inside = inside_0;
    return _S993;
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
    float3  _S994 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_2));
    float3  _S995 = scatter_0 * _S994 / make_float3 (sigma_1);
    float3  _S996 = _slang_select(scatters_0, _S995,_S994);
    return _S996;
}

static __device__ bool scatterSampled_0(bool replay_1, uint b_5, uint stop_0, bool varying_0)
{
    bool _S997 = !replay_1;
    bool _S998;
    if(_S997)
    {
        _S998 = true;
    }
    else
    {
        bool _S999 = b_5 == stop_0;
        if(_S999)
        {
            _S998 = !varying_0;
        }
        else
        {
            _S998 = false;
        }
    }
    return _S998;
}

static __device__ uint arrivalLobe_0(uint b_6, uint prev_lobe_0)
{
    bool _S1000 = b_6 > 0U;
    uint _S1001 = _slang_select(_S1000, prev_lobe_0,3U);
    return _S1001;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_5, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1002;
    (&_S1002)->extinction_behind = extinction_behind_0;
    (&_S1002)->extinction_front = extinction_front_0;
    (&_S1002)->fillings = fillings_0;
    (&_S1002)->side = side_0;
    (&_S1002)->depth = depth_1;
    (&_S1002)->lobe = lobe_2;
    (&_S1002)->surface = surface_5;
    (&_S1002)->length = length_2;
    (&_S1002)->width = width_1;
    (&_S1002)->own = *own_2;
    (&_S1002)->fiber = fiber_0;
    return _S1002;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1003 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1003)
    {
        return 0.07957746833562851f;
    }
    float _S1004 = g_0 * g_0;
    return (1.0f - _S1004) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1004 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_9, float3  b_7)
{
    float3  _S1005 = a_9 / b_7;
    float3  _S1006 = make_float3 (0.0f);
    bool3  _S1007 = b_7 == _S1006;
    float3  _S1008 = _slang_select(_S1007, _S1006,_S1005);
    return _S1008;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1009 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1009 << offset_1))) | ((newbits_0 & _S1009) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_2 = r_7;
    uint _S1010 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1011 = insertBits_0(_S1010, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1011;
    (&candidate_2)->f = f_5;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S1012 = pcg(random_state_9);
    Random _S1013 = pcg(_S1012.state);
    float _S1014 = 1.0f - 2.0f * _S1012.value;
    float _S1015 = (F32_sqrt(((F32_max((1.0f - _S1014 * _S1014), (0.0f))))));
    float _S1016 = 6.28318548202514648f * _S1013.value;
    return make_float3 (_S1015 * (F32_cos((_S1016))), _S1015 * (F32_sin((_S1016))), _S1014);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_10, float * pdf_5)
{
    bool _S1017 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1017)
    {
        *pdf_5 = 0.07957746833562851f;
        float3  _S1018 = isotropic_0(random_state_10);
        return _S1018;
    }
    Random _S1019 = pcg(random_state_10);
    Random _S1020 = pcg(_S1019.state);
    float _S1021 = g_1 * g_1;
    float _S1022 = 2.0f * g_1;
    float _S1023 = (1.0f - _S1021) / (1.0f - g_1 + _S1022 * _S1019.value);
    float _S1024 = clamp_1((1.0f + _S1021 - _S1023 * _S1023) / _S1022, -1.0f, 1.0f);
    float _S1025 = (F32_sqrt(((F32_max((1.0f - _S1024 * _S1024), (0.0f))))));
    float _S1026 = 6.28318548202514648f * _S1020.value;
    float _S1027 = phaseHG_0(g_1, _S1024);
    *pdf_5 = _S1027;
    float3  _S1028 = tangentToWorld(make_float3 (_S1025 * (F32_cos((_S1026))), _S1024, _S1025 * (F32_sin((_S1026)))), dir_9);
    float3  _S1029 = ((((_S1028)) * make_float3(rnorm3df(((_S1028)).x, ((_S1028)).y, ((_S1028)).z))));
    return _S1029;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_5)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_2)
{
    BSDFMaterial _S1030;
    (&_S1030)->albedo = albedo_0;
    (&_S1030)->emissive = emissive_0;
    (&_S1030)->roughness = roughness_0;
    (&_S1030)->metallic = metallic_0;
    (&_S1030)->transmission = transmission_0;
    (&_S1030)->ior = ior_0;
    (&_S1030)->absorption = absorption_0;
    (&_S1030)->specular_tint = specular_tint_0;
    (&_S1030)->specular_level = specular_level_0;
    (&_S1030)->translucent = translucent_0;
    (&_S1030)->sheen = sheen_2;
    (&_S1030)->sheen_roughness = sheen_roughness_0;
    (&_S1030)->anisotropy = anisotropy_0;
    (&_S1030)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1030)->tangent = tangent_2;
    (&_S1030)->velvet = velvet_0;
    (&_S1030)->toon = toon_2;
    return _S1030;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1031;
    (&_S1031)->scatter = scatter_1;
    (&_S1031)->extinction = extinction_1;
    (&_S1031)->g = g_2;
    return _S1031;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_10, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1032;
    (&_S1032)->smooth_n = smooth_n_4;
    (&_S1032)->geometry_n = geometry_n_2;
    (&_S1032)->geometry_offset = geometry_offset_2;
    (&_S1032)->material = *material_10;
    (&_S1032)->skip = skip_0;
    (&_S1032)->random_state = random_state_11;
    (&_S1032)->coverage = coverage_0;
    (&_S1032)->encloses = encloses_0;
    (&_S1032)->volume = *volume_0;
    (&_S1032)->fills = fills_0;
    (&_S1032)->hair = hair_0;
    return _S1032;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S1033 = (&surface_6->material)->emissive;
    float3  _S1034 = make_float3 (0.0f);
    bool _S1035 = !top_0;
    float3  _S1036 = _slang_select(_S1035, _S1034,_S1033);
    (&(&lower_0)->material)->emissive = _S1036;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_2)
{
    float _S1037 = surface_7->coverage;
    bool _S1038 = u_2 < _S1037;
    if(_S1038)
    {
        return *surface_7;
    }
    float3  _S1039 = make_float3 (0.0f);
    float3  _S1040 = make_float3 (1.0f);
    BSDFMaterial _S1041 = Material_x24init_0(_S1039, _S1039, 0.0f, 0.0f, 0.0f, 0.0f, _S1039, _S1040, 1.0f, _S1039, _S1039, 0.5f, 0.0f, 0.0f, _S1039, 0.0f, _S1039);
    BSDFMaterial material_11 = _S1041;
    (&material_11)->albedo = _S1040;
    (&material_11)->emissive = (&surface_7->material)->emissive;
    (&material_11)->transmission = 1.0f;
    (&material_11)->ior = 1.0f;
    (&material_11)->absorption = (&surface_7->material)->absorption;
    FKSurface through_0 = *surface_7;
    (&through_0)->material = material_11;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S1042 = transmission_1 > 0.0f;
    bool _S1043;
    if(_S1042)
    {
        _S1043 = true;
    }
    else
    {
        _S1043 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1044;
    if(_S1043)
    {
        _S1044 = 1.0f;
    }
    else
    {
        _S1044 = -1.0f;
    }
    return _S1044;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_9)
{
    return (dot_0(dir_10, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_11)
{
    float3  _S1045 = surface_8->geometry_n;
    float _S1046 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_11);
    FKSurface faced_0 = *surface_8;
    float3  _S1047 = surface_8->smooth_n * make_float3 (_S1046);
    (&faced_0)->smooth_n = _S1047;
    float3  _S1048 = _S1045 * make_float3 (_S1046);
    (&faced_0)->geometry_n = _S1048;
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
    float3  _S1049 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1049));
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
    bool _S1050;
    if(open_0)
    {
        _S1050 = prev_rough_0;
    }
    else
    {
        _S1050 = false;
    }
    if(_S1050)
    {
        _S1050 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S1050 = false;
    }
    return _S1050;
}

__device__ float2  vertexEta(BSDFMaterial material_12, float n_dot_v_0)
{
    bool _S1051 = n_dot_v_0 < 0.0f;
    float _S1052 = _slang_select(_S1051, material_12.ior,1.0f);
    float _S1053 = _slang_select(_S1051, 1.0f,material_12.ior);
    return make_float2 (_S1052, _S1053);
}

__device__ bool neeDecision(BSDFMaterial material_13, float n_dot_v_1, float eta_i_9, float eta_o_9)
{
    float _S1054 = fresnel((F32_abs((n_dot_v_1))), eta_i_9, eta_o_9);
    float3  _S1055 = mix_0(make_float3 (_S1054), material_13.albedo, material_13.metallic);
    float _S1056 = rgb_to_greyscale(_S1055);
    float _S1057 = (F32_max(((1.0f - _S1056) * (1.0f - material_13.metallic) * (1.0f - material_13.transmission)), (0.0f)));
    bool _S1058 = _S1057 > 0.03999999910593033f;
    bool _S1059;
    if(_S1058)
    {
        _S1059 = true;
    }
    else
    {
        _S1059 = (material_13.roughness) > 0.20000000298023224f;
    }
    return _S1059;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_14)
{
    float _S1060 = rgb_to_greyscale(material_14->translucent);
    return _S1060 > 0.0f;
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
    MediumSides _S1061;
    (&_S1061)->behind = *behind_0;
    (&_S1061)->front = *front_0;
    (&_S1061)->fillings = fillings_1;
    (&_S1061)->face = face_1;
    return _S1061;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1062 = surface_9->geometry_n;
    MediumSides _S1063 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S1063;
    bool _S1064 = surface_9->encloses;
    if(_S1064)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S1065 = (dot_0(dir_12, _S1062)) > 0.0f;
        if(_S1065)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1066 = surface_10->geometry_n;
    ShadowContext _S1067 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1068 = surface_10->encloses;
    ShadowContext context_4;
    if(_S1068)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S1069 = - _S1066;
        float3  _S1070 = _slang_select(turned_0, _S1069,_S1066);
        (&faced_1)->geometry_n = _S1070;
        FKMedium _S1071 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1072 = faced_1;
        FKMedium _S1073 = _S1071;
        MediumSides _S1074 = mediumSides_0(&_S1072, &_S1073, filling_1, dir_13, outside_1);
        ShadowContext _S1075 = ShadowContext_x24init_0(_S1074.behind.extinction, _S1074.front.extinction, _S1074.fillings, _S1066, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1076 = _S1074.fillings;
            ShadowContext _S1077 = ShadowContext_x24init_0(_S1074.front.extinction, _S1074.behind.extinction, uint2 {_S1076.y, _S1076.x}, _S1066, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1077;
        }
        else
        {
            context_4 = _S1075;
        }
    }
    else
    {
        context_4 = _S1067;
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

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_15, float eta_i_10, float eta_o_10, bool competing_1, uint random_state_12)
{
    float3  _S1078 = light_2->dir;
    bool _S1079 = (dot_0(geometry_n_4, - in_dir_8) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_3;
    float3  _S1080 = BSDF(in_dir_8, _S1078, smooth_n_5, *material_15, eta_i_10, eta_o_10, _S1079, random_state_12, &throughputs_1, &pdfs_3);
    bool _S1081 = !competing_1;
    bool _S1082;
    if(_S1081)
    {
        _S1082 = true;
    }
    else
    {
        _S1082 = (light_2->density) == 0.0f;
    }
    if(_S1082)
    {
        return _S1080 * light_2->radiance;
    }
    float3  _S1083 = make_float3 (0.0f);
    uint i_23 = 0U;
    float3  weighted_0 = _S1083;
    for(;;)
    {
        if(i_23 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1084 = (pdfs_3[i_23]) > 0.0f;
        if(_S1084)
        {
            float _S1085 = light_2->density;
            float _S1086 = pdfs_3[i_23] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_23] * make_float3 (pdfs_3[i_23]) / make_float3 (_S1085 * (1.0f + _S1086 * _S1086));
            weighted_0 = weighted_1;
        }
        uint i_24 = i_23 + 1U;
        i_23 = i_24;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_13, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S1087;
    (&_S1087)->unit_direction = unit_direction_1;
    (&_S1087)->throughput = throughput_1;
    (&_S1087)->random_state = random_state_13;
    (&_S1087)->refracted = refracted_3;
    (&_S1087)->lobe = lobe_4;
    (&_S1087)->pdf = pdf_6;
    return _S1087;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_8, float n_i_dot_v_6, float alpha_15, BSDFMaterial material_16, BSDFLobes lobes_11, float eta_i_11, float eta_o_11, uint random_state_14)
{
    float3  _S1088 = make_float3 (1.0f);
    SampleBSDF _S1089 = SampleBSDF_x24init_0(_S1088, _S1088, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1089;
    Random _S1090 = pcg(random_state_14);
    Random _S1091 = pcg(_S1090.state);
    (&sample_1)->random_state = _S1091.state;
    float _S1092 = _S1090.value;
    float _S1093 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1092 * _S1092))))));
    float _S1094 = 6.28318548202514648f * _S1091.value;
    float3  _S1095 = tangentToWorld(make_float3 (_S1093 * (F32_cos((_S1094))), _S1090.value, _S1093 * (F32_sin((_S1094)))), n_i_8);
    (&sample_1)->unit_direction = _S1095;
    (&sample_1)->lobe = 4U;
    float3  _S1096 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_8, alpha_15, material_16, lobes_11);
    (&sample_1)->throughput = _S1096;
    float _S1097 = sheenVelvetPDF(_S1090.value, 0.0f, n_i_dot_v_6, alpha_15, lobes_11, eta_i_11, eta_o_11);
    (&sample_1)->pdf = _S1097;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1098 = (F32_sqrt((random_1_0)));
    float _S1099 = 6.28318548202514648f * random_2_0;
    float _S1100 = _S1098 * (F32_cos((_S1099)));
    float _S1101 = _S1098 * (F32_sin((_S1099)));
    float _S1102 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1100 * _S1100 - _S1101 * _S1101))))));
    return make_float3 (_S1100, _S1102, _S1101);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_9, float n_i_dot_v_7, float alpha_16, BSDFMaterial material_17, BSDFLobes lobes_12, float eta_i_12, float eta_o_12, uint random_state_15)
{
    float3  _S1103 = make_float3 (1.0f);
    SampleBSDF _S1104 = SampleBSDF_x24init_0(_S1103, _S1103, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1104;
    Random _S1105 = pcg(random_state_15);
    Random _S1106 = pcg(_S1105.state);
    (&sample_2)->random_state = _S1106.state;
    float3  _S1107 = sampleCosWeightedHemisphere(_S1105.value, _S1106.value);
    bool _S1108 = u_3 < (lobes_12.p_diffuse * lobes_12.translucent_share);
    float _S1109 = _S1107.y;
    float _S1110 = - _S1109;
    float _S1111 = _slang_select(_S1108, _S1110,_S1109);
    float3  _S1112 = tangentToWorld(make_float3 (_S1107.x, _S1111, _S1107.z), n_i_9);
    (&sample_2)->unit_direction = _S1112;
    (&sample_2)->refracted = _S1108;
    (&sample_2)->lobe = 0U;
    float3  _S1113 = diffuseBSDF((&sample_2)->unit_direction, n_i_9, alpha_16, material_17, lobes_12);
    (&sample_2)->throughput = _S1113;
    float _S1114 = diffusePDF(_S1111, 0.0f, n_i_dot_v_7, alpha_16, lobes_12, eta_i_12, eta_o_12);
    (&sample_2)->pdf = _S1114;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_10, float n_i_dot_v_8, float alpha_17, BSDFMaterial material_18, BSDFLobes lobes_13, float eta_i_13, float eta_o_13, uint random_state_16)
{
    float3  _S1115 = make_float3 (1.0f);
    SampleBSDF _S1116 = SampleBSDF_x24init_0(_S1115, _S1115, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1116;
    Random _S1117 = pcg(random_state_16);
    Random _S1118 = pcg(_S1117.state);
    (&sample_3)->random_state = _S1118.state;
    float _S1119 = _S1117.value * lobes_13.toon_norm / 6.28318548202514648f;
    float t_21;
    if(lobes_13.toon_glossy)
    {
        t_21 = (F32_acos((clamp_1(1.0f - _S1119, -1.0f, 1.0f))));
    }
    else
    {
        t_21 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1119)))), (1.0f))))));
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
        float _S1120;
        if(t_21 < (lobes_13.toon_a))
        {
            _S1120 = 1.0f;
        }
        else
        {
            _S1120 = (F32_max((1.0f - (t_21 - lobes_13.toon_a) / (F32_max((lobes_13.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float integral_1;
        if(lobes_13.toon_glossy)
        {
            integral_1 = 1.0f - (F32_cos(((F32_min((t_21), (lobes_13.toon_a))))));
        }
        else
        {
            float _S1121 = (F32_sin(((F32_min((t_21), (lobes_13.toon_a))))));
            integral_1 = _S1121 * _S1121 / 2.0f;
        }
        bool _S1122 = t_21 > (lobes_13.toon_a);
        bool _S1123;
        if(_S1122)
        {
            _S1123 = (lobes_13.toon_s) > 0.0f;
        }
        else
        {
            _S1123 = false;
        }
        float integral_2;
        if(_S1123)
        {
            if(lobes_13.toon_glossy)
            {
                float _S1124 = (F32_cos((lobes_13.toon_a)));
                float _S1125 = (F32_cos((t_21)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1124 - _S1125) - ((F32_sin((t_21))) - t_21 * _S1125 - ((F32_sin((lobes_13.toon_a))) - lobes_13.toon_a * _S1124)) / lobes_13.toon_s;
            }
            else
            {
                float _S1126 = 2.0f * lobes_13.toon_a;
                float _S1127 = (F32_cos((_S1126)));
                float _S1128 = 2.0f * t_21;
                float _S1129 = (F32_cos((_S1128)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1127 - _S1129) / 4.0f - ((F32_sin((_S1128))) / 8.0f - t_21 * _S1129 / 4.0f - ((F32_sin((_S1126))) / 8.0f - lobes_13.toon_a * _S1127 / 4.0f)) / lobes_13.toon_s;
            }
            float integral_3 = integral_1 + integral_2;
            integral_2 = integral_3;
        }
        else
        {
            integral_2 = integral_1;
        }
        float _S1130 = _S1120 * (F32_sin((t_21)));
        float _S1131;
        if(lobes_13.toon_glossy)
        {
            _S1131 = 1.0f;
        }
        else
        {
            _S1131 = (F32_cos((t_21)));
        }
        float _S1132 = _S1130 * _S1131;
        float _S1133 = (integral_2 - _S1119) / _S1132;
        bool _S1134 = _S1132 > 0.0f;
        float _S1135 = _slang_select(_S1134, _S1133,0.0f);
        float _S1136 = clamp_1(t_21 - _S1135, 0.0f, lobes_13.toon_b);
        int k_1 = k_0 + int(1);
        t_21 = _S1136;
        k_0 = k_1;
    }
    float _S1137 = 6.28318548202514648f * _S1118.value;
    float _S1138 = (F32_sin((t_21)));
    float3  _S1139 = tangentToWorld(make_float3 (_S1138 * (F32_cos((_S1137))), (F32_cos((t_21))), _S1138 * (F32_sin((_S1137)))), lobes_13.toon_axis);
    (&sample_3)->unit_direction = _S1139;
    bool _S1140 = (dot_0(n_i_10, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1140;
    (&sample_3)->lobe = 6U;
    float3  _S1141 = toonBSDF((&sample_3)->unit_direction, n_i_10, alpha_17, material_18, lobes_13);
    (&sample_3)->throughput = _S1141;
    float _S1142 = toonPDF(dot_0(n_i_10, (&sample_3)->unit_direction), dot_0((&sample_3)->unit_direction, lobes_13.toon_axis), n_i_dot_v_8, alpha_17, lobes_13, eta_i_13, eta_o_13);
    (&sample_3)->pdf = _S1142;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_11, float n_i_dot_v_9, float alpha_18, BSDFMaterial material_19, BSDFLobes lobes_14, float eta_i_14, float eta_o_14, uint random_state_17)
{
    float3  _S1143 = make_float3 (1.0f);
    SampleBSDF _S1144 = SampleBSDF_x24init_0(_S1143, _S1143, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1144;
    (&sample_4)->unit_direction = lobes_14.refracted;
    (&sample_4)->random_state = random_state_17;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1145 = refractBSDF((&sample_4)->unit_direction, n_i_11, alpha_18, material_19, lobes_14);
    (&sample_4)->throughput = _S1145;
    float _S1146 = refractPDF(0.0f, dot_0((&sample_4)->unit_direction, ggx_n_3), n_i_dot_v_9, alpha_18, lobes_14, eta_i_14, eta_o_14);
    (&sample_4)->pdf = _S1146;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_25, float3  n_10)
{
    return i_25 - make_float3 (2.0f * dot_0(n_10, i_25)) * n_10;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_12, float n_i_dot_v_10, float alpha_19, BSDFMaterial material_20, BSDFLobes lobes_15, float eta_i_15, float eta_o_15, uint random_state_18)
{
    float3  _S1147 = make_float3 (1.0f);
    SampleBSDF _S1148 = SampleBSDF_x24init_0(_S1147, _S1147, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1148;
    float3  _S1149 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S1150 = ((((_S1149)) * make_float3(rnorm3df(((_S1149)).x, ((_S1149)).y, ((_S1149)).z))));
    (&sample_5)->unit_direction = _S1150;
    (&sample_5)->random_state = random_state_18;
    (&sample_5)->lobe = 2U;
    float3  _S1151 = reflectBSDF((&sample_5)->unit_direction, n_i_12, alpha_19, material_20, lobes_15);
    (&sample_5)->throughput = _S1151;
    float _S1152 = reflectPDF(0.0f, 0.0f, n_i_dot_v_10, alpha_19, lobes_15, eta_i_15, eta_o_15);
    (&sample_5)->pdf = _S1152;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_11, BSDFMaterial material_21, float eta_i_16, float eta_o_16, uint random_init_0, float2  screen_space_0)
{
    uint random_state_19 = random_init_0;
    float3  _S1153 = negate_0(in_dir_10);
    float _S1154 = dot_0(n_11, _S1153);
    float _S1155 = sign_0(_S1154);
    float3  n_i_13 = n_11 * make_float3 (_S1155);
    float _S1156 = (F32_abs((_S1154)));
    float _S1157 = material_21.roughness;
    float _S1158 = _S1157 * _S1157;
    AnisotropicFrame _S1159 = anisotropicFrame(material_21, n_i_13);
    float3  _S1160 = sampleHalfVector(_S1153, n_i_13, _S1158, _S1159, &random_state_19);
    BSDFLobes _S1161 = bsdfLobes(in_dir_10, _S1153, n_i_13, _S1160, material_21, eta_i_16, eta_o_16, _S1159);
    BSDFLobes lobes_16 = _S1161;
    float _S1162 = translucentShare(material_21);
    (&lobes_16)->translucent_share = _S1162;
    Random _S1163 = pcg(random_state_19);
    random_state_19 = _S1163.state;
    bool _S1164 = (_S1163.value) < ((&lobes_16)->p_sheen_velvet);
    if(_S1164)
    {
        SampleBSDF _S1165 = sheenVelvetSample(n_i_13, _S1156, _S1158, material_21, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1165;
    }
    float _S1166 = _S1163.value - (&lobes_16)->p_sheen_velvet;
    bool _S1167 = _S1166 < ((&lobes_16)->p_diffuse);
    if(_S1167)
    {
        SampleBSDF _S1168 = diffuseSample(_S1166, n_i_13, _S1156, _S1158, material_21, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1168;
    }
    bool _S1169 = _S1166 < ((&lobes_16)->p_diffuse + (&lobes_16)->p_toon);
    if(_S1169)
    {
        SampleBSDF _S1170 = toonSample(n_i_13, _S1156, _S1158, material_21, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1170;
    }
    float _S1171 = (&lobes_16)->p_toon;
    bool _S1172 = (_S1166 - _S1171) < ((&lobes_16)->p_diffuse + (&lobes_16)->p_refract);
    if(_S1172)
    {
        SampleBSDF _S1173 = refractSample(_S1160, n_i_13, _S1156, _S1158, material_21, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1173;
    }
    SampleBSDF _S1174 = reflectSample(in_dir_10, _S1160, n_i_13, _S1156, _S1158, material_21, lobes_16, eta_i_16, eta_o_16, random_state_19);
    return _S1174;
}

__device__ bool withinInverseFootprint(float pdf_7, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1175 = pdf_7 > 0.0f;
    bool _S1176;
    if(_S1175)
    {
        if(diffuse_0)
        {
            _S1176 = true;
        }
        else
        {
            _S1176 = (pdf_7 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1176 = false;
    }
    return _S1176;
}

__device__ bool roughLobe(float pdf_8, bool diffuse_1, float roughness_1)
{
    bool _S1177 = pdf_8 > 0.0f;
    bool _S1178;
    if(_S1177)
    {
        if(diffuse_1)
        {
            _S1178 = true;
        }
        else
        {
            _S1178 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1178 = false;
    }
    return _S1178;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1179 = layers_0 > 1U;
    bool _S1180;
    if(_S1179)
    {
        _S1180 = refracting_0 != passed_0;
    }
    else
    {
        _S1180 = false;
    }
    return _S1180;
}

static __device__ float widened_0(float spread_1, float pdf_9, bool delta_0)
{
    float _S1181 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_9))))), (3.14159274101257324f)));
    bool _S1182 = !delta_0;
    float _S1183 = _slang_select(_S1182, _S1181,0.0f);
    return spread_1 + _S1183;
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
    bool _S1184;
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
    int _S1185;
    Shift ended_0;
    float density_3;
    float spread_3;
    float width_4;
    float sky_pdf_1;
    float spread_4;
    float width_5;
    uint b_9;
    float3  _S1186 = make_float3 (0.0f);
    Shift _S1187 = Shift_x24init_0(_S1186, 0.0f);
    uint _S1188 = r_8->path;
    uint _S1189 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1190 = extractBits_0(_S1188, 5U, 5U);
    uint _S1191 = extractBits_0(_S1188, 10U, 2U);
    uint _S1192 = extractBits_0(_S1188, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1193 = _S1192 >= 3U;
        uint _S1194 = _slang_select(_S1193, 1U,0U);
        uint _S1195 = _S1189 + _S1194;
        uint _S1196 = (fcptMaxBounces());
        passes_0 = _S1195 > _S1196;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1187;
    }
    uint _S1197 = _S1190 - 1U;
    bool _S1198 = _S1192 == 3U;
    uint _S1199 = _slang_select(_S1198, 1U,0U);
    uint _S1200 = _S1189 + _S1199;
    bool _S1201 = _S1191 == 0U;
    uint _S1202 = _slang_select(_S1201, _S1200,_S1197);
    FKHit _S1203 = (fcptReservoirHit((*r_8)));
    float3  _S1204 = dom_7->x0;
    float3  _S1205 = dom_7->x1 - dom_7->x0;
    float3  _S1206 = ((((_S1205)) * make_float3(rnorm3df(((_S1205)).x, ((_S1205)).y, ((_S1205)).z))));
    FKRay _S1207 = Ray_x24init_0(dom_7->x1, _S1206);
    FKRay ray_2 = _S1207;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1186;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1186;
    float3  extinction_in_0 = _S1186;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1208 = dom_7->spread;
    float _S1209 = dom_7->width;
    float _S1210 = length_0(_S1205);
    NEEVertex _S1211 = NEEVertex_x24init_0(true, 0.0f, _S1186, _S1186, _S1186);
    NEEVertex nee_vertex_0 = _S1211;
    Vertex _S1212 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1212;
    Reservoir _S1213 = (Reservoir{});
    Reservoir chain_0 = _S1213;
    uint _S1214 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1204;
    (&hit_4)->distance = _S1210;
    FKMedium _S1215 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1216 = filling_2;
    bool _S1217 = (fcptVaryingUsed());
    uint _S1218 = _slang_select(_S1217, _S1216,4294967295U);
    filling_2 = _S1218;
    scatter_in_0 = _S1215.scatter;
    extinction_in_0 = _S1215.extinction;
    g_in_0 = _S1215.g;
    Reservoir _S1219 = chain_0;
    uint _S1220 = filling_2;
    for(;;)
    {
        bool _S1221 = (fcptVaryingUsed());
        if(_S1221)
        {
            passes_0 = _S1220 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1222 = (fcptMajorant((_S1220)));
            spread_2 = _S1222;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1202;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1191 == 1U;
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
            ended_0 = _S1187;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1208;
            width_3 = _S1209;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_8 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1223 = (&prev_0)->rough;
        if(_S1223)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1224 = stream(_S1214, 384U);
        uint tracking_0 = _S1224;
        weight_1 = throughput_3;
        glowed_0 = _S1186;
        b_8 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_2 = _S1208;
        width_3 = _S1209;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1185 = int(1);
                break;
            }
            uint _S1225 = b_8 + 320U;
            bool _S1226 = b_8 == 4294967295U;
            uint _S1227 = _slang_select(_S1226, 384U,_S1225);
            uint _S1228 = stream(_S1214, _S1227);
            Random _S1229 = pcg(_S1228);
            float _S1230 = freeFlight_0(_S1229.value, spread_2);
            if(passes_0)
            {
                float3  _S1231 = (&ray_2)->origin;
                float3  _S1232 = (&ray_2)->unit_direction;
                float _S1233 = (&hit_4)->distance;
                uint _S1234 = _slang_select(_S1226, 0U,b_8);
                uint _S1235 = (&prev_0)->lobe;
                uint _S1236 = _slang_select(_S1226, 3U,_S1235);
                float _S1237 = (fcptTrackMedium((_S1220), (_S1231), (_S1232), (_S1233), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1234), (_S1236), (_S1226)));
                geometry_density_2 = _S1237;
            }
            else
            {
                geometry_density_2 = _S1230;
            }
            bool _S1238 = !(geometry_density_2 < ((&hit_4)->distance));
            if(_S1238)
            {
                _S1185 = int(1);
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
                float3  _S1239 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1240 = sel_7->glow + _S1239;
                sel_7->glow = _S1240;
            }
            else
            {
            }
            glowed_0 = _S1186;
            uint b_10 = b_8 + 1U;
            float3  _S1241 = (&ray_2)->origin + make_float3 (geometry_density_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1241;
            float3  _S1242 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, geometry_density_2, true);
            float3  _S1243 = weight_1;
            float3  _S1244 = _slang_select(passes_0, _S1243,_S1242);
            float3  throughput_4 = throughput_2 * _S1244;
            uint _S1245 = stream(_S1214, b_10 + 320U);
            tracking_0 = _S1245;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_2 * geometry_density_2;
            float _S1246 = threshold_2 + 3.14159274101257324f;
            bool _S1247 = scatterSampled_0(replay_2, b_10, _S1202, passes_0);
            TreeSample _S1248 = TreeSample_x24init_0(_S1186, _S1186, 0.0f, 0U);
            if(_S1247)
            {
                float3  _S1249 = (&ray_2)->origin;
                float3  _S1250 = (&ray_2)->unit_direction;
                float3  _S1251 = (&ray_2)->unit_direction;
                uint _S1252 = stream(_S1214, b_10 + 64U);
                float3  _S1253 = extinction_in_0;
                float3  _S1254 = extinction_in_0;
                uint2  _S1255 = make_uint2 (_S1220);
                float3  _S1256 = (&ray_2)->unit_direction;
                uint _S1257 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                FKHit _S1258 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1259 = _S1258;
                ShadowContext _S1260 = ShadowContext_x24init_0(_S1253, _S1254, _S1255, _S1256, b_10, _S1257, false, geometry_density_2, width_6, &_S1259, false);
                ShadowContext _S1261 = _S1260;
                TreeSample _S1262 = sampleLightTree_0(_S1249, _S1250, _S1251, 0.0f, true, _S1252, &_S1261);
                light_3 = _S1262;
            }
            else
            {
                light_3 = _S1248;
            }
            float _S1263 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1264 = (fcptMaxBounces());
            bool _S1265 = b_10 < _S1264;
            if(_S1265)
            {
                is_inside_6 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_6 = false;
            }
            float _S1266 = _slang_select(is_inside_6, _S1263,0.0f);
            float3  _S1267 = throughput_4 * light_3.radiance;
            float _S1268 = powerHeuristic(light_3.density, _S1266);
            float3  _S1269 = _S1267 * make_float3 (_S1263 * _S1268);
            float3  _S1270 = _slang_select(_S1247, _S1269,_S1186);
            if(replay_2)
            {
                viewed_0 = b_10 == _S1202;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1271 = _S1191 == 2U;
                if(_S1271)
                {
                    float _S1272 = rgb_to_greyscale(_S1270);
                    passes_0 = _S1272 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1273 = Shift_x24init_0(_S1270, 1.0f);
                    _S1185 = int(0);
                    ended_0 = _S1273;
                    spread_2 = _S1246;
                    geometry_density_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_10;
                    break;
                }
                _S1185 = int(0);
                ended_0 = _S1187;
                spread_2 = _S1246;
                geometry_density_2 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_10;
                break;
            }
            bool _S1274 = !replay_2;
            if(_S1274)
            {
                Reservoir candidate_3 = _S1219;
                uint _S1275 = extractBits_0(_S1219.path, 10U, 2U);
                bool _S1276 = _S1275 == 1U;
                if(_S1276)
                {
                    float3  _S1277 = safeDivide(_S1270, _S1186);
                    (&candidate_3)->radiance = _S1277;
                }
                else
                {
                    uint _S1278 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                    uint _S1279 = insertBits_0(_S1278, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1279;
                }
                Reservoir _S1280 = withEnd(candidate_3, 0U, b_10, _S1270);
                offer(sel_7, _S1280, _S1270 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1281 = survivalProbability(throughput_4, density_2);
                uint _S1282 = stream(_S1214, b_10 + 128U);
                Random _S1283 = pcg(_S1282);
                bool _S1284 = _S1281 < (_S1283.value);
                if(_S1284)
                {
                    _S1184 = true;
                }
                else
                {
                    uint _S1285 = (fcptMaxBounces());
                    _S1184 = b_10 >= _S1285;
                }
                if(_S1184)
                {
                    _S1185 = int(0);
                    ended_0 = _S1187;
                    spread_2 = _S1246;
                    geometry_density_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_10;
                    break;
                }
                float _S1286 = density_2 * _S1281;
                density_2 = _S1286;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1287 = stream(_S1214, b_10);
            float3  _S1288 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1287, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1288;
            NEEVertex _S1289 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1186, (&ray_2)->origin);
            nee_vertex_0 = _S1289;
            Vertex _S1290 = scatteredVertex_0(false);
            prev_0 = _S1290;
            float _S1291 = (&prev_0)->pdf;
            FKRay _S1292 = ray_2;
            FKHit _S1293 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1294 = (fcptTraverseInstanceBVH((_S1292), (true), (4.294967296e+09f), (false), (_S1293), (false)));
            hit_4 = _S1294;
            b_8 = b_10;
            throughput_2 = throughput_4;
            threshold_2 = _S1246;
            width_3 = width_6;
            sky_pdf_0 = _S1291;
        }
        if(_S1185 != int(1))
        {
            width_3 = geometry_density_2;
            throughput_2 = chain_throughput_0;
            b_8 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1187;
        spread_2 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1295 = b_8 == 4294967295U;
    bool _S1296 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1296)
    {
        bool _S1297 = !(&nee_vertex_0)->none;
        float _S1298 = _slang_select(_S1297, sky_pdf_0,0.0f);
        float _S1299 = escapeWeight_0(_S1298, (&ray_2)->unit_direction);
        float3  _S1300 = environment_0((&ray_2)->unit_direction, b_8, (&prev_0)->lobe);
        float3  _S1301 = throughput_2 * _S1300;
        if(replay_2)
        {
            bool _S1302 = b_8 == _S1202;
            if(_S1302)
            {
                passes_0 = _S1191 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1301 * make_float3 (_S1299) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1201)
            {
                passes_0 = _S1198;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_8 == _S1189;
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
                return Shift_x24init_0(_S1301 * make_float3 (_S1299), 1.0f);
            }
            return _S1187;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1303 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1304 = _S1303 == 1U;
        if(_S1304)
        {
            uint _S1305 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1306 = _S1305 == b_8;
            float _S1307 = _slang_select(_S1306, 1.0f,_S1299);
            float3  _S1308 = safeDivide(_S1301 * make_float3 (_S1307), _S1186);
            (&candidate_4)->radiance = _S1308;
        }
        else
        {
            bool _S1309 = (&prev_0)->rough;
            if(_S1309)
            {
                uint _S1310 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                uint _S1311 = insertBits_0(_S1310, 3U, 10U, 2U);
                uint _S1312 = insertBits_0(_S1311, (&prev_0)->lobe, 15U, 3U);
                bool _S1313 = (&prev_0)->inside;
                uint _S1314 = _slang_select(_S1313, 1U,0U);
                uint _S1315 = insertBits_0(_S1312, _S1314, 22U, 1U);
                (&candidate_4)->path = _S1315;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1316 = _S1301 * make_float3 (_S1299);
        Reservoir _S1317 = withEnd(candidate_4, 3U, b_8, _S1316);
        offer(sel_7, _S1317, _S1316 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1187;
    }
    float3  _S1318 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1318;
    bool _S1319 = (fcptVaryingUsed());
    if(_S1319)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1320 = !replay_2;
        if(_S1320)
        {
            float3  _S1321 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1322 = sel_7->glow + _S1321;
            sel_7->glow = _S1322;
        }
        float3  _S1323 = throughput_2 * weight_1;
        throughput_2 = _S1323;
    }
    else
    {
        float3  _S1324 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1325 = throughput_2 * _S1324;
        throughput_2 = _S1325;
    }
    float _S1326 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1327 = b_8 + 1U;
    b_8 = _S1327;
    layer_0 = 0U;
    width_3 = _S1326;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_6 = false;
    chain_throughput_0 = _S1186;
    float3  reconnection_0 = _S1186;
    viewed_0 = _S1295;
    for(;;)
    {
        bool _S1328 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1184 = _S1191 == 1U;
        }
        else
        {
            _S1184 = false;
        }
        bool _S1329;
        if(_S1184)
        {
            _S1329 = b_8 == _S1190;
        }
        else
        {
            _S1329 = false;
        }
        bool _S1330;
        if(_S1329)
        {
            bool _S1331 = ((&hit_4)->instance_index) != (_S1203.instance_index);
            if(_S1331)
            {
                _S1330 = true;
            }
            else
            {
                _S1330 = ((&hit_4)->triangle_index) != (_S1203.triangle_index);
            }
        }
        else
        {
            _S1330 = false;
        }
        if(_S1330)
        {
            return _S1187;
        }
        FKMedium _S1332 = Medium_x24init_0(_S1186, _S1186, 0.0f);
        BSDFMaterial _S1333 = Material_x24init_0(_S1186, _S1186, 0.0f, 0.0f, 0.0f, 0.0f, _S1186, throughput_3, 1.0f, _S1186, _S1186, 0.5f, 0.0f, 0.0f, _S1186, 0.0f, _S1186);
        FKMedium _S1334 = _S1332;
        FKSurface _S1335 = Surface_x24init_0(_S1186, _S1186, 0.0f, &_S1333, false, 0U, 1.0f, false, &_S1334, 4294967295U, _S1186);
        bool _S1336 = !_S1328;
        bool scatter_2;
        bool is_inside_7;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S1336)
        {
            uint _S1337 = stream(_S1214, b_8);
            uint _S1338 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKSurface _S1339 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1337), (width_3), (layer_0), (b_8), (_S1338), ((&ray_2)->unit_direction)));
            bool _S1340 = !passes_0;
            FKSurface _S1341 = _S1339;
            FKSurface _S1342 = emitting_0(&_S1341, _S1340);
            uint _S1343 = stream(_S1214, b_8 + 256U);
            Random _S1344 = pcg(_S1343);
            FKSurface _S1345 = _S1342;
            FKSurface _S1346 = uncovered_0(&_S1345, _S1344.value);
            float _S1347 = facingSign(_S1346.material.transmission, _S1346.geometry_n, (&ray_2)->unit_direction);
            bool _S1348 = _S1347 < 0.0f;
            bool _S1349 = (_S1346.material.transmission) > 0.0f;
            if(_S1349)
            {
                bool _S1350 = arrivesBehind_0((&ray_2)->unit_direction, _S1346.geometry_n);
                scatter_2 = _S1350;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1351 = _S1346;
            FKSurface _S1352 = facingRay_0(&_S1351, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1353 = arrivesBehind_0((&ray_2)->unit_direction, _S1352.geometry_n);
                is_inside_7 = _S1353;
            }
            else
            {
                is_inside_7 = scatter_2;
            }
            if(is_inside_7)
            {
                float3  _S1354 = beerLambert((&hit_4)->distance, _S1352.material.absorption);
                float3  _S1355 = throughput_2 * _S1354;
                throughput_5 = _S1355;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1356 = !_S1352.skip;
            float geometry_density_3 = geometryDensity(_S1352.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1357 = b_8 == _S1327;
            if(_S1357)
            {
                float _S1358 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1358;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1359 = geometry_density_2;
            scatter_2 = _S1356;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1359;
            surface_12 = _S1352;
            turned_1 = _S1348;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_12 = _S1335;
            throughput_5 = throughput_2;
            is_inside_7 = is_inside_6;
        }
        bool _S1360 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1361 = surface_12;
        FKSurface _S1362 = surface_12;
        float _S1363 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        float2  _S1364 = vertexEta(_S1361.material, _S1363);
        bool _S1365;
        if(scatter_2)
        {
            bool _S1366 = neeDecision(_S1361.material, _S1363, _S1364.x, _S1364.y);
            _S1365 = _S1366;
        }
        else
        {
            _S1365 = false;
        }
        bool _S1367;
        if(passes_0)
        {
            _S1367 = true;
        }
        else
        {
            _S1367 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1367)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1365;
        }
        bool _S1368 = (fcptHairUsed());
        bool _S1369;
        if(_S1368)
        {
            float3  _S1370 = surface_12.hair;
            _S1369 = (dot_0(_S1370, _S1370)) > 0.0f;
        }
        else
        {
            _S1369 = false;
        }
        bool _S1371;
        if(_S1369)
        {
            _S1371 = true;
        }
        else
        {
            BSDFMaterial _S1372 = _S1361.material;
            bool _S1373 = isTranslucent_0(&_S1372);
            _S1371 = _S1373;
        }
        bool _S1374;
        if(_S1371)
        {
            _S1374 = true;
        }
        else
        {
            bool _S1375 = (_S1361.material.transmission) > 0.0f;
            if(_S1375)
            {
                uint _S1376 = (fcptLayers((hit_4)));
                _S1374 = _S1376 == 1U;
            }
            else
            {
                _S1374 = false;
            }
        }
        float3  emission_0;
        if(_S1328)
        {
            float3  _S1377 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1377;
        }
        else
        {
            emission_0 = _S1361.material.emissive;
        }
        bool _S1378 = !replay_2;
        bool _S1379;
        if(_S1378)
        {
            _S1379 = true;
        }
        else
        {
            _S1379 = b_8 >= _S1202;
        }
        bool _S1380;
        if(_S1379)
        {
            float _S1381 = rgb_to_greyscale(emission_0);
            _S1380 = _S1381 > 0.0f;
        }
        else
        {
            _S1380 = false;
        }
        float3  emission_1;
        if(_S1380)
        {
            NEEVertex _S1382 = nee_vertex_0;
            FKHit _S1383 = hit_4;
            float _S1384 = emissionWeight_0(&_S1382, &_S1383, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1384);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1385;
        if(replay_2)
        {
            _S1385 = _S1191 == 1U;
        }
        else
        {
            _S1385 = false;
        }
        bool _S1386;
        if(_S1385)
        {
            _S1386 = b_8 > _S1190;
        }
        else
        {
            _S1386 = false;
        }
        bool _S1387;
        if(_S1386)
        {
            _S1387 = b_8 == _S1189;
        }
        else
        {
            _S1387 = false;
        }
        bool _S1388;
        if(_S1387)
        {
            bool _S1389 = _S1192 == 1U;
            if(_S1389)
            {
                _S1388 = true;
            }
            else
            {
                _S1388 = _S1192 == 2U;
            }
        }
        else
        {
            _S1388 = false;
        }
        if(_S1388)
        {
            bool _S1390 = _S1328 != (_S1192 == 2U);
            if(_S1390)
            {
                return _S1187;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1391 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1392 = _S1391 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1393 = insertBits_0(0U, b_8, 5U, 5U);
        uint _S1394 = insertBits_0(_S1393, 1U, 10U, 2U);
        uint _S1395 = insertBits_0(_S1394, (&prev_0)->lobe, 15U, 3U);
        bool _S1396 = (&prev_0)->inside;
        uint _S1397 = _slang_select(_S1396, 1U,0U);
        uint _S1398 = insertBits_0(_S1395, _S1397, 22U, 1U);
        (&here_0)->path = _S1398;
        float _S1399 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1399;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1400;
        if(replay_2)
        {
            _S1400 = _S1191 == 1U;
        }
        else
        {
            _S1400 = false;
        }
        bool _S1401;
        if(_S1400)
        {
            _S1401 = b_8 == _S1190;
        }
        else
        {
            _S1401 = false;
        }
        bool _S1402 = b_8 == _S1202;
        bool _S1403;
        if(_S1402)
        {
            bool _S1404 = !scatter_2;
            if(_S1404)
            {
                _S1403 = true;
            }
            else
            {
                bool _S1405 = _S1191 != 1U;
                if(_S1405)
                {
                    _S1403 = _S1191 != 3U;
                }
                else
                {
                    _S1403 = false;
                }
            }
        }
        else
        {
            _S1403 = false;
        }
        bool _S1406;
        if(_S1403)
        {
            _S1406 = _S1191 == 2U;
        }
        else
        {
            _S1406 = false;
        }
        bool _S1407;
        if(_S1406)
        {
            _S1407 = !_S1360;
        }
        else
        {
            _S1407 = false;
        }
        bool _S1408;
        if(_S1407)
        {
            _S1408 = _S1192 != 4U;
        }
        else
        {
            _S1408 = false;
        }
        bool _S1409 = _S1190 == _S1189;
        bool _S1410;
        if(_S1409)
        {
            _S1410 = _S1192 == 0U;
        }
        else
        {
            _S1410 = false;
        }
        bool _S1411;
        if(_S1410)
        {
            _S1411 = ((&hit_4)->instance_index) == (_S1203.instance_index);
        }
        else
        {
            _S1411 = false;
        }
        bool _S1412;
        if(_S1411)
        {
            _S1412 = ((&hit_4)->triangle_index) == (_S1203.triangle_index);
        }
        else
        {
            _S1412 = false;
        }
        bool _S1413;
        if(_S1412)
        {
            _S1413 = _S1360;
        }
        else
        {
            _S1413 = false;
        }
        bool _S1414 = _slang_select(_S1401, _S1413,_S1408);
        bool _S1415;
        if(nee_0)
        {
            _S1415 = _slang_select(replay_2, _S1414,scatter_2);
        }
        else
        {
            _S1415 = false;
        }
        TreeSample _S1416 = TreeSample_x24init_0(_S1186, _S1186, 0.0f, 0U);
        uint2  _S1417 = make_uint2 (0U);
        float2  _S1418 = make_float2 (0.0f);
        FKHit _S1419 = Hit_x24init_0(_S1418, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1420 = _S1419;
        ShadowContext _S1421 = ShadowContext_x24init_0(_S1186, _S1186, _S1417, _S1186, 0U, 0U, false, 0.0f, 0.0f, &_S1420, false);
        bool _S1422;
        if(nee_0)
        {
            _S1422 = _S1379;
        }
        else
        {
            _S1422 = false;
        }
        ShadowContext context_5;
        if(_S1422)
        {
            uint _S1423 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKMedium _S1424 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1425 = surface_12;
            FKHit _S1426 = hit_4;
            FKMedium _S1427 = _S1424;
            ShadowContext _S1428 = shadowContext_0(&_S1425, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_8, _S1423, (&hit_4)->distance, width_3, &_S1426, _S1369, &_S1427);
            context_5 = _S1428;
        }
        else
        {
            context_5 = _S1421;
        }
        float3  throughput_6;
        float3  lit_0;
        if(_S1415)
        {
            float3  _S1429 = (&ray_2)->origin;
            if(_S1369)
            {
                throughput_6 = _S1186;
            }
            else
            {
                throughput_6 = _S1362.smooth_n;
            }
            FKSurface _S1430 = surface_12;
            uint _S1431 = stream(_S1214, b_8 + 64U);
            ShadowContext _S1432 = context_5;
            TreeSample _S1433 = sampleLightTree_0(_S1429, throughput_6, surface_12.geometry_n, surface_12.geometry_offset, _S1374, _S1431, &_S1432);
            bool _S1434 = any_1((_S1433.radiance) != _S1186);
            if(_S1434)
            {
                if(_S1369)
                {
                    uint _S1435 = (fcptMaxBounces());
                    bool _S1436 = b_8 < _S1435;
                    FKSurface _S1437 = surface_12;
                    TreeSample _S1438 = _S1433;
                    float3  _S1439 = hairLight_0(&_S1437, (&ray_2)->unit_direction, &_S1438, _S1436);
                    lit_0 = _S1439;
                }
                else
                {
                    float _S1440 = _S1364.x;
                    float _S1441 = _S1364.y;
                    uint _S1442 = (fcptMaxBounces());
                    bool _S1443 = b_8 < _S1442;
                    TreeSample _S1444 = _S1433;
                    BSDFMaterial _S1445 = _S1361.material;
                    float3  _S1446 = lightBSDF_0((&ray_2)->unit_direction, &_S1444, _S1362.smooth_n, _S1430.geometry_n, &_S1445, _S1440, _S1441, _S1443, surface_12.random_state);
                    lit_0 = _S1446;
                }
            }
            else
            {
                lit_0 = _S1186;
            }
            light_3 = _S1433;
        }
        else
        {
            light_3 = _S1416;
            lit_0 = _S1186;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1447;
        bool _S1448;
        float density_4;
        if(_S1401)
        {
            bool _S1449 = !_S1360;
            if(_S1449)
            {
                return _S1187;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1409)
            {
                viewed_1 = _S1192 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1409)
            {
                refracted_4 = _S1192 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1450 = !nee_0;
                if(_S1450)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1451 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1451 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1187;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1409)
            {
                wrong_side_0 = _S1192 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1452 = !nee_0;
                if(_S1452)
                {
                    return _S1187;
                }
                float _S1453 = environmentPdf_0(r_8->dir);
                float3  _S1454 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_12, _S1364, is_inside_7, _S1453, surface_12.random_state);
                return Shift_x24init_0(throughput_7 * _S1454 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1455 = extractBits_0(_S1188, 21U, 1U);
            bool _S1456 = nee_0 != (_S1455 == 1U);
            if(_S1456)
            {
                return _S1187;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1402;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1457 = !scatter_2;
                if(_S1457)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1458 = _S1191 != 1U;
                    if(_S1458)
                    {
                        refracted_4 = _S1191 != 3U;
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
                bool _S1459 = _S1191 == 2U;
                if(_S1459)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1360;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1192 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1369)
                    {
                        return _S1187;
                    }
                    uint _S1460 = stream(_S1214, b_8 + 448U);
                    FKRay _S1461 = ray_2;
                    FKSurface _S1462 = surface_12;
                    ShadowContext _S1463 = context_5;
                    SkySample _S1464 = sampleSky_0(&_S1461, &_S1462, _S1364, is_inside_7, _S1460, surface_12.random_state, &_S1463);
                    return Shift_x24init_0(throughput_5 * _S1464.color, 1.0f);
                }
                if(_S1459)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1360;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1465 = rgb_to_greyscale(light_3.radiance);
                    bool _S1466 = !(_S1465 > 0.0f);
                    if(_S1466)
                    {
                        return _S1187;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S1201)
                {
                    passes_0 = _S1192 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1328;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S1201)
                {
                    passes_0 = _S1192 == 1U;
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
                    passes_0 = !_S1360;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S1187;
            }
            else
            {
                if(_S1378)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1467 = b_8 > 0U;
                    if(_S1467)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1392)
                        {
                            float3  _S1468 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1468;
                        }
                        else
                        {
                            if(_S1360)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1469 = throughput_5 * emission_1;
                        Reservoir _S1470 = withEnd(candidate_5, 1U, b_8, _S1469);
                        offer(sel_7, _S1470, _S1469 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1471 = throughput_5 * emission_1;
                        float3  _S1472 = sel_7->glow + _S1471;
                        sel_7->glow = _S1472;
                    }
                    if(nee_0)
                    {
                        float3  _S1473 = throughput_5 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1392)
                        {
                            float3  _S1474 = safeDivide(_S1473, chain_throughput_0);
                            (&candidate_6)->radiance = _S1474;
                        }
                        else
                        {
                            if(_S1360)
                            {
                                candidate_6 = here_0;
                                uint _S1475 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1475;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1476 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                                uint _S1477 = insertBits_0(_S1476, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1477;
                            }
                        }
                        Reservoir _S1478 = withEnd(candidate_6, 0U, b_8, _S1473);
                        offer(sel_7, _S1478, _S1473 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1369)
                        {
                            _S1447 = false;
                        }
                        else
                        {
                            bool _S1479 = environmentMapped_0();
                            _S1447 = _S1479;
                        }
                    }
                    else
                    {
                        _S1447 = false;
                    }
                    if(_S1447)
                    {
                        uint _S1480 = (fcptMaxBounces());
                        _S1448 = b_8 < _S1480;
                    }
                    else
                    {
                        _S1448 = false;
                    }
                    if(_S1448)
                    {
                        uint _S1481 = stream(_S1214, b_8 + 448U);
                        FKRay _S1482 = ray_2;
                        FKSurface _S1483 = surface_12;
                        ShadowContext _S1484 = context_5;
                        SkySample _S1485 = sampleSky_0(&_S1482, &_S1483, _S1364, is_inside_7, _S1481, surface_12.random_state, &_S1484);
                        float3  _S1486 = throughput_5 * _S1485.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1392)
                        {
                            float3  _S1487 = safeDivide(_S1486, chain_throughput_0);
                            (&candidate_7)->radiance = _S1487;
                        }
                        else
                        {
                            if(_S1360)
                            {
                                candidate_7 = here_0;
                                uint _S1488 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1488;
                                (&candidate_7)->dir = _S1485.dir;
                                (&candidate_7)->radiance = _S1485.radiance;
                            }
                            else
                            {
                                uint _S1489 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                                uint _S1490 = insertBits_0(_S1489, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1490;
                            }
                        }
                        Reservoir _S1491 = withEnd(candidate_7, 4U, b_8, _S1486);
                        offer(sel_7, _S1491, _S1486 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1492;
        bool _S1493;
        bool _S1494;
        bool straight_0;
        bool _S1495;
        bool _S1496;
        bool _S1497;
        bool _S1498;
        bool _S1499;
        bool _S1500;
        bool _S1501;
        bool _S1502;
        bool _S1503;
        bool _S1504;
        bool _S1505;
        bool _S1506;
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
                viewed_1 = _S1402;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1507 = extractBits_0(_S1188, 15U, 3U);
            uint _S1508 = extractBits_0(_S1188, 18U, 3U);
            uint _S1509 = _slang_select(_S1401, _S1508,_S1507);
            float3  _S1510 = r_8->dir;
            bool refracted_5 = _S1509 == 1U;
            SampleBSDF _S1511 = SampleBSDF_x24init_0(_S1186, _S1186, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1511;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1512 = extractBits_0(_S1188, 22U, 1U);
                bool _S1513 = is_inside_7 != (_S1512 == 1U);
                if(_S1513)
                {
                    return _S1187;
                }
                bool _S1514 = _S1191 == 1U;
                if(_S1514)
                {
                    float3  _S1515 = (fcptHitPosition((_S1203)));
                    throughput_8 = _S1515;
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
                    BSDFMaterial _S1516 = _S1361.material;
                    bool _S1517 = isTranslucent_0(&_S1516);
                    if(_S1517)
                    {
                        refracted_4 = _S1509 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1518 = throughput_8 - (&ray_2)->origin;
                        float3  _S1519 = _slang_select(_S1514, _S1518,_S1510);
                        wrong_side_0 = (dot_0(_S1362.smooth_n, _S1519) * _S1363) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1514)
                {
                    float3  _S1520 = (&ray_2)->origin;
                    FKSurface _S1521 = surface_12;
                    float3  _S1522 = - _S1362.smooth_n;
                    bool _S1523 = is_inside_7 != refracted_4;
                    float3  _S1524 = _slang_select(_S1523, _S1522,_S1362.smooth_n);
                    float3  _S1525 = throughput_8 - (_S1520 + make_float3 (_S1521.geometry_offset) * _S1524);
                    float3  _S1526 = ((((_S1525)) * make_float3(rnorm3df(((_S1525)).x, ((_S1525)).y, ((_S1525)).z))));
                    reconnection_1 = _S1526;
                }
                else
                {
                    reconnection_1 = _S1510;
                }
                if(_S1369)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1527 = wrongSide_0(is_inside_7, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1527;
                }
                if(wrong_side_0)
                {
                    return _S1187;
                }
                float3  _S1528 = throughput_8;
                throughput_8 = reconnection_1;
                b_11 = _S1509;
                wrong_side_0 = false;
                reconnection_1 = _S1528;
            }
            else
            {
                bool _S1529 = !_S1401;
                if(_S1529)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1530;
                    if(_S1369)
                    {
                        SampleBSDF _S1531 = (fcptSampleHair((surface_12.hair), (_S1361.material.albedo), (_S1361.material.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1530 = _S1531;
                    }
                    else
                    {
                        SampleBSDF _S1532 = sampleBSDF((&ray_2)->unit_direction, _S1362.smooth_n, _S1361.material, _S1364.x, _S1364.y, surface_12.random_state, _S1418);
                        _S1530 = _S1532;
                    }
                    bsdf_sampled_0 = _S1530;
                    if(_S1369)
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
                            return _S1187;
                        }
                        break;
                    }
                    if(_S1369)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1533 = wrongSide_0(is_inside_7, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1533;
                    }
                    if(wrong_side_0)
                    {
                        _S1447 = (_S1361.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1447 = false;
                    }
                    if(_S1447)
                    {
                        SampleBSDF _S1534 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1361.material, _S1364.x, _S1364.y, (&bsdf_sampled_0)->random_state, _S1418);
                        (&bsdf_sampled_0)->unit_direction = _S1534.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1534.refracted;
                        (&bsdf_sampled_0)->throughput = _S1534.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1535 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1535;
                        }
                    }
                    uint _S1536 = (&bsdf_sampled_0)->lobe;
                    float3  _S1537 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1538 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1539 = (&bsdf_sampled_0)->pdf;
                    float _S1540 = _slang_select(wrong_side_0, 0.0f,_S1539);
                    (&lobe_5)->pdf = _S1540;
                    throughput_8 = _S1537;
                    b_11 = _S1536;
                    refracted_4 = _S1538;
                }
                else
                {
                    throughput_8 = _S1510;
                    b_11 = _S1509;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1447 = true;
            }
            else
            {
                _S1447 = _S1401;
            }
            float3  chain_throughput_1;
            if(_S1447)
            {
                if(_S1369)
                {
                    SampleBSDF _S1541 = (fcptConnectHair((surface_12.hair), (_S1361.material.albedo), (_S1361.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    lobe_5 = _S1541;
                }
                else
                {
                    float3  _S1542 = (&ray_2)->unit_direction;
                    float _S1543 = sign_0(_S1363);
                    float3  _S1544 = _S1362.smooth_n * make_float3 (_S1543);
                    float _S1545 = dot_0(_S1544, throughput_8);
                    float _S1546 = _S1361.material.roughness;
                    float _S1547 = _S1546 * _S1546;
                    AnisotropicFrame _S1548 = anisotropicFrame(_S1361.material, _S1544);
                    float3  _S1549 = reflectedHalf(_S1542, throughput_8);
                    bool _S1550 = b_11 == 1U;
                    if(_S1550)
                    {
                        float3  _S1551 = refractedHalf(_S1542, throughput_8, _S1362.smooth_n, _S1364.x, _S1364.y);
                        throughput_9 = _S1551;
                    }
                    else
                    {
                        throughput_9 = _S1549;
                    }
                    bool _S1552 = b_11 == 0U;
                    if(_S1552)
                    {
                        _S1448 = true;
                    }
                    else
                    {
                        _S1448 = b_11 == 6U;
                    }
                    if(_S1448)
                    {
                        float3  _S1553 = sampledHalf(_S1542, _S1362.smooth_n, _S1361.material, surface_12.random_state, _S1548);
                        throughput_10 = _S1553;
                    }
                    else
                    {
                        throughput_10 = throughput_9;
                    }
                    float3  _S1554 = negate_0(_S1542);
                    float _S1555 = _S1364.x;
                    float _S1556 = _S1364.y;
                    BSDFLobes _S1557 = bsdfLobes(_S1542, _S1554, _S1544, throughput_10, _S1361.material, _S1555, _S1556, _S1548);
                    BSDFLobes lobe_terms_1 = _S1557;
                    float _S1558 = translucentShare(_S1361.material);
                    (&lobe_terms_1)->translucent_share = _S1558;
                    switch(b_11)
                    {
                    case 0U:
                        {
                            float _S1559 = diffusePDF(_S1545, 0.0f, (F32_abs((_S1363))), _S1547, lobe_terms_1, _S1555, _S1556);
                            float3  _S1560 = diffuseBSDF(throughput_8, _S1544, _S1547, _S1361.material, lobe_terms_1);
                            density_6 = _S1559;
                            chain_throughput_1 = _S1560;
                            break;
                        }
                    case 1U:
                        {
                            float _S1561 = refractPDF(_S1545, dot_0(throughput_8, throughput_10), (F32_abs((_S1363))), _S1547, lobe_terms_1, _S1555, _S1556);
                            float3  _S1562 = refractBSDF(throughput_8, _S1544, _S1547, _S1361.material, lobe_terms_1);
                            density_6 = _S1561;
                            chain_throughput_1 = _S1562;
                            break;
                        }
                    case 4U:
                        {
                            float _S1563 = sheenVelvetPDF(_S1545, 0.0f, (F32_abs((_S1363))), _S1547, lobe_terms_1, _S1555, _S1556);
                            float3  _S1564 = sheenVelvetBSDF(throughput_8, _S1544, _S1547, _S1361.material, lobe_terms_1);
                            density_6 = _S1563;
                            chain_throughput_1 = _S1564;
                            break;
                        }
                    case 6U:
                        {
                            float _S1565 = toonPDF(_S1545, dot_0(throughput_8, (&lobe_terms_1)->toon_axis), (F32_abs((_S1363))), _S1547, lobe_terms_1, _S1555, _S1556);
                            float3  _S1566 = toonBSDF(throughput_8, _S1544, _S1547, _S1361.material, lobe_terms_1);
                            density_6 = _S1565;
                            chain_throughput_1 = _S1566;
                            break;
                        }
                    default:
                        {
                            float _S1567 = reflectPDF(_S1545, 0.0f, (F32_abs((_S1363))), _S1547, lobe_terms_1, _S1555, _S1556);
                            float3  _S1568 = reflectBSDF(throughput_8, _S1544, _S1547, _S1361.material, lobe_terms_1);
                            density_6 = _S1567;
                            chain_throughput_1 = _S1568;
                            break;
                        }
                    }
                    bool _S1569 = density_6 > 0.0f;
                    if(_S1569)
                    {
                        SampleBSDF _S1570 = SampleBSDF_x24init_0(throughput_8, chain_throughput_1, surface_12.random_state, _S1550, b_11, density_6);
                        lobe_5 = _S1570;
                    }
                }
            }
            bool _S1571 = b_11 == 0U;
            if(_S1571)
            {
                _S1448 = true;
            }
            else
            {
                _S1448 = b_11 == 4U;
            }
            if(_S1448)
            {
                _S1492 = true;
            }
            else
            {
                _S1492 = b_11 == 6U;
            }
            if(_S1369)
            {
                _S1493 = false;
            }
            else
            {
                bool _S1572 = !_S1492;
                if(_S1572)
                {
                    bool _S1573 = (_S1361.material.roughness) == 0.0f;
                    if(_S1573)
                    {
                        _S1493 = true;
                    }
                    else
                    {
                        bool _S1574 = b_11 == 1U;
                        if(_S1574)
                        {
                            _S1493 = (_S1364.x) == (_S1364.y);
                        }
                        else
                        {
                            _S1493 = false;
                        }
                    }
                }
                else
                {
                    _S1493 = false;
                }
            }
            bool _S1575 = !_S1369;
            if(_S1575)
            {
                _S1494 = b_11 == 1U;
            }
            else
            {
                _S1494 = false;
            }
            if(_S1494)
            {
                straight_0 = (_S1361.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1495 = _S1575;
            }
            else
            {
                _S1495 = false;
            }
            if(_S1495)
            {
                _S1496 = b_11 == 1U;
            }
            else
            {
                _S1496 = false;
            }
            if(_S1496)
            {
                _S1497 = (_S1364.x) == (_S1364.y);
            }
            else
            {
                _S1497 = false;
            }
            BSDFMaterial _S1576 = _S1361.material;
            bool _S1577 = isTranslucent_0(&_S1576);
            if(_S1577)
            {
                _S1498 = _S1571;
            }
            else
            {
                _S1498 = false;
            }
            if(_S1498)
            {
                _S1499 = (dot_0(throughput_8, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1499 = false;
            }
            if(nee_0)
            {
                _S1500 = !_S1493;
            }
            else
            {
                _S1500 = false;
            }
            if(_S1500)
            {
                _S1501 = !wrong_side_0;
            }
            else
            {
                _S1501 = false;
            }
            if(_S1501)
            {
                float _S1578 = (&lobe_5)->pdf;
                float3  _S1579 = (&ray_2)->origin;
                float3  _S1580 = _slang_select(_S1374, _S1186,_S1362.smooth_n);
                float3  _S1581 = (&ray_2)->origin;
                FKSurface _S1582 = surface_12;
                float3  _S1583 = - _S1362.smooth_n;
                float3  _S1584 = _slang_select(_S1499, _S1583,_S1362.smooth_n);
                NEEVertex _S1585 = NEEVertex_x24init_0(false, _S1578, _S1579, _S1580, _S1581 + make_float3 (_S1582.geometry_offset) * _S1584);
                nee_vertex_0 = _S1585;
            }
            else
            {
                if(_S1369)
                {
                    _S1502 = true;
                }
                else
                {
                    bool _S1586 = b_11 != 1U;
                    if(_S1586)
                    {
                        _S1502 = true;
                    }
                    else
                    {
                        _S1502 = (_S1364.x) != (_S1364.y);
                    }
                }
                if(_S1502)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1587 = withinInverseFootprint((&lobe_5)->pdf, _S1492, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1588 = roughLobe((&lobe_5)->pdf, _S1492, _S1361.material.roughness);
            if(_S1401)
            {
                bool _S1589 = !_S1587;
                if(_S1589)
                {
                    return _S1187;
                }
                bool _S1590 = _S1192 != 1U;
                if(_S1590)
                {
                    _S1502 = _S1192 != 2U;
                }
                else
                {
                    _S1502 = false;
                }
                if(_S1502)
                {
                    float _S1591 = (&lobe_5)->pdf;
                    float _S1592 = _slang_select(nee_0, _S1591,0.0f);
                    float _S1593 = escapeWeight_0(_S1592, _S1510);
                    if(_S1409)
                    {
                        passes_0 = _S1198;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1594 = _slang_select(passes_0, _S1593,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1594) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1595 = throughput_6 * make_float3 ((&lobe_5)->pdf);
                float _S1596 = density_4 * (&lobe_5)->pdf;
                throughput_9 = _S1595;
                density_6 = _S1596;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1597 = (fcptLayers((hit_4)));
            bool _S1598 = b_11 == 1U;
            bool _S1599 = passesLayer_0(_S1597, _S1598, passes_0);
            if(viewed_1)
            {
                _S1502 = _S1599;
            }
            else
            {
                _S1502 = false;
            }
            if(_S1502)
            {
                return _S1187;
            }
            if(replay_2)
            {
                _S1503 = b_8 <= _S1202;
            }
            else
            {
                _S1503 = false;
            }
            if(_S1503)
            {
                _S1504 = _S1360;
            }
            else
            {
                _S1504 = false;
            }
            if(_S1504)
            {
                _S1505 = _S1587;
            }
            else
            {
                _S1505 = false;
            }
            if(_S1505)
            {
                _S1506 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1506 = !_S1588;
                }
                else
                {
                    _S1506 = false;
                }
            }
            if(_S1506)
            {
                return _S1187;
            }
            if(viewed_1)
            {
                float3  _S1600 = throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1601 = (&lobe_5)->pdf;
                throughput_10 = _S1600;
                sky_pdf_2 = _S1601;
            }
            else
            {
                float3  _S1602 = throughput_9 * max_0((&lobe_5)->throughput, _S1186);
                throughput_10 = _S1602;
                sky_pdf_2 = density_6;
            }
            bool _S1603;
            if(_S1378)
            {
                _S1603 = !_S1392;
            }
            else
            {
                _S1603 = false;
            }
            bool _S1604;
            if(_S1603)
            {
                _S1604 = _S1360;
            }
            else
            {
                _S1604 = false;
            }
            bool _S1605;
            if(_S1604)
            {
                _S1605 = _S1587;
            }
            else
            {
                _S1605 = false;
            }
            if(_S1605)
            {
                chain_0 = here_0;
                uint _S1606 = insertBits_0((&chain_0)->path, b_11, 18U, 3U);
                uint _S1607 = _slang_select(nee_0, 1U,0U);
                uint _S1608 = insertBits_0(_S1606, _S1607, 21U, 1U);
                (&chain_0)->path = _S1608;
                float _S1609 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1609;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1610 = surface_12;
            Vertex _S1611 = Vertex_x24init_0(_S1588, b_11, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_8)))), is_inside_7);
            prev_0 = _S1611;
            float _S1612 = (&lobe_5)->pdf;
            bool _S1613;
            if(_S1598)
            {
                _S1613 = (_S1364.x) == (_S1364.y);
            }
            else
            {
                _S1613 = false;
            }
            float sky_pdf_3 = _slang_select(_S1613, sky_pdf_0,_S1612);
            float _S1614 = _slang_select(_S1369, 0.0f,sky_pdf_3);
            float _S1615 = widened_0(spread_2, (&lobe_5)->pdf, _S1493);
            bool _S1616;
            if(refracted_4)
            {
                _S1616 = !_S1499;
            }
            else
            {
                _S1616 = false;
            }
            bool is_inside_8;
            if(_S1616)
            {
                bool _S1617 = !is_inside_7;
                is_inside_8 = _S1617;
            }
            else
            {
                is_inside_8 = is_inside_7;
            }
            FKSurface _S1618 = surface_12;
            bool _S1619 = boundsVolume_0(&_S1618);
            bool _S1620;
            if(_S1619)
            {
                _S1620 = !_S1599;
            }
            else
            {
                _S1620 = false;
            }
            if(_S1620)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1621 = - _S1610.geometry_n;
                float3  _S1622 = _slang_select(turned_1, _S1621,_S1610.geometry_n);
                (&faced_2)->geometry_n = _S1622;
                FKMedium _S1623 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1624 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1625 = faced_2;
                FKMedium _S1626 = _S1623;
                FKMedium _S1627 = _S1624;
                MediumSides _S1628 = mediumSides_0(&_S1625, &_S1626, filling_2, (&ray_2)->unit_direction, &_S1627);
                bool _S1629 = leavesInFront_0((&faced_2)->geometry_n, throughput_8, _S1610.geometry_n);
                float3  _S1630 = _slang_select(_S1629, _S1628.front.scatter,_S1628.behind.scatter);
                scatter_in_0 = _S1630;
                float3  _S1631 = _slang_select(_S1629, _S1628.front.extinction,_S1628.behind.extinction);
                extinction_in_0 = _S1631;
                float _S1632 = _slang_select(_S1629, _S1628.front.g,_S1628.behind.g);
                g_in_0 = _S1632;
                uint _S1633 = _S1628.fillings.x;
                uint _S1634 = _S1628.fillings.y;
                uint _S1635 = _slang_select(_S1629, _S1634,_S1633);
                bool _S1636 = (fcptVaryingUsed());
                uint _S1637 = _slang_select(_S1636, _S1635,4294967295U);
                filling_2 = _S1637;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1638 = !_S1599;
            if(_S1638)
            {
                FKSurface _S1639 = surface_12;
                float _S1640 = _slang_select(straight_0, 0.0f,_S1639.geometry_offset);
                float3  _S1641 = - _S1362.smooth_n;
                bool _S1642 = is_inside_8 != _S1499;
                float3  _S1643 = _slang_select(_S1642, _S1641,_S1362.smooth_n);
                float3  _S1644 = (&ray_2)->origin + make_float3 (_S1640) * _S1643;
                (&ray_2)->origin = _S1644;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1599;
            viewed_1 = _S1497;
            sky_pdf_2 = _S1614;
            spread_5 = _S1615;
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
        if(_S1378)
        {
            if(_S1328)
            {
                float3  _S1645 = throughput_9 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1646 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1647 = _S1646 == 1U;
                if(_S1647)
                {
                    float3  _S1648 = safeDivide(_S1645, chain_throughput_0);
                    (&candidate_8)->radiance = _S1648;
                }
                Reservoir _S1649 = withEnd(candidate_8, 2U, b_8, _S1645);
                offer(sel_7, _S1649, _S1645 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1328)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1650 = survivalProbability(throughput_9, density_6);
                density_7 = _S1650;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1651 = stream(_S1214, b_8 + 128U);
            Random _S1652 = pcg(_S1651);
            bool _S1653 = density_7 < (_S1652.value);
            if(_S1653)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1654 = (fcptMaxBounces());
                wrong_side_0 = b_8 >= _S1654;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1655 = density_6 * density_7;
            density_7 = _S1655;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1656 = layer_0 ^ 1U;
        uint _S1657 = _slang_select(passes_0, _S1656,0U);
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
            uint _S1658 = b_11 + 1U;
            b_8 = _S1658;
            layer_0 = _S1657;
            continue;
        }
        FKRay _S1659 = ray_2;
        float _S1660 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1402;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1191 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1661 = _slang_select(wrong_side_0, _S1660,4.294967296e+09f);
        bool _S1662 = !_S1369;
        if(straight_0)
        {
            _S1447 = true;
        }
        else
        {
            _S1447 = _S1369;
        }
        FKHit _S1663;
        if(_S1447)
        {
            _S1663 = hit_4;
        }
        else
        {
            _S1663 = _S1419;
        }
        FKHit _S1664 = (fcptTraverseInstanceBVH((_S1659), (_S1336), (_S1661), (_S1662), (_S1663), (viewed_1)));
        hit_4 = _S1664;
        if(replay_2)
        {
            _S1448 = _S1402;
        }
        else
        {
            _S1448 = false;
        }
        if(_S1448)
        {
            _S1492 = _S1191 == 1U;
        }
        else
        {
            _S1492 = false;
        }
        if(_S1492)
        {
            _S1493 = ((&hit_4)->instance_index) == (_S1203.instance_index);
        }
        else
        {
            _S1493 = false;
        }
        if(_S1493)
        {
            _S1494 = ((&hit_4)->triangle_index) == (_S1203.triangle_index);
        }
        else
        {
            _S1494 = false;
        }
        if(_S1494)
        {
            (&hit_4)->uv = _S1203.uv;
            float _S1665 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1665;
        }
        if(replay_2)
        {
            _S1495 = _S1402;
        }
        else
        {
            _S1495 = false;
        }
        if(_S1495)
        {
            _S1496 = _S1191 == 3U;
        }
        else
        {
            _S1496 = false;
        }
        if(_S1496)
        {
            _S1497 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1497 = false;
        }
        if(_S1497)
        {
            return _S1187;
        }
        Reservoir _S1666 = chain_0;
        uint _S1667 = filling_2;
        for(;;)
        {
            bool _S1668 = (fcptVaryingUsed());
            if(_S1668)
            {
                _S1498 = _S1667 != 4294967295U;
            }
            else
            {
                _S1498 = false;
            }
            float _S1669;
            if(_S1498)
            {
                float _S1670 = (fcptMajorant((_S1667)));
                _S1669 = _S1670;
            }
            else
            {
                _S1669 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1499 = _S1402;
            }
            else
            {
                _S1499 = false;
            }
            if(_S1499)
            {
                _S1500 = _S1191 == 1U;
            }
            else
            {
                _S1500 = false;
            }
            if(_S1500)
            {
                _S1501 = _S1669 > 0.0f;
            }
            else
            {
                _S1501 = false;
            }
            if(_S1501)
            {
                ended_0 = _S1187;
                sky_pdf_1 = sky_pdf_2;
                spread_3 = spread_5;
                width_4 = width_3;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_11 = b_8;
                _S1502 = true;
                break;
            }
            bool _S1671 = (&prev_0)->rough;
            if(_S1671)
            {
                _S1502 = !(_S1669 > 0.0f);
            }
            else
            {
                _S1502 = false;
            }
            (&prev_0)->rough = _S1502;
            uint _S1672 = b_8 + 320U;
            bool _S1673 = b_8 == 4294967295U;
            uint _S1674 = _slang_select(_S1673, 384U,_S1672);
            uint _S1675 = stream(_S1214, _S1674);
            uint tracking_1 = _S1675;
            weight_1 = throughput_3;
            glowed_0 = _S1186;
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
                    _S1185 = int(2);
                    break;
                }
                uint _S1676 = b_11 + 320U;
                bool _S1677 = b_11 == 4294967295U;
                uint _S1678 = _slang_select(_S1677, 384U,_S1676);
                uint _S1679 = stream(_S1214, _S1678);
                Random _S1680 = pcg(_S1679);
                float _S1681 = freeFlight_0(_S1680.value, _S1669);
                if(_S1498)
                {
                    float3  _S1682 = (&ray_2)->origin;
                    float3  _S1683 = (&ray_2)->unit_direction;
                    float _S1684 = (&hit_4)->distance;
                    uint _S1685 = _slang_select(_S1677, 0U,b_11);
                    uint _S1686 = (&prev_0)->lobe;
                    uint _S1687 = _slang_select(_S1677, 3U,_S1686);
                    float _S1688 = (fcptTrackMedium((_S1667), (_S1682), (_S1683), (_S1684), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1685), (_S1687), (_S1677)));
                    spread_4 = _S1688;
                }
                else
                {
                    spread_4 = _S1681;
                }
                bool _S1689 = !(spread_4 < ((&hit_4)->distance));
                if(_S1689)
                {
                    _S1185 = int(2);
                    break;
                }
                if(_S1498)
                {
                    _S1503 = _S1378;
                }
                else
                {
                    _S1503 = false;
                }
                if(_S1503)
                {
                    float3  _S1690 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1691 = sel_7->glow + _S1690;
                    sel_7->glow = _S1691;
                }
                else
                {
                }
                glowed_0 = _S1186;
                uint b_12 = b_11 + 1U;
                float3  _S1692 = (&ray_2)->origin + make_float3 (spread_4) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1692;
                float3  _S1693 = flightWeight_0(scatter_in_0, extinction_in_0, _S1669, spread_4, true);
                float3  _S1694 = weight_1;
                float3  _S1695 = _slang_select(_S1498, _S1694,_S1693);
                float3  throughput_11 = throughput_10 * _S1695;
                uint _S1696 = stream(_S1214, b_12 + 320U);
                tracking_1 = _S1696;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_3 * spread_4;
                float _S1697 = spread_3 + 3.14159274101257324f;
                bool _S1698 = scatterSampled_0(replay_2, b_12, _S1202, _S1498);
                TreeSample light_4;
                if(_S1698)
                {
                    float3  _S1699 = (&ray_2)->origin;
                    float3  _S1700 = (&ray_2)->unit_direction;
                    float3  _S1701 = (&ray_2)->unit_direction;
                    uint _S1702 = stream(_S1214, b_12 + 64U);
                    float3  _S1703 = extinction_in_0;
                    float3  _S1704 = extinction_in_0;
                    uint2  _S1705 = make_uint2 (_S1667);
                    float3  _S1706 = (&ray_2)->unit_direction;
                    uint _S1707 = arrivalLobe_0(b_12, (&prev_0)->lobe);
                    FKHit _S1708 = _S1419;
                    ShadowContext _S1709 = ShadowContext_x24init_0(_S1703, _S1704, _S1705, _S1706, b_12, _S1707, false, spread_4, width_7, &_S1708, false);
                    ShadowContext _S1710 = _S1709;
                    TreeSample _S1711 = sampleLightTree_0(_S1699, _S1700, _S1701, 0.0f, true, _S1702, &_S1710);
                    light_4 = _S1711;
                }
                else
                {
                    light_4 = _S1416;
                }
                float _S1712 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1713 = (fcptMaxBounces());
                bool _S1714 = b_12 < _S1713;
                if(_S1714)
                {
                    _S1504 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1504 = false;
                }
                float _S1715 = _slang_select(_S1504, _S1712,0.0f);
                float3  _S1716 = throughput_11 * light_4.radiance;
                float _S1717 = powerHeuristic(light_4.density, _S1715);
                float3  _S1718 = _S1716 * make_float3 (_S1712 * _S1717);
                float3  _S1719 = _slang_select(_S1698, _S1718,_S1186);
                if(replay_2)
                {
                    _S1505 = b_12 == _S1202;
                }
                else
                {
                    _S1505 = false;
                }
                if(_S1505)
                {
                    bool _S1720 = _S1191 == 2U;
                    if(_S1720)
                    {
                        float _S1721 = rgb_to_greyscale(_S1719);
                        _S1506 = _S1721 > 0.0f;
                    }
                    else
                    {
                        _S1506 = false;
                    }
                    if(_S1506)
                    {
                        Shift _S1722 = Shift_x24init_0(_S1719, 1.0f);
                        _S1185 = int(1);
                        ended_0 = _S1722;
                        spread_4 = _S1697;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_9 = b_12;
                        break;
                    }
                    _S1185 = int(1);
                    ended_0 = _S1187;
                    spread_4 = _S1697;
                    width_5 = width_7;
                    throughput_8 = throughput_11;
                    b_9 = b_12;
                    break;
                }
                if(_S1378)
                {
                    Reservoir candidate_9 = _S1666;
                    uint _S1723 = extractBits_0(_S1666.path, 10U, 2U);
                    bool _S1724 = _S1723 == 1U;
                    if(_S1724)
                    {
                        float3  _S1725 = safeDivide(_S1719, chain_throughput_0);
                        (&candidate_9)->radiance = _S1725;
                    }
                    else
                    {
                        uint _S1726 = insertBits_0(0U, b_12 + 1U, 5U, 5U);
                        uint _S1727 = insertBits_0(_S1726, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1727;
                    }
                    Reservoir _S1728 = withEnd(candidate_9, 0U, b_12, _S1719);
                    offer(sel_7, _S1728, _S1719 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1729 = survivalProbability(throughput_11, density_3);
                    uint _S1730 = stream(_S1214, b_12 + 128U);
                    Random _S1731 = pcg(_S1730);
                    bool _S1732 = _S1729 < (_S1731.value);
                    if(_S1732)
                    {
                        _S1506 = true;
                    }
                    else
                    {
                        uint _S1733 = (fcptMaxBounces());
                        _S1506 = b_12 >= _S1733;
                    }
                    if(_S1506)
                    {
                        _S1185 = int(1);
                        ended_0 = _S1187;
                        spread_4 = _S1697;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_9 = b_12;
                        break;
                    }
                    float _S1734 = density_3 * _S1729;
                    density_3 = _S1734;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1735 = stream(_S1214, b_12);
                float3  _S1736 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1735, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1736;
                NEEVertex _S1737 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1186, (&ray_2)->origin);
                nee_vertex_0 = _S1737;
                Vertex _S1738 = scatteredVertex_0(is_inside_6);
                prev_0 = _S1738;
                float _S1739 = (&prev_0)->pdf;
                FKRay _S1740 = ray_2;
                FKHit _S1741 = (fcptTraverseInstanceBVH((_S1740), (true), (4.294967296e+09f), (false), (_S1419), (false)));
                hit_4 = _S1741;
                b_11 = b_12;
                throughput_10 = throughput_11;
                spread_3 = _S1697;
                width_4 = width_7;
                sky_pdf_1 = _S1739;
            }
            if(_S1185 != int(2))
            {
                spread_3 = spread_4;
                width_4 = width_5;
                throughput_10 = throughput_8;
                b_11 = b_9;
                _S1502 = true;
                break;
            }
            ended_0 = _S1187;
            _S1502 = false;
            break;
        }
        if(_S1502)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1503 = b_11 == b_8;
        }
        else
        {
            _S1503 = false;
        }
        bool _S1742 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1742)
        {
            bool _S1743 = !(&nee_vertex_0)->none;
            float _S1744 = _slang_select(_S1743, sky_pdf_1,0.0f);
            float _S1745 = escapeWeight_0(_S1744, (&ray_2)->unit_direction);
            float3  _S1746 = environment_0((&ray_2)->unit_direction, b_11, (&prev_0)->lobe);
            float3  _S1747 = throughput_10 * _S1746;
            if(replay_2)
            {
                bool _S1748 = b_11 == _S1202;
                if(_S1748)
                {
                    passes_0 = _S1191 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1747 * make_float3 (_S1745) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1201)
                {
                    passes_0 = _S1198;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_11 == _S1189;
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
                    return Shift_x24init_0(_S1747 * make_float3 (_S1745), 1.0f);
                }
                return _S1187;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1749 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1750 = _S1749 == 1U;
            if(_S1750)
            {
                uint _S1751 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1752 = _S1751 == b_11;
                float _S1753 = _slang_select(_S1752, 1.0f,_S1745);
                float3  _S1754 = safeDivide(_S1747 * make_float3 (_S1753), chain_throughput_0);
                (&candidate_10)->radiance = _S1754;
            }
            else
            {
                bool _S1755 = (&prev_0)->rough;
                if(_S1755)
                {
                    uint _S1756 = insertBits_0(0U, b_11 + 1U, 5U, 5U);
                    uint _S1757 = insertBits_0(_S1756, 3U, 10U, 2U);
                    uint _S1758 = insertBits_0(_S1757, (&prev_0)->lobe, 15U, 3U);
                    bool _S1759 = (&prev_0)->inside;
                    uint _S1760 = _slang_select(_S1759, 1U,0U);
                    uint _S1761 = insertBits_0(_S1758, _S1760, 22U, 1U);
                    (&candidate_10)->path = _S1761;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1762 = _S1747 * make_float3 (_S1745);
            Reservoir _S1763 = withEnd(candidate_10, 3U, b_11, _S1762);
            offer(sel_7, _S1763, _S1762 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1764 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1764;
        bool _S1765 = (fcptVaryingUsed());
        if(_S1765)
        {
            _S1504 = filling_2 != 4294967295U;
        }
        else
        {
            _S1504 = false;
        }
        if(_S1504)
        {
            if(_S1378)
            {
                float3  _S1766 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1767 = sel_7->glow + _S1766;
                sel_7->glow = _S1767;
            }
            float3  _S1768 = throughput_10 * weight_1;
            throughput_8 = _S1768;
        }
        else
        {
            float3  _S1769 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1770 = throughput_10 * _S1769;
            throughput_8 = _S1770;
        }
        float _S1771 = width_4 + spread_3 * (&hit_4)->distance;
        viewed_0 = _S1503;
        width_3 = _S1771;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_3;
        uint _S1658 = b_11 + 1U;
        b_8 = _S1658;
        layer_0 = _S1657;
    }
    return _S1187;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_9)
{
    Selection _S1772 = (Selection{});
    Selection sel_8 = _S1772;
    bool _S1773 = (r_9->w) <= 0.0f;
    if(_S1773)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1774 = walk_0(dom_8, r_9, true, 0.0f, &sel_8);
    return _S1774;
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
    Random _S1775 = pcg(state_4);
    Random _S1776 = pcg(_S1775.state);
    float _S1777 = 6.28318548202514648f * _S1775.value;
    float _S1778 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1776.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1776.state, _S1778 * (F32_cos((_S1777))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S1779;
    (&_S1779)->state = state_5;
    (&_S1779)->value = value_2;
    return _S1779;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S1780 = normal_distribution(state_6);
    Random _S1781 = normal_distribution(_S1780.state);
    Random _S1782 = normal_distribution(_S1781.state);
    float3  _S1783 = make_float3 (_S1780.value, _S1781.value, _S1782.value);
    float3  _S1784 = ((((_S1783)) * make_float3(rnorm3df(((_S1783)).x, ((_S1783)).y, ((_S1783)).z))));
    return RandomSphere_x24init_0(_S1782.state, _S1784);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_12)
{
    float3  _S1785 = p1_0 - p0_0;
    float3  _S1786 = p2_0 - p0_0;
    float2  _S1787 = uv1_0 - uv0_0;
    float2  _S1788 = uv2_0 - uv0_0;
    float _S1789 = _S1787.x;
    float _S1790 = _S1788.y;
    float _S1791 = _S1787.y;
    float _S1792 = _S1788.x;
    float _S1793 = _S1789 * _S1790 - _S1791 * _S1792;
    float _S1794 = 1.0f / _S1793;
    float3  t_22 = (_S1785 * make_float3 (_S1790) - _S1786 * make_float3 (_S1791)) * make_float3 (_S1794);
    float3  _S1795 = (_S1786 * make_float3 (_S1789) - _S1785 * make_float3 (_S1792)) * make_float3 (_S1794);
    float3  _S1796 = t_22 - n_12 * make_float3 (dot_0(n_12, t_22));
    float3  t_23 = ((((_S1796)) * make_float3(rnorm3df(((_S1796)).x, ((_S1796)).y, ((_S1796)).z))));
    bool _S1797 = (dot_0(cross_0(n_12, t_23), _S1795)) > 0.0f;
    float3  t_24;
    if(_S1797)
    {
        float3  _S1798 = negate_0(t_23);
        t_24 = _S1798;
    }
    else
    {
        t_24 = t_23;
    }
    float3  _S1799 = cross_0(n_12, t_24);
    return makeMatrix<float, 3, 3> (t_24, _S1799, n_12);
}

__device__ float3  tangentToWorldNormalMap(float3  v_4, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_4, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1800 = t1_0 - t0_0;
    float3  _S1801 = t2_2 - t0_0;
    float3  _S1802 = t2_2 - t1_0;
    float _S1803 = (F32_min((length_0(_S1800)), ((F32_min((length_0(_S1801)), (length_0(_S1802)))))));
    float3  _S1804 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1805 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1806 = dot_0(geometry_n_5, _S1805);
    float3  _S1807 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1808 = dot_0(geometry_n_5, _S1807);
    float3  _S1809 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1810 = acos_0(abs_0(make_float3 (_S1806, _S1808, dot_0(geometry_n_5, _S1809))));
    float3  _S1811 = clamp_2(tan_0(_S1810), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1804 * _S1811, uvw_0), 0.0f, _S1803 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_15, float3  n_13, BSDFMaterial material_22)
{
    float3  _S1812 = negate_0(dir_15);
    float _S1813 = sign_0(dot_0(n_13, _S1812));
    float3  _S1814 = n_13 * make_float3 (_S1813);
    AnisotropicFrame _S1815 = anisotropicFrame(material_22, _S1814);
    bool _S1816 = (_S1815.alphas.x) > 0.0f;
    if(_S1816)
    {
        float _S1817 = material_22.transmission * (1.0f - material_22.metallic);
        float3  _S1818 = negate_0(_S1814);
        float3  _S1819 = anisotropicLocal(dir_15, _S1815.tangent, _S1818);
        float _S1820 = anisotropicG1(_S1819, _S1815.alphas);
        return make_float3 (_S1817 * _S1820) * material_22.albedo;
    }
    float _S1821 = material_22.transmission * (1.0f - material_22.metallic);
    float _S1822 = material_22.roughness;
    float _S1823 = smithG1(_S1822 * _S1822, (F32_abs((dot_0(n_13, dir_15)))));
    return make_float3 (_S1821 * _S1823) * material_22.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_25, float3  out_dir_3, uint p_14, float w_2, float alpha_20, uint nt_0)
{
    uint _S1824 = p_14 % 4U;
    float _S1825 = w_2 * HAIR_WIDTHS_0[_S1824];
    float _S1826 = (F32_asin((clamp_1(dot_0(out_dir_3, t_25), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_25), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1824] * alpha_20;
    return ((F32_asinh((_S1826 / _S1825))) / (F32_asinh((3.14159274101257324f / _S1825))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_26, float3  out_dir_4, uint np_0)
{
    float3  _S1827 = worldToTangent(out_dir_4, t_26);
    float3  _S1828 = worldToTangent(in_dir_12, t_26);
    return (F32_frac((((F32_atan2((_S1827.z), (_S1827.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1828.z), (1.17549435082228751e-38f - _S1828.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_27, uint p_15, float row_0, float column_0, float w_3, float alpha_21, uint nt_1, uint np_1)
{
    float3  _S1829 = worldToTangent(in_dir_13, t_27);
    uint _S1830 = p_15 % 4U;
    float _S1831 = w_3 * HAIR_WIDTHS_0[_S1830];
    float _S1832 = (F32_asin((clamp_1(dot_0(in_dir_13, t_27), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1830] * alpha_21 + _S1831 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1831))))));
    float _S1833 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1829.z), (1.17549435082228751e-38f - _S1829.x)));
    float _S1834 = (F32_cos((_S1832)));
    float3  _S1835 = tangentToWorld(make_float3 (_S1834 * (F32_cos((_S1833))), (F32_sin((_S1832))), _S1834 * (F32_sin((_S1833)))), t_27);
    return _S1835;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_14, BSDFMaterial material_23, float coverage_1)
{
    float3  _S1836;
    if((material_23.ior) == 1.0f)
    {
        float3  _S1837 = straightThrough(toward_1, n_14, material_23);
        _S1836 = _S1837;
    }
    else
    {
        _S1836 = make_float3 (0.0f);
    }
    return _S1836 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_4, Selection * sel_9)
{
    Domain _S1838 = dom_9;
    Reservoir _S1839 = r_10;
    Shift _S1840 = walk_0(&_S1838, &_S1839, replay_3, scale_4, sel_9);
    return _S1840;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_11)
{
    Domain _S1841 = dom_10;
    Reservoir _S1842 = r_11;
    Shift _S1843 = shift_0(&_S1841, &_S1842);
    return _S1843;
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
