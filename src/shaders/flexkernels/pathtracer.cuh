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
    float _S465 = frame_2.alphas.x;
    float _S466 = (F32_sqrt(((F32_min((_S465), (frame_2.alphas.y))))));
    bool _S467 = _S465 > 0.0f;
    float _S468 = _slang_select(_S467, _S466,material_2.roughness);
    float _S469 = _S468 * _S468;
    float _S470 = (F32_pow((_S469), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S469) / (1.0f + 1.28094995021820068f * _S469);
    bool _S471 = _S469 > 0.0f;
    float _S472 = _slang_select(_S471, _S470,0.0f);
    float _S473 = clamp_1(dot_0(n_i_2, v_3), 0.0f, 1.0f);
    float _S474 = _S469 * _S468;
    float _S475 = (F32_min((1.00064504146575928f - _S468 * (0.00375499995425344f + _S473 * (-0.04133399948477745f + _S473 * (-0.90938502550125122f + _S473 * 0.35275399684906006f))) - _S469 * (0.27602800726890564f + _S473 * (1.27023398876190186f + _S473 * 0.04740000143647194f)) - _S474 * (0.31452900171279907f - _S473 * 0.34830701351165771f) + _S474 * _S468 * 0.27229699492454529f), (1.0f)));
    float3  _S476 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_2.albedo * make_float3 (_S472)), make_float3 (1.0f / (F32_max((_S475), (0.0000152587890625f)))));
    float3  _S477 = mix_0(_S415, material_2.albedo * _S476, material_2.metallic);
    float3  F_1 = _S477 * scale_1;
    float _S478 = rgb_to_greyscale(F_1);
    float _S479 = 1.0f - material_2.metallic;
    float3  _S480 = make_float3 (1.0f) - _S415;
    float3  _S481 = make_float3 ((1.0f - material_2.transmission) * _S479) * _S480 * scale_1;
    float3  _S482 = make_float3 (material_2.transmission * _S479) * _S480 * scale_1;
    float _S483 = (F32_max((_S478), (0.0f)));
    float _S484 = rgb_to_greyscale(_S481);
    float _S485 = (F32_max((_S484), (0.0f)));
    float _S486 = rgb_to_greyscale(_S482);
    float _S487 = sign_0(length_0(_S407));
    float _S488 = (F32_max((_S486 * _S487), (0.0f)));
    float _S489 = _S483 + _S485 + _S488 + toon_component_0;
    float _S490 = (F32_min((sheen_component_0), (1.0f)));
    bool _S491 = sheen_component_0 > 0.0f;
    if(_S491)
    {
        _S445 = !(_S489 > 0.0f);
    }
    else
    {
        _S445 = false;
    }
    float _S492 = _slang_select(_S445, 1.0f,_S490);
    float _S493 = (1.0f - _S492) / (F32_max((_S489), (0.0000152587890625f)));
    float _S494 = _S485 * _S493;
    float _S495 = _S483 * _S493;
    float _S496 = _S488 * _S493;
    float visible_1;
    if(_S467)
    {
        float3  _S497 = anisotropicLocal(v_3, frame_2.tangent, n_i_2);
        float _S498 = anisotropicG1(_S497, frame_2.alphas);
        float3  _S499 = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_2);
        float _S500 = anisotropicD(_S499, frame_2.alphas);
        float _S501 = _S498 * _S500;
        visible_1 = _S501;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S403, _S404, _S407, F_1, _S478, 1.0f, _S481, _S482, _S494, _S495, _S496, 0.0f, sheen_1, _S492, view_1, frame_2.tangent, frame_2.alphas, visible_1, toon_component_0 * _S493, toon_1, toon_a_1, toon_s_1, toon_b_1, _S442, toon_norm_1, toon_view_1, toon_axis_1);
}

__device__ float translucentShare(BSDFMaterial material_3)
{
    float _S502 = rgb_to_greyscale(material_3.translucent);
    float _S503 = rgb_to_greyscale(material_3.albedo);
    float _S504 = _S502 / (_S503 + _S502);
    bool _S505 = _S502 > 0.0f;
    float _S506 = _slang_select(_S505, _S504,0.0f);
    return _S506;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_2, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S507 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S508 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S509 = 1.0f - lobes_0.translucent_share;
    bool _S510 = n_i_dot_l_0 < 0.0f;
    float _S511 = _slang_select(_S510, lobes_0.translucent_share,_S509);
    float _S512 = _S508 * _S511;
    bool _S513 = (lobes_0.translucent_share) > 0.0f;
    float _S514 = _slang_select(_S513, _S512,_S507);
    bool _S515 = n_i_dot_v_0 > 0.0f;
    float _S516 = _slang_select(_S515, _S514,0.0f);
    return _S516;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_3, float alpha_3, BSDFMaterial material_4, BSDFLobes lobes_1)
{
    bool _S517 = (dot_0(n_i_3, l_0)) < 0.0f;
    float3  _S518 = _slang_select(_S517, material_4.translucent,material_4.albedo);
    float _S519 = 1.0f - lobes_1.translucent_share;
    float _S520 = _slang_select(_S517, lobes_1.translucent_share,_S519);
    float3  _S521 = _S518 / make_float3 (_S520);
    bool _S522 = (lobes_1.translucent_share) > 0.0f;
    float3  _S523 = _slang_select(_S522, _S521,material_4.albedo);
    return lobes_1.diffuse_weight * _S523 / make_float3 (lobes_1.p_diffuse);
}

__device__ float smithG1(float alpha_4, float n_dot_x_0)
{
    float _S524 = alpha_4 * alpha_4;
    float _S525 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S524 + (1.0f - _S524) * n_dot_x_0 * n_dot_x_0))));
    bool _S526 = alpha_4 > 0.0f;
    float _S527 = _slang_select(_S526, _S525,1.0f);
    return _S527;
}

__device__ float trowbridgeReitz(float alpha_5, float n_dot_h_1)
{
    float _S528 = alpha_5 * alpha_5;
    float _S529 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S528 * n_dot_h_1 * n_dot_h_1;
    return _S528 / (F32_max((3.14159274101257324f * _S529 * _S529), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S530 = smithG1(alpha_6, n_i_dot_v_1);
    float _S531 = _S530 * lobes_2.v_dot_h;
    float _S532 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S533 = _S531 * _S532 / n_i_dot_v_1;
    bool _S534 = alpha_6 > 0.0f;
    bool _S535;
    if(_S534)
    {
        _S535 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S535 = false;
    }
    if(_S535)
    {
        _S535 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S535 = false;
    }
    if(_S535)
    {
        _S535 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S535 = false;
    }
    float _S536 = _slang_select(_S535, _S533,0.0f);
    bool _S537 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S537)
    {
        float _S538 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S539 = (lobes_2.v_dot_h) > 0.0f;
        if(_S539)
        {
            _S535 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S535 = false;
        }
        if(_S535)
        {
            _S535 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S535 = false;
        }
        float _S540 = _slang_select(_S535, _S538,0.0f);
        pdf_h_0 = _S540;
    }
    else
    {
        pdf_h_0 = _S536;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S541 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S542 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S543 = lobes_3.p_refract * _S541 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S542 * _S542);
    bool _S544 = eta_i_4 != eta_o_4;
    bool _S545;
    if(_S544)
    {
        _S545 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S545 = false;
    }
    float _S546 = _slang_select(_S545, _S543,0.0f);
    return _S546;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_4, float alpha_8, BSDFMaterial material_5, BSDFLobes lobes_4)
{
    float _S547 = - dot_0(n_i_4, l_1);
    float _S548 = smithG1(alpha_8, (F32_max((_S547), (0.0f))));
    bool _S549 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S549)
    {
        float3  _S550 = negate_0(n_i_4);
        float3  _S551 = anisotropicLocal(l_1, lobes_4.tangent, _S550);
        float _S552 = anisotropicG1(_S551, lobes_4.alphas);
        G1_l_0 = _S552;
    }
    else
    {
        G1_l_0 = _S548;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_5.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S553 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S554 = n_i_dot_l_2 > 0.0f;
    bool _S555;
    if(_S554)
    {
        _S555 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S555 = false;
    }
    float _S556 = _slang_select(_S555, _S553,0.0f);
    return _S556;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_5, float alpha_10, BSDFMaterial material_6, BSDFLobes lobes_6)
{
    float3  _S557 = l_2 + lobes_6.view;
    float3  _S558 = ((((_S557)) * make_float3(rnorm3df(((_S557)).x, ((_S557)).y, ((_S557)).z))));
    float _S559 = dot_0(n_i_5, _S558);
    float _S560 = (F32_max((dot_0(n_i_5, l_2)), (0.0f)));
    float _S561 = (F32_max((dot_0(n_i_5, lobes_6.view)), (0.0f)));
    float _S562 = 1.0f / (F32_max((material_6.sheen_roughness), (0.05000000074505806f)));
    float _S563 = 1.0f - _S559 * _S559;
    float _S564 = (2.0f + _S562) * (F32_pow(((F32_max((_S563), (0.0f)))), (0.5f * _S562))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S560 + _S561 - _S560 * _S561)), (0.0000152587890625f)));
    bool _S565 = (material_6.velvet) > 0.0f;
    float f_1;
    if(_S565)
    {
        float _S566 = (F32_max((material_6.sheen_roughness), (0.00999999977648258f)));
        float _S567 = _S566 * _S566;
        float _S568 = (F32_max((_S563), (0.0000152587890625f)));
        float _S569 = (F32_exp((- _S559 * _S559 / (_S568 * _S567)))) / (3.14159274101257324f * _S567 * _S568 * _S568) * (F32_min((1.0f), (2.0f * _S559 * (F32_min((_S560), (_S561))) / (F32_max(((F32_abs((dot_0(_S558, lobes_6.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S560 * _S561), (0.0000152587890625f)));
        f_1 = _S569;
    }
    else
    {
        f_1 = _S564;
    }
    return lobes_6.sheen * make_float3 (f_1 * _S560 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float toonPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, BSDFLobes lobes_7, float eta_i_6, float eta_o_6)
{
    float _S570 = _slang_select(lobes_7.toon_glossy, l_dot_h_3,n_i_dot_l_3);
    float _S571 = (F32_acos((clamp_1(_S570, -1.0f, 1.0f))));
    float _S572;
    if(_S571 < (lobes_7.toon_a))
    {
        _S572 = 1.0f;
    }
    else
    {
        _S572 = (F32_max((1.0f - (_S571 - lobes_7.toon_a) / (F32_max((lobes_7.toon_s), (0.0000152587890625f)))), (0.0f)));
    }
    float _S573 = lobes_7.p_toon * _S572;
    float _S574 = _slang_select(lobes_7.toon_glossy, 1.0f,n_i_dot_l_3);
    float _S575 = _S573 * _S574 / lobes_7.toon_norm;
    bool _S576;
    if(lobes_7.toon_glossy)
    {
        _S576 = true;
    }
    else
    {
        _S576 = n_i_dot_l_3 > 0.0f;
    }
    float _S577 = _slang_select(_S576, _S575,0.0f);
    return _S577;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_3, float3  n_i_6, float alpha_12, BSDFMaterial material_7, BSDFLobes lobes_8)
{
    float _S578 = (F32_max((dot_0(n_i_6, l_3)), (0.0f)));
    float _S579 = _slang_select(lobes_8.toon_glossy, _S578,lobes_8.toon_view);
    return lobes_8.toon * make_float3 (_S579) / make_float3 (lobes_8.p_toon);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_4, float l_dot_h_4, float n_i_dot_v_5, float alpha_13, BSDFLobes lobes_9, float eta_i_7, float eta_o_7)
{
    float _S580 = vndfPDF(n_i_dot_v_5, alpha_13, lobes_9);
    float _S581 = lobes_9.p_reflect * _S580 / (4.0f * lobes_9.v_dot_h);
    bool _S582 = _S580 > 0.0f;
    float _S583 = _slang_select(_S582, _S581,0.0f);
    return _S583;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_4, float3  n_i_7, float alpha_14, BSDFMaterial material_8, BSDFLobes lobes_10)
{
    float _S584 = dot_0(n_i_7, l_4);
    float _S585 = smithG1(alpha_14, (F32_max((_S584), (0.0f))));
    bool _S586 = (lobes_10.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S586)
    {
        float3  _S587 = anisotropicLocal(l_4, lobes_10.tangent, n_i_7);
        float _S588 = anisotropicG1(_S587, lobes_10.alphas);
        G1_l_1 = _S588;
    }
    else
    {
        G1_l_1 = _S585;
    }
    return make_float3 (lobes_10.reflect_weight * G1_l_1) * lobes_10.F / make_float3 (lobes_10.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_9, float eta_i_8, float eta_o_8, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S589 = negate_0(in_dir_4);
    float _S590 = dot_0(n_7, _S589);
    float _S591 = sign_0(_S590);
    float3  _S592 = n_7 * make_float3 (_S591);
    AnisotropicFrame _S593 = anisotropicFrame(material_9, _S592);
    float _S594 = dot_0(_S592, out_dir_2);
    float _S595 = material_9.roughness;
    float _S596 = _S595 * _S595;
    float _S597 = rgb_to_greyscale(material_9.translucent);
    bool _S598 = _S597 > 0.0f;
    bool _S599 = (dot_0(n_7, out_dir_2) * _S590) < 0.0f;
    uint _S600;
    if((F32_abs((material_9.toon.x))) > 0.0f)
    {
        _S600 = 5U;
    }
    else
    {
        _S600 = 4U;
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
        float3  _S601 = make_float3 (0.0f);
        (*throughputs_0)[i_7] = _S601;
        (*pdfs_0)[i_7] = 0.0f;
        uint i_8 = i_7 + 1U;
        i_7 = i_8;
    }
    float3  _S602 = make_float3 (0.0f);
    BSDFLobes _S603 = BSDFLobes_x24init_0(0.0f, 0.0f, _S602, _S602, 0.0f, 0.0f, _S602, _S602, 0.0f, 0.0f, 0.0f, 0.0f, _S602, 0.0f, _S602, _S602, make_float2 (0.0f), 0.0f, 0.0f, _S602, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S602);
    BSDFLobes lobe_terms_0 = _S603;
    uint half_of_0 = 4294967295U;
    float3  ggx_n_2 = _S602;
    i_7 = 0U;
    for(;;)
    {
        if(i_7 < _S600)
        {
        }
        else
        {
            break;
        }
        uint _S604;
        if(i_7 == 3U)
        {
            _S604 = 4U;
        }
        else
        {
            if(i_7 == 4U)
            {
                _S604 = 6U;
            }
            else
            {
                _S604 = i_7;
            }
        }
        bool _S605 = _S604 == 0U;
        bool _S606;
        if(_S605)
        {
            _S606 = _S598;
        }
        else
        {
            _S606 = false;
        }
        bool _S607;
        if(_S606)
        {
            _S607 = _S599;
        }
        else
        {
            _S607 = _S604 == 1U;
        }
        bool _S608 = _S607 != refracted_2;
        if(_S608)
        {
            ggx_n_1 = ggx_n_2;
            uint i_9 = i_7 + 1U;
            ggx_n_2 = ggx_n_1;
            i_7 = i_9;
            continue;
        }
        uint _S609;
        if(_S604 == 6U)
        {
            _S609 = 0U;
        }
        else
        {
            if(_S604 == 4U)
            {
                _S609 = 2U;
            }
            else
            {
                _S609 = _S604;
            }
        }
        bool _S610 = _S609 != half_of_0;
        uint half_of_1;
        if(_S610)
        {
            bool _S611 = _S609 == 0U;
            if(_S611)
            {
                float3  _S612 = sampledHalf(in_dir_4, n_7, material_9, random_state_4, _S593);
                ggx_n_1 = _S612;
            }
            else
            {
                bool _S613 = _S609 == 1U;
                if(_S613)
                {
                    float3  _S614 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_8, eta_o_8);
                    ggx_n_1 = _S614;
                }
                else
                {
                    float3  _S615 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S615;
                }
            }
            float3  _S616 = negate_0(in_dir_4);
            BSDFLobes _S617 = bsdfLobes(in_dir_4, _S616, _S592, ggx_n_1, material_9, eta_i_8, eta_o_8, _S593);
            lobe_terms_0 = _S617;
            float _S618 = translucentShare(material_9);
            (&lobe_terms_0)->translucent_share = _S618;
            half_of_1 = _S609;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S604)
        {
        case 0U:
            {
                float _S619 = diffusePDF(_S594, 0.0f, (F32_abs((_S590))), _S596, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(0)] = _S619;
                float3  _S620 = diffuseBSDF(out_dir_2, _S592, _S596, material_9, lobe_terms_0);
                (*throughputs_0)[int(0)] = _S620;
                break;
            }
        case 1U:
            {
                float _S621 = refractPDF(_S594, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S590))), _S596, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(1)] = _S621;
                float3  _S622 = refractBSDF(out_dir_2, _S592, _S596, material_9, lobe_terms_0);
                (*throughputs_0)[int(1)] = _S622;
                break;
            }
        case 4U:
            {
                float _S623 = sheenVelvetPDF(_S594, 0.0f, (F32_abs((_S590))), _S596, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(3)] = _S623;
                float3  _S624 = sheenVelvetBSDF(out_dir_2, _S592, _S596, material_9, lobe_terms_0);
                (*throughputs_0)[int(3)] = _S624;
                break;
            }
        case 6U:
            {
                float _S625 = toonPDF(_S594, dot_0(out_dir_2, (&lobe_terms_0)->toon_axis), (F32_abs((_S590))), _S596, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(4)] = _S625;
                float3  _S626 = toonBSDF(out_dir_2, _S592, _S596, material_9, lobe_terms_0);
                (*throughputs_0)[int(4)] = _S626;
                break;
            }
        default:
            {
                float _S627 = reflectPDF(_S594, 0.0f, (F32_abs((_S590))), _S596, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(2)] = _S627;
                float3  _S628 = reflectBSDF(out_dir_2, _S592, _S596, material_9, lobe_terms_0);
                (*throughputs_0)[int(2)] = _S628;
                break;
            }
        }
        half_of_0 = half_of_1;
        uint i_9 = i_7 + 1U;
        ggx_n_2 = ggx_n_1;
        i_7 = i_9;
    }
    i_7 = 0U;
    ggx_n_1 = _S602;
    for(;;)
    {
        if(i_7 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S629 = ((*pdfs_0)[i_7]) > 0.0f;
        if(_S629)
        {
            float3  f_2 = ggx_n_1 + (*throughputs_0)[i_7] * make_float3 ((*pdfs_0)[i_7]);
            ggx_n_1 = f_2;
        }
        uint i_10 = i_7 + 1U;
        i_7 = i_10;
    }
    return ggx_n_1;
}

static __device__ __forceinline__ float3  skyLobes_0(float3  in_dir_5, float3  dir_3, FKSurface * surface_1, float2  eta_1, bool is_inside_2, float pdf_0, uint random_state_5, FixedArray<float3 , 5>  * terms_0, FixedArray<float, 5>  * pdfs_1)
{
    bool _S630 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    float3  _S631 = BSDF(in_dir_5, dir_3, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S630, random_state_5, terms_0, pdfs_1);
    float3  _S632 = make_float3 (0.0f);
    uint i_11 = 0U;
    float3  f_3 = _S632;
    for(;;)
    {
        if(i_11 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S633 = ((*pdfs_1)[i_11]) > 0.0f;
        if(_S633)
        {
            float3  _S634 = (*terms_0)[i_11] * make_float3 ((*pdfs_1)[i_11]) / make_float3 ((*pdfs_1)[i_11] + pdf_0);
            (*terms_0)[i_11] = _S634;
            float3  f_4 = f_3 + (*terms_0)[i_11];
            f_3 = f_4;
        }
        uint i_12 = i_11 + 1U;
        i_11 = i_12;
    }
    return f_3;
}

__device__ float3  skyBSDF(float3  in_dir_6, float3  dir_4, FKSurface surface_2, float2  eta_2, bool is_inside_3, float pdf_1, uint random_state_6)
{
    FKSurface _S635 = surface_2;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S636 = skyLobes_0(in_dir_6, dir_4, &_S635, eta_2, is_inside_3, pdf_1, random_state_6, &terms_1, &pdfs_2);
    return _S636;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S637;
    (&_S637)->dir = dir_5;
    (&_S637)->radiance = radiance_0;
    (&_S637)->color = color_0;
    (&_S637)->random_state = random_state_7;
    return _S637;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S638 = (fcptEnvironmentCdfSize());
    uint2  _S639 = make_uint2 (1U, 0U);
    uint2  _S640 = _S638 - _S639;
    Random _S641 = pcg(init_random_state_0);
    Random _S642 = pcg(_S641.state);
    Random _S643 = pcg(_S642.state);
    Random _S644 = pcg(_S643.state);
    uint _S645 = _S640.x;
    uint _S646 = searchCDF_0(make_uint2 (_S645, 0U), make_uint2 (0U, 1U), _S640.y, _S641.value);
    uint _S647 = searchCDF_0(make_uint2 (0U, _S646), _S639, _S645, _S642.value);
    float2  _S648 = make_float2 ((float)_S640.x, (float)_S640.y);
    float2  _S649 = (make_float2 (float(_S647), float(_S646)) + make_float2 (_S643.value, _S644.value)) / _S648 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S650 = _S649.y;
    float _S651 = (F32_sin((_S650)));
    float _S652 = _S649.x;
    float3  _S653 = make_float3 (- _S651 * (F32_cos((_S652))), _S651 * (F32_sin((_S652))), (F32_cos((_S650))));
    float _S654 = environmentPdf_0(_S653);
    float3  _S655 = skyBSDF(ray_0->unit_direction, _S653, *surface_3, eta_3, is_inside_4, _S654, lobe_state_0);
    bool _S656 = !(_S654 > 0.0f);
    bool _S657;
    if(_S656)
    {
        _S657 = true;
    }
    else
    {
        _S657 = all_1(_S655 == make_float3 (0.0f));
    }
    if(_S657)
    {
        float3  _S658 = make_float3 (0.0f);
        return SkySample_x24init_0(_S653, _S658, _S658, _S644.state);
    }
    float3  _S659 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S653, context_2, _S644.state);
    return SkySample_x24init_0(_S653, _S659, _S655 * _S659, _S644.state);
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
    SampleBSDF _S660 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S661 = _S660.throughput * make_float3 (_S660.pdf);
    float _S662 = light_1->density;
    float _S663 = 1.0f + _S660.pdf * _S660.pdf / (light_1->density * light_1->density);
    bool _S664;
    if(competing_0)
    {
        _S664 = _S662 > 0.0f;
    }
    else
    {
        _S664 = false;
    }
    float _S665 = _slang_select(_S664, _S663,1.0f);
    return _S661 / make_float3 (_S665) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S666;
    (&_S666)->dir = dir_6;
    (&_S666)->radiance = radiance_1;
    (&_S666)->density = density_0;
    (&_S666)->random_state = random_state_8;
    return _S666;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S667 = importance(first_1, p_12, normal_3);
    float _S668 = importance(second_1, p_12, normal_3);
    float2  _S669 = make_float2 (_S667, _S668);
    bool _S670 = _S667 == 0.0f;
    bool _S671;
    if(_S670)
    {
        _S671 = _S668 == 0.0f;
    }
    else
    {
        _S671 = false;
    }
    if(_S671)
    {
        return 2U;
    }
    float _S672 = _S667 + _S668;
    bool _S673 = _S668 > 0.0f;
    if(_S673)
    {
        _S671 = (*pick_0 * _S672) >= _S667;
    }
    else
    {
        _S671 = false;
    }
    uint _S674 = uint(_S671);
    float _S675 = (F32_min(((*pick_0 * _S672 - float(_S674) * _S667) / _slang_vector_get_element(_S669, _S674)), (0.99999994039535522f)));
    *pick_0 = _S675;
    float _S676 = *probability_3 * (_slang_vector_get_element(_S669, _S674) / _S672);
    *probability_3 = _S676;
    return _S674;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S677 = center_1 - p_13;
    float _S678 = radius_1 * radius_1 / dot_0(_S677, _S677);
    float _S679 = u1_0 * _S678 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S678), (0.0f)))))));
    float _S680 = 2.0f * u1_0;
    bool _S681 = _S678 >= 1.0f;
    float _S682 = _slang_select(_S681, _S680,_S679);
    float _S683 = (F32_sqrt(((F32_max((_S682 * (2.0f - _S682)), (0.0f))))));
    float _S684 = 6.28318548202514648f * u2_0;
    float3  _S685 = make_float3 (_S683 * (F32_cos((_S684))), 1.0f - _S682, _S683 * (F32_sin((_S684))));
    float3  _S686 = ((((_S677)) * make_float3(rnorm3df(((_S677)).x, ((_S677)).y, ((_S677)).z))));
    float3  _S687 = tangentToWorld(_S685, _S686);
    return _S687;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S688 = center_2 - ray_1->origin;
    float _S689 = dot_0(_S688, ray_1->unit_direction);
    float _S690 = dot_0(_S688, _S688) - _S689 * _S689;
    float _S691 = radius_3 * radius_3;
    bool _S692 = _S690 > _S691;
    if(_S692)
    {
        return 4.294967296e+09f;
    }
    float _S693 = (F32_sqrt((_S691 - _S690)));
    float _S694 = _S689 - _S693;
    float _S695 = _S689 + _S693;
    bool _S696 = _S694 > 0.0000152587890625f;
    bool _S697;
    if(_S696)
    {
        _S697 = _S694 < max_len_0;
    }
    else
    {
        _S697 = false;
    }
    if(_S697)
    {
        return _S694;
    }
    bool _S698 = _S695 > 0.0000152587890625f;
    if(_S698)
    {
        _S697 = _S695 < max_len_0;
    }
    else
    {
        _S697 = false;
    }
    if(_S697)
    {
        return _S695;
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
        *_slang_vector_get_element_ptr(&result_6, j_1) = sum_0;
        j_1 = j_1 + int(1);
    }
    return result_6;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S699 = pcg(init_random_state_1);
    Random _S700 = pcg(_S699.state);
    Random _S701 = pcg(_S700.state);
    float3  _S702 = make_float3 (0.0f);
    TreeSample _S703 = TreeSample_x24init_0(_S702, _S702, 0.0f, _S701.state);
    TreeSample sample_0 = _S703;
    float3  _S704 = _slang_select(sided_0, _S702,smooth_n_2);
    float3  _S705 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S699.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S706 = (fcptLightNode((n_8)));
        if((_S706.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S707 = (fcptLightSecond((n_8)));
        uint _S708 = n_8 + 1U;
        LightNode _S709 = (fcptLightBounds((_S708)));
        LightNode _S710 = (fcptLightBounds((_S707)));
        uint _S711 = pickChild(_S709, _S710, origin_4, _S704, &pick_1, &probability_4);
        bool _S712 = _S711 > 1U;
        if(_S712)
        {
            return sample_0;
        }
        bool _S713 = _S711 == 1U;
        uint _S714 = _slang_select(_S713, _S707,_S708);
        n_8 = _S714;
    }
    bool _S715 = n_8 == 0U;
    bool _S716;
    if(_S715)
    {
        LightNode _S717 = (fcptLightBounds((0U)));
        float _S718 = importance(_S717, origin_4, _S704);
        _S716 = !(_S718 > 0.0f);
    }
    else
    {
        _S716 = false;
    }
    if(_S716)
    {
        return sample_0;
    }
    uint4  _S719 = (fcptLightNode((n_8)));
    FKHit _S720 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S721 = (_S719.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S721)
    {
        FKLight _S722 = (fcptLight((_S719.y)));
        if(sided_0)
        {
            float _S723 = sign_0(dot_0(geometry_n_1, _S722.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S723);
            float3  _S724 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S724;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S705;
            lift_n_0 = smooth_n_2;
        }
        bool _S725 = (_S722.variance) == 0.0f;
        if(_S725)
        {
            float3  _S726 = _S722.position - emitter_point_0;
            float3  _S727 = ((((_S726)) * make_float3(rnorm3df(((_S726)).x, ((_S726)).y, ((_S726)).z))));
            (&sample_0)->dir = _S727;
            float3  _S728 = _S722.color * make_float3 (_S722.intensity) / make_float3 (dot_0(_S726, _S726) * probability_4);
            (&sample_0)->radiance = _S728;
            shadow_1 = _S726;
        }
        else
        {
            float3  _S729 = sampleSphere(_S722.position, _S722.variance, emitter_point_0, _S700.value, _S701.value);
            (&sample_0)->dir = _S729;
            float _S730 = sphereDensity(_S722.position, _S722.variance, emitter_point_0);
            float _S731 = probability_4 * _S730;
            (&sample_0)->density = _S731;
            float3  _S732 = pointLightRadiance(_S722.color, _S722.intensity, _S722.variance);
            float3  _S733 = _S732 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S733;
            FKRay _S734 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S735 = raySphere_0(_S722.position, _S722.variance, &_S734, 4.294967296e+09f);
            float3  _S736 = (&sample_0)->dir * make_float3 (_S735);
            shadow_1 = _S736;
        }
        emitter_0 = _S720;
        emitter_point_0 = _S702;
    }
    else
    {
        uint _S737 = _S719.y;
        uint _S738 = (fcptTriangleOffset((_S737)));
        uint _S739 = _S738 + _S719.z;
        Matrix<float, 3, 3>  _S740 = (fcptWorldTriangle((_S737), (_S739)));
        float _S741 = (F32_sqrt((_S700.value)));
        float2  _S742 = make_float2 (_S741 * (1.0f - _S701.value), _S741 * _S701.value);
        float3  _S743 = mul_0(make_float3 (1.0f - _S741, _S742.x, _S742.y), _S740);
        if(sided_0)
        {
            float _S744 = sign_0(dot_0(geometry_n_1, _S743 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S744);
            float3  _S745 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S745;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S746 = !((dot_0(smooth_n_2, _S743 - origin_4)) > 0.0f);
            if(_S746)
            {
                return sample_0;
            }
            emitter_point_0 = _S705;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S742, _S737, _S739, 0U, 0.0f);
        float3  _S747 = _S743 - emitter_point_0;
        float3  _S748 = ((((_S747)) * make_float3(rnorm3df(((_S747)).x, ((_S747)).y, ((_S747)).z))));
        (&sample_0)->dir = _S748;
        float _S749 = solidAngle(probability_4, cross_0(_S740.rows[int(1)] - _S740.rows[int(0)], _S740.rows[int(2)] - _S740.rows[int(0)]), _S747);
        (&sample_0)->density = _S749;
        bool _S750 = (fcptShadowFirst());
        bool _S751 = !_S750;
        if(_S751)
        {
            FKSurface _S752 = (fcptLightSurfaceAt((emitter_1), (_S743), (_S701.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S743 - origin_4))));
            (&sample_0)->random_state = _S752.random_state;
            float3  _S753 = _slang_select(_S752.skip, _S702,_S752.material.emissive);
            float3  _S754 = _S753 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S754;
        }
        shadow_1 = _S747;
        emitter_0 = emitter_1;
        emitter_point_0 = _S743;
    }
    FKHit _S755 = emitter_0;
    float3  _S756 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S701.state, &_S755);
    bool _S757 = (fcptShadowFirst());
    if(_S757)
    {
        _S716 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S716 = false;
    }
    if(_S716)
    {
        _S716 = !all_1(_S756 == _S702);
    }
    else
    {
        _S716 = false;
    }
    if(_S716)
    {
        FKSurface _S758 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S701.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S758.random_state;
        float3  _S759 = _slang_select(_S758.skip, _S702,_S758.material.emissive);
        float3  _S760 = _S759 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S760;
    }
    float3  _S761 = (&sample_0)->radiance * _S756;
    bool _S762 = all_1(_S756 == _S702);
    float3  _S763 = _slang_select(_S762, _S702,_S761);
    (&sample_0)->radiance = _S763;
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
    float _S764 = 1.0f / (1.0f + b_3 / a_7 * (b_3 / a_7));
    bool _S765 = b_3 > 0.0f;
    float _S766 = _slang_select(_S765, _S764,1.0f);
    return _S766;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S767 = vertex_0->none;
    if(_S767)
    {
        return 1.0f;
    }
    uint _S768 = (fcptLightSlot((*hit_1)));
    float _S769 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S768, light_point_1);
    float _S770 = powerHeuristic(vertex_0->pdf, _S769);
    return _S770;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_0)
{
    uint2  _S771 = (fcptEnvironmentMapSize());
    bool _S772 = (_S771.x) > 1U;
    bool _S773;
    if(_S772)
    {
        uint2  _S774 = (fcptEnvironmentMapSize());
        _S773 = (_S774.y) > 1U;
    }
    else
    {
        _S773 = false;
    }
    if(_S773)
    {
        float3  _S775 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_0)));
        return _S775;
    }
    float3  _S776 = (fcptAmbient());
    return _S776;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S777 = (fcptEnvironmentCdfSize());
    bool _S778 = (_S777.x) > 1U;
    bool _S779;
    if(_S778)
    {
        uint2  _S780 = (fcptEnvironmentCdfSize());
        _S779 = (_S780.y) > 1U;
    }
    else
    {
        _S779 = false;
    }
    bool _S781 = !_S779;
    if(_S781)
    {
        return false;
    }
    uint2  _S782 = (fcptEnvironmentMapSize());
    bool _S783 = (_S782.x) > 1U;
    if(_S783)
    {
        uint2  _S784 = (fcptEnvironmentMapSize());
        _S779 = (_S784.y) > 1U;
    }
    else
    {
        _S779 = false;
    }
    return _S779;
}

static __device__ float escapeWeight_0(float pdf_2, float3  dir_8)
{
    bool _S785 = pdf_2 <= 0.0f;
    bool _S786;
    if(_S785)
    {
        _S786 = true;
    }
    else
    {
        bool _S787 = environmentMapped_0();
        _S786 = !_S787;
    }
    if(_S786)
    {
        return 1.0f;
    }
    float _S788 = environmentPdf_0(dir_8);
    return pdf_2 / (pdf_2 + _S788);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S789 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S790 = make_int2 ((int)_S789.x, (int)_S789.y);
    uint _S791 = previousSeed_0(_S790);
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
            uint _S792 = previousSeed_0(_S790 + make_int2 (x_16, y_5));
            bool _S793 = _S792 == _S791;
            uint _S794 = _slang_select(_S793, 1U,0U);
            uint count_3 = count_2 + _S794;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S795 = float(count_2 - 1U) / 288.0f;
    bool _S796 = _S791 != 0U;
    float _S797 = _slang_select(_S796, _S795,0.0f);
    fcptStoreDuplication((_S790), (make_uint4 ((F32_asuint((_S797))), 0U, 0U, 0U)));
    return;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S798 = hash(index_0);
    uint _S799 = hash(seed_3 ^ _S798);
    return _S799;
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
    float _S800 = rgb_to_greyscale(weight_0);
    bool _S801 = _S800 > 0.0f;
    bool _S802;
    if(_S801)
    {
        _S802 = _S800 < 3.00000000549775576e+38f;
    }
    else
    {
        _S802 = false;
    }
    bool _S803 = !_S802;
    if(_S803)
    {
        return;
    }
    bool _S804 = sel_2->sums;
    if(_S804)
    {
        float3  _S805 = sel_2->color + weight_0;
        sel_2->color = _S805;
        return;
    }
    float _S806 = sel_2->w_sum + _S800;
    sel_2->w_sum = _S806;
    float3  _S807 = sel_2->color + weight_0;
    sel_2->color = _S807;
    Random _S808 = pcg(sel_2->random_state);
    sel_2->random_state = _S808.state;
    bool _S809 = (_S808.value * sel_2->w_sum) <= _S800;
    if(_S809)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S810 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S810;
    float _S811 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S811;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S812 = rgb_to_greyscale((&r_4)->f);
    float _S813 = sel_4.w_sum / _S812;
    bool _S814 = _S812 > 0.0f;
    float _S815 = _slang_select(_S814, _S813,0.0f);
    (&r_4)->w = _S815;
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
    uint2  _S816 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S817 = make_int2 ((int)_S816.x, (int)_S816.y);
    float3  _S818 = make_float3 (0.0f);
    FKHit _S819 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S820 = Domain_x24init_0(_S818, _S818, &_S819, 0.0f, 0.0f);
    Domain dom_4 = _S820;
    bool _S821 = (fcptCurrentDomain((_S817), (&dom_4)));
    bool _S822 = !_S821;
    if(_S822)
    {
        Reservoir _S823 = (Reservoir{});
        fcptStoreReservoirPrevious((_S817), (_S823), ((&dom_4)->hit));
        return;
    }
    Reservoir _S824 = (fcptLoadReservoirTemporal((_S817)));
    uint t_13 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S824.c;
    for(;;)
    {
        uint _S825 = (fcptRestirNeighbours());
        if(t_13 < _S825)
        {
        }
        else
        {
            break;
        }
        int2  _S826 = partner_0(_S817, t_13);
        Domain neighbor_0 = _S820;
        bool _S827 = (fcptCurrentDomain((_S826), (&neighbor_0)));
        if(_S827)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S828 = (fcptReservoirTemporal((_S826), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S828.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_14 = t_13 + 1U;
        t_13 = t_14;
    }
    float _S829 = _S824.c / (F32_max((count_4), (1.0f)));
    float _S830 = rgb_to_greyscale(_S824.f);
    bool _S831 = count_4 == 0.0f;
    float _S832 = _slang_select(_S831, 1.0f,0.0f);
    Selection _S833 = (Selection{});
    Selection sel_5 = _S833;
    uint _S834 = (fcptFrame());
    uint _S835 = hash(_S834);
    uint _S836 = global_invocation_id_2.x;
    uint2  _S837 = (fcptRenderSize());
    uint _S838 = stream(_S835, _S836 + _S837.x * global_invocation_id_2.y);
    uint _S839 = stream(_S838, 195U);
    (&sel_5)->random_state = _S839;
    t_13 = 0U;
    float canonical_mis_0 = _S832;
    for(;;)
    {
        uint _S840 = (fcptRestirNeighbours());
        if(t_13 < _S840)
        {
        }
        else
        {
            break;
        }
        int2  _S841 = partner_0(_S817, t_13);
        Domain neighbor_dom_0 = _S820;
        bool _S842 = (fcptCurrentDomain((_S841), (&neighbor_dom_0)));
        if(_S842)
        {
            Reservoir _S843 = (fcptLoadReservoirTemporal((_S841)));
            uint4  _S844 = (fcptShiftData((_S841), (t_13)));
            float4  _S845 = asfloat_0(_S844);
            uint4  _S846 = (fcptShiftData((_S817), (t_13)));
            float4  _S847 = asfloat_0(_S846);
            float _S848 = pairShare(_S843.c, _S829, c_sum_1);
            bool _S849 = _S830 > 0.0f;
            float canonical_mis_1;
            if(_S849)
            {
                float _S850 = rgb_to_greyscale(float3 {_S847.x, _S847.y, _S847.z});
                float _S851 = canonicalWeight(_S848, _S829, _S830, _S843.c, _S850);
                float canonical_mis_2 = canonical_mis_0 + _S851;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S852 = float3 {_S845.x, _S845.y, _S845.z};
            Shift _S853 = Shift_x24init_0(_S852, _S845.w);
            float _S854 = rgb_to_greyscale(_S843.f);
            float _S855 = rgb_to_greyscale(_S852);
            float _S856 = neighborWeight(_S848, _S843.c, _S854, _S829, _S855);
            offerShifted(&sel_5, _S843, _S853, _S856);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_15 = t_13 + 1U;
        t_13 = t_15;
    }
    offerShifted(&sel_5, _S824, Shift_x24init_0(_S824.f, 1.0f), canonical_mis_0);
    Reservoir _S857 = finalize(sel_5, c_sum_1);
    fcptStoreReservoirPrevious((_S817), (_S857), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S817), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S817), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S858 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S859 = _S858 != 4294967295U;
    if(_S859)
    {
        uint2  _S860 = make_uint2 (_S858, _S858 >> 14U) & make_uint2 (16383U);
        int2  _S861 = make_int2 ((int)_S860.x, (int)_S860.y);
        ShiftJob _S862 = (ShiftJob{});
        ShiftJob shift_job_0 = _S862;
        Shift _S863 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S864 = _S858 >> 28U;
        bool _S865 = spatialJob_0(_S861, _S864, &shift_job_0, true);
        Shift shifted_1;
        if(_S865)
        {
            Domain _S866 = (&shift_job_0)->dom;
            Reservoir _S867 = (&shift_job_0)->r;
            Shift _S868 = passShift_0(&_S866, &_S867);
            shifted_1 = _S868;
        }
        else
        {
            shifted_1 = _S863;
        }
        fcptStoreShiftData((_S861), (_S864), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S869 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S870 = make_int2 ((int)_S869.x, (int)_S869.y);
    FixedArray<uint, 3>  _S871;
    spatialBins_0(_S870, &_S871);
    FixedArray<uint, 3>  _S872 = _S871;
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
        bool _S873 = (_S872[t_16]) == 40U;
        if(_S873)
        {
            fcptStoreShiftData((_S870), (t_16), (make_uint4 (0U)));
        }
        uint t_17 = t_16 + 1U;
        t_16 = t_17;
    }
    FixedArray<uint, 3>  _S874 = _S872;
    queueShifts_0(_S870, &_S874, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S875 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S876 = make_int2 ((int)_S875.x, (int)_S875.y);
    FixedArray<uint, 3>  _S877;
    spatialBins_0(_S876, &_S877);
    FixedArray<uint, 3>  _S878 = _S877;
    countShifts_0(&_S878, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S879 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S880 = _S879 != 4294967295U;
    if(_S880)
    {
        uint2  _S881 = make_uint2 (_S879, _S879 >> 14U) & make_uint2 (16383U);
        int2  _S882 = make_int2 ((int)_S881.x, (int)_S881.y);
        int2  _S883 = (fcptLoadTemporalNeighbor((_S882)));
        uint _S884 = _S879 >> 28U;
        Shift _S885 = temporalShiftAt_0(_S882, _S883, _S884);
        fcptStoreTemporalShift((_S882), (_S884), (make_uint4 (asuint_1(_S885.f).x, asuint_1(_S885.f).y, asuint_1(_S885.f).z, (F32_asuint((_S885.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S886 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S887 = make_int2 ((int)_S886.x, (int)_S886.y);
    FixedArray<uint, 3>  _S888;
    temporalBins_0(_S887, &_S888);
    FixedArray<uint, 3>  _S889 = _S888;
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
        bool _S890 = (_S889[t_18]) == 40U;
        if(_S890)
        {
            fcptStoreTemporalShift((_S887), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S891 = _S889;
    queueShifts_0(_S887, &_S891, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S892 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S893 = make_int2 ((int)_S892.x, (int)_S892.y);
    bool _S894 = (fcptSceneUnchanged());
    bool _S895 = !_S894;
    bool _S896;
    if(_S895)
    {
        uint2  _S897 = (fcptRenderSize());
        int2  _S898 = make_int2 ((int)_S897.x, (int)_S897.y);
        _S896 = all_0(_S893 < _S898);
    }
    else
    {
        _S896 = false;
    }
    if(_S896)
    {
        Reservoir _S899 = (fcptLoadReservoirInitial((_S893)));
        int2  _S900 = sampleNeighbor_0(_S893, _S899.seed);
        fcptStoreTemporalNeighbor((_S893), (_S900));
    }
    FixedArray<uint, 3>  _S901;
    temporalBins_0(_S893, &_S901);
    FixedArray<uint, 3>  _S902 = _S901;
    countShifts_0(&_S902, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_8, float b_4, float t_20)
{
    return a_8 + (b_4 - a_8) * t_20;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S903 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S903;
}

__device__ float2  temporalWeights(float c_2, float p_c_1, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S904 = c_2 * p_c_1;
    float _S905 = c_t_0 * p_t_0;
    return make_float2 (_S904 / (_S904 + c_t_0 * g_previous_0), _S905 / (_S905 + c_2 * g_current_0));
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S906 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S907 = make_int2 ((int)_S906.x, (int)_S906.y);
    float3  _S908 = make_float3 (0.0f);
    FKHit _S909 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S910 = Domain_x24init_0(_S908, _S908, &_S909, 0.0f, 0.0f);
    Domain dom_5 = _S910;
    bool _S911 = (fcptCurrentDomain((_S907), (&dom_5)));
    bool _S912 = !_S911;
    if(_S912)
    {
        Reservoir _S913 = (Reservoir{});
        fcptStoreReservoirTemporal((_S907), (_S913), ((&dom_5)->hit));
        return;
    }
    Reservoir _S914 = (fcptLoadReservoirInitial((_S907)));
    bool _S915 = (fcptTemporalQueued());
    bool _S916 = (fcptSceneUnchanged());
    bool _S917;
    if(_S916)
    {
        _S917 = true;
    }
    else
    {
        _S917 = !_S915;
    }
    int2  _S918;
    if(_S917)
    {
        int2  _S919 = sampleNeighbor_0(_S907, _S914.seed);
        _S918 = _S919;
    }
    else
    {
        int2  _S920 = (fcptLoadTemporalNeighbor((_S907)));
        _S918 = _S920;
    }
    bool _S921 = (_S918.x) >= int(0);
    Reservoir r_5;
    if(_S921)
    {
        Reservoir _S922 = (fcptLoadReservoirPrevious((_S918)));
        uint4  _S923 = (fcptDuplication((_S918)));
        float _S924 = (U32_asfloat((_S923.x)));
        uint _S925 = (fcptRestirDecorrelation());
        bool _S926 = _S925 == 1U;
        float _S927 = _slang_select(_S926, _S924,0.0f);
        float _S928 = confidenceCap(_S927);
        float _S929 = (F32_min((_S922.c), (_S928)));
        bool _S930 = (fcptSceneUnchanged());
        float4  _S931 = make_float4 (_S922.f.x, _S922.f.y, _S922.f.z, 1.0f);
        bool _S932 = !_S930;
        if(_S932)
        {
            _S917 = _S915;
        }
        else
        {
            _S917 = false;
        }
        float4  to_current_0;
        if(_S917)
        {
            uint4  _S933 = (fcptTemporalShift((_S907), (0U)));
            float4  _S934 = asfloat_0(_S933);
            to_current_0 = _S934;
        }
        else
        {
            if(_S932)
            {
                Shift _S935 = temporalShiftAt_0(_S907, _S918, 0U);
                float4  _S936 = make_float4 (_S935.f.x, _S935.f.y, _S935.f.z, _S935.jac);
                to_current_0 = _S936;
            }
            else
            {
                to_current_0 = _S931;
            }
        }
        Domain own_1 = _S910;
        if(_S930)
        {
            _S917 = true;
        }
        else
        {
            bool _S937 = (fcptPreviousScenes());
            bool _S938 = !_S937;
            if(_S938)
            {
                _S917 = (_S914.w) > 0.0f;
            }
            else
            {
                _S917 = false;
            }
            if(_S917)
            {
                bool _S939 = (fcptStoredDomainInitial((_S907), (_S914.seed), (&own_1)));
                _S917 = _S939;
            }
            else
            {
                _S917 = false;
            }
            if(_S917)
            {
                Domain _S940 = (fcptPreviousDomain((_S918), (_S914.seed)));
                Domain _S941 = _S940;
                Domain _S942 = own_1;
                bool _S943 = sameDomain_0(&_S941, &_S942);
                _S917 = _S943;
            }
            else
            {
                _S917 = false;
            }
        }
        float4  _S944 = make_float4 (_S914.f.x, _S914.f.y, _S914.f.z, 1.0f);
        bool _S945 = !_S917;
        if(_S945)
        {
            _S917 = _S915;
        }
        else
        {
            _S917 = false;
        }
        float4  to_previous_0;
        if(_S917)
        {
            uint4  _S946 = (fcptTemporalShift((_S907), (1U)));
            float4  _S947 = asfloat_0(_S946);
            to_previous_0 = _S947;
        }
        else
        {
            if(_S945)
            {
                Shift _S948 = temporalShiftAt_0(_S907, _S918, 1U);
                float4  _S949 = make_float4 (_S948.f.x, _S948.f.y, _S948.f.z, _S948.jac);
                to_previous_0 = _S949;
            }
            else
            {
                to_previous_0 = _S944;
            }
        }
        float _S950 = rgb_to_greyscale(_S914.f);
        float _S951 = rgb_to_greyscale(_S922.f);
        Selection _S952 = (Selection{});
        Selection sel_6 = _S952;
        uint _S953 = (fcptFrame());
        uint _S954 = hash(_S953);
        uint _S955 = global_invocation_id_7.x;
        uint2  _S956 = (fcptRenderSize());
        uint _S957 = stream(_S954, _S955 + _S956.x * global_invocation_id_7.y);
        uint _S958 = stream(_S957, 194U);
        (&sel_6)->random_state = _S958;
        float4  _S959 = to_previous_0;
        float _S960 = rgb_to_greyscale(float3 {_S959.x, _S959.y, _S959.z});
        float4  _S961 = to_current_0;
        float3  _S962 = float3 {_S961.x, _S961.y, _S961.z};
        float _S963 = rgb_to_greyscale(_S962);
        float2  _S964 = temporalWeights(_S914.c, _S950, _S929, _S951, _S960, _S963);
        offerShifted(&sel_6, _S914, Shift_x24init_0(_S914.f, 1.0f), _S964.x);
        offerShifted(&sel_6, _S922, Shift_x24init_0(_S962, to_current_0.w), _S964.y);
        Reservoir _S965 = finalize(sel_6, _S914.c + _S929);
        r_5 = _S965;
    }
    else
    {
        r_5 = _S914;
    }
    fcptStoreReservoirTemporal((_S907), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S966 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S967 = make_int2 ((int)_S966.x, (int)_S966.y);
    float3  _S968 = make_float3 (0.0f);
    float2  _S969 = make_float2 (0.0f);
    FKHit _S970 = Hit_x24init_0(_S969, 0U, 0U, 0U, 0.0f);
    Domain _S971 = Domain_x24init_0(_S968, _S968, &_S970, 0.0f, 0.0f);
    Domain dom_6 = _S971;
    bool _S972 = (fcptCurrentDomain((_S967), (&dom_6)));
    bool _S973 = !_S972;
    if(_S973)
    {
        Reservoir _S974 = (Reservoir{});
        fcptStoreReservoirInitial((_S967), (_S974), ((&dom_6)->hit));
        return;
    }
    uint _S975 = (fcptFrame());
    uint _S976 = hash(_S975);
    uint _S977 = global_invocation_id_8.x;
    uint2  _S978 = (fcptRenderSize());
    uint _S979 = stream(_S976, _S977 + _S978.x * global_invocation_id_8.y);
    Selection _S980 = (Selection{});
    Selection initial_0 = _S980;
    uint _S981 = stream(_S979, 193U);
    (&initial_0)->random_state = _S981;
    bool _S982 = (fcptRestirUsed());
    bool _S983 = !_S982;
    (&initial_0)->sums = _S983;
    uint _S984 = stream(_S979, 0U);
    (&(&initial_0)->r)->seed = _S984;
    FKHit _S985 = Hit_x24init_0(_S969, 4294967295U, 0U, 0U, 0.0f);
    uint _S986 = (fcptSamples());
    float _S987 = 1.0f / float(_S986);
    FKHit hit_2 = _S985;
    uint i_17 = 0U;
    float3  seen_0 = _S968;
    for(;;)
    {
        uint _S988 = (fcptSamples());
        if(i_17 < _S988)
        {
        }
        else
        {
            break;
        }
        Reservoir _S989 = (Reservoir{});
        Reservoir r_6 = _S989;
        uint _S990 = stream(_S979, i_17);
        (&r_6)->seed = _S990;
        Domain path_0 = _S971;
        bool _S991 = (fcptStoredDomainInitial((_S967), ((&r_6)->seed), (&path_0)));
        bool _S992 = !_S991;
        if(_S992)
        {
            float3  _S993 = (fcptMissed((_S967), (path_0), (_S987)));
            float3  seen_1 = seen_0 + _S993;
            seen_0 = seen_1;
            uint i_18 = i_17 + 1U;
            i_17 = i_18;
            continue;
        }
        Domain _S994 = path_0;
        Reservoir _S995 = r_6;
        Shift _S996 = passWalk_0(&_S994, &_S995, false, _S987, &initial_0);
        bool _S997 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S997)
        {
            FKHit _S998 = (&path_0)->hit;
            hit_3 = _S998;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_18 = i_17 + 1U;
        i_17 = i_18;
    }
    uint _S999 = (fcptSamples());
    float3  seen_2 = seen_0 + (&initial_0)->glow / make_float3 (float(_S999));
    if((&initial_0)->sums)
    {
        seen_0 = seen_2 + (&initial_0)->color;
    }
    else
    {
        seen_0 = seen_2;
    }
    fcptAddColor((_S967), (make_float4 (seen_0.x, seen_0.y, seen_0.z, 1.0f)));
    Reservoir _S1000 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S967), (_S1000), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_3, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1001;
    (&_S1001)->none = none_0;
    (&_S1001)->pdf = pdf_3;
    (&_S1001)->origin = origin_5;
    (&_S1001)->smooth_n = smooth_n_3;
    (&_S1001)->start = start_6;
    return _S1001;
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
    Vertex _S1002;
    (&_S1002)->rough = rough_0;
    (&_S1002)->lobe = lobe_1;
    (&_S1002)->pdf = pdf_4;
    (&_S1002)->cos = cos_0;
    (&_S1002)->inside = inside_0;
    return _S1002;
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
    float3  _S1003 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_2));
    float3  _S1004 = scatter_0 * _S1003 / make_float3 (sigma_1);
    float3  _S1005 = _slang_select(scatters_0, _S1004,_S1003);
    return _S1005;
}

static __device__ bool scatterSampled_0(bool replay_1, uint b_5, uint stop_0, bool varying_0)
{
    bool _S1006 = !replay_1;
    bool _S1007;
    if(_S1006)
    {
        _S1007 = true;
    }
    else
    {
        bool _S1008 = b_5 == stop_0;
        if(_S1008)
        {
            _S1007 = !varying_0;
        }
        else
        {
            _S1007 = false;
        }
    }
    return _S1007;
}

static __device__ uint arrivalLobe_0(uint b_6, uint prev_lobe_0)
{
    bool _S1009 = b_6 > 0U;
    uint _S1010 = _slang_select(_S1009, prev_lobe_0,3U);
    return _S1010;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_5, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1011;
    (&_S1011)->extinction_behind = extinction_behind_0;
    (&_S1011)->extinction_front = extinction_front_0;
    (&_S1011)->fillings = fillings_0;
    (&_S1011)->side = side_0;
    (&_S1011)->depth = depth_1;
    (&_S1011)->lobe = lobe_2;
    (&_S1011)->surface = surface_5;
    (&_S1011)->length = length_2;
    (&_S1011)->width = width_1;
    (&_S1011)->own = *own_2;
    (&_S1011)->fiber = fiber_0;
    return _S1011;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1012 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1012)
    {
        return 0.07957746833562851f;
    }
    float _S1013 = g_0 * g_0;
    return (1.0f - _S1013) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1013 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_9, float3  b_7)
{
    float3  _S1014 = a_9 / b_7;
    float3  _S1015 = make_float3 (0.0f);
    bool3  _S1016 = b_7 == _S1015;
    float3  _S1017 = _slang_select(_S1016, _S1015,_S1014);
    return _S1017;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1018 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1018 << offset_1))) | ((newbits_0 & _S1018) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_2 = r_7;
    uint _S1019 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1020 = insertBits_0(_S1019, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1020;
    (&candidate_2)->f = f_5;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S1021 = pcg(random_state_9);
    Random _S1022 = pcg(_S1021.state);
    float _S1023 = 1.0f - 2.0f * _S1021.value;
    float _S1024 = (F32_sqrt(((F32_max((1.0f - _S1023 * _S1023), (0.0f))))));
    float _S1025 = 6.28318548202514648f * _S1022.value;
    return make_float3 (_S1024 * (F32_cos((_S1025))), _S1024 * (F32_sin((_S1025))), _S1023);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_10, float * pdf_5)
{
    bool _S1026 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1026)
    {
        *pdf_5 = 0.07957746833562851f;
        float3  _S1027 = isotropic_0(random_state_10);
        return _S1027;
    }
    Random _S1028 = pcg(random_state_10);
    Random _S1029 = pcg(_S1028.state);
    float _S1030 = g_1 * g_1;
    float _S1031 = 2.0f * g_1;
    float _S1032 = (1.0f - _S1030) / (1.0f - g_1 + _S1031 * _S1028.value);
    float _S1033 = clamp_1((1.0f + _S1030 - _S1032 * _S1032) / _S1031, -1.0f, 1.0f);
    float _S1034 = (F32_sqrt(((F32_max((1.0f - _S1033 * _S1033), (0.0f))))));
    float _S1035 = 6.28318548202514648f * _S1029.value;
    float _S1036 = phaseHG_0(g_1, _S1033);
    *pdf_5 = _S1036;
    float3  _S1037 = tangentToWorld(make_float3 (_S1034 * (F32_cos((_S1035))), _S1033, _S1034 * (F32_sin((_S1035)))), dir_9);
    float3  _S1038 = ((((_S1037)) * make_float3(rnorm3df(((_S1037)).x, ((_S1037)).y, ((_S1037)).z))));
    return _S1038;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_5)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_2)
{
    BSDFMaterial _S1039;
    (&_S1039)->albedo = albedo_0;
    (&_S1039)->emissive = emissive_0;
    (&_S1039)->roughness = roughness_0;
    (&_S1039)->metallic = metallic_0;
    (&_S1039)->transmission = transmission_0;
    (&_S1039)->ior = ior_0;
    (&_S1039)->absorption = absorption_0;
    (&_S1039)->specular_tint = specular_tint_0;
    (&_S1039)->specular_level = specular_level_0;
    (&_S1039)->translucent = translucent_0;
    (&_S1039)->sheen = sheen_2;
    (&_S1039)->sheen_roughness = sheen_roughness_0;
    (&_S1039)->anisotropy = anisotropy_0;
    (&_S1039)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1039)->tangent = tangent_2;
    (&_S1039)->velvet = velvet_0;
    (&_S1039)->toon = toon_2;
    return _S1039;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1040;
    (&_S1040)->scatter = scatter_1;
    (&_S1040)->extinction = extinction_1;
    (&_S1040)->g = g_2;
    return _S1040;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_10, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1041;
    (&_S1041)->smooth_n = smooth_n_4;
    (&_S1041)->geometry_n = geometry_n_2;
    (&_S1041)->geometry_offset = geometry_offset_2;
    (&_S1041)->material = *material_10;
    (&_S1041)->skip = skip_0;
    (&_S1041)->random_state = random_state_11;
    (&_S1041)->coverage = coverage_0;
    (&_S1041)->encloses = encloses_0;
    (&_S1041)->volume = *volume_0;
    (&_S1041)->fills = fills_0;
    (&_S1041)->hair = hair_0;
    return _S1041;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S1042 = (&surface_6->material)->emissive;
    float3  _S1043 = make_float3 (0.0f);
    bool _S1044 = !top_0;
    float3  _S1045 = _slang_select(_S1044, _S1043,_S1042);
    (&(&lower_0)->material)->emissive = _S1045;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_2)
{
    float _S1046 = surface_7->coverage;
    bool _S1047 = u_2 < _S1046;
    if(_S1047)
    {
        return *surface_7;
    }
    float3  _S1048 = make_float3 (0.0f);
    float3  _S1049 = make_float3 (1.0f);
    BSDFMaterial _S1050 = Material_x24init_0(_S1048, _S1048, 0.0f, 0.0f, 0.0f, 0.0f, _S1048, _S1049, 1.0f, _S1048, _S1048, 0.5f, 0.0f, 0.0f, _S1048, 0.0f, _S1048);
    BSDFMaterial material_11 = _S1050;
    (&material_11)->albedo = _S1049;
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
    bool _S1051 = transmission_1 > 0.0f;
    bool _S1052;
    if(_S1051)
    {
        _S1052 = true;
    }
    else
    {
        _S1052 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1053;
    if(_S1052)
    {
        _S1053 = 1.0f;
    }
    else
    {
        _S1053 = -1.0f;
    }
    return _S1053;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_9)
{
    return (dot_0(dir_10, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_11)
{
    float3  _S1054 = surface_8->geometry_n;
    float _S1055 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_11);
    FKSurface faced_0 = *surface_8;
    float3  _S1056 = surface_8->smooth_n * make_float3 (_S1055);
    (&faced_0)->smooth_n = _S1056;
    float3  _S1057 = _S1054 * make_float3 (_S1055);
    (&faced_0)->geometry_n = _S1057;
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
    float3  _S1058 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1058));
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
    bool _S1059;
    if(open_0)
    {
        _S1059 = prev_rough_0;
    }
    else
    {
        _S1059 = false;
    }
    if(_S1059)
    {
        _S1059 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S1059 = false;
    }
    return _S1059;
}

__device__ float2  vertexEta(BSDFMaterial material_12, float n_dot_v_0)
{
    bool _S1060 = n_dot_v_0 < 0.0f;
    float _S1061 = _slang_select(_S1060, material_12.ior,1.0f);
    float _S1062 = _slang_select(_S1060, 1.0f,material_12.ior);
    return make_float2 (_S1061, _S1062);
}

__device__ bool neeDecision(BSDFMaterial material_13, float n_dot_v_1, float eta_i_9, float eta_o_9)
{
    float _S1063 = fresnel((F32_abs((n_dot_v_1))), eta_i_9, eta_o_9);
    float3  _S1064 = mix_0(make_float3 (_S1063), material_13.albedo, material_13.metallic);
    float _S1065 = rgb_to_greyscale(_S1064);
    float _S1066 = (F32_max(((1.0f - _S1065) * (1.0f - material_13.metallic) * (1.0f - material_13.transmission)), (0.0f)));
    bool _S1067 = _S1066 > 0.03999999910593033f;
    bool _S1068;
    if(_S1067)
    {
        _S1068 = true;
    }
    else
    {
        _S1068 = (material_13.roughness) > 0.20000000298023224f;
    }
    return _S1068;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_14)
{
    float _S1069 = rgb_to_greyscale(material_14->translucent);
    return _S1069 > 0.0f;
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
    MediumSides _S1070;
    (&_S1070)->behind = *behind_0;
    (&_S1070)->front = *front_0;
    (&_S1070)->fillings = fillings_1;
    (&_S1070)->face = face_1;
    return _S1070;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1071 = surface_9->geometry_n;
    MediumSides _S1072 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S1072;
    bool _S1073 = surface_9->encloses;
    if(_S1073)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S1074 = (dot_0(dir_12, _S1071)) > 0.0f;
        if(_S1074)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1075 = surface_10->geometry_n;
    ShadowContext _S1076 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1077 = surface_10->encloses;
    ShadowContext context_4;
    if(_S1077)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S1078 = - _S1075;
        float3  _S1079 = _slang_select(turned_0, _S1078,_S1075);
        (&faced_1)->geometry_n = _S1079;
        FKMedium _S1080 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1081 = faced_1;
        FKMedium _S1082 = _S1080;
        MediumSides _S1083 = mediumSides_0(&_S1081, &_S1082, filling_1, dir_13, outside_1);
        ShadowContext _S1084 = ShadowContext_x24init_0(_S1083.behind.extinction, _S1083.front.extinction, _S1083.fillings, _S1075, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1085 = _S1083.fillings;
            ShadowContext _S1086 = ShadowContext_x24init_0(_S1083.front.extinction, _S1083.behind.extinction, uint2 {_S1085.y, _S1085.x}, _S1075, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1086;
        }
        else
        {
            context_4 = _S1084;
        }
    }
    else
    {
        context_4 = _S1076;
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
    float3  _S1087 = light_2->dir;
    bool _S1088 = (dot_0(geometry_n_4, - in_dir_8) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_3;
    float3  _S1089 = BSDF(in_dir_8, _S1087, smooth_n_5, *material_15, eta_i_10, eta_o_10, _S1088, random_state_12, &throughputs_1, &pdfs_3);
    bool _S1090 = !competing_1;
    bool _S1091;
    if(_S1090)
    {
        _S1091 = true;
    }
    else
    {
        _S1091 = (light_2->density) == 0.0f;
    }
    if(_S1091)
    {
        return _S1089 * light_2->radiance;
    }
    float3  _S1092 = make_float3 (0.0f);
    uint i_23 = 0U;
    float3  weighted_0 = _S1092;
    for(;;)
    {
        if(i_23 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1093 = (pdfs_3[i_23]) > 0.0f;
        if(_S1093)
        {
            float _S1094 = light_2->density;
            float _S1095 = pdfs_3[i_23] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_23] * make_float3 (pdfs_3[i_23]) / make_float3 (_S1094 * (1.0f + _S1095 * _S1095));
            weighted_0 = weighted_1;
        }
        uint i_24 = i_23 + 1U;
        i_23 = i_24;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_13, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S1096;
    (&_S1096)->unit_direction = unit_direction_1;
    (&_S1096)->throughput = throughput_1;
    (&_S1096)->random_state = random_state_13;
    (&_S1096)->refracted = refracted_3;
    (&_S1096)->lobe = lobe_4;
    (&_S1096)->pdf = pdf_6;
    return _S1096;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_8, float n_i_dot_v_6, float alpha_15, BSDFMaterial material_16, BSDFLobes lobes_11, float eta_i_11, float eta_o_11, uint random_state_14)
{
    float3  _S1097 = make_float3 (1.0f);
    SampleBSDF _S1098 = SampleBSDF_x24init_0(_S1097, _S1097, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1098;
    Random _S1099 = pcg(random_state_14);
    Random _S1100 = pcg(_S1099.state);
    (&sample_1)->random_state = _S1100.state;
    float _S1101 = _S1099.value;
    float _S1102 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1101 * _S1101))))));
    float _S1103 = 6.28318548202514648f * _S1100.value;
    float3  _S1104 = tangentToWorld(make_float3 (_S1102 * (F32_cos((_S1103))), _S1099.value, _S1102 * (F32_sin((_S1103)))), n_i_8);
    (&sample_1)->unit_direction = _S1104;
    (&sample_1)->lobe = 4U;
    float3  _S1105 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_8, alpha_15, material_16, lobes_11);
    (&sample_1)->throughput = _S1105;
    float _S1106 = sheenVelvetPDF(_S1099.value, 0.0f, n_i_dot_v_6, alpha_15, lobes_11, eta_i_11, eta_o_11);
    (&sample_1)->pdf = _S1106;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1107 = (F32_sqrt((random_1_0)));
    float _S1108 = 6.28318548202514648f * random_2_0;
    float _S1109 = _S1107 * (F32_cos((_S1108)));
    float _S1110 = _S1107 * (F32_sin((_S1108)));
    float _S1111 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1109 * _S1109 - _S1110 * _S1110))))));
    return make_float3 (_S1109, _S1111, _S1110);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_9, float n_i_dot_v_7, float alpha_16, BSDFMaterial material_17, BSDFLobes lobes_12, float eta_i_12, float eta_o_12, uint random_state_15)
{
    float3  _S1112 = make_float3 (1.0f);
    SampleBSDF _S1113 = SampleBSDF_x24init_0(_S1112, _S1112, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1113;
    Random _S1114 = pcg(random_state_15);
    Random _S1115 = pcg(_S1114.state);
    (&sample_2)->random_state = _S1115.state;
    float3  _S1116 = sampleCosWeightedHemisphere(_S1114.value, _S1115.value);
    bool _S1117 = u_3 < (lobes_12.p_diffuse * lobes_12.translucent_share);
    float _S1118 = _S1116.y;
    float _S1119 = - _S1118;
    float _S1120 = _slang_select(_S1117, _S1119,_S1118);
    float3  _S1121 = tangentToWorld(make_float3 (_S1116.x, _S1120, _S1116.z), n_i_9);
    (&sample_2)->unit_direction = _S1121;
    (&sample_2)->refracted = _S1117;
    (&sample_2)->lobe = 0U;
    float3  _S1122 = diffuseBSDF((&sample_2)->unit_direction, n_i_9, alpha_16, material_17, lobes_12);
    (&sample_2)->throughput = _S1122;
    float _S1123 = diffusePDF(_S1120, 0.0f, n_i_dot_v_7, alpha_16, lobes_12, eta_i_12, eta_o_12);
    (&sample_2)->pdf = _S1123;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_10, float n_i_dot_v_8, float alpha_17, BSDFMaterial material_18, BSDFLobes lobes_13, float eta_i_13, float eta_o_13, uint random_state_16)
{
    float3  _S1124 = make_float3 (1.0f);
    SampleBSDF _S1125 = SampleBSDF_x24init_0(_S1124, _S1124, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1125;
    Random _S1126 = pcg(random_state_16);
    Random _S1127 = pcg(_S1126.state);
    (&sample_3)->random_state = _S1127.state;
    float _S1128 = _S1126.value * lobes_13.toon_norm / 6.28318548202514648f;
    float t_21;
    if(lobes_13.toon_glossy)
    {
        t_21 = (F32_acos((clamp_1(1.0f - _S1128, -1.0f, 1.0f))));
    }
    else
    {
        t_21 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1128)))), (1.0f))))));
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
        float _S1129;
        if(t_21 < (lobes_13.toon_a))
        {
            _S1129 = 1.0f;
        }
        else
        {
            _S1129 = (F32_max((1.0f - (t_21 - lobes_13.toon_a) / (F32_max((lobes_13.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float integral_1;
        if(lobes_13.toon_glossy)
        {
            integral_1 = 1.0f - (F32_cos(((F32_min((t_21), (lobes_13.toon_a))))));
        }
        else
        {
            float _S1130 = (F32_sin(((F32_min((t_21), (lobes_13.toon_a))))));
            integral_1 = _S1130 * _S1130 / 2.0f;
        }
        bool _S1131 = t_21 > (lobes_13.toon_a);
        bool _S1132;
        if(_S1131)
        {
            _S1132 = (lobes_13.toon_s) > 0.0f;
        }
        else
        {
            _S1132 = false;
        }
        float integral_2;
        if(_S1132)
        {
            if(lobes_13.toon_glossy)
            {
                float _S1133 = (F32_cos((lobes_13.toon_a)));
                float _S1134 = (F32_cos((t_21)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1133 - _S1134) - ((F32_sin((t_21))) - t_21 * _S1134 - ((F32_sin((lobes_13.toon_a))) - lobes_13.toon_a * _S1133)) / lobes_13.toon_s;
            }
            else
            {
                float _S1135 = 2.0f * lobes_13.toon_a;
                float _S1136 = (F32_cos((_S1135)));
                float _S1137 = 2.0f * t_21;
                float _S1138 = (F32_cos((_S1137)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1136 - _S1138) / 4.0f - ((F32_sin((_S1137))) / 8.0f - t_21 * _S1138 / 4.0f - ((F32_sin((_S1135))) / 8.0f - lobes_13.toon_a * _S1136 / 4.0f)) / lobes_13.toon_s;
            }
            float integral_3 = integral_1 + integral_2;
            integral_2 = integral_3;
        }
        else
        {
            integral_2 = integral_1;
        }
        float _S1139 = _S1129 * (F32_sin((t_21)));
        float _S1140;
        if(lobes_13.toon_glossy)
        {
            _S1140 = 1.0f;
        }
        else
        {
            _S1140 = (F32_cos((t_21)));
        }
        float _S1141 = _S1139 * _S1140;
        float _S1142 = (integral_2 - _S1128) / _S1141;
        bool _S1143 = _S1141 > 0.0f;
        float _S1144 = _slang_select(_S1143, _S1142,0.0f);
        float _S1145 = clamp_1(t_21 - _S1144, 0.0f, lobes_13.toon_b);
        int k_1 = k_0 + int(1);
        t_21 = _S1145;
        k_0 = k_1;
    }
    float _S1146 = 6.28318548202514648f * _S1127.value;
    float _S1147 = (F32_sin((t_21)));
    float3  _S1148 = tangentToWorld(make_float3 (_S1147 * (F32_cos((_S1146))), (F32_cos((t_21))), _S1147 * (F32_sin((_S1146)))), lobes_13.toon_axis);
    (&sample_3)->unit_direction = _S1148;
    bool _S1149 = (dot_0(n_i_10, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1149;
    (&sample_3)->lobe = 6U;
    float3  _S1150 = toonBSDF((&sample_3)->unit_direction, n_i_10, alpha_17, material_18, lobes_13);
    (&sample_3)->throughput = _S1150;
    float _S1151 = toonPDF(dot_0(n_i_10, (&sample_3)->unit_direction), dot_0((&sample_3)->unit_direction, lobes_13.toon_axis), n_i_dot_v_8, alpha_17, lobes_13, eta_i_13, eta_o_13);
    (&sample_3)->pdf = _S1151;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_11, float n_i_dot_v_9, float alpha_18, BSDFMaterial material_19, BSDFLobes lobes_14, float eta_i_14, float eta_o_14, uint random_state_17)
{
    float3  _S1152 = make_float3 (1.0f);
    SampleBSDF _S1153 = SampleBSDF_x24init_0(_S1152, _S1152, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1153;
    (&sample_4)->unit_direction = lobes_14.refracted;
    (&sample_4)->random_state = random_state_17;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1154 = refractBSDF((&sample_4)->unit_direction, n_i_11, alpha_18, material_19, lobes_14);
    (&sample_4)->throughput = _S1154;
    float _S1155 = refractPDF(0.0f, dot_0((&sample_4)->unit_direction, ggx_n_3), n_i_dot_v_9, alpha_18, lobes_14, eta_i_14, eta_o_14);
    (&sample_4)->pdf = _S1155;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_25, float3  n_10)
{
    return i_25 - make_float3 (2.0f * dot_0(n_10, i_25)) * n_10;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_12, float n_i_dot_v_10, float alpha_19, BSDFMaterial material_20, BSDFLobes lobes_15, float eta_i_15, float eta_o_15, uint random_state_18)
{
    float3  _S1156 = make_float3 (1.0f);
    SampleBSDF _S1157 = SampleBSDF_x24init_0(_S1156, _S1156, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1157;
    float3  _S1158 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S1159 = ((((_S1158)) * make_float3(rnorm3df(((_S1158)).x, ((_S1158)).y, ((_S1158)).z))));
    (&sample_5)->unit_direction = _S1159;
    (&sample_5)->random_state = random_state_18;
    (&sample_5)->lobe = 2U;
    float3  _S1160 = reflectBSDF((&sample_5)->unit_direction, n_i_12, alpha_19, material_20, lobes_15);
    (&sample_5)->throughput = _S1160;
    float _S1161 = reflectPDF(0.0f, 0.0f, n_i_dot_v_10, alpha_19, lobes_15, eta_i_15, eta_o_15);
    (&sample_5)->pdf = _S1161;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_11, BSDFMaterial material_21, float eta_i_16, float eta_o_16, uint random_init_0, float2  screen_space_0)
{
    uint random_state_19 = random_init_0;
    float3  _S1162 = negate_0(in_dir_10);
    float _S1163 = dot_0(n_11, _S1162);
    float _S1164 = sign_0(_S1163);
    float3  n_i_13 = n_11 * make_float3 (_S1164);
    float _S1165 = (F32_abs((_S1163)));
    float _S1166 = material_21.roughness;
    float _S1167 = _S1166 * _S1166;
    AnisotropicFrame _S1168 = anisotropicFrame(material_21, n_i_13);
    float3  _S1169 = sampleHalfVector(_S1162, n_i_13, _S1167, _S1168, &random_state_19);
    BSDFLobes _S1170 = bsdfLobes(in_dir_10, _S1162, n_i_13, _S1169, material_21, eta_i_16, eta_o_16, _S1168);
    BSDFLobes lobes_16 = _S1170;
    float _S1171 = translucentShare(material_21);
    (&lobes_16)->translucent_share = _S1171;
    Random _S1172 = pcg(random_state_19);
    random_state_19 = _S1172.state;
    bool _S1173 = (_S1172.value) < ((&lobes_16)->p_sheen_velvet);
    if(_S1173)
    {
        SampleBSDF _S1174 = sheenVelvetSample(n_i_13, _S1165, _S1167, material_21, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1174;
    }
    float _S1175 = _S1172.value - (&lobes_16)->p_sheen_velvet;
    bool _S1176 = _S1175 < ((&lobes_16)->p_diffuse);
    if(_S1176)
    {
        SampleBSDF _S1177 = diffuseSample(_S1175, n_i_13, _S1165, _S1167, material_21, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1177;
    }
    bool _S1178 = _S1175 < ((&lobes_16)->p_diffuse + (&lobes_16)->p_toon);
    if(_S1178)
    {
        SampleBSDF _S1179 = toonSample(n_i_13, _S1165, _S1167, material_21, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1179;
    }
    float _S1180 = (&lobes_16)->p_toon;
    bool _S1181 = (_S1175 - _S1180) < ((&lobes_16)->p_diffuse + (&lobes_16)->p_refract);
    if(_S1181)
    {
        SampleBSDF _S1182 = refractSample(_S1169, n_i_13, _S1165, _S1167, material_21, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1182;
    }
    SampleBSDF _S1183 = reflectSample(in_dir_10, _S1169, n_i_13, _S1165, _S1167, material_21, lobes_16, eta_i_16, eta_o_16, random_state_19);
    return _S1183;
}

__device__ bool withinInverseFootprint(float pdf_7, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1184 = pdf_7 > 0.0f;
    bool _S1185;
    if(_S1184)
    {
        if(diffuse_0)
        {
            _S1185 = true;
        }
        else
        {
            _S1185 = (pdf_7 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1185 = false;
    }
    return _S1185;
}

__device__ bool roughLobe(float pdf_8, bool diffuse_1, float roughness_1)
{
    bool _S1186 = pdf_8 > 0.0f;
    bool _S1187;
    if(_S1186)
    {
        if(diffuse_1)
        {
            _S1187 = true;
        }
        else
        {
            _S1187 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1187 = false;
    }
    return _S1187;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1188 = layers_0 > 1U;
    bool _S1189;
    if(_S1188)
    {
        _S1189 = refracting_0 != passed_0;
    }
    else
    {
        _S1189 = false;
    }
    return _S1189;
}

static __device__ float widened_0(float spread_1, float pdf_9, bool delta_0)
{
    float _S1190 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_9))))), (3.14159274101257324f)));
    bool _S1191 = !delta_0;
    float _S1192 = _slang_select(_S1191, _S1190,0.0f);
    return spread_1 + _S1192;
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
    bool _S1193;
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
    int _S1194;
    Shift ended_0;
    float density_3;
    float spread_3;
    float width_4;
    float sky_pdf_1;
    float spread_4;
    float width_5;
    uint b_9;
    float3  _S1195 = make_float3 (0.0f);
    Shift _S1196 = Shift_x24init_0(_S1195, 0.0f);
    uint _S1197 = r_8->path;
    uint _S1198 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1199 = extractBits_0(_S1197, 5U, 5U);
    uint _S1200 = extractBits_0(_S1197, 10U, 2U);
    uint _S1201 = extractBits_0(_S1197, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1202 = _S1201 >= 3U;
        uint _S1203 = _slang_select(_S1202, 1U,0U);
        uint _S1204 = _S1198 + _S1203;
        uint _S1205 = (fcptMaxBounces());
        passes_0 = _S1204 > _S1205;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1196;
    }
    uint _S1206 = _S1199 - 1U;
    bool _S1207 = _S1201 == 3U;
    uint _S1208 = _slang_select(_S1207, 1U,0U);
    uint _S1209 = _S1198 + _S1208;
    bool _S1210 = _S1200 == 0U;
    uint _S1211 = _slang_select(_S1210, _S1209,_S1206);
    FKHit _S1212 = (fcptReservoirHit((*r_8)));
    float3  _S1213 = dom_7->x0;
    float3  _S1214 = dom_7->x1 - dom_7->x0;
    float3  _S1215 = ((((_S1214)) * make_float3(rnorm3df(((_S1214)).x, ((_S1214)).y, ((_S1214)).z))));
    FKRay _S1216 = Ray_x24init_0(dom_7->x1, _S1215);
    FKRay ray_2 = _S1216;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1195;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1195;
    float3  extinction_in_0 = _S1195;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1217 = dom_7->spread;
    float _S1218 = dom_7->width;
    float _S1219 = length_0(_S1214);
    NEEVertex _S1220 = NEEVertex_x24init_0(true, 0.0f, _S1195, _S1195, _S1195);
    NEEVertex nee_vertex_0 = _S1220;
    Vertex _S1221 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1221;
    Reservoir _S1222 = (Reservoir{});
    Reservoir chain_0 = _S1222;
    uint _S1223 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1213;
    (&hit_4)->distance = _S1219;
    FKMedium _S1224 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1225 = filling_2;
    bool _S1226 = (fcptVaryingUsed());
    uint _S1227 = _slang_select(_S1226, _S1225,4294967295U);
    filling_2 = _S1227;
    scatter_in_0 = _S1224.scatter;
    extinction_in_0 = _S1224.extinction;
    g_in_0 = _S1224.g;
    Reservoir _S1228 = chain_0;
    uint _S1229 = filling_2;
    for(;;)
    {
        bool _S1230 = (fcptVaryingUsed());
        if(_S1230)
        {
            passes_0 = _S1229 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1231 = (fcptMajorant((_S1229)));
            spread_2 = _S1231;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1211;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1200 == 1U;
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
            ended_0 = _S1196;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1217;
            width_3 = _S1218;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_8 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1232 = (&prev_0)->rough;
        if(_S1232)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1233 = stream(_S1223, 384U);
        uint tracking_0 = _S1233;
        weight_1 = throughput_3;
        glowed_0 = _S1195;
        b_8 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_2 = _S1217;
        width_3 = _S1218;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1194 = int(1);
                break;
            }
            uint _S1234 = b_8 + 320U;
            bool _S1235 = b_8 == 4294967295U;
            uint _S1236 = _slang_select(_S1235, 384U,_S1234);
            uint _S1237 = stream(_S1223, _S1236);
            Random _S1238 = pcg(_S1237);
            float _S1239 = freeFlight_0(_S1238.value, spread_2);
            if(passes_0)
            {
                float3  _S1240 = (&ray_2)->origin;
                float3  _S1241 = (&ray_2)->unit_direction;
                float _S1242 = (&hit_4)->distance;
                uint _S1243 = _slang_select(_S1235, 0U,b_8);
                uint _S1244 = (&prev_0)->lobe;
                uint _S1245 = _slang_select(_S1235, 3U,_S1244);
                float _S1246 = (fcptTrackMedium((_S1229), (_S1240), (_S1241), (_S1242), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1243), (_S1245), (_S1235)));
                geometry_density_2 = _S1246;
            }
            else
            {
                geometry_density_2 = _S1239;
            }
            bool _S1247 = !(geometry_density_2 < ((&hit_4)->distance));
            if(_S1247)
            {
                _S1194 = int(1);
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
                float3  _S1248 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1249 = sel_7->glow + _S1248;
                sel_7->glow = _S1249;
            }
            else
            {
            }
            glowed_0 = _S1195;
            uint b_10 = b_8 + 1U;
            float3  _S1250 = (&ray_2)->origin + make_float3 (geometry_density_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1250;
            float3  _S1251 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, geometry_density_2, true);
            float3  _S1252 = weight_1;
            float3  _S1253 = _slang_select(passes_0, _S1252,_S1251);
            float3  throughput_4 = throughput_2 * _S1253;
            uint _S1254 = stream(_S1223, b_10 + 320U);
            tracking_0 = _S1254;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_2 * geometry_density_2;
            float _S1255 = threshold_2 + 3.14159274101257324f;
            bool _S1256 = scatterSampled_0(replay_2, b_10, _S1211, passes_0);
            TreeSample _S1257 = TreeSample_x24init_0(_S1195, _S1195, 0.0f, 0U);
            if(_S1256)
            {
                float3  _S1258 = (&ray_2)->origin;
                float3  _S1259 = (&ray_2)->unit_direction;
                float3  _S1260 = (&ray_2)->unit_direction;
                uint _S1261 = stream(_S1223, b_10 + 64U);
                float3  _S1262 = extinction_in_0;
                float3  _S1263 = extinction_in_0;
                uint2  _S1264 = make_uint2 (_S1229);
                float3  _S1265 = (&ray_2)->unit_direction;
                uint _S1266 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                FKHit _S1267 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1268 = _S1267;
                ShadowContext _S1269 = ShadowContext_x24init_0(_S1262, _S1263, _S1264, _S1265, b_10, _S1266, false, geometry_density_2, width_6, &_S1268, false);
                ShadowContext _S1270 = _S1269;
                TreeSample _S1271 = sampleLightTree_0(_S1258, _S1259, _S1260, 0.0f, true, _S1261, &_S1270);
                light_3 = _S1271;
            }
            else
            {
                light_3 = _S1257;
            }
            float _S1272 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1273 = (fcptMaxBounces());
            bool _S1274 = b_10 < _S1273;
            if(_S1274)
            {
                is_inside_6 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_6 = false;
            }
            float _S1275 = _slang_select(is_inside_6, _S1272,0.0f);
            float3  _S1276 = throughput_4 * light_3.radiance;
            float _S1277 = powerHeuristic(light_3.density, _S1275);
            float3  _S1278 = _S1276 * make_float3 (_S1272 * _S1277);
            float3  _S1279 = _slang_select(_S1256, _S1278,_S1195);
            if(replay_2)
            {
                viewed_0 = b_10 == _S1211;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1280 = _S1200 == 2U;
                if(_S1280)
                {
                    float _S1281 = rgb_to_greyscale(_S1279);
                    passes_0 = _S1281 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1282 = Shift_x24init_0(_S1279, 1.0f);
                    _S1194 = int(0);
                    ended_0 = _S1282;
                    spread_2 = _S1255;
                    geometry_density_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_10;
                    break;
                }
                _S1194 = int(0);
                ended_0 = _S1196;
                spread_2 = _S1255;
                geometry_density_2 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_10;
                break;
            }
            bool _S1283 = !replay_2;
            if(_S1283)
            {
                Reservoir candidate_3 = _S1228;
                uint _S1284 = extractBits_0(_S1228.path, 10U, 2U);
                bool _S1285 = _S1284 == 1U;
                if(_S1285)
                {
                    float3  _S1286 = safeDivide(_S1279, _S1195);
                    (&candidate_3)->radiance = _S1286;
                }
                else
                {
                    uint _S1287 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                    uint _S1288 = insertBits_0(_S1287, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1288;
                }
                Reservoir _S1289 = withEnd(candidate_3, 0U, b_10, _S1279);
                offer(sel_7, _S1289, _S1279 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1290 = survivalProbability(throughput_4, density_2);
                uint _S1291 = stream(_S1223, b_10 + 128U);
                Random _S1292 = pcg(_S1291);
                bool _S1293 = _S1290 < (_S1292.value);
                if(_S1293)
                {
                    _S1193 = true;
                }
                else
                {
                    uint _S1294 = (fcptMaxBounces());
                    _S1193 = b_10 >= _S1294;
                }
                if(_S1193)
                {
                    _S1194 = int(0);
                    ended_0 = _S1196;
                    spread_2 = _S1255;
                    geometry_density_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_10;
                    break;
                }
                float _S1295 = density_2 * _S1290;
                density_2 = _S1295;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1296 = stream(_S1223, b_10);
            float3  _S1297 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1296, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1297;
            NEEVertex _S1298 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1195, (&ray_2)->origin);
            nee_vertex_0 = _S1298;
            Vertex _S1299 = scatteredVertex_0(false);
            prev_0 = _S1299;
            float _S1300 = (&prev_0)->pdf;
            FKRay _S1301 = ray_2;
            FKHit _S1302 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1303 = (fcptTraverseInstanceBVH((_S1301), (true), (4.294967296e+09f), (false), (_S1302), (false)));
            hit_4 = _S1303;
            b_8 = b_10;
            throughput_2 = throughput_4;
            threshold_2 = _S1255;
            width_3 = width_6;
            sky_pdf_0 = _S1300;
        }
        if(_S1194 != int(1))
        {
            width_3 = geometry_density_2;
            throughput_2 = chain_throughput_0;
            b_8 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1196;
        spread_2 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1304 = b_8 == 4294967295U;
    bool _S1305 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1305)
    {
        bool _S1306 = !(&nee_vertex_0)->none;
        float _S1307 = _slang_select(_S1306, sky_pdf_0,0.0f);
        float _S1308 = escapeWeight_0(_S1307, (&ray_2)->unit_direction);
        float3  _S1309 = environment_0((&ray_2)->unit_direction, b_8, (&prev_0)->lobe);
        float3  _S1310 = throughput_2 * _S1309;
        if(replay_2)
        {
            bool _S1311 = b_8 == _S1211;
            if(_S1311)
            {
                passes_0 = _S1200 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1310 * make_float3 (_S1308) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1210)
            {
                passes_0 = _S1207;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_8 == _S1198;
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
                return Shift_x24init_0(_S1310 * make_float3 (_S1308), 1.0f);
            }
            return _S1196;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1312 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1313 = _S1312 == 1U;
        if(_S1313)
        {
            uint _S1314 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1315 = _S1314 == b_8;
            float _S1316 = _slang_select(_S1315, 1.0f,_S1308);
            float3  _S1317 = safeDivide(_S1310 * make_float3 (_S1316), _S1195);
            (&candidate_4)->radiance = _S1317;
        }
        else
        {
            bool _S1318 = (&prev_0)->rough;
            if(_S1318)
            {
                uint _S1319 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                uint _S1320 = insertBits_0(_S1319, 3U, 10U, 2U);
                uint _S1321 = insertBits_0(_S1320, (&prev_0)->lobe, 15U, 3U);
                bool _S1322 = (&prev_0)->inside;
                uint _S1323 = _slang_select(_S1322, 1U,0U);
                uint _S1324 = insertBits_0(_S1321, _S1323, 22U, 1U);
                (&candidate_4)->path = _S1324;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1325 = _S1310 * make_float3 (_S1308);
        Reservoir _S1326 = withEnd(candidate_4, 3U, b_8, _S1325);
        offer(sel_7, _S1326, _S1325 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1196;
    }
    float3  _S1327 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1327;
    bool _S1328 = (fcptVaryingUsed());
    if(_S1328)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1329 = !replay_2;
        if(_S1329)
        {
            float3  _S1330 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1331 = sel_7->glow + _S1330;
            sel_7->glow = _S1331;
        }
        float3  _S1332 = throughput_2 * weight_1;
        throughput_2 = _S1332;
    }
    else
    {
        float3  _S1333 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1334 = throughput_2 * _S1333;
        throughput_2 = _S1334;
    }
    float _S1335 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1336 = b_8 + 1U;
    b_8 = _S1336;
    layer_0 = 0U;
    width_3 = _S1335;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_6 = false;
    chain_throughput_0 = _S1195;
    float3  reconnection_0 = _S1195;
    viewed_0 = _S1304;
    for(;;)
    {
        bool _S1337 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1193 = _S1200 == 1U;
        }
        else
        {
            _S1193 = false;
        }
        bool _S1338;
        if(_S1193)
        {
            _S1338 = b_8 == _S1199;
        }
        else
        {
            _S1338 = false;
        }
        bool _S1339;
        if(_S1338)
        {
            bool _S1340 = ((&hit_4)->instance_index) != (_S1212.instance_index);
            if(_S1340)
            {
                _S1339 = true;
            }
            else
            {
                _S1339 = ((&hit_4)->triangle_index) != (_S1212.triangle_index);
            }
        }
        else
        {
            _S1339 = false;
        }
        if(_S1339)
        {
            return _S1196;
        }
        FKMedium _S1341 = Medium_x24init_0(_S1195, _S1195, 0.0f);
        BSDFMaterial _S1342 = Material_x24init_0(_S1195, _S1195, 0.0f, 0.0f, 0.0f, 0.0f, _S1195, throughput_3, 1.0f, _S1195, _S1195, 0.5f, 0.0f, 0.0f, _S1195, 0.0f, _S1195);
        FKMedium _S1343 = _S1341;
        FKSurface _S1344 = Surface_x24init_0(_S1195, _S1195, 0.0f, &_S1342, false, 0U, 1.0f, false, &_S1343, 4294967295U, _S1195);
        bool _S1345 = !_S1337;
        bool scatter_2;
        bool is_inside_7;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S1345)
        {
            uint _S1346 = stream(_S1223, b_8);
            uint _S1347 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKSurface _S1348 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1346), (width_3), (layer_0), (b_8), (_S1347), ((&ray_2)->unit_direction)));
            bool _S1349 = !passes_0;
            FKSurface _S1350 = _S1348;
            FKSurface _S1351 = emitting_0(&_S1350, _S1349);
            uint _S1352 = stream(_S1223, b_8 + 256U);
            Random _S1353 = pcg(_S1352);
            FKSurface _S1354 = _S1351;
            FKSurface _S1355 = uncovered_0(&_S1354, _S1353.value);
            float _S1356 = facingSign(_S1355.material.transmission, _S1355.geometry_n, (&ray_2)->unit_direction);
            bool _S1357 = _S1356 < 0.0f;
            bool _S1358 = (_S1355.material.transmission) > 0.0f;
            if(_S1358)
            {
                bool _S1359 = arrivesBehind_0((&ray_2)->unit_direction, _S1355.geometry_n);
                scatter_2 = _S1359;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1360 = _S1355;
            FKSurface _S1361 = facingRay_0(&_S1360, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1362 = arrivesBehind_0((&ray_2)->unit_direction, _S1361.geometry_n);
                is_inside_7 = _S1362;
            }
            else
            {
                is_inside_7 = scatter_2;
            }
            if(is_inside_7)
            {
                float3  _S1363 = beerLambert((&hit_4)->distance, _S1361.material.absorption);
                float3  _S1364 = throughput_2 * _S1363;
                throughput_5 = _S1364;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1365 = !_S1361.skip;
            float geometry_density_3 = geometryDensity(_S1361.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1366 = b_8 == _S1336;
            if(_S1366)
            {
                float _S1367 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1367;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1368 = geometry_density_2;
            scatter_2 = _S1365;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1368;
            surface_12 = _S1361;
            turned_1 = _S1357;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_12 = _S1344;
            throughput_5 = throughput_2;
            is_inside_7 = is_inside_6;
        }
        bool _S1369 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1370 = surface_12;
        FKSurface _S1371 = surface_12;
        float _S1372 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        float2  _S1373 = vertexEta(_S1370.material, _S1372);
        bool _S1374;
        if(scatter_2)
        {
            bool _S1375 = neeDecision(_S1370.material, _S1372, _S1373.x, _S1373.y);
            _S1374 = _S1375;
        }
        else
        {
            _S1374 = false;
        }
        bool _S1376;
        if(passes_0)
        {
            _S1376 = true;
        }
        else
        {
            _S1376 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1376)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1374;
        }
        bool _S1377 = (fcptHairUsed());
        bool _S1378;
        if(_S1377)
        {
            float3  _S1379 = surface_12.hair;
            _S1378 = (dot_0(_S1379, _S1379)) > 0.0f;
        }
        else
        {
            _S1378 = false;
        }
        bool _S1380;
        if(_S1378)
        {
            _S1380 = true;
        }
        else
        {
            BSDFMaterial _S1381 = _S1370.material;
            bool _S1382 = isTranslucent_0(&_S1381);
            _S1380 = _S1382;
        }
        bool _S1383;
        if(_S1380)
        {
            _S1383 = true;
        }
        else
        {
            bool _S1384 = (_S1370.material.transmission) > 0.0f;
            if(_S1384)
            {
                uint _S1385 = (fcptLayers((hit_4)));
                _S1383 = _S1385 == 1U;
            }
            else
            {
                _S1383 = false;
            }
        }
        float3  emission_0;
        if(_S1337)
        {
            float3  _S1386 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1386;
        }
        else
        {
            emission_0 = _S1370.material.emissive;
        }
        bool _S1387 = !replay_2;
        bool _S1388;
        if(_S1387)
        {
            _S1388 = true;
        }
        else
        {
            _S1388 = b_8 >= _S1211;
        }
        bool _S1389;
        if(_S1388)
        {
            float _S1390 = rgb_to_greyscale(emission_0);
            _S1389 = _S1390 > 0.0f;
        }
        else
        {
            _S1389 = false;
        }
        float3  emission_1;
        if(_S1389)
        {
            NEEVertex _S1391 = nee_vertex_0;
            FKHit _S1392 = hit_4;
            float _S1393 = emissionWeight_0(&_S1391, &_S1392, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1393);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1394;
        if(replay_2)
        {
            _S1394 = _S1200 == 1U;
        }
        else
        {
            _S1394 = false;
        }
        bool _S1395;
        if(_S1394)
        {
            _S1395 = b_8 > _S1199;
        }
        else
        {
            _S1395 = false;
        }
        bool _S1396;
        if(_S1395)
        {
            _S1396 = b_8 == _S1198;
        }
        else
        {
            _S1396 = false;
        }
        bool _S1397;
        if(_S1396)
        {
            bool _S1398 = _S1201 == 1U;
            if(_S1398)
            {
                _S1397 = true;
            }
            else
            {
                _S1397 = _S1201 == 2U;
            }
        }
        else
        {
            _S1397 = false;
        }
        if(_S1397)
        {
            bool _S1399 = _S1337 != (_S1201 == 2U);
            if(_S1399)
            {
                return _S1196;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1400 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1401 = _S1400 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1402 = insertBits_0(0U, b_8, 5U, 5U);
        uint _S1403 = insertBits_0(_S1402, 1U, 10U, 2U);
        uint _S1404 = insertBits_0(_S1403, (&prev_0)->lobe, 15U, 3U);
        bool _S1405 = (&prev_0)->inside;
        uint _S1406 = _slang_select(_S1405, 1U,0U);
        uint _S1407 = insertBits_0(_S1404, _S1406, 22U, 1U);
        (&here_0)->path = _S1407;
        float _S1408 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1408;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1409;
        if(replay_2)
        {
            _S1409 = _S1200 == 1U;
        }
        else
        {
            _S1409 = false;
        }
        bool _S1410;
        if(_S1409)
        {
            _S1410 = b_8 == _S1199;
        }
        else
        {
            _S1410 = false;
        }
        bool _S1411 = b_8 == _S1211;
        bool _S1412;
        if(_S1411)
        {
            bool _S1413 = !scatter_2;
            if(_S1413)
            {
                _S1412 = true;
            }
            else
            {
                bool _S1414 = _S1200 != 1U;
                if(_S1414)
                {
                    _S1412 = _S1200 != 3U;
                }
                else
                {
                    _S1412 = false;
                }
            }
        }
        else
        {
            _S1412 = false;
        }
        bool _S1415;
        if(_S1412)
        {
            _S1415 = _S1200 == 2U;
        }
        else
        {
            _S1415 = false;
        }
        bool _S1416;
        if(_S1415)
        {
            _S1416 = !_S1369;
        }
        else
        {
            _S1416 = false;
        }
        bool _S1417;
        if(_S1416)
        {
            _S1417 = _S1201 != 4U;
        }
        else
        {
            _S1417 = false;
        }
        bool _S1418 = _S1199 == _S1198;
        bool _S1419;
        if(_S1418)
        {
            _S1419 = _S1201 == 0U;
        }
        else
        {
            _S1419 = false;
        }
        bool _S1420;
        if(_S1419)
        {
            _S1420 = ((&hit_4)->instance_index) == (_S1212.instance_index);
        }
        else
        {
            _S1420 = false;
        }
        bool _S1421;
        if(_S1420)
        {
            _S1421 = ((&hit_4)->triangle_index) == (_S1212.triangle_index);
        }
        else
        {
            _S1421 = false;
        }
        bool _S1422;
        if(_S1421)
        {
            _S1422 = _S1369;
        }
        else
        {
            _S1422 = false;
        }
        bool _S1423 = _slang_select(_S1410, _S1422,_S1417);
        bool _S1424;
        if(nee_0)
        {
            _S1424 = _slang_select(replay_2, _S1423,scatter_2);
        }
        else
        {
            _S1424 = false;
        }
        TreeSample _S1425 = TreeSample_x24init_0(_S1195, _S1195, 0.0f, 0U);
        uint2  _S1426 = make_uint2 (0U);
        float2  _S1427 = make_float2 (0.0f);
        FKHit _S1428 = Hit_x24init_0(_S1427, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1429 = _S1428;
        ShadowContext _S1430 = ShadowContext_x24init_0(_S1195, _S1195, _S1426, _S1195, 0U, 0U, false, 0.0f, 0.0f, &_S1429, false);
        bool _S1431;
        if(nee_0)
        {
            _S1431 = _S1388;
        }
        else
        {
            _S1431 = false;
        }
        ShadowContext context_5;
        if(_S1431)
        {
            uint _S1432 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKMedium _S1433 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1434 = surface_12;
            FKHit _S1435 = hit_4;
            FKMedium _S1436 = _S1433;
            ShadowContext _S1437 = shadowContext_0(&_S1434, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_8, _S1432, (&hit_4)->distance, width_3, &_S1435, _S1378, &_S1436);
            context_5 = _S1437;
        }
        else
        {
            context_5 = _S1430;
        }
        float3  throughput_6;
        float3  lit_0;
        if(_S1424)
        {
            float3  _S1438 = (&ray_2)->origin;
            if(_S1378)
            {
                throughput_6 = _S1195;
            }
            else
            {
                throughput_6 = _S1371.smooth_n;
            }
            FKSurface _S1439 = surface_12;
            uint _S1440 = stream(_S1223, b_8 + 64U);
            ShadowContext _S1441 = context_5;
            TreeSample _S1442 = sampleLightTree_0(_S1438, throughput_6, surface_12.geometry_n, surface_12.geometry_offset, _S1383, _S1440, &_S1441);
            bool _S1443 = any_1((_S1442.radiance) != _S1195);
            if(_S1443)
            {
                if(_S1378)
                {
                    uint _S1444 = (fcptMaxBounces());
                    bool _S1445 = b_8 < _S1444;
                    FKSurface _S1446 = surface_12;
                    TreeSample _S1447 = _S1442;
                    float3  _S1448 = hairLight_0(&_S1446, (&ray_2)->unit_direction, &_S1447, _S1445);
                    lit_0 = _S1448;
                }
                else
                {
                    float _S1449 = _S1373.x;
                    float _S1450 = _S1373.y;
                    uint _S1451 = (fcptMaxBounces());
                    bool _S1452 = b_8 < _S1451;
                    TreeSample _S1453 = _S1442;
                    BSDFMaterial _S1454 = _S1370.material;
                    float3  _S1455 = lightBSDF_0((&ray_2)->unit_direction, &_S1453, _S1371.smooth_n, _S1439.geometry_n, &_S1454, _S1449, _S1450, _S1452, surface_12.random_state);
                    lit_0 = _S1455;
                }
            }
            else
            {
                lit_0 = _S1195;
            }
            light_3 = _S1442;
        }
        else
        {
            light_3 = _S1425;
            lit_0 = _S1195;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1456;
        bool _S1457;
        float density_4;
        if(_S1410)
        {
            bool _S1458 = !_S1369;
            if(_S1458)
            {
                return _S1196;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1418)
            {
                viewed_1 = _S1201 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1418)
            {
                refracted_4 = _S1201 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1459 = !nee_0;
                if(_S1459)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1460 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1460 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1196;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1418)
            {
                wrong_side_0 = _S1201 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1461 = !nee_0;
                if(_S1461)
                {
                    return _S1196;
                }
                float _S1462 = environmentPdf_0(r_8->dir);
                float3  _S1463 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_12, _S1373, is_inside_7, _S1462, surface_12.random_state);
                return Shift_x24init_0(throughput_7 * _S1463 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1464 = extractBits_0(_S1197, 21U, 1U);
            bool _S1465 = nee_0 != (_S1464 == 1U);
            if(_S1465)
            {
                return _S1196;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1411;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1466 = !scatter_2;
                if(_S1466)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1467 = _S1200 != 1U;
                    if(_S1467)
                    {
                        refracted_4 = _S1200 != 3U;
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
                bool _S1468 = _S1200 == 2U;
                if(_S1468)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1369;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1201 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1378)
                    {
                        return _S1196;
                    }
                    uint _S1469 = stream(_S1223, b_8 + 448U);
                    FKRay _S1470 = ray_2;
                    FKSurface _S1471 = surface_12;
                    ShadowContext _S1472 = context_5;
                    SkySample _S1473 = sampleSky_0(&_S1470, &_S1471, _S1373, is_inside_7, _S1469, surface_12.random_state, &_S1472);
                    return Shift_x24init_0(throughput_5 * _S1473.color, 1.0f);
                }
                if(_S1468)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1369;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1474 = rgb_to_greyscale(light_3.radiance);
                    bool _S1475 = !(_S1474 > 0.0f);
                    if(_S1475)
                    {
                        return _S1196;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S1210)
                {
                    passes_0 = _S1201 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1337;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S1210)
                {
                    passes_0 = _S1201 == 1U;
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
                    passes_0 = !_S1369;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S1196;
            }
            else
            {
                if(_S1387)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1476 = b_8 > 0U;
                    if(_S1476)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1401)
                        {
                            float3  _S1477 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1477;
                        }
                        else
                        {
                            if(_S1369)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1478 = throughput_5 * emission_1;
                        Reservoir _S1479 = withEnd(candidate_5, 1U, b_8, _S1478);
                        offer(sel_7, _S1479, _S1478 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1480 = throughput_5 * emission_1;
                        float3  _S1481 = sel_7->glow + _S1480;
                        sel_7->glow = _S1481;
                    }
                    if(nee_0)
                    {
                        float3  _S1482 = throughput_5 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1401)
                        {
                            float3  _S1483 = safeDivide(_S1482, chain_throughput_0);
                            (&candidate_6)->radiance = _S1483;
                        }
                        else
                        {
                            if(_S1369)
                            {
                                candidate_6 = here_0;
                                uint _S1484 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1484;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1485 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                                uint _S1486 = insertBits_0(_S1485, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1486;
                            }
                        }
                        Reservoir _S1487 = withEnd(candidate_6, 0U, b_8, _S1482);
                        offer(sel_7, _S1487, _S1482 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1378)
                        {
                            _S1456 = false;
                        }
                        else
                        {
                            bool _S1488 = environmentMapped_0();
                            _S1456 = _S1488;
                        }
                    }
                    else
                    {
                        _S1456 = false;
                    }
                    if(_S1456)
                    {
                        uint _S1489 = (fcptMaxBounces());
                        _S1457 = b_8 < _S1489;
                    }
                    else
                    {
                        _S1457 = false;
                    }
                    if(_S1457)
                    {
                        uint _S1490 = stream(_S1223, b_8 + 448U);
                        FKRay _S1491 = ray_2;
                        FKSurface _S1492 = surface_12;
                        ShadowContext _S1493 = context_5;
                        SkySample _S1494 = sampleSky_0(&_S1491, &_S1492, _S1373, is_inside_7, _S1490, surface_12.random_state, &_S1493);
                        float3  _S1495 = throughput_5 * _S1494.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1401)
                        {
                            float3  _S1496 = safeDivide(_S1495, chain_throughput_0);
                            (&candidate_7)->radiance = _S1496;
                        }
                        else
                        {
                            if(_S1369)
                            {
                                candidate_7 = here_0;
                                uint _S1497 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1497;
                                (&candidate_7)->dir = _S1494.dir;
                                (&candidate_7)->radiance = _S1494.radiance;
                            }
                            else
                            {
                                uint _S1498 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                                uint _S1499 = insertBits_0(_S1498, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1499;
                            }
                        }
                        Reservoir _S1500 = withEnd(candidate_7, 4U, b_8, _S1495);
                        offer(sel_7, _S1500, _S1495 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1501;
        bool _S1502;
        bool _S1503;
        bool straight_0;
        bool _S1504;
        bool _S1505;
        bool _S1506;
        bool _S1507;
        bool _S1508;
        bool _S1509;
        bool _S1510;
        bool _S1511;
        bool _S1512;
        bool _S1513;
        bool _S1514;
        bool _S1515;
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
                viewed_1 = _S1411;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1516 = extractBits_0(_S1197, 15U, 3U);
            uint _S1517 = extractBits_0(_S1197, 18U, 3U);
            uint _S1518 = _slang_select(_S1410, _S1517,_S1516);
            float3  _S1519 = r_8->dir;
            bool refracted_5 = _S1518 == 1U;
            SampleBSDF _S1520 = SampleBSDF_x24init_0(_S1195, _S1195, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1520;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1521 = extractBits_0(_S1197, 22U, 1U);
                bool _S1522 = is_inside_7 != (_S1521 == 1U);
                if(_S1522)
                {
                    return _S1196;
                }
                bool _S1523 = _S1200 == 1U;
                if(_S1523)
                {
                    float3  _S1524 = (fcptHitPosition((_S1212)));
                    throughput_8 = _S1524;
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
                    BSDFMaterial _S1525 = _S1370.material;
                    bool _S1526 = isTranslucent_0(&_S1525);
                    if(_S1526)
                    {
                        refracted_4 = _S1518 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1527 = throughput_8 - (&ray_2)->origin;
                        float3  _S1528 = _slang_select(_S1523, _S1527,_S1519);
                        wrong_side_0 = (dot_0(_S1371.smooth_n, _S1528) * _S1372) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1523)
                {
                    float3  _S1529 = (&ray_2)->origin;
                    FKSurface _S1530 = surface_12;
                    float3  _S1531 = - _S1371.smooth_n;
                    bool _S1532 = is_inside_7 != refracted_4;
                    float3  _S1533 = _slang_select(_S1532, _S1531,_S1371.smooth_n);
                    float3  _S1534 = throughput_8 - (_S1529 + make_float3 (_S1530.geometry_offset) * _S1533);
                    float3  _S1535 = ((((_S1534)) * make_float3(rnorm3df(((_S1534)).x, ((_S1534)).y, ((_S1534)).z))));
                    reconnection_1 = _S1535;
                }
                else
                {
                    reconnection_1 = _S1519;
                }
                if(_S1378)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1536 = wrongSide_0(is_inside_7, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1536;
                }
                if(wrong_side_0)
                {
                    return _S1196;
                }
                float3  _S1537 = throughput_8;
                throughput_8 = reconnection_1;
                b_11 = _S1518;
                wrong_side_0 = false;
                reconnection_1 = _S1537;
            }
            else
            {
                bool _S1538 = !_S1410;
                if(_S1538)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1539;
                    if(_S1378)
                    {
                        SampleBSDF _S1540 = (fcptSampleHair((surface_12.hair), (_S1370.material.albedo), (_S1370.material.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1539 = _S1540;
                    }
                    else
                    {
                        SampleBSDF _S1541 = sampleBSDF((&ray_2)->unit_direction, _S1371.smooth_n, _S1370.material, _S1373.x, _S1373.y, surface_12.random_state, _S1427);
                        _S1539 = _S1541;
                    }
                    bsdf_sampled_0 = _S1539;
                    if(_S1378)
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
                            return _S1196;
                        }
                        break;
                    }
                    if(_S1378)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1542 = wrongSide_0(is_inside_7, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1542;
                    }
                    if(wrong_side_0)
                    {
                        _S1456 = (_S1370.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1456 = false;
                    }
                    if(_S1456)
                    {
                        SampleBSDF _S1543 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1370.material, _S1373.x, _S1373.y, (&bsdf_sampled_0)->random_state, _S1427);
                        (&bsdf_sampled_0)->unit_direction = _S1543.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1543.refracted;
                        (&bsdf_sampled_0)->throughput = _S1543.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1544 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1544;
                        }
                    }
                    uint _S1545 = (&bsdf_sampled_0)->lobe;
                    float3  _S1546 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1547 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1548 = (&bsdf_sampled_0)->pdf;
                    float _S1549 = _slang_select(wrong_side_0, 0.0f,_S1548);
                    (&lobe_5)->pdf = _S1549;
                    throughput_8 = _S1546;
                    b_11 = _S1545;
                    refracted_4 = _S1547;
                }
                else
                {
                    throughput_8 = _S1519;
                    b_11 = _S1518;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1456 = true;
            }
            else
            {
                _S1456 = _S1410;
            }
            float3  chain_throughput_1;
            if(_S1456)
            {
                if(_S1378)
                {
                    SampleBSDF _S1550 = (fcptConnectHair((surface_12.hair), (_S1370.material.albedo), (_S1370.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    lobe_5 = _S1550;
                }
                else
                {
                    float3  _S1551 = (&ray_2)->unit_direction;
                    float _S1552 = sign_0(_S1372);
                    float3  _S1553 = _S1371.smooth_n * make_float3 (_S1552);
                    float _S1554 = dot_0(_S1553, throughput_8);
                    float _S1555 = _S1370.material.roughness;
                    float _S1556 = _S1555 * _S1555;
                    AnisotropicFrame _S1557 = anisotropicFrame(_S1370.material, _S1553);
                    float3  _S1558 = reflectedHalf(_S1551, throughput_8);
                    bool _S1559 = b_11 == 1U;
                    if(_S1559)
                    {
                        float3  _S1560 = refractedHalf(_S1551, throughput_8, _S1371.smooth_n, _S1373.x, _S1373.y);
                        throughput_9 = _S1560;
                    }
                    else
                    {
                        throughput_9 = _S1558;
                    }
                    bool _S1561 = b_11 == 0U;
                    if(_S1561)
                    {
                        _S1457 = true;
                    }
                    else
                    {
                        _S1457 = b_11 == 6U;
                    }
                    if(_S1457)
                    {
                        float3  _S1562 = sampledHalf(_S1551, _S1371.smooth_n, _S1370.material, surface_12.random_state, _S1557);
                        throughput_10 = _S1562;
                    }
                    else
                    {
                        throughput_10 = throughput_9;
                    }
                    float3  _S1563 = negate_0(_S1551);
                    float _S1564 = _S1373.x;
                    float _S1565 = _S1373.y;
                    BSDFLobes _S1566 = bsdfLobes(_S1551, _S1563, _S1553, throughput_10, _S1370.material, _S1564, _S1565, _S1557);
                    BSDFLobes lobe_terms_1 = _S1566;
                    float _S1567 = translucentShare(_S1370.material);
                    (&lobe_terms_1)->translucent_share = _S1567;
                    switch(b_11)
                    {
                    case 0U:
                        {
                            float _S1568 = diffusePDF(_S1554, 0.0f, (F32_abs((_S1372))), _S1556, lobe_terms_1, _S1564, _S1565);
                            float3  _S1569 = diffuseBSDF(throughput_8, _S1553, _S1556, _S1370.material, lobe_terms_1);
                            density_6 = _S1568;
                            chain_throughput_1 = _S1569;
                            break;
                        }
                    case 1U:
                        {
                            float _S1570 = refractPDF(_S1554, dot_0(throughput_8, throughput_10), (F32_abs((_S1372))), _S1556, lobe_terms_1, _S1564, _S1565);
                            float3  _S1571 = refractBSDF(throughput_8, _S1553, _S1556, _S1370.material, lobe_terms_1);
                            density_6 = _S1570;
                            chain_throughput_1 = _S1571;
                            break;
                        }
                    case 4U:
                        {
                            float _S1572 = sheenVelvetPDF(_S1554, 0.0f, (F32_abs((_S1372))), _S1556, lobe_terms_1, _S1564, _S1565);
                            float3  _S1573 = sheenVelvetBSDF(throughput_8, _S1553, _S1556, _S1370.material, lobe_terms_1);
                            density_6 = _S1572;
                            chain_throughput_1 = _S1573;
                            break;
                        }
                    case 6U:
                        {
                            float _S1574 = toonPDF(_S1554, dot_0(throughput_8, (&lobe_terms_1)->toon_axis), (F32_abs((_S1372))), _S1556, lobe_terms_1, _S1564, _S1565);
                            float3  _S1575 = toonBSDF(throughput_8, _S1553, _S1556, _S1370.material, lobe_terms_1);
                            density_6 = _S1574;
                            chain_throughput_1 = _S1575;
                            break;
                        }
                    default:
                        {
                            float _S1576 = reflectPDF(_S1554, 0.0f, (F32_abs((_S1372))), _S1556, lobe_terms_1, _S1564, _S1565);
                            float3  _S1577 = reflectBSDF(throughput_8, _S1553, _S1556, _S1370.material, lobe_terms_1);
                            density_6 = _S1576;
                            chain_throughput_1 = _S1577;
                            break;
                        }
                    }
                    bool _S1578 = density_6 > 0.0f;
                    if(_S1578)
                    {
                        SampleBSDF _S1579 = SampleBSDF_x24init_0(throughput_8, chain_throughput_1, surface_12.random_state, _S1559, b_11, density_6);
                        lobe_5 = _S1579;
                    }
                }
            }
            bool _S1580 = b_11 == 0U;
            if(_S1580)
            {
                _S1457 = true;
            }
            else
            {
                _S1457 = b_11 == 4U;
            }
            if(_S1457)
            {
                _S1501 = true;
            }
            else
            {
                _S1501 = b_11 == 6U;
            }
            if(_S1378)
            {
                _S1502 = false;
            }
            else
            {
                bool _S1581 = !_S1501;
                if(_S1581)
                {
                    bool _S1582 = (_S1370.material.roughness) == 0.0f;
                    if(_S1582)
                    {
                        _S1502 = true;
                    }
                    else
                    {
                        bool _S1583 = b_11 == 1U;
                        if(_S1583)
                        {
                            _S1502 = (_S1373.x) == (_S1373.y);
                        }
                        else
                        {
                            _S1502 = false;
                        }
                    }
                }
                else
                {
                    _S1502 = false;
                }
            }
            bool _S1584 = !_S1378;
            if(_S1584)
            {
                _S1503 = b_11 == 1U;
            }
            else
            {
                _S1503 = false;
            }
            if(_S1503)
            {
                straight_0 = (_S1370.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1504 = _S1584;
            }
            else
            {
                _S1504 = false;
            }
            if(_S1504)
            {
                _S1505 = b_11 == 1U;
            }
            else
            {
                _S1505 = false;
            }
            if(_S1505)
            {
                _S1506 = (_S1373.x) == (_S1373.y);
            }
            else
            {
                _S1506 = false;
            }
            BSDFMaterial _S1585 = _S1370.material;
            bool _S1586 = isTranslucent_0(&_S1585);
            if(_S1586)
            {
                _S1507 = _S1580;
            }
            else
            {
                _S1507 = false;
            }
            if(_S1507)
            {
                _S1508 = (dot_0(throughput_8, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1508 = false;
            }
            if(nee_0)
            {
                _S1509 = !_S1502;
            }
            else
            {
                _S1509 = false;
            }
            if(_S1509)
            {
                _S1510 = !wrong_side_0;
            }
            else
            {
                _S1510 = false;
            }
            if(_S1510)
            {
                float _S1587 = (&lobe_5)->pdf;
                float3  _S1588 = (&ray_2)->origin;
                float3  _S1589 = _slang_select(_S1383, _S1195,_S1371.smooth_n);
                float3  _S1590 = (&ray_2)->origin;
                FKSurface _S1591 = surface_12;
                float3  _S1592 = - _S1371.smooth_n;
                float3  _S1593 = _slang_select(_S1508, _S1592,_S1371.smooth_n);
                NEEVertex _S1594 = NEEVertex_x24init_0(false, _S1587, _S1588, _S1589, _S1590 + make_float3 (_S1591.geometry_offset) * _S1593);
                nee_vertex_0 = _S1594;
            }
            else
            {
                if(_S1378)
                {
                    _S1511 = true;
                }
                else
                {
                    bool _S1595 = b_11 != 1U;
                    if(_S1595)
                    {
                        _S1511 = true;
                    }
                    else
                    {
                        _S1511 = (_S1373.x) != (_S1373.y);
                    }
                }
                if(_S1511)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1596 = withinInverseFootprint((&lobe_5)->pdf, _S1501, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1597 = roughLobe((&lobe_5)->pdf, _S1501, _S1370.material.roughness);
            if(_S1410)
            {
                bool _S1598 = !_S1596;
                if(_S1598)
                {
                    return _S1196;
                }
                bool _S1599 = _S1201 != 1U;
                if(_S1599)
                {
                    _S1511 = _S1201 != 2U;
                }
                else
                {
                    _S1511 = false;
                }
                if(_S1511)
                {
                    float _S1600 = (&lobe_5)->pdf;
                    float _S1601 = _slang_select(nee_0, _S1600,0.0f);
                    float _S1602 = escapeWeight_0(_S1601, _S1519);
                    if(_S1418)
                    {
                        passes_0 = _S1207;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1603 = _slang_select(passes_0, _S1602,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1603) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1604 = throughput_6 * make_float3 ((&lobe_5)->pdf);
                float _S1605 = density_4 * (&lobe_5)->pdf;
                throughput_9 = _S1604;
                density_6 = _S1605;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1606 = (fcptLayers((hit_4)));
            bool _S1607 = b_11 == 1U;
            bool _S1608 = passesLayer_0(_S1606, _S1607, passes_0);
            if(viewed_1)
            {
                _S1511 = _S1608;
            }
            else
            {
                _S1511 = false;
            }
            if(_S1511)
            {
                return _S1196;
            }
            if(replay_2)
            {
                _S1512 = b_8 <= _S1211;
            }
            else
            {
                _S1512 = false;
            }
            if(_S1512)
            {
                _S1513 = _S1369;
            }
            else
            {
                _S1513 = false;
            }
            if(_S1513)
            {
                _S1514 = _S1596;
            }
            else
            {
                _S1514 = false;
            }
            if(_S1514)
            {
                _S1515 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1515 = !_S1597;
                }
                else
                {
                    _S1515 = false;
                }
            }
            if(_S1515)
            {
                return _S1196;
            }
            if(viewed_1)
            {
                float3  _S1609 = throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1610 = (&lobe_5)->pdf;
                throughput_10 = _S1609;
                sky_pdf_2 = _S1610;
            }
            else
            {
                float3  _S1611 = throughput_9 * max_0((&lobe_5)->throughput, _S1195);
                throughput_10 = _S1611;
                sky_pdf_2 = density_6;
            }
            bool _S1612;
            if(_S1387)
            {
                _S1612 = !_S1401;
            }
            else
            {
                _S1612 = false;
            }
            bool _S1613;
            if(_S1612)
            {
                _S1613 = _S1369;
            }
            else
            {
                _S1613 = false;
            }
            bool _S1614;
            if(_S1613)
            {
                _S1614 = _S1596;
            }
            else
            {
                _S1614 = false;
            }
            if(_S1614)
            {
                chain_0 = here_0;
                uint _S1615 = insertBits_0((&chain_0)->path, b_11, 18U, 3U);
                uint _S1616 = _slang_select(nee_0, 1U,0U);
                uint _S1617 = insertBits_0(_S1615, _S1616, 21U, 1U);
                (&chain_0)->path = _S1617;
                float _S1618 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1618;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1619 = surface_12;
            Vertex _S1620 = Vertex_x24init_0(_S1597, b_11, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_8)))), is_inside_7);
            prev_0 = _S1620;
            float _S1621 = (&lobe_5)->pdf;
            bool _S1622;
            if(_S1607)
            {
                _S1622 = (_S1373.x) == (_S1373.y);
            }
            else
            {
                _S1622 = false;
            }
            float sky_pdf_3 = _slang_select(_S1622, sky_pdf_0,_S1621);
            float _S1623 = _slang_select(_S1378, 0.0f,sky_pdf_3);
            float _S1624 = widened_0(spread_2, (&lobe_5)->pdf, _S1502);
            bool _S1625;
            if(refracted_4)
            {
                _S1625 = !_S1508;
            }
            else
            {
                _S1625 = false;
            }
            bool is_inside_8;
            if(_S1625)
            {
                bool _S1626 = !is_inside_7;
                is_inside_8 = _S1626;
            }
            else
            {
                is_inside_8 = is_inside_7;
            }
            FKSurface _S1627 = surface_12;
            bool _S1628 = boundsVolume_0(&_S1627);
            bool _S1629;
            if(_S1628)
            {
                _S1629 = !_S1608;
            }
            else
            {
                _S1629 = false;
            }
            if(_S1629)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1630 = - _S1619.geometry_n;
                float3  _S1631 = _slang_select(turned_1, _S1630,_S1619.geometry_n);
                (&faced_2)->geometry_n = _S1631;
                FKMedium _S1632 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1633 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1634 = faced_2;
                FKMedium _S1635 = _S1632;
                FKMedium _S1636 = _S1633;
                MediumSides _S1637 = mediumSides_0(&_S1634, &_S1635, filling_2, (&ray_2)->unit_direction, &_S1636);
                bool _S1638 = leavesInFront_0((&faced_2)->geometry_n, throughput_8, _S1619.geometry_n);
                float3  _S1639 = _slang_select(_S1638, _S1637.front.scatter,_S1637.behind.scatter);
                scatter_in_0 = _S1639;
                float3  _S1640 = _slang_select(_S1638, _S1637.front.extinction,_S1637.behind.extinction);
                extinction_in_0 = _S1640;
                float _S1641 = _slang_select(_S1638, _S1637.front.g,_S1637.behind.g);
                g_in_0 = _S1641;
                uint _S1642 = _S1637.fillings.x;
                uint _S1643 = _S1637.fillings.y;
                uint _S1644 = _slang_select(_S1638, _S1643,_S1642);
                bool _S1645 = (fcptVaryingUsed());
                uint _S1646 = _slang_select(_S1645, _S1644,4294967295U);
                filling_2 = _S1646;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1647 = !_S1608;
            if(_S1647)
            {
                FKSurface _S1648 = surface_12;
                float _S1649 = _slang_select(straight_0, 0.0f,_S1648.geometry_offset);
                float3  _S1650 = - _S1371.smooth_n;
                bool _S1651 = is_inside_8 != _S1508;
                float3  _S1652 = _slang_select(_S1651, _S1650,_S1371.smooth_n);
                float3  _S1653 = (&ray_2)->origin + make_float3 (_S1649) * _S1652;
                (&ray_2)->origin = _S1653;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1608;
            viewed_1 = _S1506;
            sky_pdf_2 = _S1623;
            spread_5 = _S1624;
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
        if(_S1387)
        {
            if(_S1337)
            {
                float3  _S1654 = throughput_9 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1655 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1656 = _S1655 == 1U;
                if(_S1656)
                {
                    float3  _S1657 = safeDivide(_S1654, chain_throughput_0);
                    (&candidate_8)->radiance = _S1657;
                }
                Reservoir _S1658 = withEnd(candidate_8, 2U, b_8, _S1654);
                offer(sel_7, _S1658, _S1654 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1337)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1659 = survivalProbability(throughput_9, density_6);
                density_7 = _S1659;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1660 = stream(_S1223, b_8 + 128U);
            Random _S1661 = pcg(_S1660);
            bool _S1662 = density_7 < (_S1661.value);
            if(_S1662)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1663 = (fcptMaxBounces());
                wrong_side_0 = b_8 >= _S1663;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1664 = density_6 * density_7;
            density_7 = _S1664;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1665 = layer_0 ^ 1U;
        uint _S1666 = _slang_select(passes_0, _S1665,0U);
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
            uint _S1667 = b_11 + 1U;
            b_8 = _S1667;
            layer_0 = _S1666;
            continue;
        }
        FKRay _S1668 = ray_2;
        float _S1669 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1411;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1200 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1670 = _slang_select(wrong_side_0, _S1669,4.294967296e+09f);
        bool _S1671 = !_S1378;
        if(straight_0)
        {
            _S1456 = true;
        }
        else
        {
            _S1456 = _S1378;
        }
        FKHit _S1672;
        if(_S1456)
        {
            _S1672 = hit_4;
        }
        else
        {
            _S1672 = _S1428;
        }
        FKHit _S1673 = (fcptTraverseInstanceBVH((_S1668), (_S1345), (_S1670), (_S1671), (_S1672), (viewed_1)));
        hit_4 = _S1673;
        if(replay_2)
        {
            _S1457 = _S1411;
        }
        else
        {
            _S1457 = false;
        }
        if(_S1457)
        {
            _S1501 = _S1200 == 1U;
        }
        else
        {
            _S1501 = false;
        }
        if(_S1501)
        {
            _S1502 = ((&hit_4)->instance_index) == (_S1212.instance_index);
        }
        else
        {
            _S1502 = false;
        }
        if(_S1502)
        {
            _S1503 = ((&hit_4)->triangle_index) == (_S1212.triangle_index);
        }
        else
        {
            _S1503 = false;
        }
        if(_S1503)
        {
            (&hit_4)->uv = _S1212.uv;
            float _S1674 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1674;
        }
        if(replay_2)
        {
            _S1504 = _S1411;
        }
        else
        {
            _S1504 = false;
        }
        if(_S1504)
        {
            _S1505 = _S1200 == 3U;
        }
        else
        {
            _S1505 = false;
        }
        if(_S1505)
        {
            _S1506 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1506 = false;
        }
        if(_S1506)
        {
            return _S1196;
        }
        Reservoir _S1675 = chain_0;
        uint _S1676 = filling_2;
        for(;;)
        {
            bool _S1677 = (fcptVaryingUsed());
            if(_S1677)
            {
                _S1507 = _S1676 != 4294967295U;
            }
            else
            {
                _S1507 = false;
            }
            float _S1678;
            if(_S1507)
            {
                float _S1679 = (fcptMajorant((_S1676)));
                _S1678 = _S1679;
            }
            else
            {
                _S1678 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1508 = _S1411;
            }
            else
            {
                _S1508 = false;
            }
            if(_S1508)
            {
                _S1509 = _S1200 == 1U;
            }
            else
            {
                _S1509 = false;
            }
            if(_S1509)
            {
                _S1510 = _S1678 > 0.0f;
            }
            else
            {
                _S1510 = false;
            }
            if(_S1510)
            {
                ended_0 = _S1196;
                sky_pdf_1 = sky_pdf_2;
                spread_3 = spread_5;
                width_4 = width_3;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_11 = b_8;
                _S1511 = true;
                break;
            }
            bool _S1680 = (&prev_0)->rough;
            if(_S1680)
            {
                _S1511 = !(_S1678 > 0.0f);
            }
            else
            {
                _S1511 = false;
            }
            (&prev_0)->rough = _S1511;
            uint _S1681 = b_8 + 320U;
            bool _S1682 = b_8 == 4294967295U;
            uint _S1683 = _slang_select(_S1682, 384U,_S1681);
            uint _S1684 = stream(_S1223, _S1683);
            uint tracking_1 = _S1684;
            weight_1 = throughput_3;
            glowed_0 = _S1195;
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
                    _S1194 = int(2);
                    break;
                }
                uint _S1685 = b_11 + 320U;
                bool _S1686 = b_11 == 4294967295U;
                uint _S1687 = _slang_select(_S1686, 384U,_S1685);
                uint _S1688 = stream(_S1223, _S1687);
                Random _S1689 = pcg(_S1688);
                float _S1690 = freeFlight_0(_S1689.value, _S1678);
                if(_S1507)
                {
                    float3  _S1691 = (&ray_2)->origin;
                    float3  _S1692 = (&ray_2)->unit_direction;
                    float _S1693 = (&hit_4)->distance;
                    uint _S1694 = _slang_select(_S1686, 0U,b_11);
                    uint _S1695 = (&prev_0)->lobe;
                    uint _S1696 = _slang_select(_S1686, 3U,_S1695);
                    float _S1697 = (fcptTrackMedium((_S1676), (_S1691), (_S1692), (_S1693), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1694), (_S1696), (_S1686)));
                    spread_4 = _S1697;
                }
                else
                {
                    spread_4 = _S1690;
                }
                bool _S1698 = !(spread_4 < ((&hit_4)->distance));
                if(_S1698)
                {
                    _S1194 = int(2);
                    break;
                }
                if(_S1507)
                {
                    _S1512 = _S1387;
                }
                else
                {
                    _S1512 = false;
                }
                if(_S1512)
                {
                    float3  _S1699 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1700 = sel_7->glow + _S1699;
                    sel_7->glow = _S1700;
                }
                else
                {
                }
                glowed_0 = _S1195;
                uint b_12 = b_11 + 1U;
                float3  _S1701 = (&ray_2)->origin + make_float3 (spread_4) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1701;
                float3  _S1702 = flightWeight_0(scatter_in_0, extinction_in_0, _S1678, spread_4, true);
                float3  _S1703 = weight_1;
                float3  _S1704 = _slang_select(_S1507, _S1703,_S1702);
                float3  throughput_11 = throughput_10 * _S1704;
                uint _S1705 = stream(_S1223, b_12 + 320U);
                tracking_1 = _S1705;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_3 * spread_4;
                float _S1706 = spread_3 + 3.14159274101257324f;
                bool _S1707 = scatterSampled_0(replay_2, b_12, _S1211, _S1507);
                TreeSample light_4;
                if(_S1707)
                {
                    float3  _S1708 = (&ray_2)->origin;
                    float3  _S1709 = (&ray_2)->unit_direction;
                    float3  _S1710 = (&ray_2)->unit_direction;
                    uint _S1711 = stream(_S1223, b_12 + 64U);
                    float3  _S1712 = extinction_in_0;
                    float3  _S1713 = extinction_in_0;
                    uint2  _S1714 = make_uint2 (_S1676);
                    float3  _S1715 = (&ray_2)->unit_direction;
                    uint _S1716 = arrivalLobe_0(b_12, (&prev_0)->lobe);
                    FKHit _S1717 = _S1428;
                    ShadowContext _S1718 = ShadowContext_x24init_0(_S1712, _S1713, _S1714, _S1715, b_12, _S1716, false, spread_4, width_7, &_S1717, false);
                    ShadowContext _S1719 = _S1718;
                    TreeSample _S1720 = sampleLightTree_0(_S1708, _S1709, _S1710, 0.0f, true, _S1711, &_S1719);
                    light_4 = _S1720;
                }
                else
                {
                    light_4 = _S1425;
                }
                float _S1721 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1722 = (fcptMaxBounces());
                bool _S1723 = b_12 < _S1722;
                if(_S1723)
                {
                    _S1513 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1513 = false;
                }
                float _S1724 = _slang_select(_S1513, _S1721,0.0f);
                float3  _S1725 = throughput_11 * light_4.radiance;
                float _S1726 = powerHeuristic(light_4.density, _S1724);
                float3  _S1727 = _S1725 * make_float3 (_S1721 * _S1726);
                float3  _S1728 = _slang_select(_S1707, _S1727,_S1195);
                if(replay_2)
                {
                    _S1514 = b_12 == _S1211;
                }
                else
                {
                    _S1514 = false;
                }
                if(_S1514)
                {
                    bool _S1729 = _S1200 == 2U;
                    if(_S1729)
                    {
                        float _S1730 = rgb_to_greyscale(_S1728);
                        _S1515 = _S1730 > 0.0f;
                    }
                    else
                    {
                        _S1515 = false;
                    }
                    if(_S1515)
                    {
                        Shift _S1731 = Shift_x24init_0(_S1728, 1.0f);
                        _S1194 = int(1);
                        ended_0 = _S1731;
                        spread_4 = _S1706;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_9 = b_12;
                        break;
                    }
                    _S1194 = int(1);
                    ended_0 = _S1196;
                    spread_4 = _S1706;
                    width_5 = width_7;
                    throughput_8 = throughput_11;
                    b_9 = b_12;
                    break;
                }
                if(_S1387)
                {
                    Reservoir candidate_9 = _S1675;
                    uint _S1732 = extractBits_0(_S1675.path, 10U, 2U);
                    bool _S1733 = _S1732 == 1U;
                    if(_S1733)
                    {
                        float3  _S1734 = safeDivide(_S1728, chain_throughput_0);
                        (&candidate_9)->radiance = _S1734;
                    }
                    else
                    {
                        uint _S1735 = insertBits_0(0U, b_12 + 1U, 5U, 5U);
                        uint _S1736 = insertBits_0(_S1735, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1736;
                    }
                    Reservoir _S1737 = withEnd(candidate_9, 0U, b_12, _S1728);
                    offer(sel_7, _S1737, _S1728 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1738 = survivalProbability(throughput_11, density_3);
                    uint _S1739 = stream(_S1223, b_12 + 128U);
                    Random _S1740 = pcg(_S1739);
                    bool _S1741 = _S1738 < (_S1740.value);
                    if(_S1741)
                    {
                        _S1515 = true;
                    }
                    else
                    {
                        uint _S1742 = (fcptMaxBounces());
                        _S1515 = b_12 >= _S1742;
                    }
                    if(_S1515)
                    {
                        _S1194 = int(1);
                        ended_0 = _S1196;
                        spread_4 = _S1706;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_9 = b_12;
                        break;
                    }
                    float _S1743 = density_3 * _S1738;
                    density_3 = _S1743;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1744 = stream(_S1223, b_12);
                float3  _S1745 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1744, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1745;
                NEEVertex _S1746 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1195, (&ray_2)->origin);
                nee_vertex_0 = _S1746;
                Vertex _S1747 = scatteredVertex_0(is_inside_6);
                prev_0 = _S1747;
                float _S1748 = (&prev_0)->pdf;
                FKRay _S1749 = ray_2;
                FKHit _S1750 = (fcptTraverseInstanceBVH((_S1749), (true), (4.294967296e+09f), (false), (_S1428), (false)));
                hit_4 = _S1750;
                b_11 = b_12;
                throughput_10 = throughput_11;
                spread_3 = _S1706;
                width_4 = width_7;
                sky_pdf_1 = _S1748;
            }
            if(_S1194 != int(2))
            {
                spread_3 = spread_4;
                width_4 = width_5;
                throughput_10 = throughput_8;
                b_11 = b_9;
                _S1511 = true;
                break;
            }
            ended_0 = _S1196;
            _S1511 = false;
            break;
        }
        if(_S1511)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1512 = b_11 == b_8;
        }
        else
        {
            _S1512 = false;
        }
        bool _S1751 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1751)
        {
            bool _S1752 = !(&nee_vertex_0)->none;
            float _S1753 = _slang_select(_S1752, sky_pdf_1,0.0f);
            float _S1754 = escapeWeight_0(_S1753, (&ray_2)->unit_direction);
            float3  _S1755 = environment_0((&ray_2)->unit_direction, b_11, (&prev_0)->lobe);
            float3  _S1756 = throughput_10 * _S1755;
            if(replay_2)
            {
                bool _S1757 = b_11 == _S1211;
                if(_S1757)
                {
                    passes_0 = _S1200 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1756 * make_float3 (_S1754) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1210)
                {
                    passes_0 = _S1207;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_11 == _S1198;
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
                    return Shift_x24init_0(_S1756 * make_float3 (_S1754), 1.0f);
                }
                return _S1196;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1758 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1759 = _S1758 == 1U;
            if(_S1759)
            {
                uint _S1760 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1761 = _S1760 == b_11;
                float _S1762 = _slang_select(_S1761, 1.0f,_S1754);
                float3  _S1763 = safeDivide(_S1756 * make_float3 (_S1762), chain_throughput_0);
                (&candidate_10)->radiance = _S1763;
            }
            else
            {
                bool _S1764 = (&prev_0)->rough;
                if(_S1764)
                {
                    uint _S1765 = insertBits_0(0U, b_11 + 1U, 5U, 5U);
                    uint _S1766 = insertBits_0(_S1765, 3U, 10U, 2U);
                    uint _S1767 = insertBits_0(_S1766, (&prev_0)->lobe, 15U, 3U);
                    bool _S1768 = (&prev_0)->inside;
                    uint _S1769 = _slang_select(_S1768, 1U,0U);
                    uint _S1770 = insertBits_0(_S1767, _S1769, 22U, 1U);
                    (&candidate_10)->path = _S1770;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1771 = _S1756 * make_float3 (_S1754);
            Reservoir _S1772 = withEnd(candidate_10, 3U, b_11, _S1771);
            offer(sel_7, _S1772, _S1771 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1773 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1773;
        bool _S1774 = (fcptVaryingUsed());
        if(_S1774)
        {
            _S1513 = filling_2 != 4294967295U;
        }
        else
        {
            _S1513 = false;
        }
        if(_S1513)
        {
            if(_S1387)
            {
                float3  _S1775 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1776 = sel_7->glow + _S1775;
                sel_7->glow = _S1776;
            }
            float3  _S1777 = throughput_10 * weight_1;
            throughput_8 = _S1777;
        }
        else
        {
            float3  _S1778 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1779 = throughput_10 * _S1778;
            throughput_8 = _S1779;
        }
        float _S1780 = width_4 + spread_3 * (&hit_4)->distance;
        viewed_0 = _S1512;
        width_3 = _S1780;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_3;
        uint _S1667 = b_11 + 1U;
        b_8 = _S1667;
        layer_0 = _S1666;
    }
    return _S1196;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_9)
{
    Selection _S1781 = (Selection{});
    Selection sel_8 = _S1781;
    bool _S1782 = (r_9->w) <= 0.0f;
    if(_S1782)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1783 = walk_0(dom_8, r_9, true, 0.0f, &sel_8);
    return _S1783;
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
    Random _S1784 = pcg(state_4);
    Random _S1785 = pcg(_S1784.state);
    float _S1786 = 6.28318548202514648f * _S1784.value;
    float _S1787 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1785.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1785.state, _S1787 * (F32_cos((_S1786))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S1788;
    (&_S1788)->state = state_5;
    (&_S1788)->value = value_2;
    return _S1788;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S1789 = normal_distribution(state_6);
    Random _S1790 = normal_distribution(_S1789.state);
    Random _S1791 = normal_distribution(_S1790.state);
    float3  _S1792 = make_float3 (_S1789.value, _S1790.value, _S1791.value);
    float3  _S1793 = ((((_S1792)) * make_float3(rnorm3df(((_S1792)).x, ((_S1792)).y, ((_S1792)).z))));
    return RandomSphere_x24init_0(_S1791.state, _S1793);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_12)
{
    float3  _S1794 = p1_0 - p0_0;
    float3  _S1795 = p2_0 - p0_0;
    float2  _S1796 = uv1_0 - uv0_0;
    float2  _S1797 = uv2_0 - uv0_0;
    float _S1798 = _S1796.x;
    float _S1799 = _S1797.y;
    float _S1800 = _S1796.y;
    float _S1801 = _S1797.x;
    float _S1802 = _S1798 * _S1799 - _S1800 * _S1801;
    float _S1803 = 1.0f / _S1802;
    float3  t_22 = (_S1794 * make_float3 (_S1799) - _S1795 * make_float3 (_S1800)) * make_float3 (_S1803);
    float3  _S1804 = (_S1795 * make_float3 (_S1798) - _S1794 * make_float3 (_S1801)) * make_float3 (_S1803);
    float3  _S1805 = t_22 - n_12 * make_float3 (dot_0(n_12, t_22));
    float3  t_23 = ((((_S1805)) * make_float3(rnorm3df(((_S1805)).x, ((_S1805)).y, ((_S1805)).z))));
    bool _S1806 = (dot_0(cross_0(n_12, t_23), _S1804)) > 0.0f;
    float3  t_24;
    if(_S1806)
    {
        float3  _S1807 = negate_0(t_23);
        t_24 = _S1807;
    }
    else
    {
        t_24 = t_23;
    }
    float3  _S1808 = cross_0(n_12, t_24);
    return makeMatrix<float, 3, 3> (t_24, _S1808, n_12);
}

__device__ float3  tangentToWorldNormalMap(float3  v_4, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_4, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1809 = t1_0 - t0_0;
    float3  _S1810 = t2_2 - t0_0;
    float3  _S1811 = t2_2 - t1_0;
    float _S1812 = (F32_min((length_0(_S1809)), ((F32_min((length_0(_S1810)), (length_0(_S1811)))))));
    float3  _S1813 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1814 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1815 = dot_0(geometry_n_5, _S1814);
    float3  _S1816 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1817 = dot_0(geometry_n_5, _S1816);
    float3  _S1818 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1819 = acos_0(abs_0(make_float3 (_S1815, _S1817, dot_0(geometry_n_5, _S1818))));
    float3  _S1820 = clamp_2(tan_0(_S1819), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1813 * _S1820, uvw_0), 0.0f, _S1812 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_15, float3  n_13, BSDFMaterial material_22)
{
    float3  _S1821 = negate_0(dir_15);
    float _S1822 = sign_0(dot_0(n_13, _S1821));
    float3  _S1823 = n_13 * make_float3 (_S1822);
    AnisotropicFrame _S1824 = anisotropicFrame(material_22, _S1823);
    bool _S1825 = (_S1824.alphas.x) > 0.0f;
    if(_S1825)
    {
        float _S1826 = material_22.transmission * (1.0f - material_22.metallic);
        float3  _S1827 = negate_0(_S1823);
        float3  _S1828 = anisotropicLocal(dir_15, _S1824.tangent, _S1827);
        float _S1829 = anisotropicG1(_S1828, _S1824.alphas);
        return make_float3 (_S1826 * _S1829) * material_22.albedo;
    }
    float _S1830 = material_22.transmission * (1.0f - material_22.metallic);
    float _S1831 = material_22.roughness;
    float _S1832 = smithG1(_S1831 * _S1831, (F32_abs((dot_0(n_13, dir_15)))));
    return make_float3 (_S1830 * _S1832) * material_22.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_25, float3  out_dir_3, uint p_14, float w_2, float alpha_20, uint nt_0)
{
    uint _S1833 = p_14 % 4U;
    float _S1834 = w_2 * HAIR_WIDTHS_0[_S1833];
    float _S1835 = (F32_asin((clamp_1(dot_0(out_dir_3, t_25), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_25), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1833] * alpha_20;
    return ((F32_asinh((_S1835 / _S1834))) / (F32_asinh((3.14159274101257324f / _S1834))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_26, float3  out_dir_4, uint np_0)
{
    float3  _S1836 = worldToTangent(out_dir_4, t_26);
    float3  _S1837 = worldToTangent(in_dir_12, t_26);
    return (F32_frac((((F32_atan2((_S1836.z), (_S1836.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1837.z), (1.17549435082228751e-38f - _S1837.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_27, uint p_15, float row_0, float column_0, float w_3, float alpha_21, uint nt_1, uint np_1)
{
    float3  _S1838 = worldToTangent(in_dir_13, t_27);
    uint _S1839 = p_15 % 4U;
    float _S1840 = w_3 * HAIR_WIDTHS_0[_S1839];
    float _S1841 = (F32_asin((clamp_1(dot_0(in_dir_13, t_27), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1839] * alpha_21 + _S1840 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1840))))));
    float _S1842 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1838.z), (1.17549435082228751e-38f - _S1838.x)));
    float _S1843 = (F32_cos((_S1841)));
    float3  _S1844 = tangentToWorld(make_float3 (_S1843 * (F32_cos((_S1842))), (F32_sin((_S1841))), _S1843 * (F32_sin((_S1842)))), t_27);
    return _S1844;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_14, BSDFMaterial material_23, float coverage_1)
{
    float3  _S1845;
    if((material_23.ior) == 1.0f)
    {
        float3  _S1846 = straightThrough(toward_1, n_14, material_23);
        _S1845 = _S1846;
    }
    else
    {
        _S1845 = make_float3 (0.0f);
    }
    return _S1845 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_4, Selection * sel_9)
{
    Domain _S1847 = dom_9;
    Reservoir _S1848 = r_10;
    Shift _S1849 = walk_0(&_S1847, &_S1848, replay_3, scale_4, sel_9);
    return _S1849;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_11)
{
    Domain _S1850 = dom_10;
    Reservoir _S1851 = r_11;
    Shift _S1852 = shift_0(&_S1850, &_S1851);
    return _S1852;
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
