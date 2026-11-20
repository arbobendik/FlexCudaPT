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

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

__device__ float translucentShare(BSDFMaterial material_0)
{
    float _S310 = rgb_to_greyscale(material_0.translucent);
    float _S311 = rgb_to_greyscale(material_0.albedo);
    float _S312 = _S310 / (_S311 + _S310);
    bool _S313 = _S310 > 0.0f;
    float _S314 = _slang_select(_S313, _S312,0.0f);
    return _S314;
}

static __device__ MaterialTerms MaterialTerms_x24init_0(float f0_0, float eta_level_0, float translucent_share_0, float toon_scale_0, float toon_component_0, float3  toon_0, float toon_a_0, float toon_s_0, float toon_b_0, bool toon_glossy_0, float toon_norm_0)
{
    MaterialTerms _S315;
    (&_S315)->f0 = f0_0;
    (&_S315)->eta_level = eta_level_0;
    (&_S315)->translucent_share = translucent_share_0;
    (&_S315)->toon_scale = toon_scale_0;
    (&_S315)->toon_component = toon_component_0;
    (&_S315)->toon = toon_0;
    (&_S315)->toon_a = toon_a_0;
    (&_S315)->toon_s = toon_s_0;
    (&_S315)->toon_b = toon_b_0;
    (&_S315)->toon_glossy = toon_glossy_0;
    (&_S315)->toon_norm = toon_norm_0;
    return _S315;
}

__device__ __forceinline__ MaterialTerms precomputeMaterial(BSDFMaterial material_1, float eta_i_0, float eta_o_0)
{
    float _S316 = (F32_min(((F32_sqrt((material_1.specular_level))) * (F32_abs((eta_i_0 - eta_o_0))) / (eta_i_0 + eta_o_0)), (0.9999847412109375f)));
    float _S317 = _S316 * _S316;
    float _S318 = (1.0f + _S316) / (1.0f - _S316);
    float3  _S319 = make_float3 (0.0f);
    float _S320 = material_1.toon.x;
    bool _S321 = _S320 < 0.0f;
    float _S322 = (F32_abs((_S320)));
    bool _S323 = _S322 > 0.0f;
    float toon_scale_1;
    float toon_component_1;
    float toon_a_1;
    float toon_s_1;
    float toon_b_1;
    float toon_norm_1;
    float3  toon_1;
    if(_S323)
    {
        float _S324 = (F32_min((_S322), (1.0f)));
        float _S325 = 1.0f - _S324;
        float _S326 = rgb_to_greyscale(material_1.albedo);
        float _S327 = _S324 * _S326;
        float3  _S328 = make_float3 (_S324) * material_1.albedo;
        float toon_a_2 = clamp_1(material_1.toon.y / _S320, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_2 = clamp_1(material_1.toon.z / _S320, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S329 = (F32_min((toon_a_2 + toon_s_2), (1.57079637050628662f)));
        if(_S321)
        {
            toon_scale_1 = 1.0f - (F32_cos(((F32_min((_S329), (toon_a_2))))));
        }
        else
        {
            float _S330 = (F32_sin(((F32_min((_S329), (toon_a_2))))));
            toon_scale_1 = _S330 * _S330 / 2.0f;
        }
        bool _S331 = _S329 > toon_a_2;
        bool _S332;
        if(_S331)
        {
            _S332 = toon_s_2 > 0.0f;
        }
        else
        {
            _S332 = false;
        }
        if(_S332)
        {
            if(_S321)
            {
                float _S333 = (F32_cos((toon_a_2)));
                float _S334 = (F32_cos((_S329)));
                toon_component_1 = (1.0f + toon_a_2 / toon_s_2) * (_S333 - _S334) - ((F32_sin((_S329))) - _S329 * _S334 - ((F32_sin((toon_a_2))) - toon_a_2 * _S333)) / toon_s_2;
            }
            else
            {
                float _S335 = 2.0f * toon_a_2;
                float _S336 = (F32_cos((_S335)));
                float _S337 = 2.0f * _S329;
                float _S338 = (F32_cos((_S337)));
                toon_component_1 = (1.0f + toon_a_2 / toon_s_2) * (_S336 - _S338) / 4.0f - ((F32_sin((_S337))) / 8.0f - _S329 * _S338 / 4.0f - ((F32_sin((_S335))) / 8.0f - toon_a_2 * _S336 / 4.0f)) / toon_s_2;
            }
            float integral_0 = toon_scale_1 + toon_component_1;
            toon_scale_1 = integral_0;
        }
        float _S339 = 6.28318548202514648f * toon_scale_1;
        toon_scale_1 = _S325;
        toon_component_1 = _S327;
        toon_1 = _S328;
        toon_a_1 = toon_a_2;
        toon_s_1 = toon_s_2;
        toon_b_1 = _S329;
        toon_norm_1 = _S339;
    }
    else
    {
        toon_scale_1 = 1.0f;
        toon_component_1 = 0.0f;
        toon_1 = _S319;
        toon_a_1 = 0.0f;
        toon_s_1 = 0.0f;
        toon_b_1 = 0.0f;
        toon_norm_1 = 1.0f;
    }
    float _S340 = translucentShare(material_1);
    return MaterialTerms_x24init_0(_S317, _S318, _S340, toon_scale_1, toon_component_1, toon_1, toon_a_1, toon_s_1, toon_b_1, _S321, toon_norm_1);
}

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

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    float _S341;
    if(e_1 > 0.0f)
    {
        _S341 = 1.0f;
    }
    else
    {
        if(e_1 < 0.0f)
        {
            _S341 = -1.0f;
        }
        else
        {
            _S341 = 0.0f;
        }
    }
    return _S341;
}

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S342;
    (&_S342)->tangent = tangent_0;
    (&_S342)->alphas = alphas_0;
    return _S342;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S343 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S343)
    {
        float3  _S344 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S344;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S345 = cross_0(n_1, a_2);
    float3  _S346 = ((((_S345)) * make_float3(rnorm3df(((_S345)).x, ((_S345)).y, ((_S345)).z))));
    float3  _S347 = cross_0(n_1, _S346);
    return make_float3 (v_0.x) * _S346 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S347;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_2, float3  n_i_0)
{
    float _S348 = material_2.roughness;
    float _S349 = _S348 * _S348;
    bool _S350 = (material_2.anisotropy) == 0.0f;
    bool _S351;
    if(_S350)
    {
        _S351 = true;
    }
    else
    {
        _S351 = !(_S349 > 0.0f);
    }
    if(_S351)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S352 = material_2.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_2.tangent));
    float3  _S353 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S354 = (dot_0(_S352, _S352)) > 0.0f;
    float3  _S355 = _slang_select(_S354, _S352,_S353);
    float3  _S356 = ((((_S355)) * make_float3(rnorm3df(((_S355)).x, ((_S355)).y, ((_S355)).z))));
    float _S357 = 6.28318548202514648f * material_2.anisotropic_rotation;
    float _S358 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_2.anisotropy))))));
    float _S359 = 1.0f / _S358;
    bool _S360 = (material_2.anisotropy) < 0.0f;
    float _S361 = _slang_select(_S360, _S359,_S358);
    return AnisotropicFrame_x24init_0(_S356 * make_float3 ((F32_cos((_S357)))) + cross_0(n_i_0, _S356) * make_float3 ((F32_sin((_S357)))), make_float2 (_S349 / _S361, _S349 * _S361));
}

__device__ static const FixedArray<float, 576>  SHEEN_ALBEDO_0 = { {
    0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f
} };
__device__ static const FixedArray<float, 576>  VELVET_ALBEDO_0 = { {
    1.00383996963500977f, 1.00428998470306396f, 1.00356996059417725f, 1.00303995609283447f, 1.00261998176574707f, 1.00229001045227051f, 1.00198996067047119f, 1.00171005725860596f, 1.00144004821777344f, 1.00120997428894043f, 1.00102996826171875f, 1.00092005729675293f, 1.00088000297546387f, 1.0009000301361084f, 1.00095999240875244f, 1.00106000900268555f, 1.00115001201629639f, 1.00124001502990723f, 1.001289963722229f, 1.0013200044631958f, 1.00133001804351807f, 1.00133001804351807f, 1.0013200044631958f, 1.00129997730255127f, 0.99086397886276245f, 0.9934689998626709f, 0.99439799785614014f, 0.99513500928878784f, 0.99574202299118042f, 0.9962649941444397f, 0.99671798944473267f, 0.99709898233413696f, 0.997406005859375f, 0.99764800071716309f, 0.99783498048782349f, 0.99798601865768433f, 0.99811899662017822f, 0.99825501441955566f, 0.99840497970581055f, 0.99857097864151001f, 0.99874699115753174f, 0.99892902374267578f, 0.9990919828414917f, 0.99923902750015259f, 0.99936902523040771f, 0.99948000907897949f, 0.99957501888275146f, 0.99965798854827881f, 0.94088798761367798f, 0.95128101110458374f, 0.95866602659225464f, 0.96450901031494141f, 0.96921002864837646f, 0.973052978515625f, 0.97623497247695923f, 0.97890102863311768f, 0.98115700483322144f, 0.98308497667312622f, 0.98474901914596558f, 0.98619699478149414f, 0.98746699094772339f, 0.98858797550201416f, 0.98958402872085571f, 0.99047297239303589f, 0.99127000570297241f, 0.99198299646377563f, 0.99262100458145142f, 0.99318897724151611f, 0.99372398853302002f, 0.99426800012588501f, 0.99475300312042236f, 0.99514400959014893f, 0.86131101846694946f, 0.88463401794433594f, 0.90212702751159668f, 0.91595500707626343f, 0.92708200216293335f, 0.93617302179336548f, 0.94370102882385254f, 0.95000702142715454f, 0.95534700155258179f, 0.9599120020866394f, 0.96384698152542114f, 0.96726799011230469f, 0.97026199102401733f, 0.97289901971817017f, 0.97523599863052368f, 0.97731602191925049f, 0.97917401790618896f, 0.98083901405334473f, 0.98233497142791748f, 0.98368102312088013f, 0.98489302396774292f, 0.98598498106002808f, 0.98697298765182495f, 0.98787301778793335f, 0.75306302309036255f, 0.79328000545501709f, 0.82418698072433472f, 0.84881901741027832f, 0.86874997615814209f, 0.88506197929382324f, 0.89858502149581909f, 0.9099239706993103f, 0.91952997446060181f, 0.9277459979057312f, 0.93483197689056396f, 0.94099199771881104f, 0.9463840126991272f, 0.95113497972488403f, 0.95534402132034302f, 0.95908999443054199f, 0.9624369740486145f, 0.96543699502944946f, 0.96813201904296875f, 0.97055697441101074f, 0.97274202108383179f, 0.97471201419830322f, 0.97649002075195312f, 0.97809398174285889f, 0.62183499336242676f, 0.68052101135253906f, 0.72705197334289551f, 0.76452702283859253f, 0.79505598545074463f, 0.82021200656890869f, 0.84120297431945801f, 0.85885602235794067f, 0.87384098768234253f, 0.88667500019073486f, 0.89775800704956055f, 0.90739899873733521f, 0.91584599018096924f, 0.92329102754592896f, 0.929889976978302f, 0.93576502799987793f, 0.94101500511169434f, 0.94572198390960693f, 0.94994997978210449f, 0.95375597476959229f, 0.95718497037887573f, 0.9602770209312439f, 0.96306699514389038f, 0.96558600664138794f, 0.47742500901222229f, 0.5522189736366272f, 0.61415499448776245f, 0.66520899534225464f, 0.70744901895523071f, 0.74262100458145142f, 0.77213901281356812f, 0.7971159815788269f, 0.81841897964477539f, 0.83673000335693359f, 0.85258400440216064f, 0.86640900373458862f, 0.87854301929473877f, 0.88924998044967651f, 0.89874798059463501f, 0.90721100568771362f, 0.91477799415588379f, 0.92156499624252319f, 0.92766499519348145f, 0.93315702676773071f, 0.9381060004234314f, 0.94257098436355591f, 0.94660097360610962f, 0.95023900270462036f, 0.33539599180221558f, 0.41908100247383118f, 0.49247598648071289f, 0.55531197786331177f, 0.60879099369049072f, 0.65415602922439575f, 0.69274699687957764f, 0.72571200132369995f, 0.75402498245239258f, 0.77849102020263672f, 0.79976201057434082f, 0.81836599111557007f, 0.83474302291870117f, 0.84922301769256592f, 0.86208897829055786f, 0.87356698513031006f, 0.88384199142456055f, 0.89306402206420898f, 0.90135800838470459f, 0.9088289737701416f, 0.91556602716445923f, 0.92164498567581177f, 0.92713397741317749f, 0.93208998441696167f, 0.21194499731063843f, 0.29365798830986023f, 0.37110498547554016f, 0.44143900275230408f, 0.5036969780921936f, 0.55801302194595337f, 0.60521197319030762f, 0.64614301919937134f, 0.68169897794723511f, 0.71268302202224731f, 0.73979401588439941f, 0.76362699270248413f, 0.78467601537704468f, 0.80335497856140137f, 0.82000100612640381f, 0.83488202095031738f, 0.8482239842414856f, 0.86021500825881958f, 0.87101101875305176f, 0.88074499368667603f, 0.88952797651290894f, 0.89745801687240601f, 0.90461999177932739f, 0.91109001636505127f, 0.11949499696493149f, 0.18745699524879456f, 0.25997200608253479f, 0.33120998740196228f, 0.39773499965667725f, 0.45832300186157227f, 0.51248997449874878f, 0.56048798561096191f, 0.6028980016708374f, 0.64032697677612305f, 0.67339599132537842f, 0.70268499851226807f, 0.72870397567749023f, 0.75189602375030518f, 0.77263599634170532f, 0.7912449836730957f, 0.80796998739242554f, 0.82303100824356079f, 0.8366129994392395f, 0.84887397289276123f, 0.85994899272918701f, 0.86995697021484375f, 0.87900298833847046f, 0.88717901706695557f, 0.05942929908633232f, 0.10839699953794479f, 0.16785700619220734f, 0.23236599564552307f, 0.29767501354217529f, 0.36022999882698059f, 0.41842898726463318f, 0.47170799970626831f, 0.5198180079460144f, 0.56301301717758179f, 0.60171198844909668f, 0.63635998964309692f, 0.66739702224731445f, 0.69524997472763062f, 0.720287024974823f, 0.74283498525619507f, 0.76317602396011353f, 0.78155702352523804f, 0.79817098379135132f, 0.81319701671600342f, 0.8267899751663208f, 0.83908802270889282f, 0.85021400451660156f, 0.86027902364730835f, 0.02584660053253174f, 0.05619670078158379f, 0.09917669743299484f, 0.15162299573421478f, 0.20941600203514099f, 0.26902499794960022f, 0.32757499814033508f, 0.38318398594856262f, 0.43501600623130798f, 0.48271399736404419f, 0.52620798349380493f, 0.56570100784301758f, 0.60149699449539185f, 0.63392102718353271f, 0.66328197717666626f, 0.68988502025604248f, 0.7139970064163208f, 0.7358660101890564f, 0.75570398569107056f, 0.77369099855422974f, 0.78999698162078857f, 0.80477499961853027f, 0.81816202402114868f, 0.83028298616409302f, 0.00968609005212784f, 0.02591750025749207f, 0.05318830162286758f, 0.09121809899806976f, 0.13777700066566467f, 0.18976299464702606f, 0.244159996509552f, 0.29880800843238831f, 0.35169300436973572f, 0.40180501341819763f, 0.44872200489044189f, 0.49213200807571411f, 0.53206497430801392f, 0.5686650276184082f, 0.60214298963546753f, 0.63272500038146973f, 0.66062301397323608f, 0.68605399131774902f, 0.70922297239303589f, 0.73031198978424072f, 0.74948400259017944f, 0.76689702272415161f, 0.78270000219345093f, 0.79702901840209961f, 0.00303822988644242f, 0.01048239972442389f, 0.02568300068378448f, 0.05025380104780197f, 0.08408640325069427f, 0.12561400234699249f, 0.17249999940395355f, 0.22232000529766083f, 0.27309399843215942f, 0.32321798801422119f, 0.37149098515510559f, 0.4173240065574646f, 0.4603630006313324f, 0.50043797492980957f, 0.53755801916122437f, 0.57181298732757568f, 0.60333001613616943f, 0.63226902484893799f, 0.65877401828765869f, 0.68301999568939209f, 0.70514601469039917f, 0.7253040075302124f, 0.74363899230957031f, 0.76029098033905029f, 0.00076204299693927f, 0.00361976004205644f, 0.0110037000849843f, 0.02512970007956028f, 0.04727460071444511f, 0.07745999842882156f, 0.11460299789905548f, 0.1569570004940033f, 0.20258499681949615f, 0.24971699714660645f, 0.29707801342010498f, 0.34340900182723999f, 0.38799500465393066f, 0.43043500185012817f, 0.47039699554443359f, 0.50777101516723633f, 0.54253697395324707f, 0.57473397254943848f, 0.60444700717926025f, 0.63179397583007812f, 0.65686798095703125f, 0.67979699373245239f, 0.70071202516555786f, 0.71974599361419678f, 0.00014345299859997f, 0.00102306995540857f, 0.00407376000657678f, 0.01122699957340956f, 0.02423799969255924f, 0.04415180161595345f, 0.07109060138463974f, 0.10433399677276611f, 0.14259399473667145f, 0.184347003698349f, 0.2281080037355423f, 0.27265200018882751f, 0.31696400046348572f, 0.36016398668289185f, 0.40178799629211426f, 0.44139501452445984f, 0.47875601053237915f, 0.51375597715377808f, 0.54635101556777954f, 0.57658302783966064f, 0.60447400808334351f, 0.63009101152420044f, 0.65352898836135864f, 0.67488902807235718f, 0.00001858420000644f, 0.0002227969962405f, 0.00124967005103827f, 0.00435766018927097f, 0.01113030035048723f, 0.0229835007339716f, 0.04079980030655861f, 0.06477940082550049f, 0.09447769820690155f, 0.12897300720214844f, 0.16708999872207642f, 0.20760199427604675f, 0.24936899542808533f, 0.29154899716377258f, 0.3332040011882782f, 0.37377101182937622f, 0.41274300217628479f, 0.44977998733520508f, 0.4846780002117157f, 0.51733100414276123f, 0.54769200086593628f, 0.57572799921035767f, 0.6014779806137085f, 0.62501102685928345f, 1.46482000218384201e-06f, 0.00003429050047998f, 0.0002985020109918f, 0.00140504003502429f, 0.00443577999249101f, 0.01069260016083717f, 0.02133879996836185f, 0.0371410995721817f, 0.05836030095815659f, 0.08476380258798599f, 0.11572299897670746f, 0.1503559947013855f, 0.18766500055789948f, 0.22665500640869141f, 0.26647698879241943f, 0.30632400512695312f, 0.34550899267196655f, 0.38344401121139526f, 0.41970700025558472f, 0.45401400327682495f, 0.48618701100349426f, 0.51614201068878174f, 0.54384201765060425f, 0.56930899620056152f, 5.83937982412408019e-08f, 3.2765999549155822e-06f, 0.00005055400106357f, 0.00035111699253321f, 0.00145683996379375f, 0.00427943980321288f, 0.0098936902359128f, 0.01927389949560165f, 0.03310279920697212f, 0.05168719962239265f, 0.07495570182800293f, 0.10250899940729141f, 0.13370099663734436f, 0.1677280068397522f, 0.20372100174427032f, 0.24084299802780151f, 0.27840098738670349f, 0.31564199924468994f, 0.35190799832344055f, 0.38674798607826233f, 0.41985601186752319f, 0.45104199647903442f, 0.48021000623703003f, 0.50734001398086548f, 8.73966010672688753e-10f, 1.57741993689342053e-07f, 5.21975016454234719e-06f, 0.00006079579907237f, 0.00036219600588083f, 0.00138045998755842f, 0.00386844994500279f, 0.00871635042130947f, 0.01675550080835819f, 0.02860799990594387f, 0.04461279883980751f, 0.06480839848518372f, 0.08895269781351089f, 0.11656700074672699f, 0.1470009982585907f, 0.17950700223445892f, 0.21331800520420074f, 0.24785000085830688f, 0.28237700462341309f, 0.31631898880004883f, 0.34923198819160461f, 0.38083100318908691f, 0.41094100475311279f, 0.43946701288223267f, 2.8866399288257627e-12f, 2.63671995348602195e-09f, 2.51094007808205788e-07f, 5.97520011069718748e-06f, 0.00005859580051037f, 0.0003192939911969f, 0.00116373994387686f, 0.00319523992948234f, 0.00714873988181353f, 0.0137449000030756f, 0.0235638003796339f, 0.03696820139884949f, 0.05407309904694557f, 0.0747511014342308f, 0.09866459667682648f, 0.12531900405883789f, 0.15412400662899017f, 0.18446199595928192f, 0.21573600172996521f, 0.24741099774837494f, 0.27903899550437927f, 0.310263991355896f, 0.34082499146461487f, 0.37054198980331421f, 6.94488983838260476e-16f, 7.04290011727115584e-12f, 3.21448001550095341e-09f, 2.20180993437679717e-07f, 4.50593006462440826e-06f, 0.00004154839916737f, 0.00022262999846134f, 0.00081575999502093f, 0.00227530999109149f, 0.00519366981461644f, 0.01020010001957417f, 0.0178545992821455f, 0.02856850065290928f, 0.04256030172109604f, 0.05984469875693321f, 0.08025020360946655f, 0.10345599800348282f, 0.12904399633407593f, 0.15654699504375458f, 0.1854960024356842f, 0.21545499563217163f, 0.24603499472141266f, 0.27690801024436951f, 0.3078019917011261f, 5.46278023199234311e-22f, 3.43167987041791307e-16f, 2.29294990113093622e-12f, 9.57796952860689998e-10f, 6.87986982939037262e-08f, 1.5533599935224629e-06f, 0.00001600819996384f, 0.00009555240103509f, 0.00038631301140413f, 0.00117554003372788f, 0.00289549003355205f, 0.00607588002458215f, 0.01126710046082735f, 0.01896269991993904f, 0.02954130060970783f, 0.04323289915919304f, 0.06011129915714264f, 0.0801049992442131f, 0.10301999747753143f, 0.12857000529766083f, 0.15640300512313843f, 0.18612800538539886f, 0.21734000742435455f, 0.24963200092315674f, 0.0f, 0.0f, 3.09890004335006815e-24f, 2.21276004416278673e-18f, 2.67358004631774657e-14f, 2.24439997836833882e-11f, 3.13075010360819306e-09f, 1.26480998119404831e-07f, 2.12951999856159091e-06f, 0.00001907769910758f, 0.00010753999958979f, 0.00042892698547803f, 0.00131604995112866f, 0.00330013991333544f, 0.00707077002152801f, 0.01337909977883101f, 0.02291939966380596f, 0.03622379899024963f, 0.05359359830617905f, 0.07507230341434479f, 0.10045900195837021f, 0.12935000658035278f, 0.16119599342346191f, 0.19536399841308594f
} };
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

static __device__ ViewTerms ViewTerms_x24init_0(float3  v_1, float3  n_i_1, AnisotropicFrame * frame_0, float3  scale_1, float sheen_component_0, float3  sheen_0, float3  view_0, float3  rebounce_0, float toon_view_0, float3  toon_axis_0)
{
    ViewTerms _S362;
    (&_S362)->v = v_1;
    (&_S362)->n_i = n_i_1;
    (&_S362)->frame = *frame_0;
    (&_S362)->scale = scale_1;
    (&_S362)->sheen_component = sheen_component_0;
    (&_S362)->sheen = sheen_0;
    (&_S362)->view = view_0;
    (&_S362)->rebounce = rebounce_0;
    (&_S362)->toon_view = toon_view_0;
    (&_S362)->toon_axis = toon_axis_0;
    return _S362;
}

__device__ __forceinline__ ViewTerms precomputeView(float3  in_dir_0, float3  n_2, BSDFMaterial material_3, MaterialTerms terms_0)
{
    float3  _S363 = negate_0(in_dir_0);
    float _S364 = sign_0(dot_0(n_2, _S363));
    float3  _S365 = n_2 * make_float3 (_S364);
    AnisotropicFrame _S366 = anisotropicFrame(material_3, _S365);
    float3  _S367 = make_float3 (1.0f);
    float3  _S368 = make_float3 (0.0f);
    float _S369 = rgb_to_greyscale(material_3.sheen);
    bool _S370 = _S369 > 0.0f;
    float sheen_component_1;
    float3  sheen_1;
    float3  view_1;
    float3  scale_2;
    if(_S370)
    {
        float _S371 = clamp_1((F32_sqrt(((F32_max((dot_0(_S365, _S363)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S372 = (U32_min((uint(_S371)), (22U)));
        float least_0 = (F32_sqrt((0.05000000074505806f)));
        float _S373 = (F32_sqrt((0.10000000149011612f)));
        bool _S374 = (material_3.velvet) > 0.0f;
        float _S375 = _slang_select(_S374, _S373,least_0);
        float _S376 = (clamp_1((F32_sqrt(((F32_max((material_3.sheen_roughness), (0.0f)))))), _S375, 1.0f) - _S375) / (1.0f - _S375) * 23.0f;
        uint _S377 = (U32_min((uint(_S376)), (22U)));
        uint _S378 = _S372 * 24U + _S377;
        float _S379 = _S371 - float(_S372);
        float _S380 = _S376 - float(_S377);
        uint _S381 = _S378 + 24U;
        float a_3 = SHEEN_ALBEDO_0[_S378] + (SHEEN_ALBEDO_0[_S381] - SHEEN_ALBEDO_0[_S378]) * _S379;
        uint _S382 = _S378 + 1U;
        uint _S383 = _S381 + 1U;
        float b_1 = SHEEN_ALBEDO_0[_S382] + (SHEEN_ALBEDO_0[_S383] - SHEEN_ALBEDO_0[_S382]) * _S379;
        float _S384 = (F32_exp((a_3 + (b_1 - a_3) * _S380)));
        if(_S374)
        {
            float a_4 = VELVET_ALBEDO_0[_S378] + (VELVET_ALBEDO_0[_S381] - VELVET_ALBEDO_0[_S378]) * _S379;
            float b_2 = VELVET_ALBEDO_0[_S382] + (VELVET_ALBEDO_0[_S383] - VELVET_ALBEDO_0[_S382]) * _S379;
            float _S385 = a_4 + (b_2 - a_4) * _S380;
            sheen_component_1 = _S385;
        }
        else
        {
            sheen_component_1 = _S384;
        }
        float _S386 = (F32_min((sheen_component_1), (1.0f)));
        float3  _S387 = make_float3 (1.0f) - material_3.sheen * make_float3 (_S386);
        float _S388 = rgb_to_greyscale(material_3.sheen);
        float _S389 = _S388 * _S386;
        float3  _S390 = material_3.sheen / make_float3 ((F32_max((sheen_component_1), (1.0f))));
        sheen_component_1 = _S389;
        sheen_1 = _S390;
        view_1 = _S363;
        scale_2 = _S387;
    }
    else
    {
        sheen_component_1 = 0.0f;
        sheen_1 = _S368;
        view_1 = _S368;
        scale_2 = _S367;
    }
    float3  scale_3 = scale_2 * make_float3 (terms_0.toon_scale);
    bool _S391 = (F32_abs((material_3.toon.x))) > 0.0f;
    float toon_view_1;
    float3  toon_axis_1;
    if(_S391)
    {
        float _S392 = dot_0(_S365, _S363);
        float _S393 = (F32_acos(((F32_min((_S392), (1.0f))))));
        if(_S393 < (terms_0.toon_a))
        {
            toon_view_1 = 1.0f;
        }
        else
        {
            toon_view_1 = (F32_max((1.0f - (_S393 - terms_0.toon_a) / (F32_max((terms_0.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        if(terms_0.toon_glossy)
        {
            float3  _S394 = make_float3 (2.0f * _S392) * _S365 - _S363;
            float3  _S395 = ((((_S394)) * make_float3(rnorm3df(((_S394)).x, ((_S394)).y, ((_S394)).z))));
            scale_2 = _S395;
        }
        else
        {
            scale_2 = _S365;
        }
        toon_axis_1 = scale_2;
    }
    else
    {
        toon_view_1 = 0.0f;
        toon_axis_1 = _S365;
    }
    float _S396 = _S366.alphas.x;
    float _S397 = (F32_sqrt(((F32_min((_S396), (_S366.alphas.y))))));
    bool _S398 = _S396 > 0.0f;
    float _S399 = _slang_select(_S398, _S397,material_3.roughness);
    float _S400 = _S399 * _S399;
    float _S401 = (F32_pow((_S400), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S400) / (1.0f + 1.28094995021820068f * _S400);
    bool _S402 = _S400 > 0.0f;
    float _S403 = _slang_select(_S402, _S401,0.0f);
    float _S404 = clamp_1(dot_0(_S365, _S363), 0.0f, 1.0f);
    float _S405 = _S400 * _S399;
    float _S406 = (F32_min((1.00064504146575928f - _S399 * (0.00375499995425344f + _S404 * (-0.04133399948477745f + _S404 * (-0.90938502550125122f + _S404 * 0.35275399684906006f))) - _S400 * (0.27602800726890564f + _S404 * (1.27023398876190186f + _S404 * 0.04740000143647194f)) - _S405 * (0.31452900171279907f - _S404 * 0.34830701351165771f) + _S405 * _S399 * 0.27229699492454529f), (1.0f)));
    float3  _S407 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_3.albedo * make_float3 (_S403)), make_float3 (1.0f / (F32_max((_S406), (0.0000152587890625f)))));
    AnisotropicFrame _S408 = _S366;
    ViewTerms _S409 = ViewTerms_x24init_0(_S363, _S365, &_S408, scale_3, sheen_component_1, sheen_1, view_1, _S407, toon_view_1, toon_axis_1);
    return _S409;
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

__device__ float3  anisotropicLocal(float3  w_0, float3  t_12, float3  n_3)
{
    return make_float3 (dot_0(w_0, t_12), dot_0(w_0, cross_0(n_3, t_12)), dot_0(w_0, n_3));
}

static __device__ float unshared_0(float x_15)
{
    return x_15;
}

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_0, float U1_0, float U2_0)
{
    float3  _S410 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S411 = ((((_S410)) * make_float3(rnorm3df(((_S410)).x, ((_S410)).y, ((_S410)).z))));
    float _S412 = _S411.x;
    float _S413 = _S411.y;
    float _S414 = _S412 * _S412 + _S413 * _S413;
    float3  _S415;
    if(_S414 > 0.0f)
    {
        float3  _S416 = make_float3 (- _S413, _S412, 0.0f);
        float _S417 = (rsqrtf((_S414)));
        _S415 = _S416 * make_float3 (_S417);
    }
    else
    {
        _S415 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S418 = cross_0(_S411, _S415);
    float _S419 = (F32_sqrt((U1_0)));
    float _S420 = 6.28318548202514648f * U2_0;
    float _S421 = _S419 * (F32_cos((_S420)));
    float t2_0 = _S419 * (F32_sin((_S420)));
    float _S422 = 0.5f * (1.0f + _S411.z);
    float t2_1 = (1.0f - _S422) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S421 * _S421)))))) + _S422 * t2_0;
    float3  _S423 = make_float3 (_S421) * _S415 + make_float3 (t2_1) * _S418;
    float _S424 = unshared_0(_S421);
    float _S425 = unshared_0(_S421);
    float3  _S426 = _S423 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S424 * _S425 - t2_1 * t2_1))))))) * _S411;
    float3  _S427 = make_float3 (alpha_0 * _S426.x, alpha_0 * _S426.y, (F32_max((0.0f), (_S426.z))));
    float3  _S428 = ((((_S427)) * make_float3(rnorm3df(((_S427)).x, ((_S427)).y, ((_S427)).z))));
    return _S428;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_4)
{
    float3  a_5 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S429 = (F32_abs((dot_0(n_4, a_5)))) > 0.9999847412109375f;
    float3  a_6;
    if(_S429)
    {
        float3  _S430 = make_float3 (1.0f, 0.0f, 0.0f);
        a_6 = _S430;
    }
    else
    {
        a_6 = a_5;
    }
    float3  _S431 = cross_0(n_4, a_6);
    float3  _S432 = ((((_S431)) * make_float3(rnorm3df(((_S431)).x, ((_S431)).y, ((_S431)).z))));
    float3  _S433 = cross_0(n_4, _S432);
    return make_float3 (dot_0(v_2, _S432), dot_0(v_2, n_4), dot_0(v_2, _S433));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_1, uint * random_state_2)
{
    Random _S434 = pcg(*random_state_2);
    Random _S435 = pcg(_S434.state);
    *random_state_2 = _S435.state;
    float _S436 = frame_1.alphas.x;
    bool _S437 = _S436 > 0.0f;
    if(_S437)
    {
        float3  _S438 = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        float _S439 = frame_1.alphas.y;
        float3  _S440 = make_float3 (_S436 * _S438.x, _S439 * _S438.y, _S438.z);
        float3  _S441 = ((((_S440)) * make_float3(rnorm3df(((_S440)).x, ((_S440)).y, ((_S440)).z))));
        float3  _S442 = sampleGGXVNDF(_S441, 1.0f, _S434.value, _S435.value);
        float3  _S443 = make_float3 (_S436 * _S442.x, _S439 * _S442.y, _S442.z);
        float3  _S444 = ((((_S443)) * make_float3(rnorm3df(((_S443)).x, ((_S443)).y, ((_S443)).z))));
        return make_float3 (_S444.x) * frame_1.tangent + make_float3 (_S444.y) * cross_0(n_i_2, frame_1.tangent) + make_float3 (_S444.z) * n_i_2;
    }
    float3  _S445 = worldToTangent(v_3, n_i_2);
    float3  _S446 = sampleGGXVNDF(float3 {_S445.x, _S445.z, _S445.y}, alpha_1, _S434.value, _S435.value);
    float3  _S447 = float3 {_S446.x, _S446.z, _S446.y};
    float3  _S448 = tangentToWorld(_S447, n_i_2);
    return _S448;
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

static __device__ float3  refract_0(float3  i_6, float3  n_5, float eta_0)
{
    float _S449 = dot_0(n_5, i_6);
    float _S450 = 1.0f - eta_0 * eta_0 * (1.0f - _S449 * _S449);
    if(_S450 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_6 - make_float3 (eta_0 * _S449 + (F32_sqrt((_S450)))) * n_5;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S451 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S452 = eta_i_1 / eta_o_1 * _S451;
    bool _S453 = _S452 < 1.0f;
    float kr_0;
    if(_S453)
    {
        float _S454 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S452 * _S452))))));
        float _S455 = eta_o_1 * cos_theta_0;
        float _S456 = eta_i_1 * _S454;
        float _S457 = (_S455 - _S456) / (_S455 + _S456);
        float _S458 = eta_i_1 * cos_theta_0;
        float _S459 = eta_o_1 * _S454;
        float _S460 = (_S458 - _S459) / (_S458 + _S459);
        float _S461 = (_S457 * _S457 + _S460 * _S460) / 2.0f;
        kr_0 = _S461;
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
    float _S462 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S462 / (_S462 + length_0(make_float3 (alphas_1.x * w_1.x, alphas_1.y * w_1.y, _S462)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S463 = alphas_2.x;
    float _S464 = h_0.x / _S463;
    float _S465 = alphas_2.y;
    float _S466 = h_0.y / _S465;
    float _S467 = h_0.z;
    float _S468 = _S464 * _S464 + _S466 * _S466 + _S467 * _S467;
    return 1.0f / (F32_max((3.14159274101257324f * _S463 * _S465 * _S468 * _S468), (1.17549435082228751e-38f)));
}

static __device__ HalfTerms HalfTerms_x24init_0(float v_dot_h_0, float n_dot_h_0, float3  refracted_1, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_1, float3  sheen_2, float p_sheen_velvet_0, float3  view_2, float3  tangent_1, float2  alphas_3, float visible_0, float p_toon_0, float3  toon_2, float toon_a_3, float toon_s_3, float toon_b_2, bool toon_glossy_1, float toon_norm_2, float toon_view_2, float3  toon_axis_2)
{
    HalfTerms _S469;
    (&_S469)->v_dot_h = v_dot_h_0;
    (&_S469)->n_dot_h = n_dot_h_0;
    (&_S469)->refracted = refracted_1;
    (&_S469)->F = F_0;
    (&_S469)->F_greyscale = F_greyscale_0;
    (&_S469)->reflect_weight = reflect_weight_0;
    (&_S469)->diffuse_weight = diffuse_weight_0;
    (&_S469)->refract_weight = refract_weight_0;
    (&_S469)->p_diffuse = p_diffuse_0;
    (&_S469)->p_reflect = p_reflect_0;
    (&_S469)->p_refract = p_refract_0;
    (&_S469)->translucent_share = translucent_share_1;
    (&_S469)->sheen = sheen_2;
    (&_S469)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S469)->view = view_2;
    (&_S469)->tangent = tangent_1;
    (&_S469)->alphas = alphas_3;
    (&_S469)->visible = visible_0;
    (&_S469)->p_toon = p_toon_0;
    (&_S469)->toon = toon_2;
    (&_S469)->toon_a = toon_a_3;
    (&_S469)->toon_s = toon_s_3;
    (&_S469)->toon_b = toon_b_2;
    (&_S469)->toon_glossy = toon_glossy_1;
    (&_S469)->toon_norm = toon_norm_2;
    (&_S469)->toon_view = toon_view_2;
    (&_S469)->toon_axis = toon_axis_2;
    return _S469;
}

__device__ __forceinline__ HalfTerms precomputeHalf(float3  in_dir_1, float3  ggx_n_0, BSDFMaterial material_4, float eta_i_2, float eta_o_2, MaterialTerms terms_1, ViewTerms view_terms_0)
{
    float _S470 = dot_0(ggx_n_0, view_terms_0.v);
    float _S471 = dot_0(view_terms_0.n_i, ggx_n_0);
    float _S472 = eta_i_2 / eta_o_2;
    float3  _S473 = refract_0(in_dir_1, ggx_n_0, _S472);
    float3  _S474 = ((((_S473)) * make_float3(rnorm3df(((_S473)).x, ((_S473)).y, ((_S473)).z))));
    float _S475 = (F32_abs((_S470)));
    bool _S476 = eta_i_2 > eta_o_2;
    float visible_1;
    if(_S476)
    {
        visible_1 = terms_1.eta_level;
    }
    else
    {
        visible_1 = 1.0f;
    }
    float _S477;
    if(_S476)
    {
        _S477 = 1.0f;
    }
    else
    {
        _S477 = terms_1.eta_level;
    }
    float _S478 = fresnel(_S475, visible_1, _S477);
    bool _S479 = (eta_i_2 * eta_i_2 * (1.0f - _S470 * _S470)) >= (eta_o_2 * eta_o_2);
    float3  _S480;
    if(_S479)
    {
        _S480 = make_float3 (1.0f);
    }
    else
    {
        float3  _S481 = material_4.specular_tint * make_float3 (terms_1.f0);
        _S480 = _S481 + (make_float3 (1.0f) - _S481) * make_float3 (_S478 - terms_1.f0) / make_float3 (1.0f - terms_1.f0);
    }
    float3  _S482 = mix_0(_S480, material_4.albedo * view_terms_0.rebounce, material_4.metallic);
    float3  F_1 = _S482 * view_terms_0.scale;
    float _S483 = rgb_to_greyscale(F_1);
    float _S484 = 1.0f - material_4.metallic;
    float3  _S485 = make_float3 (1.0f) - _S480;
    float3  _S486 = make_float3 ((1.0f - material_4.transmission) * _S484) * _S485 * view_terms_0.scale;
    float3  _S487 = make_float3 (material_4.transmission * _S484) * _S485 * view_terms_0.scale;
    float _S488 = (F32_max((_S483), (0.0f)));
    float _S489 = rgb_to_greyscale(_S486);
    float _S490 = (F32_max((_S489), (0.0f)));
    float _S491 = rgb_to_greyscale(_S487);
    float _S492 = sign_0(length_0(_S474));
    float _S493 = (F32_max((_S491 * _S492), (0.0f)));
    float _S494 = _S488 + _S490 + _S493 + terms_1.toon_component;
    float _S495 = (F32_min((view_terms_0.sheen_component), (1.0f)));
    bool _S496 = (view_terms_0.sheen_component) > 0.0f;
    bool _S497;
    if(_S496)
    {
        _S497 = !(_S494 > 0.0f);
    }
    else
    {
        _S497 = false;
    }
    float _S498 = _slang_select(_S497, 1.0f,_S495);
    float _S499 = (1.0f - _S498) / (F32_max((_S494), (0.0000152587890625f)));
    float _S500 = _S490 * _S499;
    float _S501 = _S488 * _S499;
    float _S502 = _S493 * _S499;
    bool _S503 = (view_terms_0.frame.alphas.x) > 0.0f;
    if(_S503)
    {
        float3  _S504 = anisotropicLocal(view_terms_0.v, view_terms_0.frame.tangent, view_terms_0.n_i);
        float _S505 = anisotropicG1(_S504, view_terms_0.frame.alphas);
        float3  _S506 = anisotropicLocal(ggx_n_0, view_terms_0.frame.tangent, view_terms_0.n_i);
        float _S507 = anisotropicD(_S506, view_terms_0.frame.alphas);
        float _S508 = _S505 * _S507;
        visible_1 = _S508;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return HalfTerms_x24init_0(_S470, _S471, _S474, F_1, _S483, 1.0f, _S486, _S487, _S500, _S501, _S502, terms_1.translucent_share, view_terms_0.sheen, _S498, view_terms_0.view, view_terms_0.frame.tangent, view_terms_0.frame.alphas, visible_1, terms_1.toon_component * _S499, terms_1.toon, terms_1.toon_a, terms_1.toon_s, terms_1.toon_b, terms_1.toon_glossy, terms_1.toon_norm, view_terms_0.toon_view, view_terms_0.toon_axis);
}

__device__ float smithG1(float alpha_2, float n_dot_x_0)
{
    float _S509 = alpha_2 * alpha_2;
    float _S510 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S509 + (1.0f - _S509) * n_dot_x_0 * n_dot_x_0))));
    bool _S511 = alpha_2 > 0.0f;
    float _S512 = _slang_select(_S511, _S510,1.0f);
    return _S512;
}

__device__ float trowbridgeReitz(float alpha_3, float n_dot_h_1)
{
    float _S513 = alpha_3 * alpha_3;
    float _S514 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S513 * n_dot_h_1 * n_dot_h_1;
    return _S513 / (F32_max((3.14159274101257324f * _S514 * _S514), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, HalfTerms lobes_0, float eta_i_3, float eta_o_3, uint lobe_0)
{
    bool _S515 = lobe_0 == 0U;
    if(_S515)
    {
        float _S516 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        float _S517 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
        float _S518 = 1.0f - lobes_0.translucent_share;
        bool _S519 = n_i_dot_l_0 < 0.0f;
        float _S520 = _slang_select(_S519, lobes_0.translucent_share,_S518);
        float _S521 = _S517 * _S520;
        bool _S522 = (lobes_0.translucent_share) > 0.0f;
        float _S523 = _slang_select(_S522, _S521,_S516);
        bool _S524 = n_i_dot_v_0 > 0.0f;
        float _S525 = _slang_select(_S524, _S523,0.0f);
        return _S525;
    }
    bool _S526 = lobe_0 == 4U;
    bool _S527;
    if(_S526)
    {
        float _S528 = lobes_0.p_sheen_velvet * 0.5f * 0.31830987334251404f;
        bool _S529 = n_i_dot_l_0 > 0.0f;
        if(_S529)
        {
            _S527 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S527 = false;
        }
        float _S530 = _slang_select(_S527, _S528,0.0f);
        return _S530;
    }
    bool _S531 = lobe_0 == 6U;
    float pdf_h_0;
    if(_S531)
    {
        float _S532 = _slang_select(lobes_0.toon_glossy, l_dot_h_0,n_i_dot_l_0);
        float _S533 = (F32_acos((clamp_1(_S532, -1.0f, 1.0f))));
        if(_S533 < (lobes_0.toon_a))
        {
            pdf_h_0 = 1.0f;
        }
        else
        {
            pdf_h_0 = (F32_max((1.0f - (_S533 - lobes_0.toon_a) / (F32_max((lobes_0.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float _S534 = lobes_0.p_toon * pdf_h_0;
        float _S535 = _slang_select(lobes_0.toon_glossy, 1.0f,n_i_dot_l_0);
        float _S536 = _S534 * _S535 / lobes_0.toon_norm;
        if(lobes_0.toon_glossy)
        {
            _S527 = true;
        }
        else
        {
            _S527 = n_i_dot_l_0 > 0.0f;
        }
        float _S537 = _slang_select(_S527, _S536,0.0f);
        return _S537;
    }
    float _S538 = smithG1(alpha_4, n_i_dot_v_0);
    float _S539 = _S538 * lobes_0.v_dot_h;
    float _S540 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    float _S541 = _S539 * _S540 / n_i_dot_v_0;
    bool _S542 = alpha_4 > 0.0f;
    if(_S542)
    {
        _S527 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S527 = false;
    }
    if(_S527)
    {
        _S527 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S527 = false;
    }
    if(_S527)
    {
        _S527 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S527 = false;
    }
    float _S543 = _slang_select(_S527, _S541,0.0f);
    bool _S544 = (lobes_0.alphas.x) > 0.0f;
    if(_S544)
    {
        float _S545 = lobes_0.visible * lobes_0.v_dot_h / n_i_dot_v_0;
        bool _S546 = (lobes_0.v_dot_h) > 0.0f;
        if(_S546)
        {
            _S527 = (lobes_0.n_dot_h) > 0.0f;
        }
        else
        {
            _S527 = false;
        }
        if(_S527)
        {
            _S527 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S527 = false;
        }
        float _S547 = _slang_select(_S527, _S545,0.0f);
        pdf_h_0 = _S547;
    }
    else
    {
        pdf_h_0 = _S543;
    }
    bool _S548 = lobe_0 == 1U;
    if(_S548)
    {
        float _S549 = eta_i_3 * lobes_0.v_dot_h + eta_o_3 * l_dot_h_0;
        float _S550 = lobes_0.p_refract * pdf_h_0 * eta_o_3 * eta_o_3 * (F32_abs((l_dot_h_0))) / (_S549 * _S549);
        bool _S551 = eta_i_3 != eta_o_3;
        if(_S551)
        {
            _S527 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S527 = false;
        }
        float _S552 = _slang_select(_S527, _S550,0.0f);
        return _S552;
    }
    float _S553 = lobes_0.p_reflect * pdf_h_0 / (4.0f * lobes_0.v_dot_h);
    bool _S554 = pdf_h_0 > 0.0f;
    float _S555 = _slang_select(_S554, _S553,0.0f);
    return _S555;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_0, uint random_state_3, bool refracted_2, uint lobe_1, float pdf_0)
{
    SampleBSDF _S556;
    (&_S556)->unit_direction = unit_direction_1;
    (&_S556)->throughput = throughput_0;
    (&_S556)->random_state = random_state_3;
    (&_S556)->refracted = refracted_2;
    (&_S556)->lobe = lobe_1;
    (&_S556)->pdf = pdf_0;
    return _S556;
}

__device__ __forceinline__ float3  lobeThroughput(float3  l_0, float3  n_i_3, float alpha_5, BSDFMaterial material_5, HalfTerms lobes_1, uint lobe_2)
{
    bool _S557 = lobe_2 == 0U;
    if(_S557)
    {
        bool _S558 = (dot_0(n_i_3, l_0)) < 0.0f;
        float3  _S559 = _slang_select(_S558, material_5.translucent,material_5.albedo);
        float _S560 = 1.0f - lobes_1.translucent_share;
        float _S561 = _slang_select(_S558, lobes_1.translucent_share,_S560);
        float3  _S562 = _S559 / make_float3 (_S561);
        bool _S563 = (lobes_1.translucent_share) > 0.0f;
        float3  _S564 = _slang_select(_S563, _S562,material_5.albedo);
        return lobes_1.diffuse_weight * _S564 / make_float3 (lobes_1.p_diffuse);
    }
    bool _S565 = lobe_2 == 4U;
    float f_1;
    if(_S565)
    {
        float3  _S566 = l_0 + lobes_1.view;
        float3  _S567 = ((((_S566)) * make_float3(rnorm3df(((_S566)).x, ((_S566)).y, ((_S566)).z))));
        float _S568 = dot_0(n_i_3, _S567);
        float _S569 = (F32_max((dot_0(n_i_3, l_0)), (0.0f)));
        float _S570 = (F32_max((dot_0(n_i_3, lobes_1.view)), (0.0f)));
        float _S571 = 1.0f / (F32_max((material_5.sheen_roughness), (0.05000000074505806f)));
        float _S572 = 1.0f - _S568 * _S568;
        float _S573 = (2.0f + _S571) * (F32_pow(((F32_max((_S572), (0.0f)))), (0.5f * _S571))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S569 + _S570 - _S569 * _S570)), (0.0000152587890625f)));
        bool _S574 = (material_5.velvet) > 0.0f;
        if(_S574)
        {
            float _S575 = (F32_max((material_5.sheen_roughness), (0.00999999977648258f)));
            float _S576 = _S575 * _S575;
            float _S577 = (F32_max((_S572), (0.0000152587890625f)));
            float _S578 = (F32_exp((- _S568 * _S568 / (_S577 * _S576)))) / (3.14159274101257324f * _S576 * _S577 * _S577) * (F32_min((1.0f), (2.0f * _S568 * (F32_min((_S569), (_S570))) / (F32_max(((F32_abs((dot_0(_S567, lobes_1.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S569 * _S570), (0.0000152587890625f)));
            f_1 = _S578;
        }
        else
        {
            f_1 = _S573;
        }
        return lobes_1.sheen * make_float3 (f_1 * _S569 * 2.0f * 3.14159274101257324f / lobes_1.p_sheen_velvet);
    }
    bool _S579 = lobe_2 == 6U;
    if(_S579)
    {
        float _S580 = (F32_max((dot_0(n_i_3, l_0)), (0.0f)));
        float _S581 = _slang_select(lobes_1.toon_glossy, _S580,lobes_1.toon_view);
        return lobes_1.toon * make_float3 (_S581) / make_float3 (lobes_1.p_toon);
    }
    bool _S582 = lobe_2 == 1U;
    if(_S582)
    {
        float _S583 = - dot_0(n_i_3, l_0);
        float _S584 = smithG1(alpha_5, (F32_max((_S583), (0.0f))));
        bool _S585 = (lobes_1.alphas.x) > 0.0f;
        if(_S585)
        {
            float3  _S586 = negate_0(n_i_3);
            float3  _S587 = anisotropicLocal(l_0, lobes_1.tangent, _S586);
            float _S588 = anisotropicG1(_S587, lobes_1.alphas);
            f_1 = _S588;
        }
        else
        {
            f_1 = _S584;
        }
        return lobes_1.refract_weight * make_float3 (f_1) * material_5.albedo / make_float3 (lobes_1.p_refract);
    }
    float _S589 = dot_0(n_i_3, l_0);
    float _S590 = smithG1(alpha_5, (F32_max((_S589), (0.0f))));
    bool _S591 = (lobes_1.alphas.x) > 0.0f;
    if(_S591)
    {
        float3  _S592 = anisotropicLocal(l_0, lobes_1.tangent, n_i_3);
        float _S593 = anisotropicG1(_S592, lobes_1.alphas);
        f_1 = _S593;
    }
    else
    {
        f_1 = _S590;
    }
    return make_float3 (lobes_1.reflect_weight * f_1) * lobes_1.F / make_float3 (lobes_1.p_reflect);
}

__device__ __forceinline__ SampleBSDF lobeBSDF(float3  in_dir_2, float3  out_dir_0, float3  n_6, BSDFMaterial material_6, float eta_i_4, float eta_o_4, uint lobe_3, uint random_init_0, MaterialTerms terms_2, ViewTerms view_terms_1)
{
    uint random_state_4 = random_init_0;
    float3  _S594 = negate_0(in_dir_2);
    float _S595 = dot_0(n_6, _S594);
    float _S596 = sign_0(_S595);
    float3  _S597 = n_6 * make_float3 (_S596);
    float _S598 = material_6.roughness;
    float _S599 = _S598 * _S598;
    float3  _S600 = _S594 + out_dir_0;
    float3  ggx_n_1 = ((((_S600)) * make_float3(rnorm3df(((_S600)).x, ((_S600)).y, ((_S600)).z))));
    float _S601 = dot_0(out_dir_0, ggx_n_1);
    bool _S602 = lobe_3 == 0U;
    float3  ggx_n_2;
    if(_S602)
    {
        float3  _S603 = sampleHalfVector(_S594, _S597, _S599, view_terms_1.frame, &random_state_4);
        ggx_n_2 = _S603;
    }
    else
    {
        ggx_n_2 = ggx_n_1;
    }
    bool _S604 = lobe_3 == 1U;
    float l_dot_h_1;
    if(_S604)
    {
        float3  _S605 = negate_0(make_float3 (eta_i_4) * _S594 + make_float3 (eta_o_4) * out_dir_0);
        float3  _S606 = ((((_S605)) * make_float3(rnorm3df(((_S605)).x, ((_S605)).y, ((_S605)).z))));
        float _S607 = sign_0(dot_0(_S605, _S597));
        float3  ggx_n_3 = _S606 * make_float3 (_S607);
        float _S608 = dot_0(out_dir_0, ggx_n_3);
        ggx_n_2 = ggx_n_3;
        l_dot_h_1 = _S608;
    }
    else
    {
        l_dot_h_1 = _S601;
    }
    bool _S609 = lobe_3 == 2U;
    if(_S609)
    {
        float3  _S610 = ((((_S600)) * make_float3(rnorm3df(((_S600)).x, ((_S600)).y, ((_S600)).z))));
        ggx_n_2 = _S610;
    }
    bool _S611 = lobe_3 == 4U;
    if(_S611)
    {
        float3  _S612 = ((((_S600)) * make_float3(rnorm3df(((_S600)).x, ((_S600)).y, ((_S600)).z))));
        ggx_n_2 = _S612;
    }
    bool _S613 = lobe_3 == 6U;
    if(_S613)
    {
        float3  _S614 = sampleHalfVector(_S594, _S597, _S599, view_terms_1.frame, &random_state_4);
        float _S615 = dot_0(out_dir_0, view_terms_1.toon_axis);
        ggx_n_2 = _S614;
        l_dot_h_1 = _S615;
    }
    HalfTerms _S616 = precomputeHalf(in_dir_2, ggx_n_2, material_6, eta_i_4, eta_o_4, terms_2, view_terms_1);
    float _S617 = lobeDensity(dot_0(_S597, out_dir_0), l_dot_h_1, (F32_abs((_S595))), _S599, _S616, eta_i_4, eta_o_4, lobe_3);
    bool _S618 = !(_S617 > 0.0f);
    if(_S618)
    {
        float3  _S619 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S619, _S619, 0U, false, 0U, 0.0f);
    }
    float3  _S620 = lobeThroughput(out_dir_0, _S597, _S599, material_6, _S616, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S620, random_state_4, _S604, lobe_3, _S617);
}

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_3, float3  dir_3, float3  n_7, BSDFMaterial material_7, float eta_i_5, float eta_o_5, bool refracted_3, float pdf_1, bool power_0, uint random_state_5, MaterialTerms terms_3, ViewTerms view_terms_2)
{
    float3  _S621 = make_float3 (0.0f);
    uint _S622;
    if((F32_abs((material_7.toon.x))) > 0.0f)
    {
        _S622 = 5U;
    }
    else
    {
        _S622 = 4U;
    }
    uint i_7 = 0U;
    float3  f_2 = _S621;
    for(;;)
    {
        if(i_7 < _S622)
        {
        }
        else
        {
            break;
        }
        uint _S623;
        if(i_7 == 3U)
        {
            _S623 = 4U;
        }
        else
        {
            if(i_7 == 4U)
            {
                _S623 = 6U;
            }
            else
            {
                _S623 = i_7;
            }
        }
        bool _S624 = _S623 == 0U;
        if(_S624)
        {
        }
        bool _S625;
        if(_S624)
        {
            float _S626 = rgb_to_greyscale(material_7.translucent);
            _S625 = _S626 > 0.0f;
        }
        else
        {
            _S625 = false;
        }
        bool _S627;
        if(_S625)
        {
            float _S628 = dot_0(n_7, dir_3);
            float3  _S629 = negate_0(in_dir_3);
            _S627 = ((_S628 * dot_0(n_7, _S629)) < 0.0f) == refracted_3;
        }
        else
        {
            _S627 = (_S623 == 1U) == refracted_3;
        }
        float3  f_3;
        if(_S627)
        {
            SampleBSDF _S630 = lobeBSDF(in_dir_3, dir_3, n_7, material_7, eta_i_5, eta_o_5, _S623, random_state_5, terms_3, view_terms_2);
            bool _S631 = (_S630.pdf) > 0.0f;
            if(_S631)
            {
                if(power_0)
                {
                    float _S632 = _S630.pdf / pdf_1;
                    float3  f_4 = f_2 + _S630.throughput * make_float3 (_S630.pdf) / make_float3 (pdf_1 * (1.0f + _S632 * _S632));
                    f_3 = f_4;
                }
                else
                {
                    float3  f_5 = f_2 + _S630.throughput * make_float3 (_S630.pdf) / make_float3 (_S630.pdf + pdf_1);
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
        uint i_8 = i_7 + 1U;
        i_7 = i_8;
        f_2 = f_3;
    }
    return f_2;
}

__device__ float3  skyBSDF(float3  in_dir_4, float3  dir_4, FKSurface surface_1, float2  eta_1, bool is_inside_2, float pdf_2, uint random_state_6)
{
    bool _S633 = wrongSide_0(is_inside_2, false, dir_4, surface_1.geometry_n);
    float _S634 = eta_1.x;
    float _S635 = eta_1.y;
    MaterialTerms _S636 = precomputeMaterial(surface_1.material, _S634, _S635);
    ViewTerms _S637 = precomputeView(in_dir_4, surface_1.smooth_n, surface_1.material, _S636);
    float3  _S638 = neeBSDF(in_dir_4, dir_4, surface_1.smooth_n, surface_1.material, _S634, _S635, _S633, pdf_2, false, random_state_6, _S636, _S637);
    return _S638;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S639;
    (&_S639)->dir = dir_5;
    (&_S639)->radiance = radiance_0;
    (&_S639)->color = color_0;
    (&_S639)->random_state = random_state_7;
    return _S639;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S640 = (fcptEnvironmentCdfSize());
    uint2  _S641 = make_uint2 (1U, 0U);
    uint2  _S642 = _S640 - _S641;
    Random _S643 = pcg(init_random_state_0);
    Random _S644 = pcg(_S643.state);
    Random _S645 = pcg(_S644.state);
    Random _S646 = pcg(_S645.state);
    uint _S647 = _S642.x;
    uint _S648 = searchCDF_0(make_uint2 (_S647, 0U), make_uint2 (0U, 1U), _S642.y, _S643.value);
    uint _S649 = searchCDF_0(make_uint2 (0U, _S648), _S641, _S647, _S644.value);
    float2  _S650 = make_float2 ((float)_S642.x, (float)_S642.y);
    float2  _S651 = (make_float2 (float(_S649), float(_S648)) + make_float2 (_S645.value, _S646.value)) / _S650 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S652 = _S651.y;
    float _S653 = (F32_sin((_S652)));
    float _S654 = _S651.x;
    float3  _S655 = make_float3 (- _S653 * (F32_cos((_S654))), _S653 * (F32_sin((_S654))), (F32_cos((_S652))));
    float _S656 = environmentPdf_0(_S655);
    float3  _S657 = skyBSDF(ray_0->unit_direction, _S655, *surface_2, eta_2, is_inside_3, _S656, lobe_state_0);
    bool _S658 = !(_S656 > 0.0f);
    bool _S659;
    if(_S658)
    {
        _S659 = true;
    }
    else
    {
        _S659 = all_1(_S657 == make_float3 (0.0f));
    }
    if(_S659)
    {
        float3  _S660 = make_float3 (0.0f);
        return SkySample_x24init_0(_S655, _S660, _S660, _S646.state);
    }
    float3  _S661 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S655, context_2, _S646.state);
    return SkySample_x24init_0(_S655, _S661, _S657 * _S661, _S646.state);
}

struct TreeSample
{
    float3  dir;
    float3  radiance;
    float density;
    uint random_state;
};

static __device__ float3  hairLight_0(FKSurface * surface_3, float3  in_dir_5, TreeSample * light_1, bool competing_0)
{
    SampleBSDF _S662 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_5), (light_1->dir)));
    float3  _S663 = _S662.throughput * make_float3 (_S662.pdf);
    float _S664 = light_1->density;
    float _S665 = 1.0f + _S662.pdf * _S662.pdf / (light_1->density * light_1->density);
    bool _S666;
    if(competing_0)
    {
        _S666 = _S664 > 0.0f;
    }
    else
    {
        _S666 = false;
    }
    float _S667 = _slang_select(_S666, _S665,1.0f);
    return _S663 / make_float3 (_S667) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S668;
    (&_S668)->dir = dir_6;
    (&_S668)->radiance = radiance_1;
    (&_S668)->density = density_0;
    (&_S668)->random_state = random_state_8;
    return _S668;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S669 = importance(first_1, p_12, normal_3);
    float _S670 = importance(second_1, p_12, normal_3);
    float2  _S671 = make_float2 (_S669, _S670);
    bool _S672 = _S669 == 0.0f;
    bool _S673;
    if(_S672)
    {
        _S673 = _S670 == 0.0f;
    }
    else
    {
        _S673 = false;
    }
    if(_S673)
    {
        return 2U;
    }
    float _S674 = _S669 + _S670;
    bool _S675 = _S670 > 0.0f;
    if(_S675)
    {
        _S673 = (*pick_0 * _S674) >= _S669;
    }
    else
    {
        _S673 = false;
    }
    uint _S676 = uint(_S673);
    float _S677 = (F32_min(((*pick_0 * _S674 - float(_S676) * _S669) / _slang_vector_get_element(_S671, _S676)), (0.99999994039535522f)));
    *pick_0 = _S677;
    float _S678 = *probability_3 * (_slang_vector_get_element(_S671, _S676) / _S674);
    *probability_3 = _S678;
    return _S676;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S679 = center_1 - p_13;
    float _S680 = radius_1 * radius_1 / dot_0(_S679, _S679);
    float _S681 = u1_0 * _S680 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S680), (0.0f)))))));
    float _S682 = 2.0f * u1_0;
    bool _S683 = _S680 >= 1.0f;
    float _S684 = _slang_select(_S683, _S682,_S681);
    float _S685 = (F32_sqrt(((F32_max((_S684 * (2.0f - _S684)), (0.0f))))));
    float _S686 = 6.28318548202514648f * u2_0;
    float3  _S687 = make_float3 (_S685 * (F32_cos((_S686))), 1.0f - _S684, _S685 * (F32_sin((_S686))));
    float3  _S688 = ((((_S679)) * make_float3(rnorm3df(((_S679)).x, ((_S679)).y, ((_S679)).z))));
    float3  _S689 = tangentToWorld(_S687, _S688);
    return _S689;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S690 = center_2 - ray_1->origin;
    float _S691 = dot_0(_S690, ray_1->unit_direction);
    float _S692 = dot_0(_S690, _S690) - _S691 * _S691;
    float _S693 = radius_3 * radius_3;
    bool _S694 = _S692 > _S693;
    if(_S694)
    {
        return 4.294967296e+09f;
    }
    float _S695 = (F32_sqrt((_S693 - _S692)));
    float _S696 = _S691 - _S695;
    float _S697 = _S691 + _S695;
    bool _S698 = _S696 > 0.0000152587890625f;
    bool _S699;
    if(_S698)
    {
        _S699 = _S696 < max_len_0;
    }
    else
    {
        _S699 = false;
    }
    if(_S699)
    {
        return _S696;
    }
    bool _S700 = _S697 > 0.0000152587890625f;
    if(_S700)
    {
        _S699 = _S697 < max_len_0;
    }
    else
    {
        _S699 = false;
    }
    if(_S699)
    {
        return _S697;
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
        int i_9 = int(0);
        float sum_0 = 0.0f;
        for(;;)
        {
            if(i_9 < int(3))
            {
            }
            else
            {
                break;
            }
            float sum_1 = sum_0 + _slang_vector_get_element(left_1, i_9) * _slang_vector_get_element(right_1.rows[i_9], j_1);
            i_9 = i_9 + int(1);
            sum_0 = sum_1;
        }
        *_slang_vector_get_element_ptr(&result_6, j_1) = sum_0;
        j_1 = j_1 + int(1);
    }
    return result_6;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S701 = pcg(init_random_state_1);
    Random _S702 = pcg(_S701.state);
    Random _S703 = pcg(_S702.state);
    float3  _S704 = make_float3 (0.0f);
    TreeSample _S705 = TreeSample_x24init_0(_S704, _S704, 0.0f, _S703.state);
    TreeSample sample_0 = _S705;
    float3  _S706 = _slang_select(sided_0, _S704,smooth_n_2);
    float3  _S707 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S701.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S708 = (fcptLightNode((n_8)));
        if((_S708.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S709 = (fcptLightSecond((n_8)));
        uint _S710 = n_8 + 1U;
        LightNode _S711 = (fcptLightBounds((_S710)));
        LightNode _S712 = (fcptLightBounds((_S709)));
        uint _S713 = pickChild(_S711, _S712, origin_4, _S706, &pick_1, &probability_4);
        bool _S714 = _S713 > 1U;
        if(_S714)
        {
            return sample_0;
        }
        bool _S715 = _S713 == 1U;
        uint _S716 = _slang_select(_S715, _S709,_S710);
        n_8 = _S716;
    }
    bool _S717 = n_8 == 0U;
    bool _S718;
    if(_S717)
    {
        LightNode _S719 = (fcptLightBounds((0U)));
        float _S720 = importance(_S719, origin_4, _S706);
        _S718 = !(_S720 > 0.0f);
    }
    else
    {
        _S718 = false;
    }
    if(_S718)
    {
        return sample_0;
    }
    uint4  _S721 = (fcptLightNode((n_8)));
    FKHit _S722 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S723 = (_S721.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S723)
    {
        FKLight _S724 = (fcptLight((_S721.y)));
        if(sided_0)
        {
            float _S725 = sign_0(dot_0(geometry_n_1, _S724.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S725);
            float3  _S726 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S726;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S707;
            lift_n_0 = smooth_n_2;
        }
        bool _S727 = (_S724.variance) == 0.0f;
        if(_S727)
        {
            float3  _S728 = _S724.position - emitter_point_0;
            float3  _S729 = ((((_S728)) * make_float3(rnorm3df(((_S728)).x, ((_S728)).y, ((_S728)).z))));
            (&sample_0)->dir = _S729;
            float3  _S730 = _S724.color * make_float3 (_S724.intensity) / make_float3 (dot_0(_S728, _S728) * probability_4);
            (&sample_0)->radiance = _S730;
            shadow_1 = _S728;
        }
        else
        {
            float3  _S731 = sampleSphere(_S724.position, _S724.variance, emitter_point_0, _S702.value, _S703.value);
            (&sample_0)->dir = _S731;
            float _S732 = sphereDensity(_S724.position, _S724.variance, emitter_point_0);
            float _S733 = probability_4 * _S732;
            (&sample_0)->density = _S733;
            float3  _S734 = pointLightRadiance(_S724.color, _S724.intensity, _S724.variance);
            float3  _S735 = _S734 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S735;
            FKRay _S736 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S737 = raySphere_0(_S724.position, _S724.variance, &_S736, 4.294967296e+09f);
            float3  _S738 = (&sample_0)->dir * make_float3 (_S737);
            shadow_1 = _S738;
        }
        emitter_0 = _S722;
        emitter_point_0 = _S704;
    }
    else
    {
        uint _S739 = _S721.y;
        uint _S740 = (fcptTriangleOffset((_S739)));
        uint _S741 = _S740 + _S721.z;
        Matrix<float, 3, 3>  _S742 = (fcptWorldTriangle((_S739), (_S741)));
        float _S743 = (F32_sqrt((_S702.value)));
        float2  _S744 = make_float2 (_S743 * (1.0f - _S703.value), _S743 * _S703.value);
        float3  _S745 = mul_0(make_float3 (1.0f - _S743, _S744.x, _S744.y), _S742);
        if(sided_0)
        {
            float _S746 = sign_0(dot_0(geometry_n_1, _S745 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S746);
            float3  _S747 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S747;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S748 = !((dot_0(smooth_n_2, _S745 - origin_4)) > 0.0f);
            if(_S748)
            {
                return sample_0;
            }
            emitter_point_0 = _S707;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S744, _S739, _S741, 0U, 0.0f);
        float3  _S749 = _S745 - emitter_point_0;
        float3  _S750 = ((((_S749)) * make_float3(rnorm3df(((_S749)).x, ((_S749)).y, ((_S749)).z))));
        (&sample_0)->dir = _S750;
        float _S751 = solidAngle(probability_4, cross_0(_S742.rows[int(1)] - _S742.rows[int(0)], _S742.rows[int(2)] - _S742.rows[int(0)]), _S749);
        (&sample_0)->density = _S751;
        bool _S752 = (fcptShadowFirst());
        bool _S753 = !_S752;
        if(_S753)
        {
            FKSurface _S754 = (fcptLightSurfaceAt((emitter_1), (_S745), (_S703.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S745 - origin_4))));
            (&sample_0)->random_state = _S754.random_state;
            float3  _S755 = _slang_select(_S754.skip, _S704,_S754.material.emissive);
            float3  _S756 = _S755 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S756;
        }
        shadow_1 = _S749;
        emitter_0 = emitter_1;
        emitter_point_0 = _S745;
    }
    FKHit _S757 = emitter_0;
    float3  _S758 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S703.state, &_S757);
    bool _S759 = (fcptShadowFirst());
    if(_S759)
    {
        _S718 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S718 = false;
    }
    if(_S718)
    {
        _S718 = !all_1(_S758 == _S704);
    }
    else
    {
        _S718 = false;
    }
    if(_S718)
    {
        FKSurface _S760 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S703.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S760.random_state;
        float3  _S761 = _slang_select(_S760.skip, _S704,_S760.material.emissive);
        float3  _S762 = _S761 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S762;
    }
    float3  _S763 = (&sample_0)->radiance * _S758;
    bool _S764 = all_1(_S758 == _S704);
    float3  _S765 = _slang_select(_S764, _S704,_S763);
    (&sample_0)->radiance = _S765;
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
    float _S766 = 1.0f / (1.0f + b_3 / a_7 * (b_3 / a_7));
    bool _S767 = b_3 > 0.0f;
    float _S768 = _slang_select(_S767, _S766,1.0f);
    return _S768;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S769 = vertex_0->none;
    if(_S769)
    {
        return 1.0f;
    }
    uint _S770 = (fcptLightSlot((*hit_1)));
    float _S771 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S770, light_point_1);
    float _S772 = powerHeuristic(vertex_0->pdf, _S771);
    return _S772;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_4)
{
    uint2  _S773 = (fcptEnvironmentMapSize());
    bool _S774 = (_S773.x) > 1U;
    bool _S775;
    if(_S774)
    {
        uint2  _S776 = (fcptEnvironmentMapSize());
        _S775 = (_S776.y) > 1U;
    }
    else
    {
        _S775 = false;
    }
    if(_S775)
    {
        float3  _S777 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_4)));
        return _S777;
    }
    float3  _S778 = (fcptAmbient());
    return _S778;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S779 = (fcptEnvironmentCdfSize());
    bool _S780 = (_S779.x) > 1U;
    bool _S781;
    if(_S780)
    {
        uint2  _S782 = (fcptEnvironmentCdfSize());
        _S781 = (_S782.y) > 1U;
    }
    else
    {
        _S781 = false;
    }
    bool _S783 = !_S781;
    if(_S783)
    {
        return false;
    }
    uint2  _S784 = (fcptEnvironmentMapSize());
    bool _S785 = (_S784.x) > 1U;
    if(_S785)
    {
        uint2  _S786 = (fcptEnvironmentMapSize());
        _S781 = (_S786.y) > 1U;
    }
    else
    {
        _S781 = false;
    }
    return _S781;
}

static __device__ float escapeWeight_0(float pdf_3, float3  dir_8)
{
    bool _S787 = pdf_3 <= 0.0f;
    bool _S788;
    if(_S787)
    {
        _S788 = true;
    }
    else
    {
        bool _S789 = environmentMapped_0();
        _S788 = !_S789;
    }
    if(_S788)
    {
        return 1.0f;
    }
    float _S790 = environmentPdf_0(dir_8);
    return pdf_3 / (pdf_3 + _S790);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S791 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S792 = make_int2 ((int)_S791.x, (int)_S791.y);
    uint _S793 = previousSeed_0(_S792);
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
            uint _S794 = previousSeed_0(_S792 + make_int2 (x_16, y_5));
            bool _S795 = _S794 == _S793;
            uint _S796 = _slang_select(_S795, 1U,0U);
            uint count_3 = count_2 + _S796;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S797 = float(count_2 - 1U) / 288.0f;
    bool _S798 = _S793 != 0U;
    float _S799 = _slang_select(_S798, _S797,0.0f);
    fcptStoreDuplication((_S792), (make_uint4 ((F32_asuint((_S799))), 0U, 0U, 0U)));
    return;
}

static __device__ float3  abs_0(float3  x_18)
{
    float3  result_7;
    int i_10 = int(0);
    for(;;)
    {
        if(i_10 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_7, i_10) = (F32_abs((_slang_vector_get_element(x_18, i_10))));
        i_10 = i_10 + int(1);
    }
    return result_7;
}

__device__ float resamplingTarget(float3  f_6)
{
    float _S800 = rgb_to_greyscale(abs_0(f_6));
    return _S800;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S801 = hash(index_0);
    uint _S802 = hash(seed_3 ^ _S801);
    return _S802;
}

static __device__ float4  asfloat_0(uint4  x_19)
{
    float4  result_8;
    int i_11 = int(0);
    for(;;)
    {
        if(i_11 < int(4))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_8, i_11) = (U32_asfloat((_slang_vector_get_element(x_19, i_11))));
        i_11 = i_11 + int(1);
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
    float _S803 = resamplingTarget(weight_0);
    bool _S804 = _S803 > 0.0f;
    bool _S805;
    if(_S804)
    {
        _S805 = _S803 < 3.00000000549775576e+38f;
    }
    else
    {
        _S805 = false;
    }
    bool _S806 = !_S805;
    if(_S806)
    {
        return;
    }
    bool _S807 = sel_2->sums;
    if(_S807)
    {
        float3  _S808 = sel_2->color + weight_0;
        sel_2->color = _S808;
        return;
    }
    float _S809 = sel_2->w_sum + _S803;
    sel_2->w_sum = _S809;
    float3  _S810 = sel_2->color + weight_0;
    sel_2->color = _S810;
    Random _S811 = pcg(sel_2->random_state);
    sel_2->random_state = _S811.state;
    bool _S812 = (_S811.value * sel_2->w_sum) <= _S803;
    if(_S812)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S813 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S813;
    float _S814 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S814;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S815 = resamplingTarget((&r_4)->f);
    float _S816 = sel_4.w_sum / _S815;
    bool _S817 = _S815 > 0.0f;
    float _S818 = _slang_select(_S817, _S816,0.0f);
    (&r_4)->w = _S818;
    (&r_4)->c = c_1;
    return r_4;
}

static __device__ uint2  asuint_0(float2  x_20)
{
    uint2  result_9;
    int i_12 = int(0);
    for(;;)
    {
        if(i_12 < int(2))
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

static __device__ void restir_spatial_0(uint3  global_invocation_id_2)
{
    uint2  _S819 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S820 = make_int2 ((int)_S819.x, (int)_S819.y);
    float3  _S821 = make_float3 (0.0f);
    FKHit _S822 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S823 = Domain_x24init_0(_S821, _S821, &_S822, 0.0f, 0.0f);
    Domain dom_4 = _S823;
    bool _S824 = (fcptCurrentDomain((_S820), (&dom_4)));
    bool _S825 = !_S824;
    if(_S825)
    {
        Reservoir _S826 = (Reservoir{});
        fcptStoreReservoirPrevious((_S820), (_S826), ((&dom_4)->hit));
        return;
    }
    Reservoir _S827 = (fcptLoadReservoirTemporal((_S820)));
    uint t_13 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S827.c;
    for(;;)
    {
        uint _S828 = (fcptRestirNeighbours());
        if(t_13 < _S828)
        {
        }
        else
        {
            break;
        }
        int2  _S829 = partner_0(_S820, t_13);
        Domain neighbor_0 = _S823;
        bool _S830 = (fcptCurrentDomain((_S829), (&neighbor_0)));
        if(_S830)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S831 = (fcptReservoirTemporal((_S829), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S831.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_14 = t_13 + 1U;
        t_13 = t_14;
    }
    float _S832 = _S827.c / (F32_max((count_4), (1.0f)));
    float _S833 = resamplingTarget(_S827.f);
    bool _S834 = count_4 == 0.0f;
    float _S835 = _slang_select(_S834, 1.0f,0.0f);
    Selection _S836 = (Selection{});
    Selection sel_5 = _S836;
    uint _S837 = (fcptFrame());
    uint _S838 = hash(_S837);
    uint _S839 = global_invocation_id_2.x;
    uint2  _S840 = (fcptRenderSize());
    uint _S841 = stream(_S838, _S839 + _S840.x * global_invocation_id_2.y);
    uint _S842 = stream(_S841, 195U);
    (&sel_5)->random_state = _S842;
    t_13 = 0U;
    float canonical_mis_0 = _S835;
    for(;;)
    {
        uint _S843 = (fcptRestirNeighbours());
        if(t_13 < _S843)
        {
        }
        else
        {
            break;
        }
        int2  _S844 = partner_0(_S820, t_13);
        Domain neighbor_dom_0 = _S823;
        bool _S845 = (fcptCurrentDomain((_S844), (&neighbor_dom_0)));
        if(_S845)
        {
            Reservoir _S846 = (fcptLoadReservoirTemporal((_S844)));
            uint4  _S847 = (fcptShiftData((_S844), (t_13)));
            float4  _S848 = asfloat_0(_S847);
            uint4  _S849 = (fcptShiftData((_S820), (t_13)));
            float4  _S850 = asfloat_0(_S849);
            float _S851 = pairShare(_S846.c, _S832, c_sum_1);
            bool _S852 = _S833 > 0.0f;
            float canonical_mis_1;
            if(_S852)
            {
                float _S853 = resamplingTarget(float3 {_S850.x, _S850.y, _S850.z});
                float _S854 = canonicalWeight(_S851, _S832, _S833, _S846.c, _S853);
                float canonical_mis_2 = canonical_mis_0 + _S854;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S855 = float3 {_S848.x, _S848.y, _S848.z};
            Shift _S856 = Shift_x24init_0(_S855, _S848.w);
            float _S857 = resamplingTarget(_S846.f);
            float _S858 = resamplingTarget(_S855);
            float _S859 = neighborWeight(_S851, _S846.c, _S857, _S832, _S858);
            offerShifted(&sel_5, _S846, _S856, _S859);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_15 = t_13 + 1U;
        t_13 = t_15;
    }
    offerShifted(&sel_5, _S827, Shift_x24init_0(_S827.f, 1.0f), canonical_mis_0);
    Reservoir _S860 = finalize(sel_5, c_sum_1);
    fcptStoreReservoirPrevious((_S820), (_S860), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S820), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S820), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
    return;
}

static __device__ uint3  asuint_1(float3  x_21)
{
    uint3  result_10;
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
        *_slang_vector_get_element_ptr(&result_10, i_13) = (F32_asuint((_slang_vector_get_element(x_21, i_13))));
        i_13 = i_13 + int(1);
    }
    return result_10;
}

static __device__ void restir_shift_0(uint3  workgroup_id_1, uint local_invocation_index_4)
{
    uint _S861 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S862 = _S861 != 4294967295U;
    if(_S862)
    {
        uint2  _S863 = make_uint2 (_S861, _S861 >> 14U) & make_uint2 (16383U);
        int2  _S864 = make_int2 ((int)_S863.x, (int)_S863.y);
        ShiftJob _S865 = (ShiftJob{});
        ShiftJob shift_job_0 = _S865;
        Shift _S866 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S867 = _S861 >> 28U;
        bool _S868 = spatialJob_0(_S864, _S867, &shift_job_0, true);
        Shift shifted_1;
        if(_S868)
        {
            Domain _S869 = (&shift_job_0)->dom;
            Reservoir _S870 = (&shift_job_0)->r;
            Shift _S871 = passShift_0(&_S869, &_S870);
            shifted_1 = _S871;
        }
        else
        {
            shifted_1 = _S866;
        }
        fcptStoreShiftData((_S864), (_S867), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S872 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S873 = make_int2 ((int)_S872.x, (int)_S872.y);
    FixedArray<uint, 3>  _S874;
    spatialBins_0(_S873, &_S874);
    FixedArray<uint, 3>  _S875 = _S874;
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
        bool _S876 = (_S875[t_16]) == 40U;
        if(_S876)
        {
            fcptStoreShiftData((_S873), (t_16), (make_uint4 (0U)));
        }
        uint t_17 = t_16 + 1U;
        t_16 = t_17;
    }
    FixedArray<uint, 3>  _S877 = _S875;
    queueShifts_0(_S873, &_S877, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S878 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S879 = make_int2 ((int)_S878.x, (int)_S878.y);
    FixedArray<uint, 3>  _S880;
    spatialBins_0(_S879, &_S880);
    FixedArray<uint, 3>  _S881 = _S880;
    countShifts_0(&_S881, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S882 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S883 = _S882 != 4294967295U;
    if(_S883)
    {
        uint2  _S884 = make_uint2 (_S882, _S882 >> 14U) & make_uint2 (16383U);
        int2  _S885 = make_int2 ((int)_S884.x, (int)_S884.y);
        int2  _S886 = (fcptLoadTemporalNeighbor((_S885)));
        uint _S887 = _S882 >> 28U;
        Shift _S888 = temporalShiftAt_0(_S885, _S886, _S887);
        fcptStoreTemporalShift((_S885), (_S887), (make_uint4 (asuint_1(_S888.f).x, asuint_1(_S888.f).y, asuint_1(_S888.f).z, (F32_asuint((_S888.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S889 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S890 = make_int2 ((int)_S889.x, (int)_S889.y);
    FixedArray<uint, 3>  _S891;
    temporalBins_0(_S890, &_S891);
    FixedArray<uint, 3>  _S892 = _S891;
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
        bool _S893 = (_S892[t_18]) == 40U;
        if(_S893)
        {
            fcptStoreTemporalShift((_S890), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S894 = _S892;
    queueShifts_0(_S890, &_S894, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S895 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S896 = make_int2 ((int)_S895.x, (int)_S895.y);
    bool _S897 = (fcptSceneUnchanged());
    bool _S898 = !_S897;
    bool _S899;
    if(_S898)
    {
        uint2  _S900 = (fcptRenderSize());
        int2  _S901 = make_int2 ((int)_S900.x, (int)_S900.y);
        _S899 = all_0(_S896 < _S901);
    }
    else
    {
        _S899 = false;
    }
    if(_S899)
    {
        Reservoir _S902 = (fcptLoadReservoirInitial((_S896)));
        int2  _S903 = sampleNeighbor_0(_S896, _S902.seed);
        fcptStoreTemporalNeighbor((_S896), (_S903));
    }
    FixedArray<uint, 3>  _S904;
    temporalBins_0(_S896, &_S904);
    FixedArray<uint, 3>  _S905 = _S904;
    countShifts_0(&_S905, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_8, float b_4, float t_20)
{
    return a_8 + (b_4 - a_8) * t_20;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S906 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S906;
}

__device__ float2  temporalWeights(float c_2, float p_c_1, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S907 = c_2 * p_c_1;
    float _S908 = c_t_0 * p_t_0;
    return make_float2 (_S907 / (_S907 + c_t_0 * g_previous_0), _S908 / (_S908 + c_2 * g_current_0));
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S909 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S910 = make_int2 ((int)_S909.x, (int)_S909.y);
    float3  _S911 = make_float3 (0.0f);
    FKHit _S912 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S913 = Domain_x24init_0(_S911, _S911, &_S912, 0.0f, 0.0f);
    Domain dom_5 = _S913;
    bool _S914 = (fcptCurrentDomain((_S910), (&dom_5)));
    bool _S915 = !_S914;
    if(_S915)
    {
        Reservoir _S916 = (Reservoir{});
        fcptStoreReservoirTemporal((_S910), (_S916), ((&dom_5)->hit));
        return;
    }
    Reservoir _S917 = (fcptLoadReservoirInitial((_S910)));
    bool _S918 = (fcptTemporalQueued());
    bool _S919 = (fcptSceneUnchanged());
    bool _S920;
    if(_S919)
    {
        _S920 = true;
    }
    else
    {
        _S920 = !_S918;
    }
    int2  _S921;
    if(_S920)
    {
        int2  _S922 = sampleNeighbor_0(_S910, _S917.seed);
        _S921 = _S922;
    }
    else
    {
        int2  _S923 = (fcptLoadTemporalNeighbor((_S910)));
        _S921 = _S923;
    }
    bool _S924 = (_S921.x) >= int(0);
    Reservoir r_5;
    if(_S924)
    {
        Reservoir _S925 = (fcptLoadReservoirPrevious((_S921)));
        uint4  _S926 = (fcptDuplication((_S921)));
        float _S927 = (U32_asfloat((_S926.x)));
        uint _S928 = (fcptRestirDecorrelation());
        bool _S929 = _S928 == 1U;
        float _S930 = _slang_select(_S929, _S927,0.0f);
        float _S931 = confidenceCap(_S930);
        float _S932 = (F32_min((_S925.c), (_S931)));
        bool _S933 = (fcptSceneUnchanged());
        float4  _S934 = make_float4 (_S925.f.x, _S925.f.y, _S925.f.z, 1.0f);
        bool _S935 = !_S933;
        if(_S935)
        {
            _S920 = _S918;
        }
        else
        {
            _S920 = false;
        }
        float4  to_current_0;
        if(_S920)
        {
            uint4  _S936 = (fcptTemporalShift((_S910), (0U)));
            float4  _S937 = asfloat_0(_S936);
            to_current_0 = _S937;
        }
        else
        {
            if(_S935)
            {
                Shift _S938 = temporalShiftAt_0(_S910, _S921, 0U);
                float4  _S939 = make_float4 (_S938.f.x, _S938.f.y, _S938.f.z, _S938.jac);
                to_current_0 = _S939;
            }
            else
            {
                to_current_0 = _S934;
            }
        }
        Domain own_1 = _S913;
        if(_S933)
        {
            _S920 = true;
        }
        else
        {
            bool _S940 = (fcptPreviousScenes());
            bool _S941 = !_S940;
            if(_S941)
            {
                _S920 = (_S917.w) > 0.0f;
            }
            else
            {
                _S920 = false;
            }
            if(_S920)
            {
                bool _S942 = (fcptStoredDomainInitial((_S910), (_S917.seed), (&own_1)));
                _S920 = _S942;
            }
            else
            {
                _S920 = false;
            }
            if(_S920)
            {
                Domain _S943 = (fcptPreviousDomain((_S921), (_S917.seed)));
                Domain _S944 = _S943;
                Domain _S945 = own_1;
                bool _S946 = sameDomain_0(&_S944, &_S945);
                _S920 = _S946;
            }
            else
            {
                _S920 = false;
            }
        }
        float4  _S947 = make_float4 (_S917.f.x, _S917.f.y, _S917.f.z, 1.0f);
        bool _S948 = !_S920;
        if(_S948)
        {
            _S920 = _S918;
        }
        else
        {
            _S920 = false;
        }
        float4  to_previous_0;
        if(_S920)
        {
            uint4  _S949 = (fcptTemporalShift((_S910), (1U)));
            float4  _S950 = asfloat_0(_S949);
            to_previous_0 = _S950;
        }
        else
        {
            if(_S948)
            {
                Shift _S951 = temporalShiftAt_0(_S910, _S921, 1U);
                float4  _S952 = make_float4 (_S951.f.x, _S951.f.y, _S951.f.z, _S951.jac);
                to_previous_0 = _S952;
            }
            else
            {
                to_previous_0 = _S947;
            }
        }
        float _S953 = resamplingTarget(_S917.f);
        float _S954 = resamplingTarget(_S925.f);
        Selection _S955 = (Selection{});
        Selection sel_6 = _S955;
        uint _S956 = (fcptFrame());
        uint _S957 = hash(_S956);
        uint _S958 = global_invocation_id_7.x;
        uint2  _S959 = (fcptRenderSize());
        uint _S960 = stream(_S957, _S958 + _S959.x * global_invocation_id_7.y);
        uint _S961 = stream(_S960, 194U);
        (&sel_6)->random_state = _S961;
        float4  _S962 = to_previous_0;
        float _S963 = resamplingTarget(float3 {_S962.x, _S962.y, _S962.z});
        float4  _S964 = to_current_0;
        float3  _S965 = float3 {_S964.x, _S964.y, _S964.z};
        float _S966 = resamplingTarget(_S965);
        float2  _S967 = temporalWeights(_S917.c, _S953, _S932, _S954, _S963, _S966);
        offerShifted(&sel_6, _S917, Shift_x24init_0(_S917.f, 1.0f), _S967.x);
        offerShifted(&sel_6, _S925, Shift_x24init_0(_S965, to_current_0.w), _S967.y);
        Reservoir _S968 = finalize(sel_6, _S917.c + _S932);
        r_5 = _S968;
    }
    else
    {
        r_5 = _S917;
    }
    fcptStoreReservoirTemporal((_S910), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S969 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S970 = make_int2 ((int)_S969.x, (int)_S969.y);
    float3  _S971 = make_float3 (0.0f);
    float2  _S972 = make_float2 (0.0f);
    FKHit _S973 = Hit_x24init_0(_S972, 0U, 0U, 0U, 0.0f);
    Domain _S974 = Domain_x24init_0(_S971, _S971, &_S973, 0.0f, 0.0f);
    Domain dom_6 = _S974;
    bool _S975 = (fcptCurrentDomain((_S970), (&dom_6)));
    bool _S976 = !_S975;
    if(_S976)
    {
        Reservoir _S977 = (Reservoir{});
        fcptStoreReservoirInitial((_S970), (_S977), ((&dom_6)->hit));
        return;
    }
    uint _S978 = (fcptFrame());
    uint _S979 = hash(_S978);
    uint _S980 = global_invocation_id_8.x;
    uint2  _S981 = (fcptRenderSize());
    uint _S982 = stream(_S979, _S980 + _S981.x * global_invocation_id_8.y);
    Selection _S983 = (Selection{});
    Selection initial_0 = _S983;
    uint _S984 = stream(_S982, 193U);
    (&initial_0)->random_state = _S984;
    bool _S985 = (fcptRestirUsed());
    bool _S986 = !_S985;
    (&initial_0)->sums = _S986;
    uint _S987 = stream(_S982, 0U);
    (&(&initial_0)->r)->seed = _S987;
    FKHit _S988 = Hit_x24init_0(_S972, 4294967295U, 0U, 0U, 0.0f);
    uint _S989 = (fcptSamples());
    float _S990 = 1.0f / float(_S989);
    FKHit hit_2 = _S988;
    uint i_14 = 0U;
    float3  seen_0 = _S971;
    for(;;)
    {
        uint _S991 = (fcptSamples());
        if(i_14 < _S991)
        {
        }
        else
        {
            break;
        }
        Reservoir _S992 = (Reservoir{});
        Reservoir r_6 = _S992;
        uint _S993 = stream(_S982, i_14);
        (&r_6)->seed = _S993;
        Domain path_0 = _S974;
        bool _S994 = (fcptStoredDomainInitial((_S970), ((&r_6)->seed), (&path_0)));
        bool _S995 = !_S994;
        if(_S995)
        {
            float3  _S996 = (fcptMissed((_S970), (path_0), (_S990)));
            float3  seen_1 = seen_0 + _S996;
            seen_0 = seen_1;
            uint i_15 = i_14 + 1U;
            i_14 = i_15;
            continue;
        }
        Domain _S997 = path_0;
        Reservoir _S998 = r_6;
        Shift _S999 = passWalk_0(&_S997, &_S998, false, _S990, &initial_0);
        bool _S1000 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1000)
        {
            FKHit _S1001 = (&path_0)->hit;
            hit_3 = _S1001;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_15 = i_14 + 1U;
        i_14 = i_15;
    }
    uint _S1002 = (fcptSamples());
    float3  seen_2 = seen_0 + (&initial_0)->glow / make_float3 (float(_S1002));
    if((&initial_0)->sums)
    {
        seen_0 = seen_2 + (&initial_0)->color;
    }
    else
    {
        seen_0 = seen_2;
    }
    fcptAddColor((_S970), (make_float4 (seen_0.x, seen_0.y, seen_0.z, 1.0f)));
    Reservoir _S1003 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S970), (_S1003), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1004;
    (&_S1004)->none = none_0;
    (&_S1004)->pdf = pdf_4;
    (&_S1004)->origin = origin_5;
    (&_S1004)->smooth_n = smooth_n_3;
    (&_S1004)->start = start_6;
    return _S1004;
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
    Vertex _S1005;
    (&_S1005)->rough = rough_0;
    (&_S1005)->lobe = lobe_5;
    (&_S1005)->pdf = pdf_5;
    (&_S1005)->cos = cos_0;
    (&_S1005)->inside = inside_0;
    return _S1005;
}

static __device__ float freeFlight_0(float u_1, float sigma_0)
{
    return - (F32_log((1.0f - u_1))) / sigma_0;
}

static __device__ float3  exp_0(float3  x_22)
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
        *_slang_vector_get_element_ptr(&result_11, i_16) = (F32_exp((_slang_vector_get_element(x_22, i_16))));
        i_16 = i_16 + int(1);
    }
    return result_11;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_1, float distance_2, bool scatters_0)
{
    float3  _S1006 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_2));
    float3  _S1007 = scatter_0 * _S1006 / make_float3 (sigma_1);
    float3  _S1008 = _slang_select(scatters_0, _S1007,_S1006);
    return _S1008;
}

static __device__ bool scatterSampled_0(bool replay_1, uint b_5, uint stop_0, bool varying_0)
{
    bool _S1009 = !replay_1;
    bool _S1010;
    if(_S1009)
    {
        _S1010 = true;
    }
    else
    {
        bool _S1011 = b_5 == stop_0;
        if(_S1011)
        {
            _S1010 = !varying_0;
        }
        else
        {
            _S1010 = false;
        }
    }
    return _S1010;
}

static __device__ uint arrivalLobe_0(uint b_6, uint prev_lobe_0)
{
    bool _S1012 = b_6 > 0U;
    uint _S1013 = _slang_select(_S1012, prev_lobe_0,3U);
    return _S1013;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_6, bool surface_4, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1014;
    (&_S1014)->extinction_behind = extinction_behind_0;
    (&_S1014)->extinction_front = extinction_front_0;
    (&_S1014)->fillings = fillings_0;
    (&_S1014)->side = side_0;
    (&_S1014)->depth = depth_1;
    (&_S1014)->lobe = lobe_6;
    (&_S1014)->surface = surface_4;
    (&_S1014)->length = length_2;
    (&_S1014)->width = width_1;
    (&_S1014)->own = *own_2;
    (&_S1014)->fiber = fiber_0;
    return _S1014;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1015 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1015)
    {
        return 0.07957746833562851f;
    }
    float _S1016 = g_0 * g_0;
    return (1.0f - _S1016) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1016 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_9, float3  b_7)
{
    float3  _S1017 = a_9 / b_7;
    float3  _S1018 = make_float3 (0.0f);
    bool3  _S1019 = b_7 == _S1018;
    float3  _S1020 = _slang_select(_S1019, _S1018,_S1017);
    return _S1020;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1021 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1021 << offset_1))) | ((newbits_0 & _S1021) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_7)
{
    Reservoir candidate_2 = r_7;
    uint _S1022 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1023 = insertBits_0(_S1022, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1023;
    (&candidate_2)->f = f_7;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_1, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S1024 = pcg(random_state_9);
    Random _S1025 = pcg(_S1024.state);
    float _S1026 = 1.0f - 2.0f * _S1024.value;
    float _S1027 = (F32_sqrt(((F32_max((1.0f - _S1026 * _S1026), (0.0f))))));
    float _S1028 = 6.28318548202514648f * _S1025.value;
    return make_float3 (_S1027 * (F32_cos((_S1028))), _S1027 * (F32_sin((_S1028))), _S1026);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_10, float * pdf_6)
{
    bool _S1029 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1029)
    {
        *pdf_6 = 0.07957746833562851f;
        float3  _S1030 = isotropic_0(random_state_10);
        return _S1030;
    }
    Random _S1031 = pcg(random_state_10);
    Random _S1032 = pcg(_S1031.state);
    float _S1033 = g_1 * g_1;
    float _S1034 = 2.0f * g_1;
    float _S1035 = (1.0f - _S1033) / (1.0f - g_1 + _S1034 * _S1031.value);
    float _S1036 = clamp_1((1.0f + _S1033 - _S1035 * _S1035) / _S1034, -1.0f, 1.0f);
    float _S1037 = (F32_sqrt(((F32_max((1.0f - _S1036 * _S1036), (0.0f))))));
    float _S1038 = 6.28318548202514648f * _S1032.value;
    float _S1039 = phaseHG_0(g_1, _S1036);
    *pdf_6 = _S1039;
    float3  _S1040 = tangentToWorld(make_float3 (_S1037 * (F32_cos((_S1038))), _S1036, _S1037 * (F32_sin((_S1038)))), dir_9);
    float3  _S1041 = ((((_S1040)) * make_float3(rnorm3df(((_S1040)).x, ((_S1040)).y, ((_S1040)).z))));
    return _S1041;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_3, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_3, float dispersion_0)
{
    BSDFMaterial _S1042;
    (&_S1042)->albedo = albedo_0;
    (&_S1042)->emissive = emissive_0;
    (&_S1042)->roughness = roughness_0;
    (&_S1042)->metallic = metallic_0;
    (&_S1042)->transmission = transmission_0;
    (&_S1042)->ior = ior_0;
    (&_S1042)->absorption = absorption_0;
    (&_S1042)->specular_tint = specular_tint_0;
    (&_S1042)->specular_level = specular_level_0;
    (&_S1042)->translucent = translucent_0;
    (&_S1042)->sheen = sheen_3;
    (&_S1042)->sheen_roughness = sheen_roughness_0;
    (&_S1042)->anisotropy = anisotropy_0;
    (&_S1042)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1042)->tangent = tangent_2;
    (&_S1042)->velvet = velvet_0;
    (&_S1042)->toon = toon_3;
    (&_S1042)->dispersion = dispersion_0;
    return _S1042;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1043;
    (&_S1043)->scatter = scatter_1;
    (&_S1043)->extinction = extinction_1;
    (&_S1043)->g = g_2;
    return _S1043;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_8, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1044;
    (&_S1044)->smooth_n = smooth_n_4;
    (&_S1044)->geometry_n = geometry_n_2;
    (&_S1044)->geometry_offset = geometry_offset_2;
    (&_S1044)->material = *material_8;
    (&_S1044)->skip = skip_0;
    (&_S1044)->random_state = random_state_11;
    (&_S1044)->coverage = coverage_0;
    (&_S1044)->encloses = encloses_0;
    (&_S1044)->volume = *volume_0;
    (&_S1044)->fills = fills_0;
    (&_S1044)->hair = hair_0;
    return _S1044;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S1045 = (&surface_5->material)->emissive;
    float3  _S1046 = make_float3 (0.0f);
    bool _S1047 = !top_0;
    float3  _S1048 = _slang_select(_S1047, _S1046,_S1045);
    (&(&lower_0)->material)->emissive = _S1048;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_2)
{
    float _S1049 = surface_6->coverage;
    bool _S1050 = u_2 < _S1049;
    if(_S1050)
    {
        return *surface_6;
    }
    float3  _S1051 = make_float3 (0.0f);
    float3  _S1052 = make_float3 (1.0f);
    BSDFMaterial _S1053 = Material_x24init_0(_S1051, _S1051, 0.0f, 0.0f, 0.0f, 0.0f, _S1051, _S1052, 1.0f, _S1051, _S1051, 0.5f, 0.0f, 0.0f, _S1051, 0.0f, _S1051, 0.0f);
    BSDFMaterial material_9 = _S1053;
    (&material_9)->albedo = _S1052;
    (&material_9)->emissive = (&surface_6->material)->emissive;
    (&material_9)->transmission = 1.0f;
    (&material_9)->ior = 1.0f;
    (&material_9)->absorption = (&surface_6->material)->absorption;
    FKSurface through_0 = *surface_6;
    (&through_0)->material = material_9;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S1054 = transmission_1 > 0.0f;
    bool _S1055;
    if(_S1054)
    {
        _S1055 = true;
    }
    else
    {
        _S1055 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1056;
    if(_S1055)
    {
        _S1056 = 1.0f;
    }
    else
    {
        _S1056 = -1.0f;
    }
    return _S1056;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_9)
{
    return (dot_0(dir_10, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_11)
{
    float3  _S1057 = surface_7->geometry_n;
    float _S1058 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_11);
    FKSurface faced_0 = *surface_7;
    float3  _S1059 = surface_7->smooth_n * make_float3 (_S1058);
    (&faced_0)->smooth_n = _S1059;
    float3  _S1060 = _S1057 * make_float3 (_S1058);
    (&faced_0)->geometry_n = _S1060;
    return faced_0;
}

static __device__ float3  max_0(float3  x_23, float3  y_7)
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
        *_slang_vector_get_element_ptr(&result_12, i_17) = (F32_max((_slang_vector_get_element(x_23, i_17)), (_slang_vector_get_element(y_7, i_17))));
        i_17 = i_17 + int(1);
    }
    return result_12;
}

static __device__ float3  log_0(float3  x_24)
{
    float3  result_13;
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
        *_slang_vector_get_element_ptr(&result_13, i_18) = (F32_log((_slang_vector_get_element(x_24, i_18))));
        i_18 = i_18 + int(1);
    }
    return result_13;
}

__device__ float3  beerLambert(float distance_3, float3  absorption_1)
{
    float3  _S1061 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1061));
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
    bool _S1062;
    if(open_0)
    {
        _S1062 = prev_rough_0;
    }
    else
    {
        _S1062 = false;
    }
    if(_S1062)
    {
        _S1062 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S1062 = false;
    }
    return _S1062;
}

__device__ bool dispersive(BSDFMaterial material_10)
{
    bool _S1063 = (material_10.dispersion) > 0.0f;
    bool _S1064;
    if(_S1063)
    {
        _S1064 = (material_10.ior) != 1.0f;
    }
    else
    {
        _S1064 = false;
    }
    return _S1064;
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
        uint _S1065 = (low_1 + high_1 + 1U) / 2U;
        bool _S1066 = (WAVELENGTH_CDF_0[_S1065]) <= u_3;
        if(_S1066)
        {
            low_1 = _S1065;
        }
        else
        {
            uint _S1067 = _S1065 - 1U;
            high_1 = _S1067;
        }
    }
    uint _S1068 = low_1;
    float _S1069 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_3 - WAVELENGTH_CDF_0[_S1068]) / _S1069), _S1069 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_0)
{
    float _S1070 = clamp_1((wavelength_0 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1071 = (U32_min((uint(_S1070)), (79U)));
    uint _S1072 = 3U * _S1071;
    float3  _S1073 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1072], WAVELENGTH_WEIGHTS_0[_S1072 + 1U], WAVELENGTH_WEIGHTS_0[_S1072 + 2U]);
    float3  _S1074 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1072 + 3U], WAVELENGTH_WEIGHTS_0[_S1072 + 4U], WAVELENGTH_WEIGHTS_0[_S1072 + 5U]);
    return _S1073 + (_S1074 - _S1073) * make_float3 (_S1070 - float(_S1071));
}

__device__ float dispersedIor(float ior_1, float dispersion_1, float wavelength_1)
{
    float _S1075 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1076 = _S1075 * (1.0f / (wavelength_1 * wavelength_1) - 2.89662933349609375f);
    bool _S1077 = dispersion_1 > 0.0f;
    float _S1078 = _slang_select(_S1077, _S1076,0.0f);
    return ior_1 + _S1078;
}

__device__ float2  vertexEta(BSDFMaterial material_11, float n_dot_v_0)
{
    bool _S1079 = n_dot_v_0 < 0.0f;
    float _S1080 = _slang_select(_S1079, material_11.ior,1.0f);
    float _S1081 = _slang_select(_S1079, 1.0f,material_11.ior);
    return make_float2 (_S1080, _S1081);
}

__device__ bool neeDecision(BSDFMaterial material_12, float n_dot_v_1, float eta_i_6, float eta_o_6)
{
    float _S1082 = fresnel((F32_abs((n_dot_v_1))), eta_i_6, eta_o_6);
    float3  _S1083 = mix_0(make_float3 (_S1082), material_12.albedo, material_12.metallic);
    float _S1084 = rgb_to_greyscale(_S1083);
    float _S1085 = (F32_max(((1.0f - _S1084) * (1.0f - material_12.metallic) * (1.0f - material_12.transmission)), (0.0f)));
    bool _S1086 = _S1085 > 0.03999999910593033f;
    bool _S1087;
    if(_S1086)
    {
        _S1087 = true;
    }
    else
    {
        _S1087 = (material_12.roughness) > 0.20000000298023224f;
    }
    return _S1087;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_13)
{
    float _S1088 = rgb_to_greyscale(material_13->translucent);
    return _S1088 > 0.0f;
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
    MediumSides _S1089;
    (&_S1089)->behind = *behind_0;
    (&_S1089)->front = *front_0;
    (&_S1089)->fillings = fillings_1;
    (&_S1089)->face = face_1;
    return _S1089;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1090 = surface_8->geometry_n;
    MediumSides _S1091 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S1091;
    bool _S1092 = surface_8->encloses;
    if(_S1092)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S1093 = (dot_0(dir_12, _S1090)) > 0.0f;
        if(_S1093)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_7, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1094 = surface_9->geometry_n;
    ShadowContext _S1095 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_2, lobe_7, true, length_3, width_2, own_3, fiber_1);
    bool _S1096 = surface_9->encloses;
    ShadowContext context_4;
    if(_S1096)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S1097 = - _S1094;
        float3  _S1098 = _slang_select(turned_0, _S1097,_S1094);
        (&faced_1)->geometry_n = _S1098;
        FKMedium _S1099 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1100 = faced_1;
        FKMedium _S1101 = _S1099;
        MediumSides _S1102 = mediumSides_0(&_S1100, &_S1101, filling_1, dir_13, outside_1);
        ShadowContext _S1103 = ShadowContext_x24init_0(_S1102.behind.extinction, _S1102.front.extinction, _S1102.fillings, _S1094, depth_2, lobe_7, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1104 = _S1102.fillings;
            ShadowContext _S1105 = ShadowContext_x24init_0(_S1102.front.extinction, _S1102.behind.extinction, uint2 {_S1104.y, _S1104.x}, _S1094, depth_2, lobe_7, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1105;
        }
        else
        {
            context_4 = _S1103;
        }
    }
    else
    {
        context_4 = _S1095;
    }
    return context_4;
}

static __device__ bool any_1(bool3  x_25)
{
    bool result_14 = false;
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
        if(result_14)
        {
            result_14 = true;
        }
        else
        {
            result_14 = (bool((_slang_vector_get_element(x_25, i_19))));
        }
        i_19 = i_19 + int(1);
    }
    return result_14;
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_6, float3  out_dir_1, float3  n_10, float3  g_n_0, BSDFMaterial material_14, float eta_i_7, float eta_o_7, uint random_state_12, MaterialTerms terms_4, ViewTerms view_terms_3)
{
    float3  _S1106 = negate_0(in_dir_6);
    bool _S1107 = (dot_0(g_n_0, _S1106) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S1107)
    {
        SampleBSDF _S1108 = lobeBSDF(in_dir_6, out_dir_1, n_10, material_14, eta_i_7, eta_o_7, 0U, random_state_12, terms_4, view_terms_3);
        SampleBSDF _S1109 = lobeBSDF(in_dir_6, out_dir_1, n_10, material_14, eta_i_7, eta_o_7, 2U, random_state_12, terms_4, view_terms_3);
        SampleBSDF _S1110 = lobeBSDF(in_dir_6, out_dir_1, n_10, material_14, eta_i_7, eta_o_7, 4U, random_state_12, terms_4, view_terms_3);
        bool _S1111 = (F32_abs((material_14.toon.x))) > 0.0f;
        if(_S1111)
        {
            SampleBSDF _S1112 = lobeBSDF(in_dir_6, out_dir_1, n_10, material_14, eta_i_7, eta_o_7, 6U, random_state_12, terms_4, view_terms_3);
            return _S1108.throughput * make_float3 (_S1108.pdf) + _S1109.throughput * make_float3 (_S1109.pdf) + _S1110.throughput * make_float3 (_S1110.pdf) + _S1112.throughput * make_float3 (_S1112.pdf);
        }
        return _S1108.throughput * make_float3 (_S1108.pdf) + _S1109.throughput * make_float3 (_S1109.pdf) + _S1110.throughput * make_float3 (_S1110.pdf);
    }
    SampleBSDF _S1113 = lobeBSDF(in_dir_6, out_dir_1, n_10, material_14, eta_i_7, eta_o_7, 1U, random_state_12, terms_4, view_terms_3);
    return _S1113.throughput * make_float3 (_S1113.pdf);
}

__device__ float3  translucentCorrection(float3  in_dir_7, float3  out_dir_2, float3  n_11, float3  g_n_1, BSDFMaterial material_15, float eta_i_8, float eta_o_8, uint random_state_13, MaterialTerms terms_5, ViewTerms view_terms_4)
{
    float _S1114 = dot_0(n_11, out_dir_2);
    float3  _S1115 = negate_0(in_dir_7);
    bool _S1116 = (_S1114 * dot_0(n_11, _S1115)) < 0.0f;
    SampleBSDF _S1117 = lobeBSDF(in_dir_7, out_dir_2, n_11, material_15, eta_i_8, eta_o_8, 0U, random_state_13, terms_5, view_terms_4);
    float3  _S1118 = negate_0(in_dir_7);
    bool _S1119 = (dot_0(g_n_1, _S1118) * dot_0(g_n_1, out_dir_2)) > 0.0f;
    float3  _S1120 = make_float3 (0.0f);
    float3  _S1121 = _S1117.throughput * make_float3 (_S1117.pdf);
    float _S1122 = _slang_select(_S1119, -1.0f,1.0f);
    float3  _S1123 = _S1121 * make_float3 (_S1122);
    float3  _S1124 = _slang_select(_S1116, _S1123,_S1120);
    return _S1124;
}

__device__ float3  translucentBSDF(float3  in_dir_8, float3  out_dir_3, float3  n_12, float3  g_n_2, BSDFMaterial material_16, float eta_i_9, float eta_o_9, uint random_state_14)
{
    MaterialTerms _S1125 = precomputeMaterial(material_16, eta_i_9, eta_o_9);
    ViewTerms _S1126 = precomputeView(in_dir_8, n_12, material_16, _S1125);
    float3  _S1127 = BSDF(in_dir_8, out_dir_3, n_12, g_n_2, material_16, eta_i_9, eta_o_9, random_state_14, _S1125, _S1126);
    float3  _S1128 = translucentCorrection(in_dir_8, out_dir_3, n_12, g_n_2, material_16, eta_i_9, eta_o_9, random_state_14, _S1125, _S1126);
    return _S1127 + _S1128;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_9, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_17, float eta_i_10, float eta_o_10, bool competing_1, uint random_state_15)
{
    bool _S1129 = !competing_1;
    bool _S1130;
    if(_S1129)
    {
        _S1130 = true;
    }
    else
    {
        _S1130 = (light_2->density) == 0.0f;
    }
    if(_S1130)
    {
        bool _S1131 = isTranslucent_0(material_17);
        _S1130 = _S1131;
    }
    else
    {
        _S1130 = false;
    }
    if(_S1130)
    {
        float3  _S1132 = translucentBSDF(in_dir_9, light_2->dir, smooth_n_5, geometry_n_4, *material_17, eta_i_10, eta_o_10, random_state_15);
        return _S1132 * light_2->radiance;
    }
    MaterialTerms _S1133 = precomputeMaterial(*material_17, eta_i_10, eta_o_10);
    ViewTerms _S1134 = precomputeView(in_dir_9, smooth_n_5, *material_17, _S1133);
    if(_S1129)
    {
        _S1130 = true;
    }
    else
    {
        _S1130 = (light_2->density) == 0.0f;
    }
    if(_S1130)
    {
        float3  _S1135 = BSDF(in_dir_9, light_2->dir, smooth_n_5, geometry_n_4, *material_17, eta_i_10, eta_o_10, random_state_15, _S1133, _S1134);
        return _S1135 * light_2->radiance;
    }
    float3  _S1136 = light_2->dir;
    bool _S1137 = (dot_0(geometry_n_4, - in_dir_9) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    float3  _S1138 = neeBSDF(in_dir_9, _S1136, smooth_n_5, *material_17, eta_i_10, eta_o_10, _S1137, light_2->density, true, random_state_15, _S1133, _S1134);
    return _S1138 * light_2->radiance * make_float3 (light_2->density);
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1139 = (F32_sqrt((random_1_0)));
    float _S1140 = 6.28318548202514648f * random_2_0;
    float _S1141 = _S1139 * (F32_cos((_S1140)));
    float _S1142 = _S1139 * (F32_sin((_S1140)));
    float _S1143 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1141 * _S1141 - _S1142 * _S1142))))));
    return make_float3 (_S1141, _S1143, _S1142);
}

static __device__ float3  reflect_0(float3  i_20, float3  n_13)
{
    return i_20 - make_float3 (2.0f * dot_0(n_13, i_20)) * n_13;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_14, BSDFMaterial material_18, float eta_i_11, float eta_o_11, uint random_init_1, float2  screen_space_0, MaterialTerms terms_6, ViewTerms view_terms_5)
{
    uint random_state_16 = random_init_1;
    float3  _S1144 = negate_0(in_dir_10);
    float _S1145 = dot_0(n_14, _S1144);
    float _S1146 = sign_0(_S1145);
    float3  n_i_4 = n_14 * make_float3 (_S1146);
    float _S1147 = (F32_abs((_S1145)));
    float _S1148 = material_18.roughness;
    float _S1149 = _S1148 * _S1148;
    float3  _S1150 = sampleHalfVector(_S1144, n_i_4, _S1149, view_terms_5.frame, &random_state_16);
    HalfTerms _S1151 = precomputeHalf(in_dir_10, _S1150, material_18, eta_i_11, eta_o_11, terms_6, view_terms_5);
    float3  _S1152 = make_float3 (1.0f);
    SampleBSDF _S1153 = SampleBSDF_x24init_0(_S1152, _S1152, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1153;
    Random _S1154 = pcg(random_state_16);
    random_state_16 = _S1154.state;
    bool _S1155 = (_S1154.value) < (_S1151.p_sheen_velvet);
    if(_S1155)
    {
        Random _S1156 = pcg(random_state_16);
        Random _S1157 = pcg(_S1156.state);
        (&sample_1)->random_state = _S1157.state;
        float _S1158 = _S1156.value;
        float _S1159 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1158 * _S1158))))));
        float _S1160 = 6.28318548202514648f * _S1157.value;
        float3  _S1161 = tangentToWorld(make_float3 (_S1159 * (F32_cos((_S1160))), _S1156.value, _S1159 * (F32_sin((_S1160)))), n_i_4);
        (&sample_1)->unit_direction = _S1161;
        float3  _S1162 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1149, material_18, _S1151, 4U);
        (&sample_1)->throughput = _S1162;
        float _S1163 = lobeDensity(_S1156.value, 0.0f, _S1147, _S1149, _S1151, eta_i_11, eta_o_11, 4U);
        (&sample_1)->pdf = _S1163;
        (&sample_1)->lobe = 4U;
        return sample_1;
    }
    float u_4 = _S1154.value - _S1151.p_sheen_velvet;
    bool _S1164 = u_4 < (_S1151.p_diffuse);
    if(_S1164)
    {
        Random _S1165 = pcg(random_state_16);
        Random _S1166 = pcg(_S1165.state);
        (&sample_1)->random_state = _S1166.state;
        float3  _S1167 = sampleCosWeightedHemisphere(_S1165.value, _S1166.value);
        bool _S1168 = u_4 < (_S1151.p_diffuse * _S1151.translucent_share);
        float _S1169 = _S1167.y;
        float _S1170 = - _S1169;
        float _S1171 = _slang_select(_S1168, _S1170,_S1169);
        float3  _S1172 = tangentToWorld(make_float3 (_S1167.x, _S1171, _S1167.z), n_i_4);
        (&sample_1)->unit_direction = _S1172;
        float3  _S1173 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1149, material_18, _S1151, 0U);
        (&sample_1)->throughput = _S1173;
        float _S1174 = lobeDensity(_S1171, 0.0f, _S1147, _S1149, _S1151, eta_i_11, eta_o_11, 0U);
        (&sample_1)->pdf = _S1174;
        (&sample_1)->refracted = _S1168;
        return sample_1;
    }
    bool _S1175 = u_4 < (_S1151.p_diffuse + _S1151.p_toon);
    if(_S1175)
    {
        Random _S1176 = pcg(random_state_16);
        Random _S1177 = pcg(_S1176.state);
        (&sample_1)->random_state = _S1177.state;
        float _S1178 = _S1176.value * _S1151.toon_norm / 6.28318548202514648f;
        float t_21;
        if(_S1151.toon_glossy)
        {
            t_21 = (F32_acos((clamp_1(1.0f - _S1178, -1.0f, 1.0f))));
        }
        else
        {
            t_21 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1178)))), (1.0f))))));
        }
        if(t_21 < (_S1151.toon_a))
        {
        }
        else
        {
            t_21 = (_S1151.toon_a + _S1151.toon_b) / 2.0f;
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
            float _S1179;
            if(t_21 < (_S1151.toon_a))
            {
                _S1179 = 1.0f;
            }
            else
            {
                _S1179 = (F32_max((1.0f - (t_21 - _S1151.toon_a) / (F32_max((_S1151.toon_s), (0.0000152587890625f)))), (0.0f)));
            }
            float integral_1;
            if(_S1151.toon_glossy)
            {
                integral_1 = 1.0f - (F32_cos(((F32_min((t_21), (_S1151.toon_a))))));
            }
            else
            {
                float _S1180 = (F32_sin(((F32_min((t_21), (_S1151.toon_a))))));
                integral_1 = _S1180 * _S1180 / 2.0f;
            }
            bool _S1181 = t_21 > (_S1151.toon_a);
            bool _S1182;
            if(_S1181)
            {
                _S1182 = (_S1151.toon_s) > 0.0f;
            }
            else
            {
                _S1182 = false;
            }
            float integral_2;
            if(_S1182)
            {
                if(_S1151.toon_glossy)
                {
                    float _S1183 = (F32_cos((_S1151.toon_a)));
                    float _S1184 = (F32_cos((t_21)));
                    integral_2 = (1.0f + _S1151.toon_a / _S1151.toon_s) * (_S1183 - _S1184) - ((F32_sin((t_21))) - t_21 * _S1184 - ((F32_sin((_S1151.toon_a))) - _S1151.toon_a * _S1183)) / _S1151.toon_s;
                }
                else
                {
                    float _S1185 = 2.0f * _S1151.toon_a;
                    float _S1186 = (F32_cos((_S1185)));
                    float _S1187 = 2.0f * t_21;
                    float _S1188 = (F32_cos((_S1187)));
                    integral_2 = (1.0f + _S1151.toon_a / _S1151.toon_s) * (_S1186 - _S1188) / 4.0f - ((F32_sin((_S1187))) / 8.0f - t_21 * _S1188 / 4.0f - ((F32_sin((_S1185))) / 8.0f - _S1151.toon_a * _S1186 / 4.0f)) / _S1151.toon_s;
                }
                float integral_3 = integral_1 + integral_2;
                integral_2 = integral_3;
            }
            else
            {
                integral_2 = integral_1;
            }
            float _S1189 = _S1179 * (F32_sin((t_21)));
            float _S1190;
            if(_S1151.toon_glossy)
            {
                _S1190 = 1.0f;
            }
            else
            {
                _S1190 = (F32_cos((t_21)));
            }
            float _S1191 = _S1189 * _S1190;
            float _S1192 = (integral_2 - _S1178) / _S1191;
            bool _S1193 = _S1191 > 0.0f;
            float _S1194 = _slang_select(_S1193, _S1192,0.0f);
            float _S1195 = clamp_1(t_21 - _S1194, 0.0f, _S1151.toon_b);
            int k_1 = k_0 + int(1);
            t_21 = _S1195;
            k_0 = k_1;
        }
        float _S1196 = 6.28318548202514648f * _S1177.value;
        float _S1197 = (F32_sin((t_21)));
        float3  _S1198 = tangentToWorld(make_float3 (_S1197 * (F32_cos((_S1196))), (F32_cos((t_21))), _S1197 * (F32_sin((_S1196)))), _S1151.toon_axis);
        (&sample_1)->unit_direction = _S1198;
        float3  _S1199 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1149, material_18, _S1151, 6U);
        (&sample_1)->throughput = _S1199;
        float _S1200 = lobeDensity(dot_0(n_i_4, (&sample_1)->unit_direction), dot_0((&sample_1)->unit_direction, _S1151.toon_axis), _S1147, _S1149, _S1151, eta_i_11, eta_o_11, 6U);
        (&sample_1)->pdf = _S1200;
        bool _S1201 = (dot_0(n_i_4, (&sample_1)->unit_direction)) < 0.0f;
        (&sample_1)->refracted = _S1201;
        (&sample_1)->lobe = 6U;
        return sample_1;
    }
    float u_5 = u_4 - _S1151.p_toon;
    bool _S1202 = u_5 < (_S1151.p_diffuse + _S1151.p_refract);
    if(_S1202)
    {
        (&sample_1)->unit_direction = _S1151.refracted;
        float _S1203 = lobeDensity(0.0f, dot_0((&sample_1)->unit_direction, _S1150), _S1147, _S1149, _S1151, eta_i_11, eta_o_11, 1U);
        (&sample_1)->pdf = _S1203;
        float3  _S1204 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1149, material_18, _S1151, 1U);
        (&sample_1)->throughput = _S1204;
        (&sample_1)->random_state = random_state_16;
        (&sample_1)->refracted = true;
        (&sample_1)->lobe = 1U;
        return sample_1;
    }
    float3  _S1205 = reflect_0(in_dir_10, _S1150);
    float3  _S1206 = ((((_S1205)) * make_float3(rnorm3df(((_S1205)).x, ((_S1205)).y, ((_S1205)).z))));
    (&sample_1)->unit_direction = _S1206;
    float3  _S1207 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1149, material_18, _S1151, 2U);
    (&sample_1)->throughput = _S1207;
    (&sample_1)->random_state = random_state_16;
    (&sample_1)->lobe = 2U;
    float _S1208 = lobeDensity(0.0f, 0.0f, _S1147, _S1149, _S1151, eta_i_11, eta_o_11, 2U);
    (&sample_1)->pdf = _S1208;
    return sample_1;
}

__device__ bool withinInverseFootprint(float pdf_7, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1209 = pdf_7 > 0.0f;
    bool _S1210;
    if(_S1209)
    {
        if(diffuse_0)
        {
            _S1210 = true;
        }
        else
        {
            _S1210 = (pdf_7 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1210 = false;
    }
    return _S1210;
}

__device__ bool roughLobe(float pdf_8, bool diffuse_1, float roughness_1)
{
    bool _S1211 = pdf_8 > 0.0f;
    bool _S1212;
    if(_S1211)
    {
        if(diffuse_1)
        {
            _S1212 = true;
        }
        else
        {
            _S1212 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1212 = false;
    }
    return _S1212;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1213 = layers_0 > 1U;
    bool _S1214;
    if(_S1213)
    {
        _S1214 = refracting_0 != passed_0;
    }
    else
    {
        _S1214 = false;
    }
    return _S1214;
}

static __device__ float widened_0(float spread_1, float pdf_9, bool delta_0)
{
    float _S1215 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_9))))), (3.14159274101257324f)));
    bool _S1216 = !delta_0;
    float _S1217 = _slang_select(_S1216, _S1215,0.0f);
    return spread_1 + _S1217;
}

static __device__ bool boundsVolume_0(FKSurface * surface_10)
{
    return surface_10->encloses;
}

static __device__ bool leavesInFront_0(float3  face_2, float3  dir_14, float3  g_3)
{
    return ((dot_0(dir_14, g_3)) > 0.0f) == ((dot_0(g_3, face_2)) > 0.0f);
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_8, bool replay_2, float scale_4, Selection * sel_7)
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
    float wavelength_2;
    uint b_8;
    uint layer_0;
    float3  throughput_2;
    float3  chain_throughput_0;
    TreeSample light_3;
    int _S1218;
    Shift ended_0;
    float density_3;
    float spread_3;
    float width_4;
    float sky_pdf_1;
    float spread_4;
    float width_5;
    uint b_9;
    float3  _S1219 = make_float3 (0.0f);
    Shift _S1220 = Shift_x24init_0(_S1219, 0.0f);
    uint _S1221 = r_8->path;
    uint _S1222 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1223 = extractBits_0(_S1221, 5U, 5U);
    uint _S1224 = extractBits_0(_S1221, 10U, 2U);
    uint _S1225 = extractBits_0(_S1221, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1226 = _S1225 >= 3U;
        uint _S1227 = _slang_select(_S1226, 1U,0U);
        uint _S1228 = _S1222 + _S1227;
        uint _S1229 = (fcptMaxBounces());
        passes_0 = _S1228 > _S1229;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1220;
    }
    uint _S1230 = _S1223 - 1U;
    bool _S1231 = _S1225 == 3U;
    uint _S1232 = _slang_select(_S1231, 1U,0U);
    uint _S1233 = _S1222 + _S1232;
    bool _S1234 = _S1224 == 0U;
    uint _S1235 = _slang_select(_S1234, _S1233,_S1230);
    FKHit _S1236 = (fcptReservoirHit((*r_8)));
    float3  _S1237 = dom_7->x0;
    float3  _S1238 = dom_7->x1 - dom_7->x0;
    float3  _S1239 = ((((_S1238)) * make_float3(rnorm3df(((_S1238)).x, ((_S1238)).y, ((_S1238)).z))));
    FKRay _S1240 = Ray_x24init_0(dom_7->x1, _S1239);
    FKRay ray_2 = _S1240;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1219;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1219;
    float3  extinction_in_0 = _S1219;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1241 = dom_7->spread;
    float _S1242 = dom_7->width;
    float _S1243 = length_0(_S1238);
    NEEVertex _S1244 = NEEVertex_x24init_0(true, 0.0f, _S1219, _S1219, _S1219);
    NEEVertex nee_vertex_0 = _S1244;
    Vertex _S1245 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1245;
    Reservoir _S1246 = (Reservoir{});
    Reservoir chain_0 = _S1246;
    uint _S1247 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1237;
    (&hit_4)->distance = _S1243;
    FKMedium _S1248 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1249 = filling_2;
    bool _S1250 = (fcptVaryingUsed());
    uint _S1251 = _slang_select(_S1250, _S1249,4294967295U);
    filling_2 = _S1251;
    scatter_in_0 = _S1248.scatter;
    extinction_in_0 = _S1248.extinction;
    g_in_0 = _S1248.g;
    Reservoir _S1252 = chain_0;
    uint _S1253 = filling_2;
    for(;;)
    {
        bool _S1254 = (fcptVaryingUsed());
        if(_S1254)
        {
            passes_0 = _S1253 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1255 = (fcptMajorant((_S1253)));
            spread_2 = _S1255;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1235;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1224 == 1U;
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
            ended_0 = _S1220;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1241;
            width_3 = _S1242;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_8 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1256 = (&prev_0)->rough;
        if(_S1256)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1257 = stream(_S1247, 384U);
        uint tracking_0 = _S1257;
        weight_1 = throughput_3;
        glowed_0 = _S1219;
        b_8 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_2 = _S1241;
        width_3 = _S1242;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1218 = int(1);
                break;
            }
            uint _S1258 = b_8 + 320U;
            bool _S1259 = b_8 == 4294967295U;
            uint _S1260 = _slang_select(_S1259, 384U,_S1258);
            uint _S1261 = stream(_S1247, _S1260);
            Random _S1262 = pcg(_S1261);
            float _S1263 = freeFlight_0(_S1262.value, spread_2);
            if(passes_0)
            {
                float3  _S1264 = (&ray_2)->origin;
                float3  _S1265 = (&ray_2)->unit_direction;
                float _S1266 = (&hit_4)->distance;
                uint _S1267 = _slang_select(_S1259, 0U,b_8);
                uint _S1268 = (&prev_0)->lobe;
                uint _S1269 = _slang_select(_S1259, 3U,_S1268);
                float _S1270 = (fcptTrackMedium((_S1253), (_S1264), (_S1265), (_S1266), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1267), (_S1269), (_S1259)));
                wavelength_2 = _S1270;
            }
            else
            {
                wavelength_2 = _S1263;
            }
            bool _S1271 = !(wavelength_2 < ((&hit_4)->distance));
            if(_S1271)
            {
                _S1218 = int(1);
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
                float3  _S1272 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1273 = sel_7->glow + _S1272;
                sel_7->glow = _S1273;
            }
            else
            {
            }
            glowed_0 = _S1219;
            uint b_10 = b_8 + 1U;
            float3  _S1274 = (&ray_2)->origin + make_float3 (wavelength_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1274;
            float3  _S1275 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, wavelength_2, true);
            float3  _S1276 = weight_1;
            float3  _S1277 = _slang_select(passes_0, _S1276,_S1275);
            float3  throughput_4 = throughput_2 * _S1277;
            uint _S1278 = stream(_S1247, b_10 + 320U);
            tracking_0 = _S1278;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_2 * wavelength_2;
            float _S1279 = threshold_2 + 3.14159274101257324f;
            bool _S1280 = scatterSampled_0(replay_2, b_10, _S1235, passes_0);
            TreeSample _S1281 = TreeSample_x24init_0(_S1219, _S1219, 0.0f, 0U);
            if(_S1280)
            {
                float3  _S1282 = (&ray_2)->origin;
                float3  _S1283 = (&ray_2)->unit_direction;
                float3  _S1284 = (&ray_2)->unit_direction;
                uint _S1285 = stream(_S1247, b_10 + 64U);
                float3  _S1286 = extinction_in_0;
                float3  _S1287 = extinction_in_0;
                uint2  _S1288 = make_uint2 (_S1253);
                float3  _S1289 = (&ray_2)->unit_direction;
                uint _S1290 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                FKHit _S1291 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1292 = _S1291;
                ShadowContext _S1293 = ShadowContext_x24init_0(_S1286, _S1287, _S1288, _S1289, b_10, _S1290, false, wavelength_2, width_6, &_S1292, false);
                ShadowContext _S1294 = _S1293;
                TreeSample _S1295 = sampleLightTree_0(_S1282, _S1283, _S1284, 0.0f, true, _S1285, &_S1294);
                light_3 = _S1295;
            }
            else
            {
                light_3 = _S1281;
            }
            float _S1296 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1297 = (fcptMaxBounces());
            bool _S1298 = b_10 < _S1297;
            if(_S1298)
            {
                is_inside_5 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_5 = false;
            }
            float _S1299 = _slang_select(is_inside_5, _S1296,0.0f);
            float3  _S1300 = throughput_4 * light_3.radiance;
            float _S1301 = powerHeuristic(light_3.density, _S1299);
            float3  _S1302 = _S1300 * make_float3 (_S1296 * _S1301);
            float3  _S1303 = _slang_select(_S1280, _S1302,_S1219);
            if(replay_2)
            {
                viewed_0 = b_10 == _S1235;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1304 = _S1224 == 2U;
                if(_S1304)
                {
                    float _S1305 = resamplingTarget(_S1303);
                    passes_0 = _S1305 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1306 = Shift_x24init_0(_S1303, 1.0f);
                    _S1218 = int(0);
                    ended_0 = _S1306;
                    spread_2 = _S1279;
                    wavelength_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_10;
                    break;
                }
                _S1218 = int(0);
                ended_0 = _S1220;
                spread_2 = _S1279;
                wavelength_2 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_10;
                break;
            }
            bool _S1307 = !replay_2;
            if(_S1307)
            {
                Reservoir candidate_3 = _S1252;
                uint _S1308 = extractBits_0(_S1252.path, 10U, 2U);
                bool _S1309 = _S1308 == 1U;
                if(_S1309)
                {
                    float3  _S1310 = safeDivide(_S1303, _S1219);
                    (&candidate_3)->radiance = _S1310;
                }
                else
                {
                    uint _S1311 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                    uint _S1312 = insertBits_0(_S1311, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1312;
                }
                Reservoir _S1313 = withEnd(candidate_3, 0U, b_10, _S1303);
                offer(sel_7, _S1313, _S1303 * make_float3 (scale_4) / make_float3 (density_2));
                float _S1314 = survivalProbability(abs_0(throughput_4), density_2);
                uint _S1315 = stream(_S1247, b_10 + 128U);
                Random _S1316 = pcg(_S1315);
                bool _S1317 = _S1314 < (_S1316.value);
                if(_S1317)
                {
                    scatter_2 = true;
                }
                else
                {
                    uint _S1318 = (fcptMaxBounces());
                    scatter_2 = b_10 >= _S1318;
                }
                if(scatter_2)
                {
                    _S1218 = int(0);
                    ended_0 = _S1220;
                    spread_2 = _S1279;
                    wavelength_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_10;
                    break;
                }
                float _S1319 = density_2 * _S1314;
                density_2 = _S1319;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1320 = stream(_S1247, b_10);
            float3  _S1321 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1320, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1321;
            NEEVertex _S1322 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1219, (&ray_2)->origin);
            nee_vertex_0 = _S1322;
            Vertex _S1323 = scatteredVertex_0(false);
            prev_0 = _S1323;
            float _S1324 = (&prev_0)->pdf;
            FKRay _S1325 = ray_2;
            FKHit _S1326 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1327 = (fcptTraverseInstanceBVH((_S1325), (true), (4.294967296e+09f), (false), (_S1326), (false)));
            hit_4 = _S1327;
            b_8 = b_10;
            throughput_2 = throughput_4;
            threshold_2 = _S1279;
            width_3 = width_6;
            sky_pdf_0 = _S1324;
        }
        if(_S1218 != int(1))
        {
            width_3 = wavelength_2;
            throughput_2 = chain_throughput_0;
            b_8 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1220;
        spread_2 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1328 = b_8 == 4294967295U;
    bool _S1329 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1329)
    {
        bool _S1330 = !(&nee_vertex_0)->none;
        float _S1331 = _slang_select(_S1330, sky_pdf_0,0.0f);
        float _S1332 = escapeWeight_0(_S1331, (&ray_2)->unit_direction);
        float3  _S1333 = environment_0((&ray_2)->unit_direction, b_8, (&prev_0)->lobe);
        float3  _S1334 = throughput_2 * _S1333;
        if(replay_2)
        {
            bool _S1335 = b_8 == _S1235;
            if(_S1335)
            {
                passes_0 = _S1224 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1334 * make_float3 (_S1332) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1234)
            {
                passes_0 = _S1231;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_8 == _S1222;
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
                return Shift_x24init_0(_S1334 * make_float3 (_S1332), 1.0f);
            }
            return _S1220;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1336 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1337 = _S1336 == 1U;
        if(_S1337)
        {
            uint _S1338 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1339 = _S1338 == b_8;
            float _S1340 = _slang_select(_S1339, 1.0f,_S1332);
            float3  _S1341 = safeDivide(_S1334 * make_float3 (_S1340), _S1219);
            (&candidate_4)->radiance = _S1341;
        }
        else
        {
            bool _S1342 = (&prev_0)->rough;
            if(_S1342)
            {
                uint _S1343 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                uint _S1344 = insertBits_0(_S1343, 3U, 10U, 2U);
                uint _S1345 = insertBits_0(_S1344, (&prev_0)->lobe, 15U, 3U);
                bool _S1346 = (&prev_0)->inside;
                uint _S1347 = _slang_select(_S1346, 1U,0U);
                uint _S1348 = insertBits_0(_S1345, _S1347, 22U, 1U);
                (&candidate_4)->path = _S1348;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1349 = _S1334 * make_float3 (_S1332);
        Reservoir _S1350 = withEnd(candidate_4, 3U, b_8, _S1349);
        offer(sel_7, _S1350, _S1349 * make_float3 (scale_4) / make_float3 (density_2));
        return _S1220;
    }
    float3  _S1351 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1351;
    bool _S1352 = (fcptVaryingUsed());
    if(_S1352)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1353 = !replay_2;
        if(_S1353)
        {
            float3  _S1354 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1355 = sel_7->glow + _S1354;
            sel_7->glow = _S1355;
        }
        float3  _S1356 = throughput_2 * weight_1;
        throughput_2 = _S1356;
    }
    else
    {
        float3  _S1357 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1358 = throughput_2 * _S1357;
        throughput_2 = _S1358;
    }
    float _S1359 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1360 = b_8 + 1U;
    b_8 = _S1360;
    layer_0 = 0U;
    width_3 = _S1359;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    wavelength_2 = 0.0f;
    chain_throughput_0 = _S1219;
    float3  reconnection_0 = _S1219;
    viewed_0 = _S1328;
    for(;;)
    {
        bool _S1361 = ((&hit_4)->is_point_light) == 1U;
        FKMedium _S1362 = Medium_x24init_0(_S1219, _S1219, 0.0f);
        BSDFMaterial _S1363 = Material_x24init_0(_S1219, _S1219, 0.0f, 0.0f, 0.0f, 0.0f, _S1219, throughput_3, 1.0f, _S1219, _S1219, 0.5f, 0.0f, 0.0f, _S1219, 0.0f, _S1219, 0.0f);
        FKMedium _S1364 = _S1362;
        FKSurface _S1365 = Surface_x24init_0(_S1219, _S1219, 0.0f, &_S1363, false, 0U, 1.0f, false, &_S1364, 4294967295U, _S1219);
        bool _S1366 = !_S1361;
        bool is_inside_6;
        float geometry_density_2;
        float3  throughput_5;
        FKSurface surface_11;
        if(_S1366)
        {
            uint _S1367 = stream(_S1247, b_8);
            uint _S1368 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKSurface _S1369 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1367), (width_3), (layer_0), (b_8), (_S1368), ((&ray_2)->unit_direction)));
            bool _S1370 = !passes_0;
            FKSurface _S1371 = _S1369;
            FKSurface _S1372 = emitting_0(&_S1371, _S1370);
            uint _S1373 = stream(_S1247, b_8 + 256U);
            Random _S1374 = pcg(_S1373);
            FKSurface _S1375 = _S1372;
            FKSurface _S1376 = uncovered_0(&_S1375, _S1374.value);
            float _S1377 = facingSign(_S1376.material.transmission, _S1376.geometry_n, (&ray_2)->unit_direction);
            bool _S1378 = _S1377 < 0.0f;
            bool _S1379 = (_S1376.material.transmission) > 0.0f;
            if(_S1379)
            {
                bool _S1380 = arrivesBehind_0((&ray_2)->unit_direction, _S1376.geometry_n);
                scatter_2 = _S1380;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1381 = _S1376;
            FKSurface _S1382 = facingRay_0(&_S1381, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1383 = arrivesBehind_0((&ray_2)->unit_direction, _S1382.geometry_n);
                is_inside_6 = _S1383;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S1384 = beerLambert((&hit_4)->distance, _S1382.material.absorption);
                float3  _S1385 = throughput_2 * _S1384;
                throughput_5 = _S1385;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1386 = !_S1382.skip;
            float geometry_density_3 = geometryDensity(_S1382.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1387 = b_8 == _S1360;
            if(_S1387)
            {
                float _S1388 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1388;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1389 = geometry_density_2;
            scatter_2 = _S1386;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1389;
            surface_11 = _S1382;
            turned_1 = _S1378;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_11 = _S1365;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S1390 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1391 = surface_11;
        FKSurface _S1392 = surface_11;
        float _S1393 = dot_0(surface_11.smooth_n, - (&ray_2)->unit_direction);
        bool _S1394 = (fcptDispersionUsed());
        bool _S1395;
        if(_S1394)
        {
            _S1395 = wavelength_2 == 0.0f;
        }
        else
        {
            _S1395 = false;
        }
        bool _S1396;
        if(_S1395)
        {
            _S1396 = scatter_2;
        }
        else
        {
            _S1396 = false;
        }
        bool _S1397;
        if(_S1396)
        {
            bool _S1398 = dispersive(_S1391.material);
            _S1397 = _S1398;
        }
        else
        {
            _S1397 = false;
        }
        float3  throughput_6;
        if(_S1397)
        {
            uint _S1399 = stream(_S1247, 512U);
            Random _S1400 = pcg(_S1399);
            float2  _S1401 = sampleWavelength(_S1400.value);
            float _S1402 = _S1401.x;
            float3  _S1403 = wavelengthWeights(_S1402);
            float3  _S1404 = throughput_5 * (_S1403 / make_float3 (_S1401.y));
            wavelength_2 = _S1402;
            throughput_6 = _S1404;
        }
        else
        {
            throughput_6 = throughput_5;
        }
        BSDFMaterial refractive_0 = _S1391.material;
        float _S1405 = dispersedIor(_S1391.material.ior, _S1391.material.dispersion, wavelength_2);
        bool _S1406 = wavelength_2 > 0.0f;
        float _S1407 = _slang_select(_S1406, _S1405,_S1391.material.ior);
        (&refractive_0)->ior = _S1407;
        float2  _S1408 = vertexEta(refractive_0, _S1393);
        bool _S1409;
        if(scatter_2)
        {
            bool _S1410 = neeDecision(_S1391.material, _S1393, _S1408.x, _S1408.y);
            _S1409 = _S1410;
        }
        else
        {
            _S1409 = false;
        }
        bool _S1411;
        if(passes_0)
        {
            _S1411 = true;
        }
        else
        {
            _S1411 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1411)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1409;
        }
        bool _S1412 = (fcptHairUsed());
        bool _S1413;
        if(_S1412)
        {
            float3  _S1414 = surface_11.hair;
            _S1413 = (dot_0(_S1414, _S1414)) > 0.0f;
        }
        else
        {
            _S1413 = false;
        }
        bool _S1415;
        if(_S1413)
        {
            _S1415 = true;
        }
        else
        {
            BSDFMaterial _S1416 = _S1391.material;
            bool _S1417 = isTranslucent_0(&_S1416);
            _S1415 = _S1417;
        }
        bool _S1418;
        if(_S1415)
        {
            _S1418 = true;
        }
        else
        {
            bool _S1419 = (_S1391.material.transmission) > 0.0f;
            if(_S1419)
            {
                uint _S1420 = (fcptLayers((hit_4)));
                _S1418 = _S1420 == 1U;
            }
            else
            {
                _S1418 = false;
            }
        }
        float3  emission_0;
        if(_S1361)
        {
            float3  _S1421 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1421;
        }
        else
        {
            emission_0 = _S1391.material.emissive;
        }
        float _S1422 = rgb_to_greyscale(emission_0);
        bool _S1423 = _S1422 > 0.0f;
        float3  emission_1;
        if(_S1423)
        {
            NEEVertex _S1424 = nee_vertex_0;
            FKHit _S1425 = hit_4;
            float _S1426 = emissionWeight_0(&_S1424, &_S1425, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1426);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1427;
        if(replay_2)
        {
            _S1427 = _S1224 == 1U;
        }
        else
        {
            _S1427 = false;
        }
        bool _S1428;
        if(_S1427)
        {
            _S1428 = b_8 > _S1223;
        }
        else
        {
            _S1428 = false;
        }
        bool _S1429;
        if(_S1428)
        {
            _S1429 = b_8 == _S1222;
        }
        else
        {
            _S1429 = false;
        }
        bool _S1430;
        if(_S1429)
        {
            bool _S1431 = _S1225 == 1U;
            if(_S1431)
            {
                _S1430 = true;
            }
            else
            {
                _S1430 = _S1225 == 2U;
            }
        }
        else
        {
            _S1430 = false;
        }
        if(_S1430)
        {
            bool _S1432 = _S1361 != (_S1225 == 2U);
            if(_S1432)
            {
                return _S1220;
            }
            return Shift_x24init_0(throughput_6 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1433 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1434 = _S1433 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1435 = insertBits_0(0U, b_8, 5U, 5U);
        uint _S1436 = insertBits_0(_S1435, 1U, 10U, 2U);
        uint _S1437 = insertBits_0(_S1436, (&prev_0)->lobe, 15U, 3U);
        bool _S1438 = (&prev_0)->inside;
        uint _S1439 = _slang_select(_S1438, 1U,0U);
        uint _S1440 = insertBits_0(_S1437, _S1439, 22U, 1U);
        (&here_0)->path = _S1440;
        uint _S1441 = (&here_0)->path;
        uint _S1442 = _slang_select(_S1406, 1U,0U);
        uint _S1443 = insertBits_0(_S1441, _S1442, 23U, 1U);
        (&here_0)->path = _S1443;
        float _S1444 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1444;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1445;
        if(replay_2)
        {
            _S1445 = _S1224 == 1U;
        }
        else
        {
            _S1445 = false;
        }
        bool _S1446;
        if(_S1445)
        {
            _S1446 = b_8 == _S1223;
        }
        else
        {
            _S1446 = false;
        }
        bool _S1447 = b_8 == _S1235;
        bool _S1448;
        if(_S1447)
        {
            bool _S1449 = !scatter_2;
            if(_S1449)
            {
                _S1448 = true;
            }
            else
            {
                bool _S1450 = _S1224 != 1U;
                if(_S1450)
                {
                    _S1448 = _S1224 != 3U;
                }
                else
                {
                    _S1448 = false;
                }
            }
        }
        else
        {
            _S1448 = false;
        }
        bool _S1451;
        if(_S1448)
        {
            _S1451 = _S1224 == 2U;
        }
        else
        {
            _S1451 = false;
        }
        bool _S1452;
        if(_S1451)
        {
            _S1452 = !_S1390;
        }
        else
        {
            _S1452 = false;
        }
        bool _S1453;
        if(_S1452)
        {
            _S1453 = _S1225 != 4U;
        }
        else
        {
            _S1453 = false;
        }
        bool _S1454 = _S1223 == _S1222;
        bool _S1455;
        if(_S1454)
        {
            _S1455 = _S1225 == 0U;
        }
        else
        {
            _S1455 = false;
        }
        bool _S1456;
        if(_S1455)
        {
            _S1456 = ((&hit_4)->instance_index) == (_S1236.instance_index);
        }
        else
        {
            _S1456 = false;
        }
        bool _S1457;
        if(_S1456)
        {
            _S1457 = ((&hit_4)->triangle_index) == (_S1236.triangle_index);
        }
        else
        {
            _S1457 = false;
        }
        bool _S1458;
        if(_S1457)
        {
            _S1458 = _S1390;
        }
        else
        {
            _S1458 = false;
        }
        bool _S1459 = _slang_select(_S1446, _S1458,_S1453);
        bool _S1460;
        if(nee_0)
        {
            _S1460 = _slang_select(replay_2, _S1459,scatter_2);
        }
        else
        {
            _S1460 = false;
        }
        TreeSample _S1461 = TreeSample_x24init_0(_S1219, _S1219, 0.0f, 0U);
        uint2  _S1462 = make_uint2 (0U);
        float2  _S1463 = make_float2 (0.0f);
        FKHit _S1464 = Hit_x24init_0(_S1463, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1465 = _S1464;
        ShadowContext _S1466 = ShadowContext_x24init_0(_S1219, _S1219, _S1462, _S1219, 0U, 0U, false, 0.0f, 0.0f, &_S1465, false);
        ShadowContext context_5;
        if(nee_0)
        {
            uint _S1467 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKMedium _S1468 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1469 = surface_11;
            FKHit _S1470 = hit_4;
            FKMedium _S1471 = _S1468;
            ShadowContext _S1472 = shadowContext_0(&_S1469, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_8, _S1467, (&hit_4)->distance, width_3, &_S1470, _S1413, &_S1471);
            context_5 = _S1472;
        }
        else
        {
            context_5 = _S1466;
        }
        float3  throughput_7;
        float3  lit_0;
        if(_S1460)
        {
            float3  _S1473 = (&ray_2)->origin;
            if(_S1413)
            {
                throughput_7 = _S1219;
            }
            else
            {
                throughput_7 = _S1392.smooth_n;
            }
            FKSurface _S1474 = surface_11;
            uint _S1475 = stream(_S1247, b_8 + 64U);
            ShadowContext _S1476 = context_5;
            TreeSample _S1477 = sampleLightTree_0(_S1473, throughput_7, surface_11.geometry_n, surface_11.geometry_offset, _S1418, _S1475, &_S1476);
            bool _S1478 = any_1((_S1477.radiance) != _S1219);
            if(_S1478)
            {
                if(_S1413)
                {
                    uint _S1479 = (fcptMaxBounces());
                    bool _S1480 = b_8 < _S1479;
                    FKSurface _S1481 = surface_11;
                    TreeSample _S1482 = _S1477;
                    float3  _S1483 = hairLight_0(&_S1481, (&ray_2)->unit_direction, &_S1482, _S1480);
                    lit_0 = _S1483;
                }
                else
                {
                    float _S1484 = _S1408.x;
                    float _S1485 = _S1408.y;
                    uint _S1486 = (fcptMaxBounces());
                    bool _S1487 = b_8 < _S1486;
                    TreeSample _S1488 = _S1477;
                    BSDFMaterial _S1489 = _S1391.material;
                    float3  _S1490 = lightBSDF_0((&ray_2)->unit_direction, &_S1488, _S1392.smooth_n, _S1474.geometry_n, &_S1489, _S1484, _S1485, _S1487, surface_11.random_state);
                    lit_0 = _S1490;
                }
            }
            else
            {
                lit_0 = _S1219;
            }
            light_3 = _S1477;
        }
        else
        {
            light_3 = _S1461;
            lit_0 = _S1219;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1491;
        bool _S1492;
        float density_4;
        if(_S1446)
        {
            bool _S1493 = ((&hit_4)->instance_index) != (_S1236.instance_index);
            if(_S1493)
            {
                viewed_1 = true;
            }
            else
            {
                viewed_1 = ((&hit_4)->triangle_index) != (_S1236.triangle_index);
            }
            if(viewed_1)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = !_S1390;
            }
            if(refracted_4)
            {
                return _S1220;
            }
            uint _S1494 = extractBits_0(_S1221, 23U, 1U);
            bool _S1495 = _S1406 != (_S1494 == 1U);
            if(_S1495)
            {
                return _S1220;
            }
            float3  throughput_8 = throughput_6 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1454)
            {
                wrong_side_0 = _S1225 == 1U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                return Shift_x24init_0(throughput_8 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1454)
            {
                _S1491 = _S1225 == 0U;
            }
            else
            {
                _S1491 = false;
            }
            if(_S1491)
            {
                bool _S1496 = !nee_0;
                if(_S1496)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1497 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1497 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1220;
                }
                return Shift_x24init_0(throughput_8 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1454)
            {
                _S1492 = _S1225 == 4U;
            }
            else
            {
                _S1492 = false;
            }
            if(_S1492)
            {
                bool _S1498 = !nee_0;
                if(_S1498)
                {
                    return _S1220;
                }
                float _S1499 = environmentPdf_0(r_8->dir);
                float3  _S1500 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_11, _S1408, is_inside_6, _S1499, surface_11.random_state);
                return Shift_x24init_0(throughput_8 * _S1500 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1501 = extractBits_0(_S1221, 21U, 1U);
            bool _S1502 = nee_0 != (_S1501 == 1U);
            if(_S1502)
            {
                return _S1220;
            }
            throughput_7 = throughput_8;
            density_4 = density_5;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1447;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1503 = !scatter_2;
                if(_S1503)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1504 = _S1224 != 1U;
                    if(_S1504)
                    {
                        refracted_4 = _S1224 != 3U;
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
                bool _S1505 = _S1224 == 2U;
                if(_S1505)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1390;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1225 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1413)
                    {
                        return _S1220;
                    }
                    uint _S1506 = stream(_S1247, b_8 + 448U);
                    FKRay _S1507 = ray_2;
                    FKSurface _S1508 = surface_11;
                    ShadowContext _S1509 = context_5;
                    SkySample _S1510 = sampleSky_0(&_S1507, &_S1508, _S1408, is_inside_6, _S1506, surface_11.random_state, &_S1509);
                    return Shift_x24init_0(throughput_6 * _S1510.color, 1.0f);
                }
                if(_S1505)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1390;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1511 = rgb_to_greyscale(light_3.radiance);
                    bool _S1512 = !(_S1511 > 0.0f);
                    if(_S1512)
                    {
                        return _S1220;
                    }
                    return Shift_x24init_0(throughput_6 * lit_0, 1.0f);
                }
                if(_S1234)
                {
                    passes_0 = _S1225 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1361;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_6 * emission_1, 1.0f);
                }
                if(_S1234)
                {
                    passes_0 = _S1225 == 1U;
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
                    passes_0 = !_S1390;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_6 * emission_1, 1.0f);
                }
                return _S1220;
            }
            else
            {
                bool _S1513 = !replay_2;
                if(_S1513)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1514 = b_8 > 0U;
                    if(_S1514)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1434)
                        {
                            float3  _S1515 = safeDivide(throughput_6 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1515;
                        }
                        else
                        {
                            if(_S1390)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1516 = throughput_6 * emission_1;
                        Reservoir _S1517 = withEnd(candidate_5, 1U, b_8, _S1516);
                        offer(sel_7, _S1517, _S1516 * make_float3 (scale_4) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1518 = throughput_6 * emission_1;
                        float3  _S1519 = sel_7->glow + _S1518;
                        sel_7->glow = _S1519;
                    }
                    if(nee_0)
                    {
                        float3  _S1520 = throughput_6 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1434)
                        {
                            float3  _S1521 = safeDivide(_S1520, chain_throughput_0);
                            (&candidate_6)->radiance = _S1521;
                        }
                        else
                        {
                            if(_S1390)
                            {
                                candidate_6 = here_0;
                                uint _S1522 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1522;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1523 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                                uint _S1524 = insertBits_0(_S1523, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1524;
                            }
                        }
                        Reservoir _S1525 = withEnd(candidate_6, 0U, b_8, _S1520);
                        offer(sel_7, _S1525, _S1520 * make_float3 (scale_4) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1413)
                        {
                            _S1491 = false;
                        }
                        else
                        {
                            bool _S1526 = environmentMapped_0();
                            _S1491 = _S1526;
                        }
                    }
                    else
                    {
                        _S1491 = false;
                    }
                    if(_S1491)
                    {
                        uint _S1527 = (fcptMaxBounces());
                        _S1492 = b_8 < _S1527;
                    }
                    else
                    {
                        _S1492 = false;
                    }
                    if(_S1492)
                    {
                        uint _S1528 = stream(_S1247, b_8 + 448U);
                        FKRay _S1529 = ray_2;
                        FKSurface _S1530 = surface_11;
                        ShadowContext _S1531 = context_5;
                        SkySample _S1532 = sampleSky_0(&_S1529, &_S1530, _S1408, is_inside_6, _S1528, surface_11.random_state, &_S1531);
                        float3  _S1533 = throughput_6 * _S1532.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1434)
                        {
                            float3  _S1534 = safeDivide(_S1533, chain_throughput_0);
                            (&candidate_7)->radiance = _S1534;
                        }
                        else
                        {
                            if(_S1390)
                            {
                                candidate_7 = here_0;
                                uint _S1535 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1535;
                                (&candidate_7)->dir = _S1532.dir;
                                (&candidate_7)->radiance = _S1532.radiance;
                            }
                            else
                            {
                                uint _S1536 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                                uint _S1537 = insertBits_0(_S1536, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1537;
                            }
                        }
                        Reservoir _S1538 = withEnd(candidate_7, 4U, b_8, _S1533);
                        offer(sel_7, _S1538, _S1533 * make_float3 (scale_4) / make_float3 (density_2));
                    }
                }
            }
            throughput_7 = throughput_6;
            density_4 = density_2;
        }
        bool _S1539;
        bool _S1540;
        bool _S1541;
        bool straight_0;
        bool _S1542;
        bool _S1543;
        bool _S1544;
        bool _S1545;
        bool _S1546;
        bool _S1547;
        bool _S1548;
        bool _S1549;
        bool _S1550;
        bool _S1551;
        bool _S1552;
        bool _S1553;
        float density_6;
        float sky_pdf_2;
        float spread_5;
        uint b_11;
        float3  throughput_9;
        float3  throughput_10;
        float3  throughput_11;
        if(scatter_2)
        {
            MaterialTerms _S1554 = MaterialTerms_x24init_0(0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S1219, 0.0f, 0.0f, 0.0f, false, 0.0f);
            AnisotropicFrame _S1555 = AnisotropicFrame_x24init_0(_S1219, _S1463);
            ViewTerms _S1556 = ViewTerms_x24init_0(_S1219, _S1219, &_S1555, _S1219, 0.0f, _S1219, _S1219, _S1219, 0.0f, _S1219);
            bool _S1557 = !_S1413;
            MaterialTerms terms_7;
            ViewTerms view_terms_6;
            if(_S1557)
            {
                MaterialTerms terms_8 = precomputeMaterial(_S1391.material, _S1408.x, _S1408.y);
                ViewTerms _S1558 = precomputeView((&ray_2)->unit_direction, _S1392.smooth_n, _S1391.material, terms_8);
                terms_7 = terms_8;
                view_terms_6 = _S1558;
            }
            else
            {
                terms_7 = _S1554;
                view_terms_6 = _S1556;
            }
            if(replay_2)
            {
                viewed_1 = _S1447;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1559 = extractBits_0(_S1221, 15U, 3U);
            uint _S1560 = extractBits_0(_S1221, 18U, 3U);
            uint _S1561 = _slang_select(_S1446, _S1560,_S1559);
            float3  _S1562 = r_8->dir;
            bool refracted_5 = _S1561 == 1U;
            SampleBSDF _S1563 = SampleBSDF_x24init_0(_S1219, _S1219, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_8 = _S1563;
            float3  reconnection_1;
            SampleBSDF _S1564;
            if(viewed_1)
            {
                uint _S1565 = extractBits_0(_S1221, 22U, 1U);
                bool _S1566 = is_inside_6 != (_S1565 == 1U);
                if(_S1566)
                {
                    return _S1220;
                }
                bool _S1567 = _S1224 == 1U;
                if(_S1567)
                {
                    float3  _S1568 = (fcptHitPosition((_S1236)));
                    throughput_9 = _S1568;
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
                    BSDFMaterial _S1569 = _S1391.material;
                    bool _S1570 = isTranslucent_0(&_S1569);
                    if(_S1570)
                    {
                        refracted_4 = _S1561 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1571 = throughput_9 - (&ray_2)->origin;
                        float3  _S1572 = _slang_select(_S1567, _S1571,_S1562);
                        wrong_side_0 = (dot_0(_S1392.smooth_n, _S1572) * _S1393) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1567)
                {
                    float3  _S1573 = (&ray_2)->origin;
                    FKSurface _S1574 = surface_11;
                    float3  _S1575 = - _S1392.smooth_n;
                    bool _S1576 = is_inside_6 != refracted_4;
                    float3  _S1577 = _slang_select(_S1576, _S1575,_S1392.smooth_n);
                    float3  _S1578 = throughput_9 - (_S1573 + make_float3 (_S1574.geometry_offset) * _S1577);
                    float3  _S1579 = ((((_S1578)) * make_float3(rnorm3df(((_S1578)).x, ((_S1578)).y, ((_S1578)).z))));
                    reconnection_1 = _S1579;
                }
                else
                {
                    reconnection_1 = _S1562;
                }
                if(_S1413)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1580 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_11.geometry_n);
                    wrong_side_0 = _S1580;
                }
                if(wrong_side_0)
                {
                    return _S1220;
                }
                float3  _S1581 = throughput_9;
                throughput_9 = reconnection_1;
                b_11 = _S1561;
                wrong_side_0 = false;
                reconnection_1 = _S1581;
            }
            else
            {
                bool _S1582 = !_S1446;
                if(_S1582)
                {
                    SampleBSDF bsdf_sampled_0;
                    if(_S1413)
                    {
                        SampleBSDF _S1583 = (fcptSampleHair((surface_11.hair), (_S1391.material.albedo), (_S1391.material.specular_tint), ((&ray_2)->unit_direction), (surface_11.random_state)));
                        _S1564 = _S1583;
                    }
                    else
                    {
                        SampleBSDF _S1584 = sampleBSDF((&ray_2)->unit_direction, _S1392.smooth_n, _S1391.material, _S1408.x, _S1408.y, surface_11.random_state, _S1463, terms_7, view_terms_6);
                        _S1564 = _S1584;
                    }
                    bsdf_sampled_0 = _S1564;
                    if(_S1413)
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
                            return _S1220;
                        }
                        break;
                    }
                    if(_S1413)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1585 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_11.geometry_n);
                        wrong_side_0 = _S1585;
                    }
                    if(wrong_side_0)
                    {
                        _S1491 = (_S1391.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1491 = false;
                    }
                    if(_S1491)
                    {
                        float _S1586 = _S1408.x;
                        float _S1587 = _S1408.y;
                        ViewTerms _S1588 = precomputeView((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n, _S1391.material, terms_7);
                        SampleBSDF _S1589 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n, _S1391.material, _S1586, _S1587, (&bsdf_sampled_0)->random_state, _S1463, terms_7, _S1588);
                        (&bsdf_sampled_0)->unit_direction = _S1589.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1589.refracted;
                        (&bsdf_sampled_0)->throughput = _S1589.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1590 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n)) * surface_11.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1590;
                        }
                    }
                    uint _S1591 = (&bsdf_sampled_0)->lobe;
                    float3  _S1592 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1593 = (&bsdf_sampled_0)->refracted;
                    lobe_8 = bsdf_sampled_0;
                    float _S1594 = (&bsdf_sampled_0)->pdf;
                    float _S1595 = _slang_select(wrong_side_0, 0.0f,_S1594);
                    (&lobe_8)->pdf = _S1595;
                    throughput_9 = _S1592;
                    b_11 = _S1591;
                    refracted_4 = _S1593;
                }
                else
                {
                    throughput_9 = _S1562;
                    b_11 = _S1561;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1491 = true;
            }
            else
            {
                _S1491 = _S1446;
            }
            if(_S1491)
            {
                if(_S1413)
                {
                    SampleBSDF _S1596 = (fcptConnectHair((surface_11.hair), (_S1391.material.albedo), (_S1391.material.specular_tint), ((&ray_2)->unit_direction), (throughput_9)));
                    _S1564 = _S1596;
                }
                else
                {
                    SampleBSDF _S1597 = lobeBSDF((&ray_2)->unit_direction, throughput_9, _S1392.smooth_n, _S1391.material, _S1408.x, _S1408.y, b_11, surface_11.random_state, terms_7, view_terms_6);
                    _S1564 = _S1597;
                }
                lobe_8 = _S1564;
            }
            bool _S1598 = b_11 == 0U;
            if(_S1598)
            {
                _S1492 = true;
            }
            else
            {
                _S1492 = b_11 == 4U;
            }
            if(_S1492)
            {
                _S1539 = true;
            }
            else
            {
                _S1539 = b_11 == 6U;
            }
            if(_S1413)
            {
                _S1540 = false;
            }
            else
            {
                bool _S1599 = !_S1539;
                if(_S1599)
                {
                    bool _S1600 = (_S1391.material.roughness) == 0.0f;
                    if(_S1600)
                    {
                        _S1540 = true;
                    }
                    else
                    {
                        bool _S1601 = b_11 == 1U;
                        if(_S1601)
                        {
                            _S1540 = (_S1408.x) == (_S1408.y);
                        }
                        else
                        {
                            _S1540 = false;
                        }
                    }
                }
                else
                {
                    _S1540 = false;
                }
            }
            if(_S1557)
            {
                _S1541 = b_11 == 1U;
            }
            else
            {
                _S1541 = false;
            }
            if(_S1541)
            {
                straight_0 = (_S1391.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1542 = _S1557;
            }
            else
            {
                _S1542 = false;
            }
            if(_S1542)
            {
                _S1543 = b_11 == 1U;
            }
            else
            {
                _S1543 = false;
            }
            if(_S1543)
            {
                _S1544 = (_S1408.x) == (_S1408.y);
            }
            else
            {
                _S1544 = false;
            }
            BSDFMaterial _S1602 = _S1391.material;
            bool _S1603 = isTranslucent_0(&_S1602);
            if(_S1603)
            {
                _S1545 = _S1598;
            }
            else
            {
                _S1545 = false;
            }
            if(_S1545)
            {
                _S1546 = (dot_0(throughput_9, surface_11.geometry_n)) < 0.0f;
            }
            else
            {
                _S1546 = false;
            }
            if(nee_0)
            {
                _S1547 = !_S1540;
            }
            else
            {
                _S1547 = false;
            }
            if(_S1547)
            {
                _S1548 = !wrong_side_0;
            }
            else
            {
                _S1548 = false;
            }
            if(_S1548)
            {
                float _S1604 = (&lobe_8)->pdf;
                float3  _S1605 = (&ray_2)->origin;
                float3  _S1606 = _slang_select(_S1418, _S1219,_S1392.smooth_n);
                float3  _S1607 = (&ray_2)->origin;
                FKSurface _S1608 = surface_11;
                float3  _S1609 = - _S1392.smooth_n;
                float3  _S1610 = _slang_select(_S1546, _S1609,_S1392.smooth_n);
                NEEVertex _S1611 = NEEVertex_x24init_0(false, _S1604, _S1605, _S1606, _S1607 + make_float3 (_S1608.geometry_offset) * _S1610);
                nee_vertex_0 = _S1611;
            }
            else
            {
                if(_S1413)
                {
                    _S1549 = true;
                }
                else
                {
                    bool _S1612 = b_11 != 1U;
                    if(_S1612)
                    {
                        _S1549 = true;
                    }
                    else
                    {
                        _S1549 = (_S1408.x) != (_S1408.y);
                    }
                }
                if(_S1549)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1613 = withinInverseFootprint((&lobe_8)->pdf, _S1539, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1614 = roughLobe((&lobe_8)->pdf, _S1539, _S1391.material.roughness);
            if(_S1446)
            {
                bool _S1615 = !_S1613;
                if(_S1615)
                {
                    return _S1220;
                }
                bool _S1616 = _S1225 != 1U;
                if(_S1616)
                {
                    _S1549 = _S1225 != 2U;
                }
                else
                {
                    _S1549 = false;
                }
                if(_S1549)
                {
                    float _S1617 = (&lobe_8)->pdf;
                    float _S1618 = _slang_select(nee_0, _S1617,0.0f);
                    float _S1619 = escapeWeight_0(_S1618, _S1562);
                    if(_S1454)
                    {
                        passes_0 = _S1231;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1620 = _slang_select(passes_0, _S1619,1.0f);
                    return Shift_x24init_0(throughput_7 * ((&lobe_8)->throughput * make_float3 ((&lobe_8)->pdf)) * r_8->radiance * make_float3 (_S1620) / make_float3 (r_8->jac), density_4 * (&lobe_8)->pdf / r_8->jac);
                }
                float3  _S1621 = throughput_7 * make_float3 ((&lobe_8)->pdf);
                float _S1622 = density_4 * (&lobe_8)->pdf;
                throughput_10 = _S1621;
                density_6 = _S1622;
            }
            else
            {
                throughput_10 = throughput_7;
                density_6 = density_4;
            }
            uint _S1623 = (fcptLayers((hit_4)));
            bool _S1624 = b_11 == 1U;
            bool _S1625 = passesLayer_0(_S1623, _S1624, passes_0);
            if(viewed_1)
            {
                _S1549 = _S1625;
            }
            else
            {
                _S1549 = false;
            }
            if(_S1549)
            {
                return _S1220;
            }
            if(replay_2)
            {
                _S1550 = b_8 <= _S1235;
            }
            else
            {
                _S1550 = false;
            }
            if(_S1550)
            {
                _S1551 = _S1390;
            }
            else
            {
                _S1551 = false;
            }
            if(_S1551)
            {
                _S1552 = _S1613;
            }
            else
            {
                _S1552 = false;
            }
            if(_S1552)
            {
                _S1553 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1553 = !_S1614;
                }
                else
                {
                    _S1553 = false;
                }
            }
            if(_S1553)
            {
                return _S1220;
            }
            if(viewed_1)
            {
                float3  _S1626 = throughput_10 * ((&lobe_8)->throughput * make_float3 ((&lobe_8)->pdf));
                float _S1627 = (&lobe_8)->pdf;
                throughput_11 = _S1626;
                sky_pdf_2 = _S1627;
            }
            else
            {
                float3  _S1628 = throughput_10 * max_0((&lobe_8)->throughput, _S1219);
                throughput_11 = _S1628;
                sky_pdf_2 = density_6;
            }
            bool _S1629 = !replay_2;
            bool _S1630;
            if(_S1629)
            {
                _S1630 = !_S1434;
            }
            else
            {
                _S1630 = false;
            }
            bool _S1631;
            if(_S1630)
            {
                _S1631 = _S1390;
            }
            else
            {
                _S1631 = false;
            }
            bool _S1632;
            if(_S1631)
            {
                _S1632 = _S1613;
            }
            else
            {
                _S1632 = false;
            }
            float3  chain_throughput_1;
            if(_S1632)
            {
                chain_0 = here_0;
                uint _S1633 = insertBits_0((&chain_0)->path, b_11, 18U, 3U);
                uint _S1634 = _slang_select(nee_0, 1U,0U);
                uint _S1635 = insertBits_0(_S1633, _S1634, 21U, 1U);
                (&chain_0)->path = _S1635;
                float _S1636 = (&chain_0)->jac * (&lobe_8)->pdf;
                (&chain_0)->jac = _S1636;
                (&chain_0)->dir = throughput_9;
                chain_throughput_1 = throughput_11;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1637 = surface_11;
            Vertex _S1638 = Vertex_x24init_0(_S1614, b_11, (&lobe_8)->pdf, (F32_abs((dot_0(surface_11.geometry_n, throughput_9)))), is_inside_6);
            prev_0 = _S1638;
            float _S1639 = (&lobe_8)->pdf;
            bool _S1640;
            if(_S1624)
            {
                _S1640 = (_S1408.x) == (_S1408.y);
            }
            else
            {
                _S1640 = false;
            }
            float sky_pdf_3 = _slang_select(_S1640, sky_pdf_0,_S1639);
            float _S1641 = _slang_select(_S1413, 0.0f,sky_pdf_3);
            float _S1642 = widened_0(spread_2, (&lobe_8)->pdf, _S1540);
            bool _S1643;
            if(refracted_4)
            {
                _S1643 = !_S1546;
            }
            else
            {
                _S1643 = false;
            }
            bool is_inside_7;
            if(_S1643)
            {
                bool _S1644 = !is_inside_6;
                is_inside_7 = _S1644;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1645 = surface_11;
            bool _S1646 = boundsVolume_0(&_S1645);
            bool _S1647;
            if(_S1646)
            {
                _S1647 = !_S1625;
            }
            else
            {
                _S1647 = false;
            }
            if(_S1647)
            {
                FKSurface faced_2 = surface_11;
                float3  _S1648 = - _S1637.geometry_n;
                float3  _S1649 = _slang_select(turned_1, _S1648,_S1637.geometry_n);
                (&faced_2)->geometry_n = _S1649;
                FKMedium _S1650 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1651 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1652 = faced_2;
                FKMedium _S1653 = _S1650;
                FKMedium _S1654 = _S1651;
                MediumSides _S1655 = mediumSides_0(&_S1652, &_S1653, filling_2, (&ray_2)->unit_direction, &_S1654);
                bool _S1656 = leavesInFront_0((&faced_2)->geometry_n, throughput_9, _S1637.geometry_n);
                float3  _S1657 = _slang_select(_S1656, _S1655.front.scatter,_S1655.behind.scatter);
                scatter_in_0 = _S1657;
                float3  _S1658 = _slang_select(_S1656, _S1655.front.extinction,_S1655.behind.extinction);
                extinction_in_0 = _S1658;
                float _S1659 = _slang_select(_S1656, _S1655.front.g,_S1655.behind.g);
                g_in_0 = _S1659;
                uint _S1660 = _S1655.fillings.x;
                uint _S1661 = _S1655.fillings.y;
                uint _S1662 = _slang_select(_S1656, _S1661,_S1660);
                bool _S1663 = (fcptVaryingUsed());
                uint _S1664 = _slang_select(_S1663, _S1662,4294967295U);
                filling_2 = _S1664;
            }
            (&ray_2)->unit_direction = throughput_9;
            bool _S1665 = !_S1625;
            if(_S1665)
            {
                FKSurface _S1666 = surface_11;
                float _S1667 = _slang_select(straight_0, 0.0f,_S1666.geometry_offset);
                float3  _S1668 = - _S1392.smooth_n;
                bool _S1669 = is_inside_7 != _S1546;
                float3  _S1670 = _slang_select(_S1669, _S1668,_S1392.smooth_n);
                float3  _S1671 = (&ray_2)->origin + make_float3 (_S1667) * _S1670;
                (&ray_2)->origin = _S1671;
            }
            throughput_10 = throughput_11;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1625;
            viewed_1 = _S1544;
            sky_pdf_2 = _S1641;
            spread_5 = _S1642;
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
            spread_5 = spread_2;
            straight_0 = false;
            is_inside_5 = is_inside_6;
        }
        bool _S1672 = !replay_2;
        float density_7;
        if(_S1672)
        {
            if(_S1361)
            {
                float3  _S1673 = throughput_10 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1674 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1675 = _S1674 == 1U;
                if(_S1675)
                {
                    float3  _S1676 = safeDivide(_S1673, chain_throughput_0);
                    (&candidate_8)->radiance = _S1676;
                }
                Reservoir _S1677 = withEnd(candidate_8, 2U, b_8, _S1673);
                offer(sel_7, _S1677, _S1673 * make_float3 (scale_4) / make_float3 (density_6));
            }
            if(_S1361)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1678 = survivalProbability(abs_0(throughput_10), density_6);
                density_7 = _S1678;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1679 = stream(_S1247, b_8 + 128U);
            Random _S1680 = pcg(_S1679);
            bool _S1681 = density_7 < (_S1680.value);
            if(_S1681)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1682 = (fcptMaxBounces());
                wrong_side_0 = b_8 >= _S1682;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1683 = density_6 * density_7;
            density_7 = _S1683;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1684 = layer_0 ^ 1U;
        uint _S1685 = _slang_select(passes_0, _S1684,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_4)->distance = 0.0f;
            b_11 = b_8;
            viewed_0 = viewed_1;
            throughput_2 = throughput_10;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_2 = spread_5;
            uint _S1686 = b_11 + 1U;
            b_8 = _S1686;
            layer_0 = _S1685;
            continue;
        }
        FKRay _S1687 = ray_2;
        float _S1688 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1447;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1224 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1689 = _slang_select(wrong_side_0, _S1688,4.294967296e+09f);
        bool _S1690 = !_S1413;
        if(straight_0)
        {
            _S1491 = true;
        }
        else
        {
            _S1491 = _S1413;
        }
        FKHit _S1691;
        if(_S1491)
        {
            _S1691 = hit_4;
        }
        else
        {
            _S1691 = _S1464;
        }
        FKHit _S1692 = (fcptTraverseInstanceBVH((_S1687), (_S1366), (_S1689), (_S1690), (_S1691), (viewed_1)));
        hit_4 = _S1692;
        if(replay_2)
        {
            _S1492 = _S1447;
        }
        else
        {
            _S1492 = false;
        }
        if(_S1492)
        {
            _S1539 = _S1224 == 1U;
        }
        else
        {
            _S1539 = false;
        }
        if(_S1539)
        {
            _S1540 = ((&hit_4)->instance_index) == (_S1236.instance_index);
        }
        else
        {
            _S1540 = false;
        }
        if(_S1540)
        {
            _S1541 = ((&hit_4)->triangle_index) == (_S1236.triangle_index);
        }
        else
        {
            _S1541 = false;
        }
        if(_S1541)
        {
            (&hit_4)->uv = _S1236.uv;
            float _S1693 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1693;
        }
        if(replay_2)
        {
            _S1542 = _S1447;
        }
        else
        {
            _S1542 = false;
        }
        if(_S1542)
        {
            _S1543 = _S1224 == 3U;
        }
        else
        {
            _S1543 = false;
        }
        if(_S1543)
        {
            _S1544 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1544 = false;
        }
        if(_S1544)
        {
            return _S1220;
        }
        Reservoir _S1694 = chain_0;
        uint _S1695 = filling_2;
        for(;;)
        {
            bool _S1696 = (fcptVaryingUsed());
            if(_S1696)
            {
                _S1545 = _S1695 != 4294967295U;
            }
            else
            {
                _S1545 = false;
            }
            float _S1697;
            if(_S1545)
            {
                float _S1698 = (fcptMajorant((_S1695)));
                _S1697 = _S1698;
            }
            else
            {
                _S1697 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1546 = _S1447;
            }
            else
            {
                _S1546 = false;
            }
            if(_S1546)
            {
                _S1547 = _S1224 == 1U;
            }
            else
            {
                _S1547 = false;
            }
            if(_S1547)
            {
                _S1548 = _S1697 > 0.0f;
            }
            else
            {
                _S1548 = false;
            }
            if(_S1548)
            {
                ended_0 = _S1220;
                sky_pdf_1 = sky_pdf_2;
                spread_3 = spread_5;
                width_4 = width_3;
                density_3 = density_7;
                throughput_11 = throughput_10;
                b_11 = b_8;
                _S1549 = true;
                break;
            }
            bool _S1699 = (&prev_0)->rough;
            if(_S1699)
            {
                _S1549 = !(_S1697 > 0.0f);
            }
            else
            {
                _S1549 = false;
            }
            (&prev_0)->rough = _S1549;
            uint _S1700 = b_8 + 320U;
            bool _S1701 = b_8 == 4294967295U;
            uint _S1702 = _slang_select(_S1701, 384U,_S1700);
            uint _S1703 = stream(_S1247, _S1702);
            uint tracking_1 = _S1703;
            weight_1 = throughput_3;
            glowed_0 = _S1219;
            b_11 = b_8;
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
                    _S1218 = int(2);
                    break;
                }
                uint _S1704 = b_11 + 320U;
                bool _S1705 = b_11 == 4294967295U;
                uint _S1706 = _slang_select(_S1705, 384U,_S1704);
                uint _S1707 = stream(_S1247, _S1706);
                Random _S1708 = pcg(_S1707);
                float _S1709 = freeFlight_0(_S1708.value, _S1697);
                if(_S1545)
                {
                    float3  _S1710 = (&ray_2)->origin;
                    float3  _S1711 = (&ray_2)->unit_direction;
                    float _S1712 = (&hit_4)->distance;
                    uint _S1713 = _slang_select(_S1705, 0U,b_11);
                    uint _S1714 = (&prev_0)->lobe;
                    uint _S1715 = _slang_select(_S1705, 3U,_S1714);
                    float _S1716 = (fcptTrackMedium((_S1695), (_S1710), (_S1711), (_S1712), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1713), (_S1715), (_S1705)));
                    spread_4 = _S1716;
                }
                else
                {
                    spread_4 = _S1709;
                }
                bool _S1717 = !(spread_4 < ((&hit_4)->distance));
                if(_S1717)
                {
                    _S1218 = int(2);
                    break;
                }
                if(_S1545)
                {
                    _S1550 = _S1672;
                }
                else
                {
                    _S1550 = false;
                }
                if(_S1550)
                {
                    float3  _S1718 = throughput_11 * glowed_0 / make_float3 (density_3);
                    float3  _S1719 = sel_7->glow + _S1718;
                    sel_7->glow = _S1719;
                }
                else
                {
                }
                glowed_0 = _S1219;
                uint b_12 = b_11 + 1U;
                float3  _S1720 = (&ray_2)->origin + make_float3 (spread_4) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1720;
                float3  _S1721 = flightWeight_0(scatter_in_0, extinction_in_0, _S1697, spread_4, true);
                float3  _S1722 = weight_1;
                float3  _S1723 = _slang_select(_S1545, _S1722,_S1721);
                float3  throughput_12 = throughput_11 * _S1723;
                uint _S1724 = stream(_S1247, b_12 + 320U);
                tracking_1 = _S1724;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_3 * spread_4;
                float _S1725 = spread_3 + 3.14159274101257324f;
                bool _S1726 = scatterSampled_0(replay_2, b_12, _S1235, _S1545);
                TreeSample light_4;
                if(_S1726)
                {
                    float3  _S1727 = (&ray_2)->origin;
                    float3  _S1728 = (&ray_2)->unit_direction;
                    float3  _S1729 = (&ray_2)->unit_direction;
                    uint _S1730 = stream(_S1247, b_12 + 64U);
                    float3  _S1731 = extinction_in_0;
                    float3  _S1732 = extinction_in_0;
                    uint2  _S1733 = make_uint2 (_S1695);
                    float3  _S1734 = (&ray_2)->unit_direction;
                    uint _S1735 = arrivalLobe_0(b_12, (&prev_0)->lobe);
                    FKHit _S1736 = _S1464;
                    ShadowContext _S1737 = ShadowContext_x24init_0(_S1731, _S1732, _S1733, _S1734, b_12, _S1735, false, spread_4, width_7, &_S1736, false);
                    ShadowContext _S1738 = _S1737;
                    TreeSample _S1739 = sampleLightTree_0(_S1727, _S1728, _S1729, 0.0f, true, _S1730, &_S1738);
                    light_4 = _S1739;
                }
                else
                {
                    light_4 = _S1461;
                }
                float _S1740 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1741 = (fcptMaxBounces());
                bool _S1742 = b_12 < _S1741;
                if(_S1742)
                {
                    _S1551 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1551 = false;
                }
                float _S1743 = _slang_select(_S1551, _S1740,0.0f);
                float3  _S1744 = throughput_12 * light_4.radiance;
                float _S1745 = powerHeuristic(light_4.density, _S1743);
                float3  _S1746 = _S1744 * make_float3 (_S1740 * _S1745);
                float3  _S1747 = _slang_select(_S1726, _S1746,_S1219);
                if(replay_2)
                {
                    _S1552 = b_12 == _S1235;
                }
                else
                {
                    _S1552 = false;
                }
                if(_S1552)
                {
                    bool _S1748 = _S1224 == 2U;
                    if(_S1748)
                    {
                        float _S1749 = resamplingTarget(_S1747);
                        _S1553 = _S1749 > 0.0f;
                    }
                    else
                    {
                        _S1553 = false;
                    }
                    if(_S1553)
                    {
                        Shift _S1750 = Shift_x24init_0(_S1747, 1.0f);
                        _S1218 = int(1);
                        ended_0 = _S1750;
                        spread_4 = _S1725;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_9 = b_12;
                        break;
                    }
                    _S1218 = int(1);
                    ended_0 = _S1220;
                    spread_4 = _S1725;
                    width_5 = width_7;
                    throughput_9 = throughput_12;
                    b_9 = b_12;
                    break;
                }
                if(_S1672)
                {
                    Reservoir candidate_9 = _S1694;
                    uint _S1751 = extractBits_0(_S1694.path, 10U, 2U);
                    bool _S1752 = _S1751 == 1U;
                    if(_S1752)
                    {
                        float3  _S1753 = safeDivide(_S1747, chain_throughput_0);
                        (&candidate_9)->radiance = _S1753;
                    }
                    else
                    {
                        uint _S1754 = insertBits_0(0U, b_12 + 1U, 5U, 5U);
                        uint _S1755 = insertBits_0(_S1754, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1755;
                    }
                    Reservoir _S1756 = withEnd(candidate_9, 0U, b_12, _S1747);
                    offer(sel_7, _S1756, _S1747 * make_float3 (scale_4) / make_float3 (density_3));
                    float _S1757 = survivalProbability(abs_0(throughput_12), density_3);
                    uint _S1758 = stream(_S1247, b_12 + 128U);
                    Random _S1759 = pcg(_S1758);
                    bool _S1760 = _S1757 < (_S1759.value);
                    if(_S1760)
                    {
                        _S1553 = true;
                    }
                    else
                    {
                        uint _S1761 = (fcptMaxBounces());
                        _S1553 = b_12 >= _S1761;
                    }
                    if(_S1553)
                    {
                        _S1218 = int(1);
                        ended_0 = _S1220;
                        spread_4 = _S1725;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_9 = b_12;
                        break;
                    }
                    float _S1762 = density_3 * _S1757;
                    density_3 = _S1762;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1763 = stream(_S1247, b_12);
                float3  _S1764 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1763, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1764;
                NEEVertex _S1765 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1219, (&ray_2)->origin);
                nee_vertex_0 = _S1765;
                Vertex _S1766 = scatteredVertex_0(is_inside_5);
                prev_0 = _S1766;
                float _S1767 = (&prev_0)->pdf;
                FKRay _S1768 = ray_2;
                FKHit _S1769 = (fcptTraverseInstanceBVH((_S1768), (true), (4.294967296e+09f), (false), (_S1464), (false)));
                hit_4 = _S1769;
                b_11 = b_12;
                throughput_11 = throughput_12;
                spread_3 = _S1725;
                width_4 = width_7;
                sky_pdf_1 = _S1767;
            }
            if(_S1218 != int(2))
            {
                spread_3 = spread_4;
                width_4 = width_5;
                throughput_11 = throughput_9;
                b_11 = b_9;
                _S1549 = true;
                break;
            }
            ended_0 = _S1220;
            _S1549 = false;
            break;
        }
        if(_S1549)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1550 = b_11 == b_8;
        }
        else
        {
            _S1550 = false;
        }
        bool _S1770 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1770)
        {
            bool _S1771 = !(&nee_vertex_0)->none;
            float _S1772 = _slang_select(_S1771, sky_pdf_1,0.0f);
            float _S1773 = escapeWeight_0(_S1772, (&ray_2)->unit_direction);
            float3  _S1774 = environment_0((&ray_2)->unit_direction, b_11, (&prev_0)->lobe);
            float3  _S1775 = throughput_11 * _S1774;
            if(replay_2)
            {
                bool _S1776 = b_11 == _S1235;
                if(_S1776)
                {
                    passes_0 = _S1224 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1775 * make_float3 (_S1773) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1234)
                {
                    passes_0 = _S1231;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_11 == _S1222;
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
                    return Shift_x24init_0(_S1775 * make_float3 (_S1773), 1.0f);
                }
                return _S1220;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1777 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1778 = _S1777 == 1U;
            if(_S1778)
            {
                uint _S1779 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1780 = _S1779 == b_11;
                float _S1781 = _slang_select(_S1780, 1.0f,_S1773);
                float3  _S1782 = safeDivide(_S1775 * make_float3 (_S1781), chain_throughput_0);
                (&candidate_10)->radiance = _S1782;
            }
            else
            {
                bool _S1783 = (&prev_0)->rough;
                if(_S1783)
                {
                    uint _S1784 = insertBits_0(0U, b_11 + 1U, 5U, 5U);
                    uint _S1785 = insertBits_0(_S1784, 3U, 10U, 2U);
                    uint _S1786 = insertBits_0(_S1785, (&prev_0)->lobe, 15U, 3U);
                    bool _S1787 = (&prev_0)->inside;
                    uint _S1788 = _slang_select(_S1787, 1U,0U);
                    uint _S1789 = insertBits_0(_S1786, _S1788, 22U, 1U);
                    (&candidate_10)->path = _S1789;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1790 = _S1775 * make_float3 (_S1773);
            Reservoir _S1791 = withEnd(candidate_10, 3U, b_11, _S1790);
            offer(sel_7, _S1791, _S1790 * make_float3 (scale_4) / make_float3 (density_3));
            break;
        }
        float3  _S1792 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1792;
        bool _S1793 = (fcptVaryingUsed());
        if(_S1793)
        {
            _S1551 = filling_2 != 4294967295U;
        }
        else
        {
            _S1551 = false;
        }
        if(_S1551)
        {
            if(_S1672)
            {
                float3  _S1794 = throughput_11 * glowed_0 / make_float3 (density_3);
                float3  _S1795 = sel_7->glow + _S1794;
                sel_7->glow = _S1795;
            }
            float3  _S1796 = throughput_11 * weight_1;
            throughput_9 = _S1796;
        }
        else
        {
            float3  _S1797 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1798 = throughput_11 * _S1797;
            throughput_9 = _S1798;
        }
        float _S1799 = width_4 + spread_3 * (&hit_4)->distance;
        viewed_0 = _S1550;
        width_3 = _S1799;
        throughput_2 = throughput_9;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_3;
        uint _S1686 = b_11 + 1U;
        b_8 = _S1686;
        layer_0 = _S1685;
    }
    return _S1220;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_9)
{
    Selection _S1800 = (Selection{});
    Selection sel_8 = _S1800;
    bool _S1801 = (r_9->w) <= 0.0f;
    if(_S1801)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1802 = walk_0(dom_8, r_9, true, 0.0f, &sel_8);
    return _S1802;
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
        *_slang_vector_get_element_ptr(&result_15, i_21) = (F32_tan((_slang_vector_get_element(x_27, i_21))));
        i_21 = i_21 + int(1);
    }
    return result_15;
}

static __device__ float3  acos_0(float3  x_28)
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
        *_slang_vector_get_element_ptr(&result_16, i_22) = (F32_acos((_slang_vector_get_element(x_28, i_22))));
        i_22 = i_22 + int(1);
    }
    return result_16;
}

__device__ Random normal_distribution(uint state_3)
{
    Random _S1803 = pcg(state_3);
    Random _S1804 = pcg(_S1803.state);
    float _S1805 = 6.28318548202514648f * _S1803.value;
    float _S1806 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1804.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1804.state, _S1806 * (F32_cos((_S1805))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1807;
    (&_S1807)->state = state_4;
    (&_S1807)->value = value_2;
    return _S1807;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1808 = normal_distribution(state_5);
    Random _S1809 = normal_distribution(_S1808.state);
    Random _S1810 = normal_distribution(_S1809.state);
    float3  _S1811 = make_float3 (_S1808.value, _S1809.value, _S1810.value);
    float3  _S1812 = ((((_S1811)) * make_float3(rnorm3df(((_S1811)).x, ((_S1811)).y, ((_S1811)).z))));
    return RandomSphere_x24init_0(_S1810.state, _S1812);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_15)
{
    float3  _S1813 = p1_0 - p0_0;
    float3  _S1814 = p2_0 - p0_0;
    float2  _S1815 = uv1_0 - uv0_0;
    float2  _S1816 = uv2_0 - uv0_0;
    float _S1817 = _S1815.x;
    float _S1818 = _S1816.y;
    float _S1819 = _S1815.y;
    float _S1820 = _S1816.x;
    float _S1821 = _S1817 * _S1818 - _S1819 * _S1820;
    float _S1822 = 1.0f / _S1821;
    float3  t_22 = (_S1813 * make_float3 (_S1818) - _S1814 * make_float3 (_S1819)) * make_float3 (_S1822);
    float3  _S1823 = (_S1814 * make_float3 (_S1817) - _S1813 * make_float3 (_S1820)) * make_float3 (_S1822);
    float3  _S1824 = t_22 - n_15 * make_float3 (dot_0(n_15, t_22));
    float3  t_23 = ((((_S1824)) * make_float3(rnorm3df(((_S1824)).x, ((_S1824)).y, ((_S1824)).z))));
    bool _S1825 = (dot_0(cross_0(n_15, t_23), _S1823)) > 0.0f;
    float3  t_24;
    if(_S1825)
    {
        float3  _S1826 = negate_0(t_23);
        t_24 = _S1826;
    }
    else
    {
        t_24 = t_23;
    }
    float3  _S1827 = cross_0(n_15, t_24);
    return makeMatrix<float, 3, 3> (t_24, _S1827, n_15);
}

__device__ float3  tangentToWorldNormalMap(float3  v_4, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_4, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1828 = t1_0 - t0_0;
    float3  _S1829 = t2_2 - t0_0;
    float3  _S1830 = t2_2 - t1_0;
    float _S1831 = (F32_min((length_0(_S1828)), ((F32_min((length_0(_S1829)), (length_0(_S1830)))))));
    float3  _S1832 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1833 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1834 = dot_0(geometry_n_5, _S1833);
    float3  _S1835 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1836 = dot_0(geometry_n_5, _S1835);
    float3  _S1837 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1838 = acos_0(abs_0(make_float3 (_S1834, _S1836, dot_0(geometry_n_5, _S1837))));
    float3  _S1839 = clamp_2(tan_0(_S1838), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1832 * _S1839, uvw_0), 0.0f, _S1831 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_15, float3  n_16, BSDFMaterial material_19)
{
    float3  _S1840 = negate_0(dir_15);
    float _S1841 = sign_0(dot_0(n_16, _S1840));
    float3  _S1842 = n_16 * make_float3 (_S1841);
    AnisotropicFrame _S1843 = anisotropicFrame(material_19, _S1842);
    bool _S1844 = (_S1843.alphas.x) > 0.0f;
    if(_S1844)
    {
        float _S1845 = material_19.transmission * (1.0f - material_19.metallic);
        float3  _S1846 = negate_0(_S1842);
        float3  _S1847 = anisotropicLocal(dir_15, _S1843.tangent, _S1846);
        float _S1848 = anisotropicG1(_S1847, _S1843.alphas);
        return make_float3 (_S1845 * _S1848) * material_19.albedo;
    }
    float _S1849 = material_19.transmission * (1.0f - material_19.metallic);
    float _S1850 = material_19.roughness;
    float _S1851 = smithG1(_S1850 * _S1850, (F32_abs((dot_0(n_16, dir_15)))));
    return make_float3 (_S1849 * _S1851) * material_19.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_25, float3  out_dir_4, uint p_14, float w_2, float alpha_6, uint nt_0)
{
    uint _S1852 = p_14 % 4U;
    float _S1853 = w_2 * HAIR_WIDTHS_0[_S1852];
    float _S1854 = (F32_asin((clamp_1(dot_0(out_dir_4, t_25), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_25), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1852] * alpha_6;
    return ((F32_asinh((_S1854 / _S1853))) / (F32_asinh((3.14159274101257324f / _S1853))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_26, float3  out_dir_5, uint np_0)
{
    float3  _S1855 = worldToTangent(out_dir_5, t_26);
    float3  _S1856 = worldToTangent(in_dir_12, t_26);
    return (F32_frac((((F32_atan2((_S1855.z), (_S1855.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1856.z), (1.17549435082228751e-38f - _S1856.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_27, uint p_15, float row_0, float column_0, float w_3, float alpha_7, uint nt_1, uint np_1)
{
    float3  _S1857 = worldToTangent(in_dir_13, t_27);
    uint _S1858 = p_15 % 4U;
    float _S1859 = w_3 * HAIR_WIDTHS_0[_S1858];
    float _S1860 = (F32_asin((clamp_1(dot_0(in_dir_13, t_27), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1858] * alpha_7 + _S1859 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1859))))));
    float _S1861 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1857.z), (1.17549435082228751e-38f - _S1857.x)));
    float _S1862 = (F32_cos((_S1860)));
    float3  _S1863 = tangentToWorld(make_float3 (_S1862 * (F32_cos((_S1861))), (F32_sin((_S1860))), _S1862 * (F32_sin((_S1861)))), t_27);
    return _S1863;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_17, BSDFMaterial material_20, float coverage_1)
{
    float3  _S1864;
    if((material_20.ior) == 1.0f)
    {
        float3  _S1865 = straightThrough(toward_1, n_17, material_20);
        _S1864 = _S1865;
    }
    else
    {
        _S1864 = make_float3 (0.0f);
    }
    return _S1864 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_5, Selection * sel_9)
{
    Domain _S1866 = dom_9;
    Reservoir _S1867 = r_10;
    Shift _S1868 = walk_0(&_S1866, &_S1867, replay_3, scale_5, sel_9);
    return _S1868;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_11)
{
    Domain _S1869 = dom_10;
    Reservoir _S1870 = r_11;
    Shift _S1871 = shift_0(&_S1869, &_S1870);
    return _S1871;
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
