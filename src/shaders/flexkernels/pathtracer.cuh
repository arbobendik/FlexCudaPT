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
    float3  coat_series;
    bool coat_behind;
    float coat_sin;
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

static __device__ MaterialTerms MaterialTerms_x24init_0(float f0_0, float eta_level_0, float translucent_share_0, float3  coat_series_0, bool coat_behind_0, float coat_sin_0, float toon_scale_0, float toon_component_0, float3  toon_0, float toon_a_0, float toon_s_0, float toon_b_0, bool toon_glossy_0, float toon_norm_0)
{
    MaterialTerms _S315;
    (&_S315)->f0 = f0_0;
    (&_S315)->eta_level = eta_level_0;
    (&_S315)->translucent_share = translucent_share_0;
    (&_S315)->coat_series = coat_series_0;
    (&_S315)->coat_behind = coat_behind_0;
    (&_S315)->coat_sin = coat_sin_0;
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
    bool _S319 = eta_i_0 > eta_o_0;
    float _S320 = (F32_max((material_1.coat_ior), (1.00999999046325684f)));
    float _S321 = eta_i_0 / _S320;
    float3  _S322 = make_float3 (1.0f);
    bool _S323 = (material_1.coat) > 0.0f;
    bool _S324;
    if(_S323)
    {
        _S324 = !_S319;
    }
    else
    {
        _S324 = false;
    }
    float3  coat_series_1;
    if(_S324)
    {
        float _S325 = _S320 * _S320;
        float _S326 = _S325 * _S325;
        float _S327 = _S320 - 1.0f;
        float _S328 = _S320 + 1.0f;
        float _S329 = _S325 - 1.0f;
        float _S330 = _S325 + 1.0f;
        float _S331 = _S326 - 1.0f;
        float _S332 = _S330 * _S331;
        float _S333 = 0.5f + _S327 * (3.0f * _S320 + 1.0f) / (6.0f * _S328 * _S328) + _S325 * _S329 * _S329 / (_S330 * _S330 * _S330) * (F32_log((_S327 / _S328))) - 2.0f * _S325 * _S320 * (_S325 + 2.0f * _S320 - 1.0f) / _S332 + 8.0f * _S326 * (_S326 + 1.0f) / (_S332 * _S331) * (F32_log((_S320)));
        float _S334 = 1.0f - (1.0f - _S333) / _S325;
        float3  _S335 = material_1.coat_tint;
        float3  _S336 = _S335 * _S335 * make_float3 (1.0f - _S334) / (make_float3 (1.0f) - material_1.albedo * make_float3 (_S334));
        coat_series_1 = _S336;
    }
    else
    {
        coat_series_1 = _S322;
    }
    float3  _S337 = make_float3 (0.0f);
    float _S338 = material_1.toon.x;
    bool _S339 = _S338 < 0.0f;
    float _S340 = (F32_abs((_S338)));
    bool _S341 = _S340 > 0.0f;
    float3  toon_1;
    float toon_scale_1;
    float toon_component_1;
    float toon_a_1;
    float toon_s_1;
    float toon_b_1;
    float toon_norm_1;
    if(_S341)
    {
        float _S342 = (F32_min((_S340), (1.0f)));
        float _S343 = 1.0f - _S342;
        float _S344 = rgb_to_greyscale(material_1.albedo);
        float _S345 = _S342 * _S344;
        float3  _S346 = make_float3 (_S342) * material_1.albedo;
        float toon_a_2 = clamp_1(material_1.toon.y / _S338, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_2 = clamp_1(material_1.toon.z / _S338, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S347 = (F32_min((toon_a_2 + toon_s_2), (1.57079637050628662f)));
        if(_S339)
        {
            toon_scale_1 = 1.0f - (F32_cos(((F32_min((_S347), (toon_a_2))))));
        }
        else
        {
            float _S348 = (F32_sin(((F32_min((_S347), (toon_a_2))))));
            toon_scale_1 = _S348 * _S348 / 2.0f;
        }
        bool _S349 = _S347 > toon_a_2;
        if(_S349)
        {
            _S324 = toon_s_2 > 0.0f;
        }
        else
        {
            _S324 = false;
        }
        if(_S324)
        {
            if(_S339)
            {
                float _S350 = (F32_cos((toon_a_2)));
                float _S351 = (F32_cos((_S347)));
                toon_component_1 = (1.0f + toon_a_2 / toon_s_2) * (_S350 - _S351) - ((F32_sin((_S347))) - _S347 * _S351 - ((F32_sin((toon_a_2))) - toon_a_2 * _S350)) / toon_s_2;
            }
            else
            {
                float _S352 = 2.0f * toon_a_2;
                float _S353 = (F32_cos((_S352)));
                float _S354 = 2.0f * _S347;
                float _S355 = (F32_cos((_S354)));
                toon_component_1 = (1.0f + toon_a_2 / toon_s_2) * (_S353 - _S355) / 4.0f - ((F32_sin((_S354))) / 8.0f - _S347 * _S355 / 4.0f - ((F32_sin((_S352))) / 8.0f - toon_a_2 * _S353 / 4.0f)) / toon_s_2;
            }
            float integral_0 = toon_scale_1 + toon_component_1;
            toon_scale_1 = integral_0;
        }
        float _S356 = 6.28318548202514648f * toon_scale_1;
        toon_scale_1 = _S343;
        toon_component_1 = _S345;
        toon_1 = _S346;
        toon_a_1 = toon_a_2;
        toon_s_1 = toon_s_2;
        toon_b_1 = _S347;
        toon_norm_1 = _S356;
    }
    else
    {
        toon_scale_1 = 1.0f;
        toon_component_1 = 0.0f;
        toon_1 = _S337;
        toon_a_1 = 0.0f;
        toon_s_1 = 0.0f;
        toon_b_1 = 0.0f;
        toon_norm_1 = 1.0f;
    }
    float _S357 = translucentShare(material_1);
    return MaterialTerms_x24init_0(_S317, _S318, _S357, coat_series_1, _S319, _S321, toon_scale_1, toon_component_1, toon_1, toon_a_1, toon_s_1, toon_b_1, _S339, toon_norm_1);
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
    float3  coat_h;
    uint coat_state;
    float3  coat;
    float coat_pdf;
    float3  coat_up;
    float3  coat_through;
    float toon_view;
    float3  toon_axis;
};

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    float _S358;
    if(e_1 > 0.0f)
    {
        _S358 = 1.0f;
    }
    else
    {
        if(e_1 < 0.0f)
        {
            _S358 = -1.0f;
        }
        else
        {
            _S358 = 0.0f;
        }
    }
    return _S358;
}

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S359;
    (&_S359)->tangent = tangent_0;
    (&_S359)->alphas = alphas_0;
    return _S359;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S360 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S360)
    {
        float3  _S361 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S361;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S362 = cross_0(n_1, a_2);
    float3  _S363 = ((((_S362)) * make_float3(rnorm3df(((_S362)).x, ((_S362)).y, ((_S362)).z))));
    float3  _S364 = cross_0(n_1, _S363);
    return make_float3 (v_0.x) * _S363 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S364;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_2, float3  n_i_0)
{
    float _S365 = material_2.roughness;
    float _S366 = _S365 * _S365;
    bool _S367 = (material_2.anisotropy) == 0.0f;
    bool _S368;
    if(_S367)
    {
        _S368 = true;
    }
    else
    {
        _S368 = !(_S366 > 0.0f);
    }
    if(_S368)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S369 = material_2.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_2.tangent));
    float3  _S370 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S371 = (dot_0(_S369, _S369)) > 0.0f;
    float3  _S372 = _slang_select(_S371, _S369,_S370);
    float3  _S373 = ((((_S372)) * make_float3(rnorm3df(((_S372)).x, ((_S372)).y, ((_S372)).z))));
    float _S374 = 6.28318548202514648f * material_2.anisotropic_rotation;
    float _S375 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_2.anisotropy))))));
    float _S376 = 1.0f / _S375;
    bool _S377 = (material_2.anisotropy) < 0.0f;
    float _S378 = _slang_select(_S377, _S376,_S375);
    return AnisotropicFrame_x24init_0(_S373 * make_float3 ((F32_cos((_S374)))) + cross_0(n_i_0, _S373) * make_float3 ((F32_sin((_S374)))), make_float2 (_S366 / _S378, _S366 * _S378));
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

__device__ float3  coatNormal(BSDFMaterial material_3, float3  n_2)
{
    float3  _S379 = material_3.coat_normal;
    bool _S380 = (dot_0(_S379, _S379)) > 0.0f;
    float3  _S381 = material_3.coat_normal;
    float3  _S382 = ((((_S381)) * make_float3(rnorm3df(((_S381)).x, ((_S381)).y, ((_S381)).z))));
    float3  _S383 = _slang_select(_S380, _S382,n_2);
    float _S384 = sign_0(dot_0(_S383, n_2));
    return _S383 * make_float3 (_S384);
}

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
    float3  _S385 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S386 = ((((_S385)) * make_float3(rnorm3df(((_S385)).x, ((_S385)).y, ((_S385)).z))));
    float _S387 = _S386.x;
    float _S388 = _S386.y;
    float _S389 = _S387 * _S387 + _S388 * _S388;
    float3  _S390;
    if(_S389 > 0.0f)
    {
        float3  _S391 = make_float3 (- _S388, _S387, 0.0f);
        float _S392 = (rsqrtf((_S389)));
        _S390 = _S391 * make_float3 (_S392);
    }
    else
    {
        _S390 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S393 = cross_0(_S386, _S390);
    float _S394 = (F32_sqrt((U1_0)));
    float _S395 = 6.28318548202514648f * U2_0;
    float _S396 = _S394 * (F32_cos((_S395)));
    float t2_0 = _S394 * (F32_sin((_S395)));
    float _S397 = 0.5f * (1.0f + _S386.z);
    float t2_1 = (1.0f - _S397) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S396 * _S396)))))) + _S397 * t2_0;
    float3  _S398 = make_float3 (_S396) * _S390 + make_float3 (t2_1) * _S393;
    float _S399 = unshared_0(_S396);
    float _S400 = unshared_0(_S396);
    float3  _S401 = _S398 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S399 * _S400 - t2_1 * t2_1))))))) * _S386;
    float3  _S402 = make_float3 (alpha_0 * _S401.x, alpha_0 * _S401.y, (F32_max((0.0f), (_S401.z))));
    float3  _S403 = ((((_S402)) * make_float3(rnorm3df(((_S402)).x, ((_S402)).y, ((_S402)).z))));
    return _S403;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_4)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S404 = (F32_abs((dot_0(n_4, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S404)
    {
        float3  _S405 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S405;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S406 = cross_0(n_4, a_4);
    float3  _S407 = ((((_S406)) * make_float3(rnorm3df(((_S406)).x, ((_S406)).y, ((_S406)).z))));
    float3  _S408 = cross_0(n_4, _S407);
    return make_float3 (dot_0(v_1, _S407), dot_0(v_1, n_4), dot_0(v_1, _S408));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_2, float3  n_i_1, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S409 = pcg(*random_state_2);
    Random _S410 = pcg(_S409.state);
    *random_state_2 = _S410.state;
    float _S411 = frame_0.alphas.x;
    bool _S412 = _S411 > 0.0f;
    if(_S412)
    {
        float3  _S413 = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        float _S414 = frame_0.alphas.y;
        float3  _S415 = make_float3 (_S411 * _S413.x, _S414 * _S413.y, _S413.z);
        float3  _S416 = ((((_S415)) * make_float3(rnorm3df(((_S415)).x, ((_S415)).y, ((_S415)).z))));
        float3  _S417 = sampleGGXVNDF(_S416, 1.0f, _S409.value, _S410.value);
        float3  _S418 = make_float3 (_S411 * _S417.x, _S414 * _S417.y, _S417.z);
        float3  _S419 = ((((_S418)) * make_float3(rnorm3df(((_S418)).x, ((_S418)).y, ((_S418)).z))));
        return make_float3 (_S419.x) * frame_0.tangent + make_float3 (_S419.y) * cross_0(n_i_1, frame_0.tangent) + make_float3 (_S419.z) * n_i_1;
    }
    float3  _S420 = worldToTangent(v_2, n_i_1);
    float3  _S421 = sampleGGXVNDF(float3 {_S420.x, _S420.z, _S420.y}, alpha_1, _S409.value, _S410.value);
    float3  _S422 = float3 {_S421.x, _S421.z, _S421.y};
    float3  _S423 = tangentToWorld(_S422, n_i_1);
    return _S423;
}

static __device__ float3  reflect_0(float3  i_6, float3  n_5)
{
    return i_6 - make_float3 (2.0f * dot_0(n_5, i_6)) * n_5;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S424 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S425 = eta_i_1 / eta_o_1 * _S424;
    bool _S426 = _S425 < 1.0f;
    float kr_0;
    if(_S426)
    {
        float _S427 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S425 * _S425))))));
        float _S428 = eta_o_1 * cos_theta_0;
        float _S429 = eta_i_1 * _S427;
        float _S430 = (_S428 - _S429) / (_S428 + _S429);
        float _S431 = eta_i_1 * cos_theta_0;
        float _S432 = eta_o_1 * _S427;
        float _S433 = (_S431 - _S432) / (_S431 + _S432);
        float _S434 = (_S430 * _S430 + _S433 * _S433) / 2.0f;
        kr_0 = _S434;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

__device__ float smithG1(float alpha_2, float n_dot_x_0)
{
    float _S435 = alpha_2 * alpha_2;
    float _S436 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S435 + (1.0f - _S435) * n_dot_x_0 * n_dot_x_0))));
    bool _S437 = alpha_2 > 0.0f;
    float _S438 = _slang_select(_S437, _S436,1.0f);
    return _S438;
}

__device__ float trowbridgeReitz(float alpha_3, float n_dot_h_0)
{
    float _S439 = alpha_3 * alpha_3;
    float _S440 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S439 * n_dot_h_0 * n_dot_h_0;
    return _S439 / (F32_max((3.14159274101257324f * _S440 * _S440), (1.17549435082228751e-38f)));
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

static __device__ ViewTerms ViewTerms_x24init_0(float3  v_3, float3  n_i_2, AnisotropicFrame * frame_1, float3  scale_1, float sheen_component_0, float3  sheen_0, float3  view_0, float3  rebounce_0, float3  coat_h_0, uint coat_state_0, float3  coat_0, float coat_pdf_0, float3  coat_up_0, float3  coat_through_0, float toon_view_0, float3  toon_axis_0)
{
    ViewTerms _S441;
    (&_S441)->v = v_3;
    (&_S441)->n_i = n_i_2;
    (&_S441)->frame = *frame_1;
    (&_S441)->scale = scale_1;
    (&_S441)->sheen_component = sheen_component_0;
    (&_S441)->sheen = sheen_0;
    (&_S441)->view = view_0;
    (&_S441)->rebounce = rebounce_0;
    (&_S441)->coat_h = coat_h_0;
    (&_S441)->coat_state = coat_state_0;
    (&_S441)->coat = coat_0;
    (&_S441)->coat_pdf = coat_pdf_0;
    (&_S441)->coat_up = coat_up_0;
    (&_S441)->coat_through = coat_through_0;
    (&_S441)->toon_view = toon_view_0;
    (&_S441)->toon_axis = toon_axis_0;
    return _S441;
}

__device__ __forceinline__ ViewTerms precomputeView(float3  in_dir_0, float3  n_6, BSDFMaterial material_4, MaterialTerms terms_0, uint random_init_0, float3  h_0)
{
    float3  _S442 = negate_0(in_dir_0);
    float _S443 = sign_0(dot_0(n_6, _S442));
    float3  _S444 = n_6 * make_float3 (_S443);
    AnisotropicFrame _S445 = anisotropicFrame(material_4, _S444);
    float3  _S446 = make_float3 (1.0f);
    float3  _S447 = make_float3 (0.0f);
    float _S448 = rgb_to_greyscale(material_4.sheen);
    bool _S449 = _S448 > 0.0f;
    float sheen_component_1;
    float3  sheen_1;
    float3  view_1;
    float3  scale_2;
    if(_S449)
    {
        float _S450 = clamp_1((F32_sqrt(((F32_max((dot_0(_S444, _S442)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S451 = (U32_min((uint(_S450)), (22U)));
        float least_0 = (F32_sqrt((0.05000000074505806f)));
        float _S452 = (F32_sqrt((0.10000000149011612f)));
        bool _S453 = (material_4.velvet) > 0.0f;
        float _S454 = _slang_select(_S453, _S452,least_0);
        float _S455 = (clamp_1((F32_sqrt(((F32_max((material_4.sheen_roughness), (0.0f)))))), _S454, 1.0f) - _S454) / (1.0f - _S454) * 23.0f;
        uint _S456 = (U32_min((uint(_S455)), (22U)));
        uint _S457 = _S451 * 24U + _S456;
        float _S458 = _S450 - float(_S451);
        float _S459 = _S455 - float(_S456);
        uint _S460 = _S457 + 24U;
        float a_5 = SHEEN_ALBEDO_0[_S457] + (SHEEN_ALBEDO_0[_S460] - SHEEN_ALBEDO_0[_S457]) * _S458;
        uint _S461 = _S457 + 1U;
        uint _S462 = _S460 + 1U;
        float b_1 = SHEEN_ALBEDO_0[_S461] + (SHEEN_ALBEDO_0[_S462] - SHEEN_ALBEDO_0[_S461]) * _S458;
        float _S463 = (F32_exp((a_5 + (b_1 - a_5) * _S459)));
        if(_S453)
        {
            float a_6 = VELVET_ALBEDO_0[_S457] + (VELVET_ALBEDO_0[_S460] - VELVET_ALBEDO_0[_S457]) * _S458;
            float b_2 = VELVET_ALBEDO_0[_S461] + (VELVET_ALBEDO_0[_S462] - VELVET_ALBEDO_0[_S461]) * _S458;
            float _S464 = a_6 + (b_2 - a_6) * _S459;
            sheen_component_1 = _S464;
        }
        else
        {
            sheen_component_1 = _S463;
        }
        float _S465 = (F32_min((sheen_component_1), (1.0f)));
        float3  _S466 = make_float3 (1.0f) - material_4.sheen * make_float3 (_S465);
        float _S467 = rgb_to_greyscale(material_4.sheen);
        float _S468 = _S467 * _S465;
        float3  _S469 = material_4.sheen / make_float3 ((F32_max((sheen_component_1), (1.0f))));
        sheen_component_1 = _S468;
        sheen_1 = _S469;
        view_1 = _S442;
        scale_2 = _S466;
    }
    else
    {
        sheen_component_1 = 0.0f;
        sheen_1 = _S447;
        view_1 = _S447;
        scale_2 = _S446;
    }
    float3  scale_3 = scale_2 * make_float3 (terms_0.toon_scale);
    bool _S470 = (F32_abs((material_4.toon.x))) > 0.0f;
    float toon_view_1;
    float3  toon_axis_1;
    if(_S470)
    {
        float _S471 = dot_0(_S444, _S442);
        float _S472 = (F32_acos(((F32_min((_S471), (1.0f))))));
        if(_S472 < (terms_0.toon_a))
        {
            toon_view_1 = 1.0f;
        }
        else
        {
            toon_view_1 = (F32_max((1.0f - (_S472 - terms_0.toon_a) / (F32_max((terms_0.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        if(terms_0.toon_glossy)
        {
            float3  _S473 = make_float3 (2.0f * _S471) * _S444 - _S442;
            float3  _S474 = ((((_S473)) * make_float3(rnorm3df(((_S473)).x, ((_S473)).y, ((_S473)).z))));
            scale_2 = _S474;
        }
        else
        {
            scale_2 = _S444;
        }
        toon_axis_1 = scale_2;
    }
    else
    {
        toon_view_1 = 0.0f;
        toon_axis_1 = _S444;
    }
    float _S475 = _S445.alphas.x;
    float _S476 = (F32_sqrt(((F32_min((_S475), (_S445.alphas.y))))));
    bool _S477 = _S475 > 0.0f;
    float _S478 = _slang_select(_S477, _S476,material_4.roughness);
    float _S479 = _S478 * _S478;
    float _S480 = (F32_pow((_S479), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S479) / (1.0f + 1.28094995021820068f * _S479);
    bool _S481 = _S479 > 0.0f;
    float _S482 = _slang_select(_S481, _S480,0.0f);
    float _S483 = clamp_1(dot_0(_S444, _S442), 0.0f, 1.0f);
    float _S484 = _S479 * _S478;
    float _S485 = (F32_min((1.00064504146575928f - _S478 * (0.00375499995425344f + _S483 * (-0.04133399948477745f + _S483 * (-0.90938502550125122f + _S483 * 0.35275399684906006f))) - _S479 * (0.27602800726890564f + _S483 * (1.27023398876190186f + _S483 * 0.04740000143647194f)) - _S484 * (0.31452900171279907f - _S483 * 0.34830701351165771f) + _S484 * _S478 * 0.27229699492454529f), (1.0f)));
    float3  _S486 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_4.albedo * make_float3 (_S482)), make_float3 (1.0f / (F32_max((_S485), (0.0000152587890625f)))));
    uint coat_state_1 = random_init_0;
    float3  _S487 = coatNormal(material_4, _S444);
    bool _S488 = (material_4.coat) > 0.0f;
    bool _S489;
    if(_S488)
    {
        _S489 = (dot_0(_S487, _S442)) > 0.0f;
    }
    else
    {
        _S489 = false;
    }
    float coat_pdf_1;
    float3  coat_h_1;
    float3  coat_1;
    float3  coat_up_1;
    float3  coat_through_1;
    if(_S489)
    {
        float _S490 = material_4.coat_roughness;
        float _S491 = _S490 * _S490;
        bool _S492 = !((dot_0(h_0, h_0)) > 0.0f);
        if(_S492)
        {
            Random _S493 = pcg(random_init_0);
            Random _S494 = pcg(_S493.state);
            coat_state_1 = _S494.state;
            float3  _S495 = sampleHalfVector(_S442, _S487, _S491, AnisotropicFrame_x24init_0(_S447, make_float2 (0.0f)), &coat_state_1);
            coat_h_1 = _S495;
        }
        else
        {
            coat_h_1 = h_0;
        }
        float _S496 = dot_0(_S487, _S442);
        float _S497 = (F32_max((material_4.coat_ior), (1.00999999046325684f)));
        float _S498 = dot_0(_S487, reflect_0(in_dir_0, coat_h_1));
        float _S499 = (F32_abs((dot_0(_S442, coat_h_1))));
        float _S500 = terms_0.coat_sin;
        float _S501 = (F32_sqrt(((F32_max((1.0f - _S500 * _S500 * (1.0f - _S499 * _S499)), (0.0f))))));
        float _S502 = fresnel(_S499, 1.0f, _S497);
        float _S503 = fresnel(_S501, _S497, 1.0f);
        float _S504 = _slang_select(terms_0.coat_behind, _S503,_S502);
        float _S505 = smithG1(_S491, _S498);
        float _S506 = _S504 * _S505;
        bool _S507 = _S498 > 0.0f;
        float _S508 = _slang_select(_S507, _S506,0.0f);
        float _S509 = material_4.coat * _S508;
        float3  _S510 = material_4.coat_tint;
        float3  _S511 = _S510 * _S510;
        float3  _S512 = _slang_select(terms_0.coat_behind, _S511,_S446);
        float3  _S513 = make_float3 (_S509) * _S512;
        float _S514 = smithG1(_S491, _S496);
        float _S515 = trowbridgeReitz(_S491, dot_0(_S487, coat_h_1));
        float _S516 = _S514 * _S515 / (4.0f * _S496);
        bool _S517 = _S491 > 0.0f;
        if(_S517)
        {
            _S489 = _S496 > 0.0f;
        }
        else
        {
            _S489 = false;
        }
        float _S518 = _slang_select(_S489, _S516,0.0f);
        float _S519 = 1.0f - _S508;
        float3  _S520 = mix_0(_S446, make_float3 (_S519) * terms_0.coat_series, material_4.coat);
        float3  _S521 = mix_0(_S446, make_float3 (_S519) * material_4.coat_tint, material_4.coat);
        coat_1 = _S513;
        coat_pdf_1 = _S518;
        coat_up_1 = _S520;
        coat_through_1 = _S521;
    }
    else
    {
        coat_h_1 = _S447;
        coat_1 = _S447;
        coat_pdf_1 = 0.0f;
        coat_up_1 = _S446;
        coat_through_1 = _S446;
    }
    AnisotropicFrame _S522 = _S445;
    ViewTerms _S523 = ViewTerms_x24init_0(_S442, _S444, &_S522, scale_3, sheen_component_1, sheen_1, view_1, _S486, coat_h_1, coat_state_1, coat_1, coat_pdf_1, coat_up_1, coat_through_1, toon_view_1, toon_axis_1);
    return _S523;
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
    float3  coat;
    float p_coat;
    float coat_pdf;
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

static __device__ float3  refract_0(float3  i_7, float3  n_7, float eta_0)
{
    float _S524 = dot_0(n_7, i_7);
    float _S525 = 1.0f - eta_0 * eta_0 * (1.0f - _S524 * _S524);
    if(_S525 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_7 - make_float3 (eta_0 * _S524 + (F32_sqrt((_S525)))) * n_7;
}

__device__ float anisotropicG1(float3  w_1, float2  alphas_1)
{
    float _S526 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S526 / (_S526 + length_0(make_float3 (alphas_1.x * w_1.x, alphas_1.y * w_1.y, _S526)));
}

__device__ float anisotropicD(float3  h_1, float2  alphas_2)
{
    float _S527 = alphas_2.x;
    float _S528 = h_1.x / _S527;
    float _S529 = alphas_2.y;
    float _S530 = h_1.y / _S529;
    float _S531 = h_1.z;
    float _S532 = _S528 * _S528 + _S530 * _S530 + _S531 * _S531;
    return 1.0f / (F32_max((3.14159274101257324f * _S527 * _S529 * _S532 * _S532), (1.17549435082228751e-38f)));
}

static __device__ HalfTerms HalfTerms_x24init_0(float v_dot_h_0, float n_dot_h_1, float3  refracted_1, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_1, float3  sheen_2, float p_sheen_velvet_0, float3  view_2, float3  tangent_1, float2  alphas_3, float visible_0, float3  coat_2, float p_coat_0, float coat_pdf_2, float p_toon_0, float3  toon_2, float toon_a_3, float toon_s_3, float toon_b_2, bool toon_glossy_1, float toon_norm_2, float toon_view_2, float3  toon_axis_2)
{
    HalfTerms _S533;
    (&_S533)->v_dot_h = v_dot_h_0;
    (&_S533)->n_dot_h = n_dot_h_1;
    (&_S533)->refracted = refracted_1;
    (&_S533)->F = F_0;
    (&_S533)->F_greyscale = F_greyscale_0;
    (&_S533)->reflect_weight = reflect_weight_0;
    (&_S533)->diffuse_weight = diffuse_weight_0;
    (&_S533)->refract_weight = refract_weight_0;
    (&_S533)->p_diffuse = p_diffuse_0;
    (&_S533)->p_reflect = p_reflect_0;
    (&_S533)->p_refract = p_refract_0;
    (&_S533)->translucent_share = translucent_share_1;
    (&_S533)->sheen = sheen_2;
    (&_S533)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S533)->view = view_2;
    (&_S533)->tangent = tangent_1;
    (&_S533)->alphas = alphas_3;
    (&_S533)->visible = visible_0;
    (&_S533)->coat = coat_2;
    (&_S533)->p_coat = p_coat_0;
    (&_S533)->coat_pdf = coat_pdf_2;
    (&_S533)->p_toon = p_toon_0;
    (&_S533)->toon = toon_2;
    (&_S533)->toon_a = toon_a_3;
    (&_S533)->toon_s = toon_s_3;
    (&_S533)->toon_b = toon_b_2;
    (&_S533)->toon_glossy = toon_glossy_1;
    (&_S533)->toon_norm = toon_norm_2;
    (&_S533)->toon_view = toon_view_2;
    (&_S533)->toon_axis = toon_axis_2;
    return _S533;
}

__device__ __forceinline__ HalfTerms precomputeHalf(float3  in_dir_1, float3  ggx_n_0, BSDFMaterial material_5, float eta_i_2, float eta_o_2, MaterialTerms terms_1, ViewTerms view_terms_0)
{
    float _S534 = dot_0(ggx_n_0, view_terms_0.v);
    float _S535 = dot_0(view_terms_0.n_i, ggx_n_0);
    float _S536 = eta_i_2 / eta_o_2;
    float3  _S537 = refract_0(in_dir_1, ggx_n_0, _S536);
    float3  _S538 = ((((_S537)) * make_float3(rnorm3df(((_S537)).x, ((_S537)).y, ((_S537)).z))));
    float _S539 = (F32_abs((_S534)));
    bool _S540 = eta_i_2 > eta_o_2;
    float visible_1;
    if(_S540)
    {
        visible_1 = terms_1.eta_level;
    }
    else
    {
        visible_1 = 1.0f;
    }
    float _S541;
    if(_S540)
    {
        _S541 = 1.0f;
    }
    else
    {
        _S541 = terms_1.eta_level;
    }
    float _S542 = fresnel(_S539, visible_1, _S541);
    bool _S543 = (eta_i_2 * eta_i_2 * (1.0f - _S534 * _S534)) >= (eta_o_2 * eta_o_2);
    float3  _S544;
    if(_S543)
    {
        _S544 = make_float3 (1.0f);
    }
    else
    {
        float3  _S545 = material_5.specular_tint * make_float3 (terms_1.f0);
        _S544 = _S545 + (make_float3 (1.0f) - _S545) * make_float3 (_S542 - terms_1.f0) / make_float3 (1.0f - terms_1.f0);
    }
    float3  _S546 = view_terms_0.scale * view_terms_0.coat;
    float _S547 = rgb_to_greyscale(_S546);
    float3  _S548 = mix_0(_S544, material_5.albedo * view_terms_0.rebounce, material_5.metallic);
    float3  F_1 = _S548 * view_terms_0.scale * view_terms_0.coat_up;
    float _S549 = rgb_to_greyscale(F_1);
    float _S550 = 1.0f - material_5.metallic;
    float3  _S551 = make_float3 (1.0f) - _S544;
    float3  _S552 = make_float3 ((1.0f - material_5.transmission) * _S550) * _S551 * view_terms_0.scale * view_terms_0.coat_up;
    float3  _S553 = make_float3 (material_5.transmission * _S550) * _S551 * view_terms_0.scale * view_terms_0.coat_through;
    float _S554 = (F32_max((_S549), (0.0f)));
    float _S555 = rgb_to_greyscale(_S552);
    float _S556 = (F32_max((_S555), (0.0f)));
    float _S557 = rgb_to_greyscale(_S553);
    float _S558 = sign_0(length_0(_S538));
    float _S559 = (F32_max((_S557 * _S558), (0.0f)));
    float _S560 = _S554 + _S556 + _S559 + terms_1.toon_component + _S547;
    float _S561 = (F32_min((view_terms_0.sheen_component), (1.0f)));
    bool _S562 = (view_terms_0.sheen_component) > 0.0f;
    bool _S563;
    if(_S562)
    {
        _S563 = !(_S560 > 0.0f);
    }
    else
    {
        _S563 = false;
    }
    float _S564 = _slang_select(_S563, 1.0f,_S561);
    float _S565 = (1.0f - _S564) / (F32_max((_S560), (0.0000152587890625f)));
    float _S566 = _S556 * _S565;
    float _S567 = _S554 * _S565;
    float _S568 = _S559 * _S565;
    float _S569 = _S547 * _S565;
    bool _S570 = (view_terms_0.frame.alphas.x) > 0.0f;
    if(_S570)
    {
        float3  _S571 = anisotropicLocal(view_terms_0.v, view_terms_0.frame.tangent, view_terms_0.n_i);
        float _S572 = anisotropicG1(_S571, view_terms_0.frame.alphas);
        float3  _S573 = anisotropicLocal(ggx_n_0, view_terms_0.frame.tangent, view_terms_0.n_i);
        float _S574 = anisotropicD(_S573, view_terms_0.frame.alphas);
        float _S575 = _S572 * _S574;
        visible_1 = _S575;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return HalfTerms_x24init_0(_S534, _S535, _S538, F_1, _S549, 1.0f, _S552, _S553, _S566, _S567, _S568, terms_1.translucent_share, view_terms_0.sheen, _S564, view_terms_0.view, view_terms_0.frame.tangent, view_terms_0.frame.alphas, visible_1, _S546, _S569, view_terms_0.coat_pdf, terms_1.toon_component * _S565, terms_1.toon, terms_1.toon_a, terms_1.toon_s, terms_1.toon_b, terms_1.toon_glossy, terms_1.toon_norm, view_terms_0.toon_view, view_terms_0.toon_axis);
}

__device__ __forceinline__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, HalfTerms lobes_0, float eta_i_3, float eta_o_3, uint lobe_0)
{
    bool _S576 = lobe_0 == 0U;
    if(_S576)
    {
        float _S577 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        float _S578 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
        float _S579 = 1.0f - lobes_0.translucent_share;
        bool _S580 = n_i_dot_l_0 < 0.0f;
        float _S581 = _slang_select(_S580, lobes_0.translucent_share,_S579);
        float _S582 = _S578 * _S581;
        bool _S583 = (lobes_0.translucent_share) > 0.0f;
        float _S584 = _slang_select(_S583, _S582,_S577);
        bool _S585 = n_i_dot_v_0 > 0.0f;
        float _S586 = _slang_select(_S585, _S584,0.0f);
        return _S586;
    }
    bool _S587 = lobe_0 == 4U;
    bool _S588;
    if(_S587)
    {
        float _S589 = lobes_0.p_sheen_velvet * 0.5f * 0.31830987334251404f;
        bool _S590 = n_i_dot_l_0 > 0.0f;
        if(_S590)
        {
            _S588 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S588 = false;
        }
        float _S591 = _slang_select(_S588, _S589,0.0f);
        return _S591;
    }
    bool _S592 = lobe_0 == 6U;
    float pdf_h_0;
    if(_S592)
    {
        float _S593 = _slang_select(lobes_0.toon_glossy, l_dot_h_0,n_i_dot_l_0);
        float _S594 = (F32_acos((clamp_1(_S593, -1.0f, 1.0f))));
        if(_S594 < (lobes_0.toon_a))
        {
            pdf_h_0 = 1.0f;
        }
        else
        {
            pdf_h_0 = (F32_max((1.0f - (_S594 - lobes_0.toon_a) / (F32_max((lobes_0.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float _S595 = lobes_0.p_toon * pdf_h_0;
        float _S596 = _slang_select(lobes_0.toon_glossy, 1.0f,n_i_dot_l_0);
        float _S597 = _S595 * _S596 / lobes_0.toon_norm;
        if(lobes_0.toon_glossy)
        {
            _S588 = true;
        }
        else
        {
            _S588 = n_i_dot_l_0 > 0.0f;
        }
        float _S598 = _slang_select(_S588, _S597,0.0f);
        return _S598;
    }
    bool _S599 = lobe_0 == 5U;
    if(_S599)
    {
        return lobes_0.p_coat * lobes_0.coat_pdf;
    }
    float _S600 = smithG1(alpha_4, n_i_dot_v_0);
    float _S601 = _S600 * lobes_0.v_dot_h;
    float _S602 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    float _S603 = _S601 * _S602 / n_i_dot_v_0;
    bool _S604 = alpha_4 > 0.0f;
    if(_S604)
    {
        _S588 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S588 = false;
    }
    if(_S588)
    {
        _S588 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S588 = false;
    }
    if(_S588)
    {
        _S588 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S588 = false;
    }
    float _S605 = _slang_select(_S588, _S603,0.0f);
    bool _S606 = (lobes_0.alphas.x) > 0.0f;
    if(_S606)
    {
        float _S607 = lobes_0.visible * lobes_0.v_dot_h / n_i_dot_v_0;
        bool _S608 = (lobes_0.v_dot_h) > 0.0f;
        if(_S608)
        {
            _S588 = (lobes_0.n_dot_h) > 0.0f;
        }
        else
        {
            _S588 = false;
        }
        if(_S588)
        {
            _S588 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S588 = false;
        }
        float _S609 = _slang_select(_S588, _S607,0.0f);
        pdf_h_0 = _S609;
    }
    else
    {
        pdf_h_0 = _S605;
    }
    bool _S610 = lobe_0 == 1U;
    if(_S610)
    {
        float _S611 = eta_i_3 * lobes_0.v_dot_h + eta_o_3 * l_dot_h_0;
        float _S612 = lobes_0.p_refract * pdf_h_0 * eta_o_3 * eta_o_3 * (F32_abs((l_dot_h_0))) / (_S611 * _S611);
        bool _S613 = eta_i_3 != eta_o_3;
        if(_S613)
        {
            _S588 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S588 = false;
        }
        float _S614 = _slang_select(_S588, _S612,0.0f);
        return _S614;
    }
    float _S615 = lobes_0.p_reflect * pdf_h_0 / (4.0f * lobes_0.v_dot_h);
    bool _S616 = pdf_h_0 > 0.0f;
    float _S617 = _slang_select(_S616, _S615,0.0f);
    return _S617;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_0, uint random_state_3, bool refracted_2, uint lobe_1, float pdf_0)
{
    SampleBSDF _S618;
    (&_S618)->unit_direction = unit_direction_1;
    (&_S618)->throughput = throughput_0;
    (&_S618)->random_state = random_state_3;
    (&_S618)->refracted = refracted_2;
    (&_S618)->lobe = lobe_1;
    (&_S618)->pdf = pdf_0;
    return _S618;
}

__device__ __forceinline__ float3  lobeThroughput(float3  l_0, float3  n_i_3, float alpha_5, BSDFMaterial material_6, HalfTerms lobes_1, uint lobe_2)
{
    bool _S619 = lobe_2 == 0U;
    if(_S619)
    {
        bool _S620 = (dot_0(n_i_3, l_0)) < 0.0f;
        float3  _S621 = _slang_select(_S620, material_6.translucent,material_6.albedo);
        float _S622 = 1.0f - lobes_1.translucent_share;
        float _S623 = _slang_select(_S620, lobes_1.translucent_share,_S622);
        float3  _S624 = _S621 / make_float3 (_S623);
        bool _S625 = (lobes_1.translucent_share) > 0.0f;
        float3  _S626 = _slang_select(_S625, _S624,material_6.albedo);
        return lobes_1.diffuse_weight * _S626 / make_float3 (lobes_1.p_diffuse);
    }
    bool _S627 = lobe_2 == 4U;
    float f_1;
    if(_S627)
    {
        float3  _S628 = l_0 + lobes_1.view;
        float3  _S629 = ((((_S628)) * make_float3(rnorm3df(((_S628)).x, ((_S628)).y, ((_S628)).z))));
        float _S630 = dot_0(n_i_3, _S629);
        float _S631 = (F32_max((dot_0(n_i_3, l_0)), (0.0f)));
        float _S632 = (F32_max((dot_0(n_i_3, lobes_1.view)), (0.0f)));
        float _S633 = 1.0f / (F32_max((material_6.sheen_roughness), (0.05000000074505806f)));
        float _S634 = 1.0f - _S630 * _S630;
        float _S635 = (2.0f + _S633) * (F32_pow(((F32_max((_S634), (0.0f)))), (0.5f * _S633))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S631 + _S632 - _S631 * _S632)), (0.0000152587890625f)));
        bool _S636 = (material_6.velvet) > 0.0f;
        if(_S636)
        {
            float _S637 = (F32_max((material_6.sheen_roughness), (0.00999999977648258f)));
            float _S638 = _S637 * _S637;
            float _S639 = (F32_max((_S634), (0.0000152587890625f)));
            float _S640 = (F32_exp((- _S630 * _S630 / (_S639 * _S638)))) / (3.14159274101257324f * _S638 * _S639 * _S639) * (F32_min((1.0f), (2.0f * _S630 * (F32_min((_S631), (_S632))) / (F32_max(((F32_abs((dot_0(_S629, lobes_1.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S631 * _S632), (0.0000152587890625f)));
            f_1 = _S640;
        }
        else
        {
            f_1 = _S635;
        }
        return lobes_1.sheen * make_float3 (f_1 * _S631 * 2.0f * 3.14159274101257324f / lobes_1.p_sheen_velvet);
    }
    bool _S641 = lobe_2 == 6U;
    if(_S641)
    {
        float _S642 = (F32_max((dot_0(n_i_3, l_0)), (0.0f)));
        float _S643 = _slang_select(lobes_1.toon_glossy, _S642,lobes_1.toon_view);
        return lobes_1.toon * make_float3 (_S643) / make_float3 (lobes_1.p_toon);
    }
    bool _S644 = lobe_2 == 5U;
    if(_S644)
    {
        return lobes_1.coat / make_float3 (lobes_1.p_coat);
    }
    bool _S645 = lobe_2 == 1U;
    if(_S645)
    {
        float _S646 = - dot_0(n_i_3, l_0);
        float _S647 = smithG1(alpha_5, (F32_max((_S646), (0.0f))));
        bool _S648 = (lobes_1.alphas.x) > 0.0f;
        if(_S648)
        {
            float3  _S649 = negate_0(n_i_3);
            float3  _S650 = anisotropicLocal(l_0, lobes_1.tangent, _S649);
            float _S651 = anisotropicG1(_S650, lobes_1.alphas);
            f_1 = _S651;
        }
        else
        {
            f_1 = _S647;
        }
        return lobes_1.refract_weight * make_float3 (f_1) * material_6.albedo / make_float3 (lobes_1.p_refract);
    }
    float _S652 = dot_0(n_i_3, l_0);
    float _S653 = smithG1(alpha_5, (F32_max((_S652), (0.0f))));
    bool _S654 = (lobes_1.alphas.x) > 0.0f;
    if(_S654)
    {
        float3  _S655 = anisotropicLocal(l_0, lobes_1.tangent, n_i_3);
        float _S656 = anisotropicG1(_S655, lobes_1.alphas);
        f_1 = _S656;
    }
    else
    {
        f_1 = _S653;
    }
    return make_float3 (lobes_1.reflect_weight * f_1) * lobes_1.F / make_float3 (lobes_1.p_reflect);
}

__device__ __forceinline__ SampleBSDF lobeBSDF(float3  in_dir_2, float3  out_dir_0, float3  n_8, BSDFMaterial material_7, float eta_i_4, float eta_o_4, uint lobe_3, uint random_init_1, MaterialTerms terms_2, ViewTerms view_terms_1)
{
    uint random_state_4 = random_init_1;
    float3  _S657 = negate_0(in_dir_2);
    float _S658 = dot_0(n_8, _S657);
    float _S659 = sign_0(_S658);
    float3  _S660 = n_8 * make_float3 (_S659);
    float _S661 = material_7.roughness;
    float _S662 = _S661 * _S661;
    float3  _S663 = _S657 + out_dir_0;
    float3  ggx_n_1 = ((((_S663)) * make_float3(rnorm3df(((_S663)).x, ((_S663)).y, ((_S663)).z))));
    float _S664 = dot_0(out_dir_0, ggx_n_1);
    bool _S665 = lobe_3 == 0U;
    float3  ggx_n_2;
    if(_S665)
    {
        float3  _S666 = sampleHalfVector(_S657, _S660, _S662, view_terms_1.frame, &random_state_4);
        ggx_n_2 = _S666;
    }
    else
    {
        ggx_n_2 = ggx_n_1;
    }
    bool _S667 = lobe_3 == 1U;
    float l_dot_h_1;
    if(_S667)
    {
        float3  _S668 = negate_0(make_float3 (eta_i_4) * _S657 + make_float3 (eta_o_4) * out_dir_0);
        float3  _S669 = ((((_S668)) * make_float3(rnorm3df(((_S668)).x, ((_S668)).y, ((_S668)).z))));
        float _S670 = sign_0(dot_0(_S668, _S660));
        float3  ggx_n_3 = _S669 * make_float3 (_S670);
        float _S671 = dot_0(out_dir_0, ggx_n_3);
        ggx_n_2 = ggx_n_3;
        l_dot_h_1 = _S671;
    }
    else
    {
        l_dot_h_1 = _S664;
    }
    bool _S672 = lobe_3 == 2U;
    if(_S672)
    {
        float3  _S673 = ((((_S663)) * make_float3(rnorm3df(((_S663)).x, ((_S663)).y, ((_S663)).z))));
        ggx_n_2 = _S673;
    }
    bool _S674 = lobe_3 == 4U;
    if(_S674)
    {
        float3  _S675 = ((((_S663)) * make_float3(rnorm3df(((_S663)).x, ((_S663)).y, ((_S663)).z))));
        ggx_n_2 = _S675;
    }
    bool _S676 = lobe_3 == 6U;
    if(_S676)
    {
        float3  _S677 = sampleHalfVector(_S657, _S660, _S662, view_terms_1.frame, &random_state_4);
        float _S678 = dot_0(out_dir_0, view_terms_1.toon_axis);
        ggx_n_2 = _S677;
        l_dot_h_1 = _S678;
    }
    bool _S679 = lobe_3 == 5U;
    ViewTerms view_3;
    if(_S679)
    {
        float3  _S680 = sampleHalfVector(_S657, _S660, _S662, view_terms_1.frame, &random_state_4);
        float3  _S681 = ((((_S663)) * make_float3(rnorm3df(((_S663)).x, ((_S663)).y, ((_S663)).z))));
        ViewTerms _S682 = precomputeView(in_dir_2, n_8, material_7, terms_2, random_init_1, _S681);
        ggx_n_2 = _S680;
        view_3 = _S682;
    }
    else
    {
        float3  _S683 = view_terms_1.coat_h;
        bool _S684 = (dot_0(_S683, _S683)) > 0.0f;
        if(_S684)
        {
            random_state_4 = view_terms_1.coat_state;
        }
        view_3 = view_terms_1;
    }
    HalfTerms _S685 = precomputeHalf(in_dir_2, ggx_n_2, material_7, eta_i_4, eta_o_4, terms_2, view_3);
    float _S686 = lobeDensity(dot_0(_S660, out_dir_0), l_dot_h_1, (F32_abs((_S658))), _S662, _S685, eta_i_4, eta_o_4, lobe_3);
    bool _S687 = !(_S686 > 0.0f);
    if(_S687)
    {
        float3  _S688 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S688, _S688, 0U, false, 0U, 0.0f);
    }
    float3  _S689 = lobeThroughput(out_dir_0, _S660, _S662, material_7, _S685, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S689, random_state_4, _S667, lobe_3, _S686);
}

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_3, float3  dir_3, float3  n_9, BSDFMaterial material_8, float eta_i_5, float eta_o_5, bool refracted_3, float pdf_1, bool power_0, uint random_state_5, MaterialTerms terms_3, ViewTerms view_terms_2)
{
    float3  _S690 = make_float3 (0.0f);
    uint _S691;
    if((F32_abs((material_8.toon.x))) > 0.0f)
    {
        _S691 = 1U;
    }
    else
    {
        _S691 = 0U;
    }
    uint _S692 = 4U + _S691;
    bool _S693 = (material_8.coat) > 0.0f;
    uint i_8;
    if(_S693)
    {
        i_8 = 1U;
    }
    else
    {
        i_8 = 0U;
    }
    uint _S694 = _S692 + i_8;
    i_8 = 0U;
    float3  f_2 = _S690;
    for(;;)
    {
        if(i_8 < _S694)
        {
        }
        else
        {
            break;
        }
        uint _S695;
        bool _S696;
        if(i_8 == 3U)
        {
            _S695 = 4U;
        }
        else
        {
            bool _S697 = i_8 == 4U;
            if(_S697)
            {
                _S696 = _S691 == 1U;
            }
            else
            {
                _S696 = false;
            }
            if(_S696)
            {
                _S695 = 6U;
            }
            else
            {
                if(i_8 >= 4U)
                {
                    _S695 = 5U;
                }
                else
                {
                    _S695 = i_8;
                }
            }
        }
        bool _S698 = _S695 == 0U;
        if(_S698)
        {
        }
        if(_S698)
        {
            float _S699 = rgb_to_greyscale(material_8.translucent);
            _S696 = _S699 > 0.0f;
        }
        else
        {
            _S696 = false;
        }
        bool _S700;
        if(_S696)
        {
            float _S701 = dot_0(n_9, dir_3);
            float3  _S702 = negate_0(in_dir_3);
            _S700 = ((_S701 * dot_0(n_9, _S702)) < 0.0f) == refracted_3;
        }
        else
        {
            _S700 = (_S695 == 1U) == refracted_3;
        }
        float3  f_3;
        if(_S700)
        {
            SampleBSDF _S703 = lobeBSDF(in_dir_3, dir_3, n_9, material_8, eta_i_5, eta_o_5, _S695, random_state_5, terms_3, view_terms_2);
            bool _S704 = (_S703.pdf) > 0.0f;
            if(_S704)
            {
                if(power_0)
                {
                    float _S705 = _S703.pdf / pdf_1;
                    float3  f_4 = f_2 + _S703.throughput * make_float3 (_S703.pdf) / make_float3 (pdf_1 * (1.0f + _S705 * _S705));
                    f_3 = f_4;
                }
                else
                {
                    float3  f_5 = f_2 + _S703.throughput * make_float3 (_S703.pdf) / make_float3 (_S703.pdf + pdf_1);
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
        uint i_9 = i_8 + 1U;
        i_8 = i_9;
        f_2 = f_3;
    }
    return f_2;
}

__device__ float3  skyBSDF(float3  in_dir_4, float3  dir_4, FKSurface surface_1, float2  eta_1, bool is_inside_2, float pdf_2, uint random_state_6)
{
    bool _S706 = wrongSide_0(is_inside_2, false, dir_4, surface_1.geometry_n);
    float _S707 = eta_1.x;
    float _S708 = eta_1.y;
    MaterialTerms _S709 = precomputeMaterial(surface_1.material, _S707, _S708);
    ViewTerms _S710 = precomputeView(in_dir_4, surface_1.smooth_n, surface_1.material, _S709, random_state_6, make_float3 (0.0f));
    float3  _S711 = neeBSDF(in_dir_4, dir_4, surface_1.smooth_n, surface_1.material, _S707, _S708, _S706, pdf_2, false, random_state_6, _S709, _S710);
    return _S711;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S712;
    (&_S712)->dir = dir_5;
    (&_S712)->radiance = radiance_0;
    (&_S712)->color = color_0;
    (&_S712)->random_state = random_state_7;
    return _S712;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S713 = (fcptEnvironmentCdfSize());
    uint2  _S714 = make_uint2 (1U, 0U);
    uint2  _S715 = _S713 - _S714;
    Random _S716 = pcg(init_random_state_0);
    Random _S717 = pcg(_S716.state);
    Random _S718 = pcg(_S717.state);
    Random _S719 = pcg(_S718.state);
    uint _S720 = _S715.x;
    uint _S721 = searchCDF_0(make_uint2 (_S720, 0U), make_uint2 (0U, 1U), _S715.y, _S716.value);
    uint _S722 = searchCDF_0(make_uint2 (0U, _S721), _S714, _S720, _S717.value);
    float2  _S723 = make_float2 ((float)_S715.x, (float)_S715.y);
    float2  _S724 = (make_float2 (float(_S722), float(_S721)) + make_float2 (_S718.value, _S719.value)) / _S723 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S725 = _S724.y;
    float _S726 = (F32_sin((_S725)));
    float _S727 = _S724.x;
    float3  _S728 = make_float3 (- _S726 * (F32_cos((_S727))), _S726 * (F32_sin((_S727))), (F32_cos((_S725))));
    float _S729 = environmentPdf_0(_S728);
    float3  _S730 = skyBSDF(ray_0->unit_direction, _S728, *surface_2, eta_2, is_inside_3, _S729, lobe_state_0);
    bool _S731 = !(_S729 > 0.0f);
    bool _S732;
    if(_S731)
    {
        _S732 = true;
    }
    else
    {
        _S732 = all_1(_S730 == make_float3 (0.0f));
    }
    if(_S732)
    {
        float3  _S733 = make_float3 (0.0f);
        return SkySample_x24init_0(_S728, _S733, _S733, _S719.state);
    }
    float3  _S734 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S728, context_2, _S719.state);
    return SkySample_x24init_0(_S728, _S734, _S730 * _S734, _S719.state);
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
    SampleBSDF _S735 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_5), (light_1->dir)));
    float3  _S736 = _S735.throughput * make_float3 (_S735.pdf);
    float _S737 = light_1->density;
    float _S738 = 1.0f + _S735.pdf * _S735.pdf / (light_1->density * light_1->density);
    bool _S739;
    if(competing_0)
    {
        _S739 = _S737 > 0.0f;
    }
    else
    {
        _S739 = false;
    }
    float _S740 = _slang_select(_S739, _S738,1.0f);
    return _S736 / make_float3 (_S740) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S741;
    (&_S741)->dir = dir_6;
    (&_S741)->radiance = radiance_1;
    (&_S741)->density = density_0;
    (&_S741)->random_state = random_state_8;
    return _S741;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S742 = importance(first_1, p_12, normal_3);
    float _S743 = importance(second_1, p_12, normal_3);
    float2  _S744 = make_float2 (_S742, _S743);
    bool _S745 = _S742 == 0.0f;
    bool _S746;
    if(_S745)
    {
        _S746 = _S743 == 0.0f;
    }
    else
    {
        _S746 = false;
    }
    if(_S746)
    {
        return 2U;
    }
    float _S747 = _S742 + _S743;
    bool _S748 = _S743 > 0.0f;
    if(_S748)
    {
        _S746 = (*pick_0 * _S747) >= _S742;
    }
    else
    {
        _S746 = false;
    }
    uint _S749 = uint(_S746);
    float _S750 = (F32_min(((*pick_0 * _S747 - float(_S749) * _S742) / _slang_vector_get_element(_S744, _S749)), (0.99999994039535522f)));
    *pick_0 = _S750;
    float _S751 = *probability_3 * (_slang_vector_get_element(_S744, _S749) / _S747);
    *probability_3 = _S751;
    return _S749;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S752 = center_1 - p_13;
    float _S753 = radius_1 * radius_1 / dot_0(_S752, _S752);
    float _S754 = u1_0 * _S753 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S753), (0.0f)))))));
    float _S755 = 2.0f * u1_0;
    bool _S756 = _S753 >= 1.0f;
    float _S757 = _slang_select(_S756, _S755,_S754);
    float _S758 = (F32_sqrt(((F32_max((_S757 * (2.0f - _S757)), (0.0f))))));
    float _S759 = 6.28318548202514648f * u2_0;
    float3  _S760 = make_float3 (_S758 * (F32_cos((_S759))), 1.0f - _S757, _S758 * (F32_sin((_S759))));
    float3  _S761 = ((((_S752)) * make_float3(rnorm3df(((_S752)).x, ((_S752)).y, ((_S752)).z))));
    float3  _S762 = tangentToWorld(_S760, _S761);
    return _S762;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S763 = center_2 - ray_1->origin;
    float _S764 = dot_0(_S763, ray_1->unit_direction);
    float _S765 = dot_0(_S763, _S763) - _S764 * _S764;
    float _S766 = radius_3 * radius_3;
    bool _S767 = _S765 > _S766;
    if(_S767)
    {
        return 4.294967296e+09f;
    }
    float _S768 = (F32_sqrt((_S766 - _S765)));
    float _S769 = _S764 - _S768;
    float _S770 = _S764 + _S768;
    bool _S771 = _S769 > 0.0000152587890625f;
    bool _S772;
    if(_S771)
    {
        _S772 = _S769 < max_len_0;
    }
    else
    {
        _S772 = false;
    }
    if(_S772)
    {
        return _S769;
    }
    bool _S773 = _S770 > 0.0000152587890625f;
    if(_S773)
    {
        _S772 = _S770 < max_len_0;
    }
    else
    {
        _S772 = false;
    }
    if(_S772)
    {
        return _S770;
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
        int i_10 = int(0);
        float sum_0 = 0.0f;
        for(;;)
        {
            if(i_10 < int(3))
            {
            }
            else
            {
                break;
            }
            float sum_1 = sum_0 + _slang_vector_get_element(left_1, i_10) * _slang_vector_get_element(right_1.rows[i_10], j_1);
            i_10 = i_10 + int(1);
            sum_0 = sum_1;
        }
        *_slang_vector_get_element_ptr(&result_6, j_1) = sum_0;
        j_1 = j_1 + int(1);
    }
    return result_6;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S774 = pcg(init_random_state_1);
    Random _S775 = pcg(_S774.state);
    Random _S776 = pcg(_S775.state);
    float3  _S777 = make_float3 (0.0f);
    TreeSample _S778 = TreeSample_x24init_0(_S777, _S777, 0.0f, _S776.state);
    TreeSample sample_0 = _S778;
    float3  _S779 = _slang_select(sided_0, _S777,smooth_n_2);
    float3  _S780 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S774.value;
    float probability_4 = 1.0f;
    uint n_10 = 0U;
    for(;;)
    {
        uint4  _S781 = (fcptLightNode((n_10)));
        if((_S781.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S782 = (fcptLightSecond((n_10)));
        uint _S783 = n_10 + 1U;
        LightNode _S784 = (fcptLightBounds((_S783)));
        LightNode _S785 = (fcptLightBounds((_S782)));
        uint _S786 = pickChild(_S784, _S785, origin_4, _S779, &pick_1, &probability_4);
        bool _S787 = _S786 > 1U;
        if(_S787)
        {
            return sample_0;
        }
        bool _S788 = _S786 == 1U;
        uint _S789 = _slang_select(_S788, _S782,_S783);
        n_10 = _S789;
    }
    bool _S790 = n_10 == 0U;
    bool _S791;
    if(_S790)
    {
        LightNode _S792 = (fcptLightBounds((0U)));
        float _S793 = importance(_S792, origin_4, _S779);
        _S791 = !(_S793 > 0.0f);
    }
    else
    {
        _S791 = false;
    }
    if(_S791)
    {
        return sample_0;
    }
    uint4  _S794 = (fcptLightNode((n_10)));
    FKHit _S795 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S796 = (_S794.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S796)
    {
        FKLight _S797 = (fcptLight((_S794.y)));
        if(sided_0)
        {
            float _S798 = sign_0(dot_0(geometry_n_1, _S797.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S798);
            float3  _S799 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S799;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S780;
            lift_n_0 = smooth_n_2;
        }
        bool _S800 = (_S797.variance) == 0.0f;
        if(_S800)
        {
            float3  _S801 = _S797.position - emitter_point_0;
            float3  _S802 = ((((_S801)) * make_float3(rnorm3df(((_S801)).x, ((_S801)).y, ((_S801)).z))));
            (&sample_0)->dir = _S802;
            float3  _S803 = _S797.color * make_float3 (_S797.intensity) / make_float3 (dot_0(_S801, _S801) * probability_4);
            (&sample_0)->radiance = _S803;
            shadow_1 = _S801;
        }
        else
        {
            float3  _S804 = sampleSphere(_S797.position, _S797.variance, emitter_point_0, _S775.value, _S776.value);
            (&sample_0)->dir = _S804;
            float _S805 = sphereDensity(_S797.position, _S797.variance, emitter_point_0);
            float _S806 = probability_4 * _S805;
            (&sample_0)->density = _S806;
            float3  _S807 = pointLightRadiance(_S797.color, _S797.intensity, _S797.variance);
            float3  _S808 = _S807 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S808;
            FKRay _S809 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S810 = raySphere_0(_S797.position, _S797.variance, &_S809, 4.294967296e+09f);
            float3  _S811 = (&sample_0)->dir * make_float3 (_S810);
            shadow_1 = _S811;
        }
        emitter_0 = _S795;
        emitter_point_0 = _S777;
    }
    else
    {
        uint _S812 = _S794.y;
        uint _S813 = (fcptTriangleOffset((_S812)));
        uint _S814 = _S813 + _S794.z;
        Matrix<float, 3, 3>  _S815 = (fcptWorldTriangle((_S812), (_S814)));
        float _S816 = (F32_sqrt((_S775.value)));
        float2  _S817 = make_float2 (_S816 * (1.0f - _S776.value), _S816 * _S776.value);
        float3  _S818 = mul_0(make_float3 (1.0f - _S816, _S817.x, _S817.y), _S815);
        if(sided_0)
        {
            float _S819 = sign_0(dot_0(geometry_n_1, _S818 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S819);
            float3  _S820 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S820;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S821 = !((dot_0(smooth_n_2, _S818 - origin_4)) > 0.0f);
            if(_S821)
            {
                return sample_0;
            }
            emitter_point_0 = _S780;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S817, _S812, _S814, 0U, 0.0f);
        float3  _S822 = _S818 - emitter_point_0;
        float3  _S823 = ((((_S822)) * make_float3(rnorm3df(((_S822)).x, ((_S822)).y, ((_S822)).z))));
        (&sample_0)->dir = _S823;
        float _S824 = solidAngle(probability_4, cross_0(_S815.rows[int(1)] - _S815.rows[int(0)], _S815.rows[int(2)] - _S815.rows[int(0)]), _S822);
        (&sample_0)->density = _S824;
        bool _S825 = (fcptShadowFirst());
        bool _S826 = !_S825;
        if(_S826)
        {
            FKSurface _S827 = (fcptLightSurfaceAt((emitter_1), (_S818), (_S776.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S818 - origin_4))));
            (&sample_0)->random_state = _S827.random_state;
            float3  _S828 = _slang_select(_S827.skip, _S777,_S827.material.emissive);
            float3  _S829 = _S828 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S829;
        }
        shadow_1 = _S822;
        emitter_0 = emitter_1;
        emitter_point_0 = _S818;
    }
    FKHit _S830 = emitter_0;
    float3  _S831 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S776.state, &_S830);
    bool _S832 = (fcptShadowFirst());
    if(_S832)
    {
        _S791 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S791 = false;
    }
    if(_S791)
    {
        _S791 = !all_1(_S831 == _S777);
    }
    else
    {
        _S791 = false;
    }
    if(_S791)
    {
        FKSurface _S833 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S776.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S833.random_state;
        float3  _S834 = _slang_select(_S833.skip, _S777,_S833.material.emissive);
        float3  _S835 = _S834 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S835;
    }
    float3  _S836 = (&sample_0)->radiance * _S831;
    bool _S837 = all_1(_S831 == _S777);
    float3  _S838 = _slang_select(_S837, _S777,_S836);
    (&sample_0)->radiance = _S838;
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
    float _S839 = 1.0f / (1.0f + b_3 / a_7 * (b_3 / a_7));
    bool _S840 = b_3 > 0.0f;
    float _S841 = _slang_select(_S840, _S839,1.0f);
    return _S841;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S842 = vertex_0->none;
    if(_S842)
    {
        return 1.0f;
    }
    uint _S843 = (fcptLightSlot((*hit_1)));
    float _S844 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S843, light_point_1);
    float _S845 = powerHeuristic(vertex_0->pdf, _S844);
    return _S845;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_4)
{
    uint2  _S846 = (fcptEnvironmentMapSize());
    bool _S847 = (_S846.x) > 1U;
    bool _S848;
    if(_S847)
    {
        uint2  _S849 = (fcptEnvironmentMapSize());
        _S848 = (_S849.y) > 1U;
    }
    else
    {
        _S848 = false;
    }
    if(_S848)
    {
        float3  _S850 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_4)));
        return _S850;
    }
    float3  _S851 = (fcptAmbient());
    return _S851;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S852 = (fcptEnvironmentCdfSize());
    bool _S853 = (_S852.x) > 1U;
    bool _S854;
    if(_S853)
    {
        uint2  _S855 = (fcptEnvironmentCdfSize());
        _S854 = (_S855.y) > 1U;
    }
    else
    {
        _S854 = false;
    }
    bool _S856 = !_S854;
    if(_S856)
    {
        return false;
    }
    uint2  _S857 = (fcptEnvironmentMapSize());
    bool _S858 = (_S857.x) > 1U;
    if(_S858)
    {
        uint2  _S859 = (fcptEnvironmentMapSize());
        _S854 = (_S859.y) > 1U;
    }
    else
    {
        _S854 = false;
    }
    return _S854;
}

static __device__ float escapeWeight_0(float pdf_3, float3  dir_8)
{
    bool _S860 = pdf_3 <= 0.0f;
    bool _S861;
    if(_S860)
    {
        _S861 = true;
    }
    else
    {
        bool _S862 = environmentMapped_0();
        _S861 = !_S862;
    }
    if(_S861)
    {
        return 1.0f;
    }
    float _S863 = environmentPdf_0(dir_8);
    return pdf_3 / (pdf_3 + _S863);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S864 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S865 = make_int2 ((int)_S864.x, (int)_S864.y);
    uint _S866 = previousSeed_0(_S865);
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
            uint _S867 = previousSeed_0(_S865 + make_int2 (x_16, y_5));
            bool _S868 = _S867 == _S866;
            uint _S869 = _slang_select(_S868, 1U,0U);
            uint count_3 = count_2 + _S869;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S870 = float(count_2 - 1U) / 288.0f;
    bool _S871 = _S866 != 0U;
    float _S872 = _slang_select(_S871, _S870,0.0f);
    fcptStoreDuplication((_S865), (make_uint4 ((F32_asuint((_S872))), 0U, 0U, 0U)));
    return;
}

static __device__ float3  abs_0(float3  x_18)
{
    float3  result_7;
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
        *_slang_vector_get_element_ptr(&result_7, i_11) = (F32_abs((_slang_vector_get_element(x_18, i_11))));
        i_11 = i_11 + int(1);
    }
    return result_7;
}

__device__ float resamplingTarget(float3  f_6)
{
    float _S873 = rgb_to_greyscale(abs_0(f_6));
    return _S873;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S874 = hash(index_0);
    uint _S875 = hash(seed_3 ^ _S874);
    return _S875;
}

static __device__ float4  asfloat_0(uint4  x_19)
{
    float4  result_8;
    int i_12 = int(0);
    for(;;)
    {
        if(i_12 < int(4))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_8, i_12) = (U32_asfloat((_slang_vector_get_element(x_19, i_12))));
        i_12 = i_12 + int(1);
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
    float _S876 = resamplingTarget(weight_0);
    bool _S877 = _S876 > 0.0f;
    bool _S878;
    if(_S877)
    {
        _S878 = _S876 < 3.00000000549775576e+38f;
    }
    else
    {
        _S878 = false;
    }
    bool _S879 = !_S878;
    if(_S879)
    {
        return;
    }
    bool _S880 = sel_2->sums;
    if(_S880)
    {
        float3  _S881 = sel_2->color + weight_0;
        sel_2->color = _S881;
        return;
    }
    float _S882 = sel_2->w_sum + _S876;
    sel_2->w_sum = _S882;
    float3  _S883 = sel_2->color + weight_0;
    sel_2->color = _S883;
    Random _S884 = pcg(sel_2->random_state);
    sel_2->random_state = _S884.state;
    bool _S885 = (_S884.value * sel_2->w_sum) <= _S876;
    if(_S885)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S886 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S886;
    float _S887 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S887;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S888 = resamplingTarget((&r_4)->f);
    float _S889 = sel_4.w_sum / _S888;
    bool _S890 = _S888 > 0.0f;
    float _S891 = _slang_select(_S890, _S889,0.0f);
    (&r_4)->w = _S891;
    (&r_4)->c = c_1;
    return r_4;
}

static __device__ uint2  asuint_0(float2  x_20)
{
    uint2  result_9;
    int i_13 = int(0);
    for(;;)
    {
        if(i_13 < int(2))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_9, i_13) = (F32_asuint((_slang_vector_get_element(x_20, i_13))));
        i_13 = i_13 + int(1);
    }
    return result_9;
}

static __device__ void restir_spatial_0(uint3  global_invocation_id_2)
{
    uint2  _S892 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S893 = make_int2 ((int)_S892.x, (int)_S892.y);
    float3  _S894 = make_float3 (0.0f);
    FKHit _S895 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S896 = Domain_x24init_0(_S894, _S894, &_S895, 0.0f, 0.0f);
    Domain dom_4 = _S896;
    bool _S897 = (fcptCurrentDomain((_S893), (&dom_4)));
    bool _S898 = !_S897;
    if(_S898)
    {
        Reservoir _S899 = (Reservoir{});
        fcptStoreReservoirPrevious((_S893), (_S899), ((&dom_4)->hit));
        return;
    }
    Reservoir _S900 = (fcptLoadReservoirTemporal((_S893)));
    uint t_13 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S900.c;
    for(;;)
    {
        uint _S901 = (fcptRestirNeighbours());
        if(t_13 < _S901)
        {
        }
        else
        {
            break;
        }
        int2  _S902 = partner_0(_S893, t_13);
        Domain neighbor_0 = _S896;
        bool _S903 = (fcptCurrentDomain((_S902), (&neighbor_0)));
        if(_S903)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S904 = (fcptReservoirTemporal((_S902), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S904.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_14 = t_13 + 1U;
        t_13 = t_14;
    }
    float _S905 = _S900.c / (F32_max((count_4), (1.0f)));
    float _S906 = resamplingTarget(_S900.f);
    bool _S907 = count_4 == 0.0f;
    float _S908 = _slang_select(_S907, 1.0f,0.0f);
    Selection _S909 = (Selection{});
    Selection sel_5 = _S909;
    uint _S910 = (fcptFrame());
    uint _S911 = hash(_S910);
    uint _S912 = global_invocation_id_2.x;
    uint2  _S913 = (fcptRenderSize());
    uint _S914 = stream(_S911, _S912 + _S913.x * global_invocation_id_2.y);
    uint _S915 = stream(_S914, 195U);
    (&sel_5)->random_state = _S915;
    t_13 = 0U;
    float canonical_mis_0 = _S908;
    for(;;)
    {
        uint _S916 = (fcptRestirNeighbours());
        if(t_13 < _S916)
        {
        }
        else
        {
            break;
        }
        int2  _S917 = partner_0(_S893, t_13);
        Domain neighbor_dom_0 = _S896;
        bool _S918 = (fcptCurrentDomain((_S917), (&neighbor_dom_0)));
        if(_S918)
        {
            Reservoir _S919 = (fcptLoadReservoirTemporal((_S917)));
            uint4  _S920 = (fcptShiftData((_S917), (t_13)));
            float4  _S921 = asfloat_0(_S920);
            uint4  _S922 = (fcptShiftData((_S893), (t_13)));
            float4  _S923 = asfloat_0(_S922);
            float _S924 = pairShare(_S919.c, _S905, c_sum_1);
            bool _S925 = _S906 > 0.0f;
            float canonical_mis_1;
            if(_S925)
            {
                float _S926 = resamplingTarget(float3 {_S923.x, _S923.y, _S923.z});
                float _S927 = canonicalWeight(_S924, _S905, _S906, _S919.c, _S926);
                float canonical_mis_2 = canonical_mis_0 + _S927;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S928 = float3 {_S921.x, _S921.y, _S921.z};
            Shift _S929 = Shift_x24init_0(_S928, _S921.w);
            float _S930 = resamplingTarget(_S919.f);
            float _S931 = resamplingTarget(_S928);
            float _S932 = neighborWeight(_S924, _S919.c, _S930, _S905, _S931);
            offerShifted(&sel_5, _S919, _S929, _S932);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_15 = t_13 + 1U;
        t_13 = t_15;
    }
    offerShifted(&sel_5, _S900, Shift_x24init_0(_S900.f, 1.0f), canonical_mis_0);
    Reservoir _S933 = finalize(sel_5, c_sum_1);
    fcptStoreReservoirPrevious((_S893), (_S933), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S893), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S893), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
    return;
}

static __device__ uint3  asuint_1(float3  x_21)
{
    uint3  result_10;
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
        *_slang_vector_get_element_ptr(&result_10, i_14) = (F32_asuint((_slang_vector_get_element(x_21, i_14))));
        i_14 = i_14 + int(1);
    }
    return result_10;
}

static __device__ void restir_shift_0(uint3  workgroup_id_1, uint local_invocation_index_4)
{
    uint _S934 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S935 = _S934 != 4294967295U;
    if(_S935)
    {
        uint2  _S936 = make_uint2 (_S934, _S934 >> 14U) & make_uint2 (16383U);
        int2  _S937 = make_int2 ((int)_S936.x, (int)_S936.y);
        ShiftJob _S938 = (ShiftJob{});
        ShiftJob shift_job_0 = _S938;
        Shift _S939 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S940 = _S934 >> 28U;
        bool _S941 = spatialJob_0(_S937, _S940, &shift_job_0, true);
        Shift shifted_1;
        if(_S941)
        {
            Domain _S942 = (&shift_job_0)->dom;
            Reservoir _S943 = (&shift_job_0)->r;
            Shift _S944 = passShift_0(&_S942, &_S943);
            shifted_1 = _S944;
        }
        else
        {
            shifted_1 = _S939;
        }
        fcptStoreShiftData((_S937), (_S940), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S945 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S946 = make_int2 ((int)_S945.x, (int)_S945.y);
    FixedArray<uint, 3>  _S947;
    spatialBins_0(_S946, &_S947);
    FixedArray<uint, 3>  _S948 = _S947;
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
        bool _S949 = (_S948[t_16]) == 40U;
        if(_S949)
        {
            fcptStoreShiftData((_S946), (t_16), (make_uint4 (0U)));
        }
        uint t_17 = t_16 + 1U;
        t_16 = t_17;
    }
    FixedArray<uint, 3>  _S950 = _S948;
    queueShifts_0(_S946, &_S950, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S951 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S952 = make_int2 ((int)_S951.x, (int)_S951.y);
    FixedArray<uint, 3>  _S953;
    spatialBins_0(_S952, &_S953);
    FixedArray<uint, 3>  _S954 = _S953;
    countShifts_0(&_S954, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S955 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S956 = _S955 != 4294967295U;
    if(_S956)
    {
        uint2  _S957 = make_uint2 (_S955, _S955 >> 14U) & make_uint2 (16383U);
        int2  _S958 = make_int2 ((int)_S957.x, (int)_S957.y);
        int2  _S959 = (fcptLoadTemporalNeighbor((_S958)));
        uint _S960 = _S955 >> 28U;
        Shift _S961 = temporalShiftAt_0(_S958, _S959, _S960);
        fcptStoreTemporalShift((_S958), (_S960), (make_uint4 (asuint_1(_S961.f).x, asuint_1(_S961.f).y, asuint_1(_S961.f).z, (F32_asuint((_S961.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S962 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S963 = make_int2 ((int)_S962.x, (int)_S962.y);
    FixedArray<uint, 3>  _S964;
    temporalBins_0(_S963, &_S964);
    FixedArray<uint, 3>  _S965 = _S964;
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
        bool _S966 = (_S965[t_18]) == 40U;
        if(_S966)
        {
            fcptStoreTemporalShift((_S963), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S967 = _S965;
    queueShifts_0(_S963, &_S967, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S968 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S969 = make_int2 ((int)_S968.x, (int)_S968.y);
    bool _S970 = (fcptSceneUnchanged());
    bool _S971 = !_S970;
    bool _S972;
    if(_S971)
    {
        uint2  _S973 = (fcptRenderSize());
        int2  _S974 = make_int2 ((int)_S973.x, (int)_S973.y);
        _S972 = all_0(_S969 < _S974);
    }
    else
    {
        _S972 = false;
    }
    if(_S972)
    {
        Reservoir _S975 = (fcptLoadReservoirInitial((_S969)));
        int2  _S976 = sampleNeighbor_0(_S969, _S975.seed);
        fcptStoreTemporalNeighbor((_S969), (_S976));
    }
    FixedArray<uint, 3>  _S977;
    temporalBins_0(_S969, &_S977);
    FixedArray<uint, 3>  _S978 = _S977;
    countShifts_0(&_S978, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_8, float b_4, float t_20)
{
    return a_8 + (b_4 - a_8) * t_20;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S979 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S979;
}

__device__ float2  temporalWeights(float c_2, float p_c_1, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S980 = c_2 * p_c_1;
    float _S981 = c_t_0 * p_t_0;
    return make_float2 (_S980 / (_S980 + c_t_0 * g_previous_0), _S981 / (_S981 + c_2 * g_current_0));
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S982 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S983 = make_int2 ((int)_S982.x, (int)_S982.y);
    float3  _S984 = make_float3 (0.0f);
    FKHit _S985 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S986 = Domain_x24init_0(_S984, _S984, &_S985, 0.0f, 0.0f);
    Domain dom_5 = _S986;
    bool _S987 = (fcptCurrentDomain((_S983), (&dom_5)));
    bool _S988 = !_S987;
    if(_S988)
    {
        Reservoir _S989 = (Reservoir{});
        fcptStoreReservoirTemporal((_S983), (_S989), ((&dom_5)->hit));
        return;
    }
    Reservoir _S990 = (fcptLoadReservoirInitial((_S983)));
    bool _S991 = (fcptTemporalQueued());
    bool _S992 = (fcptSceneUnchanged());
    bool _S993;
    if(_S992)
    {
        _S993 = true;
    }
    else
    {
        _S993 = !_S991;
    }
    int2  _S994;
    if(_S993)
    {
        int2  _S995 = sampleNeighbor_0(_S983, _S990.seed);
        _S994 = _S995;
    }
    else
    {
        int2  _S996 = (fcptLoadTemporalNeighbor((_S983)));
        _S994 = _S996;
    }
    bool _S997 = (_S994.x) >= int(0);
    Reservoir r_5;
    if(_S997)
    {
        Reservoir _S998 = (fcptLoadReservoirPrevious((_S994)));
        uint4  _S999 = (fcptDuplication((_S994)));
        float _S1000 = (U32_asfloat((_S999.x)));
        uint _S1001 = (fcptRestirDecorrelation());
        bool _S1002 = _S1001 == 1U;
        float _S1003 = _slang_select(_S1002, _S1000,0.0f);
        float _S1004 = confidenceCap(_S1003);
        float _S1005 = (F32_min((_S998.c), (_S1004)));
        bool _S1006 = (fcptSceneUnchanged());
        float4  _S1007 = make_float4 (_S998.f.x, _S998.f.y, _S998.f.z, 1.0f);
        bool _S1008 = !_S1006;
        if(_S1008)
        {
            _S993 = _S991;
        }
        else
        {
            _S993 = false;
        }
        float4  to_current_0;
        if(_S993)
        {
            uint4  _S1009 = (fcptTemporalShift((_S983), (0U)));
            float4  _S1010 = asfloat_0(_S1009);
            to_current_0 = _S1010;
        }
        else
        {
            if(_S1008)
            {
                Shift _S1011 = temporalShiftAt_0(_S983, _S994, 0U);
                float4  _S1012 = make_float4 (_S1011.f.x, _S1011.f.y, _S1011.f.z, _S1011.jac);
                to_current_0 = _S1012;
            }
            else
            {
                to_current_0 = _S1007;
            }
        }
        Domain own_1 = _S986;
        if(_S1006)
        {
            _S993 = true;
        }
        else
        {
            bool _S1013 = (fcptPreviousScenes());
            bool _S1014 = !_S1013;
            if(_S1014)
            {
                _S993 = (_S990.w) > 0.0f;
            }
            else
            {
                _S993 = false;
            }
            if(_S993)
            {
                bool _S1015 = (fcptStoredDomainInitial((_S983), (_S990.seed), (&own_1)));
                _S993 = _S1015;
            }
            else
            {
                _S993 = false;
            }
            if(_S993)
            {
                Domain _S1016 = (fcptPreviousDomain((_S994), (_S990.seed)));
                Domain _S1017 = _S1016;
                Domain _S1018 = own_1;
                bool _S1019 = sameDomain_0(&_S1017, &_S1018);
                _S993 = _S1019;
            }
            else
            {
                _S993 = false;
            }
        }
        float4  _S1020 = make_float4 (_S990.f.x, _S990.f.y, _S990.f.z, 1.0f);
        bool _S1021 = !_S993;
        if(_S1021)
        {
            _S993 = _S991;
        }
        else
        {
            _S993 = false;
        }
        float4  to_previous_0;
        if(_S993)
        {
            uint4  _S1022 = (fcptTemporalShift((_S983), (1U)));
            float4  _S1023 = asfloat_0(_S1022);
            to_previous_0 = _S1023;
        }
        else
        {
            if(_S1021)
            {
                Shift _S1024 = temporalShiftAt_0(_S983, _S994, 1U);
                float4  _S1025 = make_float4 (_S1024.f.x, _S1024.f.y, _S1024.f.z, _S1024.jac);
                to_previous_0 = _S1025;
            }
            else
            {
                to_previous_0 = _S1020;
            }
        }
        float _S1026 = resamplingTarget(_S990.f);
        float _S1027 = resamplingTarget(_S998.f);
        Selection _S1028 = (Selection{});
        Selection sel_6 = _S1028;
        uint _S1029 = (fcptFrame());
        uint _S1030 = hash(_S1029);
        uint _S1031 = global_invocation_id_7.x;
        uint2  _S1032 = (fcptRenderSize());
        uint _S1033 = stream(_S1030, _S1031 + _S1032.x * global_invocation_id_7.y);
        uint _S1034 = stream(_S1033, 194U);
        (&sel_6)->random_state = _S1034;
        float4  _S1035 = to_previous_0;
        float _S1036 = resamplingTarget(float3 {_S1035.x, _S1035.y, _S1035.z});
        float4  _S1037 = to_current_0;
        float3  _S1038 = float3 {_S1037.x, _S1037.y, _S1037.z};
        float _S1039 = resamplingTarget(_S1038);
        float2  _S1040 = temporalWeights(_S990.c, _S1026, _S1005, _S1027, _S1036, _S1039);
        offerShifted(&sel_6, _S990, Shift_x24init_0(_S990.f, 1.0f), _S1040.x);
        offerShifted(&sel_6, _S998, Shift_x24init_0(_S1038, to_current_0.w), _S1040.y);
        Reservoir _S1041 = finalize(sel_6, _S990.c + _S1005);
        r_5 = _S1041;
    }
    else
    {
        r_5 = _S990;
    }
    fcptStoreReservoirTemporal((_S983), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S1042 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S1043 = make_int2 ((int)_S1042.x, (int)_S1042.y);
    float3  _S1044 = make_float3 (0.0f);
    float2  _S1045 = make_float2 (0.0f);
    FKHit _S1046 = Hit_x24init_0(_S1045, 0U, 0U, 0U, 0.0f);
    Domain _S1047 = Domain_x24init_0(_S1044, _S1044, &_S1046, 0.0f, 0.0f);
    Domain dom_6 = _S1047;
    bool _S1048 = (fcptCurrentDomain((_S1043), (&dom_6)));
    bool _S1049 = !_S1048;
    if(_S1049)
    {
        Reservoir _S1050 = (Reservoir{});
        fcptStoreReservoirInitial((_S1043), (_S1050), ((&dom_6)->hit));
        return;
    }
    uint _S1051 = (fcptFrame());
    uint _S1052 = hash(_S1051);
    uint _S1053 = global_invocation_id_8.x;
    uint2  _S1054 = (fcptRenderSize());
    uint _S1055 = stream(_S1052, _S1053 + _S1054.x * global_invocation_id_8.y);
    Selection _S1056 = (Selection{});
    Selection initial_0 = _S1056;
    uint _S1057 = stream(_S1055, 193U);
    (&initial_0)->random_state = _S1057;
    bool _S1058 = (fcptRestirUsed());
    bool _S1059 = !_S1058;
    (&initial_0)->sums = _S1059;
    uint _S1060 = stream(_S1055, 0U);
    (&(&initial_0)->r)->seed = _S1060;
    FKHit _S1061 = Hit_x24init_0(_S1045, 4294967295U, 0U, 0U, 0.0f);
    uint _S1062 = (fcptSamples());
    float _S1063 = 1.0f / float(_S1062);
    FKHit hit_2 = _S1061;
    uint i_15 = 0U;
    float3  seen_0 = _S1044;
    for(;;)
    {
        uint _S1064 = (fcptSamples());
        if(i_15 < _S1064)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1065 = (Reservoir{});
        Reservoir r_6 = _S1065;
        uint _S1066 = stream(_S1055, i_15);
        (&r_6)->seed = _S1066;
        Domain path_0 = _S1047;
        bool _S1067 = (fcptStoredDomainInitial((_S1043), ((&r_6)->seed), (&path_0)));
        bool _S1068 = !_S1067;
        if(_S1068)
        {
            float3  _S1069 = (fcptMissed((_S1043), (path_0), (_S1063)));
            float3  seen_1 = seen_0 + _S1069;
            seen_0 = seen_1;
            uint i_16 = i_15 + 1U;
            i_15 = i_16;
            continue;
        }
        Domain _S1070 = path_0;
        Reservoir _S1071 = r_6;
        Shift _S1072 = passWalk_0(&_S1070, &_S1071, false, _S1063, &initial_0);
        bool _S1073 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1073)
        {
            FKHit _S1074 = (&path_0)->hit;
            hit_3 = _S1074;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_16 = i_15 + 1U;
        i_15 = i_16;
    }
    uint _S1075 = (fcptSamples());
    float3  seen_2 = seen_0 + (&initial_0)->glow / make_float3 (float(_S1075));
    if((&initial_0)->sums)
    {
        seen_0 = seen_2 + (&initial_0)->color;
    }
    else
    {
        seen_0 = seen_2;
    }
    fcptAddColor((_S1043), (make_float4 (seen_0.x, seen_0.y, seen_0.z, 1.0f)));
    Reservoir _S1076 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S1043), (_S1076), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1077;
    (&_S1077)->none = none_0;
    (&_S1077)->pdf = pdf_4;
    (&_S1077)->origin = origin_5;
    (&_S1077)->smooth_n = smooth_n_3;
    (&_S1077)->start = start_6;
    return _S1077;
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
    Vertex _S1078;
    (&_S1078)->rough = rough_0;
    (&_S1078)->lobe = lobe_5;
    (&_S1078)->pdf = pdf_5;
    (&_S1078)->cos = cos_0;
    (&_S1078)->inside = inside_0;
    return _S1078;
}

static __device__ float freeFlight_0(float u_1, float sigma_0)
{
    return - (F32_log((1.0f - u_1))) / sigma_0;
}

static __device__ float3  exp_0(float3  x_22)
{
    float3  result_11;
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
        *_slang_vector_get_element_ptr(&result_11, i_17) = (F32_exp((_slang_vector_get_element(x_22, i_17))));
        i_17 = i_17 + int(1);
    }
    return result_11;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_1, float distance_2, bool scatters_0)
{
    float3  _S1079 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_2));
    float3  _S1080 = scatter_0 * _S1079 / make_float3 (sigma_1);
    float3  _S1081 = _slang_select(scatters_0, _S1080,_S1079);
    return _S1081;
}

static __device__ bool scatterSampled_0(bool replay_1, uint b_5, uint stop_0, bool varying_0)
{
    bool _S1082 = !replay_1;
    bool _S1083;
    if(_S1082)
    {
        _S1083 = true;
    }
    else
    {
        bool _S1084 = b_5 == stop_0;
        if(_S1084)
        {
            _S1083 = !varying_0;
        }
        else
        {
            _S1083 = false;
        }
    }
    return _S1083;
}

static __device__ uint arrivalLobe_0(uint b_6, uint prev_lobe_0)
{
    bool _S1085 = b_6 > 0U;
    uint _S1086 = _slang_select(_S1085, prev_lobe_0,3U);
    return _S1086;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_6, bool surface_4, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1087;
    (&_S1087)->extinction_behind = extinction_behind_0;
    (&_S1087)->extinction_front = extinction_front_0;
    (&_S1087)->fillings = fillings_0;
    (&_S1087)->side = side_0;
    (&_S1087)->depth = depth_1;
    (&_S1087)->lobe = lobe_6;
    (&_S1087)->surface = surface_4;
    (&_S1087)->length = length_2;
    (&_S1087)->width = width_1;
    (&_S1087)->own = *own_2;
    (&_S1087)->fiber = fiber_0;
    return _S1087;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1088 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1088)
    {
        return 0.07957746833562851f;
    }
    float _S1089 = g_0 * g_0;
    return (1.0f - _S1089) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1089 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_9, float3  b_7)
{
    float3  _S1090 = a_9 / b_7;
    float3  _S1091 = make_float3 (0.0f);
    bool3  _S1092 = b_7 == _S1091;
    float3  _S1093 = _slang_select(_S1092, _S1091,_S1090);
    return _S1093;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1094 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1094 << offset_1))) | ((newbits_0 & _S1094) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_7)
{
    Reservoir candidate_2 = r_7;
    uint _S1095 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1096 = insertBits_0(_S1095, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1096;
    (&candidate_2)->f = f_7;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_1, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S1097 = pcg(random_state_9);
    Random _S1098 = pcg(_S1097.state);
    float _S1099 = 1.0f - 2.0f * _S1097.value;
    float _S1100 = (F32_sqrt(((F32_max((1.0f - _S1099 * _S1099), (0.0f))))));
    float _S1101 = 6.28318548202514648f * _S1098.value;
    return make_float3 (_S1100 * (F32_cos((_S1101))), _S1100 * (F32_sin((_S1101))), _S1099);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_10, float * pdf_6)
{
    bool _S1102 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1102)
    {
        *pdf_6 = 0.07957746833562851f;
        float3  _S1103 = isotropic_0(random_state_10);
        return _S1103;
    }
    Random _S1104 = pcg(random_state_10);
    Random _S1105 = pcg(_S1104.state);
    float _S1106 = g_1 * g_1;
    float _S1107 = 2.0f * g_1;
    float _S1108 = (1.0f - _S1106) / (1.0f - g_1 + _S1107 * _S1104.value);
    float _S1109 = clamp_1((1.0f + _S1106 - _S1108 * _S1108) / _S1107, -1.0f, 1.0f);
    float _S1110 = (F32_sqrt(((F32_max((1.0f - _S1109 * _S1109), (0.0f))))));
    float _S1111 = 6.28318548202514648f * _S1105.value;
    float _S1112 = phaseHG_0(g_1, _S1109);
    *pdf_6 = _S1112;
    float3  _S1113 = tangentToWorld(make_float3 (_S1110 * (F32_cos((_S1111))), _S1109, _S1110 * (F32_sin((_S1111)))), dir_9);
    float3  _S1114 = ((((_S1113)) * make_float3(rnorm3df(((_S1113)).x, ((_S1113)).y, ((_S1113)).z))));
    return _S1114;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_3, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_3, float dispersion_0, float coat_3, float coat_roughness_0, float coat_ior_0, float3  coat_tint_0, float3  coat_normal_0)
{
    BSDFMaterial _S1115;
    (&_S1115)->albedo = albedo_0;
    (&_S1115)->emissive = emissive_0;
    (&_S1115)->roughness = roughness_0;
    (&_S1115)->metallic = metallic_0;
    (&_S1115)->transmission = transmission_0;
    (&_S1115)->ior = ior_0;
    (&_S1115)->absorption = absorption_0;
    (&_S1115)->specular_tint = specular_tint_0;
    (&_S1115)->specular_level = specular_level_0;
    (&_S1115)->translucent = translucent_0;
    (&_S1115)->sheen = sheen_3;
    (&_S1115)->sheen_roughness = sheen_roughness_0;
    (&_S1115)->anisotropy = anisotropy_0;
    (&_S1115)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1115)->tangent = tangent_2;
    (&_S1115)->velvet = velvet_0;
    (&_S1115)->toon = toon_3;
    (&_S1115)->dispersion = dispersion_0;
    (&_S1115)->coat = coat_3;
    (&_S1115)->coat_roughness = coat_roughness_0;
    (&_S1115)->coat_ior = coat_ior_0;
    (&_S1115)->coat_tint = coat_tint_0;
    (&_S1115)->coat_normal = coat_normal_0;
    return _S1115;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1116;
    (&_S1116)->scatter = scatter_1;
    (&_S1116)->extinction = extinction_1;
    (&_S1116)->g = g_2;
    return _S1116;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_9, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1117;
    (&_S1117)->smooth_n = smooth_n_4;
    (&_S1117)->geometry_n = geometry_n_2;
    (&_S1117)->geometry_offset = geometry_offset_2;
    (&_S1117)->material = *material_9;
    (&_S1117)->skip = skip_0;
    (&_S1117)->random_state = random_state_11;
    (&_S1117)->coverage = coverage_0;
    (&_S1117)->encloses = encloses_0;
    (&_S1117)->volume = *volume_0;
    (&_S1117)->fills = fills_0;
    (&_S1117)->hair = hair_0;
    return _S1117;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S1118 = (&surface_5->material)->emissive;
    float3  _S1119 = make_float3 (0.0f);
    bool _S1120 = !top_0;
    float3  _S1121 = _slang_select(_S1120, _S1119,_S1118);
    (&(&lower_0)->material)->emissive = _S1121;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_2)
{
    float _S1122 = surface_6->coverage;
    bool _S1123 = u_2 < _S1122;
    if(_S1123)
    {
        return *surface_6;
    }
    float3  _S1124 = make_float3 (0.0f);
    float3  _S1125 = make_float3 (1.0f);
    BSDFMaterial _S1126 = Material_x24init_0(_S1124, _S1124, 0.0f, 0.0f, 0.0f, 0.0f, _S1124, _S1125, 1.0f, _S1124, _S1124, 0.5f, 0.0f, 0.0f, _S1124, 0.0f, _S1124, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, _S1125, _S1124);
    BSDFMaterial material_10 = _S1126;
    (&material_10)->albedo = _S1125;
    (&material_10)->emissive = (&surface_6->material)->emissive;
    (&material_10)->transmission = 1.0f;
    (&material_10)->ior = 1.0f;
    (&material_10)->absorption = (&surface_6->material)->absorption;
    FKSurface through_0 = *surface_6;
    (&through_0)->material = material_10;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S1127 = transmission_1 > 0.0f;
    bool _S1128;
    if(_S1127)
    {
        _S1128 = true;
    }
    else
    {
        _S1128 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1129;
    if(_S1128)
    {
        _S1129 = 1.0f;
    }
    else
    {
        _S1129 = -1.0f;
    }
    return _S1129;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_11)
{
    return (dot_0(dir_10, n_11)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_11)
{
    float3  _S1130 = surface_7->geometry_n;
    float _S1131 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_11);
    FKSurface faced_0 = *surface_7;
    float3  _S1132 = surface_7->smooth_n * make_float3 (_S1131);
    (&faced_0)->smooth_n = _S1132;
    float3  _S1133 = _S1130 * make_float3 (_S1131);
    (&faced_0)->geometry_n = _S1133;
    return faced_0;
}

static __device__ float3  max_0(float3  x_23, float3  y_7)
{
    float3  result_12;
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
        *_slang_vector_get_element_ptr(&result_12, i_18) = (F32_max((_slang_vector_get_element(x_23, i_18)), (_slang_vector_get_element(y_7, i_18))));
        i_18 = i_18 + int(1);
    }
    return result_12;
}

static __device__ float3  log_0(float3  x_24)
{
    float3  result_13;
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
        *_slang_vector_get_element_ptr(&result_13, i_19) = (F32_log((_slang_vector_get_element(x_24, i_19))));
        i_19 = i_19 + int(1);
    }
    return result_13;
}

__device__ float3  beerLambert(float distance_3, float3  absorption_1)
{
    float3  _S1134 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1134));
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
    bool _S1135;
    if(open_0)
    {
        _S1135 = prev_rough_0;
    }
    else
    {
        _S1135 = false;
    }
    if(_S1135)
    {
        _S1135 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S1135 = false;
    }
    return _S1135;
}

__device__ bool dispersive(BSDFMaterial material_11)
{
    bool _S1136 = (material_11.dispersion) > 0.0f;
    bool _S1137;
    if(_S1136)
    {
        _S1137 = (material_11.ior) != 1.0f;
    }
    else
    {
        _S1137 = false;
    }
    return _S1137;
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
        uint _S1138 = (low_1 + high_1 + 1U) / 2U;
        bool _S1139 = (WAVELENGTH_CDF_0[_S1138]) <= u_3;
        if(_S1139)
        {
            low_1 = _S1138;
        }
        else
        {
            uint _S1140 = _S1138 - 1U;
            high_1 = _S1140;
        }
    }
    uint _S1141 = low_1;
    float _S1142 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_3 - WAVELENGTH_CDF_0[_S1141]) / _S1142), _S1142 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_0)
{
    float _S1143 = clamp_1((wavelength_0 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1144 = (U32_min((uint(_S1143)), (79U)));
    uint _S1145 = 3U * _S1144;
    float3  _S1146 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1145], WAVELENGTH_WEIGHTS_0[_S1145 + 1U], WAVELENGTH_WEIGHTS_0[_S1145 + 2U]);
    float3  _S1147 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1145 + 3U], WAVELENGTH_WEIGHTS_0[_S1145 + 4U], WAVELENGTH_WEIGHTS_0[_S1145 + 5U]);
    return _S1146 + (_S1147 - _S1146) * make_float3 (_S1143 - float(_S1144));
}

__device__ float dispersedIor(float ior_1, float dispersion_1, float wavelength_1)
{
    float _S1148 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1149 = _S1148 * (1.0f / (wavelength_1 * wavelength_1) - 2.89662933349609375f);
    bool _S1150 = dispersion_1 > 0.0f;
    float _S1151 = _slang_select(_S1150, _S1149,0.0f);
    return ior_1 + _S1151;
}

__device__ float2  vertexEta(BSDFMaterial material_12, float n_dot_v_0)
{
    bool _S1152 = n_dot_v_0 < 0.0f;
    float _S1153 = _slang_select(_S1152, material_12.ior,1.0f);
    float _S1154 = _slang_select(_S1152, 1.0f,material_12.ior);
    return make_float2 (_S1153, _S1154);
}

__device__ bool neeDecision(BSDFMaterial material_13, float n_dot_v_1, float eta_i_6, float eta_o_6)
{
    float _S1155 = fresnel((F32_abs((n_dot_v_1))), eta_i_6, eta_o_6);
    float3  _S1156 = mix_0(make_float3 (_S1155), material_13.albedo, material_13.metallic);
    float _S1157 = rgb_to_greyscale(_S1156);
    float _S1158 = (F32_max(((1.0f - _S1157) * (1.0f - material_13.metallic) * (1.0f - material_13.transmission)), (0.0f)));
    bool _S1159 = _S1158 > 0.03999999910593033f;
    bool _S1160;
    if(_S1159)
    {
        _S1160 = true;
    }
    else
    {
        _S1160 = (material_13.roughness) > 0.20000000298023224f;
    }
    return _S1160;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_14)
{
    float _S1161 = rgb_to_greyscale(material_14->translucent);
    return _S1161 > 0.0f;
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
    MediumSides _S1162;
    (&_S1162)->behind = *behind_0;
    (&_S1162)->front = *front_0;
    (&_S1162)->fillings = fillings_1;
    (&_S1162)->face = face_1;
    return _S1162;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1163 = surface_8->geometry_n;
    MediumSides _S1164 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S1164;
    bool _S1165 = surface_8->encloses;
    if(_S1165)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S1166 = (dot_0(dir_12, _S1163)) > 0.0f;
        if(_S1166)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_7, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1167 = surface_9->geometry_n;
    ShadowContext _S1168 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_2, lobe_7, true, length_3, width_2, own_3, fiber_1);
    bool _S1169 = surface_9->encloses;
    ShadowContext context_4;
    if(_S1169)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S1170 = - _S1167;
        float3  _S1171 = _slang_select(turned_0, _S1170,_S1167);
        (&faced_1)->geometry_n = _S1171;
        FKMedium _S1172 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1173 = faced_1;
        FKMedium _S1174 = _S1172;
        MediumSides _S1175 = mediumSides_0(&_S1173, &_S1174, filling_1, dir_13, outside_1);
        ShadowContext _S1176 = ShadowContext_x24init_0(_S1175.behind.extinction, _S1175.front.extinction, _S1175.fillings, _S1167, depth_2, lobe_7, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1177 = _S1175.fillings;
            ShadowContext _S1178 = ShadowContext_x24init_0(_S1175.front.extinction, _S1175.behind.extinction, uint2 {_S1177.y, _S1177.x}, _S1167, depth_2, lobe_7, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1178;
        }
        else
        {
            context_4 = _S1176;
        }
    }
    else
    {
        context_4 = _S1168;
    }
    return context_4;
}

static __device__ bool any_1(bool3  x_25)
{
    bool result_14 = false;
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
        if(result_14)
        {
            result_14 = true;
        }
        else
        {
            result_14 = (bool((_slang_vector_get_element(x_25, i_20))));
        }
        i_20 = i_20 + int(1);
    }
    return result_14;
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_6, float3  out_dir_1, float3  n_12, float3  g_n_0, BSDFMaterial material_15, float eta_i_7, float eta_o_7, uint random_state_12, MaterialTerms terms_4, ViewTerms view_terms_3)
{
    float3  _S1179 = negate_0(in_dir_6);
    bool _S1180 = (dot_0(g_n_0, _S1179) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S1180)
    {
        SampleBSDF _S1181 = lobeBSDF(in_dir_6, out_dir_1, n_12, material_15, eta_i_7, eta_o_7, 0U, random_state_12, terms_4, view_terms_3);
        SampleBSDF _S1182 = lobeBSDF(in_dir_6, out_dir_1, n_12, material_15, eta_i_7, eta_o_7, 2U, random_state_12, terms_4, view_terms_3);
        SampleBSDF _S1183 = lobeBSDF(in_dir_6, out_dir_1, n_12, material_15, eta_i_7, eta_o_7, 4U, random_state_12, terms_4, view_terms_3);
        float3  f_8 = _S1181.throughput * make_float3 (_S1181.pdf) + _S1182.throughput * make_float3 (_S1182.pdf) + _S1183.throughput * make_float3 (_S1183.pdf);
        bool _S1184 = (F32_abs((material_15.toon.x))) > 0.0f;
        float3  f_9;
        if(_S1184)
        {
            SampleBSDF _S1185 = lobeBSDF(in_dir_6, out_dir_1, n_12, material_15, eta_i_7, eta_o_7, 6U, random_state_12, terms_4, view_terms_3);
            float3  f_10 = f_8 + _S1185.throughput * make_float3 (_S1185.pdf);
            f_9 = f_10;
        }
        else
        {
            f_9 = f_8;
        }
        bool _S1186 = (material_15.coat) > 0.0f;
        if(_S1186)
        {
            SampleBSDF _S1187 = lobeBSDF(in_dir_6, out_dir_1, n_12, material_15, eta_i_7, eta_o_7, 5U, random_state_12, terms_4, view_terms_3);
            float3  f_11 = f_9 + _S1187.throughput * make_float3 (_S1187.pdf);
            f_9 = f_11;
        }
        return f_9;
    }
    SampleBSDF _S1188 = lobeBSDF(in_dir_6, out_dir_1, n_12, material_15, eta_i_7, eta_o_7, 1U, random_state_12, terms_4, view_terms_3);
    return _S1188.throughput * make_float3 (_S1188.pdf);
}

__device__ float3  translucentCorrection(float3  in_dir_7, float3  out_dir_2, float3  n_13, float3  g_n_1, BSDFMaterial material_16, float eta_i_8, float eta_o_8, uint random_state_13, MaterialTerms terms_5, ViewTerms view_terms_4)
{
    float _S1189 = dot_0(n_13, out_dir_2);
    float3  _S1190 = negate_0(in_dir_7);
    bool _S1191 = (_S1189 * dot_0(n_13, _S1190)) < 0.0f;
    SampleBSDF _S1192 = lobeBSDF(in_dir_7, out_dir_2, n_13, material_16, eta_i_8, eta_o_8, 0U, random_state_13, terms_5, view_terms_4);
    float3  _S1193 = negate_0(in_dir_7);
    bool _S1194 = (dot_0(g_n_1, _S1193) * dot_0(g_n_1, out_dir_2)) > 0.0f;
    float3  _S1195 = make_float3 (0.0f);
    float3  _S1196 = _S1192.throughput * make_float3 (_S1192.pdf);
    float _S1197 = _slang_select(_S1194, -1.0f,1.0f);
    float3  _S1198 = _S1196 * make_float3 (_S1197);
    float3  _S1199 = _slang_select(_S1191, _S1198,_S1195);
    return _S1199;
}

__device__ float3  translucentBSDF(float3  in_dir_8, float3  out_dir_3, float3  n_14, float3  g_n_2, BSDFMaterial material_17, float eta_i_9, float eta_o_9, uint random_state_14)
{
    MaterialTerms _S1200 = precomputeMaterial(material_17, eta_i_9, eta_o_9);
    ViewTerms _S1201 = precomputeView(in_dir_8, n_14, material_17, _S1200, random_state_14, make_float3 (0.0f));
    float3  _S1202 = BSDF(in_dir_8, out_dir_3, n_14, g_n_2, material_17, eta_i_9, eta_o_9, random_state_14, _S1200, _S1201);
    float3  _S1203 = translucentCorrection(in_dir_8, out_dir_3, n_14, g_n_2, material_17, eta_i_9, eta_o_9, random_state_14, _S1200, _S1201);
    return _S1202 + _S1203;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_9, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_18, float eta_i_10, float eta_o_10, bool competing_1, uint random_state_15)
{
    bool _S1204 = !competing_1;
    bool _S1205;
    if(_S1204)
    {
        _S1205 = true;
    }
    else
    {
        _S1205 = (light_2->density) == 0.0f;
    }
    if(_S1205)
    {
        bool _S1206 = isTranslucent_0(material_18);
        _S1205 = _S1206;
    }
    else
    {
        _S1205 = false;
    }
    if(_S1205)
    {
        float3  _S1207 = translucentBSDF(in_dir_9, light_2->dir, smooth_n_5, geometry_n_4, *material_18, eta_i_10, eta_o_10, random_state_15);
        return _S1207 * light_2->radiance;
    }
    MaterialTerms _S1208 = precomputeMaterial(*material_18, eta_i_10, eta_o_10);
    ViewTerms _S1209 = precomputeView(in_dir_9, smooth_n_5, *material_18, _S1208, random_state_15, make_float3 (0.0f));
    if(_S1204)
    {
        _S1205 = true;
    }
    else
    {
        _S1205 = (light_2->density) == 0.0f;
    }
    if(_S1205)
    {
        float3  _S1210 = BSDF(in_dir_9, light_2->dir, smooth_n_5, geometry_n_4, *material_18, eta_i_10, eta_o_10, random_state_15, _S1208, _S1209);
        return _S1210 * light_2->radiance;
    }
    float3  _S1211 = light_2->dir;
    bool _S1212 = (dot_0(geometry_n_4, - in_dir_9) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    float3  _S1213 = neeBSDF(in_dir_9, _S1211, smooth_n_5, *material_18, eta_i_10, eta_o_10, _S1212, light_2->density, true, random_state_15, _S1208, _S1209);
    return _S1213 * light_2->radiance * make_float3 (light_2->density);
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1214 = (F32_sqrt((random_1_0)));
    float _S1215 = 6.28318548202514648f * random_2_0;
    float _S1216 = _S1214 * (F32_cos((_S1215)));
    float _S1217 = _S1214 * (F32_sin((_S1215)));
    float _S1218 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1216 * _S1216 - _S1217 * _S1217))))));
    return make_float3 (_S1216, _S1218, _S1217);
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_15, BSDFMaterial material_19, float eta_i_11, float eta_o_11, uint random_init_2, float2  screen_space_0, MaterialTerms terms_6, ViewTerms view_terms_5)
{
    uint random_state_16 = random_init_2;
    float3  _S1219 = negate_0(in_dir_10);
    float _S1220 = dot_0(n_15, _S1219);
    float _S1221 = sign_0(_S1220);
    float3  n_i_4 = n_15 * make_float3 (_S1221);
    float _S1222 = (F32_abs((_S1220)));
    float _S1223 = material_19.roughness;
    float _S1224 = _S1223 * _S1223;
    float3  _S1225 = sampleHalfVector(_S1219, n_i_4, _S1224, view_terms_5.frame, &random_state_16);
    float3  _S1226 = view_terms_5.coat_h;
    uint _S1227;
    if((dot_0(_S1226, _S1226)) > 0.0f)
    {
        _S1227 = view_terms_5.coat_state;
    }
    else
    {
        _S1227 = random_state_16;
    }
    random_state_16 = _S1227;
    HalfTerms _S1228 = precomputeHalf(in_dir_10, _S1225, material_19, eta_i_11, eta_o_11, terms_6, view_terms_5);
    float3  _S1229 = make_float3 (1.0f);
    SampleBSDF _S1230 = SampleBSDF_x24init_0(_S1229, _S1229, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1230;
    Random _S1231 = pcg(random_state_16);
    random_state_16 = _S1231.state;
    bool _S1232 = (_S1231.value) < (_S1228.p_sheen_velvet);
    if(_S1232)
    {
        Random _S1233 = pcg(random_state_16);
        Random _S1234 = pcg(_S1233.state);
        (&sample_1)->random_state = _S1234.state;
        float _S1235 = _S1233.value;
        float _S1236 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1235 * _S1235))))));
        float _S1237 = 6.28318548202514648f * _S1234.value;
        float3  _S1238 = tangentToWorld(make_float3 (_S1236 * (F32_cos((_S1237))), _S1233.value, _S1236 * (F32_sin((_S1237)))), n_i_4);
        (&sample_1)->unit_direction = _S1238;
        float3  _S1239 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1224, material_19, _S1228, 4U);
        (&sample_1)->throughput = _S1239;
        float _S1240 = lobeDensity(_S1233.value, 0.0f, _S1222, _S1224, _S1228, eta_i_11, eta_o_11, 4U);
        (&sample_1)->pdf = _S1240;
        (&sample_1)->lobe = 4U;
        return sample_1;
    }
    float _S1241 = _S1231.value - _S1228.p_sheen_velvet;
    bool _S1242 = _S1241 < (_S1228.p_coat);
    if(_S1242)
    {
        float3  _S1243 = reflect_0(in_dir_10, view_terms_5.coat_h);
        float3  _S1244 = ((((_S1243)) * make_float3(rnorm3df(((_S1243)).x, ((_S1243)).y, ((_S1243)).z))));
        (&sample_1)->unit_direction = _S1244;
        float3  _S1245 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1224, material_19, _S1228, 5U);
        (&sample_1)->throughput = _S1245;
        float _S1246 = lobeDensity(dot_0(n_i_4, (&sample_1)->unit_direction), 0.0f, _S1222, _S1224, _S1228, eta_i_11, eta_o_11, 5U);
        (&sample_1)->pdf = _S1246;
        (&sample_1)->random_state = random_state_16;
        (&sample_1)->lobe = 5U;
        return sample_1;
    }
    float u_4 = _S1241 - _S1228.p_coat;
    bool _S1247 = u_4 < (_S1228.p_diffuse);
    if(_S1247)
    {
        Random _S1248 = pcg(random_state_16);
        Random _S1249 = pcg(_S1248.state);
        (&sample_1)->random_state = _S1249.state;
        float3  _S1250 = sampleCosWeightedHemisphere(_S1248.value, _S1249.value);
        bool _S1251 = u_4 < (_S1228.p_diffuse * _S1228.translucent_share);
        float _S1252 = _S1250.y;
        float _S1253 = - _S1252;
        float _S1254 = _slang_select(_S1251, _S1253,_S1252);
        float3  _S1255 = tangentToWorld(make_float3 (_S1250.x, _S1254, _S1250.z), n_i_4);
        (&sample_1)->unit_direction = _S1255;
        float3  _S1256 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1224, material_19, _S1228, 0U);
        (&sample_1)->throughput = _S1256;
        float _S1257 = lobeDensity(_S1254, 0.0f, _S1222, _S1224, _S1228, eta_i_11, eta_o_11, 0U);
        (&sample_1)->pdf = _S1257;
        (&sample_1)->refracted = _S1251;
        return sample_1;
    }
    bool _S1258 = u_4 < (_S1228.p_diffuse + _S1228.p_toon);
    if(_S1258)
    {
        Random _S1259 = pcg(random_state_16);
        Random _S1260 = pcg(_S1259.state);
        (&sample_1)->random_state = _S1260.state;
        float _S1261 = _S1259.value * _S1228.toon_norm / 6.28318548202514648f;
        float t_21;
        if(_S1228.toon_glossy)
        {
            t_21 = (F32_acos((clamp_1(1.0f - _S1261, -1.0f, 1.0f))));
        }
        else
        {
            t_21 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1261)))), (1.0f))))));
        }
        if(t_21 < (_S1228.toon_a))
        {
        }
        else
        {
            t_21 = (_S1228.toon_a + _S1228.toon_b) / 2.0f;
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
            float _S1262;
            if(t_21 < (_S1228.toon_a))
            {
                _S1262 = 1.0f;
            }
            else
            {
                _S1262 = (F32_max((1.0f - (t_21 - _S1228.toon_a) / (F32_max((_S1228.toon_s), (0.0000152587890625f)))), (0.0f)));
            }
            float integral_1;
            if(_S1228.toon_glossy)
            {
                integral_1 = 1.0f - (F32_cos(((F32_min((t_21), (_S1228.toon_a))))));
            }
            else
            {
                float _S1263 = (F32_sin(((F32_min((t_21), (_S1228.toon_a))))));
                integral_1 = _S1263 * _S1263 / 2.0f;
            }
            bool _S1264 = t_21 > (_S1228.toon_a);
            bool _S1265;
            if(_S1264)
            {
                _S1265 = (_S1228.toon_s) > 0.0f;
            }
            else
            {
                _S1265 = false;
            }
            float integral_2;
            if(_S1265)
            {
                if(_S1228.toon_glossy)
                {
                    float _S1266 = (F32_cos((_S1228.toon_a)));
                    float _S1267 = (F32_cos((t_21)));
                    integral_2 = (1.0f + _S1228.toon_a / _S1228.toon_s) * (_S1266 - _S1267) - ((F32_sin((t_21))) - t_21 * _S1267 - ((F32_sin((_S1228.toon_a))) - _S1228.toon_a * _S1266)) / _S1228.toon_s;
                }
                else
                {
                    float _S1268 = 2.0f * _S1228.toon_a;
                    float _S1269 = (F32_cos((_S1268)));
                    float _S1270 = 2.0f * t_21;
                    float _S1271 = (F32_cos((_S1270)));
                    integral_2 = (1.0f + _S1228.toon_a / _S1228.toon_s) * (_S1269 - _S1271) / 4.0f - ((F32_sin((_S1270))) / 8.0f - t_21 * _S1271 / 4.0f - ((F32_sin((_S1268))) / 8.0f - _S1228.toon_a * _S1269 / 4.0f)) / _S1228.toon_s;
                }
                float integral_3 = integral_1 + integral_2;
                integral_2 = integral_3;
            }
            else
            {
                integral_2 = integral_1;
            }
            float _S1272 = _S1262 * (F32_sin((t_21)));
            float _S1273;
            if(_S1228.toon_glossy)
            {
                _S1273 = 1.0f;
            }
            else
            {
                _S1273 = (F32_cos((t_21)));
            }
            float _S1274 = _S1272 * _S1273;
            float _S1275 = (integral_2 - _S1261) / _S1274;
            bool _S1276 = _S1274 > 0.0f;
            float _S1277 = _slang_select(_S1276, _S1275,0.0f);
            float _S1278 = clamp_1(t_21 - _S1277, 0.0f, _S1228.toon_b);
            int k_1 = k_0 + int(1);
            t_21 = _S1278;
            k_0 = k_1;
        }
        float _S1279 = 6.28318548202514648f * _S1260.value;
        float _S1280 = (F32_sin((t_21)));
        float3  _S1281 = tangentToWorld(make_float3 (_S1280 * (F32_cos((_S1279))), (F32_cos((t_21))), _S1280 * (F32_sin((_S1279)))), _S1228.toon_axis);
        (&sample_1)->unit_direction = _S1281;
        float3  _S1282 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1224, material_19, _S1228, 6U);
        (&sample_1)->throughput = _S1282;
        float _S1283 = lobeDensity(dot_0(n_i_4, (&sample_1)->unit_direction), dot_0((&sample_1)->unit_direction, _S1228.toon_axis), _S1222, _S1224, _S1228, eta_i_11, eta_o_11, 6U);
        (&sample_1)->pdf = _S1283;
        bool _S1284 = (dot_0(n_i_4, (&sample_1)->unit_direction)) < 0.0f;
        (&sample_1)->refracted = _S1284;
        (&sample_1)->lobe = 6U;
        return sample_1;
    }
    float u_5 = u_4 - _S1228.p_toon;
    bool _S1285 = u_5 < (_S1228.p_diffuse + _S1228.p_refract);
    if(_S1285)
    {
        (&sample_1)->unit_direction = _S1228.refracted;
        float _S1286 = lobeDensity(0.0f, dot_0((&sample_1)->unit_direction, _S1225), _S1222, _S1224, _S1228, eta_i_11, eta_o_11, 1U);
        (&sample_1)->pdf = _S1286;
        float3  _S1287 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1224, material_19, _S1228, 1U);
        (&sample_1)->throughput = _S1287;
        (&sample_1)->random_state = random_state_16;
        (&sample_1)->refracted = true;
        (&sample_1)->lobe = 1U;
        return sample_1;
    }
    float3  _S1288 = reflect_0(in_dir_10, _S1225);
    float3  _S1289 = ((((_S1288)) * make_float3(rnorm3df(((_S1288)).x, ((_S1288)).y, ((_S1288)).z))));
    (&sample_1)->unit_direction = _S1289;
    float3  _S1290 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1224, material_19, _S1228, 2U);
    (&sample_1)->throughput = _S1290;
    (&sample_1)->random_state = random_state_16;
    (&sample_1)->lobe = 2U;
    float _S1291 = lobeDensity(0.0f, 0.0f, _S1222, _S1224, _S1228, eta_i_11, eta_o_11, 2U);
    (&sample_1)->pdf = _S1291;
    return sample_1;
}

__device__ bool withinInverseFootprint(float pdf_7, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1292 = pdf_7 > 0.0f;
    bool _S1293;
    if(_S1292)
    {
        if(diffuse_0)
        {
            _S1293 = true;
        }
        else
        {
            _S1293 = (pdf_7 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1293 = false;
    }
    return _S1293;
}

__device__ bool roughLobe(float pdf_8, bool diffuse_1, float roughness_1)
{
    bool _S1294 = pdf_8 > 0.0f;
    bool _S1295;
    if(_S1294)
    {
        if(diffuse_1)
        {
            _S1295 = true;
        }
        else
        {
            _S1295 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1295 = false;
    }
    return _S1295;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1296 = layers_0 > 1U;
    bool _S1297;
    if(_S1296)
    {
        _S1297 = refracting_0 != passed_0;
    }
    else
    {
        _S1297 = false;
    }
    return _S1297;
}

static __device__ float widened_0(float spread_1, float pdf_9, bool delta_0)
{
    float _S1298 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_9))))), (3.14159274101257324f)));
    bool _S1299 = !delta_0;
    float _S1300 = _slang_select(_S1299, _S1298,0.0f);
    return spread_1 + _S1300;
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
    int _S1301;
    Shift ended_0;
    float density_3;
    float spread_3;
    float width_4;
    float sky_pdf_1;
    float spread_4;
    float width_5;
    uint b_9;
    float3  _S1302 = make_float3 (0.0f);
    Shift _S1303 = Shift_x24init_0(_S1302, 0.0f);
    uint _S1304 = r_8->path;
    uint _S1305 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1306 = extractBits_0(_S1304, 5U, 5U);
    uint _S1307 = extractBits_0(_S1304, 10U, 2U);
    uint _S1308 = extractBits_0(_S1304, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1309 = _S1308 >= 3U;
        uint _S1310 = _slang_select(_S1309, 1U,0U);
        uint _S1311 = _S1305 + _S1310;
        uint _S1312 = (fcptMaxBounces());
        passes_0 = _S1311 > _S1312;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1303;
    }
    uint _S1313 = _S1306 - 1U;
    bool _S1314 = _S1308 == 3U;
    uint _S1315 = _slang_select(_S1314, 1U,0U);
    uint _S1316 = _S1305 + _S1315;
    bool _S1317 = _S1307 == 0U;
    uint _S1318 = _slang_select(_S1317, _S1316,_S1313);
    FKHit _S1319 = (fcptReservoirHit((*r_8)));
    float3  _S1320 = dom_7->x0;
    float3  _S1321 = dom_7->x1 - dom_7->x0;
    float3  _S1322 = ((((_S1321)) * make_float3(rnorm3df(((_S1321)).x, ((_S1321)).y, ((_S1321)).z))));
    FKRay _S1323 = Ray_x24init_0(dom_7->x1, _S1322);
    FKRay ray_2 = _S1323;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1302;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1302;
    float3  extinction_in_0 = _S1302;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1324 = dom_7->spread;
    float _S1325 = dom_7->width;
    float _S1326 = length_0(_S1321);
    NEEVertex _S1327 = NEEVertex_x24init_0(true, 0.0f, _S1302, _S1302, _S1302);
    NEEVertex nee_vertex_0 = _S1327;
    Vertex _S1328 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1328;
    Reservoir _S1329 = (Reservoir{});
    Reservoir chain_0 = _S1329;
    uint _S1330 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1320;
    (&hit_4)->distance = _S1326;
    FKMedium _S1331 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1332 = filling_2;
    bool _S1333 = (fcptVaryingUsed());
    uint _S1334 = _slang_select(_S1333, _S1332,4294967295U);
    filling_2 = _S1334;
    scatter_in_0 = _S1331.scatter;
    extinction_in_0 = _S1331.extinction;
    g_in_0 = _S1331.g;
    Reservoir _S1335 = chain_0;
    uint _S1336 = filling_2;
    for(;;)
    {
        bool _S1337 = (fcptVaryingUsed());
        if(_S1337)
        {
            passes_0 = _S1336 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1338 = (fcptMajorant((_S1336)));
            spread_2 = _S1338;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1318;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1307 == 1U;
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
            ended_0 = _S1303;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1324;
            width_3 = _S1325;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_8 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1339 = (&prev_0)->rough;
        if(_S1339)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1340 = stream(_S1330, 384U);
        uint tracking_0 = _S1340;
        weight_1 = throughput_3;
        glowed_0 = _S1302;
        b_8 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_2 = _S1324;
        width_3 = _S1325;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1301 = int(1);
                break;
            }
            uint _S1341 = b_8 + 320U;
            bool _S1342 = b_8 == 4294967295U;
            uint _S1343 = _slang_select(_S1342, 384U,_S1341);
            uint _S1344 = stream(_S1330, _S1343);
            Random _S1345 = pcg(_S1344);
            float _S1346 = freeFlight_0(_S1345.value, spread_2);
            if(passes_0)
            {
                float3  _S1347 = (&ray_2)->origin;
                float3  _S1348 = (&ray_2)->unit_direction;
                float _S1349 = (&hit_4)->distance;
                uint _S1350 = _slang_select(_S1342, 0U,b_8);
                uint _S1351 = (&prev_0)->lobe;
                uint _S1352 = _slang_select(_S1342, 3U,_S1351);
                float _S1353 = (fcptTrackMedium((_S1336), (_S1347), (_S1348), (_S1349), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1350), (_S1352), (_S1342)));
                wavelength_2 = _S1353;
            }
            else
            {
                wavelength_2 = _S1346;
            }
            bool _S1354 = !(wavelength_2 < ((&hit_4)->distance));
            if(_S1354)
            {
                _S1301 = int(1);
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
                float3  _S1355 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1356 = sel_7->glow + _S1355;
                sel_7->glow = _S1356;
            }
            else
            {
            }
            glowed_0 = _S1302;
            uint b_10 = b_8 + 1U;
            float3  _S1357 = (&ray_2)->origin + make_float3 (wavelength_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1357;
            float3  _S1358 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, wavelength_2, true);
            float3  _S1359 = weight_1;
            float3  _S1360 = _slang_select(passes_0, _S1359,_S1358);
            float3  throughput_4 = throughput_2 * _S1360;
            uint _S1361 = stream(_S1330, b_10 + 320U);
            tracking_0 = _S1361;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_2 * wavelength_2;
            float _S1362 = threshold_2 + 3.14159274101257324f;
            bool _S1363 = scatterSampled_0(replay_2, b_10, _S1318, passes_0);
            TreeSample _S1364 = TreeSample_x24init_0(_S1302, _S1302, 0.0f, 0U);
            if(_S1363)
            {
                float3  _S1365 = (&ray_2)->origin;
                float3  _S1366 = (&ray_2)->unit_direction;
                float3  _S1367 = (&ray_2)->unit_direction;
                uint _S1368 = stream(_S1330, b_10 + 64U);
                float3  _S1369 = extinction_in_0;
                float3  _S1370 = extinction_in_0;
                uint2  _S1371 = make_uint2 (_S1336);
                float3  _S1372 = (&ray_2)->unit_direction;
                uint _S1373 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                FKHit _S1374 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1375 = _S1374;
                ShadowContext _S1376 = ShadowContext_x24init_0(_S1369, _S1370, _S1371, _S1372, b_10, _S1373, false, wavelength_2, width_6, &_S1375, false);
                ShadowContext _S1377 = _S1376;
                TreeSample _S1378 = sampleLightTree_0(_S1365, _S1366, _S1367, 0.0f, true, _S1368, &_S1377);
                light_3 = _S1378;
            }
            else
            {
                light_3 = _S1364;
            }
            float _S1379 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1380 = (fcptMaxBounces());
            bool _S1381 = b_10 < _S1380;
            if(_S1381)
            {
                is_inside_5 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_5 = false;
            }
            float _S1382 = _slang_select(is_inside_5, _S1379,0.0f);
            float3  _S1383 = throughput_4 * light_3.radiance;
            float _S1384 = powerHeuristic(light_3.density, _S1382);
            float3  _S1385 = _S1383 * make_float3 (_S1379 * _S1384);
            float3  _S1386 = _slang_select(_S1363, _S1385,_S1302);
            if(replay_2)
            {
                viewed_0 = b_10 == _S1318;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1387 = _S1307 == 2U;
                if(_S1387)
                {
                    float _S1388 = resamplingTarget(_S1386);
                    passes_0 = _S1388 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1389 = Shift_x24init_0(_S1386, 1.0f);
                    _S1301 = int(0);
                    ended_0 = _S1389;
                    spread_2 = _S1362;
                    wavelength_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_10;
                    break;
                }
                _S1301 = int(0);
                ended_0 = _S1303;
                spread_2 = _S1362;
                wavelength_2 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_10;
                break;
            }
            bool _S1390 = !replay_2;
            if(_S1390)
            {
                Reservoir candidate_3 = _S1335;
                uint _S1391 = extractBits_0(_S1335.path, 10U, 2U);
                bool _S1392 = _S1391 == 1U;
                if(_S1392)
                {
                    float3  _S1393 = safeDivide(_S1386, _S1302);
                    (&candidate_3)->radiance = _S1393;
                }
                else
                {
                    uint _S1394 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                    uint _S1395 = insertBits_0(_S1394, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1395;
                }
                Reservoir _S1396 = withEnd(candidate_3, 0U, b_10, _S1386);
                offer(sel_7, _S1396, _S1386 * make_float3 (scale_4) / make_float3 (density_2));
                float _S1397 = survivalProbability(abs_0(throughput_4), density_2);
                uint _S1398 = stream(_S1330, b_10 + 128U);
                Random _S1399 = pcg(_S1398);
                bool _S1400 = _S1397 < (_S1399.value);
                if(_S1400)
                {
                    scatter_2 = true;
                }
                else
                {
                    uint _S1401 = (fcptMaxBounces());
                    scatter_2 = b_10 >= _S1401;
                }
                if(scatter_2)
                {
                    _S1301 = int(0);
                    ended_0 = _S1303;
                    spread_2 = _S1362;
                    wavelength_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_10;
                    break;
                }
                float _S1402 = density_2 * _S1397;
                density_2 = _S1402;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1403 = stream(_S1330, b_10);
            float3  _S1404 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1403, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1404;
            NEEVertex _S1405 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1302, (&ray_2)->origin);
            nee_vertex_0 = _S1405;
            Vertex _S1406 = scatteredVertex_0(false);
            prev_0 = _S1406;
            float _S1407 = (&prev_0)->pdf;
            FKRay _S1408 = ray_2;
            FKHit _S1409 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1410 = (fcptTraverseInstanceBVH((_S1408), (true), (4.294967296e+09f), (false), (_S1409), (false)));
            hit_4 = _S1410;
            b_8 = b_10;
            throughput_2 = throughput_4;
            threshold_2 = _S1362;
            width_3 = width_6;
            sky_pdf_0 = _S1407;
        }
        if(_S1301 != int(1))
        {
            width_3 = wavelength_2;
            throughput_2 = chain_throughput_0;
            b_8 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1303;
        spread_2 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1411 = b_8 == 4294967295U;
    bool _S1412 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1412)
    {
        bool _S1413 = !(&nee_vertex_0)->none;
        float _S1414 = _slang_select(_S1413, sky_pdf_0,0.0f);
        float _S1415 = escapeWeight_0(_S1414, (&ray_2)->unit_direction);
        float3  _S1416 = environment_0((&ray_2)->unit_direction, b_8, (&prev_0)->lobe);
        float3  _S1417 = throughput_2 * _S1416;
        if(replay_2)
        {
            bool _S1418 = b_8 == _S1318;
            if(_S1418)
            {
                passes_0 = _S1307 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1417 * make_float3 (_S1415) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1317)
            {
                passes_0 = _S1314;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_8 == _S1305;
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
                return Shift_x24init_0(_S1417 * make_float3 (_S1415), 1.0f);
            }
            return _S1303;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1419 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1420 = _S1419 == 1U;
        if(_S1420)
        {
            uint _S1421 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1422 = _S1421 == b_8;
            float _S1423 = _slang_select(_S1422, 1.0f,_S1415);
            float3  _S1424 = safeDivide(_S1417 * make_float3 (_S1423), _S1302);
            (&candidate_4)->radiance = _S1424;
        }
        else
        {
            bool _S1425 = (&prev_0)->rough;
            if(_S1425)
            {
                uint _S1426 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                uint _S1427 = insertBits_0(_S1426, 3U, 10U, 2U);
                uint _S1428 = insertBits_0(_S1427, (&prev_0)->lobe, 15U, 3U);
                bool _S1429 = (&prev_0)->inside;
                uint _S1430 = _slang_select(_S1429, 1U,0U);
                uint _S1431 = insertBits_0(_S1428, _S1430, 22U, 1U);
                (&candidate_4)->path = _S1431;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1432 = _S1417 * make_float3 (_S1415);
        Reservoir _S1433 = withEnd(candidate_4, 3U, b_8, _S1432);
        offer(sel_7, _S1433, _S1432 * make_float3 (scale_4) / make_float3 (density_2));
        return _S1303;
    }
    float3  _S1434 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1434;
    bool _S1435 = (fcptVaryingUsed());
    if(_S1435)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1436 = !replay_2;
        if(_S1436)
        {
            float3  _S1437 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1438 = sel_7->glow + _S1437;
            sel_7->glow = _S1438;
        }
        float3  _S1439 = throughput_2 * weight_1;
        throughput_2 = _S1439;
    }
    else
    {
        float3  _S1440 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1441 = throughput_2 * _S1440;
        throughput_2 = _S1441;
    }
    float _S1442 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1443 = b_8 + 1U;
    b_8 = _S1443;
    layer_0 = 0U;
    width_3 = _S1442;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    wavelength_2 = 0.0f;
    chain_throughput_0 = _S1302;
    float3  reconnection_0 = _S1302;
    viewed_0 = _S1411;
    for(;;)
    {
        bool _S1444 = ((&hit_4)->is_point_light) == 1U;
        FKMedium _S1445 = Medium_x24init_0(_S1302, _S1302, 0.0f);
        BSDFMaterial _S1446 = Material_x24init_0(_S1302, _S1302, 0.0f, 0.0f, 0.0f, 0.0f, _S1302, throughput_3, 1.0f, _S1302, _S1302, 0.5f, 0.0f, 0.0f, _S1302, 0.0f, _S1302, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, throughput_3, _S1302);
        FKMedium _S1447 = _S1445;
        FKSurface _S1448 = Surface_x24init_0(_S1302, _S1302, 0.0f, &_S1446, false, 0U, 1.0f, false, &_S1447, 4294967295U, _S1302);
        bool _S1449 = !_S1444;
        bool is_inside_6;
        float geometry_density_2;
        float3  throughput_5;
        FKSurface surface_11;
        if(_S1449)
        {
            uint _S1450 = stream(_S1330, b_8);
            uint _S1451 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKSurface _S1452 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1450), (width_3), (layer_0), (b_8), (_S1451), ((&ray_2)->unit_direction)));
            bool _S1453 = !passes_0;
            FKSurface _S1454 = _S1452;
            FKSurface _S1455 = emitting_0(&_S1454, _S1453);
            uint _S1456 = stream(_S1330, b_8 + 256U);
            Random _S1457 = pcg(_S1456);
            FKSurface _S1458 = _S1455;
            FKSurface _S1459 = uncovered_0(&_S1458, _S1457.value);
            float _S1460 = facingSign(_S1459.material.transmission, _S1459.geometry_n, (&ray_2)->unit_direction);
            bool _S1461 = _S1460 < 0.0f;
            bool _S1462 = (_S1459.material.transmission) > 0.0f;
            if(_S1462)
            {
                bool _S1463 = arrivesBehind_0((&ray_2)->unit_direction, _S1459.geometry_n);
                scatter_2 = _S1463;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1464 = _S1459;
            FKSurface _S1465 = facingRay_0(&_S1464, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1466 = arrivesBehind_0((&ray_2)->unit_direction, _S1465.geometry_n);
                is_inside_6 = _S1466;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S1467 = beerLambert((&hit_4)->distance, _S1465.material.absorption);
                float3  _S1468 = throughput_2 * _S1467;
                throughput_5 = _S1468;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1469 = !_S1465.skip;
            float geometry_density_3 = geometryDensity(_S1465.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1470 = b_8 == _S1443;
            if(_S1470)
            {
                float _S1471 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1471;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1472 = geometry_density_2;
            scatter_2 = _S1469;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1472;
            surface_11 = _S1465;
            turned_1 = _S1461;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_11 = _S1448;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S1473 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1474 = surface_11;
        FKSurface _S1475 = surface_11;
        float _S1476 = dot_0(surface_11.smooth_n, - (&ray_2)->unit_direction);
        bool _S1477 = (fcptDispersionUsed());
        bool _S1478;
        if(_S1477)
        {
            _S1478 = wavelength_2 == 0.0f;
        }
        else
        {
            _S1478 = false;
        }
        bool _S1479;
        if(_S1478)
        {
            _S1479 = scatter_2;
        }
        else
        {
            _S1479 = false;
        }
        bool _S1480;
        if(_S1479)
        {
            bool _S1481 = dispersive(_S1474.material);
            _S1480 = _S1481;
        }
        else
        {
            _S1480 = false;
        }
        float3  throughput_6;
        if(_S1480)
        {
            uint _S1482 = stream(_S1330, 512U);
            Random _S1483 = pcg(_S1482);
            float2  _S1484 = sampleWavelength(_S1483.value);
            float _S1485 = _S1484.x;
            float3  _S1486 = wavelengthWeights(_S1485);
            float3  _S1487 = throughput_5 * (_S1486 / make_float3 (_S1484.y));
            wavelength_2 = _S1485;
            throughput_6 = _S1487;
        }
        else
        {
            throughput_6 = throughput_5;
        }
        BSDFMaterial refractive_0 = _S1474.material;
        float _S1488 = dispersedIor(_S1474.material.ior, _S1474.material.dispersion, wavelength_2);
        bool _S1489 = wavelength_2 > 0.0f;
        float _S1490 = _slang_select(_S1489, _S1488,_S1474.material.ior);
        (&refractive_0)->ior = _S1490;
        float2  _S1491 = vertexEta(refractive_0, _S1476);
        bool _S1492;
        if(scatter_2)
        {
            bool _S1493 = neeDecision(_S1474.material, _S1476, _S1491.x, _S1491.y);
            _S1492 = _S1493;
        }
        else
        {
            _S1492 = false;
        }
        bool _S1494;
        if(passes_0)
        {
            _S1494 = true;
        }
        else
        {
            _S1494 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1494)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1492;
        }
        bool _S1495 = (fcptHairUsed());
        bool _S1496;
        if(_S1495)
        {
            float3  _S1497 = surface_11.hair;
            _S1496 = (dot_0(_S1497, _S1497)) > 0.0f;
        }
        else
        {
            _S1496 = false;
        }
        bool _S1498;
        if(_S1496)
        {
            _S1498 = true;
        }
        else
        {
            BSDFMaterial _S1499 = _S1474.material;
            bool _S1500 = isTranslucent_0(&_S1499);
            _S1498 = _S1500;
        }
        bool _S1501;
        if(_S1498)
        {
            _S1501 = true;
        }
        else
        {
            bool _S1502 = (_S1474.material.transmission) > 0.0f;
            if(_S1502)
            {
                uint _S1503 = (fcptLayers((hit_4)));
                _S1501 = _S1503 == 1U;
            }
            else
            {
                _S1501 = false;
            }
        }
        float3  emission_0;
        if(_S1444)
        {
            float3  _S1504 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1504;
        }
        else
        {
            emission_0 = _S1474.material.emissive;
        }
        float _S1505 = rgb_to_greyscale(emission_0);
        bool _S1506 = _S1505 > 0.0f;
        float3  emission_1;
        if(_S1506)
        {
            NEEVertex _S1507 = nee_vertex_0;
            FKHit _S1508 = hit_4;
            float _S1509 = emissionWeight_0(&_S1507, &_S1508, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1509);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1510;
        if(replay_2)
        {
            _S1510 = _S1307 == 1U;
        }
        else
        {
            _S1510 = false;
        }
        bool _S1511;
        if(_S1510)
        {
            _S1511 = b_8 > _S1306;
        }
        else
        {
            _S1511 = false;
        }
        bool _S1512;
        if(_S1511)
        {
            _S1512 = b_8 == _S1305;
        }
        else
        {
            _S1512 = false;
        }
        bool _S1513;
        if(_S1512)
        {
            bool _S1514 = _S1308 == 1U;
            if(_S1514)
            {
                _S1513 = true;
            }
            else
            {
                _S1513 = _S1308 == 2U;
            }
        }
        else
        {
            _S1513 = false;
        }
        if(_S1513)
        {
            bool _S1515 = _S1444 != (_S1308 == 2U);
            if(_S1515)
            {
                return _S1303;
            }
            return Shift_x24init_0(throughput_6 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1516 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1517 = _S1516 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1518 = insertBits_0(0U, b_8, 5U, 5U);
        uint _S1519 = insertBits_0(_S1518, 1U, 10U, 2U);
        uint _S1520 = insertBits_0(_S1519, (&prev_0)->lobe, 15U, 3U);
        bool _S1521 = (&prev_0)->inside;
        uint _S1522 = _slang_select(_S1521, 1U,0U);
        uint _S1523 = insertBits_0(_S1520, _S1522, 22U, 1U);
        (&here_0)->path = _S1523;
        uint _S1524 = (&here_0)->path;
        uint _S1525 = _slang_select(_S1489, 1U,0U);
        uint _S1526 = insertBits_0(_S1524, _S1525, 23U, 1U);
        (&here_0)->path = _S1526;
        float _S1527 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1527;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1528;
        if(replay_2)
        {
            _S1528 = _S1307 == 1U;
        }
        else
        {
            _S1528 = false;
        }
        bool _S1529;
        if(_S1528)
        {
            _S1529 = b_8 == _S1306;
        }
        else
        {
            _S1529 = false;
        }
        bool _S1530 = b_8 == _S1318;
        bool _S1531;
        if(_S1530)
        {
            bool _S1532 = !scatter_2;
            if(_S1532)
            {
                _S1531 = true;
            }
            else
            {
                bool _S1533 = _S1307 != 1U;
                if(_S1533)
                {
                    _S1531 = _S1307 != 3U;
                }
                else
                {
                    _S1531 = false;
                }
            }
        }
        else
        {
            _S1531 = false;
        }
        bool _S1534;
        if(_S1531)
        {
            _S1534 = _S1307 == 2U;
        }
        else
        {
            _S1534 = false;
        }
        bool _S1535;
        if(_S1534)
        {
            _S1535 = !_S1473;
        }
        else
        {
            _S1535 = false;
        }
        bool _S1536;
        if(_S1535)
        {
            _S1536 = _S1308 != 4U;
        }
        else
        {
            _S1536 = false;
        }
        bool _S1537 = _S1306 == _S1305;
        bool _S1538;
        if(_S1537)
        {
            _S1538 = _S1308 == 0U;
        }
        else
        {
            _S1538 = false;
        }
        bool _S1539;
        if(_S1538)
        {
            _S1539 = ((&hit_4)->instance_index) == (_S1319.instance_index);
        }
        else
        {
            _S1539 = false;
        }
        bool _S1540;
        if(_S1539)
        {
            _S1540 = ((&hit_4)->triangle_index) == (_S1319.triangle_index);
        }
        else
        {
            _S1540 = false;
        }
        bool _S1541;
        if(_S1540)
        {
            _S1541 = _S1473;
        }
        else
        {
            _S1541 = false;
        }
        bool _S1542 = _slang_select(_S1529, _S1541,_S1536);
        bool _S1543;
        if(nee_0)
        {
            _S1543 = _slang_select(replay_2, _S1542,scatter_2);
        }
        else
        {
            _S1543 = false;
        }
        TreeSample _S1544 = TreeSample_x24init_0(_S1302, _S1302, 0.0f, 0U);
        uint2  _S1545 = make_uint2 (0U);
        float2  _S1546 = make_float2 (0.0f);
        FKHit _S1547 = Hit_x24init_0(_S1546, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1548 = _S1547;
        ShadowContext _S1549 = ShadowContext_x24init_0(_S1302, _S1302, _S1545, _S1302, 0U, 0U, false, 0.0f, 0.0f, &_S1548, false);
        ShadowContext context_5;
        if(nee_0)
        {
            uint _S1550 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKMedium _S1551 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1552 = surface_11;
            FKHit _S1553 = hit_4;
            FKMedium _S1554 = _S1551;
            ShadowContext _S1555 = shadowContext_0(&_S1552, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_8, _S1550, (&hit_4)->distance, width_3, &_S1553, _S1496, &_S1554);
            context_5 = _S1555;
        }
        else
        {
            context_5 = _S1549;
        }
        float3  throughput_7;
        float3  lit_0;
        if(_S1543)
        {
            float3  _S1556 = (&ray_2)->origin;
            if(_S1496)
            {
                throughput_7 = _S1302;
            }
            else
            {
                throughput_7 = _S1475.smooth_n;
            }
            FKSurface _S1557 = surface_11;
            uint _S1558 = stream(_S1330, b_8 + 64U);
            ShadowContext _S1559 = context_5;
            TreeSample _S1560 = sampleLightTree_0(_S1556, throughput_7, surface_11.geometry_n, surface_11.geometry_offset, _S1501, _S1558, &_S1559);
            bool _S1561 = any_1((_S1560.radiance) != _S1302);
            if(_S1561)
            {
                if(_S1496)
                {
                    uint _S1562 = (fcptMaxBounces());
                    bool _S1563 = b_8 < _S1562;
                    FKSurface _S1564 = surface_11;
                    TreeSample _S1565 = _S1560;
                    float3  _S1566 = hairLight_0(&_S1564, (&ray_2)->unit_direction, &_S1565, _S1563);
                    lit_0 = _S1566;
                }
                else
                {
                    float _S1567 = _S1491.x;
                    float _S1568 = _S1491.y;
                    uint _S1569 = (fcptMaxBounces());
                    bool _S1570 = b_8 < _S1569;
                    TreeSample _S1571 = _S1560;
                    BSDFMaterial _S1572 = _S1474.material;
                    float3  _S1573 = lightBSDF_0((&ray_2)->unit_direction, &_S1571, _S1475.smooth_n, _S1557.geometry_n, &_S1572, _S1567, _S1568, _S1570, surface_11.random_state);
                    lit_0 = _S1573;
                }
            }
            else
            {
                lit_0 = _S1302;
            }
            light_3 = _S1560;
        }
        else
        {
            light_3 = _S1544;
            lit_0 = _S1302;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1574;
        bool _S1575;
        float density_4;
        if(_S1529)
        {
            bool _S1576 = ((&hit_4)->instance_index) != (_S1319.instance_index);
            if(_S1576)
            {
                viewed_1 = true;
            }
            else
            {
                viewed_1 = ((&hit_4)->triangle_index) != (_S1319.triangle_index);
            }
            if(viewed_1)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = !_S1473;
            }
            if(refracted_4)
            {
                return _S1303;
            }
            uint _S1577 = extractBits_0(_S1304, 23U, 1U);
            bool _S1578 = _S1489 != (_S1577 == 1U);
            if(_S1578)
            {
                return _S1303;
            }
            float3  throughput_8 = throughput_6 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1537)
            {
                wrong_side_0 = _S1308 == 1U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                return Shift_x24init_0(throughput_8 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1537)
            {
                _S1574 = _S1308 == 0U;
            }
            else
            {
                _S1574 = false;
            }
            if(_S1574)
            {
                bool _S1579 = !nee_0;
                if(_S1579)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1580 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1580 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1303;
                }
                return Shift_x24init_0(throughput_8 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1537)
            {
                _S1575 = _S1308 == 4U;
            }
            else
            {
                _S1575 = false;
            }
            if(_S1575)
            {
                bool _S1581 = !nee_0;
                if(_S1581)
                {
                    return _S1303;
                }
                float _S1582 = environmentPdf_0(r_8->dir);
                float3  _S1583 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_11, _S1491, is_inside_6, _S1582, surface_11.random_state);
                return Shift_x24init_0(throughput_8 * _S1583 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1584 = extractBits_0(_S1304, 21U, 1U);
            bool _S1585 = nee_0 != (_S1584 == 1U);
            if(_S1585)
            {
                return _S1303;
            }
            throughput_7 = throughput_8;
            density_4 = density_5;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1530;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1586 = !scatter_2;
                if(_S1586)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1587 = _S1307 != 1U;
                    if(_S1587)
                    {
                        refracted_4 = _S1307 != 3U;
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
                bool _S1588 = _S1307 == 2U;
                if(_S1588)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1473;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1308 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1496)
                    {
                        return _S1303;
                    }
                    uint _S1589 = stream(_S1330, b_8 + 448U);
                    FKRay _S1590 = ray_2;
                    FKSurface _S1591 = surface_11;
                    ShadowContext _S1592 = context_5;
                    SkySample _S1593 = sampleSky_0(&_S1590, &_S1591, _S1491, is_inside_6, _S1589, surface_11.random_state, &_S1592);
                    return Shift_x24init_0(throughput_6 * _S1593.color, 1.0f);
                }
                if(_S1588)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1473;
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
                        return _S1303;
                    }
                    return Shift_x24init_0(throughput_6 * lit_0, 1.0f);
                }
                if(_S1317)
                {
                    passes_0 = _S1308 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1444;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_6 * emission_1, 1.0f);
                }
                if(_S1317)
                {
                    passes_0 = _S1308 == 1U;
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
                    passes_0 = !_S1473;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_6 * emission_1, 1.0f);
                }
                return _S1303;
            }
            else
            {
                bool _S1596 = !replay_2;
                if(_S1596)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1597 = b_8 > 0U;
                    if(_S1597)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1517)
                        {
                            float3  _S1598 = safeDivide(throughput_6 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1598;
                        }
                        else
                        {
                            if(_S1473)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1599 = throughput_6 * emission_1;
                        Reservoir _S1600 = withEnd(candidate_5, 1U, b_8, _S1599);
                        offer(sel_7, _S1600, _S1599 * make_float3 (scale_4) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1601 = throughput_6 * emission_1;
                        float3  _S1602 = sel_7->glow + _S1601;
                        sel_7->glow = _S1602;
                    }
                    if(nee_0)
                    {
                        float3  _S1603 = throughput_6 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1517)
                        {
                            float3  _S1604 = safeDivide(_S1603, chain_throughput_0);
                            (&candidate_6)->radiance = _S1604;
                        }
                        else
                        {
                            if(_S1473)
                            {
                                candidate_6 = here_0;
                                uint _S1605 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1605;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1606 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                                uint _S1607 = insertBits_0(_S1606, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1607;
                            }
                        }
                        Reservoir _S1608 = withEnd(candidate_6, 0U, b_8, _S1603);
                        offer(sel_7, _S1608, _S1603 * make_float3 (scale_4) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1496)
                        {
                            _S1574 = false;
                        }
                        else
                        {
                            bool _S1609 = environmentMapped_0();
                            _S1574 = _S1609;
                        }
                    }
                    else
                    {
                        _S1574 = false;
                    }
                    if(_S1574)
                    {
                        uint _S1610 = (fcptMaxBounces());
                        _S1575 = b_8 < _S1610;
                    }
                    else
                    {
                        _S1575 = false;
                    }
                    if(_S1575)
                    {
                        uint _S1611 = stream(_S1330, b_8 + 448U);
                        FKRay _S1612 = ray_2;
                        FKSurface _S1613 = surface_11;
                        ShadowContext _S1614 = context_5;
                        SkySample _S1615 = sampleSky_0(&_S1612, &_S1613, _S1491, is_inside_6, _S1611, surface_11.random_state, &_S1614);
                        float3  _S1616 = throughput_6 * _S1615.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1517)
                        {
                            float3  _S1617 = safeDivide(_S1616, chain_throughput_0);
                            (&candidate_7)->radiance = _S1617;
                        }
                        else
                        {
                            if(_S1473)
                            {
                                candidate_7 = here_0;
                                uint _S1618 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1618;
                                (&candidate_7)->dir = _S1615.dir;
                                (&candidate_7)->radiance = _S1615.radiance;
                            }
                            else
                            {
                                uint _S1619 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                                uint _S1620 = insertBits_0(_S1619, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1620;
                            }
                        }
                        Reservoir _S1621 = withEnd(candidate_7, 4U, b_8, _S1616);
                        offer(sel_7, _S1621, _S1616 * make_float3 (scale_4) / make_float3 (density_2));
                    }
                }
            }
            throughput_7 = throughput_6;
            density_4 = density_2;
        }
        bool _S1622;
        bool _S1623;
        bool _S1624;
        bool straight_0;
        bool _S1625;
        bool _S1626;
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
        float density_6;
        float sky_pdf_2;
        float spread_5;
        uint b_11;
        float3  throughput_9;
        float3  throughput_10;
        float3  throughput_11;
        if(scatter_2)
        {
            MaterialTerms _S1637 = MaterialTerms_x24init_0(0.0f, 0.0f, 0.0f, _S1302, false, 0.0f, 0.0f, 0.0f, _S1302, 0.0f, 0.0f, 0.0f, false, 0.0f);
            AnisotropicFrame _S1638 = AnisotropicFrame_x24init_0(_S1302, _S1546);
            ViewTerms _S1639 = ViewTerms_x24init_0(_S1302, _S1302, &_S1638, _S1302, 0.0f, _S1302, _S1302, _S1302, _S1302, 0U, _S1302, 0.0f, _S1302, _S1302, 0.0f, _S1302);
            bool _S1640 = !_S1496;
            MaterialTerms terms_7;
            ViewTerms view_terms_6;
            if(_S1640)
            {
                MaterialTerms terms_8 = precomputeMaterial(_S1474.material, _S1491.x, _S1491.y);
                ViewTerms _S1641 = precomputeView((&ray_2)->unit_direction, _S1475.smooth_n, _S1474.material, terms_8, surface_11.random_state, _S1302);
                terms_7 = terms_8;
                view_terms_6 = _S1641;
            }
            else
            {
                terms_7 = _S1637;
                view_terms_6 = _S1639;
            }
            if(replay_2)
            {
                viewed_1 = _S1530;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1642 = extractBits_0(_S1304, 15U, 3U);
            uint _S1643 = extractBits_0(_S1304, 18U, 3U);
            uint _S1644 = _slang_select(_S1529, _S1643,_S1642);
            float3  _S1645 = r_8->dir;
            bool refracted_5 = _S1644 == 1U;
            SampleBSDF _S1646 = SampleBSDF_x24init_0(_S1302, _S1302, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_8 = _S1646;
            float3  reconnection_1;
            SampleBSDF _S1647;
            if(viewed_1)
            {
                uint _S1648 = extractBits_0(_S1304, 22U, 1U);
                bool _S1649 = is_inside_6 != (_S1648 == 1U);
                if(_S1649)
                {
                    return _S1303;
                }
                bool _S1650 = _S1307 == 1U;
                if(_S1650)
                {
                    float3  _S1651 = (fcptHitPosition((_S1319)));
                    throughput_9 = _S1651;
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
                    BSDFMaterial _S1652 = _S1474.material;
                    bool _S1653 = isTranslucent_0(&_S1652);
                    if(_S1653)
                    {
                        refracted_4 = _S1644 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1654 = throughput_9 - (&ray_2)->origin;
                        float3  _S1655 = _slang_select(_S1650, _S1654,_S1645);
                        wrong_side_0 = (dot_0(_S1475.smooth_n, _S1655) * _S1476) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1650)
                {
                    float3  _S1656 = (&ray_2)->origin;
                    FKSurface _S1657 = surface_11;
                    float3  _S1658 = - _S1475.smooth_n;
                    bool _S1659 = is_inside_6 != refracted_4;
                    float3  _S1660 = _slang_select(_S1659, _S1658,_S1475.smooth_n);
                    float3  _S1661 = throughput_9 - (_S1656 + make_float3 (_S1657.geometry_offset) * _S1660);
                    float3  _S1662 = ((((_S1661)) * make_float3(rnorm3df(((_S1661)).x, ((_S1661)).y, ((_S1661)).z))));
                    reconnection_1 = _S1662;
                }
                else
                {
                    reconnection_1 = _S1645;
                }
                if(_S1496)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1663 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_11.geometry_n);
                    wrong_side_0 = _S1663;
                }
                if(wrong_side_0)
                {
                    return _S1303;
                }
                float3  _S1664 = throughput_9;
                throughput_9 = reconnection_1;
                b_11 = _S1644;
                wrong_side_0 = false;
                reconnection_1 = _S1664;
            }
            else
            {
                bool _S1665 = !_S1529;
                if(_S1665)
                {
                    SampleBSDF bsdf_sampled_0;
                    if(_S1496)
                    {
                        SampleBSDF _S1666 = (fcptSampleHair((surface_11.hair), (_S1474.material.albedo), (_S1474.material.specular_tint), ((&ray_2)->unit_direction), (surface_11.random_state)));
                        _S1647 = _S1666;
                    }
                    else
                    {
                        SampleBSDF _S1667 = sampleBSDF((&ray_2)->unit_direction, _S1475.smooth_n, _S1474.material, _S1491.x, _S1491.y, surface_11.random_state, _S1546, terms_7, view_terms_6);
                        _S1647 = _S1667;
                    }
                    bsdf_sampled_0 = _S1647;
                    if(_S1496)
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
                            return _S1303;
                        }
                        break;
                    }
                    if(_S1496)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1668 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_11.geometry_n);
                        wrong_side_0 = _S1668;
                    }
                    if(wrong_side_0)
                    {
                        _S1574 = (_S1474.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1574 = false;
                    }
                    if(_S1574)
                    {
                        float _S1669 = _S1491.x;
                        float _S1670 = _S1491.y;
                        ViewTerms _S1671 = precomputeView((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n, _S1474.material, terms_7, (&bsdf_sampled_0)->random_state, _S1302);
                        SampleBSDF _S1672 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n, _S1474.material, _S1669, _S1670, (&bsdf_sampled_0)->random_state, _S1546, terms_7, _S1671);
                        (&bsdf_sampled_0)->unit_direction = _S1672.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1672.refracted;
                        (&bsdf_sampled_0)->throughput = _S1672.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1673 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n)) * surface_11.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1673;
                        }
                    }
                    uint _S1674 = (&bsdf_sampled_0)->lobe;
                    float3  _S1675 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1676 = (&bsdf_sampled_0)->refracted;
                    lobe_8 = bsdf_sampled_0;
                    float _S1677 = (&bsdf_sampled_0)->pdf;
                    float _S1678 = _slang_select(wrong_side_0, 0.0f,_S1677);
                    (&lobe_8)->pdf = _S1678;
                    throughput_9 = _S1675;
                    b_11 = _S1674;
                    refracted_4 = _S1676;
                }
                else
                {
                    throughput_9 = _S1645;
                    b_11 = _S1644;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1574 = true;
            }
            else
            {
                _S1574 = _S1529;
            }
            if(_S1574)
            {
                if(_S1496)
                {
                    SampleBSDF _S1679 = (fcptConnectHair((surface_11.hair), (_S1474.material.albedo), (_S1474.material.specular_tint), ((&ray_2)->unit_direction), (throughput_9)));
                    _S1647 = _S1679;
                }
                else
                {
                    SampleBSDF _S1680 = lobeBSDF((&ray_2)->unit_direction, throughput_9, _S1475.smooth_n, _S1474.material, _S1491.x, _S1491.y, b_11, surface_11.random_state, terms_7, view_terms_6);
                    _S1647 = _S1680;
                }
                lobe_8 = _S1647;
            }
            bool _S1681 = b_11 == 0U;
            if(_S1681)
            {
                _S1575 = true;
            }
            else
            {
                _S1575 = b_11 == 4U;
            }
            if(_S1575)
            {
                _S1622 = true;
            }
            else
            {
                _S1622 = b_11 == 6U;
            }
            bool _S1682 = b_11 == 5U;
            float _S1683 = _slang_select(_S1682, _S1474.material.coat_roughness,_S1474.material.roughness);
            if(_S1496)
            {
                _S1623 = false;
            }
            else
            {
                bool _S1684 = !_S1622;
                if(_S1684)
                {
                    bool _S1685 = _S1683 == 0.0f;
                    if(_S1685)
                    {
                        _S1623 = true;
                    }
                    else
                    {
                        bool _S1686 = b_11 == 1U;
                        if(_S1686)
                        {
                            _S1623 = (_S1491.x) == (_S1491.y);
                        }
                        else
                        {
                            _S1623 = false;
                        }
                    }
                }
                else
                {
                    _S1623 = false;
                }
            }
            if(_S1640)
            {
                _S1624 = b_11 == 1U;
            }
            else
            {
                _S1624 = false;
            }
            if(_S1624)
            {
                straight_0 = (_S1474.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1625 = _S1640;
            }
            else
            {
                _S1625 = false;
            }
            if(_S1625)
            {
                _S1626 = b_11 == 1U;
            }
            else
            {
                _S1626 = false;
            }
            if(_S1626)
            {
                _S1627 = (_S1491.x) == (_S1491.y);
            }
            else
            {
                _S1627 = false;
            }
            BSDFMaterial _S1687 = _S1474.material;
            bool _S1688 = isTranslucent_0(&_S1687);
            if(_S1688)
            {
                _S1628 = _S1681;
            }
            else
            {
                _S1628 = false;
            }
            if(_S1628)
            {
                _S1629 = (dot_0(throughput_9, surface_11.geometry_n)) < 0.0f;
            }
            else
            {
                _S1629 = false;
            }
            if(nee_0)
            {
                _S1630 = !_S1623;
            }
            else
            {
                _S1630 = false;
            }
            if(_S1630)
            {
                _S1631 = !wrong_side_0;
            }
            else
            {
                _S1631 = false;
            }
            if(_S1631)
            {
                float _S1689 = (&lobe_8)->pdf;
                float3  _S1690 = (&ray_2)->origin;
                float3  _S1691 = _slang_select(_S1501, _S1302,_S1475.smooth_n);
                float3  _S1692 = (&ray_2)->origin;
                FKSurface _S1693 = surface_11;
                float3  _S1694 = - _S1475.smooth_n;
                float3  _S1695 = _slang_select(_S1629, _S1694,_S1475.smooth_n);
                NEEVertex _S1696 = NEEVertex_x24init_0(false, _S1689, _S1690, _S1691, _S1692 + make_float3 (_S1693.geometry_offset) * _S1695);
                nee_vertex_0 = _S1696;
            }
            else
            {
                if(_S1496)
                {
                    _S1632 = true;
                }
                else
                {
                    bool _S1697 = b_11 != 1U;
                    if(_S1697)
                    {
                        _S1632 = true;
                    }
                    else
                    {
                        _S1632 = (_S1491.x) != (_S1491.y);
                    }
                }
                if(_S1632)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1698 = withinInverseFootprint((&lobe_8)->pdf, _S1622, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1699 = roughLobe((&lobe_8)->pdf, _S1622, _S1683);
            if(_S1529)
            {
                bool _S1700 = !_S1698;
                if(_S1700)
                {
                    return _S1303;
                }
                bool _S1701 = _S1308 != 1U;
                if(_S1701)
                {
                    _S1632 = _S1308 != 2U;
                }
                else
                {
                    _S1632 = false;
                }
                if(_S1632)
                {
                    float _S1702 = (&lobe_8)->pdf;
                    float _S1703 = _slang_select(nee_0, _S1702,0.0f);
                    float _S1704 = escapeWeight_0(_S1703, _S1645);
                    if(_S1537)
                    {
                        passes_0 = _S1314;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1705 = _slang_select(passes_0, _S1704,1.0f);
                    return Shift_x24init_0(throughput_7 * ((&lobe_8)->throughput * make_float3 ((&lobe_8)->pdf)) * r_8->radiance * make_float3 (_S1705) / make_float3 (r_8->jac), density_4 * (&lobe_8)->pdf / r_8->jac);
                }
                float3  _S1706 = throughput_7 * make_float3 ((&lobe_8)->pdf);
                float _S1707 = density_4 * (&lobe_8)->pdf;
                throughput_10 = _S1706;
                density_6 = _S1707;
            }
            else
            {
                throughput_10 = throughput_7;
                density_6 = density_4;
            }
            uint _S1708 = (fcptLayers((hit_4)));
            bool _S1709 = b_11 == 1U;
            bool _S1710 = passesLayer_0(_S1708, _S1709, passes_0);
            if(viewed_1)
            {
                _S1632 = _S1710;
            }
            else
            {
                _S1632 = false;
            }
            if(_S1632)
            {
                return _S1303;
            }
            if(replay_2)
            {
                _S1633 = b_8 <= _S1318;
            }
            else
            {
                _S1633 = false;
            }
            if(_S1633)
            {
                _S1634 = _S1473;
            }
            else
            {
                _S1634 = false;
            }
            if(_S1634)
            {
                _S1635 = _S1698;
            }
            else
            {
                _S1635 = false;
            }
            if(_S1635)
            {
                _S1636 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1636 = !_S1699;
                }
                else
                {
                    _S1636 = false;
                }
            }
            if(_S1636)
            {
                return _S1303;
            }
            if(viewed_1)
            {
                float3  _S1711 = throughput_10 * ((&lobe_8)->throughput * make_float3 ((&lobe_8)->pdf));
                float _S1712 = (&lobe_8)->pdf;
                throughput_11 = _S1711;
                sky_pdf_2 = _S1712;
            }
            else
            {
                float3  _S1713 = throughput_10 * max_0((&lobe_8)->throughput, _S1302);
                throughput_11 = _S1713;
                sky_pdf_2 = density_6;
            }
            bool _S1714 = !replay_2;
            bool _S1715;
            if(_S1714)
            {
                _S1715 = !_S1517;
            }
            else
            {
                _S1715 = false;
            }
            bool _S1716;
            if(_S1715)
            {
                _S1716 = _S1473;
            }
            else
            {
                _S1716 = false;
            }
            bool _S1717;
            if(_S1716)
            {
                _S1717 = _S1698;
            }
            else
            {
                _S1717 = false;
            }
            float3  chain_throughput_1;
            if(_S1717)
            {
                chain_0 = here_0;
                uint _S1718 = insertBits_0((&chain_0)->path, b_11, 18U, 3U);
                uint _S1719 = _slang_select(nee_0, 1U,0U);
                uint _S1720 = insertBits_0(_S1718, _S1719, 21U, 1U);
                (&chain_0)->path = _S1720;
                float _S1721 = (&chain_0)->jac * (&lobe_8)->pdf;
                (&chain_0)->jac = _S1721;
                (&chain_0)->dir = throughput_9;
                chain_throughput_1 = throughput_11;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1722 = surface_11;
            Vertex _S1723 = Vertex_x24init_0(_S1699, b_11, (&lobe_8)->pdf, (F32_abs((dot_0(surface_11.geometry_n, throughput_9)))), is_inside_6);
            prev_0 = _S1723;
            float _S1724 = (&lobe_8)->pdf;
            bool _S1725;
            if(_S1709)
            {
                _S1725 = (_S1491.x) == (_S1491.y);
            }
            else
            {
                _S1725 = false;
            }
            float sky_pdf_3 = _slang_select(_S1725, sky_pdf_0,_S1724);
            float _S1726 = _slang_select(_S1496, 0.0f,sky_pdf_3);
            float _S1727 = widened_0(spread_2, (&lobe_8)->pdf, _S1623);
            bool _S1728;
            if(refracted_4)
            {
                _S1728 = !_S1629;
            }
            else
            {
                _S1728 = false;
            }
            bool is_inside_7;
            if(_S1728)
            {
                bool _S1729 = !is_inside_6;
                is_inside_7 = _S1729;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1730 = surface_11;
            bool _S1731 = boundsVolume_0(&_S1730);
            bool _S1732;
            if(_S1731)
            {
                _S1732 = !_S1710;
            }
            else
            {
                _S1732 = false;
            }
            if(_S1732)
            {
                FKSurface faced_2 = surface_11;
                float3  _S1733 = - _S1722.geometry_n;
                float3  _S1734 = _slang_select(turned_1, _S1733,_S1722.geometry_n);
                (&faced_2)->geometry_n = _S1734;
                FKMedium _S1735 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1736 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1737 = faced_2;
                FKMedium _S1738 = _S1735;
                FKMedium _S1739 = _S1736;
                MediumSides _S1740 = mediumSides_0(&_S1737, &_S1738, filling_2, (&ray_2)->unit_direction, &_S1739);
                bool _S1741 = leavesInFront_0((&faced_2)->geometry_n, throughput_9, _S1722.geometry_n);
                float3  _S1742 = _slang_select(_S1741, _S1740.front.scatter,_S1740.behind.scatter);
                scatter_in_0 = _S1742;
                float3  _S1743 = _slang_select(_S1741, _S1740.front.extinction,_S1740.behind.extinction);
                extinction_in_0 = _S1743;
                float _S1744 = _slang_select(_S1741, _S1740.front.g,_S1740.behind.g);
                g_in_0 = _S1744;
                uint _S1745 = _S1740.fillings.x;
                uint _S1746 = _S1740.fillings.y;
                uint _S1747 = _slang_select(_S1741, _S1746,_S1745);
                bool _S1748 = (fcptVaryingUsed());
                uint _S1749 = _slang_select(_S1748, _S1747,4294967295U);
                filling_2 = _S1749;
            }
            (&ray_2)->unit_direction = throughput_9;
            bool _S1750 = !_S1710;
            if(_S1750)
            {
                FKSurface _S1751 = surface_11;
                float _S1752 = _slang_select(straight_0, 0.0f,_S1751.geometry_offset);
                float3  _S1753 = - _S1475.smooth_n;
                bool _S1754 = is_inside_7 != _S1629;
                float3  _S1755 = _slang_select(_S1754, _S1753,_S1475.smooth_n);
                float3  _S1756 = (&ray_2)->origin + make_float3 (_S1752) * _S1755;
                (&ray_2)->origin = _S1756;
            }
            throughput_10 = throughput_11;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1710;
            viewed_1 = _S1627;
            sky_pdf_2 = _S1726;
            spread_5 = _S1727;
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
        bool _S1757 = !replay_2;
        float density_7;
        if(_S1757)
        {
            if(_S1444)
            {
                float3  _S1758 = throughput_10 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1759 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1760 = _S1759 == 1U;
                if(_S1760)
                {
                    float3  _S1761 = safeDivide(_S1758, chain_throughput_0);
                    (&candidate_8)->radiance = _S1761;
                }
                Reservoir _S1762 = withEnd(candidate_8, 2U, b_8, _S1758);
                offer(sel_7, _S1762, _S1758 * make_float3 (scale_4) / make_float3 (density_6));
            }
            if(_S1444)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1763 = survivalProbability(abs_0(throughput_10), density_6);
                density_7 = _S1763;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1764 = stream(_S1330, b_8 + 128U);
            Random _S1765 = pcg(_S1764);
            bool _S1766 = density_7 < (_S1765.value);
            if(_S1766)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1767 = (fcptMaxBounces());
                wrong_side_0 = b_8 >= _S1767;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1768 = density_6 * density_7;
            density_7 = _S1768;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1769 = layer_0 ^ 1U;
        uint _S1770 = _slang_select(passes_0, _S1769,0U);
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
            uint _S1771 = b_11 + 1U;
            b_8 = _S1771;
            layer_0 = _S1770;
            continue;
        }
        FKRay _S1772 = ray_2;
        float _S1773 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1530;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1307 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1774 = _slang_select(wrong_side_0, _S1773,4.294967296e+09f);
        bool _S1775 = !_S1496;
        if(straight_0)
        {
            _S1574 = true;
        }
        else
        {
            _S1574 = _S1496;
        }
        FKHit _S1776;
        if(_S1574)
        {
            _S1776 = hit_4;
        }
        else
        {
            _S1776 = _S1547;
        }
        FKHit _S1777 = (fcptTraverseInstanceBVH((_S1772), (_S1449), (_S1774), (_S1775), (_S1776), (viewed_1)));
        hit_4 = _S1777;
        if(replay_2)
        {
            _S1575 = _S1530;
        }
        else
        {
            _S1575 = false;
        }
        if(_S1575)
        {
            _S1622 = _S1307 == 1U;
        }
        else
        {
            _S1622 = false;
        }
        if(_S1622)
        {
            _S1623 = ((&hit_4)->instance_index) == (_S1319.instance_index);
        }
        else
        {
            _S1623 = false;
        }
        if(_S1623)
        {
            _S1624 = ((&hit_4)->triangle_index) == (_S1319.triangle_index);
        }
        else
        {
            _S1624 = false;
        }
        if(_S1624)
        {
            (&hit_4)->uv = _S1319.uv;
            float _S1778 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1778;
        }
        if(replay_2)
        {
            _S1625 = _S1530;
        }
        else
        {
            _S1625 = false;
        }
        if(_S1625)
        {
            _S1626 = _S1307 == 3U;
        }
        else
        {
            _S1626 = false;
        }
        if(_S1626)
        {
            _S1627 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1627 = false;
        }
        if(_S1627)
        {
            return _S1303;
        }
        Reservoir _S1779 = chain_0;
        uint _S1780 = filling_2;
        for(;;)
        {
            bool _S1781 = (fcptVaryingUsed());
            if(_S1781)
            {
                _S1628 = _S1780 != 4294967295U;
            }
            else
            {
                _S1628 = false;
            }
            float _S1782;
            if(_S1628)
            {
                float _S1783 = (fcptMajorant((_S1780)));
                _S1782 = _S1783;
            }
            else
            {
                _S1782 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1629 = _S1530;
            }
            else
            {
                _S1629 = false;
            }
            if(_S1629)
            {
                _S1630 = _S1307 == 1U;
            }
            else
            {
                _S1630 = false;
            }
            if(_S1630)
            {
                _S1631 = _S1782 > 0.0f;
            }
            else
            {
                _S1631 = false;
            }
            if(_S1631)
            {
                ended_0 = _S1303;
                sky_pdf_1 = sky_pdf_2;
                spread_3 = spread_5;
                width_4 = width_3;
                density_3 = density_7;
                throughput_11 = throughput_10;
                b_11 = b_8;
                _S1632 = true;
                break;
            }
            bool _S1784 = (&prev_0)->rough;
            if(_S1784)
            {
                _S1632 = !(_S1782 > 0.0f);
            }
            else
            {
                _S1632 = false;
            }
            (&prev_0)->rough = _S1632;
            uint _S1785 = b_8 + 320U;
            bool _S1786 = b_8 == 4294967295U;
            uint _S1787 = _slang_select(_S1786, 384U,_S1785);
            uint _S1788 = stream(_S1330, _S1787);
            uint tracking_1 = _S1788;
            weight_1 = throughput_3;
            glowed_0 = _S1302;
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
                    _S1301 = int(2);
                    break;
                }
                uint _S1789 = b_11 + 320U;
                bool _S1790 = b_11 == 4294967295U;
                uint _S1791 = _slang_select(_S1790, 384U,_S1789);
                uint _S1792 = stream(_S1330, _S1791);
                Random _S1793 = pcg(_S1792);
                float _S1794 = freeFlight_0(_S1793.value, _S1782);
                if(_S1628)
                {
                    float3  _S1795 = (&ray_2)->origin;
                    float3  _S1796 = (&ray_2)->unit_direction;
                    float _S1797 = (&hit_4)->distance;
                    uint _S1798 = _slang_select(_S1790, 0U,b_11);
                    uint _S1799 = (&prev_0)->lobe;
                    uint _S1800 = _slang_select(_S1790, 3U,_S1799);
                    float _S1801 = (fcptTrackMedium((_S1780), (_S1795), (_S1796), (_S1797), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1798), (_S1800), (_S1790)));
                    spread_4 = _S1801;
                }
                else
                {
                    spread_4 = _S1794;
                }
                bool _S1802 = !(spread_4 < ((&hit_4)->distance));
                if(_S1802)
                {
                    _S1301 = int(2);
                    break;
                }
                if(_S1628)
                {
                    _S1633 = _S1757;
                }
                else
                {
                    _S1633 = false;
                }
                if(_S1633)
                {
                    float3  _S1803 = throughput_11 * glowed_0 / make_float3 (density_3);
                    float3  _S1804 = sel_7->glow + _S1803;
                    sel_7->glow = _S1804;
                }
                else
                {
                }
                glowed_0 = _S1302;
                uint b_12 = b_11 + 1U;
                float3  _S1805 = (&ray_2)->origin + make_float3 (spread_4) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1805;
                float3  _S1806 = flightWeight_0(scatter_in_0, extinction_in_0, _S1782, spread_4, true);
                float3  _S1807 = weight_1;
                float3  _S1808 = _slang_select(_S1628, _S1807,_S1806);
                float3  throughput_12 = throughput_11 * _S1808;
                uint _S1809 = stream(_S1330, b_12 + 320U);
                tracking_1 = _S1809;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_3 * spread_4;
                float _S1810 = spread_3 + 3.14159274101257324f;
                bool _S1811 = scatterSampled_0(replay_2, b_12, _S1318, _S1628);
                TreeSample light_4;
                if(_S1811)
                {
                    float3  _S1812 = (&ray_2)->origin;
                    float3  _S1813 = (&ray_2)->unit_direction;
                    float3  _S1814 = (&ray_2)->unit_direction;
                    uint _S1815 = stream(_S1330, b_12 + 64U);
                    float3  _S1816 = extinction_in_0;
                    float3  _S1817 = extinction_in_0;
                    uint2  _S1818 = make_uint2 (_S1780);
                    float3  _S1819 = (&ray_2)->unit_direction;
                    uint _S1820 = arrivalLobe_0(b_12, (&prev_0)->lobe);
                    FKHit _S1821 = _S1547;
                    ShadowContext _S1822 = ShadowContext_x24init_0(_S1816, _S1817, _S1818, _S1819, b_12, _S1820, false, spread_4, width_7, &_S1821, false);
                    ShadowContext _S1823 = _S1822;
                    TreeSample _S1824 = sampleLightTree_0(_S1812, _S1813, _S1814, 0.0f, true, _S1815, &_S1823);
                    light_4 = _S1824;
                }
                else
                {
                    light_4 = _S1544;
                }
                float _S1825 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1826 = (fcptMaxBounces());
                bool _S1827 = b_12 < _S1826;
                if(_S1827)
                {
                    _S1634 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1634 = false;
                }
                float _S1828 = _slang_select(_S1634, _S1825,0.0f);
                float3  _S1829 = throughput_12 * light_4.radiance;
                float _S1830 = powerHeuristic(light_4.density, _S1828);
                float3  _S1831 = _S1829 * make_float3 (_S1825 * _S1830);
                float3  _S1832 = _slang_select(_S1811, _S1831,_S1302);
                if(replay_2)
                {
                    _S1635 = b_12 == _S1318;
                }
                else
                {
                    _S1635 = false;
                }
                if(_S1635)
                {
                    bool _S1833 = _S1307 == 2U;
                    if(_S1833)
                    {
                        float _S1834 = resamplingTarget(_S1832);
                        _S1636 = _S1834 > 0.0f;
                    }
                    else
                    {
                        _S1636 = false;
                    }
                    if(_S1636)
                    {
                        Shift _S1835 = Shift_x24init_0(_S1832, 1.0f);
                        _S1301 = int(1);
                        ended_0 = _S1835;
                        spread_4 = _S1810;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_9 = b_12;
                        break;
                    }
                    _S1301 = int(1);
                    ended_0 = _S1303;
                    spread_4 = _S1810;
                    width_5 = width_7;
                    throughput_9 = throughput_12;
                    b_9 = b_12;
                    break;
                }
                if(_S1757)
                {
                    Reservoir candidate_9 = _S1779;
                    uint _S1836 = extractBits_0(_S1779.path, 10U, 2U);
                    bool _S1837 = _S1836 == 1U;
                    if(_S1837)
                    {
                        float3  _S1838 = safeDivide(_S1832, chain_throughput_0);
                        (&candidate_9)->radiance = _S1838;
                    }
                    else
                    {
                        uint _S1839 = insertBits_0(0U, b_12 + 1U, 5U, 5U);
                        uint _S1840 = insertBits_0(_S1839, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1840;
                    }
                    Reservoir _S1841 = withEnd(candidate_9, 0U, b_12, _S1832);
                    offer(sel_7, _S1841, _S1832 * make_float3 (scale_4) / make_float3 (density_3));
                    float _S1842 = survivalProbability(abs_0(throughput_12), density_3);
                    uint _S1843 = stream(_S1330, b_12 + 128U);
                    Random _S1844 = pcg(_S1843);
                    bool _S1845 = _S1842 < (_S1844.value);
                    if(_S1845)
                    {
                        _S1636 = true;
                    }
                    else
                    {
                        uint _S1846 = (fcptMaxBounces());
                        _S1636 = b_12 >= _S1846;
                    }
                    if(_S1636)
                    {
                        _S1301 = int(1);
                        ended_0 = _S1303;
                        spread_4 = _S1810;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_9 = b_12;
                        break;
                    }
                    float _S1847 = density_3 * _S1842;
                    density_3 = _S1847;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1848 = stream(_S1330, b_12);
                float3  _S1849 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1848, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1849;
                NEEVertex _S1850 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1302, (&ray_2)->origin);
                nee_vertex_0 = _S1850;
                Vertex _S1851 = scatteredVertex_0(is_inside_5);
                prev_0 = _S1851;
                float _S1852 = (&prev_0)->pdf;
                FKRay _S1853 = ray_2;
                FKHit _S1854 = (fcptTraverseInstanceBVH((_S1853), (true), (4.294967296e+09f), (false), (_S1547), (false)));
                hit_4 = _S1854;
                b_11 = b_12;
                throughput_11 = throughput_12;
                spread_3 = _S1810;
                width_4 = width_7;
                sky_pdf_1 = _S1852;
            }
            if(_S1301 != int(2))
            {
                spread_3 = spread_4;
                width_4 = width_5;
                throughput_11 = throughput_9;
                b_11 = b_9;
                _S1632 = true;
                break;
            }
            ended_0 = _S1303;
            _S1632 = false;
            break;
        }
        if(_S1632)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1633 = b_11 == b_8;
        }
        else
        {
            _S1633 = false;
        }
        bool _S1855 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1855)
        {
            bool _S1856 = !(&nee_vertex_0)->none;
            float _S1857 = _slang_select(_S1856, sky_pdf_1,0.0f);
            float _S1858 = escapeWeight_0(_S1857, (&ray_2)->unit_direction);
            float3  _S1859 = environment_0((&ray_2)->unit_direction, b_11, (&prev_0)->lobe);
            float3  _S1860 = throughput_11 * _S1859;
            if(replay_2)
            {
                bool _S1861 = b_11 == _S1318;
                if(_S1861)
                {
                    passes_0 = _S1307 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1860 * make_float3 (_S1858) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1317)
                {
                    passes_0 = _S1314;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_11 == _S1305;
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
                    return Shift_x24init_0(_S1860 * make_float3 (_S1858), 1.0f);
                }
                return _S1303;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1862 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1863 = _S1862 == 1U;
            if(_S1863)
            {
                uint _S1864 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1865 = _S1864 == b_11;
                float _S1866 = _slang_select(_S1865, 1.0f,_S1858);
                float3  _S1867 = safeDivide(_S1860 * make_float3 (_S1866), chain_throughput_0);
                (&candidate_10)->radiance = _S1867;
            }
            else
            {
                bool _S1868 = (&prev_0)->rough;
                if(_S1868)
                {
                    uint _S1869 = insertBits_0(0U, b_11 + 1U, 5U, 5U);
                    uint _S1870 = insertBits_0(_S1869, 3U, 10U, 2U);
                    uint _S1871 = insertBits_0(_S1870, (&prev_0)->lobe, 15U, 3U);
                    bool _S1872 = (&prev_0)->inside;
                    uint _S1873 = _slang_select(_S1872, 1U,0U);
                    uint _S1874 = insertBits_0(_S1871, _S1873, 22U, 1U);
                    (&candidate_10)->path = _S1874;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1875 = _S1860 * make_float3 (_S1858);
            Reservoir _S1876 = withEnd(candidate_10, 3U, b_11, _S1875);
            offer(sel_7, _S1876, _S1875 * make_float3 (scale_4) / make_float3 (density_3));
            break;
        }
        float3  _S1877 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1877;
        bool _S1878 = (fcptVaryingUsed());
        if(_S1878)
        {
            _S1634 = filling_2 != 4294967295U;
        }
        else
        {
            _S1634 = false;
        }
        if(_S1634)
        {
            if(_S1757)
            {
                float3  _S1879 = throughput_11 * glowed_0 / make_float3 (density_3);
                float3  _S1880 = sel_7->glow + _S1879;
                sel_7->glow = _S1880;
            }
            float3  _S1881 = throughput_11 * weight_1;
            throughput_9 = _S1881;
        }
        else
        {
            float3  _S1882 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1883 = throughput_11 * _S1882;
            throughput_9 = _S1883;
        }
        float _S1884 = width_4 + spread_3 * (&hit_4)->distance;
        viewed_0 = _S1633;
        width_3 = _S1884;
        throughput_2 = throughput_9;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_3;
        uint _S1771 = b_11 + 1U;
        b_8 = _S1771;
        layer_0 = _S1770;
    }
    return _S1303;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_9)
{
    Selection _S1885 = (Selection{});
    Selection sel_8 = _S1885;
    bool _S1886 = (r_9->w) <= 0.0f;
    if(_S1886)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1887 = walk_0(dom_8, r_9, true, 0.0f, &sel_8);
    return _S1887;
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
    Random _S1888 = pcg(state_3);
    Random _S1889 = pcg(_S1888.state);
    float _S1890 = 6.28318548202514648f * _S1888.value;
    float _S1891 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1889.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1889.state, _S1891 * (F32_cos((_S1890))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1892;
    (&_S1892)->state = state_4;
    (&_S1892)->value = value_2;
    return _S1892;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1893 = normal_distribution(state_5);
    Random _S1894 = normal_distribution(_S1893.state);
    Random _S1895 = normal_distribution(_S1894.state);
    float3  _S1896 = make_float3 (_S1893.value, _S1894.value, _S1895.value);
    float3  _S1897 = ((((_S1896)) * make_float3(rnorm3df(((_S1896)).x, ((_S1896)).y, ((_S1896)).z))));
    return RandomSphere_x24init_0(_S1895.state, _S1897);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_16)
{
    float3  _S1898 = p1_0 - p0_0;
    float3  _S1899 = p2_0 - p0_0;
    float2  _S1900 = uv1_0 - uv0_0;
    float2  _S1901 = uv2_0 - uv0_0;
    float _S1902 = _S1900.x;
    float _S1903 = _S1901.y;
    float _S1904 = _S1900.y;
    float _S1905 = _S1901.x;
    float _S1906 = _S1902 * _S1903 - _S1904 * _S1905;
    float _S1907 = 1.0f / _S1906;
    float3  t_22 = (_S1898 * make_float3 (_S1903) - _S1899 * make_float3 (_S1904)) * make_float3 (_S1907);
    float3  _S1908 = (_S1899 * make_float3 (_S1902) - _S1898 * make_float3 (_S1905)) * make_float3 (_S1907);
    float3  _S1909 = t_22 - n_16 * make_float3 (dot_0(n_16, t_22));
    float3  t_23 = ((((_S1909)) * make_float3(rnorm3df(((_S1909)).x, ((_S1909)).y, ((_S1909)).z))));
    bool _S1910 = (dot_0(cross_0(n_16, t_23), _S1908)) > 0.0f;
    float3  t_24;
    if(_S1910)
    {
        float3  _S1911 = negate_0(t_23);
        t_24 = _S1911;
    }
    else
    {
        t_24 = t_23;
    }
    float3  _S1912 = cross_0(n_16, t_24);
    return makeMatrix<float, 3, 3> (t_24, _S1912, n_16);
}

__device__ float3  tangentToWorldNormalMap(float3  v_4, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_4, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1913 = t1_0 - t0_0;
    float3  _S1914 = t2_2 - t0_0;
    float3  _S1915 = t2_2 - t1_0;
    float _S1916 = (F32_min((length_0(_S1913)), ((F32_min((length_0(_S1914)), (length_0(_S1915)))))));
    float3  _S1917 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1918 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1919 = dot_0(geometry_n_5, _S1918);
    float3  _S1920 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1921 = dot_0(geometry_n_5, _S1920);
    float3  _S1922 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1923 = acos_0(abs_0(make_float3 (_S1919, _S1921, dot_0(geometry_n_5, _S1922))));
    float3  _S1924 = clamp_2(tan_0(_S1923), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1917 * _S1924, uvw_0), 0.0f, _S1916 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_15, float3  n_17, BSDFMaterial material_20)
{
    float3  _S1925 = negate_0(dir_15);
    float _S1926 = sign_0(dot_0(n_17, _S1925));
    float3  _S1927 = n_17 * make_float3 (_S1926);
    AnisotropicFrame _S1928 = anisotropicFrame(material_20, _S1927);
    bool _S1929 = (_S1928.alphas.x) > 0.0f;
    if(_S1929)
    {
        float _S1930 = material_20.transmission * (1.0f - material_20.metallic);
        float3  _S1931 = negate_0(_S1927);
        float3  _S1932 = anisotropicLocal(dir_15, _S1928.tangent, _S1931);
        float _S1933 = anisotropicG1(_S1932, _S1928.alphas);
        return make_float3 (_S1930 * _S1933) * material_20.albedo;
    }
    float _S1934 = material_20.transmission * (1.0f - material_20.metallic);
    float _S1935 = material_20.roughness;
    float _S1936 = smithG1(_S1935 * _S1935, (F32_abs((dot_0(n_17, dir_15)))));
    return make_float3 (_S1934 * _S1936) * material_20.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_25, float3  out_dir_4, uint p_14, float w_2, float alpha_6, uint nt_0)
{
    uint _S1937 = p_14 % 4U;
    float _S1938 = w_2 * HAIR_WIDTHS_0[_S1937];
    float _S1939 = (F32_asin((clamp_1(dot_0(out_dir_4, t_25), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_25), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1937] * alpha_6;
    return ((F32_asinh((_S1939 / _S1938))) / (F32_asinh((3.14159274101257324f / _S1938))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_26, float3  out_dir_5, uint np_0)
{
    float3  _S1940 = worldToTangent(out_dir_5, t_26);
    float3  _S1941 = worldToTangent(in_dir_12, t_26);
    return (F32_frac((((F32_atan2((_S1940.z), (_S1940.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1941.z), (1.17549435082228751e-38f - _S1941.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_27, uint p_15, float row_0, float column_0, float w_3, float alpha_7, uint nt_1, uint np_1)
{
    float3  _S1942 = worldToTangent(in_dir_13, t_27);
    uint _S1943 = p_15 % 4U;
    float _S1944 = w_3 * HAIR_WIDTHS_0[_S1943];
    float _S1945 = (F32_asin((clamp_1(dot_0(in_dir_13, t_27), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1943] * alpha_7 + _S1944 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1944))))));
    float _S1946 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1942.z), (1.17549435082228751e-38f - _S1942.x)));
    float _S1947 = (F32_cos((_S1945)));
    float3  _S1948 = tangentToWorld(make_float3 (_S1947 * (F32_cos((_S1946))), (F32_sin((_S1945))), _S1947 * (F32_sin((_S1946)))), t_27);
    return _S1948;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_18, BSDFMaterial material_21, float coverage_1)
{
    float3  through_1;
    if((material_21.ior) == 1.0f)
    {
        float3  _S1949 = straightThrough(toward_1, n_18, material_21);
        through_1 = _S1949;
    }
    else
    {
        through_1 = make_float3 (0.0f);
    }
    bool _S1950 = (material_21.coat) > 0.0f;
    if(_S1950)
    {
        float3  _S1951 = coatNormal(material_21, n_18);
        float _S1952 = fresnel((F32_abs((dot_0(_S1951, toward_1)))), 1.0f, (F32_max((material_21.coat_ior), (1.00999999046325684f))));
        float3  _S1953 = mix_0(make_float3 (1.0f), make_float3 (1.0f - _S1952) * material_21.coat_tint, material_21.coat);
        float3  through_2 = through_1 * _S1953;
        through_1 = through_2;
    }
    return through_1 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_5, Selection * sel_9)
{
    Domain _S1954 = dom_9;
    Reservoir _S1955 = r_10;
    Shift _S1956 = walk_0(&_S1954, &_S1955, replay_3, scale_5, sel_9);
    return _S1956;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_11)
{
    Domain _S1957 = dom_10;
    Reservoir _S1958 = r_11;
    Shift _S1959 = shift_0(&_S1957, &_S1958);
    return _S1959;
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
